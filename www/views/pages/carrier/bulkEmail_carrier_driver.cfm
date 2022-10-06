<cfparam name="url.loadid" default="0">
<cfparam name="MailTo" default="">
<cfparam name="MailFrom" default="">
<cfparam name="Subject" default="">
<cfparam name="body" default="">
<cfparam name="emailSignature" default="">
<cfset loadID = "">
<cfif  structkeyexists(url,"loadid") and len(trim(url.loadid)) gt 1>
	<cfset loadID = url.loadid>
</cfif>
<cfinvoke component="#variables.objloadGateway#" method="getCompanyInformation" returnvariable="request.qGetCompanyInformation" />
<cfinvoke component="#variables.objloadGateway#" method="getSystemSetupOptions" returnvariable="request.qGetSystemSetupOptions" />
<cfset variables.freightBroker = request.qGetSystemSetupOptions.freightBroker/>
<cfinvoke component="#variables.objloadGateway#" method="getAllCarrierDriverContacts" freightBroker="#variables.freightBroker#" returnvariable="request.qcarriers" />
<cfinvoke component="#variables.objloadGateway#" method="getcurAgentMaildetails" returnvariable="request.qcurAgentdetails" employeID="#session.empid#" />
<cfset SmtpAddress=request.qcurAgentdetails.SmtpAddress>
<cfset SmtpUsername=request.qcurAgentdetails.SmtpUsername>
<cfset SmtpPort=request.qcurAgentdetails.SmtpPort>
<cfset SmtpPassword=request.qcurAgentdetails.SmtpPassword>
<cfset FA_SSL=request.qcurAgentdetails.useSSL>
<cfset FA_TLS=request.qcurAgentdetails.useTLS>
<cfset MailFrom=request.qcurAgentdetails.EmailID>
<cfset MailTo=request.qcarriers.mailList>
<cfset Subject = "General Message" >
<cfset emailSignature = request.qcurAgentdetails.emailSignature>
	
<cfif IsDefined("form.send")>	
	<cfset form.MailTo = ListRemoveDuplicates(form.MailTo, ";") />
	<cfif form.MailTo is not "" AND form.MailFrom is not "" AND form.Subject is not "">
		<cfoutput>
			<cftry>
				<cfif request.qGetCompanyInformation.ccOnEmails EQ true>
					<cfloop list="#form.MailTo#" item="emailTo" delimiters=";">
						<cfif IsValid( "email", emailTo)>
							<cfmail from='"#SmtpUsername#" <#SmtpUsername#>' subject="#form.Subject#" to="#emailTo#"  CC="#form.cCMail#" type="text/plain" server="#SmtpAddress#" username="#SmtpUsername#" password="#SmtpPassword#" port="#SmtpPort#" usessl="#FA_SSL#" usetls="#FA_TLS#" >
								#form.body#
								<cfif len(form.attachments)>
									<cfset tempDir = expandpath('upload/temp#DateTimeFormat(now(),"yyMMddHHnnssl")#/')>
									<cfset DirectoryCreate(tempDir)>
									<cffile action = "uploadAll" destination = "#tempDir#" result="attachmentArr">
									<cfloop array="#attachmentArr#" item="attach">
										<cfmailparam file="#tempDir##attach.serverfile#"/>
									</cfloop>
								</cfif>
							</cfmail>
							<cfset IsEmailSent = 1>
						</cfif>
					</cfloop>	
				<cfelse>	
					<cfloop list="#form.MailTo#" item="emailTo" delimiters=";">
						<cfif IsValid( "email", emailTo)>
							<cfmail from='"#SmtpUsername#" <#SmtpUsername#>' subject="#form.Subject#" to="#emailTo#"  type="text/plain" server="#SmtpAddress#" username="#SmtpUsername#" password="#SmtpPassword#" port="#SmtpPort#" usessl="#FA_SSL#" usetls="#FA_TLS#" >								
								#form.body#
								<cfif len(form.attachments)>
									<cfset tempDir = expandpath('upload/temp#DateTimeFormat(now(),"yyMMddHHnnssl")#/')>
									<cfset DirectoryCreate(tempDir)>
									<cffile action = "uploadAll" destination = "#tempDir#" result="attachmentArr">
									<cfloop array="#attachmentArr#" item="attach">
										<cfmailparam file="#tempDir##attach.serverfile#"/>
									</cfloop>
								</cfif>
							</cfmail>
							<cfset IsEmailSent = 1>
						</cfif>
					</cfloop>
				</cfif>
				
				<!--- <cfinvoke component="#variables.objloadGateway#" method="setLogMails" loadID="#loadID#" date="#Now()#" subject="#form.Subject#" emailBody="#form.body#" reportType="carrier" fromAddress="#SmtpUsername#" toAddress="#form.MailTo#" /> --->
				<cfsavecontent variable="content">
					<div id="message" class="msg-area" style="width: 100%;display:block;"><p>Thank you, <cfoutput>#form.MailFrom#: your message has been sent</cfoutput>.</p></div>
				</cfsavecontent>	
				<script>
					setTimeout(function(){ 
						window.close(); 
					}, 2000);									
				</script>
				<!--- <cfif request.qGetSystemSetupOptions.AutomaticEmailReports EQ 1>
					<cfinvoke component="#variables.objloadGateway#" method="updateDispatchNotes" loadID="#loadID#"  Notes="#DateTimeFormat(now(),'dd/mm/yyyy hh:mm tt')# - #session.UserFullName# > Emailed #variables.freightBroker# Report " />
				</cfif> --->				
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
	Unable to send email. Please specify the load Number or Load ID	
