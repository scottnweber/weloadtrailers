<cfoutput>
	<cfset local.dsn = trim(listFirst(cgi.SCRIPT_NAME,'/'))>
	<cfif structKeyExists(url, "CompanyID")>
		<cfset local.companyid = url.companyid>
	<cfelse>
		<cfset local.companyid = session.companyid>
	</cfif>

	<cfif structKeyExists(url, "loadstatus") and len(trim(url.loadstatus))>
		<cfquery name="qUpdSysConfig" datasource="#local.dsn#">
			UPDATE SystemConfig SET DriverSettlementStatusID = <cfqueryparam value="#url.loadstatus#" cfsqltype="cf_sql_varchar"> WHERE CompanyID = <cfqueryparam value="#local.CompanyID#" cfsqltype="cf_sql_varchar">
		</cfquery>
	</cfif>
	<cfquery name="qgetSysConfig" datasource="#local.dsn#">
		SELECT
		(SELECT companyName FROM SystemConfig WHERE CompanyID = <cfqueryparam value="#local.CompanyID#" cfsqltype="cf_sql_varchar">) AS companyName,
		(SELECT companyLogoName FROM SystemConfig WHERE CompanyID = <cfqueryparam value="#local.CompanyID#" cfsqltype="cf_sql_varchar">) AS companyLogoName,
		Address,
		City,
		State,
		ZipCode,
		Phone,
		fax,
		companycode
		FROM Companies WHERE CompanyID = <cfqueryparam value="#local.CompanyID#" cfsqltype="cf_sql_varchar">
	</cfquery>

	<cfquery name="qgetDriverSettlement" datasource="#local.dsn#">	
		SELECT 
		C.CarrierID,
		C.CarrierName,
		C.Address,
		C.City,
		C.stateCode,
		C.ZipCode,
		C.EmailID,
		C.phone,
		L.LoadNumber,
		LS.StopNo,
		LS.LoadType,
		LS.City AS StopCity,
		LS.Statecode AS StopStatecode,
		LS.StopDate,
		LS.StopTime,
		ISNULL(LS.Miles,0) AS Miles,
		ISNULL(L.DeadHeadMiles,0) AS DeadHeadMiles,
		ISNULL(L.CarrFlatRate,0) AS CarrFlatRate,
		ISNULL(L.carrierMilesCharges,0) AS carrierMilesCharges,
		LSC.SrNo,
		C.IsCarrier,
		ISNULL(LSC.CarrCharges,0) AS CarrCharges,
		ISNULL(U.PaymentAdvance,0) AS PaymentAdvance,
		CONVERT(varchar(25),L.LoadNumber)+CONVERT(varchar(25),LS.StopNo)+CONVERT(varchar(25),LSC.SrNo) AS ComGrp,
		L.orderDate,
		U.UnitName,
		U.UnitCode,
		LSC.Description,
		L.NewPickupDate,
		L.LoadID,
		LS.NewDriverName,
		LS.NewDriverName2, 
		LSC.qty,
		LSC.CarrRateOfCustTotal,
		LSC.CustRate,
		LSC.CarrRate,
		L.NewDeliverydate,
		0 AS IsCarrierExp
		FROM Carriers C
		LEFT JOIN LoadStops LS ON LS.NewCarrierID = C.CarrierID
		LEFT JOIN LoadStopCommodities LSC ON LSC.LoadStopID = LS.LoadStopID
		LEFT JOIN Loads L ON L.LoadID = LS.LoadID
		LEFT JOIN LoadStatusTypes LST ON LST.StatusTypeID = L.StatusTypeID
		LEFT JOIN Units U ON LSC.UnitID = U.UnitID 
		LEFT JOIN Employees Emp ON Emp.EmployeeID = L.DispatcherID
        LEFT JOIN Offices O ON O.OfficeID = Emp.OfficeID 
		WHERE 
		<cfif structKeyExists(url, "History") AND url.History EQ 1 AND structKeyExists(url, "HistoryDate") AND Len(Trim(url.HistoryDate))> 
			L.DriverPaidDate = <cfqueryparam value="#url.HistoryDate#" cfsqltype="cf_sql_date">
		<cfelse>
			L.DriverPaidDate IS NULL
		</cfif>
		<cfif structKeyExists(url, "StatusFrom") AND structKeyExists(url, "StatusTo") AND len(trim(url.StatusFrom)) AND len(trim(url.StatusTo))>
			AND LST.StatusText BETWEEN <cfqueryparam value="#url.StatusFrom#" cfsqltype="cf_sql_varchar"> AND <cfqueryparam value="#url.StatusTo#" cfsqltype="cf_sql_varchar">
		<cfelseif structKeyExists(url, "loadstatus") and len(trim(url.loadstatus))>
			AND L.StatusTypeID = <cfqueryparam value="#url.loadstatus#" cfsqltype="cf_sql_varchar">
		</cfif>	
		<cfif structKeyExists(url, "EndDeliveryDate") AND Len(Trim(url.EndDeliveryDate))>
			AND ISNULL(L.NewDeliverydate,L.NewPickupDate) <= <cfqueryparam value="#url.EndDeliveryDate#" cfsqltype="cf_sql_date">
		</cfif>
		AND C.CompanyID = <cfqueryparam value="#local.CompanyID#" cfsqltype="cf_sql_varchar">
		<cfif structKeyExists(url, "CarrierID") AND len(trim(url.CarrierID))>
			AND C.CarrierID = <cfqueryparam value="#url.CarrierID#" cfsqltype="cf_sql_varchar">
		</cfif>
		<cfif structkeyexists(url,"officeFrom") AND len(trim(url.officeFrom))>
	        AND O.OfficeCode>= <cfqueryparam value="#url.officeFrom#" cfsqltype="cf_sql_varchar">
	    </cfif>
	    <cfif structkeyexists(url,"officeTo") AND len(trim(url.officeTo))>
	        AND O.OfficeCode<= <cfqueryparam value="#url.officeTo#" cfsqltype="cf_sql_varchar">
	    </cfif>
		UNION
		SELECT 
		C.CarrierID,
		C.CarrierName,
		C.Address,
		C.City,
		C.stateCode,
		C.ZipCode,
		C.EmailID,
		C.phone,
		NULL AS LoadNumber,
		0 AS StopNo,
		1 AS LoadType,
		NULL AS StopCity,
		NULL AS StopStatecode,
		NULL StopDate,
		NULL StopTime,
		0 AS Miles,
		0 AS DeadHeadMiles,
		0 AS CarrFlatRate,
		0 AS carrierMilesCharges,
		0 AS SrNo,
		C.IsCarrier,
		CE.Amount AS CarrCharges,
		0 AS PaymentAdvance,
		CONVERT(varchar(25),CHECKSUM(NEWID())) AS ComGrp,
		NULL AS orderDate,
		NULL AS UnitName,
		NULL AS UnitCode,
		CE.Description,
		NULL AS NewPickupDate,
		NULL AS LoadID,
		NULL AS NewDriverName,
		NULL AS NewDriverName2,
		NULL AS qty,
		0 AS CarrRateOfCustTotal,
		0 AS CustRate,
		CE.Amount AS CarrRate,
		CE.Date AS NewDeliverydate,
		1 AS IsCarrierExp
		FROM Carriers C
		INNER JOIN CarrierExpenses CE ON CE.CarrierID = C.CarrierID
		WHERE C.CompanyID = <cfqueryparam value="#local.CompanyID#" cfsqltype="cf_sql_varchar">
		AND ISNULL(IsCarrier,0) = 0
		<cfif structKeyExists(url, "CarrierID") AND len(trim(url.CarrierID))>
			AND C.CarrierID = <cfqueryparam value="#url.CarrierID#" cfsqltype="cf_sql_varchar">
		</cfif>
		<cfif structKeyExists(url, "History") AND url.History EQ 1 AND structKeyExists(url, "HistoryDate") AND Len(Trim(url.HistoryDate))> 
			AND CE.DriverPaidDate = <cfqueryparam value="#url.HistoryDate#" cfsqltype="cf_sql_date">
		<cfelse>
			AND CE.DriverPaidDate IS NULL
		</cfif>
		<cfif structKeyExists(url, "EndDeliveryDate") AND Len(Trim(url.EndDeliveryDate))>
			AND CE.Date <= <cfqueryparam value="#url.EndDeliveryDate#" cfsqltype="cf_sql_date">
		</cfif>
		ORDER BY CarrierName,NewDeliveryDate,LoadNumber,StopNo,LoadType
	</cfquery>
	<cfset CarrierIDList = ListRemoveDuplicates(ValueList(qgetDriverSettlement.CarrierID))>
	<cfif structKeyExists(url, "SettlementPaid") and url.SettlementPaid EQ 1 and structKeyExists(url, "PaidDate") and len(trim(url.PaidDate))>
		<cfset LoadNumberList = ListRemoveDuplicates(ValueList(qgetDriverSettlement.LoadNumber))>

		<CFSTOREDPROC PROCEDURE="spUpdateDriverPaidDate" DATASOURCE="#local.dsn#">
			<CFPROCPARAM VALUE="#url.PaidDate#" cfsqltype="cf_sql_date">
			<CFPROCPARAM VALUE="#ListRemoveDuplicates(ValueList(qgetDriverSettlement.LoadID))#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR">
		</CFSTOREDPROC>
		
		<cfloop list="#LoadNumberList#" index="LoadNo">
			<cfquery dbtype="query" name="qGetLoad">
				SELECT LoadID AS ID FROM qgetDriverSettlement WHERE LoadNumber = <cfqueryparam value="#LoadNo#" cfsqltype="cf_sql_varchar">
			</cfquery>
			<cfquery name="insertLoadLog" datasource="#application.dsn#" result="qResult">
				INSERT INTO LoadLogs (
							LoadID,
							LoadNumber,
							FieldLabel,
							oldValue,
							NewValue,
							UpdatedByUserID,
							UpdatedBy,
							UpdatedTimestamp
						)
					values
						(
							<cfqueryparam value="#qGetLoad.ID#" cfsqltype="cf_sql_nvarchar">,
							<cfqueryparam value="#LoadNo#" cfsqltype="cf_sql_bigint">,
							<cfqueryparam value="Driver Paid Date" cfsqltype="cf_sql_nvarchar">,
							NULL,
							<cfqueryparam value="#url.PaidDate#" cfsqltype="cf_sql_nvarchar">,
							<cfqueryparam value="#url.empid#" cfsqltype="cf_sql_nvarchar">,
							<cfqueryparam value="#url.user#" cfsqltype="cf_sql_nvarchar">,
							<cfqueryparam value="#Now()#" cfsqltype="cf_sql_timestamp">
						)
			</cfquery>
		</cfloop>
		
		<cfif len(trim(CarrierIDList))>
			<CFSTOREDPROC PROCEDURE="spUpdateDriverPaidDate" DATASOURCE="#local.dsn#">
				<CFPROCPARAM VALUE="#url.PaidDate#" cfsqltype="cf_sql_date">
				<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR">
				<CFPROCPARAM VALUE="#CarrierIDList#" cfsqltype="CF_SQL_VARCHAR">
				<cfif structKeyExists(url, "EndDeliveryDate") AND Len(Trim(url.EndDeliveryDate))>
					<CFPROCPARAM VALUE="#url.EndDeliveryDate#" cfsqltype="cf_sql_date">
				</cfif>
			</CFSTOREDPROC>
		</cfif>
	</cfif>

	<cfset fileName = "Driver Settlement Report Date-#DateFormat(Now(),'mm.dd.yyyy')#.pdf">
	<cfheader name="Content-Disposition" value="inline; filename=#fileName#">

	<cfif not qgetDriverSettlement.recordcount>
		<cfdocument format="PDF" name="driversettlement">
			No Record Found.
		</cfdocument>
		<cfcontent variable="#toBinary(driversettlement)#" type="application/pdf" />
		<cfabort>
	</cfif>
	<cfdocument format="PDF" name="driversettlement"  margintop="1.5">
		<cfdocumentitem type="header">
			<table width="100%" style='font-family: "Arial";font-size: 13px;margin-bottom: 10px;' cellspacing="0">
				<tr>
					<td valign="top" align="left" style="border-bottom: 1px solid black;">
						<img src="../fileupload/img/#qgetSysConfig.companycode#/logo/#qgetSysConfig.companyLogoName#" width="90"><br>
						<strong style='font-size: 14px;'>#qgetSysConfig.companyName#</strong><br>
						#qgetSysConfig.address#<br>
						#qgetSysConfig.City# #qgetSysConfig.State# #qgetSysConfig.ZipCode#<br>
						<strong>Phone ##:</strong>#qgetSysConfig.Phone#<br>
						<strong>Fax ##:</strong>#qgetSysConfig.Fax#
					</td>
					<td valign="top" align="center" style="border-bottom: 1px solid black;"><h1 style="text-align: center;">Driver Settlement</h1></td>
					<td valign="top" align="right" style="font-size: 17px;"  style="border-bottom: 1px solid black;">
						<br><strong>Date:</strong><cfif structKeyExists(url, "History") AND url.History EQ 1 AND structKeyExists(url, "HistoryDate") AND Len(Trim(url.HistoryDate))>#DateFormat(url.HistoryDate,"m/d/yy")#<cfelse>#DateFormat(now(),"m/d/yy")#</cfif><br>
					</td>
				</tr>
			</table>
		</cfdocumentitem>
		<cfloop query="qgetDriverSettlement" group="CarrierID">
			<cfset TotalPayroll =0>
			<cfset TotalPayrollAdvance =0>
			<b><cfif qgetDriverSettlement.IsCarrier eq 1>Carier<cfelse>Driver</cfif> Details</b><br>
			<b style="font-size: 12px;">#qgetDriverSettlement.CarrierName#</b>
			<p style="font-size: 12px;margin:0;">#qgetDriverSettlement.Address#</p>
			<p style="font-size: 12px;margin:0;">#qgetDriverSettlement.City#, #qgetDriverSettlement.stateCode# #qgetDriverSettlement.ZipCode#</p>
			<p style="font-size: 12px;margin:0;">#qgetDriverSettlement.Phone#</p>

			<cfif structKeyExists(url, "GroupByLoad") AND url.GroupByLoad EQ 1>
				<cfset CarrierTotal = 0>
				<cfloop group = "LoadNumber">
					<cfif len(trim(LoadNumber))>
					<cfset TotalPaymentAmount = 0>
					<table width="100%" style='font-family: "Arial";margin-top: 15px;font-size: 13px;' cellspacing="0" cellpadding="0" border=1>
						<tr>
							<th>Load##</th>
							<th>Date</th>
							<th>Description</th>
							<th>Loaded<br>Miles</th>
							<th>DH Miles</th>
							<th>Amount</th>
						</tr>
						<tr>
							<cfset CarrierPay = qgetDriverSettlement.CarrFlatRate+qgetDriverSettlement.carrierMilesCharges>
							<cfset TotalPaymentAmount = TotalPaymentAmount+CarrierPay>
							<cfset Tmiles = 0>
							<cfset DHmiles = 0>

							<cfset StopCityC = "">
							<cfset StopStateCodeC = "">
							<cfset StopDateC = "">
							<cfset StopTimeC = "">

							<cfloop group = "stopNo">
								<cfset Tmiles = Tmiles+qgetDriverSettlement.miles>
								<cfset DHmiles = DHmiles+qgetDriverSettlement.DeadHeadMiles>
								<cfloop group = "loadType">
									<cfif qgetDriverSettlement.LoadType EQ 2>
										<cfset StopCityC = qgetDriverSettlement.StopCity>
										<cfset StopStateCodeC = qgetDriverSettlement.StopStateCode>
										<cfset StopDateC = qgetDriverSettlement.StopDate>
										<cfset StopTimeC = qgetDriverSettlement.StopTime>
									</cfif>
								</cfloop>
							</cfloop>
							<td align="center">#qgetDriverSettlement.LoadNumber#</td>
							<td align="center">#qgetDriverSettlement.LoadNumber#</td>
							<td align="center">
								#qgetDriverSettlement.StopCity#, #qgetDriverSettlement.StopStateCode# - #StopCityC#, #StopStateCodeC#
							</td>
							<td align="right">#NumberFormat(Tmiles,'__.0')#</td>
							<td align="right">#NumberFormat(DHmiles,'__.0')#</td>
							<td align="right">
								#DollarFormat(CarrierPay)#
								<cfif len(trim(qgetDriverSettlement.NewDriverName)) AND len(trim(qgetDriverSettlement.NewDriverName2))>
									<br><b style="font-size: 10px;margin-right: 5px;">SPLIT PAY</b>
								</cfif>
							</td>
						</tr>
						<tr>
							<td>&nbsp;</td>
							<td align="center"><b>Qty</b></td>
							<td><b>Description</b></td>
							<td colspan="2" align="center"><b>Rate</b></td>
							<td align="center"><b>Amount</b></td>
						</tr>

						<cfloop group="ComGrp">
							<cfif len(srNo) and qgetDriverSettlement.CarrCharges gt 0 and qgetDriverSettlement.paymentadvance eq 0>
								<cfset CarrChargesN = qgetDriverSettlement.CarrCharges>
								<cfset TotalPaymentAmount = TotalPaymentAmount+CarrChargesN>
								<tr>
									<td>&nbsp;</td>
									<td align="center">#qgetDriverSettlement.qty#</td>
									<td align="left">#qgetDriverSettlement.Description#</td>
									<td align="right" colspan="2">
										<cfif qgetDriverSettlement.CarrRateOfCustTotal NEQ 0 AND qgetDriverSettlement.CustRate NEQ 0 AND qgetDriverSettlement.CarrRate NEQ 0>  
											
											(
												#NumberFormat(qgetDriverSettlement.CarrRateOfCustTotal)#% of 
												#DollarFormat(qgetDriverSettlement.CustRate)#
												) + #DollarFormat(qgetDriverSettlement.CarrRate)#
											</td>
										<cfelseif qgetDriverSettlement.CarrRateOfCustTotal NEQ 0 AND qgetDriverSettlement.CustRate NEQ 0>
											#NumberFormat(qgetDriverSettlement.CarrRateOfCustTotal)#% of #DollarFormat(qgetDriverSettlement.CustRate)#
										<cfelse>
											#DollarFormat(qgetDriverSettlement.CarrRate)#
										</cfif>
									</td>
									<td align="right">#DollarFormat(CarrChargesN)#</td>
								</tr>
							</cfif>
						</cfloop>
						<cfloop group="ComGrp">
							<cfif len(srNo) and qgetDriverSettlement.CarrCharges gt 0 and qgetDriverSettlement.paymentadvance eq 1>
								<cfset CarrChargesN = qgetDriverSettlement.CarrCharges * -1>
								<cfset TotalPaymentAmount = TotalPaymentAmount+CarrChargesN>
								<tr>
									<td>&nbsp;</td>
									<td align="center">#qgetDriverSettlement.qty#</td>
									<td align="left">#qgetDriverSettlement.Description#</td>
									<td align="right" colspan="2" style="color: red;">
										#DollarFormat(-1*qgetDriverSettlement.CarrRate)#
									</td>
									<td align="right" style="color: red;">#DollarFormat(CarrChargesN)#</td>
								</tr>
							</cfif>
						</cfloop>
						<cfloop group="ComGrp">
							<cfif len(srNo) and qgetDriverSettlement.CarrCharges lt 0>
								<cfset CarrChargesN = qgetDriverSettlement.CarrCharges>
								<cfset TotalPaymentAmount = TotalPaymentAmount+CarrChargesN>
								<tr>
									<td>&nbsp;</td>
									<td align="center">#qgetDriverSettlement.qty#</td>
									<td align="left">#qgetDriverSettlement.Description#</td>
									<td align="right" colspan="2" style="color: red;">
										#DollarFormat(qgetDriverSettlement.CarrRate)#
									</td>
									<td align="right" style="color: red;">#DollarFormat(CarrChargesN)#</td>
								</tr>
							</cfif>
						</cfloop>
						<tr>
							<td colspan="2" style="border-right:none;"><b>Load## #qgetDriverSettlement.LoadNumber#</b></td>
							<td colspan="3" align="right" style="border-right:none;border-left:none;"><b>TOTAL PAY:</b></td>
							<td align="right" style="border-left:none;"><b>#DollarFormat(TotalPaymentAmount)#</b></td>
						</tr>
					</table>
					<cfset CarrierTotal = CarrierTotal + TotalPaymentAmount>
				</cfif>
				</cfloop>
				<table width="100%" style='font-family: "Arial";margin-top: 15px;font-size: 14px;' cellspacing="0" cellpadding="0" border=1>
					<tr>
						<td width="87%" align="right"  style="border-right:none;">
							<b><cfif qgetDriverSettlement.IsCarrier eq 1>Carier<cfelse>Driver</cfif> Total: </b>
						</td>
						<td align="right" style="border-left:none;"><b>#DollarFormat(CarrierTotal)#</b></td>
					</tr>
				</table>
			<cfelse>
				<h3>Load Pay</h3>
				<table width="100%" style='font-family: "Arial";margin-top: 15px;font-size: 13px;' cellspacing="0" cellpadding="0" border=1>
					<thead style="background-color: ##a7a3a3;color:##fff">
						<tr>
							<th>Load##</th>
							<th>Origin</th>
							<th>Destination</th>
							<th>Loaded<br>Miles</th>
							<th>DH Miles</th>
							<th>Load<br>Pay</th>
						</tr>
					</thead>
					<tbody>
						<cfloop group = "LoadNumber">
							<cfif NOT qgetDriverSettlement.IsCarrierExp>
								<cfset CarrierPay = qgetDriverSettlement.CarrFlatRate+qgetDriverSettlement.carrierMilesCharges>
								<cfset TotalPayroll =TotalPayroll+CarrierPay>
								<cfset Tmiles = 0>
								<cfset DHmiles = 0>

								<cfset StopCityC = "">
								<cfset StopStateCodeC = "">
								<cfset StopDateC = "">
								<cfset StopTimeC = "">

								<cfloop group = "stopNo">
									<cfset Tmiles = Tmiles+qgetDriverSettlement.miles>
									<cfset DHmiles = DHmiles+qgetDriverSettlement.DeadHeadMiles>
									<cfloop group = "loadType">
										<cfif qgetDriverSettlement.LoadType EQ 2>
											<cfset StopCityC = qgetDriverSettlement.StopCity>
											<cfset StopStateCodeC = qgetDriverSettlement.StopStateCode>
											<cfset StopDateC = qgetDriverSettlement.StopDate>
											<cfset StopTimeC = qgetDriverSettlement.StopTime>
										</cfif>
									</cfloop>
								</cfloop>

								<tr>
									<td align="center">#qgetDriverSettlement.LoadNumber#</td>
									<td align="center" width="32%">
										#qgetDriverSettlement.StopCity#, #qgetDriverSettlement.StopStateCode#<br> 
										#dateformat(qgetDriverSettlement.StopDate,'mm/dd/yyyy')# <cfif qgetDriverSettlement.StopTime EQ 'ASAP'>#qgetDriverSettlement.StopTime#<cfelseif len(trim(qgetDriverSettlement.StopTime)) AND len(listGetAt(qgetDriverSettlement.StopTime, 1,'-')) EQ 4>#Insert(":",listGetAt(qgetDriverSettlement.StopTime, 1,'-'),2)#</cfif>
									</td>
									<td align="center" width="32%">
										#StopCityC#, #StopStateCodeC#<br> 
										#dateformat(StopDateC,'mm/dd/yyyy')# <cfif StopTimeC EQ 'ASAP'>#qgetDriverSettlement.StopTime#<cfelseif len(trim(StopTimeC)) AND len(listGetAt(StopTimeC, 1,'-')) EQ 4>#Insert(":",listGetAt(StopTimeC, 1,'-'),2)#</cfif>
									</td>
									<td align="right">#NumberFormat(Tmiles,'__.0')#</td>
									<td align="right">#NumberFormat(DHmiles,'__.0')#</td>
									<td align="right">
										#DollarFormat(CarrierPay)#
										<cfif len(trim(qgetDriverSettlement.NewDriverName)) AND len(trim(qgetDriverSettlement.NewDriverName2))>
											<br><b style="font-size: 10px;margin-right: 5px;">SPLIT PAY</b>
										</cfif>
									</td>
								</tr>
							</cfif>
						</cfloop>
					</tbody>
				</table>
				<table width="100%" style='font-family: "Arial";font-size: 13px;margin-top: 10px;' cellspacing="0">
					<tr>
						<td align="left" style="border-bottom: 1px solid gray;padding-bottom: 10px;"><strong>Load Total: #DollarFormat(TotalPayroll)#</strong></td>
						<!--- <td align="center" style="border-bottom: 1px solid gray;padding-bottom: 10px;"><strong>Total Payroll Advance: #DollarFormat(TotalPayrollAdvance)#</strong></td> --->
						<cfset BalancePayroll =TotalPayroll-TotalPayrollAdvance>
						<td align="right" style="border-bottom: 1px solid gray;padding-bottom: 10px;"><strong>Total Load Pay: #DollarFormat(BalancePayroll)#</strong></td>
					</tr>
				</table>
				<h3>Reimbursements and Accessorials</h3>
				<table width="100%" style='font-family: "Arial";margin-top: 15px;font-size: 13px;' cellspacing="0" cellpadding="0" border=1>
					<thead style="background-color: ##a7a3a3;color:##fff">
						<tr>
							<th>Load##</th>
							<th>Qty</th>
							<th>Description</th>
							<th>Rate</th>
							<th>Total</th>
						</tr>
					</thead>
					<tbody>
						<cfset TotalReimbursementAndAccessorial = 0>
						<cfloop group="ComGrp">
							<cfif len(srNo) and qgetDriverSettlement.CarrCharges gt 0>
								<cfif qgetDriverSettlement.PaymentAdvance>
									<cfset CarrChargesN = qgetDriverSettlement.CarrCharges * -1>
								<cfelse>
									<cfset CarrChargesN = qgetDriverSettlement.CarrCharges>
								</cfif>
								<tr>
									<td align="center">#qgetDriverSettlement.loadNumber#</td>
									<td align="center">#qgetDriverSettlement.qty#</td>
									<td align="left">#qgetDriverSettlement.Description#</td>
									<td align="right">
										<cfif qgetDriverSettlement.CarrRateOfCustTotal NEQ 0 AND qgetDriverSettlement.CustRate NEQ 0 AND qgetDriverSettlement.CarrRate NEQ 0>  
											
											(
												#NumberFormat(qgetDriverSettlement.CarrRateOfCustTotal)#% of 
												#DollarFormat(qgetDriverSettlement.CustRate)#
												) + #DollarFormat(qgetDriverSettlement.CarrRate)#
											</td>
										<cfelseif qgetDriverSettlement.CarrRateOfCustTotal NEQ 0 AND qgetDriverSettlement.CustRate NEQ 0>
											#NumberFormat(qgetDriverSettlement.CarrRateOfCustTotal)#% of #DollarFormat(qgetDriverSettlement.CustRate)#
										<cfelse>
											<cfif qgetDriverSettlement.PaymentAdvance>
												#DollarFormat(-1*qgetDriverSettlement.CarrRate)#
											<cfelse>
												#DollarFormat(qgetDriverSettlement.CarrRate)#
											</cfif>
										</cfif>
									</td>
									<td align="right">#DollarFormat(CarrChargesN)#</td>
									<cfset TotalReimbursementAndAccessorial = TotalReimbursementAndAccessorial + CarrChargesN>
								</tr>
							</cfif>
						</cfloop>
					</tbody>
				</table>
				<table width="100%" style='font-family: "Arial";font-size: 13px;margin-top: 10px;' cellspacing="0">
					<tr>
						<td align="right" style="padding-bottom: 10px;border-bottom: 1px solid gray;"><strong>Total Reimbursement and Accessorial: #DollarFormat(TotalReimbursementAndAccessorial)#</strong></td>
					</tr>
				</table>
				<h3>Deductions</h3>
				<table width="100%" style='font-family: "Arial";margin-top: 15px;font-size: 13px;' cellspacing="0" cellpadding="0" border=1>
					<thead style="background-color: ##a7a3a3;color:##fff">
						<tr>
							<th>Load##</th>
							<th>Date</th>
							<th>Type</th>
							<th>Category</th>
							<th>Amount</th>
						</tr>
					</thead>
					<tbody>
						<cfset TotalDeductionsAmount = 0>
						<cfloop group="ComGrp">
							<cfif len(qgetDriverSettlement.srNo) AND  qgetDriverSettlement.CarrCharges lt 0>
								<tr>
									<td align="center">#qgetDriverSettlement.loadNumber#</td>
									<td align="center">#DateFormat(qgetDriverSettlement.orderDate,'mm/dd/yyyy')#</td>
									<td align="center">#qgetDriverSettlement.UnitName#(#qgetDriverSettlement.UnitCode#)</td>
									<td align="center">#qgetDriverSettlement.Description#</td>
									<td align="right">#DollarFormat(qgetDriverSettlement.CarrCharges)#</td>
									<cfset TotalDeductionsAmount = TotalDeductionsAmount + qgetDriverSettlement.CarrCharges>
								</tr>
							</cfif>
						</cfloop>
					</tbody>
				</table>
				<table width="100%" style='font-family: "Arial";font-size: 13px;margin-top: 10px;' cellspacing="0">
					<tr>
						<td align="right" style="padding-bottom: 10px;border-bottom: 1px solid gray;"><strong>Total Deductions Amount: #DollarFormat(TotalDeductionsAmount)#</strong></td>
					</tr>
				</table>
				<h3>Summary</h3>
				<table width="100%" style='font-family: "Arial";font-size: 13px;margin-top: 10px;' cellspacing="0">
					<tr>
						<td align="right" width="90%">
							<strong>Load Pay:</strong>
						</td>
						<td align="right">
							<strong>#DollarFormat(BalancePayroll)#</strong>
						</td>
					</tr>
					<tr>
						<td align="right" width="90%">
							<strong>Total Reimbursement and Accessorial:</strong>
						</td>
						<td align="right">
							<strong>#DollarFormat(TotalReimbursementAndAccessorial)#</strong>
						</td>
					</tr>
					<tr>
						<td align="right" width="90%">
							<strong>Total Deductions:</strong>
						</td>
						<td align="right">
							<strong>#DollarFormat(TotalDeductionsAmount)#</strong>
						</td>
					</tr>
					<tr>
						<td colspan="2">&nbsp;</td>
					</tr>
					<cfset TotalPaymentAmount = BalancePayroll+TotalReimbursementAndAccessorial+TotalDeductionsAmount>
					<tr>
						<td align="right" width="90%">
							<h3>Total Payment Amount:</h3>
						</td>
						<td align="right">
							<h3>#DollarFormat(TotalPaymentAmount)#</h3>
						</td>
					</tr>
				</table>
			</cfif>
			<cfif qgetDriverSettlement.CarrierID NEQ ListLast(CarrierIDList) AND url.PageBreak EQ 1>
				<cfdocumentitem type="pagebreak" />
			</cfif>
		</cfloop>
	</cfdocument>
	<cfsavecontent variable="footerText">
		<span style='font-family: "Arial";font-size: 10pt;'>
			---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
			<br></br>
			<b>#DateFormat(Now(),'mm/dd/yyyy')#</b> 
			<b style="color:white;">LMS</b>
			<p style="font-style: italic;font-size: 8pt;">Powered by Load Manager TMS Software. For more info call (833) 568-8080 or visit www.LoadManager.Com Page</p> 
			<b style="color:white;">LMS</b>
			<b>_PAGENUMBER of _LASTPAGENUMBER</b> 
		</span>
	</cfsavecontent>
	
	<cfpdf action="addFooter" source="driversettlement" name="myDoc" text="#footerText#"/>
	<cfcontent variable="#toBinary(myDoc)#" type="application/pdf" />
</cfoutput>