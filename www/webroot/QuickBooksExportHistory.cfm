<cfparam name="sortorder" default="DESC">
<cfparam name="sortby"  default="Created">

<cfparam name="pageNo"  default="1">

<cfif isDefined("form.ARRevert")>
    <cfinvoke component="#variables.objLoadGateway#" method="QBRevertLastInvoice" returnvariable="resp"/>
    <cfset session.ExportRevertRespMsg = resp>
    <cflocation url="index.cfm?event=QuickBooksExportHistory&#session.URLToken#">
</cfif>
<cfif isDefined("form.APRevert")>
    <cfinvoke component="#variables.objLoadGateway#" method="QBRevertLastBills" returnvariable="resp"/>
    <cfset session.ExportRevertRespMsg = resp>
    <cflocation url="index.cfm?event=QuickBooksExportHistory&#session.URLToken#">
</cfif>

<cfinvoke component="#variables.objloadGateway#" method="getSystemSetupOptions" returnvariable="request.qGetSystemSetupOptions" />

<cfinvoke component="#variables.objLoadGateway#" method="getQBExportHistory" frmStruct="#form#" returnvariable="qLoads" />

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
    <cfinclude template="QBtabs.cfm">
    <div class="search-panel" style="width:914px;background-color: red;">
        <div class="form-search" style="width:100%;background-color: #request.qGetSystemSetupOptions.BackgroundColorForContentAccounting# !important;padding-bottom: 10px;">
            <cfform id="QBExportHistory" name="QBExportHistory" action="" method="post" preserveData="yes">
                <cfinput id="pageNo" name="pageNo" value="1" type="hidden">
                <cfinput id="sortOrder" name="sortOrder" value="DESC" type="hidden">
                <cfinput id="sortBy" name="sortBy" value="Created" type="hidden">
                <cfinput name="" onclick="javascript: document.getElementById('pageNo').value=1;" type="submit" class="s-bttn" value="Search" style="display:none;" />
            </cfform>
            <cfform id="ARExportRvertForm" name="ARExportRvertForm" action="" method="post" preserveData="yes" style="width:50%;float:left;text-align:center;border-right:groove 1px;padding-top:25px;padding-bottom:25px;">
                <h2 style="color:##2f9d01">Revert Last Invoice Export</h2>
                <cfinput type="submit" value="Revert Invoice Export" name="ARRevert" style="width:175px !important">
            </cfform>
             <cfform id="APExportRvertForm" name="APExportRvertForm" action="" method="post" preserveData="yes" style="text-align:center;padding-top:25px;padding-bottom:25px;">
                <h2 style="color:##f80100">Revert Last Bills Export</h2>
                <cfinput type="submit" value="Revert Bills Export" name="APRevert" style="width:175px !important">
            </cfform>
        </div>
    </div>
  
    <cfset pageSize = 30>
    <cfif isdefined("form.pageNo")>
        <cfset rowNum = ((form.pageNo-1)*pageSize)>
    <cfelse>
        <cfset rowNum = 0>
    </cfif>
    <div style="clear:left"></div>
    <cfif structKeyExists(session, "ExportRevertRespMsg")>
        <div id="message" class="msg-area-#session.ExportRevertRespMsg.res#">#session.ExportRevertRespMsg.msg#</div>
        <cfset structDelete(session, "ExportRevertRespMsg")>
    </cfif>
    <div style="clear:both"></div>
    <table width="914" border="0" class="data-table" cellspacing="0" cellpadding="0" style="color:##000000;">
        <thead>
            <tr>
                <th width="5" align="center" valign="middle" class="head-bg" style="border-left: 1px solid ##5d8cc9;border-top-left-radius: 5px;">&nbsp;</th>
                <th width="60" align="center" valign="middle" class="head-bg" onclick="sortTableBy('LoadNumber','QBExportHistory')">Load##</th>
                <th width="65" align="center" valign="middle" class="head-bg" onclick="sortTableBy('Type','QBExportHistory')">Type</th>
                <th width="65" align="center" valign="middle" class="head-bg" onclick="sortTableBy('MinOfPickupDate','QBExportHistory')">Pickup Date</th>
                <th width="105" align="center" valign="middle" class="head-bg" onclick="sortTableBy('MaxOfDeliveryDate','QBExportHistory')">Delivery Date</th>
                <th width="75" align="center" valign="middle" class="head-bg" onclick="sortTableBy('PayerName','QBExportHistory')">Customer Name</th>
                <th width="75" align="center" valign="middle" class="head-bg" onclick="sortTableBy('FirstOfCarrierName','QBExportHistory')">#variables.freightbroker# Name</th>
                <th width="165" align="center" valign="middle" class="head-bg" onclick="sortTableBy('[Customer Amount]','QBExportHistory')">Customer Amt</th>
                <th width="165" align="center" valign="middle" class="head-bg" onclick="sortTableBy('[Customer Amount]','QBExportHistory')">#variables.freightbroker# Amt</th>
                <th width="65" align="center" valign="middle" class="head-bg" onclick="sortTableBy('Created','QBExportHistory')">Date/Time</th>
                <th width="60" align="center" valign="middle" class="head-bg2" onclick="sortTableBy('User','QBExportHistory')" style="border-right: 1px solid ##5d8cc9;border-top-right-radius: 5px;">User</th>
            </tr>
        </thead>
        <tbody id="data-content">
            <cfif qLoads.recordcount>
                <cfloop query="qLoads">
                    <cfset onHrefClick = "index.cfm?event=addload&loadid=#qLoads.LOADID#&#session.URLToken#">
                    <tr style="cursor: default;" <cfif qLoads.currentRow mod 2 eq 0>bgcolor="##FFFFFF"<cfelse>bgcolor="##f7f7f7"</cfif>>
                        <td class="sky-bg2" valign="middle" align="center" style="border-left: 1px solid ##5d8cc9;">#rowNum + qLoads.currentRow#</td>
                        <td  align="left" valign="middle" nowrap="nowrap" class="normal-td"><a style="color:##000" href="#onHrefClick#">#qLoads.LoadNumber#</a></td>
                        <td  align="left" valign="middle" nowrap="nowrap" class="normal-td">#qLoads.Type#</td>
                        <td  align="left" valign="middle" nowrap="nowrap" class="normal-td">#DateFormat(qLoads.MinOfPickupDate,'mm/dd/yyyy')#</td>
                        <td  align="left" valign="middle" nowrap="nowrap" class="normal-td">#DateFormat(qLoads.MaxOfDeliveryDate,'mm/dd/yyyy')#</td>
                        <td  align="left" valign="middle" nowrap="nowrap" class="normal-td">#qLoads.PayerName#</td>
                        <td  align="left" valign="middle" nowrap="nowrap" class="normal-td">#qLoads.FirstOfCarrierName#</td>

                        <cfset customerAmount = qLoads['Customer Amount']>
                        <cfset carrierAmount = qLoads['Carrier Amount']>
                        <td  align="right" valign="middle" nowrap="nowrap" class="normal-td" style="padding-right: 5px;">#DollarFormat(customerAmount)#</td>
                        <td  align="right" valign="middle" nowrap="nowrap" class="normal-td" style="padding-right: 5px;">#DollarFormat(carrierAmount)#</td>

                        <td  align="right" valign="middle" nowrap="nowrap" class="normal-td" style="padding-right: 5px;">#DateTimeFormat(qLoads.created,"mm/dd/yyyy h:nn:ss tt")#</td>
                        <td style="border-right: 1px solid ##5d8cc9;"  align="right" valign="middle" nowrap="nowrap" class="normal-td2">#CreatedBy#</td>
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
                        <div class="arrow-top"><a href="javascript: tablePrevPage('QBExportHistory');"><img src="images/arrow-top.gif" alt="" /></a></div>
                        <div class="arrow-bot"><a href="javascript: tableNextPage('QBExportHistory');"><img src="images/arrow-bot.gif" alt="" /></a></div>
                    </div>
                    <div class="gen-left"><a href="javascript: tablePrevPage('QBExportHistory');">Prev </a>-<a href="javascript: tableNextPage('QBExportHistory');"> Next</a></div>
                    <div class="gen-right"><img src="images/loader.gif" alt="" /></div>
                    <div class="clear"></div>
                </td>
            </tr> 
        </tfoot>   
    </table>
</cfoutput>