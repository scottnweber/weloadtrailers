<cftry>
	<cfswitch expression="#form.groupby#">
		<cfcase value="salesAgent">
			<cfset groupByText = "Sales Agent">
			<cfset groupByCol = "SalesRep">
			<cfif structKeyExists(form, "showCommision")>
				<cfset reportTitle = "Agent Commission Report">
			<cfelse>
				<cfset reportTitle = "Agent Report">
			</cfif>
		</cfcase>
		<cfcase value="dispatcher">
			<cfset groupByText = "Dispatcher">
			<cfset groupByCol = "Dispatcher">
			<cfset reportTitle = "Dispatcher Report">
		</cfcase>
		<cfcase value="customer">
			<cfset groupByText = "">
			<cfset groupByCol = "CustomerName">
			<cfset reportTitle = "Customer Report">
		</cfcase>
		<cfcase value="Carrier">
			<cfset groupByText = "">
			<cfset groupByCol = "CarrierName">
			<cfif form.freightBroker EQ 'Driver'>
				<cfset reportTitle = "Driver Settlement Report">
			<cfelse>
				<cfset reportTitle = "Carrier Report">
			</cfif>
		</cfcase>
		<cfdefaultcase>
			<cfset groupByText = "">
			<cfset groupByCol = "LoadNumber">
			<cfset reportTitle = "Load Report">
		</cfdefaultcase>
	</cfswitch>
	<cfoutput>
		<cfdocument format="PDF" name="SalesDetailReport" margintop="1.25" marginleft="0.10" marginright="0.10" marginbottom="0.5">
			<style type="text/css">
				.LoadData td{
					font-size: 12px;
					border-top: solid 1px lightgray;
					padding-top: 2px;
				}
				.OfficeData td{
					font-size: 12px;
					border-bottom: solid 1px;
				}
				.CommodityData td{
					font-size: 10px;
					font-style: italic;
					padding-top: 2px;
					padding-bottom: 2px;
				}
				td[align='right']{
					padding-right: 2px;
				}
				.LoadTotalData td{
					font-size: 12px;
					border-top: solid 1px;
					padding-bottom: 20px;
					padding-top: 2px;
					font-weight: bold;
				}
				.GroupTotalData td{
					font-size: 12px;
					font-weight: bold;
					padding-bottom: <cfif structKeyExists(form, "pagebreak") AND form.groupby neq 'none'>1<cfelse>20</cfif>px;
					padding-top: 2px;
				}
				.OfficeTotalData td{
					font-size: 12px;
					font-weight: bold;
					padding-bottom: <cfif structKeyExists(form, "pagebreak") AND form.groupby neq 'none'>1<cfelse>20</cfif>px;
					padding-top: 2px;
				}
				.GrandTotalData td{
					border-top: solid 1px;
					font-size: 12px;
					font-weight: bold;
					padding-top: 2px;
				}
			</style>
			<cfdocumentitem type="header">
				<style type="text/css">
					.LoadHeader td{
						font-size: 11px;
						font-weight: bold;
					}
					.CommodityHeader td{
						font-size: 9px;
						font-style: italic;
						font-weight: bold;
					}
					td[align='right']{
						padding-right: 2px;
					}
				</style>
				<table width="100%" style="font-family: 'Arial Narrow';height: 100%;" cellspacing="0" cellpadding="0">
					<tr>
						<td width="25%">
							<cfif cgi.https EQ 'on'>
								<cfset imgurl = "https://#cgi.HTTP_HOST#/#trim(listFirst(cgi.SCRIPT_NAME,'/'))#/www/fileupload/img/#session.usercompanycode#/logo/#form.CompanyLogoName#">
							<cfelse>
								<cfset imgurl = "http://#cgi.HTTP_HOST#/#trim(listFirst(cgi.SCRIPT_NAME,'/'))#/www/fileupload/img/#session.usercompanycode#/logo/#form.CompanyLogoName#">
							</cfif>
							<cfscript>
								if(fileExists(imgurl)){
									imgObj = imageRead(imgurl);
									imgObj.scaleTofit(106,53);
									cfimage(action="writeToBrowser", source=imgObj)
								}
							</cfscript>
						</td>
						<td width="50%" align="center" style="font-weight: bold;font-size: 18px;" valign="top">
							<i>#reportTitle#</i>
							<br>#form.CompanyName#</td>
						<td width="25%" align="right" valign="top">
							<table width="100%" style="font-family: 'Arial Narrow';font-size: 8px;" cellspacing="0" cellpadding="0">
								<tr>
									<td align="right"><b>From #form.datetype# Date: </b></td>
									<td>#form.datefrom#</td>
									<td align="right"><b>To: </b></td>
									<td>#form.dateto#</td>
								</tr>
								<tr>
									<td align="right"><b>From Status: </b></td>
									<td>#trim(replaceNoCase(REReplace(form.statusfrom,"[0-9]","","ALL"), ".", ""))#</td>
									<td align="right"><b>To: </b></td>
									<td>#trim(replaceNoCase(REReplace(form.statusto,"[0-9]","","ALL"), ".", ""))#</td>
								</tr>
								<cfif len(trim(form.officeFrom)) AND len(trim(form.officeTo))>
									<tr>
										<td align="right"><b>From Office: </b></td>
										<td>#left(form.officeFrom,10)#</td>
										<td align="right"><b>To: </b></td>
										<td>#left(form.officeTo,10)#</td>
									</tr>
								</cfif>
								<cfif len(trim(form.billFrom)) AND len(trim(form.billTo))>
									<tr>
										<td align="right"><b>From Bill From: </b></td>
										<td>#left(form.billFrom,10)#</td>
										<td align="right"><b>To: </b></td>
										<td>#left(form.billTo,10)#</td>
									</tr>
								</cfif>
								<cfif len(trim(salesRepFrom)) AND len(trim(salesRepTo))>
									<tr>
										<td align="right"><b>From Sales Rep: </b></td>
										<td>#form.salesRepFrom#</td>
										<td align="right"><b>To: </b></td>
										<td>#form.salesRepTo#</td>
									</tr>
								</cfif>
								<cfif len(trim(dispatcherFrom)) AND len(trim(dispatcherTo))>
									<tr>
										<td align="right"><b>From Dispatcher: </b></td>
										<td>#form.dispatcherFrom#</td>
										<td align="right"><b>To: </b></td>
										<td>#form.dispatcherTo#</td>
									</tr>
								</cfif>
								<cfif len(trim(customerFrom)) AND len(trim(customerTo))>
									<tr>
										<td align="right"><b>From Customer: </b></td>
										<td>#left(form.customerFrom,10)#</td>
										<td align="right"><b>To: </b></td>
										<td>#left(form.customerTo,10)#</td>
									</tr>
								</cfif>
								<cfif len(trim(equipmentFrom)) AND len(trim(equipmentTo))>
									<tr>
										<td align="right"><b>From Equipment: </b></td>
										<td>#left(form.equipmentFrom,10)#</td>
										<td align="right"><b>To: </b></td>
										<td>#left(form.equipmentTo,10)#</td>
									</tr>
								</cfif>
								<cfif len(trim(carrierFrom)) AND len(trim(carrierTo))>
									<tr>
										<td align="right"><b>From #form.freightBroker#: </b></td>
										<td>#left(form.carrierFrom,10)#</td>
										<td align="right"><b>To: </b></td>
										<td>#left(form.carrierTo,10)#</td>
									</tr>
								</cfif>
							</table>
						</td>
					</tr>
					<tr>
						<td colspan="3" valign="bottom">
							<cfif not listFindNoCase('none,customer,carrier', form.groupby)>
								<cfset colspan = 7>
							<cfelse>
								<cfset colspan = 6>
							</cfif>
							<cfif structKeyExists(form, "dispatcherSplitAmt")>
								<cfset colspan = colspan+1>
							</cfif>
							<table width="100%" cellspacing="0" cellpadding="0" style="font-family: 'Arial';border-bottom: solid 1px;">
								<tr class="LoadHeader">
									<cfif not listFindNoCase('none,customer,carrier', form.groupby)>
										<td width="100">#groupByText#</td>
									</cfif>
									<td width="54" align="right">Load##</td>
									<td width="70" align="right">Pickup Date</td>
									<td width="153">Customer</td>
									<td width="153">#form.freightBroker#</td>
									<td width="169">Pickup City, State - Delivery City, State</td>
									<td width="51" align="right">## of trips</td>
								</tr>
								<tr>
								<td width="<cfif structKeyExists(form, "dispatcherSplitAmt")>750<cfelse>650</cfif>" colspan="#colspan#" style="padding-left: <cfif structKeyExists(form, "dispatcherSplitAmt")>50<cfelse>100</cfif>px;">
										<table width="100%" cellspacing="0" cellpadding="0" style="font-family: 'Arial';">
											<tr class="CommodityHeader">
												<td <cfif structKeyExists(form, "showCommision")>width="354"<cfelse>width="456"</cfif> align="right">Cust. Amt</td>
												<td width="64" align="right">Carr. Amt</td>
												<td width="57" align="right" >Direct Cost</td>
												<td width="51" align="right">Margin</td>
												<cfif structKeyExists(form, "dispatcherSplitAmt")>
													<td width="50" align="right">Split<br>Margin</td>
												</cfif>
												<cfif structKeyExists(form, "showCommision")>
													<td width="51" align="right">Comm %</td>
													<td width="51" align="right">Amount</td>
												</cfif>
											</tr>
										</table>
									</td>
								</tr>
							</table>
						</td>
					</tr>
				</table>
			</cfdocumentitem>
			<table width="100%" cellspacing="0" cellpadding="0" style="font-family: 'Arial Narrow';margin-top: -10px;">			
				<cfset grandCustRate = 0>
				<cfset grandCarrRate = 0>
				<cfset grandDirectCostTotal = 0>
				<cfset grandMargin = 0>
				<cfset grandSplitMargin = 0>
				<cfset grandAmount = 0>
				<cfset grandNoOfTrips = 0>
				<cfset officePageBreak = 0>
				<cfloop query="qSalesDetail" group="OfficeCode">
					<cfif structKeyExists(form, "showOfficeSubtotal")>
						<cfif structKeyExists(form, "pagebreak") AND qSalesDetail.currentrow neq 1 AND form.groupby neq 'none'>
							<cfset officePageBreak = 1>
							</table>
							<cfdocumentitem type="pagebreak"></cfdocumentitem>
							<table width="100%" cellspacing="0" cellpadding="0" style="font-family: 'Arial Narrow';">
						</cfif>
						<tr class="OfficeData">
							<td colspan="#colspan#"><b>Office: </b>#qSalesDetail.OfficeCode#</td>
						</tr>
						<tr><td colspan="#colspan#">&nbsp;</td></tr>
					</cfif>
					<cfset ofcCustRate = 0>
					<cfset ofcCarrRate = 0>
					<cfset ofcDirectCostTotal = 0>
					<cfset ofcMargin = 0>
					<cfset ofcSplitMargin = 0>
					<cfset ofcAmount = 0>
					<cfset ofcNoOfTrips = 0>
					<cfloop group="#groupByCol#">
						<!--- PageBreak --->
						<cfif structKeyExists(form, "pagebreak") AND qSalesDetail.currentrow neq 1 AND form.groupby neq 'none' AND officePageBreak EQ 0>
							</table>
							<cfdocumentitem type="pagebreak"></cfdocumentitem>
							<table width="100%" cellspacing="0" cellpadding="0" style="font-family: 'Arial Narrow';">
						</cfif>
						<cfset officePageBreak = 0>
						<!--- PageBreak --->
						<cfset grpCustRate = 0>
						<cfset grpCarrRate = 0>
						<cfset grpDirectCostTotal = 0>
						<cfset grpMargin = 0>
						<cfset grpSplitMargin = 0>
						<cfset grpAmount = 0>
						<cfset grpNoOfTrips = 0>
						<cfset grpLoadCount = 0>
						<cfloop group="LoadNumber">
							<tr class="LoadData">
								<cfif not listFindNoCase('none,customer,carrier', form.groupby)>
									<td width="100" valign="top">#qSalesDetail['#groupByCol#'][currentrow]#</td>
								</cfif>
								<td width="54" align="right" valign="top">#qSalesDetail.LoadNumber#<cfif qSalesDetail.HasLateStop EQ 1>*</cfif></td>
								<td width="70" align="right" valign="top">#DateFormat(qSalesDetail.PickupDate,'mm/dd/yyyy')#</td>
								<td width="153" valign="top">#qSalesDetail.CustomerName#</td>
								<td width="153" valign="top">#qSalesDetail.CarrierName#</td>
								<td width="169" valign="top">#qSalesDetail.PickupCityStateDeliveryCityState#</td>
								<td width="51" align="right" valign="top">#qSalesDetail.NoOftrips#</td>
							</tr>
							<tr>
								<td width="<cfif structKeyExists(form, "dispatcherSplitAmt")>750<cfelse>650</cfif>" colspan="#colspan#" style="padding-left: <cfif structKeyExists(form, "dispatcherSplitAmt")>50<cfelse>100</cfif>px;">
									<table width="100%" cellspacing="0" cellpadding="0" style="font-family: 'Arial Narrow';">
										<tr class="CommodityData">
											<cfset CustAmt = qSalesDetail["Cust Amt"]>
											<cfset CarrAmt = qSalesDetail["Carr Amt"]>
											<cfset DirectCost = qSalesDetail["Direct Cost"]>
											<cfset Comm = qSalesDetail["Comm %"]>
											<cfif structKeyExists(form, "dispatcherSplitAmt") AND qSalesDetail.DispatchSplitAmt NEQ 0>
												<cfset CommAmt = qSalesDetail.DispatchSplitAmt * (Comm/100)>
											<cfelse>
												<cfset CommAmt = qSalesDetail["Comm Amt"]>
											</cfif>
											<td <cfif structKeyExists(form, "showCommision")>width="354"<cfelse>width="456"</cfif> align="right" valign="top">#DollarFormat(CustAmt)#</td>
											<td width="64" align="right" valign="top">#DollarFormat(CarrAmt)#</td>
											<td width="57" align="right" valign="top">#DollarFormat(DirectCost)#</td>
											<td width="51" align="right" valign="top">#DollarFormat(qSalesDetail.Margin)#</td>
											<cfif structKeyExists(form, "dispatcherSplitAmt")>
												<td width="50" align="right" valign="top"><cfif qSalesDetail.DispatchSplitAmt NEQ 0>#DollarFormat(qSalesDetail.DispatchSplitAmt)#<cfelse>&nbsp;</cfif></td></td>
											</cfif>
											<cfif structKeyExists(form, "showCommision")>
												<td width="51" align="right" valign="top">#Comm# %</td>
												<td width="51" align="right" valign="top">#DollarFormat(CommAmt)#</td>
											</cfif>
										</tr>
									</table>
								</td>
							</tr>
							<cfset grpCustRate = grpCustRate + CustAmt>
							<cfset grpCarrRate = grpCarrRate + CarrAmt>
							<cfset grpDirectCostTotal = grpDirectCostTotal + DirectCost>
							<cfset grpMargin = grpMargin + qSalesDetail.Margin>
							<cfif structKeyExists(form, "dispatcherSplitAmt")>
								<cfset grpSplitMargin = grpSplitMargin + qSalesDetail.DispatchSplitAmt>
							</cfif>
							<cfset grpNoOfTrips = grpNoOfTrips + qSalesDetail.NoOftrips>
							<cfset grpAmount = grpAmount + CommAmt>
							<cfset grpLoadCount++>
						</cfloop>
						<cfif form.groupby neq 'none'>
							<tr>
								<td colspan="#colspan#">
									<table width="100%" cellspacing="0" cellpadding="0" style="font-family: 'Arial Narrow';">
										<tr>
											<td colspan="<cfif structKeyExists(form, "dispatcherSplitAmt")>8<cfelse>7</cfif>">
												<hr style="border-top:1px double black;border-bottom:1px double black;border-left: none;border-right: none;height: 5px;">
											</td>
										</tr>
										<tr class="GroupTotalData">
											<td <cfif structKeyExists(form, "showCommision")>width="<cfif structKeyExists(form, "dispatcherSplitAmt")>349<cfelse>399</cfif>"<cfelse>width="<cfif structKeyExists(form, "dispatcherSplitAmt")>451<cfelse>501</cfif>"</cfif>>Totals for #qSalesDetail['#groupByCol#'][currentrow]# <cfif form.groupby EQ "Customer"> - #grpLoadCount# Load(s)</cfif></td>
											<td width="64" align="right">#DollarFormat(grpCustRate)#</td>
											<td width="64" align="right">#DollarFormat(grpCarrRate)#</td>
											<td width="57" align="right">#DollarFormat(grpDirectCostTotal)#</td>
											<td width="51" align="right">#DollarFormat(grpMargin)#</td>
											<cfif structKeyExists(form, "dispatcherSplitAmt")>
												<td width="50" align="right" valign="top">#DollarFormat(grpSplitMargin)#</td></td>
											</cfif>
											<cfif structKeyExists(form, "showCommision")>
												<td width="51" align="right">#Comm# %</td>
												<td width="51" align="right">#DollarFormat(grpAmount)#</td>
											</cfif>
										</tr>
									</table>
								</td>
							</tr>
						</cfif>
						<cfset grandCustRate = grandCustRate + grpCustRate>
						<cfset grandCarrRate = grandCarrRate + grpCarrRate>
						<cfset grandDirectCostTotal = grandDirectCostTotal + grpDirectCostTotal>
						<cfset grandMargin = grandMargin + grpMargin>
						<cfset grandSplitMargin = grandSplitMargin + grpSplitMargin>
						<cfset grandNoOfTrips = grandNoOfTrips + grpNoOfTrips>
						<cfset grandAmount = grandAmount + grpAmount>

						<cfset ofcCustRate = ofcCustRate + grpCustRate>
						<cfset ofcCarrRate = ofcCarrRate + grpCarrRate>
						<cfset ofcDirectCostTotal = ofcDirectCostTotal + grpDirectCostTotal>
						<cfset ofcMargin = ofcMargin + grpMargin>
						<cfset ofcSplitMargin = ofcSplitMargin + grpSplitMargin>
						<cfset ofcAmount = ofcAmount + grpAmount>
						<cfset ofcNoOfTrips = ofcNoOfTrips + grpNoOfTrips>
					</cfloop>
					<cfif structKeyExists(form, "showOfficeSubtotal")>
						<tr>
							<td colspan="#colspan#">
								<table width="100%" cellspacing="0" cellpadding="0" style="font-family: 'Arial Narrow';">
									<tr>
										<td colspan="<cfif structKeyExists(form, "dispatcherSplitAmt")>8<cfelse>7</cfif>">
											<hr style="border-top:1px double black;border-bottom:1px double black;border-left: none;border-right: none;height: 5px;">
										</td>
									</tr>
									<tr class="OfficeTotalData">
										<td <cfif structKeyExists(form, "showCommision")>width="<cfif structKeyExists(form, "dispatcherSplitAmt")>349<cfelse>399</cfif>"<cfelse>width="<cfif structKeyExists(form, "dispatcherSplitAmt")>451<cfelse>501</cfif>"</cfif>>Total - #qSalesDetail.officecode#</td>
										<td width="64" align="right">#DollarFormat(ofcCustRate)#</td>
										<td width="64" align="right">#DollarFormat(ofcCarrRate)#</td>
										<td width="57" align="right">#DollarFormat(ofcDirectCostTotal)#</td>
										<td width="51" align="right">#DollarFormat(ofcMargin)#</td>
										<cfif structKeyExists(form, "dispatcherSplitAmt")>
											<td width="50" align="right" valign="top">#DollarFormat(ofcSplitMargin)#</td></td>
										</cfif>
										<cfif structKeyExists(form, "showCommision")>
											<td width="51" align="right">&nbsp;</td>
											<td width="51" align="right">#DollarFormat(ofcAmount)#</td>
										</cfif>
									</tr>
								</table>
							</td>
						</tr>
					</cfif>
				</cfloop>
				<cfif structKeyExists(form, "pagebreak") AND form.groupby neq 'none'>
					<tr>
						<td colspan="#colspan#">&nbsp;</td>
					</tr>
				</cfif>
				<tr>
					<td colspan="#colspan#">
						<table width="100%" cellspacing="0" cellpadding="0" style="font-family: 'Arial Narrow';">
							<tr>
								<td colspan="<cfif structKeyExists(form, "dispatcherSplitAmt")>8<cfelse>7</cfif>" align="right" style="font-size: 12; font-weight: bold;">#grandNoOfTrips#</td>
							</tr>
							<tr class="GrandTotalData">
								<td valign="bottom" <cfif structKeyExists(form, "showCommision")>width="<cfif structKeyExists(form, "dispatcherSplitAmt")>349<cfelse>399</cfif>"<cfelse>width="<cfif structKeyExists(form, "dispatcherSplitAmt")>451<cfelse>501</cfif>"</cfif>>GRAND TOTAL&nbsp;&nbsp;&nbsp;&nbsp;#qLateStopDetails.TotalLoads# Loads <span style="color: ##800000;">#qLateStopDetails.LateStops# of #qLateStopDetails.TotalStops# Late Stops (#round(qLateStopDetails.LateStopPerc)#%)</span></td>
								<td valign="bottom" width="64" align="right">#DollarFormat(grandCustRate)#</td>
								<td valign="bottom" width="64" align="right">#DollarFormat(grandCarrRate)#</td>
								<td valign="bottom" width="57" align="right">#DollarFormat(grandDirectCostTotal)#</td>
								<td valign="bottom" width="51" align="right">#DollarFormat(grandMargin)#</td>
								<cfif structKeyExists(form, "dispatcherSplitAmt")>
									<td width="50" align="right" valign="top">#DollarFormat(grandSplitMargin)#</td></td>
								</cfif>
								<cfif structKeyExists(form, "showCommision")>
									<td width="51" align="right">&nbsp;</td>
									<td width="51" align="right">#DollarFormat(grandAmount)#</td>
								</cfif>
							</tr>
							<tr>
								<td colspan="<cfif structKeyExists(form, "dispatcherSplitAmt")>8<cfelse>7</cfif>">
									<hr style="border-top:1px double black;border-bottom:1px double black;border-left: none;border-right: none;height: 5px;">
								</td>
							</tr>
						</table>
					</td>
				</tr>
			</table>
			<cfdocumentitem type="footer">
				<table width="100%" style="font-family: 'Arial Narrow';border-top: solid 1px;" cellspacing="0" cellpadding="0">
					<tbody>
						<tr>
							<td width="33%" style="font-size: 12px;padding-top: 3px;">#DateTimeFormat(Now(), "mm/dd/yyyy hh:nn tt")# *Load had a LATE stop.</td>
							<td width="34%" align="center" style="font-size: 12px;padding-top: 3px;">
								#form.CompanyName#
							</td>
							<td width="33%" align="right" style="font-size: 12px;padding-top: 3px;">Page #cfdocument.currentpagenumber# of #cfdocument.totalpagecount#</td>
						</tr>
					</tbody>
				</table>
			</cfdocumentitem>
		</cfdocument>	
		<cfset PDFinfo=StructNew()> 
		<cfset PDFinfo.Title="Sales"> 
		<cfset fileName = "Sales Date-#DateFormat(Now(),'mm.dd.yyyy')#.pdf">
		<cfpdf action="setInfo" source="SalesDetailReport" info="#PDFinfo#" overwrite="yes">
		<cfheader name="Content-Disposition" value="inline; filename=#fileName#">
		<cfcontent type="application/pdf" variable="#tobinary(SalesDetailReport)#">
	</cfoutput>
	<cfcatch>
		<cfdocument format="PDF" name="SalesDetailReport">
			<cfoutput>
				Unable To Generate Report.
			</cfoutput>
		</cfdocument>
		<cfset PDFinfo=StructNew()> 
		<cfset PDFinfo.Title="Sales"> 
		<cfset fileName = "Sales Date-#DateFormat(Now(),'mm.dd.yyyy')#.pdf">
		<cfpdf action="setInfo" source="SalesDetailReport" info="#PDFinfo#" overwrite="yes">
		<cfheader name="Content-Disposition" value="inline; filename=#fileName#">
		<cfcontent type="application/pdf" variable="#tobinary(SalesDetailReport)#">
	</cfcatch>
</cftry>