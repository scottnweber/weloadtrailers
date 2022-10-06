<cfcomponent output="true">
	<cffunction name="GetSystemConfig" access="public" returntype="query">
		<cfquery name="qSystemConfig" datasource="#trim(listFirst(cgi.SCRIPT_NAME,'/'))#">
			SELECT
			Carr.ApplyInsuranceToAll AS ApplyToAll 
			,C.CompanyID
			,C.CompanyName
			,C.CompanyCode
			,S.companyLogoName
			,S.BackgroundColor
			,S.BackgroundColorForContent
			,ISNULL(S.DropBoxAccessToken,(SELECT DropBoxAccessToken FROM LoadManagerAdmin.dbo.SystemSetup)) AS DropBoxAccessToken
			,SO.PromptForACHInformation
			,SO.RequireFedTaxID
			,SO.KeepCarrierInactive
			,SO.PromptForELDStatus
			,SO.PromptForCertifications
			,SO.RequireBIPDInsurance
        	,SO.RequireCargoInsurance
        	,SO.RequireGeneralInsurance
        	,SO.BIPDMin
        	,SO.CargoMin
        	,SO.GeneralMin
			,SO.RequireVoidedCheck
			,SO.AllowDownloadAndSubmitManually
			FROM Carriers Carr
			INNER JOIN Companies C ON Carr.CompanyID = C.CompanyID
			INNER JOIN SystemConfig S ON C.CompanyID = S.CompanyID
			INNER JOIN SystemConfigOnboardCarrier SO ON SO.CompanyID = S.CompanyID
			WHERE Carr.CarrierID = <cfqueryparam value="#url.CarrierID#" cfsqltype="cf_sql_varchar">
		</cfquery>
		<cfreturn qSystemConfig>
	</cffunction>

	<cffunction name="GetCompanySystemConfig" access="public" returntype="query">
		<cfquery name="qSystemConfig" datasource="#trim(listFirst(cgi.SCRIPT_NAME,'/'))#">
			SELECT 
			C.CompanyID
			,C.CompanyName
			,C.CompanyCode
			,S.companyLogoName
			,S.BackgroundColor
			,S.BackgroundColorForContent
			,S.DropBoxAccessToken
			,SO.PromptForACHInformation
			,SO.RequireFedTaxID
			,SO.KeepCarrierInactive
			,SO.PromptForELDStatus
			,SO.PromptForCertifications
			,SO.RequireBIPDInsurance
        	,SO.RequireCargoInsurance
        	,SO.RequireGeneralInsurance
        	,SO.BIPDMin
        	,SO.CargoMin
        	,SO.GeneralMin
			,SO.RequireVoidedCheck
			FROM Companies C
			INNER JOIN SystemConfig S ON C.CompanyID = S.CompanyID
			INNER JOIN SystemConfigOnboardCarrier SO ON SO.CompanyID = S.CompanyID
			WHERE C.CompanyID = <cfqueryparam value="#url.CompanyID#" cfsqltype="cf_sql_varchar">
		</cfquery>
		<cfreturn qSystemConfig>
	</cffunction>

	<cffunction name="GetStates" access="public" returntype="query">
		<CFSTOREDPROC PROCEDURE="USP_GetStateDetails" DATASOURCE="#trim(listFirst(cgi.SCRIPT_NAME,'/'))#"> 
			<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCRESULT NAME="qStates"> 
		</CFSTOREDPROC>
		<cfreturn qStates>
	</cffunction>

	<cffunction name="GetCountries" access="public" returntype="query">
		<CFSTOREDPROC PROCEDURE="USP_GetcountryDetails" DATASOURCE="#trim(listFirst(cgi.SCRIPT_NAME,'/'))#"> 
			<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR">  
			<CFPROCRESULT NAME="qCountries"> 
		</CFSTOREDPROC>	
		<cfreturn qCountries>
	</cffunction>

	<cffunction name="GetCarrierInfo" access="public" returntype="query">
		<cfargument name="CarrierID" required="true" type="string">
		<cfquery name="qCarrierInfo" datasource="#trim(listFirst(cgi.SCRIPT_NAME,'/'))#">
			SELECT 
			DOTNumber
			,MCNumber
			,CarrierName
			,TaxID
			,SCAC
			,Address
			,City
			,StateCode
			,ZipCode
			,Country
			,Phone
			,PhoneExt
			,Fax
			,FaxExt
			,TollFree
			,TollfreeExt
			,Cel
			,CellPhoneExt
			,EmailID
			,Website
			,ContactPerson
			,ContactHow
			,CarrierEmailAvailableLoads
			,FactoringID
			,RemitName
			,RemitAddress
			,RemitCity
			,RemitState
			,RemitZipcode
			,RemitContact
			,RemitPhone
			,RemitFax
			,RemitEmail
			FROM Carriers C
			WHERE C.CarrierID = <cfqueryparam value="#arguments.CarrierID#" cfsqltype="cf_sql_varchar" null="#not len(arguments.CarrierID)#">
		</cfquery>
		<cfreturn qCarrierInfo>
	</cffunction>

	<cffunction name="SaveCarrierInfo" access="public" returntype="string">
		<cfargument name="CarrierID" required="true" type="string">
		<cfargument name="FrmStruct" required="true" type="struct">
		<cfset var resCarrierID = arguments.CarrierID>
		<cfif structKeyExists(arguments.FrmStruct,"CarrierEmailAvailableLoads")>
		    <cfset var CarrierEmailAvailableLoads = 1>
		<cfelse>
		    <cfset var CarrierEmailAvailableLoads = 0>
		</cfif>
		<cfif NOT len(trim(arguments.CarrierID))>
			<cfquery name="qGet" datasource="#Application.dsn#">
				SELECT NEWID() AS CarrierID
			</cfquery>
			<cfset resCarrierID = qGet.CarrierID>
			<cfquery name="qInsCarrier" datasource="#Application.dsn#">
	            INSERT INTO Carriers(CarrierID,CompanyID,DOTNumber,MCNumber,CarrierName,VendorID,TaxID,SCAC,Address,City,StateCode,ZipCode,Country,Phone,PhoneExt,Fax,FaxExt,TollFree,TollfreeExt,Cel,CellPhoneExt,EmailID,Website,ContactPerson,ContactHow,CarrierEmailAvailableLoads,RemitName,RemitAddress,RemitCity,RemitState,RemitZipcode,RemitContact,RemitPhone,RemitFax,RemitEmail,IsInsVerified,IsInsDate,IsContractVerified,IsW9,IsReferences,Status,Track1099,IsCarrier,CreatedBy,LastModifiedBy,CreatedDateTime,LastModifiedDateTime
	              )
	            VALUES(
	              	<cfqueryparam value="#qGet.CarrierID#" cfsqltype="cf_sql_varchar">
	              	,<cfqueryparam value="#arguments.FrmStruct.CompanyID#" cfsqltype="cf_sql_varchar">
	              	,<cfqueryparam value="#arguments.FrmStruct.DOTNumber#" cfsqltype="cf_sql_varchar">
					,<cfqueryparam value="#arguments.FrmStruct.MCNumber#" cfsqltype="cf_sql_varchar">
					,<cfqueryparam value="#arguments.FrmStruct.CarrierName#" cfsqltype="cf_sql_varchar">
					,<cfqueryparam value="#Left(ReplaceNoCase(arguments.FrmStruct.CarrierName," ","","ALL"),10)#" cfsqltype="cf_sql_varchar">
					,<cfqueryparam value="#arguments.FrmStruct.TaxID#" cfsqltype="cf_sql_varchar">
					,<cfqueryparam value="#arguments.FrmStruct.SCAC#" cfsqltype="cf_sql_varchar">
					,<cfqueryparam value="#arguments.FrmStruct.Address#" cfsqltype="cf_sql_varchar">
					,<cfqueryparam value="#arguments.FrmStruct.City#" cfsqltype="cf_sql_varchar">
					,<cfqueryparam value="#arguments.FrmStruct.StateCode#" cfsqltype="cf_sql_varchar">
					,<cfqueryparam value="#arguments.FrmStruct.ZipCode#" cfsqltype="cf_sql_varchar">
					,<cfqueryparam value="#arguments.FrmStruct.Country#" cfsqltype="cf_sql_varchar">
					,<cfqueryparam value="#arguments.FrmStruct.Phone#" cfsqltype="cf_sql_varchar">
					,<cfqueryparam value="#arguments.FrmStruct.PhoneExt#" cfsqltype="cf_sql_varchar">
					,<cfqueryparam value="#arguments.FrmStruct.Fax#" cfsqltype="cf_sql_varchar">
					,<cfqueryparam value="#arguments.FrmStruct.FaxExt#" cfsqltype="cf_sql_varchar">
					,<cfqueryparam value="#arguments.FrmStruct.TollFree#" cfsqltype="cf_sql_varchar">
					,<cfqueryparam value="#arguments.FrmStruct.TollfreeExt#" cfsqltype="cf_sql_varchar">
					,<cfqueryparam value="#arguments.FrmStruct.Cel#" cfsqltype="cf_sql_varchar">
					,<cfqueryparam value="#arguments.FrmStruct.CellPhoneExt#" cfsqltype="cf_sql_varchar">
					,<cfqueryparam value="#arguments.FrmStruct.EmailID#" cfsqltype="cf_sql_varchar">
					,<cfqueryparam value="#arguments.FrmStruct.Website#" cfsqltype="cf_sql_varchar">
					,<cfqueryparam value="#arguments.FrmStruct.ContactPerson#" cfsqltype="cf_sql_varchar">
					,<cfqueryparam value="#arguments.FrmStruct.ContactHow#" cfsqltype="cf_sql_integer">
					,<cfqueryparam value="#CarrierEmailAvailableLoads#" cfsqltype="cf_sql_bit">
					,<cfqueryparam value="#arguments.FrmStruct.RemitName#" cfsqltype="cf_sql_varchar">
					,<cfqueryparam value="#arguments.FrmStruct.RemitAddress#" cfsqltype="cf_sql_varchar">
					,<cfqueryparam value="#arguments.FrmStruct.RemitCity#" cfsqltype="cf_sql_varchar">
					,<cfqueryparam value="#arguments.FrmStruct.RemitState#" cfsqltype="cf_sql_varchar">
					,<cfqueryparam value="#arguments.FrmStruct.RemitZipcode#" cfsqltype="cf_sql_varchar">
					,<cfqueryparam value="#arguments.FrmStruct.RemitContact#" cfsqltype="cf_sql_varchar">
					,<cfqueryparam value="#arguments.FrmStruct.RemitPhone#" cfsqltype="cf_sql_varchar">
					,<cfqueryparam value="#arguments.FrmStruct.RemitFax#" cfsqltype="cf_sql_varchar">
					,<cfqueryparam value="#arguments.FrmStruct.RemitEmail#" cfsqltype="cf_sql_varchar">
					,0,0,0,0,0,1,1,1 
					,<cfqueryparam value="#arguments.FrmStruct.CarrierName#" cfsqltype="cf_sql_varchar">
					,<cfqueryparam value="#arguments.FrmStruct.CarrierName#" cfsqltype="cf_sql_varchar">
					,getdate()
					,getdate()
	            )
	          </cfquery>
		<cfelse>
			<cfquery name="qCarrierUpdate" datasource="#trim(listFirst(cgi.SCRIPT_NAME,'/'))#">
				UPDATE Carriers SET 
				<cfif isDefined('arguments.FrmStruct.DOTNumber')>
					DOTNumber = <cfqueryparam value="#arguments.FrmStruct.DOTNumber#" cfsqltype="cf_sql_varchar">
				<cfelse>
					DOTNumber = <cfqueryparam value="" cfsqltype="cf_sql_varchar">
				</cfif>
				<cfif isDefined('arguments.FrmStruct.MCNumber')>
					,MCNumber = <cfqueryparam value="#arguments.FrmStruct.MCNumber#" cfsqltype="cf_sql_varchar">
				<cfelse>
					,MCNumber = <cfqueryparam value="" cfsqltype="cf_sql_varchar">
				</cfif>
				,CarrierName = <cfqueryparam value="#arguments.FrmStruct.CarrierName#" cfsqltype="cf_sql_varchar">
				,TaxID = <cfqueryparam value="#arguments.FrmStruct.TaxID#" cfsqltype="cf_sql_varchar">
				,SCAC = <cfqueryparam value="#arguments.FrmStruct.SCAC#" cfsqltype="cf_sql_varchar">
				,Address = <cfqueryparam value="#arguments.FrmStruct.Address#" cfsqltype="cf_sql_varchar">
				,City = <cfqueryparam value="#arguments.FrmStruct.City#" cfsqltype="cf_sql_varchar">
				,StateCode = <cfqueryparam value="#arguments.FrmStruct.StateCode#" cfsqltype="cf_sql_varchar">
				,ZipCode = <cfqueryparam value="#arguments.FrmStruct.ZipCode#" cfsqltype="cf_sql_varchar">
				,Country = <cfqueryparam value="#arguments.FrmStruct.Country#" cfsqltype="cf_sql_varchar">
				,Phone = <cfqueryparam value="#arguments.FrmStruct.Phone#" cfsqltype="cf_sql_varchar">
				,PhoneExt = <cfqueryparam value="#arguments.FrmStruct.PhoneExt#" cfsqltype="cf_sql_varchar">
				,Fax = <cfqueryparam value="#arguments.FrmStruct.Fax#" cfsqltype="cf_sql_varchar">
				,FaxExt = <cfqueryparam value="#arguments.FrmStruct.FaxExt#" cfsqltype="cf_sql_varchar">
				,TollFree = <cfqueryparam value="#arguments.FrmStruct.TollFree#" cfsqltype="cf_sql_varchar">
				,TollfreeExt = <cfqueryparam value="#arguments.FrmStruct.TollfreeExt#" cfsqltype="cf_sql_varchar">
				,Cel = <cfqueryparam value="#arguments.FrmStruct.Cel#" cfsqltype="cf_sql_varchar">
				,CellPhoneExt = <cfqueryparam value="#arguments.FrmStruct.CellPhoneExt#" cfsqltype="cf_sql_varchar">
				,EmailID = <cfqueryparam value="#arguments.FrmStruct.EmailID#" cfsqltype="cf_sql_varchar">
				,Website = <cfqueryparam value="#arguments.FrmStruct.Website#" cfsqltype="cf_sql_varchar">
				,ContactPerson = <cfqueryparam value="#arguments.FrmStruct.ContactPerson#" cfsqltype="cf_sql_varchar">
				,ContactHow = <cfqueryparam value="#arguments.FrmStruct.ContactHow#" cfsqltype="cf_sql_integer">
				,CarrierEmailAvailableLoads = <cfqueryparam value="#CarrierEmailAvailableLoads#" cfsqltype="cf_sql_bit">
				,RemitName = <cfqueryparam value="#arguments.FrmStruct.RemitName#" cfsqltype="cf_sql_varchar">
				,RemitAddress = <cfqueryparam value="#arguments.FrmStruct.RemitAddress#" cfsqltype="cf_sql_varchar">
				,RemitCity = <cfqueryparam value="#arguments.FrmStruct.RemitCity#" cfsqltype="cf_sql_varchar">
				,RemitState = <cfqueryparam value="#arguments.FrmStruct.RemitState#" cfsqltype="cf_sql_varchar">
				,RemitZipcode = <cfqueryparam value="#arguments.FrmStruct.RemitZipcode#" cfsqltype="cf_sql_varchar">
				,RemitContact = <cfqueryparam value="#arguments.FrmStruct.RemitContact#" cfsqltype="cf_sql_varchar">
				,RemitPhone = <cfqueryparam value="#arguments.FrmStruct.RemitPhone#" cfsqltype="cf_sql_varchar">
				,RemitFax = <cfqueryparam value="#arguments.FrmStruct.RemitFax#" cfsqltype="cf_sql_varchar">
				,RemitEmail = <cfqueryparam value="#arguments.FrmStruct.RemitEmail#" cfsqltype="cf_sql_varchar">
				WHERE CarrierID = <cfqueryparam value="#arguments.CarrierID#" cfsqltype="cf_sql_varchar">
			</cfquery>
		</cfif>
		<cfreturn resCarrierID>
	</cffunction>

	<cffunction name="GetCarrierInsuranceInfo" access="public" returntype="query">
		<cfargument name="CarrierID" required="true" type="string">
		<cfquery name="qCarrierInsuranceInfo" datasource="#trim(listFirst(cgi.SCRIPT_NAME,'/'))#">
			SELECT 
			C.InsCompany,C.InsCompPhone,C.InsAgent,C.InsAgentPhone,C.InsEmail,Ins.InsuranceCompanyAddress,C.InsPolicyNumber,C.InsExpDate,C.InsLimit,Ins.householdGoods
			,C.InsCompanyCargo,C.InsCompPhoneCargo,C.InsAgentCargo,C.InsAgentPhoneCargo,C.InsEmailCargo,Ins.InsuranceCompanyAddressCargo,C.InsPolicyNumberCargo,C.InsExpDateCargo,C.InsLimitCargo,Ins.householdGoodsCargo
			,C.InsCompanyGeneral,C.InsCompPhoneGeneral,C.InsAgentGeneral,C.InsAgentPhoneGeneral,C.InsEmailGeneral,Ins.InsuranceCompanyAddressGeneral,C.InsPolicyNumberGeneral,C.InsExpDateGeneral,C.InsLimitGeneral,Ins.householdGoodsGeneral
			FROM Carriers C
			LEFT JOIN lipublicfmcsa Ins ON Ins.CarrierID = C.CarrierID
			WHERE C.CarrierID = <cfqueryparam value="#arguments.CarrierID#" cfsqltype="cf_sql_varchar">
		</cfquery>
		<cfreturn qCarrierInsuranceInfo>
	</cffunction>

	<cffunction name="SaveCarrierInsurance" access="public" returntype="void">
		<cfargument name="CarrierID" required="true" type="string">
		<cfargument name="FrmStruct" required="true" type="struct">
		<cfif structkeyexists(arguments.FrmStruct,"ApplyToAll")>
			<cfset ApplyToAll = 1>
		<cfelse>
			<cfset ApplyToAll = 0>
		</cfif>

		<cfquery name="qCarrierUpdate" datasource="#trim(listFirst(cgi.SCRIPT_NAME,'/'))#">
			UPDATE Carriers SET 
			InsCompany = <cfqueryparam value="#arguments.FrmStruct.InsCompany#" cfsqltype="cf_sql_varchar">
			,InsCompPhone = <cfqueryparam value="#arguments.FrmStruct.InsCompPhone#" cfsqltype="cf_sql_varchar">
			,InsAgent = <cfqueryparam value="#arguments.FrmStruct.InsAgent#" cfsqltype="cf_sql_varchar">
			,InsAgentPhone = <cfqueryparam value="#arguments.FrmStruct.InsAgentPhone#" cfsqltype="cf_sql_varchar">
			,InsEmail = <cfqueryparam value="#arguments.FrmStruct.InsEmail#" cfsqltype="cf_sql_varchar">
			,InsPolicyNumber = <cfqueryparam value="#arguments.FrmStruct.InsPolicyNumber#" cfsqltype="cf_sql_varchar">
			<cfif isValid("date", arguments.FrmStruct.InsExpDate)>
				,InsExpDate = <cfqueryparam value="#arguments.FrmStruct.InsExpDate#" cfsqltype="cf_sql_date">
			</cfif>
			<cfif len(trim(ReplaceNoCase(ReplaceNoCase(arguments.FrmStruct.InsLimit,',','','ALL'),'$','','ALL'))) AND LSParseCurrency(trim(ReplaceNoCase(ReplaceNoCase(arguments.FrmStruct.InsLimit,',','','ALL'),'$','','ALL'))) GT 0>
		      	,InsLimit = <cfqueryparam cfsqltype="cf_sql_real" value="#LSParseCurrency(trim(ReplaceNoCase(ReplaceNoCase(arguments.FrmStruct.InsLimit,',','','ALL'),'$','','ALL')))#">
		    <cfelse>
		      	,InsLimit = 0
		    </cfif>

			,InsCompanyCargo = <cfqueryparam value="#arguments.FrmStruct.InsCompanyCargo#" cfsqltype="cf_sql_varchar">
			,InsCompPhoneCargo = <cfqueryparam value="#arguments.FrmStruct.InsCompPhoneCargo#" cfsqltype="cf_sql_varchar">
			,InsAgentCargo = <cfqueryparam value="#arguments.FrmStruct.InsAgentCargo#" cfsqltype="cf_sql_varchar">
			,InsAgentPhoneCargo = <cfqueryparam value="#arguments.FrmStruct.InsAgentPhoneCargo#" cfsqltype="cf_sql_varchar">
			,InsEmailCargo = <cfqueryparam value="#arguments.FrmStruct.InsEmailCargo#" cfsqltype="cf_sql_varchar">
			,InsPolicyNumberCargo = <cfqueryparam value="#arguments.FrmStruct.InsPolicyNumberCargo#" cfsqltype="cf_sql_varchar">
			<cfif isValid("date", arguments.FrmStruct.InsExpDateCargo)>
				,InsExpDateCargo = <cfqueryparam value="#arguments.FrmStruct.InsExpDateCargo#" cfsqltype="cf_sql_date">
			</cfif>
			<cfif len(trim(ReplaceNoCase(ReplaceNoCase(arguments.FrmStruct.InsLimitCargo,',','','ALL'),'$','','ALL'))) AND LSParseCurrency(trim(ReplaceNoCase(ReplaceNoCase(arguments.FrmStruct.InsLimitCargo,',','','ALL'),'$','','ALL'))) GT 0>
		      	,InsLimitCargo = <cfqueryparam cfsqltype="cf_sql_real" value="#LSParseCurrency(trim(ReplaceNoCase(ReplaceNoCase(arguments.FrmStruct.InsLimitCargo,',','','ALL'),'$','','ALL')))#">
		    <cfelse>
		      	,InsLimitCargo = 0
		    </cfif>

			,InsCompanyGeneral = <cfqueryparam value="#arguments.FrmStruct.InsCompanyGeneral#" cfsqltype="cf_sql_varchar">
			,InsCompPhoneGeneral = <cfqueryparam value="#arguments.FrmStruct.InsCompPhoneGeneral#" cfsqltype="cf_sql_varchar">
			,InsAgentGeneral = <cfqueryparam value="#arguments.FrmStruct.InsAgentGeneral#" cfsqltype="cf_sql_varchar">
			,InsAgentPhoneGeneral = <cfqueryparam value="#arguments.FrmStruct.InsAgentPhoneGeneral#" cfsqltype="cf_sql_varchar">
			,InsEmailGeneral = <cfqueryparam value="#arguments.FrmStruct.InsEmailGeneral#" cfsqltype="cf_sql_varchar">
			,InsPolicyNumberGeneral = <cfqueryparam value="#arguments.FrmStruct.InsPolicyNumberGeneral#" cfsqltype="cf_sql_varchar">
			<cfif isValid("date", arguments.FrmStruct.InsExpDateGeneral)>
				,InsExpDateGeneral = <cfqueryparam value="#arguments.FrmStruct.InsExpDateGeneral#" cfsqltype="cf_sql_date">
			</cfif>
			<cfif len(trim(ReplaceNoCase(ReplaceNoCase(arguments.FrmStruct.InsLimitGeneral,',','','ALL'),'$','','ALL'))) AND LSParseCurrency(trim(ReplaceNoCase(ReplaceNoCase(arguments.FrmStruct.InsLimitGeneral,',','','ALL'),'$','','ALL'))) GT 0>
		      	,InsLimitGeneral = <cfqueryparam cfsqltype="cf_sql_real" value="#LSParseCurrency(trim(ReplaceNoCase(ReplaceNoCase(arguments.FrmStruct.InsLimitGeneral,',','','ALL'),'$','','ALL')))#">
		    <cfelse>
		      	,InsLimitGeneral = 0
		    </cfif>
			,ApplyInsuranceToAll = <cfqueryparam value="#ApplyToAll#" cfsqltype="cf_sql_bit">
			WHERE CarrierID = <cfqueryparam value="#arguments.CarrierID#" cfsqltype="cf_sql_varchar">
		</cfquery>

		<cfquery name="qCarrierUpdateInsurance" datasource="#trim(listFirst(cgi.SCRIPT_NAME,'/'))#">
			IF(SELECT COUNT(ID) FROM lipublicfmcsa WHERE CarrierID = <cfqueryparam value="#arguments.CarrierID#" cfsqltype="cf_sql_varchar">) <> 0
			BEGIN
				UPDATE lipublicfmcsa SET
				InsuranceCompanyAddress = <cfqueryparam value="#arguments.FrmStruct.InsuranceCompanyAddress#" cfsqltype="cf_sql_varchar">
				,householdGoods = <cfqueryparam value="#arguments.FrmStruct.householdGoods#" cfsqltype="cf_sql_bit">
				,InsuranceCompanyAddressCargo = <cfqueryparam value="#arguments.FrmStruct.InsuranceCompanyAddressCargo#" cfsqltype="cf_sql_varchar">
				,householdGoodsCargo = <cfqueryparam value="#arguments.FrmStruct.householdGoodsCargo#" cfsqltype="cf_sql_bit">
				,InsuranceCompanyAddressGeneral = <cfqueryparam value="#arguments.FrmStruct.InsuranceCompanyAddressGeneral#" cfsqltype="cf_sql_varchar">
				,householdGoodsGeneral = <cfqueryparam value="#arguments.FrmStruct.householdGoodsGeneral#" cfsqltype="cf_sql_bit">
				WHERE CarrierID = <cfqueryparam value="#arguments.CarrierID#" cfsqltype="cf_sql_varchar">
			END
			ELSE 
			BEGIN
				INSERT INTO lipublicfmcsa (CarrierID,InsuranceCompanyAddress,householdGoods,InsuranceCompanyAddressCargo,householdGoodsCargo,InsuranceCompanyAddressGeneral,householdGoodsGeneral,DateCreated,commonStatus,contractStatus,brokerStatus,commonAppPending,contractAppPending,BrokerAppPending,BIPDInsRequired,cargoInsRequired,BIPDInsonFile,cargoInsonFile)
				VALUES(
					<cfqueryparam value="#arguments.CarrierID#" cfsqltype="cf_sql_varchar">
					,<cfqueryparam value="#arguments.FrmStruct.InsuranceCompanyAddress#" cfsqltype="cf_sql_varchar">
					,<cfqueryparam value="#arguments.FrmStruct.householdGoods#" cfsqltype="cf_sql_bit">
					,<cfqueryparam value="#arguments.FrmStruct.InsuranceCompanyAddressCargo#" cfsqltype="cf_sql_varchar">
					,<cfqueryparam value="#arguments.FrmStruct.householdGoodsCargo#" cfsqltype="cf_sql_bit">
					,<cfqueryparam value="#arguments.FrmStruct.InsuranceCompanyAddressGeneral#" cfsqltype="cf_sql_varchar">
					,<cfqueryparam value="#arguments.FrmStruct.householdGoodsGeneral#" cfsqltype="cf_sql_bit">
					,GETDATE()
					,0,0,0,0,0,0,0,0,0,0
					)
			END
		</cfquery>
	</cffunction>

	<cffunction name="AddCarrierContact" access="public" returntype="void">
		<cfargument name="CarrierID" required="true" type="string">
		<cfargument name="FrmStruct" required="true" type="struct">

		<cfloop from="1" to="#arguments.FrmStruct.TotalCount#" index="i">
			<cfset local.CarrierContactID = arguments.FrmStruct["ContactID_#i#"]>
			<cfset local.ContactPerson = arguments.FrmStruct["ContactPerson_#i#"]>
			<cfset local.PhoneNo = arguments.FrmStruct["PhoneNo_#i#"]>
			<cfset local.PhoneNoExt = arguments.FrmStruct["PhoneNoExt_#i#"]>
			<cfset local.Fax = arguments.FrmStruct["Fax_#i#"]>
			<cfset local.FaxExt = arguments.FrmStruct["FaxExt_#i#"]>
			<cfset local.TollFree = arguments.FrmStruct["TollFree_#i#"]>
			<cfset local.TollFreeExt = arguments.FrmStruct["TollFreeExt_#i#"]>
			<cfset local.PersonMobileNo = arguments.FrmStruct["PersonMobileNo_#i#"]>
			<cfset local.MobileNoExt = arguments.FrmStruct["MobileNoExt_#i#"]>
			<cfset local.Email = arguments.FrmStruct["Email_#i#"]>
			<cfset local.ContactType = arguments.FrmStruct["ContactType_#i#"]>
			<cfif len(trim(local.CarrierContactID))>
				<cfquery name="qUpd"  datasource="#trim(listFirst(cgi.SCRIPT_NAME,'/'))#">
					UPDATE CarrierContacts SET 
					ContactPerson=<cfqueryparam value="#local.ContactPerson#" cfsqltype="cf_sql_varchar">
					,PhoneNo=<cfqueryparam value="#local.PhoneNo#" cfsqltype="cf_sql_varchar">
					,PhoneNoExt=<cfqueryparam value="#local.PhoneNoExt#" cfsqltype="cf_sql_varchar">
					,Fax=<cfqueryparam value="#local.PhoneNoExt#" cfsqltype="cf_sql_varchar">
					,FaxExt=<cfqueryparam value="#local.FaxExt#" cfsqltype="cf_sql_varchar">
					,TollFree=<cfqueryparam value="#local.TollFree#" cfsqltype="cf_sql_varchar">
					,TollFreeExt=<cfqueryparam value="#local.TollFreeExt#" cfsqltype="cf_sql_varchar">
					,PersonMobileNo=<cfqueryparam value="#local.PersonMobileNo#" cfsqltype="cf_sql_varchar">
					,MobileNoExt=<cfqueryparam value="#local.MobileNoExt#" cfsqltype="cf_sql_varchar">
					,Email=<cfqueryparam value="#local.Email#" cfsqltype="cf_sql_varchar">
					,ContactType=<cfqueryparam value="#local.ContactType#" cfsqltype="cf_sql_varchar">
					WHERE CarrierContactID = <cfqueryparam value="#local.CarrierContactID#" cfsqltype="cf_sql_varchar">
				</cfquery>
			<cfelse>
				<cfif len(trim(local.ContactPerson))>
					<cfquery name="qInsCarrierContact"  datasource="#trim(listFirst(cgi.SCRIPT_NAME,'/'))#">
						INSERT INTO CarrierContacts(CarrierContactID,CarrierID,ContactPerson,PhoneNo,PhoneNoExt,Fax,FaxExt,TollFree,TollFreeExt,PersonMobileNo,MobileNoExt,Email,ContactType)
						VALUES(
							NEWID()
							,<cfqueryparam value="#arguments.CarrierID#" cfsqltype="cf_sql_varchar">
							,<cfqueryparam value="#local.ContactPerson#" cfsqltype="cf_sql_varchar">
							,<cfqueryparam value="#local.PhoneNo#" cfsqltype="cf_sql_varchar">
							,<cfqueryparam value="#local.PhoneNoExt#" cfsqltype="cf_sql_varchar">
							,<cfqueryparam value="#local.Fax#" cfsqltype="cf_sql_varchar">
							,<cfqueryparam value="#local.FaxExt#" cfsqltype="cf_sql_varchar">
							,<cfqueryparam value="#local.TollFree#" cfsqltype="cf_sql_varchar">
							,<cfqueryparam value="#local.TollFreeExt#" cfsqltype="cf_sql_varchar">
							,<cfqueryparam value="#local.PersonMobileNo#" cfsqltype="cf_sql_varchar">
							,<cfqueryparam value="#local.MobileNoExt#" cfsqltype="cf_sql_varchar">
							,<cfqueryparam value="#local.Email#" cfsqltype="cf_sql_varchar">
							,<cfqueryparam value="#local.ContactType#" cfsqltype="cf_sql_varchar">
						)
					</cfquery>
				</cfif>
			</cfif>
		</cfloop>

		<cfloop from="1" to="#arguments.FrmStruct.TotalDriverCount#" index="i">
			<cfset local.CarrierContactID = arguments.FrmStruct["DriverContactID_#i#"]>
			<cfset local.ContactPerson = arguments.FrmStruct["DriverContactPerson_#i#"]>
			<cfset local.PhoneNo = arguments.FrmStruct["DriverPhoneNo_#i#"]>
			<cfset local.PhoneNoExt = arguments.FrmStruct["DriverPhoneNoExt_#i#"]>
			<cfset local.Fax = arguments.FrmStruct["DriverFax_#i#"]>
			<cfset local.FaxExt = arguments.FrmStruct["DriverFaxExt_#i#"]>
			<cfset local.TollFree = arguments.FrmStruct["DriverTollFree_#i#"]>
			<cfset local.TollFreeExt = arguments.FrmStruct["DriverTollFreeExt_#i#"]>
			<cfset local.PersonMobileNo = arguments.FrmStruct["DriverPersonMobileNo_#i#"]>
			<cfset local.MobileNoExt = arguments.FrmStruct["DriverMobileNoExt_#i#"]>
			<cfset local.Email = arguments.FrmStruct["DriverEmail_#i#"]>
			<cfset local.ContactType = 'Driver'>
			<cfif len(trim(local.CarrierContactID))>
				<cfquery name="qUpd"  datasource="#trim(listFirst(cgi.SCRIPT_NAME,'/'))#">
					UPDATE CarrierContacts SET 
					ContactPerson=<cfqueryparam value="#local.ContactPerson#" cfsqltype="cf_sql_varchar">
					,PhoneNo=<cfqueryparam value="#local.PhoneNo#" cfsqltype="cf_sql_varchar">
					,PhoneNoExt=<cfqueryparam value="#local.PhoneNoExt#" cfsqltype="cf_sql_varchar">
					,Fax=<cfqueryparam value="#local.PhoneNoExt#" cfsqltype="cf_sql_varchar">
					,FaxExt=<cfqueryparam value="#local.FaxExt#" cfsqltype="cf_sql_varchar">
					,TollFree=<cfqueryparam value="#local.TollFree#" cfsqltype="cf_sql_varchar">
					,TollFreeExt=<cfqueryparam value="#local.TollFreeExt#" cfsqltype="cf_sql_varchar">
					,PersonMobileNo=<cfqueryparam value="#local.PersonMobileNo#" cfsqltype="cf_sql_varchar">
					,MobileNoExt=<cfqueryparam value="#local.MobileNoExt#" cfsqltype="cf_sql_varchar">
					,Email=<cfqueryparam value="#local.Email#" cfsqltype="cf_sql_varchar">
					,ContactType=<cfqueryparam value="#local.ContactType#" cfsqltype="cf_sql_varchar">
					WHERE CarrierContactID = <cfqueryparam value="#local.CarrierContactID#" cfsqltype="cf_sql_varchar">
				</cfquery>
			<cfelse>
				<cfif len(trim(local.ContactPerson))>
					<cfquery name="qInsCarrierContact"  datasource="#trim(listFirst(cgi.SCRIPT_NAME,'/'))#">
						INSERT INTO CarrierContacts(CarrierContactID,CarrierID,ContactPerson,PhoneNo,PhoneNoExt,Fax,FaxExt,TollFree,TollFreeExt,PersonMobileNo,MobileNoExt,Email,ContactType)
						VALUES(
							NEWID()
							,<cfqueryparam value="#arguments.CarrierID#" cfsqltype="cf_sql_varchar">
							,<cfqueryparam value="#local.ContactPerson#" cfsqltype="cf_sql_varchar">
							,<cfqueryparam value="#local.PhoneNo#" cfsqltype="cf_sql_varchar">
							,<cfqueryparam value="#local.PhoneNoExt#" cfsqltype="cf_sql_varchar">
							,<cfqueryparam value="#local.Fax#" cfsqltype="cf_sql_varchar">
							,<cfqueryparam value="#local.FaxExt#" cfsqltype="cf_sql_varchar">
							,<cfqueryparam value="#local.TollFree#" cfsqltype="cf_sql_varchar">
							,<cfqueryparam value="#local.TollFreeExt#" cfsqltype="cf_sql_varchar">
							,<cfqueryparam value="#local.PersonMobileNo#" cfsqltype="cf_sql_varchar">
							,<cfqueryparam value="#local.MobileNoExt#" cfsqltype="cf_sql_varchar">
							,<cfqueryparam value="#local.Email#" cfsqltype="cf_sql_varchar">
							,<cfqueryparam value="#local.ContactType#" cfsqltype="cf_sql_varchar">
						)
					</cfquery>
				</cfif>
			</cfif>
		</cfloop>
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

	<cffunction name="ZohoSignAPI" access="public" returntype="struct">
		<cfargument name="CarrierID" required="true" type="string">
		<cfargument name="TemplateID" required="true" type="string">
		<cfargument name="CompanyID" required="true" type="string">
		<cfargument name="CompanyCode" required="true" type="string">
		<cftry>
			<cfinvoke method="GetCarrierInfo" returnVariable="qCarrierInfo">
				<cfinvokeargument name="CarrierID" value="#arguments.CarrierID#">
			</cfinvoke>

			<cfquery name="qGetDocDetail" datasource="#trim(listFirst(cgi.SCRIPT_NAME,'/'))#">
				SELECT ZohoTemplateID AS TemplateID,ZohoActionID AS ActionID,UploadFileName FROM OnboardingDocuments WHERE ID = <cfqueryparam value="#arguments.TemplateID#" cfsqltype="cf_sql_varchar">
			</cfquery>

			<cfset var auth_token = GetZohoAuthToken()>

			<cfset var recipient_name = qCarrierInfo.CarrierName>
			<cfset var recipient_email = qCarrierInfo.EmailID>
			<cfquery name="qCarrierCarrierTemplateDoc" datasource="#trim(listFirst(cgi.SCRIPT_NAME,'/'))#">
				SELECT RequestID,ActionID FROM CarrierTemplateDocuments WHERE CarrierID = <cfqueryparam value="#arguments.CarrierID#" cfsqltype="cf_sql_varchar"> AND TemplateID = <cfqueryparam value="#qGetDocDetail.TemplateID#" cfsqltype="cf_sql_varchar">
			</cfquery>
			<cfif qCarrierCarrierTemplateDoc.recordCount>
				<cfset var RequestID = qCarrierCarrierTemplateDoc.RequestID>
				<cfset var Action_ID = qCarrierCarrierTemplateDoc.ActionID>
			<cfelse>
				<cfset var reqData = structnew()>
				<cfset var actions = arrayNew(1)>
				<cfset var actiondetail = structnew()>
				<cfset actiondetail["recipient_name"] = recipient_name>
				<cfset actiondetail["recipient_email"] = recipient_email>
				<cfset actiondetail["action_id"] = qGetDocDetail.ActionID>
				<cfset arrayAppend(actions, actiondetail)>
			    <cfset templates["actions"] = actions>
			    <cfset reqData["templates"] = templates>
				<cfhttp method="post" url="https://sign.zoho.com/api/v1/templates/#qGetDocDetail.TemplateID#/createdocument" result="objRespCreateDoc">
				    <cfhttpparam type="header" name="Authorization" value="Zoho-oauthtoken #auth_token#"/>
				    <cfhttpparam type="formfield" name="data" value="#serializeJSON(reqData)#"/>
				    <cfhttpparam type="formfield" name="is_quicksend" value="false"/>
				</cfhttp>
				<cfset structResp = deserializeJSON(objRespCreateDoc.Filecontent)>
				<cfset var RequestID = structResp.requests.request_id>
				<cfset var Action_ID = structResp.requests.actions[1].action_id>

				<cfquery name="qInsertCarrDoc" datasource="#trim(listFirst(cgi.SCRIPT_NAME,'/'))#">
					INSERT INTO CarrierTemplateDocuments (CarrierID,TemplateID,RequestID,ActionID)
					VALUES(
						<cfqueryparam value="#arguments.CarrierID#" cfsqltype="cf_sql_varchar">
						,<cfqueryparam value="#qGetDocDetail.TemplateID#" cfsqltype="cf_sql_varchar">
						,<cfqueryparam value="#RequestID#" cfsqltype="cf_sql_varchar">
						,<cfqueryparam value="#Action_ID#" cfsqltype="cf_sql_varchar">
						)
				</cfquery>	

				<cfquery name="qInsertLog" datasource="#trim(listFirst(cgi.SCRIPT_NAME,'/'))#">
					INSERT INTO ZohoSignLog (CompanyID,CompanyCode,CarrierID,RequestID)
					VALUES(
						<cfqueryparam value="#arguments.CompanyID#" cfsqltype="cf_sql_varchar">
						,<cfqueryparam value="#arguments.CompanyCode#" cfsqltype="cf_sql_varchar">
						,<cfqueryparam value="#arguments.CarrierID#" cfsqltype="cf_sql_varchar">
						,<cfqueryparam value="#RequestID#" cfsqltype="cf_sql_varchar">
						)
				</cfquery>	
				<cfset var reqData = structnew()>
				<cfset var actions = arrayNew(1)>
				<cfset var actiondetail = structnew()>

				<cfset actiondetail["action_id"] = Action_ID>
				<cfset actiondetail["action_type"] = "SIGN">
				<cfset actiondetail["private_notes"] = "">
				<cfset actiondetail["signing_order"] = 0>
				<cfset actiondetail["verify_recipient"] =false>
				<cfset actiondetail["recipient_name"] = recipient_name>
				<cfset actiondetail["recipient_email"] = recipient_email>
				<cfset actiondetail["is_embedded"] = true>

				<cfloop array="#structResp.requests.actions[1].fields#" item="fieldTemp">
					<cfset structDelete(fieldTemp, "time_zone_offset")>
					<cfif findNoCase("Company", fieldTemp.field_label) OR findNoCase("Full Name", fieldTemp.field_label)>
						<cfset fieldTemp.default_value = "#qCarrierInfo.CarrierName#">
					</cfif>
					<cfif findNoCase("Address", fieldTemp.field_label)>
						<cfset fieldTemp.default_value = "#qCarrierInfo.Address#">
					</cfif>
					<cfif findNoCase("City", fieldTemp.field_label)>
						<cfset fieldTemp.default_value = "#qCarrierInfo.City#">
					</cfif>
					<cfif findNoCase("State", fieldTemp.field_label)>
						<cfset fieldTemp.default_value = "#qCarrierInfo.StateCode#">
					</cfif>
					<cfif findNoCase("Zip", fieldTemp.field_label)>
						<cfset fieldTemp.default_value = "#qCarrierInfo.ZipCode#">
					</cfif>
					<cfif findNoCase("City, State Zip", fieldTemp.field_label)>
						<cfset fieldTemp.default_value = "#trim(qCarrierInfo.City)#, #trim(qCarrierInfo.StateCode)# #trim(qCarrierInfo.ZipCode)#">
					</cfif>
					<cfif findNoCase("Dot Number", fieldTemp.field_label)>
						<cfset fieldTemp.default_value = "#qCarrierInfo.DOTNumber#">
					</cfif>
					<cfif findNoCase("MC Number", fieldTemp.field_label)>
						<cfset fieldTemp.default_value = "#qCarrierInfo.MCNumber#">
					</cfif>
					<cfif findNoCase("Fed Tax ID", fieldTemp.field_label)>
						<cfset fieldTemp.default_value = "#qCarrierInfo.TaxID#">
					</cfif>
					<cfif findNoCase("Email", fieldTemp.field_label)>
						<cfset fieldTemp.default_value = "#qCarrierInfo.EmailID#">
					</cfif>
					<cfif findNoCase("Contact Name", fieldTemp.field_label)>
						<cfset fieldTemp.default_value = "#qCarrierInfo.ContactPerson#">
					</cfif>
					<cfif findNoCase("Phone", fieldTemp.field_label)>
						<cfset fieldTemp.default_value = "#qCarrierInfo.Phone#">
					</cfif>
					<cfif findNoCase("Fax", fieldTemp.field_label)>
						<cfset fieldTemp.default_value = "#qCarrierInfo.Fax#">
					</cfif>
				</cfloop>

				<cfset actiondetail["fields"] = structResp.requests.actions[1].fields>
				<cfset arrayAppend(actions, actiondetail)>
			    <cfset requests["actions"] = actions>
			    <cfset reqData["requests"] = requests>

				<cfhttp method="post" url="https://sign.zoho.com/api/v1/requests/#RequestID#/submit" result="objRespSubmitDoc">
				    <cfhttpparam type="header" name="Authorization" value="Zoho-oauthtoken #auth_token#"/>
				    <cfhttpparam type="formfield" name="data" value="#serializeJSON(reqData)#"/>
				</cfhttp>
			</cfif>

			<cfhttp method="post" url="https://sign.zoho.com/api/v1/requests/#RequestID#/actions/#Action_ID#/embedtoken?host=https://#cgi.HTTP_HOST#/" result="objRespEmbedurl">
			    <cfhttpparam type="header" name="Authorization" value="Zoho-oauthtoken #auth_token#"/>
			</cfhttp>

			<cfset structEmburlResp = deserializeJSON(objRespEmbedurl.Filecontent)>
			<cfset var zohoEmbedded = structnew()>
			<cfset zohoEmbedded.sign_url = structEmburlResp.sign_url>
			<cfset zohoEmbedded.request_id = RequestID>
			<cfset zohoEmbedded.UploadFileName = qGetDocDetail.UploadFileName>

			<cfreturn zohoEmbedded>
			<cfcatch>
				<cfdocument format="pdf" filename="C:\pdf\CarrierOnBoard_#DateTimeFormat(now(),"YYYY_MM_dd_HH_nn_ss_l")#.pdf" overwrite="true">
		    		<cfdump var="#datetimeformat(now())#">
			    	<cfdump var="#arguments#">
			    	<cfdump var="#cfcatch#">
				</cfdocument>
				<cfset var zohoEmbedded = structnew()>
				<cfset zohoEmbedded.sign_url = "">
				<cfset zohoEmbedded.request_id = "">
				<cfset zohoEmbedded.UploadFileName = qGetDocDetail.UploadFileName>
				<cfreturn zohoEmbedded>
			</cfcatch>
		</cftry>
	</cffunction>

	<cffunction name="ISDocumentSigned" access="public" returntype="boolean">
		<cfargument name="RequestID" required="true" type="string">
		<cftry>
			<cfset var auth_token = GetZohoAuthToken()>
			<cfhttp method="get" url="https://sign.zoho.com/api/v1/requests/#RequestID#" result="objResp">
			    <cfhttpparam type="header" name="Authorization" value="Zoho-oauthtoken #auth_token#"/>
			</cfhttp>
			
			<cfset structResp = deserializeJSON(objResp.Filecontent)>
			<cfif structResp.requests.actions[1].action_status EQ 'SIGNED'>
				<cfreturn 1>
			<cfelse>
				<cfreturn 0>
			</cfif>
			<cfcatch>
				<cfreturn 0>
			</cfcatch>
		</cftry>
	</cffunction>

	<cffunction name="SaveCoveredLanes" access="public" returntype="void">
		<cfargument name="CarrierID" required="true" type="string">
		<cfargument name="FrmStruct" required="true" type="struct">

		<cfif structKeyExists(arguments.FrmStruct, "lanestates")>
			<cfloop list="#arguments.FrmStruct.lanestates#" item="state">
				<cfquery name="qIns" datasource="#trim(listFirst(cgi.SCRIPT_NAME,'/'))#">
				IF(SELECT COUNT(CarrierLaneID) FROM CarrierLanes WHERE CarrierID = <cfqueryparam value="#arguments.CarrierID#" cfsqltype="cf_sql_varchar"> AND PickUpState = <cfqueryparam value="#state#" cfsqltype="cf_sql_varchar"> AND DeliveryState = <cfqueryparam value="#state#" cfsqltype="cf_sql_varchar">)=0
					BEGIN
					    INSERT INTO CarrierLanes (
						    CarrierLaneID,
						    CarrierID,
						    PickUpState,
						    DeliveryState,
						    Cost,
						    Miles,
						    RatePerMile,
						    IntransitStops,
						    CreatedBy,
						    ModifiedBy
					    ) 
						VALUES(
							NEWID(),
							<cfqueryparam value="#arguments.CarrierID#" cfsqltype="cf_sql_varchar">,
							<cfqueryparam value="#state#" cfsqltype="cf_sql_varchar">,
							<cfqueryparam value="#state#" cfsqltype="cf_sql_varchar">,
							0,
						    0,
						    0,
						    0,
							<cfqueryparam value="CarrierOnBoard" cfsqltype="cf_sql_varchar">,
							<cfqueryparam value="CarrierOnBoard" cfsqltype="cf_sql_varchar">
						)
					END
  				</cfquery>
			</cfloop>
		</cfif>	

	</cffunction>

	<cffunction name="GetEquipments" access="public" returntype="query">
		<cfargument name="CompanyID" required="true" type="string">
		<cfquery name="qEquipments" datasource="#trim(listFirst(cgi.SCRIPT_NAME,'/'))#">
			SELECT EquipmentID,EquipmentName FROM Equipments
			WHERE CompanyID = <cfqueryparam value="#arguments.CompanyID#" cfsqltype="cf_sql_varchar">
			AND ShowCarrierOnboarding = 1
		</cfquery>
		<cfreturn qEquipments>
	</cffunction>

	<cffunction name="SaveCarrierEquipments" access="public" returntype="void">
		<cfargument name="CarrierID" required="true" type="string">
		<cfargument name="FrmStruct" required="true" type="struct">

		<cfif structKeyExists(arguments.FrmStruct, "CarrierEquipments")>
			<cfloop list="#arguments.FrmStruct.CarrierEquipments#" item="Equipment">
				<cfquery name="qIns" datasource="#trim(listFirst(cgi.SCRIPT_NAME,'/'))#">
				IF(SELECT COUNT(CarrierEquipmentID) FROM CarrierEquipments WHERE CarrierID = <cfqueryparam value="#arguments.CarrierID#" cfsqltype="cf_sql_varchar"> AND EquipmentID=<cfqueryparam value="#Equipment#" cfsqltype="cf_sql_varchar">)=0
					BEGIN
					    INSERT INTO CarrierEquipments (
						    CarrierEquipmentID,
						    CarrierID,
						    EquipmentID,
						    CreatedBy,
						    ModifiedBy
					    ) 
						VALUES(
							NEWID(),
							<cfqueryparam value="#arguments.CarrierID#" cfsqltype="cf_sql_varchar">,
							<cfqueryparam value="#Equipment#" cfsqltype="cf_sql_varchar">,
							<cfqueryparam value="CarrierOnBoard" cfsqltype="cf_sql_varchar">,
							<cfqueryparam value="CarrierOnBoard" cfsqltype="cf_sql_varchar">
						)
					END
  				</cfquery>
			</cfloop>
		</cfif>	

	</cffunction>

	<cffunction name="GetContacts" access="public" returntype="query">
		<cfargument name="CarrierID" required="true" type="string">
		<cfargument name="ContactType" required="false" type="string" default="">
		<cfquery name="qContacts" datasource="#trim(listFirst(cgi.SCRIPT_NAME,'/'))#">
			SELECT CarrierContactID,ContactPerson,PhoneNo,PhoneNoExt,Fax,FaxExt,TollFree,TollFreeExt,PersonMobileNo,MobileNoExt,Email,ContactType FROM CarrierContacts
			WHERE CarrierID = <cfqueryparam value="#arguments.CarrierID#" cfsqltype="cf_sql_varchar">
			<cfif len(trim(arguments.ContactType))>
				AND ContactType = <cfqueryparam value="#arguments.ContactType#" cfsqltype="cf_sql_varchar">
			<cfelse>
				AND ContactType IN ('Billing','Credit','General')
			</cfif>
			AND Active = 1
		</cfquery>
		<cfreturn qContacts>
	</cffunction>

	<cffunction name="DeleteContact" access="remote" returntype="void">
		<cfargument name="CarrierContactID" required="true" type="string">
		<cfquery name="qDel" datasource="#trim(listFirst(cgi.SCRIPT_NAME,'/'))#">
			DELETE FROM CarrierContacts WHERE CarrierContactID = <cfqueryparam value="#arguments.CarrierContactID#" cfsqltype="cf_sql_varchar">
		</cfquery>
	</cffunction>

	<cffunction name="GetLanes" access="public" returntype="query">
		<cfargument name="CarrierID" required="true" type="string">
		<cfquery name="qLanes" datasource="#trim(listFirst(cgi.SCRIPT_NAME,'/'))#">
			SELECT PickUpState FROM CarrierLanes
			WHERE CarrierID = <cfqueryparam value="#arguments.CarrierID#" cfsqltype="cf_sql_varchar">
			AND PickUpState = DeliveryState
		</cfquery>
		<cfreturn qLanes>
	</cffunction>

	<cffunction name="DeleteLane" access="remote" returntype="void">
		<cfargument name="Lane" required="true" type="string">
		<cfargument name="CarrierID" required="true" type="string">
		<cfquery name="qDel" datasource="#trim(listFirst(cgi.SCRIPT_NAME,'/'))#">
			DELETE FROM CarrierLanes WHERE CarrierID = <cfqueryparam value="#arguments.CarrierID#" cfsqltype="cf_sql_varchar">
			AND PickUpState = <cfqueryparam value="#arguments.Lane#" cfsqltype="cf_sql_varchar">
			AND DeliveryState = <cfqueryparam value="#arguments.Lane#" cfsqltype="cf_sql_varchar">
		</cfquery>
	</cffunction>

	<cffunction name="GetCarrierEquipments" access="public" returntype="query">
		<cfargument name="CarrierID" required="true" type="string">
		<cfquery name="qCarrierEquipments" datasource="#trim(listFirst(cgi.SCRIPT_NAME,'/'))#">
			SELECT EquipmentID FROM CarrierEquipments
			WHERE CarrierID = <cfqueryparam value="#arguments.CarrierID#" cfsqltype="cf_sql_varchar">
		</cfquery>
		<cfreturn qCarrierEquipments>
	</cffunction>

	<cffunction name="DeleteCarrierEquipment" access="remote" returntype="void">
		<cfargument name="EquipmentID" required="true" type="string">
		<cfargument name="CarrierID" required="true" type="string">
		<cfquery name="qDel" datasource="#trim(listFirst(cgi.SCRIPT_NAME,'/'))#">
			DELETE FROM CarrierEquipments WHERE EquipmentID = <cfqueryparam value="#arguments.EquipmentID#" cfsqltype="cf_sql_varchar"> AND CarrierID = <cfqueryparam value="#arguments.CarrierID#" cfsqltype="cf_sql_varchar">
		</cfquery>
	</cffunction>

	<cffunction name="UpdateCarrierOnboardStep" access="public" returntype="void">
		<cfargument name="CarrierID" required="true" type="string">
		<cfargument name="CarrierOnboardStep" required="true" type="string">

		<cfquery name="qUpd" datasource="#trim(listFirst(cgi.SCRIPT_NAME,'/'))#">
			UPDATE Carriers SET CarrierOnboardStep = <cfqueryparam value="#arguments.CarrierOnboardStep#" cfsqltype="cf_sql_varchar">,OnboardStatus = 1 WHERE  CarrierID = <cfqueryparam value="#arguments.CarrierID#" cfsqltype="cf_sql_varchar">
		</cfquery>
	</cffunction>

	<cffunction name="DocumentRenewed" access="public" returntype="void">
		<cfargument name="CarrierID" required="true" type="string">
		<cfinvoke component="cfc.carrier" method="GetSystemConfig" returnVariable="qSystemConfig"></cfinvoke>
		<cfquery name="qUpd"  datasource="#trim(listFirst(cgi.SCRIPT_NAME,'/'))#">
			UPDATE Carriers 
			SET OnboardStatus = 2,CarrierOnboardStep = NULL
			<cfif qSystemConfig.KeepCarrierInactive EQ 1>
				,Status = 0
			</cfif>
			WHERE CarrierID = <cfqueryparam value="#arguments.CarrierID#" cfsqltype="cf_sql_varchar">
		</cfquery>
		<cfif qSystemConfig.KeepCarrierInactive EQ 1>
			<cfquery name="insAlert"  datasource="#trim(listFirst(cgi.SCRIPT_NAME,'/'))#">
				INSERT INTO Alerts(CreatedBy,CompanyID,Description,AssignedTo,AssignedType,Type,TypeID,Reference)
				VALUES(
					<cfqueryparam value="#arguments.CarrierID#" cfsqltype="cf_sql_varchar">
					,<cfqueryparam value="#qSystemConfig.CompanyID#" cfsqltype="cf_sql_varchar">
					,'Carrier Packet Verification'
					,'CarrierOnboardingVerifier'
					,'Parameter'
					,'Carrier'
					,<cfqueryparam value="#arguments.CarrierID#" cfsqltype="cf_sql_varchar">
					,(SELECT 'MC'+REPLACE(MCNumber,'MC','') FROM Carriers WHERE CarrierID = <cfqueryparam value="#arguments.CarrierID#" cfsqltype="cf_sql_varchar">)
				)
			</cfquery>	
		</cfif>	
	</cffunction>

	<cffunction name="FinishOnBoard" access="public" returntype="void">
		<cfargument name="CarrierID" required="true" type="string">
		<cfinvoke component="cfc.carrier" method="GetSystemConfig" returnVariable="qSystemConfig"></cfinvoke>

		<cfquery name="qUpd"  datasource="#trim(listFirst(cgi.SCRIPT_NAME,'/'))#">
			UPDATE Carriers 
			SET OnboardStatus = 2,CarrierOnboardStep = NULL
			<cfif qSystemConfig.KeepCarrierInactive EQ 1>
				,Status = 0
			</cfif>
			WHERE CarrierID = <cfqueryparam value="#arguments.CarrierID#" cfsqltype="cf_sql_varchar">
		</cfquery>	

		<cfquery name="qrygetCommonDropBox" datasource="LoadManagerAdmin">
			SELECT <cfif len(trim(qSystemConfig.DropBoxAccessToken))>'#qSystemConfig.DropBoxAccessToken#'<cfelse>DropBoxAccessToken</cfif> AS DropBoxAccessToken 
			FROM SystemSetup
		</cfquery>

		<cfquery name="qGetAttachment"  datasource="#trim(listFirst(cgi.SCRIPT_NAME,'/'))#">
			SELECT attachmentFileName FROM FileAttachments WHERE linked_Id = <cfqueryparam value="#arguments.CarrierID#" cfsqltype="cf_sql_varchar"> AND attachedFileLabel = 'Signed Onboard Document'
		</cfquery>

		<cfset var dsn = trim(listFirst(cgi.SCRIPT_NAME,'/'))>
		<cfset var rootPath = "#expandPath("\#dsn#\www\webroot\CarrierOnBoard\Temp_CarrierOnBoard_#arguments.CarrierID#_#dateTimeFormat(now(),'YYMMDDHHNNSSL')#\")#">
		<cfdirectory action = "create" directory = "#rootPath#" > 
		<cfset PDFtkList = "">
		<cfexecute 
			name="c:\Program Files\wkhtmltopdf\bin\wkhtmltopdf.exe" 
			arguments="https://#cgi.HTTP_HOST#/#dsn#/www/webroot/CarrierOnBoard/index.cfm?event=CarrierInformation&CarrierID=#arguments.CarrierID#&isPdf=1 #rootPath#1CarrierInformation.pdf" timeout="1000" />
		<cfset PDFtkList = listAppend(PDFtkList, "#rootPath#1CarrierInformation.pdf"," ")>

		<cfexecute 
			name="c:\Program Files\wkhtmltopdf\bin\wkhtmltopdf.exe" 
			arguments="https://#cgi.HTTP_HOST#/#dsn#/www/webroot/CarrierOnBoard/index.cfm?event=CarrierInsurance&CarrierID=#arguments.CarrierID#&isPdf=1 #rootPath#2CarrierInsurance.pdf" timeout="1000" />
		<cfset PDFtkList = listAppend(PDFtkList, "#rootPath#2CarrierInsurance.pdf"," ")>

		<cfexecute 
			name="c:\Program Files\wkhtmltopdf\bin\wkhtmltopdf.exe" 
			arguments="https://#cgi.HTTP_HOST#/#dsn#/www/webroot/CarrierOnBoard/index.cfm?event=AddContact&CarrierID=#arguments.CarrierID#&isPdf=1 #rootPath#3AddContact.pdf" timeout="1000" />
		<cfset PDFtkList = listAppend(PDFtkList, "#rootPath#3AddContact.pdf"," ")>

		<cfexecute 
			name="c:\Program Files\wkhtmltopdf\bin\wkhtmltopdf.exe" 
			arguments="https://#cgi.HTTP_HOST#/#dsn#/www/webroot/CarrierOnBoard/index.cfm?event=CoveredLanes&CarrierID=#arguments.CarrierID#&isPdf=1 #rootPath#4CoveredLanes.pdf" timeout="1000" />
		<cfset PDFtkList = listAppend(PDFtkList, "#rootPath#4CoveredLanes.pdf"," ")>

		<cfexecute 
			name="c:\Program Files\wkhtmltopdf\bin\wkhtmltopdf.exe" 
			arguments="https://#cgi.HTTP_HOST#/#dsn#/www/webroot/CarrierOnBoard/index.cfm?event=CarrierEquipments&CarrierID=#arguments.CarrierID#&isPdf=1 #rootPath#5CarrierEquipments.pdf" timeout="1000" />
		<cfset PDFtkList = listAppend(PDFtkList, "#rootPath#5CarrierEquipments.pdf"," ")>

		<cfexecute 
			name="c:\Program Files\wkhtmltopdf\bin\wkhtmltopdf.exe" 
			arguments="https://#cgi.HTTP_HOST#/#dsn#/www/webroot/CarrierOnBoard/index.cfm?event=CarrierACHInformation&CarrierID=#arguments.CarrierID#&isPdf=1 #rootPath#6CarrierACHInformation.pdf" timeout="1000" />
		<cfset PDFtkList = listAppend(PDFtkList, "#rootPath#6CarrierACHInformation.pdf"," ")>

		<cfexecute 
			name="c:\Program Files\wkhtmltopdf\bin\wkhtmltopdf.exe" 
			arguments="https://#cgi.HTTP_HOST#/#dsn#/www/webroot/CarrierOnBoard/index.cfm?event=CarrierELDAndCertification&CarrierID=#arguments.CarrierID#&isPdf=1 #rootPath#7CarrierELDAndCertification.pdf" timeout="1000" />
		<cfset PDFtkList = listAppend(PDFtkList, "#rootPath#7CarrierELDAndCertification.pdf"," ")>

 		<cfset var index = 8>
		<cfloop query="qGetAttachment">
			<cfhttp method="POST" url="https://api.dropboxapi.com/2/sharing/create_shared_link"	result="returnStruct"> 
				<cfhttpparam type="HEADER" name="Authorization" value="Bearer #qrygetCommonDropBox.DropBoxAccessToken#">	
				<cfhttpparam type="HEADER" name="Content-Type" value="application/json">	
				<cfhttpparam type="body" value='{"path":#SerializeJSON('/fileupload/img/#qSystemConfig.CompanyCode#/' & qGetAttachment.attachmentFileName)#}'>
			</cfhttp>
			<cfset filePath = "">
			<cfif returnStruct.Statuscode EQ "200 OK">
				<cfset filePath = deserializeJSON(returnStruct.fileContent).url.Split('\?')[1] & '?raw=1'>
			</cfif>	
			<cfhttp url="#filePath#" method="get" getAsBinary="yes"path="#rootPath#" file="#index##qGetAttachment.attachmentFileName#"/>
			<cfset fileInfo = GetFileInfo('#rootPath##index##qGetAttachment.attachmentFileName#')>
			<cfif fileInfo.canWrite>
				<cfset PDFtkList = listAppend(PDFtkList, "#rootPath##index##qGetAttachment.attachmentFileName#"," ")>
			</cfif>
			<cfset index++>
		</cfloop>

		<cfexecute name="C:\Program Files\PDFtk Server\bin\pdftk.exe" arguments="#PDFtkList# cat output #rootPath#CarrierPacketPDF.pdf dont_ask" timeOut="1000"></cfexecute>

		<cfset FileName = "CarrierPacket_#dateTimeFormat(now(),'YYMMDDHHNNSS')#.pdf">
		<cfset tmpStruct = {"path":"/fileupload/img/#qSystemConfig.CompanyCode#/#FileName#","mode":{".tag":"overwrite"},"autorename":false}>
		<cffile action = "readbinary" file = "#rootPath#CarrierPacketPDF.pdf" variable="CarrierPacketPDF">
		<cfhttp method="post" url="https://content.dropboxapi.com/2/files/upload" result="objDropbox"> 
			<cfhttpparam type="HEADER" name="Authorization" value="Bearer #trim(qrygetCommonDropBox.DropBoxAccessToken)#">		
			<cfhttpparam type="HEADER" name="Content-Type" value="application/octet-stream">
			<cfhttpparam type="HEADER" name="Dropbox-API-Arg" value="#serializeJSON(tmpStruct)#">
			<cfhttpparam type="body" value="#CarrierPacketPDF#">
		</cfhttp>
		<cfif objDropbox.Statuscode EQ "200 OK">
			<cfquery name="qIns" datasource="#dsn#" result="resFa">
				INSERT INTO FileAttachments(
					linked_Id,
					linked_to,
					attachedFileLabel,
					attachmentFileName,
					uploadedBy,
					DropBoxFile,
					AttachmentTypeID
				) VALUES (
					<cfqueryparam value="#arguments.CarrierID#" cfsqltype="cf_sql_varchar">,
					3,
					<cfqueryparam value="Carrier Packet" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#FileName#" cfsqltype="cf_sql_varchar">,
					'Carrier',
					1,
					NULL
				)
			</cfquery>
		</cfif>
		<cfif structKeyExists(form, "SignedDoc")>
			<cffile action="upload" fileField="SignedDoc" nameconflict="overwrite" destination="#rootPath#">
			<cfset FileName = "SignedOnboardDocument_#DateFormat(now(),'mmddyyyy')##TimeFormat(now(),'hhnnss')#.pdf">
			<cfset tmpStruct = {"path":"/fileupload/img/#qSystemConfig.CompanyCode#/#FileName#","mode":{".tag":"overwrite"},"autorename":false}>
			<cffile action = "readbinary" file = "#rootPath##cffile.CLIENTFILENAME#.#cffile.CLIENTFILEEXT#" variable="SignedOnboardDocument">
			<cfhttp method="post" url="https://content.dropboxapi.com/2/files/upload" result="objDropbox"> 
				<cfhttpparam type="HEADER" name="Authorization" value="Bearer #trim(qrygetCommonDropBox.DropBoxAccessToken)#">		
				<cfhttpparam type="HEADER" name="Content-Type" value="application/octet-stream">
				<cfhttpparam type="HEADER" name="Dropbox-API-Arg" value="#serializeJSON(tmpStruct)#">
				<cfhttpparam type="body" value="#SignedOnboardDocument#">
			</cfhttp>
			<cfif objDropbox.Statuscode EQ "200 OK">
				<cfquery name="qIns" datasource="#dsn#" result="resFa">
					INSERT INTO FileAttachments(
						linked_Id,
						linked_to,
						attachedFileLabel,
						attachmentFileName,
						uploadedBy,
						DropBoxFile,
						AttachmentTypeID
					) VALUES (
						<cfqueryparam value="#arguments.CarrierID#" cfsqltype="cf_sql_varchar">,
						3,
						<cfqueryparam value="Signed Onboard Document" cfsqltype="cf_sql_varchar">,
						<cfqueryparam value="#FileName#" cfsqltype="cf_sql_varchar">,
						'Carrier',
						1,
						NULL
					)
				</cfquery>
			</cfif>
		</cfif>
		<cfset DirectoryDelete(rootPath,true)>
		<cfif qSystemConfig.KeepCarrierInactive EQ 1>
			<cfquery name="insAlert"  datasource="#trim(listFirst(cgi.SCRIPT_NAME,'/'))#">
				INSERT INTO Alerts(CreatedBy,CompanyID,Description,AssignedTo,AssignedType,Type,TypeID,Reference)
				VALUES(
					<cfqueryparam value="#arguments.CarrierID#" cfsqltype="cf_sql_varchar">
					,<cfqueryparam value="#qSystemConfig.CompanyID#" cfsqltype="cf_sql_varchar">
					,'Carrier Packet Verification'
					,'CarrierOnboardingVerifier'
					,'Parameter'
					,'Carrier'
					,<cfqueryparam value="#arguments.CarrierID#" cfsqltype="cf_sql_varchar">
					,(SELECT 'MC'+REPLACE(MCNumber,'MC','') FROM Carriers WHERE CarrierID = <cfqueryparam value="#arguments.CarrierID#" cfsqltype="cf_sql_varchar">)
				)
			</cfquery>	
		</cfif>
	</cffunction>

	<cffunction name="GetTemplates" access="public" returntype="query">
		<cfargument name="CompanyID" required="true" type="string">

		<cfquery name="qGet"  datasource="#trim(listFirst(cgi.SCRIPT_NAME,'/'))#">
			SELECT ID FROM OnboardingDocuments
			WHERE CompanyID = <cfqueryparam value="#arguments.CompanyID#" cfsqltype="cf_sql_varchar">
			AND Active = 1
		</cfquery>

		<cfreturn qGet>
	</cffunction>

	<cffunction name="GetCarrierAttachmentTypes" access="public" returntype="query">
		<cfargument name="CompanyID" required="true" type="string">

		<cfquery name="qGet" datasource="#trim(listFirst(cgi.SCRIPT_NAME,'/'))#">
			SELECT AttachmentTypeID FROM FileAttachmentTypes
			WHERE CompanyID = <cfqueryparam value="#arguments.CompanyID#" cfsqltype="cf_sql_varchar">
			AND AttachmentType='Carrier'
		</cfquery>

		<cfreturn qGet>
	</cffunction>

	<cffunction name="GetAttachmentTypeDetail" access="public" returntype="query">
		<cfargument name="AttachmentTypeID" required="true" type="string">

		<cfquery name="qGet" datasource="#trim(listFirst(cgi.SCRIPT_NAME,'/'))#">
			SELECT Description,Required,RenewalDate FROM FileAttachmentTypes
			WHERE AttachmentTypeID = <cfqueryparam value="#arguments.AttachmentTypeID#" cfsqltype="cf_sql_varchar">
		</cfquery>

		<cfreturn qGet>
	</cffunction>

	<cffunction name="GetCarrierAttachment" access="public" returntype="query">
		<cfargument name="CarrierID" required="true" type="string">
		<cfargument name="AttachmentTypeID" required="true" type="string">

		<cfquery name="qGet" datasource="#trim(listFirst(cgi.SCRIPT_NAME,'/'))#">
			SELECT TOP 1 AttachmentFileName,attachment_Id,UploadedDateTime FROM FileAttachments
			WHERE AttachmentTypeID = <cfqueryparam value="#arguments.AttachmentTypeID#" cfsqltype="cf_sql_varchar">
			AND linked_Id = <cfqueryparam value="#arguments.CarrierID#" cfsqltype="cf_sql_varchar">
			ORDER BY UploadedDateTime 
		</cfquery>

		<cfreturn qGet>
	</cffunction>

	<cffunction name="AttachFile" access="public" returntype="void">
		<cfargument name="CarrierID" required="true" type="string">
		<cfargument name="FrmStruct" required="true" type="struct">

		<cfif len(trim(arguments.FrmStruct.file))>
			<cfinvoke component="cfc.carrier" method="GetSystemConfig" returnVariable="qSystemConfig"></cfinvoke>
			<cfset var dsn=trim(listFirst(cgi.SCRIPT_NAME,'/'))>
			<cfquery name="qrygetCommonDropBox" datasource="LoadManagerAdmin">
				SELECT <cfif len(trim(qSystemConfig.DropBoxAccessToken))>'#qSystemConfig.DropBoxAccessToken#'<cfelse>DropBoxAccessToken</cfif> AS DropBoxAccessToken 
				FROM SystemSetup
			</cfquery>

			<cfset var rootPath = "#expandPath("\#dsn#\www\webroot\CarrierOnBoard\Temp_CarrierOnBoard_#arguments.CarrierID#_#dateTimeFormat(now(),'YYMMDDHHNNSSL')#\")#">
			<cfif not directoryExists(rootPath)>
				<cfdirectory action = "create" directory = "#rootPath#" > 
			</cfif>
			<cffile action="upload" fileField="file" nameconflict="overwrite" destination="#rootPath#">
			<cfset var tempFileName = REReplace(Replace("#cffile.CLIENTFILENAME#",":","_","ALL"), "[^A-Za-z0-9_.]","","all")>
			<cfif len(tempFileName) GT 0>
				<cfset var UploadedFile = tempFileName&"_"&dateTimeFormat(now(),'YYMMDDHHNNSS')&"."&cffile.CLIENTFILEEXT>
			<cfelse>	
				<cfset var UploadedFile = "file_"&dateTimeFormat(now(),'YYMMDDHHNNSS')&"."&cffile.CLIENTFILEEXT>
			</cfif>
						
			<cffile action="rename" source="#rootPath#/#cffile.CLIENTFILE#" destination="#rootPath#/#UploadedFile#">

			<cfhttp method="post" url="https://api.dropboxapi.com/2/users/get_current_account" result="returnStruct"> 
				<cfhttpparam type="HEADER" name="Authorization" value="Bearer #qrygetCommonDropBox.DropBoxAccessToken#">		
			</cfhttp> 
			<cfif returnStruct.Statuscode EQ "200 OK"> <!--- Authorization Success --->
				<cfhttp method="POST" url="https://api.dropboxapi.com/2/files/get_metadata"	result="returnStruct"> 
					<cfhttpparam type="HEADER" name="Authorization" value="Bearer #qrygetCommonDropBox.DropBoxAccessToken#">			
					<cfhttpparam type="HEADER" name="Content-Type" value="application/json">			
					<cfhttpparam type="body" value='{"path": "/fileupload/img/#qSystemConfig.CompanyCode#"}'>	
				</cfhttp>	
				<cfif returnStruct.Statuscode NEQ "200 OK"> <!--- Folder Not Found, Create Folder ---->	
					<cfset tmpStruct = { "path" = '/fileupload/img/#qSystemConfig.CompanyCode#'}>
					<cfhttp method="post" url="https://api.dropboxapi.com/2/files/create_folder" result="returnStructCreateFolder"> 
						<cfhttpparam type="HEADER" name="Authorization" value="Bearer #qrygetCommonDropBox.DropBoxAccessToken#">		
						<cfhttpparam type="HEADER" name="Content-Type" value="application/json">
						<cfhttpparam type="body" value="#serializeJSON(tmpStruct)#">
					</cfhttp> 
				</cfif>
				<cfset tmpStruct = {"path":"/fileupload/img/#qSystemConfig.CompanyCode#/#UploadedFile#","mode":{".tag":"add"},"autorename":true}>

				<cffile action = "readbinary" file = "#rootPath#/#UploadedFile#" variable="filcontent">
				<cfhttp method="post" url="https://content.dropboxapi.com/2/files/upload" result="returnStruct"> <cfhttpparam type="HEADER" name="Authorization" value="Bearer #qrygetCommonDropBox.DropBoxAccessToken#">		
					<cfhttpparam type="HEADER" name="Content-Type" value="application/octet-stream">
					<cfhttpparam type="HEADER" name="Dropbox-API-Arg" value="#serializeJSON(tmpStruct)#">
					<cfhttpparam type="body" value="#filcontent#">
				</cfhttp>
				<cfif returnStruct.Statuscode EQ "200 OK">
					<cfquery name="qIns" datasource="#dsn#" result="resFa">
						INSERT INTO FileAttachments(
							linked_Id,
							linked_to,
							attachedFileLabel,
							attachmentFileName,
							uploadedBy,
							DropBoxFile,
							AttachmentTypeID
						) VALUES (
							<cfqueryparam value="#arguments.CarrierID#" cfsqltype="cf_sql_varchar">,
							3,
							<cfqueryparam value="#arguments.FrmStruct.AttachmentLabel#" cfsqltype="cf_sql_varchar">,
							<cfqueryparam value="#UploadedFile#" cfsqltype="cf_sql_varchar">,
							'Carrier',
							1,
							<cfqueryparam value="#arguments.FrmStruct.AttachmentTypeID#" cfsqltype="cf_sql_varchar">
						)
					</cfquery>
					<cfquery name="qInsertAttachmentTypes" datasource="#dsn#">
						INSERT INTO MultipleFileAttachmentsTypes 
						VALUES(newid(),
							<cfqueryparam cfsqltype="cf_sql_integer" value="#resFa.GENERATEDKEY#">,
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.FrmStruct.AttachmentTypeID#">)
					</cfquery>
				</cfif>
			</cfif>
			<cfset DirectoryDelete(rootPath,true)>
			<cfif len(trim(arguments.FrmStruct.AttachmentID))>
				<cfinvoke method="DeleteAttachment">
					<cfinvokeargument name="AttachmentID" value="#arguments.FrmStruct.AttachmentID#">
					<cfinvokeargument name="AttachmentFileName" value="#arguments.FrmStruct.AttachmentFileName#">
				</cfinvoke>
			</cfif>
		</cfif>
	</cffunction>

	<cffunction name="DeleteAttachment" access="public" returntype="void">
		<cfargument name="AttachmentID" required="true" type="string">
		<cfargument name="AttachmentFileName" required="true" type="string">

		<cfinvoke component="cfc.carrier" method="GetSystemConfig" returnVariable="qSystemConfig"></cfinvoke>
		<cfset var dsn=trim(listFirst(cgi.SCRIPT_NAME,'/'))>
		<cfquery name="qrygetCommonDropBox" datasource="LoadManagerAdmin">
			SELECT <cfif len(trim(qSystemConfig.DropBoxAccessToken))>'#qSystemConfig.DropBoxAccessToken#'<cfelse>DropBoxAccessToken</cfif> AS DropBoxAccessToken 
			FROM SystemSetup
		</cfquery>
		<cfset tmpStruct = {"path":"/fileupload/img/#qSystemConfig.CompanyCode#/#arguments.AttachmentFileName#"}>
		<cfhttp method="post" url="https://api.dropboxapi.com/2/files/delete" result="returnStruct">
			<cfhttpparam type="HEADER" name="Authorization" value="Bearer #qrygetCommonDropBox.DropBoxAccessToken#">
			<cfhttpparam type="HEADER" name="Content-Type" value="application/json">
			<cfhttpparam type="body" value="#serializeJSON(tmpStruct)#">
		</cfhttp>	

		<cfquery name="deleteItems" datasource="#dsn#">
			delete from FileAttachments where attachment_Id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.AttachmentID#">
			delete from MultipleFileAttachmentsTypes where attachmentId = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.AttachmentID#"> 
		</cfquery>
	</cffunction>

	<cffunction name="GetCarrierACH" access="public" returntype="query">
		<cfargument name="CarrierID" required="true" type="string">
		<cfquery name="qCarrierACH" datasource="#trim(listFirst(cgi.SCRIPT_NAME,'/'))#">
			SELECT ACHBankName,ACHBankAddress,ACHBankCity,ACHBankState,ACHBankZip,ACHBankPhone,ACHBankPhoneExt,ACHBankRoutingNumber,ACHBankCheckingAccountNumber FROM Carriers
			WHERE CarrierID = <cfqueryparam value="#arguments.CarrierID#" cfsqltype="cf_sql_varchar">
		</cfquery>
		<cfreturn qCarrierACH>
	</cffunction>

	<cffunction name="SaveCarrierACH" access="public" returntype="void">
		<cfargument name="CarrierID" required="true" type="string">
		<cfargument name="FrmStruct" required="true" type="struct">

		<cfquery name="qUpd" datasource="#trim(listFirst(cgi.SCRIPT_NAME,'/'))#">
			UPDATE Carriers SET 
			ACHBankName = <cfqueryparam value="#arguments.FrmStruct.ACHBankName#" cfsqltype="cf_sql_varchar"> 
			,ACHBankAddress = <cfqueryparam value="#arguments.FrmStruct.ACHBankAddress#" cfsqltype="cf_sql_varchar"> 
			,ACHBankCity = <cfqueryparam value="#arguments.FrmStruct.ACHBankCity#" cfsqltype="cf_sql_varchar"> 
			,ACHBankState = <cfqueryparam value="#arguments.FrmStruct.ACHBankState#" cfsqltype="cf_sql_varchar"> 
			,ACHBankZip = <cfqueryparam value="#arguments.FrmStruct.ACHBankZip#" cfsqltype="cf_sql_varchar"> 
			,ACHBankPhone = <cfqueryparam value="#arguments.FrmStruct.ACHBankPhone#" cfsqltype="cf_sql_varchar">
			,ACHBankPhoneExt = <cfqueryparam value="#arguments.FrmStruct.ACHBankPhoneExt#" cfsqltype="cf_sql_varchar">
			,ACHBankRoutingNumber = <cfqueryparam value="#arguments.FrmStruct.ACHBankRoutingNumber#" cfsqltype="cf_sql_varchar">
			,ACHBankCheckingAccountNumber = <cfqueryparam value="#arguments.FrmStruct.ACHBankCheckingAccountNumber#" cfsqltype="cf_sql_varchar">
			WHERE  CarrierID = <cfqueryparam value="#arguments.CarrierID#" cfsqltype="cf_sql_varchar">
		</cfquery>
	</cffunction>

	<cffunction name="SaveELDStatus" access="public" returntype="void">
		<cfargument name="CarrierID" required="true" type="string">
		<cfargument name="FrmStruct" required="true" type="struct">

		<cfquery name="qUpd" datasource="#trim(listFirst(cgi.SCRIPT_NAME,'/'))#">
			UPDATE Carriers SET 
			ELDComplianceStatus = <cfif structkeyexists(arguments.FrmStruct,"ELDStatus")><cfqueryparam value="#arguments.FrmStruct.ELDStatus#" cfsqltype="cf_sql_integer"><cfelse>NULL</cfif>
			WHERE  CarrierID = <cfqueryparam value="#arguments.CarrierID#" cfsqltype="cf_sql_varchar">
		</cfquery>
	</cffunction>

	<cffunction name="SaveCertifications" access="public" returntype="void">
		<cfargument name="CarrierID" required="true" type="string">
		<cfargument name="FrmStruct" required="true" type="struct">

		<cfquery name="qUpd" datasource="#trim(listFirst(cgi.SCRIPT_NAME,'/'))#">
			UPDATE Carriers SET 
			Certifications = <cfif structkeyexists(arguments.FrmStruct,"Certifications")><cfqueryparam value="#arguments.FrmStruct.Certifications#" cfsqltype="cf_sql_varchar"><cfelse>NULL</cfif>
			,HazmatNumber = <cfqueryparam value="#arguments.FrmStruct.HazmatNumber#" cfsqltype="cf_sql_varchar"  null="#not len(arguments.FrmStruct.HazmatNumber)#">
			,CTPATSVINumber = <cfqueryparam value="#arguments.FrmStruct.CTPATSVINumber#" cfsqltype="cf_sql_varchar" null="#not len(arguments.FrmStruct.CTPATSVINumber)#">
			WHERE  CarrierID = <cfqueryparam value="#arguments.CarrierID#" cfsqltype="cf_sql_varchar">
		</cfquery>
	</cffunction>

	<cffunction name="GetCarrierELDAndCertification" access="public" returntype="query">
		<cfargument name="CarrierID" required="true" type="string">
		<cfquery name="qCarrierELDCert" datasource="#trim(listFirst(cgi.SCRIPT_NAME,'/'))#">
			SELECT ELDComplianceStatus,Certifications,HazmatNumber,CTPATSVINumber FROM Carriers
			WHERE CarrierID = <cfqueryparam value="#arguments.CarrierID#" cfsqltype="cf_sql_varchar">
		</cfquery>
		<cfreturn qCarrierELDCert>
	</cffunction>

	<cffunction name="CheckOnboardStatus" access="public" returntype="numeric">
		<cfargument name="CarrierID" required="true" type="string">
		<cfquery name="qCheckOnboardStatus" datasource="#trim(listFirst(cgi.SCRIPT_NAME,'/'))#">
			SELECT OnboardStatus FROM Carriers WHERE CarrierID = <cfqueryparam value="#arguments.CarrierID#" cfsqltype="cf_sql_varchar"> 
		</cfquery>
		<cfif qCheckOnboardStatus.recordCount>
			<cfreturn qCheckOnboardStatus.OnboardStatus>
		<cfelse>
			<cfreturn 2>
		</cfif>
	</cffunction>
	<cffunction  name="CheckCarrierExist" access="public" returntype="any">
		<cfargument name="CarrierID" required="true" type="string">
		<cfquery name="qCheckCarrierExist" datasource="#trim(listFirst(cgi.SCRIPT_NAME,'/'))#">
			select count(CarrierID) AS carrierCount FROM Carriers WHERE CarrierID = <cfqueryparam value="#arguments.CarrierID#" cfsqltype="cf_sql_varchar">
		</cfquery>
		<cfreturn qCheckCarrierExist.carrierCount>
	</cffunction>
	<cffunction name="AttachInsuranceCertificate" access="public" returntype="any" output="yes">
		<cfargument name="CarrierID" required="true" type="string">
		<cfargument name="FrmStruct" required="true" type="struct">
		<cfargument name="AttachmentLabel" required="true" type="string">
		<cfargument name="file" required="true" type="any">
		<cfargument name="fileField" required="true" type="string">
		<cfargument name="InsExpDate" required="false" type="string">

		<cftry>
		<cfif len(trim(arguments.file) )>
			<cfinvoke component="cfc.carrier" method="GetSystemConfig" returnVariable="qSystemConfig"></cfinvoke>
			<cfset var dsn=trim(listFirst(cgi.SCRIPT_NAME,'/'))>
			<cfquery name="qrygetCommonDropBox" datasource="LoadManagerAdmin">
				SELECT <cfif len(trim(qSystemConfig.DropBoxAccessToken))>'#qSystemConfig.DropBoxAccessToken#'<cfelse>DropBoxAccessToken</cfif> AS DropBoxAccessToken 
				FROM SystemSetup
			</cfquery>

			<cfset var rootPath = "#expandPath("\#dsn#\www\webroot\CarrierOnBoard\Temp_CarrierOnBoard_#arguments.CarrierID#_#dateTimeFormat(now(),'YYMMDDHHNNSSL')#\")#">
			<cfif not directoryExists(rootPath)>
				<cfdirectory action = "create" directory = "#rootPath#" > 
			</cfif>
			<cffile action="upload" fileField="#arguments.fileField#" nameconflict="overwrite" destination="#rootPath#">
			<cfset var tempFileName = REReplace(Replace("#cffile.CLIENTFILENAME#",":","_","ALL"), "[^A-Za-z0-9_.]","","all")>
			<cfif len(tempFileName) GT 0>
				<cfset var UploadedFile = tempFileName&"_"&dateTimeFormat(now(),'YYMMDDHHNNSS')&"."&cffile.CLIENTFILEEXT>
			<cfelse>	
				<cfset var UploadedFile = "file_"&dateTimeFormat(now(),'YYMMDDHHNNSS')&"."&cffile.CLIENTFILEEXT>
			</cfif>
						
			<cffile action="rename" source="#rootPath#/#cffile.CLIENTFILE#" destination="#rootPath#/#UploadedFile#">

			<cfhttp method="post" url="https://api.dropboxapi.com/2/users/get_current_account" result="returnStruct"> 
				<cfhttpparam type="HEADER" name="Authorization" value="Bearer #qrygetCommonDropBox.DropBoxAccessToken#">		
			</cfhttp> 
			<cfif returnStruct.Statuscode EQ "200 OK"> <!--- Authorization Success --->
				<cfhttp method="POST" url="https://api.dropboxapi.com/2/files/get_metadata"	result="returnStruct"> 
					<cfhttpparam type="HEADER" name="Authorization" value="Bearer #qrygetCommonDropBox.DropBoxAccessToken#">			
					<cfhttpparam type="HEADER" name="Content-Type" value="application/json">			
					<cfhttpparam type="body" value='{"path": "/fileupload/img/#qSystemConfig.CompanyCode#"}'>	
				</cfhttp>	
				<cfif returnStruct.Statuscode NEQ "200 OK"> <!--- Folder Not Found, Create Folder ---->	
					<cfset tmpStruct = { "path" = '/fileupload/img/#qSystemConfig.CompanyCode#'}>
					<cfhttp method="post" url="https://api.dropboxapi.com/2/files/create_folder" result="returnStructCreateFolder"> 
						<cfhttpparam type="HEADER" name="Authorization" value="Bearer #qrygetCommonDropBox.DropBoxAccessToken#">		
						<cfhttpparam type="HEADER" name="Content-Type" value="application/json">
						<cfhttpparam type="body" value="#serializeJSON(tmpStruct)#">
					</cfhttp> 
				</cfif>
				<cfset tmpStruct = {"path":"/fileupload/img/#qSystemConfig.CompanyCode#/#UploadedFile#","mode":{".tag":"add"},"autorename":true}>

				<cffile action = "readbinary" file = "#rootPath#/#UploadedFile#" variable="filcontent">
				<cfhttp method="post" url="https://content.dropboxapi.com/2/files/upload" result="returnStruct"> <cfhttpparam type="HEADER" name="Authorization" value="Bearer #qrygetCommonDropBox.DropBoxAccessToken#">		
					<cfhttpparam type="HEADER" name="Content-Type" value="application/octet-stream">
					<cfhttpparam type="HEADER" name="Dropbox-API-Arg" value="#serializeJSON(tmpStruct)#">
					<cfhttpparam type="body" value="#filcontent#">
				</cfhttp>
				<cfif returnStruct.Statuscode EQ "200 OK">
					<cfquery name="qIns" datasource="#dsn#" result="resFa">
						INSERT INTO FileAttachments(
							linked_Id,
							linked_to,
							attachedFileLabel,
							attachmentFileName,
							uploadedBy,
							DropBoxFile
							<cfif isDefined('arguments.InsExpDate')>
								,InsExpDate
							</cfif>
						) VALUES (
							<cfqueryparam value="#arguments.CarrierID#" cfsqltype="cf_sql_varchar">,
							3,
							<cfqueryparam value="#arguments.AttachmentLabel#" cfsqltype="cf_sql_varchar">,
							<cfqueryparam value="#UploadedFile#" cfsqltype="cf_sql_varchar">,
							'Carrier',
							1
							<cfif isDefined('arguments.InsExpDate')>
								,<cfqueryparam value="#arguments.InsExpDate#" cfsqltype="cf_sql_date">
							</cfif>
						)
					</cfquery>
				</cfif>
			</cfif>
			<cfset DirectoryDelete(rootPath,true)>
		</cfif>
		<cfcatch type="any">
			<cfif Find("Saving empty (zero-length) files is prohibited", CFCatch.Detail) GT 0>
				<cfreturn 'error'>
			</cfif>
		</cfcatch>
		</cftry>
	</cffunction>
	<cffunction  name="GetBIPDInsuranceCertificate" access="public" returntype="query">
		<cfargument name="CarrierID" required="true" type="string">
		<cfquery name="qGetInsuranceCertificate" datasource="#trim(listFirst(cgi.SCRIPT_NAME,'/'))#">
			SELECT TOP 1 AttachmentFileName,attachedFileLabel,attachment_Id,UploadedDateTime FROM FileAttachments
			WHERE attachedFileLabel = 'InsuranceBIPD'
			AND linked_Id = <cfqueryparam value="#arguments.CarrierID#" cfsqltype="cf_sql_varchar">
			ORDER BY UploadedDateTime 
		</cfquery>
		<cfreturn qGetInsuranceCertificate>
	</cffunction>
	<cffunction  name="GetCargoInsuranceCertificate" access="public" returntype="query">
		<cfargument name="CarrierID" required="true" type="string">
		<cfquery name="qGetInsuranceCertificate" datasource="#trim(listFirst(cgi.SCRIPT_NAME,'/'))#">
			SELECT TOP 1 AttachmentFileName,attachedFileLabel,attachment_Id,UploadedDateTime FROM FileAttachments
			WHERE attachedFileLabel = 'InsuranceCargo'
			AND linked_Id = <cfqueryparam value="#arguments.CarrierID#" cfsqltype="cf_sql_varchar">
			ORDER BY UploadedDateTime 
		</cfquery>
		<cfreturn qGetInsuranceCertificate>
	</cffunction>
	<cffunction  name="GetGeneralInsuranceCertificate" access="public" returntype="query">
		<cfargument name="CarrierID" required="true" type="string">
		<cfquery name="qGetInsuranceCertificate" datasource="#trim(listFirst(cgi.SCRIPT_NAME,'/'))#">
			SELECT TOP 1 AttachmentFileName,attachedFileLabel,attachment_Id,UploadedDateTime FROM FileAttachments
			WHERE attachedFileLabel = 'InsuranceGeneral'
			AND linked_Id = <cfqueryparam value="#arguments.CarrierID#" cfsqltype="cf_sql_varchar">
			ORDER BY UploadedDateTime 
		</cfquery>
		<cfreturn qGetInsuranceCertificate>
	</cffunction>
	<cffunction  name="GetCopyOfVoidedCheck" access="public" returntype="query">
		<cfargument name="CarrierID" required="true" type="string">
		<cfquery name="qGetCopyOfVoidedCheck" datasource="#trim(listFirst(cgi.SCRIPT_NAME,'/'))#">
			SELECT TOP 1 AttachmentFileName,attachedFileLabel,attachment_Id,UploadedDateTime FROM FileAttachments
			WHERE attachedFileLabel = 'Copy of voided check'
			AND linked_Id = <cfqueryparam value="#arguments.CarrierID#" cfsqltype="cf_sql_varchar">
			ORDER BY UploadedDateTime 
		</cfquery>
		<cfreturn qGetCopyOfVoidedCheck>
	</cffunction>
</cfcomponent>

