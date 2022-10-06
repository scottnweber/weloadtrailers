<cfoutput>
	<cfset local.dsn = trim(listFirst(cgi.SCRIPT_NAME,'/'))>
	<cfquery name="qGetSystemConfig" datasource="#local.dsn#">
	    SELECT companyName FROM Companies WHERE CompanyID = <cfqueryparam value="#session.companyid#" cfsqltype="cf_sql_varchar">
	</cfquery>

	<cfquery name="qAging" datasource="#local.dsn#">
	    SELECT 
		C.CarrierName, 
		C.VendorID, 
		APT.TRANS_NUMBER,
		APT.date AS InvDate, 
		DATEADD(DD,ISNULL(ST.[Terms Days],0),APT.date) AS Duedate, 
		APT.term_number, 
		APT.Description, 
		DATEDIFF(day,DATEADD(DD,ISNULL(ST.[Terms Days],0),APT.date),getdate()) AS Age ,
		CASE WHEN (DATEDIFF(day,DATEADD(DD,ISNULL(ST.[Terms Days],0),APT.date),getdate())) <=30 THEN APT.Balance + SUM(ISNULL(APCTF.amountpaid,0)) ELSE 0 END AS Curr ,
		CASE WHEN (DATEDIFF(day,DATEADD(DD,ISNULL(ST.[Terms Days],0),APT.date),getdate())) BETWEEN 31 AND 45 THEN APT.Balance + SUM(ISNULL(APCTF.amountpaid,0)) ELSE 0 END AS Over30 ,
		CASE WHEN (DATEDIFF(day,DATEADD(DD,ISNULL(ST.[Terms Days],0),APT.date),getdate())) BETWEEN 46 AND 60 THEN APT.Balance + SUM(ISNULL(APCTF.amountpaid,0)) ELSE 0 END AS Over45 ,
		CASE WHEN (DATEDIFF(day,DATEADD(DD,ISNULL(ST.[Terms Days],0),APT.date),getdate())) BETWEEN 61 AND 75 THEN APT.Balance + SUM(ISNULL(APCTF.amountpaid,0)) ELSE 0 END AS Over60 ,
		CASE WHEN (DATEDIFF(day,DATEADD(DD,ISNULL(ST.[Terms Days],0),APT.date),getdate())) >=75 THEN APT.Balance  + SUM(ISNULL(APCTF.amountpaid,0)) ELSE 0 END AS Over75 ,
		APT.Balance + SUM(ISNULL(APCTF.amountpaid,0)) AS Balance,
		APT.Salesperson 
		FROM  [LMA Accounts Payable Transactions] APT
		LEFT JOIN [LMA Accounts Payable Check Transaction File]  APCTF ON APT.TRANS_NUMBER = APCTF.invoicenumber AND checknumber is NULL		
		INNER JOIN Carriers C ON C.CarrierID = APT.CarrierID
		LEFT JOIN [LMA System Terms] ST ON ST.ID = APT.term_number AND ST.CompanyID =APT.CompanyID 
		WHERE APT.Balance + ISNULL(APCTF.amountpaid,0)  > 0 
		<cfif len(trim(url.DateFrom))>
			AND CONVERT(varchar, APT.Date, 23) >= <cfqueryparam value="#url.DateFrom#" cfsqltype="cf_sql_date">
		</cfif>
		<cfif len(trim(url.DateTo))>
			AND CONVERT(varchar, APT.Date, 23) <= <cfqueryparam value="#url.DateFrom#" cfsqltype="cf_sql_date">
		</cfif>
		AND C.CarrierName >= <cfqueryparam value="#url.carrierLimitFrom#" cfsqltype="cf_sql_varchar">
		AND C.CarrierName <= <cfqueryparam value="#url.carrierLimitTo#" cfsqltype="cf_sql_varchar">
		AND APT.CompanyID = <cfqueryparam value="#session.companyid#" cfsqltype="cf_sql_varchar">
		GROUP BY 
		C.CarrierName, 
		C.VendorID, 
		APT.TRANS_NUMBER,
		APT.date,
		ST.[Terms Days],
		APT.term_number, 
		APT.Description,
		APT.Balance,
		APT.Salesperson 
		ORDER BY #url.groupBy#,#url.sortBy#
	</cfquery>
	<cfset fileName = "Vendor Aging Report Date-#DateFormat(Now(),'mm.dd.yyyy')#.pdf">
	<cfheader name="Content-Disposition" value="inline; filename=#fileName#">
	<cfdocument format="PDF" name="VendorAging" margintop="1">
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
	        				<td width="50%" align="right">
	        					<h4>Vendor Aging Report</h4>
	        					<h3>#qGetSystemConfig.companyName#</h3>
	        				</td>
	        				<td width="50%" align="right" style="font-size: 10px;padding-left: 10px;">
	        					<table style="font-size: 13px;" cellspacing="0" cellpadding="0" width="100%">
	        						<tr>
	        							<td align="right"><b>Carrier&nbsp;From:</b></td>
	        							<td>#url.CarrierLimitFrom#</td>
	        							<td align="right"><b>To:</b></td>
	        							<td>#url.CarrierLimitTo#</td>
	        						</tr>
	        						<cfif len(trim(url.dateFrom)) OR len(trim(url.dateTo))>
		        						<tr>
		        							<td align="right"><b>Date From:</b></td>
		        							<td>#url.dateFrom#</td>
		        							<td align="right"><b>To:</b></td>
		        							<td>#url.dateTo#</td>
		        						</tr>
		        					</cfif>
	        					</table>
	        				</td>
	        			</tr>
	        		</table>
	        		<table width="100%" style="font-family: 'Arial';font-size: 14px;margin-top: 5px;" cellspacing="0" cellpadding="0">
	        			<thead>
	        				<tr>
	        					<cfif url.reportType EQ 'Detail'>
		        					<th align="left" width="10%" style="border-bottom: solid 1px;">Invoice</th>
		        					<th align="left" width="14%" style="border-bottom: solid 1px;">Description</th>
		        					<th align="left" width="10%" style="border-bottom: solid 1px;">Inv Date</th>
		        					<th align="left" width="10%" style="border-bottom: solid 1px;">Due Date</th>
		        					<th align="left" width="6%" style="border-bottom: solid 1px;">Age</th>
		        				<cfelse>
		        					<th colspan="5"  width="50%" align="left" style="border-bottom: solid 1px;"><cfif url.groupBy EQ 'CarrierName'>Carrier<cfelse>Sales Person</cfif></th>
		        				</cfif>
	        					<th align="center" width="10%" style="border-bottom: solid 1px;">Current</th>
	        					<th align="center" width="10%" style="border-bottom: solid 1px;">Over 30</th>
	        					<th align="center" width="10%" style="border-bottom: solid 1px;">Over 45</th>
	        					<th align="center" width="10%" style="border-bottom: solid 1px;">Over 60</th>
	        					<th align="center" width="10%" style="border-bottom: solid 1px;">Over 75</th>
	        				</tr>
	        			</thead>
	        		</table> 
	            </cfdocumentitem>
	            <table width="100%" style="font-family: 'Arial';font-size: 13px;margin-top: -10px;" cellspacing="0" cellpadding="0" >
	            	<cfset currGrandTotal = 0>
	            	<cfset Over30GrandTotal = 0>
	            	<cfset Over45GrandTotal = 0>
	            	<cfset Over60GrandTotal = 0>
	            	<cfset Over75GrandTotal = 0>
	            	<cfset GrandTotal = 0>
	            	<cfloop query="qAging" group="#url.groupBy#">
	            		<cfset currTotal = 0>
		            	<cfset Over30Total = 0>
		            	<cfset Over45Total = 0>
		            	<cfset Over60Total = 0>
		            	<cfset Over75Total = 0>
		            	<cfset Total = 0>
		            	<cfif url.reportType EQ 'Detail'>
			            	<tr>
			            		<td  colspan="10" style="border-bottom: solid 1px;">
			            			<cfif url.groupBy EQ 'CarrierName'>
					            		#qAging.vendorID# #qAging.CarrierName#
					            	<cfelse>
					            		#qAging.salesperson#
					            	</cfif>
				            	</td>
			            	</tr>
			            </cfif>
		            	<cfloop group="TRANS_NUMBER">
		            		<cfset currTotal = currTotal + qAging.curr>
		            		<cfset currGrandTotal = currGrandTotal + qAging.curr>
		            		<cfset Over30Total = Over30Total + qAging.Over30>
		            		<cfset Over30GrandTotal = Over30GrandTotal + qAging.Over30>
		            		<cfset Over45Total = Over45Total + qAging.Over45>
		            		<cfset Over45GrandTotal = Over45GrandTotal + qAging.Over45>
		            		<cfset Over60Total = Over60Total + qAging.Over60>
		            		<cfset Over60GrandTotal = Over60GrandTotal + qAging.Over60>
		            		<cfset Over75Total = Over75Total + qAging.Over75>
		            		<cfset Over75GrandTotal = Over75GrandTotal + qAging.Over75>
		            		<cfset Total = Total + qAging.balance>
		            		<cfset GrandTotal = GrandTotal + qAging.balance>
		            		<cfif url.reportType EQ 'Detail'>
								<tr>
									<td style="border-bottom: solid 1px;" width="10%">#qAging.TRANS_NUMBER#</td>
									<td style="border-bottom: solid 1px;" width="14%">#LEFT(qAging.Description,10)#</td>
									<td style="border-bottom: solid 1px;" width="10%">#DateFormat(qAging.InvDate,'m/d/yyyy')#</td>
									<td style="border-bottom: solid 1px;" width="10%">#DateFormat(qAging.DueDate,'m/d/yyyy')#</td>
									<td style="border-bottom: solid 1px;" width="6%">#qAging.age#</td>
									<td style="border-bottom: solid 1px;" width="10%" align="right">#DollarFormat(qAging.curr)#</td>
									<td style="border-bottom: solid 1px;" width="10%" align="right">#DollarFormat(qAging.Over30)#</td>
									<td style="border-bottom: solid 1px;" width="10%" align="right">#DollarFormat(qAging.Over45)#</td>
									<td style="border-bottom: solid 1px;" width="10%" align="right">#DollarFormat(qAging.Over60)#</td>
									<td style="border-bottom: solid 1px;" width="10%" align="right">#DollarFormat(qAging.Over75)#</td>
								</tr>
							</cfif>
						</cfloop>
						<tr>
							<td colspan="5"><cfif url.reportType EQ 'Detail'><b>Totals For:</b></cfif></b>
								<cfif url.groupBy EQ 'CarrierName'>
				            		#qAging.VendorID# #qAging.CarrierName#
				            	<cfelse>
				            		#qAging.salesperson#
				            	</cfif>
				            </td>
							<td width="10%" align="right">#DollarFormat(currTotal)#</td>
							<td width="10%" align="right">#DollarFormat(Over30Total)#</td>
							<td width="10%" align="right">#DollarFormat(Over45Total)#</td>
							<td width="10%" align="right">#DollarFormat(Over60Total)#</td>
							<td width="10%" align="right">#DollarFormat(Over75Total)#</td>
						</tr>
						<tr>
							<td colspan="9" align="right"><b>Total balance:</b></td>
							<td width="10%" align="right">#DollarFormat(Total)#</td>
						</tr>
						<tr><td colspan="10">&nbsp;</td></tr>
					</cfloop>
					<tr><td colspan="10"><hr></td></tr>
					<tr>
						<td><b>Total</b></td>
						<td colspan="4"></td>
						<td width="10%" align="right">#DollarFormat(currGrandTotal)#</td>
						<td width="10%" align="right">#DollarFormat(Over30GrandTotal)#</td>
						<td width="10%" align="right">#DollarFormat(Over45GrandTotal)#</td>
						<td width="10%" align="right">#DollarFormat(Over60GrandTotal)#</td>
						<td width="10%" align="right">#DollarFormat(Over75GrandTotal)#</td>
					</tr>
					<tr><td colspan="10">&nbsp;</td></tr>
					<tr>
						<td colspan="9" align="right"><b>Grand Total:</b></td>
						<td width="10%" align="right"><b>#DollarFormat(GrandTotal)#</b></td>
					</tr>
	            </table>
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
	<cfcontent variable="#toBinary(VendorAging)#" type="application/pdf" />
</cfoutput>