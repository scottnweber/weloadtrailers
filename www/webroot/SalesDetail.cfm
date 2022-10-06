<cfif not structKeyExists(Cookie, "ReportIncludeAllDispatchers")>
	<cfcookie name="ReportIncludeAllDispatchers" value="false" expires="never">
</cfif>
<cfif not structKeyExists(Cookie, "ReportIncludeAllSalesRep")>
	<cfcookie name="ReportIncludeAllSalesRep" value="false" expires="never">
</cfif>
<cfoutput>
	<cfinvoke component="#variables.objloadGateway#" method="getLoadStatus" returnvariable="request.qLoadStatus" />
	<cfinvoke component="#variables.objloadGateway#" AuthLevelId="Sales Representative,Dispatcher" method="getSalesPerson" returnvariable="request.qSalesPerson" />
	<cfinvoke component="#variables.objloadGateway#" AuthLevelId="Dispatcher" method="getSalesPerson" returnvariable="request.qDispatcher" />
	<cfinvoke component="#variables.objCutomerGateway#" method="getAllpayerCustomers" returnvariable="request.qryCustomersList" />
	<cfinvoke component="#variables.objequipmentGateway#" method="getloadEquipments" returnvariable="request.qEquipments" />
	<cfif session.currentusertype EQ "administrator" OR ListContains(session.rightsList,'showAllOfficeLoads',',')>
		<cfinvoke component="#variables.objofficeGateway#" method="getAllOffices" sortby="officecode" sortorder="asc"  returnvariable="request.qOffices" />
	<cfelse>
		<cfinvoke component="#variables.objofficeGateway#" method="getAllOffices" sortby="officecode" sortorder="asc" officeID="#session.officeID#" returnvariable="request.qOffices" />
	</cfif>
	<cfinvoke component="#variables.objagentGateway#" method="getBillFromCompanies" incCompany=1 returnvariable="request.qBillFromCompanies" />
	<cfif request.qsystemsetupoptions1.freightBroker EQ 1>
		<cfset variables.freightBroker = "Carrier">
		<cfinvoke component="#variables.objCarrierGateway#" method="getAllCarriersForReport" IsCarrier="1" returnvariable="request.qCarrier"></cfinvoke>
	<cfelseif request.qsystemsetupoptions1.freightBroker EQ 2>
		<cfset variables.freightBroker = "Carrier/Driver">
		<cfinvoke component="#variables.objCarrierGateway#" method="getAllCarriersForReport" returnvariable="request.qCarrier"></cfinvoke>
	<cfelse>
		<cfset variables.freightBroker = "Driver">
		<cfinvoke component="#variables.objCarrierGateway#" method="getAllCarriersForReport" IsCarrier="0" returnvariable="request.qCarrier"></cfinvoke>
	</cfif>
	<style type="text/css">
		.reportsSubHeading{
			border-bottom: 1px solid ##77463d !important;
			margin-bottom: 5px !important;
		}
		.hidecheckBoxSplitAmt{
			display: none;
		}
		.disAllowEditSelectBox {
			background: none repeat scroll 0 0 ##e3e3e3 !important;
			border: 1px solid ##c5c1c1 !important;
			color: ##434343 !important;
			pointer-events: none;
		}
		.hideAllDispatcher,.hideAllSalesRep{
			display: none;
		}
	</style>
	<script type="text/javascript">
		$(document).ready(function(){
			$( "[type='datefield']" ).datepicker({
			  	dateFormat: "mm/dd/yy",
			  	showOn: "button",
			  	buttonImage: "images/DateChooser.png",
			  	buttonImageOnly: true,
			   	showButtonPanel: true
			});
			$( ".datefield" ).datepicker( "option", "showButtonPanel", true );
            var old_goToToday = $.datepicker._gotoToday
            $.datepicker._gotoToday = function(id) {
                old_goToToday.call(this,id)
                this._selectDate(id)
            }
		})

		function validateForm(){
			if(checkdate()){
				return true;
			}
			return false;
		}

		function checkdate(){
			var reg =/((^(10|12|0?[13578])([/])(3[01]|[12][0-9]|0?[1-9])([/])((1[8-9]\d{2})|([2-9]\d{3}))$)|(^(11|0?[469])([/])(30|[12][0-9]|0?[1-9])([/])((1[8-9]\d{2})|([2-9]\d{3}))$)|(^(0?2)([/])(2[0-8]|1[0-9]|0?[1-9])([/])((1[8-9]\d{2})|([2-9]\d{3}))$)|(^(0?2)([/])(29)([/])([2468][048]00)$)|(^(0?2)([/])(29)([/])([3579][26]00)$)|(^(0?2)([/])(29)([/])([1][89][0][48])$)|(^(0?2)([/])(29)([/])([2-9][0-9][0][48])$)|(^(0?2)([/])(29)([/])([1][89][2468][048])$)|(^(0?2)([/])(29)([/])([2-9][0-9][2468][048])$)|(^(0?2)([/])(29)([/])([1][89][13579][26])$)|(^(0?2)([/])(29)([/])([2-9][0-9][13579][26])$))/;
			    
			if($('##dateFrom').val().length < 1){
			    alert('please enter a date');
			    $('##dateFrom').focus();
			    return false;
			}
	    	if($('##dateFrom').val().length){
	    		if(!$('##dateFrom').val().match(reg)){
	    			alert('Please enter a valid date');
	    			 $('##dateFrom').focus();
	    			$('##dateFrom').val('');
	    			return false;
	    		}
	    	}	
	    	if($('##dateTo').val().length < 1){
	    	alert('please enter a date');
	    	 $('##dateTo').focus();
	    	 return false;
	    	}
	    	if($('##dateTo').val().length){
	    		if(!$('##dateTo').val().match(reg)){
	    			alert('Please enter a valid date');
	    			 $('##dateTo').focus();
	    			$('##dateTo').val('');
	    			return false;
	    		}
	    	}	
            return true;
		}
	</script>
	<div class="white-con-area" style="height: 36px;background-color: ##82bbef;">
		<div style="float: left;"><h2 style="color:white;font-weight:bold;margin-left: 12px;">Sales & Commission Detail Report</h2></div>
	</div>
	<div style="clear:left"></div>
	<div class="white-con-area">
	    <div class="white-mid">
	    	<form name="frmSalesReport" action="index.cfm?event=SalesDetailReport&#session.URLToken#" method="post" onsubmit="return validateForm()">
	    		<input type="hidden" name="CompanyName" value="#request.qsystemsetupoptions1.CompanyName#">
	    		<input type="hidden" name="CompanyLogoName" value="#request.qsystemsetupoptions1.CompanyLogoName#">
				<input type="hidden" name="freightBroker" value="#variables.freightBroker#">
				<input type="hidden" name="urlToken" id="urlToken" value="#session.urlToken#">
	    		<div class="form-con" style="margin-bottom: 20px;">
	    			<fieldset>
	    				<h2 class="reportsSubHeading">Group By&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Sort By</h2>
	    				<div class="clear"></div>
	            		<div style="width:10px; float:left;">&nbsp;</div>
	            		<div style="float: left;">
		           			<div style="float:left;">
				                <input type="radio" name="groupBy" value="none" id="none" checked="yes" style="width:15px; padding:0px 0px 0 0px;margin-bottom:1px;"  onclick="hideCustomerCheckBox();hidecheckBoxGroup();"/>
				                <label class="normal" for="salesAgent" style="text-align:left; padding:0 0 0 0;width: 90px;">None</label>
				                <input type="radio" name="sortby" value="loadno" id="loadno" style="width:15px; padding:0px 0px 0 0px;margin-bottom:1px;" checked/>
				                <label class="normal" for="loadno" style="text-align:left; padding:0 0 0 0;width: 50px;">Load##</label>
				            </div>
		    				<div class="clear"></div>
		        			<div style="float:left;">
				            	<cfif request.qsystemsetupoptions1.freightBroker>	
				                	<input type="radio" name="groupBy" value="salesAgent" id="salesAgent" style="width:15px; padding:0px 0px 0 0px;margin-bottom:1px;" onclick="hideCustomerCheckBox();showcheckBoxGroup();shwIncSalesrep();"/>
				                <cfelse>
				                	<cfif len(trim(request.qsystemsetupoptions1.userDef7))>	
				                		<input type="radio" name="groupBy" value="#request.qsystemsetupoptions1.userDef7#" id="salesAgent" style="width:15px; padding:0px 0px 0 0px;margin-bottom:1px;" onclick="hideCustomerCheckBox();showcheckBoxGroup();shwIncSalesrep();"/>	
				                	<cfelse>
				                		<input type="radio" name="groupBy" value="salesAgent" id="salesAgent" style="width:15px; padding:0px 0px 0 0px;margin-bottom:1px;" onclick="hideCustomerCheckBox();showcheckBoxGroup();shwIncSalesrep();"/>
				                	</cfif>
				                </cfif>
		                		<label class="normal" for="salesAgent" style="text-align:left; padding:0 0 0 0;width: 90px;" >
					                <cfif request.qsystemsetupoptions1.freightBroker>	
					                	Sales Agent
					                <cfelse>
					                	<cfif len(trim(request.qsystemsetupoptions1.userDef7))>
					                			#request.qsystemsetupoptions1.userDef7#
					                	<cfelse>
					                		Sales Agent	
					                	</cfif>
					                </cfif>	
		                		</label>
		                		<input type="radio" name="sortby" value="date" id="date" style="width:15px; padding:0px 0px 0 0px;margin-bottom:1px;"/>
				                <label class="normal" for="date" style="text-align:left; padding:0 0 0 0;width: 50px;">Date</label>
		            		</div>
		            		<div class="clear"></div>
		            		<div style="float:left;">
		                		<input type="radio" name="groupBy" value="dispatcher" id="dispatcher"  style="width:15px; padding:0px 0px 0 0px;margin-bottom:1px;" onclick="hideCustomerCheckBox();showcheckBoxGroup();showDispSplitAmt();shwIncDispatcher();"/>
		                		<label class="normal" for="dispatcher" style="text-align:left; padding:0 0 0 0;" >Dispatcher</label>
		            		</div>			
							<div class="clear"></div>
		            		<div style="float:left;">
				                <input type="radio" name="groupBy" value="customer" id="customer"  style="width:15px; padding:0px 0px 0 0px;margin-bottom:1px;" onclick="hideCustomerCheckBox();showcheckBoxGroup()"/>
				                <label class="normal" for="customer" style="text-align:left; padding:0 0 0 0;" >Customer</label>
				            </div>			
					 		<div class="clear"></div>
				            <div style="float:left;">
				                <input type="radio" name="groupBy" value="carrier" id="carrier" style="width:15px; padding:0px 0px 0 0px;margin-bottom:1px;" onclick="showCustomerCheckBox();showcheckBoxGroup()"/>
				                <label class="normal" for="carrier" style="text-align:left; padding:0 0 0 0;">#variables.freightBroker#</label>
				            </div>    
				            <div class="clear"></div>
			        	</div>
			            <div style="float: left;">
			            	<div style="float:left;">
				                <input type="checkbox" name="ExZeroItems" value="1" id="ExZeroItems" style="width: 16px;" onclick="ckExZeroItems()"/>
				                <label class="normal" for="ExZeroItems" style="width:155px;text-align:left;">Exclude $0.00 items</label>
				            </div> 
				            <div class="clear"></div>
				            <div style="float:left;display: none;" class="zeroWeightGrp">
				                <input type="checkbox" name="ExZeroWeight" value="1" id="ExZeroWeight" style="width: 16px;"/>
				                <label class="normal" for="ExZeroWeight" style="width:175px;text-align:left;">Also Exclude 0 weight commodities</label>
				            </div> 
				            <div class="clear"></div>
				            <div style="float:left;" class="hidecheckBoxGroup">
				                <input type="checkbox" name="pagebreak" value="" id="customerCheckGroup" checked style="width: 16px;"/>
				                 <label class="normal" for="customerCheckGroup" style="width:155px;text-align:left;">Page Break After Each Group?</label>
				            </div> 
		    				<div class="clear"></div> 
		    				<div style="float:left;" class="hideAllDispatcher">
				                <input type="checkbox" name="incAllDispatchers" value="" id="incAllDispatchers" style="width: 16px;" onclick="updateReportCookies('ReportIncludeAllDispatchers',this);showDispSplitAmt()" <cfif cookie.ReportIncludeAllDispatchers EQ 1> checked </cfif>/>
				                <label class="normal" for="incAllDispatchers" style="width:120px;text-align:left;">Include Dispatcher 2 & 3</label>
				            </div> 
				            <div class="clear"></div> 
		    				<div style="float:left;" class="hideAllSalesRep">
				                <input type="checkbox" name="incAllSalesRep" value="" id="incAllSalesRep" style="width: 16px;" onclick="updateReportCookies('ReportIncludeAllSalesRep',this);" <cfif cookie.ReportIncludeAllSalesRep EQ 1> checked </cfif>/>
				                <label class="normal" for="incAllSalesRep" style="width:120px;text-align:left;">Include Sales Rep 2 & 3</label>
				            </div> 
		    				<div class="clear"></div> 
		    				<div style="float:left;" class="hidecheckBox">
				                <input type="checkbox" name="customerCheck" value="" id="customerCheck" checked style="width: 16px;"/>
				                 <label class="normal" for="customerCheck" style="width:100px;text-align:left;">Show Customer Info</label>
				            </div>  

				            <div class="clear"></div> 
		    				<div style="float:left;" class="hidecheckBoxSplitAmt">
				                <input type="checkbox" name="dispatcherSplitAmt" value="" id="dispatcherSplitAmt" style="width: 16px;"/>
				                <label class="normal" for="customerCheck" style="width:100px;text-align:left;">Split Margin for Commission Amt</label>
				            </div>

						</div>
	    				<div class="clear"></div>  
			            <div style="margin-top:30px;">
				            <input type="radio" name="datetype" value="Pickup" id="Pickup"  style="width:15px; padding:0px 0px 0 0px;" checked="true"/>
				            <label for="Pickup" class="normal" style="width:50px;"><h2 style="float:left;padding: 0;">Pickup</h2></label>
				            <input type="radio" name="datetype" value="Delivery" id="Delivery"  style="width:15px; padding:0px 0px 0 0px;"/>
				            <label for="Delivery" class="normal" style="width:70px;"><h2 style="float:left;padding: 0;">Delivery</h2></label>
				            <input type="radio" name="datetype" value="Invoice" id="Invoice"  style="width:15px; padding:0px 0px 0 0px;"/>
				            <label for="Invoice" class="normal" style="width:60px;"><h2 style="float:left;padding: 0;">Invoice</h2></label>
				            <input type="radio" name="datetype" value="Create" id="Create"  style="width:15px; padding:0px 0px 0 0px;"/>
				            <label for="Create" class="normal" style="width:60px;"><h2 style="float:left;padding: 0;">Create</h2></label>
				            <div class="clear reportsSubHeading" ></div>  
			            </div>
                        <label class="space_it">From</label>
                        <div style="position:relative;float:left;">
                            <div style="float:left;">
                                <input class="sm-input datefield" name="dateFrom" id="dateFrom"  value="#dateformat(Now()-30,'mm/dd/yyy')#" type="datefield" />
                            </div>
                        </div>
			        	<label style="margin-left: -54px;">To</label>
                        <div style="position:relative;float:left;">
                            <div style="float:left;">
                                <input class="sm-input datefield" name="dateTo" id="dateTo"  value="#dateformat(Now(),'mm/dd/yyy')#" type="datefield" />
                            </div>
                        </div>
                        <div width="100%" style="margin-top: 30px;">
							<div style="float:left;margin-top:15px;width:50%;">
								<h2 class="reportsSubHeading">Commission</h2>
								<label>Commission %</label>
								<input class="sm-input" name="commissionPercent" id="commissionPercent" value="#NumberFormat(0,'0.00')#"/>
								<div class="clear"></div>
							</div>
							<div  style="float:left;margin-top:15px;width:50%;">
								<h2 style="text-align:center;" class="reportsSubHeading">Margin Range</h2>
								<label>From </label>
								<input class="sm-input" name="marginFrom" id="marginFrom" value="#DollarFormat(0)#"/>
								<div class="clear"></div>
								<label>To </label>
								<input class="sm-input" name="marginTo" id="marginTo" value="#DollarFormat(0)#" />
								<div class="clear"></div>
							</div>
						</div>
						<div class="clear"></div>
						<div style="margin-top: 30px;">
							<h2 style="margin-top:14px;" class="reportsSubHeading">Load Status</h2>
				            <label>Status From</label>			
				   			<select name="statusFrom" id="statusFrom">
								<cfloop query="request.qLoadStatus">
									<option value="#request.qLoadStatus.Text#" <cfif (request.qsystemsetupoptions1.IsLoadStatusDefaultForReport EQ 1 AND request.qsystemsetupoptions1.ARAndAPExportStatusID EQ request.qLoadStatus.value) OR (request.qsystemsetupoptions1.IsLoadStatusDefaultForReport EQ 0 AND request.qLoadStatus.Text EQ '1. ACTIVE')>selected</cfif>>#request.qLoadStatus.statusdescription#</option>
								</cfloop>
							</select>
				
							<label>Status To</label>			 
				   			<select name="statusTo" id="statusTo">
								<cfloop query="request.qLoadStatus">
									<option value="#request.qLoadStatus.Text#" <cfif (request.qsystemsetupoptions1.IsLoadStatusDefaultForReport EQ 1 AND request.qsystemsetupoptions1.ARAndAPExportStatusID EQ request.qLoadStatus.value) OR (request.qsystemsetupoptions1.IsLoadStatusDefaultForReport EQ 0 AND request.qLoadStatus.Text EQ '8. COMPLETED')>selected</cfif>>#request.qLoadStatus.statusdescription#</option>
								</cfloop>
							</select>
						</div>
						<div class="clear"></div>
						<div style="margin-top: 30px;">
							<h2 style="margin-top:14px;" class="reportsSubHeading">Office</h2>
							<label>From </label>
							<select name="officeFrom" id="officeFrom" <cfif NOT (session.currentusertype EQ "administrator" OR ListContains(session.rightsList,'showAllOfficeLoads',','))> class="disAllowEditSelectBox" </cfif>>
								<cfif session.currentusertype EQ "administrator" OR ListContains(session.rightsList,'showAllOfficeLoads',',')>
									<option value="">Select</option>
								</cfif>
								<cfloop query="request.qOffices">
								<option value="#request.qOffices.officecode#">#request.qOffices.officecode#</option>
								</cfloop>
							</select>
							<div class="clear"></div>
							<label>To </label>
							<select name="officeTo" id="officeTo" <cfif NOT (session.currentusertype EQ "administrator" OR ListContains(session.rightsList,'showAllOfficeLoads',','))> class="disAllowEditSelectBox" </cfif>>
								<cfif session.currentusertype EQ "administrator" OR ListContains(session.rightsList,'showAllOfficeLoads',',')>
									<option value="">Select</option>
								</cfif>
								<cfloop query="request.qOffices">
								<option value="#request.qOffices.officecode#">#request.qOffices.officecode#</option>
								</cfloop>
							</select>
						</div>
						<div class="clear"></div>
						<div style="margin-top: 30px;">
							<h2 style="margin-top:14px;" class="reportsSubHeading">Bill From</h2>
							<label>From </label>
							<select name="billFrom" id="billFrom">
								<option value="">Select</option>
								<cfloop query="request.qBillFromCompanies">
								<option value="#request.qBillFromCompanies.CompanyName#">#request.qBillFromCompanies.CompanyName#</option>
								</cfloop>
							</select>
							<div class="clear"></div>
							<label>To </label>
							<select name="billTo" id="billTo">
								<option value="">Select</option>
								<cfloop query="request.qBillFromCompanies">
								<option value="#request.qBillFromCompanies.CompanyName#">#request.qBillFromCompanies.CompanyName#</option>
								</cfloop>
							</select>
						</div>
						<div class="clear"></div>
	    			</fieldset>
	    		</div>
	    		<div class="form-con">
					<fieldset>	
		        		<h2 class="reportsSubHeading" style="margin-left: 50px;">
				 			<cfif request.qsystemsetupoptions1.freightBroker>	
				            	Sales Rep
				            <cfelse>
				            	<cfif len(trim(request.qsystemsetupoptions1.userDef7))>
				            			#request.qsystemsetupoptions1.userDef7#
				            	<cfelse>
				            		Sales Rep	
				            	</cfif>
				            </cfif>	
	        			</h2>
	        			<div style="float:right; margin-right:40px;">
				            <label>From </label>
				            <cfif request.qsystemsetupoptions1.freightBroker>
				            	 <select name="salesRepFrom" id="salesRepFrom">
				            	 	<cfif (structKeyExists(session, "currentusertype") AND session.currentusertype eq 'Sales Representative') OR ListContains(session.rightsList,'SalesRepReport',',')>
				            	 		<cfloop query="request.qSalesPerson">
				            	 			<cfif request.qSalesPerson.EmployeeID EQ session.empid>
				            	 				<cfset opt = request.qSalesPerson.Name>
												<cfif len(trim(request.qSalesPerson.address))>
													<cfset opt = opt&",ADDRESS:"&request.qSalesPerson.address>
												</cfif>
												<cfif len(trim(request.qSalesPerson.city))>
													<cfset opt = opt&",CITY:"&request.qSalesPerson.city>
												</cfif>
												<cfif len(trim(request.qSalesPerson.state))>
													<cfset opt = opt&",STATE:"&request.qSalesPerson.state>
												</cfif>
												<cfif len(trim(request.qSalesPerson.telephone))>
													<cfset opt = opt&",Phone##:"&request.qSalesPerson.telephone>
												</cfif>
												<option value="#request.qSalesPerson.Name#">#opt#</option>
											</cfif>
										</cfloop>
				            	 	<cfelse>
				            	 		<option value="">Select</option>
						                <cfloop query="request.qSalesPerson">
					                		<cfset opt = request.qSalesPerson.Name>
											<cfif len(trim(request.qSalesPerson.address))>
												<cfset opt = opt&",ADDRESS:"&request.qSalesPerson.address>
											</cfif>
											<cfif len(trim(request.qSalesPerson.city))>
												<cfset opt = opt&",CITY:"&request.qSalesPerson.city>
											</cfif>
											<cfif len(trim(request.qSalesPerson.state))>
												<cfset opt = opt&",STATE:"&request.qSalesPerson.state>
											</cfif>
											<cfif len(trim(request.qSalesPerson.telephone))>
												<cfset opt = opt&",Phone##:"&request.qSalesPerson.telephone>
											</cfif>
											<option value="#request.qSalesPerson.Name#" srname="#request.qSalesPerson.Name#">#opt#</option>
										</cfloop>
				            	 	</cfif>
					            </select> 	
				          	<cfelse>	  	
						       <input type="text" name="salesRepFrom" id="salesRepFrom" value="">
					        </cfif>    
				            <div class="clear"></div>
				            <label>To </label>
				             
				            <cfif request.qsystemsetupoptions1.freightBroker>
								<select id="salesRepTo" name="salesRepTo">
									<cfif (structKeyExists(session, "currentusertype") AND session.currentusertype eq 'Sales Representative') OR ListContains(session.rightsList,'SalesRepReport',',')>
				            	 		<cfloop query="request.qSalesPerson">
				            	 			<cfif request.qSalesPerson.EmployeeID EQ session.empid>
												<cfset opt = request.qSalesPerson.Name>
												<cfif len(trim(request.qSalesPerson.address))>
													<cfset opt = opt&",ADDRESS:"&request.qSalesPerson.address>
												</cfif>
												<cfif len(trim(request.qSalesPerson.city))>
													<cfset opt = opt&",CITY:"&request.qSalesPerson.city>
												</cfif>
												<cfif len(trim(request.qSalesPerson.state))>
													<cfset opt = opt&",STATE:"&request.qSalesPerson.state>
												</cfif>
												<cfif len(trim(request.qSalesPerson.telephone))>
													<cfset opt = opt&",Phone##:"&request.qSalesPerson.telephone>
												</cfif>
												<option value="#request.qSalesPerson.Name#" srname="#request.qSalesPerson.Name#">#opt#</option>
											</cfif>
										</cfloop>
				            	 	<cfelse>
						            	<option value="">Select</option>
						                <cfloop query="request.qSalesPerson">
											<cfset opt = request.qSalesPerson.Name>
											<cfif len(trim(request.qSalesPerson.address))>
													<cfset opt = opt&",ADDRESS:"&request.qSalesPerson.address>
												</cfif>
												<cfif len(trim(request.qSalesPerson.city))>
													<cfset opt = opt&",CITY:"&request.qSalesPerson.city>
												</cfif>
												<cfif len(trim(request.qSalesPerson.state))>
													<cfset opt = opt&",STATE:"&request.qSalesPerson.state>
												</cfif>
												<cfif len(trim(request.qSalesPerson.telephone))>
													<cfset opt = opt&",Phone##:"&request.qSalesPerson.telephone>
												</cfif>
											<option value="#request.qSalesPerson.Name#" srname="#request.qSalesPerson.Name#">#opt#</option>
										</cfloop>
						            </cfif>
					            </select> 
				            <cfelse>
								<input type="text" name="salesRepTo" id="salesRepTo" value="">
				            </cfif>
		            		<div class="clear"></div>		
	        			</div>
	        			<div class="clear"></div>
						<cfif ListContains(session.rightsList,'SalesRepReport',',')>
							<div>
								<h2 style="margin-top:25px; text-align: center;" class="">OR</h2>
							</div>
						</cfif>
	        			<div class="clear"></div>
	            
	        			<h2 style="margin-left: 50px;" class="reportsSubHeading">Dispatcher</h2>
	        			<div style="float:right; margin-right:40px;">
		        			<label>From </label>
					        <select name="dispatcherFrom" id="dispatcherFrom">
					        	<cfif structKeyExists(session, "currentusertype") AND session.currentusertype eq 'Dispatcher'>
					        		<cfloop query="request.qDispatcher">
					        			<cfif request.qDispatcher.EmployeeID EQ session.empid>
					        				<cfset opt = request.qDispatcher.Name>
											<cfif len(trim(request.qDispatcher.address))>
												<cfset opt = opt&",ADDRESS:"&request.qDispatcher.address>
											</cfif>
											<cfif len(trim(request.qDispatcher.city))>
												<cfset opt = opt&",CITY:"&request.qDispatcher.city>
											</cfif>
											<cfif len(trim(request.qDispatcher.state))>
												<cfset opt = opt&",STATE:"&request.qDispatcher.state>
											</cfif>
											<cfif len(trim(request.qDispatcher.telephone))>
												<cfset opt = opt&",Phone##:"&request.qDispatcher.telephone>
											</cfif>
								        	<option value="#request.qDispatcher.Name#">#opt#</option>
								        </cfif>
							        </cfloop>	
					        	<cfelse>
					            	<option value="">Select</option>
					                <cfloop query="request.qDispatcher">
					                	<cfset opt = request.qDispatcher.Name>
										<cfif len(trim(request.qDispatcher.address))>
											<cfset opt = opt&",ADDRESS:"&request.qDispatcher.address>
										</cfif>
										<cfif len(trim(request.qDispatcher.city))>
											<cfset opt = opt&",CITY:"&request.qDispatcher.city>
										</cfif>
										<cfif len(trim(request.qDispatcher.state))>
											<cfset opt = opt&",STATE:"&request.qDispatcher.state>
										</cfif>
										<cfif len(trim(request.qDispatcher.telephone))>
											<cfset opt = opt&",Phone##:"&request.qDispatcher.telephone>
										</cfif>
							        	<option value="#request.qDispatcher.Name#"  dname="#request.qDispatcher.Name#">#opt#</option>
							        </cfloop>
					            </cfif>
				            </select>
				            <div class="clear"></div>
				            <label>To </label>
					        <select id="dispatcherTo" name="dispatcherTo">
				            	<cfif structKeyExists(session, "currentusertype") AND session.currentusertype eq 'Dispatcher'>
					        		<cfloop query="request.qDispatcher">
					        			<cfif request.qDispatcher.EmployeeID EQ session.empid>
								        	<cfset opt = request.qDispatcher.Name>
											<cfif len(trim(request.qDispatcher.address))>
												<cfset opt = opt&",ADDRESS:"&request.qDispatcher.address>
											</cfif>
											<cfif len(trim(request.qDispatcher.city))>
												<cfset opt = opt&",CITY:"&request.qDispatcher.city>
											</cfif>
											<cfif len(trim(request.qDispatcher.state))>
												<cfset opt = opt&",STATE:"&request.qDispatcher.state>
											</cfif>
											<cfif len(trim(request.qDispatcher.telephone))>
												<cfset opt = opt&",Phone##:"&request.qDispatcher.telephone>
											</cfif>
								        	<option value="#request.qDispatcher.Name#"  dname="#request.qDispatcher.Name#">#opt#</option>
									        </cfif>
							        </cfloop>	
					        	<cfelse>
					            	<option value="">Select</option>
					                <cfloop query="request.qDispatcher">
							        	<cfset opt = request.qDispatcher.Name>
										<cfif len(trim(request.qDispatcher.address))>
											<cfset opt = opt&",ADDRESS:"&request.qDispatcher.address>
										</cfif>
										<cfif len(trim(request.qDispatcher.city))>
											<cfset opt = opt&",CITY:"&request.qDispatcher.city>
										</cfif>
										<cfif len(trim(request.qDispatcher.state))>
											<cfset opt = opt&",STATE:"&request.qDispatcher.state>
										</cfif>
										<cfif len(trim(request.qDispatcher.telephone))>
											<cfset opt = opt&",Phone##:"&request.qDispatcher.telephone>
										</cfif>
							        	<option value="#request.qDispatcher.Name#"  dname="#request.qDispatcher.Name#">#opt#</option>
							        </cfloop>
					            </cfif>
				            </select>
				            <div class="clear"></div>
				        </div>
				        <div class="clear"></div>
				 
						<h2 style="margin-top:17px; margin-left: 50px;" class="reportsSubHeading">Customer</h2>
						<div style="float:right; margin-right:40px;">
							<label>From </label>
							<select name="customerFrom" id="customerFrom">
								<option value="">Select</option>
								<cfloop query="request.qryCustomersList">
									<cfset opt = request.qryCustomersList.customername>
									<cfif len(trim(request.qryCustomersList.location))>
										<cfset opt = opt&",ADDRESS:"&request.qryCustomersList.location>
									</cfif>
									<cfif len(trim(request.qryCustomersList.city))>
										<cfset opt = opt&",CITY:"&request.qryCustomersList.city>
									</cfif>
									<cfif len(trim(request.qryCustomersList.statecode))>
										<cfset opt = opt&",STATE:"&request.qryCustomersList.statecode>
									</cfif>
									<cfif len(trim(request.qryCustomersList.PhoneNo))>
										<cfset opt = opt&",Phone##:"&request.qryCustomersList.PhoneNo>
									</cfif>
									<option value="#request.qryCustomersList.customername#" custName="#request.qryCustomersList.customername#">#opt#</option>
								</cfloop>
							</select>
							<div class="clear"></div>
							<label>To </label>
							<select name="customerTo" id="customerTo">
								<option value="">Select</option>
								<cfloop query="request.qryCustomersList">
									<cfset opt = request.qryCustomersList.customername>
									<cfif len(trim(request.qryCustomersList.location))>
										<cfset opt = opt&",ADDRESS:"&request.qryCustomersList.location>
									</cfif>
									<cfif len(trim(request.qryCustomersList.city))>
										<cfset opt = opt&",CITY:"&request.qryCustomersList.city>
									</cfif>
									<cfif len(trim(request.qryCustomersList.statecode))>
										<cfset opt = opt&",STATE:"&request.qryCustomersList.statecode>
									</cfif>
									<cfif len(trim(request.qryCustomersList.PhoneNo))>
										<cfset opt = opt&",Phone##:"&request.qryCustomersList.PhoneNo>
									</cfif>
									<option value="#request.qryCustomersList.customername#" custname="#request.qryCustomersList.customername#">#opt#</option>
								</cfloop>
							</select>
							<div class="clear"></div>
						</div>
						<div class="clear"></div>

				
						<h2 style="margin-top:32px; margin-left: 50px;" class="reportsSubHeading">Equipment</h2>
						<div style="float:right; margin-right:40px;">
							<label>From </label>
							<select name="equipmentFrom" id="equipmentFrom">
								<option value="">Select</option>
								<cfloop query="request.qEquipments">
								<option value="#request.qEquipments.equipmentname#">#request.qEquipments.equipmentname#</option>
								</cfloop>
							</select>
							<div class="clear"></div>
							<label>To </label>
							<select name="equipmentTo" id="equipmentTo">
								<option value="">Select</option>
								<cfloop query="request.qEquipments">
								<option value="#request.qEquipments.equipmentname#">#request.qEquipments.equipmentname#</option>
								</cfloop>
							</select>
						</div>
						<div class="clear"></div>	

						<h2 style="margin-top:32px; margin-left: 50px;" class="reportsSubHeading">#variables.freightBroker#</h2>
						<div style="float:right; margin-right:40px;">
							<label>From </label>
							<select name="carrierFrom" id="carrierFrom">
								<option value="">Select</option>
								<cfloop query="request.qCarrier">
									<cfset opt = request.qCarrier.CarrierName>
									<cfif len(trim(request.qCarrier.address))>
										<cfset opt = opt&",ADDRESS:"&request.qCarrier.address>
									</cfif>
									<cfif len(trim(request.qCarrier.city))>
										<cfset opt = opt&",CITY:"&request.qCarrier.city>
									</cfif>
									<cfif len(trim(request.qCarrier.statecode))>
										<cfset opt = opt&",STATE:"&request.qCarrier.statecode>
									</cfif>
									<cfif len(trim(request.qCarrier.Phone))>
										<cfset opt = opt&",Phone##:"&request.qCarrier.Phone>
									</cfif>
									<option value="#request.qCarrier.CarrierName#" cname="#request.qCarrier.CarrierName#">#opt#</option>
								</cfloop>
							</select>
							<div class="clear"></div>
							<label>To </label>
							<select name="carrierTo" id="carrierTo">
								<option value="">Select</option>
								<cfloop query="request.qCarrier">
									<cfset opt = request.qCarrier.CarrierName>
									<cfif len(trim(request.qCarrier.address))>
										<cfset opt = opt&",ADDRESS:"&request.qCarrier.address>
									</cfif>
									<cfif len(trim(request.qCarrier.city))>
										<cfset opt = opt&",CITY:"&request.qCarrier.city>
									</cfif>
									<cfif len(trim(request.qCarrier.statecode))>
										<cfset opt = opt&",STATE:"&request.qCarrier.statecode>
									</cfif>
									<cfif len(trim(request.qCarrier.Phone))>
										<cfset opt = opt&",Phone##:"&request.qCarrier.Phone>
									</cfif>
									<option value="#request.qCarrier.CarrierName#" cname="#request.qCarrier.CarrierName#">#opt#</option>
								</cfloop>
							</select>
						</div>
				        <div class="right" style="margin-top:20px;border-top: 1px solid ##77463d;width:88%;">
				        	<div style="margin-left: 100px;margin-top: 20px;">
								<input id="sReport" type="submit" name="viewReport" class="bttn tooltip" value="View Report" style="width:95px;" formtarget="_blank"/>
				        	</div>
					    </div>
					</fieldset>
			        <div class="clear"></div>
				</div>
	    		<div class="clear"></div>
	    	</form>
	    </div>
	</div>
</cfoutput>