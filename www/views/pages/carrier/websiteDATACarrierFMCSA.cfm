<cftry>
	<cfset webkey = "0db3710cf0ae77bd5a8c04c6d342a3015ecd388e">
	<cfset CarrierInfo = structNew()>
	<cfif structkeyExists(url,"DOTNumber")>
		<cfset dotNumber = trim(url.DOTNumber)>
		<cfhttp url="https://mobile.fmcsa.dot.gov/qc/services/carriers/#dotNumber#?webKey=#webkey#" method="get" result="httpCarrierInfo" timeout="300"></cfhttp>
		<cfset ContentInfo = deserializeJSON(httpCarrierInfo.FileContent)>
		<cfif isDefined("ContentInfo.content")>
			<cfset CarrierInfo = ContentInfo.content.carrier>
			<cfhttp url="https://mobile.fmcsa.dot.gov/qc/services/carriers/#dotNumber#/docket-numbers?webKey=#webkey#" method="get" result="httpDocketInfo" timeout="300"></cfhttp>
			<cfset DocketInfo = deserializeJSON(httpDocketInfo.FileContent)>
			<cfif NOT arrayIsEmpty(DocketInfo.content)>
				<cfset MCNumber = DocketInfo.content[1].docketNumber>
			</cfif>
		</cfif>
	<cfelseif structkeyExists(url,"mcNo")>
		<cfset mcNo = trim(url.mcNo)>
		<cfhttp url="https://mobile.fmcsa.dot.gov/qc/services/carriers/docket-number/#mcNo#?webKey=#webkey#" method="get" result="httpCarrierInfo" timeout="300"></cfhttp>
		<cfset ContentInfo = deserializeJSON(httpCarrierInfo.FileContent)>
		<cfif isDefined("ContentInfo.content") AND NOT arrayIsEmpty(ContentInfo.content)>
			<cfset CarrierInfo = ContentInfo.content[1].carrier>
		</cfif>
		<cfset dotNumber = CarrierInfo.DOTNumber>
	<cfelseif structkeyExists(url,"LegalName")>
		<cfset CarrierName = url.LegalName>
		<cfhttp url="https://mobile.fmcsa.dot.gov/qc/services/carriers/name/#CarrierName#?webKey=#webkey#" method="get" result="httpCarrierInfo" timeout="300"></cfhttp>
		<cfset ContentInfo = deserializeJSON(httpCarrierInfo.FileContent)>
		<cfif isDefined("ContentInfo.content") AND NOT arrayIsEmpty(ContentInfo.content)>
			<cfset CarrierInfo = ContentInfo.content[1].carrier>
			<cfset dotNumber = CarrierInfo.DOTNumber>
			<cfhttp url="https://mobile.fmcsa.dot.gov/qc/services/carriers/#dotNumber#/docket-numbers?webKey=#webkey#" method="get" result="httpDocketInfo" timeout="300"></cfhttp>
			<cfset DocketInfo = deserializeJSON(httpDocketInfo.FileContent)>
			<cfif NOT arrayIsEmpty(DocketInfo.content)>
				<cfset MCNumber = DocketInfo.content[1].docketNumber>
			</cfif>
		</cfif>
	</cfif>
	
	<cfif not structIsEmpty(CarrierInfo)>
		<cfset CarrierName = CarrierInfo.LegalName>
		<cfset VendorID = Left(ReplaceNoCase(CarrierInfo.LegalName," ","","ALL"),10)>
		<cfset Address = CarrierInfo.phyStreet>
		<cfset City = CarrierInfo.phyCity>
		<cfset State11 = CarrierInfo.phyState>
		<cfset ZipCode = CarrierInfo.phyZipCode>
		<cfset bipd_Insurance_on_file=CarrierInfo.bipdInsuranceOnFile>
		<cfset InsLimitCargo = CarrierInfo.cargoInsuranceOnFile*1000>
	<cfelse>
		<cfif structkeyExists(url,"mcNo") >
			<cfset message="Data not available. Please check the mc## and try again.">
		</cfif>
		<cfif structkeyExists(url,"DOTNumber") >
			<cfset message="Data not available. Please check the DOT## and try again.">
		</cfif>
	</cfif>
	<cfcatch type="any">
		<cfif structkeyExists(url,"mcNo") >
			<cfset message="Data not available. Please check the mc## and try again.">
		</cfif>
		<cfif structkeyExists(url,"DOTNumber") >
			<cfset message="Data not available. Please check the DOT## and try again.">
		</cfif>
	</cfcatch>
</cftry>