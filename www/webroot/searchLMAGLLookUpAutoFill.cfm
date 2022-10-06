<cfsilent>
	<cfquery name="qMatchingRecords" datasource="#Application.dsn#">
		SELECT [#url.fieldName#] AS Result FROM [LMA General Ledger Transactions]
		WHERE [#url.fieldName#] LIKE '#url.term#%'
		AND CompanyID = '#session.companyid#'
		ORDER BY Result
	</cfquery>	
</cfsilent>

<cfset thisArrayBecomesJSON = [] />
<cfloop query="qMatchingRecords" group="Result">
	{
		<cfset thisEvent = {
		"value" = "#qMatchingRecords.Result#"
		} />
	}
	<cfset arrayAppend( thisArrayBecomesJSON, thisEvent ) />
</cfloop>
		
		
	
<cfset myJSON = serializeJSON( thisArrayBecomesJSON ) />
<cfoutput>#myJSON#</cfoutput>