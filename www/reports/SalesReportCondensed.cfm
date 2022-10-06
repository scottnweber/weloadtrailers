<cfoutput>
	<cfif qCommissionReportLoads.FreightBroker EQ 1>
		<cfset txtFreightBroker = "Carrier">
	<cfelseif qCommissionReportLoads.FreightBroker EQ 0>
		<cfset txtFreightBroker = "Driver">
	<cfelse>
		<cfset txtFreightBroker = "Carrier/<br>Driver">
	</cfif>
	<cfdocument format="PDF" name="SalesReport"  margintop="2" marginleft="0.10" marginright="0.10" marginbottom="0.5">
		<style type="text/css">
			.LoadData td{
				font-size: 11px;
				padding-bottom: 5px;
				padding-top: 5px;
			}
			td[align='right']{
				padding-right: 2px;
			}
			.GroupData td{
				font-size: 11px;
				border-bottom: solid 1px;
			}
			.GroupTotalData td{
				font-size: 12px;
				font-weight: bold;
				border-top: solid 1px;
				padding-top: 5px;
				padding-bottom: 25px;
			}
			.GrandTotalData td{
				font-size: 12px;
				font-weight: bold;
				border-top: solid 1px;
				padding-top: 5px;
				padding-bottom: 25px;
			}
		</style>
		<cfdocumentitem type="header">
			<style type="text/css">
				.LoadHeader td{
					font-size: 11px;
					font-weight: bold;
					border-top: solid 1px;
					border-bottom: solid 1px;
					//padding-top: 5px;
					//padding-bottom: 5px;
				}
				td[align='right']{
					padding-right: 2px;
				}
			</style>
			<table width="100%" style="font-family: 'Arial Narrow';height: 100%;" cellspacing="0" cellpadding="0">
				<tr>
					<td width="30%" valign="bottom">
						<cfif cgi.https EQ 'on'>
							<cfset imgurl = "https://#cgi.HTTP_HOST#/#trim(listFirst(cgi.SCRIPT_NAME,'/'))#/www/fileupload/img/#qCommissionReportLoads.CompanyCode#/logo/#qCommissionReportLoads.CompanyLogoName#">
						<cfelse>
							<cfset imgurl = "http://#cgi.HTTP_HOST#/#trim(listFirst(cgi.SCRIPT_NAME,'/'))#/www/fileupload/img/#qCommissionReportLoads.CompanyCode#/logo/#qCommissionReportLoads.CompanyLogoName#">
						</cfif>
						<cfscript>
							if(fileExists(imgurl)){
								imgObj = imageRead(imgurl);
								imgObj.scaleTofit(106,53);
								cfimage(action="writeToBrowser", source=imgObj)
							}
						</cfscript>
					</td>
					<td width="40%" align="center" style="font-weight: bold;font-size: 18px;" valign="middle">
						<i><cfif groupsBy EQ 'none'>Load<cfelseif groupsBy EQ 'salesAgent'>Agent<cfelseif groupsBy EQ 'dispatcher'>Dispatcher<cfelseif groupsBy EQ 'customername'>Customer<cfelseif groupsBy EQ 'carrier'>Carrier</cfif> <cfif reportType EQ "Commission" AND groupsBy EQ 'salesAgent'>Commission </cfif>Report</i>
						<br>#qCommissionReportLoads.CompanyName#
					</td>
					<td width="30%" align="right" valign="bottom">
						<cfif variables.ShowReportCriteria EQ 1>
							<table width="100%" style="font-family: 'Arial Narrow';font-size: 8px;" cellspacing="0" cellpadding="0">
								<tr>
									<td align="right"><b>From <cfif DateType EQ "Shipdate">Pickup<cfelseif DateType EQ "Deliverydate">Delivery<cfelseif DateType EQ "Invoicedate">Invoice<cfelse>Created</cfif> Date: </b></td>
									<td>#DateFrom#</td>
									<td align="right"><b>To: </b></td>
									<td>#DateTo#</td>
								</tr>
								<tr>
									<td align="right"><b>From Sales Agent</b></td>
									<td>#salesRepFrom#</td>
									<td align="right"><b>To: </b></td>
									<td>#salesRepTo#</td>
								</tr>
								<tr>
									<td align="right"><b>From Dispatcher:</b></td>
									<td>#dispatcherFrom#</td>
									<td align="right"><b>To: </b></td>
									<td>#dispatcherTo#</td>
								</tr>
								<tr>
									<td align="right"><b>From Gross Mrg:</b></td>
									<td>#marginRangeFrom#</td>
									<td align="right"><b>To: </b></td>
									<td>#marginRangeTo#</td>
								</tr>
								<tr>
									<td align="right"><b>From Equipment:</b></td>
									<td>#equipmentFrom#</td>
									<td align="right"><b>To: </b></td>
									<td>#equipmentTo#</td>
								</tr>
								<tr>
									<td align="right"><b>From Customer:</b></td>
									<td>#customerFrom#</td>
									<td align="right"><b>To: </b></td>
									<td>#customerTo#</td>
								</tr>
								<tr>
									<td align="right"><b>From #txtFreightBroker#:</b></td>
									<td>#carrierFrom#</td>
									<td align="right"><b>To: </b></td>
									<td>#carrierTo#</td>
								</tr>
								<tr>
									<td align="right"><b>Group By:</b></td>
									<td colspan="3">#groupsBy#</td>
								</tr>
							</table>
						<cfelse>
							&nbsp;
						</cfif>
					</td>
				</tr>
				<tr>
					<td colspan="3" valign="bottom">
						<table width="100%" cellspacing="0" cellpadding="0" style="font-family: 'Arial';">
							<tr class="LoadHeader">
								<td align="right" width="40" valign="bottom">Load##</td>
								<td align="right" width="45" valign="bottom"><cfif DateType EQ "Shipdate">Pickup<cfelseif DateType EQ "Deliverydate">Delivery<cfelseif DateType EQ "Invoicedate">Invoice<cfelse>Created</cfif> Date</td>
								<td width="<cfif reportType EQ "Commission">120<cfelse>165</cfif>" valign="bottom"><cfif structKeyExists(url, "customerStatus") AND url.customerStatus EQ 1>&nbsp;<cfelse>Customer</cfif></td>
								<td width="70" valign="bottom">First Stop</td>
								<td width="70" valign="bottom">Last Stop</td>
								<td align="right" width="55" valign="bottom"><cfif groupsBy EQ 'Carrier'><cfif reportType EQ "Sales" AND qCommissionReportLoads.IsDispatch EQ 1>Dispatch Service Fee<cfelse>&nbsp;</cfif><cfelse>Customer<br>Total</cfif></td>
								<td align="right" width="55" valign="bottom">#txtFreightBroker#<br>Total</td>
								<td align="right" width="55" valign="bottom"><cfif groupsBy EQ 'Carrier'>&nbsp;<cfelseif reportType EQ "Commission" AND structKeyExists(url, "NonCommissionable") AND url.NonCommissionable NEQ 1>Comm<br>Margin<cfelse>Gross<br>Margin</cfif></td>
								<td width="<cfif reportType EQ "Commission">120<cfelse>165</cfif>" valign="bottom">#txtFreightBroker#</td>
								<cfif reportType EQ "Commission">
									<td align="right" width="60" valign="bottom"><cfif qCommissionReportLoads.IsDispatch EQ 1>Dispatch<br>Service<br>Amount<cfelse>Sales<br>Agent<br>Commission</cfif></td>
									<td align="right" width="30" valign="bottom">&nbsp;</td>
								</cfif>	
								<td align="right" width="30" valign="bottom">## of<br>Trips</td>
							</tr>
						</table>
					</td>
				</tr>
			</table>
		</cfdocumentitem>
		<table width="100%" cellspacing="0" cellpadding="0" style="font-family: 'Arial Narrow';">
			<cfset grandLoadCount = 0>
			<cfset grandCustomerTotal = 0>
			<cfset grandCarrierTotal = 0>
			<cfset grandGrossMarginTotal = 0>
			<cfset grandMargin = 0>
			<cfset grandNoOfTrips = 0>
			<cfset grandCommissionAmount =0>
			<cfloop query="qCommissionReportLoads" group="grpby">
				<cfif structKeyExists(url, "pageBreakStatus") AND url.pageBreakStatus EQ 1 AND qCommissionReportLoads.currentrow neq 1>
					</table>
					<cfdocumentitem type="pagebreak"></cfdocumentitem>
					<table width="100%" cellspacing="0" cellpadding="0" style="font-family: 'Arial Narrow';">
				</cfif>
				<cfset grpCustomerTotal = 0>
				<cfset grpCarrierTotal = 0>
				<cfset grpGrossMarginTotal= 0>
				<cfset grpMargin = 0>
				<cfset grpNoOfTrips = 0>
				<cfset grpCommissionAmount = 0>
				<cfset grpLoadCount = 0>
				<tr class="GroupData">
					<td colspan="<cfif reportType EQ "Commission">12<cfelse>10</cfif>">
						<cfif qCommissionReportLoads.grpby NEQ "none">
							<b><cfif groupsBy EQ 'salesagent'>Sales Agent<cfelseif groupsBy EQ 'dispatcher'>Dispatcher<cfelseif groupsBy EQ 'customername'>Customer<cfelseif groupsBy EQ 'carrier'>Carrier</cfif>: </b>#qCommissionReportLoads.grpby#
						</cfif>
					</td>
				</tr>
				<cfloop group="LoadNumber">
					<tr class="LoadData">
						<td align="right" width="40">#qCommissionReportLoads.LoadNumber#<cfif qCommissionReportLoads.HasLateStop EQ 1>*</cfif></td>
						<td align="right" width="45">#DateFormat(qCommissionReportLoads.OrderDate,'mm/dd/yyyy')#</td>
						<td width="<cfif reportType EQ "Commission">120<cfelse>165</cfif>"><cfif structKeyExists(url, "customerStatus") AND url.customerStatus EQ 1>&nbsp;<cfelse>#qCommissionReportLoads.CustName#</cfif></td>
						<td width="70">#qCommissionReportLoads.FirstStop#</td>
						<td width="70">#qCommissionReportLoads.LastStop#</td>
						<td align="right" width="55"><cfif groupsBy EQ 'Carrier'><cfif reportType EQ "Sales" AND qCommissionReportLoads.IsDispatch EQ 1>#DollarFormat(qCommissionReportLoads.CommissionAmountReport)#&nbsp;&nbsp;#qCommissionReportLoads.CommissionPercentReport#%<cfelse>&nbsp;</cfif><cfelse>#dollarFormat(qCommissionReportLoads.TotalCustomerCharges)#</cfif></td>
						<td align="right" width="55">#dollarFormat(qCommissionReportLoads.TotalCarrierCharges)#</td>
						<td align="right" width="55"><cfif groupsBy EQ 'Carrier'>&nbsp;<cfelseif reportType EQ "Commission" AND structKeyExists(url, "NonCommissionable") AND url.NonCommissionable NEQ 1>#dollarFormat(qCommissionReportLoads.GrossMargin - qCommissionReportLoads.CommissionAmountReport)#<cfelseif reportType EQ "Sales" AND qCommissionReportLoads.IsDispatch EQ 1>#dollarFormat(qCommissionReportLoads.GrossMargin - qCommissionReportLoads.TotalDirectCost)#<cfelse>#dollarFormat(qCommissionReportLoads.GrossMargin)#</cfif></td>
						<td width="<cfif reportType EQ "Commission">120<cfelse>165</cfif>">#qCommissionReportLoads.CarrierName#</td>
						<cfif reportType EQ "Commission">
							<td align="right" width="60">#DollarFormat(qCommissionReportLoads.CommissionAmountReport)#</td>
							<td align="right" width="30">#qCommissionReportLoads.CommissionPercentReport#%</td>
						</cfif>	
						<td align="right" width="30">#qCommissionReportLoads.NoOfTrips#</td>
					</tr>
					<cfset grpCustomerTotal = grpCustomerTotal + qCommissionReportLoads.TotalCustomerCharges>
					<cfset grpCarrierTotal = grpCarrierTotal + qCommissionReportLoads.TotalCarrierCharges>
					<cfif reportType EQ "Commission" AND structKeyExists(url, "NonCommissionable") AND url.NonCommissionable NEQ 1>
						<cfset grpGrossMarginTotal = grpGrossMarginTotal + (qCommissionReportLoads.GrossMargin - qCommissionReportLoads.CommissionAmountReport)>
					<cfelseif reportType EQ "Sales" AND qCommissionReportLoads.IsDispatch EQ 1>
						<cfset grpGrossMarginTotal = grpGrossMarginTotal + (qCommissionReportLoads.GrossMargin - qCommissionReportLoads.TotalDirectCost)>
					<cfelse>
						<cfset grpGrossMarginTotal = grpGrossMarginTotal + qCommissionReportLoads.GrossMargin>
					</cfif>
					<cfif grpCustomerTotal neq 0>
						<cfset grpMargin = (grpGrossMarginTotal/grpCustomerTotal)*100>
					</cfif>
					<cfset grpCommissionAmount = grpCommissionAmount + qCommissionReportLoads.CommissionAmountReport>
					<cfset grpNoOfTrips = grpNoOfTrips + qCommissionReportLoads.NoOfTrips>
					<cfset grpLoadCount++>
				</cfloop>
				<tr class="GroupTotalData">
					<td colspan="2">TOTAL</td>
					<td colspan="2">#grpLoadCount# Loads</td>
					<td><cfif groupsBy EQ 'Carrier'>&nbsp;<cfelse>Margin:#DecimalFormat(grpMargin)#%</cfif></td>
					<td align="right"><cfif groupsBy EQ 'Carrier'><cfif reportType EQ "Sales" AND qCommissionReportLoads.IsDispatch EQ 1>#DollarFormat(grpCommissionAmount)#<cfelse>&nbsp;</cfif><cfelse>#dollarFormat(grpCustomerTotal)#</cfif></td>
					<td align="right">#dollarFormat(grpCarrierTotal)#</td>
					<td align="right"><cfif groupsBy EQ 'Carrier'>&nbsp;<cfelse>#dollarFormat(grpGrossMarginTotal)#</cfif></td>
					<td>&nbsp;</td>
					<cfif reportType EQ "Commission">
						<td align="right">#dollarFormat(grpCommissionAmount)#</td>
						<td>&nbsp;</td>
					</cfif>
					<td colspan="2" align="right">#grpNoOfTrips#</td>
				</tr>
				<cfset grandLoadCount = grandLoadCount + grpLoadCount>
				<cfset grandCustomerTotal = grandCustomerTotal + grpCustomerTotal>
				<cfset grandCarrierTotal = grandCarrierTotal + grpCarrierTotal>
				<cfset grandGrossMarginTotal = grandGrossMarginTotal + grpGrossMarginTotal>
				<cfif grandCustomerTotal neq 0>
					<cfset grandMargin = (grandGrossMarginTotal/grandCustomerTotal)*100>
				</cfif>
				<cfset grandNoOfTrips = grandNoOfTrips + grpNoOfTrips>
				<cfset grandCommissionAmount = grandCommissionAmount + grpCommissionAmount>
			</cfloop>
			<tr class="GrandTotalData">
				<td colspan="2">GRAND TOTAL</td>
				<td colspan="2">#grandLoadCount# Loads</td>
				<td><cfif groupsBy EQ 'Carrier'>&nbsp;<cfelse>Margin:#DecimalFormat(grandMargin)#%</cfif></td>
				<td align="right"><cfif groupsBy EQ 'Carrier'><cfif reportType EQ "Sales" AND qCommissionReportLoads.IsDispatch EQ 1>#DollarFormat(grandCommissionAmount)#<cfelse>&nbsp;</cfif><cfelse>#dollarFormat(grandCustomerTotal)#</cfif></td>
				<td align="right">#dollarFormat(grandCarrierTotal)#</td>
				<td align="right"><cfif groupsBy EQ 'Carrier'>&nbsp;<cfelse>#dollarFormat(grandGrossMarginTotal)#</cfif></td>
				<td>&nbsp;</td>
				<cfif reportType EQ "Commission">
					<td align="right">#dollarFormat(grandCommissionAmount)#</td>
					<td>&nbsp;</td>
				</cfif>
				<td colspan="2" align="right">#grandNoOfTrips#</td>
			</tr>
		</table>
		<cfdocumentitem type="footer">
			<table width="100%" style="font-family: 'Arial Narrow';border-top: solid 1px;" cellspacing="0" cellpadding="0">
				<tbody>
					<tr>
						<td width="33%" style="font-size: 12px;padding-top: 3px;">#DateTimeFormat(Now(), "mmm dd, yyyy hh:nn tt")#</td>
						<td width="34%" align="center" style="font-size: 12px;padding-top: 3px;">*Load had a LATE stop.</td>
						<td width="33%" align="right" style="font-size: 12px;padding-top: 3px;">Page #cfdocument.currentpagenumber# of #cfdocument.totalpagecount#</td>
					</tr>
				</tbody>
			</table>
		</cfdocumentitem>
	</cfdocument>

	<cfset PDFinfo=StructNew()> 
	<cfset PDFinfo.Title="Load Report"> 
	<cfset fileName = "Load Commission Report Date-#DateFormat(Now(),'mm.dd.yyyy')#.pdf">
	<cfpdf action="setInfo" source="SalesReport" info="#PDFinfo#" overwrite="yes">
	<cfheader name="Content-Disposition" value="inline; filename=#fileName#">
	<cfif not isDefined("emailPDF")>
		<cfcontent type="application/pdf" variable="#tobinary(SalesReport)#">
	</cfif>
</cfoutput>