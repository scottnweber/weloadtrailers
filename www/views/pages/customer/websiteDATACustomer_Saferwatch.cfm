<cftry>
	<cfparam name="customerid" default="0">
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
		SELECT SaferWatch,SaferWatchWebKey,SaferWatchCustomerKey,FreightBroker,SaferWatchUpdateCarrierInfo,SaferWatchCertData FROM SystemConfig WHERE CompanyID = <cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar">
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
		<cfif  variables.responsestatus.ResponseDO.action EQ "OK" AND structKeyExists(variables.responsestatus,"CarrierDetails")>	 <cfif editid eq 0>
				<cfset CustomerName 		= variables.responsestatus.CarrierDetails.Identity.legalName>
				<cfset  location 				= variables.responsestatus.CarrierDetails.Identity.businessStreet>				
				<cfset  City 						= variables.responsestatus.CarrierDetails.Identity.businessCity>
				<cfset  StateValCODE 	= variables.responsestatus.CarrierDetails.Identity.businessState>
				<cfset  state1					= StateValCODE>
				<cfset  Zipcode 				= variables.responsestatus.CarrierDetails.Identity.businessZipCode>
				<cfset  Country1				= variables.responsestatus.CarrierDetails.Identity.businessCountry>					
								
				<cfset  PhoneNO 					= variables.responsestatus.CarrierDetails.Identity.businessPhone>
				<cfset  businessPhone	= variables.responsestatus.CarrierDetails.Identity.businessPhone>
				<cfset  Fax 						= variables.responsestatus.CarrierDetails.Identity.businessFax>
				<cfset  Dotnumber 			= variables.responsestatus.CarrierDetails.dotNumber>
				<cfset  Email 					=  replace(variables.responsestatus.CarrierDetails.Identity.emailAddress,' ','','all')>
				<cfset org_Dotnumber	=Dotnumber>
				<cfset risk_assessment = variables.responsestatus .CarrierDetails.RiskAssessment.Overall>
				<cfset  CellPhone 			= variables.responsestatus.CarrierDetails.Identity.cellPhone>
			</cfif>
			<cfif 	structKeyExists(variables.responsestatus.CarrierDetails,"docketNumber")	AND  len(variables.responsestatus.CarrierDetails.docketNumber) GT 0 >				
				<cfset MCNumber    		= right(variables.responsestatus.CarrierDetails.docketNumber,len(variables.responsestatus.CarrierDetails.docketNumber)-2)>																
			</cfif>
				
			<cfif org_Dotnumber EQ variables.responsestatus.CarrierDetails.dotNumber >
				<cfset risk_assessment = variables.responsestatus .CarrierDetails.RiskAssessment.Overall>
			</cfif>
			<cfset bit_addWatch 		= 1 >
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