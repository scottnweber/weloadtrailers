<cfoutput>
    <cfinvoke component="#variables.objLoadGateway#" method="getGLBalanceSheetSetup" returnvariable="qGLBalanceSheetSetup" />
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
            $(document).on('change', '.GL-Fields', function () {
                var id = $(this).attr('id').split('_')[1];
                var fieldName = $(this).attr('id').split('_')[0];
                var val = $(this).val();
                $.ajax({
                    type    : 'POST',
                    url     : "../gateways/loadgateway.cfc?method=setGLBalanceSheetSetup",
                    data    : {fieldName : fieldName,id:id,value:val, dsn:"#application.dsn#",companyid:'#session.companyid#'},
                    success :function(ID){
                        if(id==0){
                            var tr_clone    = $('##tr_0').clone();
                            $("##ProfitType_0 option[value='0']").remove();
                            $('##id_0').html(ID);
                            $('##tr_0').attr('id','tr_'+ID);
                            $('##id_0').attr('id','id_'+ID);
                            $('##ProfitType_0').attr('id','ProfitType_'+ID);
                            $('##MainTitle_0').attr('id','MainTitle_'+ID);
                            $('##MainSort_0').attr('id','MainSort_'+ID);
                            $('##SubTitle_0').attr('id','SubTitle_'+ID);
                            $('##SubSort_0').attr('id','SubSort_'+ID);
                            $('##GLAcctFrom_0').attr('id','GLAcctFrom_'+ID);
                            $('##GLAcctTo_0').attr('id','GLAcctTo_'+ID);
                            $('##del_0').attr('onclick','delRow('+ID+')');
                            $('##del_0').attr('id','del_'+ID);
                            
                            $('##body-list').append(tr_clone);
                            $('##ProfitType_0').val(0);
                            $('##MainTitle_0').val('');
                            $('##MainSort_0').val('');
                            $('##SubTitle_0').val('');
                            $('##SubSort_0').val('');
                            $('##GLAcctFrom_0').val('');
                            $('##GLAcctTo_0').val('');
                        }
                    },
                    beforeSend:function() {
                    },
                });
            });
        })
        
        function delRow(ID){
            if(ID != 0){
                if(confirm('Are you sure you want to delete this row?')){
                    $.ajax({
                        type    : 'POST',
                        url     : "../gateways/loadgateway.cfc?method=deleteGLBalanceSheetSetup",
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
    </script>
    <h1>General Ledger Financial Setup</h1>
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
                <th align="center" valign="middle" class="head-bg" >&nbsp;</th>
                <th align="center" valign="middle" class="head-bg" width="20%">Profit Type</th>
                <th align="center" valign="middle" class="head-bg" width="25%">Main Title</th>
                <th align="center" valign="middle" class="head-bg" width="5%">Main Sort</th>
                <th align="center" valign="middle" class="head-bg" width="25%">Sub Title</th>
                <th align="center" valign="middle" class="head-bg" width="5%">Sub Sort</th>
                <th align="center" valign="middle" class="head-bg" width="10%">Acct From</th>
                <th align="center" valign="middle" class="head-bg" width="10%">Acct To</th>
                <th align="center" valign="middle" class="head-bg2" ></th>
                <th align="right" valign="top"><img src="images/top-right.gif" alt="" width="5" height="48" /></th>
            </tr>
        </thead>
        <tbody id="body-list">
            <cfloop query="qGLBalanceSheetSetup">
                <tr id="tr_#qGLBalanceSheetSetup.ID#">
                    <td height="20" class="sky-bg">&nbsp;</td>
                    <td class="sky-bg2" valign="middle" align="center" id="id_#qGLBalanceSheetSetup.ID#">#qGLBalanceSheetSetup.ID#</td>
                    <td  align="left" valign="middle" nowrap="nowrap" class="normal-td">
                        <cfset listProfitType = "Gross Profit,Net Profit,Total Net Profit">
                        <select id="ProfitType_#qGLBalanceSheetSetup.ID#" class="GL-Fields" style="width:100%;">
                            <cfloop list="#listProfitType#" index="Type">
                                <option value="#Type#" <cfif qGLBalanceSheetSetup.ProfitType EQ Type>selected </cfif>>#Type#</option>
                            </cfloop>
                        </select>
                    </td>
                    <td  align="left" valign="middle" nowrap="nowrap" class="normal-td">
                        <input  style="width:98%;" class="GL-Fields" id="MainTitle_#qGLBalanceSheetSetup.ID#" value="#qGLBalanceSheetSetup.MainTitle#">
                    </td>
                    <td  align="left" valign="middle" nowrap="nowrap" class="normal-td">
                        <input style="width:92%;text-align: right;" class="GL-Fields" id="MainSort_#qGLBalanceSheetSetup.ID#" value="#qGLBalanceSheetSetup.MainSort#">
                    </td>
                    <td  align="left" valign="middle" nowrap="nowrap" class="normal-td">
                        <input style="width:98%;" class="GL-Fields" id="SubTitle_#qGLBalanceSheetSetup.ID#" value="#qGLBalanceSheetSetup.SubTitle#">
                    </td>
                    <td  align="left" valign="middle" nowrap="nowrap" class="normal-td">
                        <input  style="width:92%;text-align: right;" class="GL-Fields" id="SubSort_#qGLBalanceSheetSetup.ID#" value="#qGLBalanceSheetSetup.SubSort#">
                    </td>
                    <td align="left" valign="middle" nowrap="nowrap" class="normal-td">
                       <input style="width:95%;" class="GL-Fields" id="GLAcctFrom_#qGLBalanceSheetSetup.ID#" value="#qGLBalanceSheetSetup.GLAcctFrom#">
                    </td>
                    <td  align="right" valign="middle" nowrap="nowrap" class="normal-td">
                        <input style="width:95%;" class="GL-Fields" id="GLAcctTo_#qGLBalanceSheetSetup.ID#" value="#qGLBalanceSheetSetup.GLAcctTo#">
                    </td>
                    <td  align="left" valign="middle" nowrap="nowrap" class="normal-td2">
                        <img onclick="delRow(#qGLBalanceSheetSetup.ID#)" src="images/delete-icon.gif" style="width:10px;margin-left: 5px;cursor: pointer;float:left" id="del_#qGLBalanceSheetSetup.ID#">
                    </td>
                    <td class="normal-td3">&nbsp;</td>
                </tr>
            </cfloop>
            <tr id="tr_0">
                <td height="20" class="sky-bg">&nbsp;</td>
                <td class="sky-bg2" valign="middle" align="center" id="id_0"></td>
                <td  align="left" valign="middle" nowrap="nowrap" class="normal-td">
                    <cfset listProfitType = "Gross Profit,Net Profit,Total Net Profit">
                    <select id="ProfitType_0" class="GL-Fields" style="width:100%;">
                        <option value="0"></option>
                        <cfloop list="#listProfitType#" index="Type">
                            <option value="#Type#">#Type#</option>
                        </cfloop>
                    </select>
                </td>
                <td  align="left" valign="middle" nowrap="nowrap" class="normal-td">
                    <input  style="width:98%;" class="GL-Fields" id="MainTitle_0" value="">
                </td>
                <td  align="left" valign="middle" nowrap="nowrap" class="normal-td">
                    <input style="width:92%;text-align: right;" class="GL-Fields" id="MainSort_0" value="">
                </td>
                <td  align="left" valign="middle" nowrap="nowrap" class="normal-td">
                    <input style="width:98%;" class="GL-Fields" id="SubTitle_0" value="">
                </td>
                <td  align="left" valign="middle" nowrap="nowrap" class="normal-td">
                    <input  style="width:92%;text-align: right;" class="GL-Fields" id="SubSort_0" value="">
                </td>
                <td align="left" valign="middle" nowrap="nowrap" class="normal-td">
                   <input style="width:95%;" class="GL-Fields" id="GLAcctFrom_0" value="">
                </td>
                <td  align="right" valign="middle" nowrap="nowrap" class="normal-td">
                    <input style="width:95%;" class="GL-Fields" id="GLAcctTo_0" value="">
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
                <td colspan="9" align="left" valign="middle" class="footer-bg">
                </td>
                <td width="5" align="right" valign="top"><img src="images/right-bot.gif" alt="" width="5" height="23" /></td>
            </tr>  
        </tfoot>   
    </table>
</cfoutput>