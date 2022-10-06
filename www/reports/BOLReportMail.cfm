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
<cfinvoke component="#variables.objloadGateway#" method="getLoadCarriersMails" loadid="#loadID#" returnvariable="request.qcarriers" />
<cfinvoke component="#variables.objloadGateway#" method="getcurAgentMaildetails" returnvariable="request.qcurAgentdetails" employeID="#session.empid#" />
<cfset SmtpAddress=request.qcurAgentdetails.SmtpAddress>
<cfset SmtpUsername=request.qcurAgentdetails.SmtpUsername>
<cfset SmtpPort=request.qcurAgentdetails.SmtpPort>
<cfset SmtpPassword=request.qcurAgentdetails.SmtpPassword>
<cfset FA_SSL=request.qcurAgentdetails.useSSL>
<cfset FA_TLS=request.qcurAgentdetails.useTLS>
<cfset MailFrom=request.qcurAgentdetails.EmailID>
<cfset MailTo=request.qcarriers>
<cfset Subject = request.qGetSystemSetupOptions.BOLHead>
<cfset emailSignature = request.qcurAgentdetails.emailSignature>
<cfif request.qGetSystemSetupOptions.IsIncludeLoadNumber EQ 1>
	<cfset includeLoadNumber = true>
<cfelse>
	<cfset includeLoadNumber = false>	
