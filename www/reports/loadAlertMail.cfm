<cfparam name="url.loadid" default="0">
<cfparam name="MailTo" default="">
<cfparam name="MailFrom" default="">
<cfparam name="Subject" default="">
<cfparam name="body" default="">
<cfparam name="emailSignature" default="">
<cfparam name="totalCarrierCharges" default="0">
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
<cfset variables.freightBroker = request.qGetSystemSetupOptions.freightBroker/>
<cfset variables.numberOfRecords = request.qGetSystemSetupOptions.numberOfCarrierInEmail/>
<cfinvoke component="#variables.objloadGateway#" method="getAllCarrierContacts" freightBroker="#variables.freightBroker#" numberOfRecords="#variables.numberOfRecords#" returnvariable="request.qcarriers" />
<!--- Get the dispatcher contact details by using dispatcher id --->
<cfif structKeyExists(url,"dispatcherId")>
	<cfinvoke component="#variables.objloadGateway#" method="getSalesPersonDetails" DispatcherID="#url.dispatcherId#" 	returnvariable="request.qdispContatDetails" />
</cfif>

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
<!--- <cfset Subject = request.qGetSystemSetupOptions.CarrierHead> --->
<cfset Subject = "AVAILABLE LOADS">
<cfset emailSignature = request.qcurAgentdetails.emailSignature>
<cfset ConfirmDispatch = "">
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
	
