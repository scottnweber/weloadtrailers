<cfparam name="sortorder" default="ASC">
<cfparam name="sortby"  default="LoadNumber">
<cfparam name="pageNo"  default="1">
<cfparam name="form.InvoiceDateFrom"  default="">
<cfparam name="form.InvoiceDateTo"  default="">
<cfparam name="form.LoadStatusFilter"  default="true">
<cfif structKeyExists(form, "ExportInvoices")>
    <cfinvoke frmStruct="#form#" component="#variables.objLoadGatewayNew#" method="QBExportAR" returnvariable="resp"/>
    <cfset session.ExportRespMsg = resp>
    <cfinvoke frmStruct="#form#" component="#variables.objLoadGatewayNew#" method="QBExportAP" returnvariable="respAP"/>
    <cfset session.ExportAPRespMsg = respAP>
    <cflocation url="index.cfm?event=QBNotExported&#session.URLToken#">
</cfif>

<cfinvoke component="#variables.objloadGateway#" method="getSystemSetupOptions" returnvariable="request.qGetSystemSetupOptions" />
<cfinvoke component="#variables.objLoadGateway#" method="getQBNotExportedLoads" frmStruct="#form#" returnvariable="qLoads" />
<cfinvoke component="#variables.objLoadGateway#" method="getQBNotExportedCustomerCarrierTotals" frmStruct="#form#" returnvariable="qTotals" />

<cfif request.qGetSystemSetupOptions.freightbroker EQ 0>
    <cfset variables.freightbroker = "Driver">
<cfelseif request.qGetSystemSetupOptions.freightbroker EQ 1>
    <cfset variables.freightbroker = "Carrier">
<cfelse>
    <cfset variables.freightbroker = "Carrier/Driver">
