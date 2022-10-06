<cfsilent>
	<cfquery name="qMatchingVendors" datasource="#Application.dsn#">
		SELECT C.CarrierID,C.VendorID,C.CarrierName,C.Address,'' AS Address2,C.City,C.StateCode,C.ZipCode,C.Balance
		,(select top 1 contactperson from CarrierContacts CC where CC.CarrierID = c.CarrierID) as contactperson
		,(select top 1 phoneno from CarrierContacts CC where CC.CarrierID = c.CarrierID) as phoneno
		,(select top 1 fax from CarrierContacts CC where CC.CarrierID = c.CarrierID) as fax
		 FROM  Carriers C
		WHERE 
		<cfif structKeyExists(url, "queryType") AND url.queryType EQ 'getCustomersByName'>
			C.CarrierName
		<cfelse>
			C.VendorID 
		</cfif> LIKE '#url.term#%'
		AND C.IsCarrier = 1
		<cfif structKeyExists(url, "showCarriersWithBalance")>
			AND C.Balance > 0
		</cfif>
		AND C.CompanyID = <cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar">
		ORDER BY C.CarrierName
	</cfquery>		
</cfsilent>

<cfset thisArrayBecomesJSON = [] />
<cfloop query="qMatchingVendors" group="VendorID">
	{
		<cfset thisEvent = {
		"vendorid" = "#qMatchingVendors.VendorID#",
		"company" = "#qMatchingVendors.CarrierName#",
		"value" = "#qMatchingVendors.CarrierName#",
		"address1" = "#qMatchingVendors.address#",
		"address2" = "#qMatchingVendors.address2#",
		"city" = "#qMatchingVendors.City#",
		"state"= "#qMatchingVendors.StateCode#",
		"zip"= "#qMatchingVendors.ZipCode#",
		"balance"= "#DollarFormat(qMatchingVendors.Balance)#",
		"contactPerson" = "#qMatchingVendors.contactPerson#",
		"phoneNo" = "#qMatchingVendors.phoneNo#",
		"fax" = "#qMatchingVendors.fax#",
		"carrierid" = "#qMatchingVendors.CarrierID#"
		} />
	}
	<cfset arrayAppend( thisArrayBecomesJSON, thisEvent ) />
</cfloop>
		
		
	
<cfset myJSON = serializeJSON( thisArrayBecomesJSON ) />
<cfoutput>#myJSON#</cfoutput>