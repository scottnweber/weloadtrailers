<cfoutput>
    <cfif structKeyExists(url, "deleteID")>
        <cfinvoke component="#variables.objLoadGateway#" method="DeleteChartOfAccounts" ID="#url.deleteID#" returnvariable="session.COAmsg"/>
        <cflocation url="index.cfm?event=ListChartofAccounts&#session.URLToken#">
    </cfif>

    <cfif structKeyExists(form, "submit")>
        <cfinvoke component="#variables.objLoadGateway#" method="saveChartOfAccounts" frmstruct="#form#" returnvariable="url.ID"/>
        <cfset session.COAmsg = "Success.">
        <cflocation url="index.cfm?event=ChartofAccounts&ID=#url.ID#&#session.URLToken#">
    </cfif>

    <cfparam name="url.ID" default="0">
    <cfinvoke component="#variables.objLoadGateway#" method="getLMAGeneralLedgerChartofAccounts" ID='#url.ID#' returnvariable="qChartofAccounts" />
    <cfinvoke component="#variables.objLoadGateway#" method="getLMASystemConfig" returnvariable="qLMASystemConfig" />
    <cfinvoke component="#variables.objLoadGateway#" method="getDeptList" returnvariable="qDeptList" />
    <cfinvoke component="#variables.objloadGateway#" method="getSystemSetupOptions" returnvariable="request.qGetSystemSetupOptions" />
    <style>
        .msg-area-success{
            border: 1px solid ##a4da46;
            padding: 5px 15px;
            width: 92%;
            float: left;
            margin-top: 5px;
            margin-bottom:  5px;
            background-color: ##b9e4b9;
            font-weight: bold;
            font-style: italic;
        }
        .disabledLoadInputs{
            height: 17px;
        }
        .normal-td,.normal-td2{
            border-bottom: 1px solid ##aec1da;
        }
        .sky-bg{
            background-color: #request.qGetSystemSetupOptions.BackgroundColorForContentAccounting#
        }
    </style>
    <script>
        $(document).ready(function(){

            <cfif url.id EQ 0>
                $('##GL_ACCT').focus();
            <cfelse>
                $('##Description').focus();
            </cfif>
            $('.budgetField').change(function(){

                if(isNaN($(this).val().replace(/[$,]/g, ''))){
                    $(this).val('$0.00');
                }

                var fieldName = $(this).attr('id');
                var val = $(this).val();


                formatDollarNegative(val, fieldName);
            });

            $("##GL_ACCT").keypress(function (e) {
                if (e.which != 8 && e.which != 0 && e.which != 32 && (e.which < 48 || e.which > 57)) {
                    return false;
                }
            }); 
        });

        function checkCOAAcctExists(){
            var GL_ACCT = $.trim($('##GL_ACCT').val());
            $('##deptDesc').html('Description');
            if(GL_ACCT.length){
                var path = urlComponentPath+"loadgateway.cfc?method=checkCOAAcctExists";
                $.ajax({
                    type: "get",
                    url: path,
                    data:{
                        GL_ACCT:GL_ACCT,companyid:'#session.companyid#',dsn:'#application.dsn#'
                    },
                    success: function(exists){
                        if(exists=='true'){
                            alert("Account already exists.");
                            $('##GL_ACCT').val('');
                            $('##GL_ACCT').focus();
                        }
                    }
                });


                if(GL_ACCT.length == 10){
                    var sourceJsonDept = [
                    <cfloop query="qDeptList">
                        {label: "#qDeptList.Dept# #qDeptList.description#", value: "#qDeptList.Dept#", description:"#qDeptList.description#"},
                    </cfloop>
                    ]
                    var dept = GL_ACCT.split("  ")[1];
                    var deptFound =0;
                    $.each(sourceJsonDept, function(i, v) {
                        if (v.value == $.trim(dept)) {
                            deptFound =1;
                            deptstr =v.description;
                        }
                    });
                    if(deptFound){
                        $('##deptDesc').html('Description    ' + deptstr);
                    }
                    else{
                        $('##deptDesc').html('Description');
                    }

                }
            }
        }

        function validateCOA(){
            var GL_ACCT = $.trim($('##GL_ACCT').val());
            var Description = $.trim($('##Description').val());
            var Type = $.trim($('##Type').val());

            if(!GL_ACCT.length){
                alert("Please enter Account-Dept.");
                $('##GL_ACCT').focus();
                return false;
            }

            if(!Description.length){
                alert("Please enter Description.");
                $('##Description').focus();
                return false;
            }

            if(!Description.length){
                alert("Please enter Type.");
                $('##Type').focus();
                return false;
            }
            if($.trim($('##Fiscal').val()) == ""){
                alert('Please setup the Fiscal Year Start on Settings > General Ledger Integration');
                return false;
            }
            $('##submit').hide();
            $('##cancel').css("margin-left","200px");
            return true;
        }
    </script>
    <cfset Fiscal_Year = qLMASystemConfig['Fiscal Year']>
    <h1>General Ledger Account</h1>
    <div style="clear:left"></div>
    <cfform id="COAForm" name="COAForm" action="index.cfm?event=ChartofAccounts&ID=#url.ID#&#session.URLToken#" method="post" preserveData="yes" onsubmit="return validateCOA();">
        <input type="hidden" value="#Fiscal_Year#" id="Fiscal">
        <fieldset style="border-width: 2px;border-style: ridge;border-color: threedface;border-image: initial;width:10%;padding:5px;float:left;height: 35px;">
            <legend style="font-weight: bold;font-size: 12px;">Account-Dept</legend>
            <input class="sm-input <cfif url.id NEQ 0>disabledLoadInputs</cfif>" maxlength="10" id="GL_ACCT" name="GL_ACCT" style="width:97%" <cfif url.id NEQ 0>readonly </cfif> value="#qChartofAccounts.GL_ACCT#" onchange="checkCOAAcctExists()">
        </fieldset>
        <fieldset style="margin-left:5px;border-width: 2px;border-style: ridge;border-color: threedface;border-image: initial;width:26%;padding:5px;float:left;height: 35px;">
            <legend style="font-weight: bold;font-size: 12px;" id="deptDesc">Description</legend>
            <input class="sm-input" id="Description" name="Description" style="width:250px !important;" value="#qChartofAccounts.Description#">
        </fieldset>
        <fieldset style="margin-left:5px;border-width: 2px;border-style: ridge;border-color: threedface;border-image: initial;width:10%;padding:5px;float:left;height: 35px;">
            <legend style="font-weight: bold;font-size: 12px;">Type</legend>
        
            <select name="Type">
                <option value="Asset" <cfif qChartofAccounts.TYPE_Description EQ "Asset"> selected </cfif>>Asset</option>
                <option value="Expense" <cfif qChartofAccounts.TYPE_Description EQ "Expense"> selected </cfif>>Expense</option>
                <option value="Income" <cfif qChartofAccounts.TYPE_Description EQ "Income"> selected </cfif>>Income</option>
                <option value="Liability" <cfif qChartofAccounts.TYPE_Description EQ "Liability"> selected </cfif>>Liability</option>
                <option value="Owner Equity" <cfif qChartofAccounts.TYPE_Description EQ "Owner Equity"> selected </cfif>>Owner Equity</option>
            </select>
   
        </fieldset>
       
        <fieldset style="margin-left:20px;width:30%;padding-top:17px;float:left;height: 35px;">
            <input type ="submit" name="submit" id="submit" class="btn" value="Save" style="color: ##599700;">
            <input type ="button" name="cancel" id="cancel" class="btn" value="Cancel" onclick="javascript:history.back();"  style="color: ##599700;margin-left: 20px;">
        </fieldset>

        <cfif url.id neq 0>
            <cfset FiscalYear = qLMASystemConfig['Fiscal Year']>
            <cfset allowDelete = 1>
            <cfif qChartofAccounts.OPEN_CURRENT NEQ 0 OR qChartofAccounts.OPEN_1YR NEQ 0 OR qChartofAccounts.OPEN_2YR NEQ 0 OR qChartofAccounts.END_CURRENT NEQ 0 OR qChartofAccounts.END_1YR NEQ 0 OR qChartofAccounts.END_2YR NEQ 0>
                <cfset allowDelete = 0>
            </cfif>

            <cfloop index="i" from="#DateFormat(FiscalYear,'yyyy-mm-dd')#" to="#DateFormat(DateAdd('yyyy',1,FiscalYear),'yyyy-mm-dd')#" step="#createTimeSpan(31, 0, 0, 0)#">
                <cfset month = dateFormat('#i#', "MMM")>
                <cfset current = Evaluate('qChartofAccounts.#month#_CURRENT')>
                <cfset oneYr = Evaluate('qChartofAccounts.#month#_CURRENT')>
                <cfset twoYr = Evaluate('qChartofAccounts.#month#_CURRENT')>
                <cfif current NEQ 0 OR oneYr NEQ 0 OR twoYr NEQ 0>
                    <cfset allowDelete = 0>
                </cfif>
            </cfloop>

            <div class="delbutton" style="float:left;margin-left: 95px;">
                <a href="index.cfm?event=ChartofAccounts&deleteid=#url.id#&#session.URLToken#" 
                <cfif allowDelete>
                    onclick="return confirm('Are you sure you want to delete?');"
                <cfelse>
                    onclick="alert('You cannot delete an account that has balances within the current year or past two years. Please zero our all balances and try again.');return false;"
                </cfif>
                >Delete</a>
            </div>
        </cfif>
        <div style="clear:left"></div>           
        <input type="hidden" value="#url.ID#" id="COAID" name="ID">
        <cfif structKeyExists(session, "COAmsg")>
            <div id="message" class="msg-area-success">#session.COAmsg#</div>
            <cfset structDelete(session, "COAmsg")>
        </cfif>
        <table width="100%" border="0" class="data-table" cellspacing="0" cellpadding="0" style="color:##000000;margin-top: 10px;">
            <thead>
                <tr>
                    <th width="5" align="left" valign="top"><img src="images/top-left.gif" alt="" width="5" height="23" style="width:100%"/></th>
                    <th width="29" align="center" valign="middle" class="head-bg">&nbsp;</th>
                    <th width="100" align="center" valign="middle" class="head-bg">Current</th>
                    <th width="100" align="center" valign="middle" class="head-bg">Budget</th>
                    <th width="100" align="center" valign="middle" class="head-bg">1 Year Past</th>
                    <th width="100" align="center" valign="middle" class="head-bg2">2 Year Past</th>
                    <th width="5" align="right" valign="top"><img src="images/top-right.gif" alt="" width="5" height="23" style="width:100%"/></th>
                </tr>
            </thead>
            <tbody style="background-color: #request.qGetSystemSetupOptions.BackgroundColorForContentAccounting#">
                <tr style="cursor: default;height:50px;">
                    <td height="20" class="sky-bg">&nbsp;</td>
                    <td align="right" valign="middle" nowrap="nowrap" class="normal-td" style="padding-right: 5px;"><b>Open Balance</b></td>
                    <td  align="center" valign="middle" nowrap="nowrap" class="normal-td">
                        <input style="width:50%;text-align: right;" class="disabledLoadInputs" value="#DollarFormat(qChartofAccounts.OPEN_CURRENT)#">
                    </td>
                    <td  align="center" valign="middle" nowrap="nowrap" class="normal-td">
                        <input style="width:50%;text-align: right;" class="budgetField" value="#DollarFormat(qChartofAccounts.OPEN_BUDGET)#" id="OPEN_BUDGET" name="OPEN_BUDGET">
                    </td>
                    <td  align="center" valign="middle" nowrap="nowrap" class="normal-td">
                        <input style="width:50%;text-align: right;" class="disabledLoadInputs" value="#DollarFormat(qChartofAccounts.OPEN_1YR)#">
                    </td>
                    <td  align="center" valign="middle" nowrap="nowrap" class="normal-td2">
                        <input style="width:50%;text-align: right;" class="disabledLoadInputs" value="#DollarFormat(qChartofAccounts.OPEN_2YR)#">
                    </td>
                    <td class="normal-td3">&nbsp;</td>
                </tr>
                <cfset FiscalYear = qLMASystemConfig['Fiscal Year']>
                <cfif isdate(FiscalYear)>
                    <cfloop index="i" from="#DateFormat(FiscalYear,'yyyy-mm-dd')#" to="#DateFormat(DateAdd('yyyy',1,FiscalYear),'yyyy-mm-dd')#" step="#createTimeSpan(31, 0, 0, 0)#">
                        <tr style="cursor: default;">
                            <td height="20" class="sky-bg">&nbsp;</td>
                            <cfset month = dateFormat('#i#', "MMM")>
                            <td align="right" valign="middle" nowrap="nowrap" class="normal-td" style="padding-right: 5px;">#dateFormat('#i#', "MMMM")# '#dateFormat('#i#', "YY")#</td>
                            <td  align="center" valign="middle" nowrap="nowrap" class="normal-td">
                                <input style="width:50%;text-align: right;" class="disabledLoadInputs" value="#DollarFormat(Evaluate('qChartofAccounts.#month#_CURRENT'))#">
                            </td>
                            <td  align="center" valign="middle" nowrap="nowrap" class="normal-td">
                                <input style="width:50%;text-align: right;" class="budgetField" value="#DollarFormat(Evaluate('qChartofAccounts.#month#_BUDGET'))#" id="#month#_BUDGET" name="#month#_BUDGET">
                            </td>
                            <td  align="center" valign="middle" nowrap="nowrap" class="normal-td">
                                <input style="width:50%;text-align: right;" class="disabledLoadInputs" value="#DollarFormat(Evaluate('qChartofAccounts.#month#_1YR'))#">
                            </td>
                            <td  align="center" valign="middle" nowrap="nowrap" class="normal-td2">
                                <input style="width:50%;text-align: right;" class="disabledLoadInputs" value="#DollarFormat(Evaluate('qChartofAccounts.#month#_2YR'))#">
                            </td>
                            <td class="normal-td3">&nbsp;</td>
                        </tr>
                    </cfloop>
                <cfelse>
                    <tr><td align="center" colspan="7" height="30"><b style="color:red;font-size: 20px;">Please provide a Fiscal Year Start on accounting settings.</b></td></tr>
                </cfif>
                <tr style="cursor: default;height:50px;">
                    <td height="20" class="sky-bg">&nbsp;</td>
                    <td align="right" valign="middle" nowrap="nowrap" class="normal-td" style="padding-right: 5px;"><b>Ending Balance</b></td>
                    <td  align="center" valign="middle" nowrap="nowrap" class="normal-td">
                        <input style="width:50%;text-align: right;" class="disabledLoadInputs" value="#DollarFormat(qChartofAccounts.END_CURRENT)#">
                    </td>
                    <td  align="center" valign="middle" nowrap="nowrap" class="normal-td">
                        <input style="width:50%;text-align: right;" class="budgetField" value="#DollarFormat(qChartofAccounts.END_BUDGET)#" id="END_BUDGET" name="END_BUDGET"></td>
                    <td  align="center" valign="middle" nowrap="nowrap" class="normal-td">
                        <input style="width:50%;text-align: right;" class="disabledLoadInputs" value="#DollarFormat(qChartofAccounts.END_1YR)#">
                    </td>
                    <td  align="center" valign="middle" nowrap="nowrap" class="normal-td2">
                        <input style="width:50%;text-align: right;" class="disabledLoadInputs" value="#DollarFormat(qChartofAccounts.END_2YR)#">
                    </td>
                    <td class="normal-td3">&nbsp;</td>
                </tr>
            </tbody>
            <tfoot>
                <tr>
                    <td width="5" align="left" valign="top"><img src="images/left-bot.gif" alt="" width="5" height="23" style="width:100%"/></td>
                    <td colspan="5" align="left" valign="middle" class="footer-bg">
                    </td>
                    <td width="5" align="right" valign="top"><img src="images/right-bot.gif" alt="" width="5" height="23" style="width:100%"/></td>
                </tr> 
            </tfoot>   
        </table>
    </cfform>
</cfoutput>

    