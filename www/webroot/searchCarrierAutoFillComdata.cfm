<cfoutput>
	<cfset LoadNumber = url.LoadNumber>

	<cfquery name="qrygetCarrierCustomerByLoadNo" datasource="#Application.dsn#">
		SELECT LoadNumber,C.CarrierName, CS.CustomerName, OrderDate from Loads L
		INNER JOIN Carriers C on L.CarrierID = C.CarrierID
		INNER JOIN Customers CS on L.CustomerID = CS.CustomerID
		WHERE LoadNumber like '%#LoadNumber#%'		
		AND StatusTypeID in (select statustypeid from LoadStatusTypes where statustext between '1. ACTIVE' AND '8. COMPLETED') 
		and L.customerid in (select customerid from CustomerOffices inner join offices on CustomerOffices.officeid = offices.officeid where offices.companyid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#url.companyid#">)
	</cfquery>

	
</cfoutput>
<cfset loadnumbeArray  = []>

<cfloop query="qrygetCarrierCustomerByLoadNo">
<cfset loadnumberDetails  = {
				"label": "#replace(TRIM(qrygetCarrierCustomerByLoadNo.LoadNumber),'"','&apos;','all')#",
				"value": "#replace(TRIM(qrygetCarrierCustomerByLoadNo.LoadNumber),'"','&apos;','all')#",
				"loadno": "#replace(TRIM(qrygetCarrierCustomerByLoadNo.LoadNumber),'"','&apos;','all')#",
				"carrier": "#replace(TRIM(qrygetCarrierCustomerByLoadNo.CarrierName),'"','&apos;','all')#",
				"customer" : "#replace(TRIM(qrygetCarrierCustomerByLoadNo.CustomerName),'"','&apos;','all')#",
				"orderdate": "#replace(TRIM(qrygetCarrierCustomerByLoadNo.OrderDate),'"','&apos;','all')#"
			}>
	<cfset arrayAppend(loadnumbeArray,loadnumberDetails)>		
</cfloop>

<cfoutput>#serializeJson(loadnumbeArray)#</cfoutput>







