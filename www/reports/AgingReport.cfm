<cfoutput>
	<cfdocument format="PDF" name="AgingReport"  margintop="1.5" marginleft="0.10" marginright="0.10" marginbottom="0.5">
		<style type="text/css">
			.LoadData td{
				font-size: 13px;
				border-bottom: solid 1px ##CCCCCC;
			}
			td[align='right']{
				padding-right: 2px;
			}
			.GroupData td{
				font-size: 13px;
				border-bottom: solid 1px;
			}
			.GroupTotalData td{
				font-size: 13px;
				font-weight: bold;
				border-top: solid 1px;
				padding-bottom: 10px;
			}
			.GrandTotalData td{
				font-size: 13px;
				font-weight: bold;
				border-top: solid 1px;
				border-bottom: solid 1px;
			}

		</style>
		<cfdocumentitem type="header">
			<style type="text/css">
				.LoadHeader td{
					font-size: 13px;
					font-weight: bold;
					border-top: solid 1px;
					border-bottom: solid 1px;
					padding-top: 5px;
					padding-bottom: 5px;
				}
				td[align='right']{
					padding-right: 2px;
				}
			</style>
			<table width="100%" style="font-family: 'Arial';height: 100%;" cellspacing="0" cellpadding="0">
				<tr>
					<td style="font-weight: bold;" width="70%">#qCommissionReportLoads.CompanyName#</td>
					<td width="30%">
						<table width="100%" style="font-family: 'Arial';font-size: 9px;" cellspacing="0" cellpadding="0">
							<tr>
								<td align="right"><b>From Date: </b></td>
								<td>#DateFrom#</td>
								<td align="right"><b>To: </b></td>
								<td>#DateTo#</td>
							</tr>
						</table>
					</td>
				</tr>
				<tr>
					<td colspan="2" valign="bottom">
						<table width="100%" cellspacing="0" cellpadding="0" style="font-family: 'Arial';">
							<tr class="LoadHeader">
								<td width="60" align="right" >Invoice##</td>
								<td width="100">Purchase Order</td>
								<td width="80" align="right">Date</td>
								<td width="80" align="right">Age</td>
								<td width="80" align="right">Current</td>
								<td width="80" align="right">Over 30</td>
								<td width="80" align="right">Over 60</td>
								<td width="80" align="right">Over 90</td>
								<td width="80" align="right">Over 120</td>
							</tr>
						</table>
					</td>
				</tr>
			</table>
		</cfdocumentitem>
		<table width="100%" cellspacing="0" cellpadding="0" style="font-family: 'Arial';margin-top: -12px;">
			<cfset grandCustomerTotal = 0>
			<cfset grandCurrentAgeTotal = 0>
			<cfset grand30AgeTotal = 0>
			<cfset grand60AgeTotal = 0>
			<cfset grand90AgeTotal = 0>
			<cfset grand120AgeTotal = 0>
			<cfloop query="qCommissionReportLoads" group="custname">
				<cfif structKeyExists(url, "pageBreakStatus") AND url.pageBreakStatus EQ 1 AND qCommissionReportLoads.currentrow neq 1>
					</table>
					<cfdocumentitem type="pagebreak"></cfdocumentitem>
					<table width="100%" cellspacing="0" cellpadding="0" style="font-family: 'Arial';margin-top: -10px;">
				</cfif>
				<cfset grpCustomerTotal = 0>
				<cfset grpCurrentAgeTotal = 0>
				<cfset grp30AgeTotal = 0>
				<cfset grp60AgeTotal = 0>
				<cfset grp90AgeTotal = 0>
				<cfset grp120AgeTotal = 0>
				<tr class="GroupData">
					<td colspan="9">
						<b><cfif reporttype eq 'Customer'>#qCommissionReportLoads.custname#<cfelse>#qCommissionReportLoads.CarrierName#</cfif></b>  <span style="margin-left: 50px;">#qCommissionReportLoads.ContactPerson# #qCommissionReportLoads.Phone#</span>
					</td>
				</tr>

				<cfloop group="LoadNumber">
					<tr class="LoadData">
						<td width="60" align="right" >#qCommissionReportLoads.LoadNumber#</td>
						<td width="100">#qCommissionReportLoads.CustomerPONo#</td>
						<td width="80" align="right">#DateFormat(qCommissionReportLoads.BillDate,'mm/dd/yyyy')#</td>
						<td width="80" align="right">#qCommissionReportLoads.Age#</td>
						<td width="80" align="right"><cfif reporttype eq 'Customer'>#dollarFormat(qCommissionReportLoads.CurrentAge)#<cfelse>#dollarFormat(qCommissionReportLoads.CarrierCurrentAge)#</cfif></td>
						<td width="80" align="right"><cfif reporttype eq 'Customer'>#dollarFormat(qCommissionReportLoads.30Age)#<cfelse>#dollarFormat(qCommissionReportLoads.Carrier30Age)#</cfif></td>
						<td width="80" align="right"><cfif reporttype eq 'Customer'>#dollarFormat(qCommissionReportLoads.60Age)#<cfelse>#dollarFormat(qCommissionReportLoads.Carrier60Age)#</cfif></td>
						<td width="80" align="right"><cfif reporttype eq 'Customer'>#dollarFormat(qCommissionReportLoads.90Age)#<cfelse>#dollarFormat(qCommissionReportLoads.Carrier90Age)#</cfif></td>
						<td width="80" align="right"><cfif reporttype eq 'Customer'>#dollarFormat(qCommissionReportLoads.120Age)#<cfelse>#dollarFormat(qCommissionReportLoads.Carrier120Age)#</cfif></td>	
					</tr>
					<cfset grpCustomerTotal = grpCustomerTotal + qCommissionReportLoads.TotalCustomerCharges>
					<cfif reporttype eq 'Customer'>
						<cfset grpCurrentAgeTotal = grpCurrentAgeTotal + qCommissionReportLoads.CurrentAge>
						<cfset grp30AgeTotal = grp30AgeTotal + qCommissionReportLoads.30Age>
						<cfset grp60AgeTotal = grp60AgeTotal + qCommissionReportLoads.60Age>
						<cfset grp90AgeTotal = grp90AgeTotal + qCommissionReportLoads.90Age>
						<cfset grp120AgeTotal = grp120AgeTotal + qCommissionReportLoads.120Age>
					<cfelse>
						<cfset grpCurrentAgeTotal = grpCurrentAgeTotal + qCommissionReportLoads.CarrierCurrentAge>
						<cfset grp30AgeTotal = grp30AgeTotal + qCommissionReportLoads.Carrier30Age>
						<cfset grp60AgeTotal = grp60AgeTotal + qCommissionReportLoads.Carrier60Age>
						<cfset grp90AgeTotal = grp90AgeTotal + qCommissionReportLoads.Carrier60Age>
						<cfset grp120AgeTotal = grp120AgeTotal + qCommissionReportLoads.Carrier120Age>
					</cfif>
				</cfloop>
				<tr class="GroupTotalData">
					<td colspan="4">TOTAL BALANCE: #dollarFormat(grpCustomerTotal)#</td>
					<td width="80" align="right">#dollarFormat(grpCurrentAgeTotal)#</td>
					<td width="80" align="right">#dollarFormat(grp30AgeTotal)#</td>
					<td width="80" align="right">#dollarFormat(grp60AgeTotal)#</td>
					<td width="80" align="right">#dollarFormat(grp90AgeTotal)#</td>
					<td width="80" align="right">#dollarFormat(grp120AgeTotal)#</td>
				</tr>
				<cfset grandCustomerTotal = 0>
				<cfset grandCurrentAgeTotal = grandCurrentAgeTotal + grpCurrentAgeTotal>
				<cfset grand30AgeTotal = grand30AgeTotal + grp30AgeTotal>
				<cfset grand60AgeTotal = grand60AgeTotal + grp60AgeTotal>
				<cfset grand90AgeTotal = grand90AgeTotal + grp90AgeTotal>
				<cfset grand120AgeTotal = grand120AgeTotal + grp120AgeTotal>
			</cfloop>
			<tr><td  colspan="9">&nbsp;</td></tr>
			<tr class="GrandTotalData">
				<td colspan="4">REPORT TOTALS: #dollarFormat(grandCustomerTotal)#</td>
				<td width="80" align="right">#dollarFormat(grandCurrentAgeTotal)#</td>
				<td width="80" align="right">#dollarFormat(grand30AgeTotal)#</td>
				<td width="80" align="right">#dollarFormat(grand60AgeTotal)#</td>
				<td width="80" align="right">#dollarFormat(grand90AgeTotal)#</td>
				<td width="80" align="right">#dollarFormat(grand120AgeTotal)#</td>
			</tr>
		</table>
	</cfdocument>
</cfoutput>
<cfset PDFinfo=StructNew()> 
<cfset PDFinfo.Title="Load Report"> 
<cfset fileName = "Load Commission Aging Report Date-#DateFormat(Now(),'mm.dd.yyyy')#.pdf">
<cfpdf action="setInfo" source="AgingReport" info="#PDFinfo#" overwrite="yes">
<cfheader name="Content-Disposition" value="inline; filename=#fileName#">
<cfcontent type="application/pdf" variable="#tobinary(AgingReport)#">