<cfcomponent output="true" extends="loadgateway">
<cfsetting showdebugoutput="no">

<cfif not structKeyExists(variables,"loadgatewayUpdate")>
	<cfscript>variables.objLoadgatewayUpdate = #request.cfcpath#&".loadgatewayUpdate";</cfscript>
</cfif>
<cfif not structKeyExists(variables,"objCustomerGateway")>
	<cfscript>variables.objCustomerGateway = #request.cfcpath#&".customergateway";</cfscript>
</cfif>

<!---cfif not structKeyExists(variables,"objPromilesGateway")>
	<cfscript>variables.objPromilesGateway = #request.cfcpath#&".promile";</cfscript>
</cfif--->
<cfif not structKeyExists(variables,"objPromilesGatewayTest")>
	<cfscript>variables.objPromilesGatewayTest = #request.cfcpath#&".promiles";</cfscript>
</cfif>

<cfset this.loadLogData = structNew()>
<cfset this.SelectForLoggingBefore = "">
<cfset this.SelectForLoggingAfter = "">

<cffunction name="init" access="public" output="false" returntype="void">
	<cfargument name="dsn" type="string" required="yes" />
	<cfset variables.dsn = Application.dsn />
</cffunction>

<!--- Validate EDI--->
<cffunction name="CheckEdi214" access="public" returntype="any">
	<cfargument name="frmstruct" type="struct" required="yes">

		<cfset Message=EditLoad(arguments.frmstruct)>
		<cfif IsDefined("arguments.frmstruct.EDIload") and arguments.frmstruct.ediload eq 1>
			<cfquery name="qryCheckEdiLoad" datasource="#variables.dsn#">
				SELECT IsEDI FROM loads WHERE IsEDI = 1 AND loadid =<cfqueryparam value="#arguments.frmstruct.editid#" cfsqltype="cf_sql_varchar">
			</cfquery>
			<cfif qryCheckEdiLoad.recordcount>
			<cfif getLoadStatus.statustext GT "0.1 EDI" AND getLoadStatus.statustext LT "9. Cancelled">		
	
				<cfset EDI214msg=EDI214Validate(arguments.frmstruct)>

				<!--- EDI 214 --->
				<cfif Len(EDI214msg)>	
					<cfquery name="qryUpdateOldStatus" datasource="#variables.dsn#">
						UPDATE Loads SET StatusTypeID = '#frmstruct.oldstatusval#' WHERE Loadid=<cfqueryparam value="#arguments.frmstruct.editid#" cfsqltype="cf_sql_varchar">
					</cfquery>		
					<cfreturn EDI214msg>
				<cfelse>
					<cfset EDI214msg=EDI214AppointmentRecord(arguments.frmstruct)> 
					<cfset EDI214msg1=EDI214StatusRecord(arguments.frmstruct)>
					<cfif Len(EDI214msg1)>
						<cfset EDI214msg = EDI214msg1>
					</cfif>
					<cfset Message = Message &  "~~" & EDI214msg >			
				</cfif>
			</cfif>
				<!--- EDI 210 --->
				<cfif structKeyExists(arguments.frmstruct,"oldstatus") AND arguments.frmstruct.oldstatus NEQ "7. INVOICE" AND arguments.frmstruct.loadstatus EQ '6419693E-A04C-4ECE-B612-36D3D40CFC70'>
				
					<cfset Edi210Msg = EDI210(arguments.frmstruct)>
					<cfif Isdefined('Edi210Msg') AND Len(Edi210Msg)>
						<cfset Message = Message& Edi210Msg>
					</cfif>
				</cfif>
			</cfif>
		</cfif>		

		<cfreturn Message>
</cffunction>

