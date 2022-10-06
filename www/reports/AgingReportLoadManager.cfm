<cfset dsn = "#Application.dsn#">

<cfsetting requestTimeOut = "24000">
<cfset groupBy = url.groupBy>
<cfset reportType = url.reportType>
<cfset orderDateFrom = "">
<cfset orderDateTo = "">
<cfset billDateFrom = "">
<cfset billDateTo = "">
<cfset DateFrom = "">
<cfset DateTo = "">

<cfif structKeyExists(url, "orderDateFrom") and len(url.orderDateFrom)>
	<cfset orderDateFrom = url.orderDateFrom>
	<cfset DateFrom = url.orderDateFrom>
</cfif>
<cfif structKeyExists(url, "orderDateTo") and len(url.orderDateTo)>
	<cfset orderDateTo = url.orderDateTo>
	<cfset DateTo = url.orderDateTo>
</cfif>
<cfif structKeyExists(url, "billDateFrom") and len(url.billDateFrom)>
	<cfset billDateFrom = url.billDateFrom>
	<cfset DateFrom = url.billDateFrom>
</cfif>
<cfif structKeyExists(url, "billDateTo") and len(url.billDateTo)>
	<cfset billDateTo = url.billDateTo>
	<cfset DateTo = url.billDateTo>
</cfif>

<cfset datetype = url.datetype>
<cfset salesRepFrom = url.salesRepFrom>
<cfset salesRepFromForQuery = url.salesRepFrom>
<cfset salesRepTo = url.salesRepTo>
<cfset salesRepToForQuery = url.salesRepTo>
<cfset dispatcherFrom = url.dispatcherFrom>
<cfset dispatcherFromForQuery = url.dispatcherFrom>
<cfset dispatcherTo = url.dispatcherTo>
<cfset dispatcherToForQuery = url.dispatcherTo>
<cfset customerFrom = url.customerLimitFrom>
<cfset customerFromForQuery = url.customerLimitFrom>
<cfset customerTo = url.customerLimitTo>
<cfset customerToForQuery = url.customerLimitTo>
<cfset deductionPercentage = url.deductionPercentage>
<cfset statusTo = url.statusTo>
<cfset statusFrom = url.statusFrom>
<cfset equipmentFrom = url.equipmentFrom>
<cfset equipmentFromForQuery = url.equipmentFrom>
<cfset equipmentTo= url.equipmentTo>
<cfset equipmentToForQuery= url.equipmentTo>
<cfset officeFrom = url.officeFrom>
<cfset officeFromForQuery = url.officeFrom>
<cfset officeTo= url.officeTo>
<cfset officeToForQuery= url.officeTo>
<cfset carrierFrom = url.carrierFrom>
<cfset carrierFromForQuery = url.carrierFrom>
<cfset carrierTo= url.carrierTo>
<cfset carrierToForQuery= url.carrierTo>
<cfset freightBroker= url.freightBroker>

<cfif structKeyExists(url, "ShowSummaryStatus")>
	<cfif url.ShowSummaryStatus eq 1>
		<cfset variables.ShowSummaryStatus=1>
	<cfelse>
		<cfset variables.ShowSummaryStatus=0>
	</cfif>
</cfif>
<cfif freightBroker eq 'Driver'>
	<cfif salesRepFrom eq "">
		<cfset salesRepFrom = "########">
		<cfset salesRepFromForQuery = "(BLANK)">
	</cfif>
	<cfif salesRepTo eq "">
		<cfset salesRepTo = "########">
		<cfset salesRepToForQuery = "(BLANK)">
	</cfif>
<cfelse>
	<cfif salesRepFrom eq "AAAA">
		<cfset salesRepFrom = "########">
		<cfset salesRepFromForQuery = "(BLANK)">
	</cfif>
	<cfif salesRepTo eq "AAAA">
		<cfset salesRepTo = "########">
		<cfset salesRepToForQuery = "(BLANK)">
	</cfif>
</cfif>

<cfif dispatcherFrom eq "AAAA">
	<cfset dispatcherFrom = "########">
    <cfset dispatcherFromForQuery = "">