</cfif>
					   
<cfoutput>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="X-UA-Compatible" content="IE=edge" />
<meta http-equiv="X-UA-Compatible" content="IE=8" >
<script language="javascript" type="text/javascript" src="scripts/jquery-1.6.2.min.js"></script>	
<script language="javascript" type="text/javascript" src="scripts/jquery.form.js"></script>	
<link href="../webroot/styles/style.css" rel="stylesheet" type="text/css" />
<style>
	.progress { position:relative; width:400px; border: 1px solid ##ddd; padding: 1px; border-radius: 3px; }
	.bar { background-image:url("../webroot/images/pbar-ani.gif"); width:0%; height:20px; border-radius: 3px; }
	.percent { position:absolute; display:inline-block; top:3px; left:48%; }
	
	input.alertbox{
	border-color:##dd0000;
}
</style></head>
<body>
</body>  

<cfif isDefined('content')>
#content#
</cfif>
<p> 
<form action = "index.cfm?event=bulkEmail&#session.URLToken#" method="POST" enctype="multipart/form-data">
	<div class="white-mid" style=" border-top: 5px solid rgb(130, 187, 239);width: 100%;">
		<div class="form-con" style="width:auto;">
			<fieldset>
			<div style="color:##000000;font-size:14px;font-weight:bold;margin-bottom:20px;margin-top:10px;">Bulk Email</div>
			<div class="clear"></div>
			<label style="margin-top: 3px;">To:</label>
			<input style="width:500px;" type="Text" name="MailTo" class="mid-textbox-1" id="MailTo" value="#MailTo#">
			<div class="clear"></div>
			<label style="margin-top: 3px;">From:</label>
			<input style="width:500px;" type="Text" name="MailFrom" class="mid-textbox-1 disabledLoadInputs" id="MailFrom" value="#MailFrom#" readonly>
			<div class="clear"></div>
			<cfif request.qGetCompanyInformation.ccOnEmails EQ true>
				<label style="margin-top: 3px;">Cc:</label>
				<input style="width:500px;" type="Text" name="cCMail" class="mid-textbox-1" id="cCMail" value="#request.qGetCompanyInformation.email#">
				<div class="clear"></div>
			</cfif>
			<label style="margin-top: 3px;">Subject:</label>
			<input style="width:500px;" type="Text" name="Subject" class="mid-textbox-1" id="Subject" value="#Subject#">
			<div class="clear"></div>
			<label style="margin-top: 3px;">Message:</label>
			<textarea style="width:500px;height:180px;" class="addressChange" rows="" name="body" id="body" cols="">#body# <cfif not IsDefined("form.send")>&##13;&##10;&##13;&##10;&##13;&##10;&##13;&##10;#emailSignature#</cfif></textarea>
			<div class="clear"></div>
			<label style="margin-top: 3px;">Attach File(s):</label>
			<input style="width:500px;" type="file" name="attachments" id="attachments" multiple>
			<div class="clear"></div>
			</fieldset>
		</div>
	</div>
	<div class="white-mid" style="width:auto;">
		<div class="form-con" style="bottom: 0px; position: absolute; background-color: rgb(130, 187, 239); width: 100%; padding: 2px 5px;">
			<fieldset>
				<div style="width:auto;">
					<input type = "Submit" name = "send" value="Send">
				</div>
			</fieldset>
		</div>
	</div>
</p> 
</form> 
</html>
</cfoutput>