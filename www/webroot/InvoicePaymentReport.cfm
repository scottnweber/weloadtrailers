<cfset Secret = application.dsn>
<cfset TheKey = 'NAMASKARAM'>
<cfset Encrypted = Encrypt(Secret, TheKey)>
<cfset dsn = ToBase64(Encrypted)>
<cfsilent>
	<cfinvoke component="#variables.objCarrierGateway#" method="getAllCarriersForReport" returnvariable="request.qCarrier"></cfinvoke>
	<cfinvoke component="#variables.objloadGateway#" method="getSystemSetupOptions" returnvariable="request.qGetSystemSetupOptions" />
	<cfinvoke component="#variables.objLoadGateway#" method="getCheckRegisterSetup" returnvariable="qCheckRegisterSetup" />
	<cfinvoke component="#variables.objLoadGateway#" method="getChecksList" returnvariable="qChecksList" />
</cfsilent>

<cfoutput>
	<style type="text/css">
		.reportsSubHeading{
			border-bottom: 1px solid ##77463d !important;
			margin-bottom: 5px !important;
		}
		.white-mid form div.form-con fieldset input.sm-input{
			font-size: 12px;
			width: 60px;
		}
		.white-mid form div.form-con fieldset select{
			font-size: 12px;
		}
		.white-mid div.form-con fieldset label.space_it{
			font-size: 12px;
		}
		.white-mid form div.form-con fieldset label.normal{
			font-size: 12px;
		}
	</style>
	<div class="white-con-area" style="height: 36px;background-color: ##82bbef;">
		<div style="float: left;"><h2 style="color:white;font-weight:bold;margin-left: 12px;">Invoice Payment Report</h2></div>
	</div>
	<div style="clear:left"></div>

	<div class="white-con-area">
		<div class="white-top"></div>
	    <div class="white-mid" style="background-color: #request.qGetSystemSetupOptions.BackgroundColorForContentAccounting# !important;">
			<cfform name="frmCommissionReport" action="##" method="post">
				<div class="form-con">
					<fieldset>
                        <h2 class="reportsSubHeading">Bank Account</h2>
						<div>
							<label>From </label>
							<cfselect name="BankAccountFrom" id="BankAccountFrom" style="width: 88px;">
								<cfloop query ="qCheckRegisterSetup">
	                                <option value="#qCheckRegisterSetup.AccountCode#">#qCheckRegisterSetup.AccountCode# #qCheckRegisterSetup.AccountName#</option>
	                            </cfloop>
							</cfselect>

							<label style="width: 25px;">To </label>
							<cfselect name="BankAccountTo" id="BankAccountTo" style="width: 88px;">
								<cfloop query ="qCheckRegisterSetup">
	                                <option value="#qCheckRegisterSetup.AccountCode#" <cfif qCheckRegisterSetup.AccountCode EQ qCheckRegisterSetup.AccountCode[qCheckRegisterSetup.recordcount]>selected </cfif>>#qCheckRegisterSetup.AccountCode# #qCheckRegisterSetup.AccountName#</option>
	                            </cfloop>
							</cfselect>
							<div class="clear"></div>
						</div>
						<div class="clear"></div>
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
									<option value="#request.qCarrier.carrierID#" <cfif request.qCarrier.carrierID EQ request.qCarrier.carrierID[request.qCarrier.recordcount-1]>selected </cfif>>#request.qCarrier.CarrierName#</option>
								</cfloop>
							</cfselect>
							<div class="clear"></div>
						</div>
						<div class="clear"></div>
						<h2 class="reportsSubHeading">Check##</h2>
						<div>
							<label>From </label>
							<input class="sm-input checkNo" name="checkNoFrom" id="checkNoFrom"  value=""  type="text"/>
							<label style="width: 25px;">To </label>
							<input class="sm-input checkNo"name="checkNoTo" id="checkNoTo"  value=""  type="text"/>
							<div class="clear"></div>
						</div>
						<h2 class="reportsSubHeading">Check Date</h2>
			            <label class="space_it" style="width: 102px;">From</label>
                        <div style="position:relative;float:left;">
                            <div style="float:left;">
                                <input class="sm-input datefield" name="checkDateFrom" id="checkDateFrom" value="" type="datefield" />
                            </div>
                        </div>
                        <label style="width: 24px;">To</label>
                        <div style="position:relative;float:left;">
                            <div style="float:left;">
                                <input class="sm-input datefield" name="checkDateTo" id="checkDateTo"  value="" type="datefield" />
                            </div>
                        </div>
                        <div class="clear"></div><h2 class="reportsSubHeading">Entry Date</h2>
			            <label class="space_it" style="width: 102px;">From</label>
                        <div style="position:relative;float:left;">
                            <div style="float:left;">
                                <input class="sm-input datefield" name="entryDateFrom" id="entryDateFrom"  value="" type="datefield" />
                            </div>
                        </div>
                        <label style="width: 24px;">To</label>
                        <div style="position:relative;float:left;">
                            <div style="float:left;">
                                <input class="sm-input datefield" name="entryDateTo" id="entryDateTo"  value="" type="datefield" />
                            </div>
                        </div>
	    				<div class="clear"></div>
					</fieldset>
				</div>
				<div class="form-con">
					<fieldset>
						<h2 class="reportsSubHeading">Type</h2>
                        <div>
                        	<input type="checkbox" name="showVoidedOnly" id="showVoidedOnly" style="float: left;width: 15px;margin-left: 73px;">
                        	<label style="width:133px;">Show Voided Check Only</label>
                           	
                        </div>
                        <div class="clear"></div>
                        <div>
                        	<input type="checkbox" name="groupByBankAcc" id="groupByBankAcc" style="float: left;width: 15px;margin-left: 73px;">
                        	<label style="width:130px;">Group By Bank Account</label>
                        </div>
                        <div class="clear"></div>

						<h2 class="reportsSubHeading">Report Type</h2>
						<div class="clear"></div>
	            		<div style="width:110px; float:left;">&nbsp;</div>
	           			<div style="float:left;">
			                <cfinput type="radio" name="reportType" value="Detail" id="Detail"  style="width:15px; padding:0px 0px 0 0px;margin-bottom:1px;" checked/>
			                <label class="normal" for="Detail" style="text-align:left; padding:0 0 0 0;width: 100px;" >Detail</label>
			            </div>
			            <div style="float:left;">
			                <cfinput type="radio" name="reportType" value="Summary" id="Summary"  style="width:15px; padding:0px 0px 0 0px;margin-bottom:1px;"/>
			                <label class="normal" for="Summary" style="text-align:left; padding:0 0 0 0;width: 100px;" >Summary</label>
			            </div>
			            <div class="clear"></div>
	    				<h2 class="reportsSubHeading">Sort By</h2>
						<div class="clear"></div>
	            		<div style="width:110px; float:left;">&nbsp;</div>
	           			<div style="float:left;">
			                <cfinput type="radio" name="sortBy" value="CheckNo" id="CheckNo"  style="width:15px; padding:0px 0px 0 0px;margin-bottom:1px;" checked/>
			                <label class="normal" for="Date" style="text-align:left; padding:0 0 0 0;width: 100px;" >Check##</label>
			            </div>
			            <div style="float:left;">
			                <cfinput type="radio" name="sortBy" value="VendorName" id="VendorName"  style="width:15px; padding:0px 0px 0 0px;margin-bottom:1px;"/>
			                <label class="normal" for="Invoice" style="text-align:left; padding:0 0 0 0;width: 100px;" >Vendor Name</label>
			            </div>
			            <div class="clear"></div>
							<input id="sReport" type="button" name="viewReport" class="bttn tooltip" value="Print" style="width:95px;height: 40px;background-size: contain;margin-top: 50px;margin-left: 50px;"/>
					</fieldset>
				</div>
	   			<div class="clear"></div>
	 		</cfform>
	    </div>
		<div class="white-bot"></div>
	</div>

	<script type="text/javascript">
		$(document).ready(function(){

			var sourceJson = [
            <cfloop query="qChecksList">
                {label: "#qChecksList.CheckNumber#", value: "#qChecksList.CheckNumber#", date:"#dateformat(qChecksList.CheckDate,'mm/dd/yyyy')#",amount:"#qChecksList.amount#"},
            </cfloop>
            ]

			$('.checkNo').each(function(i, tag) {
				$(tag).autocomplete({
                    multiple: false,
                    width: 400,
                    scroll: true,
                    scrollHeight: 300,
                    cacheLength: 1,
                    highlight: false,
                    dataType: "json",
                    source: sourceJson,
                    focus: function( event, ui ) {
                    },
                    change: function(event,ui){
                    },
                    select: function(e, ui) {
                    }  
                });

                $(tag).data("ui-autocomplete")._renderItem = function(ul, item) {
		            return $( "<li><b><u>Check##</u>:</b> "+ item.value+"&nbsp;&nbsp;&nbsp;<b><u>Date</u>:</b>" + item.date+"&nbsp;&nbsp;&nbsp;<b><u>Amount</u>:</b> " + item.amount+"</li>" )
		                    .appendTo( ul );
		        }
			})

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
				var BankAccountFrom = $("##BankAccountFrom"). val();
				var BankAccountTo = $("##BankAccountTo"). val();
				if( typeof BankAccountFrom === 'undefined' || BankAccountFrom === null || typeof BankAccountTo === 'undefined' || BankAccountTo === null){
				    alert('Unable to generate report. Invalid bank accounts.');
				    return false;
				}

			 	//if(checkdate()){
			 		if($("input[name='reportType']:checked"). val()=='Detail'){
			 			var url = "../reports/InvoicePaymentReport.cfm?";
			 		}
			 		else{
			 			var url = "../reports/InvoicePaymentReportSummary.cfm?";
			 		}
					

					url += "&BankAccountFrom="+$("##BankAccountFrom"). val();
					url += "&BankAccountTo="+$("##BankAccountTo"). val();

					var e = document.getElementById("carrierFrom");
					url += "&carrierFrom="+encodeURIComponent(trim(e.options[e.selectedIndex].text));
					e = document.getElementById("carrierTo");
					url += "&carrierTo="+encodeURIComponent(trim(e.options[e.selectedIndex].text));

					url += "&checkNoFrom="+$("##checkNoFrom"). val();
					url += "&checkNoTo="+$("##checkNoTo"). val();

					url += "&checkDateFrom="+$("##checkDateFrom"). val();
					url += "&checkDateTo="+$("##checkDateTo"). val();

					url += "&entryDateFrom="+$("##entryDateFrom"). val();
					url += "&entryDateTo="+$("##entryDateTo"). val();

		
					url += "&reportType="+$("input[name='reportType']:checked"). val();

					url += "&sortBy="+$("input[name='sortBy']:checked"). val();

					if ($('##showVoidedOnly').is(':checked')) {
						url += "&showVoidedOnly=1";
					}
					
					if ($('##groupByBankAcc').is(':checked')) {
						url += "&groupBybank=1";
					}

					url += '&#session.URLToken#'
					window.open(url);
			    //}
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