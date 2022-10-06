
<cfparam name="url.CarrierID" default="">

<cfinvoke component="#variables.objloadGateway#" method="getCompanyInformation" returnvariable="request.qGetCompanyInformation" />
<cfinvoke component="#variables.objloadGateway#" method="getSystemSetupOptions" returnvariable="request.qGetSystemSetupOptions" />
<cfset variables.freightBroker = request.qGetSystemSetupOptions.freightBroker/>
<cfset variables.numberOfRecords = request.qGetSystemSetupOptions.numberOfCarrierInEmail/>

<cfif structKeyExists(url, "BulkCarrierIDTS")>
	<cffile action="read" file="#expandPath('../temp/BulkAlertCarrierID_#session.CompanyID#_#url.BulkCarrierIDTS#.txt')#" variable="CarrierIDList">
	<cfinvoke component="#variables.objloadGateway#" method="getAllCarrierContacts" freightBroker="#variables.freightBroker#" CarrierID="#CarrierIDList#" numberOfRecords="#variables.numberOfRecords#" returnvariable="request.qcarriers" />
<cfelse>
	<cfinvoke component="#variables.objloadGateway#" method="getAllCarrierContacts" freightBroker="#variables.freightBroker#" CarrierID="#url.CarrierID#" numberOfRecords="#variables.numberOfRecords#" returnvariable="request.qcarriers" />
</cfif>
<cfinvoke component="#variables.objloadGateway#" method="getcurAgentMaildetails" returnvariable="request.qcurAgentdetails" employeID="#session.empid#" />

<cfinvoke component="#variables.objloadGateway#" method="getLoadDetailsForMailAlert" LoadID="#url.LoadID#" returnvariable="getLoadDetails" />
<cfinvoke component="#variables.objequipmentGateway#" method="getloadEquipments" returnvariable="request.qEquipments" />
<cfset SmtpAddress=request.qcurAgentdetails.SmtpAddress>
<cfset SmtpUsername=request.qcurAgentdetails.SmtpUsername>
<cfset SmtpPort=request.qcurAgentdetails.SmtpPort>
<cfset SmtpPassword=request.qcurAgentdetails.SmtpPassword>
<cfset FA_SSL=request.qcurAgentdetails.useSSL>
<cfset FA_TLS=request.qcurAgentdetails.useTLS>
<cfset MailFrom=request.qcurAgentdetails.EmailID>
<cfset MailTo=request.qcarriers.mailList>
<cfset Subject = request.qGetSystemSetupOptions.DefaultLaneAlertEmailSubject>
<cfset emailSignature = request.qcurAgentdetails.emailSignature>

<cfset Message = request.qGetSystemSetupOptions.DefaultLaneAlertEmailtext>
<cfset Message = replaceNoCase(Message, "{EmailSignature}", replace(request.qcurAgentdetails.emailSignature,"Regards,","Regards,<br>"), "ALL")>

<cfset Message = replaceNoCase(Message, "{Pickup City}", "")>
<cfset Message = replaceNoCase(Message, "{Delivery City}", "")>
<cfif IsDefined("form.sendEmail")>	
	<cfset form.MailTo = ListRemoveDuplicates(form.MailTo, ";") />
	<cfif form.MailTo is not "" AND form.MailFrom is not "" AND form.Subject is not "">
		<cfoutput>
			<cftry>
				<cfif request.qGetCompanyInformation.ccOnEmails EQ true>
					<cfloop list="#form.MailTo#" item="emailTo" delimiters=";">
						<cfset tempBody= form.body>
						<cfif IsValid( "email", emailTo)>
							<cfmail from='"#SmtpUsername#" <#SmtpUsername#>' subject="#form.Subject#" to="#emailTo#"  CC="#form.cCMail#" type="text/plain" server="#SmtpAddress#" username="#SmtpUsername#" password="#SmtpPassword#" port="#SmtpPort#" usessl="#FA_SSL#" usetls="#FA_TLS#" replyto="#SmtpUsername#">
								<cfif structKeyExists(request.qcarriers.emailAndName, emailTo)>
									<cfset carrierName = structFind(request.qcarriers.emailAndName, emailTo) />
									<cfset tempBody = replaceNoCase(tempBody, "[carrierName]", ' '&carrierName, 'one') >
								<cfelse>	
									<cfset tempBody = replaceNoCase(tempBody, "[carrierName]", "") >
								</cfif>
								#tempBody#
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
						<cfset tempBody= form.body>
						<cfif IsValid( "email", emailTo)>
							<cfmail from='"#SmtpUsername#" <#SmtpUsername#>' subject="#form.Subject#" to="#emailTo#"  type="text/plain" server="#SmtpAddress#" username="#SmtpUsername#" password="#SmtpPassword#" port="#SmtpPort#" usessl="#FA_SSL#" usetls="#FA_TLS#" replyto="#SmtpUsername#" >
								<cfif structKeyExists(request.qcarriers.emailAndName, emailTo)>
									<cfset carrierName = structFind(request.qcarriers.emailAndName, emailTo) />
									<cfset tempBody = replaceNoCase(tempBody, "[carrierName]", ' '&carrierName, 'one') >
								<cfelse>	
									<cfset tempBody = replaceNoCase(tempBody, "[carrierName]", "") >
								</cfif>
								#tempBody#
								<cfif len(form.attachments)>
									<cfset tempDir = expandpath('upload/temp#DateTimeFormat(now(),"yyMMddHHnnssl")#/')>
									<cfset DirectoryCreate(tempDir)>
									<cffile action = "uploadAll" destination = "#tempDir#" result="attachmentArr">
									<cfloop array="#attachmentArr#" item="attach">
										<cfmailparam file="#tempDir##attach.serverfile#"/>
									</cfloop>
								</cfif>
							</cfmail>
						</cfif>
					</cfloop>
				</cfif>
				
				<cfsavecontent variable="content">
					<div id="message" class="msg-area" style="width: 100%;display:block;"><p>Thank you, <cfoutput>#form.MailFrom#: your mail has been sent</cfoutput>.</p></div>
				</cfsavecontent>
				<cfset EmailSent = 1>	
				<cfif structKeyExists(session, "lanesLoadID")>
					<cfset structDelete(session, "lanesLoadID")>
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
	Unable to send email. Please specify the load Number or Load ID	
