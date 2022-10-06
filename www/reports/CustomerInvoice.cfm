<cftry>
	<cfset stopIndex = 0>
	<cfoutput>
		<cfdocument format="PDF" name="CustomerDocumentReport" margintop="0.01" marginleft="0.25" marginright="0.25" marginbottom="0.5">
            <cfloop query="qCustomerReport" group="CustomerID">
                <cfset FlatRate = 0>
				<cfset FlatMilesRate = 0>
				<cfset AccessorialsTotal = 0>
				<cfset PaymentsTotal = 0>
				<cfset CustTotal = 0>
				<cfset WeightTotal = 0>
				<cfif qCustomerReport.currentrow eq 1>
					<cfset FlatRate = qCustomerReport.CustFlatRate>
					<cfset FlatMilesRate = qCustomerReport.CustomerMilesCharges>
				</cfif>
				<cfloop  group="LoadStopCommoditiesID">
					<cfif qCustomerReport.PaymentAdvance EQ 1>
						<cfset PaymentsTotal = PaymentsTotal + qCustomerReport.CustCharges>
					<cfelse>
						<cfset AccessorialsTotal = AccessorialsTotal + qCustomerReport.CustCharges>
					</cfif>
					<cfset WeightTotal = WeightTotal + qCustomerReport.Weight>
				</cfloop>
				<cfset CustTotal = (FlatRate + FlatMilesRate + AccessorialsTotal) - PaymentsTotal>
                <table width="100%" style="font-family: 'Arial';margin-top: 15px;" cellspacing="0" cellpadding="0">
                    <tr>
                        <td colspan="2" align="center" style="font-weight: bold;font-size: 22px;">#qCustomerReport.ReportTitle#</td>
                    </tr>
                    <tr>
                        <td width="50%" align="left" style="padding-bottom: 10px;">
                            <cfif len(trim(qCustomerReport.CompanyLogoName))>
                                <cfif cgi.https EQ 'on'>
                                    <cfset imgurl = "https://#cgi.HTTP_HOST#/#trim(listFirst(cgi.SCRIPT_NAME,'/'))#/www/fileupload/img/#qCustomerReport.CompanyCode#/logo/#qCustomerReport.CompanyLogoName#">
                                <cfelse>
                                    <cfset imgurl = "http://#cgi.HTTP_HOST#/#trim(listFirst(cgi.SCRIPT_NAME,'/'))#/www/fileupload/img/#qCustomerReport.CompanyCode#/logo/#qCustomerReport.CompanyLogoName#">
                                </cfif>
                                <cfscript>
                                    if(fileExists(imgurl)){
                                        imgObj = imageRead(imgurl);
                                        imgObj.scaleTofit(219,116);
                                        cfimage(action="writeToBrowser", source=imgObj)
                                    }
                                </cfscript>
                            </cfif>
                        </td>
                        <td width="50%" align="right" valign="bottom" style="padding-right:30px;">
                            <table>
                                <tr>
                                    <td align="right" style="font-weight: bold;font-size:21px">Invoice##:</td>
                                    <td align="left">#qCustomerReport.LoadNumber#</td>
                                </tr>
                                <tr>
                                    <td align="right" style="font-weight: bold;font-size:15px;">PO##:</td>
                                    <td align="left">#qCustomerReport.CustomerPONo#</td>
                                </tr>
                                <tr>
                                    <td align="right" style="font-weight: bold;font-size:15px;">Date:</td>
                                    <td align="left">#DateFormat(Now(),"mm/dd/yyyy")# </td>
                                </tr>
                                <tr>
                                    <td align="right" style="font-weight: bold;font-size:15px;">Amount:</td>
                                    <td align="left">#DollarFormat(qCustomerReport.AmountFC)# <cfif qCustomerReport.ForeignCurrencyEnabled EQ 1 AND len(trim(qCustomerReport.CurrencyNameISO))>#qCustomerReport.CurrencyNameISO#</cfif></td>
                                </tr>
                                <tr>
                                    <td align="right" style="font-weight: bold;font-size:15px;">Terms:</td>
                                    <td align="left">#qCustomerReport.PaymentTerms#</td>
                                </tr>
                            </table>
                        </td>
                    </tr>
                </table>
                <div style="border-bottom: solid 1px;"></div>
                <table width="97%" style="font-family: 'Arial';float: right;margin-top:4px;" cellspacing="0" cellpadding="0" align="right">
                    <thead>
                        <tr>
                            <th width="90%" style="font-size: 13px;background-color: ##E0E0E0;border: solid 1px;padding-left:5px;" align="left">FROM:</th>
                        </tr>
                    </thead>
                </table>
                <div style="clear: both"></div>
                <table width="45%" style="font-family: 'Arial';float: left;margine:0px;padding-left:22px;" cellspacing="0" cellpadding="0" align="right">
                    <tbody>
                        <tr>
                            <td width="50%" style="font-size: 15px;font-weight: bold;">#qCustomerReport.CompanyName#</td>
                        </tr>
                        <tr>
                            <td width="50%" style="font-size: 13px;font-weight: lighter;">#qCustomerReport.Address#</td>
                        </tr>
                        <tr>
                            <td width="50%" style="font-size: 13px;font-weight: lighter;">#qCustomerReport.CompanyCity# #qCustomerReport.CompanyState# &nbsp;&nbsp;&nbsp;&nbsp;#qCustomerReport.CompanyZip#</td>
                        </tr>
                    </tbody>
                </table>
                <table width="52%" style="font-family: 'Arial';float: left;margin-left: 15px;margin-top: 3px;padding-left:20px;" cellspacing="0" cellpadding="0">
                    <tbody>
                        <tr>
                            <td width="40%" style="font-size: 12px;padding-bottom: 3px;"><b>Phone##: </b>#qCustomerReport.Phone#</td>
                            <td width="60%" style="font-size: 12px;padding-bottom: 3px;"><b>Fax##: </b>#qCustomerReport.Fax#</td>
                        </tr>
                        <cfif qCustomerReport.salesrep IS NOT '' AND  qCustomerReport.DispatchFee  IS  0>
                            <tr>
                                <td colspan="2" style="font-size: 12px;padding-bottom: 3px;"><b>Contact: </b>#qCustomerReport.SalesRep#</td>
                            </tr>
                            <tr>
                                <td colspan="2" style="font-size: 12px;padding-bottom: 3px;"><b>Email: </b>#qCustomerReport.EmailID#</td>
                            </tr>
                        </cfif>
                    </tbody>
                </table>
                <div style="clear: both"></div>
                <table width="97%" style="font-family: 'Arial';float: right;margin-top:7px;" cellspacing="0" cellpadding="0" align="right">
                    <thead>
                        <tr>
                            <th width="90%" style="font-size: 13px;background-color: ##E0E0E0;border: solid 1px;padding-left:5px;" align="left">BILL TO:</th>
                        </tr>
                    </thead>
                </table>
                <div style="clear: both"></div>
                <table width="45%" style="font-family: 'Arial';float: left;margine:0;padding-left:22px;" cellspacing="0" cellpadding="0" align="right">
                    <tbody>
                        <tr style="font-size: 13px;font-weight: lighter;">
                            <td>#qCustomerReport.PayerN#</td>
                        </tr>
                        <tr style="font-size: 13px;font-weight: lighter;">
                            <td width="50%">#qCustomerReport.PayerS#</td>
                        </tr>
                        <tr style="font-size: 13px;font-weight: lighter;">
                            <td width="50%">#qCustomerReport.PayerC# #qCustomerReport.PayerST# &nbsp;&nbsp;&nbsp;&nbsp;#qCustomerReport.PayerZ#</td>
                        </tr>
                        <tr>
                            <td width="50%"></td>
                        </tr>
                    </tbody>
                </table>
                <table width="52%" style="font-family: 'Arial';float: left;margin-left: 15px;margin-top: 3px;padding-left:20px;" cellspacing="0" cellpadding="0">
                    <tbody>
                        <tr>
                            <td colspan="2" style="font-size: 12px;padding-bottom: 3px;"><b>Contact: &nbsp;&nbsp;</b>#qCustomerReport.PayerCt#</td>
                        </tr>
                        <tr>
                            <td width="40%" style="font-size: 12px;padding-bottom: 3px;"><b>Phone##:&nbsp;&nbsp;&nbsp;</b>#qCustomerReport.PayerP#</td>
                        </tr>
                        <tr>
                            <td width="40%" style="font-size: 12px;padding-bottom: 3px;"><b>Fax##: </b>#qCustomerReport.PayerF#</td>
                        </tr>
                        <tr>
                            <td colspan="2" style="font-size: 12px;padding-bottom: 3px;"><b>Email: </b>#qCustomerReport.PayerEmail#</td>
                        </tr>
                    </tbody>
                </table>
                <div style="clear: both"></div>
                <table width="45%" style="font-family: 'Arial';float: left; margin-left:22px;" cellspacing="0" cellpadding="0">
                    <thead>
                        <tr>
                            <th style="font-size: 13px;background-color: ##E0E0E0;border: solid 1px;">Pickup:</th>
                        </tr>
                    </thead>
                    <tbody>
                        <tr>
                            <td  style="font-size: 13px;border-bottom: solid 1px;">
                                #qCustomerReport.StopName#<br>
                                #qCustomerReport.StopAddress#<br>
                                #qCustomerReport.StopCity# #qCustomerReport.StopState# &nbsp;&nbsp;&nbsp;&nbsp;#qCustomerReport.StopZip#
                            </td>
                        </tr>
                    </tbody>
                </table>
                <table width="49%" style="font-family: 'Arial';float: right;" cellspacing="0" cellpadding="0">
                    <thead>
                        <th width="60%" style="font-size: 13px;background-color: ##E0E0E0;border: solid 1px;">Delivery:</th>
                    </thead>
                    <tbody>
                        <tr>
                            <td style="font-size: 13px;border-bottom: solid 1px;">
                                #qCustomerReport.StopName[qCustomerReport.recordcount]#<br>
                                #qCustomerReport.StopAddress[qCustomerReport.recordcount]#<br>
                                #qCustomerReport.StopCity[qCustomerReport.recordcount]# #qCustomerReport.StopState[qCustomerReport.recordcount]# &nbsp;&nbsp;&nbsp;&nbsp;#qCustomerReport.StopZip[qCustomerReport.recordcount]#
                            </td>
                        </tr>
                    </tbody>
                </table>
                <div style="clear: both"></div>
                <table width="45%" style="font-family: 'Arial';float: left;padding-left:40px" cellspacing="0" cellpadding="0">
                    <tbody>
                        <tr>
                            <td colspan="2" style="font-size: 12px;"><b>Contact:</b>  #qCustomerReport.ShipperContact#</td>
                        </tr>
                        <tr>
                            <td width="50%" style="font-size: 12px;"><b>Phone ##:</b>  #qCustomerReport.ShipperPhone#</td>
                            <td width="50%" style="font-size: 12px;"><b>Fax ##:</b>  #qCustomerReport.ShipperFax#</td>
                            
                        </tr>
                        <tr>
                            <td colspan="2" style="font-size: 12px;"><b>Email:</b>  #qCustomerReport.ShipperEmail#</td>
                        </tr>
                    </tbody>
                </table>
                <table width="52%" style="font-family: 'Arial';float: right;margin-top: 3px;" cellspacing="0" cellpadding="0">
                    <tbody>
                        <tr>
                            <td  colspan="2" style="font-size: 12px;padding-left: 40px;"><b>Contact: </b>  #qCustomerReport.ShipperContact[qCustomerReport.recordcount]#</td>
                        </tr>
                        <tr>
                            <td width="50%" style="font-size: 12px;padding-left: 40px;"><b>Phone ##:</b>  #qCustomerReport.ShipperPhone[qCustomerReport.recordcount]#</td>
                            <td width="50%" style="font-size: 12px;padding-left: 25px;"><b>Fax ##:</b>  #qCustomerReport.ShipperFax[qCustomerReport.recordcount]#</td>
                            
                        </tr>
                        <tr>
                            <td colspan="2" style="font-size: 12px;padding-left: 40px;"><b>Email: </b>  #qCustomerReport.ShipperEmail[qCustomerReport.recordcount]#</td>
                        </tr>
                    </tbody>
                </table>
                <div style="clear: both"></div>
                <table width="97%" style="font-family: 'Arial';float: right;margin-top: 5px;" cellspacing="0" cellpadding="0">
                <thead>
                        <th width="16%" style="font-size: 13px;background-color: ##E0E0E0;border: solid 1px;">Pickup Date</th>
                        <th width="16%" style="font-size: 13px;background-color: ##E0E0E0;border-top: solid 1px;border-right: solid 1px;border-bottom: solid 1px;">BOL##</th>
                        <th width="16%" style="font-size: 13px;background-color: ##E0E0E0;border-top: solid 1px;border-right: solid 1px;border-bottom: solid 1px;">PO##</th>
                        <th width="16%" style="font-size: 13px;background-color: ##E0E0E0;border-top: solid 1px;border-right: solid 1px;border-bottom: solid 1px;">Delivery Date</th>
                        <th width="16%" style="font-size: 13px;background-color: ##E0E0E0;border-top: solid 1px;border-right: solid 1px;border-bottom: solid 1px;">Miles Charges</th>
                        <th width="13%" style="font-size: 13px;background-color: ##E0E0E0;border-top: solid 1px;border-right: solid 1px;border-bottom: solid 1px;">Weight</th>
                    </thead>
                    <tbody>
                        <tr>
							<tr>
								<td align="center" style="font-size: 13px;border-bottom: solid 1px;border-left: solid 1px;font-weight: bold;">#Dateformat(qCustomerReport.ShipperPickupDate,"mm/dd/yy")#</td>
								<td align="center" style="font-size: 13px;border-bottom: solid 1px;border-left: solid 1px;font-weight: bold;">#qCustomerReport.BOLNum#</td>
								<td align="center" style="font-size: 13px;border-bottom: solid 1px;border-left: solid 1px;font-weight: bold;">#qCustomerReport.CustomerPONo#</td>

								<td align="center" style="font-size: 13px;border-bottom: solid 1px;border-left: solid 1px;font-weight: bold;">#Dateformat(qCustomerReport.ShipperPickupDate[qCustomerReport.recordcount],"mm/dd/yy")#</td>
								<td align="center" style="font-size: 13px;border-bottom: solid 1px;border-left: solid 1px;font-weight: bold;">#DollarFormat(qCustomerReport.customerMilesCharges)#</td>
								<td align="center" style="font-size: 13px;border-bottom: solid 1px;border-right: solid 1px;border-left: solid 1px;font-weight: bold;">#qCustomerReport.Weight#</td>
							</tr>
                        </tr>
                    </tbody>
                </table>
                <div style="clear: both"></div>
                <cfif qCustomerReport.CustomerInvoiceformat EQ 0>
                    <table width="97%" style="font-family: 'Arial';float:right;margin:0;" cellspacing="0" cellpadding="0">
                        <thead>
                            <tr>
                                <th width="6%" align="left" style="font-size: 12px;border-top: solid 1px;padding-top: 3px;padding-bottom: 3px;padding-left:10px;">Stop </th>
                                <th width="55%"  align="left" style="font-size: 12px;border-top: solid 1px;padding-top: 3px;padding-bottom: 3px;">Company Name, Address, City, State and Zip Code</th>
                                <th width="20%" align="center"  style="font-size: 12px;border-top: solid 1px;padding-top: 3px;padding-bottom: 3px;padding-right:10px;">Delivery Date/Time</th>
                            </tr>
                        </thead>                 
                    </table>
                </cfif>
                    <div style="clear: both"></div>
                    <table width="97%" style="font-family: 'Arial';float:right;margin:0;" cellspacing="0" cellpadding="0">
                        <thead>
                            <tr>
                                <th width="15%" align="right" style="font-size: 12px;padding-top: 3px;padding-bottom: 3px;padding-left:10px;<cfif qCustomerReport.CustomerInvoiceformat EQ 0>border-bottom: solid 1px;border-top: solid 1px;</cfif>"><i>Qty</i></th>
                                <th width="50%" align="left" style="font-size: 12px;padding-top: 3px;padding-bottom: 3px;padding-left:25px;<cfif qCustomerReport.CustomerInvoiceformat EQ 0>border-bottom: solid 1px;border-top: solid 1px;</cfif>"><i>Description</i></th>
                                <th width="10%" align="left" style="font-size: 12px;padding-top: 3px;padding-bottom: 3px;<cfif qCustomerReport.CustomerInvoiceformat EQ 0>border-bottom: solid 1px;border-top: solid 1px;</cfif>"><i>Weight</i></th>
                                <th width="10%" align="left" style="font-size: 12px;padding-top: 3px;padding-bottom: 3px;<cfif qCustomerReport.CustomerInvoiceformat EQ 0>border-bottom: solid 1px;border-top: solid 1px;</cfif>"><i>Amount</i></th>
                            </tr>
                        </thead>                 
                    </table>
                    <div style="clear: both"></div>
                    <table width="97%" style="font-family: 'Arial';float:right;margin:0;" cellspacing="0" cellpadding="0">
                        <tbody>   
                            <cfloop group="StopNo">
                                <cfset bitShowComm = 1>
                                <cfsavecontent variable="Commodities">
                                    <cfloop  group="LoadStopCommoditiesID">
                                        <cfif qCustomerReport.CustCharges NEQ 0 OR qCustomerReport.Weight NEQ 0>
                                            <cfset vCustRate = qCustomerReport.CustRate>
                                            <cfset vCustCharges = qCustomerReport.CustCharges>
                                            <cfif qCustomerReport.PaymentAdvance EQ 1>
                                                <cfset vCustRate = -1*vCustRate>
                                                <cfset vCustCharges = -1*vCustCharges>
                                            </cfif>
                                            <tr>
                                                <td align="center" width="5%" style="font-size: 12px;border-top:1px solid;padding-bottom:3px;padding-top:3px;"><i>#qCustomerReport.Qty#</i></td>
                                                <td width="50%" align="left" style="font-size: 12px;padding-left:10px;border-top:1px solid;padding-bottom:3px;padding-top:3px;"><i>#qCustomerReport.Description# #qCustomerReport.Dimensions#</i></td>
                                                <td width="10%" align="left" style="font-size: 12px;border-top:1px solid;padding-bottom:3px;padding-top:3px;"><i>#qCustomerReport.Weight#</i></td>
                                                <td width="10%" align="left" style="font-size: 12px;border-top:1px solid;padding-bottom:3px;padding-top:3px;"><i>#Numberformat(vCustRate,"$__.__")#</i></td>
                                            </tr>
                                        </cfif>
                                    </cfloop>
                                </cfsavecontent>
                                <cfloop  group="LoadType">
                                <cfif qCustomerReport.CustomerInvoiceformat EQ 0>
                                    <cfif len(trim(qCustomerReport.StopName)) OR len(trim(qCustomerReport.StopAddress)) OR len(trim(qCustomerReport.StopCity)) OR len(trim(qCustomerReport.StopState)) OR len(trim(qCustomerReport.StopZip))>
                                        <cfset stopIndex++>
                                        <tr>
                                            <td width="9%" valign="top" align="left" style="font-size: 12px;padding-top: 3px;padding-left: 20px;<cfif qCustomerReport.StopNo NEQ qCustomerReport.StopNo[qCustomerReport.currentrow+1]>border-bottom: solid 1px;</cfif>">#stopIndex#</td>
                                            <td align="left" width="67%" valign="top" style="font-size: 12px;padding-top: 3px;<cfif qCustomerReport.StopNo NEQ qCustomerReport.StopNo[qCustomerReport.currentrow+1]>border-bottom: solid 1px;</cfif>">
                                                <i><cfif qCustomerReport.Blind EQ 0>#qCustomerReport.StopName#, #qCustomerReport.StopAddress#,</cfif> #qCustomerReport.StopCity#, #qCustomerReport.StopState#</i><br>
                                            </td>
                                            <td valign="top" align="center" width="30%" style="font-size: 12px;padding-top: 3px;<cfif qCustomerReport.StopNo NEQ qCustomerReport.StopNo[qCustomerReport.currentrow+1]>border-bottom: solid 1px;</cfif>">#Dateformat(qCustomerReport.StopDate,"mm/dd/yy")# #qCustomerReport.StopTime# #qCustomerReport.TimeZone#</td>
                                        </tr>
                                    </cfif>
                                </cfif>
                                </cfloop>                     
                                <cfif len(trim(qCustomerReport.StopName)) OR len(trim(qCustomerReport.StopAddress)) OR len(trim(qCustomerReport.StopCity)) OR len(trim(qCustomerReport.StopState)) OR len(trim(qCustomerReport.StopZip))>
                                    <cfif bitShowComm EQ 1 and len(trim(Commodities))>
                                        <tr>
                                            <td colspan="6" style="">
                                                <table width="85%" style="font-family: 'Arial';float:right;" cellspacing="0" cellpadding="0">
                                                    <tbody>
                                                        #Commodities#
                                                    </tbody>
                                                </table>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td colspan="6" <cfif qCustomerReport.CustomerInvoiceformat EQ 0>style="border-bottom:1px solid;"</cfif>>
                                                
                                            </td>
                                        </tr>
                                        <cfset bitShowComm = 0>
                                    </cfif>
                                </cfif>
                            </cfloop>                     
                        </tbody>          
                    </table>
                <div style="clear: both"></div>
                <table width="97%" style="font-family: 'Arial';float: right;margin-top:10px;" cellspacing="0" cellpadding="0" align="right">
                    <tbody>
                        <tr>
                            <td width="25%" colspan="2" style="font-size: 13px;border-top: solid 2px;border-bottom: solid 2px;padding-top: 3px;padding-bottom: 3px;">
                                <b>Flat Rate: </b>#DollarFormat(FlatRate)#
                            </td>
                            <td style="font-size: 13px;border-top: solid 2px;border-bottom: solid 2px;padding-top: 3px;padding-bottom: 3px;" align="left">
                                <b style="padding-right:20px;">+</b>
                            </td>
                            <td width="25%" colspan="2" style="font-size: 13px;border-top: solid 2px;border-bottom: solid 2px;padding-top: 3px;padding-bottom: 3px;">
                                <b>Miles Charge: </b>#DollarFormat(FlatMilesRate)#
                            </td>
                            <td style="font-size: 13px;border-top: solid 2px;border-bottom: solid 2px;padding-top: 3px;padding-bottom: 3px;" align="left">
                                <b style="padding-right:20px;">+</b>
                            </td>
                            <td width="25%" colspan="2" style="font-size: 13px;border-top: solid 2px;border-bottom: solid 2px;padding-top: 3px;padding-bottom: 3px;">
                                <b>Accessorials: </b>#DollarFormat(AccessorialsTotal)#
                            </td>
                            <td style="font-size: 13px;border-top: solid 2px;border-bottom: solid 2px;padding-top: 3px;padding-bottom: 3px;" align="left">
                                <b style="padding-right:20px;">+</b>
                            </td>
                            <td width="25%" colspan="2" style="font-size: 13px;border-top: solid 2px;border-bottom: solid 2px;padding-top: 3px;padding-bottom: 3px;">
                                <b>Payments: </b>#DollarFormat(PaymentsTotal)#
                            </td>
                        
                        </tr>  
                    </tbody>
                </table>
                <div style="clear: both"></div>
                <table width="97%" style="font-family: 'Arial';float: right;" cellspacing="0" cellpadding="0" align="right">
                    <tbody>
                        <tr style="">
                            <td width="50%" colspan="6" height="35%" style="font-size: 15px;border: solid 1px;padding-left:5px;height:30px;" align="left"><b>Terms:</b>#qCustomerReport.PaymentTerms#<cfif len(trim(duedate))><b style="padding-left:50px;">Due Date:</b>#DateFormat(DueDate,'mmmm dd, yyyy')#</cfif><b style="<cfif len(trim(duedate))>padding-left:50px;<cfelse>padding-left:300px;</cfif>">Amount Due:</b>#DollarFormat(qCustomerReport.AmountFC)# <cfif qCustomerReport.ForeignCurrencyEnabled EQ 1 AND len(trim(qCustomerReport.CurrencyNameISO))>#qCustomerReport.CurrencyNameISO#</cfif></td>
                        </tr>
                    </tbody>
                </table>
                <div style="clear: both"></div>
                <table width="97%" style="font-family: 'Arial';float: right;" cellspacing="0" cellpadding="0">
                    <tbody>
                        <tr>
                            <td style="font-size:12px;">#replace(qCustomerReport.InvoiceRemitInformation,Chr(10),'<br>','ALL')#</td>
                        </tr>
                        <tr>
                            <td style="font-size:14px;padding-top: 5px;">#replace(qCustomerReport.PricingNotes,Chr(10),'<br>','ALL')#</td>                       
                        </tr>
                        <cfif qCustomerReport.ShowCustomerTermsOnInvoice>
                            <tr>
                                <td style="font-size:12px;padding-top:15px;">#replace(qCustomerReport.CustomerTerms,Chr(10),'<br>','ALL')#</td>
                            </tr>
                        </cfif>
                    </tbody>
                </table>

            </cfloop>
            <div style="clear: both"></div>
            <cfdocumentitem type="footer">
				<table width="100%" style="font-family: 'Arial';border-top: solid 1px;" cellspacing="0" cellpadding="0">
					<tbody>
						<tr>
							<td width="33%" style="font-size: 12px;padding-top: 3px;">#DateFormat(Now(), "mm/dd/yyyy")#</td>
							<td align="right" width="47%" style="font-size: 12px;padding-top: 3px;">Load##: #qCustomerReport.LoadNumber#</td>
							<td width="20%" align="right" style="font-size: 12px;padding-top: 3px;">Page #cfdocument.currentpagenumber# of #cfdocument.totalpagecount#</td>
						</tr>
					</tbody>
				</table>
			</cfdocumentitem>             
        </cfdocument>
        <cfset PDFinfo=StructNew()> 
		<cfset PDFinfo.Title="CustomerDocumentReport"> 
		<cfset fileName = "#qCustomerReport.ReportTitle# ###qCustomerReport.LoadNumber# Date-#DateFormat(Now(),'mm.dd.yyyy')#.pdf">
		<cfpdf action="setInfo" source="CustomerDocumentReport" info="#PDFinfo#" overwrite="yes">
        <cfif not isDefined("bitConsolidatedReport")>
    		<cfheader name="Content-Disposition" value="inline; filename=#fileName#">
        </cfif>
		<cfif qCustomerReport.StatusText EQ '9. Cancelled'>
			<cfpdf action="addwatermark" source="CustomerDocumentReport" image="../webroot/images/WM_Cancelled.png"name = "CustomerDocumentReport">
		</cfif>
    </cfoutput>
	<cfcatch>
        <cfdocument format="PDF" name="CustomerDocumentReport">
            <cfoutput>
                Unable To Generate Report.
            </cfoutput>
		</cfdocument>
		<cfset PDFinfo=StructNew()> 
		<cfset PDFinfo.Title="#qCustomerReport.ReportTitle#"> 
		<cfset fileName = "#qCustomerReport.ReportTitle# ###qCustomerReport.LoadNumber# Date-#DateFormat(Now(),'mm.dd.yyyy')#.pdf">
		<cfpdf action="setInfo" source="CustomerDocumentReport" info="#PDFinfo#" overwrite="yes">
		<cfheader name="Content-Disposition" value="inline; filename=#fileName#">

	</cfcatch>
</cftry>