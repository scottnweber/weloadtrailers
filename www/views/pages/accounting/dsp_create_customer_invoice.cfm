<cfoutput>

    <cfinvoke component="#variables.objloadGateway#" method="getSystemSetupOptions" returnvariable="request.qGetSystemSetupOptions" />
    <cfif structKeyExists(form, "CreateInvoice")>
        <cfinvoke component="#variables.objLoadGateway#" method="getLMASystemConfig" returnvariable="qLMASystemConfig" />
        <cfinvoke component="#variables.objLoadGateway#"  method="check_fiscal" Trans_Date="#form.invoiceDate#" returnvariable="resCkFiscal" />
        <cfset ARGLAccount = qLMASystemConfig['AR GL Account']>
        <cfset session.InvoiceMsg = structNew()>
        <cfif NOT len(trim(ARGLAccount))>
            <cfset session.InvoiceMsg.res = 'error'>
            <cfset session.InvoiceMsg.msg = "No account number has been setup for this transaction. Please correct this and try again.">
        <cfelseif resCkFiscal.res eq 'error'>
            <cfset session.InvoiceMsg = resCkFiscal>
        <cfelse>
            <cfset form.ARGLAccount = qLMASystemConfig['AR GL Account']>
            <cfset form.year_past = resCkFiscal.year_past>
            <cfinvoke frmStruct="#form#" component="#variables.objLoadGateway#" method="LMACreateCustomerInvoice" returnvariable="resp"/>
            <cfset session.InvoiceMsg = resp>
            <cfif session.InvoiceMsg.res EQ 'success'>
                <cflocation url="index.cfm?event=CreateCustomerInvoice&#session.URLToken#">
            </cfif>
        </cfif>
        
    </cfif>
    <cfinvoke component="#variables.objLoadGateway#" method="getAcctDeptList" returnvariable="qAcctDeptList" />
    <cfinvoke component="#variables.objLoadGateway#" method="getLMASystemTerms" returnvariable="qSystemTerms" />
    <cfset AuthLevel = "Sales Representative,Manager,Dispatcher,Administrator,Central Dispatcher">
    <cfinvoke component="#variables.objloadGateway#" AuthLevel="#AuthLevel#" method="getloadSalesPerson" returnvariable="qSalesPerson" />
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
        .smallPlaceHolder::-webkit-input-placeholder { /* Chrome/Opera/Safari */
            font-size: 9px;
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

            $('##cutomerIdAuto').focus();
            $('##cutomerIdAuto').each(function(i, tag) {
                $(tag).autocomplete({
                    multiple: false,
                    width: 400,
                    scroll: true,
                    scrollHeight: 300,
                    cacheLength: 1,
                    highlight: false,
                    dataType: "json",
                    autoFocus: true,
                    source: 'searchLMACustomersAutoFill.cfm',
                    select: function(e, ui) {
                        $(this).val( ui.item.customercode );
                        $('##CompanyName').val( ui.item.name );
                        $('##customerIDContainer').val( ui.item.customerid );
                        $('##customercode').val( ui.item.customercode );
                        generateInvoice();
                        return false;
                    }
                });
                $(tag).data("ui-autocomplete")._renderItem = function(ul, item) {
                    return $( "<li><b><u>Customer Code:</u></b>"+item.customercode+"&nbsp;&nbsp;&nbsp;<b><u>Company:</u></b> "+ item.name+"<br><b><u>City</u>:</b>" + item.city+"&nbsp;&nbsp;&nbsp;<b><u>State</u>:</b> " + item.state+"&nbsp;&nbsp;&nbsp;<b><u>Invoices</u>:</b> " + item.invoices+"<hr></li>" )
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
                    source: 'searchLMACustomersAutoFill.cfm?&companyid=#session.companyid#&queryType=getCustomersByName',
                    select: function(e, ui) {
                        $(this).val( ui.item.name );
                        $('##cutomerIdAuto').val( ui.item.customercode );
                        $('##customerIDContainer').val( ui.item.customerid );
                        $('##customercode').val( ui.item.customercode );
                        generateInvoice();
                        return false;
                    }
                });
                $(tag).data("ui-autocomplete")._renderItem = function(ul, item) {
                    return $( "<li><b><u>Customer Code:</u></b>"+item.customercode+"&nbsp;&nbsp;&nbsp;<b><u>Company:</u></b> "+ item.name+"<br><b><u>City</u>:</b>" + item.city+"&nbsp;&nbsp;&nbsp;<b><u>State</u>:</b> " + item.state+"&nbsp;&nbsp;&nbsp;<b><u>Invoices</u>:</b> " + item.balance+"<hr></li>" )
                            .appendTo( ul );
                }
            });
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

            $('.LMAAutoComplete').each(function(i, tag) {
                var indx = $(this).attr('id').split('_')[1];
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
                            if (v.value == val) {
                                keyFound = 1;
                                $('##description_'+indx).val(v.description);
                                if($('##type').val() == 'C'){
                                    $('##creditdebit_'+indx).val('D');
                                }
                                else{
                                    $('##creditdebit_'+indx).val(v.creditdebit);
                                }
                                
                                $('##amount_'+indx).val('$0.00');
                                allocateAmount(indx);
                                return false;
                            }
                        });
                        if(keyFound==0){
                            alert('Invalid account number. Please correct and try again');
                            $(this).val('');
                            $(this).focus();
                            $(this).val('');
                        }
                    },
                    select: function(e, ui) {
                        $('##description_'+indx).val(ui.item.description);
                        if($('##type').val() == 'C'){
                            $('##creditdebit_'+indx).val('D');
                        }
                        else{
                            $('##creditdebit_'+indx).val(ui.item.creditdebit);
                        }
                        $('##amount_'+indx).val('$0.00');
                        allocateAmount(indx);
                        return false;
                    }  
                });
            });
            var sourceJsonDesc = [
            <cfloop query="qAcctDeptList">
                <cfif not listFind(".,/", qAcctDeptList.GL_ACCT)>
                    {label: "#qAcctDeptList.description# #qAcctDeptList.GL_ACCT# ", value: "#qAcctDeptList.description#", glacct:"#qAcctDeptList.GL_ACCT#",creditdebit:"#qAcctDeptList.credit_debit#"},
                </cfif>
            </cfloop>
            ]
            $('.LMAAutoCompleteDesc').each(function(i, tag) {
                var indx = $(this).attr('id').split('_')[1];
                $(tag).autocomplete({
                    multiple: false,
                    width: 400,
                    scroll: true,
                    scrollHeight: 300,
                    cacheLength: 1,
                    highlight: false,
                    dataType: "json",
                    source: sourceJsonDesc,
                    focus: function( event, ui ) {
                        $(this).val( ui.item.value );
                    },
                    change: function(event,ui){
                        var val = $(this).val();
                        var keyFound = 0;
                        $.each(sourceJsonDesc, function(i, v) {
                            if (v.value == val) {
                                keyFound = 1;
                                $('##glacct_'+indx).val(v.glacct);
                                if($('##type').val() == 'C'){
                                    $('##creditdebit_'+indx).val('D');
                                }
                                else{
                                    $('##creditdebit_'+indx).val(v.creditdebit);
                                }
                                
                                $('##amount_'+indx).val('$0.00');
                                allocateAmount(indx);
                                return false;
                            }
                        });
                        if(keyFound==0){
                            alert('Invalid account. Please correct and try again');
                            $(this).val('');
                            $(this).focus();
                            $(this).val('');
                        }
                    },
                    select: function(e, ui) {
                        $('##glacct_'+indx).val(ui.item.glacct);
                        if($('##type').val() == 'C'){
                            $('##creditdebit_'+indx).val('D');
                        }
                        else{
                            $('##creditdebit_'+indx).val(ui.item.creditdebit);
                        }
                        $('##amount_'+indx).val('$0.00');
                        allocateAmount(indx);
                        return false;
                    }  
                });
            });
        })
        function generateInvoice(){
            $.ajax({
                type    : 'GET',
                url     : "../gateways/loadgateway.cfc?method=generateLMAInvoiceNumber",
                data    : {dsn:"#application.dsn#",companyid:'#session.companyid#'},
                success :function(invNo){
                    $('##invoice').val(invNo)
                },
            });
        }

        function allocateAmount(row){
            var totalAmount = parseFloat($('##totalAmount').val().replace(/[$,]/g, ''));
            if(isNaN(totalAmount)){
                totalAmount = 0;
                $('##totalAmount').val('$0.00');
            }
            if(row!=0 && isNaN(parseFloat($('##amount_'+row).val().replace(/[$,]/g, '')))){
                $('##amount_'+row).val('$0.00');
            }
            if(row==0){
                var amount =  parseFloat($('##amount_1').val().replace(/[$,]/g, ''));
                if($('##glacct_1').val().length && amount == 0){
                    $('##amount_1').val(totalAmount);
                    formatDollarNegative(totalAmount, 'amount_1');
                }
                formatDollarNegative(totalAmount, 'totalAmount');
            }
            else{
                if(totalAmount>0){
                    if($('##glacct_'+row).val().length)
                    {
                        var amount =  parseFloat($('##amount_'+row).val().replace(/[$,]/g, ''));
                        if(amount==0){
                            $(".amount").each(function(){
                                var index = $(this).attr('id').split('_')[1];
                                var glAcct = $('##glacct_'+index).val();
                                var amtVal = $('##amount_'+index).val();
                                var amt = amtVal.replace(/[$,]/g, '');
                                if(index!=row && glAcct.length && amtVal.length){
                                    totalAmount = totalAmount - amt;
                                }
                            });
                            if(totalAmount != 0){
                                $('##amount_'+row).val(totalAmount);
                                var cd = $.trim($('##creditdebit_'+row).val());
                                if(!cd.length){
                                    if(totalAmount<0){
                                        $('##creditdebit_'+row).val('C');
                                    }
                                    else{
                                        $('##creditdebit_'+row).val('D');
                                    }
                                    
                                }
                            }
                        }
                    }
                }
                if($('##amount_'+row).val().length){
                    formatDollarNegative($('##amount_'+row).val(), 'amount_'+row);
                }
            }      
            
        }
        function validateInvoice(){
            var totalAmount = parseFloat($('##totalAmount').val().replace(/[$,]/g, ''));
            var allocatedAmount = 0;
            var err = 0;
            $(".amount").each(function(){
                var index = $(this).attr('id').split('_')[1];
                var glAcct = $('##glacct_'+index).val();
                var amtVal = $('##amount_'+index).val();
                var creditdebit = $('##creditdebit_'+index).val();
                var amt = amtVal.replace(/[$,]/g, '');
                if(glAcct.length && amtVal.length){
                    if(!$.trim(creditdebit).length){
                        alert('Please enter D/C.');
                        $('##creditdebit_'+index).focus();
                        err = 1; 
                    }
                    allocatedAmount = parseFloat(allocatedAmount) + parseFloat(amt);
                }
            });
            
            var custID = $('##customerIDContainer').val();
            if(!$.trim(custID).length){
                alert('Invalid Customer.');
                err = 1; 
            }

            if(err==0){
                if(confirm('Are you sure you want to create this invoice?')){
                    return true;
                }
            }
            
            return false;
        }
    </script>
    <div class="white-con-area" style="height: 36px;background-color: ##82bbef;width:75%;">
        <div style="float: left;">
            <h2 style="color:white;font-weight:bold;margin-left: 12px;">Create Customer Invoice</h2>
        </div>
    </div>
    <div style="clear:left"></div>
    <cfform id="CreateCustomerInvoiceForm" name="CreateCustomerInvoiceForm" action="index.cfm?event=CreateCustomerInvoice&#session.URLToken#" method="post" preserveData="yes" onsubmit="return validateInvoice();">
        <div class="search-panel" style="width:75%;">
            <div class="form-search" style="width:100%;background-color: #request.qGetSystemSetupOptions.BackgroundColorForContentAccounting# !important;padding-bottom: 10px;">
                <fieldset style="width:98%;padding:5px;float:left;">
                    <div style="float:left">
                        <label style="font-weight: bold;width:75px;margin-left: 20px;">Customer:</label>
                        <input class="sm-input" id="cutomerIdAuto" name="cutomerIdAuto"  type="text" style="width:150px !important;" placeholder ="Type here for lookup." tabindex="1" <cfif isDefined('form.cutomerIdAuto')>value="#form.cutomerIdAuto#"</cfif> />
                        <input type="hidden" id="customerIDContainer" name="customerID" <cfif isDefined('form.customerID')>value="#form.customerID#"</cfif>>
                        <input type="hidden"  id="customercode" name="customercode" <cfif isDefined('form.customercode')>value="#form.customercode#"</cfif>>
                    </div>
                    <div style="float:left">
                        <input placeholder ="Type here for lookup." class="sm-input" id="CompanyName" name="CompanyName" type="text" style="width:250px !important;"  <cfif isDefined('form.CompanyName')>value="#form.CompanyName#"</cfif>/>
                    </div>
                    <div style="float:left">
                        <label style="width:80px;">Terms:</label>
                        <select style="width:100px !important;" tabindex="2" name="term_number">
                            <option value="0"></option>
                            <cfloop query="qSystemTerms">
                                <option value="#qSystemTerms.ID#" <cfif isDefined('form.term_number') AND form.term_number EQ qSystemTerms.ID> selected </cfif> >#qSystemTerms.Description#</option>
                            </cfloop>
                        </select>
                    </div>
                    <div class="clear"></div>
                    <div style="float:left">
                        <label style="width:77px;margin-left: 20px;">Invoice:</label>
                        <input tabindex="3"  class="sm-input" id="invoice" name="invoice"  <cfif isDefined('form.invoice')>value="#form.invoice#"</cfif> type="text" style="width:100px !important;" onkeyup="if (/\D/g.test(this.value)) this.value = this.value.replace(/\D/g,'')" />
                    </div>
                    <div style="float:left">
                        <label style="width:123px;">Type:</label>
                        <select style="width:172px !important;" tabindex="4" name="type" id="type">
                            <option value="I" <cfif isDefined('form.type') AND form.type EQ "I"> selected </cfif>>Invoice</option>
                            <option value="P" <cfif isDefined('form.type') AND form.type EQ "P"> selected </cfif>>Pre-Payment</option>
                            <option value="C" <cfif isDefined('form.type') AND form.type EQ "C"> selected </cfif>>Credit-Invoice</option>
                        </select>
                    </div>
                    <div style="float:left">
                        <label style="width:87px;">Dept:</label>
                        <input tabindex="5" maxlength="4" class="sm-input" id="dept" name="dept" type="text" style="width:55px !important;" <cfif isDefined('form.dept')>value="#form.dept#"</cfif>/>
                    </div>
                    <div class="clear"></div>
                    <div style="float:left">
                        <label style="width:77px;margin-left: 20px;">Date:</label>
                        <input tabindex="6"  class="sm-input datefield" id="invoiceDate" name="invoiceDate"  onchange="checkDateFormatAll(this);" <cfif isDefined('form.invoiceDate')>value="#form.invoiceDate#"<cfelse>value="#DateFormat(now(),'mm/dd/yyyy')#"</cfif> type="text" style="width:83px !important;"/>
                    </div>
                    <div style="float:left">
                        <label style="width:127px;">Total Amount:</label>
                        <input tabindex="7"  class="sm-input" id="totalAmount" name="totalAmount" <cfif isDefined('form.totalAmount')>value="#form.totalAmount#"<cfelse>value="$0.00"</cfif> type="text" style="width:100px !important;" onchange="allocateAmount(0)"/>
                    </div>
                    <div class="clear"></div>
                    <div style="float:left">
                        <label style="width:77px;margin-left: 20px;">Notes:</label>
                        <textarea name="notes" style="width:417px;padding-left:  2px;font-family: Arial, Helvetica, sans-serif;font-size: 11px;" rows="3" tabindex="8"><cfif isDefined('form.notes')>#form.notes#</cfif></textarea>
                    </div>
                    <div style="float:left">
                        <label style="width:90px;">Sales Person:</label>
                        <select style="width:100px !important;" tabindex="9" name="salesperson">
                            <option value="">Select</option>
                            <cfloop query="qSalesPerson">
                                <option value="#qSalesPerson.Name#" <cfif isDefined('form.salesperson') AND form.salesperson EQ qSalesPerson.Name> selected </cfif>>#qSalesPerson.Name#</option>
                            </cfloop>
                        </select><br>
                        <select style="width:100px !important;margin-left: 100px;margin-top: 8px;" tabindex="10" name="dispatcher">
                            <option value="">Select</option>
                            <cfloop query="qSalesPerson">
                                <option value="#qSalesPerson.Name#" <cfif isDefined('form.dispatcher') AND form.dispatcher EQ qSalesPerson.Name> selected </cfif>>#qSalesPerson.Name#</option>
                            </cfloop>
                        </select>
                    </div>
                </fieldset>
            </div>
        </div>
        <div class="clear"></div>
        <cfif structKeyExists(session, "InvoiceMsg")>
            <div id="message" class="msg-area-#session.InvoiceMsg.res#">#session.InvoiceMsg.msg#</div>
            <cfset structDelete(session, "InvoiceMsg")>
        </cfif>
        <div style="clear:left"></div>
    	<cfset pageSize = 30>
        <cfif isdefined("form.pageNo")>
            <cfset rowNum = ((form.pageNo-1)*pageSize)>
        <cfelse>
            <cfset rowNum = 0>
        </cfif>

        <table width="75%" border="0" class="data-table" cellspacing="0" cellpadding="0" style="color:##000000;">
            <thead>
                <tr>
                    <th width="30" align="center" valign="middle" class="head-bg left-th-border">Account</th>
                    <th width="350" align="center" valign="middle" class="head-bg">Description</th>
                    <th width="50" align="center" valign="middle" class="head-bg">D/C</th>
                    <th width="50" align="center" valign="middle" class="head-bg2 right-th-border">Amount</th>
                </tr>
            </thead>

            <tbody id="data-content">
                 <cfloop from="1" to="10" step="1" index="i">
                    <tr>
                        <td align="center" valign="middle" nowrap="nowrap" class="normal-td left-td-border" style="padding: 0;"><input <cfif i eq 1>placeholder="Type for lookup."</cfif> style="width:97%" class="LMAAutoComplete smallPlaceHolder" id="glacct_#i#" name="glacct_#i#" <cfif isDefined('form.glacct_#i#')>value="#Evaluate('form.glacct_#i#')#"</cfif>></td>
                        <td align="left" valign="middle" nowrap="nowrap" class="normal-td" style="padding: 0;"><input class="LMAAutoCompleteDesc smallPlaceHolder" <cfif i eq 1>placeholder="Type here for lookup."</cfif> style="width:99%" id="description_#i#" name="description_#i#"  <cfif isDefined('form.description_#i#')>value="#Evaluate('form.description_#i#')#"</cfif>>></td>
                        <td align="left" valign="middle" nowrap="nowrap" class="normal-td" style="padding: 0;"><input style="width:97%" maxlength="1" id="creditdebit_#i#" name="creditdebit_#i#" <cfif isDefined('form.creditdebit_#i#')>value="#Evaluate('form.creditdebit_#i#')#"</cfif>></td>
                        <td align="left" valign="middle" nowrap="nowrap" class="normal-td" style="padding: 0;"><input style="width:97%" class="amount" id="amount_#i#" name="amount_#i#" onclick="allocateAmount(#i#)" onchange="allocateAmount(#i#)" <cfif isDefined('form.amount_#i#')>value="#Evaluate('form.amount_#i#')#"</cfif>></td>
                    </tr> 
                </cfloop>
            </tbody>
            <tfoot>
                <tr>
                    <td colspan="4" align="left" valign="middle" class="footer-bg">
                    </td>
                </tr> 
            </tfoot>   
        </table>
        <fieldset style="width:74%;padding:5px;float:left;background-color: #request.qGetSystemSetupOptions.BackgroundColorForContentAccounting# !important;">
            <div style="float:right;">
                <button class="btn" name="CreateInvoice" style="height: 30px;background-size: contain;"><b>Create Invoice</b></button>
            </div>
        </fieldset>
    </cfform>  
</cfoutput>

    