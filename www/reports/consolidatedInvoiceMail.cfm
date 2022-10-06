<cfoutput>
	<cftry>
		<cfparam name="body" default="">
		<cfquery name="qgetLoadConsolidatedDetail" datasource="#application.dsn#">
			SELECT 
			LCD.LoadID,
			LC.CustomerID,
			LC.ConsolidatedInvoiceNumber,
			LC.Amount,
			CASE WHEN isnull(C.BestOpp, '') = '' THEN 'Due Upon Receipt' ELSE C.bestopp END AS PaymentTerms,
			L.CustomerPONo,
			C.CustomerName,
			C.Location,
			C.City,
			C.StateCode,
			C.ZipCode,
			C.ContactPerson,
			C.PhoneNo,
			C.Fax,
			ISNULL(C.IncludeIndividualInvoices,0) AS IncludeIndividualInvoices,
			L.LoadNumber,
			L.BOLNum,
			convert(varchar, L.BillDate, 1) AS BillDate,
			L.InternalRef,
			L.TotalCustomerCharges,
			LC.REL,
			LC.JOB,
			LC.PaymentTerms,
			C.SeperateJobPo,
			(SELECT ShipperCity + ' ' + ShipperState + ' TO ' + ConsigneeCity + ' ' + ConsigneeState FROM Loads WHERE LoadID = (SELECT TOP 1 LoadID FROM LoadsConsolidatedDetail WHERE ConsolidatedID = ID)) AS LoadRoute,
			(SELECT TOP 1 Description FROM LoadStopCommodities WHERE LoadStopID in (SELECT TOP 1 LoadStopID FROM LoadStops WHERE LoadID = (SELECT TOP 1 LoadID FROM LoadsConsolidatedDetail WHERE ConsolidatedID = ID) AND LoadType=1)) AS Description,
			LC.Comment,
			LC.JobEdited,
			LC.JobEdited,
			ISNULL(C.ConsolidateInvoiceBOL,0) AS ConsolidateInvoiceBOL,
			ISNULL(C.ConsolidateInvoiceRef,0) AS ConsolidateInvoiceRef,
			ISNULL(C.ConsolidateInvoiceDate,0) AS ConsolidateInvoiceDate
			FROM LoadsConsolidated LC
			JOIN LoadsConsolidatedDetail LCD ON LC.ID = LCD.ConsolidatedID
			JOIN Customers C ON C.CustomerID = LC.CustomerID
			JOIN Loads L ON L.LoadID = LCD.LoadID
			AND LC.ConsolidatedInvoiceNumber = <cfqueryparam value="#url.ConsolidatedInvoiceNumber#" cfsqltype="cf_sql_integer">
			ORDER BY L.BillDate,L.TotalCustomerCharges
		</cfquery>

		<cfquery name="qgetSysConfig" datasource="#application.dsn#">
			SELECT
			C.companyName,
			S.companyLogoName,
			S.DropBoxAccessToken,
			C.Address,
			C.City,
			C.State,
			C.ZipCode,
			C.Phone,
			C.fax,
			C.CompanyCode,
			C.RemitInfo1,
			C.RemitInfo2,
			C.RemitInfo3,
			C.RemitInfo4,
			C.RemitInfo5,
			C.RemitInfo6
			FROM Companies C 
			INNER JOIN SystemConfig S On S.CompanyID = C.CompanyID
			WHERE C.CompanyID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#session.CompanyID#" >
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
		<cfquery name="careerReport" datasource="#Application.dsn#">
			SELECT customerID, Email
			FROM Customers
			WHERE customerID = <cfqueryparam value="#qgetLoadConsolidatedDetail.customerID#" cfsqltype="cf_sql_varchar">
		</cfquery>

		<cfset customPath = "">
		<cfif len(trim(qgetSysConfig.companycode)) and directoryExists(expandPath("../reports/#trim(qgetSysConfig.companycode)#"))>
			<cfset customPath = "#trim(qgetSysConfig.companycode)#">
		</cfif>

		<cfinvoke component="#variables.objloadGateway#" method="getcurAgentMaildetails" returnvariable="request.qcurAgentdetails" employeID="#session.empid#" />
		
		<cfset MailTo= careerReport.Email>
		<cfset SmtpAddress=request.qcurAgentdetails.SmtpAddress>
		<cfset SmtpUsername=request.qcurAgentdetails.SmtpUsername>
		<cfset SmtpPort=request.qcurAgentdetails.SmtpPort>
		<cfset SmtpPassword=request.qcurAgentdetails.SmtpPassword>
		<cfset FA_SSL=request.qcurAgentdetails.useSSL>
		<cfset FA_TLS=request.qcurAgentdetails.useTLS>
		<cfset MailFrom=request.qcurAgentdetails.EmailID>
		<cfset emailSignature = request.qcurAgentdetails.emailSignature>

		<cfif IsDefined("form.send")>
			<cfif form.MailTo is not "" AND form.MailFrom is not "" AND form.Subject is not "">
				<cfset rootPath = expandPath('../fileupload/consolidatedInvoice#url.ConsolidatedInvoiceNumber##DateFormat(Now(),"YYMMDD")##TimeFormat(Now(),"hhmmss")#/')>
				<cfif not directoryExists(rootPath)>
					<cfdirectory action = "create" directory = "#rootPath#" > 
				</cfif>
				<cfset totalAmount = 0>
				<cfloop query="qgetLoadConsolidatedDetail" group="BillDate">
					<cfloop group="TotalCustomerCharges">
						<cfset count =1>
						<cfloop>
							<cfif currentrow neq 1 and qgetLoadConsolidatedDetail.BillDate eq qgetLoadConsolidatedDetail.BillDate[currentrow-1] and qgetLoadConsolidatedDetail.TotalCustomerCharges eq qgetLoadConsolidatedDetail.TotalCustomerCharges[currentrow-1]>
								<cfset count++>
							</cfif>
						</cfloop>
						<cfset lineTotal = qgetLoadConsolidatedDetail.TotalCustomerCharges*count>
						<cfset totalAmount = totalAmount+lineTotal>
					</cfloop>
				</cfloop>
				<cfdocument format="PDF" filename="#rootPath#/consInv.pdf">
					<cfdocumentitem type="header">
						<div style="position: absolute;bottom: 0px;width: 100%;">
							<table width="100%" style='font-family: "Arial";font-size: 13px;' cellspacing="0">
								<tr>
									<td width="25%" valign="top" align="left" style="border-bottom: 1px solid black;">
										<img src="../fileupload/img/#qgetSysConfig.companycode#/logo/#qgetSysConfig.CompanylogoName#" width="140">						
									</td>
									<td width="25%" valign="top" align="right" style="border-bottom: 1px solid black;">
										<strong>CONSOLIDATED</strong>
										<h1 style="margin-top: 0;">INVOICE</h1>
									</td>
									<td width="50%" valign="top" align="right" style="font-size: 17px;"  style="border-bottom: 1px solid black;">
										<table >
											<tr>
												<td align="right"><b>Invoice##:</b></td>
												<td>#qgetLoadConsolidatedDetail.ConsolidatedInvoiceNumber#</td>
											</tr>
											<tr>
												<td align="right"><b>PO##:</b></td>
												<td>#qgetLoadConsolidatedDetail.CustomerPONo#</td>
											</tr>
											<tr>
												<td align="right"><b>Date:</b></td>
												<td>#DateFormat(now(),"m/d/yy")#</td>
											</tr>
											<tr>
												<td align="right"><b>Amount:</b></td>
												<td>#DollarFormat(totalAmount)#</td>
											</tr>
											<tr>
												<td align="right"><b>Terms:</b></td>
												<td>
													<cfif len(trim(qgetLoadConsolidatedDetail.PaymentTerms))>#qgetLoadConsolidatedDetail.PaymentTerms#
													<cfelse>#qgetLoadConsolidatedDetail.PaymentTermsN#
													</cfif>
												</td>
											</tr>
										</table>
									</td>
								</tr>
							</table>
						</div>
					</cfdocumentitem>
					<table width="98%" align="right" style='font-family: "Arial";font-size: 13px;margin-top: -25px;' cellspacing="0" >
						<tr>
							<td style="border: 1px solid black;background-color: ##E0E0E0;" colspan="2"><strong style="margin-left: 5px;">FROM</strong>: </td>
						</tr>
						<tr>
							<td style="padding-top: 5px;" width="70%">
								#qgetSysConfig.companyName#<br>
								#qgetSysConfig.address#<br>
								#qgetSysConfig.City# #qgetSysConfig.State# #qgetSysConfig.ZipCode#
							</td>
							<td style="padding-top: 5px;">
								<table style='font-family: "Arial";font-size: 13px;'>
									<tr>
										<td align="right"><b>Phone ##:</b></td>
										<td>#qgetSysConfig.Phone#</td>
									</tr>
									<tr>
										<td align="right"><b>Fax ##:</b></td>
										<td>#qgetSysConfig.Fax#</td>
									</tr>
								</table>
							</td>
						</tr>
					</table>
					<div style="padding: 0;margin: 0;line-height: 0;font-size: 0;height: 0;clear: both;"></div>
					<table width="98%" align="right" style='font-family: "Arial";font-size: 13px;margin-top: 3px;' cellspacing="0">
						<tr>
							<td style="border: 1px solid black;background-color: ##E0E0E0;" colspan="2"><strong style="margin-left: 5px;">BILL TO</strong>:</td>
						</tr>
						<tr>
							<td style="padding-top: 5px;" width="70%">
								#qgetLoadConsolidatedDetail.CustomerName#<br>
								#replace(qgetLoadConsolidatedDetail.Location,chr(13)&chr(10),"<br />","all")#<br>
								#qgetLoadConsolidatedDetail.City#, #qgetLoadConsolidatedDetail.StateCode# #qgetLoadConsolidatedDetail.ZipCode#
								
								<table style='font-family: "Arial";font-size: 13px;margin-top: 10px;'>
									<tr>
										<td align="right"><b>Contact ##:</b></td>
										<td>#qgetLoadConsolidatedDetail.ContactPerson#</td>
									</tr>
									<tr>
										<td align="right"><b>Phone ##:</b></td>
										<td>#qgetLoadConsolidatedDetail.PhoneNo#</td>
									</tr>
									<tr>
										<td align="right"><b>Fax ##:</b></td>
										<td>#qgetLoadConsolidatedDetail.Fax#</td>
									</tr>
								</table>
							</td>
							<td style="padding-top: 5px;" width="30%">
								#qgetSysConfig.RemitInfo1#<br>
								#qgetSysConfig.RemitInfo2#<br>
								#qgetSysConfig.RemitInfo3#<br>
								#qgetSysConfig.RemitInfo4#<br>
								#qgetSysConfig.RemitInfo5#<br>
								#qgetSysConfig.RemitInfo6#<br>
							</td>
						</tr>
					</table>
					<div style="padding: 0;margin: 0;line-height: 0;font-size: 0;height: 0;clear: both;"></div>
					<cfif qgetLoadConsolidatedDetail.SeperateJobPo NEQ 1 AND qgetLoadConsolidatedDetail.JobEdited EQ 0>
						<cfset  Job = qgetLoadConsolidatedDetail.Description & ' ' & qgetLoadConsolidatedDetail.LoadRoute>
					<cfelse>
						<cfset  Job = qgetLoadConsolidatedDetail.Job>
					</cfif>

					<table width="<cfif len(trim(qgetLoadConsolidatedDetail.REL)) OR len(trim(job))>100<cfelse>30</cfif>%" style='font-family: "Arial";margin-top: 5px;font-size: 13px;<cfif NOT len(trim(qgetLoadConsolidatedDetail.REL)) AND NOT len(trim(job))>float:right;</cfif>' cellspacing="0" cellpadding="0" border=1>
						<thead style="background-color: ##a7a3a3;color:##fff">
							<tr>
								<cfif len(trim(qgetLoadConsolidatedDetail.REL))>
									<th width="16%">REL##</th>
								</cfif>
								<cfif len(trim(job))>
									<th width="66%">JOB</th>
								</cfif>
								<th width="18%">PAYMENT TERMS</th>
							</tr>
						</thead>
						<tbody>
							<tr>
								<cfif len(trim(qgetLoadConsolidatedDetail.REL))>
									<td align="center">#qgetLoadConsolidatedDetail.REL#</td>
								</cfif>
								<cfif len(trim(job))>
									<td align="center">#Job#</td>
								</cfif>
								<td align="center"><cfif len(trim(qgetLoadConsolidatedDetail.PaymentTerms))>#qgetLoadConsolidatedDetail.PaymentTerms#<cfelse>#qgetLoadConsolidatedDetail.PaymentTermsN#</cfif></td>
							</tr>
						</tbody>
					</table>
					<div style="padding: 0;margin: 0;line-height: 0;font-size: 0;height: 0;clear: both;"></div>
					<table width="100%" style='font-family: "Arial";margin-top: 15px;font-size: 13px;' cellspacing="0" cellpadding="0" border=1>
				<thead style="background-color: ##a7a3a3;color:##fff">
					<tr>
						<cfset LoadWidth = 24>
						<cfif NOT qgetLoadConsolidatedDetail.SeperateJobPo>
							<cfset LoadWidth = LoadWidth + 16>
						</cfif>
						<cfif NOT qgetLoadConsolidatedDetail.ConsolidateInvoiceBOL>
							<cfset LoadWidth = LoadWidth + 10>
						</cfif>
						<cfif NOT qgetLoadConsolidatedDetail.ConsolidateInvoiceRef>
							<cfset LoadWidth = LoadWidth + 12>
						</cfif>
						<cfif NOT qgetLoadConsolidatedDetail.ConsolidateInvoiceDate>
							<cfset LoadWidth = LoadWidth + 10>
						</cfif>
						<th align="left" width="#LoadWidth#%">INVOICE##/LOAD##</th>
						<cfif qgetLoadConsolidatedDetail.SeperateJobPo><th width="16%">JOB##/PO##</th></cfif>
						<cfif qgetLoadConsolidatedDetail.ConsolidateInvoiceBOL><th width="10%">BOL##</th></cfif>
						<cfif qgetLoadConsolidatedDetail.ConsolidateInvoiceRef><th width="12%">REFERENCE##</th></cfif>
						<cfif qgetLoadConsolidatedDetail.ConsolidateInvoiceDate><th width="10%">DELIVERED</th></cfif>
						<th width="14%">UNIT PRICE</th>
						<th width="14%">LINE TOTAL</th>
					</tr>
				</thead>
				<tbody>
					<cfloop query="qgetLoadConsolidatedDetail" group="BillDate">
						<cfloop group="TotalCustomerCharges">
							<cfset count =1>
							<tr>
								<td align="left"><cfloop><cfif currentrow neq 1 and qgetLoadConsolidatedDetail.BillDate eq qgetLoadConsolidatedDetail.BillDate[currentrow-1] and qgetLoadConsolidatedDetail.TotalCustomerCharges eq qgetLoadConsolidatedDetail.TotalCustomerCharges[currentrow-1]>, <cfset count++></cfif>#qgetLoadConsolidatedDetail.LoadNumber#</cfloop></td>
								<cfif qgetLoadConsolidatedDetail.SeperateJobPo><td align="center">#qgetLoadConsolidatedDetail.CustomerPONo#</td></cfif>
								<cfif qgetLoadConsolidatedDetail.ConsolidateInvoiceBOL><td align="center">#qgetLoadConsolidatedDetail.BOLNum#</td></cfif>
								<cfif qgetLoadConsolidatedDetail.ConsolidateInvoiceRef><td align="center">#qgetLoadConsolidatedDetail.InternalRef#</td></cfif>
								<cfif qgetLoadConsolidatedDetail.ConsolidateInvoiceDate>
									<td align="center">
										<cfif len(qgetLoadConsolidatedDetail.BillDate)>
											#qgetLoadConsolidatedDetail.BillDate#
										</cfif>
									</td>
								</cfif>
								<td align="right" style="padding-right: 5px;">#DollarFormat(qgetLoadConsolidatedDetail.TotalCustomerCharges)#</td>
								<cfset lineTotal = qgetLoadConsolidatedDetail.TotalCustomerCharges*count>
								<td align="right" style="padding-right: 5px;">#DollarFormat(lineTotal)#</td>
							</tr>
						</cfloop>
					</cfloop>
					<tr>
						<cfset colspan1 = 7>
						<cfset colspan2 = 5>
						<cfif NOT qgetLoadConsolidatedDetail.SeperateJobPo>
							<cfset colspan1-->
							<cfset colspan2-->
						</cfif>
						<cfif NOT qgetLoadConsolidatedDetail.ConsolidateInvoiceBOL>
							<cfset colspan1-->
							<cfset colspan2-->
						</cfif>
						<cfif NOT qgetLoadConsolidatedDetail.ConsolidateInvoiceRef>
							<cfset colspan1-->
							<cfset colspan2-->
						</cfif>
						<cfif NOT qgetLoadConsolidatedDetail.ConsolidateInvoiceDate>
							<cfset colspan1-->
							<cfset colspan2-->
						</cfif>
						<td colspan="#colspan1#" align="left"> 
							<strong>#REReplace(qgetLoadConsolidatedDetail.Comment, "\r\n|\n\r|\n|\r", "<br />", "all")#</strong>
						</td>
					</tr>
					<tr>
						<td align="left"><strong>TOTAL</strong></td>
						<td colspan="#colspan2#">&nbsp;</td>
						<td align="right" style="padding-right: 5px;"><strong>#DollarFormat(totalAmount)#</strong></td>
					</tr>
				</tbody>
			</table>
					<table width="100%" style='font-family: "Arial";font-size: 13px;margin-top: 10px;padding-left: 100px;' cellspacing="0">
						<tr>
							<td style="border: 1px solid black;">
								<strong style="margin-left: 5px;">Terms</strong>: #qgetLoadConsolidatedDetail.PaymentTerms#
								<strong style="margin-left: 15px;">Amount Due</strong>: #DollarFormat(totalAmount)#
							</td>
						</tr>
					</table>
				</cfdocument>

				<cfloop query="qgetLoadConsolidatedDetail">
					<cfquery name="careerReport" datasource="#Application.dsn#">
						SELECT *, 
							(SELECT sum(weight)  from vwCarrierConfirmationReport 
							WHERE  (LoadID =  <cfqueryparam value="#qgetLoadConsolidatedDetail.LoadID#" cfsqltype="cf_sql_varchar">)
							GROUP BY loadnumber) as TotalWeight 
						FROM vwCustomerInvoiceReport
						WHERE  (LoadID =  <cfqueryparam value="#qgetLoadConsolidatedDetail.LoadID#" cfsqltype="cf_sql_varchar">)
					   	ORDER BY stopnum 
					</cfquery> 
					<cfif qgetLoadConsolidatedDetail.IncludeIndividualInvoices>
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

						<cfset fileName = 'consInvLoad#careerReport.LoadNumber#.pdf'>

						<cfif len(trim(customPath)) and fileExists(expandPath("../reports/#trim(customPath)#/CustomerInvoiceReport.cfr"))>
							<cfset tempRootPath = expandPath("../reports/#trim(customPath)#/CustomerInvoiceReport.cfr")>
						<cfelse>
							<cfset tempRootPath = expandPath("../reports/CustomerInvoiceReport.cfr")>
						</cfif>

						<cfreport format="PDF" template="#tempRootPath#" style="../webroot/styles/reportStyle.css" query="#careerReportNew#" filename="#rootPath#/#fileName#" overwrite="true"> 
							<cfreportParam name="ReportDate" value="#DateFormat(Now(),'mm/dd/yyyy')#"> 
							<cfreportParam name="addFooter" value="0">
						</cfreport>
					</cfif> 
					<cfquery name="qGetCompany" datasource="#Application.dsn#">
						SELECT 
							CompanyCode
						FROM Companies WHERE CompanyID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#session.CompanyID#" >
					</cfquery>
					<cfquery name="qGetBillDoc" datasource="#Application.dsn#">
						SELECT * FROM FileAttachments WHERE linked_Id = <cfqueryparam value="#careerReport.LoadID#" cfsqltype="cf_sql_varchar">  AND Billingattachments = 1
					</cfquery>

					<cfif qGetBillDoc.recordcount>
						<cfloop query="#qGetBillDoc#">
							<cfif dropboxfile eq 1>
								<cfhttp
										method="POST"
										url="https://api.dropboxapi.com/2/sharing/create_shared_link"	
										result="returnStruct"> 
												<cfhttpparam type="HEADER" name="Authorization" value="Bearer #qrygetCommonDropBox.DropBoxAccessToken#">	
												<cfhttpparam type="HEADER" name="Content-Type" value="application/json">	
												<cfhttpparam type="body" value='{"path":#SerializeJSON('/fileupload/img/#qGetCompany.CompanyCode#/' & qGetBillDoc.attachmentFileName)#}'>
								</cfhttp> 
								<cfset filePath = "">
								<cfif returnStruct.Statuscode EQ "200 OK">
									<cfset filePath = deserializeJSON(returnStruct.fileContent).url.Split('\?')[1] & '?raw=1'>
								</cfif>	
							<cfelse>
								<cfset filePath = expandPath('../fileupload/img/#qGetCompany.CompanyCode#/#qGetBillDoc.attachmentFileName#')>
							</cfif>
							<cfif fileexists(filePath)>
								<cfset FileExt=ListLast(qGetBillDoc.attachmentFileName,".")>
								<cfif FileExt EQ 'pdf'>
									<cfif dropboxfile eq 1>
										<cfhttp url="#filePath#" 
									        method="get" 
									        getAsBinary="yes"
									        path="#rootPath#" 
									        file="consInvLoad#careerReport.LoadNumber#bill#qGetBillDoc.currentRow#.pdf"/>
									<cfelse>
										<cffile
										action = "copy"
										source = "#filePath#"
										destination = "#rootPath#/consInvLoad#careerReport.LoadNumber#bill#qGetBillDoc.currentRow#.pdf">
									</cfif>
								<cfelseif listFindNoCase("jpg,jpeg", FileExt)>
									<cfif dropboxfile eq 1>
										<cfdocument format="PDF" filename="#rootPath#/consInvLoad#careerReport.LoadNumber#bill#qGetBillDoc.currentRow#.pdf">
										    <img src="#filePath#">
										</cfdocument>
									<cfelse>
										<cfdocument mimetype="image/jpeg" srcfile="#filePath#"  format="PDF" filename="#rootPath#/consInvLoad#careerReport.LoadNumber#bill#qGetBillDoc.currentRow#.pdf">
										</cfdocument>
									</cfif>
								<cfelseif FileExt EQ 'png'>
									<cfdocument mimetype="image/png" srcfile="#filePath#"  format="PDF" filename="#rootPath#/consInvLoad#careerReport.LoadNumber#bill#qGetBillDoc.currentRow#.pdf">
									</cfdocument>
								<cfelseif FileExt EQ 'gif'>
									<cfdocument mimetype="image/gif" srcfile="#filePath#"  format="PDF" filename="#rootPath#/consInvLoad#careerReport.LoadNumber#bill#qGetBillDoc.currentRow#.pdf">
									</cfdocument>
								</cfif>
							</cfif>
						</cfloop>
					</cfif>
				</cfloop> 
				<cfquery name="qGetCustBillDoc" datasource="#Application.dsn#">
					SELECT * FROM FileAttachments WHERE linked_Id = <cfqueryparam value="#qgetLoadConsolidatedDetail.CustomerID#" cfsqltype="cf_sql_varchar">  AND Billingattachments = 1
				</cfquery>

				<cfif qGetCustBillDoc.recordcount>
					<cfloop query="#qGetCustBillDoc#">
						<cfset filePath = expandPath('../fileupload/img/#qGetCustBillDoc.attachmentFileName#')>
						<cfif fileexists(filePath)>
							<cfset FileExt=ListLast(qGetCustBillDoc.attachmentFileName,".")>
							<cfif FileExt EQ 'pdf'>
								<cffile
								action = "copy"
								source = "#filePath#"
								destination = "#rootPath#/consInvLoad#careerReport.LoadNumber#billCust#qGetCustBillDoc.currentRow#.pdf">
							<cfelseif listFindNoCase("jpg,jpeg", FileExt)>
								<cfdocument mimetype="image/jpeg" srcfile="#filePath#"  format="PDF" filename="#rootPath#/consInvLoad#careerReport.LoadNumber#billCust#qGetCustBillDoc.currentRow#.pdf">
								</cfdocument>
							<cfelseif FileExt EQ 'png'>
								<cfdocument mimetype="image/png" srcfile="#filePath#"  format="PDF" filename="#rootPath#/consInvLoad#careerReport.LoadNumber#billCust#qGetCustBillDoc.currentRow#.pdf">
								</cfdocument>
							<cfelseif FileExt EQ 'gif'>
								<cfdocument mimetype="image/gif" srcfile="#filePath#"  format="PDF" filename="#rootPath#/consInvLoad#careerReport.LoadNumber#billCust#qGetCustBillDoc.currentRow#.pdf">
								</cfdocument>
							</cfif>
						</cfif>
					</cfloop>
				</cfif>
				<cfpdf action="merge" directory="#rootPath#" destination="#rootPath#/ConsolidatedInvoice#url.ConsolidatedInvoiceNumber#.pdf" overwrite="yes" order="name" ascending="yes">

				<cfsavecontent variable="footerText">
					<span style='font-family: "Arial";font-size: 10pt;'>
						<cfloop from="1" to="167" index="i">-</cfloop>
						<br></br>
						<p>#DateFormat(Now(),'mm/dd/yyyy')#<p><cfloop from="1" to="170" index="i">&##160;</cfloop></p>_PAGENUMBER of _LASTPAGENUMBER</p> 
						
						
					</span>
				</cfsavecontent>
		
				<cfpdf action="addFooter" source="#rootPath#/ConsolidatedInvoice#url.ConsolidatedInvoiceNumber#.pdf" name="genPDF" text="#footerText#"/>
				
				<cfmail from='"#SmtpUsername#" <#SmtpUsername#>' subject="#form.Subject#"   to="#form.MailTo#" type="text/html"  server="#SmtpAddress#" username="#SmtpUsername#" password="#SmtpPassword#" port="#SmtpPort#" usessl="#FA_SSL#" usetls="#FA_TLS#">
					#form.body#
					<cfmailparam
						file="ConsolidatedInvoice#url.ConsolidatedInvoiceNumber#.pdf"
						type="application/pdf"
						content="#genPDF#"
						/>
				</cfmail>
				<cfset DirectoryDelete(rootPath,true)>
				<cfset emailSent=1> 
				<cfsavecontent variable="content">
					<div id="message" class="msg-area" style="width: 100%;display:block;"><p>Thank you, <cfoutput>#form.MailFrom#: your message has been sent</cfoutput>.</p></div>
				</cfsavecontent>
			<cfelse>
				<cfoutput>
					<cfsavecontent variable="content">
						<div id="message" class="msg-area" style="width: 100%;display:block;background: none repeat scroll 0 0 ##f4cbc8;border: 1px solid ##f2867a;"><p>Please provide details like 'From', 'To' and 'Subject'.</p></div>
					</cfsavecontent>
				</cfoutput>
			</cfif>
		</cfif>
		<cfcatch>
			<cfoutput>
				<cfsavecontent variable="content">
					<div id="message" class="msg-area" style="width: 100%;display:block;background: none repeat scroll 0 0 ##f4cbc8;border: 1px solid ##f2867a;"><p>Something went wrong.Please try again later.</p></div>
				</cfsavecontent>
			</cfoutput>
		</cfcatch>
	</cftry>
	<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
	<html>
		<head>
			<meta http-equiv="X-UA-Compatible" content="IE=edge" />
			<meta http-equiv="X-UA-Compatible" content="IE=8" >
			<script language="javascript" type="text/javascript" src="https://code.jquery.com/jquery-1.6.2.min.js"></script>
			<script language="javascript" type="text/javascript" src="scripts/jquery.form.js"></script>	
			<link href="../webroot/styles/style.css" rel="stylesheet" type="text/css" />
			<style>
				.progress { position:relative; width:400px; border: 1px solid ##ddd; padding: 1px; border-radius: 3px; }
				.bar { background-image:url("../webroot/images/pbar-ani.gif"); width:0%; height:20px; border-radius: 3px; }
				.percent { position:absolute; display:inline-block; top:3px; left:48%; }
				input.alertbox{ border-color:##dd0000;}
			</style>
			<cfif isDefined("emailSent")>
				<script type="text/javascript">
					$(document).ready(function(){
						alert('The email sent successfully.');
						window.close(); 
					});
				</script>
			</cfif>
		</head>
		<body>
			<cfif isDefined('content')>
				#content#
			</cfif>
			<p> 
				<form action = "index.cfm?event=consolidatedInvoiceMail&ConsolidatedInvoiceNumber=#ConsolidatedInvoiceNumber#&#session.URLToken#" method="POST">
					<div class="white-mid" style=" border-top: 5px solid rgb(130, 187, 239);width: 100%;">
						<div class="form-con" style="width:auto;">
							<fieldset>
								<div style="color:##000000;font-size:14px;font-weight:bold;margin-bottom:20px;margin-top:10px;">Consolidate Invoice Mail</div>
								<div class="clear"></div>
								<label style="margin-top: 3px;">To:</label>
								<input style="width:500px;" type="Text" name="MailTo" class="mid-textbox-1" id="MailTo" value="#MailTo#">
								<div class="clear"></div>
								<label style="margin-top: 3px;">From:</label>
								<input style="width:500px;" type="Text" name="MailFrom" class="mid-textbox-1 disabledLoadInputs" id="MailFrom" value="#MailFrom#" readonly>
								<div class="clear"></div>
								<label style="margin-top: 3px;">Subject:</label>
								<input style="width:500px;" type="Text" name="Subject" class="mid-textbox-1" id="Subject" value="ConsolidatedInvoice #url.ConsolidatedInvoiceNumber#">
								<div class="clear"></div>
								<label style="margin-top: 3px;">Message:</label>
								<textarea style="width:500px;height:180px;" class="addressChange" rows="" name="body" id="body" cols="">#body#	 <cfif not IsDefined("form.send")>&##13;&##10;#emailSignature#</cfif></textarea>
								<div class="clear"></div>
							</fieldset>
						</div>
					</div>
					<div class="white-mid" style="width:auto;">
						<div class="form-con" style="bottom: 0px; position: absolute; background-color: rgb(130, 187, 239); width: 100%; padding: 2px 5px;">
							<fieldset>
								<div style="width:auto;">
									<input type = "Submit" name = "send" value="Send">
								</div>
							</fieldset>
						</div>
					</div>
				</p> 
			</form> 
		</body> 
	</html>
</cfoutput>



