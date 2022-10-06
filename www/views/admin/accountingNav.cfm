<cfparam name="event" default="InvoiceLoads">
<cfoutput>
	<style>

		.nav-with-sub-menu{
			width: 548px;
		    float: left;
		    display: block;
		    padding: 0;
		    margin: 0;
		    margin-top: 3px;
		    font-size: 12px;
		}
		.nav-with-sub-menu .li-has-sub-menu {
		    float: left;
		    display: block;
		    cursor: pointer;
		}
		.nav-with-sub-menu .li-has-sub-menu a.main-menu{
			padding: 0 20px 0 20px;
		    display: block;
		    text-decoration: none;
		    color: ##c1d5ed;
		    background: none;
		    line-height: 22px;
		    float: left;
		    
		}

		.nav-with-sub-menu .li-has-sub-menu a.main-menu.active{
			text-decoration: none;
		    color: ##ffffff;
		    background: ##8abd32;
		}
		.nav-with-sub-menu .li-has-sub-menu a.main-menu:hover{
			text-decoration: none;
		    color: ##ffffff;
		    background: ##8abd32;
		}
		.nav-with-sub-menu .li-has-sub-menu .ul-sub-menu{
			position: absolute;
			display:none;
			margin-top: 22px;
			background: ##283d50;
		}

		.nav-with-sub-menu .li-has-sub-menu .ul-sub-menu li a{
			padding: 0 20px 0 20px;
		    text-decoration: none;
		    color: ##c1d5ed;
		    background: none;
		    line-height: 22px;
		    padding-top: 5px;
    		padding-bottom: 5px;
    		width:100%;
		}
		.nav-with-sub-menu .li-has-sub-menu .ul-sub-menu li:hover{
			text-decoration: none;
		    color: ##ffffff;
		    background: ##8abd32;
		}
		.nav-with-sub-menu .li-has-sub-menu .ul-sub-menu li a:hover{
			text-decoration: none;
		    color: ##ffffff;
		}
		.li-has-sub-menu{
			background-image:  url(images/subnav-libg.gif);background-repeat: no-repeat;background-position: right;
		}
		.li-has-sub-menu:last-child{
			background: none;
		}
	</style>
	<script>
		$(document).ready(function(){
			$('.li-has-sub-menu').mouseover(function(){
				if(!$(this).find('.ul-sub-menu').is(":visible")){
					$(this).find('.ul-sub-menu').show();
				}
			})
			$('.li-has-sub-menu').mouseleave(function(){
				if($(this).find('.ul-sub-menu').is(":visible")){
					$(this).find('.ul-sub-menu').hide();
				}
			});

			$('.ul-sub-menu li').click(function(){
				location.href = $( this ).find( "a" ).attr('href');
			})


			$('.ul-sub-menu li').mouseover(function(){
				$( this ).find( "a" ).css('color','##ffffff');
			})
			$('.ul-sub-menu li').mouseleave(function(){
				$( this ).find( "a" ).css('color','##c1d5ed');
			})

		});
	</script>
	<div class="nav-with-sub-menu" style="width: 890px;">
		<ul>
			<li class="li-has-sub-menu">
				<a class="main-menu <cfif listFindNoCase("InvoiceLoads,CustomerPayments,CreateCustomerInvoice,LMACustomerAgingReport,LMACustomerStatementReport,LMAPrintCashReceipts,CustomerInquiry,VoidCustomerPayment", event)> active </cfif>">Accounts Receivable</a>
					<ul class="ul-sub-menu" style="z-index: 99;">
						<li><a href="index.cfm?event=InvoiceLoads&#Session.URLToken#">Invoice Customer Loads</a></li>
						<li><a href="index.cfm?event=CreateCustomerInvoice&#Session.URLToken#">Create Customer Invoice</a></li>
						<li><a href="index.cfm?event=CustomerPayments&#Session.URLToken#">Post Customer Payments</a></li>
						<li><a href="index.cfm?event=CustomerInquiry&#Session.URLToken#">Customer Inquiry</a></li>
						<li><a href="index.cfm?event=VoidCustomerPayment&#Session.URLToken#">Void Customer Payment</a></li>
						<li style="border-top: solid 1px ##fff;"><img src="images/reportIcon.ico" style="margin-left: 4px;margin-top: 2px;float: left;"><a href="index.cfm?event=LMACustomerAgingReport&#Session.URLToken#" style="padding-left: 0;padding-top: 0;">Print Customer Aging</a></li>
						<li><img src="images/reportIcon.ico" style="margin-left: 4px;margin-top: 2px;float: left;"><a href="index.cfm?event=LMACustomerStatementReport&#Session.URLToken#" style="padding-left: 0;padding-top: 0;">Print/Email Customer Statement</a></li>
						<li><img src="images/reportIcon.ico" style="margin-left: 4px;margin-top: 2px;float: left;"><a href="index.cfm?event=LMAPrintCashReceipts&#Session.URLToken#" style="padding-left: 0;padding-top: 0;">Print Customer Payments</a></li>
					</ul>
			</li>
			<li class="li-has-sub-menu">
				<a class="main-menu <cfif listFindNoCase("InvoiceCarrierLoads,CreateVendorInvoice,InvoiceToPay,PrintChecks,LMAVendorAgingReport,LMAInvoicesPickedtoPay,VendorInquiry,PostInvoicePayment,VoidInvoicePayment,InvoicePaymentReport", event)> active </cfif>">Accounts Payable</a>
					<ul class="ul-sub-menu" style="z-index: 99;">
						<li><a href="index.cfm?event=InvoiceCarrierLoads&#Session.URLToken#">Invoice Carrier Loads</a></li>
						<li><a href="index.cfm?event=CreateVendorInvoice&#Session.URLToken#">Create Vendor Invoice</a></li>
						<li><a href="index.cfm?event=InvoiceToPay&#Session.URLToken#">Pick Invoices To Pay</a></li>
						<li><a href="index.cfm?event=VendorInquiry&#Session.URLToken#">Vendor Inquiry</a></li>
						<li><a href="index.cfm?event=PostInvoicePayment&#Session.URLToken#">Post Invoice Payment</a></li>
						<li><a href="index.cfm?event=VoidInvoicePayment&#Session.URLToken#">Void Invoice Payment</a></li>
						<li style="border-top: solid 1px ##fff;"><img src="images/reportIcon.ico" style="margin-left: 4px;margin-top: 2px;float: left;"><a href="index.cfm?event=PrintChecks&#Session.URLToken#" style="padding-left: 0;padding-top: 0;">Print Checks</a></li>
						<li><img src="images/reportIcon.ico" style="margin-left: 4px;margin-top: 2px;float: left;"><a href="index.cfm?event=LMAVendorAgingReport&#Session.URLToken#" style="padding-left: 0;padding-top: 0;">Print Vendor Aging</a></li>
						<li><img src="images/reportIcon.ico" style="margin-left: 4px;margin-top: 2px;float: left;"><a href="index.cfm?event=InvoicePaymentReport&#Session.URLToken#" style="padding-left: 0;padding-top: 0;">Invoice Payment Report</a></li>
						<li><img src="images/reportIcon.ico" style="margin-left: 4px;margin-top: 2px;float: left;"><a href="index.cfm?event=LMAInvoicesPickedtoPay&#Session.URLToken#" style="padding-left: 0;padding-top: 0;">Invoices Picked to Pay</a></li>
					</ul>
			</li>
			<li class="li-has-sub-menu">
				<a class="main-menu <cfif listFindNoCase("ListChartofAccounts,ChartofAccounts,FindGLTransactions,BankAccounts,LMAPrintTrialBalance,LMAPrintIncomeStatement,LMAPrintBalanceSheet,JournalEntry,PostJournalEntry,ReverseJournalEntry,Departments,AccountDepartments,LMAPrintLedgerReport", event)> active </cfif>">General Ledger</a>
					<ul class="ul-sub-menu" style="z-index: 99;">
						<li><a href="index.cfm?event=ListChartofAccounts&#Session.URLToken#">Chart of Accounts</a></li>
						<li><a href="index.cfm?event=JournalEntry&#Session.URLToken#">Journal Entry</a></li>
						<li><a href="index.cfm?event=FindGLTransactions&#Session.URLToken#">Find G/L Transactions</a></li>
						<li><a href="index.cfm?event=BankAccounts&#Session.URLToken#">Bank Accounts</a></li>
						<li><a href="index.cfm?event=Departments&#Session.URLToken#">Departments</a></li>
						<li style="border-top: solid 1px ##fff;"><img src="images/reportIcon.ico" style="margin-left: 4px;margin-top: 2px;float: left;"><a href="index.cfm?event=LMAPrintTrialBalance&#Session.URLToken#" style="padding-left: 0;padding-top: 0;">Print Trial Balance</a></li>
						<li><img src="images/reportIcon.ico" style="margin-left: 4px;margin-top: 2px;float: left;"><a href="index.cfm?event=LMAPrintIncomeStatement&#Session.URLToken#" style="padding-left: 0;padding-top: 0;">Print Income Statement</a></li>
						<li><img src="images/reportIcon.ico" style="margin-left: 4px;margin-top: 2px;float: left;"><a href="index.cfm?event=LMAPrintBalanceSheet&#Session.URLToken#" style="padding-left: 0;padding-top: 0;">Print Balance Sheet</a></li>
						<li><img src="images/reportIcon.ico" style="margin-left: 4px;margin-top: 2px;float: left;"><a href="index.cfm?event=LMAPrintLedgerReport&#Session.URLToken#" style="padding-left: 0;padding-top: 0;">Print Ledger Report</a></li>
					</ul>
			</li>
			<li class="li-has-sub-menu">
				<a class="main-menu <cfif listFindNoCase("LMASettings,PaymentTerms,addLMAPaymentTerms,GeneralLedgerFinancialSetup,GeneralLedgerBalanceSheetSetup,OpenNewYear,GLRecalculate", event)> active </cfif>">Settings</a>
					<ul class="ul-sub-menu" style="z-index: 99;">
						<li><a href="index.cfm?event=LMASettings&#Session.URLToken#">General Ledger Integration</a></li>
						<li><a href="index.cfm?event=PaymentTerms&#Session.URLToken#">Payment Terms</a></li>
						<li><a href="index.cfm?event=GeneralLedgerFinancialSetup&#Session.URLToken#">G/L Income Statement Setup</a></li>
						<li><a href="index.cfm?event=GeneralLedgerBalanceSheetSetup&#Session.URLToken#">G/L Balance Sheet Setup</a></li>
						<li><a href="index.cfm?event=OpenNewYear&#Session.URLToken#">Open New Year</a></li>
						<li><a href="index.cfm?event=GLRecalculate&#Session.URLToken#">G/L Recalculate</a></li>
					</ul>
			</li>
		</ul>
		<div class="clear"></div>
	</div>
	<div class="below-navright" id="helpLink" style="padding-top: 4px;width: 30px;">
	</div>
	<div style="float:right;margin-right: -100px;margin-top: -59px;"><a href="index.cfm?event=feedback&#Session.URLToken#"><img src="images/support.png" width="100px" border="0"></a></div>
<div style="float:right;margin-top: -57px;"><a href="javascript:void(0);" onclick="window.open('index.cfm?event=postNote&#session.URLToken#','Map','height=600,width=800');"><img src="images/postedNoteIcon.png" width="100px" border="0"></a></div>
</cfoutput>