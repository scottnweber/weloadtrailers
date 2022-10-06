<cfset Secret = application.dsn>
<cfset TheKey = 'NAMASKARAM'>
<cfset Encrypted = Encrypt(Secret, TheKey)>
<cfset dsn = ToBase64(Encrypted)>
<cfscript>
	variables.objCutomerGateway = getGateway("gateways.customergateway", MakeParameters("dsn=#Application.dsn#,pwdExpiryDays=#Application.pwdExpiryDays#"));
</cfscript>
<cfsilent>
	<cfinvoke component="#variables.objCutomerGateway#" method="getAllpayerCustomers" returnvariable="request.qryCustomersList" />
	<cfinvoke component="#variables.objCarrierGateway#" method="getAllCarriersForReport" returnvariable="request.qCarrier"></cfinvoke>
	<cfinvoke component="#variables.objloadGateway#" method="getSystemSetupOptions" returnvariable="request.qGetSystemSetupOptions" />
	<cfinvoke component="#variables.objLoadGateway#" method="getCheckRegisterSetup" returnvariable="qCheckRegisterSetup" />
</cfsilent>

<cfoutput>
	<style type="text/css">
		.reportsSubHeading{
			border-bottom: 1px solid ##77463d !important;
			margin-bottom: 5px !important;
		}
		.white-mid div.form-con fieldset label{
			font-size: 12px;
		}
		.white-mid form div.form-con fieldset select{
			font-size: 12px;
		}
		.white-mid form div.form-con fieldset label.normal{
			font-size: 12px;
		}
	</style>
	<div class="white-con-area" style="height: 36px;background-color: ##82bbef;">
		<div style="float: left;"><h2 style="color:white;font-weight:bold;margin-left: 12px;">Invoices Picked to Pay</h2></div>
	</div>
	<div style="clear:left"></div>

	<div class="white-con-area">
		<div class="white-top"></div>
	    <div class="white-mid" style="background-color: #request.qGetSystemSetupOptions.BackgroundColorForContentAccounting# !important;">
			<cfform name="frmCommissionReport" action="##" method="post">
				<div class="form-con">
					<fieldset>
			            <h2 class="reportsSubHeading">Vendor</h2>
						<div>
							<label>From </label>
							<cfselect name="carrierFrom" id="carrierFrom">
								<cfloop query="request.qCarrier">
									<option value="#request.qCarrier.carrierID#">#request.qCarrier.CarrierName#</option>
								</cfloop>
							</cfselect>
							<div class="clear"></div>
							<label>To </label>
							<cfselect name="carrierTo" id="carrierTo">
								<cfloop query="request.qCarrier">
									<option value="#request.qCarrier.carrierID#" <cfif request.qCarrier.carrierID EQ request.qCarrier.carrierID[request.qCarrier.recordcount]>selected </cfif>>#request.qCarrier.CarrierName#</option>
								</cfloop>
								<cfloop query="request.qryCustomersList">
									<option value="#request.qryCustomersList.customerid#" <cfif request.qryCustomersList.customerid EQ request.qryCustomersList.customerid[request.qryCustomersList.recordcount]>selected </cfif>>#request.qryCustomersList.customername#</option>
								</cfloop>
							</cfselect>
							<div class="clear"></div>
						</div>
						<div class="clear"></div>
						<h2 class="reportsSubHeading">Account</h2>
						<div>
							<label>From </label>
							<cfselect name="AccountFrom" id="AccountFrom">
								<cfif not qCheckRegisterSetup.recordcount>
									<option value=""></option>
								</cfif>
								<cfloop query ="qCheckRegisterSetup">
	                                <option value="#qCheckRegisterSetup.AccountCode#">#qCheckRegisterSetup.AccountCode# #qCheckRegisterSetup.AccountName#</option>
	                            </cfloop>
							</cfselect>
							<div class="clear"></div>
							<label>To </label>
							<cfselect name="AccountTo" id="AccountTo">
								<cfif not qCheckRegisterSetup.recordcount>
									<option value=""></option>
								</cfif>
								<cfloop query ="qCheckRegisterSetup">
	                                <option value="#qCheckRegisterSetup.AccountCode#" <cfif qCheckRegisterSetup.currentrow eq qCheckRegisterSetup.recordcount>selected </cfif> >#qCheckRegisterSetup.AccountCode# #qCheckRegisterSetup.AccountName#</option>
	                            </cfloop>
							</cfselect>
							<div class="clear"></div>
						</div>
						<div class="clear"></div>
						<h2 class="reportsSubHeading">Report Type</h2>
						<div class="clear"></div>
	            		<div style="width:110px; float:left;">&nbsp;</div>
	           			<div style="float:left;">
			                <cfinput type="radio" name="reportType" value="Detail" id="Detail"  style="width:15px; padding:0px 0px 0 0px;margin-bottom:1px;" checked/>
			                <label class="normal" for="Detail" style="text-align:left; padding:0 0 0 0;width:100px;" >Detail</label>
			            </div>
			            <div style="float:left;margin-bottom: 10px;">
			                <cfinput type="radio" name="reportType" value="Summary" id="Summary"  style="width:15px; padding:0px 0px 0 0px;margin-bottom:1px;"/>
			                <label class="normal" for="Summary" style="text-align:left; padding:0 0 0 0;width:100px;" >Summary</label>
			            </div>	
					</fieldset>
				</div>
				<div class="form-con">
					<div class="right">
			        	<div>
							<input id="sReport" type="button" name="viewReport" class="bttn tooltip" value="Print" style="width:95px;height: 40px;background-size: contain;"/>
			        	</div>
				    </div>
				</div>
	   			<div class="clear"></div>
	 		</cfform>
	    </div>
		<div class="white-bot"></div>
	</div>

	<script type="text/javascript">
		$(document).ready(function(){
			$( "[type='datefield']" ).datepicker({
			  dateFormat: "mm/dd/yy",
			  showOn: "button",
			  buttonImage: "images/DateChooser.png",
			  buttonImageOnly: true
			});
			$("input[name='reportType']").click(function(){
				if($(this).val()=='Summary'){
					$("input[name='sortBy']").prop("disabled", true)
				}
				else{
					$("input[name='sortBy']").prop("disabled", false)
				}
			});


			$('##sReport').click(function(){	
				var url = "../reports/LMAInvoicesPickedtoPay.cfm?dsn=#dsn#";
				var e = document.getElementById("carrierFrom");
				url += "&carrierLimitFrom="+encodeURIComponent(trim(e.options[e.selectedIndex].text));
				e = document.getElementById("carrierTo");
				url += "&carrierLimitTo="+encodeURIComponent(trim(e.options[e.selectedIndex].text));
				url += "&reportType="+$("input[name='reportType']:checked"). val();
				url += "&accountFrom="+$("##AccountFrom").val();
				url += "&AccountTo="+$("##AccountTo").val();
				url += '&#session.URLToken#'
				window.open(url);
			});
		});		
	</script>
</cfoutput>