</cfif>

<cfif dispatcherTo eq "AAAA">
	<cfset dispatcherTo = "########">
    <cfset dispatcherToForQuery = "">
</cfif>

<cfif customerFrom eq "AAAA">
	<cfset customerFrom = "########">
	<cfset customerFromForQuery = "(BLANK)">
</cfif>

<cfif customerTo eq "AAAA">
	<cfset customerTo = "########">
	<cfset customerToForQuery = "(BLANK)">
</cfif>

<cfif equipmentFrom eq "AAAA">
	<cfset equipmentFrom = "########">
    <cfset equipmentFromForQuery = "(BLANK)">
</cfif>

<cfif equipmentTo eq "AAAA">
	<cfset equipmentTo = "########">
	<cfset equipmentToForQuery = "(BLANK)">
</cfif>

<cfif carrierFrom eq "AAAA">
	<cfset carrierFrom = "########">
    <cfset carrierFromForQuery = "(BLANK)">
</cfif>

<cfif carrierTo eq "AAAA">
	<cfset carrierTo = "########">
    <cfset carrierToForQuery = "(BLANK)">
</cfif>

<cfif groupBy eq "salesAgent">
	<cfset groupBy = "Sales Agent">
	<cfset groupsBy = "SALESAGENT">
<cfelseif groupBy eq "Driver">
	<cfset groupBy = "Driver">
	<cfset groupsBy = "Driver">
<cfelseif groupBy eq "userDefinedFieldTrucking">
	<cfset groupBy = "userDefinedFieldTrucking">
	<cfset groupsBy = "userDefinedFieldTrucking">
<cfelseif groupBy eq "Carrier">
	<cfset groupBy = "Carrier">
	<cfset groupsBy = "Carrier">
<cfelseif groupBy eq "CustName">
	<cfset groupBy = "CustName">
	<cfset groupsBy = "CUSTOMERNAME">
<cfelseif  groupBy eq 'dispatcher'>
	<cfset groupBy = "Dispatcher">
	<cfset groupsBy = "DISPATCHER">
<cfelse>
	<cfset groupBy = "none">
	<cfset groupsBy = "none">
</cfif>
<cfif structKeyExists(url, "ShowReportCriteria")>
	<cfif url.ShowReportCriteria eq 1>
		<cfset variables.ShowReportCriteria=1>
	<cfelse>
		<cfset variables.ShowReportCriteria=0>	
	</cfif>	
<cfelse>
	<cfset variables.ShowReportCriteria=0>	
</cfif>	

<cfstoredproc procedure="USP_GetLoadsForCommissionAging" datasource="#dsn#">
	<cfprocparam value="#datetype#" cfsqltype="cf_sql_varchar">
	<cfprocparam value="#orderDateFrom#" cfsqltype="cf_sql_varchar">
	<cfprocparam value="#orderDateTo#" cfsqltype="cf_sql_varchar">
	<cfprocparam value="#billDateFrom#" cfsqltype="cf_sql_varchar">
	<cfprocparam value="#billDateTo#" cfsqltype="cf_sql_varchar">
	<cfprocparam value="#groupsBy#" cfsqltype="cf_sql_varchar">
	<cfprocparam value="#groupBy#" cfsqltype="cf_sql_varchar">
	<cfprocparam value="#salesRepFromForQuery#" cfsqltype="cf_sql_varchar">
	<cfprocparam value="#salesRepToForQuery#" cfsqltype="cf_sql_varchar">
	<cfprocparam value="#dispatcherFromForQuery#" cfsqltype="cf_sql_varchar">
	<cfprocparam value="#dispatcherToForQuery#" cfsqltype="cf_sql_varchar">
	<cfprocparam value="#statusTo#" cfsqltype="cf_sql_varchar">
	<cfprocparam value="#statusFrom#" cfsqltype="cf_sql_varchar">
	<cfprocparam value="#deductionPercentage#" cfsqltype="cf_sql_varchar">
	<cfprocparam value="#equipmentFromForQuery#" cfsqltype="cf_sql_varchar">
	<cfprocparam value="#equipmentToForQuery#" cfsqltype="cf_sql_varchar">
	<cfprocparam value="#officeFromForQuery#" cfsqltype="cf_sql_varchar">
	<cfprocparam value="#officeToForQuery#" cfsqltype="cf_sql_varchar">
	<cfprocparam value="#carrierFromForQuery#" cfsqltype="cf_sql_varchar">
	<cfprocparam value="#carrierToForQuery#" cfsqltype="cf_sql_varchar">
	<cfprocparam value="#customerFromForQuery#" cfsqltype="cf_sql_varchar">
	<cfprocparam value="#customerToForQuery#" cfsqltype="cf_sql_varchar">
	<cfprocparam value="#freightBroker#" cfsqltype="cf_sql_varchar">
	<cfprocparam value="#session.companyid#" cfsqltype="cf_sql_varchar">
	<cfprocparam value="#reportType#" cfsqltype="cf_sql_varchar">
	<cfif isdefined("session.rightsList") AND ListContains(session.rightsList,'SalesRepReport',',')>
		<cfprocparam value="1" cfsqltype="cf_sql_bit">
	<cfelse>
		<cfprocparam value="0" cfsqltype="cf_sql_bit">
	</cfif>
	<cfprocresult name="qCommissionReportLoads">
