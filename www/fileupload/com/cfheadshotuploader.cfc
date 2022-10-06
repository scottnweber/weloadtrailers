
<cfcomponent hint="I handle AJAX File Uploads from Valum's AJAX file uploader library">
	
    <cffunction name="Upload" access="remote" output="false" returntype="any" returnformat="JSON">
		<cfargument name="qqfile" type="string" required="true">
		<cfargument name="dsn" type="string" required="false">
		<cfargument name="companyID" type="string" required="false">

		<cfset TheKey = 'NAMASKARAM'>					
		<cfset dsn = Decrypt(ToString(ToBinary(dsn)), TheKey)>
		
		<cfset var local = structNew()>
		<cfset local.response = structNew()>
		<cfset local.requestData = GetHttpRequestData()>
		<cfset local.response.FILENAME = "">
		
		<CFSET UploadDir = "#ExpandPath('../')#img\">
		
		<!--- Begin : DropBox Integration  ---->
		<cfquery name="qrygetSettingsForDropBox" datasource="#dsn#">
			SELECT 
				DropBox,
				DropBoxAccessToken
			FROM SystemConfig WHERE CompanyID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.CompanyID#" >
		</cfquery>
		<cfquery name="qrygetCommonDropBox" datasource="LoadManagerAdmin">
			SELECT 
			<cfif len(trim(qrygetSettingsForDropBox.DropBoxAccessToken))>
				'#qrygetSettingsForDropBox.DropBoxAccessToken#'
			<cfelse>
				DropBoxAccessToken 
			</cfif>
			AS DropBoxAccessToken
			FROM SystemSetup
		</cfquery>
		<cfquery name="qGetCompany" datasource="#dsn#">
			SELECT 
				CompanyCode
			FROM Companies WHERE CompanyID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.CompanyID#" >
		</cfquery>
		<!--- End : DropBox Integration  ---->
		
		<cfif qrygetSettingsForDropBox.DropBox EQ 1 > <!---  Store file @ DropBox  ----> 
			<!--- Begin : DropBox Integration  ---->
			<cfhttp
					method="post"
					url="https://api.dropboxapi.com/2/users/get_current_account"	
					result="returnStruct"> 
							<cfhttpparam type="HEADER" name="Authorization" value="Bearer #qrygetCommonDropBox.DropBoxAccessToken#">		
			</cfhttp> 	
			<cfif returnStruct.Statuscode EQ "200 OK"> <!--- Authorization Success --->
				<cfhttp
						method="POST"
						url="https://api.dropboxapi.com/2/files/get_metadata"	
						result="returnStruct"> 
							<cfhttpparam type="HEADER" name="Authorization" value="Bearer #qrygetCommonDropBox.DropBoxAccessToken#">			
							<cfhttpparam type="HEADER" name="Content-Type" value="application/json">			
							<cfhttpparam type="body" value='{"path": "/fileupload/img/#qGetCompany.CompanyCode#"}'>			
				</cfhttp>				
				<cfif returnStruct.Statuscode NEQ "200 OK"> <!--- Folder Not Found, Create Folder ---->				
					<cfset tmpStruct = {
						 "path" = '/fileupload/img/#qGetCompany.CompanyCode#'
						}>
						<cfhttp
								method="post"
								url="https://api.dropboxapi.com/2/files/create_folder"	
								result="returnStructCreateFolder"> 
										<cfhttpparam type="HEADER" name="Authorization" value="Bearer #qrygetCommonDropBox.DropBoxAccessToken#">		
										<cfhttpparam type="HEADER" name="Content-Type" value="application/json">
										 <cfhttpparam type="body" value="#serializeJSON(tmpStruct)#">
						</cfhttp> 						
				</cfif>
				<cfif len(trim(arguments.qqfile))>
						<cffile action="upload"
							 fileField="file"
							 nameconflict="overwrite"
							 destination="#UploadDir#">	
				
							<cfset tempFileName = REReplace("#cffile.CLIENTFILENAME#", "[^A-Za-z0-9_.]","","all")>
							<cfif len(tempFileName) GT 0>
								<cfset UploadedFile = tempFileName&"_"&dateTimeFormat(now(),'YYMMDDHHNNSS')&"."&cffile.CLIENTFILEEXT>
							<cfelse>	
								<cfset UploadedFile = "file_"&dateTimeFormat(now(),'YYMMDDHHNNSS')&"."&cffile.CLIENTFILEEXT>
							</cfif>
						
							 <cffile action="rename"
								source="#UploadDir#/#cffile.CLIENTFILE#"
								destination="#UploadDir#/#UploadedFile#">
								
						<cfoutput>
							<cfset tmpStruct = {"path":"/fileupload/img/#qGetCompany.CompanyCode#/#UploadedFile#"
																,"mode":{".tag":"add"}
																,"autorename":true}>
						</cfoutput>
						<cffile action = "readbinary"
								file = "#UploadDir#/#UploadedFile#"
								variable="filcontent">
						<cfhttp
								method="post"
								url="https://content.dropboxapi.com/2/files/upload"	
								result="returnStruct"> 
									<cfhttpparam type="HEADER" name="Authorization" value="Bearer #qrygetCommonDropBox.DropBoxAccessToken#">		
									<cfhttpparam type="HEADER" name="Content-Type" value="application/octet-stream">
									<cfhttpparam type="HEADER" name="Dropbox-API-Arg" value="#serializeJSON(tmpStruct)#">
									<cfhttpparam type="body" value="#filcontent#">
						</cfhttp> 
							
						<cfif returnStruct.Statuscode EQ "200 OK">
							<cffile action="delete" 		file="#UploadDir#/#UploadedFile#">
							<cfset local.response['success'] 			= true>
							<cfset local.response['type']				 = 'form'>
							<cfset local.response.FILENAME		 = '#UploadedFile#'>
							<cfset local.addRecord = AddUploadedFileRecord(UploadedFile,arguments.id,arguments.attachTo,arguments.user,qrygetSettingsForDropBox.DropBox,arguments.flag,arguments.dsn,qGetCompany.CompanyCode,arguments.CompanyID,arguments.userFullName)>
						<cfelse>
							<cfset local.response['success'] 			= false>
						</cfif>					
					</cfif>
			<cfelse> <!--- Authorization Fails  ---->
					<cfset local.response['success'] 			= false>						
			</cfif>
			<!--- End : DropBox Integration  ---->
		<cfelse> <!---  Store file Locally  ---->
			<CFSET UploadDir = "#ExpandPath('../')#img/#qGetCompany.CompanyCode#">
			<cfif not directoryExists(UploadDir)>
				<cfdirectory action="create" directory="#UploadDir#">
			</cfif>			
			<!--- check if XHR data exists --->
			<cfif len(local.requestData.content) GT 0>
				<cfset local.response = UploadFileXhr(arguments.qqfile,local.requestData.content,qGetCompany.CompanyCode)>       
			<cfelse>
				<!--- no XHR data process as standard form submission --->
				
				<cffile action="upload" file="#arguments.qqfile#" destination="#UploadDir#" nameConflict="makeunique" >

				<cfset tempFileName = REReplace("#cffile.CLIENTFILENAME#", "[^A-Za-z0-9_.]","","all")>
				<cfif len(tempFileName) GT 0>
					<cfset UploadedFile = tempFileName&"."&cffile.CLIENTFILEEXT>
				<cfelse>	
					<cfset UploadedFile = "file_"&dateTimeFormat(now(),'Ymddhhnnssl')&"."&cffile.CLIENTFILEEXT>
				</cfif>
				
				<cfif fileExists("#UploadDir#/#cffile.ATTEMPTEDSERVERFILE#")>
					<cffile action="rename"	source="#UploadDir#/#cffile.ATTEMPTEDSERVERFILE#" destination="#UploadDir#/#UploadedFile#">
				</cfif>

				<cfset local.response['success'] = true>
				<cfset local.response['type'] = 'form'>
				<cfset local.response.FILENAME = AddUploadedFileRecord(UploadedFile,arguments.id,arguments.attachTo,arguments.user,qrygetSettingsForDropBox.DropBox,arguments.flag,arguments.dsn,qGetCompany.CompanyCode,arguments.CompanyID,arguments.userFullName)>
			</cfif>
		</cfif>	
		
		<cfreturn local.response>
	</cffunction>
      
    
    <cffunction name="UploadFileXhr" access="private" output="false" returntype="struct">
		<cfargument name="qqfile" type="string" required="true">
		<cfargument name="content" type="any" required="true">
		<cfargument name="CompanyCode" type="any" required="true">
		<cfset var local = structNew()>
		<cfset local.response = structNew()>
		<cfset local.response.FILENAME ="">
		<CFSET UploadDir = "#ExpandPath('../')#img/#arguments.CompanyCode#">

        <!--- write the contents of the http request to a file.  
		The filename is passed with the qqfile variable --->
		<cffile action="write" file="#UploadDir#/#arguments.qqfile#" output="#arguments.content#">

		<!--- if you want to return some JSON you can do it here.  
		I'm just passing a success message	--->
    	<cfset local.response['success'] = true>
    	<cfset local.response['type'] = 'xhr'>
		<cfset local.response.FILENAME = '#arguments.qqfile#'>
		<cfreturn local.response>
    </cffunction>
    <cffunction name="updateDriverDocument" access="remote" output="false" returntype="void">
    	<cfargument name="attachid" type="numeric" required="true">
		<cfargument name="checkedStatus" type="boolean" required="true">
		<cfargument name="dsn" type="string" required="true">

		<cfquery name="qryUpdate" datasource="#dsn#">
			update FileAttachments set 
			DriverDocument=<cfqueryparam cfsqltype="cf_sql_bit" value="#arguments.checkedStatus#">
			where attachment_Id=<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.attachid#">			
		</cfquery>
    </cffunction>
    <cffunction name="UpdateBillingDocument" access="remote" output="false" returntype="any" returnformat="JSON">
		<cfargument name="attachid" type="numeric" required="true">
		<cfargument name="checkedStatus" type="boolean" required="true">
		<cfargument name="flag" type="boolean" required="true">
		<cfargument name="dsn" type="string" required="true">
		
				<!--- Begin : DropBox Integration  ---->
		<cfquery name="qrygetSettingsForDropBox" datasource="#dsn#">
			SELECT 
				DropBox,
				DropBoxAccessToken
			FROM SystemConfig WHERE CompanyID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.CompanyID#" >
		</cfquery>
		<!--- End : DropBox Integration  ---->
		
		
		<cfif arguments.flag eq 0>
			<cfquery name="qryUpdate" datasource="#dsn#">
				update FileAttachments set 
				Billingattachments=<cfqueryparam cfsqltype="cf_sql_bit" value="#arguments.checkedStatus#" >
				<cfif qrygetSettingsForDropBox.DropBox EQ 1 > <!---  Store file @ DropBox  ----> 
					,DropBoxFile = <cfqueryparam cfsqltype="cf_sql_bit" value="1" >
				</cfif>
				where attachment_Id=<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.attachid#" >				
			</cfquery>
		<cfelse>
			<cfquery name="qSystemSetupOptions" datasource="#dsn#">
				update FileAttachmentsTemp set 
				Billingattachments=<cfqueryparam cfsqltype="cf_sql_bit" value="#arguments.checkedStatus#">
				<cfif qrygetSettingsForDropBox.DropBox EQ 1 > <!---  Store file @ DropBox  ----> 
					,DropBoxFile = <cfqueryparam cfsqltype="cf_sql_bit" value="1" >
				</cfif>
				where  attachment_Id=<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.attachid#" >				
			</cfquery>
		</cfif>
		<cfset var localresponse = structNew()>
		<cfset localresponse['attachid'] = arguments.attachid>
		<cfset localresponse['checkedStatus'] = arguments.checkedStatus>
		<cfreturn SerializeJSON(localresponse)>
	</cffunction>	
	
	<cffunction name="AddUploadedFileRecord" access="private" returntype="string">
		<cfargument name="attachmentFileName" type="string" required="true">
		<cfargument name="linkedId" type="string" required="true">
		<cfargument name="linkedTo" type="string" required="true">
		<cfargument name="uploadedBy" type="string" required="true">
		<cfargument name="isDropBox" type="string" required="true">
		<cfargument name="flag" type="string" required="true">
		<cfargument name="dsn" type="string" required="false">
		<cfargument name="companycode" type="string" required="false">
		<cfargument name="CompanyID" type="string" required="false">
		<cfargument name="userFullName" type="string" required="false">
		<cfif arguments.flag eq 0>
			<cfset var tablename = "FileAttachments">
		<cfelse>
			<cfset var tablename = "FileAttachmentsTemp">
		</cfif>
				
		<cfquery result="qryInsertUploadedFile" datasource="#arguments.dsn#">
			insert into #tablename#(
					linked_Id,
					linked_to,
					attachedFileLabel,
					attachmentFileName,
					uploadedBy
					<cfif arguments.isDropBox EQ 1 >,DropBoxFile</cfif>
					<cfif arguments.linkedId EQ 'systemsetup'>,CompanyID</cfif>
					)
					values(
					<cfqueryparam cfsqltype="cf_sql_nvarchar" value="#arguments.linkedId#">,
					'#arguments.linkedTo#',
					<cfqueryparam cfsqltype="cf_sql_nvarchar" value="">,
					<cfqueryparam cfsqltype="cf_sql_nvarchar" value="#arguments.attachmentFileName#">,
					<cfqueryparam cfsqltype="cf_sql_nvarchar" value="#arguments.uploadedBy#">
					<cfif arguments.isDropBox EQ 1 >,1</cfif>
					<cfif arguments.linkedId EQ 'systemsetup'>,<cfqueryparam cfsqltype="cf_sql_nvarchar" value="#arguments.CompanyID#"></cfif>
					)				
		</cfquery>
		<cfset variables.filenameEditedWithEXt = arguments.attachmentFileName>
		<cfif arguments.isDropBox EQ 0 >
			<cfset variables.attcahnumber=1>
			<cfif isnumeric(qryInsertUploadedFile.GENERATEDKEY)>
				<cfset variables.attcahnumber=qryInsertUploadedFile.GENERATEDKEY>
			</cfif>
			<cfset variables.filenameExt=listlast(arguments.attachmentFileName,'.')>
			<cfset variables.filenameEdited1=Replace(evaluate("arguments.attachmentFileName"), '#variables.filenameExt#', '#variables.attcahnumber#' ,'.')>
			<cfset variables.filenameEditedWithEXt=Replace(variables.filenameEdited1&'.'&variables.filenameExt,' ','','all')>
			<CFSET UploadDir = "#ExpandPath('../')#img/#arguments.companycode#/">
			<cfif not directoryExists(UploadDir)>
				<cfdirectory action="create" directory="#UploadDir#">
			</cfif>			
			<cffile  action = "rename" destination = "#UploadDir##variables.filenameEditedWithEXt#"  source = "#UploadDir##arguments.attachmentFileName#" nameconflict="make unique">
			<cfquery name="qryUpdate" datasource="#dsn#">
				update #tablename#
				set attachmentFileName=<cfqueryparam cfsqltype="cf_sql_nvarchar" value="#variables.filenameEditedWithEXt#">
				where attachment_Id=<cfqueryparam cfsqltype="cf_sql_integer" value="#variables.attcahnumber#">
			</cfquery>	
		</cfif>

		<cfif arguments.linkedTo EQ 1>
			<cfset NewDispatchNotes = "#DateTimeFormat(now(),"m/dd/yyyy h:nn: tt")# - #arguments.userFullName# > File attached > #arguments.attachmentFileName#">
			<cfquery name="qUpd" datasource="#application.dsn#">
				UPDATE Loads SET NewDispatchNotes = <cfqueryparam cfsqltype="cf_sql_varchar" value="#NewDispatchNotes#">+CHAR(13)+NewDispatchNotes
				WHERE LoadID = <cfqueryparam value="#arguments.linkedId#" cfsqltype="cf_sql_varchar">
			</cfquery>
		</cfif>
		<cfreturn variables.filenameEditedWithEXt>
	
	</cffunction>
	
	<cffunction name="UpdateLabel" access="remote" output="false" returntype="any" returnformat="JSON">
		<cfargument name="attachid" type="numeric" required="true">
		<cfargument name="label" type="string" required="true">
		<cfargument name="dsn" type="string" required="true">
		
		<cfquery name="qryUpdate" datasource="#arguments.dsn#">
			UPDATE FileAttachments SET attachedFileLabel = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.label#"> WHERE attachment_Id=<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.attachid#">
		</cfquery>
		<cfreturn 'success'>
	</cffunction>

	<cffunction name="UploadSupport" access="remote" output="false" returntype="any" returnformat="JSON">
		<cftry>
			<cfset resp = structNew()>
			
			<cfset UploadDir = "#ExpandPath('../')#img\support\">
			<cfif not directoryExists(UploadDir)>
				<cfdirectory action="create" directory="#UploadDir#">
			</cfif>
			<cffile action="upload" fileField="upload" nameconflict="MakeUnique" destination="#UploadDir#" result="fileUploaded"  accept="image/png, image/gif, image/jpg, image/jpeg">	

			<cfset fileUrl = "https://loadmanager.biz/LoadManagerLive/www/fileupload/img/support/#fileUploaded.serverfile#">
			<cfset resp['uploaded'] = 1>
			<cfset resp['fileName'] = fileUploaded.serverfile>
			<cfset resp['url'] = fileUrl>
			<cfreturn resp>
			<cfcatch>
				<cfset resp['uploaded'] = 0>
				<cfset err = structNew()>
				<cfset err['message'] = 'Unable to upload image.'>
				<cfset resp['error'] = err>
				<cfreturn resp>
			</cfcatch>
		</cftry>
	</cffunction>
</cfcomponent>