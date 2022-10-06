<cfparam name="description" default="">
<cfparam name="amount" default="0">
<cfparam name="category" default="">
<cfparam name="date" default="">
<cfparam name="url.carrierExpenseID" default="">
<cfoutput>
<cfsilent>
	<cfif structkeyexists(url,"carrierExpenseID") and len(trim(url.carrierExpenseID)) gt 0>
		<cfinvoke component="#variables.objequipmentGateway#" method="getCarrierExpenseInformation" CarrierExpenseID="#url.CarrierExpenseID#"returnvariable="request.qGetCarrierExpenseInformation" />
		<cfif request.qGetCarrierExpenseInformation.recordcount>
			<cfset  description = request.qGetCarrierExpenseInformation.description>
			<cfset  amount = request.qGetCarrierExpenseInformation.amount>
			<cfset  category = request.qGetCarrierExpenseInformation.category>
			<cfset  date = request.qGetCarrierExpenseInformation.date>
		</cfif>
	</cfif>	
</cfsilent>
<cfif structkeyexists(url,"carrierExpenseID") and len(trim(url.carrierExpenseID)) gt 0>
	<div class="search-panel">
		<div class="delbutton">
			<a href="index.cfm?event=delDriverExpense&CarrierExpenseID=#url.carrierExpenseID#&driverid=#url.driverid#&#session.URLToken##iscarrier#" onclick="return confirm('Are you sure to delete it ?');">
			Delete 
			</a>
		</div>
	</div>	
	<div class="white-con-area" style="height: 36px;background-color: ##82bbef;">
		<div style="float: left; width: 46%;"><h2 style="color:white;font-weight:bold;margin-left: 12px;">Edit Carrier Expense</h2></div>
	</div>
	<div style="clear:left;"></div>
<cfelse>
	<div class="white-con-area" style="height: 36px;background-color: ##82bbef;margin-top: 25px;">
		<div style="float: left; width: 46%;"><h2 style="color:white;font-weight:bold;margin-left: 12px;">Add Carrier Expense</h2></div>
	</div>
	<div style="clear:left;"></div>
</cfif>
<div class="white-con-area">
	<div class="white-top"></div>
	<div class="white-mid">
		<cfform name="frmCarrierExpense" id="frmCarrierExpense" action="index.cfm?event=addDriverExpense:process&editid=#carrierExpenseID#&#session.URLToken##isCarrier#" method="post">
			
			<div class="form-con">
				<fieldset style="margin-top: 16px;">
					<label>Description</label>
					<INPUT placeholder="Type text to select" TYPE="text" class="medium-textbox applynotesPl" name="description" id="description" tabindex="1" style="margin-bottom: 10px;" value="#description#" maxlength="250">
					<div class="clear"></div>
					
					<label>Amount</label>
					<input type="text" name="amount" id="amount" tabindex="2" value="#replace("$#Numberformat(amount,"___.__")#", " ", "", "ALL")#">
					<div class="clear"></div>
					
					<label>Date</label>
					<input tabindex=4 name="date" id="date"  onchange="checkDateFormatAll(this);" value="#dateformat(date,'mm/dd/yyyy')#" validate="date" required="yes" message="Please enter a valid date" type="datefield" class="sm-input datefield"/>
					<div class="clear"></div>

					<label>Category</label>
					<input type="text" name="category" id="category" tabindex="2" value="#category#">
					<div class="clear"></div>
					<input type="hidden" name="driverid" id="driverid" value="#url.driverid#">
					<input type="hidden" name="editid" id="editid" value="#carrierExpenseID#">
					<input  type="button" name="submitExpInformation" tabindex="5" class="bttn" value="Save" style="width:80px;margin-left:55px;margin-top:5px;" onclick="return validationCarrierExpense();" />
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









