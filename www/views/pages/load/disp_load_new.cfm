<!---Functuin for triming input string--->
<cftry>
<link href="file:///D|/loadManagerForDrake/webroot/styles/style.css" rel="stylesheet" type="text/css" />
<cfif structkeyexists(session,'iscustomer') AND val(session.iscustomer)>
	<cfset customer = 1>
<cfelse>
	<cfset customer = 0>
</cfif>

<cfparam name="pagesize" default="30">
<cfparam name="TodaysLoadPageNo" default="1">
<cfparam name="TodaysloadSortBy" default="statusText,NewPickupDate">
<cfparam name="TodaysloadSortOrder" default="ASC">
<cfparam name="FutureLoadsPageNo" default="1">
<cfparam name="FutureLoadsSortBy" default="statusText,NewPickupDate">
<cfparam name="FutureLoadsSortOrder" default="ASC">
<cfparam name="DispatchedPageNo" default="1">
<cfparam name="DispatchedSortBy" default="statusText,NewPickupDate">
<cfparam name="DispatchedSortOrder" default="ASC">

<cfif structKeyExists(form, "TodaysLoadPageNo")>
	<cfset TodaysLoadPageNo = form.TodaysLoadPageNo>
</cfif>
<cfif structKeyExists(form, "TodaysLoadSortBy")>
	<cfset TodaysLoadSortBy = form.TodaysLoadSortBy>
</cfif>
<cfif structKeyExists(form, "TodaysLoadSortOrder")>
	<cfset TodaysLoadSortOrder = form.TodaysLoadSortOrder>
</cfif>
<cfif structKeyExists(form, "FutureLoadsPageNo")>
	<cfset FutureLoadsPageNo = form.FutureLoadsPageNo>
</cfif>
<cfif structKeyExists(form, "FutureLoadsSortBy")>
	<cfset FutureLoadsSortBy = form.FutureLoadsSortBy>
</cfif>
<cfif structKeyExists(form, "FutureLoadsSortOrder")>
	<cfset FutureLoadsSortOrder = form.FutureLoadsSortOrder>
</cfif>
<cfif structKeyExists(form, "DispatchedPageNo")>
	<cfset DispatchedPageNo = form.DispatchedPageNo>
</cfif>
<cfif structKeyExists(form, "DispatchedSortBy")>
	<cfset DispatchedSortBy = form.DispatchedSortBy>
</cfif>
<cfif structKeyExists(form, "DispatchedSortOrder")>
	<cfset DispatchedSortOrder = form.DispatchedSortOrder>
</cfif>

<cfinvoke component="#variables.objloadGateway#" method="getLoadSystemSetupOptions" returnvariable="request.qSystemSetupOptions1" />
<!--- Begin Get Load Board Details--->
<cfinvoke component="#variables.objloadGateway#" method="GetLoadBoardDetails" PageNo="#FutureLoadsPageNo#" SortBy="#FutureLoadsSortBy#" SortOrder="#FutureLoadsSortOrder#" StatusArg = 'FutureLoads' IsCustomer="#customer#" returnvariable="qFutureLoads"> 

<cfinvoke component="#variables.objloadGateway#" method="GetLoadBoardDetails" PageNo="#TodaysLoadPageNo#" SortBy="#TodaysLoadSortBy#" SortOrder="#TodaysLoadSortOrder#" StatusArg = 'Todaysload' IsCustomer="#customer#"  returnvariable="qTodaysload">

<cfinvoke component="#variables.objloadGateway#" method="GetLoadBoardDetails" PageNo="#DispatchedPageNo#" SortBy="#DispatchedSortBy#" SortOrder="#DispatchedSortOrder#" StatusArg = 'Dispatched' IsCustomer="#customer#" returnvariable="qDispatched">
<!--- End Get Load Board Details--->

