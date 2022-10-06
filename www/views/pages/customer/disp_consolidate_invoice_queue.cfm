<cfparam name="message" default="">
<cfparam name="url.sortorder" default="desc">
<cfparam name="sortby"  default="">
<cfsilent>
	<cfif isdefined("form.searchText") >	
		<cfinvoke component="#variables.objCutomerGateway#" method="getConsolidateInvoiceQueue" searchText="#form.searchText#" pageNo="#form.pageNo#" sortorder="#form.sortOrder#" sortby="#form.sortBy#"  returnvariable="qConsolidateInvoiceQueue" />	
	<cfelse>
		<cfinvoke component="#variables.objCutomerGateway#" method="getConsolidateInvoiceQueue" searchText="" pageNo="1" returnvariable="qConsolidateInvoiceQueue" />
	</cfif>
	<cfif qConsolidateInvoiceQueue.recordcount lte 0>
		<cfset message="No match found">
	</cfif>
 </cfsilent>
<cfoutput>
	<cfinvoke component="#variables.objloadGateway#" method="getcurAgentMaildetails" returnvariable="request.qcurMailAgentdetails" employeID="#session.empid#" />
	<cfif request.qcurMailAgentdetails.recordcount gt 0 and (request.qcurMailAgentdetails.SmtpAddress eq "" or request.qcurMailAgentdetails.SmtpUsername eq "" or request.qcurMailAgentdetails.SmtpPort eq "" or request.qcurMailAgentdetails.SmtpPassword eq "" or request.qcurMailAgentdetails.SmtpPort eq 0)>
        <cfset mailsettings = "false">
    <cfelse>
        <cfset mailsettings = "true">
    </cfif>
	<div id="Information"></div>
	<h1>Consolidated Invoice Queue</h1>
	<div style="clear:left"></div>
	<cfif isdefined("message") and len(message)>
		<div id="message" class="msg-area">#message#</div>
	</cfif>
	<cfif isdefined("session.message") and len(session.message)>
		<div id="message" class="msg-area">#session.message#</div>
		<cfset exists= structdelete(session, 'message', true)/> 
	</cfif>
	<div class="search-panel">
		<div class="form-search">
			<cfform id="dispConsolidateInvoiceQueueForm" name="dispConsolidateInvoiceQueueForm" action="index.cfm?event=consolidatedinvoicequeue&#session.URLToken#" method="post" preserveData="yes">
				<cfinput id="pageNo" name="pageNo" value="1" type="hidden">
			    <cfinput id="sortOrder" name="sortOrder" value="ASC" type="hidden">
			    <cfif isDefined("form.sortBy")>
			    	<cfinput id="sortBy" name="sortBy" value="#form.sortBy#" type="hidden">
			    <cfelse>
			    	<cfinput id="sortBy" name="sortBy" value="LC.ConsolidatedInvoiceNumber" type="hidden">
			    </cfif>
				<fieldset>
					<cfset variables.Secret = application.dsn>
					<cfset variables.TheKey = 'NAMASKARAM'>
					<cfset variables.Encrypted = Encrypt(variables.Secret, variables.TheKey)>
					<cfset variables.dsn = ToBase64(variables.Encrypted)>
					<cfinput name="dsn" type="hidden" value="#application.dsn#" id="dsn">
					<cfinput name="searchText" type="text" title="Consolidation##, Customer, Ref##, Status.." placeholder="Consolidation##, Customer, Ref##, Status.."/>
					<input name="" onclick="javascript: document.getElementById('pageNo').value=1;" type="submit" class="s-bttn" value="Search" style="width:56px;" />
					<div class="clear"></div>
				</fieldset>
			</cfform>			
		</div>
	</div>
	<table width="100%" border="0" class="data-table" cellspacing="0" cellpadding="0" style="color:##000000;">
  		<thead>
  			<tr>
				<th width="29" align="center" valign="middle" class="head-bg" style="border-left: 1px solid ##5d8cc9;border-top-left-radius: 5px;">&nbsp;</th>
				<th width="5" align="center" valign="middle" class="head-bg" onclick="sortTableBy('LC.ConsolidatedInvoiceNumber','dispConsolidateInvoiceQueueForm');">Consolidation##</th>
				<th width="50" align="center" valign="middle" class="head-bg" onclick="sortTableBy('CAST(LC.Description AS VARCHAR(MAX))','dispConsolidateInvoiceQueueForm');">Customer</th>
  				<th width="40" align="center" valign="middle" class="head-bg" onclick="sortTableBy('LC.Date','dispConsolidateInvoiceQueueForm');">Created</th>
				<th width="40" align="center" valign="middle" class="head-bg" onclick="sortTableBy('LC.ConsolidatedInvoiceNumber','dispConsolidateInvoiceQueueForm');">Reference##</th>
  				<th width="50" align="center" valign="middle" class="head-bg" onclick="sortTableBy('LC.Amount','dispConsolidateInvoiceQueueForm');">Amount</th>
				<th width="50" align="center" valign="middle" class="head-bg" onclick="sortTableBy('LC.LoadCount','dispConsolidateInvoiceQueueForm');">Load&nbsp;Count</th>
				<th width="50" align="center" valign="middle" class="head-bg">Print</th>
				<th width="50" align="center" valign="middle" class="head-bg">Email</th>
				<th width="50" align="center" valign="middle" class="head-bg2" onclick="sortTableBy('LC.Status','dispConsolidateInvoiceQueueForm');" style="border-right: 1px solid ##5d8cc9;border-top-right-radius: 5px;">Status</th>
  			</tr>
  		</thead>
  		<tbody>
     		<cfloop query="qConsolidateInvoiceQueue">
        		<cfset pageSize = 30>
	            <cfif isdefined("form.pageNo")>
	            	<cfset rowNum=(qConsolidateInvoiceQueue.currentRow) + ((form.pageNo-1)*pageSize)>
	            <cfelse>
	            	<cfset rowNum=(qConsolidateInvoiceQueue.currentRow)>
	            </cfif>
				<tr <cfif qConsolidateInvoiceQueue.currentRow mod 2 eq 0>bgcolor="##FFFFFF"<cfelse>bgcolor="##f7f7f7"</cfif>>
					<td class="sky-bg2" valign="middle" align="center" style="border-left: 1px solid ##5d8cc9;"  onclick="document.location.href='index.cfm?event=editconsolidatedinvoicequeue&editid=#qConsolidateInvoiceQueue.ID#&#session.URLToken#'">#rowNum#</td>
					<td align="center" valign="middle" nowrap="nowrap" class="normal-td" onclick="document.location.href='index.cfm?event=editconsolidatedinvoicequeue&editid=#qConsolidateInvoiceQueue.ID#&#session.URLToken#'"><a title="#qConsolidateInvoiceQueue.ConsolidatedInvoiceNumber#" href="index.cfm?event=editconsolidatedinvoicequeue&editid=#qConsolidateInvoiceQueue.ID#&#session.URLToken#">#qConsolidateInvoiceQueue.ConsolidatedInvoiceNumber#</a></td>

					<td align="left" valign="middle" nowrap="nowrap" class="normal-td" style="cursor: context-menu;" onclick="document.location.href='index.cfm?event=addcustomer&customerid=#qConsolidateInvoiceQueue.CustomerID#&#session.URLToken#'"><a title="#qConsolidateInvoiceQueue.ConsolidatedInvoiceNumber#" href="index.cfm?event=addcustomer&customerid=#qConsolidateInvoiceQueue.CustomerID#&#session.URLToken#">#qConsolidateInvoiceQueue.Description#</a></td>


					<td align="right" valign="middle" nowrap="nowrap" class="normal-td" style="cursor: context-menu;padding-right: 5px;" onclick="document.location.href='index.cfm?event=editconsolidatedinvoicequeue&editid=#qConsolidateInvoiceQueue.ID#&#session.URLToken#'"><a title="#qConsolidateInvoiceQueue.ConsolidatedInvoiceNumber#" href="index.cfm?event=editconsolidatedinvoicequeue&editid=#qConsolidateInvoiceQueue.ID#&#session.URLToken#">#dateformat(qConsolidateInvoiceQueue.date,'mm/dd/yyyy')#</a></td>
					<td  align="center" valign="middle" nowrap="nowrap" class="normal-td" style="cursor: context-menu;" onclick="document.location.href='index.cfm?event=editconsolidatedinvoicequeue&editid=#qConsolidateInvoiceQueue.ID#&#session.URLToken#'"><a title="#qConsolidateInvoiceQueue.ConsolidatedInvoiceNumber#" href="index.cfm?event=editconsolidatedinvoicequeue&editid=#qConsolidateInvoiceQueue.ID#&#session.URLToken#">#qConsolidateInvoiceQueue.Reference#</a></td>
					<td  align="right" valign="middle" nowrap="nowrap" class="normal-td" style="cursor: context-menu;padding-right: 5px;" onclick="document.location.href='index.cfm?event=editconsolidatedinvoicequeue&editid=#qConsolidateInvoiceQueue.ID#&#session.URLToken#'"><a title="#qConsolidateInvoiceQueue.ConsolidatedInvoiceNumber#" href="index.cfm?event=editconsolidatedinvoicequeue&editid=#qConsolidateInvoiceQueue.ID#&#session.URLToken#">#DollarFormat(qConsolidateInvoiceQueue.Amount)#</a></td>
					<td align="right" valign="middle" nowrap="nowrap" class="normal-td" style="cursor: context-menu;padding-right: 5px;" onclick="document.location.href='index.cfm?event=editconsolidatedinvoicequeue&editid=#qConsolidateInvoiceQueue.ID#&#session.URLToken#'"><a title="#qConsolidateInvoiceQueue.ConsolidatedInvoiceNumber#" href="index.cfm?event=editconsolidatedinvoicequeue&editid=#qConsolidateInvoiceQueue.ID#&#session.URLToken#">#qConsolidateInvoiceQueue.LoadCount#</a></td>


					<td align="center" valign="middle" nowrap="nowrap" class="normal-td">
						<input type="button" value="EDIT" onclick="document.location.href='index.cfm?event=editconsolidatedinvoicequeue&editid=#qConsolidateInvoiceQueue.ID#&#session.URLToken#'" style="width: 58px !important;font-size: 10px;">

						<input type="button" value="PRINT" onclick="consolidatedInvoiceReportOnClick(#qConsolidateInvoiceQueue.ConsolidatedInvoiceNumber#,'#session.URLToken#','#qConsolidateInvoiceQueue.CustomerID#','#session.CompanyID#','#qConsolidateInvoiceQueue.ID#')" style="width: 58px !important;font-size: 10px;">
					</td>
					<td align="left" valign="middle" nowrap="nowrap" class="normal-td"><input type="button" value="EMAIL" 
						<cfif mailsettings>
							onclick="consolidatedInvoiceEmailOnClick(#qConsolidateInvoiceQueue.ConsolidatedInvoiceNumber#,'#session.URLToken#','#qConsolidateInvoiceQueue.CustomerID#','#session.CompanyID#','#qConsolidateInvoiceQueue.ID#')"
						<cfelse>
							onclick="alert('You must setup your email address in your profile before you can email reports.');"
						</cfif>
						 style="width: 58px !important;font-size: 10px;"></td>
					<td align="left" valign="middle" nowrap="nowrap" class="normal-td2"  style="border-right: 1px solid ##5d8cc9;">
						<input type="button" id="btn_consolidate_status_#qConsolidateInvoiceQueue.ConsolidatedInvoiceNumber#" value="#qConsolidateInvoiceQueue.Status#" onclick="changeConsolidatedStatus(#qConsolidateInvoiceQueue.ConsolidatedInvoiceNumber#,'#qConsolidateInvoiceQueue.CustomerID#','#session.CompanyID#','#qConsolidateInvoiceQueue.ID#')" style="width: 58px !important;font-size: 10px;">
					</td>
	 			</tr>
	 		</cfloop>
		</tbody>
	 	<tfoot>
	 		<tr>
				<td colspan="10" align="left" valign="middle" class="footer-bg" style="border-left: 1px solid ##5d8cc9;border-bottom-left-radius: 5px;border-right: 1px solid ##5d8cc9;border-bottom-right-radius: 5px;">
					<div class="up-down">
						<div class="arrow-top"><a href="javascript: tablePrevPage('dispConsolidateInvoiceQueueForm');"><img src="images/arrow-top.gif" alt="" /></a></div>
						<div class="arrow-bot"><a href="javascript: tableNextPage('dispConsolidateInvoiceQueueForm');"><img src="images/arrow-bot.gif" alt="" /></a></div>
					</div>
					<div class="gen-left" style="font-size: 14px;">
						<cfif qConsolidateInvoiceQueue.recordcount>
						<button type="button" class="bttn_nav" onclick="tablePrevPage('dispConsolidateInvoiceQueueForm');">PREV</button>
						  Page
						  <input type="text" onkeyup="if (/\D/g.test(this.value)) this.value = this.value.replace(/\D/g,'')" value="<cfif structKeyExists(form, "pageNo")>#form.pageNo#<cfelse>1</cfif>" id="jumpPageNo" style="text-align: center;width: 25px;" onchange="jumpToPage('dispConsolidateInvoiceQueueForm')">
						      <input type="hidden" id="TotalPages" value="#qConsolidateInvoiceQueue.TotalPages#">
						  of #qConsolidateInvoiceQueue.TotalPages#
						  <button type="button" class="bttn_nav" onclick="tableNextPage('dispConsolidateInvoiceQueueForm');">NEXT</button>
						</cfif>
		          	</div>
					<div class="gen-right"><img src="images/loader.gif" alt="" /></div>
					<div class="clear"></div>
				</td>
	 		</tr>	
	 	</tfoot>	  
	</table>
</cfoutput>
    