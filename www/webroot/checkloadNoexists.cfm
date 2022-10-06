<cfif isdefined("url.val") and url.val neq "">
 <cfsilent>
 	<cfset local.carrierId = url.carID />
	<cfset local.loadManualNumber = url.val />
	<cfset local.existingloadManualNo = url.extLN />
	<cfset local.CompanyID = url.CompanyID />
 	<!--- get system settings --->
 	<cfset local.withIdentifier = 0/>
 	<cfquery name="local.qSystemSetupOptions" datasource="#varDsn#">
	    SELECT IsConcatCarrierDriverIdentifier, freightBroker FROM SystemConfig where companyid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#local.companyid#">
	</cfquery>

	<cfif (local.qSystemSetupOptions.IsConcatCarrierDriverIdentifier EQ 1) AND local.qSystemSetupOptions.freightBroker EQ 2>
		<cfset addIdentifier = 0>
		<cfset replaceIdentifier = 0>
		<cfquery name="local.IsExists" datasource="#varDsn#">
			SELECT TOP 1 CarrierID FROM Loads WHERE LoadNumber = #local.loadManualNumber#
			and customerid in (select customerid from CustomerOffices inner join offices on CustomerOffices.officeid = offices.officeid where offices.companyid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#local.companyid#">)
		</cfquery>

		<cfif len(trim(local.carrierId)) >
			<cfif (local.IsExists.recordcount GE 1) AND (len(trim(local.IsExists.CarrierID)) LE 0)>
				<cfset addIdentifier = 1 >	
			</cfif>

			<cfif (local.IsExists.recordcount GE 1) AND len(trim(local.IsExists.CarrierID)) AND (local.IsExists.CarrierID NEQ local.carrierId) AND (local.existingloadManualNo EQ local.loadManualNumber)>
				<cfset replaceIdentifier = 1>
				<cfset addIdentifier = 1>
			</cfif>

			<cfif local.existingloadManualNo NEQ local.loadManualNumber>	
				<cfset addIdentifier = 1>
			</cfif>

			<cfif addIdentifier EQ 1>
				<cfif replaceIdentifier EQ 1 AND (left(local.loadManualNumber, 1) eq 1 OR left(local.loadManualNumber, 1) eq 2)>
					<cfset local.loadManualNumber = RIGHT(local.loadManualNumber, LEN(local.loadManualNumber) - 1)>
				</cfif>
				<!--- get carrier type  --->
				<cfquery name="carrierType" datasource="#varDsn#">
					SELECT IsCarrier FROM Carriers WHERE CarrierID = '#local.carrierId#' 			
				</cfquery>

				<cfif carrierType.IsCarrier EQ 1>
					<!--- prepend the digit 1 to the loadManualNumber--->
					<cfset url.val = 1&local.loadManualNumber>
				<cfelse>
					<!--- prepend the digit 2 to the loadManualNumber--->
					<cfset url.val = 2&local.loadManualNumber>	
				</cfif>				
				<cfset local.withIdentifier = 1/>	
			</cfif>			
		</cfif>

		<cfif (len(trim(local.carrierId)) LE 0) AND len(trim(local.existingloadManualNo)) AND (local.existingloadManualNo EQ local.loadManualNumber) AND (local.IsExists.recordcount GE 1) AND len(trim(local.IsExists.CarrierID))>
			<cfif left(local.loadManualNumber, 1) eq 1 OR left(local.loadManualNumber, 1) eq 2>
				<cfset url.val = RIGHT(local.loadManualNumber, LEN(local.loadManualNumber) - 1)>
				<cfset local.withIdentifier = 1/>	
			</cfif>
		</cfif>
	</cfif>

	<cfquery name="getEarlierCustName" datasource="#varDsn#">
		SELECT TOP 1 LoadID,LoadNumber 
		FROM Loads L WITH (NOLOCK)
		INNER JOIN CustomerOffices CO WITH (NOLOCK) ON CO.CustomerID = L.CustomerID
		INNER JOIN Offices O WITH (NOLOCK) ON O.OfficeID = CO.OfficeID
		WHERE L.LoadNumber=<cfqueryparam cfsqltype="cf_sql_bigint" value="#url.val#"> AND O.CompanyID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#local.companyid#">
	</cfquery>
</cfsilent>
	<cfoutput>
	<cfif getEarlierCustName.recordcount gt 0 AND local.withIdentifier EQ 1 >	
		<cfset cnt=url.val>#url.val#
	<cfelseif getEarlierCustName.recordcount gt 0>
		<cfset cnt=1>#cnt#
	<cfelse>
		<cfset cnt=0>#cnt#
	</cfif>
	</cfoutput>
</cfif>