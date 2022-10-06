<cfif server.coldfusion.productversion CONTAINS '2021'>
	<cflocation url="https://#cgi.HTTP_HOST#/#trim(listFirst(cgi.SCRIPT_NAME,'/'))#/www/webroot/index.cfm?event=CarrierReport&#cgi.QUERY_STRING#">
</cfif> 
<cfset variables.frieghtBroker = "">
<cfif structkeyexists(url,"type")>
	<cfset variables.frieghtBroker=url.type>
</cfif>
<cfif structkeyexists(url,"carrierratecon")>
	<cfset variables.carrierratecon=url.carrierratecon>
<cfelse>
	<cfset variables.carrierratecon=1>	
</cfif>
<cfset customPath = "">
<cfquery name="qGetCompany" datasource="#Application.dsn#">
	select CompanyCode from Companies 
	WHERE CompanyID = 
	<cfif structKeyExists(url, "CompanyID")>
		<cfqueryparam value="#url.CompanyID#" cfsqltype="cf_sql_varchar">
	<cfelse>
		<cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar">
	</cfif>
</cfquery>

<cfif len(trim(qGetCompany.companycode)) and directoryExists(expandPath("../reports/#trim(qGetCompany.companycode)#"))>
	<cfset customPath = "#trim(qGetCompany.companycode)#">
</cfif>

