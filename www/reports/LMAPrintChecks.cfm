<cfoutput>
	<cfset local.dsn = trim(listFirst(cgi.SCRIPT_NAME,'/'))>

	<cfquery name="qPrintCheckQry" datasource="#local.dsn#">	
		SELECT * FROM [LMA Accounts Payable Check Transaction File]
		WHERE checkaccount = <cfqueryparam value="#url.account#" cfsqltype="CF_SQL_INTEGER"> 
		AND checknumber = <cfqueryparam value="#url.checkNumber#" cfsqltype="cf_sql_varchar"> 
		AND CompanyID = <cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar"> 
		ORDER BY vendorcode,id
	</cfquery>

	<cfset fileName = "Check-#DateFormat(Now(),'mm.dd.yyyy')#.pdf">
	<cfheader name="Content-Disposition" value="inline; filename=#fileName#">
	<cfdocument format="PDF" name="PrintCheck">
		<cfif qPrintCheckQry.recordcount>
			<cfloop query="qPrintCheckQry" group="vendorcode">
				<cfset local.checkTotal = 0>
				<table style='font-family: "Arial";font-size: 10px;<cfif qPrintCheckQry.currentRow mod 2 EQ 0>margin-top:250px;</cfif>' width="100%">
					<tr>
						<td width="48%"><b>Company:</b>#qPrintCheckQry.vendorcode# - #qPrintCheckQry.description#</td>
						<td width="30%" align="right">#DATEFORMAT(qPrintCheckQry.checkdate,'mm/dd/yyyy')#</td>
						<td width="30%" align="center">#qPrintCheckQry.checknumber#</td>
					</tr>
				</table>
				<div style="clear: both;"></div>
				<table cellspacing="0" style='font-family: "Arial";border:solid 1px;height: 270px;float:left;' width="48%">
					<thead>
						<tr bgcolor="##afabab" style="font-size: 13px;">
							<th style="border-bottom: solid 1px;border-right: solid 1px;">INVOICE##</th>
							<th style="border-bottom: solid 1px;border-right: solid 1px;">AMOUNT</th>
							<th style="border-bottom: solid 1px;border-right: solid 1px;">BAL.</th>
							<th style="border-bottom: solid 1px;border-right: solid 1px;">DISC</th>
							<th style="border-bottom: solid 1px;">PAID</th>
						</tr>
					</thead>
					<tbody>
						<cfloop group="id">
							<cfset local.checktotal = local.checktotal + qPrintCheckQry.amount>
							<tr style="font-size: 12px;">
								<td style="border-right: none;padding-top: 2px;border-bottom: dotted 1px;padding-left: 2px;">#qPrintCheckQry.invoicenumber#</td>
								<td align="center" style="border-right: none;border-left: none;padding-top: 2px;border-bottom: dotted 1px;">#DollarFormat(qPrintCheckQry.amount)#</td>
								<td align="center" style="border-right: none;border-left: none;padding-top: 2px;border-bottom: dotted 1px;">#DollarFormat(qPrintCheckQry.amount)#</td>
								<td align="center" style="border-right: none;border-left: none;padding-top: 2px;border-bottom: dotted 1px;">#DollarFormat(qPrintCheckQry.amountdiscount)#</td>
								<td align="center" style="border-left: none;padding-top: 2px;border-bottom: dotted 1px;">#DollarFormat(qPrintCheckQry.amountpaid)#</td>
							</tr>
						</cfloop>
					</tbody>
				</table>
				<table cellspacing="0" style='font-family: "Arial";border:solid 1px;height: 270px;float:left;margin-left: 20px;' width="48%">
					<thead>
						<tr bgcolor="##afabab" style="font-size: 13px;">
							<th style="border-bottom: solid 1px;border-right: solid 1px;">INVOICE##</th>
							<th style="border-bottom: solid 1px;border-right: solid 1px;">AMOUNT</th>
							<th style="border-bottom: solid 1px;border-right: solid 1px;">BAL.</th>
							<th style="border-bottom: solid 1px;border-right: solid 1px;">DISC</th>
							<th style="border-bottom: solid 1px;">PAID</th>
						</tr>
					</thead>
					<tbody>
						<tr style="font-size: 12px;">
							<td colspan="5">&nbsp;</td>
						</tr>
					</tbody>
				</table>
				<div style="clear: both;"></div>
				<hr>
				<table style='font-family: "Arial";font-size: 12px;float: right;margin-top: 5px;margin-right: 5px;' cellspacing="0" width="30%">
					<tr>
						<td align="center" bgcolor="##afabab" style="padding-top: 2px;border:solid 1px;" width="50%"><b>CHECK TOTAL</b></td>
						<td align="right" style="padding-top: 2px;border:solid 1px;padding-right: 2px;"><b>#DollarFormat(local.checkTotal)#</b></td>
					</tr>
				</table>
			</cfloop>
		<cfelse>
			No Records Found.
		</cfif>
	</cfdocument>
	<cfcontent variable="#toBinary(PrintCheck)#" type="application/pdf" />
</cfoutput>