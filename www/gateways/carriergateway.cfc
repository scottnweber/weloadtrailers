<cfcomponent output="false">
<cffunction name="init" access="public" output="false" returntype="void">
	<cfargument name="dsn" type="string" required="yes" />
	<cfset variables.dsn = Application.dsn />
</cffunction>
<!--- Get Carrier Offices --->
<cffunction name="getCarrierOffice" access="public" output="false" returntype="any">
    <cfargument name="carrierid" type="any" required="no">
	<CFSTOREDPROC PROCEDURE="USP_GetCarrierOfficeDetails" DATASOURCE="#variables.dsn#">
		<cfif isdefined('carrierid') and len(carrierid)>
		 	<CFPROCPARAM VALUE="#arguments.carrierid#" cfsqltype="CF_SQL_VARCHAR">
		 <cfelse>
		 	<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR">
		 </cfif>
		 <CFPROCRESULT NAME="qrygetcarrieroffice">
	</CFSTOREDPROC>
    <cfreturn qrygetcarrieroffice>
</cffunction>
<cffunction name="getAttachedFiles" access="public" returntype="query">
	<cfargument name="linkedid" type="string">
	<cfargument name="fileType" type="string">

	<cfquery name="getFilesAttached" datasource="#variables.dsn#">
		select * from FileAttachments where linked_id=<cfqueryparam value="#arguments.linkedid#" cfsqltype="cf_sql_varchar"> and linked_to=<cfqueryparam value="#arguments.filetype#" cfsqltype="cf_sql_integer">
	</cfquery>

	<cfreturn getFilesAttached>
</cffunction>
<!--- Add Carrier --->
<cffunction name="AddCarrier" access="public" output="false" returntype="any">
    <cfargument name="formStruct" type="struct" required="yes">
    <cfset resultStruct ={}>
    
    <cfif structKeyExists(arguments.formStruct, "venderId") AND trim(arguments.formStruct.venderId) NEQ "">
       <cfquery name="qSystemSetupOptions" datasource="#variables.dsn#">
          SELECT AllowDuplicateVendorCode
          FROM SystemConfig WHERE CompanyID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#session.CompanyID#">
      </cfquery>
      <cfif qSystemSetupOptions.AllowDuplicateVendorCode EQ 0>
        <cfquery name="qFilterDuplicateVendorId" datasource="#variables.dsn#">
            SELECT count(*) as count
            FROM Carriers
            WHERE VendorID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.venderId#">
            AND CompanyID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#session.CompanyID#">
         </cfquery>
         <cfif qFilterDuplicateVendorId.count GT 0>
         <cfset resultStruct['msg'] ="Vendor code already in use, please enter a valid vendor code.">
            <cfset resultStruct['duplicateVendorId'] =1>
       		<cfreturn resultStruct>
         </cfif>
      </cfif>
    </cfif>

	<cfif structKeyExists(arguments.formStruct,"isShowDollar")>
		<cfset var isShowDollar = 1>
	<cfelse>
		<cfset var isShowDollar = 0>
	</cfif>

  <cfif structKeyExists(arguments.formStruct,"carrierEmailAvailableLoads")>
    <cfset var carrierEmailAvailableLoads = 1>
  <cfelse>
    <cfset var carrierEmailAvailableLoads = 0>
  </cfif>
  <cfif structKeyExists(arguments.formStruct,"RatePerMile")>
    <cfset var RatePerMile =ReplaceNoCase(ReplaceNoCase(arguments.formStruct.RatePerMile,'$','','ALL'),',','','ALL')>
  <cfelse>
    <cfset var RatePerMile =0>
  </cfif>
  <cfif structKeyExists(arguments.formStruct, "DispatchFeeAmount")>
    <cfset var DispatchFeeAmount =ReplaceNoCase(ReplaceNoCase(arguments.formStruct.DispatchFeeAmount,'$','','ALL'),',','','ALL')>
  <cfelse>
    <cfset var DispatchFeeAmount =0>
  </cfif>
  <cfif structKeyExists(arguments.formStruct, "DispatchFee")>
    <cfset var DispatchFee =ReplaceNoCase(ReplaceNoCase(arguments.formStruct.DispatchFee,'%','','ALL'),',','','ALL')>
  <cfelse>
    <cfset var DispatchFee =0>
  </cfif>
  <CFSTOREDPROC PROCEDURE="USP_InsertCarrier" DATASOURCE="#variables.dsn#">
    <cfprocparam cfsqltype="cf_sql_varchar" value="#session.CompanyID#">,
    <cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.CarrierName#">,
    <cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.MCNumber#">,
    <cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.Address#">,
    <cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.RegNumber#">,
   
    <cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.TaxID#">,  
    <cfif structKeyExists(arguments.formStruct, "equipment") and  len(arguments.formStruct.equipment)>
      <cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.equipment#">,
    <cfelse>
      <cfprocparam cfsqltype="cf_sql_varchar" value="" null="true">,
    </cfif>
    <cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.RemitName#">,
    <cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.RemitAddress#">,
    <cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.RemitCity#">,
    <cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.RemitState#">,
    <cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.RemitZipcode#">,
    <cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.RemitContact#">,
    <cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.RemitPhone#">,
    <cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.RemitFax#">,
    <cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.InsCompany#">,
    <cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.InsComPhone#">,
    <cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.InsAgent#">,
    <cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.InsAgentPhone#">,
    <cfprocparam cfsqltype="cf_sql_varchar" value="#Left(arguments.formStruct.InsPolicyNo,49)#">,
    <cfif len(trim(arguments.formStruct.InsExpDate))>
      <cfprocparam cfsqltype="cf_sql_date" value="#arguments.formStruct.InsExpDate#">,
    <cfelse>
      <cfprocparam cfsqltype="cf_sql_date" value="" null="true">,
    </cfif>
    <cfprocparam cfsqltype="cf_sql_bit" value="#arguments.formStruct.Track1099#">,
    <cfif len(trim(ReplaceNoCase(ReplaceNoCase(arguments.formStruct.InsLimit,',','','ALL'),'$','','ALL'))) AND LSParseCurrency(trim(ReplaceNoCase(ReplaceNoCase(arguments.formStruct.InsLimit,',','','ALL'),'$','','ALL'))) GT 0>
      <cfprocparam cfsqltype="cf_sql_real" value="#LSParseCurrency(trim(ReplaceNoCase(ReplaceNoCase(arguments.formStruct.InsLimit,',','','ALL'),'$','','ALL')))#">,
    <cfelse>
      <cfprocparam cfsqltype="cf_sql_real" value="0">,
    </cfif>
    <cfif listlen(arguments.formStruct.State) gt 0>
      <cfprocparam cfsqltype="cf_sql_varchar" value="#listfirst(arguments.formStruct.State)#">,
    <cfelse>
      <cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.State#">,
    </cfif>
    <cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.Zipcode#">,
    <cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.EquipmentNotes#">,
    <cfprocparam cfsqltype="cf_sql_tinyint" value="#arguments.formStruct.Status#">,
    <cfprocparam cfsqltype="cf_sql_varchar" value="#session.adminUserName#">,
    <cfprocparam cfsqltype="cf_sql_varchar" value="#session.adminUserName#">,
    <cfprocparam cfsqltype="cf_sql_timestamp" value="#Now()#">,
    <cfprocparam cfsqltype="cf_sql_timestamp" value="#Now()#">,
    <cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.City#">,
    <cfif len(arguments.formStruct.Country) lte 0>
      <cfprocparam cfsqltype="cf_sql_varchar" value="" null="true">,
    <cfelse>
      <cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.Country#">,
    </cfif>
    <cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.Website#">
    <cfprocparam cfsqltype="cf_sql_varchar" value="False">,
    <cfprocparam cfsqltype="cf_sql_varchar" value="False">,
    <cfprocparam cfsqltype="cf_sql_varchar" value="False">,
    <cfprocparam cfsqltype="cf_sql_varchar" value="False">,
    <cfprocparam cfsqltype="cf_sql_varchar" value="False">,
    <cfprocparam cfsqltype="cf_sql_varchar" value="#cgi.REMOTE_ADDR#">,
    <cfprocparam cfsqltype="cf_sql_varchar" value="#cgi.HTTP_USER_AGENT#">,
    <cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.notes#">,
    <cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.terms#" null="#not len(arguments.formStruct.terms)#">,
    <cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.venderId#" null="#not len(arguments.formStruct.venderId)#">,
    <cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.DOTNumber#" null="#not len(arguments.formStruct.DOTNumber)#">,
    <cfprocparam cfsqltype="cf_sql_varchar" value="1">,
    <cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.risk_assessment#" null="#not len(arguments.formStruct.risk_assessment)#">,
    <cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.MobileAppPassword#" null="#not len(arguments.formStruct.MobileAppPassword)#">,
    <cfprocparam VALUE="#isShowDollar#" cfsqltype="cf_sql_bit">,
    <cfprocparam VALUE="#arguments.formStruct.IsCarrier#" cfsqltype="cf_sql_bit">,
    <cfprocparam VALUE="#arguments.formStruct.PreConMethod#" cfsqltype="cf_sql_tinyint">,
    <cfprocparam VALUE="#val(arguments.formStruct.LoadLimit)#" cfsqltype="cf_sql_tinyint">,
    <cfif structKeyExists(arguments.formStruct, "defaultCurrency")>
      <cfprocparam VALUE="#arguments.formStruct.defaultCurrency#" cfsqltype="cf_sql_integer" null="#YesNoFormat(not Len(arguments.formStruct.defaultCurrency))#">,
    <cfelse>
      <cfprocparam VALUE="" cfsqltype="cf_sql_integer" null="true">,
    </cfif>
    <cfprocparam VALUE="#carrierEmailAvailableLoads#" cfsqltype="cf_sql_bit">,
    <!--- #837: Carrier screen add new field Dispatch Fee: Begins --->
    <cfif Len(trim(DispatchFee)) AND isnumeric(DispatchFee)>
      <cfprocparam value="#DispatchFee#" cfsqltype="cf_sql_float">,
    <cfelse>
      <cfprocparam value="0" cfsqltype="cf_sql_float">,
    </cfif>
    <!--- #837: Carrier screen add new field Dispatch Fee: Ends --->
    <cfif structKeyExists(arguments.formStruct,"SCAC") and Len(arguments.formStruct.SCAC)>
      <cfprocparam VALUE="#arguments.formStruct.SCAC#" cfsqltype="cf_sql_varchar">,
    <cfelse>
      <cfprocparam VALUE="" cfsqltype="cf_sql_varchar" null="true">,
    </cfif>
    <cfif structKeyExists(arguments.formStruct,"memo") and Len(arguments.formStruct.memo)>
      <cfprocparam VALUE="#arguments.formStruct.memo#" cfsqltype="cf_sql_varchar">,
    <cfelse>
      <cfprocparam VALUE="" cfsqltype="cf_sql_varchar" null="true">,
    </cfif>
    <cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.InsCompanyCargo#">,
    <cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.InsComPhoneCargo#">,
    <cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.InsAgentCargo#">,
    <cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.InsAgentPhoneCargo#">,
    <cfprocparam cfsqltype="cf_sql_varchar" value="#Left(arguments.formStruct.InsPolicyNoCargo,49)#">,
    <cfif len(trim(arguments.formStruct.InsExpDateCargo))>
      <cfprocparam cfsqltype="cf_sql_date" value="#arguments.formStruct.InsExpDateCargo#">,
    <cfelse>
      <cfprocparam cfsqltype="cf_sql_date" value="" null="true">,
    </cfif>
    <cfif len(trim(ReplaceNoCase(ReplaceNoCase(arguments.formStruct.InsLimitCargo,',','','ALL'),'$','','ALL'))) AND LSParseCurrency(trim(ReplaceNoCase(ReplaceNoCase(arguments.formStruct.InsLimitCargo,',','','ALL'),'$','','ALL'))) GT 0>
      <cfprocparam cfsqltype="cf_sql_real" value="#LSParseCurrency(trim(ReplaceNoCase(ReplaceNoCase(arguments.formStruct.InsLimitCargo,',','','ALL'),'$','','ALL')))#">,
    <cfelse>
      <cfprocparam cfsqltype="cf_sql_real" value="0">,
    </cfif>
    <cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.InsCompanyGeneral#">,
    <cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.InsComPhoneGeneral#">,
    <cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.InsAgentGeneral#">,
    <cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.InsAgentPhoneGeneral#">,
    <cfprocparam cfsqltype="cf_sql_varchar" value="#Left(arguments.formStruct.InsPolicyNoGeneral,49)#">,
    <cfif len(trim(arguments.formStruct.InsExpDateGeneral))>
      <cfprocparam cfsqltype="cf_sql_date" value="#arguments.formStruct.InsExpDateGeneral#">,
    <cfelse>
      <cfprocparam cfsqltype="cf_sql_date" value="" null="true">,
    </cfif>
    <cfif len(trim(ReplaceNoCase(ReplaceNoCase(arguments.formStruct.InsLimitGeneral,',','','ALL'),'$','','ALL'))) AND LSParseCurrency(trim(ReplaceNoCase(ReplaceNoCase(arguments.formStruct.InsLimitGeneral,',','','ALL'),'$','','ALL'))) GT 0>
      <cfprocparam cfsqltype="cf_sql_real" value="#LSParseCurrency(trim(ReplaceNoCase(ReplaceNoCase(arguments.formStruct.InsLimitGeneral,',','','ALL'),'$','','ALL')))#">,
    <cfelse>
      <cfprocparam cfsqltype="cf_sql_real" value="0">,
    </cfif>
    <cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.InsEmail#">,
    <cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.InsEmailCargo#">,
    <cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.InsEmailGeneral#">,

    <cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.InsuranceCompanyAddress#">,
    <cfprocparam cfsqltype="cf_sql_timestamp" value="#arguments.formStruct.ExpirationDate#"  null="#yesNoFormat(NOT len(arguments.formStruct.ExpirationDate))#">,
    <cfprocparam cfsqltype="cf_sql_timestamp" value="#now()#">,
    <cfprocparam cfsqltype="cf_sql_bit" value="#arguments.formStruct.commonStatus#">,
    <cfprocparam cfsqltype="cf_sql_bit" value="#arguments.formStruct.contractStatus#">,
    <cfprocparam cfsqltype="cf_sql_bit" value="#arguments.formStruct.BrokerStatus#">,
    <cfprocparam cfsqltype="cf_sql_bit" value="#arguments.formStruct.commonAppPending#">,
    <cfprocparam cfsqltype="cf_sql_bit" value="#arguments.formStruct.contractAppPending#">,
    <cfprocparam cfsqltype="cf_sql_bit" value="#arguments.formStruct.BrokerAppPending#">,
    <cfprocparam cfsqltype="cf_sql_bit" value="#arguments.formStruct.BIPDInsRequired#">,
    <cfprocparam cfsqltype="cf_sql_bit" value="#arguments.formStruct.cargoInsRequired#">,
    <cfprocparam cfsqltype="cf_sql_bit" value="#arguments.formStruct.BIPDInsonFile#">,
    <cfprocparam cfsqltype="cf_sql_bit" value="#arguments.formStruct.cargoInsonFile#">,
    <cfprocparam cfsqltype="cf_sql_bit" value="#arguments.formStruct.householdGoods#">,
    <cfprocparam cfsqltype="cf_sql_timestamp" value="#arguments.formStruct.CARGOExpirationDate#" null="#yesNoFormat(NOT len(arguments.formStruct.CARGOExpirationDate))#">,
    <cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.InsuranceCompanyAddressCargo#">,
    <cfprocparam cfsqltype="cf_sql_bit" value="#arguments.formStruct.householdGoodsCargo#">,
    <cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.InsuranceCompanyAddressGeneral#">,
    <cfprocparam cfsqltype="cf_sql_bit" value="#arguments.formStruct.householdGoodsGeneral#">,
    <cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.employeeType#">
    <cfif structKeyExists(arguments.formStruct, "source")>
      <cfprocparam VALUE="#arguments.formStruct.source#" cfsqltype="cf_sql_varchar">,
    <cfelse>
      <cfprocparam VALUE="" cfsqltype="cf_sql_varchar" null="true">,
    </cfif>
    <cfif structKeyExists(arguments.formStruct, "FactoringID")>
      <cfprocparam VALUE="#arguments.formStruct.FactoringID#" cfsqltype="cf_sql_varchar">,
    <cfelse>
      <cfprocparam VALUE="" cfsqltype="cf_sql_varchar" null="true">,
    </cfif>
    <cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.ContactPerson#">,
    <cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.Phone#">,
    <cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.Fax#">,
    <cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.CellPhone#">,
    <cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.Email#">,
    <cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.Tollfree#">

    <cfif structKeyExists(arguments.formStruct, "PhoneExt")>
      <cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.PhoneExt#">,
    <cfelse>
      <cfprocparam VALUE="" cfsqltype="cf_sql_varchar" null="true">,
    </cfif> 
    <cfif structKeyExists(arguments.formStruct, "FaxExt")>
      <cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.FaxExt#">,
    <cfelse>
      <cfprocparam VALUE="" cfsqltype="cf_sql_varchar" null="true">,
    </cfif> 
    <cfif structKeyExists(arguments.formStruct, "TollfreeExt")>
      <cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.TollfreeExt#">,
    <cfelse>
      <cfprocparam VALUE="" cfsqltype="cf_sql_varchar" null="true">,
    </cfif>
    <cfif structKeyExists(arguments.formStruct, "CellPhoneExt")>
      <cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.CellPhoneExt#">,
    <cfelse>
      <cfprocparam VALUE="" cfsqltype="cf_sql_varchar" null="true">,
    </cfif>
    <cfif len(trim(RatePerMile)) AND isnumeric(RatePerMile)>
      <cfprocparam cfsqltype="cf_sql_money" value="#RatePerMile#">
    <cfelse>
      <cfprocparam cfsqltype="cf_sql_money" value="0">
    </cfif>
    <cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.RemitEmail#">,
    <cfif len(trim(arguments.formStruct.FF)) AND isnumeric(arguments.formStruct.FF)>
      <cfprocparam cfsqltype="CF_SQL_FLOAT" value="#arguments.formStruct.FF#">
    <cfelse>
      <cfprocparam cfsqltype="CF_SQL_FLOAT" value="0">
    </cfif>
    <cfif len(trim(DispatchFeeAmount)) AND isnumeric(DispatchFeeAmount)>
      <cfprocparam cfsqltype="cf_sql_money" value="#DispatchFeeAmount#">
    <cfelse>
      <cfprocparam cfsqltype="cf_sql_money" value="0">
    </cfif>
    <cfprocresult name="qLastInsertedCarrier">
  </CFSTOREDPROC>

  <cfset var i = 1>
  <cfloop list="#arguments.formStruct.numberOfCommodity#" index="index">
    <cfset var carrRateComm = evaluate("arguments.formStruct.txt_carrRateComm_#i#") >
	  <cfset var custRateComm = evaluate("arguments.formStruct.txt_custRateComm_#i#") >
	  <cfset var commodityType = evaluate("arguments.formStruct.sel_commodityType_#i#") >

	  <cfif carrRateComm contains '$'>
      <cfset carrRateComm = val(right(carrRateComm,len(carrRateComm)-1))>
    <cfelse>
      <cfset carrRateComm = val(carrRateComm)>
	  </cfif>

    <cfif custRateComm contains '%'>
		  <cfset custRateComm = val(left(custRateComm,len(custRateComm)-1))>
    <cfelse>
		  <cfset custRateComm = val(custRateComm)>
	  </cfif>
	  <cfquery name="qInsertCommodity" datasource="#variables.dsn#">
  		INSERT INTO carrier_commodity(CARRIERID,carrrate,COMMODITYID,CarrRateOfCustTotal)
  		VALUES(
  			<cfqueryparam cfsqltype="cf_sql_varchar" value="#qLastInsertedCarrier.LastInsertedCarrierID#">,
  			<cfqueryparam value="#carrRateComm#">,
  			<cfqueryparam cfsqltype="cf_sql_varchar" value="#commodityType#">,
  			<cfqueryparam value="#custRateComm#">
  		)
	  </cfquery>
	  <cfset i++ >
  </cfloop>

  <cfloop from="1" to="#arguments.formStruct.totalequipcount#" index="indx">
    <cfset var EquipmentID = arguments.formStruct["EquipmentID_#indx#"]>
    <cfif structKeyExists(arguments.formStruct, "IsDefault_#indx#")>
      <cfset var IsDefault =1>
    <cfelse>
      <cfset var IsDefault =0>
    </cfif>
    <cfif len(trim(EquipmentID))>
      <cfquery name="qInsertCommodity" datasource="#variables.dsn#">
        INSERT INTO CarrierEquipments(EquipmentID,CarrierID,IsDefault,CreatedBy,ModifiedBy)
        VALUES(
            <cfqueryparam cfsqltype="cf_sql_varchar" value="#EquipmentID#">,
            <cfqueryparam cfsqltype="cf_sql_varchar" value="#qLastInsertedCarrier.LastInsertedCarrierID#">,
            <cfqueryparam cfsqltype="cf_sql_bit" value="#IsDefault#">,
            <cfqueryparam cfsqltype="cf_sql_varchar" value="#session.adminusername#">,
            <cfqueryparam cfsqltype="cf_sql_varchar" value="#session.adminusername#">
          )
      </cfquery>
    </cfif>
  </cfloop>

  <cfquery name="qInsCarrierLanes" datasource="#variables.dsn#">
    INSERT INTO CarrierLanes (
    CarrierLaneID,
    CarrierID,
    PickUpCity,
    PickUpState,
    PickUpZip,
    DeliveryCity,
    DeliveryState,
    DeliveryZip,
    Cost,
    Miles,
    RatePerMile,
    IntransitStops,
    CreatedBy,
    ModifiedBy
    ) 
  VALUES(
    NEWID(),
    <cfqueryparam value="#qLastInsertedCarrier.LastInsertedCarrierID#" cfsqltype="cf_sql_varchar">,
    <cfqueryparam value="#arguments.formStruct.City#" cfsqltype="cf_sql_varchar" null="#not len(arguments.formStruct.City)#">,
    <cfqueryparam value="#arguments.formStruct.State#" cfsqltype="cf_sql_varchar" null="#not len(arguments.formStruct.State)#">,
    <cfqueryparam value="#arguments.formStruct.Zipcode#" cfsqltype="cf_sql_varchar" null="#not len(arguments.formStruct.Zipcode)#">,
    <cfqueryparam value="#arguments.formStruct.City#" cfsqltype="cf_sql_varchar" null="#not len(arguments.formStruct.City)#">,
    <cfqueryparam value="#arguments.formStruct.State#" cfsqltype="cf_sql_varchar" null="#not len(arguments.formStruct.State)#">,
    <cfqueryparam value="#arguments.formStruct.Zipcode#" cfsqltype="cf_sql_varchar" null="#not len(arguments.formStruct.Zipcode)#">,
    0,
    0,
    0,
    0,
    <cfqueryparam value="#session.adminUserName#" cfsqltype="cf_sql_varchar">,
    <cfqueryparam value="#session.adminUserName#" cfsqltype="cf_sql_varchar">
    )
  </cfquery>

	<cfset resultStruct['msg'] ="Carrier has been added successfully.">
  <cfset resultStruct['duplicateVendorId'] =0>
  <cfset resultStruct['Carrier_Id'] =qLastInsertedCarrier.LastInsertedCarrierID>
  <cfreturn resultStruct>
</cffunction>

<!--- Add Driver --->
<cffunction name="AddDriver" access="public" output="false" returntype="any">
  <cfargument name="formStruct" type="struct" required="yes">
  
	<cfif structKeyExists(arguments.formStruct,"isShowDollar")>
    <cfset var isShowDollar = 1>
  <cfelse>
    <cfset var isShowDollar = 0>
  </cfif>

  <cfif structKeyExists(arguments.formStruct,"carrierEmailAvailableLoads")>
    <cfset var carrierEmailAvailableLoads = 1>
  <cfelse>
    <cfset var carrierEmailAvailableLoads = 0>
  </cfif>
  <cfif structKeyExists(arguments.formStruct,"CalculateDHMiles")>
    <cfset var CalculateDHMiles = 1>
  <cfelse>
    <cfset var CalculateDHMiles = 0>
  </cfif>
  <cfset var RatePerMile =ReplaceNoCase(ReplaceNoCase(arguments.formStruct.RatePerMile,'$','','ALL'),',','','ALL')>
  <CFSTOREDPROC PROCEDURE="USP_InsertDriver" DATASOURCE="#variables.dsn#">
    <cfprocparam cfsqltype="cf_sql_varchar" value="#session.CompanyID#">,
    <cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.CarrierName#">,
    <cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.MCNumber#">,
    <cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.Address#">,
    <cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.RegNumber#">,
    <cfif len(arguments.formStruct.equipment) lte 0>
      <cfprocparam cfsqltype="cf_sql_varchar" value="" null="true">,
    <cfelse>
      <cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.equipment#">,
    </cfif>
    <cfif len(trim(arguments.formStruct.InsExpDate))>
      <cfprocparam cfsqltype="cf_sql_date" value="#arguments.formStruct.InsExpDate#">,
    <cfelse>
      <cfprocparam cfsqltype="cf_sql_date" value="" null="true">,
    </cfif>
    <cfif listlen(arguments.formStruct.State) gt 0>
      <cfprocparam cfsqltype="cf_sql_varchar" value="#listfirst(arguments.formStruct.State)#">,
    <cfelse>
      <cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.State#">,
    </cfif>
    <cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.Zipcode#">,
    <cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.EquipmentNotes#">,
    <cfprocparam cfsqltype="cf_sql_tinyint" value="#arguments.formStruct.Status#">,
    <cfprocparam cfsqltype="cf_sql_varchar" value="#session.adminUserName#">,
    <cfprocparam cfsqltype="cf_sql_varchar" value="#session.adminUserName#">,
    <cfprocparam cfsqltype="cf_sql_timestamp" value="#Now()#">,
    <cfprocparam cfsqltype="cf_sql_timestamp" value="#Now()#">,
    <cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.City#">,
    <cfif len(arguments.formStruct.Country) lte 0>
      <cfprocparam cfsqltype="cf_sql_varchar" value="" null="true">,
    <cfelse>
      <cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.Country#">,
    </cfif>
    <cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.Phone#">,
    <cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.Fax#">,
    <cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.CellPhone#">,
    <cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.Email#">,
    <cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.Tollfree#">,
    <cfprocparam cfsqltype="cf_sql_varchar" value="False">,
    <cfprocparam cfsqltype="cf_sql_varchar" value="False">,
    <cfprocparam cfsqltype="cf_sql_varchar" value="False">,
    <cfprocparam cfsqltype="cf_sql_varchar" value="False">,
    <cfprocparam cfsqltype="cf_sql_varchar" value="False">,
    <cfprocparam cfsqltype="cf_sql_varchar" value="#cgi.REMOTE_ADDR#">,
    <cfprocparam cfsqltype="cf_sql_varchar" value="#cgi.HTTP_USER_AGENT#">,
    <cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.notes#">,
    <cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.terms#" null="#not len(arguments.formStruct.terms)#">,
    <cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.licState#">,
    <cfif len(trim(arguments.formStruct.DOBDate))>
      <cfprocparam cfsqltype="cf_sql_date" value="#arguments.formStruct.DOBDate#">,
    <cfelse>
      <cfprocparam cfsqltype="cf_sql_date" value="" null="true">,
    </cfif>
    <cfif len(trim(arguments.formStruct.hiredDate))>
      <cfprocparam cfsqltype="cf_sql_date" value="#arguments.formStruct.hiredDate#">,
    <cfelse>
      <cfprocparam cfsqltype="cf_sql_date" value="" null="true">,
    </cfif>
    <cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.ss#">,
    <cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.employeeType#">,
    <cfif len(trim(arguments.formStruct.lastDrugTest))>
      <cfprocparam cfsqltype="cf_sql_date" value="#arguments.formStruct.lastDrugTest#">,
    <cfelse>
      <cfprocparam cfsqltype="cf_sql_date" value="" null="true">,
    </cfif>
    <cfif len(trim(arguments.formStruct.CDLExpires))>
      <cfprocparam cfsqltype="cf_sql_date" value="#arguments.formStruct.CDLExpires#">,
    <cfelse>
      <cfprocparam cfsqltype="cf_sql_date" value="" null="true">,
    </cfif>
    <cfprocparam cfsqltype="cf_sql_bit" value="#arguments.formStruct.IsCarrier#">,
    <cfprocparam VALUE="#arguments.formStruct.PreConMethod#" cfsqltype="cf_sql_tinyint">,
    <cfprocparam VALUE="#val(arguments.formStruct.LoadLimit)#" cfsqltype="cf_sql_tinyint">,
    <cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.MobileAppPassword#" null="#not len(arguments.formStruct.MobileAppPassword)#">,
    <cfprocparam VALUE="#isShowDollar#" cfsqltype="cf_sql_bit">,
    <cfif structKeyExists(arguments.formStruct, "defaultCurrency")>
      <cfprocparam VALUE="#arguments.formStruct.defaultCurrency#" cfsqltype="cf_sql_integer" null="#YesNoFormat(not Len(arguments.formStruct.defaultCurrency))#">,
    <cfelse>
      <cfprocparam VALUE="" cfsqltype="cf_sql_integer" null="true">,
    </cfif>
    <cfprocparam VALUE="#carrierEmailAvailableLoads#" cfsqltype="cf_sql_bit">,
    <cfprocparam VALUE="#arguments.formStruct.venderId#" cfsqltype="cf_sql_varchar">,
    <cfif structKeyExists(arguments.formStruct, "company_name") and len(arguments.formStruct.company_name)>
        <cfprocparam VALUE="#arguments.formStruct.company_name#" cfsqltype="cf_sql_varchar">,
      <cfelse>
        <cfprocparam VALUE="" cfsqltype="cf_sql_varchar" null="true">,
    </cfif> 
    <cfif structKeyExists(arguments.formStruct, "irs_ein") and len(arguments.formStruct.irs_ein)>
      <cfprocparam VALUE="#arguments.formStruct.irs_ein#" cfsqltype="cf_sql_varchar">,
    <cfelse>
      <cfprocparam VALUE="" cfsqltype="cf_sql_varchar" null="true">,
    </cfif> 
    <cfif structKeyExists(arguments.formStruct, "fuelCardNo") and len(arguments.formStruct.fuelCardNo)>
      <cfprocparam VALUE="#arguments.formStruct.fuelCardNo#" cfsqltype="cf_sql_varchar">,
    <cfelse>
      <cfprocparam VALUE="" cfsqltype="cf_sql_varchar" null="true">,
    </cfif> 
    <cfif structKeyExists(arguments.formStruct, "PhoneExt")>
      <cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.PhoneExt#">,
    <cfelse>
      <cfprocparam VALUE="" cfsqltype="cf_sql_varchar" null="true">,
    </cfif> 
    <cfif structKeyExists(arguments.formStruct, "FaxExt")>
      <cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.FaxExt#">,
    <cfelse>
      <cfprocparam VALUE="" cfsqltype="cf_sql_varchar" null="true">,
    </cfif> 
    <cfif structKeyExists(arguments.formStruct, "TollfreeExt")>
      <cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.TollfreeExt#">
    <cfelse>
      <cfprocparam VALUE="" cfsqltype="cf_sql_varchar" null="true">
    </cfif> 
    <cfif structKeyExists(arguments.formStruct, "CellPhoneExt")>
      <cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.CellPhoneExt#">
    <cfelse>
      <cfprocparam VALUE="" cfsqltype="cf_sql_varchar" null="true">
    </cfif> 
    <cfif len(trim(RatePerMile)) AND isnumeric(RatePerMile)>
      <cfprocparam cfsqltype="cf_sql_money" value="#RatePerMile#">
    <cfelse>
      <cfprocparam cfsqltype="cf_sql_money" value="0">
    </cfif>
    <cfprocparam VALUE="#CalculateDHMiles#" cfsqltype="cf_sql_bit">
    <cfprocresult name="qLastInsertedCarrier">
  </CFSTOREDPROC>

  <cfset var i = 1>
  <cfloop list="#arguments.formStruct.numberOfCommodity#" index="index">
    <cfset var carrRateComm = evaluate("arguments.formStruct.txt_carrRateComm_#i#") >
    <cfset var custRateComm = evaluate("arguments.formStruct.txt_custRateComm_#i#") >
    <cfset var commodityType = evaluate("arguments.formStruct.sel_commodityType_#i#") >

    <cfif carrRateComm contains '$'>
      <cfset carrRateComm = val(right(carrRateComm,len(carrRateComm)-1))>
    <cfelse>
      <cfset carrRateComm = val(carrRateComm)>
    </cfif>

    <cfif custRateComm contains '%'>
      <cfset custRateComm = val(left(custRateComm,len(custRateComm)-1))>
    <cfelse>
      <cfset custRateComm = val(custRateComm)>
    </cfif>
    <cfquery name="qInsertCommodity" datasource="#variables.dsn#">
      INSERT INTO carrier_commodity
      (
        CARRIERID,carrrate,COMMODITYID,CarrRateOfCustTotal
      )
      VALUES
      (
        <cfqueryparam cfsqltype="cf_sql_varchar" value="#qLastInsertedCarrier.LastInsertedCarrierID#">,
        <cfqueryparam value="#carrRateComm#">,
        <cfqueryparam cfsqltype="cf_sql_varchar" value="#commodityType#">,
        <cfqueryparam value="#custRateComm#">
      )
    </cfquery>
    <cfset i++ >
  </cfloop>
  <cfset resultStruct={}>
  
	<cfset resultStruct['msg'] ="Driver has been added successfully.">
    <cfset resultStruct['driverID'] = qLastInsertedCarrier.LastInsertedCarrierID>
  <cfreturn resultStruct>
</cffunction>

<!--- Add carrier Offices --->
<cffunction name="AddCarrierOffices" access="public" output="false" returntype="any">
   <cfargument name="formStruct" type="struct"  required="yes">
   <cfargument name="fieldID" type="any" required="yes">
        <cfquery name="getLastCarrierID" datasource="#variables.dsn#">
           select top 1 carrierID from carriers 
           where companyid = <cfqueryparam value="#session.companyid#" cfSqltype="cf_sql_varchar">
           order by createddatetime desc
        </cfquery>
       <cfif isDefined("getLastCarrierID.recordcount") and getLastCarrierID.recordcount gt 0>
            <cfset carrierid=getLastCarrierID.carrierID>
        </cfif>

  <cfif isdefined("formStruct.Office_Name#arguments.fieldID#") and len('formStruct.Office_Name#arguments.fieldID#') gt 0>
      <cfset Office_Name=evaluate("arguments.formStruct.Office_Name#arguments.fieldID#")>
  </cfif>
  <cfif isdefined("formStruct.Office_Manager#arguments.fieldID#") and len('formStruct.Office_Manager#arguments.fieldID#') gt 0>
          <cfset Office_Manager=evaluate("arguments.formStruct.Office_Manager#arguments.fieldID#")>
  </cfif>
  <cfif isdefined("formStruct.Office_Phone#arguments.fieldID#") and len('formStruct.Office_Phone#arguments.fieldID#') gt 0>
         <cfset Office_Phone=evaluate("arguments.formStruct.Office_Phone#arguments.fieldID#")>
  </cfif>
  <cfif isdefined("formStruct.Office_Email#arguments.fieldID#") and len('formStruct.Office_Email#arguments.fieldID#') gt 0>
        <cfset Office_Email=evaluate("arguments.formStruct.Office_Email#arguments.fieldID#")>
  </cfif>
  <cfif isdefined("formStruct.Office_Fax#arguments.fieldID#") and len('formStruct.Office_Fax#arguments.fieldID#') gt 0>
        <cfset Office_Fax=evaluate("arguments.formStruct.Office_Fax#arguments.fieldID#")>
   </cfif>

  <cfif len(Office_Name)>
         <cfquery name="qryinsertoffice" datasource="#variables.dsn#">
            insert into CarrierOffices(CarrierID,Location,Manager,PhoneNo,EmailID,Fax)
            values( <cfqueryparam cfsqltype="cf_sql_varchar" value="#getLastCarrierID.carrierID#">,
                    <cfqueryparam cfsqltype="cf_sql_varchar" value="#Office_Name#">,
                    <cfqueryparam cfsqltype="cf_sql_varchar" value="#Office_Manager#">,
                    <cfqueryparam cfsqltype="cf_sql_varchar" value="#Office_Phone#">,
                    <cfqueryparam cfsqltype="cf_sql_varchar" value="#Office_Email#">,
                    <cfqueryparam cfsqltype="cf_sql_varchar" value="#Office_Fax#">
                    )
         </cfquery>
</cfif>
<cfreturn "Carrier has been added successfully.">
</cffunction>
<!--- Get Carriers --->
<cffunction name="getAllCarriers" aceess="public" output="false" returntype="any">
    <cfargument name="carrierid" required="no" type="string">
    <cfargument name="sortorder" required="no" type="any">
    <cfargument name="sortby" required="no" type="any">
	<CFSTOREDPROC PROCEDURE="USP_GetCarrierDetails" DATASOURCE="#variables.dsn#">
		<cfif isdefined('arguments.carrierid') and len(arguments.carrierid)>
		 	<CFPROCPARAM VALUE="#arguments.carrierid#" cfsqltype="CF_SQL_VARCHAR">
		 <cfelse>
		 	<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR">
		 </cfif>
     <CFPROCPARAM VALUE="#session.CompanyID#" cfsqltype="CF_SQL_VARCHAR">
		 <CFPROCRESULT NAME="qrygetCarriers">
	</CFSTOREDPROC>

   <cfif isDefined("arguments.sortorder") and isDefined("arguments.sortby") and len(arguments.sortby)>

          <cfquery datasource="#variables.dsn#" name="getnewAgent">
                      select *, ISNULL(RatePerMile,0) AS RatePrMile  from Carriers WITH (NOLOCK)
                      where companyid = <cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar">
                      order by #arguments.sortby# #arguments.sortorder#;
          </cfquery>

         <cfreturn getnewAgent>

    </cfif>

   <cfreturn qrygetCarriers>
</cffunction>



<!--- Get Carriers Info --->
<cffunction name="getCarriersInfo" access="public" output="false" returntype="query">
    <cfargument name="carrierid" required="yes">

	<cfquery name="qryGetCarrierInfo" datasource="#variables.dsn#">
        SELECT Carriers.CarrierName AS CarrierName, ISNULL(Carriers.RatePerMile,0) AS RatePerMile, Carriers.Address AS location, Carriers.City as city, Carriers.StateCode AS state, Carriers.ZipCode AS zip, Carriers.phone AS phone, carriers.fax as fax
		FROM Carriers
        <!--- INNER JOIN States ON Carriers.StateID = States.StateID --->
        <cfif arguments.carrierid eq ''> <!--- if the load does not have a carrier, use null as carrierid to return an empty query --->
        	WHERE CarrierID = null
        <cfelse>
        	WHERE CarrierID = <cfqueryparam value="#arguments.carrierid#" cfsqltype="cf_sql_varchar">
        </cfif>
        AND CompanyID = <cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar">
    </cfquery>


   <cfreturn qryGetCarrierInfo>
</cffunction>

<!--- get Carrier Commodity By Id --->
<cffunction name="getCarrierCommodityById" access="remote" output="false" returntype="query">
    <cfargument name="carrierid" required="yes" type="string">
	<cfargument name="LoadStopID" required="yes" type="string">
	<cfquery name="qGetCarrierCommodityById" datasource="#Application.dsn#">
        SELECT carrierid,carrrate,commodityid,CarrRateOfCustTotal,id
		FROM carrier_commodity
        WHERE carrierid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.carrierid#">
    </cfquery>
   <cfreturn qGetCarrierCommodityById>
</cffunction>

<!---   Carrier --->
<cffunction name="UpdateCarrier" access="public" output="false" returntype="any">
  <cfargument name="formStruct" type="struct" required="yes">
	<cfset resultStruct ={}>
	<cfif structKeyExists(arguments.formStruct,"isShowDollar")>
		<cfset var isShowDollar = 1>
	<cfelse>
		<cfset var isShowDollar = 0>
	</cfif>

  <cfif structKeyExists(arguments.formStruct,"carrierEmailAvailableLoads")>
    <cfset var carrierEmailAvailableLoads = 1>
  <cfelse>
    <cfset var carrierEmailAvailableLoads = 0>
  </cfif>

  <cfset var RatePerMile =ReplaceNoCase(ReplaceNoCase(arguments.formStruct.RatePerMile,'$','','ALL'),',','','ALL')>
  <cfif structKeyExists(arguments.formStruct, "DispatchFeeAmount")>
    <cfset var DispatchFeeAmount =ReplaceNoCase(ReplaceNoCase(arguments.formStruct.DispatchFeeAmount,'$','','ALL'),',','','ALL')>
  <cfelse>
    <cfset var DispatchFeeAmount =0>
  </cfif>
  <cfif structKeyExists(arguments.formStruct, "DispatchFee")>
    <cfset var DispatchFee =ReplaceNoCase(ReplaceNoCase(arguments.formStruct.DispatchFee,'%','','ALL'),',','','ALL')>
  <cfelse>
    <cfset var DispatchFee =0>
  </cfif>
  <cfif trim(arguments.formStruct.venderId) NEQ "">
    <cfquery name="qSystemSetupOptions" datasource="#variables.dsn#">
        SELECT AllowDuplicateVendorCode
        FROM SystemConfig WHERE CompanyID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#session.CompanyID#">
    </cfquery>
    <cfif qSystemSetupOptions.AllowDuplicateVendorCode EQ 0>
      <cfquery name="qFilterDuplicateVendorId" datasource="#variables.dsn#">
        SELECT count(*) as count
        FROM Carriers
        WHERE VendorID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.venderId#">
        AND CARRIERID != <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.editid#">
        AND CompanyID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#session.CompanyID#">
       </cfquery>
       <cfif qFilterDuplicateVendorId.count GT 0>
       	<cfset resultStruct.msg ="Vendor code already in use, please enter a valid vendor code.">
            <cfset resultStruct.duplicateVendorId =1>
       		<cfreturn resultStruct>
       </cfif>
    </cfif>
  </cfif>
  <cfquery name="qVendorDetails" datasource="#variables.dsn#">
    SELECT VendorID, AYBImport, MyCarrierPackets
    FROM Carriers
    WHERE CARRIERID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.editid#">
  </cfquery>
  
  <CFSTOREDPROC PROCEDURE="USP_UpdateCarrier" DATASOURCE="#variables.dsn#">
    <cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.editid#">,
    <cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.CarrierName#">,
    <cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.MCNumber#">,
    <cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.Address#">,
    <cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.RegNumber#">,

    <cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.TaxID#">,  
    <cfif structKeyExists(arguments.formStruct, "equipment") and  len(arguments.formStruct.equipment)>
      <cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.equipment#">,
    <cfelse>
      <cfprocparam cfsqltype="cf_sql_varchar" value="" null="true">,
    </cfif>
		<cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.RemitName#">,
    <cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.RemitAddress#">,
    <cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.RemitCity#">,
    <cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.RemitState#">,
    <cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.RemitZipcode#">,
    <cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.RemitContact#">,
    <cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.RemitPhone#">,
    <cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.RemitFax#">,
    <cfif isDefined("arguments.formStruct.InsCompany")>
      <cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.InsCompany#">,
    <cfelse>
      <cfprocparam cfsqltype="cf_sql_varchar" value="" null="true">,
    </cfif>
    <cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.InsComPhone#">,
    <cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.InsAgent#">,
    <cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.InsAgentPhone#">,
    <!--- Somtimes the policy number comes in with a long string of text begining with 'A Licensing'. Test for it and do not save it. --->
    <cfif Left(#arguments.formStruct.InsPolicyNo#,11) neq 'A Licensing'>
      <cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.InsPolicyNo#">,
    <cfelse>
		 	<cfprocparam cfsqltype="cf_sql_varchar" value="" null="true">,
    </cfif>
    <cfif len(trim(arguments.formStruct.InsExpDate))>
      <cfprocparam cfsqltype="cf_sql_date" value="#arguments.formStruct.InsExpDate#">,
    <cfelse>
      <cfprocparam cfsqltype="cf_sql_date" value="" null="true">,
    </cfif>
    <cfprocparam cfsqltype="cf_sql_bit" value="#arguments.formStruct.Track1099#">,

    <cfif len(trim(ReplaceNoCase(ReplaceNoCase(arguments.formStruct.InsLimit,',','','ALL'),'$','','ALL'))) AND LSParseCurrency(trim(ReplaceNoCase(ReplaceNoCase(arguments.formStruct.InsLimit,',','','ALL'),'$','','ALL'))) GT 0>
      <cfprocparam cfsqltype="cf_sql_real" value="#LSParseCurrency(trim(ReplaceNoCase(ReplaceNoCase(arguments.formStruct.InsLimit,',','','ALL'),'$','','ALL')))#">,
    <cfelse>
      <cfprocparam cfsqltype="cf_sql_real" value="0">,
    </cfif>
    <cfif listlen(arguments.formStruct.State) gt 0>
      <cfprocparam cfsqltype="cf_sql_varchar" value="#listfirst(arguments.formStruct.State)#">,
    <cfelse>
      <cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.State#">,
    </cfif>
    <cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.Zipcode#">,
    <cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.EquipmentNotes#">,
    <cfprocparam cfsqltype="cf_sql_tinyint" value="#arguments.formStruct.Status#">,
    <cfprocparam cfsqltype="cf_sql_varchar" value="#session.adminUserName#">,
    <cfprocparam cfsqltype="cf_sql_timestamp" value="#Now()#">,
    <cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.City#">,
    <cfif len(arguments.formStruct.Country) lte 0>
      <cfprocparam cfsqltype="cf_sql_varchar" value="" null="true">,
    <cfelse>
      <cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.Country#">,
    </cfif>

    <cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.Website#">,

    <cfprocparam cfsqltype="cf_sql_varchar" value="#cgi.REMOTE_ADDR#">,
		<cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.notes#">,
    <cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.terms#" null="#not len(arguments.formStruct.terms)#">,
		<cfif qVendorDetails.AYBImport EQ false>
      <cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.venderId#" null="#not len(arguments.formStruct.venderId)#">,
    <cfelse>
      <cfprocparam cfsqltype="cf_sql_varchar" value="#qVendorDetails.venderId#" null="#not len(qVendorDetails.venderId)#">,
	  </cfif>
    <cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.DOTNumber#" null="#not len(arguments.formStruct.DOTNumber)#">,
  	<cfif structKeyExists(arguments.formStruct,"bit_addWatch") AND arguments.formStruct.bit_addWatch GT 0 >
  	  <cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.bit_addWatch#" null="#not len(arguments.formStruct.bit_addWatch)#">,
  	<cfelse>
      <cfprocparam cfsqltype="cf_sql_varchar" value="0">,
  	</cfif>
	  <cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.risk_assessment#" null="#not len(arguments.formStruct.risk_assessment)#">,
    <cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.MobileAppPassword#" null="#not len(arguments.formStruct.MobileAppPassword)#">,
    <cfprocparam VALUE="#isShowDollar#" cfsqltype="cf_sql_bit">,
    <cfprocparam VALUE="#arguments.formStruct.PreConMethod#" cfsqltype="cf_sql_tinyint">,
    <cfprocparam VALUE="#val(arguments.formStruct.LoadLimit)#" cfsqltype="cf_sql_tinyint">,
    <cfif structKeyExists(arguments.formStruct, "defaultCurrency")>
		  <cfprocparam VALUE="#val(arguments.formStruct.defaultCurrency)#" cfsqltype="cf_sql_tinyint" null="#YesNoFormat(not Len(arguments.formStruct.defaultCurrency))#">,
	   <cfelse>
		  <cfprocparam cfsqltype="cf_sql_tinyint" value="" null="true">,
	  </cfif>
    <cfprocparam VALUE="#carrierEmailAvailableLoads#" cfsqltype="cf_sql_bit">,
	<!--- #837: Carrier screen add new field Dispatch Fee: Begins --->
	  <cfif Len(trim(DispatchFee)) AND isnumeric(DispatchFee)>
      <cfprocparam value="#DispatchFee#" cfsqltype="cf_sql_float">,
	  <cfelse>
      <cfprocparam value="0" cfsqltype="cf_sql_float">,
	  </cfif>
    <cfif structKeyExists(arguments.formStruct, "MyCarrierPackets") AND arguments.formStruct.MyCarrierPackets EQ 1>
      <cfprocparam VALUE=1 cfsqltype="cf_sql_bit">,
    <cfelse>
      <cfprocparam VALUE="#qVendorDetails.MyCarrierPackets#" cfsqltype="cf_sql_bit">,
    </cfif>
    <cfif structKeyExists(arguments.formStruct,"SCAC") and Len(arguments.formStruct.SCAC)>
      <cfprocparam VALUE="#arguments.formStruct.SCAC#" cfsqltype="cf_sql_varchar">,
    <cfelse>
      <cfprocparam VALUE="" cfsqltype="cf_sql_varchar" null="true">,
    </cfif>
    <cfif structKeyExists(arguments.formStruct,"memo") and Len(arguments.formStruct.memo)>
      <cfprocparam VALUE="#arguments.formStruct.memo#" cfsqltype="cf_sql_varchar">,
    <cfelse>
      <cfprocparam VALUE="" cfsqltype="cf_sql_varchar" null="true">,
    </cfif>
    <cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.InsCompanyCargo#">,
    <cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.InsComPhoneCargo#">,
    <cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.InsAgentCargo#">,
    <cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.InsAgentPhoneCargo#">,
    <cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.InsPolicyNoCargo#">,
    <cfif len(trim(arguments.formStruct.InsExpDateCargo))>
      <cfprocparam cfsqltype="cf_sql_date" value="#arguments.formStruct.InsExpDateCargo#">,
    <cfelse>
      <cfprocparam cfsqltype="cf_sql_date" value="" null="true">,
    </cfif>
    <cfif len(trim(ReplaceNoCase(ReplaceNoCase(arguments.formStruct.InsLimitCargo,',','','ALL'),'$','','ALL'))) AND LSParseCurrency(trim(ReplaceNoCase(ReplaceNoCase(arguments.formStruct.InsLimitCargo,',','','ALL'),'$','','ALL'))) GT 0>
      <cfprocparam cfsqltype="cf_sql_real" value="#LSParseCurrency(trim(ReplaceNoCase(ReplaceNoCase(arguments.formStruct.InsLimitCargo,',','','ALL'),'$','','ALL')))#">
    <cfelse>
      <cfprocparam cfsqltype="cf_sql_real" value="0">
    </cfif>
    <cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.InsCompanyGeneral#">,
    <cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.InsComPhoneGeneral#">,
    <cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.InsAgentGeneral#">,
    <cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.InsAgentPhoneGeneral#">,
    <cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.InsPolicyNoGeneral#">
    <cfif len(trim(arguments.formStruct.InsExpDateGeneral))>
      <cfprocparam cfsqltype="cf_sql_date" value="#arguments.formStruct.InsExpDateGeneral#">,
    <cfelse>
      <cfprocparam cfsqltype="cf_sql_date" value="" null="true">,
    </cfif>
    <cfif len(trim(ReplaceNoCase(ReplaceNoCase(arguments.formStruct.InsLimitGeneral,',','','ALL'),'$','','ALL'))) AND LSParseCurrency(trim(ReplaceNoCase(ReplaceNoCase(arguments.formStruct.InsLimitGeneral,',','','ALL'),'$','','ALL'))) GT 0>
      <cfprocparam cfsqltype="cf_sql_real" value="#LSParseCurrency(trim(ReplaceNoCase(ReplaceNoCase(arguments.formStruct.InsLimitGeneral,',','','ALL'),'$','','ALL')))#">
    <cfelse>
      <cfprocparam cfsqltype="cf_sql_real" value="0">
    </cfif>
   
    <cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.InsEmail#">,
    <cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.InsEmailCargo#">,
    <cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.InsEmailGeneral#">,

    <cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.InsuranceCompanyAddress#">,
    <cfprocparam cfsqltype="cf_sql_timestamp" value="#arguments.formStruct.ExpirationDate#"  null="#yesNoFormat(NOT len(arguments.formStruct.ExpirationDate))#">,
    <cfprocparam cfsqltype="cf_sql_bit" value="#arguments.formStruct.commonStatus#">,
    <cfprocparam cfsqltype="cf_sql_bit" value="#arguments.formStruct.contractStatus#">,
    <cfprocparam cfsqltype="cf_sql_bit" value="#arguments.formStruct.BrokerStatus#">,
    <cfprocparam cfsqltype="cf_sql_bit" value="#arguments.formStruct.commonAppPending#">,
    <cfprocparam cfsqltype="cf_sql_bit" value="#arguments.formStruct.contractAppPending#">,
    <cfprocparam cfsqltype="cf_sql_bit" value="#arguments.formStruct.BrokerAppPending#">,
    <cfprocparam cfsqltype="cf_sql_bit" value="#arguments.formStruct.BIPDInsRequired#">,
    <cfprocparam cfsqltype="cf_sql_bit" value="#arguments.formStruct.cargoInsRequired#">,
    <cfprocparam cfsqltype="cf_sql_bit" value="#arguments.formStruct.BIPDInsonFile#">,
    <cfprocparam cfsqltype="cf_sql_bit" value="#arguments.formStruct.cargoInsonFile#">,
    <cfprocparam cfsqltype="cf_sql_bit" value="#arguments.formStruct.householdGoods#">,
    <cfprocparam cfsqltype="cf_sql_timestamp" value="#arguments.formStruct.CARGOExpirationDate#" null="#yesNoFormat(NOT len(arguments.formStruct.CARGOExpirationDate))#">,
    <cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.InsuranceCompanyAddressCargo#">,
    <cfprocparam cfsqltype="cf_sql_bit" value="#arguments.formStruct.householdGoodsCargo#">,
    <cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.InsuranceCompanyAddressGeneral#">,
    <cfprocparam cfsqltype="cf_sql_bit" value="#arguments.formStruct.householdGoodsGeneral#">,
    <cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.employeeType#">,
    <cfif structKeyExists(arguments.formStruct, "FactoringID")>
      <cfprocparam VALUE="#arguments.formStruct.FactoringID#" cfsqltype="cf_sql_varchar">
    <cfelse>
      <cfprocparam VALUE="" cfsqltype="cf_sql_varchar" null="true">
    </cfif>
    <cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.ContactPerson#">,
    <cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.Phone#">,
    <cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.Fax#">,
    <cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.CellPhone#">,
    <cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.Email#">,
    <cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.Tollfree#">

    <cfif structKeyExists(arguments.formStruct, "PhoneExt")>
      <cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.PhoneExt#">,
    <cfelse>
      <cfprocparam VALUE="" cfsqltype="cf_sql_varchar" null="true">,
    </cfif> 
    <cfif structKeyExists(arguments.formStruct, "FaxExt")>
      <cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.FaxExt#">,
    <cfelse>
      <cfprocparam VALUE="" cfsqltype="cf_sql_varchar" null="true">,
    </cfif> 
    <cfif structKeyExists(arguments.formStruct, "TollfreeExt")>
      <cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.TollfreeExt#">,
    <cfelse>
      <cfprocparam VALUE="" cfsqltype="cf_sql_varchar" null="true">,
    </cfif>
    <cfif structKeyExists(arguments.formStruct, "CellPhoneExt")>
      <cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.CellPhoneExt#">,
    <cfelse>
      <cfprocparam VALUE="" cfsqltype="cf_sql_varchar" null="true">,
    </cfif>
    <cfif len(trim(RatePerMile)) AND isnumeric(RatePerMile)>
      <cfprocparam cfsqltype="cf_sql_money" value="#RatePerMile#">
    <cfelse>
      <cfprocparam cfsqltype="cf_sql_money" value="0">
    </cfif>
    <cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.RemitEmail#">,
    <cfif len(trim(arguments.formStruct.FF)) AND isnumeric(arguments.formStruct.FF)>
      <cfprocparam cfsqltype="CF_SQL_FLOAT" value="#arguments.formStruct.FF#">
    <cfelse>
      <cfprocparam cfsqltype="CF_SQL_FLOAT" value="0">
    </cfif>
    <cfif len(trim(DispatchFeeAmount)) AND isnumeric(DispatchFeeAmount)>
      <cfprocparam cfsqltype="cf_sql_money" value="#DispatchFeeAmount#">
    <cfelse>
      <cfprocparam cfsqltype="cf_sql_money" value="0">
    </cfif>
  </CFSTOREDPROC>

  <cfquery name="qDeleteCommodity" datasource="#variables.dsn#">
    DELETE FROM carrier_commodity
    WHERE CARRIERID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.editid#">
  </cfquery>
  <cfset var i = 1>
  <cfloop list="#arguments.formStruct.numberOfCommodity#" index="index">
  	<cfset var carrRateComm = evaluate("arguments.formStruct.txt_carrRateComm_#i#") >
    <cfset var custRateComm = evaluate("arguments.formStruct.txt_custRateComm_#i#") >
  	<cfset var commodityType = evaluate("arguments.formStruct.sel_commodityType_#i#") >

  	<cfif carrRateComm contains '$'>
  		<cfset carrRateComm = val(right(carrRateComm,len(carrRateComm)-1))>
    <cfelse>
  		<cfset carrRateComm = val(carrRateComm)>
  	</cfif>

  	<cfif custRateComm contains '%'>
  		<cfset custRateComm = val(left(custRateComm,len(custRateComm)-1))>
    <cfelse>
  		<cfset custRateComm = val(custRateComm)>
  	</cfif>
    <cfquery name="qInsertCommodity" datasource="#variables.dsn#">
  		INSERT INTO carrier_commodity(CARRIERID,carrrate,COMMODITYID,CarrRateOfCustTotal)
  		VALUES(
  			<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.editid#">,
  			<cfqueryparam value="#carrRateComm#">,
  			<cfqueryparam cfsqltype="cf_sql_varchar" value="#commodityType#">,
  			<cfqueryparam value="#custRateComm#">
  		)
    </cfquery>
    <cfset i++ >
  </cfloop>

  <cfloop from="1" to="#arguments.formStruct.totalequipcount#" index="indx">
    <cfset var CarrierEquipmentID = arguments.formStruct["CarrierEquipmentID_#indx#"]>
    <cfset var EquipmentID = arguments.formStruct["EquipmentID_#indx#"]>
    <cfset var TruckTrailerOption = arguments.formStruct["relEquipmentID_#indx#"]>
    <cfset var DriverContactID = arguments.formStruct["DriverContactID_#indx#"]>
    <cfif structKeyExists(arguments.formStruct, "IsDefault_#indx#")>
      <cfset var IsDefault =1>
    <cfelse>
      <cfset var IsDefault =0>
    </cfif>
    <cfquery name="qUpdE" datasource="#variables.dsn#">
      UPDATE Equipments SET TruckTrailerOption = NULL WHERE TruckTrailerOption = <cfqueryparam cfsqltype="cf_sql_varchar" value="#TruckTrailerOption#" null="#not len(TruckTrailerOption)#">
    </cfquery>
    <cfif len(trim(CarrierEquipmentID))>
      <cfif len(trim(EquipmentID))>
        <cfquery name="qUpdate" datasource="#variables.dsn#">
          UPDATE CarrierEquipments SET 
          EquipmentID=<cfqueryparam cfsqltype="cf_sql_varchar" value="#EquipmentID#">,
          IsDefault=<cfqueryparam cfsqltype="cf_sql_bit" value="#IsDefault#">,
          ModifiedBy=<cfqueryparam cfsqltype="cf_sql_varchar" value="#session.adminusername#">,
          ModifiedDateTime=getdate(),
          DriverContactID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#DriverContactID#" null="#not len(DriverContactID)#">
          WHERE CarrierEquipmentID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#CarrierEquipmentID#">
        </cfquery>
      <cfelse>
        <cfquery name="qDelete" datasource="#variables.dsn#">
          DELETE FROM CarrierEquipments WHERE CarrierEquipmentID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#CarrierEquipmentID#">
        </cfquery>
      </cfif>
    <cfelse>
      <cfif len(trim(EquipmentID))>
        <cfquery name="qInsert" datasource="#variables.dsn#">
          INSERT INTO CarrierEquipments(EquipmentID,CarrierID,IsDefault,CreatedBy,ModifiedBy,DriverContactID)
          VALUES(
              <cfqueryparam cfsqltype="cf_sql_varchar" value="#EquipmentID#">,
              <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.editid#">,
              <cfqueryparam cfsqltype="cf_sql_bit" value="#IsDefault#">,
              <cfqueryparam cfsqltype="cf_sql_varchar" value="#session.adminusername#">,
              <cfqueryparam cfsqltype="cf_sql_varchar" value="#session.adminusername#">,
              <cfqueryparam cfsqltype="cf_sql_varchar" value="#DriverContactID#" null="#not len(DriverContactID)#">
            )
        </cfquery>
      </cfif>
    </cfif>
    <cfif len(trim(EquipmentID))>
      <cfquery name="qUpd" datasource="#variables.dsn#">
        UPDATE Equipments 
        SET TruckTrailerOption = <cfqueryparam cfsqltype="cf_sql_varchar" value="#TruckTrailerOption#"  null="#not len(TruckTrailerOption)#">  
        WHERE EquipmentID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#EquipmentID#" null="#not len(EquipmentID)#">
      </cfquery>
    </cfif>

    <cfquery name="qUpdTT" datasource="#variables.dsn#">
      UPDATE Equipments SET TruckTrailerOption = <cfqueryparam cfsqltype="cf_sql_varchar" value="#EquipmentID#"  null="#not len(EquipmentID)#"> WHERE EquipmentID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#TruckTrailerOption#" null="#not len(TruckTrailerOption)#">
    </cfquery>

  </cfloop>
  <cfset resultStruct.msg ="Carrier has been updated successfully.">
  <cfset resultStruct.duplicateVendorId =0>
  <cfreturn resultStruct>

</cffunction>

 <!--- Update Driver --->
  <cffunction name="UpdateDriver" access="public" output="false" returntype="any">
    <cfargument name="formStruct" type="struct" required="yes">
	<cfset resultStruct={}>

	<cfif structKeyExists(arguments.formStruct,"isShowDollar")>
    <cfset var isShowDollar = 1>
  <cfelse>
    <cfset var isShowDollar = 0>
  </cfif>


  <cfif structKeyExists(arguments.formStruct,"carrierEmailAvailableLoads")>
    <cfset var carrierEmailAvailableLoads = 1>
  <cfelse>
    <cfset var carrierEmailAvailableLoads = 0>
  </cfif>
  <cfif structKeyExists(arguments.formStruct,"CalculateDHMiles")>
    <cfset var CalculateDHMiles = 1>
  <cfelse>
    <cfset var CalculateDHMiles = 0>
  </cfif>
	<cfset var RatePerMile =ReplaceNoCase(ReplaceNoCase(arguments.formStruct.RatePerMile,'$','','ALL'),',','','ALL')>
  <cfif len(trim(arguments.formStruct.equipment))>
    <cfquery name="qUpd" datasource="#variables.dsn#">
        UPDATE Carriers SET EquipmentID = NULL WHERE EquipmentID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.equipment#">
    </cfquery>
  </cfif>
  <cfquery name="qUpd" datasource="#variables.dsn#">
    UPDATE Equipments SET Driver = NULL WHERE Driver = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.CarrierName#"> AND CompanyID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#session.CompanyID#">
  </cfquery>
  <CFSTOREDPROC PROCEDURE="USP_UpdateDriver" DATASOURCE="#variables.dsn#">
    <cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.editid#">,
    <cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.CarrierName#">,
    <cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.MCNumber#">,
    <cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.Address#">,
    <cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.RegNumber#">,
    <cfif structKeyExists(arguments.formStruct, "equipment") and  len(arguments.formStruct.equipment)>
      <cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.equipment#">,
    <cfelse>
      <cfprocparam cfsqltype="cf_sql_varchar" value="" null="true">,
    </cfif>
    <cfif len(trim(arguments.formStruct.InsExpDate))>
      <cfprocparam cfsqltype="cf_sql_date" value="#arguments.formStruct.InsExpDate#">,
    <cfelse>
      <cfprocparam cfsqltype="cf_sql_date" value="" null="true">,
    </cfif>
    <cfif listlen(arguments.formStruct.State) gt 0>
      <cfprocparam cfsqltype="cf_sql_varchar" value="#listfirst(arguments.formStruct.State)#">,
    <cfelse>
      <cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.State#">,
    </cfif>
    <cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.Zipcode#">,
    <cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.EquipmentNotes#">,
    <cfprocparam cfsqltype="cf_sql_tinyint" value="#arguments.formStruct.Status#">,
    <cfprocparam cfsqltype="cf_sql_varchar" value="#session.adminUserName#">,
    <cfprocparam cfsqltype="cf_sql_timestamp" value="#Now()#">,
    <cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.City#">,
    <cfif len(arguments.formStruct.Country) lte 0>
      <cfprocparam cfsqltype="cf_sql_varchar" value="" null="true">,
    <cfelse>
      <cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.Country#">,
    </cfif>
    <cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.Phone#">,
    <cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.Fax#">,
    <cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.CellPhone#">,
    <cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.Email#">,
    <cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.Tollfree#">,
    <cfprocparam cfsqltype="cf_sql_varchar" value="#cgi.REMOTE_ADDR#">,
    <cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.notes#">,
    <cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.terms#" null="#not len(arguments.formStruct.terms)#">,
    <cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.licState#">,
    <cfif len(trim(arguments.formStruct.DOBDate))>
      <cfprocparam cfsqltype="cf_sql_date" value="#arguments.formStruct.DOBDate#">,
    <cfelse>
      <cfprocparam cfsqltype="cf_sql_date" value="" null="true">,
    </cfif>
    <cfif len(trim(arguments.formStruct.hiredDate))>
      <cfprocparam cfsqltype="cf_sql_date" value="#arguments.formStruct.hiredDate#">,
    <cfelse>
      <cfprocparam cfsqltype="cf_sql_date" value="" null="true">,
    </cfif>
    <cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.ss#">,
    <cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.employeeType#">,
    <cfif len(trim(arguments.formStruct.lastDrugTest))>
      <cfprocparam cfsqltype="cf_sql_date" value="#arguments.formStruct.lastDrugTest#">,
    <cfelse>
      <cfprocparam cfsqltype="cf_sql_date" value="" null="true">,
    </cfif>
    <cfif len(trim(arguments.formStruct.CDLExpires))>
      <cfprocparam cfsqltype="cf_sql_date" value="#arguments.formStruct.CDLExpires#">,
    <cfelse>
      <cfprocparam cfsqltype="cf_sql_date" value="" null="true">,
    </cfif>
    <cfprocparam VALUE="#arguments.formStruct.PreConMethod#" cfsqltype="cf_sql_tinyint">,
    <cfprocparam VALUE="#val(arguments.formStruct.LoadLimit)#" cfsqltype="cf_sql_tinyint">,
    <cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.MobileAppPassword#" null="#not len(arguments.formStruct.MobileAppPassword)#">,
    <cfprocparam VALUE="#isShowDollar#" cfsqltype="cf_sql_bit">,
    <cfif structKeyExists(arguments.formStruct, "defaultCurrency")>
      <cfprocparam VALUE="#arguments.formStruct.defaultCurrency#" cfsqltype="cf_sql_integer" null="#YesNoFormat(not Len(arguments.formStruct.defaultCurrency))#">,
    <cfelse>
      <cfprocparam VALUE="" cfsqltype="cf_sql_integer" null="true">,
    </cfif>
    <cfprocparam VALUE="#carrierEmailAvailableLoads#" cfsqltype="cf_sql_bit">,
    <cfprocparam VALUE="#arguments.formStruct.venderId#" cfsqltype="cf_sql_varchar">,
    <cfif structKeyExists(arguments.formStruct, "company_name") and len(arguments.formStruct.company_name)>
      <cfprocparam VALUE="#arguments.formStruct.company_name#" cfsqltype="cf_sql_varchar">,
    <cfelse>
      <cfprocparam VALUE="" cfsqltype="cf_sql_varchar" null="true">,
    </cfif> 
    <cfif structKeyExists(arguments.formStruct, "irs_ein") and len(arguments.formStruct.irs_ein)>
      <cfprocparam VALUE="#arguments.formStruct.irs_ein#" cfsqltype="cf_sql_varchar">,
    <cfelse>
      <cfprocparam VALUE="" cfsqltype="cf_sql_varchar" null="true">,
    </cfif> 
    <cfif structKeyExists(arguments.formStruct, "fuelCardNo") and len(arguments.formStruct.fuelCardNo)>
      <cfprocparam VALUE="#arguments.formStruct.fuelCardNo#" cfsqltype="cf_sql_varchar">,
    <cfelse>
      <cfprocparam VALUE="" cfsqltype="cf_sql_varchar" null="true">,
    </cfif> 
    <cfif structKeyExists(arguments.formStruct, "PhoneExt")>
      <cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.PhoneExt#">,
    <cfelse>
      <cfprocparam VALUE="" cfsqltype="cf_sql_varchar" null="true">,
    </cfif> 
    <cfif structKeyExists(arguments.formStruct, "FaxExt")>
      <cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.FaxExt#">,
    <cfelse>
      <cfprocparam VALUE="" cfsqltype="cf_sql_varchar" null="true">,
    </cfif> 
    <cfif structKeyExists(arguments.formStruct, "TollfreeExt")>
      <cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.TollfreeExt#">,
    <cfelse>
      <cfprocparam VALUE="" cfsqltype="cf_sql_varchar" null="true">,
    </cfif> 
    <cfif structKeyExists(arguments.formStruct, "CellPhoneExt")>
      <cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.CellPhoneExt#">,
    <cfelse>
      <cfprocparam VALUE="" cfsqltype="cf_sql_varchar" null="true">,
    </cfif> 
    <cfif structKeyExists(arguments.formStruct, "Track1099")>
      <cfprocparam cfsqltype="cf_sql_bit" value="#arguments.formStruct.Track1099#">,
    <cfelse>
      <cfprocparam cfsqltype="cf_sql_bit" value="" null="true">,
    </cfif>
    <cfif len(trim(RatePerMile)) AND isnumeric(RatePerMile)>
      <cfprocparam cfsqltype="cf_sql_money" value="#RatePerMile#">
    <cfelse>
      <cfprocparam cfsqltype="cf_sql_money" value="0">
    </cfif>
    <cfprocparam VALUE="#CalculateDHMiles#" cfsqltype="cf_sql_bit">
  </CFSTOREDPROC>

    <cfquery name="qDeleteCommodity" datasource="#variables.dsn#">
      DELETE FROM carrier_commodity
      WHERE CARRIERID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.editid#">
    </cfquery>
    <cfset var i = 1>
    <cfloop list="#arguments.formStruct.numberOfCommodity#" index="index">
      <cfset var carrRateComm = evaluate("arguments.formStruct.txt_carrRateComm_#i#") >
      <cfset var custRateComm = evaluate("arguments.formStruct.txt_custRateComm_#i#") >
      <cfset var commodityType = evaluate("arguments.formStruct.sel_commodityType_#i#") >

      <cfif carrRateComm contains '$'>
        <cfset carrRateComm = val(right(carrRateComm,len(carrRateComm)-1))>
      <cfelse>
        <cfset carrRateComm = val(carrRateComm)>
      </cfif>

      <cfif custRateComm contains '%'>
        <cfset custRateComm = val(left(custRateComm,len(custRateComm)-1))>
      <cfelse>
        <cfset custRateComm = val(custRateComm)>
      </cfif>
      <cfquery name="qInsertCommodity" datasource="#variables.dsn#">
        INSERT INTO carrier_commodity
        (
          CARRIERID,carrrate,COMMODITYID,CarrRateOfCustTotal
        )
        VALUES
        (
          <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.editid#">,
          <cfqueryparam value="#carrRateComm#">,
          <cfqueryparam cfsqltype="cf_sql_varchar" value="#commodityType#">,
          <cfqueryparam value="#custRateComm#">
        )
      </cfquery>
      <cfset i++ >
    </cfloop>
    <cfif structkeyexists(arguments.formStruct,"equipment") and len(trim(arguments.formStruct.equipment))>
      <cfquery name="qUpd" datasource="#variables.dsn#">
        UPDATE Equipments SET Driver = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.CarrierName#"> WHERE EquipmentID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.equipment#">
      </cfquery>
    </cfif>
    <cfset resultStruct['msg'] ="Driver has been updated successfully.">
    <cfset resultStruct['driverID']= arguments.formStruct.editid>
    <cfreturn resultStruct>
    
  </cffunction>

<!--- Update Carrier Offices --->
<cffunction name="UpdateCarrierOffices" access="public" output="false" returntype="any">
    <cfargument name="formStruct" type="struct"  required="yes">
    <cfargument name="fieldID" type="any" required="yes">

          <cfif isdefined("formStruct.CarrierOfficeID#arguments.fieldID#") and len('formStruct.CarrierOfficeID#arguments.fieldID#') gt 0>
             <cfset CarrierOfficeID=evaluate("arguments.formStruct.CarrierOfficeID#arguments.fieldID#")>
          </cfif>
          <cfif isdefined("formStruct.Office_Name#arguments.fieldID#") and len('formStruct.Office_Name#arguments.fieldID#') gt 0>
              <cfset Office_Name=evaluate("arguments.formStruct.Office_Name#arguments.fieldID#")>
          </cfif>
          <cfif isdefined("formStruct.Office_Manager#arguments.fieldID#") and len('formStruct.Office_Manager#arguments.fieldID#') gt 0>
                  <cfset Office_Manager=evaluate("arguments.formStruct.Office_Manager#arguments.fieldID#")>
          </cfif>
          <cfif isdefined("formStruct.Office_Phone#arguments.fieldID#") and len('formStruct.Office_Phone#arguments.fieldID#') gt 0>
                 <cfset Office_Phone=evaluate("arguments.formStruct.Office_Phone#arguments.fieldID#")>
          </cfif>
          <cfif isdefined("formStruct.Office_Email#arguments.fieldID#") and len('formStruct.Office_Email#arguments.fieldID#') gt 0>
                <cfset Office_Email=evaluate("arguments.formStruct.Office_Email#arguments.fieldID#")>
          </cfif>
          <cfif isdefined("formStruct.Office_Fax#arguments.fieldID#") and len('formStruct.Office_Fax#arguments.fieldID#') gt 0>
                <cfset Office_Fax=evaluate("arguments.formStruct.Office_Fax#arguments.fieldID#")>
          </cfif>
   <cfif len(CarrierOfficeID)  gt 1>

    <cfquery name="qryupdate" datasource="#variables.dsn#">
        update CarrierOffices
        set Location=<cfqueryparam cfsqltype="cf_sql_varchar" value="#trim(Office_Name)#">,
            Manager=<cfqueryparam cfsqltype="cf_sql_varchar" value="#trim(Office_Manager)#">,
			PhoneNo=<cfqueryparam cfsqltype="cf_sql_varchar" value="#trim(Office_Phone)#">,
			EmailID=<cfqueryparam cfsqltype="cf_sql_varchar" value="#trim(Office_Email)#">,
			Fax=<cfqueryparam cfsqltype="cf_sql_varchar" value="#trim(Office_Fax)#">
        where CarrierID=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.editid#"> and
              CarrierOfficeID=<cfqueryparam cfsqltype="cf_sql_varchar" value="#CarrierOfficeID#">
    </cfquery>

    <cfelse>

      <cfquery name="qryinsert" datasource="#variables.dsn#">
           insert into CarrierOffices(CarrierID,Location,Manager,PhoneNo,EmailID,Fax)
            values( '#arguments.formStruct.editid#',
                    <cfqueryparam cfsqltype="cf_sql_varchar" value="#trim(Office_Name)#">,
                    <cfqueryparam cfsqltype="cf_sql_varchar" value="#trim(Office_Manager)#">,
                    <cfqueryparam cfsqltype="cf_sql_varchar" value="#trim(Office_Phone)#">,
                    <cfqueryparam cfsqltype="cf_sql_varchar" value="#trim(Office_Email)#">,
                    <cfqueryparam cfsqltype="cf_sql_varchar" value="#trim(Office_Fax)#">
                    )
      </cfquery>

    </cfif>

</cffunction>
<!--- Delete Carrier --->
<cffunction name="deleteCarriers" access="public" returntype="any">
    <cfargument name="CarrierID" type="any" required="yes">
    <cftry>
    <cftransaction>
      <cfquery name="qrydelete" datasource="#variables.dsn#">
          delete from CarrierContacts
          where CarrierID=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.CarrierID#">
      </cfquery>
      <cfquery name="qDel" datasource="#variables.dsn#">
          delete from Carriers
          where CarrierID=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.CarrierID#">
      </cfquery>
    </cftransaction>
    <cfreturn "1">
    <cfcatch type="any">
        <cfreturn "0">
    </cfcatch>
    </cftry>
</cffunction>
<!--- Delete Carrier Contacts--->
<cffunction name="deleteCarrierContacts" access="public" returntype="any">
    <cfargument name="CarrierID" type="any" required="yes">
    <cftry>
    <cfquery name="qrydelete" datasource="#variables.dsn#">
        delete from CarrierContacts
        where CarrierID=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.CarrierID#">
    </cfquery>
    <cfreturn "1">
    <cfcatch type="any">
        <cfreturn "0">
    </cfcatch>
    </cftry>
</cffunction>
<!--- Delete Carrier Contacts--->
<cffunction name="deleteCarrierLookoutData" access="public" returntype="any">
    <cfargument name="CarrierID" type="any" required="yes">
    <cftry>
    <cfquery name="qrydelete" datasource="#variables.dsn#">
        delete from CLActivePendingInsurance
        where CarrierID=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.CarrierID#">
        delete from CLInsuranceHistory
        where CarrierID=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.CarrierID#">
    </cfquery>
    <cfreturn "1">
    <cfcatch type="any">
        <cfreturn "0">
    </cfcatch>
    </cftry>
</cffunction>
<!--- Delete Carrier Offices --->
<cffunction name="deleteCarriersoffices" access="public" returntype="any">
    <cfargument name="CarrierID" type="any" required="yes">
        <cftry>
        <cfquery name="qrydelete" datasource="#variables.dsn#">
            delete from CarrierOffices
            where CarrierID=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.CarrierID#">
        </cfquery>
        <cfreturn "Record has been deleted successfully.">
        <cfcatch type="any">
            <cfreturn "Deletion is not allowed because data is active in other records. ">
        </cfcatch>
        </cftry>
</cffunction>

<cffunction name="deleteCarrierLipublicfmcsa" access="public" returntype="any">
    <cfargument name="CarrierID" type="any" required="yes">
        <cftry>
        <cfquery name="qrydelete" datasource="#variables.dsn#">
            delete from lipublicfmcsa
            where carrierId= <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.CarrierID#">
        </cfquery>
        <cfreturn "Record has been deleted successfully.">
        <cfcatch type="any">
            <cfreturn "Deletion is not allowed because data is active in other records. ">
        </cfcatch>
        </cftry>
</cffunction>
<!--- Get Search Agent --->
<cffunction name="getSearchedCarrier" access="public" output="false" returntype="query">
	<cfargument name="searchText" required="yes" type="any">
    <cfargument name="pageNo" required="yes" type="any">
    <cfargument name="sortorder" required="no" type="any">
    <cfargument name="sortby" required="no" type="any">
    <cfargument name="IsCarrier" required="no" type="any" default="">
    <cfargument name="pending" required="no" type="any" default="0">

    <cfif not isdefined('arguments.searchText')>
  		<cfset arguments.searchText = "">
  	</cfif>
    <cfif not isdefined('arguments.pageNo')>
  		<cfset arguments.pageNo = 1>
  	</cfif>
    <cfif not isdefined('arguments.sortorder')>
  		<cfset arguments.sortorder = "ASC">
  	</cfif>
    <cfif not isdefined('arguments.sortby')>
  		<cfset arguments.sortby = "CarrierName">
  	</cfif>
    <cfif structKeyExists(form,"searchPickUpState") AND len(trim(form.searchPickUpState))>
      <cfset local.searchPickUpState = form.searchPickUpState>
    <cfelse>
      <cfset local.searchPickUpState = "">
    </cfif>
    <cfif structKeyExists(form,"searchEquipmentID") AND len(trim(form.searchEquipmentID))>
      <cfset local.searchEquipmentID = form.searchEquipmentID>
    <cfelse>
      <cfset local.searchEquipmentID = "">
    </cfif>
    <CFSTOREDPROC PROCEDURE="USP_GetCarrierList" DATASOURCE="#variables.dsn#">
      <CFPROCPARAM VALUE="#session.CompanyID#" CFSQLTYPE="CF_SQL_VARCHAR">
      <CFPROCPARAM VALUE="#arguments.pageNo#" CFSQLTYPE="CF_SQL_VARCHAR">
      <CFPROCPARAM VALUE="#arguments.sortBy#" CFSQLTYPE="CF_SQL_VARCHAR">
      <CFPROCPARAM VALUE="#arguments.sortOrder#" CFSQLTYPE="CF_SQL_VARCHAR">
      <CFPROCPARAM VALUE="#ReplaceNoCase(arguments.searchText,"'","''",'ALL')#" CFSQLTYPE="CF_SQL_VARCHAR">
      <CFPROCPARAM VALUE="#local.searchPickUpState#" CFSQLTYPE="CF_SQL_VARCHAR">
      <CFPROCPARAM VALUE="#local.searchEquipmentID#" CFSQLTYPE="CF_SQL_VARCHAR">
      <CFPROCPARAM VALUE="#arguments.IsCarrier#" CFSQLTYPE="CF_SQL_VARCHAR">
      <CFPROCPARAM VALUE="#arguments.Pending#" CFSQLTYPE="CF_SQL_VARCHAR">
      <CFPROCRESULT NAME="QreturnSearch">
    </CFSTOREDPROC>
    <cfreturn QreturnSearch>
</cffunction>


<!--- Filter carriers starts here --->
<cffunction name="getFilteredCarrier" access="public" output="false" returntype="query">


    <cfargument name="pageNo" required="yes" type="any">
    <cfargument name="sortorder" required="no" type="any">
    <cfargument name="sortby" required="no" type="any">
    <cfargument name="insexp" required="yes" type="any">
    <cfargument name="shippercity" required="yes" type="any">
    <cfargument name="shipperstate" required="yes" type="any">
    <cfargument name="shipperZipcode" required="yes" type="any">
    <cfargument name="consigneecity" required="yes" type="any">
    <cfargument name="consigneestate" required="yes" type="any">
    <cfargument name="consigneeZipcode" required="yes" type="any">

	<cfif not isdefined('arguments.pageNo')>
		<cfset arguments.pageNo = 1>
	</cfif>

    <cfif not isdefined('arguments.sortorder')>
		<cfset arguments.sortorder = "ASC">
	</cfif>

    <cfif not isdefined('arguments.sortby')>
		<cfset arguments.sortby = "CarrierName">
	</cfif>

		<cfquery name="QreturnSearch" datasource="#variables.dsn#">
			WITH page AS (
				select carriers.*, ROW_NUMBER() OVER (ORDER BY
					UPPER(#arguments.sortby#) #arguments.sortorder#
				) AS Row
			from carriers
			where CompanyID =  <cfqueryparam value="#session.companyid#" cfsqltype="cf_sql_varchar"> AND AND
            		(
                    <cfif isdefined('arguments.insexp') and #arguments.insexp# eq 1 >
						INSEXPDATE <= getdate()
                        AND
					</cfif>
                        ( 1=1
                         <cfif isdefined('arguments.consigneecity') and trim(Len(#arguments.consigneecity#)) gt 1 >
                            AND City = <cfqueryparam value='#arguments.consigneecity#' cfsqltype="cf_sql_varchar">
                         </cfif>
                         <cfif isdefined('arguments.consigneestate') and trim(Len(#arguments.consigneestate#)) gt 1 >
                            AND STATECODE = <cfqueryparam value='#arguments.consigneestate#' cfsqltype="cf_sql_varchar">
                         </cfif>
                         <cfif isdefined('arguments.consigneeZipcode') and trim(Len(#arguments.consigneeZipcode#)) gt 1 >
                            AND Zipcode = <cfqueryparam value='#arguments.consigneeZipcode#' cfsqltype="cf_sql_varchar">
                         </cfif>
                         <cfif (isdefined('arguments.shippercity') and trim(Len(#arguments.shippercity#)) gt 1) OR (isdefined('arguments.shipperstate') and trim(Len(#arguments.shipperstate#)) gt 1) OR (isdefined('arguments.shipperZipcode') and trim(Len(#arguments.shipperZipcode#)) gt 1 ) >
                            OR 1=1
                         </cfif>
                         <cfif isdefined('arguments.shippercity') and trim(Len(#arguments.shippercity#)) gt 1 >
                            AND City = <cfqueryparam value='#arguments.shippercity#' cfsqltype="cf_sql_varchar">
                         </cfif>
                         <cfif isdefined('arguments.shipperstate') and trim(Len(#arguments.shipperstate#)) gt 1 >
                            AND STATECODE = <cfqueryparam value='#arguments.shipperstate#' cfsqltype="cf_sql_varchar">
                         </cfif>
                         <cfif isdefined('arguments.shipperZipcode') and trim(Len(#arguments.shipperZipcode#)) gt 1 >
                            AND Zipcode = <cfqueryparam value='#arguments.shipperZipcode#' cfsqltype="cf_sql_varchar">
                         </cfif>
                        )
                    )
                )
			 SELECT * FROM page WHERE Row between (<cfqueryparam value="#pageNo#" cfsqltype="cf_sql_varchar"> - 1) * 30 + 1 and <cfqueryparam value="#pageNo#" cfsqltype="cf_sql_varchar">*30

		</cfquery>

    <cfreturn QreturnSearch>

</cffunction>

<!--- Filter carriers ends here --->



<!--- Add LI Web Site Data--->
<cffunction name="AddLIWebsiteData" access="public" output="false" returntype="any">
	<cfargument name="formStruct" required="yes" type="struct">
  <cfargument name="carrierid" required="yes" type="string">
		<cfif isDefined("session.AuthType_Common_status")>
		   <cfquery name="AddLIData" datasource="#variables.dsn#">
			insert into carriersLNI (CarrierID,DOTCommonAuthorityStatus,DOTContractAuthorityStatus,DOTBrokerAuthorityStatus
			,DOTCommonAppPending,DOTContractAppPending,DOTBrokerAppPending,InsLiabilities,InsOnFileLiabilities,InsCargo,InsOnFileCargo,CargoAuthHouseHold
			,ChangedDate,RefreshedDate)
			values(<cfqueryparam value="#arguments.carrierid#" cfsqltype="cf_sql_varchar">,
        <cfqueryparam value='#session.AuthType_Common_status#' cfsqltype="cf_sql_varchar">,
        <cfqueryparam value='#session.AuthType_Contract_status#' cfsqltype="cf_sql_varchar">,
        <cfqueryparam value='#session.AuthType_Broker_status#'cfsqltype="cf_sql_varchar">,
				<cfqueryparam value='#session.AuthType_Common_appPending#'cfsqltype="cf_sql_varchar">,
        <cfqueryparam value='#session.AuthType_Contract_appPending#'cfsqltype="cf_sql_varchar">,
        <cfqueryparam value='#session.AuthType_Broker_appPending#'cfsqltype="cf_sql_varchar">,
				<cfqueryparam value='#session.bipd_Insurance_required#'cfsqltype="cf_sql_varchar">,
        <cfqueryparam value='#session.bipd_Insurance_on_file#'cfsqltype="cf_sql_varchar">,
        <cfqueryparam value='#session.cargo_Insurance_required#'cfsqltype="cf_sql_varchar">,
				<cfqueryparam value='#session.cargo_Insurance_on_file#'cfsqltype="cf_sql_varchar">,
        <cfqueryparam value='#session.household_goods#'cfsqltype="cf_sql_varchar">,
        getdate(),
        getdate())
		   </cfquery>
	   </cfif>

</cffunction>

<!--- Add LI Web Site Data--->
<cffunction name="EditLIWebsiteData" access="public" output="false" returntype="any">
	<cfargument name="CarrierID" required="yes" type="any">
	   <cfquery name="AddLIData" datasource="#variables.dsn#">
	    update carriersLNI set
	    DOTCommonAuthorityStatus = <cfqueryparam value='#session.AuthType_Common_status#' cfsqltype="cf_sql_varchar">
	    ,DOTContractAuthorityStatus = <cfqueryparam value='#session.AuthType_Contract_status#' cfsqltype="cf_sql_varchar">
	    ,DOTBrokerAuthorityStatus = <cfqueryparam value='#session.AuthType_Broker_status#'cfsqltype="cf_sql_varchar">
	    ,DOTCommonAppPending = <cfqueryparam value='#session.AuthType_Common_appPending#'cfsqltype="cf_sql_varchar">
	    ,DOTContractAppPending = <cfqueryparam value='#session.AuthType_Contract_appPending#'cfsqltype="cf_sql_varchar">
	    ,DOTBrokerAppPending = <cfqueryparam value='#session.AuthType_Broker_appPending#'cfsqltype="cf_sql_varchar">
	    ,InsLiabilities = <cfqueryparam value='#session.bipd_Insurance_required#'cfsqltype="cf_sql_varchar">
	    ,InsOnFileLiabilities = <cfqueryparam value='#session.bipd_Insurance_on_file#'cfsqltype="cf_sql_varchar">
	    ,InsCargo = <cfqueryparam value='#session.cargo_Insurance_required#'cfsqltype="cf_sql_varchar">
	    ,InsOnFileCargo =<cfqueryparam value='#session.cargo_Insurance_on_file#'cfsqltype="cf_sql_varchar">
	    ,CargoAuthHouseHold = <cfqueryparam value='#session.household_goods#'cfsqltype="cf_sql_varchar">
	    ,RefreshedDate = getdate()
		    where carrierID = <cfqueryparam value='#arguments.CarrierID#'cfsqltype="cf_sql_varchar">
	   </cfquery>
	<cfreturn 'LI Web site data has been updated successfully.'>
</cffunction>

<!--- Get LI Web Site Data--->
<cffunction name="getLIWebsiteData" access="public" output="false" returntype="query">
	<cfargument name="CarrierID" required="yes" type="any">
	   <cfquery name="getLIData" datasource="#variables.dsn#">
		 select * from CarriersLNI where carrierId = <cfqueryparam value='#arguments.CarrierID#'cfsqltype="cf_sql_varchar">
	   </cfquery>
    <cfreturn getLIData>
</cffunction>


<!--- get commodity by carrier id --->
<cffunction name="getCommodityById" access="public" output="false" returntype="query">
	<cfargument name="carrierID" required="yes" type="string">
	<cfquery name="qGetCommodityById" datasource="#variables.dsn#">
		select CARRIERID,carrrate,COMMODITYID,CarrRateOfCustTotal,ID
		from carrier_commodity
		where CARRIERID = <cfqueryparam value='#arguments.CarrierID#'cfsqltype="cf_sql_varchar">
	</cfquery>
	<cfreturn qGetCommodityById >
</cffunction>
<!---update lifmca details--->
<cffunction name="UpdatelifmcaDetails" access="public" output="false" returntype="query">
    <cfargument name="formStruct" type="struct"  required="yes">
      <cfquery name="qryUpdateLifmcaDetails" datasource="#variables.dsn#">
           update lipublicfmcsa
			set
			InsuranceCompanyAddress= <cfqueryparam cfsqltype="cf_sql_varchar" value="#argument.formStruct.InsuranceCompanyAddress#">,
			ExpirationDate=<cfqueryparam cfsqltype="cf_sql_timestamp" value="#argument.formStruct.ExpirationDate#" null="#yesNoFormat(NOT len(arguments.formStruct.ExpirationDate))#">,
			DateModified=<cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">,
			commonStatus=<cfqueryparam cfsqltype="cf_sql_bit" value="#arguments.formStruct.commonStatus#">,
			contractStatus = <cfqueryparam cfsqltype="cf_sql_bit" value="#arguments.formStruct.contractStatus#">,
			BrokerStatus= <cfqueryparam cfsqltype="cf_sql_bit" value="#arguments.formStruct.BrokerStatus#">,
			commonAppPending= <cfqueryparam cfsqltype="cf_sql_bit" value="#arguments.formStruct.commonAppPending#">,
			contractAppPending=  <cfqueryparam cfsqltype="cf_sql_bit" value="#arguments.formStruct.contractAppPending#">,
			BrokerAppPending=  <cfqueryparam cfsqltype="cf_sql_bit" value="#arguments.formStruct.BrokerAppPending#">,
			BIPDInsRequired= <cfqueryparam cfsqltype="cf_sql_bit" value="#arguments.formStruct.BIPDInsRequired#">,
			cargoInsRequired= <cfqueryparam cfsqltype="cf_sql_bit" value="#session.adminUserName#">,
			BIPDInsonFile=<cfqueryparam cfsqltype="cf_sql_bit" value="#Now()#">,
			cargoInsonFile= <cfqueryparam cfsqltype="cf_sql_bit" value="#arguments.formStruct.City#">,
			householdGoods= <cfqueryparam cfsqltype="cf_sql_bit" value="#arguments.formStruct.Country#">
		where
			carrierId=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.carrierId#">
      </cfquery>
	  <cfreturn 'LI Web site data has been updated successfully.'>
</cffunction>
<!---get lifmcaDetails--->
<cffunction name="getlifmcaDetails" access="public" output="false" returntype="query">
    <cfargument name="carrierid" type="string"  required="yes">
      <cfquery name="qrygetlifmcaDetails" datasource="#variables.dsn#">
           select * from lipublicfmcsa
			where carrierId=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.carrierId#">
      </cfquery>
	  <cfreturn qrygetlifmcaDetails>
</cffunction>

<!--- add watch --->
	<cffunction name="AddWatch" access="public"  returntype="any">
		<cfargument name="DOTNumber" type="string"  default="0">
		<cfargument name="MCNumber" type="string"  default="0">
		<cfif arguments.DOTNumber GT 0 >
			<cfset variables.number = arguments.DOTNumber >
		<cfelseif arguments.MCNumber GT 0 >
			<cfset variables.number = arguments.MCNumber >
		<cfelse>
			<cfset variables.number = 0>
		</cfif>
		<cfquery name="qSystemSetupOptions" datasource="#variables.dsn#">
	    	SELECT SaferWatch,SaferWatchWebKey,SaferWatchCustomerKey
			FROM SystemConfig WHERE CompanyID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#session.CompanyID#">
	    </cfquery>
		<cfhttp url="http://www.saferwatch.com/webservices/CarrierService32.php?Action=AddWatch&ServiceKey=#qSystemSetupOptions.SaferWatchWebKey#&CustomerKey=#qSystemSetupOptions.SaferWatchCustomerKey#&number=#variables.number#" method="get" >
		</cfhttp>
		<cfif cfhttp.Statuscode EQ '200 OK'>
			<cfset variables.resStruct = ConvertXmlToStruct(cfhttp.Filecontent, StructNew())>
			<cfreturn variables.resStruct.ResponseDO.displayMsg>
		<cfelse>
			<cfreturn "Not added to watch.">
		</cfif>
	</cffunction>

	<cffunction name="getCarrier" access="public"  returntype="any">
		<cfargument name="carrierid" type="string"  default="0">
		<cfquery name="qgetCarrier" datasource="#variables.dsn#">
	    	 SELECT DOTNumber,MCNumber FROM carriers WHERE  CarrierID = <cfqueryparam value='#arguments.CarrierID#'cfsqltype="cf_sql_varchar">
	    </cfquery>
		<cfreturn qgetCarrier>
	</cffunction>
<!--- Remove  watch --->
	<cffunction name="RemoveWatch" access="public"  returntype="any">
		<cfargument name="DOTNumber" type="string"  default="0">
		<cfargument name="MCNumber" type="string"  default="0">
		<cfif arguments.DOTNumber GT 0 >
			<cfset variables.number = arguments.DOTNumber >
		<cfelseif arguments.MCNumber GT 0 >
			<cfset variables.number = arguments.MCNumber >
		<cfelse>
			<cfset variables.number = 0>
		</cfif>
		<cfquery name="qSystemSetupOptions" datasource="#variables.dsn#">
	    	SELECT SaferWatch,SaferWatchWebKey,SaferWatchCustomerKey
			FROM SystemConfig WHERE CompanyID =<cfqueryparam cfsqltype="cf_sql_varchar" value="#session.companyid#">
	    </cfquery>
		<cfhttp url="http://www.saferwatch.com/webservices/CarrierService32.php?Action=RemoveWatch&ServiceKey=#qSystemSetupOptions.SaferWatchWebKey#&CustomerKey=#qSystemSetupOptions.SaferWatchCustomerKey#&number=#variables.number#" method="get" >
		</cfhttp>
		<cfif cfhttp.Statuscode EQ '200 OK'>
			<cfset variables.resStruct = ConvertXmlToStruct(cfhttp.Filecontent, StructNew())>
			<cfreturn variables.resStruct.ResponseDO.displayMsg>
		<cfelse>
			<cfreturn "Unable to remove watch.">
		</cfif>
	</cffunction>

	<!--- Carrier Lookup--->
	<cffunction name="CarrierRiskAssessment" access="public"  returntype="any">
		<cfargument name="DOTNumber" type="string"  default="0">
		<cfargument name="MCNumber" type="string"  default="0">
		<cfset risk_assessment = "" >
		<cfif arguments.DOTNumber GT 0 >
			<cfset variables.number = arguments.DOTNumber >
		<cfelseif arguments.MCNumber GT 0 >
			<cfset variables.number = arguments.MCNumber >
		<cfelse>
			<cfset variables.number = 0>
		</cfif>
		<cfquery name="qSystemSetupOptions" datasource="#variables.dsn#">
	    	SELECT SaferWatch,SaferWatchWebKey,SaferWatchCustomerKey
			FROM SystemConfig WHERE CompanyID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#session.CompanyID#">
	    </cfquery>
		<cfhttp url="http://www.saferwatch.com/webservices/CarrierService32.php?Action=CarrierLookup&ServiceKey=#qSystemSetupOptions.SaferWatchWebKey#&CustomerKey=#qSystemSetupOptions.SaferWatchCustomerKey#&number=#variables.number#" method="get" >
		</cfhttp>
		<cfif cfhttp.Statuscode EQ '200 OK'>
			<cfset variables.resStruct = ConvertXmlToStruct(cfhttp.Filecontent, StructNew())>
			<cfif structKeyExists(variables.resStruct ,"CarrierDetails") AND variables.resStruct.CarrierDetails.dotNumber EQ  arguments.DOTNumber AND variables.resStruct.CarrierDetails.docketNumber EQ arguments.MCNumber AND structKeyExists(variables.resStruct .CarrierDetails,"RiskAssessment") AND structKeyExists(variables.resStruct .CarrierDetails.RiskAssessment,"Overall")  >
				<cfset risk_assessment = variables.resStruct .CarrierDetails.RiskAssessment.Overall>
			</cfif>
		<cfelse>
			<cfreturn "">
		</cfif>
		<cfreturn risk_assessment>
	</cffunction>

	<!--- Carrier Lookup--->
	<cffunction name="CarrierLookup" access="public"  returntype="any">
		<cfargument name="DOTNumber" type="string"  default="0">
		<cfargument name="MCNumber" type="string"  default="0">
		<cfset risk_assessment = "" >
		<cfif arguments.DOTNumber GT 0 >
			<cfset variables.number = arguments.DOTNumber >
		<cfelseif arguments.MCNumber GT 0 >
			<cfset variables.number = arguments.MCNumber >
		<cfelse>
			<cfset variables.number = 0>
		</cfif>
		<cfquery name="qSystemSetupOptions" datasource="#variables.dsn#">
	    	SELECT SaferWatch,SaferWatchWebKey,SaferWatchCustomerKey
			FROM SystemConfig WHERE CompanyID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#session.CompanyID#">
	    </cfquery>
		<cfhttp url="http://www.saferwatch.com/webservices/CarrierService32.php?Action=CarrierLookup&ServiceKey=#qSystemSetupOptions.SaferWatchWebKey#&CustomerKey=#qSystemSetupOptions.SaferWatchCustomerKey#&number=#variables.number#" method="get" >
		</cfhttp>
		<cfif cfhttp.Statuscode EQ '200 OK'>
			<cfset variables.resStruct = ConvertXmlToStruct(cfhttp.Filecontent, StructNew())>
			<cfif structKeyExists(variables.resStruct ,"CarrierDetails") AND structKeyExists(variables.resStruct .CarrierDetails,"RiskAssessment") AND structKeyExists(variables.resStruct .CarrierDetails.RiskAssessment,"Overall")  >
				<cfset risk_assessment = variables.resStruct >
			</cfif>
		<cfelse>
			<cfreturn "">
		</cfif>
		<cfreturn risk_assessment>
	</cffunction>

	<cffunction name="UpdateWatchList" access="public"  returntype="any">
		<cfargument name="DOTNumber" type="string"  default="0">
		<cfargument name="MCNumber" type="string"  default="0">
		<cfargument name="SaferWatch" type="string"  default="0">
		<cfargument name="bit_addWatch" type="string"  default="0">
		<cfargument name="editid" type="string"  default="0">
		<cfquery name="qCarrier" datasource="#variables.dsn#">
	    	SELECT SaferWatch
			FROM Carriers
			WHERE CarrierID = <cfqueryparam value='#arguments.editid#'cfsqltype="cf_sql_varchar">
	    </cfquery>
		 <cfif StructKeyExists(arguments,"SaferWatch") AND  arguments.SaferWatch EQ 1 >
			<cfif StructKeyExists(arguments,"bit_addWatch") AND arguments.bit_addWatch EQ 1 AND qCarrier.SaferWatch EQ 0 >
				<cfinvoke component="#variables.objCarrierGateway#" method="AddWatch" returnvariable="message">
					<cfinvokeargument name="DOTNumber" value="#arguments.DOTNumber#">
					<cfinvokeargument name="MCNumber" value="MC#arguments.MCNumber#">
				</cfinvoke>
			<cfelseif  qCarrier.SaferWatch EQ 1 AND  NOT StructKeyExists(arguments,"bit_addWatch")>
				<cfinvoke component="#variables.objCarrierGateway#" method="RemoveWatch" returnvariable="message">
					<cfinvokeargument name="DOTNumber" value="#arguments.DOTNumber#">
					<cfinvokeargument name="MCNumber" value="MC#arguments.MCNumber#">
				</cfinvoke>
			</cfif>
		 </cfif>
	</cffunction>

	<cffunction name="ConvertXmlToStruct" access="public" returntype="struct" output="true"  hint="Parse raw XML response body into ColdFusion structs and arrays and return it.">
		<cfargument name="xmlNode" type="string" required="true" />
		<cfargument name="str" type="struct" required="true" />
		<cfset var i 							= 0 />
		<cfset var axml						= arguments.xmlNode />
		<cfset var astr						= arguments.str />
		<cfset var n 							= "" />
		<cfset var tmpContainer 	= "" />

		<cfset axml = XmlSearch(XmlParse(arguments.xmlNode),"/node()")>
		<cfset axml = axml[1] />

		<cfloop from="1" to="#arrayLen(axml.XmlChildren)#" index="i">
			<cfset n = replace(axml.XmlChildren[i].XmlName, axml.XmlChildren[i].XmlNsPrefix&":", "") />
			<cfif structKeyExists(astr, n)>
				<cfif not isArray(astr[n])>
					<cfset tmpContainer = astr[n] />
					<cfset astr[n] = arrayNew(1) />
					<cfset astr[n][1] = tmpContainer />
				<cfelse>
				</cfif>

				<cfif arrayLen(axml.XmlChildren[i].XmlChildren) gt 0>
						<cfset astr[n][arrayLen(astr[n])+1] = ConvertXmlToStruct(axml.XmlChildren[i], structNew()) />
				<cfelse>
						<cfset astr[n][arrayLen(astr[n])+1] = axml.XmlChildren[i].XmlText />
				</cfif>
			<cfelse>
				<cfif arrayLen(axml.XmlChildren[i].XmlChildren) gt 0>
					<cfset astr[n] = ConvertXmlToStruct(axml.XmlChildren[i], structNew()) />
				<cfelse>
					<cfif IsStruct(aXml.XmlAttributes) AND StructCount(aXml.XmlAttributes)>
						<cfset at_list = StructKeyList(aXml.XmlAttributes)>
						<cfloop from="1" to="#listLen(at_list)#" index="atr">
							 <cfif ListgetAt(at_list,atr) CONTAINS "xmlns:">
								<cfset Structdelete(axml.XmlAttributes, listgetAt(at_list,atr))>
							 </cfif>
						 </cfloop>
						 <cfif StructCount(axml.XmlAttributes) GT 0>
							 <cfset astr['_attributes'] = axml.XmlAttributes />
						</cfif>
					</cfif>
					<cfif IsStruct(aXml.XmlChildren[i].XmlAttributes) AND StructCount(aXml.XmlChildren[i].XmlAttributes) GT 0>
						<cfset astr[n] = axml.XmlChildren[i].XmlText />
						 <cfset attrib_list = StructKeylist(axml.XmlChildren[i].XmlAttributes) />
						 <cfloop from="1" to="#listLen(attrib_list)#" index="attrib">
							 <cfif ListgetAt(attrib_list,attrib) CONTAINS "xmlns:">
								<cfset Structdelete(axml.XmlChildren[i].XmlAttributes, listgetAt(attrib_list,attrib))>
							 </cfif>
						 </cfloop>
						 <cfif StructCount(axml.XmlChildren[i].XmlAttributes) GT 0>
							 <cfset astr[n&'_attributes'] = axml.XmlChildren[i].XmlAttributes />
						</cfif>
					<cfelse>
						 <cfset astr[n] = axml.XmlChildren[i].XmlText />
					</cfif>
				</cfif>
			</cfif>
		</cfloop>
		<cfreturn astr />
	</cffunction>

  <!---function to get the user editing details for corresponding carrier --->
  <cffunction name="getUserEditingDetails" access="public" returntype="query">
    <cfargument name="carrierid" type="string" required="yes"/>
    <!---Query to get the user editing details for corresponding carrier--->
    
    <cfquery name="qryUpdateEditingUserId" datasource="#Application.dsn#">
      select  InUseBy,InUseOn from Carriers
      where CarrierID=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.carrierid#">
    </cfquery>

    <cfreturn qryUpdateEditingUserId>
  </cffunction>

  <!---function to update the userid for corresponding carrier--->
  <cffunction name="removeUserAccessOnCarrier" access="remote" returntype="struct" returnformat="json">
    <cfargument name="dsn" type="string" required="yes"/>
    <cfargument name="carrierid" type="string" required="yes"/>
      <cfset var carriers=StructNew()>
      <!---Query to get the userid--->
      <cfquery name="qryGetUserId" datasource="#arguments.dsn#" result="result">
        select InUseBy,InUseOn,CarrierName from Carriers where CarrierId=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.carrierid#">
      </cfquery>

      <!-- Return if lock already removed-->
      <cfif len(trim(qryGetUserId.InUseBy)) eq 0>
        <cfset carriers.msg = "No Lock Exist!" />
        <cfreturn carriers>
      </cfif> 

      <!---Query to get editing User Name--->
      <cfquery name="qryGetUserName" datasource="#arguments.dsn#" result="result">
        SELECT NAME
        FROM employees
        WHERE employeeID = <cfqueryparam value="#qryGetUserId.inuseby#" cfsqltype="cf_sql_varchar">
      </cfquery>
      <cfset carrier.userName=qryGetUserName.NAME>
     
      <cfset carrier.onDateTime=dateformat(qryGetUserId.InUseOn,"mm/dd/yy hh:mm:ss")>
      <cfset carrier.dsn=arguments.dsn>
      <!---Query to update the userid for corresponding carrier to null--->
      <cfquery name="qryUpdateEditingUserId" datasource="#arguments.dsn#" result="result">
        UPDATE Carriers
        SET
        InUseBy=null,
        InUseOn=null
        where CarrierId=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.carrierid#">
      </cfquery>
      <cfreturn carriers>
  </cffunction>
  <!---function to update the userid for corresponding carrier--->
  <cffunction name="updateEditingUserId" access="public" returntype="void">
    <cfargument name="userid" type="string" required="yes"/>
    <cfargument name="carrierid" type="string" required="yes"/>
    <cfargument name="status" type="boolean" required="yes"/>
    <cfif  arguments.status>
      <!---Query to update the userid for corresponding carrier to null--->
      <cflock timeout="600" scope="request" type="exclusive">
        <cfquery name="qryUpdateEditingUserId" datasource="#Application.dsn#" result="result">
          UPDATE Carriers
          SET
          InUseBy=null,
          InUseOn=null,
          sessionid=null
          where InUseBy=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.userid#">
        </cfquery>
      </cflock>
      <!---cfdump var="#result#"--->
    <cfelse>
      <!---Query to update the userid for corresponding carrier--->
      <cflock timeout="600" scope="request" type="exclusive">
        <cfquery name="qryUpdateEditingUserId" datasource="#Application.dsn#" result="result">
          UPDATE Carriers
          SET
          InUseBy=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.userid#">,
          InUseOn=<cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">,
          sessionid=<cfqueryparam cfsqltype="cf_sql_varchar" value="#session.sessionid#">
          where carrierid=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.carrierid#">
        </cfquery>
      </cflock>
      <!---cfdump var="#result#"--->
    </cfif>
  </cffunction>

  <!---function to insert UserBrowserTabDetails--->
  <cffunction name="insertTabDetails" access="remote" output="yes" returnformat="json">
    <cfargument name="tabID" type="any" required="yes">
    <cfargument name="carrierid" type="any" required="yes">
    <cfargument name="sessionid" type="any" required="yes">
    <cfargument name="userid" type="any" required="yes">
    <cfargument name="dsn" type="any" required="yes">
    <!---query to select UserBrowserTabDetails--->
    <cfquery name="qryGetBrowserTabDetails" datasource="#arguments.dsn#">
      select * from  UserBrowserTabDetails
      where 1=1
      and carrierid=<cfqueryparam value="#arguments.carrierid#" cfsqltype="cf_sql_varchar">
      and sessionid=<cfqueryparam value="#arguments.sessionid#" cfsqltype="cf_sql_varchar">
      and userid=<cfqueryparam value="#arguments.userid#" cfsqltype="cf_sql_varchar">
      and tabID=<cfqueryparam value="#arguments.tabID#" cfsqltype="cf_sql_varchar">
    </cfquery>
    <cfif not qryGetBrowserTabDetails .recordcount>
      <!---Query to insert UserBrowserTabDetails--->
      <cfquery name="qryInsertGetBrowserTabDetails" datasource="#arguments.dsn#">
        INSERT INTO UserBrowserTabDetails (userid, carrierid, tabid, sessionid, createddate)
              VALUES (<cfqueryparam value="#arguments.userid#" cfsqltype="cf_sql_varchar">,
            <cfqueryparam value="#arguments.carrierid#" cfsqltype="cf_sql_varchar">,
            <cfqueryparam value="#arguments.tabID#" cfsqltype="cf_sql_varchar"> ,
            <cfqueryparam value="#arguments.sessionid#" cfsqltype="cf_sql_varchar">,
            <cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">)
      </cfquery>
    </cfif>
  </cffunction>

  <!---function to delete BrowserTabDetails--->
  <cffunction name="deleteTabDetails" access="remote" output="yes" returnformat="json">
    <cfargument name="tabID" type="any" required="yes">
    <cfargument name="sessionid" type="any" required="yes">
    <cfargument name="userid" type="any" required="yes">
    <cfargument name="dsn" type="any" required="yes">
    <cfargument name="carrierid" type="any" required="yes">
    <!---query to delete UserBrowserTabDetails--->
    <cfquery name="qryGetBrowserTabDetails" datasource="#arguments.dsn#">
      delete from  UserBrowserTabDetails
      where
          sessionid=<cfqueryparam value="#arguments.sessionid#" cfsqltype="cf_sql_varchar">
      and userid=<cfqueryparam value="#arguments.userid#" cfsqltype="cf_sql_varchar">
      and tabID=<cfqueryparam value="#arguments.tabID#" cfsqltype="cf_sql_varchar">
      and CarrierID=<cfqueryparam value="#arguments.carrierid#" cfsqltype="cf_sql_varchar">
    </cfquery>
  </cffunction>


  <!--- Get Session Ajax version--->
  <cffunction name="getAjaxSession" access="remote" output="yes" returnformat="json">
    <cfargument name="UnlockStatus" type="any" required="no">
    <cfargument name="carrierid" type="any" required="no">
    <cfargument name="dsn" type="any" required="no">
    <cfargument name="sessionid" type="any" required="no">
    <cfargument name="userid" type="any" required="no">
    <cfargument name="tabid" type="any" required="no">
    <cfargument name="saveEvent" type="any" required="no" default="false">


    <cfif structkeyexists(arguments,"tabid")>
      <!----query to delete -corresponding rows of tabid--->
      <cfquery name="qryGetBrowserTabDetails" datasource="#arguments.dsn#">
        delete from  UserBrowserTabDetails
        where tabID=<cfqueryparam value="#arguments.tabid#" cfsqltype="cf_sql_varchar">
      </cfquery>
    </cfif>
    <cfif structkeyexists(arguments,"UnlockStatus") and structkeyexists(arguments,"carrierid") and arguments.UnlockStatus eq false and len(trim(arguments.carrierid)) gt 1 and structkeyexists(arguments,"dsn") and structkeyexists(arguments,"sessionid") and structkeyexists(arguments,"userid") and arguments.saveevent neq "true">
      <!---Query to select browser tab details--->
      <cfquery name="qryGetBrowsertabDetails" datasource="#arguments.dsn#">
        select id from UserBrowserTabDetails
        where
          carrierid=<cfqueryparam value="#arguments.carrierid#" cfsqltype="cf_sql_varchar">
        and sessionid=<cfqueryparam value="#arguments.sessionid#" cfsqltype="cf_sql_varchar">
        and userid=<cfqueryparam value="#arguments.userid#" cfsqltype="cf_sql_varchar">
      </cfquery>
    
      <cfif not qryGetBrowsertabDetails.recordcount>

        <!---Query to remove lock --->
        <cfquery name="qryGetInuseBy" datasource="#arguments.dsn#">
          update Carriers
          set
            InUseBy=null,
            InUseOn=null,
            sessionId=null
          where CarrierID=<cfqueryparam value="#arguments.carrierid#" cfsqltype="cf_sql_varchar">
          and InUseBy = <cfqueryparam value="#arguments.userid#" cfsqltype="cf_sql_varchar">
        </cfquery>
      <cfelse>
        <cfabort/>
      </cfif>
    </cfif>
 </cffunction>
 
<cffunction name="getCarrierFromFmcsaDB">
    <cfargument name="Number" type="any" required="yes">
	<cfargument name="IsDot" type="any" required="yes">
	 <cfargument name="dsn" type="any" required="yes">
	 
	<cfquery name="qryGetCarrierFromFmcsaDB" datasource="#arguments.dsn#">
	  select DOT_NUMBER,LEGAL_NAME,PHY_STREET,PHY_CITY,PHY_STATE,PHY_ZIP,PHY_COUNTRY,TELEPHONE,FAX,EMAIL_ADDRESS from FMCSA where 
		<cfif IsDot>
			DOT_NUMBER = <cfqueryparam value="#arguments.Number#" cfsqltype="cf_sql_numeric">
		<cfelse>
			MC_NUMBER = <cfqueryparam value="#arguments.Number#" cfsqltype="cf_sql_numeric">
		</cfif>
	  
	</cfquery>
	
	<cfreturn qryGetCarrierFromFmcsaDB>
</cffunction>

<cffunction name="updateCarrierSaferWatch" access="remote" returntype="string" returnformat="json">
    <cfargument name="dsn" type="string" required="yes"/>
    <cfargument name="carrierid" type="string" required="yes"/>
    <cfargument name="CompanyID" type="string" required="yes"/>

    <cfquery name="qSystemSetupOptions" datasource="#arguments.dsn#">
      SELECT SaferWatchWebKey,SaferWatchCustomerKey
      FROM SystemConfig WHERE CompanyID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.CompanyID#">
    </cfquery>  

    <cfset SaferWatchTimeout = 10>
    <cfset SaferWatchWebKey         = qSystemSetupOptions.SaferWatchWebKey>
    <cfset SaferWatchCustomerKey  = qSystemSetupOptions.SaferWatchCustomerKey>

    <cfquery name="qryGetAllCarriers" datasource="#arguments.dsn#" result="result">
      select carrierId,mcnumber,dotnumber from carriers WHERE carrierid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.carrierid#">
    </cfquery>

    <cfquery name="qryUpdateCarrierSaferWatch" datasource="#arguments.dsn#" result="result">
      update carriers set SaferWatch = 1 where carrierid=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.carrierid#">
    </cfquery>

    <cfif len(trim(qryGetAllCarriers.mcnumber)) OR len(trim(qryGetAllCarriers.dotnumber))>
      <cfif  len(qryGetAllCarriers.mcnumber) gt 1>
        <cfset DOT_Number ="MC"& trim(qryGetAllCarriers.mcnumber)>      
      <cfelseif  len(qryGetAllCarriers.dotnumber) gt 1>
        <cfset DOT_Number = trim(qryGetAllCarriers.dotnumber)> 
      </cfif>

      <cfhttp url="http://www.saferwatch.com/webservices/CarrierService32.php?Action=AddWatch&ServiceKey=#SaferWatchWebKey#&CustomerKey=#SaferWatchCustomerKey#&number=#trim(DOT_Number)#" method="get" result="objGet">
      </cfhttp>
    </cfif>

    <cfreturn 'success'>
</cffunction>

<cffunction name="updateViaSaferWatch" access="public" output="false" returntype="struct">
  <cftry>
  <cfquery name="qSystemSetupOptions" datasource="#variables.dsn#">
      SELECT SaferWatch,SaferWatchWebKey,SaferWatchCustomerKey,FreightBroker,SaferWatchUpdateCarrierInfo,SaferWatchCertData
      FROM SystemConfig WHERE CompanyID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#session.CompanyID#">
  </cfquery>  

  <cfset SaferWatchTimeout = 10>
  <cfset SaferWatchWebKey         = qSystemSetupOptions.SaferWatchWebKey>
  <cfset SaferWatchCustomerKey  = qSystemSetupOptions.SaferWatchCustomerKey>

  <cfquery name="qryGetAllCarriers" datasource="#variables.dsn#" result="result">
    select carrierId,mcnumber,dotnumber from carriers WHERE CompanyID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#session.CompanyID#">
  </cfquery>

  <cfloop query="qryGetAllCarriers">
    <cfif len(trim(qryGetAllCarriers.mcnumber)) OR len(trim(qryGetAllCarriers.dotnumber))>
      <cfif  len(qryGetAllCarriers.mcnumber) gt 1>
        <cfset DOT_Number ="MC"& trim(qryGetAllCarriers.mcnumber)>      
      <cfelseif  len(qryGetAllCarriers.dotnumber) gt 1>
        <cfset DOT_Number = trim(qryGetAllCarriers.dotnumber)> 
      </cfif>

      <cfhttp url="http://www.saferwatch.com/webservices/CarrierService32.php?Action=AddWatch&ServiceKey=#SaferWatchWebKey#&CustomerKey=#SaferWatchCustomerKey#&number=#trim(DOT_Number)#" method="get" result="objGet">
      </cfhttp>
      
      <cfhttp url="http://www.saferwatch.com/webservices/CarrierService32.php?Action=CarrierLookup&ServiceKey=#SaferWatchWebKey#&CustomerKey=#SaferWatchCustomerKey#&number=#trim(DOT_Number)#" method="get"   TIMEOUT="#SaferWatchTimeout#" throwonerror = Yes>
      </cfhttp>

      <cfif cfhttp.Statuscode EQ '200 OK'>  
        <cfset variables.responsestatus = structNew()>    
        <cfset variables.responsestatus = ConvertXmlToStruct(cfhttp.Filecontent, StructNew()) >
        <cfif  NOT structKeyExists(variables.responsestatus,"CarrierDetails") AND structKeyExists(variables.responsestatus,"ResponseDO")  AND variables.responsestatus.ResponseDO.action EQ "FAILED">
          <cfset respStr = structNew()>
          <cfset respStr.res = "error">
          <cfset respStr.msg = "SaferWatch:#variables.responsestatus.ResponseDO.displayMsg#">
          <cfreturn respStr>
        </cfif>
    
        <cfset risk_assessment = variables.responsestatus.CarrierDetails.RiskAssessment.Overall>
        <cfif IsStruct(variables.responsestatus.CarrierDetails.FMCSAInsurance.PolicyList)>
          <cfif IsArray(variables.responsestatus.CarrierDetails.FMCSAInsurance.PolicyList.PolicyItem)>
            <cfset insCarrier     = left(variables.responsestatus.CarrierDetails.FMCSAInsurance.PolicyList.PolicyItem[1].companyName,100)>
            <cfset InsAgentPhone  = formatPhoneNumber(variables.responsestatus.CarrierDetails.FMCSAInsurance.PolicyList.PolicyItem[1].phone)>
            <cfset insAgentName   = variables.responsestatus.CarrierDetails.FMCSAInsurance.PolicyList.PolicyItem[1].attnToName>
            <cfset formatRequired  = variables.responsestatus.CarrierDetails.FMCSAInsurance.PolicyList.PolicyItem[1].address&","&variables.responsestatus.CarrierDetails.FMCSAInsurance.PolicyList.PolicyItem[1].city&" "&variables.responsestatus.CarrierDetails.FMCSAInsurance.PolicyList.PolicyItem[1].stateCode&","&variables.responsestatus.CarrierDetails.FMCSAInsurance.PolicyList.PolicyItem[1].postalCode&","&variables.responsestatus.CarrierDetails.FMCSAInsurance.PolicyList.PolicyItem[1].countryCode>
              <cfset insPolicy        = left(variables.responsestatus.CarrierDetails.FMCSAInsurance.PolicyList.PolicyItem[1].policyNumber,50)>
          <cfelse>
            <cfset insCarrier = left(variables.responsestatus.CarrierDetails.FMCSAInsurance.PolicyList.PolicyItem.companyName,100)>
            <cfset InsAgentPhone = formatPhoneNumber(variables.responsestatus.CarrierDetails.FMCSAInsurance.PolicyList.PolicyItem.phone)>
            <cfset insAgentName = variables.responsestatus.CarrierDetails.FMCSAInsurance.PolicyList.PolicyItem.attnToName>
            <cfset formatRequired = variables.responsestatus.CarrierDetails.FMCSAInsurance.PolicyList.PolicyItem.address&"&##13;&##10;"&variables.responsestatus.CarrierDetails.FMCSAInsurance.PolicyList.PolicyItem.city&"&nbsp;"&variables.responsestatus.CarrierDetails.FMCSAInsurance.PolicyList.PolicyItem.stateCode&",&nbsp;"&variables.responsestatus.CarrierDetails.FMCSAInsurance.PolicyList.PolicyItem.postalCode&"&##13;&##10;"&variables.responsestatus.CarrierDetails.FMCSAInsurance.PolicyList.PolicyItem.countryCode>
            <cfset insPolicy = left(variables.responsestatus.CarrierDetails.FMCSAInsurance.PolicyList.PolicyItem.policyNumber,50)>
            <cfif qSystemSetupOptions.SaferWatchCertData EQ 1 AND IsDate(variables.responsestatus.CarrierDetails.FMCSAInsurance.PolicyList.PolicyItem.cancelationDate) AND qSystemSetupOptions.SaferWatchUpdateCarrierInfo EQ 1 AND variables.responsestatus.CarrierDetails.FMCSAInsurance.PolicyList.PolicyItem.cancelationDate NEQ "" AND qSystemSetupOptions.SaferWatchCertData EQ 1>
              <cfset InsExpDateLive = variables.responsestatus.CarrierDetails.FMCSAInsurance.PolicyList.PolicyItem.cancelationDate >
            </cfif>
            <cfif qSystemSetupOptions.SaferWatchCertData EQ 1 AND variables.responsestatus.CarrierDetails.FMCSAInsurance.PolicyList.PolicyItem.insuranceType  NEQ "BIPD" AND IsDate(variables.responsestatus.CarrierDetails.FMCSAInsurance.PolicyList.PolicyItem.cancelationDate)  AND  qSystemSetupOptions.SaferWatchUpdateCarrierInfo EQ 1 AND  variables.responsestatus.CarrierDetails.FMCSAInsurance.PolicyList.PolicyItem.cancelationDate NEQ "">
              <cfset CARGOExpirationDate = variables.responsestatus.CarrierDetails.FMCSAInsurance.PolicyList.PolicyItem.cancelationDate >
            <cfelseif qSystemSetupOptions.SaferWatchCertData EQ 1 AND  IsDate(variables.responsestatus.CarrierDetails.FMCSAInsurance.PolicyList.PolicyItem.cancelationDate) AND  qSystemSetupOptions.SaferWatchUpdateCarrierInfo EQ 1 AND variables.responsestatus.CarrierDetails.FMCSAInsurance.PolicyList.PolicyItem.cancelationDate NEQ "">
              <cfset ExpirationDate = variables.responsestatus.CarrierDetails.FMCSAInsurance.PolicyList.PolicyItem.cancelationDate >
            </cfif>

          </cfif>
        </cfif>


        <cfif structKeyExists(variables.responsestatus.CarrierDetails,"CertData") AND isStruct(variables.responsestatus.CarrierDetails.CertData) AND structKeyExists(variables.responsestatus.CarrierDetails.CertData,"Certificate") AND isStruct(variables.responsestatus.CarrierDetails.CertData.Certificate) AND structKeyExists(variables.responsestatus.CarrierDetails.CertData.Certificate,"Coverage") AND qSystemSetupOptions.SaferWatchCertData EQ 1 >  

          <cfif IsArray(variables.responsestatus.CarrierDetails.CertData.Certificate.Coverage)>
            <cfset InsExpDateLive = variables.responsestatus.CarrierDetails.CertData.Certificate.Coverage[1].expirationDate>
            <cfset ExpirationDate = variables.responsestatus.CarrierDetails.CertData.Certificate.Coverage[1].expirationDate>
            <cfset insLimit = variables.responsestatus.CarrierDetails.CertData.Certificate.Coverage[1].coverageLimit>
            <cfloop from="1" to="#arrayLen(variables.responsestatus.CarrierDetails.CertData.Certificate.Coverage)#" index="i">
              <cfif variables.responsestatus.CarrierDetails.CertData.Certificate.Coverage[i].type CONTAINS "Cargo">
                <cfset InsCompanyCargo = variables.responsestatus.CarrierDetails.CertData.Certificate.Coverage[i].insurerName>
                <cfset InsComPhoneCargo = InsAgentPhone>
                <cfif structKeyExists(variables.responsestatus.CarrierDetails.CertData.Certificate,"producerName")>
                  <cfset InsAgentCargo = variables.responsestatus.CarrierDetails.CertData.Certificate.producerName>
                </cfif>
                <cfif structKeyExists(variables.responsestatus.CarrierDetails.CertData.Certificate,"producerPhone")>
                  <cfset InsAgentPhoneCargo = variables.responsestatus.CarrierDetails.CertData.Certificate.producerPhone>
                </cfif>
                <cfif structKeyExists(variables.responsestatus.CarrierDetails.CertData.Certificate,"producerAddress")>
                  <cfset InsuranceCompanyAddressCargo = variables.responsestatus.CarrierDetails.CertData.Certificate.producerAddress>
                </cfif>
                <cfif structKeyExists(variables.responsestatus.CarrierDetails.CertData.Certificate,"producerCity")>
                  <cfset InsuranceCompanyAddressCargo = InsuranceCompanyAddressCargo&','&variables.responsestatus.CarrierDetails.CertData.Certificate.producerCity>
                </cfif>
                <cfif structKeyExists(variables.responsestatus.CarrierDetails.CertData.Certificate,"producerState")>
                  <cfset InsuranceCompanyAddressCargo = InsuranceCompanyAddressCargo&' '&variables.responsestatus.CarrierDetails.CertData.Certificate.producerState>
                </cfif>
                <cfif structKeyExists(variables.responsestatus.CarrierDetails.CertData.Certificate,"producerZip")>
                  <cfset InsuranceCompanyAddressCargo = InsuranceCompanyAddressCargo&','&variables.responsestatus.CarrierDetails.CertData.Certificate.producerZip>
                </cfif>
                <cfset InsPolicyNoCargo = variables.responsestatus.CarrierDetails.CertData.Certificate.Coverage[i].policyNumber>
                <cfset InsExpDateCargo = variables.responsestatus.CarrierDetails.CertData.Certificate.Coverage[i].expirationDate>
                <cfset InsLimitCargo = variables.responsestatus.CarrierDetails.CertData.Certificate.Coverage[i].coverageLimit>
              <cfelseif variables.responsestatus.CarrierDetails.CertData.Certificate.Coverage[i].type CONTAINS "General">
                <cfif structKeyExists(variables.responsestatus.CarrierDetails.CertData.Certificate,"producerName")>
                  <cfset InsAgentGeneral = variables.responsestatus.CarrierDetails.CertData.Certificate.producerName>
                </cfif>
                <cfif structKeyExists(variables.responsestatus.CarrierDetails.CertData.Certificate,"producerPhone")>
                  <cfset InsAgentPhoneGeneral = variables.responsestatus.CarrierDetails.CertData.Certificate.producerPhone>
                </cfif>
                <cfif structKeyExists(variables.responsestatus.CarrierDetails.CertData.Certificate,"producerAddress")>
                  <cfset InsuranceCompanyAddressGeneral = variables.responsestatus.CarrierDetails.CertData.Certificate.producerAddress>
                </cfif>
                <cfif structKeyExists(variables.responsestatus.CarrierDetails.CertData.Certificate,"producerCity")>
                  <cfset InsuranceCompanyAddressGeneral = InsuranceCompanyAddressGeneral&','&variables.responsestatus.CarrierDetails.CertData.Certificate.producerCity>
                </cfif>
                <cfif structKeyExists(variables.responsestatus.CarrierDetails.CertData.Certificate,"producerState")>
                  <cfset InsuranceCompanyAddressGeneral = InsuranceCompanyAddressGeneral&' '&variables.responsestatus.CarrierDetails.CertData.Certificate.producerState>
                </cfif>
                <cfif structKeyExists(variables.responsestatus.CarrierDetails.CertData.Certificate,"producerZip")>
                  <cfset InsuranceCompanyAddressGeneral = InsuranceCompanyAddressGeneral&','&variables.responsestatus.CarrierDetails.CertData.Certificate.producerZip>
                </cfif>
                <cfset InsPolicyNoGeneral = variables.responsestatus.CarrierDetails.CertData.Certificate.Coverage[i].policyNumber>
                <cfset InsExpDateGeneral = variables.responsestatus.CarrierDetails.CertData.Certificate.Coverage[i].expirationDate>
                <cfset InsLimitGeneral = variables.responsestatus.CarrierDetails.CertData.Certificate.Coverage[i].coverageLimit>
                <cfset InsCompanyGeneral = variables.responsestatus.CarrierDetails.CertData.Certificate.Coverage[i].insurerName>
                <cfset InsComPhoneGeneral = InsAgentPhone>
              </cfif>
            </cfloop>
          <cfelse>
            <cfset InsExpDateLive       = variables.responsestatus.CarrierDetails.CertData.Certificate.Coverage.expirationDate>
            <cfset ExpirationDate = "">
            <cfset CARGOExpirationDate =  "">
          </cfif> 
        <cfelseif structKeyExists(variables.responsestatus.CarrierDetails,"CertData") AND isStruct(variables.responsestatus.CarrierDetails.CertData) AND structKeyExists(variables.responsestatus.CarrierDetails.CertData,"Certificate")AND isArray(variables.responsestatus.CarrierDetails.CertData.Certificate) AND isStruct(variables.responsestatus.CarrierDetails.CertData.Certificate[1]) AND structKeyExists(variables.responsestatus.CarrierDetails.CertData.Certificate[1],"Coverage") AND isArray(variables.responsestatus.CarrierDetails.CertData.Certificate[1].Coverage)>
          <cfset InsExpDateLive = variables.responsestatus.CarrierDetails.CertData.Certificate[1].Coverage[1].expirationDate>
          <cfset ExpirationDate = variables.responsestatus.CarrierDetails.CertData.Certificate[1].Coverage[1].expirationDate>
          <cfloop from="1" to="#arrayLen(variables.responsestatus.CarrierDetails.CertData.Certificate[1].Coverage)#" index="i">
            <cfif variables.responsestatus.CarrierDetails.CertData.Certificate[1].Coverage[i].type CONTAINS "Cargo">
               <cfset InsCompanyCargo = variables.responsestatus.CarrierDetails.CertData.Certificate[1].Coverage[i].insurerName>
              <cfset InsComPhoneCargo = InsAgentPhone>

              <cfif structKeyExists(variables.responsestatus.CarrierDetails.CertData.Certificate[1],"producerName")>
                <cfset InsAgentCargo = variables.responsestatus.CarrierDetails.CertData.Certificate[1].producerName>
              </cfif>
              <cfif structKeyExists(variables.responsestatus.CarrierDetails.CertData.Certificate[1],"producerPhone")>
                <cfset InsAgentPhoneCargo = variables.responsestatus.CarrierDetails.CertData.Certificate[1].producerPhone>
              </cfif>
              <cfset InsuranceCompanyAddressCargo= "">
              <cfif structKeyExists(variables.responsestatus.CarrierDetails.CertData.Certificate[1],"producerAddress") AND Len(variables.responsestatus.CarrierDetails.CertData.Certificate[1].producerAddress)>
                <cfset InsuranceCompanyAddressCargo = variables.responsestatus.CarrierDetails.CertData.Certificate[1].producerAddress>
              </cfif>
              <cfif structKeyExists(variables.responsestatus.CarrierDetails.CertData.Certificate[1],"producerCity") AND Len(variables.responsestatus.CarrierDetails.CertData.Certificate[1].producerCity)>
                <cfset InsuranceCompanyAddressCargo = InsuranceCompanyAddressCargo&','&variables.responsestatus.CarrierDetails.CertData.Certificate[1].producerCity>
              </cfif>
              <cfif structKeyExists(variables.responsestatus.CarrierDetails.CertData.Certificate[1],"producerState") AND Len(variables.responsestatus.CarrierDetails.CertData.Certificate[1].producerState)>
                <cfset InsuranceCompanyAddressCargo = InsuranceCompanyAddressCargo&' '&variables.responsestatus.CarrierDetails.CertData.Certificate[1].producerState>
              </cfif>
              <cfif structKeyExists(variables.responsestatus.CarrierDetails.CertData.Certificate[1],"producerZip") AND Len(variables.responsestatus.CarrierDetails.CertData.Certificate[1].producerZip)>
                <cfset InsuranceCompanyAddressCargo = InsuranceCompanyAddressCargo&','&variables.responsestatus.CarrierDetails.CertData.Certificate[1].producerZip>
              </cfif>
              <cfset InsPolicyNoCargo = variables.responsestatus.CarrierDetails.CertData.Certificate[1].Coverage[i].policyNumber>
              <cfset InsExpDateCargo =  variables.responsestatus.CarrierDetails.CertData.Certificate[1].Coverage[i].expirationDate> 
            <cfelseif variables.responsestatus.CarrierDetails.CertData.Certificate[1].Coverage[i].type CONTAINS "General">
              <cfif structKeyExists(variables.responsestatus.CarrierDetails.CertData.Certificate[1],"producerName")>
                <cfset InsAgentGeneral = variables.responsestatus.CarrierDetails.CertData.Certificate[1].producerName>
              </cfif>
              <cfif structKeyExists(variables.responsestatus.CarrierDetails.CertData.Certificate[1],"producerPhone")>
                <cfset InsAgentPhoneGeneral = variables.responsestatus.CarrierDetails.CertData.Certificate[1].producerPhone>
              </cfif>
              <cfset InsuranceCompanyAddressGeneral = "">
              <cfif structKeyExists(variables.responsestatus.CarrierDetails.CertData.Certificate[1],"producerAddress") AND Len(variables.responsestatus.CarrierDetails.CertData.Certificate[1].producerAddress)>
                <cfset InsuranceCompanyAddressGeneral = variables.responsestatus.CarrierDetails.CertData.Certificate[1].producerAddress>
              </cfif>
              <cfif structKeyExists(variables.responsestatus.CarrierDetails.CertData.Certificate[1],"producerCity") AND Len(variables.responsestatus.CarrierDetails.CertData.Certificate[1].producerCity)>
                <cfset InsuranceCompanyAddressGeneral = InsuranceCompanyAddressGeneral&','&variables.responsestatus.CarrierDetails.CertData.Certificate[1].producerCity>
              </cfif>
              <cfif structKeyExists(variables.responsestatus.CarrierDetails.CertData.Certificate[1],"producerState") AND Len(variables.responsestatus.CarrierDetails.CertData.Certificate[1].producerState)>
                <cfset InsuranceCompanyAddressGeneral = InsuranceCompanyAddressGeneral&' '&variables.responsestatus.CarrierDetails.CertData.Certificate[1].producerState>
              </cfif>
              <cfif structKeyExists(variables.responsestatus.CarrierDetails.CertData.Certificate[1],"producerZip")AND Len(variables.responsestatus.CarrierDetails.CertData.Certificate[1].producerZip)>
                <cfset InsuranceCompanyAddressGeneral = InsuranceCompanyAddressGeneral&','&variables.responsestatus.CarrierDetails.CertData.Certificate[1].producerZip>
              </cfif>
              <cfset InsPolicyNoGeneral = variables.responsestatus.CarrierDetails.CertData.Certificate[1].Coverage[i].policyNumber>
              <cfset InsExpDateGeneral = variables.responsestatus.CarrierDetails.CertData.Certificate[1].Coverage[i].expirationDate>
              <cfset InsLimitGeneral = variables.responsestatus.CarrierDetails.CertData.Certificate[1].Coverage[i].coverageLimit>
              <cfset InsCompanyGeneral = variables.responsestatus.CarrierDetails.CertData.Certificate[1].Coverage[i].insurerName>
              <cfset InsComPhoneGeneral = InsAgentPhone>
            </cfif>
          </cfloop>
        </cfif>

        <cfquery name="qUpd" datasource="#variables.dsn#">
          UPDATE Carriers SET 
          SaferWatch = 1,
          RiskAssessment=<cfqueryparam cfsqltype="cf_sql_varchar" value="#risk_assessment#">
          <cfif isDefined("insCarrier")>
            ,InsCompany = <cfqueryparam cfsqltype="cf_sql_varchar" value="#insCarrier#">
          </cfif>
          <cfif isDefined("InsAgentPhone")>
            ,InsCompPhone = <cfqueryparam cfsqltype="cf_sql_varchar" value="#InsAgentPhone#">
          </cfif>
          <cfif isDefined("insAgentName")>
            ,InsAgent = <cfqueryparam cfsqltype="cf_sql_varchar" value="#insAgentName#">
          </cfif>
          <cfif isDefined("InsAgentPhone")>
            ,InsAgentPhone = <cfqueryparam cfsqltype="cf_sql_varchar" value="#InsAgentPhone#">
          </cfif>
          <cfif isDefined("insPolicy")>
            ,InsPolicyNumber = <cfqueryparam cfsqltype="cf_sql_varchar" value="#insPolicy#">
          </cfif>
          <cfif isDefined("ExpirationDate")>
            ,InsExpDate = <cfqueryparam cfsqltype="cf_sql_date" value="#ExpirationDate#">
          </cfif>
          <cfif isDefined("insLimit")>
            ,InsLimit = <cfqueryparam cfsqltype="cf_sql_real" value="#LSParseCurrency(InsLimit)#">
          </cfif>
          <cfif isDefined("InsCompanyCargo")>
            ,InsCompanyCargo = <cfqueryparam cfsqltype="cf_sql_varchar" value="#InsCompanyCargo#">
          </cfif>
          <cfif isDefined("InsComPhoneCargo")>
            ,InsCompPhoneCargo = <cfqueryparam cfsqltype="cf_sql_varchar" value="#InsComPhoneCargo#">
          </cfif>
          <cfif isDefined("InsAgentCargo")>
            ,InsAgentCargo = <cfqueryparam cfsqltype="cf_sql_varchar" value="#InsAgentCargo#">
          </cfif>
          <cfif isDefined("InsAgentPhoneCargo")>
            ,InsAgentPhoneCargo = <cfqueryparam cfsqltype="cf_sql_varchar" value="#InsAgentPhoneCargo#">
          </cfif>
          <cfif isDefined("InsPolicyNoCargo")>
            ,InsPolicyNumberCargo = <cfqueryparam cfsqltype="cf_sql_varchar" value="#InsPolicyNoCargo#">
          </cfif>
          <cfif isDefined("InsExpDateCargo")>
            ,InsExpDateCargo = <cfqueryparam cfsqltype="cf_sql_date" value="#InsExpDateCargo#">
          </cfif>
          <cfif isDefined("InsLimitCargo")>
            ,InsLimitCargo = <cfqueryparam cfsqltype="cf_sql_real" value="#LSParseCurrency(InsLimitCargo)#">
          </cfif>
          <cfif isDefined("InsCompanyGeneral")>
            ,InsCompanyGeneral = <cfqueryparam cfsqltype="cf_sql_varchar" value="#InsCompanyGeneral#">
          </cfif>
          <cfif isDefined("InsComPhoneGeneral")>
            ,InsCompPhoneGeneral = <cfqueryparam cfsqltype="cf_sql_varchar" value="#InsComPhoneGeneral#">
          </cfif>
          <cfif isDefined("InsAgentGeneral")>
            ,InsAgentGeneral = <cfqueryparam cfsqltype="cf_sql_varchar" value="#InsAgentGeneral#">
          </cfif>
          <cfif isDefined("InsAgentPhoneGeneral")>
            ,InsAgentPhoneGeneral = <cfqueryparam cfsqltype="cf_sql_varchar" value="#InsAgentPhoneGeneral#">
          </cfif>
          <cfif isDefined("InsPolicyNoCargo")>
            ,InsPolicyNumberGeneral = <cfqueryparam cfsqltype="cf_sql_varchar" value="#InsPolicyNoCargo#">
          </cfif>
          <cfif isDefined("InsExpDateGeneral")>
            ,InsExpDateGeneral = <cfqueryparam cfsqltype="cf_sql_date" value="#InsExpDateGeneral#">
          </cfif>
          <cfif isDefined("InsLimitGeneral")>
            ,InsLimitGeneral = <cfqueryparam cfsqltype="cf_sql_real" value="#LSParseCurrency(InsLimitGeneral)#">
          </cfif>
          WHERE CarrierID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#qryGetAllCarriers.carrierid#">
        </cfquery>
      </cfif>
    </cfif>
  </cfloop>
  <cfset respStr = structNew()>
  <cfset respStr.res = "success">
  <cfset respStr.msg = "Saferwatch:successfully updated.">
  <cfreturn respStr>
  <cfcatch>
    <cfset respStr = structNew()>
    <cfset respStr.res = "error">
    <cfset respStr.msg = "Saferwatch:Something went wrong. Update failed.">
    <cfreturn respStr>
  </cfcatch>
  </cftry>
</cffunction>

<cffunction name="getAllCarriersForReport" access="public"  returntype="any">
    <cfargument name="IsCarrier" required="no" type="any" default="">
    <cfquery name="qgetCarrier" datasource="#variables.dsn#">
         SELECT carrierID,CarrierName,address,city,stateCode,phone FROM carriers  
         WHERE CompanyID = <cfqueryparam value= "#session.companyid#" cfSqltype="varchar">
         <cfif len(arguments.IsCarrier)>
          AND IsCarrier = <cfqueryparam cfsqltype="cf_sql_bit" value="#arguments.IsCarrier#">
         </cfif>
         ORDER BY CarrierName
      </cfquery>
    <cfreturn qgetCarrier>
  </cffunction>

  <cffunction name="getSearchedCarrierCRMNotes" access="public" output="false" returntype="query">
    <cfargument name="searchText" required="yes" type="any" default="">
      <cfargument name="pageNo" required="yes" type="any" default="-1">
      <cfargument name="sortorder" required="no" type="any" default="DESC">
      <cfargument name="sortby" required="no" type="any" default="C.CreatedDateTime">
      <cfargument name="CarrierID" required="yes" type="any" default="">

      <cfargument name="FirstNoteDate" required="no" type="any" default="">
      <cfargument name="LastNoteDate" required="no" type="any" default="">

      <cfquery name="qCRMNotes" datasource="#Application.dsn#">
        <cfif arguments.pageNo neq -1>WITH page AS (</cfif>
        SELECT 
          C.CRMNoteID,
          C.Note,
          C.NoteUser,
          C.CreatedDateTime,
          CT.NoteType,
        ROW_NUMBER() OVER (ORDER BY
                     #arguments.sortBy#  #arguments.sortOrder#
              ) AS Row
      FROM CarrierCRMNotes C
      INNER JOIN CRMNoteTypes CT ON CT.CRMNoteTypeID = C.CRMNoteTypeID
      WHERE CarrierID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.CarrierID#">
      AND CT.CRMType = 'Carrier'
      <cfif isDefined("arguments.FirstNoteDate") and len(arguments.FirstNoteDate)>
        AND C.CreatedDateTime > = <cfqueryparam cfsqltype="cf_sql_date" value="#arguments.FirstNoteDate#">
      </cfif>
      <cfif isDefined("arguments.LastNoteDate") and len(arguments.LastNoteDate)>
        AND C.CreatedDateTime < = <cfqueryparam cfsqltype="cf_sql_timestamp" value="#arguments.LastNoteDate#  23:59:59.999">
      </cfif>
      <cfif arguments.pageNo neq -1>
                )
                SELECT * FROM page WHERE Row between (<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.pageNo#"> - 1) * 30 + 1 and <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.pageNo#"> * 30
            </cfif>
    </cfquery>

    <cfreturn qCRMNotes>
  </cffunction>

  <cffunction name="saveCRMCallFrequency" access="remote" output="false" returntype="any" returnFormat="plain">

    <cfargument name="CallFrequency" required="true">
    <cfargument name="NextCall" required="true">
    <cfargument name="editid" required="true">

    <cfset local.dsn = trim(listFirst(cgi.SCRIPT_NAME,'/'))>
    <cfquery name="qrysaveCRMCallFrequency" datasource="#local.dsn#">
      UPDATE Carriers 
      SET CRMCallFrequency = 
      <cfif len(trim(arguments.CallFrequency))>
        <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#arguments.CallFrequency#">
      <cfelse>
        NULL
      </cfif>
      <cfif len(trim(arguments.NextCall))>
        ,CRMNextCallDate = <cfqueryparam cfsqltype="cf_sql_date" value="#arguments.NextCall#">
      <cfelse>
        ,CRMNextCallDate = <cfqueryparam cfsqltype="cf_sql_date" value="" null="true">
      </cfif>
      WHERE CarrierID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.editid#">
    </cfquery>
    
  </cffunction>

  <cffunction name="saveCRMNote" access="remote" output="yes" returnformat="json">
    <cfargument name="carrierid" required="yes" type="any">
    <cfargument name="dsn" required="yes" type="any">
    <cfargument name="CRMNoteType" required="yes" type="any">
    <cfargument name="CRMNote" required="yes" type="any">
    <cfargument name="user" required="yes" type="any">
    <cfset response = structNew()>

    <cftry>
      <cfquery name="insertCRMnote" datasource="#arguments.dsn#">
        INSERT INTO CarrierCRMNotes VALUES(
          newid(),
          <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.carrierid#">,
          <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.CRMNote#">,
          <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.CRMNoteType#">,
          <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.user#">,
          getdate()
        )
      </cfquery>

      <cfquery name="getCustomerCallFrequency" datasource="#arguments.dsn#">
        SELECT ISNULL(CRMCallFrequency,0) AS CRMCallFrequency  FROM Carriers WHERE carrierid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.carrierid#">
      </cfquery>

      <cfquery name="updateCustomer" datasource="#arguments.dsn#">
        UPDATE Carriers SET 
        CRMLastCallDate = getdate() 
        <cfif getCustomerCallFrequency.CRMCallFrequency EQ 0>
          ,CRMNextCallDate =  NULL
        <cfelse>
          ,CRMNextCallDate =  DATEADD(day, #getCustomerCallFrequency.CRMCallFrequency#, getdate())
        </cfif>
        WHERE carrierid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.carrierid#">
      </cfquery>

      <cfset response.success = 1>
      <cfset response.msg = "Note added successfully.">
      <cfreturn response>

      <cfcatch>
        <cfset response.success = 0>
        <cfset response.msg = "Something went wrong. Please contact support">
        <cfreturn response>
      </cfcatch>
     </cftry>
  </cffunction>

  <cffunction name="getCarrierCRMOverdue" access="public" output="false" returntype="query">
      <cfargument name="iscarrier" required="no" type="any" default="">
      <cfquery name="qryCountCarrier" datasource="#Application.dsn#">
        SELECT COUNT(*) AS carrCount FROM Carriers WHERE CRMNextCallDate < getdate()
        AND CompanyID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#session.companyid#">
         <cfif structKeyExists(arguments, "iscarrier") and len(trim(arguments.iscarrier))>
        AND ISNULL(iscarrier,0) = <cfqueryparam cfsqltype="cf_sql_bit" value="#arguments.iscarrier#">
        </cfif>
    </cfquery>
  
    <cfreturn qryCountCarrier>
  </cffunction>

  <cffunction name="getCRMCalls" access="public" output="false" returntype="query">
    <cfargument name="searchText" required="no" type="any">
      <cfargument name="pageNo" required="no" type="any" default="1">
      <cfargument name="sortorder" required="no" type="any" default="ASC">
      <cfargument name="sortby" required="no" type="any" default="C.CRMNextCallDate">
      <cfargument name="iscarrier" required="no" type="any" default="">

      <cfquery name="qgetCRMCalls" datasource="#Application.dsn#">
        BEGIN WITH page AS 
        (SELECT 
        C.CarrierID,
        C.CarrierName,
        C.MCNumber,
        C.DOTNumber,
        C.City,
        C.stateCode,
        C.Phone,
        C.Status,
        C.EmailID,
        C.CRMNextCallDate,
        C.insExpDate,
        E.Name AS AssingedTo
        ,ROW_NUMBER() OVER (ORDER BY #arguments.sortby# #arguments.sortorder#) AS Row
        FROM Carriers C
        LEFT JOIN Employees E ON E.EmployeeID = C.CRMUser
        WHERE  C.CRMNextCallDate IS NOT NULL
        AND CompanyID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#session.companyid#">
        <cfif structKeyExists(arguments, "iscarrier") and len(trim(arguments.iscarrier))>
        AND ISNULL(iscarrier,0) = <cfqueryparam cfsqltype="cf_sql_bit" value="#arguments.iscarrier#">
        </cfif>
        <cfif structKeyExists(arguments, "searchText") and len(trim(arguments.searchText))>
          AND (C.CarrierName LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#arguments.searchText#%">
          OR C.MCNumber LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#arguments.searchText#%">
          OR C.DOTNumber LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#arguments.searchText#%">
          OR C.City LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#arguments.searchText#%">
          OR C.stateCode LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#arguments.searchText#%">
          OR E.Name  LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#arguments.searchText#%">)
        </cfif>
        )
        SELECT
          *,(select (max(row)/30) + (CASE WHEN max(row)%30 <> 0 THEN 1 ELSE 0 END)  FROM page) AS TotalPages 
        FROM page
        WHERE Row BETWEEN (<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.pageNo#"> - 1) * 30 + 1 AND <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.pageNo#"> * 30
        END
    </cfquery>

    <cfreturn qgetCRMCalls>
  </cffunction>

  <cffunction name="getarrierCRMReminder" access="public" output="false" returntype="query">
    <cfargument name="searchText" required="no" type="any">
      <cfargument name="pageNo" required="no" type="any" default="1">
      <cfargument name="sortorder" required="no" type="any" default="ASC">
      <cfargument name="sortby" required="no" type="any" default="C.CRMNextCallDate">
      <cfargument name="iscarrier" required="no" type="any" default="">

      <cfquery name="qgetCRMCalls" datasource="#Application.dsn#">
        BEGIN WITH page AS 
        (SELECT 
        C.CarrierID,
        C.CarrierName,
        C.MCNumber,
        C.DOTNumber,
        C.City,
        C.stateCode,
        C.Phone,
        C.Status,
        C.EmailID,
        C.CRMNextCallDate,
        E.Name AS AssingedTo
        ,ROW_NUMBER() OVER (ORDER BY #arguments.sortby# #arguments.sortorder#) AS Row
        FROM Carriers C
        LEFT JOIN Employees E ON E.EmployeeID = C.CRMUser
        WHERE C.CRMNextCallDate IS NOT NULL
        AND C.CompanyID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#session.CompanyID#">
        <cfif structKeyExists(arguments, "iscarrier") and len(trim(arguments.iscarrier))>
        AND ISNULL(iscarrier,0) = <cfqueryparam cfsqltype="cf_sql_bit" value="#arguments.iscarrier#">
        </cfif>
        AND C.CRMNextCallDate < getdate()
        <cfif structKeyExists(arguments, "searchText") and len(trim(arguments.searchText))>
          AND (C.CarrierName LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#arguments.searchText#%">
          OR C.MCNumber LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#arguments.searchText#%">
          OR C.DOTNumber LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#arguments.searchText#%">
          OR C.City LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#arguments.searchText#%">
          OR C.stateCode LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#arguments.searchText#%">
          OR E.Name  LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#arguments.searchText#%">)
        </cfif>
        )
        SELECT
          *
        FROM page
        WHERE Row BETWEEN (<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.pageNo#">- 1) * 30 + 1 AND <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.pageNo#"> * 30
        END
    </cfquery>

    <cfreturn qgetCRMCalls>
  </cffunction>

  <cffunction name="formatPhoneNumber">
    <cfargument name="phoneNumber" required="true" />
    <cfif len(phoneNumber) EQ 10>
        <cfreturn "#left(phoneNumber,3)#-#mid(phoneNumber,4,3)#-#right(phoneNumber,4)#" />
    <cfelse>
      <cfreturn phoneNumber />
    </cfif>
  </cffunction>

  <cffunction name="getCarrierContacts" access="public" output="false" returntype="query">
    <cfargument name="CarrierID" required="yes" type="any" default="">
      <cfargument name="CarrierContactID" required="no" type="any" default="">
      <cfquery name="qCarrierContacts" datasource="#Application.dsn#">
        SELECT * FROM CarrierContacts
      WHERE CarrierID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.CarrierID#">
      <cfif structKeyExists(arguments, "CarrierContactID") AND len(trim(arguments.CarrierContactID))>
        AND CarrierContactID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.CarrierContactID#">
      </cfif>
    </cfquery>
    
      <cfreturn qCarrierContacts>
  </cffunction>
  <cffunction name="saveCarrierContactFromLoadScreen" access="remote" output="false" returntype="any" returnFormat="json">
    <cfargument name="dsn" type="string" required="yes" />
    <cfargument name="fpContactType" type="string" required="yes" />
    <cfargument name="fpContactName" type="string" required="yes" />
    <cfargument name="fpContactPhone" type="string" required="yes" />
    <cfargument name="fpContactPhoneExt" type="string" required="yes" />
    <cfargument name="fpContactFax" type="string" required="yes" />
    <cfargument name="fpContactFaxExt" type="string" required="yes" />
    <cfargument name="fpContactTollFree" type="string" required="yes" />
    <cfargument name="fpContactTollFreeExt" type="string" required="yes" />
    <cfargument name="fpContactCell" type="string" required="yes" />
    <cfargument name="fpContactCellExt" type="string" required="yes" />
    <cfargument name="fpContactCellEmailID" type="string" required="yes" />
    <cfargument name="fpContactActive" type="string" required="yes" />
    <cfargument name="fpContactEmailAvailableLoads" type="string" required="no" default="0"/>
    <cfargument name="fpContactAddress" type="string" required="yes" />
    <cfargument name="fpContactCity" type="string" required="yes" />
    <cfargument name="fpContactState" type="string" required="yes" />
    <cfargument name="fpContactZip" type="string" required="yes" />
    <cfargument name="fpContactNotes" type="string" required="yes" />
    <cftry>
      <cfif structkeyexists(arguments,"fpContactEmailAvailableLoads")>
        <cfset local.fpContactEmailAvailableLoads = 1>
      <cfelse>
        <cfset local.fpContactEmailAvailableLoads = 0>
      </cfif>

      <cfquery name="qGet" datasource="#arguments.dsn#">
        SELECT NEWID() AS CarrierContactID
      </cfquery>
      <cfquery name="qAddCarrierContact" datasource="#arguments.dsn#">
        INSERT INTO CarrierContacts (
             [CarrierContactID]
            ,[CarrierID]
            ,[ContactPerson]
            ,[PhoneNo]
            ,[PhoneNoExt]
            ,[Fax]
            ,[FaxExt]
            ,[TollFree]
            ,[TollfreeExt]
            ,[PersonMobileNo]
            ,[MobileNoExt]
            ,[Email]
            ,[ContactType]
            ,[carrierEmailAvailableLoads]
            ,[Active]
            ,[Location]
            ,[City]
            ,[StateCode]
            ,[Zipcode]
            ,[Notes])
            VALUES(
              <cfqueryparam cfsqltype="cf_sql_varchar" value="#qGet.CarrierContactID#">
              ,<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.fpContactCarrierID#">
              ,<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.fpContactName#">
              ,<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.fpContactPhone#">
              ,<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.fpContactPhoneExt#">
              ,<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.fpContactFax#">
              ,<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.fpContactFaxExt#">
              ,<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.fpContactTollFree#">
              ,<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.fpContactTollfreeExt#">
              ,<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.fpContactCell#">
              ,<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.fpContactCellExt#">
              ,<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.fpContactCellEmailID#">
              ,<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.fpContactType#">
              ,<cfqueryparam cfsqltype="cf_sql_bit" value="#local.fpContactEmailAvailableLoads#">
              ,<cfqueryparam cfsqltype="cf_sql_bit" value="#arguments.fpContactActive#">
              ,<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.fpContactAddress#">
              ,<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.fpContactCity#">
              ,<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.fpContactState#">
              ,<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.fpContactZip#">
              ,<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.fpContactNotes#">
            )
      </cfquery>
      <cfset response.success = 1>
      <cfset response.id = qGet.CarrierContactID>
      <cfreturn response>
      <cfcatch type="any">
        <cfset response.success = 0>
        <cfreturn response>
      </cfcatch>
    </cftry>
  </cffunction>
  <cffunction name="addCarrierContact" access="public" output="false" returntype="string">
    <cfargument name="frmstruct" type="struct" required="yes" />

      <cfif structkeyexists(arguments.frmstruct,"carrierEmailAvailableLoads")>
        <cfset local.carrierEmailAvailableLoads = 1>
      <cfelse>
        <cfset local.carrierEmailAvailableLoads = 0>
      </cfif>
      <cfif structKeyExists(arguments.frmstruct, "Active")>
      <cfset var Active = 1>
    <cfelse>
      <cfset var Active = 0>
    </cfif>
      <cfquery name="qAddCarrierContact" datasource="#Application.dsn#">
        <cfif structkeyexists(arguments.frmstruct,"CarrierContactId") AND LEN(TRIM(arguments.frmstruct.CarrierContactId))>
          UPDATE CarrierContacts SET 
        [ContactPerson] = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.frmstruct.ContactPerson#">
        ,[PhoneNo] = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.frmstruct.PhoneNo#">
        ,[PhoneNoExt] = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.frmstruct.PhoneNoExt#">
        ,[Fax] = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.frmstruct.Fax#">
        ,[FaxExt] = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.frmstruct.FaxExt#">
        ,[TollFree] = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.frmstruct.TollFree#">
        ,[TollfreeExt] = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.frmstruct.TollfreeExt#">
        ,[PersonMobileNo] = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.frmstruct.PersonMobileNo#">
        ,[MobileNoExt] = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.frmstruct.MobileNoExt#">
        ,[Email] = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.frmstruct.Email#">
        ,[ContactType] = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.frmstruct.ContactType#">
        ,[carrierEmailAvailableLoads] = <cfqueryparam cfsqltype="cf_sql_bit" value="#local.carrierEmailAvailableLoads#">
        ,[Active] = <cfqueryparam cfsqltype="cf_sql_bit" value="#arguments.frmstruct.Active#">
        ,[Location]=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.frmstruct.Location#">
        ,[City]=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.frmstruct.City#">
        ,[StateCode]=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.frmstruct.State1#">
        ,[Zipcode]=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.frmstruct.ZipCode#">
        ,[Notes]=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.frmstruct.Notes#">
        WHERE CarrierContactId = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.frmstruct.CarrierContactID#">
        <cfelse>
          INSERT INTO CarrierContacts (
            [CarrierContactID]
          ,[CarrierID]
          ,[ContactPerson]
          ,[PhoneNo]
          ,[PhoneNoExt]
          ,[Fax]
          ,[FaxExt]
          ,[TollFree]
          ,[TollfreeExt]
          ,[PersonMobileNo]
          ,[MobileNoExt]
          ,[Email]
          ,[ContactType]
          ,[carrierEmailAvailableLoads]
          ,[Active]
          ,[Location]
          ,[City]
          ,[StateCode]
          ,[Zipcode]
          ,[Notes])
          VALUES(
            NEWID()
            ,<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.frmstruct.CarrierID#">
            ,<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.frmstruct.ContactPerson#">
            ,<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.frmstruct.PhoneNo#">
            ,<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.frmstruct.PhoneNoExt#">
            ,<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.frmstruct.Fax#">
            ,<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.frmstruct.FaxExt#">
            ,<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.frmstruct.TollFree#">
            ,<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.frmstruct.TollfreeExt#">
            ,<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.frmstruct.PersonMobileNo#">
            ,<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.frmstruct.MobileNoExt#">
            ,<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.frmstruct.Email#">
            ,<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.frmstruct.ContactType#">
            ,<cfqueryparam cfsqltype="cf_sql_bit" value="#local.carrierEmailAvailableLoads#">
            ,<cfqueryparam cfsqltype="cf_sql_bit" value="#arguments.frmstruct.Active#">
            ,<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.frmstruct.Location#">
            ,<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.frmstruct.City#">
            ,<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.frmstruct.State1#">
            ,<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.frmstruct.ZipCode#">
            ,<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.frmstruct.Notes#">
          )
        </cfif>
    </cfquery>
    
      <cfreturn 'Carrier contact saved successfully.'>
  </cffunction>

  <cffunction name="deleteCarrierContact" access="public" output="false" returntype="string">
    <cfargument name="CarrierContactID" required="no" type="any" default="">
    <cfquery name="qDelCarrierContact" datasource="#Application.dsn#">
      DELETE FROM CarrierContacts
      WHERE CarrierContactId = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.CarrierContactID#">
    </cfquery>
    <cfreturn 'Carrier contact deleted.'>
  </cffunction>

  <cffunction name="getDotNumberForUpdate" access="remote" output="yes" returnformat="json">
    <cfargument name="CompanyID" type="string" default="">
    <cfargument name="dsn" type="string" default="">
    <cfquery name="qryGetDotNumberForUpdate" datasource="#arguments.dsn#" result="result">
      select CarrierID,DotNumber from carriers where DOTNumber is not null AND LEN(TRIM(DOTNumber))>0
      AND DOTNumber <> '0'
      and companyid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.CompanyID#">
    </cfquery>

    <cfset tempArr = arrayNew(1)>
    <cfloop query="qryGetDotNumberForUpdate">
      <cfset tempStruct = structNew()>
      <cfset tempStruct.CarrierID = qryGetDotNumberForUpdate.CarrierID>
      <cfset tempStruct.DotNumber = qryGetDotNumberForUpdate.DotNumber>
      <cfset arrayAppend(tempArr, tempStruct)>
    </cfloop>

    <cfreturn serializeJSON(tempArr)>

  </cffunction>

  <cffunction name="UpdateViaCarrierLookOut" access="remote" output="false" returntype="string">
    <cfargument name="DotNumber" type="string" default="">
    <cfargument name="CompanyID" type="string" default="">
    <cfargument name="CarrierID" type="string" default="">
    <cfargument name="AdminUserName" type="string" default="">
    <cfargument name="dsn" type="string" default="">
    <cfargument name="opt" type="string" default="1" required="false">
    <cftry>

      <cfquery name="qSystemSetupOptions" datasource="#arguments.dsn#">
        SELECT CarrierLookoutAPIKey
        FROM SystemConfig WHERE CompanyID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.companyid#">
      </cfquery>  

      <cfset DOT_Number = trim(arguments.DotNumber)> 

      <cfhttp url="https://api.carriersoftware.com/api/CarrierInsurance?dot=#DOT_Number#" method="get"  throwonerror = Yes result="objCarrierInsurance" timeout="300">
        <cfhttpparam type="header" name="API_KEY" value="#qSystemSetupOptions.CarrierLookoutAPIKey#"/>
      </cfhttp>

      <cfhttp url="https://api.carriersoftware.com/api/BasicISS?dot=#DOT_Number#" method="get"  throwonerror = Yes result="objBasicISS">
        <cfhttpparam type="header" name="API_KEY" value="#qSystemSetupOptions.CarrierLookoutAPIKey#"/>
      </cfhttp>
      <cfif objBasicISS.Statuscode EQ '200 OK'>
          <cfset var BasicISS = DeserializeJSON(objBasicISS.Filecontent)>
          <cfif BasicISS.Total NEQ 0 AND NOT arrayIsEmpty(BasicISS.results)>
              <cfset var BasicISS = BasicISS.results[BasicISS.Total]>
          <cfelse>
              <cfset var BasicISS = structNew()>
          </cfif>
      </cfif>

      <cfif objCarrierInsurance.Statuscode EQ '200 OK'>
        <cfset var CarrierInsurance = DeserializeJSON(objCarrierInsurance.Filecontent)>

        <cfif not ArrayIsEmpty(CarrierInsurance.CarrierDockets)>

          <cfif arrayLen(CarrierInsurance.CarrierDockets) GT 1>
            <cfquery name="qGetMC" datasource="#arguments.dsn#">
              SELECT MCNumber FROM Carriers WHERE CarrierID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.CarrierID#">
            </cfquery>

            <cfif Len(trim(qGetMC.MCNumber))>
              <cfset var tempArr = arrayNew(1)>
              <cfloop from="1" to="#arrayLen(CarrierInsurance.CarrierDockets)#" index="i">
                <cfif CarrierInsurance.CarrierDockets[i].DocketNo EQ 'MC#qGetMC.MCNumber#'>
                  <cfset arrayAppend(tempArr, CarrierInsurance.CarrierDockets[i])>
                </cfif>
              </cfloop>
              <cfset CarrierInsurance.CarrierDockets = tempArr>
            </cfif>
          </cfif>

          <cfset var Carrier = structNew()>
          <cfset Carrier["CarrierID"] = arguments.CarrierID>
          <cfset Carrier["CarrierName"] = CarrierInsurance.CarrierDockets[1].LegalName>
          <cfset Carrier["VendorID"] = Left(ReplaceNoCase(CarrierInsurance.CarrierDockets[1].LegalName," ","","ALL"),10)>
          <cfset Carrier["MCNumber"] = replaceNoCase(CarrierInsurance.CarrierDockets[1].DocketNo, "MC", "")>
          <cfset Carrier["DOTNumber"] = DOT_Number>
          <cfif structKeyExists(CarrierInsurance.CarrierDockets[1], "Address")>
            <cfset Carrier["Address"] = CarrierInsurance.CarrierDockets[1].Address>
          <cfelse>
            <cfset Carrier["Address"] = "">
          </cfif>
          <cfif structKeyExists(CarrierInsurance.CarrierDockets[1], "City")>
            <cfset Carrier["City"] = CarrierInsurance.CarrierDockets[1].City>
          <cfelse>
            <cfset Carrier["City"] = "">  
          </cfif>
          <cfif structKeyExists(CarrierInsurance.CarrierDockets[1], "State")>
            <cfset Carrier["State"] = CarrierInsurance.CarrierDockets[1].State>
          <cfelse>
            <cfset Carrier["State"] = "">
          </cfif>
          <cfif structKeyExists(CarrierInsurance.CarrierDockets[1], "Zip")>
            <cfset Carrier["Zip"] = CarrierInsurance.CarrierDockets[1].Zip>
          <cfelse>
            <cfset Carrier["Zip"] = "">
          </cfif>
          <cfif structKeyExists(CarrierInsurance.CarrierDockets[1], "Country")>
            <cfset Carrier["Country"] = CarrierInsurance.CarrierDockets[1].Country>
          <cfelse>
            <cfset Carrier["Country"] = "">
          </cfif>
          <cfif structKeyExists(CarrierInsurance.CarrierDockets[1], "Phone")>
            <cfset Carrier["Phone"] = CarrierInsurance.CarrierDockets[1].Phone>
          <cfelse>
            <cfset Carrier["Phone"] = "">
          </cfif>
          <cfif structKeyExists(CarrierInsurance.CarrierDockets[1], "Fax")>
            <cfset Carrier["Fax"] = CarrierInsurance.CarrierDockets[1].Fax>
          <cfelse>
            <cfset Carrier["Fax"] = "">
          </cfif>
          <cfif structKeyExists(CarrierInsurance.CarrierDockets[1], "MailPhone")>
            <cfset Carrier["MailPhone"] = CarrierInsurance.CarrierDockets[1].MailPhone>
          <cfelse>
            <cfset Carrier["MailPhone"] = "">
          </cfif>
          <cfif structKeyExists(CarrierInsurance.CarrierDockets[1], "MailFax")>
            <cfset Carrier["MailFax"] = CarrierInsurance.CarrierDockets[1].MailFax>
          <cfelse>
            <cfset Carrier["MailFax"] = "">
          </cfif>

          <cftransaction>
            <cfif arguments.opt EQ 2>
              <cfquery name="qInsCarrier" datasource="#arguments.dsn#">
                  UPDATE Carriers SET
                  CarrierName = <cfqueryparam cfsqltype="cf_sql_varchar" value="#Carrier["CarrierName"]#">,
                  VendorID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#Carrier["VendorID"]#">, 
                  Address = <cfqueryparam cfsqltype="cf_sql_varchar" value="#Carrier["Address"]#" null="#not len(Carrier["Address"])#">,
                  City = <cfqueryparam cfsqltype="cf_sql_varchar" value="#Carrier["City"]#" null="#not len(Carrier["City"])#">,
                  StateCode = <cfqueryparam cfsqltype="cf_sql_varchar" value="#Carrier["State"]#" null="#not len(Carrier["State"])#">,
                  ZipCode = <cfqueryparam cfsqltype="cf_sql_varchar" value="#Carrier["Zip"]#" null="#not len(Carrier["Zip"])#">,
                  Country = <cfqueryparam cfsqltype="cf_sql_varchar" value="#Carrier["Country"]#" null="#not len(Carrier["Country"])#">,
                  Phone =  <cfqueryparam cfsqltype="cf_sql_varchar" value="#Carrier["Phone"]#" null="#not len(Carrier["Phone"])#">,
                  Fax = <cfqueryparam cfsqltype="cf_sql_varchar" value="#Carrier["Fax"]#" null="#not len(Carrier["Fax"])#">,
                  LastModifiedBy = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.adminusername#">,
                  LastModifiedDateTime = GETDATE()
                  WHERE CarrierID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#Carrier["CarrierID"]#">
              </cfquery>
            </cfif>
            <cfquery name="qDelCarrierInsurance" datasource="#arguments.dsn#">
              DELETE FROM CLActivePendingInsurance WHERE CarrierID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#Carrier["CarrierID"]#"> AND ISFromAPI = 1
            </cfquery>
            <cfquery name="qClearExp" datasource="#arguments.dsn#">
              UPDATE Carriers set InsExpDateCargo=NULL,InsExpDateGeneral=NULL
              WHERE CarrierID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#Carrier["CarrierID"]#">
            </cfquery>

            <cfset var BIPDExists = 0>
            <cfset var BIPDExpired = 0>
            <cfloop array="#CarrierInsurance.CarrierDockets[1].Insurances#" index="Insurance">
              <cfset var CarrierInsuranceInfo= structNew()>
              <cfset CarrierInsuranceInfo["DocketNo"] = CarrierInsurance.CarrierDockets[1].DocketNo>
              <cfif structkeyexists(Insurance,"FormCode")>
                <cfset CarrierInsuranceInfo["Form"] = Insurance.FormCode>
              <cfelse>
                <cfset CarrierInsuranceInfo["Form"] = "">
              </cfif>
              <cfset CarrierInsuranceInfo["Type"] = Insurance.InsType>
              <cfset CarrierInsuranceInfo["InsuranceCarrier"] = Insurance.InsCarrier>
              <cfset CarrierInsuranceInfo["PolicyNo"] = Insurance.PolicyNo>
              <cfset CarrierInsuranceInfo["CoveredTo"] = DollarFormat(Insurance.BiPdMaxLim*1000)>
              <cfif Insurance.InsType EQ 1>
                  <cfif structkeyexists(CarrierInsurance.CarrierDockets[1],"BiPdReq")>
                    <cfset CarrierInsuranceInfo["Req"] = DollarFormat(CarrierInsurance.CarrierDockets[1].BiPdReq*1000)>
                  <cfelse>
                    <cfset CarrierInsuranceInfo["Req"] = "">
                  </cfif>
              <cfelse>
                  <cfif structkeyexists(CarrierInsurance.CarrierDockets[1],"CargoReq")>
                    <cfset CarrierInsuranceInfo["Req"] = CarrierInsurance.CarrierDockets[1].CargoReq>
                  <cfelse>
                    <cfset CarrierInsuranceInfo["Req"] = "">
                  </cfif>
              </cfif>
              <cfif Insurance.InsType EQ 1>
                  <cfif structkeyexists(CarrierInsurance.CarrierDockets[1],"BiPdOnFile")>
                    <cfset CarrierInsuranceInfo["OnFile"] = DollarFormat(CarrierInsurance.CarrierDockets[1].BiPdOnFile*1000)>
                  <cfelse>
                    <cfset CarrierInsuranceInfo["OnFile"] = "">
                  </cfif>
              <cfelse>
                  <cfif structkeyexists(CarrierInsurance.CarrierDockets[1],"CargoOnFile")>
                    <cfset CarrierInsuranceInfo["OnFile"] = CarrierInsurance.CarrierDockets[1].CargoOnFile>
                  <cfelse>
                    <cfset CarrierInsuranceInfo["OnFile"] = "">
                  </cfif>
              </cfif>
              <cfif structkeyexists(Insurance,"BiPdClass")>
                <cfset CarrierInsuranceInfo["BiPdClass"] = Insurance.BiPdClass>
              <cfelse>
                <cfset CarrierInsuranceInfo["BiPdClass"] = "">
              </cfif>
              <cfset Insurance.InsExpDate =  DateFormat(DateAdd('yyyy',1,Insurance.InsEffDate),'yyyy-mm-dd')>
              <cfif DateCompare(Insurance.InsExpDate,DateFormat(now(),'yyyy-mm-dd')) EQ 1><!--- Expiry Date In Future --->
                <cfset CarrierInsuranceInfo["EffectiveDate"] = DateFormat(Insurance.InsEffDate,"mm/dd/yyyy")>
                <cfset CarrierInsuranceInfo["ExpirationDate"] = DateFormat(Insurance.InsExpDate,"mm/dd/yyyy")>
              <cfelse><!--- Expiry Date In Past --->
                <cfset InsEffYearDiff = DateDiff("yyyy",Insurance.InsEffDate,DateFormat(now(),'yyyy-mm-dd'))>
                <cfset InsExpYearDiff = DateDiff("yyyy",Insurance.InsExpDate,DateFormat(now(),'yyyy-mm-dd'))>
                <cfset CarrierInsuranceInfo["EffectiveDate"] = DateFormat(dateAdd("yyyy", InsEffYearDiff, Insurance.InsEffDate),"mm/dd/yyyy")>
                <cfset CarrierInsuranceInfo["ExpirationDate"] = DateFormat(dateAdd("yyyy", InsExpYearDiff+1, Insurance.InsExpDate),"mm/dd/yyyy")>
              </cfif>

              <cfif Insurance.InsType EQ 1>
                <cfquery name="qupdCarr" datasource="#arguments.dsn#">
                  UPDATE Carriers SET 
                  InsCompany = <cfqueryparam cfsqltype="cf_sql_varchar" value="#CarrierInsuranceInfo["InsuranceCarrier"]#"> 
                  ,InsPolicyNumber = <cfqueryparam cfsqltype="cf_sql_varchar" value="#CarrierInsuranceInfo["PolicyNo"]#">
                  ,InsExpDate = <cfqueryparam cfsqltype="cf_sql_date" value="#CarrierInsuranceInfo["ExpirationDate"]#">
                  ,InsLimit = <cfqueryparam cfsqltype="cf_sql_real" value="#replaceNoCase(replaceNoCase(CarrierInsuranceInfo["CoveredTo"],'$',''),',','','ALL')#">
                  WHERE CarrierID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#Carrier["CarrierID"]#">
                </cfquery>
              <cfelse>
                <cfquery name="qupdCarr" datasource="#arguments.dsn#">
                  UPDATE Carriers SET 
                  InsCompanyCargo = <cfqueryparam cfsqltype="cf_sql_varchar" value="#CarrierInsuranceInfo["InsuranceCarrier"]#"> 
                  ,InsPolicyNumberCargo = <cfqueryparam cfsqltype="cf_sql_varchar" value="#CarrierInsuranceInfo["PolicyNo"]#">
                  ,InsExpDateCargo = <cfqueryparam cfsqltype="cf_sql_date" value="#CarrierInsuranceInfo["ExpirationDate"]#">
                  ,InsLimitCargo = <cfqueryparam cfsqltype="cf_sql_real" value="#replaceNoCase(replaceNoCase(CarrierInsuranceInfo["CoveredTo"],'$',''),',','','ALL')#">
                  WHERE CarrierID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#Carrier["CarrierID"]#">
                </cfquery>
              </cfif>

              <cfquery name="qInsCarrierInsurance" datasource="#arguments.dsn#">
                INSERT INTO [dbo].[CLActivePendingInsurance]
                 ([ID]
                 ,[CarrierID]
                 ,[CreatedBy]
                 ,[DocketNo]
                 ,[Form]
                 ,[Type]
                 ,[InsuranceCarrier]
                 ,[PolicyNo]
                 ,[CoveredTo]
                 ,[Req]
                 ,[OnFile]
                 ,[EffectiveDate]
                 ,[ExpirationDate]
                 ,[ISFromAPI]
                 ,[BiPdClass])
                VALUES(
                  NEWID(),
                  <cfqueryparam cfsqltype="cf_sql_varchar" value="#Carrier["CarrierID"]#">,
                  <cfqueryparam value="#arguments.adminUserName#" cfsqltype="cf_sql_varchar">,
                  <cfqueryparam cfsqltype="cf_sql_varchar" value="#CarrierInsuranceInfo["DocketNo"]#">,
                  <cfqueryparam cfsqltype="cf_sql_varchar" value="#CarrierInsuranceInfo["Form"]#" null="#not len(CarrierInsuranceInfo["Form"])#">,
                  <cfqueryparam cfsqltype="cf_sql_integer" value="#CarrierInsuranceInfo["Type"]#">,
                  <cfqueryparam cfsqltype="cf_sql_varchar" value="#CarrierInsuranceInfo["InsuranceCarrier"]#">,
                  <cfqueryparam cfsqltype="cf_sql_varchar" value="#CarrierInsuranceInfo["PolicyNo"]#">,
                  <cfqueryparam cfsqltype="cf_sql_varchar" value="#CarrierInsuranceInfo["CoveredTo"]#">,
                  <cfqueryparam cfsqltype="cf_sql_varchar" value="#CarrierInsuranceInfo["Req"]#" null="#not len(CarrierInsuranceInfo["Req"])#">,
                  <cfqueryparam cfsqltype="cf_sql_varchar" value="#CarrierInsuranceInfo["OnFile"]#" null="#not len(CarrierInsuranceInfo["OnFile"])#">,
                  <cfqueryparam cfsqltype="cf_sql_date" value="#CarrierInsuranceInfo["EffectiveDate"]#">,
                  <cfqueryparam cfsqltype="cf_sql_date" value="#CarrierInsuranceInfo["ExpirationDate"]#">,
                  1,
                  <cfqueryparam cfsqltype="cf_sql_varchar" value="#CarrierInsuranceInfo["BiPdClass"]#" null="#not len(CarrierInsuranceInfo["BiPdClass"])#">
                  )
              </cfquery>
              <cfif CarrierInsuranceInfo["Type"] EQ 1 AND CarrierInsuranceInfo["BiPdClass"] EQ 'P'>
                <cfset BIPDExists = 1>
                <cfif DateDiff("d", CarrierInsuranceInfo["ExpirationDate"], now()) GT 0>
                  <cfset BIPDExpired = 1>
                </cfif>
              </cfif>
            </cfloop>
            <cfset Carrier["risk_assessment"] = "">
            <cfif NOT BIPDExists OR (BIPDExists AND BIPDExpired)>
              <cfset Carrier["risk_assessment"] = "Unacceptable">
            <cfelseif BIPDExists AND NOT BIPDExpired AND NOT StructIsEmpty(BasicISS) AND (BasicISS.UnsafeDriveBasicAlert EQ 'Y' OR BasicISS.HOSBasicAlert EQ 'Y' OR BasicISS.DrivFitBasicAlert EQ 'Y' OR BasicISS.ContrSubstBasicAlert EQ 'Y' OR BasicISS.VehMaintBasicAlert EQ 'Y' OR BasicISS.CrashBasicAlert EQ 'Y')>
              <cfset Carrier["risk_assessment"] = "Moderate">
            <cfelseif BIPDExists AND NOT BIPDExpired AND NOT StructIsEmpty(BasicISS) AND BasicISS.UnsafeDriveBasicAlert NEQ 'Y' AND BasicISS.HOSBasicAlert NEQ 'Y' AND BasicISS.DrivFitBasicAlert NEQ 'Y' AND BasicISS.ContrSubstBasicAlert NEQ 'Y' AND BasicISS.VehMaintBasicAlert NEQ 'Y' AND BasicISS.CrashBasicAlert NEQ 'Y'>
              <cfset Carrier["risk_assessment"] = "Acceptable">
            </cfif> 

            <cfquery name="qUpdCarrier" datasource="#arguments.dsn#">
              UPDATE Carriers SET RiskAssessment = <cfqueryparam cfsqltype="cf_sql_varchar" value="#Carrier["risk_assessment"]#" null="#yesNoFormat(NOT len(Carrier["risk_assessment"]))#"> WHERE CarrierID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#Carrier["CarrierID"]#">
            </cfquery>

            <cfhttp url="https://api.carriersoftware.com/api/InsuranceHistory?dot=#DOT_Number#" method="get"  throwonerror = Yes result="objCarrierInsuranceHistory">
              <cfhttpparam type="header" name="API_KEY" value="#trim(qSystemSetupOptions.CarrierLookoutAPIKey)#"/>
            </cfhttp>

            <cfif objCarrierInsuranceHistory.Statuscode EQ '200 OK'>
              <cfset CarrierInsuranceHistory = DeserializeJSON(objCarrierInsuranceHistory.Filecontent)>
              <cfquery name="qDelCarrierInsuranceHistory" datasource="#arguments.dsn#">
                DELETE FROM CLInsuranceHistory WHERE CarrierID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#Carrier["CarrierID"]#">
              </cfquery>
              <cfif NOT StructIsEmpty(CarrierInsuranceHistory) AND not ArrayIsEmpty(CarrierInsuranceHistory.results)>
                <cfloop array="#CarrierInsuranceHistory.results#" index="InsuranceHistory">
                  <cfset var CarrierInsuranceHistoryInfo= structNew()>
                  <cfset CarrierInsuranceHistoryInfo["DocketNo"] = InsuranceHistory.DocketNo>
                  <cfif structkeyexists(InsuranceHistory,"Form")>
                    <cfset CarrierInsuranceHistoryInfo["Form"] = InsuranceHistory.Form>
                  <cfelse>
                    <cfset CarrierInsuranceHistoryInfo["Form"] = "">
                  </cfif>
                  <cfset CarrierInsuranceHistoryInfo["Type"] = InsuranceHistory.Type>
                  <cfset CarrierInsuranceHistoryInfo["InsuranceCarrier"] = InsuranceHistory.Carrier>
                  <cfset CarrierInsuranceHistoryInfo["PolicyNo"] = InsuranceHistory.PolicyNo>
                  <cfset CarrierInsuranceHistoryInfo["CoveredTo"] = InsuranceHistory.CovMax>

                  <cfset CarrierInsuranceHistoryInfo["EffStartDate"] = "">
                  <cfif structkeyexists(InsuranceHistory,"EffStartDate")>
                    <cfset CarrierInsuranceHistoryInfo["EffStartDate"]= InsuranceHistory.EffStartDate.ReplaceFirst(
                        "^.*?(\d{4})-?(\d{2})-?(\d{2})T([\d:]+).*$",
                        "$1-$2-$3 $4"
                        ) />
                  </cfif>
                  <cfset CarrierInsuranceHistoryInfo["EffEndDate"] = "">
                  <cfif structkeyexists(InsuranceHistory,"EffEndDate")>
                    <cfset CarrierInsuranceHistoryInfo["EffEndDate"]= InsuranceHistory.EffEndDate.ReplaceFirst(
                        "^.*?(\d{4})-?(\d{2})-?(\d{2})T([\d:]+).*$",
                        "$1-$2-$3 $4"
                        ) />
                  </cfif>
                  <cfset CarrierInsuranceHistoryInfo["EndAction"] = InsuranceHistory.EndAction>

                  <cfquery name="qInsCarrierInsuranceHistory" datasource="#arguments.dsn#">
                    INSERT INTO [dbo].[CLInsuranceHistory]
                   ([ID]
                   ,[CarrierID]
                   ,[CreatedBy]
                   ,[DocketNo]
                   ,[Form]
                   ,[Type]
                   ,[InsuranceCarrier]
                   ,[PolicyNo]
                   ,[CoveredTo]
                   ,[EffectiveDateFrom]
                   ,[EffectiveDateTo]
                   ,[EndAction])
                   VALUES(
                    NEWID(),
                    <cfqueryparam cfsqltype="cf_sql_varchar" value="#Carrier["CarrierID"]#">,
                    <cfqueryparam value="#arguments.adminUserName#" cfsqltype="cf_sql_varchar">,
                    <cfqueryparam cfsqltype="cf_sql_varchar" value="#CarrierInsuranceHistoryInfo["DocketNo"]#">,
                    <cfqueryparam cfsqltype="cf_sql_varchar" value="#CarrierInsuranceHistoryInfo["Form"]#" null="#not len(CarrierInsuranceHistoryInfo["Form"])#">,
                    <cfqueryparam cfsqltype="cf_sql_varchar" value="#CarrierInsuranceHistoryInfo["Type"]#">,
                    <cfqueryparam cfsqltype="cf_sql_varchar" value="#CarrierInsuranceHistoryInfo["InsuranceCarrier"]#">,
                    <cfqueryparam cfsqltype="cf_sql_varchar" value="#CarrierInsuranceHistoryInfo["PolicyNo"]#">,
                    <cfqueryparam cfsqltype="cf_sql_varchar" value="#CarrierInsuranceHistoryInfo["CoveredTo"]#">,
                    <cfqueryparam cfsqltype="cf_sql_date" value="#CarrierInsuranceHistoryInfo["EffStartDate"]#"  null="#not len(CarrierInsuranceHistoryInfo["EffStartDate"])#">,
                    <cfqueryparam cfsqltype="cf_sql_date" value="#CarrierInsuranceHistoryInfo["EffEndDate"]#"  null="#not len(CarrierInsuranceHistoryInfo["EffEndDate"])#">,
                    <cfqueryparam cfsqltype="cf_sql_varchar" value="#CarrierInsuranceHistoryInfo["EndAction"]#">
                    )
                  </cfquery>
                </cfloop>
              </cfif>
            </cfif>

          </cftransaction>
          <cfquery name="qInsMC_DOT" datasource="ZFMCSA">
            IF(SELECT COUNT(id) FROM MC_DOT WHERE MC = <cfqueryparam cfsqltype="cf_sql_varchar" value="#Carrier["MCNumber"]#">) = 0
              BEGIN
              INSERT INTO [dbo].[MC_DOT]
               ([DOT]
               ,[MC]
               ,[Updated]
               ,[Carrier Name])
              VALUES
               (<cfqueryparam cfsqltype="cf_sql_varchar" value="#Carrier["DOTNumber"]#">
               ,<cfqueryparam cfsqltype="cf_sql_varchar" value="#Carrier["MCNumber"]#">
               ,GETDATE()
               ,<cfqueryparam cfsqltype="cf_sql_varchar" value="#Carrier["CarrierName"]#">)
            END
          </cfquery>
        </cfif>
      </cfif>
      
      <cfreturn 'success'>
      <cfcatch>
        <cfreturn 'error'>
      </cfcatch>
    </cftry>
  </cffunction>

  <cffunction name="CSVToQuery" access="public" returntype="query" output="false" hint="Converts the given CSV string to a query.">

    <cfargument name="CSV" type="string" required="true"  hint="This is the CSV string that will be manipulated."/>
    <cfargument name="Delimiter" type="string" required="false" default="," hint="This is the delimiter that will separate the fields within the CSV value."/>
    <cfargument name="Qualifier" type="string" required="false" default="""" hint="This is the qualifier that will wrap around fields that have special characters embeded."/>

    <cfset var LOCAL = StructNew() />
    <cfset ARGUMENTS.Delimiter = Left( ARGUMENTS.Delimiter, 1 ) />
    <cfif Len( ARGUMENTS.Qualifier )>
      <cfset ARGUMENTS.Qualifier = Left( ARGUMENTS.Qualifier, 1 ) />
    </cfif>
    <cfset LOCAL.LineDelimiter = Chr( 10 ) />
    <cfset ARGUMENTS.CSV = ARGUMENTS.CSV.ReplaceAll("\r?\n",LOCAL.LineDelimiter) />
    <cfset LOCAL.Delimiters = ARGUMENTS.CSV.ReplaceAll("[^\#ARGUMENTS.Delimiter#\#LOCAL.LineDelimiter#]+","").ToCharArray()/>
    <cfset ARGUMENTS.CSV = (" " & ARGUMENTS.CSV) />
    <cfset ARGUMENTS.CSV = ARGUMENTS.CSV.ReplaceAll("([\#ARGUMENTS.Delimiter#\#LOCAL.LineDelimiter#]{1})","$1 ") />
    <cfset LOCAL.Tokens = ARGUMENTS.CSV.Split("[\#ARGUMENTS.Delimiter#\#LOCAL.LineDelimiter#]{1}") />
    <cfset LOCAL.Rows = ArrayNew( 1 ) />
    <cfset ArrayAppend(LOCAL.Rows,ArrayNew( 1 )) />
    <cfset LOCAL.RowIndex = 1 />
    <cfset LOCAL.IsInValue = false />
    <cfloop index="LOCAL.TokenIndex" from="1" to="#ArrayLen( LOCAL.Tokens )#" step="1">
      <cfset LOCAL.FieldIndex = ArrayLen(LOCAL.Rows[ LOCAL.RowIndex ]) />
      <cfset LOCAL.Token = LOCAL.Tokens[ LOCAL.TokenIndex ].ReplaceFirst("^.{1}","") />
      <cfif Len( ARGUMENTS.Qualifier )>
        <cfif LOCAL.IsInValue>
          <cfset LOCAL.Token = LOCAL.Token.ReplaceAll("\#ARGUMENTS.Qualifier#{2}","{QUALIFIER}")/>
          <cfset LOCAL.Rows[ LOCAL.RowIndex ][ LOCAL.FieldIndex ] = (LOCAL.Rows[ LOCAL.RowIndex ][ LOCAL.FieldIndex ] &
            LOCAL.Delimiters[ LOCAL.TokenIndex - 1 ] & LOCAL.Token) />
          <cfif (Right( LOCAL.Token, 1 ) EQ ARGUMENTS.Qualifier)>
            <cfset LOCAL.Rows[ LOCAL.RowIndex ][ LOCAL.FieldIndex ] = LOCAL.Rows[ LOCAL.RowIndex ][ LOCAL.FieldIndex ].ReplaceFirst( ".{1}$", "" ) />
            <cfset LOCAL.IsInValue = false />
          </cfif>
        <cfelse>
          <cfif (Left( LOCAL.Token, 1 ) EQ ARGUMENTS.Qualifier)>
            <cfset LOCAL.Token = LOCAL.Token.ReplaceFirst("^.{1}","")/>
            <cfset LOCAL.Token = LOCAL.Token.ReplaceAll("\#ARGUMENTS.Qualifier#{2}","{QUALIFIER}")/>
            <cfif (Right( LOCAL.Token, 1 ) EQ ARGUMENTS.Qualifier)>
              <cfset ArrayAppend(LOCAL.Rows[ LOCAL.RowIndex ],LOCAL.Token.ReplaceFirst(".{1}$","")) />
            <cfelse>
              <cfset LOCAL.IsInValue = true />
              <cfset ArrayAppend(LOCAL.Rows[ LOCAL.RowIndex ],LOCAL.Token)/>
            </cfif>
          <cfelse>
            <cfset ArrayAppend(LOCAL.Rows[ LOCAL.RowIndex ],LOCAL.Token) />
          </cfif>
        </cfif>
        <cfset LOCAL.Rows[ LOCAL.RowIndex ][ ArrayLen( LOCAL.Rows[ LOCAL.RowIndex ] ) ] = Replace(
          LOCAL.Rows[ LOCAL.RowIndex ][ ArrayLen( LOCAL.Rows[ LOCAL.RowIndex ] ) ],"{QUALIFIER}",ARGUMENTS.Qualifier,
          "ALL") />
      <cfelse>
        <cfset ArrayAppend(LOCAL.Rows[ LOCAL.RowIndex ],LOCAL.Token)/>
      </cfif>
      <cfif ((NOT LOCAL.IsInValue) AND (LOCAL.TokenIndex LT ArrayLen( LOCAL.Tokens )) AND (LOCAL.Delimiters[ LOCAL.TokenIndex ] EQ LOCAL.LineDelimiter))>
        <cfset ArrayAppend(LOCAL.Rows,ArrayNew( 1 )) />
        <cfset LOCAL.RowIndex = (LOCAL.RowIndex + 1) />
      </cfif>
    </cfloop>

    <cfset LOCAL.MaxFieldCount = 0 />
    <cfset LOCAL.EmptyArray = ArrayNew( 1 ) />
    <cfloop index="LOCAL.RowIndex"from="1"to="#ArrayLen( LOCAL.Rows )#" step="1">
      <cfset LOCAL.MaxFieldCount = Max(LOCAL.MaxFieldCount,ArrayLen(LOCAL.Rows[ LOCAL.RowIndex ]))/>
      <cfset ArrayAppend(LOCAL.EmptyArray,"")/>
    </cfloop>

    <cfset LOCAL.Query = QueryNew( "" ) />

    <cfloop index="LOCAL.FieldIndex" from="1" to="#LOCAL.MaxFieldCount#" step="1">
      <cfset QueryAddColumn(LOCAL.Query,"COLUMN_#LOCAL.FieldIndex#","CF_SQL_VARCHAR",LOCAL.EmptyArray) />
    </cfloop>
    <cfloop index="LOCAL.RowIndex" from="1" to="#ArrayLen( LOCAL.Rows )#" step="1">
      <cfloop index="LOCAL.FieldIndex" from="1" to="#ArrayLen( LOCAL.Rows[ LOCAL.RowIndex ] )#" step="1">
        <cfset LOCAL.Query[ "COLUMN_#LOCAL.FieldIndex#" ][ LOCAL.RowIndex ] = JavaCast("string",LOCAL.Rows[ LOCAL.RowIndex ][ LOCAL.FieldIndex ]) />
      </cfloop>
    </cfloop>
    <cfreturn LOCAL.Query />

  </cffunction>

  <cffunction name="uploadCarrierViaCSV" access="remote" output="yes" returnformat="json">
    <cfargument name="createdBy" required="yes" type="any">
    <cfargument name="CompanyID" required="yes" type="any">
    <cfargument name="IsCarrier" required="yes" type="any">
    <cftry>
      <cfset row="">
      <cfset response = structNew()>  
      <cfset local.dsn = trim(listFirst(cgi.SCRIPT_NAME,'/'))>

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

      <cfset validHeader = "MC Number,Company Name,Address,City,State,Zip,Country,Phone,Fax,Email,Contact,DOT Number,SCAC,VendorCode,Fed Tax ID,Notes,Website">
      <cfset uploadedHeader = listgetAt('#csvfile#',1, '#chr(10)##chr(13)#')>


      <cfif Compare(validHeader, uploadedHeader) NEQ 0>
        <cffile action="delete" file="#rootPath##fileName#">
        <cfset response.success = 0>
        <cfset response.message = "There are one or more column headings that are not valid.  Please check correct and try again.">
        <cfreturn response>
      </cfif>

      <cfquery name="qGetCarrierMCs" datasource="#local.dsn#">
        SELECT trim(MCNumber) AS MCNumber FROM Carriers WHERE CompanyID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.companyid#">
      </cfquery>

      <cfset validMCNumbers = valuelist(qGetCarrierMCs.MCNumber)>
      <cfset currentRow = 1>
      <cfset bitImportedAll = 1>

      <cfloop index="row" list="#csvfile#" delimiters="#chr(10)##chr(13)#">
        <cfif currentRow NEQ 1>
          <cfset qryRow = CSVToQuery(row)>

          <cfset MCNumber = qryRow.column_1>
          <cfset CarrierName = qryRow.column_2>
          <cfset Address = qryRow.column_3>
          <cfset City = qryRow.column_4>
          <cfset State = qryRow.column_5>
          <cfset Zip = qryRow.column_6>
          <cfset Country = qryRow.column_7>
          <cfset Phone = qryRow.column_8>
          <cfset Fax = qryRow.column_9>
          <cfset Email = qryRow.column_10>
          <cfset Contact = qryRow.column_11>
          <cfset DotNumber = qryRow.column_12>
          <cfset SCAC = qryRow.column_13>
          <cfset VendorID = qryRow.column_14>
          <cfif not len(trim(VendorID))>
            <cfset VendorID = Left( CarrierName, 10 ) >
          </cfif> 
          <cfset TaxID = qryRow.column_15>
          <cfset Notes = qryRow.column_16>
          <cfset Website = qryRow.column_17>
          <cfif NOT listFindNoCase(validMCNumbers, MCNumber)>

            <cfif not len(trim(DotNumber))>
              <cfquery name="qGetDOT" datasource="ZFMCSA">
                select DOT from MC_DOT WHERE MC = <cfqueryparam cfsqltype="cf_sql_varchar" value="#MCNumber#">
              </cfquery>

              <cfif qGetDOT.recordcount>
                <cfset DotNumber = qGetDOT.DOT>
              </cfif>
            </cfif>

            <cfquery name="qGetcarrierID" datasource="#local.dsn#">
              SELECT NewID() as CarrierID
            </cfquery>
            <cfset CarrierID = qGetcarrierID.CarrierID>
            <cfquery name="qInscarrier" datasource="#local.dsn#">
              INSERT INTO Carriers(CarrierID,CompanyID,CarrierName,MCNumber,DotNumber,Address,City,stateCode,ZipCode,country,Phone,Fax,EmailID,ContactPerson,CreatedBy,LastModifiedBy,CreatedDateTime,LastModifiedDateTime,IsInsVerified,IsInsDate,IsContractVerified,IsW9,IsReferences,Status,Track1099,VendorID,IsCarrier,SCAC,TaxID,CarrierTerms,Notes,Website)
              VALUES(
                <cfqueryparam cfsqltype="cf_sql_varchar" value="#CarrierID#">,
                <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.companyid#">,
                <cfqueryparam cfsqltype="cf_sql_varchar" value="#CarrierName#">,
                <cfqueryparam cfsqltype="cf_sql_varchar" value="#MCNumber#">,
                <cfqueryparam cfsqltype="cf_sql_varchar" value="#DotNumber#">,
                <cfqueryparam cfsqltype="cf_sql_varchar" value="#Address#">,
                <cfqueryparam cfsqltype="cf_sql_varchar" value="#City#">,
                <cfqueryparam cfsqltype="cf_sql_varchar" value="#state#">,
                <cfqueryparam cfsqltype="cf_sql_varchar" value="#Zip#">,
                <cfqueryparam cfsqltype="cf_sql_varchar" value="#country#">,
                <cfqueryparam cfsqltype="cf_sql_varchar" value="#Phone#">,
                <cfqueryparam cfsqltype="cf_sql_varchar" value="#Fax#">,
                <cfqueryparam cfsqltype="cf_sql_varchar" value="#Email#">,
                <cfqueryparam cfsqltype="cf_sql_varchar" value="#Contact#">,
                <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.createdBy#">,
                <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.createdBy#">,
                GETDATE(),GETDATE(),
                0,0,0,0,0,1,1,
                <cfqueryparam cfsqltype="cf_sql_varchar" value="#VendorID#">
                ,<cfqueryparam cfsqltype="cf_sql_bit" value="#arguments.IsCarrier#">
                ,<cfqueryparam cfsqltype="cf_sql_varchar" value="#SCAC#">
                ,<cfqueryparam cfsqltype="cf_sql_varchar" value="#TaxID#">
                ,<cfqueryparam cfsqltype="cf_sql_varchar" value="#Notes#">
                ,<cfqueryparam cfsqltype="cf_sql_varchar" value="#Notes#">
                ,<cfqueryparam cfsqltype="cf_sql_varchar" value="#Website#">
              )
            </cfquery>

            <cfquery name="qInsLog" datasource="#local.dsn#">
              INSERT INTO CarrierCsvImportLog (LogId,Message,CreatedDate,Success,RowData,MCNumber,CompanyID,CreatedBy)
              VALUES(newid(),
                <cfqueryparam cfsqltype="cf_sql_varchar" value='Imported Carrier:MC#MCNumber#(Row Number:#currentRow#).'>,
                getdate(),
                1,
                <cfqueryparam cfsqltype="cf_sql_varchar" value="#row#">,
                <cfqueryparam cfsqltype="cf_sql_varchar" value="#MCNumber#">,
                <cfqueryparam cfsqltype="cf_sql_varchar" value='#arguments.companyid#'>,
                <cfqueryparam cfsqltype="cf_sql_varchar" value='#arguments.createdBy#'>
              )
            </cfquery>

          <cfelse>
            <cfset bitImportedAll = 0>
            <cfquery name="qInsLog" datasource="#local.dsn#">
              INSERT INTO carriercsvimportlog (LogId,Message,CreatedDate,Success,RowData,CompanyID,MCNumber,CreatedBy)
              VALUES(newid(),
                <cfqueryparam cfsqltype="cf_sql_varchar" value='MC (#MCNumber#) already exists.Row Number:#currentRow#'>,
                getdate(),0,
                <cfqueryparam cfsqltype="cf_sql_varchar" value="#row#">,
                <cfqueryparam cfsqltype="cf_sql_varchar" value='#arguments.companyid#'>,
                <cfqueryparam cfsqltype="cf_sql_varchar" value="#MCNumber#">,
                <cfqueryparam cfsqltype="cf_sql_varchar" value='#arguments.createdBy#'>)
            </cfquery>
          </cfif>
        </cfif>
        <cfset currentRow++>
      </cfloop>

      <cfset response.success = 1>
      <cfif bitImportedAll EQ 0>
        <cfset response.message = "Some rows are not imported. Please check log for more details.">
      <cfelse>
        <cfset response.message = "[Type] imported successfully. Please check log for more details.">
      </cfif>
      <cfreturn response>
      <cfcatch>
        <cfquery name="qInsLog" datasource="#local.dsn#">
          INSERT INTO carriercsvimportlog (LogId,Message,CreatedDate,Success,RowData,CompanyID,CreatedBy)
          VALUES(newid(),
            <cfqueryparam cfsqltype="cf_sql_varchar" value="#cfcatch.message##cfcatch.detail#">,
            getdate(),0,
            <cfqueryparam cfsqltype="cf_sql_varchar" value="#row#">,
            <cfqueryparam cfsqltype="cf_sql_varchar" value='#arguments.companyid#'>,
            <cfqueryparam cfsqltype="cf_sql_varchar" value='#arguments.createdBy#'>
            )
        </cfquery>

        <cfset response.success = 0>
        <cfset response.message = "Something went wrong. Please contact support.">
        <cfreturn response>
      </cfcatch>
    </cftry>
  </cffunction>

  <cffunction name="getCarrierCsvImportLog" access="public" output="false" returntype="query">
    <cfargument name="searchText" required="no" type="any">
    <cfargument name="pageNo" required="no" type="any" default="1">
    <cfargument name="sortorder" required="no" type="any" default="DESC">
    <cfargument name="sortby" required="no" type="any" default="CreatedDate">

      <cfquery name="qgetCarrierCsvImportLog" datasource="#Application.dsn#">
        BEGIN WITH page AS 
        (SELECT 
          P.LogID
          ,P.MCNumber
          ,P.Message
          ,P.CreatedDate
          ,P.Success
          ,P.CreatedBy
          ,ROW_NUMBER() OVER (ORDER BY #arguments.sortby# #arguments.sortorder#) AS Row
        FROM CarrierCsvImportLog P
        WHERE  P.CompanyID = <cfqueryparam value="#session.CompanyID#" cfsqltype="varchar">
        <cfif structKeyExists(arguments, "searchText") and len(trim(arguments.searchText))>
          AND P.MCNumber LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#arguments.searchText#%">
        </cfif>
        )
        SELECT
          *,(select (max(row)/30) + (CASE WHEN max(row)%30 <> 0 THEN 1 ELSE 0 END)  FROM page) AS TotalPages
        FROM page
        WHERE Row BETWEEN (<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.pageNo#"> - 1) * 30 + 1 AND <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.pageNo#"> * 30
        END
    </cfquery>

    <cfreturn qgetCarrierCsvImportLog>
  </cffunction>

  <cffunction name="createViaSaferWatch" access="public" output="false" returntype="string">
    <cfargument name="DotNumber" type="string" required="false" default="">
    <cfargument name="MCNumber" type="string" required="false" default="">
    <cfargument name="CompanyID" type="string" required="no" default=""/>
    <cftry>
      <cfif structKeyExists(arguments, "CompanyID") AND len(trim(arguments.CompanyID))>
        <cfset var local.CompanyID = arguments.CompanyID>
      <cfelse>
        <cfset var local.CompanyID = session.CompanyID>
      </cfif>
      <cfif len(trim(arguments.MCNumber))>
        <cfset var DOT_Number ="MC"& trim(arguments.MCNumber)>      
      <cfelseif len(trim(arguments.DOTNumber))>
        <cfset var DOT_Number = trim(arguments.DOTNumber)> 
      </cfif>

      <cfquery name="qSystemSetupOptions" datasource="#Application.dsn#">
        SELECT SaferWatch,SaferWatchWebKey,SaferWatchCustomerKey,FreightBroker,SaferWatchUpdateCarrierInfo,SaferWatchCertData
        FROM SystemConfig WHERE CompanyID = <cfqueryparam value="#local.CompanyID#" cfsqltype="cf_sql_varchar">
      </cfquery>

      <cfhttp url="http://www.saferwatch.com/webservices/CarrierService32.php?Action=CarrierLookup&ServiceKey=#qSystemSetupOptions.SaferWatchWebKey#&CustomerKey=#qSystemSetupOptions.SaferWatchCustomerKey#&number=#trim(DOT_Number)#" method="get" throwonerror = Yes>
      </cfhttp>

      <cfif cfhttp.Statuscode EQ '200 OK'>
        <cfset variables.responsestatus = structNew()>    
        <cfset variables.responsestatus = ConvertXmlToStruct(cfhttp.Filecontent, StructNew()) >
        <cfset var Carrier = structNew()>
        <cfquery name="qGetcarrierID" datasource="#Application.dsn#">
          SELECT NewID() as CarrierID
        </cfquery>
        <cfset CarrierName = variables.responsestatus.CarrierDetails.Identity.legalName>

        <cfset Carrier["CarrierID"] = qGetcarrierID.CarrierID>
        <cfset Carrier["CarrierName"] = variables.responsestatus.CarrierDetails.Identity.legalName>
        <cfset Carrier["VendorID"] = Left(ReplaceNoCase(variables.responsestatus.CarrierDetails.Identity.legalName," ","","ALL"),10)>
        <cfset Carrier["MCNumber"] = replaceNoCase(variables.responsestatus.CarrierDetails.docketNumber, "MC", "")>
        <cfset Carrier["DOTNumber"] = variables.responsestatus.CarrierDetails.dotNumber>
        <cfset Carrier["Address"] = variables.responsestatus.CarrierDetails.Identity.businessStreet>
        <cfset Carrier["City"] = variables.responsestatus.CarrierDetails.Identity.businessCity>
        <cfset Carrier["State"] = variables.responsestatus.CarrierDetails.Identity.businessState>
        <cfset Carrier["Zip"] = variables.responsestatus.CarrierDetails.Identity.businessZipCode>
        <cfset Carrier["Country"] = variables.responsestatus.CarrierDetails.Identity.businessCountry>
        <cfset Carrier["Phone"] = variables.responsestatus.CarrierDetails.Identity.businessPhone>
        <cfset Carrier["Fax"] = variables.responsestatus.CarrierDetails.Identity.businessFax>
        <cfset Carrier["Cel"] = variables.responsestatus.CarrierDetails.Identity.cellPhone>
        <cfset Carrier["EmailID"] = replace(variables.responsestatus.CarrierDetails.Identity.emailAddress,' ','','all')>
        <cfif structKeyExists(variables.responsestatus.CarrierDetails.Identity, "CompanyRep1")>
          <cfset Carrier["ContactPerson"] = variables.responsestatus.CarrierDetails.Identity.CompanyRep1>
        <cfelseif structKeyExists(variables.responsestatus.CarrierDetails.Identity, "CompanyRep2")>
          <cfset Carrier["ContactPerson"] = variables.responsestatus.CarrierDetails.Identity.CompanyRep2>
        <cfelse>
          <cfset Carrier["ContactPerson"] = "">
        </cfif>
       
        <cftransaction>
          <cfquery name="qInsCarrier" datasource="#Application.dsn#">
            INSERT INTO Carriers(CarrierID,CompanyID,CarrierName,MCNumber,DotNumber,Address,City,stateCode,ZipCode,country,phone,fax,CreatedBy,LastModifiedBy,CreatedDateTime,LastModifiedDateTime,IsInsVerified,IsInsDate,IsContractVerified,IsW9,IsReferences,Status,Track1099,VendorID,IsCarrier,Cel,EmailID,ContactPerson
              )
            VALUES(
              <cfqueryparam cfsqltype="cf_sql_varchar" value="#Carrier["CarrierID"]#">,
              <cfqueryparam cfsqltype="cf_sql_varchar" value="#local.companyid#">,
              <cfqueryparam cfsqltype="cf_sql_varchar" value="#Carrier["CarrierName"]#">,
              <cfqueryparam cfsqltype="cf_sql_varchar" value="#Carrier["MCNumber"]#">,
              <cfqueryparam cfsqltype="cf_sql_varchar" value="#Carrier["DOTNumber"]#">,
              <cfqueryparam cfsqltype="cf_sql_varchar" value="#Carrier["Address"]#" null="#not len(Carrier["Address"])#">,
              <cfqueryparam cfsqltype="cf_sql_varchar" value="#Carrier["City"]#" null="#not len(Carrier["City"])#">,
              <cfqueryparam cfsqltype="cf_sql_varchar" value="#Carrier["State"]#" null="#not len(Carrier["State"])#">,
              <cfqueryparam cfsqltype="cf_sql_varchar" value="#Carrier["Zip"]#" null="#not len(Carrier["Zip"])#">,
              <cfqueryparam cfsqltype="cf_sql_varchar" value="#Carrier["Country"]#" null="#not len(Carrier["Country"])#">,
              <cfqueryparam cfsqltype="cf_sql_varchar" value="#Carrier["Phone"]#" null="#not len(Carrier["Phone"])#">,
              <cfqueryparam cfsqltype="cf_sql_varchar" value="#Carrier["Fax"]#" null="#not len(Carrier["Fax"])#">,
              <cfif structKeyExists(session, "adminusername")>
                <cfqueryparam cfsqltype="cf_sql_varchar" value="#session.adminusername#">,
                <cfqueryparam cfsqltype="cf_sql_varchar" value="#session.adminusername#">,
              <cfelse>
                'Onboard',
                'Onboard',
              </cfif>
              GETDATE(),GETDATE(),
              0,0,0,0,0,1,1,
              <cfqueryparam cfsqltype="cf_sql_varchar" value="#Carrier["VendorID"]#">,
              1,
              <cfqueryparam cfsqltype="cf_sql_varchar" value="#Carrier["Cel"]#" null="#not len(Carrier["Cel"])#">,
              <cfqueryparam cfsqltype="cf_sql_varchar" value="#Carrier["EmailID"]#" null="#not len(Carrier["EmailID"])#">,
              <cfqueryparam cfsqltype="cf_sql_varchar" value="#Carrier["ContactPerson"]#" null="#not len(Carrier["ContactPerson"])#">
            )
          </cfquery>

          <cfif IsStruct(variables.responsestatus.CarrierDetails.FMCSAInsurance.PolicyList)>
            <cfif IsArray(variables.responsestatus.CarrierDetails.FMCSAInsurance.PolicyList.PolicyItem)>
              <cfset insCarrier     = left(variables.responsestatus.CarrierDetails.FMCSAInsurance.PolicyList.PolicyItem[1].companyName,100)>
              <cfset InsAgentPhone  = formatPhoneNumber(variables.responsestatus.CarrierDetails.FMCSAInsurance.PolicyList.PolicyItem[1].phone)>
              <cfset insAgentName   = variables.responsestatus.CarrierDetails.FMCSAInsurance.PolicyList.PolicyItem[1].attnToName>
              <cfset formatRequired  = variables.responsestatus.CarrierDetails.FMCSAInsurance.PolicyList.PolicyItem[1].address&","&variables.responsestatus.CarrierDetails.FMCSAInsurance.PolicyList.PolicyItem[1].city&" "&variables.responsestatus.CarrierDetails.FMCSAInsurance.PolicyList.PolicyItem[1].stateCode&","&variables.responsestatus.CarrierDetails.FMCSAInsurance.PolicyList.PolicyItem[1].postalCode&","&variables.responsestatus.CarrierDetails.FMCSAInsurance.PolicyList.PolicyItem[1].countryCode>
                <cfset insPolicy        = left(variables.responsestatus.CarrierDetails.FMCSAInsurance.PolicyList.PolicyItem[1].policyNumber,50)>
            <cfelse>
              <cfset insCarrier = left(variables.responsestatus.CarrierDetails.FMCSAInsurance.PolicyList.PolicyItem.companyName,100)>
              <cfset InsAgentPhone = formatPhoneNumber(variables.responsestatus.CarrierDetails.FMCSAInsurance.PolicyList.PolicyItem.phone)>
              <cfset insAgentName = variables.responsestatus.CarrierDetails.FMCSAInsurance.PolicyList.PolicyItem.attnToName>
              <cfset formatRequired = variables.responsestatus.CarrierDetails.FMCSAInsurance.PolicyList.PolicyItem.address&"&##13;&##10;"&variables.responsestatus.CarrierDetails.FMCSAInsurance.PolicyList.PolicyItem.city&"&nbsp;"&variables.responsestatus.CarrierDetails.FMCSAInsurance.PolicyList.PolicyItem.stateCode&",&nbsp;"&variables.responsestatus.CarrierDetails.FMCSAInsurance.PolicyList.PolicyItem.postalCode&"&##13;&##10;"&variables.responsestatus.CarrierDetails.FMCSAInsurance.PolicyList.PolicyItem.countryCode>
              <cfset insPolicy = left(variables.responsestatus.CarrierDetails.FMCSAInsurance.PolicyList.PolicyItem.policyNumber,50)>
              <cfif qSystemSetupOptions.SaferWatchCertData EQ 1 AND IsDate(variables.responsestatus.CarrierDetails.FMCSAInsurance.PolicyList.PolicyItem.cancelationDate) AND qSystemSetupOptions.SaferWatchUpdateCarrierInfo EQ 1 AND variables.responsestatus.CarrierDetails.FMCSAInsurance.PolicyList.PolicyItem.cancelationDate NEQ "" AND qSystemSetupOptions.SaferWatchCertData EQ 1>
                <cfset InsExpDateLive = variables.responsestatus.CarrierDetails.FMCSAInsurance.PolicyList.PolicyItem.cancelationDate >
              </cfif>
              <cfif qSystemSetupOptions.SaferWatchCertData EQ 1 AND variables.responsestatus.CarrierDetails.FMCSAInsurance.PolicyList.PolicyItem.insuranceType  NEQ "BIPD" AND IsDate(variables.responsestatus.CarrierDetails.FMCSAInsurance.PolicyList.PolicyItem.cancelationDate)  AND  qSystemSetupOptions.SaferWatchUpdateCarrierInfo EQ 1 AND  variables.responsestatus.CarrierDetails.FMCSAInsurance.PolicyList.PolicyItem.cancelationDate NEQ "">
                <cfset CARGOExpirationDate = variables.responsestatus.CarrierDetails.FMCSAInsurance.PolicyList.PolicyItem.cancelationDate >
              <cfelseif qSystemSetupOptions.SaferWatchCertData EQ 1 AND  IsDate(variables.responsestatus.CarrierDetails.FMCSAInsurance.PolicyList.PolicyItem.cancelationDate) AND  qSystemSetupOptions.SaferWatchUpdateCarrierInfo EQ 1 AND variables.responsestatus.CarrierDetails.FMCSAInsurance.PolicyList.PolicyItem.cancelationDate NEQ "">
                <cfset ExpirationDate = variables.responsestatus.CarrierDetails.FMCSAInsurance.PolicyList.PolicyItem.cancelationDate >
              </cfif>
            </cfif>
          </cfif>
          <cfif qSystemSetupOptions.SaferWatchUpdateCarrierInfo EQ 1>
            <cfset bipd_Insurance_on_file = variables.responsestatus.CarrierDetails.FMCSAInsurance.bipdOnFile>
            <cfset BIPDInsRequired        = variables.responsestatus.CarrierDetails.FMCSAInsurance.bipdRequired>
            <cfset BIPDInsonFile          = variables.responsestatus.CarrierDetails.FMCSAInsurance.bipdOnFile>
            <cfset cargoInsRequired       = variables.responsestatus.CarrierDetails.FMCSAInsurance.cargoRequired>
            <cfset cargoInsonFile         = variables.responsestatus.CarrierDetails.FMCSAInsurance.cargoOnFile>         
          </cfif>
          <cfif structKeyExists(variables.responsestatus.CarrierDetails,"CertData") AND isStruct(variables.responsestatus.CarrierDetails.CertData) AND structKeyExists(variables.responsestatus.CarrierDetails.CertData,"Certificate") AND isStruct(variables.responsestatus.CarrierDetails.CertData.Certificate) AND structKeyExists(variables.responsestatus.CarrierDetails.CertData.Certificate,"Coverage") AND qSystemSetupOptions.SaferWatchCertData EQ 1 >  
            <cfif structKeyExists(variables.responsestatus.CarrierDetails,"FMCSAInsurance") AND isstruct(variables.responsestatus.CarrierDetails.FMCSAInsurance) AND structKeyExists(variables.responsestatus.CarrierDetails.FMCSAInsurance,"bipdOnFile")>
              <cfset bipd_Insurance_on_file = variables.responsestatus.CarrierDetails.FMCSAInsurance.bipdOnFile>
            </cfif>
            <cfif structKeyExists(variables.responsestatus.CarrierDetails.CertData.Certificate,"producerEmail")>
              <cfset InsEmail = variables.responsestatus.CarrierDetails.CertData.Certificate.producerEmail>
              <cfset InsEmailCargo = variables.responsestatus.CarrierDetails.CertData.Certificate.producerEmail>
              <cfset InsEmailGeneral = variables.responsestatus.CarrierDetails.CertData.Certificate.producerEmail>
            </cfif>
            <cfif structKeyExists(variables.responsestatus.CarrierDetails.Identity, "companyRep1")>
              <cfset RemitName = variables.responsestatus.CarrierDetails.Identity.companyRep1>
            </cfif>
            <cfif structKeyExists(variables.responsestatus.CarrierDetails.Identity, "mailingStreet")>
              <cfset RemitAddress = variables.responsestatus.CarrierDetails.Identity.mailingStreet>
            </cfif>
            <cfif structKeyExists(variables.responsestatus.CarrierDetails.Identity, "mailingCity")>
              <cfset RemitCity = variables.responsestatus.CarrierDetails.Identity.mailingCity>
            </cfif>
            <cfif structKeyExists(variables.responsestatus.CarrierDetails.Identity, "mailingState")>
              <cfset RemitState = variables.responsestatus.CarrierDetails.Identity.mailingState>
            </cfif>
            <cfif structKeyExists(variables.responsestatus.CarrierDetails.Identity, "mailingZipCode")>
              <cfset RemitZipCode = variables.responsestatus.CarrierDetails.Identity.mailingZipCode>
            </cfif>
            <cfif structKeyExists(variables.responsestatus.CarrierDetails.Identity, "mailingPhone")>
              <cfset RemitPhone = variables.responsestatus.CarrierDetails.Identity.mailingPhone>
            </cfif>
            <cfif structKeyExists(variables.responsestatus.CarrierDetails.Identity, "mailingPhone")>
              <cfset RemitFax = variables.responsestatus.CarrierDetails.Identity.mailingFax>
            </cfif>
            <cfif IsArray(variables.responsestatus.CarrierDetails.CertData.Certificate.Coverage)>
              <cfset InsExpDateLive = variables.responsestatus.CarrierDetails.CertData.Certificate.Coverage[1].expirationDate>
              <cfset ExpirationDate = variables.responsestatus.CarrierDetails.CertData.Certificate.Coverage[1].expirationDate>
              <cfloop from="1" to="#arrayLen(variables.responsestatus.CarrierDetails.CertData.Certificate.Coverage)#" index="i">
                <cfif variables.responsestatus.CarrierDetails.CertData.Certificate.Coverage[i].type CONTAINS "Cargo">
                  <cfset InsCompanyCargo = variables.responsestatus.CarrierDetails.CertData.Certificate.Coverage[i].insurerName>
                  <cfset InsComPhoneCargo = InsAgentPhone>
                  <cfif structKeyExists(variables.responsestatus.CarrierDetails.CertData.Certificate,"producerName")>
                    <cfset InsAgentCargo = variables.responsestatus.CarrierDetails.CertData.Certificate.producerName>
                  </cfif>
                  <cfif structKeyExists(variables.responsestatus.CarrierDetails.CertData.Certificate,"producerPhone")>
                    <cfset InsAgentPhoneCargo = variables.responsestatus.CarrierDetails.CertData.Certificate.producerPhone>
                  </cfif>
                  <cfif structKeyExists(variables.responsestatus.CarrierDetails.CertData.Certificate,"producerAddress")>
                    <cfset InsuranceCompanyAddressCargo = variables.responsestatus.CarrierDetails.CertData.Certificate.producerAddress>
                  </cfif>
                  <cfif structKeyExists(variables.responsestatus.CarrierDetails.CertData.Certificate,"producerCity")>
                    <cfset InsuranceCompanyAddressCargo = InsuranceCompanyAddressCargo&','&variables.responsestatus.CarrierDetails.CertData.Certificate.producerCity>
                  </cfif>
                  <cfif structKeyExists(variables.responsestatus.CarrierDetails.CertData.Certificate,"producerState")>
                    <cfset InsuranceCompanyAddressCargo = InsuranceCompanyAddressCargo&' '&variables.responsestatus.CarrierDetails.CertData.Certificate.producerState>
                  </cfif>
                  <cfif structKeyExists(variables.responsestatus.CarrierDetails.CertData.Certificate,"producerZip")>
                    <cfset InsuranceCompanyAddressCargo = InsuranceCompanyAddressCargo&','&variables.responsestatus.CarrierDetails.CertData.Certificate.producerZip>
                  </cfif>
                  <cfset InsPolicyNoCargo = variables.responsestatus.CarrierDetails.CertData.Certificate.Coverage[i].policyNumber>
                  <cfset InsExpDateCargo = variables.responsestatus.CarrierDetails.CertData.Certificate.Coverage[i].expirationDate>
                  <cfset InsLimitCargo = variables.responsestatus.CarrierDetails.CertData.Certificate.Coverage[i].coverageLimit>
                <cfelseif variables.responsestatus.CarrierDetails.CertData.Certificate.Coverage[i].type CONTAINS "General">
                  <cfif structKeyExists(variables.responsestatus.CarrierDetails.CertData.Certificate,"producerName")>
                    <cfset InsAgentGeneral = variables.responsestatus.CarrierDetails.CertData.Certificate.producerName>
                  </cfif>
                  <cfif structKeyExists(variables.responsestatus.CarrierDetails.CertData.Certificate,"producerPhone")>
                    <cfset InsAgentPhoneGeneral = variables.responsestatus.CarrierDetails.CertData.Certificate.producerPhone>
                  </cfif>
                  <cfif structKeyExists(variables.responsestatus.CarrierDetails.CertData.Certificate,"producerAddress")>
                    <cfset InsuranceCompanyAddressGeneral = variables.responsestatus.CarrierDetails.CertData.Certificate.producerAddress>
                  </cfif>
                  <cfif structKeyExists(variables.responsestatus.CarrierDetails.CertData.Certificate,"producerCity")>
                    <cfset InsuranceCompanyAddressGeneral = InsuranceCompanyAddressGeneral&','&variables.responsestatus.CarrierDetails.CertData.Certificate.producerCity>
                  </cfif>
                  <cfif structKeyExists(variables.responsestatus.CarrierDetails.CertData.Certificate,"producerState")>
                    <cfset InsuranceCompanyAddressGeneral = InsuranceCompanyAddressGeneral&' '&variables.responsestatus.CarrierDetails.CertData.Certificate.producerState>
                  </cfif>
                  <cfif structKeyExists(variables.responsestatus.CarrierDetails.CertData.Certificate,"producerZip")>
                    <cfset InsuranceCompanyAddressGeneral = InsuranceCompanyAddressGeneral&','&variables.responsestatus.CarrierDetails.CertData.Certificate.producerZip>
                  </cfif>
                  <cfset InsPolicyNoGeneral = variables.responsestatus.CarrierDetails.CertData.Certificate.Coverage[i].policyNumber>
                  <cfset InsExpDateGeneral = variables.responsestatus.CarrierDetails.CertData.Certificate.Coverage[i].expirationDate>
                  <cfset InsLimitGeneral = variables.responsestatus.CarrierDetails.CertData.Certificate.Coverage[i].coverageLimit>
                  <cfset InsCompanyGeneral = variables.responsestatus.CarrierDetails.CertData.Certificate.Coverage[i].insurerName>
                  <cfset InsComPhoneGeneral = InsAgentPhone>
                </cfif>
              </cfloop>
            <cfelse>
              <cfset InsExpDateLive       = variables.responsestatus.CarrierDetails.CertData.Certificate.Coverage.expirationDate>
              <cfset ExpirationDate = "">
              <cfset CARGOExpirationDate =  "">
            </cfif> 
          <cfelseif structKeyExists(variables.responsestatus.CarrierDetails,"CertData") AND isStruct(variables.responsestatus.CarrierDetails.CertData) AND structKeyExists(variables.responsestatus.CarrierDetails.CertData,"Certificate")AND isArray(variables.responsestatus.CarrierDetails.CertData.Certificate) AND isStruct(variables.responsestatus.CarrierDetails.CertData.Certificate[1]) AND structKeyExists(variables.responsestatus.CarrierDetails.CertData.Certificate[1],"Coverage") AND isArray(variables.responsestatus.CarrierDetails.CertData.Certificate[1].Coverage)>
            <cfset InsExpDateLive = variables.responsestatus.CarrierDetails.CertData.Certificate[1].Coverage[1].expirationDate>
            <cfset ExpirationDate = variables.responsestatus.CarrierDetails.CertData.Certificate[1].Coverage[1].expirationDate>
            <cfloop from="1" to="#arrayLen(variables.responsestatus.CarrierDetails.CertData.Certificate[1].Coverage)#" index="i">
              <cfif variables.responsestatus.CarrierDetails.CertData.Certificate[1].Coverage[i].type CONTAINS "Cargo">
                 <cfset InsCompanyCargo = variables.responsestatus.CarrierDetails.CertData.Certificate[1].Coverage[i].insurerName>
                <cfset InsComPhoneCargo = InsAgentPhone>

                <cfif structKeyExists(variables.responsestatus.CarrierDetails.CertData.Certificate[1],"producerName")>
                  <cfset InsAgentCargo = variables.responsestatus.CarrierDetails.CertData.Certificate[1].producerName>
                </cfif>
                <cfif structKeyExists(variables.responsestatus.CarrierDetails.CertData.Certificate[1],"producerPhone")>
                  <cfset InsAgentPhoneCargo = variables.responsestatus.CarrierDetails.CertData.Certificate[1].producerPhone>
                </cfif>
                <cfset InsuranceCompanyAddressCargo= "">
                <cfif structKeyExists(variables.responsestatus.CarrierDetails.CertData.Certificate[1],"producerAddress") AND Len(variables.responsestatus.CarrierDetails.CertData.Certificate[1].producerAddress)>
                  <cfset InsuranceCompanyAddressCargo = variables.responsestatus.CarrierDetails.CertData.Certificate[1].producerAddress>
                </cfif>
                <cfif structKeyExists(variables.responsestatus.CarrierDetails.CertData.Certificate[1],"producerCity") AND Len(variables.responsestatus.CarrierDetails.CertData.Certificate[1].producerCity)>
                  <cfset InsuranceCompanyAddressCargo = InsuranceCompanyAddressCargo&','&variables.responsestatus.CarrierDetails.CertData.Certificate[1].producerCity>
                </cfif>
                <cfif structKeyExists(variables.responsestatus.CarrierDetails.CertData.Certificate[1],"producerState") AND Len(variables.responsestatus.CarrierDetails.CertData.Certificate[1].producerState)>
                  <cfset InsuranceCompanyAddressCargo = InsuranceCompanyAddressCargo&' '&variables.responsestatus.CarrierDetails.CertData.Certificate[1].producerState>
                </cfif>
                <cfif structKeyExists(variables.responsestatus.CarrierDetails.CertData.Certificate[1],"producerZip") AND Len(variables.responsestatus.CarrierDetails.CertData.Certificate[1].producerZip)>
                  <cfset InsuranceCompanyAddressCargo = InsuranceCompanyAddressCargo&','&variables.responsestatus.CarrierDetails.CertData.Certificate[1].producerZip>
                </cfif>
                <cfset InsPolicyNoCargo = variables.responsestatus.CarrierDetails.CertData.Certificate[1].Coverage[i].policyNumber>
                <cfset InsExpDateCargo =  variables.responsestatus.CarrierDetails.CertData.Certificate[1].Coverage[i].expirationDate> 
              <cfelseif variables.responsestatus.CarrierDetails.CertData.Certificate[1].Coverage[i].type CONTAINS "General">
                <cfif structKeyExists(variables.responsestatus.CarrierDetails.CertData.Certificate[1],"producerName")>
                  <cfset InsAgentGeneral = variables.responsestatus.CarrierDetails.CertData.Certificate[1].producerName>
                </cfif>
                <cfif structKeyExists(variables.responsestatus.CarrierDetails.CertData.Certificate[1],"producerPhone")>
                  <cfset InsAgentPhoneGeneral = variables.responsestatus.CarrierDetails.CertData.Certificate[1].producerPhone>
                </cfif>
                <cfset InsuranceCompanyAddressGeneral = "">
                <cfif structKeyExists(variables.responsestatus.CarrierDetails.CertData.Certificate[1],"producerAddress") AND Len(variables.responsestatus.CarrierDetails.CertData.Certificate[1].producerAddress)>
                  <cfset InsuranceCompanyAddressGeneral = variables.responsestatus.CarrierDetails.CertData.Certificate[1].producerAddress>
                </cfif>
                <cfif structKeyExists(variables.responsestatus.CarrierDetails.CertData.Certificate[1],"producerCity") AND Len(variables.responsestatus.CarrierDetails.CertData.Certificate[1].producerCity)>
                  <cfset InsuranceCompanyAddressGeneral = InsuranceCompanyAddressGeneral&','&variables.responsestatus.CarrierDetails.CertData.Certificate[1].producerCity>
                </cfif>
                <cfif structKeyExists(variables.responsestatus.CarrierDetails.CertData.Certificate[1],"producerState") AND Len(variables.responsestatus.CarrierDetails.CertData.Certificate[1].producerState)>
                  <cfset InsuranceCompanyAddressGeneral = InsuranceCompanyAddressGeneral&' '&variables.responsestatus.CarrierDetails.CertData.Certificate[1].producerState>
                </cfif>
                <cfif structKeyExists(variables.responsestatus.CarrierDetails.CertData.Certificate[1],"producerZip")AND Len(variables.responsestatus.CarrierDetails.CertData.Certificate[1].producerZip)>
                  <cfset InsuranceCompanyAddressGeneral = InsuranceCompanyAddressGeneral&','&variables.responsestatus.CarrierDetails.CertData.Certificate[1].producerZip>
                </cfif>
                <cfset InsPolicyNoGeneral = variables.responsestatus.CarrierDetails.CertData.Certificate[1].Coverage[i].policyNumber>
                <cfset InsExpDateGeneral = variables.responsestatus.CarrierDetails.CertData.Certificate[1].Coverage[i].expirationDate>
                <cfset InsLimitGeneral = variables.responsestatus.CarrierDetails.CertData.Certificate[1].Coverage[i].coverageLimit>
                <cfset InsCompanyGeneral = variables.responsestatus.CarrierDetails.CertData.Certificate[1].Coverage[i].insurerName>
                <cfset InsComPhoneGeneral = InsAgentPhone>
              </cfif>
            </cfloop>
          <cfelseif structKeyExists(variables.responsestatus.CarrierDetails,"CertData")  AND isStruct(variables.responsestatus.CarrierDetails.CertData) AND structKeyExists(variables.responsestatus.CarrierDetails.CertData,"Certificate") AND isArray(variables.responsestatus.CarrierDetails.CertData.Certificate)>
            <cfloop from="1" to="#arrayLen(variables.responsestatus.CarrierDetails.CertData.Certificate)#" index="i">
              <cfif structKeyExists(variables.responsestatus.CarrierDetails.CertData.Certificate[i],"Coverage") AND isStruct(variables.responsestatus.CarrierDetails.CertData.Certificate[i].Coverage) AND structKeyExists(variables.responsestatus.CarrierDetails.CertData.Certificate[i].Coverage,"type") AND variables.responsestatus.CarrierDetails.CertData.Certificate[i].Coverage.type CONTAINS "Cargo">
                <cfset InsCompanyCargo = variables.responsestatus.CarrierDetails.CertData.Certificate[i].Coverage.insurerName>
                <cfset InsComPhoneCargo = InsAgentPhone>
                <cfif structKeyExists(variables.responsestatus.CarrierDetails.CertData.Certificate[i],"producerName")>
                  <cfset InsAgentCargo = variables.responsestatus.CarrierDetails.CertData.Certificate[i].producerName>
                </cfif>
                <cfif structKeyExists(variables.responsestatus.CarrierDetails.CertData.Certificate[i],"producerPhone")>
                  <cfset InsAgentPhoneCargo = variables.responsestatus.CarrierDetails.CertData.Certificate[i].producerPhone>
                </cfif>
                <cfif structKeyExists(variables.responsestatus.CarrierDetails.CertData.Certificate[i],"producerAddress")>
                  <cfset InsuranceCompanyAddressCargo = variables.responsestatus.CarrierDetails.CertData.Certificate[i].producerAddress>
                </cfif>
                <cfif structKeyExists(variables.responsestatus.CarrierDetails.CertData.Certificate[i],"producerCity")>
                  <cfset InsuranceCompanyAddressCargo = InsuranceCompanyAddressCargo&','&variables.responsestatus.CarrierDetails.CertData.Certificate[i].producerCity>
                </cfif>
                <cfif structKeyExists(variables.responsestatus.CarrierDetails.CertData.Certificate[i],"producerState")>
                  <cfset InsuranceCompanyAddressCargo = InsuranceCompanyAddressCargo&' '&variables.responsestatus.CarrierDetails.CertData.Certificate[i].producerState>
                </cfif>
                <cfif structKeyExists(variables.responsestatus.CarrierDetails.CertData.Certificate[i],"producerZip")>
                  <cfset InsuranceCompanyAddressCargo = InsuranceCompanyAddressCargo&','&variables.responsestatus.CarrierDetails.CertData.Certificate[i].producerZip>
                </cfif>
                <cfset InsPolicyNoCargo = variables.responsestatus.CarrierDetails.CertData.Certificate[i].Coverage.policyNumber>
                <cfset InsExpDateCargo = variables.responsestatus.CarrierDetails.CertData.Certificate[i].Coverage.expirationDate>
                <cfset InsLimitCargo = variables.responsestatus.CarrierDetails.CertData.Certificate[i].Coverage.coverageLimit>
              </cfif>
            </cfloop>
          <cfelseif structKeyExists(variables.responsestatus.CarrierDetails,"CertData")  AND isStruct(variables.responsestatus.CarrierDetails.CertData) AND structKeyExists(variables.responsestatus.CarrierDetails.CertData,"Certificate")AND isStruct(variables.responsestatus.CarrierDetails.CertData.Certificate) AND structKeyExists(variables.responsestatus.CarrierDetails.CertData.Certificate,"Coverage") AND isArray(variables.responsestatus.CarrierDetails.CertData.Certificate.Coverage)>
            <cfset InsExpDateLive = variables.responsestatus.CarrierDetails.CertData.Certificate.Coverage[1].expirationDate>
            <cfif structKeyExists(variables.responsestatus.CarrierDetails.CertData.Certificate,"producerEmail")>
              <cfset InsEmail = variables.responsestatus.CarrierDetails.CertData.Certificate.producerEmail>
              <cfset InsEmailCargo = variables.responsestatus.CarrierDetails.CertData.Certificate.producerEmail>
              <cfset InsEmailGeneral = variables.responsestatus.CarrierDetails.CertData.Certificate.producerEmail>
            </cfif>
            <cfloop from="1" to="#arrayLen(variables.responsestatus.CarrierDetails.CertData.Certificate.Coverage)#" index="i">
              <cfif variables.responsestatus.CarrierDetails.CertData.Certificate.Coverage[i].type CONTAINS "Cargo">
                <cfset InsCompanyCargo = variables.responsestatus.CarrierDetails.CertData.Certificate.Coverage[i].insurerName>
                <cfset InsComPhoneCargo = InsAgentPhone>
                <cfif structKeyExists(variables.responsestatus.CarrierDetails.CertData.Certificate,"producerName")>
                  <cfset InsAgentCargo = variables.responsestatus.CarrierDetails.CertData.Certificate.producerName>
                </cfif>
                <cfif structKeyExists(variables.responsestatus.CarrierDetails.CertData.Certificate,"producerPhone")>
                  <cfset InsAgentPhoneCargo = variables.responsestatus.CarrierDetails.CertData.Certificate.producerPhone>
                </cfif>
                <cfif structKeyExists(variables.responsestatus.CarrierDetails.CertData.Certificate,"producerAddress")>
                  <cfset InsuranceCompanyAddressCargo = variables.responsestatus.CarrierDetails.CertData.Certificate.producerAddress>
                </cfif>
                <cfif structKeyExists(variables.responsestatus.CarrierDetails.CertData.Certificate,"producerCity")>
                  <cfset InsuranceCompanyAddressCargo = InsuranceCompanyAddressCargo&','&variables.responsestatus.CarrierDetails.CertData.Certificate.producerCity>
                </cfif>
                <cfif structKeyExists(variables.responsestatus.CarrierDetails.CertData.Certificate,"producerState")>
                  <cfset InsuranceCompanyAddressCargo = InsuranceCompanyAddressCargo&' '&variables.responsestatus.CarrierDetails.CertData.Certificate.producerState>
                </cfif>
                <cfif structKeyExists(variables.responsestatus.CarrierDetails.CertData.Certificate,"producerZip")>
                  <cfset InsuranceCompanyAddressCargo = InsuranceCompanyAddressCargo&','&variables.responsestatus.CarrierDetails.CertData.Certificate.producerZip>
                </cfif>
                <cfset InsPolicyNoCargo = variables.responsestatus.CarrierDetails.CertData.Certificate.Coverage[i].policyNumber>
                <cfset InsExpDateCargo = variables.responsestatus.CarrierDetails.CertData.Certificate.Coverage[i].expirationDate>
                <cfset InsLimitCargo = variables.responsestatus.CarrierDetails.CertData.Certificate.Coverage[i].coverageLimit>
              <cfelseif variables.responsestatus.CarrierDetails.CertData.Certificate.Coverage[i].type CONTAINS "General">
                <cfif structKeyExists(variables.responsestatus.CarrierDetails.CertData.Certificate,"producerName")>
                  <cfset InsAgentGeneral = variables.responsestatus.CarrierDetails.CertData.Certificate.producerName>
                </cfif>
                <cfif structKeyExists(variables.responsestatus.CarrierDetails.CertData.Certificate,"producerPhone")>
                  <cfset InsAgentPhoneGeneral = variables.responsestatus.CarrierDetails.CertData.Certificate.producerPhone>
                </cfif>
                <cfif structKeyExists(variables.responsestatus.CarrierDetails.CertData.Certificate,"producerAddress")>
                  <cfset InsuranceCompanyAddressGeneral = variables.responsestatus.CarrierDetails.CertData.Certificate.producerAddress>
                </cfif>
                <cfif structKeyExists(variables.responsestatus.CarrierDetails.CertData.Certificate,"producerCity")>
                  <cfset InsuranceCompanyAddressGeneral = InsuranceCompanyAddressGeneral&','&variables.responsestatus.CarrierDetails.CertData.Certificate.producerCity>
                </cfif>
                <cfif structKeyExists(variables.responsestatus.CarrierDetails.CertData.Certificate,"producerState")>
                  <cfset InsuranceCompanyAddressGeneral = InsuranceCompanyAddressGeneral&' '&variables.responsestatus.CarrierDetails.CertData.Certificate.producerState>
                </cfif>
                <cfif structKeyExists(variables.responsestatus.CarrierDetails.CertData.Certificate,"producerZip")>
                  <cfset InsuranceCompanyAddressGeneral = InsuranceCompanyAddressGeneral&','&variables.responsestatus.CarrierDetails.CertData.Certificate.producerZip>
                </cfif>
                <cfset InsPolicyNoGeneral = variables.responsestatus.CarrierDetails.CertData.Certificate.Coverage[i].policyNumber>
                <cfset InsExpDateGeneral = variables.responsestatus.CarrierDetails.CertData.Certificate.Coverage[i].expirationDate>
                <cfset InsLimitGeneral = variables.responsestatus.CarrierDetails.CertData.Certificate.Coverage[i].coverageLimit>
                <cfset InsCompanyGeneral = variables.responsestatus.CarrierDetails.CertData.Certificate.Coverage[i].insurerName>
                <cfset InsComPhoneGeneral = InsAgentPhone>
              </cfif>
            </cfloop>
          </cfif>
          <cfquery name="qupdCarr" datasource="#Application.dsn#">
            UPDATE Carriers SET 
            InsCompany = <cfqueryparam cfsqltype="cf_sql_varchar" value="#insCarrier#"> 
            ,InsCompPhone = <cfqueryparam cfsqltype="cf_sql_varchar" value="#InsAgentPhone#"> 
            ,InsAgent = <cfqueryparam cfsqltype="cf_sql_varchar" value="#insAgentName#">
            ,InsAgentPhone = <cfqueryparam cfsqltype="cf_sql_varchar" value="#InsAgentPhone#"> 
            ,InsEmail = <cfqueryparam cfsqltype="cf_sql_varchar" value="#InsEmail#">
            ,InsPolicyNumber = <cfqueryparam cfsqltype="cf_sql_varchar" value="#insPolicy#">
            ,InsExpDate = <cfqueryparam cfsqltype="cf_sql_date" value="#InsExpDateLive#">
            ,InsLimit = <cfqueryparam cfsqltype="cf_sql_real" value="#replaceNoCase(replaceNoCase(bipd_Insurance_on_file,'$',''),',','','ALL')#">

            ,InsCompanyCargo = <cfqueryparam cfsqltype="cf_sql_varchar" value="#InsCompanyCargo#"> 
            ,InsCompPhoneCargo = <cfqueryparam cfsqltype="cf_sql_varchar" value="#InsComPhoneCargo#"> 
            ,InsAgentCargo = <cfqueryparam cfsqltype="cf_sql_varchar" value="#InsAgentCargo#">
            ,InsAgentPhoneCargo = <cfqueryparam cfsqltype="cf_sql_varchar" value="#InsAgentPhoneCargo#"> 
            ,InsEmailCargo = <cfqueryparam cfsqltype="cf_sql_varchar" value="#InsEmailCargo#">
            ,InsPolicyNumberCargo = <cfqueryparam cfsqltype="cf_sql_varchar" value="#InsPolicyNoCargo#">
            ,InsExpDateCargo = <cfqueryparam cfsqltype="cf_sql_date" value="#InsExpDateCargo#">
            ,InsLimitCargo = <cfqueryparam cfsqltype="cf_sql_real" value="#replaceNoCase(replaceNoCase(InsLimitCargo,'$',''),',','','ALL')#">

            ,InsCompanyGeneral = <cfqueryparam cfsqltype="cf_sql_varchar" value="#InsCompanyGeneral#"> 
            ,InsCompPhoneGeneral = <cfqueryparam cfsqltype="cf_sql_varchar" value="#InsComPhoneGeneral#"> 
            ,InsAgentGeneral = <cfqueryparam cfsqltype="cf_sql_varchar" value="#InsAgentGeneral#">
            ,InsAgentPhoneGeneral = <cfqueryparam cfsqltype="cf_sql_varchar" value="#InsAgentPhoneGeneral#"> 
            ,InsEmailGeneral = <cfqueryparam cfsqltype="cf_sql_varchar" value="#InsEmailGeneral#">
            ,InsPolicyNumberGeneral = <cfqueryparam cfsqltype="cf_sql_varchar" value="#InsPolicyNoGeneral#">
            ,InsExpDateGeneral = <cfqueryparam cfsqltype="cf_sql_date" value="#InsExpDateGeneral#">
            ,InsLimitGeneral = <cfqueryparam cfsqltype="cf_sql_real" value="#replaceNoCase(replaceNoCase(InsLimitGeneral,'$',''),',','','ALL')#">
            WHERE CarrierID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#Carrier["CarrierID"]#">
          </cfquery>

          <cfquery name="qupdIns" datasource="#Application.dsn#">
            INSERT INTO lipublicfmcsa (CarrierID,DateCreated,InsuranceCompanyAddress,InsuranceCompanyAddressCargo,InsuranceCompanyAddressGeneral,commonStatus,contractStatus,brokerStatus,commonAppPending,contractAppPending,BrokerAppPending,BIPDInsRequired,cargoInsRequired,BIPDInsonFile,cargoInsonFile,householdGoods)
            VALUES(
              <cfqueryparam cfsqltype="cf_sql_varchar" value="#Carrier["CarrierID"]#"> 
              ,getdate()
              ,<cfqueryparam cfsqltype="cf_sql_varchar" value="#formatRequired#"> 
              ,<cfqueryparam cfsqltype="cf_sql_varchar" value="#InsuranceCompanyAddressCargo#"> 
              ,<cfqueryparam cfsqltype="cf_sql_varchar" value="#InsuranceCompanyAddressGeneral#"> 
              ,0,0,0,0,0,0,0,0,0,0,1
              )
          </cfquery>
        </cftransaction>
        <cfreturn Carrier["CarrierID"]>
      <cfelse>
        <cfreturn ''>
      </cfif>
      <cfcatch>
        <cfreturn ''>
      </cfcatch>
    </cftry>
  </cffunction>

  <cffunction name="createViaCarrierLookout" access="public" output="false" returntype="string">
    <cfargument name="DotNumber" type="string" required="false" default="">
    <cfargument name="MCNumber" type="string" required="false" default="">
    <cfargument name="CompanyID" type="string" required="no" default=""/>
    <cftry>
      <cfif structKeyExists(arguments, "CompanyID") AND len(trim(arguments.CompanyID))>
        <cfset var local.CompanyID = arguments.CompanyID>
      <cfelse>
        <cfset var local.CompanyID = session.CompanyID>
      </cfif>
      <cfquery name="qSystemSetupOptions" datasource="#Application.dsn#">
        SELECT S.CarrierLookoutAPIKey,SO.KeepCarrierInactive
        FROM SystemConfig S
        INNER JOIN SystemConfigOnboardCarrier SO ON SO.CompanyID = S.CompanyID
        WHERE S.CompanyID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#local.companyid#">
      </cfquery>  

      <cfif len(trim(arguments.dotnumber))>
        <cfset DOT_Number = trim(arguments.dotnumber)>

        <cfhttp url="https://api.carriersoftware.com/api/DOT/#DOT_Number#" method="get" result="objCarrierInsuranceDot" timeout="300">
          <cfhttpparam type="header" name="API_KEY" value="#trim(qSystemSetupOptions.CarrierLookoutAPIKey)#"/>
        </cfhttp>
        <cfif objCarrierInsuranceDot.Filecontent EQ "null" OR objCarrierInsuranceDot.Statuscode EQ "404 Not Found" OR objCarrierInsuranceDot.Statuscode EQ "400 Bad request"><cfreturn 0></cfif>
      <cfelseif len(trim(arguments.MCNumber))>
        <cfset MC_Number = trim(arguments.MCNumber)>
        <cfset MC_Number = replaceNoCase(MC_Number, " ", "","ALL")>
        <cfset MC_Number = replaceNoCase(MC_Number, "MC", "")>
        <cfset MC_Number = replaceNoCase(MC_Number, "-", "")>
        <cfset MC_Number = replaceNoCase(MC_Number, "##", "")>
        <cfset MC_Number = REReplace(MC_Number,"^0+","")>
        <cfset MC_Number = "MC"&trim(MC_Number)>
        <cfhttp url="https://api.carriersoftware.com/api/DOTByMC/#MC_Number#" method="get" result="objCarrierInsuranceDot" timeout="300">
          <cfhttpparam type="header" name="API_KEY" value="#trim(qSystemSetupOptions.CarrierLookoutAPIKey)#"/>
        </cfhttp>
        
        <cfif objCarrierInsuranceDot.Filecontent EQ "null" OR objCarrierInsuranceDot.Statuscode EQ "404 Not Found" OR objCarrierInsuranceDot.Statuscode EQ "400 Bad request" OR objCarrierInsuranceDot.Statuscode CONTAINS "Connection Failure."><cfreturn 0></cfif>
        <cfset DOT_Number = DeserializeJSON(objCarrierInsuranceDot.Filecontent).DotNumber>
      </cfif>

      <cfhttp url="https://api.carriersoftware.com/api/CarrierInsurance?dot=#DOT_Number#" method="get"  throwonerror = Yes result="objCarrierInsurance" timeout="300">
        <cfhttpparam type="header" name="API_KEY" value="#trim(qSystemSetupOptions.CarrierLookoutAPIKey)#"/>
      </cfhttp>

      <cfhttp url="https://api.carriersoftware.com/api/BasicISS?dot=#DOT_Number#" method="get"  throwonerror = Yes result="objBasicISS">
        <cfhttpparam type="header" name="API_KEY" value="#qSystemSetupOptions.CarrierLookoutAPIKey#"/>
      </cfhttp>
      <cfif objBasicISS.Statuscode EQ '200 OK'>
          <cfset var BasicISS = DeserializeJSON(objBasicISS.Filecontent)>
          <cfif BasicISS.Total NEQ 0 AND NOT arrayIsEmpty(BasicISS.results)>
              <cfset var BasicISS = BasicISS.results[BasicISS.Total]>
          <cfelse>
              <cfset var BasicISS = structNew()>
          </cfif>
      </cfif>

      <cfif objCarrierInsurance.Statuscode EQ '200 OK'>
        <cfset var CarrierInsurance = DeserializeJSON(objCarrierInsurance.Filecontent)>
        <cfset var CarrierInsuranceDOT = DeserializeJSON(objCarrierInsuranceDot.Filecontent)>

        <cfif not ArrayIsEmpty(CarrierInsurance.CarrierDockets)>
          <cfif structkeyexists(arguments,"MCNumber") AND Len(trim(arguments.MCNumber)) AND arrayLen(CarrierInsurance.CarrierDockets) GT 1>
            <cfset var tempArr = arrayNew(1)>

            <cfloop from="1" to="#arrayLen(CarrierInsurance.CarrierDockets)#" index="i">
              <cfif listFindNoCase("MC#trim(arguments.MCNumber)#,MC0#trim(arguments.MCNumber)#", CarrierInsurance.CarrierDockets[i].DocketNo)>
                <cfset arrayAppend(tempArr, CarrierInsurance.CarrierDockets[i])>
              </cfif>
            </cfloop>
            <cfset CarrierInsurance.CarrierDockets = tempArr>
          </cfif>

          <cfif arrayLen(CarrierInsurance.CarrierDockets) GT 1>
            <cfset session.CreateViaCLError = "This DOT number is related to multiple MC numbers. Please use the MC## in order to add the correct carrier.">
            <cfreturn 0>
          </cfif>
          <cfset var Carrier = structNew()>
          <cfquery name="qGetcarrierID" datasource="#Application.dsn#">
            SELECT NewID() as CarrierID
          </cfquery>
          <cfset Carrier["CarrierID"] = qGetcarrierID.CarrierID>
          <cfset Carrier["CarrierName"] = CarrierInsurance.CarrierDockets[1].LegalName>
          <cfset Carrier["VendorID"] = Left(ReplaceNoCase(CarrierInsurance.CarrierDockets[1].LegalName," ","","ALL"),10)>
          <cfif not isdefined("MC_Number")>
            <cfset MC_Number = replaceNoCase(CarrierInsurance.CarrierDockets[1].DocketNo, "MC", "")>
          </cfif>
          <cfset Carrier["MCNumber"] = replaceNoCase(MC_Number, "MC", "")>
          <cfset Carrier["DOTNumber"] = DOT_Number>
          <cfif structKeyExists(CarrierInsurance.CarrierDockets[1], "Address")>
            <cfset Carrier["Address"] = CarrierInsurance.CarrierDockets[1].Address>
          <cfelse>
            <cfset Carrier["Address"] = "">
          </cfif>
          <cfif structKeyExists(CarrierInsurance.CarrierDockets[1], "City")>
            <cfset Carrier["City"] = CarrierInsurance.CarrierDockets[1].City>
          <cfelse>
            <cfset Carrier["City"] = "">  
          </cfif>
          <cfif structKeyExists(CarrierInsurance.CarrierDockets[1], "State")>
            <cfset Carrier["State"] = CarrierInsurance.CarrierDockets[1].State>
          <cfelse>
            <cfset Carrier["State"] = "">
          </cfif>
          <cfif structKeyExists(CarrierInsurance.CarrierDockets[1], "Zip")>
            <cfset Carrier["Zip"] = CarrierInsurance.CarrierDockets[1].Zip>
          <cfelse>
            <cfset Carrier["Zip"] = "">
          </cfif>
          <cfif structKeyExists(CarrierInsurance.CarrierDockets[1], "Country")>
            <cfset Carrier["Country"] = CarrierInsurance.CarrierDockets[1].Country>
          <cfelse>
            <cfset Carrier["Country"] = "">
          </cfif>
          <cfif structKeyExists(CarrierInsurance.CarrierDockets[1], "Phone")>
            <cfset Carrier["Phone"] = formatPhoneNumber(CarrierInsurance.CarrierDockets[1].Phone)>
          <cfelse>
            <cfset Carrier["Phone"] = "">
          </cfif>
          <cfif structKeyExists(CarrierInsuranceDOT, "FaxNumber")>
            <cfset Carrier["Fax"] = formatPhoneNumber(CarrierInsuranceDOT.FaxNumber)>
          <cfelseif structKeyExists(CarrierInsurance.CarrierDockets[1], "Fax")>
            <cfset Carrier["Fax"] = formatPhoneNumber(CarrierInsurance.CarrierDockets[1].Fax)>
          <cfelse>
            <cfset Carrier["Fax"] = "">
          </cfif>
          <cfif structKeyExists(CarrierInsurance.CarrierDockets[1], "MailPhone")>
            <cfset Carrier["MailPhone"] = CarrierInsurance.CarrierDockets[1].MailPhone>
          <cfelse>
            <cfset Carrier["MailPhone"] = "">
          </cfif>
          <cfif structKeyExists(CarrierInsurance.CarrierDockets[1], "MailFax")>
            <cfset Carrier["MailFax"] = CarrierInsurance.CarrierDockets[1].MailFax>
          <cfelse>
            <cfset Carrier["MailFax"] = "">
          </cfif>
          <cfif structKeyExists(CarrierInsuranceDOT, "CellPhone")>
            <cfset Carrier["Cel"] = formatPhoneNumber(CarrierInsuranceDOT.CellPhone)>
          <cfelse>
            <cfset Carrier["Cel"] = "">
          </cfif>
          <cfif structKeyExists(CarrierInsuranceDOT, "EmailAddress")>
            <cfset Carrier["EmailID"] = CarrierInsuranceDOT.EmailAddress>
          <cfelse>
            <cfset Carrier["EmailID"] = "">
          </cfif>

          <cfif structKeyExists(CarrierInsuranceDOT, "CompanyRep1")>
            <cfset Carrier["ContactPerson"] = CarrierInsuranceDOT.CompanyRep1>
          <cfelseif structKeyExists(CarrierInsuranceDOT, "CompanyRep2")>
            <cfset Carrier["ContactPerson"] = CarrierInsuranceDOT.CompanyRep2>
          <cfelse>
            <cfset Carrier["ContactPerson"] = "">
          </cfif>
          <cftransaction>
            <cfquery name="qInsCarrier" datasource="#Application.dsn#">
                INSERT INTO Carriers(CarrierID,CompanyID,CarrierName,MCNumber,DotNumber,Address,City,stateCode,ZipCode,country,phone,fax,CreatedBy,LastModifiedBy,CreatedDateTime,LastModifiedDateTime,IsInsVerified,IsInsDate,IsContractVerified,IsW9,IsReferences,Status,Track1099,VendorID,IsCarrier,Cel,EmailID,ContactPerson
                  )
                VALUES(
                  <cfqueryparam cfsqltype="cf_sql_varchar" value="#Carrier["CarrierID"]#">,
                  <cfqueryparam cfsqltype="cf_sql_varchar" value="#local.companyid#">,
                  <cfqueryparam cfsqltype="cf_sql_varchar" value="#Carrier["CarrierName"]#">,
                  <cfqueryparam cfsqltype="cf_sql_varchar" value="#Carrier["MCNumber"]#">,
                  <cfqueryparam cfsqltype="cf_sql_varchar" value="#Carrier["DOTNumber"]#">,
                  <cfqueryparam cfsqltype="cf_sql_varchar" value="#Carrier["Address"]#" null="#not len(Carrier["Address"])#">,
                  <cfqueryparam cfsqltype="cf_sql_varchar" value="#Carrier["City"]#" null="#not len(Carrier["City"])#">,
                  <cfqueryparam cfsqltype="cf_sql_varchar" value="#Carrier["State"]#" null="#not len(Carrier["State"])#">,
                  <cfqueryparam cfsqltype="cf_sql_varchar" value="#Carrier["Zip"]#" null="#not len(Carrier["Zip"])#">,
                  <cfqueryparam cfsqltype="cf_sql_varchar" value="#Carrier["Country"]#" null="#not len(Carrier["Country"])#">,
                  <cfqueryparam cfsqltype="cf_sql_varchar" value="#Carrier["Phone"]#" null="#not len(Carrier["Phone"])#">,
                  <cfqueryparam cfsqltype="cf_sql_varchar" value="#Carrier["Fax"]#" null="#not len(Carrier["Fax"])#">,
                  <cfif structKeyExists(session, "adminusername")>
                    <cfqueryparam cfsqltype="cf_sql_varchar" value="#session.adminusername#">,
                    <cfqueryparam cfsqltype="cf_sql_varchar" value="#session.adminusername#">,
                  <cfelse>
                    'Onboard',
                    'Onboard',
                  </cfif>
                  GETDATE(),GETDATE(),
                  0,0,0,0,0,
                  <cfif qSystemSetupOptions.KeepCarrierInactive EQ 1>0<cfelse>1</cfif>,
                  1,
                  <cfqueryparam cfsqltype="cf_sql_varchar" value="#Carrier["VendorID"]#">,
                  1,
                  <cfqueryparam cfsqltype="cf_sql_varchar" value="#Carrier["Cel"]#" null="#not len(Carrier["Cel"])#">,
                  <cfqueryparam cfsqltype="cf_sql_varchar" value="#Carrier["EmailID"]#" null="#not len(Carrier["EmailID"])#">,
                  <cfqueryparam cfsqltype="cf_sql_varchar" value="#Carrier["ContactPerson"]#" null="#not len(Carrier["ContactPerson"])#">
                )
            </cfquery>

            <cfif len(trim(Carrier["MailPhone"])) OR len(trim(Carrier["MailFax"]))>
              <cfquery name="qInsCarrierContact" datasource="#Application.dsn#">
                INSERT INTO CarrierContacts (CarrierContactID,CarrierID,PhoneNo,Fax,ContactType)
                  VALUES(
                    NewID(),
                    <cfqueryparam cfsqltype="cf_sql_varchar" value="#Carrier["CarrierID"]#">,
                    <cfqueryparam cfsqltype="cf_sql_varchar" value="#Carrier["MailPhone"]#">,
                    <cfqueryparam cfsqltype="cf_sql_varchar" value="#Carrier["MailFax"]#">,
                    'General'
                    )
              </cfquery>
            </cfif>

            <cfquery name="qInsCarrierLanes" datasource="#Application.dsn#">
              INSERT INTO CarrierLanes (
              CarrierLaneID,
              CarrierID,
              PickUpCity,
              PickUpState,
              PickUpZip,
              DeliveryCity,
              DeliveryState,
              DeliveryZip,
              Cost,
              Miles,
              RatePerMile,
              IntransitStops,
              CreatedBy,
              ModifiedBy
              ) 
            VALUES(
              NEWID(),
              <cfqueryparam cfsqltype="cf_sql_varchar" value="#Carrier["CarrierID"]#">,
              <cfqueryparam cfsqltype="cf_sql_varchar" value="#Carrier["City"]#" null="#not len(Carrier["City"])#">,
              <cfqueryparam cfsqltype="cf_sql_varchar" value="#Carrier["State"]#" null="#not len(Carrier["State"])#">,
              <cfqueryparam cfsqltype="cf_sql_varchar" value="#Carrier["Zip"]#" null="#not len(Carrier["Zip"])#">,
              <cfqueryparam cfsqltype="cf_sql_varchar" value="#Carrier["City"]#" null="#not len(Carrier["City"])#">,
              <cfqueryparam cfsqltype="cf_sql_varchar" value="#Carrier["State"]#" null="#not len(Carrier["State"])#">,
              <cfqueryparam cfsqltype="cf_sql_varchar" value="#Carrier["Zip"]#" null="#not len(Carrier["Zip"])#">,
              0,
              0,
              0,
              0,
              <cfif structKeyExists(session, "adminusername")>
                <cfqueryparam cfsqltype="cf_sql_varchar" value="#session.adminusername#">,
                <cfqueryparam cfsqltype="cf_sql_varchar" value="#session.adminusername#">
              <cfelse>
                'Onboard',
                'Onboard'
              </cfif>
              )
            </cfquery>
            <cfset var BIPDExists = 0>
            <cfset var BIPDExpired = 0>
            <cfloop array="#CarrierInsurance.CarrierDockets[1].Insurances#" index="Insurance">
              <cfset var CarrierInsuranceInfo= structNew()>
              <cfset CarrierInsuranceInfo["DocketNo"] = CarrierInsurance.CarrierDockets[1].DocketNo>
              <cfif structkeyexists(Insurance,"FormCode")>
                <cfset CarrierInsuranceInfo["Form"] = Insurance.FormCode>
              <cfelse>
                <cfset CarrierInsuranceInfo["Form"] = "">
              </cfif>
              <cfset CarrierInsuranceInfo["Type"] = Insurance.InsType>
              <cfset CarrierInsuranceInfo["InsuranceCarrier"] = Insurance.InsCarrier>
              <cfif structKeyExists(Insurance, "PolicyNo")>
                <cfset CarrierInsuranceInfo["PolicyNo"] = Insurance.PolicyNo>
              <cfelse>
                <cfset CarrierInsuranceInfo["PolicyNo"] = "">
              </cfif>
              <cfif structKeyExists(Insurance, "PolicyNo")>
                <cfset CarrierInsuranceInfo["CoveredTo"] = DollarFormat(Insurance.BiPdMaxLim*1000)>
              <cfelse>
                <cfset CarrierInsuranceInfo["CoveredTo"] = DollarFormat(0)>
              </cfif>
              <cfif Insurance.InsType EQ 1>
                  <cfif structkeyexists(CarrierInsurance.CarrierDockets[1],"BiPdReq")>
                    <cfset CarrierInsuranceInfo["Req"] = DollarFormat(CarrierInsurance.CarrierDockets[1].BiPdReq*1000)>
                  <cfelse>
                    <cfset CarrierInsuranceInfo["Req"] = "">
                  </cfif>
              <cfelse>
                  <cfif structkeyexists(CarrierInsurance.CarrierDockets[1],"CargoReq")>
                    <cfset CarrierInsuranceInfo["Req"] = CarrierInsurance.CarrierDockets[1].CargoReq>
                  <cfelse>
                    <cfset CarrierInsuranceInfo["Req"] = "">
                  </cfif>
              </cfif>
              <cfif Insurance.InsType EQ 1>
                  <cfif structkeyexists(CarrierInsurance.CarrierDockets[1],"BiPdOnFile")>
                    <cfset CarrierInsuranceInfo["OnFile"] = DollarFormat(CarrierInsurance.CarrierDockets[1].BiPdOnFile*1000)>
                  <cfelse>
                    <cfset CarrierInsuranceInfo["OnFile"] = "">
                  </cfif>
              <cfelse>
                  <cfif structkeyexists(CarrierInsurance.CarrierDockets[1],"CargoOnFile")>
                    <cfset CarrierInsuranceInfo["OnFile"] = CarrierInsurance.CarrierDockets[1].CargoOnFile>
                  <cfelse>
                    <cfset CarrierInsuranceInfo["OnFile"] = "">
                  </cfif>
              </cfif>
              <cfset Insurance.InsExpDate =  DateFormat(DateAdd('yyyy',1,Insurance.InsEffDate),'yyyy-mm-dd')>
              <cfif DateCompare(Insurance.InsExpDate,DateFormat(now(),'yyyy-mm-dd')) EQ 1><!--- Expiry Date In Future --->
                <cfset CarrierInsuranceInfo["EffectiveDate"] = DateFormat(Insurance.InsEffDate,"mm/dd/yyyy")>
                <cfset CarrierInsuranceInfo["ExpirationDate"] = DateFormat(Insurance.InsExpDate,"mm/dd/yyyy")>
              <cfelse><!--- Expiry Date In Past --->
                <cfset InsEffYearDiff = DateDiff("yyyy",Insurance.InsEffDate,DateFormat(now(),'yyyy-mm-dd'))>
                <cfset InsExpYearDiff = DateDiff("yyyy",Insurance.InsExpDate,DateFormat(now(),'yyyy-mm-dd'))>
                <cfset CarrierInsuranceInfo["EffectiveDate"] = DateFormat(dateAdd("yyyy", InsEffYearDiff, Insurance.InsEffDate),"mm/dd/yyyy")>
                <cfset CarrierInsuranceInfo["ExpirationDate"] = DateFormat(dateAdd("yyyy", InsExpYearDiff+1, Insurance.InsExpDate),"mm/dd/yyyy")>
              </cfif>
              <cfif structkeyexists(Insurance,"BiPdClass")>
                <cfset CarrierInsuranceInfo["BiPdClass"] = Insurance.BiPdClass>
              <cfelse>
                <cfset CarrierInsuranceInfo["BiPdClass"] = "">
              </cfif>
              <cfif Insurance.InsType EQ 1>
                <cfquery name="qupdCarr" datasource="#Application.dsn#">
                  UPDATE Carriers SET 
                  InsCompany = <cfqueryparam cfsqltype="cf_sql_varchar" value="#CarrierInsuranceInfo["InsuranceCarrier"]#"> 
                  ,InsPolicyNumber = <cfqueryparam cfsqltype="cf_sql_varchar" value="#CarrierInsuranceInfo["PolicyNo"]#">
                  ,InsExpDate = <cfqueryparam cfsqltype="cf_sql_date" value="#CarrierInsuranceInfo["ExpirationDate"]#">
                  ,InsLimit = <cfqueryparam cfsqltype="cf_sql_real" value="#replaceNoCase(replaceNoCase(CarrierInsuranceInfo["CoveredTo"],'$',''),',','','ALL')#">
                  WHERE CarrierID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#Carrier["CarrierID"]#">
                </cfquery>
              <cfelse>
                <cfquery name="qupdCarr" datasource="#Application.dsn#">
                  UPDATE Carriers SET 
                  InsCompanyCargo = <cfqueryparam cfsqltype="cf_sql_varchar" value="#CarrierInsuranceInfo["InsuranceCarrier"]#"> 
                  ,InsPolicyNumberCargo = <cfqueryparam cfsqltype="cf_sql_varchar" value="#CarrierInsuranceInfo["PolicyNo"]#">
                  ,InsExpDateCargo = <cfqueryparam cfsqltype="cf_sql_date" value="#CarrierInsuranceInfo["ExpirationDate"]#">
                  ,InsLimitCargo = <cfqueryparam cfsqltype="cf_sql_real" value="#replaceNoCase(replaceNoCase(CarrierInsuranceInfo["CoveredTo"],'$',''),',','','ALL')#">
                  WHERE CarrierID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#Carrier["CarrierID"]#">
                </cfquery>
              </cfif>
              <cfquery name="qInsCarrierInsurance" datasource="#Application.dsn#">
                INSERT INTO [dbo].[CLActivePendingInsurance]
                 ([ID]
                 ,[CarrierID]
                 ,[CreatedBy]
                 ,[DocketNo]
                 ,[Form]
                 ,[Type]
                 ,[InsuranceCarrier]
                 ,[PolicyNo]
                 ,[CoveredTo]
                 ,[Req]
                 ,[OnFile]
                 ,[EffectiveDate]
                 ,[ExpirationDate]
                 ,[ISFromAPI]
                 ,[BiPdClass])
                VALUES(
                  NEWID(),
                  <cfqueryparam cfsqltype="cf_sql_varchar" value="#Carrier["CarrierID"]#">,
                  <cfif structKeyExists(session, "adminusername")>
                    <cfqueryparam cfsqltype="cf_sql_varchar" value="#session.adminusername#">,
                  <cfelse>
                    'Onboard',
                  </cfif>
                  <cfqueryparam cfsqltype="cf_sql_varchar" value="#CarrierInsuranceInfo["DocketNo"]#">,
                  <cfqueryparam cfsqltype="cf_sql_varchar" value="#CarrierInsuranceInfo["Form"]#" null="#not len(CarrierInsuranceInfo["Form"])#">,
                  <cfqueryparam cfsqltype="cf_sql_integer" value="#CarrierInsuranceInfo["Type"]#">,
                  <cfqueryparam cfsqltype="cf_sql_varchar" value="#CarrierInsuranceInfo["InsuranceCarrier"]#">,
                  <cfqueryparam cfsqltype="cf_sql_varchar" value="#CarrierInsuranceInfo["PolicyNo"]#">,
                  <cfqueryparam cfsqltype="cf_sql_varchar" value="#CarrierInsuranceInfo["CoveredTo"]#">,
                  <cfqueryparam cfsqltype="cf_sql_varchar" value="#CarrierInsuranceInfo["Req"]#" null="#not len(CarrierInsuranceInfo["Req"])#">,
                  <cfqueryparam cfsqltype="cf_sql_varchar" value="#CarrierInsuranceInfo["OnFile"]#" null="#not len(CarrierInsuranceInfo["OnFile"])#">,
                  <cfqueryparam cfsqltype="cf_sql_date" value="#CarrierInsuranceInfo["EffectiveDate"]#">,
                  <cfqueryparam cfsqltype="cf_sql_date" value="#CarrierInsuranceInfo["ExpirationDate"]#">,
                  1,
                  <cfqueryparam cfsqltype="cf_sql_varchar" value="#CarrierInsuranceInfo["BiPdClass"]#" null="#not len(CarrierInsuranceInfo["BiPdClass"])#">

                  )
              </cfquery>
              <cfif CarrierInsuranceInfo["Type"] EQ 1 AND CarrierInsuranceInfo["BiPdClass"] EQ 'P'>
                <cfset BIPDExists = 1>
                <cfif DateDiff("d", CarrierInsuranceInfo["ExpirationDate"], now()) GT 0>
                  <cfset BIPDExpired = 1>
                </cfif>
              </cfif>
            </cfloop>
            <cfset Carrier["risk_assessment"] = "">
            <cfif NOT BIPDExists OR (BIPDExists AND BIPDExpired)>
              <cfset Carrier["risk_assessment"] = "Unacceptable">
            <cfelseif BIPDExists AND NOT BIPDExpired AND NOT StructIsEmpty(BasicISS) AND (BasicISS.UnsafeDriveBasicAlert EQ 'Y' OR BasicISS.HOSBasicAlert EQ 'Y' OR BasicISS.DrivFitBasicAlert EQ 'Y' OR BasicISS.ContrSubstBasicAlert EQ 'Y' OR BasicISS.VehMaintBasicAlert EQ 'Y' OR BasicISS.CrashBasicAlert EQ 'Y')>
              <cfset Carrier["risk_assessment"] = "Moderate">
            <cfelseif BIPDExists AND NOT BIPDExpired AND NOT StructIsEmpty(BasicISS) AND BasicISS.UnsafeDriveBasicAlert NEQ 'Y' AND BasicISS.HOSBasicAlert NEQ 'Y' AND BasicISS.DrivFitBasicAlert NEQ 'Y' AND BasicISS.ContrSubstBasicAlert NEQ 'Y' AND BasicISS.VehMaintBasicAlert NEQ 'Y' AND BasicISS.CrashBasicAlert NEQ 'Y'>
              <cfset Carrier["risk_assessment"] = "Acceptable">
            </cfif> 

            <cfquery name="qUpdCarrier" datasource="#Application.dsn#">
              UPDATE Carriers SET RiskAssessment = <cfqueryparam cfsqltype="cf_sql_varchar" value="#Carrier["risk_assessment"]#" null="#yesNoFormat(NOT len(Carrier["risk_assessment"]))#"> WHERE CarrierID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#Carrier["CarrierID"]#">
            </cfquery>

            <cfhttp url="https://api.carriersoftware.com/api/InsuranceHistory?dot=#DOT_Number#" method="get"  throwonerror = Yes result="objCarrierInsuranceHistory">
              <cfhttpparam type="header" name="API_KEY" value="#trim(qSystemSetupOptions.CarrierLookoutAPIKey)#"/>
            </cfhttp>

            <cfif objCarrierInsuranceHistory.Statuscode EQ '200 OK'>
              <cfset CarrierInsuranceHistory = DeserializeJSON(objCarrierInsuranceHistory.Filecontent)>
              <cfif NOT StructIsEmpty(CarrierInsuranceHistory) AND not ArrayIsEmpty(CarrierInsuranceHistory.results)>
                <cfloop array="#CarrierInsuranceHistory.results#" index="InsuranceHistory">
                  <cfset var CarrierInsuranceHistoryInfo= structNew()>
                  <cfset CarrierInsuranceHistoryInfo["DocketNo"] = InsuranceHistory.DocketNo>
                  <cfif structkeyexists(InsuranceHistory,"Form")>
                    <cfset CarrierInsuranceHistoryInfo["Form"] = InsuranceHistory.Form>
                  <cfelse>
                    <cfset CarrierInsuranceHistoryInfo["Form"] = "">
                  </cfif>
                  <cfset CarrierInsuranceHistoryInfo["Type"] = InsuranceHistory.Type>
                  <cfset CarrierInsuranceHistoryInfo["InsuranceCarrier"] = InsuranceHistory.Carrier>
                  <cfset CarrierInsuranceHistoryInfo["PolicyNo"] = InsuranceHistory.PolicyNo>
                  <cfset CarrierInsuranceHistoryInfo["CoveredTo"] = InsuranceHistory.CovMax>

                  <cfset CarrierInsuranceHistoryInfo["EffStartDate"] = "">
                  <cfif structkeyexists(InsuranceHistory,"EffStartDate")>
                    <cfset CarrierInsuranceHistoryInfo["EffStartDate"]= InsuranceHistory.EffStartDate.ReplaceFirst(
                        "^.*?(\d{4})-?(\d{2})-?(\d{2})T([\d:]+).*$",
                        "$1-$2-$3 $4"
                        ) />
                  </cfif>
                  <cfset CarrierInsuranceHistoryInfo["EffEndDate"] = "">
                  <cfif structkeyexists(InsuranceHistory,"EffEndDate")>
                    <cfset CarrierInsuranceHistoryInfo["EffEndDate"]= InsuranceHistory.EffEndDate.ReplaceFirst(
                        "^.*?(\d{4})-?(\d{2})-?(\d{2})T([\d:]+).*$",
                        "$1-$2-$3 $4"
                        ) />
                  </cfif>
                  <cfset CarrierInsuranceHistoryInfo["EndAction"] = InsuranceHistory.EndAction>

                  <cfquery name="qInsCarrierInsuranceHistory" datasource="#Application.dsn#">
                    INSERT INTO [dbo].[CLInsuranceHistory]
                   ([ID]
                   ,[CarrierID]
                   ,[CreatedBy]
                   ,[DocketNo]
                   ,[Form]
                   ,[Type]
                   ,[InsuranceCarrier]
                   ,[PolicyNo]
                   ,[CoveredTo]
                   ,[EffectiveDateFrom]
                   ,[EffectiveDateTo]
                   ,[EndAction])
                   VALUES(
                    NEWID(),
                    <cfqueryparam cfsqltype="cf_sql_varchar" value="#Carrier["CarrierID"]#">,
                    <cfif structKeyExists(session, "adminusername")>
                      <cfqueryparam cfsqltype="cf_sql_varchar" value="#session.adminusername#">,
                    <cfelse>
                      'Onboard',
                    </cfif>
                    <cfqueryparam cfsqltype="cf_sql_varchar" value="#CarrierInsuranceHistoryInfo["DocketNo"]#">,
                    <cfqueryparam cfsqltype="cf_sql_varchar" value="#CarrierInsuranceHistoryInfo["Form"]#" null="#not len(CarrierInsuranceHistoryInfo["Form"])#">,
                    <cfqueryparam cfsqltype="cf_sql_varchar" value="#CarrierInsuranceHistoryInfo["Type"]#">,
                    <cfqueryparam cfsqltype="cf_sql_varchar" value="#CarrierInsuranceHistoryInfo["InsuranceCarrier"]#">,
                    <cfqueryparam cfsqltype="cf_sql_varchar" value="#CarrierInsuranceHistoryInfo["PolicyNo"]#">,
                    <cfqueryparam cfsqltype="cf_sql_varchar" value="#CarrierInsuranceHistoryInfo["CoveredTo"]#">,
                    <cfqueryparam cfsqltype="cf_sql_date" value="#CarrierInsuranceHistoryInfo["EffStartDate"]#"  null="#not len(CarrierInsuranceHistoryInfo["EffStartDate"])#">,
                    <cfqueryparam cfsqltype="cf_sql_date" value="#CarrierInsuranceHistoryInfo["EffEndDate"]#"  null="#not len(CarrierInsuranceHistoryInfo["EffEndDate"])#">,
                    <cfqueryparam cfsqltype="cf_sql_varchar" value="#CarrierInsuranceHistoryInfo["EndAction"]#">
                    )
                  </cfquery>
                </cfloop>
              </cfif>
            </cfif>

          </cftransaction>
          <cfquery name="qGetMC_DOT" datasource="ZFMCSA">
              select COUNT(id) AS count from MC_DOT WHERE MC = <cfqueryparam cfsqltype="cf_sql_varchar" value="#Carrier["MCNumber"]#">
          </cfquery>
          <cfif not qGetMC_DOT.count>
            <cfquery name="qInsMC_DOT" datasource="ZFMCSA">
              INSERT INTO [dbo].[MC_DOT]
               ([DOT]
               ,[MC]
               ,[Updated]
               ,[Carrier Name])
              VALUES
               (<cfqueryparam cfsqltype="cf_sql_varchar" value="#Carrier["DOTNumber"]#">
               ,<cfqueryparam cfsqltype="cf_sql_varchar" value="#Carrier["MCNumber"]#">
               ,GETDATE()
               ,<cfqueryparam cfsqltype="cf_sql_varchar" value="#Carrier["CarrierName"]#">)
            </cfquery>
          </cfif>
        </cfif>
      </cfif>
      <cfif isDefined('Carrier')>
        <cfreturn Carrier["CarrierID"]>
      <cfelse>
        <cfreturn 1>
      </cfif>
      <cfcatch>
        <cfif isDefined("cfcatch.message") AND cfcatch.message EQ 'Connection Failure: Status code unavailable'>
          <cfreturn 0>
        </cfif>
        <cfscript>
          variables.objLoadGateway = #request.cfcpath#&".loadgateway";
        </cfscript>
        <cfinvoke component="#variables.objLoadGateway#" method="CreateLogError" Exception="#cfcatch#">
        <cfreturn 0>
      </cfcatch>
    </cftry>
  </cffunction>
  <cffunction name="getCarrierEquipments" access="remote" output="yes" returnformat="json">
    <cfargument name="CompanyID" required="yes" type="string">
    <cfargument name="CarrierID" required="yes" type="string">
    <cfargument name="dsn" required="yes" type="string">
    <cfargument name="sortby" required="yes" type="string" default="ModifiedDateTime">
    <cfargument name="sortorder" required="yes" type="string" default="Desc">
    <cfif arguments.CarrierID EQ 0>
      <cfset arguments.CarrierID = '00000000-0000-0000-0000-000000000000'>
    </cfif>
    <cfquery name="qGetCarrierEquipments" datasource="#arguments.dsn#">
      SELECT CE.CarrierEquipmentID,CE.EquipmentID,CE.IsDefault,CE.ModifiedDateTime,CE.DriverContactID,E.TruckTrailerOption
      FROM CarrierEquipments CE
      LEFT JOIN Equipments E ON E.EquipmentID = CE.EquipmentID
      WHERE CE.CarrierID = <cfqueryparam value="#arguments.CarrierID#" cfsqltype="cf_sql_varchar">

      UNION 
      SELECT NULL AS CarrierEquipmentID,NULL AS EquipmentID,0 AS IsDefault,getdate() AS ModifiedDateTime,NULL AS DriverContactID,NULL AS TruckTrailerOption
      WHERE (SELECT COUNT(CarrierEquipmentID) FROM CarrierEquipments WHERE CarrierID = <cfqueryparam value="#arguments.CarrierID#" cfsqltype="cf_sql_varchar">) = 0

      ORDER BY IsDefault DESC,#arguments.SortBy# #arguments.Sortorder#
    </cfquery>

    <cfquery  name="qEquipments" datasource="#arguments.dsn#">
      SELECT E.EquipmentID,E.EquipmentName,E.EquipmentType,E.TruckTrailerOption FROM Equipments E
        WHERE E.CompanyID = <cfqueryparam value="#arguments.CompanyID#" cfsqltype="cf_sql_varchar"> AND E.IsActive = 1
    </cfquery>

    <cfquery  name="qDriver" datasource="#arguments.dsn#">
      SELECT CarrierContactID,ContactPerson FROM CarrierContacts WHERE ContactType = 'Driver'
      AND CarrierID = <cfqueryparam value="#arguments.CarrierID#" cfsqltype="cf_sql_varchar">
    </cfquery>

    <cfsavecontent variable="ResponseData">
      <cfloop query="qGetCarrierEquipments">
        <tr id="equipmentrow_#qGetCarrierEquipments.currentrow#">
          <td class="normaltd" valign="top" align="left" style="border-left: 1px solid ##5d8cc9;" height="30">
            <input type="hidden" name="CarrierEquipmentID_#qGetCarrierEquipments.currentrow#" id="CarrierEquipmentID_#qGetCarrierEquipments.currentrow#" value="#qGetCarrierEquipments.CarrierEquipmentID#">
            <select class="selEquipmentID EquipmentSelect2" style="width:195px;height:26px;" name="EquipmentID_#qGetCarrierEquipments.currentrow#" id="EquipmentID_#qGetCarrierEquipments.currentrow#" onchange="changeTruck(this)">
              <option value=""></option>
              <cfloop query="qEquipments">
                <cfif qEquipments.EquipmentType NEQ 'Trailer'>
                  <option value="#qEquipments.equipmentId#" <cfif qEquipments.equipmentId EQ qGetCarrierEquipments.EquipmentID> selected </cfif> data-trailer="#qEquipments.TruckTrailerOption#">#qEquipments.equipmentName#</option>
                </cfif>
              </cfloop>
            </select>
          </td>
          <td class="normaltd" valign="middle" align="left">
            <select style="width:195px;height:26px;" class="relEquipmentID RelEquipmentSelect2" name="relEquipmentID_#qGetCarrierEquipments.currentrow#" id="relEquipmentID_#qGetCarrierEquipments.currentrow#">
              <option value=""></option>
              <cfloop query="qEquipments">
                <cfif qEquipments.EquipmentType EQ 'Trailer'>
                  <option value="#qEquipments.equipmentId#" <cfif qEquipments.equipmentId EQ qGetCarrierEquipments.TruckTrailerOption> selected </cfif>>#qEquipments.equipmentName#</option>
                </cfif>
              </cfloop>
            </select>
          </td>
          <td class="normaltd" valign="middle" align="left">
            <select style="width:195px;height:26px;" name="DriverContactID_#qGetCarrierEquipments.currentrow#" id="DriverContactID_#qGetCarrierEquipments.currentrow#" class="DriverSelect2">
              <option value=""></option>
              <cfloop query="qDriver">
                <option value="#qDriver.CarrierContactID#" <cfif qDriver.CarrierContactID eq qGetCarrierEquipments.DriverContactID> selected </cfif>>#qDriver.ContactPerson#</option>
              </cfloop>
            </select>
          </td>
          <td class="normaltd" valign="middle" align="center">
            <input type="checkbox" class="IsDefault" name="IsDefault_#qGetCarrierEquipments.currentrow#" id="IsDefault_#qGetCarrierEquipments.currentrow#" <cfif qGetCarrierEquipments.IsDefault> checked </cfif> onclick="DefaultEquipment(this)">
          </td>
          <td class="normaltd" valign="middle" align="center">
            <img class="delRow" name="RemoveEquip_#qGetCarrierEquipments.currentrow#" id="RemoveEquip_#qGetCarrierEquipments.currentrow#" onclick="RemoveEquipmentRow(this)" src="images/delete-icon.gif" style="width:10px;margin-left: 5px;cursor: pointer;">
          </td>
        </tr>
      </cfloop>
    </cfsavecontent>
    <cfset response = structNew()>
    <cfset response['data'] = ResponseData>
    <cfset response['recordcount'] = qGetCarrierEquipments.recordcount>

    <cfreturn response>
  </cffunction>

  <cffunction name="DeleteCarrierEquipment" access="remote" output="yes" returnformat="json">
    <cfargument name="CarrierEquipmentID" required="yes" type="string">
    <cfargument name="dsn" required="yes" type="string">

    <cftry>
      <cfquery name="delQry" datasource="#arguments.dsn#">
        DELETE FROM CarrierEquipments WHERE CarrierEquipmentID = <cfqueryparam value="#arguments.CarrierEquipmentID#" cfsqltype="cf_sql_varchar">
      </cfquery>
      <cfreturn 'Success'>
      <cfcatch>
        <cfreturn 'Error'>
      </cfcatch>
    </cftry>
  </cffunction>

  <cffunction name="DeleteCarrierCommodity" access="remote" output="yes" returnformat="json">
    <cfargument name="ID" required="yes" type="string">
    <cfargument name="dsn" required="yes" type="string">

    <cftry>
      <cfquery name="delQry" datasource="#arguments.dsn#">
        DELETE FROM carrier_commodity WHERE ID = <cfqueryparam value="#arguments.ID#" cfsqltype="cf_sql_integer">
      </cfquery>
      <cfreturn 'Success'>
      <cfcatch>
        <cfreturn 'Error'>
      </cfcatch>
    </cftry>
  </cffunction>

  <!--- Delete Carrier Contacts--->
  <cffunction name="deleteCarrierEquipments" access="public" returntype="any">
      <cfargument name="CarrierID" type="any" required="yes">
      <cftry>
      <cfquery name="qrydelete" datasource="#variables.dsn#">
          delete from CarrierEquipments
          where CarrierID=<cfqueryparam value="#arguments.CarrierID#" cfsqltype="cf_sql_varchar">
      </cfquery>
      <cfreturn "1">
      <cfcatch type="any">
          <cfreturn "0">
      </cfcatch>
      </cftry>
  </cffunction>

  <cffunction name="getCarrierLanes" access="public" returntype="any">
      <cfargument name="CarrierID" type="any" required="yes">

      <cfquery name="qLanes" datasource="#variables.dsn#">
        SELECT 
          L.LoadNumber,
          CL.PickUpCity,
          CL.PickUpState,
          CL.PickUpZip,
          CL.PickDate,
          CL.DeliveryCity,
          CL.DeliveryState,
          CL.DeliveryZip,
          CL.DeliveryDate,
          CL.Cost,
          CL.Miles,
          CASE WHEN CL.Miles <> 0 THEN (CL.Cost/CL.Miles) ELSE 0 END AS RatePerMile,
          CL.IntransitStops,
          CL.CreatedBy,
          CL.CreatedDateTime,
          CL.CarrierLaneID,
          CL.EquipmentID,
          1 AS SortOrder
        FROM CarrierLanes CL
        LEFT JOIN Loads L ON L.LoadID = CL.LoadID
        WHERE CL.CarrierID=<cfqueryparam value="#arguments.CarrierID#" cfsqltype="cf_sql_varchar">
        UNION

        SELECT 
          NULL AS LoadNumber,
          NULL AS PickUpCity,
          NULL AS PickUpState,
          NULL AS PickUpZip,
          NULL AS PickDate,
          NULL AS DeliveryCity,
          NULL AS DeliveryState,
          NULL AS DeliveryZip,
          NULL AS DeliveryDate,
          0 AS Cost,
          0 AS Miles,
          0 AS RatePerMile,
          0 AS IntransitStops,
          NULL AS CreatedBy,
          NULL AS CreatedDateTime,
          NULL AS CarrierLaneID,
          NULL AS EquipmentID,
          2 AS SortOrder
          
        ORDER BY SortOrder ASC,DeliveryDate DESC
      </cfquery>
      <cfreturn qLanes>
  </cffunction>

  <cffunction name="setCarrierLanes" access="remote" returntype="struct" returnformat="json">
    <cfargument name="CarrierLaneID" type="string" required="yes"/>
    <cfargument name="EquipmentID" type="string" required="yes"/>

    <cfargument name="PickUpCity" type="string" required="yes"/>
    <cfargument name="PickUpState" type="string" required="yes"/>
    <cfargument name="PickUpZip" type="string" required="yes"/>
    <cfargument name="PickDate" type="string" required="yes"/>

    <cfargument name="DeliveryCity" type="string" required="yes"/>
    <cfargument name="DeliveryState" type="string" required="yes"/>
    <cfargument name="DeliveryZip" type="string" required="yes"/>
    <cfargument name="DeliveryDate" type="string" required="yes"/>

    <cfargument name="Cost" type="string" required="yes"/>
    <cfargument name="Miles" type="string" required="yes"/>
    <cfargument name="RatePerMile" type="string" required="yes"/>
    <cfargument name="IntransitStops" type="string" required="yes"/>

    <cfargument name="dsn" type="string" required="yes"/>
    <cfargument name="CreatedBy" type="string" required="yes"/>
    <cfargument name="CarrierID" type="string" required="yes"/>
    <cftry>

      <cfquery name="qCheckDuplicate" datasource="#arguments.dsn#">
        SELECT COUNT(CarrierLaneID) AS CLCount FROM CarrierLanes 
        WHERE CarrierID = <cfqueryparam value="#arguments.CarrierID#" cfsqltype="cf_sql_varchar"> 
        AND ISNULL(EquipmentID,'') = <cfqueryparam value="#arguments.EquipmentID#" cfsqltype="cf_sql_varchar"> 
        AND ((PickUpCity = <cfqueryparam value="#arguments.PickUpCity#" cfsqltype="cf_sql_varchar"> AND PickUpState=<cfqueryparam value="#arguments.PickUpState#" cfsqltype="cf_sql_varchar">) OR PickUpZip =<cfqueryparam value="#arguments.PickUpZip#" cfsqltype="cf_sql_varchar">)
        AND ((DeliveryCity = <cfqueryparam value="#arguments.DeliveryCity#" cfsqltype="cf_sql_varchar"> AND DeliveryState=<cfqueryparam value="#arguments.DeliveryCity#" cfsqltype="cf_sql_varchar">) OR DeliveryZip =<cfqueryparam value="#arguments.DeliveryZip#" cfsqltype="cf_sql_varchar">)
        <cfif len(trim(arguments.CarrierLaneID))>
          AND CarrierLaneID <> <cfqueryparam value="#arguments.CarrierLaneID#" cfsqltype="cf_sql_varchar">
        </cfif>
      </cfquery>

      <cfif qCheckDuplicate.CLCount NEQ 0>
        <cfset response['Success']=0>
        <cfset response['Message']='Duplicate lane entry not allowed. Please change pickup location or delivery location or equipment and try again.'>
        <cfreturn response>
      </cfif>

      <cfif not len(trim(arguments.CarrierLaneID))>
        <cfquery name="qGetCarrierLaneID" datasource="#arguments.dsn#">
          SELECT NEWID() AS ID
        </cfquery>

        <cfquery name="qIns" datasource="#arguments.dsn#">
          INSERT INTO CarrierLanes (
            CarrierLaneID,
            CarrierID,
            EquipmentID,
            PickUpCity,
            PickUpState,
            PickUpZip,
            PickDate,
            DeliveryCity,
            DeliveryState,
            DeliveryZip,
            DeliveryDate,
            Cost,
            Miles,
            RatePerMile,
            IntransitStops,
            CreatedBy,
            ModifiedBy
            ) 
          VALUES(
            <cfqueryparam value="#qGetCarrierLaneID.ID#" cfsqltype="cf_sql_varchar">,
            <cfqueryparam value="#arguments.CarrierID#" cfsqltype="cf_sql_varchar">,
            <cfqueryparam value="#arguments.EquipmentID#" cfsqltype="cf_sql_varchar" null="#not len(arguments.EquipmentID)#">,
            <cfqueryparam value="#arguments.PickUpCity#" cfsqltype="cf_sql_varchar" null="#not len(arguments.PickUpCity)#">,
            <cfqueryparam value="#arguments.PickUpState#" cfsqltype="cf_sql_varchar" null="#not len(arguments.PickUpState)#">,
            <cfqueryparam value="#arguments.PickUpZip#" cfsqltype="cf_sql_varchar" null="#not len(arguments.PickUpZip)#">,
            <cfqueryparam value="#arguments.PickDate#" cfsqltype="cf_sql_date" null="#not len(arguments.PickDate)#">,
            <cfqueryparam value="#arguments.DeliveryCity#" cfsqltype="cf_sql_varchar" null="#not len(arguments.DeliveryCity)#">,
            <cfqueryparam value="#arguments.DeliveryState#" cfsqltype="cf_sql_varchar" null="#not len(arguments.DeliveryState)#">,
            <cfqueryparam value="#arguments.DeliveryZip#" cfsqltype="cf_sql_varchar" null="#not len(arguments.DeliveryZip)#">,
            <cfqueryparam value="#arguments.DeliveryDate#" cfsqltype="cf_sql_date" null="#not len(arguments.DeliveryDate)#">,
            <cfqueryparam value="#arguments.Cost#" cfsqltype="cf_sql_float">,
            <cfqueryparam value="#arguments.Miles#" cfsqltype="cf_sql_float">,
            <cfqueryparam value="#arguments.RatePerMile#" cfsqltype="cf_sql_float">,
            <cfqueryparam value="#arguments.IntransitStops#" cfsqltype="cf_sql_integer">,
            <cfqueryparam value="#arguments.CreatedBy#" cfsqltype="cf_sql_varchar">,
            <cfqueryparam value="#arguments.CreatedBy#" cfsqltype="cf_sql_varchar">
            )
        </cfquery>

        <cfquery name="qGet" datasource="#arguments.dsn#">
          SELECT CreatedDateTime FROM CarrierLanes WHERE CarrierLaneID = <cfqueryparam value="#qGetCarrierLaneID.ID#" cfsqltype="cf_sql_varchar">
        </cfquery>
        <cfset var response = structNew()>
        <cfset response['Success']=1>
        <cfset response['CarrierLaneID']=qGetCarrierLaneID.ID>
        <cfset response['CreatedDateTime']=DateTimeFormat(qGet.CreatedDateTime,'short')>
        <cfreturn response>
      <cfelse>
        <cfquery name="qUpd" datasource="#arguments.dsn#">
          UPDATE CarrierLanes SET 
            EquipmentID=<cfqueryparam value="#arguments.EquipmentID#" cfsqltype="cf_sql_varchar" null="#not len(arguments.EquipmentID)#">,
            PickUpCity=<cfqueryparam value="#arguments.PickUpCity#" cfsqltype="cf_sql_varchar" null="#not len(arguments.PickUpCity)#">,
            PickUpState=<cfqueryparam value="#arguments.PickUpState#" cfsqltype="cf_sql_varchar" null="#not len(arguments.PickUpState)#">,
            PickUpZip=<cfqueryparam value="#arguments.PickUpZip#" cfsqltype="cf_sql_varchar" null="#not len(arguments.PickUpZip)#">,
            PickDate=<cfqueryparam value="#arguments.PickDate#" cfsqltype="cf_sql_date" null="#not len(arguments.PickDate)#">,
            DeliveryCity=<cfqueryparam value="#arguments.DeliveryCity#" cfsqltype="cf_sql_varchar" null="#not len(arguments.DeliveryCity)#">,
            DeliveryState=<cfqueryparam value="#arguments.DeliveryState#" cfsqltype="cf_sql_varchar" null="#not len(arguments.DeliveryState)#">,
            DeliveryZip=<cfqueryparam value="#arguments.DeliveryZip#" cfsqltype="cf_sql_varchar" null="#not len(arguments.DeliveryZip)#">,
            DeliveryDate=<cfqueryparam value="#arguments.DeliveryDate#" cfsqltype="cf_sql_date" null="#not len(arguments.DeliveryDate)#">,
            Cost=<cfqueryparam value="#arguments.Cost#" cfsqltype="cf_sql_float">,
            Miles=<cfqueryparam value="#arguments.Miles#" cfsqltype="cf_sql_float">,
            RatePerMile=<cfqueryparam value="#arguments.RatePerMile#" cfsqltype="cf_sql_float">,
            IntransitStops=<cfqueryparam value="#arguments.IntransitStops#" cfsqltype="cf_sql_integer">,
            ModifiedBy=<cfqueryparam value="#arguments.CreatedBy#" cfsqltype="cf_sql_varchar">
          WHERE CarrierLaneID = <cfqueryparam value="#arguments.CarrierLaneID#" cfsqltype="cf_sql_varchar">
        </cfquery>
        <cfset var response = structNew()>
          <cfset response['Success']=1>
          <cfset response['CarrierLaneID']=arguments.CarrierLaneID>
          <cfreturn response>
        </cfif>
        <cfcatch>
          <cfset response['Success']=0>
          <cfset response['Message']='Something went wrong. Please try again later.'>
          <cfreturn response>
        </cfcatch>
    </cftry>
  </cffunction>

  <cffunction name="deleteCarrierLane" access="remote" returntype="struct" returnformat="json">
    <cfargument name="CarrierLaneID" type="string" required="yes"/>
    <cfargument name="dsn" type="string" required="yes"/>
    <cftry>
      <cfquery name="qDelete" datasource="#arguments.dsn#">
        DELETE FROM CarrierLanes WHERE CarrierLaneID = <cfqueryparam value="#arguments.CarrierLaneID#" cfsqltype="cf_sql_varchar"> 
      </cfquery>
      <cfset response['Success']=1>
      <cfreturn response>
      <cfcatch>
        <cfset response['Success']=0>
        <cfset response['Message']='Something went wrong. Please try again later.'>
        <cfreturn response>
      </cfcatch>
    </cftry>
  </cffunction>

  <cffunction name="searchCarrierLanes" access="public" returntype="any">
      	<cfargument name="LoadID" type="any" required="yes">
      	<cftry>
	      	<CFSTOREDPROC PROCEDURE="SP_SearchCarrierLanes" DATASOURCE="#variables.dsn#">
	        	<CFPROCPARAM VALUE="#arguments.LoadID#" cfsqltype="CF_SQL_VARCHAR">
	        	<CFPROCPARAM VALUE="#session.CompanyID#" cfsqltype="CF_SQL_VARCHAR">
	        	<CFPROCRESULT NAME="qLanes">
	      	</CFSTOREDPROC>
	      	<cfreturn qLanes>
		   	<cfcatch>
		   		<cfreturn QueryNew( "" )>
		   	</cfcatch>
	  	</cftry>
  </cffunction>

  <cffunction name="getAdvanceSearchedCarrier" access="public" output="false" returntype="query">
    <cfargument name="pageNo" required="no" type="string" default="1">
    <cfargument name="sortorder" required="no" type="string" default="ASC">
    <cfargument name="sortby" required="no" type="string" default="CarrierName">
    <cfargument name="frmstruct" required="yes" type="struct">

    <cfif listLen(arguments.frmstruct.EquipmentID) LT listLen(arguments.frmstruct.PickUpState)>
      <cfset Difference = listLen(arguments.frmstruct.PickUpState) - listLen(arguments.frmstruct.EquipmentID)>
      <cfloop from='1' to="#Difference#" index="i" step="1">
        <cfset var tempEquipmentID = listAppend('#arguments.frmstruct.EquipmentID#',0,',')>
      </cfloop>  
      <cfset arguments.frmstruct.EquipmentID = tempEquipmentID>
    </cfif>
    <cfquery name="QreturnSearch" datasource="#variables.dsn#">
      WITH page AS (
        select 
        carriers.carrierid,
        carriers.MCNumber,
        carriers.CarrierName,
        carriers.City,
        carriers.Phone,
        carriers.EmailID,
        carriers.riskassessment,
        carriers.DOTNumber,
        carriers.Address,
        carriers.stateCode,
        carriers.zipCode,
        carriers.ContactPerson,
        carriers.insExpDate ,
        carriers.crmnextcalldate,
        carriers.status,
        Cast(carriers.notes as Nvarchar(Max)) as notes,
        carriers.CDLEXPIRES,
        CASE WHEN (SELECT COUNT(CC.CarrierContactID) FROM CarrierContacts CC WHERE CC.CarrierID = Carriers.CarrierID AND CC.ContactType = 'General' AND LEN(isnull(CC.PhoneNO,'')) <> 0) <> 0
        THEN 
        (SELECT TOP 1 CC.PhoneNO FROM CarrierContacts CC WHERE CC.CarrierID = Carriers.CarrierID AND CC.ContactType = 'General' AND LEN(isnull(CC.PhoneNO,'')) <> 0)
        ELSE 
        (SELECT TOP 1 CC.PhoneNO FROM CarrierContacts CC WHERE CC.CarrierID = Carriers.CarrierID AND CC.ContactType <> 'General' AND LEN(isnull(CC.PhoneNO,'')) <> 0)
        END AS phoneNo,
 
       ROW_NUMBER() OVER (ORDER BY
          UPPER(#arguments.sortby#) #arguments.sortorder#
        ) AS Row
      from carriers
      inner join carrierlanes on carrierlanes.carrierId = carriers.carrierId
      where
        carriers.CompanyID =  <cfqueryparam value="#session.companyid#" cfsqltype="cf_sql_varchar">
  
        <cfset var row = 0>
        <cfloop from="1" to="#listLen(arguments.frmstruct.PickUpState)#" index="i" step="1">
          <cfset var PickUpState = listGetAt(arguments.frmstruct.PickUpState, i)>
          <cfset var DeliveryState = listGetAt(arguments.frmstruct.DeliveryState, i)>
          <cfset var EquipmentID = listGetAt(arguments.frmstruct.EquipmentID, i)>
          <cfif i eq 1> AND ((<cfelse> OR (</cfif>
            <cfif PickUpState NEQ 0 OR DeliveryState NEQ 0 OR EquipmentID NEQ 0>
              1 = 1 
              <cfif PickUpState NEQ 0>
                AND carrierlanes.PickUpState = <cfqueryparam cfsqltype="cf_sql_varchar" value="#PickUpState#">
              </cfif>
              <cfif DeliveryState NEQ 0>
                AND carrierlanes.DeliveryState = <cfqueryparam cfsqltype="cf_sql_varchar" value="#DeliveryState#">
              </cfif>
              <cfif EquipmentID NEQ 0>
                AND carrierlanes.EquipmentID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#EquipmentID#">
              </cfif>
            <cfelse>
              1 = <cfif listLen(arguments.frmstruct.PickUpState) EQ 1>1<cfelse>2</cfif>
            </cfif>
           <cfif i eq listLen(arguments.frmstruct.PickUpState)>))<cfelse>)</cfif>
        </cfloop>
        
        group by
        carriers.carrierid,
        carriers.MCNumber,
        carriers.CarrierName,
        carriers.City,
        carriers.Phone,
        carriers.EmailID,
        carriers.riskassessment,
        carriers.DOTNumber,
        carriers.Address,
        carriers.stateCode,
        carriers.zipCode,
        carriers.ContactPerson,
        carriers.insExpDate ,
        carriers.crmnextcalldate,
        carriers.status,
        Cast(carriers.notes as Nvarchar(Max)),carriers.CDLEXPIRES
         )
       SELECT *,(select (max(row)/30) + (CASE WHEN max(row)%30 <> 0 THEN 1 ELSE 0 END)  FROM page) AS TotalPages FROM page WHERE Row between (<cfqueryparam value="#pageNo#" cfsqltype="cf_sql_varchar"> - 1) * 30 + 1 and <cfqueryparam value="#pageNo#" cfsqltype="cf_sql_varchar">*30

    </cfquery>

    <cfreturn QreturnSearch>
  </cffunction>

  <cffunction name="getActivePendingInsurance" access="public" output="false" returntype="query">
    <cfargument name="CarrierID" type="string">
    <cfargument name="DOTNumber" type="string">

    <cfquery name="qGetActivePendingInsurance" datasource="#variables.dsn#">
      SELECT 
      ID 
      ,DocketNo
      ,Form
      ,Type
      ,InsuranceCarrier
      ,PolicyNo
      ,CoveredTo
      ,CASE WHEN Req IN ('Y','N') THEN '$0.00' ELSE Req END AS Req
      ,CASE WHEN OnFile IN ('Y','N') THEN '$0.00' ELSE OnFile END AS OnFile
      ,EffectiveDate
      ,ExpirationDate
      ,BIPDClass
      ,CancelDate
      ,1 AS SortOrder
      FROM CLActivePendingInsurance WHERE CarrierID = <cfqueryparam value="#arguments.CarrierID#" cfsqltype="cf_sql_varchar"> 
      UNION 
      SELECT
      NULL AS ID 
      ,NULL AS DocketNo
      ,NULL AS Form
      ,NULL AS Type
      ,NULL AS InsuranceCarrier
      ,NULL AS PolicyNo
      ,'$0.00' AS CoveredTo
      ,'$0.00' AS Req
      ,'$0.00' AS OnFile
      ,NULL AS EffectiveDate
      ,NULL AS ExpirationDate
      ,NULL AS BIPDClass
      ,NULL AS CancelDate
      ,2 AS SortOrder
      ORDER BY SortOrder,Type
    </cfquery>

    <cfreturn qGetActivePendingInsurance>
  </cffunction>

  <cffunction name="getInsuranceHistory" access="public" output="false" returntype="query">
    <cfargument name="CarrierID" type="string">
    <cfargument name="DOTNumber" type="string">

    <cfquery name="qGetInsuranceHistory" datasource="#variables.dsn#">
      SELECT * FROM CLInsuranceHistory WHERE CarrierID = <cfqueryparam value="#arguments.CarrierID#" cfsqltype="cf_sql_varchar"> ORDER BY EffectiveDateFrom DESC
    </cfquery>

    <cfreturn qGetInsuranceHistory>
  </cffunction>

  <cffunction name="DeleteCarrierInsurance" access="remote" returntype="struct" returnformat="json">
    <cfargument name="ID" type="string" required="yes"/>
    <cfargument name="dsn" type="string" required="yes"/>
    <cftry>
      <cfquery name="qDelete" datasource="#arguments.dsn#">
        DELETE FROM CLActivePendingInsurance WHERE ID = <cfqueryparam value="#arguments.ID#" cfsqltype="cf_sql_varchar"> 
      </cfquery>
      <cfset response['Success']=1>
      <cfreturn response>
      <cfcatch>
        <cfset response['Success']=0>
        <cfset response['Message']='Something went wrong. Please try again later.'>
        <cfreturn response>
      </cfcatch>
    </cftry>
  </cffunction>

  <cffunction name="SetCarrierInsurance" access="remote" returntype="struct" returnformat="json">
    <cfargument name="ID" type="string" required="yes"/>
    <cfargument name="FieldName" type="string" required="yes"/>
    <cfargument name="dsn" type="string" required="yes"/>
    <cfargument name="CreatedBy" type="string" required="yes"/>
    <cfargument name="CarrierID" type="string" required="yes"/>
    <cfargument name="FieldVal" type="string" required="yes"/>
    <cfargument name="BIPDClass" type="string" required="no" default=""/>
    <cfargument name="InsType" type="string" required="yes"/>
    <cftry>

      <cfif not len(trim(arguments.ID))>
        <cfquery name="qInsurance" datasource="#arguments.dsn#">
          SELECT NEWID() AS InsID
        </cfquery>
        <cfset arguments.ID = qInsurance.InsID>
        <cfquery name="qIns" datasource="#arguments.dsn#">
          INSERT INTO CLActivePendingInsurance (ID,CreatedBy,CarrierID)
          VALUES(
            <cfqueryparam value="#arguments.ID#" cfsqltype="cf_sql_varchar">
            ,<cfqueryparam value="#arguments.CreatedBy#" cfsqltype="cf_sql_varchar">
            ,<cfqueryparam value="#arguments.CarrierID#" cfsqltype="cf_sql_varchar">
            )
        </cfquery>
      </cfif>

      <cfset var sql_type = "cf_sql_varchar">

      <cfif listFindNoCase("EffectiveDate,ExpirationDate,CancelDate", arguments.FieldName)>
        <cfset sql_type = "cf_sql_date">
      </cfif>
      <cfquery name="qIns" datasource="#arguments.dsn#">
        UPDATE CLActivePendingInsurance 
        SET #arguments.FieldName# = <cfqueryparam value="#arguments.FieldVal#" cfsqltype="#sql_type#">
        ,ModifiedBy = <cfqueryparam value="#arguments.CreatedBy#" cfsqltype="cf_sql_varchar">
        ,ModifiedDate = GETDATE()
        <cfif arguments.FieldName EQ 'Type'>
          ,BIPDClass = <cfqueryparam value="#arguments.BIPDClass#" cfsqltype="cf_sql_varchar"  null="#not len(arguments.BIPDClass)#">
        </cfif>
        WHERE ID = <cfqueryparam value="#arguments.ID#" cfsqltype="cf_sql_varchar">
      </cfquery>

      <cfif arguments.FieldName EQ "ExpirationDate" AND listFindNoCase("1,2",arguments.InsType)>
        <cfquery name="qUpd" datasource="#arguments.dsn#">
          UPDATE Carriers SET 
          <cfif arguments.InsType EQ 1>
            InsExpDate = <cfqueryparam value="#arguments.FieldVal#" cfsqltype="cf_sql_date">
          <cfelse>
            InsExpDateCargo = <cfqueryparam value="#arguments.FieldVal#" cfsqltype="cf_sql_date">
          </cfif>
          WHERE CarrierID = <cfqueryparam value="#arguments.CarrierID#" cfsqltype="cf_sql_varchar">
        </cfquery>
      </cfif>
      <cfset var response = structNew()>
      <cfset response['Success']=1>
      <cfset response['ID']=arguments.ID>
      <cfreturn response>

      <cfcatch>
          <cfset response['Success']=0>
          <cfset response['Message']='Something went wrong. Please try again later.'>
          <cfreturn response>
        </cfcatch>
    </cftry>
  </cffunction>
  <cffunction name="saveCarrierScheduleCall" access="public" returntype="struct">
    <cfargument name="CarrierID" type="string" required="yes"/>
    <cfargument name="frmstruct" type="struct" required="yes"/>

    <cftry>
      <cfquery name="qUpd" datasource="#Application.dsn#">
        UPDATE Carriers SET
        CRMContactID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.frmstruct.CRMContactID#"   null="#not len(arguments.frmstruct.CRMContactID)#">
        ,CRMPhoneNo = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.frmstruct.CRMPhoneNo#"   null="#not len(arguments.frmstruct.CRMPhoneNo)#">
        ,CRMPhoneNOExt = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.frmstruct.CRMPhoneNOExt#"   null="#not len(arguments.frmstruct.CRMPhoneNOExt)#">
        ,CRMFax = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.frmstruct.CRMFax#"   null="#not len(arguments.frmstruct.CRMFax)#">
        ,CRMFaxExt = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.frmstruct.CRMFaxExt#"   null="#not len(arguments.frmstruct.CRMFaxExt)#">
        ,CRMTollFree = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.frmstruct.CRMTollFree#"   null="#not len(arguments.frmstruct.CRMTollFree)#">
        ,CRMTollFreeExt = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.frmstruct.CRMTollFreeExt#"   null="#not len(arguments.frmstruct.CRMTollFreeExt)#">
        ,CRMCell = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.frmstruct.CRMCell#"   null="#not len(arguments.frmstruct.CRMCell)#">
        ,CRMCellExt = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.frmstruct.CRMCellExt#"   null="#not len(arguments.frmstruct.CRMCellExt)#">
        ,CRMEmail = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.frmstruct.CRMEmail#"   null="#not len(arguments.frmstruct.CRMEmail)#">
        ,CRMNoteType = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.frmstruct.CRMNoteType#"   null="#not len(arguments.frmstruct.CRMNoteType)#">
        ,CRMRepeatInterval = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.frmstruct.CRMRepeatInterval#" null="#not len(arguments.frmstruct.CRMRepeatInterval)#">
        ,CRMNextCallDate = <cfqueryparam cfsqltype="cf_sql_date" value="#arguments.frmstruct.CRMNextCallDate#"  null="#not len(arguments.frmstruct.CRMNextCallDate)#">
        ,CRMUser = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.frmstruct.CRMUser#"   null="#not len(arguments.frmstruct.CRMUser)#">
        WHERE CarrierID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.CarrierID#">
      </cfquery>

      <cfset respStr = structNew()>
        <cfset respStr.res = "success">
        <cfset respStr.msg = "Updated Successfully.">
        <cfreturn respStr>
      <cfcatch>
          <cfset respStr = structNew()>
          <cfset respStr.res = "error">
          <cfset respStr.msg = "Something went wrong. Please try again later.">
          <cfreturn respStr>
        </cfcatch>
    </cftry>
  </cffunction>

  <cffunction name="UpdateQuotecarrier" access="public" output="false" returntype="any">
    <cfargument name="CarrierQuoteID" required="yes" type="string">
    <cfargument name="carrierid" required="yes" type="string">
    <cfquery name="qUpd" datasource="#Application.dsn#">
      UPDATE LoadCarrierQuotes SET CarrierID = <cfqueryparam value="#arguments.carrierid#" cfsqltype="cf_sql_varchar">,
      QUnknownCarrier = 0
      WHERE CarrierQuoteID = <cfqueryparam value="#arguments.CarrierQuoteID#" cfsqltype="cf_sql_integer">
    </cfquery>
    <cfreturn 'success'>
  </cffunction>

  <cffunction name="getCarrierContactDetail" access="remote" returntype="struct" returnformat="json">
    <cfargument name="CarrierContactID" type="string" required="yes"/>
    <cfargument name="dsn" type="string" required="yes"/>
    <cfquery name="qGet" datasource="#arguments.dsn#">
      SELECT ContactType,ContactPerson,Location,City,StateCode,ZipCode,PhoneNo,PhoneNoExt,Fax,Fax,FaxExt,TollFree,TollfreeExt,PersonMobileNo,MobileNoExt,Email FROM CarrierContacts
      WHERE CarrierContactID = <cfqueryparam value="#arguments.CarrierContactID#" cfsqltype="cf_sql_varchar">
      UNION
      SELECT 'Billing' AS ContactType,ContactPerson,Address AS Location,City,StateCode,ZipCode,Phone AS PhoneNo,PhoneExt AS PhoneNoExt,Fax,Fax,FaxExt,TollFree,TollfreeExt,Cel AS PersonMobileNo,CellPhoneExt AS MobileNoExt,EmailID FROM Carriers
      WHERE CarrierID = <cfqueryparam value="#arguments.CarrierContactID#" cfsqltype="cf_sql_varchar">
    </cfquery>
    <cfset retStr = structNew()>
    <cfloop query="qGet">
      <cfloop list="#qGet.ColumnList#" index="col">
        <cfset retStr["#col#"] = qGet["#col#"]>
      </cfloop>
    </cfloop>
    <cfreturn retStr>
  </cffunction>

  <cffunction name="CheckCarrierMissingAttachment" access="remote" output="yes" returntype="string" returnformat="json">
    <cfargument name="CarrierID" type="string" required="yes">
    <cfargument name="CompanyID" type="string" required="yes">
    <cfargument name="dsn" type="string" required="yes">
    <cfargument name="type" type="string" required="no" default="Carrier">

    <cftry>
      <cfquery name="qGet" datasource="#arguments.dsn#">
        SELECT COUNT(AttachmentTypeID) AS MissingAttCount FROM FileAttachmentTypes WHERE AttachmentType =<cfqueryparam value="#arguments.type#" cfsqltype="cf_sql_varchar"> AND Required = 1 AND CompanyID = <cfqueryparam value="#arguments.CompanyID#" cfsqltype="cf_sql_varchar">
        AND AttachmentTypeID NOT IN (SELECT MFA.AttachmentTypeID FROM FileAttachments FA
        INNER JOIN MultipleFileAttachmentsTypes MFA ON FA.attachment_Id = MFA.AttachmentID
        WHERE FA.linked_Id=<cfqueryparam value="#arguments.CarrierID#" cfsqltype="cf_sql_varchar">)
      </cfquery>
      <cfif qGet.MissingAttCount EQ 0>
        <cfreturn 0>
      <cfelse>
        <cfreturn 1>
      </cfif>
      <cfcatch>
        <cfreturn 0>
      </cfcatch>
    </cftry>

  </cffunction>

  <cffunction name="getDashBoardCarrierAuto" access="remote" output="yes" returntype="any" returnformat="json">
      <cfargument name="term" required="no" type="string">
      
      <cfquery name="qGet" datasource="#variables.dsn#">
        SELECT CarrierID,CarrierName FROM Carriers 
        WHERE CompanyID = <cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar">
        AND CarrierName like <cfqueryparam value="#arguments.term#%" cfsqltype="cf_sql_varchar">
      </cfquery>

      <cfset var retArr = arrayNew(1)>
      <cfloop query="qGet">
        <cfset tempStruct = structNew()>
        <cfset tempStruct["label"] = qGet.CarrierName>
        <cfset tempStruct["name"] = qGet.CarrierName>
        <cfset tempStruct["value"] = qGet.CarrierID>
        <cfset arrayAppend(retArr, tempStruct)>
      </cfloop>
      <cfreturn retArr>
  </cffunction>

  <cffunction name="getOnboardingDocs" access="public" output="false" returntype="query">
    <cfargument name="searchText" required="yes" type="any" default="">
    <cfargument name="pageNo" required="yes" type="any" default="-1">
    <cfargument name="sortorder" required="no" type="any" default="DESC">
    <cfargument name="sortby" required="no" type="any" default="UpdatedDateTime">

    <cfquery name="qGet" datasource="#Application.dsn#">
      <cfif arguments.pageNo neq -1>WITH page AS (</cfif>
      SELECT 
        ID,
        Name,
        Description,
        UpdatedDateTime,
        UpdateBy,
        Active,
        ROW_NUMBER() OVER (ORDER BY #arguments.sortBy#  #arguments.sortOrder#) AS Row
      FROM OnboardingDocuments
      WHERE CompanyID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#session.CompanyID#">
      <cfif len(trim(arguments.searchText))>
        AND
        (Name like <cfqueryparam value="%#arguments.searchText#%" cfsqltype="cf_sql_varchar">
        or Description like <cfqueryparam value="%#arguments.searchText#%" cfsqltype="cf_sql_varchar">)
      </cfif>
      <cfif arguments.pageNo neq -1>
        )
       SELECT *,(select (max(row)/30) + (CASE WHEN max(row)%30 <> 0 THEN 1 ELSE 0 END)  FROM page) AS TotalPages FROM page WHERE Row between (<cfqueryparam value="#pageNo#" cfsqltype="cf_sql_varchar"> - 1) * 30 + 1 and <cfqueryparam value="#pageNo#" cfsqltype="cf_sql_varchar">*30
       ORDER BY Row
      </cfif>
    </cfquery>

    <cfreturn qGet>
  </cffunction>

  <cffunction name="InsertOnboardingDoc" access="public" returntype="struct">
    <cfargument name="formStruct" type="struct" required="yes"/>
    <cftry>
      <cfset var ZohoTemplateID = "">
      <cfset var ZohoActionID = "">
      <cfset var ZohoDocumentID = "">
      <cfif arguments.formStruct.CreateDocFrom EQ 2 AND Len(Trim(arguments.formStruct.UploadFileName))>
        <cfinvoke method="CreateZohoTemplate" returnvariable="resZohoCreateTemplate">
          <cfinvokeargument Name="TemplateName" value="#Trim(arguments.formStruct.Name)#">
          <cfinvokeargument Name="FileName" value="#Trim(arguments.formStruct.UploadFileName)#">
        </cfinvoke>
        <cfset ZohoTemplateID = resZohoCreateTemplate.TemplateID>
        <cfset ZohoActionID = resZohoCreateTemplate.ActionID>
        <cfset ZohoDocumentID = resZohoCreateTemplate.DocumentID>
      </cfif>

      <cfquery name="qGet" datasource="#variables.dsn#">
        SELECT NEWID() AS ID
      </cfquery>
      <cfquery name="qIns" datasource="#variables.dsn#">
        INSERT INTO [dbo].[OnboardingDocuments]
          ([ID]
          ,[Name]
          ,[Description]
          ,[CreatedBy]
          ,[UpdatedDateTime]
          ,[UpdateBy]
          ,[Active]
          ,[CreateDocFrom]
          ,[DocEditorInformation]
          ,[UploadFileName]
          ,[CompanyID]
          ,[ZohoTemplateID]
          ,[ZohoActionID]
          ,[ZohoDocumentID]
          )
        VALUES(
          <cfqueryparam value="#qGet.ID#" cfsqltype="cf_sql_varchar">
          ,<cfqueryparam value="#arguments.formStruct.Name#" cfsqltype="cf_sql_varchar">
          ,<cfqueryparam value="#arguments.formStruct.Description#" cfsqltype="cf_sql_varchar">
          ,<cfqueryparam value="#session.adminusername#" cfsqltype="cf_sql_varchar">
          ,GETDATE()
          ,<cfqueryparam value="#session.adminusername#" cfsqltype="cf_sql_varchar">
          ,0
          ,<cfqueryparam value="#arguments.formStruct.CreateDocFrom#" cfsqltype="cf_sql_integer">
          ,<cfqueryparam value="#arguments.formStruct.DocEditorInformation#" cfsqltype="cf_sql_varchar" null="#yesNoFormat(NOT len(trim(arguments.formStruct.DocEditorInformation)))#">
          ,<cfqueryparam value="#arguments.formStruct.UploadFileName#" cfsqltype="cf_sql_varchar" null="#yesNoFormat(NOT len(trim(arguments.formStruct.UploadFileName)))#">
          ,<cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar">
          ,<cfqueryparam value="#ZohoTemplateID#" cfsqltype="cf_sql_varchar" null="#yesNoFormat(NOT len(trim(ZohoTemplateID)))#">
          ,<cfqueryparam value="#ZohoActionID#" cfsqltype="cf_sql_varchar" null="#yesNoFormat(NOT len(trim(ZohoActionID)))#">
          ,<cfqueryparam value="#ZohoDocumentID#" cfsqltype="cf_sql_varchar" null="#yesNoFormat(NOT len(trim(ZohoDocumentID)))#">
          )
      </cfquery>

      <cfset var response = structNew()>
      <cfset response['res']='success'>
      <cfset response['id']=qGet.ID>
      <cfset response['editTemplate']=1>
      <cfset response['msg']="Onboarding Doc added successfully. Please add atleast one signature field to make the document active.">
      <cfreturn response>

      <cfcatch>
        <cfset response['res']='error'>
        <cfset response['msg']='Unable to add doc. Please try again later.'>
        <cfreturn response>
      </cfcatch>
    </cftry>
  </cffunction>

  <cffunction name="getOnboardingDoc" access="public" output="false" returntype="query">
    <cfargument name="ID" required="yes" type="string">

    <cfquery name="qGet" datasource="#Application.dsn#">
      SELECT 
        ID,
        Name,
        Description,
        CreateDocFrom,
        DocEditorInformation,
        UploadFileName,
        Active,
        ZohoTemplateID
      FROM OnboardingDocuments WHERE ID = <cfqueryparam value="#arguments.ID#" cfsqltype="cf_sql_varchar">
    </cfquery>

    <cfreturn qGet>
  </cffunction>

  <cffunction name="UdpateOnboardingDoc" access="public" returntype="struct">
    <cfargument name="formStruct" type="struct" required="yes"/>
    <cftry>
      
      <cfif structKeyExists(arguments.formStruct, "Active")>
        <cfset var bitActive = 1>
      <cfelse>
        <cfset var bitActive = 0>
      </cfif>
      <cfset var SignFieldMsg = "">
      <cfif structKeyExists(arguments.formStruct, "ZohoTemplateID") AND Len(Trim(arguments.formStruct.ZohoTemplateID)) AND bitActive EQ 1>
        <cfhttp method="post" url="https://accounts.zoho.com/oauth/v2/token" result="objRespAccessToken">
          <cfhttpparam type="url" name="refresh_token" value="1000.2cea9b0735011dad98cc3479f1734f48.980caac236c9085dfa9bc0aad5ee444a"/>
          <cfhttpparam type="url" name="client_id" value="1000.KW1ZX4LDG0LMC6OC4V3BJZ57Z03AEZ"/>
          <cfhttpparam type="url" name="client_secret" value="df1e7797a0b17ef9cab6a5d827da89a479238734ac"/>
          <cfhttpparam type="url" name="grant_type" value="refresh_token"/>
        </cfhttp>

        <cfset structRespAccessToken = deserializeJSON(objRespAccessToken.filecontent)>
        <cfset auth_token = structRespAccessToken.access_token>
        <cfhttp method="get" url="https://sign.zoho.com/api/v1/templates/#arguments.formStruct.ZohoTemplateID#" result="objRespTemplatesFields">
          <cfhttpparam type="header" name="Authorization" value="Zoho-oauthtoken #auth_token#"/>
        </cfhttp>
        <cfset structResp = deserializeJSON(objRespTemplatesFields.Filecontent)>
        <cfset bitActive = 0>
        <cfset SignFieldMsg = " Please add atleast one signature field to make the document active.">
        <cfloop array="#structResp.templates.actions[1].fields#" item="field">
          <cfif isDefined('field.field_type_name') AND field.field_type_name EQ 'Signature'>
            <cfset bitActive = 1>
            <cfset SignFieldMsg = "">
          </cfif>
        </cfloop>
      </cfif>
      <cfquery name="qUpd" datasource="#variables.dsn#">
        UPDATE [dbo].[OnboardingDocuments]
        SET [Name] = <cfqueryparam value="#arguments.formStruct.Name#" cfsqltype="cf_sql_varchar">
          ,[Description] = <cfqueryparam value="#arguments.formStruct.Description#" cfsqltype="cf_sql_varchar">
          ,[UpdatedDateTime] = GETDATE()
          ,[UpdateBy] = <cfqueryparam value="#session.adminusername#" cfsqltype="cf_sql_varchar">
          ,[CreateDocFrom] = <cfqueryparam value="#arguments.formStruct.CreateDocFrom#" cfsqltype="cf_sql_integer">
          ,[DocEditorInformation] = <cfqueryparam value="#arguments.formStruct.DocEditorInformation#" cfsqltype="cf_sql_varchar" null="#yesNoFormat(NOT len(trim(arguments.formStruct.DocEditorInformation)))#">
          ,[UploadFileName] = <cfqueryparam value="#arguments.formStruct.UploadFileName#" cfsqltype="cf_sql_varchar" null="#yesNoFormat(NOT len(trim(arguments.formStruct.UploadFileName)))#">
          ,[Active] = <cfqueryparam value="#bitActive#" cfsqltype="cf_sql_bit">
        WHERE ID = <cfqueryparam value="#arguments.formStruct.ID#" cfsqltype="cf_sql_varchar">
      </cfquery>
      <cfset var response = structNew()>
      <cfif len(trim(SignFieldMsg))>
        <cfset response['res']='error'>
        <cfset response['id']=arguments.formStruct.ID>
        <cfset response['msg']="#SignFieldMsg#">
      <cfelse>
        <cfset response['res']='success'>
        <cfset response['id']=arguments.formStruct.ID>
        <cfset response['msg']="Onboarding Doc updated successfully.">
      </cfif>
      <cfreturn response>

      <cfcatch>
        <cfset response['res']='error'>
        <cfset response['msg']='Unable to update doc. Please try again later.'>
        <cfreturn response>
      </cfcatch>
    </cftry>
  </cffunction>

  <cffunction name="DeleteOnboardingDoc" access="public" returntype="struct">
    <cfargument name="ID" type="string" required="yes"/>
    <cfargument name="UploadFileName" type="string" required="no" default=""/>
    <cfargument name="ZohoTemplateID" type="string" required="no" default=""/>
    <cftry>
      <cfif len(trim(arguments.UploadFileName)) and fileExists(expandPath('../fileupload/CarrierDocs/#session.usercompanycode#/#arguments.UploadFileName#'))>
        <cffile action="delete" file="#expandPath('../fileupload/CarrierDocs/#session.usercompanycode#/#arguments.UploadFileName#')#">
      </cfif>

      <cfif len(trim(arguments.ZohoTemplateID))>
        <cfset var auth_token = GetZohoAuthToken()>
        <cfhttp method="put" url="https://sign.zoho.com/api/v1/templates/#trim(arguments.ZohoTemplateID)#/delete" result="objRespDelTemplate">
          <cfhttpparam type="header" name="Authorization" value="Zoho-oauthtoken #auth_token#"/>
        </cfhttp>
      </cfif>

      <cfquery name="qDel" datasource="#variables.dsn#">
        DELETE FROM [dbo].[OnboardingDocuments]
        WHERE ID = <cfqueryparam value="#arguments.ID#" cfsqltype="cf_sql_varchar">
      </cfquery>

      <cfquery name="qrygetCommonDropBox" datasource="#variables.dsn#">
        SELECT ISNULL(DropBoxAccessToken,(SELECT DropBoxAccessToken FROM LoadManagerAdmin.dbo.SystemSetup)) AS DropBoxAccessToken FROM SystemConfig WHERE CompanyID = <cfqueryparam value="#session.companyid#" cfsqltype="cf_sql_varchar">
      </cfquery>
      <cfset tmpStruct = {"path":"/fileupload/img/#session.usercompanycode#/#arguments.UploadFileName#"}>
      <cfhttp
          method="post"
          url="https://api.dropboxapi.com/2/files/delete"
          result="returnStruct">
              <cfhttpparam type="HEADER" name="Authorization" value="Bearer #qrygetCommonDropBox.DropBoxAccessToken#">
              <cfhttpparam type="HEADER" name="Content-Type" value="application/json">
              <cfhttpparam type="body" value="#serializeJSON(tmpStruct)#">
      </cfhttp>
      <cfset var response = structNew()>
      <cfset response['res']='success'>
      <cfset response['msg']="Onboarding Doc deleted successfully.">
      <cfreturn response>

      <cfcatch>
        <cfset response['res']='error'>
        <cfset response['msg']='Unable to delete doc. Please try again later.'>
        <cfreturn response>
      </cfcatch>
    </cftry>
  </cffunction>

  <cffunction name="getOnboardingSettings" access="public" output="false" returntype="query">
    <cfquery name="qGet" datasource="#Application.dsn#">
      SELECT 
        PromptToAddDispatchers,
        PromptToAddDrivers,
        PromptToAddOtherContacts,
        PromptForLanes,
        PromptForELDStatus,
        PromptForCertifications,
        PromptForTruckTrailer,
        PromptForModesofTransportation,
        PromptForPaymentoptions,
        PromptForACHInformation,
        RequireFedTaxID,
        KeepCarrierInactive,
        UserOnBoardingInvite,
        UseEmail,
        RequireBIPDInsurance,
        RequireCargoInsurance,
        RequireGeneralInsurance,
        BIPDMin,
        CargoMin,
        GeneralMin,
        RequireVoidedCheck,
        AllowDownloadAndSubmitManually
      FROM SystemConfigOnboardCarrier WHERE CompanyID = <cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar">
    </cfquery>

    <cfreturn qGet>
  </cffunction>

  <cffunction name="SaveOnboardingSetting" access="public" returntype="struct">
    <cfargument name="formStruct" type="struct" required="yes"/>
    <cftry>
      <cfquery name="qUpd" datasource="#variables.dsn#">
        UPDATE SystemConfigOnboardCarrier
        SET [PromptToAddDispatchers] = <cfif structKeyExists(arguments.formStruct, "PromptToAddDispatchers")>1<cfelse>0</cfif>
        ,[PromptToAddDrivers] = <cfif structKeyExists(arguments.formStruct, "PromptToAddDrivers")>1<cfelse>0</cfif>
        ,[PromptToAddOtherContacts] = <cfif structKeyExists(arguments.formStruct, "PromptToAddOtherContacts")>1<cfelse>0</cfif>
        ,[PromptForLanes] = <cfif structKeyExists(arguments.formStruct, "PromptForLanes")>1<cfelse>0</cfif>

        ,[PromptForELDStatus] = <cfif structKeyExists(arguments.formStruct, "PromptForELDStatus")>1<cfelse>0</cfif>
        ,[PromptForCertifications] = <cfif structKeyExists(arguments.formStruct, "PromptForCertifications")>1<cfelse>0</cfif>
        ,[PromptForTruckTrailer] = <cfif structKeyExists(arguments.formStruct, "PromptForTruckTrailer")>1<cfelse>0</cfif>
        ,[PromptForModesofTransportation] = <cfif structKeyExists(arguments.formStruct, "PromptForModesofTransportation")>1<cfelse>0</cfif>
        ,[PromptForPaymentoptions] = <cfif structKeyExists(arguments.formStruct, "PromptForPaymentoptions")>1<cfelse>0</cfif>
        ,[PromptForACHInformation] = <cfif structKeyExists(arguments.formStruct, "PromptForACHInformation")>1<cfelse>0</cfif>
        ,[KeepCarrierInactive] = <cfif structKeyExists(arguments.formStruct, "KeepCarrierInactive")>1<cfelse>0</cfif>
        ,[RequireFedTaxID] = <cfif structKeyExists(arguments.formStruct, "RequireFedTaxID")>1<cfelse>0</cfif>
        ,[UserOnBoardingInvite] = <cfqueryparam value="#arguments.formStruct.UserOnBoardingInvite#" cfsqltype="cf_sql_varchar"  null="#not len(arguments.formStruct.UserOnBoardingInvite)#">
        ,[UseEmail] = <cfqueryparam value="#arguments.formStruct.UseEmail#" cfsqltype="cf_sql_varchar">
        ,[RequireBIPDInsurance] = <cfif structKeyExists(arguments.formStruct, "RequireBIPDInsurance")>1<cfelse>0</cfif>
        ,[RequireCargoInsurance] = <cfif structKeyExists(arguments.formStruct, "RequireCargoInsurance")>1<cfelse>0</cfif>
        ,[RequireGeneralInsurance] = <cfif structKeyExists(arguments.formStruct, "RequireGeneralInsurance")>1<cfelse>0</cfif>
        <cfif len(trim(ReplaceNoCase(ReplaceNoCase(arguments.formStruct.BIPDMin,',','','ALL'),'$','','ALL'))) AND LSParseCurrency(trim(ReplaceNoCase(ReplaceNoCase(arguments.formStruct.BIPDMin,',','','ALL'),'$','','ALL'))) GT 0>
            ,BIPDMin = <cfqueryparam cfsqltype="cf_sql_real" value="#LSParseCurrency(trim(ReplaceNoCase(ReplaceNoCase(arguments.formStruct.BIPDMin,',','','ALL'),'$','','ALL')))#">
        <cfelse>
            ,BIPDMin = 750000
        </cfif>
        <cfif len(trim(ReplaceNoCase(ReplaceNoCase(arguments.formStruct.CargoMin,',','','ALL'),'$','','ALL'))) AND LSParseCurrency(trim(ReplaceNoCase(ReplaceNoCase(arguments.formStruct.CargoMin,',','','ALL'),'$','','ALL'))) GT 0>
            ,CargoMin = <cfqueryparam cfsqltype="cf_sql_real" value="#LSParseCurrency(trim(ReplaceNoCase(ReplaceNoCase(arguments.formStruct.CargoMin,',','','ALL'),'$','','ALL')))#">
        <cfelse>
            ,CargoMin = 100000
        </cfif>
        <cfif len(trim(ReplaceNoCase(ReplaceNoCase(arguments.formStruct.GeneralMin,',','','ALL'),'$','','ALL'))) AND LSParseCurrency(trim(ReplaceNoCase(ReplaceNoCase(arguments.formStruct.GeneralMin,',','','ALL'),'$','','ALL'))) GT 0>
            ,GeneralMin = <cfqueryparam cfsqltype="cf_sql_real" value="#LSParseCurrency(trim(ReplaceNoCase(ReplaceNoCase(arguments.formStruct.GeneralMin,',','','ALL'),'$','','ALL')))#">
        <cfelse>
            ,GeneralMin = 0
        </cfif>
        ,[RequireVoidedCheck] = <cfif structKeyExists(arguments.formStruct, "voidedCheck")>1<cfelse>0</cfif>
        ,[AllowDownloadAndSubmitManually] = <cfif structKeyExists(arguments.formStruct, "AllowDownloadAndSubmitManually")>1<cfelse>0</cfif>
        WHERE CompanyID = <cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar">
      </cfquery>
      <cfset var response = structNew()>
      <cfset response['res']='success'>
      <cfset response['msg']="Onboarding settings updated successfully.">
      <cfreturn response>

      <cfcatch>
        <cfset response['res']='error'>
        <cfset response['msg']='Unable to update settings. Please try again later.'>
        <cfreturn response>
      </cfcatch>
    </cftry>
  </cffunction>

  <cffunction name="ajxUploadCarrierDoc" access="remote" output="yes" returntype="any" returnformat="json">
    <cftry>
      <cfset resp = structNew()>
      <cfset UploadDir = "#expandPath('../fileupload/CarrierDocs/#session.usercompanycode#/')#">

      <cfif not directoryExists(UploadDir)>
        <cfdirectory action="create" directory="#UploadDir#">
      </cfif>

      <cffile action="upload" fileField="file" nameconflict="MakeUnique" destination="#UploadDir#" result="fileUploaded" accept="application/pdf"> 
      <cfset FileName = "#fileUploaded.serverfile#">
      <cfset tmpStruct = {"path":"/fileupload/img/#session.usercompanycode#/#FileName#","mode":{".tag":"overwrite"},"autorename":false}>
      <cffile action = "readbinary" file = "#UploadDir##FileName#" variable="OnboardDocument">
      
      <cfquery name="qrygetCommonDropBox" datasource="#variables.dsn#">
        SELECT ISNULL(DropBoxAccessToken,(SELECT DropBoxAccessToken FROM LoadManagerAdmin.dbo.SystemSetup)) AS DropBoxAccessToken FROM SystemConfig WHERE CompanyID = <cfqueryparam value="#session.companyid#" cfsqltype="cf_sql_varchar">
      </cfquery>

      <cfhttp method="post" url="https://content.dropboxapi.com/2/files/upload" result="objDropbox"> 
        <cfhttpparam type="HEADER" name="Authorization" value="Bearer #trim(qrygetCommonDropBox.DropBoxAccessToken)#">    
        <cfhttpparam type="HEADER" name="Content-Type" value="application/octet-stream">
        <cfhttpparam type="HEADER" name="Dropbox-API-Arg" value="#serializeJSON(tmpStruct)#">
        <cfhttpparam type="body" value="#OnboardDocument#">
      </cfhttp>
      <cfif trim(objDropbox.Statuscode) EQ "200 OK">
        <cfset resp['success'] = 1>
        <cfset resp['fileName'] = fileUploaded.serverfile>
      <cfelse>
        <cfset resp['success'] = 0>
        <cfset resp['message'] = 'Unable to upload the file.'>
      </cfif>
      <cfreturn resp> 
      <cfcatch>
        <cfset resp['success'] = 0>
        <cfset resp['message'] = 'Unable to upload the file.'>
        <cfreturn resp>
      </cfcatch>
    </cftry>
  </cffunction>

  <cffunction name="GetCarrierPacketURL" access="remote" output="yes" returntype="any" returnformat="json">
    <cfargument name="CarrierID" type="string" required="yes"/>
    <cftry>
      
      <cfquery name="qgetSysConfig" datasource="#variables.dsn#">
        SELECT C.CompanyCode,S.DropBoxAccessToken FROM Companies C 
        INNER JOIN SystemConfig S ON S.CompanyID = C.CompanyID
        WHERE C.CompanyID = <cfqueryparam value="#session.companyid#" cfsqltype="cf_sql_varchar">
      </cfquery>
      
      <cfquery name="qgetFile" datasource="#variables.dsn#">
        SELECT TOP 1 attachmentFileName FROM FileAttachments WHERE attachedFileLabel = 'Carrier Packet' 
        AND linked_Id= <cfqueryparam value="#arguments.CarrierID#" cfsqltype="cf_sql_varchar">
        ORDER BY UploadedDateTime DESC
      </cfquery>

      <cfquery name="qrygetCommonDropBox" datasource="LoadManagerAdmin">
        SELECT 
        <cfif len(trim(qgetSysConfig.DropBoxAccessToken))>
          '#qgetSysConfig.DropBoxAccessToken#'
        <cfelse>
          DropBoxAccessToken 
        </cfif>
        AS DropBoxAccessToken
        FROM SystemSetup
      </cfquery>

      <cfhttp
          method="POST"
          url="https://api.dropboxapi.com/2/sharing/create_shared_link" 
          result="returnStruct"> 
              <cfhttpparam type="HEADER" name="Authorization" value="Bearer #qrygetCommonDropBox.DropBoxAccessToken#">  
              <cfhttpparam type="HEADER" name="Content-Type" value="application/json">  
              <cfhttpparam type="body" value='{"path":#SerializeJSON('/fileupload/img/#qgetSysConfig.CompanyCode#/#qgetFile.attachmentFileName#')#}'>
      </cfhttp> 
      <cfset filePath = "">
      <cfif returnStruct.Statuscode EQ "200 OK">
        <cfset filePath = deserializeJSON(returnStruct.fileContent).url.Split('\?')[1] & '?raw=1'>
        <cfset resp['success'] = 1>
        <cfset resp['url'] = filePath>
        <cfreturn resp> 
      <cfelse>
        <cfset resp['success'] = 0>
        <cfreturn resp>
      </cfif> 
      <cfcatch>
        <cfset resp['success'] = 0>
        <cfreturn resp>
      </cfcatch>
    </cftry>
  </cffunction>

  <cffunction name="GetZohoAuthToken" access="public" returntype="string">
    <cfhttp method="post" url="https://accounts.zoho.com/oauth/v2/token" result="objRespAccessToken">
      <cfhttpparam type="url" name="refresh_token" value="1000.2cea9b0735011dad98cc3479f1734f48.980caac236c9085dfa9bc0aad5ee444a"/>
      <cfhttpparam type="url" name="client_id" value="1000.KW1ZX4LDG0LMC6OC4V3BJZ57Z03AEZ"/>
      <cfhttpparam type="url" name="client_secret" value="df1e7797a0b17ef9cab6a5d827da89a479238734ac"/>
      <cfhttpparam type="url" name="grant_type" value="refresh_token"/>
    </cfhttp>
    <cfset var structRespAccessToken = deserializeJSON(objRespAccessToken.filecontent)>
    <cfset var auth_token = structRespAccessToken.access_token>
    <cfreturn auth_token>
  </cffunction>

  <cffunction name="CreateZohoTemplate" access="public" returntype="struct">
    <cfargument name="TemplateName" type="string" required="yes"/>
    <cfargument name="FileName" type="string" required="yes"/>

    <cfset var auth_token = GetZohoAuthToken()>
      
    <cfset var reqData = structNew()>

    <cfset var templates = structNew()>
    <cfset templates["template_name"] = arguments.TemplateName>
    <cfset templates["request_type_id"] = 101691000000000135>
    <cfset templates["expiration_days"] = 15>
    <cfset templates["is_sequential"] = true>
    <cfset templates["reminder_period"] = 5>
    <cfset templates["email_reminders"] = true>

    <cfset var actions = arrayNew(1)>
    <cfset var actiondetail = structNew()>
    <cfset actiondetail["action_type"] = "SIGN">
    <cfset actiondetail["signing_order"] = 1>
    <cfset actiondetail["recipient_name"] = "">
    <cfset actiondetail["role"] = "Partner/Client">
    <cfset actiondetail["recipient_email"] = "">
    <cfset actiondetail["recipient_phonenumber"] = "">
    <cfset actiondetail["recipient_countrycode"] = "">
    <cfset actiondetail["private_notes"] = "">
    <cfset actiondetail["verify_recipient"] = false>

    <cfset arrayAppend(actions, actiondetail)>
    <cfset templates["actions"] = actions>
    <cfset reqData["templates"] = templates>

    <cfset var UploadDir = "#expandPath('../fileupload/CarrierDocs/#session.usercompanycode#/')#">

    <cfhttp method="post" url="https://sign.zoho.com/api/v1/templates" result="objRespCreateTemplate">
      <cfhttpparam type="header" name="Authorization" value="Zoho-oauthtoken #auth_token#"/>
      <cfhttpparam type="file" name="file" file="#UploadDir##arguments.FileName#"/>
      <cfhttpparam type="formfield" name="data" value="#serializeJSON(reqData)#"/>
    </cfhttp>
    <cfset structResp = deserializeJSON(objRespCreateTemplate.Filecontent)>
    <cfset var response = structNew()>
    <cfset response['TemplateID']=structResp.templates.template_id>
    <cfset response['ActionID']=structResp.templates.actions[1].action_id>
    <cfset response['DocumentID']=structResp.templates.document_ids[1].document_id>
    <cffile action="delete" file="#UploadDir#/#arguments.FileName#">
    <cfreturn response>
  </cffunction>

  <cffunction name="SaveTemplateFields" access="public" returntype="boolean">
    <cfargument name="frmStruct" type="struct" required="yes"/>

    <cfset var auth_token = GetZohoAuthToken()>
    <cfquery name="qGetDoc" datasource="#variables.dsn#">
      SELECT ZohoDocumentID,ZohoTemplateID,ZohoActionID,Active FROM OnboardingDocuments WHERE ID = <cfqueryparam value="#arguments.frmStruct.ID#" cfsqltype="cf_sql_varchar">
    </cfquery>

    <cfset var templateActive = 0>
    <cfset var structFields = deserializeJSON(form.TemplateFields)>
    <cfset var reqData = structNew()>
    <cfset var templates = structNew()>

    <cfset var actions = arrayNew(1)>
    <cfset var actiondetail = structNew()>
    <cfset actiondetail["action_id"] = qGetDoc.ZohoActionID>
    <cfset actiondetail["action_type"] = "SIGN">
    <cfset actiondetail["signing_order"] = 1>
    <cfset actiondetail["recipient_name"] = "">
    <cfset actiondetail["role"] = "Partner/Client">
    <cfset actiondetail["recipient_email"] = "">
    <cfset actiondetail["recipient_phonenumber"] = "">
    <cfset actiondetail["recipient_countrycode"] = "">
    <cfset actiondetail["private_notes"] = "">
    <cfset actiondetail["verify_recipient"] = false>
    <cfset var deleted_fields = arrayNew(1)>
    <cfset var deleted_radio_fields = arrayNew(1)>
    <cfif len(trim(arguments.frmStruct.del_fields))>
      <cfloop list="#arguments.frmStruct.del_fields#" item="del">
        <cfset arrayappend(deleted_fields,del)>
      </cfloop>
    </cfif>
    <cfset actiondetail["deleted_fields"] = deleted_fields>
    <cfset actiondetail["deleted_radio_fields"] = deleted_radio_fields>

    <cfset var fields = structNew()>
    
    <cfset var text_fields = arrayNew(1)>
    <cfset var image_fields = arrayNew(1)>
    <cfset var date_fields = arrayNew(1)>
    <cfset var check_boxes = arrayNew(1)>
    <cfset var radio_groups = arrayNew(1)>

    <cfset var text_property = structNew()>
    <cfset text_property["font"] = "Arial">
    <cfset text_property["font_size"] = 11>
    <cfset text_property["font_color"] = "000000">
    <cfset text_property["is_bold"] = false>
    <cfset text_property["is_italic"] = false>

    <cfloop array="#structFields#" item="field">
        <cfset var tempStruct = structNew()>
        <cfif len(trim(field.field_id))>
          <cfset tempStruct["field_id"] = field.field_id>
        </cfif>
        <cfset tempStruct["field_type_name"] = field.field_type_name> 
        <cfset tempStruct["field_name"] = field.field_name> 
        <cfset tempStruct["document_id"] = qGetDoc.ZohoDocumentID> 
        <cfif field.is_mandatory EQ "YES">
          <cfset tempStruct["is_mandatory"] = true>
        <cfelse>
          <cfset tempStruct["is_mandatory"] = false>  
        </cfif>
        <cfset tempStruct["page_no"] = field.page_no>
        <cfset tempStruct["x_coord"] = field.x_coord>
        <cfset tempStruct["y_coord"] = field.y_coord>
        <cfset tempStruct["abs_width"] = field.abs_width>
        <cfset tempStruct["abs_height"] = field.abs_height>
        <cfif listFindNoCase("Textfield,Company,Name", field.field_type_name)>
          <cfset tempStruct["text_property"] = text_property>
          <cfset arrayAppend(text_fields, tempStruct)>
        <cfelseif field.field_type_name EQ 'Signature'>
          <cfset templateActive = 1>
          <cfset arrayAppend(image_fields, tempStruct)>
        <cfelseif field.field_type_name EQ 'Initial'>
          <cfset arrayAppend(image_fields, tempStruct)>
        <cfelseif listFindNoCase("Date,CustomDate", field.field_type_name)>
          <cfset tempStruct["text_property"] = text_property>
          <cfset arrayAppend(date_fields, tempStruct)>
        <cfelseif field.field_type_name EQ 'Checkbox'>
          <cfset arrayAppend(check_boxes, tempStruct)>
        <cfelseif field.field_type_name EQ 'Radio'>

          <cfscript>
            arrayIndex = ArrayFind(radio_groups, function(struct){ 
              return struct.field_name == field.radGroupName; 
            });
          </cfscript>
          
          <cfset sub_fields_struct = structNew()>
          <cfset sub_fields_struct["default_value"] = false>
          <cfset sub_fields_struct["height"] = 1.515573>
          <cfset sub_fields_struct["page_no"] = field.page_no>
          <cfset sub_fields_struct["sub_field_name"] = field.field_name>
          <cfset sub_fields_struct["width"] = 1.960784>
          <cfset sub_fields_struct["x_value"] = field.x_coord>
          <cfset sub_fields_struct["y_value"] = field.y_coord>

          <cfif arrayIndex EQ 0>
            <cfset sub_fields = arrayNew(1)>
            <cfset arrayAppend(sub_fields, sub_fields_struct)>
            <cfset tempStruct["sub_fields"] = sub_fields>
            <cfset structDelete(tempStruct, "abs_height")>
            <cfset structDelete(tempStruct, "abs_width")>
            <cfset structDelete(tempStruct, "x_coord")>
            <cfset structDelete(tempStruct, "y_coord")>
            <cfset tempStruct["field_type_name"] = "Radiogroup"> 
            <cfset tempStruct["field_name"] = field.radGroupName>
            <cfset arrayAppend(radio_groups, tempStruct)>
          <cfelse>
            <cfset arrayAppend(radio_groups[arrayIndex].sub_fields, sub_fields_struct)>
          </cfif>
        </cfif>
    </cfloop>

    <cfset fields["text_fields"] = text_fields>
    <cfset fields["image_fields"] = image_fields>
    <cfset fields["date_fields"] = date_fields>
    <cfset fields["check_boxes"] = check_boxes>
    <cfset fields["radio_groups"] = radio_groups>

    <cfset actiondetail["fields"] = fields>
    <cfset arrayAppend(actions, actiondetail)>
    <cfset templates["actions"] = actions>
    <cfset reqData["templates"] = templates>

    <cfhttp method="put" url="https://sign.zoho.com/api/v1/templates/#qGetDoc.ZohoTemplateID#" result="objRespTemplatesFields" timeout="600">
      <cfhttpparam type="header" name="Authorization" value="Zoho-oauthtoken #auth_token#"/>
      <cfhttpparam type="formfield" name="data" value="#serializeJSON(reqData)#"/>
    </cfhttp>
    
    <cfif qGetDoc.Active NEQ templateActive>
      <cfquery name="qUpdDoc" datasource="#variables.dsn#">
        UPDATE OnboardingDocuments SET Active = <cfqueryparam value="#templateActive#" cfsqltype="cf_sql_bit"> WHERE ID = <cfqueryparam value="#arguments.frmStruct.ID#" cfsqltype="cf_sql_varchar">
      </cfquery>
      <cfreturn 1>
    <cfelse>
      <cfreturn 0>
    </cfif>
    
  </cffunction>

  <cffunction name="getOnBoardEquipments" access="public" output="false" returntype="query">
    <cfargument name="searchText" required="yes" type="any" default="">
    <cfargument name="pageNo" required="yes" type="any" default="-1">
    <cfargument name="sortorder" required="no" type="any" default="ASC">
    <cfargument name="sortby" required="no" type="any" default="E.EquipmentCode">

    <cfquery name="qEquipments" datasource="#Application.dsn#">
      <cfif arguments.pageNo neq -1>WITH page AS (</cfif>
        SELECT 
          E.EquipmentID,
          E.EquipmentCode,
          E.EquipmentName,
          E.EquipmentType,
          E.Length,
          E.Width,
          E.IsActive,
          E.Temperature,
          E.TemperatureScale,
          E.ShowCarrierOnboarding,
          ROW_NUMBER() OVER (ORDER BY #arguments.sortBy#  #arguments.sortOrder#) AS Row
        FROM Equipments E
        WHERE E.Companyid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#session.CompanyID#">
      <cfif isDefined("arguments.searchText") and len(arguments.searchText)>
        AND 
        (
          E.EquipmentCode like <cfqueryparam cfsqltype="cf_sql_varchar" value="%#arguments.searchText#%">
          OR E.EquipmentName like <cfqueryparam cfsqltype="cf_sql_varchar" value="%#arguments.searchText#%">
          OR E.EquipmentType like <cfqueryparam cfsqltype="cf_sql_varchar" value="%#arguments.searchText#%">
        )
      </cfif>
      <cfif arguments.pageNo neq -1>
        )
        SELECT * FROM page WHERE Row between (<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.pageNo#"> - 1) * 30 + 1 and <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.pageNo#">  * 30
      </cfif>
    </cfquery>
    <cfreturn qEquipments>
  </cffunction>

  <cffunction name="SetEquipmentOnBoard" access="public" returntype="void">
    <cfargument name="EquipmentID" type="string" required="yes"/>
    <cfargument name="ShowCarrierOnboarding" type="string" required="yes"/>
    <cfquery name="qUpd" datasource="#Application.dsn#">
      UPDATE Equipments SET ShowCarrierOnboarding = <cfqueryparam cfsqltype="cf_sql_bit" value="#arguments.ShowCarrierOnboarding#"> WHERE EquipmentID IN (<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.EquipmentID#" list="yes">)
    </cfquery>

  </cffunction>

  <cffunction name="getCarrierDocsForVerification" access="public" returntype="query">
    <cfargument name="CarrierID" type="string" required="yes"/>

    <cfquery name="qGet" datasource="#Application.dsn#">
      SELECT FA.attachmentFileName,FA.attachedFileLabel,C.CarrierName,FA.attachment_Id,FA.VerifiedBy,FA.VerifiedDate FROM FileAttachments FA
      INNER JOIN FileAttachmentTypes FAT ON FA.AttachmentTypeID = FAT.AttachmentTypeID
      INNER JOIN Carriers C ON C.CarrierID = FA.linked_Id
      WHERE linked_Id=<cfqueryparam value="#arguments.CarrierID#" cfsqltype="cf_sql_varchar">
      UNION
      SELECT FA.attachmentFileName,FA.attachedFileLabel,C.CarrierName,FA.attachment_Id,FA.VerifiedBy,FA.VerifiedDate FROM FileAttachments FA 
      INNER JOIN Carriers C ON C.CarrierID = FA.linked_Id
      WHERE linked_Id=<cfqueryparam value="#arguments.CarrierID#" cfsqltype="cf_sql_varchar"> AND attachedFileLabel IN ('Signed Onboard Document','Carrier Packet')
    </cfquery>

    <cfreturn qGet>
  </cffunction>

  <cffunction name="checkStatusChange" access="public" returntype="boolean">
    <cfargument name="CarrierID" type="string" required="yes"/>

    <cfquery name="qGetSysOpt" datasource="#Application.dsn#">
      SELECT KeepCarrierInactive FROM SystemConfigOnboardCarrier WHERE CompanyID=<cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar">
    </cfquery>

    <cfif qGetSysOpt.KeepCarrierInactive EQ 0>
      <cfreturn 1>
    </cfif>

    <cfquery name="qGet" datasource="#Application.dsn#">
      SELECT FA.attachment_Id,FA.VerifiedBy FROM FileAttachments FA
      INNER JOIN FileAttachmentTypes FAT ON FA.AttachmentTypeID = FAT.AttachmentTypeID
      INNER JOIN Carriers C ON C.CarrierID = FA.linked_Id
      WHERE linked_Id=<cfqueryparam value="#arguments.CarrierID#" cfsqltype="cf_sql_varchar">
      UNION
      SELECT FA.attachment_Id,FA.VerifiedBy FROM FileAttachments FA 
      INNER JOIN Carriers C ON C.CarrierID = FA.linked_Id
      WHERE linked_Id=<cfqueryparam value="#arguments.CarrierID#" cfsqltype="cf_sql_varchar"> AND attachedFileLabel IN ('Signed Onboard Document','Carrier Packet')
    </cfquery>

    <cfif NOT qGet.recordcount>
      <cfreturn 1>
    <cfelse>
      <cfloop query="qGet">
        <cfif not len(trim(qGet.VerifiedBy))> <cfreturn 0></cfif>
      </cfloop>
    </cfif>
    
    <cfreturn 1>
  </cffunction>

  <cffunction name="unVerifyCarrierDocs" access="public" returntype="void">
    <cfargument name="CarrierID" type="string" required="yes"/>

    <cfquery name="qUpd" datasource="#Application.dsn#">
      UPDATE FileAttachments SET VerifiedBy = NULL,VerifiedDate=NULL WHERE linked_Id = <cfqueryparam value="#arguments.CarrierID#" cfsqltype="cf_sql_varchar">
    </cfquery>
    <cfquery name="qUpdCarr" datasource="#Application.dsn#">
      UPDATE Carriers SET Status = 0
      WHERE CarrierID = <cfqueryparam value="#arguments.CarrierID#" cfsqltype="cf_sql_varchar"> 
    </cfquery>
  </cffunction>

  <cffunction name="VerifyDocument" access="public" returntype="boolean">
    <cfargument name="frmstruct" type="struct" required="yes"/>
  
    <cfquery name="qUpd" datasource="#Application.dsn#">
      UPDATE FileAttachments SET 
      VerifiedBy = <cfqueryparam cfsqltype="cf_sql_varchar"  value="#arguments.frmstruct.VerifiedBy#"  null="#not len(arguments.frmstruct.VerifiedBy)#"> 
      ,VerifiedDate = <cfqueryparam cfsqltype="cf_sql_timestamp" value="#arguments.frmstruct.VerifiedDate#"  null="#not len(arguments.frmstruct.VerifiedDate)#"> 
      WHERE attachment_Id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.frmstruct.AttachmentID#"  null="#not len(arguments.frmstruct.AttachmentID)#"> 
    </cfquery>

    <cfquery name="qGet" datasource="#Application.dsn#">
      SELECT FA.attachment_Id FROM FileAttachments FA
      INNER JOIN FileAttachmentTypes FAT ON FA.AttachmentTypeID = FAT.AttachmentTypeID
      INNER JOIN Carriers C ON C.CarrierID = FA.linked_Id
      WHERE linked_Id=<cfqueryparam value="#arguments.frmstruct.CarrierID#" cfsqltype="cf_sql_varchar">
      AND VerifiedBy IS NULL
      UNION
      SELECT FA.attachment_Id FROM FileAttachments FA 
      INNER JOIN Carriers C ON C.CarrierID = FA.linked_Id
      WHERE linked_Id=<cfqueryparam value="#arguments.frmstruct.CarrierID#" cfsqltype="cf_sql_varchar"> AND attachedFileLabel IN ('Signed Onboard Document','Carrier Packet')
      AND VerifiedBy IS NULL
    </cfquery>
    <cfif qGet.recordcount>
      <cfset var carrierstatus = 0>
    <cfelse>
      <cfset var carrierstatus = 1>
    </cfif> 

    <cfquery name="qUpdCarr" datasource="#Application.dsn#">
      UPDATE Carriers SET Status = <cfqueryparam value="#carrierstatus#" cfsqltype="cf_sql_bit">
      WHERE CarrierID = <cfqueryparam value="#arguments.frmstruct.CarrierID#" cfsqltype="cf_sql_varchar"> 
    </cfquery>

    <cfif carrierstatus EQ 1>
      <cfquery name="qUpdAlert" datasource="#Application.dsn#">
        UPDATE Alerts SET Approved = 1 WHERE TypeID = <cfqueryparam value="#arguments.frmstruct.CarrierID#" cfsqltype="cf_sql_varchar"> AND AssignedType='Parameter' AND AssignedTo='CarrierOnboardingVerifier'
      </cfquery>
    </cfif>
    <cfreturn carrierstatus>
  </cffunction>

  <cffunction name="getCRMCallHistory" access="public" output="false" returntype="query">
    <cfargument name="searchText" required="no" type="any">
     <cfargument name="pageNo" required="no" type="any" default="1">
     <cfargument name="sortorder" required="no" type="any" default="">
     <cfargument name="sortby" required="no" type="any" default="">
  
    <cfquery name="qgetCRMCallHistory" datasource="#Application.dsn#">
      BEGIN WITH page AS 
      (SELECT 
      CN.CRMNoteID,
      CN.NoteUser AS UserName,
      C.CarrierName AS Company,
      CASE WHEN C.CarrierID = C.CRMContactID THEN C.ContactPerson ELSE CC.ContactPerson END AS Contact,
      CN.CreatedDateTime AS [Date],
      C.CRMPhoneNo AS Phone,
      CNT.NoteType AS CallType,
      CAST(CN.Note AS varchar(50)) AS CallNotes,
      C.CRMNextCallDate AS NextCallDate,
      <cfif len(trim(arguments.sortby))>
        ROW_NUMBER() OVER (ORDER BY #arguments.sortby# #arguments.sortorder#) AS Row
        <cfelse>
      ROW_NUMBER() OVER(ORDER BY CN.CreatedDateTime DESC, CN.NoteUser ASC, C.CarrierName ASC) AS Row
      </cfif> 
      FROM Carriers C
      INNER JOIN CarrierCRMNotes CN ON C.CarrierID = CN.CarrierID
      INNER JOIN CRMNoteTypes CNT ON CNT.CRMNoteTypeID = CN.CRMNoteTypeID
      LEFT JOIN CustomerContacts CC ON CC.CustomerContactID = C.CRMContactID
      WHERE C.CompanyID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#session.CompanyID#">
      <cfif structKeyExists(arguments, "searchText") and len(trim(arguments.searchText))>
        AND (CN.NoteUser LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#arguments.searchText#%">
        OR C.CarrierName LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#arguments.searchText#%">
        OR C.ContactPerson LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#arguments.searchText#%">
        OR CC.ContactPerson LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#arguments.searchText#%">
          )
      </cfif>
      )
      SELECT *,(select (max(row)/30) + (CASE WHEN max(row)%30 <> 0 THEN 1 ELSE 0 END)  FROM page) AS TotalPages FROM page WHERE Row BETWEEN (<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.pageNo#"> - 1) * 30 + 1 AND <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.pageNo#"> * 30
      END
    </cfquery>
    <cfreturn qgetCRMCallHistory>
  </cffunction>

  <cffunction name="getCRMCallDetail" access="public" output="false" returntype="query">
    <cfargument name="CRMNoteID" required="yes" type="any">
  
    <cfquery name="qgetCRMCallDetail" datasource="#Application.dsn#">
      SELECT 
      CN.CRMNoteID,
      CN.NoteUser AS UserName,
      C.CarrierName AS Company,
      CASE WHEN C.CarrierID = C.CRMContactID THEN C.ContactPerson ELSE CC.ContactPerson END AS Contact,
      CN.CreatedDateTime AS [Date],
      C.CRMPhoneNo AS Phone,
      CNT.NoteType AS CallType,
      CN.Note AS CallNotes
      FROM CarrierCRMNotes CN 
      INNER JOIN Carriers C ON C.CarrierID = CN.CarrierID
      INNER JOIN CRMNoteTypes CNT ON CNT.CRMNoteTypeID = CN.CRMNoteTypeID
      LEFT JOIN CustomerContacts CC ON CC.CustomerContactID = C.CRMContactID
      WHERE CN.CRMNoteID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.CRMNoteID#">
    </cfquery>
    <cfreturn qgetCRMCallDetail>
  </cffunction>

  <cffunction name="GetCarrierOnBoardLink" access="public" returntype="struct">
    <cfargument name="DOTNumber" type="string" required="yes"/>
    <cfargument name="MCNumber" type="string" required="yes"/>
    <cfargument name="CompanyID" type="string" required="no" default=""/>

    <cfif structKeyExists(arguments, "CompanyID") AND len(trim(arguments.CompanyID))>
      <cfset var local.CompanyID = arguments.CompanyID>
    <cfelse>
      <cfset var local.CompanyID = session.CompanyID>
    </cfif>
    <cfquery name="qSystemSetupOptions" datasource="#variables.dsn#">
      SELECT CarrierLNI
      FROM SystemConfig WHERE CompanyID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#local.CompanyID#">
    </cfquery>

    <cfquery name="qGet" datasource="#Application.dsn#">
      SELECT CarrierID,OnboardStatus FROM Carriers WHERE CompanyID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#local.CompanyID#">
      <cfif len(trim(arguments.DOTNumber))>
        AND DOTNumber = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.DOTNumber#">
      <cfelseif len(trim(arguments.MCNumber))>
        AND MCNumber = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.MCNumber#">
      <cfelse>
        AND 1 = 0
      </cfif>
    </cfquery>
    <cfset respStr = structNew()>
    <cfif qGet.recordcount>
      <cfset respStr.CarrierID = qGet.CarrierID>
      <cfset respStr.OnboardStatus = qGet.OnboardStatus>
      <cfreturn respStr>
    <cfelse>
      <cfif qSystemSetupOptions.CarrierLNI EQ 3>
        <cfinvoke method="createViaSaferWatch" returnvariable="request.CarrierID">
          <cfinvokeargument name="DOTNumber" value="#arguments.DOTNumber#">
          <cfinvokeargument name="MCNumber" value="#arguments.MCNumber#">
          <cfinvokeargument name="CompanyID" value="#local.CompanyID#">
        </cfinvoke>
      <cfelse>
        <cfinvoke method="createViaCarrierLookout" returnvariable="request.CarrierID">
          <cfinvokeargument name="DOTNumber" value="#arguments.DOTNumber#">
          <cfinvokeargument name="MCNumber" value="#arguments.MCNumber#">
          <cfinvokeargument name="CompanyID" value="#local.CompanyID#">
        </cfinvoke>
      </cfif>
      <cfif len(trim(request.CarrierID)) EQ 36>
        <cfset respStr.CarrierID = request.CarrierID>
        <cfset respStr.OnboardStatus = 0>
        <cfreturn respStr>
      <cfelse>
        <cfset respStr.CarrierID = ''>
        <cfset respStr.OnboardStatus = 0>
        <cfreturn respStr>
      </cfif>
    </cfif>
  </cffunction>

  <cffunction name="GetExpiredDocuments" access="public" output="false" returntype="query">
    <cfargument name="CarrierID" required="yes" type="any">
  
    <cfquery name="qGetExpiredDocuments" datasource="#Application.dsn#">
      SELECT FAT.AttachmentTypeID, FAT.Description,C.OnboardStatus FROM FileAttachments FA
      INNER JOIN MultipleFileAttachmentsTypes MAT ON FA.attachment_Id = MAT.AttachmentID
      INNER JOIN FileAttachmentTypes FAT ON FAT.AttachmentTypeID = MAT.AttachmentTypeID
      INNER JOIN Carriers C On C.CarrierID = FA.linked_Id
      WHERE DATEDIFF(month, FA.UploadedDateTime, GETDATE()) >= FAT.Interval
      AND linked_Id =<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.CarrierID#">
      AND C.OnboardStatus <> 4
    </cfquery>

    <cfif qGetExpiredDocuments.recordcount>
      <cfquery name="qUpd" datasource="#Application.dsn#">
        UPDATE Carriers SET Status = 0,OnboardStatus=3 WHERE CarrierID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.CarrierID#">
      </cfquery>
    </cfif>

    <cfreturn qGetExpiredDocuments>
  </cffunction>
  <cffunction name="GetExpiredInsurance" access="public" output="false" returntype="query">
    <cfargument name="CarrierID" required="yes" type="any">
  
    <cfquery name="qGetExpiredInsurance" datasource="#Application.dsn#">
      SELECT attachedFileLabel,InsExpDate FROM FileAttachments
      WHERE InsExpDate < GETDATE() AND (attachedFileLabel = 'InsuranceBIPD' OR attachedFileLabel = 'InsuranceCargo' OR attachedFileLabel = 'InsuranceGeneral')
      AND linked_Id =<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.CarrierID#">
    </cfquery>

    <cfreturn qGetExpiredInsurance>
  </cffunction>

  <cffunction name="CheckCarrierVendorID" access="public" returntype="boolean">
    <cfargument name="VendorID" required="yes" type="any">
    <cfquery name="qGet" datasource="#Application.dsn#">
      SELECT CarrierID FROM Carriers WHERE CompanyID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#session.CompanyID#"> 
      AND VendorID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.VendorID#">
    </cfquery>

    <cfif qGet.recordcount>
      <cfreturn 1>
    <cfelse>
      <cfreturn 0>
    </cfif>
  </cffunction>
</cfcomponent>
