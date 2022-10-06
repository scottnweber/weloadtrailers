<cfdump var="#application#">
<cfdump var="#DateTimeFormat(now(), 'dd/mm/yyyy hh:nn tt')#">
<cfset objDS = createobject("java","coldfusion.server.ServiceFactory").getDatasourceService()>
<cfdump var="#objDS#">
<cfdump var="#objDS.getNames()#">
<cfabort>



<cfloop collection="#objDS#" item="Key">
	<cfif len(objDS[Key]["password"])>
	<tr>
	<td>#objDS[key].name#</td>
	<td>#objDS[key].username#</td>
	</tr>
	</cfif>
</cfloop>

<!---
<cfset objDS = createobject("java","coldfusion.server.ServiceFactory").getDatasourceService().getDatasources() />
<cfdump var="#objDS#"> --->

