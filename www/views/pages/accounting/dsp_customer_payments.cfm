<cfparam name="sortorder" default="desc">
<cfparam name="sortby"  default="">
<cfparam name="searchText"  default=" ">
<cfparam name="pageNo"  default="1">
<cfoutput>
    <cfinvoke component="#variables.objloadGateway#" method="getSystemSetupOptions" returnvariable="request.qGetSystemSetupOptions" />
    <cfif structKeyExists(form, "PostPayment")>
        <cfinvoke component="#variables.objLoadGateway#" method="getLMASystemConfig" returnvariable="qLMASystemConfig" />
        <cfinvoke component="#variables.objLoadGateway#"  method="check_fiscal" Trans_Date="#form.PaymentDate#" returnvariable="resCkFiscal" />
        <cfset ARGLAccount = qLMASystemConfig['AR GL Account']>
        <cfset DepositClearingAccount = qLMASystemConfig['Chk_clearing']>

        <cfif NOT len(trim(ARGLAccount)) OR NOT len(trim(DepositClearingAccount))>
            <cfset session.PaymentMsg.res = 'error'>
            <cfset session.PaymentMsg.msg = "No account number has been setup for this transaction. Please correct this and try again.">
        <cfelseif resCkFiscal.res eq 'error'>
            <cfset session.PaymentMsg = resCkFiscal>
        <cfelse>
            <cfset form.year_past = resCkFiscal.year_past>
            <cfset form.DepositClearingAccount = DepositClearingAccount>
            <cfset form.ARGLAccount = ARGLAccount>
            <cfinvoke frmStruct="#form#" component="#variables.objLoadGateway#" method="LMAAccountsReceivablePayment" returnvariable="resp"/>
                <cfset session.PaymentMsg = resp>
        </cfif>
        <cflocation url="index.cfm?event=CustomerPayments&#session.URLToken#">
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
        .head-bg-lma{
            background: none;
            text-align: left;
            border-right:groove 1px gray;
            border-bottom:groove 1px gray;
            padding-left: 5px;
            height:auto;
        }
        .normal-td-lma{
            text-align: left;
            border-right:groove 1px gray;
            border-bottom:none;
            padding-left: 5px;
        }
        .right0{
            border-right:none;
        }
        ##tr_loader{
            height:150px;
        }
        .msg-area-success{
            border: 1px solid ##a4da46;
            padding: 5px 15px;
            font-weight: normal;
            width: 97%;
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
            width: 97%;
            float: left;
            margin-top: 5px;
            margin-bottom:  5px;
            background-color: ##e4b9c6;
            font-weight: bold;
            font-style: italic;
        }
        .reportsSubHeading{
            color: ##7e7e7e;
            padding: 0px 0 10px 10px;
            margin: 0;
            font-size: 14px;
            font-weight: normal;
            border-bottom: 1px solid ##77463d !important;
            margin-bottom: 5px !important;
        }
    </style>
    <script>
        function sortTable(n) {
            var table, rows, switching, i, x, y, shouldSwitch, dir, switchcount = 0;
            table = document.getElementById("myTable2");
            switching = true;
            // Set the sorting direction to ascending:
            dir = "asc";
            /* Make a loop that will continue until
            no switching has been done: */
            while (switching) {
                // Start by saying: no switching is done:
                switching = false;
                rows = table.rows;
                /* Loop through all table rows (except the
                first, which contains table headers): */
                for (i = 1; i < (rows.length - 2); i++) {
                    // Start by saying there should be no switching:
                    shouldSwitch = false;
                    /* Get the two elements you want to compare,
                    one from current row and one from the next: */
                    x = rows[i].getElementsByTagName("td")[n];
                    y = rows[i + 1].getElementsByTagName("td")[n];
                    /* Check if the two rows should switch place,
                    based on the direction, asc or desc: */
                    if (dir == "asc") {
                        if (x.innerHTML.toLowerCase() > y.innerHTML.toLowerCase()) {
                        // If so, mark as a switch and break the loop:
                        shouldSwitch = true;
                        break;
                    }
                    } else if (dir == "desc") {
                        if (x.innerHTML.toLowerCase() < y.innerHTML.toLowerCase()) {
                            // If so, mark as a switch and break the loop:
                            shouldSwitch = true;
                            break;
                            }
                    }
                }
                if (shouldSwitch) {
                    /* If a switch has been marked, make the switch
                    and mark that a switch has been done: */
                    rows[i].parentNode.insertBefore(rows[i + 1], rows[i]);
                    switching = true;
                    // Each time a switch is done, increase this count by 1:
                    switchcount ++;
                } else {
                    /* If no switching has been done AND the direction is "asc",
                    set the direction to "desc" and run the while loop again. */
                    if (switchcount == 0 && dir == "asc") {
                        dir = "desc";
                        switching = true;
                    }
                }
            }

            $('table > tbody  > tr').each(function(index, tr) { 
               console.log(index);
               console.log(tr);
            });
                        
        }

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
                    source: 'searchLMACustomersAutoFill.cfm?&companyid=#session.companyid#',
                    select: function(e, ui) {
                        $('##sortby').val( '' );
                        $('##sortorder').val( '' );
                        $('##CompanyName').val( ui.item.name );
                        $(this).val( ui.item.customercode );
                        $('##customerIDContainer').val(ui.item.customerid);
                        if(ui.item.consolidateinvoices == 1){
                            $('##ConsolidationBlock').show();
                        }
                        else{
                            $('##ConsolidationBlock').hide();
                        }
                        loadContent('TRANS_NUMBER');
                        return false;
                    }
                });
                $(tag).data("ui-autocomplete")._renderItem = function(ul, item) {
                    return $( "<li><b><u>ID:</u></b>"+item.customercode+"&nbsp;&nbsp;&nbsp;<b><u>Company:</u></b> "+ item.name+"<br><b><u>City</u>:</b>" + item.city+"&nbsp;&nbsp;&nbsp;<b><u>State</u>:</b> " + item.state+"&nbsp;&nbsp;&nbsp;<b><u>Invoices</u>:</b> " + item.balance+"<hr></li>" )
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
                        $('##sortby').val( '' );
                        $('##sortorder').val( '' );
                        $(this).val( ui.item.name );
                        $('##cutomerIdAuto').val( ui.item.customercode );
                        $('##customerIDContainer').val(ui.item.customerid);
                        if(ui.item.consolidateinvoices == 1){
                            $('##ConsolidationBlock').show();
                        }
                        else{
                            $('##ConsolidationBlock').hide();
                        }
                        loadContent('TRANS_NUMBER');
                        return false;
                    }
                });
                $(tag).data("ui-autocomplete")._renderItem = function(ul, item) {
                    return $( "<li><b><u>ID:</u></b>"+item.customercode+"&nbsp;&nbsp;&nbsp;<b><u>Company:</u></b> "+ item.name+"<br><b><u>City</u>:</b>" + item.city+"&nbsp;&nbsp;&nbsp;<b><u>State</u>:</b> " + item.state+"&nbsp;&nbsp;&nbsp;<b><u>Invoices</u>:</b> " + item.balance+"<hr></li>" )
                            .appendTo( ul );
                }
            });
        })

        function loadContent(sortby){
            var customerid = $('##customerIDContainer').val();
            var ConsolidationNo = $('##ConsolidationNo').val(); 
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
                url     : "../gateways/loadgateway.cfc?method=getLMAInvoices",
                data    : {customerid : customerid, dsn:"#application.dsn#", sortby : sortby, sortorder:sortorder, companyid:'#session.companyid#',ConsolidationNo:ConsolidationNo},
                success :function(data){
                    $('##data-content').html(data);
                },
                beforeSend:function() {
                    $('##data-content ').html('<tr><td height="20" class="sky-bg">&nbsp;</td><td colspan="10" align="center" valign="middle" nowrap="nowrap" class="normal-td2"><img src="images/loadDelLoader.gif" style="margin-top: 25px;"><br>Please wait...</td><td class="normal-td3">&nbsp;</td></tr>');
                },
            });
        }

        function getCheckBalance(){
            var checkAmount = parseFloat($('##checkAmount').val().replace(/[$,]/g, ''));
            if(checkAmount>0){
                $(".amtApplied").each(function(){
                    var id=$(this).attr('id').split('_')[1];
                    var amt = parseFloat($(this).val().replace(/[$,]/g, '')); 
                    checkAmount = checkAmount - amt;

                });
            }
            return checkAmount;
        }

        function amountApplied(RowID,ev){
            if(ev == 'click'){
                var clickedOrgAmt = parseFloat($('##amtApplied_'+RowID).data('amt'));
                var clickedAppAmt = parseFloat($('##amtApplied_'+RowID).val().replace(/[$,]/g, ''));
                if(clickedAppAmt == 0){
                    var clickedRowVal = getCheckBalance();
                    if(clickedRowVal>clickedOrgAmt){
                        clickedRowVal = clickedOrgAmt; 
                    }
                }
                else{
                    var clickedRowVal = 0;
                    $('##discount_'+RowID).val(clickedRowVal);
                    formatDollarNegative(clickedRowVal, 'discount_'+RowID)
                }
                $('##amtApplied_'+RowID).val(clickedRowVal);
                formatDollarNegative(clickedRowVal, 'amtApplied_'+RowID)
            }
            else{
                var changedOrgAmt = parseFloat($('##amtApplied_'+RowID).data('amt'));
                var changedAppAmt = parseFloat($('##amtApplied_'+RowID).val().replace(/[$,]/g, ''));
                if(isNaN(changedAppAmt)){
                    changedAppAmt = 0;
                    $('##amtApplied_'+RowID).val('$0.00');
                }
                if(changedAppAmt<changedOrgAmt){
                    var changedDiscAmt = changedOrgAmt - changedAppAmt;
                    $('##discount_'+RowID).val(changedDiscAmt);
                    formatDollarNegative(changedDiscAmt, 'discount_'+RowID)
                }
                $('##amtApplied_'+RowID).val(changedAppAmt);
                formatDollarNegative(changedAppAmt, 'amtApplied_'+RowID)
            }
            calculateBalance();
        }

        function discountApplied(RowID,ev){
            if(ev == 'click'){
                var clickedDiscAmt = parseFloat($('##discount_'+RowID).val().replace(/[$,]/g, ''));
                if(clickedDiscAmt==0){
                    var clickedOrgAmt = parseFloat($('##amtApplied_'+RowID).data('amt'));
                    var clickedAppAmt = parseFloat($('##amtApplied_'+RowID).val().replace(/[$,]/g, ''));
                    var clickedRowVal = clickedOrgAmt - clickedAppAmt;
                }
                else{
                    var clickedRowVal = 0;
                }
                $('##discount_'+RowID).val(clickedRowVal);
                formatDollarNegative(clickedRowVal, 'discount_'+RowID)
            }
            else{
                var changedDiscAmt = parseFloat($('##discount_'+RowID).val().replace(/[$,]/g, ''));
                if(isNaN(changedDiscAmt)){
                    changedDiscAmt = 0;
                }

                $('##discount_'+RowID).val(changedDiscAmt);
                formatDollarNegative(changedDiscAmt, 'discount_'+RowID)
            }
            calculateBalance();

        }

        function calculateBalance(){
            var checkAmount = parseFloat($('##checkAmount').val().replace(/[$,]/g, ''));
            if(isNaN(checkAmount)){
                checkAmount = 0;
                $('##checkAmount').val('$0.00');
            }
            formatDollarNegative(checkAmount, 'checkAmount');
            var TotalAppliedPayment = 0;
            var TotalRemaining = 0;
            $(".amtApplied").each(function(){
                var rowID = $(this).attr('id').split('_')[1]
                var OrgRowAmt = parseFloat($(this).data('amt'));
                var AppRowAmt = parseFloat($(this).val().replace(/[$,]/g, ''));
                var DisRowAmt = parseFloat($('##discount_'+rowID).val().replace(/[$,]/g, ''));
                var RemRowAmt = OrgRowAmt - AppRowAmt - DisRowAmt;
                TotalAppliedPayment = TotalAppliedPayment + AppRowAmt;
                TotalRemaining = TotalRemaining + RemRowAmt;
                $('##remaining_'+rowID).html(formatDollar(RemRowAmt));
                $('##rembalance_'+rowID).val(RemRowAmt);
            });
            var UnusedAmount = checkAmount - TotalAppliedPayment; 
            if(UnusedAmount<0){
                UnusedAmount = 0;
            }
            $('##UnusedAmount').val(UnusedAmount);
            $('##TotalRemaining').val(TotalRemaining);
            $('##TotalAppliedPayment').val(TotalAppliedPayment);
            formatDollarNegative(UnusedAmount, 'UnusedAmount');
            formatDollarNegative(TotalRemaining, 'TotalRemaining');
            formatDollarNegative(TotalAppliedPayment, 'TotalAppliedPayment');

        }

        function formatDollar(num) {   
            var DecimalSeparator = Number("1.2").toLocaleString().substr(1,1);
            var AmountWithCommas = num.toLocaleString();
            var arParts = String(AmountWithCommas).split(DecimalSeparator);
            var intPart = arParts[0];
            var decPart = (arParts.length > 1 ? arParts[1] : '');
            decPart = (decPart + '00').substr(0,2);
            if((intPart + DecimalSeparator + decPart )[0] != "$") {
                var returnvalue = '$' + intPart + DecimalSeparator + decPart;
            } else {
                var returnvalue = intPart + DecimalSeparator + decPart;
            }
            return returnvalue.replace('$-','-$');
        }
        function validatePayment(){
            var unusedamt = parseFloat($('##UnusedAmount').val().replace(/[$,]/g, ''));
            var chkamt = parseFloat($('##checkAmount').val().replace(/[$,]/g, ''));
            var TotalAppliedPayment = parseFloat($('##TotalAppliedPayment').val().replace(/[$,]/g, ''));
            if($.trim($('##cutomerIdAuto').val().length)==0) {
                alert("Please enter Customer code");
                return false;
            }
            if(unusedamt>0){
                if(confirm('You have not applied the full payment amount.\nDo you want to post the payment and create an open credit?')){
                    $('##createOpenCredit').val(1);
                }
                else{
                    $('##createOpenCredit').val(0);
                }
            }
            if(!$.trim($('##checknumber').val()).length){
                if(!confirm('You did not enter a check number.\nWould you like to use a system generated reference number instead?')){
                    $('##checknumber').focus()
                    return false;
                }
            }
            if(TotalAppliedPayment>chkamt){
                alert("You have applied more than the payment amount.\nPlease fix this before posting the payment.");
                return false;
            }
            return confirm('Are you sure you want to post this payment?');
        }
    </script>
    <div class="white-con-area" style="height: 36px;background-color: ##82bbef;width:100%;">
        <div style="float: left;">
            <h2 style="color:white;font-weight:bold;margin-left: 12px;">Post Customer Payment</h2>
        </div>
    </div>
    <div style="clear:left"></div>
    <cfform id="RecordPaymentsForm" name="RecordPaymentsForm" action="index.cfm?event=CustomerPayments&#session.URLToken#" method="post" preserveData="yes" onsubmit="return validatePayment();">
        <div class="search-panel" style="width:100%;">
            <div class="form-search" style="width:100%;background-color: #request.qGetSystemSetupOptions.BackgroundColorForContentAccounting# !important;padding-bottom: 10px;">
                <cfinput id="sortorder" name="sortOrder" value="" type="hidden">
                <cfinput id="sortby" name="sortby" value="" type="hidden">
                <cfinput id="createOpenCredit" name="createOpenCredit" value="0" type="hidden">
                <fieldset style="width:70%;padding:5px;float:left;height: 46px;">
                    <h2 class="reportsSubHeading">Customer Lookup</h2>
                    <div style="float:left">
                        <label style="font-weight: bold;width:87px;margin-left: 20px;">Customer Code:</label>
                        <input class="sm-input" id="cutomerIdAuto" name="" value="" type="text" style="width:140px !important;" placeholder ="Type here for lookup." tabindex="1" />
                        <input type="hidden" value="" id="customerIDContainer">
                    </div>
                    <div style="float:left">
                        <label style="font-weight: bold;width:75px;margin-left: 20px;">Company:</label>
                        <input class="sm-input" id="CompanyName" name="CompanyName" value="" type="text" style="width:250px !important;"  placeholder ="Type here for lookup." tabindex="1"/>
                    </div>
                </fieldset>
                <fieldset style="width:14%;padding:5px;float:left;margin-left: 10px;">
                    <h2 class="reportsSubHeading">Open Balances</h2>
                    <div style="text-align: center;">
                        <b>Invoices: $0.00</b><br>
                        <b>Credits: $0.00</b>
                    </div>
                </fieldset>
                <fieldset style="width:70%;padding:5px;float:left;margin-top: 10px;">
                    <h2 class="reportsSubHeading"></h2>
                    <div style="float:left">
                        <label style="width:77px;margin-left: 20px;">Payment Date:</label>
                        <input tabindex="2"  class="sm-input datefield" id="PaymentDate" name="PaymentDate"  onchange="checkDateFormatAll(this);" value="#DateFormat(now(),'mm/dd/yyyy')#" type="text" style="width:83px !important;"/><br>
                        <label style="width:77px;margin-left: 20px;">Entered By:</label>
                        <input tabindex="5"  class="sm-input"  id="EnteredBy" name="EnteredBy" value="#session.adminusername#" type="text" style="width:100px !important;"/>
                    </div>
                    <div style="float:left">
                        <label style="width:77px;margin-left: 20px;">Check Amt:</label>
                        <input  tabindex="3" class="sm-input" id="checkAmount" name="checkAmount" value="$0.00" type="text" style="width:93px !important;text-align: right;" onchange="calculateBalance()"/><br>
                        <label style="width:77px;margin-left: 20px;">Pay Type:</label>
                        <select style="width:100px !important;" tabindex="6">
                            <option>Cash</option>
                            <option>Check</option>
                            <option>Credit Card</option>
                            <option>Other</option>
                        </select>
                    </div>
                    <div style="float:left">
                        <label style="width:77px;margin-left: 20px;">Check ##:</label>
                        <input tabindex="4" maxlength="100" class="sm-input" id="checknumber" name="checknumber" value="" type="text" style="width:125px !important;" /><br>
                        <label style="width:77px;margin-left: 20px;">Description:</label>
                        <input maxlength="100" class="sm-input" id="Description" name="Description" value="Payment Received" type="text" style="width:125px !important;" tabindex="7" />
                    </div>
                </fieldset>
                <fieldset id="ConsolidationBlock" style="width:25%;padding:5px;float:left;margin-left: 10px;margin-top: 10px;display: none;">
                    <h2 class="reportsSubHeading"></h2>
                    <div style="text-align: center;">
                        <label style="width:77px;margin-left: 20px;">Consolidation##</label>
                        <input class="sm-input" id="ConsolidationNo" name="ConsolidationNo" value="" type="text" style="width:125px !important;" tabindex="8" onchange="loadContent('TRANS_NUMBER')" />
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
    	<cfset pageSize = 30>
        <cfif isdefined("form.pageNo")>
            <cfset rowNum = ((form.pageNo-1)*pageSize)>
        <cfelse>
            <cfset rowNum = 0>
        </cfif>

        <table width="100%" border="0" id="myTable2" class="data-table" cellspacing="0" cellpadding="0" style="color:##000000;">
            <thead>
                <tr>
                    <th width="5" align="left" valign="top"><img src="images/top-left.gif" alt="" width="5" height="23" /></th>
                    <th width="29" align="center" valign="middle" class="head-bg">&nbsp;</th>
                    <th width="220" align="center" valign="middle" class="head-bg" onclick="sortTable(2)">Date</th>
                    <th width="105" align="center" valign="middle" class="head-bg" onclick="sortTable(3)">Type</th>
                    <th width="120" align="center" valign="middle" class="head-bg" onclick="sortTable(4)">Reference</th>
                    <th width="120" align="center" valign="middle" class="head-bg" onclick="sortTable(5)">Amount</th>
                    <th width="120" align="center" valign="middle" class="head-bg" onclick="sortTable(6)">Balance</th>
        	        <th width="120" align="center" valign="middle" class="head-bg" onclick="sortTable(7)">Description</th>
                    <th width="120" align="center" valign="middle" class="head-bg">Amt. Applied</th>
                    <th width="120" align="center" valign="middle" class="head-bg">Discount</th>
                    <th width="120" align="center" valign="middle" class="head-bg2" onclick="sortTable(10)">Remaining</th>
                    <th width="5" align="right" valign="top"><img src="images/top-right.gif" alt="" width="5" height="23" /></th>
                </tr>
            </thead>
            <tbody id="data-content">
                <tr>
                    <td height="20" class="sky-bg">&nbsp;</td>
                    <td colspan="10" align="center" valign="middle" nowrap="nowrap" class="normal-td2">
                        No Records.
                    </td>
                    <td class="normal-td3">&nbsp;</td>
                </tr>
            </tbody>
            <tfoot>
                <tr>
                    <td width="5" align="left" valign="top"><img src="images/left-bot.gif" alt="" width="5" height="23" /></td>
                    <td colspan="10" align="left" valign="middle" class="footer-bg">
                    </td>
                    <td width="5" align="right" valign="top"><img src="images/right-bot.gif" alt="" width="5" height="23" /></td>
                </tr> 
            </tfoot>   
        </table>
        <fieldset style="width:99%;padding:5px;float:left;background-color: #request.qGetSystemSetupOptions.BackgroundColorForContentAccounting# !important;">
            <div style="float:left;margin-left: 100px;">
                <label style="width:77px;margin-left: 20px;"><b>Unused Amount:</b></label>
                <input class="sm-input" id="UnusedAmount" readonly name="UnusedAmount" type="text" style="width:83px !important;text-align: right;" value="$0.00" />
            </div>
            <div style="float:left">
                <label style="width:77px;margin-left: 20px;"><b>Total Applied Payment:</b></label>
                <input class="sm-input" readonly id="TotalAppliedPayment" name="TotalAppliedPayment" type="text" style="width:83px !important;text-align: right;" value="$0.00"/>
                <input class="sm-input" readonly id="TotalRemaining" name="TotalRemaining" type="text" style="width:83px !important;text-align: right;" value="$0.00"/>
                <button class="btn" name="PostPayment" tabindex="9"><b>Post Payment</b></button>
            </div>
        </fieldset>
    </cfform>  
</cfoutput>

    