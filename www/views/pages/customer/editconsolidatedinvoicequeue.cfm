<cfparam name="REL" default="">
<cfparam name="Job" default="">
<cfparam name="paymentTerms" default="">
<cfparam name="Comment" default="">
<cfparam name="InvoiceDate" default="#now()#">
	<cfsilent>
		<cfif isdefined('form.submit') or isdefined('form.print')>
			<cfinvoke component="#variables.objCutomerGateway#" method="setConsolidatedInvoiceInformation" REL="#form.REL#" Job="#form.Job#" Comment="#Comment#" paymentTerms="#form.paymentTerms#" InvoiceDate="#form.InvoiceDate#" ID='#url.editid#' returnvariable="success"/>
			<cfif isdefined('form.print')>
				<cflocation url="../reports/ConsolidatedInvoiceReport.cfm?ConsolidatedInvoiceNumber=#form.ConsolidatedInvoiceNumber#&dsn=#application.dsn#&#session.URLToken#&CompanyID=#session.CompanyID#" />
			</cfif>
			<cflocation url="index.cfm?event=consolidatedinvoicequeue&#session.URLToken#" />
		</cfif>
		<cfinvoke component="#variables.objCutomerGateway#" ID='#url.editid#' method="getConsolidatedInvoiceInformation" returnvariable="request.qGetMaintenanceInformation" />

		<cfinvoke component="#variables.objCutomerGateway#" method="getConsolidateLoadList" searchText="" pageNo="1" returnvariable="qConsolidateLoads" ConsolidatedID="#url.editid#"/>

		
		<cfset  REL = request.qGetMaintenanceInformation.REL>

		<cfif request.qGetMaintenanceInformation.SeperateJobPo NEQ 1 AND request.qGetMaintenanceInformation.JobEdited EQ 0>
			<cfset  Job = request.qGetMaintenanceInformation.Description & ' ' & request.qGetMaintenanceInformation.LoadRoute>
		<cfelse>
			<cfset  Job = request.qGetMaintenanceInformation.Job>
		</cfif>
		<cfset  InvoiceDate = request.qGetMaintenanceInformation.InvoiceDate>
		<cfset  Comment = request.qGetMaintenanceInformation.Comment>
		<cfset  paymentTerms = request.qGetMaintenanceInformation.paymentTerms>

	</cfsilent>
