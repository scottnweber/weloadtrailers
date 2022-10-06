<cfoutput>
    <cfif structKeyExists(form, "Process")>
        <cfinvoke component="#variables.objLoadGateway#" method="getLMASystemConfig" returnvariable="qLMASystemConfig" />
        <cfset FiscalYear = qLMASystemConfig['Fiscal Year']>
        <cfset form.ARGLAccount = qLMASystemConfig['AR GL Account']>
        <cfset form.year_past = DateDiff("yyyy",FiscalYear , now())>
        <cfinvoke frmStruct="#form#" component="#variables.objLoadGateway#" method="LMAVendorPayment" returnvariable="resp"/>
        <cfset session.PaymentMsg = resp>
        <cflocation url="index.cfm?event=InvoiceToPay&#session.URLToken#">
    </cfif>
    <cfinvoke component="#variables.objLoadGateway#" method="getCheckRegisterSetup" returnvariable="qCheckRegisterSetup" />
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
                if($.trim(AccountCode).length){
                    $.ajax({
                        type    : 'GET',
                        url     : "../gateways/loadgateway.cfc?method=generateCheckNumber",
                        data    : {dsn:"#application.dsn#",AccountCode:AccountCode,CompanyID:'#session.companyid#'},
                        success :function(ckNo){
                            $('##NextCheckNo').val(ckNo)
                        },
                    });
                }
            });

            $('##print').click(function(){
                var account = $.trim($('##Acct').val());
                var checkNumber = $.trim($('##NextCheckNo').val());
                if(!account.length){
                    alert('Please select an account.');
                    $('##Acct').focus();
                }
                else{
                    $.ajax({
                        type    : 'GET',
                        url     : "../gateways/loadgateway.cfc?method=printChecks",
                        data    : {dsn:"#application.dsn#",account:account,checkNumber:checkNumber,CompanyID:'#session.companyid#'},
                        success :function(ckNo){
                            $('##print').prop('disabled', true);
                            $('##close').show();
                            $('##cancel').hide();
                            window.open('../reports/LMAPrintChecks.cfm?Account='+account+'&checkNumber='+checkNumber);
                        },
                    });
                }
            })

            $('##close').click(function(){
                if(confirm('Did the checks print properly?')){
                    var account = $.trim($('##Acct').val());
                    var checkNumber = $.trim($('##NextCheckNo').val());
                    $.ajax({
                        type    : 'POST',
                        url     : "../gateways/loadgateway.cfc?method=closeChecks",
                        data    : {dsn:"#application.dsn#",account:account,checkNumber:checkNumber,CompanyID:'#session.companyid#'},
                        success :function(resp){
                            alert('Posting checks to accounting is complete.');
                            location.reload();
                        },
                    });
                }
            })

        });

    </script>
    <div class="white-con-area" style="height: 36px;background-color: ##82bbef;width:85%;">
        <div style="float: left;">
            <h2 style="color:white;font-weight:bold;margin-left: 12px;">Print Checks</h2>
        </div>
    </div>
    <div style="clear:left"></div>
    <div class="white-con-area" style="width:85%;">
        <div class="white-top"></div>
        <div class="white-mid" style="background-color: #request.qGetSystemSetupOptions.BackgroundColorForContentAccounting# !important;width: 100%;">
            <cfform name="frmPrintChecks" id="frmPrintChecks" action="index.cfm?event=PrintChecks&#session.URLToken#" method="post">
                <div class="form-con" style="margin-top: 5px;margin-bottom: 5px;">
                    <fieldset style="padding-bottom: 10px;">
                        <label class="space_it" style="width: 145px;">Check Account:</label>
                        <div style="position:relative;float:left;">
                            <div style="float:left;">          
                                <select id="Acct" name="Acct">
                                    <option value="">Select Account</option>
                                    <cfloop query ="qCheckRegisterSetup">
                                        <option value="#qCheckRegisterSetup.AccountCode#">#qCheckRegisterSetup.AccountCode# #qCheckRegisterSetup.AccountName#</option>
                                    </cfloop>
                                </select>
                            </div>
                        </div>
                        <div class="clear"></div> 
                        <label class="space_it" style="width: 145px;">Check Type:</label>
                        <div style="position:relative;float:left;">
                            <div style="float:left;">
                                <select id="CheckType" name="CheckType">
                                    <option value="">Laser Check - Center</option>
                                </select>
                            </div>
                        </div>
                        <div class="clear"></div> 
                        <label class="space_it" style="width: 145px;">Next Check Number:</label>
                        <div style="position:relative;float:left;">
                            <div style="float:left;">
                                <input class="sm-input" tabindex=4 name="NextCheckNo" id="NextCheckNo"  value="" style="width: 120px !important;" readonly />
                            </div>
                        </div>
                        <div class="clear"></div> 
                        <div style="margin-left: 155px;margin-top: 10px;">
                            <input id="close" type="button" name="close" class="bttn tooltip" value="Close" style="width:95px;display: none;"/>
                            <input id="print" type="button" name="print" class="bttn tooltip" value="Print" style="width:95px;"/>
                            <input id="cancel" type="button" name="cancel" class="bttn tooltip" value="Cancel" style="width:95px;"/>
                        </div>
                    </fieldset>
                </div>
                <div class="form-con" style="width:400px;margin-top: 5px;margin-bottom: 5px;">
                    <fieldset style="padding-bottom: 10px;text-align: center;">
                        <label class="space_it">Date:</label>
                        <div style="position:relative;float:left;">
                            <div style="float:left;">
                                <input class="sm-input datefield" tabindex=4 name="Date" id="Date"  value="#dateformat(Now(),'mm/dd/yyy')#" validate="date" type="datefield" />
                            </div>
                        </div>
                        <div class="clear"></div> 
                        <label class="space_it">Print Where?</label>
                        <div style="position:relative;float:left;">
                            <div style="float:left;width:75px;">
                                <input type="radio" name="PrintWhere" value="0" style="width:12px;" checked><span style="margin-left: -17px;">Screen</span><br>
                                <input type="radio" name="PrintWhere" value="1" style="width:12px;position: relative;right: 20px;"><span style="position:relative;right:20px;">Printer</span>
                            </div>
                        </div>
                    </fieldset>
                </div>
            </cfform>
            <div class="clear"></div>
        </div>
        <div class="white-bot"></div>
    </div>
</cfoutput>

    