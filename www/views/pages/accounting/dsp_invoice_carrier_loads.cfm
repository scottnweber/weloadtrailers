<cfparam name="sortorder" default="desc">
<cfparam name="sortby"  default="">
<cfparam name="searchText"  default=" ">
<cfparam name="pageNo"  default="1">
<cfparam name="form.InvoiceDateFrom"  default="">
<cfparam name="form.InvoiceDateTo"  default="">
<cfoutput>
    <cfinvoke component="#variables.objloadGateway#" method="getSystemSetupOptions" returnvariable="request.qGetSystemSetupOptions" />
    <cfif structKeyExists(form, "InvoiceLoads")>
        <cfinvoke component="#variables.objLoadGateway#" method="getLMASystemConfig" returnvariable="qLMASystemConfig" />
        <cfset session.InvLoadsMsg = structNew()>
        <cfset CostOfFreightSales = qLMASystemConfig['AR Cost of Sales']>
        <cfset APGLAccount = qLMASystemConfig['AP GL Account']>
        <cfset FiscalYear = qLMASystemConfig['Fiscal Year']>

        <cfif form.count EQ 0>
            <cfset session.InvLoadsMsg.res = 'error'>
            <cfset session.InvLoadsMsg.msg = "Unable to create invoice. No loads found.">
        <cfelseif NOT len(trim(CostOfFreightSales)) OR NOT len(trim(APGLAccount)) >
            <cfset session.InvLoadsMsg.res = 'error'>
            <cfset session.InvLoadsMsg.msg = "No account number has been setup for this transaction. Please correct this and try again.">
        <cfelse>
            <cfset form.CostOfFreightSales = qLMASystemConfig['AR Cost of Sales']>
            <cfset form.APGLAccount = qLMASystemConfig['AP GL Account']>
            <cfinvoke frmStruct="#form#" component="#variables.objLoadGateway#" method="InvoiceCarrierLoads" returnvariable="resp"/>
            <cfset session.InvLoadsMsg = resp>
            <cflocation url="index.cfm?event=InvoiceCarrierLoads&#session.URLToken#">
        </cfif>
    </cfif>
    <cfif request.qGetSystemSetupOptions.freightbroker EQ 0>
        <cfset variables.freightbroker = "Driver">
    <cfelseif request.qGetSystemSetupOptions.freightbroker EQ 1>
        <cfset variables.freightbroker = "Carrier">
    <cfelse>
        <cfset variables.freightbroker = "Carrier/Driver">
    </cfif>
    <cfinvoke frmStruct="#form#" component="#variables.objLoadGateway#" method="getInvoiceCarrierLoads" returnvariable="qInvoiceLoads" />
    <cfinvoke component="#variables.objLoadGateway#" method="getAPInvoiceCustomerCarrierTotals" frmStruct="#form#" returnvariable="qTotals" />
    <style type="text/css">
        ul##ui-id-1 {
            overflow: scroll;
            height: 250px;
        }
        .sm-input{
            width: 60px !important;
            height: 18px;
            background: ##FFFFFF;
            border: 1px solid ##b3b3b3;
            padding: 2px 2px 0 2px;
            margin: 0 0 8px 0;
            font-size: 11px;
            margin-right: 8px !important;
        }
        .btn{
            background: url(../webroot/images/button-bg.gif) left top repeat-x;
            border: 1px solid ##b3b3b3;
            padding: 0 10px;
            height: 20px;
            font-size: 11px;
            font-weight: bold;
            line-height: 20px;
            text-align: center;
            margin: 2px;
            color: ##599700;
            width: 125px !important;
            cursor: pointer;
        }
        .msg-area-success{
            border: 1px solid ##a4da46;
            padding: 5px 15px;
            font-weight: normal;
            width: 92%;
            float: left;
            margin-top: 5px;
            margin-bottom:  5px;
            background-color: ##b9e4b9;
            font-weight: bold;
            font-style: italic;
        }
        .msg-area-error{
            border: 1px solid ##da4646;
            padding: 5px 15px;
            font-weight: normal;
            width: 92%;
            float: left;
            margin-top: 5px;
            margin-bottom:  5px;
            background-color: ##e4b9c6;
            font-weight: bold;
            font-style: italic;
        }
        .reportsSubHeading{
            color: ##7e7e7e;
            padding: 0px 0 10px 10px;
            margin: 0;
            font-size: 14px;
            font-weight: normal;
            border-bottom: 1px solid ##77463d !important;
            margin-bottom: 5px !important;
        }
    </style>
    <script>
        $(document).ready(function(){
            $('##InvoiceDateFrom').focus();

            $( ".datefield" ).datepicker({
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
            $('.datefield').change(function(){
                var InvoiceDateFrom = $('##InvoiceDateFrom').val();
                var InvoiceDateTo = $('##InvoiceDateTo').val();

                if($.trim(InvoiceDateFrom).length && $.trim(InvoiceDateTo).length && new Date($.trim(InvoiceDateFrom)) <= new Date($.trim(InvoiceDateTo))){
                    $('##data-content ').html('<tr><td colspan="10" align="center" style="border-left: 1px solid ##5d8cc9;border-right: 1px solid ##5d8cc9;"><img src="images/loadDelLoader.gif" style="margin-top: 25px;"><br>Please wait...</td></tr>');
                    $('##dispARExportForm').submit();
                }
                else if(!$.trim(InvoiceDateFrom).length && !$.trim(InvoiceDateTo).length){
                    $('##data-content ').html('<tr><td colspan="10" align="center" style="border-left: 1px solid ##5d8cc9;border-right: 1px solid ##5d8cc9;"><img src="images/loadDelLoader.gif" style="margin-top: 25px;"><br>Please wait...</td></tr>');
                    $('##dispARExportForm').submit();
                }
            });
        })
        function selectAllLoads(){
            var ckd = $('##ckInvoiceLoadsAll').is(":checked");
            $('.ckInvoiceLoads').prop("checked",ckd);
            uncheckLoad()
        }

        function uncheckLoad(){
            var ArrLoadID = [];
            $('.ckInvoiceLoads').each(function(){
                if(!$(this).is(":checked")){
                    ArrLoadID.push($(this).val());
                }
            });
            $('##ExcludeLoads').val(ArrLoadID)
        }
    </script>
    <div class="white-con-area" style="height: 36px;background-color: ##82bbef;width:95%;">
        <div style="float: left;">
            <h2 style="color:white;font-weight:bold;margin-left: 12px;">Invoice #variables.freightbroker# Loads</h2>
        </div>
    </div>
    <div style="clear:left"></div>
    <div class="search-panel" style="width:100%;">
        <div class="form-search" style="width:95%;background-color: #request.qGetSystemSetupOptions.BackgroundColorForContentAccounting# !important;padding-bottom: 10px;">
            <cfform id="dispARExportForm" name="dispARExportForm" action="index.cfm?event=InvoiceCarrierLoads&#session.URLToken#" method="post" preserveData="yes">
                <cfinput id="pageNo" name="pageNo" value="1" type="hidden">
                <cfinput id="sortOrder" name="sortOrder" value="ASC" type="hidden">
                <cfinput id="sortBy" name="sortBy" value="LoadNumber" type="hidden">
                <input type="hidden" value="#qInvoiceLoads.RecordCount#" id="Count" name="Count">
                <input type="hidden" name="ExcludeLoads"  id="ExcludeLoads" value="">
                <fieldset style="width:45%;padding:5px;float:left;">
                    <h2 class="reportsSubHeading">Enter Invoice Date Range</h2>
                    <div style="float: left;">
                        <label style="font-weight: bold;width:30px;margin-left: 20px;">From:</label>
                        <input class="sm-input datefield" tabindex=4 id="InvoiceDateFrom" name="InvoiceDateFrom"  onchange="InvoiceDateFormat(this);checkDateFormatAll(this);" value="<cfif structKeyExists(form, "InvoiceDateFrom")>#DateFormat(form.InvoiceDateFrom,'mm/dd/yyyy')#</cfif>" type="text" />
                    </div>
                    <div style="float: left;">
                        <label style="font-weight: bold;width:30px;">To:</label>
                        <input class="sm-input datefield" tabindex=4 id="InvoiceDateTo" name="InvoiceDateTo"  onchange="InvoiceDateFormat(this);checkDateFormatAll(this);" value="<cfif structKeyExists(form, "InvoiceDateTo")>#DateFormat(form.InvoiceDateTo,'mm/dd/yyyy')#</cfif>" type="text" />
                    </div>
                    <div style="float: left;">
                        <button class="btn" name="dateRangeSubmit" style="display:none;"><b>Submit</b></button>
                    </div>
                </fieldset>
                <cfset CustomerTotal =0>
                <cfset CarrierTotal =0>
                <cfset CustomerTotalCount =0>
                <cfset CarrierTotalCount =0>
                <cfloop query="qTotals" group="loadid">
                    <cfif qTotals.TotalCustomerCharges GT 0>
                        <cfset CustomerTotal =CustomerTotal+qTotals.TotalCustomerCharges>
                        <cfset CustomerTotalCount =CustomerTotalCount+1>
                    </cfif>

                    <cfif qTotals.TotalCarrierCharges GT 0>
                        <cfset CarrierTotal =CarrierTotal+qTotals.TotalCarrierCharges>
                        <cfset CarrierTotalCount =CarrierTotalCount+1>
                    </cfif>
                </cfloop>
                <fieldset style="width:14%;padding:5px;float:left;margin-left: 10px;">
                    <h2 class="reportsSubHeading">Customer Totals</h2>
                    <input class="sm-input" tabindex=4 id="CustomerTotals" value="#DollarFormat(CustomerTotal)#" type="text" style="color:##008000;width:73px !important" readonly/>
                    <input class="sm-input" tabindex=4 id="CustomerNo" value="#CustomerTotalCount#" type="text" 
                    style="width:25px !important;color:##008000" readonly/>
                </fieldset>
                <fieldset style="width:14%;padding:5px;float:left;margin-left: 10px;">
                    <h2 class="reportsSubHeading">#variables.freightbroker# Totals</h2>
                    <input class="sm-input" tabindex=4 id="CarrierTotals" value="#DollarFormat(CarrierTotal)#" type="text" style="color:##FF0000;width:73px !important" readonly/>
                    <input class="sm-input" tabindex=4 id="CarrierNo" value="#CarrierTotalCount#" type="text" 
                    style="width:25px !important;color:##FF0000" readonly/>
                </fieldset>
                <fieldset style="border-width: 2px;border-style: ridge;border-color: threedface;border-image: initial;width:15%;padding:5px;float:left;margin-left: 10px;margin-top: 7px;text-align: center;">
                    <button class="btn" name="InvoiceLoads" style="height: 32px;background-size: contain;"><b>Invoice Loads</b></button>
                </fieldset>
            </cfform>     
        </div>
    </div>
    <div style="clear:left"></div>
    <cfif structKeyExists(session, "InvLoadsMsg") AND structKeyExists(session.InvLoadsMsg, "res")>
        <div id="message" class="msg-area-#session.InvLoadsMsg.res#">#session.InvLoadsMsg.msg#</div>
        <cfset structDelete(session, "InvLoadsMsg")>
    </cfif>
    <div style="clear:both"></div>
	<cfset pageSize = 30>
    <cfif isdefined("form.pageNo")>
        <cfset rowNum = ((form.pageNo-1)*pageSize)>
    <cfelse>
        <cfset rowNum = 0>
    </cfif>

    <table width="95%" border="0" class="data-table" cellspacing="0" cellpadding="0" style="color:##000000;">
        <thead>
            <tr>
                <th width="5" align="center" valign="middle" class="head-bg" style="border-left: 1px solid ##5d8cc9;border-top-left-radius: 5px;">&nbsp;</th>
                <th align="center" valign="middle" class="head-bg" width="10">
                    <input type="checkbox" name="ckInvoiceLoadsAll" id="ckInvoiceLoadsAll" value="" checked onclick="selectAllLoads()">
                </th>
                <th width="60" align="center" valign="middle" class="head-bg" onclick="sortTableBy('L.LoadNumber','dispARExportForm')">Load##</th>
                <th width="75" align="center" valign="middle" class="head-bg" onclick="sortTableBy('StatusText','dispARExportForm')">StatusText</th>
                <th width="250" align="center" valign="middle" class="head-bg" onclick="sortTableBy('ISNULL(L.CarrierName,L.LoadDriverName)','dispARExportForm')">#variables.freightbroker#</th>
                <th width="75" align="center" valign="middle" class="head-bg" onclick="sortTableBy('L.NewPickupDate','dispARExportForm')">Pickup Date</th>
    	        <th width="75" align="center" valign="middle" class="head-bg" onclick="sortTableBy('L.BillDate','dispARExportForm')">Invoice Date</th>
                <th width="60" align="center" valign="middle" class="head-bg" onclick="sortTableBy('L.TotalCustomerCharges','dispARExportForm')">Customer Amt</th>
                <th width="60" align="center" valign="middle" class="head-bg2" onclick="sortTableBy('L.TotalCarrierCharges','dispARExportForm')" style="border-right: 1px solid ##5d8cc9;border-top-right-radius: 5px;">#variables.freightbroker# Amt</th>
            </tr>
        </thead>
        <tbody id="data-content">
            <cfif qInvoiceLoads.recordcount>
                <cfloop query="qInvoiceLoads">
                    <cfset onHrefClick = "index.cfm?event=addload&loadid=#qInvoiceLoads.LOADID#&#session.URLToken#">
                    <tr style="cursor: default;" <cfif qInvoiceLoads.currentRow mod 2 eq 0>bgcolor="##FFFFFF"<cfelse>bgcolor="##f7f7f7"</cfif>>
                        <td class="sky-bg2" valign="middle" align="center" style="border-left: 1px solid ##5d8cc9;">#rowNum + qInvoiceLoads.currentRow#</a></td>
                        <td  align="center" valign="middle" nowrap="nowrap" class="normal-td" width="10" style="padding: 0;">
                            <input type="checkbox" name="ckInvoiceLoads" class="ckInvoiceLoads" value="#qInvoiceLoads.LOADID#" checked onclick="uncheckLoad()">
                        </td>
                        <td  align="left" valign="middle" nowrap="nowrap" class="normal-td">#qInvoiceLoads.LoadNumber#</td>
                        <td  align="left" valign="middle" nowrap="nowrap" class="normal-td">#qInvoiceLoads.StatusDescription#</td>
                        <td  align="left" valign="middle" nowrap="nowrap" class="normal-td">#qInvoiceLoads.CarrierName#</td>
                        <td  align="left" valign="middle" nowrap="nowrap" class="normal-td">#DateFormat(qInvoiceLoads.NewPickupDate,'mm/dd/yyyy')#</td>
                		<td  align="left" valign="middle" nowrap="nowrap" class="normal-td">#DateFormat(qInvoiceLoads.BillDate,'mm/dd/yyyy')#</td>
                        <td  align="right" valign="middle" nowrap="nowrap" class="normal-td" style="padding-right: 5px;">#DollarFormat(qInvoiceLoads.TotalCustomerCharges)#</td>
                        <td style="border-right: 1px solid ##5d8cc9;"  align="right" valign="middle" nowrap="nowrap" class="normal-td2" onclick="location.href='#onHrefClick#'"><a href="#onHrefClick#">#DollarFormat(qInvoiceLoads.TotalCarrierCharges)#</a></td>
                    </tr>
                </cfloop>
            <cfelse>
                <tr>
                    <td colspan="11" align="center" style="border-left: 1px solid ##5d8cc9;border-right: 1px solid ##5d8cc9;">No Records Found.</td>
                </tr>
            </cfif>
        </tbody>
        <tfoot>
            <tr>
                <td colspan="11" align="left" valign="middle" class="footer-bg" style="border-left: 1px solid ##5d8cc9;border-bottom-left-radius: 5px;border-bottom-right-radius: 5px;border-right: 1px solid ##5d8cc9;">
                    <div class="up-down">
                        <div class="arrow-top"><a href="javascript: tablePrevPage('dispARExportForm');"><img src="images/arrow-top.gif" alt="" /></a></div>
                        <div class="arrow-bot"><a href="javascript: tableNextPage('dispARExportForm');"><img src="images/arrow-bot.gif" alt="" /></a></div>
                    </div>
                    <div class="gen-left" style="font-size: 14px;">
                      <cfif qInvoiceLoads.recordcount>
                        <button type="button" class="bttn_nav" onclick="tablePrevPage('dispARExportForm');">PREV</button>
                          Page 
                          <input type="text" onkeyup="if (/\D/g.test(this.value)) this.value = this.value.replace(/\D/g,'')" value="<cfif structKeyExists(form, "pageNo")>#form.pageNo#<cfelse>1</cfif>" id="jumpPageNo" style="text-align: center;width: 25px;" onchange="jumpToPage('dispARExportForm')">
                              <input type="hidden" id="TotalPages" value="#qInvoiceLoads.TotalPages#">
                          of #qInvoiceLoads.TotalPages#
                          <button type="button" class="bttn_nav" onclick="tableNextPage('dispARExportForm');">NEXT</button>
                      </cfif>
                    </div>
                    <div class="gen-right"><img src="images/loader.gif" alt="" /></div>
                    <div class="clear"></div>
                </td>
            </tr> 
        </tfoot>   
    </table>
</cfoutput>

    