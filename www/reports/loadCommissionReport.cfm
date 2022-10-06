<cfif server.coldfusion.productversion CONTAINS '2021'>
	<cflocation url="https://#cgi.HTTP_HOST#/#trim(listFirst(cgi.SCRIPT_NAME,'/'))#/www/webroot/index.cfm?event=SalesReportCondensed&#cgi.QUERY_STRING#">
</cfif> 
<cffunction name="checkValidDate" access="public" output="false" returntype="void">
	<cfargument name="DateStr" type="string" required="yes" />
	<cfset regex = '(0[1-9]|1[012])[- /.](0[1-9]|[12][0-9]|3[01])[- /.](19|20)[0-9]{2}'>
	<cfset MatchedDate = REMatchNoCase(regex, arguments.DateStr)>
	<cfif arrayLen(MatchedDate) EQ 0>
		<cfdocument format="PDF">
			<cfoutput>Invalid date range. Unable to generate the report.</cfoutput>
		</cfdocument>
		<cfabort>
	</cfif>
</cffunction>
<cfset dsn = "#Application.dsn#">

<cfsetting requestTimeOut = "24000">
<cfparam name="url.sortBy" default="LoadNumber">
<cfparam name="url.groupBy" default="None">
<cfset groupBy = url.groupBy>
<cfset sortBy = url.sortBy>
<cfset orderDateFrom = "">
<cfset orderDateTo = "">
<cfset deliveryDateFrom = "">
<cfset deliveryDateTo = "">
<cfset billDateFrom = "">
<cfset billDateTo = "">
<cfset createDateFrom = "">
<cfset createDateTo = "">
<cfset DateFrom = "">
<cfset DateTo = "">
<cfparam name="url.datetype" default="Shipdate">
<cfparam name="url.customerLimitFrom" default="####">
<cfparam name="url.customerLimitTo" default="ZZZZ">
<cfparam name="url.marginRangeFrom" default="0">
<cfparam name="url.marginRangeTo" default="0">
<cfparam name="url.customerStatus" default="0">
<cfparam name="url.ShowSummaryStatus" default="0">
<cfparam name="url.ShowProfit" default="0">
<cfparam name="url.pageBreakStatus" default="1">
<cfparam name="url.ShowReportCriteria" default="1">
<cfparam name="url.reportType" default="Sales">
<cfparam name="url.StatusTo" default="7. INVOICE">
<cfparam name="url.StatusFrom" default="7. INVOICE">
<cfparam name="url.equipmentFrom" default="AAAA">
<cfparam name="url.equipmentTo" default="ZZZZ">
<cfparam name="url.officeFrom" default="AAAA">
<cfparam name="url.officeTo" default="ZZZZ">
<cfparam name="url.carrierFrom" default="AAAA">
<cfparam name="url.carrierTo" default="ZZZZ">
<cfparam name="url.freightBroker" default="Carrrier">
<cfparam name="url.companyid" default="56BFEDEC-E133-4C0B-9353-07B4BAD63C65">
<cfif structKeyExists(url, "orderDateFrom") and len(url.orderDateFrom)>
	<cfset checkValidDate(url.orderDateFrom)>
	<cfset orderDateFrom = url.orderDateFrom>
	<cfset DateFrom = url.orderDateFrom>
</cfif>
<cfif structKeyExists(url, "orderDateTo") and len(url.orderDateTo)>
	<cfset checkValidDate(url.orderDateTo)>
	<cfset orderDateTo = url.orderDateTo>
	<cfset DateTo = url.orderDateTo>
</cfif>

<cfif structKeyExists(url, "deliveryDateFrom") and len(url.deliveryDateFrom)>
	<cfset checkValidDate(url.deliveryDateFrom)>
	<cfset deliveryDateFrom = url.deliveryDateFrom>
	<cfset DateFrom = url.deliveryDateFrom>
</cfif>
<cfif structKeyExists(url, "deliveryDateTo") and len(url.deliveryDateTo)>
	<cfset checkValidDate(url.deliveryDateTo)>
	<cfset deliveryDateTo = url.deliveryDateTo>
	<cfset DateTo = url.deliveryDateTo>
</cfif>

<cfif structKeyExists(url, "billDateFrom") and len(url.billDateFrom)>
	<cfset checkValidDate(url.billDateFrom)>
	<cfset billDateFrom = url.billDateFrom>
	<cfset DateFrom = url.billDateFrom>
