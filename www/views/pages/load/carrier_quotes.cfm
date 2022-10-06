<!---Functuin for triming input string--->
<cfset variables.Secret = application.dsn>
<cfset variables.TheKey = 'NAMASKARAM'>
<cfset variables.Encrypted = Encrypt(variables.Secret, variables.TheKey)>
<cfset variables.dsn = ToBase64(variables.Encrypted)>
<cfif structkeyexists(session,'iscustomer') AND val(session.iscustomer)>
	<cfset customer = 1>
<cfelse>
	<cfset customer = 0>
</cfif>
<cfoutput>
<style>
	.MyloadTableWrap table td {
	    word-wrap: break-word;
	    white-space: normal;
	}
	.tbl_quote_list tbody tr:nth-child(odd) {background: ##CCC}
    .tbl_quote_list tbody tr:nth-child(even) {background: ##f3f1f1}	
	.tbl_quote_list tbody tr td{text-align: center;padding:3px;}
</style>
</cfoutput>
<cffunction name="truncateMyString" access="public" returntype="string">
	<cfargument name="endindex" type="numeric" required="true"  />
	<cfargument name="inputstring" type="string" required="true"  />

	<cfif Len(inputstring) le endindex>
		<cfset inputstring=inputstring.substring(0, Len(inputstring))>
	<cfelse>
		<cfset inputstring=inputstring.substring(0, endindex)>
	</cfif>

	<cfreturn inputstring>
</cffunction>
<!---Functuin for triming input string--->

<cfparam name="message" default="">
<cfparam name="url.linkid" default="">

<cfparam name="sortorder" default="ASC">
<cfparam name="sortby"  default="LS.StatusText">
<cfparam name="variables.searchTextStored"  default="">
<cfparam name="session.searchtext"  default="">
<cfif StructKeyExists(form,"searchtext")>
	<cfif structkeyexists(form,"rememberSearch")>
		<cfset session.searchtext = form.searchtext>
		<cfset variables.searchTextStored=session.searchtext>
	<cfelse>
		<cfset session.searchtext = "">
		<cfset variables.searchTextStored=form.searchtext>
	</cfif>
<cfelse>
	<cfset variables.searchTextStored=session.searchtext>
</cfif>
<cfinvoke component="#variables.objloadGateway#" method="getLoadStatus" returnvariable="request.qLoadStatus" />
<cfsilent>

<cfinvoke component="#variables.objloadGateway#" method="getLoadSystemSetupOptions" returnvariable="request.qSystemSetupOptions1" />

<cfset pageSize = 30>
<cfif structKeyExists(request.qSystemSetupOptions1, "rowsperpage") AND request.qSystemSetupOptions1.rowsperpage>
	<cfset pageSize = request.qSystemSetupOptions1.rowsperpage>
</cfif>
<!--- Getting page1 of All Results --->
<cfinvoke component="#variables.objloadGateway#" method="getLoadCarrierQuotesReport" searchText="#variables.searchTextStored#" pageNo="1" rowsperpage="#pageSize#" returnvariable="qLoads" sortby="#sortby#" sortorder="#sortorder#" />

<cfif structkeyexists(session,"empid")>
	<cfif len(trim(session.empid))>
		<cfinvoke component="#variables.objloadGateway#" method="getcurAgentdetails" employeID="#session.empid#" returnvariable="request.qrygetAgentdetails" />
	</cfif>
</cfif>

<!--- Handeling Advance Search Ended --->
</cfsilent>
<link href="file:///D|/loadManagerForDrake/webroot/styles/style.css" rel="stylesheet" type="text/css" />
<cfoutput>
	<h1>Carrier Quotes</h1>
	<div style="clear:left;"></div>

	<div id="message" class="msg-area" style="display:none;">No match found</div>
	<cfif structkeyExists(session, 'isSaferWatchCarrierUpdate') AND session.isSaferWatchCarrierUpdate EQ 1>
		<script type="text/javascript">
			newwindow = window.open('?event=saferWatchCarrierUpdate', '_blank');
		</script>
		<cfset structDelete(session, 'isSaferWatchCarrierUpdate')>
	<cfelse>

	</cfif>
	<cfif structKeyExists(session,"message") AND session.message NEQ "" >
		<div class="col-md-12">&nbsp;</div>
		<div id="messageLoadsExportedForCustomer" class="msg-area">#session.message#</div>
		<cfset session.message = "">
	</cfif>
	<div id="messageLoadsExportedForCustomer" class="msg-area" style="display:none;"></div>
	<div id="messageLoadsExportedForCarrier" class="msg-area" style="display:none;"></div>
	<div id="messageLoadsExportedForBoth" class="msg-area" style="display:none;"></div>
	<div id="messageWarning" class="errormsg-area" style="display:none;"></div>

	<div class="search-panel" style="width:100%;">
    	<div class="form-search">
		<cfset actionUrl = 'index.cfm?event=#url.event#&#session.URLToken#'>
		<cfset csrfToken=CSRFGenerateToken() />

		<cfform id="dispLoadForm" name="dispLoadForm" action="#actionUrl#" method="post" preserveData="yes">
			<cfinput id="pageNo" name="pageNo" value="1" type="hidden">
		    <cfinput id="sortOrder" name="sortOrder" value="ASC"  type="hidden">
		    <cfinput id="sortBy" name="sortBy" value="statusText"  type="hidden">
		    <cfinput id="weekMonth" name="weekMonth" value="" type="hidden">
			<cfinput id="txtBol" name="txtBol" value="" type="hidden">
			<cfinput id="txtDispatcher" name="txtDispatcher" value="" type="hidden">
			<cfinput id="txtAgent" name="txtAgent" value="" type="hidden">
			<cfinput id="csfrToken" name="csfrToken" value="#csrfToken#" type="hidden">
			<fieldset>
				<cfif request.qSystemSetupOptions1.LoadsColumnsSetting EQ 1>
					<cfset placeHolderTxt = "Load##, Driver,TRK ##,TRL ##,Customer,.....">
					<cfset titleTxt = "Load##, Driver,TRK ##,TRL ##,Customer,Shipper,Commidity,Consignee,DelTime..">
				<cfelse>
					<cfset placeHolderTxt = "Load##, Status, Customer, PO##, BOL##, Carr......">
					<cfset titleTxt = "Load##, Status, Customer, PO##, BOL##, Carrier, City, State, Dispatcher ">
						<cfif request.qSystemSetupOptions1.freightBroker>
							<cfset titleTxt = titleTxt&"OR Agent">
						<cfelse>
							<cfset titleTxt =  titleTxt&"OR"&left(request.qSystemSetupOptions1.userDef7,9) >
						</cfif>
						<cfset titleTxt =  titleTxt&",shipdate">
				</cfif>
				<cfinvoke component="#variables.objloadGateway#" method="getSystemSetupOptions" returnvariable="request.qGetSystemSetupOptions" />
				<input type="hidden" name="LoadNumberAutoIncrement" id="LoadNumberAutoIncrement" value="#request.qGetSystemSetupOptions.LoadNumberAutoIncrement#">
				<input name="searchText"  style="width:224px;" type="text" placeholder="#placeHolderTxt#" value="#variables.searchTextStored#" id="searchText"  class="InfotoolTip" title="#titleTxt#" />
				<input name="" onclick="clearPreviousSearchHiddenFields()" type="submit" class="s-bttn" value="Search" style="width:56px;" />
	    		<input name="rememberSearch" type="checkbox" class="s-bttn" value="" <cfif session.searchtext neq "">checked="true"</cfif> id="rememberSearch" style="width: 15px;margin-left: 15px;margin-top: 3px;" onclick="rememberSearchSession(this);" />
				<div style="margin-left: 6px; margin-top: 5px;float: left;color: ##3a5b96;;">Remember Search</div>
				<div class="clear"></div>
			</fieldset>
		</cfform>

		<cfif isdefined('weekOrMonth') AND weekOrMonth neq "">
	    	<cfset form.weekMonth = '#weekOrMonth#'>
	        <script> document.getElementById('weekMonth').value='#weekOrMonth#' </script>
	    </cfif>

	    <cfif isdefined("form.weekMonth") AND form.weekMonth neq "">
			<cfinvoke component="#variables.objloadGateway#" method="getSearchLoads" agentUserName="#request.myLoadsAgentUserName#" rowsperpage="#pageSize#" returnvariable="qLoads">
	       		<cfinvokeargument name="#form.weekMonth#" value="#form.weekMonth#">
	       		<cfif isdefined('form.pageNo')>
	        		<cfinvokeargument name="pageNo" value="#form.pageNo#">
		        <cfelse>
			        <cfinvokeargument name="pageNo" value="1">
	        	    <cfset form.pageNo = 1>
	        	</cfif>

	            <cfif isdefined('form.sortOrder')>
		            <cfinvokeargument name="sortorder" value="#form.sortOrder#">
	            </cfif>
	            <cfif isdefined('form.sortBy')>
		            <cfinvokeargument name="sortby" value="#form.sortBy#">
	            </cfif>
			</cfinvoke>
		</cfif>

		<cfif isdefined('searchSubmitLocal') AND (searchSubmitLocal eq 'yes')>
	        <cfset form.LoadStatusAdv = '#LoadStatusAdv#'>
	        <cfset form.LoadNumberAdv = '#LoadNumberAdv#'>
	        <cfset form.OfficeAdv = '#OfficeAdv#'>
			<cfset form.shipperCityAdv = '#shipperCityAdv#'>
	        <cfset form.consigneeCityAdv = '#consigneeCityAdv#'>
	        <cfset form.ShipperStateAdv = '#ShipperStateAdv#'>
	        <cfset form.ConsigneeStateAdv = '#ConsigneeStateAdv#'>
	        <cfset form.CustomerNameAdv = '#CustomerNameAdv#'>
	        <cfset form.StartDateAdv = '#StartDateAdv#'>
	        <cfset form.EndDateAdv = '#EndDateAdv#'>
	        <cfset form.CarrierNameAdv = '#CarrierNameAdv#'>
	        <cfset form.CustomerPOAdv = '#CustomerPOAdv#'>
			<cfset form.txtBol = '#LoadBol#'>
			<cfset form.txtDispatcher  = '#carrierDispatcher#'>
			<cfset form.txtAgent  = '#carrierAgent#'>
	    </cfif>
	</div>
</div>
<div class="clear"></div>
<cfform id="dispLoadFormUdateShipDate" name="dispLoadFormUdateShipDate" action="#actionUrl#" method="post" preserveData="yes">	
		<table width="100%" border="0" cellspacing="0" cellpadding="0" class="data-table glossy-bg-blue">
			<tr class="glossy-bg-blue">
				<th width="5" class="" align="left" valign="top" style="border:1px solid ##5d8cc9;">
				<span></span>
					<span class="up-down gen-left">
						<span class="arrow-top"><a href="javascript: tablePrevPage('dispLoadForm');" style="padding-left:5px !important;"><img src="images/arrow-top.gif" alt=""  style="width: 10px;"/></a></span>
						<span class="arrow-bot"><a href="javascript: tableNextPage('dispLoadForm');"><img src="images/arrow-bot.gif" alt=""  style="width: 10px;" /></a></span>
					</span>						
					<span class="gen-left"><a href="javascript: tablePrevPage('dispLoadForm');">&nbsp;&nbsp;Prev </a>-<a href="javascript: tableNextPage('dispLoadForm');"> Next</a></span>
					<span class="gen-right"></span>
					<span class="span"></div>
				</th>													
			 </tr>
		</table>
		<table width="100%" border="0" cellspacing="0" cellpadding="0" class="data-table">			  
			<thead>
				<tr>
					<th width="5" align="left" valign="top" class="fillHeader"></th>
					<th width="29" align="center" valign="middle" class="head-bg numbering">&nbsp;</th>
					<th align="center" valign="middle" class="head-bg load" onclick="sortTableBy('l.LoadNumber','dispLoadForm');">LOAD##</th>
					<th align="center" style="width:10% !important;" valign="middle" class="head-bg " onclick="sortTableBy('LS.StatusText','dispLoadForm');">Status </th>
					<th align="center" style="width:10% !important;" valign="middle" class="head-bg " onclick="sortTableBy('L.NewPickupDate','dispLoadForm');">Pickup Date</th>
					<th align="center" style="width:10% !important;"  valign="middle" class="head-bg " onclick="sortTableBy('L.CustName','dispLoadForm');">Customer</th>
					<th align="center" style="width:10% !important;" valign="middle" class="head-bg "">First Stop</th>
					<th align="center"  style="width:10% !important;" valign="middle" class="head-bg ">Last Stop</th>
					<th align="center"  style="width:10% !important;" valign="middle" class="head-bg " onclick="sortTableBy('L.TotalCustomerCharges','dispLoadForm');">Customer Total</th>
					<th align="center"  style="width:10% !important;" valign="middle" class="head-bg " onclick="sortTableBy('L.TotalCarrierCharges','dispLoadForm');">Carrier Total</th>
					<th align="center"  style="width:10% !important;" valign="middle" class="head-bg ">Gross Margin</th>
					<th align="center"  style="width:10% !important;" valign="middle" class="head-bg ">Commodity</th>
					<th align="center"  style="width:10% !important;" valign="middle" class="head-bg " onclick="sortTableBy('L.EquipmentName','dispLoadForm');">Equipment</th>
				</tr>
		  	</thead>
		  	<tbody>			  
				<cfloop query="qLoads" group="LoadNumber">
					<tr onclick="showList(#qLoads.LoadNumber#)" style="background:###qLoads.ColorCode#; cursor:pointer;" onmouseover="this.style.background = '##FFFFFF';" onmouseout="this.style.background = '###qLoads.ColorCode#';" <cfif qLoads.Row mod 2 eq 0>bgcolor="##FFFFFF"<cfelse>bgcolor="##f7f7f7"</cfif>>	
						<td height="20" class="sky-bg">&nbsp;</td>						
						<td align="center" valign="middle" nowrap="nowrap" class="sky-bg2" >#qLoads.Row#</td>
				
						<td align="left" valign="middle" nowrap="nowrap" class="normal-td">#qLoads.loadNumber#</td>
						<td align="left" valign="middle" nowrap="nowrap" class="normal-td">#qLoads.StatusDescription#</td>
						<td align="left" valign="middle" nowrap="nowrap" class="normal-td">#DateFormat(qLoads.NewPickupDate,'mm/dd/yyyy')#</td>
						<td align="left" valign="middle" nowrap="nowrap" class="normal-td">#qLoads.CustName#</td>
						<td align="left" valign="middle" nowrap="nowrap" class="normal-td">#qLoads.FirstStop#</td>
						<td align="left" valign="middle" nowrap="nowrap" class="normal-td">#qLoads.LastStop#</td>
						<td align="left" valign="middle" nowrap="nowrap" class="normal-td">#DollarFormat(qLoads.TotalCustomerCharges)#</td>
						<td align="left" valign="middle" nowrap="nowrap" class="normal-td">#DollarFormat(qLoads.TotalCarrierCharges)#</td>
						<td align="left" valign="middle" nowrap="nowrap" class="normal-td">#DollarFormat(GrossMargin)#</td>
						<td align="left" valign="middle" nowrap="nowrap" class="normal-td">#qLoads.Commodity#</td>
						<td align="left" valign="middle" nowrap="nowrap" class="normal-td">#qLoads.LoadEquipmentName#</td>
					</tr>
					<tr id="QuotesList#qLoads.LoadNumber#" class="QuotesList" style="display:none">
						<td></td>
						<td></td>
						<td></td>
						<td colspan="10">
							<table width="100%" class="tbl_quote_list">
	                            <thead>
	                                <tr  style="background-color: ##4a98dc;color: ##fff;">
	                                    <th>Quote Amt</th>
	                                    <th>Carrier Name</th>
	                                    <th>Carrier MC</th>
	                                    <th>Contact</th>
	                                    <th>Phone</th>
	                                    <th>Active</th>
	                                    <th>Mileage</th>
	                                    <th>Price/Mile</th>
	                                    <th>Equipment</th>
	                                </tr>
	                            </thead>
	                            <tbody>
	                            	<cfloop group="CarrierQuoteID">
	                            		<cfif len(CarrierQuoteID)>
			                                <tr>
			                                    <td>
			                                        #DollarFormat(Amount)#
			                                    </td>
			                                    <td>#CarrierName#</td>
			                                    <td>#MCNumber#</td>
			                                    <td>#ContactPerson#</td>
			                                    <td>#phone#</td>
			                                    <td>#Active#</td>
			                                    <td>#Miles#</td>
			                                    <td>
			                                    	<cfif Amount gt 0 and Miles gt 0>
				                                    	#DollarFormat(Amount/Miles)#
				                                	<cfelse>
				                                		N/A
				                                	</cfif>
				                                </td>
			                                    <td>#EquipmentName#</td>
			                                </tr>  
			                            <cfelse>
			                            	<tr>
			                            		<td colspan="9">No Records Found</td>
			                            	</tr>
			                            </cfif>
		                            </cfloop>
	                            </tbody>
		                    </table>
						</td>
					</tr>
				</cfloop>
			</tbody>	
			<tfoot>
			<tr>
				<td width="5" align="left" valign="top"><img src="images/left-bot.gif" alt="" width="5" height="23" /></td>
				<td colspan='9' align="left" valign="middle" class="footer-bg">
					<div class="up-down">
						<div class="arrow-top">
							<a href="javascript: tablePrevPage('dispLoadForm');"><img src="images/arrow-top.gif" alt="" /></a>
						</div>
						<div class="arrow-bot">
							<a href="javascript: tableNextPage('dispLoadForm');"><img src="images/arrow-bot.gif" alt="" /></a>
						</div>
					</div>
					<div class="gen-left">
						<a href="javascript: tablePrevPage('dispLoadForm');">Prev </a>-<a href="javascript: tableNextPage('dispLoadForm');"> Next</a>
					</div>
					<div class="gen-right"><img src="images/loader.gif" alt="" /></div>
					<div class="clear"></div>
				</td>
				<td class="footer-bg"></td>
				<td class="footer-bg"></td>
				<td width="6" align="right" valign="top"><img src="images/right-bot.gif" alt="" width="5" height="23" /></td>
			</tr>
			</tfoot>		
		</table>
	</cfform>
	<div id="responseCopyLoad"></div>
<script>
	function showList(no){
		$( '.QuotesList' ).each(function() {
			if(this.id != 'QuotesList'+no){
				$(this).hide();
			}
		});
		$('##QuotesList'+no).toggle();
	}
</script>
</cfoutput>



