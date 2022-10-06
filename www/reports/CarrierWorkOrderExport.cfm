<cfif structkeyExists(url,"dsn")>
<!--- Decrypt String --->
<cfset TheKey = 'NAMASKARAM'>
<cfset dsn = Decrypt(ToString(ToBinary(url.dsn)), TheKey)>
</cfif>

<cfif structkeyexists(url,"loadno") or structkeyexists(url,"loadid")>

	<cfquery name="careerReport" datasource="#dsn#">
		SELECT *, 
			(SELECT sum(weight)  from vwCarrierInterWOExport 
			   <cfif structkeyexists(url,"loadno")>
					WHERE  (LoadNumber =  <cfqueryparam value="#url.Loadno#" cfsqltype="cf_sql_varchar">)
				<cfelseif structkeyexists(url,"loadid")>
					WHERE  (LoadID =  <cfqueryparam value="#url.LoadID#" cfsqltype="cf_sql_varchar">)
			   </cfif>
			 GROUP BY loadnumber) as TotalWeight 
		FROM vwCarrierInterWOExport
	   <cfif structkeyexists(url,"loadno")>
			WHERE  (LoadNumber =  <cfqueryparam value="#url.Loadno#" cfsqltype="cf_sql_varchar">)
		<cfelseif structkeyexists(url,"loadid")>
			WHERE  (LoadID =  <cfqueryparam value="#url.LoadID#" cfsqltype="cf_sql_varchar">)
	   </cfif>
	   	   ORDER BY stopnum 
	</cfquery>
	 <cfoutput>
	<cfreport format="PDF" template="CarrierWorkOrderExport.cfr" style="../webroot/styles/reportStyle.css" query="#careerReport#"> 
		<cfreportParam name="ReportDate" value="#DateFormat(Now(),'mm/dd/yyyy')#"> 
	</cfreport> 
	</cfoutput>	 
<cfelse>
	Unable to generate the report. Please specify the load Number or Load ID	
</cfif>	