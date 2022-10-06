<cfquery name="qGetSystemConfig" datasource="#Application.dsn#">
    SELECT companyName FROM Companies WHERE CompanyID = <cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar">
</cfquery>
<cfquery name="qGetCarrierQuotes" datasource="#Application.dsn#">
    SELECT L.LoadNumber,L.noOfTrips,ROW_NUMBER() OVER(Partition by L.LoadNumber ORDER BY L.LoadNumber ASC,(CASE WHEN LCQ.CarrierID = LS.NewCarrierID  AND L.CarrFlatRate = ISNULL(LCQ.Amount,0) THEN '1.TRUE' ELSE '2.FALSE' END) ASC,ISNULL(LCQ.Amount,0) ASC,Cr.CarrierName ASC) AS QuoteNo,CASE WHEN LCQ.CarrierID = LS.NewCarrierID THEN LST.StatusText ELSE NULL END AS StatusText,'$'+CONVERT(varchar(25), CONVERT(money, ISNULL(LCQ.Amount,0))) AS Quote,Cr.CarrierName,Cr.MCNumber,L.CustName,L.CustomerPONo,E.EquipmentName,Emp.Name,LS.StopDate AS PickUpDate,LS1.StopDate AS DeliveryDate,LS.City+', '+LS.StateCode+' '+LS.PostalCode AS FirstStop,LS1.City+', '+LS1.StateCode+' '+LS1.PostalCode AS LastStop,LST.StatusText AS LoadStatusText
        FROM LoadCarrierQuotes LCQ
        INNER JOIN Loads L ON L.LoadID = LCQ.LoadID
        LEFT JOIN LoadStops LS ON LS.LoadID = LCQ.LoadID AND LS.StopNo = (LCQ.StopNo-1) AND LS.LoadType = 1
        LEFT JOIN LoadStops LS1 ON LS1.LoadID = LCQ.LoadID AND LS1.StopNo = (LCQ.StopNo-1) AND LS1.LoadType = 2
        INNER JOIN LoadStatusTypes LST ON LST.StatusTypeID = L.StatusTypeID 
        LEFT JOIN Carriers Cr ON Cr.CarrierID = LCQ.CarrierID
        LEFT JOIN Equipments E ON E.EquipmentID = ISNULL(LCQ.EquipmentID,LS.NewEquipmentID)
        LEFT JOIN Employees Emp ON Emp.EmployeeID = L.DispatcherID
        LEFT JOIN Offices O ON O.OfficeID = Emp.OfficeID 
        WHERE O.CompanyID = <cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar">
    <cfif structkeyexists(url,"loadNoFrom") AND len(trim(url.loadNoFrom))>
        AND L.LoadNumber >= <cfqueryparam value="#url.loadNoFrom#" cfsqltype="cf_sql_numeric">
    </cfif>
    <cfif structkeyexists(url,"loadNoTo") AND len(trim(url.loadNoTo))>
        AND L.LoadNumber <= <cfqueryparam value="#url.loadNoTo#" cfsqltype="cf_sql_numeric">
    </cfif>
    <cfif structkeyexists(url,"statusFrom") AND len(trim(url.statusFrom))>
        AND LST.StatusText >= <cfqueryparam value="#url.statusFrom#" cfsqltype="cf_sql_varchar">
    </cfif>
    <cfif structkeyexists(url,"statusTo") AND len(trim(url.statusTo))>
        AND LST.StatusText <= <cfqueryparam value="#url.statusTo#" cfsqltype="cf_sql_varchar">
    </cfif>
    <cfif structkeyexists(url,"carrierFrom") AND len(trim(url.carrierFrom))>
        AND Cr.CarrierName>= <cfqueryparam value="#url.carrierFrom#" cfsqltype="cf_sql_varchar">
    </cfif>
    <cfif structkeyexists(url,"carrierTo") AND len(trim(url.carrierTo))>
        AND Cr.CarrierName<= <cfqueryparam value="#url.carrierTo#" cfsqltype="cf_sql_varchar">
    </cfif>
    <cfif structkeyexists(url,"mcFrom") AND len(trim(url.mcFrom))>
        AND Cr.MCNumber>= <cfqueryparam value="#url.mcFrom#" cfsqltype="cf_sql_varchar">
    </cfif>
    <cfif structkeyexists(url,"mcTo") AND len(trim(url.mcTo))>
        AND Cr.MCNumber<= <cfqueryparam value="#url.mcTo#" cfsqltype="cf_sql_varchar">
    </cfif>
    <cfif structkeyexists(url,"customerFrom") AND len(trim(url.customerFrom))>
        AND L.CustName>= <cfqueryparam value="#url.customerFrom#" cfsqltype="cf_sql_varchar">
    </cfif>
    <cfif structkeyexists(url,"customerTo") AND len(trim(url.customerTo))>
        AND L.CustName<= <cfqueryparam value="#url.customerTo#" cfsqltype="cf_sql_varchar">
    </cfif>
    <cfif structkeyexists(url,"poFrom") AND len(trim(url.poFrom))>
        AND L.CustomerPONo>= <cfqueryparam value="#url.poFrom#" cfsqltype="cf_sql_varchar">
    </cfif>
    <cfif structkeyexists(url,"poTo") AND len(trim(url.poTo))>
        AND L.CustomerPONo<= <cfqueryparam value="#url.poTo#" cfsqltype="cf_sql_varchar">
    </cfif>
    <cfif structkeyexists(url,"equipmentFrom") AND len(trim(url.equipmentFrom))>
        AND E.EquipmentName>= <cfqueryparam value="#url.equipmentFrom#" cfsqltype="cf_sql_varchar">
    </cfif>
    <cfif structkeyexists(url,"equipmentTo") AND len(trim(url.equipmentTo))>
        AND E.EquipmentName<= <cfqueryparam value="#url.equipmentTo#" cfsqltype="cf_sql_varchar">
    </cfif>
    <cfif structkeyexists(url,"officeFrom") AND len(trim(url.officeFrom))>
        AND O.OfficeCode>= <cfqueryparam value="#url.officeFrom#" cfsqltype="cf_sql_varchar">
    </cfif>
    <cfif structkeyexists(url,"officeTo") AND len(trim(url.officeTo))>
        AND O.OfficeCode<= <cfqueryparam value="#url.officeTo#" cfsqltype="cf_sql_varchar">
    </cfif>
    <cfif structkeyexists(url,"dispatcherFrom") AND len(trim(url.dispatcherFrom))>
        AND Emp.Name>= <cfqueryparam value="#url.dispatcherFrom#" cfsqltype="cf_sql_varchar">
    </cfif>
    <cfif structkeyexists(url,"dispatcherTo") AND len(trim(url.dispatcherTo))>
        AND Emp.Name<= <cfqueryparam value="#url.dispatcherTo#" cfsqltype="cf_sql_varchar">
    </cfif>
    <cfif structkeyexists(url,"pickupDateFrom") AND len(trim(url.pickupDateFrom))>
        AND LS.StopDate>= <cfqueryparam value="#url.pickupDateFrom#" cfsqltype="cf_sql_date">
    </cfif>
    <cfif structkeyexists(url,"pickupDateTo") AND len(trim(url.pickupDateTo))>
        AND LS.StopDate<= <cfqueryparam value="#url.pickupDateTo#" cfsqltype="cf_sql_date">
    </cfif>
    <cfif structkeyexists(url,"pickupCityFrom") AND len(trim(url.pickupCityFrom))>
        AND LS.City>= <cfqueryparam value="#url.pickupCityFrom#" cfsqltype="cf_sql_varchar">
    </cfif>
    <cfif structkeyexists(url,"pickupCityTo") AND len(trim(url.pickupCityTo))>
        AND LS.City<= <cfqueryparam value="#url.pickupCityTo#" cfsqltype="cf_sql_varchar">
    </cfif>
    <cfif structkeyexists(url,"pickupZipFrom") AND len(trim(url.pickupZipFrom))>
        AND LS.PostalCode>= <cfqueryparam value="#url.pickupZipFrom#" cfsqltype="cf_sql_varchar">
    </cfif>
    <cfif structkeyexists(url,"pickupZipTo") AND len(trim(url.pickupZipTo))>
        AND LS.PostalCode<= <cfqueryparam value="#url.pickupZipTo#" cfsqltype="cf_sql_varchar">
    </cfif>
    <cfif structkeyexists(url,"pickupStateFrom") AND len(trim(url.pickupStateFrom))>
        AND LS.StateCode>= <cfqueryparam value="#url.pickupStateFrom#" cfsqltype="cf_sql_varchar">
    </cfif>
    <cfif structkeyexists(url,"pickupStateTo") AND len(trim(url.pickupStateTo))>
        AND LS.StateCode<= <cfqueryparam value="#url.pickupStateTo#" cfsqltype="cf_sql_varchar">
    </cfif>
    <cfif structkeyexists(url,"deliveryDateFrom") AND len(trim(url.deliveryDateFrom))>
        AND LS1.StopDate>= <cfqueryparam value="#url.deliveryDateFrom#" cfsqltype="cf_sql_date">
    </cfif>
    <cfif structkeyexists(url,"deliveryDateTo") AND len(trim(url.deliveryDateTo))>
        AND LS1.StopDate<= <cfqueryparam value="#url.deliveryDateTo#" cfsqltype="cf_sql_date">
    </cfif>
    <cfif structkeyexists(url,"deliveryCityFrom") AND len(trim(url.deliveryCityFrom))>
        AND LS1.City>= <cfqueryparam value="#url.deliveryCityFrom#" cfsqltype="cf_sql_varchar">
    </cfif>
    <cfif structkeyexists(url,"deliveryCityTo") AND len(trim(url.deliveryCityTo))>
        AND LS1.City<= <cfqueryparam value="#url.deliveryCityTo#" cfsqltype="cf_sql_varchar">
    </cfif>
    <cfif structkeyexists(url,"deliveryZipFrom") AND len(trim(url.deliveryZipFrom))>
        AND LS1.PostalCode>= <cfqueryparam value="#url.deliveryZipFrom#" cfsqltype="cf_sql_varchar">
    </cfif>
    <cfif structkeyexists(url,"deliveryZipTo") AND len(trim(url.deliveryZipTo))>
        AND LS1.PostalCode<= <cfqueryparam value="#url.deliveryZipTo#" cfsqltype="cf_sql_varchar">
    </cfif>
    <cfif structkeyexists(url,"deliveryStateFrom") AND len(trim(url.deliveryStateFrom))>
        AND LS1.StateCode>= <cfqueryparam value="#url.deliveryStateFrom#" cfsqltype="cf_sql_varchar">
    </cfif>
    <cfif structkeyexists(url,"deliveryStateTo") AND len(trim(url.deliveryStateTo))>
        AND LS1.StateCode<= <cfqueryparam value="#url.deliveryStateTo#" cfsqltype="cf_sql_varchar">
    </cfif>


    <cfif structkeyexists(url,"carrierTotalFrom") AND len(trim(url.carrierTotalFrom))>
        AND (SELECT SUM(LSC.CarrCharges) FROM LoadStopCommodities LSC WHERE LSC.LoadStopID = LS.LoadStopID)>= <cfqueryparam value="#url.carrierTotalFrom#" cfsqltype="cf_sql_float">
    </cfif>
    <cfif structkeyexists(url,"carrierTotalTo") AND len(trim(url.carrierTotalTo))>
        AND (SELECT SUM(LSC.CarrCharges) FROM LoadStopCommodities LSC WHERE LSC.LoadStopID = LS.LoadStopID)<= <cfqueryparam value="#url.carrierTotalTo#" cfsqltype="cf_sql_float">
    </cfif>
    ORDER BY L.LoadNumber ASC,(CASE WHEN LCQ.CarrierID = LS.NewCarrierID  AND L.CarrFlatRate = ISNULL(LCQ.Amount,0) THEN '1.TRUE' ELSE '2.FALSE' END) ASC,ISNULL(LCQ.Amount,0) ASC,Cr.CarrierName ASC
