<cfsilent>
	<cfquery name="qMatchingCustomers" datasource="#Application.dsn#">
		SELECT C.CustomerID,C.CustomerCode,C.CustomerName,C.location,C.City,C.statecode,C.zipCode,(select top 1 contactperson from CustomerContacts CC where CC.CustomerID = c.CustomerID) as contactperson,
		(select top 1 phoneno from CustomerContacts CC where CC.CustomerID = c.CustomerID) as phoneno,
		(select top 1 fax from CustomerContacts CC where CC.CustomerID = c.CustomerID) as fax,
		(select Name from Employees E where E.EmployeeID = c.SalesRepID) as Salesperson,0 AS Invocies
		,C.Balance 
		,C.ConsolidateInvoices
		,(select sum(ART.total) from [LMA Accounts Receivable Transactions] ART where ART.CustomerID = c.CustomerID AND TRANS_NUMBER NOT IN (SELECT CAST(InvoicNumber AS VARCHAR(50)) FROM [LMA Accounts Receivable Payment Detail] WHERE CompanyID = <cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar">)
			AND ART.CompanyID = <cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar">) AS OpenInvoices

		FROM Customers C
		inner join (select
				    customerid
					from CustomerOffices c1 inner join offices o1 on o1.officeid = c1.OfficeID
					where o1.CompanyID = '#session.companyid#'
					group by customerid) Offices ON Offices.CustomerID = C.CustomerID
		WHERE 
		<cfif structKeyExists(url, "queryType") AND url.queryType EQ 'getCustomersByName'>C.CustomerName<cfelse>C.CustomerCode</cfif>  LIKE '#url.term#%'
		ORDER BY CustomerName
	</cfquery>	
</cfsilent>

<cfset thisArrayBecomesJSON = [] />
<cfloop query="qMatchingCustomers" group="CustomerID">
	{
		<cfset thisEvent = {
		"customerid" = "#qMatchingCustomers.CustomerID#",
		"customercode" = "#qMatchingCustomers.CustomerCode#",
		"name" = "#qMatchingCustomers.CustomerName#",
		"city" = "#qMatchingCustomers.City#",
		"state"= "#qMatchingCustomers.StateCode#",
		"invoices"= "#DollarFormat(qMatchingCustomers.Invocies)#",
		"location" = "#qMatchingCustomers.location#",
		"zip" = "#qMatchingCustomers.zipCode#",
		"contactPerson" = "#qMatchingCustomers.contactPerson#",
		"phoneNo" = "#qMatchingCustomers.phoneNo#",
		"fax" = "#qMatchingCustomers.fax#",
		"value" = "#qMatchingCustomers.CustomerName#",
		"Salesperson" = "#qMatchingCustomers.Salesperson#",
		"balance" = "#DollarFormat(qMatchingCustomers.balance)#",
		"openinvoices" = "#DollarFormat(qMatchingCustomers.openinvoices)#",
		"consolidateinvoices" = "#qMatchingCustomers.consolidateinvoices#"
		} />
	}
	<cfset arrayAppend( thisArrayBecomesJSON, thisEvent ) />
</cfloop>
		
		
	
<cfset myJSON = serializeJSON( thisArrayBecomesJSON ) />
<cfoutput>#myJSON#</cfoutput>