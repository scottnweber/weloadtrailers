<cfoutput>
    <cfparam name="form.vendorIdAuto" default="">
    <cfparam name="form.vendorIdAutoValueContainer" default="">
    <cfparam name="form.vendorInfo" default="">
    <cfparam name="form.Contact" default="">
    <cfparam name="form.Phone" default="">
    <cfparam name="form.Fax" default="">
    <cfparam name="form.balance" default="$0.00">
    <cfparam name="form.openinv" default="$0.00">
    <cfinvoke component="#variables.objloadGateway#" method="getSystemSetupOptions" returnvariable="request.qGetSystemSetupOptions" />
    <cfif structKeyExists(form, "OpenInvoices")>
        <cfinvoke component="#variables.objLoadGateway#" method="getCarrierOpenInvoices" VendorID="#form.vendorIdAutoValueContainer#" returnvariable="request.qOpenInvoices" />
    <cfelseif structKeyExists(form, "HistoryInvoices")>
        <cfinvoke component="#variables.objLoadGateway#" method="getCarrierOpenInvoices" VendorID="#form.vendorIdAutoValueContainer#" HistoryInvoices = "1" returnvariable="request.qOpenInvoices" />
    <cfelseif structKeyExists(form, "Payments")>
        <cfinvoke component="#variables.objLoadGateway#" method="getCarrierPayments" VendorID="#form.vendorIdAutoValueContainer#" returnvariable="request.qPayments" />
    <cfelseif structKeyExists(form, "Commodities")>
        <cfinvoke component="#variables.objLoadGateway#" method="getCarrierCommodities" VendorID="#form.vendorIdAutoValueContainer#" returnvariable="request.qCommodities" />
    <cfelseif structKeyExists(form, "CheckNumber")>
        <cfinvoke component="#variables.objLoadGateway#" method="getLMASystemConfig" returnvariable="qLMASystemConfig" />
        <cfinvoke component="#variables.objLoadGateway#"  method="check_fiscal" Trans_Date="#DateFormat(now(),'mm/dd/yyyy')#" returnvariable="resCkFiscal" />
        <cfset form.APDiscountAccount = qLMASystemConfig['AP Discount GL']>
        <cfset form.APGLAccount = qLMASystemConfig['AP GL Account']>
        <cfset form.year_past = resCkFiscal.year_past>
        <cfinvoke component="#variables.objLoadGatewayNew#" method="voidCarrierPayment" frmstruct="#form#" returnvariable="session.PaymentMsg"/> 
        <cflocation url="index.cfm?event=VendorInquiry&#session.URLToken#">
    </cfif>
    <style type="text/css">
        .white-mid{
            background-color: #request.qGetSystemSetupOptions.BackgroundColorForContentAccounting# !important;padding-bottom: 10px;
        }
        .btn{
            background: url(../webroot/images/button-bg.gif) left top repeat-x;
            border: 1px solid ##b3b3b3;
            padding: 0 10px;
            height: 32px;
            font-size: 11px;
            font-weight: bold;
            line-height: 20px;
            text-align: center;
            margin: 2px;
            color: ##599700;
            width: 125px !important;
            cursor: pointer;
            background-size : contain;
        }
        .msg-area-success{
            border: 1px solid ##a4da46;
            padding: 5px 15px;
            font-weight: normal;
            width: 82%;
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
            width: 82%;
            float: left;
            margin-top: 5px;
            margin-bottom:  5px;
            background-color: ##e4b9c6;
            font-weight: bold;
          
    </style>
    <script>
        $(document).ready(function(){
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
                    source: 'searchLMAVendorsAutoFill.cfm?queryType=getVendorsByName',
                    select: function(e, ui) {
                        $('##vendorIdAutoValueContainer').val(ui.item.vendorid);
                        $('##vendorInfo').val("<b><a style='text-decoration:underline;' href=index.cfm?event=addcarrier&iscarrier=1&carrierid="+ui.item.carrierid+" >"+ui.item.company+"</a></b><br/>"+ui.item.address1+"<br/>"+ui.item.city+","+ui.item.state+"<br/>"+ui.item.zip);
                        $('##Contact').val(ui.item.contactPerson);
                        $('##Phone').val(ui.item.phoneNo);
                        $('##fax').val(ui.item.fax);
                        var strHtml ="";
                        strHtml = strHtml + "<label class='field-textarea' style='width:275px'><b><a style='text-decoration:underline;' href=index.cfm?event=addcarrier&iscarrier=1&carrierid="+ui.item.carrierid+" >"+ui.item.company+"</a></b><br/>"+ui.item.address1+"<br/>"+ui.item.city+","+ui.item.state+"<br/>"+ui.item.zip+"</label>";
                        strHtml = strHtml + "<div class='clear'></div>"
                        strHtml = strHtml + "<label>Contact</label><label class='field-text' style='width:275px;'>"+ui.item.contactPerson+"</label>"
                        strHtml = strHtml + "<div class='clear'></div>"
                        strHtml = strHtml + "<label>Phone</label>"
                        strHtml = strHtml + "<label class='cellnum-text' style='width:107px'>"+ui.item.phoneNo+"</label>"
                        strHtml = strHtml + "<label class='space_load'>Fax</label>"
                        strHtml = strHtml + "<label class='cellnum-text' style='width:107px'>"+ui.item.fax+"</label>"
                        strHtml = strHtml + "<div class='clear'></div>"
                        strHtml = strHtml + "<div class='clear'></div>"
                        $('##VendorInfo1').html(strHtml);

                        $('##field-balance').html(ui.item.balance);
                        /*$('##field-openinvoices').html(ui.item.openinvoices);
                        $('##balance').val(ui.item.balance);
                        $('##openinv').val(ui.item.openinvoices);*/
                    }
                })
                $(tag).data("ui-autocomplete")._renderItem = function(ul, item) {
                    return $( "<li>"+item.company+"<br/><b><u>Address</u>:</b> "+ item.address1+"&nbsp;&nbsp;&nbsp;<b><u>City</u>:</b>" + item.city+"&nbsp;&nbsp;&nbsp;<b><u>State</u>:</b> " + item.state+"<br/><b><u>Zip</u>:</b> " + item.zip+"</li>" )
                            .appendTo( ul );
                }
            })
        })

        function showCheckDetails(checkNo){
            $('.checkDetails').hide();
            $('.checkDetails'+checkNo).show('slow');
            
        }

        function openCheckDetails(checkNo){
            $('.checkDetailsInv').hide();
            $('.checkDetailsInv'+checkNo).show('slow');
            
        }

        function validateInquiryForm() {
            if(!$.trim($('##vendorIdAutoValueContainer').val()).length){
                return false;
            }
            
        }
        function voidPayment(ckNo,code){
            if(confirm('Are you sure you want to void this payment?')){
                $('##Vendorcode').val(code);
                $('##CheckNumber').val(ckNo);
                $('##VoidCarrierPaymentForm').submit();
            }
        }
    </script>
    <div class="clear"></div>
    <cfif structKeyExists(session, "PaymentMsg")>
        <div id="message" class="msg-area-#session.PaymentMsg.res#">#session.PaymentMsg.msg#</div>
        <cfset structDelete(session, "PaymentMsg")>
    </cfif>
    <div style="clear:left"></div>
    <div class="white-con-area" style="height: 36px;background-color: ##82bbef;">
        <div style="float: left;">
            <h2 style="color:white;font-weight:bold;margin-left: 12px;">Vendor Inquiry</h2>
        </div>
    </div>
    <cfform id="VoidCarrierPaymentForm" name="VoidCarrierPaymentForm" action="index.cfm?event=VendorInquiry&#session.URLToken#">
        <input type="hidden" id="CheckNumber" name="CheckNumber" value="">
        <input type="hidden" id="Vendorcode" name="Vendorcode" value="">
    </cfform>
    <div style="clear:left"></div>
    <cfform id="vendorInquiryForm" name="vendorInquiryForm" action="index.cfm?event=VendorInquiry&#session.URLToken#" method="post" preserveData="yes" onsubmit="return validateInquiryForm()">
        <div class="white-con-area">
            <div class="white-top"></div>
            <div class="white-mid">
                <div class="form-con">
                    <fieldset class="carrierFields">
                        <label class="bold">Select Vendor*</label>
                        <input name="vendorIdAuto" id="vendorIdAuto" tabindex="1" title="Type text here to display list." style="width:275px" value="#form.vendorIdAuto#"/>
                        <input type="hidden" name="vendorIdAutoValueContainer" id="vendorIdAutoValueContainer" value="#form.vendorIdAutoValueContainer#"/>
                        <input type="hidden" name="vendorInfo" id="vendorInfo" value="#form.vendorInfo#">
                        <input type="hidden" name="Contact" id="Contact" value="#form.Contact#">
                        <input type="hidden" name="Phone" id="Phone" value="#form.Phone#">
                        <input type="hidden" name="fax" id="fax" value="#form.fax#">
                        <input type="hidden" name="balance" id="balance" value="#form.balance#">
                        <input type="hidden" name="openinv" id="openinv" value="#form.openinv#">
                        <div class="clear"></div>
                        <label>Vendor Info</label>
                        <div id="VendorInfo1">
                            <label class="field-textarea" style="width:275px">#form.vendorInfo#</label>
                            <div class="clear"></div>
                            <label >Contact</label>
                            <label class="field-text" style="width:275px">#form.Contact#</label>
                            <div class="clear"></div>
                            <label>Phone</label>
                            <label class="cellnum-text" style="width:107px">#form.Phone#</label>
                            <label class="space_load">Fax</label>
                            <label class="cellnum-text" style="width:107px">#form.fax#</label>
                            <div class="clear"></div>
                            
                        </div>
                    </fieldset>
                </div>
                <div class="form-con" style="width: 200px;">
                    <fieldset class="carrierFields">
                        <div id="VendorInfo2">
                            <label>Terms</label>
                            <label class="field-text" style="width:75px">No Terms</label>
                            <div class="clear"></div>
                            <label>Credit Limit</label>
                            <label class="field-text" style="width:75px">$0.00</label>
                            <div class="clear"></div>
                            <label>Open Invoices</label>
                            <label class="field-text" id="field-openinvoices" style="width:75px">#form.openinv#</label>
                            <div class="clear"></div>
                            <label>Open Credits</label>
                            <label class="field-text" style="width:75px">$0.00</label>
                            <div class="clear"></div>
                            <label>MTD Purchases</label>
                            <label class="field-text" style="width:75px">$0.00</label>
                            <div class="clear"></div>
                            <label>YTD Purchases</label>
                            <label class="field-text" style="width:75px">$0.00</label>
                            <div class="clear"></div>
                            <label>Last Year Purchases</label>
                            <label class="field-text" style="width:75px">$0.00</label>
                            <div class="clear"></div>
                            <label>Balance</label>
                            <label class="field-text" id="field-balance" style="width:75px">#form.balance#</label>
                            <div class="clear"></div>
                        </div>
                    </fieldset>
                </div>
                <div class="form-con" style="width: 160px;">
                    <button tabindex="2" class="btn" name="OpenInvoices" style="height: 32px;background-size: contain;"><b>Open Invoices</b></button>
                    <button tabindex="3" class="btn" name="Payments" style="height: 32px;background-size: contain;"><b>Payments</b></button>
                    <button tabindex="4" class="btn" name="HistoryInvoices" style="height: 32px;background-size: contain;"><b>History Invoices</b></button>
                    <button tabindex="5" class="btn" name="Commodities" style="height: 32px;background-size: contain;"><b>Commodities</b></button>
                </div>
                <div class="clear"></div>
            </div>
        </div>
    </cfform>  
    <div class="clear"></div>
    <cfset pageSize = 30>
    <cfif isdefined("form.pageNo")>
        <cfset rowNum = ((form.pageNo-1)*pageSize)>
    <cfelse>
        <cfset rowNum = 0>
    </cfif>
    <cfif structKeyExists(request, "qOpenInvoices")>
        <table width="86%" border="0" class="data-table" cellspacing="0" cellpadding="0" style="color:##000000;">
            <thead>
                <tr>
                    <th  align="left" valign="top"><img src="images/top-left.gif" alt="" width="5" height="23" /></th>
                    <th  align="center" valign="middle" class="head-bg">&nbsp;</th>
                    <th align="center" valign="middle" class="head-bg">Invoice##</th>
                    <th align="center" valign="middle" class="head-bg">Date</th>
                    <th align="center" valign="middle" class="head-bg">Term##</th>
                    <th align="center" valign="middle" class="head-bg">Description</th>
                    <th align="center" valign="middle" class="head-bg">Reference##</th>
                    <th  align="center" valign="middle" class="head-bg">Amount</th>
                    <th align="center" valign="middle" class="head-bg">Paid</th>
                    <th align="center" valign="middle" class="head-bg">Balance</th>
                    <th align="center" valign="middle" class="head-bg">Discount</th>
                    <th align="center" valign="middle" class="head-bg">Vendor</th>
                    <th align="center" valign="middle" class="head-bg2">Notes</th>
                    <th  align="right" valign="top"><img src="images/top-right.gif" alt="" width="5" height="23" /></th>
                </tr>
            </thead>
            <tbody>
                <cfif request.qOpenInvoices.recordcount>
                    <cfloop query="request.qOpenInvoices">
                        <cfset onHrefClick = "index.cfm?event=addload&loadid=#request.qOpenInvoices.LOADID#&#session.URLToken#">
                        <tr <cfif  request.qOpenInvoices.currentRow mod 2 eq 0>bgcolor="##FFFFFF"<cfelse>bgcolor="##f7f7f7"</cfif>>
                            <td height="20" class="sky-bg">&nbsp;</td>
                            <td class="sky-bg2" valign="middle" align="center">&nbsp;</td>
                            <td  align="left" valign="middle" nowrap="nowrap" class="normal-td"  onclick="location.href='#onHrefClick#'">
                                <a href="#onHrefClick#">#request.qOpenInvoices.TRANS_NUMBER#</a>
                            </td>
                            
                            <td  align="left" valign="middle" nowrap="nowrap" class="normal-td">
                                #DateFormat(request.qOpenInvoices.Date,'mm/dd/yyyy')#
                            </td>

                            <td  align="left" valign="middle" nowrap="nowrap" class="normal-td">
                                #request.qOpenInvoices.term_number#
                            </td>

                            <td  align="left" valign="middle" nowrap="nowrap" class="normal-td">
                                #request.qOpenInvoices.description#
                            </td>

                            <td  align="left" valign="middle" nowrap="nowrap" class="normal-td">
                                #request.qOpenInvoices.Reference#
                            </td>

                            <td  align="right" valign="middle" nowrap="nowrap" class="normal-td">
                                #DollarFormat(request.qOpenInvoices.Total)#
                            </td>

                            <td  align="right" valign="middle" nowrap="nowrap" class="normal-td">
                                <a onclick="openCheckDetails('#request.qOpenInvoices.TRANS_NUMBER#')">#DollarFormat(request.qOpenInvoices.applied)#</a>
                            </td>

                            <td  align="right" valign="middle" nowrap="nowrap" class="normal-td">
                                #DollarFormat(request.qOpenInvoices.Balance)#
                            </td>

                            <td  align="right" valign="middle" nowrap="nowrap" class="normal-td">
                                #DollarFormat(request.qOpenInvoices.discount)#
                            </td>

                            <td valign="middle" nowrap="nowrap" class="normal-td">
                                #form.vendorIdAuto#
                            </td>
                            <td  align="left" valign="middle" nowrap="nowrap" class="normal-td2" title="#request.qOpenInvoices.notes#">
                                #left(request.qOpenInvoices.notes,10)#...
                            </td>
                            <td class="normal-td3">&nbsp;</td>
                        </tr>
                        <!--- <cfif len(trim(request.qOpenInvoices.checknumber))> --->
                            <tr style="display: none;" class="checkDetailsInv checkDetailsInv#request.qOpenInvoices.TRANS_NUMBER#">
                                <td height="20" class="sky-bg">&nbsp;</td>
                                <td class="sky-bg2" valign="middle" align="center">&nbsp;</td>
                                <td colspan="10">
                                    <table width="100%">
                                        <thead>
                                            <tr>
                                                <th style="border-bottom: solid 1px;">Invoice##</th>
                                                <th style="border-bottom: solid 1px;">Check date</th>
                                                <th style="border-bottom: solid 1px;">Disc Amt</th>
                                                <th align="right" style="border-bottom: solid 1px;">Bal. Before Pmt</th>
                                                <th align="right" style="border-bottom: solid 1px;">Applied Amt</th>
                                                <th align="right" style="border-bottom: solid 1px;">Bal After Pmt</th>
                                                <th align="right" style="border-bottom: solid 1px;">Invoice Amt</th>
                                                <th style="border-bottom: solid 1px;">Bank Code</th>
                                                <th style="border-bottom: solid 1px;">Vendor Amt</th>
                                                <th style="border-bottom: solid 1px;">Check##</th>
                                            </tr>
                                        </thead>

                                        <cfset onHrefClick = "index.cfm?event=addload&loadid=#request.qOpenInvoices.LOADID#&#session.URLToken#">
                                        <tr>
                                            <td align="center" onclick="location.href='#onHrefClick#'"><a href="#onHrefClick#">#request.qOpenInvoices.TRANS_NUMBER#</a></td>
                                            <td align="center">#DateFormat(request.qOpenInvoices.checkdate,'mm/dd/yyyy')#</td>
                                            <td align="right">#DollarFormat(request.qOpenInvoices.amountdiscount)#</td>
                                            <td align="right">#DollarFormat(request.qOpenInvoices.Amount)#</td>
                                            <td align="right">#DollarFormat(request.qOpenInvoices.amountpaid)#</td>
                                            <td align="right">
                                                <cfset local.amt = request.qOpenInvoices.Amount - request.qOpenInvoices.amountpaid>
                                                #DollarFormat(local.amt)# 
                                            </td>
                                            <td align="right">#DollarFormat(request.qOpenInvoices.Total)#</td>
                                            <td align="center">#request.qOpenInvoices.checkaccount#</td>
                                            <td align="center">#request.qOpenInvoices.vendorid#</td>
                                            <td align="center">#request.qOpenInvoices.checknumber#</td>
                                        </tr>
                                    </table>
                                </td>
                                <td class="normal-td3">&nbsp;</td>
                            </tr>
                        <!--- </cfif> --->
                    </cfloop>
                <cfelse>
                    <tr>
                        <td height="20" class="sky-bg">&nbsp;</td>
                        <td colspan="12" align="center" style="background-color: #request.qGetSystemSetupOptions.BackgroundColorForContentAccounting# !important;">No Records Found.</td>
                        <td class="normal-td3">&nbsp;</td>
                    </tr>

                </cfif>
           </tbody>
           <tfoot>
                <tr>
                    <td width="5" align="left" valign="top"><img src="images/left-bot.gif" alt="" width="5" height="23" /></td>
                    <td colspan="12" align="left" valign="middle" class="footer-bg">
                        <div class="up-down">
                            <div class="arrow-top"><a href="javascript: tablePrevPage('FindGLTransactionsForm');"><img src="images/arrow-top.gif" alt="" /></a></div>
                            <div class="arrow-bot"><a href="javascript: tableNextPage('FindGLTransactionsForm');"><img src="images/arrow-bot.gif" alt="" /></a></div>
                        </div>
                        <div class="gen-left"><a href="javascript: tablePrevPage('FindGLTransactionsForm');">Prev </a>-<a href="javascript: tableNextPage('FindGLTransactionsForm');"> Next</a></div>
                        <div class="gen-right"><img src="images/loader.gif" alt="" /></div>
                        <div class="clear"></div>
                    </td>
                    <td width="5" align="right" valign="top"><img src="images/right-bot.gif" alt="" width="5" height="23" /></td>
                </tr>  
            </tfoot>   
        </table>
    </cfif>
    <cfif structKeyExists(request, "qPayments")>
        <table width="86%" border="0" class="data-table" cellspacing="0" cellpadding="0" style="color:##000000;">
            <thead>
                <tr>
                    <th  align="left" valign="top"><img src="images/top-left.gif" alt="" width="5" height="23" /></th>
                    <th  align="center" valign="middle" class="head-bg">&nbsp;</th>
                    <th align="center" valign="middle" class="head-bg">Check/Ref##</th>
                    <th align="center" valign="middle" class="head-bg">Date##</th>
                    <th align="center" valign="middle" class="head-bg">Payment Amount</th>
                    <th align="center" valign="middle" class="head-bg" onclick="sortTableBy('EntryDate','FindGLTransactionsForm')">Pay-Type</th>
                    <th align="center" valign="middle" class="head-bg2">&nbsp;</th>
                    <th  align="right" valign="top"><img src="images/top-right.gif" alt="" width="5" height="23" /></th>
                </tr>
            </thead>
            <tbody>
                <cfif request.qPayments.recordcount>
                    <cfloop query="request.qPayments" group="CheckNumber">
                        <tr <cfif  request.qPayments.currentRow mod 2 eq 0>bgcolor="##FFFFFF"<cfelse>bgcolor="##f7f7f7"</cfif>>
                            <td height="20" class="sky-bg">&nbsp;</td>
                            <td class="sky-bg2" valign="middle" align="center">&nbsp;</td>
                            <td  align="left" valign="middle" nowrap="nowrap" class="normal-td" onclick="showCheckDetails('#request.qPayments.CheckNumber#')">
                                <a>#request.qPayments.CheckNumber#</a>
                            </td>
                            <td  align="left" valign="middle" nowrap="nowrap" class="normal-td">
                                #DateFormat(request.qPayments.checkdate,'mm/dd/yyyy')#
                            </td>
                            <td  align="right" valign="middle" nowrap="nowrap" class="normal-td">
                                #DollarFormat(request.qPayments.amount)#
                            </td>
                            <td  align="left" valign="middle" nowrap="nowrap" class="normal-td">
                                <cfif len(trim(request.qPayments.VoidedOn))>VOID<cfelse>P</cfif>
                            </td>
                            <td  align="left" valign="middle" nowrap="nowrap" class="normal-td2">
                                <cfif len(trim(request.qPayments.VoidedOn))>
                                    Voided By : #request.qPayments.VoidedBy#<br>
                                    Voided On : #dateFormat(request.qPayments.VoidedOn,"mm/dd/yyyy")#
                                <cfelse>
                                    <input type="button" name="voidPayment" value="Void" style="width: 50px !important;" onclick="voidPayment('#request.qPayments.CheckNumber#','#request.qPayments.Vendorcode#')">
                                </cfif>
                            </td>
                            <td class="normal-td3">&nbsp;</td>
                        </tr>
                        <!--- <cfloop group="InvoicNumber"> --->
                            <tr style="display: none;" class="checkDetails checkDetails#request.qPayments.CheckNumber#">
                                <td height="20" class="sky-bg">&nbsp;</td>
                                <td class="sky-bg2" valign="middle" align="center">&nbsp;</td>
                                <td colspan="5">
                                    <table width="100%">
                                        <thead>
                                            <tr>
                                                <th style="border-bottom: solid 1px;">Invoice##</th>
                                                <th style="border-bottom: solid 1px;">Check date</th>
                                                <th style="border-bottom: solid 1px;">Disc Amt</th>
                                                <th align="right" style="border-bottom: solid 1px;">Bal. Before Pmt</th>
                                                <th align="right" style="border-bottom: solid 1px;">Applied Amt</th>
                                                <th align="right" style="border-bottom: solid 1px;">Bal After Pmt</th>
                                                <th align="right" style="border-bottom: solid 1px;">Invoice Amt</th>
                                                <th style="border-bottom: solid 1px;">Bank Code</th>
                                                <th style="border-bottom: solid 1px;">Vendor Amt</th>
                                                <th style="border-bottom: solid 1px;">Entered By</th>
                                            </tr>
                                        </thead>
                                        <cfloop group="invoicenumber">
                                            <cfset onHrefClick = "index.cfm?event=addload&loadid=#request.qPayments.LOADID#&#session.URLToken#">
                                            <tr>
                                                <td align="center" onclick="location.href='#onHrefClick#'"><a href="#onHrefClick#">#request.qPayments.invoicenumber#</a></td>
                                                <td align="center">#DateFormat(request.qPayments.checkdate,'mm/dd/yyyy')#</td>
                                                <td align="right">#DollarFormat(request.qPayments.amountdiscount)#</td>
                                                <td align="right">#DollarFormat(request.qPayments.Amount)#</td>
                                                <td align="right">#DollarFormat(request.qPayments.amountpaid)#</td>
                                                <td align="right">
                                                    <cfset local.amt = request.qPayments.Amount - request.qPayments.amountpaid>
                                                    #DollarFormat(local.amt)# 
                                                </td>
                                                <td align="right">#DollarFormat(request.qPayments.Amount)#</td>
                                                <td align="center">#request.qPayments.checkaccount#</td>
                                                <td align="center">#request.qPayments.Vendorcode#</td>
                                                <td align="center">#request.qPayments.EnteredBy#</td>
                                            </tr>
                                        </cfloop>
                                    </table>
                                </td>
                                <td class="normal-td3">&nbsp;</td>
                            </tr>
                        <!--- </cfloop> --->
                    </cfloop>
                <cfelse>
                    <tr>
                        <td height="20" class="sky-bg">&nbsp;</td>
                        <td colspan="6" align="center" style="background-color: #request.qGetSystemSetupOptions.BackgroundColorForContentAccounting# !important;">No Records Found.</td>
                        <td class="normal-td3">&nbsp;</td>
                    </tr>

                </cfif>
           </tbody>
           <tfoot>
                <tr>
                    <td width="5" align="left" valign="top"><img src="images/left-bot.gif" alt="" width="5" height="23" /></td>
                    <td colspan="6" align="left" valign="middle" class="footer-bg">
                        <div class="up-down">
                            <div class="arrow-top"><a href="javascript: tablePrevPage('FindGLTransactionsForm');"><img src="images/arrow-top.gif" alt="" /></a></div>
                            <div class="arrow-bot"><a href="javascript: tableNextPage('FindGLTransactionsForm');"><img src="images/arrow-bot.gif" alt="" /></a></div>
                        </div>
                        <div class="gen-left"><a href="javascript: tablePrevPage('FindGLTransactionsForm');">Prev </a>-<a href="javascript: tableNextPage('FindGLTransactionsForm');"> Next</a></div>
                        <div class="gen-right"><img src="images/loader.gif" alt="" /></div>
                        <div class="clear"></div>
                    </td>
                    <td width="5" align="right" valign="top"><img src="images/right-bot.gif" alt="" width="5" height="23" /></td>
                </tr>  
            </tfoot>   
        </table>
    </cfif>
    <cfif structKeyExists(request, "qCommodities")>
        <table width="86%" border="0" class="data-table" cellspacing="0" cellpadding="0" style="color:##000000;">
            <thead>
                <tr>
                    <th  align="left" valign="top"><img src="images/top-left.gif" alt="" width="5" height="23" /></th>
                    <th  align="center" valign="middle" class="head-bg">&nbsp;</th>
                    <th align="center" valign="middle" class="head-bg">Invoice##</th>
                    <th align="center" valign="middle" class="head-bg">Type</th>
                    <th align="center" valign="middle" class="head-bg">Description</th>
                    <th align="center" valign="middle" class="head-bg">Qty</th>
                    <th align="center" valign="middle" class="head-bg2">Carrier Rate</th>
                    <th  align="right" valign="top"><img src="images/top-right.gif" alt="" width="5" height="23" /></th>
                </tr>
            </thead>
            <tbody>
                <cfif request.qCommodities.recordcount>
                    <cfloop query="request.qCommodities">
                        <cfset onHrefClick = "index.cfm?event=addload&loadid=#request.qCommodities.LOADID#&#session.URLToken#">
                        <tr <cfif  request.qCommodities.currentRow mod 2 eq 0>bgcolor="##FFFFFF"<cfelse>bgcolor="##f7f7f7"</cfif>>
                            <td height="20" class="sky-bg">&nbsp;</td>
                            <td class="sky-bg2" valign="middle" align="center">&nbsp;</td>
                            <td  align="left" valign="middle" nowrap="nowrap" class="normal-td"  onclick="location.href='#onHrefClick#'">
                                <a href="#onHrefClick#">#request.qCommodities.TRANS_NUMBER#</a>
                            </td>
                            <td  align="left" valign="middle" nowrap="nowrap" class="normal-td">
                                #request.qCommodities.UnitName#
                            </td>
                            <td  align="left" valign="middle" nowrap="nowrap" class="normal-td">
                                #request.qCommodities.Description#
                            </td>
                            <td  align="left" valign="middle" nowrap="nowrap" class="normal-td">
                                #request.qCommodities.Qty#
                            </td>
                            <td  align="right" valign="middle" nowrap="nowrap" class="normal-td2">
                                #DollarFormat(request.qCommodities.CarrRate)#
                            </td>
                            <td class="normal-td3">&nbsp;</td>
                        </tr>
                    </cfloop>
                <cfelse>
                    <tr>
                        <td height="20" class="sky-bg">&nbsp;</td>
                        <td colspan="6" align="center" style="background-color: #request.qGetSystemSetupOptions.BackgroundColorForContentAccounting# !important;">No Records Found.</td>
                        <td class="normal-td3">&nbsp;</td>
                    </tr>

                </cfif>
           </tbody>
           <tfoot>
                <tr>
                    <td width="5" align="left" valign="top"><img src="images/left-bot.gif" alt="" width="5" height="23" /></td>
                    <td colspan="6" align="left" valign="middle" class="footer-bg">
                        <div class="up-down">
                            <div class="arrow-top"><a href="javascript: tablePrevPage('FindGLTransactionsForm');"><img src="images/arrow-top.gif" alt="" /></a></div>
                            <div class="arrow-bot"><a href="javascript: tableNextPage('FindGLTransactionsForm');"><img src="images/arrow-bot.gif" alt="" /></a></div>
                        </div>
                        <div class="gen-left"><a href="javascript: tablePrevPage('FindGLTransactionsForm');">Prev </a>-<a href="javascript: tableNextPage('FindGLTransactionsForm');"> Next</a></div>
                        <div class="gen-right"><img src="images/loader.gif" alt="" /></div>
                        <div class="clear"></div>
                    </td>
                    <td width="5" align="right" valign="top"><img src="images/right-bot.gif" alt="" width="5" height="23" /></td>
                </tr>  
            </tfoot>   
        </table>
    </cfif>
</cfoutput>

    