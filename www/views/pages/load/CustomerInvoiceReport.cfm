<cfoutput>
<cfinclude template="../webroot/Application.cfc">
<cfif structkeyexists(url,"loadno") or structkeyexists(url,"loadid")>
	<cfquery name="careerReport" datasource="#Application.dsn#">
		SELECT *, 
			(SELECT sum(weight)  from vwCarrierConfirmationReport 
			   <cfif structkeyexists(url,"loadno")>
					WHERE  (LoadNumber =<cfqueryparam value="#url.loadno#" cfsqltype="cf_sql_varchar">)
				<cfelseif structkeyexists(url,"loadid")>
					WHERE  (LoadID = <cfqueryparam value="#url.loadid#" cfsqltype="cf_sql_varchar">)
			   </cfif>
			 GROUP BY loadnumber) as TotalWeight 
		FROM vwCustomerInvoiceReport
	   <cfif structkeyexists(url,"loadno")>
			WHERE  (LoadNumber = <cfqueryparam value="#url.loadno#" cfsqltype="cf_sql_varchar">)
		<cfelseif structkeyexists(url,"loadid")>
			WHERE  (LoadID = <cfqueryparam value="#url.loadid#" cfsqltype="cf_sql_varchar">)
	   </cfif>
	   	   ORDER BY stopnum 
	</cfquery> 
    
     <cfset customPath = "">
	<cfquery name="qGetCompany" datasource="#Application.dsn#">
		select CompanyCode from Companies where companyid = <cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar">
	</cfquery>

	<cfif len(trim(qGetCompany.companycode)) and directoryExists(expandPath("../reports/#trim(qGetCompany.companycode)#"))>
		<cfset customPath = "#trim(qGetCompany.companycode)#">
	</cfif>
	<cfif len(trim(customPath)) and fileExists(expandPath("../reports/#trim(customPath)#/CustomerInvoiceReport.cfr"))>
		<cfset tempRootPath = expandPath("../reports/#trim(customPath)#/CustomerInvoiceReport.cfr")>
	<cfelse>
		<cfset tempRootPath = expandPath("../reports/CustomerInvoiceReport.cfr")>
	</cfif>

	<cfreport format="PDF" template="#tempRootPath#" style="../webroot/styles/reportStyle.css" query="#careerReport#"> 
		<cfreportParam name="ReportDate" value="#DateFormat(Now(),'mm/dd/yyyy')#"> 
	</cfreport> 	 
<cfelse>
	Unable to generate the report. Please specify the load Number or Load ID	
</cfif>
</cfoutput>