</cfif>


<cfoutput>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="X-UA-Compatible" content="IE=edge" />
<meta http-equiv="X-UA-Compatible" content="IE=8" >
<script language="javascript" type="text/javascript" src="https://code.jquery.com/jquery-1.6.2.min.js"></script>	
<script language="javascript" type="text/javascript" src="scripts/jquery.form.js"></script>	
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
</head>
<body>
</body>  

<cfif isDefined('content')>
#content#
</cfif>
<p> 


	<div class="white-mid" style="width: 100%;">
		<h1 style="color:white;font-weight:bold;background-color: ##82bbef;padding-left: 10px;">
			Load Notification
		</h1>
		<div class="form-con" style="width:auto;">
			<ul class="tabs">
				<li class="tab-link current" data-tab="tab-1">Email</li>
			</ul>
			<div class="clear"></div>			
				<div id="tab-1" class="tab-content current">
					<form action = "" method="POST" style="margin-top: 10px;" enctype="multipart/form-data">
						<fieldset>
							<label style="margin-top: 3px;">Email Merge List:</label>
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
							<textarea style="width:500px;height:180px;" class="addressChange" rows="" name="body" id="body" cols="">#Message#</textarea>
							<div class="clear"></div>
							<label style="margin-top: 3px;">Attach File(s):</label>
							<input style="width:500px;" type="file" name="attachments" id="attachments" multiple>
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

<script type="text/javascript">
	$(document).ready(function(){
		<cfif isdefined('EmailSent')>
			alert('Your Mail has been sent.');
			window.close();
		</cfif>
		$('ul.tabs li').click(function(){
			var tab_id = $(this).attr('data-tab');

			$('ul.tabs li').removeClass('current');
			$('.tab-content').removeClass('current');

			$(this).addClass('current');
			$("##"+tab_id).addClass('current');
		})



		var sourceEquipJson = [
		<cfloop query="request.qEquipments">
			{ID:"#request.qEquipments.EquipmentID#",Name:"#request.qEquipments.EquipmentName#"},
		</cfloop>
		];

		if (typeof(window.opener.document.getElementById('PickUpState')) != 'undefined' && window.opener.document.getElementById('PickUpState') != null)
		{
			var PickUpState = window.opener.document.getElementById('PickUpState').value.replace(",0", "");
			var DeliveryState = window.opener.document.getElementById('DeliveryState').value.replace(",0", "");
			var EquipmentID = window.opener.document.getElementById('EquipmentID').value.replace(",0", "").split(",");
		}
		
		else if (typeof(window.opener.document.getElementById('ShipperStateAdv')) != 'undefined' && window.opener.document.getElementById('ShipperStateAdv') != null)
		{
			var PickUpState = window.opener.document.getElementById('ShipperStateAdv').value.replace(",0", "");
			var DeliveryState = window.opener.document.getElementById('ConsigneeStateAdv').value.replace(",0", "");
			var EquipmentID = window.opener.document.getElementById('EquipmentAdv').value.replace(",0", "").split(",");
		}
		else{
			var PickUpState = window.opener.document.getElementById('shipperstate').value;
			var DeliveryState = window.opener.document.getElementById('consigneestate').value;
			var EquipmentID = window.opener.document.getElementById('equipment').value;
		}


		let str = document.getElementById("body").innerHTML; 
		if(PickUpState==0){
			PickUpState = "";
		}
  		if(DeliveryState==0){
			DeliveryState="";
		}
		str = str.replace("{Delivery State}", DeliveryState);
		str = str.replace("{Pickup State}", PickUpState);
		var Trucks = [];
		$.each(EquipmentID, function(index,EquipID) {
			$.each(sourceEquipJson, function(i, v) {
		        if (v.ID == EquipID) {
		            Trucks.push(v.Name);
		        }
			});
        }); 
		str = str.replace("{Equipment}", Trucks);
		$('##body').val(str);




	});
	
</script>
</html>
</cfoutput>