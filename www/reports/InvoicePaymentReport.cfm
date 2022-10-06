<cfoutput>
	<cfset local.dsn = trim(listFirst(cgi.SCRIPT_NAME,'/'))>
	<cfquery name="qGetSystemConfig" datasource="#local.dsn#">
	    SELECT companyName FROM Companies WHERE CompanyID = <cfqueryparam value="#session.companyid#" cfsqltype="cf_sql_varchar">
	</cfquery>

	<cfquery name="qInvoicePayment" datasource="#local.dsn#">
		<cfif not structKeyExists(url, "showVoidedOnly")>
			SELECT 
			[description]
			,[id]
			,[vendorcode]
			,[invoicenumber]
			,[amount]
			,[amountpaid]
			,[amountdiscount]
			,[invoicedate]
			,[checknumber]
			,[checkdate]
			,[checkaccount]
			,0 AS [Voided]
			,NULL [DateVoided]
			,[EntryDate]
			,[EnteredBy]
			,[RemitCode]
			,NULL AS [RemitName]
			,0 AS [XRateAmt]
			,[CompanyID]
			,(select [Account Name] from [LMA Check Register Setup] where [account code] = CTF.checkaccount and CompanyID = CTF.CompanyID) AS bank
			FROM [LMA Accounts Payable Check Transaction File] CTF 
			WHERE 
			CTF.CompanyID = <cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar">
			AND CTF.checkaccount >= <cfqueryparam value="#url.BankAccountFrom#" cfsqltype="cf_sql_integer">
			AND CTF.checkaccount <= <cfqueryparam value="#url.BankAccountTo#" cfsqltype="cf_sql_integer">

			AND CTF.description >= <cfqueryparam value="#url.carrierFrom#" cfsqltype="cf_sql_varchar">
			AND CTF.description <= <cfqueryparam value="#url.carrierTo#" cfsqltype="cf_sql_varchar">

			<cfif structKeyExists(url, "checkNoFrom") AND len(trim(url.checkNoFrom))>
				AND CTF.checknumber >= <cfqueryparam value="#url.checkNoFrom#" cfsqltype="cf_sql_varchar">
			</cfif>
			<cfif structKeyExists(url, "checkNoTo") AND len(trim(url.checkNoTo))>
				AND CTF.checknumber <= <cfqueryparam value="#url.checkNoTo#" cfsqltype="cf_sql_varchar">
			</cfif>

			<cfif len(trim(url.checkDateFrom))>
				AND CONVERT(varchar, CTF.checkDate, 23) >= <cfqueryparam value="#url.checkDateFrom#" cfsqltype="cf_sql_date">
			</cfif>
			<cfif len(trim(url.checkDateTo))>
				AND CONVERT(varchar, CTF.checkDate, 23) <= <cfqueryparam value="#url.checkDateTo#" cfsqltype="cf_sql_date">
			</cfif>

			<cfif len(trim(url.entryDateFrom))>
				AND CONVERT(varchar, CTF.EntryDate, 23) >= <cfqueryparam value="#url.entryDateFrom#" cfsqltype="cf_sql_date">
			</cfif>
			<cfif len(trim(url.entryDateTo))>
				AND CONVERT(varchar, CTF.EntryDate, 23) <= <cfqueryparam value="#url.entryDateTo#" cfsqltype="cf_sql_date">
			</cfif>
			UNION
		</cfif>
		SELECT 
		[description]
		,[id]
		,[vendorcode]
		,[invoicenumber]
		,[amount]
		,[amountpaid]
		,[amountdiscount]
		,[invoicedate]
		,CONVERT(varchar(100),checknumber) AS checknumber
		,[checkdate]
		,[checkaccount]
		,[Voided]
		,[DateVoided]
		,[EntryDate]
		,[EnteredBy]
		,[RemitCode]
		,[RemitName]
		,[XRateAmt]
		,[CompanyID]
		,(select [Account Name] from [LMA Check Register Setup] where [account code] = CTF.checkaccount and CompanyID = CTF.CompanyID) AS bank
		FROM [LMA Accounts Payable Check Transaction History] CTF 
		WHERE 
		CTF.CompanyID = <cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar">
		AND CTF.checkaccount >= <cfqueryparam value="#url.BankAccountFrom#" cfsqltype="cf_sql_integer">
		AND CTF.checkaccount <= <cfqueryparam value="#url.BankAccountTo#" cfsqltype="cf_sql_integer">

		AND CTF.description >= <cfqueryparam value="#url.carrierFrom#" cfsqltype="cf_sql_varchar">
		AND CTF.description <= <cfqueryparam value="#url.carrierTo#" cfsqltype="cf_sql_varchar">

		<cfif structKeyExists(url, "checkNoFrom") AND len(trim(url.checkNoFrom))>
			AND CTF.checknumber >= <cfqueryparam value="#url.checkNoFrom#" cfsqltype="cf_sql_integer">
		</cfif>
		<cfif structKeyExists(url, "checkNoTo") AND len(trim(url.checkNoTo))>
			AND CTF.checknumber <= <cfqueryparam value="#url.checkNoTo#" cfsqltype="cf_sql_integer">
		</cfif>

		<cfif len(trim(url.checkDateFrom))>
			AND CONVERT(varchar, CTF.checkDate, 23) >= <cfqueryparam value="#url.checkDateFrom#" cfsqltype="cf_sql_date">
		</cfif>
		<cfif len(trim(url.checkDateTo))>
			AND CONVERT(varchar, CTF.checkDate, 23) <= <cfqueryparam value="#url.checkDateTo#" cfsqltype="cf_sql_date">
		</cfif>

		<cfif len(trim(url.entryDateFrom))>
			AND CONVERT(varchar, CTF.EntryDate, 23) >= <cfqueryparam value="#url.entryDateFrom#" cfsqltype="cf_sql_date">
		</cfif>
		<cfif len(trim(url.entryDateTo))>
			AND CONVERT(varchar, CTF.EntryDate, 23) <= <cfqueryparam value="#url.entryDateTo#" cfsqltype="cf_sql_date">
		</cfif>
		ORDER BY 
		<cfif structKeyExists(url, "groupBybank") and url.groupBybank eq 1>
			CTF.checkaccount ASC,
		</cfif>
		<cfif url.sortby eq 'CheckNo'>CTF.checknumber<cfelse>CTF.description</cfif> ASC

	</cfquery>

	<cfset fileName = "Invoice Payment Report Date-#DateFormat(Now(),'mm.dd.yyyy')#.pdf">
	<cfheader name="Content-Disposition" value="inline; filename=#fileName#">
	<cfdocument format="PDF" name="InvoicePayment" margintop="1.5">
		<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
	    <HTML xmlns="http://www.w3.org/1999/xhtml">
	        <HEAD>
	            <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
	            <TITLE>Load Manager TMS</TITLE>
	        </HEAD> 
	        <BODY style="font-family: 'Arial';">
	        	<cfdocumentitem type="header">
	        		<table width="100%" style="font-family: 'Arial';border-bottom: solid 3px gray;margin-top: 5px;">
	        			<tr><td colspan="2"><h3>#qGetSystemConfig.companyName#</h3></td></tr>
	        			<tr>
	        				<td valign="bottom">
	        					<h3>Invoice Payment Report - #url.reporttype#</h3>
	        				</td>
	        				<td style="font-size: 10px;padding-left: 10px;">
	        					<table style="font-size: 12px;" cellspacing="0" cellpadding="0" width="100%">
	        						<cfif structKeyExists(url, "BankAccountFrom")>
		        						<tr>
		        							<td align="right"><b>From Account: </b></td>
		        							<td>#url.BankAccountFrom#</td>
		        							<td align="right"><b>To: </b></td>
		        							<td>#url.BankAccountFrom#</td>
		        						</tr>
		        					</cfif>
		        					<cfif structKeyExists(url, "carrierFrom")>
		        						<tr>
		        							<td align="right"><b>From Vendor: </b></td>
		        							<td>#url.carrierFrom#</td>
		        							<td align="right"><b>To: </b></td>
		        							<td>#url.carrierTo#</td>
		        						</tr>
		        					</cfif>
		        					<cfif structKeyExists(url, "checkNoFrom") AND LEN(TRIM(url.checkNoFrom))>
		        						<tr>
		        							<td align="right"><b>From Check##: </b></td>
		        							<td>#url.checkNoFrom#</td>
		        							<td align="right"><b>To: </b></td>
		        							<td>#url.checkNoTo#</td>
		        						</tr>
		        					</cfif>
		        					<cfif structKeyExists(url, "checkDateFrom") AND LEN(TRIM(url.checkDateFrom))>
		        						<tr>
		        							<td align="right"><b>From Date: </b></td>
		        							<td>#url.checkDateFrom#</td>
		        							<td align="right"><b>To: </b></td>
		        							<td>#url.checkDateTo#</td>
		        						</tr>
		        					</cfif>
		        					<cfif structKeyExists(url, "entryDateFrom") AND LEN(TRIM(url.entryDateFrom))>
		        						<tr>
		        							<td align="right"><b>From EntryDate: </b></td>
		        							<td>#url.entryDateFrom#</td>
		        							<td align="right"><b>To: </b></td>
		        							<td >#url.entryDateTo#</td>
		        						</tr>
		        					</cfif>
	        						<tr>
	        							<td align="right"><b>Voided Checks Only: </b></td>
	        							<td><cfif structKeyExists(url, "showVoidedOnly") AND url.showVoidedOnly EQ 1>Yes<cfelse>No</cfif></td>
	        							<td align="right"><b>Sort By: </b></td>
	        							<td ><cfif url.sortby eq 'checkno'>Check ##<cfelse>#url.sortby#</cfif></td>
	        						</tr>
	        						<tr>
	        							<td align="right"><b>Group By Bank: </b></td>
	        							<td><cfif structKeyExists(url, "groupBybank") AND url.groupBybank EQ 1>Yes<cfelse>No</cfif></td>
	        						</tr>
	        					</table>
	        				</td>
	        			</tr>
	        		</table> 
	            </cfdocumentitem>
	            <cfif qInvoicePayment.recordcount>
	            <cfif structKeyExists(url, "groupBybank") and url.groupBybank eq 1>
	            	<table width="100%" style="font-family: 'Arial';font-size: 14px;margin-top: -10px;" cellspacing="0" cellpadding="0">
	        			<tbody>
	        				<cfset grandTotal = 0>
	        				<cfloop query="qInvoicePayment" group="checkaccount">
	        					<cfset bankTotal = 0>
	        					<tr>
	        						<td colspan="1" style="border-bottom: solid 1px;"><b>Bank ##: </b>#qInvoicePayment.checkaccount#</td>
	        						<td colspan="3" style="border-bottom: solid 1px;"><b>Account: </b>#qInvoicePayment.bank#</td>
	        					</tr>
	        					<cfloop group="checknumber">
		        					<cfset TotalForVendor = 0>
		        					<cfloop group="invoicenumber">
		        						<cfset TotalForVendor = TotalForVendor + qInvoicePayment.amountpaid>
		        					</cfloop>
		        					<cfset grandTotal = grandTotal + TotalForVendor>
		        					<cfset bankTotal = bankTotal + TotalForVendor>
			        				<tr>
			        					<td style="border-bottom: solid 1px;"><b>Ck##</b>: #qInvoicePayment.checknumber#</td>
			        					<td style="border-bottom: solid 1px;"><b>Vendor##</b>: #qInvoicePayment.vendorcode#</td>
			        					<td style="border-bottom: solid 1px;"><b>Desc</b>: #qInvoicePayment.description#</td>
			        					<td style="border-bottom: solid 1px;" align="right"><b>Amt</b>: #DollarFormat(TotalForVendor)#</td>
			        				</tr>
			        				<tr>
			        					<td colspan="4">
			        						<table width="100%" style="font-family: 'Arial';font-size: 12px;" cellspacing="0" cellpadding="0">
		        								<thead>
		        									<tr>
		        										<th>&nbsp;</th>
		        										<th align="right">Check Date</th>
		        										<th align="right">Invoice##</th>
		        										<th align="right">Inv Date</th>
		        										<th align="right">Bal. Before</th>
		        										<th align="right">Bal. After</th>
		        										<th align="right">Paid</th>
		        									</tr>
		        									<cfloop group="invoicenumber">
		        										<tr>
		        											<td width="18%"><cfif qInvoicePayment.voided eq 0>&nbsp;<cfelse>**VOID**</cfif></td>
		        											<td align="right">
		        												#dateformat(qInvoicePayment.checkdate,"m/d/yyyy")#
		        											</td>
		        											<td align="right">#qInvoicePayment.invoicenumber#</td>
		        											<td align="right">
		        												#dateformat(qInvoicePayment.checkdate,"m/d/yyyy")#
		        											</td>
		        											<td align="right">#DollarFormat(qInvoicePayment.amount)#</td>
		        											<cfset bal = qInvoicePayment.amount - qInvoicePayment.amountpaid>
		        											<td align="right">#DollarFormat(bal)#</td>
		        											<td align="right">#DollarFormat(qInvoicePayment.amountpaid)#</td>
		        										</tr>
		        									</cfloop>
		        									<tr>
		        										<td colspan="6" style="font-size: 14px;border-top: solid 2px;border-bottom: solid 1px"><b>Total For #qInvoicePayment.vendorcode#</b></td>
		        										<td align="right"  style="font-size: 14px;border-top: solid 2px;border-bottom: solid 1px"><b>#DollarFormat(TotalForVendor)#</b></td>
		        									</tr>
		        								</thead>
			        						</table>
			        					</td>
			        				</tr>
			        				<tr>
			        					<td colspan="4">&nbsp;</td>
			        				</tr>
			        			</cfloop>
			        			<tr>
	        						<td style="border-bottom: solid 1px;"><b>Bank ##: </b>#qInvoicePayment.checkaccount#</td>
	        						<td style="border-bottom: solid 1px;"><b>Account: </b>#qInvoicePayment.bank#</td>
	        						<td style="border-bottom: solid 1px;"  align="right"><b>Total: </b></td>
	        						<td style="border-bottom: solid 1px;"  align="right"><b>#DollarFormat(bankTotal)# </b></td>
	        					</tr>
			        		</cfloop>
		        			<tr>
	        					<td colspan="3" align="right"><b>TOTAL:</b></td>
	        					<td colspan="1" align="right"><b>#DollarFormat(grandTotal)#</b></td>
	        				</tr>
	        			</tbody>
	        		</table>
	            <cfelse>
	            	<table width="100%" style="font-family: 'Arial';font-size: 14px;margin-top: -10px;" cellspacing="0" cellpadding="0">
	        			<tbody>
	        				<cfset grandTotal = 0>
	        				<cfloop query="qInvoicePayment" group="checknumber">
	        					<cfset TotalForVendor = 0>
	        					<cfloop group="invoicenumber">
	        						<cfset TotalForVendor = TotalForVendor + qInvoicePayment.amountpaid>
	        					</cfloop>
	        					<cfset grandTotal = grandTotal + TotalForVendor>
		        				<tr>
		        					<td style="border-bottom: solid 1px;"><b>Ck##</b>: #qInvoicePayment.checknumber#</td>
		        					<td style="border-bottom: solid 1px;"><b>Vendor##</b>: #qInvoicePayment.vendorcode#</td>
		        					<td style="border-bottom: solid 1px;"><b>Desc</b>: #qInvoicePayment.description#</td>
		        					<td style="border-bottom: solid 1px;" align="right"><b>Amt</b>: #DollarFormat(TotalForVendor)#</td>
		        				</tr>
		        				<tr>
		        					<td colspan="4">
		        						<table width="100%" style="font-family: 'Arial';font-size: 12px;" cellspacing="0" cellpadding="0">
	        								<thead>
	        									<tr>
	        										<th>&nbsp;</th>
	        										<th align="right">Check Date</th>
	        										<th align="right">Invoice##</th>
	        										<th align="right">Inv Date</th>
	        										<th align="right">Bal. Before</th>
	        										<th align="right">Bal. After</th>
	        										<th align="right">Paid</th>
	        									</tr>
	        									<cfloop group="invoicenumber">
	        										<tr>
	        											<td width="18%" align="right"><cfif qInvoicePayment.voided eq 0>&nbsp;<cfelse>**VOID**</cfif></td>
	        											<td align="right">
	        												#dateformat(qInvoicePayment.checkdate,"m/d/yyyy")#
	        											</td>
	        											<td align="right">#qInvoicePayment.invoicenumber#</td>
	        											<td align="right">
	        												#dateformat(qInvoicePayment.checkdate,"m/d/yyyy")#
	        											</td>
	        											<td align="right">#DollarFormat(qInvoicePayment.amount)#</td>
	        											<cfset bal = qInvoicePayment.amount - qInvoicePayment.amountpaid>
	        											<td align="right">#DollarFormat(bal)#</td>
	        											<td align="right">#DollarFormat(qInvoicePayment.amountpaid)#</td>
	        										</tr>
	        									</cfloop>
	        									<tr>
	        										<td colspan="6" style="font-size: 14px;border-top: solid 2px;border-bottom: solid 1px"><b>Total For #qInvoicePayment.vendorcode#</b></td>
	        										<td align="right"  style="font-size: 14px;border-top: solid 2px;border-bottom: solid 1px"><b>#DollarFormat(TotalForVendor)#</b></td>
	        									</tr>
	        								</thead>
		        						</table>
		        					</td>
		        				</tr>
		        				<tr>
		        					<td colspan="4">&nbsp;</td>
		        				</tr>
		        			</cfloop>
		        			<tr>
	        					<td colspan="3" align="right"><b>TOTAL:</b></td>
	        					<td colspan="1" align="right"><b>#DollarFormat(grandTotal)#</b></td>
	        				</tr>
	        			</tbody>
	        		</table>
	            </cfif>
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
	<cfcontent variable="#toBinary(InvoicePayment)#" type="application/pdf" /> 	
</cfoutput>