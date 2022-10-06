<!---cfinclude template="../webroot/Application.cfm"--->

<cfif structkeyexists(url,"loadno") or structkeyexists(url,"loadid")>

	<cfquery name="careerReport" datasource="#Application.dsn#">
		SELECT *, 
			(SELECT sum(weight)  from vwCarrierRateConfirmation 
			   <cfif structkeyexists(url,"loadno")>
			WHERE  (LoadNumber = <cfqueryparam value="#url.Loadno#" cfsqltype="cf_sql_varchar">)
		<cfelseif structkeyexists(url,"loadid")>
			WHERE  (LoadID = <cfqueryparam value="#url.LoadID#" cfsqltype="cf_sql_varchar">)
	   </cfif>
			 GROUP BY loadnumber) as TotalWeight 
		FROM vwCarrierRateConfirmation
	  <cfif structkeyexists(url,"loadno")>
			WHERE  (LoadNumber = <cfqueryparam value="#url.Loadno#" cfsqltype="cf_sql_varchar">)
		<cfelseif structkeyexists(url,"loadid")>
			WHERE  (LoadID = <cfqueryparam value="#url.LoadID#" cfsqltype="cf_sql_varchar">)
	   </cfif>
	   	   ORDER BY stopnum 
	</cfquery>
	 <cfoutput>

	<cfreport format="PDF" template="loadReportForCarrierConfirmation.cfr" style="../webroot/styles/reportStyle.css" query="#careerReport#" name="result"> 

	<!---	<cfreport format="PDF" template="LoadReportForDispatch.cfr" style="../webroot/styles/reportStyle.css" query="#careerReport#"> 
		<cfreportParam name="ReportDate" value="#DateFormat(Now(),'mm/dd/yyyy')#"> 
    --->
	</cfreport> 
	<cfset fileName = "Carrier Rate Confirmation Load ###careerReport.LoadNumber# Date-#DateFormat(Now(),'mm.dd.yyyy')#.pdf">
	<cfheader name="Content-Disposition" value="inline; filename=#fileName#">
	<cfcontent type="application/pdf" variable="#tobinary(result)#">
	</cfoutput>	 
<cfelse>
	Unable to generate the report. Please specify the load Number or Load ID	
</cfif>	