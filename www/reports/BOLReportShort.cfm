<cftry>
	<cfoutput>
		<cfdocument format="PDF" name="BOLReportShort" margintop="0.01" marginleft="0.25" marginright="0.25" marginbottom="0.5">
            <cfloop query="qBOLReportShort" group="LoadID">
                <table width="100%" style="font-family: 'Arial';" cellspacing="0" cellpadding="0">
                    <tbody>
                        <tr>                        
                            <td width="35%" align="left" valign="top" style="padding-bottom: 10px;padding-top:10px;">
                                <cfif len(trim(qBOLReportShort.CompanyLogoName))>
                                    <cfif cgi.https EQ 'on'>
                                        <cfset imgurl = "https://#cgi.HTTP_HOST#/#trim(listFirst(cgi.SCRIPT_NAME,'/'))#/www/fileupload/img/#qBOLReportShort.CompanyCode#/logo/#qBOLReportShort.CompanyLogoName#">
                                    <cfelse>
                                        <cfset imgurl = "http://#cgi.HTTP_HOST#/#trim(listFirst(cgi.SCRIPT_NAME,'/'))#/www/fileupload/img/#qBOLReportShort.CompanyCode#/logo/#qBOLReportShort.CompanyLogoName#">
                                    </cfif>
                                    <cfscript>
                                        if(fileExists(imgurl)){
                                            imgObj = imageRead(imgurl);
                                            imgObj.scaleTofit(180,70);
                                            cfimage(action="writeToBrowser", source=imgObj)
                                        }
                                    </cfscript>
                                </cfif>
                            </td>
                            <td align="left" style="font-weight: bold;font-size: 18px;">STRAIGHT BILL OF LADING</td>
                        </tr>
                    </tbody>
                </table>
                <table width="49%"  style="font-family: 'Arial';float:left;margin-top:4px;height:120px;" cellspacing="0" cellpadding="0" align="right">
                    <thead>
                        <tr>
                            <th width="100%" style="font-size: 13px;background-color: ##cccccc;border: solid 1px;padding-left:5px;" align="center">BILL TO:</th>
                        </tr>
                    </thead>
                    <tbody>
                        <tr>
                            <td style="font-size: 13px;font-weight: bold;border-left:1px solid;border-right:1px solid;padding:4px 0 5px 3px;height:10px;">#qBOLReportShort.CustomerName#</td>
                        </tr>
                        <tr>
                            <td style="font-size: 13px;font-weight: lighter;border-left:1px solid;border-right:1px solid;height:10px;padding:4px 0 5px 3px;">#qBOLReportShort.CustomerAddress#</td>
                        </tr>
                        <tr>
                            <td style="font-size: 13px;font-weight: lighter;border-left:1px solid;border-bottom:1px solid;border-right:1px solid;padding:4px 0 5px 3px;;height:15px;padding-bottom:4px">#qBOLReportShort.CustomerCity#, #qBOLReportShort.CustomerState#, #qBOLReportShort.CustomerZipCode#</td>
                        </tr>
                        <tr>
                        <td>
                            <table width="100%" style="font-family: 'Arial';float: left;" cellspacing="0" cellpadding="0">
                                <tbody>
                                    <tr>
                                        <td width="45%" style="font-size: 13px;padding:2px 0 2px 3px;"><b>Phone: #qBOLReportShort.Phone#</b></td>
                                        <td width="55%" style="font-size: 13px;padding:2px 0 2px 3px;"><b>Fax: #qBOLReportShort.Fax#</b></td>
                                    </tr>
                                </tbody>
                            </table>
                        </td>
                        </tr>
                    </tbody>
                </table>
                <table width="49%" style="font-family: 'Arial';float:right;position:relative;top:-30px;" cellspacing="0" cellpadding="0" align="right">
                    <tbody>
                        <tr>
                            <td></td>
                            <td style="border-right:1px solid;"></td>
                            <td align="center" style="font-size: 13px;font-weight: bold;border-right:1px solid;border-top:1px solid;padding:2px 0 2px 0;background-color: ##cccccc">BOL ##</td>
                            <td valign="top" style="font-size: 13px;font-weight: lighter;border-right:1px solid;border-top:1px solid;padding:2px 0 2px 3px;">#qBOLReportShort.LoadNumber#</td>
                        </tr>
                        <tr>
                            <td></td>
                            <td style="border-right:1px solid;"></td>
                            <td align="center" style="font-size: 13px;font-weight: bold;border-right:1px solid;border-top:1px solid;padding:2px 0 2px 0;background-color: ##cccccc">PO ##</td>
                            <td style="font-size: 13px;font-weight: lighter;border-right:1px solid;border-top:1px solid;padding:2px 0 2px 3px;">#qBOLReportShort.RefNo#</td>
                        </tr>
                        
                            <tr>
                                <td width="13%" align="center" style="font-size: 13px;font-weight: bold;border-left:1px solid;border-right:1px solid;border-bottom:1px solid;padding:2px 0 2px 0;border-top:1px solid;background-color: ##cccccc">PickUp</td>
                                <td width="20%" style="font-size: 13px;font-weight: lighter;border-right:1px solid;border-bottom:1px solid;border-top:1px solid;padding:2px 0 2px 3px;">#Dateformat(qBOLReportShort.PickupDate,"mm/dd/yyyy")#</td>
                                <td width="13%" align="center" style="font-size: 13px;font-weight: bold;border-right:1px solid;border-bottom:1px solid;border-top:1px solid;padding:2px 0 2px 0;background-color: ##cccccc">Delivery</td>
                                <td width="30%" style="font-size: 13px;font-weight: lighter;border-right:1px solid;border-bottom:1px solid;border-top:1px solid;padding:2px 0 2px 3px;">#Dateformat(qBOLReportShort.DeliveryDate,"mm/dd/yyyy")#</td>
                            </tr>
                    </tbody>
                </table>
                <div style="clear: both"></div>
                <table width="49%" style="font-family: 'Arial';float:right;position:relative;top:-80px;" cellspacing="0" cellpadding="0" align="right">
                    <tbody>
                        <tr>
                            <td  width="55%" align="center" style="font-size: 13px;font-weight: bold;border-left:1px solid;border-right:1px solid;border-top:1px solid;padding:2px 0 2px 0;background-color: ##cccccc">Emergency Response Number :</td>
                            <td width="35%" style="font-size: 13px;font-weight: lighter;border-right:1px solid;border-top:1px solid;padding:2px 0 2px 3px;">#qBOLReportShort.EmergencyResponseNo#</td>
                        </tr>
                    </tbody>
                </table>
                <div style="clear: both"></div>
                <table width="49%" style="font-family: 'Arial';float:right;position:relative;top:-80px;" cellspacing="0" cellpadding="0" align="right">
                    <tbody>
                        <tr>
                            <td  width="15%" align="center" style="font-size: 13px;font-weight: bold;border-left:1px solid;border-right:1px solid;border-top:1px solid;padding:2px 0 2px 0;background-color: ##cccccc;">Driver:</td>
                            <td width="65%" style="font-size: 13px;font-weight: lighter;border-right:1px solid;border-top:1px solid;padding:2px 0 2px 3px;">#qBOLReportShort.shipperDriverName#</td>
                        </tr>
                        <tr>
                            <td colspan="" width="15%" align="center" style="font-size: 13px;font-weight: bold;border-left:1px solid;border-right:1px solid;border-top:1px solid;padding:2px 0 2px 0;background-color: ##cccccc;border-bottom:1px solid;">Carrier:</td>
                            <td width="65%" style="font-size: 13px;font-weight: lighter;border-right:1px solid;border-top:1px solid;padding:2px 0 2px 3px;border-bottom:1px solid;">#qBOLReportShort.CarrierName#</td>
                        </tr>
                    </tbody>
                </table>
                <div style="clear: both"></div>
                    <table width="49%" style="font-family: 'Arial';float:left;margin-top:4px;position:relative;top:-70px;" cellspacing="0" cellpadding="0" align="right">
                        <thead>
                            <tr>
                                <th width="100%" style="font-size: 13px;background-color: ##cccccc;border: solid 1px;padding-left:1px;" align="left">PICKUP: #qBOLReportShort.shipperReleaseNo#</th>
                            </tr>
                        </thead>
                        <tbody>
                            <tr>
                                <td style="font-size: 13px;font-weight: lighter;border-left:1px solid;border-right:1px solid;padding:4px 0 5px 3px;height:15px;">#qBOLReportShort.shipperStopName#</td>
                            </tr>
                            <tr>
                                <td style="font-size: 13px;font-weight: lighter;border-left:1px solid;border-right:1px solid;padding:4px 0 5px 3px;height:15px;">#qBOLReportShort.shipperLocation#</td>
                            </tr>
                            <tr>
                                <td style="font-size: 13px;font-weight: lighter;border-left:1px solid;border-bottom:1px solid;border-right:1px solid;padding:4px 0 5px 3px;padding-bottom:10px;height:15px;">#qBOLReportShort.shipperCity#, #qBOLReportShort.shipperState#, #qBOLReportShort.shipperPostalCode#</td>
                            </tr>
                            <tr>
                                <td>
                                    <table width="100%" style="font-family: 'Arial';float: left;border-left:1px solid;border-right:1px solid;" cellspacing="0" cellpadding="0">
                                        <tbody>
                                            <tr>
                                                <td width="35%" style="font-size: 13px;padding:4px 0 5px 3px;"><b>Tel: </b>#qBOLReportShort.shipperPhone#</td>
                                                <td width="20%" style="font-size: 13px;padding:4px 0 5px 3px;"><b>Ext: </b>#qBOLReportShort.shipperPhoneExt#</td>
                                                <td width="45%" style="font-size: 13px;padding:4px 0 5px 3px;"><b>Fax: </b>#qBOLReportShort.shipperFax#</td>
                                            </tr>
                                        </tbody>
                                    </table>
                                </td>
                            </tr>
                            <tr>
                                <td>
                                    <table width="100%" style="font-family: 'Arial';border-left:1px solid;border-bottom:1px solid;border-right:1px solid;" cellspacing="0" cellpadding="0">
                                        <tbody>
                                            <tr>
                                                <td width="10%" style="font-size: 13px;padding:4px 0 5px 3px;"><b>Contact: </b></td>
                                                <td width="10%" style="font-size: 13px;padding:4px 0 5px 3px;">#qBOLReportShort.shipperContactPerson#</td>
                                                <td width="10%" style="font-size: 13px;padding:4px 0 5px 3px;"><b>Email: </b></td>
                                                <cfset strText = qBOLReportShort.shipperEmailID>
                                                <cfset CountVar = 24>
                                                <cfset strTextNew = "">
                                                <cfloop index="intChar" from="1" to="#Len( strText )#" step="1">
                                                    <cfif intChar EQ CountVar AND len(strText) GT CountVar>
                                                        <cfset strTextNew &= '<br>'&mid(strText, intChar, 1)>
                                                        <cfset CountVar = CountVar+24>
                                                    <cfelse>
                                                        <cfset strTextNew &= mid(strText, intChar, 1)>
                                                    </cfif>
                                                </cfloop>
                                                <td width="70%" style="font-size: 13px;padding:4px 0 5px 3px;height:30px;">#strTextNew#</td>
                                            </tr>
                                        </tbody>
                                    </table>
                                </td>
                            </tr>
                        </tbody>
                    </table>
                    <table width="49%" style="font-family: 'Arial';float:right;margin-top:4px;position:relative;top:-70px;" cellspacing="0" cellpadding="0" align="right">
                        <thead>
                            <tr>
                                <th width="100%" style="font-size: 13px;background-color: ##cccccc;border: solid 1px;padding-left:1px;" align="left">DELIVERY:</th>
                            </tr>
                        </thead>
                        <tbody>
                            <tr>
                                <td style="font-size: 13px;font-weight: lighter;border-left:1px solid;border-right:1px solid;padding:4px 0 5px 3px;height:15px;">#qBOLReportShort.consigneeStopName#</td>
                            </tr>
                            <tr>
                                <td style="font-size: 13px;font-weight: lighter;border-left:1px solid;border-right:1px solid;padding:4px 0 5px 3px;height:15px;">#qBOLReportShort.consigneeLocation#</td>
                            </tr>
                            <tr>
                                <td style="font-size: 13px;font-weight: lighter;border-left:1px solid;border-bottom:1px solid;border-right:1px solid;padding:4px 0 5px 3px;padding-bottom:10px;height:15px;">#qBOLReportShort.consigneeCity#, #qBOLReportShort.consigneeState#, #qBOLReportShort.consigneePostalCode#</td>
                            </tr>
                            <tr>
                                <td>
                                    <table width="100%" style="font-family: 'Arial';float: left;border-left:1px solid;border-right:1px solid;" cellspacing="0" cellpadding="0">
                                        <tbody>
                                            <tr>
                                                <td width="35%" style="font-size: 13px;padding:4px 0 5px 3px;"><b>Tel: </b>#qBOLReportShort.consigneePhone#</td>
                                                <td width="20%" style="font-size: 13px;padding:4px 0 5px 3px;"><b>Ext: </b>#qBOLReportShort.consigneePhoneExt#</td>
                                                <td width="45%" style="font-size: 13px;padding:4px 0 5px 3px;"><b>Fax: </b>#qBOLReportShort.consigneeFax#</td>
                                            </tr>
                                        </tbody>
                                    </table>
                                </td>
                            </tr>
                            <tr>
                                <td>
                                    <table width="100%" style="font-family: 'Arial';border-left:1px solid;border-bottom:1px solid;border-right:1px solid;" cellspacing="0" cellpadding="0">
                                        <tbody>
                                            <tr>
                                                <td width="10%" style="font-size: 13px;padding:4px 0 5px 3px;"><b>Contact: </b></td>
                                                <td width="15%" style="font-size: 13px;padding:4px 0 5px 3px;">#qBOLReportShort.consigneeContactPerson#</td>
                                                <td width="10%" style="font-size: 13px;padding:4px 0 5px 3px;"><b>Email: </b></td>
                                                <cfset strText = qBOLReportShort.consigneeEmailID>
                                                <cfset CountVar = 24>
                                                <cfset strTextNew = "">
                                                <cfloop index="intChar" from="1" to="#Len( strText )#" step="1">
                                                    <cfif intChar EQ CountVar AND len(strText) GT CountVar>
                                                        <cfset strTextNew &= '<br>'&mid(strText, intChar, 1)>
                                                        <cfset CountVar = CountVar+24>
                                                    <cfelse>
                                                        <cfset strTextNew &= mid(strText, intChar, 1)>
                                                    </cfif>
                                                </cfloop>
                                                <td width="65%" style="font-size: 13px;padding:4px 0 5px 3px;height:30px;">#strTextNew#</td>
                                            </tr>
                                        </tbody>
                                    </table>
                                </td>
                            </tr>
                        </tbody>
                    </table>
                <div style="clear: both"></div>
               <table width="100%" style="font-family: 'Arial';float: right;position:relative;top:-60px;" cellspacing="0" cellpadding="0">
                <thead>
                        <th width="56%" style="font-size: 13px;background-color: ##cccccc;border: solid 1px;padding-top:4px;padding-bottom:4px;">Description</th>
                        <th width="10%" style="font-size: 13px;background-color: ##cccccc;border-top: solid 1px;border-right: solid 1px;border-bottom: solid 1px;padding-top:4px;padding-bottom:4px;">Hazmat</th>
                        <th width="10%" style="font-size: 13px;background-color: ##cccccc;border-top: solid 1px;border-right: solid 1px;border-bottom: solid 1px;padding-top:4px;padding-bottom:4px;">Class</th>
                        <th width="10%" style="font-size: 13px;background-color: ##cccccc;border-top: solid 1px;border-right: solid 1px;border-bottom: solid 1px;padding-top:4px;padding-bottom:4px;">Piece(s)</th>
                        <th width="14%" style="font-size: 13px;background-color: ##cccccc;border-top: solid 1px;border-right: solid 1px;border-bottom: solid 1px;padding-top:4px;padding-bottom:4px;">Weight(lbs)</th>
                    </thead>
                    <tbody>
                        <cfset table = 0>
                        <cfset TotalPieces = 0>
                        <cfset TotalWeight = 0>
                        <cfloop group="LoadStopIDBOL">
                            <cfsavecontent variable="Commodities">
                                <cfloop group="SrNo">
                                    <cfif len(trim(qBOLReportShort.Description)) OR len(trim(qBOLReportShort.Hazmat)) OR len(trim(qBOLReportShort.ClassID)) OR (qBOLReportShort.qty NEQ 0 OR qBOLReportShort.Weight NEQ 0)>
                                        <cfset table = 1>
                                        <cfset TotalPieces = TotalPieces + qBOLReportShort.qty>
                                        <cfset TotalWeight = TotalWeight + qBOLReportShort.Weight>
                                        <tr>
                                            <td align="left" style="font-size: 13px;border-bottom: solid 1px;border-left: solid 1px;padding-top:3px;padding-bottom:3px;">#qBOLReportShort.Description#</td>
                                            <td align="center" style="font-size: 13px;border-bottom: solid 1px;border-left: solid 1px;padding-top:3px;padding-bottom:3px;">#qBOLReportShort.Hazmat#</td>

                                            <td align="center" style="font-size: 13px;border-bottom: solid 1px;border-left: solid 1px;padding-top:3px;padding-bottom:3px;">#qBOLReportShort.ClassID#</td>
                                            <td align="right" style="font-size: 13px;border-bottom: solid 1px;border-left: solid 1px;padding-top:3px;padding-bottom:3px;">#qBOLReportShort.qty#</td>
                                            <td align="right" style="font-size: 13px;border-bottom: solid 1px;border-right: solid 1px;border-left: solid 1px;padding-top:3px;padding-bottom:3px;">#numberFormat(qBOLReportShort.Weight,'__.0')#</td>
                                        </tr>
                                    </cfif>
                                </cfloop>
                            </cfsavecontent>
                        </cfloop>
                        <cfif table EQ 1>
                            #Commodities#
                        <cfelse>
                            <tr>
                                <td align="left" style="font-size: 13px;border-bottom: solid 1px;border-left: solid 1px;padding-top:4px;padding-bottom:4px;"></td>
                                <td align="left" style="font-size: 13px;border-bottom: solid 1px;border-left: solid 1px;padding-top:4px;padding-bottom:4px;"></td>

                                <td align="left" style="font-size: 13px;border-bottom: solid 1px;border-left: solid 1px;padding-top:4px;padding-bottom:4px;"></td>
                                <td align="right" style="font-size: 13px;border-bottom: solid 1px;border-left: solid 1px;padding-top:4px;padding-bottom:4px;">0</td>
                                <td align="right" style="font-size: 13px;border-bottom: solid 1px;border-right: solid 1px;border-left: solid 1px;padding-top:4px;padding-bottom:4px;">0</td>
                            </tr>
                        </cfif>

                        <tr>
                            <td></td>
                            <td colspan="2" align="left" style="font-size: 13px;border-bottom: solid 1px;border-left: solid 1px;background-color: ##cccccc;font-weight:bold;padding-top:4px;padding-bottom:4px;">Total</td>
                            <td align="right" style="font-size: 13px;border-bottom: solid 1px;border-left: solid 1px;">#numberFormat(TotalPieces,'__.0')#</td>
                            <td align="right" style="font-size: 13px;border-bottom: solid 1px;border-left: solid 1px;border-right: solid 1px;">#numberFormat(TotalWeight,'__.0')#</td>
                        </tr>
                    </tbody>
                </table>     
                <div style="clear: both"></div>
                <table width="35%"style="font-family: 'Arial';position:relative;top:-86px;" cellspacing="0" cellpadding="0">
                    <tbody>
                        <tr>
                            <td width="45%"align="center" style="font-size: 13px;border-bottom: solid 1px;border-left: solid 1px;background-color: ##cccccc;font-weight:bold;padding-top:4px;padding-bottom:4px;border-top: solid 1px;">Declared Value</td>
                            <td align="right" style="font-size: 13px;border-right:1px solid;border-bottom: solid 1px;border-left: solid 1px;padding-top:4px;padding-bottom:4px;border-top: solid 1px;">#dollarformat(qBOLReportShort.DeclaredValue)#</td>
                        </tr>
                    </tbody>
                </table>  
                <div style="clear: both"></div>
                <table width="100%" style="font-family: 'Arial';position:relative;top:-70px;" cellspacing="0" cellpadding="0">
                    <thead>
                        <tr>
                            <th width="15%" style="font-size: 13px;background-color: ##cccccc;border-left: solid 1px;border-right: solid 1px;border-top: solid 1px;padding-left:5px;padding-top:4px;padding-bottom:4px;" align="left">Notes</th>
                            <th width="85%"><th>
                        </tr>
                    </thead>
                    <tbody>
                        <tr>
                            <td colspan="2" valign="top" height="50px" style="font-size: 13px;border: solid 1px;padding-left:5px;padding-top:4px;padding-bottom:4px;">#qBOLReportShort.Notes#</td>
                        </tr>
                    </tbody>
                </table>         
                <div style="clear: both"></div>
                <table width="100%" style="font-family: 'Arial';position:relative;top:-60px;" cellspacing="0" cellpadding="0">
                    <thead>
                        <tr>
                            <th width="15%" style="font-size: 13px;background-color: ##cccccc;border-left: solid 1px;border-right: solid 1px;border-top: solid 1px;padding-left:5px;padding-top:4px;padding-bottom:4px;" align="left">Terms</th>
                            <th width="85%"><th>
                        </tr>
                    </thead>
                    <tbody>
                        <tr>
                            <td colspan="2" style="border-top: solid 1px;"></td>
                        </tr>
                    </tbody>
                </table> 
                <div style="position:relative;top:-50px;font-family: 'Arial';font-size: 13px;">
                    #qBOLReportShort.ShortBOLTerms#
                </div>
            </cfloop>         
        </cfdocument>
        <cfset PDFinfo=StructNew()> 
		<cfset PDFinfo.Title="BOLReportShort"> 
		<cfset fileName = "BOL ###qBOLReportShort.LoadNumber# Date-#DateFormat(Now(),'mm.dd.yyyy')#.pdf">
		<cfpdf action="setInfo" source="BOLReportShort" info="#PDFinfo#" overwrite="yes">
		<cfheader name="Content-Disposition" value="inline; filename=#fileName#">
    </cfoutput>
	<cfcatch>
        <cfdocument format="PDF" name="BOLReportShort">
            <cfoutput>
                Unable To Generate Report.
            </cfoutput>
		</cfdocument>
		<cfset PDFinfo=StructNew()> 
		<cfset PDFinfo.Title="BOLReportShort"> 
		<cfset fileName = "BOL ###qBOLReportShort.LoadNumber# Date-#DateFormat(Now(),'mm.dd.yyyy')#.pdf">
		<cfpdf action="setInfo" source="BOLReportShort" info="#PDFinfo#" overwrite="yes">
		<cfheader name="Content-Disposition" value="inline; filename=#fileName#">

	</cfcatch>
</cftry>