<cfoutput>
	<cfset local.dsn = trim(listFirst(cgi.SCRIPT_NAME,'/'))>
	<cfquery name="qGetSystemConfig" datasource="#local.dsn#">
	    SELECT companyName FROM Companies  WHERE CompanyID = <cfqueryparam value="#session.companyid#" cfsqltype="cf_sql_varchar">
	</cfquery>

	<cfquery name="qInvoicesPickedToPay" datasource="#local.dsn#">
	    SELECT * FROM [LMA Accounts Payable Check Transaction File]  APCT
	    INNER JOIN Carriers C ON C.VendorID = APCT.VendorCode
	    INNER JOIN [LMA Check Register Setup] LCRS ON LCRS.ID = APCT.checkaccount
	    WHERE APCT.CompanyID =  <cfqueryparam value="#session.companyid#" cfsqltype="cf_sql_varchar">
	    AND C.carrierName >= <cfqueryparam value="#url.carrierLimitFrom#" cfsqltype="cf_sql_varchar">
		AND C.carrierName <= <cfqueryparam value="#url.carrierLimitTo#" cfsqltype="cf_sql_varchar">
		<cfif len(trim(url.AccountFrom))>
			AND LCRS.[account code] >= <cfqueryparam value="#url.AccountFrom#" cfsqltype="cf_sql_integer">
		</cfif>
		<cfif len(trim(url.AccountTo))>
			AND LCRS.[account code] <= <cfqueryparam value="#url.AccountTo#" cfsqltype="cf_sql_integer">
		</cfif>
		ORDER BY LCRS.[Account Name],C.CarrierName,APCT.InvoiceNumber
	</cfquery>


	<cfset fileName = "Invoices Picked To Pay Date-#DateFormat(Now(),'mm.dd.yyyy')#.pdf">
	<cfheader name="Content-Disposition" value="inline; filename=#fileName#">
	<cfdocument format="PDF" name="InvoicesPickedToPay" margintop="1">
		<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
	    <HTML xmlns="http://www.w3.org/1999/xhtml">
	        <HEAD>
	            <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
	            <TITLE>Load Manager TMS</TITLE>
	        </HEAD> 
	        <BODY style="font-family: 'Arial';">
	        	<cfdocumentitem type="header">
	        		<table width="100%" style="font-family: 'Arial';margin-top: 5px;">
	        			<tr>
	        				<td width="20%" align="right">
	        				</td>
	        				<td width="30%" align="left">
	        					<h3>Invoices Picked To Pay - #url.reportType#</h3>
	        					<h3>#qGetSystemConfig.companyName#</h3>
	        				</td>
	        				<td width="50%" align="right" style="font-size: 10px;padding-left: 10px;">
	        					<table style="font-size: 13px;" cellspacing="0" cellpadding="0" width="100%">
	        						<tr>
	        							<td align="right" width="50%"><b>Vendor From: </b></td>
	        							<td>#url.carrierLimitFrom#</td>
	        						</tr>
	        						<tr>
	        							<td align="right"><b>To: </b></td>
	        							<td>#url.carrierLimitTO#</td>
	        						</tr>
	        						<tr>
	        							<td align="right" width="50%"><b>Account From: </b></td>
	        							<td>#url.AccountFrom#</td>
	        						</tr>
	        						<tr>
	        							<td align="right"><b>To: </b></td>
	        							<td>#url.AccountTO#</td>
	        						</tr>
	        					</table>
	        				</td>
	        			</tr>
	        		</table>
	        	</cfdocumentitem>
	        	<cfif qInvoicesPickedToPay.recordcount>
		        	<table width="100%" style="font-family: 'Arial';font-size: 13px;margin-top: -10px;" cellspacing="0" cellpadding="0">
		        		<tr>
		        			<cfif url.reportType EQ 'Detail'>
			        			<td align="right" style="border-top: inset 1px;border-bottom: inset 1px;"><b>Invoice##</b></td>
			        			<td align="center" style="border-top: inset 1px;border-bottom: inset 1px;"><b>Date</b></td>
			        			<td align="center" style="border-top: inset 1px;border-bottom: inset 1px;"><b>Due</b></td>
			        			<td align="center" style="border-top: inset 1px;border-bottom: inset 1px;"><b>Due In Days</b></td>
			        		<cfelse>
			        			<td colspan="4" style="border-top: inset 1px;border-bottom: inset 1px;"><b>Vendor</b></td>
			        		</cfif>
		        			<td align="right" style="border-top: inset 1px;border-bottom: inset 1px;"><b>Invoice Amt</b></td>
		        			<td align="right" style="border-top: inset 1px;border-bottom: inset 1px;"><b>Paid Amt</b></td>
		        			<td align="right" style="border-top: inset 1px;border-bottom: inset 1px;"><b>Balance</b></td>
		        			<td align="right" style="border-top: inset 1px;border-bottom: inset 1px;"><b>Disc</b></td>
		        			<td align="right" style="border-top: inset 1px;border-bottom: inset 1px;"><b>Amt To Pay</b></td>
		        			<td align="right" style="border-top: inset 1px;border-bottom: inset 1px;"><b>Bal. After Pmt</b></td>
		        		</tr>
		        		<cfset amountreporttotal = 0>
	        			<cfset amountpaidreportTotal = 0>
	        			<cfset balancereporttotal = 0>
	        			<cfset amountdiscountreporttotal = 0>
	        			<cfset totalchecks = 0>
		        		<cfloop query="qInvoicesPickedToPay" group="Account Name">
		        			<cfset totalchecks = totalchecks+1>
		        			<cfset amountbanktotal = 0>
		        			<cfset amountpaidbanktotal = 0>
		        			<cfset balancebanktotal = 0>
		        			<cfset amountdiscountbanktotal = 0>
		        			<cfset local.accName = qInvoicesPickedToPay["Account Name"]>
		        			<cfif url.reportType EQ 'Detail'>
			        			<tr>
			        				<td colspan="10"><b>Bank Account: #local.accName#</b></td>
			        			</tr>
			        		</cfif>
		        			<cfloop group="carrierName">
		        				<cfset amounttotal = 0>
			        			<cfset amountpaidTotal = 0>
			        			<cfset balancetotal = 0>
			        			<cfset amountdiscounttotal = 0>
			        			<cfif url.reportType EQ 'Detail'>
			        				<tr>
				        				<td colspan="10" style="font-size: 12px;"><i>#qInvoicesPickedToPay.Carriername#</i></td>
				        			</tr>
				        		</cfif>
			        			<cfloop group="invoicenumber">
			        				<cfset amounttotal = amounttotal+qInvoicesPickedToPay.amount>
				        			<cfset amountpaidTotal = amountpaidTotal+qInvoicesPickedToPay.amountpaid>
				        			<cfset balancetotal = balancetotal+qInvoicesPickedToPay.balance>
				        			<cfset amountdiscounttotal = amountdiscounttotal+qInvoicesPickedToPay.amountdiscount>
				        			<cfif url.reportType EQ 'Detail'>
				        				<tr>
					        				<td align="right">#qInvoicesPickedToPay.invoicenumber#</td>
					        				<td align="center">#dateformat(qInvoicesPickedToPay.entrydate,"m/d/yyyy")#</td>
					        				<td align="center">#dateformat(qInvoicesPickedToPay.checkdate,"m/d/yyyy")#</td>
					        				<td align="center">Past Due</td>
					        				<td align="right">#dollarformat(qInvoicesPickedToPay.amount)#</td>
					        				<td align="right">#dollarformat(qInvoicesPickedToPay.amountpaid)#</td>
					        				<td align="right">#dollarformat(qInvoicesPickedToPay.balance)#</td>
					        				<td align="right">#dollarformat(qInvoicesPickedToPay.amountdiscount)#</td>
					        				<td align="right"><b>#dollarformat(qInvoicesPickedToPay.amount)#</b></td>
					        				<td align="right">#dollarformat(qInvoicesPickedToPay.amount-qInvoicesPickedToPay.amountpaid)#</td>
					        			</tr>
					        		</cfif>
			        			</cfloop>
			        			<cfset amountbanktotal = amountbanktotal+amountTotal>
			        			<cfset amountpaidbanktotal = amountpaidbanktotal+amountpaidTotal>
			        			<cfset balancebanktotal = balancebanktotal+balanceTotal>
			        			<cfset amountdiscountbanktotal = amountdiscountbanktotal+amountdiscountTotal>
			        			<tr>
			        				<td colspan="4" style="font-size: 12px;border-bottom: inset 1px;"><i>#qInvoicesPickedToPay.Carriername# <cfif url.reportType EQ 'Detail'>Totals</cfif></i></td>
			        				<td align="right" style="<cfif url.reportType EQ 'Detail'>border-top: solid 1px;</cfif>border-bottom: solid 1px;">#dollarformat(amountTotal)#</td>
			        				<td align="right" style="<cfif url.reportType EQ 'Detail'>border-top: solid 1px;</cfif>border-bottom: solid 1px;">#dollarformat(amountpaidTotal)#</td>
			        				<td align="right" style="<cfif url.reportType EQ 'Detail'>border-top: solid 1px;</cfif>border-bottom: solid 1px;">#dollarformat(balanceTotal)#</td>
			        				<td align="right" style="<cfif url.reportType EQ 'Detail'>border-top: solid 1px;</cfif>border-bottom: solid 1px;">#dollarformat(amountdiscountTotal)#</td>
			        				<td align="right" style="<cfif url.reportType EQ 'Detail'>border-top: solid 1px;</cfif>border-bottom: solid 1px;"><b>#dollarformat(amountTotal)#</b></td>
			        				<td align="right" style="<cfif url.reportType EQ 'Detail'>border-top: solid 1px;</cfif>border-bottom: solid 1px;">#dollarformat(amountTotal-amountpaidTotal)#</td>
			        			</tr>
		        			</cfloop>
		        			<cfset amountreporttotal = amountreporttotal+amountbankTotal>
		        			<cfset amountpaidreportTotal = amountpaidreportTotal+amountpaidbankTotal>
		        			<cfset balancereporttotal = balancereporttotal+balancebankTotal>
		        			<cfset amountdiscountreporttotal = amountdiscountreporttotal+amountdiscountbankTotal>
		        			<cfif url.reportType EQ 'Detail'>
			        			<tr>
			        				<td colspan="4">Bank Account Totals</td>
			        				<td align="right">#dollarformat(amountbankTotal)#</td>
			        				<td align="right">#dollarformat(amountpaidbankTotal)#</td>
			        				<td align="right">#dollarformat(balancebankTotal)#</td>
			        				<td align="right">#dollarformat(amountdiscountbankTotal)#</td>
			        				<td align="right"><b>#dollarformat(amountbankTotal)#</b></td>
			        				<td align="right">#dollarformat(amountbankTotal-amountpaidbankTotal)#</td>
			        			</tr>
			        		</cfif>
		        		</cfloop>
		        		<tr>
	        				<td colspan="4" style="padding-top: 10px;">Report Totals</td>
	        				<td align="right" style="<cfif url.reportType EQ 'Detail'>border-top: inset 1px;</cfif>padding-top: 10px;">#dollarformat(amountreporttotal)#</td>
	        				<td align="right" style="<cfif url.reportType EQ 'Detail'>border-top: inset 1px;</cfif>padding-top: 10px;">#dollarformat(amountpaidreportTotal)#</td>
	        				<td align="right" style="<cfif url.reportType EQ 'Detail'>border-top: inset 1px;</cfif>padding-top: 10px;">#dollarformat(balancereporttotal)#</td>
	        				<td align="right" style="<cfif url.reportType EQ 'Detail'>border-top: inset 1px;</cfif>padding-top: 10px;">#dollarformat(amountdiscountreporttotal)#</td>
	        				<td align="right" style="<cfif url.reportType EQ 'Detail'>border-top: inset 1px;</cfif>padding-top: 10px;"><b>#dollarformat(amountreporttotal)#</b></td>
	        				<td align="right" style="<cfif url.reportType EQ 'Detail'>border-top: inset 1px;</cfif>padding-top: 10px;">#dollarformat(amountreporttotal-amountpaidreportTotal)#</td>
	        			</tr>
	        			<tr>
	        				<td colspan="4">Totals checks to be Printed:#totalchecks#</td>
	        			</tr>
		        	</table>
		        <cfelse>
		        	This report has no data. Please change your selection and try again.
		        </cfif>
	            <cfdocumentitem type = "footer">
	                <table width="100%" style="font-family: 'Arial';font-size: 12px;margin-top: -10px;" cellspacing="0" cellpadding="0" style="border-top: solid 1px;">
	            		<tr>
	            			<td>#DateTimeFormat(now(),"mmm dd, yyyy, hh:nn:ss tt")#</td>
	            			<td align="right">Page #cfdocument.currentpagenumber# of #cfdocument.totalpagecount#</td>
	            		</tr>
	            	</table>
	            </cfdocumentitem> 
	        </BODY>
	    </HTML>      	
	</cfdocument>
	<cfcontent variable="#toBinary(InvoicesPickedToPay)#" type="application/pdf" /> 	
</cfoutput>