<cfif IsDefined("form.sendEmail")>	
	<cfset form.MailTo = ListRemoveDuplicates(form.MailTo, ";") />
	<cfif form.MailTo is not "" AND form.MailFrom is not "" AND form.Subject is not "">
		<cfoutput>
			<cftry>
				<cfif request.qGetCompanyInformation.ccOnEmails EQ true>
					<cfloop list="#form.MailTo#" item="emailTo" delimiters=";">
						<cfset tempBody= form.body>
						<cfif IsValid( "email", emailTo)>
							<cfmail from='"#SmtpUsername#" <#SmtpUsername#>' subject="#form.Subject#" to="#emailTo#"  CC="#form.cCMail#" type="text/plain" server="#SmtpAddress#" username="#SmtpUsername#" password="#SmtpPassword#" port="#SmtpPort#" usessl="#FA_SSL#" usetls="#FA_TLS#" replyto="#request.qdispContatDetails.emailId#">
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
							<cfmail from='"#SmtpUsername#" <#SmtpUsername#>' subject="#form.Subject#" to="#emailTo#"  type="text/plain" server="#SmtpAddress#" username="#SmtpUsername#" password="#SmtpPassword#" port="#SmtpPort#" usessl="#FA_SSL#" usetls="#FA_TLS#" replyto="#request.qdispContatDetails.emailId#" >
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
				</cfif>
				
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
					
					setTimeout(function(){ 
					    var emailDisplayStatus='<cfoutput>#request.qGetSystemSetupOptions.AutomaticEmailReports#</cfoutput>';
						if(emailDisplayStatus == '1'){
							window.opener.document.getElementById('dispatchHiddenValue').value="Emailed #variables.frieghtBroker# Report >";
							window.opener.document.getElementById('dispatchNotes').prepend(clock()+' - '+ window.opener.document.getElementById('Loggedin_Person').value+ ' > Emailed #variables.frieghtBroker# Report > \n');
							//window.opener.document.getElementById('dispatchNotes').focus();
						}
						<cfif IsEmailSent AND IsTextSent>
							window.close(); 
						</cfif> 
					},2000);				
				</script>		
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
							<!--- <cfset number = "5166951118"> --->
							<cfset restBody = {"country_code" = 1, "mobile_number" = "#number#", "message" = {"text" = "#form.body#"}}>
							<!--- <cfdump var="#serializeJSON(restBody)#" abort="true"> --->
							<cfhttp result="textResult" method="PUT" url="http://api.trumpia.com/rest/v1/LoadManager1/mobilemessage">
								<cfhttpparam name="Content-Type" type="header" value="application/json">
								<cfhttpparam name="X-Apikey" type="header" value="f0c5ace485736aaab2a31d7f9f2e783c">

								<cfhttpparam type="body" value="#serializeJSON(restBody)#">
							</cfhttp>
							<!--- <cfdump var="#textResult#"> --->
							<cfset fileContent = deserializeJSON(textResult.Filecontent)>


							<cfhttp result="textResult1" method="GET" charset="utf-8" url="http://api.trumpia.com/rest/v1/LoadManager1/report/#fileContent.request_id#">						    
								<cfhttpparam name="Content-Type" type="header" value="application/json">
								<cfhttpparam name="X-Apikey" type="header" value="f0c5ace485736aaab2a31d7f9f2e783c">
							</cfhttp>
							<!--- <cfdump var="#textResult1#"> --->
						
						<cfelseif request.qGetSystemSetupOptions.TextAPI EQ 1>
							<cfset fromNumber = "Plivo Texting API - 18665243748">
							
							<cfset restBody = {"src" = "18665243748", "dst" = 1&"#number#", "text" = "#form.body#"}><!---3054922182 ---- non toll free - 6312010077 --- toll free - 8665243748 ---->
							<cfhttp result="textresult1" method="POST" charset="utf-8" url="https://api.plivo.com/v1/Account/MAODG4YMVMN2FHZMQWYJ/Message/" username="MAODG4YMVMN2FHZMQWYJ" password="NzMyNjM2N2EyZDQzNjJiMjRjNTM2ZjhlNTBmNzhk">
								<cfhttpparam name="Content-Type" type="header" value="application/json">
								<cfhttpparam type="body" value="#serializeJSON(restBody)#">							
							</cfhttp>
							<!--<cfdump var="#textresult1#">-->
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
							//window.opener.document.getElementById('dispatchNotes').focus();
						}
						<cfif IsEmailSent AND IsTextSent>
							window.close(); 
						</cfif>
					},2000);				
				</script>
				<!--- <cfif request.qGetSystemSetupOptions.AutomaticEmailReports EQ 1>
					<cfinvoke component="#variables.objloadGateway#" method="updateDispatchNotes" loadID="#loadID#"  Notes="#DateTimeFormat(now(),'dd/mm/yyyy hh:mm tt')# - #session.UserFullName# > Texted #variables.frieghtBroker# Report " />
				</cfif>	 --->			
				<cfcatch>
					<cfsavecontent variable="content">
						<div id="message" class="msg-area" style="width: 100%;display:block;background: none repeat scroll 0 0 ##f4cbc8;border: 1px solid ##f2867a;"><p>The text is not sent.#cfcatch.message#</p>
						<!---<cfdump var="#cfcatch#">---></div>
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

