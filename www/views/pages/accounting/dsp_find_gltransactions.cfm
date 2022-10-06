<cfoutput>
    <cfinvoke component="#variables.objLoadGateway#" method="getAcctDeptList" returnvariable="qAcctDeptList" />
    <cfif structKeyExists(form, "FindGLTrans")>
        <cfinvoke component="#variables.objLoadGateway#" method="FindGLTrans" frmStruct="#form#" returnvariable="request.qGLTransactions" />
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
        .msg-area{
            width: 500px;
            float: left;
            margin-top: 5px;
            background-color: ##b9e4b9;
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

            $( ".datefield" ).datepicker({
                dateFormat: "mm/dd/yy",
                showOn: "button",
                buttonImage: "images/DateChooser.png",
                buttonImageOnly: true,
                showButtonPanel: true,
                todayBtn:'linked'
            });
            $.datepicker._gotoToday = function(id) { 
                $(id).datepicker('setDate', new Date()).datepicker('hide').blur(); 
            };
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

            $('##GL_ACCT').each(function(i, tag) {
                $(tag).autocomplete({
                    multiple: false,
                    width: 400,
                    scroll: true,
                    scrollHeight: 300,
                    cacheLength: 1,
                    highlight: false,
                    dataType: "json",
                    source: sourceJson,
                    focus: function( event, ui ) {
                        $(this).val( ui.item.value );
                    },
                    change: function(event,ui){

                        var val = $(this).val();
                        var keyFound = 0;
                        $.each(sourceJson, function(i, v) {
                            if (v.value.startsWith(val)) {
                                keyFound = 1;
                                keyValue = v.value;
                                return false;
                            }
                        });
                        if(keyFound==0 && $.trim($('##GL_ACCT').val()).length){
                            alert('Invalid account number. Please correct and try again');
                            $(this).val('');
                            $(this).focus();
                            $(this).val('');
                        }
                        else{
                            $(this).val(keyValue);
                        }
                    },
                    select: function(e, ui) {
                        return false;
                    }  
                });
            });

            $('.gl-lookup').each(function(i, tag) {
                var fieldName = $(this).attr('data-fieldName');
                $(tag).autocomplete({
                    multiple: false,
                    width: 400,
                    scroll: true,
                    scrollHeight: 300,
                    cacheLength: 1,
                    highlight: false,
                    dataType: "json",
                    focus: function( event, ui ) {
                        $(this).val( ui.item.value );
                        return false;
                    },
                    source: 'searchLMAGLLookUpAutoFill.cfm?fieldName='+fieldName,
                    select: function(e, ui) {
                        $(this).val( ui.item.value );
                        return false;
                    }
                });
            });

            $('##Amount').change(function(){

                if(isNaN($(this).val().replace(/[$,]/g, ''))){
                    $(this).val('$0.00');
                }

                if($.trim($(this).val()).length){
                    formatDollarNegative($(this).val(), 'Amount');
                }
            })
            
            $('.chkDC').click(function(){
                var val = $(this).val(); 
                $('.chkDC').each(function() {
                    if($(this).val() != val){
                        $(this). prop("checked", false);
                    }
                })
            })

            <cfif structKeyExists(form, "Type")>
                $('##Type').val('#form.type#');
            </cfif>
        })
    </script>
    <div class="white-con-area" style="height: 36px;background-color: ##82bbef;width:100%;">
        <div style="float: left;">
            <h2 style="color:white;font-weight:bold;margin-left: 12px;">Find G/L Transactions</h2>
        </div>
    </div>
    <div style="clear:left"></div>
    <div class="search-panel" style="width:100%;">
        <div class="form-search" style="width:100%;background-color: #request.qGetSystemSetupOptions.BackgroundColorForContentAccounting# !important;">
            <cfform id="FindGLTransactionsForm" name="FindGLTransactionsForm" action="index.cfm?event=FindGLTransactions&#session.URLToken#" method="post" preserveData="yes">
                <cfinput id="pageNo" name="pageNo" value="1" type="hidden">
                <cfinput id="sortOrder" name="sortOrder" value="DESC" type="hidden">
                <cfinput id="sortBy" name="sortBy" value="EntryDate" type="hidden">
                <cfinput id="FindGLTrans" name="FindGLTrans" value="" type="hidden">
                <fieldset style="width:55%;padding:5px;float:left;">
                    <h2 class="reportsSubHeading">Enter Search Criteria</h2>
                    <div style="float:left">
                        <label style="width:77px;margin-left: 20px;">Account##:</label>
                        <input tabindex="1" class="sm-input" id="GL_ACCT" name="GL_ACCT" value="<cfif structKeyExists(form, "GL_ACCT")>#form.GL_ACCT#</cfif>" type="text" style="width:100px !important;" />
                    </div>
                    <div style="float:left">
                        <label style="font-weight: bold;width:77px;">Description:</label>
                        <input class="sm-input gl-lookup" tabindex="2" id="Description" name="Description" value="<cfif structKeyExists(form, "Description")>#form.Description#</cfif>" type="text" style="width:200px !important;" data-fieldName="Description"/>
                    </div>
                    <div class="clear"></div>
                    <div style="float:left">
                        <label style="width:77px;margin-left: 20px;">Department:</label>
                        <input tabindex="3" class="sm-input gl-lookup" id="Department" name="Department" value="" type="text" style="width:100px !important;" data-fieldName="GL Department"/>
                    </div>
                    <div style="float:left">
                        <label style="font-weight: bold;width:77px;">Amount:</label>
                        <input tabindex="4" class="sm-input" id="Amount" name="Amount" value="<cfif structKeyExists(form, "Amount")>#form.Amount#</cfif>" type="text" style="width:100px !important;" />
                    </div>
                    <div class="clear"></div>
                    <div style="float:left">
                        <label style="width:77px;margin-left: 20px;">Date:</label>
                        <input tabindex="5"  class="sm-input datefield" id="Date" name="Date"  onchange="checkDateFormatAll(this);" value="<cfif structKeyExists(form, "Date")>#form.Date#</cfif>" type="text" style="width:83px !important;"/>
                    </div>
                    <div style="float:left">
                        <label style="font-weight: bold;width:80px;">Type:</label>
                        <select id="Type" name="Type" style="height: 21px;width: 106px;" >
                            <option value="">Select</option>
                            <option value="RS">RS-Sales</option>
                            <option value="CR">CR-Cash Receipt</option>
                            <option value="RP">RP-Purchase</option>
                            <option value="CD">CD-Cash Disbursement</option>
                            <option value="GJ">GJ-General Journal</option>
                            <option value="OT">OT-Other</option>
                            <option value="PR">PR-Payroll</option>
                            <option value="YE">YE-Year End</option>
                            <option value="BB">BB-Beg. Bal.</option>
                        </select>
                    </div>
                    <div class="clear"></div>
                    <div style="float:left">
                        <label style="width:77px;margin-left: 20px;">Code:</label>
                        <input tabindex="7" class="sm-input gl-lookup" id="code" name="code" value="<cfif structKeyExists(form, "Code")>#form.Code#</cfif>" type="text" style="width:100px !important;" data-fieldName="Code"/>
                    </div>
                    <div style="float:left">
                        <label style="font-weight: bold;width:77px;">Entered By:</label>
                        <input tabindex="8" class="sm-input" id="EnteredBy" name="EnteredBy" value="<cfif structKeyExists(form, "EnteredBy")>#form.EnteredBy#</cfif>" type="text" style="width:100px !important;" />
                    </div>
                    <div class="clear"></div>
                    <div style="float:left">
                        <label style="width:77px;margin-left: 20px;">Transaction##:</label>
                        <input tabindex="9" class="sm-input gl-lookup" id="InvoiceCode" name="InvoiceCode" value="<cfif structKeyExists(form, "InvoiceCode")>#form.InvoiceCode#</cfif>" type="text" style="width:100px !important;" data-fieldName="Invoice Code"/>
                    </div>
                    <div style="float:left">
                        <label style="font-weight: bold;width:77px;">Entry Date:</label>
                        <input tabindex="10" class="sm-input datefield" id="EntryDate" name="EntryDate"  onchange="checkDateFormatAll(this);" value="<cfif structKeyExists(form, "EntryDate")>#form.EntryDate#</cfif>" type="text" style="width:83px !important;"/>
                    </div>
                    <div class="clear"></div>
                    <input name="Submit" onclick="javascript: document.getElementById('pageNo').value=1;" type="submit" class="s-bttn" value="Find" style="width:56px;margin-left: 307px;" />
                    <div class="clear"></div>
                 </fieldset>
                 <fieldset style="border-width: 2px;border-style: ridge;border-color: threedface;border-image: initial;width:10%;padding:5px;float:left;margin-left: 10px;">
                    <legend style="margin-left: 10px;"><b>Debit/Credit</b></legend>
                    <input class="sm-input chkDC" name="DC" <cfif structKeyExists(form, "DC") AND form.dc EQ "D">checked </cfif> value="D" type="checkbox" style="height: 15px;width: 15px !important;margin-left: 20px;"><label style="font-weight: bold;width:25px;">Debit</label>
                    <div class="clear"></div>
                    <input class="sm-input chkDC" name="DC" <cfif structKeyExists(form, "DC") AND form.dc EQ "C">checked </cfif> value="C" type="checkbox" style="height: 15px;width: 15px !important;margin-left: 20px;"><label style="font-weight: bold;width:25px;">Credit</label>
                    <div class="clear"></div>
                    <input class="sm-input chkDC" name="DC" <cfif ((structKeyExists(form, "DC") AND form.dc EQ "Both") OR (NOT structKeyExists(form, "DC")))>checked </cfif> value="Both" type="checkbox" style="height: 15px;width: 15px !important;margin-left: 20px;"><label style="font-weight: bold;width:25px;">Both</label>
                </fieldset>
            </cfform>     
        </div>
    </div>
    <div class="clear"></div>
    <cfset pageSize = 30>
    <cfif isdefined("form.pageNo")>
        <cfset rowNum = ((form.pageNo-1)*pageSize)>
    <cfelse>
        <cfset rowNum = 0>
    </cfif>
    <cfif structKeyExists(request, "qGLTransactions")>
        <table width="100%" border="0" class="data-table" cellspacing="0" cellpadding="0" style="color:##000000;">
            <thead>
                <tr>
                    <th  align="left" valign="top"><img src="images/top-left.gif" alt="" width="5" height="23" /></th>
                    <th  align="center" valign="middle" class="head-bg">&nbsp;</th>
                    <th align="center" valign="middle" class="head-bg" onclick="sortTableBy('Invoice Code','FindGLTransactionsForm')">Transaction Code</th>
                    <th align="center" valign="middle" class="head-bg" onclick="sortTableBy('GL Account','FindGLTransactionsForm')">Account</th>
                    <th align="center" valign="middle" class="head-bg" onclick="sortTableBy('Date','FindGLTransactionsForm')">Date</th>
                    <th  align="center" valign="middle" class="head-bg" onclick="sortTableBy('Code','FindGLTransactionsForm')">Code</th>
                    <th  align="center" valign="middle" class="head-bg" onclick="sortTableBy('Description','FindGLTransactionsForm')">Description</th>
                    <th  align="center" valign="middle" class="head-bg" onclick="sortTableBy('D/C','FindGLTransactionsForm')">D/C</th>
                    <th  align="center" valign="middle" class="head-bg" onclick="sortTableBy('Amount','FindGLTransactionsForm')">Amount</th>
                    <th  align="center" valign="middle" class="head-bg" onclick="sortTableBy('TypeTran','FindGLTransactionsForm')">Type</th>
                    <th  align="center" valign="middle" class="head-bg" onclick="sortTableBy('Description','FindGLTransactionsForm')">Type Description</th>
                    <th  align="center" valign="middle" class="head-bg" onclick="sortTableBy('EnteredBy','FindGLTransactionsForm')">Entered By</th>
                    <th align="center" valign="middle" class="head-bg2" onclick="sortTableBy('EntryDate','FindGLTransactionsForm')">Entered Date</th>
                    <th  align="right" valign="top"><img src="images/top-right.gif" alt="" width="5" height="23" /></th>
                </tr>
            </thead>
            <tbody>
                <cfif request.qGLTransactions.recordcount>
                    <cfloop query="request.qGLTransactions">
                        <tr <cfif  request.qGLTransactions.currentRow mod 2 eq 0>bgcolor="##FFFFFF"<cfelse>bgcolor="##f7f7f7"</cfif>>
                            <td height="20" class="sky-bg">&nbsp;</td>
                            <td class="sky-bg2" valign="middle" align="center" onclick="document.location.href='index.cfm?event=ReverseJournalEntry&Trans_Number=#request.qGLTransactions.TransactionCode#&#session.URLToken#'"><a href="index.cfm?event=ReverseJournalEntry&Trans_Number=#request.qGLTransactions.TransactionCode#&#session.URLToken#">#rowNum +  request.qGLTransactions.currentRow#</a></td>
                            <td  align="left" valign="middle" nowrap="nowrap" class="normal-td" onclick="document.location.href='index.cfm?event=ReverseJournalEntry&Trans_Number=#request.qGLTransactions.TransactionCode#&#session.URLToken#'"><a href="index.cfm?event=ReverseJournalEntry&Trans_Number=#request.qGLTransactions.TransactionCode#&#session.URLToken#">#request.qGLTransactions.TransactionCode#</a></td>
                            <td  align="left" valign="middle" nowrap="nowrap" class="normal-td" onclick="document.location.href='index.cfm?event=ReverseJournalEntry&Trans_Number=#request.qGLTransactions.TransactionCode#&#session.URLToken#'"><a href="index.cfm?event=ReverseJournalEntry&Trans_Number=#request.qGLTransactions.TransactionCode#&#session.URLToken#">#request.qGLTransactions.Account#</a></td>
                            <td  align="left" valign="middle" nowrap="nowrap" class="normal-td" onclick="document.location.href='index.cfm?event=ReverseJournalEntry&Trans_Number=#request.qGLTransactions.TransactionCode#&#session.URLToken#'"><a href="index.cfm?event=ReverseJournalEntry&Trans_Number=#request.qGLTransactions.TransactionCode#&#session.URLToken#">#request.qGLTransactions.Date#</a></td>
                            <td  align="left" valign="middle" nowrap="nowrap" class="normal-td" onclick="document.location.href='index.cfm?event=ReverseJournalEntry&Trans_Number=#request.qGLTransactions.TransactionCode#&#session.URLToken#'"><a href="index.cfm?event=ReverseJournalEntry&Trans_Number=#request.qGLTransactions.TransactionCode#&#session.URLToken#">#request.qGLTransactions.Code#</a></td>
                            <td  align="left" valign="middle" nowrap="nowrap" class="normal-td" onclick="document.location.href='index.cfm?event=ReverseJournalEntry&Trans_Number=#request.qGLTransactions.TransactionCode#&#session.URLToken#'"><a href="index.cfm?event=ReverseJournalEntry&Trans_Number=#request.qGLTransactions.TransactionCode#&#session.URLToken#">#request.qGLTransactions.Description#</a></td>
                            <td  align="left" valign="middle" nowrap="nowrap" class="normal-td" onclick="document.location.href='index.cfm?event=ReverseJournalEntry&Trans_Number=#request.qGLTransactions.TransactionCode#&#session.URLToken#'"><a href="index.cfm?event=ReverseJournalEntry&Trans_Number=#request.qGLTransactions.TransactionCode#&#session.URLToken#">#request.qGLTransactions.DC#</a></td>
                            <td  align="right" valign="middle" nowrap="nowrap" class="normal-td" style="padding-right: 5px;" onclick="document.location.href='index.cfm?event=ReverseJournalEntry&Trans_Number=#request.qGLTransactions.TransactionCode#&#session.URLToken#'"><a href="index.cfm?event=ReverseJournalEntry&Trans_Number=#request.qGLTransactions.TransactionCode#&#session.URLToken#">#DollarFormat(request.qGLTransactions.Amount)#</a></td>
                            <td  align="left" valign="middle" nowrap="nowrap" class="normal-td" onclick="document.location.href='index.cfm?event=ReverseJournalEntry&Trans_Number=#request.qGLTransactions.TransactionCode#&#session.URLToken#'"><a href="index.cfm?event=ReverseJournalEntry&Trans_Number=#request.qGLTransactions.TransactionCode#&#session.URLToken#">#request.qGLTransactions.TypeTran#</a></td>
                            <td  align="left" valign="middle" nowrap="nowrap" class="normal-td" onclick="document.location.href='index.cfm?event=ReverseJournalEntry&Trans_Number=#request.qGLTransactions.TransactionCode#&#session.URLToken#'"><a href="index.cfm?event=ReverseJournalEntry&Trans_Number=#request.qGLTransactions.TransactionCode#&#session.URLToken#">
                                <cfswitch expression="#request.qGLTransactions.TypeTran#">
                                    <cfcase value="CR">Cash Receipt</cfcase>
                                    <cfcase value="GJ">General Journal</cfcase>
                                    <cfcase value="BB">Beg. Bal.</cfcase>
                                    <cfcase value="RP">Purchase</cfcase>
                                    <cfcase value="CD">Cash Disbursement</cfcase>
                                </cfswitch>
                                </a>
                            </td>
                            <td  align="left" valign="middle" nowrap="nowrap" class="normal-td" onclick="document.location.href='index.cfm?event=ReverseJournalEntry&Trans_Number=#request.qGLTransactions.TransactionCode#&#session.URLToken#'"><a href="index.cfm?event=ReverseJournalEntry&Trans_Number=#request.qGLTransactions.TransactionCode#&#session.URLToken#">#request.qGLTransactions.EnteredBy#</a></td>
                            <td  align="left" valign="middle" nowrap="nowrap" class="normal-td2" onclick="document.location.href='index.cfm?event=ReverseJournalEntry&Trans_Number=#request.qGLTransactions.TransactionCode#&#session.URLToken#'"><a href="index.cfm?event=ReverseJournalEntry&Trans_Number=#request.qGLTransactions.TransactionCode#&#session.URLToken#">#request.qGLTransactions.EntryDate#</a></td>
                            <td class="normal-td3">&nbsp;</td>
                        </tr>
                    </cfloop>
                <cfelse>
                    <tr>
                        <td height="20" class="sky-bg">&nbsp;</td>
                        <td colspan="12" align="center" style="background-color: #request.qGetSystemSetupOptions.BackgroundColorForContentAccounting# !important;">No Records Found.</td>
                        <td class="normal-td3">&nbsp;</td>
                    </tr>

                </cfif>
           </tbody>
           <tfoot>
                <tr>
                    <td width="5" align="left" valign="top"><img src="images/left-bot.gif" alt="" width="5" height="23" /></td>
                    <td colspan="12" align="left" valign="middle" class="footer-bg">
                        <div class="up-down">
                            <div class="arrow-top"><a href="javascript: tablePrevPage('FindGLTransactionsForm');"><img src="images/arrow-top.gif" alt="" /></a></div>
                            <div class="arrow-bot"><a href="javascript: tableNextPage('FindGLTransactionsForm');"><img src="images/arrow-bot.gif" alt="" /></a></div>
                        </div>
                        <div class="gen-left" style="font-size: 14px;">
                          <cfif request.qGLTransactions.recordcount>
                            <button type="button" class="bttn_nav" onclick="tablePrevPage('FindGLTransactionsForm');">PREV</button>
                              Page 
                              <input type="text" onkeyup="if (/\D/g.test(this.value)) this.value = this.value.replace(/\D/g,'')" value="<cfif structKeyExists(form, "pageNo")>#form.pageNo#<cfelse>1</cfif>" id="jumpPageNo" style="text-align: center;width: 25px;" onchange="jumpToPage('FindGLTransactionsForm')">
                                  <input type="hidden" id="TotalPages" value="#request.qGLTransactions.TotalPages#">
                              of #request.qGLTransactions.TotalPages#
                              <button type="button" class="bttn_nav" onclick="tableNextPage('FindGLTransactionsForm');">NEXT</button>
                          </cfif>
                        </div>
                        <div class="gen-right"><img src="images/loader.gif" alt="" /></div>
                        <div class="clear"></div>
                    </td>
                    <td width="5" align="right" valign="top"><img src="images/right-bot.gif" alt="" width="5" height="23" /></td>
                </tr>  
            </tfoot>   
        </table>
    </cfif>
</cfoutput>