<cfparam name="message" default="">
<cfparam name="sortorder" default="desc">
<cfparam name="sortby"  default="">
<cfparam name="searchText"  default=" ">
<cfparam name="pageNo"  default="1">
<cfoutput>
    <style type="text/css">
        .msg-area{
            width: 500px;
            float: left;
            margin-top: 5px;
            background-color: ##b9e4b9;
        }
    </style>
    <h1>Payment Terms</h1>
    <div style="clear:left"></div>

    <cfif structKeyExists(session, "TermMessage")>
        <div class="msg-area" style="width:500px">#session.TermMessage#</div>
        <cfset structdelete(session, 'TermMessage')/> 
    </cfif>
 
    <div class="search-panel">
        <div class="form-search">
            <cfform id="paymentTermsForm" name="paymentTermsForm" action="index.cfm?event=PaymentTerms&#session.URLToken#" method="post" preserveData="yes">
                <cfinput id="pageNo" name="pageNo" value="1" type="hidden">
                <cfinput id="sortOrder" name="sortOrder" value="ASC" type="hidden">
                <cfinput id="sortBy" name="sortBy" value="Description" type="hidden">
                <fieldset>
                    <cfinput name="searchText" type="text" />
                    <input name="" onclick="javascript: document.getElementById('pageNo').value=1;" type="submit" class="s-bttn" value="Search" style="width:56px;" />
                    <div class="clear"></div>
                 </fieldset>
            </cfform>     
        </div>
        <div class="addbutton" style="float:left;margin-left: 105px;"><a href="index.cfm?event=addLMAPaymentTerms&#session.URLToken#">Add New</a></div>
    </div>
    <cfif isdefined("form.searchText") >
    	<cfinvoke component="#variables.objLoadGateway#" method="getLMAPaymentTerms" searchText="#form.searchText#" pageNo="#form.pageNo#" sortorder="#form.sortOrder#" sortby="#form.sortBy#" returnvariable="qPaymentTerms" />
    <cfelse>
    	<cfinvoke component="#variables.objLoadGateway#" method="getLMAPaymentTerms" returnvariable="qPaymentTerms" />
    </cfif>
	
    <cfset pageSize = 30>
    <cfif isdefined("form.pageNo")>
        <cfset rowNum = ((form.pageNo-1)*pageSize)>
    <cfelse>
        <cfset rowNum = 0>
    </cfif>
    <div class="clear"></div>
    <table width="50%" border="0" class="data-table" cellspacing="0" cellpadding="0" style="color:##000000;">
        <thead>
            <tr>
                <th  align="left" valign="top"><img src="images/top-left.gif" alt="" width="5" height="23" /></th>
                <th  align="center" valign="middle" class="head-bg">&nbsp;</th>
                <th align="center" valign="middle" class="head-bg" onclick="sortTableBy('Description','paymentTermsForm')">Description</th>
                <th align="center" valign="middle" class="head-bg">Type</th>
                <th  align="center" valign="middle" class="head-bg">Discount</th>
                <th  align="center" valign="middle" class="head-bg">Discount Days</th>
                <th align="center" valign="middle" class="head-bg2">Net Days</th>
                <th  align="right" valign="top"><img src="images/top-right.gif" alt="" width="5" height="23" /></th>
            </tr>
        </thead>
        <tbody>
            <cfloop query="qPaymentTerms">
                <tr <cfif qPaymentTerms.currentRow mod 2 eq 0>bgcolor="##FFFFFF"<cfelse>bgcolor="##f7f7f7"</cfif>>
                    <td height="20" class="sky-bg">&nbsp;</td>
                    <td class="sky-bg2" valign="middle" align="center">#rowNum + qPaymentTerms.currentRow#</td>
                    <td  align="left" valign="middle" nowrap="nowrap" class="normal-td" onclick="document.location.href='index.cfm?event=addLMAPaymentTerms&ID=#qPaymentTerms.ID#&#session.URLToken#'"><a href="index.cfm?event=addLMAPaymentTerms&ID=#qPaymentTerms.ID#&#session.URLToken#">#qPaymentTerms.Description#</a></td>
                    <td  align="left" valign="middle" nowrap="nowrap" class="normal-td">#qPaymentTerms.Type#</td>
                    <td  align="left" valign="middle" nowrap="nowrap" class="normal-td">#DollarFormat(qPaymentTerms.Discount)#</td>
                    <td  align="left" valign="middle" nowrap="nowrap" class="normal-td">#qPaymentTerms.DiscountDays#</td>
                    <td  align="left" valign="middle" nowrap="nowrap" class="normal-td2">#qPaymentTerms.NetDays#</td>
                    <td class="normal-td3">&nbsp;</td>
                </tr>
            </cfloop>
       </tbody>
       <tfoot>
            <tr>
                <td width="5" align="left" valign="top"><img src="images/left-bot.gif" alt="" width="5" height="23" /></td>
                <td colspan="6" align="left" valign="middle" class="footer-bg">
                    <div class="up-down">
                        <div class="arrow-top"><a href="javascript: tablePrevPage('dispLoadLogsForm');"><img src="images/arrow-top.gif" alt="" /></a></div>
                        <div class="arrow-bot"><a href="javascript: tableNextPage('dispLoadLogsForm');"><img src="images/arrow-bot.gif" alt="" /></a></div>
                    </div>
                    <div class="gen-left" style="font-size: 14px;">
                          <cfif qPaymentTerms.recordcount>
                            <button type="button" class="bttn_nav" onclick="tablePrevPage('dispLoadLogsForm');">PREV</button>
                              Page
                              <input type="text" onkeyup="if (/\D/g.test(this.value)) this.value = this.value.replace(/\D/g,'')" value="<cfif structKeyExists(form, "pageNo")>#form.pageNo#<cfelse>1</cfif>" id="jumpPageNo" style="text-align: center;width: 25px;" onchange="jumpToPage('dispLoadLogsForm')">
                                  <input type="hidden" id="TotalPages" value="#qPaymentTerms.TotalPages#">
                              of #qPaymentTerms.TotalPages#
                              <button type="button" class="bttn_nav" onclick="tableNextPage('dispLoadLogsForm');">NEXT</button>
                          </cfif>
                        </div>
                    <div class="gen-right"><img src="images/loader.gif" alt="" /></div>
                    <div class="clear"></div>
                </td>
                <td width="5" align="right" valign="top"><img src="images/right-bot.gif" alt="" width="5" height="23" /></td>
            </tr>  
        </tfoot>   
    </table>
</cfoutput>