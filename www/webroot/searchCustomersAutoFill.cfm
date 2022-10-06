<cfparam name="variables.contacttype" default="General">
<cfparam name="url.queryType" default="getCustomers">

<cfif structKeyExists(url, "queryType") AND url.queryType EQ 'getCustomers'>
	<cfset variables.contacttype = 'Billing'>
<cfelseif structKeyExists(url, "queryType") AND url.queryType EQ 'getShippers'>
	<cfset variables.contacttype = 'Dispatch'>
</cfif>

<cfsilent>
	<cfif listFindNoCase("getCity,GetZip,GetState", url.queryType)>
		<cfquery name="GetCitySelected" datasource="#Application.dsn#">
			select *
			from postalcode		
			<cfif url.queryType EQ 'GetCity'>
				WHERE City LIKE <cfqueryparam value="#url.term#%" cfsqltype="cf_sql_varchar">		
				ORDER BY City
			<cfelseif url.queryType EQ 'GetZip'>
				WHERE PostalCode LIKE <cfqueryparam value="#url.term#%" cfsqltype="cf_sql_varchar">
				ORDER BY PostalCode	
			<cfelseif url.queryType EQ 'GetState'>
					where StateCode LIKE <cfqueryparam value="#url.term#%" cfsqltype="cf_sql_varchar">
					ORDER BY StateCode		
			</cfif>
		</cfquery>
	<cfelseif url.queryType EQ 'getZipCityState'>
		<cfquery name="qGetZipCityState" datasource="#Application.dsn#">
			<cfif isNumeric(url.term)>
				SELECT City,StateCode,PostalCode FROM PostalCode
				WHERE PostalCode LIKE <cfqueryparam value="#url.term#%" cfsqltype="cf_sql_varchar">
				GROUP BY City,StateCode,PostalCode
				ORDER BY PostalCode	
			<cfelse>
				SELECT City,StateCode FROM PostalCode
				WHERE City LIKE <cfqueryparam value="#url.term#%" cfsqltype="cf_sql_varchar">
				GROUP BY City,StateCode
				ORDER BY City	
			</cfif>
		</cfquery>
	<cfelse>
		<cfquery name="qMatchingCustomers" datasource="#Application.dsn#">

			SELECT 
			Customers.CustomerName,
			Customers.City,
			Customers.StateCode,
			Customers.zipCode,
			Customers.CustomerID,
			Customers.Location,
			Customers.ContactPerson,
			Customers.phoneNo,
			Customers.PhoneNoExt,
			Customers.personMobileNo,
			Customers.fax,
			Customers.email,
			Customers.creditLimit,
			Customers.balance,
			Customers.available,
			Customers.CustomerNotes,
			CAST(Customers.CustomerDirections AS NVARCHAR(MAX)) AS CustomerDirections,
			Customers.AcctMGRID,
			Customers.SalesRepID,
			Customers.IsPayer,
			Customers.CarrierNotes,
			Customers.DefaultCurrency,
			Customers.LockSalesAgentOnLoad,
			Customers.LockDispatcherOnLoad,
			Customers.ConsolidateInvoices,
			Customers.TimeZone,
			ISNULL(F.FF,S.FactoringFee) AS FF,
			Customers.billfromcompany,
			Customers.SalesRepID2,
			Customers.AcctMGRID2,
			Customers.LockDispatcher2OnLoad
			FROM Customers
			INNER JOIN CustomerOffices CO ON Customers.CustomerID = CO.CustomerID
			INNER JOIN Offices O ON O.OfficeID = CO.OfficeID
			INNER JOIN SystemConfig S ON S.CompanyID = O.CompanyID
			LEFT JOIN Factorings F ON F.FactoringID = Customers.FactoringID
			WHERE O.CompanyID = 
			<cfif structKeyExists(session, "companyid")>
				<cfqueryparam value="#session.companyid#" cfsqltype="cf_sql_varchar">
			<cfelseif structKeyExists(url, "companyid")>
				<cfqueryparam value="#url.companyid#" cfsqltype="cf_sql_varchar">
			<cfelse>
				<cfqueryparam value="" cfsqltype="cf_sql_varchar" null="true">
			</cfif>
			AND Customers.CustomerName LIKE <cfqueryparam value="#url.term#%" cfsqltype="cf_sql_varchar">
			<cfif url.queryType EQ 'getCustomers'>
				AND IsPayer = <cfqueryparam value="true" cfsqltype="cf_sql_bit">
			</cfif>	
			<cfif StructKeyExists(session,"currentusertype") AND listfindnocase("sales representative,dispatcher,manager",session.currentusertype) >
	 			<cfif NOT ListContains(session.rightsList,'showAllOfficeCustomers',',')>
	 				AND O.OfficeID = <cfqueryparam value="#session.officeid#" cfsqltype="cf_sql_varchar">
	 			</cfif>
	 		</cfif>
			GROUP BY 
			Customers.CustomerName,
			Customers.City,
			Customers.StateCode,
			Customers.zipCode,
			Customers.CustomerID,
			Customers.Location,
			Customers.ContactPerson,
			Customers.phoneNo,
			Customers.PhoneNoExt,
			Customers.personMobileNo,
			Customers.fax,
			Customers.email,
			Customers.creditLimit,
			Customers.balance,
			Customers.available,
			Customers.CustomerNotes,
			CAST(Customers.CustomerDirections AS NVARCHAR(MAX)),
			Customers.AcctMGRID,
			Customers.SalesRepID,
			Customers.IsPayer,
			Customers.CarrierNotes,
			Customers.DefaultCurrency,
			Customers.LockSalesAgentOnLoad,
			Customers.LockDispatcherOnLoad,
			Customers.ConsolidateInvoices,
			Customers.TimeZone,
			F.FF,
			S.FactoringFee,
			Customers.billfromcompany,
			Customers.SalesRepID2,
			Customers.AcctMGRID2,
			Customers.LockDispatcher2OnLoad
			<cfif url.queryType NEQ 'getCustomers'>
				UNION
				SELECT 
				CustomerStops.CustomerStopName AS CustomerName,
				CustomerStops.City,
				(SELECT StateCode FROM States WHERE StateID = CustomerStops.StateID) AS StateCode,
				CustomerStops.PostalCode AS zipCode,
				'00000000-0000-0000-0000-000000000000' AS CustomerID,
				CustomerStops.Location,
				CustomerStops.ContactPerson,
				CustomerStops.phone,
				NULL AS PhoneNoExt,
				CustomerStops.CellNo AS personMobileNo,
				CustomerStops.fax,
				CustomerStops.EmailID AS email,
				0 AS creditLimit,
				0 AS balance,
				0 AS available,
				CAST(CustomerStops.NewInstructions AS NVARCHAR(MAX)) AS CustomerNotes,
				CAST(CustomerStops.NewDirections AS NVARCHAR(MAX)) AS CustomerDirections,
				NULL AS AcctMGRID,
				NULL AS SalesRepID,
				0 AS IsPayer,
				NULL AS CarrierNotes,
				NULL AS DefaultCurrency,
				0 AS LockSalesAgentOnLoad,
				0 AS LockDispatcherOnLoad,
				0 AS ConsolidateInvoices,
				NULL AS TimeZone,
				S.FactoringFee AS FF,
				NULL AS billfromcompany,
				NULL AS SalesRepID2,
				NULL AS AcctMGRID2,
				0 AS LockDispatcher2OnLoad
				FROM CustomerStops
				INNER JOIN CustomerOffices CO ON CustomerStops.CustomerID = CO.CustomerID
				INNER JOIN Offices O ON O.OfficeID = CO.OfficeID
				INNER JOIN SystemConfig S ON S.CompanyID = O.CompanyID
				WHERE O.CompanyID = 
				<cfif structKeyExists(session, "companyid")>
					<cfqueryparam value="#session.companyid#" cfsqltype="cf_sql_varchar">
				<cfelseif structKeyExists(url, "companyid")>
					<cfqueryparam value="#url.companyid#" cfsqltype="cf_sql_varchar">
				<cfelse>
					<cfqueryparam value="" cfsqltype="cf_sql_varchar" null="true">
				</cfif>
				AND CustomerStops.CustomerStopName LIKE <cfqueryparam value="#url.term#%" cfsqltype="cf_sql_varchar">	
				<cfif StructKeyExists(session,"currentusertype") AND listfindnocase("sales representative,dispatcher,manager",session.currentusertype) >
		 			<cfif NOT ListContains(session.rightsList,'showAllOfficeCustomers',',')>
		 				AND O.OfficeID = <cfqueryparam value="#session.officeid#" cfsqltype="cf_sql_varchar">
		 			</cfif>
		 		</cfif>
				GROUP BY 
				CustomerStops.CustomerStopName,
				CustomerStops.City,
				CustomerStops.StateID,
				CustomerStops.PostalCode,
				CustomerStops.Location,
				CustomerStops.ContactPerson,
				CustomerStops.phone,
				CustomerStops.CellNo,
				CustomerStops.fax,
				CustomerStops.EmailID,
				CAST(CustomerStops.NewInstructions AS NVARCHAR(MAX)),
				CAST(CustomerStops.NewDirections AS NVARCHAR(MAX)),
				S.FactoringFee
			</cfif>
			ORDER BY CustomerName,Zipcode,Location
		</cfquery>	
	</cfif>
