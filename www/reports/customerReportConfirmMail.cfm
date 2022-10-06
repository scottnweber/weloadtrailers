<cfparam name="url.loadid" default="0">
<cfparam name="url.customerID" default="">
<cfparam name="MailTo" default="">
<cfparam name="MailFrom" default="">
<cfparam name="Subject" default="">
<cfparam name="body" default="">
<cfparam name="emailSignature" default="">
<cfset loadID = "">
<cfset customerID = "">
<cfset loadStatus = "">

<cfif  structkeyexists(url,"loadid") and len(trim(url.loadid)) gt 1>
	<cfset loadID = url.loadid>
	<cfinvoke component="#variables.objloadGateway#" method="getAllLoads" loadid="#loadID#" stopNo="0" returnvariable="request.qLoads" />
	<cfset loadStatus=request.qLoads.statustext>
</cfif>
<cfif len(trim(request.qLoads.contactemail))>
	<cfset MailTo = trim(request.qLoads.contactemail)>
</cfif>
<cfif  structkeyexists(url,"customerID") and len(trim(url.customerID)) gt 1>
	<cfset customerID = url.customerID>
	<cfquery name="careerReport" datasource="#Application.dsn#">
		SELECT Email FROM CustomerContacts  
		WHERE customerID=<cfqueryparam value="#customerID#" cfsqltype="cf_sql_varchar"> AND ContactType ='Billing'
	</cfquery>
	<cfset MailTo = listAppend(MailTo, valuelist(careerReport.Email,";"),";")>
</cfif>
<cfset MailTo = listRemoveDuplicates(MailTo,";")>
<cfinvoke component="#variables.objloadGateway#" method="getCompanyInformation" returnvariable="request.qGetCompanyInformation" />
<cfinvoke component="#variables.objloadGateway#" method="getSystemSetupOptions" returnvariable="request.qGetSystemSetupOptions" />
<cfinvoke component="#variables.objloadGateway#" method="getcurAgentMaildetails" returnvariable="request.qcurAgentdetails" employeID="#session.empid#" />
<cfset SmtpAddress=request.qcurAgentdetails.SmtpAddress>
<cfset SmtpUsername=request.qcurAgentdetails.SmtpUsername>
<cfset SmtpPort=request.qcurAgentdetails.SmtpPort>
<cfset SmtpPassword=request.qcurAgentdetails.SmtpPassword>
<cfset FA_SSL=request.qcurAgentdetails.useSSL>
<cfset FA_TLS=request.qcurAgentdetails.useTLS>
<cfset MailFrom=request.qcurAgentdetails.EmailID>
<cfset Subject = request.qGetSystemSetupOptions.CustInvHead>
<cfset emailSignature = request.qcurAgentdetails.emailSignature>
<cfset variables.status=''>
<cfif loadStatus eq '0. QUOTE'>
	<cfset variables.status='Rate Quote'>				
<cfelseif (loadStatus eq '1. ACTIVE')>
	<cfset variables.status='Rate Confirmation'>						
<cfelseif (loadStatus eq '2. BOOKED') or (loadStatus eq '3. DISPATCHED') or(loadStatus eq '4. LOADED') or(loadStatus eq '5. DELIVERED') or (loadStatus eq '4.1 ARRIVED') or (loadStatus eq '6. POD') or (loadStatus eq '7. INVOICE') or (loadStatus eq '7.1 PAID') or (loadStatus eq '8. COMPLETED') or (loadStatus eq '9. Cancelled')>
	<cfset variables.status='Invoice'>				
</cfif>	
<cfif request.qGetSystemSetupOptions.IsIncludeLoadNumber EQ 1>
	<cfset includeLoadNumber = true>
<cfelse>
	<cfset includeLoadNumber = false>	
