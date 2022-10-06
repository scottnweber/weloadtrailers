<cfinvoke component="#variables.objloadGateway#" method="getCompanyInformation" returnvariable="request.qGetCompanyInformation" />
<cfinvoke component="#variables.objloadGateway#" method="getSystemSetupOptions" returnvariable="request.qGetSystemSetupOptions" />
<cfinvoke component="#variables.objloadGateway#" method="getLoadStatusUpdateMailDetails" returnvariable="request.qGetLoadDetails" LoadID="#url.LoadID#"/>
<cfinvoke component="#variables.objloadGateway#" method="getcurAgentMaildetails" returnvariable="request.qcurAgentdetails" employeID="#request.qGetSystemSetupOptions.UserAccountStatusUpdate#" />

<cfparam name="MailTo" default="">
<cfparam name="MailFrom" default="">
<cfparam name="Subject" default="">
<cfparam name="Message" default="">


<cfif structKeyExists(form, "sendEmail")>
	<cfif request.qcurAgentdetails.recordcount gt 0 and (request.qcurAgentdetails.SmtpAddress eq "" or request.qcurAgentdetails.SmtpUsername eq "" or request.qcurAgentdetails.SmtpPort eq "" or request.qcurAgentdetails.SmtpPassword eq "" or request.qcurAgentdetails.SmtpPort eq 0 or request.qcurAgentdetails.EmailValidated EQ 0)>
		<cfset errorMsg = "The email was not sent, please check your email settings.">
	<cfelseif not len(trim(form.MailTo)) or not len(trim(form.MailFrom)) or not len(trim(form.Subject))>
		<cfset errorMsg = "Please provide details like 'From', 'To' and 'Subject'.">
	<cfelse>
		<cfif request.qGetSystemSetupOptions.StatusUpdateMailType EQ 0>
			<cfset SmtpAddress=request.qcurAgentdetails.SmtpAddress>
			<cfset SmtpUsername=request.qcurAgentdetails.SmtpUsername>
			<cfset SmtpPort=request.qcurAgentdetails.SmtpPort>
			<cfset SmtpPassword=request.qcurAgentdetails.SmtpPassword>
			<cfset FA_SSL=request.qcurAgentdetails.useSSL>
			<cfset FA_TLS=request.qcurAgentdetails.useTLS>
		<cfelse>
			<cfset SmtpAddress='smtp.office365.com'>
			<cfset SmtpUsername='noreply@loadmanager.com'>
			<cfset SmtpPort=587>
			<cfset SmtpPassword='Wsi2025!@##'>
			<cfset FA_SSL=0>
			<cfset FA_TLS=1>
		</cfif>
		<cfif structKeyExists(form, "MailCC")>
			<cfmail from='"#SmtpUsername#" <#form.MailFrom#>' subject="#form.Subject#" to="#form.MailTo#" cc="#form.MailCC#" type="text/html" server="#SmtpAddress#" username="#SmtpUsername#" password="#SmtpPassword#" port="#SmtpPort#" usessl="#FA_SSL#" usetls="#FA_TLS#" >
				#form.Message#
			</cfmail>
		<cfelse>
			<cfmail from='"#SmtpUsername#" <#form.MailFrom#>' subject="#form.Subject#" to="#form.MailTo#" type="text/html" server="#SmtpAddress#" username="#SmtpUsername#" password="#SmtpPassword#" port="#SmtpPort#" usessl="#FA_SSL#" usetls="#FA_TLS#" >
				#form.Message#
			</cfmail>
		</cfif>
		<cfinvoke component="#variables.objloadGateway#" method="setLogMails" LoadID="#url.LoadID#" date="#Now()#" subject="#form.Subject#" emailBody="#form.Message#" reportType="LocationUpdate" fromAddress="#SmtpUsername#" toAddress="#form.MailTo#" />
		<cfset NewDispatchNotes = "#DateTimeFormat(now(),"mm/dd/yyyy h:nn: tt")# - #session.UserFullName# > Status update was emailed.">
		<cfquery name="qUpdLoadEmailList" datasource="#application.dsn#">
			UPDATE Loads SET EmailList = <cfqueryparam value="#form.MailTo#" cfsqltype="cf_sql_varchar"> 
			,NewDispatchNotes = <cfqueryparam cfsqltype="cf_sql_varchar" value="#NewDispatchNotes#">+CHAR(13)+NewDispatchNotes
			WHERE LoadID = <cfqueryparam value="#url.LoadID#" cfsqltype="cf_sql_varchar">
		</cfquery>
		<cfset emailSent = 1>	
	</cfif>

	<cfset MailTo = form.MailTo>
	<cfset MailFrom = form.MailFrom>
	<cfset Subject = form.Subject>
	<cfset Message = form.Message>