</cfif>
<cfif structKeyExists(url, "billDateTo") and len(url.billDateTo)>
	<cfset checkValidDate(url.billDateTo)>
	<cfset billDateTo = url.billDateTo>
	<cfset DateTo = url.billDateTo>
</cfif>
<cfif structKeyExists(url, "createDateFrom") and len(url.createDateFrom)>
	<cfset checkValidDate(url.createDateFrom)>
	<cfset createDateFrom = url.createDateFrom>
	<cfset DateFrom = url.createDateFrom>
</cfif>
<cfif structKeyExists(url, "createDateTo") and len(url.createDateTo)>
	<cfset checkValidDate(url.createDateTo)>
	<cfset createDateTo = url.createDateTo>
	<cfset DateTo = url.createDateTo>
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
<cfset marginRangeFrom = url.marginRangeFrom>
<cfset marginRangeTo = url.marginRangeTo>
<cfset deductionPercentage = url.deductionPercentage>
<cfset commissionPercentage = url.commissionPercentage>
<cfset reportType = url.reportType>
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

<cfif structKeyExists(url, "ShowProfit")>
	<cfif url.ShowProfit eq 1>
		<cfset variables.ShowProfit=1>
	<cfelse>
		<cfset variables.ShowProfit=0>	
	</cfif>	
</cfif>	

<cfif structKeyExists(url, "ShowReportCriteria")>
	<cfif url.ShowReportCriteria eq 1>
		<cfset variables.ShowReportCriteria=1>
	<cfelse>
		<cfset variables.ShowReportCriteria=0>	
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

<cfif officeFrom eq "AAAA">
	<cfset officeFrom = "########">
    <cfset officeFromForQuery = "(BLANK)">
</cfif>

<cfif officeTo eq "AAAA">
	<cfset officeTo = "########">
    <cfset officeToForQuery = "(BLANK)">
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
<cfelseif  groupBy eq 'Carrier/Driver'>
	<cfset groupBy = "Carrier">
	<cfset groupsBy = "Carrier">
<cfelse>
	<cfset groupBy = "none">
	<cfset groupsBy = "none">
</cfif>

<cfstoredproc procedure="USP_GetLoadsForCommissionReport" datasource="#dsn#">
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
	<cfprocparam value="#createDateFrom#" cfsqltype="cf_sql_varchar">
	<cfprocparam value="#createDateTo#" cfsqltype="cf_sql_varchar">
	<cfprocparam value="#url.companyid#" cfsqltype="cf_sql_varchar">
	<cfprocparam value="#deliveryDateFrom#" cfsqltype="cf_sql_varchar">
	<cfprocparam value="#deliveryDateTo#" cfsqltype="cf_sql_varchar">
	<cfprocparam value="#sortBy#" cfsqltype="cf_sql_varchar">
	<cfif isdefined("session.rightsList") AND ListContains(session.rightsList,'SalesRepReport',',')>
		<cfprocparam value="1" cfsqltype="cf_sql_bit">
	<cfelse>
		<cfprocparam value="0" cfsqltype="cf_sql_bit">
	</cfif>
	<cfif structKeyExists(cookie, "ReportIncludeAllDispatchers") AND cookie.ReportIncludeAllDispatchers>
		<cfprocparam value="1" cfsqltype="cf_sql_bit">
	<cfelse>
		<cfprocparam value="0" cfsqltype="cf_sql_bit">
	</cfif>
	<cfprocresult name="qCommissionReportLoads">
</cfstoredproc>

<cfset customPath = "">
<cfquery name="qGetCompany" datasource="#dsn#">
	select CompanyCode from Companies WHERE CompanyID = <cfqueryparam value="#url.companyid#" cfsqltype="cf_sql_varchar">
</cfquery>

<cfif len(trim(qGetCompany.companycode)) and directoryExists(expandPath("../reports/#trim(qGetCompany.companycode)#"))>
	<cfset customPath = "#trim(qGetCompany.companycode)#">
</cfif>
<cfquery name="qSystemSetupOptions" datasource="#dsn#">
	SELECT includeNumberofTripsInReports FROM SystemConfig WHERE CompanyID = <cfqueryparam value="#url.companyid#" cfsqltype="cf_sql_varchar">