</cfquery>

<cfif structKeyExists(url, "export") and url.export eq 1>
    <cfscript> 
        theDir=expandPath( "../temp/" );
        if(! DirectoryExists(theDir)){
            directoryCreate(expandPath("../temp/"));
        }
        theFile=theDir & "CarrierQuote.xls"; 
        theSheet = SpreadsheetNew("CarrierQuote");
        SpreadSheetAddRow(theSheet,"Load##,Trip##,Load Status,Quote,Carrier,Customer,PO##,Equipment,Dispatcher,Pickup,Delivery,First Stop,Last Stop");
        SpreadsheetformatRow(theSheet,{bold=true,alignment='left'},1);
        SpreadsheetFormatCell(theSheet,{alignment='right'},1,5);
        cr = 1;
        for (quoteRow in qGetCarrierQuotes){
            nr = cr+1;
            SpreadsheetSetCellValue(theSheet,'#quoteRow.loadnumber#',nr,1);
            SpreadsheetSetCellValue(theSheet,'#quoteRow.noOfTrips#',nr,2);
            SpreadsheetSetCellValue(theSheet,'#quoteRow.LoadStatusText#',nr,3);
            SpreadsheetSetCellValue(theSheet,'#quoteRow.Quote#',nr,4);
            SpreadsheetSetCellValue(theSheet,'#quoteRow.CarrierName#',nr,5);
            SpreadsheetSetCellValue(theSheet,'#quoteRow.CustName#',nr,6);
            SpreadsheetSetCellValue(theSheet,'#quoteRow.CustomerPONo#',nr,7);
            SpreadsheetSetCellValue(theSheet,'#quoteRow.EquipmentName#',nr,8);
            SpreadsheetSetCellValue(theSheet,'#quoteRow.Name#',nr,9);
            SpreadsheetSetCellValue(theSheet,'#quoteRow.PickUpDate#',nr,10);
            SpreadsheetSetCellValue(theSheet,'#quoteRow.DeliveryDate#',nr,11);
            SpreadsheetSetCellValue(theSheet,'#quoteRow.FirstStop#',nr,12);
            SpreadsheetSetCellValue(theSheet,'#quoteRow.LastStop#',nr,13);
            SpreadsheetformatRow(theSheet,{alignment='left'},nr);
            SpreadsheetFormatCell(theSheet,{alignment='right',bold=false},nr,5);
            cr++;
        }
    </cfscript> 

    <cfspreadsheet 
            action="write" 
            filename="#theFile#" 
            name="theSheet"
            sheetname="getCustomersDetails" 
            overwrite=true> 
    <cfset fileName = "Carrier Quote Report Date-#DateFormat(Now(),'mm.dd.yyyy')#.xls">
    <cfheader name="Content-Disposition" value="attachment;filename=#fileName#">,
    <cfcontent deleteFile = "yes" type="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" file="#theFile#">

