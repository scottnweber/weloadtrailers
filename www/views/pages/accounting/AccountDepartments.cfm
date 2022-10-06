<cfoutput>
    <cfif structKeyExists(url, "deleteID")>
        <cfinvoke component="#variables.objLoadGateway#" method="deleteAccountDepartment" ID="#url.deleteID#" returnvariable="session.AcctDeptMsg"/>
        <cflocation url="index.cfm?event=Departments&#session.URLToken#">
    </cfif>
    <cfparam name="url.id" default="">
    <cfparam name="variables.totalrows" default="0">
    <cfif structKeyExists(form, "SaveAcctDept")>
        <cfinvoke frmStruct="#form#" component="#variables.objLoadGateway#" method="SaveAccountDepartment" returnvariable="resp"/>
        <cfset session.AcctDeptMsg = resp>
        <cfif session.AcctDeptMsg.id NEQ 0>
            <cflocation url="index.cfm?event=AccountDepartments&id=#session.AcctDeptMsg.id#&#session.URLToken#">
        <cfelse>
            <cflocation url="index.cfm?event=AccountDepartments&#session.URLToken#">
        </cfif>
    </cfif>
    <cfinvoke component="#variables.objLoadGateway#" method="getAcctDeptList" returnvariable="qAcctDeptList" />
    <cfinvoke component="#variables.objLoadGateway#" method="getDeptList" returnvariable="qDeptList" />
    <cfinvoke component="#variables.objloadGateway#" method="getSystemSetupOptions" returnvariable="request.qGetSystemSetupOptions" />
    <cfinvoke component="#variables.objLoadGateway#" method="getDeptDetails" returnvariable="qDeptDetails" id="#url.id#"/>
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
            width: 469px;
            float: left;
            margin-top: 5px;
            background-color: ##b9e4b9;
        }
        .msg-area-error{
            border: 1px solid ##da4646;
            padding: 5px 15px;
            font-weight: normal;
            margin: 0 auto;
            width: 469px;
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
            width: 150px !important;
            cursor: pointer;
        }
    </style>
    <script>
        $(document).ready(function(){
            var sourceJsonDept = [
            <cfloop query="qDeptList">
                    {label: "#qDeptList.Dept# #qDeptList.description#", value: "#qDeptList.Dept#", description:"#qDeptList.description#"},
            </cfloop>
            ]

            $('##Dept').autocomplete({
                multiple: false,
                width: 400,
                scroll: true,
                scrollHeight: 300,
                cacheLength: 1,
                highlight: false,
                dataType: "json",
                autoFocus: true,
                source: sourceJsonDept,
                select: function(e, ui) {
                    $('##Description').val(ui.item.description);
                }
            });
            $.ui.autocomplete.filter = function (array, term) {
                var matcher = new RegExp("^" + $.ui.autocomplete.escapeRegex(term), "i");
                return $.grep(array, function (value) {
                    return matcher.test(value.label || value.value || value);
                });
            };
            var sourceJson = [
            <cfloop query="qAcctDeptList">
                <cfif not listFind(".,/", qAcctDeptList.GL_ACCT) and len(trim(qAcctDeptList.GL_ACCT)) EQ 4>
                    {label: "#qAcctDeptList.GL_ACCT# #qAcctDeptList.description#", value: "#qAcctDeptList.GL_ACCT#", description:"#qAcctDeptList.description#",creditdebit:"#qAcctDeptList.credit_debit#"},
                </cfif>
            </cfloop>
            ]

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
                        return false;
                    }  
                })
            })

            $(document).on('change', '.GL-Fields', function () {
                var row = $(this).closest("tr");
                var id=$(row).attr('id').split('_')[1];
                var totalRows = parseInt($('##totalRows').val());
                if(id==0){
                    var tr_clone    = $('##tr_0').clone();
                    var ID = totalRows + 1;
                    $('##id_0').html('');
                    $('##tr_0').attr('id','tr_'+ID);
                    $('##id_0').attr('id','id_'+ID);

                    $('##glacct_0').attr('name','glacct_'+ID);
                    $('##glacct_0').attr('id','glacct_'+ID);
                    $('##description_0').attr('name','description_'+ID);
                    $('##description_0').attr('id','description_'+ID);

                    $('##body-list').append(tr_clone);
                    $('##glacct_0').val('');
                    $('##description_0').val('');
                    $('##totalRows').val(ID);
                    $("##glacct_0").autocomplete({
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
                            $( "##glacct_"+indx ).trigger( "change" );
                            return false;
                        }  
                    })
                }
            })
        })

        function validateDept(){
            var dept = $('##Dept').val();
            if(!$.trim(dept).length){
                alert('Please enter Dept.')
                $('##Dept').focus()
                return false; 
            }

            var Description = $('##Description').val();
            if(!$.trim(Description).length){
                alert('Please enter Description.')
                $('##Description').focus()
                return false; 
            }

            deptExists = 0;
            var sourceJsonDept = [
            <cfloop query="qDeptList">
                    {label: "#qDeptList.Dept# #qDeptList.description#", value: "#qDeptList.Dept#", description:"#qDeptList.description#"},
            </cfloop>
            ]
            $.each(sourceJsonDept, function(i, v) {
                if (v.value == $.trim(dept)) {
                    deptExists = 1;
                }
            });

            if(!deptExists){
                return true;
            }
            else{
                return true;
            }
            return false;
        }
    </script>
    <div class="white-con-area" style="height: 36px;background-color: ##82bbef;width:50%;">
        <div style="float: left;">
            <h2 style="color:white;font-weight:bold;margin-left: 12px;">Departments</h2>
        </div>
        <cfif structKeyExists(url, "ID") AND len(trim(url.ID))>    
            <div class="delbutton" style="float:left;margin-left: 435px;margin-top: -33px;">
                <a href="index.cfm?event=AccountDepartments&deleteid=#url.id#&#session.URLToken#" onclick="return confirm('Are you sure you want to delete this Department?');">  Delete</a>
            </div>
        </cfif>
    </div>
    <div style="clear:left"></div>

    <cfform id="AccountDepartmentsForm" name="AccountDepartmentsForm" action="index.cfm?event=AccountDepartments&#session.URLToken#" method="post" preserveData="yes" onsubmit="return validateDept();">
        <input type="hidden" name="id" value="#url.id#">
        <div class="search-panel" style="width:100%;">
            <div class="form-search" style="width:50%;background-color: #request.qGetSystemSetupOptions.BackgroundColorForContentAccounting# !important;padding-bottom: 10px;">
                <fieldset style="width:100%;float:left;">
                    <div style="float:left">
                        <label style="font-weight: bold;width:25px;margin-left: 10px;">Dept:</label>
                        <input class="sm-input" id="Dept" name="Dept" value="#qDeptDetails.Dept#"/>
                    </div>
                    <div style="float:left">
                        <label style="font-weight: bold;width:70px;margin-left: 10px;">Description</label>
                        <input class="sm-input" name="DeptDesc" id="Description" type="text" style="width:200px !important;" value="#qDeptDetails.DeptDesc#"/>
                    </div>
                    <div style="float:left">
                        <button class="btn" name="SaveAcctDept" style="width: 60px !important;"><b>Save</b></button>
                    </div>
                </fieldset>
            </div>
        </div>
        <div class="clear"></div>
        <cfif structKeyExists(session, "AcctDeptMsg")>
            <div id="message" class="msg-area-#session.AcctDeptMsg.res#">#session.AcctDeptMsg.msg#</div>
            <cfset structDelete(session, "AcctDeptMsg")>
        </cfif>
        <div class="clear"></div>
        <table width="50%" border="0" class="data-table" cellspacing="0" cellpadding="0" style="color:##000000;">
            <thead>
                <tr>
                    <th align="left" valign="top"><img src="images/top-left.gif" alt="" width="5" /></th>
                    <th align="center" valign="middle" class="head-bg" >&nbsp;</th>
                    <th align="center" valign="middle" class="head-bg" width="25%">G/L Account</th>
                    <th align="center" valign="middle" class="head-bg2" width="75%">Description</th>
                    <th align="right" valign="top"><img src="images/top-right.gif" alt="" width="5" /></th>
                </tr>
            </thead>
            <tbody id="body-list">
                <tr id="tr_0">
                    <td height="20" class="sky-bg">&nbsp;</td>
                    <td class="sky-bg2" valign="middle" align="center" id="id_0">
                        <b style="font-size: 20px;">*</b>
                    </td>
                    <td  align="left" valign="middle" nowrap="nowrap" class="normal-td">
                        <input  style="width:96%;" class="GLAccount GL-Fields" value="" id="glacct_0" name="glacct_0">
                    </td>
                    <td  align="left" valign="middle" nowrap="nowrap" class="normal-td2">
                        <input style="width:100%;" class="GL-Fields" value="" id="description_0" name="description_0">
                    </td>
                    <td class="normal-td3">&nbsp;</td>
                </tr>
           </tbody>
           <tfoot>
                <tr>
                    <td width="5" align="left" valign="top"><img src="images/left-bot.gif" alt="" width="5" height="23" /></td>
                    <td colspan="3" align="left" valign="middle" class="footer-bg">
                    </td>
                    <td width="5" align="right" valign="top"><img src="images/right-bot.gif" alt="" width="5" height="23" /></td>
                </tr>  
            </tfoot>   
        </table>
        <div class="clear"></div>
        <fieldset style="width:49%;padding:5px;float:left;background-color: #request.qGetSystemSetupOptions.BackgroundColorForContentAccounting# !important;">
            <div style="text-align: right;margin-right: 62px;">
                <input type="hidden" name="totalRows" id="totalRows" value="#variables.totalrows#">
                <input type="hidden" name="Type" id="Type" value="Asset">
                <label style="font-weight: bold;float: left;margin-left: 88px;">Add Dept Description to end of GL Account Description?</label>
                <input type="checkbox" name="addDeptDesc" style="float: left;margin-top: 2px;margin-left: 5px;">
                <div class="clear"></div>
                <label style="font-weight: bold;">Description Separator:</label>
                <input class="sm-input" name="DescSep" type="text" value='-' style="width: 25px !important;"/>
                <div class="clear"></div>
                <button class="btn" name="SaveAcctDept"><b>Create New Accounts</b></button>
            </div> 
        </fieldset>
    </cfform>
</cfoutput>