<cfoutput>
<cfif structkeyExists(url,"dsn")>
<!--- Decrypt String --->
<cfset TheKey = 'NAMASKARAM'>
<cfset dsn = Decrypt(ToString(ToBinary(url.dsn)), TheKey)>
</cfif>
<cfif structkeyexists(url,"loadno") or structkeyexists(url,"loadid")>
	<cfquery name="careerReport" datasource="#dsn#">
		SELECT *, 
			(SELECT sum(weight)  from vwCarrierConfirmationReport 
			   <cfif structkeyexists(url,"loadno")>
					WHERE  (LoadNumber = <cfqueryparam value="#url.Loadno#" cfsqltype="cf_sql_varchar">)
				<cfelseif structkeyexists(url,"loadid")>
					WHERE  (LoadID = <cfqueryparam value="#url.LoadID#" cfsqltype="cf_sql_varchar">)
			   </cfif>
			 GROUP BY loadnumber) as TotalWeight 
		FROM vwCustomerInvoiceReport
	   <cfif structkeyexists(url,"loadno")>
			WHERE  (LoadNumber = <cfqueryparam value="#url.Loadno#" cfsqltype="cf_sql_varchar">)
		<cfelseif structkeyexists(url,"loadid")>
			WHERE  (LoadID = <cfqueryparam value="#url.LoadID#" cfsqltype="cf_sql_varchar">)
	   </cfif>
	   	   ORDER BY stopnum 
	</cfquery> 

	<cfset careerReportNew = QueryNew(careerReport.columnList&",shipperStopNum,conStopNum")> 
		<cfset QueryAddRow(careerReportNew, careerReport.recordcount)>
		<cfset indx = 0>
		<cfset prevStopID = "">
		<cfloop query="careerReport">
			<cfloop list="#careerReportNew.columnList#" index="key">
				<cfif not listFindNoCase("shipperStopNum,conStopNum", key)>
					<cfset QuerySetCell(careerReportNew, key, evaluate("careerReport.#key#") , careerReport.currentrow)> 
					<cfif not len(trim(careerReport.totalweight))>
						<cfset QuerySetCell(careerReportNew, "totalweight", 0 , careerReport.currentrow)> 
					</cfif>
					<cfif not len(trim(careerReport.weight))>
						<cfset QuerySetCell(careerReportNew, "weight", 0 , careerReport.currentrow)> 
					</cfif>
					<cfif not len(trim(careerReport.Custcharges))>
					<cfset QuerySetCell(careerReportNew, "Custcharges", 0 , careerReport.currentrow)> 
					</cfif>
					<cfif not len(trim(careerReport.Carrcharges))>
						<cfset QuerySetCell(careerReportNew, "Carrcharges", 0 , careerReport.currentrow)> 
					</cfif>
				</cfif>
			</cfloop>
			<cfif (prevStopID NEQ careerReport.loadstopid) AND (len(trim(careerReport.shipperName)) OR len(trim(careerReport.ShipperAddress)) OR len(trim(careerReport.Shippercity)) OR len(trim(careerReport.Shipperstate)) OR len(trim(careerReport.Shipperzip)))>
				<cfset indx++>
				<cfset QuerySetCell(careerReportNew, "shipperStopNum", indx , careerReport.currentrow)> 
			</cfif>
			<cfif (prevStopID NEQ careerReport.loadstopid) AND (len(trim(careerReport.conName)) OR len(trim(careerReport.conAddress)) OR len(trim(careerReport.concity)) OR len(trim(careerReport.constate)) OR len(trim(careerReport.conzip)))>
				<cfset indx++>
				<cfset QuerySetCell(careerReportNew, "conStopNum", indx , careerReport.currentrow)> 
			</cfif>	
			<cfset prevStopID = careerReport.loadstopid>
		</cfloop>
    
    <cfset customPath = "">
	<cfquery name="qGetCompany" datasource="#dsn#">
		select CompanyCode from Companies  WHERE CompanyID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#session.CompanyID#" >
	</cfquery>

	<cfif len(trim(qGetCompany.companycode)) and directoryExists(expandPath("../reports/#trim(qGetCompany.companycode)#"))>
		<cfset customPath = "#trim(qGetCompany.companycode)#">
	</cfif>
	<cfif len(trim(customPath)) and fileExists(expandPath("../reports/#trim(customPath)#/CustomerInvoiceReport.cfr"))>
		<cfset tempRootPath = expandPath("../reports/#trim(customPath)#/CustomerInvoiceReport.cfr")>
	<cfelse>
		<cfset tempRootPath = expandPath("../reports/CustomerInvoiceReport.cfr")>
	</cfif>

	<cfreport format="PDF" template="#tempRootPath#" style="../webroot/styles/reportStyle.css" query="#careerReportNew#" name="result"> 
		<cfreportParam name="ReportDate" value="#DateFormat(Now(),'mm/dd/yyyy')#"> 
	</cfreport> 
	<cfset fileName = "Customer Confirmation Load ###careerReport.LoadNumber# Date-#DateFormat(Now(),'mm.dd.yyyy')#.pdf">
	<cfheader name="Content-Disposition" value="inline; filename=#fileName#">
	<cfcontent type="application/pdf" variable="#tobinary(result)#">	 
<cfelse>
	Unable to generate the report. Please specify the load Number or Load ID	
</cfif>
</cfoutput>