</cfif>	
<cfif IsDefined("form.send")>
	<cfif form.MailTo is not "" AND form.MailFrom is not "" AND form.Subject is not "">
			<cfquery name="BOLReport" datasource="#application.dsn#">
        SELECT         l.LoadID, l.LoadNumber, l.CustomerPONo AS RefNo, l.Address AS custaddress, l.City AS custcity, l.StateCode AS custstate, l.PostalCode AS custpostalcode, 
                         l.Phone AS custphone, l.Fax AS custfax, l.CellNo AS custcell, l.CustName AS custname, l.EmergencyResponseNo, l.CODAmt, l.CODFee, l.DeclaredValue, l.Notes,

                        CASE WHEN (LEN(TRIM(stops.shipperStopName)) = 0 AND LEN(TRIM(stops.shipperLocation)) = 0 AND LEN(TRIM(stops.shipperCity)) = 0 AND LEN(TRIM(stops.ShipperState)) = 0 AND LEN(TRIM(stops.ShipperState)) = 0 )
                         THEN
                            FirstPick.shipperState
                         ELSE
                         stops.shipperState
                         END AS shipperState,
                         CASE WHEN (LEN(TRIM(stops.shipperStopName)) = 0 AND LEN(TRIM(stops.shipperLocation)) = 0 AND LEN(TRIM(stops.shipperCity)) = 0 AND LEN(TRIM(stops.ShipperState)) = 0 AND LEN(TRIM(stops.ShipperState)) = 0 )
                         THEN
                            FirstPick.shipperCity
                         ELSE
                         stops.shipperCity
                         END AS shipperCity,
                         stops.consigneeState, stops.consigneeCity, carr.CarrierName, stops.LoadStopID, stops.StopNo, 
                         stops.shipperStopDate AS PickupDate, stops.shipperStopTime AS PickupTime, stops.consigneeStopDate AS DeliveryDate, stops.consigneeStopTime AS DeliveryTime, 
                        CASE WHEN (LEN(TRIM(stops.shipperStopName)) = 0 AND LEN(TRIM(stops.shipperLocation)) = 0 AND LEN(TRIM(stops.shipperCity)) = 0 AND LEN(TRIM(stops.ShipperState)) = 0 AND LEN(TRIM(stops.ShipperState)) = 0 )
                         THEN
                            FirstPick.shipperStopName
                         ELSE
                         stops.shipperStopName
                         END AS shipperStopName,
                         stops.consigneeStopName,
                         CASE WHEN (LEN(TRIM(stops.shipperStopName)) = 0 AND LEN(TRIM(stops.shipperLocation)) = 0 AND LEN(TRIM(stops.shipperCity)) = 0 AND LEN(TRIM(stops.ShipperState)) = 0 AND LEN(TRIM(stops.ShipperState)) = 0 )

                         THEN
                            FirstPick.shipperLocation
                         ELSE
                         stops.shipperLocation
                         END AS shipperLocation,
                         stops.consigneeLocation, stops.shipperPostalCode, stops.consigneePostalCode, 
                        CASE WHEN (LEN(TRIM(stops.shipperStopName)) = 0 AND LEN(TRIM(stops.shipperLocation)) = 0 AND LEN(TRIM(stops.shipperCity)) = 0 AND LEN(TRIM(stops.ShipperState)) = 0 AND LEN(TRIM(stops.ShipperState)) = 0 )

                         THEN
                            FirstPick.shipperContactPerson
                         ELSE
                         stops.shipperContactPerson
                         END AS shipperContactPerson,
                         stops.consigneeContactPerson, 
                         CASE WHEN (LEN(TRIM(stops.shipperStopName)) = 0 AND LEN(TRIM(stops.shipperLocation)) = 0 AND LEN(TRIM(stops.shipperCity)) = 0 AND LEN(TRIM(stops.ShipperState)) = 0 AND LEN(TRIM(stops.ShipperState)) = 0 )

                         THEN
                            FirstPick.shipperPhone
                         ELSE
                         stops.shipperPhone
                         END AS shipperPhone,
                         CASE WHEN (LEN(TRIM(stops.shipperStopName)) = 0 AND LEN(TRIM(stops.shipperLocation)) = 0 AND LEN(TRIM(stops.shipperCity)) = 0 AND LEN(TRIM(stops.ShipperState)) = 0 AND LEN(TRIM(stops.ShipperState)) = 0 )

                         THEN
                            FirstPick.shipperPhoneExt
                         ELSE
                         stops.shipperPhoneExt
                         END AS shipperPhoneExt,
                         stops.consigneePhone, 
                         stops.consigneePhoneExt, 
                        CASE WHEN (LEN(TRIM(stops.shipperStopName)) = 0 AND LEN(TRIM(stops.shipperLocation)) = 0 AND LEN(TRIM(stops.shipperCity)) = 0 AND LEN(TRIM(stops.ShipperState)) = 0 AND LEN(TRIM(stops.ShipperState)) = 0 )

                         THEN
                            FirstPick.shipperFax
                         ELSE
                         stops.shipperFax
                         END AS shipperFax,
                         stops.consigneeFax, 
                         stops.shipperEmailID, stops.consigneeEmailID, stops.shipperBlind, stops.consigneeBlind, stops.shipperDriverName, stops.consigneeDriverName, BOL.SrNo, 
                         ISNULL(BOL.Qty, 0) AS Qty, BOL.Description, ISNULL(BOL.Weight, 0) AS Weight, BOL.classid, BOL.Hazmat, BOL.LoadStopIDBOL, CarrierTerms.CarrierTerms, 
                         dbo.Companies.CompanyName, dbo.Companies.address, dbo.Companies.address2, dbo.Companies.city, dbo.Companies.state, dbo.Companies.zipCode,CASE WHEN ISNULL(dbo.Employees.Telephone ,'') = '' THEN case when isnull(offi.ContactNo ,'') = '' then dbo.Companies.phone else offi.ContactNo End ELSE dbo.Employees.Telephone END as Phone
                         ,case when isnull(dbo.Companies.fax ,'') = '' then dbo.Companies.fax
                         else offi.faxno End as fax,dbo.Companies.CompanyCode,(SELECT CompanyLogoName
                               FROM            dbo.SystemConfig where companyID = <cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar">) AS CompanyLogoName,consigneeReleaseNo,shipperReleaseNo
FROM            dbo.Loads AS l 

INNER JOIN
                         dbo.Employees ON L.DispatcherID = dbo.Employees.EmployeeID
LEFT OUTER JOIN
                             (SELECT        a.LoadID, a.LoadStopID, a.StopNo, a.NewCarrierID, a.NewOfficeID, a.City AS shipperCity, b.City AS consigneeCity, a.CustName AS shipperStopName, 
                                                         b.CustName AS consigneeStopName, a.Address AS shipperLocation, b.Address AS consigneeLocation, a.PostalCode AS shipperPostalCode, 
                                                         b.PostalCode AS consigneePostalCode, a.ContactPerson AS shipperContactPerson, b.ContactPerson AS consigneeContactPerson, 
                                                         a.Phone AS shipperPhone, b.Phone AS consigneePhone,a.PhoneExt AS shipperPhoneExt, b.PhoneExt AS consigneePhoneExt, a.Fax AS shipperFax, b.Fax AS consigneeFax, a.EmailID AS shipperEmailID, 
                                                         b.EmailID AS consigneeEmailID, a.StopDate AS shipperStopDate, b.StopDate AS consigneeStopDate, a.StopTime AS shipperStopTime, 
                                                         b.StopTime AS consigneeStopTime, a.TimeIn AS shipperStopTimeIn, b.TimeIn AS consigneeStopTimeIn, a.TimeOut AS shipperStopTimeOut, 
                                                         b.TimeOut AS consigneeStopTimeOut, a.ReleaseNo AS shipperReleaseNo, b.ReleaseNo AS consigneeReleaseNo, a.Blind AS shipperBlind, 
                                                         b.Blind AS consigneeBlind, a.Instructions AS shipperInstructions, b.Instructions AS consigneeInstructions, a.Directions AS shipperDirections, 
                                                         b.Directions AS consigneeDirections, a.LoadStopID AS shipperLoadStopID, b.LoadStopID AS consigneeLoadStopID, 
                                                         a.NewBookedWith AS shipperBookedWith, b.NewBookedWith AS consigneeBookedWith, a.NewEquipmentID AS shipperEquipmentID, 
                                                         b.NewEquipmentID AS consigneeEquipmentID, a.NewDriverName AS shipperDriverName, b.NewDriverName AS consigneeDriverName, 
                                                         a.NewDriverCell AS shipperDriverCell, b.NewDriverCell AS consigneeDriverCell, a.NewTruckNo AS shipperTruckNo, 
                                                         b.NewTruckNo AS consigneeTruckNo, a.NewTrailorNo AS shipperTrailorNo, b.NewTrailorNo AS consigneeTrailorNo, a.RefNo AS shipperRefNo, 
                                                         b.RefNo AS consigneeRefNo, a.Miles AS shipperMiles, b.Miles AS consigneeMiles, a.CustomerID AS shipperCustomerID, 
                                                         b.CustomerID AS consigneeCustomerID, a.StateCode AS shipperState, b.StateCode AS consigneeState
                               FROM            dbo.LoadStops AS a INNER JOIN
                                                         dbo.LoadStops AS b ON a.LoadID = b.LoadID AND a.StopNo = b.StopNo
                               WHERE        (a.LoadID = <cfqueryparam value="#url.loadid#" cfsqltype="cf_sql_varchar">) AND (a.LoadType = 1) AND (b.LoadType = 2)) AS stops ON 
                         stops.LoadID = l.LoadID LEFT OUTER JOIN
                          ( SELECT c.LoadID,c.CustName AS shipperStopName, c.Address AS shipperLocation,c.City AS shipperCity,c.StateCode AS shipperState,c.PostalCode AS shipperPostalCode,c.Phone AS shipperPhone,c.PhoneExt AS shipperPhoneExt,c.Fax AS shipperFax, c.ContactPerson AS shipperContactPerson  FROM dbo.LoadStops AS c WHERE c.LoadID = <cfqueryparam value="#url.loadid#" cfsqltype="cf_sql_varchar"> AND c.StopNo = 0 AND c.LoadType = 1   ) AS FirstPick ON FirstPick.LoadID = l.LoadID LEFT OUTER JOIN
                             (SELECT        CarrierID, CarrierName
                               FROM            dbo.Carriers) AS carr ON carr.CarrierID = stops.NewCarrierID LEFT OUTER JOIN
                             (SELECT        CarrierTerms
                               FROM            dbo.SystemConfig where companyID = <cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar">) AS CarrierTerms ON 1 = 1 
                            <cfif request.qGetSystemSetupOptions.UseNonFeeAccOnBOL EQ 1>
                                LEFT OUTER JOIN
                                (SELECT ISNULL(dbo.LoadStopCommodities.SrNo, '') AS SrNo, ISNULL(dbo.LoadStopCommodities.Qty, 0) AS Qty, ISNULL(dbo.LoadStopCommodities.Description, '') AS Description, 
                                                         ISNULL(dbo.LoadStopCommodities.Weight, 0) AS Weight, dbo.CommodityClasses.ClassName AS classid,'' AS Hazmat, 
                                                        '#url.LoadID#' AS LoadStopIDBOL,
                                                        dbo.LoadStopCommodities.LoadStopID AS LoadStopID
                                                        ,dbo.LoadStopCommodities.FEE
                                FROM            dbo.LoadStopCommodities LEFT OUTER JOIN
                                                         dbo.CommodityClasses ON dbo.LoadStopCommodities.ClassID = dbo.CommodityClasses.ClassID) AS BOL ON BOL.FEE=0 AND BOL.LoadStopID = stops.LoadStopID and (len(bol.Description) <> 0 or bol.qty>0 or bol.weight > 0  or len(bol.classid) <> 0 or len(bol.Hazmat) <> 0)

                            <cfelse>
                                LEFT OUTER JOIN
                                (SELECT        ISNULL(dbo.LoadStopsBOL.SrNo, '') AS SrNo, ISNULL(dbo.LoadStopsBOL.Qty, 0) AS Qty, ISNULL(dbo.LoadStopsBOL.Description, '') AS Description, 
                                                         ISNULL(dbo.LoadStopsBOL.Weight, 0) AS Weight, dbo.CommodityClasses.ClassName AS classid, ISNULL(dbo.LoadStopsBOL.Hazmat, '') AS Hazmat, 
                                                         dbo.LoadStopsBOL.loadStopIdBOL AS LoadStopIDBOL
                                FROM            dbo.LoadStopsBOL LEFT OUTER JOIN
                                                         dbo.CommodityClasses ON dbo.LoadStopsBOL.ClassID = dbo.CommodityClasses.ClassID) AS BOL ON BOL.LoadStopIDBOL = l.LoadID and (len(bol.Description) <> 0 or bol.qty>0 or bol.weight > 0  or len(bol.classid) <> 0 or len(bol.Hazmat) <> 0)
                            </cfif>
                             left outer join
                         dbo.Companies on dbo.Companies.companyID = <cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar"> left outer join (select top 1 ContactNo,FaxNo,officeid,companyID from offices where companyID = <cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar">) as offi  on offi.companyID=Companies.companyID
WHERE        (l.LoadID = <cfqueryparam value="#url.loadid#" cfsqltype="cf_sql_varchar">) AND dbo.Companies.companyID = <cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar">
ORDER BY l.LoadNumber ,StopNo
    </cfquery>
		<cfoutput>
			<!--- <cfreport name="genPDF" format="PDF" template="BOLReport.cfr" query="#BOLReport#"> 
				<cfreportParam name="ReportDate" value="#DateFormat(Now(),'mm/dd/yyyy')#"> 
			</cfreport>
         <cfif application.dsn neq "LoadManagerLive"> --->
            <cfinvoke component="#variables.objloadGatewaynew#" method="getBOLReport" LoadID = "#url.LoadID#" CompanyID="#session.companyID#" returnvariable="qBOLReport" />
            <cfif len(trim(qBOLReport.CompanyCode)) and directoryExists(expandPath("../reports/#trim(qBOLReport.CompanyCode)#")) and fileExists(expandPath("../reports/#trim(qBOLReport.CompanyCode)#/BOLReport.cfm"))>
               <cfinclude template="#trim(qCustomerReport.CompanyCode)#/BOLReport.cfm">
            <cfelse>
               <cfinclude template="BOLReport.cfm">
               <cfset genPDF = BOLReport>
               <cfset BOLReport = qBOLReport>
            </cfif>
         <!--- </cfif> --->
			<cftry>
				<cfif request.qGetCompanyInformation.ccOnEmails EQ true>
					<cfmail from='"#SmtpUsername#" <#SmtpUsername#>' subject="#form.Subject#" to="#form.MailTo#" CC="#request.qGetCompanyInformation.email#" type="text/plain" server="#SmtpAddress#" username="#SmtpUsername#" password="#SmtpPassword#" port="#SmtpPort#" usessl="#FA_SSL#" usetls="#FA_TLS#" >
					#form.body#
						<cfmailparam
							file="#BOLReport.LoadNumber#.BOLReport.pdf"
							type="application/pdf"
							content="#genPDF#"
						/>
					</cfmail>
				<cfelse>
					<cfmail from='"#SmtpUsername#" <#SmtpUsername#>' subject="#form.Subject#" to="#form.MailTo#" type="text/plain" server="#SmtpAddress#" username="#SmtpUsername#" password="#SmtpPassword#" port="#SmtpPort#" usessl="#FA_SSL#" usetls="#FA_TLS#" >
					#form.body#
					 <cfmailparam
						file="#BOLReport.LoadNumber#.BOLReport.pdf"
						type="application/pdf"
						content="#genPDF#"
						/>

					</cfmail>
				</cfif>
				<cfinvoke component="#variables.objloadGateway#" method="setLogMails" loadID="#loadID#" date="#Now()#" subject="#form.Subject#" emailBody="#form.body#" reportType="BOL" fromAddress="#SmtpUsername#" toAddress="#form.MailTo#" />
				<cfsavecontent variable="content">
					<div id="message" class="msg-area" style="width: 100%;display:block;"><p>Thank you, <cfoutput>#form.MailFrom#: your message has been sent</cfoutput>.</p></div>
				</cfsavecontent>
				<script>
					setTimeout(function(){ 
						window.close(); 
					}, 2000);				
				</script>
				<cfcatch>
					<cfsavecontent variable="content">
						<div id="message" class="msg-area" style="width: 100%;display:block;background: none repeat scroll 0 0 ##f4cbc8;border: 1px solid ##f2867a;"><p>The mail is not sent.</p></div>
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
<form action = "index.cfm?event=loadMail&type=BOL&loadid=#loadID#&#session.URLToken#" method="POST">
	<div class="white-mid" style=" border-top: 5px solid rgb(130, 187, 239);width: 100%;">
		<div class="form-con" style="width:auto;">
			<cfif includeLoadNumber>
				<cfif structkeyexists(url,"loadid") AND len(trim(url.loadid)) GT 0>
					<cfquery name="getLoadNumber" datasource="#Application.dsn#">
						SELECT LoadNumber FROM vwCarrierRateConfirmation
							WHERE  (LoadID =  <cfqueryparam value="#url.LoadID#" cfsqltype="cf_sql_varchar">)
					</cfquery>	
					<cfset Subject = Subject &' - Load## #getLoadNumber.LoadNumber#' />	
				</cfif>
			</cfif>
			<fieldset>
			<div style="color:##000000;font-size:14px;font-weight:bold;margin-bottom:20px;margin-top:10px;">BOL Report Mail</div>
			<div class="clear"></div>
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
			<textarea style="width:500px;height:180px;" class="addressChange" rows="" name="body" id="body" cols="">#body# <cfif not IsDefined("form.send")>&##13;&##10;#emailSignature#</cfif></textarea>
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