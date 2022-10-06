<cfcomponent output="true" extends="loadgateway">
<cfsetting showdebugoutput="no">

<cfif not structKeyExists(variables,"loadgatewayUpdate") and structkeyexists(request,"cfcpath")>
	<cfscript>variables.objLoadgatewayUpdate = #request.cfcpath#&".loadgatewayUpdate";</cfscript>
</cfif>
<cfif not structKeyExists(variables,"objCustomerGateway") and structkeyexists(request,"cfcpath")>
	<cfscript>variables.objCustomerGateway = #request.cfcpath#&".customergateway";</cfscript>
</cfif>

<cfif not structKeyExists(variables,"objPromilesGatewayTest") and structkeyexists(request,"cfcpath")>
	<cfscript>variables.objPromilesGatewayTest = #request.cfcpath#&".promiles";</cfscript>
</cfif>

<cfif not structKeyExists(variables,"objAlertGateway") and structkeyexists(request,"cfcpath")>
	<cfscript>variables.objAlertGateway = #request.cfcpath#&".alertgateway";</cfscript>
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
				<cfquery name="qryGetStatus" datasource="#variables.dsn#">
					select StatusText from LoadStatusTypes where StatusTypeID=
					<cfqueryparam value='#arguments.frmstruct.loadstatus#' cfsqltype="cf_sql_varchar">
				</cfquery>
				<cfif structKeyExists(arguments.frmstruct,"oldstatus") AND arguments.frmstruct.oldstatus NEQ "7. INVOICE" AND qryGetStatus.StatusText EQ '7. INVOICE'>
				
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
	<cfset var LastLoadId = "">
	<cfset var lastUpdatedShipCustomerID ="">
	<cfset var lastInsertedStopId = "">
	<cfset var lastUpdatedConsCustomerID ="">

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
	<cfinvoke method="GetTranscore" loadManualNo="#arguments.frmstruct.loadManualNo#" returnvariable="variables.datStatus">
	<cftransaction>
		<!--- Load Logging--->
		<cfinvoke method="LoadLogRegister" type="RunUSP_UpdateLoad" instance=1 whereList="#arguments.frmstruct.editid#">
		<!--- Load Logging--->
		<cfset var LastLoadId = "">
		<cfinvoke method="RunUSP_UpdateLoad" frmstruct="#frmstruct#" returnvariable="LastLoadId">
		<!--- Load Logging--->
		<cfinvoke method="LoadLogRegister" type="RunUSP_UpdateLoad" instance=2 whereList="#arguments.frmstruct.editid#">
		<!--- Load Logging--->
		<cfinvoke method="unLockLoad" LastLoadId="#LastLoadId#">
		<cfif isDefined("arguments.frmstruct.userDefinedForTrucking")>	
			<cfinvoke method="UpdateUserDefinedFieldTrucking" LastLoadId="#LastLoadId#" userDefinedForTrucking="#arguments.frmstruct.userDefinedForTrucking#">
		</cfif>
		<cfif isDefined("arguments.frmstruct.noOfTrips") and len(arguments.frmstruct.noOfTrips)>
			<cfinvoke method="UpdateLoadNoOfTrips" editid="#arguments.frmstruct.editid#" noOfTrips="#arguments.frmstruct.noOfTrips#">
		</cfif>
	</cftransaction>
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
	<cfinvoke method="LoadLogRegister" type="USP_UpdateLoadStop" instance=1 whereList="#LastLoadId#,0,1">
	<cfinvoke component="#variables.objLoadgatewayUpdate#" method="getlastStopId" ShipBlind="#ShipBlind#" lastUpdatedShipCustomerID="#lastUpdatedShipCustomerID#" frmstruct="#arguments.frmstruct#" LastLoadId="#LastLoadId#" returnvariable="lastStopIdValue"/>
	<cfinvoke method="LoadLogRegister" type="USP_UpdateLoadStop" instance=2 whereList="#LastLoadId#,0,1">
	<cfset lastInsertedStopId = lastStopIdValue.lastStopID>
	<!--- IMPORT Load Stop Starts Here ---->
	<cfif structKeyExists(arguments.frmstruct,"dateDispatched")>
		<cfinvoke method="SetImportLoadAddress" frmstruct="#arguments.frmstruct#" lastInsertedStopId="#lastInsertedStopId#"/>
	</cfif>
	<!--- IMPORT Load Stop Ends Here --->
	<!--- EXPORT Load Stop Starts Here ---->
	<cfif structKeyExists(arguments.frmstruct,"exportDateDispatched")>
		<cfinvoke method="SetExportLoadAddress" frmstruct="#arguments.frmstruct#" lastInsertedStopId="#lastInsertedStopId#"/>
	</cfif>
	<!--- EXPORT Load Stop Ends Here --->
	<!--- Editing Stop1 Consignee Details--->
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
	<cfset updateConsigneeStopLoadEdit(LastLoadId,lastUpdatedConsCustomerID,ConsBlind,variables.noOfDays1,arguments.frmstruct)>
	<!--- Load Logging--->
	<cfinvoke method="LoadLogRegister" type="USP_UpdateLoadStop" instance=2 whereList="#LastLoadId#,0,2">		
		<!--- Load Logging--->
		<cfif val(arguments.frmstruct.totalResult1) gt val(arguments.frmstruct.commoditityAlreadyCount1)>
			<cfloop from="1" to="#val(arguments.frmstruct.commoditityAlreadyCount1)#" index="num">
				<cfset UpdateLoadItemLoadEdit(arguments.frmstruct,num,lastInsertedStopId)>
			</cfloop>
			<cfset variables.startcommoditityAlreadyCount1=val(arguments.frmstruct.commoditityAlreadyCount1)+1>
			<cfloop from="#val(variables.startcommoditityAlreadyCount1)#" to="#val(arguments.frmstruct.totalResult1)#" index="num">
				<cfset InsertLoadItemLoadEdit(arguments.frmstruct,num,lastInsertedStopId)>
				<!--- Load Logging--->
				<cfset StructInsert(this.loadLogData, "New Load Item-" & num , {
							FieldLabel = "New Load Item. Number: " & num
						}, true)>
				<!--- Load Logging--->
			</cfloop>
		<cfelse>
			<cfset var num = "">
			<cfloop from="1" to="#val(arguments.frmstruct.totalResult1)#" index="num">
				<cfset UpdateLoadItemLoadEdit(arguments.frmstruct,num,lastInsertedStopId)>
			</cfloop>
	  	</cfif>
		<!--- EDIT 2nd and further Stops --->
		<cfset var stpID = "">
		<cfif listLen(arguments.frmstruct.shownStopArray)>
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
					<cfif isdefined('arguments.frmstruct.shipperPickupDate#stpID#') and isdefined('arguments.frmstruct.consigneePickupDate#stpID#') and IsValid("date",#EVALUATE('arguments.frmstruct.shipperPickupDate#stpID#')#) and IsValid("date",#EVALUATE('arguments.frmstruct.consigneePickupDate#stpID#')#)>
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
			 		<cfset qLastInsertedShipper = insertShipperStopLoadEdit(LastLoadId,lastUpdatedShipCustomerID,ShipBlind,variables.NewStopNo,variables.noOfDays,arguments.frmstruct,stpID)>
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
					<cfset insertConsigneeStopLoadEdit(LastLoadId,lastUpdatedConsCustomerID,ConsBlind,variables.NewStopNo,variables.noOfDays,arguments.frmstruct,stpID)>
					<!--- Load Logging--->
					<cfset StructInsert(this.loadLogData, "New Load Stop-" & variables.NewStopNo+1 & "-Type-2", {
								FieldLabel = "New Load Stop. Stop Number: " & variables.NewStopNo+1 & " Stop Type: 2"
							}, true)>
					<!--- Load Logging--->					
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
					<cfset qLastInsertedShipper = updateShipperStopLoadEditStopNo(LastLoadId,lastUpdatedShipCustomerID,ShipBlind,stopNo,variables.NewStopNo,variables.noOfDays,arguments.frmstruct,stpID)>
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
			   		<cfelseif structKeyExists(arguments.frmstruct, "consigneeValueContainer#stpID#")>
						<cfset lastUpdatedConsCustomerID =	evaluate("arguments.frmstruct.consigneeValueContainer#stpID#")>
					</cfif>
					<!--- Load Logging--->
					<cfinvoke method="LoadLogRegister" type="USP_UpdateLoadStop" instance=1 whereList="#LastLoadId#,#stopNo#,2">
					<!--- Load Logging--->	
					<cfset updateConsigneeStopLoadEditStopNo(LastLoadId,lastUpdatedConsCustomerID,ShipBlind,stopNo,variables.NewStopNo,variables.noOfDays,arguments.frmstruct,stpID)>			
					<!--- Load Logging--->
					<cfinvoke method="LoadLogRegister" type="USP_UpdateLoadStop" instance=2 whereList="#LastLoadId#,#stopNo#,2">
					<!--- Load Logging--->
				</cfif>
				<!--- IMPORT Load Stop Starts Here ---->
				<cfif structKeyExists(arguments.frmstruct,"dateDispatched#stpID#")>
					<cfinvoke method="SetImportLoadAddressStopNo" frmstruct="#arguments.frmstruct#" lastInsertedStopId="#lastInsertedStopId#" stpID="#stpID#"/>
				</cfif>
				<!--- IMPORT Load Stop Ends Here --->
				<!--- EXPORT Load Stop Starts Here ---->
				<cfif structKeyExists(arguments.frmstruct,"exportDateDispatched#stpID#")>
					<cfinvoke method="SetExportLoadAddressStopNo" frmstruct="#arguments.frmstruct#" lastInsertedStopId="#lastInsertedStopId#" stpID="#stpID#"/>
				</cfif>
				<!--- Insert Load Items---->
				<cfset var totalResultstops=val(evaluate("arguments.frmstruct.totalResult#stpID#"))>
				<cfset var commoditityAlreadyCountStops=val(evaluate("arguments.frmstruct.commoditityAlreadyCount#stpID#"))>
				<cfif val(totalResultstops) gt val(commoditityAlreadyCountStops) and  val(commoditityAlreadyCountStops) neq 1>
					<cfloop from="1" to="#val(commoditityAlreadyCountStops)#" index="num">
						 <cfset qty=VAL(evaluate("arguments.frmstruct.qty#stpID#_#num#"))>
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
						 <cfset custCharges =evaluate("arguments.frmstruct.custCharges#stpID#_#num#")>
						 <cfset custCharges = replace( replace( custCharges,"$","","ALL"),",","","ALL") >
						 <cfset carrCharges=evaluate("arguments.frmstruct.carrCharges#stpID#_#num#")>
						 <cfset carrCharges = replace( replace( carrCharges,"$","","ALL"),",","","ALL") >
						 <cfset CarrRateOfCustTotal =listfirst(evaluate("arguments.frmstruct.CarrierPer#stpID#_#num#"))>
						 <cfset CarrRateOfCustTotal = replace( CarrRateOfCustTotal,"%","","ALL") >
						 
						 <cfset directCost =evaluate("arguments.frmstruct.directCost#stpID#_#num#")>
						 <cfset directCost = replace( replace( directCost,"$","","ALL"),",","","ALL") >
						 <cfset directCostTotal =evaluate("arguments.frmstruct.directCostTotal#stpID#_#num#")>
						 <cfset directCostTotal = replace( replace( directCostTotal,"$","","ALL"),",","","ALL") >
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
							<CFPROCPARAM VALUE="#CarrRateOfCustTotal#" cfsqltype="CF_SQL_VARCHAR">
							<CFPROCPARAM VALUE="#isFee#" cfsqltype="CF_SQL_VARCHAR">
							<CFPROCPARAM VALUE="#Val(directCost)#" cfsqltype="cf_sql_money">
							<CFPROCPARAM VALUE="#val(directCostTotal)#" cfsqltype="cf_sql_money">
							<CFPROCPARAM VALUE="#dimensions#" cfsqltype="CF_SQL_VARCHAR">

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
 						 <cfset CustomerRate = replace( replace( CustomerRate,"(","","ALL"),")","","ALL") >
 						 <cfset CarrierRate = replace( replace( CarrierRate,"(","","ALL"),")","","ALL") >
						 <cfset custCharges=evaluate("arguments.frmstruct.custCharges#stpID#_#num#")>
						 <cfset custCharges = replace( replace( custCharges,"$","","ALL"),",","","ALL") >
						 <cfset carrCharges=evaluate("arguments.frmstruct.carrCharges#stpID#_#num#")>
						 <cfset carrCharges = replace( replace( carrCharges,"$","","ALL"),",","","ALL") >
						 <cfset CarrRateOfCustTotal=evaluate("arguments.frmstruct.CarrierPer#stpID#_#num#")>
						 <cfset CarrRateOfCustTotal = replace( CarrRateOfCustTotal,"%","","ALL") >
						 <cfif not IsNumeric(CarrRateOfCustTotal)><cfset CarrRateOfCustTotal = 0></cfif>
						 <cfif isdefined('arguments.frmstruct.isFee#stpID#_#num#')><cfset isFee=true><cfelse><cfset isFee=false></cfif>
						 <cfif not len(trim(CustomerRate))><cfset CustomerRate=0.00></cfif>
						 <cfif not len(trim(CarrierRate))><cfset CarrierRate=0.00></cfif>
						<cfset directCost =evaluate("arguments.frmstruct.directCost#stpID#_#num#")>
						<cfset directCost = replace( replace( directCost,"$","","ALL"),",","","ALL") >
						<cfset directCostTotal =evaluate("arguments.frmstruct.directCostTotal#stpID#_#num#")>
						<cfset directCostTotal = replace( replace( directCostTotal,"$","","ALL"),",","","ALL") >
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
						</cfstoredproc>
						<!--- Load Logging--->
						<cfset StructInsert(this.loadLogData, "New Load Item-" & num , {
									FieldLabel = "New Load Item. Number: " & num
								}, true)>
						<!--- Load Logging--->
					</cfloop>
				<cfelse>
					<cfloop from="1" to="#val(evaluate("arguments.frmstruct.totalResult#stpID#"))#" index="num">
						<cfif isdefined("arguments.frmstruct.qty#stpID#_#num#")>
						<cfset qty=evaluate("arguments.frmstruct.qty#stpID#_#num#")>
						<cfset unit=evaluate("arguments.frmstruct.unit#stpID#_#num#")>
						<cfif isDefined("arguments.frmstruct.description#stpID#_#num#")>
							<cfset description=evaluate("arguments.frmstruct.description#stpID#_#num#")>
						<cfelse>
							<cfset description="">
						</cfif>
						<cfif isDefined("arguments.frmstruct.dimensions#stpID#_#num#")>
							<cfset dimensions=evaluate("arguments.frmstruct.dimensions#stpID#_#num#")>
						<cfelse>
							<cfset dimensions="">
						</cfif>
						<cfif isdefined("arguments.frmstruct.weight#stpID#_#num#")>
							<cfset weight=VAL(replaceNoCase(evaluate("arguments.frmstruct.weight#stpID#_#num#"), ",", "","ALL"))>
						<cfelse>
							<cfset weight=0>
						</cfif>
						<cfset class=evaluate("arguments.frmstruct.class#stpID#_#num#")>
						<cfif isDefined("arguments.frmstruct.CustomerRate#stpID#_#num#")>
							<cfset CustomerRate=evaluate("arguments.frmstruct.CustomerRate#stpID#_#num#")>
						<cfelse>
							<cfset CustomerRate = 0>
						</cfif>
						<cfset CustomerRate = replace( replace( CustomerRate,"$","","ALL"),",","","ALL") >
						<cfset CarrierRate=evaluate("arguments.frmstruct.CarrierRate#stpID#_#num#")>
						<cfset CarrierRate = replace( replace( CarrierRate,"$","","ALL"),",","","ALL") >
						<cfset CustomerRate = replace( replace( CustomerRate,"(","","ALL"),")","","ALL") >
 						<cfset CarrierRate = replace( replace( CarrierRate,"(","","ALL"),")","","ALL") >
						<cfif isDefined("arguments.frmstruct.custCharges#stpID#_#num#")>
							<cfset custCharges=evaluate("arguments.frmstruct.custCharges#stpID#_#num#")>
						<cfelse>
							<cfset custCharges = 0>
						</cfif>
						<cfset custCharges = replace( replace( custCharges,"$","","ALL"),",","","ALL") >
						<cfset carrCharges=evaluate("arguments.frmstruct.carrCharges#stpID#_#num#")>
						<cfset carrCharges = replace( replace( carrCharges,"$","","ALL"),",","","ALL") >
						<cfif isDefined("arguments.frmstruct.CarrierPer#stpID#_#num#")>
							<cfset CarrRateOfCustTotal =listfirst(evaluate("arguments.frmstruct.CarrierPer#stpID#_#num#"))>
						<cfelse>
							<cfset CarrRateOfCustTotal = 0 >
						</cfif>
						<cfset CarrRateOfCustTotal = replace( CarrRateOfCustTotal,"%","","ALL") >
						<cfif isDefined("arguments.frmstruct.directCost#stpID#_#num#")>
							<cfset directCost =evaluate("arguments.frmstruct.directCost#stpID#_#num#")>
						<cfelse>
							<cfset directCost =0>
						</cfif>
						<cfset directCost = replace( replace( directCost,"$","","ALL"),",","","ALL") >
						<cfif isDefined("arguments.frmstruct.directCostTotal#stpID#_#num#")>
							<cfset directCostTotal =evaluate("arguments.frmstruct.directCostTotal#stpID#_#num#")>
						<cfelse>
							<cfset directCostTotal =0>
						</cfif>
						<cfset directCostTotal = replace( replace( directCostTotal,"$","","ALL"),",","","ALL") >
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
								<CFPROCPARAM VALUE="#CarrRateOfCustTotal#" cfsqltype="CF_SQL_VARCHAR">
								<CFPROCPARAM VALUE="#isFee#" cfsqltype="CF_SQL_VARCHAR">
								<CFPROCPARAM VALUE="#Val(directCost)#" cfsqltype="cf_sql_money">
								<CFPROCPARAM VALUE="#val(directCostTotal)#" cfsqltype="cf_sql_money">
								<CFPROCPARAM VALUE="#dimensions#" cfsqltype="CF_SQL_VARCHAR">
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
								<CFPROCPARAM VALUE="#CarrRateOfCustTotal#" cfsqltype="CF_SQL_VARCHAR">
								<CFPROCPARAM VALUE="#isFee#" cfsqltype="CF_SQL_VARCHAR">
								<CFPROCPARAM VALUE="#Val(directCost)#" cfsqltype="cf_sql_money">
								<CFPROCPARAM VALUE="#val(directCostTotal)#" cfsqltype="cf_sql_money">
								<CFPROCPARAM VALUE="#dimensions#" cfsqltype="CF_SQL_VARCHAR">
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
								<CFPROCPARAM VALUE="#CarrRateOfCustTotal#" cfsqltype="CF_SQL_VARCHAR">
								<CFPROCPARAM VALUE="#isFee#" cfsqltype="CF_SQL_VARCHAR">
								<CFPROCPARAM VALUE="#Val(directCost)#" cfsqltype="cf_sql_money">
								<CFPROCPARAM VALUE="#val(directCostTotal)#" cfsqltype="cf_sql_money">
								<CFPROCPARAM VALUE="#dimensions#" cfsqltype="CF_SQL_VARCHAR">
								<CFPROCRESULT NAME="qInsertedLoadItem">
							</cfstoredproc>
							<!--- Load Logging--->
								<cfinvoke method="LoadLogRegister" type="USP_UpdateLoadItem" instance=2 whereList="#lastInsertedStopId#,#num#,#stpID#">
							<!--- Load Logging--->
						</cfif>
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
		<cfquery name="qryGetStatus" datasource="#variables.dsn#">
			select StatusText from LoadStatusTypes where StatusTypeID=
			<cfqueryparam value='#arguments.frmstruct.loadstatus#' cfsqltype="cf_sql_varchar">
		</cfquery>
		<cfif qryGetStatus.StatusText eq "9. Cancelled">
			<cfset p_action='D' />
		</cfif>
		<cfif NOT StructKeyExists(arguments.frmstruct,"postCarrierRatetoloadboard")>
			<cfset IncludeCarierRate = 0>
		<cfelse>
			<cfset IncludeCarierRate = 1 >
		</cfif>
		<cfinvoke method="Posteverywhere" LoadId="#arguments.frmstruct.editid#" impref="#arguments.frmstruct.LoadNumber#" PEPcustomerKey="#arguments.frmstruct.PEPcustomerKey#" PEPsecretKey="#arguments.frmstruct.PEPsecretKey#" POSTACTION="#p_action#"  CARRIERRATE = "#arguments.frmstruct.CARRIERRATE#"    IncludeCarierRate="#IncludeCarierRate#"    returnvariable="request.postevrywhere" />
		<cfset Msg_postev=request.postevrywhere/>
		<cfset Msg=#request.postevrywhere#>
	<cfelseif  structKeyExists(arguments.frmstruct,"integratewithPEP") and  #arguments.frmstruct.integratewithPEP# eq 1 and NOT structKeyExists(arguments.frmstruct,"posttoloadboard") and structKeyExists(arguments.frmstruct,"ISPOST") and arguments.frmstruct.ISPOST EQ 1>
		<cfset p_action='D' />
		<cfif NOT StructKeyExists(arguments.frmstruct,"postCarrierRatetoloadboard")>
			<cfset IncludeCarierRate = 0>
		<cfelse>
			<cfset IncludeCarierRate = 1 >
		</cfif>
		<cfinvoke method="Posteverywhere" LoadId="#arguments.frmstruct.editid#" impref="#arguments.frmstruct.LoadNumber#" PEPcustomerKey="#arguments.frmstruct.PEPcustomerKey#" PEPsecretKey="#arguments.frmstruct.PEPsecretKey#" POSTACTION="#p_action#"  CARRIERRATE = "#arguments.frmstruct.CARRIERRATE#"    IncludeCarierRate="#IncludeCarierRate#"    returnvariable="request.postevrywhere" />
		<cfset Msg_postev=request.postevrywhere/>
		<cfset Msg=#request.postevrywhere#>	
	</cfif>
	<!-----------pep CALL---->
	<!-----Begin : DirectFreight Integration-------->
	<cfset MsgDF=postToDirectFrieght(arguments.frmstruct)>
	<!-----End : DirectFreight Integration-------->

	<!-----transcore 360 webservice Call-------->
	<cfif structKeyExists(arguments.frmstruct,"integratewithTran360") and  arguments.frmstruct.integratewithTran360 EQ 1 AND structKeyExists(arguments.frmstruct,"posttoTranscore")>
			<cfif structKeyExists(arguments.frmstruct,"IsTransCorePst") AND arguments.frmstruct.IsTransCorePst EQ 1>
				<!---<cfset p_action = 'U'>---->
				<cfset p_action='D'>
				<cfinvoke method="Transcore360Webservice"  LoadId="#arguments.frmstruct.editid#" impref="#arguments.frmstruct.loadManualNo#" trans360Usename="#arguments.frmstruct.trans360Usename#" trans360Password="#arguments.frmstruct.trans360Password#" POSTACTION="#p_action#" returnvariable="request.Transcore360Webservice" />
				<cfset p_action = 'A'>
				<cfif NOT StructKeyExists(arguments.frmstruct,"postCarrierRatetoTranscore")>
					<cfset IncludeCarierRate = 0>
				<cfelse>
					<cfset IncludeCarierRate = arguments.frmstruct.postCarrierRatetoTranscore >
				</cfif>
				<cfinvoke method="Transcore360Webservice"  LoadId="#arguments.frmstruct.editid#" impref="#arguments.frmstruct.loadManualNo#" trans360Usename="#arguments.frmstruct.trans360Usename#" trans360Password="#arguments.frmstruct.trans360Password#" POSTACTION="#p_action#"  IncludeCarierRate="#IncludeCarierRate#" CARRIERRATE="#arguments.frmstruct.CARRIERRATE#" returnvariable="request.Transcore360Webservice" Refreshed="1"/>
			<cfelse>
				<cfset p_action = 'A'>
				<cfif NOT StructKeyExists(arguments.frmstruct,"postCarrierRatetoTranscore")>
					<cfset IncludeCarierRate = 0>
				<cfelse>
					<cfset IncludeCarierRate = arguments.frmstruct.postCarrierRatetoTranscore >
				</cfif>
				<cfinvoke method="Transcore360Webservice"  LoadId="#arguments.frmstruct.editid#" impref="#arguments.frmstruct.loadManualNo#" trans360Usename="#arguments.frmstruct.trans360Usename#" trans360Password="#arguments.frmstruct.trans360Password#" POSTACTION="#p_action#"  IncludeCarierRate="#IncludeCarierRate#" CARRIERRATE="#arguments.frmstruct.CARRIERRATE#" returnvariable="request.Transcore360Webservice" />
			</cfif>
			<!--- change by sp --->
			<cfset Msg=#request.Transcore360Webservice#>
			<!--- change by sp --->
		<cfelseif structKeyExists(arguments.frmstruct,"integratewithTran360") and  arguments.frmstruct.integratewithTran360 EQ 1  AND arguments.frmstruct.IsTransCorePst EQ 1 AND NOT structKeyExists(arguments.frmstruct,"posttoTranscore")>
			<cfset p_action='D'>
		<cfinvoke method="Transcore360Webservice"  LoadId="#arguments.frmstruct.editid#" impref="#arguments.frmstruct.loadManualNo#" trans360Usename="#arguments.frmstruct.trans360Usename#" trans360Password="#arguments.frmstruct.trans360Password#" POSTACTION="#p_action#" returnvariable="request.Transcore360Webservice" />
		<cfset Msg=request.Transcore360Webservice>
		</cfif>
		<!--- Validation for Unauthorised users try to update on Transcore --->
		<cfif NOT structKeyExists(arguments.frmstruct,"integratewithTran360") AND structKeyExists(arguments.frmstruct,"posttoTranscore")>
			<cfif not variables.datStatus>
				<cfset msg = "There is a problem in logging to Dat Loadboard">
				<cfquery name="TransFlaginsert" datasource="#variables.dsn#">
					update Loads SET IsTransCorePst=0, Trans_Sucess_Flag=0 WHERE LoadID=<cfqueryparam value="#arguments.frmstruct.editid#" cfsqltype="cf_sql_varchar">
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
		<cfset ITS_msg = ITSWebservice(arguments.frmstruct.LoadNumber, p_action, arguments.frmstruct.ITSUsername, arguments.frmstruct.ITSPassword, arguments.frmstruct.ITSIntegrationID,variables.loadNumber,arguments.frmstruct.editid,session.CompanyID,application.dsn,session.empid,IncludeCarierRate,arguments.frmstruct.CARRIERRATE)>
		<!--- <cfset ITS_msg="ITS Says : "&ITS_msg /> --->
		<!--- change by sp --->
	<cfelseif structKeyExists(arguments.frmstruct,"integratewithITS") and  arguments.frmstruct.integratewithITS EQ 1 AND structKeyExists(arguments.frmstruct,"IsITSPst") AND arguments.frmstruct.IsITSPst EQ 1 AND NOT structKeyExists(arguments.frmstruct,"posttoITS")>
		<cfset p_action = 'D'>
		<cfset ITS_msg = ITSWebservice(arguments.frmstruct.LoadNumber, p_action, arguments.frmstruct.ITSUsername, arguments.frmstruct.ITSPassword, arguments.frmstruct.ITSIntegrationID,variables.loadNumber,arguments.frmstruct.editid,session.CompanyID,application.dsn,session.empid)>
		<!--- <cfset ITS_msg="ITS Says : "&ITS_msg /> --->
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
				<cfif equipment EQ "" AND form.equipment eq ""><cfif msg2 neq '1'><cfset msg2 = msg2 &','& "Please select equipment for stop #stpID# for posting 123Loadboard"><cfelse><cfset msg2 ="Please select equipment for stop #stpID# for posting 123Loadboard"></cfif></cfif>
				<cfset pickUpDate= dateFormat(evaluate("form.shipperPickupDate#stpID#"), "yyyymmdd")>
				<cfif today GT pickUpDate ><cfif msg2 neq '1'><cfset msg2 = msg2 &','& "Please enter pickup date after today for stop #stpID# for posting 123Loadboard"><cfelse><cfset msg2 = "Please enter pickup date after today for stop #stpID# for posting 123Loadboard"></cfif></cfif>
				<cfset consigneePickupDate= dateFormat(evaluate("form.consigneePickupDate#stpID#"), "yyyymmdd")>
				<cfif today GT consigneePickupDate ><cfif msg2 neq '1'><cfset msg2 = msg2 &','& "Please enter consignee Pickup Date date after today for stop #stpID# for posting 123Loadboard"><cfelse><cfset msg2 = "Please enter consignee Pickup Date date after today for stop #stpID# for posting 123Loadboard"></cfif></cfif>
			</cfloop>
		</cfif>
		<cfif  msg2 NEQ '1'>
			<cfquery name="LoadBoard123Flaginsert" datasource="#variables.dsn#">
				update Loads SET postto123loadboard=0 WHERE LoadID=<cfqueryparam value="#arguments.frmstruct.editid#" cfsqltype="cf_sql_varchar">
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
			select proMilesStatus from systemconfig
			where CompanyID=<cfqueryparam cfsqltype="cf_sql_varchar" value="#session.CompanyID#">
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
	<cfset CarrierLoadStatusLaneSave(LastLoadId,arguments.frmstruct.oldStatusVal)>
	<cfset saveCarrierQuoteLocal(arguments.frmstruct)>

	<cfif structKeyExists(arguments.frmstruct,"oldStatusVal") AND arguments.frmstruct.oldStatusVal NEQ arguments.frmstruct.loadStatus AND request.qgetsystemsetupoptions.StatusUpdateEmailOption EQ 0>
		<cfset SendLoadEmailUpdate(LastLoadId,arguments.frmstruct.loadStatus)>
	</cfif>
	<cfif structKeyExists(arguments.frmstruct,"MinimumMarginReached") AND arguments.frmstruct.MinimumMarginReached EQ 0 AND request.qgetsystemsetupoptions.MinMarginOverrideApproval EQ 1 AND structKeyExists(arguments.frmstruct,"RateApprovalNeeded") AND arguments.frmstruct.RateApprovalNeeded EQ 0>
		<cfinvoke component="#variables.objAlertGateway#" method="createAlert" CreatedBy="#session.EmpID#" CompanyID="#session.CompanyID#" Description="Load Margin Override" AssignedType="Role" AssignedTo="Administrator" Type="Load" TypeId="#LastLoadId#"  Reference="#arguments.frmstruct.LoadNumber#"/>
	<cfelseif structKeyExists(arguments.frmstruct,"MinimumMarginReached") AND arguments.frmstruct.MinimumMarginReached EQ 1 AND structKeyExists(arguments.frmstruct,"RateApprovalNeeded") AND arguments.frmstruct.RateApprovalNeeded EQ 1>
		<cfinvoke component="#variables.objAlertGateway#" method="deleteAlert" TypeId="#LastLoadId#" />
	</cfif>
	<cfif request.qgetsystemsetupoptions.EDispatchOptions EQ 0>
		<cfinvoke method="sendPushNotification" Driver1Cell="#replaceNoCase(arguments.frmstruct.driverCell, "-", "","ALL")#" Driver2Cell="#replaceNoCase(arguments.frmstruct.secDriverCell, "-", "","ALL")#" LoadID="#LastLoadId#" LoadNumber="#arguments.frmstruct.LoadNumber#"/>
	</cfif>
	<cfset session.P44MSG = checkProject44Local(arguments.frmstruct)>
	<cfset Msg='#Msg_postev#'&'~~'&'#Msg#' & '~~' & ITS_msg & '~~' & msg2& '~~' & msg3 & '~~' & variables.promilesRes & '~~' & MsgDF>
	<cfreturn Msg>

</cffunction>

<cffunction name="checkProject44Local" access="public" returntype="any">
	<cfargument name="frmstruct" type="struct" required="yes">
	<cfset P44MSG = ''>
	<cfif request.qGetSystemSetupOptions.project44>
		<cfquery name="qGetLoadproject44" datasource="#Application.dsn#">
			SELECT PushDataToProject44Api FROM Loads WHERE LoadID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.frmstruct.editid#">
		</cfquery>

		<cfif qGetLoadproject44.PushDataToProject44Api>
			<cfloop from="1" to="#arguments.frmstruct.totalstop#" index="stpID">
				<cfif stpID EQ 1>
					<cfset stopID = ''>
					<cfset stopno = 0>
				<cfelse>
					<cfset stopID = stpID>
					<cfset stopno = stpID>
				</cfif>

				<cfif isdefined('oldShipperTimeIn#stopID#') AND evaluate('oldShipperTimeIn#stopID#') NEQ evaluate('shipperTimeIn#stopID#') AND len(trim(evaluate('shipperTimeIn#stopID#')))>
					<cfinvoke method="sendProject44Local" loadid="#arguments.frmstruct.editid#" stopno="#stopno#" LoadType="1" event="ARRIVED" dsn="#application.dsn#" empid="#session.empid#" returnvariable="P44MSG">
				</cfif>

				<cfif isdefined('oldShipperTimeOut#stopID#') AND evaluate('oldShipperTimeOut#stopID#') NEQ evaluate('shipperTimeOut#stopID#') AND len(trim(evaluate('shipperTimeOut#stopID#')))>
					<cfinvoke method="sendProject44Local" loadid="#arguments.frmstruct.editid#" stopno="#stopno#" LoadType="1" event="DEPARTED" dsn="#application.dsn#" empid="#session.empid#"  returnvariable="P44MSG">
				</cfif>

				<cfif isdefined('oldConsigneeTimeIn#stopID#') AND evaluate('oldConsigneeTimeIn#stopID#') NEQ evaluate('ConsigneeTimeIn#stopID#') AND len(trim(evaluate('ConsigneeTimeIn#stopID#')))>
					<cfinvoke method="sendProject44Local" loadid="#arguments.frmstruct.editid#" stopno="#stopno#" LoadType="2" event="ARRIVED" dsn="#application.dsn#" empid="#session.empid#"  returnvariable="P44MSG">
				</cfif>

				<cfif isdefined('oldConsigneeTimeOut#stopID#') AND evaluate('oldConsigneeTimeOut#stopID#') NEQ evaluate('ConsigneeTimeOut#stopID#') AND len(trim(evaluate('ConsigneeTimeOut#stopID#')))>
					<cfinvoke method="sendProject44Local" loadid="#arguments.frmstruct.editid#" stopno="#stopno#" LoadType="2" event="DEPARTED" dsn="#application.dsn#" empid="#session.empid#"  returnvariable="P44MSG">
				</cfif>

			</cfloop>
		</cfif>
	</cfif>
	<cfreturn P44MSG>
</cffunction>

<cffunction name="saveCarrierQuoteLocal" access="public" returntype="any">
	<cfargument name="frmstruct" type="struct" required="yes">

	<cfloop from="1" to="#val(arguments.frmstruct.totalStop)#" index="stpID">
		<cfif isDefined('quoteCarrierID#stpID#') AND len(trim(evaluate('quoteCarrierID#stpID#')))>
			<cfinvoke method="saveCarrierQuote" returnvariable="result">
				<cfinvokeargument name="CarrierQuoteID" value="#evaluate('CarrierQuoteID#stpID#')#">
				<cfinvokeargument name="loadID" value="#form.editid#">
				<cfinvokeargument name="StopNo" value="#stpID#">
				<cfinvokeargument name="Amount" value="#replaceNoCase(replaceNoCase(evaluate('quoteAmount#stpID#'),'$',''),',','','ALL')#">
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
				SELECT EDISCAC,BolNum,LoadNumber,receiverid,CustomerID AS PayerId,LoadID FROM Loads
				where loadid=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.frmstruct.editid#">
			</cfquery>
			<cfif len(trim(qGetLoadDetails.EDISCAC)) AND len(trim(qGetLoadDetails.BolNum))>
				<cfquery name="qInsEDI990" datasource="#Application.dsn#">
					INSERT INTO EDI990(lm_EDISetup_SCAC,lm_Loads_BOL,ReservationActionCode,Processed,CreatedDate,ModifiedDate,receiverID,LoadID) 
					VALUES(
						<cfqueryparam cfsqltype="cf_sql_varchar" value='#qGetLoadDetails.EDISCAC#'>,
						<cfqueryparam cfsqltype="cf_sql_varchar" value='#qGetLoadDetails.BolNum#'>,
						<cfqueryparam cfsqltype="cf_sql_varchar" value='#ResActCode#'>,
						0,getdate(),getdate(),
						<cfqueryparam cfsqltype="cf_sql_varchar" value='#qGetLoadDetails.receiverid#'>,
						<cfqueryparam cfsqltype="cf_sql_varchar" value='#qGetLoadDetails.LoadID#'>
						)
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
				           ,CustomerID
				           ,ReceiverID
						)
					VALUES(newid()
						,<cfqueryparam value="#qGetLoadDetails.BolNum#" cfsqltype="cf_sql_varchar">
						,<cfqueryparam value="#description#" cfsqltype="cf_sql_varchar">
						,getdate()
						,<cfqueryparam value="#LoadNumber#" cfsqltype="CF_SQL_INTEGER">
						,<cfqueryparam value="#doctype#" cfsqltype="cf_sql_varchar">
						,getdate()
						,<cfqueryparam cfsqltype="cf_sql_varchar" value='#qGetLoadDetails.PayerID#'>
						,<cfqueryparam cfsqltype="cf_sql_varchar" value='#qGetLoadDetails.ReceiverID#'>
						)
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
					,ISNULL((select ECM.receiverID from EDICustomerIDMapping ECM WHERE  ECM.lm_Customers_CustomerCode = L.CustomerID),L.receiverid) AS receiverid,
					,LS.IdentityCode as ShipperIdentificationCode
					,EDI.lm_loadstops_contactperson as ShipperName
					,L.CustomerMilesCharges as MilesCharge
					,L.CustFlatRate as CustFlatRate  
					FROM loads L
					LEFT JOIN LoadStops LS ON L.LoadID = LS.LoadID
					INNER JOIN edi204stops EDI on edi.lm_Loads_BOL=L.BolNum 
					and edi.Name = ls.CustName
					and ( LoadType=1 and edi.lm_LoadStops_LoadType in ('LD','CL','PL' ) 
 					or LoadType=2 and edi.lm_LoadStops_LoadType in ('CU','UL','PU' ) )
					LEFT JOIN LoadStopCommodities LSC ON LS.LoadStopID = LSC.LoadStopID
				WHERE L.loadid=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.frmstruct.editid#">
				ORDER BY LS.StopNo,LS.LoadType,LSC.SrNo
			</cfquery>

			<cfif len(getLoadDetails.EDISCAC) AND getLoadDetails.ediInvoiced EQ 0>

			<cfset cust_total_charge =  getLoadDetails.MilesCharge + getLoadDetails.CustFlatRate + getLoadDetails.Total_Charge_LineDetails>
			
			<cfif cust_total_charge NEQ getLoadDetails.TotalCustomerCharges>
				
				<cfset Validate_error="Your load has been saved but the Load Status was not updated because the EDI 210 data failed it's integrity check. Please call Load Manager technical support to get this issue resolved.">
					<cfquery name="qryUpdateOldStatus" datasource="#variables.dsn#">
						UPDATE Loads SET StatusTypeID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#frmstruct.oldstatusval#">
						WHERE Loadid=<cfqueryparam value="#arguments.frmstruct.editid#" cfsqltype="cf_sql_varchar">
					</cfquery>
				<cfreturn Validate_error>
				
			</cfif>

			<cfquery name="qInsertEDI210" datasource="#Application.dsn#" result="resultInsertEDI210">
					INSERT INTO EDI210 (lm_Loads_LoadNumber,lm_Loads_BOL,Shipment_Method_Of_Payment,lm_Loads_InvoiceDate,lm_Loads_TotalCustomerCharges,lm_LoadStops_NewDeliveryDate,lm_EDISetup_SCAC,Reference_Identification_Qualifier,lm_Loads_CustomerPONo,lm_Loads_NewPickupDate,Total_Weight,Weight_Qualifier,Total_Charge,Lading_Quantity,Weight_Unit_Code,lm_LoadStops_NewDeliveryTime,PODSignature,receiverID,ShipperName,ShipperIdentificationCode,LoadID)
					VALUES (
						<cfqueryparam value="#getLoadDetails.LoadNumber#" cfsqltype="cf_sql_varchar">,
						<cfqueryparam value="#getLoadDetails.BOLNum#" cfsqltype="cf_sql_varchar">,
						<cfqueryparam value="#getLoadDetails.ShipmentMethodOfPayment#" cfsqltype="cf_sql_varchar">,
						<cfqueryparam cfsqltype="cf_sql_varchar" null="#not len(getLoadDetails.InvoiceDate)#" value="#DateFormat(getLoadDetails.InvoiceDate,'yyyymmdd')#">,
						<cfqueryparam cfsqltype="cf_sql_integer" null="#not len(getLoadDetails.TotalCustomerCharges)#" value="#getLoadDetails.TotalCustomerCharges*100#">,
						<cfqueryparam cfsqltype="cf_sql_varchar" null="#not len(getLoadDetails.NewDeliveryDate)#" value="#DateFormat(getLoadDetails.NewDeliveryDate,'yyyymmdd')#">,
						<cfqueryparam value="#getLoadDetails.EDISCAC#" cfsqltype="cf_sql_varchar">,
						'PO',
						<cfqueryparam value="#getLoadDetails.CustomerPONo#" cfsqltype="cf_sql_varchar">,
						<cfqueryparam value="#DateFormat(getLoadDetails.NewPickupDate,'yyyymmdd')#" cfsqltype="cf_sql_varchar">,
						<cfqueryparam value="#getLoadDetails.Total_Weight#" cfsqltype="cf_sql_varchar">,
						'G',
						<cfqueryparam cfsqltype="cf_sql_integer" null="#not len(getLoadDetails.TotalCustomerCharges)#" value="#getLoadDetails.TotalCustomerCharges*100#">,
						<cfqueryparam value='#getLoadDetails.Lading_Quantity#' cfsqltype="cf_sql_varchar">,
						'L',
						<cfqueryparam value='#getLoadDetails.NewDeliveryTime#' cfsqltype="cf_sql_varchar">,
						<cfqueryparam value='#getLoadDetails.PODSignature#' cfsqltype="cf_sql_varchar">,
						<cfqueryparam value='#getLoadDetails.receiverID#' cfsqltype="cf_sql_varchar">,
						<cfqueryparam value='#getLoadDetails.ShipperName#' cfsqltype="cf_sql_varchar">,
						<cfqueryparam value='#ShipperIdentificationCode.ShipperName#' cfsqltype="cf_sql_varchar">,
						<cfqueryparam value='#arguments.frmstruct.editid#' cfsqltype="cf_sql_varchar">
						)
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
							VALUES(
								<cfqueryparam value="#getLoadDetails.BolNum#" cfsqltype="cf_sql_varchar">,
								<cfqueryparam value="#getLoadDetails.EDIstopno#" cfsqltype="cf_sql_varchar">,
								<cfqueryparam value="#LoadTypeReason#" cfsqltype="cf_sql_varchar">,
								<cfqueryparam value="#local.TotalStopCommWeight#" cfsqltype="cf_sql_varchar">,
								'G',
								<cfqueryparam value="#local.TotalStopCommQty#" cfsqltype="cf_sql_varchar">,
								<cfqueryparam value="#LoadTypeCode#" cfsqltype="cf_sql_varchar">,
								<cfqueryparam value="#CustName#" cfsqltype="cf_sql_varchar">,
								<cfqueryparam value="#LoadTypeQualifier#" cfsqltype="cf_sql_varchar">,
								<cfqueryparam value="#getLoadDetails.Address#" cfsqltype="cf_sql_varchar">,
								<cfqueryparam value="#getLoadDetails.City#" cfsqltype="cf_sql_varchar">,
								<cfqueryparam value="#getLoadDetails.StateCode#" cfsqltype="cf_sql_varchar">,
								<cfqueryparam value="#getLoadDetails.PostalCode#" cfsqltype="cf_sql_varchar">,
								'US',
								<cfqueryparam value="#getLoadDetails.receiverID#" cfsqltype="cf_sql_varchar">
							)
						</cfquery>
						<cfset local.prevStopNo = getLoadDetails.StopNo>
						<cfset local.prevTotalStopCommWeight = getLoadDetails.TotalStopCommWeight>
						<cfset local.prevTotalStopCommQty = getLoadDetails.TotalStopCommQty>
						<cfset local.StopNo++>
					</cfif>

					<cfif getLoadDetails.LoadType EQ 1 AND trim(getLoadDetails.CustRate) GT 0>				
						<cfquery name="qgetEDI210LineDetails" datasource="#Application.dsn#">
							select isnull(max(Assigned_Number),0)+1 as assign_no from EDI210LineDetails where lm_Loads_BOL=<cfqueryparam value="#getLoadDetails.BolNum#" cfsqltype="cf_sql_varchar">
						</cfquery>
						<cfset assign_no = qgetEDI210LineDetails.assign_no>			

						<cfquery name="qInsertEDI210LineDetails" datasource="#Application.dsn#">
							INSERT INTO EDI210LineDetails(Assigned_Number,Lading_Line_Item_Number,lm_LoadStopsCommodities_Description,Rated_as_Quantity,Rated_as_Qualifier,lm_LoadStopCommodities_weight,Weight_Qualifier,[lm_LoadStopsCommodities_Quantity-1],[Packing_Form_Code-1],[Weight_Unit_Code-1],[Line_Quantity-1]
							,[lm_LoadStopsCommodities_Quantity-2],[Packing_Form_Code-2],[Weight_Unit_Code-2],[Line_Quantity-2],[Packing_Form_Code-3],lm_LoadStopCommodities_CustRate,Rate_Qualifier,lm_LoadStopCommodities_CustCharges,lm_loads_BOL,receiverID,CreatedDate,ModifiedDate)
							VALUES(
								<cfqueryparam value="#assign_no#" cfsqltype="cf_sql_varchar">,
								<cfqueryparam value="#assign_no#" cfsqltype="cf_sql_varchar">,
								<cfqueryparam value="#getLoadDetails.Description#" cfsqltype="cf_sql_varchar">,
								<cfqueryparam value="#getLoadDetails.Qty#" cfsqltype="cf_sql_varchar">,
								'LC',
								<cfqueryparam value="#getLoadDetails.weight#" cfsqltype="cf_sql_varchar">,
								'G',
								<cfqueryparam value="#getLoadDetails.Qty#" cfsqltype="cf_sql_varchar">,
								'PLT','L',
								<cfqueryparam value="#getLoadDetails.Qty#" cfsqltype="cf_sql_varchar">,
								<cfqueryparam value="#getLoadDetails.Qty#" cfsqltype="cf_sql_varchar">,
								'PLT','L',
								<cfqueryparam value="#getLoadDetails.Qty#" cfsqltype="cf_sql_varchar">,
								'PLT',
								<cfqueryparam value="#trim(getLoadDetails.CustRate)#" cfsqltype="cf_sql_varchar">,
								'FR',
								<cfqueryparam cfsqltype="cf_sql_integer" null="#not len(getLoadDetails.CustCharges)#" value="#getLoadDetails.CustCharges*100#">,
								<cfqueryparam value="#getLoadDetails.BolNum#" cfsqltype="cf_sql_varchar">,
								<cfqueryparam value="#getLoadDetails.receiverID#" cfsqltype="cf_sql_varchar">,
								getDate(),getdate())
						</cfquery>
					</cfif>
				</cfloop>

				<cfif getLoadDetails.RecordCount>

				<cfif getLoadDetails.CustFlatRate GT 0>
					<cfquery name="qgetEDI210LineDetails" datasource="#Application.dsn#">
						select isnull(max(Assigned_Number),0)+1 as assign_no from EDI210LineDetails where lm_Loads_BOL=<cfqueryparam value="#getLoadDetails.BolNum#" cfsqltype="cf_sql_varchar">
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
							VALUES(
								<cfqueryparam value="#assign_no#" cfsqltype="cf_sql_varchar">,
								<cfqueryparam value="#assign_no#" cfsqltype="cf_sql_varchar">,
								'Flat Rate','1','LC','0','G','1','PLT','L','1','1','PLT','L','1','PLT',
								<cfqueryparam value='#trim(getLoadDetails.CustFlatRate)#' cfsqltype="cf_sql_varchar">,
								'FR',
								<cfqueryparam cfsqltype="cf_sql_integer" null="#not len(getLoadDetails.CustFlatRate)#" value="#getLoadDetails.CustFlatRate*100#">,
								<cfqueryparam value="#getLoadDetails.BolNum#" cfsqltype="cf_sql_varchar">,
								<cfqueryparam value="#getLoadDetails.receiverID#" cfsqltype="cf_sql_varchar">,
								getDate(),getdate())
						</cfquery>
					</cfif>

					<cfif getLoadDetails.MilesCharge GT 0>
					<cfquery name="qgetEDI210LineDetails" datasource="#Application.dsn#">
						select isnull(max(Assigned_Number),0)+1 as assign_no from EDI210LineDetails where lm_Loads_BOL=<cfqueryparam value="#getLoadDetails.BolNum#" cfsqltype="cf_sql_varchar">
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
							VALUES(
								<cfqueryparam value="#assign_no#" cfsqltype="cf_sql_varchar">,
								<cfqueryparam value="#assign_no#" cfsqltype="cf_sql_varchar">,
								'Miles Charge','1','LC','0','G','1','PLT','L','1','1','PLT','L','1','PLT',
								<cfqueryparam value="#trim(getLoadDetails.MilesCharge)#" cfsqltype="cf_sql_varchar">,
								'FR',
								<cfqueryparam cfsqltype="cf_sql_integer" null="#not len(getLoadDetails.MilesCharge)#" value="#getLoadDetails.MilesCharge*100#">,
								<cfqueryparam value="#getLoadDetails.BolNum#" cfsqltype="cf_sql_varchar">,
								<cfqueryparam value="#getLoadDetails.receiverID#" cfsqltype="cf_sql_varchar">,
								getDate(),getdate())
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
	
	<cfset var col = "">
	<cfset excludeArray=["LASTMODIFIEDDATE","CREATEDDATETIME", "NEWDISPATCHNOTES", "SALESREPID", "NEWCARRIERID", "CARRIERID", "CUSTOMERID", "EQUIPMENTNAME", "EQUIPMENTID" ]> 
	<!---SALESREPID is added cos we already have agent name --->


	<cfif arguments.instance EQ 1>
		<cfquery name="this.SelectForLoggingBefore" datasource="#variables.dsn#">
			<cfif arguments.type EQ "RunUSP_UpdateLoad">
				Select LoadNumber,SalesRepID,DispatcherID,CustomerPONo,BOLNum,StatusTypeID,CustomerID As PayerID,IsPost,IsTransCorePst,PostTo123LoadBoard,TotalCarrierCharges,TotalCustomerCharges,LastModifiedDate,ModifiedBy,UpdatedByIP,NewNotes,NewDispatchNotes,carrierNotes,pricingNotes,CustFlatRate,CarrFlatRate,CarrierID,CarrOfficeID,EquipmentID,DriverName,DriverCell,TruckNo,TrailorNo,newbookedwithload,NewPickupNo ,NewPickupDate ,NewPickupTime ,NewPickupTimeIn ,NewPickupTimeOut ,NewDeliveryNo ,NewDeliveryDate ,NewDeliveryTime ,NewDeliveryDateTimeIn ,NewDeliveryDateTimeOut ,CustomerRatePerMile ,CarrierRatePerMile,TotalMiles,orderDate,BillDate,totalProfit,ARExported,APExported,customerMilesCharges,carrierMilesCharges,customerCommoditiesCharges,carrierCommoditiesCharges,Address,City,StateCode,PostalCode,ContactPerson,Phone,Fax,CellNo,CustName,IsPartial,readyDate,arriveDate,isExcused,bookedBy,invoiceNumber,weight,CarrierInvoiceNumber,postCarrierRatetoloadboard,postCarrierRatetoTranscore,postCarrierRateto123LoadBoard,ShipperState,ShipperCity,ConsigneeState,ConsigneeCity,SalesAgent,EquipmentName,CarrierName,LoadDriverName from Loads where loadid=<cfqueryparam cfsqltype='cf_sql_varchar' value='#arguments.whereList[1]#'>
				
				<cfset this.loadLogData = structNew()><!--- CF uses the same CFC instance for every request. Hence this line resets the variable--->
			<cfelseif arguments.type EQ "USP_UpdateLoadStop">
				Select ReleaseNo,Blind,StopDate,StopTime,TimeIn,TimeOut,Instructions,Directions,CustomerID,CreatedBy,CreatedDateTime,ModifiedBy,LastModifiedDate,isoriginpickup,IsFinalDelivery,newBookedwith,NewEquipmentID,NewDriverName,NewDriverName2,NewDriverCell,NewTruckNo,NewTrailorNo,RefNo,Miles,NewCarrierID,NewOfficeID,Address,City,StateCode,PostalCode,ContactPerson,Phone,Fax,EmailID,CustName,userDef1,userDef2,userDef3,userDef4,userDef5,userDef6,StopNo,stopdateDifference,NewDriverCell2 from LoadStops where loadid=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.whereList[1]#"> AND StopNo = #arguments.whereList[2]# AND LoadStops.LoadType = #arguments.whereList[3]#
			<cfelseif arguments.type EQ "USP_UpdateLoadItem">	
				Select Qty,UnitID,Description,Weight,ClassID,CustRate,CarrRate,CustCharges,CarrCharges,fee,CarrRateOfCustTotal from [LoadStopCommodities] where LoadStopID=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.whereList[1]#"> AND [SrNo] = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.whereList[2]#">
			</cfif>
		</cfquery>
	<cfelse>
		<cfquery name="this.SelectForLoggingAfter" datasource="#variables.dsn#">
			<cfif arguments.type EQ "RunUSP_UpdateLoad">
				Select LoadNumber,SalesRepID,DispatcherID,CustomerPONo,BOLNum,StatusTypeID,CustomerID AS PayerID,IsPost,IsTransCorePst,PostTo123LoadBoard,TotalCarrierCharges,TotalCustomerCharges,LastModifiedDate,ModifiedBy,UpdatedByIP,NewNotes,NewDispatchNotes,carrierNotes,pricingNotes,CustFlatRate,CarrFlatRate,CarrierID,CarrOfficeID,EquipmentID,DriverName,DriverCell,TruckNo,TrailorNo,newbookedwithload,NewPickupNo ,NewPickupDate ,NewPickupTime ,NewPickupTimeIn ,NewPickupTimeOut ,NewDeliveryNo ,NewDeliveryDate ,NewDeliveryTime ,NewDeliveryDateTimeIn ,NewDeliveryDateTimeOut ,CustomerRatePerMile ,CarrierRatePerMile,TotalMiles,orderDate,BillDate,totalProfit,ARExported,APExported,customerMilesCharges,carrierMilesCharges,customerCommoditiesCharges,carrierCommoditiesCharges,Address,City,StateCode,PostalCode,ContactPerson,Phone,Fax,CellNo,CustName,IsPartial,readyDate,arriveDate,isExcused,bookedBy,invoiceNumber,weight,CarrierInvoiceNumber,postCarrierRatetoloadboard,postCarrierRatetoTranscore,postCarrierRateto123LoadBoard,ShipperState,ShipperCity,ConsigneeState,ConsigneeCity,SalesAgent,EquipmentName,CarrierName,LoadDriverName from Loads where loadid=<cfqueryparam cfsqltype='cf_sql_varchar' value='#arguments.whereList[1]#'>
			<cfelseif arguments.type EQ "USP_UpdateLoadStop">
				Select ReleaseNo,Blind,StopDate,StopTime,TimeIn,TimeOut,Instructions,Directions,CustomerID,CreatedBy,CreatedDateTime,ModifiedBy,LastModifiedDate,isoriginpickup,IsFinalDelivery,newBookedwith,NewEquipmentID,NewDriverName,NewDriverName2,NewDriverCell,NewTruckNo,NewTrailorNo,RefNo,Miles,NewCarrierID,NewOfficeID,Address,City,StateCode,PostalCode,ContactPerson,Phone,Fax,EmailID,CustName,userDef1,userDef2,userDef3,userDef4,userDef5,userDef6,StopNo,stopdateDifference,NewDriverCell2 from LoadStops where loadid=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.whereList[1]#"> AND StopNo = #arguments.whereList[2]# AND LoadStops.LoadType = #arguments.whereList[3]#
			<cfelseif arguments.type EQ "USP_UpdateLoadItem">	
				Select Qty,UnitID,Description,Weight,ClassID,CustRate,CarrRate,CustCharges,CarrCharges,fee,CarrRateOfCustTotal from [LoadStopCommodities] where LoadStopID=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.whereList[1]#"> AND [SrNo] = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.whereList[2]#">
			</cfif>
		</cfquery>

		<cfif this.SelectForLoggingBefore.recordCount AND this.SelectForLoggingAfter.recordCount>
			<cfloop list="#this.SelectForLoggingBefore.columnList#" index="col">
				<cfif isDefined("this.SelectForLoggingAfter.#col#") AND isDefined("this.SelectForLoggingBefore.#col#") AND this.SelectForLoggingBefore[col][1] NEQ this.SelectForLoggingAfter[col][1] AND NOT ArrayContains(excludeArray,col)>
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
	</cfif>
</cffunction>

<cffunction name="getSearchedLoadLogs" access="public" output="false" returntype="query">
	<cfargument name="searchText" required="no" type="any">
    <cfargument name="pageNo" required="no" type="any">
    <cfargument name="sortorder" required="no" type="any">
    <cfargument name="sortby" required="no" type="any">
    <cfargument name="bulkdelete" required="no" type="any" default="0">
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
		 <CFPROCPARAM VALUE="#session.companyid#" cfsqltype="cf_sql_varchar">
		 <cfif structKeyExists(arguments, "bulkdelete") and arguments.bulkdelete EQ 1>
		 	<CFPROCPARAM VALUE="1" cfsqltype="cf_sql_nvarchar">
		 <cfelse>
		 	<CFPROCPARAM VALUE="0" cfsqltype="cf_sql_varchar">
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
    	WHERE CompanyID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#session.companyid#">
	    <cfif structKeyExists(arguments, "searchText") and len(trim(arguments.searchText))>
		    AND (LoadID LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#arguments.searchText#%">
		    OR LoadNumber LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#arguments.searchText#%">
		    OR Description LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#arguments.searchText#%">
		    OR FuelCardNo LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#arguments.searchText#%">)
	    </cfif>
	    )
	    SELECT
	      *,(select (max(row)/30) + (CASE WHEN max(row)%30 <> 0 THEN 1 ELSE 0 END)  FROM page) AS TotalPages
	    FROM page
	    WHERE Row BETWEEN (<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.pageNo#"> - 1) * 30 + 1 AND <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.pageNo#"> * 30
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
		    AND (lm_Loads_BOL LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#arguments.searchText#%">
		    OR lm_Customers_CustomerCode LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#arguments.searchText#%">)
	    </cfif>
	    )
	    SELECT
	      *
	    FROM page
	    WHERE Row BETWEEN (<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.pageNo#"> - 1) * 30 + 1 AND <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.pageNo#"> * 30
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
		    	reference_identification LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#arguments.searchText#%">
		    OR
		    	payment_method_code LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#arguments.searchText#%">
		    OR
		    	monetary_amount LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#arguments.searchText#%">
		    )
	    </cfif>	    
	    )	
	    SELECT
	      *
	    FROM page
	    WHERE Row BETWEEN (<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.pageNo#"> - 1) * 30 + 1 AND <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.pageNo#"> * 30
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
    		,BOLNumber
    		,Detail
    		,CreatedDate
    		,L.LoadNumber
    		,DocType
			,CustomerName
			, ROW_NUMBER() OVER (ORDER BY #arguments.sortby# #arguments.sortorder#) AS Row
    	FROM EDI204Log 	LG
		left Join loads L on LG.BOLNumber =L.BOLNum
		Left Join Customers C on L.CustomerID = C.CustomerID
		inner join (select
					    customerid
						from CustomerOffices c1 inner join offices o1 on o1.officeid = c1.OfficeID
						where o1.CompanyID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#session.companyid#">
						group by customerid) Offices ON Offices.CustomerID = C.CustomerID

		WHERE 1=1 AND (LG.BOLNumber =L.BOLNum OR L.receiverid = LG.receiverid  )
    	<cfif structKeyExists(arguments, "searchText") and len(trim(arguments.searchText))>
		    AND (LoadLogID LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#arguments.searchText#%">
		    OR BOLNumber LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#arguments.searchText#%">
		    OR DOCTYPE LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#arguments.searchText#%">
		    OR CreatedDate LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#arguments.searchText#%">
		    OR Detail LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#arguments.searchText#%">
		    OR LG.LoadNumber LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#arguments.searchText#%">
		    OR CustomerName LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#arguments.searchText#%">)
	    </cfif>
	    )
	    SELECT
	      *,(select (max(row)/30) + (CASE WHEN max(row)%30 <> 0 THEN 1 ELSE 0 END)  FROM page) AS TotalPages
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
			SELECT distinct EDISCAC,BolNum,LoadNumber,ISNULL((select ECM.receiverID from EDICustomerIDMapping ECM WHERE  ECM.lm_Customers_CustomerCode = L.CustomerID),L.receiverid) AS receiverid, L.CustomerID, stopdate  AS Ship_Date,stoptime AS Ship_Time,EDI.identitycode,EDI.identitycodeq,EDI.entityidentitycode
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
			LEFT JOIN edi204stops EDI on (edi.lm_Loads_BOL=L.BolNum OR edi.lm_Loads_BOL = l.CustomerPONo) 
			and edi.Name = ls.CustName
			and ( LoadType=1 and edi.lm_LoadStops_LoadType in ('LD','CL','PL' ) 
 					or LoadType=2 and edi.lm_LoadStops_LoadType in ('CU','UL','PU' ) )
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

			<cfset newAppointmentTime = qGetLoadDetails.Ship_Time>
			<cfif Findnocase('-',qGetLoadDetails.Ship_Time) GT 0>								
				<cfset newAppointmentTime = Right(qGetLoadDetails.Ship_Time,4)>
			</cfif>

			<cfquery name="qGetEDI214" datasource="#Application.dsn#">
				SELECT 
					Reference_Identification ,[date],[time]
				FROM EDI214 
				WHERE Reference_Identification =<cfqueryparam cfsqltype="cf_sql_varchar" value="#qGetLoadDetails.LoadNumber#">
				AND Shipment_Appointment_Status_Code = <cfqueryparam cfsqltype="cf_sql_varchar" value="#qGetLoadDetails.Shipment_Appointment_Status_Code#">
				AND lm_LoadStops_StopNo = <cfqueryparam cfsqltype="cf_sql_varchar" value="#qGetLoadDetails.EdiNewstopNo#">				
				AND [Date] =<cfqueryparam cfsqltype="cf_sql_varchar" value="#dateformat(qGetLoadDetails.Ship_Date,'yyyymmdd')#">
				AND [Time] =<cfqueryparam cfsqltype="cf_sql_varchar" value="#newAppointmentTime#">
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
			<cfif  (NOT len(qGetLoadDetails.EdiNewStopNO) OR NOT len(qGetLoadDetails.EntityIdentityCode) OR  NOT len(qGetLoadDetails.IdentityCode)) > 
				<cfif qGetLoadDetails.LoadType EQ 1>
					<cfset result = result & " EDI 214 pickup stop details are missing">
				<cfelse>
					<cfset result = result & " EDI 214 delivery stop details are missing">
				</cfif>
			<cfelse>
			
			

			<cfif Len(newAppointmentTime) NEQ 4 OR Findnocase('-',newAppointmentTime) GT 0>
					<cfif qGetLoadDetails.LoadType EQ 1>
						<cfset result = result & " EDI 214 pickup apt. time not in correct format.">
					<cfelse>
						<cfset result = result & " EDI 214 delivery apt. time not in correct format.">
					</cfif>
			<cfelse>
							
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
					<cfqueryparam value='#qGetLoadDetails.LoadNumber#' cfsqltype="cf_sql_varchar">
					,<cfqueryparam value='#qGetLoadDetails.BolNum#' cfsqltype="cf_sql_varchar">
					,<cfqueryparam value='#qGetLoadDetails.EDISCAC#' cfsqltype="cf_sql_varchar">
					,<cfqueryparam value='#qGetLoadDetails.EntityIdentityCode#' cfsqltype="cf_sql_varchar">
					,<cfqueryparam value='#qGetLoadDetails.custname#' cfsqltype="cf_sql_varchar">
					,<cfqueryparam value='#qGetLoadDetails.IdentityCodeQ#' cfsqltype="cf_sql_varchar">
					,<cfqueryparam value='#qGetLoadDetails.IdentityCode#' cfsqltype="cf_sql_varchar">
					,<cfqueryparam value='#Assign_Number#' cfsqltype="cf_sql_varchar">
					,''
					,''
					,<cfqueryparam value='#dateformat(qGetLoadDetails.Ship_Date,"yyyymmdd")#' cfsqltype="cf_sql_varchar">
					,<cfqueryparam value='#newAppointmentTime#' cfsqltype="cf_sql_varchar">
					,'LT'
					,<cfqueryparam value='#qGetLoadDetails.CustomerPONo#' cfsqltype="cf_sql_varchar">
					,0
		           	,<cfqueryparam value='#qGetLoadDetails.receiverid#' cfsqltype="cf_sql_varchar">
		           	,<cfqueryparam value='#qGetLoadDetails.Shipment_Appointment_Status_Code#' cfsqltype="cf_sql_varchar">
		           	,<cfqueryparam value='#qGetLoadDetails.EdiNewStopNO#' cfsqltype="cf_sql_varchar">
		           	,getdate()
		           	,'NA'
					,<cfqueryparam value='#arguments.frmstruct.editid#' cfsqltype="cf_sql_varchar">
					)
			</cfquery>
			<cfset Assign_Number = Assign_Number + 1>
			<cfset LogEdi214(qGetLoadDetails.BolNum, DocType, EDI214Status, qGetLoadDetails.LoadNumber,qGetLoadDetails.PayerID,qGetLoadDetails.ReceiverID)>
			<cfif qGetLoadDetails.LoadType EQ 1>
				<cfset result = result & "EDI 214 pickup information has been queued.">
			<cfelse>
				<cfset result = result & "EDI 214 delivery information has been queued.">
			</cfif>

			</cfif>
			</cfif>
			</cfif>
		</cfloop>
		</cfif>
		
		<!--- If shipper/ consignee pickup date/ time changed  --->
		<cfquery name="qGetLoadDetailsAdd" datasource="#Application.dsn#">
			SELECT distinct EDISCAC,BolNum,LoadNumber,ISNULL((select ECM.receiverID from EDICustomerIDMapping ECM WHERE  ECM.lm_Customers_CustomerCode = L.CustomerID),L.receiverid) AS receiverid, L.CustomerID, stopdate  AS Ship_Date,stoptime AS Ship_Time,EDI.identitycode,EDI.identitycodeq,EDI.entityidentitycode
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
			LEFT JOIN edi204stops EDI on (edi.lm_Loads_BOL=L.BolNum OR edi.lm_Loads_BOL = l.CustomerPONo) 
			and edi.Name = ls.CustName
			and ( LoadType=1 and edi.lm_LoadStops_LoadType in ('LD','CL','PL' ) 
 					or LoadType=2 and edi.lm_LoadStops_LoadType in ('CU','UL','PU' ) )
			where L.loadid=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.frmstruct.editid#" > AND EDISCAC is not null			
			AND ls.custName is not null
			
		</cfquery>		
		
		<cfif qGetLoadDetailsAdd.RecordCount>
		<cfset Assign_Number = qGetLoadDetailsAdd.Assigned_Number>		
			<cfloop query="qGetLoadDetailsAdd">
					
			<cfset newAppointmentTime = qGetLoadDetailsAdd.Ship_Time>
			<cfif Findnocase('-',qGetLoadDetailsAdd.Ship_Time) GT 0>								
				<cfset newAppointmentTime = Right(qGetLoadDetailsAdd.Ship_Time,4)>
			</cfif>	

			<cfquery name="qGetEDI214Add" datasource="#Application.dsn#">
				SELECT 
					Reference_Identification ,[date],[time]
				FROM EDI214 
				WHERE Reference_Identification =<cfqueryparam cfsqltype="cf_sql_varchar" value="#qGetLoadDetailsAdd.LoadNumber#">
				AND Shipment_Appointment_Status_Code = <cfqueryparam cfsqltype="cf_sql_varchar" value="#qGetLoadDetailsAdd.Shipment_Appointment_Status_Code#">
				AND lm_LoadStops_StopNo = <cfqueryparam cfsqltype="cf_sql_varchar" value="#qGetLoadDetailsAdd.EdiNewstopNo#">
				AND [Date] =<cfqueryparam cfsqltype="cf_sql_varchar" value="#dateformat(qGetLoadDetailsAdd.Ship_Date,'yyyymmdd')#">
				AND [Time] =<cfqueryparam cfsqltype="cf_sql_varchar" value="#newAppointmentTime#">
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
				<cfif NOT isNumeric(qGetLoadDetailsAdd.Ship_Time) AND qGetLoadDetailsAdd.Loadtype EQ 1 AND Findnocase('-',qGetLoadDetailsAdd.edistoptime) EQ 'no'>
					<cfset EDIError = "Pickup time is not valid. EDI 214 could not be queued.">
				<cfelseif NOT isNumeric(qGetLoadDetailsAdd.Ship_Time) AND qGetLoadDetailsAdd.Loadtype EQ 2 AND Findnocase('-',qGetLoadDetailsAdd.edistoptime) EQ 'no'>
					<cfset EDIError = "Delivery time is not valid. EDI 214 could not be queued.">		
				<cfelseif IsNumeric(qGetLoadDetailsAdd.Ship_Time) AND Len(qGetLoadDetailsAdd.Ship_Time) EQ 4 >					
					
						<cfif qGetLoadDetailsAdd.Loadtype EQ 1 AND Findnocase('-',qGetLoadDetailsAdd.edistoptime) EQ 'no'>
							<cfset local.HourPart =Left(qGetLoadDetailsAdd.Ship_Time,2)>
							<cfset local.MinutePart =Right(qGetLoadDetailsAdd.Ship_Time,2)>
							<cfif local.HourPart GT 23 OR local.MinutePart GT 59>
								<cfset EDIError = "Pickup time is not valid. EDI 214 could not be queued.">
							</cfif>
						<cfelseif qGetLoadDetailsAdd.Loadtype EQ 2 AND Findnocase('-',qGetLoadDetailsAdd.edistoptime) EQ 'no'>
							<cfset local.HourPart =Left(qGetLoadDetailsAdd.Ship_Time,2)>
							<cfset local.MinutePart =Right(qGetLoadDetailsAdd.Ship_Time,2)>
							<cfif local.HourPart GT 23 OR local.MinutePart GT 59>
								<cfset EDIError = "Delivery time is not valid. EDI 214 could not be queued.">
							</cfif>
						</cfif>
				<cfelseif Len(qGetLoadDetailsAdd.Ship_Time) NEQ 4 AND qGetLoadDetailsAdd.Loadtype EQ 1 AND Findnocase('-',qGetLoadDetailsAdd.edistoptime) EQ 'no'>
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
				
				
				<cfif  (NOT len(qGetLoadDetailsAdd.EdiNewStopNO) OR NOT len(qGetLoadDetailsAdd.EntityIdentityCode) OR  NOT len(qGetLoadDetailsAdd.IdentityCode)) >
					<cfif qGetLoadDetailsAdd.LoadType EQ 1>
						<cfset result = result & " EDI 214 pickup stop details are missing">
					<cfelse>
						<cfset result = result & " EDI 214 delivery stop details are missing">
					</cfif>
				<cfelse>	
				
				

				<cfif Len(newAppointmentTime) NEQ 4 OR Findnocase('-',newAppointmentTime) GT 0>
					<cfif qGetLoadDetailsAdd.LoadType EQ 1>
						<cfset result = result & " EDI 214 pickup apt. time not in correct format.">
					<cfelse>
						<cfset result = result & " EDI 214 delivery apt. time not in correct format.">
					</cfif>

				<cfelse>

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
					<cfqueryparam value='#qGetLoadDetailsAdd.LoadNumber#' cfsqltype="cf_sql_varchar">
					,<cfqueryparam value='#qGetLoadDetailsAdd.BolNum#' cfsqltype="cf_sql_varchar">
					,<cfqueryparam value='#qGetLoadDetailsAdd.EDISCAC#' cfsqltype="cf_sql_varchar">
					,<cfqueryparam value='#qGetLoadDetailsAdd.EntityIdentityCode#' cfsqltype="cf_sql_varchar">
					,<cfqueryparam value='#qGetLoadDetailsAdd.custname#' cfsqltype="cf_sql_varchar">
					,<cfqueryparam value='#qGetLoadDetailsAdd.IdentityCodeQ#' cfsqltype="cf_sql_varchar">
					,<cfqueryparam value='#qGetLoadDetailsAdd.IdentityCode#' cfsqltype="cf_sql_varchar">
					,<cfqueryparam value='#Assign_Number#' cfsqltype="cf_sql_varchar">
					,''
					,''
					,<cfqueryparam value='#dateformat(qGetLoadDetailsAdd.Ship_Date,"yyyymmdd")#' cfsqltype="cf_sql_varchar">
					,<cfqueryparam value='#newAppointmentTime#' cfsqltype="cf_sql_varchar">
					,'LT'
					,<cfqueryparam value='#qGetLoadDetailsAdd.CustomerPONo#' cfsqltype="cf_sql_varchar">
					,0
		           	,<cfqueryparam value='#qGetLoadDetailsAdd.receiverid#' cfsqltype="cf_sql_varchar">
		           	,<cfqueryparam value='#qGetLoadDetailsAdd.Shipment_Appointment_Status_Code#' cfsqltype="cf_sql_varchar">
		           	,<cfqueryparam value='#qGetLoadDetailsAdd.EdiNewStopNO#' cfsqltype="cf_sql_varchar">
		           	,getdate()
		           	,'NA'
					,<cfqueryparam value='#arguments.frmstruct.editid#' cfsqltype="cf_sql_varchar">
					)
			</cfquery>
			<cfset Assign_Number = Assign_Number + 1>
			<cfset LogEdi214(qGetLoadDetailsAdd.BolNum, DocType, EDI214Status, qGetLoadDetails.LoadNumber,qGetLoadDetailsAdd.PayerID,qGetLoadDetailsAdd.ReceiverID)>

			<cfif qGetLoadDetailsAdd.LoadType EQ 1>
				<cfset result = result & " EDI 214 pickup information has been queued.">
			<cfelse>
				<cfset result = result & " EDI 214 delivery information has been queued. ">
			</cfif>
			</cfif>
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
			SELECT DISTINCT EDISCAC,BolNum,LoadNumber,L.receiverid, L.CustomerID, stopdate  AS Ship_Date,stoptime AS Ship_Time,EDI.identitycode,EDI.identitycodeq,EDI.entityidentitycode
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
			LEFT JOIN edi204stops EDI on (edi.lm_Loads_BOL=L.BolNum OR edi.lm_Loads_BOL = l.CustomerPONo) 
			and edi.Name = ls.CustName
			and ( LoadType=1 and edi.lm_LoadStops_LoadType in ('LD','CL','PL' ) 
 					or LoadType=2 and edi.lm_LoadStops_LoadType in ('CU','UL','PU' ) )
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
				<cfif NOT isNumeric(qGetLoadDetails.Ship_Time) AND EDI214Loadtype EQ 1 AND Findnocase('-',qGetLoadDetails.Ship_Time) EQ 'no'>
					<cfset EDIError = "Pickup time is not valid. EDI 214 could not be queued.">
				<cfelseif NOT isNumeric(qGetLoadDetails.Ship_Time) AND EDI214Loadtype EQ 2 AND Findnocase('-',qGetLoadDetails.Ship_Time) EQ 'no'>
					<cfset EDIError = "Delivery time is not valid. EDI 214 could not be queued.">		
				<cfelseif IsNumeric(qGetLoadDetails.Ship_Time) AND Len(qGetLoadDetails.Ship_Time) EQ 4 AND Findnocase('-',qGetLoadDetails.Ship_Time) EQ 'no'>					
					
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
				<cfelseif Len(qGetLoadDetails.Ship_Time) NEQ 4 AND EDI214Loadtype EQ 1 AND Findnocase('-',qGetLoadDetails.Ship_Time) EQ 'no'>
					<cfset EDIError = "Pickup time is not valid. EDI 214 could not be queued.">
				<cfelseif Len(qGetLoadDetails.Ship_Time) NEQ 4 AND EDI214Loadtype EQ 2 AND Findnocase('-',qGetLoadDetails.Ship_Time) EQ 'no'>
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
			SELECT DISTINCT EDISCAC,BolNum,LoadNumber,L.receiverid, L.CustomerID, stopdate  AS Ship_Date,stoptime AS Ship_Time,TimeIn as Ship_TimeIn,TimeOut as Ship_TimeOut,LoadType,EDI.identitycode,EDI.identitycodeq,EDI.entityidentitycode
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
			LEFT JOIN edi204stops EDI on (edi.lm_Loads_BOL=L.BolNum OR edi.lm_Loads_BOL = l.CustomerPONo) 
			and edi.Name = ls.CustName
			and ( LoadType=1 and edi.lm_LoadStops_LoadType in ('LD','CL','PL' ) 
 					or LoadType=2 and edi.lm_LoadStops_LoadType in ('CU','UL','PU' ) )
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
			SELECT DISTINCT EDISCAC,BolNum,LoadNumber,ISNULL((select ECM.receiverID from EDICustomerIDMapping ECM WHERE  ECM.lm_Customers_CustomerCode = L.CustomerID),L.receiverid) AS receiverid, L.CustomerID, stopdate  AS Ship_Date,stoptime AS Ship_Time,TimeIn as Ship_TimeIn,TimeOut as Ship_TimeOut,LoadType,EDI.identitycode,EDI.identitycodeq,EDI.entityidentitycode
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
			,EDI.lm_loadstops_stoptime as edistoptime
			,EDI.lm_LoadStops_StopDateQ	
			,case when EDI.lm_LoadStops_StopDateQ='02' then 'Delivery Requested on This Date'  
				  when EDI.lm_LoadStops_StopDateQ='10' then 'Requested Pickup Date/Pick-up Date'
				  when EDI.lm_LoadStops_StopDateQ='37' then 'Pickup Not Before Date' 
				  when EDI.lm_LoadStops_StopDateQ='38' then 'Pickup Not Later Than Date' 
				  when EDI.lm_LoadStops_StopDateQ='53' then 'Deliver Not Before Date' 
				  when EDI.lm_LoadStops_StopDateQ='54' then 'Deliver No Later Than Date' 
				 end EDIReasonMessage 		
			FROM Loads L
			LEFT JOIN LoadStops LS on L.loadID = LS.loadid
			LEFT JOIN edi204 E on L.loadId = E.LoadID
			LEFT JOIN edi204stops EDI on (edi.lm_Loads_BOL=L.BolNum OR edi.lm_Loads_BOL = l.CustomerPONo) 
			and edi.Name = ls.CustName
			and ( LoadType=1 and edi.lm_LoadStops_LoadType in ('LD','CL','PL' ) 
 					or LoadType=2 and edi.lm_LoadStops_LoadType in ('CU','UL','PU' ) )
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
					<cfset local.frmTimeOut = '#frmstruct.shipperTimeOut#'>
				<cfelse>
					<cfset local.ediReasoncode = Evaluate('frmstruct.shipperEdiReasonCode#qGetLoadDetails.stopNo+1#')>
					<cfset local.frmOldTimeIn = Evaluate('frmstruct.oldShipperTimeIn#qGetLoadDetails.stopNo+1#')>
					<cfset local.frmTimeIn =  Evaluate('frmstruct.shipperTimeIn#qGetLoadDetails.stopNo+1#')>
					<cfset local.frmTimeOut =  Evaluate('frmstruct.shipperTimeOut#qGetLoadDetails.stopNo+1#')>
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
							
							AND [Time] =<cfqueryparam cfsqltype="cf_sql_varchar" value='#Local.Time#'>
							AND Shipment_Status_Code =<cfqueryparam cfsqltype="cf_sql_varchar" value='#local.shipment_status_Code#'>
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


								<cfif Findnocase('-',qGetLoadDetails.edistoptime) EQ 'no' and qGetLoadDetails.Ship_TimeIn GT qGetLoadDetails.Ship_Time>
									<cfif len(local.ediReasoncode) Eq 0>
								  		<cfreturn "Please select a reason for late pickup on Stop "& qGetLoadDetails.stopno+1>
								  	<cfelse>
								  		<cfset local.shipment_status = local.ediReasoncode>
								    </cfif>
								</cfif>
								<cfif  (NOT len(qGetLoadDetails.EdiNewStopNO) OR NOT len(qGetLoadDetails.EntityIdentityCode) OR  NOT len(qGetLoadDetails.IdentityCode)) > 
									<cfif qGetLoadDetails.LoadType EQ 1>
										<cfset result = result & " EDI 214 pickup stop details are missing">
									<cfelse>
										<cfset result = result & " EDI 214 delivery stop details are missing">
									</cfif>
								<cfelse>

								<cfif Findnocase('-',qGetLoadDetails.edistoptime) GT 0  AND Not Len(local.ediReasoncode) 
								AND qGetLoadDetails.lm_LoadStops_StopDateQ EQ '37-38'
								AND 
									(qGetLoadDetails.Ship_TimeIn LT Left(qGetLoadDetails.Ship_Time,4) OR qGetLoadDetails.Ship_TimeIn GT Right(qGetLoadDetails.Ship_Time,4))
								>
			
									<cfset result = "EDI 214 Pickup time in for stop #qGetLoadDetails.stopno+1# is not in the range  #qGetLoadDetails.edistoptime#. Please choose the reason code.">

										
									
		
								<cfelseif Len(local.frmTimeIn ) AND Len(Local.frmTimeOut) AND (local.frmTimeIn GT local.frmTimeOut)>
									<cfset result = "EDI 214 Pickup Time In for stop #qGetLoadDetails.stopno+1# is after the time out.">
								<cfelse>
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
									<cfqueryparam value='#qGetLoadDetails.LoadNumber#' cfsqltype="cf_sql_varchar">
									,<cfqueryparam value='#qGetLoadDetails.BolNum#' cfsqltype="cf_sql_varchar">
									,<cfqueryparam value='#qGetLoadDetails.EDISCAC#' cfsqltype="cf_sql_varchar">
									,<cfqueryparam value='#qGetLoadDetails.EntityIdentityCode#' cfsqltype="cf_sql_varchar">
									,<cfqueryparam value='#qGetLoadDetails.custname#' cfsqltype="cf_sql_varchar">
									,<cfqueryparam value='#qGetLoadDetails.IdentityCodeQ#' cfsqltype="cf_sql_varchar">
									,<cfqueryparam value='#qGetLoadDetails.IdentityCode#' cfsqltype="cf_sql_varchar">
									,<cfqueryparam value='#Assign_Number#' cfsqltype="cf_sql_varchar">
									,<cfqueryparam value='#local.shipment_status_Code#' cfsqltype="cf_sql_varchar">
									,<cfqueryparam value='#local.shipment_status#' cfsqltype="cf_sql_varchar">
									,<cfqueryparam value='#dateformat(qGetLoadDetails.Ship_Date,"yyyymmdd")#' cfsqltype="cf_sql_varchar">
									,<cfqueryparam value='#local.Time#' cfsqltype="cf_sql_varchar">
									,'LT'
									,<cfqueryparam value='#qGetLoadDetails.CustomerPONo#' cfsqltype="cf_sql_varchar">
									,0
						           	,<cfqueryparam value='#qGetLoadDetails.receiverid#' cfsqltype="cf_sql_varchar">
						           	,''
						           	,<cfqueryparam value='#qGetLoadDetails.EdiNewStopNO#' cfsqltype="cf_sql_varchar">
						           	,getdate()
						           	,''
									,<cfqueryparam value='#arguments.frmstruct.editid#' cfsqltype="cf_sql_varchar">
									)
							</cfquery>
					<cfset Assign_Number = Assign_Number +1>
					<cfset EDI214_Status ='#local.shipment_status# - #local.shipment_status_Code#'>
					<cfset LogEdi214(qGetLoadDetails.BolNum, DocType, EDI214_Status, qGetLoadDetails.LoadNumber,qGetLoadDetails.PayerID,qGetLoadDetails.ReceiverID)>
					<cfset result = result & "EDI 214 pickup information has been queued. ">
					<cfset AlertEDIReasonMessage = qGetLoadDetails.EDIReasonMessage>
					<cfset showEdistopDate =  Mid(qGetLoadDetails.Edistopdate,5,2) &"/" & Mid(qGetLoadDetails.Edistopdate,7,2) & "/" & Mid(qGetLoadDetails.Edistopdate,1,4) >
					<cfset showEdistoptime = Mid(qGetLoadDetails.Edistoptime,1,2) & ":" &	Mid(qGetLoadDetails.Edistoptime,3,4)>	
					
													
									
					</cfif>
					

					
				</cfif>
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
						<cfset local.frmTimeIn = '#frmstruct.shipperTimeIn#'>
						<cfset local.frmTimeOut = '#frmstruct.shipperTimeOut#'>
					<cfelse>
						<cfset local.ediReasoncode = Evaluate('frmstruct.shipperEdiReasonCode#qGetLoadDetails.stopNo+1#')>			
						<cfset local.frmOldTimeOut = Evaluate('frmstruct.oldShipperTimeOut#qGetLoadDetails.stopNo+1#')>
						<cfset local.frmTimeIn =  Evaluate('frmstruct.shipperTimeIn#qGetLoadDetails.stopNo+1#')>
						<cfset local.frmTimeOut =  Evaluate('frmstruct.shipperTimeOut#qGetLoadDetails.stopNo+1#')>
					</cfif>

					
					<cfquery name="qryTimeIn" datasource="#Application.dsn#">
							select reference_identification from EDI214 
							WHERE Reference_Identification =<cfqueryparam cfsqltype="cf_sql_varchar" value="#qGetLoadDetails.LoadNumber#">
							
							AND [Time] =<cfqueryparam value='#Local.Time#' cfsqltype="cf_sql_varchar">
							AND Shipment_Status_Code =<cfqueryparam value='#local.shipment_status_Code#' cfsqltype="cf_sql_varchar">
							
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
								<cfif Len(Local.Time) AND Len(local.shipment_status) AND Len(local.shipment_status_code)>
									<cfif  (NOT len(qGetLoadDetails.EdiNewStopNO) OR NOT len(qGetLoadDetails.EntityIdentityCode) OR  NOT len(qGetLoadDetails.IdentityCode)) > 
										<cfif qGetLoadDetails.LoadType EQ 1>
											<cfset result = result & " EDI 214 pickup stop details are missing">
										<cfelse>
											<cfset result = result & " EDI 214 delivery stop details are missing">
										</cfif>
									<cfelse>
									
									<cfif Findnocase('-',qGetLoadDetails.edistoptime) GT 0  AND Not Len(local.ediReasoncode)
									AND qGetLoadDetails.lm_LoadStops_StopDateQ EQ '37-38'
									AND 
									(qGetLoadDetails.Ship_TimeOut LT Left(qGetLoadDetails.Ship_Time,4) OR qGetLoadDetails.Ship_TimeOut GT Right(qGetLoadDetails.Ship_Time,4))>
									
									
									
												
										<cfset result = "EDI 214 Pickup time out for stop #qGetLoadDetails.stopno+1# is not in the range  #qGetLoadDetails.edistoptime#. Please choose the reason code.">

									
								<cfelseif Len(local.frmTimeIn ) AND Len(Local.frmTimeOut) AND (local.frmTimeIn GT local.frmTimeOut)>
									<cfset result = "EDI 214 Pickup Time In for stop #qGetLoadDetails.stopno+1# is after the time out.">
								<cfelse>

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
									<cfqueryparam value='#qGetLoadDetails.LoadNumber#' cfsqltype="cf_sql_varchar">
									,<cfqueryparam value='#qGetLoadDetails.BolNum#' cfsqltype="cf_sql_varchar">
									,<cfqueryparam value='#qGetLoadDetails.EDISCAC#' cfsqltype="cf_sql_varchar">
									,<cfqueryparam value='#qGetLoadDetails.EntityIdentityCode#' cfsqltype="cf_sql_varchar">
									,<cfqueryparam value='#qGetLoadDetails.custname#' cfsqltype="cf_sql_varchar">
									,<cfqueryparam value='#qGetLoadDetails.IdentityCodeQ#' cfsqltype="cf_sql_varchar">
									,<cfqueryparam value='#qGetLoadDetails.IdentityCode#' cfsqltype="cf_sql_varchar">
									,<cfqueryparam value='#Assign_Number#' cfsqltype="cf_sql_varchar">
									,<cfqueryparam value='#local.shipment_status_Code#' cfsqltype="cf_sql_varchar">
									,<cfqueryparam value='#local.shipment_status#' cfsqltype="cf_sql_varchar">
									,<cfqueryparam value='#dateformat(qGetLoadDetails.Ship_Date,"yyyymmdd")#' cfsqltype="cf_sql_varchar">
									,<cfqueryparam value='#local.Time#' cfsqltype="cf_sql_varchar">
									,'LT'
									,<cfqueryparam value='#qGetLoadDetails.CustomerPONo#' cfsqltype="cf_sql_varchar">
									,0
						           	,<cfqueryparam value='#qGetLoadDetails.receiverid#' cfsqltype="cf_sql_varchar">
						           	,''
						           	,<cfqueryparam value='#qGetLoadDetails.EdiNewStopNO#' cfsqltype="cf_sql_varchar">
						           	,getdate()
						           	,''
									,<cfqueryparam value='#arguments.frmstruct.editid#' cfsqltype="cf_sql_varchar">
									)
							</cfquery>
							<cfset Assign_Number = Assign_Number +1>
							<cfset EDI214_Status ='#local.shipment_status# - #local.shipment_status_Code#'>
							<cfset LogEdi214(qGetLoadDetails.BolNum, DocType, EDI214_Status, qGetLoadDetails.LoadNumber,qGetLoadDetails.PayerID,qGetLoadDetails.ReceiverID)>
							<cfset result = result & "EDI 214 pickup information has been queued. ">
							<cfset AlertEDIReasonMessage = qGetLoadDetails.EDIReasonMessage>
							<cfset showEdistopDate =  Mid(qGetLoadDetails.Edistopdate,5,2) &"/" & Mid(qGetLoadDetails.Edistopdate,7,2) & "/" & Mid(qGetLoadDetails.Edistopdate,1,4) >
							<cfset showEdistoptime = Mid(qGetLoadDetails.Edistoptime,1,2) & ":" &	Mid(qGetLoadDetails.Edistoptime,3,4)>	

							</cfif>
							
						</cfif>
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
					<cfset local.frmTimeOut = '#frmstruct.ConsigneeTimeOut#'>
				<cfelse>
					<cfset local.ediReasoncode = Evaluate('frmstruct.consigneeEdiReasonCode#qGetLoadDetails.stopNo+1#')>
					<cfset local.frmOldTimeIn = Evaluate('frmstruct.oldConsigneeTimeIn#qGetLoadDetails.stopNo+1#')>
					<cfset local.frmTimeIn =  Evaluate('frmstruct.ConsigneeTimeIn#qGetLoadDetails.stopNo+1#')>
					<cfset local.frmTimeOut =  Evaluate('frmstruct.ConsigneeTimeOut#qGetLoadDetails.stopNo+1#')>
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
							
							AND [Time] =<cfqueryparam value='#Local.Time#' cfsqltype="cf_sql_varchar">
							AND Shipment_Status_Code =<cfqueryparam value='#local.shipment_status_Code#' cfsqltype="cf_sql_varchar">
							
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
								
								
								<cfif Findnocase('-',qGetLoadDetails.edistoptime) eq 'no' AND qGetLoadDetails.Ship_TimeIn GT qGetLoadDetails.Ship_Time>
									<cfif len(local.ediReasoncode) Eq 0>
								  		<cfreturn "Please select a reason for late delivery on Stop "& qGetLoadDetails.stopno+1>
								  	<cfelse>
								  		<cfset local.shipment_status = local.ediReasoncode>
								    </cfif>
								</cfif>
								<cfif  (NOT len(qGetLoadDetails.EdiNewStopNO) OR NOT len(qGetLoadDetails.EntityIdentityCode) OR  NOT len(qGetLoadDetails.IdentityCode)) > 
									<cfif qGetLoadDetails.LoadType EQ 1>
										<cfset result = result & " EDI 214 pickup stop details are missing">
									<cfelse>
										<cfset result = result & " EDI 214 delivery stop details are missing">
									</cfif>
								<cfelse>
								
								<cfif Findnocase('-',qGetLoadDetails.edistoptime) GT 0  AND Not Len(local.ediReasoncode)
								AND qGetLoadDetails.lm_LoadStops_StopDateQ EQ '53-54'
									AND 
									(qGetLoadDetails.Ship_TimeIn LT Left(qGetLoadDetails.Ship_Time,4) OR qGetLoadDetails.Ship_TimeIn GT Right(qGetLoadDetails.Ship_Time,4))
								>
									
									
									

									<cfset result = "EDI 214 Delivery time in for stop #qGetLoadDetails.stopno+1# is not in the range  #qGetLoadDetails.edistoptime#. Please choose the reason code.">

								<cfelseif Len(local.frmTimeIn ) AND Len(Local.frmTimeOut) AND (local.frmTimeIn GT local.frmTimeOut)>
									<cfset result = "EDI 214 Delivery Time In for stop #qGetLoadDetails.stopno+1# is after the time out.">	
								<cfelse>

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
									<cfqueryparam value='#qGetLoadDetails.LoadNumber#' cfsqltype="cf_sql_varchar">
									,<cfqueryparam value='#qGetLoadDetails.BolNum#' cfsqltype="cf_sql_varchar">
									,<cfqueryparam value='#qGetLoadDetails.EDISCAC#' cfsqltype="cf_sql_varchar">
									,<cfqueryparam value='#qGetLoadDetails.EntityIdentityCode#' cfsqltype="cf_sql_varchar">
									,<cfqueryparam value='#qGetLoadDetails.custname#' cfsqltype="cf_sql_varchar">
									,<cfqueryparam value='#qGetLoadDetails.IdentityCodeQ#' cfsqltype="cf_sql_varchar">
									,<cfqueryparam value='#qGetLoadDetails.IdentityCode#' cfsqltype="cf_sql_varchar">
									,<cfqueryparam value='#Assign_Number#' cfsqltype="cf_sql_varchar">
									,<cfqueryparam value='#local.shipment_status_Code#' cfsqltype="cf_sql_varchar">
									,<cfqueryparam value='#local.shipment_status#' cfsqltype="cf_sql_varchar">
									,<cfqueryparam value='#dateformat(qGetLoadDetails.Ship_Date,"yyyymmdd")#' cfsqltype="cf_sql_varchar">
									,<cfqueryparam value='#local.Time#' cfsqltype="cf_sql_varchar">
									,'LT'
									,<cfqueryparam value='#qGetLoadDetails.CustomerPONo#' cfsqltype="cf_sql_varchar">
									,0
						           	,<cfqueryparam value='#qGetLoadDetails.receiverid#' cfsqltype="cf_sql_varchar">
						           	,''
						           	,<cfqueryparam value='#qGetLoadDetails.EdiNewStopNO#' cfsqltype="cf_sql_varchar">
						           	,getdate()
						           	,''
									,<cfqueryparam value='#arguments.frmstruct.editid#' cfsqltype="cf_sql_varchar">
									)
							</cfquery>
							<cfset Assign_Number = Assign_Number +1>
							<cfset EDI214_Status ='#local.shipment_status# - #local.shipment_status_Code#'>
							<cfset LogEdi214(qGetLoadDetails.BolNum, DocType, EDI214_Status, qGetLoadDetails.LoadNumber,qGetLoadDetails.PayerID,qGetLoadDetails.ReceiverID)>
							<cfset result = result & "EDI 214 delivery information has been queued.">
							<cfset AlertEDIReasonMessage = qGetLoadDetails.EDIReasonMessage>
							<cfset showEdistopDate =  Mid(qGetLoadDetails.Edistopdate,5,2) &"/" & Mid(qGetLoadDetails.Edistopdate,7,2) & "/" & Mid(qGetLoadDetails.Edistopdate,1,4) >
							<cfset showEdistoptime = Mid(qGetLoadDetails.Edistoptime,1,2) & ":" &	Mid(qGetLoadDetails.Edistoptime,3,4)>	
							
							</cfif>
							
						</cfif>
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
						<cfset local.frmTimeIn = '#frmstruct.ConsigneeTimeIn#'>
						<cfset local.frmTimeOut = '#frmstruct.ConsigneeTimeOut#'>
					<cfelse>
						<cfset local.ediReasoncode = Evaluate('frmstruct.consigneeEdiReasonCode#qGetLoadDetails.stopNo+1#')>
						<cfset local.frmOldTimeOut = Evaluate('frmstruct.oldConsigneeTimeOut#qGetLoadDetails.stopNo+1#')>
						<cfset local.frmTimeIn =  Evaluate('frmstruct.ConsigneeTimeIn#qGetLoadDetails.stopNo+1#')>
						<cfset local.frmTimeOut =  Evaluate('frmstruct.ConsigneeTimeOut#qGetLoadDetails.stopNo+1#')>
					</cfif>
				
					<cfif Len(Local.Time) AND Len(local.shipment_status) AND Len(local.shipment_status_code)>
						<cfquery name="qryTimeIn" datasource="#Application.dsn#">
							select reference_identification from EDI214 
							WHERE Reference_Identification =<cfqueryparam cfsqltype="cf_sql_varchar" value="#qGetLoadDetails.LoadNumber#">
							
							AND [Time] =<cfqueryparam value='#Local.Time#' cfsqltype="cf_sql_varchar">
							AND Shipment_Status_Code =<cfqueryparam value='#local.shipment_status_Code#' cfsqltype="cf_sql_varchar">
							
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
								<cfif  (NOT len(qGetLoadDetails.EdiNewStopNO) OR NOT len(qGetLoadDetails.EntityIdentityCode) OR  NOT len(qGetLoadDetails.IdentityCode)) > 
									<cfif qGetLoadDetails.LoadType EQ 1>
										<cfset result = result & " EDI 214 pickup stop details are missing">
									<cfelse>
										<cfset result = result & " EDI 214 delivery stop details are missing">
									</cfif>
								<cfelse>
								
								<cfif Findnocase('-',qGetLoadDetails.edistoptime) GT 0  AND Not Len(local.ediReasoncode)
								AND qGetLoadDetails.lm_LoadStops_StopDateQ EQ '53-54' 
								AND (qGetLoadDetails.Ship_TimeOut LT Left(qGetLoadDetails.Ship_Time,4) OR  qGetLoadDetails.Ship_TimeOut GT Right(qGetLoadDetails.Ship_Time,4))>

									
												
										<cfset result = "EDI 214 Delivery time out for stop #qGetLoadDetails.stopno+1# is not in the range  #qGetLoadDetails.edistoptime#. Please choose the reason code.">

									

									

								<cfelseif Len(local.frmTimeIn ) AND Len(Local.frmTimeOut) AND (local.frmTimeIn GT local.frmTimeOut)>
									<cfset result = "EDI 214 Delivery Time In for stop #qGetLoadDetails.stopno+1# is after the time out.">
								<cfelse>


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
									<cfqueryparam value='#qGetLoadDetails.LoadNumber#' cfsqltype="cf_sql_varchar">
									,<cfqueryparam value='#qGetLoadDetails.BolNum#' cfsqltype="cf_sql_varchar">
									,<cfqueryparam value='#qGetLoadDetails.EDISCAC#' cfsqltype="cf_sql_varchar">
									,<cfqueryparam value='#qGetLoadDetails.EntityIdentityCode#' cfsqltype="cf_sql_varchar">
									,<cfqueryparam value='#qGetLoadDetails.custname#' cfsqltype="cf_sql_varchar">
									,<cfqueryparam value='#qGetLoadDetails.IdentityCodeQ#' cfsqltype="cf_sql_varchar">
									,<cfqueryparam value='#qGetLoadDetails.IdentityCode#' cfsqltype="cf_sql_varchar">
									,<cfqueryparam value='#Assign_Number#' cfsqltype="cf_sql_varchar">
									,<cfqueryparam value='#local.shipment_status_Code#' cfsqltype="cf_sql_varchar">
									,<cfqueryparam value='#local.shipment_status#' cfsqltype="cf_sql_varchar">
									,<cfqueryparam value='#dateformat(qGetLoadDetails.Ship_Date,"yyyymmdd")#' cfsqltype="cf_sql_varchar">
									,<cfqueryparam value='#local.Time#' cfsqltype="cf_sql_varchar">
									'LT'
									,<cfqueryparam value='#qGetLoadDetails.CustomerPONo#' cfsqltype="cf_sql_varchar">
									,0
						           	,<cfqueryparam value='#qGetLoadDetails.receiverid#' cfsqltype="cf_sql_varchar">
						           	,''
						           	,<cfqueryparam value='#qGetLoadDetails.EdiNewStopNO#' cfsqltype="cf_sql_varchar">
						           	,getdate()
						           	,''
									,<cfqueryparam value='#arguments.frmstruct.editid#' cfsqltype="cf_sql_varchar">
									)
							</cfquery>
							<cfset Assign_Number = Assign_Number +1>
							<cfset EDI214_Status ='#local.shipment_status# - #local.shipment_status_Code#'>
							<cfset LogEdi214(qGetLoadDetails.BolNum, DocType, EDI214_Status, qGetLoadDetails.LoadNumber,qGetLoadDetails.PayerID,qGetLoadDetails.ReceiverID)>
							<cfset result = result & "EDI 214 delivery information has been queued.">
							<cfset AlertEDIReasonMessage = qGetLoadDetails.EDIReasonMessage>
							<cfset showEdistopDate =  Mid(qGetLoadDetails.Edistopdate,5,2) &"/" & Mid(qGetLoadDetails.Edistopdate,7,2) & "/" & Mid(qGetLoadDetails.Edistopdate,1,4) >		
							<cfset showEdistoptime = Mid(qGetLoadDetails.Edistoptime,1,2) & ":" &	Mid(qGetLoadDetails.Edistoptime,3,4)>

							</cfif>
							
						</cfif>
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
		<cfargument name="CustomerID" type="string" required="yes" />
		<cfargument name="ReceiverID" type="string" required="yes" />
		
		<cfquery name="qinsEDILog" datasource="#Application.dsn#">
			INSERT INTO EDI204Log (
					[LoadLogID]
		           ,[BOLNumber]
		           ,[Detail]
		           ,[CreatedDate]
		           ,[LoadNumber]
		           ,[DocType]
		           ,[ModifiedDate]
		           ,CustomerID
				   ,ReceiverID
				)
			VALUES(newid()
				,<cfqueryparam value="#Arguments.BolNum#" cfsqltype="cf_sql_varchar">
				,<cfqueryparam value="EDI#Arguments.DocType# processed with status #Arguments.EDI214Status#." cfsqltype="cf_sql_varchar">
				,getdate()
				,<cfqueryparam value="#Arguments.LoadNumber#" cfsqltype="CF_SQL_INTEGER">
				,<cfqueryparam value="#Arguments.DocType#" cfsqltype="cf_sql_varchar">
				,getdate()
				,<cfqueryparam value='#Arguments.CustomerID#' cfsqltype="cf_sql_varchar">
				,<cfqueryparam value='#Arguments.ReceiverID#' cfsqltype="cf_sql_varchar">
				)
		</cfquery>

	</cffunction>
	
	<cffunction name="postToDirectFrieght" access="public" returntype="any">
		<cfargument name="frmstruct" type="struct" required="yes">

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

			<cfinvoke method="DirectFreightLoadboard" impref="#arguments.frmstruct.loadManualNo#" LoadId="#arguments.frmstruct.editid#" DirectFreightLoadboardUserName="#arguments.frmstruct.DirectFreightLoadboardUserName#" DirectFreightLoadboardPassword="#arguments.frmstruct.DirectFreightLoadboardPassword#" POSTMETHOD="#p_method#"  IncludeCarierRate="#IncludeCarierRate#" CARRIERRATE="#arguments.frmstruct.CARRIERRATE#" returnvariable="request.DirectFreightLoadboard" />

			<cfset MsgDF=#request.DirectFreightLoadboard#>
		<cfelseif structKeyExists(arguments.frmstruct,"IntegrateWithDirectFreightLoadboard") and  arguments.frmstruct.IntegrateWithDirectFreightLoadboard EQ 1  AND arguments.frmstruct.loadDirectFreightPost EQ 1 AND NOT structKeyExists(arguments.frmstruct,"posttoDirectFreight")>
			<cfinvoke method="DirectFreightLoadboard" impref="#arguments.frmstruct.loadManualNo#" LoadId="#arguments.frmstruct.editid#" DirectFreightLoadboardUserName="#arguments.frmstruct.DirectFreightLoadboardUserName#" DirectFreightLoadboardPassword="#arguments.frmstruct.DirectFreightLoadboardPassword#" POSTMETHOD="DEL"  returnvariable="request.DirectFreightLoadboard" />

			<cfset MsgDF=#request.DirectFreightLoadboard#>
		</cfif>
		<cfif NOT structKeyExists(arguments.frmstruct,"IntegrateWithDirectFreightLoadboard") AND structKeyExists(arguments.frmstruct,"posttoDirectFreight")>
			<cfset MsgDF="There is a problem in logging to Direct Freight Loadboard">
		</cfif>
		<cfreturn MsgDF>
	</cffunction>

	<cffunction name="GetTranscore" access="public" returntype="any">
		<cfargument name="loadManualNo" type="string" required="yes">
		<cfquery name="qryGetTranscore" datasource="#variables.dsn#">
			select IsTransCorePst from Loads  WITH (NOLOCK) WHERE ControlNumber=
	        <cfif NOT len(trim(arguments.loadManualNo))>
	            <cfqueryparam cfsqltype="cf_sql_bigint" value="#trim(arguments.loadManualNo)#"  null="yes" />
	        <cfelse>
	            <cfqueryparam cfsqltype="cf_sql_bigint" value="#trim(arguments.loadManualNo)#" />
	        </cfif>
	        and customerid in (select customerid from CustomerOffices WITH (NOLOCK) inner join offices on CustomerOffices.officeid = offices.officeid where offices.companyid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#session.companyid#">) 
		</cfquery>

		<cfset variables.datStatus=0>
		<cfif qryGetTranscore.recordcount>
			<cfif qryGetTranscore.IsTransCorePst eq 1>
				<cfset variables.datStatus=1>
			</cfif>
		</cfif>

		<cfreturn variables.datStatus>
	</cffunction>

	<cffunction name="unLockLoad" access="public" returntype="any">
		<cfargument name="LastLoadId" type="string" required="yes">
		<cfquery name="qUnLockLoad" datasource="#variables.dsn#">
			UPDATE  Loads SET IsLocked = 0 where loadid=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.LastLoadId#">
		</cfquery>
	</cffunction>

	<cffunction name="UpdateUserDefinedFieldTrucking" access="public" returntype="any">
		<cfargument name="LastLoadId" type="string" required="yes">
		<cfargument name="userDefinedForTrucking" type="string" required="yes">
		<cfquery name="qUpdateUserDefinedFieldTrucking" datasource="#variables.dsn#">
			UPDATE  Loads SET
			userDefinedFieldTrucking=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.userDefinedForTrucking#">
			where loadid=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.LastLoadId#">
		</cfquery>
	</cffunction>

	<cffunction name="UpdateLoadNoOfTrips" access="public" returntype="any">
		<cfargument name="editid" type="string" required="yes">
		<cfargument name="noOfTrips" type="string" required="yes">
		<cfquery name="qUpdateLoadNoOfTrips" datasource="#variables.dsn#">
			UPDATE Loads SET
			noOfTrips=<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.noOfTrips#">
			where loadid=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.editid#">
		</cfquery>
	</cffunction>

	<cffunction name="UpdateLoadStopIntermodalImport" access="public" returntype="any">
		<cfargument name="lastInsertedStopId" type="string" required="yes">
		<cfargument name="frmstruct" type="struct" required="yes">

		<cfquery name="qLoadStopIntermodalImportExists" datasource="#variables.dsn#">
			SELECT LoadStopID FROM LoadStopIntermodalImport
			WHERE LoadStopID = <cfqueryparam value="#arguments.lastInsertedStopId#" cfsqltype="cf_sql_varchar">
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
					LoadStopID = <cfqueryparam value="#arguments.lastInsertedStopId#" cfsqltype="cf_sql_varchar"> AND
					StopNo = <cfqueryparam value="1" cfsqltype="cf_sql_integer">
			</cfquery>
		<cfelse>
			<cfquery name="qUpdateLoadStopIntermodalImport" datasource="#variables.dsn#">
				insert into LoadStopIntermodalImport(LoadStopID,StopNo,dateDispatched,steamShipLine,eta,oceanBillofLading,actualArrivalDate,seal,customersReleaseDate,vesselName,freightReleaseDate,dateAvailable,demuggageFreeTimeExpirationDate,perDiemFreeTimeExpirationDate,pickupDate,requestedDeliveryDate,requestedDeliveryTime,scheduledDeliveryDate,scheduledDeliveryTime,unloadingDelayDetentionStartDate,unloadingDelayDetentionStartTime,actualDeliveryDate,unloadingDelayDetentionEndDate,unloadingDelayDetentionEndTime,returnDate,pickUpAddress,deliveryAddress,emptyReturnAddress)
				values (<cfqueryparam value="#arguments.lastInsertedStopId#" cfsqltype="cf_sql_varchar">,
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

	</cffunction>

	<cffunction name="SetImportLoadAddress" access="public" returntype="any">
		<cfargument name="frmstruct" type="struct" required="yes">
		<cfargument name="lastInsertedStopId" type="string" required="yes">

		<cfinvoke method="UpdateLoadStopIntermodalImport" lastInsertedStopId="#arguments.lastInsertedStopId#" frmstruct="#arguments.frmstruct#">
		<cfinvoke component="#variables.objLoadgatewayUpdate#" method="getLoadStopAddress" tablename="LoadStopCargoPickupAddress" address="#arguments.frmstruct.pickUpAddress#" returnvariable="qLoadStopCargoPickupAddressExists" />
		<cfif qLoadStopCargoPickupAddressExists.recordcount>
			<cfquery name="qUpdateCargoPickupAddress" datasource="#variables.dsn#">
				update LoadStopCargoPickupAddress
				set address = <cfqueryparam value="#arguments.frmstruct.pickUpAddress#" cfsqltype="cf_sql_varchar">,
					LoadStopID = <cfqueryparam value="#arguments.lastInsertedStopId#" cfsqltype="cf_sql_varchar">,
					dateModified = <cfqueryparam value="#now()#" cfsqltype="cf_sql_date">
				where ID = <cfqueryparam value="#qLoadStopCargoPickupAddressExists.ID#" cfsqltype="cf_sql_integer">
			</cfquery>
		<cfelse>
			<cfquery name="qInsertCargoPickupAddress" datasource="#variables.dsn#">
				insert into LoadStopCargoPickupAddress
					(address, LoadStopID, dateAdded, dateModified)
				values(
						<cfqueryparam value="#arguments.frmstruct.pickUpAddress#" cfsqltype="cf_sql_varchar">,
						<cfqueryparam value="#arguments.lastInsertedStopId#" cfsqltype="cf_sql_varchar">,
						<cfqueryparam value="#now()#" cfsqltype="cf_sql_date">,
						<cfqueryparam value="#now()#" cfsqltype="cf_sql_date">)
			</cfquery>
		</cfif>
		<cfinvoke component="#variables.objLoadgatewayUpdate#" method="getLoadStopAddress" tablename="LoadStopCargoDeliveryAddress" address="#arguments.frmstruct.deliveryAddress#" returnvariable="qLoadStopCargoDeliveryAddressExists" />
		<cfif qLoadStopCargoDeliveryAddressExists.recordcount>
			<cfquery name="qUpdateCargoDeliveryAddress" datasource="#variables.dsn#">
				update LoadStopCargoDeliveryAddress
				set address = <cfqueryparam value="#arguments.frmstruct.deliveryAddress#" cfsqltype="cf_sql_varchar">,
					LoadStopID = <cfqueryparam value="#arguments.lastInsertedStopId#" cfsqltype="cf_sql_varchar">,
					dateModified = <cfqueryparam value="#now()#" cfsqltype="cf_sql_date">
				where ID = <cfqueryparam value="#qLoadStopCargoDeliveryAddressExists.ID#" cfsqltype="cf_sql_integer">
			</cfquery>
		<cfelse>
			<cfquery name="qInsertCargoDeliveryAddress" datasource="#variables.dsn#">
				insert into LoadStopCargoDeliveryAddress (address, LoadStopID, dateAdded, dateModified)
				values ( <cfqueryparam value="#arguments.frmstruct.deliveryAddress#" cfsqltype="cf_sql_varchar">,
						<cfqueryparam value="#arguments.lastInsertedStopId#" cfsqltype="cf_sql_varchar">,
						<cfqueryparam value="#now()#" cfsqltype="cf_sql_date">,
						<cfqueryparam value="#now()#" cfsqltype="cf_sql_date">)
			</cfquery>
		</cfif>
		<cfinvoke component="#variables.objLoadgatewayUpdate#" method="getLoadStopAddress" tablename="LoadStopEmptyReturnAddress" address="#arguments.frmstruct.emptyReturnAddress#" returnvariable="qLoadStopEmptyReturnAddressExists" />
		<cfif qLoadStopEmptyReturnAddressExists.recordcount>
			<cfquery name="qUpdateEmptyReturnAddress" datasource="#variables.dsn#">
				update LoadStopEmptyReturnAddress
				set address = <cfqueryparam value="#arguments.frmstruct.emptyReturnAddress#" cfsqltype="cf_sql_varchar">,
					LoadStopID = <cfqueryparam value="#arguments.lastInsertedStopId#" cfsqltype="cf_sql_varchar">,
					dateModified = <cfqueryparam value="#now()#" cfsqltype="cf_sql_date">
				where ID = <cfqueryparam value="#qLoadStopEmptyReturnAddressExists.ID#" cfsqltype="cf_sql_integer">
			</cfquery>
		<cfelse>
			<cfquery name="qInsertEmptyReturnAddress" datasource="#variables.dsn#">
				insert into LoadStopEmptyReturnAddress(address, LoadStopID, dateAdded, dateModified)
				values(
						<cfqueryparam value="#arguments.frmstruct.emptyReturnAddress#" cfsqltype="cf_sql_varchar">,
						<cfqueryparam value="#arguments.lastInsertedStopId#" cfsqltype="cf_sql_varchar">,
						<cfqueryparam value="#now()#" cfsqltype="cf_sql_date">,
						<cfqueryparam value="#now()#" cfsqltype="cf_sql_date">)
			</cfquery>
		</cfif>

		<cfreturn 1>
	</cffunction>

	<cffunction name="SetExportLoadAddress" access="public" returntype="any">
		<cfargument name="frmstruct" type="struct" required="yes">
		<cfargument name="lastInsertedStopId" type="string" required="yes">
		<cfinvoke component="#variables.objLoadgatewayUpdate#" method="UpdateLoadAddNew"
			lastInsertedStopId = "#arguments.lastInsertedStopId#" frmstruct="#arguments.frmstruct#"returnvariable="qUpdateLoadID"/>
			<cfinvoke component="#variables.objLoadgatewayUpdate#" method="getLoadStopAddress" tablename="LoadStopEmptyPickupAddress" address="#arguments.frmstruct.exportEmptyPickUpAddress#" returnvariable="qLoadStopEmptyPickupAddressExists" />
			<cfif qLoadStopEmptyPickupAddressExists.recordcount>
				<cfquery name="qUpdateEmptyPickupAddress" datasource="#variables.dsn#">
					update LoadStopEmptyPickupAddress
					set address = <cfqueryparam value="#arguments.frmstruct.exportEmptyPickUpAddress#" cfsqltype="cf_sql_varchar">,
						LoadStopID = <cfqueryparam value="#arguments.lastInsertedStopId#" cfsqltype="cf_sql_varchar">,
						dateModified = <cfqueryparam value="#now()#" cfsqltype="cf_sql_date">
					where ID = <cfqueryparam value="#qLoadStopEmptyPickupAddressExists.ID#" cfsqltype="cf_sql_integer">
				</cfquery>
			<cfelse>
				<cfquery name="qInsertEmptyPickupAddress" datasource="#variables.dsn#">
					insert into LoadStopEmptyPickupAddress (address, LoadStopID, dateAdded, dateModified)
					values(<cfqueryparam value="#arguments.frmstruct.exportEmptyPickUpAddress#" cfsqltype="cf_sql_varchar">,
							<cfqueryparam value="#arguments.lastInsertedStopId#" cfsqltype="cf_sql_varchar">,
							<cfqueryparam value="#now()#" cfsqltype="cf_sql_date">,
							<cfqueryparam value="#now()#" cfsqltype="cf_sql_date">)
				</cfquery>
			</cfif>
			<cfinvoke component="#variables.objLoadgatewayUpdate#" method="getLoadStopAddress" tablename="LoadStopLoadingAddress" address="#arguments.frmstruct.exportLoadingAddress#" returnvariable="qLoadStopLoadingAddressExists" />
			<cfif qLoadStopLoadingAddressExists.recordcount>
				<cfquery name="qUpdateLoadingAddress" datasource="#variables.dsn#">
					update LoadStopLoadingAddress
					set address = <cfqueryparam value="#arguments.frmstruct.exportLoadingAddress#" cfsqltype="cf_sql_varchar">,
						LoadStopID = <cfqueryparam value="#arguments.lastInsertedStopId#" cfsqltype="cf_sql_varchar">,
						dateModified = <cfqueryparam value="#now()#" cfsqltype="cf_sql_date">
					where ID = <cfqueryparam value="#qLoadStopLoadingAddressExists.ID#" cfsqltype="cf_sql_integer">
				</cfquery>
			<cfelse>
				<cfquery name="qInsertLoadingAddress" datasource="#variables.dsn#">
					insert into LoadStopLoadingAddress (address, LoadStopID, dateAdded, dateModified)
					values (
							<cfqueryparam value="#arguments.frmstruct.exportLoadingAddress#" cfsqltype="cf_sql_varchar">,
							<cfqueryparam value="#arguments.lastInsertedStopId#" cfsqltype="cf_sql_varchar">,
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
						LoadStopID = <cfqueryparam value="#arguments.lastInsertedStopId#" cfsqltype="cf_sql_varchar">,
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
							<cfqueryparam value="#arguments.lastInsertedStopId#" cfsqltype="cf_sql_varchar">,
							<cfqueryparam value="#now()#" cfsqltype="cf_sql_date">,
							<cfqueryparam value="#now()#" cfsqltype="cf_sql_date">
						)
				</cfquery>
			</cfif>
			<cfreturn 1>
	</cffunction>

	<cffunction name="updateConsigneeStopLoadEdit" access="public" returntype="any">
    	<cfargument name="LastLoadId" type="string" required="yes">
    	<cfargument name="lastUpdatedConsCustomerID" type="string" required="yes">
    	<cfargument name="ConsBlind" type="string" required="yes">
    	<cfargument name="noOfDays1" type="string" required="yes">
		<cfargument name="frmstruct" type="struct" required="yes">

		<CFSTOREDPROC PROCEDURE="USP_UpdateLoadStop" DATASOURCE="#variables.dsn#">
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
			<CFPROCPARAM VALUE="#arguments.frmstruct.consigneePickupDate#" cfsqltype="cf_sql_date" null="#yesNoFormat(NOT len(arguments.frmstruct.consigneePickupDate) OR NOT isdate(arguments.frmstruct.consigneePickupDate))#">
			<CFPROCPARAM VALUE="#arguments.frmstruct.consigneePickupTime#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#arguments.frmstruct.consigneetimein#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#arguments.frmstruct.consigneetimeout#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#session.adminUserName#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#arguments.lastUpdatedConsCustomerID#" cfsqltype="CF_SQL_VARCHAR" null="#yesNoFormat(NOT len(arguments.lastUpdatedConsCustomerID))#">
			<CFPROCPARAM VALUE="#arguments.ConsBlind#" cfsqltype="CF_SQL_BIT">
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
			<CFPROCPARAM VALUE="#session.companyid#" cfsqltype="CF_SQL_VARCHAR">
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
				<CFPROCPARAM VALUE="#arguments.frmstruct.CarrierContactID2_1#"  cfsqltype="CF_SQL_VARCHAR">
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
				<CFPROCPARAM VALUE="#arguments.frmstruct.CarrierContactID3_1#"  cfsqltype="CF_SQL_VARCHAR">
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

    <cffunction name="UpdateLoadItemLoadEdit" access="public" returntype="any">
    	<cfargument name="frmstruct" type="struct" required="yes">
    	<cfargument name="num" type="string" required="yes">
		<cfargument name="lastInsertedStopId" type="string" required="yes">

		<cfset var qty=VAL(evaluate("arguments.frmstruct.qty_#arguments.num#"))>
		<cfset var unit=evaluate("arguments.frmstruct.unit_#arguments.num#")>
		<cfset var description=evaluate("arguments.frmstruct.description_#arguments.num#")>
		<cfset var dimensions=evaluate("arguments.frmstruct.dimensions_#arguments.num#")>
		<cfif isdefined("arguments.frmstruct.weight_#arguments.num#")>
			<cfset var weight=VAL(replaceNoCase(evaluate("arguments.frmstruct.weight_#arguments.num#"), ",", "","ALL"))>
		<cfelse>
			<cfset var weight=0>
		</cfif>
		<cfset var class=evaluate("arguments.frmstruct.class_#arguments.num#")>
		<cfset CustomerRate=evaluate("arguments.frmstruct.CustomerRate_#arguments.num#")>
		<cfset CustomerRate = replace( replace( CustomerRate,"$","","ALL"),",","","ALL") >
		<cfset var CarrierRate=evaluate("arguments.frmstruct.CarrierRate_#arguments.num#")>
		<cfset CarrierRate = replace( replace( CarrierRate,"$","","ALL"),",","","ALL") >
		<cfset CustomerRate = replace( replace( CustomerRate,"(","","ALL"),")","","ALL") >
		<cfset CarrierRate = replace( replace( CarrierRate,"(","","ALL"),")","","ALL") >
		<cfset var custCharges =evaluate("arguments.frmstruct.custCharges_#arguments.num#")>
		<cfset custCharges = replace( replace( custCharges,"$","","ALL"),",","","ALL") >
		<cfset var carrCharges=evaluate("arguments.frmstruct.carrCharges_#arguments.num#")>
		<cfset carrCharges = replace( replace( carrCharges,"$","","ALL"),",","","ALL") >
		<cfset var CarrRateOfCustTotal =evaluate("arguments.frmstruct.CarrierPer_#arguments.num#")>
		<cfset CarrRateOfCustTotal = replace( CarrRateOfCustTotal,"%","","ALL") >

		<cfset var directCost =evaluate("arguments.frmstruct.directCost_#arguments.num#")>
		<cfset directCost = replace( replace( directCost,"$","","ALL"),",","","ALL") >
		<cfset var directCostTotal =evaluate("arguments.frmstruct.directCostTotal_#arguments.num#")>
		<cfset directCostTotal = replace( replace( directCostTotal,"$","","ALL"),",","","ALL") >

		<cfif not Isnumeric(CarrRateOfCustTotal)>
			<cfset CarrRateOfCustTotal = 0>
		</cfif>
		<cfif isdefined('arguments.frmstruct.isFee_#arguments.num#')>
		 	<cfset var isFee=true>
		<cfelse>
		 	<cfset var isFee=false>
		</cfif>
		<!--- Load Logging--->
		<cfinvoke method="LoadLogRegister" type="USP_UpdateLoadItem" instance=1 whereList="#arguments.lastInsertedStopId#,#arguments.num#">
		<!--- Load Logging--->
		 <CFSTOREDPROC PROCEDURE="USP_UpdateLoadItem" DATASOURCE="#variables.dsn#">
			<CFPROCPARAM VALUE="#arguments.lastInsertedStopId#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#arguments.num#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#val(qty)#" cfsqltype="CF_SQL_float">
			<CFPROCPARAM VALUE="#unit#" cfsqltype="CF_SQL_VarCHAR">
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

		<!--- Load Logging--->
		<cfinvoke method="LoadLogRegister" type="USP_UpdateLoadItem" instance=2 whereList="#arguments.lastInsertedStopId#,#arguments.num#,0">
		<!--- Load Logging--->
		<cfreturn 1>		
    </cffunction>

    <cffunction name="InsertLoadItemLoadEdit" access="public" returntype="any">
    	<cfargument name="frmstruct" type="struct" required="yes">
    	<cfargument name="num" type="string" required="yes">
		<cfargument name="lastInsertedStopId" type="string" required="yes">

		<cfset qty=VAL(evaluate("arguments.frmstruct.qty_#arguments.num#"))>
		 <cfset unit=evaluate("arguments.frmstruct.unit_#arguments.num#")>
		 <cfset description=evaluate("arguments.frmstruct.description_#arguments.num#")>
		 <cfset dimensions=evaluate("arguments.frmstruct.dimensions_#arguments.num#")>
		 <cfif isdefined("arguments.frmstruct.weight_#arguments.num#")>
			<cfset weight=VAL(replaceNoCase(evaluate("arguments.frmstruct.weight_#arguments.num#"), ",", "","ALL"))>
		<cfelse>
			<cfset weight=0>
		</cfif>
		 <cfset class=evaluate("arguments.frmstruct.class_#arguments.num#")>
		 <cfset CustomerRate=evaluate("arguments.frmstruct.CustomerRate_#arguments.num#")>
		 <cfset CustomerRate = replace( replace( CustomerRate,"$","","ALL"),",","","ALL") >
		 <cfset CarrierRate=evaluate("arguments.frmstruct.CarrierRate_#arguments.num#")>
		 <cfset CarrierRate = replace( replace( CarrierRate,"$","","ALL"),",","","ALL") >
		 <cfset CustomerRate = replace( replace( CustomerRate,"(","","ALL"),")","","ALL") >
 		 <cfset CarrierRate = replace( replace( CarrierRate,"(","","ALL"),")","","ALL") >
		 <cfif structKeyExists(arguments.frmstruct, "custCharges_#arguments.num#")>
			 <cfset custCharges=evaluate("arguments.frmstruct.custCharges_#arguments.num#")>
			 <cfset custCharges = replace( replace( custCharges,"$","","ALL"),",","","ALL") >
		 <cfelse>
		 	 <cfset custCharges = 0 >
		 </cfif>
		 <cfset carrCharges=evaluate("arguments.frmstruct.carrCharges_#arguments.num#")>
		 <cfset carrCharges = replace( replace( carrCharges,"$","","ALL"),",","","ALL") >
		 <cfset CarrRateOfCustTotal=evaluate("arguments.frmstruct.CarrierPer_#arguments.num#")>
		 <cfset CarrRateOfCustTotal = replace( CarrRateOfCustTotal,"%","","ALL") >
		 <cfset directCost=evaluate("arguments.frmstruct.directCost_#arguments.num#")>
		 <cfset directCost = replace( replace( directCost,"$","","ALL"),",","","ALL") >
		 <cfset directCostTotal =evaluate("arguments.frmstruct.directCostTotal_#arguments.num#")>
		 <cfset directCostTotal = replace( replace( directCostTotal,"$","","ALL"),",","","ALL")>
		 <cfif not len(trim(directCost))><cfset directCost=0.00></cfif>
		 <cfif not len(trim(directCostTotal))><cfset directCostTotal=0.00></cfif>
		 <cfif not Isnumeric(CarrRateOfCustTotal)><cfset CarrRateOfCustTotal = 0></cfif>
		 <cfif isdefined('arguments.frmstruct.isFee_#arguments.num#')><cfset isFee=true><cfelse><cfset isFee=false></cfif>
		 <cfif not len(trim(CustomerRate))><cfset CustomerRate=0.00></cfif>
		 <cfif not len(trim(CarrierRate))><cfset CarrierRate=0.00></cfif>
		<CFSTOREDPROC PROCEDURE="USP_InsertLoadItem" DATASOURCE="#variables.dsn#">
			<CFPROCPARAM VALUE="#arguments.lastInsertedStopId#" cfsqltype="CF_SQL_VARCHAR">
		 	<CFPROCPARAM VALUE="#arguments.num#" cfsqltype="CF_SQL_VARCHAR">
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
		<cfreturn 1>			
	</cffunction>

	<cffunction name="insertShipperStopLoadEdit" access="public" returntype="any">
    	<cfargument name="LastLoadId" type="string" required="yes">
    	<cfargument name="lastUpdatedShipCustomerID" type="string" required="yes">
    	<cfargument name="ShipBlind" type="string" required="yes">
    	<cfargument name="NewStopNo" type="string" required="yes">
    	<cfargument name="noOfDays" type="string" required="yes">
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
				<cfif len(evaluate('arguments.frmstruct.stOffice#arguments.stpID#')) gt 1>
					<CFPROCPARAM VALUE="#evaluate('arguments.frmstruct.stOffice#arguments.stpID#')#" cfsqltype="CF_SQL_VARCHAR">
				<cfelse>
					<CFPROCPARAM VALUE="Null" cfsqltype="CF_SQL_VARCHAR">
				</cfif>
			</cfif>
			<CFPROCPARAM VALUE="#EVALUATE('arguments.frmstruct.shipperPickupNO1#arguments.stpID#')#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#EVALUATE('arguments.frmstruct.shipperPickupDate#arguments.stpID#')#" cfsqltype="CF_SQL_dATE" null="#yesNoFormat(NOT len(EVALUATE('arguments.frmstruct.shipperPickupDate#arguments.stpID#')))#">
			<CFPROCPARAM VALUE="#EVALUATE('arguments.frmstruct.shipperPickupTime#arguments.stpID#')#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#EVALUATE('arguments.frmstruct.shipperTimeIn#arguments.stpID#')#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#EVALUATE('arguments.frmstruct.shipperTimeOut#arguments.stpID#')#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#session.adminUserName#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#arguments.lastUpdatedShipCustomerID#" cfsqltype="CF_SQL_VARCHAR"  null="#yesNoFormat(NOT len(arguments.lastUpdatedShipCustomerID))#">
			<CFPROCPARAM VALUE="#arguments.ShipBlind#" cfsqltype="CF_SQL_BIT">
			<CFPROCPARAM VALUE="#EVALUATE('arguments.frmstruct.shipperNotes#arguments.stpID#')#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#EVALUATE('arguments.frmstruct.shipperDirection#arguments.stpID#')#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="1" cfsqltype="CF_SQL_INTEGER">
			<CFPROCPARAM VALUE="#EVALUATE('arguments.frmstruct.shipperlocation#arguments.stpID#')#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#EVALUATE('arguments.frmstruct.shipperCity#arguments.stpID#')#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#EVALUATE('arguments.frmstruct.shipperStateName#arguments.stpID#')#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#EVALUATE('arguments.frmstruct.shipperZipCode#arguments.stpID#')#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#EVALUATE('arguments.frmstruct.shipperContactPerson#arguments.stpID#')#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#EVALUATE('arguments.frmstruct.shipperPhone#arguments.stpID#')#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#EVALUATE('arguments.frmstruct.shipperPhoneExt#arguments.stpID#')#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#EVALUATE('arguments.frmstruct.shipperFax#arguments.stpID#')#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#EVALUATE('arguments.frmstruct.shipperEmail#arguments.stpID#')#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#EVALUATE('arguments.frmstruct.shipperName#arguments.stpID#')#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#EVALUATE('arguments.frmstruct.userDef1#arguments.stpID#')#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#EVALUATE('arguments.frmstruct.userDef2#arguments.stpID#')#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#EVALUATE('arguments.frmstruct.userDef3#arguments.stpID#')#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#EVALUATE('arguments.frmstruct.userDef4#arguments.stpID#')#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#EVALUATE('arguments.frmstruct.userDef5#arguments.stpID#')#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#EVALUATE('arguments.frmstruct.userDef6#arguments.stpID#')#" cfsqltype="CF_SQL_VARCHAR">
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
			<cfprocresult name="qLastInsertedShipper">
		</CFSTOREDPROC>
		<cfreturn qLastInsertedShipper>
	</cffunction>

	<cffunction name="insertConsigneeStopLoadEdit" access="public" returntype="any">
		<cfargument name="LastLoadId" type="string" required="yes">
    	<cfargument name="lastUpdatedConsCustomerID" type="string" required="yes">
    	<cfargument name="ConsBlind" type="string" required="yes">
    	<cfargument name="NewStopNo" type="string" required="yes">
    	<cfargument name="noOfDays" type="string" required="yes">
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
				<cfif len(evaluate('arguments.frmstruct.stOffice#arguments.stpID#')) gt 1>
					<CFPROCPARAM VALUE="#evaluate('arguments.frmstruct.stOffice#arguments.stpID#')#" cfsqltype="CF_SQL_VARCHAR">
				<cfelse>
					<CFPROCPARAM VALUE="Null" cfsqltype="CF_SQL_VARCHAR">
				</cfif>
			</cfif>
			<CFPROCPARAM VALUE="#EVALUATE('arguments.frmstruct.consigneePickupNo#arguments.stpID#')#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#EVALUATE('arguments.frmstruct.consigneePickupDate#arguments.stpID#')#" cfsqltype="CF_SQL_dATE" null="#yesNoFormat(NOT len(EVALUATE('arguments.frmstruct.consigneePickupDate#arguments.stpID#')) OR NOT isDate(EVALUATE('arguments.frmstruct.consigneePickupDate#arguments.stpID#')))#">
			<CFPROCPARAM VALUE="#EVALUATE('arguments.frmstruct.consigneePickupTime#arguments.stpID#')#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#EVALUATE('arguments.frmstruct.consigneetimein#arguments.stpID#')#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#EVALUATE('arguments.frmstruct.consigneetimeout#arguments.stpID#')#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#session.adminUserName#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#arguments.lastUpdatedConsCustomerID#" cfsqltype="CF_SQL_VARCHAR"  null="#yesNoFormat(NOT len(arguments.lastUpdatedConsCustomerID))#">
			<CFPROCPARAM VALUE="#arguments.ConsBlind#" cfsqltype="CF_SQL_BIT">
			<CFPROCPARAM VALUE="#EVALUATE('arguments.frmstruct.consigneeNotes#arguments.stpID#')#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#EVALUATE('arguments.frmstruct.consigneeDirection#arguments.stpID#')#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="2" cfsqltype="CF_SQL_INTEGER">
			<CFPROCPARAM VALUE="#EVALUATE('arguments.frmstruct.consigneelocation#arguments.stpID#')#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#EVALUATE('arguments.frmstruct.consigneeCity#arguments.stpID#')#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#EVALUATE('arguments.frmstruct.consigneeStateName#arguments.stpID#')#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#EVALUATE('arguments.frmstruct.consigneeZipCode#arguments.stpID#')#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#EVALUATE('arguments.frmstruct.consigneeContactPerson#arguments.stpID#')#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#EVALUATE('arguments.frmstruct.consigneePhone#arguments.stpID#')#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#EVALUATE('arguments.frmstruct.consigneePhoneExt#arguments.stpID#')#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#EVALUATE('arguments.frmstruct.consigneeFax#arguments.stpID#')#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#EVALUATE('arguments.frmstruct.consigneeEmail#arguments.stpID#')#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#EVALUATE('arguments.frmstruct.consigneeName#arguments.stpID#')#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#EVALUATE('arguments.frmstruct.userDef1#arguments.stpID#')#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#EVALUATE('arguments.frmstruct.userDef2#arguments.stpID#')#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#EVALUATE('arguments.frmstruct.userDef3#arguments.stpID#')#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#EVALUATE('arguments.frmstruct.userDef4#arguments.stpID#')#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#EVALUATE('arguments.frmstruct.userDef5#arguments.stpID#')#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#EVALUATE('arguments.frmstruct.userDef6#arguments.stpID#')#" cfsqltype="CF_SQL_VARCHAR">
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
			<cfif isdefined('arguments.frmstruct.CarrierEmailID') and len(arguments.frmstruct.CarrierEmailID)>
				<CFPROCPARAM VALUE="#arguments.frmstruct.CarrierEmailID#"  cfsqltype="CF_SQL_VARCHAR">
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

	<cffunction name="updateShipperStopLoadEditStopNo" access="public" returntype="any">
    	<cfargument name="LastLoadId" type="string" required="yes">
    	<cfargument name="lastUpdatedShipCustomerID" type="string" required="yes">
    	<cfargument name="ShipBlind" type="string" required="yes">
    	<cfargument name="stopNo" type="string" required="yes">
    	<cfargument name="NewStopNo" type="string" required="yes">
    	<cfargument name="noOfDays" type="string" required="yes">
		<cfargument name="frmstruct" type="struct" required="yes">
		<cfargument name="stpID" type="string" required="yes">

		<CFSTOREDPROC PROCEDURE="USP_UpdateLoadStop" DATASOURCE="#variables.dsn#">
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
			<CFPROCPARAM VALUE="#left(evaluate('arguments.frmstruct.truckNo#arguments.stpID#'),20)#" cfsqltype="CF_SQL_VARCHAR">
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
				<cfif len(evaluate('arguments.frmstruct.stOffice#arguments.stpID#')) gt 1>
					<CFPROCPARAM VALUE="#evaluate('arguments.frmstruct.stOffice#arguments.stpID#')#" cfsqltype="CF_SQL_VARCHAR">
				<cfelse>
					<CFPROCPARAM VALUE="Null" cfsqltype="CF_SQL_VARCHAR">
				</cfif>
			</cfif>
			<CFPROCPARAM VALUE="#EVALUATE('arguments.frmstruct.shipperPickupNO1#arguments.stpID#')#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#EVALUATE('arguments.frmstruct.shipperPickupDate#arguments.stpID#')#" cfsqltype="CF_SQL_dATE" null="#yesNoFormat(NOT len(EVALUATE('arguments.frmstruct.shipperPickupDate#arguments.stpID#')) OR NOT isDate(EVALUATE('arguments.frmstruct.shipperPickupDate#arguments.stpID#')))#">
			<CFPROCPARAM VALUE="#EVALUATE('arguments.frmstruct.shipperPickupTime#arguments.stpID#')#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#EVALUATE('arguments.frmstruct.shipperTimeIn#arguments.stpID#')#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#EVALUATE('arguments.frmstruct.shipperTimeOut#arguments.stpID#')#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#session.adminUserName#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#arguments.lastUpdatedShipCustomerID#" cfsqltype="CF_SQL_VARCHAR"  null="#yesNoFormat(NOT len(arguments.lastUpdatedShipCustomerID))#">
			<CFPROCPARAM VALUE="#arguments.ShipBlind#" cfsqltype="CF_SQL_BIT">
			<CFPROCPARAM VALUE="#EVALUATE('arguments.frmstruct.shipperNotes#arguments.stpID#')#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#EVALUATE('arguments.frmstruct.shipperDirection#arguments.stpID#')#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="1" cfsqltype="CF_SQL_INTEGER">
			<CFPROCPARAM VALUE="#arguments.stopNo#" cfsqltype="CF_SQL_INTEGER"> <!--- Stop Number --->
			<CFPROCPARAM VALUE="#EVALUATE('arguments.frmstruct.shipperlocation#arguments.stpID#')#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#EVALUATE('arguments.frmstruct.shipperCity#arguments.stpID#')#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#EVALUATE('arguments.frmstruct.shipperStateName#arguments.stpID#')#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#EVALUATE('arguments.frmstruct.shipperZipCode#arguments.stpID#')#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#EVALUATE('arguments.frmstruct.shipperContactPerson#arguments.stpID#')#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#EVALUATE('arguments.frmstruct.shipperPhone#arguments.stpID#')#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#EVALUATE('arguments.frmstruct.shipperPhoneExt#arguments.stpID#')#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#EVALUATE('arguments.frmstruct.shipperFax#arguments.stpID#')#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#EVALUATE('arguments.frmstruct.shipperEmail#arguments.stpID#')#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#EVALUATE('arguments.frmstruct.shipperName#arguments.stpID#')#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#EVALUATE('arguments.frmstruct.userDef1#arguments.stpID#')#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#EVALUATE('arguments.frmstruct.userDef2#arguments.stpID#')#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#EVALUATE('arguments.frmstruct.userDef3#arguments.stpID#')#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#EVALUATE('arguments.frmstruct.userDef4#arguments.stpID#')#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#EVALUATE('arguments.frmstruct.userDef5#arguments.stpID#')#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#EVALUATE('arguments.frmstruct.userDef6#arguments.stpID#')#" cfsqltype="CF_SQL_VARCHAR">
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
			<CFPROCPARAM VALUE="#session.companyid#" cfsqltype="CF_SQL_VARCHAR">
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

			<cfprocresult name="qLastInsertedShipper">
		</CFSTOREDPROC>
		<cfreturn qLastInsertedShipper>
	</cffunction>

	<cffunction name="updateConsigneeStopLoadEditStopNo" access="public" returntype="any">
    	<cfargument name="LastLoadId" type="string" required="yes">
    	<cfargument name="lastUpdatedConsCustomerID" type="string" required="yes">
    	<cfargument name="ShipBlind" type="string" required="yes">
    	<cfargument name="stopNo" type="string" required="yes">
    	<cfargument name="NewStopNo" type="string" required="yes">
    	<cfargument name="noOfDays" type="string" required="yes">
		<cfargument name="frmstruct" type="struct" required="yes">
		<cfargument name="stpID" type="string" required="yes">

		<CFSTOREDPROC PROCEDURE="USP_UpdateLoadStop" DATASOURCE="#variables.dsn#">
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
				<cfif len(evaluate('arguments.frmstruct.stOffice#arguments.stpID#')) gt 1>
					<CFPROCPARAM VALUE="#evaluate('arguments.frmstruct.stOffice#arguments.stpID#')#" cfsqltype="CF_SQL_VARCHAR">
				<cfelse>
					<CFPROCPARAM VALUE="Null" cfsqltype="CF_SQL_VARCHAR">
				</cfif>
			</cfif>
			<CFPROCPARAM VALUE="#EVALUATE('arguments.frmstruct.consigneePickupNo#arguments.stpID#')#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#EVALUATE('arguments.frmstruct.consigneePickupDate#arguments.stpID#')#" cfsqltype="CF_SQL_dATE" null="#yesNoFormat(NOT len(EVALUATE('arguments.frmstruct.consigneePickupDate#arguments.stpID#')) OR NOT isDate(EVALUATE('arguments.frmstruct.consigneePickupDate#arguments.stpID#')))#">
			<CFPROCPARAM VALUE="#EVALUATE('arguments.frmstruct.consigneePickupTime#arguments.stpID#')#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#EVALUATE('arguments.frmstruct.consigneetimein#arguments.stpID#')#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#EVALUATE('arguments.frmstruct.consigneetimeout#arguments.stpID#')#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#session.adminUserName#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#arguments.lastUpdatedConsCustomerID#" cfsqltype="CF_SQL_VARCHAR" null="#yesNoFormat(NOT len(arguments.lastUpdatedConsCustomerID))#">
			<CFPROCPARAM VALUE="#ConsBlind#" cfsqltype="CF_SQL_BIT">
			<CFPROCPARAM VALUE="#EVALUATE('arguments.frmstruct.consigneeNotes#arguments.stpID#')#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#EVALUATE('arguments.frmstruct.consigneeDirection#arguments.stpID#')#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="2" cfsqltype="CF_SQL_INTEGER">
			<CFPROCPARAM VALUE="#arguments.stopNo#" cfsqltype="CF_SQL_INTEGER"> <!--- Stop Number --->
			<CFPROCPARAM VALUE="#EVALUATE('arguments.frmstruct.consigneelocation#arguments.stpID#')#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#EVALUATE('arguments.frmstruct.consigneeCity#arguments.stpID#')#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#EVALUATE('arguments.frmstruct.consigneeStateName#arguments.stpID#')#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#EVALUATE('arguments.frmstruct.consigneeZipCode#arguments.stpID#')#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#EVALUATE('arguments.frmstruct.consigneeContactPerson#arguments.stpID#')#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#EVALUATE('arguments.frmstruct.consigneePhone#arguments.stpID#')#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#EVALUATE('arguments.frmstruct.consigneePhoneExt#arguments.stpID#')#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#EVALUATE('arguments.frmstruct.consigneeFax#arguments.stpID#')#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#EVALUATE('arguments.frmstruct.consigneeEmail#arguments.stpID#')#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#EVALUATE('arguments.frmstruct.consigneeName#arguments.stpID#')#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#EVALUATE('arguments.frmstruct.userDef1#arguments.stpID#')#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#EVALUATE('arguments.frmstruct.userDef2#arguments.stpID#')#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#EVALUATE('arguments.frmstruct.userDef3#arguments.stpID#')#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#EVALUATE('arguments.frmstruct.userDef4#arguments.stpID#')#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#EVALUATE('arguments.frmstruct.userDef5#arguments.stpID#')#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#EVALUATE('arguments.frmstruct.userDef6#arguments.stpID#')#" cfsqltype="CF_SQL_VARCHAR">
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
			<CFPROCPARAM VALUE="#session.companyid#" cfsqltype="CF_SQL_VARCHAR">
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
			<cfif structKeyExists(arguments.frmstruct, "customDriverPayFlatRate#stpID#") AND IsNumeric(arguments.frmstruct["customDriverPayFlatRate#stpID#"])>
				<CFPROCPARAM VALUE="#arguments.frmstruct["customDriverPayFlatRate#stpID#"]#"  cfsqltype="CF_SQL_FLOAT">
			<cfelse>
				<CFPROCPARAM VALUE="0"  cfsqltype="CF_SQL_FLOAT">
			</cfif>

			<cfif structKeyExists(arguments.frmstruct, "customDriverPayFlatRate2_#stpID#") AND IsNumeric(arguments.frmstruct["customDriverPayFlatRate2_#stpID#"])>
				<CFPROCPARAM VALUE="#arguments.frmstruct["customDriverPayFlatRate2_#stpID#"]#"  cfsqltype="CF_SQL_FLOAT">
			<cfelse>
				<CFPROCPARAM VALUE="0"  cfsqltype="CF_SQL_FLOAT">
			</cfif>

			<cfif structKeyExists(arguments.frmstruct, "customDriverPayFlatRate3_#stpID#") AND IsNumeric(arguments.frmstruct["customDriverPayFlatRate3_#stpID#"])>
				<CFPROCPARAM VALUE="#arguments.frmstruct["customDriverPayFlatRate3_#stpID#"]#"  cfsqltype="CF_SQL_FLOAT">
			<cfelse>
				<CFPROCPARAM VALUE="0"  cfsqltype="CF_SQL_FLOAT">
			</cfif>

			<cfif structKeyExists(arguments.frmstruct, "customDriverPayPercentage#stpID#") AND IsNumeric(arguments.frmstruct["customDriverPayPercentage#stpID#"])>
				<CFPROCPARAM VALUE="#arguments.frmstruct["customDriverPayPercentage#stpID#"]#"  cfsqltype="CF_SQL_FLOAT">
			<cfelse>
				<CFPROCPARAM VALUE="0"  cfsqltype="CF_SQL_FLOAT">
			</cfif>

			<cfif structKeyExists(arguments.frmstruct, "customDriverPayPercentage2_#stpID#") AND IsNumeric(arguments.frmstruct["customDriverPayPercentage2_#stpID#"])>
				<CFPROCPARAM VALUE="#arguments.frmstruct["customDriverPayPercentage2_#stpID#"]#"  cfsqltype="CF_SQL_FLOAT">
			<cfelse>
				<CFPROCPARAM VALUE="0"  cfsqltype="CF_SQL_FLOAT">
			</cfif>

			<cfif structKeyExists(arguments.frmstruct, "customDriverPayPercentage3_#stpID#") AND IsNumeric(arguments.frmstruct["customDriverPayPercentage3_#stpID#"])>
				<CFPROCPARAM VALUE="#arguments.frmstruct["customDriverPayPercentage3_#stpID#"]#"  cfsqltype="CF_SQL_FLOAT">
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
		<cfreturn 1>
	</cffunction>
	<cffunction name="SetImportLoadAddressStopNo" access="public" returntype="any">
		<cfargument name="frmstruct" type="struct" required="yes">
		<cfargument name="lastInsertedStopId" type="string" required="yes">
		<cfargument name="stpID" type="string" required="yes">
		<cfquery name="qLoadStopIntermodalImportExists" datasource="#variables.dsn#">
			SELECT LoadStopID FROM LoadStopIntermodalImport
			WHERE LoadStopID = <cfqueryparam value="#arguments.lastInsertedStopId#" cfsqltype="cf_sql_varchar">
			AND StopNo = <cfqueryparam value="#arguments.stpID#" cfsqltype="cf_sql_integer">
		</cfquery>
		<cfif qLoadStopIntermodalImportExists.recordcount>
			<cfquery name="qUpdateLoadStopIntermodalImport" datasource="#variables.dsn#">
				update
					LoadStopIntermodalImport
				set dateDispatched = <cfqueryparam value="#EVALUATE('arguments.frmstruct.dateDispatched#arguments.stpID#')#" cfsqltype="cf_sql_date">,
					steamShipLine = <cfqueryparam value="#EVALUATE('arguments.frmstruct.steamShipLine#arguments.stpID#')#" cfsqltype="cf_sql_varchar">,
					eta = <cfqueryparam value="#EVALUATE('arguments.frmstruct.eta#arguments.stpID#')#" cfsqltype="cf_sql_date">,
					oceanBillofLading = <cfqueryparam value="#EVALUATE('arguments.frmstruct.oceanBillofLading#arguments.stpID#')#" cfsqltype="cf_sql_varchar">,
					actualArrivalDate = <cfqueryparam value="#EVALUATE('arguments.frmstruct.actualArrivalDate#arguments.stpID#')#" cfsqltype="cf_sql_date">,
					seal = <cfqueryparam value="#EVALUATE('arguments.frmstruct.seal#arguments.stpID#')#" cfsqltype="cf_sql_varchar">,
					customersReleaseDate = <cfqueryparam value="#EVALUATE('arguments.frmstruct.customersReleaseDate#arguments.stpID#')#" cfsqltype="cf_sql_date">,
					vesselName = <cfqueryparam value="#EVALUATE('arguments.frmstruct.vesselName#arguments.stpID#')#" cfsqltype="cf_sql_varchar">,
					freightReleaseDate = <cfqueryparam value="#EVALUATE('arguments.frmstruct.freightReleaseDate#arguments.stpID#')#" cfsqltype="cf_sql_date">,
					dateAvailable = <cfqueryparam value="#EVALUATE('arguments.frmstruct.dateAvailable#arguments.stpID#')#" cfsqltype="cf_sql_date">,
					demuggageFreeTimeExpirationDate = <cfqueryparam value="#EVALUATE('arguments.frmstruct.demuggageFreeTimeExpirationDate#arguments.stpID#')#" cfsqltype="cf_sql_date">,
					perDiemFreeTimeExpirationDate = <cfqueryparam value="#EVALUATE('arguments.frmstruct.perDiemFreeTimeExpirationDate#arguments.stpID#')#" cfsqltype="cf_sql_date">,
					pickupDate = <cfqueryparam value="#EVALUATE('arguments.frmstruct.pickupDate#arguments.stpID#')#" cfsqltype="cf_sql_date" null="#yesNoFormat(NOT len(EVALUATE('arguments.frmstruct.pickupDate#arguments.stpID#')))#">,
					requestedDeliveryDate = <cfqueryparam value="#EVALUATE('arguments.frmstruct.requestedDeliveryDate#arguments.stpID#')#" cfsqltype="cf_sql_date">,
					requestedDeliveryTime = <cfqueryparam value="#EVALUATE('arguments.frmstruct.requestedDeliveryTime#arguments.stpID#')#" cfsqltype="cf_sql_varchar">,
					scheduledDeliveryDate = <cfqueryparam value="#EVALUATE('arguments.frmstruct.scheduledDeliveryDate#arguments.stpID#')#" cfsqltype="cf_sql_date">,
					scheduledDeliveryTime = <cfqueryparam value="#EVALUATE('arguments.frmstruct.scheduledDeliveryTime#arguments.stpID#')#" cfsqltype="cf_sql_varchar">,
					unloadingDelayDetentionStartDate = <cfqueryparam value="#EVALUATE('arguments.frmstruct.unloadingDelayDetentionStartDate#arguments.stpID#')#" cfsqltype="cf_sql_date">,
					unloadingDelayDetentionStartTime = <cfqueryparam value="#EVALUATE('arguments.frmstruct.unloadingDelayDetentionStartTime#arguments.stpID#')#" cfsqltype="cf_sql_varchar">,
					actualDeliveryDate = <cfqueryparam value="#EVALUATE('arguments.frmstruct.actualDeliveryDate#arguments.stpID#')#" cfsqltype="cf_sql_date">,
					unloadingDelayDetentionEndDate = <cfqueryparam value="#EVALUATE('arguments.frmstruct.unloadingDelayDetentionEndDate#arguments.stpID#')#" cfsqltype="cf_sql_date">,
					unloadingDelayDetentionEndTime = <cfqueryparam value="#EVALUATE('arguments.frmstruct.unloadingDelayDetentionEndTime#arguments.stpID#')#" cfsqltype="cf_sql_varchar">,
					returnDate = <cfqueryparam value="#EVALUATE('arguments.frmstruct.returnDate#arguments.stpID#')#" cfsqltype="cf_sql_date">,
					pickUpAddress = <cfqueryparam value="#EVALUATE('arguments.frmstruct.pickUpAddress#arguments.stpID#')#" cfsqltype="cf_sql_varchar">,
					deliveryAddress = <cfqueryparam value="#EVALUATE('arguments.frmstruct.deliveryAddress#arguments.stpID#')#" cfsqltype="cf_sql_varchar">,
					emptyReturnAddress = <cfqueryparam value="#EVALUATE('arguments.frmstruct.emptyReturnAddress#arguments.stpID#')#" cfsqltype="cf_sql_varchar">
				WHERE
					LoadStopID = <cfqueryparam value="#arguments.lastInsertedStopId#" cfsqltype="cf_sql_varchar"> AND
					StopNo = <cfqueryparam value="#arguments.stpID#" cfsqltype="cf_sql_integer">
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
						<cfqueryparam value="#EVALUATE('arguments.frmstruct.requestedDeliveryTime#arguments.stpID#')#" cfsqltype="cf_sql_varchar">,
						<cfqueryparam value="#EVALUATE('arguments.frmstruct.scheduledDeliveryDate#arguments.stpID#')#" cfsqltype="cf_sql_date">,
						<cfqueryparam value="#EVALUATE('arguments.frmstruct.scheduledDeliveryTime#arguments.stpID#')#" cfsqltype="cf_sql_varchar">,
						<cfqueryparam value="#EVALUATE('arguments.frmstruct.unloadingDelayDetentionStartDate#arguments.stpID#')#" cfsqltype="cf_sql_date">,
						<cfqueryparam value="#EVALUATE('arguments.frmstruct.unloadingDelayDetentionStartTime#arguments.stpID#')#" cfsqltype="cf_sql_varchar">,
						<cfqueryparam value="#EVALUATE('arguments.frmstruct.actualDeliveryDate#arguments.stpID#')#" cfsqltype="cf_sql_date">,
						<cfqueryparam value="#EVALUATE('arguments.frmstruct.unloadingDelayDetentionEndDate#arguments.stpID#')#" cfsqltype="cf_sql_date">,
						<cfqueryparam value="#EVALUATE('arguments.frmstruct.unloadingDelayDetentionEndTime#arguments.stpID#')#" cfsqltype="cf_sql_varchar">,
						<cfqueryparam value="#EVALUATE('arguments.frmstruct.returnDate#arguments.stpID#')#" cfsqltype="cf_sql_date">,
						<cfqueryparam value="#EVALUATE('arguments.frmstruct.pickUpAddress#arguments.stpID#')#" cfsqltype="cf_sql_varchar">,
						<cfqueryparam value="#EVALUATE('arguments.frmstruct.deliveryAddress#arguments.stpID#')#" cfsqltype="cf_sql_varchar">,
						<cfqueryparam value="#EVALUATE('arguments.frmstruct.emptyReturnAddress#arguments.stpID#')#" cfsqltype="cf_sql_varchar">
					)
			</cfquery>
		</cfif>
		<cfinvoke component="#variables.objLoadgatewayUpdate#" method="getLoadStopAddress" tablename="LoadStopCargoPickupAddress" address="#EVALUATE('arguments.frmstruct.pickUpAddress#arguments.stpID#')#" returnvariable="qLoadStopCargoPickupAddressExists" />
		<cfif qLoadStopCargoPickupAddressExists.recordcount>
			<cfquery name="qUpdateCargoPickupAddress" datasource="#variables.dsn#">
				update
					LoadStopCargoPickupAddress
				set
					address =   <cfqueryparam value="#EVALUATE('arguments.frmstruct.pickUpAddress#arguments.stpID#')#" cfsqltype="cf_sql_varchar">,
					LoadStopID = <cfqueryparam value="#arguments.lastInsertedStopId#" cfsqltype="cf_sql_varchar">,
					dateModified = <cfqueryparam value="#now()#" cfsqltype="cf_sql_date">
				where ID = <cfqueryparam value="#qLoadStopCargoPickupAddressExists.ID#" cfsqltype="cf_sql_integer">
			</cfquery>
		<cfelse>
			<cfquery name="qInsertCargoPickupAddress" datasource="#variables.dsn#">
				insert into LoadStopCargoPickupAddress
					(address, LoadStopID, dateAdded, dateModified)
				values
					(
						<cfqueryparam value="#EVALUATE('arguments.frmstruct.pickUpAddress#arguments.stpID#')#" cfsqltype="cf_sql_varchar">,
						<cfqueryparam value="#arguments.lastInsertedStopId#" cfsqltype="cf_sql_varchar">,
						<cfqueryparam value="#now()#" cfsqltype="cf_sql_date">,
						<cfqueryparam value="#now()#" cfsqltype="cf_sql_date">
					)
			</cfquery>
		</cfif>
		<cfinvoke component="#variables.objLoadgatewayUpdate#" method="getLoadStopAddress" tablename="LoadStopCargoDeliveryAddress" address="#EVALUATE('arguments.frmstruct.deliveryAddress#arguments.stpID#')#" returnvariable="qLoadStopCargoDeliveryAddressExists" />
		<cfif qLoadStopCargoDeliveryAddressExists.recordcount>
			<cfquery name="qUpdateCargoDeliveryAddress" datasource="#variables.dsn#">
				update
					LoadStopCargoDeliveryAddress
				set
					address = <cfqueryparam value="#EVALUATE('arguments.frmstruct.deliveryAddress#arguments.stpID#')#" cfsqltype="cf_sql_varchar">,
					LoadStopID = <cfqueryparam value="#arguments.lastInsertedStopId#" cfsqltype="cf_sql_varchar">,
					dateModified = <cfqueryparam value="#now()#" cfsqltype="cf_sql_date">
				where ID = <cfqueryparam value="#qLoadStopCargoDeliveryAddressExists.ID#" cfsqltype="cf_sql_integer">
			</cfquery>
		<cfelse>
			<cfquery name="qInsertCargoDeliveryAddress" datasource="#variables.dsn#">
				insert into LoadStopCargoDeliveryAddress
					(address, LoadStopID, dateAdded, dateModified)
				values
					(
						<cfqueryparam value="#EVALUATE('arguments.frmstruct.deliveryAddress#arguments.stpID#')#" cfsqltype="cf_sql_varchar">,
						<cfqueryparam value="#arguments.lastInsertedStopId#" cfsqltype="cf_sql_varchar">,
						<cfqueryparam value="#now()#" cfsqltype="cf_sql_date">,
						<cfqueryparam value="#now()#" cfsqltype="cf_sql_date">
					)
			</cfquery>
		</cfif>
		<cfinvoke component="#variables.objLoadgatewayUpdate#" method="getLoadStopAddress" tablename="LoadStopEmptyReturnAddress" address="#EVALUATE('arguments.frmstruct.emptyReturnAddress#arguments.stpID#')#" returnvariable="qLoadStopEmptyReturnAddressExists" />
		<cfif qLoadStopEmptyReturnAddressExists.recordcount>
			<cfquery name="qUpdateEmptyReturnAddress" datasource="#variables.dsn#">
				update
					LoadStopEmptyReturnAddress
				set
					address = <cfqueryparam value="#EVALUATE('arguments.frmstruct.emptyReturnAddress#arguments.stpID#')#" cfsqltype="cf_sql_varchar">,
					LoadStopID = <cfqueryparam value="#arguments.lastInsertedStopId#" cfsqltype="cf_sql_varchar">,
					dateModified = <cfqueryparam value="#now()#" cfsqltype="cf_sql_date">
				where ID = <cfqueryparam value="#qLoadStopEmptyReturnAddressExists.ID#" cfsqltype="cf_sql_integer">
			</cfquery>
		<cfelse>
			<cfquery name="qInsertEmptyReturnAddress" datasource="#variables.dsn#">
				insert into LoadStopEmptyReturnAddress
					(address, LoadStopID, dateAdded, dateModified)
				values
					(
						<cfqueryparam value="#EVALUATE('arguments.frmstruct.emptyReturnAddress#arguments.stpID#')#" cfsqltype="cf_sql_varchar">,
						<cfqueryparam value="#arguments.lastInsertedStopId#" cfsqltype="cf_sql_varchar">,
						<cfqueryparam value="#now()#" cfsqltype="cf_sql_date">,
						<cfqueryparam value="#now()#" cfsqltype="cf_sql_date">
					)
			</cfquery>
		</cfif>
	</cffunction>

	<cffunction name="SetExportLoadAddressStopNo" access="public" returntype="any">
		<cfargument name="frmstruct" type="struct" required="yes">
		<cfargument name="lastInsertedStopId" type="string" required="yes">
		<cfargument name="stpID" type="string" required="yes">

		<cfquery name="qLoadStopIntermodalExportExists" datasource="#variables.dsn#">
			SELECT LoadStopID FROM LoadStopIntermodalExport
			WHERE LoadStopID = <cfqueryparam value="#arguments.lastInsertedStopId#" cfsqltype="cf_sql_varchar">
			AND StopNo = <cfqueryparam value="#arguments.stpID#" cfsqltype="cf_sql_integer">
		</cfquery>
		<cfif qLoadStopIntermodalExportExists.recordcount>
			<cfquery name="qUpdateLoadStopIntermodalExport" datasource="#variables.dsn#">
				update LoadStopIntermodalExport
				set dateDispatched = <cfqueryparam value="#EVALUATE('arguments.frmstruct.exportDateDispatched#arguments.stpID#')#" cfsqltype="cf_sql_date">,
					DateMtAvailableForPickup = <cfqueryparam value="#EVALUATE('arguments.frmstruct.exportDateMtAvailableForPickup#arguments.stpID#')#" cfsqltype="cf_sql_date">,
					steamShipLine = <cfqueryparam value="#EVALUATE('arguments.frmstruct.exportsteamShipLine#arguments.stpID#')#" cfsqltype="cf_sql_varchar">,
					DemurrageFreeTimeExpirationDate = <cfqueryparam value="#EVALUATE('arguments.frmstruct.exportDemurrageFreeTimeExpirationDate#arguments.stpID#')#" cfsqltype="cf_sql_date">,
					vesselName = <cfqueryparam value="#EVALUATE('arguments.frmstruct.exportvesselName#arguments.stpID#')#" cfsqltype="cf_sql_varchar">,
					PerDiemFreeTimeExpirationDate = <cfqueryparam value="#EVALUATE('arguments.frmstruct.exportPerDiemFreeTimeExpirationDate#arguments.stpID#')#" cfsqltype="cf_sql_date">,
					Voyage = <cfqueryparam value="#EVALUATE('arguments.frmstruct.exportVoyage#arguments.stpID#')#" cfsqltype="cf_sql_varchar">,
					EmptyPickupDate = <cfqueryparam value="#EVALUATE('arguments.frmstruct.exportEmptyPickupDate#arguments.stpID#')#" cfsqltype="cf_sql_date">,
					seal = <cfqueryparam value="#EVALUATE('arguments.frmstruct.exportseal#arguments.stpID#')#" cfsqltype="cf_sql_varchar">,
					Booking = <cfqueryparam value="#EVALUATE('arguments.frmstruct.exportBooking#arguments.stpID#')#" cfsqltype="cf_sql_varchar">,
					ScheduledLoadingDate = <cfqueryparam value="#EVALUATE('arguments.frmstruct.exportScheduledLoadingDate#arguments.stpID#')#" cfsqltype="cf_sql_date">,
					ScheduledLoadingTime = <cfqueryparam value="#EVALUATE('arguments.frmstruct.exportScheduledLoadingTime#arguments.stpID#')#" cfsqltype="cf_sql_varchar">,
					VesselCutoffDate = <cfqueryparam value="#EVALUATE('arguments.frmstruct.exportVesselCutoffDate#arguments.stpID#')#" cfsqltype="cf_sql_date">,
					LoadingDate = <cfqueryparam value="#EVALUATE('arguments.frmstruct.exportLoadingDate#arguments.stpID#')#" cfsqltype="cf_sql_date">,
					VesselLoadingWindow = <cfqueryparam value="#EVALUATE('arguments.frmstruct.exportVesselLoadingWindow#arguments.stpID#')#" cfsqltype="cf_sql_varchar">,
					LoadingDelayDetectionStartDate = <cfqueryparam value="#EVALUATE('arguments.frmstruct.exportLoadingDelayDetectionStartDate#arguments.stpID#')#" cfsqltype="cf_sql_date">,
					LoadingDelayDetectionStartTime = <cfqueryparam value="#EVALUATE('arguments.frmstruct.exportLoadingDelayDetectionStartTime#arguments.stpID#')#" cfsqltype="cf_sql_varchar">,
					RequestedLoadingDate = <cfqueryparam value="#EVALUATE('arguments.frmstruct.exportRequestedLoadingDate#arguments.stpID#')#" cfsqltype="cf_sql_date">,
					RequestedLoadingTime = <cfqueryparam value="#EVALUATE('arguments.frmstruct.exportRequestedLoadingTime#arguments.stpID#')#" cfsqltype="cf_sql_varchar">,
					LoadingDelayDetectionEndDate = <cfqueryparam value="#EVALUATE('arguments.frmstruct.exportLoadingDelayDetectionEndDate#arguments.stpID#')#" cfsqltype="cf_sql_date">,
					LoadingDelayDetectionEndTime = <cfqueryparam value="#EVALUATE('arguments.frmstruct.exportLoadingDelayDetectionEndTime#arguments.stpID#')#" cfsqltype="cf_sql_varchar">,
					ETS = <cfqueryparam value="#EVALUATE('arguments.frmstruct.exportETS#arguments.stpID#')#" cfsqltype="cf_sql_date">,
					ReturnDate = <cfqueryparam value="#EVALUATE('arguments.frmstruct.exportReturnDate#arguments.stpID#')#" cfsqltype="cf_sql_date">,
					emptyPickupAddress = <cfqueryparam value="#EVALUATE('arguments.frmstruct.exportEmptyPickupAddress#arguments.stpID#')#" cfsqltype="cf_sql_varchar">,
					loadingAddress = <cfqueryparam value="#EVALUATE('arguments.frmstruct.exportLoadingAddress#arguments.stpID#')#" cfsqltype="cf_sql_varchar">,
					returnAddress = <cfqueryparam value="#EVALUATE('arguments.frmstruct.exportReturnAddress#arguments.stpID#')#" cfsqltype="cf_sql_varchar">
				WHERE LoadStopID = <cfqueryparam value="#arguments.lastInsertedStopId#" cfsqltype="cf_sql_varchar"> AND
					StopNo = <cfqueryparam value="#arguments.stpID#" cfsqltype="cf_sql_integer">
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
						<cfqueryparam value="#arguments.lastInsertedStopId#" cfsqltype="cf_sql_varchar">,
						<cfqueryparam value="#arguments.stpID#" cfsqltype="cf_sql_integer">,
						<cfqueryparam value="#EVALUATE('arguments.frmstruct.exportDateDispatched#arguments.stpID#')#" cfsqltype="cf_sql_date">,
						<cfqueryparam value="#EVALUATE('arguments.frmstruct.exportDateMtAvailableForPickup#arguments.stpID#')#" cfsqltype="cf_sql_date">,
						<cfqueryparam value="#EVALUATE('arguments.frmstruct.exportsteamShipLine#arguments.stpID#')#" cfsqltype="cf_sql_varchar">,
						<cfqueryparam value="#EVALUATE('arguments.frmstruct.exportDemurrageFreeTimeExpirationDate#arguments.stpID#')#" cfsqltype="cf_sql_date">,
						<cfqueryparam value="#EVALUATE('arguments.frmstruct.exportvesselName#arguments.stpID#')#" cfsqltype="cf_sql_varchar">,
						<cfqueryparam value="#EVALUATE('arguments.frmstruct.exportPerDiemFreeTimeExpirationDate#arguments.stpID#')#" cfsqltype="cf_sql_date">,
						<cfqueryparam value="#EVALUATE('arguments.frmstruct.exportVoyage#arguments.stpID#')#" cfsqltype="cf_sql_varchar">,
						<cfqueryparam value="#EVALUATE('arguments.frmstruct.exportEmptyPickupDate#arguments.stpID#')#" cfsqltype="cf_sql_date" null="#yesNoFormat(NOT len(EVALUATE('arguments.frmstruct.exportEmptyPickupDate#arguments.stpID#')))#">,
						<cfqueryparam value="#EVALUATE('arguments.frmstruct.exportseal#arguments.stpID#')#" cfsqltype="cf_sql_varchar">,
						<cfqueryparam value="#EVALUATE('arguments.frmstruct.exportBooking#arguments.stpID#')#" cfsqltype="cf_sql_varchar">,
						<cfqueryparam value="#EVALUATE('arguments.frmstruct.exportScheduledLoadingDate#arguments.stpID#')#" cfsqltype="cf_sql_date">,
						<cfqueryparam value="#EVALUATE('arguments.frmstruct.exportScheduledLoadingTime#arguments.stpID#')#" cfsqltype="cf_sql_varchar">,
						<cfqueryparam value="#EVALUATE('arguments.frmstruct.exportVesselCutoffDate#arguments.stpID#')#" cfsqltype="cf_sql_date">,
						<cfqueryparam value="#EVALUATE('arguments.frmstruct.exportLoadingDate#arguments.stpID#')#" cfsqltype="cf_sql_date">,
						<cfqueryparam value="#EVALUATE('arguments.frmstruct.exportVesselLoadingWindow#arguments.stpID#')#" cfsqltype="cf_sql_varchar">,
						<cfqueryparam value="#EVALUATE('arguments.frmstruct.exportLoadingDelayDetectionStartDate#arguments.stpID#')#" cfsqltype="cf_sql_date">,
						<cfqueryparam value="#EVALUATE('arguments.frmstruct.exportLoadingDelayDetectionStartTime#arguments.stpID#')#" cfsqltype="cf_sql_varchar">,
						<cfqueryparam value="#EVALUATE('arguments.frmstruct.exportRequestedLoadingDate#arguments.stpID#')#" cfsqltype="cf_sql_date">,
						<cfqueryparam value="#EVALUATE('arguments.frmstruct.exportRequestedLoadingTime#arguments.stpID#')#" cfsqltype="cf_sql_varchar">,
						<cfqueryparam value="#EVALUATE('arguments.frmstruct.exportLoadingDelayDetectionEndDate#arguments.stpID#')#" cfsqltype="cf_sql_date">,
						<cfqueryparam value="#EVALUATE('arguments.frmstruct.exportLoadingDelayDetectionEndTime#arguments.stpID#')#" cfsqltype="cf_sql_varchar">,
						<cfqueryparam value="#EVALUATE('arguments.frmstruct.exportETS#arguments.stpID#')#" cfsqltype="cf_sql_date">,
						<cfqueryparam value="#EVALUATE('arguments.frmstruct.exportReturnDate#arguments.stpID#')#" cfsqltype="cf_sql_date">,
						<cfqueryparam value="#EVALUATE('arguments.frmstruct.exportEmptyPickupAddress#arguments.stpID#')#" cfsqltype="cf_sql_varchar">,
						<cfqueryparam value="#EVALUATE('arguments.frmstruct.exportLoadingAddress#arguments.stpID#')#" cfsqltype="cf_sql_varchar">,
						<cfqueryparam value="#EVALUATE('arguments.frmstruct.exportReturnAddress#arguments.stpID#')#" cfsqltype="cf_sql_varchar">)
			</cfquery>
		</cfif>
		<cfinvoke component="#variables.objLoadgatewayUpdate#" method="getLoadStopAddress" tablename="LoadStopEmptyPickupAddress" address="#EVALUATE('arguments.frmstruct.exportEmptyPickUpAddress#arguments.stpID#')#" returnvariable="qLoadStopEmptyPickupAddressExists" />
		<cfif qLoadStopEmptyPickupAddressExists.recordcount>
			<cfquery name="qUpdateEmptyPickupAddress" datasource="#variables.dsn#">
				update LoadStopEmptyPickupAddress
				set address = <cfqueryparam value="#EVALUATE('arguments.frmstruct.exportEmptyPickUpAddress#arguments.stpID#')#" cfsqltype="cf_sql_varchar">,
					LoadStopID = <cfqueryparam value="#arguments.lastInsertedStopId#" cfsqltype="cf_sql_varchar">,
					dateModified = <cfqueryparam value="#now()#" cfsqltype="cf_sql_date">
				where ID = <cfqueryparam value="#qLoadStopEmptyPickupAddressExists.ID#" cfsqltype="cf_sql_integer">
			</cfquery>
		<cfelse>
			<cfquery name="qInsertEmptyPickupAddress" datasource="#variables.dsn#">
				insert into LoadStopEmptyPickupAddress
					(address, LoadStopID, dateAdded, dateModified)
				values
					(
						<cfqueryparam value="#EVALUATE('arguments.frmstruct.exportEmptyPickUpAddress#arguments.stpID#')#" cfsqltype="cf_sql_varchar">,
						<cfqueryparam value="#arguments.lastInsertedStopId#" cfsqltype="cf_sql_varchar">,
						<cfqueryparam value="#now()#" cfsqltype="cf_sql_date">,
						<cfqueryparam value="#now()#" cfsqltype="cf_sql_date">
					)
			</cfquery>
		</cfif>
		<cfinvoke component="#variables.objLoadgatewayUpdate#" method="getLoadStopAddress" tablename="LoadStopLoadingAddress" address="#EVALUATE('arguments.frmstruct.exportLoadingAddress#arguments.stpID#')#" returnvariable="qLoadStopLoadingAddressExists" />
		<cfif qLoadStopLoadingAddressExists.recordcount>
			<cfquery name="qUpdateLoadingAddress" datasource="#variables.dsn#">
				update LoadStopLoadingAddress
				set address = <cfqueryparam value="#EVALUATE('arguments.frmstruct.exportLoadingAddress#arguments.stpID#')#" cfsqltype="cf_sql_varchar">,
					LoadStopID = <cfqueryparam value="#arguments.lastInsertedStopId#" cfsqltype="cf_sql_varchar">,
					dateModified = <cfqueryparam value="#now()#" cfsqltype="cf_sql_date">
				where ID = <cfqueryparam value="#qLoadStopLoadingAddressExists.ID#" cfsqltype="cf_sql_integer">
			</cfquery>
		<cfelse>
			<cfquery name="qInsertLoadingAddress" datasource="#variables.dsn#">
				insert into LoadStopLoadingAddress
					(address, LoadStopID, dateAdded, dateModified)
				values(<cfqueryparam value="#EVALUATE('arguments.frmstruct.exportLoadingAddress#arguments.stpID#')#" cfsqltype="cf_sql_varchar">,
						<cfqueryparam value="#arguments.lastInsertedStopId#" cfsqltype="cf_sql_varchar">,
						<cfqueryparam value="#now()#" cfsqltype="cf_sql_date">,
						<cfqueryparam value="#now()#" cfsqltype="cf_sql_date">)
			</cfquery>
		</cfif>
		<cfinvoke component="#variables.objLoadgatewayUpdate#" method="getLoadStopAddress" tablename="LoadStopReturnAddress" address="#EVALUATE('arguments.frmstruct.exportReturnAddress#arguments.stpID#')#" returnvariable="qLoadStopReturnAddressExists" />
		<cfif qLoadStopReturnAddressExists.recordcount>
			<cfquery name="qUpdateReturnAddress" datasource="#variables.dsn#">
				update
					LoadStopReturnAddress
				set
					address = <cfqueryparam value="#EVALUATE('arguments.frmstruct.exportReturnAddress#arguments.stpID#')#" cfsqltype="cf_sql_varchar">,
					LoadStopID = <cfqueryparam value="#arguments.lastInsertedStopId#" cfsqltype="cf_sql_varchar">,
					dateModified = <cfqueryparam value="#now()#" cfsqltype="cf_sql_date">
				where ID = <cfqueryparam value="#qLoadStopReturnAddressExists.ID#" cfsqltype="cf_sql_integer">
			</cfquery>
		<cfelse>
			<cfquery name="qInsertReturnAddress" datasource="#variables.dsn#">
				insert into LoadStopReturnAddress
					(address, LoadStopID, dateAdded, dateModified)
				values
					(
						<cfqueryparam value="#EVALUATE('arguments.frmstruct.exportReturnAddress#arguments.stpID#')#" cfsqltype="cf_sql_varchar">,
						<cfqueryparam value="#arguments.lastInsertedStopId#" cfsqltype="cf_sql_varchar">,
						<cfqueryparam value="#now()#" cfsqltype="cf_sql_date">,
						<cfqueryparam value="#now()#" cfsqltype="cf_sql_date">
					)
			</cfquery>
		</cfif>
	</cffunction>

	<cffunction name="SendLoadEmailUpdate" access="public" returntype="any">
		<cfargument name="LoadID" type="any" required="no"/>
		<cfargument name="NewStatus" type="any" required="no"/>
		<cftry>
			<cfquery name="qGetEmailUpdateLoadStatus" datasource="#variables.dsn#">
				SELECT StatusTypeID,StatusText FROM LoadStatusTypes WHERE CompanyID = <cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar"> AND SendEmailForLoads = 1
			</cfquery>

			<cfquery name="qGetUserAccount" datasource="#variables.dsn#">
				SELECT 
				S.UserAccountStatusUpdate
				,S.DefaultLoadEmailtext 
				,C.ccOnEmails
				,C.email AS CCMail
				,S.StatusUpdateMailType
				FROM SystemConfig S
				INNER JOIN Companies C ON C.CompanyID = S.CompanyID
				WHERE S.CompanyID = <cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar">
			</cfquery>

			<cfset var listStatus = valueList(qGetEmailUpdateLoadStatus.StatusTypeID)>
			<cfset var MailTo = ''>
			<cfif listFindNoCase(listStatus, arguments.NewStatus) AND (len(trim(qGetUserAccount.UserAccountStatusUpdate)) OR qGetUserAccount.StatusUpdateMailType EQ 1)>

				<cfinvoke  method="getcurAgentMaildetails" returnvariable="request.qcurAgentdetails" employeID="#trim(qGetUserAccount.UserAccountStatusUpdate)#" />
				<cfinvoke  method="getLoadStatusUpdateMailDetails" returnvariable="request.qGetLoadDetails" LoadID="#arguments.LoadID#"/>
				<!---Begin: MailTo --->
				<cfif len(trim(request.qGetLoadDetails.EmailList))>
					<cfset MailTo = trim(request.qGetLoadDetails.EmailList)>
				<cfelse>
					<cfif listFindNoCase(request.qGetSystemSetupOptions.DefaultLoadEmails, "Customer") AND len(trim(request.qGetLoadDetails.ContactEmail))>
						<cfset MailTo = listAppend(MailTo, request.qGetLoadDetails.ContactEmail,";")>
					</cfif>
					<cfif listFindNoCase(request.qGetSystemSetupOptions.DefaultLoadEmails, "Sales Rep") AND len(trim(request.qGetLoadDetails.SalesRepEmail))>
						<cfset MailTo = listAppend(MailTo, request.qGetLoadDetails.SalesRepEmail,";")>
					</cfif>
					<cfif listFindNoCase(request.qGetSystemSetupOptions.DefaultLoadEmails, "Dispatcher") AND len(trim(request.qGetLoadDetails.DispatcherEmail))>
						<cfset MailTo = listAppend(MailTo, request.qGetLoadDetails.DispatcherEmail,";")>
					</cfif>
					<cfif listFindNoCase(request.qGetSystemSetupOptions.DefaultLoadEmails, "Company") AND len(trim(qGetUserAccount.CCMail))>
						<cfset MailTo = listAppend(MailTo, qGetUserAccount.CCMail,";")>
					</cfif>
				</cfif>
				<cfset MailTo = ListRemoveDuplicates(MailTo)>
				<!---End: MailTo --->
				<cfif qGetUserAccount.StatusUpdateMailType EQ 0>
					<cfset MailFrom=request.qcurAgentdetails.EmailID>
				<cfelse>
					<cfset MailFrom='noreply@loadmanager.com'>
				</cfif>
				<cfset Subject = "#request.qGetSystemSetupOptions.DefaultLoadEmailSubject# - Load## #request.qGetLoadDetails.LoadNumber#">
				<!---Begin: Message --->
				<cfset Message = replace(request.qGetSystemSetupOptions.DefaultLoadEmailtext,chr(13)&chr(10),"<br />","all")>
				<cfset Message = replaceNoCase(Message, "Load## {LoadNumber}", "<b>Load## {LoadNumber}</b>")>
				<cfset Message = replaceNoCase(Message, "Status: {LoadStatus}", "<b><u>Status:</u></b> {LoadStatus}")>
				<cfset Message = replaceNoCase(Message, "PO##: {PONumber}", "<b><u>PO##:</u></b> {PONumber}")>
				<cfset Message = replaceNoCase(Message, "{EmailSignature}", replace(request.qcurAgentdetails.emailSignature,"Regards,","Regards,<br>"), "ALL")>
				<cfset Message = replaceNoCase(Message, "{LoadNumber}", request.qGetLoadDetails.LoadNumber)>
				<cfset Message = replaceNoCase(Message, "{PONumber}", request.qGetLoadDetails.CustomerPONo)>
				<cfset Message = replaceNoCase(Message, "{Map}", "<a href='#request.qGetLoadDetails.mapLink#' target='_blank'>VIEW LOCATION UPDATES</a>")>
				<cfset stopBody = "">
				<cfset stopNumber = 1>
				<cfloop query="request.qGetLoadDetails">
					<cfif len(trim(request.qGetLoadDetails.CustName)) OR len(trim(request.qGetLoadDetails.Address)) OR len(trim(request.qGetLoadDetails.City)) OR len(trim(request.qGetLoadDetails.StateCode)) OR len(trim(request.qGetLoadDetails.PostalCode))>
						<cfset AddressString = "">
						<cfset stopBody &= "<b>Stop #stopNumber#: </b>">
						<cfif len(trim(request.qGetLoadDetails.CustName))>
							<cfset stopBody &= trim(request.qGetLoadDetails.CustName) & "<br>">
						</cfif>
						<cfif len(trim(request.qGetLoadDetails.Address))>
							<cfset stopBody &= trim(request.qGetLoadDetails.Address) & "<br>">
						</cfif>
						<cfif len(trim(request.qGetLoadDetails.City))>
							<cfset AddressString &= trim(request.qGetLoadDetails.City) & ", ">
						</cfif>
						<cfif len(trim(request.qGetLoadDetails.StateCode))>
							<cfset AddressString &= trim(request.qGetLoadDetails.StateCode) & " ">
						</cfif>
						<cfif len(trim(request.qGetLoadDetails.PostalCode))>
							<cfset AddressString &= trim(request.qGetLoadDetails.PostalCode) & " ">
						</cfif>
						<cfif len(trim(AddressString))>
							<cfset stopBody &= trim(AddressString)>
						</cfif>
						<cfif len(trim(request.qGetLoadDetails.ContactPerson))>
							<cfset stopBody &= '<br>Contact: ' & trim(request.qGetLoadDetails.ContactPerson)>
						</cfif>
						<cfif len(trim(request.qGetLoadDetails.Phone))>
							<cfset stopBody &= '<br>Phone: ' & trim(request.qGetLoadDetails.Phone)>
						</cfif>
						<cfif request.qGetLoadDetails.Currentrow NEQ request.qGetLoadDetails.recordcount>
							<cfset stopBody &= "<br><br>">
						</cfif>
						<cfset stopNumber++>
					</cfif>
				</cfloop>
				<cfif stopNumber GT 2 AND len(trim(request.qGetLoadDetails.LoadStatusStopNo)) EQ 2>
					<cfset stopTypeNo = left(trim(request.qGetLoadDetails.LoadStatusStopNo),1)>
					<cfset stopTypeText = right(trim(request.qGetLoadDetails.LoadStatusStopNo),1)>
					<cfif stopTypeText EQ 'S'>
						<cfset stopTypeText = 'Pickup'>
					<cfelse>
						<cfset stopTypeText = 'Delivery'>
					</cfif>
					<cfset Message = replaceNoCase(Message, "{LoadStatus}", request.qGetLoadDetails.StatusDescription & " " & "Stop " & stopTypeNo & " " & stopTypeText)>
				<cfelse>
					<cfset Message = replaceNoCase(Message, "{LoadStatus}", request.qGetLoadDetails.StatusDescription)>
				</cfif>
				<cfset Message = replaceNoCase(Message, "{StopDetails}", stopBody)>
				<!---End: Message --->
				<cfif qGetUserAccount.StatusUpdateMailType EQ 0>
					<cfset SmtpAddress=request.qcurAgentdetails.SmtpAddress>
					<cfset SmtpUsername=request.qcurAgentdetails.SmtpUsername>
					<cfset SmtpPort=request.qcurAgentdetails.SmtpPort>
					<cfset SmtpPassword=request.qcurAgentdetails.SmtpPassword>
					<cfset FA_SSL=request.qcurAgentdetails.useSSL>
					<cfset FA_TLS=request.qcurAgentdetails.useTLS>
				<cfelse>
					<cfset SmtpAddress='smtp.office365.com'>
					<cfset SmtpUsername='noreply@loadmanager.com'>
					<cfset SmtpPort=587>
					<cfset SmtpPassword='Wsi2025!@##'>
					<cfset FA_SSL=0>
					<cfset FA_TLS=1>
				</cfif>
				<cfif qGetUserAccount.ccOnEmails EQ true and len(trim(qGetUserAccount.CCMail))>
					<cfmail from='"#SmtpUsername#" <#MailFrom#>' subject="#Subject#" to="#MailTo#" cc="#qGetUserAccount.CCMail#" type="text/html" server="#SmtpAddress#" username="#SmtpUsername#" password="#SmtpPassword#" port="#SmtpPort#" usessl="#FA_SSL#" usetls="#FA_TLS#" >
						#Message#
					</cfmail>
				<cfelse>
					<cfmail from='"#SmtpUsername#" <#MailFrom#>' subject="#Subject#" to="#MailTo#" type="text/html" server="#SmtpAddress#" username="#SmtpUsername#" password="#SmtpPassword#" port="#SmtpPort#" usessl="#FA_SSL#" usetls="#FA_TLS#" >
						#Message#
					</cfmail>
				</cfif>

				<cfinvoke method="setLogMails" LoadID="#arguments.LoadID#" date="#Now()#" subject="#Subject#" emailBody="#Message#" reportType="LocationUpdate" fromAddress="#SmtpUsername#" toAddress="#MailTo#" />

				<cfset var NewDispatchNotes = "#DateTimeFormat(now(),"mm/dd/yyyy h:nn: tt")# - #session.UserFullName# > Status update was emailed.">
				<cfquery name="qUpdateLoadDispatchNote" datasource="#variables.dsn#">
					UPDATE Loads
					SET
					EmailList = <cfqueryparam value="#MailTo#" cfsqltype="cf_sql_varchar">, 
					NewDispatchNotes = <cfqueryparam cfsqltype="cf_sql_varchar" value="#NewDispatchNotes#">+CHAR(13)+NewDispatchNotes
					WHERE LoadID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.LoadID#">
				</cfquery>
				<cfset session.LoadEmailUpdateMsg = 'Status update was emailed to #MailTo#'>
			</cfif>
			<cfcatch>
			</cfcatch>
		</cftry>
	</cffunction>

	<cffunction name="CarrierLoadStatusLaneSave" access="public" returntype="any">
		<cfargument name="LoadID" type="any" required="no"/>
		<cfargument name="OldStatus" type="any" required="no"/>
		<cftry>
			<CFSTOREDPROC PROCEDURE="SP_CarrierLoadStatusLaneSave" DATASOURCE="#variables.dsn#">
				<CFPROCPARAM VALUE="#arguments.LoadID#" cfsqltype="CF_SQL_VARCHAR">
				<CFPROCPARAM VALUE="#arguments.OldStatus#" cfsqltype="CF_SQL_VARCHAR">
				<CFPROCPARAM VALUE="#session.AdminUserName#" cfsqltype="CF_SQL_VARCHAR">
			</CFSTOREDPROC>
			<cfcatch>
			</cfcatch>
		</cftry>
	</cffunction>

	<cffunction name="getQBARLoads" access="public" returntype="query">
    	<cfargument name="frmStruct" required="no" type="struct">

    	<cfif structKeyExists(arguments.frmStruct, "pageNo")>
    		<cfset local.pageNo = arguments.frmStruct.pageNo>
    	<cfelse>
    		<cfset local.pageNo = 1>
    	</cfif>

    	<cfif structKeyExists(arguments.frmStruct, "sortby")>
    		<cfset local.sortby = arguments.frmStruct.sortby>
    	<cfelse>
    		<cfset local.sortby = "LoadNumber">
    	</cfif>

    	<cfif structKeyExists(arguments.frmStruct, "sortorder")>
    		<cfset local.sortorder = arguments.frmStruct.sortorder>
    	<cfelse>
    		<cfset local.sortorder = "ASC">
    	</cfif>
    	<cfinvoke method="getSystemSetupOptions" returnvariable="request.qSystemSetupOptions">
		<cfquery name="qGetQBARLoads" datasource="#variables.dsn#">
			BEGIN WITH page AS( 
				SELECT 
				L.LoadID
				,L.LoadNumber
				,Lst.StatusText
				,Lst.StatusDescription
				,L.BillDate
				,L.NewPickupDate
				,C.CustomerName
				,C.Email
				,L.TotalCustomerCharges
				,L.TotalCarrierCharges

				,ROW_NUMBER() OVER (ORDER BY #local.sortby# #local.sortorder#) AS Row
				FROM Loads L
				INNER JOIN Customers C ON C.CustomerID = L.CustomerID
				INNER JOIN CustomerOffices CO ON CO.CustomerID = C.CustomerID
				INNER JOIN Offices O ON O.OfficeID = CO.OfficeID
				INNER JOIN SystemConfig S ON S.CompanyID =  O.CompanyID 
				INNER JOIN LoadStatusTypes LST ON LST.StatusTypeID = L.StatusTypeID AND S.ARAndAPExportStatusID = L.StatusTypeID
				
				WHERE O.CompanyID = <cfqueryparam value="#session.companyID#" cfsqltype="cf_sql_varchar">
				AND L.ARExported  = 0
				<cfif Len(Trim(arguments.frmStruct.InvoiceDateFrom)) AND Len(Trim(arguments.frmStruct.InvoiceDateTo))>
					AND ISNULL(L.BillDate,L.NewPickupDate) BETWEEN <cfqueryparam value="#Trim(arguments.frmStruct.InvoiceDateFrom)#" cfsqltype="cf_sql_date">
						AND <cfqueryparam value="#Trim(arguments.frmStruct.InvoiceDateTO)#" cfsqltype="cf_sql_date">
				</cfif>
				GROUP BY 
				L.LoadID
				,L.LoadNumber
				,Lst.StatusText
				,Lst.StatusDescription
				,L.BillDate
				,L.NewPickupDate
				,C.CustomerName
				,C.Email
				,L.TotalCustomerCharges
				,L.TotalCarrierCharges
				)
				SELECT * FROM page
		    	WHERE Row BETWEEN (#local.pageNo# - 1) * #request.qSystemSetupOptions.RowsPerPage# + 1 AND #local.pageNo# * #request.qSystemSetupOptions.RowsPerPage#
	    	END
		</cfquery>
	    <cfreturn qGetQBARLoads>
	</cffunction>

	<cffunction name="getQBARCustomerCarrierTotals" access="public" returntype="query">
		<cfinvoke method="getSystemSetupOptions" returnvariable="request.qSystemSetupOptions">
		<cfquery name="qgetQBARCustomerCarrierTotals" datasource="#variables.dsn#">
			SELECT L1.LoadID,L1.TotalCustomerCharges,L1.TotalCarrierCharges FROM Loads L1 
			INNER JOIN CustomerOffices CO1 ON CO1.CustomerID = L1 .CustomerID
			INNER JOIN Offices O1 ON O1.OfficeID = CO1.OfficeID
			INNER JOIN SystemConfig S1 ON S1.CompanyID =  O1.CompanyID 
			INNER JOIN LoadStatusTypes LST1 ON LST1.StatusTypeID = L1.StatusTypeID AND S1.ARAndAPExportStatusID = L1.StatusTypeID
			WHERE O1.CompanyID = <cfqueryparam value="#session.companyID#" cfsqltype="cf_sql_varchar">
			AND L1.ARExported  = 0
			<cfif Len(Trim(arguments.frmStruct.InvoiceDateFrom)) AND Len(Trim(arguments.frmStruct.InvoiceDateTo))>
				AND ISNULL(L1.BillDate,L1.NewPickupDate) BETWEEN <cfqueryparam value="#Trim(arguments.frmStruct.InvoiceDateFrom)#" cfsqltype="cf_sql_date">
					AND <cfqueryparam value="#Trim(arguments.frmStruct.InvoiceDateTO)#" cfsqltype="cf_sql_date">
			</cfif>
		</cfquery>
		<cfreturn qgetQBARCustomerCarrierTotals>
	</cffunction>

	<cffunction name="QBExportAR" access="public" returntype="struct" returnformat="json">
    	<cfargument name="frmStruct" required="no" type="struct">
    	<cftry>
	    	<cfset var bitExportedAll = 1>
	    	<cfset var iifString = "">
	    	<cfset var csvString = "">
	    	<cfquery name="qGetQBSettings" datasource="#variables.dsn#">
	    		SELECT C.CompanyCode,C.CompanyName,S.QBDefInvItemName,S.QBDefInvPayTerm,S.QBVersion,S.showCarrierInvoiceNumber FROM Companies C
	    		INNER JOIN SystemConfig S ON C.CompanyID = S.CompanyID
				WHERE C.CompanyID = <cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar">
			</cfquery>
			<cfinvoke method="getSystemSetupOptions" returnvariable="request.qGetSystemSetupOptions" />
			<cfquery name="qGetQBARExportLoads" datasource="#variables.dsn#">
				SELECT 
					L.LoadID
					,L.LoadNumber
					,Lst.StatusText
					,Lst.StatusTypeID
					,L.BillDate
					,PickUp.StopDate AS PickUpDate
					,CASE WHEN ISNULL(C.RemitName,'') <> '' AND S.QBFactoringNameOnInvoice = 1 THEN C.RemitName ELSE C.CustomerName END AS CustomerName
					,L.TotalCustomerCharges
					,L.TotalCarrierCharges
					,PickUp.CustName AS PickUpName
					,PickUp.Address AS PickUpAddress
					,PickUp.City AS PickUpCity
					,PickUp.StateCode AS PickUpState
					,PickUp.PostalCode AS PickUpZip
					,Delivery.CustName AS DeliveryName
					,Delivery.Address AS DeliveryAddress
					,Delivery.City AS DeliveryCity
					,Delivery.StateCode AS DeliveryState
					,Delivery.PostalCode AS DeliveryZip
					,CASE WHEN ISNULL(C.RemitName,'') <> '' AND S.QBFactoringNameOnInvoice = 1 THEN C.RemitAddress ELSE C.Location END AS CustomerAddress
					,CASE WHEN ISNULL(C.RemitCity,'') <> '' AND S.QBFactoringNameOnInvoice = 1 THEN C.RemitCity ELSE C.City END AS CustomerCity
					,CASE WHEN ISNULL(C.RemitState,'') <> '' AND S.QBFactoringNameOnInvoice = 1 THEN C.RemitState ELSE C.StateCode END AS CustomerState
					,CASE WHEN ISNULL(C.RemitZipcode,'') <> '' AND S.QBFactoringNameOnInvoice = 1 THEN C.RemitZipcode ELSE C.ZipCode END AS CustomerZip
					,Delivery.StopDate AS DeliveryDate
					,L.CarrierName
					,L.CustomerPONo
					,C.phoneNo
			        ,C.personMobileNo
			        ,C.ContactPerson
			        ,C.Email
					FROM Loads L
					INNER JOIN Customers C ON C.CustomerID = L.CustomerID
					INNER JOIN CustomerOffices CO ON CO.CustomerID = C.CustomerID
					INNER JOIN Offices O ON O.OfficeID = CO.OfficeID
					INNER JOIN Companies CMP ON CMP.CompanyID = O.CompanyID
					INNER JOIN SystemConfig S ON S.CompanyID =  CMP.CompanyID 
					INNER JOIN LoadStatusTypes LST ON LST.StatusTypeID = L.StatusTypeID 
					<cfif NOT structKeyExists(arguments.frmStruct, "InvoiceLoads")>
						AND S.ARAndAPExportStatusID = L.StatusTypeID
					</cfif>
					INNER JOIN LoadStops PickUp ON PickUp.LoadID = L.LoadID AND PickUp.StopNo = 0 AND PickUp.LoadType = 1
					INNER JOIN LoadStops Delivery ON Delivery.LoadID = L.LoadID AND Delivery.StopNo = (SELECT MAX(LS.StopNo) FROM LoadStops LS WHERE LS.LoadID = L.LoadID) AND Delivery.LoadType = 2
					
					WHERE CMP.CompanyID = <cfqueryparam value="#session.companyID#" cfsqltype="cf_sql_varchar">
					AND L.ARExported  = 0
					<cfif Len(Trim(arguments.frmStruct.InvoiceDateFrom)) AND Len(Trim(arguments.frmStruct.InvoiceDateTo))>
						AND ISNULL(L.BillDate,PickUp.StopDate) BETWEEN <cfqueryparam value="#Trim(arguments.frmStruct.InvoiceDateFrom)#" cfsqltype="cf_sql_date">
							AND <cfqueryparam value="#Trim(arguments.frmStruct.InvoiceDateTO)#" cfsqltype="cf_sql_date">
					</cfif>
					<cfif structKeyExists(arguments.frmStruct, "InvoiceLoads")>
						AND L.LoadID IN (<cfqueryparam list="true" value="#arguments.frmStruct.InvoiceLoads#" null="#not len(arguments.frmstruct.IncludeLoads)#">)
					</cfif>
					<cfif structKeyExists(arguments.frmStruct, "ExcludeLoads") AND Len(Trim(arguments.frmStruct.ExcludeLoads))>
						AND L.LoadID NOT IN (<cfqueryparam list="true" value="#arguments.frmStruct.ExcludeLoads#">)
					</cfif>
					GROUP BY
					L.LoadID
					,L.LoadNumber
					,Lst.StatusText
					,Lst.StatusTypeID
					,L.BillDate
					,PickUp.StopDate
					,S.QBFactoringNameOnInvoice 
					,C.CustomerName
					,C.RemitName
					,L.TotalCustomerCharges
					,L.TotalCarrierCharges
					,PickUp.CustName
					,PickUp.Address
					,PickUp.City
					,PickUp.StateCode
					,PickUp.PostalCode
					,Delivery.CustName
					,Delivery.Address
					,Delivery.City
					,Delivery.StateCode
					,Delivery.PostalCode
					,C.Location
					,C.RemitAddress
					,C.City
					,C.RemitCity
					,C.StateCode
					,C.RemitState
					,C.ZipCode
					,C.RemitZipcode
					,Delivery.StopDate
					,L.CarrierName
					,L.CustomerPONo
					,C.phoneNo
			        ,C.personMobileNo
			        ,C.ContactPerson
			        ,C.Email
			</cfquery>

			<cfquery name="qGetExportSet" datasource="#variables.dsn#">
				SELECT convert(varchar,getdate(), 112) + replace(convert(varchar, getdate(), 114),':','') AS ID
			</cfquery>

			<cfif qGetQBSettings.QBVersion EQ 1>
		    	<cfscript> 
		    		fileName = 'QBInvoiceImport_#qGetQBSettings.CompanyCode#_#DateTimeFormat(now(),"YYYY_MM_dd_HH_nn_ss_l")#.iif';
					theDir=expandPath( "../temp/" );
					if(! DirectoryExists(theDir)){
						directoryCreate(expandPath("../temp/"));
					}
					theFile=theDir & fileName; 
				</cfscript> 

				<cfset iifString = "!TRNS#CHR(9)#TRNSID#CHR(9)#TRNSTYPE#CHR(9)#DATE#CHR(9)#ACCNT#CHR(9)#NAME#CHR(9)#AMOUNT#CHR(9)#DOCNUM#CHR(9)#MEMO#CHR(9)#CLEAR#CHR(9)#TOPRINT#CHR(9)#ADDR1#CHR(9)#ADDR2#CHR(9)#ADDR3#CHR(9)#ADDR4#CHR(9)#ADDR5#CHR(9)#DUEDATE#CHR(9)#PAID#CHR(9)#NAMEISTAXABLE#CHR(9)#PONUM#CHR(9)#TERMS#Chr(13)##chr(10)#">
				<cfset iifString = iifString & "!SPL#CHR(9)#EXTRA#CHR(9)#AMOUNT#CHR(9)#TAXABLE#CHR(9)#ACCNT#CHR(9)#INVITEM#CHR(9)#QNTY#CHR(9)#MEMO#CHR(9)##CHR(9)##CHR(9)##CHR(9)##CHR(9)##CHR(9)##CHR(9)##CHR(9)##CHR(9)##CHR(9)##CHR(9)##CHR(9)##CHR(9)##Chr(13)##chr(10)#">
				<cfset iifString = iifString & "!ENDTRNS#CHR(9)##CHR(9)##CHR(9)##CHR(9)##CHR(9)##CHR(9)##CHR(9)##CHR(9)##CHR(9)##CHR(9)##CHR(9)##CHR(9)##CHR(9)##CHR(9)##CHR(9)##CHR(9)##CHR(9)##CHR(9)##CHR(9)##CHR(9)#">

		    	<cfloop query="qGetQBARExportLoads">
					<cfif len(trim(qGetQBARExportLoads.BillDate))>
						<cfset var InvoiceDate = qGetQBARExportLoads.BillDate>
					<cfelse>
						<cfset var InvoiceDate = qGetQBARExportLoads.PickUpDate>
					</cfif>
					<cfif len(trim(InvoiceDate))>
						<cfset var memo= 'SHIPPER:\n#qGetQBARExportLoads.PickUpName#\n#qGetQBARExportLoads.PickUpAddress#\n#qGetQBARExportLoads.PickUpCity# #qGetQBARExportLoads.PickUpState# #qGetQBARExportLoads.PickUpZip#\n\nCONSIGNEE:\n#qGetQBARExportLoads.DeliveryName#\n#qGetQBARExportLoads.DeliveryAddress#\n#qGetQBARExportLoads.DeliveryCity# #qGetQBARExportLoads.DeliveryState# #qGetQBARExportLoads.DeliveryZip#'>
						<cfset var DueDate = ''>
						<cfif len(trim(qGetQBSettings.QBDefInvPayTerm))>
							<cfset var termNo = ''>
							<cfloop list="#qGetQBSettings.QBDefInvPayTerm#" delimiters=" " item="i">
								<cfif isNumeric(i)>
							        <cfset termNo = i>
							        <cfbreak>
							    </cfif>
							</cfloop>	
							<cfif len(trim(termNo)) and isnumeric(termNo)>
								<cfset DueDate = DateAdd('d',termNo,InvoiceDate)>
								<cfset DueDate = DateFormat(DueDate,'m/d/yyyy')>
							</cfif>
						</cfif>

						<cfset iifString = iifString & "#Chr(13)##chr(10)#">

						<cfset iifString = iifString & 'TRNS#CHR(9)##qGetQBARExportLoads.LoadNumber##CHR(9)#INVOICE#CHR(9)##DateFormat(InvoiceDate,'m/d/yyyy')##CHR(9)#Accounts Receivable#CHR(9)#"#qGetQBARExportLoads.CustomerName#"#CHR(9)##qGetQBARExportLoads.TotalCustomerCharges##CHR(9)##qGetQBARExportLoads.LoadNumber##CHR(9)##memo##CHR(9)#N#CHR(9)#N#CHR(9)#"#qGetQBARExportLoads.CustomerName#"#CHR(9)##qGetQBARExportLoads.CustomerAddress##CHR(9)#"#qGetQBARExportLoads.CustomerCity#, #qGetQBARExportLoads.CustomerState# #qGetQBARExportLoads.CustomerZip#"#CHR(9)##CHR(9)##CHR(9)##DueDate##CHR(9)#N#CHR(9)#N#CHR(9)##qGetQBARExportLoads.CustomerPONo##CHR(9)##qGetQBSettings.QBDefInvPayTerm##Chr(13)##chr(10)#'>

						<cfset iifString = iifString & "SPL#CHR(9)##CHR(9)#-#qGetQBARExportLoads.TotalCustomerCharges##CHR(9)##qGetQBARExportLoads.TotalCustomerCharges##CHR(9)##qGetQBSettings.QBDefInvItemName##CHR(9)#Line Haul#CHR(9)#-1#CHR(9)##memo##CHR(9)##CHR(9)##CHR(9)##CHR(9)##CHR(9)##CHR(9)##CHR(9)##CHR(9)##CHR(9)##CHR(9)##CHR(9)##CHR(9)##CHR(9)##Chr(13)##chr(10)#">

						<cfset iifString = iifString & "SPL#CHR(9)#AUTOSTAX#CHR(9)##CHR(9)##CHR(9)##CHR(9)##CHR(9)##CHR(9)##CHR(9)##CHR(9)##CHR(9)##CHR(9)##CHR(9)##CHR(9)##CHR(9)##CHR(9)##CHR(9)##CHR(9)##CHR(9)##CHR(9)##CHR(9)##Chr(13)##chr(10)#">

						<cfset iifString = iifString & "ENDTRNS#CHR(9)##CHR(9)##CHR(9)##CHR(9)##CHR(9)##CHR(9)##CHR(9)##CHR(9)##CHR(9)##CHR(9)##CHR(9)##CHR(9)##CHR(9)##CHR(9)##CHR(9)##CHR(9)##CHR(9)##CHR(9)##CHR(9)##CHR(9)#">

						<cfquery name="qUpdLoads" datasource="#variables.dsn#">
							UPDATE Loads SET ARExported  = 1
							,StatusTypeID = <cfqueryparam value="#arguments.frmstruct.InvoiceStatus#" cfsqltype="cf_sql_varchar">
							WHERE LoadID = <cfqueryparam value="#qGetQBARExportLoads.LoadID#" cfsqltype="cf_sql_varchar">
						</cfquery>
						<cfif arguments.frmstruct.InvoiceStatus NEQ qGetQBARExportLoads.StatusTypeID>
							<cfset SendLoadEmailUpdate(qGetQBARExportLoads.LoadID,arguments.frmstruct.InvoiceStatus)>
							<cfif structKeyExists(session, "LoadEmailUpdateMsg")>
								<cfset structDelete(session, "LoadEmailUpdateMsg")>
							</cfif>
						</cfif>
						<cfquery name="qInsQBExportedHistory" datasource="#variables.dsn#">
							INSERT INTO tblQBExportedHistory
								([CompanyName]
					           ,[MinOfPickupDate]
					           ,[MaxOfDeliveryDate]
					           ,[LoadNumber]
					           ,[FirstOfCarrierName]
					           ,[PayerName]
					           ,[Customer Amount]
					           ,[Carrier Amount]
					           ,[created]
					           ,[Type]
					           ,[id]
					           ,[CompanyID]
					           ,[CreatedBy]
					           ,[LoadID]
					           ,[ExportSetID])
							VALUES(
								<cfqueryparam value="#qGetQBSettings.CompanyName#" cfsqltype="cf_sql_varchar">
								<cfif len(trim(qGetQBARExportLoads.PickupDate))>
									,<cfqueryparam value="#qGetQBARExportLoads.PickupDate#" cfsqltype="cf_sql_date">
								<cfelse>
									,<cfqueryparam value="" cfsqltype="cf_sql_date" null="true">
								</cfif>
								<cfif len(trim(qGetQBARExportLoads.DeliveryDate))>
									,<cfqueryparam value="#qGetQBARExportLoads.DeliveryDate#" cfsqltype="cf_sql_date">
								<cfelse>
									,<cfqueryparam value="" cfsqltype="cf_sql_date" null="true">
								</cfif>
								,<cfqueryparam value="#qGetQBARExportLoads.LoadNumber#" cfsqltype="cf_sql_integer">
								,<cfqueryparam value="#qGetQBARExportLoads.CarrierName#" cfsqltype="cf_sql_varchar">
								,<cfqueryparam value="#qGetQBARExportLoads.CustomerName#" cfsqltype="cf_sql_varchar">
								,<cfqueryparam value="#qGetQBARExportLoads.TotalCustomerCharges#" cfsqltype="cf_sql_float">
								,<cfqueryparam value="#qGetQBARExportLoads.TotalCarrierCharges#" cfsqltype="cf_sql_float">
								,getdate()
								,'Invoice'
								,(SELECT ISNULL(MAX(id),0)+1 FROM tblQBExportedHistory)
								,<cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar">
								,<cfqueryparam value="#session.adminUserName#" cfsqltype="cf_sql_varchar">
								,<cfqueryparam value="#qGetQBARExportLoads.LoadID#" cfsqltype="cf_sql_varchar">
								,<cfqueryparam value="#qGetExportSet.ID#" cfsqltype="cf_sql_varchar">
							)
						</cfquery>
					</cfif>
				</cfloop>
				<cffile action="write" output="#iifString#" file="#theFile#" addNewLine="no">
			<cfelse>
				<cfscript> 
		    		fileName = 'QBInvoiceImport_#qGetQBSettings.CompanyCode#_#DateTimeFormat(now(),"YYYY_MM_dd_HH_nn_ss_l")#.csv';
					theDir=expandPath( "../temp/" );
					if(! DirectoryExists(theDir)){
						directoryCreate(expandPath("../temp/"));
					}
					theFile=theDir & fileName; 
				</cfscript> 
				<cfset var csvString = "RefNumber,Customer,PayorPhone,PayerMobileNo,PayerContact,TxnDate,DueDate,ShipDate,ShipMethodName,ShipMethodId,SalesTerm,BillAddrLine1,BillAddrLineCity,BillAddrLineState,BillAddrLinePostalCode,BillEmail,ToBePrinted,ToBeEmailed,LineItem,LineQty,LineDesc,LineUnitPrice,LineTaxable,LineAmount,ARExported">
				
				<cfloop query="qGetQBARExportLoads">
					<cfif not len(trim(qGetQBARExportLoads.EMail))>
						<cfset respStr = structNew()>
				    	<cfset respStr.res = 'error'>
				    	<cfset respStr.msg = "You cannot export Invoices for customer #qGetQBARExportLoads.CustomerName# because their email address is not setup. Please correct this and try again. ">
				    	<cfreturn respStr>
			    	</cfif>
				</cfloop>

			
				<cfloop query="qGetQBARExportLoads">
					<cfif len(trim(qGetQBARExportLoads.BillDate))>
						<cfset var InvoiceDate = qGetQBARExportLoads.BillDate>
					<cfelse>
						<cfset var InvoiceDate = qGetQBARExportLoads.PickUpDate>
					</cfif>
					<cfif len(trim(InvoiceDate))>
						<cfset var DueDate = ''>
						<cfif len(trim(qGetQBSettings.QBDefInvPayTerm))>
							<cfset var termNo = ''>
							<cfloop list="#qGetQBSettings.QBDefInvPayTerm#" delimiters=" " item="i">
								<cfif isNumeric(i)>
							        <cfset termNo = i>
							        <cfbreak>
							    </cfif>
							</cfloop>	
							<cfif len(trim(termNo)) and isnumeric(termNo)>
								<cfset DueDate = DateAdd('d',termNo,InvoiceDate)>
								<cfset DueDate = DateFormat(DueDate,'mm/dd/yyyy')>
							</cfif>
						</cfif>
						<cfset csvString = csvString & "#Chr(13)##chr(10)#">
						<cfset csvString = csvString & '#qGetQBARExportLoads.LoadNumber#,"#qGetQBARExportLoads.CustomerName#",#qGetQBARExportLoads.phoneNo#,#qGetQBARExportLoads.phoneNo#,#qGetQBARExportLoads.ContactPerson#,#DateFormat(InvoiceDate,"mm/dd/yyyy")#,#DueDate#,#DateFormat(InvoiceDate,"mm/dd/yyyy")#,,,#qGetQBSettings.QBDefInvPayTerm#,"#qGetQBARExportLoads.CustomerAddress#",#qGetQBARExportLoads.CustomerCity#,#qGetQBARExportLoads.CustomerState#,#tostring(qGetQBARExportLoads.CustomerZip)#,#qGetQBARExportLoads.Email#,Y,Y,LoadTotal,1,Load Charges including Flat Rate and Accessorials,#qGetQBARExportLoads.TotalCustomerCharges#,N,#qGetQBARExportLoads.TotalCustomerCharges#,0'>

						<cfquery name="qUpdLoads" datasource="#variables.dsn#">
							UPDATE Loads SET ARExported  = 1
							,StatusTypeID = <cfqueryparam value="#arguments.frmstruct.InvoiceStatus#" cfsqltype="cf_sql_varchar">
							WHERE LoadID = <cfqueryparam value="#qGetQBARExportLoads.LoadID#" cfsqltype="cf_sql_varchar">
						</cfquery>
						<cfif arguments.frmstruct.InvoiceStatus NEQ qGetQBARExportLoads.StatusTypeID>
							<cfset SendLoadEmailUpdate(qGetQBARExportLoads.LoadID,arguments.frmstruct.InvoiceStatus)>
							<cfif structKeyExists(session, "LoadEmailUpdateMsg")>
								<cfset structDelete(session, "LoadEmailUpdateMsg")>
							</cfif>
						</cfif>
						<cfquery name="qInsQBExportedHistory" datasource="#variables.dsn#">
							INSERT INTO tblQBExportedHistory
								([CompanyName]
					           ,[MinOfPickupDate]
					           ,[MaxOfDeliveryDate]
					           ,[LoadNumber]
					           ,[FirstOfCarrierName]
					           ,[PayerName]
					           ,[Customer Amount]
					           ,[Carrier Amount]
					           ,[created]
					           ,[Type]
					           ,[id]
					           ,[CompanyID]
					           ,[CreatedBy]
					           ,[LoadID]
					           ,[ExportSetID])
							VALUES(
								<cfqueryparam value="#qGetQBSettings.CompanyName#" cfsqltype="cf_sql_varchar">
								<cfif len(trim(qGetQBARExportLoads.PickupDate))>
									,<cfqueryparam value="#qGetQBARExportLoads.PickupDate#" cfsqltype="cf_sql_date">
								<cfelse>
									,<cfqueryparam value="" cfsqltype="cf_sql_date" null="true">
								</cfif>
								<cfif len(trim(qGetQBARExportLoads.DeliveryDate))>
									,<cfqueryparam value="#qGetQBARExportLoads.DeliveryDate#" cfsqltype="cf_sql_date">
								<cfelse>
									,<cfqueryparam value="" cfsqltype="cf_sql_date" null="true">
								</cfif>
								,<cfqueryparam value="#qGetQBARExportLoads.LoadNumber#" cfsqltype="cf_sql_integer">
								,<cfqueryparam value="#qGetQBARExportLoads.CarrierName#" cfsqltype="cf_sql_varchar">
								,<cfqueryparam value="#qGetQBARExportLoads.CustomerName#" cfsqltype="cf_sql_varchar">
								,<cfqueryparam value="#qGetQBARExportLoads.TotalCustomerCharges#" cfsqltype="cf_sql_float">
								,<cfqueryparam value="#qGetQBARExportLoads.TotalCarrierCharges#" cfsqltype="cf_sql_float">
								,getdate()
								,'Invoice'
								,(SELECT ISNULL(MAX(id),0)+1 FROM tblQBExportedHistory)
								,<cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar">
								,<cfqueryparam value="#session.adminUserName#" cfsqltype="cf_sql_varchar">
								,<cfqueryparam value="#qGetQBARExportLoads.LoadID#" cfsqltype="cf_sql_varchar">
								,<cfqueryparam value="#qGetExportSet.ID#" cfsqltype="cf_sql_varchar">
							)
						</cfquery>
					</cfif>
				</cfloop>
				<cffile action="write" output="#csvString#" file="#theFile#" addNewLine="no">
			</cfif>
			<cfset respStr = structNew()>
	    	<cfset respStr.res = 'success'>
	    	<cfset respStr.msg = "Exported successfully.">
	    	<cfset respStr.fileName = "#fileName#">
	    	<cfreturn respStr>

			<cfcatch>
				<cfset respStr = structNew()>
		    	<cfset respStr.res = 'error'>
		    	<cfset respStr.msg = "Something went wrong. Unable to export.">
		    	<cfreturn respStr>
			</cfcatch>
		</cftry>
    </cffunction>

    <cffunction name="getQBAPLoads" access="public" returntype="query">
    	<cfargument name="frmStruct" required="no" type="struct">

    	<cfif structKeyExists(arguments.frmStruct, "pageNo")>
    		<cfset local.pageNo = arguments.frmStruct.pageNo>
    	<cfelse>
    		<cfset local.pageNo = 1>
    	</cfif>

    	<cfif structKeyExists(arguments.frmStruct, "sortby")>
    		<cfset local.sortby = arguments.frmStruct.sortby>
    	<cfelse>
    		<cfset local.sortby = "LoadNumber">
    	</cfif>

    	<cfif structKeyExists(arguments.frmStruct, "sortorder")>
    		<cfset local.sortorder = arguments.frmStruct.sortorder>
    	<cfelse>
    		<cfset local.sortorder = "ASC">
    	</cfif>
    	<cfinvoke method="getSystemSetupOptions" returnvariable="request.qSystemSetupOptions">
		<cfquery name="qgetQBAPLoads" datasource="#variables.dsn#">
			BEGIN WITH page AS( 
				SELECT 
				L.LoadID
				,L.LoadNumber
				,Lst.StatusText
				,Lst.StatusDescription
				,L.BillDate
				,L.NewPickupDate
				,Carr.CarrierName
				,L.TotalCustomerCharges
				,L.TotalCarrierCharges
				,ROW_NUMBER() OVER (ORDER BY #local.sortby# #local.sortorder#) AS Row
				FROM Loads L
				INNER JOIN Customers C ON C.CustomerID = L.CustomerID
				INNER JOIN Carriers Carr ON Carr.CarrierID = L.CarrierID
				INNER JOIN CustomerOffices CO ON CO.CustomerID = C.CustomerID
				INNER JOIN Offices O ON O.OfficeID = CO.OfficeID
				INNER JOIN SystemConfig S ON S.CompanyID =  O.CompanyID 
				INNER JOIN LoadStatusTypes LST ON LST.StatusTypeID = L.StatusTypeID AND S.APExportStatusID = L.StatusTypeID
				WHERE O.CompanyID = <cfqueryparam value="#session.companyID#" cfsqltype="cf_sql_varchar">
				AND L.APExported  = 0
				<cfif request.qSystemSetupOptions.showCarrierInvoiceNumber EQ 1>
					AND ISNULL(L.CarrierInvoiceNumber,0)<>0
				</cfif>
				<cfif Len(Trim(arguments.frmStruct.InvoiceDateFrom)) AND Len(Trim(arguments.frmStruct.InvoiceDateTo))>
					AND ISNULL(L.BillDate,L.NewPickupDate) BETWEEN <cfqueryparam value="#Trim(arguments.frmStruct.InvoiceDateFrom)#" cfsqltype="cf_sql_date">
						AND <cfqueryparam value="#Trim(arguments.frmStruct.InvoiceDateTO)#" cfsqltype="cf_sql_date">
				</cfif>
				GROUP BY
				L.LoadID
				,L.LoadNumber
				,Lst.StatusText
				,Lst.StatusDescription
				,L.BillDate
				,L.NewPickupDate
				,Carr.CarrierName
				,L.TotalCustomerCharges
				,L.TotalCarrierCharges
				)
				SELECT * FROM page
		    	WHERE Row BETWEEN (#local.pageNo# - 1) * #request.qSystemSetupOptions.RowsPerPage# + 1 AND #local.pageNo# * #request.qSystemSetupOptions.RowsPerPage#
	    	END
		</cfquery>
	    <cfreturn qgetQBAPLoads>
	</cffunction>

	<cffunction name="getQBAPCustomerCarrierTotals" access="public" returntype="query">
		<cfinvoke method="getSystemSetupOptions" returnvariable="request.qSystemSetupOptions">
		<cfquery name="qgetQBAPCustomerCarrierTotals" datasource="#variables.dsn#">
			SELECT L1.LoadID,L1.TotalCustomerCharges,L1.TotalCarrierCharges FROM Loads L1 
			INNER JOIN CustomerOffices CO1 ON CO1.CustomerID = L1 .CustomerID
			INNER JOIN Offices O1 ON O1.OfficeID = CO1.OfficeID
			INNER JOIN SystemConfig S1 ON S1.CompanyID =  O1.CompanyID 
			INNER JOIN LoadStatusTypes LST1 ON LST1.StatusTypeID = L1.StatusTypeID AND S1.APExportStatusID = L1.StatusTypeID
			WHERE O1.CompanyID = <cfqueryparam value="#session.companyID#" cfsqltype="cf_sql_varchar">
			AND L1.APExported  = 0
			<cfif request.qSystemSetupOptions.showCarrierInvoiceNumber EQ 1>
				AND ISNULL(L1.CarrierInvoiceNumber,0)<>0
			</cfif>
			<cfif Len(Trim(arguments.frmStruct.InvoiceDateFrom)) AND Len(Trim(arguments.frmStruct.InvoiceDateTo))>
				AND ISNULL(L1.BillDate,L1.NewPickupDate) BETWEEN <cfqueryparam value="#Trim(arguments.frmStruct.InvoiceDateFrom)#" cfsqltype="cf_sql_date">
					AND <cfqueryparam value="#Trim(arguments.frmStruct.InvoiceDateTO)#" cfsqltype="cf_sql_date">
			</cfif>
		</cfquery>
		<cfreturn qgetQBAPCustomerCarrierTotals>
	</cffunction>

	<cffunction name="QBExportAP" access="public" returntype="struct" returnformat="json">
    	<cfargument name="frmStruct" required="no" type="struct">
    	<cftry>
	    	<cfset var bitExportedAll = 1>
	    	<cfset var iifString = "">
	    	<cfset var csvString = "">
	    	<cfinvoke method="getSystemSetupOptions" returnvariable="request.qGetSystemSetupOptions" />
	    	<cfquery name="qGetQBSettings" datasource="#variables.dsn#">
	    		SELECT C.CompanyCode,C.CompanyName,S.QBDefBillAccountName,S.QBDefBillPayTerm,S.QBVersion,S.showCarrierInvoiceNumber,S.QBCarrierInvoiceASRef,S.QBFactoringNameOnBill FROM Companies C
	    		INNER JOIN SystemConfig S ON C.CompanyID = S.CompanyID
				WHERE C.CompanyID = <cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar">
			</cfquery>
			<cfquery name="qGetQBAPExportLoads" datasource="#variables.dsn#">
				SELECT 
				L.LoadID
				,L.LoadNumber
				,LS.NewCarrierID
				,Lst.StatusText
				,Lst.StatusTypeID
				,L.BillDate
				,PickUp.StopDate AS PickUpDate
				,C.CustomerName
				,L.TotalCustomerCharges
				,CASE WHEN L.CarrierID = LS.NewCarrierID THEN L.CarrFlatRate + L.carrierMilesCharges + SUM(LSC.CarrCharges) ELSE SUM(LSC.CarrCharges) END AS TotalCarrierCharges
				,PickUp.CustName AS PickUpName
				,PickUp.Address AS PickUpAddress
				,PickUp.City AS PickUpCity
				,PickUp.StateCode AS PickUpState
				,PickUp.PostalCode AS PickUpZip
				,Delivery.CustName AS DeliveryName
				,Delivery.Address AS DeliveryAddress
				,Delivery.City AS DeliveryCity
				,Delivery.StateCode AS DeliveryState
				,Delivery.PostalCode AS DeliveryZip

				<cfif qGetQBSettings.QBVersion EQ 1 AND qGetQBSettings.QBFactoringNameOnBill EQ 1>
					,CASE WHEN ISNULL(Carr.RemitName,'') = '' THEN Carr.CarrierName ELSE Carr.RemitName END AS CarrierName
					,CASE WHEN ISNULL(Carr.RemitAddress,'') = '' THEN Carr.Address ELSE Carr.RemitAddress END AS CarrierAddress
					,CASE WHEN ISNULL(Carr.RemitCity,'') = '' THEN Carr.City ELSE Carr.RemitCity END AS CarrierCity
					,CASE WHEN ISNULL(Carr.RemitState,'') = '' THEN Carr.StateCode ELSE Carr.RemitState END AS CarrierState
					,CASE WHEN ISNULL(Carr.RemitZipcode,'') = '' THEN Carr.ZipCode ELSE Carr.RemitZipcode END AS CarrierZip
				<cfelse>
					,Carr.CarrierName
					,Carr.Address AS CarrierAddress
					,Carr.City AS CarrierCity
					,Carr.StateCode AS CarrierState
					,Carr.ZipCode AS CarrierZip
				</cfif>
				,Delivery.StopDate AS DeliveryDate
				,Carr.RemitName,Carr.RemitCity,Carr.RemitAddress,Carr.RemitZipcode,Carr.RemitContact,Carr.RemitState
				,<cfif qGetQBSettings.QBCarrierInvoiceASRef EQ 1>
					L.CarrierInvoiceNumber
				<cfelse>
					L.LoadNumber 
				</cfif> AS CarrierInvoiceNumber
				FROM Loads L
				INNER JOIN Customers C ON C.CustomerID = L.CustomerID
				LEFT JOIN LoadStops LS ON LS.LoadID = L.LoadID
				LEFT JOIN LoadStopCommodities LSC ON LSC.LoadStopID = LS.LoadStopID
				LEFT JOIN Carriers Carr ON Carr.CarrierID = LS.NewCarrierID 
				INNER JOIN CustomerOffices CO ON CO.CustomerID = C.CustomerID
				INNER JOIN Offices O ON O.OfficeID = CO.OfficeID
				INNER JOIN Companies CMP ON CMP.CompanyID = O.CompanyID
				INNER JOIN SystemConfig S ON S.CompanyID =  CMP.CompanyID 
				INNER JOIN LoadStatusTypes LST ON LST.StatusTypeID = L.StatusTypeID
				<cfif NOT structKeyExists(arguments.frmStruct, "BillsLoads")>
					AND S.APExportStatusID = L.StatusTypeID
				</cfif>
				INNER JOIN LoadStops PickUp ON PickUp.LoadID = L.LoadID AND PickUp.StopNo = 0 AND PickUp.LoadType = 1
				INNER JOIN LoadStops Delivery ON Delivery.LoadID = L.LoadID AND Delivery.StopNo = (SELECT MAX(LS.StopNo) FROM LoadStops LS WHERE LS.LoadID = L.LoadID) AND Delivery.LoadType = 2
				
				WHERE CMP.CompanyID = <cfqueryparam value="#session.companyID#" cfsqltype="cf_sql_varchar">
				AND L.APExported  = 0
				<cfif qGetQBSettings.showCarrierInvoiceNumber EQ 1>
					AND ISNULL(L.CarrierInvoiceNumber,0)<>0
				</cfif>
				<cfif Len(Trim(arguments.frmStruct.InvoiceDateFrom)) AND Len(Trim(arguments.frmStruct.InvoiceDateTo))>
					AND ISNULL(L.BillDate,PickUp.StopDate) BETWEEN <cfqueryparam value="#Trim(arguments.frmStruct.InvoiceDateFrom)#" cfsqltype="cf_sql_date">
						AND <cfqueryparam value="#Trim(arguments.frmStruct.InvoiceDateTO)#" cfsqltype="cf_sql_date">
				</cfif>
				<cfif structKeyExists(arguments.frmStruct, "BillsLoads")>
					AND L.LoadID IN (<cfqueryparam list="true" value="#arguments.frmStruct.BillsLoads#" null="#not len(arguments.frmstruct.BillsLoads)#">)
				</cfif>
				<cfif structKeyExists(arguments.frmStruct, "ExcludeLoads") AND Len(Trim(arguments.frmStruct.ExcludeLoads))>
					AND L.LoadID NOT IN (<cfqueryparam list="true" value="#arguments.frmStruct.ExcludeLoads#">)
				</cfif>
				GROUP BY
				L.LoadID
				,L.LoadNumber
				,Lst.StatusText
				,Lst.StatusTypeID
				,L.BillDate
				,PickUp.StopDate
				,C.CustomerName
				,L.TotalCustomerCharges
				,L.CarrierID
				,LS.NewCarrierID
				,L.CarrFlatRate
				,L.carrierMilesCharges
				,PickUp.CustName
				,PickUp.Address
				,PickUp.City
				,PickUp.StateCode
				,PickUp.PostalCode
				,Delivery.CustName
				,Delivery.Address
				,Delivery.City
				,Delivery.StateCode
				,Delivery.PostalCode
				,Carr.Address
				,Carr.City
				,Carr.StateCode
				,Carr.ZipCode
				,Delivery.StopDate
				,Carr.CarrierName
				,Carr.RemitName,Carr.RemitCity,Carr.RemitAddress,Carr.RemitZipcode,Carr.RemitContact,Carr.RemitState
				,L.CarrierInvoiceNumber
				,S.QBFactoringNameOnBill
				ORDER BY L.LoadNumber,CarrierName
			</cfquery>
			<cfquery name="qGetExportSet" datasource="#variables.dsn#">
				SELECT convert(varchar,getdate(), 112) + replace(convert(varchar, getdate(), 114),':','') AS ID
			</cfquery>
			<cfif qGetQBSettings.QBVersion EQ 1>
		    	<cfscript> 
		    		fileName = 'QBBillImport_#qGetQBSettings.CompanyCode#_#DateTimeFormat(now(),"YYYY_MM_dd_HH_nn_ss_l")#.iif';
					theDir=expandPath( "../temp/" );
					if(! DirectoryExists(theDir)){
						directoryCreate(expandPath("../temp/"));
					}
					theFile=theDir & fileName; 
					theSheet = SpreadsheetNew("QBBillImport");
				</cfscript> 

				<cfset iifString = "!TRNS#CHR(9)#TRNSID#CHR(9)#TRNSTYPE#CHR(9)#DATE#CHR(9)#ACCNT#CHR(9)#NAME#CHR(9)#AMOUNT#CHR(9)#DOCNUM#CHR(9)#MEMO#CHR(9)#CLEAR#CHR(9)#TOPRINT#CHR(9)#ADDR1#CHR(9)#ADDR2#CHR(9)#ADDR3#CHR(9)#ADDR4#CHR(9)#ADDR5#CHR(9)#DUEDATE#CHR(9)#TERMS#CHR(13)##CHR(10)#">

				<cfset iifString = iifString & "!SPL#CHR(9)#SPLID#CHR(9)#TRNTYPE#CHR(9)#DATE#CHR(9)#ACCNT#CHR(9)#CLEAR#CHR(9)#AMOUNT#CHR(9)#REIMBEXP#CHR(9)#MEMO#CHR(9)#QNTY#CHR(9)#INVITEM#CHR(9)##CHR(9)##CHR(9)##CHR(9)##CHR(9)##CHR(9)##CHR(9)##CHR(13)##CHR(10)#">

				<cfset iifString = iifString & "!ENDTRNS#CHR(9)##CHR(9)##CHR(9)##CHR(9)##CHR(9)##CHR(9)##CHR(9)##CHR(9)##CHR(9)##CHR(9)##CHR(9)##CHR(9)##CHR(9)##CHR(9)##CHR(9)##CHR(9)##CHR(9)#">

		    	<cfloop query="qGetQBAPExportLoads" group="LoadNumber">
		    		<cfloop group="CarrierName">
		    		<cfset local.TotalCarrierCharges = 0>
		    		<cfloop group="NewCarrierID">
		    			<cfset local.TotalCarrierCharges = local.TotalCarrierCharges + qGetQBAPExportLoads.TotalCarrierCharges>
		    		</cfloop>
					<cfif len(trim(qGetQBAPExportLoads.BillDate))>
						<cfset var InvoiceDate = qGetQBAPExportLoads.BillDate>
					<cfelse>
						<cfset var InvoiceDate = qGetQBAPExportLoads.PickUpDate>
					</cfif>
					<cfif len(trim(InvoiceDate))>
						<cfset var DueDate = ''>
						<cfif len(trim(qGetQBSettings.QBDefBillPayTerm))>
							<cfset var termNo = ''>
							<cfloop list="#qGetQBSettings.QBDefBillPayTerm#" delimiters=" " item="i">
								<cfif isNumeric(i)>
							        <cfset termNo = i>
							        <cfbreak>
							    </cfif>
							</cfloop>	
							<cfif len(trim(termNo)) and isnumeric(termNo)>
								<cfset DueDate = DateAdd('d',termNo,InvoiceDate)>
								<cfset DueDate = DateFormat(DueDate,'m/d/yyyy')>
							</cfif>
						</cfif>

						<cfset var memo= 'SHIPPER:\n#qGetQBAPExportLoads.PickUpName#\n#qGetQBAPExportLoads.PickUpAddress#\n#qGetQBAPExportLoads.PickUpCity# #qGetQBAPExportLoads.PickUpState# #qGetQBAPExportLoads.PickUpZip#\n\nCONSIGNEE:\n#qGetQBAPExportLoads.DeliveryName#\n#qGetQBAPExportLoads.DeliveryAddress#\n#qGetQBAPExportLoads.DeliveryCity# #qGetQBAPExportLoads.DeliveryState# #qGetQBAPExportLoads.DeliveryZip#'>

						<cfset iifString = iifString & "#chr(13)##chr(10)#">

						<cfset iifString = iifString & 'TRNS#CHR(9)##qGetQBAPExportLoads.LoadNumber##CHR(9)#BILL#CHR(9)##DateFormat(InvoiceDate,'m/d/yyyy')##CHR(9)#Accounts Payable#CHR(9)#"#qGetQBAPExportLoads.CarrierName#"#CHR(9)#-#local.TotalCarrierCharges##CHR(9)##qGetQBAPExportLoads.LoadNumber##CHR(9)#Carrier Invoice##: #qGetQBAPExportLoads.CarrierInvoiceNumber##CHR(9)#N#CHR(9)#N#CHR(9)#"#qGetQBAPExportLoads.CarrierName#"#CHR(9)##qGetQBAPExportLoads.CarrierAddress##CHR(9)#"#qGetQBAPExportLoads.CarrierCity#, #qGetQBAPExportLoads.CarrierState# #qGetQBAPExportLoads.CarrierZip#"#CHR(9)##CHR(9)##CHR(9)##DueDate##CHR(9)##qGetQBSettings.QBDefBillPayTerm##chr(13)##chr(10)#'>

						<cfset iifString = iifString & "SPL#CHR(9)##qGetQBAPExportLoads.LoadNumber##CHR(9)#BILL#CHR(9)##CHR(9)##qGetQBSettings.QBDefBillAccountName##CHR(9)#N#CHR(9)##local.TotalCarrierCharges##CHR(9)#NOTHING#CHR(9)##memo##CHR(9)#1#CHR(9)#LOAD#CHR(9)##CHR(9)##CHR(9)##CHR(9)##CHR(9)##CHR(9)##CHR(9)##chr(13)##chr(10)#">

						<cfset iifString = iifString & "SPL#CHR(9)#AUTOSTAX#CHR(9)##CHR(9)##CHR(9)##CHR(9)##CHR(9)##CHR(9)##CHR(9)##CHR(9)##CHR(9)##CHR(9)##CHR(9)##CHR(9)##CHR(9)##CHR(9)##CHR(9)##CHR(9)##chr(13)##chr(10)#">

						<cfset iifString = iifString & "ENDTRNS#CHR(9)##CHR(9)##CHR(9)##CHR(9)##CHR(9)##CHR(9)##CHR(9)##CHR(9)##CHR(9)##CHR(9)##CHR(9)##CHR(9)##CHR(9)##CHR(9)##CHR(9)##CHR(9)##CHR(9)#">

						<cfquery name="qUpdLoads" datasource="#variables.dsn#">
							UPDATE Loads SET APExported  = 1
							,StatusTypeID = <cfqueryparam value="#arguments.frmstruct.BillStatus#" cfsqltype="cf_sql_varchar">
							WHERE LoadID = <cfqueryparam value="#qGetQBAPExportLoads.LoadID#" cfsqltype="cf_sql_varchar">
						</cfquery>
						<cfif qGetQBAPExportLoads.StatusTypeID NEQ arguments.frmstruct.BillStatus>
							<cfset SendLoadEmailUpdate(qGetQBAPExportLoads.LoadID,arguments.frmstruct.BillStatus)>
							<cfif structKeyExists(session, "LoadEmailUpdateMsg")>
								<cfset structDelete(session, "LoadEmailUpdateMsg")>
							</cfif>
						</cfif>
						<cfquery name="qInsQBExportedHistory" datasource="#variables.dsn#">
							INSERT INTO tblQBExportedHistory
								([CompanyName]
					           ,[MinOfPickupDate]
					           ,[MaxOfDeliveryDate]
					           ,[LoadNumber]
					           ,[FirstOfCarrierName]
					           ,[PayerName]
					           ,[Customer Amount]
					           ,[Carrier Amount]
					           ,[created]
					           ,[Type]
					           ,[id]
					           ,[CompanyID]
					           ,[CreatedBy]
					           ,[LoadID]
					           ,[ExportSetID])
							VALUES(
								<cfqueryparam value="#qGetQBSettings.CompanyName#" cfsqltype="cf_sql_varchar">
								<cfif len(trim(qGetQBAPExportLoads.PickupDate))>
									,<cfqueryparam value="#qGetQBAPExportLoads.PickupDate#" cfsqltype="cf_sql_date">
								<cfelse>
									,<cfqueryparam value="" cfsqltype="cf_sql_date" null="true">
								</cfif>
								<cfif len(trim(qGetQBAPExportLoads.DeliveryDate))>
									,<cfqueryparam value="#qGetQBAPExportLoads.DeliveryDate#" cfsqltype="cf_sql_date">
								<cfelse>
									,<cfqueryparam value="" cfsqltype="cf_sql_date" null="true">
								</cfif>
								,<cfqueryparam value="#qGetQBAPExportLoads.LoadNumber#" cfsqltype="cf_sql_integer">
								,<cfqueryparam value="#qGetQBAPExportLoads.CarrierName#" cfsqltype="cf_sql_varchar">
								,<cfqueryparam value="#qGetQBAPExportLoads.CustomerName#" cfsqltype="cf_sql_varchar">
								,<cfqueryparam value="#qGetQBAPExportLoads.TotalCustomerCharges#" cfsqltype="cf_sql_float">
								,<cfqueryparam value="#qGetQBAPExportLoads.TotalCarrierCharges#" cfsqltype="cf_sql_float">
								,getdate()
								,'Bill'
								,(SELECT ISNULL(MAX(id),0)+1 FROM tblQBExportedHistory)
								,<cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar">
								,<cfqueryparam value="#session.adminUserName#" cfsqltype="cf_sql_varchar">
								,<cfqueryparam value="#qGetQBAPExportLoads.LoadID#" cfsqltype="cf_sql_varchar">
								,<cfqueryparam value="#qGetExportSet.ID#" cfsqltype="cf_sql_varchar">
							)
						</cfquery>
					<cfelse>
						<cfset bitExportedAll = 0>
					</cfif>
					</cfloop>
				</cfloop>

				<cffile action="write" output="#iifString#" file="#theFile#" addnewline="no">
			<cfelse>
				<cfscript> 
		    		fileName = 'QBBillImport_#qGetQBSettings.CompanyCode#_#DateTimeFormat(now(),"YYYY_MM_dd_HH_nn_ss_l")#.csv';
					theDir=expandPath( "../temp/" );
					if(! DirectoryExists(theDir)){
						directoryCreate(expandPath("../temp/"));
					}
					theFile=theDir & fileName; 
					theSheet = SpreadsheetNew("QBBillImport");
				</cfscript>

				<cfset csvString = "APAccount,RefNumber,Vendor,TxnDate,SalesTerm,AddressLine1,AddressCity,AddressState,AddressPostalcode,ExpenseAccount,ExpenseAmount,ExpenseDescription,FinalRemitTo,RemitCity,RemitAddress,RemitZipcode,RemitContact,RemitName,RemitState"> 

				<cfloop query="qGetQBAPExportLoads">
					<cfif len(trim(qGetQBAPExportLoads.BillDate))>
						<cfset var InvoiceDate = qGetQBAPExportLoads.BillDate>
					<cfelse>
						<cfset var InvoiceDate = qGetQBAPExportLoads.PickUpDate>
					</cfif>
					<cfif len(trim(InvoiceDate))>
						<cfset csvString = csvString & "#chr(13)##chr(10)#">
						<cfset csvString = csvString & 'Accounts Payable (A/P),#qGetQBAPExportLoads.LoadNumber#,"#qGetQBAPExportLoads.CarrierName#",#DateFormat(InvoiceDate,"mm/dd/yyyy")#,#qGetQBSettings.QBDefBillPayTerm#,"#qGetQBAPExportLoads.CarrierAddress#",#qGetQBAPExportLoads.CarrierCity#,#qGetQBAPExportLoads.CarrierState#,#qGetQBAPExportLoads.CarrierZip#,#qGetQBSettings.QBDefBillAccountName#,#qGetQBAPExportLoads.TotalCarrierCharges#,Load Charges including Flat Rate and Accessorials,#qGetQBAPExportLoads.RemitName#,#qGetQBAPExportLoads.RemitCity#,"#qGetQBAPExportLoads.RemitAddress#",#qGetQBAPExportLoads.RemitZipcode#,#qGetQBAPExportLoads.RemitContact#,#qGetQBAPExportLoads.RemitName#,#qGetQBAPExportLoads.RemitState#'>

						<cfquery name="qUpdLoads" datasource="#variables.dsn#">
							UPDATE Loads SET APExported  = 1
							,StatusTypeID = <cfqueryparam value="#arguments.frmstruct.BillStatus#" cfsqltype="cf_sql_varchar">
							WHERE LoadID = <cfqueryparam value="#qGetQBAPExportLoads.LoadID#" cfsqltype="cf_sql_varchar">
						</cfquery>
						<cfif qGetQBAPExportLoads.StatusTypeID NEQ arguments.frmstruct.BillStatus>
							<cfset SendLoadEmailUpdate(qGetQBAPExportLoads.LoadID,arguments.frmstruct.BillStatus)>
							<cfif structKeyExists(session, "LoadEmailUpdateMsg")>
								<cfset structDelete(session, "LoadEmailUpdateMsg")>
							</cfif>
						</cfif>
						<cfquery name="qInsQBExportedHistory" datasource="#variables.dsn#">
							INSERT INTO tblQBExportedHistory
								([CompanyName]
					           ,[MinOfPickupDate]
					           ,[MaxOfDeliveryDate]
					           ,[LoadNumber]
					           ,[FirstOfCarrierName]
					           ,[PayerName]
					           ,[Customer Amount]
					           ,[Carrier Amount]
					           ,[created]
					           ,[Type]
					           ,[id]
					           ,[CompanyID]
					           ,[CreatedBy]
					           ,[LoadID]
					           ,[ExportSetID])
							VALUES(
								<cfqueryparam value="#qGetQBSettings.CompanyName#" cfsqltype="cf_sql_varchar">
								<cfif len(trim(qGetQBAPExportLoads.PickupDate))>
									,<cfqueryparam value="#qGetQBAPExportLoads.PickupDate#" cfsqltype="cf_sql_date">
								<cfelse>
									,<cfqueryparam value="" cfsqltype="cf_sql_date" null="true">
								</cfif>
								<cfif len(trim(qGetQBAPExportLoads.DeliveryDate))>
									,<cfqueryparam value="#qGetQBAPExportLoads.DeliveryDate#" cfsqltype="cf_sql_date">
								<cfelse>
									,<cfqueryparam value="" cfsqltype="cf_sql_date" null="true">
								</cfif>
								,<cfqueryparam value="#qGetQBAPExportLoads.LoadNumber#" cfsqltype="cf_sql_integer">
								,<cfqueryparam value="#qGetQBAPExportLoads.CarrierName#" cfsqltype="cf_sql_varchar">
								,<cfqueryparam value="#qGetQBAPExportLoads.CustomerName#" cfsqltype="cf_sql_varchar">
								,<cfqueryparam value="#qGetQBAPExportLoads.TotalCustomerCharges#" cfsqltype="cf_sql_float">
								,<cfqueryparam value="#qGetQBAPExportLoads.TotalCarrierCharges#" cfsqltype="cf_sql_float">
								,getdate()
								,'Bill'
								,(SELECT ISNULL(MAX(id),0)+1 FROM tblQBExportedHistory)
								,<cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar">
								,<cfqueryparam value="#session.adminUserName#" cfsqltype="cf_sql_varchar">
								,<cfqueryparam value="#qGetQBAPExportLoads.LoadID#" cfsqltype="cf_sql_varchar">
								,<cfqueryparam value="#qGetExportSet.ID#" cfsqltype="cf_sql_varchar">
							)
						</cfquery>
					</cfif>
				</cfloop>
				<cffile action="write" output="#csvString#" file="#theFile#" addNewLine="no">
			</cfif>
			<cfset respStr = structNew()>
	    	<cfset respStr.res = 'success'>
	    	<cfset respStr.msg = "Exported successfully.">
	    	<cfset respStr.fileName = "#fileName#">
	    	<cfreturn respStr>

			<cfcatch>
				<cfset respStr = structNew()>
		    	<cfset respStr.res = 'error'>
		    	<cfset respStr.msg = "Something went wrong. Unable to export.">
		    	<cfreturn respStr>
			</cfcatch>
		</cftry>
    </cffunction>

    <cffunction name="updateDashboardChart" access="remote" output="yes" returntype="any" returnformat="json">
    	<cfargument name="groupby" required="no" type="string">
    	<cfargument name="dateFrom" required="no" type="string">
    	<cfargument name="dateTo" required="no" type="string">
    	<cfargument name="statusFrom" required="no" type="string">
    	<cfargument name="statusTo" required="no" type="string">
    	<cfargument name="totalField" required="yes" type="string">
    	<cfargument name="Dispatcher" required="no" type="string">
    	<cfargument name="SalesRep" required="no" type="string">
    	<cfargument name="dateType" required="no" type="string" default="NewPickupDate">
    	<cfif arguments.groupby EQ 'none'>
	    	<cfquery name="qGet" datasource="#variables.dsn#">
	    		SELECT 
				LEFT(DATENAME(month,L.#arguments.dateType#),3) AS Label,
				MIN(L.#arguments.dateType#) AS Datetime,
				SUM(L.TotalCustomerCharges) AS Sales,
				SUM(L.TotalCustomerCharges-TotalCarrierCharges) AS Profit,
				CASE WHEN SUM(L.TotalCustomerCharges) = 0 THEN 0 ELSE (SUM(L.TotalCustomerCharges-TotalCarrierCharges) * 100)/SUM(L.TotalCustomerCharges) END AS ProfitPerc,
				COUNT(L.LoadID) AS LoadCount
				FROM Loads L
				INNER JOIN LoadStatusTypes LST ON LST.StatusTypeID = L.StatusTypeID
				WHERE L.CustomerID IN (SELECT CO.CustomerID FROM CustomerOffices CO WHERE CO.OfficeID IN (SELECT O.OfficeID FROM Offices O WHERE O.CompanyID = <cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar">))
				AND convert(date, L.#arguments.dateType#, 101) BETWEEN <cfqueryparam value="#arguments.dateFrom#" cfsqltype="cf_sql_date"> AND <cfqueryparam value="#arguments.dateTo#" cfsqltype="cf_sql_date">
				AND LST.StatusText BETWEEN <cfqueryparam value="#arguments.StatusFrom#" cfsqltype="cf_sql_varchar"> AND <cfqueryparam value="#arguments.StatusTo#" cfsqltype="cf_sql_varchar">
				<cfif len(trim(arguments.Dispatcher)) OR len(trim(arguments.SalesRep))>
					AND (1=0
						<cfif len(trim(arguments.Dispatcher))>
							OR L.DispatcherID = <cfqueryparam value="#arguments.Dispatcher#" cfsqltype="cf_sql_varchar">
							OR L.Dispatcher1 = <cfqueryparam value="#arguments.Dispatcher#" cfsqltype="cf_sql_varchar">
							OR L.Dispatcher2 = <cfqueryparam value="#arguments.Dispatcher#" cfsqltype="cf_sql_varchar">
							OR L.Dispatcher3 = <cfqueryparam value="#arguments.Dispatcher#" cfsqltype="cf_sql_varchar">
						</cfif>
						<cfif len(trim(arguments.SalesRep))>
							OR L.SalesRepID = <cfqueryparam value="#arguments.SalesRep#" cfsqltype="cf_sql_varchar">
							OR L.SalesRep1 = <cfqueryparam value="#arguments.SalesRep#" cfsqltype="cf_sql_varchar">
							OR L.SalesRep2 = <cfqueryparam value="#arguments.SalesRep#" cfsqltype="cf_sql_varchar">
							OR L.SalesRep3 = <cfqueryparam value="#arguments.SalesRep#" cfsqltype="cf_sql_varchar">
						</cfif>
						)
				</cfif>
				GROUP BY  DATENAME(month,L.#arguments.dateType#)
				ORDER BY Datetime
	    	</cfquery>
	    <cfelseif listFindNoCase("salesagent,dispatcher", arguments.groupby)>
	    	<cfquery name="qGet" datasource="#variables.dsn#">
	    		SELECT E.Name AS Label,
				SUM(L.TotalCustomerCharges) AS Sales,
				SUM(L.TotalCustomerCharges-TotalCarrierCharges) AS Profit,
				CASE WHEN SUM(L.TotalCustomerCharges) = 0 THEN 0 ELSE (SUM(L.TotalCustomerCharges-TotalCarrierCharges) * 100)/SUM(L.TotalCustomerCharges) END AS ProfitPerc,
				COUNT(L.LoadID) AS LoadCount
				FROM Employees E
				INNER JOIN Loads L ON E.EmployeeID = <cfif arguments.groupby EQ 'salesagent'>L.SalesRepID<cfelse>L.DispatcherID</cfif>
				INNER JOIN LoadStatusTypes LST ON LST.StatusTypeID = L.StatusTypeID
				INNER JOIN Offices O ON O.OfficeID = E.OfficeID
				WHERE O.CompanyID = <cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar">
				AND convert(date, L.#arguments.dateType#, 101) BETWEEN <cfqueryparam value="#arguments.dateFrom#" cfsqltype="cf_sql_date"> AND <cfqueryparam value="#arguments.dateTo#" cfsqltype="cf_sql_date">
				AND LST.StatusText BETWEEN <cfqueryparam value="#arguments.StatusFrom#" cfsqltype="cf_sql_varchar"> AND <cfqueryparam value="#arguments.StatusTo#" cfsqltype="cf_sql_varchar">
				<cfif len(trim(arguments.Dispatcher)) OR len(trim(arguments.SalesRep))>
					AND (1=0
						<cfif len(trim(arguments.Dispatcher))>
							OR L.DispatcherID = <cfqueryparam value="#arguments.Dispatcher#" cfsqltype="cf_sql_varchar">
							OR L.Dispatcher1 = <cfqueryparam value="#arguments.Dispatcher#" cfsqltype="cf_sql_varchar">
							OR L.Dispatcher2 = <cfqueryparam value="#arguments.Dispatcher#" cfsqltype="cf_sql_varchar">
							OR L.Dispatcher3 = <cfqueryparam value="#arguments.Dispatcher#" cfsqltype="cf_sql_varchar">
						</cfif>
						<cfif len(trim(arguments.SalesRep))>
							OR L.SalesRepID = <cfqueryparam value="#arguments.SalesRep#" cfsqltype="cf_sql_varchar">
							OR L.SalesRep1 = <cfqueryparam value="#arguments.SalesRep#" cfsqltype="cf_sql_varchar">
							OR L.SalesRep2 = <cfqueryparam value="#arguments.SalesRep#" cfsqltype="cf_sql_varchar">
							OR L.SalesRep3 = <cfqueryparam value="#arguments.SalesRep#" cfsqltype="cf_sql_varchar">
						</cfif>
						)
				</cfif>
				GROUP BY  E.Name
				ORDER BY #arguments.totalField# DESC 
	    	</cfquery>
	    <cfelseif arguments.groupby eq "customer">
	    	<cfquery name="qGet" datasource="#variables.dsn#">
		    	SELECT 
				C.CustomerName AS Label,
				SUM(L.TotalCustomerCharges) AS Sales,
				SUM(L.TotalCustomerCharges-TotalCarrierCharges) AS Profit,
				CASE WHEN SUM(L.TotalCustomerCharges) = 0 THEN 0 ELSE (SUM(L.TotalCustomerCharges-TotalCarrierCharges) * 100)/SUM(L.TotalCustomerCharges) END AS ProfitPerc,
				COUNT(L.LoadID) AS LoadCount
				FROM Customers C
				INNER JOIN Loads L ON L.CustomerID = C.CustomerID
				INNER JOIN LoadStatusTypes LST ON LST.StatusTypeID = L.StatusTypeID
				INNER JOIN CustomerOffices CO ON CO.CustomerID = L.CustomerID
				INNER JOIN Offices O ON O.OfficeID = CO.OfficeID
				WHERE O.CompanyID = <cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar">
				AND convert(date, L.#arguments.dateType#, 101) BETWEEN <cfqueryparam value="#arguments.dateFrom#" cfsqltype="cf_sql_date"> AND <cfqueryparam value="#arguments.dateTo#" cfsqltype="cf_sql_date">
				AND LST.StatusText BETWEEN <cfqueryparam value="#arguments.StatusFrom#" cfsqltype="cf_sql_varchar"> AND <cfqueryparam value="#arguments.StatusTo#" cfsqltype="cf_sql_varchar">
				<cfif len(trim(arguments.Dispatcher)) OR len(trim(arguments.SalesRep))>
					AND (1=0
						<cfif len(trim(arguments.Dispatcher))>
							OR L.DispatcherID = <cfqueryparam value="#arguments.Dispatcher#" cfsqltype="cf_sql_varchar">
							OR L.Dispatcher1 = <cfqueryparam value="#arguments.Dispatcher#" cfsqltype="cf_sql_varchar">
							OR L.Dispatcher2 = <cfqueryparam value="#arguments.Dispatcher#" cfsqltype="cf_sql_varchar">
							OR L.Dispatcher3 = <cfqueryparam value="#arguments.Dispatcher#" cfsqltype="cf_sql_varchar">
						</cfif>
						<cfif len(trim(arguments.SalesRep))>
							OR L.SalesRepID = <cfqueryparam value="#arguments.SalesRep#" cfsqltype="cf_sql_varchar">
							OR L.SalesRep1 = <cfqueryparam value="#arguments.SalesRep#" cfsqltype="cf_sql_varchar">
							OR L.SalesRep2 = <cfqueryparam value="#arguments.SalesRep#" cfsqltype="cf_sql_varchar">
							OR L.SalesRep3 = <cfqueryparam value="#arguments.SalesRep#" cfsqltype="cf_sql_varchar">
						</cfif>
						)
				</cfif>
				GROUP BY  C.CustomerName
				ORDER BY #arguments.totalField# DESC 
	    	</cfquery>
	    <cfelseif arguments.groupby eq "carrier">
	    	<cfquery name="qGet" datasource="#variables.dsn#">
		    	SELECT 
				C.CarrierName AS Label,
				SUM(L.TotalCustomerCharges) AS Sales,
				SUM(L.TotalCustomerCharges-TotalCarrierCharges) AS Profit,
				CASE WHEN SUM(L.TotalCustomerCharges) = 0 THEN 0 ELSE (SUM(L.TotalCustomerCharges-TotalCarrierCharges) * 100)/SUM(L.TotalCustomerCharges) END AS ProfitPerc,
				COUNT(L.LoadID) AS LoadCount
				FROM Carriers C
				INNER JOIN Loads L ON L.CarrierID = C.CarrierID
				INNER JOIN LoadStatusTypes LST ON LST.StatusTypeID = L.StatusTypeID
				WHERE C.CompanyID = <cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar">
				AND convert(date, L.#arguments.dateType#, 101) BETWEEN <cfqueryparam value="#arguments.dateFrom#" cfsqltype="cf_sql_date"> AND <cfqueryparam value="#arguments.dateTo#" cfsqltype="cf_sql_date">
				AND LST.StatusText BETWEEN <cfqueryparam value="#arguments.StatusFrom#" cfsqltype="cf_sql_varchar"> AND <cfqueryparam value="#arguments.StatusTo#" cfsqltype="cf_sql_varchar">
				<cfif len(trim(arguments.Dispatcher)) OR len(trim(arguments.SalesRep))>
					AND (1=0
						<cfif len(trim(arguments.Dispatcher))>
							OR L.DispatcherID = <cfqueryparam value="#arguments.Dispatcher#" cfsqltype="cf_sql_varchar">
							OR L.Dispatcher1 = <cfqueryparam value="#arguments.Dispatcher#" cfsqltype="cf_sql_varchar">
							OR L.Dispatcher2 = <cfqueryparam value="#arguments.Dispatcher#" cfsqltype="cf_sql_varchar">
							OR L.Dispatcher3 = <cfqueryparam value="#arguments.Dispatcher#" cfsqltype="cf_sql_varchar">
						</cfif>
						<cfif len(trim(arguments.SalesRep))>
							OR L.SalesRepID = <cfqueryparam value="#arguments.SalesRep#" cfsqltype="cf_sql_varchar">
							OR L.SalesRep1 = <cfqueryparam value="#arguments.SalesRep#" cfsqltype="cf_sql_varchar">
							OR L.SalesRep2 = <cfqueryparam value="#arguments.SalesRep#" cfsqltype="cf_sql_varchar">
							OR L.SalesRep3 = <cfqueryparam value="#arguments.SalesRep#" cfsqltype="cf_sql_varchar">
						</cfif>
						)
				</cfif>
				GROUP BY  C.CarrierName
				ORDER BY #arguments.totalField# DESC 
	    	</cfquery>
	    </cfif>
    	<cfset total = 0>
    	<cfloop query="qGet">
    		<cfset total = total + qGet["#totalField#"][currentrow]>
    	</cfloop>
    	<cfset var retArr = arrayNew(1)>
    	<cfset tempper = 0>
    	<cfloop query="qGet">
    		<cfset tempStruct = structNew()>
    		<cfset tempStruct["Label"] = qGet.Label>
    		<cfset tempStruct["Sales"] = dollarformat(qGet.Sales)>
    		<cfset tempStruct["Profit"] =  dollarformat(qGet.Profit)>
    		<cfset tempStruct["LoadCount"] = qGet.LoadCount>
    		<cfset tempStruct["ProfitPerc"] = ProfitPerc>
    		<cfset tempStruct["Total"] = total>
    		<cfif total EQ 0>
    			<cfset tempStruct["Value"] = 0>
    		<cfelse>
	    		<cfset tempStruct["Value"] = (qGet["#totalField#"][currentrow] * 100)/total>
	    	</cfif>
    		<cfset arrayAppend(retArr, tempStruct)>
    	</cfloop>

    	<cfreturn retArr>
    </cffunction>

    <cffunction name="getLoadDetailsForGoogleMap" access="public" returntype="query">
    	<cfargument name="LoadID" required="yes" type="string">

    	<cfquery name="qLoadDetails" datasource="#variables.dsn#">
    		SELECT 
			LS.CustName,
			REPLACE(LS.Address, CHAR(13) + CHAR(10), ' ') AS Address,
			LS.City,
			LS.StateCode,
			LS.PostalCode,
			L.LoadNumber,
			ISNULL(LS.NewDriverName,LS.NewDriverName2) AS Driver,
			L.EquipmentName,
			CASE WHEN LS.LoadType = 1 THEN 'P' ELSE 'D' END AS LoadType,
			LS.StopNo+1 AS StopNo,
			LS.ContactPerson,
			LS.Phone
			FROM Loads L
			INNER JOIN LoadStops LS ON LS.LoadID = L.LoadID
			WHERE L.LoadID = <cfqueryparam value="#arguments.LoadID#" cfsqltype="cf_sql_varchar">
			AND (ISNULL(LS.Address,'') <> '' OR ISNULL(LS.City,'') <> '' OR ISNULL(LS.StateCode,'') <> '' OR ISNULL(LS.PostalCode,'') <> '')
			ORDER BY LS.StopNo,LS.LoadType
    	</cfquery>

    	<cfreturn qLoadDetails>
    </cffunction>

    <cffunction name="getGPSDataPoints" access="public" returntype="query">
    	<cfargument name="LoadID" required="yes" type="string">

    	<cfquery name="qGPSDataPoints" datasource="#variables.dsn#">
    		SELECT 
			[ZGPSTrackingMPWeb].[dbo].[Positions].[servertime],
			[ZGPSTrackingMPWeb].[dbo].[Positions].[Latitude],
			[ZGPSTrackingMPWeb].[dbo].[Positions].[Longitude]
			FROM [dbo].[Loads] 
			INNER JOIN  [ZGPSTrackingMPWeb].[dbo].[Devices] ON [ZGPSTrackingMPWeb].[dbo].[Devices].[UniqueID] = [dbo].[Loads].[GPSDeviceID] 
			INNER JOIN  [ZGPSTrackingMPWeb].[dbo].[Positions] ON [ZGPSTrackingMPWeb].[dbo].[Positions].[DeviceID] = [ZGPSTrackingMPWeb].[dbo].[Devices].[ID] 
			WHERE [dbo].[Loads].[LoadID] = <cfqueryparam value="#arguments.LoadID#" cfsqltype="cf_sql_varchar">
			GROUP BY [ZGPSTrackingMPWeb].[dbo].[Positions].[servertime],[ZGPSTrackingMPWeb].[dbo].[Positions].[Latitude],[ZGPSTrackingMPWeb].[dbo].[Positions].[Longitude]
			ORDER BY [ZGPSTrackingMPWeb].[dbo].[Positions].[servertime]
    	</cfquery>

    	<cfreturn qGPSDataPoints>
    </cffunction>

    <cffunction name="setDashBoardLogin" access="public" returntype="void">
    	<cfargument name="DashboardUser" type="string" required="yes"/>
		<cfargument name="DashboardPassword" type="string" required="yes"/>

		<cfquery name="qUpd" datasource="#Application.dsn#">
			UPDATE SystemConfig 
			SET DashboardUser = <cfqueryparam value="#arguments.DashboardUser#" cfsqltype="cf_sql_varchar">
			,DashboardPassword = <cfqueryparam value="#arguments.DashboardPassword#" cfsqltype="cf_sql_varchar">
			WHERE CompanyID = <cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar">
		</cfquery>
    </cffunction>

    <cffunction name="getValidCustomers" access="public" returntype="query">
		<cfquery name="qGet" datasource="#Application.dsn#">
			select customername from customers 
			inner join customeroffices on customeroffices.customerid = customers.customerid
			inner join offices on offices.OfficeID = customeroffices.OfficeID
			where companyid = <cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar">
		</cfquery>
		<cfreturn qGet>
	</cffunction>

	<cffunction name="relocationToBeta" access="public" returntype="void">
		<cfquery name="qDel" datasource="#Application.dsn#">
			DELETE FROM UserCountCheck WHERE CUTOMERID IN (SELECT E.EmployeeID FROM Employees E INNER JOIN Offices O ON O.OfficeID = E.OfficeID WHERE O.CompanyID = <cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar">)
		</cfquery>
	</cffunction>

	<cffunction name="CancelLoadDispatch" access="public" returntype="void">
    	<cfargument name="LoadID" type="string" required="yes"/>

		<cfquery name="qUpd" datasource="#Application.dsn#">
			UPDATE Loads SET IsEDispatched = 0
			WHERE LoadID = <cfqueryparam value="#arguments.LoadID#" cfsqltype="cf_sql_varchar">
		</cfquery>

		<cfquery name="qUpdStop" datasource="#Application.dsn#">
			UPDATE LoadStops SET NewDriverCell = ''
			WHERE LoadID = <cfqueryparam value="#arguments.LoadID#" cfsqltype="cf_sql_varchar">
			AND StopNo = 0
		</cfquery>

    </cffunction>

    <cffunction name="getSalesDetailReport" access="public" returntype="any">
		<cfargument name="frmStruct" type="struct" required="yes">
		
		<cfswitch expression="#arguments.frmStruct.groupby#">
			<cfcase value="salesAgent"><cfset var orderBy = "SalesRep.Name"></cfcase>
			<cfcase value="dispatcher"><cfset var orderBy = "Dispatcher.Name"></cfcase>
			<cfcase value="customer"><cfset var orderBy = "L.CustName"></cfcase>
			<cfcase value="Carrier"><cfset var orderBy = "L.CarrierName"></cfcase>
			<cfdefaultcase><cfset var orderBy = ""></cfdefaultcase>
		</cfswitch>

		<cfif structKeyExists(form, "ExZeroItems")>
			<cfset var ExcludeZeroItems = 1>
		<cfelse>
			<cfset var ExcludeZeroItems = 0>
		</cfif>

		<cfif structKeyExists(form, "ExZeroWeight")>
			<cfset var ExcludeZeroWeight = 1>
		<cfelse>
			<cfset var ExcludeZeroWeight = 0>
		</cfif>

		<CFSTOREDPROC PROCEDURE="USP_GetSalesDetailReport" DATASOURCE="#Application.dsn#">
			<CFPROCPARAM VALUE="#session.CompanyID#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#arguments.frmStruct.groupby#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#arguments.frmStruct.datetype#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#arguments.frmStruct.datefrom#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#arguments.frmStruct.dateto#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#arguments.frmStruct.statusfrom#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#arguments.frmStruct.statusto#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#trim(replaceNoCase(arguments.frmStruct.salesRepFrom, "'", "''",'ALL'))#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#trim(replaceNoCase(arguments.frmStruct.salesRepTo, "'", "''",'ALL'))#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#trim(replaceNoCase(arguments.frmStruct.dispatcherFrom, "'", "''",'ALL'))#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#trim(replaceNoCase(arguments.frmStruct.dispatcherTo, "'", "''",'ALL'))#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#trim(replaceNoCase(arguments.frmStruct.customerFrom, "'", "''",'ALL'))#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#trim(replaceNoCase(arguments.frmStruct.customerTo, "'", "''",'ALL'))#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#trim(replaceNoCase(arguments.frmStruct.carrierFrom, "'", "''",'ALL'))#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#trim(replaceNoCase(arguments.frmStruct.carrierTo, "'", "''",'ALL'))#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#orderBy#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#ExcludeZeroItems#" cfsqltype="CF_SQL_BIT">
			<CFPROCPARAM VALUE="#ExcludeZeroWeight#" cfsqltype="CF_SQL_BIT">
			<CFPROCPARAM VALUE="#trim(replaceNoCase(arguments.frmStruct.officeFrom, "'", "''",'ALL'))#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#trim(replaceNoCase(arguments.frmStruct.officeTo, "'", "''",'ALL'))#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#trim(replaceNoCase(arguments.frmStruct.billFrom, "'", "''",'ALL'))#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#trim(replaceNoCase(arguments.frmStruct.billTo, "'", "''",'ALL'))#" cfsqltype="CF_SQL_VARCHAR">
			<cfif ListContains(session.rightsList,'SalesRepReport',',')>
				<cfprocparam value="1" cfsqltype="cf_sql_bit">
			<cfelse>
				<cfprocparam value="0" cfsqltype="cf_sql_bit">
			</cfif>
			<cfif structKeyExists(cookie, "ReportIncludeAllDispatchers") AND cookie.ReportIncludeAllDispatchers>
				<cfprocparam value="1" cfsqltype="cf_sql_bit">
			<cfelse>
				<cfprocparam value="0" cfsqltype="cf_sql_bit">
			</cfif>
			<cfif structKeyExists(cookie, "ReportIncludeAllSalesRep") AND cookie.ReportIncludeAllSalesRep>
				<cfprocparam value="1" cfsqltype="cf_sql_bit">
			<cfelse>
				<cfprocparam value="0" cfsqltype="cf_sql_bit">
			</cfif>
			<CFPROCRESULT NAME="qSalesDetail">
		</CFSTOREDPROC>
		<cfreturn qSalesDetail>
	</cffunction>

	<cffunction name="getSalesReport" access="public" returntype="any">
		<cfargument name="frmStruct" type="struct" required="yes">
		
		<cfswitch expression="#arguments.frmStruct.groupby#">
			<cfcase value="salesAgent"><cfset var orderBy = "SalesRep.Name"></cfcase>
			<cfcase value="dispatcher"><cfset var orderBy = "Dispatcher.Name"></cfcase>
			<cfcase value="customer"><cfset var orderBy = "L.CustName"></cfcase>
			<cfcase value="Carrier"><cfset var orderBy = "L.CarrierName"></cfcase>
			<cfdefaultcase><cfset var orderBy = ""></cfdefaultcase>
		</cfswitch>
		<CFSTOREDPROC PROCEDURE="USP_GetSalesReport" DATASOURCE="#Application.dsn#">
			<CFPROCPARAM VALUE="#session.CompanyID#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#arguments.frmStruct.groupby#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#arguments.frmStruct.datetype#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#arguments.frmStruct.datefrom#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#arguments.frmStruct.dateto#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#arguments.frmStruct.statusfrom#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#arguments.frmStruct.statusto#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#trim(replaceNoCase(arguments.frmStruct.salesRepFrom, "'", "''",'ALL'))#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#trim(replaceNoCase(arguments.frmStruct.salesRepTo, "'", "''",'ALL'))#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#trim(replaceNoCase(arguments.frmStruct.dispatcherFrom, "'", "''",'ALL'))#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#trim(replaceNoCase(arguments.frmStruct.dispatcherTo, "'", "''",'ALL'))#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#trim(replaceNoCase(arguments.frmStruct.customerFrom, "'", "''",'ALL'))#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#trim(replaceNoCase(arguments.frmStruct.customerTo, "'", "''",'ALL'))#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#trim(replaceNoCase(arguments.frmStruct.carrierFrom, "'", "''",'ALL'))#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#trim(replaceNoCase(arguments.frmStruct.carrierTo, "'", "''",'ALL'))#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#orderBy#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#trim(replaceNoCase(arguments.frmStruct.officeFrom, "'", "''",'ALL'))#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#trim(replaceNoCase(arguments.frmStruct.officeTo, "'", "''",'ALL'))#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#trim(replaceNoCase(arguments.frmStruct.billFrom, "'", "''",'ALL'))#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#trim(replaceNoCase(arguments.frmStruct.billTo, "'", "''",'ALL'))#" cfsqltype="CF_SQL_VARCHAR">
			<cfif ListContains(session.rightsList,'SalesRepReport',',')>
				<cfprocparam value="1" cfsqltype="cf_sql_bit">
			<cfelse>
				<cfprocparam value="0" cfsqltype="cf_sql_bit">
			</cfif>
			<cfif structKeyExists(cookie, "ReportIncludeAllDispatchers") AND cookie.ReportIncludeAllDispatchers>
				<cfprocparam value="1" cfsqltype="cf_sql_bit">
			<cfelse>
				<cfprocparam value="0" cfsqltype="cf_sql_bit">
			</cfif>
			<cfif structKeyExists(cookie, "ReportIncludeAllSalesRep") AND cookie.ReportIncludeAllSalesRep>
				<cfprocparam value="1" cfsqltype="cf_sql_bit">
			<cfelse>
				<cfprocparam value="0" cfsqltype="cf_sql_bit">
			</cfif>
			<CFPROCRESULT NAME="qSalesDetail">
		</CFSTOREDPROC>
		<cfreturn qSalesDetail>
	</cffunction>

	<cffunction name="getLateStopDetails" access="public" returntype="query">
		<cfargument name="LoadID" type="string" required="yes">
		<CFSTOREDPROC PROCEDURE="USP_GetLateStopDetails" DATASOURCE="#Application.dsn#">
			<CFPROCPARAM VALUE="#arguments.LoadID#" cfsqltype="CF_SQL_VARCHAR" null="#not len(arguments.LoadID)#">
			<CFPROCRESULT NAME="qLateStopDetails">
		</CFSTOREDPROC>
		<cfreturn qLateStopDetails>
	</cffunction>

	<cffunction name="wp_getLoads" access="remote" returntype="any" returnformat="JSON">
		<cfargument name="StatusID" type="string" required="no" default="">
		<cfargument name="LoadID" type="string" required="no" default="">
		<cfquery name="qgetActiveLoads" datasource="#trim(listFirst(cgi.SCRIPT_NAME,'/'))#">
	    	SELECT 
	    	LoadID,
			LoadNumber,
			convert(varchar, NewPickupDate, 101) AS ShipDate
			,(SELECT TOP(1) City FROM LoadStops WHERE loadId = L.Loadid  AND  StopNo = 0 AND LoadType = 1) AS ShipCity
			,(SELECT TOP(1) StateCode FROM LoadStops WHERE loadId = L.Loadid  AND  StopNo = 0 AND LoadType = 1) AS ShipState
			,(SELECT Top(1) City FROM LoadStops WHERE loadId = L.Loadid AND  StopNo =(SELECT MAX(StopNo) FROM LoadStops WHERE LoadID = L.Loadid) AND LoadType = 2) AS DeliveryCity
			,(SELECT Top(1) StateCode FROM LoadStops WHERE loadId = L.Loadid AND  StopNo =(SELECT MAX(StopNo) FROM LoadStops WHERE LoadID = L.Loadid) AND LoadType = 2) AS DeliveryState
			,convert(varchar, NewDeliveryDate, 101) AS deliveryDate
			,EquipmentName as TruckType
			,EquipmentID
			,isnull(noOfTrips,0) as noOfTrips
			,L.carrierNotes
			,L.totalmiles as carriertotalmiles
			,L.TotalCarrierCharges
			,S.IncludeCarrierRate
			FROM Loads L
			INNER JOIN LoadStatusTypes LST ON LST.StatusTypeID = L.StatusTypeID
			INNER JOIN SystemConfig S ON S.CompanyID = LST.CompanyID
			<cfif len(trim(arguments.StatusID))>
				WHERE L.StatusTypeID=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.StatusID#">
				ORDER BY ShipDate,ShipState,ShipCity
			<cfelse>
				WHERE LoadID=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.LoadID#">
			</cfif>
		</cfquery>
		<cfset arrActiveLoads = arrayNew(1)>
		<cfset keyList = qgetActiveLoads.columnList>

		<cfloop query="qgetActiveLoads">
			<cfset temp = structNew()>
			<cfloop list="#keyList#" item="key">
				<cfset structInsert(temp, key, qgetActiveLoads[key][currentrow])>
			</cfloop>
			<cfset arrayAppend(arrActiveLoads, temp)>
		</cfloop>

		<cfreturn arrActiveLoads>

	</cffunction>

	<cffunction name="wp_getCarrier" access="remote" returntype="any" returnformat="JSON">

		<cfargument name="MCNumber" type="string" required="no" default="0">
		<cfargument name="CompanyID" type="string" required="no" default="">
		<cfheader name="Access-Control-Allow-Origin" value="*">
		<cfquery name="qgetCarrierbyMC" datasource="#trim(listFirst(cgi.SCRIPT_NAME,'/'))#">
			SELECT CarrierID FROM Carriers WHERE MCNumber = <cfqueryparam value="#arguments.MCNumber#" cfsqltype="cf_sql_varchar"> and CompanyID = <cfqueryparam value="#arguments.CompanyID#" cfsqltype="cf_sql_varchar">
		</cfquery>

		<cfif qgetCarrierbyMC.recordcount>
			<cfset structCarrier = structNew()>
			<cfloop list="#qgetCarrierbyMC.columnList#" item="key">
				<cfset structInsert(structCarrier, key, qgetCarrierbyMC[key])>
			</cfloop>
			<cfreturn structCarrier>
		<cfelse>
			<cfreturn 0>
		</cfif>

	</cffunction>

	<cffunction name="voidCustomerPayment" access="public" returntype="struct" returnformat="json">
		<cfargument name="frmstruct" required="yes" type="struct">
	    <cftransaction>
		    <cftry>
		    	<cfset var listARTransNumbers = arguments.frmstruct.CheckNumber>
		    	<cfset var balance = 0>
		    	<cfquery name="qGetARPayment" datasource="#Application.dsn#">
		    		SELECT InvoicNumber,(Applie + Discou) AS Amount FROM [LMA Accounts Receivable Payment Detail] WHERE CheckNumber = <cfqueryparam value="#arguments.frmstruct.CheckNumber#" cfsqltype="cf_sql_varchar"> AND CustomerID = <cfqueryparam value="#arguments.frmstruct.CustomerID#" cfsqltype="cf_sql_varchar">
		    	</cfquery>
		    	<cfloop query="qGetARPayment">
			    	<cfset listARTransNumbers = listAppend(listARTransNumbers, qGetARPayment.InvoicNumber)>
			    	<cfset balance = balance + qGetARPayment.Amount>
			    </cfloop>
			    <cfquery name="qUpdARPayment" datasource="#Application.dsn#">
			    	UPDATE [LMA Accounts Receivable Payment Detail] 
			    	SET Balance = Applie + Discou, Applie = 0, Discou = 0, 
			    	VoidedBy = <cfqueryparam value="#session.adminusername#" cfsqltype="cf_sql_varchar">
			    	,VoidedOn = getdate()
			    	WHERE CheckNumber = <cfqueryparam value="#arguments.frmstruct.CheckNumber#" cfsqltype="cf_sql_varchar"> AND CustomerID = <cfqueryparam value="#arguments.frmstruct.CustomerID#" cfsqltype="cf_sql_varchar">
				</cfquery>

				<cfquery name="qUpdARTrans" datasource="#Application.dsn#">
			    	UPDATE [LMA Accounts Receivable Transactions] 
			    	SET Balance = Applied + Discount, Applied = 0, Discount = 0
			    	WHERE Trans_Number IN (<cfqueryparam value="#listARTransNumbers#" cfsqltype="cf_sql_varchar" list="yes">)
			    	AND CustomerID = <cfqueryparam value="#arguments.frmstruct.CustomerID#" cfsqltype="cf_sql_varchar">
				</cfquery>

				<cfquery name="qUpdCustomer" datasource="#Application.dsn#">
			    	UPDATE Customers
			    	SET Balance = Balance + <cfqueryparam value="#balance#" cfsqltype="cf_sql_money">
			    	WHERE CustomerID = <cfqueryparam value="#arguments.frmstruct.CustomerID#" cfsqltype="cf_sql_varchar">
				</cfquery>

				<cfset local.post_amt = Balance>
			    <cfset local.debitTotal = local.post_amt>
			    <cfinvoke method="PostToGL" returnvariable="qPostToGL" account="#form.ARGLAccount#" cv_code="#arguments.frmStruct.companycode#" year_past="#form.year_past#" post_amt="#local.post_amt#" Invoice_Code="#arguments.frmstruct.CheckNumber#" tran_type="CR" tran_desc="Payment voided" tran_date="#DateFormat(now(),'mm/dd/yyyy')#" module=""/>
			    <cfset local.creditTotal = local.post_amt>
			    <cfset local.post_amt = -1*local.post_amt>
			    <cfinvoke method="PostToGL" returnvariable="qPostToGL" account="#form.DepositClearingAccount#" cv_code="#arguments.frmStruct.companycode#" year_past="#form.year_past#" post_amt="#local.post_amt#" Invoice_Code="#arguments.frmstruct.CheckNumber#" tran_type="CR" tran_desc="Payment voided" tran_date="#DateFormat(now(),'mm/dd/yyyy')#" module=""/>


				<cfset respStr = structNew()>
		    	<cfset respStr.res = 'success'>
		    	<cfset respStr.msg = "Payment have been voided.">
		    	<cfreturn respStr>
		    	<cfcatch>
		    		<cftransaction action="rollback">
		    			<cfdump var="#cfcatch#"><cfabort>
		    		<cfset respStr = structNew()>
			    	<cfset respStr.res = 'error'>
			    	<cfset respStr.msg = "Something went wrong. Unable to void the payment.">
			    	<cfreturn respStr>
		    	</cfcatch>
		    </cftry>
	    </cftransaction>
	    
	</cffunction>

	<cffunction name="voidCarrierPayment" access="public" returntype="struct" returnformat="json">
		<cfargument name="frmstruct" required="yes" type="struct">

	    <cftransaction>
		    <cftry>
		    	<cfset var listInvNumbers = "">
		    	<cfset var balance = 0>
		    	<cfset var discount = 0>
		    	<cfquery name="qGetAPCheckTrans" datasource="#Application.dsn#">
		    		SELECT InvoiceNumber,AmountPaid as Amount,AmountDiscount as Discount,checkaccount
		    		FROM [LMA Accounts Payable Check Transaction File]
		    		WHERE vendorcode = <cfqueryparam value="#arguments.frmstruct.vendorcode#" cfsqltype="cf_sql_varchar">
		    		<cfif len(trim(arguments.frmstruct.checknumber))>
			    		AND checknumber = <cfqueryparam value="#arguments.frmstruct.checknumber#" cfsqltype="cf_sql_varchar">
			    	<cfelse>
			    		AND checknumber IS NULL
			    	</cfif>
			    	AND CompanyID = <cfqueryparam value="#session.companyID#" cfsqltype="cf_sql_varchar">
		    	</cfquery>

		    	<cfloop query="qGetAPCheckTrans">
		    		<cfset listInvNumbers = listAppend(listInvNumbers, qGetAPCheckTrans.InvoiceNumber)>
		    		<cfset balance = balance + qGetAPCheckTrans.Amount>
		    		<cfset discount = discount + qGetAPCheckTrans.discount>
		    	</cfloop>

		    	<cfquery name="qUpdAPCheckTrans" datasource="#Application.dsn#">
			    	UPDATE [LMA Accounts Payable Check Transaction File]
			    	SET VoidedBy = <cfqueryparam value="#session.adminusername#" cfsqltype="cf_sql_varchar">
			    	,VoidedOn = getdate()
			    	WHERE vendorcode = <cfqueryparam value="#arguments.frmstruct.vendorcode#" cfsqltype="cf_sql_varchar">
			    	<cfif len(trim(arguments.frmstruct.checknumber))>
			    		AND checknumber = <cfqueryparam value="#arguments.frmstruct.checknumber#" cfsqltype="cf_sql_varchar">
			    	<cfelse>
			    		AND checknumber IS NULL
			    	</cfif>
			    	AND CompanyID = <cfqueryparam value="#session.companyID#" cfsqltype="cf_sql_varchar">
				</cfquery>

				<cfquery name="qUpdAPTrans" datasource="#Application.dsn#">
					UPDATE [LMA Accounts Payable Transactions] SET Balance = Applied + Discount, Applied = 0, Discount = 0
					WHERE Trans_Number IN  (<cfqueryparam value="#listInvNumbers#" cfsqltype="cf_sql_varchar" list="yes">)
			    	AND VendorID = <cfqueryparam value="#arguments.frmstruct.vendorcode#" cfsqltype="cf_sql_varchar">
			    	AND CompanyID = <cfqueryparam value="#session.companyID#" cfsqltype="cf_sql_varchar">
				</cfquery>

				<cfquery name="qUpdVendor" datasource="#Application.dsn#">
			    	UPDATE Carriers
			    	SET Balance = <cfqueryparam value="#(balance+discount)#" cfsqltype="cf_sql_money">
			    	WHERE CompanyID = <cfqueryparam value="#session.companyID#" cfsqltype="cf_sql_varchar">
			    	AND VendorID = <cfqueryparam value="#arguments.frmstruct.vendorcode#" cfsqltype="cf_sql_varchar">
				</cfquery>

				<cfif len(trim(arguments.frmstruct.checknumber))>
					<cfset local.TotalApplied = balance>
					<cfset local.TotalDiscount = discount>
					<cfset local.vendorcode = arguments.frmstruct.vendorcode>
					<cfset local.invoicenumber = qGetAPCheckTrans.invoicenumber>
					<cfset local.description = "Payment voided">

					<cfquery name="qGetBankCode" datasource="#Application.dsn#">
						SELECT [General Ledger Code] as glacct FROM [LMA Check Register Setup] WHERE companyID = <cfqueryparam value="#session.companyID#" cfsqltype="cf_sql_varchar"> AND [account code] = <cfqueryparam value="#qGetAPCheckTrans.checkaccount#" cfsqltype="cf_sql_integer">
					</cfquery>
					<cfif local.TotalApplied neq 0>
				    	<cfinvoke method="PostToGL" returnvariable="qPostToGL" account="#qGetBankCode.glacct#" cv_code="#local.vendorcode#" year_past="#arguments.frmStruct.year_past#" post_amt="#local.TotalApplied#" Invoice_Code="#local.invoicenumber#" tran_type="CD" tran_desc="#local.description#" tran_date="#DateFormat(now(),'mm/dd/yyyy')#" module=""/>
				    	<cfset local.TotalApplied  = -1*local.TotalApplied>
				    	<cfinvoke method="PostToGL" returnvariable="qPostToGL" account="#arguments.frmstruct.APGLAccount#" cv_code="#local.vendorcode#" year_past="#arguments.frmStruct.year_past#" post_amt="#local.TotalApplied#" Invoice_Code="#local.invoicenumber#" tran_type="CD" tran_desc="#local.description#" tran_date="#DateFormat(now(),'mm/dd/yyyy')#" module=""/>
				    </cfif>

				    <cfif local.TotalDiscount neq 0>
				    	<cfinvoke method="PostToGL" returnvariable="qPostToGL" account="#arguments.frmstruct.APDiscountAccount#" cv_code="#local.vendorcode#" year_past="#arguments.frmStruct.year_past#" post_amt="#local.TotalDiscount#" Invoice_Code="#local.invoicenumber#" tran_type="CD" tran_desc="#local.description#" tran_date="#DateFormat(now(),'mm/dd/yyyy')#" module=""/>
				    	<cfset local.TotalDiscount  = -1*local.TotalDiscount>
				    	<cfinvoke method="PostToGL" returnvariable="qPostToGL" account="#arguments.frmstruct.APGLAccount#" cv_code="#local.vendorcode#" year_past="#arguments.frmStruct.year_past#" post_amt="#local.TotalDiscount#" Invoice_Code="#local.invoicenumber#" tran_type="CD" tran_desc="#local.description#" tran_date="#DateFormat(now(),'mm/dd/yyyy')#" module=""/>
				    </cfif>
				</cfif>

		    	<cfset respStr = structNew()>
		    	<cfset respStr.res = 'success'>
		    	<cfset respStr.msg = "Payment have been voided.">
		    	<cfreturn respStr>
		    	<cfcatch>
		    		<cftransaction action="rollback">
		    		<cfset respStr = structNew()>
			    	<cfset respStr.res = 'error'>
			    	<cfset respStr.msg = "Something went wrong. Unable to void the payment.">
			    	<cfreturn respStr>
		    	</cfcatch>
		    </cftry>
		</cftransaction>
	</cffunction>

	<cffunction name="getCustomerPaymentsForVoid" access="public" returntype="query">

	    <cfquery name="qPayments" datasource="#variables.dsn#">
	    	SELECT 
	    		ARPT.CheckNumber,
				ARPT.Date,
				ARPT.CheckAmount,
				ARPT.CompanCode,
				ARPT.CustomerID
			FROM 
				[LMA Accounts Receivable Payment Detail] ARPT 
			WHERE ARPT.CompanyID = <cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar">	
			ORDER BY ARPT.CheckNumber,ARPT.InvoicNumber
	    </cfquery>
	    <cfreturn qPayments>
	</cffunction>

	<cffunction name="CheckLoadLimitReached" access="public" returntype="boolean">
	    <cfquery name="qCheck" datasource="#variables.dsn#">
	    	SELECT L.LoadID AS LoadCount FROM Loads L
			INNER JOIN CustomerOffices CO ON CO.CustomerID = L.CustomerID
			INNER JOIN Offices O ON O.OfficeID = CO.OfficeID
			WHERE MONTH(L.CreatedDateTime) = MONTH(GETDATE()) AND  YEAR(L.CreatedDateTime) = YEAR(GETDATE())
			AND O.CompanyID = <cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar">	
			GROUP BY L.LoadID
	    </cfquery>
	    <cfif qCheck.recordcount GTE 30>
		    <cfreturn 1>
		<cfelse>
			<cfreturn 0>
		</cfif>
	</cffunction>

	<cffunction name="updateDaysFilterCookies" access="public" returntype="void">
		<cfargument name="LoadsDaysFilter" required="yes" type="string">
		<cfargument name="FilterDays" required="yes" type="boolean">
		<cfargument name="Advanced" required="yes" type="boolean">

		<cfif arguments.Advanced>
			<cfif arguments.FilterDays>
				<cfcookie name="advFilterLoadsByDays" value="1" expires="never">
			<cfelse>
				<cfcookie name="advFilterLoadsByDays" value="0" expires="never">
			</cfif>
			<cfcookie name="advLoadsDaysFilter" value="#arguments.LoadsDaysFilter#" expires="never">
		<cfelse>
			<cfif arguments.FilterDays>
				<cfcookie name="FilterLoadsByDays" value="1" expires="never">
			<cfelse>
				<cfcookie name="FilterLoadsByDays" value="0" expires="never">
			</cfif>
			<cfcookie name="LoadsDaysFilter" value="#arguments.LoadsDaysFilter#" expires="never">
		</cfif>
		
	</cffunction>

	<cffunction name="ProcessCustomerPaymentData" access="public" returntype="query">
		<cfargument name="frmStruct" required="yes" type="struct">

		<cfquery name="qMasterLoads" datasource="#variables.dsn#">
			SELECT LoadID,LoadNumber FROM Loads L
			INNER JOIN CustomerOffices CO ON CO.CustomerID = L.CustomerID
			INNER JOIN Offices O ON O.OfficeID = CO.OfficeID
			WHERE O.CompanyID = <cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar">
			GROUP BY LoadID,LoadNumber
		</cfquery>

		<cfset var delimiter = chr(10)>
		<cfset var qryLoad = QueryNew("LoadID,LoadNumber,PmtRef,PmtDate,PmtAmount,AppliedAmt")>
		<cfset var rowNum = 1>
		<cfloop index="row" list="#arguments.frmStruct.LoadText#" delimiters="#delimiter#">
			<cfset array = listToArray(row,Chr(9))>
			<cfif ArrayIsDefined(array, 1) AND IsNumeric(trim(array[1]))>
				<cfquery dbtype="query" name="qGetLoadID">
					SELECT LoadID FROM qMasterLoads WHERE LoadNumber = <cfqueryparam value="#trim(array[1])#" cfsqltype="cf_sql_varchar">
				</cfquery>
				<cfif qGetLoadID.recordcount>
					<cfset QueryAddRow(qryLoad, 1)>
					<cfset QuerySetCell(qryLoad, "LoadID", qGetLoadID.LoadID, rowNum)>
					<cfset QuerySetCell(qryLoad, "LoadNumber", trim(array[1]), rowNum)>
					<cfif ArrayIsDefined(array, 2)>
						<cfset QuerySetCell(qryLoad, "PmtRef", trim(array[2]), rowNum)>
					</cfif>
					<cfif ArrayIsDefined(array, 3)>
						<cfset QuerySetCell(qryLoad, "PmtDate", trim(array[3]), rowNum)>
					</cfif>
					<cfif ArrayIsDefined(array, 4)>
						<cfset QuerySetCell(qryLoad, "PmtAmount", trim(array[4]), rowNum)>
					</cfif>
					<cfif ArrayIsDefined(array, 5)>
						<cfset QuerySetCell(qryLoad, "AppliedAmt", trim(array[5]), rowNum)>
					</cfif>
					<cfset rowNum++>
				</cfif>
			</cfif>
		</cfloop>
		<cfreturn qryLoad>
	</cffunction>

	<cffunction name="UpdateCustomerPayment" access="public" returntype="void">
		<cfargument name="frmStruct" required="yes" type="struct">

		<cfquery name="qLoad" datasource="#variables.dsn#">
			SELECT LoadID FROM Loads L
			INNER JOIN CustomerOffices CO ON CO.CustomerID = L.CustomerID
			INNER JOIN Offices O ON O.OfficeID = CO.OfficeID
			WHERE O.CompanyID = <cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar">
			AND LoadNumber = <cfqueryparam value="#arguments.frmStruct.LoadNumber#" cfsqltype="cf_sql_bigint">
		</cfquery>
		<cfset var pricingNotes = datetimeformat(now(),"m/d/yyyy h:mm tt")&" - "&session.adminUserName&" > Payment Received.">
		<cfif len(trim(arguments.frmStruct.PmtRef))>
			<cfset pricingNotes &= " Pmt Ref: #arguments.frmStruct.PmtRef#,">
		</cfif>
		<cfif len(trim(arguments.frmStruct.PmtDate))>
			<cfset pricingNotes &= " Pmt Date: #arguments.frmStruct.PmtDate#,">
		</cfif>
		<cfif len(trim(arguments.frmStruct.PmtAmount)) AND IsNumeric(replaceNoCase(replaceNoCase(arguments.frmStruct.PmtAmount,'$',''),',','','ALL'))>
			<cfset pricingNotes &= " Pmt Amount: #dollarformat(replaceNoCase(replaceNoCase(arguments.frmStruct.PmtAmount,'$',''),',','','ALL'))#,">
		</cfif>
		<cfif len(trim(arguments.frmStruct.AppliedAmt)) AND IsNumeric(replaceNoCase(replaceNoCase(arguments.frmStruct.AppliedAmt,'$',''),',','','ALL'))>
			<cfset pricingNotes &= " Applied Amt: #dollarformat(replaceNoCase(replaceNoCase(arguments.frmStruct.AppliedAmt,'$',''),',','','ALL'))#,">
		</cfif>

		<cfif mid(pricingNotes,len(pricingNotes),1) EQ ",">
			<cfset pricingNotes = RemoveChars(pricingNotes, len(pricingNotes), 1)>
		</cfif>

		<cfif qLoad.recordcount>
			<cfquery name="qUpdateLoad" datasource="#variables.dsn#">						
				UPDATE LOADS
				SET 
				CustomerPaid = 1,
				StatusTypeID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.frmStruct.StatusTypeID#">,
				pricingNotes = '#pricingNotes#'+CHAR(13)+pricingNotes					
				WHERE loadId = <cfqueryparam cfsqltype="cf_sql_varchar" value="#qLoad.LoadID#">
			</cfquery>
		</cfif>

		<cfcookie name="CustomerPaidLoadStatus" value="#arguments.frmStruct.StatusTypeID#" expires="never">
	</cffunction>

	<cffunction name="uploadCustomerPaymentCsv" access="public" output="yes" returnformat="json">
		<cftry>
			<cfset var row="">
			<cfset var response = structNew()>	

			<cfset var rootPath = expandPath('../fileupload/tempCSV/')>
			<cfif not directoryExists(rootPath)>
				<cfdirectory action = "create" directory = "#rootPath#" > 
			</cfif>

			<cffile action="upload" filefield="file" destination="#rootPath#" nameConflict="MakeUnique" result=uploadedFile>
			<cfif uploadedFile.SERVERFILEEXT NEQ 'csv'>
				<cfset response.success = 0>
				<cfset response.message = "Invalid file extension.Please upload CSV file.">
				<cfreturn response>
			</cfif>
			<cfset var fileName = uploadedFile.SERVERFILE>
			<cffile action="read" file="#rootPath##fileName#" variable="csvfile">

			<cfset var currentRow = 1>
			<cfset var LoadText = "">
			<cfloop index="row" list="#csvfile#" delimiters="#chr(10)##chr(13)#">
				<cfif currentRow NEQ 1>
					<cfset qryRow = CSVToQuery(row)>
					<cfset LoadNumber= qryRow.column_1>
					<cfset PmtRef= qryRow.column_2>
					<cfset PmtDate= qryRow.column_3>
					<cfset PmtAmount = qryRow.column_4>
					<cfset AppliedAmt = qryRow.column_5>
					<cfif len(trim(LoadText))>
						<cfset LoadText &= chr(10)>
					</cfif>
					<cfset LoadText &= LoadNumber & chr(9) & PmtRef & chr(9) & PmtDate & chr(9) & PmtAmount & chr(9) & AppliedAmt>
				</cfif>
				<cfset currentRow++>
			</cfloop>

			<cfif fileexists("#rootPath##fileName#")>
				<cffile action="delete" file="#rootPath##fileName#">
			</cfif>
			<cfset response.success = 1>
			<cfset response.message = LoadText>
			<cfreturn response>
			<cfcatch>
				<cfset CreateLogError(cfcatch)>
				<cfset response.success = 0>
				<cfset response.message = "Something went wrong. Please ry again later.">
				<cfreturn response>
			</cfcatch>
		</cftry>
	</cffunction>

	<cffunction name="UpdateLoadPricingNotes" access="public" returntype="void">
		<cfargument name="LoadID" required="yes" type="string">
		<cfargument name="PricingNotes" required="yes" type="string">

		<cfquery name="qUpdateLoad" datasource="#variables.dsn#">						
			UPDATE LOADS
			SET 
			PricingNotes = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.PricingNotes#">
			WHERE LoadID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.LoadID#">
		</cfquery>
	</cffunction>
	<cffunction name="UpdateDefaultBillFromCompany" access="public" returntype="void">
		<cfargument name="CompanyID" required="yes" type="any">
		<cfargument name="checked" required="yes" type="any">

		<cfquery name="qUpdateDefaultBillFromCompany" datasource="#variables.dsn#">						
			UPDATE SystemConfig
			SET 
			DefaultBillFromAsCompany = <cfqueryparam cfsqltype="cf_sql_bit" value="#arguments.checked#">
			WHERE CompanyID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.CompanyID#">
		</cfquery>
	</cffunction>
	<cffunction name="getBOLReport" access="public" returntype="any">
		<cfargument name="LoadID" required="yes" type="any">
		<cfargument name="CompanyID" required="yes" type="any">
		<cfquery name="qGetCompany" datasource="#dsn#">
			select CompanyCode from Companies WHERE CompanyID = <cfqueryparam value="#arguments.CompanyID#" cfsqltype="cf_sql_varchar">
		</cfquery>
		<cfquery name="qGetSystemconfig" datasource="#dsn#">
			select UseNonFeeAccOnBOL from SystemConfig WHERE CompanyID = <cfqueryparam value="#arguments.CompanyID#" cfsqltype="cf_sql_varchar">
		</cfquery>
		<cfif structkeyexists(url,"loadno") or (structkeyexists(url,"loadid")) AND isValid("regex", url.loadid,'^[{]?[0-9a-fA-F]{8}-([0-9a-fA-F]{4}-){3}[0-9a-fA-F]{12}[}]?$') OR NOT len(trim(url.loadid))>	
			<cfquery name="qBOLReport" datasource="#dsn#">
        SELECT         l.LoadID, l.LoadNumber, CASE WHEN ISNULL(l.CustomerPONo,'')<>'' THEN l.CustomerPONo ELSE l.BOLREPO END AS RefNo, l.Address AS custaddress, l.City AS custcity, l.StateCode AS custstate, l.PostalCode AS custpostalcode, 
                         l.Phone AS custphone, l.Fax AS custfax, l.CellNo AS custcell, l.CustName AS custname, l.EmergencyResponseNo, l.CODAmt, l.CODFee, l.DeclaredValue, l.Notes,

                        CASE WHEN (LEN(TRIM(stops.shipperStopName)) = 0 AND LEN(TRIM(stops.shipperLocation)) = 0 AND LEN(TRIM(stops.shipperCity)) = 0 AND LEN(TRIM(stops.ShipperState)) = 0 AND LEN(TRIM(stops.ShipperState)) = 0 )
                         THEN
                            FirstPick.shipperState
                         ELSE
                         stops.shipperState
                         END AS shipperState,
                         CASE WHEN (LEN(TRIM(stops.shipperStopName)) = 0 AND LEN(TRIM(stops.shipperLocation)) = 0 AND LEN(TRIM(stops.shipperCity)) = 0 AND LEN(TRIM(stops.ShipperState)) = 0 AND LEN(TRIM(stops.ShipperState)) = 0 )
                         THEN
                            FirstPick.shipperCity
                         ELSE
                         stops.shipperCity
                         END AS shipperCity,
                         stops.consigneeState, stops.consigneeCity, carr.CarrierName, stops.LoadStopID, stops.StopNo, 
                         stops.shipperStopDate AS PickupDate, stops.shipperStopTime AS PickupTime, stops.consigneeStopDate AS DeliveryDate, stops.consigneeStopTime AS DeliveryTime, 
                        CASE WHEN (LEN(TRIM(stops.shipperStopName)) = 0 AND LEN(TRIM(stops.shipperLocation)) = 0 AND LEN(TRIM(stops.shipperCity)) = 0 AND LEN(TRIM(stops.ShipperState)) = 0 AND LEN(TRIM(stops.ShipperState)) = 0 )
                         THEN
                            FirstPick.shipperStopName
                         ELSE
                         stops.shipperStopName
                         END AS shipperStopName,
                         stops.consigneeStopName,
                         CASE WHEN (LEN(TRIM(stops.shipperStopName)) = 0 AND LEN(TRIM(stops.shipperLocation)) = 0 AND LEN(TRIM(stops.shipperCity)) = 0 AND LEN(TRIM(stops.ShipperState)) = 0 AND LEN(TRIM(stops.ShipperState)) = 0 )

                         THEN
                            FirstPick.shipperLocation
                         ELSE
                         stops.shipperLocation
                         END AS shipperLocation,
                         stops.consigneeLocation, stops.shipperPostalCode, stops.consigneePostalCode, 
                        CASE WHEN (LEN(TRIM(stops.shipperStopName)) = 0 AND LEN(TRIM(stops.shipperLocation)) = 0 AND LEN(TRIM(stops.shipperCity)) = 0 AND LEN(TRIM(stops.ShipperState)) = 0 AND LEN(TRIM(stops.ShipperState)) = 0 )

                         THEN
                            FirstPick.shipperContactPerson
                         ELSE
                         stops.shipperContactPerson
                         END AS shipperContactPerson,
                         stops.consigneeContactPerson, 
                         CASE WHEN (LEN(TRIM(stops.shipperStopName)) = 0 AND LEN(TRIM(stops.shipperLocation)) = 0 AND LEN(TRIM(stops.shipperCity)) = 0 AND LEN(TRIM(stops.ShipperState)) = 0 AND LEN(TRIM(stops.ShipperState)) = 0 )

                         THEN
                            FirstPick.shipperPhone
                         ELSE
                         stops.shipperPhone
                         END AS shipperPhone,

                         CASE WHEN (LEN(TRIM(stops.shipperStopName)) = 0 AND LEN(TRIM(stops.shipperLocation)) = 0 AND LEN(TRIM(stops.shipperCity)) = 0 AND LEN(TRIM(stops.ShipperState)) = 0 AND LEN(TRIM(stops.ShipperState)) = 0 )

                         THEN
                            FirstPick.shipperPhoneExt
                         ELSE
                         stops.shipperPhoneExt
                         END AS shipperPhoneExt,

                         stops.consigneePhone, 
                         stops.consigneePhoneExt, 
                        CASE WHEN (LEN(TRIM(stops.shipperStopName)) = 0 AND LEN(TRIM(stops.shipperLocation)) = 0 AND LEN(TRIM(stops.shipperCity)) = 0 AND LEN(TRIM(stops.ShipperState)) = 0 AND LEN(TRIM(stops.ShipperState)) = 0 )

                         THEN
                            FirstPick.shipperFax
                         ELSE
                         stops.shipperFax
                         END AS shipperFax,
                         stops.consigneeFax, 
                         stops.shipperEmailID, stops.consigneeEmailID, stops.shipperBlind, stops.consigneeBlind, stops.shipperDriverName, stops.consigneeDriverName, BOLs.SrNo, 
                         ISNULL(BOLs.Qty, 0) AS Qty, BOLs.Description, ISNULL(BOLs.Weight, 0) AS Weight, BOLs.classid, BOLs.Hazmat, BOLs.LoadStopIDBOL, CarrierTerms.CarrierTerms, 
                         dbo.Companies.CompanyName, dbo.Companies.address, dbo.Companies.address2, dbo.Companies.city, dbo.Companies.state, dbo.Companies.zipCode,CASE WHEN ISNULL(dbo.Employees.Telephone ,'') = '' THEN case when isnull(offi.ContactNo ,'') = '' then dbo.Companies.phone else offi.ContactNo End ELSE dbo.Employees.Telephone END as Phone
                         ,case when isnull(dbo.Companies.fax ,'') = '' then dbo.Companies.fax
                         else offi.faxno End as fax,dbo.Companies.CompanyCode,(SELECT CompanyLogoName
                               FROM            dbo.SystemConfig where companyID = <cfqueryparam value="#arguments.CompanyID#" cfsqltype="cf_sql_varchar">) AS CompanyLogoName,consigneeReleaseNo,shipperReleaseNo
					FROM            dbo.Loads AS l 
					INNER JOIN
					dbo.Employees ON L.DispatcherID = dbo.Employees.EmployeeID
					LEFT OUTER JOIN
                             (SELECT        a.LoadID, a.LoadStopID, a.StopNo, a.NewCarrierID, a.NewOfficeID, a.City AS shipperCity, b.City AS consigneeCity, a.CustName AS shipperStopName, 
									b.CustName AS consigneeStopName, a.Address AS shipperLocation, b.Address AS consigneeLocation, a.PostalCode AS shipperPostalCode, 
									b.PostalCode AS consigneePostalCode, a.ContactPerson AS shipperContactPerson, b.ContactPerson AS consigneeContactPerson, 
									a.Phone AS shipperPhone,a.PhoneExt AS shipperPhoneExt, b.Phone AS consigneePhone,b.PhoneExt AS consigneePhoneExt, a.Fax AS shipperFax, b.Fax AS consigneeFax, a.EmailID AS shipperEmailID, 
									b.EmailID AS consigneeEmailID, a.StopDate AS shipperStopDate, b.StopDate AS consigneeStopDate, a.StopTime AS shipperStopTime, 
									b.StopTime AS consigneeStopTime, a.TimeIn AS shipperStopTimeIn, b.TimeIn AS consigneeStopTimeIn, a.TimeOut AS shipperStopTimeOut, 
									b.TimeOut AS consigneeStopTimeOut, a.ReleaseNo AS shipperReleaseNo, b.ReleaseNo AS consigneeReleaseNo, a.Blind AS shipperBlind, 
									b.Blind AS consigneeBlind, a.Instructions AS shipperInstructions, b.Instructions AS consigneeInstructions, a.Directions AS shipperDirections, 
									b.Directions AS consigneeDirections, a.LoadStopID AS shipperLoadStopID, b.LoadStopID AS consigneeLoadStopID, 
									a.NewBookedWith AS shipperBookedWith, b.NewBookedWith AS consigneeBookedWith, a.NewEquipmentID AS shipperEquipmentID, 
									b.NewEquipmentID AS consigneeEquipmentID, a.NewDriverName AS shipperDriverName, b.NewDriverName AS consigneeDriverName, 
									a.NewDriverCell AS shipperDriverCell, b.NewDriverCell AS consigneeDriverCell, a.NewTruckNo AS shipperTruckNo, 
									b.NewTruckNo AS consigneeTruckNo, a.NewTrailorNo AS shipperTrailorNo, b.NewTrailorNo AS consigneeTrailorNo, a.RefNo AS shipperRefNo, 
									b.RefNo AS consigneeRefNo, a.Miles AS shipperMiles, b.Miles AS consigneeMiles, a.CustomerID AS shipperCustomerID, 
									b.CustomerID AS consigneeCustomerID, a.StateCode AS shipperState, b.StateCode AS consigneeState
                               FROM            dbo.LoadStops AS a INNER JOIN
                                                         dbo.LoadStops AS b ON a.LoadID = b.LoadID AND a.StopNo = b.StopNo
                               WHERE        (a.LoadID = <cfqueryparam value="#arguments.loadID#" cfsqltype="cf_sql_varchar">) AND (a.LoadType = 1) AND (b.LoadType = 2)) AS stops ON 
                         stops.LoadID = l.LoadID LEFT OUTER JOIN
                          ( SELECT c.LoadID,c.CustName AS shipperStopName, c.Address AS shipperLocation,c.City AS shipperCity,c.StateCode AS shipperState,c.PostalCode AS shipperPostalCode,c.Phone AS shipperPhone,c.PhoneExt AS shipperPhoneExt,c.Fax AS shipperFax, c.ContactPerson AS shipperContactPerson  FROM dbo.LoadStops AS c WHERE c.LoadID = <cfqueryparam value="#arguments.loadID#" cfsqltype="cf_sql_varchar"> AND c.StopNo = 0 AND c.LoadType = 1   ) AS FirstPick ON FirstPick.LoadID = l.LoadID LEFT OUTER JOIN
                             (SELECT        CarrierID, CarrierName
                               FROM            dbo.Carriers) AS carr ON carr.CarrierID = stops.NewCarrierID LEFT OUTER JOIN
                             (SELECT        CarrierTerms
                               FROM            dbo.SystemConfig where companyID = <cfqueryparam value="#arguments.CompanyID#" cfsqltype="cf_sql_varchar">) AS CarrierTerms ON 1 = 1 
							<cfif qGetSystemconfig.UseNonFeeAccOnBOL EQ 1>
                                LEFT OUTER JOIN
                                (SELECT ISNULL(dbo.LoadStopCommodities.SrNo, '') AS SrNo, ISNULL(dbo.LoadStopCommodities.Qty, 0) AS Qty, ISNULL(dbo.LoadStopCommodities.Description, '') AS Description, 
                                                         ISNULL(dbo.LoadStopCommodities.Weight, 0) AS Weight, dbo.CommodityClasses.ClassName AS classid,'' AS Hazmat, 
                                                        '#url.LoadID#' AS LoadStopIDBOL,
                                                        dbo.LoadStopCommodities.LoadStopID AS LoadStopID
                                                        ,dbo.LoadStopCommodities.FEE
                                FROM            dbo.LoadStopCommodities LEFT OUTER JOIN
                                                         dbo.CommodityClasses ON dbo.LoadStopCommodities.ClassID = dbo.CommodityClasses.ClassID) AS BOLs ON BOLs.FEE=0 AND BOLs.LoadStopID = stops.LoadStopID and (len(BOLs.Description) <> 0 or BOLs.qty>0 or BOLs.weight > 0  or len(BOLs.classid) <> 0 or len(BOLs.Hazmat) <> 0)
							<cfelse>
                                LEFT OUTER JOIN
                                (SELECT        ISNULL(dbo.LoadStopsBOL.SrNo, '') AS SrNo, ISNULL(dbo.LoadStopsBOL.Qty, 0) AS Qty, ISNULL(dbo.LoadStopsBOL.Description, '') AS Description, 
                                                         ISNULL(dbo.LoadStopsBOL.Weight, 0) AS Weight, dbo.CommodityClasses.ClassName AS classid, ISNULL(dbo.LoadStopsBOL.Hazmat, '') AS Hazmat, 
                                                         dbo.LoadStopsBOL.loadStopIdBOL AS LoadStopIDBOL
                                FROM            dbo.LoadStopsBOL LEFT OUTER JOIN
                                                         dbo.CommodityClasses ON dbo.LoadStopsBOL.ClassID = dbo.CommodityClasses.ClassID) AS BOLs ON BOLs.LoadStopIDBOL = l.LoadID and (len(BOLs.Description) <> 0 or BOLs.qty>0 or BOLs.weight > 0  or len(BOLs.classid) <> 0 or len(BOLs.Hazmat) <> 0)
                            </cfif>
                             left outer join
                         dbo.Companies on dbo.Companies.companyID = <cfqueryparam value="#arguments.CompanyID#" cfsqltype="cf_sql_varchar"> left outer join (select top 1 ContactNo,FaxNo,officeid,companyID from offices where companyID = <cfqueryparam value="#arguments.CompanyID#" cfsqltype="cf_sql_varchar">) as offi  on offi.companyID=Companies.companyID
				WHERE        (l.LoadID = <cfqueryparam value="#arguments.loadID#" cfsqltype="cf_sql_varchar">) AND dbo.Companies.companyID = <cfqueryparam value="#arguments.CompanyID#" cfsqltype="cf_sql_varchar">
				ORDER BY l.LoadNumber ,StopNo
		</cfquery>
		<cfreturn qBOLReport>
		</cfif>
	</cffunction>
	<cffunction name="getBOLReportshort" access="public" returntype="any">
		<cfargument name="LoadID" required="yes" type="any">
		<cfargument name="CompanyID" required="yes" type="any">
		<cfquery name="qGetCompany" datasource="#dsn#">
			select CompanyCode from Companies WHERE CompanyID = <cfqueryparam value="#arguments.CompanyID#" cfsqltype="cf_sql_varchar">
		</cfquery>
		<cfquery name="qGetSystemconfig" datasource="#dsn#">
			select UseNonFeeAccOnBOL from SystemConfig WHERE CompanyID = <cfqueryparam value="#arguments.CompanyID#" cfsqltype="cf_sql_varchar">
		</cfquery>
	<cfif structkeyexists(url,"loadno") or structkeyexists(url,"loadid")>
    	<cfquery name="qBOLReportShort" datasource="#dsn#">
       		 SELECT l.LoadID, l.LoadNumber, CASE WHEN ISNULL(l.CustomerPONo,'')<>'' THEN l.CustomerPONo ELSE l.BOLREPO END AS RefNo, l.Address AS custaddress, l.City AS custcity, l.StateCode AS custstate, l.PostalCode AS custpostalcode, 
                         l.Phone AS custphone, l.Fax AS custfax, l.CellNo AS custcell, l.CustName AS custname, l.EmergencyResponseNo, l.CODAmt, l.CODFee, l.DeclaredValue, l.Notes, 
                         stops.shipperState, stops.shipperCity, stops.consigneeState, stops.consigneeCity, carr.CarrierName, stops.LoadStopID, stops.StopNo, 
                         l.NewPickupDate AS PickupDate, l.NewPickupTime AS PickupTime, l.NewDeliveryDate AS DeliveryDate, l.NewDeliveryTime AS DeliveryTime, 
                         stops.shipperStopName, stops.consigneeStopName, stops.shipperLocation, stops.consigneeLocation, stops.shipperPostalCode, stops.consigneePostalCode, 
                         stops.shipperContactPerson, stops.consigneeContactPerson, stops.shipperPhone,stops.shipperPhoneExt, stops.consigneePhone,stops.consigneePhoneExt, stops.shipperFax, stops.consigneeFax, 
                         stops.shipperEmailID, stops.consigneeEmailID, stops.shipperBlind, stops.consigneeBlind, stops.shipperDriverName, stops.consigneeDriverName, BOL.SrNo, 
                         ISNULL(BOL.Qty, 0) AS Qty, BOL.Description, ISNULL(BOL.Weight, 0) AS Weight, BOL.classid, BOL.Hazmat, BOL.LoadStopIDBOL, CarrierTerms.CarrierTerms, 
                         dbo.Companies.CompanyName, dbo.Companies.address, dbo.Companies.address2, dbo.Companies.city, dbo.Companies.state, dbo.Companies.zipCode,CASE WHEN ISNULL(dbo.Employees.Telephone ,'') = '' THEN case when isnull(offi.ContactNo ,'') = '' then dbo.Companies.phone else offi.ContactNo End ELSE dbo.Employees.Telephone END as Phone
                         ,case when isnull(dbo.Companies.fax ,'') = '' then dbo.Companies.fax
                         else offi.faxno End as fax,
                        ( (select top 1 NewBookedWith from loadstops where loadid = l.loadid and loadtype=1 order by StopNo)
                         +'/'+carr.CarrierName) as shipperBookedWith, carr.EmailID As carrEmail,
                        l.BOLFromName,l.BOLFromTel,l.BOLFromEmail,(l.BOLREName+' / PO## '+l.BOLREPO) as BOLRE
                        ,ShortBOLTerms.ShortBOLTerms,dbo.Companies.CompanyCode,(SELECT CompanyLogoName
                               FROM dbo.SystemConfig where companyID = <cfqueryparam value="#arguments.CompanyID#" cfsqltype="cf_sql_varchar">) AS CompanyLogoName,C.CustomerName,C.Location AS CustomerAddress,C.City AS CustomerCity,C.statecode AS CustomerState,C.ZipCode AS CustomerZipCode,consigneeReleaseNo,shipperReleaseNo
				FROM            dbo.Loads AS l 
				INNER JOIN Customers C On C.CustomerID = l.CustomerID
				INNER JOIN
								dbo.Employees ON L.DispatcherID = dbo.Employees.EmployeeID LEFT OUTER JOIN
									(SELECT        a.LoadID, a.LoadStopID, a.StopNo, a.NewCarrierID, a.NewOfficeID, a.City AS shipperCity, b.City AS consigneeCity, a.CustName AS shipperStopName, 
									b.CustName AS consigneeStopName, a.Address AS shipperLocation, b.Address AS consigneeLocation, a.PostalCode AS shipperPostalCode, 
									b.PostalCode AS consigneePostalCode, a.ContactPerson AS shipperContactPerson, b.ContactPerson AS consigneeContactPerson, 
									a.Phone AS shipperPhone, b.Phone AS consigneePhone, a.PhoneExt AS shipperPhoneExt, b.PhoneExt AS consigneePhoneExt, a.Fax AS shipperFax, b.Fax AS consigneeFax, a.EmailID AS shipperEmailID, 
									b.EmailID AS consigneeEmailID, a.StopDate AS shipperStopDate, b.StopDate AS consigneeStopDate, a.StopTime AS shipperStopTime, 
									b.StopTime AS consigneeStopTime, a.TimeIn AS shipperStopTimeIn, b.TimeIn AS consigneeStopTimeIn, a.TimeOut AS shipperStopTimeOut, 
									b.TimeOut AS consigneeStopTimeOut, a.ReleaseNo AS shipperReleaseNo, b.ReleaseNo AS consigneeReleaseNo, a.Blind AS shipperBlind, 
									b.Blind AS consigneeBlind, a.Instructions AS shipperInstructions, b.Instructions AS consigneeInstructions, a.Directions AS shipperDirections, 
									b.Directions AS consigneeDirections, a.LoadStopID AS shipperLoadStopID, b.LoadStopID AS consigneeLoadStopID, 
									a.NewBookedWith AS shipperBookedWith, b.NewBookedWith AS consigneeBookedWith, a.NewEquipmentID AS shipperEquipmentID, 
									b.NewEquipmentID AS consigneeEquipmentID, a.NewDriverName AS shipperDriverName, b.NewDriverName AS consigneeDriverName, 
									a.NewDriverCell AS shipperDriverCell, b.NewDriverCell AS consigneeDriverCell, a.NewTruckNo AS shipperTruckNo, 
									b.NewTruckNo AS consigneeTruckNo, a.NewTrailorNo AS shipperTrailorNo, b.NewTrailorNo AS consigneeTrailorNo, a.RefNo AS shipperRefNo, 
									b.RefNo AS consigneeRefNo, a.Miles AS shipperMiles, b.Miles AS consigneeMiles, a.CustomerID AS shipperCustomerID, 
									b.CustomerID AS consigneeCustomerID, a.StateCode AS shipperState, b.StateCode AS consigneeState
									FROM  dbo.LoadStops AS a INNER JOIN
									dbo.LoadStops AS b ON a.LoadID = b.LoadID AND a.StopNo = b.StopNo
									WHERE (a.LoadID = <cfqueryparam value="#arguments.loadID#" cfsqltype="cf_sql_varchar">) AND (a.LoadType = 1 AND a.StopNo=0) AND (b.LoadType = 2  AND b.StopNo=0)) AS stops ON 
									stops.LoadID = l.LoadID LEFT OUTER JOIN
									(SELECT CarrierID, CarrierName, EmailID
									FROM dbo.Carriers) AS carr ON carr.CarrierID = stops.NewCarrierID LEFT OUTER JOIN
									(SELECT CarrierTerms
									FROM dbo.SystemConfig where companyID = <cfqueryparam value="#arguments.CompanyID#" cfsqltype="cf_sql_varchar">) AS CarrierTerms ON 1 = 1 LEFT OUTER JOIN
									(SELECT ShortBOLTerms
									FROM dbo.SystemConfig where companyID = <cfqueryparam value="#arguments.CompanyID#" cfsqltype="cf_sql_varchar">) AS ShortBOLTerms ON 1 = 1 
									<cfif qGetSystemconfig.UseNonFeeAccOnBOL EQ 1>
										LEFT OUTER JOIN
										(SELECT ISNULL(dbo.LoadStopCommodities.SrNo, '') AS SrNo, ISNULL(dbo.LoadStopCommodities.Qty, 0) AS Qty, ISNULL(dbo.LoadStopCommodities.Description, '') AS Description, 
											ISNULL(dbo.LoadStopCommodities.Weight, 0) AS Weight, dbo.CommodityClasses.ClassName AS classid,'' AS Hazmat, 
											<cfqueryparam value="#arguments.loadID#" cfsqltype="cf_sql_varchar"> AS LoadStopIDBOL,
											dbo.LoadStopCommodities.LoadStopID AS LoadStopID
											,dbo.LoadStopCommodities.FEE
										FROM dbo.LoadStopCommodities LEFT OUTER JOIN
											dbo.CommodityClasses ON dbo.LoadStopCommodities.ClassID = dbo.CommodityClasses.ClassID) AS BOL ON BOL.FEE=0 AND BOL.LoadStopID = stops.LoadStopID and (len(bol.Description) <> 0 or bol.qty>0 or bol.weight > 0  or len(bol.classid) <> 0 or len(bol.Hazmat) <> 0)
									<cfelse>
										LEFT OUTER JOIN
										(SELECT        ISNULL(dbo.LoadStopsBOL.SrNo, '') AS SrNo, ISNULL(dbo.LoadStopsBOL.Qty, 0) AS Qty, ISNULL(dbo.LoadStopsBOL.Description, '') AS Description, 
											ISNULL(dbo.LoadStopsBOL.Weight, 0) AS Weight, dbo.CommodityClasses.ClassName AS classid, ISNULL(dbo.LoadStopsBOL.Hazmat, '') AS Hazmat, 
											dbo.LoadStopsBOL.loadStopIdBOL AS LoadStopIDBOL
										FROM dbo.LoadStopsBOL LEFT OUTER JOIN
											dbo.CommodityClasses ON dbo.LoadStopsBOL.ClassID = dbo.CommodityClasses.ClassID) AS BOL ON BOL.LoadStopIDBOL = l.LoadID and (len(bol.Description) <> 0 or bol.qty>0 or bol.weight > 0  or len(bol.classid) <> 0 or len(bol.Hazmat) <> 0)
									</cfif>
									left outer join
								dbo.Companies on dbo.Companies.companyID = <cfqueryparam value="#arguments.CompanyID#" cfsqltype="cf_sql_varchar"> left outer join (select top 1 ContactNo,FaxNo,officeid,companyID from offices where companyID = <cfqueryparam value="#arguments.CompanyID#" cfsqltype="cf_sql_varchar">) as offi  on offi.companyID=Companies.companyID
		WHERE        (l.LoadID = <cfqueryparam value="#arguments.loadID#" cfsqltype="cf_sql_varchar">) AND dbo.Companies.companyID = <cfqueryparam value="#arguments.CompanyID#" cfsqltype="cf_sql_varchar">
		ORDER BY l.LoadNumber
    </cfquery>
	<cfreturn qBOLReportShort>
	</cfif>
	</cffunction>

	<cffunction name="uploadCSVCustomer" access="public" output="yes" returnformat="json">
		<cftry>
			<cfset row="">
			<cfset response = structNew()>	

			<cfset rootPath = expandPath('../fileupload/tempCSV/')>
			<cfif not directoryExists(rootPath)>
				<cfdirectory action = "create" directory = "#rootPath#" > 
			</cfif>

			<cffile action="upload" filefield="file" destination="#rootPath#" nameConflict="MakeUnique" result=uploadedFile>

			<cfif uploadedFile.SERVERFILEEXT NEQ 'csv'>
				<cfset response.success = 0>
				<cfset response.message = "Invalid file extension.Please upload CSV file.">
				<cfreturn response>
			</cfif>

			<cfset fileName = uploadedFile.SERVERFILE>
		
			<cffile action="read" file="#rootPath##fileName#" variable="csvfile">

			<cfset validHeader = "Carrier Flat Rate,Customer Flat Rate,Equipment Name,Agent Login Name,Dispatcher Login Name,Pickup Date,Delivery Date,PRO##,BOL##,PONumber,Pickup##,Shipper Name,Shipper Address,Shipper City,Shipper State,Shipper Zip,Delivery##,Destination Name,Destination Address,Destination City,Destination State,Destination Zip,Notes,Dispatch Notes,Carrier Notes,Commodity Qty,Commidity Type,Commodity Description,Commodity Fee,Commodity Weight,Commodity Class,Commodity Cust Rate,Commodity Carr Rate,Commodity Cust Percent,LTL,Equipment Length">
			<cfset uploadedHeader = listgetAt('#csvfile#',1, '#chr(10)##chr(13)#')>
			<cfif Compare(validHeader, uploadedHeader) NEQ 0>
				<cfset response.success = 0>
				<cfset response.message = "Invalid header format.">
				<cfreturn response>
			</cfif>

			<cfquery name="qGetEquipmentNames" datasource="#variables.dsn#">
				SELECT trim(EquipmentName) AS EquipmentName,EquipmentID FROM Equipments WHERE CompanyID = <cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar">
			</cfquery>

			<cfquery name="qGetSalesperson" datasource="#variables.dsn#">
				SELECT EmployeeID,Name FROM Employees 
				INNER JOIN Roles ON Roles.RoleID = Employees.RoleID
				INNER JOIN Offices ON Employees.OfficeID = Offices.OfficeID
				WHERE Roles.RoleValue IN ('Sales Representative','Manager','Dispatcher','Administrator','Central Dispatcher')
				AND Offices.CompanyID = <cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar">
				AND Roles.CompanyID = <cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar">
			</cfquery>

			<cfquery name="qGetEmployee" datasource="#variables.dsn#">
				SELECT Name FROM employees 
				INNER JOIN Offices ON Employees.OfficeID = Offices.OfficeID
				WHERE LoginID = <cfqueryparam value="#session.AdminUserName#" cfsqltype="cf_sql_varchar">
				AND Offices.CompanyID = <cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar">
			</cfquery>

			<cfquery name="qGetUnits" datasource="#variables.dsn#">
				SELECT UnitName,UnitID FROM Units WHERE CompanyID = <cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar">
			</cfquery>

			<cfquery name="qGetClasses" datasource="#variables.dsn#">
				SELECT ClassName,ClassID FROM CommodityClasses WHERE CompanyID = <cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar">
			</cfquery>

			<cfset var insStatusTypeID = "">
			<cfquery name="qGetStatus" datasource="#variables.dsn#">
				SELECT StatusTypeID FROM LoadStatusTypes WHERE StatusText = '0.1 SPOT' AND CompanyID = <cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar">
			</cfquery>

			<cfif qGetStatus.recordcount>
				<cfset insStatusTypeID = qGetStatus.StatusTypeID>
			<cfelse>
				<cfquery name="qGetStatus" datasource="#variables.dsn#">
					SELECT newid() AS StatusTypeID
				</cfquery>
				<cfset insStatusTypeID = qGetStatus.StatusTypeID>	
				<cfquery name="qInsStatus" datasource="#variables.dsn#">
					INSERT INTO LoadStatusTypes(StatusTypeID,StatusOrder,StatusText,StatusType,HasNotes,IsActive,CreatedDateTime,LastModifiedDateTime,CreatedBy,LastModifiedBy,ColorCode,Filter,ForceNextStatus,SystemUpdated,AllowOnMobileWebApp,CompanyID)
					VALUES(
						<cfqueryparam value="#insStatusTypeID#" cfsqltype="cf_sql_varchar">
						,99
						,'0.1 SPOT'
						,1
						,0
						,1
						,getdate()
						,getdate()
						,<cfqueryparam value="#session.AdminUserName#" cfsqltype="cf_sql_varchar">
						,<cfqueryparam value="#session.AdminUserName#" cfsqltype="cf_sql_varchar">
						,'87de78'
						,1
						,0
						,0
						,0
						,<cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar">
					)

					UPDATE Roles SET EditableStatuses = EditableStatuses + ',0.1 SPOT' 
					WHERE CompanyID = <cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar"> AND EditableStatuses NOT LIKE '%0.1 SPOT%' AND RoleValue = 'Administrator'

					INSERT INTO agentsLoadTypes VALUES (
						<cfqueryparam value="#session.EmpID#" cfsqltype="cf_sql_varchar">
						,<cfqueryparam value="#insStatusTypeID#" cfsqltype="cf_sql_varchar">
						)
				</cfquery>

				<cfset session.editablestatuses &= ',0.1 SPOT'>
			</cfif>

			<!--- <cfset validCustCode = valuelist(qGetCustomerCodes.CustomerCode)> --->

			<cfset currentRow = 1>
			<cfset bitImportedAll = 1>
			<cfloop index="row" list="#csvfile#" delimiters="#chr(10)##chr(13)#">
				<cfif currentRow NEQ 1>
					<cfset qryRow = CSVToQuery(row)>

					<cfset CarrierFlatRate = ReplaceNoCase(ReplaceNoCase(qryRow.column_1,'$','','ALL'),',','','ALL')>
					<cfset CustomerFlatRate = ReplaceNoCase(ReplaceNoCase(qryRow.column_2,'$','','ALL'),',','','ALL')>

					<cfif NOT len(trim(CarrierFlatRate))>
						<cfset CarrierFlatRate = 0>
					</cfif>

					<cfif NOT len(trim(CustomerFlatRate))>
						<cfset CustomerFlatRate = 0>
					</cfif>

					<cfset EquipmentName = qryRow.column_3>
					<cfif len(trim(qryRow.column_4))>
						<cfset AgentLoginName = listGetAt(qryRow.column_4, 1)>
					<cfelse>
						<cfset AgentLoginName = qryRow.column_4>
					</cfif>
					<cfif len(trim(qryRow.column_5))>
						<cfset DispatcherLoginName = listGetAt(qryRow.column_5, 1)>
					<cfelse>
						<cfset DispatcherLoginName = qryRow.column_5>
					</cfif>
					<cfset PickupDate= qryRow.column_6>
					<cfset DeliveryDate = qryRow.column_7>
					<cfset PRO = qryRow.column_8>
					<cfset BOL = qryRow.column_9>
					<cfset PO = qryRow.column_10>
					<cfset PickupNo = qryRow.column_11>
					<cfset ShipperName = qryRow.column_12>
					<cfset ShipperAddress = qryRow.column_13>
					<cfset ShipperCity = qryRow.column_14>
					<cfset ShipperState = qryRow.column_15>
					<cfset ShipperZip = qryRow.column_16>
					<cfset DeliveryNo = qryRow.column_17>
					<cfset DestinationName = qryRow.column_18>
					<cfset DestinationAddress = qryRow.column_19>
					<cfset DestinationCity = qryRow.column_20>
					<cfset DestinationState = qryRow.column_21>
					<cfset DestinationZip = qryRow.column_22>
					<cfset NewNotes = qryRow.column_23>
					<cfset NewDispatchNotes = qryRow.column_24>
					<cfset CarrierNotes = qryRow.column_25>

					<cfset CommodityQty = qryRow.column_26>
					<cfset CommidityType = qryRow.column_27>
					<cfset CommodityDescription = qryRow.column_28>
					<cfset CommodityFee = qryRow.column_29>
					<cfset CommidityWeight = qryRow.column_30>
					<cfset CommodityClass= qryRow.column_31>
					<cfset CommodityCustRate = ReplaceNoCase(ReplaceNoCase(qryRow.column_32,'$','','ALL'),',','','ALL')>
					<cfset CommidityCarrRate = ReplaceNoCase(ReplaceNoCase(qryRow.column_33,'$','','ALL'),',','','ALL')>
					<cfset CommodityCustPercent= ReplaceNoCase(qryRow.column_34,'%','','ALL')>

					<cfset LTL = qryRow.column_35>

					<cfif qGetEmployee.recordcount>
						<cfif len(trim(NewDispatchNotes))>
							<cfset NewDispatchNotes = '#DateTimeFormat(now(),"m/d/yyyy h:nn tt")# - #qGetEmployee.name# > #NewDispatchNotes#'>
						</cfif>
					</cfif>
					
					<cfquery dbtype="query" name="qGetEquipmentID">
						SELECT EquipmentID FROM qGetEquipmentNames WHERE upper(EquipmentName) = upper('#EquipmentName#')
					</cfquery>
					
					<cfquery dbtype="query" name="qGetDispatcherID">
						SELECT EmployeeID FROM qGetSalesperson WHERE upper(Name) = upper('#DispatcherLoginName#')
					</cfquery>	

					<cfquery dbtype="query" name="qGetAgentID">
						SELECT EmployeeID FROM qGetSalesperson WHERE upper(Name) = upper('#AgentLoginName#')
					</cfquery>

					<cfquery dbtype="query" name="qGetUnitID">
						SELECT UnitID FROM qGetUnits WHERE upper(UnitName) = upper('#CommidityType#')
					</cfquery>

					<cfquery dbtype="query" name="qGetClassID">
						SELECT ClassID FROM qGetClasses WHERE upper(ClassName) = upper('#CommodityClass#')
					</cfquery>

					<cfquery name="getloadmanual" datasource="#variables.dsn#">
						SELECT max(loadnumber) + 1 AS loadManualNo FROM Loads WHERE customerid in (select customerid from CustomerOffices inner join offices on CustomerOffices.officeid = offices.officeid where offices.companyid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#session.CompanyID#">)
					</cfquery>
					<cfif len(trim(PRO))>
						<cfset loadManualNo=trim(PRO)>
					<cfelse>
						<cfset loadManualNo=getloadmanual.loadManualNo>
					</cfif>
					
					<cfquery name="getLoadID" datasource="#variables.dsn#">
						SELECT NEWID() AS LoadID 
					</cfquery>

					<cfquery name="qinsLoad" datasource="#variables.dsn#">

						INSERT INTO Loads
						(
							LoadID
							,LoadNumber
							,StatusTypeID
							,CustomerID
							,custName
							,CarrFlatRate
							,CustFlatRate
							<cfif len(trim(qGetEquipmentID.EquipmentID))>,EquipmentID,EquipmentName</cfif>
							<cfif len(trim(qGetAgentID.EmployeeID))>,SalesRepID</cfif>
							,SalesAgent
							<cfif len(trim(qGetDispatcherID.EmployeeID))>,DispatcherID</cfif>
							,InternalRef
							,BOLNum
							,CustomerPONo
							,CreatedDateTime
							,LastModifiedDate
							,CreatedBy
							,ModifiedBy
							<cfif len(trim(PickupDate)) AND isdate(PickupDate)>,NewPickupDate</cfif>
							<cfif len(trim(DeliveryDate)) AND isdate(DeliveryDate)>,NewDeliveryDate</cfif>
							,HasEnrouteStops
							,HasTemp
							,IsPost
							,IsPepUpload
							,IsLocked
							,TotalCustomerCharges
							,TotalCarrierCharges
							,ControlNumber
							,NEWNOTES
							,NEWDISPATCHNOTES
							,ShipperCity
							,ShipperState
							,ConsigneeCity
							,ConsigneeState
							,CarrierNotes
							<cfif len(trim(LTL)) AND listFindNoCase("true,false,0,1", LTL)>,IsPartial</cfif>
						)
						VALUES 
						(
							<cfqueryparam value="#getLoadID.LoadID#" cfsqltype="cf_sql_varchar">
							,<cfqueryparam value="#loadManualNo#" cfsqltype="cf_sql_varchar">
							,<cfqueryparam value="#insStatusTypeID#" cfsqltype="cf_sql_varchar">
							,<cfqueryparam value="#session.CustomerID#" cfsqltype="cf_sql_varchar">
							,<cfqueryparam value="#session.userfullname#" cfsqltype="cf_sql_varchar">
							,<cfqueryparam value="#CarrierFlatRate#" cfsqltype="cf_sql_float">
							,<cfqueryparam value="#CustomerFlatRate#" cfsqltype="cf_sql_float">
							<cfif len(trim(qGetEquipmentID.EquipmentID))>
								,<cfqueryparam value="#qGetEquipmentID.EquipmentID#" cfsqltype="cf_sql_varchar">
								,<cfqueryparam value="#EquipmentName#" cfsqltype="cf_sql_varchar">
							</cfif>
							<cfif len(trim(qGetAgentID.EmployeeID))>,<cfqueryparam value="#qGetAgentID.EmployeeID#" cfsqltype="cf_sql_varchar"></cfif>
							,<cfqueryparam value="#AgentLoginName#" cfsqltype="cf_sql_varchar">
							<cfif len(trim(qGetDispatcherID.EmployeeID))>,<cfqueryparam value="#qGetDispatcherID.EmployeeID#" cfsqltype="cf_sql_varchar"></cfif>
							,<cfqueryparam value="#PRO#" cfsqltype="cf_sql_varchar">
							,<cfqueryparam value="#BOL#" cfsqltype="cf_sql_varchar">
							,<cfqueryparam value="#PO#" cfsqltype="cf_sql_varchar">
							,getdate()
							,getdate()
							,<cfqueryparam value="#session.AdminUserName#" cfsqltype="cf_sql_varchar">
							,<cfqueryparam value="#session.AdminUserName#" cfsqltype="cf_sql_varchar">
							<cfif len(trim(PickupDate)) AND isdate(PickupDate)>,<cfqueryparam value="#PickupDate#" cfsqltype="cf_sql_varchar"></cfif>
							<cfif len(trim(DeliveryDate)) AND isdate(DeliveryDate)>,<cfqueryparam value="#DeliveryDate#" cfsqltype="cf_sql_varchar"></cfif>
							,0
							,0
							,0
							,0
							,0
							,<cfqueryparam value="#CustomerFlatRate#" cfsqltype="cf_sql_float">
							,<cfqueryparam value="#CarrierFlatRate#" cfsqltype="cf_sql_float">
							,<cfqueryparam value="#loadManualNo#" cfsqltype="cf_sql_varchar">
							,<cfqueryparam value="#NEWNOTES#" cfsqltype="cf_sql_varchar">
							,<cfqueryparam value="#NEWDISPATCHNOTES#" cfsqltype="cf_sql_varchar">
							,<cfqueryparam value="#ShipperCity#" cfsqltype="cf_sql_varchar">
							,<cfqueryparam value="#ShipperState#" cfsqltype="cf_sql_varchar">
							,<cfqueryparam value="#DestinationCity#" cfsqltype="cf_sql_varchar">
							,<cfqueryparam value="#DestinationState#" cfsqltype="cf_sql_varchar">
							,<cfqueryparam value="#CarrierNotes#" cfsqltype="cf_sql_varchar">
							<cfif len(trim(LTL)) AND listFindNoCase("true,false,0,1", LTL)>,<cfqueryparam value="#LTL#" cfsqltype="cf_sql_varchar"></cfif>
						)
					</cfquery>

					<cfquery name="getLoadShipperStopID" datasource="#variables.dsn#">
						SELECT newid() AS StopID
					</cfquery>	

					<cfquery name="qinsShipperStop" datasource="#variables.dsn#">
						INSERT INTO LoadStops 
						(
							LoadStopID
							,LoadID
							,StopNo
							,LoadType
							,Address
							,City
							,stateCode
							,postalCode
							,ReleaseNo
							<cfif len(trim(PickupDate)) AND isdate(PickupDate)>,StopDate</cfif>
							,IsOriginPickup
							,IsFinalDelivery
							,blind
							,CreatedDateTime
							,LastModifiedDate
							,CreatedBy
							,ModifiedBy
							<cfif len(trim(qGetEquipmentID.EquipmentID))>,NewEquipmentID</cfif>
							,RefNo
							,TimeIn
							,TimeOut
							,StopTime
							,CustName
						)
						VALUES(
							<cfqueryparam value="#getLoadShipperStopID.StopID#" cfsqltype="cf_sql_varchar">
							,<cfqueryparam value="#getLoadID.LoadID#" cfsqltype="cf_sql_varchar">
							,0
							,1
							,<cfqueryparam value="#ShipperAddress#" cfsqltype="cf_sql_varchar">
							,<cfqueryparam value="#ShipperCity#" cfsqltype="cf_sql_varchar">
							,<cfqueryparam value="#ShipperState#" cfsqltype="cf_sql_varchar">
							,<cfqueryparam value="#ShipperZip#" cfsqltype="cf_sql_varchar">
							,<cfqueryparam value="#PickupNo#" cfsqltype="cf_sql_varchar">
							<cfif len(trim(PickupDate)) AND isdate(PickupDate)>,<cfqueryparam value="#PickupDate#" cfsqltype="cf_sql_varchar"></cfif>
							,1
							,0
							,0
							,getdate()
							,getdate()
							,<cfqueryparam value="#session.AdminUserName#" cfsqltype="cf_sql_varchar">
							,<cfqueryparam value="#session.AdminUserName#" cfsqltype="cf_sql_varchar">
							<cfif len(trim(qGetEquipmentID.EquipmentID))>,<cfqueryparam value="#qGetEquipmentID.EquipmentID#" cfsqltype="cf_sql_varchar"></cfif>
							,''
							,''
							,''
							,''
							,<cfqueryparam value="#ShipperName#" cfsqltype="cf_sql_varchar">
						)
					</cfquery>

					<cfquery name="qinsConsigneeStop" datasource="#variables.dsn#">
						INSERT INTO LoadStops 
						(
							LoadStopID
							,LoadID
							,StopNo
							,LoadType
							,Address
							,City
							,stateCode
							,postalCode
							,ReleaseNo
							<cfif len(trim(DeliveryDate)) AND isdate(DeliveryDate)>,StopDate</cfif>
							,IsOriginPickup
							,IsFinalDelivery
							,blind
							,CreatedDateTime
							,LastModifiedDate
							,CreatedBy
							,ModifiedBy
							<cfif len(trim(qGetEquipmentID.EquipmentID))>,NewEquipmentID</cfif>
							,RefNo
							,TimeIn
							,TimeOut
							,StopTime
							,CustName
						)
						VALUES(
							newid()
							,<cfqueryparam value="#getLoadID.LoadID#" cfsqltype="cf_sql_varchar">
							,0
							,2
							,<cfqueryparam value="#DestinationAddress#" cfsqltype="cf_sql_varchar">
							,<cfqueryparam value="#DestinationCity#" cfsqltype="cf_sql_varchar">
							,<cfqueryparam value="#DestinationState#" cfsqltype="cf_sql_varchar">
							,<cfqueryparam value="#DestinationZip#" cfsqltype="cf_sql_varchar">
							,<cfqueryparam value="#DeliveryNo#" cfsqltype="cf_sql_varchar">
							<cfif len(trim(DeliveryDate)) AND isdate(DeliveryDate)>,<cfqueryparam value="#DeliveryDate#" cfsqltype="cf_sql_varchar"></cfif>
							,0
							,1
							,0
							,getdate()
							,getdate()
							,<cfqueryparam value="#session.AdminUserName#" cfsqltype="cf_sql_varchar">
							,<cfqueryparam value="#session.AdminUserName#" cfsqltype="cf_sql_varchar">
							<cfif len(trim(qGetEquipmentID.EquipmentID))>,<cfqueryparam value="#qGetEquipmentID.EquipmentID#" cfsqltype="cf_sql_varchar"></cfif>
							,''
							,''
							,''
							,''
							,<cfqueryparam value="#DestinationName#" cfsqltype="cf_sql_varchar">
						)
					</cfquery>


					<cfquery name="newLoadStopComm" datasource="#variables.dsn#">
						INSERT INTO LoadStopCommodities
						(
							LoadStopID
							,Weight
							,Qty
							,Description
							,SrNo
							,CustCharges
							,CarrCharges
							,CustRate
							,CarrRate
							,CarrRateOfCustTotal 
							<cfif listFind("0,1", CommodityFee)>,Fee</cfif>
							<cfif qGetUnitID.recordcount>,UnitID</cfif>
							<cfif qGetClassID.recordcount>,ClassID</cfif>
						)
						VALUES(
							<cfqueryparam value="#getLoadShipperStopID.StopID#" cfsqltype="cf_sql_varchar">
							,<cfif isnumeric(CommidityWeight)><cfqueryparam value="#CommidityWeight#" cfsqltype="cf_sql_varchar"><cfelse>0</cfif>
							,<cfif isnumeric(CommodityQty)><cfqueryparam value="#CommodityQty#" cfsqltype="cf_sql_varchar"><cfelse>1</cfif>
							,<cfqueryparam value="#CommodityDescription#" cfsqltype="cf_sql_varchar">
							,'1'
							,<cfif isnumeric(CommodityCustRate)><cfqueryparam value="#CommodityCustRate#" cfsqltype="cf_sql_varchar"><cfelse>0</cfif>
							,<cfif isnumeric(CommidityCarrRate)><cfqueryparam value="#CommidityCarrRate#" cfsqltype="cf_sql_varchar"><cfelse>0</cfif>
							,<cfif isnumeric(CommodityCustRate)><cfqueryparam value="#CommodityCustRate#" cfsqltype="cf_sql_varchar"><cfelse>0</cfif>
							,<cfif isnumeric(CommidityCarrRate)><cfqueryparam value="#CommidityCarrRate#" cfsqltype="cf_sql_varchar"><cfelse>0</cfif>
							,<cfif isnumeric(CommodityCustPercent)><cfqueryparam value="#CommodityCustPercent#" cfsqltype="cf_sql_varchar"><cfelse>0</cfif>
							<cfif listFind("0,1", CommodityFee)>,<cfqueryparam value="#CommodityFee#" cfsqltype="cf_sql_varchar"></cfif>
							<cfif qGetUnitID.recordcount>,<cfqueryparam value="#qGetUnitID.UnitID#" cfsqltype="cf_sql_varchar"></cfif>
							<cfif qGetClassID.recordcount>,<cfqueryparam value="#qGetClassID.ClassID#" cfsqltype="cf_sql_varchar"></cfif>
						)
					</cfquery>
					<cfset logMsg = "Imported load:#loadManualNo#(Row Number:#currentRow#).">
					<cfquery name="qInsLog" datasource="#variables.dsn#">
						INSERT INTO CsvImportLog (LogId,Message,CreatedDate,Success,RowData,LoadNumber,CompanyID)
						VALUES(newid(),<cfqueryparam value="#logMsg#" cfsqltype="cf_sql_varchar">,getdate(),1,<cfqueryparam value="#row#" cfsqltype="cf_sql_varchar">,<cfqueryparam value="#loadManualNo#" cfsqltype="cf_sql_varchar">,<cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar">)
					</cfquery>
				</cfif>	
				<cfset currentRow++>
			</cfloop>
			<cfset response.success = 1>
			<cfif bitImportedAll EQ 0>
				<cfset response.message = "Some rows are not imported.">
			<cfelse>
				<cfset response.message = "Loads imported successfully.">
			</cfif>
			<cfreturn response>
			<cfcatch>
				<cfquery name="qInsLog" datasource="#variables.dsn#">
					INSERT INTO CsvImportLog (LogId,Message,CreatedDate,Success,RowData,CompanyID)
					VALUES(newid(),<cfqueryparam value="#cfcatch.message##cfcatch.detail#" cfsqltype="cf_sql_varchar">,getdate(),0,<cfqueryparam value="#row#" cfsqltype="cf_sql_varchar">,<cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar">)
				</cfquery>

				<cfset response.success = 0>
				<cfset response.message = "Something went wrong. Please contact support.">
				<cfreturn response>
			</cfcatch>
		 </cftry>
	</cffunction>
</cfcomponent>