<cfif NOT IsTextSent>
	<cfset textBody ="">
	<cfset newLine = "&##13;&##10;">

	<cfinvoke component="#variables.objloadGateway#" method="getLoadDetailsForMailAlert" LoadID="#url.LoadID#" returnvariable="getLoadDetails" />

	<cfset textBody ="Hello," & newLine>
	<cfset textBody &="Load ##: ">
	<cfif Len(Trim(getLoadDetails.LoadNumber))>
		<cfset textBody &= Trim(getLoadDetails.LoadNumber) >
	</cfif>
	<cfset textBody &= " is available. Details are below." & newLine>
	<cfset textBody &= (Len(Trim(getLoadDetails.StopDate)) EQ 0) ? "" : Replace(DateFormat(getLoadDetails.StopDate,'medium'), ",", "") >

	<cfif Len(Trim(getLoadDetails.StopTime))>
		<cfset textBody &= " @ "& Trim(getLoadDetails.StopTime) >
	</cfif>
	<cfif Len(Trim(getLoadDetails.City))>
		<cfset textBody &= ", "& Trim(getLoadDetails.City) >
	</cfif>
	<cfif Len(Trim(getLoadDetails.StateCode))>
		<cfset textBody &= ", "& Trim(getLoadDetails.StateCode) >
	</cfif>
	<cfset textBody &=  newLine>
	<cfif getLoadDetails.recordcount/2 EQ 1>
		<cfset stop = "is 1 stop">
	<cfelseif getLoadDetails.recordcount/2 GT 1>
		<cfset stop = "are #getLoadDetails.recordcount/2# stops">
	</cfif>	

	<cfset textBody &= "There #stop# on this load." & newLine>

	<cfset textBody &= (Len(Trim(getLoadDetails.StopDate[getLoadDetails.recordcount])) EQ 0) ? "" : Replace(DateFormat(getLoadDetails.StopDate[getLoadDetails.recordcount],'medium'), ",", "") >

	<cfif Len(Trim(getLoadDetails.StopTime[getLoadDetails.recordcount]))>
		<cfset textBody &= " @ "& Trim(getLoadDetails.StopTime[getLoadDetails.recordcount]) >
	</cfif>
	<cfif Len(Trim(getLoadDetails.City))>
		<cfset textBody &= ", "& Trim(getLoadDetails.City[getLoadDetails.recordcount]) >
	</cfif>
	<cfif Len(Trim(getLoadDetails.StateCode))>
		<cfset textBody &= ", "& Trim(getLoadDetails.StateCode[getLoadDetails.recordcount]) >
	</cfif>
	<cfif totalCarrierCharges GT 0>
		<cfset textBody &= newLine& "Amount: $#url.totalCarrierCharges#" >
	</cfif>
	<cfif  Len(Trim(request.qdispContatDetails.cel)) AND  Len(Trim(request.qdispContatDetails.telephone))>
		<cfset variables.separator = ', ' />
	<cfelse>	
		<cfset variables.separator = '' />
	</cfif>
	<cfset bottomNote = newLine & newLine & "If you are interested in this load please call (#trim(request.qdispContatDetails.telephone)##variables.separator##Trim(request.qdispContatDetails.cel)#) or email (#trim(request.qdispContatDetails.emailId)#)" >
	<cfset textBody &= bottomNote />
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
</style></head>
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
				<cfif NOT IsEmailSent><li class="tab-link <cfif (NOT IsDefined("form.sendText") AND NOT IsDefined("form.sendEmail")) OR IsTextSent> current</cfif>" data-tab="tab-1">Email <!--- #ConfirmDispatch# ---></li></cfif>
				<cfif NOT IsTextSent><li class="tab-link <cfif IsEmailSent OR IsDefined("form.sendText")> current </cfif>" data-tab="tab-2">Text <!--- #ConfirmDispatch# ---></li></cfif>
			</ul>
			<div class="clear"></div>			
			<cfif NOT IsEmailSent>
				<cfset emailBody ="">
				<cfset newLine = "&##13;&##10;">

				<cfset emailBody ="Hello [carrierName]," & newLine & newLine>
				<cfset emailBody &="Load ##: " >
				<cfinvoke component="#variables.objloadGateway#" method="getLoadDetailsForMailAlert" LoadID="#url.LoadID#" returnvariable="getLoadDetails" />
				<cfif Len(Trim(getLoadDetails.LoadNumber))>
					<cfset emailBody &= Trim(getLoadDetails.LoadNumber) >
				</cfif>
				<cfset emailBody &= " is available going from ">
				<cfif Len(Trim(getLoadDetails.City))>
					<cfset emailBody &= Trim(getLoadDetails.City) >
				<cfelse>
					<cfset emailBody &= "<Pickup city not set>" >	
				</cfif>
				<cfif Len(Trim(getLoadDetails.StateCode))>
					<cfset emailBody &= ", "& Trim(getLoadDetails.StateCode) >
				<cfelse>
					<cfset emailBody &= ", <Pickup state not set>" >	
				</cfif>
				<cfset emailBody &= " to ">
				<cfif Len(Trim(getLoadDetails.City[getLoadDetails.recordcount]))>
					<cfset emailBody &= Trim(getLoadDetails.City[getLoadDetails.recordcount]) >
				<cfelse>
					<cfset emailBody &= "<Delivery city not set>" >	
				</cfif>
				<cfif Len(Trim(getLoadDetails.StateCode[getLoadDetails.recordcount]))>
					<cfset emailBody &= ", "& Trim(getLoadDetails.StateCode[getLoadDetails.recordcount]) >
				<cfelse>
					<cfset emailBody &= ", <Delivery state not set>" >	
				</cfif>
				<cfset emailBody &= ". Please see the details below." & newLine & newLine>

				<cfset prevStopID = "">
				
				<cfloop query="getLoadDetails">
					<cfif getLoadDetails.LoadType EQ 1>	
						<cfset emailBody &= "*PICK*: " >
						<cfset emailBody &= (Len(Trim(getLoadDetails.StopDate)) EQ 0) ? "<Pickup date not set>" : Replace(DateFormat(getLoadDetails.StopDate,'medium'), ",", "") >

						<cfif Len(Trim(getLoadDetails.CustName))>
							<cfset emailBody &= ", "& Trim(getLoadDetails.CustName) >
						</cfif>
						<cfif Len(Trim(getLoadDetails.Address))>
							<cfset emailBody &= ", "& Trim(getLoadDetails.Address) >
						</cfif>
						<cfif Len(Trim(getLoadDetails.City))>
							<cfset emailBody &= ", "& Trim(getLoadDetails.City) >
						</cfif>
						<cfif Len(Trim(getLoadDetails.StateCode))>
							<cfset emailBody &= ", "& Trim(getLoadDetails.StateCode) >
						</cfif>
						<cfif Len(Trim(getLoadDetails.PostalCode))>
							<cfset emailBody &= ", "& Trim(getLoadDetails.PostalCode) >
						</cfif>						
						<cfset emailBody &= newLine & newLine>
						
					<cfelseif getLoadDetails.LoadType EQ 2>
						<cfset emailBody &= "*DROP*: " >
						<cfset emailBody &= (Len(Trim(getLoadDetails.StopDate)) EQ 0) ? "<Delivery date not set>" : Replace(DateFormat(getLoadDetails.StopDate,'medium'), ",", "") >
						<cfif Len(Trim(getLoadDetails.CustName))>
							<cfset emailBody &= ", "& Trim(getLoadDetails.CustName) >
						</cfif>
						<cfif Len(Trim(getLoadDetails.Address))>
							<cfset emailBody &= ", "& Trim(getLoadDetails.Address) >
						</cfif>
						<cfif Len(Trim(getLoadDetails.City))>
							<cfset emailBody &= ", "& Trim(getLoadDetails.City) >
						</cfif>
						<cfif Len(Trim(getLoadDetails.StateCode))>
							<cfset emailBody &= ", "& Trim(getLoadDetails.StateCode) >
						</cfif>
						<cfif Len(Trim(getLoadDetails.PostalCode))>
							<cfset emailBody &= ", "& Trim(getLoadDetails.PostalCode) >
						</cfif>
						<cfset emailBody &= newLine & newLine>
						
					</cfif>
				</cfloop>
				<!--- <cfset emailBody &= "*DELIVERY*: " >
				<cfset emailBody &= (Len(Trim(getLastDeliveryDetails.StopDate)) EQ 0) ? "" : Replace(DateFormat(getLastDeliveryDetails.StopDate,'medium'), ",", "") >
				<cfif Len(Trim(getLastDeliveryDetails.StopTime))>
					<cfset emailBody &= " @ " & Trim(getLastDeliveryDetails.StopTime) >
				</cfif>
				<cfif Len(Trim(getLastDeliveryDetails.stopAddress))>
					<cfset emailBody &= ", "& Trim(getLastDeliveryDetails.stopName) >
				</cfif>
				<cfif Len(Trim(getLastDeliveryDetails.stopAddress))>
					<cfset emailBody &= ", "& Trim(getLastDeliveryDetails.stopAddress) >
				</cfif>
				<cfif Len(Trim(getLastDeliveryDetails.StopCity))>
					<cfset emailBody &= ", "& Trim(getLastDeliveryDetails.StopCity) >
				</cfif>
				<cfif Len(Trim(getLastDeliveryDetails.StopState))>
					<cfset emailBody &= ", "& Trim(getLastDeliveryDetails.StopState) >
				</cfif>
				<cfif Len(Trim(getLastDeliveryDetails.stopZip))>
					<cfset emailBody &= ", "& Trim(getLastDeliveryDetails.stopZip) >
				</cfif> --->

				<cfif url.totalCarrierCharges GT 0>
					<cfset emailBody &= "Amount: $#url.totalCarrierCharges#" & newLine & newLine >
				</cfif>
				<cfif  Len(Trim(request.qdispContatDetails.cel)) AND  Len(Trim(request.qdispContatDetails.telephone))>
					<cfset variables.separator = ', ' />
				<cfelse>	
					<cfset variables.separator = '' />
				</cfif>
				<cfset bottomNote = "If you are interested in this load please call (#trim(request.qdispContatDetails.telephone)##variables.separator##Trim(request.qdispContatDetails.cel)#) or email (#trim(request.qdispContatDetails.emailId)#)" & newLine >
				<cfset unsubscribeNote = 'To unsubscribe to this email please reply with "REMOVE" in the subject line.' >
				<cfset emailBody &= bottomNote >
				<cfset emailBody &= unsubscribeNote >
				<!--- <cfset emailBody &= newLine & newLine & "To unsubscribe from future emails please click This Link." > --->
				
				<div id="tab-1" class="tab-content <cfif (NOT IsDefined("form.sendText") AND NOT IsDefined("form.sendEmail")) OR IsTextSent> current</cfif>">
					<form action = "index.cfm?event=loadMail&type=#variables.frieghtBroker#&loadid=#loadID#&dispatcherId=#url.dispatcherId#&totalCarrierCharges=#url.totalCarrierCharges#&#session.URLToken#" method="POST" style="margin-top: 10px;" enctype="multipart/form-data">
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
							<textarea style="width:500px;height:180px;" class="addressChange" rows="" name="body" id="body" cols=""><cfif not IsDefined("form.sendEmail")>#emailBody#<cfelse>#form.body#</cfif></textarea>
							<div class="clear"></div>
							<label style="margin-top: 3px;">Attach File(s):</label>
							<input style="width:500px;" type="file" name="attachments" id="attachments" multiple>
							<div class="clear"></div>
							<div style="width:auto;float: right;">
								<input type = "hidden" name = "IsTextSent" value="#IsTextSent#">
								<input type = "hidden" name = "IsEmailSent" value="#IsEmailSent#">
								<input type = "Submit" name = "sendEmail" value="Send">
							</div>
						</fieldset>
					</form> 
				</div>
			</cfif>
			<cfif NOT IsTextSent>
				<div id="tab-2" class="tab-content <cfif IsEmailSent OR IsDefined("form.sendText")> current</cfif>">
					 <form action = "index.cfm?event=loadMail&type=#variables.frieghtBroker#&loadid=#loadID#&dispatcherId=#url.dispatcherId#&totalCarrierCharges=#url.totalCarrierCharges#&#session.URLToken#" method="POST" style="margin-top: 10px;">
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
									<input type = "Submit" name = "sendText" value="Send">
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

<script type="text/javascript">
	$(document).ready(function(){
	
		$('ul.tabs li').click(function(){
			var tab_id = $(this).attr('data-tab');

			$('ul.tabs li').removeClass('current');
			$('.tab-content').removeClass('current');

			$(this).addClass('current');
			$("##"+tab_id).addClass('current');
		})
		countCharacters();

	});
	function countCharacters(){ 
		$("##charcount").text($("##tab-2 ##body").val().length);		
	}
</script>
</html>
</cfoutput>