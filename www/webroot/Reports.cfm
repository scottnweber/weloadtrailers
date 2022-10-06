<cfif not structKeyExists(Cookie, "ReportIncludeAllDispatchers")>
	<cfcookie name="ReportIncludeAllDispatchers" value="false" expires="never">
</cfif>
<cfif not structKeyExists(Cookie, "ReportIncludeAllSalesRep")>
	<cfcookie name="ReportIncludeAllSalesRep" value="false" expires="never">
</cfif>
<cfparam name="MailTo" default="">
<cfparam name="MailFrom" default="">
<cfparam name="Subject" default="">
<cfparam name="body" default="">
<cfset Secret = application.dsn>
<cfset TheKey = 'NAMASKARAM'>
<cfset Encrypted = Encrypt(Secret, TheKey)>
<cfset dsn = ToBase64(Encrypted)>
<cfscript>
	variables.objequipmentGateway = getGateway("gateways.equipmentgateway", MakeParameters("dsn=#Application.dsn#,pwdExpiryDays=#Application.pwdExpiryDays#"));
	variables.objCutomerGateway = getGateway("gateways.customergateway", MakeParameters("dsn=#Application.dsn#,pwdExpiryDays=#Application.pwdExpiryDays#"));
</cfscript>
<cfsilent>
	<cfparam name="loadID" default="">
	<cfif session.currentusertype EQ 'Administrator' OR listFindNoCase(session.rightslist, "showAllOfficeLoads")>
		<cfinvoke component="#variables.objofficeGateway#" method="getAllOffices" sortby="officecode" sortorder="asc"  returnvariable="request.qOffices" />
	<cfelse>
		<cfinvoke component="#variables.objofficeGateway#" method="getAllOffices" sortby="officecode" officeid="#session.officeid#" sortorder="asc"  returnvariable="request.qOffices" />
	</cfif>
	<cfinvoke component="#variables.objloadGateway#" method="getCompanyInformation" returnvariable="request.qGetCompanyInformation" />
	<cfinvoke component="#variables.objloadGateway#" method="getcurAgentMaildetails" returnvariable="request.qcurAgentdetails" employeID="#session.empid#" />
	<cfinvoke component="#variables.objloadGateway#" AuthLevelId="Sales Representative,Dispatcher" method="getSalesPerson" returnvariable="request.qSalesPerson" />
	<cfinvoke component="#variables.objloadGateway#" AuthLevelId="Dispatcher" method="getSalesPerson" returnvariable="request.qDispatcher" />
	<cfinvoke component="#variables.objloadGateway#" method="getSystemSetupOptions" returnvariable="request.qGetSystemSetupOptions" />
	<cfinvoke component="#variables.objequipmentGateway#" method="getloadEquipments" returnvariable="request.qEquipments" />
	<cfinvoke component="#variables.objCutomerGateway#" method="getAllpayerCustomers" returnvariable="request.qryCustomersList" />
	<cfinvoke component="#variables.objloadGateway#" method="getcurAgentMaildetails" returnvariable="request.qcurMailAgentdetails" employeID="#session.empid#" />
	<cfset MailFrom=request.qcurAgentdetails.EmailID>
	<cfset Subject = request.qGetSystemSetupOptions.SalesHead>
	<cfif request.qcurMailAgentdetails.recordcount gt 0 and (request.qcurMailAgentdetails.SmtpAddress eq "" or request.qcurMailAgentdetails.SmtpUsername eq "" or request.qcurMailAgentdetails.SmtpPort eq "" or request.qcurMailAgentdetails.SmtpPassword eq "" or request.qcurMailAgentdetails.SmtpPort eq 0)>
	  	<cfset mailsettings = "false">
	<cfelse>
	  	<cfset mailsettings = "true">
	</cfif>
	<cfif request.qGetSystemSetupOptions.freightBroker EQ 1>
		<cfset variables.freightBroker = "Carrier">
		<cfinvoke component="#variables.objCarrierGateway#" method="getAllCarriersForReport" IsCarrier="1" returnvariable="request.qCarrier"></cfinvoke>
	<cfelseif request.qGetSystemSetupOptions.freightBroker EQ 2>
		<cfset variables.freightBroker = "Carrier/Driver">
		<cfinvoke component="#variables.objCarrierGateway#" method="getAllCarriersForReport" returnvariable="request.qCarrier"></cfinvoke>
	<cfelse>
		<cfset variables.freightBroker = "Driver">
		<cfinvoke component="#variables.objCarrierGateway#" method="getAllCarriersForReport" IsCarrier="0" returnvariable="request.qCarrier"></cfinvoke>
	</cfif>