</cfquery>
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
                		<cfset tempRootPath = expandPath("../reports/#trim(customPath)#/loadCommissionReportSCIPageBreak.cfr")>
                	<cfelse>
						<cfset tempRootPath = expandPath("../reports/loadCommissionReportSCIPageBreak.cfr")>
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
                		<cfset tempRootPath = expandPath("../reports/#trim(customPath)#/loadCommissionReportSCIPageBreak.cfr")>
                	<cfelse>
						<cfset tempRootPath = expandPath("../reports/loadCommissionReportSCIPageBreak.cfr")>
					</cfif>
				</cfif>  			

            	<cfif url.GroupBy eq "dispatcher">
            		<cfif len(trim(customPath)) and fileExists(expandPath("../reports/#trim(customPath)#/loadCommissionReportDispatchCom.cfr"))>
            			<cfset tempRootPath = expandPath("../reports/#trim(customPath)#/loadCommissionReportDispatchCom.cfr")>
            		<cfelse>
	                	<cfset tempRootPath = expandPath("../reports/loadCommissionReportDispatchCom.cfr")>
	                </cfif>
				</cfif>  
							              
            	<cfif url.reportType eq 'Commission' and listFindNoCase("Carrier,Carrier/Driver", url.GroupBy)>
            		<cfif len(trim(customPath)) and fileExists(expandPath("../reports/#trim(customPath)#/loadCommissionReportCarrierStatement.cfr"))>
            			<cfset tempRootPath = expandPath("../reports/#trim(customPath)#/loadCommissionReportCarrierStatement.cfr")>
            		<cfelse>
	                	<cfset tempRootPath = expandPath("../reports/loadCommissionReportCarrierStatement.cfr")>
	                </cfif>
				</cfif>  
			<cfelse>
				<cfif len(trim(customPath)) and fileExists(expandPath("../reports/#trim(customPath)#/loadCommissionReportSCI.cfr"))>
					<cfset tempRootPath = expandPath("../reports/#trim(customPath)#/loadCommissionReportSCI.cfr")> 
				<cfelse>
					<cfset tempRootPath = expandPath("../reports/loadCommissionReportSCI.cfr")> 
				</cfif>
			</cfif>
		</cfif>	
	</cfif>	
</cfif>	
<!--- <cfdump var="#tempRootPath#"><cfabort> --->
<cfif groupsBy EQ 'dispatcher' AND structKeyExists(cookie, "ReportIncludeAllDispatchers") AND cookie.ReportIncludeAllDispatchers>
	<cfset qCommissionReportLoadsNew = QueryNew(qCommissionReportLoads.columnList)>
	<cfset currRow = 1>
	<cfloop query="qCommissionReportLoads">
		<cfset QueryAddRow(qCommissionReportLoadsNew, 1)>
		<cfloop list="#qCommissionReportLoads.columnList#" index="key">
			<cfset QuerySetCell(qCommissionReportLoadsNew, key, evaluate("qCommissionReportLoads.#key#") , currRow)>
		</cfloop>
		<cfset currRow++>
		<cfif len(trim(qCommissionReportLoads.Dispatcher2))>
			<cfset QueryAddRow(qCommissionReportLoadsNew, 1)>
			<cfloop list="#qCommissionReportLoads.columnList#" index="key">
				<cfset QuerySetCell(qCommissionReportLoadsNew, key, evaluate("qCommissionReportLoads.#key#") , currRow)>
			</cfloop>
			<cfset QuerySetCell(qCommissionReportLoadsNew, "Dispatcher", qCommissionReportLoads.Dispatcher2 , currRow)>
			<cfset QuerySetCell(qCommissionReportLoadsNew, "GrpBy", qCommissionReportLoads.Dispatcher2 , currRow)>
			<cfset currRow++>
		</cfif>
		<cfif len(trim(qCommissionReportLoads.Dispatcher3))>
			<cfset QueryAddRow(qCommissionReportLoadsNew, 1)>
			<cfloop list="#qCommissionReportLoads.columnList#" index="key">
				<cfset QuerySetCell(qCommissionReportLoadsNew, key, evaluate("qCommissionReportLoads.#key#") , currRow)>
			</cfloop>
			<cfset QuerySetCell(qCommissionReportLoadsNew, "Dispatcher", qCommissionReportLoads.Dispatcher3 , currRow)>
			<cfset QuerySetCell(qCommissionReportLoadsNew, "GrpBy", qCommissionReportLoads.Dispatcher3 , currRow)>
			<cfset currRow++>
		</cfif>
	</cfloop>
	<cfset qCommissionReportLoads = qCommissionReportLoadsNew>
