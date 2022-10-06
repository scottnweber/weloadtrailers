<cfparam name="description" default="">
<cfparam name="amount" default="0">
<cfparam name="category" default="">
<cfparam name="url.ExpenseID" default="">
<cfoutput>
<cfsilent>
	<cfif structkeyexists(url,"ExpenseID") and len(trim(url.ExpenseID)) gt 0>
		<cfinvoke component="#variables.objequipmentGateway#" method="getExpenseInformation" ExpenseID="#url.ExpenseID#"returnvariable="request.qGetExpenseInformation" />
		<cfif request.qGetExpenseInformation.recordcount>
			<cfset  description = request.qGetExpenseInformation.description>
			<cfset  amount = request.qGetExpenseInformation.amount>
			<cfset  category = request.qGetExpenseInformation.category>
		</cfif>
	</cfif>	
</cfsilent>
<cfif structkeyexists(url,"ExpenseID") and len(trim(url.ExpenseID)) gt 0>
	<div class="search-panel">
		<div class="delbutton">
			<a href="index.cfm?event=ExpenseSetUp&DelExpenseID=#url.ExpenseID#&#session.URLToken##iscarrier#" onclick="return confirm('Are you sure to delete it ?');">
			Delete 
			</a>
		</div>
	</div>	
	<div class="white-con-area" style="height: 36px;background-color: ##82bbef;">
		<div style="float: left; width: 20%;" id="divUploadedFiles">
		</div>
		<div style="float: left; width: 46%;"><h2 style="color:white;font-weight:bold;margin-left: 12px;">Edit Expense Setup</h2></div>
	</div>
	<div style="clear:left;"></div>
<cfelse>
	<div class="white-con-area" style="height: 36px;background-color: ##82bbef;margin-top: 25px;">
		<div style="float: left; width: 20%;" id="divUploadedFiles">
		</div>
		<div style="float: left; width: 46%;"><h2 style="color:white;font-weight:bold;margin-left: 12px;">Add Expense Setup</h2></div>
	</div>
	<div style="clear:left;"></div>
</cfif>
<div class="white-con-area">
	<div class="white-top"></div>
	<div class="white-mid">
		<cfform name="frmExpense" id="frmExpense" action="index.cfm?event=addExpenseSetUp:process&editid=#ExpenseID#&#session.URLToken##isCarrier#" method="post">
			<div class="form-con">
				<fieldset style="margin-top: 16px;">
					<label>Description</label>
					<INPUT TYPE="text" class="medium-textbox applynotesPl" name="description" id="description" tabindex="1" style="margin-bottom: 10px;" value="#description#" maxlength="250">
					<div class="clear"></div>
					
					<label>Amount</label>
					<input type="text" name="amount" id="amount" tabindex="2" value="#replace("$#Numberformat(amount,"___.__")#", " ", "", "ALL")#">
					<div class="clear"></div>
					
					<label>Category</label>
					<input type="text" name="category" id="category" tabindex="2" value="#category#">
					<div class="clear"></div>

					<input type="hidden" name="editid" id="editid" value="#ExpenseID#">
					<cfset Secret = application.dsn>
					<cfset TheKey = 'NAMASKARAM'>
					<cfset Encrypted = Encrypt(Secret, TheKey)>
					<cfset dsn = ToBase64(Encrypted)>		
					<input  type="button" name="submitExpInformation" tabindex="5" class="bttn" value="Save" style="width:80px;margin-left:55px;margin-top:5px;" onclick="return validationExpense('#dsn#','#session.companyid#');" />
					<input  type="button" onclick="javascript:history.back();" tabindex="6" name="back" class="bttn" value="Back" style="width:70px;margin-top: 5px;" />
					<div id="errorShow" class="msg-area" style="width: 181px;margin-left: 96px; margin-top: 36px;">
						<FONT COLOR="##ba151c">Description already exists</FONT>
					</div>			
				</fieldset>
			</div>
			<div class="clear"></div>
		</cfform>
		<div class="clear"></div>
	</div>
	<div class="white-bot"></div>
</cfoutput>









