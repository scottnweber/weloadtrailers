<cfif server.coldfusion.productversion CONTAINS '2021'>
    <cflocation url="https://#cgi.HTTP_HOST#/#trim(listFirst(cgi.SCRIPT_NAME,'/'))#/www/webroot/index.cfm?event=BOLReportShortPrint&#cgi.QUERY_STRING#">
</cfif> 
<cfoutput>
<cfif structkeyExists(url,"dsn")>
<!--- Decrypt String --->
<cfset TheKey = 'NAMASKARAM'>
<cfset dsn = Decrypt(ToString(ToBinary(url.dsn)), TheKey)>
</cfif>
<cfset customPath = "">
<cfquery name="qGetCompany" datasource="#dsn#">
    select CompanyCode from Companies WHERE CompanyID = <cfqueryparam value="#session.companyid#" cfsqltype="cf_sql_varchar">
</cfquery>
<cfquery name="qGetSystemconfig" datasource="#dsn#">
    select UseNonFeeAccOnBOL from SystemConfig WHERE CompanyID = <cfqueryparam value="#session.companyid#" cfsqltype="cf_sql_varchar">
</cfquery>
<cfif len(trim(qGetCompany.companycode)) and directoryExists(expandPath("../reports/#trim(qGetCompany.companycode)#"))>
    <cfset customPath = "#trim(qGetCompany.companycode)#">
</cfif>
<cfif len(trim(customPath)) and fileExists(expandPath("../reports/#trim(customPath)#/ShortBOLReport.cfr"))>
    <cfset tempRootPath = expandPath("../reports/#trim(customPath)#/ShortBOLReport.cfr")> 
<cfelse>
    <cfset tempRootPath = expandPath("../reports/ShortBOLReport.cfr")> 
