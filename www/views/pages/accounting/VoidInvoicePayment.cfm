<cfoutput>
    <cfinvoke component="#variables.objloadGateway#" method="getSystemSetupOptions" returnvariable="request.qGetSystemSetupOptions" />
    <cfif structKeyExists(form, "Process")>
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
            <cfinvoke frmStruct="#form#" component="#variables.objLoadGateway#" method="VoidInvoicePayment" returnvariable="resp"/>
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

            $('##Acct').change(function(){
                var AccountCode = $(this).val();
                var glacct = $(this).find(':selected').attr('data-glacct');
                $('##CheckNumber').empty().append('<option value=""></option>');
                if($.trim(AccountCode).length){
                    $.ajax({
                        type    : 'GET',
                        url     : "../gateways/loadgateway.cfc?method=getChecksForAccount",
                        data    : {dsn:"#application.dsn#",AccountCode:AccountCode,CompanyID:'#session.companyid#'},
                        success :function(res){
                            var obj = JSON.parse(res);
                            $.each( obj, function( key, check ) {;
                                $('##CheckNumber').append('<option data-Payee="'+check.Payee+'" data-Amount="'+check.Amount+'" data-CheckDate="'+check.CheckDate+'" value="'+check.CheckNumber+'">'+check.CheckNumber+'&nbsp;&nbsp;'+check.Payee+'</option>');
                                
                            });
                            $('##glacct').val(glacct);
                        },
                    });
                }
            });

            $('##CheckNumber').change(function(){
                var Payee = $(this).find(':selected').attr('data-Payee');
                var Amount = $(this).find(':selected').attr('data-Amount');
                var CheckDate = $(this).find(':selected').attr('data-CheckDate');
                $('##Payee').val(Payee);
                $('##Amount').val(Amount);
                $('##CheckDate').val(CheckDate);
            });
        })
        

        function validateVoid(){

            if(!$('##Acct').val().length){
                alert('Please select an account.');
                $('##Acct').focus()
                return false;
            }
            if(!$('##CheckNumber').val().length){
                alert('Please select Check Number.');
                $('##CheckNumber').focus()
                return false;
            }
            if(confirm('Are you sure you want to process?')){
                return true;
            }
        }
    </script>
    <div class="white-con-area" style="height: 36px;background-color: ##82bbef;width:75%;">
        <div style="float: left;">
            <h2 style="color:white;font-weight:bold;margin-left: 12px;">Void Invoice Payment</h2>
        </div>
    </div>
    <div style="clear:left"></div>
    <cfform id="VoidPaymentForm" name="VoidPaymentForm" action="index.cfm?event=VoidInvoicePayment&#session.URLToken#" method="post" preserveData="yes" onsubmit="return validateVoid();">
        <cfinput id="glacct" name="glacct" value="" type="hidden">
        <div class="search-panel" style="width:100%;">
            <div class="form-search" style="width:75%;background-color: #request.qGetSystemSetupOptions.BackgroundColorForContentAccounting# !important;padding-bottom: 10px;">
                <fieldset style="width:100%;padding:5px;float:left;">
                    <div style="float:left">
                        <label style="font-weight: bold;width:90px;">Bank Account:</label>
                        <select id="Acct" name="Acct" style="width:212px !important;height: 22px;" tabindex="1">
                            <option></option>
                            <cfloop query ="qCheckRegisterSetup">
                                <option data-glacct="#qCheckRegisterSetup.GLAcct#" value="#qCheckRegisterSetup.AccountCode#">#qCheckRegisterSetup.AccountCode# #qCheckRegisterSetup.AccountName#</option>
                            </cfloop>
                        </select>
                    </div>
                     <div style="float:left">
                        <label style="width:60px;">Date:</label>
                        <input tabindex="2" class="sm-input datefield hasDatepicker" id="invoiceDate" name="invoiceDate" onchange="checkDateFormatAll(this);" value="01/04/2021" type="text" style="width:83px !important;"><img class="ui-datepicker-trigger" src="images/DateChooser.png" alt="..." title="...">
                    </div>
                    <div class="clear"></div>
                    <div style="float:left">
                        <label style="font-weight: bold;width:90px;">Check Number:</label>
                        <select  tabindex="3" id="CheckNumber" name="CheckNumber" style="width:60px !important;height: 22px;">
                            <option></option>
                        </select>
                    </div>
                    <div style="float:left">
                        <label style="font-weight: bold;width:76px;">Check Date:</label>
                        <input class="sm-input disabledLoadInputs" readonly id="CheckDate" name="CheckDate" value="" type="text" tabindex="100" style="width:60px !important;" />
                    </div>
                    <div style="float:left">
                        <label style="font-weight: bold;width:50px;">Payee:</label>
                        <input class="sm-input disabledLoadInputs" readonly id="Payee" name="Payee" value="" type="text" tabindex="101" style="width:185px !important;" />
                    </div>
                    <div style="float:left">
                        <label style="font-weight: bold;width:50px;">Amount:</label>
                        <input tabindex="102" class="sm-input disabledLoadInputs" readonly id="Amount" name="Amount" value="" type="text" style="width:85px !important;" />
                    </div>
                </fieldset>
            </div>
        </div>
        <div class="clear"></div>
        <cfif structKeyExists(session, "PaymentMsg")>
            <div id="message" class="msg-area-#session.PaymentMsg.res#">#session.PaymentMsg.msg#</div>
            <cfset structDelete(session, "PaymentMsg")>
        </cfif>
        
        <fieldset style="width:74%;padding:5px;float:left;background-color: #request.qGetSystemSetupOptions.BackgroundColorForContentAccounting# !important;">
            <div style="float:right;margin-right: 5%;">
                <button tabindex="4" class="btn" name="Process" style="height: 30px;background-size: contain;"><b>Process</b></button>
            </div>
        </fieldset>
    </cfform>  
</cfoutput>

    