<cfoutput>
    <cfif structKeyExists(url, "delTrans_Number")>
        <cfinvoke component="#variables.objLoadGateway#" method="deleteJournal" Trans_Number="#url.delTrans_Number#" returnvariable="session.PostJournalMsg"/>
        <cflocation url="index.cfm?event=JournalEntry&#session.URLToken#">
    </cfif>
    <cfif structKeyExists(form, "PostJournal")>
        <cfinvoke frmStruct="#form#" component="#variables.objLoadGateway#" method="PostJournal" returnvariable="resp"/>
        <cfset session.PostJournalMsg = resp>
        <cfif session.PostJournalMsg.res EQ 'success'>
            <cflocation url="index.cfm?event=JournalEntry&#session.URLToken#">
        </cfif>
    </cfif>
    <cfparam name="url.Trans_Number" default="0">
    <cfinvoke component="#variables.objLoadGateway#" method="getAcctDeptList" returnvariable="qAcctDeptList" />
    <cfinvoke component="#variables.objLoadGateway#" Trans_Number="#url.Trans_Number#" method="getJournalEntry" returnvariable="qJournalEntry" />
    <cfinvoke component="#variables.objloadGateway#" method="getSystemSetupOptions" returnvariable="request.qGetSystemSetupOptions" />

    <cfif url.Trans_Number EQ 0>
        <cfinvoke component="#variables.objloadGateway#" method="getNextGJNumber" returnvariable="url.Trans_Number" />
    </cfif>

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
            width: 97%;
            float: left;
            margin-top: 5px;
            background-color: ##b9e4b9;
        }
        .msg-area-error{
            border: 1px solid ##da4646;
            padding: 5px 15px;
            font-weight: normal;
            margin: 0 auto;
            width: 97%;
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
        .disabledLoadInputs{
            height: 17px;
        }
    </style>
    <script>
        $(document).ready(function(){
            $('##Trans_Date').focus();

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
                            if (v.value.startsWith(val)) {
                                keyFound = 1;
                                keyValue = v.value;
                                $('##description_'+indx).val(v.description);
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
                        else{
                            $(this).val(keyValue);
                        }
                    },
                    select: function(e, ui) {
                        var indx = $(this).attr('id').split('_')[1];
                        $('##description_'+indx).val(ui.item.description);
                        $('##description_'+indx).focus();
                        return false;
                    }  
                });
            });

            $(".CD").keyup(function(){
                var val=$.trim($(this).val());
                if(val.length){
                    var uc=val.toUpperCase();
                    if(uc == 'D' || uc == 'C'){
                        $(this).val(uc);
                    }
                    else{
                        $(this).val('');
                    }
                }
            });

            $(document).on('change', '.hFields', function () {
                var fieldName = $(this).attr('id');
                var trans_number = $('##trans_number').val();
                var val = $(this).val();

                $.ajax({
                    type    : 'POST',
                    url     : "../gateways/loadgateway.cfc?method=setJournalEntryHeader",
                    data    : {fieldName : fieldName,value:val,trans_number:trans_number, dsn:"#application.dsn#",EnteredBy:'#session.adminusername#',CompanyID:'#session.companyid#'},
                    success :function(trans_number){
                        $('##trans_number').val(trans_number);
                        $('##delTransNumber').attr('href','index.cfm?event=PostJournalEntry&delTrans_number='+trans_number+'&#session.URLToken#');
                    }
                })
            })

            $(document).on('change', '.GL-Fields', function () {
                var row = $(this).closest("tr");
                var id=$(row).attr('id').split('_')[1];
                var fieldName = $(this).attr('data-fieldName');
                var val = $(this).val();
                var trans_number = $('##trans_number').val();

                var debit_credit = '';
                var amount = '';

                var Difference = parseFloat($('##Difference').val().replace(/[$,]/g, ''));

                if(fieldName == 'GJL Account Number'){
                    var keyFound = 0;
                    $.each(sourceJson, function(i, v) {
                        if (v.value.startsWith(val)) {
                            val = v.value;
                            keyFound = 1;
                            if(Difference<=0){
                                
                                if(Difference<0){
                                    debit_credit = 'D';
                                    $('##creditdebit_'+id).val(debit_credit);
                                    amount = -1*Difference;
                                    $('##credit_'+id).val('$0.00');
                                    $('##amount_'+id).val(amount);
                                    formatDollarNegative(amount, "amount_"+id);
                                    $('##debit_'+id).val(amount);
                                    formatDollarNegative(amount, "debit_"+id);
                                }
                                else{
                                    debit_credit = v.creditdebit;
                                    $('##creditdebit_'+id).val(debit_credit);
                                }
                                
                            }
                            else{
                                debit_credit = 'C';
                                $('##creditdebit_'+id).val(debit_credit);
                                amount = Difference;

                                $('##debit_'+id).val('$0.00');
                                $('##amount_'+id).val(amount);
                                formatDollarNegative(amount, "amount_"+id);
                                $('##credit_'+id).val(amount);
                                formatDollarNegative(amount, "credit_"+id);

                            }
                            return false;
                        }
                    });
                    if(keyFound==0){
                        return false;
                    }
                }


                if(fieldName == 'D/C'){
                    debit_credit = $('##creditdebit_'+id).val();
                    amount = $('##amount_'+id).val();
                    if(debit_credit == 'D'){
                        $('##debit_'+id).val(amount);
                        $('##credit_'+id).val('$0.00');
                    }
                    if(debit_credit == 'C'){
                        $('##credit_'+id).val(amount);
                        $('##debit_'+id).val('$0.00');
                    }
                    calculateDifference();
                }

                if(fieldName == 'Amount'){
                    debit_credit = $('##creditdebit_'+id).val();
                    amount = $('##amount_'+id).val();

                    if(isNaN(amount.replace(/[$,]/g, ''))){
                        amount = 0;
                        val = 0;
                        $('##amount_'+id).val('$0.00');
                    }

                    if(!$.trim(debit_credit).length){
                        if(Difference<=0){
                            $('##creditdebit_'+id).val('D');
                            var debit_credit = 'D';
                        }
                        else{
                            $('##creditdebit_'+id).val('C');
                            var debit_credit = 'C';
                        }
                    }

                    if($.trim(debit_credit)=='D'){
                        $('##debit_'+id).val($(this).val());
                    }
                    else{
                        $('##credit_'+id).val($(this).val());
                    }
                }

                calculateDifference();
                $.ajax({
                    type    : 'POST',
                    url     : "../gateways/loadgateway.cfc?method=setJournalEntry",
                    data    : {fieldName : fieldName,id:id,value:val,trans_number:trans_number, dsn:"#application.dsn#",CompanyID:'#session.companyid#',debit_credit:debit_credit,amount:amount,EnteredBy:'#session.adminusername#'},
                    success :function(response){
                        var resData = jQuery.parseJSON(response);
                        var ID=resData.ID

                        if(!$.trim(trans_number).length){
                            $('##trans_number').val(resData.TRANS_NUMBER);
                            $('##delTransNumber').attr('href','index.cfm?event=PostJournalEntry&delTrans_number='+resData.TRANS_NUMBER+'&#session.URLToken#');
                        }

                        if(id==0){
                            var tr_clone    = $('##tr_0').clone();
                            $('##id_0').html('');
                            $('##tr_0').attr('id','tr_'+ID);
                            $('##id_0').attr('id','id_'+ID);
                            $('##date_0').attr('id','date_'+ID);
                            $('##glacct_0').attr('id','glacct_'+ID);
                            $('##description_0').attr('id','description_'+ID);
                            $('##creditdebit_0').attr('id','creditdebit_'+ID);
                            $('##amount_0').attr('onchange','formatDollarNegative(this.value, "amount_'+ID+'")');
                            $('##amount_0').attr('id','amount_'+ID);
                            $('##credit_0').attr('id','credit_'+ID);
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
                                        if (v.value.startsWith(val)) {
                                            keyFound = 1;
                                            keyValue = v.value;
                                            $('##description_'+indx).val(v.description);
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
                                    else{
                                        $(this).val(keyValue);
                                    }
                                },
                                select: function(e, ui) {
                                    var indx = $(this).attr('id').split('_')[1];
                                    $('##description_'+indx).val(ui.item.description);
                                    $('##description_'+indx).focus();
                                    return false;
                                }  
                            });
                        }
                    },
                    beforeSend:function() {
                    },
                });
            });
        })
        
        function delRow(ID){
            if(ID != 0){
                if(confirm('Are you sure you want to delete this entry?')){
                    $.ajax({
                        type    : 'POST',
                        url     : "../gateways/loadgateway.cfc?method=deleteJournalEntry",
                        data    : {id:ID, dsn:"#application.dsn#"},
                        success :function(){
                            $('##tr_'+ID).remove();
                        },
                        beforeSend:function() {
                        },
                    });
                }
            }
            
        }

        function calculateDifference(){

            var debitAmount = 0;
            var creditAmount = 0;

            $("input[data-fieldName='Debit']").each(function(){
                var amt = parseFloat($(this).val().replace(/[$,]/g, ''));
                debitAmount = debitAmount + amt;
            })
            $('##debitAmount').val(debitAmount);
            formatDollarNegative(debitAmount, 'debitAmount');

            $("input[data-fieldName='Credit']").each(function(){
                var amt = parseFloat($(this).val().replace(/[$,]/g, ''));
                creditAmount = creditAmount + amt;
            })
            $('##creditAmount').val(creditAmount);
            formatDollarNegative(creditAmount, 'creditAmount');


            var Difference = debitAmount-creditAmount;
            $('##Difference').val(Difference);
            formatDollarNegative(Difference, 'Difference');
        }

        function validatePost(){
            var Difference = parseFloat($('##Difference').val().replace(/[$,]/g, ''));
            var errorFound = 0;
            $( ".GL-Fields" ).each(function() {
                var fieldName = $(this).attr('data-fieldName');
                if(fieldName=='Amount'){
                    var id=$(this).attr('id').split('_')[1];
                    if(id!=0 && parseFloat($(this).val().replace(/[$,]/g, '')) == 0){
                        //alert('Please enter a value other than $0 before posting');
                        //$(this).focus();
                        //return false;
                        $(this).focus();
                        errorFound = 1;
                    }
                    
                }
            });
       

            if(Difference!=0){
                alert('The amounts are not in balance, please correct this and try again.');
            }
            else if(!$.trim($('##Trans_Date').val()).length){
                alert('Please enter a Trans. Date.');
                $('##Trans_Date').focus();
            }
            else if (errorFound==1){
                alert('Please enter a value other than $0 before posting.');
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
            <h2 style="color:white;font-weight:bold;margin-left: 12px;">Journal Entry</h2>
        </div>
        <div class="delbutton" style="float:right;">
            <a id="delTransNumber" href="index.cfm?event=PostJournalEntry&delTrans_number=#url.trans_number#&#session.URLToken#" onclick="return confirm('Are you sure you want to delete this term?');">  Delete</a>
        </div>
    </div>
    <div style="clear:left"></div>
    <cfset pageSize = 30>
    <cfif isdefined("form.pageNo")>
        <cfset rowNum = ((form.pageNo-1)*pageSize)>
    <cfelse>
        <cfset rowNum = 0>
    </cfif>
    <cfform id="PostJournalEntryForm" name="PostJournalEntryForm" action="index.cfm?event=PostJournalEntry&Trans_Number=#url.Trans_Number#&#session.URLToken#" method="post" preserveData="yes" onsubmit="return validatePost();">
        <div class="search-panel" style="width:100%;">
            <div class="form-search" style="width:100%;background-color: #request.qGetSystemSetupOptions.BackgroundColorForContentAccounting# !important;padding-bottom: 10px;">
                <fieldset style="width:100%;float:left;">
                    <div style="float:left">
                        <label style="font-weight: bold;width:75px;margin-left: 20px;">Journal##</label>
                        <input tabindex="1000" class="sm-input disabledLoadInputs" id="trans_number" name="trans_number" readonly value="<cfif len(trim(url.trans_number))>#url.trans_number#</cfif>"/>
                    </div>
                    <div style="float:left">
                        <label style="font-weight: bold;width:40px;">Type</label>
                        <select name="Type">
                            <option value="GJ">GJ</option>
                        </select>
                    </div>
                    <div style="float:left">
                        <label style="font-weight: bold;width:85px;margin-left: 10px;">Post Date</label>
                        <input class="sm-input datefield hFields" id="Trans_Date" onchange="checkDateFormatAll(this);" value="#dateFormat(qJournalEntry.Trans_Date,'m/d/yyyy')#" type="text" style="width:65px !important;text-align: right;"/>
                    </div>
                    <div style="float:left">
                        <label style="font-weight: bold;width:85px;margin-left: 10px;">Code/Reference</label>
                        <input class="sm-input hFields" maxlength="50" id="Cust_Vend_Code" value="#qJournalEntry.Cust_Vend_Code#" type="text" style="width:65px !important;"/>
                    </div>
                    <div style="float:left">
                        <label style="font-weight: bold;width:85px;margin-left: 10px;">Entered By</label>
                        <input class="sm-input hFields disabledLoadInputs" id="EnteredBy" <cfif len(trim(qJournalEntry.EnteredBy))>value="#qJournalEntry.EnteredBy#"<cfelse>value="#session.adminusername#"</cfif> type="text" readonly style="width:65px !important;" tabindex="1000"/>
                    </div>
                </fieldset>
            </div>
        </div>
        <div class="clear"></div>
        <cfif structKeyExists(session, "PostJournalMsg")>
            <div id="message" class="msg-area-#session.PostJournalMsg.res#">#session.PostJournalMsg.msg#</div>
            <cfset structDelete(session, "PostJournalMsg")>
        </cfif>
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
                    <cfset totalCreditAmount = totalCreditAmount+qJournalEntry.Credit>
                    <tr id="tr_#qJournalEntry.ID#">
                        <td height="20" class="sky-bg">&nbsp;</td>
                        <td class="sky-bg2" valign="middle" align="center">&nbsp;</td>
                        <td  align="left" valign="middle" nowrap="nowrap" class="normal-td">
                            <input  style="width:96%;text-align: right;" class="GL-Fields" value="#DateFormat(qJournalEntry.Date,'m/d/yyyy')#" data-fieldName="Date" id="date_#qJournalEntry.ID#">
                        </td>
                        <td  align="left" valign="middle" nowrap="nowrap" class="normal-td">
                            <input  style="width:96%;" class="GLAccount GL-Fields" value="#qJournalEntry.GJLAccountNumber#" data-fieldName="GJL Account Number" id="glacct_#qJournalEntry.ID#">
                        </td>
                        <td  align="left" valign="middle" nowrap="nowrap" class="normal-td">
                            <input style="width:99%;" class="GL-Fields" value="#qJournalEntry.Description#" data-fieldName="Description" id="description_#qJournalEntry.ID#">
                        </td>
                        <td  align="left" valign="middle" nowrap="nowrap" class="normal-td">
                            <input style="width:93%;" class="GL-Fields" value="#qJournalEntry.DC#" data-fieldName="D/C" maxlength="1" id="creditdebit_#qJournalEntry.ID#">
                        </td>
                        <td  align="left" valign="middle" nowrap="nowrap" class="normal-td">
                            <input  style="width:97%;text-align: right;" class="GL-Fields" value="#DollarFormat(qJournalEntry.Amount)#" data-fieldName="Amount" id="amount_#qJournalEntry.ID#" onchange="formatDollarNegative(this.value, 'amount_#qJournalEntry.ID#');">
                        </td>
                        <td align="left" valign="middle" nowrap="nowrap" class="normal-td">
                           <input style="width:97%;text-align: right;" class="GL-Fields disabledLoadInputs" value="#DollarFormat(qJournalEntry.Debit)#" tabindex="1000" readonly data-fieldName="Debit" id="debit_#qJournalEntry.ID#">
                        </td>
                        <td  align="right" valign="middle" nowrap="nowrap" class="normal-td">
                            <input style="width:97%;text-align: right;" class="GL-Fields disabledLoadInputs" value="#DollarFormat(qJournalEntry.Credit)#" tabindex="1000" readonly data-fieldName="Credit" id="credit_#qJournalEntry.ID#">
                        </td>
                        <td  align="left" valign="middle" nowrap="nowrap" class="normal-td2">
                            <img onclick="delRow(#qJournalEntry.ID#)" id="del_#qJournalEntry.ID#" src="images/delete-icon.gif" style="width:10px;margin-left: 5px;cursor: pointer;float:left">
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
                            <input  style="width:96%;text-align: right;" class="GL-Fields" value="#dateFormat(now(),'m/d/yyyy')#" data-fieldName="Date" id="date_0">
                        </td>
                        <td  align="left" valign="middle" nowrap="nowrap" class="normal-td">
                            <input  style="width:96%;" class="GLAccount GL-Fields" value="" data-fieldName="GJL Account Number" id="glacct_0">
                        </td>
                        <td  align="left" valign="middle" nowrap="nowrap" class="normal-td">
                            <input style="width:99%;" class="GL-Fields" value="" data-fieldName="Description" id="description_0">
                        </td>
                        <td  align="left" valign="middle" nowrap="nowrap" class="normal-td">
                            <input style="width:93%;" class="GL-Fields CD" maxlength="1" value="" data-fieldName="D/C" id="creditdebit_0">
                        </td>
                        <td  align="left" valign="middle" nowrap="nowrap" class="normal-td">
                            <input  style="width:97%;text-align: right;" class="GL-Fields" value="#dollarFormat(0)#" data-fieldName="Amount" id="amount_0" onchange="formatDollarNegative(this.value, 'amount_0');">
                        </td>
                        <td align="left" valign="middle" nowrap="nowrap" class="normal-td">
                           <input style="width:97%;text-align: right;" class="GL-Fields disabledLoadInputs" value="#dollarFormat(0)#" data-fieldName="Debit" tabindex="1000" readonly id="debit_0" >
                        </td>
                        <td  align="right" valign="middle" nowrap="nowrap" class="normal-td">
                            <input style="width:97%;text-align: right;" class="GL-Fields disabledLoadInputs" value="#dollarFormat(0)#" data-fieldName="Credit" tabindex="1000" readonly id="credit_0">
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
                <label style="width:77px;margin-left: 20px;"><b>Total Debits:</b></label>
                <input class="disabledLoadInputs" id="debitAmount" name="debitAmount" type="text" style="width:125px !important;text-align: right;" value="#DollarFormat(totalDebitAmount)#" readonly tabindex="1000" />

                <label style="width:77px;margin-left: 20px;"><b>Total Credits:</b></label>
                <input class="disabledLoadInputs" id="creditAmount" name="creditAmount" type="text" style="width:125px !important;text-align: right;" value="#DollarFormat(totalCreditAmount)#"  readonly tabindex="1000"/>

                <label style="width:77px;margin-left: 20px;"><b>Difference:</b></label>
                <input class="disabledLoadInputs" id="Difference" name="Difference" type="text" style="width:125px !important;text-align: right;" value="#DollarFormat(totalDebitAmount-totalCreditAmount)#" readonly tabindex="1000"/>
            </div>
            <div style="text-align: right;margin-right: 105px;">
                <button class="btn" name="PostJournal"><b>Post Journal</b></button>
            </div> 
        </fieldset>
    </cfform>
</cfoutput>