</cfstoredproc>

<cfset customPath = "">
<cfquery name="qGetCompany" datasource="#dsn#">
	select CompanyCode from Companies WHERE CompanyID = <cfqueryparam value="#session.companyid#" cfsqltype="cf_sql_varchar">
</cfquery>

<cfif len(trim(qGetCompany.companycode)) and directoryExists(expandPath("../reports/#trim(qGetCompany.companycode)#"))>
	<cfset customPath = "#trim(qGetCompany.companycode)#">
</cfif>

<cfif structKeyExists(url, "customerStatus")>
	<cfif url.customerStatus eq 1>
		<cfif structKeyExists(url, "pageBreakStatus")>
			<cfif url.pageBreakStatus eq 1>
				<cfif len(trim(customPath)) and fileExists(expandPath("../reports/#trim(customPath)#/loadCommissionReportPageBreak.cfr"))>
					<cfset tempRootPath = expandPath("../reports/#trim(customPath)#/loadCommissionReportPageBreak.cfr")>
				<cfelse>
					<cfset tempRootPath = expandPath("../reports/loadCommissionReportPageBreak.cfr")>
				</cfif>
			<cfelse>
				<cfif len(trim(customPath)) and fileExists(expandPath("../reports/#trim(customPath)#/loadCommissionReport.cfr"))>
					<cfset tempRootPath = expandPath("../reports/#trim(customPath)#/loadCommissionReport.cfr")>
				<cfelse>
					<cfset tempRootPath = expandPath("../reports/loadCommissionReport.cfr")>
				</cfif>
			</cfif>
		</cfif>
	<cfelse>
		<!--- Show Customer Info,--->
		<cfif structKeyExists(url, "pageBreakStatus")>
			<cfif url.pageBreakStatus eq 1>
				<cfif url.GroupBy eq "Carrier">
					<cfif len(trim(customPath)) and fileExists(expandPath("../reports/#trim(customPath)#/loadCommissionReportSCIPageBreakCarrierPay.cfr"))>
            			<cfset tempRootPath = expandPath("../reports/#trim(customPath)#/loadCommissionReportSCIPageBreakCarrierPay.cfr")>
            		<cfelse>
                		<cfset tempRootPath = expandPath("../reports/loadCommissionReportSCIPageBreakCarrierPay.cfr")>
                	</cfif>
				<cfelse>
					<cfif len(trim(customPath)) and fileExists(expandPath("../reports/#trim(customPath)#/loadCommissionReportSCIPageBreak.cfr"))>
                		<cfset tempRootPath = expandPath("../reports/#trim(customPath)#/loadCommissionReportSCIPageBreakAging.cfr")>
                	<cfelse>
						<cfset tempRootPath = expandPath("../reports/loadCommissionReportSCIPageBreakAging.cfr")>
					</cfif>
				</cfif>
				<cfif url.GroupBy eq "Driver">
					<cfif len(trim(customPath)) and fileExists(expandPath("../reports/#trim(customPath)#/loadCommissionReportSCIPageBreakCarrierPay.cfr"))>
            			<cfset tempRootPath = expandPath("../reports/#trim(customPath)#/loadCommissionReportSCIPageBreakCarrierPay.cfr")>
            		<cfelse>
                		<cfset tempRootPath = expandPath("../reports/loadCommissionReportSCIPageBreakCarrierPay.cfr")>
                	</cfif>
				<cfelse>
					<cfif len(trim(customPath)) and fileExists(expandPath("../reports/#trim(customPath)#/loadCommissionReportSCIPageBreak.cfr"))>
                		<cfset tempRootPath = expandPath("../reports/#trim(customPath)#/loadCommissionReportSCIPageBreakAging.cfr")>
                	<cfelse>
						<cfset tempRootPath = expandPath("../reports/loadCommissionReportSCIPageBreakAging.cfr")>
					</cfif>
				</cfif>
			<cfelse>
				<cfif len(trim(customPath)) and fileExists(expandPath("../reports/#trim(customPath)#/loadCommissionReportSCIAging.cfr"))>
					<cfset tempRootPath = expandPath("../reports/#trim(customPath)#/loadCommissionReportSCIAging.cfr")> 
				<cfelse>
					<cfset tempRootPath = expandPath("../reports/loadCommissionReportSCIAging.cfr")> 
				</cfif>
			</cfif>
		</cfif>
	</cfif>
