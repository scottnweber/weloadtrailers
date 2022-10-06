<!--------------------------------------------------------------------------------------------------------------------------------------------------------->
<!--- Page: exportExcel.cfm --->
<!--- Purpose: 766: Feature Request- Excel Export Feature --->
<!--- Date: 2018-02-22 --->
<!--------------------------------------------------------------------------------------------------------------------------------------------------------->
<cfinvoke component="#variables.objloadGateway#" method="getLoadStatus" returnvariable="request.qLoadStatus" />
<cfinvoke component="#variables.objloadGateway#" method="getSystemSetupOptions" returnvariable="request.qGetSystemSetupOptions" />
<cfinvoke component="#variables.objCarrierGateway#" method="getSearchedCarrier" pageno="1" searchText="" returnvariable="request.qCarrier" />
<cfinvoke component="#variables.objCustomerGateway#" method="getAllCustomers" searchText="" pageNo="1" returnvariable="request.qCustomer" />
<cfinvoke component="#variables.objloadGateway#" method="getLoadSystemSetupOptions" returnvariable="request.qSystemSetupOptions1" />
<cfif session.currentusertype EQ "administrator" OR ListContains(session.rightsList,'showAllOfficeLoads',',')>
	<cfinvoke component="#variables.objofficeGateway#" method="getAllOffices" sortby="officecode" sortorder="asc"  returnvariable="request.qOffices" />
<cfelse>
	<cfinvoke component="#variables.objofficeGateway#" method="getAllOffices" sortby="officecode" sortorder="asc" officeID="#session.officeID#" returnvariable="request.qOffices" />
</cfif>
<cfset loadStatusFrom=request.qGetSystemSetupOptions.ARANDAPEXPORTSTATUSID>
<cfset loadStatusTo=request.qGetSystemSetupOptions.ARANDAPEXPORTSTATUSID>
<cfset isLoadStatusDefault=request.qGetSystemSetupOptions.IsLoadStatusDefaultForReport>	
<cfif not isLoadStatusDefault>
	<cfquery name="qryGetStatusFrom" datasource="#application.dsn#">
		select StatusTypeID AS StatusID from LoadStatusTypes where StatusText='1. ACTIVE' and companyid = '#session.companyid#'
	</cfquery>
	<cfquery name="qryGetStatusTo" datasource="#application.dsn#">
		select StatusTypeID AS StatusID from LoadStatusTypes where StatusText='8. COMPLETED' and companyid = '#session.companyid#'
	</cfquery>
	<cfset loadStatusFrom=qryGetStatusFrom.StatusID>
	<cfset loadStatusTo=qryGetStatusTo.StatusID>
