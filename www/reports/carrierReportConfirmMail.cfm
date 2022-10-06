
<cfparam name="url.loadid" default="0">
<cfparam name="MailTo" default="">
<cfparam name="MailFrom" default="">
<cfparam name="Subject" default="">
<cfparam name="body" default="">
<cfparam name="EOption" default="1">
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
<cfset SmtpAddress=request.qcurAgentdetails.SmtpAddress>
<cfset SmtpUsername=request.qcurAgentdetails.SmtpUsername>
<cfset SmtpPort=request.qcurAgentdetails.SmtpPort>
<cfset SmtpPassword=request.qcurAgentdetails.SmtpPassword>
<cfset FA_SSL=request.qcurAgentdetails.useSSL>
<cfset FA_TLS=request.qcurAgentdetails.useTLS>
<cfset MailFrom=request.qcurAgentdetails.EmailID>
<cfset MailTo=request.qcarriers.mailList>
<cfset TextTo=request.qcarriers.textList>
<cfset Subject = request.qGetSystemSetupOptions.CarrierHead>
<cfset emailSignature = request.qcurAgentdetails.emailSignature>
<cfset ConfirmDispatch = "">
<cfquery name="getLoadDetails" datasource="#Application.dsn#">
	SELECT  
		(SELECT TOP 1 NewDriverCell FROM LoadStops LS WHERE LS.LoadID = L.LoadID AND LS.stopNo = 0) AS Driver1Cell
		,(SELECT TOP 1 NewDriverCell2 FROM LoadStops LS WHERE LS.LoadID = L.LoadID  AND LS.stopNo = 0) AS Driver2Cell
		,(select CompanyName from Companies where CompanyID = <cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar">) as Company
		,C.Iscarrier
		,C.Cel
	FROM Loads L
	INNER JOIN Carriers C ON C.CarrierID = L.CarrierID
	WHERE L.LoadID = <cfqueryparam value="#loadID#" cfsqltype="cf_sql_varchar">
</cfquery>
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
<cfif variables.frieghtBroker EQ "Carrier">
	<cfset ConfirmDispatch = "Confirmation">
<cfelse>
	<cfset ConfirmDispatch = "Dispatch">
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
<cfif request.qGetSystemSetupOptions.IsIncludeLoadNumber EQ 1>
	<cfset includeLoadNumber = true>
<cfelse>
	<cfset includeLoadNumber = false>	
</cfif>
<cfquery name="getLoadDetails" datasource="#Application.dsn#">
	SELECT 
	L.STATUSTYPEID,
	LST.StatusText
	FROM Loads L
	INNER JOIN LoadStatusTypes LST ON LST.STATUSTYPEID = L.STATUSTYPEID
	WHERE L.LoadID = <cfqueryparam value="#url.loadID#" cfsqltype="cf_sql_varchar">
</cfquery>
<cfquery name="getDispatchStatus" datasource="#Application.dsn#">
	SELECT STATUSTYPEID AS ID,StatusDescription FROM LoadStatusTypes WHERE CompanyID = <cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar">
	AND StatusText = '3. DISPATCHED'
</cfquery>
<cfif request.qcurAgentdetails.recordcount gt 0 and (request.qcurAgentdetails.SmtpAddress eq "" or request.qcurAgentdetails.SmtpUsername eq "" or request.qcurAgentdetails.SmtpPort eq "" or request.qcurAgentdetails.SmtpPassword eq "" or request.qcurAgentdetails.SmtpPort eq 0 or request.qcurAgentdetails.EmailValidated EQ 0)>
    <cfset mailsettings = 0>
<cfelse>
    <cfset mailsettings = 1>
</cfif>
<cfif request.qGetSystemSetupOptions.CarrierRateConfirmation EQ 1>
	<cfset variables.carrierratecon=1>
<cfelse>
	<cfset variables.carrierratecon=0>	
</cfif>
<cfset customPath = "">
<cfquery name="qGetCompany" datasource="#Application.dsn#">
	select CompanyCode from Companies 
	WHERE CompanyID = 
	<cfif structKeyExists(url, "CompanyID")>
		<cfqueryparam value="#url.CompanyID#" cfsqltype="cf_sql_varchar">
	<cfelse>
		<cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar">
	</cfif>
</cfquery>

<cfif len(trim(qGetCompany.companycode)) and directoryExists(expandPath("../reports/#trim(qGetCompany.companycode)#"))>
	<cfset customPath = "#trim(qGetCompany.companycode)#">
</cfif>

<cfif IsDefined("form.sendEmail")>
	<cfif mailsettings eq 0>
		<cfset IsEmailSent = 1>
		<cfset smtpError = 1>
	<cfelseif form.MailTo is not "" AND form.MailFrom is not "" AND form.Subject is not "">
		<cfoutput>
			<cfinvoke component="#variables.objloadGateway#" method="getCarrierReport" LoadID = "#url.LoadID#" returnvariable="qCarrierReport" />
			<cfif len(trim(qCarrierReport.CompanyCode)) and directoryExists(expandPath("../reports/#trim(qCarrierReport.CompanyCode)#")) and fileExists(expandPath("../reports/#trim(qCarrierReport.CompanyCode)#/CarrierReport.cfm"))>
				<cfinclude template="#trim(qCarrierReport.CompanyCode)#/CarrierReport.cfm">
			<cfelse>
				<cfinclude template="CarrierReport.cfm">
			</cfif>

			<cfif structKeyExists(form, "Eoption") AND form.Eoption EQ 0>
				<cfset emailType="html">
					<cfsavecontent variable="emailBody">
						<div style="font-size: 14px;width: 610px;">
							<p>Hi.</p>
							<p>Here is your Carrier Rate Confirmation & Agreement</label> for <b>Load## #qCarrierReport.LOADNUMBER#</b> from <b>#request.qGetCompanyInformation.companyname#</b></p>
							<p>Please <a href="https://#cgi.http_host#/#application.dsn#/www/webroot/ERateCon.cfm?loadid=#loadid#&companyid=#session.companyID#">Click on this link</a> to view and accept the rate agreement. If you have any questions please contact us at #qCarrierReport.DispatcherPhone# and ask for #qCarrierReport.DispatcherName#. Thank You</p>
							<img src="https://#cgi.http_host#/#application.dsn#/www/fileupload/img/#request.qGetCompanyInformation.CompanyCode#/logo/#request.qGetSystemSetupOptions.companyLogoName#" width="120px;" />
							<p style="font-size: 12px;"><b style="text-decoration: underline;">NOTE:</b>This is not junk mail. You are receiving this from #request.qGetCompanyInformation.companyname#'s TMS system called Load Manager&trade;.<br>For any questions or more information, please call #request.qGetCompanyInformation.companyname# at #qCarrierReport.DispatcherPhone# and ask for #qCarrierReport.DispatcherName#</p>
							<p style="font-size: 12px;">Service Provided by:</p>
							<img src="https://#cgi.http_host#/#application.dsn#/www/webroot/images/banner3.jpg"  width="610px" >
						</div>
					</cfsavecontent>

			<cfelse>
				<cfset emailType="text/plain">
				<cfset emailBody = form.body>
			</cfif>
			<cftry>
				<cfif request.qGetCompanyInformation.ccOnEmails EQ true>		
					<cfmail from='"#SmtpUsername#" <#MailFrom#>' subject="#form.Subject#" to="#form.MailTo#"  CC="#request.qGetCompanyInformation.email#" type="#emailType#" server="#SmtpAddress#" username="#SmtpUsername#" password="#SmtpPassword#" port="#SmtpPort#" usessl="#FA_SSL#" usetls="#FA_TLS#" >
						#emailBody#
						<cfif structKeyExists(form, "Eoption") AND form.Eoption EQ 1>
							<cfmailparam
							file="#fileName#"
							type="application/pdf"
							content="#CarrierReport#"
							/>		
						</cfif>
					</cfmail>
					<cfset IsEmailSent = 1>
				<cfelse>	
					<cfmail from='"#SmtpUsername#" <#MailFrom#>' subject="#form.Subject#" to="#form.MailTo#"  type="#emailType#" server="#SmtpAddress#" username="#SmtpUsername#" password="#SmtpPassword#" port="#SmtpPort#" usessl="#FA_SSL#" usetls="#FA_TLS#" >
						 #emailBody#
						<cfif structKeyExists(form, "Eoption") AND form.Eoption EQ 1>
							<cfmailparam
							file="#fileName#"
							type="application/pdf"
							content="#CarrierReport#"
							/>
						</cfif>
					</cfmail>
					<cfset IsEmailSent = 1>
				</cfif>
				<cfinvoke component="#variables.objloadGateway#" method="setLogMails" loadID="#loadID#" date="#Now()#" subject="#form.Subject#" emailBody="#form.body#" reportType="carrier" fromAddress="#SmtpUsername#" toAddress="#form.MailTo#" />
				<cfsavecontent variable="content">
					<div id="message" class="msg-area" style="width: 100%;display:block;"><p>Thank you, <cfoutput>#form.MailFrom#: your message has been sent</cfoutput>.</p></div>
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
					<cfinvoke component="#variables.objloadGateway#" method="updateDispatchNotes" loadID="#loadID#"  Notes="#DateTimeFormat(now(),'m/dd/yyyy h:nn tt')# - #session.UserFullName# > Emailed #variables.frieghtBroker# Report " />
				</cfif>				
				<cfcatch>
					<cfsavecontent variable="content">
						<div id="message" class="msg-area" style="width: 100%;display:block;background: none repeat scroll 0 0 ##f4cbc8;border: 1px solid ##f2867a;"><p>The mail is not sent.#cfcatch.message#</p></div>
					</cfsavecontent>
				</cfcatch>
			</cftry>
		</cfoutput>
	<cfelse>
		<cfoutput>
		<cfsavecontent variable="content">
			<div id="message" class="msg-area" style="width: 100%;display:block;background: none repeat scroll 0 0 ##f4cbc8;border: 1px solid ##f2867a;"><p>Please provide details like 'From', 'To' and 'Subject'.</p></div>
		</cfsavecontent>
		</cfoutput>
	</cfif>
<cfelse>
	Unable to generate the report. Please specify the load Number or Load ID	
</cfif>


<cfif IsDefined("form.sendText")>
	<cfif form.MailTo is not "">				
		<cfoutput>
			<cftry>
				<cfif request.qGetSystemSetupOptions.TextAPI EQ 2>
					<cfthrow message="The texting feature is turned off. Please turn it on and try again.">
				</cfif>
				<!--- Character limit--->
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
					
					setTimeout(function(){ 
					    var emailDisplayStatus='<cfoutput>#request.qGetSystemSetupOptions.AutomaticEmailReports#</cfoutput>';
						if(emailDisplayStatus == '1'){
							window.opener.document.getElementById('dispatchHiddenValue').value="Texted #variables.frieghtBroker# Report >";
							window.opener.document.getElementById('dispatchNotes').prepend(clock()+' - '+ window.opener.document.getElementById('Loggedin_Person').value+ ' > Texted #variables.frieghtBroker# Report > \n');
						}
						<cfif IsEmailSent AND IsTextSent>
							window.close(); 
						</cfif>
					},2000);				
				</script>
				<cfif request.qGetSystemSetupOptions.AutomaticEmailReports EQ 1>
					<cfinvoke component="#variables.objloadGateway#" method="updateDispatchNotes" loadID="#loadID#"  Notes="#DateTimeFormat(now(),'mm/dd/yyyy h:nn tt')# - #session.UserFullName# > Texted #variables.frieghtBroker# Report " />
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
</cfif>

<cfif NOT IsTextSent AND request.qGetSystemSetupOptions.TextAPI NEQ 2>
	<cfset textBody ="">
	<cfset newLine = "&##13;&##10;">
	<cfquery name="careerReport" datasource="#Application.dsn#">
		SELECT * FROM vwCarrierRateConfirmation WITH (NOLOCK)
	   <cfif structkeyexists(url,"loadno")>
			WHERE  (LoadNumber =  <cfqueryparam value="#url.Loadno#" cfsqltype="cf_sql_varchar">)
		<cfelseif structkeyexists(url,"loadid")>
			WHERE  (LoadID =  <cfqueryparam value="#url.LoadID#" cfsqltype="cf_sql_varchar">)
	   </cfif>
			ORDER BY StopNo, LoadType, SrNo
	</cfquery>
	<cfset textBody ="##:" & careerReport.LoadNumber & newLine>
	<cfset prevStopID = "">
	<cfloop query="careerReport">
		<cfif prevStopID EQ careerReport.LoadStopID>
			<cfcontinue>
		</cfif>
		<cfset prevStopID = careerReport.LoadStopID>

		<cfif careerReport.LoadType EQ 1>
			<cfset textBody &= "**PICKUP:**" & newLine>
			<cfset textBody &= (Len(Trim(careerReport.StopName)) EQ 0) ? "" : careerReport.StopName & newLine>
			
			<cfset textBody &= careerReport.StopAddress & ", " & careerReport.StopCity & ((careerReport.StopState EQ "0") ? "" : " " & careerReport.StopState ) & ", " & careerReport.StopZip & newLine>


			<cfif Len(Trim(careerReport.StopDate)) NEQ 0 OR Len(Trim(careerReport.StopTime)) NEQ 0>
				<cfset textBody &= "DATE:">
			</cfif>				
			<cfset textBody &= (Len(Trim(careerReport.StopDate)) EQ 0) ? "" : Replace(DateFormat(careerReport.StopDate,'medium'), ",", "")>

			<cfif Len(Trim(careerReport.StopTime))>
				<cfset textBody &= " @ " & careerReport.StopTime>
			</cfif>
			<cfif Len(Trim(careerReport.StopDate)) NEQ 0 OR Len(Trim(careerReport.StopTime)) NEQ 0>
				<cfset textBody &= newLine>
			</cfif>
			<cfset textBody &= (Len(Trim(careerReport.PickDelNo)) EQ 0) ? "" : "PICKUP##:" & careerReport.PickDelNo & newLine>
			<cfset textBody &= (Len(Trim(careerReport.StopPhone)) EQ 0) ? "" : "PH:" & careerReport.StopPhone & newLine>


			<cfset textBody &= (Len(Trim(careerReport.CustomerPONo)) EQ 0) ? "" : "PO:" & careerReport.CustomerPONo & newLine>

		<cfelseif careerReport.LoadType EQ 2>
			<cfset textBody &= newLine & "**DELIVERY:**" & newLine>
			<cfset textBody &= (Len(Trim(careerReport.StopName)) EQ 0) ? "" : careerReport.StopName & newLine>


			<cfset textBody &= careerReport.StopAddress & ", " & careerReport.StopCity & ((careerReport.StopState EQ "0") ? "" : " " & careerReport.StopState ) & ", " & careerReport.StopZip & newLine>
			
			<cfif Len(Trim(careerReport.StopDate)) NEQ 0 OR Len(Trim(careerReport.StopTime)) NEQ 0>
				<cfset textBody &= "DATE:">
			</cfif>				
			<cfset textBody &= (Len(Trim(careerReport.StopDate)) EQ 0) ? "" : Replace(DateFormat(careerReport.StopDate,'medium'), ",", "")>

			<cfif Len(Trim(careerReport.StopTime))>
				<cfset textBody &= " @ " & careerReport.StopTime>
			</cfif>
			<cfif Len(Trim(careerReport.StopDate)) NEQ 0 OR Len(Trim(careerReport.StopTime)) NEQ 0>
				<cfset textBody &= newLine>
			</cfif>
			<cfset textBody &= (Len(Trim(careerReport.PickDelNo)) EQ 0) ? "" : "DELIVERY##:" & careerReport.PickDelNo & newLine>s

			<cfset textBody &= (Len(Trim(careerReport.StopPhone)) EQ 0) ? "" : "PH:" & careerReport.StopPhone & newLine>


			<cfset textBody &= (Len(Trim(careerReport.carrierNotes)) EQ 0) ? "" : "NOTES:" & careerReport.carrierNotes & newLine & newLine>

		</cfif>
	</cfloop>
	<cfset textBody &= careerReport.CompanyName>
</cfif>


<cfoutput>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="X-UA-Compatible" content="IE=edge" />
<meta http-equiv="X-UA-Compatible" content="IE=8" >
<link rel="stylesheet" type="text/css" href="styles/jquery.autocomplete.css" />
<link rel="stylesheet" href="https://code.jquery.com/ui/1.11.0/themes/smoothness/jquery-ui.css">
<script src="https://code.jquery.com/jquery-1.10.2.min.js"></script>
<script src="https://code.jquery.com/ui/1.11.0/jquery-ui.min.js"></script>

<script language="javascript" type="text/javascript" src="../scripts/jquery.form.js"></script>	
<link href="../webroot/styles/style.css" rel="stylesheet" type="text/css" />
<title>Load Manager TMS</title>

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
				var emailDisplayStatus='<cfoutput>#request.qGetSystemSetupOptions.AutomaticEmailReports#</cfoutput>';
				if(emailDisplayStatus == '1'){
					window.opener.document.getElementById('dispatchHiddenValue').value="Emailed #variables.frieghtBroker# Report >";
					window.opener.document.getElementById('dispatchNotes').prepend(clock()+' - '+ window.opener.document.getElementById('Loggedin_Person').value+ ' > Emailed #variables.frieghtBroker# Report \n');
				}
				alert('Your Mail has been sent.')
				window.close();
			})
			
		<cfelseif IsTextSent AND NOT IsEmailSent> 
			$(document).ready(function(){
				alert('Your Message has been sent.')
				window.close();
			})
		<cfelseif IsTextSent AND IsEmailSent>
			$(document).ready(function(){
				<cfif IsDefined("form.sendEmail")>
					var emailDisplayStatus='<cfoutput>#request.qGetSystemSetupOptions.AutomaticEmailReports#</cfoutput>';
					if(emailDisplayStatus == '1'){
						window.opener.document.getElementById('dispatchHiddenValue').value="Emailed #variables.frieghtBroker# Report >";
						window.opener.document.getElementById('dispatchNotes').prepend(clock()+' - '+ window.opener.document.getElementById('Loggedin_Person').value+ ' > Emailed #variables.frieghtBroker# Report \n');
					}
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
</body>  

<cfif isDefined('content')>
#content#
</cfif>
<p> 


	<div class="white-mid" style="width: 100%;">
		<h1 style="color:white;font-weight:bold;background-color: ##82bbef;padding-left: 10px;">
			#variables.frieghtBroker# Report
		</h1>
		<div class="form-con" style="width:auto;">
			<ul class="tabs">
				<cfif NOT IsEmailSent AND mailsettings EQ 1><li class="tab-link <cfif (NOT IsDefined("form.sendText") AND NOT IsDefined("form.sendEmail")) OR IsTextSent> current</cfif>" data-tab="tab-1">Email #ConfirmDispatch#</li></cfif>
				<cfif NOT IsTextSent AND request.qGetSystemSetupOptions.TextAPI NEQ 2><li class="tab-link <cfif IsEmailSent OR IsDefined("form.sendText") OR mailsettings EQ 0> current </cfif>" data-tab="tab-2">Text #ConfirmDispatch#</li></cfif>
			</ul>
			<div class="clear"></div>	
			<cfif mailsettings EQ 1>		
				<cfif NOT IsEmailSent>
					<div id="tab-1" class="tab-content <cfif (NOT IsDefined("form.sendText") AND NOT IsDefined("form.sendEmail")) OR IsTextSent> current</cfif>">
						<form action = "index.cfm?event=loadMail&type=#variables.frieghtBroker#&loadid=#loadID#&#session.URLToken#" method="POST" style="margin-top: 10px;">
							<cfif includeLoadNumber>
								<cfif structkeyexists(url,"loadno") AND len(trim(url.loadno)) GT 0>
									<cfset Subject = Subject &' - Load## #url.loadno#' />
								<cfelseif structkeyexists(url,"loadid") AND len(trim(url.loadid)) GT 0>
									<cfquery name="getLoadNumber" datasource="#Application.dsn#">
										SELECT LoadNumber FROM Loads WHERE  LoadID =  <cfqueryparam value="#url.LoadID#" cfsqltype="cf_sql_varchar">
									</cfquery>	
									<cfset Subject = Subject &' - Load## #getLoadNumber.LoadNumber#' />	
								</cfif>
							</cfif>
							<fieldset>
								<label style="margin-top: 3px;">To:</label>
								<input style="width:500px;" type="Text" name="MailTo" class="mid-textbox-1 CarrEmail" id="MailTo" value="#MailTo#">
								<div class="clear"></div>
								<label style="margin-top: 3px;">From:</label>
								<input style="width:500px;" type="Text" name="MailFrom" class="mid-textbox-1 disabledLoadInputs" id="MailFrom" value="#MailFrom#" readonly>
								<div class="clear"></div>
								<cfif request.qGetCompanyInformation.ccOnEmails EQ true>
									<label style="margin-top: 3px;">Cc:</label>
									<input style="width:500px;" type="Text" name="cCMail" class="mid-textbox-1 disabledLoadInputs" id="cCMail" value="#request.qGetCompanyInformation.email#" readonly>
									<div class="clear"></div>
								</cfif>
								<label style="margin-top: 3px;">Subject:</label>
								<input style="width:500px;" type="Text" name="Subject" class="mid-textbox-1" id="Subject" value="#Subject#">
								<div class="clear"></div>
								<label style="margin-top: 3px;">Message:</label>
								<textarea style="width:500px;height:180px;" class="addressChange" rows="" name="body" id="body" cols=""><cfif not IsDefined("form.sendEmail")>&##13;&##10;#emailSignature#<cfelse>#form.body#</cfif></textarea>
								<div class="clear"></div>
								<input type="radio" value="0" name="EOption" style="width: 20px;margin-left: 110px;" <cfif EOption EQ 0>checked </cfif>>Electronic Rate Confirmation (Auto Dispatch with Carrier Confirmation and e-signature)
								<div class="clear"></div>
								<input type="radio" value="1"  name="EOption" style="width: 20px;margin-left: 110px;" <cfif EOption EQ 1>checked </cfif>>PDF only
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
			</cfif>
			<cfif request.qGetSystemSetupOptions.TextAPI NEQ 2>
				<cfif NOT IsTextSent>
					<div id="tab-2" class="tab-content <cfif IsEmailSent OR IsDefined("form.sendText") OR mailsettings EQ 0> current</cfif>">
						 <form action = "index.cfm?event=loadMail&type=#variables.frieghtBroker#&loadid=#loadID#&#session.URLToken#" method="POST" style="margin-top: 10px;">
							<fieldset>
								<label style="margin-top: 3px;">To:</label>
								<input style="width:500px;" type="Text" name="MailTo" class="mid-textbox-1" id="MailTo" value="<cfif not IsDefined("form.sendText")>#TextTo#<cfelse>#form.MailTo#</cfif>">
								<div class="clear"></div>							
								<label style="margin-top: 3px;">Message:</label>
								<textarea style="width:500px;height:180px;" class="addressChange" rows="" name="body" id="body" cols="" onkeyup="javascript:countCharacters()"><cfif not IsDefined("form.sendText")>#textBody#<cfelse>#form.body#</cfif></textarea>
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
			</cfif>
		</div>
	</div>
	<div class="white-mid" style="width:auto;">
		<div class="form-con" style="bottom: 0px; position: absolute; background-color: rgb(130, 187, 239); width: 100%; padding: 2px 5px;">	
		</div>
	</div>
</p> 

<div class="clear"></div>	

<script type="text/javascript">
	$(document).ready(function(){
		$('##body').focus();
		$('ul.tabs li').click(function(){
			var tab_id = $(this).attr('data-tab');

			$('ul.tabs li').removeClass('current');
			$('.tab-content').removeClass('current');

			$(this).addClass('current');
			$("##"+tab_id).addClass('current');
		})
		countCharacters();

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

	});
	function countCharacters(){ 
		if(document.getElementById(name) != null) {
			$("##charcount").text($("##tab-2 ##body").val().length);
		}		
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
		<cfif structkeyexists(url,"loadid") and len(trim(url.loadid)) gt 1 and getLoadDetails.StatusText NEQ '3. DISPATCHED'>
            if(confirm('Do you want to change the Load Status to "#getDispatchStatus.StatusDescription#"?')){
                $.ajax({
                    type    : 'POST',
                    url     : "../gateways/loadgateway.cfc?method=updateLoadStatusDispatched",
                    data    : {LoadID : '#url.loadid#' , dsn : '#Application.dsn#' , user : '#request.qcurAgentdetails.Name#', companyid:'#session.companyid#', clock:clock()},
                    success :function(){     
                        window.opener.document.getElementById('dispatchNotes').prepend(clock()+' - '+ window.opener.document.getElementById('Loggedin_Person').value+ ' > Status changed to #getDispatchStatus.StatusDescription# \n');
                        window.opener.document.getElementById('loadStatus').value='#getDispatchStatus.ID#';

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
            }
        </cfif>
	}
</script>
</html>
</cfoutput>