</cfif>
<cfoutput>
	<cfreport format="pdf" template="#tempRootPath#" query="#qCommissionReportLoads#" name="result">
		<cfreportParam name="orderDateFrom" value="#orderDateFrom#">
		<cfreportParam name="orderDateTo" value="#orderDateTo#">
		<cfreportParam name="billDateFrom" value="#billDateFrom#">
		<cfreportParam name="billDateTo" value="#billDateTo#">
		<cfreportParam name="salesRepFrom" value="#salesRepFrom#">
		<cfreportParam name="salesRepTo" value="#salesRepTo#">
		<cfreportParam name="dispatcherFrom" value="#dispatcherFrom#">
		<cfreportParam name="dispatcherTo" value="#dispatcherTo#">
		<cfreportParam name="customerFrom" value="#customerFrom#">
		<cfreportParam name="customerTo" value="#customerTo#">
		<cfreportParam name="marginRangeFrom" value="0">
		<cfreportParam name="marginRangeTo" value="0">
		<cfreportParam name="paramgroupBy" value="#groupsBy#">
		<cfreportParam name="deductionPercentage" value="#deductionPercentage#">
		<cfreportParam name="equipmentFrom" value="#equipmentFrom#">
		<cfreportParam name="equipmentTo" value="#equipmentTo#">
		<cfreportParam name="freightBroker" value="#freightBroker#">
		<cfreportParam name="ShowSummaryStatus" value="#variables.ShowSummaryStatus#">
		<cfreportParam name="ShowReportCriteria" value="#variables.ShowReportCriteria#">
		<cfreportParam name="reportType" value="#reportType#">	
		<cfreportParam name="carrierFrom" value="#customerFrom#">
		<cfreportParam name="carrierTo" value="#customerTo#">
		<cfreportParam name="datetype" value="#datetype#">
		<cfreportParam name="dateFrom" value="#dateFrom#">
		<cfreportParam name="dateTo" value="#dateTo#">
	</cfreport>
	<cfset fileName = "Load Commission Aging Report Date-#DateFormat(Now(),'mm.dd.yyyy')#.pdf">
	<cfheader name="Content-Disposition" value="inline; filename=#fileName#">
	<cfcontent type="application/pdf" variable="#tobinary(result)#">
</cfoutput> 
