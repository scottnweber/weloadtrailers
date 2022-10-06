<cfoutput>
	<cfset local.dsn = trim(listFirst(cgi.SCRIPT_NAME,'/'))>
	<cfquery name="qGetSystemConfig" datasource="#local.dsn#">
	    SELECT companyName FROM Companies WHERE CompanyID =<cfqueryparam value="#session.companyid#" cfsqltype="cf_sql_varchar">
	</cfquery>

	<cfquery name="qAging" datasource="#local.dsn#">
	    SELECT 
		C.CustomerName,
		C.CustomerCode,
		ART.TRANS_NUMBER,
		ART.date AS InvDate,
		DATEADD(DD,ISNULL(ST.[Terms Days],0),ART.date) AS Duedate,
		ART.term_number,
		ART.Description,
		DATEDIFF(day,DATEADD(DD,ISNULL(ST.[Terms Days],0),ART.date),getdate()) AS Age
		,CASE WHEN (DATEDIFF(day,DATEADD(DD,ISNULL(ST.[Terms Days],0),ART.date),getdate())) <=30 THEN  ART.Balance ELSE 0 END AS Below30 
		,CASE WHEN (DATEDIFF(day,DATEADD(DD,ISNULL(ST.[Terms Days],0),ART.date),getdate())) BETWEEN 31 AND 60 THEN  ART.Balance ELSE 0 END AS Over30 
		,CASE WHEN (DATEDIFF(day,DATEADD(DD,ISNULL(ST.[Terms Days],0),ART.date),getdate())) BETWEEN 61 AND 90 THEN  ART.Balance ELSE 0 END AS Over60
		,CASE WHEN (DATEDIFF(day,DATEADD(DD,ISNULL(ST.[Terms Days],0),ART.date),getdate())) >=91 THEN  ART.Balance ELSE 0 END AS Over90 
		,ART.Balance
		,ART.Salesperson
		FROM  [LMA Accounts Receivable Transactions] ART
		INNER JOIN Customers C ON C.CustomerID = ART.CustomerID
		LEFT JOIN [LMA System Terms] ST ON ST.ID = ART.term_number
		WHERE ART.Balance <> 0
		AND  ART.typetrans IN ('I','C') 
		<cfif len(trim(url.DateFrom)) AND len(trim(url.DateTo))>
			AND DATEADD(DD,ISNULL(ST.[Terms Days],0),ART.date) BETWEEN <cfqueryparam value="#url.DateFrom#" cfsqltype="cf_sql_date"> AND <cfqueryparam value="#url.DateTo#" cfsqltype="cf_sql_date">
		</cfif>
		
		<cfif structKeyExists(url, "customerLimitFrom")>
			AND C.CustomerName >= <cfqueryparam value="#url.customerLimitFrom#" cfsqltype="cf_sql_varchar">
		</cfif>
		<cfif structKeyExists(url, "customerLimitFrom")>
			AND C.CustomerName <= <cfqueryparam value="#url.customerLimitTo#" cfsqltype="cf_sql_varchar">
		</cfif>
		AND ART.CompanyID = <cfqueryparam value="#session.companyid#" cfsqltype="cf_sql_varchar">
		ORDER BY #url.groupBy#,#url.sortBy#
	</cfquery>

	<cfset fileName = "Customer Aging Report Date-#DateFormat(Now(),'mm.dd.yyyy')#.pdf">
	<cfheader name="Content-Disposition" value="inline; filename=#fileName#">
	<cfdocument format="PDF" name="CustomerAging" margintop="1">
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
	        					<h3>Customer Aging Report</h3>
	        					<h3>#qGetSystemConfig.companyName#</h3>
	        				</td>
	        				<td width="50%" align="right" style="font-size: 10px;padding-left: 10px;">
	        					<table style="font-size: 13px;" cellspacing="0" cellpadding="0" width="100%">
	        						<cfif structKeyExists(url, "customerLimitFrom")>
		        						<tr>
		        							<td align="right" width="50%"><b>From: </b></td>
		        							<td>#url.CustomerLimitFrom#</td>
		        						</tr>
		        						<tr>
		        							<td align="right"><b>To: </b></td>
		        							<td>#url.CustomerLimitTo#</td>
		        						</tr>
		        					</cfif>
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
	        		<table width="100%" style="font-family: 'Arial';font-size: 14px;margin-top: 5px;" cellspacing="0" cellpadding="0">
	        			<thead>
	        				<tr>
	        					<cfif url.reportType EQ 'Detail'>
		        					<th align="left" width="10%" style="border-bottom: solid 1px;">Invoice</th>
		        					<th align="left" width="24%" style="border-bottom: solid 1px;">Description</th>
		        					<th align="right" width="10%" style="border-bottom: solid 1px;">Inv Date</th>
		        					<th align="right" width="10%" style="border-bottom: solid 1px;">Due Date</th>
		        					<th align="right" width="6%" style="border-bottom: solid 1px;">Age</th>
		        				<cfelse>
		        					<th <!--- colspan="5" --->  width="60%" align="left" style="border-bottom: solid 1px;"><cfif url.groupBy EQ 'CustomerName'>Customer<cfelse>Sales Person</cfif></th>
		        				</cfif>
	        					<th align="right" width="10%" style="border-bottom: solid 1px;">1-30</th>
	        					<th align="right" width="10%" style="border-bottom: solid 1px;">31-60</th>
	        					<th align="right" width="10%" style="border-bottom: solid 1px;">61-90</th>
	        					<th align="right" width="10%" style="border-bottom: solid 1px;">90+</th>
	        				</tr>
	        			</thead>
	        		</table> 
	            </cfdocumentitem>
	            <table width="100%" style="font-family: 'Arial';font-size: 13px;margin-top: -10px;" cellspacing="0" cellpadding="0">
	            	<cfset Below30GrandTotal = 0>
	            	<cfset Over30GrandTotal = 0>
	            	<cfset Over60GrandTotal = 0>
	            	<cfset Over90GrandTotal = 0>
	            	<cfset GrandTotal = 0>
	            	<cfloop query="qAging" group="#url.groupBy#">
	            		<cfset Below30Total = 0>
		            	<cfset Over30Total = 0>
		            	<cfset Over60Total = 0>
		            	<cfset Over90Total = 0>
		            	<cfset Total = 0>
		            	<cfif url.reportType EQ 'Detail'>
			            	<tr>
			            		<td  colspan="10" style="border-bottom: solid 1px;">
			            			<cfif url.groupBy EQ 'CustomerName'>
					            		<b>#qAging.customerCode# #qAging.CustomerName#</b>
					            	<cfelse>
					            		<b>#qAging.salesperson#</b>
					            	</cfif>
				            	</td>
			            	</tr>
			            </cfif>
		            	<cfloop group="TRANS_NUMBER">
		            		<cfset Below30Total = Below30Total + qAging.Below30>
		            		<cfset Below30GrandTotal = Below30GrandTotal + qAging.Below30>
		            		<cfset Over30Total = Over30Total + qAging.Over30>
		            		<cfset Over30GrandTotal = Over30GrandTotal + qAging.Over30>
		            		<cfset Over60Total = Over60Total + qAging.Over60>
		            		<cfset Over60GrandTotal = Over60GrandTotal + qAging.Over60>
		            		<cfset Over90Total = Over90Total + qAging.Over90>
		            		<cfset Over90GrandTotal = Over90GrandTotal + qAging.Over90>
		            		<cfset Total = Total + qAging.balance>
		            		<cfset GrandTotal = GrandTotal + qAging.balance>
		            		<cfif url.reportType EQ 'Detail'>
								<tr>
									<td style="border-bottom: inset 1px;" width="10%">#qAging.TRANS_NUMBER#</td>
									<td style="border-bottom: inset 1px;" width="24%">#LEFT(qAging.Description,10)#</td>
									<td style="border-bottom: inset 1px;" width="10%" align="right">#DateFormat(qAging.InvDate,'m/d/yyyy')#</td>
									<td style="border-bottom: inset 1px;" width="10%" align="right">#DateFormat(qAging.DueDate,'m/d/yyyy')#</td>
									<td style="border-bottom: inset 1px;" width="6%" align="right">#qAging.age#</td>
									<td style="border-bottom: inset 1px;" width="10%" align="right">#DollarFormat(qAging.Below30)#
									</td>
									<td style="border-bottom: inset 1px;" width="10%" align="right">#DollarFormat(qAging.Over30)#</td>
									<td style="border-bottom: inset 1px;" width="10%" align="right">#DollarFormat(qAging.Over60)#</td>
									<td style="border-bottom: inset 1px;" width="10%" align="right">#DollarFormat(qAging.Over90)#</td>
								</tr>
							</cfif>
						</cfloop>
						<tr>
							<td <cfif url.reportType EQ 'Detail'>colspan="5"</cfif> width="60%"><cfif url.reportType EQ 'Detail'><b>Totals For: </b></cfif></b>
								<cfif url.groupBy EQ 'CustomerName'>
				            		#qAging.customerCode# #qAging.CustomerName#
				            	<cfelse>
				            		#qAging.salesperson#
				            	</cfif>
				            </td>
							<td width="10%" align="right" style="padding-right: 2px">#DollarFormat(Below30Total)#</td>
							<td width="10%" align="right">#DollarFormat(Over30Total)#</td>
							<td width="10%" align="right">#DollarFormat(Over60Total)#</td> 
							<td width="10%" align="right">#DollarFormat(Over90Total)#</td>
						</tr>
						<tr>
							<td <cfif url.reportType EQ 'Detail'>colspan="8"<cfelse>colspan="4" width="60%"</cfif> align="right"><b>Total balance: </b></td>
							<td width="10%" align="right">#DollarFormat(Total)#</td>
						</tr>
						<tr><td <cfif url.reportType EQ 'Detail'>colspan="9"<cfelse>colspan="5"</cfif>>&nbsp;</td></tr>
					</cfloop>
					<tr><td <cfif url.reportType EQ 'Detail'>colspan="9"<cfelse>colspan="5"</cfif>><hr></td></tr>
					<tr>
						<td><b>Total</b></td>
						<cfif url.reportType EQ 'Detail'>
							<td colspan="4"></td>
						</cfif>
						<td width="10%" align="right">#DollarFormat(Below30GrandTotal)#</td>
						<td width="10%" align="right">#DollarFormat(Over30GrandTotal)#</td>
						<td width="10%" align="right">#DollarFormat(Over60GrandTotal)#</td>
						<td width="10%" align="right">#DollarFormat(Over90GrandTotal)#</td>
					</tr>
					<tr><td <cfif url.reportType EQ 'Detail'>colspan="9"<cfelse>colspan="5"</cfif>>&nbsp;</td></tr>
					<tr>
						<td <cfif url.reportType EQ 'Detail'>colspan="8"<cfelse>colspan="4" width="60%"</cfif> align="right"><b>Grand Total: </b></td>
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
	<cfcontent variable="#toBinary(CustomerAging)#" type="application/pdf" /> 	
</cfoutput>