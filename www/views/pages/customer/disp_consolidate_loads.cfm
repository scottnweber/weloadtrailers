<cfparam name="message" default="">
<cfparam name="url.sortorder" default="desc">
<cfparam name="sortby"  default="">
<cfsilent>
	<cfinvoke component="#variables.objloadGateway#" method="getLoadSystemSetupOptions" returnvariable="request.qSystemSetupOptions" />
	<cfif isdefined("form.searchText") >	
		<cfinvoke component="#variables.objCutomerGateway#" method="getConsolidateLoads" searchText="#form.searchText#" pageNo="#form.pageNo#" sortorder="#form.sortOrder#" sortby="#form.sortBy#"  returnvariable="qConsolidateLoads" />	
	<cfelse>
		<cfinvoke component="#variables.objCutomerGateway#" method="getConsolidateLoads" searchText="" pageNo="1" returnvariable="qConsolidateLoads" />
	</cfif>
	<cfif qConsolidateLoads.recordcount lte 0>
		<cfset message="No match found">
	</cfif>
 </cfsilent>
<cfoutput>
	<style type="text/css">
		
	</style>
	<h1>Select Invoices to Consolidate and then click the "Add to Queue" button.</h1>
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
			<cfform id="dispConsolidateLoadsSearchForm" name="dispConsolidateLoadsSearchForm" action="index.cfm?event=createconsolidatedinvoices&#session.URLToken#" method="post" preserveData="yes">
				<cfinput id="pageNo" name="pageNo" value="1" type="hidden">
			    <cfinput id="sortOrder" name="sortOrder" value="ASC" type="hidden">
			    <cfif isDefined("form.sortBy")>
			    	<cfinput id="sortBy" name="sortBy" value="#form.sortBy#" type="hidden">
			    <cfelse>
			    	<cfinput id="sortBy" name="sortBy" value="LP.StopDate,L.CustName,L.LoadNumber" type="hidden">
			    </cfif>
				<fieldset>
					<cfset variables.Secret = application.dsn>
					<cfset variables.TheKey = 'NAMASKARAM'>
					<cfset variables.Encrypted = Encrypt(variables.Secret, variables.TheKey)>
					<cfset variables.dsn = ToBase64(variables.Encrypted)>
					<cfinput name="dsn" type="hidden" value="#variables.dsn#" id="dsn">
					<input name="s_empid" type="hidden" value="#session.empid#" id="s_empid">
            		<input name="s_adminusername" type="hidden" value="#session.adminusername#" id="s_adminusername">
					<cfinput name="searchText" type="text" title="Load##, Status, Customer, PO##.." placeholder="Load##, Status, Customer, PO##.."/>
					<input name="" onclick="javascript: document.getElementById('pageNo').value=1;" type="submit" class="s-bttn" value="Search" style="width:56px;" />
					<input name="btnConsolidate" onclick="addToConsolidatedQueue(0);" type="button" class="s-bttn" value="Add to Queue" style="width:170px !important;margin-left: 10px;" />
					<div class="clear"></div>
				</fieldset>
			</cfform>			
		</div>
	</div>
	<table width="100%" border="0" class="data-table" cellspacing="0" cellpadding="0" style="color:##000000;">
  		<thead>
  			<tr>
				<th width="5" align="left" valign="top"><img src="images/top-left.gif" alt="" width="5" height="23" /></th>
				<th width="29" align="center" valign="middle" class="head-bg">&nbsp;</th>
				<th style="padding-left: 9px;" width="10" align="left" valign="middle" class="head-bg">
					<input type="checkbox" name="checkboxSelectConsolidate" id="checkboxSelectConsolidate" class="checkboxSelectConsolidate" onclick="checkboxConsolidated(this)" data-billdocerror="0" value="0">
				</th>
				<th width="25" align="center" valign="middle" class="head-bg" onclick="sortTableBy('L.LoadNumber','dispConsolidateLoadsSearchForm');">Load##</th>
				<th width="50" align="center" valign="middle" class="head-bg" onclick="sortTableBy('LST.StatusText','dispConsolidateLoadsSearchForm');">Status</th>
  				<th width="40" align="center" valign="middle" class="head-bg" onclick="sortTableBy('L.CustName','dispConsolidateLoadsSearchForm');">Customer</th>
				<th width="40" align="center" valign="middle" class="head-bg" onclick="sortTableBy('L.CustomerPONo','dispConsolidateLoadsSearchForm');">PO##</th>
  				<th width="50" align="center" valign="middle" class="head-bg" onclick="sortTableBy('LP.StopDate','dispConsolidateLoadsSearchForm');">Ship&nbsp;Date</th>
				<th width="50" align="center" valign="middle" class="head-bg" onclick="sortTableBy('LP.StopTime','dispConsolidateLoadsSearchForm');">Ship&nbsp;Time</th>
   				<th width="40" align="center" valign="middle" class="head-bg" onclick="sortTableBy('LP.City','dispConsolidateLoadsSearchForm');">Ship&nbsp;City</th>
				<th width="40" align="center" valign="middle" class="head-bg" onclick="sortTableBy('LP.StateCode','dispConsolidateLoadsSearchForm');">Ship&nbsp;ST</th>
				<th width="50" align="center" valign="middle" class="head-bg" onclick="sortTableBy('LD.StopDate','dispConsolidateLoadsSearchForm');">Del.&nbsp;Date</th>
				<th width="50" align="center" valign="middle" class="head-bg" onclick="sortTableBy('LD.StopTime','dispConsolidateLoadsSearchForm');">Del.&nbsp;Time</th>
   				<th width="40" align="center" valign="middle" class="head-bg" onclick="sortTableBy('LD.City','dispConsolidateLoadsSearchForm');">Del.&nbsp;City</th>
				<th width="35" align="center" valign="middle" class="head-bg" onclick="sortTableBy('LD.StateCode','dispConsolidateLoadsSearchForm');">Del.&nbsp;ST</th>
				<th width="50" align="center" valign="middle" class="head-bg" onclick="sortTableBy('L.TotalCustomerCharges','dispConsolidateLoadsSearchForm');">Cust.&nbsp;Amt</th>
				<th width="50" align="center" valign="middle" class="head-bg" onclick="sortTableBy('L.TotalCarrierCharges','dispConsolidateLoadsSearchForm');">Carr.&nbsp;Amt</th>
				<th width="30" align="center" valign="middle" class="head-bg" onclick="sortTableBy('ISNULL(l.CarrierName,l.LoadDriverName)','dispConsolidateLoadsSearchForm');">Carrier</th>
				<th width="30" align="center" valign="middle" class="head-bg" onclick="sortTableBy('L.EquipmentName','dispConsolidateLoadsSearchForm');">Equipment</th>
				<th width="30" align="center" valign="middle" class="head-bg" onclick="sortTableBy('L.DriverName ','dispConsolidateLoadsSearchForm');">Driver</th>
				<th width="30" align="center" valign="middle" class="head-bg" onclick="sortTableBy('E.EmpDispatch','dispConsolidateLoadsSearchForm');">Dispatcher</th>
				<th width="30" align="center" valign="middle" class="head-bg2" onclick="sortTableBy('L.SalesAgent','dispConsolidateLoadsSearchForm');">Sales Rep</th>
				<th width="5" align="right" valign="top"><img src="images/top-right.gif" alt="" width="5" height="23" /></th>
  			</tr>
  		</thead>
  		<tbody>
     		<cfloop query="qConsolidateLoads">	
        		<cfset pageSize = 30>
	            <cfif isdefined("form.pageNo")>
	            	<cfset rowNum=(qConsolidateLoads.currentRow) + ((form.pageNo-1)*pageSize)>
	            <cfelse>
	            	<cfset rowNum=(qConsolidateLoads.currentRow)>
	            </cfif>
				<tr style="background: ###qConsolidateLoads.colorcode#; cursor: pointer;" onmouseover="this.style.background = '##FFFFFF';" onmouseout="this.style.background = '###qConsolidateLoads.colorcode#';"bgcolor="##f7f7f7">
					<td height="20" class="sky-bg">&nbsp;</td>
					<td class="sky-bg2" valign="middle" align="center">#rowNum#</td>
					<td  align="left" valign="middle" nowrap="nowrap" class="normal-td">
						<input type="checkbox" name="checkboxSelectConsolidate" id="checkboxSelectConsolidate" class="checkboxSelectConsolidate" data-billdocerror="<cfif qConsolidateLoads.UnSupportedBillingDocuments>1<cfelse>0</cfif>"  value="#qConsolidateLoads.loadid#">
					</td>
					<td  align="center" valign="middle" nowrap="nowrap" class="normal-td" style="padding-right: 5px;"><a style="color:###qConsolidateLoads.TextColorCode#">#qConsolidateLoads.LoadNumber#</a></td>
					<td align="center" valign="middle" nowrap="nowrap" class="normal-td" style="padding-right: 5px;"><a style="color:###qConsolidateLoads.TextColorCode#">#qConsolidateLoads.StatusDescription#</a></td>
					<td align="left" valign="middle" nowrap="nowrap" class="normal-td" style="padding-right: 5px;"><a style="color:###qConsolidateLoads.TextColorCode#">#qConsolidateLoads.CustName#</a></td>
					<td align="right" valign="middle" nowrap="nowrap" class="normal-td" style="padding-right: 5px;"><a style="color:###qConsolidateLoads.TextColorCode#">#qConsolidateLoads.CustomerPONo#</a></td>
					<td align="right" valign="middle" nowrap="nowrap" class="normal-td"  style="padding-right: 5px;"><a style="color:###qConsolidateLoads.TextColorCode#">#dateformat(qConsolidateLoads.ShipDate,'mm/dd/yyyy')#</a></td>
					<td align="left" valign="middle" nowrap="nowrap" class="normal-td"><a style="color:###qConsolidateLoads.TextColorCode#">#qConsolidateLoads.ShipTime#</a></td>
					<td align="left" valign="middle" nowrap="nowrap" class="normal-td"><a style="color:###qConsolidateLoads.TextColorCode#">#qConsolidateLoads.ShipCity#</a></td>
					<td align="left" valign="middle" nowrap="nowrap" class="normal-td"><a style="color:###qConsolidateLoads.TextColorCode#">#qConsolidateLoads.ShipState#</a></td>
					<td align="left" valign="middle" nowrap="nowrap" class="normal-td"  style="padding-right: 5px;"><a style="color:###qConsolidateLoads.TextColorCode#">#dateformat(qConsolidateLoads.DelDate,'mm/dd/yyyy')#</a></td>
					<td align="left" valign="middle" nowrap="nowrap" class="normal-td"><a style="color:###qConsolidateLoads.TextColorCode#">#qConsolidateLoads.DelTime#</a></td>
					<td align="left" valign="middle" nowrap="nowrap" class="normal-td"><a style="color:###qConsolidateLoads.TextColorCode#">#qConsolidateLoads.DelCity#</a></td>
					<td align="left" valign="middle" nowrap="nowrap" class="normal-td"><a style="color:###qConsolidateLoads.TextColorCode#">#qConsolidateLoads.DelState#</a></td>
					<td align="right" valign="middle" nowrap="nowrap" class="normal-td" style="padding-right: 5px;"><a style="color:###qConsolidateLoads.TextColorCode#">#DollarFormat(qConsolidateLoads.TotalCustomerCharges)#</a></td>
					<td align="right" valign="middle" nowrap="nowrap" class="normal-td" style="padding-right: 5px;"><a style="color:###qConsolidateLoads.TextColorCode#">#DollarFormat(qConsolidateLoads.TotalCarrierCharges)#</a></td>
					<td align="left" valign="middle" nowrap="nowrap" class="normal-td"><a style="color:###qConsolidateLoads.TextColorCode#">#qConsolidateLoads.CarrierName#</a></td>
					<td align="left" valign="middle" nowrap="nowrap" class="normal-td"><a style="color:###qConsolidateLoads.TextColorCode#">#qConsolidateLoads.EquipmentName#</a></td>
					<td align="left" valign="middle" nowrap="nowrap" class="normal-td" style="padding-right: 5px;"><a style="color:###qConsolidateLoads.TextColorCode#">#qConsolidateLoads.DriverName#</a></td>
					<td align="left" valign="middle" nowrap="nowrap" class="normal-td"><a style="color:###qConsolidateLoads.TextColorCode#">#qConsolidateLoads.EmpDispatch#</a></td>
					<td align="left" valign="middle" nowrap="nowrap" class="normal-td2"><a style="color:###qConsolidateLoads.TextColorCode#">#qConsolidateLoads.SalesAgent#</a></td>
					<td class="normal-td3">&nbsp;</td>
	 			</tr>
	 		</cfloop>
		</tbody>
	 	<tfoot>
	 		<tr>
				<td width="5" align="left" valign="top"><img src="images/left-bot.gif" alt="" width="5" height="23" /></td>
				<td colspan="21" align="left" valign="middle" class="footer-bg">
					<div class="up-down">
						<div class="arrow-top"><a href="javascript: tablePrevPage('dispConsolidateLoadsSearchForm');"><img src="images/arrow-top.gif" alt="" /></a></div>
						<div class="arrow-bot"><a href="javascript: tableNextPage('dispConsolidateLoadsSearchForm');"><img src="images/arrow-bot.gif" alt="" /></a></div>
					</div>
					<div class="gen-left" style="font-size: 14px;">
						<cfif qConsolidateLoads.recordcount>
							<button type="button" class="bttn_nav" onclick="tablePrevPage('dispConsolidateLoadsSearchForm');">PREV</button>
						  Page 
						  <input type="text" onkeyup="if (/\D/g.test(this.value)) this.value = this.value.replace(/\D/g,'')" value="<cfif structKeyExists(form, "pageNo")>#form.pageNo#<cfelse>1</cfif>" id="jumpPageNo" style="text-align: center;width: 25px;" onchange="jumpToPage('dispConsolidateLoadsSearchForm')">
						      <input type="hidden" id="TotalPages" value="#qConsolidateLoads.TotalPages#">
						  of #qConsolidateLoads.TotalPages#
						  <button type="button" class="bttn_nav" onclick="tableNextPage('dispConsolidateLoadsSearchForm');">NEXT</button>
						</cfif>
		          	</div>
					<div class="gen-right"><img src="images/loader.gif" alt="" /></div>
					<div class="clear"></div>
				</td>
				<td width="5" align="right" valign="top"><img src="images/right-bot.gif" alt="" width="5" height="23" /></td>
	 		</tr>	
	 	</tfoot>	  
	</table>

	<script>
		$(document).ready(function(){
			$(".checkboxSelectConsolidate").click(function(){
			  	if($(this).data("billdocerror")){
			  		alert("Load "+$(this).val()+" has attachments that are not supported. We only support PDF, JPG, PNG & GIF file formats. Please fix this and try to add this load again.");
			  		return false;
			  	}
			});
			<cfif not len(request.qSystemSetupOptions.ConsolidateInvoiceTriggerStatus)>
				if(confirm('There are no load statuses selected for consolidated invoices in your settings. Please update this and try again.')){
					window.open('index.cfm?event=systemsetup&#session.URLToken#&IDFocus=ConsolidateInvoiceTriggerStatus', '_blank');
				}
			</cfif>
		})
	</script>
</cfoutput>