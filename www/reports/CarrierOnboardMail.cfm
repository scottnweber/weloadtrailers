<cfparam name="MailFrom" default="">
<cfquery name="qGetConfig" datasource="#application.dsn#">
  	SELECT DefaultOnboardingEmailSubject,DefaultOnboardingEmailCC,DefaultOnboardingEmailtext,UserOnBoardingInvite,UseEmail FROM SystemConfigOnboardCarrier WHERE CompanyID = <cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar">
</cfquery>
<cfif qGetConfig.UseEmail EQ 0>
	<cfinvoke component="#variables.objloadGateway#" method="getcurAgentMaildetails" returnvariable="request.qcurAgentdetailsforMail" employeID="#qGetConfig.UserOnBoardingInvite#" />
<cfelseif qGetConfig.UseEmail EQ 2>
	<cfinvoke component="#variables.objloadGateway#" method="getcurAgentMaildetails" returnvariable="request.qcurAgentdetailsforMail" employeID="#session.empid#" />
<cfelse>
	<cfset request.qcurAgentdetailsforMail = structnew()>
	<cfset request.qcurAgentdetailsforMail.SmtpAddress = 'smtp.office365.com'>
	<cfset request.qcurAgentdetailsforMail.SmtpUsername = 'noreply@loadmanager.com'>
	<cfset request.qcurAgentdetailsforMail.SmtpPort = '587'>
	<cfset request.qcurAgentdetailsforMail.SmtpPassword = 'Wsi2025!@##'>
	<cfset request.qcurAgentdetailsforMail.useSSL = 0>
	<cfset request.qcurAgentdetailsforMail.useTLS = 1>
	<cfset request.qcurAgentdetailsforMail.EmailID = 'noreply@loadmanager.com'>
</cfif>
<cfif isDefined("form.sendEmail")>
	<cfset SmtpAddress=request.qcurAgentdetailsforMail.SmtpAddress>
	<cfset SmtpUsername=request.qcurAgentdetailsforMail.SmtpUsername>
	<cfset SmtpPort=request.qcurAgentdetailsforMail.SmtpPort>
	<cfset SmtpPassword=request.qcurAgentdetailsforMail.SmtpPassword>
	<cfset FA_SSL=request.qcurAgentdetailsforMail.useSSL>
	<cfset FA_TLS=request.qcurAgentdetailsforMail.useTLS>
	<cfset MailFrom=request.qcurAgentdetailsforMail.EmailID>

	<cfif structKeyExists(form, "cCMail")>
      	<cfmail from='"#SmtpUsername#" <#SmtpUsername#>' subject="#form.Subject#" to="#form.mailto#" type="text/html" server="#SmtpAddress#" username="#SmtpUsername#" password="#SmtpPassword#" port="#SmtpPort#" usessl="#FA_SSL#" usetls="#FA_TLS#" cc="#trim(form.cCMail)#">  
          	#form.body#
      	</cfmail>
    <cfelse>
      	<cfmail from='"#SmtpUsername#" <#SmtpUsername#>' subject="#form.Subject#" to="#form.mailto#" type="text/html" server="#SmtpAddress#" username="#SmtpUsername#" password="#SmtpPassword#" port="#SmtpPort#" usessl="#FA_SSL#" usetls="#FA_TLS#">  
          	#form.body#
      	</cfmail>
    </cfif>
    <cfquery name="qUpd" datasource="#application.dsn#">
      	UPDATE Carriers SET 
      	OnboardStatus = <cfif structKeyExists(url, "ExpiredDocuments")>4<cfelse>1</cfif> 
      	,OBCarrierEmail = <cfqueryparam value="#form.mailto#" cfsqltype="cf_sql_varchar">
      	,OBLMEmail = <cfqueryparam value="#SmtpUsername#" cfsqltype="cf_sql_varchar">  
      	,OBLMUserName = <cfqueryparam value="#session.adminusername#" cfsqltype="cf_sql_varchar">
      	,OBLMUserID = <cfqueryparam value="#session.empid#" cfsqltype="cf_sql_varchar">
      	WHERE CarrierID = <cfqueryparam value="#url.CarrierID#" cfsqltype="cf_sql_varchar"> 
    </cfquery>
    <cfoutput>
    	<script>
    		alert('Onboard email send successfully.');
    		if (typeof(opener.document.getElementById('OnBoardCarrier')) != 'undefined' && opener.document.getElementById('OnBoardCarrier') != null)
				{
		    		<cfif structKeyExists(url, "ExpiredDocuments")>
		    			opener.document.getElementById('OnBoardCarrier').value = 'Documents Pending';
		    		<cfelse>
		    			opener.document.getElementById('OnBoardCarrier').value = 'Onboarding in Progress';
		    		</cfif>
		    		opener.document.getElementById('OnBoardCarrier').style.color = '##4c4c4c';
		    	}
    		window.close();
    	</script>
    </cfoutput>
    <cfabort>
</cfif>

<cfinvoke component="#variables.objloadGateway#" method="getCompanyInformation" returnvariable="request.qGetCompanyInformation" />
<cfinvoke component="#variables.objAgentGateway#" method="getAllAgent" returnvariable="request.qAgent" />
<cfquery name="qGet" datasource="#application.dsn#">
  	SELECT EmailID,CarrierName FROM Carriers WHERE CarrierID = <cfqueryparam value="#url.CarrierID#" cfsqltype="cf_sql_varchar">