<!--- Edit Load--->
<cffunction name="EditLoad" access="public" returntype="any">
	<cfargument name="frmstruct" type="struct" required="yes">

	<cfif isdefined('arguments.frmstruct.shipBlind')>
		<cfset shipBlind=True>
	<cfelse>
		<cfset shipBlind=False>
	</cfif>
	<cfif isdefined('arguments.frmstruct.ConsBlind')>
		<cfset ConsBlind=True>
	<cfelse>
		<cfset ConsBlind=False>
	</cfif>
	<cfquery name="qryGetTranscore" datasource="#variables.dsn#">
		select IsTransCorePst from Loads WHERE ControlNumber=<cfqueryparam value="#arguments.frmstruct.loadManualNo#" cfsqltype="cf_sql_integer">
	</cfquery>
	<cfset variables.datStatus=0>
	<cfif qryGetTranscore.recordcount>
		<cfif qryGetTranscore.IsTransCorePst eq 1>
			<cfset variables.datStatus=1>
		</cfif>
	</cfif>
		<cftransaction>
			<!--- Load Logging--->
			<cfinvoke method="LoadLogRegister" type="RunUSP_UpdateLoad" instance=1 whereList="#arguments.frmstruct.editid#">
			<!--- Load Logging--->
			<cfinvoke method="RunUSP_UpdateLoad" frmstruct="#frmstruct#" returnvariable="LastLoadId">
			<!--- Load Logging--->
			<cfinvoke method="LoadLogRegister" type="RunUSP_UpdateLoad" instance=2 whereList="#arguments.frmstruct.editid#">
			<!--- Load Logging--->
			<cfquery name="unLockLoad" datasource="#variables.dsn#">
				UPDATE  Loads SET IsLocked = 0 where loadid=<cfqueryparam cfsqltype="cf_sql_varchar" value="#LastLoadId#">
			</cfquery>
			<cfif isDefined("arguments.frmstruct.userDefinedForTrucking")>		
			   	<cfquery name="UpdateUserDefinedFieldTrucking" datasource="#variables.dsn#">
					UPDATE  Loads SET
					userDefinedFieldTrucking=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.frmstruct.userDefinedForTrucking#">
					where loadid=<cfqueryparam cfsqltype="cf_sql_varchar" value="#LastLoadId#">
				</cfquery>
			</cfif>
			<cfif isDefined("arguments.frmstruct.noOfTrips") and len(arguments.frmstruct.noOfTrips)>
				<cfquery name="UpdateLoadNoOfTrips" datasource="#variables.dsn#">
					UPDATE Loads SET
					noOfTrips=<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.frmstruct.noOfTrips#">
					where loadid=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.frmstruct.editid#">
				</cfquery>
			</cfif>
		</cftransaction>
			<cfset lastUpdatedShipCustomerID ="">
			<cfif arguments.frmstruct.shipper neq "" and arguments.frmstruct.shipperName neq "">
				<cfif structKeyExists(arguments.frmstruct,"shipperFlag") and  arguments.frmstruct.shipperFlag eq 2>
						<cfset lastUpdatedShipCustomerID = arguments.frmstruct.shipperValueContainer>
						<cfinvoke method="getIsPayerStop" customerID="#lastUpdatedShipCustomerID#" returnvariable="qGetIsPayer">
					<cfif qGetIsPayer.recordcount AND NOT qGetIsPayer.isPayer>
						<cfinvoke method="updateCustomer" formStruct="#arguments.frmstruct#" updateType="shipper" stopNo="0" returnvariable="lastUpdatedShipCustomerID" />
					<cfelseif evaluate('arguments.frmstruct.shipperValueContainer') EQ "">
						<cfinvoke method="formCustStruct" frmstruct="#arguments.frmstruct#" type="shipper" returnvariable="shipperStruct" />
						<cfinvoke component ="#variables.objCustomerGateway#" method="AddCustomer" formStruct="#shipperStruct#" idReturn="true" returnvariable="addedShipperResult"/>
						<cfset lastUpdatedShipCustomerID = addedShipperResult.id>
					<cfelse>
						<cfset lastUpdatedShipCustomerID = arguments.frmstruct.shipperValueContainer>
					</cfif>
				<cfelseif (structKeyExists(arguments.frmstruct,"shipperFlag") and  arguments.frmstruct.shipperFlag eq 1) AND arguments.frmstruct.shipperValueContainer eq "">
				<!--- Adding New Stop1 Shipper --->
					<cfset shipperStruct = {}>
					<!--- If the  shipper is not selected through autosuggest then insert a new shipper --->
				    <cfinvoke method="formCustStruct" frmstruct="#arguments.frmstruct#" type="shipper" returnvariable="shipperStruct" />
					<cfinvoke component ="#variables.objCustomerGateway#" method="AddCustomer" formStruct="#shipperStruct#" idReturn="true" returnvariable="addedShipperResult"/>
					<cfset lastUpdatedShipCustomerID = addedShipperResult.id>
				<cfelse>
					<cfset lastUpdatedShipCustomerID = arguments.frmstruct.shipperValueContainer>
				</cfif>
			</cfif>
		<cfinvoke component="#variables.objLoadgatewayUpdate#" method="getlastStopId" ShipBlind="#ShipBlind#" lastUpdatedShipCustomerID="#lastUpdatedShipCustomerID#" frmstruct="#arguments.frmstruct#" LastLoadId="#LastLoadId#" returnvariable="lastStopIdValue"/>
		<cfset lastInsertedStopId = lastStopIdValue.lastStopID>
		<!--- IMPORT Load Stop Starts Here ---->
		<cfif structKeyExists(arguments.frmstruct,"dateDispatched")>
			<cfquery name="qLoadStopIntermodalImportExists" datasource="#variables.dsn#">
				SELECT LoadStopID FROM LoadStopIntermodalImport
				WHERE LoadStopID = <cfqueryparam value="#lastInsertedStopId#" cfsqltype="cf_sql_varchar">
				AND StopNo = <cfqueryparam value="1" cfsqltype="cf_sql_integer">
			</cfquery>
			<cfif qLoadStopIntermodalImportExists.recordcount>
				<cfquery name="qUpdateLoadStopIntermodalImport" datasource="#variables.dsn#">
					update LoadStopIntermodalImport
					set dateDispatched = <cfqueryparam value="#arguments.frmstruct.dateDispatched#" cfsqltype="cf_sql_date">,
						steamShipLine = <cfqueryparam value="#arguments.frmstruct.steamShipLine#" cfsqltype="cf_sql_varchar">,
						eta = <cfqueryparam value="#arguments.frmstruct.eta#" cfsqltype="cf_sql_date">,
						oceanBillofLading = <cfqueryparam value="#arguments.frmstruct.oceanBillofLading#" cfsqltype="cf_sql_varchar">,
						actualArrivalDate = <cfqueryparam value="#arguments.frmstruct.actualArrivalDate#" cfsqltype="cf_sql_date">,
						seal = <cfqueryparam value="#arguments.frmstruct.seal#" cfsqltype="cf_sql_varchar">,
						customersReleaseDate = <cfqueryparam value="#arguments.frmstruct.customersReleaseDate#" cfsqltype="cf_sql_date">,
						vesselName = <cfqueryparam value="#arguments.frmstruct.vesselName#" cfsqltype="cf_sql_varchar">,
						freightReleaseDate = <cfqueryparam value="#arguments.frmstruct.freightReleaseDate#" cfsqltype="cf_sql_date">,
						dateAvailable = <cfqueryparam value="#arguments.frmstruct.dateAvailable#" cfsqltype="cf_sql_date">,
						demuggageFreeTimeExpirationDate = <cfqueryparam value="#arguments.frmstruct.demuggageFreeTimeExpirationDate#" cfsqltype="cf_sql_date">,
						perDiemFreeTimeExpirationDate = <cfqueryparam value="#arguments.frmstruct.perDiemFreeTimeExpirationDate#" cfsqltype="cf_sql_date">,
						pickupDate = <cfqueryparam value="#arguments.frmstruct.pickupDate#" cfsqltype="cf_sql_date">,
						requestedDeliveryDate = <cfqueryparam value="#arguments.frmstruct.requestedDeliveryDate#" cfsqltype="cf_sql_date">,
						requestedDeliveryTime = <cfqueryparam value="#arguments.frmstruct.requestedDeliveryTime#" cfsqltype="cf_sql_varchar">,
						scheduledDeliveryDate = <cfqueryparam value="#arguments.frmstruct.scheduledDeliveryDate#" cfsqltype="cf_sql_date">,
						scheduledDeliveryTime = <cfqueryparam value="#arguments.frmstruct.scheduledDeliveryTime#" cfsqltype="cf_sql_varchar">,
						unloadingDelayDetentionStartDate = <cfqueryparam value="#arguments.frmstruct.unloadingDelayDetentionStartDate#" cfsqltype="cf_sql_date">,
						unloadingDelayDetentionStartTime = <cfqueryparam value="#arguments.frmstruct.unloadingDelayDetentionStartTime#" cfsqltype="cf_sql_varchar">,
						actualDeliveryDate = <cfqueryparam value="#arguments.frmstruct.actualDeliveryDate#" cfsqltype="cf_sql_date">,
						unloadingDelayDetentionEndDate = <cfqueryparam value="#arguments.frmstruct.unloadingDelayDetentionEndDate#" cfsqltype="cf_sql_date">,
						unloadingDelayDetentionEndTime = <cfqueryparam value="#arguments.frmstruct.unloadingDelayDetentionEndTime#" cfsqltype="cf_sql_varchar">,
						returnDate = <cfqueryparam value="#arguments.frmstruct.returnDate#" cfsqltype="cf_sql_date">,
						pickUpAddress = <cfqueryparam value="#arguments.frmstruct.pickUpAddress#" cfsqltype="cf_sql_varchar">,
						deliveryAddress = <cfqueryparam value="#arguments.frmstruct.deliveryAddress#" cfsqltype="cf_sql_varchar">,
						emptyReturnAddress = <cfqueryparam value="#arguments.frmstruct.emptyReturnAddress#" cfsqltype="cf_sql_varchar">
					WHERE
						LoadStopID = <cfqueryparam value="#lastInsertedStopId#" cfsqltype="cf_sql_varchar"> AND
						StopNo = <cfqueryparam value="1" cfsqltype="cf_sql_integer">
				</cfquery>
			<cfelse>
				<cfquery name="qUpdateLoadStopIntermodalImport" datasource="#variables.dsn#">
					insert into LoadStopIntermodalImport(LoadStopID,StopNo,dateDispatched,steamShipLine,eta,oceanBillofLading,actualArrivalDate,seal,customersReleaseDate,vesselName,freightReleaseDate,dateAvailable,demuggageFreeTimeExpirationDate,perDiemFreeTimeExpirationDate,pickupDate,requestedDeliveryDate,requestedDeliveryTime,scheduledDeliveryDate,scheduledDeliveryTime,unloadingDelayDetentionStartDate,unloadingDelayDetentionStartTime,actualDeliveryDate,unloadingDelayDetentionEndDate,unloadingDelayDetentionEndTime,returnDate,pickUpAddress,deliveryAddress,emptyReturnAddress)
					values (<cfqueryparam value="#lastInsertedStopId#" cfsqltype="cf_sql_varchar">,
							<cfqueryparam value="1" cfsqltype="cf_sql_integer">,
							<cfqueryparam value="#arguments.frmstruct.dateDispatched#" cfsqltype="cf_sql_date">,
							<cfqueryparam value="#arguments.frmstruct.steamShipLine#" cfsqltype="cf_sql_varchar">,
							<cfqueryparam value="#arguments.frmstruct.eta#" cfsqltype="cf_sql_date">,
							<cfqueryparam value="#arguments.frmstruct.oceanBillofLading#" cfsqltype="cf_sql_varchar">,
							<cfqueryparam value="#arguments.frmstruct.actualArrivalDate#" cfsqltype="cf_sql_date">,
							<cfqueryparam value="#arguments.frmstruct.seal#" cfsqltype="cf_sql_varchar">,
							<cfqueryparam value="#arguments.frmstruct.customersReleaseDate#" cfsqltype="cf_sql_date">,
							<cfqueryparam value="#arguments.frmstruct.vesselName#" cfsqltype="cf_sql_varchar">,
							<cfqueryparam value="#arguments.frmstruct.freightReleaseDate#" cfsqltype="cf_sql_date">,
							<cfqueryparam value="#arguments.frmstruct.dateAvailable#" cfsqltype="cf_sql_date">,
							<cfqueryparam value="#arguments.frmstruct.demuggageFreeTimeExpirationDate#" cfsqltype="cf_sql_date">,
							<cfqueryparam value="#arguments.frmstruct.perDiemFreeTimeExpirationDate#" cfsqltype="cf_sql_date">,
							<cfqueryparam value="#arguments.frmstruct.pickupDate#" cfsqltype="cf_sql_date" null="#yesNoFormat(NOT len(arguments.frmstruct.pickupDate))#">,
							<cfqueryparam value="#arguments.frmstruct.requestedDeliveryDate#" cfsqltype="cf_sql_date">,
							<cfqueryparam value="#arguments.frmstruct.requestedDeliveryTime#" cfsqltype="cf_sql_varchar">,
							<cfqueryparam value="#arguments.frmstruct.scheduledDeliveryDate#" cfsqltype="cf_sql_date">,
							<cfqueryparam value="#arguments.frmstruct.scheduledDeliveryTime#" cfsqltype="cf_sql_varchar">,
							<cfqueryparam value="#arguments.frmstruct.unloadingDelayDetentionStartDate#" cfsqltype="cf_sql_date">,
							<cfqueryparam value="#arguments.frmstruct.unloadingDelayDetentionStartTime#" cfsqltype="cf_sql_varchar">,
							<cfqueryparam value="#arguments.frmstruct.actualDeliveryDate#" cfsqltype="cf_sql_date">,
							<cfqueryparam value="#arguments.frmstruct.unloadingDelayDetentionEndDate#" cfsqltype="cf_sql_date">,
							<cfqueryparam value="#arguments.frmstruct.unloadingDelayDetentionEndTime#" cfsqltype="cf_sql_varchar">,
							<cfqueryparam value="#arguments.frmstruct.returnDate#" cfsqltype="cf_sql_date">,
							<cfqueryparam value="#arguments.frmstruct.pickUpAddress#" cfsqltype="cf_sql_varchar">,
							<cfqueryparam value="#arguments.frmstruct.deliveryAddress#" cfsqltype="cf_sql_varchar">,
							<cfqueryparam value="#arguments.frmstruct.emptyReturnAddress#" cfsqltype="cf_sql_varchar">)
				</cfquery>
			</cfif>
			<cfinvoke component="#variables.objLoadgatewayUpdate#" method="getLoadStopAddress" tablename="LoadStopCargoPickupAddress" address="#arguments.frmstruct.pickUpAddress#" returnvariable="qLoadStopCargoPickupAddressExists" />
			<cfif qLoadStopCargoPickupAddressExists.recordcount>
				<cfquery name="qUpdateCargoPickupAddress" datasource="#variables.dsn#">
					update LoadStopCargoPickupAddress
					set address = <cfqueryparam value="#arguments.frmstruct.pickUpAddress#" cfsqltype="cf_sql_varchar">,
						LoadStopID = <cfqueryparam value="#lastInsertedStopId#" cfsqltype="cf_sql_varchar">,
						dateModified = <cfqueryparam value="#now()#" cfsqltype="cf_sql_date">
					where ID = <cfqueryparam value="#qLoadStopCargoPickupAddressExists.ID#" cfsqltype="cf_sql_integer">
				</cfquery>
			<cfelse>
				<cfquery name="qInsertCargoPickupAddress" datasource="#variables.dsn#">
					insert into LoadStopCargoPickupAddress
						(address, LoadStopID, dateAdded, dateModified)
					values(
							<cfqueryparam value="#arguments.frmstruct.pickUpAddress#" cfsqltype="cf_sql_varchar">,
							<cfqueryparam value="#lastInsertedStopId#" cfsqltype="cf_sql_varchar">,
							<cfqueryparam value="#now()#" cfsqltype="cf_sql_date">,
							<cfqueryparam value="#now()#" cfsqltype="cf_sql_date">)
				</cfquery>
			</cfif>
			<cfinvoke component="#variables.objLoadgatewayUpdate#" method="getLoadStopAddress" tablename="LoadStopCargoDeliveryAddress" address="#arguments.frmstruct.deliveryAddress#" returnvariable="qLoadStopCargoDeliveryAddressExists" />
			<cfif qLoadStopCargoDeliveryAddressExists.recordcount>
				<cfquery name="qUpdateCargoDeliveryAddress" datasource="#variables.dsn#">
					update LoadStopCargoDeliveryAddress
					set address = <cfqueryparam value="#arguments.frmstruct.deliveryAddress#" cfsqltype="cf_sql_varchar">,
						LoadStopID = <cfqueryparam value="#lastInsertedStopId#" cfsqltype="cf_sql_varchar">,
						dateModified = <cfqueryparam value="#now()#" cfsqltype="cf_sql_date">
					where ID = <cfqueryparam value="#qLoadStopCargoDeliveryAddressExists.ID#" cfsqltype="cf_sql_integer">
				</cfquery>
			<cfelse>
				<cfquery name="qInsertCargoDeliveryAddress" datasource="#variables.dsn#">
					insert into LoadStopCargoDeliveryAddress (address, LoadStopID, dateAdded, dateModified)
					values ( <cfqueryparam value="#arguments.frmstruct.deliveryAddress#" cfsqltype="cf_sql_varchar">,
							<cfqueryparam value="#lastInsertedStopId#" cfsqltype="cf_sql_varchar">,
							<cfqueryparam value="#now()#" cfsqltype="cf_sql_date">,
							<cfqueryparam value="#now()#" cfsqltype="cf_sql_date">)
				</cfquery>
			</cfif>
			<cfinvoke component="#variables.objLoadgatewayUpdate#" method="getLoadStopAddress" tablename="LoadStopEmptyReturnAddress" address="#arguments.frmstruct.emptyReturnAddress#" returnvariable="qLoadStopEmptyReturnAddressExists" />
			<cfif qLoadStopEmptyReturnAddressExists.recordcount>
				<cfquery name="qUpdateEmptyReturnAddress" datasource="#variables.dsn#">
					update LoadStopEmptyReturnAddress
					set address = <cfqueryparam value="#arguments.frmstruct.emptyReturnAddress#" cfsqltype="cf_sql_varchar">,
						LoadStopID = <cfqueryparam value="#lastInsertedStopId#" cfsqltype="cf_sql_varchar">,
						dateModified = <cfqueryparam value="#now()#" cfsqltype="cf_sql_date">
					where ID = <cfqueryparam value="#qLoadStopEmptyReturnAddressExists.ID#" cfsqltype="cf_sql_integer">
				</cfquery>
			<cfelse>
				<cfquery name="qInsertEmptyReturnAddress" datasource="#variables.dsn#">
					insert into LoadStopEmptyReturnAddress(address, LoadStopID, dateAdded, dateModified)
					values(
							<cfqueryparam value="#arguments.frmstruct.emptyReturnAddress#" cfsqltype="cf_sql_varchar">,
							<cfqueryparam value="#lastInsertedStopId#" cfsqltype="cf_sql_varchar">,
							<cfqueryparam value="#now()#" cfsqltype="cf_sql_date">,
							<cfqueryparam value="#now()#" cfsqltype="cf_sql_date">)
				</cfquery>
			</cfif>

		</cfif>
		<!--- IMPORT Load Stop Ends Here --->
		<!--- EXPORT Load Stop Starts Here ---->
		<cfif structKeyExists(arguments.frmstruct,"exportDateDispatched")>
			<cfinvoke component="#variables.objLoadgatewayUpdate#" method="UpdateLoadAddNew"
			lastInsertedStopId = "#lastInsertedStopId#" frmstruct="#arguments.frmstruct#"returnvariable="qUpdateLoadID"/>
			<cfinvoke component="#variables.objLoadgatewayUpdate#" method="getLoadStopAddress" tablename="LoadStopEmptyPickupAddress" address="#arguments.frmstruct.exportEmptyPickUpAddress#" returnvariable="qLoadStopEmptyPickupAddressExists" />
			<cfif qLoadStopEmptyPickupAddressExists.recordcount>
				<cfquery name="qUpdateEmptyPickupAddress" datasource="#variables.dsn#">
					update LoadStopEmptyPickupAddress
					set address = <cfqueryparam value="#arguments.frmstruct.exportEmptyPickUpAddress#" cfsqltype="cf_sql_varchar">,
						LoadStopID = <cfqueryparam value="#lastInsertedStopId#" cfsqltype="cf_sql_varchar">,
						dateModified = <cfqueryparam value="#now()#" cfsqltype="cf_sql_date">
					where ID = <cfqueryparam value="#qLoadStopEmptyPickupAddressExists.ID#" cfsqltype="cf_sql_integer">
				</cfquery>
			<cfelse>
				<cfquery name="qInsertEmptyPickupAddress" datasource="#variables.dsn#">
					insert into LoadStopEmptyPickupAddress (address, LoadStopID, dateAdded, dateModified)
					values(<cfqueryparam value="#arguments.frmstruct.exportEmptyPickUpAddress#" cfsqltype="cf_sql_varchar">,
							<cfqueryparam value="#lastInsertedStopId#" cfsqltype="cf_sql_varchar">,
							<cfqueryparam value="#now()#" cfsqltype="cf_sql_date">,
							<cfqueryparam value="#now()#" cfsqltype="cf_sql_date">)
				</cfquery>
			</cfif>
			<cfinvoke component="#variables.objLoadgatewayUpdate#" method="getLoadStopAddress" tablename="LoadStopLoadingAddress" address="#arguments.frmstruct.exportLoadingAddress#" returnvariable="qLoadStopLoadingAddressExists" />
			<cfif qLoadStopLoadingAddressExists.recordcount>
				<cfquery name="qUpdateLoadingAddress" datasource="#variables.dsn#">
					update LoadStopLoadingAddress
					set address = <cfqueryparam value="#arguments.frmstruct.exportLoadingAddress#" cfsqltype="cf_sql_varchar">,
						LoadStopID = <cfqueryparam value="#lastInsertedStopId#" cfsqltype="cf_sql_varchar">,
						dateModified = <cfqueryparam value="#now()#" cfsqltype="cf_sql_date">
					where ID = <cfqueryparam value="#qLoadStopLoadingAddressExists.ID#" cfsqltype="cf_sql_integer">
				</cfquery>
			<cfelse>
				<cfquery name="qInsertLoadingAddress" datasource="#variables.dsn#">
					insert into LoadStopLoadingAddress (address, LoadStopID, dateAdded, dateModified)
					values (
							<cfqueryparam value="#arguments.frmstruct.exportLoadingAddress#" cfsqltype="cf_sql_varchar">,
							<cfqueryparam value="#lastInsertedStopId#" cfsqltype="cf_sql_varchar">,
							<cfqueryparam value="#now()#" cfsqltype="cf_sql_date">,
							<cfqueryparam value="#now()#" cfsqltype="cf_sql_date">)
				</cfquery>
			</cfif>
			<cfinvoke component="#variables.objLoadgatewayUpdate#" method="getLoadStopAddress" tablename="LoadStopReturnAddress" address="#arguments.frmstruct.exportReturnAddress#" returnvariable="qLoadStopReturnAddressExists" />
			<cfif qLoadStopReturnAddressExists.recordcount>
				<cfquery name="qUpdateReturnAddress" datasource="#variables.dsn#">
					update
						LoadStopReturnAddress
					set
						address = <cfqueryparam value="#arguments.frmstruct.exportReturnAddress#" cfsqltype="cf_sql_varchar">,
						LoadStopID = <cfqueryparam value="#lastInsertedStopId#" cfsqltype="cf_sql_varchar">,
						dateModified = <cfqueryparam value="#now()#" cfsqltype="cf_sql_date">
					where ID = <cfqueryparam value="#qLoadStopReturnAddressExists.ID#" cfsqltype="cf_sql_integer">
				</cfquery>
			<cfelse>
				<cfquery name="qInsertReturnAddress" datasource="#variables.dsn#">
					insert into LoadStopReturnAddress
						(address, LoadStopID, dateAdded, dateModified)
					values
						(
							<cfqueryparam value="#arguments.frmstruct.exportReturnAddress#" cfsqltype="cf_sql_varchar">,
							<cfqueryparam value="#lastInsertedStopId#" cfsqltype="cf_sql_varchar">,
							<cfqueryparam value="#now()#" cfsqltype="cf_sql_date">,
							<cfqueryparam value="#now()#" cfsqltype="cf_sql_date">
						)
				</cfquery>
			</cfif>
		</cfif>
		<!--- EXPORT Load Stop Ends Here --->
		<!--- Editing Stop1 Consignee Details--->
			<cfset lastUpdatedConsCustomerID ="">
			<cfif arguments.frmstruct.consignee neq "" and arguments.frmstruct.consigneeName neq "">
				<cfif structKeyExists(arguments.frmstruct,"consigneeFlag") and  arguments.frmstruct.consigneeFlag eq 2>
					<cfset lastUpdatedConsCustomerID = arguments.frmstruct.consigneeValueContainer>
					<cfinvoke method="getIsPayerStop" customerID="#lastUpdatedConsCustomerID#" returnvariable="qGetIsPayer">
					<cfif qGetIsPayer.recordcount AND NOT qGetIsPayer.isPayer>
						<cfinvoke method="updateCustomer" formStruct="#arguments.frmstruct#" updateType="consignee" stopNo="0" returnvariable="lastUpdatedConsCustomerID" />
					<cfelseif arguments.frmstruct.consigneeValueContainer EQ "">
						<cfinvoke method="formCustStruct" frmstruct="#arguments.frmstruct#" type="consignee" returnvariable="consigneeStruct" />
						<cfinvoke component ="#variables.objCustomerGateway#" method="AddCustomer" formStruct="#consigneeStruct#" idReturn="true" returnvariable="addedConsigneeResult"/>
						<cfset lastUpdatedConsCustomerID = addedConsigneeResult.id>
					<cfelse>
						<cfset lastUpdatedConsCustomerID = arguments.frmstruct.consigneeValueContainer>
					</cfif>
				<cfelseif (structKeyExists(arguments.frmstruct,"consigneeFlag") and  arguments.frmstruct.consigneeFlag eq 1) AND arguments.frmstruct.consigneeValueContainer eq "">
				<!-----Add New Stop 1 Consignee-------->
					<cfinvoke method="formCustStruct" frmstruct="#arguments.frmstruct#" type="consignee" returnvariable="consigneeStruct" />
					<cfinvoke component ="#variables.objCustomerGateway#" method="AddCustomer" formStruct="#consigneeStruct#" idReturn="true" returnvariable="addedConsigneeResult"/>
					<cfset lastUpdatedConsCustomerID = addedConsigneeResult.id>
				<cfelse>
					<cfset lastUpdatedConsCustomerID = arguments.frmstruct.consigneeValueContainer>
				</cfif>
			</cfif>
  		<cfif IsValid("date",arguments.frmstruct.shipperPickupDate) and IsValid("date",arguments.frmstruct.consigneePickupDate)>
			<cfset variables.dateCompareResult= DateCompare(arguments.frmstruct.shipperPickupDate,arguments.frmstruct.consigneePickupDate)>
			<cfif variables.dateCompareResult eq -1>
				<cfset variables.noOfDays1=dateDiff("d",arguments.frmstruct.shipperPickupDate, arguments.frmstruct.consigneePickupDate)>
			<cfelseif variables.dateCompareResult eq 0>
				<cfset variables.noOfDays1=0>
			<cfelseif variables.dateCompareResult eq 1>
				<cfset variables.noOfDays1="">
			</cfif>
		<cfelse>
			<cfset variables.noOfDays1="">
		</cfif>
		<!--- Load Logging--->
		<cfinvoke method="LoadLogRegister" type="USP_UpdateLoadStop" instance=1 whereList="#LastLoadId#,0,2">		
		<!--- Load Logging--->
		<CFSTOREDPROC PROCEDURE="USP_UpdateLoadStop" DATASOURCE="#variables.dsn#">
			<CFPROCPARAM VALUE="#LastLoadId#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="True" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="True" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#arguments.frmstruct.BookedWith#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#arguments.frmstruct.equipment#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#arguments.frmstruct.driver#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#arguments.frmstruct.drivercell#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#arguments.frmstruct.truckNo#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#arguments.frmstruct.trailerNo#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#arguments.frmstruct.refNo#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#arguments.frmstruct.milse#" cfsqltype="cf_sql_float">
			<CFPROCPARAM VALUE="#arguments.frmstruct.carrierid#" cfsqltype="CF_SQL_VARCHAR">
			<cfif len(arguments.frmstruct.stOffice) gt 1>
				<CFPROCPARAM VALUE="#arguments.frmstruct.stOffice#" cfsqltype="CF_SQL_VARCHAR">
			<cfelse>
				<CFPROCPARAM VALUE="Null" cfsqltype="CF_SQL_VARCHAR">
			</cfif>
			<CFPROCPARAM VALUE="#arguments.frmstruct.consigneePickupNo#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#arguments.frmstruct.consigneePickupDate#" cfsqltype="CF_SQL_dATE" null="#yesNoFormat(NOT len(arguments.frmstruct.consigneePickupDate))#">
			<CFPROCPARAM VALUE="#arguments.frmstruct.consigneePickupTime#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#arguments.frmstruct.consigneetimein#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#arguments.frmstruct.consigneetimeout#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#session.adminUserName#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#lastUpdatedConsCustomerID#" cfsqltype="CF_SQL_VARCHAR" null="#yesNoFormat(NOT len(lastUpdatedConsCustomerID))#">
			<CFPROCPARAM VALUE="#ConsBlind#" cfsqltype="CF_SQL_BIT">
			<CFPROCPARAM VALUE="#arguments.frmstruct.consigneeNotes#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#arguments.frmstruct.consigneeDirection#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="2" cfsqltype="CF_SQL_INTEGER">
			<CFPROCPARAM VALUE="0" cfsqltype="CF_SQL_INTEGER"> <!--- Stop Number --->
			<CFPROCPARAM VALUE="#arguments.frmstruct.consigneelocation#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#arguments.frmstruct.consigneeCity#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#arguments.frmstruct.consigneeStateName#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#arguments.frmstruct.consigneeZipCode#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#arguments.frmstruct.consigneeContactPerson#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#arguments.frmstruct.consigneePhone#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#arguments.frmstruct.consigneeFax#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#arguments.frmstruct.consigneeEmail#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#arguments.frmstruct.consigneeName#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#arguments.frmstruct.userDef1#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#arguments.frmstruct.userDef2#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#arguments.frmstruct.userDef3#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#arguments.frmstruct.userDef4#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#arguments.frmstruct.userDef5#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#arguments.frmstruct.userDef6#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="0" cfsqltype="CF_SQL_INTEGER">
			<CFPROCPARAM VALUE="#variables.noOfDays1#" cfsqltype="CF_SQL_INTEGER" null="#yesNoFormat(NOT len(variables.noOfDays1))#">
			<CFPROCPARAM VALUE="#arguments.frmstruct.Secdriver#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#arguments.frmstruct.secDriverCell#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#arguments.frmstruct.temperature#" cfsqltype="CF_SQL_FLOAT" null="#yesNoFormat(NOT len(arguments.frmstruct.temperature))#">
			<CFPROCPARAM VALUE="#arguments.frmstruct.temperaturescale#" cfsqltype="CF_SQL_VARCHAR">
			<cfprocresult name="qLastInsertedConsignee">
		</CFSTOREDPROC>
		<!--- Load Logging--->
		<cfinvoke method="LoadLogRegister" type="USP_UpdateLoadStop" instance=2 whereList="#LastLoadId#,0,2">		
		<!--- Load Logging--->
		<cfset lastConsigneeStopId = qLastInsertedConsignee.lastStopID>
		<cfif val(arguments.frmstruct.totalResult1) gt val(arguments.frmstruct.commoditityAlreadyCount1)>
			<cfloop from="1" to="#val(arguments.frmstruct.commoditityAlreadyCount1)#" index="num">
				 <cfset qty=VAL(evaluate("arguments.frmstruct.qty_#num#"))>
				 <cfset unit=evaluate("arguments.frmstruct.unit_#num#")>
				 <cfset description=evaluate("arguments.frmstruct.description_#num#")>
				 <cfif isdefined("arguments.frmstruct.weight_#num#")>
					<cfset weight=VAL(evaluate("arguments.frmstruct.weight_#num#"))>
				<cfelse>
					<cfset weight=0>
				</cfif>
				 <cfset class=evaluate("arguments.frmstruct.class_#num#")>
				 <cfset CustomerRate=evaluate("arguments.frmstruct.CustomerRate_#num#")>
				 <cfset CustomerRate = replace( CustomerRate,"$","","ALL") >
				 <cfset CarrierRate=evaluate("arguments.frmstruct.CarrierRate_#num#")>
				 <cfset CarrierRate = replace( CarrierRate,"$","","ALL") >
				 <cfset custCharges =evaluate("arguments.frmstruct.custCharges_#num#")>
				 <cfset custCharges = replace( custCharges,"$","","ALL") >
				 <cfset carrCharges=evaluate("arguments.frmstruct.carrCharges_#num#")>
				 <cfset carrCharges = replace( carrCharges,"$","","ALL") >
				 <cfset CarrRateOfCustTotal =evaluate("arguments.frmstruct.CarrierPer_#num#")>
				 <cfset CarrRateOfCustTotal = replace( CarrRateOfCustTotal,"%","","ALL") >
				 <cfif not IsNumeric(CarrRateOfCustTotal)>
					<cfset CarrRateOfCustTotal = 0>
				</cfif>
				 <cfif isdefined('arguments.frmstruct.isFee_#num#')>
				 	<cfset isFee=true>
				 <cfelse>
				 	<cfset isFee=false>
				 </cfif>
				<!--- Load Logging--->
					<cfinvoke method="LoadLogRegister" type="USP_UpdateLoadItem" instance=1 whereList="#lastInsertedStopId#,#num#">
				<!--- Load Logging--->
				 <CFSTOREDPROC PROCEDURE="USP_UpdateLoadItem" DATASOURCE="#variables.dsn#">
					<CFPROCPARAM VALUE="#lastInsertedStopId#" cfsqltype="CF_SQL_VARCHAR">
					<CFPROCPARAM VALUE="#num#" cfsqltype="CF_SQL_VARCHAR">
					<CFPROCPARAM VALUE="#val(qty)#" cfsqltype="CF_SQL_float">
					<CFPROCPARAM VALUE="#unit#" cfsqltype="CF_SQL_VarCHAR">
					<CFPROCPARAM VALUE="#description#" cfsqltype="CF_SQL_NVARCHAR">
					<CFPROCPARAM VALUE="#weight#" cfsqltype="CF_SQL_float">
					<CFPROCPARAM VALUE="#class#" cfsqltype="CF_SQL_VARCHAR">
					<CFPROCPARAM VALUE="#Val(CustomerRate)#" cfsqltype="cf_sql_money">
					<CFPROCPARAM VALUE="#Val(CarrierRate)#" cfsqltype="cf_sql_money">
					<CFPROCPARAM VALUE="#val(custCharges)#" cfsqltype="cf_sql_money">
					<CFPROCPARAM VALUE="#val(carrCharges)#" cfsqltype="cf_sql_money">
					<CFPROCPARAM VALUE="#CarrRateOfCustTotal#" cfsqltype="cf_sql_decimal">
					<CFPROCPARAM VALUE="#isFee#" cfsqltype="CF_SQL_VARCHAR">
					<CFPROCRESULT NAME="qInsertedLoadItem">
				</cfstoredproc>
				<!--- Load Logging--->
					<cfinvoke method="LoadLogRegister" type="USP_UpdateLoadItem" instance=2 whereList="#lastInsertedStopId#,#num#,0">
				<!--- Load Logging--->
			</cfloop>
			<cfset variables.startcommoditityAlreadyCount1=val(arguments.frmstruct.commoditityAlreadyCount1)+1>
			<cfloop from="#val(variables.startcommoditityAlreadyCount1)#" to="#val(arguments.frmstruct.totalResult1)#" index="num">
			     <cfset qty=VAL(evaluate("arguments.frmstruct.qty_#num#"))>
				 <cfset unit=evaluate("arguments.frmstruct.unit_#num#")>
				 <cfset description=evaluate("arguments.frmstruct.description_#num#")>
				 <cfif isdefined("arguments.frmstruct.weight_#num#")>
					<cfset weight=VAL(evaluate("arguments.frmstruct.weight_#num#"))>
				<cfelse>
					<cfset weight=0>
				</cfif>
				 <cfset class=evaluate("arguments.frmstruct.class_#num#")>
				 <cfset CustomerRate=evaluate("arguments.frmstruct.CustomerRate_#num#")>
				 <cfset CustomerRate = replace( CustomerRate,"$","","ALL") >
				 <cfset CarrierRate=evaluate("arguments.frmstruct.CarrierRate_#num#")>
				 <cfset CarrierRate = replace( CarrierRate,"$","","ALL") >
				 <cfset custCharges=evaluate("arguments.frmstruct.custCharges_#num#")>
				 <cfset custCharges = replace( custCharges,"$","","ALL") >
				 <cfset carrCharges=evaluate("arguments.frmstruct.carrCharges_#num#")>
				 <cfset carrCharges = replace( carrCharges,"$","","ALL") >
				 <cfset CarrRateOfCustTotal=evaluate("arguments.frmstruct.CarrierPer_#num#")>
				 <cfset CarrRateOfCustTotal = replace( CarrRateOfCustTotal,"%","","ALL") >
				 <cfif not IsNumeric(CarrRateOfCustTotal)><cfset CarrRateOfCustTotal = 0></cfif>
				 <cfif isdefined('arguments.frmstruct.isFee_#num#')><cfset isFee=true><cfelse><cfset isFee=false></cfif>
				 <cfif not len(trim(CustomerRate))><cfset CustomerRate=0.00></cfif>
				 <cfif not len(trim(CarrierRate))><cfset CarrierRate=0.00></cfif>
				<CFSTOREDPROC PROCEDURE="USP_InsertLoadItem" DATASOURCE="#variables.dsn#">
					<CFPROCPARAM VALUE="#lastInsertedStopId#" cfsqltype="CF_SQL_VARCHAR">
				 	<CFPROCPARAM VALUE="#num#" cfsqltype="CF_SQL_VARCHAR">
				 	<CFPROCPARAM VALUE="#val(qty)#" cfsqltype="CF_SQL_float">
				 	<CFPROCPARAM VALUE="#unit#" cfsqltype="CF_SQL_VARCHAR">
				 	<CFPROCPARAM VALUE="#description#" cfsqltype="CF_SQL_NVARCHAR">
				 	<CFPROCPARAM VALUE="#weight#" cfsqltype="CF_SQL_float">
				 	<CFPROCPARAM VALUE="#class#" cfsqltype="CF_SQL_VARCHAR">
					<CFPROCPARAM VALUE="#Val(CustomerRate)#" cfsqltype="cf_sql_money">
					<CFPROCPARAM VALUE="#Val(CarrierRate)#" cfsqltype="cf_sql_money">
					<CFPROCPARAM VALUE="#val(custCharges)#" cfsqltype="cf_sql_money">
					<CFPROCPARAM VALUE="#val(carrCharges)#" cfsqltype="cf_sql_money">
					<CFPROCPARAM VALUE="#CarrRateOfCustTotal#" cfsqltype="cf_sql_decimal">
				 	<CFPROCPARAM VALUE="#isFee#" cfsqltype="CF_SQL_VARCHAR">
				 	<CFPROCRESULT NAME="qInsertedLoadItem">
				</cfstoredproc>
				<!--- Load Logging--->
				<cfset StructInsert(this.loadLogData, "New Load Item-" & num , {
							FieldLabel = "New Load Item. Number: " & num
						}, true)>
				<!--- Load Logging--->
			</cfloop>
		<cfelse>
			<cfloop from="1" to="#val(arguments.frmstruct.totalResult1)#" index="num">
				 <cfset qty=VAL(evaluate("arguments.frmstruct.qty_#num#"))>
				 <cfset unit=evaluate("arguments.frmstruct.unit_#num#")>
				 <cfset description=evaluate("arguments.frmstruct.description_#num#")>
				 <cfif isdefined("arguments.frmstruct.weight_#num#")>
					<cfset weight=VAL(evaluate("arguments.frmstruct.weight_#num#"))>
				<cfelse>
					<cfset weight=0>
				</cfif>
				 <cfset class=evaluate("arguments.frmstruct.class_#num#")>
				 <cfset CustomerRate=evaluate("arguments.frmstruct.CustomerRate_#num#")>
				 <cfset CustomerRate = replace( CustomerRate,"$","","ALL") >
				 <cfset CarrierRate=evaluate("arguments.frmstruct.CarrierRate_#num#")>
				 <cfset CarrierRate = replace( CarrierRate,"$","","ALL") >
				 <cfset custCharges =evaluate("arguments.frmstruct.custCharges_#num#")>
				 <cfset custCharges = replace( custCharges,"$","","ALL") >
				 <cfset carrCharges=evaluate("arguments.frmstruct.carrCharges_#num#")>
				 <cfset carrCharges = replace( carrCharges,"$","","ALL") >
				 <cfset CarrRateOfCustTotal =evaluate("arguments.frmstruct.CarrierPer_#num#")>
				 <cfset CarrRateOfCustTotal = replace( CarrRateOfCustTotal,"%","","ALL") >
				 <cfif not IsNumeric(CarrRateOfCustTotal)>
					<cfset CarrRateOfCustTotal = 0>
				</cfif>
				 <cfif isdefined('arguments.frmstruct.isFee_#num#')>
				 	<cfset isFee=true>
				 <cfelse>
				 	<cfset isFee=false>
				 </cfif>
				 <!--- Load Logging--->
					<cfinvoke method="LoadLogRegister" type="USP_UpdateLoadItem" instance=1 whereList="#lastInsertedStopId#,#num#">
				<!--- Load Logging--->
				 <CFSTOREDPROC PROCEDURE="USP_UpdateLoadItem" DATASOURCE="#variables.dsn#">
					<CFPROCPARAM VALUE="#lastInsertedStopId#" cfsqltype="CF_SQL_VARCHAR">
					<CFPROCPARAM VALUE="#num#" cfsqltype="CF_SQL_VARCHAR">
					<CFPROCPARAM VALUE="#val(qty)#" cfsqltype="CF_SQL_float">
					<CFPROCPARAM VALUE="#unit#" cfsqltype="CF_SQL_VarCHAR">
					<CFPROCPARAM VALUE="#description#" cfsqltype="CF_SQL_NVARCHAR">
					<CFPROCPARAM VALUE="#weight#" cfsqltype="CF_SQL_float">
					<CFPROCPARAM VALUE="#class#" cfsqltype="CF_SQL_VARCHAR">
					<CFPROCPARAM VALUE="#Val(CustomerRate)#" cfsqltype="cf_sql_money">
					<CFPROCPARAM VALUE="#Val(CarrierRate)#" cfsqltype="cf_sql_money">
					<CFPROCPARAM VALUE="#val(custCharges)#" cfsqltype="cf_sql_money">
					<CFPROCPARAM VALUE="#val(carrCharges)#" cfsqltype="cf_sql_money">
					<CFPROCPARAM VALUE="#CarrRateOfCustTotal#" cfsqltype="cf_sql_decimal">
					<CFPROCPARAM VALUE="#isFee#" cfsqltype="CF_SQL_VARCHAR">
					<CFPROCRESULT NAME="qInsertedLoadItem">
				</cfstoredproc>
				<!--- Load Logging--->
					<cfinvoke method="LoadLogRegister" type="USP_UpdateLoadItem" instance=2 whereList="#lastInsertedStopId#,#num#,0">
				<!--- Load Logging--->
			</cfloop>
	  	</cfif>
		<!--- EDIT 2nd and further Stops --->
		<!---<cfif val(arguments.frmstruct.totalStop) gt 1>--->
		<cfif listLen(arguments.frmstruct.shownStopArray)>
			<!--- <cfloop from="2" to="#val(arguments.frmstruct.totalStop)#" index="stpID"> --->
			<cfloop list="#arguments.frmstruct.shownStopArray#" index="stpID">
			   <cfset request.qLoads = getAllLoads(loadid="#arguments.frmstruct.editid#",stopNo="#(stpID-1)#")>
			   <cfset stopNo=stpID-1>
				<cfif isdefined('arguments.frmstruct.shipBlind#stpID#')>
					<cfset shipBlind=True>
				<cfelse>
					<cfset shipBlind=False>
				</cfif>
				<cfif isdefined('arguments.frmstruct.ConsBlind#stpID#')>
					<cfset ConsBlind=True>
				<cfelse>
					<cfset ConsBlind=False>
				</cfif>
				<cfquery name="qStopExists" datasource="#variables.dsn#">
					SELECT * FROM LoadStops
					WHERE LoadID = <cfqueryparam value="#frmstruct.editID#" cfsqltype="cf_sql_varchar">
					AND StopNo = <cfqueryparam value="#stopNo#" cfsqltype="cf_sql_integer">
				</cfquery>
					<cfif IsValid("date",#EVALUATE('arguments.frmstruct.shipperPickupDate#stpID#')#) and IsValid("date",#EVALUATE('arguments.frmstruct.consigneePickupDate#stpID#')#)>
 						<cfset variables.dateCompareResult= DateCompare(EVALUATE('arguments.frmstruct.shipperPickupDate#stpID#'), EVALUATE('arguments.frmstruct.consigneePickupDate#stpID#'))>
						<cfif variables.dateCompareResult eq -1>
							<cfset variables.noOfDays=dateDiff("d", evaluate('arguments.frmstruct.shipperPickupDate#stpID#'), evaluate('arguments.frmstruct.consigneePickupDate#stpID#'))>
						<cfelseif variables.dateCompareResult eq 0>
							<cfset variables.noOfDays=0>
						<cfelseif variables.dateCompareResult eq 1>
							<cfset variables.noOfDays="">
						</cfif>
					<cfelse>
						<cfset variables.noOfDays="">
					</cfif>
				<cfif qStopExists.RecordCount EQ 0>
				<!--- Editing Next Stops Shipper Details --->
					<cfset lastUpdatedShipCustomerID ="">
					<cfif evaluate("arguments.frmstruct.shipper#stpID#") neq "" and evaluate("arguments.frmstruct.shipperName#stpID#") neq "">
						<cfif structKeyExists(arguments.frmstruct,"shipperFlag#stpID#") and  evaluate("arguments.frmstruct.shipperFlag#stpID#") eq 2>
							<cfset lastUpdatedShipCustomerID = Evaluate("arguments.frmstruct.shipperValueContainer#stpID#")>
							<cfinvoke method="getIsPayerStop" customerID="#lastUpdatedShipCustomerID#" returnvariable="qGetIsPayer">
							<cfif qGetIsPayer.recordcount AND NOT qGetIsPayer.isPayer>
								<cfinvoke method="updateCustomer" formStruct="#arguments.frmstruct#" updateType="shipper" stopNo="#stpID#" returnvariable="lastUpdatedShipCustomerID" />
							<cfelseif evaluate('arguments.frmstruct.shipperValueContainer#stpID#') EQ "">
								<cfinvoke method="formCustStruct" frmstruct="#arguments.frmstruct#" type="shipper" returnvariable="shipperStruct" />
								<cfinvoke component ="#variables.objCustomerGateway#" method="AddCustomer" formStruct="#shipperStruct#" idReturn="true" returnvariable="addedShipperResult"/>
								<cfset lastUpdatedShipCustomerID = addedShipperResult.id>
							<cfelse>
								<cfset lastUpdatedShipCustomerID = evaluate('arguments.frmstruct.shipperValueContainer#stpID#')>
							</cfif>
						<cfelseif (structKeyExists(arguments.frmstruct,"shipperFlag#stpID#") and  evaluate("arguments.frmstruct.shipperFlag#stpID#") eq 1) AND evaluate('arguments.frmstruct.shipperValueContainer#stpID#') eq "">
						<!----Adding New Shipper-------->
							<cfinvoke method="formCustStruct" frmstruct="#arguments.frmstruct#" type="shipper" stop="#stpID#" returnvariable="shipperStruct" />
							<cfinvoke component ="#variables.objCustomerGateway#" method="AddCustomer" formStruct="#shipperStruct#" idReturn="true" returnvariable="addedShipperResult"/>
							<cfset lastUpdatedShipCustomerID = addedShipperResult.id>
						<cfelse>
							<cfset lastUpdatedShipCustomerID = evaluate('arguments.frmstruct.shipperValueContainer#stpID#')>
						</cfif>
					</cfif>
			 		<cfset variables.NewStopNo = 0>
			 		<cfloop from="1" to="#arguments.frmstruct.totalStop#" index="index">
			 			<cfquery name="qryGetStopExists" datasource="#variables.dsn#">
							SELECT StopNo FROM LoadStops
							WHERE LoadID = <cfqueryparam value="#frmstruct.editID#" cfsqltype="cf_sql_varchar">
							AND StopNo = <cfqueryparam value="#index#" cfsqltype="cf_sql_integer">
							AND StopNo < <cfqueryparam value="#stpID-1#" cfsqltype="cf_sql_integer">
						</cfquery>
						<cfif NOT qryGetStopExists.recordcount>
							<cfset variables.NewStopNo = index>
							<cfbreak>
						<cfelse>
							<cfset variables.NewStopNo = index>
						</cfif>
			 		</cfloop>
				  	<CFSTOREDPROC PROCEDURE="USP_InsertLoadStop" DATASOURCE="#variables.dsn#">
						<CFPROCPARAM VALUE="#LastLoadId#" cfsqltype="CF_SQL_VARCHAR">
						<CFPROCPARAM VALUE="True" cfsqltype="CF_SQL_VARCHAR">
						<CFPROCPARAM VALUE="True" cfsqltype="CF_SQL_VARCHAR">
						<CFPROCPARAM VALUE="#evaluate('arguments.frmstruct.BookedWith#stpID#')#" cfsqltype="CF_SQL_VARCHAR">
						<CFPROCPARAM VALUE="#evaluate('arguments.frmstruct.equipment#stpID#')#" cfsqltype="CF_SQL_VARCHAR">
						<CFPROCPARAM VALUE="#evaluate('arguments.frmstruct.driver#stpID#')#" cfsqltype="CF_SQL_VARCHAR">
						<CFPROCPARAM VALUE="#evaluate('arguments.frmstruct.drivercell#stpID#')#" cfsqltype="CF_SQL_VARCHAR">
						<CFPROCPARAM VALUE="#evaluate('arguments.frmstruct.truckNo#stpID#')#" cfsqltype="CF_SQL_VARCHAR">
						<CFPROCPARAM VALUE="#evaluate('arguments.frmstruct.trailerNo#stpID#')#" cfsqltype="CF_SQL_VARCHAR">
						<CFPROCPARAM VALUE="#evaluate('arguments.frmstruct.refNo#stpID#')#" cfsqltype="CF_SQL_VARCHAR">
						<CFPROCPARAM VALUE="#evaluate('arguments.frmstruct.milse#stpID#')#" cfsqltype="cf_sql_float">
						<!------If the carrier for this stop is not selected and the carrier for the first stop is selected then add the first stop carrier for this stop------>
						<cfif arguments.frmstruct.carrierid neq "" and evaluate('arguments.frmstruct.carrierid#stpID#') eq "">
							<CFPROCPARAM VALUE="#arguments.frmstruct.carrierid#" cfsqltype="CF_SQL_VARCHAR">
							<cfif len(arguments.frmstruct.stOffice) gt 1>
								<CFPROCPARAM VALUE="#arguments.frmstruct.stOffice#" cfsqltype="CF_SQL_VARCHAR">
							<cfelse>
								<CFPROCPARAM VALUE="Null" cfsqltype="CF_SQL_VARCHAR">
							</cfif>
						<cfelse>
							<CFPROCPARAM VALUE="#evaluate('arguments.frmstruct.carrierid#stpID#')#" cfsqltype="CF_SQL_VARCHAR">
							<cfif len(evaluate('arguments.frmstruct.stOffice#stpID#')) gt 1>
								<CFPROCPARAM VALUE="#evaluate('arguments.frmstruct.stOffice#stpID#')#" cfsqltype="CF_SQL_VARCHAR">
							<cfelse>
								<CFPROCPARAM VALUE="Null" cfsqltype="CF_SQL_VARCHAR">
							</cfif>
						</cfif>
						<CFPROCPARAM VALUE="#EVALUATE('arguments.frmstruct.shipperPickupNO1#stpID#')#" cfsqltype="CF_SQL_VARCHAR">
						<CFPROCPARAM VALUE="#EVALUATE('arguments.frmstruct.shipperPickupDate#stpID#')#" cfsqltype="CF_SQL_dATE" null="#yesNoFormat(NOT len(EVALUATE('arguments.frmstruct.shipperPickupDate#stpID#')))#">
						<CFPROCPARAM VALUE="#EVALUATE('arguments.frmstruct.shipperPickupTime#stpID#')#" cfsqltype="CF_SQL_VARCHAR">
						<CFPROCPARAM VALUE="#EVALUATE('arguments.frmstruct.shipperTimeIn#stpID#')#" cfsqltype="CF_SQL_VARCHAR">
						<CFPROCPARAM VALUE="#EVALUATE('arguments.frmstruct.shipperTimeOut#stpID#')#" cfsqltype="CF_SQL_VARCHAR">
						<CFPROCPARAM VALUE="#session.adminUserName#" cfsqltype="CF_SQL_VARCHAR">
						<CFPROCPARAM VALUE="#lastUpdatedShipCustomerID#" cfsqltype="CF_SQL_VARCHAR"  null="#yesNoFormat(NOT len(lastUpdatedShipCustomerID))#">
						<CFPROCPARAM VALUE="#ShipBlind#" cfsqltype="CF_SQL_BIT">
						<CFPROCPARAM VALUE="#EVALUATE('arguments.frmstruct.shipperNotes#stpID#')#" cfsqltype="CF_SQL_VARCHAR">
						<CFPROCPARAM VALUE="#EVALUATE('arguments.frmstruct.shipperDirection#stpID#')#" cfsqltype="CF_SQL_VARCHAR">
						<CFPROCPARAM VALUE="1" cfsqltype="CF_SQL_INTEGER">
						<CFPROCPARAM VALUE="#EVALUATE('arguments.frmstruct.shipperlocation#stpID#')#" cfsqltype="CF_SQL_VARCHAR">
						<CFPROCPARAM VALUE="#EVALUATE('arguments.frmstruct.shipperCity#stpID#')#" cfsqltype="CF_SQL_VARCHAR">
						<CFPROCPARAM VALUE="#EVALUATE('arguments.frmstruct.shipperStateName#stpID#')#" cfsqltype="CF_SQL_VARCHAR">
						<CFPROCPARAM VALUE="#EVALUATE('arguments.frmstruct.shipperZipCode#stpID#')#" cfsqltype="CF_SQL_VARCHAR">
						<CFPROCPARAM VALUE="#EVALUATE('arguments.frmstruct.shipperContactPerson#stpID#')#" cfsqltype="CF_SQL_VARCHAR">
						<CFPROCPARAM VALUE="#EVALUATE('arguments.frmstruct.shipperPhone#stpID#')#" cfsqltype="CF_SQL_VARCHAR">
						<CFPROCPARAM VALUE="#EVALUATE('arguments.frmstruct.shipperFax#stpID#')#" cfsqltype="CF_SQL_VARCHAR">
						<CFPROCPARAM VALUE="#EVALUATE('arguments.frmstruct.shipperEmail#stpID#')#" cfsqltype="CF_SQL_VARCHAR">
						<CFPROCPARAM VALUE="#EVALUATE('arguments.frmstruct.shipperName#stpID#')#" cfsqltype="CF_SQL_VARCHAR">
						<CFPROCPARAM VALUE="#EVALUATE('arguments.frmstruct.userDef1#stpID#')#" cfsqltype="CF_SQL_VARCHAR">
						<CFPROCPARAM VALUE="#EVALUATE('arguments.frmstruct.userDef2#stpID#')#" cfsqltype="CF_SQL_VARCHAR">
						<CFPROCPARAM VALUE="#EVALUATE('arguments.frmstruct.userDef3#stpID#')#" cfsqltype="CF_SQL_VARCHAR">
						<CFPROCPARAM VALUE="#EVALUATE('arguments.frmstruct.userDef4#stpID#')#" cfsqltype="CF_SQL_VARCHAR">
						<CFPROCPARAM VALUE="#EVALUATE('arguments.frmstruct.userDef5#stpID#')#" cfsqltype="CF_SQL_VARCHAR">
						<CFPROCPARAM VALUE="#EVALUATE('arguments.frmstruct.userDef6#stpID#')#" cfsqltype="CF_SQL_VARCHAR">
						<CFPROCPARAM VALUE="#variables.NewStopNo#" cfsqltype="CF_SQL_INTEGER">
						<CFPROCPARAM VALUE="#variables.noOfDays#" cfsqltype="CF_SQL_INTEGER" null="#yesNoFormat(NOT len(variables.noOfDays))#">
						<CFPROCPARAM VALUE="#evaluate('arguments.frmstruct.Secdriver#stpID#')#" cfsqltype="CF_SQL_VARCHAR">
						<CFPROCPARAM VALUE="#evaluate('arguments.frmstruct.secDriverCell#stpID#')#" cfsqltype="CF_SQL_VARCHAR">
						<CFPROCPARAM VALUE="#evaluate('arguments.frmstruct.temperature#stpID#')#" cfsqltype="CF_SQL_FLOAT" null="#yesNoFormat(NOT len(evaluate('arguments.frmstruct.temperature#stpID#')))#">
						<CFPROCPARAM VALUE="#evaluate('arguments.frmstruct.temperaturescale#stpID#')#" cfsqltype="CF_SQL_VARCHAR">
						<cfprocresult name="qLastInsertedShipper">
					</CFSTOREDPROC>
					<!--- Load Logging--->
					<cfset StructInsert(this.loadLogData, "New Load Stop-" & variables.NewStopNo+1 & "-Type-1", {
								FieldLabel = "New Load Stop. Stop Number: " & variables.NewStopNo+1 & " Stop Type: 1"
							}, true)>
					<!--- Load Logging--->
					<cfset lastInsertedStopId = qLastInsertedShipper.lastStopID>
					<cfset lastUpdatedConsCustomerID ="">
					<cfif evaluate("arguments.frmstruct.consignee#stpID#") neq "" and evaluate("arguments.frmstruct.consigneeName#stpID#") neq "">
						<cfif structKeyExists(arguments.frmstruct,"consigneeFlag#stpID#") and  evaluate("arguments.frmstruct.consigneeFlag#stpID#") eq 2>
							<cfset lastUpdatedConsCustomerID = Evaluate("arguments.frmstruct.consigneeValueContainer#stpID#")>
							<cfinvoke method="getIsPayerStop" customerID="#lastUpdatedConsCustomerID#" returnvariable="qGetIsPayer">
							<cfif qGetIsPayer.recordcount AND NOT qGetIsPayer.isPayer>
								<cfinvoke method="updateCustomer" formStruct="#arguments.frmstruct#" updateType="consignee" stopNo="#stpID#" returnvariable="lastUpdatedConsCustomerID" />
							<cfelseif evaluate('arguments.frmstruct.consigneeValueContainer#stpID#') EQ "">
								<cfinvoke method="formCustStruct" frmstruct="#arguments.frmstruct#" type="consignee" returnvariable="consigneeStruct" />
								<cfinvoke component ="#variables.objCustomerGateway#" method="AddCustomer" formStruct="#consigneeStruct#" idReturn="true" returnvariable="addedConsigneeResult"/>
								<cfset lastUpdatedConsCustomerID = addedConsigneeResult.id>
							<cfelse>
								<cfset lastUpdatedConsCustomerID = evaluate("arguments.frmstruct.consigneeValueContainer#stpID#")>
							</cfif>
						<cfelseif (structKeyExists(arguments.frmstruct,"consigneeFlag#stpID#") and  evaluate("arguments.frmstruct.consigneeFlag#stpID#") eq 1) AND evaluate('arguments.frmstruct.consigneeValueContainer#stpID#') eq "">
							<cfinvoke method="formCustStruct" frmstruct="#arguments.frmstruct#" type="consignee" stop="#stpID#" returnvariable="consigneeStruct" />
							<cfinvoke component ="#variables.objCustomerGateway#" method="AddCustomer" formStruct="#consigneeStruct#" idReturn="true" returnvariable="addedConsigneeResult"/>
							<cfset lastUpdatedConsCustomerID = addedConsigneeResult.id>
						<cfelse>
							<cfset lastUpdatedConsCustomerID = evaluate("arguments.frmstruct.consigneeValueContainer#stpID#")>
						</cfif>
					</cfif>


					<CFSTOREDPROC PROCEDURE="USP_InsertLoadStop" DATASOURCE="#variables.dsn#">
						<CFPROCPARAM VALUE="#LastLoadId#" cfsqltype="CF_SQL_VARCHAR">
						<CFPROCPARAM VALUE="True" cfsqltype="CF_SQL_VARCHAR">
						<CFPROCPARAM VALUE="True" cfsqltype="CF_SQL_VARCHAR">
						<CFPROCPARAM VALUE="#evaluate('arguments.frmstruct.BookedWith#stpID#')#" cfsqltype="CF_SQL_VARCHAR">
						<CFPROCPARAM VALUE="#evaluate('arguments.frmstruct.equipment#stpID#')#" cfsqltype="CF_SQL_VARCHAR">
						<CFPROCPARAM VALUE="#evaluate('arguments.frmstruct.driver#stpID#')#" cfsqltype="CF_SQL_VARCHAR">
						<CFPROCPARAM VALUE="#evaluate('arguments.frmstruct.drivercell#stpID#')#" cfsqltype="CF_SQL_VARCHAR">
						<CFPROCPARAM VALUE="#evaluate('arguments.frmstruct.truckNo#stpID#')#" cfsqltype="CF_SQL_VARCHAR">
						<CFPROCPARAM VALUE="#evaluate('arguments.frmstruct.trailerNo#stpID#')#" cfsqltype="CF_SQL_VARCHAR">
						<CFPROCPARAM VALUE="#evaluate('arguments.frmstruct.refNo#stpID#')#" cfsqltype="CF_SQL_VARCHAR">
						<CFPROCPARAM VALUE="#evaluate('arguments.frmstruct.milse#stpID#')#" cfsqltype="cf_sql_float">
						<!------If the carrier for this stop is not selected and the carrier for the first stop is selected then add the first stop carrier for this stop------>
						<cfif arguments.frmstruct.carrierid neq "" and evaluate('arguments.frmstruct.carrierid#stpID#') eq "">
							<CFPROCPARAM VALUE="#arguments.frmstruct.carrierid#" cfsqltype="CF_SQL_VARCHAR">
							<cfif len(arguments.frmstruct.stOffice) gt 1>
								<CFPROCPARAM VALUE="#arguments.frmstruct.stOffice#" cfsqltype="CF_SQL_VARCHAR">
							<cfelse>
								<CFPROCPARAM VALUE="Null" cfsqltype="CF_SQL_VARCHAR">
							</cfif>
						<cfelse>
							<CFPROCPARAM VALUE="#evaluate('arguments.frmstruct.carrierid#stpID#')#" cfsqltype="CF_SQL_VARCHAR">
							<cfif len(evaluate('arguments.frmstruct.stOffice#stpID#')) gt 1>
								<CFPROCPARAM VALUE="#evaluate('arguments.frmstruct.stOffice#stpID#')#" cfsqltype="CF_SQL_VARCHAR">
							<cfelse>
								<CFPROCPARAM VALUE="Null" cfsqltype="CF_SQL_VARCHAR">
							</cfif>
						</cfif>
						<CFPROCPARAM VALUE="#EVALUATE('arguments.frmstruct.consigneePickupNo#stpID#')#" cfsqltype="CF_SQL_VARCHAR">
						<CFPROCPARAM VALUE="#EVALUATE('arguments.frmstruct.consigneePickupDate#stpID#')#" cfsqltype="CF_SQL_dATE" null="#yesNoFormat(NOT len(EVALUATE('arguments.frmstruct.consigneePickupDate#stpID#')))#">
						<CFPROCPARAM VALUE="#EVALUATE('arguments.frmstruct.consigneePickupTime#stpID#')#" cfsqltype="CF_SQL_VARCHAR">
						<CFPROCPARAM VALUE="#EVALUATE('arguments.frmstruct.consigneetimein#stpID#')#" cfsqltype="CF_SQL_VARCHAR">
						<CFPROCPARAM VALUE="#EVALUATE('arguments.frmstruct.consigneetimeout#stpID#')#" cfsqltype="CF_SQL_VARCHAR">
						<CFPROCPARAM VALUE="#session.adminUserName#" cfsqltype="CF_SQL_VARCHAR">
						<CFPROCPARAM VALUE="#lastUpdatedConsCustomerID#" cfsqltype="CF_SQL_VARCHAR"  null="#yesNoFormat(NOT len(lastUpdatedConsCustomerID))#">
						<CFPROCPARAM VALUE="#ConsBlind#" cfsqltype="CF_SQL_BIT">
						<CFPROCPARAM VALUE="#EVALUATE('arguments.frmstruct.consigneeNotes#stpID#')#" cfsqltype="CF_SQL_VARCHAR">
						<CFPROCPARAM VALUE="#EVALUATE('arguments.frmstruct.consigneeDirection#stpID#')#" cfsqltype="CF_SQL_VARCHAR">
						<CFPROCPARAM VALUE="2" cfsqltype="CF_SQL_INTEGER">
						<CFPROCPARAM VALUE="#EVALUATE('arguments.frmstruct.consigneelocation#stpID#')#" cfsqltype="CF_SQL_VARCHAR">
						<CFPROCPARAM VALUE="#EVALUATE('arguments.frmstruct.consigneeCity#stpID#')#" cfsqltype="CF_SQL_VARCHAR">
						<CFPROCPARAM VALUE="#EVALUATE('arguments.frmstruct.consigneeStateName#stpID#')#" cfsqltype="CF_SQL_VARCHAR">
						<CFPROCPARAM VALUE="#EVALUATE('arguments.frmstruct.consigneeZipCode#stpID#')#" cfsqltype="CF_SQL_VARCHAR">
						<CFPROCPARAM VALUE="#EVALUATE('arguments.frmstruct.consigneeContactPerson#stpID#')#" cfsqltype="CF_SQL_VARCHAR">
						<CFPROCPARAM VALUE="#EVALUATE('arguments.frmstruct.consigneePhone#stpID#')#" cfsqltype="CF_SQL_VARCHAR">
						<CFPROCPARAM VALUE="#EVALUATE('arguments.frmstruct.consigneeFax#stpID#')#" cfsqltype="CF_SQL_VARCHAR">
						<CFPROCPARAM VALUE="#EVALUATE('arguments.frmstruct.consigneeEmail#stpID#')#" cfsqltype="CF_SQL_VARCHAR">
						<CFPROCPARAM VALUE="#EVALUATE('arguments.frmstruct.consigneeName#stpID#')#" cfsqltype="CF_SQL_VARCHAR">
						<CFPROCPARAM VALUE="#EVALUATE('arguments.frmstruct.userDef1#stpID#')#" cfsqltype="CF_SQL_VARCHAR">
						<CFPROCPARAM VALUE="#EVALUATE('arguments.frmstruct.userDef2#stpID#')#" cfsqltype="CF_SQL_VARCHAR">
						<CFPROCPARAM VALUE="#EVALUATE('arguments.frmstruct.userDef3#stpID#')#" cfsqltype="CF_SQL_VARCHAR">
						<CFPROCPARAM VALUE="#EVALUATE('arguments.frmstruct.userDef4#stpID#')#" cfsqltype="CF_SQL_VARCHAR">
						<CFPROCPARAM VALUE="#EVALUATE('arguments.frmstruct.userDef5#stpID#')#" cfsqltype="CF_SQL_VARCHAR">
						<CFPROCPARAM VALUE="#EVALUATE('arguments.frmstruct.userDef6#stpID#')#" cfsqltype="CF_SQL_VARCHAR">
						<CFPROCPARAM VALUE="#variables.NewStopNo#" cfsqltype="CF_SQL_INTEGER">
						<CFPROCPARAM VALUE="#variables.noOfDays#" cfsqltype="CF_SQL_INTEGER" null="#yesNoFormat(NOT len(variables.noOfDays))#">
						<CFPROCPARAM VALUE="#evaluate('arguments.frmstruct.Secdriver#stpID#')#" cfsqltype="CF_SQL_VARCHAR">
						<CFPROCPARAM VALUE="#evaluate('arguments.frmstruct.secDriverCell#stpID#')#" cfsqltype="CF_SQL_VARCHAR">
						<CFPROCPARAM VALUE="#evaluate('arguments.frmstruct.temperature#stpID#')#" cfsqltype="CF_SQL_FLOAT" null="#yesNoFormat(NOT len(evaluate('arguments.frmstruct.temperature#stpID#')))#">
						<CFPROCPARAM VALUE="#evaluate('arguments.frmstruct.temperaturescale#stpID#')#" cfsqltype="CF_SQL_VARCHAR">
						<cfprocresult name="qLastInsertedConsignee">
					</CFSTOREDPROC>
					<!--- Load Logging--->
					<cfset StructInsert(this.loadLogData, "New Load Stop-" & variables.NewStopNo+1 & "-Type-2", {
								FieldLabel = "New Load Stop. Stop Number: " & variables.NewStopNo+1 & " Stop Type: 2"
							}, true)>
					<!--- Load Logging--->					
					<cfset lastConsigneeStopId = qLastInsertedConsignee.lastStopID>
				<cfelse>
					<!--- Adding Stop1 Shipper --->
					<cfif structKeyExists(arguments.frmstruct,"shipperFlag#stpID#") and  evaluate("arguments.frmstruct.shipperFlag#stpID#") eq 2>
						<cfset lastUpdatedShipCustomerID = evaluate('arguments.frmstruct.shipperValueContainer#stpID#')>
						<cfinvoke method="getIsPayerStop" customerID="#lastUpdatedShipCustomerID#" returnvariable="qGetIsPayer">
						<cfif qGetIsPayer.recordcount AND NOT qGetIsPayer.isPayer>
							<cfinvoke method="updateCustomer" formStruct="#arguments.frmstruct#" updateType="shipper" stopNo="#stpID#" returnvariable="lastUpdatedShipCustomerID" />
						<cfelseif evaluate('arguments.frmstruct.shipperValueContainer#stpID#') EQ "">
							<cfinvoke method="formCustStruct" frmstruct="#arguments.frmstruct#" type="shipper" returnvariable="shipperStruct" />
							<cfinvoke component ="#variables.objCustomerGateway#" method="AddCustomer" formStruct="#shipperStruct#" idReturn="true" returnvariable="addedShipperResult"/>
							<cfset lastUpdatedShipCustomerID = addedShipperResult.id>
						<cfelse>
							<cfset lastUpdatedShipCustomerID = evaluate("arguments.frmstruct.shipperValueContainer#stpID#")>
						</cfif>
					<cfelseif (structKeyExists(arguments.frmstruct,"shipperFlag#stpID#") and  evaluate("arguments.frmstruct.shipperFlag#stpID#") eq 1) AND evaluate('arguments.frmstruct.shipperValueContainer#stpID#') eq "">
						<cfinvoke method="formCustStruct" frmstruct="#arguments.frmstruct#" type="shipper" stop="#stpID#" returnvariable="shipperStruct" />
					   	<cfinvoke component ="#variables.objCustomerGateway#" method="AddCustomer" formStruct="#shipperStruct#" idReturn="true" returnvariable="addedShipperResult"/>
						<cfset lastUpdatedShipCustomerID = addedShipperResult.id>
				   	<cfelse>
			  			<cfset lastUpdatedShipCustomerID = evaluate("arguments.frmstruct.shipperValueContainer#stpID#")>
				  	</cfif>
					<cfset variables.NewStopNo = 0>
			 		<cfloop from="1" to="#arguments.frmstruct.totalStop#" index="index">
			 			<cfquery name="qryGetStopExists" datasource="#variables.dsn#">
							SELECT StopNo FROM LoadStops
							WHERE LoadID = <cfqueryparam value="#frmstruct.editID#" cfsqltype="cf_sql_varchar">
							AND StopNo = <cfqueryparam value="#index#" cfsqltype="cf_sql_integer">
							AND StopNo < <cfqueryparam value="#stpID-1#" cfsqltype="cf_sql_integer">
						</cfquery>
						<cfif NOT qryGetStopExists.recordcount>
							<cfset variables.NewStopNo = index>
							<cfbreak>
						<cfelse>
							<cfset variables.NewStopNo = index>
						</cfif>
			 		</cfloop>
					<!--- Load Logging--->
					<cfinvoke method="LoadLogRegister" type="USP_UpdateLoadStop" instance=1 whereList="#LastLoadId#,#stopNo#,2">
					<!--- Load Logging--->
				  	<CFSTOREDPROC PROCEDURE="USP_UpdateLoadStop" DATASOURCE="#variables.dsn#">
						<CFPROCPARAM VALUE="#LastLoadId#" cfsqltype="CF_SQL_VARCHAR">
						<CFPROCPARAM VALUE="True" cfsqltype="CF_SQL_VARCHAR">
						<CFPROCPARAM VALUE="True" cfsqltype="CF_SQL_VARCHAR">
						<CFPROCPARAM VALUE="#evaluate('arguments.frmstruct.BookedWith#stpID#')#" cfsqltype="CF_SQL_VARCHAR">
						<CFPROCPARAM VALUE="#evaluate('arguments.frmstruct.equipment#stpID#')#" cfsqltype="CF_SQL_VARCHAR">
						<CFPROCPARAM VALUE="#evaluate('arguments.frmstruct.driver#stpID#')#" cfsqltype="CF_SQL_VARCHAR">
						<CFPROCPARAM VALUE="#evaluate('arguments.frmstruct.drivercell#stpID#')#" cfsqltype="CF_SQL_VARCHAR">
						<CFPROCPARAM VALUE="#evaluate('arguments.frmstruct.truckNo#stpID#')#" cfsqltype="CF_SQL_VARCHAR">
						<CFPROCPARAM VALUE="#evaluate('arguments.frmstruct.trailerNo#stpID#')#" cfsqltype="CF_SQL_VARCHAR">
						<CFPROCPARAM VALUE="#evaluate('arguments.frmstruct.refNo#stpID#')#" cfsqltype="CF_SQL_VARCHAR">
						<CFPROCPARAM VALUE="#evaluate('arguments.frmstruct.milse#stpID#')#" cfsqltype="cf_sql_float">
						<!------If the carrier for this stop is not selected and the carrier for the first stop is selected then add the first stop carrier for this stop------>
						<cfif arguments.frmstruct.carrierid neq "" and evaluate('arguments.frmstruct.carrierid#stpID#') eq "">
							<CFPROCPARAM VALUE="#arguments.frmstruct.carrierid#" cfsqltype="CF_SQL_VARCHAR">
							<cfif len(arguments.frmstruct.stOffice) gt 1>
								<CFPROCPARAM VALUE="#arguments.frmstruct.stOffice#" cfsqltype="CF_SQL_VARCHAR">
							<cfelse>
								<CFPROCPARAM VALUE="Null" cfsqltype="CF_SQL_VARCHAR">
							</cfif>
						<cfelse>
							<CFPROCPARAM VALUE="#evaluate('arguments.frmstruct.carrierid#stpID#')#" cfsqltype="CF_SQL_VARCHAR">
							<cfif len(evaluate('arguments.frmstruct.stOffice#stpID#')) gt 1>
								<CFPROCPARAM VALUE="#evaluate('arguments.frmstruct.stOffice#stpID#')#" cfsqltype="CF_SQL_VARCHAR">
							<cfelse>
								<CFPROCPARAM VALUE="Null" cfsqltype="CF_SQL_VARCHAR">
							</cfif>
						</cfif>
						<CFPROCPARAM VALUE="#EVALUATE('arguments.frmstruct.shipperPickupNO1#stpID#')#" cfsqltype="CF_SQL_VARCHAR">
						<CFPROCPARAM VALUE="#EVALUATE('arguments.frmstruct.shipperPickupDate#stpID#')#" cfsqltype="CF_SQL_dATE" null="#yesNoFormat(NOT len(EVALUATE('arguments.frmstruct.shipperPickupDate#stpID#')))#">
						<CFPROCPARAM VALUE="#EVALUATE('arguments.frmstruct.shipperPickupTime#stpID#')#" cfsqltype="CF_SQL_VARCHAR">
						<CFPROCPARAM VALUE="#EVALUATE('arguments.frmstruct.shipperTimeIn#stpID#')#" cfsqltype="CF_SQL_VARCHAR">
						<CFPROCPARAM VALUE="#EVALUATE('arguments.frmstruct.shipperTimeOut#stpID#')#" cfsqltype="CF_SQL_VARCHAR">
						<CFPROCPARAM VALUE="#session.adminUserName#" cfsqltype="CF_SQL_VARCHAR">
						<CFPROCPARAM VALUE="#lastUpdatedShipCustomerID#" cfsqltype="CF_SQL_VARCHAR"  null="#yesNoFormat(NOT len(lastUpdatedShipCustomerID))#">
						<CFPROCPARAM VALUE="#ShipBlind#" cfsqltype="CF_SQL_BIT">
						<CFPROCPARAM VALUE="#EVALUATE('arguments.frmstruct.shipperNotes#stpID#')#" cfsqltype="CF_SQL_VARCHAR">
						<CFPROCPARAM VALUE="#EVALUATE('arguments.frmstruct.shipperDirection#stpID#')#" cfsqltype="CF_SQL_VARCHAR">
						<CFPROCPARAM VALUE="1" cfsqltype="CF_SQL_INTEGER">
						<CFPROCPARAM VALUE="#stopNo#" cfsqltype="CF_SQL_INTEGER"> <!--- Stop Number --->
						<CFPROCPARAM VALUE="#EVALUATE('arguments.frmstruct.shipperlocation#stpID#')#" cfsqltype="CF_SQL_VARCHAR">
						<CFPROCPARAM VALUE="#EVALUATE('arguments.frmstruct.shipperCity#stpID#')#" cfsqltype="CF_SQL_VARCHAR">
						<CFPROCPARAM VALUE="#EVALUATE('arguments.frmstruct.shipperStateName#stpID#')#" cfsqltype="CF_SQL_VARCHAR">
						<CFPROCPARAM VALUE="#EVALUATE('arguments.frmstruct.shipperZipCode#stpID#')#" cfsqltype="CF_SQL_VARCHAR">
						<CFPROCPARAM VALUE="#EVALUATE('arguments.frmstruct.shipperContactPerson#stpID#')#" cfsqltype="CF_SQL_VARCHAR">
						<CFPROCPARAM VALUE="#EVALUATE('arguments.frmstruct.shipperPhone#stpID#')#" cfsqltype="CF_SQL_VARCHAR">
						<CFPROCPARAM VALUE="#EVALUATE('arguments.frmstruct.shipperFax#stpID#')#" cfsqltype="CF_SQL_VARCHAR">
						<CFPROCPARAM VALUE="#EVALUATE('arguments.frmstruct.shipperEmail#stpID#')#" cfsqltype="CF_SQL_VARCHAR">
						<CFPROCPARAM VALUE="#EVALUATE('arguments.frmstruct.shipperName#stpID#')#" cfsqltype="CF_SQL_VARCHAR">
						<CFPROCPARAM VALUE="#EVALUATE('arguments.frmstruct.userDef1#stpID#')#" cfsqltype="CF_SQL_VARCHAR">
						<CFPROCPARAM VALUE="#EVALUATE('arguments.frmstruct.userDef2#stpID#')#" cfsqltype="CF_SQL_VARCHAR">
						<CFPROCPARAM VALUE="#EVALUATE('arguments.frmstruct.userDef3#stpID#')#" cfsqltype="CF_SQL_VARCHAR">
						<CFPROCPARAM VALUE="#EVALUATE('arguments.frmstruct.userDef4#stpID#')#" cfsqltype="CF_SQL_VARCHAR">
						<CFPROCPARAM VALUE="#EVALUATE('arguments.frmstruct.userDef5#stpID#')#" cfsqltype="CF_SQL_VARCHAR">
						<CFPROCPARAM VALUE="#EVALUATE('arguments.frmstruct.userDef6#stpID#')#" cfsqltype="CF_SQL_VARCHAR">
						<CFPROCPARAM VALUE="#variables.NewStopNo#" cfsqltype="CF_SQL_INTEGER">
						<CFPROCPARAM VALUE="#variables.noOfDays#" cfsqltype="CF_SQL_INTEGER" null="#yesNoFormat(NOT len(variables.noOfDays))#">
						<CFPROCPARAM VALUE="#evaluate('arguments.frmstruct.Secdriver#stpID#')#" cfsqltype="CF_SQL_VARCHAR">
						<CFPROCPARAM VALUE="#evaluate('arguments.frmstruct.secDriverCell#stpID#')#" cfsqltype="CF_SQL_VARCHAR">
						<CFPROCPARAM VALUE="#evaluate('arguments.frmstruct.temperature#stpID#')#" cfsqltype="CF_SQL_FLOAT" null="#yesNoFormat(NOT len(evaluate('arguments.frmstruct.temperature#stpID#')))#">
						<CFPROCPARAM VALUE="#evaluate('arguments.frmstruct.temperaturescale#stpID#')#" cfsqltype="CF_SQL_VARCHAR">
						<cfprocresult name="qLastInsertedShipper">
					</CFSTOREDPROC>
					<!--- Load Logging--->
					<cfinvoke method="LoadLogRegister" type="USP_UpdateLoadStop" instance=2 whereList="#LastLoadId#,#stopNo#,2">
					<!--- Load Logging--->
					<cfset lastInsertedStopId = qLastInsertedShipper.lastStopID>
					<cfif structKeyExists(arguments.frmstruct,"consigneeFlag#stpID#") and  evaluate("arguments.frmstruct.consigneeFlag#stpID#") eq 2>
						<cfset lastUpdatedConsCustomerID = Evaluate("arguments.frmstruct.consigneeValueContainer#stpID#")>
						<cfinvoke method="getIsPayerStop" customerID="#lastUpdatedConsCustomerID#" returnvariable="qGetIsPayer">
						<cfif qGetIsPayer.recordcount AND NOT qGetIsPayer.isPayer>
							<cfinvoke method="updateCustomer" formStruct="#arguments.frmstruct#" updateType="consignee" stopNo="#stpID#" returnvariable="lastUpdatedConsCustomerID" />
						<cfelseif evaluate('arguments.frmstruct.consigneeValueContainer#stpID#') EQ "">
							<cfinvoke method="formCustStruct" frmstruct="#arguments.frmstruct#" type="consignee" returnvariable="consigneeStruct" />
							<cfinvoke component ="#variables.objCustomerGateway#" method="AddCustomer" formStruct="#consigneeStruct#" idReturn="true" returnvariable="addedConsigneeResult"/>
							<cfset lastUpdatedConsCustomerID = addedConsigneeResult.id>
						<cfelse>
							<cfset lastUpdatedConsCustomerID = evaluate("arguments.frmstruct.consigneeValueContainer#stpID#")>
						</cfif>
					<cfelseif (structKeyExists(arguments.frmstruct,"consigneeFlag#stpID#") and  evaluate("arguments.frmstruct.consigneeFlag#stpID#") eq 1) AND evaluate('arguments.frmstruct.consigneeValueContainer#stpID#') eq "">
						<cfinvoke method="formCustStruct" frmstruct="#arguments.frmstruct#" type="consignee" stop="#stpID#" returnvariable="consigneeStruct" />
						<cfinvoke component ="#variables.objCustomerGateway#" method="AddCustomer" formStruct="#consigneeStruct#" idReturn="true" returnvariable="addedConsigneeResult"/>
						<cfset lastUpdatedConsCustomerID = addedConsigneeResult.id>
			   		<cfelse>
						<cfset lastUpdatedConsCustomerID =	evaluate("arguments.frmstruct.consigneeValueContainer#stpID#")>
					</cfif>
					<!--- Load Logging--->
					<cfinvoke method="LoadLogRegister" type="USP_UpdateLoadStop" instance=1 whereList="#LastLoadId#,#stopNo#,2">
					<!--- Load Logging--->					
					<CFSTOREDPROC PROCEDURE="USP_UpdateLoadStop" DATASOURCE="#variables.dsn#">
						<CFPROCPARAM VALUE="#LastLoadId#" cfsqltype="CF_SQL_VARCHAR">
						<CFPROCPARAM VALUE="True" cfsqltype="CF_SQL_VARCHAR">
						<CFPROCPARAM VALUE="True" cfsqltype="CF_SQL_VARCHAR">
						<CFPROCPARAM VALUE="#evaluate('arguments.frmstruct.BookedWith#stpID#')#" cfsqltype="CF_SQL_VARCHAR">
						<CFPROCPARAM VALUE="#evaluate('arguments.frmstruct.equipment#stpID#')#" cfsqltype="CF_SQL_VARCHAR">
						<CFPROCPARAM VALUE="#evaluate('arguments.frmstruct.driver#stpID#')#" cfsqltype="CF_SQL_VARCHAR">
						<CFPROCPARAM VALUE="#evaluate('arguments.frmstruct.drivercell#stpID#')#" cfsqltype="CF_SQL_VARCHAR">
						<CFPROCPARAM VALUE="#evaluate('arguments.frmstruct.truckNo#stpID#')#" cfsqltype="CF_SQL_VARCHAR">
						<CFPROCPARAM VALUE="#evaluate('arguments.frmstruct.trailerNo#stpID#')#" cfsqltype="CF_SQL_VARCHAR">
						<CFPROCPARAM VALUE="#evaluate('arguments.frmstruct.refNo#stpID#')#" cfsqltype="CF_SQL_VARCHAR">
						<CFPROCPARAM VALUE="#evaluate('arguments.frmstruct.milse#stpID#')#" cfsqltype="cf_sql_float">
						<!------If the carrier for this stop is not selected and the carrier for the first stop is selected then add the first stop carrier for this stop------>
						<cfif arguments.frmstruct.carrierid neq "" and evaluate('arguments.frmstruct.carrierid#stpID#') eq "">
							<CFPROCPARAM VALUE="#arguments.frmstruct.carrierid#" cfsqltype="CF_SQL_VARCHAR">
							<cfif len(arguments.frmstruct.stOffice) gt 1>
								<CFPROCPARAM VALUE="#arguments.frmstruct.stOffice#" cfsqltype="CF_SQL_VARCHAR">
							<cfelse>
								<CFPROCPARAM VALUE="Null" cfsqltype="CF_SQL_VARCHAR">
							</cfif>
						<cfelse>
							<CFPROCPARAM VALUE="#evaluate('arguments.frmstruct.carrierid#stpID#')#" cfsqltype="CF_SQL_VARCHAR">
							<cfif len(evaluate('arguments.frmstruct.stOffice#stpID#')) gt 1>
								<CFPROCPARAM VALUE="#evaluate('arguments.frmstruct.stOffice#stpID#')#" cfsqltype="CF_SQL_VARCHAR">
							<cfelse>
								<CFPROCPARAM VALUE="Null" cfsqltype="CF_SQL_VARCHAR">
							</cfif>
						</cfif>
						<CFPROCPARAM VALUE="#EVALUATE('arguments.frmstruct.consigneePickupNo#stpID#')#" cfsqltype="CF_SQL_VARCHAR">
						<CFPROCPARAM VALUE="#EVALUATE('arguments.frmstruct.consigneePickupDate#stpID#')#" cfsqltype="CF_SQL_dATE" null="#yesNoFormat(NOT len(EVALUATE('arguments.frmstruct.consigneePickupDate#stpID#')))#">
						<CFPROCPARAM VALUE="#EVALUATE('arguments.frmstruct.consigneePickupTime#stpID#')#" cfsqltype="CF_SQL_VARCHAR">
						<CFPROCPARAM VALUE="#EVALUATE('arguments.frmstruct.consigneetimein#stpID#')#" cfsqltype="CF_SQL_VARCHAR">
						<CFPROCPARAM VALUE="#EVALUATE('arguments.frmstruct.consigneetimeout#stpID#')#" cfsqltype="CF_SQL_VARCHAR">
						<CFPROCPARAM VALUE="#session.adminUserName#" cfsqltype="CF_SQL_VARCHAR">
						<CFPROCPARAM VALUE="#lastUpdatedConsCustomerID#" cfsqltype="CF_SQL_VARCHAR" null="#yesNoFormat(NOT len(lastUpdatedConsCustomerID))#">
						<CFPROCPARAM VALUE="#ConsBlind#" cfsqltype="CF_SQL_BIT">
						<CFPROCPARAM VALUE="#EVALUATE('arguments.frmstruct.consigneeNotes#stpID#')#" cfsqltype="CF_SQL_VARCHAR">
						<CFPROCPARAM VALUE="#EVALUATE('arguments.frmstruct.consigneeDirection#stpID#')#" cfsqltype="CF_SQL_VARCHAR">
						<CFPROCPARAM VALUE="2" cfsqltype="CF_SQL_INTEGER">
						<CFPROCPARAM VALUE="#stopNo#" cfsqltype="CF_SQL_INTEGER"> <!--- Stop Number --->
						<CFPROCPARAM VALUE="#EVALUATE('arguments.frmstruct.consigneelocation#stpID#')#" cfsqltype="CF_SQL_VARCHAR">
						<CFPROCPARAM VALUE="#EVALUATE('arguments.frmstruct.consigneeCity#stpID#')#" cfsqltype="CF_SQL_VARCHAR">
						<CFPROCPARAM VALUE="#EVALUATE('arguments.frmstruct.consigneeStateName#stpID#')#" cfsqltype="CF_SQL_VARCHAR">
						<CFPROCPARAM VALUE="#EVALUATE('arguments.frmstruct.consigneeZipCode#stpID#')#" cfsqltype="CF_SQL_VARCHAR">
						<CFPROCPARAM VALUE="#EVALUATE('arguments.frmstruct.consigneeContactPerson#stpID#')#" cfsqltype="CF_SQL_VARCHAR">
						<CFPROCPARAM VALUE="#EVALUATE('arguments.frmstruct.consigneePhone#stpID#')#" cfsqltype="CF_SQL_VARCHAR">
						<CFPROCPARAM VALUE="#EVALUATE('arguments.frmstruct.consigneeFax#stpID#')#" cfsqltype="CF_SQL_VARCHAR">
						<CFPROCPARAM VALUE="#EVALUATE('arguments.frmstruct.consigneeEmail#stpID#')#" cfsqltype="CF_SQL_VARCHAR">
						<CFPROCPARAM VALUE="#EVALUATE('arguments.frmstruct.consigneeName#stpID#')#" cfsqltype="CF_SQL_VARCHAR">
						<CFPROCPARAM VALUE="#EVALUATE('arguments.frmstruct.userDef1#stpID#')#" cfsqltype="CF_SQL_VARCHAR">
						<CFPROCPARAM VALUE="#EVALUATE('arguments.frmstruct.userDef2#stpID#')#" cfsqltype="CF_SQL_VARCHAR">
						<CFPROCPARAM VALUE="#EVALUATE('arguments.frmstruct.userDef3#stpID#')#" cfsqltype="CF_SQL_VARCHAR">
						<CFPROCPARAM VALUE="#EVALUATE('arguments.frmstruct.userDef4#stpID#')#" cfsqltype="CF_SQL_VARCHAR">
						<CFPROCPARAM VALUE="#EVALUATE('arguments.frmstruct.userDef5#stpID#')#" cfsqltype="CF_SQL_VARCHAR">
						<CFPROCPARAM VALUE="#EVALUATE('arguments.frmstruct.userDef6#stpID#')#" cfsqltype="CF_SQL_VARCHAR">
						<CFPROCPARAM VALUE="#variables.NewStopNo#" cfsqltype="CF_SQL_INTEGER">
						<CFPROCPARAM VALUE="#variables.noOfDays#" cfsqltype="CF_SQL_INTEGER" null="#yesNoFormat(NOT len(variables.noOfDays))#">
						<CFPROCPARAM VALUE="#evaluate('arguments.frmstruct.Secdriver#stpID#')#" cfsqltype="CF_SQL_VARCHAR">
						<CFPROCPARAM VALUE="#evaluate('arguments.frmstruct.secDriverCell#stpID#')#" cfsqltype="CF_SQL_VARCHAR">
						<CFPROCPARAM VALUE="#evaluate('arguments.frmstruct.temperature#stpID#')#" cfsqltype="CF_SQL_FLOAT" null="#yesNoFormat(NOT len(evaluate('arguments.frmstruct.temperature#stpID#')))#">
						<CFPROCPARAM VALUE="#evaluate('arguments.frmstruct.temperaturescale#stpID#')#" cfsqltype="CF_SQL_VARCHAR">
						<cfprocresult name="qLastInsertedConsignee">
					</CFSTOREDPROC>
					<cfset lastConsigneeStopId = qLastInsertedConsignee.lastStopID>
					<!--- Load Logging--->
					<cfinvoke method="LoadLogRegister" type="USP_UpdateLoadStop" instance=2 whereList="#LastLoadId#,#stopNo#,2">
					<!--- Load Logging--->
				</cfif>
				<!--- IMPORT Load Stop Starts Here ---->
				<cfif structKeyExists(arguments.frmstruct,"dateDispatched#stpID#")>
					<cfquery name="qLoadStopIntermodalImportExists" datasource="#variables.dsn#">
						SELECT LoadStopID FROM LoadStopIntermodalImport
						WHERE LoadStopID = <cfqueryparam value="#lastInsertedStopId#" cfsqltype="cf_sql_varchar">
						AND StopNo = <cfqueryparam value="#stpID#" cfsqltype="cf_sql_integer">
					</cfquery>
					<cfif qLoadStopIntermodalImportExists.recordcount>
						<cfquery name="qUpdateLoadStopIntermodalImport" datasource="#variables.dsn#">
							update
								LoadStopIntermodalImport
							set dateDispatched = <cfqueryparam value="#EVALUATE('arguments.frmstruct.dateDispatched#stpID#')#" cfsqltype="cf_sql_date">,
								steamShipLine = <cfqueryparam value="#EVALUATE('arguments.frmstruct.steamShipLine#stpID#')#" cfsqltype="cf_sql_varchar">,
								eta = <cfqueryparam value="#EVALUATE('arguments.frmstruct.eta#stpID#')#" cfsqltype="cf_sql_date">,
								oceanBillofLading = <cfqueryparam value="#EVALUATE('arguments.frmstruct.oceanBillofLading#stpID#')#" cfsqltype="cf_sql_varchar">,
								actualArrivalDate = <cfqueryparam value="#EVALUATE('arguments.frmstruct.actualArrivalDate#stpID#')#" cfsqltype="cf_sql_date">,
								seal = <cfqueryparam value="#EVALUATE('arguments.frmstruct.seal#stpID#')#" cfsqltype="cf_sql_varchar">,
								customersReleaseDate = <cfqueryparam value="#EVALUATE('arguments.frmstruct.customersReleaseDate#stpID#')#" cfsqltype="cf_sql_date">,
								vesselName = <cfqueryparam value="#EVALUATE('arguments.frmstruct.vesselName#stpID#')#" cfsqltype="cf_sql_varchar">,
								freightReleaseDate = <cfqueryparam value="#EVALUATE('arguments.frmstruct.freightReleaseDate#stpID#')#" cfsqltype="cf_sql_date">,
								dateAvailable = <cfqueryparam value="#EVALUATE('arguments.frmstruct.dateAvailable#stpID#')#" cfsqltype="cf_sql_date">,
								demuggageFreeTimeExpirationDate = <cfqueryparam value="#EVALUATE('arguments.frmstruct.demuggageFreeTimeExpirationDate#stpID#')#" cfsqltype="cf_sql_date">,
								perDiemFreeTimeExpirationDate = <cfqueryparam value="#EVALUATE('arguments.frmstruct.perDiemFreeTimeExpirationDate#stpID#')#" cfsqltype="cf_sql_date">,
								pickupDate = <cfqueryparam value="#EVALUATE('arguments.frmstruct.pickupDate#stpID#')#" cfsqltype="cf_sql_date" null="#yesNoFormat(NOT len(EVALUATE('arguments.frmstruct.pickupDate#stpID#')))#">,
								requestedDeliveryDate = <cfqueryparam value="#EVALUATE('arguments.frmstruct.requestedDeliveryDate#stpID#')#" cfsqltype="cf_sql_date">,
								requestedDeliveryTime = <cfqueryparam value="#EVALUATE('arguments.frmstruct.requestedDeliveryTime#stpID#')#" cfsqltype="cf_sql_varchar">,
								scheduledDeliveryDate = <cfqueryparam value="#EVALUATE('arguments.frmstruct.scheduledDeliveryDate#stpID#')#" cfsqltype="cf_sql_date">,
								scheduledDeliveryTime = <cfqueryparam value="#EVALUATE('arguments.frmstruct.scheduledDeliveryTime#stpID#')#" cfsqltype="cf_sql_varchar">,
								unloadingDelayDetentionStartDate = <cfqueryparam value="#EVALUATE('arguments.frmstruct.unloadingDelayDetentionStartDate#stpID#')#" cfsqltype="cf_sql_date">,
								unloadingDelayDetentionStartTime = <cfqueryparam value="#EVALUATE('arguments.frmstruct.unloadingDelayDetentionStartTime#stpID#')#" cfsqltype="cf_sql_varchar">,
								actualDeliveryDate = <cfqueryparam value="#EVALUATE('arguments.frmstruct.actualDeliveryDate#stpID#')#" cfsqltype="cf_sql_date">,
								unloadingDelayDetentionEndDate = <cfqueryparam value="#EVALUATE('arguments.frmstruct.unloadingDelayDetentionEndDate#stpID#')#" cfsqltype="cf_sql_date">,
								unloadingDelayDetentionEndTime = <cfqueryparam value="#EVALUATE('arguments.frmstruct.unloadingDelayDetentionEndTime#stpID#')#" cfsqltype="cf_sql_varchar">,
								returnDate = <cfqueryparam value="#EVALUATE('arguments.frmstruct.returnDate#stpID#')#" cfsqltype="cf_sql_date">,
								pickUpAddress = <cfqueryparam value="#EVALUATE('arguments.frmstruct.pickUpAddress#stpID#')#" cfsqltype="cf_sql_varchar">,
								deliveryAddress = <cfqueryparam value="#EVALUATE('arguments.frmstruct.deliveryAddress#stpID#')#" cfsqltype="cf_sql_varchar">,
								emptyReturnAddress = <cfqueryparam value="#EVALUATE('arguments.frmstruct.emptyReturnAddress#stpID#')#" cfsqltype="cf_sql_varchar">
							WHERE
								LoadStopID = <cfqueryparam value="#lastInsertedStopId#" cfsqltype="cf_sql_varchar"> AND
								StopNo = <cfqueryparam value="#stpID#" cfsqltype="cf_sql_integer">
						</cfquery>
					<cfelse>
						<cfquery name="qUpdateLoadStopIntermodalImport" datasource="#variables.dsn#">
							insert into LoadStopIntermodalImport
								(
									LoadStopID,
									StopNo,
									dateDispatched,
									steamShipLine,
									eta,
									oceanBillofLading,
									actualArrivalDate,
									seal,
									customersReleaseDate,
									vesselName,
									freightReleaseDate,
									dateAvailable,
									demuggageFreeTimeExpirationDate,
									perDiemFreeTimeExpirationDate,
									pickupDate,
									requestedDeliveryDate,
									requestedDeliveryTime,
									scheduledDeliveryDate,
									scheduledDeliveryTime,
									unloadingDelayDetentionStartDate,
									unloadingDelayDetentionStartTime,
									actualDeliveryDate,
									unloadingDelayDetentionEndDate,
									unloadingDelayDetentionEndTime,
									returnDate,
									pickUpAddress,
									deliveryAddress,
									emptyReturnAddress
								)
							values
								(
									<cfqueryparam value="#lastInsertedStopId#" cfsqltype="cf_sql_varchar">,
									<cfqueryparam value="#stpID#" cfsqltype="cf_sql_integer">,
									<cfqueryparam value="#EVALUATE('arguments.frmstruct.dateDispatched#stpID#')#" cfsqltype="cf_sql_date">,
									<cfqueryparam value="#EVALUATE('arguments.frmstruct.steamShipLine#stpID#')#" cfsqltype="cf_sql_varchar">,
									<cfqueryparam value="#EVALUATE('arguments.frmstruct.eta#stpID#')#" cfsqltype="cf_sql_date">,
									<cfqueryparam value="#EVALUATE('arguments.frmstruct.oceanBillofLading#stpID#')#" cfsqltype="cf_sql_varchar">,
									<cfqueryparam value="#EVALUATE('arguments.frmstruct.actualArrivalDate#stpID#')#" cfsqltype="cf_sql_date">,
									<cfqueryparam value="#EVALUATE('arguments.frmstruct.seal#stpID#')#" cfsqltype="cf_sql_varchar">,
									<cfqueryparam value="#EVALUATE('arguments.frmstruct.customersReleaseDate#stpID#')#" cfsqltype="cf_sql_date">,
									<cfqueryparam value="#EVALUATE('arguments.frmstruct.vesselName#stpID#')#" cfsqltype="cf_sql_varchar">,
									<cfqueryparam value="#EVALUATE('arguments.frmstruct.freightReleaseDate#stpID#')#" cfsqltype="cf_sql_date">,
									<cfqueryparam value="#EVALUATE('arguments.frmstruct.dateAvailable#stpID#')#" cfsqltype="cf_sql_date">,
									<cfqueryparam value="#EVALUATE('arguments.frmstruct.demuggageFreeTimeExpirationDate#stpID#')#" cfsqltype="cf_sql_date">,
									<cfqueryparam value="#EVALUATE('arguments.frmstruct.perDiemFreeTimeExpirationDate#stpID#')#" cfsqltype="cf_sql_date">,
									<cfqueryparam value="#EVALUATE('arguments.frmstruct.pickupDate#stpID#')#" cfsqltype="cf_sql_date" null="#yesNoFormat(NOT len(EVALUATE('arguments.frmstruct.pickupDate#stpID#')))#">,
									<cfqueryparam value="#EVALUATE('arguments.frmstruct.requestedDeliveryDate#stpID#')#" cfsqltype="cf_sql_date">,
									<cfqueryparam value="#EVALUATE('arguments.frmstruct.requestedDeliveryTime#stpID#')#" cfsqltype="cf_sql_varchar">,
									<cfqueryparam value="#EVALUATE('arguments.frmstruct.scheduledDeliveryDate#stpID#')#" cfsqltype="cf_sql_date">,
									<cfqueryparam value="#EVALUATE('arguments.frmstruct.scheduledDeliveryTime#stpID#')#" cfsqltype="cf_sql_varchar">,
									<cfqueryparam value="#EVALUATE('arguments.frmstruct.unloadingDelayDetentionStartDate#stpID#')#" cfsqltype="cf_sql_date">,
									<cfqueryparam value="#EVALUATE('arguments.frmstruct.unloadingDelayDetentionStartTime#stpID#')#" cfsqltype="cf_sql_varchar">,
									<cfqueryparam value="#EVALUATE('arguments.frmstruct.actualDeliveryDate#stpID#')#" cfsqltype="cf_sql_date">,
									<cfqueryparam value="#EVALUATE('arguments.frmstruct.unloadingDelayDetentionEndDate#stpID#')#" cfsqltype="cf_sql_date">,
									<cfqueryparam value="#EVALUATE('arguments.frmstruct.unloadingDelayDetentionEndTime#stpID#')#" cfsqltype="cf_sql_varchar">,
									<cfqueryparam value="#EVALUATE('arguments.frmstruct.returnDate#stpID#')#" cfsqltype="cf_sql_date">,
									<cfqueryparam value="#EVALUATE('arguments.frmstruct.pickUpAddress#stpID#')#" cfsqltype="cf_sql_varchar">,
									<cfqueryparam value="#EVALUATE('arguments.frmstruct.deliveryAddress#stpID#')#" cfsqltype="cf_sql_varchar">,
									<cfqueryparam value="#EVALUATE('arguments.frmstruct.emptyReturnAddress#stpID#')#" cfsqltype="cf_sql_varchar">
								)
						</cfquery>
					</cfif>
					<cfinvoke component="#variables.objLoadgatewayUpdate#" method="getLoadStopAddress" tablename="LoadStopCargoPickupAddress" address="#EVALUATE('arguments.frmstruct.pickUpAddress#stpID#')#" returnvariable="qLoadStopCargoPickupAddressExists" />
					<cfif qLoadStopCargoPickupAddressExists.recordcount>
						<cfquery name="qUpdateCargoPickupAddress" datasource="#variables.dsn#">
							update
								LoadStopCargoPickupAddress
							set
								address =   <cfqueryparam value="#EVALUATE('arguments.frmstruct.pickUpAddress#stpID#')#" cfsqltype="cf_sql_varchar">,
								LoadStopID = <cfqueryparam value="#lastInsertedStopId#" cfsqltype="cf_sql_varchar">,
								dateModified = <cfqueryparam value="#now()#" cfsqltype="cf_sql_date">
							where ID = <cfqueryparam value="#qLoadStopCargoPickupAddressExists.ID#" cfsqltype="cf_sql_integer">
						</cfquery>
					<cfelse>
						<cfquery name="qInsertCargoPickupAddress" datasource="#variables.dsn#">
							insert into LoadStopCargoPickupAddress
								(address, LoadStopID, dateAdded, dateModified)
							values
								(
									<cfqueryparam value="#EVALUATE('arguments.frmstruct.pickUpAddress#stpID#')#" cfsqltype="cf_sql_varchar">,
									<cfqueryparam value="#lastInsertedStopId#" cfsqltype="cf_sql_varchar">,
									<cfqueryparam value="#now()#" cfsqltype="cf_sql_date">,
									<cfqueryparam value="#now()#" cfsqltype="cf_sql_date">
								)
						</cfquery>
					</cfif>
					<cfinvoke component="#variables.objLoadgatewayUpdate#" method="getLoadStopAddress" tablename="LoadStopCargoDeliveryAddress" address="#EVALUATE('arguments.frmstruct.deliveryAddress#stpID#')#" returnvariable="qLoadStopCargoDeliveryAddressExists" />
					<cfif qLoadStopCargoDeliveryAddressExists.recordcount>
						<cfquery name="qUpdateCargoDeliveryAddress" datasource="#variables.dsn#">
							update
								LoadStopCargoDeliveryAddress
							set
								address = <cfqueryparam value="#EVALUATE('arguments.frmstruct.deliveryAddress#stpID#')#" cfsqltype="cf_sql_varchar">,
								LoadStopID = <cfqueryparam value="#lastInsertedStopId#" cfsqltype="cf_sql_varchar">,
								dateModified = <cfqueryparam value="#now()#" cfsqltype="cf_sql_date">
							where ID = <cfqueryparam value="#qLoadStopCargoDeliveryAddressExists.ID#" cfsqltype="cf_sql_integer">
						</cfquery>
					<cfelse>
						<cfquery name="qInsertCargoDeliveryAddress" datasource="#variables.dsn#">
							insert into LoadStopCargoDeliveryAddress
								(address, LoadStopID, dateAdded, dateModified)
							values
								(
									<cfqueryparam value="#EVALUATE('arguments.frmstruct.deliveryAddress#stpID#')#" cfsqltype="cf_sql_varchar">,
									<cfqueryparam value="#lastInsertedStopId#" cfsqltype="cf_sql_varchar">,
									<cfqueryparam value="#now()#" cfsqltype="cf_sql_date">,
									<cfqueryparam value="#now()#" cfsqltype="cf_sql_date">
								)
						</cfquery>
					</cfif>
					<cfinvoke component="#variables.objLoadgatewayUpdate#" method="getLoadStopAddress" tablename="LoadStopEmptyReturnAddress" address="#EVALUATE('arguments.frmstruct.emptyReturnAddress#stpID#')#" returnvariable="qLoadStopEmptyReturnAddressExists" />
					<cfif qLoadStopEmptyReturnAddressExists.recordcount>
						<cfquery name="qUpdateEmptyReturnAddress" datasource="#variables.dsn#">
							update
								LoadStopEmptyReturnAddress
							set
								address = <cfqueryparam value="#EVALUATE('arguments.frmstruct.emptyReturnAddress#stpID#')#" cfsqltype="cf_sql_varchar">,
								LoadStopID = <cfqueryparam value="#lastInsertedStopId#" cfsqltype="cf_sql_varchar">,
								dateModified = <cfqueryparam value="#now()#" cfsqltype="cf_sql_date">
							where ID = <cfqueryparam value="#qLoadStopEmptyReturnAddressExists.ID#" cfsqltype="cf_sql_integer">
						</cfquery>
					<cfelse>
						<cfquery name="qInsertEmptyReturnAddress" datasource="#variables.dsn#">
							insert into LoadStopEmptyReturnAddress
								(address, LoadStopID, dateAdded, dateModified)
							values
								(
									<cfqueryparam value="#EVALUATE('arguments.frmstruct.emptyReturnAddress#stpID#')#" cfsqltype="cf_sql_varchar">,
									<cfqueryparam value="#lastInsertedStopId#" cfsqltype="cf_sql_varchar">,
									<cfqueryparam value="#now()#" cfsqltype="cf_sql_date">,
									<cfqueryparam value="#now()#" cfsqltype="cf_sql_date">
								)
						</cfquery>
					</cfif>

				</cfif>
				<!--- IMPORT Load Stop Ends Here --->
				<!--- EXPORT Load Stop Starts Here ---->
				<cfif structKeyExists(arguments.frmstruct,"exportDateDispatched#stpID#")>
					<cfquery name="qLoadStopIntermodalExportExists" datasource="#variables.dsn#">
						SELECT LoadStopID FROM LoadStopIntermodalExport
						WHERE LoadStopID = <cfqueryparam value="#lastInsertedStopId#" cfsqltype="cf_sql_varchar">
						AND StopNo = <cfqueryparam value="#stpID#" cfsqltype="cf_sql_integer">
					</cfquery>
					<cfif qLoadStopIntermodalExportExists.recordcount>
						<cfquery name="qUpdateLoadStopIntermodalExport" datasource="#variables.dsn#">
							update LoadStopIntermodalExport
							set dateDispatched = <cfqueryparam value="#EVALUATE('arguments.frmstruct.exportDateDispatched#stpID#')#" cfsqltype="cf_sql_date">,
								DateMtAvailableForPickup = <cfqueryparam value="#EVALUATE('arguments.frmstruct.exportDateMtAvailableForPickup#stpID#')#" cfsqltype="cf_sql_date">,
								steamShipLine = <cfqueryparam value="#EVALUATE('arguments.frmstruct.exportsteamShipLine#stpID#')#" cfsqltype="cf_sql_varchar">,
								DemurrageFreeTimeExpirationDate = <cfqueryparam value="#EVALUATE('arguments.frmstruct.exportDemurrageFreeTimeExpirationDate#stpID#')#" cfsqltype="cf_sql_date">,
								vesselName = <cfqueryparam value="#EVALUATE('arguments.frmstruct.exportvesselName#stpID#')#" cfsqltype="cf_sql_varchar">,
								PerDiemFreeTimeExpirationDate = <cfqueryparam value="#EVALUATE('arguments.frmstruct.exportPerDiemFreeTimeExpirationDate#stpID#')#" cfsqltype="cf_sql_date">,
								Voyage = <cfqueryparam value="#EVALUATE('arguments.frmstruct.exportVoyage#stpID#')#" cfsqltype="cf_sql_varchar">,
								EmptyPickupDate = <cfqueryparam value="#EVALUATE('arguments.frmstruct.exportEmptyPickupDate#stpID#')#" cfsqltype="cf_sql_date">,
								seal = <cfqueryparam value="#EVALUATE('arguments.frmstruct.exportseal#stpID#')#" cfsqltype="cf_sql_varchar">,
								Booking = <cfqueryparam value="#EVALUATE('arguments.frmstruct.exportBooking#stpID#')#" cfsqltype="cf_sql_varchar">,
								ScheduledLoadingDate = <cfqueryparam value="#EVALUATE('arguments.frmstruct.exportScheduledLoadingDate#stpID#')#" cfsqltype="cf_sql_date">,
								ScheduledLoadingTime = <cfqueryparam value="#EVALUATE('arguments.frmstruct.exportScheduledLoadingTime#stpID#')#" cfsqltype="cf_sql_varchar">,
								VesselCutoffDate = <cfqueryparam value="#EVALUATE('arguments.frmstruct.exportVesselCutoffDate#stpID#')#" cfsqltype="cf_sql_date">,
								LoadingDate = <cfqueryparam value="#EVALUATE('arguments.frmstruct.exportLoadingDate#stpID#')#" cfsqltype="cf_sql_date">,
								VesselLoadingWindow = <cfqueryparam value="#EVALUATE('arguments.frmstruct.exportVesselLoadingWindow#stpID#')#" cfsqltype="cf_sql_varchar">,
								LoadingDelayDetectionStartDate = <cfqueryparam value="#EVALUATE('arguments.frmstruct.exportLoadingDelayDetectionStartDate#stpID#')#" cfsqltype="cf_sql_date">,
								LoadingDelayDetectionStartTime = <cfqueryparam value="#EVALUATE('arguments.frmstruct.exportLoadingDelayDetectionStartTime#stpID#')#" cfsqltype="cf_sql_varchar">,
								RequestedLoadingDate = <cfqueryparam value="#EVALUATE('arguments.frmstruct.exportRequestedLoadingDate#stpID#')#" cfsqltype="cf_sql_date">,
								RequestedLoadingTime = <cfqueryparam value="#EVALUATE('arguments.frmstruct.exportRequestedLoadingTime#stpID#')#" cfsqltype="cf_sql_varchar">,
								LoadingDelayDetectionEndDate = <cfqueryparam value="#EVALUATE('arguments.frmstruct.exportLoadingDelayDetectionEndDate#stpID#')#" cfsqltype="cf_sql_date">,
								LoadingDelayDetectionEndTime = <cfqueryparam value="#EVALUATE('arguments.frmstruct.exportLoadingDelayDetectionEndTime#stpID#')#" cfsqltype="cf_sql_varchar">,
								ETS = <cfqueryparam value="#EVALUATE('arguments.frmstruct.exportETS#stpID#')#" cfsqltype="cf_sql_date">,
								ReturnDate = <cfqueryparam value="#EVALUATE('arguments.frmstruct.exportReturnDate#stpID#')#" cfsqltype="cf_sql_date">,
								emptyPickupAddress = <cfqueryparam value="#EVALUATE('arguments.frmstruct.exportEmptyPickupAddress#stpID#')#" cfsqltype="cf_sql_varchar">,
								loadingAddress = <cfqueryparam value="#EVALUATE('arguments.frmstruct.exportLoadingAddress#stpID#')#" cfsqltype="cf_sql_varchar">,
								returnAddress = <cfqueryparam value="#EVALUATE('arguments.frmstruct.exportReturnAddress#stpID#')#" cfsqltype="cf_sql_varchar">
							WHERE LoadStopID = <cfqueryparam value="#lastInsertedStopId#" cfsqltype="cf_sql_varchar"> AND
								StopNo = <cfqueryparam value="#stpID#" cfsqltype="cf_sql_integer">
						</cfquery>
					<cfelse>
						<cfquery name="qUpdateLoadStopIntermodalExport" datasource="#variables.dsn#">
							insert into LoadStopIntermodalExport
								( LoadStopID,
									StopNo,
									dateDispatched,
									DateMtAvailableForPickup,
									steamShipLine,
									DemurrageFreeTimeExpirationDate,
									vesselName,
									PerDiemFreeTimeExpirationDate,
									Voyage,
									EmptyPickupDate,
									seal,
									Booking,
									ScheduledLoadingDate,
									ScheduledLoadingTime,
									VesselCutoffDate,
									LoadingDate,
									VesselLoadingWindow,
									LoadingDelayDetectionStartDate,
									LoadingDelayDetectionStartTime,
									RequestedLoadingDate,
									RequestedLoadingTime,
									LoadingDelayDetectionEndDate,
									LoadingDelayDetectionEndTime,
									ETS,
									ReturnDate,
									emptyPickupAddress,
									loadingAddress,
									returnAddress)
							values (
									<cfqueryparam value="#lastInsertedStopId#" cfsqltype="cf_sql_varchar">,
									<cfqueryparam value="#stpID#" cfsqltype="cf_sql_integer">,
									<cfqueryparam value="#EVALUATE('arguments.frmstruct.exportDateDispatched#stpID#')#" cfsqltype="cf_sql_date">,
									<cfqueryparam value="#EVALUATE('arguments.frmstruct.exportDateMtAvailableForPickup#stpID#')#" cfsqltype="cf_sql_date">,
									<cfqueryparam value="#EVALUATE('arguments.frmstruct.exportsteamShipLine#stpID#')#" cfsqltype="cf_sql_varchar">,
									<cfqueryparam value="#EVALUATE('arguments.frmstruct.exportDemurrageFreeTimeExpirationDate#stpID#')#" cfsqltype="cf_sql_date">,
									<cfqueryparam value="#EVALUATE('arguments.frmstruct.exportvesselName#stpID#')#" cfsqltype="cf_sql_varchar">,
									<cfqueryparam value="#EVALUATE('arguments.frmstruct.exportPerDiemFreeTimeExpirationDate#stpID#')#" cfsqltype="cf_sql_date">,
									<cfqueryparam value="#EVALUATE('arguments.frmstruct.exportVoyage#stpID#')#" cfsqltype="cf_sql_varchar">,
									<cfqueryparam value="#EVALUATE('arguments.frmstruct.exportEmptyPickupDate#stpID#')#" cfsqltype="cf_sql_date" null="#yesNoFormat(NOT len(EVALUATE('arguments.frmstruct.exportEmptyPickupDate#stpID#')))#">,
									<cfqueryparam value="#EVALUATE('arguments.frmstruct.exportseal#stpID#')#" cfsqltype="cf_sql_varchar">,
									<cfqueryparam value="#EVALUATE('arguments.frmstruct.exportBooking#stpID#')#" cfsqltype="cf_sql_varchar">,
									<cfqueryparam value="#EVALUATE('arguments.frmstruct.exportScheduledLoadingDate#stpID#')#" cfsqltype="cf_sql_date">,
									<cfqueryparam value="#EVALUATE('arguments.frmstruct.exportScheduledLoadingTime#stpID#')#" cfsqltype="cf_sql_varchar">,
									<cfqueryparam value="#EVALUATE('arguments.frmstruct.exportVesselCutoffDate#stpID#')#" cfsqltype="cf_sql_date">,
									<cfqueryparam value="#EVALUATE('arguments.frmstruct.exportLoadingDate#stpID#')#" cfsqltype="cf_sql_date">,
									<cfqueryparam value="#EVALUATE('arguments.frmstruct.exportVesselLoadingWindow#stpID#')#" cfsqltype="cf_sql_varchar">,
									<cfqueryparam value="#EVALUATE('arguments.frmstruct.exportLoadingDelayDetectionStartDate#stpID#')#" cfsqltype="cf_sql_date">,
									<cfqueryparam value="#EVALUATE('arguments.frmstruct.exportLoadingDelayDetectionStartTime#stpID#')#" cfsqltype="cf_sql_varchar">,
									<cfqueryparam value="#EVALUATE('arguments.frmstruct.exportRequestedLoadingDate#stpID#')#" cfsqltype="cf_sql_date">,
									<cfqueryparam value="#EVALUATE('arguments.frmstruct.exportRequestedLoadingTime#stpID#')#" cfsqltype="cf_sql_varchar">,
									<cfqueryparam value="#EVALUATE('arguments.frmstruct.exportLoadingDelayDetectionEndDate#stpID#')#" cfsqltype="cf_sql_date">,
									<cfqueryparam value="#EVALUATE('arguments.frmstruct.exportLoadingDelayDetectionEndTime#stpID#')#" cfsqltype="cf_sql_varchar">,
									<cfqueryparam value="#EVALUATE('arguments.frmstruct.exportETS#stpID#')#" cfsqltype="cf_sql_date">,
									<cfqueryparam value="#EVALUATE('arguments.frmstruct.exportReturnDate#stpID#')#" cfsqltype="cf_sql_date">,
									<cfqueryparam value="#EVALUATE('arguments.frmstruct.exportEmptyPickupAddress#stpID#')#" cfsqltype="cf_sql_varchar">,
									<cfqueryparam value="#EVALUATE('arguments.frmstruct.exportLoadingAddress#stpID#')#" cfsqltype="cf_sql_varchar">,
									<cfqueryparam value="#EVALUATE('arguments.frmstruct.exportReturnAddress#stpID#')#" cfsqltype="cf_sql_varchar">)
						</cfquery>
					</cfif>
					<cfinvoke component="#variables.objLoadgatewayUpdate#" method="getLoadStopAddress" tablename="LoadStopEmptyPickupAddress" address="#EVALUATE('arguments.frmstruct.exportEmptyPickUpAddress#stpID#')#" returnvariable="qLoadStopEmptyPickupAddressExists" />
					<cfif qLoadStopEmptyPickupAddressExists.recordcount>
						<cfquery name="qUpdateEmptyPickupAddress" datasource="#variables.dsn#">
							update LoadStopEmptyPickupAddress
							set address = <cfqueryparam value="#EVALUATE('arguments.frmstruct.exportEmptyPickUpAddress#stpID#')#" cfsqltype="cf_sql_varchar">,
								LoadStopID = <cfqueryparam value="#lastInsertedStopId#" cfsqltype="cf_sql_varchar">,
								dateModified = <cfqueryparam value="#now()#" cfsqltype="cf_sql_date">
							where ID = <cfqueryparam value="#qLoadStopEmptyPickupAddressExists.ID#" cfsqltype="cf_sql_integer">
						</cfquery>
					<cfelse>
						<cfquery name="qInsertEmptyPickupAddress" datasource="#variables.dsn#">
							insert into LoadStopEmptyPickupAddress
								(address, LoadStopID, dateAdded, dateModified)
							values
								(
									<cfqueryparam value="#EVALUATE('arguments.frmstruct.exportEmptyPickUpAddress#stpID#')#" cfsqltype="cf_sql_varchar">,
									<cfqueryparam value="#lastInsertedStopId#" cfsqltype="cf_sql_varchar">,
									<cfqueryparam value="#now()#" cfsqltype="cf_sql_date">,
									<cfqueryparam value="#now()#" cfsqltype="cf_sql_date">
								)
						</cfquery>
					</cfif>
					<cfinvoke component="#variables.objLoadgatewayUpdate#" method="getLoadStopAddress" tablename="LoadStopLoadingAddress" address="#EVALUATE('arguments.frmstruct.exportLoadingAddress#stpID#')#" returnvariable="qLoadStopLoadingAddressExists" />
					<cfif qLoadStopLoadingAddressExists.recordcount>
						<cfquery name="qUpdateLoadingAddress" datasource="#variables.dsn#">
							update LoadStopLoadingAddress
							set address = <cfqueryparam value="#EVALUATE('arguments.frmstruct.exportLoadingAddress#stpID#')#" cfsqltype="cf_sql_varchar">,
								LoadStopID = <cfqueryparam value="#lastInsertedStopId#" cfsqltype="cf_sql_varchar">,
								dateModified = <cfqueryparam value="#now()#" cfsqltype="cf_sql_date">
							where ID = <cfqueryparam value="#qLoadStopLoadingAddressExists.ID#" cfsqltype="cf_sql_integer">
						</cfquery>
					<cfelse>
						<cfquery name="qInsertLoadingAddress" datasource="#variables.dsn#">
							insert into LoadStopLoadingAddress
								(address, LoadStopID, dateAdded, dateModified)
							values(<cfqueryparam value="#EVALUATE('arguments.frmstruct.exportLoadingAddress#stpID#')#" cfsqltype="cf_sql_varchar">,
									<cfqueryparam value="#lastInsertedStopId#" cfsqltype="cf_sql_varchar">,
									<cfqueryparam value="#now()#" cfsqltype="cf_sql_date">,
									<cfqueryparam value="#now()#" cfsqltype="cf_sql_date">)
						</cfquery>
					</cfif>
					<cfinvoke component="#variables.objLoadgatewayUpdate#" method="getLoadStopAddress" tablename="LoadStopReturnAddress" address="#EVALUATE('arguments.frmstruct.exportReturnAddress#stpID#')#" returnvariable="qLoadStopReturnAddressExists" />
					<cfif qLoadStopReturnAddressExists.recordcount>
						<cfquery name="qUpdateReturnAddress" datasource="#variables.dsn#">
							update
								LoadStopReturnAddress
							set
								address = <cfqueryparam value="#EVALUATE('arguments.frmstruct.exportReturnAddress#stpID#')#" cfsqltype="cf_sql_varchar">,
								LoadStopID = <cfqueryparam value="#lastInsertedStopId#" cfsqltype="cf_sql_varchar">,
								dateModified = <cfqueryparam value="#now()#" cfsqltype="cf_sql_date">
							where ID = <cfqueryparam value="#qLoadStopReturnAddressExists.ID#" cfsqltype="cf_sql_integer">
						</cfquery>
					<cfelse>
						<cfquery name="qInsertReturnAddress" datasource="#variables.dsn#">
							insert into LoadStopReturnAddress
								(address, LoadStopID, dateAdded, dateModified)
							values
								(
									<cfqueryparam value="#EVALUATE('arguments.frmstruct.exportReturnAddress#stpID#')#" cfsqltype="cf_sql_varchar">,
									<cfqueryparam value="#lastInsertedStopId#" cfsqltype="cf_sql_varchar">,
									<cfqueryparam value="#now()#" cfsqltype="cf_sql_date">,
									<cfqueryparam value="#now()#" cfsqltype="cf_sql_date">
								)
						</cfquery>
					</cfif>
				</cfif>
				<!--- Insert Load Items---->
				<cfset var totalResultstops=val(evaluate("arguments.frmstruct.totalResult#stpID#"))>
				<cfset var commoditityAlreadyCountStops=val(evaluate("arguments.frmstruct.commoditityAlreadyCount#stpID#"))>
				<cfif val(totalResultstops) gt val(commoditityAlreadyCountStops) and  val(commoditityAlreadyCountStops) neq 1>
					<cfloop from="1" to="#val(commoditityAlreadyCountStops)#" index="num">
						 <cfset qty=VAL(evaluate("arguments.frmstruct.qty#stpID#_#num#"))>
						 <cfset unit=evaluate("arguments.frmstruct.unit#stpID#_#num#")>
						 <cfset description=evaluate("arguments.frmstruct.description#stpID#_#num#")>
						 <cfif isdefined("arguments.frmstruct.weight#stpID#_#num#")>
							<cfset weight=VAL(evaluate("arguments.frmstruct.weight#stpID#_#num#"))>
						<cfelse>
							<cfset weight=0>
						</cfif>
						 <cfset class=evaluate("arguments.frmstruct.class#stpID#_#num#")>
						 <cfset CustomerRate=evaluate("arguments.frmstruct.CustomerRate#stpID#_#num#")>
						 <cfset CustomerRate = replace( CustomerRate,"$","","ALL") >
						 <cfset CarrierRate=evaluate("arguments.frmstruct.CarrierRate#stpID#_#num#")>
						 <cfset CarrierRate = replace( CarrierRate,"$","","ALL") >
						 <cfset custCharges =evaluate("arguments.frmstruct.custCharges#stpID#_#num#")>
						 <cfset custCharges = replace( custCharges,"$","","ALL") >
						 <cfset carrCharges=evaluate("arguments.frmstruct.carrCharges#stpID#_#num#")>
						 <cfset carrCharges = replace( carrCharges,"$","","ALL") >
						 <cfset CarrRateOfCustTotal =evaluate("arguments.frmstruct.CarrierPer#stpID#_#num#")>
						 <cfset CarrRateOfCustTotal = replace( CarrRateOfCustTotal,"%","","ALL") >
						 <cfif not IsNumeric(CarrRateOfCustTotal)>
							<cfset CarrRateOfCustTotal = 0>
						</cfif>
						 <cfif isdefined('arguments.frmstruct.isFee#stpID#_#num#')>
						 	<cfset isFee=true>
						 <cfelse>
						 	<cfset isFee=false>
						 </cfif>
						<!--- Load Logging--->
							<cfinvoke method="LoadLogRegister" type="USP_UpdateLoadItem" instance=1 whereList="#lastInsertedStopId#,#num#">
						<!--- Load Logging--->
						 <CFSTOREDPROC PROCEDURE="USP_UpdateLoadItem" DATASOURCE="#variables.dsn#">
							<CFPROCPARAM VALUE="#lastInsertedStopId#" cfsqltype="CF_SQL_VARCHAR">
							<CFPROCPARAM VALUE="#num#" cfsqltype="CF_SQL_VARCHAR">
							<CFPROCPARAM VALUE="#val(qty)#" cfsqltype="CF_SQL_float">
							<CFPROCPARAM VALUE="#unit#" cfsqltype="CF_SQL_VarCHAR">
							<CFPROCPARAM VALUE="#description#" cfsqltype="CF_SQL_NVARCHAR">
							<CFPROCPARAM VALUE="#weight#" cfsqltype="CF_SQL_float">
							<CFPROCPARAM VALUE="#class#" cfsqltype="CF_SQL_VARCHAR">
							<CFPROCPARAM VALUE="#Val(CustomerRate)#" cfsqltype="cf_sql_money">
							<CFPROCPARAM VALUE="#Val(CarrierRate)#" cfsqltype="cf_sql_money">
							<CFPROCPARAM VALUE="#val(custCharges)#" cfsqltype="cf_sql_money">
							<CFPROCPARAM VALUE="#val(carrCharges)#" cfsqltype="cf_sql_money">
							<CFPROCPARAM VALUE="#CarrRateOfCustTotal#" cfsqltype="cf_sql_decimal">
							<CFPROCPARAM VALUE="#isFee#" cfsqltype="CF_SQL_VARCHAR">
							<CFPROCRESULT NAME="qInsertedLoadItem">
						</cfstoredproc>
						<!--- Load Logging--->
							<cfinvoke method="LoadLogRegister" type="USP_UpdateLoadItem" instance=2 whereList="#lastInsertedStopId#,#num#,#stpID#">
						<!--- Load Logging--->
					</cfloop>
					<cfset var newCommoditityAlreadyCount1=val(evaluate("arguments.frmstruct.commoditityAlreadyCount#stpID#"))+1>
					<cfloop from="#val(newCommoditityAlreadyCount1)#" to="#val(totalResultstops)#" index="num">
					     <cfset qty=VAL(evaluate("arguments.frmstruct.qty#stpID#_#num#"))>
						 <cfset unit=evaluate("arguments.frmstruct.unit#stpID#_#num#")>
						 <cfset description=evaluate("arguments.frmstruct.description#stpID#_#num#")>
						 <cfif isdefined("arguments.frmstruct.weight#stpID#_#num#")>
							<cfset weight=VAL(evaluate("arguments.frmstruct.weight#stpID#_#num#"))>
						<cfelse>
							<cfset weight=0>
						</cfif>
						 <cfset class=evaluate("arguments.frmstruct.class#stpID#_#num#")>
						 <cfset CustomerRate=evaluate("arguments.frmstruct.CustomerRate#stpID#_#num#")>
						 <cfset CustomerRate = replace( CustomerRate,"$","","ALL") >
						 <cfset CarrierRate=evaluate("arguments.frmstruct.CarrierRate#stpID#_#num#")>
						 <cfset CarrierRate = replace( CarrierRate,"$","","ALL") >
						 <cfset custCharges=evaluate("arguments.frmstruct.custCharges#stpID#_#num#")>
						 <cfset custCharges = replace( custCharges,"$","","ALL") >
						 <cfset carrCharges=evaluate("arguments.frmstruct.carrCharges#stpID#_#num#")>
						 <cfset carrCharges = replace( carrCharges,"$","","ALL") >
						 <cfset CarrRateOfCustTotal=evaluate("arguments.frmstruct.CarrierPer#stpID#_#num#")>
						 <cfset CarrRateOfCustTotal = replace( CarrRateOfCustTotal,"%","","ALL") >
						 <cfif not IsNumeric(CarrRateOfCustTotal)><cfset CarrRateOfCustTotal = 0></cfif>
						 <cfif isdefined('arguments.frmstruct.isFee#stpID#_#num#')><cfset isFee=true><cfelse><cfset isFee=false></cfif>
						 <cfif not len(trim(CustomerRate))><cfset CustomerRate=0.00></cfif>
						 <cfif not len(trim(CarrierRate))><cfset CarrierRate=0.00></cfif>
						<CFSTOREDPROC PROCEDURE="USP_InsertLoadItem" DATASOURCE="#variables.dsn#">
							<CFPROCPARAM VALUE="#lastInsertedStopId#" cfsqltype="CF_SQL_VARCHAR">
						 	<CFPROCPARAM VALUE="#num#" cfsqltype="CF_SQL_VARCHAR">
						 	<CFPROCPARAM VALUE="#val(qty)#" cfsqltype="CF_SQL_float">
						 	<CFPROCPARAM VALUE="#unit#" cfsqltype="CF_SQL_VARCHAR">
						 	<CFPROCPARAM VALUE="#description#" cfsqltype="CF_SQL_NVARCHAR">
						 	<CFPROCPARAM VALUE="#weight#" cfsqltype="CF_SQL_float">
						 	<CFPROCPARAM VALUE="#class#" cfsqltype="CF_SQL_VARCHAR">
							<CFPROCPARAM VALUE="#Val(CustomerRate)#" cfsqltype="cf_sql_money">
							<CFPROCPARAM VALUE="#Val(CarrierRate)#" cfsqltype="cf_sql_money">
							<CFPROCPARAM VALUE="#val(custCharges)#" cfsqltype="cf_sql_money">
							<CFPROCPARAM VALUE="#val(carrCharges)#" cfsqltype="cf_sql_money">
							<CFPROCPARAM VALUE="#CarrRateOfCustTotal#" cfsqltype="cf_sql_decimal">
						 	<CFPROCPARAM VALUE="#isFee#" cfsqltype="CF_SQL_VARCHAR">
						 	<CFPROCRESULT NAME="qInsertedLoadItem">
						</cfstoredproc>
						<!--- Load Logging--->
						<cfset StructInsert(this.loadLogData, "New Load Item-" & num , {
									FieldLabel = "New Load Item. Number: " & num
								}, true)>
						<!--- Load Logging--->
					</cfloop>
				<cfelse>
					<cfloop from="1" to="#val(evaluate("arguments.frmstruct.totalResult#stpID#"))#" index="num">
						<cfset qty=evaluate("arguments.frmstruct.qty#stpID#_#num#")>
						<cfset unit=evaluate("arguments.frmstruct.unit#stpID#_#num#")>
						<cfset description=evaluate("arguments.frmstruct.description#stpID#_#num#")>
						 <cfif isdefined("arguments.frmstruct.weight#stpID#_#num#")>
							<cfset weight=VAL(evaluate("arguments.frmstruct.weight#stpID#_#num#"))>
						<cfelse>
							<cfset weight=0>
						</cfif>
						<cfset class=evaluate("arguments.frmstruct.class#stpID#_#num#")>
						<cfset CustomerRate=evaluate("arguments.frmstruct.CustomerRate#stpID#_#num#")>
						<cfset CustomerRate = replace( CustomerRate,"$","","ALL") >
						<cfset CarrierRate=evaluate("arguments.frmstruct.CarrierRate#stpID#_#num#")>
						<cfset CarrierRate = replace( CarrierRate,"$","","ALL") >
						<cfset custCharges=evaluate("arguments.frmstruct.custCharges#stpID#_#num#")>
						<cfset custCharges = replace( custCharges,"$","","ALL") >
						<cfset carrCharges=evaluate("arguments.frmstruct.carrCharges#stpID#_#num#")>
						<cfset carrCharges = replace( carrCharges,"$","","ALL") >
						<cfset CarrRateOfCustTotal =evaluate("arguments.frmstruct.CarrierPer#stpID#_#num#")>
						<cfset CarrRateOfCustTotal = replace( CarrRateOfCustTotal,"%","","ALL") >
						<cfif not IsNumeric(CarrRateOfCustTotal)>
							<cfset CarrRateOfCustTotal = 0>
						</cfif>
						<cfif isdefined('arguments.frmstruct.isFee#stpID#_#num#')>
							<cfset isFee=true>
						<cfelse>
							<cfset isFee=false>
						</cfif>
						<cfset local.LoadStopID = evaluate("arguments.frmstruct.nextloadstopid#stpID#")>
						<cfset local.commoditiesExist = true>
						<cfif local.LoadStopID neq "">
							<cfquery name="qIfStopCommoditiesExists" datasource="#variables.dsn#">
								select ls.loadid,ls.loadstopid,lsc.SrNo from loadstops ls
								left join LoadStopCommodities lsc on ls.loadstopid = lsc.loadstopid
								where ls.loadid = <cfqueryparam value="#frmstruct.editID#" cfsqltype="cf_sql_char">
								and ls.loadstopid = <cfqueryparam value="#local.LoadStopID#" cfsqltype="cf_sql_char">
								and lsc.SrNo = <cfqueryparam value="#num#" cfsqltype="cf_sql_bigint">
							</cfquery>
							<cfif qIfStopCommoditiesExists.RecordCount EQ 0>
								<cfset local.commoditiesExist = false>
							</cfif>
						<cfelse>
							<CFSTOREDPROC PROCEDURE="USP_InsertLoadItem" DATASOURCE="#variables.dsn#">
								<CFPROCPARAM VALUE="#lastInsertedStopId#" cfsqltype="CF_SQL_VARCHAR">
								<CFPROCPARAM VALUE="#num#" cfsqltype="cf_sql_bigint">
								<CFPROCPARAM VALUE="#val(qty)#" cfsqltype="cf_sql_decimal">
								<CFPROCPARAM VALUE="#unit#" cfsqltype="CF_SQL_VARCHAR">
								<CFPROCPARAM VALUE="#description#" cfsqltype="CF_SQL_NVARCHAR">
								<CFPROCPARAM VALUE="#weight#" cfsqltype="CF_SQL_VARCHAR">
								<CFPROCPARAM VALUE="#class#" cfsqltype="CF_SQL_VARCHAR">
								<CFPROCPARAM VALUE="#Val(CustomerRate)#" cfsqltype="cf_sql_money">
								<CFPROCPARAM VALUE="#Val(CarrierRate)#" cfsqltype="cf_sql_money">
								<CFPROCPARAM VALUE="#val(custCharges)#" cfsqltype="cf_sql_money">
								<CFPROCPARAM VALUE="#val(carrCharges)#" cfsqltype="cf_sql_money">
								<CFPROCPARAM VALUE="#CarrRateOfCustTotal#" cfsqltype="cf_sql_decimal">
								<CFPROCPARAM VALUE="#isFee#" cfsqltype="CF_SQL_VARCHAR">
								<CFPROCRESULT NAME="qInsertedLoadItem">
							</cfstoredproc>
							<!--- Load Logging--->
							<cfset StructInsert(this.loadLogData, "New Load Item-" & num , {
										FieldLabel = "New Load Item. Number: " & num
									}, true)>
							<!--- Load Logging--->
						</cfif>
						<cfif NOT local.commoditiesExist>
							 <CFSTOREDPROC PROCEDURE="USP_InsertLoadItem" DATASOURCE="#variables.dsn#">
								<CFPROCPARAM VALUE="#lastInsertedStopId#" cfsqltype="CF_SQL_VARCHAR">
								<CFPROCPARAM VALUE="#num#" cfsqltype="cf_sql_bigint">
								<CFPROCPARAM VALUE="#val(qty)#" cfsqltype="cf_sql_decimal">
								<CFPROCPARAM VALUE="#unit#" cfsqltype="CF_SQL_VARCHAR">
								<CFPROCPARAM VALUE="#description#" cfsqltype="CF_SQL_NVARCHAR">
								<CFPROCPARAM VALUE="#weight#" cfsqltype="CF_SQL_VARCHAR">
								<CFPROCPARAM VALUE="#class#" cfsqltype="CF_SQL_VARCHAR">
								<CFPROCPARAM VALUE="#Val(CustomerRate)#" cfsqltype="cf_sql_money">
								<CFPROCPARAM VALUE="#Val(CarrierRate)#" cfsqltype="cf_sql_money">
								<CFPROCPARAM VALUE="#val(custCharges)#" cfsqltype="cf_sql_money">
								<CFPROCPARAM VALUE="#val(carrCharges)#" cfsqltype="cf_sql_money">
								<CFPROCPARAM VALUE="#CarrRateOfCustTotal#" cfsqltype="cf_sql_decimal">
								<CFPROCPARAM VALUE="#isFee#" cfsqltype="CF_SQL_VARCHAR">
								<CFPROCRESULT NAME="qInsertedLoadItem">
							</cfstoredproc>
							<!--- Load Logging--->
							<cfset StructInsert(this.loadLogData, "New Load Item-" & num , {
										FieldLabel = "New Load Item. Number: " & num
									}, true)>
							<!--- Load Logging--->
						<cfelse>
							<!--- Load Logging--->
								<cfinvoke method="LoadLogRegister" type="USP_UpdateLoadItem" instance=1 whereList="#lastInsertedStopId#,#num#">
							<!--- Load Logging--->
							<CFSTOREDPROC PROCEDURE="USP_UpdateLoadItem" DATASOURCE="#variables.dsn#">
								<CFPROCPARAM VALUE="#lastInsertedStopId#" cfsqltype="CF_SQL_VARCHAR">
								<CFPROCPARAM VALUE="#num#" cfsqltype="CF_SQL_VARCHAR">
								<CFPROCPARAM VALUE="#val(qty)#" cfsqltype="CF_SQL_float">
								<CFPROCPARAM VALUE="#unit#" cfsqltype="CF_SQL_VarCHAR">
								<CFPROCPARAM VALUE="#description#" cfsqltype="CF_SQL_NVARCHAR">
								<CFPROCPARAM VALUE="#weight#" cfsqltype="CF_SQL_float">
								<CFPROCPARAM VALUE="#class#" cfsqltype="CF_SQL_VARCHAR">
								<CFPROCPARAM VALUE="#Val(CustomerRate)#" cfsqltype="cf_sql_money">
								<CFPROCPARAM VALUE="#Val(CarrierRate)#" cfsqltype="cf_sql_money">
								<CFPROCPARAM VALUE="#val(custCharges)#" cfsqltype="cf_sql_money">
								<CFPROCPARAM VALUE="#val(carrCharges)#" cfsqltype="cf_sql_money">
								<CFPROCPARAM VALUE="#CarrRateOfCustTotal#" cfsqltype="cf_sql_decimal">
								<CFPROCPARAM VALUE="#isFee#" cfsqltype="CF_SQL_VARCHAR">
								<CFPROCRESULT NAME="qInsertedLoadItem">
							</cfstoredproc>
							<!--- Load Logging--->
								<cfinvoke method="LoadLogRegister" type="USP_UpdateLoadItem" instance=2 whereList="#lastInsertedStopId#,#num#,#stpID#">
							<!--- Load Logging--->
						</cfif>
					</cfloop>
				</cfif>
			</cfloop>
		</cfif>
	<!--- Web service calls begins from here --->
	<cfset Msg_postev='1'><cfset Msg='1'><cfset ITS_msg = '1'><cfset msg2 = '1'>
	<cfset variables.promilesRes=1>
	<!-----------pep CALL---->
	<cfif  structKeyExists(arguments.frmstruct,"integratewithPEP") and  #arguments.frmstruct.integratewithPEP# eq 1 and structKeyExists(arguments.frmstruct,"posttoloadboard")>
		<cfset p_action='U' />
		<cfif arguments.frmstruct.loadStatus eq "c126b878-9db5-4411-be4d-61e93fab8c95">
			<cfset p_action='D' />
		</cfif>
		<cfif NOT StructKeyExists(arguments.frmstruct,"postCarrierRatetoloadboard")>
			<cfset IncludeCarierRate = 0>
		<cfelse>
			<cfset IncludeCarierRate = 1 >
		</cfif>
		<cfinvoke method="Posteverywhere" impref="#arguments.frmstruct.LoadNumber#" PEPcustomerKey="#arguments.frmstruct.PEPcustomerKey#" PEPsecretKey="#arguments.frmstruct.PEPsecretKey#" POSTACTION="#p_action#"  CARRIERRATE = "#arguments.frmstruct.CARRIERRATE#"    IncludeCarierRate="#IncludeCarierRate#"    returnvariable="request.postevrywhere" />
		<cfset Msg_postev=request.postevrywhere/>
		<cfset Msg=#request.postevrywhere#>
	<cfelseif  structKeyExists(arguments.frmstruct,"integratewithPEP") and  #arguments.frmstruct.integratewithPEP# eq 1 and NOT structKeyExists(arguments.frmstruct,"posttoloadboard") and structKeyExists(arguments.frmstruct,"ISPOST") and arguments.frmstruct.ISPOST EQ 1>
		<cfset p_action='D' />
		<cfif NOT StructKeyExists(arguments.frmstruct,"postCarrierRatetoloadboard")>
			<cfset IncludeCarierRate = 0>
		<cfelse>
			<cfset IncludeCarierRate = 1 >
		</cfif>
		<cfinvoke method="Posteverywhere" impref="#arguments.frmstruct.LoadNumber#" PEPcustomerKey="#arguments.frmstruct.PEPcustomerKey#" PEPsecretKey="#arguments.frmstruct.PEPsecretKey#" POSTACTION="#p_action#"  CARRIERRATE = "#arguments.frmstruct.CARRIERRATE#"    IncludeCarierRate="#IncludeCarierRate#"    returnvariable="request.postevrywhere" />
		<cfset Msg_postev=request.postevrywhere/>
		<cfset Msg=#request.postevrywhere#>	
	</cfif>
	<!-----------pep CALL---->
	<!-----transcore 360 webservice Call-------->
	<cfif structKeyExists(arguments.frmstruct,"integratewithTran360") and  arguments.frmstruct.integratewithTran360 EQ 1 AND structKeyExists(arguments.frmstruct,"posttoTranscore")>
			<cfif structKeyExists(arguments.frmstruct,"IsTransCorePst") AND arguments.frmstruct.IsTransCorePst EQ 1>
				<!---<cfset p_action = 'U'>---->
				<cfset p_action='D'>
				<cfinvoke method="Transcore360Webservice" impref="#arguments.frmstruct.loadManualNo#" trans360Usename="#arguments.frmstruct.trans360Usename#" trans360Password="#arguments.frmstruct.trans360Password#" POSTACTION="#p_action#" returnvariable="request.Transcore360Webservice" />
				<cfset p_action = 'A'>
				<cfif NOT StructKeyExists(arguments.frmstruct,"postCarrierRatetoTranscore")>
					<cfset IncludeCarierRate = 0>
				<cfelse>
					<cfset IncludeCarierRate = arguments.frmstruct.postCarrierRatetoTranscore >
				</cfif>
				<cfinvoke method="Transcore360Webservice" impref="#arguments.frmstruct.loadManualNo#" trans360Usename="#arguments.frmstruct.trans360Usename#" trans360Password="#arguments.frmstruct.trans360Password#" POSTACTION="#p_action#"  IncludeCarierRate="#IncludeCarierRate#" CARRIERRATE="#arguments.frmstruct.CARRIERRATE#" returnvariable="request.Transcore360Webservice" />
			<cfelse>
				<cfset p_action = 'A'>
				<cfif NOT StructKeyExists(arguments.frmstruct,"postCarrierRatetoTranscore")>
					<cfset IncludeCarierRate = 0>
				<cfelse>
					<cfset IncludeCarierRate = arguments.frmstruct.postCarrierRatetoTranscore >
				</cfif>
				<cfinvoke method="Transcore360Webservice" impref="#arguments.frmstruct.loadManualNo#" trans360Usename="#arguments.frmstruct.trans360Usename#" trans360Password="#arguments.frmstruct.trans360Password#" POSTACTION="#p_action#"  IncludeCarierRate="#IncludeCarierRate#" CARRIERRATE="#arguments.frmstruct.CARRIERRATE#" returnvariable="request.Transcore360Webservice" />
			</cfif>
			<!--- change by sp --->
			<cfset Msg=#request.Transcore360Webservice#>
			<!--- change by sp --->
		<cfelseif structKeyExists(arguments.frmstruct,"integratewithTran360") and  arguments.frmstruct.integratewithTran360 EQ 1  AND arguments.frmstruct.IsTransCorePst EQ 1 AND NOT structKeyExists(arguments.frmstruct,"posttoTranscore")>
			<cfset p_action='D'>
		<cfinvoke method="Transcore360Webservice" impref="#arguments.frmstruct.loadManualNo#" trans360Usename="#arguments.frmstruct.trans360Usename#" trans360Password="#arguments.frmstruct.trans360Password#" POSTACTION="#p_action#" returnvariable="request.Transcore360Webservice" />
		<cfset Msg=request.Transcore360Webservice>
		</cfif>
		<!--- Validation for Unauthorised users try to update on Transcore --->
		<cfif NOT structKeyExists(arguments.frmstruct,"integratewithTran360") AND structKeyExists(arguments.frmstruct,"posttoTranscore")>
			<cfif not variables.datStatus>
				<cfset msg = "There is a problem in logging to Dat Loadboard">
				<cfquery name="TransFlaginsert" datasource="#variables.dsn#">
					update Loads SET IsTransCorePst=0, Trans_Sucess_Flag=0 WHERE ControlNumber=<cfqueryparam value="#arguments.frmstruct.loadManualNo#" cfsqltype="cf_sql_integer">
				</cfquery>
			</cfif>
		</cfif>
	<!--- BEGIN: ITS Webservice Integration --->
	<!--- add by sp --->
	<cfset variables.loadNumber ="">
	<cfif StructKeyExists(form,"loadManualNo")>
		<cfset variables.loadNumber = form.loadManualNo>
	</cfif>
	<!--- add by sp --->
	<cfif structKeyExists(arguments.frmstruct,"integratewithITS") and  arguments.frmstruct.integratewithITS EQ 1 AND structKeyExists(arguments.frmstruct,"posttoITS")>
		<cfif structKeyExists(arguments.frmstruct,"IsITSPst") AND arguments.frmstruct.IsITSPst EQ 1>
			<cfset p_action = 'U'>
		<cfelse>
			<cfset p_action = 'A'>
		</cfif>
		<!--- change by sp --->
		<cfif NOT StructKeyExists(arguments.frmstruct,"postCarrierRatetoITS")>
				<cfset IncludeCarierRate = 0>
			<cfelse>
				<cfset IncludeCarierRate = arguments.frmstruct.postCarrierRatetoITS >
			</cfif>
		<cfset ITS_msg = ITSWebservice(arguments.frmstruct.LoadNumber, p_action, arguments.frmstruct.ITSUsername, arguments.frmstruct.ITSPassword, arguments.frmstruct.ITSIntegrationID,variables.loadNumber,application.dsn,IncludeCarierRate)>
		<!--- change by sp --->
	<cfelseif structKeyExists(arguments.frmstruct,"integratewithITS") and  arguments.frmstruct.integratewithITS EQ 1 AND structKeyExists(arguments.frmstruct,"IsITSPst") AND arguments.frmstruct.IsITSPst EQ 1 AND NOT structKeyExists(arguments.frmstruct,"posttoITS")>
		<cfset p_action = 'D'>
		<cfset ITS_msg = ITSWebservice(arguments.frmstruct.LoadNumber, p_action, arguments.frmstruct.ITSUsername, arguments.frmstruct.ITSPassword, arguments.frmstruct.ITSIntegrationID,variables.loadNumber)>
	</cfif>
	<!--- END: ITS Webservice Integration --->
	<!--- Validation for Unauthorised users try to update on Transcore --->
	<cfif NOT structKeyExists(arguments.frmstruct,"loadBoard123") AND structKeyExists(arguments.frmstruct,"PostTo123LoadBoard")>
		<cfset msg = "There is a problem in logging to 123LoadBoard">
	</cfif>
	<cfset msg3="1">
	<cfif not StructKeyExists(arguments.frmstruct,"notpostingTo123LoadBoard") >
	<!--- START: loadBoard123 --->
	<cfif structKeyExists(form,"PostTo123LoadBoard")>
		<cfset loardBoard123Exists=form.loadBoard123>
		<cfset equipment = form.equipment>
		<cfset today = dateFormat(now(),"yyyymmdd")>
		<cfset pickUpDate= dateFormat(form.shipperPickupDate,"yyyymmdd")>
		<cfset consigneePickupDate= dateFormat(form.consigneePickupDate,"yyyymmdd")>
		<cfif equipment EQ ""><cfset msg2 = "Please select equipment for stop 1 for posting 123Loadboard"></cfif>
		<cfif loardBoard123Exists EQ 0>
			<cfif msg2 neq '1'>
				<cfset msg2 = msg2 &','& "You need to setup your user name and password for 123LoadBoard before you can post loads.">
			<cfelse>
				<cfset msg2 = "You need to setup your user name and password for 123LoadBoard before you can post loads.">
			</cfif>
		</cfif>
		<cfif today GT pickUpDate >
			<cfif msg2 neq '1'>
				<cfset msg2 = msg2 &','& "Please enter pickup date after today for stop 1 for posting 123Loadboard">
			<cfelse>
				<cfset msg2 = "Please enter pickup date after today for stop 1 for posting 123Loadboard">
			</cfif>
		</cfif>
		<cfif today GT consigneePickupDate >
			<cfif msg2 neq '1'>
				<cfset msg2 =msg2 &','&  "Please enter consignee Pickup Date after today for stop 1 for posting 123Loadboard">
			<cfelse>
				<cfset msg2 ="Please enter consignee Pickup Date after today for stop 1 for posting 123Loadboard">
			</cfif>
		</cfif>
		<cfif val(arguments.frmstruct.totalStop) gt 1>
			<cfloop from="2" to="#val(arguments.frmstruct.totalStop)#" index="stpID">
				<cfset equipment = evaluate("form.equipment#stpID#")>
				<cfif equipment EQ ""><cfif msg2 neq '1'><cfset msg2 = msg2 &','& "Please select equipment for stop #stpID# for posting 123Loadboard"><cfelse><cfset msg2 ="Please select equipment for stop #stpID# for posting 123Loadboard"></cfif></cfif>
				<cfset pickUpDate= dateFormat(evaluate("form.shipperPickupDate#stpID#"), "yyyymmdd")>
				<cfif today GT pickUpDate ><cfif msg2 neq '1'><cfset msg2 = msg2 &','& "Please enter pickup date after today for stop #stpID# for posting 123Loadboard"><cfelse><cfset msg2 = "Please enter pickup date after today for stop #stpID# for posting 123Loadboard"></cfif></cfif>
				<cfset consigneePickupDate= dateFormat(evaluate("form.consigneePickupDate#stpID#"), "yyyymmdd")>
				<cfif today GT consigneePickupDate ><cfif msg2 neq '1'><cfset msg2 = msg2 &','& "Please enter consignee Pickup Date date after today for stop #stpID# for posting 123Loadboard"><cfelse><cfset msg2 = "Please enter consignee Pickup Date date after today for stop #stpID# for posting 123Loadboard"></cfif></cfif>
			</cfloop>
		</cfif>
		<cfif  msg2 NEQ '1'>
			<cfquery name="LoadBoard123Flaginsert" datasource="#variables.dsn#">
				update Loads SET postto123loadboard=0 WHERE ControlNumber=<cfqueryparam value="#variables.loadNumber#" cfsqltype="cf_sql_integer">
			</cfquery>
		</cfif>
	</cfif>
	<!---Start 123loardBoard Integration--->
	<cfif msg2 EQ '1'>
		<cfif structKeyExists(arguments.frmstruct,"loadBoard123") and  arguments.frmstruct.loadBoard123 EQ 1 AND structKeyExists(arguments.frmstruct,"PostTo123LoadBoard")>
			<cfif structKeyExists(arguments.frmstruct,"Is123LoadBoardPst") AND arguments.frmstruct.Is123LoadBoardPst EQ 1>
				<cfset p_action = 'U'>
			<cfelse>
				<cfset p_action = 'A'>
			</cfif>
			<!--- change by sp --->
			<cfinvoke component="#variables.objLoadgatewayUpdate#" method="callLoadboardWebservice" p_action="#p_action#" frmstruct="#arguments.frmstruct#" LastLoadId="#LastLoadId#" returnvariable="responseLoadboardWebservice"/>
			<cfset msg3 =responseLoadboardWebservice>
			<!--- change by sp --->
		<cfelseif structKeyExists(arguments.frmstruct,"loadBoard123") and  arguments.frmstruct.loadBoard123 EQ 1 AND structKeyExists(arguments.frmstruct,"Is123LoadBoardPst") AND arguments.frmstruct.Is123LoadBoardPst EQ 1 AND NOT structKeyExists(arguments.frmstruct,"PostTo123LoadBoard")>
			<cfset p_action = 'D'>
			<cfinvoke component="#variables.objLoadgatewayUpdate#" method="callLoadboardWebservice"  p_action="#p_action#" frmstruct="#arguments.frmstruct#" LastLoadId="#LastLoadId#" returnvariable="responseLoadboardWebservice"/>
			<cfset msg3 =responseLoadboardWebservice>
		</cfif>
	</cfif>
	</cfif>
	<cfif structKeyExists(session,"empid") AND getLoadStatusText(arguments.frmstruct.loadStatus) EQ '5. DELIVERED'>
		<cfquery name="getProMileDetails" datasource="#Application.dsn#">
			select proMilesStatus from Employees
			where EmployeeID=<cfqueryparam cfsqltype="cf_sql_varchar" value="#session.empid#">
		</cfquery>
		<cfinvoke method="getSystemSetupOptions" returnvariable="request.qSystemSetupOptions">		
		<cfif request.qSystemSetupOptions.googlemapspcmiler EQ 1 AND getProMileDetails.proMilesStatus>
			<cfset responsePromiles=1>			
			<cfinvoke component="#variables.objPromilesGatewayTest#" method="promilesCalculation" frmstruct="#arguments.frmstruct#" returnvariable="responsePromiles"/>
			<cfset variables.promilesRes=responsePromiles>
		</cfif>
	</cfif>
	<cfif structKeyExists(arguments.frmstruct,"PODSignature")>
		<cfset LoadPODSignature(arguments.frmstruct)>
	</cfif>
	<cfif structKeyExists(arguments.frmstruct,"oldstatus") AND arguments.frmstruct.oldstatus EQ "0.1 EDI">
		<cfset EDI990(arguments.frmstruct)>
	</cfif>	
	<cfset saveCarrierQuoteLocal(arguments.frmstruct)>
	<cfset Msg='#Msg_postev#'&'~~'&'#Msg#' & '~~' & ITS_msg & '~~' & msg2& '~~' & msg3 & '~~' & variables.promilesRes>
	
	<cfreturn Msg>

</cffunction>

<cffunction name="saveCarrierQuoteLocal" access="public" returntype="any">
	<cfargument name="frmstruct" type="struct" required="yes">

	<cfloop from="1" to="#val(arguments.frmstruct.totalStop)#" index="stpID">
		<cfif isDefined('quoteCarrierID#stpID#') AND len(trim(evaluate('quoteCarrierID#stpID#')))>
			<cfinvoke method="saveCarrierQuote" returnvariable="result">
				<cfinvokeargument name="CarrierQuoteID" value="#evaluate('CarrierQuoteID#stpID#')#">
				<cfinvokeargument name="loadID" value="#form.editid#">
				<cfinvokeargument name="StopNo" value="#stpID#">
				<cfinvokeargument name="Amount" value="#replace(evaluate('quoteAmount#stpID#'), '$', '')#">
				<cfinvokeargument name="CarrierID" value="#evaluate('quoteCarrierID#stpID#')#">
				<cfinvokeargument name="EquipmentID" value="#evaluate('quoteEquipment#stpID#')#">
				<cfinvokeargument name="TruckNo" value="#evaluate('quoteTruckNo#stpID#')#">
				<cfinvokeargument name="FuelSurcharge" value="#evaluate('quoteFuelSurcharge#stpID#')#">
				<cfinvokeargument name="TrailerNo" value="#evaluate('quoteTrailerNo#stpID#')#">
				<cfinvokeargument name="ContainerNo" value="#evaluate('quoteContainerNo#stpID#')#">
				<cfinvokeargument name="RefNo" value="#evaluate('quoteRefNo#stpID#')#">
				<cfinvokeargument name="CarrRefNo" value="#evaluate('quoteRefNo#stpID#')#">
				<cfinvokeargument name="Miles" value="#evaluate('quoteMiles#stpID#')#">
				<cfinvokeargument name="dsn" value="#Application.dsn#">
			</cfinvoke>
		</cfif>
	</cfloop>
</cffunction>

<cffunction name="getLoadStatusText" access="public" returntype="any">
	<cfargument name="loadStatus" type="string" required="yes">
	<cfquery name="getLoadStatus" datasource="#Application.dsn#">
		select statustext from LoadStatusTypes
		where StatusTypeID=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.loadStatus#">
	</cfquery>
	<cfreturn getLoadStatus.statustext>
</cffunction>

<cffunction name="EDI990" access="public" returntype="any">
	<cfargument name="frmstruct" type="struct" required="yes">
    <cfset doctype='990'>
	<cfquery name="getLoadStatus" datasource="#Application.dsn#">
			select statustext from LoadStatusTypes
			where StatusTypeID=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.frmstruct.loadStatus#">
		</cfquery>

		<cfif getLoadStatus.statustext NEQ "0.1 EDI">
			<cfif getLoadStatus.statustext EQ "1. ACTIVE">
				<cfset ResActCode = 'A'>
				<cfset description = "Accepted">
			<cfelse>
				<cfset ResActCode = 'D'>
				<cfset description = "Cancelled">
			</cfif>
			<cfquery name="qGetLoadDetails" datasource="#variables.dsn#">
				SELECT EDISCAC,BolNum,LoadNumber,receiverid,LoadID FROM Loads
				where loadid=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.frmstruct.editid#">
			</cfquery>
			<cfif len(trim(qGetLoadDetails.EDISCAC)) AND len(trim(qGetLoadDetails.BolNum))>
				<cfquery name="qInsEDI990" datasource="#Application.dsn#">
					INSERT INTO EDI990(lm_EDISetup_SCAC,lm_Loads_BOL,ReservationActionCode,Processed,CreatedDate,ModifiedDate,receiverID,LoadID) VALUES('#qGetLoadDetails.EDISCAC#','#qGetLoadDetails.BolNum#','#ResActCode#',0,getdate(),getdate(),'#qGetLoadDetails.receiverid#','#qGetLoadDetails.LoadID#')
				</cfquery>
				<cfquery name="qinsEDILog" datasource="#dsn#">
					INSERT INTO EDI204Log (
							[LoadLogID]
				           ,[BOLNumber]
				           ,[Detail]
				           ,[CreatedDate]
				           ,[LoadNumber]
				           ,[DocType]
				           ,[ModifiedDate]
						)
					VALUES(newid()
						,<cfqueryparam value="#qGetLoadDetails.BolNum#" cfsqltype="cf_sql_varchar">
						,<cfqueryparam value="#description#" cfsqltype="cf_sql_varchar">
						,getdate()
						,<cfqueryparam value="#LoadNumber#" cfsqltype="CF_SQL_INTEGER">
						,<cfqueryparam value="#doctype#" cfsqltype="cf_sql_varchar">
						,getdate())
				</cfquery>
			</cfif>
		</cfif>
</cffunction>

<cffunction name="LoadPODSignature" access="public" returntype="any">
	<cfargument name="frmstruct" type="struct" required="yes">
	<cfquery name="updLoadPODSignature" datasource="#Application.dsn#">
		update loads set PODSignature = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.frmstruct.PODSignature#">
		where loadid=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.frmstruct.editid#">
	</cfquery>
</cffunction>

<cffunction name="EDI210" access="public" returntype="any">

	<cfargument name="frmstruct" type="struct" required="yes">
		<cfquery name="getLoadStatus" datasource="#Application.dsn#">
			select statustext from LoadStatusTypes
			where StatusTypeID=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.frmstruct.loadStatus#">
		</cfquery>

		<cfif getLoadStatus.statustext EQ "7. INVOICE">
			<cfset doctype='210'>
			<cfset description = "Invoiced">
			<cfquery name="getLoadDetails" datasource="#Application.dsn#">
				SELECT DISTINCT L.ediInvoiced,L.EDISCAC,L.LoadNumber,L.BOLNum,L.ShipmentMethodOfPayment,L.BillDate AS InvoiceDate,L.TotalCustomerCharges,L.NewDeliveryDate,L.CustomerPONo,L.NewPickupDate 
					,LS.StopNo
					,EDI.lm_LoadStops_StopNo as EDIstopno
					,LS.LoadType,LS.CustName,LS.Address,LS.City,LS.StateCode,LS.PostalCode
					,LSC.Description,LSC.weight,LSC.Qty,LSC.CustRate,LSC.CustCharges,LSC.SrNo
					,(SELECT SUM(LSC1.Weight) FROM LoadStopCommodities LSC1 WHERE LSC1.LoadStopID=LS.LoadStopID) AS TotalStopCommWeight
					,(SELECT SUM(LSC1.Qty) FROM LoadStopCommodities LSC1 WHERE LSC1.LoadStopID=LS.LoadStopID) AS TotalStopCommQty
					,(SELECT SUM(LSC1.Weight) FROM LoadStopCommodities LSC1 WHERE LSC1.LoadStopID IN (SELECT LS1.LoadStopID FROM LoadStops LS1 WHERE LS1.LoadID = L.LoadID)) AS Total_Weight
					,(SELECT SUM(LSC1.CustRate) FROM LoadStopCommodities LSC1 WHERE LSC1.LoadStopID IN (SELECT LS1.LoadStopID FROM LoadStops LS1 WHERE LS1.LoadID = L.LoadID)) AS Total_Charge
					,(SELECT SUM(LSC1.CustCharges) FROM LoadStopCommodities LSC1 WHERE LSC1.LoadStopID IN (SELECT LS1.LoadStopID FROM LoadStops LS1 WHERE LS1.LoadID = L.LoadID)) AS Total_Charge_LineDetails
					,(SELECT SUM(LSC1.Qty) FROM LoadStopCommodities LSC1 WHERE LSC1.LoadStopID IN (SELECT LS1.LoadStopID FROM LoadStops LS1 WHERE LS1.LoadID = L.LoadID)) AS Lading_Quantity
					,L.NewDeliveryTime
					,L.PODSignature
					,L.receiverID
					,LS.IdentityCode as ShipperIdentificationCode
					,EDI.lm_loadstops_contactperson as ShipperName
					,L.CustomerMilesCharges as MilesCharge
					,L.CustFlatRate as CustFlatRate  
					FROM loads L
					LEFT JOIN LoadStops LS ON L.LoadID = LS.LoadID
					INNER JOIN edi204stops EDI on edi.lm_Loads_BOL=L.BolNum and edi.IdentityCode=LS.IdentityCode
					LEFT JOIN LoadStopCommodities LSC ON LS.LoadStopID = LSC.LoadStopID
				WHERE L.loadid=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.frmstruct.editid#">
				ORDER BY LS.StopNo,LS.LoadType,LSC.SrNo
			</cfquery>

			<cfif len(getLoadDetails.EDISCAC) AND getLoadDetails.ediInvoiced EQ 0>

			<cfset cust_total_charge =  getLoadDetails.MilesCharge + getLoadDetails.CustFlatRate + getLoadDetails.Total_Charge_LineDetails>
			
			<cfif cust_total_charge NEQ getLoadDetails.TotalCustomerCharges>
				
				<cfset Validate_error="Your load has been saved but the Load Status was not updated because the EDI 210 data failed it's integrity check. Please call Load Manager technical support to get this issue resolved.">
					<cfquery name="qryUpdateOldStatus" datasource="#variables.dsn#">
						UPDATE Loads SET StatusTypeID = '#frmstruct.oldstatusval#' WHERE Loadid=<cfqueryparam value="#arguments.frmstruct.editid#" cfsqltype="cf_sql_varchar">
					</cfquery>
				<cfreturn Validate_error>
				
			</cfif>

			<cfquery name="qInsertEDI210" datasource="#Application.dsn#" result="resultInsertEDI210">
					INSERT INTO EDI210 (lm_Loads_LoadNumber,lm_Loads_BOL,Shipment_Method_Of_Payment,lm_Loads_InvoiceDate,lm_Loads_TotalCustomerCharges,lm_LoadStops_NewDeliveryDate,lm_EDISetup_SCAC,Reference_Identification_Qualifier,lm_Loads_CustomerPONo,lm_Loads_NewPickupDate,Total_Weight,Weight_Qualifier,Total_Charge,Lading_Quantity,Weight_Unit_Code,lm_LoadStops_NewDeliveryTime,PODSignature,receiverID,ShipperName,ShipperIdentificationCode,LoadID)
					VALUES ('#getLoadDetails.LoadNumber#','#getLoadDetails.BOLNum#','#getLoadDetails.ShipmentMethodOfPayment#',
						<cfqueryparam cfsqltype="cf_sql_varchar" null="#not len(getLoadDetails.InvoiceDate)#" value="#DateFormat(getLoadDetails.InvoiceDate,'yyyymmdd')#">,<cfqueryparam cfsqltype="cf_sql_integer" null="#not len(getLoadDetails.TotalCustomerCharges)#" value="#getLoadDetails.TotalCustomerCharges*100#">,<cfqueryparam cfsqltype="cf_sql_varchar" null="#not len(getLoadDetails.NewDeliveryDate)#" value="#DateFormat(getLoadDetails.NewDeliveryDate,'yyyymmdd')#">,'#getLoadDetails.EDISCAC#','PO','#getLoadDetails.CustomerPONo#','#DateFormat(getLoadDetails.NewPickupDate,'yyyymmdd')#','#getLoadDetails.Total_Weight#','G',<cfqueryparam cfsqltype="cf_sql_integer" null="#not len(getLoadDetails.TotalCustomerCharges)#" value="#getLoadDetails.TotalCustomerCharges*100#">,'#getLoadDetails.Lading_Quantity#','L','#getLoadDetails.NewDeliveryTime#','#getLoadDetails.PODSignature#','#getLoadDetails.receiverID#','#getLoadDetails.ShipperName#','#getLoadDetails.ShipperIdentificationCode#','#arguments.frmstruct.editid#')
				</cfquery>
				<cfquery name="qinsEDILog" datasource="#dsn#">
					INSERT INTO EDI204Log (
							[LoadLogID]
				           ,[BOLNumber]
				           ,[Detail]
				           ,[CreatedDate]
				           ,[LoadNumber]
				           ,[DocType]
				           ,[ModifiedDate]
						)
					VALUES(newid()
						,<cfqueryparam value="#getLoadDetails.BolNum#" cfsqltype="cf_sql_varchar">
						,<cfqueryparam value="#description#" cfsqltype="cf_sql_varchar">
						,getdate()
						,<cfqueryparam value="#getLoadDetails.LoadNumber#" cfsqltype="CF_SQL_INTEGER">
						,<cfqueryparam value="#doctype#" cfsqltype="cf_sql_varchar">
						,getdate())
				</cfquery>
				<cfset local.StopNo = 1>
				<cfset local.prevStopNo = "">
				<cfset local.prevTotalStopCommWeight = 0>
				<cfset local.prevTotalStopCommQty = 0>
				<cfloop query="getLoadDetails">

					<cfif getLoadDetails.LoadType EQ 1>
						<cfset LoadTypeReason = 'LD'>
						<cfset LoadTypeCode = 'SH'>
						<cfset LoadTypeQualifier = 92>
					<cfelse>
						<cfset LoadTypeReason = 'UL'>
						<cfset LoadTypeCode = 'CN'>
						<cfset LoadTypeQualifier = 93>
					</cfif>

					<cfquery name="qCheckEDI210StopExist" datasource="#Application.dsn#">
						SELECT COUNT(ID) AS StopCount FROM EDI210Stops WHERE lm_loads_BOL = '#getLoadDetails.BOLNum#' AND lm_LoadStops_StopNo ='#local.StopNo#'
					</cfquery>
					<cfif local.prevStopNo EQ getLoadDetails.StopNo AND getLoadDetails.LoadType EQ 2>
						<cfset local.TotalStopCommWeight = local.prevTotalStopCommWeight>
						<cfset local.TotalStopCommQty = local.prevTotalStopCommQty>
					<cfelse>
						<cfset local.TotalStopCommWeight = getLoadDetails.TotalStopCommWeight>
						<cfset local.TotalStopCommQty = getLoadDetails.TotalStopCommQty>
					</cfif>
					<cfif NOT qCheckEDI210StopExist.StopCount>
						<cfquery name="qInsertEDI210Stops" datasource="#Application.dsn#">
							INSERT INTO EDI210Stops(lm_loads_BOL,lm_LoadStops_StopNo,[lm_LoadStops_Type-Reason],lm_LoadStopCommodities_Weight,Weight_Unit_Code,lm_LoadStopCommodities_qty,[lm_LoadStops_Type-Code],lm_LoadStops_StopName,[lm_LoadStops_Type-Qualifier],lm_LoadStops_Address,lm_LoadStops_City,lm_LoadStops_StateCode,lm_LoadStops_PostalCode,Country_Code,receiverID)
							VALUES('#getLoadDetails.BOLNum#','#getLoadDetails.EDIstopno#','#LoadTypeReason#','#local.TotalStopCommWeight#','G','#local.TotalStopCommQty#','#LoadTypeCode#','#CustName#','#LoadTypeQualifier#','#getLoadDetails.Address#','#getLoadDetails.City#','#getLoadDetails.StateCode#','#getLoadDetails.PostalCode#','US','#getLoadDetails.receiverID#')
						</cfquery>
						<cfset local.prevStopNo = getLoadDetails.StopNo>
						<cfset local.prevTotalStopCommWeight = getLoadDetails.TotalStopCommWeight>
						<cfset local.prevTotalStopCommQty = getLoadDetails.TotalStopCommQty>
						<cfset local.StopNo++>
					</cfif>

					<cfif getLoadDetails.LoadType EQ 1>			
												
						<cfquery name="qInsertEDI210LineDetails" datasource="#Application.dsn#">
							INSERT INTO EDI210LineDetails(Assigned_Number,Lading_Line_Item_Number,lm_LoadStopsCommodities_Description,Rated_as_Quantity,Rated_as_Qualifier,lm_LoadStopCommodities_weight,Weight_Qualifier,[lm_LoadStopsCommodities_Quantity-1],[Packing_Form_Code-1],[Weight_Unit_Code-1],[Line_Quantity-1]
							,[lm_LoadStopsCommodities_Quantity-2],[Packing_Form_Code-2],[Weight_Unit_Code-2],[Line_Quantity-2],[Packing_Form_Code-3],lm_LoadStopCommodities_CustRate,Rate_Qualifier,lm_LoadStopCommodities_CustCharges,lm_loads_BOL,receiverID,CreatedDate,ModifiedDate)
							VALUES('#getLoadDetails.SrNo#','#getLoadDetails.SrNo#','#getLoadDetails.Description#','#getLoadDetails.Qty#','LC','#getLoadDetails.weight#','G','#getLoadDetails.Qty#','PLT','L','#getLoadDetails.Qty#','#getLoadDetails.Qty#','PLT','L','#getLoadDetails.Qty#','PLT','#trim(getLoadDetails.CustRate)#','FR',<cfqueryparam cfsqltype="cf_sql_integer" null="#not len(getLoadDetails.CustCharges)#" value="#getLoadDetails.CustCharges*100#">,'#getLoadDetails.BOLNum#','#getLoadDetails.receiverID#',getDate(),getdate())
						</cfquery>
					</cfif>
				</cfloop>

				<cfif getLoadDetails.RecordCount>

				<cfif getLoadDetails.CustFlatRate GT 0>
					<cfquery name="qgetEDI210LineDetails" datasource="#Application.dsn#">
						select max(Assigned_Number)+1 as assign_no from EDI210LineDetails where lm_Loads_BOL='#getLoadDetails.BOLNum#'
					</cfquery>
					<cfset assign_no = qgetEDI210LineDetails.assign_no>
						<cfquery name="qInsertEDI210LineDetails" datasource="#Application.dsn#">
							INSERT INTO EDI210LineDetails
							(Assigned_Number
							,Lading_Line_Item_Number
							,lm_LoadStopsCommodities_Description
							,Rated_as_Quantity
							,Rated_as_Qualifier
							,lm_LoadStopCommodities_weight
							,Weight_Qualifier
							,[lm_LoadStopsCommodities_Quantity-1]
							,[Packing_Form_Code-1]
							,[Weight_Unit_Code-1]
							,[Line_Quantity-1]
							,[lm_LoadStopsCommodities_Quantity-2]
							,[Packing_Form_Code-2]
							,[Weight_Unit_Code-2]
							,[Line_Quantity-2]
							,[Packing_Form_Code-3]
							,lm_LoadStopCommodities_CustRate
							,Rate_Qualifier
							,lm_LoadStopCommodities_CustCharges,lm_loads_BOL,receiverID,CreatedDate,ModifiedDate)
							VALUES('#assign_no#','#assign_no#','Flat Rate','1','LC','0','G','1','PLT','L','1','1','PLT','L','1','PLT','#trim(getLoadDetails.CustFlatRate)#','FR',<cfqueryparam cfsqltype="cf_sql_integer" null="#not len(getLoadDetails.CustFlatRate)#" value="#getLoadDetails.CustFlatRate*100#">,'#getLoadDetails.BOLNum#','#getLoadDetails.receiverID#',getDate(),getdate())
						</cfquery>
					</cfif>

					<cfif getLoadDetails.MilesCharge GT 0>
					<cfquery name="qgetEDI210LineDetails" datasource="#Application.dsn#">
						select max(Assigned_Number)+1 as assign_no from EDI210LineDetails where lm_Loads_BOL='#getLoadDetails.BOLNum#'
					</cfquery>
					<cfset assign_no = qgetEDI210LineDetails.assign_no>
						<cfquery name="qInsertEDI210LineDetails" datasource="#Application.dsn#">
							INSERT INTO EDI210LineDetails
							(Assigned_Number
							,Lading_Line_Item_Number
							,lm_LoadStopsCommodities_Description
							,Rated_as_Quantity
							,Rated_as_Qualifier
							,lm_LoadStopCommodities_weight
							,Weight_Qualifier
							,[lm_LoadStopsCommodities_Quantity-1]
							,[Packing_Form_Code-1]
							,[Weight_Unit_Code-1]
							,[Line_Quantity-1]
							,[lm_LoadStopsCommodities_Quantity-2]
							,[Packing_Form_Code-2]
							,[Weight_Unit_Code-2]
							,[Line_Quantity-2]
							,[Packing_Form_Code-3]
							,lm_LoadStopCommodities_CustRate
							,Rate_Qualifier
							,lm_LoadStopCommodities_CustCharges,lm_loads_BOL,receiverID,CreatedDate,ModifiedDate)
							VALUES('#assign_no#','#assign_no#','Miles Charge','1','LC','0','G','1','PLT','L','1','1','PLT','L','1','PLT','#trim(getLoadDetails.MilesCharge)#','FR',<cfqueryparam cfsqltype="cf_sql_integer" null="#not len(getLoadDetails.MilesCharge)#" value="#getLoadDetails.MilesCharge*100#">,'#getLoadDetails.BOLNum#','#getLoadDetails.receiverID#',getDate(),getdate())
						</cfquery>
					</cfif>
				</cfif>
				<cfquery name="qUpdBitProcessed" datasource="#Application.dsn#">
					UPDATE Loads SET ediInvoiced = 1 WHERE loadid=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.frmstruct.editid#">
				</cfquery>
			</cfif>
		</cfif>
</cffunction>


<cffunction name="LoadLogRegister" access="private" returntype="any">
	<cfargument name="type" type="string" required="yes">
	<cfargument name="instance" type="numeric" required="yes"><!--- 1 = before, 2 = after --->
	<cfargument name="whereList" type="string" required="yes">
		
	<cfif NOT request.qGetSystemSetupOptions.IsLoadLogEnabled EQ 1>
		<cfreturn>
	</cfif>
	<cfset arguments.whereList = ListToArray(arguments.whereList)>
	
	<!---<cfset var selectQuery = {
		"RunUSP_UpdateLoad" = "Select LoadNumber,SalesRepID,DispatcherID,CustomerPONo,BOLNum,StatusTypeID,PayerID,IsPost,IsTransCorePst,PostTo123LoadBoard,TotalCarrierCharges,TotalCustomerCharges,LastModifiedDate,ModifiedBy,UpdatedByIP,NewNotes,NewDispatchNotes,carrierNotes,pricingNotes,CustFlatRate,CarrFlatRate,CarrierID,CarrOfficeID,EquipmentID,DriverName,DriverCell,TruckNo,TrailorNo,newbookedwithload,NewPickupNo ,NewPickupDate ,NewPickupTime ,NewPickupTimeIn ,NewPickupTimeOut ,NewDeliveryNo ,NewDeliveryDate ,NewDeliveryTime ,NewDeliveryDateTimeIn ,NewDeliveryDateTimeOut ,CustomerRatePerMile ,CarrierRatePerMile,CustomerTotalMiles ,CarrierTotalMiles,officeid,orderDate,BillDate,totalProfit,ARExported,APExported,customerMilesCharges,carrierMilesCharges,customerCommoditiesCharges,carrierCommoditiesCharges,Address,City,StateCode,PostalCode,ContactPerson,Phone,Fax,CellNo,CustName,IsPartial,readyDate,arriveDate,isExcused,bookedBy,invoiceNumber,weight,CarrierInvoiceNumber,postCarrierRatetoloadboard,postCarrierRatetoTranscore,postCarrierRateto123LoadBoard,ShipperState,ShipperCity,ConsigneeState,ConsigneeCity,SalesAgent,EquipmentName,CarrierName,LoadDriverName from Loads where loadid=<cfqueryparam cfsqltype='cf_sql_varchar' value='#arguments.whereList[1]#'>"
		
	}>
	<cfif NOT structKeyExists(selectQuery, "#arguments.type#")>
		<cfdump var="Wrong Type given." abort>
	</cfif>
	--->	
	
	
	
	<cfset var col = "">
	<cfset excludeArray=["LASTMODIFIEDDATE","CREATEDDATETIME", "NEWDISPATCHNOTES", "SALESREPID", "NEWCARRIERID", "CARRIERID", "CUSTOMERID", "EQUIPMENTNAME", "EQUIPMENTID" ]> 
	<!---SALESREPID is added cos we already have agent name --->


	<cfif arguments.instance EQ 1>
		<cfquery name="this.SelectForLoggingBefore" datasource="#variables.dsn#">
			<cfif arguments.type EQ "RunUSP_UpdateLoad">
				Select LoadNumber,SalesRepID,DispatcherID,CustomerPONo,BOLNum,StatusTypeID,PayerID,IsPost,IsTransCorePst,PostTo123LoadBoard,TotalCarrierCharges,TotalCustomerCharges,LastModifiedDate,ModifiedBy,UpdatedByIP,NewNotes,NewDispatchNotes,carrierNotes,pricingNotes,CustFlatRate,CarrFlatRate,CarrierID,CarrOfficeID,EquipmentID,DriverName,DriverCell,TruckNo,TrailorNo,newbookedwithload,NewPickupNo ,NewPickupDate ,NewPickupTime ,NewPickupTimeIn ,NewPickupTimeOut ,NewDeliveryNo ,NewDeliveryDate ,NewDeliveryTime ,NewDeliveryDateTimeIn ,NewDeliveryDateTimeOut ,CustomerRatePerMile ,CarrierRatePerMile,CustomerTotalMiles ,CarrierTotalMiles,officeid,orderDate,BillDate,totalProfit,ARExported,APExported,customerMilesCharges,carrierMilesCharges,customerCommoditiesCharges,carrierCommoditiesCharges,Address,City,StateCode,PostalCode,ContactPerson,Phone,Fax,CellNo,CustName,IsPartial,readyDate,arriveDate,isExcused,bookedBy,invoiceNumber,weight,CarrierInvoiceNumber,postCarrierRatetoloadboard,postCarrierRatetoTranscore,postCarrierRateto123LoadBoard,ShipperState,ShipperCity,ConsigneeState,ConsigneeCity,SalesAgent,EquipmentName,CarrierName,LoadDriverName from Loads where loadid=<cfqueryparam cfsqltype='cf_sql_varchar' value='#arguments.whereList[1]#'>
				
				<cfset this.loadLogData = structNew()><!--- CF uses the same CFC instance for every request. Hence this line resets the variable--->
			<cfelseif arguments.type EQ "USP_UpdateLoadStop">
				Select ReleaseNo,Blind,StopDate,StopTime,TimeIn,TimeOut,Instructions,Directions,CustomerID,CreatedBy,CreatedDateTime,ModifiedBy,LastModifiedDate,isoriginpickup,IsFinalDelivery,newBookedwith,NewEquipmentID,NewDriverName,NewDriverName2,NewDriverCell,NewTruckNo,NewTrailorNo,RefNo,Miles,NewCarrierID,NewOfficeID,Address,City,StateCode,PostalCode,ContactPerson,Phone,Fax,EmailID,CustName,userDef1,userDef2,userDef3,userDef4,userDef5,userDef6,StopNo,stopdateDifference,NewDriverCell2 from LoadStops where loadid=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.whereList[1]#"> AND StopNo = #arguments.whereList[2]# AND LoadStops.LoadType = #arguments.whereList[3]#
			<cfelseif arguments.type EQ "USP_UpdateLoadItem">	
				Select Qty,UnitID,Description,Weight,ClassID,CustRate,CarrRate,CustCharges,CarrCharges,fee,CarrRateOfCustTotal from [LoadStopCommodities] where LoadStopID=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.whereList[1]#"> AND [SrNo] = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.whereList[2]#">
			</cfif>
		</cfquery>
		<!---<cfdump var="#this.SelectForLoggingBefore#" >
		<cfdump var="#this.loadLogData#">--->
	<cfelse>
		<cfquery name="this.SelectForLoggingAfter" datasource="#variables.dsn#">
			<cfif arguments.type EQ "RunUSP_UpdateLoad">
				Select LoadNumber,SalesRepID,DispatcherID,CustomerPONo,BOLNum,StatusTypeID,PayerID,IsPost,IsTransCorePst,PostTo123LoadBoard,TotalCarrierCharges,TotalCustomerCharges,LastModifiedDate,ModifiedBy,UpdatedByIP,NewNotes,NewDispatchNotes,carrierNotes,pricingNotes,CustFlatRate,CarrFlatRate,CarrierID,CarrOfficeID,EquipmentID,DriverName,DriverCell,TruckNo,TrailorNo,newbookedwithload,NewPickupNo ,NewPickupDate ,NewPickupTime ,NewPickupTimeIn ,NewPickupTimeOut ,NewDeliveryNo ,NewDeliveryDate ,NewDeliveryTime ,NewDeliveryDateTimeIn ,NewDeliveryDateTimeOut ,CustomerRatePerMile ,CarrierRatePerMile,CustomerTotalMiles ,CarrierTotalMiles,officeid,orderDate,BillDate,totalProfit,ARExported,APExported,customerMilesCharges,carrierMilesCharges,customerCommoditiesCharges,carrierCommoditiesCharges,Address,City,StateCode,PostalCode,ContactPerson,Phone,Fax,CellNo,CustName,IsPartial,readyDate,arriveDate,isExcused,bookedBy,invoiceNumber,weight,CarrierInvoiceNumber,postCarrierRatetoloadboard,postCarrierRatetoTranscore,postCarrierRateto123LoadBoard,ShipperState,ShipperCity,ConsigneeState,ConsigneeCity,SalesAgent,EquipmentName,CarrierName,LoadDriverName from Loads where loadid=<cfqueryparam cfsqltype='cf_sql_varchar' value='#arguments.whereList[1]#'>
			<cfelseif arguments.type EQ "USP_UpdateLoadStop">
				Select ReleaseNo,Blind,StopDate,StopTime,TimeIn,TimeOut,Instructions,Directions,CustomerID,CreatedBy,CreatedDateTime,ModifiedBy,LastModifiedDate,isoriginpickup,IsFinalDelivery,newBookedwith,NewEquipmentID,NewDriverName,NewDriverName2,NewDriverCell,NewTruckNo,NewTrailorNo,RefNo,Miles,NewCarrierID,NewOfficeID,Address,City,StateCode,PostalCode,ContactPerson,Phone,Fax,EmailID,CustName,userDef1,userDef2,userDef3,userDef4,userDef5,userDef6,StopNo,stopdateDifference,NewDriverCell2 from LoadStops where loadid=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.whereList[1]#"> AND StopNo = #arguments.whereList[2]# AND LoadStops.LoadType = #arguments.whereList[3]#
			<cfelseif arguments.type EQ "USP_UpdateLoadItem">	
				Select Qty,UnitID,Description,Weight,ClassID,CustRate,CarrRate,CustCharges,CarrCharges,fee,CarrRateOfCustTotal from [LoadStopCommodities] where LoadStopID=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.whereList[1]#"> AND [SrNo] = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.whereList[2]#">
			</cfif>
		</cfquery>
<!---<cfif arguments.type EQ "USP_UpdateLoadItem">
	<cfdump var="#arguments.whereList[1]#-#arguments.whereList[2]#" abort>				
</cfif>--->
		<cfif this.SelectForLoggingBefore.recordCount AND this.SelectForLoggingAfter.recordCount>
			<cfloop list="#this.SelectForLoggingBefore.columnList#" index="col">
				<cfif this.SelectForLoggingBefore[col][1] NEQ this.SelectForLoggingAfter[col][1] AND NOT ArrayContains(excludeArray,col)>
					<cfif arguments.type EQ "USP_UpdateLoadStop">
						<cfset var colWithStop = col & (arguments.whereList[2] + 1)>				
					<cfelseif arguments.type EQ "USP_UpdateLoadItem">
						<cfset var colWithStop = col & arguments.whereList[3] & "_" & (arguments.whereList[2])>				
					<cfelse>
						<cfset var colWithStop = col>				
					</cfif>
					<cfset StructInsert(this.loadLogData, arguments.type & "_" & colWithStop, {
								FieldLabel = colWithStop,
								OldValue = this.SelectForLoggingBefore[col][1],
								NewValue = this.SelectForLoggingAfter[col][1]
							}, true)>
				</cfif>
			</cfloop>
		</cfif>			
		<!---<cfdump var="#this.SelectForLoggingAfter#" >
		<cfdump var="#this.loadLogData#">--->
	</cfif>
	<!---<cfdump var="#this.SelectForLoggingBefore#" abort >--->
</cffunction>

<cffunction name="getSearchedLoadLogs" access="public" output="false" returntype="query">
	<cfargument name="searchText" required="no" type="any">
    <cfargument name="pageNo" required="no" type="any">
    <cfargument name="sortorder" required="no" type="any">
    <cfargument name="sortby" required="no" type="any">

	<!---<cfdump var="#arguments#" abort>--->
	<CFSTOREDPROC PROCEDURE="USP_SearchLoadLogs" datasource="#Application.dsn#">
		<cfif isdefined('arguments.searchText') and len(arguments.searchText)>
		 	<CFPROCPARAM VALUE="#arguments.searchText#" cfsqltype="cf_sql_nvarchar">
		 <cfelse>
		 	<CFPROCPARAM VALUE="" cfsqltype="cf_sql_nvarchar">
		 </cfif>
		 
		 <cfif isdefined('arguments.pageNo') and len(arguments.pageNo)>
		 	<CFPROCPARAM VALUE="#arguments.pageNo#" cfsqltype="cf_sql_integer">
		 <cfelse>
		 	<CFPROCPARAM VALUE="1" cfsqltype="cf_sql_integer">
		 </cfif>
		
		<CFPROCPARAM VALUE="30" cfsqltype="cf_sql_integer"> <!--- Page Size --->

         <cfif isdefined('arguments.sortorder') and len(arguments.sortorder)>
		 	<CFPROCPARAM VALUE="#arguments.sortorder#" cfsqltype="cf_sql_nvarchar">
		 <cfelse>
		 	<CFPROCPARAM VALUE="DESC" cfsqltype="cf_sql_varchar">
		 </cfif>

         <cfif isdefined('arguments.sortby') and len(arguments.sortby)>
		 	<CFPROCPARAM VALUE="#arguments.sortby#" cfsqltype="cf_sql_nvarchar">
		 <cfelse>
		 	<CFPROCPARAM VALUE="UpdatedTimestamp" cfsqltype="cf_sql_varchar">
		 </cfif>

		 <CFPROCRESULT NAME="QreturnSearch">
	</CFSTOREDPROC>
	<cfreturn QreturnSearch>
</cffunction>

<cffunction name="getSearchedLoadComDataLogs" access="public" output="false" returntype="query">
	<cfargument name="searchText" required="no" type="any">
    <cfargument name="pageNo" required="no" type="any" default="1">
    <cfargument name="sortorder" required="no" type="any" default="DESC">
    <cfargument name="sortby" required="no" type="any" default="FuelPurchaseDate">
 
    <cfquery name="qSearchedLoadComDataLogs" datasource="#Application.dsn#">
    	BEGIN WITH page AS 
    	(SELECT *, ROW_NUMBER() OVER (ORDER BY #arguments.sortby# #arguments.sortorder#) AS Row
    	FROM LoadComDataLogs
	    <cfif structKeyExists(arguments, "searchText") and len(trim(arguments.searchText))>
		    WHERE (LoadID LIKE '%#arguments.searchText#%'
		    OR LoadNumber LIKE '%#arguments.searchText#%'
		    OR Description LIKE '%#arguments.searchText#%'
		    OR FuelCardNo LIKE '%#arguments.searchText#%')
	    </cfif>
	    )
	    SELECT
	      *
	    FROM page
	    WHERE Row BETWEEN (#arguments.pageNo# - 1) * 30 + 1 AND #arguments.pageNo# * 30
	    END
	</cfquery>

	<cfreturn qSearchedLoadComDataLogs>
</cffunction>

<cffunction name="getPendingEDILoads" access="public" output="false" returntype="query">
	<cfargument name="searchText" required="no" type="any">
    <cfargument name="pageNo" required="no" type="any" default="1">
    <cfargument name="sortorder" required="no" type="any" default="ASC">
    <cfargument name="sortby" required="no" type="any" default="lm_EDISetup_SCAC">
 
    <cfquery name="qgetPendingEDILoads" datasource="#Application.dsn#">
    	BEGIN WITH page AS 
    	(SELECT *,isnull((SELECT CustomerName FROM Customers WHERE CustomerID = (SELECT lm_Customers_CustomerCode FROM EDICustomerIDMapping WHERE receiverID=EDI204.receiverID)),'Not Found') as custName, ROW_NUMBER() OVER (ORDER BY lm_Loads_BOL ASC) AS Row
    	FROM EDI204
    	WHERE imported = 0
	    <cfif structKeyExists(arguments, "searchText") and len(trim(arguments.searchText))>
		    AND (lm_Loads_BOL LIKE '%' + '#arguments.searchText#' + '%'
		    OR lm_Customers_CustomerCode LIKE '%' + '#arguments.searchText#' + '%')
	    </cfif>
	    )
	    SELECT
	      *
	    FROM page
	    WHERE Row BETWEEN (#arguments.pageNo# - 1) * 30 + 1 AND #arguments.pageNo# * 30
	    END
	</cfquery>

	<cfreturn qgetPendingEDILoads>
</cffunction>

<cffunction name="getPendingEDI820Loads" access="public" output="false" returntype="query">
	<cfargument name="searchText" required="no" type="any">
    <cfargument name="pageNo" required="no" type="any" default="1">
    <cfargument name="sortorder" required="no" type="any" default="ASC">
    <cfargument name="sortby" required="no" type="any" default="lm_EDISetup_SCAC">
 
    <cfquery name="qgetPendingEDI820Loads" datasource="#Application.dsn#">
    	BEGIN WITH page AS 
    	(SELECT  *, ROW_NUMBER() OVER (ORDER BY Reference_Identification ASC) AS Row FROM EDI820 where edi_processed =0	  
	    
	    <cfif structKeyExists(arguments, "searchText") and len(trim(arguments.searchText))>
		    AND (
		    	reference_identification LIKE '%' + '#arguments.searchText#' + '%'
		    OR
		    	payment_method_code LIKE '%' + '#arguments.searchText#' + '%'
		    OR
		    	monetary_amount LIKE '%' + '#arguments.searchText#' + '%'
		    )
	    </cfif>	    
	    )	
	    SELECT
	      *
	    FROM page
	    WHERE Row BETWEEN (#arguments.pageNo# - 1) * 30 + 1 AND #arguments.pageNo# * 30
	    END
	</cfquery>

	<cfreturn qgetPendingEDI820Loads>
</cffunction>

<cffunction name="getEDI820Data" access="public" output="false" returntype="query">
	<cfargument name="loadID" required="yes" type="any">    
 	
    <cfquery name="qgetEDI820Loads" datasource="#Application.dsn#">
    	SELECT * FROM EDI820 WHERE Reference_Identification IN (SELECT LoadNumber FROM Loads WHERE LoadID=<cfqueryparam value="#arguments.loadID#" cfsqltype="cf_sql_varchar">)
	</cfquery>

	<cfreturn qgetEDI820Loads>
</cffunction>

<cffunction name="getEDILog" access="public" output="false" returntype="query">
	<cfargument name="searchText" required="no" type="any">
    <cfargument name="pageNo" required="no" type="any" default="1">
    <cfargument name="sortorder" required="no" type="any" default="DESC">
    <cfargument name="sortby" required="no" type="any" default="CreatedDate">

    <cfquery name="qgetEDILoads" datasource="#Application.dsn#">
    	BEGIN WITH page AS 
    	(SELECT 
    		 LoadLogID
    		,BOLNumber,Detail
    		,CreatedDate
    		,LG.LoadNumber
    		,DocType
			,CustomerName
			, ROW_NUMBER() OVER (ORDER BY #arguments.sortby# #arguments.sortorder#) AS Row
    	FROM EDI204Log 	LG
		left Join loads L on LG.LoadNumber =L.LoadNumber
		Left Join Customers C on L.PayerID = C.CustomerID
    	<cfif structKeyExists(arguments, "searchText") and len(trim(arguments.searchText))>
		    WHERE (LoadLogID LIKE '%' + '#arguments.searchText#' + '%'
		    OR BOLNumber LIKE '%' + '#arguments.searchText#' + '%'
		    OR DOCTYPE LIKE '%' + '#arguments.searchText#' + '%'
		    OR CreatedDate LIKE '%' + '#arguments.searchText#' + '%'
		    OR Detail LIKE '%' + '#arguments.searchText#' + '%'
		    OR LG.LoadNumber LIKE '%' + '#arguments.searchText#' + '%'
		    OR CustomerName LIKE '%' + '#arguments.searchText#' + '%')
	    </cfif>
	    )
	    SELECT
	      *
	    FROM page
	    WHERE Row BETWEEN (#arguments.pageNo# - 1) * 30 + 1 AND #arguments.pageNo# * 30
	    END
	</cfquery>

	<cfreturn qgetEDILoads>
</cffunction>
<cffunction name="EDI214AppointmentRecord" access="remote" output="yes" returntype="string" returnformat="json">
		<cfargument name="frmstruct" type="struct" required="yes">
	    <cfset doctype='214'>
	    <cfset result = "">

	<cfquery name="getLoadStatus" datasource="#Application.dsn#">
		select statustext from LoadStatusTypes
		where StatusTypeID=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.frmstruct.loadStatus#">
	</cfquery>
		
			<cfset EDI214Status = 1>
			<cfset EDI214Loadtype = ''>
			<cfif getLoadStatus.statustext EQ "4. LOADED">
				<cfset EDI214Status = 'AA'>
				<cfset EDI214Loadtype = 1>
			<cfelseif getLoadStatus.statustext EQ "4.1 ARRIVED">
				<cfset EDI214Status = 'AB'>
				<cfset EDI214Loadtype = 2>
			<cfelseif getLoadStatus.statustext EQ "5. DELIVERED">
				<cfset EDI214Status = 'AB'>	
				<cfset EDI214Loadtype = 2>		
			</cfif>


		<cfquery name="qGetLoadDetails" datasource="#Application.dsn#">
			SELECT distinct EDISCAC,BolNum,LoadNumber,L.receiverid, stopdate  AS Ship_Date,stoptime AS Ship_Time,LS.identitycode,LS.identitycodeq,LS.entityidentitycode
			,(SELECT SUM(Qty) FROM LoadStopCommodities WHERE loadstopid IN (
				SELECT loadstopid FROM loadstops WHERE loadid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.frmstruct.editid#">)) AS Qty
			,(SELECT SUM(Weight) FROM LoadStopCommodities WHERE loadstopid IN (
				SELECT loadstopid FROM loadstops WHERE loadid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.frmstruct.editid#">)) AS Weight			
			,(SELECT ISNULL(MAX(Assigned_Number),0)+1 FROM edi214) AS Assigned_Number
			,CustomerPONo
			,LS.custName
			,LS.StopNo	
			,EDI.lm_loadstops_stopdate as edistopdate
			,EDI.lm_loadstops_stoptime as edistoptime		
			,case when LoadType=1 then (LS.StopNo * 2 +1) else (LS.StopNo * 2 +2) End NewStopNO	
			,Edi.lm_LoadStops_StopNo as EdiNewStopNo		
			,case when LoadType=1 then 'AA' else 'AB' End Shipment_Appointment_Status_Code
			,LoadType
			FROM Loads L
			LEFT JOIN LoadStops LS on L.loadID = LS.loadid
			LEFT JOIN edi204 E on L.loadId = E.LoadID
			LEFT JOIN edi204stops EDI on (edi.lm_Loads_BOL=L.BolNum OR edi.lm_Loads_BOL = l.CustomerPONo) and edi.IdentityCode=LS.IdentityCode
			where L.loadid=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.frmstruct.editid#" > AND EDISCAC is not null
			AND ls.custName is not null
			<cfif Len(EDI214Loadtype)>
			AND LS.LoadType = <cfqueryparam cfsqltype="cf_sql_varchar" value="#EDI214Loadtype#" >
			<cfif isdefined("arguments.frmstruct.shipperConsignee")>
			AND LS.LoadStopID =<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.frmstruct.shipperConsignee#" >
			</cfif>
			</cfif>
		</cfquery>		
		
		<cfif qGetLoadDetails.RecordCount>	

			<cfset Assign_Number = qGetLoadDetails.Assigned_Number>	
			<cfloop query="qGetLoadDetails">

			<cfquery name="qGetEDI214" datasource="#Application.dsn#">
				SELECT 
					Reference_Identification ,[date],[time]
				FROM EDI214 
				WHERE Reference_Identification =<cfqueryparam cfsqltype="cf_sql_varchar" value="#qGetLoadDetails.LoadNumber#">
				AND Shipment_Appointment_Status_Code = <cfqueryparam cfsqltype="cf_sql_varchar" value="#qGetLoadDetails.Shipment_Appointment_Status_Code#">
				AND lm_LoadStops_StopNo = <cfqueryparam cfsqltype="cf_sql_varchar" value="#qGetLoadDetails.EdiNewstopNo#">				
				AND [Date] =<cfqueryparam cfsqltype="cf_sql_varchar" value="#dateformat(qGetLoadDetails.Ship_Date,'yyyymmdd')#">
				AND [Time] =<cfqueryparam cfsqltype="cf_sql_varchar" value="#qGetLoadDetails.Ship_Time#">
			</cfquery>
			
			<cfset local.oldShipperPickupDate = ''>
			<cfset local.shipperPickupDate = ''>
			<cfset local.oldShipperpickupTime = ''>
			<cfset local.shipperpickupTime = ''>
			<cfset local.appointmentFlag =0>

			 
				<cfif qGetLoadDetails.LoadType EQ 1>
					<cfif qGetLoadDetails.stopNo eq 0>
						<cfif Len(frmstruct.shipper)>
							<cfset local.oldShipperPickupDate = '#frmstruct.oldShipperPickupDate#'>
							<cfset local.shipperPickupDate = '#frmstruct.shipperPickupDate#'>
							<cfset local.oldShipperpickupTime = '#frmstruct.oldShipperpickupTime#'>
							<cfset local.shipperpickupTime = '#frmstruct.shipperpickupTime#'>
						</cfif>
					<cfelse>
						<cfif Len(Evaluate('frmstruct.shipper#qGetLoadDetails.stopNo+1#'))>
							<cfset local.oldShipperPickupDate = Evaluate('frmstruct.oldShipperPickupDate#qGetLoadDetails.stopNo+1#')>
							<cfset local.shipperPickupDate =  Evaluate('frmstruct.shipperPickupDate#qGetLoadDetails.stopNo+1#')>
							<cfset local.oldShipperpickupTime = Evaluate('frmstruct.oldShipperpickupTime#qGetLoadDetails.stopNo+1#')>
							<cfset local.shipperpickupTime =  Evaluate('frmstruct.shipperpickupTime#qGetLoadDetails.stopNo+1#')>
						</cfif>
					</cfif>
					
					<cfif (Isdefined("local.oldShipperPickupDate") AND Len(local.oldShipperPickupDate) AND local.oldShipperPickupDate NEQ dateformat(local.shipperPickupDate,'yyyymmdd')) OR (IsDefined("local.shipperpickupTime") AND Len(local.shipperpickupTime) AND local.oldShipperpickupTime NEQ local.shipperpickupTime)>
						<cfset local.appointmentFlag =1>						
					</cfif>
				<cfelseif qGetLoadDetails.LoadType EQ 2>
					<cfif qGetLoadDetails.stopNo eq 0>
						<cfif Len(frmstruct.consignee)>
							<cfset local.oldConsigneePickupDate = '#frmstruct.oldConsigneePickupDate#'>
							<cfset local.ConsigneePickupDate = '#frmstruct.ConsigneePickupDate#'>
							<cfset local.oldConsigneepickupTime = '#frmstruct.oldConsigneepickupTime#'>
							<cfset local.ConsigneepickupTime = '#frmstruct.ConsigneepickupTime#'>
						</cfif>
					<cfelse>
						<cfif Len(Evaluate('frmstruct.consignee#qGetLoadDetails.stopNo+1#'))>
							<cfset local.oldConsigneePickupDate = Evaluate('frmstruct.oldConsigneePickupDate#qGetLoadDetails.stopNo+1#')>
							<cfset local.ConsigneePickupDate =  Evaluate('frmstruct.ConsigneePickupDate#qGetLoadDetails.stopNo+1#')>
							<cfset local.oldConsigneepickupTime = Evaluate('frmstruct.oldConsigneepickupTime#qGetLoadDetails.stopNo+1#')>
							<cfset local.ConsigneepickupTime =  Evaluate('frmstruct.ConsigneepickupTime#qGetLoadDetails.stopNo+1#')>
						</cfif>
					</cfif>
					<cfif (IsDefined("local.oldConsigneePickupDate") AND Len(local.oldConsigneePickupDate) AND local.oldConsigneePickupDate NEQ dateformat(local.ConsigneePickupDate,'yyyymmdd')) OR (Isdefined("local.ConsigneepickupTime") AND Len(local.ConsigneepickupTime) AND (local.oldConsigneepickupTime NEQ local.ConsigneepickupTime))>
						<cfset local.appointmentFlag =1>
							
					</cfif>
				</cfif>
			

			




			<cfif qGetEDI214.RecordCount EQ 0 AND (( (qGetLoadDetails.edistopdate NEQ dateformat(qGetLoadDetails.ship_date,'yyyymmdd') OR qGetLoadDetails.edistoptime NEQ qGetLoadDetails.ship_time) AND  local.appointmentFlag EQ 1) OR ((getLoadStatus.statustext EQ "4. LOADED" OR getLoadStatus.statustext EQ "4.1 ARRIVED" OR getLoadStatus.statustext EQ "5. DELIVERED")	AND  local.appointmentFlag EQ 1))>	
				
				<cfquery name="qInsEDI214" datasource="#Application.dsn#">
					INSERT INTO EDI214(
					 Reference_Identification	
					,lm_Loads_BOL	
					,lm_EDISetup_SCAC	
					,[lm_LoadStops_Type-Code]	
					,lm_LoadStops_StopName	
					,[lm_LoadStops_Type-Qualifier]	
					,Identification_Code	
					,Assigned_Number	
					,Shipment_Status_Code	
					,Shipment_Status	
					,[Date]	
					,[Time]	
					,TIme_Code	
					,Purchase_Order_Number	
					,edi_processed	
					,receiverID
					,Shipment_Appointment_Status_Code
					,lm_LoadStops_StopNo
					,ModifiedDate
					,Shipment_Appointment_Status
					,LoadID
					)
				Values(
					'#qGetLoadDetails.LoadNumber#'
					,'#qGetLoadDetails.BolNum#'
					,'#qGetLoadDetails.EDISCAC#'
					,'#qGetLoadDetails.EntityIdentityCode#'
					,'#qGetLoadDetails.custname#'
					,'#qGetLoadDetails.IdentityCodeQ#'
					,'#qGetLoadDetails.IdentityCode#'
					,'#Assign_Number#'
					,''
					,''
					,'#dateformat(qGetLoadDetails.Ship_Date,"yyyymmdd")#'
					,'#qGetLoadDetails.Ship_Time#'
					,'LT'
					,'#qGetLoadDetails.CustomerPONo#'
					,0
		           	,'#qGetLoadDetails.receiverid#'
		           	,'#qGetLoadDetails.Shipment_Appointment_Status_Code#'
		           	,'#qGetLoadDetails.EdiNewStopNO#'
		           	,getdate()
		           	,'NA'
					,'#arguments.frmstruct.editid#'
					)
			</cfquery>
			<cfset Assign_Number = Assign_Number + 1>
			<cfset LogEdi214(qGetLoadDetails.BolNum, DocType, EDI214Status, qGetLoadDetails.LoadNumber)>
			<cfif qGetLoadDetails.LoadType EQ 1>
				<cfset result = "EDI 214 pickup information has been queued.">
			<cfelse>
				<cfset result = "EDI 214 delivery information has been queued.">
			</cfif>
			
			</cfif>
		</cfloop>
		
		

		
			
		
		
		</cfif>
		
		
		<!--- If shipper/ consignee pickup date/ time changed  --->
		<cfquery name="qGetLoadDetailsAdd" datasource="#Application.dsn#">
			SELECT distinct EDISCAC,BolNum,LoadNumber,L.receiverid, stopdate  AS Ship_Date,stoptime AS Ship_Time,LS.identitycode,LS.identitycodeq,LS.entityidentitycode
			,(SELECT SUM(Qty) FROM LoadStopCommodities WHERE loadstopid IN (
				SELECT loadstopid FROM loadstops WHERE loadid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.frmstruct.editid#">)) AS Qty
			,(SELECT SUM(Weight) FROM LoadStopCommodities WHERE loadstopid IN (
				SELECT loadstopid FROM loadstops WHERE loadid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.frmstruct.editid#">)) AS Weight			
			,(SELECT ISNULL(MAX(Assigned_Number),0)+1 FROM edi214) AS Assigned_Number
			,CustomerPONo
			,LS.custName
			,LS.StopNo	
			,EDI.lm_loadstops_stopdate as edistopdate
			,EDI.lm_loadstops_stoptime as edistoptime		
			,case when LoadType=1 then (LS.StopNo * 2 +1) else (LS.StopNo * 2 +2) End NewStopNO	
			,Edi.lm_LoadStops_StopNo as EdiNewStopNo			
			,case when LoadType=1 then 'AA' else 'AB' End Shipment_Appointment_Status_Code
			,LoadType
			FROM Loads L
			LEFT JOIN LoadStops LS on L.loadID = LS.loadid
			LEFT JOIN edi204 E on L.loadId = E.LoadID
			LEFT JOIN edi204stops EDI on (edi.lm_Loads_BOL=L.BolNum OR edi.lm_Loads_BOL = l.CustomerPONo) and edi.IdentityCode=LS.IdentityCode
			where L.loadid=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.frmstruct.editid#" > AND EDISCAC is not null			
			AND ls.custName is not null
			
		</cfquery>		
		
		<cfif qGetLoadDetailsAdd.RecordCount>
		<cfset Assign_Number = qGetLoadDetailsAdd.Assigned_Number>		
			<cfloop query="qGetLoadDetailsAdd">
					
				    
			<cfquery name="qGetEDI214Add" datasource="#Application.dsn#">
				SELECT 
					Reference_Identification ,[date],[time]
				FROM EDI214 
				WHERE Reference_Identification =<cfqueryparam cfsqltype="cf_sql_varchar" value="#qGetLoadDetailsAdd.LoadNumber#">
				AND Shipment_Appointment_Status_Code = <cfqueryparam cfsqltype="cf_sql_varchar" value="#qGetLoadDetailsAdd.Shipment_Appointment_Status_Code#">
				AND lm_LoadStops_StopNo = <cfqueryparam cfsqltype="cf_sql_varchar" value="#qGetLoadDetailsAdd.EdiNewstopNo#">
				AND [Date] =<cfqueryparam cfsqltype="cf_sql_varchar" value="#dateformat(qGetLoadDetailsAdd.Ship_Date,'yyyymmdd')#">
				AND [Time] =<cfqueryparam cfsqltype="cf_sql_varchar" value="#qGetLoadDetailsAdd.Ship_Time#">
			</cfquery>

			<!--- compare old and new form values --->
			<cfset local.oldShipperPickupDate = ''>
			<cfset local.shipperPickupDate = ''>
			<cfset local.oldShipperpickupTime = ''>
			<cfset local.shipperpickupTime = ''>
			<cfset local.appointmentFlag =0>

			<cfif qGetLoadDetailsAdd.LoadType EQ 1>
					<cfif qGetLoadDetailsAdd.stopNo eq 0>
						<cfif Len(frmstruct.shipper)>
							<cfset local.oldShipperPickupDate = '#frmstruct.oldShipperPickupDate#'>
							<cfset local.shipperPickupDate = '#frmstruct.shipperPickupDate#'>
							<cfset local.oldShipperpickupTime = '#frmstruct.oldShipperpickupTime#'>
							<cfset local.shipperpickupTime = '#frmstruct.shipperpickupTime#'>
						</cfif>
					<cfelse>
						<cfif Len(Evaluate('frmstruct.shipper#qGetLoadDetailsAdd.stopNo+1#'))>
							<cfset local.oldShipperPickupDate = Evaluate('frmstruct.oldShipperPickupDate#qGetLoadDetailsAdd.stopNo+1#')>
							<cfset local.shipperPickupDate =  Evaluate('frmstruct.shipperPickupDate#qGetLoadDetailsAdd.stopNo+1#')>
							<cfset local.oldShipperpickupTime = Evaluate('frmstruct.oldShipperpickupTime#qGetLoadDetailsAdd.stopNo+1#')>
							<cfset local.shipperpickupTime =  Evaluate('frmstruct.shipperpickupTime#qGetLoadDetailsAdd.stopNo+1#')>
						</cfif>
					</cfif>

				<cfif (Len(local.oldShipperPickupDate) AND local.oldShipperPickupDate NEQ dateformat(local.shipperPickupDate,'yyyymmdd')) OR (Len(local.shipperpickupTime) AND local.oldShipperpickupTime NEQ local.shipperpickupTime)>
						<cfset local.appointmentFlag =1>						
					</cfif>
			<cfelse>
				<cfif qGetLoadDetailsAdd.stopNo eq 0>
						<cfif Len(frmstruct.consignee)>
							<cfset local.oldConsigneePickupDate = '#frmstruct.oldConsigneePickupDate#'>
							<cfset local.ConsigneePickupDate = '#frmstruct.ConsigneePickupDate#'>
							<cfset local.oldConsigneepickupTime = '#frmstruct.oldConsigneepickupTime#'>
							<cfset local.ConsigneepickupTime = '#frmstruct.ConsigneepickupTime#'>
						</cfif>
					<cfelse>
						<cfif Len(Evaluate('frmstruct.consignee#qGetLoadDetailsAdd.stopNo+1#'))>
							<cfset local.oldConsigneePickupDate = Evaluate('frmstruct.oldConsigneePickupDate#qGetLoadDetailsAdd.stopNo+1#')>
							<cfset local.ConsigneePickupDate =  Evaluate('frmstruct.ConsigneePickupDate#qGetLoadDetailsAdd.stopNo+1#')>
							<cfset local.oldConsigneepickupTime = Evaluate('frmstruct.oldConsigneepickupTime#qGetLoadDetailsAdd.stopNo+1#')>
							<cfset local.ConsigneepickupTime =  Evaluate('frmstruct.ConsigneepickupTime#qGetLoadDetailsAdd.stopNo+1#')>
						</cfif>
					</cfif>


					<cfif (IsDefined("local.oldConsigneePickupDate") AND Len(local.oldConsigneePickupDate) AND local.oldConsigneePickupDate NEQ dateformat(local.ConsigneePickupDate,'yyyymmdd')) OR (IsDefined("local.ConsigneepickupTime") AND Len(local.ConsigneepickupTime) AND (local.oldConsigneepickupTime NEQ local.ConsigneepickupTime))>
						<cfset local.appointmentFlag =1>
							
					</cfif>
			</cfif>
			<!--- .End compare old and new form values--->






			<cfif qGetEDI214Add.RecordCount EQ 0 AND (( (qGetLoadDetailsAdd.edistopdate NEQ dateformat(qGetLoadDetailsAdd.ship_date,'yyyymmdd') OR qGetLoadDetailsAdd.edistoptime NEQ qGetLoadDetailsAdd.ship_time) AND local.appointmentFlag EQ 1) OR ((getLoadStatus.statustext EQ "4. LOADED" OR getLoadStatus.statustext EQ "4.1 ARRIVED" OR getLoadStatus.statustext EQ "5. DELIVERED") AND local.appointmentFlag EQ 1	))>	
				<cfset EDIError="">
				<cfset EDIDateError="">

				<cfif qGetLoadDetailsAdd.Loadtype EQ 1 AND (NOT Len(qGetLoadDetailsAdd.Ship_Date) OR NOT qGetLoadDetails.Ship_Date GTE now())>
					<cfif NOT Len(qGetLoadDetails.Ship_Date)>
						<cfset EDIDateError = "Pickup Date is not valid.">
					</cfif>
				<cfelseif qGetLoadDetailsAdd.Loadtype EQ 2 AND (NOT Len(qGetLoadDetailsAdd.Ship_Date) OR NOT qGetLoadDetailsAdd.Ship_Date GTE now())>
					<cfif NOT Len(qGetLoadDetailsAdd.Ship_Date)>
						<cfset EDIDateError = "Delivery Date is not valid.">
					</cfif>
				</cfif>	
				<cfif NOT isNumeric(qGetLoadDetailsAdd.Ship_Time) AND qGetLoadDetailsAdd.Loadtype EQ 1>
					<cfset EDIError = "Pickup time is not valid. EDI 214 could not be queued.">
				<cfelseif NOT isNumeric(qGetLoadDetailsAdd.Ship_Time) AND qGetLoadDetailsAdd.Loadtype EQ 2>
					<cfset EDIError = "Delivery time is not valid. EDI 214 could not be queued.">		
				<cfelseif IsNumeric(qGetLoadDetailsAdd.Ship_Time) AND Len(qGetLoadDetailsAdd.Ship_Time) EQ 4 >					
					
						<cfif qGetLoadDetailsAdd.Loadtype EQ 1>
							<cfset local.HourPart =Left(qGetLoadDetailsAdd.Ship_Time,2)>
							<cfset local.MinutePart =Right(qGetLoadDetailsAdd.Ship_Time,2)>
							<cfif local.HourPart GT 23 OR local.MinutePart GT 59>
								<cfset EDIError = "Pickup time is not valid. EDI 214 could not be queued.">
							</cfif>
						<cfelseif qGetLoadDetailsAdd.Loadtype EQ 2>
							<cfset local.HourPart =Left(qGetLoadDetailsAdd.Ship_Time,2)>
							<cfset local.MinutePart =Right(qGetLoadDetailsAdd.Ship_Time,2)>
							<cfif local.HourPart GT 23 OR local.MinutePart GT 59>
								<cfset EDIError = "Delivery time is not valid. EDI 214 could not be queued.">
							</cfif>
						</cfif>
				<cfelseif Len(qGetLoadDetailsAdd.Ship_Time) NEQ 4 AND qGetLoadDetailsAdd.Loadtype EQ 1>
					<cfset EDIError = "Pickup time is not valid. EDI 214 could not be queued.">
				<cfelseif Len(qGetLoadDetailsAdd.Ship_Time) NEQ 4 AND qGetLoadDetailsAdd.Loadtype EQ 2>
					<cfset EDIError = "Delivery time is not valid. EDI 214 could not be queued.">				
				</cfif>
				<cfif Len(EDIDateError) AND Len(EDIError)>
					<cfset EDIError = EDIDateError & EDIError>
				<cfelseif Len(EDIDateError)>
					<cfset EDIError = EDIDateError & " EDI 214 could not be queued.">
				</cfif>
				<cfif NOT Len(EDIError)>				
					
				<cfquery name="qInsEDI214" datasource="#Application.dsn#">
					INSERT INTO EDI214(
					 Reference_Identification	
					,lm_Loads_BOL	
					,lm_EDISetup_SCAC	
					,[lm_LoadStops_Type-Code]	
					,lm_LoadStops_StopName	
					,[lm_LoadStops_Type-Qualifier]	
					,Identification_Code	
					,Assigned_Number	
					,Shipment_Status_Code	
					,Shipment_Status	
					,[Date]	
					,[Time]	
					,TIme_Code	
					,Purchase_Order_Number	
					,edi_processed	
					,receiverID
					,Shipment_Appointment_Status_Code
					,lm_LoadStops_StopNo
					,ModifiedDate
					,Shipment_Appointment_Status
					,LoadID
					)
				Values(
					'#qGetLoadDetailsAdd.LoadNumber#'
					,'#qGetLoadDetailsAdd.BolNum#'
					,'#qGetLoadDetailsAdd.EDISCAC#'
					,'#qGetLoadDetailsAdd.EntityIdentityCode#'
					,'#qGetLoadDetailsAdd.custname#'
					,'#qGetLoadDetailsAdd.IdentityCodeQ#'
					,'#qGetLoadDetailsAdd.IdentityCode#'
					,'#Assign_Number#'
					,''
					,''
					,'#dateformat(qGetLoadDetailsAdd.Ship_Date,"yyyymmdd")#'
					,'#qGetLoadDetailsAdd.Ship_Time#'
					,'LT'
					,'#qGetLoadDetailsAdd.CustomerPONo#'
					,0
		           	,'#qGetLoadDetailsAdd.receiverid#'
		           	,'#qGetLoadDetailsAdd.Shipment_Appointment_Status_Code#'
		           	,'#qGetLoadDetailsAdd.EdiNewStopNO#'
		           	,getdate()
		           	,'NA'
					,'#arguments.frmstruct.editid#'
					)
			</cfquery>
			<cfset Assign_Number = Assign_Number + 1>
			<cfset LogEdi214(qGetLoadDetails.BolNum, DocType, EDI214Status, qGetLoadDetails.LoadNumber)>

			<cfif qGetLoadDetails.LoadType EQ 1>
				<cfset result = "EDI 214 pickup information has been queued.">
			<cfelse>
				<cfset result = "EDI 214 delivery information has been queued.">
			</cfif>
			</cfif>
		</cfif>
			</cfloop>
			
		</cfif>
		<!--- .end --->
		
	
		
		<cfreturn result>
	</cffunction>
	<cffunction name="EDI214Validate" access="remote" output="yes" returntype="string" returnformat="json">
		<cfargument name="frmstruct" type="struct" required="yes">
	    <cfset doctype='214'>
	    <cfset result = "">
		<cfquery name="getLoadStatus" datasource="#Application.dsn#">
			select statustext from LoadStatusTypes
			where StatusTypeID=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.frmstruct.loadStatus#">
		</cfquery>
		<cfif getLoadStatus.statustext EQ "4. LOADED" OR getLoadStatus.statustext EQ "4.1 ARRIVED" OR getLoadStatus.statustext EQ "5. DELIVERED">	
		
			<cfset EDI214Status = 1>
			<cfset EDI214Loadtype = ''>
			<cfif getLoadStatus.statustext EQ "4. LOADED">
				<cfset EDI214Status = 'AA'>
				<cfset EDI214Loadtype = 1>
			<cfelseif getLoadStatus.statustext EQ "4.1 ARRIVED">
				<cfset EDI214Status = 'AB'>
				<cfset EDI214Loadtype = 2>
			<cfelseif getLoadStatus.statustext EQ "5. DELIVERED">
				<cfset EDI214Status = 'AB'>	
				<cfset EDI214Loadtype = 2>		
			</cfif>


		<cfquery name="qGetLoadDetails" datasource="#Application.dsn#">
			SELECT DISTINCT EDISCAC,BolNum,LoadNumber,L.receiverid, stopdate  AS Ship_Date,stoptime AS Ship_Time,LS.identitycode,LS.identitycodeq,LS.entityidentitycode
			,(SELECT SUM(Qty) FROM LoadStopCommodities WHERE loadstopid IN (
				SELECT loadstopid FROM loadstops WHERE loadid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.frmstruct.editid#">)) AS Qty
			,(SELECT SUM(Weight) FROM LoadStopCommodities WHERE loadstopid IN (
				SELECT loadstopid FROM loadstops WHERE loadid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.frmstruct.editid#">)) AS Weight			
			,(SELECT ISNULL(MAX(Assigned_Number),0)+1 FROM edi214) AS Assigned_Number
			,CustomerPONo
			,LS.custName
			,LS.StopNo
			,EDI.lm_LoadStops_StopNo  AS EdiStopNo
			,case when LoadType=1 then (LS.StopNo * 2 +1) else (LS.StopNo * 2 +2) End NewStopNO	
			, Edi.lm_LoadStops_StopNo as EdiNewStopNo	
			,case when LoadType=1 then 'AA' else 'AB' End Shipment_Appointment_Status_Code
			FROM Loads L
			LEFT JOIN LoadStops LS on L.loadID = LS.loadid
			LEFT JOIN edi204 E on L.loadId = E.LoadID
			LEFT JOIN edi204stops EDI on (edi.lm_Loads_BOL=L.BolNum OR edi.lm_Loads_BOL = l.CustomerPONo) and edi.IdentityCode=LS.IdentityCode
			where L.loadid=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.frmstruct.editid#" > AND EDISCAC is not null
			AND ls.custName is not null 
			AND LS.LoadType = <cfqueryparam cfsqltype="cf_sql_varchar" value="#EDI214Loadtype#" >
			<cfif isdefined("arguments.frmstruct.shipperConsignee")>
			AND LS.LoadStopID =<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.frmstruct.shipperConsignee#" >
			</cfif>
		</cfquery>		
		
		<cfif qGetLoadDetails.RecordCount>	
			<cfquery name="qGetEDI214" datasource="#Application.dsn#">
				SELECT 
					Reference_Identification 
				FROM EDI214 
				WHERE Reference_Identification =<cfqueryparam cfsqltype="cf_sql_varchar" value="#qGetLoadDetails.LoadNumber#">
				AND Shipment_Status_Code = <cfqueryparam cfsqltype="cf_sql_varchar" value="#EDI214Status#">
				AND lm_LoadStops_StopNo = <cfqueryparam cfsqltype="cf_sql_varchar" value="#qGetLoadDetails.EDiNewstopNo#">
		    </cfquery>
			<cfif qGetEDI214.RecordCount EQ 0>
			<cfset Assign_Number = qGetLoadDetails.Assigned_Number>
			<cfloop query="qGetLoadDetails">
				<cfset EDIError="">
				<cfset EDIDateError="">

				<cfif EDI214Loadtype EQ 1 AND (NOT Len(qGetLoadDetails.Ship_Date) OR NOT qGetLoadDetails.Ship_Date GTE now())>
					<cfif NOT Len(qGetLoadDetails.Ship_Date)>
						<cfset EDIDateError = "Pickup Date is not valid.">
					</cfif>
				<cfelseif EDI214Loadtype EQ 2 AND (NOT Len(qGetLoadDetails.Ship_Date) OR NOT qGetLoadDetails.Ship_Date GTE now())>
					<cfif NOT Len(qGetLoadDetails.Ship_Date)>
						<cfset EDIDateError = "Delivery Date is not valid.">
					</cfif>
				</cfif>	
				<cfif NOT isNumeric(qGetLoadDetails.Ship_Time) AND EDI214Loadtype EQ 1>
					<cfset EDIError = "Pickup time is not valid. EDI 214 could not be queued.">
				<cfelseif NOT isNumeric(qGetLoadDetails.Ship_Time) AND EDI214Loadtype EQ 2>
					<cfset EDIError = "Delivery time is not valid. EDI 214 could not be queued.">		
				<cfelseif IsNumeric(qGetLoadDetails.Ship_Time) AND Len(qGetLoadDetails.Ship_Time) EQ 4 >					
					
						<cfif EDI214Loadtype EQ 1>
							<cfset local.HourPart =Left(qGetLoadDetails.Ship_Time,2)>
							<cfset local.MinutePart =Right(qGetLoadDetails.Ship_Time,2)>
							<cfif local.HourPart GT 23 OR local.MinutePart GT 59>
								<cfset EDIError = "Pickup time is not valid. EDI 214 could not be queued.">
							</cfif>
						<cfelseif EDI214Loadtype EQ 2>
							<cfset local.HourPart =Left(qGetLoadDetails.Ship_Time,2)>
							<cfset local.MinutePart =Right(qGetLoadDetails.Ship_Time,2)>
							<cfif local.HourPart GT 23 OR local.MinutePart GT 59>
								<cfset EDIError = "Delivery time is not valid. EDI 214 could not be queued.">
							</cfif>
						</cfif>
				<cfelseif Len(qGetLoadDetails.Ship_Time) NEQ 4 AND EDI214Loadtype EQ 1>
					<cfset EDIError = "Pickup time is not valid. EDI 214 could not be queued.">
				<cfelseif Len(qGetLoadDetails.Ship_Time) NEQ 4 AND EDI214Loadtype EQ 2>
					<cfset EDIError = "Delivery time is not valid. EDI 214 could not be queued.">				
				</cfif>
				<cfif Len(EDIDateError) AND Len(EDIError)>
					<cfset EDIError = EDIDateError & EDIError>
				<cfelseif Len(EDIDateError)>
					<cfset EDIError = EDIDateError & " EDI 214 could not be queued.">
				</cfif>
				<cfif Len(EDIError)>				
					<cfreturn EDIError>
				</cfif>
						
			</cfloop>
		</cfif>
	</cfif>
</cfif>
		<cfreturn result>
	</cffunction>

	<!--- validate appointment records --->
	<cffunction name="EDI214ValidateApp" access="remote" output="yes" returntype="string" returnformat="json">
		<cfargument name="frmstruct" type="struct" required="yes">
	    <cfset doctype='214'>
	    <cfset result = "">
		
		
		<cfquery name="qGetLoadDetails" datasource="#Application.dsn#">
			SELECT DISTINCT EDISCAC,BolNum,LoadNumber,L.receiverid, stopdate  AS Ship_Date,stoptime AS Ship_Time,TimeIn as Ship_TimeIn,TimeOut as Ship_TimeOut,LoadType,LS.identitycode,LS.identitycodeq,LS.entityidentitycode
			,(SELECT SUM(Qty) FROM LoadStopCommodities WHERE loadstopid IN (
				SELECT loadstopid FROM loadstops WHERE loadid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.frmstruct.editid#">)) AS Qty
			,(SELECT SUM(Weight) FROM LoadStopCommodities WHERE loadstopid IN (
				SELECT loadstopid FROM loadstops WHERE loadid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.frmstruct.editid#">)) AS Weight			
			,(SELECT ISNULL(MAX(Assigned_Number),0)+1 FROM edi214) AS Assigned_Number
			,CustomerPONo
			,LS.custName
			,LS.StopNo
			,EDI.lm_LoadStops_StopNo  AS EdiStopNo
			,case when LoadType=1 then (LS.StopNo * 2 +1) else (LS.StopNo * 2 +2) End NewStopNO	
			, Edi.lm_LoadStops_StopNo as EdiNewStopNo	
			FROM Loads L
			LEFT JOIN LoadStops LS on L.loadID = LS.loadid
			LEFT JOIN edi204 E on L.loadId = E.LoadID
			LEFT JOIN edi204stops EDI on (edi.lm_Loads_BOL=L.BolNum OR edi.lm_Loads_BOL = l.CustomerPONo) and edi.IdentityCode=LS.IdentityCode
			where L.loadid=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.frmstruct.editid#" > AND EDISCAC is not null
			
			AND ls.custName is not null 
			
		</cfquery>		

		<cfif qGetLoadDetails.RecordCount>	
			
			
			<cfloop query="qGetLoadDetails">
				<cfset EDIError="">
				<cfset EDIDateError="">

				<cfif qGetLoadDetails.Loadtype EQ 1 AND (NOT Len(qGetLoadDetails.Ship_Date) OR NOT qGetLoadDetails.Ship_Date GTE now())>
					<cfif NOT Len(qGetLoadDetails.Ship_Date)>
						<cfset EDIDateError = "Pickup Date is not valid.">
					</cfif>
				<cfelseif qGetLoadDetails.Loadtype EQ 2 AND (NOT Len(qGetLoadDetails.Ship_Date) OR NOT qGetLoadDetails.Ship_Date GTE now())>
					<cfif NOT Len(qGetLoadDetails.Ship_Date)>
						<cfset EDIDateError = "Delivery Date is not valid.">
					</cfif>
				</cfif>	
				<cfif NOT isNumeric(qGetLoadDetails.Ship_TimeIn) AND qGetLoadDetails.Loadtype EQ 1>
					<cfset EDIError = "Pickup time in is not valid. EDI 214 could not be queued.">
				<cfelseif NOT isNumeric(qGetLoadDetails.Ship_TimeIn) AND qGetLoadDetails.Loadtype EQ 2>
					<cfset EDIError = "Delivery time in is not valid. EDI 214 could not be queued.">		
				<cfelseif IsNumeric(qGetLoadDetails.Ship_TimeIn) AND Len(qGetLoadDetails.Ship_TimeIn) EQ 4 >					
					
						<cfif qGetLoadDetails.Loadtype EQ 1>
							<cfset local.HourPart =Left(qGetLoadDetails.Ship_TimeIn,2)>
							<cfset local.MinutePart =Right(qGetLoadDetails.Ship_TimeIn,2)>
							<cfif local.HourPart GT 23 OR local.MinutePart GT 59>
								<cfset EDIError = "Pickup time in is not valid. EDI 214 could not be queued.">
							</cfif>
						<cfelseif qGetLoadDetails.Loadtype EQ 2>
							<cfset local.HourPart =Left(qGetLoadDetails.Ship_TimeIn,2)>
							<cfset local.MinutePart =Right(qGetLoadDetails.Ship_TimeIn,2)>
							<cfif local.HourPart GT 23 OR local.MinutePart GT 59>
								<cfset EDIError = "Delivery time in  is not valid. EDI 214 could not be queued.">
							</cfif>
						</cfif>
				<cfelseif Len(qGetLoadDetails.Ship_TimeIn) NEQ 4 AND qGetLoadDetails.Loadtype EQ 1>
					<cfset EDIError = "Pickup time in is not valid. EDI 214 could not be queued.">
				<cfelseif Len(qGetLoadDetails.Ship_TimeIn) NEQ 4 AND qGetLoadDetails.Loadtype EQ 2>
					<cfset EDIError = "Delivery time in is not valid. EDI 214 could not be queued.">				
				</cfif>
				<cfif Len(EDIDateError) AND Len(EDIError)>
					<cfset EDIError = EDIDateError & EDIError>
				<cfelseif Len(EDIDateError)>
					<cfset EDIError = EDIDateError & " EDI 214 could not be queued.">
				</cfif>
				<cfif Len(EDIError)>				
					<cfreturn EDIError>
				</cfif>
						
			</cfloop>
		
	</cfif>

		<cfreturn result>
	</cffunction>

	<!--- Insert status records --->
	<cffunction name="EDI214StatusRecord" access="remote" output="yes" returntype="string" returnformat="json">
		<cfargument name="frmstruct" type="struct" required="yes">
	    <cfset doctype='214'>
	    <cfset result = "">
		
		<cfquery name="qGetLoadDetails" datasource="#Application.dsn#">
			SELECT DISTINCT EDISCAC,BolNum,LoadNumber,L.receiverid, stopdate  AS Ship_Date,stoptime AS Ship_Time,TimeIn as Ship_TimeIn,TimeOut as Ship_TimeOut,LoadType,LS.identitycode,LS.identitycodeq,LS.entityidentitycode
			,(SELECT SUM(Qty) FROM LoadStopCommodities WHERE loadstopid IN (
				SELECT loadstopid FROM loadstops WHERE loadid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.frmstruct.editid#">)) AS Qty
			,(SELECT SUM(Weight) FROM LoadStopCommodities WHERE loadstopid IN (
				SELECT loadstopid FROM loadstops WHERE loadid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.frmstruct.editid#">)) AS Weight			
			,(SELECT ISNULL(MAX(Assigned_Number),0)+1 FROM edi214) AS Assigned_Number
			,CustomerPONo
			,LS.custName
			,LS.StopNo
			,EDI.lm_LoadStops_StopNo  AS EdiStopNo
			,case when LoadType=1 then (LS.StopNo * 2 +1) else (LS.StopNo * 2 +2) End NewStopNO	
			,Edi.lm_LoadStops_StopNo as EdiNewStopNo
			,EDI.lm_loadstops_stopdate as edistopdate
			,EDI.lm_loadstops_stoptimeQ as edistoptime
			,EDI.lm_LoadStops_StopDateQ	
			,case when EDI.lm_LoadStops_StopDateQ='02'  then 'Delivery Requested on This Date'  when EDI.lm_LoadStops_StopDateQ='10' then 'Requested Ship Date/Pick-up Date'
				  when EDI.lm_LoadStops_StopDateQ='37' then 'Ship Not Before Date' 
				  when EDI.lm_LoadStops_StopDateQ='38' then 'Ship Not Later Than Date' 
				  when EDI.lm_LoadStops_StopDateQ='53' then 'Deliver Not Before Date' 
				  when EDI.lm_LoadStops_StopDateQ='54' then 'Deliver No Later Than Date' 
				 end EDIReasonMessage 		
			FROM Loads L
			LEFT JOIN LoadStops LS on L.loadID = LS.loadid
			LEFT JOIN edi204 E on L.loadId = E.LoadID
			LEFT JOIN edi204stops EDI on (edi.lm_Loads_BOL=L.BolNum OR edi.lm_Loads_BOL = l.CustomerPONo) and edi.IdentityCode=LS.IdentityCode
			where L.loadid=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.frmstruct.editid#" > AND EDISCAC is not null			
			AND ls.custName is not null 
			
		</cfquery>		
		<cfset Assign_Number = qGetLoadDetails.Assigned_Number>
		<cfset EDIError ="">
		<cfset EDIDateError="">
		<cfloop query="qGetLoadDetails">
			<cfset local.Time = "">
			<cfset local.shipment_status = "">
			<cfset local.shipment_status_code = "">		
			
			<cfif qGetLoadDetails.LoadType Eq 1>
				<cfif qGetLoadDetails.stopNo eq 0>
					<cfset local.ediReasoncode = '#frmstruct.shipperEdiReasonCode#'>
					<cfset local.frmOldTimeIn = '#frmstruct.oldShipperTimeIn#'>
					<cfset local.frmTimeIn = '#frmstruct.shipperTimeIn#'>
				<cfelse>
					<cfset local.ediReasoncode = Evaluate('frmstruct.shipperEdiReasonCode#qGetLoadDetails.stopNo+1#')>
					<cfset local.frmOldTimeIn = Evaluate('frmstruct.oldShipperTimeIn#qGetLoadDetails.stopNo+1#')>
					<cfset local.frmTimeIn =  Evaluate('frmstruct.shipperTimeIn#qGetLoadDetails.stopNo+1#')>
				</cfif>

				<cfif len(local.ediReasoncode)>
					<cfset local.shipment_status = local.ediReasoncode>
				<cfelse>
					<cfset local.shipment_status = 'NS'>
				</cfif>
				
				
				<cfif Len(qGetLoadDetails.Ship_TimeIn) AND (local.frmOldTimeIn NEQ local.frmTimeIn OR len(local.ediReasoncode) )>
					<cfset local.Time = qGetLoadDetails.Ship_TimeIn>
					<cfset local.shipment_status_code = 'X3'>					
					
					<cfif Len(Local.Time) AND Len(local.shipment_status) AND Len(local.shipment_status_code)>

						<cfquery name="qryTimeIn" datasource="#Application.dsn#">
							select reference_identification from EDI214 
							WHERE Reference_Identification =<cfqueryparam cfsqltype="cf_sql_varchar" value="#qGetLoadDetails.LoadNumber#">
							
							AND [Time] ='#Local.Time#'
							AND Shipment_Status_Code ='#local.shipment_status_Code#'
							
						</cfquery>
						<cfif qryTimeIn.RecordCount EQ 0>
						<cfset local.HourPart =Left(local.Time,2)>
						<cfset local.MinutePart =Right(local.Time,2)>
							<cfif local.HourPart GT 23 OR local.MinutePart GT 59>
								<cfset EDIError = "Pickup time in is not valid. EDI 214 could not be queued.">
							<cfelse>
								<cfset EDIDateError="">

								<cfif qGetLoadDetails.Loadtype EQ 1 AND (NOT Len(qGetLoadDetails.Ship_Date) OR NOT qGetLoadDetails.Ship_Date GTE now())>
									<cfif NOT Len(qGetLoadDetails.Ship_Date)>
										<cfset EDIDateError = "Pickup Date is not valid.">
									</cfif>
								<cfelseif qGetLoadDetails.Loadtype EQ 2 AND (NOT Len(qGetLoadDetails.Ship_Date) OR NOT qGetLoadDetails.Ship_Date GTE now())>
									<cfif NOT Len(qGetLoadDetails.Ship_Date)>
										<cfset EDIDateError = "Delivery Date is not valid.">
									</cfif>
								</cfif>	
								<cfif Not Len(EDIDateError)>														


								<cfif qGetLoadDetails.Ship_TimeIn GT qGetLoadDetails.Ship_Time>
									<cfif len(local.ediReasoncode) Eq 0>
								  		<cfreturn "Please select a reason for late pickup on Stop "& qGetLoadDetails.stopno+1>
								  	<cfelse>
								  		<cfset local.shipment_status = local.ediReasoncode>
								    </cfif>
								</cfif>
								<cfquery name="qInsEDI214" datasource="#Application.dsn#">
									INSERT INTO EDI214(
									 Reference_Identification	
									,lm_Loads_BOL	
									,lm_EDISetup_SCAC	
									,[lm_LoadStops_Type-Code]	
									,lm_LoadStops_StopName	
									,[lm_LoadStops_Type-Qualifier]	
									,Identification_Code	
									,Assigned_Number	
									,Shipment_Status_Code	
									,Shipment_Status	
									,[Date]	
									,[Time]	
									,TIme_Code	
									,Purchase_Order_Number	
									,edi_processed	
									,receiverID
									,Shipment_Appointment_Status_Code
									,lm_LoadStops_StopNo
									,ModifiedDate
									,Shipment_Appointment_Status
									,LoadID
									)
								Values(
									'#qGetLoadDetails.LoadNumber#'
									,'#qGetLoadDetails.BolNum#'
									,'#qGetLoadDetails.EDISCAC#'
									,'#qGetLoadDetails.EntityIdentityCode#'
									,'#qGetLoadDetails.custname#'
									,'#qGetLoadDetails.IdentityCodeQ#'
									,'#qGetLoadDetails.IdentityCode#'
									,'#Assign_Number#'
									,'#local.shipment_status_Code#'
									,'#local.shipment_status#'
									,'#dateformat(qGetLoadDetails.Ship_Date,"yyyymmdd")#'
									,'#local.Time#'
									,'LT'
									,'#qGetLoadDetails.CustomerPONo#'
									,0
						           	,'#qGetLoadDetails.receiverid#'
						           	,''
						           	,'#qGetLoadDetails.EdiNewStopNO#'
						           	,getdate()
						           	,''
									,'#arguments.frmstruct.editid#'
									)
							</cfquery>
					<cfset Assign_Number = Assign_Number +1>
					<cfset EDI214_Status ='#local.shipment_status# - #local.shipment_status_Code#'>
					<cfset LogEdi214(qGetLoadDetails.BolNum, DocType, EDI214_Status, qGetLoadDetails.LoadNumber)>
					<cfset result = "EDI 214 pickup information has been queued. ">
					<cfset AlertEDIReasonMessage = qGetLoadDetails.EDIReasonMessage>
					<cfset showEdistopDate =  Mid(qGetLoadDetails.Edistopdate,5,2) &"/" & Mid(qGetLoadDetails.Edistopdate,7,2) & "/" & Mid(qGetLoadDetails.Edistopdate,1,4) >
					<cfset showEdistoptime = Mid(qGetLoadDetails.Edistoptime,1,2) & ":" &	Mid(qGetLoadDetails.Edistoptime,3,4)>	
					
					
					
				</cfif>
				</cfif>
			</cfif>
			</cfif>
				</cfif>
				<cfif Len(qGetLoadDetails.Ship_TimeOut)>
					<cfset local.Time = qGetLoadDetails.Ship_TimeOut>
					<cfset local.shipment_status_code = 'AF'>
					
					<cfif qGetLoadDetails.stopNo eq 0>
						<cfset local.ediReasoncode = '#frmstruct.shipperEdiReasonCode#'>						
						<cfset local.frmOldTimeOut = '#frmstruct.oldShipperTimeOut#'>
						<cfset local.frmTimeOut = '#frmstruct.shipperTimeOut#'>
					<cfelse>
						<cfset local.ediReasoncode = Evaluate('frmstruct.shipperEdiReasonCode#qGetLoadDetails.stopNo+1#')>			
						<cfset local.frmOldTimeOut = Evaluate('frmstruct.oldShipperTimeOut#qGetLoadDetails.stopNo+1#')>
						<cfset local.frmTimeOut =  Evaluate('frmstruct.shipperTimeOut#qGetLoadDetails.stopNo+1#')>
					</cfif>

					<cfif Len(Local.Time) AND Len(local.shipment_status) AND Len(local.shipment_status_code)>
					<cfquery name="qryTimeIn" datasource="#Application.dsn#">
							select reference_identification from EDI214 
							WHERE Reference_Identification =<cfqueryparam cfsqltype="cf_sql_varchar" value="#qGetLoadDetails.LoadNumber#">
							
							AND [Time] ='#Local.Time#'
							AND Shipment_Status_Code ='#local.shipment_status_Code#'
							
						</cfquery>
						<cfif qryTimeIn.RecordCount EQ 0>
							<cfset local.HourPart =Left(local.Time,2)>
						<cfset local.MinutePart =Right(local.Time,2)>
							<cfif local.HourPart GT 23 OR local.MinutePart GT 59>
								<cfset EDIError = "Pickup time in is not valid. EDI 214 could not be queued.">
							<cfelse>
								<cfset EDIDateError="">

								<cfif qGetLoadDetails.Loadtype EQ 1 AND (NOT Len(qGetLoadDetails.Ship_Date) OR NOT qGetLoadDetails.Ship_Date GTE now())>
									<cfif NOT Len(qGetLoadDetails.Ship_Date)>
										<cfset EDIDateError = "Pickup Date is not valid.">
									</cfif>
								<cfelseif qGetLoadDetails.Loadtype EQ 2 AND (NOT Len(qGetLoadDetails.Ship_Date) OR NOT qGetLoadDetails.Ship_Date GTE now())>
									<cfif NOT Len(qGetLoadDetails.Ship_Date)>
										<cfset EDIDateError = "Delivery Date is not valid.">
									</cfif>
								</cfif>	
								<cfif Not Len(EDIDateError)>
								<cfquery name="qInsEDI214" datasource="#Application.dsn#">
									INSERT INTO EDI214(
									 Reference_Identification	
									,lm_Loads_BOL	
									,lm_EDISetup_SCAC	
									,[lm_LoadStops_Type-Code]	
									,lm_LoadStops_StopName	
									,[lm_LoadStops_Type-Qualifier]	
									,Identification_Code	
									,Assigned_Number	
									,Shipment_Status_Code	
									,Shipment_Status	
									,[Date]	
									,[Time]	
									,TIme_Code	
									,Purchase_Order_Number	
									,edi_processed	
									,receiverID
									,Shipment_Appointment_Status_Code
									,lm_LoadStops_StopNo
									,ModifiedDate
									,Shipment_Appointment_Status
									,LoadID
									)
								Values(
									'#qGetLoadDetails.LoadNumber#'
									,'#qGetLoadDetails.BolNum#'
									,'#qGetLoadDetails.EDISCAC#'
									,'#qGetLoadDetails.EntityIdentityCode#'
									,'#qGetLoadDetails.custname#'
									,'#qGetLoadDetails.IdentityCodeQ#'
									,'#qGetLoadDetails.IdentityCode#'
									,'#Assign_Number#'
									,'#local.shipment_status_Code#'
									,'#local.shipment_status#'
									,'#dateformat(qGetLoadDetails.Ship_Date,"yyyymmdd")#'
									,'#local.Time#'
									,'LT'
									,'#qGetLoadDetails.CustomerPONo#'
									,0
						           	,'#qGetLoadDetails.receiverid#'
						           	,''
						           	,'#qGetLoadDetails.EdiNewStopNO#'
						           	,getdate()
						           	,''
									,'#arguments.frmstruct.editid#'
									)
							</cfquery>
							<cfset Assign_Number = Assign_Number +1>
							<cfset EDI214_Status ='#local.shipment_status# - #local.shipment_status_Code#'>
							<cfset LogEdi214(qGetLoadDetails.BolNum, DocType, EDI214_Status, qGetLoadDetails.LoadNumber)>
							<cfset result = "EDI 214 pickup information has been queued. ">
							<cfset AlertEDIReasonMessage = qGetLoadDetails.EDIReasonMessage>
							<cfset showEdistopDate =  Mid(qGetLoadDetails.Edistopdate,5,2) &"/" & Mid(qGetLoadDetails.Edistopdate,7,2) & "/" & Mid(qGetLoadDetails.Edistopdate,1,4) >
							<cfset showEdistoptime = Mid(qGetLoadDetails.Edistoptime,1,2) & ":" &	Mid(qGetLoadDetails.Edistoptime,3,4)>	
							
						</cfif>
						</cfif>
		</cfif>
			</cfif>
				</cfif>
			<cfelseif qGetLoadDetails.LoadType Eq 2>
				<cfset local.ediReasoncode ="">
				<cfif qGetLoadDetails.stopNo eq 0>
					<cfset local.ediReasoncode = '#frmstruct.consigneeEdiReasonCode#'>
					<cfset local.frmOldTimeIn = '#frmstruct.oldConsigneeTimeIn#'>
					<cfset local.frmTimeIn = '#frmstruct.ConsigneeTimeIn#'>
				<cfelse>
					<cfset local.ediReasoncode = Evaluate('frmstruct.consigneeEdiReasonCode#qGetLoadDetails.stopNo+1#')>
					<cfset local.frmOldTimeIn = Evaluate('frmstruct.oldConsigneeTimeIn#qGetLoadDetails.stopNo+1#')>
					<cfset local.frmTimeIn =  Evaluate('frmstruct.ConsigneeTimeIn#qGetLoadDetails.stopNo+1#')>
				</cfif>
				
				<cfif len(local.ediReasoncode)>
					<cfset local.shipment_status = local.ediReasoncode>
				<cfelse>
					<cfset local.shipment_status = 'NS'>
				</cfif>
				<cfif Len(qGetLoadDetails.Ship_TimeIn) AND (local.frmOldTimeIn NEQ local.frmTimeIn OR Len(local.ediReasoncode))>
					<cfset local.Time = qGetLoadDetails.Ship_TimeIn>
					<cfset local.shipment_status_code = 'X1'>
					<cfif Len(Local.Time) AND Len(local.shipment_status) AND Len(local.shipment_status_code)>
						<cfquery name="qryTimeIn" datasource="#Application.dsn#">
							select reference_identification from EDI214 
							WHERE Reference_Identification =<cfqueryparam cfsqltype="cf_sql_varchar" value="#qGetLoadDetails.LoadNumber#">
							
							AND [Time] ='#Local.Time#'
							AND Shipment_Status_Code ='#local.shipment_status_Code#'
							
						</cfquery>
						<cfif qryTimeIn.RecordCount EQ 0>
							<cfset local.HourPart =Left(local.Time,2)>
						<cfset local.MinutePart =Right(local.Time,2)>
							<cfif local.HourPart GT 23 OR local.MinutePart GT 59>
								<cfset EDIError = "Pickup time in is not valid. EDI 214 could not be queued.">
							<cfelse>
								<cfset EDIDateError="">

								<cfif qGetLoadDetails.Loadtype EQ 1 AND (NOT Len(qGetLoadDetails.Ship_Date) OR NOT qGetLoadDetails.Ship_Date GTE now())>
									<cfif NOT Len(qGetLoadDetails.Ship_Date)>
										<cfset EDIDateError = "Pickup Date is not valid.">
									</cfif>
								<cfelseif qGetLoadDetails.Loadtype EQ 2 AND (NOT Len(qGetLoadDetails.Ship_Date) OR NOT qGetLoadDetails.Ship_Date GTE now())>
									<cfif NOT Len(qGetLoadDetails.Ship_Date)>
										<cfset EDIDateError = "Delivery Date is not valid.">
									</cfif>
								</cfif>	
								<cfif Not Len(EDIDateError)>
								
								
								<cfif qGetLoadDetails.Ship_TimeIn GT qGetLoadDetails.Ship_Time>
									<cfif len(local.ediReasoncode) Eq 0>
								  		<cfreturn "Please select a reason for late delivery on Stop "& qGetLoadDetails.stopno+1>
								  	<cfelse>
								  		<cfset local.shipment_status = local.ediReasoncode>
								    </cfif>
								</cfif>
								<cfquery name="qInsEDI214" datasource="#Application.dsn#">
									INSERT INTO EDI214(
									 Reference_Identification	
									,lm_Loads_BOL	
									,lm_EDISetup_SCAC	
									,[lm_LoadStops_Type-Code]	
									,lm_LoadStops_StopName	
									,[lm_LoadStops_Type-Qualifier]	
									,Identification_Code	
									,Assigned_Number	
									,Shipment_Status_Code	
									,Shipment_Status	
									,[Date]	
									,[Time]	
									,TIme_Code	
									,Purchase_Order_Number	
									,edi_processed	
									,receiverID
									,Shipment_Appointment_Status_Code
									,lm_LoadStops_StopNo
									,ModifiedDate
									,Shipment_Appointment_Status
									,LoadID
									)
								Values(
									'#qGetLoadDetails.LoadNumber#'
									,'#qGetLoadDetails.BolNum#'
									,'#qGetLoadDetails.EDISCAC#'
									,'#qGetLoadDetails.EntityIdentityCode#'
									,'#qGetLoadDetails.custname#'
									,'#qGetLoadDetails.IdentityCodeQ#'
									,'#qGetLoadDetails.IdentityCode#'
									,'#Assign_Number#'
									,'#local.shipment_status_Code#'
									,'#local.shipment_status#'
									,'#dateformat(qGetLoadDetails.Ship_Date,"yyyymmdd")#'
									,'#local.Time#'
									,'LT'
									,'#qGetLoadDetails.CustomerPONo#'
									,0
						           	,'#qGetLoadDetails.receiverid#'
						           	,''
						           	,'#qGetLoadDetails.EdiNewStopNO#'
						           	,getdate()
						           	,''
									,'#arguments.frmstruct.editid#'
									)
							</cfquery>
							<cfset Assign_Number = Assign_Number +1>
							<cfset EDI214_Status ='#local.shipment_status# - #local.shipment_status_Code#'>
							<cfset LogEdi214(qGetLoadDetails.BolNum, DocType, EDI214_Status, qGetLoadDetails.LoadNumber)>
							<cfset result = "EDI 214 delivery information has been queued. ">
							<cfset AlertEDIReasonMessage = qGetLoadDetails.EDIReasonMessage>
							<cfset showEdistopDate =  Mid(qGetLoadDetails.Edistopdate,5,2) &"/" & Mid(qGetLoadDetails.Edistopdate,7,2) & "/" & Mid(qGetLoadDetails.Edistopdate,1,4) >
							<cfset showEdistoptime = Mid(qGetLoadDetails.Edistoptime,1,2) & ":" &	Mid(qGetLoadDetails.Edistoptime,3,4)>	
							
							
						</cfif>
						</cfif>
		</cfif>
			</cfif>
				</cfif>
				<cfif Len(qGetLoadDetails.Ship_TimeOut)>
					<cfset local.Time = qGetLoadDetails.Ship_TimeOut>
					<cfset local.shipment_status_code = 'CD'>
					<cfif qGetLoadDetails.stopNo eq 0>
						<cfset local.ediReasoncode = '#frmstruct.consigneeEdiReasonCode#'>
						<cfset local.frmOldTimeOut = '#frmstruct.oldConsigneeTimeOut#'>
						<cfset local.frmTimeOut = '#frmstruct.ConsigneeTimeOut#'>
					<cfelse>
						<cfset local.ediReasoncode = Evaluate('frmstruct.consigneeEdiReasonCode#qGetLoadDetails.stopNo+1#')>
						<cfset local.frmOldTimeOut = Evaluate('frmstruct.oldConsigneeTimeOut#qGetLoadDetails.stopNo+1#')>
						<cfset local.frmTimeOut =  Evaluate('frmstruct.ConsigneeTimeOut#qGetLoadDetails.stopNo+1#')>
					</cfif>
				
					<cfif Len(Local.Time) AND Len(local.shipment_status) AND Len(local.shipment_status_code)>
						<cfquery name="qryTimeIn" datasource="#Application.dsn#">
							select reference_identification from EDI214 
							WHERE Reference_Identification =<cfqueryparam cfsqltype="cf_sql_varchar" value="#qGetLoadDetails.LoadNumber#">
							
							AND [Time] ='#Local.Time#'
							AND Shipment_Status_Code ='#local.shipment_status_Code#'
							
						</cfquery>
						<cfif qryTimeIn.RecordCount EQ 0>
							<cfset local.HourPart =Left(local.Time,2)>
						<cfset local.MinutePart =Right(local.Time,2)>
							<cfif local.HourPart GT 23 OR local.MinutePart GT 59>
								<cfset EDIError = "Pickup time in is not valid. EDI 214 could not be queued.">
							<cfelse>
								<cfset EDIDateError="">

								<cfif qGetLoadDetails.Loadtype EQ 1 AND (NOT Len(qGetLoadDetails.Ship_Date) OR NOT qGetLoadDetails.Ship_Date GTE now())>
									<cfif NOT Len(qGetLoadDetails.Ship_Date)>
										<cfset EDIDateError = "Pickup Date is not valid.">
									</cfif>
								<cfelseif qGetLoadDetails.Loadtype EQ 2 AND (NOT Len(qGetLoadDetails.Ship_Date) OR NOT qGetLoadDetails.Ship_Date GTE now())>
									<cfif NOT Len(qGetLoadDetails.Ship_Date)>
										<cfset EDIDateError = "Delivery Date is not valid.">
									</cfif>
								</cfif>	
								<cfif Not Len(EDIDateError)>

								
								<cfquery name="qInsEDI214" datasource="#Application.dsn#">
									INSERT INTO EDI214(
									 Reference_Identification	
									,lm_Loads_BOL	
									,lm_EDISetup_SCAC	
									,[lm_LoadStops_Type-Code]	
									,lm_LoadStops_StopName	
									,[lm_LoadStops_Type-Qualifier]	
									,Identification_Code	
									,Assigned_Number	
									,Shipment_Status_Code	
									,Shipment_Status	
									,[Date]	
									,[Time]	
									,TIme_Code	
									,Purchase_Order_Number	
									,edi_processed	
									,receiverID
									,Shipment_Appointment_Status_Code
									,lm_LoadStops_StopNo
									,ModifiedDate
									,Shipment_Appointment_Status
									,LoadID
									)
								Values(
									'#qGetLoadDetails.LoadNumber#'
									,'#qGetLoadDetails.BolNum#'
									,'#qGetLoadDetails.EDISCAC#'
									,'#qGetLoadDetails.EntityIdentityCode#'
									,'#qGetLoadDetails.custname#'
									,'#qGetLoadDetails.IdentityCodeQ#'
									,'#qGetLoadDetails.IdentityCode#'
									,'#Assign_Number#'
									,'#local.shipment_status_Code#'
									,'#local.shipment_status#'
									,'#dateformat(qGetLoadDetails.Ship_Date,"yyyymmdd")#'
									,'#local.Time#'
									,'LT'
									,'#qGetLoadDetails.CustomerPONo#'
									,0
						           	,'#qGetLoadDetails.receiverid#'
						           	,''
						           	,'#qGetLoadDetails.EdiNewStopNO#'
						           	,getdate()
						           	,''
									,'#arguments.frmstruct.editid#'
									)
							</cfquery>
							<cfset Assign_Number = Assign_Number +1>
							<cfset EDI214_Status ='#local.shipment_status# - #local.shipment_status_Code#'>
							<cfset LogEdi214(qGetLoadDetails.BolNum, DocType, EDI214_Status, qGetLoadDetails.LoadNumber)>
							<cfset result = "EDI 214 delivery information has been queued. ">
							<cfset AlertEDIReasonMessage = qGetLoadDetails.EDIReasonMessage>
							<cfset showEdistopDate =  Mid(qGetLoadDetails.Edistopdate,5,2) &"/" & Mid(qGetLoadDetails.Edistopdate,7,2) & "/" & Mid(qGetLoadDetails.Edistopdate,1,4) >		
							<cfset showEdistoptime = Mid(qGetLoadDetails.Edistoptime,1,2) & ":" &	Mid(qGetLoadDetails.Edistoptime,3,4)>
							
						</cfif>
						</cfif>
		</cfif>
			</cfif>
				</cfif>
			</cfif>
			
			
		</cfloop>
		
			
		<cfreturn result>
	</cffunction>
	<cffunction name="LogEdi214" access="remote" output="yes" returntype="string" returnformat="json">
		<cfargument name="BolNum" type="string" required="yes" />
		<cfargument name="DocType" type="string" required="yes" />
		<cfargument name="EDI214Status" type="string" required="yes" />
		<cfargument name="LoadNumber" type="string" required="yes" />
		
		<cfquery name="qinsEDILog" datasource="#Application.dsn#">
			INSERT INTO EDI204Log (
					[LoadLogID]
		           ,[BOLNumber]
		           ,[Detail]
		           ,[CreatedDate]
		           ,[LoadNumber]
		           ,[DocType]
		           ,[ModifiedDate]
				)
			VALUES(newid()
				,<cfqueryparam value="#Arguments.BolNum#" cfsqltype="cf_sql_varchar">
				,<cfqueryparam value="EDI#Arguments.DocType# processed with status #Arguments.EDI214Status#." cfsqltype="cf_sql_varchar">
				,getdate()
				,<cfqueryparam value="#Arguments.LoadNumber#" cfsqltype="CF_SQL_INTEGER">
				,<cfqueryparam value="#Arguments.DocType#" cfsqltype="cf_sql_varchar">
				,getdate())
		</cfquery>

	</cffunction>
	
</cfcomponent>