<cfoutput>
	<cfsilent>
<!--- default value------->
		<cfparam name="UnitCode" default="">
		<cfparam name="UnitName" default="">
		<cfparam name="Status" default="1">
		<cfparam name="IsFee" default="0">
		<cfparam name="CustomerRate" default="0.00">
		<cfparam name="CarrierRate" default="0.00">
		<cfparam name="url.editid" default="0">
		<cfparam name="url.unitid" default="0">
		<cfparam name="variables.paymentAdvanceCheck" default="0">
		<cfparam name="HideOnCustomerInvoice" default="0">
		<cfparam name="GLSalesAccount" default="">
		<cfparam name="GLExpenseAccount" default="">
		<cfparam name="GLBankAccount" default="">
		<cfinvoke component="#variables.objloadGateway#" method="getSystemSetupOptions" returnvariable="request.qSystemSetupOptions" /> 
		<cfinvoke component="#variables.objLoadGateway#" method="getAcctDeptList" returnvariable="qAcctDeptList" />

		<cfif isdefined("url.unitid") and len(trim(url.unitid)) gt 1>
			<cfinvoke component="#variables.objunitGateway#" method="getAllUnits" UnitID="#url.unitid#" returnvariable="request.qUnits" />

			<cfif request.qUnits.recordcount eq 1>
				<cfset UnitCode=#request.qUnits.UnitCode#>
				<cfset UnitName=#request.qUnits.UnitName#>
				<cfset Status=#request.qUnits.IsActive#>
				<cfset IsFee =#request.qUnits.IsFee#>
				<cfset editid=#request.qUnits.UnitID#>
				<cfset CustomerRate=#request.qUnits.CustomerRate#>
				<cfset CarrierRate=#request.qUnits.CarrierRate#>
				<cfset variables.paymentAdvanceCheck =request.qUnits.PAYMENTADVANCE>
				<cfset HideOnCustomerInvoice =#request.qUnits.HideOnCustomerInvoice#>
				<cfset GLSalesAccount =request.qUnits.GLSalesAccount>
				<cfset GLExpenseAccount =request.qUnits.GLExpenseAccount>
				<cfset GLBankAccount =request.qUnits.GLBankAccount>
			</cfif>
		</cfif>
	</cfsilent>
	<script>
        $(document).ready(function(){
            $( "##paymentAdvance" ).click(function() {
				if($(this).prop("checked")){
					$('##paymentAdvanceChecked').show();
					$('##paymentAdvanceUnChecked').hide();
				}
				else{
					$('##paymentAdvanceChecked').hide();
					$('##paymentAdvanceUnChecked').show();
				}
			});

            $('.dollarFormatRate').change(function(){
            	var rate = $(this).val();
            	var Dmask = new RegExp("^[+-]?(?:[$]|)[0-9]{1,6}(?:[0-9]*(?:[.,][0-9]{1})?|(?:,[0-9]{3})*(?:\.[0-9]{1,2})?|(?:\.[0-9]{3})*(?:,[0-9]{1,2})?)$");
            	if(!Dmask.test(rate.trim())){
            		alert('Invalid Rate.');
            		$(this).focus();
            	}
            })
            
        });
    </script>
	<cfif isdefined("url.unitid") and len(trim(url.unitid)) gt 1>
		<div class="white-con-area" style="height: 36px;background-color: ##82bbef;">
			<div class="search-panel"><div class="delbutton"><a href="index.cfm?event=unit&unitid=#editid#&#session.URLToken#" onclick="return confirm('Are you sure to delete it ?');">  Delete</a></div></div>	
			<div style="float: left;"><h2 style="color:white;font-weight:bold;margin-left: 12px;">Edit Unit <span style="padding-left:180px;">#Ucase(UnitName)#</span></h2></div>
		</div>
		<div style="clear:left;"></div>
	<cfelse>
		<div class="white-con-area" style="height: 36px;background-color: ##82bbef;">
			<div style="float: left;"><h2 style="color:white;font-weight:bold;margin-left: 12px;">Add New Unit</h2></div>
		</div>
		<div style="clear:left;"></div>
	</cfif>
	<div class="white-con-area">
		<div class="white-top"></div>
		<div class="white-mid">
			<cfform name="frmUnit" action="index.cfm?event=addunit:process&editid=#editid#&#session.URLToken#" method="post">
				<cfinput type="hidden" name="editid" value="#editid#">
				<div class="form-con">
					<fieldset>  
						<label><strong>Type*</strong></label>
						<cfinput type="text" name="UnitName" value="#UnitName#" size="25" required="yes" message="Please  enter the name" maxlength="100">
						<div class="clear"></div>
						<label><strong>Description*</strong></label>
						<cfinput type="text" name="UnitCode" value="#UnitCode#" size="25" required="yes" message="Please  enter the unit code" maxlength="20">  
						<div class="clear"></div>
						<label><strong>Active</strong></label>
						<cfif val(Status)>
							<cfinput type="checkbox" name="Status" value="1" style="margin-left: -85px;" checked/>
						<cfelse>
							<cfinput type="checkbox" name="Status" value="1" style="margin-left: -85px;" />
						</cfif>
						<span class="clear"></span>
						<label class="feetext"><strong>Fee</strong></label>
						<cfif val(IsFee)>
							<cfinput type="checkbox" name="IsFee" value="1" style="margin-left: -85px;" checked/>
						<cfelse>
							<cfinput type="checkbox" name="IsFee" value="1" style="margin-left: -85px;" />
						</cfif>
						<label>Payment Advance</label>
						<cfif val(variables.paymentAdvanceCheck)>
							<cfinput type="checkbox" name="paymentAdvance" value="1" style="margin-left: -85px;" checked/>
						<cfelse>
							<cfinput type="checkbox" name="paymentAdvance" value="1" style="margin-left: -85px;" />
						</cfif>
						<div class="clear"></div>
						<label>Hide on Customer Invoice</label>
						<cfif val(HideOnCustomerInvoice)>
							<cfinput type="checkbox" name="HideOnCustomerInvoice" value="1" style="margin-left: -85px;" checked/>
						<cfelse>
							<cfinput type="checkbox" name="HideOnCustomerInvoice" value="1" style="margin-left: -85px;" />
						</cfif>
					</fieldset>
				</div>
				<div class="form-con">
					<fieldset>
						<label class="ratefield"><strong>Customer Rate*</strong></label>
						<cfinput type="text" name="CustomerRate" value="#replace("$#Numberformat(customerrate,"___.__")#", " ", "", "ALL")#" size="25" required="yes" message="Please  enter the Customer Rate" class="activeTextField dollarFormatRate">
						
						<div class="clear"></div>
						<label class="ratefield"><strong><cfif request.qSystemSetupOptions.freightBroker>Carrier<cfelse>Driver</cfif> Rate*</strong></label>
						<cfinput type="text" name="CarrierRate" value="#replace("$#Numberformat(carrierrate,"___.__")#", " ", "", "ALL")#" size="25" required="yes" message="Please  enter the Carrier Rate" class="activeTextField dollarFormatRate">
						<div class="clear"></div>

						<div <cfif NOT ListContains(session.rightsList,'Accounting',',')>style="display:none;"</cfif>>
							<div id="paymentAdvanceUnChecked" <cfif val(variables.paymentAdvanceCheck)> style="display:none;" </cfif>>
								<label class="ratefield"><strong>Sales</strong></label>
								<select name="GLSalesAccount" style="width:75px;">
									<option value=""></option>
									<cfloop query="qAcctDeptList">
										<option value="#qAcctDeptList.gl_acct#" <cfif qAcctDeptList.gl_acct eq GLSalesAccount> selected </cfif>>#qAcctDeptList.gl_acct#</option>
									</cfloop>
								</select>
								<div class="clear"></div>
								
								<label class="ratefield"><strong>Cost of Sales</strong></label>
								<select name="GLExpenseAccount" style="width:75px;">
									<option value=""></option>
									<cfloop query="qAcctDeptList">
										<option value="#qAcctDeptList.gl_acct#" <cfif qAcctDeptList.gl_acct eq GLExpenseAccount> selected </cfif>>#qAcctDeptList.gl_acct#</option>
									</cfloop>
								</select>
								<div class="clear"></div>
							</div>
							
							<div id="paymentAdvanceChecked" <cfif not val(variables.paymentAdvanceCheck)> style="display:none;" </cfif>>
								<label class="ratefield"><strong>Bank Account</strong></label>
								<select name="GLBankAccount" style="width:75px;">
									<option value=""></option>
									<cfloop query="qAcctDeptList">
										<option value="#qAcctDeptList.gl_acct#" <cfif qAcctDeptList.gl_acct eq GLBankAccount> selected </cfif>>#qAcctDeptList.gl_acct#</option>
									</cfloop>
								</select>
								<div class="clear"></div>
							</div>
						</div>
						<div style="padding-left:150px;"><input  type="submit" name="submit" onclick="return validateUnit(frmUnit);" class="bttn" value="Save Unit" style="width:112px;" /><input  type="button" onclick="javascript:history.back();" name="back" class="bttn" value="Back" style="width:70px;" /></div>
						<div class="clear"></div>  		
					</fieldset>
				</div>
			</cfform>
			<div class="clear"></div>
			<cfif isDefined("url.unitid") and len(url.unitid) gt 1>
				<p id="footer" style="padding-left:10px;font-family:Verdana, Geneva, sans-serif; font-style:italic bold; text-transform:uppercase;font-family:Verdana, Geneva, sans-serif; font-style:italic; text-transform:uppercase;width:80%;">Last Updated:<cfif isDefined("request.qUnits")>&nbsp;&nbsp;&nbsp; #request.qUnits.LastModifiedDateTime#&nbsp;&nbsp;&nbsp;#request.qUnits.LastModifiedBy#</cfif></p>
			</cfif>
		</div>
		<div class="white-bot"></div>
	</div>
</cfoutput>


