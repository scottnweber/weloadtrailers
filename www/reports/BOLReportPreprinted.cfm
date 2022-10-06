<cfoutput>
	<cftry>
		<cfset local.dsn = trim(listFirst(cgi.SCRIPT_NAME,'/'))>
		<cfquery name="qgetLoadDetail" datasource="#local.dsn#">
			SELECT 
			ls.stopNo,
			ls.loadType,
			ISNULL(ls.stopDate,l.orderdate) as pickUpDate,
			ls.custname as shipperName,
			ls.address as shipperAddress,
			ls.city as shipperCity,
			ls.statecode as shipperState,
			ls.postalcode as shipperZip,
			ls.Phone as shipperPhone,
			(select ls1.custname from loadstops ls1 where ls1.loadid = l.loadid and ls1.stopno = ls.stopno and ls1.LoadType = 2) AS consigneeName,
			(select ls1.address from loadstops ls1 where ls1.loadid = l.loadid and ls1.stopno = ls.stopno and ls1.LoadType = 2) AS consigneeAddress,
			(select ls1.city from loadstops ls1 where ls1.loadid = l.loadid and ls1.stopno = ls.stopno and ls1.LoadType = 2) AS consigneeCity,
			(select ls1.statecode from loadstops ls1 where ls1.loadid = l.loadid and ls1.stopno = ls.stopno and ls1.LoadType = 2) AS consigneeState,
			(select ls1.postalcode from loadstops ls1 where ls1.loadid = l.loadid and ls1.stopno = ls.stopno and ls1.LoadType = 2) AS consigneeZip,
			(select ls1.Phone from loadstops ls1 where ls1.loadid = l.loadid and ls1.stopno = ls.stopno and ls1.LoadType = 2) AS consigneePhone,
			ls.RefNo AS InternalRef,
			l.CustomerPONo,
			l.TotalMiles AS customerTotalMiles,
			l.carrierNotes,
			ISNULL(ls.NewDriverName,ls.NewDriverName2) AS DriverName
			FROM 
			Loads  l
			INNER JOIN loadstops ls ON ls.loadid = l.loadid
			WHERE l.loadid = <cfqueryparam value="#url.Loadid#" cfsqltype="cf_sql_varchar">
			AND LoadType = 1
			ORDER BY ls.stopno,ls.LoadType
		</cfquery>
		
		<cfset customPath = "">
		<cfquery name="qGetCompany" datasource="#local.dsn#">
			select CompanyCode from Companies where companyid = <cfqueryparam value="#session.companyid#" cfsqltype="cf_sql_varchar">
		</cfquery>

		<cfif len(trim(qGetCompany.companycode)) and directoryExists(expandPath("../reports/#trim(qGetCompany.companycode)#"))>
			<cfset customPath = "#trim(qGetCompany.companycode)#">
		</cfif>
		<cfif len(trim(customPath)) and fileExists(expandPath("../reports/#trim(customPath)#/BOLReportPreprinted.cfr"))>
			<cfset tempRootPath = expandPath("../reports/#trim(customPath)#/BOLReportPreprinted.cfr")>
		<cfelse>
			<cfset tempRootPath = expandPath("../reports/BOLReportPreprinted.cfr")>
		</cfif>
		<cfreport format="pdf" template="#tempRootPath#" query="#qgetLoadDetail#" name="result">

		</cfreport>
		<cfset fileName = "BOL Report Date-#DateFormat(Now(),'mm.dd.yyyy')#.pdf">
		<cfheader name="Content-Disposition" value="inline; filename=#fileName#">
		<cfcontent type="application/pdf" variable="#tobinary(result)#">
		<cfcatch>
			<cfdump var="#cfcatch#"><cfabort>
			Unable to generate report.
		</cfcatch>
	</cftry>
</cfoutput>