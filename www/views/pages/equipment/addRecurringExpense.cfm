<cfparam name="description" default="">
<cfparam name="amount" default="">
<cfparam name="category" default="">
<cfparam name="date" default="">
<cfparam name="interval" default="0">
<cfparam name="url.carrierExpenseRecurringID" default="">
<cfoutput>
<cfsilent>
	<cfif structkeyexists(url,"carrierExpenseRecurringID") and len(trim(url.carrierExpenseRecurringID)) gt 0>
		<cfinvoke component="#variables.objequipmentGateway#" method="getRecurringCarrierExpenseInformation" carrierExpenseRecurringID="#url.carrierExpenseRecurringID#"returnvariable="request.qGetRecurringCarrierExpenseInformation" />
		<cfif request.qGetRecurringCarrierExpenseInformation.recordcount>
			<cfset  description = request.qGetRecurringCarrierExpenseInformation.description>
			<cfset  amount = request.qGetRecurringCarrierExpenseInformation.amount>
			<cfset  category = request.qGetRecurringCarrierExpenseInformation.category>
			<cfset  date = request.qGetRecurringCarrierExpenseInformation.nextdate>
			<cfset  interval = request.qGetRecurringCarrierExpenseInformation.interval>
		</cfif>
	</cfif>	
</cfsilent>
<cfif structkeyexists(url,"carrierExpenseRecurringID") and len(trim(url.carrierExpenseRecurringID)) gt 0>
	<div class="search-panel">
		<div class="delbutton">
			<a href="index.cfm?event=delRecurringDriverExpense&carrierExpenseRecurringID=#url.carrierExpenseRecurringID#&driverid=#url.driverid#&#session.URLToken##iscarrier#" onclick="return confirm('Are you sure to delete it ?');">
			Delete 
			</a>
		</div>
	</div>	
	<div class="white-con-area" style="height: 36px;background-color: ##82bbef;">
		<div style="float: left; width: 46%;"><h2 style="color:white;font-weight:bold;margin-left: 12px;">Edit Recurring Carrier Expense</h2></div>
	</div>
	<div style="clear:left;"></div>
<cfelse>
	<div class="white-con-area" style="height: 36px;background-color: ##82bbef;margin-top: 25px;">
		<div style="float: left; width: 46%;"><h2 style="color:white;font-weight:bold;margin-left: 12px;">Add Recurring Carrier Expense</h2></div>
	</div>
	<div style="clear:left;"></div>
</cfif>
<div class="white-con-area">
	<div class="white-top"></div>
	<div class="white-mid">
		<cfform name="frmRecurringCarrierExpense" id="frmRecurringCarrierExpense" action="index.cfm?event=addRecurringDriverExpense:process&editid=#carrierExpenseRecurringID#&#session.URLToken##isCarrier#" method="post">
			
			<div class="form-con">
				<fieldset style="margin-top: 16px;">
					<label>Description</label>
					<INPUT  placeholder="Type text to select"  TYPE="text" class="medium-textbox applynotesPl" name="description" id="description" tabindex="1" style="margin-bottom: 10px;" value="#description#" maxlength="250">
					<div class="clear"></div>
					
					<label>Amount</label>
					<input type="text" name="amount" id="amount" tabindex="2" value="#decimalFormat(amount)#">
					<div class="clear"></div>
					
					<label>Next Date</label>
					<input tabindex=4 name="date" id="date"  onchange="checkDateFormatAll(this);" value="#dateformat(date,'mm/dd/yyyy')#" validate="date" required="yes" message="Please enter a valid date" type="datefield" class="sm-input datefield"/>
					<div class="clear"></div>

					<label>Interval</label>
					<select name="Interval" id="Interval">
						<option value="0" <cfif Interval EQ "0"> selected </cfif>>Select Interval</option>
						<option value="D" <cfif Interval EQ "D"> selected </cfif>>Day</option>
						<option value="W" <cfif Interval EQ "W"> selected </cfif>>Week</option>
						<option value="Q" <cfif Interval EQ "Q"> selected </cfif>>Quarter</option>
						<option value="M" <cfif Interval EQ "M"> selected </cfif>>Month</option>
						<option value="Y" <cfif Interval EQ "Y"> selected </cfif>>Year</option>
						<option value="2" <cfif Interval EQ "2"> selected </cfif>>2 Year</option>
					</select>
					<div class="clear"></div>
					
					<label>Category</label>
					<input type="text" name="category" id="category" tabindex="2" value="#category#">
					<div class="clear"></div>
					<input type="hidden" name="driverid" id="driverid" value="#url.driverid#">
					<input type="hidden" name="editid" id="editid" value="#carrierExpenseRecurringID#">
					<input  type="button" name="submitExpInformation" tabindex="5" class="bttn" value="Save" style="width:80px;margin-left:55px;margin-top:5px;" onclick="return validationRecurringCarrierExpense();" />
					<input  type="button" onclick="javascript:history.back();" tabindex="6" name="back" class="bttn" value="Back" style="width:70px;margin-top: 5px;" />		
				</fieldset>
			</div>
			<div class="clear"></div>
		</cfform>
		<div class="clear"></div>
	</div>
	<div class="white-bot"></div>
	<script type="text/javascript">

		$(document).ready(function(){

			$( ".datefield" ).datepicker({
	          dateFormat: "mm/dd/yy",
	          showOn: "button",
	          buttonImage: "images/DateChooser.png",
	          buttonImageOnly: true,
	          showButtonPanel: true
	        });

			$('##description').each(function(i, tag) {
		        $(tag).autocomplete({
		            multiple: false,
		            width: 400,
		            scroll: true,
		            scrollHeight: 300,
		            cacheLength: 1,
		            highlight: false,
		            dataType: "json",
		            source: '../gateways/equipmentgateway.cfc?method=expenseAutoComplete&CompanyID=#session.CompanyID#',
		            select: function(e, ui) {
		                $(this).val(ui.item.Description);
		                $('##amount').val(ui.item.Amount);
		                $('##category').val(ui.item.Category);
		                return false;
		            }
		        });
		        $(tag).data("ui-autocomplete")._renderItem = function(ul, item) {
		            return $( "<li>"+item.Description+"<br/><b><u>Amount</u>:</b> "+ item.Amount+"&nbsp;&nbsp;&nbsp;<b><u>Category</u>:</b>" + item.Category+"</li>" )
		                    .appendTo( ul );
		        }
		    });
	    });
	</script>
</cfoutput>









