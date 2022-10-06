<cfoutput>
    <cfinvoke component="#variables.objLoadGateway#" method="getAcctDeptList" returnvariable="qAcctDeptList" />
    <cfinvoke component="#variables.objLoadGateway#" method="getBankAccounts" returnvariable="qBankAccounts" />
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
        .head-bg,.head-bg2{
            background-size: contain;
        }
        .normal-td,.normal-td2{
            padding: 0px;
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
                    focus: function( event, ui ) {
                        $(this).val( ui.item.value );
                    },
                    change: function(event,ui){
                        var val = $(this).val();
                        var keyFound = 0;
                        $.each(sourceJson, function(i, v) {
                            if (v.value == val) {
                                keyFound = 1;
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
                        $('##'+id).change();
                        return false;
                    }  
                });
            });
            $(document).on('change', '.formatDollar', function () {
                if(isNaN($(this).val().replace(/[$,]/g, ''))){
                    $(this).val('$0.00');
                }
                formatDollarNegative($(this).val(), $(this).attr('id'));
            })
            $(document).on('change', '.bank-fields', function () {
                var fieldName = $(this).attr('data-fieldName');
                var id = $(this).attr('id').split('_')[1];
                var idField = $(this).attr('id').split('_')[0];
                var val = $(this).val();
                $.ajax({
                    type    : 'POST',
                    url     : "../gateways/loadgateway.cfc?method=LMACheckRegisterSetup",
                    data    : {fieldName : fieldName,id:id,value:val, dsn:"#application.dsn#",companyid:'#session.companyid#'},
                    success :function(ID){
                        if(id==0){
                            $('##id_0').html(ID);
                            $('##tr_0').attr('id','tr_'+ID);
                            $('##id_0').attr('id','id_'+ID);
                            $('##GLAccount_0').attr('id','GLAccount_'+ID);
                            $('##AccountName_0').attr('id','AccountName_'+ID);
                            $('##NextCheckNo_0').attr('id','NextCheckNo_'+ID);
                            $('##NextHandCheck_0').attr('id','NextHandCheck_'+ID);
                            $('##NextBankStatement_0').attr('id','NextBankStatement_'+ID);
                            $('##PRPBSBal_0').attr('id','PRPBSBal_'+ID);
                            $('##DepInTrans_0').attr('id','DepInTrans_'+ID);
                            $('##OutstandingChks_0').attr('id','OutstandingChks_'+ID);
                            $('##GLBal_0').attr('id','GLBal_'+ID);
                            $('##del_0').attr('onclick','delRow('+ID+')');
                            $('##del_0').attr('id','del_'+ID);
                            $('##body-bank-list').append('<tr id="tr_0"><td height="20" class="sky-bg">&nbsp;</td><td class="sky-bg2" valign="middle" align="center" id="id_0"></td><td  align="left" valign="middle" nowrap="nowrap" class="normal-td"><input style="width:97%" class="GLAccount bank-fields" id="GLAccount_0" value="" data-fieldName="General Ledger Code"></td><td  align="left" valign="middle" nowrap="nowrap" class="normal-td"><input style="width:98%" class="bank-fields" data-fieldName="Account Name" id="AccountName_0"  value=""></td><td  align="left" valign="middle" nowrap="nowrap" class="normal-td"><input style="width:97%" class="bank-fields" id="NextCheckNo_0" value="0" data-fieldName="Next Check ##"></td><td  align="left" valign="middle" nowrap="nowrap" class="normal-td"><input style="width:97%" class="bank-fields"  id="NextHandCheck_0" value="0" data-fieldName="NextHandCheck"></td><td  align="left" valign="middle" nowrap="nowrap" class="normal-td"><input style="width:97%" id="NextBankStatement_0" value="" class="bank-fields" data-fieldName="DateReconc"></td><td  align="left" valign="middle" nowrap="nowrap" class="normal-td"><input style="width:97%" class="formatDollar bank-fields" id="PRPBSBal_0" value="$0.00" data-fieldName="Openbalance"></td><td  align="right" valign="middle" nowrap="nowrap" class="normal-td"><input style="width:97%" class="formatDollar bank-fields" id="DepInTrans_0" value="$0.00" data-fieldName="Debit"></td><td  align="left" valign="middle" nowrap="nowrap" class="normal-td"><input style="width:97%" class="formatDollar bank-fields" id="OutstandingChks_0" value="$0.00" data-fieldName="Credit"></td><td  align="left" valign="middle" nowrap="nowrap" class="normal-td"><input style="width:100%" class="formatDollar bank-fields" id="GLBal_0" value="$0.00" data-fieldName="Balance"></td><td  align="left" valign="middle" nowrap="nowrap" class="normal-td2"><img onclick="delRow(0)" id="del_0" src="images/delete-icon.gif" style="width:10px;margin-left: 5px;cursor: pointer;float:left"></td><td class="normal-td3">&nbsp;</td></tr>');
                            $( "##GLAccount_0" ).autocomplete({
                                source: sourceJson
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
                if(confirm('Are you sure you want to delete this account?')){
                    $.ajax({
                        type    : 'POST',
                        url     : "../gateways/loadgateway.cfc?method=LMADeleteCheckRegisterSetup",
                        data    : {id:ID, dsn:'#application.dsn#',companyid:'#session.companyid#'},
                        success :function(){
                            $('##tr_'+ID).remove();
                        },
                        beforeSend:function() {
                        },
                    });
                }
            }
            
        }
    </script>
    <h1>Bank Accounts</h1>
    <div class="clear"></div>
    <cfset pageSize = 30>
    <cfif isdefined("form.pageNo")>
        <cfset rowNum = ((form.pageNo-1)*pageSize)>
    <cfelse>
        <cfset rowNum = 0>
    </cfif>

    <table width="100%" border="0" class="data-table" cellspacing="0" cellpadding="0" style="color:##000000;">
        <thead>
            <tr>
                <th align="left" valign="top"><img src="images/top-left.gif" alt="" width="5" height="48" /></th>
                <th align="center" valign="middle" class="head-bg" width="10">&nbsp;</th>
                <th align="center" valign="middle" class="head-bg" width="70">G/L Account</th>
                <th align="center" valign="middle" class="head-bg" width="250">Account Name</th>
                <th align="center" valign="middle" class="head-bg" width="80">Next<br>Comp Chk</th>
                <th align="center" valign="middle" class="head-bg" width="80">Next<br>Hand Chk</th>
                <th align="center" valign="middle" class="head-bg" width="80">Next Bank<br>Statement</th>
                <th align="center" valign="middle" class="head-bg" width="85">Prior Reconciled<br>Bank Statement<br>Balance</th>
                <th align="center" valign="middle" class="head-bg" width="85">Deposit In<br>Transit</th>
                <th align="center" valign="middle" class="head-bg" width="85" width="80">Outstanding<br>Checks</th>
                <th align="center" valign="middle" class="head-bg" width="85">GL Balance</th>

                <th align="center" valign="middle" class="head-bg2" width="10"></th>

                <th align="right" valign="top"><img src="images/top-right.gif" alt="" width="5" height="48" /></th>
            </tr>
        </thead>
        <tbody id="body-bank-list">
            <cfloop query="qBankAccounts">
                <tr id="tr_#qBankAccounts.ID#">
                    <td height="20" class="sky-bg">&nbsp;</td>
                    <td class="sky-bg2" valign="middle" align="center" id="id_#qBankAccounts.ID#">#qBankAccounts.ID#</td>
                    <td  align="left" valign="middle" nowrap="nowrap" class="normal-td">
                        <input style="width:97%" class="GLAccount bank-fields" id="GLAccount_#qBankAccounts.ID#" value="#qBankAccounts.GLAccount#" data-fieldName="General Ledger Code">
                    </td>
                    <td  align="left" valign="middle" nowrap="nowrap" class="normal-td">
                        <input style="width:98%" class="bank-fields" data-fieldName="Account Name" id="AccountName_#qBankAccounts.ID#" value="#qBankAccounts.AccountName#">
                    </td>
                    <td  align="left" valign="middle" nowrap="nowrap" class="normal-td">
                        <input style="width:97%" onkeyup="if (/\D/g.test(this.value)) this.value = this.value.replace(/\D/g,'0')"  class="bank-fields" id="NextCheckNo_#qBankAccounts.ID#" value="#qBankAccounts.NextCheckNo#" data-fieldName="Next Check ##">
                    </td>
                    <td  align="left" valign="middle" nowrap="nowrap" class="normal-td">
                        <input style="width:97%" class="bank-fields" onkeyup="if (/\D/g.test(this.value)) this.value = this.value.replace(/\D/g,'0')"  id="NextHandCheck_#qBankAccounts.ID#" value="#qBankAccounts.NextHandCheck#" data-fieldName="NextHandCheck">
                    </td>
                    <td  align="left" valign="middle" nowrap="nowrap" class="normal-td">
                        <input style="width:97%" class="bank-fields" id="NextBankStatement_#qBankAccounts.ID#" value="#DateFormat(qBankAccounts.DateReconc,"mm/dd/yyyy")#"  data-fieldName="DateReconc">
                    </td>
                    <td  align="left" valign="middle" nowrap="nowrap" class="normal-td">
                        <input style="width:97%" class="formatDollar bank-fields" id="PRPBSBal_#qBankAccounts.ID#" value="#DollarFormat(qBankAccounts.OpenBalance)#" data-fieldName="OpenBalance">
                    </td>
                    <td  align="right" valign="middle" nowrap="nowrap" class="normal-td">
                        <input style="width:97%" class="formatDollar bank-fields" id="DepInTrans_#qBankAccounts.ID#" value="#DollarFormat(qBankAccounts.Debit)#" data-fieldName="Debit">
                    </td>
                    <td  align="left" valign="middle" nowrap="nowrap" class="normal-td">
                        <input style="width:97%" class="formatDollar bank-fields" id="OutstandingChks_#qBankAccounts.ID#" value="#DollarFormat(qBankAccounts.Credit)#" data-fieldName="Credit">
                    </td>
                    <td  align="left" valign="middle" nowrap="nowrap" class="normal-td">
                        <input style="width:100%" class="formatDollar bank-fields" id="GLBal_#qBankAccounts.ID#" value="#DollarFormat(qBankAccounts.Balance)#" data-fieldName="Balance">
                    </td>
                    <td  align="left" valign="middle" nowrap="nowrap" class="normal-td2">
                        <img onclick="delRow(#qBankAccounts.ID#)" src="images/delete-icon.gif" style="width:10px;margin-left: 5px;cursor: pointer;float:left" id="del_#qBankAccounts.ID#">
                    </td>
                    <td class="normal-td3">&nbsp;</td>
                </tr>
            </cfloop>
            <tr id="tr_0">
                <td height="20" class="sky-bg">&nbsp;</td>
                <td class="sky-bg2" valign="middle" align="center" id="id_0"></td>
                <td  align="left" valign="middle" nowrap="nowrap" class="normal-td">
                    <input style="width:97%" class="GLAccount bank-fields" id="GLAccount_0" value="" data-fieldName="General Ledger Code">
                </td>
                <td  align="left" valign="middle" nowrap="nowrap" class="normal-td">
                    <input style="width:98%" class="bank-fields" data-fieldName="Account Name" id="AccountName_0"  value="">
                </td>
                <td  align="left" valign="middle" nowrap="nowrap" class="normal-td">
                    <input style="width:97%" onkeyup="if (/\D/g.test(this.value)) this.value = this.value.replace(/\D/g,'0')"  class="bank-fields" id="NextCheckNo_0" value="0" data-fieldName="Next Check ##">
                </td>
                <td  align="left" valign="middle" nowrap="nowrap" class="normal-td">
                    <input style="width:97%" class="bank-fields"  onkeyup="if (/\D/g.test(this.value)) this.value = this.value.replace(/\D/g,'0')"  id="NextHandCheck_0" value="0" data-fieldName="NextHandCheck">
                </td>
                <td  align="left" valign="middle" nowrap="nowrap" class="normal-td">
                    <input style="width:97%" class="bank-fields" id="NextBankStatement_0" value="" data-fieldName="DateReconc">
                </td>
                <td  align="left" valign="middle" nowrap="nowrap" class="normal-td">
                    <input style="width:97%" class="formatDollar bank-fields" id="PRPBSBal_0" value="$0.00">
                </td>
                <td  align="right" valign="middle" nowrap="nowrap" class="normal-td" data-fieldName="Openbalance">
                    <input style="width:97%" class="formatDollar bank-fields" id="DepInTrans_0" value="$0.00" data-fieldName="Debit">
                </td>
                <td  align="left" valign="middle" nowrap="nowrap" class="normal-td">
                    <input style="width:97%" class="formatDollar bank-fields" id="OutstandingChks_0" value="$0.00" data-fieldName="Credit">
                </td>
                <td  align="left" valign="middle" nowrap="nowrap" class="normal-td">
                    <input style="width:100%" class="formatDollar bank-fields" id="GLBal_0" value="$0.00" data-fieldName="Balance">
                </td>
                <td  align="left" valign="middle" nowrap="nowrap" class="normal-td2">
                    <img onclick="delRow(0)" src="images/delete-icon.gif" style="width:10px;margin-left: 5px;cursor: pointer;float:left" id="del_0">
                </td>
                <td class="normal-td3">&nbsp;</td>
            </tr>
       </tbody>
       <tfoot>
            <tr>
                <td width="5" align="left" valign="top"><img src="images/left-bot.gif" alt="" width="5" height="23" /></td>
                <td colspan="11" align="left" valign="middle" class="footer-bg">
                </td>
                <td width="5" align="right" valign="top"><img src="images/right-bot.gif" alt="" width="5" height="23" /></td>
            </tr>  
        </tfoot>   
    </table>
</cfoutput>