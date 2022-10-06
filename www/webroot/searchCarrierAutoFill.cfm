<cfoutput>
	<cfparam default=" " name="variables.deliveryDate">
	<cfparam default="" name="risk_assessment">
	<cfparam default="" name="link">
	<cfparam default="" name="SelectedEquipmentID">
	<cfparam default="" name="iscarrier">
	<cfparam default="" name="deliveryDate">
	
	<cfset variables.deliveryDate = url.deliverydate>
	
	<cfif NOT Len(variables.deliveryDate)>
		<cfset variables.deliveryDate = dateformat(now(),'mm/dd/yyyy')>
	</cfif>
	
	<cfquery name="qSystemSetupOptions" datasource="#Application.dsn#">
    	SELECT showExpiredInsuranceCarriers
        FROM SystemConfig where companyid = <cfqueryparam value="#url.companyid#" cfsqltype="cf_sql_varchar">
    </cfquery>
	
	
	<cfquery name="qryGetSystemConfig" datasource="#Application.dsn#">
		SELECT CarrierLoadLimit, showExpiredInsuranceCarriers,CarrierLNI
	        FROM SystemConfig where companyid = <cfqueryparam value="#url.companyid#" cfsqltype="cf_sql_varchar">
	</cfquery>

	<cfquery name="qrygetFilterCarriers" datasource="#Application.dsn#" cachedwithin="#createTimespan(0, 0, 0, 15)#">
		SELECT UPPER(LTRIM(car.CarrierName)) AS Text, car.CarrierID AS Value, car.Cel AS cell, car.Fax, 
		car.EmailID,
		car.phone,car.tollfree,
		car.phoneext,car.faxext,car.tollfreeext,car.cellphoneext,
		car.RatePerMile,
		UPPER(car.CarrierName) AS carrierName, car.City, GETDATE() AS currentDate, car.stateCode, car.ZipCode, car.Address, car.InsExpDate,car.InsExpDateCargo,car.InsExpDateGeneral, e.EquipmentID, CASE car.Status WHEN 1 THEN 'ACTIVE' ELSE 'INACTIVE' END AS Status, li.ExpirationDate AS BIPDExpirationDate, li.CARGOExpirationDate, car.MCNumber, car.DOTNumber, car.RiskAssessment, car.IsCarrier, car.LoadLimit, (#qryGetSystemConfig.CarrierLoadLimit#) AS GlobalLoadLimit, COUNT('Loadstops.LoadStopID') AS TotalPickups, car.DefaultCurrency, e.unitNumber, car.ContactPerson, car.SCAC, e.isactive as eqActive, car.CalculateDHMiles

			<cfif len(trim(variables.deliveryDate)) and isdate(variables.deliveryDate)>
				,ISNULL(DATEDIFF(day,<cfqueryparam value="#variables.deliveryDate#" cfsqltype="cf_sql_date">,car.InsExpDate),1) AS bitInsExpired
				,ISNULL(DATEDIFF(day,<cfqueryparam value="#variables.deliveryDate#" cfsqltype="cf_sql_date">,car.InsExpDateCargo),1) AS bitCargoInsExpired
				<cfif qryGetSystemConfig.CarrierLNI EQ 2>
					,1
				<cfelse>
					,ISNULL(DATEDIFF(day,<cfqueryparam value="#variables.deliveryDate#" cfsqltype="cf_sql_date">,car.InsExpDateGeneral),1) 
				</cfif>
				AS bitGenInsExpired
			</cfif>
			,(SELECT COUNT(FAT.AttachmentTypeID) FROM FileAttachments FA
			INNER JOIN MultipleFileAttachmentsTypes MAT ON FA.attachment_Id = MAT.AttachmentID
			INNER JOIN FileAttachmentTypes FAT ON FAT.AttachmentTypeID = MAT.AttachmentTypeID
			WHERE DATEDIFF(month, FA.UploadedDateTime, GETDATE()) >= FAT.Interval
			AND linked_Id = convert(varchar(36),Car.CarrierID)) AS ExpDocCount
			,Car.RemitName
		FROM Carriers AS car WITH (NOLOCK) 
		LEFT JOIN LoadStops ON car.CarrierID = LoadStops.NewCarrierID AND LoadStops.StopDate = CONVERT(DATETIME, <cfqueryparam value="#url.pickupDate#" cfsqltype="cf_sql_date">, 102) AND (LoadStops.LoadType = 1)
		LEFT JOIN lipublicfmcsa AS li ON car.CarrierID = li.carrierId
		LEFT JOIN Equipments AS e ON car.EquipmentID = e.EquipmentID
		WHERE (LTRIM(car.CarrierName) LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="#url.term#%"> OR MCNumber like <cfqueryparam cfsqltype="cf_sql_varchar" value="#url.term#%"> )
		<cfif structKeyExists(url,"iscarrier") AND url.iscarrier NEQ "" AND url.iscarrier NEQ 2>
			AND ISNULL(car.iscarrier,0) = <cfqueryparam value="#url.iscarrier#" cfsqltype="cf_sql_bit">
		</cfif>
		AND car.companyid = <cfqueryparam value="#url.companyid#" cfsqltype="cf_sql_varchar">
		<cfif NOT qryGetSystemConfig.showExpiredInsuranceCarriers>			 
			AND (((DATEDIFF(DAY,getdate(),InsExpDate) >=0 <cfif len(trim(variables.deliveryDate)) and isdate(variables.deliveryDate)>AND DATEDIFF(DAY,<cfqueryparam value="#variables.deliveryDate#" cfsqltype="cf_sql_date">,InsExpDate) >=0</cfif>) OR InsExpDate IS NULL)
			AND ((DATEDIFF(DAY,getdate(),InsExpDateCargo) >=0 <cfif len(trim(variables.deliveryDate)) and isdate(variables.deliveryDate)>AND DATEDIFF(DAY,<cfqueryparam value="#variables.deliveryDate#" cfsqltype="cf_sql_date">,InsExpDateCargo) >=0</cfif>) OR InsExpDateCargo IS NULL)
			AND ((DATEDIFF(DAY,getdate(),InsExpDateGeneral) >=0 <cfif len(trim(variables.deliveryDate)) and isdate(variables.deliveryDate)>AND DATEDIFF(DAY,<cfqueryparam value="#variables.deliveryDate#" cfsqltype="cf_sql_date">,InsExpDateGeneral) >=0</cfif>) OR InsExpDateGeneral IS NULL))
		</cfif>
		GROUP BY LTRIM(car.CarrierName), car.CarrierID, car.Cel, car.Fax, car.EmailID, UPPER(car.CarrierName), car.City, car.stateCode, car.ZipCode, car.Address, car.InsExpDate,car.InsExpDate,car.InsExpDateCargo,car.InsExpDateGeneral, car.phone,car.tollfree,car.phoneext,car.faxext,car.tollfreeext,car.cellphoneext,car.RatePerMile, e.EquipmentID, li.ExpirationDate, li.CARGOExpirationDate, car.MCNumber, car.DOTNumber, car.RiskAssessment, car.LoadLimit, car.Status, car.IsCarrier, loadstops.StopDate, LoadStops.LoadType, car.DefaultCurrency, e.unitNumber,e.isActive, car.ContactPerson, car.SCAC, car.companyid, car.CalculateDHMiles,Car.RemitName
		
	</cfquery>
	
</cfoutput>

<cfquery name="qSystemSetupOptions" datasource="#Application.dsn#">
		SELECT SaferWatch,SaferWatchWebKey,SaferWatchCustomerKey,FreightBroker,CarrierLNI
		FROM SystemConfig  where companyid = <cfqueryparam value="#url.companyid#" cfsqltype="cf_sql_varchar">
</cfquery>
<cfoutput>
[
	<cfset isFirstIteration='yes'>
	<cfloop query="qrygetFilterCarriers">
		<cfif isFirstIteration EQ 'no'>,</cfif>

		<cfif len(trim(variables.deliveryDate)) and isdate(variables.deliveryDate)>
			<cfif qrygetFilterCarriers.bitInsExpired LTE 0 OR qrygetFilterCarriers.bitCargoInsExpired LTE 0 OR qrygetFilterCarriers.bitGenInsExpired LTE 0>
				<cfset insuranceExpired = 'yes'>
			<cfelse>
				<cfset insuranceExpired = 'no'>
			</cfif>
		<cfelse>
			<cfset insuranceExpired = 'no'>
		</cfif>

		<cfset qrygetFilterCarriers.Address = REReplace(qrygetFilterCarriers.Address, "\r\n|\n\r|\n|\r", "<br />", "all")>
		<cfif qSystemSetupOptions.SaferWatch EQ 1 AND qSystemSetupOptions.FreightBroker  EQ 1>
				<cfif  qrygetFilterCarriers.DOTNumber NEQ "">
					 <cfset number = qrygetFilterCarriers.DOTNumber>
				<cfelseif  qrygetFilterCarriers.MCNumber NEQ ""  >
					<cfset number = "MC"&qrygetFilterCarriers.MCNumber >
				<cfelse>
					<cfset number = 0 >
				</cfif>

					<cfset risk_assessment = qrygetFilterCarriers.RiskAssessment >

				<cfset link = "http://www.saferwatch.com/swCarrierDetailsLink.php?&number=#number#">
				<cfif risk_assessment EQ "Unacceptable">
					<cfset risk_assessment = "images/SW-Red.png" >
				<cfelseif risk_assessment EQ "Moderate">
					<cfset risk_assessment = "images/SW-Yellow.png">
				<cfelseif risk_assessment EQ "Acceptable">
					<cfset risk_assessment = "images/SW-Green.png">
				<cfelse>
					<cfset risk_assessment = "images/SW-Blank.png">
				</cfif>
		<cfelse>
			<cfset SelectedEquipmentID = qrygetFilterCarriers.EquipmentID>
		</cfif>

		<cfif qSystemSetupOptions.CarrierLNI EQ 2>
			<cfset link = "">
			<cfset risk_assessment = qrygetFilterCarriers.RiskAssessment >
			<cfif risk_assessment EQ "Unacceptable">
				<cfset risk_assessment = "images/CL-Red.png" >
			<cfelseif risk_assessment EQ "Moderate">
				<cfset risk_assessment = "images/CL-Yellow.png">
			<cfelseif risk_assessment EQ "Acceptable">
				<cfset risk_assessment = "images/CL-Green.png">
			</cfif>
		</cfif>

		<cfset carrierOverLimit = "no">
		<cfif qrygetFilterCarriers.LoadLimit NEQ 0 AND qrygetFilterCarriers.TotalPickups GTE qrygetFilterCarriers.LoadLimit>
			<cfset carrierOverLimit = "yes">
		<cfelseif qrygetFilterCarriers.LoadLimit EQ 0 AND qrygetFilterCarriers.GlobalLoadLimit NEQ 0 AND qrygetFilterCarriers.TotalPickups GTE qrygetFilterCarriers.GlobalLoadLimit>
			<cfset carrierOverLimit = "yes">
		</cfif>
			<cfset isFirstIteration='no'>
			{
				"label": "#replace(TRIM(qrygetFilterCarriers.carrierName),'"','&apos;','all')#",
				"value": "#replace(TRIM(qrygetFilterCarriers.value),'"','&apos;','all')#",
				"name" : "#replace(TRIM(qrygetFilterCarriers.carrierName),'"','&apos;','all')#",
				"location": "#replace(TRIM(qrygetFilterCarriers.Address),'"','&apos;','all')#",
				"city" : "#replace(TRIM(qrygetFilterCarriers.City),'"','&apos;','all')#",
				"state": "#replace(TRIM(qrygetFilterCarriers.StateCode),'"','&apos;','all')#",
				"zip": "#replace(TRIM(qrygetFilterCarriers.zipCode),'"','&apos;','all')#",
				"phoneNo": "#replace(TRIM(qrygetFilterCarriers.phone),'"','&apos;','all')#",
				"cell": "#replace(TRIM(qrygetFilterCarriers.cell),'"','&apos;','all')#",
				"fax": "#replace(TRIM(qrygetFilterCarriers.fax),'"','&apos;','all')#",
				"tollfree": "#replace(TRIM(qrygetFilterCarriers.tollfree),'"','&apos;','all')#",
				"phoneext": "#replace(TRIM(qrygetFilterCarriers.phoneext),'"','&apos;','all')#",
				"cellphoneext": "#replace(TRIM(qrygetFilterCarriers.cellphoneext),'"','&apos;','all')#",
				"faxext": "#replace(TRIM(qrygetFilterCarriers.faxext),'"','&apos;','all')#",
				"tollfreeext": "#replace(TRIM(qrygetFilterCarriers.tollfreeext),'"','&apos;','all')#",
				"InsExpDate": "#replace(TRIM(DateFormat(qrygetFilterCarriers.InsExpDate,'mm/dd/yyyy')),'"','&apos;','all')#",
				"email": "#replace(TRIM(qrygetFilterCarriers.emailID),'"','&apos;','all')#",
				"insuranceExpired" : "#replace(TRIM(insuranceExpired),'"','&apos;','all')#",
				"status" : "#replace(TRIM(qrygetFilterCarriers.Status),'"','&apos;','all')#",
				"link":"#link#",
				"EquipmentID":"#replace(TRIM(SelectedEquipmentID),'"','&apos;','all')#",
				"risk_assessment":"#risk_assessment#",
				"iscarrier":"#replace(TRIM(qrygetFilterCarriers.iscarrier),'"','&apos;','all')#",
				"isoverlimit": "#carrierOverLimit#",
				"ExpDocCount": "#ExpDocCount#",
				"loadLimit": #replace(TRIM(qrygetFilterCarriers.LoadLimit),'"','&apos;','all')#,
				"currency": "#replace(TRIM(qrygetFilterCarriers.DefaultCurrency),'"','&apos;','all')#"
				<cfif qrygetFilterCarriers.iscarrier EQ 0>
					,"unitNumber": "#replace(TRIM(qrygetFilterCarriers.unitNumber),'"','&apos;','all')#"
				<cfelse>	
					,"unitNumber": "-1"
				</cfif>
				,"MCNumber" : "#replace(TRIM(qrygetFilterCarriers.MCNumber),'"','&apos;','all')#"
				,"RemitName" : "#replace(TRIM(qrygetFilterCarriers.RemitName),'"','&apos;','all')#"
				,"ContactPerson" : "#replace(TRIM(qrygetFilterCarriers.ContactPerson),'"','&apos;','all')#"
				,"Status" : "#replace(TRIM(qrygetFilterCarriers.Status),'"','&apos;','all')#"
				,"DOTNumber" : "#replace(TRIM(qrygetFilterCarriers.DOTNumber),'"','&apos;','all')#"
				,"SCAC" : "#replace(TRIM(qrygetFilterCarriers.SCAC),'"','&apos;','all')#"
				,"eqActive" : "#replace(TRIM(qrygetFilterCarriers.eqActive),'"','&apos;','all')#"
				,"RatePerMile" : "#replace(TRIM(replace("$#Numberformat(qrygetFilterCarriers.RatePerMile,"___.__")#", " ", "", "ALL")),'"','&apos;','all')#"
				,"CalculateDHMiles": "#replace(TRIM(qrygetFilterCarriers.CalculateDHMiles),'"','&apos;','all')#"
			}

	</cfloop>

]
</cfoutput>

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




