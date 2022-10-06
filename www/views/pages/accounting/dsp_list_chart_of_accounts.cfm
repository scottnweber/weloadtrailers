<cfparam name="message" default="">
<cfparam name="sortorder" default="desc">
<cfparam name="sortby"  default="">
<cfparam name="searchText"  default=" ">
<cfparam name="pageNo"  default="1">
<cfoutput>
    <cfif isdefined("form.searchText") >
        <cfinvoke component="#variables.objLoadGateway#" method="getChartofAccountsList" searchText="#form.searchText#" pageNo="#form.pageNo#" sortorder="#form.sortOrder#" sortby="#form.sortBy#" returnvariable="qChartofAccountsList" />
    <cfelse>
        <cfinvoke component="#variables.objLoadGateway#" method="getChartofAccountsList" returnvariable="qChartofAccountsList" />
    </cfif>
    <cfinvoke component="#variables.objLoadGateway#" method="getAcctDeptList" returnvariable="qAcctDeptList" />
    <cfinvoke component="#variables.objLoadGateway#" method="getLMASystemConfig" returnvariable="qLMASystemConfig" />
    <script>
        $(document).ready(function(){
            var sourceJson = [
            <cfloop query="qAcctDeptList">
                <cfif not listFind(".,/", qAcctDeptList.GL_ACCT)>
                    {label: "#qAcctDeptList.GL_ACCT# #qAcctDeptList.description#", value: "#qAcctDeptList.GL_ACCT#", description:"#qAcctDeptList.description#",creditdebit:"#qAcctDeptList.credit_debit#"},
                </cfif>
            </cfloop>
            ]
            $.ui.autocomplete.filter = function (array, term) {
                var matcher = new RegExp("^" + $.ui.autocomplete.escapeRegex(term), "i");
                return $.grep(array, function (value) {
                    return matcher.test(value.label || value.value || value);
                });
            };

            $('.GLAccount').each(function(i, tag) {
                var id = $(this).attr('id');
                $(tag).autocomplete({
                    multiple: false,
                    width: 400,
                    scroll: true,
                    scrollHeight: 300,
                    cacheLength: 1,
                    highlight: false,
                    dataType: "json",
                    source: sourceJson,
                    autoFocus: true,
                    focus: function( event, ui ) {
                        $(this).val( ui.item.value );
                    },
                    select: function(e, ui) {
                        $('##'+id).change();
                        return false;
                    }  
                });
            });
        })

    </script>
    <style type="text/css">
        .msg-area{
            width: 500px;
            float: left;
            margin-top: 5px;
            background-color: ##b9e4b9;
        }
    </style>
    <h1>Chart Of Accounts</h1>
    <div class="addbutton" style="background: url(../webroot/images/LMA_AddNew.png) no-repeat 0px 7px;background-size: 20px 20px;">            
        <a href="index.cfm?event=ChartofAccounts&#session.URLToken#" style="margin-right: 5px;">Add New</a>
    </div>
    <div style="clear:left"></div>
    <div class="search-panel">
        <div class="form-search">
            <cfform id="COAForm" name="COAForm" action="index.cfm?event=ListChartofAccounts&#session.URLToken#" method="post" preserveData="yes">
                <cfinput id="pageNo" name="pageNo" value="1" type="hidden">
                <cfinput id="sortOrder" name="sortOrder" value="ASC" type="hidden">
                <cfinput id="sortBy" name="sortBy" value="GL_ACCT" type="hidden">
                <fieldset>
                    <cfinput name="searchText" type="text" class="GLAccount"/>
                    <input name="" onclick="javascript: document.getElementById('pageNo').value=1;" type="submit" class="s-bttn" value="Search" style="width:56px;" />
                    <div class="clear"></div>
                 </fieldset>
            </cfform>     
        </div>
    </div>
    <cfset pageSize = 30>
    <cfif isdefined("form.pageNo")>
        <cfset rowNum = ((form.pageNo-1)*pageSize)>
    <cfelse>
        <cfset rowNum = 0>
    </cfif>
    <div class="clear"></div>
    <cfif structKeyExists(session, "COAmsg")>
        <div class="msg-area" style="width:500px">#session.COAmsg#</div>
        <cfset structdelete(session, 'COAmsg')/> 
    </cfif>
    <div class="clear"></div>
    <table width="100%" border="0" class="data-table" cellspacing="0" cellpadding="0" style="color:##000000;">
        <thead>
            <tr>
                <th  align="left" valign="top"><img src="images/top-left.gif" alt="" width="5" height="23" /></th>
                <th  align="center" valign="middle" class="head-bg">&nbsp;</th>
                <th align="center" valign="middle" class="head-bg" onclick="COAForm('GL_ACCT','COAForm')">Account</th>
                <th align="center" valign="middle" class="head-bg">Description</th>
                <th  align="center" valign="middle" class="head-bg">MTD</th>
                <th  align="center" valign="middle" class="head-bg">YTD</th>
                <th align="center" valign="middle" class="head-bg2">Type</th>
                <th  align="right" valign="top"><img src="images/top-right.gif" alt="" width="5" height="23" /></th>
            </tr>
        </thead>
        <tbody>
            <cfloop query="qChartofAccountsList">
                <cfset FiscalYear = qLMASystemConfig['Fiscal Year']>
                <cfif len(trim(FiscalYear))>
                    <cfset hrefLink = "index.cfm?event=ChartofAccounts&ID=#qChartofAccountsList.ID#&#session.URLToken#">
                <cfelse>
                    <cfset hrefLink = "javascript: alert('Please setup the Fiscal Year Start on Settings > General Ledger Integration');">
                </cfif>
                <tr <cfif qChartofAccountsList.currentRow mod 2 eq 0>bgcolor="##FFFFFF"<cfelse>bgcolor="##f7f7f7"</cfif>>
                    <td height="20" class="sky-bg">&nbsp;</td>
                    <td class="sky-bg2" valign="middle" align="center">#rowNum + qChartofAccountsList.currentRow#</td>
                    <td  align="left" valign="middle" nowrap="nowrap" class="normal-td" onclick="document.location.href='#hrefLink#'"><a href="#hrefLink#">#qChartofAccountsList.GL_ACCT#</a></td>
                    <td  align="left" valign="middle" nowrap="nowrap" class="normal-td" onclick="document.location.href='#hrefLink#'"><a href="#hrefLink#">#qChartofAccountsList.Description#</a></td>
                    <td  align="right" valign="middle" nowrap="nowrap" class="normal-td" style="padding-right: 5px;" onclick="document.location.href='#hrefLink#'"><a href="#hrefLink#">#DollarFormat(qChartofAccountsList.MTD)#</a></td>
                    <td  align="right" valign="middle" nowrap="nowrap" class="normal-td" style="padding-right: 5px;" onclick="document.location.href='#hrefLink#'"><a href="#hrefLink#">#DollarFormat(qChartofAccountsList.YTD)#</a></td>
                    <td  align="left" valign="middle" nowrap="nowrap" class="normal-td2" onclick="document.location.href='#hrefLink#'"><a href="#hrefLink#">#qChartofAccountsList.Type_Description#</a></td>
                    <td class="normal-td3">&nbsp;</td>
                </tr>
            </cfloop>
       </tbody>
       <tfoot>
            <tr>
                <td width="5" align="left" valign="top"><img src="images/left-bot.gif" alt="" width="5" height="23" /></td>
                <td colspan="6" align="left" valign="middle" class="footer-bg">
                    <div class="up-down">
                        <div class="arrow-top"><a href="javascript: tablePrevPage('COAForm');"><img src="images/arrow-top.gif" alt="" /></a></div>
                        <div class="arrow-bot"><a href="javascript: tableNextPage('COAForm');"><img src="images/arrow-bot.gif" alt="" /></a></div>
                    </div>
                    <div class="gen-left" style="font-size: 14px;">
                      <cfif qChartofAccountsList.recordcount>
                        <button type="button" class="bttn_nav" onclick="tablePrevPage('COAForm');">PREV</button>
                          Page 
                          <input type="text" onkeyup="if (/\D/g.test(this.value)) this.value = this.value.replace(/\D/g,'')" value="<cfif structKeyExists(form, "pageNo")>#form.pageNo#<cfelse>1</cfif>" id="jumpPageNo" style="text-align: center;width: 25px;" onchange="jumpToPage('COAForm')">
                              <input type="hidden" id="TotalPages" value="#qChartofAccountsList.TotalPages#">
                          of #qChartofAccountsList.TotalPages#
                           <button type="button" class="bttn_nav" onclick="tableNextPage('COAForm');">NEXT</button>
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