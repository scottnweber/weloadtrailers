<cfsilent>
	<cfquery name="GetCitySelected" datasource="#Application.dsn#">
		select *
		from postalcode
		
		<cfif url.queryType EQ 'GetCity'>
					where City LIKE <cfqueryparam value="#url.q#%" cfsqltype="cf_sql_varchar">		
					ORDER BY City
			<cfelseif url.queryType EQ 'GetZip'>
					where PostalCode LIKE <cfqueryparam value="#url.q#%" cfsqltype="cf_sql_varchar">
					ORDER BY PostalCode	
		</cfif>
	</cfquery>
</cfsilent>


	<cfset thisArrayBecomesJSON = [] />
	<cfloop query="GetCitySelected">
		<cfif url.queryType EQ 'getCity'>
			{
				<cfset thisEvent = {"city" = "#GetCitySelected.City#","state" = "#GetCitySelected.StateCode#","zip" = "#GetCitySelected.PostalCode#"} />
			}
		<cfelse>
			{
				<cfset thisEvent = {"zip" = "#GetCitySelected.PostalCode#","city" = "#GetCitySelected.City#","state" = "#GetCitySelected.StateCode#"} />
			}
		</cfif>
		<cfset arrayAppend( thisArrayBecomesJSON, thisEvent ) />
	</cfloop>
	
<cfset myJSON = serializeJSON( thisArrayBecomesJSON ) />
<cfoutput>#myJSON#</cfoutput>
