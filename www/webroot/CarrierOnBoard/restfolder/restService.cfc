<cfcomponent rest="true" restpath="/whZohoSigned/">
	<cffunction name="DocumentDetails" access="remote" returntype="void" httpMethod="POST">
		<cftry>
			<cfset var dsn = "LoadManagerLive">
	        <cfset var payLoad = GetHttpRequestData().content> 
			<cfset var structContent = deserializeJSON(payLoad)>
			<cfset var reqId = structContent.requests.request_id>

			<cfdirectory action="list" directory="#expandPath("\#dsn#\www\webroot\CarrierOnBoard\")#" recurse="false" name="dirList" filter="Temp_CarrierOnBoard*">
			<cfloop query="dirList">
				<cfif dateDiff('h', dirList.DateLastModified, now()) GTE 1>
					<cfset DirectoryDelete(expandPath('\#dsn#\www\webroot\CarrierOnBoard\#dirList.Name#'),true)>
				</cfif>
			</cfloop>

			<cfquery name="qGet" datasource="#dsn#">
				SELECT Carr.CarrierID,C.CompanyCode,S.DropBoxAccessToken FROM Carriers Carr
				INNER JOIN CarrierTemplateDocuments CD ON CD.CarrierID = Carr.CarrierID
				INNER JOIN Companies C ON C.CompanyID = Carr.CompanyID
				INNER JOIN SystemConfig S ON S.CompanyID = C.CompanyID
				WHERE CD.RequestID = <cfqueryparam value="#reqId#" cfsqltype="cf_sql_varchar">
			</cfquery>

			<cfquery name="qrygetCommonDropBox" datasource="LoadManagerAdmin">
				SELECT <cfif len(trim(qGet.DropBoxAccessToken))>'#qGet.DropBoxAccessToken#'<cfelse>DropBoxAccessToken</cfif> AS DropBoxAccessToken,ZohoToken,ZohoTokenExpiry
				FROM SystemSetup
			</cfquery>

			<cfif dateDiff("s", now(), qrygetCommonDropBox.ZohoTokenExpiry) LTE 0>
			    <cfhttp method="post" url="https://accounts.zoho.com/oauth/v2/token" result="objRespAccessToken">
			      <cfhttpparam type="url" name="refresh_token" value="1000.2cea9b0735011dad98cc3479f1734f48.980caac236c9085dfa9bc0aad5ee444a"/>
			      <cfhttpparam type="url" name="client_id" value="1000.KW1ZX4LDG0LMC6OC4V3BJZ57Z03AEZ"/>
			      <cfhttpparam type="url" name="client_secret" value="df1e7797a0b17ef9cab6a5d827da89a479238734ac"/>
			      <cfhttpparam type="url" name="grant_type" value="refresh_token"/>
			    </cfhttp>
			    
			    <cfset var structRespAccessToken = deserializeJSON(objRespAccessToken.filecontent)>
			    <cfset var auth_token = structRespAccessToken.access_token>

			    <cfquery name="qUpd" datasource="LoadManagerAdmin">
			    	UPDATE SystemSetup set 
			    	ZohoToken = <cfqueryparam value="#auth_token#" cfsqltype="cf_sql_varchar">
			    	,ZohoTokenExpiry = <cfqueryparam value="#dateAdd("s", 3600, now())#" cfsqltype="cf_sql_timestamp">
			   	</cfquery>
			<cfelse>
				<cfset var auth_token = qrygetCommonDropBox.ZohoToken>
			</cfif>

			<cfhttp method="get" url="https://sign.zoho.com/api/v1/requests/#reqId#/pdf" result="objRespPdf">
			    <cfhttpparam type="header" name="Authorization" value="Zoho-oauthtoken #auth_token#"/>
			</cfhttp>

			<cfif objRespPdf.Statuscode EQ "200">
				<cfhttp method="post" url="https://api.dropboxapi.com/2/users/get_current_account" result="objDropBoxAuth"> 
					<cfhttpparam type="HEADER" name="Authorization" value="Bearer #trim(qrygetCommonDropBox.DropBoxAccessToken)#">		
				</cfhttp> 
				<cfif objDropBoxAuth.Statuscode EQ "200 OK"> <!--- Authorization Success --->
					<cfhttp method="POST" url="https://api.dropboxapi.com/2/files/get_metadata"	result="objDropBoxFolder"> 
							<cfhttpparam type="HEADER" name="Authorization" value="Bearer #trim(qrygetCommonDropBox.DropBoxAccessToken)#">			
							<cfhttpparam type="HEADER" name="Content-Type" value="application/json">			
							<cfhttpparam type="body" value='{"path": "/fileupload/img/#qGet.CompanyCode#"}'>			
					</cfhttp>
					<cfif objDropBoxFolder.Statuscode NEQ "200 OK"> <!--- Folder Not Found, Create Folder ---->			
						<cfset tmpFolderStruct = {
							 "path" = '/fileupload/img/#qGet.CompanyCode#'
							}>
						<cfhttp
							method="post"
							url="https://api.dropboxapi.com/2/files/create_folder"	
							result="returnStructCreateFolder"> 
								<cfhttpparam type="HEADER" name="Authorization" value="Bearer #trim(qrygetCommonDropBox.DropBoxAccessToken)#">	
								<cfhttpparam type="HEADER" name="Content-Type" value="application/json">
								<cfhttpparam type="body" value="#serializeJSON(tmpFolderStruct)#">
						</cfhttp> 						
					</cfif>	

					<cfset pdfvar = objRespPdf.Filecontent.toByteArray()>
					<cfset FileName = "SignedOnboardDocument_#DateFormat(now(),'mmddyyyy')##TimeFormat(now(),'hhnnss')#.pdf">
					<cfset tmpStruct = {"path":"/fileupload/img/#qGet.CompanyCode#/#FileName#","mode":{".tag":"add"},"autorename":true}>

					<cfhttp method="post" url="https://content.dropboxapi.com/2/files/upload" result="objDropbox"> 
						<cfhttpparam type="HEADER" name="Authorization" value="Bearer #trim(qrygetCommonDropBox.DropBoxAccessToken)#">		
						<cfhttpparam type="HEADER" name="Content-Type" value="application/octet-stream">
						<cfhttpparam type="HEADER" name="Dropbox-API-Arg" value="#serializeJSON(tmpStruct)#">
						<cfhttpparam type="body" value="#pdfvar#">
					</cfhttp>

					<cfquery name="qIns" datasource="#dsn#">
						INSERT INTO FileAttachments(
							linked_Id,
							linked_to,
							attachedFileLabel,
							attachmentFileName,
							uploadedBy,
							DropBoxFile
						) VALUES (
							<cfqueryparam value="#qGet.CarrierID#" cfsqltype="cf_sql_varchar" null="#not len(qGet.CarrierID)#">,
							3,
							<cfqueryparam value="Signed Onboard Document" cfsqltype="cf_sql_varchar">,
							<cfqueryparam value="#FileName#" cfsqltype="cf_sql_varchar">,
							'ZohoSign',
							1
						)
					</cfquery>
				</cfif>
			</cfif>
			<cfcatch>
				<cfset var template = "restService:whZohoSigned">
                <cfset var errordetail = "">
                <cfif isDefined('cfcatch.cause.Detail') and isDefined('cfcatch.cause.Message')>
                    <cfset errordetail = "#cfcatch.cause.Detail##cfcatch.cause.Message#">
                <cfelseif isDefined('cfcatch.Message') >
                    <cfset errordetail = "#cfcatch.Message#">
                </cfif>
                <cfif structKeyExists(cfcatch, "TagContext") AND isArray(cfcatch.TagContext) AND NOT arrayIsEmpty(cfcatch.TagContext) AND isstruct(cfcatch.TagContext[1]) AND structKeyExists(cfcatch.TagContext[1], "raw_trace")>
                    <cfset template = cfcatch.TagContext[1].raw_trace>
                </cfif>
                <cfquery name="qInsLog" datasource="LoadManagerAdmin">
                    INSERT INTO LMErrorLog (CompanyCode,Detail,Status,FormData,URLData,Template,SourcePage)
                    VALUES (
                        <cfqueryparam value="" cfsqltype="cf_sql_varchar">
                        ,<cfqueryparam value="#errordetail#" cfsqltype="cf_sql_varchar">
                        ,'Pending'
                        ,<cfqueryparam value="#payLoad#" cfsqltype="cf_sql_varchar">
                        ,<cfqueryparam value="#SerializeJSON(url)#" cfsqltype="cf_sql_varchar">
                        ,<cfqueryparam value="#template#" cfsqltype="cf_sql_varchar">
                        ,NULL
                        )
                </cfquery>
			</cfcatch>
		</cftry>
	</cffunction>
</cfcomponent>