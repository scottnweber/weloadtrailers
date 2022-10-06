<cfoutput>
    <cfif structKeyExists(form, "ReverseJournal")>
        <cfinvoke frmStruct="#form#" component="#variables.objLoadGateway#" method="ReverseJournal" returnvariable="resp"/>
        <cfif resp.res EQ 'success'>
            <cflocation url="index.cfm?event=PostJournalEntry&Trans_Number=#resp.msg#&#session.URLToken#">
        </cfif>
    </cfif>
    <cfparam name="url.Trans_Number" default="0">
    <cfinvoke component="#variables.objLoadGateway#" method="getAcctDeptList" returnvariable="qAcctDeptList" />
    <cfinvoke component="#variables.objLoadGateway#" Trans_Number="#url.Trans_Number#" method="getReverseJournalEntry" returnvariable="qJournalEntry" />
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
        .head-bg,.head-bg2{
            background-size: contain;
        }
        .normal-td,.normal-td2{
            padding: 0px;
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
                    {label: "#qAcctDeptList.GL_ACCT#", value: "#qAcctDeptList.GL_ACCT#", description:"#qAcctDeptList.description#",creditdebit:"#qAcctDeptList.credit_debit#"},
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
                        var indx = $(this).attr('id').split('_')[1];
                        var val = $(this).val();
                        var keyFound = 0;
                        $.each(sourceJson, function(i, v) {
                            if (v.value == val) {
                                keyFound = 1;
                                $('##description_'+indx).val(v.description);
                                if($('##type').val() == 'C'){
                                    $('##creditdebit_'+indx).val('D');
                                }
                                else{
                                    $('##creditdebit_'+indx).val(v.creditdebit);
                                }
                                return false;
                            }
                        });
                        if(keyFound==0){
                            alert('Invalid account number. Please correct and try again');
                            $(this).val('');
                            $(this).focus();
                            $(this).val('');
                            return false;
                        }
                    },
                    select: function(e, ui) {
                        var indx = $(this).attr('id').split('_')[1];
                        $('##description_'+indx).val(ui.item.description);
                        if($('##type').val() == 'C'){
                            $('##creditdebit_'+indx).val('D');
                        }
                        else{
                            $('##creditdebit_'+indx).val(ui.item.creditdebit);
                        }
                        $('##description_'+indx).focus();
                        return false;
                    }  
                });
            });

            $(document).on('change', '.GL-Fields', function () {
                var row = $(this).closest("tr");
                var id=$(row).attr('id').split('_')[1];
                var fieldName = $(this).attr('data-fieldName');
                var val = $(this).val();
                var trans_number = $('##trans_number').val();
                if(fieldName == 'GJL Account Number'){
                    var keyFound = 0;
                    $.each(sourceJson, function(i, v) {
                        if (v.value == val) {
                            keyFound = 1;
                        }
                    });
                    if(keyFound==0){
                        return false;
                    }
                }

                if(fieldName == 'Debit'){
                    var debitAmount = 0;
                    formatDollarNegative(val, $(this).attr('id'));
                    $("input[data-fieldName='Debit']").each(function(){
                        var amt = parseFloat($(this).val().replace(/[$,]/g, ''));
                        debitAmount = debitAmount + amt;
                    })
                    $('##debitAmount').val(debitAmount);
                    formatDollarNegative(debitAmount, 'debitAmount');
                    calculateDifference();
                }

                if(fieldName == 'Credit'){
                    var creditAmount = 0;
                    formatDollarNegative(val, $(this).attr('id'));
                    $("input[data-fieldName='Credit']").each(function(){
                        var amt = parseFloat($(this).val().replace(/[$,]/g, ''));
                        creditAmount = creditAmount + amt;
                    })
                    $('##creditAmount').val(creditAmount);
                    formatDollarNegative(creditAmount, 'creditAmount');
                    calculateDifference();
                }

                if(id==0){
                    var tr_clone = $('##tr_0').clone();
                    var ID = parseInt($('##ID_Val').val())+1;
                    $('##ID_Val').val(ID);

                    $('##id_0').html('');
                    $('##tr_0').attr('id','tr_'+ID);
                    $('##id_0').attr('id','id_'+ID);

                    $('##date_0').attr('name','date_'+ID);
                    $('##date_0').attr('id','date_'+ID);

                    $('##glacct_0').attr('name','glacct_'+ID);
                    $('##glacct_0').attr('id','glacct_'+ID);

                    $('##description_0').attr('name','description_'+ID);
                    $('##description_0').attr('id','description_'+ID);

                    $('##creditdebit_0').attr('name','creditdebit_'+ID);
                    $('##creditdebit_0').attr('id','creditdebit_'+ID);

                    $('##amount_0').attr('onchange','formatDollarNegative(this.value, "amount_'+ID+'")');
                    $('##amount_0').attr('name','amount_'+ID);
                    $('##amount_0').attr('id','amount_'+ID);

                    $('##credit_0').attr('name','credit_'+ID);
                    $('##credit_0').attr('id','credit_'+ID);

                    $('##debit_0').attr('name','debit_'+ID);
                    $('##debit_0').attr('id','debit_'+ID);

                    $('##del_0').attr('onclick','delRow('+ID+')');
                    $('##del_0').attr('id','del_'+ID);
                    $('##body-list').append(tr_clone);
                    $('##id_0').html('<b style="font-size: 20px;">*</b>');
                    $('##date_0').val('#dateformat(now(),'m/d/yyyy')#');
                    $('##glacct_0').val('');
                    $('##description_0').val('');
                    $('##creditdebit_0').val('');
                    $('##amount_0').val('$0.00');
                    $('##credit_0').val('$0.00');
                    $('##debit_0').val('$0.00');

                    $('##glacct_0').autocomplete({
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
                            var indx = $(this).attr('id').split('_')[1];
                            var val = $(this).val();
                            var keyFound = 0;
                            $.each(sourceJson, function(i, v) {
                                if (v.value == val) {
                                    keyFound = 1;
                                    $('##description_'+indx).val(v.description);
                                    if($('##type').val() == 'C'){
                                        $('##creditdebit_'+indx).val('D');
                                    }
                                    else{
                                        $('##creditdebit_'+indx).val(v.creditdebit);
                                    }
                                    return false;
                                }
                            });
                            if(keyFound==0){
                                alert('Invalid account number. Please correct and try again');
                                $(this).val('');
                                $(this).focus();
                                $(this).val('');
                                return false;
                            }
                        },
                        select: function(e, ui) {
                            var indx = $(this).attr('id').split('_')[1];
                            $('##description_'+indx).val(ui.item.description);
                            if($('##type').val() == 'C'){
                                $('##creditdebit_'+indx).val('D');
                            }
                            else{
                                $('##creditdebit_'+indx).val(ui.item.creditdebit);
                            }
                            $('##description_'+indx).focus();
                            return false;
                        }  
                    });
                }
            });
        })
        
        function delRow(ID){
            if(ID != 0){
                if(confirm('Are you sure you want to delete this entry?')){
                    $('##tr_'+ID).remove();
                    var startIndx = parseInt(ID)+1;
                    var endIndx = parseInt($('##ID_Val').val());

                    for(i=startIndx;i<=endIndx;i++){
                        var oldID = i;
                        var newID = i-1;
                        $('##tr_'+oldID).attr('id','tr_'+newID);
                        $('##id_'+oldID).attr('id','id_'+newID);

                        $('##date_'+oldID).attr('name','date_'+newID);
                        $('##date_'+oldID).attr('id','date_'+newID);

                        $('##glacct_'+oldID).attr('name','glacct_'+newID);
                        $('##glacct_'+oldID).attr('id','glacct_'+newID);

                        $('##description_'+oldID).attr('name','description_'+newID);
                        $('##description_'+oldID).attr('id','description_'+newID);

                        $('##creditdebit_'+oldID).attr('name','creditdebit_'+newID);
                        $('##creditdebit_'+oldID).attr('id','creditdebit_'+newID);

                        $('##amount_'+oldID).attr('onchange','formatDollarNegative(this.value, "amount_'+newID+'")');
                        $('##amount_'+oldID).attr('name','amount_'+newID);
                        $('##amount_'+oldID).attr('id','amount_'+newID);

                        $('##credit_'+oldID).attr('name','credit_'+newID);
                        $('##credit_'+oldID).attr('id','credit_'+newID);

                        $('##debit_'+oldID).attr('name','debit_'+newID);
                        $('##debit_'+oldID).attr('id','debit_'+newID);
                        $('##del_'+oldID).attr('onclick','delRow('+newID+')');
                        $('##del_'+oldID).attr('id','del_'+newID);
                    }
                    $('##ID_Val').val(endIndx-1);

                    var debitAmount = 0;
                    $("input[data-fieldName='Debit']").each(function(){
                        var amt = parseFloat($(this).val().replace(/[$,]/g, ''));
                        debitAmount = debitAmount + amt;
                    })
                    $('##debitAmount').val(debitAmount);
                    formatDollarNegative(debitAmount, 'debitAmount');

                    var creditAmount = 0;
                    $("input[data-fieldName='Credit']").each(function(){
                        var amt = parseFloat($(this).val().replace(/[$,]/g, ''));
                        creditAmount = creditAmount + amt;
                    })
                    $('##creditAmount').val(creditAmount);
                    formatDollarNegative(creditAmount, 'creditAmount');
                    calculateDifference();
                    
                }
            }
            
        }

        function calculateDifference(){
            var debitAmount = parseFloat($('##debitAmount').val().replace(/[$,]/g, ''));
            var creditAmount = parseFloat($('##creditAmount').val().replace(/[$,]/g, ''));

            var Difference = debitAmount-creditAmount;
            $('##Difference').val(Difference);
            formatDollarNegative(Difference, 'Difference');
        }

        function validatePost(){
            var Difference = parseFloat($('##Difference').val().replace(/[$,]/g, ''));
            if(Difference!=0){
                alert('Unable to post. Difference should be 0.');
            }
            else if(!$.trim($('##Trans_Date').val()).length){
                alert('Please enter a Trans. Date.');
                $('##Trans_Date').focus();
            }
            else{
                if(confirm('Are you sure you want to post?')){
                    return true;
                }
                else{
                    return false;
                }
            }
            return false;
        }
    </script>
    <div class="white-con-area" style="height: 36px;background-color: ##82bbef;width:100%;">
        <div style="float: left;">
            <h2 style="color:white;font-weight:bold;margin-left: 12px;">Reverse Journal Entry</h2>
        </div>
    </div>
    <div style="clear:left"></div>
    <cfset pageSize = 30>
    <cfif isdefined("form.pageNo")>
        <cfset rowNum = ((form.pageNo-1)*pageSize)>
    <cfelse>
        <cfset rowNum = 0>
    </cfif>
    <cfform id="PostJournalEntryForm" name="PostJournalEntryForm" action="index.cfm?event=ReverseJournalEntry&Trans_Number=#url.Trans_Number#&#session.URLToken#" method="post" preserveData="yes" onsubmit="return validatePost();">
        <input type="hidden" id="ID_Val" value="#qJournalEntry.recordcount#" name="TotalRows">
        <div class="search-panel" style="width:100%;">
            <div class="form-search" style="width:100%;background-color: #request.qGetSystemSetupOptions.BackgroundColorForContentAccounting# !important;padding-bottom: 10px;">
                <fieldset style="width:100%;float:left;">
                    <div style="float:left">
                        <label style="font-weight: bold;width:75px;margin-left: 20px;">Transaction##</label>
                        <input class="sm-input" id="trans_number" name="trans_number" readonly value="<cfif url.trans_number>#url.trans_number#</cfif>"/>
                    </div>
                    <div style="float:left">
                        <label style="font-weight: bold;width:40px;">Type</label>
                        <select name="Type">
                            <option value="GJ">GJ</option>
                        </select>
                    </div>
                    <div style="float:left">
                        <label style="font-weight: bold;width:85px;margin-left: 10px;">Trans. Date</label>
                        <input class="sm-input datefield hFields" id="Trans_Date" name="Trans_Date" onchange="checkDateFormatAll(this);" value="#dateFormat(qJournalEntry.Trans_Date,'m/d/yyyy')#" type="text" style="width:65px !important;text-align: right;"/>
                    </div>
                    <div style="float:left">
                        <label style="font-weight: bold;width:85px;margin-left: 10px;">Code/Reference</label>
                        <input class="sm-input hFields" id="Cust_Vend_Code" name="Cust_Vend_Code" value="#qJournalEntry.Cust_Vend_Code#" type="text" style="width:65px !important;"/>
                    </div>
                    <div style="float:left">
                        <label style="font-weight: bold;width:85px;margin-left: 10px;">Entered By</label>
                        <input class="sm-input hFields" id="EnteredBy" name="EnteredBy" value="#qJournalEntry.EnteredBy#" type="text" style="width:65px !important;;"/>
                    </div>
                </fieldset>
            </div>
        </div>
        <div class="clear"></div>
        <table width="100%" border="0" class="data-table" cellspacing="0" cellpadding="0" style="color:##000000;">
            <thead>
                <tr>
                    <th align="left" valign="top"><img src="images/top-left.gif" alt="" width="5" height="48" /></th>
                    <th align="center" valign="middle" class="head-bg" >&nbsp;</th>
                    <th align="center" valign="middle" class="head-bg" width="10%">Date</th>
                    <th align="center" valign="middle" class="head-bg" width="10%">G/L Account</th>
                    <th align="center" valign="middle" class="head-bg" width="35%">Description</th>
                    <th align="center" valign="middle" class="head-bg" width="6%">D/C</th>
                    <th align="center" valign="middle" class="head-bg" width="13%">Amount</th>
                    <th align="center" valign="middle" class="head-bg" width="13%">Debit</th>
                    <th align="center" valign="middle" class="head-bg" width="13%">Credit</th>
                    <th align="center" valign="middle" class="head-bg2" ></th>
                    <th align="right" valign="top"><img src="images/top-right.gif" alt="" width="5" height="48" /></th>
                </tr>
            </thead>
            <tbody id="body-list">
                <cfset totalDebitAmount = 0>
                <cfset totalCreditAmount = 0>
                <cfloop query="qJournalEntry">
                    <cfset totalDebitAmount = totalDebitAmount+qJournalEntry.Debit>
                    <cfif qJournalEntry.Credit LT 0>
                        <cfset variables.credit = -1*qJournalEntry.Credit>
                    <cfelse>
                        <cfset variables.credit = -qJournalEntry.Credit>
                    </cfif>
                    <cfset totalCreditAmount = totalCreditAmount+variables.Credit>
                    <tr id="tr_#qJournalEntry.currentrow#">
                        <td height="20" class="sky-bg">&nbsp;</td>
                        <td class="sky-bg2" valign="middle" align="center">&nbsp;</td>
                        <td  align="left" valign="middle" nowrap="nowrap" class="normal-td">
                            <input  style="width:96%;text-align: right;" class="GL-Fields" value="#DateFormat(qJournalEntry.Date,'m/d/yyyy')#" data-fieldName="Date" id="date_#qJournalEntry.currentrow#" name="date_#qJournalEntry.currentrow#">
                        </td>
                        <td  align="left" valign="middle" nowrap="nowrap" class="normal-td">
                            <input  style="width:96%;" class="GLAccount GL-Fields" value="#qJournalEntry.GJLAccountNumber#" data-fieldName="GJL Account Number" id="glacct_#qJournalEntry.currentrow#" name="glacct_#qJournalEntry.currentrow#">
                        </td>
                        <td  align="left" valign="middle" nowrap="nowrap" class="normal-td">
                            <input style="width:99%;" class="GL-Fields" value="#qJournalEntry.Description#" data-fieldName="Description" id="description_#qJournalEntry.currentrow#" name="description_#qJournalEntry.currentrow#">
                        </td>
                        <td  align="left" valign="middle" nowrap="nowrap" class="normal-td">
                            <input style="width:93%;" class="GL-Fields" value="#qJournalEntry.DC#" data-fieldName="D/C" id="creditdebit_#qJournalEntry.currentrow#" name="creditdebit_#qJournalEntry.currentrow#">
                        </td>
                        <td  align="left" valign="middle" nowrap="nowrap" class="normal-td">
                            <cfif qJournalEntry.Amount LT 0>
                                <cfset variables.Amount = -1*qJournalEntry.Amount>
                            <cfelse>
                                <cfset variables.Amount = qJournalEntry.Amount>
                            </cfif>
                            <input  style="width:97%;text-align: right;" class="GL-Fields" value="#DollarFormat(variables.Amount)#" data-fieldName="Amount" id="amount_#qJournalEntry.currentrow#" name="amount_#qJournalEntry.currentrow#" onchange="formatDollarNegative(this.value, 'amount_#qJournalEntry.currentrow#');">
                        </td>
                        <td align="left" valign="middle" nowrap="nowrap" class="normal-td">
                           <input style="width:97%;text-align: right;" class="GL-Fields" value="#DollarFormat(qJournalEntry.Debit)#" data-fieldName="Debit" id="debit_#qJournalEntry.currentrow#" name="debit_#qJournalEntry.currentrow#">
                        </td>
                        <td  align="right" valign="middle" nowrap="nowrap" class="normal-td">
                            <input style="width:97%;text-align: right;" class="GL-Fields" value="#DollarFormat(variables.Credit)#" data-fieldName="Credit" id="credit_#qJournalEntry.currentrow#" name="credit_#qJournalEntry.currentrow#">
                        </td>
                        <td  align="left" valign="middle" nowrap="nowrap" class="normal-td2">
                            <img onclick="delRow(#qJournalEntry.currentrow#)" id="del_#qJournalEntry.currentrow#" src="images/delete-icon.gif" style="width:10px;margin-left: 5px;cursor: pointer;float:left">
                        </td>
                        <td class="normal-td3">&nbsp;</td>
                    </tr>
                </cfloop>
                <tr id="tr_0">
                    <td height="20" class="sky-bg">&nbsp;</td>
                    <td class="sky-bg2" valign="middle" align="center" id="id_0">
                        <b style="font-size: 20px;">*</b>
                    </td>
                    <td  align="left" valign="middle" nowrap="nowrap" class="normal-td">
                            <input  style="width:96%;text-align: right;" class="GL-Fields" value="#dateFormat(now(),'m/d/yyyy')#" data-fieldName="Date" id="date_0" name="date_0">
                        </td>
                        <td  align="left" valign="middle" nowrap="nowrap" class="normal-td">
                            <input  style="width:96%;" class="GLAccount GL-Fields" value="" data-fieldName="GJL Account Number" id="glacct_0" name="glacct_0">
                        </td>
                        <td  align="left" valign="middle" nowrap="nowrap" class="normal-td">
                            <input style="width:99%;" class="GL-Fields" value="" data-fieldName="Description" id="description_0" name="description_0">
                        </td>
                        <td  align="left" valign="middle" nowrap="nowrap" class="normal-td">
                            <input style="width:93%;" class="GL-Fields" value="" data-fieldName="D/C" id="creditdebit_0" name="creditdebit_0">
                        </td>
                        <td  align="left" valign="middle" nowrap="nowrap" class="normal-td">
                            <input  style="width:97%;text-align: right;" class="GL-Fields" value="#dollarFormat(0)#" data-fieldName="Amount" id="amount_0" name="amount_0" onchange="formatDollarNegative(this.value, 'amount_0');">
                        </td>
                        <td align="left" valign="middle" nowrap="nowrap" class="normal-td">
                           <input style="width:97%;text-align: right;" class="GL-Fields" value="#dollarFormat(0)#" data-fieldName="Debit" id="debit_0" name="debit_0">
                        </td>
                        <td  align="right" valign="middle" nowrap="nowrap" class="normal-td">
                            <input style="width:97%;text-align: right;" class="GL-Fields" value="#dollarFormat(0)#" data-fieldName="Credit" id="credit_0" name="credit_0">
                        </td>
                        <td  align="left" valign="middle" nowrap="nowrap" class="normal-td2">
                            <img onclick="delRow(0)" id="del_0" src="images/delete-icon.gif" style="width:10px;margin-left: 5px;cursor: pointer;float:left">
                        </td>
                    <td class="normal-td3">&nbsp;</td>
                </tr>
           </tbody>
           <tfoot>
                <tr>
                    <td width="5" align="left" valign="top"><img src="images/left-bot.gif" alt="" width="5" height="23" /></td>
                    <td colspan="9" align="left" valign="middle" class="footer-bg">
                    </td>
                    <td width="5" align="right" valign="top"><img src="images/right-bot.gif" alt="" width="5" height="23" /></td>
                </tr>  
            </tfoot>   
        </table>
        <fieldset style="width:99%;padding:5px;float:left;background-color: #request.qGetSystemSetupOptions.BackgroundColorForContentAccounting# !important;">
            <div style="text-align: right;margin-right: 100px;">
                <label style="width:77px;margin-left: 20px;"><b>Debit Amount:</b></label>
                <input class="sm-input" id="debitAmount" name="debitAmount" type="text" style="width:125px !important;text-align: right;" value="#DollarFormat(totalDebitAmount)#" readonly />

                <label style="width:77px;margin-left: 20px;"><b>Credit Amount:</b></label>
                <input class="sm-input" id="creditAmount" name="creditAmount" type="text" style="width:125px !important;text-align: right;" value="#DollarFormat(totalCreditAmount)#"  readonly/>

                <label style="width:77px;margin-left: 20px;"><b>Difference:</b></label>
                <input class="sm-input" id="Difference" name="Difference" type="text" style="width:125px !important;text-align: right;" value="#DollarFormat(totalDebitAmount-totalCreditAmount)#" readonly/>
            </div>
            <div style="text-align: right;margin-right: 105px;">
                <button class="btn" name="ReverseJournal"><b>Reverse Journal</b></button>
            </div> 
        </fieldset>
    </cfform>
</cfoutput>