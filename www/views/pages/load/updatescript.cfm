<cfquery name="getLoads" datasource="mps">
	select distinct loadid,customerid,loadstopid from loadstops where customerid is not null and  StateCode=''
</cfquery>

<cfdump var="recordcount:#getLoads.recordcount#">
<cfloop query="getloads">
	<cfdump var="#loadstopid#,">
	<cfquery name="getcustomerinformation" datasource="mps">
		select customers.*,states.* from customers left join states on customers.stateid = states.stateid where customerid = <cfqueryparam value="#getloads.customerid#" cfsqltype="cf_sql_varchar">
	</cfquery>
	
	<cfquery name="updateLoadstops" datasource="mps">
		update loadstops set statecode=<cfqueryparam value="#getcustomerinformation.statecode#" cfsqltype="cf_sql_varchar"> where loadstopid=<cfqueryparam value="#getloads.loadstopid#" cfsqltype="cf_sql_varchar">
	</cfquery>	

</cfloop>