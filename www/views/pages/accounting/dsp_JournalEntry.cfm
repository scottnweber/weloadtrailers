<cfoutput>
    <cfparam name="url.sortorder" default="desc">
    <cfparam name="sortby"  default="">
    <cfif isdefined("form.searchText") >
        <cfinvoke component="#variables.objLoadGateway#" method="getJournalEntries" searchText="#form.searchText#" pageNo="#form.pageNo#" sortorder="#form.sortOrder#" sortby="#form.sortBy#" returnvariable="request.qJournalEntries" />
    <cfelse>
        <cfinvoke component="#variables.objLoadGateway#" method="getJournalEntries" searchText="" pageNo="1" returnvariable="request.qJournalEntries" />
    </cfif>

    <cfinvoke component="#variables.objloadGateway#" method="getSystemSetupOptions" returnvariable="request.qGetSystemSetupOptions" />
    <style type="text/css">
        form .form-search fieldset label {
            float: left;
            text-align: right;
            width: 138px;
            padding: 0 10px 0 0;
            font-size: 11px;
            font-weight: bold;
            color: ##000000;
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
        .msg-area-success{
            border: 1px solid ##a4da46;
            padding: 5px 15px;
            font-weight: normal;
            margin: 0 auto;
            width: 500px;
            float: left;
            margin-top: 5px;
            background-color: ##b9e4b9;
        }
        .msg-area-error{
            border: 1px solid ##da4646;
            padding: 5px 15px;
            font-weight: normal;
            margin: 0 auto;
            width: 500px;
            float: left;
            margin-top: 5px;
            background-color: ##e4b9c6;
        }
        .reportsSubHeading{
            color: ##7e7e7e;
            padding: 0px 0 10px 10px;
            margin: 0;
            font-weight: normal;
            border-bottom: 1px solid ##77463d !important;
            margin-bottom: 5px !important;
        }
    </style>
    <script>
        $(document).ready(function(){
        })
    </script>
    <div class="white-con-area" style="height: 36px;background-color: ##82bbef;width:60%;">
        <div style="float: left;">
            <h2 style="color:white;font-weight:bold;margin-left: 12px;">Journal Entry</h2>
        </div>
        <div class="addbutton" style="background: url(../webroot/images/LMA_AddNew.png) no-repeat 0px 7px;background-size: 20px 20px;">            
            <a href="index.cfm?event=PostJournalEntry&#session.URLToken#" style="margin-right: 5px;">Add New</a>
        </div>
    </div>
    <div style="clear:left"></div>
    <div class="search-panel" style="width:60%;">
        <div class="form-search" style="width:100%;background-color: #request.qGetSystemSetupOptions.BackgroundColorForContentAccounting# !important;">
            <cfform id="dspJournalEntryForm" name="dspJournalEntryForm" action="index.cfm?event=JournalEntry&#session.URLToken#" method="post" preserveData="yes">
                <cfinput id="pageNo" name="pageNo" value="1" type="hidden">
                <cfinput id="sortOrder" name="sortOrder" value="DESC" type="hidden">
                <cfinput id="sortBy" name="sortBy" value="Trans_Date" type="hidden">

                <fieldset style="width:50%;padding:5px;float:left;">
                    <h1 class="reportsSubHeading">Search</h1>
                    <div style="float:left">
                        <input tabindex="1" class="sm-input" id="searchText" name="searchText" value="" type="text" style="width:100px !important;margin-left:10px;" />
                        <input name="Submit" onclick="javascript: document.getElementById('pageNo').value=1;" type="submit" class="s-bttn" value="Find" style="width:56px;" />
                    </div>
                 </fieldset>
            </cfform>     
        </div>
    </div> 
    <cfif structKeyExists(session, "PostJournalMsg")>
        <div id="message" class="msg-area-#session.PostJournalMsg.res#">#session.PostJournalMsg.msg#</div>
        <cfset structDelete(session, "PostJournalMsg")>
    </cfif>
    <div style="clear:left"></div>
    <div class="clear"></div>
    <cfset pageSize = 30>
    <cfif isdefined("form.pageNo")>
        <cfset rowNum = ((form.pageNo-1)*pageSize)>
    <cfelse>
        <cfset rowNum = 0>
    </cfif>
    
        <table width="60%" border="0" class="data-table" cellspacing="0" cellpadding="0" style="color:##000000;">
            <thead>
                <tr>
                    <th  align="left" valign="top"><img src="images/top-left.gif" alt="" width="5" height="23" /></th>
                    <th  align="center" valign="middle" class="head-bg">&nbsp;</th>
                    <th align="center" valign="middle" class="head-bg" onclick="sortTableBy('Trans_Number','dspJournalEntryForm')">Transaction ##</th>
                    <th align="center" valign="middle" class="head-bg" onclick="sortTableBy('Trans_Date','dspJournalEntryForm')">Date</th>
                    <th align="center" valign="middle" class="head-bg" onclick="sortTableBy('Type','dspJournalEntryForm')">Type</th>
                    <th  align="center" valign="middle" class="head-bg" onclick="sortTableBy('Cust_Vend_Code','dspJournalEntryForm')">Vendor Code</th>
                    <th align="center" valign="middle" class="head-bg2" onclick="sortTableBy('EnteredBy','dspJournalEntryForm')">Entered By</th>
                    <th  align="right" valign="top"><img src="images/top-right.gif" alt="" width="5" height="23" /></th>
                </tr>
            </thead>
            <tbody>
                <cfif request.qJournalEntries.recordcount>
                    <cfloop query="request.qJournalEntries">
                        <tr <cfif  request.qJournalEntries.currentRow mod 2 eq 0>bgcolor="##FFFFFF"<cfelse>bgcolor="##f7f7f7"</cfif>>
                            <td height="20" class="sky-bg">&nbsp;</td>
                            <td class="sky-bg2" valign="middle" align="center" onclick="document.location.href='index.cfm?event=PostJournalEntry&Trans_Number=#request.qJournalEntries.Trans_Number#&#session.URLToken#'">
                                <a href="index.cfm?event=PostJournalEntry&Trans_Number=#request.qJournalEntries.Trans_Number#&#session.URLToken#">#rowNum +  request.qJournalEntries.currentRow#</a>
                            </td>
                            <td  align="left" valign="middle" nowrap="nowrap" class="normal-td" onclick="document.location.href='index.cfm?event=PostJournalEntry&Trans_Number=#request.qJournalEntries.Trans_Number#&#session.URLToken#'">
                                <a href="index.cfm?event=PostJournalEntry&Trans_Number=#request.qJournalEntries.Trans_Number#&#session.URLToken#">#request.qJournalEntries.Trans_Number#
                                </a>
                            </td>
                            <td  align="left" valign="middle" nowrap="nowrap" class="normal-td" onclick="document.location.href='index.cfm?event=PostJournalEntry&Trans_Number=#request.qJournalEntries.Trans_Number#&#session.URLToken#'">
                                <a href="index.cfm?event=PostJournalEntry&Trans_Number=#request.qJournalEntries.Trans_Number#&#session.URLToken#">#DateFormat(request.qJournalEntries.Trans_Date,'mm/dd/yyyy')#
                                </a>
                            </td>
                            <td  align="left" valign="middle" nowrap="nowrap" class="normal-td" onclick="document.location.href='index.cfm?event=PostJournalEntry&Trans_Number=#request.qJournalEntries.Trans_Number#&#session.URLToken#'">
                                <a href="index.cfm?event=PostJournalEntry&Trans_Number=#request.qJournalEntries.Trans_Number#&#session.URLToken#">#request.qJournalEntries.Type#
                                </a>
                            </td>
                            <td  align="left" valign="middle" nowrap="nowrap" class="normal-td" onclick="document.location.href='index.cfm?event=PostJournalEntry&Trans_Number=#request.qJournalEntries.Trans_Number#&#session.URLToken#'">
                                <a href="index.cfm?event=PostJournalEntry&Trans_Number=#request.qJournalEntries.Trans_Number#&#session.URLToken#">#request.qJournalEntries.Cust_Vend_Code#</a>
                            </td>
                            <td  align="left" valign="middle" nowrap="nowrap" class="normal-td2" onclick="document.location.href='index.cfm?event=PostJournalEntry&Trans_Number=#request.qJournalEntries.Trans_Number#&#session.URLToken#'">
                                <a href="index.cfm?event=PostJournalEntry&Trans_Number=#request.qJournalEntries.Trans_Number#&#session.URLToken#">#request.qJournalEntries.EnteredBy#
                                </a>
                            </td>
                            <td class="normal-td3">&nbsp;</td>
                        </tr>
                    </cfloop>
                <cfelse>
                    <tr>
                        <td height="20" class="sky-bg">&nbsp;</td>
                        <td colspan="6" align="center" style="background-color: #request.qGetSystemSetupOptions.BackgroundColorForContentAccounting# !important;">No Records Found.</td>
                        <td class="normal-td3">&nbsp;</td>
                    </tr>

                </cfif>
           </tbody>
           <tfoot>
                <tr>
                    <td width="5" align="left" valign="top"><img src="images/left-bot.gif" alt="" width="5" height="23" /></td>
                    <td colspan="6" align="left" valign="middle" class="footer-bg">
                        <div class="up-down">
                            <div class="arrow-top"><a href="javascript: tablePrevPage('dspJournalEntryForm');"><img src="images/arrow-top.gif" alt="" /></a></div>
                            <div class="arrow-bot"><a href="javascript: tableNextPage('dspJournalEntryForm');"><img src="images/arrow-bot.gif" alt="" /></a></div>
                        </div>
                        <div class="gen-left" style="font-size: 14px;">
                          <cfif request.qJournalEntries.recordcount>
                              <button type="button" class="bttn_nav" onclick="tablePrevPage('dspJournalEntryForm');">PREV</button>
                              Page 
                              <input type="text" onkeyup="if (/\D/g.test(this.value)) this.value = this.value.replace(/\D/g,'')" value="<cfif structKeyExists(form, "pageNo")>#form.pageNo#<cfelse>1</cfif>" id="jumpPageNo" style="text-align: center;width: 25px;" onchange="jumpToPage('dspJournalEntryForm')">
                                  <input type="hidden" id="TotalPages" value="#request.qJournalEntries.TotalPages#">
                              of #request.qJournalEntries.TotalPages#
                              <button type="button" class="bttn_nav" onclick="tablePrevPage('dspJournalEntryForm');">NEXT</button>
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