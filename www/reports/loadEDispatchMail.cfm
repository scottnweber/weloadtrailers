<cfparam name="url.loadid" default="0">
<cfparam name="MailTo" default="">
<cfparam name="MailFrom" default="">
<cfparam name="Subject" default="">
<cfparam name="body" default="">
<cfparam name="emailSignature" default="">
<cfset loadID = "">
<cfset variables.frieghtBroker = "">
<cfif  structkeyexists(url,"loadid") and len(trim(url.loadid)) gt 1>
	<cfset loadID = url.loadid>
</cfif>
<cfif structkeyexists(url,"type")>
	<cfset variables.frieghtBroker=url.type>
</cfif>
<cfinvoke component="#variables.objloadGateway#" method="getCompanyInformation" returnvariable="request.qGetCompanyInformation" />
<cfinvoke component="#variables.objloadGateway#" method="getSystemSetupOptions" returnvariable="request.qGetSystemSetupOptions" />
<cfinvoke component="#variables.objloadGateway#" method="getLoadCarriersContacts" loadid="#loadID#" returnvariable="request.qcarriers" />
<cfinvoke component="#variables.objloadGateway#" method="getcurAgentMaildetails" returnvariable="request.qcurAgentdetails" employeID="#session.empid#" />

<cfparam name="url.EDispatchOptions" default="#request.qgetSystemSetupOptions.EDispatchOptions#">

<cfset SmtpAddress=request.qcurAgentdetails.SmtpAddress>
<cfset SmtpUsername=request.qcurAgentdetails.SmtpUsername>
<cfset SmtpPort=request.qcurAgentdetails.SmtpPort>
<cfset SmtpPassword=request.qcurAgentdetails.SmtpPassword>
<cfset FA_SSL=request.qcurAgentdetails.useSSL>
<cfset FA_TLS=request.qcurAgentdetails.useTLS>
<cfset MailFrom=request.qcurAgentdetails.EmailID>
<cfset Subject = request.qGetSystemSetupOptions.EDispatchHead>
<cfset smsSign = request.qcurAgentdetails.emailSignature>
<cfset EmailValidated = request.qcurAgentdetails.EmailValidated>
<cfset emailSignature = replace(request.qcurAgentdetails.emailSignature,"Regards,","Regards,<br>")>
<cfif request.qGetSystemSetupOptions.IsIncludeLoadNumber EQ 1>
	<cfset includeLoadNumber = true>
<cfelse>
	<cfset includeLoadNumber = false>	
</cfif>
<cfif url.EDispatchOptions EQ 0>
	<cfset EDispatchType = 'Mobile App'>
<cfelseif url.EDispatchOptions EQ 1>
	<cfset EDispatchType = 'Web App'>
<cfelseif url.EDispatchOptions EQ 2>
	<cfset EDispatchType = 'Web App with MacroPoint'>
<cfelse>
	<cfset EDispatchType = 'MacroPoint'>
</cfif>
<cfif IsDefined("form.IsEmailSent")>
	<cfset IsEmailSent = form.IsEmailSent>
<cfelse>
	<cfset IsEmailSent = 0>
</cfif>
<cfif IsDefined("form.IsTextSent")>
	<cfset IsTextSent = form.IsTextSent>
<cfelse>
	<cfset IsTextSent = 0>
</cfif>
<cfif request.qcurAgentdetails.recordcount gt 0 and (request.qcurAgentdetails.SmtpAddress eq "" or request.qcurAgentdetails.SmtpUsername eq "" or request.qcurAgentdetails.SmtpPort eq "" or request.qcurAgentdetails.SmtpPassword eq "" or request.qcurAgentdetails.SmtpPort eq 0 or request.qcurAgentdetails.EmailValidated EQ 0)>
    <cfset mailsettings = 0>
<cfelse>
    <cfset mailsettings = 1>
</cfif>
<cfquery name="getDispatchStatus" datasource="#Application.dsn#">
	SELECT STATUSTYPEID AS ID,StatusDescription,IsActive FROM LoadStatusTypes WHERE CompanyID = <cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar">
	AND StatusText = '3. DISPATCHED'