</cfif>
<cfif groupsBy EQ 'salesAgent' AND structKeyExists(cookie, "ReportIncludeAllSalesRep") AND cookie.ReportIncludeAllSalesRep >
	<cfset qCommissionReportLoadsNew = QueryNew(qCommissionReportLoads.columnList)>
	<cfset currRow = 1>
	<cfloop query="qCommissionReportLoads">
		<cfset QueryAddRow(qCommissionReportLoadsNew, 1)>
		<cfloop list="#qCommissionReportLoads.columnList#" index="key">
			<cfset QuerySetCell(qCommissionReportLoadsNew, key, evaluate("qCommissionReportLoads.#key#") , currRow)>
		</cfloop>
		<cfset currRow++>
		<cfif len(trim(qCommissionReportLoads.SalesAgent2))>
			<cfset QueryAddRow(qCommissionReportLoadsNew, 1)>
			<cfloop list="#qCommissionReportLoads.columnList#" index="key">
				<cfset QuerySetCell(qCommissionReportLoadsNew, key, evaluate("qCommissionReportLoads.#key#") , currRow)>
			</cfloop>
			<cfset QuerySetCell(qCommissionReportLoadsNew, "SalesAgent", qCommissionReportLoads.SalesAgent2 , currRow)>
			<cfset QuerySetCell(qCommissionReportLoadsNew, "GrpBy", qCommissionReportLoads.SalesAgent2 , currRow)>
			<cfset currRow++>
		</cfif>
		<cfif len(trim(qCommissionReportLoads.SalesAgent3))>
			<cfset QueryAddRow(qCommissionReportLoadsNew, 1)>
			<cfloop list="#qCommissionReportLoads.columnList#" index="key">
				<cfset QuerySetCell(qCommissionReportLoadsNew, key, evaluate("qCommissionReportLoads.#key#") , currRow)>
			</cfloop>
			<cfset QuerySetCell(qCommissionReportLoadsNew, "SalesAgent", qCommissionReportLoads.SalesAgent3 , currRow)>
			<cfset QuerySetCell(qCommissionReportLoadsNew, "GrpBy", qCommissionReportLoads.SalesAgent3 , currRow)>
			<cfset currRow++>
		</cfif>
	</cfloop>
	<cfset qCommissionReportLoads = qCommissionReportLoadsNew>
</cfif>
<cfoutput>
		<cfreport format="pdf" template="#tempRootPath#" query="#qCommissionReportLoads#" name="result">
			<cfreportParam name="ReportType" value="#reportType#">
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
			<cfreportParam name="marginRangeFrom" value="#marginRangeFrom#">
			<cfreportParam name="marginRangeTo" value="#marginRangeTo#">
			<cfreportParam name="paramgroupBy" value="#groupsBy#">
			<cfreportParam name="deductionPercentage" value="#deductionPercentage#">
			<cfreportParam name="equipmentFrom" value="#equipmentFrom#">
			<cfreportParam name="equipmentTo" value="#equipmentTo#">
			<cfreportParam name="carrierFrom" value="#carrierFrom#">
			<cfreportParam name="carrierTo" value="#carrierTo#">
			<cfreportParam name="freightBroker" value="#freightBroker#">
			<cfreportParam name="ShowSummaryStatus" value="#variables.ShowSummaryStatus#">
			<cfreportParam name="ShowProfit" value="#variables.ShowProfit#">
			<cfreportParam name="includeNumberofTripsInReports" value="#qSystemSetupOptions.includeNumberofTripsInReports#">	
			<cfreportParam name="DateFrom" value="#DateFrom#">
			<cfreportParam name="DateTo" value="#DateTo#">
			<cfreportParam name="createDateFrom" value="#createDateFrom#">
			<cfreportParam name="DateType" value="#DateType#">
			<cfreportParam name="ShowReportCriteria" value="#variables.ShowReportCriteria#">	
		</cfreport>
		<cfset fileName = "Load Commission Report Date-#DateFormat(Now(),'mm.dd.yyyy')#.pdf">
		<cfheader name="Content-Disposition" value="inline; filename=#fileName#">
		<cfcontent type="application/pdf" variable="#tobinary(result)#">
</cfoutput> 
