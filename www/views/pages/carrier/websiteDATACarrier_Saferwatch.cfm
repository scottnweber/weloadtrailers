<cftry>
	<cfparam name="carrierid" default="0">
	<cfset session.AuthType_Common_status="">
	<cfset session.AuthType_Common_appPending="">
	<cfset session.AuthType_Contract_status="">
	<cfset session.AuthType_Contract_appPending="">
	<cfset session.AuthType_Broker_status="">
	<cfset session.AuthType_Broker_appPending="">
	<cfset session.household_goods="">
	<cfset session.bipd_Insurance_required="">
	<cfset session.bipd_Insurance_on_file="">
	<cfset session.cargo_Insurance_required="">
	<cfset session.cargo_Insurance_on_file="">
	<cfset SaferWatchTimeout = 10>
	<cfset SaferWatchWebKey 				= request.qGetSystemSetupOptions.SaferWatchWebKey>
	<cfset SaferWatchCustomerKey 	= request.qGetSystemSetupOptions.SaferWatchCustomerKey>

	<cfif isdefined('url.mcNo') and len(url.mcNo) gt 1>
		<cfset DOT_Number ="MC"& trim(url.mcNo)>  		
	<cfelseif isdefined('url.DOTNumber') and len(url.DOTNumber) gt 1>
		<cfset DOT_Number = trim(url.DOTNumber)> 
    </cfif>
	
	<cfquery name="qSystemSetupOptions" datasource="#Application.dsn#">
		SELECT SaferWatch,SaferWatchWebKey,SaferWatchCustomerKey,FreightBroker,SaferWatchUpdateCarrierInfo,SaferWatchCertData
		FROM SystemConfig WHERE CompanyID = <cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar">
	</cfquery>	 
	
	<cfhttp url="http://www.saferwatch.com/webservices/CarrierService32.php?Action=CarrierLookup&ServiceKey=#SaferWatchWebKey#&CustomerKey=#SaferWatchCustomerKey#&number=#trim(DOT_Number)#" method="get"   TIMEOUT="#SaferWatchTimeout#" throwonerror = Yes>
	</cfhttp>

	<cfif cfhttp.Statuscode EQ '200 OK'>	
		<cfset variables.responsestatus = structNew()>		
		<cfset variables.responsestatus = ConvertXmlToStruct(cfhttp.Filecontent, StructNew()) >
		<cfset CarrierXmlData=XMLParse(cfhttp.Filecontent) >
		<cfif  NOT structKeyExists(variables.responsestatus,"CarrierDetails") AND structKeyExists(variables.responsestatus,"ResponseDO")  AND variables.responsestatus.ResponseDO.action EQ "FAILED">
			<cfset message = variables.responsestatus.ResponseDO.displayMsg>
		</cfif>

		<cfif  structKeyExists(variables.responsestatus,"CarrierDetails") AND NOT (structKeyExists(variables.responsestatus.CarrierDetails,"CertData")   AND isStruct(variables.responsestatus.CarrierDetails.CertData)
		AND qSystemSetupOptions.SaferWatchCertData EQ 1) AND NOT qSystemSetupOptions.SaferWatchCertData EQ 0  
		AND CarrierXmlData['CarrierService32.CarrierLookup'].CarrierDetails.CertData.XmlAttributes.status EQ "ACCOUNTEXPIRED">
			<cfset session.errmessage = "Your SaferWatch account does not have CertData access setup. Please contact support to get this fixed." >
		</cfif>
		
		<cfif  variables.responsestatus.ResponseDO.action EQ "OK" AND structKeyExists(variables.responsestatus,"CarrierDetails")>												
			<cfif (qSystemSetupOptions.SaferWatchUpdateCarrierInfo AND carrierid GT 0 ) OR (carrierid EQ 0) >
				<cfset CarrierName 		= variables.responsestatus.CarrierDetails.Identity.legalName>
				<cfset  Address 				= variables.responsestatus.CarrierDetails.Identity.businessStreet>				
				<cfset  City 						= variables.responsestatus.CarrierDetails.Identity.businessCity>
				<cfset  StateValCODE 	= variables.responsestatus.CarrierDetails.Identity.businessState>
				<cfset  State11					= StateValCODE>
				<cfset  Zipcode 				= variables.responsestatus.CarrierDetails.Identity.businessZipCode>
				<cfset  Country1				= variables.responsestatus.CarrierDetails.Identity.businessCountry>					
									
				<cfset  Phone 					= variables.responsestatus.CarrierDetails.Identity.businessPhone>
				<cfset  businessPhone	= variables.responsestatus.CarrierDetails.Identity.businessPhone>
				<cfset  Fax 						= variables.responsestatus.CarrierDetails.Identity.businessFax>
				<cfset  Dotnumber 			= variables.responsestatus.CarrierDetails.dotNumber>
				<cfset  Email 					=  replace(variables.responsestatus.CarrierDetails.Identity.emailAddress,' ','','all')>
				<cfset org_Dotnumber	=Dotnumber>
				<cfset risk_assessment = variables.responsestatus .CarrierDetails.RiskAssessment.Overall>
				<cfset  CellPhone 			= variables.responsestatus.CarrierDetails.Identity.cellPhone>

				<cfif carrierid GT 0>
					<cfinvoke component="#variables.objCarrierGateway#" method="getAllCarriers" returnvariable="request.qCarrier">
						<cfinvokeargument name="carrierid" value="#carrierid#">
					</cfinvoke>
					<cfset RemitName=request.qCarrier.RemitName>
					<cfset RemitAddress=request.qCarrier.RemitAddress>
					<cfset RemitCity=request.qCarrier.RemitCity>
					<cfset RemitState=request.qCarrier.RemitState>
					<cfset RemitZipCode=request.qCarrier.RemitZipCode>
					<cfset RemitContact=request.qCarrier.RemitContact>
					<cfset RemitPhone=request.qCarrier.RemitPhone>
					<cfset RemitFax=request.qCarrier.RemitFax>
					<cfset carrierEmailAvailableLoads=request.qCarrier.CarrierEmailAvailableLoads>
					<cfset isShowDollar=request.qCarrier.isShowDollar>
				</cfif>
			<cfelseif qSystemSetupOptions.SaferWatchUpdateCarrierInfo EQ 0 AND carrierid GT 0  >
				<cfinvoke component="#variables.objCarrierGateway#" method="getAllCarriers" returnvariable="request.qCarrier">
					<cfinvokeargument name="carrierid" value="#carrierid#">
				</cfinvoke>
				<cfinvoke component="#variables.objCarrierGateway#" method="getLIWebsiteData" returnvariable="request.qLiWebsiteData">
					<cfinvokeargument name="carrierid" value="#url.carrierid#">
				</cfinvoke>
				<cfinvoke component="#variables.objCarrierGateway#" method="getCommodityById"  returnvariable="request.qGetCommodityById" >
					<cfinvokeargument name="carrierID" value="#url.carrierid#">
				</cfinvoke>
				<cfinvoke component="#variables.objCarrierGateway#" method="getlifmcaDetails" returnvariable="request.qrygetlifmcaDetails">
					<cfinvokeargument name="carrierid" value="#url.carrierid#">
				</cfinvoke>
				<cfset CarrierName		=request.qCarrier.CarrierName>
				<cfset Address				=request.qCarrier.Address>
				<cfset StateValCODE	=trim(request.qCarrier.StateCODE)>	
				<cfset  State11					= StateValCODE>
				<cfset City						=request.qCarrier.City>
				<cfset Zipcode				=request.qCarrier.Zipcode>
				<cfset Country1				=request.qCarrier.Country>
				<cfset Phone					=formatPhoneNumber(request.qCarrier.Phone)>
				<cfset  businessPhone	=formatPhoneNumber(request.qCarrier.Phone)>
				<cfset Fax						=request.qCarrier.Fax> 
				<cfset Email					=request.qCarrier.EmailID>
				<cfset Dotnumber			=request.qCarrier.DOTNUMBER>
				<cfset org_Dotnumber	=request.qCarrier.DOTNUMBER>
				<cfset Tollfree 				=request.qCarrier.TollFree>
				<cfset CellPhone			=request.qCarrier.Cel>
				<cfset TaxID=request.qCarrier.TaxID>
				<cfset Website				=request.qCarrier.website>
				<cfset ContactPerson	=request.qCarrier.ContactPerson>
				<cfset RemitName=request.qCarrier.RemitName>
				<cfset RemitAddress=request.qCarrier.RemitAddress>
				<cfset RemitCity=request.qCarrier.RemitCity>
				<cfset RemitState=request.qCarrier.RemitState>
				<cfset RemitZipCode=request.qCarrier.RemitZipCode>
				<cfset RemitContact=request.qCarrier.RemitContact>
				<cfset RemitPhone=request.qCarrier.RemitPhone>
				<cfset RemitFax=request.qCarrier.RemitFax>
				<cfset CarrierInstructions=request.qCarrier.CarrierInstructions>
				<cfset EquipmentNotes=request.qCarrier.EquipmentNotes>
				<cfset equipment=request.qCarrier.EquipmentID>
				<cfset Website=request.qCarrier.Website>
				<cfset notes =request.qCarrier.notes>
				<cfset Terms =request.qCarrier.CarrierTerms>
				<cfset editid=#url.carrierid#>
				<cfset vendorID=request.qCarrier.VENDORID>
				<cfset MobileAppPassword=request.qCarrier.MobileAppPassword>
				<cfset isShowDollar=request.qCarrier.isShowDollar>
				<cfset Track1099=request.qCarrier.Track1099>
				<cfset bit_addWatch =  request.qCarrier.SaferWatch>
				<cfset InsExpDateLive = request.qCarrier.InsExpDate>
				<cfset InsLimit=request.qCarrier.InsLimit>
				<cfset bipd_Insurance_on_file =request.qCarrier.InsLimit>
				<cfset variables.ExpirationDate=request.qrygetlifmcaDetails.ExpirationDate>
				<cfset variables.CARGOExpirationDate=request.qrygetlifmcaDetails.CARGOExpirationDate>
				<cfset variables.cargoInsRequired=request.qrygetlifmcaDetails.cargoInsRequired>
				<cfset variables.BIPDInsonFile=request.qrygetlifmcaDetails.BIPDInsonFile>
				<cfset variables.cargoInsonFile=request.qrygetlifmcaDetails.cargoInsonFile>
				<cfset carrierEmailAvailableLoads=request.qCarrier.CarrierEmailAvailableLoads>
				<cfset isShowDollar=request.qCarrier.isShowDollar>
				<cfset getMCNoURL="index.cfm?event=addcarrier&carrierid=#url.carrierid#&#session.URLToken#">
			</cfif>
			<cfif 	structKeyExists(variables.responsestatus.CarrierDetails,"docketNumber")	AND  len(variables.responsestatus.CarrierDetails.docketNumber) GT 0 >				
				<cfset MCNumber    		= right(variables.responsestatus.CarrierDetails.docketNumber,len(variables.responsestatus.CarrierDetails.docketNumber)-2)>					
			</cfif>
				
			<cfif org_Dotnumber EQ variables.responsestatus.CarrierDetails.dotNumber >
				<cfset risk_assessment = variables.responsestatus .CarrierDetails.RiskAssessment.Overall>
			</cfif>
			<cfset bit_addWatch 		= 1 >
			
			<cfif IsStruct(variables.responsestatus.CarrierDetails.FMCSAInsurance.PolicyList)>
				<cfif IsArray(variables.responsestatus.CarrierDetails.FMCSAInsurance.PolicyList.PolicyItem)>
					<cfset insCarrier			= left(variables.responsestatus.CarrierDetails.FMCSAInsurance.PolicyList.PolicyItem[1].companyName,100)>
					<cfset InsAgentPhone	= formatPhoneNumber(variables.responsestatus.CarrierDetails.FMCSAInsurance.PolicyList.PolicyItem[1].phone)>
					<cfset insAgentName 	= variables.responsestatus.CarrierDetails.FMCSAInsurance.PolicyList.PolicyItem[1].attnToName>
					<cfset formatRequired  = variables.responsestatus.CarrierDetails.FMCSAInsurance.PolicyList.PolicyItem[1].address&","&variables.responsestatus.CarrierDetails.FMCSAInsurance.PolicyList.PolicyItem[1].city&" "&variables.responsestatus.CarrierDetails.FMCSAInsurance.PolicyList.PolicyItem[1].stateCode&","&variables.responsestatus.CarrierDetails.FMCSAInsurance.PolicyList.PolicyItem[1].postalCode&","&variables.responsestatus.CarrierDetails.FMCSAInsurance.PolicyList.PolicyItem[1].countryCode>
						<cfset insPolicy				= left(variables.responsestatus.CarrierDetails.FMCSAInsurance.PolicyList.PolicyItem[1].policyNumber,50)>
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
				<cfset bipd_Insurance_on_file	= variables.responsestatus.CarrierDetails.FMCSAInsurance.bipdOnFile>
				<cfset BIPDInsRequired 				= variables.responsestatus.CarrierDetails.FMCSAInsurance.bipdRequired>
				<cfset BIPDInsonFile					= variables.responsestatus.CarrierDetails.FMCSAInsurance.bipdOnFile>
				<cfset cargoInsRequired				= variables.responsestatus.CarrierDetails.FMCSAInsurance.cargoRequired>
				<cfset cargoInsonFile					= variables.responsestatus.CarrierDetails.FMCSAInsurance.cargoOnFile>					
			</cfif>
			
			<cfif structKeyExists(variables.responsestatus.CarrierDetails,"CertData") AND isStruct(variables.responsestatus.CarrierDetails.CertData) AND structKeyExists(variables.responsestatus.CarrierDetails.CertData,"Certificate") AND isStruct(variables.responsestatus.CarrierDetails.CertData.Certificate) AND structKeyExists(variables.responsestatus.CarrierDetails.CertData.Certificate,"Coverage") AND qSystemSetupOptions.SaferWatchCertData EQ 1 >	
				<cfif structKeyExists(variables.responsestatus.CarrierDetails,"FMCSAInsurance") AND isstruct(variables.responsestatus.CarrierDetails.FMCSAInsurance) AND structKeyExists(variables.responsestatus.CarrierDetails.FMCSAInsurance,"bipdOnFile")>
					<cfset bipd_Insurance_on_file	= variables.responsestatus.CarrierDetails.FMCSAInsurance.bipdOnFile>
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
					<cfset InsExpDateLive 			= variables.responsestatus.CarrierDetails.CertData.Certificate.Coverage.expirationDate>
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
			<cfif variables.responsestatus.CarrierDetails.Authority.commonAuthority  NEQ "None">
				<cfset variables.commonStatus = 1>
			<cfelse>
				<cfset variables.commonStatus = 0>
			</cfif>
			<cfif variables.responsestatus.CarrierDetails.Authority.contractAuthority  NEQ "None">
				<cfset variables.contractStatus = 1>
			<cfelse>
				<cfset variables.contractStatus = 0>
			</cfif>
			<cfif variables.responsestatus.CarrierDetails.Authority.brokerAuthority  NEQ "None">
				<cfset variables.brokerStatus = 1>
			<cfelse>
				<cfset variables.brokerStatus = 0>
			</cfif>
			<cfif variables.responsestatus.CarrierDetails.Authority.brokerAuthority  NEQ "None">
				<cfset variables.brokerStatus = 1>
			<cfelse>
				<cfset variables.brokerStatus = 0>
			</cfif>
			<cfif variables.responsestatus.CarrierDetails.Authority.commonAuthorityPending  NEQ "No">
				<cfset variables.commonAppPending = 1>
			<cfelse>
				<cfset variables.commonAppPending = 0>
			</cfif>
			<cfif variables.responsestatus.CarrierDetails.Authority.contractAuthorityPending  NEQ "No">
				<cfset variables.contractAppPending = 1>
			<cfelse>
				<cfset variables.contractAppPending = 0>
			</cfif>
			<cfif variables.responsestatus.CarrierDetails.Authority.brokerAuthorityPending  NEQ "No">
				<cfset variables.BrokerAppPending = 1>
			<cfelse>
				<cfset variables.BrokerAppPending = 0>
			</cfif>	
			<cfset message="">
			<cfif InsExpDateLive EQ "" AND isdefined("request.qCarrier")>
				<cfset InsExpDateLive = request.qCarrier.InsExpDate>
			</cfif>
			<cfif InsExpDateLive EQ "" AND isdefined("request.qCarrier")>
				<cfset InsExpDateLive = request.qCarrier.InsExpDate>
			</cfif>
			<cfif ExpirationDate EQ "" AND isdefined("request.qCarrier")>
				<cfset variables.ExpirationDate=request.qrygetlifmcaDetails.ExpirationDate>
			</cfif>
			<cfif CARGOExpirationDate EQ "" AND isdefined("request.qCarrier")>
				<cfset variables.CARGOExpirationDate=request.qrygetlifmcaDetails.CARGOExpirationDate>
			</cfif>
			<cfset source = 'Safer Watch'>
		<cfelse>
			<cfset CarrierName 		= "">					
			<cfset  Address 				= "">				
			<cfset  City 						= "">
			<cfset  StateValCODE 	= "">
			<cfset  State11					= "">
			<cfset  Zipcode 				= "">
			<cfset  Country1				= "">
			<cfset  Phone 					= "">
			<cfset  businessPhone	= "">
			<cfset  Fax 						= "">				
			<cfset  CellPhone 			= "">
			<cfset  Email 					=  "">	
			<cfif structkeyExists(url,"mcNo") >
				<cfset MCNumber = url.mcNo >
				<cfset message="Data not available. Please check the mc## and try again.">
			</cfif>
			<cfif structkeyExists(url,"DOTNumber") >
				<cfset Dotnumber = url.DOTNumber >
				<cfset message="Data not available. Please check the DOT## and try again.">
			</cfif>
			<cfif structkeyExists(variables.responsestatus.ResponseDO,"displayMsg") >
				<cfset message = variables.responsestatus.ResponseDO.displayMsg>
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
		<cfset message="Data not available. Please check the mc## and try again."&cfcatch>
	</cfif>
	<cfif structkeyExists(url,"DOTNumber") >
		<cfset message="Data not available. Please check the DOT## and try again."&cfcatch>
	</cfif>
</cfcatch>

</cftry>