<cfoutput>
	<style>
		.clear{
			margin-top: 10px;
		}
		.bttn{
			background: url(../webroot/images/button-bg.gif) left top repeat-x;
		    border: 1px solid ##b3b3b3;
		    padding: 0 10px 0 10px;
		    height: 48px;
		    font-size: 11px;
		    font-weight: bold;
		    line-height: 20px;
		    text-align: center;
		    margin: 0 10px 8px 0;
		    cursor: pointer;
		    background-size: contain;
		    width: 100px;
    		font-size: 13px;
		}
	</style>
	<script type="text/javascript">
		$(document).ready(function(){
			$( "[type='datefield']" ).datepicker({
				dateFormat: "mm/dd/yy",
				showOn: "button",
				buttonImage: "images/DateChooser.png",
				buttonImageOnly: true
			});
		})
		

	</script>
	<div class="white-con-area" style="height: 40px;background-color: ##82bbef;">
		<div style="float: left; width: 100%; min-height: 40px;">
			<h1 style="color:white;font-weight:bold;margin-left:279px;float: left;">Edit Consolidated Invoice## #request.qGetMaintenanceInformation.ConsolidatedInvoiceNumber#</h1>
			<input type="button" id="btn_consolidate_status_#request.qGetMaintenanceInformation.ConsolidatedInvoiceNumber#" value="#request.qGetMaintenanceInformation.Status#" onclick="changeConsolidatedStatus(#request.qGetMaintenanceInformation.ConsolidatedInvoiceNumber#,'#request.qGetMaintenanceInformation.CustomerID#','#session.CompanyID#','#url.editid#')" style="float:right;width: 58px !important;font-size: 10px;margin-top: 10px;margin-right: 5px;">
		</div>
	</div>
	<div style="clear:left"></div>
	<div class="white-con-area">
		<div class="white-top"></div>
		<div class="white-mid">
			<cfform action="" name="frmMaintenanceInformation" method="post">
				<input type="hidden" name="ConsolidatedInvoiceNumber" value="#request.qGetMaintenanceInformation.ConsolidatedInvoiceNumber#">
				<input type="hidden" id="dsn" value="#application.dsn#">
				<input type="hidden" id="reload" value="1">
				<div class="form-con">
					<fieldset>
						
						<label>Customer</label>
						<input type="text" readonly value="#qConsolidateLoads.CustName#" style="background-color: ##e8e3e3">
						<div class="clear"></div>

						<label>REL##</label>
						<input type="text" name="REL" id="REL" value="#REL#">
						<div class="clear"></div>

						<label>Job</label>
						<textarea class="medium-textbox applynotesPl" name="Job" tabindex=5 cols="" rows="">#Job#</textarea>
						<div class="clear" style="height: 10px;"></div>

						<label>Date</label>
						<input name="InvoiceDate" id="InvoiceDate" value="#dateformat(InvoiceDate,'mm/dd/yyyy')#" type="datefield" style="width:55px;margin-right:10px;"/>
						<div class="clear"></div>
					</fieldset>
				</div>
				<div class="form-con">
					<fieldset>
						
						<label>Payment terms</label>
						<input type="text" name="paymentTerms" id="paymentTerms" value="#paymentTerms#">
						<div class="clear"></div>

						<label>Comment</label>
						<textarea class="medium-textbox applynotesPl" name="Comment" tabindex=5 cols="" rows="">#Comment#</textarea>
						<div class="clear"></div>
						
						<div class="clear" style="border-top: 1px solid ##E6E6E6;margin-top: 21px;" >&nbsp;</div>	
						<div class="clear"></div>
						<button type="submit" name="print" class="bttn" style="margin-left: 111px;">Save &<br>PRINT</button>
						<button type="submit" name="submit" class="bttn">Save &<br>EXIT</button>
						<div class="clear"></div>

						<div id="message" class="msg-area" style="width: 181px;margin-left: 96px;margin-top: 36px; display:<cfif isDefined('success')>block;<cfelse>none;</cfif>">
							<cfif isDefined('success') AND success>
								Information saved successfully
							<cfelseif isDefined('success') AND NOT success>
								unknown <b>Error</b> occured while saving
							</cfif>
						</div>
					</fieldset>
				</div>
				<div class="clear"></div>
			</cfform>
		</div>
		<div class="white-bot"></div>
	</div>
	<table width="100%" border="0" class="data-table" cellspacing="0" cellpadding="0" style="color:##000000;">
  		<thead>
  			<tr>
				<th width="5" align="left" valign="top"><img src="images/top-left.gif" alt="" width="5" height="23" /></th>
				<th width="29" align="center" valign="middle" class="head-bg">&nbsp;</th>
				
				<th width="25" align="center" valign="middle" class="head-bg">Load##</th>
				<th width="50" align="center" valign="middle" class="head-bg">Status</th>
  				<th width="40" align="center" valign="middle" class="head-bg">Customer</th>
				<th width="40" align="center" valign="middle" class="head-bg">PO##</th>
  				<th width="50" align="center" valign="middle" class="head-bg">Ship&nbsp;Date</th>
				<th width="50" align="center" valign="middle" class="head-bg">Ship&nbsp;Time</th>
   				<th width="40" align="center" valign="middle" class="head-bg">Ship&nbsp;City</th>
				<th width="40" align="center" valign="middle" class="head-bg">Ship&nbsp;ST</th>
				<th width="50" align="center" valign="middle" class="head-bg">Del.&nbsp;Date</th>
				<th width="50" align="center" valign="middle" class="head-bg">Del.&nbsp;Time</th>
   				<th width="40" align="center" valign="middle" class="head-bg">Del.&nbsp;City</th>
				<th width="35" align="center" valign="middle" class="head-bg">Del.&nbsp;ST</th>
				<th width="50" align="center" valign="middle" class="head-bg">Cust.&nbsp;Amt</th>
				<th width="50" align="center" valign="middle" class="head-bg">Carr.&nbsp;Amt</th>
				<th width="30" align="center" valign="middle" class="head-bg">Carrier</th>
				<th width="30" align="center" valign="middle" class="head-bg">Equipment</th>
				<th width="30" align="center" valign="middle" class="head-bg">Driver</th>
				<th width="30" align="center" valign="middle" class="head-bg">Dispatcher</th>
				<th width="30" align="center" valign="middle" class="head-bg2">Sales Rep</th>
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
					<cfset onHrefClick = "index.cfm?event=addload&loadid=#qConsolidateLoads.LOADID#&#session.URLToken#">
					<td  align="center" valign="middle" nowrap="nowrap" class="normal-td" style="padding-right: 5px;" onclick="location.href='#onHrefClick#'"><a href="#onHrefClick#" style="color:###qConsolidateLoads.TextColorCode#">#qConsolidateLoads.LoadNumber#</a></td>
					<td align="center" valign="middle" nowrap="nowrap" class="normal-td" style="padding-right: 5px;"onclick="location.href='#onHrefClick#'"><a href="#onHrefClick#" style="color:###qConsolidateLoads.TextColorCode#">#qConsolidateLoads.StatusDescription#</a></td>
					<td align="left" valign="middle" nowrap="nowrap" class="normal-td" style="padding-right: 5px;"onclick="location.href='#onHrefClick#'"><a href="#onHrefClick#" style="color:###qConsolidateLoads.TextColorCode#">#qConsolidateLoads.CustName#</a></td>
					<td align="right" valign="middle" nowrap="nowrap" class="normal-td" style="padding-right: 5px;"onclick="location.href='#onHrefClick#'"><a href="#onHrefClick#" style="color:###qConsolidateLoads.TextColorCode#">#qConsolidateLoads.CustomerPONo#</a></td>
					<td align="right" valign="middle" nowrap="nowrap" class="normal-td"  style="padding-right: 5px;"onclick="location.href='#onHrefClick#'"><a href="#onHrefClick#" style="color:###qConsolidateLoads.TextColorCode#">#dateformat(qConsolidateLoads.ShipDate,'mm/dd/yyyy')#</a></td>
					<td align="left" valign="middle" nowrap="nowrap" class="normal-td"onclick="location.href='#onHrefClick#'"><a href="#onHrefClick#" style="color:###qConsolidateLoads.TextColorCode#">#qConsolidateLoads.ShipTime#</a></td>
					<td align="left" valign="middle" nowrap="nowrap" class="normal-td"onclick="location.href='#onHrefClick#'"><a href="#onHrefClick#" style="color:###qConsolidateLoads.TextColorCode#">#qConsolidateLoads.ShipCity#</a></td>
					<td align="left" valign="middle" nowrap="nowrap" class="normal-td"onclick="location.href='#onHrefClick#'"><a href="#onHrefClick#" style="color:###qConsolidateLoads.TextColorCode#">#qConsolidateLoads.ShipState#</a></td>
					<td align="left" valign="middle" nowrap="nowrap" class="normal-td"  style="padding-right: 5px;"><a href="#onHrefClick#" style="color:###qConsolidateLoads.TextColorCode#">#dateformat(qConsolidateLoads.DelDate,'mm/dd/yyyy')#</a></td>
					<td align="left" valign="middle" nowrap="nowrap" class="normal-td"onclick="location.href='#onHrefClick#'"><a href="#onHrefClick#" style="color:###qConsolidateLoads.TextColorCode#">#qConsolidateLoads.DelTime#</a></td>
					<td align="left" valign="middle" nowrap="nowrap" class="normal-td"onclick="location.href='#onHrefClick#'"><a href="#onHrefClick#" style="color:###qConsolidateLoads.TextColorCode#">#qConsolidateLoads.DelCity#</a></td>
					<td align="left" valign="middle" nowrap="nowrap" class="normal-td"onclick="location.href='#onHrefClick#'"><a href="#onHrefClick#" style="color:###qConsolidateLoads.TextColorCode#">#qConsolidateLoads.DelState#</a></td>
					<td align="right" valign="middle" nowrap="nowrap" class="normal-td" style="padding-right: 5px;"onclick="location.href='#onHrefClick#'"><a href="#onHrefClick#" style="color:###qConsolidateLoads.TextColorCode#">#DollarFormat(qConsolidateLoads.TotalCustomerCharges)#</a></td>
					<td align="right" valign="middle" nowrap="nowrap" class="normal-td" style="padding-right: 5px;"onclick="location.href='#onHrefClick#'"><a href="#onHrefClick#" style="color:###qConsolidateLoads.TextColorCode#">#DollarFormat(qConsolidateLoads.TotalCarrierCharges)#</a></td>
					<td align="left" valign="middle" nowrap="nowrap" class="normal-td"onclick="location.href='#onHrefClick#'"><a href="#onHrefClick#" style="color:###qConsolidateLoads.TextColorCode#">#qConsolidateLoads.CarrierName#</a></td>
					<td align="left" valign="middle" nowrap="nowrap" class="normal-td"onclick="location.href='#onHrefClick#'"><a href="#onHrefClick#" style="color:###qConsolidateLoads.TextColorCode#">#qConsolidateLoads.EquipmentName#</a></td>
					<td align="left" valign="middle" nowrap="nowrap" class="normal-td" style="padding-right: 5px;"onclick="location.href='#onHrefClick#'"><a href="#onHrefClick#" style="color:###qConsolidateLoads.TextColorCode#">#qConsolidateLoads.DriverName#</a></td>
					<td align="left" valign="middle" nowrap="nowrap" class="normal-td"onclick="location.href='#onHrefClick#'"><a href="#onHrefClick#" style="color:###qConsolidateLoads.TextColorCode#">#qConsolidateLoads.EmpDispatch#</a></td>
					<td align="left" valign="middle" nowrap="nowrap" class="normal-td2"onclick="location.href='#onHrefClick#'"><a href="#onHrefClick#" style="color:###qConsolidateLoads.TextColorCode#">#qConsolidateLoads.SalesAgent#</a></td>
					<td class="normal-td3">&nbsp;</td>
	 			</tr>
	 		</cfloop>
		</tbody>
	 	<tfoot>
	 		<tr>
				<td width="5" align="left" valign="top"><img src="images/left-bot.gif" alt="" width="5" height="23" /></td>
				<td colspan="20" align="left" valign="middle" class="footer-bg">
					
				</td>
				<td width="5" align="right" valign="top"><img src="images/right-bot.gif" alt="" width="5" height="23" /></td>
	 		</tr>	
	 	</tfoot>	  
	</table>
</cfoutput>