<cfelse>
	<!---Begin: MailTo --->
	<cfif len(trim(request.qGetLoadDetails.EmailList))>
		<cfset MailTo = trim(request.qGetLoadDetails.EmailList)>
	<cfelse>
		<cfif listFindNoCase(request.qGetSystemSetupOptions.DefaultLoadEmails, "Customer") AND len(trim(request.qGetLoadDetails.ContactEmail))>
			<cfset MailTo = listAppend(MailTo, request.qGetLoadDetails.ContactEmail,";")>
		</cfif>
		<cfif listFindNoCase(request.qGetSystemSetupOptions.DefaultLoadEmails, "Sales Rep") AND len(trim(request.qGetLoadDetails.SalesRepEmail))>
			<cfset MailTo = listAppend(MailTo, request.qGetLoadDetails.SalesRepEmail,";")>
		</cfif>
		<cfif listFindNoCase(request.qGetSystemSetupOptions.DefaultLoadEmails, "Dispatcher") AND len(trim(request.qGetLoadDetails.DispatcherEmail))>
			<cfset MailTo = listAppend(MailTo, request.qGetLoadDetails.DispatcherEmail,";")>
		</cfif>
		<cfif listFindNoCase(request.qGetSystemSetupOptions.DefaultLoadEmails, "Company") AND len(trim(request.qGetCompanyInformation.Email))>
			<cfset MailTo = listAppend(MailTo, request.qGetCompanyInformation.Email,";")>
		</cfif>
	</cfif>
	<cfset MailTo = ListRemoveDuplicates(MailTo)>
	<!---End: MailTo --->
	<cfif request.qGetSystemSetupOptions.StatusUpdateMailType EQ 0>
		<cfset MailFrom=request.qcurAgentdetails.EmailID>
	<cfelse>
		<cfset MailFrom='noreply@loadmanager.com'>
	</cfif>
	<cfset Subject = "#request.qGetSystemSetupOptions.DefaultLoadEmailSubject# - Load## #request.qGetLoadDetails.LoadNumber#">
	<!---Begin: Message --->
	<cfset Message = replace(request.qGetSystemSetupOptions.DefaultLoadEmailtext,chr(13)&chr(10),"<br />","all")>
	<cfset Message = replaceNoCase(Message, "Load## {LoadNumber}", "<b>Load## {LoadNumber}</b>")>
	<cfset Message = replaceNoCase(Message, "Status: {LoadStatus}", "<b><u>Status:</u></b> {LoadStatus}")>
	<cfset Message = replaceNoCase(Message, "PO##: {PONumber}", "<b><u>PO##:</u></b> {PONumber}")>
	<cfset Message = replaceNoCase(Message, "{EmailSignature}", replace(request.qcurAgentdetails.emailSignature,"Regards,","Regards,<br>"), "ALL")>
	<cfset Message = replaceNoCase(Message, "{LoadNumber}", request.qGetLoadDetails.LoadNumber)>
	<cfset Message = replaceNoCase(Message, "{PONumber}", request.qGetLoadDetails.CustomerPONo)>
	<cfif structKeyExists(url, "LoadStatus")>
		<cfset loadStatusText = url.LoadStatus>
	<cfelse>
		<cfset loadStatusText = request.qGetLoadDetails.StatusDescription>
	</cfif>
	<cfset Message = replaceNoCase(Message, "{Map}", "<a href='#request.qGetLoadDetails.mapLink#' target='_blank'>VIEW LOCATION UPDATES</a>")>
	<cfset stopBody = "">
	<cfset stopNumber = 1>
	<cfloop query="request.qGetLoadDetails">
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
	<cfif stopNumber GT 2 AND len(trim(request.qGetLoadDetails.LoadStatusStopNo)) EQ 2>
		<cfset stopTypeNo = left(trim(request.qGetLoadDetails.LoadStatusStopNo),1)>
		<cfset stopTypeText = right(trim(request.qGetLoadDetails.LoadStatusStopNo),1)>
		<cfif stopTypeText EQ 'S'>
			<cfset stopTypeText = 'Pickup'>
		<cfelse>
			<cfset stopTypeText = 'Delivery'>
		</cfif>
		<cfset Message = replaceNoCase(Message, "{LoadStatus}", loadStatusText & " " & "Stop " & stopTypeNo & " " & stopTypeText)>
	<cfelse>
		<cfset Message = replaceNoCase(Message, "{LoadStatus}", loadStatusText)>
	</cfif>
	<cfset Message = replaceNoCase(Message, "{StopDetails}", stopBody)>
	<!---End: Message --->
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
			<script language="javascript" type="text/javascript" src="../webroot/javascripts/plugins/ckeditor/ckeditor.js?ver=4.16.0"></script>		
			<link href="../webroot/styles/style.css" rel="stylesheet" type="text/css" />
			<title>Load Manager TMS</title>
			<style>
				.progress { position:relative; width:400px; border: 1px solid ##ddd; padding: 1px; border-radius: 3px; }
				.bar { background-image:url("../webroot/images/pbar-ani.gif"); width:0%; height:20px; border-radius: 3px; }
				.percent { position:absolute; display:inline-block; top:3px; left:48%; }
				input.alertbox{	border-color:##dd0000; }
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
				##cke_Message{
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
				$(document).ready(function(){
					<cfif isDefined("emailSent") and emailSent EQ 1>
						window.opener.document.getElementById('dispatchNotes').prepend('#NewDispatchNotes#\n');
						alert('Your Mail has been sent.');
						window.close();
					</cfif>
					CKEDITOR.replace('Message', {allowedContent: 'p b u a[href];'});

					<cfif structKeyExists(url, "ReviewOnly")>
						$('##sendEmail').hide();
						$('##Message,##Subject,##MailTo').attr("readonly", true).css('background-color','##e3e3e3');
					</cfif>
				});
			</script>
		</head>
		</head>
		<body>
			<cfif isDefined("errorMsg")>
				<div id="message" class="msg-area" style="width: 100%;display:block;background: none repeat scroll 0 0 ##f4cbc8;border: 1px solid ##f2867a;"><p>#errorMsg#</p></div>
			</cfif>
			<div class="white-mid" style="width: 100%;">
				<h1 style="color:white;font-weight:bold;background-color: ##82bbef;padding-left: 10px;">
					Email Updates<cfif structKeyExists(url, "ReviewOnly")> (Review Only)</cfif>
				</h1>
				<div class="form-con" style="width:auto;">
					<ul class="tabs">
						<li class="tab-link current" data-tab="tab-1">Email</li>
					</ul>
					<div class="clear"></div>	
					<div id="tab-1" class="tab-content current">
						<form action = "" method="POST" style="margin-top: 10px;">
							<fieldset>
								<label style="margin-top: 3px;">To:</label>
								<input style="width:500px;" type="Text" name="MailTo" class="mid-textbox-1" id="MailTo" value="#MailTo#">
								<div class="clear"></div>
								<label style="margin-top: 3px;">From:</label>
								<input style="width:500px;" type="Text" name="MailFrom" class="mid-textbox-1 disabledLoadInputs" id="MailFrom" value="#MailFrom#" readonly>
								<div class="clear"></div>
								<cfif request.qGetCompanyInformation.ccOnEmails EQ true and len(trim(request.qGetCompanyInformation.email))>
									<label style="margin-top: 3px;">CC:</label>
									<input style="width:500px;" type="Text" name="MailCC" class="mid-textbox-1 disabledLoadInputs" id="MailCC" value="#request.qGetCompanyInformation.email#" readonly>
									<div class="clear"></div>
								</cfif>
								<label style="margin-top: 3px;">Subject:</label>
								<input style="width:500px;" type="Text" name="Subject" class="mid-textbox-1" id="Subject" value="#Subject#">
								<div class="clear"></div>
								<label style="margin-top: 3px;">Message:</label>
								<textarea style="width:500px;height:180px;" rows="" name="Message" id="Message" cols="">#Message#</textarea>
								<div class="clear"></div>
								<div style="width:auto;float: right;">
									<input type = "Submit" name = "sendEmail" id = "sendEmail" value="Send">
								</div>
							</fieldset>
						</form>
					</div>
				</div>
			</div>
		</body> 
	</html>
</cfoutput>