</cfif>
<cfif IsDefined("form.send")>
	<cfinvoke component="#variables.objAgentGateway#" method="verifyMailServer" returnvariable="smtpStatus">
		<cfinvokeargument name="host" value="#SmtpAddress#">
		<cfinvokeargument name="protocol" value="smtp">
		<cfinvokeargument name="port" value=#SmtpPort#>
		<cfinvokeargument name="user" value="#SmtpUsername#">
		<cfinvokeargument name="password" value="#SmtpPassword#">
		<cfinvokeargument name="useTLS" value=#FA_TLS#>
		<cfinvokeargument name="useSSL" value=#FA_SSL#>
		<cfinvokeargument name="overwrite" value=false>
		<cfinvokeargument name="timeout" value=10000>
	</cfinvoke>
	<cfif NOT smtpStatus.WASVERIFIED>
		<cfset IsEmailSent = 1>
		<cfset smtpError = 1>
	<cfelseif form.MailTo is not "" AND form.MailFrom is not "" AND form.Subject is not "">
		<cfquery name="careerReport" datasource="#Application.dsn#">
			SELECT *, 
				(SELECT sum(weight)  from vwCarrierConfirmationReport 
				   <cfif structkeyexists(url,"loadno")>
						WHERE  (LoadNumber = <cfqueryparam value="#url.Loadno#" cfsqltype="cf_sql_varchar">)
					<cfelseif structkeyexists(url,"loadid")>
						WHERE  (LoadID = <cfqueryparam value="#url.LoadID#" cfsqltype="cf_sql_varchar">)
				   </cfif>
				 GROUP BY loadnumber) as TotalWeight 
			FROM vwCustomerInvoiceReport
		   <cfif structkeyexists(url,"loadno")>
				WHERE  (LoadNumber = <cfqueryparam value="#url.Loadno#" cfsqltype="cf_sql_varchar">)
			<cfelseif structkeyexists(url,"loadid")>
				WHERE  (LoadID = <cfqueryparam value="#url.LoadID#" cfsqltype="cf_sql_varchar">)
		   </cfif>
			   ORDER BY stopnum 
		</cfquery>
		<cfset dueDate = "">
		<cfif len(trim(careerReport.PaymentTerms)) AND careerReport.ReportTitle EQ 'Invoice'>
			<cfset arrMatch = rematch("NET[\d]+",replace(careerReport.PaymentTerms, " ", "","ALL"))>
			<cfif not arrayIsEmpty(arrMatch)>
				<cfset dueDays = replaceNoCase(arrMatch[1], "NET", "")>
				<cfset dueDate = dateAdd("d", dueDays, careerReport.BillDate)>
			</cfif>
		</cfif>
		<cfset careerReportNew = QueryNew(careerReport.columnList&",shipperStopNum,conStopNum,dueDate")> 
		<cfset QueryAddRow(careerReportNew, careerReport.recordcount)>
		<cfset indx = 0>
		<cfset prevStopID = "">
		<cfloop query="careerReport">
			<cfloop list="#careerReportNew.columnList#" index="key">
				<cfif not listFindNoCase("shipperStopNum,conStopNum,dueDate", key)>
					<cfset QuerySetCell(careerReportNew, key, evaluate("careerReport.#key#") , careerReport.currentrow)> 
					<cfif not len(trim(careerReport.totalweight))>
						<cfset QuerySetCell(careerReportNew, "totalweight", 0 , careerReport.currentrow)> 
					</cfif>
					<cfif not len(trim(careerReport.weight))>
						<cfset QuerySetCell(careerReportNew, "weight", 0 , careerReport.currentrow)> 
					</cfif>
					<cfif not len(trim(careerReport.Custcharges))>
						<cfset QuerySetCell(careerReportNew, "Custcharges", 0 , careerReport.currentrow)> 
					</cfif>
					<cfif not len(trim(careerReport.Carrcharges))>
						<cfset QuerySetCell(careerReportNew, "Carrcharges", 0 , careerReport.currentrow)> 
					</cfif>
				</cfif>
			</cfloop>
			<cfif (prevStopID NEQ careerReport.loadstopid) AND (len(trim(careerReport.shipperName)) OR len(trim(careerReport.ShipperAddress)) OR len(trim(careerReport.Shippercity)) OR len(trim(careerReport.Shipperstate)) OR len(trim(careerReport.Shipperzip)))>
				<cfset indx++>
				<cfset QuerySetCell(careerReportNew, "shipperStopNum", indx , careerReport.currentrow)> 
			</cfif>
			<cfif (prevStopID NEQ careerReport.loadstopid) AND (len(trim(careerReport.conName)) OR len(trim(careerReport.conAddress)) OR len(trim(careerReport.concity)) OR len(trim(careerReport.constate)) OR len(trim(careerReport.conzip)))>
				<cfset indx++>
				<cfset QuerySetCell(careerReportNew, "conStopNum", indx , careerReport.currentrow)> 
			</cfif>	
			<cfset QuerySetCell(careerReportNew, "dueDate", duedate , careerReport.currentrow)> 
			<cfset prevStopID = careerReport.loadstopid>
		</cfloop>

	
		<!--- Begin : DropBox Integration  ---->
		<cfquery name="qrygetSettingsForDropBox" datasource="#Application.dsn#">
			SELECT 
				DropBox,
				DropBoxAccessToken
			FROM SystemConfig  WHERE CompanyID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#session.CompanyID#" >
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
		
		<!--- End : DropBox Integration  ---->
		<cfset myPosition = find("Regards", form.body)>		
		<cfoutput>
			<!--- <cfset customPath = "">
			<cfquery name="qGetCompany" datasource="#Application.dsn#">
				select CompanyCode from Companies  WHERE CompanyID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#session.CompanyID#" >
			</cfquery>

			<cfif len(trim(qGetCompany.companycode)) and directoryExists(expandPath("../reports/#trim(qGetCompany.companycode)#"))>
				<cfset customPath = "#trim(qGetCompany.companycode)#">
			</cfif>
			<cfif len(trim(customPath)) and fileExists(expandPath("../reports/#trim(customPath)#/CustomerInvoiceReport.cfr"))>
				<cfset tempRootPath = expandPath("../reports/#trim(customPath)#/CustomerInvoiceReport.cfr")>
			<cfelse>
				<cfset tempRootPath = expandPath("../reports/CustomerInvoiceReport.cfr")>
			</cfif>
			<cfreport name="genPDF" format="PDF" template="#tempRootPath#" style="../webroot/styles/reportStyle.css" query="#careerReportNew#"> 
				<cfreportParam name="ReportDate" value="#DateFormat(Now(),'mm/dd/yyyy')#"> 
			</cfreport> --->

			<!--- <cfif application.dsn NEQ "LoadManagerLive"> --->
				<cfinvoke component="#variables.objloadGateway#" method="getCustomerReport" LoadID = "#url.LoadID#" returnvariable="qCustomerReport" />
				<cfif len(trim(qCustomerReport.CompanyCode)) and directoryExists(expandPath("../reports/#trim(qCustomerReport.CompanyCode)#")) and fileExists(expandPath("../reports/#trim(qCustomerReport.CompanyCode)#/CustomerInvoice.cfm"))>
					<cfinclude template="#trim(qCustomerReport.CompanyCode)#/CustomerInvoice.cfm">
				<cfelse>
					<cfinclude template="CustomerInvoice.cfm">
				</cfif>
				<cfset genPDF = CustomerDocumentReport>
			<!--- </cfif> --->

			<cftry>
				<cfif request.qGetCompanyInformation.ccOnEmails EQ true>
					<cfmail from='"#SmtpUsername#" <#SmtpUsername#>' subject="#form.Subject#" to="#form.MailTo#"  CC="#request.qGetCompanyInformation.email#" type="text/html" server="#SmtpAddress#" username="#SmtpUsername#" password="#SmtpPassword#" port="#SmtpPort#" usessl="#FA_SSL#" usetls="#FA_TLS#" >
				#form.body#
				
						 <cfmailparam
							file="#careerReport.loadnumber# #variables.status#.pdf"
							type="application/pdf"
							content="#genPDF#"
							/>
							<!--- See if the check box on the email form for including billing documents is checked --->
							<cfif structkeyexists(form,"billingDocument")>
								
								<!--- Loop through the attachment records for this load where the attached is marked as a billing document] --->
								<cfquery name="qrygetFileAttachments" datasource="#Application.dsn#">
									select * from FileAttachments where linked_Id=<cfqueryparam cfsqltype="cf_sql_varchar" value="#url.loadid#"> and	BILLINGATTACHMENTS=<cfqueryparam cfsqltype="cf_sql_bit" value="1">
							   </cfquery>	
							   <!--- Begin : DropBox Integration  ---->
							
									<cfif qrygetFileAttachments.recordcount>
										<cfloop query="qrygetFileAttachments">
											<cfif  qrygetFileAttachments.DropBoxFile EQ 0   AND FileExists(expandpath('../')&'fileupload\img\#request.qGetCompanyInformation.CompanyCode#\#qrygetFileAttachments.attachmentFileName#')>
												<cfset variables.path=expandpath('../')&'fileupload\img\#request.qGetCompanyInformation.CompanyCode#\#qrygetFileAttachments.attachmentFileName#'>
													<cfmailparam disposition="attachment" 
												file="#variables.path#" type ="application/msword,application/docx,application/pdf,application/octet-stream,application/msword,text/plain,binary/octet-stream, image/pjpeg,  image/gif, application/vnd.openxmlformats-officedocument.wordprocessingml.document, application/vnd.ms-word.document.12, application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"/>
											<cfelseif qrygetFileAttachments.DropBoxFile EQ 1>
												<cfhttp
														method="POST"
														url="https://api.dropboxapi.com/2/sharing/create_shared_link"	
														result="returnStruct"> 
																<cfhttpparam type="HEADER" name="Authorization" value="Bearer #qrygetCommonDropBox.DropBoxAccessToken#">	
																<cfhttpparam type="HEADER" name="Content-Type" value="application/json">	
																<cfhttpparam type="body" value='{"path":#SerializeJSON('/fileupload/img/#request.qGetCompanyInformation.CompanyCode#/' & qrygetFileAttachments.attachmentFileName)#}'>
												</cfhttp>										
												<cfset FileUrl = "">
												<cfif returnStruct.Statuscode EQ "200 OK">
													<cfset FileUrl = deserializeJSON(returnStruct.fileContent).url.Split('\?')[1] & '?raw=1'>
													
													<cfhttp url="#FileUrl#" method="get" result="tempFile"></cfhttp>
												</cfif>
												
												<cfif FileUrl NEQ "">
													<cfif NOT IsSimpleValue(tempFile.Filecontent)>
														<cfset content = tempFile.Filecontent.toByteArray()>
													<cfelse>
														<cfset content = tempFile.Filecontent>
													</cfif>
													<cfmailparam disposition="attachment" 
													content="#content#" 
													file="#qrygetFileAttachments.attachmentFileName#" type ="application/msword,application/docx,application/pdf,application/octet-stream,application/msword,text/plain,binary/octet-stream, image/pjpeg,  image/gif, application/vnd.openxmlformats-officedocument.wordprocessingml.document, application/vnd.ms-word.document.12, application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"/>	
												</cfif>	
											 </cfif>
										</cfloop>
									</cfif>
								
								<!--- End : DropBox Integration  ---->
							   
							</cfif>	
					</cfmail>
				<cfelse>
					<cfmail from='"#SmtpUsername#" <#SmtpUsername#>' subject="#form.Subject#"   to="#form.MailTo#"  <!---type="text/plain"---->  type="text/html"  server="#SmtpAddress#" username="#SmtpUsername#" password="#SmtpPassword#" port="#SmtpPort#" usessl="#FA_SSL#" usetls="#FA_TLS#" >
				#form.body#
			
						 <cfmailparam
							file="#careerReport.loadnumber# #variables.status#.pdf"
							type="application/pdf"
							content="#genPDF#"
							/>
						
								<cfif structkeyexists(form,"billingDocument")>
									<cfquery name="qrygetFileAttachments" datasource="#Application.dsn#">
										select * from FileAttachments where linked_Id=<cfqueryparam cfsqltype="cf_sql_varchar" value="#url.loadid#"> and	BILLINGATTACHMENTS=<cfqueryparam cfsqltype="cf_sql_bit" value="1">
								   </cfquery>	
								   <cfif qrygetFileAttachments.recordcount>
										<cfloop query="qrygetFileAttachments">
											<cfif  qrygetFileAttachments.DropBoxFile EQ 0  AND FileExists(expandpath('../')&'fileupload\img\#request.qGetCompanyInformation.CompanyCode#\#qrygetFileAttachments.attachmentFileName#')>
												<cfset variables.path=expandpath('../')&'fileupload\img\#request.qGetCompanyInformation.CompanyCode#\#qrygetFileAttachments.attachmentFileName#'>
													<cfmailparam disposition="attachment" 
												file="#variables.path#" type ="application/msword,application/docx,application/pdf,application/octet-stream,application/msword,text/plain,binary/octet-stream, image/pjpeg,  image/gif, application/vnd.openxmlformats-officedocument.wordprocessingml.document, application/vnd.ms-word.document.12, application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"/>
											<cfelseif qrygetFileAttachments.DropBoxFile EQ 1>
												<cfhttp
														method="POST"
														url="https://api.dropboxapi.com/2/sharing/create_shared_link"	
														result="returnStruct"> 
																<cfhttpparam type="HEADER" name="Authorization" value="Bearer #qrygetCommonDropBox.DropBoxAccessToken#">	
																<cfhttpparam type="HEADER" name="Content-Type" value="application/json">	
																<cfhttpparam type="body" value='{"path":#SerializeJSON('/fileupload/img/#request.qGetCompanyInformation.CompanyCode#/' & qrygetFileAttachments.attachmentFileName)#}'>
												</cfhttp>												
												<cfset FileUrl = "">
												<cfif returnStruct.Statuscode EQ "200 OK">
													<cfset FileUrl = deserializeJSON(returnStruct.fileContent).url.Split('\?')[1] & '?raw=1'>
													
													<cfhttp url="#FileUrl#" method="get" result="tempFile"></cfhttp>
												</cfif>
												
												<cfif FileUrl NEQ "">
													<cfif NOT IsSimpleValue(tempFile.Filecontent)>
														<cfset content = tempFile.Filecontent.toByteArray()>
													<cfelse>
														<cfset content = tempFile.Filecontent>
													</cfif>
													<cfmailparam disposition="attachment" 
													content="#content#" 
													file="#qrygetFileAttachments.attachmentFileName#" type ="application/msword,application/docx,application/pdf,application/octet-stream,application/msword,text/plain,binary/octet-stream, image/pjpeg,  image/gif, application/vnd.openxmlformats-officedocument.wordprocessingml.document, application/vnd.ms-word.document.12, application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"/>	
												</cfif>	
											 </cfif>
										</cfloop>

									</cfif>
								</cfif>	
							
					</cfmail>
				
				</cfif>	
				<cfinvoke component="#variables.objloadGateway#" method="setLogMails" loadID="#loadID#" date="#Now()#" subject="#form.Subject#" emailBody="#form.body#" reportType="customer" fromAddress="#SmtpUsername#" toAddress="#form.MailTo#" />
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
							window.opener.document.getElementById('dispatchHiddenValue').value="Emailed #variables.status# >";
							window.opener.document.getElementById('dispatchNotes').prepend(clock()+' - '+ window.opener.document.getElementById('Loggedin_Person').value+ ' > Emailed #variables.status# Report > \n');
						}	
						window.close(); 
					}, 2000);				
				</script>
				<cfcatch>
					<cfsavecontent variable="content">
						<div id="message" class="msg-area" style="width: 100%;display:block;background: none repeat scroll 0 0 ##f4cbc8;border: 1px solid ##f2867a;"><p><cfdump var="#cfcatch#"></p></div>
						
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
</style>
<script type="text/javascript">
	
		$(document).ready(function(){
			$('##body').focus();
			<cfif isdefined('smtpError')>
				alert('The email was not sent, please check your email settings.');
			</cfif>
		})
	