</cfif>
<cfif structkeyexists(url,"loadno") or structkeyexists(url,"loadid")>
    <cfquery name="BOLReport" datasource="#dsn#">
        SELECT         l.LoadID, l.LoadNumber, CASE WHEN ISNULL(l.CustomerPONo,'')<>'' THEN l.CustomerPONo ELSE l.BOLREPO END AS RefNo, l.Address AS custaddress, l.City AS custcity, l.StateCode AS custstate, l.PostalCode AS custpostalcode, 
                         l.Phone AS custphone, l.Fax AS custfax, l.CellNo AS custcell, l.CustName AS custname, l.EmergencyResponseNo, l.CODAmt, l.CODFee, l.DeclaredValue, l.Notes, 
                         stops.shipperState, stops.shipperCity, stops.consigneeState, stops.consigneeCity, carr.CarrierName, stops.LoadStopID, stops.StopNo, 
                         l.NewPickupDate AS PickupDate, l.NewPickupTime AS PickupTime, l.NewDeliveryDate AS DeliveryDate, l.NewDeliveryTime AS DeliveryTime, 
                         stops.shipperStopName, stops.consigneeStopName, stops.shipperLocation, stops.consigneeLocation, stops.shipperPostalCode, stops.consigneePostalCode, 
                         stops.shipperContactPerson, stops.consigneeContactPerson, stops.shipperPhone,stops.shipperPhoneExt, stops.consigneePhone,stops.consigneePhoneExt, stops.shipperFax, stops.consigneeFax, 
                         stops.shipperEmailID, stops.consigneeEmailID, stops.shipperBlind, stops.consigneeBlind, stops.shipperDriverName, stops.consigneeDriverName, BOL.SrNo, 
                         ISNULL(BOL.Qty, 0) AS Qty, BOL.Description, ISNULL(BOL.Weight, 0) AS Weight, BOL.classid, BOL.Hazmat, BOL.LoadStopIDBOL, CarrierTerms.CarrierTerms, 
                         dbo.Companies.CompanyName, dbo.Companies.address, dbo.Companies.address2, dbo.Companies.city, dbo.Companies.state, dbo.Companies.zipCode,CASE WHEN ISNULL(dbo.Employees.Telephone ,'') = '' THEN case when isnull(offi.ContactNo ,'') = '' then dbo.Companies.phone else offi.ContactNo End ELSE dbo.Employees.Telephone END as Phone
                         ,case when isnull(dbo.Companies.fax ,'') = '' then dbo.Companies.fax
                         else offi.faxno End as fax,
                        ( (select top 1 NewBookedWith from loadstops where loadid = l.loadid and loadtype=1 order by StopNo)
                         +'/'+carr.CarrierName) as shipperBookedWith, carr.EmailID As carrEmail,
                        l.BOLFromName,l.BOLFromTel,l.BOLFromEmail,(l.BOLREName+' / PO## '+l.BOLREPO) as BOLRE
                        ,ShortBOLTerms.ShortBOLTerms,dbo.Companies.CompanyCode,(SELECT CompanyLogoName
                               FROM            dbo.SystemConfig where companyID = <cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar">) AS CompanyLogoName,C.CustomerName,C.Location AS CustomerAddress,C.City AS CustomerCity,C.statecode AS CustomerState,C.ZipCode AS CustomerZipCode,consigneeReleaseNo,shipperReleaseNo
FROM            dbo.Loads AS l 

INNER JOIN Customers C On C.CustomerID = l.CustomerID
INNER JOIN
                         dbo.Employees ON L.DispatcherID = dbo.Employees.EmployeeID LEFT OUTER JOIN
                             (SELECT        a.LoadID, a.LoadStopID, a.StopNo, a.NewCarrierID, a.NewOfficeID, a.City AS shipperCity, b.City AS consigneeCity, a.CustName AS shipperStopName, 
                                                         b.CustName AS consigneeStopName, a.Address AS shipperLocation, b.Address AS consigneeLocation, a.PostalCode AS shipperPostalCode, 
                                                         b.PostalCode AS consigneePostalCode, a.ContactPerson AS shipperContactPerson, b.ContactPerson AS consigneeContactPerson, 
                                                         a.Phone AS shipperPhone, b.Phone AS consigneePhone, a.PhoneExt AS shipperPhoneExt, b.PhoneExt AS consigneePhoneExt, a.Fax AS shipperFax, b.Fax AS consigneeFax, a.EmailID AS shipperEmailID, 
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
                               WHERE        (a.LoadID = <cfqueryparam value="#url.loadid#" cfsqltype="cf_sql_varchar">) AND (a.LoadType = 1 AND a.StopNo=0) AND (b.LoadType = 2  AND b.StopNo=0)) AS stops ON 
                         stops.LoadID = l.LoadID LEFT OUTER JOIN
                             (SELECT        CarrierID, CarrierName, EmailID
                               FROM            dbo.Carriers) AS carr ON carr.CarrierID = stops.NewCarrierID LEFT OUTER JOIN
                             (SELECT        CarrierTerms
                               FROM            dbo.SystemConfig where companyID = <cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar">) AS CarrierTerms ON 1 = 1 LEFT OUTER JOIN
                             (SELECT        ShortBOLTerms
                               FROM            dbo.SystemConfig where companyID = <cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar">) AS ShortBOLTerms ON 1 = 1 



                             <cfif qGetSystemconfig.UseNonFeeAccOnBOL EQ 1>
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

ORDER BY l.LoadNumber
    </cfquery>
    <cfreport format="PDF" template="#tempRootPath#" query="#BOLReport#" name="result">
    </cfreport>      
    <cfset fileName = "BOL Load ###BOLReport.LoadNumber# Date-#DateFormat(Now(),'mm.dd.yyyy')#.pdf">
    <cfheader name="Content-Disposition" value="inline; filename=#fileName#">
    <cfcontent type="application/pdf" variable="#tobinary(result)#"> 
<cfelse>
    Unable to generate the report. Please specify the load Number or Load ID    
</cfif>
</cfoutput> 