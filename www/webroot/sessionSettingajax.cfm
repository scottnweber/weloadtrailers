<cfif structkeyexists(url,"checked") and structkeyexists(url,"searchText") and structkeyexists(url,"csfrToken")>
	<cfset validate = CSRFverifyToken(csfrToken)> 
	<cfif validate>
		<cfif url.checked>		
			<cfset session.searchtext = url.searchText>
		<cfelse>
			<cfset session.searchtext = ''>
		</cfif>
	</cfif>	
<cfelseif structkeyexists(url,"showStatus") and structkeyexists(url,"csfrToken")>
	<cfset validate = CSRFverifyToken(csfrToken)> 
	<cfif validate>	
		<cfif url.showStatus>
			<cfset session.showloadtypestatusonloadsscreen = 1>
		<cfelse>
			<cfset session.showloadtypestatusonloadsscreen = 0>
		</cfif>
	</cfif>	
</cfif>