</script>
</head>
<body>
 

<cfif isDefined('content')>
#content#
</cfif>
<p> 
<form action = "index.cfm?event=loadMail&type=customer&customerID=#customerID#&loadid=#loadID#&#session.URLToken#" method="POST">
	<div class="white-mid" style="width: 100%;">
		<h1 style="color:white;font-weight:bold;background-color: ##82bbef;padding-left: 10px;">
			#variables.status# Mail
		</h1>
		<div class="form-con" style="width:auto;">
			<cfif includeLoadNumber>
				<cfif structkeyexists(url,"loadno") AND len(trim(url.loadno)) GT 0>
					<cfset Subject = Subject &' - Load## #url.loadno#' />
				<cfelseif structkeyexists(url,"loadid") AND len(trim(url.loadid)) GT 0>
					<cfquery name="getLoadNumber" datasource="#Application.dsn#">
						SELECT LoadNumber FROM vwCarrierRateConfirmation
							WHERE  (LoadID = <cfqueryparam value="#url.LoadID#" cfsqltype="cf_sql_varchar">)
					</cfquery>	
					<cfset Subject = Subject &' - Load## #getLoadNumber.LoadNumber#' />	
				</cfif>
			</cfif>
			<fieldset>
			<div class="clear"></div>
			<cfif variables.status eq 'Invoice'>
				<input id="billingDocument" class="" type="checkbox" value="" name="billingDocument" style="width: 10px; margin-left: 95px;" checked>
				<span style="font-size: 12px;">	Include all billing documents as attachments </span>
				<div class="clear"></div>
				<cfquery name="qrygetSettingsForDropBox" datasource="#Application.dsn#">
					SELECT 
						DropBox,
						DropBoxAccessToken
					FROM SystemConfig  WHERE CompanyID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#session.CompanyID#" >
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
				<cfquery name="qGetCompany" datasource="#Application.dsn#">
					select CompanyCode from Companies  WHERE CompanyID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#session.CompanyID#" >
				</cfquery>
				<cfquery name="qrygetFileAttachments" datasource="#Application.dsn#">
					select * from FileAttachments where linked_Id=<cfqueryparam cfsqltype="cf_sql_varchar" value="#url.loadid#"> and BILLINGATTACHMENTS=<cfqueryparam cfsqltype="cf_sql_bit" value="1">
			    </cfquery>
			    <b style="margin-left: 110px;text-decoration: underline;">Billing Documents:</b>
			    <a style="text-decoration: underline;" href="index.cfm?event=CustomerInvoiceReport&loadid=#url.loadid#&#session.URLToken#" target="_blank">Invoice</a><cfif qrygetFileAttachments.recordcount>, </cfif>
			    <cfloop query="#qrygetFileAttachments#">
			    	<cfif dropboxfile eq 1>
						<cfhttp
								method="POST"
								url="https://api.dropboxapi.com/2/sharing/create_shared_link"	
								result="returnStruct"> 
										<cfhttpparam type="HEADER" name="Authorization" value="Bearer #qrygetCommonDropBox.DropBoxAccessToken#">	
										<cfhttpparam type="HEADER" name="Content-Type" value="application/json">	
										<cfhttpparam type="body" value='{"path":#SerializeJSON('/fileupload/img/#qGetCompany.CompanyCode#/' & qrygetFileAttachments.attachmentFileName)#}'>
						</cfhttp> 
						<cfset filePath = "">
						<cfif returnStruct.Statuscode EQ "200 OK">
							<cfset filePath = deserializeJSON(returnStruct.fileContent).url.Split('\?')[1] & '?raw=1'>
						</cfif>	
					<cfelse>
						<cfset filePath = expandPath('../fileupload/img/#qrygetFileAttachments.attachmentFileName#')>
					</cfif>
			    	<a style="text-decoration: underline;" href="#filePath#" target="_blank"><cfif len(trim(qrygetFileAttachments.attachedFileLabel))>#qrygetFileAttachments.attachedFileLabel#<cfelse>#qrygetFileAttachments.attachmentFileName#</cfif></a><cfif qrygetFileAttachments.currentrow NEQ qrygetFileAttachments.recordcount>, </cfif>
			    </cfloop>
			    <div class="clear"></div>
			</cfif>	
			<div class="clear" style="margin-top: 10px;"></div>
			<label style="margin-top: 3px;">To:</label>
			<input style="width:500px;" type="Text" name="MailTo" class="mid-textbox-1" id="MailTo" value="#MailTo#">
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
			<textarea style="width:500px;height:180px;" class="addressChange" rows="" name="body" id="body" cols="">#body#	 <cfif not IsDefined("form.send")>&##13;&##10;#emailSignature#</cfif></textarea>
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
</body> 
</html>
</cfoutput>