<cfoutput>
	<div class="clear"></div>
	<cfform id="dispLoadForm" name="dispLoadForm" action="" method="post" preserveData="yes">
		<cfinput id="TodaysLoadPageNo" name="TodaysLoadPageNo" value="1" type="hidden">
	    <cfinput id="TodaysLoadSortBy" name="TodaysLoadSortBy" value="l.LoadNumber" type="hidden">
	    <cfinput id="TodaysLoadSortOrder" name="TodaysLoadSortOrder" value="ASC" type="hidden">
	    <cfinput id="FutureLoadsPageNo" name="FutureLoadsPageNo" value="1" type="hidden">
	    <cfinput id="FutureLoadsSortBy" name="FutureLoadsSortBy" value="l.LoadNumber" type="hidden">
	    <cfinput id="FutureLoadsSortOrder" name="FutureLoadsSortOrder" value="ASC" type="hidden">
	    <cfinput id="DispatchedPageNo" name="DispatchedPageNo" value="1" type="hidden">
	    <cfinput id="DispatchedSortBy" name="DispatchedSortBy" value="l.LoadNumber" type="hidden">
	    <cfinput id="DispatchedSortOrder" name="DispatchedSortOrder" value="ASC" type="hidden">

		<cfif request.qSystemSetupOptions1.LoadsColumnsSetting NEQ 1>
			<div style="width: 100% ">
				<H2>Future Loads </H2>
				<table width="100%" border="0" cellspacing="0" cellpadding="0" class="data-table" id="tblLoadList"> 	
		  			<thead>
					  	<tr class="glossy-bg-blue">
							<th colspan="32" class="" align="left" valign="top" style="border:1px solid ##5d8cc9;">
								<span>&nbsp;&nbsp;</span>
								<span class="up-down gen-left">
									<span class="arrow-top">
										<a href="javascript: FutureLoadsTablePrevPage();" style="padding-left:5px !important;"><img src="images/arrow-top.gif" alt="" style="width: 10px;" /></a>
									</span>
									<span class="arrow-bot">
										<a href="javascript: FutureLoadsTableNextPage();">
											<img src="images/arrow-bot.gif" alt=""  style="width: 10px;" />
										</a>
									</span>
								</span>						
								<span class="gen-left">
									<a href="javascript: FutureLoadsTablePrevPage();">&nbsp;&nbsp;Prev </a>-<a href="javascript: FutureLoadsTableNextPage();"> Next</a>
								</span>
								<span class="gen-right"></span>
								<span class="span"></div>
							</th>													
						</tr>
		 				<tr>
		  					<th width="5" align="left" valign="top" class="fillHeader"></th>
							<th width="29" align="center" valign="middle" class="head-bg numbering">&nbsp;</th>
							<th align="center" valign="middle" class="head-bg load" onclick="sortFutureLoadsBy('l.LoadNumber');">LOAD##</th>
							<th align="center" valign="middle" class="head-bg statusWrap" onclick="sortFutureLoadsBy('loadStatus.statusText');">Status</th>
							<th align="center" valign="middle" class="head-bg custWrap" onclick="sortFutureLoadsBy('cust.customerName');">Customer</th>
							<th align="center" valign="middle" class="head-bg poWrap" onclick="sortFutureLoadsBy('l.CUSTOMERPONO');">PO##</th>
							<th align="center" valign="middle" class="head-bg shipdate" onclick="sortFutureLoadsBy('l.NewPickupDate');">Ship&nbsp;Date</th>
							<th align="center" valign="middle" class="head-bg" onclick="sortFutureLoadsBy('FirstShipper.CITY');">Ship&nbsp;City</th>
							<th align="center" valign="middle" class="head-bg stHead" onclick="sortFutureLoadsBy('FirstShipper.StateCode');">ST</th>
							<th align="center" valign="middle" class="head-bg" onclick="sortFutureLoadsBy('finalconsignee.consigneeCity');">Con.&nbsp;City</th>
							<th align="center" valign="middle" class="head-bg stHead" onclick="sortFutureLoadsBy('finalconsignee.consigneeState');">ST</th>
							<th align="center" valign="middle" class="head-bg deliverDate" onclick="sortFutureLoadsBy('l.NewDeliveryDate');">Delivery&nbsp;Date</th>
							<cfset loadsColumnStatus="#request.qSystemSetupOptions1.LoadsColumnsStatus#">

							<cfif listFindNoCase(#request.qSystemSetupOptions1.LoadsColumns#, "Cust Amt") GT 0 AND NOT ListContains(session.rightsList,'HideCustomerPricing',',')>	
								<cfif ListgetAt(loadsColumnStatus,listFindNoCase(request.qSystemSetupOptions1.LoadsColumns, "Cust Amt"))>
								
								<th align="right" valign="middle" class="head-bg custAmt" onclick="sortFutureLoadsBy('l.TOTALCUSTOMERCHARGES');">Cust&nbsp;Amt</th>
								</cfif>
							</cfif>	
							<cfif listFindNoCase(#request.qSystemSetupOptions1.LoadsColumns#, "Carr Amt") GT 0 >	
								<cfif ListgetAt(loadsColumnStatus,listFindNoCase(request.qSystemSetupOptions1.LoadsColumns, "Carr Amt"))>
								<th align="right" valign="middle" class="head-bg custAmt" onclick="sortFutureLoadsBy('l.TotalCarrierCharges');">Carr&nbsp;Amt</th>					
							</cfif>
							</cfif>
							<cfif listFindNoCase(#request.qSystemSetupOptions1.LoadsColumns#, "Miles") GT 0 >	
								<cfif ListgetAt(loadsColumnStatus,listFindNoCase(request.qSystemSetupOptions1.LoadsColumns, "Miles"))>
								<th align="right" valign="middle" class="head-bg custAmt" onclick="sortFutureLoadsBy('l.TotalMiles');">Miles</th>					
							</cfif>
							</cfif>
							<cfif listFindNoCase(#request.qSystemSetupOptions1.LoadsColumns#, "DH Miles") GT 0 >	
								<cfif ListgetAt(loadsColumnStatus,listFindNoCase(request.qSystemSetupOptions1.LoadsColumns, "DH Miles"))>
								<th align="right" valign="middle" class="head-bg custAmt" onclick="sortFutureLoadsBy('l.DeadHeadMiles');" style="min-width: 60px;">DH Miles</th>					
							</cfif>
							</cfif>
							<cfif isdefined('url.event') AND url.event neq 'myLoad' AND  request.qSystemSetupOptions1.ShowCarrierInvoiceNumberInAllLoads EQ 1>
								<th align="right" valign="middle" class="head-bg custAmt" onclick="sortFutureLoadsBy('l.CarrierInvoiceNumber');">CARR_INV</th>
							</cfif>
							<th align="center" valign="middle" class="head-bg" onclick="sortFutureLoadsBy('l.CARRIERNAME');">
								<cfif request.qSystemSetupOptions1.freightBroker and customer NEQ 1>
									Carrier
								<cfelseif NOT val(request.qSystemSetupOptions1.freightBroker)>
									Driver
								</cfif>
							</th>
							<th align="center" valign="middle" class="head-bg dispatch" onclick="sortFutureLoadsBy('Equipments1.EquipmentName');">Equipment </th>
							<th align="center" valign="middle" class="head-bg dispatch" onclick="sortFutureLoadsBy('l.DriverName');">Driver </th>
							<th align="center" valign="middle" class="head-bg dispatch" onclick="sortFutureLoadsBy('Employees.empDispatch');">Dispatcher </th>
							<th align="center" valign="middle" class="head-bg2 agent" <cfif request.qSystemSetupOptions1.freightBroker> onclick="sortFutureLoadsBy('l.SalesAgent');" <cfelse> onclick="sortFutureLoadsBy('l.userDefinedFieldTrucking');"</cfif>><cfif request.qSystemSetupOptions1.freightBroker>Sales Rep<cfelse> #left(request.qSystemSetupOptions1.userDef7,9)#</cfif></th>
							<th width="5" align="right" valign="top" class="fillHeaderRight">
		  				</tr>
		  			</thead>
					<tbody>					
						<cfset variables.counter=0>
						<cfif qFutureLoads.recordcount>
							<cfloop query="qFutureLoads">
								<cfinvoke component="#variables.objloadGateway#" method="getLoadStatus" LoadStatusID="#qFutureLoads.statusTypeID#" returnvariable="request.qFutureLoadstatus" />
								<cfinvoke component="#variables.objloadGateway#" method="getFirstShipperDeatils" LoadID="#qFutureLoads.Loadid#" returnvariable="request.qFirstShipperDeatils" />
								
								<cfif ListContains(session.rightsList,'editLoad',',')>
									<cfset onRowClick = "document.location.href='index.cfm?event=addload&loadid=#qFutureLoads.LOADID#&#session.URLToken#'">
									<cfset onHrefClick = "index.cfm?event=addload&loadid=#qFutureLoads.LOADID#&#session.URLToken#">
								<cfelse>
									<cfset onRowClick = "javascript: alert('You do not have the rights to edit loads');">
									<cfset onHrefClick = "javascript: alert('You do not have the rights to edit loads');">
								</cfif>
								<cfif isdefined("form.FutureLoadsPageNo")>
									<cfset rowNum=(qFutureLoads.currentRow) + ((form.FutureLoadsPageNo-1)*pageSize)>
								<cfelse>
									<cfset rowNum=(qFutureLoads.currentRow)>
								</cfif>
								<tr style="background:###request.qFutureLoadstatus.ColorCode#; cursor:pointer;" onmouseover="this.style.background = '##FFFFFF';" onmouseout="this.style.background = '###request.qFutureLoadstatus.ColorCode#';" <cfif qFutureLoads.Row mod 2 eq 0>bgcolor="##FFFFFF"<cfelse>bgcolor="##f7f7f7"</cfif>>
									<td height="20" class="sky-bg">&nbsp;</td>
									<td align="center" valign="middle" nowrap="nowrap" class="sky-bg2" onclick="#onRowClick#">#rowNum#</td>
									<input type="hidden" name="StatusText#qFutureLoads.loadNumber#" id="StatusText#qFutureLoads.loadNumber#" value="#qFutureLoads.STATUSTEXT#">
									<td align="left" valign="middle" nowrap="nowrap" class="normal-td" onclick="#onRowClick#"><a href="#onHrefClick#" style="color:###qFutureLoads.TextColorCode#">#qFutureLoads.loadNumber#</a></td>
									<td  align="left" valign="middle" nowrap="nowrap" class="normal-td" onclick="#onRowClick#"><a href="#onHrefClick#" style="color:###qFutureLoads.TextColorCode#">#qFutureLoads.StatusDescription#</a></td>
									<td  align="left" valign="middle" nowrap="nowrap" class="normal-td" onclick="#onRowClick#"><a href="#onHrefClick#" style="color:###qFutureLoads.TextColorCode#">#qFutureLoads.customerName#</a></td>
									<td  align="left" valign="middle" nowrap="nowrap" class="normal-td" onclick="#onRowClick#"><a href="#onHrefClick#" style="color:###qFutureLoads.TextColorCode#">#qFutureLoads.CUSTOMERPONO#</a></td>
									<td align="left" valign="middle" nowrap="nowrap" class="normal-td" onclick="#onRowClick#"><a href="#onHrefClick#" style="color:###qFutureLoads.TextColorCode#">#dateformat(qFutureLoads.PICKUPDATE,'mm/dd/yyyy')#</a></td>
									<td align="left" valign="middle" nowrap="nowrap" class="normal-td" onclick="#onRowClick#"><a href="#onHrefClick#" style="color:###qFutureLoads.TextColorCode#">#qFutureLoads.shippercity#</a></td>
									<td align="left" valign="middle" nowrap="nowrap" class="normal-td" onclick="#onRowClick#"><a href="#onHrefClick#" style="color:###qFutureLoads.TextColorCode#"><cfif qFutureLoads.shipperstate NEQ 0>#qFutureLoads.shipperstate#</cfif></a></td>
									<td align="left" valign="middle" nowrap="nowrap" class="normal-td" onclick="#onRowClick#"><a href="#onHrefClick#" style="color:###qFutureLoads.TextColorCode#">#qFutureLoads.consigneeCity# </a></td>
									<td align="left" valign="middle" nowrap="nowrap" class="normal-td" onclick="#onRowClick#"><a href="#onHrefClick#" style="color:###qFutureLoads.TextColorCode#"><cfif qFutureLoads.consigneeState NEQ 0>#qFutureLoads.consigneeState#</cfif></a></td>
									<td align="left" valign="middle" nowrap="nowrap" class="normal-td" onclick="#onRowClick#"><a href="#onHrefClick#" style="color:###qFutureLoads.TextColorCode#">#dateformat(qFutureLoads.DeliveryDATE,'mm/dd/yyyy')#</a></td>

									<cfif request.qSystemSetupOptions1.ForeignCurrencyEnabled>
										<cfif listFindNoCase(#request.qSystemSetupOptions1.LoadsColumns#, "Cust Amt") GT 0 AND NOT ListContains(session.rightsList,'HideCustomerPricing',',')>	
											<cfif ListgetAt(loadsColumnStatus,listFindNoCase(request.qSystemSetupOptions1.LoadsColumns, "Cust Amt"))>
												<td align="right" valign="middle" nowrap="nowrap" class="normal-td custAmt" onclick="#onRowClick#"><a href="#onHrefClick#" style="color:###qFutureLoads.TextColorCode#">#NumberFormat(qFutureLoads.TOTALCUSTOMERCHARGES)# #qFutureLoads.CUSTOMERCURRENCYISO#</a></td>
											</cfif>
										</cfif>

										<cfif listFindNoCase(#request.qSystemSetupOptions1.LoadsColumns#, "Carr Amt") GT 0 >	
											<cfif ListgetAt(loadsColumnStatus,listFindNoCase(request.qSystemSetupOptions1.LoadsColumns, "Carr Amt"))>
												<td align="right" valign="middle" nowrap="nowrap" class="normal-td carrAmt" onclick="#onRowClick#"><a href="#onHrefClick#" style="color:###qFutureLoads.TextColorCode#">#NumberFormat(qFutureLoads.TOTALCARRIERCHARGES)# #qFutureLoads.CARRIERCURRENCYISO#</a></td>
											</cfif>
										</cfif>
									<cfelse>
										<cfif listFindNoCase(#request.qSystemSetupOptions1.LoadsColumns#, "Cust Amt") GT 0 >	
										<cfif ListgetAt(loadsColumnStatus,listFindNoCase(request.qSystemSetupOptions1.LoadsColumns, "Cust Amt"))>
											<td align="right" valign="middle" nowrap="nowrap" class="normal-td custAmt" onclick="#onRowClick#"><a href="#onHrefClick#" style="color:###qFutureLoads.TextColorCode#">#NumberFormat(qFutureLoads.TOTALCUSTOMERCHARGES,'$')#</a></td>
										</cfif>
									</cfif>
										<cfif listFindNoCase(#request.qSystemSetupOptions1.LoadsColumns#, "Carr Amt") GT 0 >	
										<cfif ListgetAt(loadsColumnStatus,listFindNoCase(request.qSystemSetupOptions1.LoadsColumns, "Carr Amt"))>
											<td align="right" valign="middle" nowrap="nowrap" class="normal-td carrAmt" onclick="#onRowClick#"><a href="#onHrefClick#" style="color:###qFutureLoads.TextColorCode#">#NumberFormat(qFutureLoads.TOTALCARRIERCHARGES,'$')#</a></td>
										</cfif>
										</cfif>
									</cfif>

									<cfif listFindNoCase(#request.qSystemSetupOptions1.LoadsColumns#, "Miles") GT 0 >	
									<cfif ListgetAt(loadsColumnStatus,listFindNoCase(request.qSystemSetupOptions1.LoadsColumns, "Miles"))>
										<td align="right" valign="middle" nowrap="nowrap" class="normal-td carrAmt" onclick="#onRowClick#" style="padding-right: 3px;"><a href="#onHrefClick#" style="color:###qFutureLoads.TextColorCode#">#qFutureLoads.carrierTotalMiles#</a></td>
									</cfif>
									</cfif>

									<cfif listFindNoCase(#request.qSystemSetupOptions1.LoadsColumns#, "DH Miles") GT 0 >	
									<cfif ListgetAt(loadsColumnStatus,listFindNoCase(request.qSystemSetupOptions1.LoadsColumns, "DH Miles"))>
										<td align="right" valign="middle" nowrap="nowrap" class="normal-td carrAmt" onclick="#onRowClick#" style="padding-right: 3px;"><a href="#onHrefClick#" style="color:###qFutureLoads.TextColorCode#">#qFutureLoads.DeadHeadMiles#</a></td>
									</cfif>
									</cfif>
									<cfif isdefined('url.event') AND url.event neq 'myLoad'  AND  request.qSystemSetupOptions1.ShowCarrierInvoiceNumberInAllLoads EQ 1>
											<td align="right" valign="middle" nowrap="nowrap" class="normal-td carrAmt" onclick="#onRowClick#"><a href="#onHrefClick#" style="color:###qFutureLoads.TextColorCode#">
											<cfif qFutureLoads.CarrierInvoiceNumber NEQ 0>#qFutureLoads.CarrierInvoiceNumber#</cfif>
											</a></td>
										</cfif>

									<cfif customer neq 1>
										<td  align="left" valign="middle" nowrap="nowrap" class="normal-td" onclick="#onRowClick#">
											<a href="#onHrefClick#" style="color:###qFutureLoads.TextColorCode#">#qFutureLoads.CARRIERNAME#</a>
										</td>
									</cfif>
									<td  align="left" valign="middle" nowrap="nowrap" class="normal-td" onclick="#onRowClick#"><a href="#onHrefClick#" style="color:###qFutureLoads.TextColorCode#">#qFutureLoads.EquipmentName#</a></td>
									<td  align="left" valign="middle" nowrap="nowrap" class="normal-td" onclick="#onRowClick#"><a href="#onHrefClick#" style="color:###qFutureLoads.TextColorCode#">#qFutureLoads.DriverName#</a></td>
									<td  align="left" valign="middle" nowrap="nowrap" class="normal-td" onclick="#onRowClick#"><a href="#onHrefClick#" style="color:###qFutureLoads.TextColorCode#">#qFutureLoads.empDispatch#</a></td>
									<td  align="left" valign="middle" nowrap="nowrap" class="normal-td2" onclick="#onRowClick#"><a href="#onHrefClick#" style="color:###qFutureLoads.TextColorCode#"><cfif request.qSystemSetupOptions1.freightBroker>#qFutureLoads.empAgent# <cfelse> #qFutureLoads.userDefinedFieldTrucking#</cfif></a></td>
									<td class="normal-td3">&nbsp;</td>
								</tr>
								<cfset variables.counter++>
							</cfloop>
						<cfelse>
							<tr>
								<td colspan='18' align="center">
									No Records Found.
								</td>
							</tr>
						</cfif>
					</tbody>
					<tfoot>
						<tr>
							<td width="5" align="left" valign="top"><img src="images/left-bot.gif" alt="" width="5" height="23" /></td>
							<td colspan='18' align="left" valign="middle" class="footer-bg">
								<div class="up-down">
									<div class="arrow-top"><a href="javascript: FutureLoadsTablePrevPage();"><img src="images/arrow-top.gif" alt="" /></a></div>
									<div class="arrow-bot"><a href="javascript: FutureLoadsTableNextPage();"><img src="images/arrow-bot.gif" alt="" /></a></div>
								</div>
								<div class="gen-left"><a href="javascript: FutureLoadsTablePrevPage();">Prev </a>-<a href="javascript: FutureLoadsTableNextPage();"> Next</a></div>
								<div class="gen-right"><img src="images/loader.gif" alt="" /></div>
								<div class="clear"></div>
							</td>
							<td class="footer-bg"></td>
							<td class="footer-bg"></td>
							<td width="6" align="right" valign="top"><img src="images/right-bot.gif" alt="" width="5" height="23" /></td>
						</tr>
					</tfoot>
				</table>
			</div>
			<div class="clear"></div>
			<div class="clear"></div>
			<div style="width: 100% ">
				<H2>Today's Loads </H2>
				<table width="100%" border="0" cellspacing="0" cellpadding="0" class="data-table" id="tblLoadList"> 	
		  			<thead>
					  	<tr class="glossy-bg-blue">
							<th colspan="32" class="" align="left" valign="top" style="border:1px solid ##5d8cc9;">
								<span>&nbsp;&nbsp;</span>
								<span class="up-down gen-left">
									<span class="arrow-top">
										<a href="javascript: TodaysLoadTablePrevPage();" style="padding-left:5px !important;"><img src="images/arrow-top.gif" alt="" style="width: 10px;" /></a>
									</span>
									<span class="arrow-bot">
										<a href="javascript: TodaysLoadTableNextPage();">
											<img src="images/arrow-bot.gif" alt=""  style="width: 10px;" />
										</a>
									</span>
								</span>						
								<span class="gen-left">
									<a href="javascript: TodaysLoadTablePrevPage();">&nbsp;&nbsp;Prev </a>-<a href="javascript: TodaysLoadTableNextPage();"> Next</a>
								</span>
								<span class="gen-right"></span>
								<span class="span"></div>
							</th>													
						</tr>
		 				<tr>
		  					<th width="5" align="left" valign="top" class="fillHeader"></th>
							<th width="29" align="center" valign="middle" class="head-bg numbering">&nbsp;</th>
							<th align="center" valign="middle" class="head-bg load" onclick="sortTodaysLoadBy('l.LoadNumber');">LOAD##</th>
							<th align="center" valign="middle" class="head-bg statusWrap" onclick="sortTodaysLoadBy('loadStatus.statusText');">Status</th>
							<th align="center" valign="middle" class="head-bg statusWrap">Load##&nbsp;-&nbsp;Stop##</th>
							<th align="center" valign="middle" class="head-bg custWrap" onclick="sortTodaysLoadBy('cust.customerName');">Customer</th>
							<th align="center" valign="middle" class="head-bg poWrap" onclick="sortTodaysLoadBy('l.CUSTOMERPONO');">PO##</th>
							<th align="center" valign="middle" class="head-bg shipdate" onclick="sortTodaysLoadBy('l.NewPickupDate');">Ship&nbsp;Date</th>
							<th align="center" valign="middle" class="head-bg" onclick="sortTodaysLoadBy('FirstShipper.CITY');">Ship&nbsp;City</th>
							<th align="center" valign="middle" class="head-bg stHead" onclick="sortTodaysLoadBy('FirstShipper.StateCode');">ST</th>
							<th align="center" valign="middle" class="head-bg" onclick="sortTodaysLoadBy('finalconsignee.consigneeCity');">Con.&nbsp;City</th>
							<th align="center" valign="middle" class="head-bg stHead" onclick="sortTodaysLoadBy('finalconsignee.consigneeState');">ST</th>
							<th align="center" valign="middle" class="head-bg deliverDate" onclick="sortTodaysLoadBy('l.NewDeliveryDate');">Delivery&nbsp;Date</th>
							<cfif listFindNoCase(#request.qSystemSetupOptions1.LoadsColumns#, "Cust Amt") GT 0 AND NOT ListContains(session.rightsList,'HideCustomerPricing',',')>	
								<cfif ListgetAt(loadsColumnStatus,listFindNoCase(request.qSystemSetupOptions1.LoadsColumns, "Cust Amt"))>
								<th align="right" valign="middle" class="head-bg custAmt" onclick="sortTodaysLoadBy('l.TOTALCUSTOMERCHARGES');">Cust&nbsp;Amt</th>
							</cfif>	
							</cfif>
							<cfif listFindNoCase(#request.qSystemSetupOptions1.LoadsColumns#, "Carr Amt") GT 0 >	
								<cfif ListgetAt(loadsColumnStatus,listFindNoCase(request.qSystemSetupOptions1.LoadsColumns, "Carr Amt"))>
								<th align="right" valign="middle" class="head-bg custAmt" onclick="sortTodaysLoadBy('l.TotalCarrierCharges');">Carr&nbsp;Amt</th>					
							</cfif>
							</cfif>
							<cfif listFindNoCase(#request.qSystemSetupOptions1.LoadsColumns#, "Miles") GT 0 >	
								<cfif ListgetAt(loadsColumnStatus,listFindNoCase(request.qSystemSetupOptions1.LoadsColumns, "Miles"))>
								<th align="right" valign="middle" class="head-bg custAmt" onclick="sortTodaysLoadBy('l.TotalMiles');">Miles</th>					
							</cfif>
							</cfif>
							<cfif listFindNoCase(#request.qSystemSetupOptions1.LoadsColumns#, "DH Miles") GT 0 >	
								<cfif ListgetAt(loadsColumnStatus,listFindNoCase(request.qSystemSetupOptions1.LoadsColumns, "DH Miles"))>
								<th align="right" valign="middle" class="head-bg custAmt" onclick="sortTodaysLoadBy('l.DeadHeadMiles');" style="min-width: 60px;">DH Miles</th>					
							</cfif>
							</cfif>
							<cfif isdefined('url.event') AND url.event neq 'myLoad' AND  request.qSystemSetupOptions1.ShowCarrierInvoiceNumberInAllLoads EQ 1>
								<th align="right" valign="middle" class="head-bg custAmt" onclick="sortTodaysLoadBy('l.CarrierInvoiceNumber');">CARR_INV</th>
							</cfif>
							<th align="center" valign="middle" class="head-bg" onclick="sortTodaysLoadBy('l.CARRIERNAME');">
								<cfif request.qSystemSetupOptions1.freightBroker and customer NEQ 1>
									Carrier
								<cfelseif NOT val(request.qSystemSetupOptions1.freightBroker)>
									Driver
								</cfif>
							</th>
							<th align="center" valign="middle" class="head-bg dispatch" onclick="sortTodaysLoadBy('Equipments1.EquipmentName');">Equipment </th>
							<th align="center" valign="middle" class="head-bg dispatch" onclick="sortTodaysLoadBy('l.DriverName');">Driver </th>
							<th align="center" valign="middle" class="head-bg dispatch" onclick="sortTodaysLoadBy('Employees.empDispatch');">Dispatcher </th>
							<th align="center" valign="middle" class="head-bg2 agent" <cfif request.qSystemSetupOptions1.freightBroker> onclick="sortTodaysLoadBy('l.SalesAgent');" <cfelse> onclick="sortTodaysLoadBy('l.userDefinedFieldTrucking');"</cfif>><cfif request.qSystemSetupOptions1.freightBroker>Sales Rep<cfelse> #left(request.qSystemSetupOptions1.userDef7,9)#</cfif></th>
							<th width="5" align="right" valign="top" class="fillHeaderRight">
		  				</tr>
		  			</thead>
					<tbody>					
						<cfset variables.counter=0>
						<cfif qTodaysLoad.recordcount>
							<cfloop query="qTodaysLoad">
								<cfinvoke component="#variables.objloadGateway#" method="getLoadStatus" LoadStatusID="#qTodaysLoad.statusTypeID#" returnvariable="request.qTodaysLoadtatus" />
								<cfinvoke component="#variables.objloadGateway#" method="getFirstShipperDeatils" LoadID="#qTodaysLoad.Loadid#" returnvariable="request.qFirstShipperDeatils" />
								
								<cfif ListContains(session.rightsList,'editLoad',',')>
									<cfset onRowClick = "document.location.href='index.cfm?event=addload&loadid=#qTodaysLoad.LOADID#&#session.URLToken#'">
									<cfset onHrefClick = "index.cfm?event=addload&loadid=#qTodaysLoad.LOADID#&#session.URLToken#">
								<cfelse>
									<cfset onRowClick = "javascript: alert('You do not have the rights to edit loads');">
									<cfset onHrefClick = "javascript: alert('You do not have the rights to edit loads');">
								</cfif>
								<cfif isdefined("form.TodaysLoadPageNo")>
									<cfset rowNum=(qTodaysLoad.currentRow) + ((form.TodaysLoadPageNo-1)*pageSize)>
								<cfelse>
									<cfset rowNum=(qTodaysLoad.currentRow)>
								</cfif>
								<tr style="background:###request.qTodaysLoadtatus.ColorCode#; cursor:pointer;" onmouseover="this.style.background = '##FFFFFF';" onmouseout="this.style.background = '###request.qTodaysLoadtatus.ColorCode#';" <cfif qTodaysLoad.Row mod 2 eq 0>bgcolor="##FFFFFF"<cfelse>bgcolor="##f7f7f7"</cfif>>
									<td height="20" class="sky-bg">&nbsp;</td>
									<td align="center" valign="middle" nowrap="nowrap" class="sky-bg2" onclick="#onRowClick#">#rowNum#</td>
									<input type="hidden" name="StatusText#qTodaysLoad.loadNumber#" id="StatusText#qTodaysLoad.loadNumber#" value="#qTodaysLoad.STATUSTEXT#">
									<td align="left" valign="middle" nowrap="nowrap" class="normal-td" onclick="#onRowClick#"><a href="#onHrefClick#" style="color:###qTodaysLoad.TextColorCode#">#qTodaysLoad.loadNumber#</a></td>
									<td  align="left" valign="middle" nowrap="nowrap" class="normal-td" onclick="#onRowClick#"><a href="#onHrefClick#" style="color:###qTodaysLoad.TextColorCode#">#qTodaysLoad.StatusDescription#</a></td>
									<td  align="left" valign="middle" nowrap="nowrap" class="normal-td" onclick="#onRowClick#"><a href="#onHrefClick#" style="color:###qTodaysLoad.TextColorCode#"><cfif len(trim(qTodaysLoad.ReleaseNo))>#qTodaysLoad.ReleaseNo# - </cfif>#replaceNoCase(replaceNoCase(qTodaysLoad.LoadStatusStopNo, 'S', 'P'), 'C', 'D')#</a></td>
									<td  align="left" valign="middle" nowrap="nowrap" class="normal-td" onclick="#onRowClick#"><a href="#onHrefClick#" style="color:###qTodaysLoad.TextColorCode#">#qTodaysLoad.customerName#</a></td>
									<td  align="left" valign="middle" nowrap="nowrap" class="normal-td" onclick="#onRowClick#"><a href="#onHrefClick#" style="color:###qTodaysLoad.TextColorCode#">#qTodaysLoad.CUSTOMERPONO#</a></td>
									<td align="left" valign="middle" nowrap="nowrap" class="normal-td" onclick="#onRowClick#"><a href="#onHrefClick#" style="color:###qTodaysLoad.TextColorCode#">#dateformat(qTodaysLoad.PICKUPDATE,'mm/dd/yyyy')#</a></td>
									<td align="left" valign="middle" nowrap="nowrap" class="normal-td" onclick="#onRowClick#"><a href="#onHrefClick#" style="color:###qTodaysLoad.TextColorCode#">#qTodaysLoad.shippercity#</a></td>
									<td align="left" valign="middle" nowrap="nowrap" class="normal-td" onclick="#onRowClick#"><a href="#onHrefClick#" style="color:###qTodaysLoad.TextColorCode#"><cfif qTodaysLoad.shipperstate NEQ 0>#qTodaysLoad.shipperstate#</cfif></a></td>
									<td align="left" valign="middle" nowrap="nowrap" class="normal-td" onclick="#onRowClick#"><a href="#onHrefClick#" style="color:###qTodaysLoad.TextColorCode#">#qTodaysLoad.consigneeCity# </a></td>
									<td align="left" valign="middle" nowrap="nowrap" class="normal-td" onclick="#onRowClick#"><a href="#onHrefClick#" style="color:###qTodaysLoad.TextColorCode#"><cfif qTodaysLoad.consigneeState NEQ 0>#qTodaysLoad.consigneeState#</cfif></a></td>
									<td align="left" valign="middle" nowrap="nowrap" class="normal-td" onclick="#onRowClick#"><a href="#onHrefClick#" style="color:###qTodaysLoad.TextColorCode#">#dateformat(qTodaysLoad.DeliveryDATE,'mm/dd/yyyy')#</a></td>

									<cfif request.qSystemSetupOptions1.ForeignCurrencyEnabled>
										<cfif listFindNoCase(#request.qSystemSetupOptions1.LoadsColumns#, "Cust Amt") GT 0 >	
											<cfif ListgetAt(loadsColumnStatus,listFindNoCase(request.qSystemSetupOptions1.LoadsColumns, "Cust Amt")) AND NOT ListContains(session.rightsList,'HideCustomerPricing',',')>
												<td align="right" valign="middle" nowrap="nowrap" class="normal-td custAmt" onclick="#onRowClick#"><a href="#onHrefClick#" style="color:###qTodaysLoad.TextColorCode#">#NumberFormat(qTodaysLoad.TOTALCUSTOMERCHARGES)# #qTodaysLoad.CUSTOMERCURRENCYISO#</a></td>
											</cfif>
										</cfif>

										<cfif listFindNoCase(#request.qSystemSetupOptions1.LoadsColumns#, "Carr Amt") GT 0 >	
										<cfif ListgetAt(loadsColumnStatus,listFindNoCase(request.qSystemSetupOptions1.LoadsColumns, "Carr Amt"))>
											<td align="right" valign="middle" nowrap="nowrap" class="normal-td carrAmt" onclick="#onRowClick#"><a href="#onHrefClick#" style="color:###qTodaysLoad.TextColorCode#">#NumberFormat(qTodaysLoad.TOTALCARRIERCHARGES)# #qTodaysLoad.CARRIERCURRENCYISO#</a></td>
										</cfif>
									</cfif>
									<cfelse>
										<cfif listFindNoCase(#request.qSystemSetupOptions1.LoadsColumns#, "Cust Amt") GT 0 AND NOT ListContains(session.rightsList,'HideCustomerPricing',',')>	
										<cfif ListgetAt(loadsColumnStatus,listFindNoCase(request.qSystemSetupOptions1.LoadsColumns, "Cust Amt"))>
											<td align="right" valign="middle" nowrap="nowrap" class="normal-td custAmt" onclick="#onRowClick#"><a href="#onHrefClick#" style="color:###qTodaysLoad.TextColorCode#">#NumberFormat(qTodaysLoad.TOTALCUSTOMERCHARGES,'$')#</a></td>
										</cfif>
										</cfif>

										<cfif listFindNoCase(#request.qSystemSetupOptions1.LoadsColumns#, "Carr Amt") GT 0 >	
										<cfif ListgetAt(loadsColumnStatus,listFindNoCase(request.qSystemSetupOptions1.LoadsColumns, "Carr Amt"))>
											<td align="right" valign="middle" nowrap="nowrap" class="normal-td carrAmt" onclick="#onRowClick#"><a href="#onHrefClick#" style="color:###qTodaysLoad.TextColorCode#">#NumberFormat(qTodaysLoad.TOTALCARRIERCHARGES,'$')#</a></td>
										</cfif>
										</cfif>
									</cfif>

									<cfif listFindNoCase(#request.qSystemSetupOptions1.LoadsColumns#, "Miles") GT 0 >	
									<cfif ListgetAt(loadsColumnStatus,listFindNoCase(request.qSystemSetupOptions1.LoadsColumns, "Miles"))>
										<td align="right" valign="middle" nowrap="nowrap" class="normal-td carrAmt" onclick="#onRowClick#" style="padding-right: 3px;"><a href="#onHrefClick#" style="color:###qTodaysLoad.TextColorCode#">#qTodaysLoad.carrierTotalMiles#</a></td>
									</cfif>
									</cfif>

									<cfif listFindNoCase(#request.qSystemSetupOptions1.LoadsColumns#, "DH Miles") GT 0 >	
									<cfif ListgetAt(loadsColumnStatus,listFindNoCase(request.qSystemSetupOptions1.LoadsColumns, "DH Miles"))>
										<td align="right" valign="middle" nowrap="nowrap" class="normal-td carrAmt" onclick="#onRowClick#" style="padding-right: 3px;"><a href="#onHrefClick#" style="color:###qTodaysLoad.TextColorCode#">#qTodaysLoad.DeadHeadMiles#</a></td>
									</cfif>
									</cfif>
									<cfif isdefined('url.event') AND url.event neq 'myLoad'  AND  request.qSystemSetupOptions1.ShowCarrierInvoiceNumberInAllLoads EQ 1>
											<td align="right" valign="middle" nowrap="nowrap" class="normal-td carrAmt" onclick="#onRowClick#"><a href="#onHrefClick#" style="color:###qTodaysLoad.TextColorCode#">
											<cfif qTodaysLoad.CarrierInvoiceNumber NEQ 0>#qTodaysLoad.CarrierInvoiceNumber#</cfif>
											</a></td>
										</cfif>

									<cfif customer neq 1>
										<td  align="left" valign="middle" nowrap="nowrap" class="normal-td" onclick="#onRowClick#">
											<a href="#onHrefClick#" style="color:###qTodaysLoad.TextColorCode#">#qTodaysLoad.CARRIERNAME#</a>
										</td>
									</cfif>
									<td  align="left" valign="middle" nowrap="nowrap" class="normal-td" onclick="#onRowClick#"><a href="#onHrefClick#" style="color:###qTodaysLoad.TextColorCode#">#qTodaysLoad.EquipmentName#</a></td>
									<td  align="left" valign="middle" nowrap="nowrap" class="normal-td" onclick="#onRowClick#"><a href="#onHrefClick#" style="color:###qTodaysLoad.TextColorCode#">#qTodaysLoad.DriverName#</a></td>
									<td  align="left" valign="middle" nowrap="nowrap" class="normal-td" onclick="#onRowClick#"><a href="#onHrefClick#" style="color:###qTodaysLoad.TextColorCode#">#qTodaysLoad.empDispatch#</a></td>
									<td  align="left" valign="middle" nowrap="nowrap" class="normal-td2" onclick="#onRowClick#"><a href="#onHrefClick#" style="color:###qTodaysLoad.TextColorCode#"><cfif request.qSystemSetupOptions1.freightBroker>#qTodaysLoad.empAgent# <cfelse> #qTodaysLoad.userDefinedFieldTrucking#</cfif></a></td>
									<td class="normal-td3">&nbsp;</td>
								</tr>
								<cfset variables.counter++>
							</cfloop>
						<cfelse>
							<tr>
								<td colspan='19' align="center">
									No Records Found.
								</td>
							</tr>
						</cfif>
					</tbody>
					<tfoot>
						<tr>
							<td width="5" align="left" valign="top"><img src="images/left-bot.gif" alt="" width="5" height="23" /></td>
							<td colspan='19' align="left" valign="middle" class="footer-bg">
								<div class="up-down">
									<div class="arrow-top"><a href="javascript: TodaysLoadTablePrevPage();"><img src="images/arrow-top.gif" alt="" /></a></div>
									<div class="arrow-bot"><a href="javascript: TodaysLoadTableNextPage();"><img src="images/arrow-bot.gif" alt="" /></a></div>
								</div>
								<div class="gen-left"><a href="javascript: TodaysLoadTablePrevPage();">Prev </a>-<a href="javascript: TodaysLoadTableNextPage();"> Next</a></div>
								<div class="gen-right"><img src="images/loader.gif" alt="" /></div>
								<div class="clear"></div>
							</td>
							<td class="footer-bg"></td>
							<td class="footer-bg"></td>
							<td width="6" align="right" valign="top"><img src="images/right-bot.gif" alt="" width="5" height="23" /></td>
						</tr>
					</tfoot>
				</table>
			</div>	
			<div class="clear"></div>
			<div class="clear"></div>
			<div style="width: 100% ">
				<H2>Dispatched Loads </H2>
				<table width="100%" border="0" cellspacing="0" cellpadding="0" class="data-table" id="tblLoadList"> 	
		  			<thead>
					  	<tr class="glossy-bg-blue">
							<th colspan="32" class="" align="left" valign="top" style="border:1px solid ##5d8cc9;">
								<span>&nbsp;&nbsp;</span>
								<span class="up-down gen-left">
									<span class="arrow-top">
										<a href="javascript: DispatchedTablePrevPage();" style="padding-left:5px !important;"><img src="images/arrow-top.gif" alt="" style="width: 10px;" /></a>
									</span>
									<span class="arrow-bot">
										<a href="javascript: DispatchedTableNextPage();">
											<img src="images/arrow-bot.gif" alt=""  style="width: 10px;" />
										</a>
									</span>
								</span>						
								<span class="gen-left">
									<a href="javascript: DispatchedTablePrevPage();">&nbsp;&nbsp;Prev </a>-<a href="javascript: DispatchedTableNextPage();"> Next</a>
								</span>
								<span class="gen-right"></span>
								<span class="span"></div>
							</th>													
						</tr>
		 				<tr>
		  					<th width="5" align="left" valign="top" class="fillHeader"></th>
							<th width="29" align="center" valign="middle" class="head-bg numbering">&nbsp;</th>
							<th align="center" valign="middle" class="head-bg load" onclick="sortDispatchedBy('l.LoadNumber');">LOAD##</th>
							<th align="center" valign="middle" class="head-bg statusWrap" onclick="sortDispatchedBy('loadStatus.statusText');">Status</th>
							<th align="center" valign="middle" class="head-bg custWrap" onclick="sortDispatchedBy('cust.customerName');">Customer</th>
							<th align="center" valign="middle" class="head-bg poWrap" onclick="sortDispatchedBy('l.CUSTOMERPONO');">PO##</th>
							<th align="center" valign="middle" class="head-bg shipdate" onclick="sortDispatchedBy('l.NewPickupDate');">Ship&nbsp;Date</th>
							<th align="center" valign="middle" class="head-bg" onclick="sortDispatchedBy('FirstShipper.CITY');">Ship&nbsp;City</th>
							<th align="center" valign="middle" class="head-bg stHead" onclick="sortDispatchedBy('FirstShipper.StateCode');">ST</th>
							<th align="center" valign="middle" class="head-bg" onclick="sortDispatchedBy('finalconsignee.consigneeCity');">Con.&nbsp;City</th>
							<th align="center" valign="middle" class="head-bg stHead" onclick="sortDispatchedBy('finalconsignee.consigneeState');">ST</th>
							<th align="center" valign="middle" class="head-bg deliverDate" onclick="sortDispatchedBy('l.NewDeliveryDate');">Delivery&nbsp;Date</th>
							<cfif listFindNoCase(#request.qSystemSetupOptions1.LoadsColumns#, "Cust Amt") GT 0 AND NOT ListContains(session.rightsList,'HideCustomerPricing',',')>	
								<cfif ListgetAt(loadsColumnStatus,listFindNoCase(request.qSystemSetupOptions1.LoadsColumns, "Cust Amt"))>
								<th align="right" valign="middle" class="head-bg custAmt" onclick="sortDispatchedBy('l.TOTALCUSTOMERCHARGES');">Cust&nbsp;Amt</th>
							</cfif>	
							</cfif>
							<cfif listFindNoCase(#request.qSystemSetupOptions1.LoadsColumns#, "Carr Amt") GT 0 >	
								<cfif ListgetAt(loadsColumnStatus,listFindNoCase(request.qSystemSetupOptions1.LoadsColumns, "Carr Amt"))>
								<th align="right" valign="middle" class="head-bg custAmt" onclick="sortDispatchedBy('l.TotalCarrierCharges');">Carr&nbsp;Amt</th>					
								</cfif>
							</cfif>
							<cfif listFindNoCase(#request.qSystemSetupOptions1.LoadsColumns#, "Miles") GT 0 >	
								<cfif ListgetAt(loadsColumnStatus,listFindNoCase(request.qSystemSetupOptions1.LoadsColumns, "Miles"))>
								<th align="right" valign="middle" class="head-bg custAmt" onclick="sortDispatchedBy('l.TotalMiles');">MIles</th>					
							</cfif>
							</cfif>
							<cfif listFindNoCase(#request.qSystemSetupOptions1.LoadsColumns#, "DH Miles") GT 0 >	
								<cfif ListgetAt(loadsColumnStatus,listFindNoCase(request.qSystemSetupOptions1.LoadsColumns, "DH Miles"))>
								<th align="right" valign="middle" class="head-bg custAmt" onclick="sortDispatchedBy('l.DeadHeadMiles');" style="min-width: 60px;">DH Miles</th>					
							</cfif>
							</cfif>
							<cfif isdefined('url.event') AND url.event neq 'myLoad' AND  request.qSystemSetupOptions1.ShowCarrierInvoiceNumberInAllLoads EQ 1>
								<th align="right" valign="middle" class="head-bg custAmt" onclick="sortDispatchedBy('l.CarrierInvoiceNumber');">CARR_INV</th>
							</cfif>
							<th align="center" valign="middle" class="head-bg" onclick="sortDispatchedBy('l.CARRIERNAME');">
								<cfif request.qSystemSetupOptions1.freightBroker and customer NEQ 1>
									Carrier
								<cfelseif NOT val(request.qSystemSetupOptions1.freightBroker)>
									Driver
								</cfif>
							</th>
							<th align="center" valign="middle" class="head-bg dispatch" onclick="sortDispatchedBy('Equipments1.EquipmentName');">Equipment </th>
							<th align="center" valign="middle" class="head-bg dispatch" onclick="sortDispatchedBy('l.DriverName');">Driver </th>
							<th align="center" valign="middle" class="head-bg dispatch" onclick="sortDispatchedBy('Employees.empDispatch');">Dispatcher </th>
							<th align="center" valign="middle" class="head-bg2 agent" <cfif request.qSystemSetupOptions1.freightBroker> onclick="sortDispatchedBy('l.SalesAgent');" <cfelse> onclick="sortDispatchedBy('l.userDefinedFieldTrucking');"</cfif>><cfif request.qSystemSetupOptions1.freightBroker>Sales Rep <cfelse> #left(request.qSystemSetupOptions1.userDef7,9)#</cfif></th>
							<th width="5" align="right" valign="top" class="fillHeaderRight">
		  				</tr>
		  			</thead>
					<tbody>					
						<cfset variables.counter=0>
						<cfif qDispatched.recordcount>
							<cfloop query="qDispatched">
								<cfinvoke component="#variables.objloadGateway#" method="getLoadStatus" LoadStatusID="#qDispatched.statusTypeID#" returnvariable="request.qDispatchedtatus" />
								<cfinvoke component="#variables.objloadGateway#" method="getFirstShipperDeatils" LoadID="#qDispatched.Loadid#" returnvariable="request.qFirstShipperDeatils" />
								
								<cfif ListContains(session.rightsList,'editLoad',',')>
									<cfset onRowClick = "document.location.href='index.cfm?event=addload&loadid=#qDispatched.LOADID#&#session.URLToken#'">
									<cfset onHrefClick = "index.cfm?event=addload&loadid=#qDispatched.LOADID#&#session.URLToken#">
								<cfelse>
									<cfset onRowClick = "javascript: alert('You do not have the rights to edit loads');">
									<cfset onHrefClick = "javascript: alert('You do not have the rights to edit loads');">
								</cfif>
								<cfif isdefined("form.DispatchedPageNo")>
									<cfset rowNum=(qDispatched.currentRow) + ((form.DispatchedPageNo-1)*pageSize)>
								<cfelse>
									<cfset rowNum=(qDispatched.currentRow)>
								</cfif>
								<tr style="background:###request.qDispatchedtatus.ColorCode#; cursor:pointer;" onmouseover="this.style.background = '##FFFFFF';" onmouseout="this.style.background = '###request.qDispatchedtatus.ColorCode#';" <cfif qDispatched.Row mod 2 eq 0>bgcolor="##FFFFFF"<cfelse>bgcolor="##f7f7f7"</cfif>>
									<td height="20" class="sky-bg">&nbsp;</td>
									<td align="center" valign="middle" nowrap="nowrap" class="sky-bg2" onclick="#onRowClick#">#rowNum#</td>
									<input type="hidden" name="StatusText#qDispatched.loadNumber#" id="StatusText#qDispatched.loadNumber#" value="#qDispatched.STATUSTEXT#">
									<td align="left" valign="middle" nowrap="nowrap" class="normal-td" onclick="#onRowClick#"><a href="#onHrefClick#" style="color:###qDispatched.TextColorCode#">#qDispatched.loadNumber#</a></td>
									<td  align="left" valign="middle" nowrap="nowrap" class="normal-td" onclick="#onRowClick#"><a href="#onHrefClick#" style="color:###qDispatched.TextColorCode#">#qDispatched.StatusDescription#</a></td>
									<td  align="left" valign="middle" nowrap="nowrap" class="normal-td" onclick="#onRowClick#"><a href="#onHrefClick#" style="color:###qDispatched.TextColorCode#">#qDispatched.customerName#</a></td>
									<td  align="left" valign="middle" nowrap="nowrap" class="normal-td" onclick="#onRowClick#"><a href="#onHrefClick#" style="color:###qDispatched.TextColorCode#">#qDispatched.CUSTOMERPONO#</a></td>
									<td align="left" valign="middle" nowrap="nowrap" class="normal-td" onclick="#onRowClick#"><a href="#onHrefClick#" style="color:###qDispatched.TextColorCode#">#dateformat(qDispatched.PICKUPDATE,'mm/dd/yyyy')#</a></td>
									<td align="left" valign="middle" nowrap="nowrap" class="normal-td" onclick="#onRowClick#"><a href="#onHrefClick#" style="color:###qDispatched.TextColorCode#">#qDispatched.shippercity#</a></td>
									<td align="left" valign="middle" nowrap="nowrap" class="normal-td" onclick="#onRowClick#"><a href="#onHrefClick#" style="color:###qDispatched.TextColorCode#"><cfif qDispatched.shipperstate NEQ 0>#qDispatched.shipperstate#</cfif></a></td>
									<td align="left" valign="middle" nowrap="nowrap" class="normal-td" onclick="#onRowClick#"><a href="#onHrefClick#" style="color:###qDispatched.TextColorCode#">#qDispatched.consigneeCity# </a></td>
									<td align="left" valign="middle" nowrap="nowrap" class="normal-td" onclick="#onRowClick#"><a href="#onHrefClick#" style="color:###qDispatched.TextColorCode#"><cfif qDispatched.consigneeState NEQ 0>#qDispatched.consigneeState#</cfif></a></td>
									<td align="left" valign="middle" nowrap="nowrap" class="normal-td" onclick="#onRowClick#"><a href="#onHrefClick#" style="color:###qDispatched.TextColorCode#">#dateformat(qDispatched.DeliveryDATE,'mm/dd/yyyy')#</a></td>

									<cfif request.qSystemSetupOptions1.ForeignCurrencyEnabled>
										<cfif listFindNoCase(#request.qSystemSetupOptions1.LoadsColumns#, "Cust Amt") GT 0 AND NOT ListContains(session.rightsList,'HideCustomerPricing',',')>	
											<cfif ListgetAt(loadsColumnStatus,listFindNoCase(request.qSystemSetupOptions1.LoadsColumns, "Cust Amt"))>
												<td align="right" valign="middle" nowrap="nowrap" class="normal-td custAmt" onclick="#onRowClick#"><a href="#onHrefClick#" style="color:###qDispatched.TextColorCode#">#NumberFormat(qDispatched.TOTALCUSTOMERCHARGES)# #qDispatched.CUSTOMERCURRENCYISO#</a></td>
											</cfif>
										</cfif>

										<cfif listFindNoCase(#request.qSystemSetupOptions1.LoadsColumns#, "Carr Amt") GT 0 >	
										<cfif ListgetAt(loadsColumnStatus,listFindNoCase(request.qSystemSetupOptions1.LoadsColumns, "Carr Amt"))>
											<td align="right" valign="middle" nowrap="nowrap" class="normal-td carrAmt" onclick="#onRowClick#"><a href="#onHrefClick#" style="color:###qDispatched.TextColorCode#">#NumberFormat(qDispatched.TOTALCARRIERCHARGES)# #qDispatched.CARRIERCURRENCYISO#</a></td>
										</cfif>
										</cfif>
									<cfelse>
										<cfif listFindNoCase(#request.qSystemSetupOptions1.LoadsColumns#, "Cust Amt") GT 0 AND NOT ListContains(session.rightsList,'HideCustomerPricing',',')>	
										<cfif ListgetAt(loadsColumnStatus,listFindNoCase(request.qSystemSetupOptions1.LoadsColumns, "Cust Amt"))>
											<td align="right" valign="middle" nowrap="nowrap" class="normal-td custAmt" onclick="#onRowClick#"><a href="#onHrefClick#" style="color:###qDispatched.TextColorCode#">#NumberFormat(qDispatched.TOTALCUSTOMERCHARGES,'$')#</a></td>
										</cfif>
										</cfif>

										<cfif listFindNoCase(#request.qSystemSetupOptions1.LoadsColumns#, "Carr Amt") GT 0 >	
										<cfif ListgetAt(loadsColumnStatus,listFindNoCase(request.qSystemSetupOptions1.LoadsColumns, "Carr Amt"))>
											<td align="right" valign="middle" nowrap="nowrap" class="normal-td carrAmt" onclick="#onRowClick#"><a href="#onHrefClick#" style="color:###qDispatched.TextColorCode#">#NumberFormat(qDispatched.TOTALCARRIERCHARGES,'$')#</a></td>
										</cfif>
										</cfif>
									</cfif>

									<cfif listFindNoCase(#request.qSystemSetupOptions1.LoadsColumns#, "Miles") GT 0 >	
									<cfif ListgetAt(loadsColumnStatus,listFindNoCase(request.qSystemSetupOptions1.LoadsColumns, "Miles"))>
										<td align="right" valign="middle" nowrap="nowrap" class="normal-td carrAmt" onclick="#onRowClick#" style="padding-right: 3px;"><a href="#onHrefClick#" style="color:###qDispatched.TextColorCode#">#qDispatched.carrierTotalMiles#</a></td>
									</cfif>
									</cfif>

									<cfif listFindNoCase(#request.qSystemSetupOptions1.LoadsColumns#, "DH Miles") GT 0 >	
									<cfif ListgetAt(loadsColumnStatus,listFindNoCase(request.qSystemSetupOptions1.LoadsColumns, "DH Miles"))>
										<td align="right" valign="middle" nowrap="nowrap" class="normal-td carrAmt" onclick="#onRowClick#" style="padding-right: 3px;"><a href="#onHrefClick#" style="color:###qDispatched.TextColorCode#">#qDispatched.DeadHeadMiles#</a></td>
									</cfif>
									</cfif>
									<cfif isdefined('url.event') AND url.event neq 'myLoad'  AND  request.qSystemSetupOptions1.ShowCarrierInvoiceNumberInAllLoads EQ 1>
											<td align="right" valign="middle" nowrap="nowrap" class="normal-td carrAmt" onclick="#onRowClick#"><a href="#onHrefClick#" style="color:###qDispatched.TextColorCode#">
											<cfif qDispatched.CarrierInvoiceNumber NEQ 0>#qDispatched.CarrierInvoiceNumber#</cfif>
											</a></td>
										</cfif>

									<cfif customer neq 1>
										<td  align="left" valign="middle" nowrap="nowrap" class="normal-td" onclick="#onRowClick#">
											<a href="#onHrefClick#" style="color:###qDispatched.TextColorCode#">#qDispatched.CARRIERNAME#</a>
										</td>
									</cfif>
									<td  align="left" valign="middle" nowrap="nowrap" class="normal-td" onclick="#onRowClick#"><a href="#onHrefClick#" style="color:###qDispatched.TextColorCode#">#qDispatched.EquipmentName#</a></td>
									<td  align="left" valign="middle" nowrap="nowrap" class="normal-td" onclick="#onRowClick#"><a href="#onHrefClick#" style="color:###qDispatched.TextColorCode#">#qDispatched.DriverName#</a></td>
									<td  align="left" valign="middle" nowrap="nowrap" class="normal-td" onclick="#onRowClick#"><a href="#onHrefClick#" style="color:###qDispatched.TextColorCode#">#qDispatched.empDispatch#</a></td>
									<td  align="left" valign="middle" nowrap="nowrap" class="normal-td2" onclick="#onRowClick#"><a href="#onHrefClick#" style="color:###qDispatched.TextColorCode#"><cfif request.qSystemSetupOptions1.freightBroker>#qDispatched.empAgent# <cfelse> #qDispatched.userDefinedFieldTrucking#</cfif></a></td>
									<td class="normal-td3">&nbsp;</td>
								</tr>
								<cfset variables.counter++>
							</cfloop>
						<cfelse>
							<tr>
								<td colspan='18' align="center">
									No Records Found.
								</td>
							</tr>
						</cfif>
					</tbody>
					<tfoot>
						<tr>
							<td width="5" align="left" valign="top"><img src="images/left-bot.gif" alt="" width="5" height="23" /></td>
							<td colspan='18' align="left" valign="middle" class="footer-bg">
								<div class="up-down">
									<div class="arrow-top"><a href="javascript: DispatchedTablePrevPage();"><img src="images/arrow-top.gif" alt="" /></a></div>
									<div class="arrow-bot"><a href="javascript: DispatchedTableNextPage();"><img src="images/arrow-bot.gif" alt="" /></a></div>
								</div>
								<div class="gen-left"><a href="javascript: DispatchedTablePrevPage();">Prev </a>-<a href="javascript: DispatchedTableNextPage();"> Next</a></div>
								<div class="gen-right"><img src="images/loader.gif" alt="" /></div>
								<div class="clear"></div>
							</td>
							<td class="footer-bg"></td>
							<td class="footer-bg"></td>
							<td width="6" align="right" valign="top"><img src="images/right-bot.gif" alt="" width="5" height="23" /></td>
						</tr>
					</tfoot>
				</table>
			</div>
		<cfelse>
			<div style="width: 100% ">
				<H2>Future Loads</H2>
				<table width="100%" border="0" cellspacing="0" cellpadding="0" class="data-table">			  
					<thead>
						<tr>
							<th width="5" align="left" valign="top" class="sky-bg"></th>
							<th width="29" align="center" valign="middle" class="head-bg numbering">&nbsp;</th>
							<cfif request.qSystemSetupOptions1.rolloverShipDateStatus AND structKeyExists(request, "qrygetAgentdetails") AND structKeyExists(request.qrygetAgentdetails, "ROLEID") AND request.qrygetAgentdetails.ROLEID neq 7>
								<cfif isdefined('url.event') AND url.event neq 'exportData'>
									<th  align="center" valign="middle" class="head-bg"> <input type="checkbox" name="rolloverShipDateAll" id="rolloverShipDateAll" class="checkboxSelect" onclick="checkboxOperation(this)"></th>
								</cfif>
							</cfif>
							<th align="center" valign="middle" class="head-bg load" onclick="sortFutureLoadsBy('l.LoadNumber');">LOAD##</th>
							<th align="center" style="width:10% !important;" valign="middle" class="head-bg " onclick="sortFutureLoadsBy('c.CarrierName');">Driver </th>
							<th align="center" style="width:10% !important;"  valign="middle" class="head-bg " onclick="sortFutureLoadsBy('l.TruckNo');">TRK ##</th>
							<th align="center" style="width:10% !important;" valign="middle" class="head-bg " onclick="sortFutureLoadsBy('l.TrailorNo');">TRL ##</th>
							<th align="center"  style="width:10% !important;" valign="middle" class="head-bg " onclick="sortFutureLoadsBy('l.CustName');">Customer</th>
							<th align="center"  style="width:10% !important;" valign="middle" class="head-bg " onclick="sortFutureLoadsBy('FirstShipper.custName');">Shipper</th>
							<th align="center"  style="width:10% !important;" valign="middle" class="head-bg " >Commodity</th>
							<th align="center"  style="width:10% !important;" valign="middle" class="head-bg " >Consignee</th>
							<cfif isdefined('url.event') AND url.event neq 'myLoad' AND  request.qSystemSetupOptions1.ShowCarrierInvoiceNumberInAllLoads EQ 1>
								<th align="center"  style="width:10% !important;" valign="middle" class="head-bg "  onclick="sortFutureLoadsBy('l.CarrierInvoiceNumber');">CARR_INV</th>
							</cfif>
							<th align="center"  style="width:10% !important;" valign="middle" class="head-bg " onclick="sortFutureLoadsBy('l.NewDeliveryDate');">Delivery&nbsp;Date</th>
							<th align="center"  style="width:10% !important;" valign="middle" class="head-bg " onclick="sortFutureLoadsBy('l.NewDeliveryTime');">DelTime</th>
							<th width="5" align="center" valign="middle" style="width:20% !important;" nowrap="nowrap" class="head-bg " >Dispatch Notes</th>
						</tr>
				  	</thead>
					<tbody>		
						<cfif qFutureLoads.recordcount>	  
							<cfloop query="qFutureLoads">
								<cfset onHrefClick = "index.cfm?event=addload&loadid=#qFutureLoads.LOADID#&#session.URLToken#">
								<cfinvoke component="#variables.objloadGateway#" method="getLoadStatus" LoadStatusID="#qFutureLoads.statusTypeID#" returnvariable="request.qFutureLoadstatus" />
								<tr style="background:###request.qFutureLoadstatus.ColorCode#; cursor:pointer;" onmouseover="this.style.background = '##FFFFFF';" onmouseout="this.style.background = '###request.qFutureLoadstatus.ColorCode#';" <cfif qFutureLoads.Row mod 2 eq 0>bgcolor="##FFFFFF"<cfelse>bgcolor="##f7f7f7"</cfif>>
									<td height="20" class="sky-bg">&nbsp;</td>								
									<td align="center" valign="middle" nowrap="nowrap" class="sky-bg2" >#qFutureLoads.Row#</td>
									<cfif request.qSystemSetupOptions1.rolloverShipDateStatus AND structKeyExists(request, "qrygetAgentdetails") AND structKeyExists(request.qrygetAgentdetails, "ROLEID") AND request.qrygetAgentdetails.ROLEID neq 7>
										<cfif isdefined('url.event') AND url.event neq 'exportData'>
											<td align="center" valign="middle" nowrap="nowrap" class="sky-bg2 " style="padding: 0 5px 0 5px;" ><cfinput type="checkbox" name="rolloverShipDateCheckSub" id="rolloverShipDateCheckSub" class="checkboxSelect" value="#qFutureLoads.loadNumber#"></td>
										</cfif>
									</cfif>
									<input type="hidden" name="StatusText#qFutureLoads.loadNumber#" id="StatusText#qFutureLoads.loadNumber#" value="#qFutureLoads.STATUSTEXT#">
									<td align="left" valign="middle" nowrap="nowrap" class="normal-td"  onclick="location.href='#onHrefClick#'"><a href="#onHrefClick#">#qFutureLoads.loadNumber#</a></td>
									<td align="left" valign="middle" nowrap="nowrap" class="normal-td"  onclick="location.href='#onHrefClick#'"><a href="#onHrefClick#">#qFutureLoads.DriverName#</a></td>
									<td align="left" valign="middle" nowrap="nowrap" class="normal-td"  onclick="location.href='#onHrefClick#'"><a href="#onHrefClick#">#replace(qFutureLoads.TruckNo,",,","","all")#</a></td>
									<td align="left" valign="middle" nowrap="nowrap" class="normal-td"  onclick="location.href='#onHrefClick#'"><a href="#onHrefClick#">#replace(qFutureLoads.TrailorNo,",,","","all")#</a></td>
									<td align="left" valign="middle" nowrap="nowrap" class="normal-td"  onclick="location.href='#onHrefClick#'"><a href="#onHrefClick#">#qFutureLoads.Customer#</a></td>
									<td align="left" valign="middle" nowrap="nowrap" class="normal-td"  onclick="location.href='#onHrefClick#'"><a href="#onHrefClick#">#qFutureLoads.Shipper#</a></td>
									<td align="left" valign="middle" nowrap="nowrap" class="normal-td"  onclick="location.href='#onHrefClick#'"><a href="#onHrefClick#">#qFutureLoads.COMMODITY#</a></td>
									<td align="left" valign="middle" nowrap="nowrap" class="normal-td"  onclick="location.href='#onHrefClick#'"><a href="#onHrefClick#">#qFutureLoads.CONSIGNEE#</a></td>
									<cfif isdefined('url.event') AND url.event neq 'myLoad'  AND  request.qSystemSetupOptions1.ShowCarrierInvoiceNumberInAllLoads EQ 1>
										<td align="left" valign="middle" nowrap="nowrap" class="normal-td"  onclick="location.href='#onHrefClick#'"><a href="#onHrefClick#">
											<cfif qFutureLoads.CarrierInvoiceNumber NEQ 0> #qFutureLoads.CarrierInvoiceNumber#</cfif>
										</a></td>
									</cfif>
									<td align="left" valign="middle" nowrap="nowrap" class="normal-td"  onclick="location.href='#onHrefClick#'"><a href="#onHrefClick#">#DateFormat(qFutureLoads.NewDeliveryDate,'mm/dd/yyyy')#</a></td>
									<td align="left" valign="middle" nowrap="nowrap" class="normal-td"  onclick="location.href='#onHrefClick#'"><a href="#onHrefClick#">#qFutureLoads.DelTime#</a></td>
									<td align="left" valign="middle" nowrap="nowrap" style="width:20% !important;" class="normal-td" >
										<a href="javascript:void(0)" style="text-decoration: underline !important;" class="InfotoolTip" title="#qFutureLoads.DispatchNotes#"> Show Notes</a>
									</td>
								</tr>
							</cfloop>
						<cfelse>
							<tr>
								<td colspan='18' align="center">
									No Records Found.
								</td>
							</tr>
						</cfif>
					</tbody>	
					<tfoot>
						<tr>
							<td width="5" align="left" valign="top"><img src="images/left-bot.gif" alt="" width="5" height="23" /></td>
							<td colspan='18' align="left" valign="middle" class="footer-bg">
								<div class="up-down">
									<div class="arrow-top"><a href="javascript: FutureLoadsTablePrevPage();"><img src="images/arrow-top.gif" alt="" /></a></div>
									<div class="arrow-bot"><a href="javascript: FutureLoadsTableNextPage();"><img src="images/arrow-bot.gif" alt="" /></a></div>
								</div>
								<div class="gen-left"><a href="javascript: FutureLoadsTablePrevPage();">Prev </a>-<a href="javascript: FutureLoadsTableNextPage();"> Next</a></div>
								<div class="gen-right"><img src="images/loader.gif" alt="" /></div>
								<div class="clear"></div>
							</td>
							<td class="footer-bg"></td>
							<td class="footer-bg"></td>
							<td width="6" align="right" valign="top"><img src="images/right-bot.gif" alt="" width="5" height="23" /></td>
						</tr>
					</tfoot>		
				</table>
			</div>
			<div class="clear"></div>
			<div class="clear"></div>
			<div style="width: 100% ">
				<H2>Today's Loads</H2>
				<table width="100%" border="0" cellspacing="0" cellpadding="0" class="data-table">			  
					<thead>
						<tr>
							<th width="5" align="left" valign="top" class="sky-bg"></th>
							<th width="29" align="center" valign="middle" class="head-bg numbering">&nbsp;</th>
							<cfif request.qSystemSetupOptions1.rolloverShipDateStatus AND structKeyExists(request, "qrygetAgentdetails") AND structKeyExists(request.qrygetAgentdetails, "ROLEID") AND request.qrygetAgentdetails.ROLEID neq 7>
								<cfif isdefined('url.event') AND url.event neq 'exportData'>
									<th  align="center" valign="middle" class="head-bg"> <input type="checkbox" name="rolloverShipDateAll" id="rolloverShipDateAll" class="checkboxSelect" onclick="checkboxOperation(this)"></th>
								</cfif>
							</cfif>
							<th align="center" valign="middle" class="head-bg load" onclick="sortTodaysLoadBy('l.LoadNumber');">LOAD##</th>
							<th align="center" style="width:10% !important;" valign="middle" class="head-bg " onclick="sortTodaysLoadBy('c.CarrierName');">Driver </th>
							<th align="center" style="width:10% !important;"  valign="middle" class="head-bg " onclick="sortTodaysLoadBy('l.TruckNo');">TRK ##</th>
							<th align="center" style="width:10% !important;" valign="middle" class="head-bg " onclick="sortTodaysLoadBy('l.TrailorNo');">TRL ##</th>
							<th align="center"  style="width:10% !important;" valign="middle" class="head-bg " onclick="sortTodaysLoadBy('l.CustName');">Customer</th>
							<th align="center"  style="width:10% !important;" valign="middle" class="head-bg " onclick="sortTodaysLoadBy('FirstShipper.custName');">Shipper</th>
							<th align="center"  style="width:10% !important;" valign="middle" class="head-bg " >Commodity</th>
							<th align="center"  style="width:10% !important;" valign="middle" class="head-bg " >Consignee</th>
							<cfif isdefined('url.event') AND url.event neq 'myLoad' AND  request.qSystemSetupOptions1.ShowCarrierInvoiceNumberInAllLoads EQ 1>
								<th align="center"  style="width:10% !important;" valign="middle" class="head-bg "  onclick="sortTodaysLoadBy('l.CarrierInvoiceNumber');">CARR_INV</th>
							</cfif>
							<th align="center"  style="width:10% !important;" valign="middle" class="head-bg " onclick="sortTodaysLoadBy('l.NewDeliveryDate');">Delivery&nbsp;Date</th>
							<th align="center"  style="width:10% !important;" valign="middle" class="head-bg " onclick="sortTodaysLoadBy('l.NewDeliveryTime');">DelTime</th>
							<th width="5" align="center" valign="middle" style="width:20% !important;" nowrap="nowrap" class="head-bg " >Dispatch Notes</th>
						</tr>
				  	</thead>
					<tbody>		
						<cfif qTodaysLoad.recordcount>	  
							<cfloop query="qTodaysLoad">
								<cfset onHrefClick = "index.cfm?event=addload&loadid=#qTodaysLoad.LOADID#&#session.URLToken#">
								<cfinvoke component="#variables.objloadGateway#" method="getLoadStatus" LoadStatusID="#qTodaysLoad.statusTypeID#" returnvariable="request.qTodaysLoadtatus" />
								<tr style="background:###request.qTodaysLoadtatus.ColorCode#; cursor:pointer;" onmouseover="this.style.background = '##FFFFFF';" onmouseout="this.style.background = '###request.qTodaysLoadtatus.ColorCode#';" <cfif qTodaysLoad.Row mod 2 eq 0>bgcolor="##FFFFFF"<cfelse>bgcolor="##f7f7f7"</cfif>>
									<td height="20" class="sky-bg">&nbsp;</td>								
									<td align="center" valign="middle" nowrap="nowrap" class="sky-bg2" >#qTodaysLoad.Row#</td>
									<cfif request.qSystemSetupOptions1.rolloverShipDateStatus AND structKeyExists(request, "qrygetAgentdetails") AND structKeyExists(request.qrygetAgentdetails, "ROLEID") AND request.qrygetAgentdetails.ROLEID neq 7>
										<cfif isdefined('url.event') AND url.event neq 'exportData'>
											<td align="center" valign="middle" nowrap="nowrap" class="sky-bg2 " style="padding: 0 5px 0 5px;" ><cfinput type="checkbox" name="rolloverShipDateCheckSub" id="rolloverShipDateCheckSub" class="checkboxSelect" value="#qTodaysLoad.loadNumber#"></td>
										</cfif>
									</cfif>
									<input type="hidden" name="StatusText#qTodaysLoad.loadNumber#" id="StatusText#qTodaysLoad.loadNumber#" value="#qTodaysLoad.STATUSTEXT#">
									<td align="left" valign="middle" nowrap="nowrap" class="normal-td"  onclick="location.href='#onHrefClick#'"><a href="#onHrefClick#">#qTodaysLoad.loadNumber#</a></td>
									<td align="left" valign="middle" nowrap="nowrap" class="normal-td"  onclick="location.href='#onHrefClick#'"><a href="#onHrefClick#">#qTodaysLoad.DriverName#</a></td>
									<td align="left" valign="middle" nowrap="nowrap" class="normal-td"  onclick="location.href='#onHrefClick#'"><a href="#onHrefClick#">#replace(qTodaysLoad.TruckNo,",,","","all")#</a></td>
									<td align="left" valign="middle" nowrap="nowrap" class="normal-td"  onclick="location.href='#onHrefClick#'"><a href="#onHrefClick#">#replace(qTodaysLoad.TrailorNo,",,","","all")#</a></td>
									<td align="left" valign="middle" nowrap="nowrap" class="normal-td"  onclick="location.href='#onHrefClick#'"><a href="#onHrefClick#">#qTodaysLoad.Customer#</a></td>
									<td align="left" valign="middle" nowrap="nowrap" class="normal-td"  onclick="location.href='#onHrefClick#'"><a href="#onHrefClick#">#qTodaysLoad.Shipper#</a></td>
									<td align="left" valign="middle" nowrap="nowrap" class="normal-td"  onclick="location.href='#onHrefClick#'"><a href="#onHrefClick#">#qTodaysLoad.COMMODITY#</a></td>
									<td align="left" valign="middle" nowrap="nowrap" class="normal-td"  onclick="location.href='#onHrefClick#'"><a href="#onHrefClick#">#qTodaysLoad.CONSIGNEE#</a></td>
									<cfif isdefined('url.event') AND url.event neq 'myLoad'  AND  request.qSystemSetupOptions1.ShowCarrierInvoiceNumberInAllLoads EQ 1>
										<td align="left" valign="middle" nowrap="nowrap" class="normal-td"  onclick="location.href='#onHrefClick#'"><a href="#onHrefClick#">
											<cfif qTodaysLoad.CarrierInvoiceNumber NEQ 0> #qTodaysLoad.CarrierInvoiceNumber#</cfif>
										</a></td>
									</cfif>
									<td align="left" valign="middle" nowrap="nowrap" class="normal-td"  onclick="location.href='#onHrefClick#'"><a href="#onHrefClick#">#DateFormat(qTodaysLoad.NewDeliveryDate,'mm/dd/yyyy')#</a></td>
									<td align="left" valign="middle" nowrap="nowrap" class="normal-td"  onclick="location.href='#onHrefClick#'"><a href="#onHrefClick#">#qTodaysLoad.DelTime#</a></td>
									<td align="left" valign="middle" nowrap="nowrap" style="width:20% !important;" class="normal-td" >
										<a href="javascript:void(0)" style="text-decoration: underline !important;" class="InfotoolTip" title="#qTodaysLoad.DispatchNotes#"> Show Notes</a>
									</td>
								</tr>
							</cfloop>
						<cfelse>
							<tr>
								<td colspan='18' align="center">
									No Records Found.
								</td>
							</tr>
						</cfif>
					</tbody>	
					<tfoot>
						<tr>
							<td width="5" align="left" valign="top"><img src="images/left-bot.gif" alt="" width="5" height="23" /></td>
							<td colspan='18' align="left" valign="middle" class="footer-bg">
								<div class="up-down">
									<div class="arrow-top"><a href="javascript: TodaysLoadTablePrevPage();"><img src="images/arrow-top.gif" alt="" /></a></div>
									<div class="arrow-bot"><a href="javascript: TodaysLoadTableNextPage();"><img src="images/arrow-bot.gif" alt="" /></a></div>
								</div>
								<div class="gen-left"><a href="javascript: TodaysLoadTablePrevPage();">Prev </a>-<a href="javascript: TodaysLoadTableNextPage();"> Next</a></div>
								<div class="gen-right"><img src="images/loader.gif" alt="" /></div>
								<div class="clear"></div>
							</td>
							<td class="footer-bg"></td>
							<td class="footer-bg"></td>
							<td width="6" align="right" valign="top"><img src="images/right-bot.gif" alt="" width="5" height="23" /></td>
						</tr>
					</tfoot>		
				</table>
			</div>
			<div class="clear"></div>
			<div class="clear"></div>
			<div style="width: 100% ">
				<H2>Dispatched Loads</H2>
				<table width="100%" border="0" cellspacing="0" cellpadding="0" class="data-table">			  
					<thead>
						<tr>
							<th width="5" align="left" valign="top" class="sky-bg"></th>
							<th width="29" align="center" valign="middle" class="head-bg numbering">&nbsp;</th>
							<cfif request.qSystemSetupOptions1.rolloverShipDateStatus AND structKeyExists(request, "qrygetAgentdetails") AND structKeyExists(request.qrygetAgentdetails, "ROLEID") AND request.qrygetAgentdetails.ROLEID neq 7>
								<cfif isdefined('url.event') AND url.event neq 'exportData'>
									<th  align="center" valign="middle" class="head-bg"> <input type="checkbox" name="rolloverShipDateAll" id="rolloverShipDateAll" class="checkboxSelect" onclick="checkboxOperation(this)"></th>
								</cfif>
							</cfif>
							<th align="center" valign="middle" class="head-bg load" onclick="sortDispatchedBy('l.LoadNumber');">LOAD##</th>
							<th align="center" style="width:10% !important;" valign="middle" class="head-bg " onclick="sortDispatchedBy('c.CarrierName');">Driver </th>
							<th align="center" style="width:10% !important;"  valign="middle" class="head-bg " onclick="sortDispatchedBy('l.TruckNo');">TRK ##</th>
							<th align="center" style="width:10% !important;" valign="middle" class="head-bg " onclick="sortDispatchedBy('l.TrailorNo');">TRL ##</th>
							<th align="center"  style="width:10% !important;" valign="middle" class="head-bg " onclick="sortDispatchedBy('l.CustName');">Customer</th>
							<th align="center"  style="width:10% !important;" valign="middle" class="head-bg " onclick="sortDispatchedBy('FirstShipper.custName');">Shipper</th>
							<th align="center"  style="width:10% !important;" valign="middle" class="head-bg " >Commodity</th>
							<th align="center"  style="width:10% !important;" valign="middle" class="head-bg " >Consignee</th>
							<cfif isdefined('url.event') AND url.event neq 'myLoad' AND  request.qSystemSetupOptions1.ShowCarrierInvoiceNumberInAllLoads EQ 1>
								<th align="center"  style="width:10% !important;" valign="middle" class="head-bg "  onclick="sortDispatchedBy('l.CarrierInvoiceNumber');">CARR_INV</th>
							</cfif>
							<th align="center"  style="width:10% !important;" valign="middle" class="head-bg " onclick="sortDispatchedBy('l.NewDeliveryDate');">Delivery&nbsp;Date</th>
							<th align="center"  style="width:10% !important;" valign="middle" class="head-bg " onclick="sortDispatchedBy('l.NewDeliveryTime');">DelTime</th>
							<th width="5" align="center" valign="middle" style="width:20% !important;" nowrap="nowrap" class="head-bg " >Dispatch Notes</th>
						</tr>
				  	</thead>
					<tbody>		
						<cfif qDispatched.recordcount>	  
							<cfloop query="qDispatched">
								<cfset onHrefClick = "index.cfm?event=addload&loadid=#qDispatched.LOADID#&#session.URLToken#">
								<cfinvoke component="#variables.objloadGateway#" method="getLoadStatus" LoadStatusID="#qDispatched.statusTypeID#" returnvariable="request.qDispatchedtatus" />
								<tr style="background:###request.qDispatchedtatus.ColorCode#; cursor:pointer;" onmouseover="this.style.background = '##FFFFFF';" onmouseout="this.style.background = '###request.qDispatchedtatus.ColorCode#';" <cfif qDispatched.Row mod 2 eq 0>bgcolor="##FFFFFF"<cfelse>bgcolor="##f7f7f7"</cfif>>
									<td height="20" class="sky-bg">&nbsp;</td>								
									<td align="center" valign="middle" nowrap="nowrap" class="sky-bg2" >#qDispatched.Row#</td>
									<cfif request.qSystemSetupOptions1.rolloverShipDateStatus AND structKeyExists(request, "qrygetAgentdetails") AND structKeyExists(request.qrygetAgentdetails, "ROLEID") AND request.qrygetAgentdetails.ROLEID neq 7>
										<cfif isdefined('url.event') AND url.event neq 'exportData'>
											<td align="center" valign="middle" nowrap="nowrap" class="sky-bg2 " style="padding: 0 5px 0 5px;" ><cfinput type="checkbox" name="rolloverShipDateCheckSub" id="rolloverShipDateCheckSub" class="checkboxSelect" value="#qDispatched.loadNumber#"></td>
										</cfif>
									</cfif>
									<input type="hidden" name="StatusText#qDispatched.loadNumber#" id="StatusText#qDispatched.loadNumber#" value="#qDispatched.STATUSTEXT#">
									<td align="left" valign="middle" nowrap="nowrap" class="normal-td"  onclick="location.href='#onHrefClick#'"><a href="#onHrefClick#">#qDispatched.loadNumber#</a></td>
									<td align="left" valign="middle" nowrap="nowrap" class="normal-td"  onclick="location.href='#onHrefClick#'"><a href="#onHrefClick#">#qDispatched.DriverName#</a></td>
									<td align="left" valign="middle" nowrap="nowrap" class="normal-td"  onclick="location.href='#onHrefClick#'"><a href="#onHrefClick#">#replace(qDispatched.TruckNo,",,","","all")#</a></td>
									<td align="left" valign="middle" nowrap="nowrap" class="normal-td"  onclick="location.href='#onHrefClick#'"><a href="#onHrefClick#">#replace(qDispatched.TrailorNo,",,","","all")#</a></td>
									<td align="left" valign="middle" nowrap="nowrap" class="normal-td"  onclick="location.href='#onHrefClick#'"><a href="#onHrefClick#">#qDispatched.Customer#</a></td>
									<td align="left" valign="middle" nowrap="nowrap" class="normal-td"  onclick="location.href='#onHrefClick#'"><a href="#onHrefClick#">#qDispatched.Shipper#</a></td>
									<td align="left" valign="middle" nowrap="nowrap" class="normal-td"  onclick="location.href='#onHrefClick#'"><a href="#onHrefClick#">#qDispatched.COMMODITY#</a></td>
									<td align="left" valign="middle" nowrap="nowrap" class="normal-td"  onclick="location.href='#onHrefClick#'"><a href="#onHrefClick#">#qDispatched.CONSIGNEE#</a></td>
									<cfif isdefined('url.event') AND url.event neq 'myLoad'  AND  request.qSystemSetupOptions1.ShowCarrierInvoiceNumberInAllLoads EQ 1>
										<td align="left" valign="middle" nowrap="nowrap" class="normal-td"  onclick="location.href='#onHrefClick#'"><a href="#onHrefClick#">
											<cfif qDispatched.CarrierInvoiceNumber NEQ 0> #qDispatched.CarrierInvoiceNumber#</cfif>
										</a></td>
									</cfif>
									<td align="left" valign="middle" nowrap="nowrap" class="normal-td"  onclick="location.href='#onHrefClick#'"><a href="#onHrefClick#">#DateFormat(qDispatched.NewDeliveryDate,'mm/dd/yyyy')#</a></td>
									<td align="left" valign="middle" nowrap="nowrap" class="normal-td"  onclick="location.href='#onHrefClick#'"><a href="#onHrefClick#">#qDispatched.DelTime#</a></td>
									<td align="left" valign="middle" nowrap="nowrap" style="width:20% !important;" class="normal-td" >
										<a href="javascript:void(0)" style="text-decoration: underline !important;" class="InfotoolTip" title="#qDispatched.DispatchNotes#"> Show Notes</a>
									</td>
								</tr>
							</cfloop>
						<cfelse>
							<tr>
								<td colspan='18' align="center">
									No Records Found.
								</td>
							</tr>
						</cfif>
					</tbody>	
					<tfoot>
						<tr>
							<td width="5" align="left" valign="top"><img src="images/left-bot.gif" alt="" width="5" height="23" /></td>
							<td colspan='18' align="left" valign="middle" class="footer-bg">
								<div class="up-down">
									<div class="arrow-top"><a href="javascript: DispatchedTablePrevPage();"><img src="images/arrow-top.gif" alt="" /></a></div>
									<div class="arrow-bot"><a href="javascript: DispatchedTableNextPage();"><img src="images/arrow-bot.gif" alt="" /></a></div>
								</div>
								<div class="gen-left"><a href="javascript: DispatchedTablePrevPage();">Prev </a>-<a href="javascript: DispatchedTableNextPage();"> Next</a></div>
								<div class="gen-right"><img src="images/loader.gif" alt="" /></div>
								<div class="clear"></div>
							</td>
							<td class="footer-bg"></td>
							<td class="footer-bg"></td>
							<td width="6" align="right" valign="top"><img src="images/right-bot.gif" alt="" width="5" height="23" /></td>
						</tr>
					</tfoot>		
				</table>
			</div>
		</cfif>
	</cfform>
	<div id="responseCopyLoad"></div>
</cfoutput>
  <cfcatch type="any">
        <cfdump var="#cfcatch#" />
        <cfabort>
    </cfcatch>
</cftry>