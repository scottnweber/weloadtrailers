<cfparam name="url.sortorder" default="desc">
<cfparam name="sortby"  default="">
<cfif structKeyExists(url,"IsCarrier")>
	<cfset isCarrier = url.IsCarrier>
</cfif>
<cfoutput>
	<div class="white-con-area" style="height: 36px;background-color: ##82bbef;">
		<div style="float: left; width: 20%;" id="divUploadedFiles">
		</div>
		<div style="float: left; width: 46%;"><h2 style="color:white;font-weight:bold;margin-left: 12px;">All Expense Setup</h2></div>
	</div>
	<div style="clear:left;"></div>
	<cfif structkeyexists(url,"DelExpenseID") and len(url.DelExpenseID)>
		<cfinvoke component="#variables.objequipmentGateway#" method="deleteExpenseSetup" ExpenseId="#url.DelExpenseID#" returnvariable="message" />
	</cfif>
	<cfif structkeyexists(url,"DelExpenseID") and len(url.DelExpenseID) gt 1>	
		<cfinvoke component="#variables.objequipmentGateway#" method="getExpenseInformation" returnvariable="request.qGetExpenseInformation" />
	</cfif>
	<cfif isdefined("message") and len(message)>
	<div class="msg-area" style="margin-left: 10px;margin-top: 10px;">#message#</div>
	</cfif>
	<cfif structkeyexists(url,"sortorder") and url.sortorder eq 'desc'>
		<cfset sortorder="asc">
	 <cfelse>
		<cfset sortorder="desc">
	</cfif>
	<cfif structkeyexists(url,"sortby")>
		<cfinvoke component="#variables.objequipmentGateway#" method="getExpenseInformation" sortorder="#sortorder#" sortby="#sortby#"  returnvariable="request.qGetExpenseInformation" />
	</cfif> 
	<div class="search-panel">
		<div class="form-search">
		</div>
		<div class="addbutton"><a href="index.cfm?event=addExpenseSetUp&#session.URLToken#&IsCarrier=#isCarrier#">Add New</a></div>
	</div>
	<cfif request.qGetExpenseInformation.recordcount>
		<table width="86%" border="0" cellspacing="0" cellpadding="0" class="data-table" id="test">
			<thead>
				<tr>
					<th width="5" align="left" valign="top"><img src="images/top-left.gif" alt="" width="5" height="23" /></th>
					<th align="center" valign="middle" class="head-bg">&nbsp;</th>
					<th align="center" valign="middle" class="head-bg" onclick="document.location.href='index.cfm?event=ExpenseSetUp&sortorder=#sortorder#&sortby=Description&#session.URLToken#&IsCarrier=#isCarrier#'">Description</th>
					<th align="center" valign="middle" class="head-bg" onclick="document.location.href='index.cfm?event=ExpenseSetUp&sortorder=#sortorder#&sortby=Amount&#session.URLToken#&IsCarrier=#isCarrier#'">Amount</th>
					<th align="center" valign="middle" class="head-bg" onclick="document.location.href='index.cfm?event=ExpenseSetUp&sortorder=#sortorder#&sortby=Category&#session.URLToken#&IsCarrier=#isCarrier#'">Category</th>
					<th width="110" align="center" valign="middle" class="head-bg2" onclick="document.location.href='index.cfm?event=ExpenseSetUp&sortorder=#sortorder#&sortby=created&#session.URLToken#&IsCarrier=#isCarrier#'">Date Created</th>
					<th align="right" valign="top"><img src="images/top-right.gif" alt="" width="5" height="23" /></th>
				</tr>
			</thead>
			<tbody>
				<cfloop query="request.qGetExpenseInformation">	
					<tr <cfif request.qGetExpenseInformation.currentRow mod 2 eq 0>bgcolor="##FFFFFF"<cfelse>bgcolor="##f7f7f7"</cfif>>
						<td height="20" class="sky-bg">&nbsp;</td>
						<td class="sky-bg2" valign="middle" align="center" onclick="document.location.href='index.cfm?event=AddExpenseSetUp&ExpenseID=#request.qGetExpenseInformation.ExpenseID#&#session.URLToken#&IsCarrier=#isCarrier#'" ><a title="#request.qGetExpenseInformation.Description#" href="index.cfm?event=AddExpenseSetUp&ExpenseID=#request.qGetExpenseInformation.ExpenseID#&#session.URLToken#&IsCarrier=#isCarrier#">#request.qGetExpenseInformation.currentRow#</a></td>
						<td class="normal-td" valign="middle" align="left" onclick="document.location.href='index.cfm?event=AddExpenseSetUp&ExpenseID=#request.qGetExpenseInformation.ExpenseID#&#session.URLToken#&IsCarrier=#isCarrier#'"><a title="#request.qGetExpenseInformation.Description#" href="index.cfm?event=AddExpenseSetUp&ExpenseID=#request.qGetExpenseInformation.ExpenseID#&#session.URLToken#&IsCarrier=#isCarrier#">#request.qGetExpenseInformation.Description#</a></td>
						<td class="normal-td" valign="middle" align="center" onclick="document.location.href='index.cfm?event=AddExpenseSetUp&ExpenseID=#request.qGetExpenseInformation.ExpenseID#&#session.URLToken#&IsCarrier=#isCarrier#'"><a title="#request.qGetExpenseInformation.Description#" href="index.cfm?event=AddExpenseSetUp&ExpenseID=#request.qGetExpenseInformation.ExpenseID#&#session.URLToken#&IsCarrier=#isCarrier#">#DollarFormat(request.qGetExpenseInformation.Amount)#</a></td>
						<td class="normal-td" valign="middle" align="center" onclick="document.location.href='index.cfm?event=AddExpenseSetUp&ExpenseID=#request.qGetExpenseInformation.ExpenseID#&#session.URLToken#&IsCarrier=#isCarrier#'"><a title="#request.qGetExpenseInformation.Category#" href="index.cfm?event=AddExpenseSetUp&ExpenseID=#request.qGetExpenseInformation.ExpenseID#&#session.URLToken#&IsCarrier=#isCarrier#">#request.qGetExpenseInformation.Category#</a></td>
						<td class="normal-td2" valign="middle" align="center" onclick="document.location.href='index.cfm?event=AddExpenseSetUp&ExpenseID=#request.qGetExpenseInformation.ExpenseID#&#session.URLToken#&IsCarrier=#isCarrier#'"><a title="#request.qGetExpenseInformation.Created#" href="index.cfm?event=AddExpenseSetUp&ExpenseID=#request.qGetExpenseInformation.ExpenseID#&#session.URLToken#&IsCarrier=#isCarrier#"> #DateFormat(request.qGetExpenseInformation.Created, "mm-dd-yyyy")#</a></td>
						<td class="normal-td3">&nbsp;</td> 
					</tr>
				</cfloop>
			</tbody>
			<tfoot>
				<tr>
					<td width="5" align="left" valign="top"><img src="images/left-bot.gif" alt="" width="5" height="23" /></td>
					<td colspan="3" align="left" valign="middle" class="footer-bg">
					<div class="up-down">
					<div class="arrow-top"><a href="##"><img src="images/arrow-top.gif" alt="" /></a></div>
					<div class="arrow-bot"><a href="##"><img src="images/arrow-bot.gif" alt="" /></a></div>
					</div>
					<div class="gen-left"><a href="##">View More</a></div>
					<div class="gen-right"><img src="images/loader.gif" alt="" /></div>
					<div class="clear"></div>
					</td><td width="5" align="right" valign="top"  class="footer-bg">&nbsp;</td><td  class="footer-bg" width="5" align="right" valign="top">&nbsp;</td>
					<td width="5" align="right" valign="top"><img src="images/right-bot.gif" alt="" width="5" height="23" /></td>
				</tr>	
			</tfoot>	  
		</table>
	</cfif>
</cfoutput>	