</cfsilent>

<cfoutput>
	<style type="text/css">
		.reportsSubHeading{
			border-bottom: 1px solid ##77463d !important;
			margin-bottom: 5px !important;
		}
		.disAllowEditSelectBox {
			background: none repeat scroll 0 0 ##e3e3e3 !important;
			border: 1px solid ##c5c1c1 !important;
			color: ##434343 !important;
			pointer-events: none;
		}
		.hideAllSalesRep{
			display: none;
		}
	</style>
	<div class="white-con-area" style="height: 36px;background-color: ##82bbef;">
		<div style="float: left;"><h2 style="color:white;font-weight:bold;margin-left: 12px;">Sales & Commission Report</h2></div>
	</div>
	<div style="clear:left"></div>

	<div class="white-con-area">
		<div class="white-top"></div>
	    <div class="white-mid">
			<cfform name="frmCommissionReport" action="##" method="post">
				<input type="hidden" name="urlToken" id="urlToken" value="#session.urlToken#">
				<input type="hidden" name="appDsn" id="appDsn" value="#application.dsn#">
				<div class="form-con" style="margin-bottom: 20px;">
					<fieldset>
						<h2 class="reportsSubHeading">Group By&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Sort By</h2>
						<div class="clear"></div>
	            		<div style="width:10px; float:left;">&nbsp;</div>
	            		<div style="float: left;">
		           			<div style="float:left;">
				                <cfinput type="radio" name="groupBy" value="none" id="none" checked="yes" style="width:15px; padding:0px 0px 0 0px;margin-bottom:1px;"  onclick="hideCustomerCheckBox();hidecheckBoxGroup();"/>
				                <label class="normal" for="salesAgent" style="text-align:left; padding:0 0 0 0;width: 90px;">None</label>

				                <cfinput type="radio" name="sortby" value="loadno" id="loadno" style="width:15px; padding:0px 0px 0 0px;margin-bottom:1px;" checked/>
				                <label class="normal" for="loadno" style="text-align:left; padding:0 0 0 0;width: 50px;">Load##</label>
				            </div>
	    					<div class="clear"></div>
	            		<!--- <div style="width:10px; float:left;">&nbsp;</div> --->
		        			<div style="float:left;">
				            	<cfif request.qGetSystemSetupOptions.freightBroker>	
				                	
				                	<cfinput type="radio" name="groupBy" value="salesAgent" id="salesAgent" style="width:15px; padding:0px 0px 0 0px;margin-bottom:1px;" onclick="hideCustomerCheckBox();showcheckBoxGroup();shwIncSalesrep();"/>
				                <cfelse>
				                	<cfif len(trim(request.qGetSystemSetupOptions.userDef7))>
				                			
				                		<cfinput type="radio" name="groupBy" value="#request.qGetSystemSetupOptions.userDef7#" id="salesAgent" style="width:15px; padding:0px 0px 0 0px;margin-bottom:1px;" onclick="hideCustomerCheckBox();showcheckBoxGroup();shwIncSalesrep();"/>	
				                	<cfelse>
				                		<cfinput type="radio" name="groupBy" value="salesAgent" id="salesAgent" style="width:15px; padding:0px 0px 0 0px;margin-bottom:1px;" onclick="hideCustomerCheckBox();showcheckBoxGroup();shwIncSalesrep();"/>
				                	</cfif>
				                </cfif>

		                		<label class="normal" for="salesAgent" style="text-align:left; padding:0 0 0 0;width: 90px;" >
					                <cfif request.qGetSystemSetupOptions.freightBroker>	
					                	Sales Agent
					                <cfelse>
					                	<cfif len(trim(request.qGetSystemSetupOptions.userDef7))>
					                			#request.qGetSystemSetupOptions.userDef7#
					                	<cfelse>
					                		Sales Agent	
					                	</cfif>
					                </cfif>	
		                		</label>

		                		<cfinput type="radio" name="sortby" value="date" id="date" style="width:15px; padding:0px 0px 0 0px;margin-bottom:1px;"/>
				                <label class="normal" for="date" style="text-align:left; padding:0 0 0 0;width: 50px;">Date</label>
		            		</div>

		            		<div class="clear"></div>
	            			<!--- <div style="width:10px; float:left;">&nbsp;</div> --->
		            		<div style="float:left;">
		                		<cfinput type="radio" name="groupBy" value="dispatcher" id="dispatcher"  style="width:15px; padding:0px 0px 0 0px;margin-bottom:1px;" onclick="hideCustomerCheckBox();showcheckBoxGroup();"/>
		                		<label class="normal" for="dispatcher" style="text-align:left; padding:0 0 0 0;" >Dispatcher</label>
		            		</div>			
							<div class="clear"></div>
							<!--- <div style="width:10px; float:left;">&nbsp;</div> --->
		            		<div style="float:left;">
				                <cfinput type="radio" name="groupBy" value="customer" id="customer"  style="width:15px; padding:0px 0px 0 0px;margin-bottom:1px;" onclick="hideCustomerCheckBox();showcheckBoxGroup()"/>
				                <label class="normal" for="customer" style="text-align:left; padding:0 0 0 0;" >Customer</label>
				            </div>			
					 		<div class="clear"></div>
		            		<!--- <div style="width:10px; float:left;">&nbsp;</div> --->
				            <div style="float:left;">
				                <cfinput type="radio" name="groupBy" value="#variables.freightBroker#" id="#variables.freightBroker#" style="width:15px; padding:0px 0px 0 0px;margin-bottom:1px;" onclick="showCustomerCheckBox();showcheckBoxGroup()"/>
				                <label class="normal" for="#variables.freightBroker#" style="text-align:left; padding:0 0 0 0;">#variables.freightBroker#</label>
				            </div>            
			            	<div class="clear"></div> 
			            </div>

			            <div style="float: left;">
							<div style="float:left;" class="hideAllDispatcher">
				                <cfinput type="checkbox" name="incAllDispatchers" value="" id="incAllDispatchers" style="width: 16px;"onclick="updateReportCookies('ReportIncludeAllDispatchers',this)" checked="#cookie.ReportIncludeAllDispatchers#"/>
				                 <label class="normal" for="incAllDispatchers" style="text-align:left;">Include Dispatcher 2 & 3</label>
				            </div>  
							<div class="clear"></div>  
 							<div style="float:left;" class="hideAllSalesRep">
				                <cfinput type="checkbox" name="incAllSalesRep" value="" id="incAllSalesRep" style="width: 16px;"onclick="updateReportCookies('ReportIncludeAllSalesRep',this)" checked="#cookie.ReportIncludeAllDispatchers#"/>
				                 <label class="normal" for="incAllSalesRep" style="text-align:left;">Include Sales Rep 2 & 3</label>
				            </div> 
				            <div class="clear"></div>  
			            	<div style="float:left;" class="hidecheckBoxGroup">
				                <cfinput type="checkbox" name="customerCheck" value="" id="customerCheckGroup" checked style="width: 16px;"/>
				                 <label class="normal" for="customerCheckGroup" style="width:155px;text-align:left;">Page Break After Each Group?</label>
				            </div> 
				            <div class="clear"></div>     
				            <div style="float:left;" class="hidecheckBox">
				                <cfinput type="checkbox" name="customerCheck" value="" id="customerCheck" checked style="width: 16px;"/>
				                 <label class="normal" for="customerCheck" style="width:100px;text-align:left;">Show Customer Info</label>
				            </div>   
				        </div>
			            <div class="clear"></div>  
			            <div style="margin-top:30px;">
				            <cfinput type="radio" name="datetype" value="Shipdate" id="customer"  style="width:15px; padding:0px 0px 0 0px;" checked="true"/>
				            <label class="normal" style="width:50px;"><h2 style="float:left;padding: 0;">Pickup</h2></label>

				            <cfinput type="radio" name="datetype" value="Deliverydate" id="customer"  style="width:15px; padding:0px 0px 0 0px;"/>
				            <label class="normal" style="width:70px;"><h2 style="float:left;padding: 0;">Delivery</h2></label>

				            <cfinput type="radio" name="datetype" value="Invoicedate" id="customer"  style="width:15px; padding:0px 0px 0 0px;"/>
				            <label class="normal" style="width:60px;"><h2 style="float:left;padding: 0;">Invoice</h2></label>

				            <cfinput type="radio" name="datetype" value="Createdate" id="customer"  style="width:15px; padding:0px 0px 0 0px;"/>
				            <label class="normal" style="width:60px;"><h2 style="float:left;padding: 0;">Create</h2></label>
				            <div class="clear reportsSubHeading" ></div>  
			            </div>


                        <label class="space_it">From</label>
                        <div style="position:relative;float:left;">
                            <div style="float:left;">
                                <input class="sm-input datefield" tabindex=4 name="dateFrom" id="dateFrom"  value="#dateformat(Now()-30,'mm/dd/yyy')#" validate="date" required="yes" message="Please enter a valid date" type="datefield" />
                            </div>
                        </div>

			        	<label style="margin-left: -54px;">To</label>

                       
                        <div style="position:relative;float:left;">
                            <div style="float:left;">
                                <input class="sm-input datefield" tabindex=4 name="dateTo" id="dateTo"  value="#dateformat(Now(),'mm/dd/yyy')#" validate="date" required="yes" message="Please enter a valid date" type="datefield" />
                            </div>
                        </div>

						<div width="100%" style="margin-top: 30px;">
							<div style="float:left;margin-top:15px;width:50%;">
								<h2 class="reportsSubHeading">Commission</h2>
								
								
								<label>Commission %</label>
								<cfinput class="sm-input" name="commissionPercent" id="commissionPercent" value="#NumberFormat(0,'0.00')#" validate="float" required="yes" message="Please enter a valid percentage in Commission %"/>
								<div class="clear"></div>
							</div>
							<div  style="float:left;margin-top:15px;width:50%;">
								<h2 style="text-align:center;" class="reportsSubHeading">Margin Range</h2>
								<label>From </label>
								<cfinput class="sm-input" name="marginFrom" id="marginFrom" value="#DollarFormat(0)#" validate="float" required="yes" message="Please enter a valid amount in Margin From"/>
								<div class="clear"></div>
								
								<label>To </label>
								<cfinput class="sm-input" name="marginTo" id="marginTo" value="#DollarFormat(0)#" validate="float" required="yes" message="Please enter a valid amount in Margin To"/>
								<div class="clear"></div>
							</div>
						</div>
						<div class="clear"></div>
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
						<div style="margin-top: 30px;">
							<h2 style="margin-top:14px;" class="reportsSubHeading">Load Status</h2>
				            <label>Status From</label>
							<cfinvoke component="#variables.objloadGateway#" method="getLoadStatus" returnvariable="request.qLoadStatus" /> 			
				   			<select name="loadStatus" id="StatusTo">
								<cfloop query="request.qLoadStatus">
									<option data-statustext="#request.qLoadStatus.text#" value="#request.qLoadStatus.value#" <cfif loadStatusFrom EQ  request.qLoadStatus.value>selected="selected"</cfif>>#request.qLoadStatus.statusdescription#</option>
								</cfloop>
							</select>
				
							<label>Status To</label>					
							<cfinvoke component="#variables.objloadGateway#" method="getLoadStatus" returnvariable="request.qLoadStatus" /> 
				   			<select name="loadStatus" id="StatusFrom">
								<cfloop query="request.qLoadStatus">
									<option data-statustext="#request.qLoadStatus.text#" value="#request.qLoadStatus.value#" <cfif loadStatusTo EQ  request.qLoadStatus.value>selected="selected"</cfif>>#request.qLoadStatus.statusdescription#</option>
								</cfloop>
							</select>
						</div>

						<div class="clear"></div>
			            <div style="margin-top:30px">
				            <h2 style="margin-top:12px;" class="reportsSubHeading">Type</h2>
							<label>Report Type</label>
					        <cfselect name="reportType" id="reportType">
								<option value="Sales">Sales</option>
								<option value="Commission">Commission</option>
							</cfselect>
			            </div>
			            <div class="clear"></div> 	
			            <div style="border-top: 1px solid ##77463d; margin-top: 56px;">	
			            	<div style="float:right;margin-right: -51px;">	
								<div style="float:left;">
									<h2 style="margin-top:14px;width: 184px;float:left;">Show Report Criteria</h2> 
								</div>	
								<div style="float:left;">
									<cfinput type="checkbox" name="ShowReportCriteria" value="" id="ShowReportCriteria"  style="margin-left: -83px;margin-top: 13px;">
								</div>
								<div style="clear:both;"></div> 	
					        </div>
							<div style="float:right;margin-right: -51px;">	
								<div style="float:left;">
									<h2 style="margin-top:14px;width: 184px;float:left;">Show Summary Only</h2> 
								</div>	
								<div style="float:left;">
									<cfinput type="checkbox" name="ShowSummaryOnly" value="" id="ShowSummaryOnly"  style="margin-left: -83px;margin-top: 13px;">
								</div>
								<div style="clear:both;"></div> 	
					        </div>  	
				           	<div class="clear"></div> 	
				           	<div style="float:right; margin-right:-51px;">	
								<div style="float:left;">
									<h2 style="margin-top:14px;width: 184px;float:left;">Show Profit & Cost</h2> 
								</div>	
								<div style="float:left;">
									<cfinput type="checkbox" name="ShowProfit" checked value="" id="ShowProfit"  style="margin-left: -83px;margin-top: 13px;">
								</div>
								<div style="clear:both;"></div> 	
					        </div>  	
				           	<div class="clear"></div>
				        </div>
					</fieldset>
				</div>
				<div class="form-con">
					<fieldset>	
		        		<h2 class="reportsSubHeading" style="margin-left: 50px;">
				 			<cfif request.qGetSystemSetupOptions.freightBroker>	
				            	Sales Rep
				            <cfelse>
				            	<cfif len(trim(request.qGetSystemSetupOptions.userDef7))>
				            			#request.qGetSystemSetupOptions.userDef7#
				            	<cfelse>
				            		Sales Rep	
				            	</cfif>
				            </cfif>	
	        			</h2>
	        			<div style="float:right; margin-right:40px;">
				            <label>From </label>
				            <cfif request.qGetSystemSetupOptions.freightBroker>
				            	 <cfselect name="salesRepFrom" id="salesRepFrom">
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
												<option value="#request.qSalesPerson.EmployeeID#" srname="#request.qSalesPerson.Name#">#opt#</option>
											</cfif>
										</cfloop>
				            	 	<cfelse>
				            	 		<option value="########" srname="########">########</option>
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
											<option value="#request.qSalesPerson.EmployeeID#" srname="#request.qSalesPerson.Name#">#opt#</option>
										</cfloop>
						                <option value="ZZZZ" srname="ZZZZ">ZZZZ</option>
				            	 	</cfif>
					            </cfselect> 	
				          	<cfelse>	  	
						       <cfinput type="text" name="salesRepFrom" id="salesRepFrom" value="(BLANK)" srname="(BLANK)">
					        </cfif>    
				            <div class="clear"></div>
				            <label>To </label>
				             
				            <cfif request.qGetSystemSetupOptions.freightBroker>
								<cfselect id="salesRepTo" name="salesRepTo">
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
												<option value="#request.qSalesPerson.EmployeeID#" srname="#request.qSalesPerson.Name#">#opt#</option>
											</cfif>
										</cfloop>
				            	 	<cfelse>
						            	<option value="########" srname="########">########</option>
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
											<option value="#request.qSalesPerson.EmployeeID#" srname="#request.qSalesPerson.Name#">#opt#</option>
										</cfloop>
						                <option value="ZZZZ" srname="ZZZZ" selected="selected">ZZZZ</option>
						            </cfif>
					            </cfselect> 
				            <cfelse>
								<cfinput type="text" name="salesRepTo" id="salesRepTo" value="ZZZZ" srname="ZZZZ">
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
					        <cfselect name="dispatcherFrom" id="dispatcherFrom">
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
								        	<option value="#request.qDispatcher.EmployeeID#" dname="#request.qDispatcher.Name#">#opt#</option>
								        </cfif>
							        </cfloop>	
					        	<cfelse>
					            	<option value="########" dname="########">########</option>
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
							        	<option value="#request.qDispatcher.EmployeeID#"  dname="#request.qDispatcher.Name#">#opt#</option>
							        </cfloop>
					                <option value="ZZZZ" dname="ZZZZ">ZZZZ</option>
					            </cfif>
				            </cfselect>
				            <div class="clear"></div>
				            <label>To </label>
					        <cfselect id="dispatcherTo" name="dispatcherTo">
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
								        	<option value="#request.qDispatcher.EmployeeID#"  dname="#request.qDispatcher.Name#">#opt#</option>
									        </cfif>
							        </cfloop>	
					        	<cfelse>
					            	<option value="########" dname="########">########</option>
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
							        	<option value="#request.qDispatcher.EmployeeID#"  dname="#request.qDispatcher.Name#">#opt#</option>
							        </cfloop>
					                <option value="ZZZZ" dname="ZZZZ" selected="selected">ZZZZ</option>
					            </cfif>
				            </cfselect>
				            <div class="clear"></div>
				        </div>
				        <div class="clear"></div>
				 
						<h2 style="margin-top:17px; margin-left: 50px;" class="reportsSubHeading">Customer</h2>
						<div style="float:right; margin-right:40px;">
							<label>From </label>
							<cfselect name="customerFrom" id="customerFrom">
								<option value="########" custName="########">########</option>
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
									<option value="#request.qryCustomersList.customerid#" custName="#request.qryCustomersList.customername#">#opt#</option>
								</cfloop>
								<option value="ZZZZ" custName="ZZZZ">ZZZZ</option>
							</cfselect>
							<div class="clear"></div>
							<label>To </label>
							<cfselect name="customerTo" id="customerTo">
								<option value="########" custName="########">########</option>
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
									<option value="#request.qryCustomersList.customerid#" custname="#request.qryCustomersList.customername#">#opt#</option>
								</cfloop>
								<option value="ZZZZ" custName="ZZZZ" selected="selected">ZZZZ</option>
							</cfselect>
							<div class="clear"></div>
						</div>
						<div class="clear"></div>

				
						<h2 style="margin-top:32px; margin-left: 50px;" class="reportsSubHeading">Equipment</h2>
						<div style="float:right; margin-right:40px;">
							<label>From </label>
							<cfselect name="equipmentFrom" id="equipmentFrom">
								<option value="########">########</option>
								<cfloop query="request.qEquipments">
								<option value="#request.qEquipments.equipmentID#">#request.qEquipments.equipmentname#</option>
								</cfloop>
								<option value="ZZZZ">ZZZZ</option>
							</cfselect>
							<div class="clear"></div>
							<label>To </label>
							<cfselect name="equipmentTo" id="equipmentTo">
								<option value="########">########</option>
								<cfloop query="request.qEquipments">
								<option value="#request.qEquipments.equipmentID#">#request.qEquipments.equipmentname#</option>
								</cfloop>
								<option value="ZZZZ" selected="selected">ZZZZ</option>
							</cfselect>
						</div>
						<div class="clear"></div>	

						<h2 style="margin-top:32px; margin-left: 50px;" class="reportsSubHeading">Office</h2>
						<div style="float:right; margin-right:40px;">
							<label>From </label>
							<cfset fromToOfcClass="">
							<cfif NOT (session.currentusertype EQ "administrator" OR ListContains(session.rightsList,'showAllOfficeLoads',','))>
								<cfset fromToOfcClass="disAllowEditSelectBox">
							</cfif>
							<cfselect name="officeFrom" id="officeFrom" class="#fromToOfcClass#">
								<cfif session.currentusertype EQ 'Administrator' OR listFindNoCase(session.rightslist, "showAllOfficeLoads")>
									<option value="########">########</option>
								</cfif>
								<cfloop query="request.qOffices">
								<option value="#request.qOffices.officecode#">#request.qOffices.officecode#</option>
								</cfloop>
								<cfif session.currentusertype EQ 'Administrator' OR listFindNoCase(session.rightslist, "showAllOfficeLoads")>
									<option value="ZZZZ">ZZZZ</option>
								</cfif>
							</cfselect>
							<div class="clear"></div>
							<label>To </label>
							<cfselect name="officeTo" id="officeTo" class="#fromToOfcClass#">
								<cfif session.currentusertype EQ 'Administrator' OR listFindNoCase(session.rightslist, "showAllOfficeLoads")>
									<option value="########">########</option>
								</cfif>
								<cfloop query="request.qOffices">
								<option value="#request.qOffices.officecode#">#request.qOffices.officecode#</option>
								</cfloop>
								<cfif session.currentusertype EQ 'Administrator' OR listFindNoCase(session.rightslist, "showAllOfficeLoads")>
									<option value="ZZZZ" selected="selected">ZZZZ</option>
								</cfif>
							</cfselect>
						</div>
						<div class="clear"></div>

						<h2 style="margin-top:32px; margin-left: 50px;" class="reportsSubHeading">#variables.freightBroker#</h2>
						<div style="float:right; margin-right:40px;">
							<label>From </label>
							<cfselect name="carrierFrom" id="carrierFrom">
								<option value="########" cname="########">########</option>
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
									<option value="#request.qCarrier.carrierID#" cname="#request.qCarrier.CarrierName#">#opt#</option>
								</cfloop>
								<option value="ZZZZ" cname="ZZZZ">ZZZZ</option>
							</cfselect>
							<div class="clear"></div>
							<label>To </label>
							<cfselect name="carrierTo" id="carrierTo">
								<option value="########" cname="########">########</option>
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
									<option value="#request.qCarrier.carrierID#" cname="#request.qCarrier.CarrierName#">#opt#</option>
								</cfloop>
								<option value="ZZZZ" cname="ZZZZ" selected="selected">ZZZZ</option>
							</cfselect>
						</div>
						<div class="clear"></div>   	
						<cfinput type="hidden" name="repUrl" id="repUrl" value="ss">
						<cfinput type="hidden" name="freightBroker" id="freightBroker" value="#variables.freightBroker#">
						<cfinput type="hidden" name="companyid" id="companyid" value="#session.companyid#">
				        <div class="right" style="margin-top:20px;border-top: 1px solid ##77463d;width:88%;">
				        	<div style="margin-left: 100px;margin-top: 20px;">
								<div style="cursor:pointer;width:27px;background-color: ##bfbcbc;float: left;margin: 1px 0;text-align: center;">
									<cfif request.qGetSystemSetupOptions.emailType EQ "Load Manager Email">
										<img id="salesReportImg" style="vertical-align:bottom;" src="images/black_mail.png" data-action="view">
									<cfelse>
										<a <cfif request.qGetCompanyInformation.ccOnEmails EQ true> href="mailto:#MailTo#?cc=#request.qGetCompanyInformation.email#&subject=#Subject#&" <cfelse> href="mailto:#MailTo#?subject=#Subject#"</cfif>>
											<img style="vertical-align:bottom;" src="images/black_mail.png">
										</a>
									</cfif>
								</div>
								<input id="sReport" type="button" name="viewReport" class="bttn tooltip" value="View Report" style="width:95px;"  <cfif mailsettings>data-allowmail="true"<cfelse>data-allowmail="false"</cfif>/>
				        	</div>
					    </div>
					</fieldset>
	        		<div class="clear"></div>
			        <div id="message" class="msg-area" style="width:153px; margin-left:200px; display:none;"></div>
			        <div class="clear"></div>
				</div>
	   			<div class="clear"></div>
	 		</cfform>
	    </div>
		<div class="white-bot"></div>
	</div>

	<script type="text/javascript">
		$(document).ready(function(){
			$('##frmCommissionReport input,##frmCommissionReport  select').change(function(){
				if($(this).attr('id') != 'ShowReportCriteria'){
					$('##ShowReportCriteria').prop('checked', true);
				}
			})

			$('##salesReportImg').click(function(){
				var dsn='#dsn#';
				if($("##customerCheck").is(':checked')){
			 		var customerStatus=0;
			 	}else{
			 		var customerStatus=1;
			 	}	
			 	if($("##customerCheckGroup").is(':checked')){
			 		var pageBreakStatus=1;
			 	}else{
			 		var pageBreakStatus=0;
			 	}
			 	if($("##ShowSummaryOnly").is(':checked')){
			 		var ShowSummaryStatus=1;
			 	}else{
			 		var ShowSummaryStatus=0;
			 	}
			 	if($("##ShowReportCriteria").is(':checked')){
			 		var ShowReportCriteria=1;
			 	}else{
			 		var ShowReportCriteria=0;
			 	}
			 	if($("##ShowProfit").is(':checked')){
			 		var ShowProfit=0;
			 	}else{
			 		var ShowProfit=1;
			 	}
				if("#request.qGetSystemSetupOptions.NonCommissionable#" == 1){
					var NonCommissionable = 1
				}else{
					var NonCommissionable = 0
				}
				getCommissionReport('#session.URLToken#', 'mail',dsn,customerStatus,pageBreakStatus,ShowSummaryStatus,ShowProfit,ShowReportCriteria,NonCommissionable);
			 });
			 $('##sReport').click(function(){	
				var dsn='#dsn#';
			 	if($("##customerCheck").is(':checked')){
			 		var customerStatus=0;
			 	}else{
			 		var customerStatus=1;
			 	}	
		 		if($("##customerCheckGroup").is(':checked')){
			 		var pageBreakStatus=1;
			 	}else{
			 		var pageBreakStatus=0;
			 	}
			 	if($("##ShowSummaryOnly").is(':checked')){
			 		var ShowSummaryStatus=1;
			 	}else{
			 		var ShowSummaryStatus=0;
			 	}
			 	if($("##ShowProfit").is(':checked')){
			 		var ShowProfit=0;
			 	}else{
			 		var ShowProfit=1;
			 	}
			 	if($("##ShowReportCriteria").is(':checked')){
			 		var ShowReportCriteria=1;
			 	}else{
			 		var ShowReportCriteria=0;
			 	}
				if("#request.qGetSystemSetupOptions.NonCommissionable#" == 1){
					var NonCommissionable = 1
				}else{
					var NonCommissionable = 0
				}
			   if(checkdate()){
			   	getCommissionReport('#session.URLToken#', 'view',dsn,customerStatus,pageBreakStatus,ShowSummaryStatus,ShowProfit,ShowReportCriteria,NonCommissionable);
			}
			});

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


		});		
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
		function sendmail(){
			var sub = "#Subject#";
			var mailTo = " ";
			myWindow=window.open("mailto:"+mailTo+"?subject="+sub,'','width=500,height=500');
			
		}
	</script>
</cfoutput>