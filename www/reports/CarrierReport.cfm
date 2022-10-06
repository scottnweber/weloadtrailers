<cftry>
	<cfset stopIndex = 0>
	<cfoutput>
		<cfdocument format="PDF" name="CarrierReport" margintop="0.10" marginleft="0.25" marginright="0.25" marginbottom="0.5">
			<cfif qCarrierReport.FreightBroker EQ 0>
				<cfset ReportTitle= 'Dispatch Report'>
			<cfelseif qCarrierReport.FreightBroker EQ 1>
				<cfset DispatchReport= 1>
				<cfloop query="qCarrierReport" group="CarrierID">
					<cfif qCarrierReport.DispatchFee EQ 0>
						<cfset DispatchReport = 0>
						<cfbreak>
					</cfif>
				</cfloop>
				<cfif qCarrierReport.Dispatch EQ 1 AND DispatchReport EQ 1>
					<cfset ReportTitle= 'Dispatch Report'>
				<cfelse>
					<cfset ReportTitle= 'Load Confirmation & Rate Agreement'>
				</cfif>
			<cfelse>
				<cfif qCarrierReport.IsCarrier EQ 1>
					<cfset ReportTitle= 'Load Confirmation & Rate Agreement'>
				<cfelse>
					<cfset ReportTitle= 'Dispatch Report'>
				</cfif>
				<cfif qCarrierReport.Dispatch EQ 1 AND qCarrierReport.DispatchFee NEQ 0>
					<cfset ReportTitle= 'Dispatch Report'>
				</cfif>
			</cfif>
			<cfloop query="qCarrierReport" group="CarrierID">
				<cfset FlatRate = 0>
				<cfset FlatMilesRate = 0>
				<cfset AccessorialsTotal = 0>
				<cfset PaymentsTotal = 0>
				<cfset CarrierTotal = 0>
				<cfset WeightTotal = 0>
				<cfif qCarrierReport.currentrow neq 1>
					<cfdocumentitem type="pagebreak" />
				</cfif>
				<cfif qCarrierReport.currentrow eq 1>
					<cfset FlatRate = qCarrierReport.CarrFlatRate>
					<cfset FlatMilesRate = qCarrierReport.carrierMilesCharges>
				</cfif>

				<cfloop  group="LoadStopCommoditiesID">
					<cfif qCarrierReport.PaymentAdvance EQ 1>
						<cfset PaymentsTotal = PaymentsTotal + qCarrierReport.CarrCharges>
					<cfelse>
						<cfset AccessorialsTotal = AccessorialsTotal + qCarrierReport.CarrCharges>
					</cfif>
					<cfset WeightTotal = WeightTotal + qCarrierReport.Weight>
				</cfloop>

				<cfset CarrierTotal = (FlatRate + FlatMilesRate + AccessorialsTotal) - PaymentsTotal>

				<table width="100%" style="font-family: 'Arial';margin-top: 15px;" cellspacing="0" cellpadding="0">
					<tr>
						<td colspan="2" align="center" style="font-weight: bold;font-size: 22px;">#ReportTitle#</td>
					</tr>
					<tr>
						<td width="50%" align="left" style="padding-bottom: 10px;">
							<cfif len(trim(qCarrierReport.CompanyLogoName))>
								<cfif cgi.https EQ 'on'>
									<cfset imgurl = "https://#cgi.HTTP_HOST#/#trim(listFirst(cgi.SCRIPT_NAME,'/'))#/www/fileupload/img/#qCarrierReport.CompanyCode#/logo/#qCarrierReport.CompanyLogoName#">
								<cfelse>
									<cfset imgurl = "http://#cgi.HTTP_HOST#/#trim(listFirst(cgi.SCRIPT_NAME,'/'))#/www/fileupload/img/#qCarrierReport.CompanyCode#/logo/#qCarrierReport.CompanyLogoName#">
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
						<td width="50%" align="right" valign="bottom" style="padding-bottom: 10px;">
							<table>
								<tr>
									<td align="right" style="font-weight: bold;">Load##:</td>
									<td align="left">#qCarrierReport.LoadNumber#</td>
								</tr>
								<tr>
									<td align="right" style="font-weight: bold;">Date:</td>
									<td align="left">#DateFormat(qCarrierReport.OrderDate,"mm/dd/yyyy")# </td>
								</tr>
								<cfif qCarrierReport.isShowDollar EQ 1 OR NOT len(qCarrierReport.CarrierID)>
									<tr>
										<td align="right" style="font-weight: bold;">Amount:</td>
										<td align="left"><b>#DollarFormat(CarrierTotal)#</b></td>
									</tr>
								</cfif>
							</table>
						</td>
					</tr>
				</table>
				<table width="45%" style="font-family: 'Arial';float: left;" cellspacing="0" cellpadding="0">
					<thead>
						<tr>
							<th width="60%" style="font-size: 13px;background-color: ##E0E0E0;border: solid 1px;">Company:</th>
							<th width="40%" style="font-size: 13px;border-right: solid 1px;border-bottom: solid 1px;border-top: solid 1px;"><cfif len(trim(qCarrierReport.CompanyMC))>MC##: #qCarrierReport.CompanyMC#</cfif></th>
						</tr>
					</thead>
					<tbody>
						<tr>
							<td colspan="2" style="font-size: 13px;border-bottom: solid 1px;">
								#qCarrierReport.CompanyName#<br>
								#qCarrierReport.CompanyAddress#<br>
								#qCarrierReport.CompanyCity#, #qCarrierReport.CompanyState# #qCarrierReport.CompanyZip#
							</td>
						</tr>
					</tbody>
				</table>
				<table width="52%" style="font-family: 'Arial';float: left;margin-left: 15px;" cellspacing="0" cellpadding="0">
					<thead>
						<th width="60%" style="font-size: 13px;background-color: ##E0E0E0;border: solid 1px;">This Load Is Assigned To:</th>
						<th width="40%" style="font-size: 13px;border-right: solid 1px;border-bottom: solid 1px;border-top: solid 1px;">#qCarrierReport.MCNo#</th>
					</thead>
					<tbody>
						<tr>
							<td colspan="2" style="font-size: 13px;border-bottom: solid 1px;">
								#qCarrierReport.CarrierName#<br>
								#qCarrierReport.CarrierAddress#<br>
								#qCarrierReport.CarrierCity#, #qCarrierReport.CarrierStateCode# #qCarrierReport.CarrierZipCode#
							</td>
						</tr>
					</tbody>
				</table>
				<table width="45%" style="font-family: 'Arial';float: left;margin-top: 3px;" cellspacing="0" cellpadding="0">
					<tbody>
						<tr>
							<td width="22%" style="font-size: 12px;font-weight: bold;">Dispatcher:</td>
							<td width="78%" style="font-size: 12px;">#qCarrierReport.DispatcherName#</td>
						</tr>
						<tr>
							<td width="22%" style="font-size: 12px;font-weight: bold;">Phone ##:</td>
							<td width="78%" style="font-size: 12px;">#qCarrierReport.DispatcherPhone# #qCarrierReport.DispatcherPhoneExt#</td>
						</tr>
						<tr>
							<td width="22%" style="font-size: 12px;font-weight: bold;">Fax ##:</td>
							<td width="78%" style="font-size: 12px;">#qCarrierReport.DispatcherFax# #qCarrierReport.DispatcherFaxExt#</td>
						</tr>
						<tr>
							<td width="22%" style="font-size: 12px;font-weight: bold;">E-Mail:</td>
							<td width="78%" style="font-size: 12px;">#qCarrierReport.DispatcherEmail#</td>
						</tr>
						<cfif qCarrierReport.CarrierRateConfirmation EQ 1>
							<tr>
								<td width="22%" style="font-size: 12px;font-weight: bold;">Weight:</td>
								<td width="78%" style="font-size: 12px;"><cfif qCarrierReport.CommodityWeight EQ 1>#WeightTotal#<cfelse>#qCarrierReport.LoadWeight#</cfif></td>
							</tr>
						</cfif>
					</tbody>
				</table>
				<table width="52%" style="font-family: 'Arial';float: left;margin-left: 15px;margin-top: 3px;" cellspacing="0" cellpadding="0">
					<tbody>
						<tr>
							<td width="40%" style="font-size: 12px;padding-bottom: 3px;"><b>Phone: </b>#qCarrierReport.CarrierPhone#</td>
							<td width="60%" style="font-size: 12px;padding-bottom: 3px;"><b>Fax##: </b>#qCarrierReport.CarrierFax#</td>
						</tr>
						<tr>
							<td width="40%" style="font-size: 12px;padding-bottom: 3px;"><b>Driver 1: </b>#qCarrierReport.Driver1#</td>
							<td width="60%" style="font-size: 12px;padding-bottom: 3px;"><b>Cell ##1: </b>#qCarrierReport.Driver1Cell#</td>
						</tr>
						<tr>
							<td width="40%" style="font-size: 12px;padding-bottom: 3px;"><b>Driver 2: </b>#qCarrierReport.Driver2#</td>
							<td width="60%" style="font-size: 12px;padding-bottom: 3px;"><b>Cell ##2: </b>#qCarrierReport.Driver2Cell#</td>
						</tr>
						<tr>
							<td width="40%" style="font-size: 12px;padding-bottom: 3px;"><b>Truck##: </b>#qCarrierReport.TruckNo#</td>
							<td width="60%" style="font-size: 12px;padding-bottom: 3px;"><b>Trailer##: </b>#qCarrierReport.TrailorNo#</td>
						</tr>
						<tr>
							<td width="40%" style="font-size: 12px;padding-bottom: 3px;"><b>Temperature: </b><cfif len(trim(qCarrierReport.Temperature))>
									#qCarrierReport.Temperature#<cfif len(trim(qCarrierReport.Temperaturescale))>&deg; #qCarrierReport.Temperaturescale#</cfif>
								</cfif></td>
							<td width="60%" style="font-size: 12px;padding-bottom: 3px;"><b>Equip: </b>#qCarrierReport.EquipmentName#</td>
						</tr>
						<tr>
							<td width="40%" style="font-size: 12px;padding-bottom: 3px;"><b>Contact: </b>#qCarrierReport.Contact#</td>
							<cfset strText = qCarrierReport.CarrierEmail>
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
							<td width="60%" style="font-size: 12px;padding-bottom: 3px;"><b>E-Mail: </b>#strTextNew#</td>
						</tr>
						<cfif qCarrierReport.CarrierRateConfirmation EQ 1>
							<tr>
								<td width="40%" style="font-size: 12px;padding-bottom: 3px;"><b>Ref No: </b>#qCarrierReport.RefNo#</td>
								<td width="60%" style="font-size: 12px;padding-bottom: 3px;"><b>Miles: </b>#qCarrierReport.Miles#</td>
							</tr>
						</cfif>
					</tbody>
				</table>
				<div style="clear: both"></div>
				<cfif qCarrierReport.CarrierRateConfirmation NEQ 1>
					<table width="45%" style="font-family: 'Arial';float: left;" cellspacing="0" cellpadding="0">
						<thead>
							<tr>
								<th style="font-size: 13px;background-color: ##E0E0E0;border: solid 1px;">Pickup:</th>
							</tr>
						</thead>
						<tbody>
							<tr>
								<td  style="font-size: 13px;border-bottom: solid 1px;">
									<cfif qCarrierReport.Blind EQ 0>#qCarrierReport.StopName#<br>
									#qCarrierReport.StopAddress#<br></cfif>
									#qCarrierReport.StopCity#, #qCarrierReport.StopState# #qCarrierReport.StopZip#
								</td>
							</tr>
						</tbody>
					</table>
					<table width="52%" style="font-family: 'Arial';float: left;margin-left: 15px;" cellspacing="0" cellpadding="0">
						<thead>
							<th width="60%" style="font-size: 13px;background-color: ##E0E0E0;border: solid 1px;">Delivery:</th>
						</thead>
						<tbody>
							<tr>
								<td style="font-size: 13px;border-bottom: solid 1px;">
									<cfif qCarrierReport.Blind[qCarrierReport.recordcount] EQ 0>#qCarrierReport.StopName[qCarrierReport.recordcount]#<br>
									#qCarrierReport.StopAddress[qCarrierReport.recordcount]#<br></cfif>
									#qCarrierReport.StopCity[qCarrierReport.recordcount]#, #qCarrierReport.StopState[qCarrierReport.recordcount]# #qCarrierReport.StopZip[qCarrierReport.recordcount]#
								</td>
							</tr>
						</tbody>
					</table>
					<table width="45%" style="font-family: 'Arial';float: left;margin-top: 3px;" cellspacing="0" cellpadding="0">
						<tbody>
							<cfif qCarrierReport.Blind EQ 0>
								<tr>
									<td width="22%" style="font-size: 12px;font-weight: bold;padding-left: 10px;">Contact:</td>
									<td width="78%" style="font-size: 12px;">#qCarrierReport.ContactPerson#</td>
								</tr>
								<tr>
									<td width="22%" style="font-size: 12px;font-weight: bold;padding-left: 10px;">Phone ##:</td>
									<td width="78%" style="font-size: 12px;">#qCarrierReport.StopPhone#</td>
								</tr>
								<tr>
									<td width="22%" style="font-size: 12px;font-weight: bold;padding-left: 10px;">Fax ##:</td>
									<td width="78%" style="font-size: 12px;">#qCarrierReport.StopFax#</td>
								</tr>
							</cfif>
						</tbody>
					</table>
					<table width="52%" style="font-family: 'Arial';float: left;margin-top: 3px;" cellspacing="0" cellpadding="0">
						<tbody>
							<cfif qCarrierReport.Blind[qCarrierReport.recordcount] EQ 0>
								<tr>
									<td width="22%" style="font-size: 12px;font-weight: bold;padding-left: 25px;">Contact:</td>
									<td width="78%" style="font-size: 12px;">#qCarrierReport.ContactPerson[qCarrierReport.recordcount]#</td>
								</tr>
								<tr>
									<td width="22%" style="font-size: 12px;font-weight: bold;padding-left: 25px;">Phone ##:</td>
									<td width="78%" style="font-size: 12px;">#qCarrierReport.StopPhone[qCarrierReport.recordcount]#</td>
								</tr>
								<tr>
									<td width="22%" style="font-size: 12px;font-weight: bold;padding-left: 25px;">Fax ##:</td>
									<td width="78%" style="font-size: 12px;">#qCarrierReport.StopFax[qCarrierReport.recordcount]#</td>
								</tr>
							</cfif>
						</tbody>
					</table>
					<div style="clear: both"></div>
					<table width="100%" style="font-family: 'Arial';float: left;margin-top: 3px;" cellspacing="0" cellpadding="0">
						<thead>
							<th style="font-size: 13px;background-color: ##E0E0E0;border: solid 1px;">Pickup Date & Time</th>
							<th style="font-size: 13px;background-color: ##E0E0E0;border-top: solid 1px;border-right: solid 1px;border-bottom: solid 1px;">Pickup ##</th>
							<th style="font-size: 13px;background-color: ##E0E0E0;border-top: solid 1px;border-right: solid 1px;border-bottom: solid 1px;">Ref No</th>
							<th style="font-size: 13px;background-color: ##E0E0E0;border-top: solid 1px;border-right: solid 1px;border-bottom: solid 1px;">Delivery Date & Time</th>
							<th style="font-size: 13px;background-color: ##E0E0E0;border-top: solid 1px;border-right: solid 1px;border-bottom: solid 1px;">Delivery ##</th>
							<th style="font-size: 13px;background-color: ##E0E0E0;border-top: solid 1px;border-right: solid 1px;border-bottom: solid 1px;">Weight</th>
						</thead>
						<tbody>
							<tr>
								<td align="center" style="font-size: 13px;border-right: solid 1px;border-bottom: solid 1px;border-left: solid 1px;">#Dateformat(qCarrierReport.StopDate,"mm/dd/yy")# #qCarrierReport.StopTime#</td>
								<td align="center" style="font-size: 13px;border-bottom: solid 1px;">#qCarrierReport.ReleaseNo#</td>
								<td align="center" style="font-size: 13px;border-bottom: solid 1px;">#qCarrierReport.RefNo#</td>

								<td align="center" style="font-size: 13px;border-bottom: solid 1px;">#Dateformat(qCarrierReport.StopDate[qCarrierReport.recordcount],"mm/dd/yy")# #qCarrierReport.StopTime[qCarrierReport.recordcount]#</td>
								<td align="center" style="font-size: 13px;border-bottom: solid 1px;">#qCarrierReport.ReleaseNo[qCarrierReport.recordcount]#</td>
								<td align="center" style="font-size: 13px;border-bottom: solid 1px;"><cfif qCarrierReport.CommodityWeight EQ 1>#WeightTotal#<cfelse>#qCarrierReport.LoadWeight#</cfif></td>
							</tr>
						</tbody>
					</table>
					<div style="clear: both"></div>
				</cfif>
				<table width="100%" style="font-family: 'Arial';" cellspacing="0" cellpadding="0">
					<thead>
						<tr>
							<th width="6%" align="right" style="font-size: 12px;border-top: solid 1px;padding-top: 3px;padding-bottom: 3px;">Stop##</th>
							<th width="6%"  style="font-size: 12px;border-top: solid 1px;padding-top: 3px;padding-bottom: 3px;">Type</th>
							<th width="55%"  align="left" style="font-size: 12px;border-top: solid 1px;padding-top: 3px;padding-bottom: 3px;"><cfif qCarrierReport.Blind EQ 0>Company Name, Address,</cfif> City, State and Zip Code</th>
							<th width="12%"  style="font-size: 12px;border-top: solid 1px;padding-top: 3px;padding-bottom: 3px;">Pickup/Del.##</th>
							<th width="7%"  align="right" style="font-size: 12px;border-top: solid 1px;padding-top: 3px;padding-bottom: 3px;">Date</th>
							<th width="14%"  style="font-size: 12px;border-top: solid 1px;padding-top: 3px;padding-bottom: 3px;">Time</th>
						</tr>
					</thead>
					<tbody>
						<cfloop  group="StopNo">
							<cfset bitShowComm = 1>
							<cfsavecontent variable="Commodities">
								<cfloop  group="LoadStopCommoditiesID">
									<cfif qCarrierReport.CarrCharges NEQ 0 OR qCarrierReport.Weight NEQ 0>
										<cfset vCarrRate = qCarrierReport.CarrRate>
										<cfset vCarrCharges = qCarrierReport.CarrCharges>
										<cfif qCarrierReport.PaymentAdvance EQ 1>
											<cfset vCarrRate = -1*vCarrRate>
											<cfset vCarrCharges = -1*vCarrCharges>
										</cfif>
										<tr>
											<td align="center" style="font-size: 12px;"><i>#qCarrierReport.Qty#</i></td>
											<td style="font-size: 12px;"><i>#qCarrierReport.Description# #qCarrierReport.Dimensions#</i></td>
											<td align="right" style="font-size: 12px;"><i>#qCarrierReport.Weight#</i></td>
											<td align="right" style="font-size: 12px;"><b><i>#Numberformat(vCarrRate,"$__.__")#</i></b></td>
											<td align="right" style="font-size: 12px;"><i><b>#Numberformat(vCarrCharges,"$__.__")#</i></b></td>
										</tr>
									</cfif>
								</cfloop>
							</cfsavecontent>
							<cfloop  group="LoadType">
								<cfif len(trim(qCarrierReport.StopName)) OR len(trim(qCarrierReport.StopAddress)) OR len(trim(qCarrierReport.StopCity)) OR len(trim(qCarrierReport.StopState)) OR len(trim(qCarrierReport.StopZip))>
									<cfset stopIndex++>
									<tr>
										<td valign="top" align="right" style="font-size: 12px;border-top: solid 2px;padding-top: 3px;">#stopIndex#</td>
										<td valign="top" align="center" style="font-size: 12px;border-top: solid 2px;padding-top: 3px;"><cfif qCarrierReport.LoadType EQ 1>PICK<cfelse>DROP</cfif></td>
										<td valign="top" style="font-size: 12px;border-top: solid 2px;padding-top: 3px;">
											<i><cfif qCarrierReport.Blind EQ 0>#qCarrierReport.StopName#, #qCarrierReport.StopAddress#,</cfif> #qCarrierReport.StopCity#, #qCarrierReport.StopState# #qCarrierReport.StopZip#</i><br>
											<b>Phone:</b>#qCarrierReport.StopPhone#
											<cfif len(trim(qCarrierReport.Instructions))>
												<br><b>Instructions:</b>#replaceNoCase(qCarrierReport.Instructions, chr(10), '<br>','ALL')#
											</cfif>
										</td>
										<td valign="top" align="center" style="font-size: 12px;border-top: solid 2px;padding-top: 3px;">#qCarrierReport.ReleaseNo#</td>
										<td valign="top" align="right" style="font-size: 12px;border-top: solid 2px;padding-top: 3px;">#Dateformat(qCarrierReport.StopDate,"mm/dd/yy")#</td>
										<td valign="top" align="right" style="font-size: 12px;border-top: solid 2px;padding-top: 3px;">#qCarrierReport.StopTime#</td>
									</tr>
									<cfif bitShowComm EQ 1 and len(trim(Commodities))>
										<tr>
											<td colspan="6" align="center" style="border-top: solid 1px;">
												<table width="75%" style="font-family: 'Arial';margin-top: 5px;" cellspacing="0" cellpadding="0">
													<thead>
														<tr>
															<th style="font-size: 12px;border-top: solid 1px;border-bottom: solid 1px;"><i>Qty</i></th>
															<th align="left" style="font-size: 12px;border-top: solid 1px;border-bottom: solid 1px;"><i>Description</i></th>
															<th align="right" style="font-size: 12px;border-top: solid 1px;border-bottom: solid 1px;"><i>Weight</i></th>
															<th align="right" style="font-size: 12px;border-top: solid 1px;border-bottom: solid 1px;"><i>Rate</i></th>
															<th align="right" style="font-size: 12px;border-top: solid 1px;border-bottom: solid 1px;"><i>Total</i></th>
														</tr>
													</thead>
													<tbody>
														#Commodities#
													</tbody>
												</table>
											</td>
										</tr>
										<cfset bitShowComm = 0>
									</cfif>
								</cfif>
							</cfloop>
						</cfloop>
						<cfif qCarrierReport.isShowDollar EQ 1 OR NOT len(qCarrierReport.CarrierID)>
							<tr>
								<td align="right" colspan="6" style="font-size: 13px;border-top: solid 2px;border-bottom: solid 2px;padding-top: 3px;padding-bottom: 3px;">
									<b>Flat Rate: </b>#DollarFormat(FlatRate)#<b> + Flat Miles Charge: </b>#DollarFormat(FlatMilesRate)#<b> + Accessorials: </b>#DollarFormat(AccessorialsTotal)#<b> - Payment(s): </b>#DollarFormat(PaymentsTotal)#
								</td>
							</tr>
							<tr>
								<td align="right" colspan="6" style="font-size: 13px;padding-top: 3px;padding-bottom: 10px;">
									<b>TOTAL AMOUNT: #DollarFormat(CarrierTotal)#</b>
								</td>
							</tr> 
						<cfelse>
							<tr>
								<td align="right" colspan="6" style="border-bottom: solid 2px;">&nbsp;</td>
							</tr>
						</cfif>
					</tbody>
				</table>
				<cfif len(trim(qCarrierReport.CriticalNotes))>
					<table width="100%" style="font-family: 'Arial';margin-bottom: 10px;" cellspacing="0" cellpadding="0">
						<tbody>
							<tr>
								<td style="background-image:  url('https://#cgi.HTTP_HOST#/#trim(listFirst(cgi.SCRIPT_NAME,'/'))#/www//webroot/images/redAstericks.png'); background-repeat: repeat-x; background-clip: content-box;"></td>
								<td style="width: 1%;white-space: nowrap;font-size: 16px;font-weight: bold;color: ##ED1D24">#qCarrierReport.CriticalNotes#</td>
								<td style="background-image:  url('https://#cgi.HTTP_HOST#/#trim(listFirst(cgi.SCRIPT_NAME,'/'))#/www//webroot/images/redAstericks.png'); background-repeat: repeat-x;"></td>
							</tr>
						</tbody>
					</table>
				</cfif>
				<cfif len(trim(qCarrierReport.CarrierNotes))>
					<div style="font-family: 'Arial';font-size: 13px;">
						<b>#qCarrierReport.FreightBrokerText# Notes</b><br>
						#replaceNoCase(qCarrierReport.CarrierNotes, chr(10), '<br>','ALL')#
					</div>
				</cfif>
				<cfset eSign = "">
				<cfset dTerms = qCarrierReport.CarrierTerms>
				<cfif not findNoCase("{eSignature}", dTerms)>
					<cfset dTerms &= "<br>{eSignature}">
				</cfif>
				<cfif structKeyExists(url, "signature") and structKeyExists(url, "ipAddress")>
					<cfset eSign = "#url.signature# #dateTimeFormat(now(),'mm/dd/yyyy hh:nn tt')# #url.ipAddress#">
				<cfelseif structKeyExists(form, "signature") and structKeyExists(form, "ipAddress")>
					<cfset eSign = "#form.signature# #dateTimeFormat(now(),'mm/dd/yyyy hh:nn tt')# #form.ipAddress#">
				</cfif>
				<cfif qCarrierReport.isShowDollar EQ 1 OR NOT len(qCarrierReport.CarrierID)>
					<div style="font-family: 'Arial';font-size: 13px;margin-top: 10px;">
						<b>Dispatch Terms & Instructions:</b><br>
						#replaceNoCase(replaceNoCase(dTerms, chr(10), '<br>','ALL'), "{eSignature}", eSign)#
					</div>
				</cfif>
			</cfloop>
			<cfdocumentitem type="footer">
				<table width="100%" style="font-family: 'Arial';border-top: solid 1px;" cellspacing="0" cellpadding="0">
					<tbody>
						<tr>
							<td width="33%" style="font-size: 12px;padding-top: 3px;">#DateFormat(Now(), "mm/dd/yyyy")#<cfif qCarrierReport.CarrierRateConfirmation EQ 1><br>Load## #qCarrierReport.LoadNumber#</cfif></td>
							<td width="34%" align="center" style="font-size: 12px;padding-top: 3px;"><cfif qCarrierReport.CarrierRateConfirmation EQ 1>Dispatcher: #qCarrierReport.DispatcherName#</cfif></td>
							<td width="33%" align="right" style="font-size: 12px;padding-top: 3px;">Page #cfdocument.currentpagenumber# of #cfdocument.totalpagecount#<cfif qCarrierReport.CarrierRateConfirmation EQ 1><br>#qCarrierReport.CompanyName#</cfif></td>
						</tr>
					</tbody>
				</table>
			</cfdocumentitem>
		</cfdocument>
		<cfset PDFinfo=StructNew()> 
		<cfset PDFinfo.Title="#ReportTitle#"> 
		<cfset fileName = "#ReportTitle# ###qCarrierReport.LoadNumber# Date-#DateFormat(Now(),'mm.dd.yyyy')#.pdf">
		<cfpdf action="setInfo" source="CarrierReport" info="#PDFinfo#" overwrite="yes">
		<cfheader name="Content-Disposition" value="inline; filename=#fileName#">
		<cfif qCarrierReport.StatusText EQ '9. Cancelled'>
			<cfpdf action="addwatermark" source="CarrierReport" image="../webroot/images/WM_Cancelled.png"name = "CarrierReport">
		</cfif>
	</cfoutput>
	<cfcatch>
		<cfdump var="#cfcatch#"><cfabort>
		<cfdocument format="PDF" name="CarrierReport">
			<cfoutput>
				Unable To Generate Report.
			</cfoutput>
		</cfdocument>
		<cfset PDFinfo=StructNew()> 
		<cfset PDFinfo.Title="#ReportTitle#"> 
		<cfset fileName = "#ReportTitle# ###qCarrierReport.LoadNumber# Date-#DateFormat(Now(),'mm.dd.yyyy')#.pdf">
		<cfpdf action="setInfo" source="CarrierReport" info="#PDFinfo#" overwrite="yes">
		<cfheader name="Content-Disposition" value="inline; filename=#fileName#">
	</cfcatch>
</cftry>