</cfsilent>

<cfset thisArrayBecomesJSON = [] />
<cfif url.queryType EQ 'getCustomers'>
	<cfloop query="qMatchingCustomers">
		{
			<cfset thisEvent = {
			"label" = "#qMatchingCustomers.CustomerName#",
			"name" = "#qMatchingCustomers.CustomerName#",
			"city" = "#qMatchingCustomers.City#",
			"state"= "#qMatchingCustomers.StateCode#",
			"zip" = "#qMatchingCustomers.zipCode#",
			"value" = "#qMatchingCustomers.CustomerID#",
			"location" = "#qMatchingCustomers.location#",
			"contactPerson" = "#qMatchingCustomers.contactPerson#",
			"phoneNo" = "#qMatchingCustomers.phoneNo#",
			"phoneNoExt" = "#qMatchingCustomers.phoneNoExt#",
			"cellNo" = "#qMatchingCustomers.personMobileNo#",
			"fax" = "#qMatchingCustomers.fax#",
			"email" = "#qMatchingCustomers.email#",
			"creditLimit" = "#qMatchingCustomers.creditLimit#",
			"balance" = "#qMatchingCustomers.balance#",
			"available" = "#qMatchingCustomers.available#",
			"notes" = "#qMatchingCustomers.CustomerNotes#",
			"dispatchNotes" = "#qMatchingCustomers.CustomerDirections#",
			"dispatcher" = "#qMatchingCustomers.AcctMGRID#",
			"salesRep" = "#qMatchingCustomers.SalesRepID#",
			"isPayer" = "#qMatchingCustomers.IsPayer#",
			"CarrierNotes" = "#qMatchingCustomers.CarrierNotes#",
			"currency" = qMatchingCustomers.DefaultCurrency,
			"locksalesagentonload" = qMatchingCustomers.LockSalesAgentOnLoad,
			"lockdispatcheronload" = qMatchingCustomers.LockDispatcherOnLoad,
			"consolidateinvoices" = qMatchingCustomers.ConsolidateInvoices,
			"ff" = qMatchingCustomers.ff,
			"billfromcompany" = qMatchingCustomers.billfromcompany,
			"dispatcher2" = "#qMatchingCustomers.AcctMGRID2#",
			"salesRep2" = "#qMatchingCustomers.SalesRepID2#",
			"lockdispatcher2onload" = "#qMatchingCustomers.LockDispatcher2OnLoad#"
			} />
		}
		<cfset arrayAppend( thisArrayBecomesJSON, thisEvent ) />
	</cfloop>
