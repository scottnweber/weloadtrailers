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
		.white-mid div.form-con fieldset label{
			font-size: 12px;
		}
		.white-mid form div.form-con fieldset select{
			font-size: 12px;
		}
		.white-mid form div.form-con fieldset input.sm-input{
			font-size: 12px;
		}
		.white-mid form div.form-con fieldset textarea{
			font-size: 12px;
		}
	</style>
	<div class="white-con-area" style="height: 36px;background-color: ##82bbef;">
		<div style="float: left;"><h2 style="color:white;font-weight:bold;margin-left: 12px;">Print/Email Customer Statement</h2></div>
	</div>
	<div style="clear:left"></div>

	<div class="white-con-area">
		<div class="white-top"></div>
	    <div class="white-mid" style="background-color: #request.qGetSystemSetupOptions.BackgroundColorForContentAccounting# !important;">
			<cfform name="frmCommissionReport" action="##" method="post">
				<div class="form-con">
					<fieldset style="padding:5px;float:left;">
						<h2 class="reportsSubHeading">Customer Range</h2>
						<div>
							<label style="width:40px;">From: </label>
							<cfselect name="customerFrom" id="customerFrom">
								<cfloop query="request.qryCustomersList">
									<option value="#request.qryCustomersList.customerid#">#request.qryCustomersList.customername#</option>
								</cfloop>
							</cfselect>
							<div class="clear"></div>
							<label style="width:40px;">To: </label>
							<cfselect name="customerTo" id="customerTo">
								<cfloop query="request.qryCustomersList">
									<option value="#request.qryCustomersList.customerid#" <cfif request.qryCustomersList.customerid EQ request.qryCustomersList.customerid[request.qryCustomersList.recordcount]>selected </cfif>>#request.qryCustomersList.customername#</option>
								</cfloop>
							</cfselect>
							<div class="clear"></div>
						</div>
					</fieldset>
					<div class="clear"></div>
					<fieldset style="padding:5px;float:left;width: 60%;">
						<h2 class="reportsSubHeading">Statement Date</h2>
                        <div >
                            <input class="sm-input datefield" tabindex=4 name="statementDate" id="statementDate"  value="#DateFormat(now(),"mm/dd/yyyy")#" validate="date" required="yes" message="Please enter a valid date" type="datefield" style="margin-left: 50px;width: 65px;"/>
                        </div>
						<div class="clear"></div>
					</fieldset>
					<div class="clear"></div>
					<fieldset style="padding:5px;float:left;">
			            <h2 class="reportsSubHeading">Comment</h2>
						<div>
							<textarea name="Comment" id="Comment" style="width:239px;"></textarea>
						</div>
					</fieldset>
				</div>
				<div class="form-con">
					<div class="right">
			        	<div>
							<input id="sReport" type="button" name="viewReport" class="bttn tooltip" value="Print" style="width:95px;height: 40px;background-size: contain;"/>
							<div class="clear"></div>
							<input id="eReport" type="button" name="mailReport" class="bttn tooltip" value="Email" style="width:95px;height: 40px;background-size: contain;"/>
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
					var url = "../reports/LMACustomerStatementReport.cfm?dsn=#dsn#";
					var e = document.getElementById("customerFrom");
					url += "&customerLimitFrom="+encodeURIComponent(trim(e.options[e.selectedIndex].text));
					e = document.getElementById("customerTo");
					url += "&customerLimitTo="+encodeURIComponent(trim(e.options[e.selectedIndex].text));
					url += "&statementDate="+$("##statementDate"). val();
					url += "&Comment="+$("##Comment"). val();
					url += '&#session.URLToken#'
					window.open(url);
			    }
			});
			$('##eReport').click(function(){	
			 	if(checkdate()){
					var url = "index.cfm?event=MailCustomerStatement&dsn=#dsn#";
					var e = document.getElementById("customerFrom");
					url += "&customerLimitFrom="+encodeURIComponent(trim(e.options[e.selectedIndex].text));
					e = document.getElementById("customerTo");
					url += "&customerLimitTo="+encodeURIComponent(trim(e.options[e.selectedIndex].text));
					url += "&statementDate="+$("##statementDate"). val();
					url += "&Comment="+$("##Comment"). val();
					url += '&#session.URLToken#'
					newwindow=window.open(url,'Map','height=550,width=750');
		            if (window.focus) {
		                newwindow.focus()
		            }
			    }
			});
		});		

		function checkdate(){
			var reg =/((^(10|12|0?[13578])([/])(3[01]|[12][0-9]|0?[1-9])([/])((1[8-9]\d{2})|([2-9]\d{3}))$)|(^(11|0?[469])([/])(30|[12][0-9]|0?[1-9])([/])((1[8-9]\d{2})|([2-9]\d{3}))$)|(^(0?2)([/])(2[0-8]|1[0-9]|0?[1-9])([/])((1[8-9]\d{2})|([2-9]\d{3}))$)|(^(0?2)([/])(29)([/])([2468][048]00)$)|(^(0?2)([/])(29)([/])([3579][26]00)$)|(^(0?2)([/])(29)([/])([1][89][0][48])$)|(^(0?2)([/])(29)([/])([2-9][0-9][0][48])$)|(^(0?2)([/])(29)([/])([1][89][2468][048])$)|(^(0?2)([/])(29)([/])([2-9][0-9][2468][048])$)|(^(0?2)([/])(29)([/])([1][89][13579][26])$)|(^(0?2)([/])(29)([/])([2-9][0-9][13579][26])$))/;
			    
	    	if($('##statementDate').val().length){
	    		if(!$('##statementDate').val().match(reg)){
	    			alert('Please enter a valid date.');
	    			$('##statementDate').focus();
	    			$('##statementDate').val('');
	    			return false;
	    		}
	    	}	
	
            return true;
		}
		
	</script>
</cfoutput>