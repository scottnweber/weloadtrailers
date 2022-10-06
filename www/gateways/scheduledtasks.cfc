<cfcomponent output="true">
	<cffunction name="sch_sendPushNotification" access="remote" returntype="void">
		<cftry>
			<cfset var dsn = trim(listFirst(cgi.SCRIPT_NAME,'/'))>
			<CFSTOREDPROC PROCEDURE="SchTask_PushNotifications" DATASOURCE="#dsn#">
				<cfprocresult name="request.qGet">
			</CFSTOREDPROC>

			<cfset body = structNew()>
			<cfset data = structNew()>
			<cfset notification = structNew()>
			<cfset notification["title"] = "Please re-open Load Manager Mobile in order to meet the tracking requirements of the load you are hauling.">
			<cfset notification["body"] = "Click here to view more details.">
			<cfset data["type"] = "activeload">
			<cfset body["notification"] = notification>
			<cfset body["data"] = data>
			<cfloop query="request.qGet" group="LoadID">
				<cfif len(trim(request.qGet.Driver1Token))>
					<cfset body["to"] = "#request.qGet.Driver1Token#">
					<cfhttp url="https://fcm.googleapis.com/fcm/send" method="post" result="httpResponse">
					    <cfhttpparam type="header" name="Content-Type" value="application/json" />
					    <cfhttpparam type="header" name="Authorization" value="key=AAAAdqo-cek:APA91bE4N0GULDCoW9PkGf3gzl04YaQpik_L-WroRA1R9fo4tZgLVRGpuR0cvSd9ajfYkTj63_F1KjREjS6bXlKWX6v5Tvq6GmiTFqd_LuUuZv25XG1cDJbqn9Bs-XwN_R8W8saLKRTi" />
					    <cfhttpparam type="body" value="#SerializeJSON(Body)#" />
					</cfhttp>
				</cfif>
				<cfif len(trim(request.qGet.Driver2Token))>
					<cfset body["to"] = "#request.qGet.Driver2Token#">
					<cfhttp url="https://fcm.googleapis.com/fcm/send" method="post" result="httpResponse">
					    <cfhttpparam type="header" name="Content-Type" value="application/json" />
					    <cfhttpparam type="header" name="Authorization" value="key=AAAAdqo-cek:APA91bE4N0GULDCoW9PkGf3gzl04YaQpik_L-WroRA1R9fo4tZgLVRGpuR0cvSd9ajfYkTj63_F1KjREjS6bXlKWX6v5Tvq6GmiTFqd_LuUuZv25XG1cDJbqn9Bs-XwN_R8W8saLKRTi" />
					    <cfhttpparam type="body" value="#SerializeJSON(Body)#" />
					</cfhttp>
				</cfif>
			</cfloop>
			<cfcatch>
				<cfset CreateLogError(cfcatch)>
			</cfcatch>
		</cftry>
	</cffunction>

	<cffunction name="schedulerLocationUpdates" access="remote" returntype="void">
		<cftry>
			<cfset variables.dsn = trim(listFirst(cgi.SCRIPT_NAME,'/'))>

			<CFSTOREDPROC PROCEDURE="SchTask_LocationUpdates" DATASOURCE="#variables.dsn#">
				<cfprocresult name="request.qGetLoadDetails">
			</CFSTOREDPROC>
			
			<cfloop query="request.qGetLoadDetails" group="LoadID">
				<cfset var MailTo = ''>
				<cfif len(trim(request.qGetLoadDetails.EmailList))>
					<cfset MailTo = trim(request.qGetLoadDetails.EmailList)>
				<cfelse>
					<cfif listFindNoCase(request.qGetLoadDetails.DefaultLoadEmails, "Customer") AND len(trim(request.qGetLoadDetails.ContactEmail))>
						<cfset MailTo = listAppend(MailTo, request.qGetLoadDetails.ContactEmail,";")>
					</cfif>
					<cfif listFindNoCase(request.qGetLoadDetails.DefaultLoadEmails, "Sales Rep") AND len(trim(request.qGetLoadDetails.SalesRepEmail))>
						<cfset MailTo = listAppend(MailTo, request.qGetLoadDetails.SalesRepEmail,";")>
					</cfif>
					<cfif listFindNoCase(request.qGetLoadDetails.DefaultLoadEmails, "Dispatcher") AND len(trim(request.qGetLoadDetails.DispatcherEmail))>
						<cfset MailTo = listAppend(MailTo, request.qGetLoadDetails.DispatcherEmail,";")>
					</cfif>
					<cfif listFindNoCase(request.qGetLoadDetails.DefaultLoadEmails, "Company") AND len(trim(request.qGetLoadDetails.CCMail))>
						<cfset MailTo = listAppend(MailTo, request.qGetLoadDetails.CCMail,";")>
					</cfif>
				</cfif>
				<cfset MailTo = ListRemoveDuplicates(MailTo)>
				<cfset Subject = "#request.qGetLoadDetails.DefaultLoadEmailSubject# - Load## #request.qGetLoadDetails.LoadNumber#">

				<cfset Message = replace(request.qGetLoadDetails.DefaultLoadEmailtext,chr(13)&chr(10),"<br />","all")>

				<cfset Message = replaceNoCase(Message, "Load## {LoadNumber}", "<b>Load## {LoadNumber}</b>")>
				<cfset Message = replaceNoCase(Message, "Status: {LoadStatus}", "<b><u>Status:</u></b> {LoadStatus}")>
				<cfset Message = replaceNoCase(Message, "PO##: {PONumber}", "<b><u>PO##:</u></b> {PONumber}")>
				<cfset Message = replaceNoCase(Message, "{EmailSignature}", "Thank You")>
				<cfset Message = replaceNoCase(Message, "{LoadNumber}", request.qGetLoadDetails.LoadNumber)>
				<cfset Message = replaceNoCase(Message, "{PONumber}", request.qGetLoadDetails.CustomerPONo)>
				<cfset Message = replaceNoCase(Message, "{Map}", "<a href='#request.qGetLoadDetails.mapLink#' target='_blank'>VIEW LOCATION UPDATES</a>")>

				<cfset stopBody = "">
				<cfset stopNumber = 1>

				<cfloop group="StopNo">
					<cfloop group="LoadType">
						<cfif len(trim(request.qGetLoadDetails.CustName)) OR len(trim(request.qGetLoadDetails.Address)) OR len(trim(request.qGetLoadDetails.City)) OR len(trim(request.qGetLoadDetails.StateCode)) OR len(trim(request.qGetLoadDetails.PostalCode))>
							<cfset AddressString = "">
							<cfset stopBody &= "<b>Stop #stopNumber#: </b>">
							<cfif len(trim(request.qGetLoadDetails.CustName))>
								<cfset stopBody &= trim(request.qGetLoadDetails.CustName) & "<br>">
							</cfif>
							<cfif len(trim(request.qGetLoadDetails.Address))>
								<cfset stopBody &= trim(request.qGetLoadDetails.Address) & "<br>">
							</cfif>
							<cfif len(trim(request.qGetLoadDetails.City))>
								<cfset AddressString &= trim(request.qGetLoadDetails.City) & ", ">
							</cfif>
							<cfif len(trim(request.qGetLoadDetails.StateCode))>
								<cfset AddressString &= trim(request.qGetLoadDetails.StateCode) & " ">
							</cfif>
							<cfif len(trim(request.qGetLoadDetails.PostalCode))>
								<cfset AddressString &= trim(request.qGetLoadDetails.PostalCode) & " ">
							</cfif>
							<cfif len(trim(AddressString))>
								<cfset stopBody &= trim(AddressString)>
							</cfif>
							<cfif len(trim(request.qGetLoadDetails.ContactPerson))>
								<cfset stopBody &= '<br>Contact: ' & trim(request.qGetLoadDetails.ContactPerson)>
							</cfif>
							<cfif len(trim(request.qGetLoadDetails.Phone))>
								<cfset stopBody &= '<br>Phone: ' & trim(request.qGetLoadDetails.Phone)>
							</cfif>
							<cfif request.qGetLoadDetails.Currentrow NEQ request.qGetLoadDetails.recordcount>
								<cfset stopBody &= "<br><br>">
							</cfif>
							<cfset stopNumber++>
						</cfif>
					</cfloop>
				</cfloop>
				<cfif stopNumber GT 2 AND len(trim(request.qGetLoadDetails.LoadStatusStopNo)) EQ 2>
					<cfset stopTypeNo = left(trim(request.qGetLoadDetails.LoadStatusStopNo),1)>
					<cfset stopTypeText = right(trim(request.qGetLoadDetails.LoadStatusStopNo),1)>
					<cfif stopTypeText EQ 'S'>
						<cfset stopTypeText = 'Pickup'>
					<cfelse>
						<cfset stopTypeText = 'Delivery'>
					</cfif>
					<cfset Message = replaceNoCase(Message, "{LoadStatus}", request.qGetLoadDetails.StatusDescription & " " & "Stop " & stopTypeNo & " " & stopTypeText)>
				<cfelse>
					<cfset Message = replaceNoCase(Message, "{LoadStatus}", request.qGetLoadDetails.StatusDescription)>
				</cfif>
				<cfset Message = replaceNoCase(Message, "{StopDetails}", stopBody)>
				<cfif request.qGetLoadDetails.ccOnEmails EQ true and len(trim(request.qGetLoadDetails.CCMail))>
					<cfmail from='"noreply@loadmanager.com" <noreply@loadmanager.com>' subject="#Subject#" to="#MailTo#"  cc="#request.qGetLoadDetails.CCMail#" type="text/html" server="smtp.office365.com" username="noreply@loadmanager.com" password="Wsi2025!@##" port="587" usessl="0" usetls="1" >
						#Message#
					</cfmail>
				<cfelse>
					<cfmail from='"noreply@loadmanager.com" <noreply@loadmanager.com>' subject="#Subject#" to="#MailTo#" type="text/html" server="smtp.office365.com" username="noreply@loadmanager.com" password="Wsi2025!@##" port="587" usessl="0" usetls="1" >
						#Message#
					</cfmail>
				</cfif>
				<cfquery name="qUpdLoad" datasource="#variables.dsn#">
					UPDATE Loads SET 
					LastLocationUpdateStatus = <cfqueryparam value="#request.qGetLoadDetails.StatusTypeID#" cfsqltype="CF_SQL_VARCHAR"> 
					,LastLocationUpdateStopType = <cfqueryparam value="#request.qGetLoadDetails.LoadStatusStopNo#" cfsqltype="CF_SQL_VARCHAR"> 
					WHERE LoadID = <cfqueryparam value="#request.qGetLoadDetails.LoadID#" cfsqltype="CF_SQL_VARCHAR">
				</cfquery>
			</cfloop>
			<cfcatch>
				<cfset CreateLogError(cfcatch)>
			</cfcatch>
		</cftry>
	</cffunction>

	<cffunction name="CreateLogError" access="public" returntype="void">
		<cfargument name="Exception" type="any" required="true"/>
		<cfset var errordetail = "">
		<cfset var template = "">
		<cfset var sourcepage = "">
		<cfset variables.dsn = trim(listFirst(cgi.SCRIPT_NAME,'/'))>

		<cfif isDefined('arguments.Exception.cause.Detail') and isDefined('arguments.Exception.cause.Message')>
			<cfset errordetail = "#arguments.Exception.cause.Detail##arguments.Exception.cause.Message#">
		<cfelseif isDefined('arguments.Exception.Message') >
			<cfset errordetail = "#arguments.Exception.Message#">
		</cfif>

		<cfif structKeyExists(arguments.Exception, "TagContext") AND isArray(arguments.Exception.TagContext) AND NOT arrayIsEmpty(arguments.Exception.TagContext) AND isstruct(arguments.Exception.TagContext[1]) AND structKeyExists(arguments.Exception.TagContext[1], "raw_trace")>
			<cfset template = arguments.Exception.TagContext[1].raw_trace>
		</cfif>
		
		<cfif isDefined("cgi.HTTP_REFERER")>
			<cfset sourcepage = "#chr(10)#[Sourcepage]:#cgi.HTTP_REFERER#">
		</cfif>

		<cffile action="append" file="#ExpandPath("../webroot/logs")#/Application.Log.txt" output="#dateTimeFormat(now())##chr(10)##(companycode)##errordetail##chr(10)#[URLData]:#SerializeJSON(url)##chr(10)#[FormData]:#SerializeJSON(form)##chr(10)#[SessionData]:{}#trim(template)##sourcepage#">

		<cfquery name="qInsLog" datasource="LoadManagerAdmin">
   			INSERT INTO LMErrorLog (CompanyCode,Detail,Status,FormData,URLData,Template,SourcePage)
   			VALUES (
   				NULL
   				,<cfqueryparam value="#errordetail#" cfsqltype="cf_sql_varchar">
   				,'Pending'
   				<cfif isDefined("form")>
   					,<cfqueryparam value="#SerializeJSON(form)#" cfsqltype="cf_sql_varchar">
   				<cfelse>
   					,NULL
   				</cfif>
   				,<cfqueryparam value="#SerializeJSON(url)#" cfsqltype="cf_sql_varchar">
   				,<cfqueryparam value="#Template#" cfsqltype="cf_sql_varchar">
   				<cfif isDefined("cgi.HTTP_REFERER")>
   					,<cfqueryparam value="#cgi.HTTP_REFERER#" cfsqltype="cf_sql_varchar">
   				<cfelse>
   					,NULL
   				</cfif>
   				)
   		</cfquery>
	</cffunction>

	<cffunction name="sch_UnpostedRecords" access="remote" returntype="void">
		<cftry>
			<CFSTOREDPROC PROCEDURE="sch_UnpostedRecords" DATASOURCE="ZGPSTrackingMPWeb"></CFSTOREDPROC>
			<cfcatch>
				<cfset CreateLogError(cfcatch)>
			</cfcatch>
		</cftry>
	</cffunction>
</cfcomponent>