<cfoutput>
    <cfinvoke component="#variables.objloadGateway#" method="getSystemSetupOptions" returnvariable="request.qGetSystemSetupOptions" />
    <cfif structKeyExists(form, "PostCheck")>
        <cfinvoke component="#variables.objLoadGateway#" method="getLMASystemConfig" returnvariable="qLMASystemConfig" />
        <cfinvoke component="#variables.objLoadGateway#"  method="check_fiscal" Trans_Date="#form.invoiceDate#" returnvariable="resCkFiscal" />
        <cfset APDiscountAccount = qLMASystemConfig['AP Discount GL']>
        <cfset APGLAccount = qLMASystemConfig['AP GL Account']>
        <cfif resCkFiscal.res eq 'error'>
            <cfset session.PaymentMsg = resCkFiscal>
        <cfelseif NOT len(trim(APDiscountAccount)) OR NOT len(trim(APGLAccount)) >
            <cfset session.InvLoadsMsg.res = 'error'>
            <cfset session.InvLoadsMsg.msg = "No account number has been setup for this transaction. Please correct this and try again.">
        <cfelse>
            <cfset form.APDiscountAccount = qLMASystemConfig['AP Discount GL']>
            <cfset form.APGLAccount = qLMASystemConfig['AP GL Account']>
            <cfset form.year_past = resCkFiscal.year_past>
            <cfinvoke frmStruct="#form#" component="#variables.objLoadGateway#" method="PostInvoicePayment" returnvariable="resp"/>
            <cfset session.PaymentMsg = resp>
        </cfif>
        <cflocation url="index.cfm?event=PostInvoicePayment&#session.URLToken#">
    </cfif>
    <cfinvoke component="#variables.objLoadGateway#" method="getCheckRegisterSetup" returnvariable="qCheckRegisterSetup" />
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

        .left-th-border{
            border-left: 1px solid ##5d8cc9;
            border-top-left-radius: 5px;
        }
        .right-th-border{
            border-right: 1px solid ##5d8cc9;
            border-top-right-radius: 5px;
        }
        .left-td-border{
            border-left: 1px solid ##5d8cc9;
        }
        .footer-bg{
            border-left: 1px solid ##5d8cc9;
            border-right: 1px solid ##5d8cc9;
            border-bottom-left-radius: 5px;
            border-bottom-right-radius: 5px;
        }
        .msg-area-success{
            border: 1px solid ##a4da46;
            padding: 5px 15px;
            font-weight: normal;
            width: 72%;
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
            width: 72%;
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
            $( ".datefield" ).datepicker({
                dateFormat: "mm/dd/yy",
                showOn: "button",
                buttonImage: "images/DateChooser.png",
                buttonImageOnly: true,
                showButtonPanel: true
            });


            $('##vendorIdAuto').each(function(i, tag) {
                $(tag).autocomplete({
                    multiple: false,
                    width: 400,
                    scroll: true,
                    scrollHeight: 300,
                    cacheLength: 1,
                    highlight: false,
                    dataType: "json",
                    autoFocus: true,
                    focus: function( event, ui ) {
                        $(this).val( ui.item.vendorid );
                        return false;
                    },
                    source: 'searchLMAVendorsAutoFill.cfm?showCarriersWithBalance=1',
                    select: function(e, ui) {
                        $('##CompanyName').val( ui.item.company );
                        $('##vendorIDContainer').val( ui.item.vendorid );
                        $('##sortby').val( '' );
                        $('##sortorder').val( '' );
                        loadContent('Date');
                        return false;
                    }
                });
                $(tag).data("ui-autocomplete")._renderItem = function(ul, item) {
                    return $( "<li><b><u>ID:</u></b>"+item.vendorid+"&nbsp;&nbsp;&nbsp;<b><u>Company:</u></b> "+ item.company+"<br><b><u>City</u>:</b>" + item.city+"&nbsp;&nbsp;&nbsp;<b><u>State</u>:</b> " + item.state+"&nbsp;&nbsp;&nbsp;<b><u>Zip</u>:</b> " + item.zip+"&nbsp;&nbsp;&nbsp;<b><u>Balance:</u>:</b> "+ item.balance +"<hr></li>" )
                            .appendTo( ul );
                }
            });

            $('##CompanyName').each(function(i, tag) {
                $(tag).autocomplete({
                    multiple: false,
                    width: 400,
                    scroll: true,
                    scrollHeight: 300,
                    cacheLength: 1,
                    highlight: false,
                    dataType: "json",
                    autoFocus: true,
                    focus: function( event, ui ) {
                        $(this).val( ui.item.company );
                        return false;
                    },
                    source: 'searchLMAVendorsAutoFill.cfm?showCarriersWithBalance=1&queryType=getCustomersByName',
                    select: function(e, ui) {
                        $('##vendorIdAuto').val( ui.item.vendorid );
                        $('##vendorIDContainer').val( ui.item.vendorid );
                        $('##sortby').val( '' );
                        $('##sortorder').val( '' );
                        loadContent('Date');
                        return false;
                    }
                });
                $(tag).data("ui-autocomplete")._renderItem = function(ul, item) {
                    return $( "<li><b><u>ID:</u></b>"+item.vendorid+"&nbsp;&nbsp;&nbsp;<b><u>Company:</u></b> "+ item.company+"<br><b><u>City</u>:</b>" + item.city+"&nbsp;&nbsp;&nbsp;<b><u>State</u>:</b> " + item.state+"&nbsp;&nbsp;&nbsp;<b><u>Zip</u>:</b> " + item.zip+"&nbsp;&nbsp;&nbsp;<b><u>Balance:</u>:</b> "+ item.balance +"<hr></li>" )
                            .appendTo( ul );
                }
            });
            
            $('##Acct').change(function(){
                var AccountCode = $(this).val();
                var glacct = $(this).find(':selected').attr('data-glacct');
                if($.trim(AccountCode).length){
                    $.ajax({
                        type    : 'GET',
                        url     : "../gateways/loadgateway.cfc?method=generateCheckNumber",
                        data    : {dsn:"#application.dsn#",AccountCode:AccountCode,CompanyID:'#session.companyid#'},
                        success :function(ckNo){
                            $('##NextCheckNo').val(ckNo);
                            $('##glacct').val(glacct);
                        },
                    });
                }
            });
        })
        
        function loadContent(sortby){
            var vendorid = $('##vendorIDContainer').val();
            if($('##sortby').val()==sortby){
                if($('##sortorder').val()=='ASC'){
                    var sortorder = 'DESC';
                }
                else{
                    var sortorder = 'ASC';
                }
            }
            else{
                var sortorder = 'ASC';
            }
            $('##sortorder').val(sortorder);
            $('##sortby').val(sortby);
            $.ajax({
                type    : 'GET',
                url     : "../gateways/loadgateway.cfc?method=getLMAVendorInvoicesPIP",
                data    : {vendorid : vendorid, dsn:"#application.dsn#", sortby : sortby, sortorder:sortorder ,companyid : '#session.companyid#'},
                success :function(data){
                    $('##data-content').html(data);
                },
                beforeSend:function() {
                    $('##data-content ').html('<tr><td height="20" class="sky-bg">&nbsp;</td><td colspan="8" align="center" valign="middle" nowrap="nowrap" class="normal-td2"><img src="images/loadDelLoader.gif" style="margin-top: 25px;"><br>Please wait...</td><td class="normal-td3">&nbsp;</td></tr>');
                },
            });
        }

        function formatAppliedDollar(id){
            if(isNaN(parseFloat($('##applied_'+id).val().replace(/[$,]/g, '')))){
                $('##applied_'+id).val('$0.00');
            }
            var applied_amt = $('##applied_'+id).val();
            $('##applied_'+id).val(applied_amt);
            formatDollarNegative(applied_amt, 'applied_'+id);
            calculateTotals(id);
        }

        function formatDiscountDollar(id,action){
            if(isNaN(parseFloat($('##discount_'+id).val().replace(/[$,]/g, '')))){
                $('##discount_'+id).val('$0.00');
            }
            var discount = $('##discount_'+id).val();
            $('##discount_'+id).val(discount);
            formatDollarNegative(discount, 'discount_'+id);
            calculateDiscount(id,action);
        }

        function calculateTotals(id){
            var applied_amt = parseFloat($('##applied_'+id).val().replace(/[$,]/g, ''));
            var TotalApplied = 0;
            var discount = parseFloat($('##discount_'+id).val().replace(/[$,]/g, ''));;
            if(applied_amt == 0){
                var applied_amt = $('##Balance_'+id).val();
                $('##applied_'+id).val(applied_amt);
                formatDollarNegative(applied_amt, 'applied_'+id);
            }
            
            $(".applied").each(function(){
                var applied = parseFloat($(this).val().replace(/[$,]/g, ''));
                TotalApplied = TotalApplied + applied;
            })
            $('##TotalApplied').val(TotalApplied);
            formatDollarNegative(TotalApplied, 'TotalApplied');
            calculateBalance(id);
            //updateDBAjax(id)
        }

        function calculateDiscount(id,action){
            var discount = parseFloat($('##discount_'+id).val().replace(/[$,]/g, ''));
            var TotalDiscount = 0;
            if(discount == 0){
                var bal = $('##Balance_'+id).val();
                var applied = parseFloat($('##applied_'+id).val().replace(/[$,]/g, ''));
                var discount = bal - applied;
                $('##discount_'+id).val(discount);
                formatDollarNegative(discount, 'discount_'+id);
            }
            else{
                if(action == 'click'){
                    $('##discount_'+id).val(0);
                    formatDollarNegative(0, 'discount_'+id);
                }
            }
            $(".discount").each(function(){
                var discount = parseFloat($(this).val().replace(/[$,]/g, ''));
                TotalDiscount = TotalDiscount + discount;
            })
            $('##TotalDiscount').val(TotalDiscount);
            formatDollarNegative(TotalDiscount, 'TotalDiscount');
            calculateBalance(id);
            //updateDBAjax(id);
        }

        function calculateBalance(id){
            var balAfterChkTotal = 0;
            var balance = parseFloat($('##Balance_'+id).val().replace(/[$,]/g, ''));
            var applied_amt = parseFloat($('##applied_'+id).val().replace(/[$,]/g, ''));
            var discount = parseFloat($('##discount_'+id).val().replace(/[$,]/g, ''));
            var total_applied = applied_amt + discount;
            var balAfterCheck = balance - total_applied;
            $('##balAfterCheck_'+id).val(balAfterCheck);
            formatDollarNegative(balAfterCheck, 'balAfterCheck_'+id);

            $(".balAfterChk").each(function(){
                var balAfterChk = parseFloat($(this).val().replace(/[$,]/g, ''));
                balAfterChkTotal = balAfterChkTotal + balAfterChk;
            })
            $('##balAfterChkTotal').val(balAfterChkTotal);
            formatDollarNegative(balAfterChkTotal, 'balAfterChkTotal');
        }

        function updateDBAjax(id){
            var applied_amt = parseFloat($('##applied_'+id).val().replace(/[$,]/g, ''));
            var discount = parseFloat($('##discount_'+id).val().replace(/[$,]/g, ''));
            $.ajax({
                type    : 'POST',
                url     : "../gateways/loadgateway.cfc?method=updateAccountsPayableTransactions",
                data    : {dsn:"#application.dsn#", idcount : id, applied:applied_amt, discount:discount},
                success :function(data){

                },
                beforeSend:function() {

                },
            });
        }

        function validatePayment(){
          
            if(!$('##vendorIdAuto').val().length){
                return false;
            }
            if(!$('##Acct').val().length){
                alert('Please select an account.');
                $('##Acct').focus()
                return false;
            }
            if(!$('input[name="Description"]').length){
                return false;
            }
            if(confirm('Are you sure you want to save this information?')){
                return true;
            }
        }
    </script>
    <div class="white-con-area" style="height: 36px;background-color: ##82bbef;width:75%;">
        <div style="float: left;">
            <h2 style="color:white;font-weight:bold;margin-left: 12px;">Post Invoice Payment</h2>
        </div>
    </div>
    <div style="clear:left"></div>
    <cfform id="ApplyPaymentForm" name="ApplyPaymentForm" action="index.cfm?event=PostInvoicePayment&#session.URLToken#" method="post" preserveData="yes" onsubmit="return validatePayment();">
        <cfinput id="sortorder" name="sortOrder" value="" type="hidden">
        <cfinput id="sortby" name="sortby" value="" type="hidden">
        <cfinput id="glacct" name="glacct" value="" type="hidden">
        <div class="search-panel" style="width:100%;">
            <div class="form-search" style="width:75%;background-color: #request.qGetSystemSetupOptions.BackgroundColorForContentAccounting# !important;padding-bottom: 10px;">
                <fieldset style="width:100%;padding:5px;float:left;">
                    <div style="float:left">
                        <label style="font-weight: bold;width:86px;">Vendor Code:</label>
                        <input class="sm-input" id="vendorIdAuto" name="vendorIdAuto" value="" type="text" style="width:119px !important;" placeholder ="Type here for lookup." tabindex="1" />
                        <input type="hidden" value="" id="vendorIDContainer" name="vendorIDContainer">
                    </div>
                    <div style="float:left">
                        <label style="font-weight: bold;width:60px;">Company:</label>
                        <input class="sm-input" placeholder ="Type here for lookup." id="CompanyName" name="CompanyName" value="" type="text" style="width:200px !important;" />
                    </div>
                    <div style="float:left">
                        <label style="font-weight: bold;width:60px;">Account:</label>
                        <select id="Acct" name="Acct" style="width:126px !important;height: 22px;">
                            <option></option>
                            <cfloop query ="qCheckRegisterSetup">
                                <option data-glacct="#qCheckRegisterSetup.GLAcct#" value="#qCheckRegisterSetup.AccountCode#">#qCheckRegisterSetup.AccountCode# #qCheckRegisterSetup.AccountName#</option>
                            </cfloop>
                        </select>
                    </div>
                    <div class="clear"></div>
                    <div style="float:left">
                        <label style="width:100px;">Pay Reference##:</label>
                        <input tabindex="5" class="sm-input" id="NextCheckNo" name="NextCheckNo" type="text" style="width:105px !important;" maxlength="100">
                    </div>
                    <div style="float:left">
                        <label style="width:60px;">Date:</label>
                        <input tabindex="6" class="sm-input datefield hasDatepicker" id="invoiceDate" name="invoiceDate" onchange="checkDateFormatAll(this);" value="01/04/2021" type="text" style="width:83px !important;"><img class="ui-datepicker-trigger" src="images/DateChooser.png" alt="..." title="...">
                    </div>
                    <div style="float:left">
                        <label style="width:77px;margin-left: 20px;">Pay Type:</label>
                        <select name="PayType" style="width:100px !important;height: 22px;" tabindex="6">
                            <option value="ACH">ACH</option>
                            <option value="Cash">Cash</option>
                            <option value="Check">Check</option>
                            <option value="Credit Card">Credit Card</option>
                            <option value="Other">Other</option>
                        </select>
                    </div>
                </fieldset>
            </div>
        </div>
        <div class="clear"></div>
        <cfif structKeyExists(session, "PaymentMsg")>
            <div id="message" class="msg-area-#session.PaymentMsg.res#">#session.PaymentMsg.msg#</div>
            <cfset structDelete(session, "PaymentMsg")>
        </cfif>
        <div style="clear:left"></div>

        <table width="75%" border="0" class="data-table" cellspacing="0" cellpadding="0" style="color:##000000;">
            <thead>
                <tr>
                    <th align="center" valign="middle" class="head-bg left-th-border" onclick="loadContent('Date')">Date</th>
                    <th align="center" valign="middle" class="head-bg" onclick="loadContent('trans_number')">Reference</th>
                    <th align="center" valign="middle" class="head-bg">Amount</th>
                    <th align="center" valign="middle" class="head-bg">Balance</th>
                    <th align="center" valign="middle" class="head-bg">Description</th>
                    <th align="center" valign="middle" class="head-bg" width="75">Amt Applied</th>
                     <th align="center" valign="middle" class="head-bg" width="65">Discount</th>
                    <th align="center" valign="middle" class="head-bg2 right-th-border" width="85">Bal. After Check</th>
                </tr>
            </thead>
            <tbody id="data-content">
                <tr>
                    <td align="center" colspan="8" class="normal-td left-td-border">No Records Found.</td>
                </tr>
            </tbody>
            <tfoot>
                <tr>
                    <td colspan="8" align="left" valign="middle" class="footer-bg">
                    </td>
                </tr> 
            </tfoot>   
        </table>
        <fieldset style="width:74%;padding:5px;float:left;background-color: #request.qGetSystemSetupOptions.BackgroundColorForContentAccounting# !important;">
            <div style="float:right;">
                <button class="btn" name="PostCheck" style="height: 30px;background-size: contain;"><b>Post Check</b></button>
            </div>
        </fieldset>
    </cfform>  
</cfoutput>

    