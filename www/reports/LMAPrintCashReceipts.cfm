<cfoutput>
	<cfset local.dsn = trim(listFirst(cgi.SCRIPT_NAME,'/'))>
	<cfquery name="qGetSystemConfig" datasource="#local.dsn#">
	    SELECT companyName FROM Companies WHERE CompanyID = <cfqueryparam value="#session.companyid#" cfsqltype="cf_sql_varchar">
	</cfquery>

	<cfquery name="qCashReceipts" datasource="#local.dsn#">
	    SELECT *,(ARPD.Balance+ARPD.Applie+ARPD.Discou) AS BalanceBefore FROM [LMA Accounts Receivable Payment Detail] ARPD
	    INNER JOIN Customers C ON C.CustomerID = ARPD.CustomerID
		<cfif len(trim(url.DateFrom))>
			AND CONVERT(varchar, ARPD.Entered, 23) >= <cfqueryparam value="#url.DateFrom#" cfsqltype="cf_sql_date">
		</cfif>
		<cfif len(trim(url.DateTo))>
			AND CONVERT(varchar, ARPD.Entered, 23) <= <cfqueryparam value="#url.DateFrom#" cfsqltype="cf_sql_date">
		</cfif>
		AND C.CustomerName >= <cfqueryparam value="#url.customerLimitFrom#" cfsqltype="cf_sql_varchar">
		AND C.CustomerName <= <cfqueryparam value="#url.customerLimitTo#" cfsqltype="cf_sql_varchar">
		AND ARPD.CompanyID = <cfqueryparam value="#session.companyid#" cfsqltype="cf_sql_varchar">
		ORDER BY C.CustomerName,ARPD.CheckNumber,ARPD.InvoicNumber
	</cfquery>

	<cfset fileName = "Cash Receipts Date-#DateFormat(Now(),'mm.dd.yyyy')#.pdf">
	<cfheader name="Content-Disposition" value="inline; filename=#fileName#">
	<cfdocument format="PDF" name="CashReceipt" margintop="1">
		<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
	    <HTML xmlns="http://www.w3.org/1999/xhtml">
	        <HEAD>
	            <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
	            <TITLE>Load Manager TMS</TITLE>
	        </HEAD> 
	        <BODY style="font-family: 'Arial';">
	        	<cfdocumentitem type="header">
	        		<table width="100%" style="font-family: 'Arial';border-bottom: solid 1px;margin-top: 5px;">
	        			<tr>
	        				<td width="25%" align="right">
	        				</td>
	        				<td width="25%" align="left">
	        					<h3>Customer Payments #url.reportType#</h3>
	        					<h3>#qGetSystemConfig.companyName#</h3>
	        				</td>
	        				<td width="50%" align="right" style="font-size: 10px;padding-left: 10px;">
	        					<table style="font-size: 13px;" cellspacing="0" cellpadding="0" width="100%">
	        						<tr>
	        							<td align="right" width="50%"><b>Customer From: </b></td>
	        							<td>#url.CustomerLimitFrom#</td>
	        						</tr>
	        						<tr>
	        							<td align="right"><b>To: </b></td>
	        							<td>#url.CustomerLimitTo#</td>
	        						</tr>
	        						<cfif len(trim(url.dateFrom)) OR len(trim(url.dateTo))>
		        						<tr>
		        							<td align="right"><b>Date From: </b></td>
		        							<td>#url.dateFrom#</td>
		        						</tr>
		        						<tr>
		        							<td align="right"><b>To: </b></td>
		        							<td>#url.dateTo#</td>
		        						</tr>
		        					</cfif>
	        					</table>
	        				</td>
	        			</tr>
	        		</table>
	        	</cfdocumentitem>
	        	<cfif qCashReceipts.recordcount>
		        	<table width="100%" style="font-family: 'Arial';font-size: 13px;margin-top: -10px;" cellspacing="0" cellpadding="0">
		        		<cfset InvoicAmountGrandTotal = 0>
		        		<cfset BalanceGrandTotal = 0>
		        		<cfset ApplieGrandTotal = 0>
		        		<cfset DiscouGrandTotal = 0>
		        		<cfif url.reportType EQ 'Summary'>
		        			<tr>
			        			<td style="font-style: italic;font-weight: bold;" colspan="4">Customer##</td>
			        			
			        			<td style="font-style: italic;font-weight: bold;" align="right">Invoice Amt</td>
			        			<td style="font-style: italic;font-weight: bold;" align="right">Bal. Before</td>
			        			<td style="font-style: italic;font-weight: bold;" align="right">Applied Amt</td>
			        			<td style="font-style: italic;font-weight: bold;" align="right">Disc Amt</td>
			        			<td style="font-style: italic;font-weight: bold;" align="right">Bal. After</td>
			        		</tr>
		        		</cfif>
		        		<cfloop query="qCashReceipts" group="CustomerName">
		        			<cfif url.reportType EQ 'Detail'>
				        		<tr>
				        			<td colspan="9" style="border-bottom: inset 1px;">
						            	<b>Customer##: </b>#qCashReceipts.customerCode# #qCashReceipts.CustomerName#
					            	</td>
				        		</tr>
				        		<tr>
				        			<td style="font-style: italic;font-weight: bold;">Ck Date</td>
				        			<td style="font-style: italic;font-weight: bold;" align="right">Check##</td>
				        			<td style="font-style: italic;font-weight: bold;" align="right">Check Amt</td>
				        			<td style="font-style: italic;font-weight: bold;" align="right">Invoice##</td>
				        			<td style="font-style: italic;font-weight: bold;" align="right">Invoice Amt</td>
				        			<td style="font-style: italic;font-weight: bold;" align="right">Bal. Before</td>
				        			<td style="font-style: italic;font-weight: bold;" align="right">Applied Amt</td>
				        			<td style="font-style: italic;font-weight: bold;" align="right">Disc Amt</td>
				        			<td style="font-style: italic;font-weight: bold;" align="right">Bal. After</td>
				        		</tr>
				        	</cfif>
			        		<cfset InvoicAmountTotal = 0>
			        		<cfset BalanceTotal = 0>
			        		<cfset ApplieTotal = 0>
			        		<cfset DiscouTotal = 0>
			        		<cfloop group="InvoicNumber">
			        			<cfset InvoicAmountTotal = InvoicAmountTotal+InvoicAmount>
			        			<cfset BalanceTotal = InvoicAmountTotal>
			        		</cfloop>
			        		<cfloop group="CheckNumber">
			        			<cfloop group="InvoicNumber">
					        		<cfset ApplieTotal = ApplieTotal+Applie>
					        		<cfset DiscouTotal = DiscouTotal+Discou>
					        		<cfif url.reportType EQ 'Detail'>
				        				<tr>
				        					<cfif qCashReceipts.CheckNumber[currentrow] NEQ qCashReceipts.CheckNumber[currentrow-1]>
						        				<td style="font-size: 12px;">#DateFormat(qCashReceipts.Entered,"mm/dd/yyyy")#</td>
						        				<td style="font-size: 12px;" align="right">#qCashReceipts.CheckNumber#</td>
						        				<td style="font-size: 12px;" align="right">#DollarFormat(CheckAmount)#</td>
						        			<cfelse>
						        				<td colspan="3"></td>
						        			</cfif>
											<td style="font-size: 12px;" align="right">#qCashReceipts.InvoicNumber#</td>
											<td style="font-size: 12px;" align="right">#DollarFormat(InvoicAmount)#</td>
											<td style="font-size: 12px;" align="right">#DollarFormat(BalanceBefore)#</td>
					        				<td style="font-size: 12px;" align="right">#DollarFormat(Applie)#</td>
					        				<td style="font-size: 12px;" align="right">#DollarFormat(Discou)#</td>
					        				<td style="font-size: 12px;" align="right">#DollarFormat(BalanceBefore-Applie-Discou)#</td>
					        			</tr>
					        		</cfif>
			        			</cfloop>
			        		</cfloop>
			        		<cfset InvoicAmountGrandTotal = InvoicAmountGrandTotal+InvoicAmountTotal>
			        		<cfset BalanceGrandTotal = BalanceGrandTotal+BalanceTotal>
			        		<cfset ApplieGrandTotal = ApplieGrandTotal+ApplieTotal>
			        		<cfset DiscouGrandTotal = DiscouGrandTotal+DiscouTotal>
			        		<tr>
								<td colspan="4" style="padding-bottom: 10px;border-top: inset 1px;font-size: 12px;">
									<b><cfif url.reportType EQ 'Detail'>Total For:</cfif> #qCashReceipts.customerCode# #qCashReceipts.CustomerName#</b>
					            </td>
					            <td style="font-size: 12px;padding-bottom: 10px;border-top: inset 1px;" align="right">#DollarFormat(InvoicAmountTotal)#</td>
								<td style="font-size: 12px;padding-bottom: 10px;border-top: inset 1px;" align="right">#DollarFormat(BalanceTotal)#</td>
		        				<td style="font-size: 12px;padding-bottom: 10px;border-top: inset 1px;" align="right">#DollarFormat(ApplieTotal)#</td>
		        				<td style="font-size: 12px;padding-bottom: 10px;border-top: inset 1px;" align="right">#DollarFormat(DiscouTotal)#</td>
		        				<td style="font-size: 12px;padding-bottom: 10px;border-top: inset 1px;" align="right">#DollarFormat(BalanceTotal-ApplieTotal-DiscouTotal)#</td>
					        </tr>
			        	</cfloop>
			        	<tr><td colspan="9"><hr></td></tr>
			        	<tr>
							<td colspan="4"><b>Grand Total: </b></td>
							<td style="font-size: 12px;padding-bottom: 10px;" align="right">#DollarFormat(InvoicAmountGrandTotal)#</td>
							<td style="font-size: 12px;padding-bottom: 10px;" align="right">#DollarFormat(BalanceGrandTotal)#</td>
	        				<td style="font-size: 12px;padding-bottom: 10px;" align="right">#DollarFormat(ApplieGrandTotal)#</td>
	        				<td style="font-size: 12px;padding-bottom: 10px;" align="right">#DollarFormat(DiscouGrandTotal)#</td>
	        				<td style="font-size: 12px;padding-bottom: 10px;" align="right">#DollarFormat(BalanceGrandTotal-ApplieGrandTotal-DiscouGrandTotal)#</td>
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
	<cfcontent variable="#toBinary(CashReceipt)#" type="application/pdf" /> 	
</cfoutput>