</cfif>
<cfoutput>
    <style type="text/css">
        .white-con-area{
            height: 31px;width:914px;
        } 
        .white-con-area h2{
            color:white;font-weight:bold;margin-left: 12px;
        }
        .ui-widget, .ui-widget input, .ui-widget select, .ui-widget textarea, .ui-widget button{
            font:11px/16px Arial,Helvetica,sans-serif !important;
        }
        .ui-widget-content{
            border:0px !important;
        }
        .ui-corner-all, .ui-corner-bottom, .ui-corner-left, .ui-corner-bl {
            border-bottom-left-radius:0px !important;
        }
        .ui-corner-all, .ui-corner-bottom, .ui-corner-right, .ui-corner-br {
            border-bottom-right-radius:0px !important;
        }
        .ui-corner-all, .ui-corner-top, .ui-corner-left, .ui-corner-tl{
            border-top-left-radius:0px !important;
        }
        .ui-corner-all, .ui-corner-top, .ui-corner-right, .ui-corner-tr{
            border-top-right-radius:0px !important;
        }
        ##tabs1{
            width: 914px;
            background-color: #request.qGetSystemSetupOptions.BackgroundColorAccounting# !important;
        }
        .ui-tabs{
            padding: 0;
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
        .reportsSubHeading{
            color: ##7e7e7e;
            padding: 0px 0 10px 10px;
            margin: 0;
            font-size: 14px;
            font-weight: normal;
            border-bottom: 1px solid ##77463d !important;
            margin-bottom: 5px !important;
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
        <cfif NOT (ListContains(session.rightsList,'modifySystemSetup',',') AND NOT ListContains(session.rightsList,'HideCustomerPricing',','))>
            .statusUpdate{
               background-color: ##d5dad3;
            }
        </cfif>
        .msg-area-success{
            border: 1px solid ##a4da46;
            padding: 5px 15px;
            font-weight: normal;
            width: 88%;
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
            width: 88%;
            float: left;
            margin-top: 5px;
            margin-bottom:  5px;
            background-color: ##e4b9c6;
            font-weight: bold;
            font-style: italic;
        }
    </style>
    <script>
        $(document).ready(function(){

            <cfif structKeyExists(session, "ExportRespMsg") and session.ExportRespMsg.res eq 'success'>
                $("##download").attr("href", '../temp/#session.ExportRespMsg.fileName#');
                document.getElementById('download').click();

                var path = urlComponentPath+"loadgateway.cfc?method=deleteTempQBFile";
                $.ajax({
                    type: "Post",
                    url: path,
                    dataType: "json",
                    data: {fileName:'#session.ExportRespMsg.fileName#'},
                    success: function(data){
                    }
                })
            </cfif>
            <cfif structKeyExists(session, "ExportAPRespMsg") and session.ExportAPRespMsg.res eq 'success'>
                $("##downloadAP").attr("href", '../temp/#session.ExportAPRespMsg.fileName#');
                document.getElementById('downloadAP').click();

                var path = urlComponentPath+"loadgateway.cfc?method=deleteTempQBFile";
                $.ajax({
                    type: "Post",
                    url: path,
                    dataType: "json",
                    data: {fileName:'#session.ExportAPRespMsg.fileName#'},
                    success: function(data){
                    }
                })
            </cfif>

            $('##InvoiceDateFrom').focus();

            $( ".datefield" ).datepicker({
                dateFormat: "mm/dd/yy",
                showOn: "button",
                buttonImage: "images/DateChooser.png",
                buttonImageOnly: true,
                showButtonPanel: true,
                onClose: function ()
                {
                    this.focus();
                }
            });

            $('.datefield').change(function(){
                var InvoiceDateFrom = $('##InvoiceDateFrom').val();
                var InvoiceDateTo = $('##InvoiceDateTo').val();

                if($.trim(InvoiceDateFrom).length && $.trim(InvoiceDateTo).length && new Date($.trim(InvoiceDateFrom)) <= new Date($.trim(InvoiceDateTo))){
                    $('##data-content ').html('<tr><td colspan="13" align="center" style="border-left: 1px solid ##5d8cc9;border-right: 1px solid ##5d8cc9;"><img src="images/loadDelLoader.gif" style="margin-top: 25px;"><br>Please wait...</td></tr>');
                    $('##ARExportForm').submit();
                }
                else if(!$.trim(InvoiceDateFrom).length && !$.trim(InvoiceDateTo).length){
                    $('##data-content ').html('<tr><td colspan="13" align="center" style="border-left: 1px solid ##5d8cc9;border-right: 1px solid ##5d8cc9;"><img src="images/loadDelLoader.gif" style="margin-top: 25px;"><br>Please wait...</td></tr>');
                    $('##ARExportForm').submit();
                }
                else if($.trim(InvoiceDateFrom).length && !$.trim(InvoiceDateTo).length){
                    $('##InvoiceDateTo').val($.trim(InvoiceDateFrom));
                    $('##data-content ').html('<tr><td colspan="13" align="center" style="border-left: 1px solid ##5d8cc9;border-right: 1px solid ##5d8cc9;"><img src="images/loadDelLoader.gif" style="margin-top: 25px;"><br>Please wait...</td></tr>');
                    $('##ARExportForm').submit();
                }
            });
        })

        function validateExport(){
            var Count = $('##Count').val();
            if(Count==0){
                alert('No data found.');
                return false;
            }
        }

        function setLoadsForInvoiceExport(){
            var checkBoxValues = [];
            $.each($("input[name='Invoice']:checked"), function(){
                checkBoxValues.push($(this).val());
            });
            $('##InvoiceLoads').val(checkBoxValues);
        }

        function setLoadsForBillsExport(){
            var checkBoxValues = [];
            $.each($("input[name='Bills']:checked"), function(){
                checkBoxValues.push($(this).val());
            });
            $('##BillsLoads').val(checkBoxValues);
        }

        function changeStatusFilter(ck){
            $('##LoadStatusFilter').val($(ck).prop("checked"));
            $('##data-content ').html('<tr><td colspan="13" align="center" style="border-left: 1px solid ##5d8cc9;border-right: 1px solid ##5d8cc9;"><img src="images/loadDelLoader.gif" style="margin-top: 25px;"><br>Please wait...</td></tr>');
            $('##ARExportForm').submit();
        }
    </script>
    <cfinclude template="QBtabs.cfm">
    
    <div class="search-panel" style="width:914px;background-color: red;">
        <div class="form-search" style="width:100%;background-color: #request.qGetSystemSetupOptions.BackgroundColorForContentAccounting# !important;padding-bottom: 10px;">
            <cfform id="ARExportForm" name="ARExportForm" action="" method="post" preserveData="yes">
                <input type="hidden" value="#qLoads.RecordCount#" id="Count">
                <input type="hidden" value="" id="InvoiceLoads" name="InvoiceLoads">
                <input type="hidden" value="" id="BillsLoads" name="BillsLoads">
                <input type="hidden" value="#request.qGetSystemSetupOptions.QBInvoiceStatusUpdateTo#" id="InvoiceStatus" name="InvoiceStatus">
                <input type="hidden" value="#request.qGetSystemSetupOptions.QBBillStatusUpdateTo#" id="BillStatus" name="BillStatus">
                <input type="hidden" value="#form.LoadStatusFilter#" id="LoadStatusFilter" name="LoadStatusFilter">
                <a id="download" href="" download="<cfif request.qGetSystemSetupOptions.QBVersion EQ 1>QBInvoiceImport.iif<cfelse>INVOICES.csv</cfif>" style="display: none">Download</a>
                <a id="downloadAP" href="" download="<cfif request.qGetSystemSetupOptions.QBVersion EQ 1>QBBillsImport.iif<cfelse>BILLS.csv</cfif>" style="display: none">Download</a>
                <fieldset style="width:45%;padding:5px;float:left;">
                    <h2 class="reportsSubHeading">Enter Invoice Date Range</h2>
                    <div style="float: left;">
                        <label style="font-weight: bold;width:30px;margin-left: 20px;">From:</label>
                        <input class="sm-input datefield" tabindex=4 id="InvoiceDateFrom" name="InvoiceDateFrom"  onchange="InvoiceDateFormat(this);checkDateFormatAll(this);" value="<cfif structKeyExists(form, "InvoiceDateFrom")>#DateFormat(form.InvoiceDateFrom,'mm/dd/yyyy')#</cfif>" type="text" />
                    </div>
                    <div style="float: left;margin-left: 20px;">
                        <label>Apply Load Status Filter:</label>
                        <input type="checkbox" style="width: 25px;" onclick="changeStatusFilter(this);"
                        <cfif form.LoadStatusFilter> checked </cfif>>
                    </div>
                    <div style="clear:left"></div>
                    <div style="float: left;">
                        <label style="font-weight: bold;width:50px;">To:</label>
                        <input class="sm-input datefield" tabindex=4 id="InvoiceDateTo" name="InvoiceDateTo"  onchange="InvoiceDateFormat(this);checkDateFormatAll(this);" value="<cfif structKeyExists(form, "InvoiceDateTo")>#DateFormat(form.InvoiceDateTo,'mm/dd/yyyy')#</cfif>" type="text" />
                    </div>
                    <div style="float: left;">
                        <button class="btn" name="dateRangeSubmit" style="display: none;"><b>Submit</b></button>
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
                <fieldset style="width:16%;padding:5px;float:left;margin-left: 10px;">
                    <h2 class="reportsSubHeading">#variables.freightbroker# Totals</h2>
                    <input class="sm-input" tabindex=4 id="CarrierTotals" value="#DollarFormat(CarrierTotal)#" type="text" style="color:##8B0000;width:73px !important" readonly/>
                    <input class="sm-input" tabindex=4 id="CarrierNo" value="#CarrierTotalCount#" type="text" 
                    style="width:25px !important;color:##8B0000" readonly/>
                </fieldset>
                <fieldset style="width:16%;padding:5px;float:left;margin-left: 10px;margin-top: 7px;">
                    <button  onclick="return validateExport();" class="btn" name="ExportInvoices" style="height: 64px;background-size: contain;"><b>Export Invoices</b></button>
                </fieldset>

            </cfform>
        </div>
    </div>
    <div style="clear:left"></div>
    <cfif structKeyExists(session, "ExportRespMsg")>
        <div id="message" class="msg-area-#session.ExportRespMsg.res#">Invoices #session.ExportRespMsg.msg#</div>
        <cfset structDelete(session, "ExportRespMsg")>
    </cfif>
    <cfif structKeyExists(session, "ExportAPRespMsg")>
        <div id="message" class="msg-area-#session.ExportAPRespMsg.res#">Bills #session.ExportAPRespMsg.msg#</div>
        <cfset structDelete(session, "ExportAPRespMsg")>
    </cfif>
    <div style="clear:both"></div>

    <cfform id="QBExport" name="QBExport" action="" method="post" preserveData="yes">
        <cfinput id="pageNo" name="pageNo" value="1" type="hidden">
        <cfinput id="sortOrder" name="sortOrder" value="ASC" type="hidden">
        <cfinput id="sortBy" name="sortBy" value="LoadNumber" type="hidden">
        <cfinput name="InvoiceDateFrom" value="#form.InvoiceDateFrom#" type="hidden">
        <cfinput name="InvoiceDateTo" value="#form.InvoiceDateTo#" type="hidden">
        <cfinput name="" onclick="javascript: document.getElementById('pageNo').value=1;" type="submit" class="s-bttn" value="Search" style="display:none;" />
    </cfform>

    <cfset pageSize = 30>
    <cfif isdefined("form.pageNo")>
        <cfset rowNum = ((form.pageNo-1)*pageSize)>
    <cfelse>
        <cfset rowNum = 0>
    </cfif>
    <table width="914" border="0" class="data-table" cellspacing="0" cellpadding="0" style="color:##000000;">
        <thead>
            <tr>
                <th align="center" valign="middle" class="head-bg" style="border-left: 1px solid ##5d8cc9;border-top-left-radius: 5px;">&nbsp;</th>
                <th align="center" valign="middle" class="head-bg" onclick="sortTableBy('L.LoadNumber','QBExport')">Load##</th>
                <th align="center" valign="middle" class="head-bg">Invoices</th>
                <th align="center" valign="middle" class="head-bg">Bills</th>
                <th align="center" valign="middle" class="head-bg" onclick="sortTableBy('Lst.StatusText','QBExport')">StatusText</th>
                <th align="center" valign="middle" class="head-bg" onclick="sortTableBy('C.CustomerName','QBExport')">Customer</th>
                <th align="center" valign="middle" class="head-bg" onclick="sortTableBy('C.Email','QBExport')">Email</th>
                <th align="center" valign="middle" class="head-bg" onclick="sortTableBy('L.NewPickupDate','QBExport')">Pickup Date</th>
                <th align="center" valign="middle" class="head-bg" onclick="sortTableBy('L.BillDate','QBExport')">Invoice Date</th>
                <th width="100" align="center" valign="middle" class="head-bg" onclick="sortTableBy('L.TotalCustomerCharges','QBExport')">Customer Amt</th>
                <th width="100" align="center" valign="middle" class="head-bg2" onclick="sortTableBy('L.TotalCarrierCharges','QBExport')" style="border-right: 1px solid ##5d8cc9;border-top-right-radius: 5px;">#variables.freightbroker# Amt</th>
            </tr>
        </thead>
        <tbody id="data-content">
            <cfif qLoads.recordcount>
                <cfloop query="qLoads">
                    <cfset onHrefClick = "index.cfm?event=addload&loadid=#qLoads.LOADID#&#session.URLToken#">
                    <tr style="cursor: default;" <cfif qLoads.currentRow mod 2 eq 0>bgcolor="##FFFFFF"<cfelse>bgcolor="##f7f7f7"</cfif>>
                        <td class="sky-bg2" valign="middle" align="center" style="border-left: 1px solid ##5d8cc9;">#rowNum + qLoads.currentRow#</a></td>
                        <td  align="left" valign="middle" nowrap="nowrap" class="normal-td" onclick="location.href='#onHrefClick#'"><a href="#onHrefClick#">#qLoads.LoadNumber#</a></td>
                        <td  align="left" valign="middle" nowrap="nowrap" class="normal-td">
                            <input type="checkbox" name="Invoice" onclick="setLoadsForInvoiceExport()" value="#qLoads.LOADID#">
                        </td>
                        <td  align="left" valign="middle" nowrap="nowrap" class="normal-td">
                            <input type="checkbox" name="Bills" onclick="setLoadsForBillsExport()" value="#qLoads.LOADID#">
                        </td>
                        <td  align="left" valign="middle" nowrap="nowrap" class="normal-td" onclick="location.href='#onHrefClick#'"><a href="#onHrefClick#">#qLoads.statusdescription#</a></td>
                        <td  align="left" valign="middle" nowrap="nowrap" class="normal-td" onclick="location.href='#onHrefClick#'"><a href="#onHrefClick#">#qLoads.CustomerName#</a></td>
                        <td  align="left" valign="middle" nowrap="nowrap" class="normal-td" onclick="location.href='#onHrefClick#'"><a href="#onHrefClick#">#replaceNoCase(qLoads.Email, ";", ";<br>")#</a></td>
                        <td  align="left" valign="middle" nowrap="nowrap" class="normal-td" onclick="location.href='#onHrefClick#'"><a href="#onHrefClick#">#DateFormat(qLoads.NewPickupDate,'mm/dd/yyyy')#</a></td>
                        <td  align="left" valign="middle" nowrap="nowrap" class="normal-td" onclick="location.href='#onHrefClick#'"><a href="#onHrefClick#">
                            <cfif len(trim(qLoads.BillDate))>
                                #DateFormat(qLoads.BillDate,'mm/dd/yyyy')#
                            <cfelseif len(trim(qLoads.NewPickupDate))>
                                <b style="color:##8B0000;">Using Pickup Date</b>
                            <cfelse>
                                <b style="color:##8B0000;">No Date</b>
                            </cfif></a>
                        </td>
                        <td  align="right" valign="middle" nowrap="nowrap" class="normal-td" style="padding-right: 5px;" onclick="location.href='#onHrefClick#'"><a href="#onHrefClick#">#DollarFormat(qLoads.TotalCustomerCharges)#</a></td>
                        <td style="border-right: 1px solid ##5d8cc9;"  align="right" valign="middle" nowrap="nowrap" class="normal-td2" onclick="location.href='#onHrefClick#'"><a href="#onHrefClick#">#DollarFormat(qLoads.TotalCarrierCharges)#</a></td>
                    </tr>
                </cfloop>
            <cfelse>
                <tr>
                    <td colspan="13" align="center" style="border-left: 1px solid ##5d8cc9;border-right: 1px solid ##5d8cc9;">No Records Found.</td>
                </tr>
            </cfif>
        </tbody>
        <tfoot>
            <tr>
                <td colspan="13" align="left" valign="middle" class="footer-bg" style="border-left: 1px solid ##5d8cc9;border-bottom-left-radius: 5px;border-bottom-right-radius: 5px;border-right: 1px solid ##5d8cc9;">
                    <div class="up-down">
                        <div class="arrow-top"><a href="javascript: tablePrevPage('QBExport');"><img src="images/arrow-top.gif" alt="" /></a></div>
                        <div class="arrow-bot"><a href="javascript: tableNextPage('QBExport');"><img src="images/arrow-bot.gif" alt="" /></a></div>
                    </div>
                    <div class="gen-left"><a href="javascript: tablePrevPage('QBExport');">Prev </a>-<a href="javascript: tableNextPage('QBExport');"> Next</a></div>
                    <div class="gen-right"><img src="images/loader.gif" alt="" /></div>
                    <div class="clear"></div>
                </td>
            </tr> 
        </tfoot>   
    </table>
</cfoutput>