<cfelseif url.queryType EQ 'getCity'>
	<cfloop query="GetCitySelected">
		<cfset thisEvent = {"city" = "#GetCitySelected.City#","value" = "#GetCitySelected.City#","state" = "#GetCitySelected.StateCode#","zip" = "#GetCitySelected.PostalCode#"} />
		<cfset arrayAppend( thisArrayBecomesJSON, thisEvent ) />
	</cfloop>
<cfelseif url.queryType EQ 'GetZip'>
	<cfloop query="GetCitySelected">
		<cfset thisEvent = {"zip" = "#GetCitySelected.PostalCode#","city" = "#GetCitySelected.City#","state" = "#GetCitySelected.StateCode#"} />
		<cfset arrayAppend( thisArrayBecomesJSON, thisEvent ) />
	</cfloop>
<cfelseif url.queryType EQ 'GetState'>
	<cfloop query="GetCitySelected" group="statecode">
		<cfset thisEvent = {"state" = "#GetCitySelected.StateCode#"} />
		<cfset arrayAppend( thisArrayBecomesJSON, thisEvent ) />
	</cfloop>
<cfelseif url.queryType EQ 'getZipCityState'>
	<cfloop query="qGetZipCityState">
		<cfif isNumeric(url.term)>
			<cfset thisEvent = {"showZip"=1,"city" = "#qGetZipCityState.city#","state" = "#qGetZipCityState.statecode#","zip" = "#qGetZipCityState.postalcode#"} />
		<cfelse>
			<cfset thisEvent = {"showZip"=0,"city" = "#qGetZipCityState.city#","state" = "#qGetZipCityState.statecode#"} />
		</cfif>
		<cfset arrayAppend( thisArrayBecomesJSON, thisEvent ) />
	</cfloop>
<cfelse>
	<cfloop query="qMatchingCustomers">
		{
			<cfset thisEvent = {
			"label" = "#qMatchingCustomers.CustomerName#",
			"name" = "#qMatchingCustomers.CustomerName#",
			"city" = "#qMatchingCustomers.City#",
			"state" = "#qMatchingCustomers.StateCode#",
			"value" = "#qMatchingCustomers.CustomerID#",
			"location" = "#qMatchingCustomers.location#",
			"zip" = "#qMatchingCustomers.Zipcode#",
			"contactPerson" = "#qMatchingCustomers.contactPerson#",
			"phoneNo" = "#qMatchingCustomers.phoneNo#",
			"phoneNoExt" = "#qMatchingCustomers.phoneNoExt#",
			"fax" = "#qMatchingCustomers.fax#",
			"email" = "#qMatchingCustomers.email#",
			"isPayer" = "#qMatchingCustomers.IsPayer#",
			"timezone" = "#qMatchingCustomers.TimeZone#",
			"CarrierNotes" = "#qMatchingCustomers.CarrierNotes#",
			"notes" = "#qMatchingCustomers.CustomerNotes#"
			} />
		}
		<cfset arrayAppend( thisArrayBecomesJSON, thisEvent ) />
	</cfloop>
</cfif>
<cfset myJSON = serializeJSON( thisArrayBecomesJSON ) />
<cfoutput>#myJSON#</cfoutput>