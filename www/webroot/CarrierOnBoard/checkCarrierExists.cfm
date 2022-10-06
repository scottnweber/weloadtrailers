<cfif not structKeyExists(url, "CarrierID") AND not structKeyExists(url, "CompanyID")>
	<cfoutput><h3>Carrier does not exists..!!</h3></cfoutput>
	<cfabort>
</cfif>
<cfif structKeyExists(url, "CarrierID") AND ((len(trim(url.CarrierID)) AND not isValid("regex", url.CarrierID,'^[{]?[0-9a-fA-F]{8}-([0-9a-fA-F]{4}-){3}[0-9a-fA-F]{12}[}]?$')) OR NOT len(trim(url.CarrierID)))>
	<cfoutput><h3>Carrier does not exists..!!</h3></cfoutput>
	<cfabort>
</cfif>
<cfif not structKeyExists(url, "CompanyID")>
	<cfinvoke component="cfc.carrier" method="CheckCarrierExist" returnVariable="CarrierStatus">
		<cfinvokeargument name="CarrierID" value="#url.CarrierID#">
	</cfinvoke>
	<cfif CarrierStatus EQ 0>
		<cfoutput><h3>Carrier does not exists..!!</h3></cfoutput>
		<cfabort>
	</cfif>
</cfif>