</cfif>
<cfoutput>
	<style type="text/css">
		.reportsSubHeading{
			border-bottom: 1px solid ##95cac885 !important;
			margin-bottom: 16px !important;
			padding-left:0px !important;
		}
	</style>
	<div class="white-con-area" style="height: 36px;background-color: ##82bbef;">
		<div style="float: left;"><h2 style="color:white;font-weight:bold;margin-left: 12px;">Export</h2></div>
	</div>
	<div style="clear:left"></div>
	<style>
		.white-mid div.form-con fieldset.TolExp{
			border: 1px dashed ##a9d6ff;
		    padding: 36px 25px;
		    margin-bottom: 13px;
		}
		.reportsSubHeading.expoCustmr{
			padding: 0px 0 6px 0px !important;
			border-bottom: 1px solid ##95cac885 !important;
    		margin-bottom: 14px !important;
		}
		.disAllowEditSelectBox {
			background: none repeat scroll 0 0 ##e3e3e3 !important;
			border: 1px solid ##c5c1c1 !important;
			color: ##434343 !important;
			pointer-events: none;
		}
	</style>
	<div class="white-con-area">
		<div class="white-top"></div>
		<div class="white-mid">
			<div class="form-con">
				<cfform name="frmExcelCustomersExport" action="index.cfm?event=ExportExcel:customers&#session.URLToken#" method="post">
					<fieldset class="TolExp">
						<h2 class="reportsSubHeading expoCustmr">Customers</h2>
						<div class="clear"></div>  
						<div>
							<p>* Click to export the details of Customers</p>
							<input id="excelSalesSummary" type="submit" name="excelSalesSummary" class="bttn tooltip" value="Export" style="width:95px;"/>
						</div>
					</fieldset>
				</cfform>
			</div>
			<div class="form-con">
				<cfform name="frmExcelCarrierDriverExport" action="index.cfm?event=ExportExcel:carriersDrivers&#session.URLToken#" method="post">
					<div class="clear"></div> 
					<fieldset class="TolExp">
						<h2 class="reportsSubHeading expoCustmr">Carriers/ Drivers</h2>
						<div class="clear"></div>  
						<div>
							<p>* Click to export the details of Carriers/ Drivers</p>
							<input id="excelSalesDetails" type="submit" name="excelSalesDetails" class="bttn tooltip" value="Export" style="width:95px;"/>
						</div>
					</fieldset>
				</cfform>
			</div>
			<div class="clear"></div>
			<div class="form-con">
				<cfform name="frmExcelSalesSummaryExport" id="frmExcelSalesSummaryExport" action="index.cfm?event=ExportExcel:salesSummary&#session.URLToken#" method="post">
					<input type="hidden" name="CompanyID" value="#session.CompanyID#">
					<fieldset style="padding-bottom: 10px;">
						<h2 class="reportsSubHeading">Sales Summary</h2>
						<div class="clear"></div>  
						<label class="space_it" style="width: 103px;">Order Date From</label>
						<div style="position:relative;float:left;">
							<div style="float:left;">
								<input class="sm-input datefield" style="width: 79px;" tabindex=4 name="summaryDateFrom" id="summaryDateFrom"  value="#dateformat(Now()-30,'mm/dd/yyy')#" validate="date" message="Please enter a valid date" type="datefield" />
							</div>
						</div>
						<label style="margin-left: -57px;width: 77px;">To</label> 
						<div style="position:relative;float:left;">
							<div style="float:left;">
								<input class="sm-input datefield" style="width: 79px;" tabindex=4 name="summaryDateTo" id="summaryDateTo"  value="#dateformat(Now(),'mm/dd/yyy')#" validate="date" message="Please enter a valid date" type="datefield" />
							</div>
						</div>

						<div class="clear"></div>  
						<label class="space_it" style="width: 103px;">Invoice Date From</label>
						<div style="position:relative;float:left;">
							<div style="float:left;">
								<input class="sm-input datefield" style="width: 79px;" tabindex=4 name="summaryInvoiceDateFrom" id="summaryInvoiceDateFrom" validate="date" type="datefield" />
							</div>
						</div>
						<label style="margin-left: -57px;width: 77px;">To</label> 
						<div style="position:relative;float:left;">
							<div style="float:left;">
								<input class="sm-input datefield" style="width: 79px;" tabindex=4 name="summaryInvoiceDateTo" id="summaryInvoiceDateTo" validate="date" type="datefield" />
							</div>
						</div>

						<div class="clear"></div>  
						<label class="space_it" style="width: 103px;">Pickup Date From</label>
						<div style="position:relative;float:left;">
							<div style="float:left;">
								<input class="sm-input datefield" style="width: 79px;" tabindex=4 name="summaryPickupDateFrom" id="summaryPickupDateFrom" validate="date" type="datefield" />
							</div>
						</div>
						<label style="margin-left: -57px;width: 77px;">To</label> 
						<div style="position:relative;float:left;">
							<div style="float:left;">
								<input class="sm-input datefield" style="width: 79px;" tabindex=4 name="summaryPickupDateTo" id="summaryPickupDateTo" validate="date" type="datefield" />
							</div>
						</div>

						<div class="clear"></div>  
						<label class="space_it" style="width: 103px;">Delivery Date From</label>
						<div style="position:relative;float:left;">
							<div style="float:left;">
								<input class="sm-input datefield" style="width: 79px;" tabindex=4 name="summaryDeliveryDateFrom" id="summaryDeliveryDateFrom" validate="date" type="datefield" />
							</div>
						</div>
						<label style="margin-left: -57px;width: 77px;">To</label> 
						<div style="position:relative;float:left;">
							<div style="float:left;">
								<input class="sm-input datefield" style="width: 79px;" tabindex=4 name="summaryDeliveryDateTo" id="summaryDeliveryDateTo" validate="date" type="datefield" />
							</div>
						</div>
						<div class="clear"></div>  
						<label class="space_it" style="width: 103px;">Status From</label>
						<div style="position:relative;float:left;">
							<div style="float:left;">
								<select name="summaryStatusFrom" id="summaryStatusFrom" style="width: 100px;">
									<cfloop query="request.qLoadStatus">
										<option value="#request.qLoadStatus.value#" <cfif loadStatusFrom EQ  request.qLoadStatus.value>selected="selected"</cfif>>#request.qLoadStatus.statusdescription#</option>
									</cfloop>
								</select>
							</div>
						</div>
						<label style="margin-left: -50px;width: 77px;">To</label> 
						<div style="position:relative;float:left;">
							<div style="float:left;">
								<select name="summaryStatusTo" id="summaryStatusTo" style="width: 100px;">
									<cfloop query="request.qLoadStatus">
										<option value="#request.qLoadStatus.value#" <cfif loadStatusTo EQ  request.qLoadStatus.value>selected="selected"</cfif>>#request.qLoadStatus.statusdescription#</option>
									</cfloop>
								</select>
							</div>
						</div>

						<div class="clear"></div>  
						<label class="space_it" style="width: 103px;">Office From</label>
						<div style="position:relative;float:left;">
							<div style="float:left;">
								<select name="summaryOfficeFrom" id="summaryOfficeFrom" style="width: 100px;" <cfif NOT (session.currentusertype EQ "administrator" OR ListContains(session.rightsList,'showAllOfficeLoads',','))> class="disAllowEditSelectBox" </cfif>>
									<cfloop query="request.qOffices">
										<option value="#request.qOffices.officecode#">#request.qOffices.officecode#</option>
									</cfloop>
								</select>
							</div>
						</div>
						<label style="margin-left: -50px;width: 77px;">To</label> 
						<div style="position:relative;float:left;">
							<div style="float:left;">
								<select name="summaryOfficeTo" id="summaryOfficeTo" style="width: 100px;" <cfif NOT (session.currentusertype EQ "administrator" OR ListContains(session.rightsList,'showAllOfficeLoads',','))> class="disAllowEditSelectBox" </cfif>>
									<cfloop query="request.qOffices">
										<option value="#request.qOffices.officecode#" <cfif request.qOffices.recordcount EQ request.qOffices.currentrow> selected </cfif> >#request.qOffices.officecode#</option>
									</cfloop>
								</select>
							</div>
						</div>

						<div class="clear"></div>  
						<label class="space_it" style="width: 103px;">PO ## From</label>
						<div style="position:relative;float:left;">
							<div style="float:left;">
								<input style="width: 95px;" class="sm-input datefield" tabindex=4 name="summaryPOFrom" type="text" />
							</div>
						</div>
						<label style="margin-left: -54px;width: 72px;">To</label> 
						<div style="position:relative;float:left;">
							<div style="float:left;">
								<input style="width: 95px;" class="sm-input datefield" tabindex=4 name="summaryPOTo" type="text" />
							</div>
						</div>

						<div class="clear"></div>  
						<label class="space_it" style="width: 103px;"><cfif request.qSystemSetupOptions1.freightBroker eq 0>Driver <cfelseif request.qSystemSetupOptions1.freightBroker eq 1>Carrier <cfelseif request.qSystemSetupOptions1.freightBroker eq 2>Carrier/ Driver </cfif>From</label>
						<div style="position:relative;float:left;">
							<div style="float:left;">
								<a href="javascript:void(0);" onclick="chooseCarrier('summaryCarrierFrom');" id="removesummaryCarrierFrom" style="color:##236334;display: none">
                                    <img style="vertical-align:bottom;" src="images/change.png">
                                    <span class="removetxt">Remove <cfif request.qSystemSetupOptions1.freightBroker eq 0>Driver <cfelseif request.qSystemSetupOptions1.freightBroker eq 1>Carrier <cfelseif request.qSystemSetupOptions1.freightBroker eq 2>Carrier/ Driver </cfif></span>
                                </a>
								<input name="selectedCarrier" class="selectedCarrierValue sm-input" style="width: 232px;" type="text" title="Type text here to display list." data-id="summaryCarrierFrom" id="selectedCarrierValuesummaryCarrierFrom"/>
								<input type="hidden" name="summaryCarrierFrom" id="summaryCarrierFrom">
							</div>
						</div>
						<div id="CarrierInfosummaryCarrierFrom" style="display:none;"></div>
						<div class="clear"></div> 
						<label class="space_it" style="width: 103px;"><cfif request.qSystemSetupOptions1.freightBroker eq 0>Driver <cfelseif request.qSystemSetupOptions1.freightBroker eq 1>Carrier <cfelseif request.qSystemSetupOptions1.freightBroker eq 2>Carrier/ Driver </cfif> To</label> 
						<div style="position:relative;float:left;">
							<div style="float:left;">
								<a href="javascript:void(0);" onclick="chooseCarrier('summaryCarrierTo');" id="removesummaryCarrierTo" style="color:##236334;display: none">
                                    <img style="vertical-align:bottom;" src="images/change.png">
                                    <span class="removetxt">Remove <cfif request.qSystemSetupOptions1.freightBroker eq 0>Driver <cfelseif request.qSystemSetupOptions1.freightBroker eq 1>Carrier <cfelseif request.qSystemSetupOptions1.freightBroker eq 2>Carrier/ Driver </cfif></span>
                                </a>
								<input name="selectedCarrier" class="selectedCarrierValue sm-input" style="width: 232px;" type="text" title="Type text here to display list." data-id="summaryCarrierTo" id="selectedCarrierValuesummaryCarrierTo"/>
								<input type="hidden" name="summaryCarrierTo" id="summaryCarrierTo">
							</div>
						</div>
						<div id="CarrierInfosummaryCarrierTo" style="display:none"></div>

						<div class="clear"></div>  
						<label class="space_it" style="width: 103px;">Customer From</label>
						<div style="position:relative;float:left;">
							<div style="float:left;">
								<select name="summaryCustomerFrom" id="summaryCustomerFrom" style="width: 100px;">
									<option value="">Select</option>
									<cfloop query="request.qCustomer">
										<cfset opt = request.qCustomer.customername>
										<cfif len(trim(request.qCustomer.location))>
											<cfset opt = opt&",ADDRESS:"&request.qCustomer.location>
										</cfif>
										<cfif len(trim(request.qCustomer.city))>
											<cfset opt = opt&",CITY:"&request.qCustomer.city>
										</cfif>
										<cfif len(trim(request.qCustomer.statecode))>
											<cfset opt = opt&",STATE:"&request.qCustomer.statecode>
										</cfif>
										<cfif len(trim(request.qCustomer.PhoneNo))>
											<cfset opt = opt&",Phone##:"&request.qCustomer.PhoneNo>
										</cfif>
										<option value="#request.qCustomer.CustomerName#">#opt#</option>
									</cfloop>
								</select>
							</div>
						</div>
						<label style="margin-left: -50px;width: 77px;">To</label> 
						<div style="position:relative;float:left;">
							<div style="float:left;">
								<select name="summaryCustomerTo" id="summaryCustomerTo" style="width: 100px;">
									<option value="">Select</option>
									<cfloop query="request.qCustomer">
										<cfset opt = request.qCustomer.customername>
										<cfif len(trim(request.qCustomer.location))>
											<cfset opt = opt&",ADDRESS:"&request.qCustomer.location>
										</cfif>
										<cfif len(trim(request.qCustomer.city))>
											<cfset opt = opt&",CITY:"&request.qCustomer.city>
										</cfif>
										<cfif len(trim(request.qCustomer.statecode))>
											<cfset opt = opt&",STATE:"&request.qCustomer.statecode>
										</cfif>
										<cfif len(trim(request.qCustomer.PhoneNo))>
											<cfset opt = opt&",Phone##:"&request.qCustomer.PhoneNo>
										</cfif>
										<option value="#request.qCustomer.CustomerName#">#opt#</option>
									</cfloop>
								</select>
							</div>
						</div>

						<div style="margin-top:30px; margin-left: 112px;">
							<input id="excelSalesSummary" type="submit" onclick="return validateexcelSalesSummary();" name="excelSalesSummary" class="bttn tooltip" value="Export" style="width:95px;"/>
						</div>
					</fieldset>
					Export limit of 10000.
				</cfform>
			</div>
			<div class="form-con">
				<cfform name="frmExcelSalesDetailExport" id="frmExcelSalesDetailExport" action="index.cfm?event=ExportExcel:salesDetail&#session.URLToken#" method="post">
					<div class="clear"></div> 
					<fieldset>
						<h2 class="reportsSubHeading">Sales Detail</h2>
						<div class="clear"></div>  
						<label class="space_it" style="width: 103px;">Order Date From</label>
						<div style="position:relative;float:left;">
							<div style="float:left;">
								<input class="sm-input datefield" style="width: 79px;" tabindex=4 name="detailDateFrom" id="detailDateFrom"  value="#dateformat(Now()-30,'mm/dd/yyy')#" validate="date" message="Please enter a valid date" type="datefield" />
							</div>
						</div>
						<label style="margin-left: -57px;width: 77px;">To</label> 
						<div style="position:relative;float:left;">
							<div style="float:left;">
								<input class="sm-input datefield" style="width: 79px;" tabindex=4 name="detailDateTo" id="detailDateTo"  value="#dateformat(Now(),'mm/dd/yyy')#" validate="date" message="Please enter a valid date" type="datefield" />
							</div>
						</div>
						<div class="clear"></div>  
						<label class="space_it" style="width: 103px;">Invoice Date From</label>
						<div style="position:relative;float:left;">
							<div style="float:left;">
								<input class="sm-input datefield" style="width: 79px;" tabindex=4 name="detailInvoiceDateFrom" id="detailInvoiceDateFrom" validate="date" type="datefield" />
							</div>
						</div>
						<label style="margin-left: -57px;width: 77px;">To</label> 
						<div style="position:relative;float:left;">
							<div style="float:left;">
								<input class="sm-input datefield" style="width: 79px;" tabindex=4 name="detailInvoiceDateTo" id="detailInvoiceDateTo" validate="date" type="datefield" />
							</div>
						</div>

						<div class="clear"></div>  
						<label class="space_it" style="width: 103px;">Pickup Date From</label>
						<div style="position:relative;float:left;">
							<div style="float:left;">
								<input class="sm-input datefield" style="width: 79px;" tabindex=4 name="detailPickupDateFrom" id="detailPickupDateFrom" validate="date" type="datefield" />
							</div>
						</div>
						<label style="margin-left: -57px;width: 77px;">To</label> 
						<div style="position:relative;float:left;">
							<div style="float:left;">
								<input class="sm-input datefield" style="width: 79px;" tabindex=4 name="detailPickupDateTo" id="detailPickupDateTo" validate="date" type="datefield" />
							</div>
						</div>
						<div class="clear"></div>  
						<label class="space_it" style="width: 103px;">Delivery Date From</label>
						<div style="position:relative;float:left;">
							<div style="float:left;">
								<input class="sm-input datefield" style="width: 79px;" tabindex=4 name="detailDeliveryDateFrom" id="detailDeliveryDateFrom" validate="date" type="datefield" />
							</div>
						</div>
						<label style="margin-left: -57px;width: 77px;">To</label> 
						<div style="position:relative;float:left;">
							<div style="float:left;">
								<input class="sm-input datefield" style="width: 79px;" tabindex=4 name="detailDeliveryDateTo" id="detailDeliveryDateTo" validate="date" type="datefield" />
							</div>
						</div>
						<div class="clear"></div>  
						<label class="space_it" style="width: 103px;">Status From</label>
						<div style="position:relative;float:left;">
							<div style="float:left;">
								<select name="detailStatusFrom" id="detailStatusFrom" style="width: 100px;">
									<cfloop query="request.qLoadStatus">
										<option value="#request.qLoadStatus.value#" <cfif loadStatusFrom EQ  request.qLoadStatus.value>selected="selected"</cfif>>#request.qLoadStatus.statusdescription#</option>
									</cfloop>
								</select>
							</div>
						</div>
						<label style="margin-left: -50px;width: 77px;">To</label> 
						<div style="position:relative;float:left;">
							<div style="float:left;">
								<select name="detailStatusTo" id="detailStatusTo" style="width: 100px;">
									<cfloop query="request.qLoadStatus">
										<option value="#request.qLoadStatus.value#" <cfif loadStatusTo EQ  request.qLoadStatus.value>selected="selected"</cfif>>#request.qLoadStatus.statusdescription#</option>
									</cfloop>
								</select>
							</div>
						</div>
						<div class="clear"></div>  
						<label class="space_it" style="width: 103px;">Office From</label>
						<div style="position:relative;float:left;">
							<div style="float:left;">
								<select name="detailOfficeFrom" id="detailOfficeFrom" style="width: 100px;" <cfif NOT (session.currentusertype EQ "administrator" OR ListContains(session.rightsList,'showAllOfficeLoads',','))>  class="disAllowEditSelectBox" </cfif>>
									<cfloop query="request.qOffices">
										<option value="#request.qOffices.officecode#">#request.qOffices.officecode#</option>
									</cfloop>
								</select>
							</div>
						</div>
						<label style="margin-left: -50px;width: 77px;">To</label> 
						<div style="position:relative;float:left;">
							<div style="float:left;">
								<select name="detailOfficeTo" id="detailOfficeTo" style="width: 100px;" <cfif NOT (session.currentusertype EQ "administrator" OR ListContains(session.rightsList,'showAllOfficeLoads',','))>  class="disAllowEditSelectBox" </cfif>>
									<cfloop query="request.qOffices">
										<option value="#request.qOffices.officecode#" <cfif request.qOffices.recordcount EQ request.qOffices.currentrow> selected </cfif>>#request.qOffices.officecode#</option>
									</cfloop>
								</select>
							</div>
						</div>
						<div class="clear"></div>  
						<label class="space_it" style="width: 103px;">PO ## From</label>
						<div style="position:relative;float:left;">
							<div style="float:left;">
								<input style="width: 95px;" class="sm-input datefield" tabindex=4 name="detailPOFrom" type="text" />
							</div>
						</div>
						<label style="margin-left: -54px;width: 72px;">To</label> 
						<div style="position:relative;float:left;">
							<div style="float:left;">
								<input style="width: 95px;" class="sm-input datefield" tabindex=4 name="detailPOTo" type="text" />
							</div>
						</div>

						<div class="clear"></div>  
						<label class="space_it" style="width: 103px;"><cfif request.qSystemSetupOptions1.freightBroker eq 0>Driver <cfelseif request.qSystemSetupOptions1.freightBroker eq 1>Carrier <cfelseif request.qSystemSetupOptions1.freightBroker eq 2>Carrier/ Driver </cfif> From</label>
						<div style="position:relative;float:left;">
							<div style="float:left;">
								<a href="javascript:void(0);" onclick="chooseCarrier('detailCarrierFrom');" id="removedetailCarrierFrom" style="color:##236334;display: none">
                                    <img style="vertical-align:bottom;" src="images/change.png">
                                    <span class="removetxt">Remove <cfif request.qSystemSetupOptions1.freightBroker eq 0>Driver <cfelseif request.qSystemSetupOptions1.freightBroker eq 1>Carrier <cfelseif request.qSystemSetupOptions1.freightBroker eq 2>Carrier/ Driver </cfif></span>
                                </a>
								<input name="selectedCarrier" class="selectedCarrierValue sm-input" style="width: 232px;" type="text" title="Type text here to display list." data-id="detailCarrierFrom" id="selectedCarrierValuedetailCarrierFrom"/>
								<input type="hidden" name="detailCarrierFrom" id="detailCarrierFrom">
							</div>
						</div>
						<div id="CarrierInfodetailCarrierFrom" style="display:none;"></div>
						<div class="clear"></div> 
						<label class="space_it" style="width: 103px;"><cfif request.qSystemSetupOptions1.freightBroker eq 0>Driver <cfelseif request.qSystemSetupOptions1.freightBroker eq 1>Carrier <cfelseif request.qSystemSetupOptions1.freightBroker eq 2>Carrier/ Driver </cfif> To</label>
						<div style="position:relative;float:left;">
							<div style="float:left;">
								<a href="javascript:void(0);" onclick="chooseCarrier('detailCarrierTo');" id="removedetailCarrierTo" style="color:##236334;display: none">
                                    <img style="vertical-align:bottom;" src="images/change.png">
                                    <span class="removetxt">Remove <cfif request.qSystemSetupOptions1.freightBroker eq 0>Driver <cfelseif request.qSystemSetupOptions1.freightBroker eq 1>Carrier <cfelseif request.qSystemSetupOptions1.freightBroker eq 2>Carrier/ Driver </cfif></span>
                                </a>
								<input name="selectedCarrier" class="selectedCarrierValue sm-input" style="width: 232px;" type="text" title="Type text here to display list." data-id="detailCarrierTo" id="selectedCarrierValuedetailCarrierTo"/>
								<input type="hidden" name="detailCarrierTo" id="detailCarrierTo">
							</div>
						</div>
						<div id="CarrierInfodetailCarrierTo" style="display:none;"></div>
						
						<div class="clear"></div>  
						<label class="space_it" style="width: 103px;">Customer From</label>
						<div style="position:relative;float:left;">
							<div style="float:left;">
								<select name="detailCustomerFrom" id="detailCustomerFrom" style="width: 100px;">
									<option value="">Select</option>
									<cfloop query="request.qCustomer">
										<cfset opt = request.qCustomer.customername>
										<cfif len(trim(request.qCustomer.location))>
											<cfset opt = opt&",ADDRESS:"&request.qCustomer.location>
										</cfif>
										<cfif len(trim(request.qCustomer.city))>
											<cfset opt = opt&",CITY:"&request.qCustomer.city>
										</cfif>
										<cfif len(trim(request.qCustomer.statecode))>
											<cfset opt = opt&",STATE:"&request.qCustomer.statecode>
										</cfif>
										<cfif len(trim(request.qCustomer.PhoneNo))>
											<cfset opt = opt&",Phone##:"&request.qCustomer.PhoneNo>
										</cfif>
										<option value="#request.qCustomer.CustomerName#">#opt#</option>
									</cfloop>
								</select>
							</div>
						</div>
						<label style="margin-left: -50px;width: 77px;">To</label> 
						<div style="position:relative;float:left;">
							<div style="float:left;">
								<select name="detailCustomerTo" id="detailCustomerTo" style="width: 100px;">
									<option value="">Select</option>
									<cfloop query="request.qCustomer">
										<cfset opt = request.qCustomer.customername>
										<cfif len(trim(request.qCustomer.location))>
											<cfset opt = opt&",ADDRESS:"&request.qCustomer.location>
										</cfif>
										<cfif len(trim(request.qCustomer.city))>
											<cfset opt = opt&",CITY:"&request.qCustomer.city>
										</cfif>
										<cfif len(trim(request.qCustomer.statecode))>
											<cfset opt = opt&",STATE:"&request.qCustomer.statecode>
										</cfif>
										<cfif len(trim(request.qCustomer.PhoneNo))>
											<cfset opt = opt&",Phone##:"&request.qCustomer.PhoneNo>
										</cfif>
										<option value="#request.qCustomer.CustomerName#">#opt#</option>
									</cfloop>
								</select>
							</div>
						</div>
						<div style="margin-top:30px; margin-left: 112px;">
							<input id="excelSalesDetails" type="submit" name="excelSalesDetails"  onclick="return validateexcelDetail();" class="bttn tooltip" value="Export" style="width:95px;"/>
						</div>
					</fieldset>
				</cfform>
			</div>
			<div class="clear"></div>
		</div>
		<div class="white-bot"></div>
	</div>

	<script type="text/javascript">
		
		$("##frmExcelSalesSummaryExport").submit(function(e) {

			//e.preventDefault(); // avoid to execute the actual submit of the form.
	
			var form = $(this);
			
			var path = urlComponentPath+"security/securitygateway.cfc?method=checkExportSalesSummaryExcelCount";

			$.ajax({
				   type: "POST",
				   url: path,
				   data: form.serialize(), // serializes the form's elements.
				   success: function(rowCount)
				   {
					   if(rowCount > 10000){
						alert('Please note the export process has a limit of 10,000 records. You have reached the limit, please narrow your criteria to avoid reaching the limit.');
					   }
					  
				   }
				 });
		});

		function checkDateLimit(DateFrom,DateTo){
			var From_date = new Date($("##"+DateFrom).val());
			var To_date = new Date($("##"+DateTo).val());
			var diff_date =  To_date - From_date;
			var years = Math.floor(diff_date/31536000000);
			if(years == 0){
				return true;
			}
			else{
				alert("You can only export up to 1 year of data at a time.")
				return false;
			}
			
		}
        function validateexcelSalesSummary(){

        	 if($('##summaryDateFrom').val().length){
          	var flag = checkDateForm('summaryDateFrom');
          	if(!flag){
             return false;
          	}
           }
            if($('##summaryDateTo').val().length){
          	var flag = checkDateForm('summaryDateTo');
          	if(!flag){
             return false;
          	}
           }

           if($('##summaryDateFrom').val().length && $('##summaryDateTo').val().length){
           	var flag = checkDateLimit('summaryDateFrom','summaryDateTo');
           	if(!flag){
             return false;
          	}
           }

            if($('##summaryInvoiceDateFrom').val().length){
          	var flag = checkDateForm('summaryInvoiceDateFrom');
          	if(!flag){
             return false;
          	}
           }
            if($('##summaryInvoiceDateTo').val().length){
          	var flag = checkDateForm('summaryInvoiceDateTo');
          	if(!flag){
             return false;
          	}
           }

           if($('##summaryInvoiceDateFrom').val().length && $('##summaryInvoiceDateTo').val().length){
           	var flag = checkDateLimit('summaryInvoiceDateFrom','summaryInvoiceDateTo');
           	if(!flag){
             return false;
          	}
           }

            if($('##summaryPickupDateFrom').val().length){
          	var flag = checkDateForm('summaryPickupDateFrom');
          	if(!flag){
             return false;
          	}
           }
            if($('##summaryPickupDateTo').val().length){
          	var flag = checkDateForm('summaryPickupDateTo');
          	if(!flag){
             return false;
          	}
           }

           if($('##summaryPickupDateFrom').val().length && $('##summaryPickupDateTo').val().length){
           	var flag = checkDateLimit('summaryPickupDateFrom','summaryPickupDateTo');
           	if(!flag){
             return false;
          	}
           }


           return true; 

        }
		function validateexcelCommission(){
			if($('##commissionInvoiceDateFrom').val().length){
	          	var flag = checkDateForm('commissionInvoiceDateFrom');
	          	if(!flag){
	             return false;
	          	}
	           }
	         if($('##commissionInvoiceDateTo').val().length){
	          	var flag = checkDateForm('commissionInvoiceDateTo');
	          	if(!flag){
	          return false;
	          	}
	          }

	          if($('##commissionInvoiceDateFrom').val().length && $('##commissionInvoiceDateTo').val().length){
	           	var flag = checkDateLimit('commissionInvoiceDateFrom','commissionInvoiceDateTo');
	           	if(!flag){
	             return false;
	          	}
	           }
		}

		function validateexcelDetail(){
         
          if($('##detailDateFrom').val().length){
          	var flag = checkDateForm('detailDateFrom');
          	if(!flag){
             return false;
          	}
           }
         if($('##detailDateTo').val().length){
          	var flag = checkDateForm('detailDateTo');
          	if(!flag){
          return false;
          	}
          }

          if($('##detailDateFrom').val().length && $('##detailDateTo').val().length){
           	var flag = checkDateLimit('detailDateFrom','detailDateTo');
           	if(!flag){
             return false;
          	}
           }

          if($('##detailInvoiceDateFrom').val().length){
          	var flag = checkDateForm('detailInvoiceDateFrom');
          	if(!flag){
          return false;
          	}
          }
          if($('##detailInvoiceDateTo').val().length){
          	var flag = checkDateForm('detailInvoiceDateTo');
          	if(!flag){
          return false;
          	}
          }

          if($('##detailInvoiceDateFrom').val().length && $('##detailInvoiceDateTo').val().length){
           	var flag = checkDateLimit('detailInvoiceDateFrom','detailInvoiceDateTo');
           	if(!flag){
             return false;
          	}
           }

           if($('##detailPickupDateFrom').val().length){
          	var flag = checkDateForm('detailPickupDateFrom');
          	if(!flag){
          return false;
          	}
          }
            if($('##detailPickupDateTo').val().length){
          	var flag = checkDateForm('detailPickupDateTo');
          	if(!flag){
          return false;
          	}
          }

          if($('##detailPickupDateFrom').val().length && $('##detailPickupDateTo').val().length){
           	var flag = checkDateLimit('detailPickupDateFrom','detailPickupDateTo');
           	if(!flag){
             return false;
          	}
           }
          return true; 
          		}
	function checkDateForm(data) {
   
	var reg =/((^(10|12|0?[13578])([/])(3[01]|[12][0-9]|0?[1-9])([/])((1[8-9]\d{2})|([2-9]\d{3}))$)|(^(11|0?[469])([/])(30|[12][0-9]|0?[1-9])([/])((1[8-9]\d{2})|([2-9]\d{3}))$)|(^(0?2)([/])(2[0-8]|1[0-9]|0?[1-9])([/])((1[8-9]\d{2})|([2-9]\d{3}))$)|(^(0?2)([/])(29)([/])([2468][048]00)$)|(^(0?2)([/])(29)([/])([3579][26]00)$)|(^(0?2)([/])(29)([/])([1][89][0][48])$)|(^(0?2)([/])(29)([/])([2-9][0-9][0][48])$)|(^(0?2)([/])(29)([/])([1][89][2468][048])$)|(^(0?2)([/])(29)([/])([2-9][0-9][2468][048])$)|(^(0?2)([/])(29)([/])([1][89][13579][26])$)|(^(0?2)([/])(29)([/])([2-9][0-9][13579][26])$))/;
	var textValue=$("##"+data).val();
		if(!textValue.match(reg)){
			alert('Please enter a valid date');
			$("##"+data).focus();
			$("##"+data).val('');
			return false;
		}else{
			return true;
		}
		
}
		$(document).ready(function(){
			$( "[type='datefield']" ).datepicker({
			  dateFormat: "mm/dd/yy",
			  showOn: "button",
			  buttonImage: "images/DateChooser.png",
			  buttonImageOnly: true
			});


			$('.selectedCarrierValue').each(function(i, tag) {
				$(tag).autocomplete({
					multiple: false,
					width: 450,
					scroll: true,
					scrollHeight: 300,
					cacheLength: 1,
					highlight: false,
					dataType: "json",
					search: function(event, ui){
						$(this).autocomplete('option', 'source', 'searchCarrierAutoFill.cfm?queryType=getCustomers&companyid=#session.companyid#&loadid=&pickupdate=&deliverydate=')
					},
					select: function(e, ui) {
						var id = $(this).data("id");
						$('##'+id).val(ui.item.name);
						var strHtml = "<div class='clear'></div>"
						strHtml = strHtml + "<label>&nbsp;</label><label class='field-textarea'>"
						strHtml = strHtml + "<b>"
						strHtml = strHtml + ui.item.name
						strHtml = strHtml + "</a>"
						strHtml = strHtml + "</b>"
						strHtml = strHtml + "<br/>"
						strHtml = strHtml + ""+ui.item.name+"<br/>"+ui.item.city+"<br/>"+ui.item.state+"&nbsp;-&nbsp;"+ui.item.zip+""
						strHtml = strHtml + "</label>"
						strHtml = strHtml + "<div class='clear'></div>"
						strHtml = strHtml + "<label>Tel</label>"
						strHtml = strHtml + "<label class='cellnum-text'>"+ui.item.phoneNo+"</label>"
						strHtml = strHtml + "<label class='space_load'>Cell</label>"
						strHtml = strHtml + "<label class='cellnum-text'>"+ui.item.cell+"</label>"
						strHtml = strHtml + "<div class='clear'></div>"
						strHtml = strHtml + "<label>Fax</label>"
						strHtml = strHtml + "<label class='field-text' style='width:260px'>"+ui.item.fax+"</label>"
						strHtml = strHtml + "<div class='clear'></div>"
						strHtml = strHtml + "<label>Email</label>"
						strHtml = strHtml + "<label class='emailbox' style='width:260px'>"+ui.item.email+"</label>";
						strHtml = strHtml + "<div class='clear'></div>"
						document.getElementById("CarrierInfo"+id).style.display = 'block';
						$('##CarrierInfo'+id).html(strHtml);
						$(this).hide();
						$('##remove'+id).show();
					}
				});
				$(tag).data("ui-autocomplete")._renderItem = function(ul, item) {
					return $( "<li>"+item.name+"&nbsp;&nbsp;&nbsp;<b><u>Status</u>:</b> "+ item.status+"&nbsp;&nbsp;&nbsp;<br/><b><u>City</u>:</b> "+ item.city+"&nbsp;&nbsp;&nbsp;<b><u>State</u>:</b>" + item.state+"&nbsp;&nbsp;&nbsp;<b><u>Zip</u>:</b> " + item.zip+"&nbsp;&nbsp;&nbsp;<b><u>Insurance Expiry</u>:</b> " + item.InsExpDate+"</li>" ).appendTo( ul );
				}
			})	
		});	

	function chooseCarrier(id){
		$('##selectedCarrierValue'+id).val('');
		$('##selectedCarrierValue'+id).show();
		$('##'+id).val('');
		$('##CarrierInfo'+id).html('');
		$('##CarrierInfo'+id).hide();
		$('##remove'+id).hide();
	}
	</script>
</cfoutput>