<cfif structkeyexists(url,"loadno") or structkeyexists(url,"loadid")>
	<!--- carrierratecon = 1 -> sequential, carrierratecon = 0 -> Classic --->
	<cfif variables.carrierratecon Eq 1>
		<cfif len(trim(customPath)) and fileExists(expandPath("../reports/#trim(customPath)#/loadReportForCarrierConfirmation.cfr"))>
			<cfset reporttemplate = '#trim(customPath)#/loadReportForCarrierConfirmation.cfr'>
		<cfelse>
			<cfset reporttemplate = 'loadReportForCarrierConfirmation.cfr'>
		</cfif>
		<cfquery name="careerReport" datasource="#Application.dsn#">
	
			SELECT * FROM vwCarrierRateConfirmation WITH (NOLOCK)
		   <cfif structkeyexists(url,"loadno")>
				WHERE  (LoadNumber = <cfqueryparam value="#url.Loadno#" cfsqltype="cf_sql_varchar">)
			<cfelseif structkeyexists(url,"loadid")>
				WHERE  (LoadID = <cfqueryparam value="#url.LoadID#" cfsqltype="cf_sql_varchar">)
		   </cfif>
				ORDER BY StopNo, LoadType, SrNo
	   </cfquery>
	<cfelse>
		<cfif len(trim(customPath)) and fileExists(expandPath("../reports/#trim(customPath)#/loadReportForCarrierConfirmationClassic.cfr"))>
			<cfset reporttemplate = '#trim(customPath)#/loadReportForCarrierConfirmationClassic.cfr'>
		<cfelse>
			<cfset reporttemplate = 'loadReportForCarrierConfirmationClassic.cfr'>
		</cfif>
		<cfquery name="careerReport" datasource="#Application.dsn#">
	
			SELECT * FROM vwCarrierRateConfirmationClassic
		   <cfif structkeyexists(url,"loadno")>
				WHERE  (LoadNumber = <cfqueryparam value="#url.Loadno#" cfsqltype="cf_sql_varchar">)
			<cfelseif structkeyexists(url,"loadid")>
				WHERE  (LoadID = <cfqueryparam value="#url.loadid#" cfsqltype="cf_sql_varchar">)
		   </cfif>
				ORDER BY StopNo, LoadType, SrNo
	   </cfquery>
		
		
	</cfif>
	<cfquery name="qLoadStatus" datasource="#Application.dsn#">
		SELECT LST.StatusText FROM Loads L
		INNER JOIN LoadStatusTypes LST ON L.StatusTypeID = LST.StatusTypeID
		WHERE LoadID = <cfqueryparam value="#url.loadid#" cfsqltype="cf_sql_varchar">
	</cfquery>
	<cfoutput>
	<cfif careerReport.recordcount>
		<cfset careerReportNew = QueryNew(careerReport.columnList&",showFlatMilesRate,carrAccessorialsTotal")> 
		<cfset QueryAddRow(careerReportNew, careerReport.recordcount)>
		<cfset bitshowFlatMilesRate = 1>
		<cfset bitCarrierChange = 1>
		<cfset tmpcarrAccessorialsTotal =0>
		<cfset ShowRateHead = 0>
		<cfloop query="careerReport">
			<cfif len(trim(careerReport.CarrRate)) AND careerReport.CarrRate NEQ 0>
				<cfset ShowRateHead = 1>
			</cfif>
			<cfloop list="#careerReportNew.columnList#" index="key">
				<cfif key eq 'carrierterms'>
					<cfif structKeyExists(url, "signature") and structKeyExists(url, "ipAddress")>
						<cfset variables.CarrierTerms = careerReport.CarrierTerms & '#url.signature# #dateTimeFormat(now(),'mm/dd/yyyy hh:nn tt')# #url.ipAddress#'>
						<cfset QuerySetCell(careerReportNew, key, variables.CarrierTerms , careerReport.currentrow)>
					<cfelse>
						<cfset QuerySetCell(careerReportNew, key, evaluate("careerReport.#key#") , careerReport.currentrow)>
					</cfif>
				<cfelseif key EQ 'showFlatMilesRate'>
					<cfset QuerySetCell(careerReportNew, "showFlatMilesRate", 0, careerReport.currentrow)> 
					<cfif bitshowFlatMilesRate EQ 1>
						<cfset QuerySetCell(careerReportNew, "showFlatMilesRate", 1, careerReport.currentrow)> 
						<cfif careerReport.carrierName[currentrow] NEQ careerReport.carrierName[currentrow+1]>
							<cfset bitshowFlatMilesRate = 0>
						</cfif>
					</cfif>
				<cfelseif key EQ 'carrAccessorialsTotal'>	
					<cfif bitCarrierChange EQ 1>
						<cfset start = careerReport.currentrow>
						<cfset bitCarrierChange = 0>
					</cfif>
					<cfset end = careerReport.currentrow>
					<cfset tmpcarrAccessorialsTotal = tmpcarrAccessorialsTotal+careerReport.CarrCharges>
					<cfloop from="#start#" to="#end#" index="indx">
						<cfset QuerySetCell(careerReportNew, "carrAccessorialsTotal", '#tmpcarrAccessorialsTotal#', "#indx#")> 
					</cfloop>
					<cfif careerReport.carrierName[currentrow] NEQ careerReport.carrierName[currentrow+1]>
						<cfset tmpcarrAccessorialsTotal =0>
						<cfset bitCarrierChange = 1>
					</cfif>
				<cfelse>
					<cfset QuerySetCell(careerReportNew, key, evaluate("careerReport.#key#") , careerReport.currentrow)> 
				</cfif>
			</cfloop>
		</cfloop>

		<cfif variables.frieghtBroker eq 'Carrier'>
			<cfreport format="PDF" template="#reporttemplate#" style="../webroot/styles/reportStyle.css" query="#careerReportNew#" name="result"> 
				<cfreportParam name="ReportDate" value="#DateFormat(Now(),'mm/dd/yyyy')#"> 
				<cfreportParam name="ShowRateHead" value="#ShowRateHead#"> 
			</cfreport> 
			<cfset fileName = "Carrier Rate Confirmation Load ###careerReportNew.LoadNumber# Date-#DateFormat(Now(),'mm.dd.yyyy')#.pdf">
			<cfheader name="Content-Disposition" value="inline; filename=#fileName#">
			<cfif qLoadStatus.StatusText EQ '9. Cancelled'>
				<cfpdf action="addwatermark" source="result" image="../webroot/images/WM_Cancelled.png"name = "result">
			</cfif>
			<cfcontent type="application/pdf" variable="#tobinary(result)#">
		<cfelseif variables.frieghtBroker eq 'Dispatch'>
			<cfreport format="PDF" template="#reporttemplate#" style="../webroot/styles/reportStyle.css" query="#careerReportNew#" name="result"> 		
				<cfreportParam name="ReportDate" value="#DateFormat(Now(),'mm/dd/yyyy')#"> 
				<cfreportParam name="ShowRateHead" value="#ShowRateHead#"> 
			</cfreport> 
			<cfset fileName = "Carrier Rate Confirmation Load ###careerReportNew.LoadNumber# Date-#DateFormat(Now(),'mm.dd.yyyy')#.pdf">
			<cfheader name="Content-Disposition" value="inline; filename=#fileName#">
			<cfif qLoadStatus.StatusText EQ '9. Cancelled'>
				<cfpdf action="addwatermark" source="result" image="../webroot/images/WM_Cancelled.png"name = "result">
			</cfif>
			<cfcontent type="application/pdf" variable="#tobinary(result)#">
		</cfif>	
		<cfelse>
			Unable to generate the report. Load data not available.	
		</cfif>
	</cfoutput>	 
<cfelse>
	Unable to generate the report. Please specify the load Number or Load ID	
</cfif>	