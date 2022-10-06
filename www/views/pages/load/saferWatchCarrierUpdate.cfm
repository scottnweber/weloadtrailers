
<cftry>
<cfinvoke component="#variables.objloadGateway#" method="getLoadSystemSetupOptions" returnvariable="request.qSystemSetupOptions1" />

<cfparam name="variables.ClassName" default="">
<cfoutput>   
	<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
	<html xmlns="http://www.w3.org/1999/xhtml">
		<head>
			<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />	  
			<title>Load Manager TMS</title>	
			<script type="text/javascript" src="https://maps.google.com/maps/api/js?sensor=false&v=3"></script>
			<link rel="stylesheet" type="text/css" href="styles/jquery.autocomplete.css" />
			<cfset urlCfcPath = Replace(request.cfcpath, '.', '/','All')/>
			<script>
				urlComponentPath  = "/#urlCfcPath#/";
			</script> 
			 
			<link rel="stylesheet" href="https://code.jquery.com/ui/1.11.0/themes/smoothness/jquery-ui.css">
			<link href="styles/style.css?#now()#" rel="stylesheet" type="text/css" />
			<script src="https://code.jquery.com/jquery-1.10.2.min.js"></script>
			<script src="https://code.jquery.com/ui/1.11.0/jquery-ui.min.js"></script>
			<script src="https://ajax.aspnetcdn.com/ajax/jquery.validate/1.9/jquery.validate.min.js"></script>
			<script src="javascripts/Validation.js?#now()#" language="javascript" type="text/javascript"></script>
			<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/font-awesome/4.4.0/css/font-awesome.min.css">		
			<script>			
				$(document).ready( function() {
					$.ajax({
							url: "../gateways/loadgateway.cfc?method=GetChangedCarriers&dsn=#Application.dsn#&adminUserName=#session.adminUserName#&CompanyID=#session.CompanyID#",
							success: function(data){
								$('.Waitmessage').hide();
								$('.WaitTimemessage').hide();
								$('.successMessage').html("<p>Message From SaferWatch API: <br><br>"+data+"</p>");
							},
							error: function(ErrorMsg){
							   console.log("Error");
							}
						});
					});
									
			</script>
		</head>
		
		<cfinvoke component="#variables.objequipmentGateway#" method="getCountEquipments" returnvariable="request.qryCountEquipments" />
		<body style="background-color:#request.qSystemSetupOptions1.BackgroundColor# !important;">
			<div class="container" style="background-color:#request.qSystemSetupOptions1.BackgroundColor# !important;">

				<div class="top-head" style="float:left; width:14%; margin-left:14%;"><a href="##"><img src="images/logo.jpg" alt="Freight Agent Tracking System" /></a></div>
				<div style="float:left; width:42%; text-align:center; margin-top:5px;">
				 
				<cfif request.qSystemSetupOptions1.companyLogoName NEQ ''>
					<img src="images/logo/#request.qSystemSetupOptions1.companyLogoName#" width="120px;" /><br>
				</cfif>
				<cfif request.qSystemSetupOptions1.companyName NEQ ''>
					<strong>#request.qSystemSetupOptions1.companyName#</strong>
				</cfif>
				</div>
				 
				<div style="width:5%; float:left; margin-top:2%;"> Version 2.80.170308</div>
				<div style="clear:left;"></div>
				<table width="100%" border="0px" cellpadding="0px" style="height:100%;" cellspacing="0px"<cfif Not StructKeyExists(request, "content") And StructKeyExists(request, "tabs")> style="height:100%;"</cfif>>
					<tr>
						<td><table width="100%" border="0px" cellpadding="0px" cellspacing="0px">
								<tr>
									<td><cfif isdefined('session.passport.isLoggedIn') and session.passport.isLoggedIn>
											<table class="navigation" style="border-collapse:collapse; border:none;" border="0" cellpadding="0" cellspacing="0">
												<tr>
													<cfif Not structKeyExists(session, "IsCustomer")>
														<td><a href="index.cfm?event=myLoad&#Session.URLToken#" <cfif event is 'home'> class="active" </cfif>>Home</a></td>
														<cfif ListContains(session.rightsList,'addEditDeleteAgents',',')>
															<cfset agentUrl = "index.cfm?event=agent&sortorder=asc&sortby=Name&#Session.URLToken#">
														<cfelse>
															<cfset agentUrl = "javascript: alert('Sorry!! You do not have rights to the User screen.');">
														</cfif>
														<td><a href="#agentUrl#" <cfif event is 'agent' or event is 'addagent:process' or event is 'addagent'> class="active" </cfif>>Users</a></td>
														<td><a href="index.cfm?event=customer&#Session.URLToken#" <cfif event is 'customer' or event is 'addcustomer:process' or event is 'addcustomer' or event is 'stop' or event is 'addstop' or event is 'addstop:process'> class="active" </cfif>>Customers</a></td>
														<td>
															<a href="index.cfm?event=carrier&#Session.URLToken#" <cfif event is 'carrier' or event is 'addcarrier:process' or event is 'addcarrier' or event is 'equipment' or event is 'equipment:process' or event is 'addequipment'> class="active" </cfif>>
																<cfif request.qSystemSetupOptions1.freightBroker>
																	Carriers
																<cfelse>
																	Drivers																	
																</cfif>
															</a>
															<cfif not request.qSystemSetupOptions1.freightBroker>
																<cfif request.qryCountEquipments.COMPUTED_COLUMN_1  gt 0>
																	<a href="index.cfm?event=equipment&EquipmentMaint=1&#Session.URLToken#">
																		<span class="unReadMessage">
																			<span title="#request.qryCountEquipments.COMPUTED_COLUMN_1# Equipments Need maintenance" class="unread">#request.qryCountEquipments.COMPUTED_COLUMN_1#</span>
																		</span>
																	</a>
																</cfif>
															</cfif>	
														</td>
													</cfif>
													<td><a href="index.cfm?event=load&#Session.URLToken#" <cfif event is 'load' or event is 'addload:process' or event is 'unit' or event is 'class' or event is 'addload' or event is 'addunit:process' or event is 'addunit' or event is 'addclass:process' or event is 'addclass' or event is 'advancedsearch'> class="active" </cfif>>All Loads</a></td>
													<cfif Not structKeyExists(session, "IsCustomer")>
														<td><a href="index.cfm?event=myLoad&#Session.URLToken#" <cfif event is 'myLoad'> class="active" </cfif>>My Loads</a></td>
	                                                    <td><a href="index.cfm?event=dispatchboard&#Session.URLToken#" <cfif event is 'dispatchboard'> class="active" </cfif>>Dispatch Board</a></td>
	                                               		<cfif ListContains(session.rightsList,'runReports',',')>
															<cfset reportUrl = "index.cfm?event=reports&#Session.URLToken#">
														<cfelse>
															<cfset reportUrl = "javascript: alert('Sorry!! You don\'t have rights to run any reports.');">
														</cfif>
														<td><a href="#reportUrl#" <cfif event is 'reports'> class="active" </cfif>>Reports</a></td>
														<cfif ListContains(session.rightsList,'modifySystemSetup',',')>
															<cfset sysSetupUrl = "index.cfm?event=systemsetup&#Session.URLToken#">
														<cfelse>
															<cfset sysSetupUrl = "javascript: alert('Sorry!! You don\'t have rights to modify System Setup.');">
														</cfif>
														<td><a href="#sysSetupUrl#" <cfif event is 'systemsetup'> class="active" </cfif>>System Setup</a></td>
													</cfif>
													<td class="nobg"><a href="index.cfm?event=logout:process&#Session.URLToken#">Logout</a></td>													
												</tr>
											</table>
									 
											<div class="below-nav">
												#request.subnavigation#
												<div class="clear"></div>
											</div>
										</cfif>										
										</td>										
								</tr>
							</table>
						</td>
					</tr>					 
					<tr>
						<td valign="top">						
								<div class="content">
										</br></br>
										<div class="well waiting Waitmessage" style="margin-left:20% !important;color:green;font-size:13px !important;font-weight:bold;">
											
											<i class="fa fa-refresh fa-spin"></i>&nbsp;&nbsp;Please wait... We are updating SaferWatch data. 
													<br>&nbsp;&nbsp;&nbsp;&nbsp;This may take a few seconds to a couple of minutes, depending on response from Saferwatch API......</br>
																							
											<cfquery name="qrygetCarrierUpdateDate" datasource="#Application.dsn#">
												SELECT SaferWatchCarrierUpdatedDate FROM SystemConfig
												WHERE CompanyID = <cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar">
											</cfquery>	
											<br>
												Last Carrier Update On <b>#DateFormat(qrygetCarrierUpdateDate.SaferWatchCarrierUpdatedDate,'mm/dd/yyyy')# </b><br><br>
											
										</div>
										</br>
																	
									<!---<cfinvoke component="#variables.objloadGateway#" method="GetChangedCarriers" returnvariable="variables.message" />		
										---->
									<div class="well successMessage" style="margin-left:20% !important;color:green;font-size:15px !important;font-weight:bold;">
																
									</div>
									
								</div>															
							</td>
					</tr>
				</table>
			</div>
		</body>
	</html>
	
	<cfif structKeyExists(variables,"testTime")>
		<!---------To display the time taken to load-------->
		<div style="position:absolute;right:439px;margin-top:-15px;"><font size="4" weight="bold">Time taken to load: #testTime# milliseconds</font></div>
	</cfif>
</cfoutput>
<cfcatch type="coldfusion.runtime.RequestTimedOutException">
	SaferWatch API takes too long to respond.<cfabort>
</cfcatch>
</cftry>