<cfelse>
    <cfset fileName = "Carrier Quote Report Date-#DateFormat(Now(),'mm.dd.yyyy')#.pdf">
    <cfset margerTopInc = 0>
    <cfif structkeyexists(url,"loadNoFrom") AND len(trim(url.loadNoFrom)) OR structkeyexists(url,"loadNoTo") AND len(trim(url.loadNoTo))>
        <cfset margerTopInc++>
    </cfif>
    <cfif structkeyexists(url,"statusFrom") AND len(trim(url.statusFrom)) OR structkeyexists(url,"statusTo") AND len(trim(url.statusTo))>
        <cfset margerTopInc++>
    </cfif>
    <cfif structkeyexists(url,"carrierFrom") AND len(trim(url.carrierFrom)) OR structkeyexists(url,"carrierTo") AND len(trim(url.carrierTo))>
        <cfset margerTopInc++>
    </cfif>
    <cfif structkeyexists(url,"mcFrom") AND len(trim(url.mcFrom)) OR structkeyexists(url,"mcTo") AND len(trim(url.mcTo))>
        <cfset margerTopInc++>
    </cfif>
    <cfif structkeyexists(url,"customerFrom") AND len(trim(url.customerFrom)) OR structkeyexists(url,"customerTo") AND len(trim(url.customerTo))>
    <cfset margerTopInc++>
    </cfif>
    <cfif structkeyexists(url,"poFrom") AND len(trim(url.poFrom)) OR structkeyexists(url,"poTo") AND len(trim(url.poTo))>
        <cfset margerTopInc++>
    </cfif>
    <cfif structkeyexists(url,"equipmentFrom") AND len(trim(url.equipmentFrom)) OR structkeyexists(url,"equipmentTo") AND len(trim(url.equipmentTo))>
        <cfset margerTopInc++>
    </cfif>
    <cfif structkeyexists(url,"dispatcherFrom") AND len(trim(url.dispatcherFrom)) OR structkeyexists(url,"dispatcherTo") AND len(trim(url.dispatcherTo))>
        <cfset margerTopInc++>
    </cfif>
    <cfif structkeyexists(url,"pickupDateFrom") AND len(trim(url.pickupDateFrom)) OR structkeyexists(url,"pickupDateTo") AND len(trim(url.pickupDateTo))>
        <cfset margerTopInc++>
    </cfif>
    <cfif structkeyexists(url,"pickupCityFrom") AND len(trim(url.pickupCityFrom)) OR structkeyexists(url,"pickupCityTo") AND len(trim(url.pickupCityTo))>
        <cfset margerTopInc++>
    </cfif>
    <cfif structkeyexists(url,"pickupStateFrom") AND len(trim(url.pickupStateFrom)) OR structkeyexists(url,"pickupStateTo") AND len(trim(url.pickupStateTo))>
        <cfset margerTopInc++>
    </cfif>
    <cfif structkeyexists(url,"DeliveryDateFrom") AND len(trim(url.DeliveryDateFrom)) OR structkeyexists(url,"DeliveryDateTo") AND len(trim(url.DeliveryDateTo))>
        <cfset margerTopInc++>
    </cfif>
    <cfif structkeyexists(url,"DeliveryCityFrom") AND len(trim(url.DeliveryCityFrom)) OR structkeyexists(url,"DeliveryCityTo") AND len(trim(url.DeliveryCityTo))>
        <cfset margerTopInc++>
    </cfif>
    <cfif structkeyexists(url,"DeliveryStateFrom") AND len(trim(url.DeliveryStateFrom)) OR structkeyexists(url,"DeliveryStateTo") AND len(trim(url.DeliveryStateTo))>
        <cfset margerTopInc++>
    </cfif>
    <cfif structkeyexists(url,"carrierTotalFrom") AND len(trim(url.carrierTotalFrom)) OR structkeyexists(url,"carrierTotalTo") AND len(trim(url.carrierTotalTo))>
        <cfset margerTopInc++>
    </cfif>
    <cfif margerTopInc LTE 8>
        <cfset marginTop = 1.5>
    </cfif>
    <cfif margerTopInc EQ 9>
        <cfset marginTop = 1.6>
    </cfif>
    <cfif margerTopInc EQ 10>
        <cfset marginTop = 1.7>
    </cfif>
    <cfif margerTopInc EQ 11>
        <cfset marginTop = 1.8>
    </cfif>
    <cfif margerTopInc EQ 12>
        <cfset marginTop = 1.9>
    </cfif>
    <cfif margerTopInc EQ 13>
        <cfset marginTop = 2>
    </cfif>
    <cfif margerTopInc EQ 14>
        <cfset marginTop = 2.1>
    </cfif>
    <cfif margerTopInc EQ 15>
        <cfset marginTop = 2.2>
    </cfif>
    <cfoutput>
        <cfheader name="Content-Disposition" value="inline; filename=#fileName#">
        <cfdocument format="PDF" orientation="landscape" marginleft="0" marginright="0" margintop="#marginTop#" >
            <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
            <HTML xmlns="http://www.w3.org/1999/xhtml">
                <HEAD>
                    <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
                    <TITLE>Load Manager TMS</TITLE>
                </HEAD> 
                <BODY style="margin-left: 20px;margin-right: 20px;font-family: 'Arial Narrow';">
                    <cfdocumentitem type="header">
                        <div style="float: left;width:50%;">
                            <h4 style="text-align: right;margin-top: 20px;font-style:italic;font-size: 14px;font-family: 'Arial Narrow';">Carrier Quotes</h4>
                            <h4 style="text-align:right;font-family: 'Arial Narrow';">#qGetSystemConfig.companyName#</h4>
                        </div>
                        <table cellspacing="0" style="float: right;font-size: 8px;margin-right: 20px;margin-top:10px;font-family: 'Arial Narrow';padding-top: 5px;">
                            <cfif structkeyexists(url,"loadNoFrom") AND len(trim(url.loadNoFrom)) OR structkeyexists(url,"loadNoTo") AND len(trim(url.loadNoTo))>
                                <tr>
                                    <td><strong>From Load##: </strong></td>
                                    <td align="left">#url.loadNoFrom#</td>
                                    <td align="right" width="25px"><strong>To: </strong></td>
                                    <td align="left">#url.loadNoTo#</td>
                                </tr>
                            </cfif>
                            <cfif structkeyexists(url,"statusFrom") AND len(trim(url.statusFrom)) OR structkeyexists(url,"statusTo") AND len(trim(url.statusTo))>
                                <tr>
                                    <td><strong>From LoadStatus: </strong></td>
                                    <td align="left">#url.statusFrom#</td>
                                    <td align="right" width="25px"><strong>To: </strong></td>
                                    <td align="left">#url.statusTo#</td>
                                </tr>
                            </cfif>
                            <cfif structkeyexists(url,"carrierFrom") AND len(trim(url.carrierFrom)) OR structkeyexists(url,"carrierTo") AND len(trim(url.carrierTo))>
                                <tr>
                                    <td><strong>From Carrier: </strong></td>
                                    <td align="left">#url.carrierFrom#</td>
                                    <td align="right" width="25px"><strong>To: </strong></td>
                                    <td align="left">#url.carrierTo#</td>
                                </tr>
                            </cfif>
                            <cfif structkeyexists(url,"mcFrom") AND len(trim(url.mcFrom)) OR structkeyexists(url,"mcTo") AND len(trim(url.mcTo))>
                                <tr>
                                    <td><strong>From MC##: </strong></td>
                                    <td align="left">#url.mcFrom#</td>
                                    <td align="right" width="25px"><strong>To: </strong></td>
                                    <td align="left">#url.mcTo#</td>
                                </tr>
                            </cfif>
                            <cfif structkeyexists(url,"customerFrom") AND len(trim(url.customerFrom)) OR structkeyexists(url,"customerTo") AND len(trim(url.customerTo))>
                                <tr>
                                    <td><strong>From Customer: </strong></td>
                                    <td align="left">#url.customerFrom#</td>
                                    <td align="right" width="25px"><strong>To: </strong></td>
                                    <td align="left">#url.customerTo#</td>
                                </tr>
                            </cfif>
                            <cfif structkeyexists(url,"poFrom") AND len(trim(url.poFrom)) OR structkeyexists(url,"poTo") AND len(trim(url.poTo))>
                                <tr>
                                    <td><strong>From Po##: </strong></td>
                                    <td align="left">#url.poFrom#</td>
                                    <td align="right" width="25px"><strong>To: </strong></td>
                                    <td align="left">#url.poTo#</td>
                                </tr>
                            </cfif>
                            <cfif structkeyexists(url,"equipmentFrom") AND len(trim(url.equipmentFrom)) OR structkeyexists(url,"equipmentTo") AND len(trim(url.equipmentTo))>
                                <tr>
                                    <td><strong>From Equipment: </strong></td>
                                    <td align="left">#url.equipmentFrom#</td>
                                    <td align="right" width="25px"><strong>To: </strong></td>
                                    <td align="left">#url.equipmentTo#</td>
                                </tr>
                            </cfif>
                            <cfif structkeyexists(url,"dispatcherFrom") AND len(trim(url.dispatcherFrom)) OR structkeyexists(url,"dispatcherTo") AND len(trim(url.dispatcherTo))>
                                <tr>
                                    <td><strong>From Dispatcher: </strong></td>
                                    <td align="left">#url.dispatcherFrom#</td>
                                    <td align="right" width="25px"><strong>To: </strong></td>
                                    <td align="left">#url.dispatcherTo#</td>
                                </tr>
                            </cfif>
                            <cfif structkeyexists(url,"pickupDateFrom") AND len(trim(url.pickupDateFrom)) OR structkeyexists(url,"pickupDateTo") AND len(trim(url.pickupDateTo))>
                                <tr>
                                    <td><strong>From PickUp: </strong></td>
                                    <td align="left">#url.pickupDateFrom#</td>
                                    <td align="right" width="25px"><strong>To: </strong></td>
                                    <td align="left">#url.pickupDateTo#</td>
                                </tr>
                            </cfif>
                            <cfif structkeyexists(url,"pickupCityFrom") AND len(trim(url.pickupCityFrom)) OR structkeyexists(url,"pickupCityTo") AND len(trim(url.pickupCityTo))>
                                <tr>
                                    <td><strong>From PickUpCity: </strong></td>
                                    <td align="left">#url.pickupCityFrom#</td>
                                    <td align="right" width="25px"><strong>To: </strong></td>
                                    <td align="left">#url.pickupCityTo#</td>
                                </tr>
                            </cfif>
                            <cfif structkeyexists(url,"pickupStateFrom") AND len(trim(url.pickupStateFrom)) OR structkeyexists(url,"pickupStateTo") AND len(trim(url.pickupStateTo))>
                                <tr>
                                    <td><strong>From PickUpState: </strong></td>
                                    <td align="left">#url.pickupStateFrom#</td>
                                    <td align="right" width="25px"><strong>To: </strong></td>
                                    <td align="left">#url.pickupStateTo#</td>
                                </tr>
                            </cfif>
                            <cfif structkeyexists(url,"DeliveryDateFrom") AND len(trim(url.DeliveryDateFrom)) OR structkeyexists(url,"DeliveryDateTo") AND len(trim(url.DeliveryDateTo))>
                                <tr>
                                    <td><strong>From Delivery: </strong></td>
                                    <td align="left">#url.DeliveryDateFrom#</td>
                                    <td align="right" width="25px"><strong>To: </strong></td>
                                    <td align="left">#url.DeliveryDateTo#</td>
                                </tr>
                            </cfif>
                            <cfif structkeyexists(url,"DeliveryCityFrom") AND len(trim(url.DeliveryCityFrom)) OR structkeyexists(url,"DeliveryCityTo") AND len(trim(url.DeliveryCityTo))>
                                <tr>
                                    <td><strong>From DeliveryCity: </strong></td>
                                    <td align="left">#url.DeliveryCityFrom#</td>
                                    <td align="right" width="25px"><strong>To: </strong></td>
                                    <td align="left">#url.DeliveryCityTo#</td>
                                </tr>
                            </cfif>
                            <cfif structkeyexists(url,"DeliveryStateFrom") AND len(trim(url.DeliveryStateFrom)) OR structkeyexists(url,"DeliveryStateTo") AND len(trim(url.DeliveryStateTo))>
                                <tr>
                                    <td><strong>From DeliveryState: </strong></td>
                                    <td align="left">#url.DeliveryStateFrom#</td>
                                    <td align="right" width="25px"><strong>To: </strong></td>
                                    <td align="left">#url.DeliveryStateTo#</td>
                                </tr>
                            </cfif>
                            <cfif structkeyexists(url,"carrierTotalFrom") AND len(trim(url.carrierTotalFrom)) OR structkeyexists(url,"carrierTotalTo") AND len(trim(url.carrierTotalTo))>
                                <tr>
                                    <td><strong>From Carrier Total: </strong></td>
                                    <td align="left">#DollarFormat(url.carrierTotalFrom)#</td>
                                    <td align="right" width="25px"><strong>To: </strong></td>
                                    <td align="left">#DollarFormat(url.carrierTotalTo)#</td>
                                </tr>
                            </cfif>
                            <cfif structkeyexists(url,"pickupZipFrom") AND len(trim(url.pickupZipFrom)) OR structkeyexists(url,"pickupZipTo") AND len(trim(url.pickupZipTo))>
                                <tr>
                                    <td><strong>From PickUpZip: </strong></td>
                                    <td align="left">#url.pickupZipFrom#</td>
                                    <td align="right" width="25px"><strong>To: </strong></td>
                                    <td align="left">#url.pickupZipFrom#</td>
                                </tr>
                            </cfif>
                            <cfif structkeyexists(url,"deliveryZipFrom") AND len(trim(url.deliveryZipFrom)) OR structkeyexists(url,"pickupZipTo") AND len(trim(url.pickupZipTo))>
                                <tr>
                                    <td><strong>From DeliveryZip: </strong></td>
                                    <td align="left">#url.deliveryZipFrom#</td>
                                    <td align="right" width="25px"><strong>To: </strong></td>
                                    <td align="left">#url.deliveryZipTo#</td>
                                </tr>
                            </cfif>
                        </table>
                        <div style="padding: 0;margin: 0;line-height: 0;font-size: 0;height:35px;clear: both;"></div>
                        <div style="margin-left: 20px;margin-right: 20px;">
                            <div style="width:100%;font-size: 9px;font-family: 'Arial Narrow';font-weight: bold;">
                                <div style="float:left;width:3%;text-align: left;border-bottom: 1px">Load##</div>
                                <div style="float:left;width:3%;text-align: left;">Trip##</div>
                                <div style="float:left;width:6%;text-align: left;">Load Status</div>
                                <div style="float:left;width:4%;text-align: right;">Quote&nbsp;&nbsp;</div>
                                <div style="float:left;width:14%;text-align: left;">Carrier</div>
                                <div style="float:left;width:10%;text-align: left;">Customer</div>
                                <div style="float:left;width:9%;text-align: left;">PO##</div>
                                <div style="float:left;width:7%;text-align: left;">Equipment</div>
                                <div style="float:left;width:6%;text-align: left;">Dispatcher</div>
                                <div style="float:left;width:5%;text-align: left;">Pickup</div>
                                <div style="float:left;width:5%;text-align: left;">Delivery</div>
                                <div style="float:left;width:14%;text-align: left;">First Stop</div>
                                <div style="float:left;width:14%;text-align: left;">Last Stop</div>
                            </div>
                        </div>
                        <div style="padding: 0;margin-left: 20px;margin-right: 20px;line-height: 0;font-size: 0;height: 1px;clear: both;background-color: ##000000;"></div>
                    </cfdocumentitem>

                    <cfloop query="qGetCarrierQuotes">
                        <cfset suppress = 1>
                        <cfset cr = qGetCarrierQuotes.currentrow>
                        <cfset pr = qGetCarrierQuotes.currentrow-1>
                        <cfif cr EQ 1 OR qGetCarrierQuotes.LoadNumber[cr] NEQ qGetCarrierQuotes.LoadNumber[pr]>
                            <cfset suppress = 0>
                        </cfif>
                        <cfif suppress EQ 0 AND qGetCarrierQuotes.currentrow NEQ 1>
                            <div style="padding: 0;margin: 0;line-height: 0;font-size: 0;height: 1px;clear: both;background-color: ##c8cacc"></div>
                            <div style="padding: 0;margin: 0;line-height: 0;font-size: 0;height: 5px;clear: both;"></div>
                        </cfif>
                        <div style="width:100%;font-size: 9px;">
                            <div style="float:left;width:3%;overflow-wrap: break-word;text-align: left;"><cfif trim(len(qGetCarrierQuotes.LoadNumber)) AND NOT suppress>#qGetCarrierQuotes.LoadNumber#<cfelse>&nbsp;</cfif></div>
                            <div style="float:left;width:3%;overflow-wrap: break-word;text-align: center;"><cfif trim(len(qGetCarrierQuotes.noOfTrips)) AND NOT suppress>#qGetCarrierQuotes.noOfTrips#<cfelse>&nbsp;</cfif></div>
                            <div style="float:left;width:6%;overflow-wrap: break-word;text-align: left;"><cfif trim(len(qGetCarrierQuotes.StatusText))>#qGetCarrierQuotes.StatusText#<cfelseif trim(len(qGetCarrierQuotes.QuoteNo)) AND qGetCarrierQuotes.QuoteNo EQ 1>#qGetCarrierQuotes.LoadStatusText#<cfelse>&nbsp;</cfif></div>
                            <div style="float:left;width:4%;overflow-wrap: break-word;text-align: right;"><cfif trim(len(qGetCarrierQuotes.Quote))>#qGetCarrierQuotes.Quote#&nbsp;&nbsp;<cfelse>&nbsp;</cfif></div>
                            <div style="float:left;width:14%;overflow-wrap: break-word;text-align: left;"><cfif trim(len(qGetCarrierQuotes.CarrierName))>#qGetCarrierQuotes.CarrierName#<cfelse>&nbsp;</cfif></div>
                            <div style="float:left;width:10%;overflow-wrap: break-word;text-align: left;"><cfif trim(len(qGetCarrierQuotes.CustName))  AND NOT suppress>#qGetCarrierQuotes.CustName#<cfelse>&nbsp;</cfif></div>
                            <div style="float:left;width:9%;overflow-wrap: break-word;text-align: left;"><cfif trim(len(qGetCarrierQuotes.CustomerPONo)) AND NOT suppress>#qGetCarrierQuotes.CustomerPONo#<cfelse>&nbsp;</cfif></div>
                            <div style="float:left;width:7%;overflow-wrap: break-word;text-align: left;"><cfif trim(len(qGetCarrierQuotes.EquipmentName)) AND NOT suppress>#qGetCarrierQuotes.EquipmentName#<cfelse>&nbsp;</cfif></div>
                            <div style="float:left;width:6%;overflow-wrap: break-word;text-align: left;"><cfif trim(len(qGetCarrierQuotes.Name)) AND NOT suppress>#qGetCarrierQuotes.Name#<cfelse>&nbsp;</cfif></div>
                            <div style="float:left;width:5%;overflow-wrap: break-word;text-align: left;"><cfif trim(len(qGetCarrierQuotes.PickUpDate)) AND NOT suppress>#DateFormat(qGetCarrierQuotes.PickUpDate,'mm/dd/yyyy')#<cfelse>&nbsp;</cfif></div>
                            <div style="float:left;width:5%;overflow-wrap: break-word;text-align: left;"><cfif trim(len(qGetCarrierQuotes.DeliveryDate)) AND NOT suppress>#DateFormat(qGetCarrierQuotes.DeliveryDate,'mm/dd/yyyy')#<cfelse>&nbsp;</cfif></div>
                            <div style="float:left;width:14%;overflow-wrap: break-word;text-align: left;"><cfif trim(len(qGetCarrierQuotes.FirstStop)) AND NOT suppress>#qGetCarrierQuotes.FirstStop#<cfelse>&nbsp;</cfif></div>
                            <div style="float:left;width:14%;overflow-wrap: break-word;text-align: left;"><cfif trim(len(qGetCarrierQuotes.LastStop)) AND NOT suppress>#qGetCarrierQuotes.LastStop#<cfelse>&nbsp;</cfif></div>
                        </div>
                        <div style="padding: 0;margin: 0;line-height: 0;font-size: 0;height: 0;clear: both;"></div>
                    </cfloop>
                    <cfdocumentitem type = "footer">
                        <div style="width:96%;border-top: solid 1px;font-size: 9px;padding-top: 5px;margin-left: 20px;font-family: 'Arial Narrow';">
                            <div style="float:left;width:50%">#DateTimeFormat(now(),"mmm dd, yyyy, hh:nn:ss tt")#</div>
                            <div style="float:right">Page #cfdocument.currentpagenumber# of #cfdocument.totalpagecount#</div>
                        </div>
                    </cfdocumentitem> 
                </BODY>
            </HTML>
        </cfdocument>
    </cfoutput>
</cfif>