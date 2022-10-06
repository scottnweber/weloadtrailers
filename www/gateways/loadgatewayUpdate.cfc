<cfcomponent output="true" extends="loadgateway">
	<cfsetting showdebugoutput="true">

	<cffunction name="init" access="public" output="false" returntype="void">
		<cfargument name="dsn" type="string" required="yes" />
		<cfset variables.dsn = Application.dsn />
	</cffunction>
	
	<cffunction name="callLoadboardWebservice" access="public" returntype="any">
		<cfargument name="frmstruct" required="yes">
		<cfargument name="p_action" required="yes">
		
		<cfset variables.postProviderid='LMGR428AP'>
		<cfif NOT StructKeyExists(arguments.frmstruct,"postCarrierRateto123LoadBoard")>
			<cfset IncludeCarierRate = 0>
		<cfelse>
			<cfset IncludeCarierRate = arguments.frmstruct.postCarrierRateto123LoadBoard >
		</cfif>
		<cfset var postLoadResponse = postTo123LoadBoardWebservice(arguments.p_action,variables.postProviderid,arguments.frmstruct.loadBoard123Username,arguments.frmstruct.loadBoard123Password,arguments.frmstruct.loadnumber,arguments.frmstruct.appDsn,arguments.frmstruct.CARRIERRATE,IncludeCarierRate,arguments.frmstruct.editid)>
		<cfreturn postLoadResponse>
	</cffunction>


	<cffunction name="getLoadStopAddress" access="public" returntype="query">
		<cfargument name="tablename" default="0">
		<cfargument name="address" default="0">
		<cfquery name="qLoadStopEmptyPickupAddressExists" datasource="#Application.dsn#">
			SELECT ID FROM #arguments.tablename#
			WHERE address = <cfqueryparam value="#arguments.address#" cfsqltype="cf_sql_varchar">
		</cfquery>
		<cfreturn qLoadStopEmptyPickupAddressExists>
	</cffunction>

	<cffunction name="getlastStopId" access="public" returntype="query">
		<cfargument name="ShipBlind" required="yes">
		<cfargument name="lastUpdatedShipCustomerID">
		<cfargument name="LastLoadId" required="yes">
		<cfargument name="frmstruct" required="yes">
		
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

		<CFSTOREDPROC PROCEDURE="USP_UpdateLoadStop" datasource="#Application.dsn#">
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
			<cfif structKeyExists(arguments.frmstruct, "stOffice") and len(arguments.frmstruct.stOffice) gt 1>
				<CFPROCPARAM VALUE="#arguments.frmstruct.stOffice#" cfsqltype="CF_SQL_VARCHAR">
			<cfelse>
				<CFPROCPARAM VALUE="Null" cfsqltype="CF_SQL_VARCHAR">
			</cfif>
			<CFPROCPARAM VALUE="#arguments.frmstruct.shipperPickupNO1#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#arguments.frmstruct.shipperPickupDate#" cfsqltype="CF_SQL_dATE" null="#yesNoFormat(NOT len(arguments.frmstruct.shipperPickupDate) OR NOT isdate(arguments.frmstruct.shipperPickupDate))#">
			<CFPROCPARAM VALUE="#arguments.frmstruct.shipperPickupTime#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#arguments.frmstruct.shipperTimeIn#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#arguments.frmstruct.shipperTimeOut#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#session.adminUserName#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#arguments.lastUpdatedShipCustomerID#" cfsqltype="CF_SQL_VARCHAR" null="#yesNoFormat(NOT len(arguments.lastUpdatedShipCustomerID))#">
			<CFPROCPARAM VALUE="#arguments.ShipBlind#" cfsqltype="CF_SQL_BIT">
			<CFPROCPARAM VALUE="#arguments.frmstruct.shipperNotes#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#arguments.frmstruct.shipperDirection#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="1" cfsqltype="CF_SQL_INTEGER">
			<CFPROCPARAM VALUE="0" cfsqltype="CF_SQL_INTEGER"> <!--- Stop Number --->
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
			<CFPROCPARAM VALUE="#variables.noOfDays1#" cfsqltype="CF_SQL_INTEGER" null="#yesNoFormat(NOT len(variables.noOfDays1))#">
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
			<cfif isdefined('arguments.frmstruct.shipperPickupDateMultiple') and len(evaluate('arguments.frmstruct.shipperPickupDateMultiple'))>
				<CFPROCPARAM VALUE="#evaluate('arguments.frmstruct.shipperPickupDateMultiple')#"  cfsqltype="CF_SQL_VARCHAR">
			<cfelse>
				<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR"  null="Yes">	
			</cfif>
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
			<cfprocresult name="qLastInsertedShipper">
		</CFSTOREDPROC>
		<cfreturn qLastInsertedShipper>
	</cffunction>
	<cffunction name="InsertLoadAdd" access="public" returntype="any">
		<cfargument name="loadManualNo" required="yes">
		<cfargument name="posttoloadboard" required="yes">
		<cfargument name="posttoTranscore" required="yes">
		<cfargument name="PostTo123LoadBoard" required="yes">
		<cfargument name="carFlatRate" required="yes">
		<cfargument name="custFlatRate" required="yes">
		<cfargument name="custRatePerMile" required="yes">
		<cfargument name="carRatePerMile" required="yes">
		<cfargument name="CustomerMilesCalc" required="yes">
		<cfargument name="CarrierMilesCalc" required="yes">
		<cfargument name="ARExported" required="yes">
		<cfargument name="APExported" required="yes">
		<cfargument name="custMilesCharges" required="yes">
		<cfargument name="carMilesCharges" required="yes">
		<cfargument name="carCommodCharges" required="yes">
		<cfargument name="custCommodCharges" required="yes">
		<cfargument name="frmstruct" required="yes">
		<cfargument name="invoiceNumber" required="yes">
		<cfargument name="postCarrierRatetoloadboard" required="no"  default="0">
		<cfargument name="postCarrierRatetoTranscore" required="no" default="0">
		<cfargument name="postCarrierRateto123LoadBoard" required="no" default="0">
		<cfargument name="dsn" required="yes">
		<cfargument name="IsConcatCarrierDriverIdentifier" required="no" default="0">
		<cfargument name="noOfTrips" required="no" default="1">
		<cfargument name="FF" required="no" default="0">

		<CFSTOREDPROC PROCEDURE="USP_InsertLoad" DATASOURCE="#arguments.dsn#">
			<CFPROCPARAM VALUE="#arguments.loadManualNo#" cfsqltype="CF_SQL_BIGINT">
			<CFPROCPARAM VALUE="#arguments.frmstruct.cutomerIdAutoValueContainer#" cfsqltype="CF_SQL_VARCHAR">
			<cfif isdefined('arguments.frmstruct.SALESPERSON') and len(arguments.frmstruct.SALESPERSON) gt 1>
				<CFPROCPARAM VALUE="#arguments.frmstruct.SALESPERSON#" cfsqltype="CF_SQL_VARCHAR">
			<cfelse>
				<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR" null="true">
			</cfif>
			<cfif isdefined('arguments.frmstruct.CARRIERINVOICENUMBER') and val(arguments.frmstruct.CARRIERINVOICENUMBER) gt 0>
				<CFPROCPARAM VALUE="#arguments.frmstruct.CARRIERINVOICENUMBER#" cfsqltype="CF_SQL_BIGINT">
			<cfelse>
				<CFPROCPARAM VALUE="0" cfsqltype="CF_SQL_BIGINT" >
			</cfif>
			<cfif isdefined('arguments.frmstruct.dispatcher') and len(arguments.frmstruct.dispatcher) gt 1>
				<CFPROCPARAM VALUE="#arguments.frmstruct.dispatcher#" cfsqltype="CF_SQL_VARCHAR">
			<cfelse>
				<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR">
			</cfif>
			<CFPROCPARAM VALUE="#arguments.frmstruct.LOADSTATUS#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#arguments.posttoloadboard#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#arguments.posttoTranscore#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#arguments.PostTo123LoadBoard#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#arguments.postCarrierRatetoloadboard#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#arguments.postCarrierRatetoTranscore#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#arguments.postCarrierRateto123LoadBoard#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#arguments.frmstruct.notes#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#arguments.frmstruct.dispatchnotes#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#arguments.frmstruct.carriernotes#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#arguments.frmstruct.pricingNotes#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#arguments.frmstruct.CUSTOMERPO#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#arguments.frmstruct.customerBOL#" cfsqltype="CF_SQL_VARCHAR">
			<cfset totCarChg = replace(arguments.frmstruct.TotalCarrierCharges,'$',"")>
			<cfset totCustChg = replace(arguments.frmstruct.TotalCustomerCharges,'$',"")>
			<CFPROCPARAM VALUE="#val(totCarChg)#" cfsqltype="cf_sql_money">
			<CFPROCPARAM VALUE="#val(totCustChg)#" cfsqltype="cf_sql_money">
			<CFPROCPARAM VALUE="#val(arguments.carFlatRate)#" cfsqltype="cf_sql_money">
			<CFPROCPARAM VALUE="#val(arguments.custFlatRate)#" cfsqltype="cf_sql_money">
			<cfif isdefined('arguments.frmstruct.carrierID') and len(trim(arguments.frmstruct.carrierID)) gt 1>
				<CFPROCPARAM VALUE="#trim(arguments.frmstruct.carrierID)#" cfsqltype="CF_SQL_VARCHAR">
			<cfelse>
				<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR">
			</cfif>
			<cfif isdefined('arguments.frmstruct.carrierOfficeID') and len(arguments.frmstruct.carrierOfficeID) gt 1>
				<CFPROCPARAM VALUE="#trim(arguments.frmstruct.carrierOfficeID)#" cfsqltype="CF_SQL_VARCHAR">
			<cfelse>
				<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR">
			</cfif>
			<CFPROCPARAM VALUE="#arguments.frmstruct.equipment#" cfsqltype="CF_SQL_VARCHAR">
			<cfif isdefined('arguments.frmstruct.driver') and len(arguments.frmstruct.driver)>
				<CFPROCPARAM VALUE="#arguments.frmstruct.driver#" cfsqltype="CF_SQL_VARCHAR">
			<cfelse>
				<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR"  null="Yes">	
			</cfif>
			<CFPROCPARAM VALUE="#arguments.frmstruct.drivercell#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#arguments.frmstruct.TRUCKNO#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#arguments.frmstruct.trailerNo#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#arguments.frmstruct.BookedWith#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#arguments.frmstruct.shipperPickupNO1#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#arguments.frmstruct.shipperPickupDate#" cfsqltype="cf_sql_date" null="#yesNoFormat(NOT len(arguments.frmstruct.shipperPickupDate))#">
			<CFPROCPARAM VALUE="#arguments.frmstruct.shipperPickupTime#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#arguments.frmstruct.shipperTimeIn#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#arguments.frmstruct.shipperTimeOut#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#arguments.frmstruct.consigneePickupNO#" cfsqltype="CF_SQL_VARCHAR">
			<cfif structkeyexists(arguments.frmstruct,"consigneePickupDate#arguments.frmstruct.totalstop#") >
				<CFPROCPARAM VALUE="#arguments.frmstruct["consigneePickupDate#arguments.frmstruct.totalstop#"]#" cfsqltype="cf_sql_date" null="#yesNoFormat(NOT len(arguments.frmstruct["consigneePickupDate#arguments.frmstruct.totalstop#"]))#">
			<cfelse>
				<CFPROCPARAM VALUE="#arguments.frmstruct.consigneePickupDate#" cfsqltype="cf_sql_date" null="#yesNoFormat(NOT len(arguments.frmstruct.consigneePickupDate))#">
			</cfif>
			<CFPROCPARAM VALUE="#arguments.frmstruct.consigneePickupTime#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#arguments.frmstruct.consigneeTimeIn#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#arguments.frmstruct.consigneeTimeOut#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#session.adminUserName#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#cgi.REMOTE_ADDR#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#cgi.HTTP_USER_AGENT#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM value="#val(arguments.custRatePerMile)#"  cfsqltype="cf_sql_money">
			<CFPROCPARAM value="#val(arguments.carRatePerMile)#"  cfsqltype="cf_sql_money">
			<CFPROCPARAM value="#val(arguments.CustomerMilesCalc)#"  cfsqltype="cf_sql_float">
			<CFPROCPARAM value="#val(arguments.CarrierMilesCalc)#"  cfsqltype="cf_sql_float">
			<CFPROCPARAM VALUE="#session.officeid#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM value="#arguments.frmstruct.orderDate#" cfsqltype="cf_sql_date">
			<CFPROCPARAM value="#arguments.frmstruct.BillDate#" cfsqltype="cf_sql_date" null="#not len(arguments.frmstruct.BillDate)#">
			<CFPROCPARAM VALUE="#arguments.ARExported#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#arguments.APExported#" cfsqltype="CF_SQL_VARCHAR">
			<cfif isNumeric(arguments.custMilesCharges)>
				<CFPROCPARAM VALUE="#arguments.custMilesCharges#" cfsqltype="cf_sql_money">
			<cfelse>
				<CFPROCPARAM VALUE="0" cfsqltype="cf_sql_money">
			</cfif>
			<cfif isNumeric(arguments.carMilesCharges)>	
				<CFPROCPARAM VALUE="#arguments.carMilesCharges#" cfsqltype="cf_sql_money">
			<cfelse>
				<CFPROCPARAM VALUE="0" cfsqltype="cf_sql_money">
			</cfif>
			<cfif isNumeric(arguments.custCommodCharges)>		
				<CFPROCPARAM VALUE="#arguments.custCommodCharges#" cfsqltype="cf_sql_money">
			<cfelse>
				<CFPROCPARAM VALUE="0" cfsqltype="cf_sql_money">
			</cfif>
			<cfif isNumeric(arguments.carCommodCharges)>	
				<CFPROCPARAM VALUE="#arguments.carCommodCharges#" cfsqltype="cf_sql_money">
			<cfelse>
				<CFPROCPARAM VALUE="0" cfsqltype="cf_sql_money">
			</cfif>

			<cfif structkeyexists(arguments.frmstruct,"customerAddress")>
				<CFPROCPARAM VALUE="#arguments.frmstruct.customerAddress#" cfsqltype="CF_SQL_VARCHAR">
			<cfelse>
				<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR"  null="Yes">	
			</cfif>
			<cfif structkeyexists(arguments.frmstruct,"customerCity")>
				<CFPROCPARAM VALUE="#arguments.frmstruct.customerCity#" cfsqltype="CF_SQL_VARCHAR">
			<cfelse>
				<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR"  null="Yes">	
			</cfif>
			<cfif structkeyexists(arguments.frmstruct,"customerState")>
				<CFPROCPARAM VALUE="#arguments.frmstruct.customerState#" cfsqltype="CF_SQL_VARCHAR">
			<cfelse>
				<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR"  null="Yes">	
			</cfif>
			<cfif structkeyexists(arguments.frmstruct,"customerZipCode")>
				<CFPROCPARAM VALUE="#arguments.frmstruct.customerZipCode#" cfsqltype="CF_SQL_VARCHAR">
			<cfelse>
				<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR"  null="Yes">	
			</cfif>
			<CFPROCPARAM VALUE="#arguments.frmstruct.customerContact#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#arguments.frmstruct.customerPhone#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#arguments.frmstruct.customerPhoneExt#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#arguments.frmstruct.customerFax#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#arguments.frmstruct.customerCell#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#arguments.frmstruct.cutomerIdAuto#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#val(arguments.invoiceNumber)#" cfsqltype="CF_SQL_INTEGER">
			<cfif structkeyexists(arguments.frmstruct,"weightStop1") and isnumeric(arguments.frmstruct.weightStop1)>
				<CFPROCPARAM VALUE="#arguments.frmstruct.weightStop1#" cfsqltype="CF_SQL_INTEGER">
			<cfelse>
				<CFPROCPARAM VALUE="0" cfsqltype="CF_SQL_INTEGER">
			</cfif>
			<CFPROCPARAM VALUE="#arguments.frmstruct.carrier_id#" cfsqltype="CF_SQL_VARCHAR"><!--- if empty null -- Logic [DONT ask me why we have carrierID in this script - I DONT KNOW] ---> 
			<CFPROCPARAM VALUE="#arguments.frmstruct.shipperstate#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#arguments.frmstruct.shippercity#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#arguments.frmstruct.consigneestate#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#arguments.frmstruct.consigneecity#" cfsqltype="CF_SQL_VARCHAR">
			<cfif isdefined('arguments.frmstruct.SALESPERSON') and len(arguments.frmstruct.SALESPERSON) gt 1>
				<CFPROCPARAM VALUE="#arguments.frmstruct.SALESPERSON#" cfsqltype="CF_SQL_VARCHAR">
			<cfelse>
				<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR" null="true">
			</cfif>
			<CFPROCPARAM VALUE="#arguments.frmstruct.equipment#" cfsqltype="CF_SQL_VARCHAR">
			
			<cfif structKeyExists(arguments.frmstruct, "defaultCustomerCurrency")>
				<CFPROCPARAM VALUE="#arguments.frmstruct.defaultCustomerCurrency#" cfsqltype="cf_sql_integer">
			<cfelse>
				<CFPROCPARAM VALUE="" cfsqltype="cf_sql_integer" null="yes">
			</cfif>	
			
			<cfif structKeyExists(arguments.frmstruct, "defaultCarrierCurrency")>
				<CFPROCPARAM VALUE="#arguments.frmstruct.defaultCarrierCurrency#" cfsqltype="cf_sql_integer">
			<cfelse>
				<CFPROCPARAM VALUE="" cfsqltype="cf_sql_integer" null="yes">
			</cfif>
			<CFPROCPARAM VALUE="#arguments.IsConcatCarrierDriverIdentifier#" cfsqltype="cf_sql_bit" >
			
			<cfif structKeyExists(arguments.frmstruct, "InternalRef")>
				<CFPROCPARAM VALUE="#arguments.frmstruct.InternalRef#" cfsqltype="CF_SQL_VARCHAR">
			<cfelse>
				<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR" null="yes">
			</cfif>
			<CFPROCPARAM VALUE="#arguments.frmstruct.noOfTrips#" cfsqltype="cf_sql_integer">
			<CFPROCPARAM VALUE="#arguments.FF#" cfsqltype="cf_sql_float">
			<cfif structKeyExists(arguments.frmstruct, "EquipmentLength") AND len(trim(arguments.frmstruct.EquipmentLength)) and isNumeric(trim(arguments.frmstruct.EquipmentLength))>
				<CFPROCPARAM VALUE="#arguments.frmstruct.EquipmentLength#" cfsqltype="CF_SQL_FLOAT">
			<cfelse>
				<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR" null="yes">
			</cfif>
			<cfif structKeyExists(arguments.frmstruct, "SalesRep1") AND len(trim(arguments.frmstruct.SalesRep1))>
				<CFPROCPARAM VALUE="#arguments.frmstruct.SalesRep1#" cfsqltype="CF_SQL_VARCHAR">
			<cfelse>
				<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR" null="yes">
			</cfif>

			<cfif structKeyExists(arguments.frmstruct, "SalesRep2") AND len(trim(arguments.frmstruct.SalesRep2))>
				<CFPROCPARAM VALUE="#arguments.frmstruct.SalesRep2#" cfsqltype="CF_SQL_VARCHAR">
			<cfelse>
				<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR" null="yes">
			</cfif>

			<cfif structKeyExists(arguments.frmstruct, "SalesRep3") AND len(trim(arguments.frmstruct.SalesRep3))>
				<CFPROCPARAM VALUE="#arguments.frmstruct.SalesRep3#" cfsqltype="CF_SQL_VARCHAR">
			<cfelse>
				<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR" null="yes">
			</cfif>

			<cfif structKeyExists(arguments.frmstruct, "SalesRep1Percentage") and isNumeric(arguments.frmstruct.SalesRep1Percentage)>
				<CFPROCPARAM VALUE="#arguments.frmstruct.SalesRep1Percentage#" cfsqltype="cf_sql_decimal">
			<cfelse>
				<CFPROCPARAM VALUE="0" cfsqltype="cf_sql_decimal">
			</cfif>

			<cfif structKeyExists(arguments.frmstruct, "SalesRep2Percentage") and isNumeric(arguments.frmstruct.SalesRep2Percentage)>
				<CFPROCPARAM VALUE="#arguments.frmstruct.SalesRep2Percentage#" cfsqltype="cf_sql_decimal">
			<cfelse>
				<CFPROCPARAM VALUE="0" cfsqltype="cf_sql_decimal">
			</cfif>

			<cfif structKeyExists(arguments.frmstruct, "SalesRep3Percentage") and isNumeric(arguments.frmstruct.SalesRep3Percentage)>
				<CFPROCPARAM VALUE="#arguments.frmstruct.SalesRep3Percentage#" cfsqltype="cf_sql_decimal">
			<cfelse>
				<CFPROCPARAM VALUE="0" cfsqltype="cf_sql_decimal">
			</cfif>
			<cfif structKeyExists(arguments.frmstruct, "TotalDirectCost")>
				<CFPROCPARAM VALUE="#val(replaceNoCase(replaceNoCase(arguments.frmStruct.TotalDirectCost,'$',''),',','','ALL'))#" cfsqltype="cf_sql_money">
			<cfelse>
				<CFPROCPARAM VALUE="0.00" cfsqltype="cf_sql_money">
			</cfif>
			<cfif structKeyExists(arguments.frmstruct, "EquipmentWidth") AND len(trim(arguments.frmstruct.EquipmentWidth))  AND isnumeric(trim(arguments.frmstruct.EquipmentWidth))>
				<CFPROCPARAM VALUE="#arguments.frmstruct.EquipmentWidth#" cfsqltype="CF_SQL_FLOAT">
			<cfelse>
				<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR" null="yes">
			</cfif>
			<cfif structKeyExists(arguments.frmstruct, "CustomerEmail") AND len(trim(arguments.frmstruct.CustomerEmail))>
				<CFPROCPARAM VALUE="#arguments.frmstruct.CustomerEmail#" cfsqltype="CF_SQL_VARCHAR">
			<cfelse>
				<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR" null="yes">
			</cfif>
			<cfif structKeyExists(arguments.frmstruct, "CustomDriverPay")>
				<CFPROCPARAM VALUE="1"  cfsqltype="CF_SQL_BIT">
			<cfelse>
				<CFPROCPARAM VALUE="0"  cfsqltype="CF_SQL_BIT">
			</cfif>
			<CFPROCPARAM VALUE="#arguments.frmstruct.CriticalNotes#" cfsqltype="CF_SQL_VARCHAR">
			<cfif structKeyExists(arguments.frmstruct, "Dispatcher1") AND len(trim(arguments.frmstruct.Dispatcher1))>
				<CFPROCPARAM VALUE="#arguments.frmstruct.Dispatcher1#" cfsqltype="CF_SQL_VARCHAR">
			<cfelse>
				<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR" null="yes">
			</cfif>

			<cfif structKeyExists(arguments.frmstruct, "Dispatcher2") AND len(trim(arguments.frmstruct.Dispatcher2))>
				<CFPROCPARAM VALUE="#arguments.frmstruct.Dispatcher2#" cfsqltype="CF_SQL_VARCHAR">
			<cfelse>
				<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR" null="yes">
			</cfif>

			<cfif structKeyExists(arguments.frmstruct, "Dispatcher3") AND len(trim(arguments.frmstruct.Dispatcher3))>
				<CFPROCPARAM VALUE="#arguments.frmstruct.Dispatcher3#" cfsqltype="CF_SQL_VARCHAR">
			<cfelse>
				<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR" null="yes">
			</cfif>

			<cfif structKeyExists(arguments.frmstruct, "Dispatcher1Percentage") and isNumeric(arguments.frmstruct.Dispatcher1Percentage)>
				<CFPROCPARAM VALUE="#arguments.frmstruct.Dispatcher1Percentage#" cfsqltype="cf_sql_decimal">
			<cfelse>
				<CFPROCPARAM VALUE="0" cfsqltype="CF_SQL_FLOAT">
			</cfif>

			<cfif structKeyExists(arguments.frmstruct, "Dispatcher2Percentage") and isNumeric(arguments.frmstruct.Dispatcher2Percentage)>
				<CFPROCPARAM VALUE="#arguments.frmstruct.Dispatcher2Percentage#" cfsqltype="cf_sql_decimal">
			<cfelse>
				<CFPROCPARAM VALUE="0" cfsqltype="CF_SQL_FLOAT">
			</cfif>

			<cfif structKeyExists(arguments.frmstruct, "Dispatcher3Percentage") and isNumeric(arguments.frmstruct.Dispatcher3Percentage)>
				<CFPROCPARAM VALUE="#arguments.frmstruct.Dispatcher3Percentage#" cfsqltype="cf_sql_decimal">
			<cfelse>
				<CFPROCPARAM VALUE="0" cfsqltype="CF_SQL_FLOAT">
			</cfif>
			<cfif structKeyExists(arguments.frmstruct,'BillFromCompany') and len(arguments.frmstruct.BillFromCompany)>
				,<CFPROCPARAM VALUE="#arguments.frmstruct.BillFromCompany#"  cfsqltype="CF_SQL_VARCHAR">
			<cfelse>
				,<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR" null="true">
			</cfif>
			<cfif structKeyExists(arguments.frmstruct,'CustomerPaid')>
				<CFPROCPARAM VALUE="1"  cfsqltype="CF_SQL_BIT">
			<cfelse>
				<CFPROCPARAM VALUE="0" cfsqltype="CF_SQL_BIT">
			</cfif>
			<cfif structKeyExists(arguments.frmstruct,'CarrierPaid')>
				<CFPROCPARAM VALUE="1"  cfsqltype="CF_SQL_BIT">
			<cfelse>
				<CFPROCPARAM VALUE="0" cfsqltype="CF_SQL_BIT">
			</cfif>
			<cfif structKeyExists(arguments.frmstruct,'LimitCarrierRate')>
				<CFPROCPARAM VALUE="1"  cfsqltype="CF_SQL_BIT">
			<cfelse>
				<CFPROCPARAM VALUE="0" cfsqltype="CF_SQL_BIT">
			</cfif>
			<CFPROCPARAM VALUE="#val(totCarChg)#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCRESULT NAME="qInsertedLoadID">
	   </CFSTOREDPROC>
	   <cfreturn qInsertedLoadID>
	</cffunction>

	<cffunction name="UpdateLoadAddNew" access="public" returntype="any">
		<cfargument name="frmstruct" required="yes" type="struct">
		<cfargument name="lastInsertedStopId" required="yes">

			<cfquery name="qLoadStopIntermodalExportExists" datasource="#application.dsn#">
				SELECT LoadStopID FROM LoadStopIntermodalExport
				WHERE LoadStopID = <cfqueryparam value="#lastInsertedStopId#" cfsqltype="cf_sql_varchar">
				AND StopNo = <cfqueryparam value="1" cfsqltype="cf_sql_integer">
			</cfquery>

			<cfif qLoadStopIntermodalExportExists.recordcount>
				<cfquery name="qUpdateLoadStopIntermodalImport" datasource="#application.dsn#">
					update LoadStopIntermodalExport
					set dateDispatched = <cfqueryparam value="#arguments.frmstruct.exportDateDispatched#" cfsqltype="cf_sql_date">,
						DateMtAvailableForPickup = <cfqueryparam value="#arguments.frmstruct.exportDateMtAvailableForPickup#" cfsqltype="cf_sql_date">,
						steamShipLine = <cfqueryparam value="#arguments.frmstruct.exportsteamShipLine#" cfsqltype="cf_sql_varchar">,
						DemurrageFreeTimeExpirationDate = <cfqueryparam value="#arguments.frmstruct.exportDemurrageFreeTimeExpirationDate#" cfsqltype="cf_sql_date">,
						vesselName = <cfqueryparam value="#arguments.frmstruct.exportvesselName#" cfsqltype="cf_sql_varchar">,
						PerDiemFreeTimeExpirationDate = <cfqueryparam value="#arguments.frmstruct.exportPerDiemFreeTimeExpirationDate#" cfsqltype="cf_sql_date">,
						Voyage = <cfqueryparam value="#arguments.frmstruct.exportVoyage#" cfsqltype="cf_sql_varchar">,
						EmptyPickupDate = <cfqueryparam value="#arguments.frmstruct.exportEmptyPickupDate#" cfsqltype="cf_sql_date">,
						seal = <cfqueryparam value="#arguments.frmstruct.exportseal#" cfsqltype="cf_sql_varchar">,
						Booking = <cfqueryparam value="#arguments.frmstruct.exportBooking#" cfsqltype="cf_sql_varchar">,
						ScheduledLoadingDate = <cfqueryparam value="#arguments.frmstruct.exportScheduledLoadingDate#" cfsqltype="cf_sql_date">,
						ScheduledLoadingTime = <cfqueryparam value="#arguments.frmstruct.exportScheduledLoadingTime#" cfsqltype="cf_sql_varchar">,
						VesselCutoffDate = <cfqueryparam value="#arguments.frmstruct.exportVesselCutoffDate#" cfsqltype="cf_sql_date">,
						LoadingDate = <cfqueryparam value="#arguments.frmstruct.exportLoadingDate#" cfsqltype="cf_sql_date">,
						VesselLoadingWindow = <cfqueryparam value="#arguments.frmstruct.exportVesselLoadingWindow#" cfsqltype="cf_sql_varchar">,
						LoadingDelayDetectionStartDate = <cfqueryparam value="#arguments.frmstruct.exportLoadingDelayDetectionStartDate#" cfsqltype="cf_sql_date">,
						LoadingDelayDetectionStartTime = <cfqueryparam value="#arguments.frmstruct.exportLoadingDelayDetectionStartTime#" cfsqltype="cf_sql_varchar">,
						RequestedLoadingDate = <cfqueryparam value="#arguments.frmstruct.exportRequestedLoadingDate#" cfsqltype="cf_sql_date">,
						RequestedLoadingTime = <cfqueryparam value="#arguments.frmstruct.exportRequestedLoadingTime#" cfsqltype="cf_sql_varchar">,
						LoadingDelayDetectionEndDate = <cfqueryparam value="#arguments.frmstruct.exportLoadingDelayDetectionEndDate#" cfsqltype="cf_sql_date">,
						LoadingDelayDetectionEndTime = <cfqueryparam value="#arguments.frmstruct.exportLoadingDelayDetectionEndTime#" cfsqltype="cf_sql_varchar">,
						ETS = <cfqueryparam value="#arguments.frmstruct.exportETS#" cfsqltype="cf_sql_date">,
						ReturnDate = <cfqueryparam value="#arguments.frmstruct.exportReturnDate#" cfsqltype="cf_sql_date">,
						emptyPickupAddress = <cfqueryparam value="#arguments.frmstruct.exportEmptyPickupAddress#" cfsqltype="cf_sql_varchar">,
						loadingAddress = <cfqueryparam value="#arguments.frmstruct.exportLoadingAddress#" cfsqltype="cf_sql_varchar">,
						returnAddress = <cfqueryparam value="#arguments.frmstruct.exportReturnAddress#" cfsqltype="cf_sql_varchar">
					WHERE
						LoadStopID = <cfqueryparam value="#arguments.lastInsertedStopId#" cfsqltype="cf_sql_varchar"> AND
						StopNo = <cfqueryparam value="1" cfsqltype="cf_sql_integer">
				</cfquery>
			<cfelse>
				<cfquery name="qUpdateLoadStopIntermodalExport" datasource="#application.dsn#">
					insert into LoadStopIntermodalExport(
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
							returnAddress)
					values(
							<cfqueryparam value="#lastInsertedStopId#" cfsqltype="cf_sql_varchar">,
							<cfqueryparam value="1" cfsqltype="cf_sql_integer">,
							<cfqueryparam value="#arguments.frmstruct.exportDateDispatched#" cfsqltype="cf_sql_date">,
							<cfqueryparam value="#arguments.frmstruct.exportDateMtAvailableForPickup#" cfsqltype="cf_sql_date">,
							<cfqueryparam value="#arguments.frmstruct.exportsteamShipLine#" cfsqltype="cf_sql_varchar">,
							<cfqueryparam value="#arguments.frmstruct.exportDemurrageFreeTimeExpirationDate#" cfsqltype="cf_sql_date">,
							<cfqueryparam value="#arguments.frmstruct.exportvesselName#" cfsqltype="cf_sql_varchar">,
							<cfqueryparam value="#arguments.frmstruct.exportPerDiemFreeTimeExpirationDate#" cfsqltype="cf_sql_date">,
							<cfqueryparam value="#arguments.frmstruct.exportVoyage#" cfsqltype="cf_sql_varchar">,
							<cfqueryparam value="#arguments.frmstruct.exportEmptyPickupDate#" cfsqltype="cf_sql_date">,
							<cfqueryparam value="#arguments.frmstruct.exportseal#" cfsqltype="cf_sql_varchar">,
							<cfqueryparam value="#arguments.frmstruct.exportBooking#" cfsqltype="cf_sql_varchar">,
							<cfqueryparam value="#arguments.frmstruct.exportScheduledLoadingDate#" cfsqltype="cf_sql_date">,
							<cfqueryparam value="#arguments.frmstruct.exportScheduledLoadingTime#" cfsqltype="cf_sql_varchar">,
							<cfqueryparam value="#arguments.frmstruct.exportVesselCutoffDate#" cfsqltype="cf_sql_date">,
							<cfqueryparam value="#arguments.frmstruct.exportLoadingDate#" cfsqltype="cf_sql_date">,
							<cfqueryparam value="#arguments.frmstruct.exportVesselLoadingWindow#" cfsqltype="cf_sql_varchar">,
							<cfqueryparam value="#arguments.frmstruct.exportLoadingDelayDetectionStartDate#" cfsqltype="cf_sql_date">,
							<cfqueryparam value="#arguments.frmstruct.exportLoadingDelayDetectionStartTime#" cfsqltype="cf_sql_varchar">,
							<cfqueryparam value="#arguments.frmstruct.exportRequestedLoadingDate#" cfsqltype="cf_sql_date">,
							<cfqueryparam value="#arguments.frmstruct.exportRequestedLoadingTime#" cfsqltype="cf_sql_varchar">,
							<cfqueryparam value="#arguments.frmstruct.exportLoadingDelayDetectionEndDate#" cfsqltype="cf_sql_date">,
							<cfqueryparam value="#arguments.frmstruct.exportLoadingDelayDetectionEndTime#" cfsqltype="cf_sql_varchar">,
							<cfqueryparam value="#arguments.frmstruct.exportETS#" cfsqltype="cf_sql_date">,
							<cfqueryparam value="#arguments.frmstruct.exportReturnDate#" cfsqltype="cf_sql_date">,
							<cfqueryparam value="#arguments.frmstruct.exportEmptyPickupAddress#" cfsqltype="cf_sql_varchar">,
							<cfqueryparam value="#arguments.frmstruct.exportLoadingAddress#" cfsqltype="cf_sql_varchar">,
							<cfqueryparam value="#arguments.frmstruct.exportReturnAddress#" cfsqltype="cf_sql_varchar">)
				</cfquery>
			</cfif>

		<cfreturn 1>
	</cffunction>

</cfcomponent>