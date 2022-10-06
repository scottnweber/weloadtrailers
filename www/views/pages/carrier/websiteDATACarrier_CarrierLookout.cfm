<cftry>
	<cfquery name="qSystemSetupOptions" datasource="#Application.dsn#">
		SELECT CarrierLookoutAPIKey
		FROM SystemConfig WHERE CompanyID = <cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar">
	</cfquery>

	<cfif isdefined('url.mcNo') and len(url.mcNo) gt 1>
		<cfset MC_Number = trim(url.mcNo)>
        <cfset MC_Number = replaceNoCase(MC_Number, " ", "","ALL")>
        <cfset MC_Number = replaceNoCase(MC_Number, "MC", "")>
        <cfset MC_Number = replaceNoCase(MC_Number, "-", "")>
        <cfset MC_Number = replaceNoCase(MC_Number, "##", "")>
        <cfset MC_Number = REReplace(MC_Number,"^0+","")>
        <cfset MC_Number = "MC"&MC_Number>
        <cfhttp url="https://api.carriersoftware.com/api/DOTByMC/#MC_Number#" method="get"  throwonerror = Yes result="objCarrierInsuranceDot" timeout="300">
          <cfhttpparam type="header" name="API_KEY" value="#trim(qSystemSetupOptions.CarrierLookoutAPIKey)#"/>
        </cfhttp>
        <cfset DOT_Number = DeserializeJSON(objCarrierInsuranceDot.Filecontent).DotNumber> 		
	<cfelseif isdefined('url.DOTNumber') and len(url.DOTNumber) gt 1>
		<cfset DOT_Number = trim(url.DOTNumber)> 
    </cfif>

    	

	<cfhttp url="https://api.carriersoftware.com/api/CarrierInsurance?dot=#DOT_Number#" method="get"  throwonerror = Yes result="objCarrierInsurance">
		<cfhttpparam type="header" name="API_KEY" value="#qSystemSetupOptions.CarrierLookoutAPIKey#"/>
	</cfhttp>

	<cfhttp url="https://api.carriersoftware.com/api/DOT/#DOT_Number#" method="get"  throwonerror = Yes result="objCarrierInsuranceDot" timeout="300">
      <cfhttpparam type="header" name="API_KEY" value="#trim(qSystemSetupOptions.CarrierLookoutAPIKey)#"/>
    </cfhttp>

	<cfif objCarrierInsurance.Statuscode EQ '200 OK'>

		<cfset CarrierInsurance = DeserializeJSON(objCarrierInsurance.Filecontent)>
		<cfset CarrierInsuranceDOT = DeserializeJSON(objCarrierInsuranceDot.Filecontent)>
		<cfif not ArrayIsEmpty(CarrierInsurance.CarrierDockets)>
			<cfset CarrierName 		= CarrierInsurance.CarrierDockets[1].LegalName>
			<cfset vendorID = Left(ReplaceNoCase(CarrierInsurance.CarrierDockets[1].LegalName," ","","ALL"),10)>
			<cfset Address 			= CarrierInsurance.CarrierDockets[1].Address>	
			<cfset City 			= CarrierInsurance.CarrierDockets[1].City>	
			<cfset State11      	= CarrierInsurance.CarrierDockets[1].State>	
			<cfset Zipcode 			= CarrierInsurance.CarrierDockets[1].Zip>	
			<cfset Country1			= CarrierInsurance.CarrierDockets[1].Country>	
			<cfset MCNumber 		= replaceNoCase(CarrierInsurance.CarrierDockets[1].DocketNo, "MC", "") >
			<cfif structKeyExists(CarrierInsuranceDOT, "EmailAddress")>
	            <cfset Email = CarrierInsuranceDOT.EmailAddress>
	        </cfif>
	        <cfif structKeyExists(CarrierInsurance.CarrierDockets[1], "Phone")>
            	<cfset businessPhone = formatPhoneNumber(CarrierInsurance.CarrierDockets[1].Phone)>
          	</cfif>
          	<cfif structKeyExists(CarrierInsuranceDOT, "FaxNumber")>
	            <cfset Fax = formatPhoneNumber(CarrierInsuranceDOT.FaxNumber)>
	        <cfelseif structKeyExists(CarrierInsurance.CarrierDockets[1], "Fax")>
	            <cfset Fax = formatPhoneNumber(CarrierInsurance.CarrierDockets[1].Fax)>
	        </cfif>
	        <cfif structKeyExists(CarrierInsuranceDOT, "CellPhone")>
	            <cfset CellPhone = formatPhoneNumber(CarrierInsuranceDOT.CellPhone)>
	        </cfif>
	        <cfif structKeyExists(CarrierInsuranceDOT, "CompanyRep1")>
            	<cfset ContactPerson = CarrierInsuranceDOT.CompanyRep1>
          	<cfelseif structKeyExists(CarrierInsuranceDOT, "CompanyRep2")>
            	<cfset ContactPerson = CarrierInsuranceDOT.CompanyRep2>
          	</cfif>
			<cfset insExpired = 0>
			<cfset insCount = 0>
			<cfloop array="#CarrierInsurance.CarrierDockets[1].Insurances#" index="Insurance">
				<cfif Insurance.InsType EQ 1>
					<cfset insCarrier	= Insurance.InsCarrier>
					<cfset InsAgentPhone = formatPhoneNumber(CarrierInsurance.CarrierDockets[1].phone)>
					<cfset insPolicy 	= Insurance.PolicyNo>
					<cfset InsExpDateLive = DateAdd("yyyy",1,Insurance.InsEffDate)>
					<cfif DateDiff("d", InsExpDateLive, now()) GT 0>
						<cfset insExpired = 1>
					</cfif>
					<cfset InsLimit=Insurance.BiPdMaxLim*1000>
					<cfset insCount = insCount+1>
				<cfelseif Insurance.InsType EQ 2>
					<cfset InsCompanyCargo	= Insurance.InsCarrier>
					<cfset InsComPhoneCargo = formatPhoneNumber(CarrierInsurance.CarrierDockets[1].phone)>
					<cfset InsPolicyNoCargo = Insurance.PolicyNo>
					<cfset InsExpDateCargo = DateAdd("yyyy",1,Insurance.InsEffDate)>
					<cfif DateDiff("d", InsExpDateCargo, now()) GT 0>
						<cfset insExpired = 1>
					</cfif>
					<cfset InsLimitCargo = Insurance.BiPdMaxLim*1000>
					<cfset insCount = insCount+1>
				</cfif>
			</cfloop>

			<cfif insExpired>
				<cfset risk_assessment = 'Unacceptable'>
			<cfelseif insCount NEQ 3>
				<cfset risk_assessment = 'Moderate'>
			<cfelse>
				<cfset risk_assessment = 'Acceptable'>
			</cfif>
			<cfset source = 'Carrier Lookout'>
		<cfelse>
			<cfif structkeyExists(url,"mcNo") >
				<cfset MCNumber = url.mcNo >
				<cfset message="Data not available. Please check the mc## and try again.">
			</cfif>
			<cfif structkeyExists(url,"DOTNumber") >
				<cfset Dotnumber = url.DOTNumber >
				<cfset message="Data not available. Please check the DOT## and try again.">
			</cfif>
		</cfif>
	</cfif>

	<cfif isDefined('mcnumber') AND len(trim(mcnumber)) AND isDefined('dotnumber') AND len(trim(dotnumber)) AND isDefined('CarrierName') AND len(trim(CarrierName))>
		<cfquery name="qGetMC_DOT" datasource="ZFMCSA">
          	select COUNT(id) AS count from MC_DOT WHERE MC = <cfqueryparam value="#MCNumber#" cfsqltype="cf_sql_varchar"> AND DOT = <cfqueryparam value="#dotnumber#" cfsqltype="cf_sql_varchar">
        </cfquery>
        <cfif not qGetMC_DOT.count>
        	<cfquery name="qInsMC_DOT" datasource="ZFMCSA">
        		INSERT INTO [dbo].[MC_DOT]
			           ([DOT]
			           ,[MC]
			           ,[Updated]
			           ,[Carrier Name])
			     VALUES
			           (<cfqueryparam value="#dotnumber#" cfsqltype="cf_sql_varchar">
			           ,<cfqueryparam value="#MCNumber#" cfsqltype="cf_sql_varchar">
			           ,GETDATE()
			           ,<cfqueryparam value="#CarrierName#" cfsqltype="cf_sql_varchar">)
        	</cfquery>
        </cfif>
	</cfif>
	
	<cffunction name="formatPhoneNumber">
		<cfargument name="phoneNumber" required="true" />
		<cfif len(phoneNumber) EQ 10>
				<cfreturn "#left(phoneNumber,3)#-#mid(phoneNumber,4,3)#-#right(phoneNumber,4)#" />
		<cfelse>
			<cfreturn phoneNumber />
		</cfif>
	</cffunction>

	<cfcatch type="any">
		<cfif structkeyExists(url,"mcNo") >
			<cfset message="Data not available. Please check the mc## and try again.">
		</cfif>
		<cfif structkeyExists(url,"DOTNumber") >
			<cfset message="Data not available. Please check the DOT## and try again.">
		</cfif>
	</cfcatch>
</cftry>