</cfquery>
<cfset MailTo = qGet.EmailID>
<cfset MailFrom=request.qcurAgentdetailsforMail.EmailID>
<cfif structKeyExists(url, "ExpiredDocuments")>
	<cfset Subject = "Document renewal!">
	<cfinvoke component = "#variables.objCarrierGateway#" method="GetExpiredDocuments" carrierid = "#url.carrierid#" returnvariable="request.qGetExpiredDocuments"/>
	<cfset Message = "Hi, please click on this <a href='https://#cgi.HTTP_HOST#/#trim(listFirst(cgi.SCRIPT_NAME,'/'))#/www/webroot/CarrierOnBoard/index.cfm?event=#request.qGetExpiredDocuments.AttachmentTypeID#_AttachFile&CarrierID=#url.CarrierID#&RenewAttachmentType=#valueList(request.qGetExpiredDocuments.AttachmentTypeID)#'>link</a> to update your profile with the following updated documents:<br />">
	<cfloop query="request.qGetExpiredDocuments">
		<cfset Message &= "<br />"&request.qGetExpiredDocuments.currentrow&")"&request.qGetExpiredDocuments.Description>
	</cfloop>
	<cfset Message &= "<br /><br />Regards,<br />#request.qGetCompanyInformation.CompanyName#">
<cfelseif structKeyExists(url, 'ExpiredInsurance')>
	<cfset Subject = "Document renewal!">
	<cfset Message = "Hi, please click on this <a href='https://#cgi.HTTP_HOST#/#trim(listFirst(cgi.SCRIPT_NAME,'/'))#/www/webroot/CarrierOnBoard/index.cfm?event=CarrierInsurance&CarrierID=#url.CarrierID#'>link</a> to update your profile with the following updated Insurance:<br />">
	<cfset Message &= "<br /><br />Regards,<br />#request.qGetCompanyInformation.CompanyName#">
<cfelse>
	<cfset Subject = qGetConfig.DefaultOnboardingEmailSubject>
	<cfset Message = replace(qGetConfig.DefaultOnboardingEmailtext,chr(13)&chr(10),"<br />","all")>
	<cfset Message = replaceNoCase(Message, "{CarrierName}", qGet.CarrierName,"ALL")>
	<cfset Message = replaceNoCase(Message, "{CompanyName}", request.qGetCompanyInformation.CompanyName,"ALL")>
</cfif>
<cfset Link = "<a href='https://#cgi.HTTP_HOST#/#trim(listFirst(cgi.SCRIPT_NAME,'/'))#/www/webroot/CarrierOnBoard/index.cfm?event=CarrierInformation&CarrierID=#url.CarrierID#'>click this link</a>">
<cfset Message = replaceNoCase(Message, "{ClickThisLink}", Link)>
<cfoutput>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="X-UA-Compatible" content="IE=edge" />
<meta http-equiv="X-UA-Compatible" content="IE=8" >
<script language="javascript" type="text/javascript" src="https://code.jquery.com/jquery-1.6.2.min.js"></script>	
<script language="javascript" type="text/javascript" src="scripts/jquery.form.js"></script>	
<link href="../webroot/styles/style.css" rel="stylesheet" type="text/css" />
<script language="javascript" type="text/javascript" src="../webroot/javascripts/plugins/ckeditor/ckeditor.js?ver=4.16.0"></script>	
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
	$(document).ready(function(){
		CKEDITOR.replace('tbody', {contentsCss:"body {font-size: 13px;font-family:Arial;margin:3px 0px 0px 2px;} p {margin:0};"});
	})
	function validateForm(){
		var MailFrom = $.trim($('##MailFrom').val());
		var MailTo = $.trim($('##MailTo').val());
		if(!MailFrom.length){
			if(confirm("You will need to select an email address for sending onboarding emails first. Click OK to continue")){
				window.opener.location.href='index.cfm?event=OnboardSetting&#session.URLToken#'
				window.close();
			}
			else{
				return false;
			}
		} else if (!MailTo.length){
			alert("Unable to send the email. Please enter Email To address.")
			$('##MailTo').focus()
			return false;
		} else if ("#request.qcurAgentdetailsforMail.SmtpAddress#" == ""){
			alert("Unable to send the email. Please check the SMTP settings.")
			window.close()
			return false;
		}
	}
</script>
</head>
<body>
</body>  

<p> 


	<div class="white-mid" style="width: 100%;">
		<h1 style="color:white;font-weight:bold;background-color: ##82bbef;padding-left: 10px;">
			Carrier Onboard Mail
		</h1>
		<div class="form-con" style="width:auto;">
			<ul class="tabs">
				<li class="tab-link current" data-tab="tab-1">Email</li>
			</ul>
			<div class="clear"></div>			
				<div id="tab-1" class="tab-content current">
					<form action = "index.cfm?event=loadMail&type=CarrierOnboard&CarrierID=#url.CarrierID#&#session.URLToken#<cfif structKeyExists(url, "ExpiredDocuments")>&ExpiredDocuments=1</cfif>" method="POST" style="margin-top: 10px;" enctype="multipart/form-data" onsubmit="return validateForm();">
						<fieldset>
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
							<textarea style="width:500px;height:180px;" class="addressChange" rows="" name="body" id="tbody" cols="">#Message#</textarea>
							<div class="clear"></div>
							<div style="width:auto;float: right;">
								<input type = "Submit" name = "sendEmail" value="Send">
							</div>
						</fieldset>
					</form> 
				</div>
		</div>
	</div>
	<div class="white-mid" style="width:auto;">
		<div class="form-con" style="bottom: 0px; position: absolute; width: 100%; padding: 2px 5px;">	
		</div>
	</div>
</p> 

<div class="clear"></div>	

</html>
</cfoutput>