</cfquery>
<cfquery name="getLoadDetails" datasource="#Application.dsn#">
	SELECT  L.LoadID
			,L.LoadNumber
			,C.CarrierName  AS DriverName
			,L.emailList
			,C.CarrierID
			,CASE WHEN (SELECT COUNT(Email) FROM CarrierContacts CC WHERE CC.CarrierID = c.CarrierID AND CC.ContactType = 'Dispatch' ) = 0 
			THEN C.EmailID ELSE
			(SELECT TOP 1 Email FROM CarrierContacts CC WHERE CC.CarrierID = c.CarrierID AND CC.ContactType = 'Dispatch' ) END AS EmailID
			,(SELECT TOP 1 NewDriverCell FROM LoadStops LS WHERE LS.LoadID = L.LoadID AND LS.stopNo = 0) AS Driver1Cell
			,(SELECT TOP 1 NewDriverCell2 FROM LoadStops LS WHERE LS.LoadID = L.LoadID  AND LS.stopNo = 0) AS Driver2Cell
			,(SELECT TOP 1 NewDriverCell3 FROM LoadStops LS WHERE LS.LoadID = L.LoadID  AND LS.stopNo = 0) AS Driver3Cell
			,(select CompanyName from Companies where CompanyID = <cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar">) as Company
			,L.STATUSTYPEID
			,(SELECT LST.statustext FROM LoadStatusTypes LST WHERE LST.STATUSTYPEID = L.STATUSTYPEID) AS statustext
			,L.CustomerID AS PayerID
			,C.Iscarrier

			,(SELECT TOP 1 CASE WHEN ISNULL(CarrierCell,'') = '' THEN C.Cel ELSE CarrierCell END FROM LoadStops LS WHERE LS.LoadID = L.LoadID  AND LS.stopNo = 0) AS Cel
	FROM Loads L
	INNER JOIN Carriers C ON C.CarrierID = L.CarrierID
	WHERE L.LoadID = <cfqueryparam value="#url.loadID#" cfsqltype="cf_sql_varchar">
</cfquery>
<cfif IsDefined("form.sendEmail")>
	<cfif mailsettings eq 0>
		<cfset IsEmailSent = 1>
		<cfset smtpError = 1>
	<cfelseif form.MailTo is not "" AND form.MailFrom is not "" AND form.Subject is not "">
		<cfset GPSDeviceID =DateFormat(Now(),"YYMMDD")&TimeFormat(Now(),"hhmmss")&getLoadDetails.LoadNumber>
		<cfset IsEDispatched = 0>
		<cfif url.EDispatchOptions EQ 0>
			<cfset IsEDispatched = 1>
		<cfelseif url.EDispatchOptions EQ 1>
			<cfset IsEDispatched = 2>
		<cfelseif url.EDispatchOptions EQ 2>
			<cfset IsEDispatched = 3>
		<cfelseif url.EDispatchOptions EQ 3>
			<cfset IsEDispatched = 4>
		</cfif>
		<cfquery name="selectLoadDetails" datasource="#Application.dsn#">
			SELECT GPSDeviceID from Loads WHERE LoadID = <cfqueryparam value="#url.loadID#" cfsqltype="cf_sql_varchar"> 
		</cfquery>
		
		<cfif selectLoadDetails.GPSDeviceID EQ 0 OR NOT len(selectLoadDetails.GPSDeviceID) >
			<cfquery name="updateLoadDetails" datasource="#Application.dsn#">
				UPDATE Loads SET 
					GPSDeviceID = <cfqueryparam value="#GPSDeviceID#" cfsqltype="cf_sql_varchar"> 
					WHERE LoadID = <cfqueryparam value="#url.loadID#" cfsqltype="cf_sql_varchar"> 
			</cfquery>
		</cfif>
		<cfquery name="updLoad" datasource="#Application.dsn#">
			UPDATE Loads SET 
				IsEDispatched = <cfqueryparam value="#IsEDispatched#" cfsqltype="cf_sql_integer"> 
				WHERE LoadID = <cfqueryparam value="#url.loadID#" cfsqltype="cf_sql_varchar"> 
		</cfquery>
		<cfmail from='"#SmtpUsername#" <#MailFrom#>' subject="#form.Subject#" to="#form.MailTo#"  CC="#request.qGetCompanyInformation.email#" type="text/html" server="#SmtpAddress#" username="#SmtpUsername#" password="#SmtpPassword#" port="#SmtpPort#" usessl="#FA_SSL#" usetls="#FA_TLS#" >
			#form.body#
		</cfmail>
		<cfset IsEmailSent = 1>
		<cfinvoke component="#variables.objloadGateway#" method="createEDispatchLog" type="#EDispatchType#" user="#session.adminusername#" loadnumber="#getLoadDetails.LoadNumber#" driverphone="#getLoadDetails.Driver1Cell#" carrieremail="#getLoadDetails.EmailID#" customerid="#getLoadDetails.PayerID#" carrierid="#getLoadDetails.CarrierID#" loadid="#getLoadDetails.LoadID#" body="#form.body#" returnvariable="logRes"/>
	<cfelse>
		<cfoutput>
		<cfsavecontent variable="content">
			<div id="message" class="msg-area" style="width: 100%;display:block;background: none repeat scroll 0 0 ##f4cbc8;border: 1px solid ##f2867a;"><p>Please provide details like 'From', 'To' and 'Subject'.</p></div>
		</cfsavecontent>
		</cfoutput>
	</cfif>	
</cfif>


<cfif IsDefined("form.sendText")>
	<cfif form.MailTo is not "">				
		<cfoutput>
			<cftry>
				<!--- Character limit--->
				<cfif request.qGetSystemSetupOptions.TextAPI EQ 2>
					<cfthrow message="The texting feature is turned off. Please turn it on and try again.">
				</cfif>
				<cfloop list="#form.MailTo#" index="cellNo">
				    <cfif len(ReReplaceNoCase(cellNo,"[^0-9]","","ALL")) NEQ 10>
						<cfthrow message="Invalid phone number #cellNo#.">
					</cfif>
				</cfloop>

				<cfif Len(form.body) GT 470>
					<cfthrow message="Number of characters in the Text is greater than 470. Only texts with less number of characters can be send. Please reduce the number of characters to 470 or less.">
				</cfif>

				<cfset temp = ListToArray(form.MailTo,",;", false, false)>
				<cfloop array="#temp#" index="number">
					<cfset number = Replace(number, " ", "", "all")>
					<cfif REFIND("^(?:(?:\+?1\s*(?:[.-]\s*)?)?(?:\(\s*([2-9]1[02-9]|[2-9][02-8]1|[2-9][02-8][02-9])\s*\)|([2-9]1[02-9]|[2-9][02-8]1|[2-9][02-8][02-9]))\s*(?:[.-]\s*)?)?([2-9]1[02-9]|[2-9][02-9]1|[2-9][02-9]{2})\s*(?:[.-]\s*)?([0-9]{4})(?:\s*(?:##|x\.?|ext\.?|extension)\s*(\d+))?$",number) >
						<cfset number = Replace(number, "-", "", "all")>
						<cfset number = Replace(number, "(", "", "all")>
						<cfset number = Replace(number, ")", "", "all")>
						<cfset fromNumber = "">
						
						<cfif request.qGetSystemSetupOptions.TextAPI EQ 0>
							<cfset fromNumber = "Trumpia Texting API">
							<!--- REST API --->
							<cfset restBody = {"country_code" = 1, "mobile_number" = "#number#", "message" = {"text" = "#form.body#"}}>
							<cfhttp result="textResult" method="PUT" url="http://api.trumpia.com/rest/v1/LoadManager1/mobilemessage">
								<cfhttpparam name="Content-Type" type="header" value="application/json">
								<cfhttpparam name="X-Apikey" type="header" value="f0c5ace485736aaab2a31d7f9f2e783c">

								<cfhttpparam type="body" value="#serializeJSON(restBody)#">
							</cfhttp>
							<cfset fileContent = deserializeJSON(textResult.Filecontent)>


							<cfhttp result="textResult1" method="GET" charset="utf-8" url="http://api.trumpia.com/rest/v1/LoadManager1/report/#fileContent.request_id#">						    
								<cfhttpparam name="Content-Type" type="header" value="application/json">
								<cfhttpparam name="X-Apikey" type="header" value="f0c5ace485736aaab2a31d7f9f2e783c">
							</cfhttp>
						
						<cfelseif request.qGetSystemSetupOptions.TextAPI EQ 1>
							<cfset fromNumber = "Plivo Texting API - 18665243748">
							
							<cfset restBody = {"src" = "18665243748", "dst" = 1&"#number#", "text" = "#form.body#"}>
							<cfhttp result="textresult1" method="POST" charset="utf-8" url="https://api.plivo.com/v1/Account/MAODG4YMVMN2FHZMQWYJ/Message/" username="MAODG4YMVMN2FHZMQWYJ" password="NzMyNjM2N2EyZDQzNjJiMjRjNTM2ZjhlNTBmNzhk">
								<cfhttpparam name="Content-Type" type="header" value="application/json">
								<cfhttpparam type="body" value="#serializeJSON(restBody)#">							
							</cfhttp>

						</cfif>
						<cfset fileContent = deserializeJSON(textResult1.Filecontent)>

						<cfif IsDefined("fileContent.status_code") AND fileContent.status_code EQ "MRCE4001" OR IsDefined("fileContent.status") AND fileContent.status EQ "sent"  OR IsDefined("fileContent.message") AND fileContent.message EQ "message(s) queued">
							<cfset IsTextSent = 1>
							<cfinvoke component="#variables.objloadGateway#" method="setLogTexts" loadID="#loadID#" date="#Now()#" textBody="#form.body#" reportType="carrier" fromNumber="#fromNumber#" toNumber="#number#" textAPIID="#request.qGetSystemSetupOptions.TextAPI#" />
						<cfelseif request.qGetSystemSetupOptions.TextAPI EQ 0>
							<cfthrow message="There is a problem with text sending. Please contact the technical team with this info: RequestID: #fileContent.request_id#, Phone number: #number#, API status:#fileContent.status_code#">
						<cfelseif request.qGetSystemSetupOptions.TextAPI EQ 1>
							<cfthrow message="There is a problem with text sending. Please contact the technical team with this info: APIID: #fileContent.api_id#, Phone number: #number#, API error:#fileContent.error#">
						</cfif>							
						
						<!--- Send E-Dispatch Text Instructions--->
						<cfif url.EDispatchOptions EQ 1 AND  len(trim(request.qGetSystemSetupOptions.EDispatchTextInstructions))>
						
							<cfif request.qGetSystemSetupOptions.TextAPI EQ 0>
								<cfset fromNumber = "Trumpia Texting API">
								<!--- REST API --->
								<cfset restBody = {"country_code" = 1, "mobile_number" = "#number#", "message" = {"text" = "#request.qGetSystemSetupOptions.EDispatchTextInstructions#"}}>
								<cfhttp result="textResult" method="PUT" url="http://api.trumpia.com/rest/v1/LoadManager1/mobilemessage">
									<cfhttpparam name="Content-Type" type="header" value="application/json">
									<cfhttpparam name="X-Apikey" type="header" value="f0c5ace485736aaab2a31d7f9f2e783c">

									<cfhttpparam type="body" value="#serializeJSON(restBody)#">
								</cfhttp>
								<cfset fileContent = deserializeJSON(textResult.Filecontent)>


								<cfhttp result="textResult1" method="GET" charset="utf-8" url="http://api.trumpia.com/rest/v1/LoadManager1/report/#fileContent.request_id#">						    
									<cfhttpparam name="Content-Type" type="header" value="application/json">
									<cfhttpparam name="X-Apikey" type="header" value="f0c5ace485736aaab2a31d7f9f2e783c">
								</cfhttp>

							
							<cfelseif request.qGetSystemSetupOptions.TextAPI EQ 1>
								<cfset fromNumber = "Plivo Texting API - 18665243748">
								
								<cfset restBody = {"src" = "18665243748", "dst" = 1&"#number#", "text" = "#request.qGetSystemSetupOptions.EDispatchTextInstructions#"}>
								<cfhttp result="textresult1" method="POST" charset="utf-8" url="https://api.plivo.com/v1/Account/MAODG4YMVMN2FHZMQWYJ/Message/" username="MAODG4YMVMN2FHZMQWYJ" password="NzMyNjM2N2EyZDQzNjJiMjRjNTM2ZjhlNTBmNzhk">
									<cfhttpparam name="Content-Type" type="header" value="application/json">
									<cfhttpparam type="body" value="#serializeJSON(restBody)#">							
								</cfhttp>

							</cfif>
							<cfset fileContent = deserializeJSON(textResult1.Filecontent)>

							<cfif IsDefined("fileContent.status_code") AND fileContent.status_code EQ "MRCE4001" OR IsDefined("fileContent.status") AND fileContent.status EQ "sent"  OR IsDefined("fileContent.message") AND fileContent.message EQ "message(s) queued">
								<cfset IsTextSent = 1>
								<cfinvoke component="#variables.objloadGateway#" method="setLogTexts" loadID="#loadID#" date="#Now()#" textBody="#request.qGetSystemSetupOptions.EDispatchTextInstructions#" reportType="carrier" fromNumber="#fromNumber#" toNumber="#number#" textAPIID="#request.qGetSystemSetupOptions.TextAPI#" />
							<cfelseif request.qGetSystemSetupOptions.TextAPI EQ 0>
								<cfthrow message="There is a problem with text sending. Please contact the technical team with this info: RequestID: #fileContent.request_id#, Phone number: #number#, API status:#fileContent.status_code#">
							<cfelseif request.qGetSystemSetupOptions.TextAPI EQ 1>
								<cfthrow message="There is a problem with text sending. Please contact the technical team with this info: APIID: #fileContent.api_id#, Phone number: #number#, API error:#fileContent.error#">
							</cfif>
						</cfif>
					</cfif>							
					
				</cfloop>
				
				<cfsavecontent variable="content">
					<cfif IsDefined("fromNumber") AND Len(fromNumber)>
						<div id="message" class="msg-area" style="width: 100%;display:block;"><p>Thank you, <cfoutput>#MailFrom#: your message has been sent</cfoutput>.</p></div>
					<cfelse>
						<div id="message" class="msg-area" style="width: 100%;display:block;"><p>None of the numbers entered is a valid phone number.</p></div>
					</cfif>
				</cfsavecontent>	
				<script>
					function clock(){
						var currentDate = new Date();
				        var currentDay = currentDate.getDate();
				        var currentMonth = currentDate.getMonth() + 1;
				        var currentYear = currentDate.getFullYear();
				        var hours = currentDate.getHours();
				        var minutes = currentDate.getMinutes();

				        var currentDate = currentMonth + "/" + currentDay + "/" + currentYear;
				        var ampm = hours >= 12 ? 'PM' : 'AM';
				        hours = hours % 12;
				        hours = hours ? hours : 12; // the hour '0' should be '12'
				        minutes = minutes < 10 ? '0'+minutes : minutes;
				        var strTime = hours + ':' + minutes + ' ' + ampm;
				        var FinalTime = currentDate+' '+strTime;
						return FinalTime
					}				
				</script>
				<cfif request.qGetSystemSetupOptions.AutomaticEmailReports EQ 1>
					<cfinvoke component="#variables.objloadGateway#" method="updateDispatchNotes" loadID="#loadID#"  Notes="#DateTimeFormat(now(),'mm/dd/yyyy hh:mm tt')# - #session.UserFullName# > Texted #variables.frieghtBroker# Report " />
				</cfif>		
				<cfinvoke component="#variables.objloadGateway#" method="createEDispatchLog" type="#EDispatchType#" user="#session.adminusername#" loadnumber="#getLoadDetails.LoadNumber#" driverphone="#getLoadDetails.Driver1Cell#" carrieremail="#getLoadDetails.EmailID#" customerid="#getLoadDetails.PayerID#" carrierid="#getLoadDetails.CarrierID#" loadid="#getLoadDetails.LoadID#" returnvariable="logRes"/>

				<cfset GPSDeviceID =DateFormat(Now(),"YYMMDD")&TimeFormat(Now(),"hhmmss")&getLoadDetails.LoadNumber>
				<cfset IsEDispatched = 0>
				<cfif url.EDispatchOptions EQ 0>
					<cfset IsEDispatched = 1>
				<cfelseif url.EDispatchOptions EQ 1>
					<cfset IsEDispatched = 2>
				<cfelseif url.EDispatchOptions EQ 2>
					<cfset IsEDispatched = 3>
				<cfelseif url.EDispatchOptions EQ 3>
					<cfset IsEDispatched = 4>
				</cfif>
				<cfquery name="selectLoadDetails" datasource="#Application.dsn#">
					SELECT GPSDeviceID from Loads WHERE LoadID = <cfqueryparam value="#url.loadID#" cfsqltype="cf_sql_varchar"> 
				</cfquery>

				<cfif selectLoadDetails.GPSDeviceID EQ 0 OR NOT len(selectLoadDetails.GPSDeviceID) >
					<cfquery name="updateLoadDetails" datasource="#Application.dsn#">
						UPDATE Loads SET 
							GPSDeviceID = <cfqueryparam value="#GPSDeviceID#" cfsqltype="cf_sql_varchar">  
							WHERE LoadID = <cfqueryparam value="#url.loadID#" cfsqltype="cf_sql_varchar"> 
					</cfquery>
				</cfif>
				<cfquery name="updLoad" datasource="#Application.dsn#">
					UPDATE Loads SET 
						IsEDispatched = <cfqueryparam value="#IsEDispatched#" cfsqltype="cf_sql_integer"> 
						WHERE LoadID = <cfqueryparam value="#url.loadID#" cfsqltype="cf_sql_varchar"> 
				</cfquery>

				<cfif url.EDispatchOptions EQ 0>
					<cfquery name="updLoadStop" datasource="#Application.dsn#">
						UPDATE LoadStops SET 
							NewDriverCell = <cfqueryparam value="#form.MailTo#" cfsqltype="cf_sql_varchar"> 
							WHERE LoadID = <cfqueryparam value="#url.loadID#" cfsqltype="cf_sql_varchar">
							AND StopNo = 0 
					</cfquery>
					<cfset refreshParent = 1>
				</cfif>
				<cfcatch>
					<cfsavecontent variable="content">
						<div id="message" class="msg-area" style="width: 100%;display:block;background: none repeat scroll 0 0 ##f4cbc8;border: 1px solid ##f2867a;"><p>The text is not sent.#cfcatch.message#</p>
						</div>
					</cfsavecontent>
				</cfcatch>
			</cftry>
		</cfoutput>
	<cfelse>
		<cfoutput>
		<cfsavecontent variable="content">
			<div id="message" class="msg-area" style="width: 100%;display:block;background: none repeat scroll 0 0 ##f4cbc8;border: 1px solid ##f2867a;"><p>Please provide details like 'To'.</p></div>
		</cfsavecontent>
		</cfoutput>
	</cfif>
	<cfif url.EDispatchOptions EQ 0>
		<cfinvoke component="#variables.objloadGateway#" method="sendPushNotification" Driver1Cell="#replaceNoCase(getLoadDetails.Driver1Cell, "-", "","ALL")#" Driver2Cell="#replaceNoCase(getLoadDetails.Driver2Cell, "-", "","ALL")#" Driver3Cell="#replaceNoCase(getLoadDetails.Driver3Cell, "-", "","ALL")#" returnvariable="respB">
	</cfif>
</cfif>


<cfset textBody ="">
<cfset bitlink="">
<cfset toMailList = ''>
<cfset textTo = ''>
<cfif listLen(getLoadDetails.EmailID)>
	<cfset toMailList = listappend(toMailList, getLoadDetails.EmailID)>
</cfif>
<cfif listLen(getLoadDetails.emailList)>
	<cfset toMailList = listappend(toMailList, getLoadDetails.emailList)>
</cfif>

<cfif getLoadDetails.Iscarrier EQ 1>
	<cfif Len(getLoadDetails.Driver1Cell)>
		<cfset textTo = listappend(textTo, getLoadDetails.Driver1Cell)>
	</cfif>
	<cfif Len(getLoadDetails.Driver2Cell)>
		<cfset textTo = listappend(textTo, getLoadDetails.Driver2Cell)>
	</cfif>
<cfelse>
	<cfif Len(getLoadDetails.Cel)>
		<cfset textTo = listappend(textTo, getLoadDetails.Cel)>
	</cfif>
</cfif>
<cfif url.EDispatchOptions EQ 0>
	<cfset DeepLink = "https://webersysteminc.page.link/tobR">
<cfelseif listFind("1,2", url.EDispatchOptions)>
	<cfset DeepLink = "https://loadmanager.biz/#Application.dsn#/mobile/index.cfm?event=login&CompanyID=#session.CompanyID#&LoadID=#url.loadID#">
</cfif>
<cfif url.EDispatchOptions NEQ 3>
	<cfhttp url="https://api-ssl.bitly.com/v3/shorten?access_token=ae8e15036ca35de1efd54a2c05b62853e605df67" method="get" result="resultUrl">
		<cfhttpparam type="url" name="longurl" value="#DeepLink#">
	</cfhttp>
	<cftry>
		<cfset bitlink=deserializeJSON(resultUrl.filecontent).data.url>
		<cfcatch>
			<cfdocument format="pdf" filename="C:\pdf\Debug_bitly_#DateTimeFormat(now(),"YYYY_MM_dd_HH_nn_ss_l")#.pdf" overwrite="true">
			    <cfdump var="#resultUrl#">
			</cfdocument>
			<cfset bitlink=DeepLink>
		</cfcatch>
	</cftry>
</cfif>

<cfoutput>
	<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
	<html>
	<head>
		<title>Load Manager TMS</title>
		<meta http-equiv="X-UA-Compatible" content="IE=edge" />
		<meta http-equiv="X-UA-Compatible" content="IE=8" >
		<link rel="stylesheet" type="text/css" href="styles/jquery.autocomplete.css" />
<link rel="stylesheet" href="https://code.jquery.com/ui/1.11.0/themes/smoothness/jquery-ui.css">
<script src="https://code.jquery.com/jquery-1.10.2.min.js"></script>
<script src="https://code.jquery.com/ui/1.11.0/jquery-ui.min.js"></script>

		<script language="javascript" type="text/javascript" src="../webroot/javascripts/plugins/ckeditor/ckeditor.js?ver=4.16.0"></script>	
		<link href="../webroot/styles/style.css" rel="stylesheet" type="text/css" />
		<style>
			.progress { position:relative; width:400px; border: 1px solid ##ddd; padding: 1px; border-radius: 3px; }
			.bar { background-image:url("../webroot/images/pbar-ani.gif"); width:0%; height:20px; border-radius: 3px; }
			.percent { position:absolute; display:inline-block; top:3px; left:48%; }
			
			input.alertbox{
				border-color:##dd0000;
			}
			ul.tabs{
				margin: 0;
				padding: 0px;
				list-style: none;
			}
			ul.tabs li{
				background: none;
				color: ##222;
				display: inline-block;
				padding: 10px 15px;
				cursor: pointer;
				font-weight: bold;
				font-size: 12px;
			}
			ul.tabs li.current{
				background: ##ededed;
				color: ##222;
			}
			.tab-content{
				display: none;
				background: ##ededed;
				padding: 15px;
			}
			.tab-content.current{
				display: inherit;
			}
			##cke_tbody{
				width:500px;
				float: left;
			}
			##cke_1_bottom {
				display: none;
			}
			##cke_1_top {
				display: none;
			}
			##cke_1_contents{
				height: 250px !important;
			}
		</style>
		<script type="text/javascript">
			<cfif isdefined('smtpError')>
				$(document).ready(function(){
					alert('The email was not sent, please check your email settings.');
					<cfif request.qGetSystemSetupOptions.TextAPI EQ 2>
						window.close();
					</cfif>
				})
			<cfelse>
				<cfif NOT IsTextSent AND IsEmailSent>
					$(document).ready(function(){
						alert('Your Mail has been sent.')
					})
					window.close();
				<cfelseif IsTextSent AND NOT IsEmailSent> 
					$(document).ready(function(){
						alert('Your Message has been sent.')
					})
					window.close();
					<cfif IsDefined('refreshParent')>
						window.opener.location.reload(true);
					</cfif>
				<cfelseif IsTextSent AND IsEmailSent>
					$(document).ready(function(){
						<cfif IsDefined("form.sendEmail")>
							alert('Your Mail has been sent.')
						</cfif>
						<cfif IsDefined("form.sendText")>
							alert('Your Message has been sent.')
						</cfif>
						window.close();
					})
				</cfif>
			</cfif>
		</script>
	</head>
	<body>
		<cfif isDefined('content')>
			#content#
		</cfif>
		<p>
			<div class="white-mid" style="width: 100%;">
				<h1 style="color:white;font-weight:bold;background-color: ##82bbef;padding-left: 10px;height: 15px;" id="HeaderLoadNumber">
					<div style="float: left;">
						<cfif url.EDispatchOptions EQ 0>Mobile App #url.carrierDispatch#<cfelseif url.EDispatchOptions EQ 1>Web App #url.carrierDispatch#<cfelseif url.EDispatchOptions EQ 2>MP-Dispatch<cfelse>MP-GPS</cfif>
					</div>
					<cfif listFind("0,1", url.EDispatchOptions)>
						<div style="float: left;background-color: ##fff;border: solid 1px;padding: 5px;width: 300px;color: ##000;font-weight: normal;font-size: 11px;margin-left: 50px;margin-top: -8px;">
							<div style="float: left;">
								<b>Mobile Type:</b>
							</div>
							<div style="float: left;margin-left: 15px;">
								<input type="radio" name="radMobApp" value="0" id="mobApp" <cfif url.EDispatchOptions EQ 0> checked </cfif>
								onclick="selectMobileApp()">
							</div>
							<div style="float: left;margin-left: 5px;">
								Mobile App
							</div>
							<div style="float: left;margin-left: 15px;">
								<input type="radio" name="radMobApp" id="webApp" value="1" <cfif url.EDispatchOptions EQ 1> checked </cfif> onclick="document.location.href='index.cfm?event=loadMail&type=#url.type#&loadid=#loadID#&EDispatchOptions=1&#session.URLToken#&carrierDispatch=#url.carrierDispatch#'">
							</div>
							<div style="float: left;margin-left: 5px;">
								Web App
							</div>
						</div>
					</cfif>
				</h1>
				<div class="clear"></div>
				<div class="form-con" style="width:auto;">	
					<ul class="tabs" <cfif url.EDispatchOptions EQ 0>style="width: 175px;float: left;"</cfif>>

						<cfif mailsettings eq 1 AND url.EDispatchOptions NEQ 0>
							<li class="tab-link <cfif (NOT IsDefined("form.sendText") AND NOT IsDefined("form.sendEmail")) OR IsTextSent> current</cfif>" data-tab="tab-1">Email <cfif listFind("0,1", url.EDispatchOptions)>Mobile #url.carrierDispatch#<cfelseif url.EDispatchOptions EQ 2>MP-Dispatch<cfelse>MP-GPS</cfif></li>
						</cfif>

						<cfif NOT IsTextSent><li class="tab-link <cfif IsEmailSent OR IsDefined("form.sendText") OR mailsettings eq 0 OR  url.EDispatchOptions EQ 0> current </cfif>" data-tab="tab-2">Text <cfif listFind("0,1", url.EDispatchOptions)>Mobile #url.carrierDispatch#<cfelseif url.EDispatchOptions EQ 2>MP-Dispatch<cfelse>MP-GPS</cfif></li></cfif>
					</ul>
					<cfif url.EDispatchOptions EQ 0>
						<cfset ckMob = "">
						<cfif getLoadDetails.Iscarrier EQ 1>
							<cfif len(trim(getLoadDetails.Driver1Cell))>
								<cfset ckMob = "driver1">
							<cfelseif len(trim(getLoadDetails.Cel))>
								<cfset ckMob = "main">
							</cfif>
						<cfelse>
							<cfif len(trim(getLoadDetails.Cel))>
								<cfset ckMob = "main">
							<cfelseif len(trim(getLoadDetails.Driver1Cell))>
								<cfset ckMob = "driver1">
							</cfif>
						</cfif>

						<div style="border:ridge 1px;width: 547px;height: 30px;float: left;padding-left: 5px;">
							<div style="float: left;float: left;margin-top: 7px;">
								<b>Change Recipient</b>
							</div>

							<div style="float: left;<cfif getLoadDetails.Iscarrier EQ 1>padding-top: 7px;</cfif>margin-left: 15px;">
								<input type="radio" name="radMob" value="<cfif len(trim(getLoadDetails.Cel))>#getLoadDetails.Cel#</cfif>" <cfif ckMob EQ "main"> checked </cfif> onclick="defaultMobileNumber()">
							</div>
							<div style="float: left;<cfif getLoadDetails.Iscarrier EQ 1>padding-top: 6px;</cfif>margin-left: 5px;">
								<u>MAIN</u>: <cfif len(trim(getLoadDetails.Cel))>#getLoadDetails.Cel#<cfelse>(NONE)</cfif>
							</div>
							
							<div style="float: left;<cfif getLoadDetails.Iscarrier EQ 1>padding-top: 7px;</cfif>margin-left: 15px;">
								<input type="radio" name="radMob" value="<cfif len(trim(getLoadDetails.Driver1Cell))>#getLoadDetails.Driver1Cell#</cfif>" <cfif ckMob EQ "driver1"> checked </cfif> onclick="defaultMobileNumber()">
							</div>
							<div style="float: left;<cfif getLoadDetails.Iscarrier EQ 1>padding-top: 6px;</cfif>margin-left: 5px;">
								<u>DRIVER 1</u>: <cfif len(trim(getLoadDetails.Driver1Cell))>#getLoadDetails.Driver1Cell#<cfelse>(NONE)</cfif>
							</div>
							
							<div style="float: left;<cfif getLoadDetails.Iscarrier EQ 1>padding-top: 7px;</cfif>margin-left: 15px;">
								<input type="radio" name="radMob" value="<cfif len(trim(getLoadDetails.Driver2Cell))>#getLoadDetails.Driver2Cell#</cfif>" onclick="defaultMobileNumber()">
							</div>
							<div style="float: left;<cfif getLoadDetails.Iscarrier EQ 1>padding-top: 6px;</cfif>margin-left: 5px;">
								<u>DRIVER 2</u>: <cfif len(trim(getLoadDetails.Driver2Cell))>#getLoadDetails.Driver2Cell#<cfelse>(NONE)</cfif>
							</div>
							
							<cfif getLoadDetails.Iscarrier NEQ 1>
								<div style="float: left;<cfif getLoadDetails.Iscarrier EQ 1>padding-top: 7px;</cfif>margin-left: 15px;">
									<input type="radio" name="radMob" value="<cfif len(trim(getLoadDetails.Driver3Cell))>#getLoadDetails.Driver3Cell#</cfif>" onclick="defaultMobileNumber()">
								</div>
								<div style="float: left;margin-left: 5px;">
									<u>DRIVER 3</u>: <cfif len(trim(getLoadDetails.Driver3Cell))>#getLoadDetails.Driver3Cell#<cfelse>(NONE)</cfif>
								</div>
							</cfif>
						</div>
					</cfif>
					<div class="clear"></div>	
					<cfif mailsettings eq 1 AND url.EDispatchOptions NEQ 0>		
						<div id="tab-1" class="tab-content <cfif (NOT IsDefined("form.sendText") AND NOT IsDefined("form.sendEmail")) OR IsTextSent> current</cfif>">
							<form action = "index.cfm?event=loadMail&type=#url.type#&loadid=#loadID#&#session.URLToken#&carrierDispatch=#url.carrierDispatch#&EDispatchOptions=#url.EDispatchOptions#" method="POST" style="margin-top: 10px;">
								<fieldset>
									<label style="margin-top: 3px;">To:</label>
									<input style="width:500px;" type="Text" name="MailTo" class="mid-textbox-1 CarrEmail" id="MailTo" value="#toMailList#">
									<div class="clear"></div>
									<label style="margin-top: 3px;">From:</label>
									<input style="width:500px;" type="Text" name="MailFrom" class="mid-textbox-1 disabledLoadInputs" id="MailFrom" value="#MailFrom#" readonly>
									<div class="clear"></div>

									<label style="margin-top: 3px;">Subject:</label>
									<input style="width:500px;" type="Text" name="Subject" class="mid-textbox-1" id="Subject" value="<cfif len(trim(Subject))>#Subject#<cfelse>Load Manager</cfif><cfif includeLoadNumber> - ###getLoadDetails.loadNumber#</cfif>">
									<div class="clear"></div>

									<label style="margin-top: 3px;">Message:</label>
									<textarea style="width:500px;height:180px;" class="addressChange" rows="" name="body" id="tbody" cols=""><cfif not IsDefined("form.sendEmail")>Hi #getLoadDetails.DriverName#,<br><br><cfif url.EDispatchOptions NEQ 3>The load ###getLoadDetails.loadNumber# has been dispatched to you from #getLoadDetails.Company#.<br><cfif len(trim(request.qgetSystemSetupOptions.EDispatchMailText))>#request.qgetSystemSetupOptions.EDispatchMailText#<br><br></cfif><a href="#DeepLink#">Click here: Load ###getLoadDetails.loadNumber#</a><cfelse>We just sent you a text from MacroPoint for tracking this load. If you need any help please call dispatch.</cfif><br><br>#emailSignature#<cfelse>#form.body#</cfif>
									</textarea>
									<div class="clear"></div>
									<div style="width:auto;float: right;">
										<input type = "hidden" name = "IsTextSent" value="#IsTextSent#">
										<input type = "hidden" name = "IsEmailSent" value="#IsEmailSent#">
										<input type = "Submit" name = "sendEmail" value="Send" onclick="updateLoadStatusDispatched()">
									</div>
								</fieldset>
							</form> 
						</div>
					</cfif>
					<cfif NOT IsTextSent OR  url.EDispatchOptions EQ 0>
						<div id="tab-2" class="tab-content <cfif IsEmailSent OR IsDefined("form.sendText") OR mailsettings eq 0 OR  url.EDispatchOptions EQ 0> current</cfif>" <cfif url.EDispatchOptions EQ 0>style="width: 700px;"</cfif>><p style="font-weight: normal;">Use comma to seperate multiple numbers</p>
							 <form action = "index.cfm?event=loadMail&type=#url.type#&loadid=#loadID#&#session.URLToken#&carrierDispatch=#url.carrierDispatch#&EDispatchOptions=#url.EDispatchOptions#" method="POST" style="margin-top: 10px;">
								<fieldset>
									<label style="margin-top: 3px;">To:</label>
									<input style="width:500px;" type="Text" name="MailTo" class="mid-textbox-1 driverno" id="MailTo" value="<cfif not IsDefined("form.sendText")>#TextTo#<cfelse>#form.MailTo#</cfif>" onchange="ParseUSNumber(this,'Phone');">
									<div class="clear"></div>							
									<label style="margin-top: 3px;">Message:</label>
									<textarea style="width:500px;height:180px;" class="addressChange" rows="" name="body" id="body" cols="" onkeyup="javascript:countCharacters()"><cfif not IsDefined("form.sendText")>Hi #getLoadDetails.DriverName#,&##13;&##10;<cfif url.EDispatchOptions NEQ 3>The Load ###getLoadDetails.loadNumber# has been dispatched to you from #getLoadDetails.Company#.&##13;&##10;<cfif len(trim(request.qgetSystemSetupOptions.EDispatchTextMessage))>#request.qgetSystemSetupOptions.EDispatchTextMessage#&##13;&##10;</cfif><cfif url.EDispatchOptions EQ 0>The dispatch information is available from the Load Manager mobile app. To download the mobile app click here.<cfelse>Click link below</cfif>&##13;&##10;#bitlink#<cfelse>We just sent you a text from MacroPoint for tracking this load. If you need any help please call dispatch.</cfif>&##13;&##10;#smsSign#<cfelse>#form.body#</cfif></textarea>
									<div class="clear"></div>
									<div>
										<div style="float: left;">
											<label style="">&nbsp;</label>Character Count: <span id="charcount"></span>/470
										</div>
										<div style="width:auto;float: right;">
											<input type = "hidden" name = "IsTextSent" value="#IsTextSent#">
											<input type = "hidden" name = "IsEmailSent" value="#IsEmailSent#">
											<input type = "Submit" name = "sendText" value="Send" onclick="updateLoadStatusDispatched()">
										</div>							  
									</div>							
								</fieldset>
							</form> 
						</div>			
					</cfif>
				</div>
			</div>
			<div class="white-mid" style="width:auto;">
				<div class="form-con" style="bottom: 0px; position: absolute; background-color: rgb(130, 187, 239); width: 100%; padding: 2px 5px;">	
				</div>
			</div>
		</p> 
		<div class="clear"></div>	
	</body>  
	<script type="text/javascript">
		$(document).ready(function(){
			
			$('.CarrEmail').each(function(i, tag) {

		        $(tag).autocomplete({
		            multiple: false,
		            width: 450,
		            scroll: true,
		            scrollHeight: 300,
		            cacheLength: 1,
		            highlight: false,
		            dataType: "json",
		            minLength:0,
		            source: 'searchCarrierContactAutoFill.cfm?loadID=#url.loadid#',
		            select: function(e, ui) { },
		        }).focus(function() { 
		        	$(this).keydown();
		        })
		        $(tag).data("ui-autocomplete")._renderItem = function(ul, item) {
		            return $( "<li><b><u>Email</u>:</b> "+item.email+"<br/><b><u>Contact</u>:</b> "+ item.ContactPerson+"&nbsp;&nbsp;&nbsp;<b><u>Phone</u>:</b> "+ item.phoneno+"<br/><b><u>cell</u>:</b> " + item.PersonMobileNo+"&nbsp;&nbsp;&nbsp;<b><u>Type</u>:</b> " + item.ContactType+"</li>" )
                    .appendTo( ul );
		        }
		    })

			$('ul.tabs li').click(function(){
				var tab_id = $(this).attr('data-tab');

				$('ul.tabs li').removeClass('current');
				$('.tab-content').removeClass('current');

				$(this).addClass('current');
				$("##"+tab_id).addClass('current');
			})
			<cfif NOT IsTextSent>
				countCharacters();
			</cfif>
			CKEDITOR.replace('tbody', {});

			<cfif url.EDispatchOptions EQ 0>
				defaultMobileNumber();
			</cfif>

			 $('.form-popup-close').click(function(){
                $('body').removeClass('formpopup-body-noscroll');
                $(this).closest( ".form-popup" ).hide();
                $('.formpopup-overlay').hide();
            });

			var carrID = '#getLoadDetails.CarrierID#';
            $(".driverno").each(function(i, tag) {
                $(tag).autocomplete({
                    multiple: false,
                    width: 450,
                    scroll: true,
                    scrollHeight: 300,
                    cacheLength: 1,
                    highlight: false,
                    dataType: "json",
                    minLength:0,
                    source: 'searchCarrierContactAutoFill.cfm?carrierID='+carrID+'&type=contact&contactType=Driver',
                    select: function(e, ui) { 
                        if($.trim(ui.item.phoneno).length){
                           $(this).val(ui.item.phoneno); 
                        }
                        if($.trim(ui.item.PersonMobileNo).length){
                           $(this).val(ui.item.PersonMobileNo); 
                        }
                        else if($.trim(ui.item.phoneno).length){
                           $(this).val(ui.item.phoneno); 
                        }
                        return false;
                    },
                    focus: function( event, ui ) {
                        if($.trim(ui.item.PersonMobileNo).length){
                           $(this).val(ui.item.PersonMobileNo); 
                        }
                        else if($.trim(ui.item.phoneno).length){
                           $(this).val(ui.item.phoneno); 
                        }
                        return false;
                    },
                }).focus(function() { 
                    $(this).autocomplete('search', $(this).val());
                })
                $(tag).data("ui-autocomplete")._renderItem = function(ul, item) {
                    return $( "<li><b><u>Contact</u>:</b> "+ item.ContactPerson+"&nbsp;&nbsp;&nbsp;<b><u>Phone</u>:</b> "+ item.phoneno+"<br/><b><u>cell</u>:</b>" + item.PersonMobileNo+"&nbsp;&nbsp;&nbsp;<b><u>Type</u>:</b> " + item.ContactType+"<b><br/><u>Email</u>:</b>"+item.email+"</li>" )
                .appendTo( ul );
                }
            })
		});

		function ParseUSNumber(frmfld,fldName) {
			var phoneText = $(frmfld).val().replace(/\D/g,'');

			phoneText = phoneText.toString().replace(/,/g, "");
			phoneText = phoneText.replace(/-/g, "");
			phoneText = phoneText.replace(/\(/g, "");
			phoneText = phoneText.replace(/\)/g, "");
			phoneText = phoneText.replace(/ /g, "");
			phoneText = phoneText.replace(/ /g, "");
			  
		  	if(phoneText.substring(0,10).search(/[a-zA-Z]/g)==-1 & isFinite(phoneText.substring(0,10)) & phoneText.substring(0,10).length==10){
				var part1 = phoneText.substring(0,6);
				part1 = part1.replace(/(\S{3})/g, "$1-");
				var part2 = phoneText.substring(6,10);
				var ext = phoneText.substring(10);
				if (ext.length) {
					var phoneField = part1 + part2+" "+ext;
				} else {
					var phoneField = part1 + part2;
				}
				$(frmfld).val(phoneField);
			} else if(phoneText.substring(0,10).length !=0) {
				if(fldName != ""){
					alert('Invalid '+fldName+'!');
				}else{
					alert('Invalid Phone Number!');
				}
				
				$(frmfld).focus();
			}
		}

		function countCharacters(){ 
			$("##charcount").text($("##tab-2 ##body").val().length);		
		}
		function clock(){
	        var currentDate = new Date();
	        var currentDay = currentDate.getDate();
	        var currentMonth = currentDate.getMonth() + 1;
	        var currentYear = currentDate.getFullYear();
	        var hours = currentDate.getHours();
	        var minutes = currentDate.getMinutes();

	        var currentDate = currentMonth + "/" + currentDay + "/" + currentYear;
	        var ampm = hours >= 12 ? 'PM' : 'AM';
	        hours = hours % 12;
	        hours = hours ? hours : 12; // the hour '0' should be '12'
	        minutes = minutes < 10 ? '0'+minutes : minutes;
	        var strTime = hours + ':' + minutes + ' ' + ampm;
	        var FinalTime = currentDate+' '+strTime;
	        return FinalTime
	    }
		function updateLoadStatusDispatched(){
			<cfif structkeyexists(url,"loadid") and len(trim(url.loadid)) gt 1 and getLoadDetails.statustext NEQ '3. DISPATCHED' AND getLoadDetails.statustext LT '3. DISPATCHED' AND getDispatchStatus.IsActive EQ 1>
				<cfif request.qGetSystemSetupOptions.RateConPromptOption EQ 1>
                if(confirm('Do you want to change the Load Status to "#getDispatchStatus.statusdescription#"?')){
                </cfif>
	                $.ajax({
	                    type    : 'POST',
	                    url     : "../gateways/loadgateway.cfc?method=updateLoadStatusDispatched",
	                    data    : {LoadID : '#url.loadid#' , dsn : '#Application.dsn#' , user : '#request.qcurAgentdetails.Name#', companyid:'#session.companyid#', clock:clock()},
	                    success :function(){ 
	                    	var oldStatusVal = window.opener.document.getElementById('oldStatusVal').value
	                        if(oldStatusVal != '#getDispatchStatus.ID#'){
	                        	$.ajax({
									type    : 'POST',
				                	url     : "ajax.cfm?event=ajxSendLoadEmailUpdate&LoadID=#url.loadid#&NewStatus=#getDispatchStatus.ID#&#session.URLToken#",
				                	data    : {},
				                	success :function(data){
				                	}
								})
	                        }    
	                        window.opener.location.reload();
	                    }
	                });
                <cfif request.qGetSystemSetupOptions.RateConPromptOption EQ 1>
                }
                </cfif>
            </cfif>
		}

		function defaultMobileNumber(){
			var ckMob = $('input[name="radMob"]:checked').val();
			$('##MailTo').val(ckMob);
		}

		function selectMobileApp(){
			<cfif url.EDispatchOptions EQ 1 AND request.qGetSystemSetupOptions.MobileAppSwitchConfirmation>
				$('body').addClass('formpopup-body-noscroll');
				$('.formpopup-overlay').show();
				$('##popup-e-dispatch').show();
			<cfelse>
				location.href='index.cfm?event=loadMail&type=#url.type#&loadid=#loadID#&EDispatchOptions=0&#session.URLToken#&carrierDispatch=#url.carrierDispatch#';
			</cfif>
		}
		function chooseMobileApp(opt){
			var ckd = $('##SwitchConfirmation').is(":checked");
			if(ckd==1){
				$.ajax({
					type    : 'POST',
	            	url     : "ajax.cfm?event=ajxOffMobileAppSwitchConfirmation&#session.URLToken#",
	            	data    : {},
	            	success :function(data){
	            	}
				})
			}
			if(opt==1){
				location.href='index.cfm?event=loadMail&type=#url.type#&loadid=#loadID#&EDispatchOptions=0&#session.URLToken#&carrierDispatch=#url.carrierDispatch#';
			}
			else{
				$("##webApp").prop("checked", true);
				$('body').removeClass('formpopup-body-noscroll');
	            $( ".form-popup" ).hide();
	            $('.formpopup-overlay').hide();
			}
		}
	</script>
	<style>
	    ##popup-e-dispatch{
	        left: 27%;
	        background-color: #request.qGetSystemSetupOptions.BackgroundColorForContent#;
	        width: 450px;
	        top: 30%;
	    }
	</style>
	<div class="formpopup-overlay"></div>
	<div class="form-popup" id="popup-e-dispatch">
	    <div class="form-popup-header">
	        Mobile App
	        <span class="form-popup-close">&times;</span>
	    </div>
	    <div class="form-popup-content">
	    	<form name="frmAddNewCustomer" id="frmAddNewCustomer">
	    		<p><b>$3 per load fee applies to all loads that are dispatched via the Load Manager Mobile App. Click OK to confirm you approved this charged and are authorized to do so. To avoid a charge click CANCEL.</b></p>
	    		<p style="margin-left: 175px;float: left;">Do not ask this again</p>
	    		<input style="margin-left: 5px;" type="checkbox" id="SwitchConfirmation">
	            <div class="clear"></div>
	            <input type="button" name="chooseMobApp" class="actbttn" value="OK" style="margin-left: 175px;" onclick="chooseMobileApp(1)">
		        <input type="button" class="actbttn" name="cancelMobApp" class="bttn" value="Cancel" onclick="chooseMobileApp(0)">
		        <img src="images/loadDelLoader.gif" class="fp-loader">
		    </form>
	    </div>
	</div>
	</html>
</cfoutput>