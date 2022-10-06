<cfoutput>
    <cfif structKeyExists(form, "submitSystemConfig")>
        <cfinvoke component="#variables.objLoadGateway#" method="setLMASystemConfig" frmstruct="#form#" returnvariable="session.systemconfigupdatemsg"/>
        <cfif structKeyExists(form, "UseDifferentGLAccountForCommodityTypes")>
            <cfinvoke component="#variables.objunitGateway#" method="getFirstUnit" returnvariable="unitid" />
            <cflocation url="index.cfm?event=addunit&unitid=#unitid#&#session.URLToken#">
        <cfelse>
            <cflocation url="index.cfm?event=LMASettings&#session.URLToken#">
        </cfif>
    </cfif>
    <cfinvoke component="#variables.objLoadGateway#" method="getAcctDeptList" returnvariable="qAcctDeptList" />
    <cfinvoke component="#variables.objLoadGateway#" method="getLMASystemConfig" returnvariable="qLMASystemConfig" />
    <cfset ARGLAccount = qLMASystemConfig['AR GL Account']>
    <cfset ARDiscountAccount = qLMASystemConfig['AR Discount GL']>
    <cfset ARSalesTaxAccount = qLMASystemConfig['AR Sales Tax Account']>
    <cfset ARInterestEarnedAccount = qLMASystemConfig['AR Interest Earned Account']>
    <cfset DepositClearingAccount = qLMASystemConfig['Chk_clearing']>
    <cfset CustomerDeposits = qLMASystemConfig['Cust_Deposit_Acct']>
    <cfset SalespersonCommisions = qLMASystemConfig['Company2']>
    <cfset FiscalYear = qLMASystemConfig['Fiscal Year']>
    <cfset GLRetainAccount = qLMASystemConfig['GL Retain Account']>
    <cfset PostingWindow = qLMASystemConfig['PostingWindow']>
    <cfset APGLAccount = qLMASystemConfig['AP GL Account']>
    <cfset APDiscountAccount = qLMASystemConfig['AP Discount GL']>
    <cfset BankInterestEarned = qLMASystemConfig['Int_Acct']>
    <cfset BankChargesAccount = qLMASystemConfig['Chg_Acct']>
    <cfset CashOverShortAccount = qLMASystemConfig['Overshort Acct']>
    <cfset FreightSales = qLMASystemConfig['AR Sales']>
    <cfset CostOfFreightSales = qLMASystemConfig['AR Cost of Sales']>
    <cfset UseDifferentGLAccountForCommodityTypes = qLMASystemConfig['UseDifferentGLAccountForCommodityTypes']>
    <style type="text/css">
        .white-mid div.form-con label {
            float: left;
            text-align: right;
            width: 140px;
            padding: 0 10px 0 0;
            font-size: 11px;
            font-weight: bold;
            color: ##000000;
        }
        .white-mid div.form-con input {
            float: left;
            width: 200px;
            background: ##FFFFFF;
            border: 1px solid ##b3b3b3;
            padding: 2px 2px 0 2px;
            margin: 0 0 8px 0;
            font-size: 11px;
            margin-right: 8px !important;
            height: 18px;
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

            var sourceJson = [
            <cfloop query="qAcctDeptList">
                <cfif not listFind(".,/", qAcctDeptList.GL_ACCT)>
                    {label: "#qAcctDeptList.GL_ACCT# #qAcctDeptList.description#", value: "#qAcctDeptList.GL_ACCT#"},
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
                            }
                        });
                        if(keyFound==0){
                            alert('Invalid account number. Please correct and try again');
                            $(this).val('');
                            $(this).focus();
                            $(this).val('');
                        }
                    }   
                });
            });
        })

    </script>
    <h1>General Ledger Integration</h1>
    <div class="clear"></div>
    <cfform id="SettingsForm" name="SettingsForm" action="index.cfm?event=LMASettings&#session.URLToken#" method="post" preserveData="yes">
        <input type="hidden" value="#qLMASystemConfig.ID#" name="id">
        <div style="margin-left:692px;">
            <input type="submit" name="submitSystemConfig" class="bttn" value="Save" style="width:80px;margin-top: -20px;margin-bottom: 5px;">
        </div>
        <cfif structKeyExists(session, "systemconfigupdatemsg")>
            <div id="message" class="msg-area" style="margin-right: 160px;float: left;margin-bottom: 5px;width: 450px;">#session.systemconfigupdatemsg#</div>
            <cfset structDelete(session, "systemconfigupdatemsg")>
        </cfif>
        <div class="clear"></div>
        <div class="white-con-area" style="width:999px">
            <div class="white-mid" style="width:999px">
                <div class="form-con" style="width:400px;padding:0">
                    <div style="height: 36px;background-color: ##82bbef;margin-bottom: 5px;float: right;margin-right: 10px">
                        <h2 style="color:white;font-weight:bold;padding-top: 10px;width:400px">Accounts Receivable</h2>
                    </div>
                    <label>A/R Account:</label>
                    <input name="ARGLAccount" type="text" value="#ARGLAccount#" maxlength="100" tabindex="1" class="LMAAutoComplete">
                    <div class="clear"></div>
                    <label>A/R Discount Account:</label>
                    <input name="ARDiscountAccount" type="text" value="#ARDiscountAccount#" maxlength="100" tabindex="2" class="LMAAutoComplete">
                    <label>A/R Sales Tax Account:</label>
                    <input name="ARSalesTaxAccount" type="text" value="#ARSalesTaxAccount#" maxlength="100" tabindex="3" class="LMAAutoComplete">
                    <label>A/R Interest Earned:</label>
                    <input name="ARInterestEarnedAccount" type="text" value="#ARInterestEarnedAccount#" maxlength="100" tabindex="4" class="LMAAutoComplete">
                    <label>Deposit Clearing Account:</label>
                    <input name="DepositClearingAccount" type="text" value="#DepositClearingAccount#" maxlength="100" tabindex="5" class="LMAAutoComplete">
                    <label>Customer Deposits:</label>
                    <input name="CustomerDeposits" type="text" value="#CustomerDeposits#" maxlength="100" tabindex="6">
                    <label>Salesperson Commisions:</label>
                    <input name="SalespersonCommisions" type="text" value="#SalespersonCommisions#" maxlength="100" tabindex="7" class="LMAAutoComplete">
                    <label>Freight Sales:</label>
                    <input name="FreightSales" type="text" value="#FreightSales#" maxlength="100" tabindex="8" class="LMAAutoComplete">
                    <label>Cost of Freight Sales:</label>
                    <input name="CostOfFreightSales" type="text" value="#CostOfFreightSales#" maxlength="100" tabindex="9" class="LMAAutoComplete">

                    <label style="width: 330px;">Use different G/L account for Commodity Types/Accessorials?</label>
                    <input name="UseDifferentGLAccountForCommodityTypes" id="UseDifferentGLAccountForCommodityTypes" type="checkbox" tabindex="9" class="LMAAutoComplete" style="width: 17px;" <cfif UseDifferentGLAccountForCommodityTypes EQ 1> checked </cfif> >
                </div>
                <div class="form-con" style="width:400px;padding:0;margin-left:50px; ">
                    <div style="height: 36px;background-color: ##82bbef;margin-bottom: 5px;float: right;margin-right: 10px">
                        <h2 style="color:white;font-weight:bold;padding-top: 10px;width:400px">General Ledger</h2>
                    </div>
                    <label>Fiscal Year Start:</label>
                    <input id="FiscalYear" name="FiscalYear" type="text" value="#DateFormat(FiscalYear,'mm/dd/yyyy')#" maxlength="100" tabindex="10" style="width:60px !important;">
                    <div class="clear"></div>
                    <label>G/L Retain Account:</label>
                    <input name="GLRetainAccount" type="text" value="#GLRetainAccount#" maxlength="100" tabindex="11" class="LMAAutoComplete">
                    <label>Posting Window:</label>
                    <input name="PostingWindow" type="text" value="#PostingWindow#" maxlength="100" tabindex="12">
                </div>
                <div class="form-con" style="width:400px;padding:0;margin-left:50px; ">
                    <div style="height: 36px;background-color: ##82bbef;margin-bottom: 5px;float: right;margin-right: 10px">
                        <h2 style="color:white;font-weight:bold;padding-top: 10px;width:400px">Bank Reconcilation</h2>
                    </div>
                    <label>Bank Interest Earned:</label>
                    <input name="BankInterestEarned" type="text" value="#BankInterestEarned#" maxlength="100" tabindex="13" class="LMAAutoComplete">
                    <label>Bank Charges Account:</label>
                    <input name="BankChargesAccount" type="text" value="#BankChargesAccount#" maxlength="100" tabindex="14" class="LMAAutoComplete">
                    <label>Cash Over/Short Account:</label>
                    <input name="CashOverShortAccount" type="text" value="#CashOverShortAccount#" maxlength="100" tabindex="15" class="LMAAutoComplete">
                </div>
                <div class="form-con" style="width:400px;padding:0;margin-left:50px;">
                    <div style="height: 36px;background-color: ##82bbef;margin-bottom: 5px;float: right;margin-right: 10px">
                        <h2 style="color:white;font-weight:bold;padding-top: 10px;width:400px">Accounts Payable</h2>
                    </div>
                    <label>A/P Account:</label>
                    <input name="APGLAccount" type="text" value="#APGLAccount#" maxlength="100" tabindex="16" class="LMAAutoComplete">
                    <label>A/P Discount Account:</label>
                    <input name="APDiscountAccount" type="text" value="#APDiscountAccount#" maxlength="100" tabindex="17" class="LMAAutoComplete">
                </div>
            </div>
        </div>
    </cfform>  
</cfoutput>

    