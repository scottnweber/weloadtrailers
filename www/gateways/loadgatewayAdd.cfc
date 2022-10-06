<cfcomponent output="true" extends="loadgateway">
<cfsetting showdebugoutput="true">
<cfif not structKeyExists(variables,"loadgatewayUpdate")>
	<cfscript>variables.objLoadgatewayUpdate = #request.cfcpath#&".loadgatewayUpdate";</cfscript>
</cfif>
<cfif not structKeyExists(variables,"objPromilesGateway")>
	<cfscript>variables.objPromilesGateway = #request.cfcpath#&".promile";</cfscript>
</cfif>
<cfif not structKeyExists(variables,"objPromilesGatewayTest")>
	<cfscript>variables.objPromilesGatewayTest = #request.cfcpath#&".promiles";</cfscript>
</cfif>
<cfif not structKeyExists(variables,"objAlertGateway")>
	<cfscript>variables.objAlertGateway = #request.cfcpath#&".alertgateway";</cfscript>
</cfif>

<cffunction name="init" access="public" output="false" returntype="void">
	<cfargument name="dsn" type="string" required="yes" />
	<cfset variables.dsn = Application.dsn />
</cffunction>


<!--- add load--->
<cffunction name="addLoad" access="public" returntype="any">
	<cfargument name="frmstruct" type="struct" required="yes">
	<cftry>
	<cfset var LastLoadId = "">
	<cfset var loadManualNo = "">
	<cfset var InvoiceNumber = "">
	<cfset var impref = "">
	<cfset var loadStruct ="">
	<cfset var lastUpdatedShipCustomerID ="">
	<cfset var lastInsertedStopId = "">
	<cfset var lastUpdatedConsCustomerID ="">
	<cfset var l = structNew()>
	<cfinvoke method="getSystemSetupOptions" returnvariable="request.qSystemSetupOptions">
	<cfset l.IsConcatCarrierDriverIdentifier = request.qSystemSetupOptions.IsConcatCarrierDriverIdentifier />
	<cfset l.freightBroker = request.qSystemSetupOptions.freightBroker />
	    
	    <cfif len(trim(l.IsConcatCarrierDriverIdentifier)) AND l.IsConcatCarrierDriverIdentifier EQ 1 AND l.freightBroker EQ 2>
			<cfset l.IsConcatCarrierDriverIdentifier = 1>
		<cfelse>
			<cfset l.IsConcatCarrierDriverIdentifier = 0>
		</cfif>
		<cfif request.qSystemSetupOptions.AutomaticFactoringFee eq 1 and structKeyExists(arguments.frmstruct, "FactoringFeePercent") AND isNumeric(arguments.frmstruct.FactoringFeePercent)>
			<cfset FF = arguments.frmstruct.FactoringFeePercent>
		<cfelse>
			<cfset FF = 0>
		</cfif>
		
		<cfif isdefined('arguments.frmstruct.weightStop1') and  arguments.frmstruct.weightStop1 neq "">
			<cfif isnumeric(arguments.frmstruct.weightStop1)>
				<cfset l.weight=arguments.frmstruct.weightStop1>
			<cfelse>
				<cfset l.weight=0>
			</cfif>
		<cfelse>
			<cfset l.weight=0>
		</cfif>
		<cfif isdefined('arguments.frmstruct.posttoloadboard')>
			<cfset posttoloadboard=True>
		<cfelse>
			<cfset posttoloadboard=False>
		</cfif>
		<cfset posttoTranscore=False><!--- Making default value to 0. If the post is success, then it will updated to 1 later. --->
		<cfif isdefined('arguments.frmstruct.PostTo123LoadBoard')>
			<cfset PostTo123LoadBoard=True>
		<cfelse>
			<cfset PostTo123LoadBoard=False>
		</cfif>
		<cfif isdefined('arguments.frmstruct.ARExported')><cfset ARExported="1"><cfelse><cfset ARExported="0">d</cfif>
		<cfif isdefined('arguments.frmstruct.APExported')><cfset APExported="1"><cfelse><cfset APExported="0"></cfif>
		<cfif isdefined('arguments.frmstruct.shipBlind')><cfset shipBlind=True><cfelse><cfset shipBlind=False></cfif>
		<cfif isdefined('arguments.frmstruct.ConsBlind')><cfset ConsBlind=True><cfelse><cfset ConsBlind=False></cfif>
		<cfset var custRatePerMile = ReplaceNoCase(arguments.frmstruct.CustomerRatePerMile,'$','','ALL')>
		<cfset custRatePerMile = ReplaceNoCase(custRatePerMile,',','','ALL')>
		<cfset var carRatePerMile = ReplaceNoCase(arguments.frmstruct.CarrierRatePerMile,'$','','ALL')>
		<cfset carRatePerMile = ReplaceNoCase(carRatePerMile,',','','ALL')>
		<cfset var custMilesCharges = ReplaceNoCase(arguments.frmstruct.CustomerMiles,'$','','ALL')>
		<cfset custMilesCharges = ReplaceNoCase(custMilesCharges,',','','ALL')>
		<cfset var carMilesCharges = ReplaceNoCase(arguments.frmstruct.CarrierMiles,'$','','ALL')>
		<cfset carMilesCharges = ReplaceNoCase(carMilesCharges,',','','ALL')>
		<cfset var custCommodCharges = ReplaceNoCase(arguments.frmstruct.TotalCustcommodities,'$','','ALL')>
		<cfset custCommodCharges = ReplaceNoCase(custCommodCharges,',','','ALL')>
		<cfset var carCommodCharges = ReplaceNoCase(arguments.frmstruct.TotalCarcommodities,'$','','ALL')>
		<cfset carCommodCharges = ReplaceNoCase(carCommodCharges,',','','ALL')>
		<cfset var custFlatRate = ReplaceNoCase(arguments.frmstruct.CustomerRate,'$','','ALL')>
		<cfset custFlatRate = ReplaceNoCase(custFlatRate,',','','ALL')>
		<cfset var carFlatRate = ReplaceNoCase(arguments.frmstruct.CarrierRate,'$','','ALL')>
		<cfset carFlatRate = ReplaceNoCase(carFlatRate,',','','ALL')>
		<cfset var CustomerMilesCalc = ReplaceNoCase(arguments.frmstruct.CustomerMilesCalc,'$','','ALL')>
		<cfset CustomerMilesCalc = ReplaceNoCase(CustomerMilesCalc,',','','ALL')>

		<cfset var CarrierMilesCalc = ReplaceNoCase(arguments.frmstruct.CarrierMilesCalc,'$','','ALL')>
		<cfset CarrierMilesCalc = ReplaceNoCase(CarrierMilesCalc,',','','ALL')>
		
		<cfif structKeyExists(arguments.frmstruct,"postCarrierRatetoloadboard")>
			<cfset postCarrierRatetoloadboard = arguments.frmstruct.postCarrierRatetoloadboard>
		<cfelse>
			<cfset postCarrierRatetoloadboard = 0>
		</cfif>

		<cfif structKeyExists(arguments.frmstruct,"postCarrierRatetoTranscore")>
			<cfset postCarrierRatetoTranscore = arguments.frmstruct.postCarrierRatetoTranscore>
		<cfelse>
			<cfset postCarrierRatetoTranscore = 0>
		</cfif>

		<cfif structKeyExists(arguments.frmstruct,"postCarrierRateto123LoadBoard")>
			<cfset postCarrierRateto123LoadBoard = arguments.frmstruct.postCarrierRateto123LoadBoard>
		<cfelse>
			<cfset postCarrierRateto123LoadBoard = 0>
		</cfif>
		
		<cfif structKeyExists(arguments.frmstruct,"noOfTrips")>
			<cfset noOfTrips = arguments.frmstruct.noOfTrips>
		<cfelse>
			<cfset noOfTrips = 1>
		</cfif>

		<cftransaction>
			<!--- Begin : Get Invoice Number --->
			<CFSTOREDPROC PROCEDURE="spGetAvailableInvoiceNumber" DATASOURCE="#variables.dsn#">
			 	<CFPROCPARAM VALUE="#session.CompanyID#" cfsqltype="CF_SQL_VARCHAR">
				<CFPROCRESULT NAME="qGetLoadMaxInvNum">
			</CFSTOREDPROC>
			<cfset InvoiceNumber=qGetLoadMaxInvNum.InvoiceNumber>
			<!--- End : Get Invoice Number --->

			<!--- Begin : Get Load Number --->
			<CFSTOREDPROC PROCEDURE="spGenerateLoadNumber" DATASOURCE="#variables.dsn#">
			 	<CFPROCPARAM VALUE="#session.CompanyID#" cfsqltype="CF_SQL_VARCHAR">
			 	<cfif structKeyExists(arguments.frmStruct, "LoadManualNo") AND len(trim(arguments.frmStruct.LoadManualNo))>
			 		<CFPROCPARAM VALUE="#trim(arguments.frmStruct.LoadManualNo)#" cfsqltype="CF_SQL_VARCHAR">
			 	<cfelse>
			 		<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR" null="true">
			 	</cfif>
				<CFPROCRESULT NAME="qGetLoadNum">
			</CFSTOREDPROC>
			<cfset loadManualNo=qGetLoadNum.LoadNumber>
			<!--- End : Get Load Number --->

			<cfinvoke component="#variables.objLoadgatewayUpdate#" method="InsertLoadAdd" loadManualNo="#loadManualNo#"  posttoloadboard="#posttoloadboard#" posttoTranscore="#posttoTranscore#" PostTo123LoadBoard="#PostTo123LoadBoard#" frmstruct="#arguments.frmstruct#" carFlatRate="#carFlatRate#" custFlatRate="#custFlatRate#" custRatePerMile="#custRatePerMile#" carRatePerMile="#carRatePerMile#" CustomerMilesCalc="#CustomerMilesCalc#" CarrierMilesCalc="#CarrierMilesCalc#" ARExported="#ARExported#" APExported="#APExported#" custMilesCharges="#custMilesCharges#" carMilesCharges="#carMilesCharges#" invoiceNumber="#invoiceNumber#" carCommodCharges="#carCommodCharges#" dsn="#variables.dsn#" custCommodCharges="#custCommodCharges#"  postCarrierRatetoloadboard="#postCarrierRatetoloadboard#"  postCarrierRatetoTranscore="#postCarrierRatetoTranscore#"   postCarrierRateto123LoadBoard="#postCarrierRateto123LoadBoard#" IsConcatCarrierDriverIdentifier="#l.IsConcatCarrierDriverIdentifier#" noOfTrips="#noOfTrips#" FF="#FF#" returnvariable="qInsertedLoadID"/>
		  	<cfif isDefined("arguments.frmstruct.userDefinedForTrucking")>
			   	<cfquery name="UpdateUserDefinedFieldTrucking" datasource="#variables.dsn#">
					UPDATE  Loads SET
					userDefinedFieldTrucking=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.frmstruct.userDefinedForTrucking#">
					where loadid=<cfqueryparam cfsqltype="cf_sql_varchar" value="#qInsertedLoadID.LASTLOADID#">
				</cfquery>
			</cfif>
	   </cftransaction>
	   <cfset LastLoadId=qInsertedLoadID.LASTLOADID>
	   <cfset impref=qInsertedLoadID.IMPREF>
		<cfif isdefined('arguments.frmstruct.ISPARTIAL')>
			<cfset ISPARTIAL=1>
		<cfelse>
			<cfset ISPARTIAL=0>
		</cfif>
		<cfset readyDat = "">
		<cfif structKeyExists(arguments.frmstruct,"readyDat") and isDate(arguments.frmstruct.readyDat)>
			<cfset readyDat = arguments.frmstruct.readyDat>
		</cfif>
		<cfset arriveDat = "">
		<cfif structKeyExists(arguments.frmstruct,"arriveDat") and isDate(arguments.frmstruct.arriveDat)>
			<cfset arriveDat = arguments.frmstruct.arriveDat>
		</cfif>
		<cfset isExcused = "">
		<cfif structKeyExists(arguments.frmstruct,"Excused")>
			<cfset isExcused = arguments.frmstruct.Excused>
		</cfif>
		<cfset bookedBy = "">
		<cfif structKeyExists(arguments.frmstruct,"bookedBy")>
			<cfset bookedBy = arguments.frmstruct.bookedBy>
		</cfif>
		<!--- BEGIN: 604: Add a column to All Loads/ My Loads : Add DeadHead Miles for Load--->
		<cfset DeadHeadMiles = 0>
		<cfif structKeyExists(arguments.frmstruct,"DeadHeadMiles") AND arguments.frmstruct.DeadHeadMiles NEQ "" AND isNumeric(arguments.frmstruct.DeadHeadMiles)>
			<cfset DeadHeadMiles = arguments.frmstruct.DeadHeadMiles>
		</cfif>
		<!--- END: 604: Add a column to All Loads/ My Loads : Add DeadHead Miles for Load--->
		<cfquery name="Updatepartial_fld" datasource="#variables.dsn#">
			UPDATE  Loads SET ISPARTIAL=<cfqueryparam cfsqltype="cf_sql_bit" value="#ISPARTIAL#">
			<cfif len(readyDat) gt 0>,readyDate = <cfqueryparam cfsqltype="cf_sql_date" value="#readyDat#">
			<cfelse>,readyDate = <cfqueryparam cfsqltype="cf_sql_date" value="#readyDat#" null="yes">
			</cfif>
			<cfif len(arriveDat) gt 0>,arriveDate = <cfqueryparam cfsqltype="cf_sql_date" value="#arriveDat#">
			<cfelse>,arriveDate = <cfqueryparam cfsqltype="cf_sql_date" value="#arriveDat#" null="yes">
			</cfif>
			<cfif len(isExcused) GT 0>,isExcused = <cfqueryparam cfsqltype="cf_sql_integer" value="#isExcused#">
			<cfelse>,isExcused = <cfqueryparam cfsqltype="cf_sql_integer" value="0">
			</cfif>
			<cfif len(bookedBy) GT 0>,bookedBy = <cfqueryparam cfsqltype="cf_sql_varchar" value="#bookedBy#">
			<cfelse>,bookedBy = <cfqueryparam cfsqltype="cf_sql_varchar" value="#bookedBy#" null="yes">
			</cfif>
			,DeadHeadMiles = <cfqueryparam cfsqltype="cf_sql_float" value="#DeadHeadMiles#">
			WHERE LoadID=<cfqueryparam cfsqltype="cf_sql_varchar" value="#LastLoadId#">
		</cfquery>
	   <!--- If there are any files attached to this load then move from temp table to the main table --->
	   <cfif structKeyExists(arguments.frmstruct,"tempLoadId")>
		   <cfinvoke method="linkAttachments" tempLoadId="#arguments.frmstruct.tempLoadId#" permLoadId="#LastLoadId#">
	   </cfif>
	   <cfset l.shipperStatus=0>
		 <cfif arguments.frmstruct.shipper eq "" and arguments.frmstruct.shipperName eq "" and arguments.frmstruct.shipperlocation eq "" and arguments.frmstruct.shipperstate eq "" and arguments.frmstruct.shipperZipcode eq "" and arguments.frmstruct.shipperContactPerson eq "" and arguments.frmstruct.shipperPhone eq "" and arguments.frmstruct.shipperFax eq "" and arguments.frmstruct.shipperPickupNo1 eq "" and arguments.frmstruct.shipperPickupDate eq "" and arguments.frmstruct.shipperpickupTime eq "" and arguments.frmstruct.shipperTimeIn eq "" and arguments.frmstruct.shipperTimeOut eq "" and arguments.frmstruct.shipperEmail eq "" and shipBlind eq 'false' and arguments.frmstruct.shipperNotes eq "" and arguments.frmstruct.shipperDirection eq "">
			<cfset l.shipperStatus=1>
		</cfif>

		<cfset lastUpdatedShipCustomerID ="">
		<cfif arguments.frmstruct.shipper neq "" and arguments.frmstruct.shipperName neq "">
			<!--- If Stop1 shipperFlag eq 2 then update customer details--->
		   <cfif structKeyExists(arguments.frmstruct,"shipperFlag") and  arguments.frmstruct.shipperFlag eq 2>
		   		<cfif request.qSystemSetupOptions.UpdateCustomerFromLoadScreen eq 1>
					<cfinvoke method="updateCustomer" formStruct="#arguments.frmstruct#" updateType="shipper" stopNo="0" returnvariable="lastUpdatedShipCustomerID" />
				<cfelseif arguments.frmstruct.shipperValueContainer neq "">
					<cfset lastUpdatedShipCustomerID = arguments.frmstruct.shipperValueContainer>
				</cfif>
			<cfelseif ((structKeyExists(arguments.frmstruct,"shipperFlag") and  arguments.frmstruct.shipperFlag eq 1) or (arguments.frmstruct.shipperValueContainer eq "")) and (l.shipperStatus eq 0)>
				<cfscript>
					variables.objCustomerGateway = #request.cfcpath#&".customergateway";
				</cfscript>
				<cfinvoke method="formCustStruct" frmstruct="#arguments.frmstruct#" type="shipper" returnvariable="shipperStruct" />
				<cfinvoke component ="#variables.objCustomerGateway#" method="AddCustomer" formStruct="#shipperStruct#" idReturn="true" returnvariable="addedShipperResult"/>
				<cfset lastUpdatedShipCustomerID = addedShipperResult.id>
			<cfelseif (l.shipperStatus eq 0)>
				<cfquery name="getEarlierCustName" datasource="#variables.dsn#">
					select CustomerName from Customers WHERE CustomerID = <cfqueryparam cfsqltype="cf_sql_varchar" value='#arguments.frmstruct.shipperValueContainer#'>
				</cfquery>
				<!--- If the customer name has changed then insert it --->
				<cfif lcase(getEarlierCustName.CustomerName) neq lcase(arguments.frmstruct.shipperName)>
					<cfscript>
						variables.objCustomerGateway = #request.cfcpath#&".customergateway";
					</cfscript>
					<cfinvoke method="formCustStruct" frmstruct="#arguments.frmstruct#" type="shipper" returnvariable="shipperStruct" />
					<cfinvoke component ="#variables.objCustomerGateway#" method="AddCustomer" formStruct="#shipperStruct#" idReturn="true" returnvariable="addedShipperResult"/>
					<cfset lastUpdatedShipCustomerID = addedShipperResult.id>
				<cfelse>
					<cfset lastUpdatedShipCustomerID = arguments.frmstruct.shipperValueContainer>
				</cfif>
			<cfelse>
				<cfset lastUpdatedShipCustomerID = arguments.frmstruct.shipperValueContainer>
			 </cfif>
		</cfif>
		<cfif IsValid("date",arguments.frmstruct.shipperPickupDate) and IsValid("date",arguments.frmstruct.consigneePickupDate)>
			<cfset l.dateCompareResult= DateCompare(arguments.frmstruct.shipperPickupDate,arguments.frmstruct.consigneePickupDate)>
			<cfif l.dateCompareResult eq -1>
				<cfset l.noOfDays1=dateDiff("d",arguments.frmstruct.shipperPickupDate, arguments.frmstruct.consigneePickupDate)>
			<cfelseif l.dateCompareResult eq 0>
				<cfset l.noOfDays1=0>
			<cfelseif l.dateCompareResult eq 1>
				<cfset l.noOfDays1="">
			</cfif>
		<cfelse>
			<cfset l.noOfDays1="">
		</cfif>
		<cfset lastInsertedStopId = insertShipperStopLoadAdd(LastLoadId,lastUpdatedShipCustomerID,ShipBlind,l.noOfDays1,arguments.frmstruct)>

		<!--- IMPORT Load Stop Starts Here ---->
		<cfif structKeyExists(arguments.frmstruct,"dateDispatched")>
			<cfinvoke method="InsertLoadStopIntermodalImport" lastInsertedStopId="#lastInsertedStopId#" frmstruct="#arguments.frmstruct#">
			<cfinvoke method="getLoadStopAddress" tablename="LoadStopCargoPickupAddress"
						address="#arguments.frmstruct.pickUpAddress#" returnvariable="qLoadStopCargoPickupAddressExists" />
			<cfif qLoadStopCargoPickupAddressExists.recordcount>
				<cfquery name="qUpdateCargoPickupAddress" datasource="#variables.dsn#">
					update
						LoadStopCargoPickupAddress
					set
						address = <cfqueryparam value="#arguments.frmstruct.pickUpAddress#" cfsqltype="cf_sql_varchar">,
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
							<cfqueryparam value="#arguments.frmstruct.pickUpAddress#" cfsqltype="cf_sql_varchar">,
							<cfqueryparam value="#lastInsertedStopId#" cfsqltype="cf_sql_varchar">,
							<cfqueryparam value="#now()#" cfsqltype="cf_sql_date">,
							<cfqueryparam value="#now()#" cfsqltype="cf_sql_date">
						)
				</cfquery>
			</cfif>
			<cfinvoke method="getLoadStopAddress" tablename="LoadStopCargoDeliveryAddress"
						address="#arguments.frmstruct.deliveryAddress#" returnvariable="qLoadStopCargoDeliveryAddressExists" />
			<cfif qLoadStopCargoDeliveryAddressExists.recordcount>
				<cfquery name="qUpdateCargoDeliveryAddress" datasource="#variables.dsn#">
					update
						LoadStopCargoDeliveryAddress
					set
						address = <cfqueryparam value="#arguments.frmstruct.deliveryAddress#" cfsqltype="cf_sql_varchar">,
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
							<cfqueryparam value="#arguments.frmstruct.deliveryAddress#" cfsqltype="cf_sql_varchar">,
							<cfqueryparam value="#lastInsertedStopId#" cfsqltype="cf_sql_varchar">,
							<cfqueryparam value="#now()#" cfsqltype="cf_sql_date">,
							<cfqueryparam value="#now()#" cfsqltype="cf_sql_date">
						)
				</cfquery>
			</cfif>
			<cfinvoke method="getLoadStopAddress" tablename="LoadStopEmptyReturnAddress"
						address="#arguments.frmstruct.emptyReturnAddress#" returnvariable="qLoadStopEmptyReturnAddressExists" />
			<cfif qLoadStopEmptyReturnAddressExists.recordcount>
				<cfquery name="qUpdateEmptyReturnAddress" datasource="#variables.dsn#">
					update
						LoadStopEmptyReturnAddress
					set
						address = <cfqueryparam value="#arguments.frmstruct.emptyReturnAddress#" cfsqltype="cf_sql_varchar">,
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
							<cfqueryparam value="#arguments.frmstruct.emptyReturnAddress#" cfsqltype="cf_sql_varchar">,
							<cfqueryparam value="#lastInsertedStopId#" cfsqltype="cf_sql_varchar">,
							<cfqueryparam value="#now()#" cfsqltype="cf_sql_date">,
							<cfqueryparam value="#now()#" cfsqltype="cf_sql_date">
						)
				</cfquery>
			</cfif>

		</cfif>
		<!--- IMPORT Load Stop Ends Here --->

		<!--- EXPORT Load Stop Starts Here ---->
		<cfif structKeyExists(arguments.frmstruct,"exportDateDispatched")>
			<cfquery name="qUpdateLoadStopIntermodalExport" datasource="#variables.dsn#">
				insert into LoadStopIntermodalExport
					(
						LoadStopID,
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
						returnAddress
					)
				values
					(
						<cfqueryparam value="#lastInsertedStopId#" cfsqltype="cf_sql_varchar">,
						<cfqueryparam value="1" cfsqltype="cf_sql_integer">,
						<cfqueryparam value="#arguments.frmstruct.exportDateDispatched#" cfsqltype="cf_sql_date">,
						<cfqueryparam value="#arguments.frmstruct.exportDateMtAvailableForPickup#" cfsqltype="cf_sql_date">,
						<cfqueryparam value="#arguments.frmstruct.exportsteamShipLine#" cfsqltype="cf_sql_varchar">,
						<cfqueryparam value="#arguments.frmstruct.exportDemurrageFreeTimeExpirationDate#" cfsqltype="cf_sql_date">,
						<cfqueryparam value="#arguments.frmstruct.exportvesselName#" cfsqltype="cf_sql_varchar">,
						<cfqueryparam value="#arguments.frmstruct.exportPerDiemFreeTimeExpirationDate#" cfsqltype="cf_sql_date">,
						<cfqueryparam value="#arguments.frmstruct.exportVoyage#" cfsqltype="cf_sql_varchar">,
						<cfqueryparam value="#arguments.frmstruct.exportEmptyPickupDate#" cfsqltype="cf_sql_date" null="#yesNoFormat(NOT len(arguments.frmstruct.exportEmptyPickupDate))#">,
						<cfqueryparam value="#arguments.frmstruct.exportseal#" cfsqltype="cf_sql_varchar">,
						<cfqueryparam value="#arguments.frmstruct.exportBooking#" cfsqltype="cf_sql_varchar">,
						<cfqueryparam value="#arguments.frmstruct.exportScheduledLoadingDate#" cfsqltype="cf_sql_date">,
						<cfqueryparam value="#arguments.frmstruct.exportScheduledLoadingTime#" cfsqltype="cf_sql_varchar" null="#yesNoFormat(NOT len(trim(arguments.frmstruct.exportScheduledLoadingTime)))#">,
						<cfqueryparam value="#arguments.frmstruct.exportVesselCutoffDate#" cfsqltype="cf_sql_date">,
						<cfqueryparam value="#arguments.frmstruct.exportLoadingDate#" cfsqltype="cf_sql_date">,
						<cfqueryparam value="#arguments.frmstruct.exportVesselLoadingWindow#" cfsqltype="cf_sql_varchar">,
						<cfqueryparam value="#arguments.frmstruct.exportLoadingDelayDetectionStartDate#" cfsqltype="cf_sql_date">,
						<cfqueryparam value="#arguments.frmstruct.exportLoadingDelayDetectionStartTime#" cfsqltype="cf_sql_varchar" null="#yesNoFormat(NOT len(trim(arguments.frmstruct.exportLoadingDelayDetectionStartTime)))#">,
						<cfqueryparam value="#arguments.frmstruct.exportRequestedLoadingDate#" cfsqltype="cf_sql_date">,
						<cfqueryparam value="#arguments.frmstruct.exportRequestedLoadingTime#" cfsqltype="cf_sql_varchar" null="#yesNoFormat(NOT len(trim(arguments.frmstruct.exportRequestedLoadingTime)))#">,
						<cfqueryparam value="#arguments.frmstruct.exportLoadingDelayDetectionEndDate#" cfsqltype="cf_sql_date">,
						<cfqueryparam value="#arguments.frmstruct.exportLoadingDelayDetectionEndTime#" cfsqltype="cf_sql_varchar" null="#yesNoFormat(NOT len(trim(arguments.frmstruct.exportLoadingDelayDetectionEndTime)))#">,
						<cfqueryparam value="#arguments.frmstruct.exportETS#" cfsqltype="cf_sql_date">,
						<cfqueryparam value="#arguments.frmstruct.exportReturnDate#" cfsqltype="cf_sql_date">,
						<cfqueryparam value="#arguments.frmstruct.exportEmptyPickupAddress#" cfsqltype="cf_sql_varchar">,
						<cfqueryparam value="#arguments.frmstruct.exportLoadingAddress#" cfsqltype="cf_sql_varchar">,
						<cfqueryparam value="#arguments.frmstruct.exportReturnAddress#" cfsqltype="cf_sql_varchar">
					)
			</cfquery>

			<cfinvoke method="getLoadStopAddress" tablename="LoadStopEmptyPickupAddress"
						address="#arguments.frmstruct.exportEmptyPickUpAddress#" returnvariable="qLoadStopEmptyPickupAddressExists" />
			<cfif qLoadStopEmptyPickupAddressExists.recordcount>
				<cfquery name="qUpdateEmptyPickupAddress" datasource="#variables.dsn#">
					update
						LoadStopEmptyPickupAddress
					set
						address = <cfqueryparam value="#arguments.frmstruct.exportEmptyPickUpAddress#" cfsqltype="cf_sql_varchar">,
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
							<cfqueryparam value="#arguments.frmstruct.exportEmptyPickUpAddress#" cfsqltype="cf_sql_varchar">,
							<cfqueryparam value="#lastInsertedStopId#" cfsqltype="cf_sql_varchar">,
							<cfqueryparam value="#now()#" cfsqltype="cf_sql_date">,
							<cfqueryparam value="#now()#" cfsqltype="cf_sql_date">
						)
				</cfquery>
			</cfif>
			<cfinvoke method="getLoadStopAddress" tablename="LoadStopLoadingAddress"
						address="#arguments.frmstruct.exportLoadingAddress#" returnvariable="qLoadStopLoadingAddressExists" />
			<cfif qLoadStopLoadingAddressExists.recordcount>
				<cfquery name="qUpdateLoadingAddress" datasource="#variables.dsn#">
					update
						LoadStopLoadingAddress
					set
						address = <cfqueryparam value="#arguments.frmstruct.exportLoadingAddress#" cfsqltype="cf_sql_varchar">,
						LoadStopID = <cfqueryparam value="#lastInsertedStopId#" cfsqltype="cf_sql_varchar">,
						dateModified = <cfqueryparam value="#now()#" cfsqltype="cf_sql_date">
					where ID = <cfqueryparam value="#qLoadStopLoadingAddressExists.ID#" cfsqltype="cf_sql_integer">
				</cfquery>
			<cfelse>
				<cfquery name="qInsertLoadingAddress" datasource="#variables.dsn#">
					insert into LoadStopLoadingAddress
						(address, LoadStopID, dateAdded, dateModified)
					values
						(
							<cfqueryparam value="#arguments.frmstruct.exportLoadingAddress#" cfsqltype="cf_sql_varchar">,
							<cfqueryparam value="#lastInsertedStopId#" cfsqltype="cf_sql_varchar">,
							<cfqueryparam value="#now()#" cfsqltype="cf_sql_date">,
							<cfqueryparam value="#now()#" cfsqltype="cf_sql_date">
						)
				</cfquery>
			</cfif>
			<cfinvoke method="getLoadStopAddress" tablename="LoadStopReturnAddress"
						address="#arguments.frmstruct.exportReturnAddress#" returnvariable="qLoadStopReturnAddressExists" />
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
		<cfset l.consigneeFlagstatus=0>
		<cfif arguments.frmstruct.consignee eq "" and arguments.frmstruct.consigneeName eq "" and arguments.frmstruct.consigneelocation eq "" and  arguments.frmstruct.consigneestate eq "" and arguments.frmstruct.consigneecity eq "" and arguments.frmstruct.consigneeZipcode eq "" and arguments.frmstruct.consigneeContactPerson eq "" and arguments.frmstruct.consigneePhone eq "" and arguments.frmstruct.consigneeFax eq "" and arguments.frmstruct.consigneePickupNo eq "" and arguments.frmstruct.consigneePickupDate eq "" and arguments.frmstruct.consigneepickupTime eq "" and arguments.frmstruct.consigneeTimeIn eq "" and arguments.frmstruct.consigneeTimeOut eq "" and ConsBlind eq 'false' and arguments.frmstruct.consigneeEmail eq "" and arguments.frmstruct.consigneeNotes eq "" and  arguments.frmstruct.consigneeDirection eq "">
			<cfset l.consigneeFlagstatus=1>
		</cfif>
		<cfset lastUpdatedConsCustomerID ="">
		<cfif arguments.frmstruct.consignee neq "" and arguments.frmstruct.consigneeName neq "">
			<!--- If Stop1 consigneeFlag  eq 2 then update customer details--->
			<cfif structKeyExists(arguments.frmstruct,"consigneeFlag") and  arguments.frmstruct.consigneeFlag eq 2>
				<cfif request.qSystemSetupOptions.UpdateCustomerFromLoadScreen eq 1>
					<cfinvoke method="updateCustomer" formStruct="#arguments.frmstruct#" updateType="consignee" stopNo="0" returnvariable="lastUpdatedConsCustomerID" />
				<cfelseif arguments.frmstruct.consigneeValueContainer neq "">
					<cfset lastUpdatedConsCustomerID = arguments.frmstruct.consigneeValueContainer>
				</cfif>
			<cfelseif ((structKeyExists(arguments.frmstruct,"consigneeFlag") and  arguments.frmstruct.consigneeFlag eq 1) or (arguments.frmstruct.consigneeValueContainer eq "")) and (l.consigneeFlagstatus eq 0) >
				<cfscript>
					variables.objCustomerGateway = #request.cfcpath#&".customergateway";
				</cfscript>
				<cfinvoke method="formCustStruct" frmstruct="#arguments.frmstruct#" type="consignee" returnvariable="consigneeStruct" />
				<cfinvoke component ="#variables.objCustomerGateway#" method="AddCustomer" formStruct="#consigneeStruct#" idReturn="true" returnvariable="addedConsigneeResult"/>
				<cfset lastUpdatedConsCustomerID = addedConsigneeResult.id>
		   <cfelseif (l.consigneeFlagstatus eq 0)>
				<cfquery name="getEarlierCustName" datasource="#variables.dsn#">
					select CustomerName from Customers WHERE CustomerID = <cfqueryparam value="#consigneeValueContainer#" cfsqltype="cf_sql_varchar">
				</cfquery>
				<!--- If the customer name has changed then insert it --->
				<cfif lcase(getEarlierCustName.CustomerName) neq lcase(arguments.frmstruct.consigneeName)>
					<cfscript>
						variables.objCustomerGateway = #request.cfcpath#&".customergateway";
					</cfscript>
					<cfinvoke method="formCustStruct" frmstruct="#arguments.frmstruct#" type="consignee" returnvariable="consigneeStruct" />
					<cfinvoke component ="#variables.objCustomerGateway#" method="AddCustomer" formStruct="#consigneeStruct#" idReturn="true" returnvariable="addedConsigneeResult"/>
					<cfset lastUpdatedConsCustomerID = addedConsigneeResult.id>
				<cfelse>
					<cfset lastUpdatedConsCustomerID = arguments.frmstruct.consigneeValueContainer>
				</cfif>
			<cfelse>
				<cfset lastUpdatedConsCustomerID = arguments.frmstruct.consigneeValueContainer>
			</cfif>
		</cfif>

		<cfset insertConsigneeStopLoadAdd(LastLoadId,lastUpdatedConsCustomerID,ConsBlind,l.noOfDays1,arguments.frmstruct)>
		<!--- Insert Load Items---->
		<cfloop from="1" to="#val(arguments.frmstruct.totalResult1)#" index="Num">
		     <cfset qty=VAL(evaluate("arguments.frmstruct.qty_#num#"))>
			 <cfset unit=evaluate("arguments.frmstruct.unit_#num#")>
			 <cfif isDefined("arguments.frmstruct.description_#num#")>
			 	<cfset description=evaluate("arguments.frmstruct.description_#num#")>
			<cfelse>
				<cfset description="">
			</cfif>
			 <cfset dimensions=evaluate("arguments.frmstruct.dimensions_#num#")>
			 <cfif isdefined("arguments.frmstruct.weight_#num#")>
				<cfset weight=VAL(replaceNoCase(evaluate("arguments.frmstruct.weight_#num#"), ",", "","ALL"))>
			<cfelse>
				<cfset weight=0>
			</cfif>
			 <cfset class=evaluate("arguments.frmstruct.class_#num#")>
			 <cfset CustomerRate=evaluate("arguments.frmstruct.CustomerRate_#num#")>
			 <cfset CustomerRate = replace( replace( CustomerRate,"$","","ALL"),",","","ALL") >
			 <cfset CarrierRate=evaluate("arguments.frmstruct.CarrierRate_#num#")>
			 <cfset CarrierRate = replace( replace( CarrierRate,"$","","ALL"),",","","ALL") >
			 <cfset CustomerRate = replace( replace( CustomerRate,"(","","ALL"),")","","ALL") >
 			 <cfset CarrierRate = replace( replace( CarrierRate,"(","","ALL"),")","","ALL") >
			 <cfif structKeyExists(arguments.frmstruct, 'custCharges_#num#')>
				<cfset custCharges=evaluate("arguments.frmstruct.custCharges_#num#")>
				<cfset custCharges = replace( replace( custCharges,"$","","ALL"),",","","ALL") >
			 <cfelse>
				<cfset custCharges = 0>
			 </cfif>
			 <cfset carrCharges=evaluate("arguments.frmstruct.carrCharges_#num#")>
			 <cfset carrCharges = replace( replace( carrCharges,"$","","ALL"),",","","ALL") >
			 <cfset CarrRateOfCustTotal=evaluate("arguments.frmstruct.CarrierPer_#num#")>
			 <cfset CarrRateOfCustTotal = replace( CarrRateOfCustTotal,"%","","ALL") >

			 <cfset directCost=evaluate("arguments.frmstruct.directCost_#num#")>
			 <cfset directCost = replace( replace( directCost,"$","","ALL"),",","","ALL") >
			 <cfset directCostTotal =evaluate("arguments.frmstruct.directCostTotal_#num#")>
			 <cfset directCostTotal = replace( replace( directCostTotal,"$","","ALL"),",","","ALL")>
			 <cfif not len(trim(directCost))><cfset directCost=0.00></cfif>
			 <cfif not len(trim(directCostTotal))><cfset directCostTotal=0.00></cfif>

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
				<CFPROCPARAM VALUE="#CarrRateOfCustTotal#" cfsqltype="CF_SQL_VARCHAR">
			 	<CFPROCPARAM VALUE="#isFee#" cfsqltype="CF_SQL_VARCHAR">
			 	<CFPROCPARAM VALUE="#Val(directCost)#" cfsqltype="cf_sql_money">
				<CFPROCPARAM VALUE="#val(directCostTotal)#" cfsqltype="cf_sql_money">
				<CFPROCPARAM VALUE="#dimensions#" cfsqltype="CF_SQL_VARCHAR">
			 	<CFPROCRESULT NAME="qInsertedLoadItem">
			</cfstoredproc>
		</cfloop>
	    <!--- Insert 2nd and further Stops --->
	    <cfset var stpID = "">
		<cfif listLen(arguments.frmstruct.shownStopArray)>
			<!--- Looping through 2nd and further loads --->
			<cfloop list="#arguments.frmstruct.shownStopArray#" index="stpID">
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
				<cfset evaluate("l.shipperStatus#stpID#=0")>
				 <cfif  evaluate('arguments.frmstruct.shipper#stpID#') eq "" and evaluate('arguments.frmstruct.shipperName#stpID#') eq "" and evaluate('arguments.frmstruct.shipperlocation#stpID#') eq "" and evaluate('arguments.frmstruct.shipperstate#stpID#') eq "" and evaluate('arguments.frmstruct.shipperZipcode#stpID#')  eq "" and evaluate('arguments.frmstruct.shipperContactPerson#stpID#') eq "" and evaluate('arguments.frmstruct.shipperPhone#stpID#') eq "" and evaluate('arguments.frmstruct.shipperFax#stpID#') eq "" and evaluate('arguments.frmstruct.shipperPickupNo1#stpID#') eq "" and evaluate('arguments.frmstruct.shipperPickupDate#stpID#') eq "" and evaluate('arguments.frmstruct.shipperpickupTime#stpID#') eq "" and evaluate('arguments.frmstruct.shipperTimeIn#stpID#') eq "" and evaluate('arguments.frmstruct.shipperTimeOut#stpID#') eq "" and evaluate('arguments.frmstruct.shipperEmail#stpID#') eq "" and shipBlind eq 'false' and evaluate(' arguments.frmstruct.shipperNotes#stpID#') eq "" and evaluate('arguments.frmstruct.shipperDirection#stpID#') eq "">
					<cfset evaluate("l.shipperStatus#stpID#=1")>
				</cfif>
				<cfset lastUpdatedShipCustomerID ="">
				<cfif evaluate("arguments.frmstruct.shipper#stpID#") neq "" and evaluate("arguments.frmstruct.shipperName#stpID#") neq "">					<!--- If 2nd and further stops shipperFlag eq 2 then update customer details --->
					
					<cfif structKeyExists(arguments.frmstruct,"shipperFlag#stpID#") and  evaluate("arguments.frmstruct.shipperFlag#stpID#") eq 2>
						<cfif request.qSystemSetupOptions.UpdateCustomerFromLoadScreen eq 1>
							<cfinvoke method="updateCustomer" formStruct="#arguments.frmstruct#" updateType="shipper" stopNo="#stpID#" returnvariable="lastUpdatedShipCustomerID" />
						<cfelseif evaluate('arguments.frmstruct.shipperValueContainer#stpID#') neq "">
							<cfset lastUpdatedShipCustomerID = evaluate('arguments.frmstruct.shipperValueContainer#stpID#')>
						</cfif>
					<cfelseif ((structKeyExists(arguments.frmstruct,"shipperFlag#stpID#") and  evaluate("arguments.frmstruct.shipperFlag#stpID#") eq 1) or (evaluate('arguments.frmstruct.shipperValueContainer#stpID#') eq "")) and ((evaluate('l.shipperStatus#stpID#') eq 0))>
						<cfscript>
							variables.objCustomerGateway = #request.cfcpath#&".customergateway";
						</cfscript>
						<cfinvoke method="formCustStruct" frmstruct="#arguments.frmstruct#" type="shipper" stop="#stpID#" returnvariable="shipperStruct" />
						<cfinvoke component ="#variables.objCustomerGateway#" method="AddCustomer" formStruct="#shipperStruct#" idReturn="true" returnvariable="addedShipperResult"/>
						<cfset lastUpdatedShipCustomerID = addedShipperResult.id>
					<cfelseif (evaluate('l.shipperStatus#stpID#') eq 0)>
						<cfquery name="getEarlierCustName" datasource="#variables.dsn#">
							select CustomerName from Customers WHERE CustomerID = 
							<cfqueryparam value='#arguments.frmstruct.cutomerIdAutoValueContainer#' cfsqltype="cf_sql_varchar">
						</cfquery>
						<!--- If the customer name has changed then insert it --->
						<cfif lcase(getEarlierCustName.CustomerName) neq lcase(evaluate("arguments.frmstruct.shipperName#stpID#"))>
							<cfscript>
								variables.objCustomerGateway = #request.cfcpath#&".customergateway";
							</cfscript>
							<cfinvoke method="formCustStruct" frmstruct="#arguments.frmstruct#" type="shipper" stop="#stpID#" returnvariable="shipperStruct" />
							<cfinvoke component ="#variables.objCustomerGateway#" method="AddCustomer" formStruct="#shipperStruct#" idReturn="true" returnvariable="addedShipperResult"/>
							<cfset lastUpdatedShipCustomerID = addedShipperResult.id>
						<cfelse>
							<cfset lastUpdatedShipCustomerID = evaluate('arguments.frmstruct.shipperValueContainer#stpID#')>
						</cfif>
					<cfelse>
						<cfset lastUpdatedShipCustomerID = evaluate('arguments.frmstruct.shipperValueContainer#stpID#')>
					</cfif>
				</cfif>
		 	<cfset l.NewStopNo = 0>
	 		<cfloop from="1" to="#arguments.frmstruct.totalStop#" index="index">
	 			<cfquery name="qryGetStopExists" datasource="#variables.dsn#">
					SELECT StopNo FROM LoadStops
					WHERE LoadID = <cfqueryparam value="#LastLoadId#" cfsqltype="cf_sql_varchar">
					AND StopNo = <cfqueryparam value="#index#" cfsqltype="cf_sql_integer">
					AND StopNo < <cfqueryparam value="#stpID-1#" cfsqltype="cf_sql_integer">
				</cfquery>
				<cfif NOT qryGetStopExists.recordcount>
					<cfset l.NewStopNo = index>
					<cfbreak>
				<cfelse>
					<cfset l.NewStopNo = index>
				</cfif>
	 		</cfloop>
	 			<cfif IsValid("date",#evaluate('arguments.frmstruct.shipperPickupDate#stpID#')#) and IsValid("date",#evaluate('arguments.frmstruct.consigneePickupDate#stpID#')#)>					<cfset l.dateCompareResult= DateCompare(evaluate('arguments.frmstruct.shipperPickupDate#stpID#'), evaluate('arguments.frmstruct.consigneePickupDate#stpID#'))>
					<cfif l.dateCompareResult eq -1>
						<cfset l.noOfDays=dateDiff("d", evaluate('arguments.frmstruct.shipperPickupDate#stpID#'), evaluate('arguments.frmstruct.consigneePickupDate#stpID#'))>
					<cfelseif l.dateCompareResult eq 0>
						<cfset l.noOfDays=0>
					<cfelseif l.dateCompareResult eq 1>
						<cfset l.noOfDays="">
					</cfif>
				<cfelse>
					<cfset l.noOfDays="">
				</cfif>
				
				<cfset qInsertedCustStopId = insertShipperStopLoadAddStopNo(LastLoadId,lastUpdatedShipCustomerID,ShipBlind,l.noOfDays,l.NewStopNo,arguments.frmstruct,stpID)>

				<cfset lastInsertedStopId = qInsertedCustStopId.lastStopID>
				<cfset evaluate("l.consigneeFlagstatus#stpID#=0")>
				<cfif  evaluate('arguments.frmstruct.consignee#stpID#') eq "" and evaluate('arguments.frmstruct.consigneeName#stpID#') eq "" and evaluate('arguments.frmstruct.consigneelocation#stpID#') eq "" and evaluate('arguments.frmstruct.consigneestate#stpID#') eq "" and evaluate('arguments.frmstruct.consigneecity#stpID#')  eq "" and evaluate('arguments.frmstruct.consigneeZipcode#stpID#') eq "" and evaluate('arguments.frmstruct.consigneeContactPerson#stpID#') eq "" and evaluate('arguments.frmstruct.consigneePhone#stpID#') eq "" and evaluate('arguments.frmstruct.consigneeFax#stpID#') eq "" and evaluate('arguments.frmstruct.consigneePickupNo#stpID#') eq "" and evaluate('arguments.frmstruct.consigneePickupDate#stpID#') eq "" and evaluate('arguments.frmstruct.consigneepickupTime#stpID#') eq "" and evaluate('arguments.frmstruct.consigneeTimeIn#stpID#') eq "" and evaluate('arguments.frmstruct.consigneeTimeOut#stpID#') eq "" and ConsBlind eq 'false' and evaluate(' arguments.frmstruct.consigneeEmail#stpID#') eq "" and evaluate('arguments.frmstruct.consigneeNotes#stpID#') eq ""  and evaluate('arguments.frmstruct.consigneeDirection#stpID#') eq "">
					<cfset evaluate("l.consigneeFlagstatus#stpID#=1")>
				</cfif>
				<cfset lastUpdatedConsCustomerID ="">
				<cfif evaluate("arguments.frmstruct.consignee#stpID#") neq "" and evaluate("arguments.frmstruct.consigneeName#stpID#") neq "">
					<!--- If 2nd and further stops consigneeFlag eq 2 then update customer details--->
					<cfif structKeyExists(arguments.frmstruct,"consigneeFlag#stpID#") and  evaluate("arguments.frmstruct.consigneeFlag#stpID#") eq 2>
						<cfif request.qSystemSetupOptions.UpdateCustomerFromLoadScreen eq 1>
							<cfinvoke method="updateCustomer" formStruct="#arguments.frmstruct#" updateType="consignee" stopNo="#stpID#" returnvariable="lastUpdatedConsCustomerID" />
						<cfelseif evaluate('arguments.frmstruct.consigneeValueContainer#stpID#') neq "">
							<cfset lastUpdatedConsCustomerID = evaluate('arguments.frmstruct.consigneeValueContainer#stpID#')>
						</cfif>
					<cfelseif ((structKeyExists(arguments.frmstruct,"consigneeFlag#stpID#") and  evaluate("arguments.frmstruct.consigneeFlag#stpID#") eq 1) or (evaluate('arguments.frmstruct.consigneeValueContainer#stpID#') eq "")) and (evaluate('l.consigneeFlagstatus#stpID#') eq 0)  >
						<cfscript>
							variables.objCustomerGateway = #request.cfcpath#&".customergateway";
						</cfscript>
						<cfinvoke method="formCustStruct" frmstruct="#arguments.frmstruct#" type="consignee" stop="#stpID#" returnvariable="consigneeStruct" />
						<cfinvoke component ="#variables.objCustomerGateway#" method="AddCustomer" formStruct="#consigneeStruct#" idReturn="true" returnvariable="addedConsigneeResult"/>
						<cfset lastUpdatedConsCustomerID = addedConsigneeResult.id>
				   <cfelseif (evaluate('l.consigneeFlagstatus#stpID#') eq 0)>
						<cfquery name="getEarlierCustName" datasource="#variables.dsn#">
							select CustomerName from Customers WHERE CustomerID = <cfqueryparam value='#arguments.frmstruct.cutomerIdAutoValueContainer#' cfsqltype="cf_sql_varchar">
						</cfquery>
						<!--- If the customer name has changed then insert it --->
						<cfif lcase(getEarlierCustName.CustomerName) neq lcase(evaluate("arguments.frmstruct.consigneeName#stpID#"))>
							<cfscript>
								variables.objCustomerGateway = #request.cfcpath#&".customergateway";
							</cfscript>
							<cfinvoke method="formCustStruct" frmstruct="#arguments.frmstruct#" type="consignee" stop="#stpID#" returnvariable="consigneeStruct" />
							<cfinvoke component ="#variables.objCustomerGateway#" method="AddCustomer" formStruct="#consigneeStruct#" idReturn="true" returnvariable="addedConsigneeResult"/>
							<cfset lastUpdatedConsCustomerID = addedConsigneeResult.id>
						<cfelse>
							<cfset lastUpdatedConsCustomerID = evaluate("arguments.frmstruct.consigneeValueContainer#stpID#")>
						</cfif>
					<cfelse>
						<cfset lastUpdatedConsCustomerID = evaluate("arguments.frmstruct.consigneeValueContainer#stpID#")>
					</cfif>
				</cfif>

				<cfset qInsertedCustStopId = insertConsigneeStopLoadAddStopNo(LastLoadId,lastUpdatedConsCustomerID,ConsBlind,l.noOfDays,l.NewStopNo,arguments.frmstruct,stpID)>
				<cfset lastConsigneeStopId = qInsertedCustStopId.lastStopID>

				<!--- IMPORT Load Stop Starts Here ---->
				<cfif structKeyExists(arguments.frmstruct,"dateDispatched#stpID#")>
					<cfinvoke method="InsertLoadStopIntermodalImportStpID" lastInsertedStopId="#lastInsertedStopId#" frmstruct="#arguments.frmstruct#" stpID="#stpID#">

					<cfinvoke method="getLoadStopAddress" tablename="LoadStopCargoPickupAddress"
						address="#EVALUATE('arguments.frmstruct.pickUpAddress#stpID#')#" returnvariable="qLoadStopCargoPickupAddressExists" />
					<cfif qLoadStopCargoPickupAddressExists.recordcount>
						<cfquery name="qUpdateCargoPickupAddress" datasource="#variables.dsn#">
							update
								LoadStopCargoPickupAddress
							set
								address = <cfqueryparam value="#EVALUATE('arguments.frmstruct.pickUpAddress#stpID#')#" cfsqltype="cf_sql_varchar">,
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
					<cfinvoke method="getLoadStopAddress" tablename="LoadStopCargoDeliveryAddress" address="#EVALUATE('arguments.frmstruct.deliveryAddress#stpID#')#" returnvariable="qLoadStopCargoDeliveryAddressExists" />
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
					<cfinvoke method="getLoadStopAddress" tablename="LoadStopEmptyReturnAddress" address="#EVALUATE('arguments.frmstruct.emptyReturnAddress#stpID#')#" returnvariable="qLoadStopEmptyReturnAddressExists" />
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
					<cfquery name="qUpdateLoadStopIntermodalExport" datasource="#variables.dsn#">
						insert into LoadStopIntermodalExport
							(
								LoadStopID,
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
								returnAddress
							)
						values
							(
								<cfqueryparam value="#lastInsertedStopId#" cfsqltype="cf_sql_varchar">,
								<cfqueryparam value="#stpID#" cfsqltype="cf_sql_integer">,
								<cfqueryparam value="#EVALUATE('arguments.frmstruct.exportDateDispatched#stpID#')#" cfsqltype="cf_sql_date">,
								<cfqueryparam value="#EVALUATE('arguments.frmstruct.exportDateMtAvailableForPickup#stpID#')#" cfsqltype="cf_sql_date">,
								<cfqueryparam value="#EVALUATE('arguments.frmstruct.exportsteamShipLine#stpID#')#" cfsqltype="cf_sql_varchar">,
								<cfqueryparam value="#EVALUATE('arguments.frmstruct.exportDemurrageFreeTimeExpirationDate#stpID#')#" cfsqltype="cf_sql_date">,
								<cfqueryparam value="#EVALUATE('arguments.frmstruct.exportvesselName#stpID#')#" cfsqltype="cf_sql_varchar">,
								<cfqueryparam value="#EVALUATE('arguments.frmstruct.exportPerDiemFreeTimeExpirationDate#stpID#')#" cfsqltype="cf_sql_date">,
								<cfqueryparam value="#EVALUATE('arguments.frmstruct.exportVoyage#stpID#')#" cfsqltype="cf_sql_varchar">,
								<cfqueryparam value="#EVALUATE('arguments.frmstruct.exportEmptyPickupDate#stpID#')#" cfsqltype="cf_sql_date">,
								<cfqueryparam value="#EVALUATE('arguments.frmstruct.exportseal#stpID#')#" cfsqltype="cf_sql_varchar">,
								<cfqueryparam value="#EVALUATE('arguments.frmstruct.exportBooking#stpID#')#" cfsqltype="cf_sql_varchar">,
								<cfqueryparam value="#EVALUATE('arguments.frmstruct.exportScheduledLoadingDate#stpID#')#" cfsqltype="cf_sql_date">,
								<cfset exportScheduledLoadingTime = EVALUATE('arguments.frmstruct.exportScheduledLoadingTime#stpID#')>
								<cfqueryparam value="#EVALUATE('arguments.frmstruct.exportScheduledLoadingTime#stpID#')#" cfsqltype="cf_sql_varchar" null="#yesNoFormat(NOT len(exportScheduledLoadingTime))#">,
								<cfqueryparam value="#EVALUATE('arguments.frmstruct.exportVesselCutoffDate#stpID#')#" cfsqltype="cf_sql_date">,
								<cfqueryparam value="#EVALUATE('arguments.frmstruct.exportLoadingDate#stpID#')#" cfsqltype="cf_sql_date">,
								<cfqueryparam value="#EVALUATE('arguments.frmstruct.exportVesselLoadingWindow#stpID#')#" cfsqltype="cf_sql_varchar">,
								<cfqueryparam value="#EVALUATE('arguments.frmstruct.exportLoadingDelayDetectionStartDate#stpID#')#" cfsqltype="cf_sql_date">,
								<cfset exportLoadingDelayDetectionStartTime = EVALUATE('arguments.frmstruct.exportLoadingDelayDetectionStartTime#stpID#')>
								<cfqueryparam value="#EVALUATE('arguments.frmstruct.exportLoadingDelayDetectionStartTime#stpID#')#" cfsqltype="cf_sql_varchar" null="#yesNoFormat(NOT len(exportLoadingDelayDetectionStartTime))#">,
								<cfqueryparam value="#EVALUATE('arguments.frmstruct.exportRequestedLoadingDate#stpID#')#" cfsqltype="cf_sql_date">,
								<cfset exportRequestedLoadingTime = EVALUATE('arguments.frmstruct.exportRequestedLoadingTime#stpID#')>
								<cfqueryparam value="#EVALUATE('arguments.frmstruct.exportRequestedLoadingTime#stpID#')#" cfsqltype="cf_sql_varchar" null="#yesNoFormat(NOT len(exportRequestedLoadingTime))#">,
								<cfqueryparam value="#EVALUATE('arguments.frmstruct.exportLoadingDelayDetectionEndDate#stpID#')#" cfsqltype="cf_sql_date">,
								<cfset exportLoadingDelayDetectionEndTime = EVALUATE('arguments.frmstruct.exportLoadingDelayDetectionEndTime#stpID#')>
								<cfqueryparam value="#EVALUATE('arguments.frmstruct.exportLoadingDelayDetectionEndTime#stpID#')#" cfsqltype="cf_sql_varchar" null="#yesNoFormat(NOT len(exportLoadingDelayDetectionEndTime))#">,
								<cfqueryparam value="#EVALUATE('arguments.frmstruct.exportETS#stpID#')#" cfsqltype="cf_sql_date">,
								<cfqueryparam value="#EVALUATE('arguments.frmstruct.exportReturnDate#stpID#')#" cfsqltype="cf_sql_date">,
								<cfqueryparam value="#EVALUATE('arguments.frmstruct.exportEmptyPickupAddress#stpID#')#" cfsqltype="cf_sql_varchar">,
								<cfqueryparam value="#EVALUATE('arguments.frmstruct.exportLoadingAddress#stpID#')#" cfsqltype="cf_sql_varchar">,
								<cfqueryparam value="#EVALUATE('arguments.frmstruct.exportReturnAddress#stpID#')#" cfsqltype="cf_sql_varchar">
							)
					</cfquery>

					<cfinvoke method="getLoadStopAddress" tablename="LoadStopEmptyPickupAddress" address="#EVALUATE('arguments.frmstruct.exportEmptyPickUpAddress#stpID#')#" returnvariable="qLoadStopEmptyPickupAddressExists" />
					<cfif qLoadStopEmptyPickupAddressExists.recordcount>
						<cfquery name="qUpdateEmptyPickupAddress" datasource="#variables.dsn#">
							update
								LoadStopEmptyPickupAddress
							set
								address = <cfqueryparam value="#EVALUATE('arguments.frmstruct.exportEmptyPickUpAddress#stpID#')#" cfsqltype="cf_sql_varchar">,
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

					<cfinvoke method="getLoadStopAddress" tablename="LoadStopLoadingAddress" address="#EVALUATE('arguments.frmstruct.exportLoadingAddress#stpID#')#" returnvariable="qLoadStopLoadingAddressExists" />
					<cfif qLoadStopLoadingAddressExists.recordcount>
						<cfquery name="qUpdateLoadingAddress" datasource="#variables.dsn#">
							update
								LoadStopLoadingAddress
							set
								address = <cfqueryparam value="#EVALUATE('arguments.frmstruct.exportLoadingAddress#stpID#')#" cfsqltype="cf_sql_varchar">,
								LoadStopID = <cfqueryparam value="#lastInsertedStopId#" cfsqltype="cf_sql_varchar">,
								dateModified = <cfqueryparam value="#now()#" cfsqltype="cf_sql_date">
							where ID = <cfqueryparam value="#qLoadStopLoadingAddressExists.ID#" cfsqltype="cf_sql_integer">
						</cfquery>
					<cfelse>
						<cfquery name="qInsertLoadingAddress" datasource="#variables.dsn#">
							insert into LoadStopLoadingAddress
								(address, LoadStopID, dateAdded, dateModified)
							values
								(
									<cfqueryparam value="#EVALUATE('arguments.frmstruct.exportLoadingAddress#stpID#')#" cfsqltype="cf_sql_varchar">,
									<cfqueryparam value="#lastInsertedStopId#" cfsqltype="cf_sql_varchar">,
									<cfqueryparam value="#now()#" cfsqltype="cf_sql_date">,
									<cfqueryparam value="#now()#" cfsqltype="cf_sql_date">
								)
						</cfquery>
					</cfif>
					<cfinvoke method="getLoadStopAddress" tablename="LoadStopReturnAddress" address="#EVALUATE('arguments.frmstruct.exportReturnAddress#stpID#')#" returnvariable="qLoadStopReturnAddressExists" />
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
				<cfloop from="1" to="#val(evaluate("arguments.frmstruct.totalResult#stpID#"))#" index="Num">
					<cfif structKeyExists(arguments.frmstruct, "qty#stpID#_#num#")>
						<cfset qty=evaluate("arguments.frmstruct.qty#stpID#_#num#")>
						<cfset unit=evaluate("arguments.frmstruct.unit#stpID#_#num#")>
						<cfset description=evaluate("arguments.frmstruct.description#stpID#_#num#")>
						<cfset dimensions=evaluate("arguments.frmstruct.dimensions#stpID#_#num#")>
						<cfif isdefined("arguments.frmstruct.weight#stpID#_#num#")>
							<cfset weight=VAL(replaceNoCase(evaluate("arguments.frmstruct.weight#stpID#_#num#"), ",", "","ALL"))>
						<cfelse>
							<cfset weight=0>
						</cfif>
						<cfset class=evaluate("arguments.frmstruct.class#stpID#_#num#")>
						<cfset CustomerRate=evaluate("arguments.frmstruct.CustomerRate#stpID#_#num#")>
						<cfset CustomerRate = replace( replace( CustomerRate,"$","","ALL"),",","","ALL") >
						<cfset CarrierRate=evaluate("arguments.frmstruct.CarrierRate#stpID#_#num#")>
						<cfset CarrierRate = replace( replace( CarrierRate,"$","","ALL"),",","","ALL") >
						<cfset CustomerRate = replace( replace( CustomerRate,"(","","ALL"),")","","ALL") >
 						<cfset CarrierRate = replace( replace( CarrierRate,"(","","ALL"),")","","ALL") >
						<cfif structKeyExists(arguments.frmstruct, "custCharges#stpID#_#num#")>
							<cfset custCharges=evaluate("arguments.frmstruct.custCharges#stpID#_#num#")>
							<cfset custCharges = replace( replace( custCharges,"$","","ALL"),",","","ALL") >
						<cfelse>
							<cfset custCharges = 0 >
						</cfif>
						<cfif structKeyExists(arguments.frmstruct, "carrCharges#stpID#_#num#")>
							<cfset carrCharges=evaluate("arguments.frmstruct.carrCharges#stpID#_#num#")>
							<cfset carrCharges = replace( replace( carrCharges,"$","","ALL"),",","","ALL") >
						<cfelse>
							<cfset carrCharges = 0 >
						</cfif>
						<cfset CarrRateOfCustTotal=evaluate("arguments.frmstruct.CarrierPer#stpID#_#num#")>
						<cfset CarrRateOfCustTotal = replace( CarrRateOfCustTotal,"%","","ALL") >
						<cfif not IsNumeric(CarrRateOfCustTotal)>
							<cfset CarrRateOfCustTotal = 0>
						</cfif>
						<cfif isdefined('arguments.frmstruct.isFee#stpID#_#num#')>
							<cfset isFee=true>
						<cfelse>
							<cfset isFee=false>
						</cfif>
						<cfif not len(trim(CustomerRate))>
							<cfset CustomerRate="0.00">
				 		</cfif>

						 <cfif not len(trim(CarrierRate))>
							<cfset CarrierRate="0.00">
						 </cfif>
						<cfif isDefined("arguments.frmstruct.directCost#stpID#_#num#")>
							<cfset directCost =evaluate("arguments.frmstruct.directCost#stpID#_#num#")>
						<cfelse>
							<cfset directCost =0>
						</cfif>
						 <cfset directCost = replace( replace( directCost,"$","","ALL"),",","","ALL") >
						 <cfif isDefined("arguments.frmstruct.directCostTotal#stpID#_#num#")>
						 	<cfset directCostTotal =evaluate("arguments.frmstruct.directCostTotal#stpID#_#num#")>
						 <cfelse>
						 	<cfset directCostTotal = 0>
						 </cfif>
						 <cfset directCostTotal = replace( replace( directCostTotal,"$","","ALL"),",","","ALL")>
						 <cfif not len(trim(directCost))><cfset directCost=0.00></cfif>
						 <cfif not len(trim(directCostTotal))><cfset directCostTotal=0.00></cfif>

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
							<CFPROCPARAM VALUE="#CarrRateOfCustTotal#" cfsqltype="CF_SQL_VARCHAR">
							<CFPROCPARAM VALUE="#isFee#" cfsqltype="CF_SQL_VARCHAR">
							<CFPROCPARAM VALUE="#val(directCost)#" cfsqltype="cf_sql_money">
							<CFPROCPARAM VALUE="#val(directCostTotal)#" cfsqltype="cf_sql_money">
							<CFPROCPARAM VALUE="#dimensions#" cfsqltype="CF_SQL_VARCHAR">
							<CFPROCRESULT NAME="qInsertedLoadItem">
						</CFSTOREDPROC>
					</cfif>
				</cfloop>
			</cfloop>
		</cfif>
		<cfset Msg0='1'> <cfset Msg1='1'><cfset msg2 ='1'>
		
		<!-------posteverywhere webservice calll---->
		<cfset Msg0 = postToPEPLoadAdd(arguments.frmstruct,impref,LastLoadId)>
	  	<!-------posteverywhere webservice calll---->
		
		<!-----Begin : DirectFreight Integration-------->
		<cfset MsgDF=postToDirectFrieghtLoadAdd(arguments.frmstruct,impref,LastLoadId)>
		<!-----End : DirectFreight Integration-------->

		<!-----Transcore 360 Webservice Call-------->
		<cfset msg1=postToTranscoreLoadAdd(arguments.frmstruct,impref,LastLoadId)> 
		<!-----Transcore 360 Webservice Call-------->

		<!--- BEGIN: ITS Webservice Integration --->
		<cfset ITS_msg=postToITSLoadAdd(arguments.frmstruct,impref,LastLoadId)> 
		<!--- END: ITS Webservice Integration --->

		<!--- BEGIN: 123 Loadboard Webservice Integration --->
		<cfset msg2=postTo123LoadBoardLoadAdd(arguments.frmstruct,impref,LastLoadId)> 
		<!--- END: 123 Loadboard Webservice Integration --->
		
		<!--- insert LoadIFTAMiles table start --->
		<cfset l.promilesRes = getResponsePromiles(arguments.frmstruct,loadManualNo)>

		<cfset Msg0='#LastLoadId#'&'~~'&'#Msg0#'&'~~'&'#Msg1#'&'~~'&ITS_msg&'~~'&msg2&'~~'&l.promilesRes & '~~' & MsgDF>

		<cfif structKeyExists(arguments.frmstruct,"MinimumMarginReached") AND arguments.frmstruct.MinimumMarginReached EQ 0 AND request.qSystemSetupOptions.MinMarginOverrideApproval EQ 1>
			<cfinvoke component="#variables.objAlertGateway#" method="createAlert" CreatedBy="#session.EmpID#" CompanyID="#session.CompanyID#" Description="Load Margin Override" AssignedType="Role" AssignedTo="Administrator" Type="Load" TypeId="#LastLoadId#" Reference="#loadManualNo#" />

		</cfif>
		<cfreturn Msg0>
		<cfcatch>
			<cfset var template = "">
			<cfset var companycode ="">
			<cfset var sourcepage = "">
			<cfset var errordetail = "">
			<cfif structKeyExists(cfcatch, "TagContext") AND isArray(cfcatch.TagContext) AND NOT arrayIsEmpty(cfcatch.TagContext) AND isstruct(cfcatch.TagContext[1]) AND structKeyExists(cfcatch.TagContext[1], "raw_trace")>
				<cfset template = cfcatch.TagContext[1].raw_trace>
			</cfif>
			
			<cfif structKeyExists(session, "usercompanycode")>
				<cfset companycode ="["&session.usercompanycode&"]">
			</cfif>
			
			<cfif isDefined("cgi.HTTP_REFERER")>
				<cfset sourcepage = "#chr(10)#[Sourcepage]:#cgi.HTTP_REFERER#">
			</cfif>

			<cfif isDefined('cfcatch.cause.Detail') and isDefined('cfcatch.cause.Message')>
				<cfset errordetail = "#cfcatch.cause.Detail##cfcatch.cause.Message#">
			<cfelseif isDefined('cfcatch.Message') >
				<cfset errordetail = "#cfcatch.Message#">
			</cfif>

			<cffile action="append" file="#ExpandPath("../webroot/logs")#/Application.Log.txt" output="#dateTimeFormat(now())##chr(10)##companycode##errordetail##chr(10)#[FormData]:#SerializeJSON(form)##chr(10)#[ArgumentData]:#SerializeJSON(arguments)##sourcepage##trim(template)#">

			<cfquery name="qInsLog" datasource="LoadManagerAdmin">
       			INSERT INTO LMErrorLog (CompanyCode,Detail,Status,FormData,URLData,Template,SourcePage)
       			VALUES (
       				<cfif structKeyExists(session, "usercompanycode")>
       					<cfqueryparam value="#session.usercompanycode#" cfsqltype="cf_sql_varchar">
       				<cfelse>
       					NULL
       				</cfif>
       				,<cfqueryparam value="#errordetail#" cfsqltype="cf_sql_varchar">
       				,'Pending'
       				<cfif isDefined("form")>
       					,<cfqueryparam value="#SerializeJSON(form)#" cfsqltype="cf_sql_varchar">
       				<cfelse>
       					,NULL
       				</cfif>
       				,<cfqueryparam value="#SerializeJSON(url)#" cfsqltype="cf_sql_varchar">
       				,<cfqueryparam value="#Template#" cfsqltype="cf_sql_varchar">
       				<cfif isDefined("cgi.HTTP_REFERER")>
       					,<cfqueryparam value="#cgi.HTTP_REFERER#" cfsqltype="cf_sql_varchar">
       				<cfelse>
       					,NULL
       				</cfif>
       				)
       		</cfquery>
       		<cfif isDefined("LastLoadId") and len(trim(LastLoadId))>
				<cfinvoke method="deleteLoad" loadid="#LastLoadId#" returnvariable="delMessage" />
			</cfif>
			<cfoutput>
       			<h3>We have encountered an error, please try again soon or call us at 631-724-9400.</h3>
       			<cfinclude template="../webroot/ErrorReport.cfm"/>
       		</cfoutput>
			<cfabort>
		</cfcatch>
	</cftry>
</cffunction>

<cffunction name="getResponsePromiles" access="public" returntype="any">
	<cfargument name="frmstruct" type="struct" required="yes">
	<cfargument name="loadManualNo" type="string" required="yes">
	<cfset variables.promilesRes=1>
	<cfif structKeyExists(session,"empid") AND getLoadStatusText(arguments.frmstruct.loadStatus) EQ '5. DELIVERED'>
		<cfquery name="getProMileDetails" datasource="#Application.dsn#">
			select proMilesStatus from systemconfig
			where CompanyID=<cfqueryparam cfsqltype="cf_sql_varchar" value="#session.CompanyID#">
		</cfquery>
		<cfinvoke method="getSystemSetupOptions" returnvariable="request.qSystemSetupOptions">
		<cfif request.qSystemSetupOptions.googlemapspcmiler EQ 1 AND getProMileDetails.proMilesStatus>
			<cfset arguments.frmstruct.loadnumber = loadManualNo>
			<cfset responsePromiles=1>

			<cfif arguments.frmstruct.loadStatus neq "">
				<cfquery name="qryGetStatusText" datasource="#Application.dsn#">
					select CAST(left( lst.StatusText, charindex(' ',  lst.StatusText) - 1) AS float)  as statustext from loads ld
					left join LoadStatusTypes  lst on ld.StatusTypeID=lst.StatusTypeID
					where lst.StatusTypeID =<cfqueryparam value="#arguments.frmstruct.loadStatus#" cfsqltype="cf_sql_varchar">
					and ld.loadnumber=<cfqueryparam value="#arguments.frmstruct.loadnumber#" cfsqltype="cf_sql_bigint">
					and IsNumeric(left(lst.StatusText, charindex(' ', lst.StatusText) - 1)) = 1 AND lst.StatusText IS NOT NULL  and left(lst.StatusText, charindex(' ', lst.StatusText) - 1) !='.'
					GROUP BY lst.StatusText
				</cfquery>
				<cfset variables.counter=1>
				<!--- Create a new three-column query, specifying the column data types --->
				<cfset qryGetStatusTextNumbersSet = QueryNew("statusNumberText","Double")>
				<!--- Make two rows in the query --->
				<cfif qryGetStatusText.recordcount>
					<cfset QueryAddRow(qryGetStatusTextNumbersSet, qryGetStatusText.recordcount)>
				<cfelse>
					<cfset QueryAddRow(qryGetStatusTextNumbersSet, 1)>
				</cfif>
				<!--- Set the values of the cells in the query --->
				<cfif qryGetStatusText.recordcount>
					<cfloop query="qryGetStatusText">
						<cfset QuerySetCell(qryGetStatusTextNumbersSet, "statusNumberText", "#qryGetStatusText.statustext#",variables.counter)>
						<cfset variables.counter++>
					</cfloop>
				<cfelse>
					<cfset QuerySetCell(qryGetStatusTextNumbersSet, "statusNumberText", "0",1)>
				</cfif>
				<cfquery dbtype="query" name="qryGetStatusTextNumbersExtactMain">
					select statusNumberText from qryGetStatusTextNumbersSet where statusNumberText between 1 and 8.9
				</cfquery>
			</cfif>
			<cfquery name="qryGetStatusNumbers" datasource="#application.dsn#">
				SELECT CAST(left(statustext, charindex(' ', statustext) - 1) AS float)  as statustext
				FROM LoadStatusTypes
				WHERE IsNumeric(left(statustext, charindex(' ', statustext) - 1)) = 1 AND statustext IS NOT NULL  and left(statustext, charindex(' ', statustext) - 1) !='.'
				AND CompanyID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#session.companyid#">
				GROUP BY statustext
			</cfquery>
			<cfset variables.count=1>
			<!--- Create a new three-column query, specifying the column data types --->
			<cfset qryGetStatusTextNumbers = QueryNew("statusNumber","Double")>
			<!--- Make two rows in the query --->
			<cfset QueryAddRow(qryGetStatusTextNumbers, qryGetStatusNumbers.recordcount)>
			<!--- Set the values of the cells in the query --->
			<cfif qryGetStatusNumbers.recordcount>
				<cfloop query="qryGetStatusNumbers">
					<cfset QuerySetCell(qryGetStatusTextNumbers, "statusNumber", "#qryGetStatusNumbers.statustext#",variables.count)>
					<cfset variables.count++>
				</cfloop>
			</cfif>
			<cfquery dbtype="query" name="qryGetStatusTextNumbersExtact">
				select statusNumber from qryGetStatusTextNumbers where statusNumber between 1 and 8.9
			</cfquery>
			<cfset variables.statuslist = "">
			<cfloop query="qryGetStatusTextNumbersExtact">
				<cfset variables.statuslist = ListAppend(variables.statuslist, val(qryGetStatusTextNumbersExtact.statusNumber), ",")>
			</cfloop>

			<cfif ListFindNoCase(variables.statuslist,qryGetStatusTextNumbersExtactMain.statusNumberText)>
				<cfinvoke component="#variables.objPromilesGatewayTest#" method="promilesCalculation" frmstruct="#arguments.frmstruct#" returnvariable="responsePromiles"/>
			</cfif>
			<cfset variables.promilesRes=responsePromiles>
		</cfif>
	</cfif>
	<cfreturn variables.promilesRes>
</cffunction>

<cffunction name="getLoadStopAddress" access="public" returntype="query">
	<cfargument name="tablename" default="0">
	<cfargument name="address" default="0">
	<cfquery name="qLoadStopEmptyPickupAddressExists" datasource="#variables.dsn#">
		SELECT ID FROM #arguments.tablename#
		WHERE address = <cfqueryparam value="#arguments.address#" cfsqltype="cf_sql_varchar">
	</cfquery>
	<cfreturn qLoadStopEmptyPickupAddressExists>
</cffunction>

<cffunction name="getLoadStatusText" access="public" returntype="any">
	<cfargument name="loadStatus" type="string" required="yes">
	<cfquery name="getLoadStatus" datasource="#Application.dsn#">
		select statustext from LoadStatusTypes
		where StatusTypeID=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.loadStatus#">
	</cfquery>
	<cfreturn getLoadStatus.statustext>
</cffunction>
<!--- Get Load Status--->
	<cffunction name="getLoadStatusAdd" access="public" returntype="query">
		<cfargument name="LoadStatusID" required="No" type="any">
		<CFSTOREDPROC PROCEDURE="USP_GetStatus" DATASOURCE="#variables.dsn#">
			<cfif isdefined('arguments.LoadStatusID') and len(arguments.LoadStatusID)>
		 	<CFPROCPARAM VALUE="#arguments.LoadStatusID#" cfsqltype="CF_SQL_VARCHAR">
		 <cfelse>
		 	<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR">
		 </cfif>
		 <CFPROCPARAM VALUE="#session.CompanyID#" cfsqltype="CF_SQL_VARCHAR">
		<CFPROCRESULT NAME="qrygetstatus">
		</CFSTOREDPROC>
	    <cfreturn qrygetstatus>
	</cffunction>

	<cffunction name="postToDirectFrieghtLoadAdd" access="public" returntype="any">
		<cfargument name="frmstruct" type="struct" required="yes">
		<cfargument name="impref" type="string" required="yes">
		<cfargument name="LastLoadId" type="string" required="yes">
		<cfset MsgDF=1>
		<cfif structKeyExists(arguments.frmstruct,"IntegrateWithDirectFreightLoadboard") and  arguments.frmstruct.IntegrateWithDirectFreightLoadboard EQ 1 AND structKeyExists(arguments.frmstruct,"posttoDirectFreight")>

			<cfif structKeyExists(arguments.frmstruct,"loadDirectFreightPost") AND arguments.frmstruct.loadDirectFreightPost EQ 1>
				<cfset p_method = 'PATCH'>
			<cfelse>
				<cfset p_method = 'POST'>
			</cfif>
			
			<cfif NOT StructKeyExists(arguments.frmstruct,"postCarrierRatetoDirectFreight")>
				<cfset IncludeCarierRate = 0>
			<cfelse>
				<cfset IncludeCarierRate = arguments.frmstruct.postCarrierRatetoDirectFreight >
			</cfif>

			<cfinvoke method="DirectFreightLoadboard" impref="#arguments.impref#" LoadID='#arguments.LastLoadId#' DirectFreightLoadboardUserName="#arguments.frmstruct.DirectFreightLoadboardUserName#" DirectFreightLoadboardPassword="#arguments.frmstruct.DirectFreightLoadboardPassword#" POSTMETHOD="#p_method#"  IncludeCarierRate="#IncludeCarierRate#" CARRIERRATE="#arguments.frmstruct.CARRIERRATE#" returnvariable="request.DirectFreightLoadboard" />

			<cfset MsgDF=#request.DirectFreightLoadboard#>
		<cfelseif structKeyExists(arguments.frmstruct,"IntegrateWithDirectFreightLoadboard") and  arguments.frmstruct.IntegrateWithDirectFreightLoadboard EQ 1  AND arguments.frmstruct.loadDirectFreightPost EQ 1 AND NOT structKeyExists(arguments.frmstruct,"posttoDirectFreight")>
			<cfinvoke method="DirectFreightLoadboard" impref="#arguments.impref#" LoadID='#arguments.LastLoadId#'  DirectFreightLoadboardUserName="#arguments.frmstruct.DirectFreightLoadboardUserName#" DirectFreightLoadboardPassword="#arguments.frmstruct.DirectFreightLoadboardPassword#" POSTMETHOD="DEL"  returnvariable="request.DirectFreightLoadboard" />

			<cfset MsgDF=#request.DirectFreightLoadboard#>
		</cfif>
		<cfif NOT structKeyExists(arguments.frmstruct,"IntegrateWithDirectFreightLoadboard") AND structKeyExists(arguments.frmstruct,"posttoDirectFreight")>
			<cfset MsgDF="There is a problem in logging to Direct Freight Loadboard">
		</cfif>
		<cfreturn MsgDF>
	</cffunction>

	<cffunction name="postToPEPLoadAdd" access="public" returntype="any">
		<cfargument name="frmstruct" type="struct" required="yes">
		<cfargument name="impref" type="string" required="yes">
		<cfargument name="LastLoadId" type="string" required="yes">
		<cfset Msg0='1'>
		<cfif  structKeyExists(arguments.frmstruct,"integratewithPEP") and  #arguments.frmstruct.integratewithPEP# eq 1 and structKeyExists(arguments.frmstruct,"posttoloadboard")>

			<cfquery name="qryGetStatus" datasource="#variables.dsn#">
				select StatusText from LoadStatusTypes where StatusTypeID='#arguments.frmstruct.loadstatus#'
			</cfquery>

			<cfif qryGetStatus.StatusText eq "9. Cancelled">
				<cfset p_action='D'>
			<cfelse>
				<cfset p_action='A'>
			</cfif>
			<cfif NOT StructKeyExists(arguments.frmstruct,"postCarrierRatetoTranscore")>
				<cfset IncludeCarierRate = 0>
			<cfelse>
				<cfset IncludeCarierRate = arguments.frmstruct.postCarrierRatetoTranscore >
			</cfif>
			<cfinvoke method="Posteverywhere" LoadID="#arguments.LastLoadId#" impref="#arguments.impref#" PEPcustomerKey="#arguments.frmstruct.PEPcustomerKey#" PEPsecretKey="#arguments.frmstruct.PEPsecretKey#" POSTACTION="#p_action#"  CARRIERRATE = "#arguments.frmstruct.CARRIERRATE#"  IncludeCarierRate="#IncludeCarierRate#" returnvariable="request.postevrywhere" />
			<cfset Msg0=request.postevrywhere>
		</cfif>
		<cfreturn Msg0>
	</cffunction>

	<cffunction name="postToTranscoreLoadAdd" access="public" returntype="any">
		<cfargument name="frmstruct" type="struct" required="yes">
		<cfargument name="impref" type="string" required="yes">
		<cfargument name="LastLoadId" type="string" required="yes">
		<cfset Msg1='1'>
		<cfif  structKeyExists(arguments.frmstruct,"integratewithTran360") and  #arguments.frmstruct.integratewithTran360# eq 1 and structKeyExists(arguments.frmstruct,"posttoTranscore")>
			<cfset p_action='A'>
			<!--- END: Trans360 webservice changes Date:23 Sep 2013 --->
			<cfif NOT StructKeyExists(arguments.frmstruct,"postCarrierRatetoTranscore")>
				<cfset IncludeCarierRate = 0>
			<cfelse>
				<cfset IncludeCarierRate = arguments.frmstruct.postCarrierRatetoTranscore >
			</cfif>
			<cfinvoke method="Transcore360Webservice" LoadID='#arguments.LastLoadId#' impref="#arguments.impref#" trans360Usename="#arguments.frmstruct.trans360Usename#" trans360Password="#arguments.frmstruct.trans360Password#" POSTACTION="#p_action#" IncludeCarierRate="#IncludeCarierRate#"  CARRIERRATE="#arguments.frmstruct.CARRIERRATE#"    returnvariable="request.Transcore360Webservice" />		
			<cfset Msg1=request.Transcore360Webservice>
		</cfif>
		<cfif NOT structKeyExists(arguments.frmstruct,"integratewithTran360") AND structKeyExists(arguments.frmstruct,"posttoTranscore")>
			<cfset msg1 = "There is a problem in logging to Dat Loadboard">
		</cfif>
		<cfreturn Msg1>
	</cffunction>

	<cffunction name="postToITSLoadAdd" access="public" returntype="any">
		<cfargument name="frmstruct" type="struct" required="yes">
		<cfargument name="impref" type="string" required="yes">
		<cfargument name="LastLoadId" type="string" required="yes">
		<cfset ITS_msg =1>
		<cfif structKeyExists(arguments.frmstruct,"integratewithITS") and  arguments.frmstruct.integratewithITS EQ 1 AND structKeyExists(arguments.frmstruct,"posttoITS")>
			<cfset p_action = 'A'>
			<cfif NOT StructKeyExists(arguments.frmstruct,"postCarrierRatetoITS")>
				<cfset IncludeCarierRate = 0>
			<cfelse>
				<cfset IncludeCarierRate = arguments.frmstruct.postCarrierRatetoITS >
			</cfif>			
			<cfset ITS_msg = ITSWebservice(arguments.impref, p_action, arguments.frmstruct.ITSUsername, arguments.frmstruct.ITSPassword, arguments.frmstruct.ITSIntegrationID,arguments.impref,arguments.LastLoadId,session.CompanyID,application.dsn,session.empid,IncludeCarierRate,arguments.frmstruct.CARRIERRATE)>
		</cfif>
		<cfreturn ITS_msg>
	</cffunction>

	<cffunction name="postTo123LoadBoardLoadAdd" access="public" returntype="any">
		<cfargument name="frmstruct" type="struct" required="yes">
		<cfargument name="impref" type="string" required="yes">
		<cfargument name="LastLoadId" type="string" required="yes">
		<cfset msg2 = 1>
		<!--- Validation for Unauthorised users try to update on Transcore --->
		<cfif NOT structKeyExists(arguments.frmstruct,"loadBoard123") AND structKeyExists(arguments.frmstruct,"PostTo123LoadBoard")>
			<cfset msg2 = "There is a problem in logging to 123loadBoard">
		</cfif>
	
		<cfif structKeyExists(arguments.frmstruct,"loadBoard123") and  arguments.frmstruct.loadBoard123 EQ 1 AND structKeyExists(arguments.frmstruct,"PostTo123LoadBoard")>
			<cfset p_action = 'A'>
			<cfset variables.postProviderid='LMGR428AP'>
			<cfif NOT StructKeyExists(arguments.frmstruct,"postCarrierRateto123LoadBoard")>
				<cfset IncludeCarierRate = 0>
			<cfelse>
				<cfset IncludeCarierRate = arguments.frmstruct.postCarrierRateto123LoadBoard >
			</cfif>
			<cfset variables.postingLoad = postTo123LoadBoardWebservice(p_action,variables.postProviderid,arguments.frmstruct.loadBoard123Username, arguments.frmstruct.loadBoard123Password,arguments.impref,arguments.frmstruct.appDsn,arguments.frmstruct.CARRIERRATE,IncludeCarierRate,arguments.LastLoadId)>
			<cfset msg2 = variables.postingLoad>
		</cfif>
		<cfreturn msg2>
	</cffunction>

	<cffunction name="insertShipperStopLoadAdd" access="public" returntype="any">
    	<cfargument name="LastLoadId" type="string" required="yes">
    	<cfargument name="lastUpdatedShipCustomerID" type="string" required="yes">
    	<cfargument name="ShipBlind" type="string" required="yes">
    	<cfargument name="noOfDays1" type="string" required="yes">
		<cfargument name="frmstruct" type="struct" required="yes">

		<CFSTOREDPROC PROCEDURE="USP_InsertLoadStop" DATASOURCE="#variables.dsn#">
			<CFPROCPARAM VALUE="#arguments.LastLoadId#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="True" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="True" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#arguments.frmstruct.BookedWith#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#arguments.frmstruct.equipment#" cfsqltype="CF_SQL_VARCHAR">
			<cfif isdefined('arguments.frmstruct.driver') and len(arguments.frmstruct.driver)>
				<CFPROCPARAM VALUE="#arguments.frmstruct.driver#" cfsqltype="CF_SQL_VARCHAR">
			<cfelse>
				<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR"  null="Yes">	
			</cfif>
			<CFPROCPARAM VALUE="#arguments.frmstruct.drivercell#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#arguments.frmstruct.truckNo#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#arguments.frmstruct.trailerNo#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#arguments.frmstruct.refNo#" cfsqltype="CF_SQL_VARCHAR">
			<cfif isNumeric(arguments.frmstruct.milse)>
				<CFPROCPARAM VALUE="#arguments.frmstruct.milse#" cfsqltype="cf_sql_float">
			<cfelse>
				<CFPROCPARAM VALUE="0" cfsqltype="cf_sql_float">
			</cfif>
			<CFPROCPARAM VALUE="#arguments.frmstruct.carrierid#" cfsqltype="CF_SQL_VARCHAR">
			<cfif structKeyExists(arguments.frmstruct, "stOffice") AND len(arguments.frmstruct.stOffice) gt 1>
				<CFPROCPARAM VALUE="#arguments.frmstruct.stOffice#" cfsqltype="CF_SQL_VARCHAR">
			<cfelse>
				<CFPROCPARAM VALUE="Null" cfsqltype="CF_SQL_VARCHAR">
			</cfif>
			<CFPROCPARAM VALUE="#arguments.frmstruct.shipperPickupNO1#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#arguments.frmstruct.shipperPickupDate#" cfsqltype="CF_SQL_dATE"  null="#yesNoFormat(NOT len(arguments.frmstruct.shipperPickupDate))#">
			<CFPROCPARAM VALUE="#arguments.frmstruct.shipperPickupTime#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#arguments.frmstruct.shipperTimeIn#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#arguments.frmstruct.shipperTimeOut#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#session.adminUserName#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#arguments.lastUpdatedShipCustomerID#" cfsqltype="CF_SQL_VARCHAR" null="#yesNoFormat(NOT len(arguments.lastUpdatedShipCustomerID))#">
			<CFPROCPARAM VALUE="#arguments.ShipBlind#" cfsqltype="CF_SQL_BIT">
			<CFPROCPARAM VALUE="#arguments.frmstruct.shipperNotes#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#arguments.frmstruct.shipperDirection#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="1" cfsqltype="CF_SQL_INTEGER">
			<CFPROCPARAM VALUE="#arguments.frmstruct.shipperlocation#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#arguments.frmstruct.shipperCity#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#arguments.frmstruct.shipperStateName#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#arguments.frmstruct.shipperZipCode#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#arguments.frmstruct.shipperContactPerson#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#arguments.frmstruct.shipperPhone#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#arguments.frmstruct.shipperPhoneExt#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#arguments.frmstruct.shipperFax#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#arguments.frmstruct.shipperEmail#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#arguments.frmstruct.shipperName#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#arguments.frmstruct.userDef1#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#arguments.frmstruct.userDef2#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#arguments.frmstruct.userDef3#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#arguments.frmstruct.userDef4#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#arguments.frmstruct.userDef5#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#arguments.frmstruct.userDef6#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="0" cfsqltype="CF_SQL_INTEGER">
			<CFPROCPARAM VALUE="#arguments.noOfDays1#" cfsqltype="CF_SQL_INTEGER" null="#yesNoFormat(NOT len(arguments.noOfDays1))#">
			<cfif isdefined('arguments.frmstruct.Secdriver') and len(arguments.frmstruct.Secdriver)>
				<CFPROCPARAM VALUE="#arguments.frmstruct.Secdriver#" cfsqltype="CF_SQL_VARCHAR">
			<cfelse>
				<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR"  null="Yes">	
			</cfif>
			<CFPROCPARAM VALUE="#arguments.frmstruct.secDriverCell#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#arguments.frmstruct.temperature#" cfsqltype="CF_SQL_VARCHAR" null="#yesNoFormat(NOT len(arguments.frmstruct.temperature))#">
			<CFPROCPARAM VALUE="#arguments.frmstruct.temperaturescale#" cfsqltype="CF_SQL_VARCHAR">
			<cfif isdefined('arguments.frmstruct.shipperTimeZone') and len(arguments.frmstruct.shipperTimeZone)>
				<CFPROCPARAM VALUE="#arguments.frmstruct.shipperTimeZone#"  cfsqltype="CF_SQL_VARCHAR">
			<cfelse>
				<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR"  null="Yes">	
			</cfif>
			<cfif isdefined('arguments.frmstruct.CarrierEmailID') and len(arguments.frmstruct.CarrierEmailID)>
				<CFPROCPARAM VALUE="#arguments.frmstruct.CarrierEmailID#"  cfsqltype="CF_SQL_VARCHAR">
			<cfelse>
				<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR"  null="Yes">	
			</cfif>
			<cfif isdefined('arguments.frmstruct.shipperPickupDateMultiple') and len(arguments.frmstruct.shipperPickupDateMultiple)>
				<CFPROCPARAM VALUE="#arguments.frmstruct.shipperPickupDateMultiple#"  cfsqltype="CF_SQL_VARCHAR">
			<cfelse>
				<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR"  null="Yes">	
			</cfif>

			<cfif isdefined('arguments.frmstruct.carrierID2_1') and len(arguments.frmstruct.carrierID2_1)>
				<CFPROCPARAM VALUE="#arguments.frmstruct.carrierID2_1#"  cfsqltype="CF_SQL_VARCHAR">
			<cfelse>
				<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR"  null="Yes">	
			</cfif>

			<cfif isdefined('arguments.frmstruct.carrierID3_1') and len(arguments.frmstruct.carrierID3_1)>
				<CFPROCPARAM VALUE="#arguments.frmstruct.carrierID3_1#"  cfsqltype="CF_SQL_VARCHAR">
			<cfelse>
				<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR"  null="Yes">	
			</cfif>

			<cfif isdefined('arguments.frmstruct.thirdDriverCell') and len(arguments.frmstruct.thirdDriverCell)>
				<CFPROCPARAM VALUE="#arguments.frmstruct.thirdDriverCell#"  cfsqltype="CF_SQL_VARCHAR">
			<cfelse>
				<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR"  null="Yes">	
			</cfif>
			<cfif structKeyExists(arguments.frmstruct, "customDriverPayFlatRate") AND IsNumeric(arguments.frmstruct.customDriverPayFlatRate)>
				<CFPROCPARAM VALUE="#arguments.frmstruct.customDriverPayFlatRate#"  cfsqltype="CF_SQL_FLOAT">
			<cfelse>
				<CFPROCPARAM VALUE="0"  cfsqltype="CF_SQL_FLOAT">
			</cfif>
			<cfif structKeyExists(arguments.frmstruct, "customDriverPayFlatRate2_1") AND IsNumeric(arguments.frmstruct.customDriverPayFlatRate2_1)>
				<CFPROCPARAM VALUE="#arguments.frmstruct.customDriverPayFlatRate2_1#"  cfsqltype="CF_SQL_FLOAT">
			<cfelse>
				<CFPROCPARAM VALUE="0"  cfsqltype="CF_SQL_FLOAT">
			</cfif>
			<cfif structKeyExists(arguments.frmstruct, "customDriverPayFlatRate3_1") AND IsNumeric(arguments.frmstruct.customDriverPayFlatRate3_1)>
				<CFPROCPARAM VALUE="#arguments.frmstruct.customDriverPayFlatRate3_1#"  cfsqltype="CF_SQL_FLOAT">
			<cfelse>
				<CFPROCPARAM VALUE="0"  cfsqltype="CF_SQL_FLOAT">
			</cfif>
			<cfif structKeyExists(arguments.frmstruct, "customDriverPayPercentage") AND IsNumeric(arguments.frmstruct.customDriverPayPercentage)>
				<CFPROCPARAM VALUE="#arguments.frmstruct.customDriverPayPercentage#"  cfsqltype="CF_SQL_FLOAT">
			<cfelse>
				<CFPROCPARAM VALUE="0"  cfsqltype="CF_SQL_FLOAT">
			</cfif>
			<cfif structKeyExists(arguments.frmstruct, "customDriverPayPercentage2_1") AND IsNumeric(arguments.frmstruct.customDriverPayPercentage2_1)>
				<CFPROCPARAM VALUE="#arguments.frmstruct.customDriverPayPercentage2_1#"  cfsqltype="CF_SQL_FLOAT">
			<cfelse>
				<CFPROCPARAM VALUE="0"  cfsqltype="CF_SQL_FLOAT">
			</cfif>
			<cfif structKeyExists(arguments.frmstruct, "customDriverPayPercentage3_1") AND IsNumeric(arguments.frmstruct.customDriverPayPercentage3_1)>
				<CFPROCPARAM VALUE="#arguments.frmstruct.customDriverPayPercentage3_1#"  cfsqltype="CF_SQL_FLOAT">
			<cfelse>
				<CFPROCPARAM VALUE="0"  cfsqltype="CF_SQL_FLOAT">
			</cfif>

			<cfif structKeyExists(arguments.frmstruct, "chkCustomDriverPayFlatRate")>
				<CFPROCPARAM VALUE="1"  cfsqltype="CF_SQL_INTEGER">
			<cfelseif structKeyExists(arguments.frmstruct, "chkCustomDriverPayPercentage")>
				<CFPROCPARAM VALUE="2"  cfsqltype="CF_SQL_INTEGER">
			<cfelse>
				<CFPROCPARAM VALUE="0"  cfsqltype="CF_SQL_INTEGER">
			</cfif>
			<cfif structKeyExists(arguments.frmstruct, "chkCustomDriverPayFlatRate2_1")>
				<CFPROCPARAM VALUE="1"  cfsqltype="CF_SQL_INTEGER">
			<cfelseif structKeyExists(arguments.frmstruct, "chkCustomDriverPayPercentage2_1")>
				<CFPROCPARAM VALUE="2"  cfsqltype="CF_SQL_INTEGER">
			<cfelse>
				<CFPROCPARAM VALUE="0"  cfsqltype="CF_SQL_INTEGER">
			</cfif>
			<cfif structKeyExists(arguments.frmstruct, "chkCustomDriverPayFlatRate3_1")>
				<CFPROCPARAM VALUE="1"  cfsqltype="CF_SQL_INTEGER">
			<cfelseif structKeyExists(arguments.frmstruct, "chkCustomDriverPayPercentage3_1")>
				<CFPROCPARAM VALUE="2"  cfsqltype="CF_SQL_INTEGER">
			<cfelse>
				<CFPROCPARAM VALUE="0"  cfsqltype="CF_SQL_INTEGER">
			</cfif>
			<cfif structKeyExists(arguments.frmstruct, "CarrierContactID") AND len(trim(arguments.frmstruct.CarrierContactID))>
				<CFPROCPARAM VALUE="#arguments.frmstruct.CarrierContactID#"  cfsqltype="CF_SQL_VARCHAR">
			<cfelse>
				<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR"  null="Yes">	
			</cfif>
			<cfif structKeyExists(arguments.frmstruct, "CarrierPhoneNo") AND len(trim(arguments.frmstruct.CarrierPhoneNo))>
				<CFPROCPARAM VALUE="#arguments.frmstruct.CarrierPhoneNo#"  cfsqltype="CF_SQL_VARCHAR">
			<cfelse>
				<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR"  null="Yes">	
			</cfif>
			<cfif structKeyExists(arguments.frmstruct, "CarrierPhoneNoExt") AND len(trim(arguments.frmstruct.CarrierPhoneNoExt))>
				<CFPROCPARAM VALUE="#arguments.frmstruct.CarrierPhoneNoExt#"  cfsqltype="CF_SQL_VARCHAR">
			<cfelse>
				<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR"  null="Yes">	
			</cfif>
			<cfif structKeyExists(arguments.frmstruct, "CarrierFax") AND len(trim(arguments.frmstruct.CarrierFax))>
				<CFPROCPARAM VALUE="#arguments.frmstruct.CarrierFax#"  cfsqltype="CF_SQL_VARCHAR">
			<cfelse>
				<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR"  null="Yes">	
			</cfif>
			<cfif structKeyExists(arguments.frmstruct, "CarrierFaxExt") AND len(trim(arguments.frmstruct.CarrierFaxExt))>
				<CFPROCPARAM VALUE="#arguments.frmstruct.CarrierFaxExt#"  cfsqltype="CF_SQL_VARCHAR">
			<cfelse>
				<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR"  null="Yes">	
			</cfif>
			<cfif structKeyExists(arguments.frmstruct, "CarrierTollFree") AND len(trim(arguments.frmstruct.CarrierTollFree))>
				<CFPROCPARAM VALUE="#arguments.frmstruct.CarrierTollFree#"  cfsqltype="CF_SQL_VARCHAR">
			<cfelse>
				<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR"  null="Yes">	
			</cfif>
			<cfif structKeyExists(arguments.frmstruct, "CarrierTollFreeExt") AND len(trim(arguments.frmstruct.CarrierTollFreeExt))>
				<CFPROCPARAM VALUE="#arguments.frmstruct.CarrierTollFreeExt#"  cfsqltype="CF_SQL_VARCHAR">
			<cfelse>
				<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR"  null="Yes">	
			</cfif>
			<cfif structKeyExists(arguments.frmstruct, "CarrierCell") AND len(trim(arguments.frmstruct.CarrierCell))>
				<CFPROCPARAM VALUE="#arguments.frmstruct.CarrierCell#"  cfsqltype="CF_SQL_VARCHAR">
			<cfelse>
				<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR"  null="Yes">	
			</cfif>
			<cfif structKeyExists(arguments.frmstruct, "CarrierCellExt") AND len(trim(arguments.frmstruct.CarrierCellExt))>
				<CFPROCPARAM VALUE="#arguments.frmstruct.CarrierCellExt#"  cfsqltype="CF_SQL_VARCHAR">
			<cfelse>
				<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR"  null="Yes">	
			</cfif>
			<cfif isdefined('arguments.frmstruct.CarrierEmailID2_1') and len(arguments.frmstruct.CarrierEmailID2_1)>
				<CFPROCPARAM VALUE="#arguments.frmstruct.CarrierEmailID2_1#"  cfsqltype="CF_SQL_VARCHAR">
			<cfelse>
				<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR"  null="Yes">	
			</cfif>
			<cfif structKeyExists(arguments.frmstruct, "CarrierContactID2_1") AND len(trim(arguments.frmstruct.CarrierContactID2_1))>
				<CFPROCPARAM VALUE="#arguments.frmstruct.CarrierContactI2_1D#"  cfsqltype="CF_SQL_VARCHAR">
			<cfelse>
				<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR"  null="Yes">	
			</cfif>
			<cfif structKeyExists(arguments.frmstruct, "CarrierPhoneNo2_1") AND len(trim(arguments.frmstruct.CarrierPhoneNo2_1))>
				<CFPROCPARAM VALUE="#arguments.frmstruct.CarrierPhoneNo2_1#"  cfsqltype="CF_SQL_VARCHAR">
			<cfelse>
				<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR"  null="Yes">	
			</cfif>
			<cfif structKeyExists(arguments.frmstruct, "CarrierPhoneNoExt2_1") AND len(trim(arguments.frmstruct.CarrierPhoneNoExt2_1))>
				<CFPROCPARAM VALUE="#arguments.frmstruct.CarrierPhoneNoExt2_1#"  cfsqltype="CF_SQL_VARCHAR">
			<cfelse>
				<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR"  null="Yes">	
			</cfif>
			<cfif structKeyExists(arguments.frmstruct, "CarrierFax2_1") AND len(trim(arguments.frmstruct.CarrierFax2_1))>
				<CFPROCPARAM VALUE="#arguments.frmstruct.CarrierFax2_1#"  cfsqltype="CF_SQL_VARCHAR">
			<cfelse>
				<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR"  null="Yes">	
			</cfif>
			<cfif structKeyExists(arguments.frmstruct, "CarrierFaxExt2_1") AND len(trim(arguments.frmstruct.CarrierFaxExt2_1))>
				<CFPROCPARAM VALUE="#arguments.frmstruct.CarrierFaxExt2_1#"  cfsqltype="CF_SQL_VARCHAR">
			<cfelse>
				<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR"  null="Yes">	
			</cfif>
			<cfif structKeyExists(arguments.frmstruct, "CarrierTollFree2_1") AND len(trim(arguments.frmstruct.CarrierTollFree2_1))>
				<CFPROCPARAM VALUE="#arguments.frmstruct.CarrierTollFree2_1#"  cfsqltype="CF_SQL_VARCHAR">
			<cfelse>
				<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR"  null="Yes">	
			</cfif>
			<cfif structKeyExists(arguments.frmstruct, "CarrierTollFreeExt2_1") AND len(trim(arguments.frmstruct.CarrierTollFreeExt2_1))>
				<CFPROCPARAM VALUE="#arguments.frmstruct.CarrierTollFreeExt2_1#"  cfsqltype="CF_SQL_VARCHAR">
			<cfelse>
				<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR"  null="Yes">	
			</cfif>
			<cfif structKeyExists(arguments.frmstruct, "CarrierCell2_1") AND len(trim(arguments.frmstruct.CarrierCell2_1))>
				<CFPROCPARAM VALUE="#arguments.frmstruct.CarrierCell2_1#"  cfsqltype="CF_SQL_VARCHAR">
			<cfelse>
				<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR"  null="Yes">	
			</cfif>
			<cfif structKeyExists(arguments.frmstruct, "CarrierCellExt2_1") AND len(trim(arguments.frmstruct.CarrierCellExt2_1))>
				<CFPROCPARAM VALUE="#arguments.frmstruct.CarrierCellExt2_1#"  cfsqltype="CF_SQL_VARCHAR">
			<cfelse>
				<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR"  null="Yes">	
			</cfif>
			<cfif isdefined('arguments.frmstruct.CarrierEmailID3_1') and len(arguments.frmstruct.CarrierEmailID3_1)>
				<CFPROCPARAM VALUE="#arguments.frmstruct.CarrierEmailID3_1#"  cfsqltype="CF_SQL_VARCHAR">
			<cfelse>
				<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR"  null="Yes">	
			</cfif>
			<cfif structKeyExists(arguments.frmstruct, "CarrierContactID3_1") AND len(trim(arguments.frmstruct.CarrierContactID3_1))>
				<CFPROCPARAM VALUE="#arguments.frmstruct.CarrierContactI3_1D#"  cfsqltype="CF_SQL_VARCHAR">
			<cfelse>
				<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR"  null="Yes">	
			</cfif>
			<cfif structKeyExists(arguments.frmstruct, "CarrierPhoneNo3_1") AND len(trim(arguments.frmstruct.CarrierPhoneNo3_1))>
				<CFPROCPARAM VALUE="#arguments.frmstruct.CarrierPhoneNo3_1#"  cfsqltype="CF_SQL_VARCHAR">
			<cfelse>
				<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR"  null="Yes">	
			</cfif>
			<cfif structKeyExists(arguments.frmstruct, "CarrierPhoneNoExt3_1") AND len(trim(arguments.frmstruct.CarrierPhoneNoExt3_1))>
				<CFPROCPARAM VALUE="#arguments.frmstruct.CarrierPhoneNoExt3_1#"  cfsqltype="CF_SQL_VARCHAR">
			<cfelse>
				<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR"  null="Yes">	
			</cfif>
			<cfif structKeyExists(arguments.frmstruct, "CarrierFax3_1") AND len(trim(arguments.frmstruct.CarrierFax3_1))>
				<CFPROCPARAM VALUE="#arguments.frmstruct.CarrierFax3_1#"  cfsqltype="CF_SQL_VARCHAR">
			<cfelse>
				<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR"  null="Yes">	
			</cfif>
			<cfif structKeyExists(arguments.frmstruct, "CarrierFaxExt3_1") AND len(trim(arguments.frmstruct.CarrierFaxExt3_1))>
				<CFPROCPARAM VALUE="#arguments.frmstruct.CarrierFaxExt3_1#"  cfsqltype="CF_SQL_VARCHAR">
			<cfelse>
				<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR"  null="Yes">	
			</cfif>
			<cfif structKeyExists(arguments.frmstruct, "CarrierTollFree3_1") AND len(trim(arguments.frmstruct.CarrierTollFree3_1))>
				<CFPROCPARAM VALUE="#arguments.frmstruct.CarrierTollFree3_1#"  cfsqltype="CF_SQL_VARCHAR">
			<cfelse>
				<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR"  null="Yes">	
			</cfif>
			<cfif structKeyExists(arguments.frmstruct, "CarrierTollFreeExt3_1") AND len(trim(arguments.frmstruct.CarrierTollFreeExt3_1))>
				<CFPROCPARAM VALUE="#arguments.frmstruct.CarrierTollFreeExt3_1#"  cfsqltype="CF_SQL_VARCHAR">
			<cfelse>
				<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR"  null="Yes">	
			</cfif>
			<cfif structKeyExists(arguments.frmstruct, "CarrierCell3_1") AND len(trim(arguments.frmstruct.CarrierCell3_1))>
				<CFPROCPARAM VALUE="#arguments.frmstruct.CarrierCell3_1#"  cfsqltype="CF_SQL_VARCHAR">
			<cfelse>
				<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR"  null="Yes">	
			</cfif>
			<cfif structKeyExists(arguments.frmstruct, "CarrierCellExt3_1") AND len(trim(arguments.frmstruct.CarrierCellExt3_1))>
				<CFPROCPARAM VALUE="#arguments.frmstruct.CarrierCellExt3_1#"  cfsqltype="CF_SQL_VARCHAR">
			<cfelse>
				<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR"  null="Yes">	
			</cfif>
			<cfif structKeyExists(arguments.frmstruct, "equipmentTrailer") AND len(trim(arguments.frmstruct.equipmentTrailer))>
				<CFPROCPARAM VALUE="#arguments.frmstruct.equipmentTrailer#"  cfsqltype="CF_SQL_VARCHAR">
			<cfelse>
				<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR"  null="Yes">	
			</cfif>
			<cfprocresult name="qLastInsertedShipper">
		</CFSTOREDPROC>
		<cfset lastInsertedStopId = qLastInsertedShipper.lastStopID>
		<cfreturn lastInsertedStopId>
	</cffunction>

	<cffunction name="insertConsigneeStopLoadAdd" access="public" returntype="any">
    	<cfargument name="LastLoadId" type="string" required="yes">
    	<cfargument name="lastUpdatedConsCustomerID" type="string" required="yes">
    	<cfargument name="ConsBlind" type="string" required="yes">
    	<cfargument name="noOfDays1" type="string" required="yes">
		<cfargument name="frmstruct" type="struct" required="yes">

		<CFSTOREDPROC PROCEDURE="USP_InsertLoadStop" DATASOURCE="#variables.dsn#">
			<CFPROCPARAM VALUE="#arguments.LastLoadId#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="True" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="True" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#arguments.frmstruct.BookedWith#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#arguments.frmstruct.equipment#" cfsqltype="CF_SQL_VARCHAR">
			<cfif isdefined('arguments.frmstruct.driver') and len(arguments.frmstruct.driver)>
				<CFPROCPARAM VALUE="#arguments.frmstruct.driver#" cfsqltype="CF_SQL_VARCHAR">
			<cfelse>
				<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR"  null="Yes">	
			</cfif>
			<CFPROCPARAM VALUE="#arguments.frmstruct.drivercell#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#arguments.frmstruct.truckNo#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#arguments.frmstruct.trailerNo#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#arguments.frmstruct.refNo#" cfsqltype="CF_SQL_VARCHAR">
			<cfif isNumeric(arguments.frmstruct.milse)>
				<CFPROCPARAM VALUE="#arguments.frmstruct.milse#" cfsqltype="cf_sql_float">
			<cfelse>
				<CFPROCPARAM VALUE="0" cfsqltype="cf_sql_float">
			</cfif>
			<CFPROCPARAM VALUE="#arguments.frmstruct.carrierid#" cfsqltype="CF_SQL_VARCHAR">
			<cfif structKeyExists(arguments.frmstruct, "stOffice") AND len(arguments.frmstruct.stOffice) gt 1>
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
			<CFPROCPARAM VALUE="#arguments.lastUpdatedConsCustomerID#" cfsqltype="CF_SQL_VARCHAR" null="#yesNoFormat(NOT len(arguments.lastUpdatedConsCustomerID))#" >
			<CFPROCPARAM VALUE="#arguments.ConsBlind#" cfsqltype="CF_SQL_BIT">
			<CFPROCPARAM VALUE="#arguments.frmstruct.consigneeNotes#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#arguments.frmstruct.consigneeDirection#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="2" cfsqltype="CF_SQL_INTEGER">
			<CFPROCPARAM VALUE="#arguments.frmstruct.consigneelocation#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#arguments.frmstruct.consigneeCity#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#arguments.frmstruct.consigneeStateName#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#arguments.frmstruct.consigneeZipCode#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#arguments.frmstruct.consigneeContactPerson#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#arguments.frmstruct.consigneePhone#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#arguments.frmstruct.consigneePhoneExt#" cfsqltype="CF_SQL_VARCHAR">
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
			<CFPROCPARAM VALUE="#arguments.noOfDays1#" cfsqltype="CF_SQL_INTEGER" null="#yesNoFormat(NOT len(arguments.noOfDays1))#">
			<cfif isdefined('arguments.frmstruct.Secdriver') and len(arguments.frmstruct.Secdriver)>
				<CFPROCPARAM VALUE="#arguments.frmstruct.Secdriver#" cfsqltype="CF_SQL_VARCHAR">
			<cfelse>
				<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR"  null="Yes">	
			</cfif>
			<CFPROCPARAM VALUE="#arguments.frmstruct.secDriverCell#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#arguments.frmstruct.temperature#" cfsqltype="CF_SQL_VARCHAR" null="#yesNoFormat(NOT len(arguments.frmstruct.temperature))#">
			<CFPROCPARAM VALUE="#arguments.frmstruct.temperaturescale#" cfsqltype="CF_SQL_VARCHAR">
			<cfif isdefined('arguments.frmstruct.consigneeTimeZone') and len(arguments.frmstruct.consigneeTimeZone)>
				<CFPROCPARAM VALUE="#arguments.frmstruct.consigneeTimeZone#"  cfsqltype="CF_SQL_VARCHAR">
			<cfelse>
				<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR"  null="Yes">	
			</cfif>
			<cfif isdefined('arguments.frmstruct.CarrierEmailID') and len(arguments.frmstruct.CarrierEmailID)>
				<CFPROCPARAM VALUE="#arguments.frmstruct.CarrierEmailID#"  cfsqltype="CF_SQL_VARCHAR">
			<cfelse>
				<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR"  null="Yes">	
			</cfif>
			<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR"  null="Yes">	
			<cfif isdefined('arguments.frmstruct.carrierID2_1') and len(arguments.frmstruct.carrierID2_1)>
				<CFPROCPARAM VALUE="#arguments.frmstruct.carrierID2_1#"  cfsqltype="CF_SQL_VARCHAR">
			<cfelse>
				<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR"  null="Yes">	
			</cfif>

			<cfif isdefined('arguments.frmstruct.carrierID3_1') and len(arguments.frmstruct.carrierID3_1)>
				<CFPROCPARAM VALUE="#arguments.frmstruct.carrierID3_1#"  cfsqltype="CF_SQL_VARCHAR">
			<cfelse>
				<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR"  null="Yes">	
			</cfif>

			<cfif isdefined('arguments.frmstruct.thirdDriverCell') and len(arguments.frmstruct.thirdDriverCell)>
				<CFPROCPARAM VALUE="#arguments.frmstruct.thirdDriverCell#"  cfsqltype="CF_SQL_VARCHAR">
			<cfelse>
				<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR"  null="Yes">	
			</cfif>
			<cfif structKeyExists(arguments.frmstruct, "customDriverPayFlatRate") AND IsNumeric(arguments.frmstruct.customDriverPayFlatRate)>
				<CFPROCPARAM VALUE="#arguments.frmstruct.customDriverPayFlatRate#"  cfsqltype="CF_SQL_FLOAT">
			<cfelse>
				<CFPROCPARAM VALUE="0"  cfsqltype="CF_SQL_FLOAT">
			</cfif>
			<cfif structKeyExists(arguments.frmstruct, "customDriverPayFlatRate2_1") AND IsNumeric(arguments.frmstruct.customDriverPayFlatRate2_1)>
				<CFPROCPARAM VALUE="#arguments.frmstruct.customDriverPayFlatRate2_1#"  cfsqltype="CF_SQL_FLOAT">
			<cfelse>
				<CFPROCPARAM VALUE="0"  cfsqltype="CF_SQL_FLOAT">
			</cfif>
			<cfif structKeyExists(arguments.frmstruct, "customDriverPayFlatRate3_1") AND IsNumeric(arguments.frmstruct.customDriverPayFlatRate3_1)>
				<CFPROCPARAM VALUE="#arguments.frmstruct.customDriverPayFlatRate3_1#"  cfsqltype="CF_SQL_FLOAT">
			<cfelse>
				<CFPROCPARAM VALUE="0"  cfsqltype="CF_SQL_FLOAT">
			</cfif>
			<cfif structKeyExists(arguments.frmstruct, "customDriverPayPercentage") AND IsNumeric(arguments.frmstruct.customDriverPayPercentage)>
				<CFPROCPARAM VALUE="#arguments.frmstruct.customDriverPayPercentage#"  cfsqltype="CF_SQL_FLOAT">
			<cfelse>
				<CFPROCPARAM VALUE="0"  cfsqltype="CF_SQL_FLOAT">
			</cfif>
			<cfif structKeyExists(arguments.frmstruct, "customDriverPayPercentage2_1") AND IsNumeric(arguments.frmstruct.customDriverPayPercentage2_1)>
				<CFPROCPARAM VALUE="#arguments.frmstruct.customDriverPayPercentage2_1#"  cfsqltype="CF_SQL_FLOAT">
			<cfelse>
				<CFPROCPARAM VALUE="0"  cfsqltype="CF_SQL_FLOAT">
			</cfif>
			<cfif structKeyExists(arguments.frmstruct, "customDriverPayPercentage3_1") AND IsNumeric(arguments.frmstruct.customDriverPayPercentage3_1)>
				<CFPROCPARAM VALUE="#arguments.frmstruct.customDriverPayPercentage3_1#"  cfsqltype="CF_SQL_FLOAT">
			<cfelse>
				<CFPROCPARAM VALUE="0"  cfsqltype="CF_SQL_FLOAT">
			</cfif>
			<cfif structKeyExists(arguments.frmstruct, "chkCustomDriverPayFlatRate")>
				<CFPROCPARAM VALUE="1"  cfsqltype="CF_SQL_INTEGER">
			<cfelseif structKeyExists(arguments.frmstruct, "chkCustomDriverPayPercentage")>
				<CFPROCPARAM VALUE="2"  cfsqltype="CF_SQL_INTEGER">
			<cfelse>
				<CFPROCPARAM VALUE="0"  cfsqltype="CF_SQL_INTEGER">
			</cfif>
			<cfif structKeyExists(arguments.frmstruct, "chkCustomDriverPayFlatRate2_1")>
				<CFPROCPARAM VALUE="1"  cfsqltype="CF_SQL_INTEGER">
			<cfelseif structKeyExists(arguments.frmstruct, "chkCustomDriverPayPercentage2_1")>
				<CFPROCPARAM VALUE="2"  cfsqltype="CF_SQL_INTEGER">
			<cfelse>
				<CFPROCPARAM VALUE="0"  cfsqltype="CF_SQL_INTEGER">
			</cfif>
			<cfif structKeyExists(arguments.frmstruct, "chkCustomDriverPayFlatRate3_1")>
				<CFPROCPARAM VALUE="1"  cfsqltype="CF_SQL_INTEGER">
			<cfelseif structKeyExists(arguments.frmstruct, "chkCustomDriverPayPercentage3_1")>
				<CFPROCPARAM VALUE="2"  cfsqltype="CF_SQL_INTEGER">
			<cfelse>
				<CFPROCPARAM VALUE="0"  cfsqltype="CF_SQL_INTEGER">
			</cfif>
			<cfif structKeyExists(arguments.frmstruct, "CarrierContactID") AND len(trim(arguments.frmstruct.CarrierContactID))>
				<CFPROCPARAM VALUE="#arguments.frmstruct.CarrierContactID#"  cfsqltype="CF_SQL_VARCHAR">
			<cfelse>
				<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR"  null="Yes">	
			</cfif>
			<cfif structKeyExists(arguments.frmstruct, "CarrierPhoneNo") AND len(trim(arguments.frmstruct.CarrierPhoneNo))>
				<CFPROCPARAM VALUE="#arguments.frmstruct.CarrierPhoneNo#"  cfsqltype="CF_SQL_VARCHAR">
			<cfelse>
				<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR"  null="Yes">	
			</cfif>
			<cfif structKeyExists(arguments.frmstruct, "CarrierPhoneNoExt") AND len(trim(arguments.frmstruct.CarrierPhoneNoExt))>
				<CFPROCPARAM VALUE="#arguments.frmstruct.CarrierPhoneNoExt#"  cfsqltype="CF_SQL_VARCHAR">
			<cfelse>
				<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR"  null="Yes">	
			</cfif>
			<cfif structKeyExists(arguments.frmstruct, "CarrierFax") AND len(trim(arguments.frmstruct.CarrierFax))>
				<CFPROCPARAM VALUE="#arguments.frmstruct.CarrierFax#"  cfsqltype="CF_SQL_VARCHAR">
			<cfelse>
				<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR"  null="Yes">	
			</cfif>
			<cfif structKeyExists(arguments.frmstruct, "CarrierFaxExt") AND len(trim(arguments.frmstruct.CarrierFaxExt))>
				<CFPROCPARAM VALUE="#arguments.frmstruct.CarrierFaxExt#"  cfsqltype="CF_SQL_VARCHAR">
			<cfelse>
				<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR"  null="Yes">	
			</cfif>
			<cfif structKeyExists(arguments.frmstruct, "CarrierTollFree") AND len(trim(arguments.frmstruct.CarrierTollFree))>
				<CFPROCPARAM VALUE="#arguments.frmstruct.CarrierTollFree#"  cfsqltype="CF_SQL_VARCHAR">
			<cfelse>
				<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR"  null="Yes">	
			</cfif>
			<cfif structKeyExists(arguments.frmstruct, "CarrierTollFreeExt") AND len(trim(arguments.frmstruct.CarrierTollFreeExt))>
				<CFPROCPARAM VALUE="#arguments.frmstruct.CarrierTollFreeExt#"  cfsqltype="CF_SQL_VARCHAR">
			<cfelse>
				<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR"  null="Yes">	
			</cfif>
			<cfif structKeyExists(arguments.frmstruct, "CarrierCell") AND len(trim(arguments.frmstruct.CarrierCell))>
				<CFPROCPARAM VALUE="#arguments.frmstruct.CarrierCell#"  cfsqltype="CF_SQL_VARCHAR">
			<cfelse>
				<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR"  null="Yes">	
			</cfif>
			<cfif structKeyExists(arguments.frmstruct, "CarrierCellExt") AND len(trim(arguments.frmstruct.CarrierCellExt))>
				<CFPROCPARAM VALUE="#arguments.frmstruct.CarrierCellExt#"  cfsqltype="CF_SQL_VARCHAR">
			<cfelse>
				<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR"  null="Yes">	
			</cfif>
			<cfif isdefined('arguments.frmstruct.CarrierEmailID2_1') and len(arguments.frmstruct.CarrierEmailID2_1)>
				<CFPROCPARAM VALUE="#arguments.frmstruct.CarrierEmailID2_1#"  cfsqltype="CF_SQL_VARCHAR">
			<cfelse>
				<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR"  null="Yes">	
			</cfif>
			<cfif structKeyExists(arguments.frmstruct, "CarrierContactID2_1") AND len(trim(arguments.frmstruct.CarrierContactID2_1))>
				<CFPROCPARAM VALUE="#arguments.frmstruct.CarrierContactI2_1D#"  cfsqltype="CF_SQL_VARCHAR">
			<cfelse>
				<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR"  null="Yes">	
			</cfif>
			<cfif structKeyExists(arguments.frmstruct, "CarrierPhoneNo2_1") AND len(trim(arguments.frmstruct.CarrierPhoneNo2_1))>
				<CFPROCPARAM VALUE="#arguments.frmstruct.CarrierPhoneNo2_1#"  cfsqltype="CF_SQL_VARCHAR">
			<cfelse>
				<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR"  null="Yes">	
			</cfif>
			<cfif structKeyExists(arguments.frmstruct, "CarrierPhoneNoExt2_1") AND len(trim(arguments.frmstruct.CarrierPhoneNoExt2_1))>
				<CFPROCPARAM VALUE="#arguments.frmstruct.CarrierPhoneNoExt2_1#"  cfsqltype="CF_SQL_VARCHAR">
			<cfelse>
				<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR"  null="Yes">	
			</cfif>
			<cfif structKeyExists(arguments.frmstruct, "CarrierFax2_1") AND len(trim(arguments.frmstruct.CarrierFax2_1))>
				<CFPROCPARAM VALUE="#arguments.frmstruct.CarrierFax2_1#"  cfsqltype="CF_SQL_VARCHAR">
			<cfelse>
				<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR"  null="Yes">	
			</cfif>
			<cfif structKeyExists(arguments.frmstruct, "CarrierFaxExt2_1") AND len(trim(arguments.frmstruct.CarrierFaxExt2_1))>
				<CFPROCPARAM VALUE="#arguments.frmstruct.CarrierFaxExt2_1#"  cfsqltype="CF_SQL_VARCHAR">
			<cfelse>
				<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR"  null="Yes">	
			</cfif>
			<cfif structKeyExists(arguments.frmstruct, "CarrierTollFree2_1") AND len(trim(arguments.frmstruct.CarrierTollFree2_1))>
				<CFPROCPARAM VALUE="#arguments.frmstruct.CarrierTollFree2_1#"  cfsqltype="CF_SQL_VARCHAR">
			<cfelse>
				<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR"  null="Yes">	
			</cfif>
			<cfif structKeyExists(arguments.frmstruct, "CarrierTollFreeExt2_1") AND len(trim(arguments.frmstruct.CarrierTollFreeExt2_1))>
				<CFPROCPARAM VALUE="#arguments.frmstruct.CarrierTollFreeExt2_1#"  cfsqltype="CF_SQL_VARCHAR">
			<cfelse>
				<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR"  null="Yes">	
			</cfif>
			<cfif structKeyExists(arguments.frmstruct, "CarrierCell2_1") AND len(trim(arguments.frmstruct.CarrierCell2_1))>
				<CFPROCPARAM VALUE="#arguments.frmstruct.CarrierCell2_1#"  cfsqltype="CF_SQL_VARCHAR">
			<cfelse>
				<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR"  null="Yes">	
			</cfif>
			<cfif structKeyExists(arguments.frmstruct, "CarrierCellExt2_1") AND len(trim(arguments.frmstruct.CarrierCellExt2_1))>
				<CFPROCPARAM VALUE="#arguments.frmstruct.CarrierCellExt2_1#"  cfsqltype="CF_SQL_VARCHAR">
			<cfelse>
				<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR"  null="Yes">	
			</cfif>
			<cfif isdefined('arguments.frmstruct.CarrierEmailID3_1') and len(arguments.frmstruct.CarrierEmailID3_1)>
				<CFPROCPARAM VALUE="#arguments.frmstruct.CarrierEmailID3_1#"  cfsqltype="CF_SQL_VARCHAR">
			<cfelse>
				<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR"  null="Yes">	
			</cfif>
			<cfif structKeyExists(arguments.frmstruct, "CarrierContactID3_1") AND len(trim(arguments.frmstruct.CarrierContactID3_1))>
				<CFPROCPARAM VALUE="#arguments.frmstruct.CarrierContactI3_1D#"  cfsqltype="CF_SQL_VARCHAR">
			<cfelse>
				<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR"  null="Yes">	
			</cfif>
			<cfif structKeyExists(arguments.frmstruct, "CarrierPhoneNo3_1") AND len(trim(arguments.frmstruct.CarrierPhoneNo3_1))>
				<CFPROCPARAM VALUE="#arguments.frmstruct.CarrierPhoneNo3_1#"  cfsqltype="CF_SQL_VARCHAR">
			<cfelse>
				<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR"  null="Yes">	
			</cfif>
			<cfif structKeyExists(arguments.frmstruct, "CarrierPhoneNoExt3_1") AND len(trim(arguments.frmstruct.CarrierPhoneNoExt3_1))>
				<CFPROCPARAM VALUE="#arguments.frmstruct.CarrierPhoneNoExt3_1#"  cfsqltype="CF_SQL_VARCHAR">
			<cfelse>
				<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR"  null="Yes">	
			</cfif>
			<cfif structKeyExists(arguments.frmstruct, "CarrierFax3_1") AND len(trim(arguments.frmstruct.CarrierFax3_1))>
				<CFPROCPARAM VALUE="#arguments.frmstruct.CarrierFax3_1#"  cfsqltype="CF_SQL_VARCHAR">
			<cfelse>
				<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR"  null="Yes">	
			</cfif>
			<cfif structKeyExists(arguments.frmstruct, "CarrierFaxExt3_1") AND len(trim(arguments.frmstruct.CarrierFaxExt3_1))>
				<CFPROCPARAM VALUE="#arguments.frmstruct.CarrierFaxExt3_1#"  cfsqltype="CF_SQL_VARCHAR">
			<cfelse>
				<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR"  null="Yes">	
			</cfif>
			<cfif structKeyExists(arguments.frmstruct, "CarrierTollFree3_1") AND len(trim(arguments.frmstruct.CarrierTollFree3_1))>
				<CFPROCPARAM VALUE="#arguments.frmstruct.CarrierTollFree3_1#"  cfsqltype="CF_SQL_VARCHAR">
			<cfelse>
				<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR"  null="Yes">	
			</cfif>
			<cfif structKeyExists(arguments.frmstruct, "CarrierTollFreeExt3_1") AND len(trim(arguments.frmstruct.CarrierTollFreeExt3_1))>
				<CFPROCPARAM VALUE="#arguments.frmstruct.CarrierTollFreeExt3_1#"  cfsqltype="CF_SQL_VARCHAR">
			<cfelse>
				<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR"  null="Yes">	
			</cfif>
			<cfif structKeyExists(arguments.frmstruct, "CarrierCell3_1") AND len(trim(arguments.frmstruct.CarrierCell3_1))>
				<CFPROCPARAM VALUE="#arguments.frmstruct.CarrierCell3_1#"  cfsqltype="CF_SQL_VARCHAR">
			<cfelse>
				<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR"  null="Yes">	
			</cfif>
			<cfif structKeyExists(arguments.frmstruct, "CarrierCellExt3_1") AND len(trim(arguments.frmstruct.CarrierCellExt3_1))>
				<CFPROCPARAM VALUE="#arguments.frmstruct.CarrierCellExt3_1#"  cfsqltype="CF_SQL_VARCHAR">
			<cfelse>
				<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR"  null="Yes">	
			</cfif>
			<cfif structKeyExists(arguments.frmstruct, "equipmentTrailer") AND len(trim(arguments.frmstruct.equipmentTrailer))>
				<CFPROCPARAM VALUE="#arguments.frmstruct.equipmentTrailer#"  cfsqltype="CF_SQL_VARCHAR">
			<cfelse>
				<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR"  null="Yes">	
			</cfif>
			<cfprocresult name="qLastInsertedConsignee">
		</CFSTOREDPROC>
		<cfreturn qLastInsertedConsignee>
	</cffunction>

	<cffunction name="insertShipperStopLoadAddStopNo" access="public" returntype="any">
    	<cfargument name="LastLoadId" type="string" required="yes">
    	<cfargument name="lastUpdatedShipCustomerID" type="string" required="yes">
    	<cfargument name="ShipBlind" type="string" required="yes">
    	<cfargument name="noOfDays" type="string" required="yes">
    	<cfargument name="NewStopNo" type="string" required="yes">
		<cfargument name="frmstruct" type="struct" required="yes">
		<cfargument name="stpID" type="string" required="yes">

		<CFSTOREDPROC PROCEDURE="USP_InsertLoadStop" DATASOURCE="#variables.dsn#">
			<CFPROCPARAM VALUE="#arguments.LastLoadId#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="True" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="True" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#evaluate('arguments.frmstruct.BookedWith#arguments.stpID#')#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#evaluate('arguments.frmstruct.equipment#arguments.stpID#')#" cfsqltype="CF_SQL_VARCHAR">
			<cfif isDefined('arguments.frmstruct.driver#arguments.stpID#') and len(evaluate('arguments.frmstruct.driver#arguments.stpID#'))>
				<CFPROCPARAM VALUE="#evaluate('arguments.frmstruct.driver#arguments.stpID#')#" cfsqltype="CF_SQL_VARCHAR">
			<cfelse>
				<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR" null="true">
			</cfif>
			<CFPROCPARAM VALUE="#evaluate('arguments.frmstruct.drivercell#arguments.stpID#')#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#evaluate('arguments.frmstruct.truckNo#arguments.stpID#')#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#evaluate('arguments.frmstruct.trailerNo#arguments.stpID#')#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#evaluate('arguments.frmstruct.refNo#arguments.stpID#')#" cfsqltype="CF_SQL_VARCHAR">
			<cfif isNumeric(evaluate('arguments.frmstruct.milse#arguments.stpID#'))>
				<CFPROCPARAM VALUE="#evaluate('arguments.frmstruct.milse#arguments.stpID#')#" cfsqltype="cf_sql_float">
			<cfelse>
				<CFPROCPARAM VALUE="0" cfsqltype="cf_sql_float">
			</cfif>
			<!------If the carrier for this stop is not selected and the carrier for the first stop is selected then add the first stop carrier for this stop------>
			<cfif arguments.frmstruct.carrierid neq "" and evaluate('arguments.frmstruct.carrierid#arguments.stpID#') eq "">
				<CFPROCPARAM VALUE="#arguments.frmstruct.carrierid#" cfsqltype="CF_SQL_VARCHAR">
				<cfif structKeyExists(arguments.frmstruct, "stOffice") AND len(arguments.frmstruct.stOffice) gt 1>
					<CFPROCPARAM VALUE="#arguments.frmstruct.stOffice#" cfsqltype="CF_SQL_VARCHAR">
				<cfelse>
					<CFPROCPARAM VALUE="Null" cfsqltype="CF_SQL_VARCHAR">
				</cfif>
			<cfelse>
				<CFPROCPARAM VALUE="#evaluate('arguments.frmstruct.carrierid#arguments.stpID#')#" cfsqltype="CF_SQL_VARCHAR">
				<cfif structKeyExists(arguments.frmstruct, "stOffice#arguments.stpID#") AND len(evaluate('arguments.frmstruct.stOffice#arguments.stpID#')) gt 1>
					<CFPROCPARAM VALUE="#evaluate('arguments.frmstruct.stOffice#arguments.stpID#')#" cfsqltype="CF_SQL_VARCHAR">
				<cfelse>
					<CFPROCPARAM VALUE="Null" cfsqltype="CF_SQL_VARCHAR">
				</cfif>
			</cfif>
			<CFPROCPARAM VALUE="#evaluate('arguments.frmstruct.shipperPickupNO1#arguments.stpID#')#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#evaluate('arguments.frmstruct.shipperPickupDate#arguments.stpID#')#" cfsqltype="CF_SQL_dATE" null="#yesNoFormat(NOT len(evaluate('arguments.frmstruct.shipperPickupDate#arguments.stpID#')))#">
			<CFPROCPARAM VALUE="#evaluate('arguments.frmstruct.shipperPickupTime#arguments.stpID#')#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#evaluate('arguments.frmstruct.shipperTimeIn#arguments.stpID#')#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#evaluate('arguments.frmstruct.shipperTimeOut#arguments.stpID#')#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#session.adminUserName#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#arguments.lastUpdatedShipCustomerID#" cfsqltype="CF_SQL_VARCHAR" null="#yesNoFormat(NOT len(arguments.lastUpdatedShipCustomerID))#">
			<CFPROCPARAM VALUE="#arguments.ShipBlind#" cfsqltype="CF_SQL_BIT">
			<CFPROCPARAM VALUE="#evaluate('arguments.frmstruct.shipperNotes#arguments.stpID#')#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#evaluate('arguments.frmstruct.shipperDirection#arguments.stpID#')#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="1" cfsqltype="CF_SQL_INTEGER">
			<CFPROCPARAM VALUE="#evaluate('arguments.frmstruct.shipperlocation#arguments.stpID#')#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#evaluate('arguments.frmstruct.shipperCity#arguments.stpID#')#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#evaluate('arguments.frmstruct.shipperStateName#arguments.stpID#')#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#evaluate('arguments.frmstruct.shipperZipCode#arguments.stpID#')#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#evaluate('arguments.frmstruct.shipperContactPerson#arguments.stpID#')#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#evaluate('arguments.frmstruct.shipperPhone#arguments.stpID#')#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#evaluate('arguments.frmstruct.shipperPhoneExt#arguments.stpID#')#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#evaluate('arguments.frmstruct.shipperFax#arguments.stpID#')#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#evaluate('arguments.frmstruct.shipperEmail#arguments.stpID#')#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#evaluate('arguments.frmstruct.shipperName#arguments.stpID#')#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#evaluate('arguments.frmstruct.userDef1#arguments.stpID#')#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#evaluate('arguments.frmstruct.userDef2#arguments.stpID#')#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#evaluate('arguments.frmstruct.userDef3#arguments.stpID#')#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#evaluate('arguments.frmstruct.userDef4#arguments.stpID#')#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#evaluate('arguments.frmstruct.userDef5#arguments.stpID#')#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#evaluate('arguments.frmstruct.userDef6#arguments.stpID#')#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#arguments.NewStopNo#" cfsqltype="CF_SQL_INTEGER">
			<CFPROCPARAM VALUE="#arguments.noOfDays#" cfsqltype="CF_SQL_INTEGER" null="#yesNoFormat(NOT len(arguments.noOfDays))#">

			<cfif isDefined('arguments.frmstruct.Secdriver#arguments.stpID#') and len(evaluate('arguments.frmstruct.Secdriver#arguments.stpID#'))>
				<CFPROCPARAM VALUE="#evaluate('arguments.frmstruct.Secdriver#arguments.stpID#')#" cfsqltype="CF_SQL_VARCHAR">
			<cfelse>
				<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR" null="true">
			</cfif>
			<CFPROCPARAM VALUE="#evaluate('arguments.frmstruct.secDriverCell#arguments.stpID#')#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#evaluate('arguments.frmstruct.temperature#arguments.stpID#')#" cfsqltype="CF_SQL_VARCHAR" null="#yesNoFormat(NOT len(evaluate('arguments.frmstruct.temperature#arguments.stpID#')))#">
			<CFPROCPARAM VALUE="#evaluate('arguments.frmstruct.temperaturescale#arguments.stpID#')#" cfsqltype="CF_SQL_VARCHAR">

			<cfif isdefined('arguments.frmstruct.shipperTimeZone#arguments.stpID#') and len(evaluate('arguments.frmstruct.shipperTimeZone#arguments.stpID#'))>
				<CFPROCPARAM VALUE="#evaluate('arguments.frmstruct.shipperTimeZone#arguments.stpID#')#"  cfsqltype="CF_SQL_VARCHAR">
			<cfelse>
				<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR"  null="Yes">	
			</cfif>

			<cfif isdefined('arguments.frmstruct.CarrierEmailID#arguments.stpID#') and len(evaluate('arguments.frmstruct.CarrierEmailID#arguments.stpID#'))>
				<CFPROCPARAM VALUE="#evaluate('arguments.frmstruct.CarrierEmailID#arguments.stpID#')#"  cfsqltype="CF_SQL_VARCHAR">
			<cfelse>
				<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR"  null="Yes">	
			</cfif>
			<cfif isdefined('arguments.frmstruct.shipperPickupDateMultiple#arguments.stpID#') and len(evaluate('arguments.frmstruct.shipperPickupDateMultiple#arguments.stpID#'))>
				<CFPROCPARAM VALUE="#evaluate('arguments.frmstruct.shipperPickupDateMultiple#arguments.stpID#')#"  cfsqltype="CF_SQL_VARCHAR">
			<cfelse>
				<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR"  null="Yes">	
			</cfif>

			<cfif isdefined('arguments.frmstruct.carrierID2_#arguments.stpID#') and len(evaluate('arguments.frmstruct.carrierID2_#arguments.stpID#'))>
				<CFPROCPARAM VALUE="#evaluate('arguments.frmstruct.carrierID2_#arguments.stpID#')#"  cfsqltype="CF_SQL_VARCHAR">
			<cfelse>
				<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR"  null="Yes">	
			</cfif>

			<cfif isdefined('arguments.frmstruct.carrierID3_#arguments.stpID#') and len(evaluate('arguments.frmstruct.carrierID3_#arguments.stpID#'))>
				<CFPROCPARAM VALUE="#evaluate('arguments.frmstruct.carrierID3_#arguments.stpID#')#"  cfsqltype="CF_SQL_VARCHAR">
			<cfelse>
				<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR"  null="Yes">	
			</cfif>

			<cfif isdefined('arguments.frmstruct.thirdDriverCell#arguments.stpID#') and len(evaluate('arguments.frmstruct.thirdDriverCell#arguments.stpID#'))>
				<CFPROCPARAM VALUE="#evaluate('arguments.frmstruct.thirdDriverCell#arguments.stpID#')#"  cfsqltype="CF_SQL_VARCHAR">
			<cfelse>
				<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR"  null="Yes">	
			</cfif>

			<cfif structKeyExists(arguments.frmstruct, "customDriverPayFlatRate#arguments.stpID#") AND IsNumeric(arguments.frmstruct["customDriverPayFlatRate#arguments.stpID#"])>
				<CFPROCPARAM VALUE="#arguments.frmstruct["customDriverPayFlatRate#arguments.stpID#"]#"  cfsqltype="CF_SQL_FLOAT">
			<cfelse>
				<CFPROCPARAM VALUE="0"  cfsqltype="CF_SQL_FLOAT">
			</cfif>

			<cfif structKeyExists(arguments.frmstruct, "customDriverPayFlatRate2_#arguments.stpID#") AND IsNumeric(arguments.frmstruct["customDriverPayFlatRate2_#arguments.stpID#"])>
				<CFPROCPARAM VALUE="#arguments.frmstruct["customDriverPayFlatRate2_#arguments.stpID#"]#"  cfsqltype="CF_SQL_FLOAT">
			<cfelse>
				<CFPROCPARAM VALUE="0"  cfsqltype="CF_SQL_FLOAT">
			</cfif>

			<cfif structKeyExists(arguments.frmstruct, "customDriverPayFlatRate3_#arguments.stpID#") AND IsNumeric(arguments.frmstruct["customDriverPayFlatRate3_#arguments.stpID#"])>
				<CFPROCPARAM VALUE="#arguments.frmstruct["customDriverPayFlatRate3_#arguments.stpID#"]#"  cfsqltype="CF_SQL_FLOAT">
			<cfelse>
				<CFPROCPARAM VALUE="0"  cfsqltype="CF_SQL_FLOAT">
			</cfif>

			<cfif structKeyExists(arguments.frmstruct, "customDriverPayPercentage#arguments.stpID#") AND IsNumeric(arguments.frmstruct["customDriverPayPercentage#arguments.stpID#"])>
				<CFPROCPARAM VALUE="#arguments.frmstruct["customDriverPayPercentage#arguments.stpID#"]#"  cfsqltype="CF_SQL_FLOAT">
			<cfelse>
				<CFPROCPARAM VALUE="0"  cfsqltype="CF_SQL_FLOAT">
			</cfif>

			<cfif structKeyExists(arguments.frmstruct, "customDriverPayPercentage2_#arguments.stpID#") AND IsNumeric(arguments.frmstruct["customDriverPayPercentage2_#arguments.stpID#"])>
				<CFPROCPARAM VALUE="#arguments.frmstruct["customDriverPayPercentage2_#arguments.stpID#"]#"  cfsqltype="CF_SQL_FLOAT">
			<cfelse>
				<CFPROCPARAM VALUE="0"  cfsqltype="CF_SQL_FLOAT">
			</cfif>

			<cfif structKeyExists(arguments.frmstruct, "customDriverPayPercentage3_#arguments.stpID#") AND IsNumeric(arguments.frmstruct["customDriverPayPercentage3_#arguments.stpID#"])>
				<CFPROCPARAM VALUE="#arguments.frmstruct["customDriverPayPercentage3_#arguments.stpID#"]#"  cfsqltype="CF_SQL_FLOAT">
			<cfelse>
				<CFPROCPARAM VALUE="0"  cfsqltype="CF_SQL_FLOAT">
			</cfif>

			<cfif structKeyExists(arguments.frmstruct, "chkCustomDriverPayFlatRate#arguments.stpID#")>
				<CFPROCPARAM VALUE="1"  cfsqltype="CF_SQL_INTEGER">
			<cfelseif structKeyExists(arguments.frmstruct, "chkCustomDriverPayPercentage#arguments.stpID#")>
				<CFPROCPARAM VALUE="2"  cfsqltype="CF_SQL_INTEGER">
			<cfelse>
				<CFPROCPARAM VALUE="0"  cfsqltype="CF_SQL_INTEGER">
			</cfif>
			<cfif structKeyExists(arguments.frmstruct, "chkCustomDriverPayFlatRate2_#arguments.stpID#")>
				<CFPROCPARAM VALUE="1"  cfsqltype="CF_SQL_INTEGER">
			<cfelseif structKeyExists(arguments.frmstruct, "chkCustomDriverPayPercentage2_#arguments.stpID#")>
				<CFPROCPARAM VALUE="2"  cfsqltype="CF_SQL_INTEGER">
			<cfelse>
				<CFPROCPARAM VALUE="0"  cfsqltype="CF_SQL_INTEGER">
			</cfif>
			<cfif structKeyExists(arguments.frmstruct, "chkCustomDriverPayFlatRate3_#arguments.stpID#")>
				<CFPROCPARAM VALUE="1"  cfsqltype="CF_SQL_INTEGER">
			<cfelseif structKeyExists(arguments.frmstruct, "chkCustomDriverPayPercentage3_#arguments.stpID#")>
				<CFPROCPARAM VALUE="2"  cfsqltype="CF_SQL_INTEGER">
			<cfelse>
				<CFPROCPARAM VALUE="0"  cfsqltype="CF_SQL_INTEGER">
			</cfif>
			<cfif isdefined('arguments.frmstruct.CarrierContactID#arguments.stpID#') and len(evaluate('arguments.frmstruct.CarrierContactID#arguments.stpID#'))>
				<CFPROCPARAM VALUE="#evaluate('arguments.frmstruct.CarrierContactID#arguments.stpID#')#"  cfsqltype="CF_SQL_VARCHAR">
			<cfelse>
				<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR"  null="Yes">	
			</cfif>

			<cfif isdefined('arguments.frmstruct.CarrierPhoneNo#arguments.stpID#') and len(evaluate('arguments.frmstruct.CarrierPhoneNo#arguments.stpID#'))>
				<CFPROCPARAM VALUE="#evaluate('arguments.frmstruct.CarrierPhoneNo#arguments.stpID#')#"  cfsqltype="CF_SQL_VARCHAR">
			<cfelse>
				<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR"  null="Yes">	
			</cfif>

			<cfif isdefined('arguments.frmstruct.CarrierPhoneNoExt#arguments.stpID#') and len(evaluate('CarrierPhoneNoExt#arguments.stpID#'))>
				<CFPROCPARAM VALUE="#evaluate('arguments.frmstruct.CarrierPhoneNoExt#arguments.stpID#')#"  cfsqltype="CF_SQL_VARCHAR">
			<cfelse>
				<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR"  null="Yes">	
			</cfif>

			<cfif isdefined('arguments.frmstruct.CarrierFax#arguments.stpID#') and len(evaluate('CarrierFax#arguments.stpID#'))>
				<CFPROCPARAM VALUE="#evaluate('arguments.frmstruct.CarrierFax#arguments.stpID#')#"  cfsqltype="CF_SQL_VARCHAR">
			<cfelse>
				<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR"  null="Yes">	
			</cfif>

			<cfif isdefined('arguments.frmstruct.CarrierFaxExt#arguments.stpID#') and len(evaluate('CarrierFaxExt#arguments.stpID#'))>
				<CFPROCPARAM VALUE="#evaluate('arguments.frmstruct.CarrierFaxExt#arguments.stpID#')#"  cfsqltype="CF_SQL_VARCHAR">
			<cfelse>
				<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR"  null="Yes">	
			</cfif>

			<cfif isdefined('arguments.frmstruct.CarrierTollFree#arguments.stpID#') and len(evaluate('CarrierTollFree#arguments.stpID#'))>
				<CFPROCPARAM VALUE="#evaluate('arguments.frmstruct.CarrierTollFree#arguments.stpID#')#"  cfsqltype="CF_SQL_VARCHAR">
			<cfelse>
				<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR"  null="Yes">	
			</cfif>

			<cfif isdefined('arguments.frmstruct.CarrierTollFreeExt#arguments.stpID#') and len(evaluate('CarrierTollFreeExt#arguments.stpID#'))>
				<CFPROCPARAM VALUE="#evaluate('arguments.frmstruct.CarrierTollFreeExt#arguments.stpID#')#"  cfsqltype="CF_SQL_VARCHAR">
			<cfelse>
				<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR"  null="Yes">	
			</cfif>

			<cfif isdefined('arguments.frmstruct.CarrierCell#arguments.stpID#') and len(evaluate('CarrierCell#arguments.stpID#'))>
				<CFPROCPARAM VALUE="#evaluate('arguments.frmstruct.CarrierCell#arguments.stpID#')#"  cfsqltype="CF_SQL_VARCHAR">
			<cfelse>
				<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR"  null="Yes">	
			</cfif>

			<cfif isdefined('arguments.frmstruct.CarrierCellExt#arguments.stpID#') and len(evaluate('CarrierCellExt#arguments.stpID#'))>
				<CFPROCPARAM VALUE="#evaluate('arguments.frmstruct.CarrierCellExt#arguments.stpID#')#"  cfsqltype="CF_SQL_VARCHAR">
			<cfelse>
				<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR"  null="Yes">	
			</cfif>

			<cfif isdefined('arguments.frmstruct.CarrierEmailID2_#arguments.stpID#') and len(evaluate('arguments.frmstruct.CarrierEmailID2_#arguments.stpID#'))>
				<CFPROCPARAM VALUE="#evaluate('arguments.frmstruct.CarrierEmailID2_#arguments.stpID#')#"  cfsqltype="CF_SQL_VARCHAR">
			<cfelse>
				<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR"  null="Yes">	
			</cfif>

			<cfif isdefined('arguments.frmstruct.CarrierContactID2_#arguments.stpID#') and len(evaluate('arguments.frmstruct.CarrierContactID2_#arguments.stpID#'))>
				<CFPROCPARAM VALUE="#evaluate('arguments.frmstruct.CarrierContactID2_#arguments.stpID#')#"  cfsqltype="CF_SQL_VARCHAR">
			<cfelse>
				<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR"  null="Yes">	
			</cfif>

			<cfif isdefined('arguments.frmstruct.CarrierPhoneNo2_#arguments.stpID#') and len(evaluate('arguments.frmstruct.CarrierPhoneNo2_#arguments.stpID#'))>
				<CFPROCPARAM VALUE="#evaluate('arguments.frmstruct.CarrierPhoneNo2_#arguments.stpID#')#"  cfsqltype="CF_SQL_VARCHAR">
			<cfelse>
				<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR"  null="Yes">	
			</cfif>

			<cfif isdefined('arguments.frmstruct.CarrierPhoneNoExt2_#arguments.stpID#') and len(evaluate('CarrierPhoneNoExt2_#arguments.stpID#'))>
				<CFPROCPARAM VALUE="#evaluate('arguments.frmstruct.CarrierPhoneNoExt2_#arguments.stpID#')#"  cfsqltype="CF_SQL_VARCHAR">
			<cfelse>
				<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR"  null="Yes">	
			</cfif>

			<cfif isdefined('arguments.frmstruct.CarrierFax2_#arguments.stpID#') and len(evaluate('CarrierFax2_#arguments.stpID#'))>
				<CFPROCPARAM VALUE="#evaluate('arguments.frmstruct.CarrierFax2_#arguments.stpID#')#"  cfsqltype="CF_SQL_VARCHAR">
			<cfelse>
				<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR"  null="Yes">	
			</cfif>

			<cfif isdefined('arguments.frmstruct.CarrierFaxExt2_#arguments.stpID#') and len(evaluate('CarrierFaxExt2_#arguments.stpID#'))>
				<CFPROCPARAM VALUE="#evaluate('arguments.frmstruct.CarrierFaxExt2_#arguments.stpID#')#"  cfsqltype="CF_SQL_VARCHAR">
			<cfelse>
				<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR"  null="Yes">	
			</cfif>

			<cfif isdefined('arguments.frmstruct.CarrierTollFree2_#arguments.stpID#') and len(evaluate('CarrierTollFree2_#arguments.stpID#'))>
				<CFPROCPARAM VALUE="#evaluate('arguments.frmstruct.CarrierTollFree2_#arguments.stpID#')#"  cfsqltype="CF_SQL_VARCHAR">
			<cfelse>
				<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR"  null="Yes">	
			</cfif>

			<cfif isdefined('arguments.frmstruct.CarrierTollFreeExt2_#arguments.stpID#') and len(evaluate('CarrierTollFreeExt2_#arguments.stpID#'))>
				<CFPROCPARAM VALUE="#evaluate('arguments.frmstruct.CarrierTollFreeExt2_#arguments.stpID#')#"  cfsqltype="CF_SQL_VARCHAR">
			<cfelse>
				<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR"  null="Yes">	
			</cfif>

			<cfif isdefined('arguments.frmstruct.CarrierCell2_#arguments.stpID#') and len(evaluate('CarrierCell2_#arguments.stpID#'))>
				<CFPROCPARAM VALUE="#evaluate('arguments.frmstruct.CarrierCell2_#arguments.stpID#')#"  cfsqltype="CF_SQL_VARCHAR">
			<cfelse>
				<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR"  null="Yes">	
			</cfif>

			<cfif isdefined('arguments.frmstruct.CarrierCellExt2_#arguments.stpID#') and len(evaluate('CarrierCellExt2_#arguments.stpID#'))>
				<CFPROCPARAM VALUE="#evaluate('arguments.frmstruct.CarrierCellExt2_#arguments.stpID#')#"  cfsqltype="CF_SQL_VARCHAR">
			<cfelse>
				<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR"  null="Yes">	
			</cfif>

			<cfif isdefined('arguments.frmstruct.CarrierEmailID3_#arguments.stpID#') and len(evaluate('arguments.frmstruct.CarrierEmailID3_#arguments.stpID#'))>
				<CFPROCPARAM VALUE="#evaluate('arguments.frmstruct.CarrierEmailID3_#arguments.stpID#')#"  cfsqltype="CF_SQL_VARCHAR">
			<cfelse>
				<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR"  null="Yes">	
			</cfif>

			<cfif isdefined('arguments.frmstruct.CarrierContactID3_#arguments.stpID#') and len(evaluate('arguments.frmstruct.CarrierContactID3_#arguments.stpID#'))>
				<CFPROCPARAM VALUE="#evaluate('arguments.frmstruct.CarrierContactID3_#arguments.stpID#')#"  cfsqltype="CF_SQL_VARCHAR">
			<cfelse>
				<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR"  null="Yes">	
			</cfif>

			<cfif isdefined('arguments.frmstruct.CarrierPhoneNo3_#arguments.stpID#') and len(evaluate('arguments.frmstruct.CarrierPhoneNo3_#arguments.stpID#'))>
				<CFPROCPARAM VALUE="#evaluate('arguments.frmstruct.CarrierPhoneNo3_#arguments.stpID#')#"  cfsqltype="CF_SQL_VARCHAR">
			<cfelse>
				<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR"  null="Yes">	
			</cfif>

			<cfif isdefined('arguments.frmstruct.CarrierPhoneNoExt3_#arguments.stpID#') and len(evaluate('CarrierPhoneNoExt3_#arguments.stpID#'))>
				<CFPROCPARAM VALUE="#evaluate('arguments.frmstruct.CarrierPhoneNoExt3_#arguments.stpID#')#"  cfsqltype="CF_SQL_VARCHAR">
			<cfelse>
				<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR"  null="Yes">	
			</cfif>

			<cfif isdefined('arguments.frmstruct.CarrierFax3_#arguments.stpID#') and len(evaluate('CarrierFax3_#arguments.stpID#'))>
				<CFPROCPARAM VALUE="#evaluate('arguments.frmstruct.CarrierFax3_#arguments.stpID#')#"  cfsqltype="CF_SQL_VARCHAR">
			<cfelse>
				<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR"  null="Yes">	
			</cfif>

			<cfif isdefined('arguments.frmstruct.CarrierFaxExt3_#arguments.stpID#') and len(evaluate('CarrierFaxExt3_#arguments.stpID#'))>
				<CFPROCPARAM VALUE="#evaluate('arguments.frmstruct.CarrierFaxExt3_#arguments.stpID#')#"  cfsqltype="CF_SQL_VARCHAR">
			<cfelse>
				<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR"  null="Yes">	
			</cfif>

			<cfif isdefined('arguments.frmstruct.CarrierTollFree3_#arguments.stpID#') and len(evaluate('CarrierTollFree3_#arguments.stpID#'))>
				<CFPROCPARAM VALUE="#evaluate('arguments.frmstruct.CarrierTollFree3_#arguments.stpID#')#"  cfsqltype="CF_SQL_VARCHAR">
			<cfelse>
				<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR"  null="Yes">	
			</cfif>

			<cfif isdefined('arguments.frmstruct.CarrierTollFreeExt3_#arguments.stpID#') and len(evaluate('CarrierTollFreeExt3_#arguments.stpID#'))>
				<CFPROCPARAM VALUE="#evaluate('arguments.frmstruct.CarrierTollFreeExt3_#arguments.stpID#')#"  cfsqltype="CF_SQL_VARCHAR">
			<cfelse>
				<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR"  null="Yes">	
			</cfif>

			<cfif isdefined('arguments.frmstruct.CarrierCell3_#arguments.stpID#') and len(evaluate('CarrierCell3_#arguments.stpID#'))>
				<CFPROCPARAM VALUE="#evaluate('arguments.frmstruct.CarrierCell3_#arguments.stpID#')#"  cfsqltype="CF_SQL_VARCHAR">
			<cfelse>
				<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR"  null="Yes">	
			</cfif>

			<cfif isdefined('arguments.frmstruct.CarrierCellExt3_#arguments.stpID#') and len(evaluate('CarrierCellExt3_#arguments.stpID#'))>
				<CFPROCPARAM VALUE="#evaluate('arguments.frmstruct.CarrierCellExt3_#arguments.stpID#')#"  cfsqltype="CF_SQL_VARCHAR">
			<cfelse>
				<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR"  null="Yes">	
			</cfif>

			<cfif isdefined('arguments.frmstruct.equipmentTrailer#arguments.stpID#') and len(evaluate('equipmentTrailer#arguments.stpID#'))>
				<CFPROCPARAM VALUE="#evaluate('arguments.frmstruct.equipmentTrailer#arguments.stpID#')#"  cfsqltype="CF_SQL_VARCHAR">
			<cfelse>
				<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR"  null="Yes">	
			</cfif>

			<CFPROCRESULT NAME="qInsertedCustStopId">
		</cfstoredproc>

		<cfreturn qInsertedCustStopId>
	</cffunction>

	<cffunction name="insertConsigneeStopLoadAddStopNo" access="public" returntype="any">
    	<cfargument name="LastLoadId" type="string" required="yes">
    	<cfargument name="lastUpdatedConsCustomerID" type="string" required="yes">
    	<cfargument name="ConsBlind" type="string" required="yes">
    	<cfargument name="noOfDays" type="string" required="yes">
    	<cfargument name="NewStopNo" type="string" required="yes">
		<cfargument name="frmstruct" type="struct" required="yes">
		<cfargument name="stpID" type="string" required="yes">

		<CFSTOREDPROC PROCEDURE="USP_InsertLoadStop" DATASOURCE="#variables.dsn#">
			<CFPROCPARAM VALUE="#arguments.LastLoadId#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="True" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="True" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#evaluate('arguments.frmstruct.BookedWith#arguments.stpID#')#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#evaluate('arguments.frmstruct.equipment#arguments.stpID#')#" cfsqltype="CF_SQL_VARCHAR">
			<cfif isDefined('arguments.frmstruct.driver#arguments.stpID#') and len(evaluate('arguments.frmstruct.driver#arguments.stpID#'))>
				<CFPROCPARAM VALUE="#evaluate('arguments.frmstruct.driver#arguments.stpID#')#" cfsqltype="CF_SQL_VARCHAR">
			<cfelse>
				<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR" null="true">
			</cfif>
			<CFPROCPARAM VALUE="#evaluate('arguments.frmstruct.drivercell#arguments.stpID#')#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#evaluate('arguments.frmstruct.truckNo#arguments.stpID#')#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#evaluate('arguments.frmstruct.trailerNo#arguments.stpID#')#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#evaluate('arguments.frmstruct.refNo#arguments.stpID#')#" cfsqltype="CF_SQL_VARCHAR">
			<cfif isnumeric(evaluate('arguments.frmstruct.milse#arguments.stpID#'))>
				<CFPROCPARAM VALUE="#evaluate('arguments.frmstruct.milse#arguments.stpID#')#" cfsqltype="cf_sql_float">
			<cfelse>
				<CFPROCPARAM VALUE="0" cfsqltype="cf_sql_float">
			</cfif>
			<!------If the carrier for this stop is not selected and the carrier for the first stop is selected then add the first stop carrier for this stop------>
			<cfif arguments.frmstruct.carrierid neq "" and evaluate('arguments.frmstruct.carrierid#arguments.stpID#') eq "">
				<CFPROCPARAM VALUE="#arguments.frmstruct.carrierid#" cfsqltype="CF_SQL_VARCHAR">
				<cfif  structKeyExists(arguments.frmstruct, "stOffice") AND len(arguments.frmstruct.stOffice) gt 1>
					<CFPROCPARAM VALUE="#arguments.frmstruct.stOffice#" cfsqltype="CF_SQL_VARCHAR">
				<cfelse>
					<CFPROCPARAM VALUE="Null" cfsqltype="CF_SQL_VARCHAR">
				</cfif>
			<cfelse>
				<CFPROCPARAM VALUE="#evaluate('arguments.frmstruct.carrierid#arguments.stpID#')#" cfsqltype="CF_SQL_VARCHAR">
				<cfif structKeyExists(arguments.frmstruct, "stOffice#arguments.stpID#") AND len(evaluate('arguments.frmstruct.stOffice#arguments.stpID#')) gt 1>
					<CFPROCPARAM VALUE="#evaluate('arguments.frmstruct.stOffice#arguments.stpID#')#" cfsqltype="CF_SQL_VARCHAR">
				<cfelse>
					<CFPROCPARAM VALUE="Null" cfsqltype="CF_SQL_VARCHAR">
				</cfif>
			</cfif>
			<CFPROCPARAM VALUE="#evaluate('arguments.frmstruct.consigneePickupNo#arguments.stpID#')#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#evaluate('arguments.frmstruct.consigneePickupDate#arguments.stpID#')#" cfsqltype="CF_SQL_dATE" null="#yesNoFormat(NOT len(evaluate('arguments.frmstruct.consigneePickupDate#arguments.stpID#')))#">
			<CFPROCPARAM VALUE="#evaluate('arguments.frmstruct.consigneePickupTime#arguments.stpID#')#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#evaluate('arguments.frmstruct.consigneetimein#arguments.stpID#')#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#evaluate('arguments.frmstruct.consigneetimeout#arguments.stpID#')#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#session.adminUserName#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#arguments.lastUpdatedConsCustomerID#" cfsqltype="CF_SQL_VARCHAR" null="#yesNoFormat(NOT len(arguments.lastUpdatedConsCustomerID))#">
			<CFPROCPARAM VALUE="#arguments.ConsBlind#" cfsqltype="CF_SQL_BIT">
			<CFPROCPARAM VALUE="#evaluate('arguments.frmstruct.consigneeNotes#arguments.stpID#')#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#evaluate('arguments.frmstruct.consigneeDirection#arguments.stpID#')#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="2" cfsqltype="CF_SQL_INTEGER">
			<!---<CFPROCPARAM VALUE="0" cfsqltype="CF_SQL_INTEGER">  Stop Number --->
			<CFPROCPARAM VALUE="#evaluate('arguments.frmstruct.consigneelocation#arguments.stpID#')#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#evaluate('arguments.frmstruct.consigneeCity#arguments.stpID#')#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#evaluate('arguments.frmstruct.consigneeStateName#arguments.stpID#')#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#evaluate('arguments.frmstruct.consigneeZipCode#arguments.stpID#')#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#evaluate('arguments.frmstruct.consigneeContactPerson#arguments.stpID#')#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#evaluate('arguments.frmstruct.consigneePhone#arguments.stpID#')#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#evaluate('arguments.frmstruct.consigneePhoneExt#arguments.stpID#')#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#evaluate('arguments.frmstruct.consigneeFax#arguments.stpID#')#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#evaluate('arguments.frmstruct.consigneeEmail#arguments.stpID#')#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#evaluate('arguments.frmstruct.consigneeName#arguments.stpID#')#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#evaluate('arguments.frmstruct.userDef1#arguments.stpID#')#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#evaluate('arguments.frmstruct.userDef2#arguments.stpID#')#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#evaluate('arguments.frmstruct.userDef3#arguments.stpID#')#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#evaluate('arguments.frmstruct.userDef4#arguments.stpID#')#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#evaluate('arguments.frmstruct.userDef5#arguments.stpID#')#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#evaluate('arguments.frmstruct.userDef6#arguments.stpID#')#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#arguments.NewStopNo#" cfsqltype="CF_SQL_INTEGER">
			<CFPROCPARAM VALUE="#arguments.noOfDays#" cfsqltype="CF_SQL_INTEGER" null="#yesNoFormat(NOT len(arguments.noOfDays))#">
			<cfif isDefined('arguments.frmstruct.Secdriver#arguments.stpID#') and len(evaluate('arguments.frmstruct.Secdriver#arguments.stpID#'))>
				<CFPROCPARAM VALUE="#evaluate('arguments.frmstruct.Secdriver#arguments.stpID#')#" cfsqltype="CF_SQL_VARCHAR">
			<cfelse>
				<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR" null="true">
			</cfif>
			<CFPROCPARAM VALUE="#evaluate('arguments.frmstruct.secDriverCell#arguments.stpID#')#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#evaluate('arguments.frmstruct.temperature#arguments.stpID#')#" cfsqltype="CF_SQL_VARCHAR" null="#yesNoFormat(NOT len(evaluate('arguments.frmstruct.temperature#arguments.stpID#')))#">
			<CFPROCPARAM VALUE="#evaluate('arguments.frmstruct.temperaturescale#arguments.stpID#')#" cfsqltype="CF_SQL_VARCHAR">
			<cfif isdefined('arguments.frmstruct.consigneeTimeZone#arguments.stpID#') and len(evaluate('arguments.frmstruct.consigneeTimeZone#arguments.stpID#'))>
				<CFPROCPARAM VALUE="#evaluate('arguments.frmstruct.consigneeTimeZone#arguments.stpID#')#"  cfsqltype="CF_SQL_VARCHAR">
			<cfelse>
				<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR"  null="Yes">	
			</cfif>
			<cfif isdefined('arguments.frmstruct.CarrierEmailID#arguments.stpID#') and len(evaluate('arguments.frmstruct.CarrierEmailID#arguments.stpID#'))>
				<CFPROCPARAM VALUE="#evaluate('arguments.frmstruct.CarrierEmailID#arguments.stpID#')#"  cfsqltype="CF_SQL_VARCHAR">
			<cfelse>
				<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR"  null="Yes">	
			</cfif>
			<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR"  null="Yes">
			<cfif isdefined('arguments.frmstruct.carrierID2_#arguments.stpID#') and len(evaluate('arguments.frmstruct.carrierID2_#arguments.stpID#'))>
				<CFPROCPARAM VALUE="#evaluate('arguments.frmstruct.carrierID2_#arguments.stpID#')#"  cfsqltype="CF_SQL_VARCHAR">
			<cfelse>
				<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR"  null="Yes">	
			</cfif>

			<cfif isdefined('arguments.frmstruct.carrierID3_#arguments.stpID#') and len(evaluate('arguments.frmstruct.carrierID3_#arguments.stpID#'))>
				<CFPROCPARAM VALUE="#evaluate('arguments.frmstruct.carrierID3_#arguments.stpID#')#"  cfsqltype="CF_SQL_VARCHAR">
			<cfelse>
				<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR"  null="Yes">	
			</cfif>

			<cfif isdefined('arguments.frmstruct.thirdDriverCell#arguments.stpID#') and len(evaluate('arguments.frmstruct.thirdDriverCell#arguments.stpID#'))>
				<CFPROCPARAM VALUE="#evaluate('arguments.frmstruct.thirdDriverCell#arguments.stpID#')#"  cfsqltype="CF_SQL_VARCHAR">
			<cfelse>
				<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR"  null="Yes">	
			</cfif>	
			<cfif structKeyExists(arguments.frmstruct, "customDriverPayFlatRate#arguments.stpID#") AND IsNumeric(arguments.frmstruct["customDriverPayFlatRate#arguments.stpID#"])>
				<CFPROCPARAM VALUE="#arguments.frmstruct["customDriverPayFlatRate#arguments.stpID#"]#"  cfsqltype="CF_SQL_FLOAT">
			<cfelse>
				<CFPROCPARAM VALUE="0"  cfsqltype="CF_SQL_FLOAT">
			</cfif>

			<cfif structKeyExists(arguments.frmstruct, "customDriverPayFlatRate2_#arguments.stpID#") AND IsNumeric(arguments.frmstruct["customDriverPayFlatRate2_#arguments.stpID#"])>
				<CFPROCPARAM VALUE="#arguments.frmstruct["customDriverPayFlatRate2_#arguments.stpID#"]#"  cfsqltype="CF_SQL_FLOAT">
			<cfelse>
				<CFPROCPARAM VALUE="0"  cfsqltype="CF_SQL_FLOAT">
			</cfif>

			<cfif structKeyExists(arguments.frmstruct, "customDriverPayFlatRate3_#arguments.stpID#") AND IsNumeric(arguments.frmstruct["customDriverPayFlatRate3_#arguments.stpID#"])>
				<CFPROCPARAM VALUE="#arguments.frmstruct["customDriverPayFlatRate3_#arguments.stpID#"]#"  cfsqltype="CF_SQL_FLOAT">
			<cfelse>
				<CFPROCPARAM VALUE="0"  cfsqltype="CF_SQL_FLOAT">
			</cfif>

			<cfif structKeyExists(arguments.frmstruct, "customDriverPayPercentage#arguments.stpID#") AND IsNumeric(arguments.frmstruct["customDriverPayPercentage#arguments.stpID#"])>
				<CFPROCPARAM VALUE="#arguments.frmstruct["customDriverPayPercentage#arguments.stpID#"]#"  cfsqltype="CF_SQL_FLOAT">
			<cfelse>
				<CFPROCPARAM VALUE="0"  cfsqltype="CF_SQL_FLOAT">
			</cfif>

			<cfif structKeyExists(arguments.frmstruct, "customDriverPayPercentage2_#arguments.stpID#") AND IsNumeric(arguments.frmstruct["customDriverPayPercentage2_#arguments.stpID#"])>
				<CFPROCPARAM VALUE="#arguments.frmstruct["customDriverPayPercentage2_#arguments.stpID#"]#"  cfsqltype="CF_SQL_FLOAT">
			<cfelse>
				<CFPROCPARAM VALUE="0"  cfsqltype="CF_SQL_FLOAT">
			</cfif>

			<cfif structKeyExists(arguments.frmstruct, "customDriverPayPercentage3_#arguments.stpID#") AND IsNumeric(arguments.frmstruct["customDriverPayPercentage3_#arguments.stpID#"])>
				<CFPROCPARAM VALUE="#arguments.frmstruct["customDriverPayPercentage3_#arguments.stpID#"]#"  cfsqltype="CF_SQL_FLOAT">
			<cfelse>
				<CFPROCPARAM VALUE="0"  cfsqltype="CF_SQL_FLOAT">
			</cfif>
			<cfif structKeyExists(arguments.frmstruct, "chkCustomDriverPayFlatRate#arguments.stpID#")>
				<CFPROCPARAM VALUE="1"  cfsqltype="CF_SQL_INTEGER">
			<cfelseif structKeyExists(arguments.frmstruct, "chkCustomDriverPayPercentage#arguments.stpID#")>
				<CFPROCPARAM VALUE="2"  cfsqltype="CF_SQL_INTEGER">
			<cfelse>
				<CFPROCPARAM VALUE="0"  cfsqltype="CF_SQL_INTEGER">
			</cfif>
			<cfif structKeyExists(arguments.frmstruct, "chkCustomDriverPayFlatRate2_#arguments.stpID#")>
				<CFPROCPARAM VALUE="1"  cfsqltype="CF_SQL_INTEGER">
			<cfelseif structKeyExists(arguments.frmstruct, "chkCustomDriverPayPercentage2_#arguments.stpID#")>
				<CFPROCPARAM VALUE="2"  cfsqltype="CF_SQL_INTEGER">
			<cfelse>
				<CFPROCPARAM VALUE="0"  cfsqltype="CF_SQL_INTEGER">
			</cfif>
			<cfif structKeyExists(arguments.frmstruct, "chkCustomDriverPayFlatRate3_#arguments.stpID#")>
				<CFPROCPARAM VALUE="1"  cfsqltype="CF_SQL_INTEGER">
			<cfelseif structKeyExists(arguments.frmstruct, "chkCustomDriverPayPercentage3_#arguments.stpID#")>
				<CFPROCPARAM VALUE="2"  cfsqltype="CF_SQL_INTEGER">
			<cfelse>
				<CFPROCPARAM VALUE="0"  cfsqltype="CF_SQL_INTEGER">
			</cfif>
			<cfif isdefined('arguments.frmstruct.CarrierContactID#arguments.stpID#') and len(evaluate('arguments.frmstruct.CarrierContactID#arguments.stpID#'))>
				<CFPROCPARAM VALUE="#evaluate('arguments.frmstruct.CarrierContactID#arguments.stpID#')#"  cfsqltype="CF_SQL_VARCHAR">
			<cfelse>
				<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR"  null="Yes">	
			</cfif>

			<cfif isdefined('arguments.frmstruct.CarrierPhoneNo#arguments.stpID#') and len(evaluate('arguments.frmstruct.CarrierPhoneNo#arguments.stpID#'))>
				<CFPROCPARAM VALUE="#evaluate('arguments.frmstruct.CarrierPhoneNo#arguments.stpID#')#"  cfsqltype="CF_SQL_VARCHAR">
			<cfelse>
				<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR"  null="Yes">	
			</cfif>

			<cfif isdefined('arguments.frmstruct.CarrierPhoneNoExt#arguments.stpID#') and len(evaluate('CarrierPhoneNoExt#arguments.stpID#'))>
				<CFPROCPARAM VALUE="#evaluate('arguments.frmstruct.CarrierPhoneNoExt#arguments.stpID#')#"  cfsqltype="CF_SQL_VARCHAR">
			<cfelse>
				<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR"  null="Yes">	
			</cfif>

			<cfif isdefined('arguments.frmstruct.CarrierFax#arguments.stpID#') and len(evaluate('CarrierFax#arguments.stpID#'))>
				<CFPROCPARAM VALUE="#evaluate('arguments.frmstruct.CarrierFax#arguments.stpID#')#"  cfsqltype="CF_SQL_VARCHAR">
			<cfelse>
				<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR"  null="Yes">	
			</cfif>

			<cfif isdefined('arguments.frmstruct.CarrierFaxExt#arguments.stpID#') and len(evaluate('CarrierFaxExt#arguments.stpID#'))>
				<CFPROCPARAM VALUE="#evaluate('arguments.frmstruct.CarrierFaxExt#arguments.stpID#')#"  cfsqltype="CF_SQL_VARCHAR">
			<cfelse>
				<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR"  null="Yes">	
			</cfif>

			<cfif isdefined('arguments.frmstruct.CarrierTollFree#arguments.stpID#') and len(evaluate('CarrierTollFree#arguments.stpID#'))>
				<CFPROCPARAM VALUE="#evaluate('arguments.frmstruct.CarrierTollFree#arguments.stpID#')#"  cfsqltype="CF_SQL_VARCHAR">
			<cfelse>
				<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR"  null="Yes">	
			</cfif>

			<cfif isdefined('arguments.frmstruct.CarrierTollFreeExt#arguments.stpID#') and len(evaluate('CarrierTollFreeExt#arguments.stpID#'))>
				<CFPROCPARAM VALUE="#evaluate('arguments.frmstruct.CarrierTollFreeExt#arguments.stpID#')#"  cfsqltype="CF_SQL_VARCHAR">
			<cfelse>
				<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR"  null="Yes">	
			</cfif>

			<cfif isdefined('arguments.frmstruct.CarrierCell#arguments.stpID#') and len(evaluate('CarrierCell#arguments.stpID#'))>
				<CFPROCPARAM VALUE="#evaluate('arguments.frmstruct.CarrierCell#arguments.stpID#')#"  cfsqltype="CF_SQL_VARCHAR">
			<cfelse>
				<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR"  null="Yes">	
			</cfif>

			<cfif isdefined('arguments.frmstruct.CarrierCellExt#arguments.stpID#') and len(evaluate('CarrierCellExt#arguments.stpID#'))>
				<CFPROCPARAM VALUE="#evaluate('arguments.frmstruct.CarrierCellExt#arguments.stpID#')#"  cfsqltype="CF_SQL_VARCHAR">
			<cfelse>
				<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR"  null="Yes">	
			</cfif>

			<cfif isdefined('arguments.frmstruct.CarrierEmailID2_#arguments.stpID#') and len(evaluate('arguments.frmstruct.CarrierEmailID2_#arguments.stpID#'))>
				<CFPROCPARAM VALUE="#evaluate('arguments.frmstruct.CarrierEmailID2_#arguments.stpID#')#"  cfsqltype="CF_SQL_VARCHAR">
			<cfelse>
				<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR"  null="Yes">	
			</cfif>

			<cfif isdefined('arguments.frmstruct.CarrierContactID2_#arguments.stpID#') and len(evaluate('arguments.frmstruct.CarrierContactID2_#arguments.stpID#'))>
				<CFPROCPARAM VALUE="#evaluate('arguments.frmstruct.CarrierContactID2_#arguments.stpID#')#"  cfsqltype="CF_SQL_VARCHAR">
			<cfelse>
				<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR"  null="Yes">	
			</cfif>

			<cfif isdefined('arguments.frmstruct.CarrierPhoneNo2_#arguments.stpID#') and len(evaluate('arguments.frmstruct.CarrierPhoneNo2_#arguments.stpID#'))>
				<CFPROCPARAM VALUE="#evaluate('arguments.frmstruct.CarrierPhoneNo2_#arguments.stpID#')#"  cfsqltype="CF_SQL_VARCHAR">
			<cfelse>
				<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR"  null="Yes">	
			</cfif>

			<cfif isdefined('arguments.frmstruct.CarrierPhoneNoExt2_#arguments.stpID#') and len(evaluate('CarrierPhoneNoExt2_#arguments.stpID#'))>
				<CFPROCPARAM VALUE="#evaluate('arguments.frmstruct.CarrierPhoneNoExt2_#arguments.stpID#')#"  cfsqltype="CF_SQL_VARCHAR">
			<cfelse>
				<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR"  null="Yes">	
			</cfif>

			<cfif isdefined('arguments.frmstruct.CarrierFax2_#arguments.stpID#') and len(evaluate('CarrierFax2_#arguments.stpID#'))>
				<CFPROCPARAM VALUE="#evaluate('arguments.frmstruct.CarrierFax2_#arguments.stpID#')#"  cfsqltype="CF_SQL_VARCHAR">
			<cfelse>
				<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR"  null="Yes">	
			</cfif>

			<cfif isdefined('arguments.frmstruct.CarrierFaxExt2_#arguments.stpID#') and len(evaluate('CarrierFaxExt2_#arguments.stpID#'))>
				<CFPROCPARAM VALUE="#evaluate('arguments.frmstruct.CarrierFaxExt2_#arguments.stpID#')#"  cfsqltype="CF_SQL_VARCHAR">
			<cfelse>
				<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR"  null="Yes">	
			</cfif>

			<cfif isdefined('arguments.frmstruct.CarrierTollFree2_#arguments.stpID#') and len(evaluate('CarrierTollFree2_#arguments.stpID#'))>
				<CFPROCPARAM VALUE="#evaluate('arguments.frmstruct.CarrierTollFree2_#arguments.stpID#')#"  cfsqltype="CF_SQL_VARCHAR">
			<cfelse>
				<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR"  null="Yes">	
			</cfif>

			<cfif isdefined('arguments.frmstruct.CarrierTollFreeExt2_#arguments.stpID#') and len(evaluate('CarrierTollFreeExt2_#arguments.stpID#'))>
				<CFPROCPARAM VALUE="#evaluate('arguments.frmstruct.CarrierTollFreeExt2_#arguments.stpID#')#"  cfsqltype="CF_SQL_VARCHAR">
			<cfelse>
				<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR"  null="Yes">	
			</cfif>

			<cfif isdefined('arguments.frmstruct.CarrierCell2_#arguments.stpID#') and len(evaluate('CarrierCell2_#arguments.stpID#'))>
				<CFPROCPARAM VALUE="#evaluate('arguments.frmstruct.CarrierCell2_#arguments.stpID#')#"  cfsqltype="CF_SQL_VARCHAR">
			<cfelse>
				<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR"  null="Yes">	
			</cfif>

			<cfif isdefined('arguments.frmstruct.CarrierCellExt2_#arguments.stpID#') and len(evaluate('CarrierCellExt2_#arguments.stpID#'))>
				<CFPROCPARAM VALUE="#evaluate('arguments.frmstruct.CarrierCellExt2_#arguments.stpID#')#"  cfsqltype="CF_SQL_VARCHAR">
			<cfelse>
				<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR"  null="Yes">	
			</cfif>

			<cfif isdefined('arguments.frmstruct.CarrierEmailID3_#arguments.stpID#') and len(evaluate('arguments.frmstruct.CarrierEmailID3_#arguments.stpID#'))>
				<CFPROCPARAM VALUE="#evaluate('arguments.frmstruct.CarrierEmailID3_#arguments.stpID#')#"  cfsqltype="CF_SQL_VARCHAR">
			<cfelse>
				<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR"  null="Yes">	
			</cfif>

			<cfif isdefined('arguments.frmstruct.CarrierContactID3_#arguments.stpID#') and len(evaluate('arguments.frmstruct.CarrierContactID3_#arguments.stpID#'))>
				<CFPROCPARAM VALUE="#evaluate('arguments.frmstruct.CarrierContactID3_#arguments.stpID#')#"  cfsqltype="CF_SQL_VARCHAR">
			<cfelse>
				<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR"  null="Yes">	
			</cfif>

			<cfif isdefined('arguments.frmstruct.CarrierPhoneNo3_#arguments.stpID#') and len(evaluate('arguments.frmstruct.CarrierPhoneNo3_#arguments.stpID#'))>
				<CFPROCPARAM VALUE="#evaluate('arguments.frmstruct.CarrierPhoneNo3_#arguments.stpID#')#"  cfsqltype="CF_SQL_VARCHAR">
			<cfelse>
				<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR"  null="Yes">	
			</cfif>

			<cfif isdefined('arguments.frmstruct.CarrierPhoneNoExt3_#arguments.stpID#') and len(evaluate('CarrierPhoneNoExt3_#arguments.stpID#'))>
				<CFPROCPARAM VALUE="#evaluate('arguments.frmstruct.CarrierPhoneNoExt3_#arguments.stpID#')#"  cfsqltype="CF_SQL_VARCHAR">
			<cfelse>
				<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR"  null="Yes">	
			</cfif>

			<cfif isdefined('arguments.frmstruct.CarrierFax3_#arguments.stpID#') and len(evaluate('CarrierFax3_#arguments.stpID#'))>
				<CFPROCPARAM VALUE="#evaluate('arguments.frmstruct.CarrierFax3_#arguments.stpID#')#"  cfsqltype="CF_SQL_VARCHAR">
			<cfelse>
				<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR"  null="Yes">	
			</cfif>

			<cfif isdefined('arguments.frmstruct.CarrierFaxExt3_#arguments.stpID#') and len(evaluate('CarrierFaxExt3_#arguments.stpID#'))>
				<CFPROCPARAM VALUE="#evaluate('arguments.frmstruct.CarrierFaxExt3_#arguments.stpID#')#"  cfsqltype="CF_SQL_VARCHAR">
			<cfelse>
				<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR"  null="Yes">	
			</cfif>

			<cfif isdefined('arguments.frmstruct.CarrierTollFree3_#arguments.stpID#') and len(evaluate('CarrierTollFree3_#arguments.stpID#'))>
				<CFPROCPARAM VALUE="#evaluate('arguments.frmstruct.CarrierTollFree3_#arguments.stpID#')#"  cfsqltype="CF_SQL_VARCHAR">
			<cfelse>
				<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR"  null="Yes">	
			</cfif>

			<cfif isdefined('arguments.frmstruct.CarrierTollFreeExt3_#arguments.stpID#') and len(evaluate('CarrierTollFreeExt3_#arguments.stpID#'))>
				<CFPROCPARAM VALUE="#evaluate('arguments.frmstruct.CarrierTollFreeExt3_#arguments.stpID#')#"  cfsqltype="CF_SQL_VARCHAR">
			<cfelse>
				<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR"  null="Yes">	
			</cfif>

			<cfif isdefined('arguments.frmstruct.CarrierCell3_#arguments.stpID#') and len(evaluate('CarrierCell3_#arguments.stpID#'))>
				<CFPROCPARAM VALUE="#evaluate('arguments.frmstruct.CarrierCell3_#arguments.stpID#')#"  cfsqltype="CF_SQL_VARCHAR">
			<cfelse>
				<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR"  null="Yes">	
			</cfif>

			<cfif isdefined('arguments.frmstruct.CarrierCellExt3_#arguments.stpID#') and len(evaluate('CarrierCellExt3_#arguments.stpID#'))>
				<CFPROCPARAM VALUE="#evaluate('arguments.frmstruct.CarrierCellExt3_#arguments.stpID#')#"  cfsqltype="CF_SQL_VARCHAR">
			<cfelse>
				<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR"  null="Yes">	
			</cfif>
			<cfif isdefined('arguments.frmstruct.equipmentTrailer#arguments.stpID#') and len(evaluate('equipmentTrailer#arguments.stpID#'))>
				<CFPROCPARAM VALUE="#evaluate('arguments.frmstruct.equipmentTrailer#arguments.stpID#')#"  cfsqltype="CF_SQL_VARCHAR">
			<cfelse>
				<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR"  null="Yes">	
			</cfif>
			<cfprocresult name="qLastInsertedConsignee">
		</CFSTOREDPROC>
		<cfreturn qLastInsertedConsignee>
	</cffunction>

	<cffunction name="InsertLoadStopIntermodalImport" access="public" returntype="any">
		<cfargument name="lastInsertedStopId" type="string" required="yes">
		<cfargument name="frmstruct" type="struct" required="yes">

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
					<cfqueryparam value="#arguments.lastInsertedStopId#" cfsqltype="cf_sql_varchar">,
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
					<cfqueryparam value="#arguments.frmstruct.requestedDeliveryTime#" cfsqltype="cf_sql_varchar" null="#yesNoFormat(NOT len(trim(arguments.frmstruct.requestedDeliveryTime)))#">,
					<cfqueryparam value="#arguments.frmstruct.scheduledDeliveryDate#" cfsqltype="cf_sql_date">,
					<cfqueryparam value="#arguments.frmstruct.scheduledDeliveryTime#" cfsqltype="cf_sql_varchar" null="#yesNoFormat(NOT len(trim(arguments.frmstruct.scheduledDeliveryTime)))#">,
					<cfqueryparam value="#arguments.frmstruct.unloadingDelayDetentionStartDate#" cfsqltype="cf_sql_date">,
					<cfqueryparam value="#arguments.frmstruct.unloadingDelayDetentionStartTime#" cfsqltype="cf_sql_varchar" null="#yesNoFormat(NOT len(trim(arguments.frmstruct.unloadingDelayDetentionStartTime)))#">,
					<cfqueryparam value="#arguments.frmstruct.actualDeliveryDate#" cfsqltype="cf_sql_date">,
					<cfqueryparam value="#arguments.frmstruct.unloadingDelayDetentionEndDate#" cfsqltype="cf_sql_date">,
					<cfqueryparam value="#arguments.frmstruct.unloadingDelayDetentionEndTime#" cfsqltype="cf_sql_varchar" null="#yesNoFormat(NOT len(trim(arguments.frmstruct.unloadingDelayDetentionEndTime)))#">,
					<cfqueryparam value="#arguments.frmstruct.returnDate#" cfsqltype="cf_sql_date">,
					<cfqueryparam value="#arguments.frmstruct.pickUpAddress#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.frmstruct.deliveryAddress#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.frmstruct.emptyReturnAddress#" cfsqltype="cf_sql_varchar">
				)
		</cfquery>

		<cfreturn 1>
	</cffunction>

	<cffunction name="InsertLoadStopIntermodalImportStpID" access="public" returntype="any">
		<cfargument name="lastInsertedStopId" type="string" required="yes">
		<cfargument name="frmstruct" type="struct" required="yes">
		<cfargument name="stpID" type="string" required="yes">

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
					<cfqueryparam value="#arguments.lastInsertedStopId#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.stpID#" cfsqltype="cf_sql_integer">,
					<cfqueryparam value="#EVALUATE('arguments.frmstruct.dateDispatched#arguments.stpID#')#" cfsqltype="cf_sql_date">,
					<cfqueryparam value="#EVALUATE('arguments.frmstruct.steamShipLine#arguments.stpID#')#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#EVALUATE('arguments.frmstruct.eta#arguments.stpID#')#" cfsqltype="cf_sql_date">,
					<cfqueryparam value="#EVALUATE('arguments.frmstruct.oceanBillofLading#arguments.stpID#')#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#EVALUATE('arguments.frmstruct.actualArrivalDate#arguments.stpID#')#" cfsqltype="cf_sql_date">,
					<cfqueryparam value="#EVALUATE('arguments.frmstruct.seal#arguments.stpID#')#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#EVALUATE('arguments.frmstruct.customersReleaseDate#arguments.stpID#')#" cfsqltype="cf_sql_date">,
					<cfqueryparam value="#EVALUATE('arguments.frmstruct.vesselName#arguments.stpID#')#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#EVALUATE('arguments.frmstruct.freightReleaseDate#arguments.stpID#')#" cfsqltype="cf_sql_date">,
					<cfqueryparam value="#EVALUATE('arguments.frmstruct.dateAvailable#arguments.stpID#')#" cfsqltype="cf_sql_date">,
					<cfqueryparam value="#EVALUATE('arguments.frmstruct.demuggageFreeTimeExpirationDate#arguments.stpID#')#" cfsqltype="cf_sql_date">,
					<cfqueryparam value="#EVALUATE('arguments.frmstruct.perDiemFreeTimeExpirationDate#arguments.stpID#')#" cfsqltype="cf_sql_date">,
					<cfqueryparam value="#EVALUATE('arguments.frmstruct.pickupDate#arguments.stpID#')#" cfsqltype="cf_sql_date" null="#yesNoFormat(NOT len(EVALUATE('arguments.frmstruct.pickupDate#arguments.stpID#')))#">,
					<cfqueryparam value="#EVALUATE('arguments.frmstruct.requestedDeliveryDate#arguments.stpID#')#" cfsqltype="cf_sql_date">,
					<cfset requestedDeliveryTime = EVALUATE('arguments.frmstruct.requestedDeliveryTime#arguments.stpID#')>
					<cfqueryparam value="#EVALUATE('arguments.frmstruct.requestedDeliveryTime#arguments.stpID#')#" cfsqltype="cf_sql_varchar" null="#yesNoFormat(NOT len(requestedDeliveryTime))#">,
					<cfqueryparam value="#EVALUATE('arguments.frmstruct.scheduledDeliveryDate#arguments.stpID#')#" cfsqltype="cf_sql_date">,
					<cfset scheduledDeliveryTime = EVALUATE('arguments.frmstruct.scheduledDeliveryTime#arguments.stpID#')>
					<cfqueryparam value="#EVALUATE('arguments.frmstruct.scheduledDeliveryTime#arguments.stpID#')#" cfsqltype="cf_sql_varchar"  null="#yesNoFormat(NOT len(scheduledDeliveryTime))#">,
					<cfqueryparam value="#EVALUATE('arguments.frmstruct.unloadingDelayDetentionStartDate#arguments.stpID#')#" cfsqltype="cf_sql_date">,
					<cfset unloadingDelayDetentionStartTime = EVALUATE('arguments.frmstruct.unloadingDelayDetentionStartTime#arguments.stpID#')>
					<cfqueryparam value="#EVALUATE('arguments.frmstruct.unloadingDelayDetentionStartTime#arguments.stpID#')#" cfsqltype="cf_sql_varchar" null="#yesNoFormat(NOT len(unloadingDelayDetentionStartTime))#">,
					<cfqueryparam value="#EVALUATE('arguments.frmstruct.actualDeliveryDate#arguments.stpID#')#" cfsqltype="cf_sql_date">,
					<cfqueryparam value="#EVALUATE('arguments.frmstruct.unloadingDelayDetentionEndDate#arguments.stpID#')#" cfsqltype="cf_sql_date">,
					<cfset unloadingDelayDetentionEndTime = EVALUATE('arguments.frmstruct.unloadingDelayDetentionEndTime#arguments.stpID#')>
					<cfqueryparam value="#EVALUATE('arguments.frmstruct.unloadingDelayDetentionEndTime#arguments.stpID#')#" cfsqltype="cf_sql_varchar" null="#yesNoFormat(NOT len(unloadingDelayDetentionEndTime))#">,
					<cfqueryparam value="#EVALUATE('arguments.frmstruct.returnDate#arguments.stpID#')#" cfsqltype="cf_sql_date">,
					<cfqueryparam value="#EVALUATE('arguments.frmstruct.pickUpAddress#arguments.stpID#')#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#EVALUATE('arguments.frmstruct.deliveryAddress#arguments.stpID#')#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#EVALUATE('arguments.frmstruct.emptyReturnAddress#arguments.stpID#')#" cfsqltype="cf_sql_varchar">
				)
		</cfquery>

		<cfreturn 1>
	</cffunction>
</cfcomponent>