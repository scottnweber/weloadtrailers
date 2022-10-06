<cfset Secret = application.dsn>
<cfset TheKey = 'NAMASKARAM'>
<cfset Encrypted = Encrypt(Secret, TheKey)>
<cfset dsn = ToBase64(Encrypted)>
<cfscript>
	variables.objCutomerGateway = getGateway("gateways.customergateway", MakeParameters("dsn=#Application.dsn#,pwdExpiryDays=#Application.pwdExpiryDays#"));
</cfscript>
<cfsilent>
	<cfinvoke component="#variables.objCutomerGateway#" method="getAllpayerCustomers" returnvariable="request.qryCustomersList" />
	<cfinvoke component="#variables.objloadGateway#" method="getSystemSetupOptions" returnvariable="request.qGetSystemSetupOptions" />
</cfsilent>

<cfoutput>
	<style type="text/css">
		.reportsSubHeading{
			border-bottom: 1px solid ##77463d !important;
			margin-bottom: 5px !important;
		}
		.white-mid div.form-con fieldset label.space_it{
			font-size: 12px;
		}
		.white-mid form div.form-con fieldset input.sm-input{
			font-size: 12px;
			width: 60px;
		}
		.white-mid form div.form-con fieldset select{
			font-size: 12px;
		}
		.white-mid form div.form-con fieldset label.normal{
			font-size: 12px;
		}
	</style>
	<div class="white-con-area" style="height: 36px;background-color: ##82bbef;">
		<div style="float: left;">
			<h2 style="color:white;font-weight:bold;margin-left: 12px;">Print Customer Payments</h2>
		</div>
	</div>
	<div style="clear:left"></div>

	<div class="white-con-area">
		<div class="white-top"></div>
	    <div class="white-mid" style="background-color: #request.qGetSystemSetupOptions.BackgroundColorForContentAccounting# !important;">
			<cfform name="frmCommissionReport" action="##" method="post">
				<div class="form-con">
					<fieldset>
						<h2 class="reportsSubHeading">Date Range</h2>
			            <label class="space_it" style="width: 102px;">From</label>
                        <div style="position:relative;float:left;">
                            <div style="float:left;">
                                <input class="sm-input datefield" tabindex=4 name="dateFrom" id="dateFrom"  value="" validate="date" required="yes" message="Please enter a valid date" type="datefield" />
                            </div>
                        </div>
                        <label style="width: 24px;">To</label>
                        <div style="position:relative;float:left;">
                            <div style="float:left;">
                                <input class="sm-input datefield" tabindex=4 name="dateTo" id="dateTo"  value="" validate="date" required="yes" message="Please enter a valid date" type="datefield" />
                            </div>
                        </div>
                        <div class="clear"></div>
			            <h2 class="reportsSubHeading">Customer</h2>
						<div>
							<label>From </label>
							<cfselect name="customerFrom" id="customerFrom">
								<cfloop query="request.qryCustomersList">
									<option value="#request.qryCustomersList.customerid#">#request.qryCustomersList.customername#</option>
								</cfloop>
							</cfselect>
							<div class="clear"></div>
							<label>To </label>
							<cfselect name="customerTo" id="customerTo">
								<cfloop query="request.qryCustomersList">
									<option value="#request.qryCustomersList.customerid#" <cfif request.qryCustomersList.customerid EQ request.qryCustomersList.customerid[request.qryCustomersList.recordcount]>selected </cfif>>#request.qryCustomersList.customername#</option>
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
			                <label class="normal" for="Detail" style="text-align:left; padding:0 0 0 0;width: 100px;" >Detail</label>
			            </div>
			            <div style="float:left;margin-bottom: 10px;">
			                <cfinput type="radio" name="reportType" value="Summary" id="Summary"  style="width:15px; padding:0px 0px 0 0px;margin-bottom:1px;"/>
			                <label class="normal" for="Summary" style="text-align:left; padding:0 0 0 0;width: 100px;" >Summary</label>
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
			  buttonImageOnly: true,
                showButtonPanel: true,
                todayBtn:'linked',
                onClose: function ()
                {
                    this.focus();
                }
			});
			$.datepicker._gotoToday = function(id) { 
                $(id).datepicker('setDate', new Date()).datepicker('hide').blur().change(); 
            };

			$('##sReport').click(function(){	
			 	if(checkdate()){
					var url = "../reports/LMAPrintCashReceipts.cfm?dsn=#dsn#";
					url += "&dateFrom="+$("##dateFrom"). val();
					url += "&dateTo="+$("##dateTo"). val();
					var e = document.getElementById("customerFrom");
					url += "&customerLimitFrom="+encodeURIComponent(trim(e.options[e.selectedIndex].text));
					e = document.getElementById("customerTo");
					url += "&customerLimitTo="+encodeURIComponent(trim(e.options[e.selectedIndex].text));
					url += "&reportType="+$("input[name='reportType']:checked"). val();
					url += '&#session.URLToken#'
					window.open(url);
			    }
			});
		});		

		function checkdate(){
			var reg =/((^(10|12|0?[13578])([/])(3[01]|[12][0-9]|0?[1-9])([/])((1[8-9]\d{2})|([2-9]\d{3}))$)|(^(11|0?[469])([/])(30|[12][0-9]|0?[1-9])([/])((1[8-9]\d{2})|([2-9]\d{3}))$)|(^(0?2)([/])(2[0-8]|1[0-9]|0?[1-9])([/])((1[8-9]\d{2})|([2-9]\d{3}))$)|(^(0?2)([/])(29)([/])([2468][048]00)$)|(^(0?2)([/])(29)([/])([3579][26]00)$)|(^(0?2)([/])(29)([/])([1][89][0][48])$)|(^(0?2)([/])(29)([/])([2-9][0-9][0][48])$)|(^(0?2)([/])(29)([/])([1][89][2468][048])$)|(^(0?2)([/])(29)([/])([2-9][0-9][2468][048])$)|(^(0?2)([/])(29)([/])([1][89][13579][26])$)|(^(0?2)([/])(29)([/])([2-9][0-9][13579][26])$))/;
			    
	    	if($('##dateFrom').val().length){
	    		if(!$('##dateFrom').val().match(reg)){
	    			alert('Please enter a valid date.');
	    			$('##dateFrom').focus();
	    			$('##dateFrom').val('');
	    			return false;
	    		}
	    	}	

	    	if($('##dateTo').val().length){
	    		if(!$('##dateTo').val().match(reg)){
	    			alert('Please enter a valid date.');
	    			 $('##dateTo').focus();
	    			$('##dateTo').val('');
	    			return false;
	    		}
	    	}	
            return true;
		}
	</script>
</cfoutput>