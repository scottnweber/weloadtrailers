<cfif server.coldfusion.productversion CONTAINS '2021'>
	<cflocation url="https://#cgi.HTTP_HOST#/#trim(listFirst(cgi.SCRIPT_NAME,'/'))#/www/webroot/index.cfm?event=CustomerInvoiceReport&#cgi.QUERY_STRING#">
</cfif> 
<cfoutput>
<cfif structkeyexists(url,"loadno") or (structkeyexists(url,"loadid")) AND isValid("regex", url.loadid,'^[{]?[0-9a-fA-F]{8}-([0-9a-fA-F]{4}-){3}[0-9a-fA-F]{12}[}]?$') OR NOT len(trim(url.loadid))>
	<cfquery name="careerReport" datasource="#Application.dsn#">
		SELECT *, 
			(SELECT sum(weight)  from vwCarrierConfirmationReport 
			WHERE  (LoadID = <cfqueryparam value="#url.LoadID#" cfsqltype="cf_sql_varchar">)
			GROUP BY loadnumber) as TotalWeight 
		FROM vwCustomerInvoiceReport
		WHERE  (LoadID = <cfqueryparam value="#url.LoadID#" cfsqltype="cf_sql_varchar">)
	   	ORDER BY stopnum ,SrNo
	</cfquery> 
	<cfquery name="qLoadStatus" datasource="#Application.dsn#">
		SELECT LST.StatusText FROM Loads L
		INNER JOIN LoadStatusTypes LST ON L.StatusTypeID = LST.StatusTypeID
		WHERE LoadID = <cfqueryparam value="#url.loadid#" cfsqltype="cf_sql_varchar">
	</cfquery>
	<cfif careerReport.recordcount>
		
		<cfset dueDate = "">
		<cfif len(trim(careerReport.PaymentTerms)) AND careerReport.ReportTitle EQ 'Invoice'>
			<cfset arrMatch = rematch("NET[\d]+",replace(careerReport.PaymentTerms, " ", "","ALL"))>
			<cfif not arrayIsEmpty(arrMatch)>
				<cfset dueDays = replaceNoCase(arrMatch[1], "NET", "")>
				<cfset dueDate = dateAdd("d", dueDays, careerReport.BillDate)>
			</cfif>
		</cfif>
		<cfset careerReportNew = QueryNew(careerReport.columnList&",shipperStopNum,conStopNum,dueDate")> 
		<cfset QueryAddRow(careerReportNew, careerReport.recordcount)>
		<cfset indx = 0>
		<cfset prevStopID = "">
		<cfloop query="careerReport">
			<cfloop list="#careerReportNew.columnList#" index="key">
				<cfif not listFindNoCase("shipperStopNum,conStopNum,dueDate", key)>
					<cfset QuerySetCell(careerReportNew, key, evaluate("careerReport.#key#") , careerReport.currentrow)> 
					<cfif not len(trim(careerReport.totalweight))>
						<cfset QuerySetCell(careerReportNew, "totalweight", 0 , careerReport.currentrow)> 
					</cfif>
					<cfif not len(trim(careerReport.weight))>
						<cfset QuerySetCell(careerReportNew, "weight", 0 , careerReport.currentrow)> 
					</cfif>
					<cfif not len(trim(careerReport.Custcharges))>
						<cfset QuerySetCell(careerReportNew, "Custcharges", 0 , careerReport.currentrow)> 
					</cfif>
					<cfif not len(trim(careerReport.Carrcharges))>
						<cfset QuerySetCell(careerReportNew, "Carrcharges", 0 , careerReport.currentrow)> 
					</cfif>
				</cfif>
			</cfloop>
			<cfif (prevStopID NEQ careerReport.loadstopid) AND (len(trim(careerReport.shipperName)) OR len(trim(careerReport.ShipperAddress)) OR len(trim(careerReport.Shippercity)) OR len(trim(careerReport.Shipperstate)) OR len(trim(careerReport.Shipperzip)))>
				<cfset indx++>
				<cfset QuerySetCell(careerReportNew, "shipperStopNum", indx , careerReport.currentrow)> 
			</cfif>
			<cfif (prevStopID NEQ careerReport.loadstopid) AND (len(trim(careerReport.conName)) OR len(trim(careerReport.conAddress)) OR len(trim(careerReport.concity)) OR len(trim(careerReport.constate)) OR len(trim(careerReport.conzip)))>
				<cfset indx++>
				<cfset QuerySetCell(careerReportNew, "conStopNum", indx , careerReport.currentrow)> 
			</cfif>	
			<cfset QuerySetCell(careerReportNew, "dueDate", duedate , careerReport.currentrow)> 
			<cfset prevStopID = careerReport.loadstopid>
		</cfloop>
		<cfset customPath = "">
		<cfset CompanyID = "">
		<cfset reportFile = 'CustomerInvoiceReport.cfr'>
		<cfif careerReportNew.CustomerInvoiceformat EQ 1>
			<cfset reportFile = 'CustomerInvoiceReportWithOutStops.cfr'>
		</cfif>
		<cfif len(trim(careerReport.companycode)) and directoryExists(expandPath("../reports/#trim(careerReport.companycode)#"))>
			<cfset customPath = "#trim(careerReport.companycode)#">
		</cfif>
		<cfif len(trim(customPath)) and fileExists(expandPath("../reports/#trim(customPath)#/#reportFile#"))>
			<cfset tempRootPath = expandPath("../reports/#trim(customPath)#/CustomerInvoiceReport.cfr")>
		<cfelse>
			<cfset tempRootPath = expandPath("../reports/#reportFile#")>
		</cfif>

		<cfset RemitColor = '##000000'>
		<cffile action="read" file="#expandPath('../webroot/')#cfrAllowedColor.json" variable="allowedColors">
		<cfloop array="#deserializeJSON(allowedColors)#" index="color">
		    <cfif color.COLORVALUE EQ careerReportNew.infocolor>
		    	<cfset RemitColor = color.COLORNAME>
		    </cfif>
		</cfloop>



		<cfset mystyle='Remit { defaultStyle: false; font-family: "Arial Narrow"; color:"#RemitColor#" }'> 
		<cfreport format="PDF" template="#tempRootPath#" style="#mystyle#" query="#careerReportNew#" name="result"> 
			<cfreportParam name="ReportDate" value="#DateFormat(Now(),'mm/dd/yyyy')#"> 
		</cfreport> 	 

		<cfset PDFinfo=StructNew()> 
		<cfset PDFinfo.Title="CustomerDocumentReport.cfm"> 
		<cfpdf action="setInfo" source="result" info="#PDFinfo#" overwrite="yes">
		<cfset fileName = "Invoice Load ###careerReport.LoadNumber# Date-#DateFormat(Now(),'mm.dd.yyyy')#.pdf">
		<cfheader name="Content-Disposition" value="inline; filename=#fileName#">
		<cfif qLoadStatus.StatusText EQ '9. Cancelled'>
			<cfpdf action="addwatermark" source="result" image="../webroot/images/WM_Cancelled.png"name = "result">
		</cfif>
		<cfcontent type="application/pdf" variable="#tobinary(result)#">
	<cfelse>
		Unable to generate the report. Load data not available.	
	</cfif>
<cfelse>
	Unable to generate the report. Please specify the load Number or Load ID	
</cfif>
</cfoutput>