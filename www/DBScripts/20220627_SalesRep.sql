GO

/****** Object:  View [dbo].[vwSalesRepCommission]    Script Date: 27-06-2022 10:03:49 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER             VIEW [dbo].[vwSalesRepCommission]
AS
SELECT        TOP (100) PERCENT dbo.Companies.CompanyName,dbo.Companies.CompanyID, dbo.Employees.Name AS Dispatcher, ISNULL(NULLIF (Employees_1.Name, N''), N'(BLANK)') AS SalesAgent1, dbo.Loads.LoadNumber, 
                         dbo.LoadStops.StopDate AS OrderDate, UPPER(dbo.Loads.CustName) AS CustName, ISNULL(NULLIF (dbo.Loads.userDefinedFieldTrucking, ''), N'(BLANK)') AS userDefinedFieldTrucking, 
                         dbo.LoadStops.City + ', ' + dbo.LoadStops.StateCode AS FirstStop, dbo.vwCarrierConfirmationReportFinalDestination.City + ', ' + dbo.vwCarrierConfirmationReportFinalDestination.StateCode AS LastStop, 
                         
						 
						 dbo.Loads.TotalCarrierCharges-dbo.LoadStops.CustomDriverPayFlatRate2-dbo.LoadStops.CustomDriverPayFlatRate3 
						 -((dbo.LoadStops.CustomDriverPayPercentage2*dbo.Loads.TotalCustomerCharges)/100)-((dbo.LoadStops.CustomDriverPayPercentage3*dbo.Loads.TotalCustomerCharges)/100)
						 
						 AS TotalCarrierCharges,
						 
						 
						 dbo.Loads.BillDate, 
                         CASE WHEN dbo.SystemConfig.AutomaticFactoringFee = 0 THEN dbo.Loads.TotalCustomerCharges ELSE (dbo.Loads.TotalCustomerCharges - (dbo.Loads.TotalCustomerCharges * dbo.loads.FF / 100)) 
                         END AS TotalCustomerCharges, 


                         ISNULL(CASE WHEN dbo.SystemConfig.AutomaticFactoringFee = 0 THEN dbo.Loads.TotalCustomerCharges ELSE (dbo.Loads.TotalCustomerCharges - (dbo.Loads.TotalCustomerCharges * dbo.loads.FF / 100)) 
                         END - dbo.Loads.TotalCarrierCharges, 0) AS GrossMargin, 
						 
						 
						 dbo.Carriers.CarrierName, ISNULL(Employees_1.SalesCommission, 0) AS CommissionPercent, 
                         ISNULL((dbo.Loads.TotalCustomerCharges - dbo.Loads.TotalCarrierCharges) * (Employees_1.SalesCommission * .01), 0) AS CommissionAmt, dbo.LoadStatusTypes.StatusTypeID, dbo.LoadStatusTypes.StatusText, 
                         ISNULL(dbo.Equipments.EquipmentName, N'(BLANK)') AS EquiptName, dbo.Employees.SalesCommission AS DispatchCommissionPercent1, ISNULL((dbo.Loads.TotalCustomerCharges - dbo.Loads.TotalCarrierCharges) 
                         * (dbo.Employees.SalesCommission * .01), 0) AS DispatchCommissionAmt1, dbo.Carriers.CarrierName AS Driver, ISNULL(TRIM(dbo.Carriers.CarrierName), N'(BLANK)') AS Carrier, dbo.SystemConfig.FreightBroker, 
                         Employees_1.Name AS SalesAgent, ISNULL(dbo.vwSalesRepCommissionCarrierPay.Payments, 0) AS Payments, dbo.Loads.TotalCarrierCharges - ISNULL(dbo.vwSalesRepCommissionCarrierPay.Payments, 0)-dbo.LoadStops.CustomDriverPayFlatRate2-dbo.LoadStops.CustomDriverPayFlatRate3 AS CarrierPay, 
						 CASE WHEN systemconfig.dispatch = 1 THEN 
						 
							 ISNULL(dbo.Carriers.DispatchFee, 0) / 100 * dbo.Loads.TotalCarrierCharges
						 ELSE 
							ISNULL(Employees_1.SalesCommission, 0) / 100 * ISNULL(CASE WHEN dbo.SystemConfig.AutomaticFactoringFee = 0 THEN dbo.Loads.TotalCustomerCharges ELSE (dbo.Loads.TotalCustomerCharges - (dbo.Loads.TotalCustomerCharges * dbo.loads.FF / 100)) 
							END - dbo.Loads.TotalCarrierCharges, 0)
						 END AS CommissionAmountReport,
						 CASE WHEN systemconfig.dispatch = 1 THEN dbo.Carriers.DispatchFee ELSE ISNULL(Employees_1.SalesCommission, 0) 
                         END AS CommissionPercentReport, 
						 dbo.Carriers.DispatchFee AS DispatchCommissionPercent, 
                         ISNULL(dbo.Carriers.DispatchFee * (CASE WHEN dbo.SystemConfig.Dispatch = 1 THEN dbo.Loads.TotalCustomerCharges ELSE (dbo.Loads.TotalCustomerCharges - dbo.Loads.TotalCarrierCharges) END), 0) 
                         AS DispatchCommissionAmt, ISNULL(dbo.Loads.noOfTrips, 0) AS nooftrips, dbo.Loads.CreatedDateTime, dbo.Loads.NewDeliveryDate AS DeliveryDate,


						 systemconfig.dispatch AS IsDispatch,
						 CASE WHEN systemconfig.dispatch = 1 
						 THEN 
							CASE WHEN ISNULL(Carriers.DispatchFee,0) <> 0 THEN Loads.TotalCustomerCharges*(Carriers.DispatchFee/100) WHEN ISNULL(Carriers.DispatchFeeAmount,0) <> 0 AND Loads.TotalCustomerCharges <> 0 THEN Carriers.DispatchFeeAmount ELSE 0 END
						 ELSE 
							0
						 END AS DispatchFeeNew,

						 CASE WHEN systemconfig.dispatch = 1 
						 THEN 
							CASE WHEN ISNULL(Carriers.DispatchFee,0) <> 0 THEN Carriers.DispatchFee WHEN ISNULL(Carriers.DispatchFeeAmount,0) <> 0 AND Loads.TotalCustomerCharges <> 0 THEN (Carriers.DispatchFeeAmount*100)/Loads.TotalCustomerCharges ELSE 0 END
						 ELSE 
							0
						 END AS DispatchFeePercNew
						 ,dbo.SystemConfig.CompanyLogoName,dbo.Companies.CompanyCode,1 as sortField
						 ,dbo.Loads.HasLateStop, dbo.Offices.OfficeCode, Dispatcher1.Name AS Dispatcher1, Dispatcher2.Name AS Dispatcher2, Dispatcher3.Name AS Dispatcher3
						 ,Office1.OfficeCode AS OfficeCode1,Office2.OfficeCode AS OfficeCode2,Office3.OfficeCode AS OfficeCode3
FROM            dbo.Employees AS Employees_1 RIGHT OUTER JOIN
                         dbo.LoadStatusTypes INNER JOIN
                         dbo.Loads INNER JOIN
                         dbo.LoadStops ON dbo.Loads.LoadID = dbo.LoadStops.LoadID INNER JOIN
                         dbo.vwCarrierConfirmationReportFinalDestination ON dbo.Loads.LoadID = dbo.vwCarrierConfirmationReportFinalDestination.LoadID ON dbo.LoadStatusTypes.StatusTypeID = dbo.Loads.StatusTypeID LEFT OUTER JOIN
                         dbo.vwSalesRepCommissionCarrierPay ON dbo.Loads.LoadID = dbo.vwSalesRepCommissionCarrierPay.LoadID LEFT OUTER JOIN
                         dbo.Equipments ON dbo.LoadStops.NewEquipmentID = dbo.Equipments.EquipmentID 
						 LEFT OUTER JOIN dbo.Carriers ON dbo.LoadStops.NewCarrierID = dbo.Carriers.CarrierID
						 ON Employees_1.EmployeeID = dbo.Loads.SalesRepID LEFT OUTER JOIN
                         dbo.Employees ON dbo.Loads.DispatcherID = dbo.Employees.EmployeeID LEFT OUTER JOIN
                         dbo.Employees Dispatcher1 ON dbo.Loads.Dispatcher1 = Dispatcher1.EmployeeID LEFT OUTER JOIN
						 dbo.Offices Office1 ON Office1.OfficeID = Dispatcher1.OfficeID LEFT OUTER JOIN
                         dbo.Employees Dispatcher2 ON dbo.Loads.Dispatcher2 = Dispatcher2.EmployeeID LEFT OUTER JOIN
						 dbo.Offices Office2 ON Office2.OfficeID = Dispatcher2.OfficeID LEFT OUTER JOIN
                         dbo.Employees Dispatcher3 ON dbo.Loads.Dispatcher3 = Dispatcher3.EmployeeID LEFT OUTER JOIN
						 dbo.Offices Office3 ON Office3.OfficeID = Dispatcher3.OfficeID LEFT OUTER JOIN
						 dbo.Offices ON dbo.Offices.OfficeID = dbo.Employees.OfficeID INNER JOIN 
                         dbo.Companies ON dbo.Companies.CompanyID = dbo.Offices.CompanyID INNER JOIN 
                         dbo.SystemConfig ON  dbo.SystemConfig.CompanyID = dbo.Companies.CompanyID
WHERE        (dbo.LoadStops.LoadType = 1) AND (dbo.LoadStops.StopNo + 1 = 1)


UNION

SELECT        TOP (100) PERCENT dbo.Companies.CompanyName,dbo.Companies.CompanyID, dbo.Employees.Name AS Dispatcher, ISNULL(NULLIF (Employees_1.Name, N''), N'(BLANK)') AS SalesAgent1, dbo.Loads.LoadNumber, 
                         dbo.LoadStops.StopDate AS OrderDate, UPPER(dbo.Loads.CustName) AS CustName, ISNULL(NULLIF (dbo.Loads.userDefinedFieldTrucking, ''), N'(BLANK)') AS userDefinedFieldTrucking, 
                         dbo.LoadStops.City + ', ' + dbo.LoadStops.StateCode AS FirstStop, dbo.vwCarrierConfirmationReportFinalDestination.City + ', ' + dbo.vwCarrierConfirmationReportFinalDestination.StateCode AS LastStop, 
                         
						 (dbo.LoadStops.CustomDriverPayFlatRate2+ ((dbo.LoadStops.CustomDriverPayPercentage2*dbo.Loads.TotalCustomerCharges)/100)) AS TotalCarrierCharges,
						 
						 
						 dbo.Loads.BillDate, 
                         0 AS TotalCustomerCharges, 


                         0 AS GrossMargin, 
						 
						 
						 dbo.Carriers.CarrierName, ISNULL(Employees_1.SalesCommission, 0) AS CommissionPercent, 
                         ISNULL((dbo.Loads.TotalCustomerCharges - dbo.Loads.TotalCarrierCharges) * (Employees_1.SalesCommission * .01), 0) AS CommissionAmt, dbo.LoadStatusTypes.StatusTypeID, dbo.LoadStatusTypes.StatusText, 
                         ISNULL(dbo.Equipments.EquipmentName, N'(BLANK)') AS EquiptName, dbo.Employees.SalesCommission AS DispatchCommissionPercent1, ISNULL((dbo.Loads.TotalCustomerCharges - dbo.Loads.TotalCarrierCharges) 
                         * (dbo.Employees.SalesCommission * .01), 0) AS DispatchCommissionAmt1, dbo.Carriers.CarrierName AS Driver, ISNULL(TRIM(dbo.Carriers.CarrierName), N'(BLANK)') AS Carrier, dbo.SystemConfig.FreightBroker, 
                         Employees_1.Name AS SalesAgent, ISNULL(dbo.vwSalesRepCommissionCarrierPay.Payments, 0) AS Payments, dbo.LoadStops.CustomDriverPayFlatRate2 AS CarrierPay, 
						 CASE WHEN systemconfig.dispatch = 1 THEN 
						 
							 ISNULL(dbo.Carriers.DispatchFee, 0) / 100 * dbo.Loads.TotalCarrierCharges
						 ELSE 
							ISNULL(Employees_1.SalesCommission, 0) / 100 * ISNULL(CASE WHEN dbo.SystemConfig.AutomaticFactoringFee = 0 THEN dbo.Loads.TotalCustomerCharges ELSE (dbo.Loads.TotalCustomerCharges - (dbo.Loads.TotalCustomerCharges * dbo.loads.FF / 100)) 
							END - dbo.Loads.TotalCarrierCharges, 0)
						 END AS CommissionAmountReport,
						 CASE WHEN systemconfig.dispatch = 1 THEN dbo.Carriers.DispatchFee ELSE ISNULL(Employees_1.SalesCommission, 0) 
                         END AS CommissionPercentReport, 
						 dbo.Carriers.DispatchFee AS DispatchCommissionPercent, 
                         ISNULL(dbo.Carriers.DispatchFee * (CASE WHEN dbo.SystemConfig.Dispatch = 1 THEN dbo.Loads.TotalCustomerCharges ELSE (dbo.Loads.TotalCustomerCharges - dbo.Loads.TotalCarrierCharges) END), 0) 
                         AS DispatchCommissionAmt, ISNULL(dbo.Loads.noOfTrips, 0) AS nooftrips, dbo.Loads.CreatedDateTime, dbo.Loads.NewDeliveryDate AS DeliveryDate,


						 systemconfig.dispatch AS IsDispatch,
						 CASE WHEN systemconfig.dispatch = 1 
						 THEN 
							CASE WHEN ISNULL(Carriers.DispatchFee,0) <> 0 THEN Loads.TotalCustomerCharges*(Carriers.DispatchFee/100) WHEN ISNULL(Carriers.DispatchFeeAmount,0) <> 0 AND Loads.TotalCustomerCharges <> 0 THEN Carriers.DispatchFeeAmount ELSE 0 END
						 ELSE 
							0
						 END AS DispatchFeeNew,

						 CASE WHEN systemconfig.dispatch = 1 
						 THEN 
							CASE WHEN ISNULL(Carriers.DispatchFee,0) <> 0 THEN Carriers.DispatchFee WHEN ISNULL(Carriers.DispatchFeeAmount,0) <> 0 AND Loads.TotalCustomerCharges <> 0 THEN (Carriers.DispatchFeeAmount*100)/Loads.TotalCustomerCharges ELSE 0 END
						 ELSE 
							0
						 END AS DispatchFeePercNew
						 ,dbo.SystemConfig.CompanyLogoName,dbo.Companies.CompanyCode,2 as sortField
						 ,dbo.Loads.HasLateStop, dbo.Offices.OfficeCode, Dispatcher1.Name AS Dispatcher1, Dispatcher2.Name AS Dispatcher2, Dispatcher3.Name AS Dispatcher3
						 ,Office1.OfficeCode AS OfficeCode1,Office2.OfficeCode AS OfficeCode2,Office3.OfficeCode AS OfficeCode3
FROM            dbo.Employees AS Employees_1 RIGHT OUTER JOIN
                         dbo.LoadStatusTypes INNER JOIN
                         dbo.Loads INNER JOIN
                         dbo.LoadStops ON dbo.Loads.LoadID = dbo.LoadStops.LoadID INNER JOIN
                         dbo.vwCarrierConfirmationReportFinalDestination ON dbo.Loads.LoadID = dbo.vwCarrierConfirmationReportFinalDestination.LoadID ON dbo.LoadStatusTypes.StatusTypeID = dbo.Loads.StatusTypeID LEFT OUTER JOIN
                         dbo.vwSalesRepCommissionCarrierPay ON dbo.Loads.LoadID = dbo.vwSalesRepCommissionCarrierPay.LoadID LEFT OUTER JOIN
                         dbo.Equipments ON dbo.LoadStops.NewEquipmentID = dbo.Equipments.EquipmentID 
						 LEFT OUTER JOIN dbo.Carriers ON dbo.LoadStops.NewCarrierID2 = dbo.Carriers.CarrierID 
						 ON Employees_1.EmployeeID = dbo.Loads.SalesRepID LEFT OUTER JOIN
                         dbo.Employees ON dbo.Loads.DispatcherID = dbo.Employees.EmployeeID LEFT OUTER JOIN
                         dbo.Employees Dispatcher1 ON dbo.Loads.Dispatcher1 = Dispatcher1.EmployeeID LEFT OUTER JOIN
						 dbo.Offices Office1 ON Office1.OfficeID = Dispatcher1.OfficeID LEFT OUTER JOIN
                         dbo.Employees Dispatcher2 ON dbo.Loads.Dispatcher2 = Dispatcher2.EmployeeID LEFT OUTER JOIN
						 dbo.Offices Office2 ON Office2.OfficeID = Dispatcher2.OfficeID LEFT OUTER JOIN
                         dbo.Employees Dispatcher3 ON dbo.Loads.Dispatcher3 = Dispatcher3.EmployeeID LEFT OUTER JOIN
						 dbo.Offices Office3 ON Office3.OfficeID = Dispatcher3.OfficeID LEFT OUTER JOIN
						 dbo.Offices ON dbo.Offices.OfficeID = dbo.Employees.OfficeID INNER JOIN 
                         dbo.Companies ON dbo.Companies.CompanyID = dbo.Offices.CompanyID INNER JOIN 
                         dbo.SystemConfig ON  dbo.SystemConfig.CompanyID = dbo.Companies.CompanyID
WHERE        (dbo.LoadStops.LoadType = 1) AND (dbo.LoadStops.StopNo + 1 = 1) AND dbo.LoadStops.NewCarrierID2 IS NOT NULL




UNION

SELECT        TOP (100) PERCENT dbo.Companies.CompanyName,dbo.Companies.CompanyID, dbo.Employees.Name AS Dispatcher, ISNULL(NULLIF (Employees_1.Name, N''), N'(BLANK)') AS SalesAgent1, dbo.Loads.LoadNumber, 
                         dbo.LoadStops.StopDate AS OrderDate, UPPER(dbo.Loads.CustName) AS CustName, ISNULL(NULLIF (dbo.Loads.userDefinedFieldTrucking, ''), N'(BLANK)') AS userDefinedFieldTrucking, 
                         dbo.LoadStops.City + ', ' + dbo.LoadStops.StateCode AS FirstStop, dbo.vwCarrierConfirmationReportFinalDestination.City + ', ' + dbo.vwCarrierConfirmationReportFinalDestination.StateCode AS LastStop, 
                         
						 
						 (dbo.LoadStops.CustomDriverPayFlatRate3+ ((dbo.LoadStops.CustomDriverPayPercentage3*dbo.Loads.TotalCustomerCharges)/100)) AS TotalCarrierCharges,
						 
						 
						 dbo.Loads.BillDate, 
                         0 AS TotalCustomerCharges, 


                         0 AS GrossMargin, 
						 
						 
						 dbo.Carriers.CarrierName, ISNULL(Employees_1.SalesCommission, 0) AS CommissionPercent, 
                         ISNULL((dbo.Loads.TotalCustomerCharges - dbo.Loads.TotalCarrierCharges) * (Employees_1.SalesCommission * .01), 0) AS CommissionAmt, dbo.LoadStatusTypes.StatusTypeID, dbo.LoadStatusTypes.StatusText, 
                         ISNULL(dbo.Equipments.EquipmentName, N'(BLANK)') AS EquiptName, dbo.Employees.SalesCommission AS DispatchCommissionPercent1, ISNULL((dbo.Loads.TotalCustomerCharges - dbo.Loads.TotalCarrierCharges) 
                         * (dbo.Employees.SalesCommission * .01), 0) AS DispatchCommissionAmt1, dbo.Carriers.CarrierName AS Driver, ISNULL(TRIM(dbo.Carriers.CarrierName), N'(BLANK)') AS Carrier, dbo.SystemConfig.FreightBroker, 
                         Employees_1.Name AS SalesAgent, ISNULL(dbo.vwSalesRepCommissionCarrierPay.Payments, 0) AS Payments, dbo.LoadStops.CustomDriverPayFlatRate3 AS CarrierPay, 
						 CASE WHEN systemconfig.dispatch = 1 THEN 
						 
							 ISNULL(dbo.Carriers.DispatchFee, 0) / 100 * dbo.Loads.TotalCarrierCharges
						 ELSE 
							ISNULL(Employees_1.SalesCommission, 0) / 100 * ISNULL(CASE WHEN dbo.SystemConfig.AutomaticFactoringFee = 0 THEN dbo.Loads.TotalCustomerCharges ELSE (dbo.Loads.TotalCustomerCharges - (dbo.Loads.TotalCustomerCharges * dbo.loads.FF / 100)) 
							END - dbo.Loads.TotalCarrierCharges, 0)
						 END AS CommissionAmountReport,
						 CASE WHEN systemconfig.dispatch = 1 THEN dbo.Carriers.DispatchFee ELSE ISNULL(Employees_1.SalesCommission, 0) 
                         END AS CommissionPercentReport, 
						 dbo.Carriers.DispatchFee AS DispatchCommissionPercent, 
                         ISNULL(dbo.Carriers.DispatchFee * (CASE WHEN dbo.SystemConfig.Dispatch = 1 THEN dbo.Loads.TotalCustomerCharges ELSE (dbo.Loads.TotalCustomerCharges - dbo.Loads.TotalCarrierCharges) END), 0) 
                         AS DispatchCommissionAmt, ISNULL(dbo.Loads.noOfTrips, 0) AS nooftrips, dbo.Loads.CreatedDateTime, dbo.Loads.NewDeliveryDate AS DeliveryDate,


						 systemconfig.dispatch AS IsDispatch,
						 CASE WHEN systemconfig.dispatch = 1 
						 THEN 
							CASE WHEN ISNULL(Carriers.DispatchFee,0) <> 0 THEN Loads.TotalCustomerCharges*(Carriers.DispatchFee/100) WHEN ISNULL(Carriers.DispatchFeeAmount,0) <> 0 AND Loads.TotalCustomerCharges <> 0 THEN Carriers.DispatchFeeAmount ELSE 0 END
						 ELSE 
							0
						 END AS DispatchFeeNew,

						 CASE WHEN systemconfig.dispatch = 1 
						 THEN 
							CASE WHEN ISNULL(Carriers.DispatchFee,0) <> 0 THEN Carriers.DispatchFee WHEN ISNULL(Carriers.DispatchFeeAmount,0) <> 0 AND Loads.TotalCustomerCharges <> 0 THEN (Carriers.DispatchFeeAmount*100)/Loads.TotalCustomerCharges ELSE 0 END
						 ELSE 
							0
						 END AS DispatchFeePercNew
						 ,dbo.SystemConfig.CompanyLogoName,dbo.Companies.CompanyCode,3 as sortField
						 ,dbo.Loads.HasLateStop, dbo.Offices.OfficeCode, Dispatcher1.Name AS Dispatcher1, Dispatcher2.Name AS Dispatcher2, Dispatcher3.Name AS Dispatcher3
						 ,Office1.OfficeCode AS OfficeCode1,Office2.OfficeCode AS OfficeCode2,Office3.OfficeCode AS OfficeCode3
FROM            dbo.Employees AS Employees_1 RIGHT OUTER JOIN
                         dbo.LoadStatusTypes INNER JOIN
                         dbo.Loads INNER JOIN
                         dbo.LoadStops ON dbo.Loads.LoadID = dbo.LoadStops.LoadID INNER JOIN
                         dbo.vwCarrierConfirmationReportFinalDestination ON dbo.Loads.LoadID = dbo.vwCarrierConfirmationReportFinalDestination.LoadID ON dbo.LoadStatusTypes.StatusTypeID = dbo.Loads.StatusTypeID LEFT OUTER JOIN
                         dbo.vwSalesRepCommissionCarrierPay ON dbo.Loads.LoadID = dbo.vwSalesRepCommissionCarrierPay.LoadID LEFT OUTER JOIN
                         dbo.Equipments ON dbo.LoadStops.NewEquipmentID = dbo.Equipments.EquipmentID 
						 LEFT OUTER JOIN dbo.Carriers ON dbo.LoadStops.NewCarrierID3 = dbo.Carriers.CarrierID 
						 ON Employees_1.EmployeeID = dbo.Loads.SalesRepID LEFT OUTER JOIN
                         dbo.Employees ON dbo.Loads.DispatcherID = dbo.Employees.EmployeeID LEFT OUTER JOIN
                         dbo.Employees Dispatcher1 ON dbo.Loads.Dispatcher1 = Dispatcher1.EmployeeID LEFT OUTER JOIN
						 dbo.Offices Office1 ON Office1.OfficeID = Dispatcher1.OfficeID LEFT OUTER JOIN
                         dbo.Employees Dispatcher2 ON dbo.Loads.Dispatcher2 = Dispatcher2.EmployeeID LEFT OUTER JOIN
						 dbo.Offices Office2 ON Office2.OfficeID = Dispatcher2.OfficeID LEFT OUTER JOIN
                         dbo.Employees Dispatcher3 ON dbo.Loads.Dispatcher3 = Dispatcher3.EmployeeID LEFT OUTER JOIN
						 dbo.Offices Office3 ON Office3.OfficeID = Dispatcher3.OfficeID LEFT OUTER JOIN
						 dbo.Offices ON dbo.Offices.OfficeID = dbo.Employees.OfficeID INNER JOIN 
                         dbo.Companies ON dbo.Companies.CompanyID = dbo.Offices.CompanyID INNER JOIN 
                         dbo.SystemConfig ON  dbo.SystemConfig.CompanyID = dbo.Companies.CompanyID
WHERE        (dbo.LoadStops.LoadType = 1) AND (dbo.LoadStops.StopNo + 1 = 1) AND dbo.LoadStops.NewCarrierID3 IS NOT NULL

ORDER BY dbo.Loads.LoadNumber
GO


GO

/****** Object:  StoredProcedure [dbo].[USP_GetLoadsForCommissionReport]    Script Date: 27-06-2022 10:08:26 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER             PROCEDURE [dbo].[USP_GetLoadsForCommissionReport] 
	-- Add the parameters for the stored procedure here
	
	@datetype varchar(20),
	@orderDateFrom varchar(10),
	@orderDateTo varchar(10),
	@billDateFrom varchar(10),
	@billDateTo varchar(10),
	@groupsBy varchar(20),
	@groupBy varchar(20),
	@salesAgentFrom VARCHAR(200),
	@salesAgentTo VARCHAR(200),
	@dispatcherFrom VARCHAR(200),
	@dispatcherTo VARCHAR(200),
	@statusTo VARCHAR(200),
	@statusFrom VARCHAR(200),
	@deductionPercentage VARCHAR(200),
	@equipmentFrom VARCHAR(200),
	@equipmentTo VARCHAR(200),
	@officeFrom VARCHAR(200),
	@officeTo VARCHAR(200),
	@carrierFrom VARCHAR(200),
	@carrierTo VARCHAR(200),
	@customerFrom VARCHAR(200),
	@customerTo VARCHAR(200),
	@freightBroker VARCHAR(200),
	@createDateFrom varchar(10),
	@createDateTo varchar(10),
	@companyid VARCHAR(200),
	@deliveryDateFrom varchar(10),
	@deliveryDateTo varchar(10),
	@sortBy varchar(20)
AS
BEGIN
	IF @groupsBy = 'none'
		IF @freightBroker ='Driver'
			IF @datetype = 'Shipdate'
				SELECT *,'none' as GrpBy,'none' as SCommissionPercent,0 as SCommissionAmt FROM vwSalesRepCommission
				WHERE orderdate BETWEEN @orderDateFrom AND @orderDateTo
				AND userDefinedFieldTrucking BETWEEN @salesAgentFrom AND @salesAgentTo
				AND ((Dispatcher BETWEEN @dispatcherFrom AND @dispatcherTo)  
					OR (Dispatcher1 BETWEEN @dispatcherFrom AND @dispatcherTo)
					OR (Dispatcher2 BETWEEN @dispatcherFrom AND @dispatcherTo)
					OR (Dispatcher3 BETWEEN @dispatcherFrom AND @dispatcherTo))
				AND statusText >= @statusTo
				AND statusText <= @statusFrom
				AND EquiptName >= @equipmentFrom
				AND EquiptName <= @equipmentTo
				AND ((OfficeCode >= @officeFrom AND OfficeCode <= @officeTo)
					OR (OfficeCode1 >= @officeFrom AND OfficeCode1 <= @officeTo)
					OR (OfficeCode2 >= @officeFrom AND OfficeCode2 <= @officeTo)
					OR (OfficeCode3 >= @officeFrom AND OfficeCode3 <= @officeTo))
				AND Carrier >= @carrierFrom
				AND Carrier <= @carrierTo
				AND trim(CustName) BETWEEN @customerFrom AND @customerTo
				AND CompanyID = @companyid
				ORDER BY	
					CASE WHEN @sortBy = 'LoadNumber' THEN LoadNumber END ASC,
					CASE WHEN @sortBy = 'date' THEN orderdate END  ASC,sortfield
					
			ELSE IF @datetype = 'Deliverydate'
				SELECT *,'none' as GrpBy,'none' as SCommissionPercent,0 as SCommissionAmt FROM vwSalesRepCommission
				WHERE Deliverydate BETWEEN @deliveryDateFrom AND @deliveryDateTo
				AND userDefinedFieldTrucking BETWEEN @salesAgentFrom AND @salesAgentTo
				AND ((Dispatcher BETWEEN @dispatcherFrom AND @dispatcherTo)  
					OR (Dispatcher1 BETWEEN @dispatcherFrom AND @dispatcherTo)
					OR (Dispatcher2 BETWEEN @dispatcherFrom AND @dispatcherTo)
					OR (Dispatcher3 BETWEEN @dispatcherFrom AND @dispatcherTo))
				AND statusText >= @statusTo
				AND statusText <= @statusFrom
				AND EquiptName >= @equipmentFrom
				AND EquiptName <= @equipmentTo
				AND ((OfficeCode >= @officeFrom AND OfficeCode <= @officeTo)
					OR (OfficeCode1 >= @officeFrom AND OfficeCode1 <= @officeTo)
					OR (OfficeCode2 >= @officeFrom AND OfficeCode2 <= @officeTo)
					OR (OfficeCode3 >= @officeFrom AND OfficeCode3 <= @officeTo))
				AND Carrier >= @carrierFrom
				AND Carrier <= @carrierTo
				AND trim(CustName) BETWEEN @customerFrom AND @customerTo
				AND CompanyID = @companyid
				ORDER BY	
					CASE WHEN @sortBy = 'LoadNumber' THEN LoadNumber END ASC,
					CASE WHEN @sortBy = 'date' THEN DeliveryDate END  ASC
			ELSE IF @datetype = 'Createdate'
				SELECT *,'none' as GrpBy,'none' as SCommissionPercent,0 as SCommissionAmt FROM vwSalesRepCommission
				WHERE CAST(CreatedDateTime as date) BETWEEN @createDateFrom AND @createDateTo
				AND userDefinedFieldTrucking BETWEEN @salesAgentFrom AND @salesAgentTo
				AND ((Dispatcher BETWEEN @dispatcherFrom AND @dispatcherTo)  
					OR (Dispatcher1 BETWEEN @dispatcherFrom AND @dispatcherTo)
					OR (Dispatcher2 BETWEEN @dispatcherFrom AND @dispatcherTo)
					OR (Dispatcher3 BETWEEN @dispatcherFrom AND @dispatcherTo))
				AND statusText >= @statusTo
				AND statusText <= @statusFrom
				AND EquiptName >= @equipmentFrom
				AND EquiptName <= @equipmentTo
				AND ((OfficeCode >= @officeFrom AND OfficeCode <= @officeTo)
					OR (OfficeCode1 >= @officeFrom AND OfficeCode1 <= @officeTo)
					OR (OfficeCode2 >= @officeFrom AND OfficeCode2 <= @officeTo)
					OR (OfficeCode3 >= @officeFrom AND OfficeCode3 <= @officeTo))
				AND Carrier >= @carrierFrom
				AND Carrier <= @carrierTo
				AND trim(CustName) BETWEEN @customerFrom AND @customerTo
				AND CompanyID = @companyid
				ORDER BY	
					CASE WHEN @sortBy = 'LoadNumber' THEN LoadNumber END ASC,
					CASE WHEN @sortBy = 'date' THEN CreatedDateTime END  ASC
			ELSE 
				SELECT *,'none' as GrpBy,'none' as SCommissionPercent,0 as SCommissionAmt FROM vwSalesRepCommission
				WHERE billdate BETWEEN @billDateFrom AND @billDateTo
				AND userDefinedFieldTrucking BETWEEN @salesAgentFrom AND @salesAgentTo
				AND ((Dispatcher BETWEEN @dispatcherFrom AND @dispatcherTo)  
					OR (Dispatcher1 BETWEEN @dispatcherFrom AND @dispatcherTo)
					OR (Dispatcher2 BETWEEN @dispatcherFrom AND @dispatcherTo)
					OR (Dispatcher3 BETWEEN @dispatcherFrom AND @dispatcherTo))
				AND statusText >= @statusTo
				AND statusText <= @statusFrom
				AND EquiptName >= @equipmentFrom
				AND EquiptName <= @equipmentTo
				AND ((OfficeCode >= @officeFrom AND OfficeCode <= @officeTo)
					OR (OfficeCode1 >= @officeFrom AND OfficeCode1 <= @officeTo)
					OR (OfficeCode2 >= @officeFrom AND OfficeCode2 <= @officeTo)
					OR (OfficeCode3 >= @officeFrom AND OfficeCode3 <= @officeTo))
				AND Carrier >= @carrierFrom
				AND Carrier <= @carrierTo
				AND trim(CustName) BETWEEN @customerFrom AND @customerTo
				AND CompanyID = @companyid
				ORDER BY	
					CASE WHEN @sortBy = 'LoadNumber' THEN LoadNumber END ASC,
					CASE WHEN @sortBy = 'date' THEN billdate END  ASC
		ELSE
			IF @datetype = 'Shipdate'
				SELECT *,'none' as GrpBy,'none' as SCommissionPercent,0 as SCommissionAmt FROM vwSalesRepCommission
				WHERE orderdate BETWEEN @orderDateFrom AND @orderDateTo
				AND SalesAgent BETWEEN @salesAgentFrom AND @salesAgentTo
				AND ((Dispatcher BETWEEN @dispatcherFrom AND @dispatcherTo)  
					OR (Dispatcher1 BETWEEN @dispatcherFrom AND @dispatcherTo)
					OR (Dispatcher2 BETWEEN @dispatcherFrom AND @dispatcherTo)
					OR (Dispatcher3 BETWEEN @dispatcherFrom AND @dispatcherTo))
				AND statusText >= @statusTo
				AND statusText <= @statusFrom
				AND EquiptName >= @equipmentFrom
				AND EquiptName <= @equipmentTo
				AND ((OfficeCode >= @officeFrom AND OfficeCode <= @officeTo)
					OR (OfficeCode1 >= @officeFrom AND OfficeCode1 <= @officeTo)
					OR (OfficeCode2 >= @officeFrom AND OfficeCode2 <= @officeTo)
					OR (OfficeCode3 >= @officeFrom AND OfficeCode3 <= @officeTo))
				AND Carrier >= @carrierFrom
				AND Carrier <= @carrierTo
				AND trim(CustName) BETWEEN @customerFrom AND @customerTo
				AND CompanyID = @companyid
				ORDER BY	
					CASE WHEN @sortBy = 'LoadNumber' THEN LoadNumber END ASC,
					CASE WHEN @sortBy = 'date' THEN orderdate END  ASC
			ELSE IF @datetype = 'Deliverydate'
				SELECT *,'none' as GrpBy,'none' as SCommissionPercent,0 as SCommissionAmt FROM vwSalesRepCommission
				WHERE Deliverydate BETWEEN @DeliverydateFrom AND @DeliverydateTo
				AND SalesAgent BETWEEN @salesAgentFrom AND @salesAgentTo
				AND ((Dispatcher BETWEEN @dispatcherFrom AND @dispatcherTo)  
					OR (Dispatcher1 BETWEEN @dispatcherFrom AND @dispatcherTo)
					OR (Dispatcher2 BETWEEN @dispatcherFrom AND @dispatcherTo)
					OR (Dispatcher3 BETWEEN @dispatcherFrom AND @dispatcherTo))
				AND statusText >= @statusTo
				AND statusText <= @statusFrom
				AND EquiptName >= @equipmentFrom
				AND EquiptName <= @equipmentTo
				AND ((OfficeCode >= @officeFrom AND OfficeCode <= @officeTo)
					OR (OfficeCode1 >= @officeFrom AND OfficeCode1 <= @officeTo)
					OR (OfficeCode2 >= @officeFrom AND OfficeCode2 <= @officeTo)
					OR (OfficeCode3 >= @officeFrom AND OfficeCode3 <= @officeTo))
				AND Carrier >= @carrierFrom
				AND Carrier <= @carrierTo
				AND trim(CustName) BETWEEN @customerFrom AND @customerTo
				AND CompanyID = @companyid
				ORDER BY	
					CASE WHEN @sortBy = 'LoadNumber' THEN LoadNumber END ASC,
					CASE WHEN @sortBy = 'date' THEN DeliveryDate END  ASC
			ELSE IF @datetype = 'Createdate'
				SELECT *,'none' as GrpBy,'none' as SCommissionPercent,0 as SCommissionAmt FROM vwSalesRepCommission
				WHERE CAST(CreatedDateTime as date) BETWEEN @createDateFrom AND @createDateTo
				AND SalesAgent BETWEEN @salesAgentFrom AND @salesAgentTo
				AND ((Dispatcher BETWEEN @dispatcherFrom AND @dispatcherTo)  
					OR (Dispatcher1 BETWEEN @dispatcherFrom AND @dispatcherTo)
					OR (Dispatcher2 BETWEEN @dispatcherFrom AND @dispatcherTo)
					OR (Dispatcher3 BETWEEN @dispatcherFrom AND @dispatcherTo))
				AND statusText >= @statusTo
				AND statusText <= @statusFrom
				AND EquiptName >= @equipmentFrom
				AND EquiptName <= @equipmentTo
				AND ((OfficeCode >= @officeFrom AND OfficeCode <= @officeTo)
					OR (OfficeCode1 >= @officeFrom AND OfficeCode1 <= @officeTo)
					OR (OfficeCode2 >= @officeFrom AND OfficeCode2 <= @officeTo)
					OR (OfficeCode3 >= @officeFrom AND OfficeCode3 <= @officeTo))
				AND Carrier >= @carrierFrom
				AND Carrier <= @carrierTo
				AND trim(CustName) BETWEEN @customerFrom AND @customerTo
				AND CompanyID = @companyid
				ORDER BY	
					CASE WHEN @sortBy = 'LoadNumber' THEN LoadNumber END ASC,
					CASE WHEN @sortBy = 'date' THEN CreatedDateTime END  ASC
			ELSE	
				SELECT *,'none' as GrpBy,'none' as SCommissionPercent,0 as SCommissionAmt FROM vwSalesRepCommission
				WHERE billdate BETWEEN @billDateFrom AND @billDateTo
				AND SalesAgent BETWEEN @salesAgentFrom AND @salesAgentTo
				AND ((Dispatcher BETWEEN @dispatcherFrom AND @dispatcherTo)  
					OR (Dispatcher1 BETWEEN @dispatcherFrom AND @dispatcherTo)
					OR (Dispatcher2 BETWEEN @dispatcherFrom AND @dispatcherTo)
					OR (Dispatcher3 BETWEEN @dispatcherFrom AND @dispatcherTo))
				AND statusText >= @statusTo
				AND statusText <= @statusFrom
				AND EquiptName >= @equipmentFrom
				AND EquiptName <= @equipmentTo
				AND ((OfficeCode >= @officeFrom AND OfficeCode <= @officeTo)
					OR (OfficeCode1 >= @officeFrom AND OfficeCode1 <= @officeTo)
					OR (OfficeCode2 >= @officeFrom AND OfficeCode2 <= @officeTo)
					OR (OfficeCode3 >= @officeFrom AND OfficeCode3 <= @officeTo))
				AND Carrier >= @carrierFrom
				AND Carrier <= @carrierTo
				AND trim(CustName) BETWEEN @customerFrom AND @customerTo
				AND CompanyID = @companyid
				ORDER BY	
					CASE WHEN @sortBy = 'LoadNumber' THEN LoadNumber END ASC,
					CASE WHEN @sortBy = 'date' THEN billdate END  ASC		
	Else	
		IF @freightBroker ='Driver'
			IF @datetype = 'Shipdate'
				SELECT *, 
				CASE 
					WHEN @groupsBy = 'userDefinedFieldTrucking' THEN userDefinedFieldTrucking 
				ELSE 
					CASE 
						WHEN @groupsBy = 'DISPATCHER' THEN DISPATCHER
					ELSE
						CASE 
							WHEN @groupsBy = 'CUSTOMERNAME' THEN CustName
						ElSE	
							CASE 
								WHEN @groupsBy = 'Carrier' THEN Carrier
							ELSE
								Driver
							END
						END
					END		
				END 
				AS GrpBy, 
				CASE WHEN @groupsBy = 'DISPATCHER' THEN DispatchCommissionPercent ELSE CommissionPercent END  AS SCommissionPercent,
				CASE WHEN @groupsBy = 'DISPATCHER' THEN DispatchCommissionAmt ELSE CommissionAmt END  AS SCommissionAmt
				FROM vwSalesRepCommission
				WHERE orderdate BETWEEN @orderDateFrom AND @orderDateTo
				AND userDefinedFieldTrucking BETWEEN @salesAgentFrom AND @salesAgentTo
				AND ((Dispatcher BETWEEN @dispatcherFrom AND @dispatcherTo)  
					OR (Dispatcher1 BETWEEN @dispatcherFrom AND @dispatcherTo)
					OR (Dispatcher2 BETWEEN @dispatcherFrom AND @dispatcherTo)
					OR (Dispatcher3 BETWEEN @dispatcherFrom AND @dispatcherTo))
				AND statusText >= @statusTo
				AND statusText <= @statusFrom
				AND EquiptName >= @equipmentFrom
				AND EquiptName <= @equipmentTo
				AND ((OfficeCode >= @officeFrom AND OfficeCode <= @officeTo)
					OR (OfficeCode1 >= @officeFrom AND OfficeCode1 <= @officeTo)
					OR (OfficeCode2 >= @officeFrom AND OfficeCode2 <= @officeTo)
					OR (OfficeCode3 >= @officeFrom AND OfficeCode3 <= @officeTo))
				AND Carrier >= @carrierFrom
				AND Carrier <= @carrierTo
				AND trim(CustName) BETWEEN @customerFrom AND @customerTo
				AND CompanyID = @companyid
				ORDER BY
				CASE WHEN @groupBy = 'userDefinedFieldTrucking' 
					THEN userDefinedFieldTrucking END ASC, 
				CASE WHEN @groupBy = 'dispatcher'
					THEN Dispatcher END ASC,
				CASE WHEN @groupBy = 'Carrier'
					THEN Carrier END ASC,
				CASE WHEN @groupBy = 'Driver'
					THEN Driver END ASC,	
				CASE WHEN @groupBy = 'CustName'
					THEN CustName END ASC,			
				CASE WHEN @sortBy = 'LoadNumber'
				     THEN LoadNumber END ASC,
				CASE WHEN @sortBy = 'Date'
				     THEN orderdate END ASC
			ELSE IF @datetype = 'Deliverydate'
				SELECT *, 
				CASE 
					WHEN @groupsBy = 'userDefinedFieldTrucking' THEN userDefinedFieldTrucking 
				ELSE 
					CASE 
						WHEN @groupsBy = 'DISPATCHER' THEN DISPATCHER
					ELSE
						CASE 
							WHEN @groupsBy = 'CUSTOMERNAME' THEN CustName
						ElSE	
							CASE 
								WHEN @groupsBy = 'Carrier' THEN Carrier
							ELSE
								Driver
							END
						END
					END		
				END 
				AS GrpBy, 
				CASE WHEN @groupsBy = 'DISPATCHER' THEN DispatchCommissionPercent ELSE CommissionPercent END  AS SCommissionPercent,
				CASE WHEN @groupsBy = 'DISPATCHER' THEN DispatchCommissionAmt ELSE CommissionAmt END  AS SCommissionAmt
				FROM vwSalesRepCommission
				WHERE Deliverydate BETWEEN @DeliverydateFrom AND @DeliverydateTo
				AND userDefinedFieldTrucking BETWEEN @salesAgentFrom AND @salesAgentTo
				AND ((Dispatcher BETWEEN @dispatcherFrom AND @dispatcherTo)  
					OR (Dispatcher1 BETWEEN @dispatcherFrom AND @dispatcherTo)
					OR (Dispatcher2 BETWEEN @dispatcherFrom AND @dispatcherTo)
					OR (Dispatcher3 BETWEEN @dispatcherFrom AND @dispatcherTo))
				AND statusText >= @statusTo
				AND statusText <= @statusFrom
				AND EquiptName >= @equipmentFrom
				AND EquiptName <= @equipmentTo
				AND ((OfficeCode >= @officeFrom AND OfficeCode <= @officeTo)
					OR (OfficeCode1 >= @officeFrom AND OfficeCode1 <= @officeTo)
					OR (OfficeCode2 >= @officeFrom AND OfficeCode2 <= @officeTo)
					OR (OfficeCode3 >= @officeFrom AND OfficeCode3 <= @officeTo))
				AND Carrier >= @carrierFrom
				AND Carrier <= @carrierTo
				AND trim(CustName) BETWEEN @customerFrom AND @customerTo
				AND CompanyID = @companyid
				ORDER BY
				CASE WHEN @groupBy = 'userDefinedFieldTrucking' 
					THEN userDefinedFieldTrucking END ASC, 
				CASE WHEN @groupBy = 'dispatcher'
					THEN Dispatcher END ASC,
				CASE WHEN @groupBy = 'Carrier'
					THEN Carrier END ASC,
				CASE WHEN @groupBy = 'Driver'
					THEN Driver END ASC,	
				CASE WHEN @groupBy = 'CustName'
					THEN CustName END ASC,			
				CASE WHEN @sortBy = 'LoadNumber'
				     THEN LoadNumber END ASC,
				CASE WHEN @sortBy = 'Date'
				     THEN Deliverydate END ASC
			ELSE IF @datetype = 'Createdate'
				SELECT *, 
				CASE 
					WHEN @groupsBy = 'userDefinedFieldTrucking' THEN userDefinedFieldTrucking 
				ELSE 
					CASE 
						WHEN @groupsBy = 'DISPATCHER' THEN DISPATCHER
					ELSE
						CASE 
							WHEN @groupsBy = 'CUSTOMERNAME' THEN CustName
						ElSE	
							CASE 
								WHEN @groupsBy = 'Carrier' THEN Carrier
							ELSE
								Driver
							END
						END
					END		
				END 
				AS GrpBy, 
				CASE WHEN @groupsBy = 'DISPATCHER' THEN DispatchCommissionPercent ELSE CommissionPercent END  AS SCommissionPercent,
				CASE WHEN @groupsBy = 'DISPATCHER' THEN DispatchCommissionAmt ELSE CommissionAmt END  AS SCommissionAmt
				FROM vwSalesRepCommission
				WHERE CAST(CreatedDateTime as date) BETWEEN @createDateFrom AND @createDateTo
				AND userDefinedFieldTrucking BETWEEN @salesAgentFrom AND @salesAgentTo
				AND ((Dispatcher BETWEEN @dispatcherFrom AND @dispatcherTo)  
					OR (Dispatcher1 BETWEEN @dispatcherFrom AND @dispatcherTo)
					OR (Dispatcher2 BETWEEN @dispatcherFrom AND @dispatcherTo)
					OR (Dispatcher3 BETWEEN @dispatcherFrom AND @dispatcherTo))
				AND statusText >= @statusTo
				AND statusText <= @statusFrom
				AND EquiptName >= @equipmentFrom
				AND EquiptName <= @equipmentTo
				AND ((OfficeCode >= @officeFrom AND OfficeCode <= @officeTo)
					OR (OfficeCode1 >= @officeFrom AND OfficeCode1 <= @officeTo)
					OR (OfficeCode2 >= @officeFrom AND OfficeCode2 <= @officeTo)
					OR (OfficeCode3 >= @officeFrom AND OfficeCode3 <= @officeTo))
				AND Carrier >= @carrierFrom
				AND Carrier <= @carrierTo
				AND trim(CustName) BETWEEN @customerFrom AND @customerTo
				AND CompanyID = @companyid
				ORDER BY
				CASE WHEN @groupBy = 'userDefinedFieldTrucking' 
					THEN userDefinedFieldTrucking END ASC, 
				CASE WHEN @groupBy = 'dispatcher'
					THEN Dispatcher END ASC,
				CASE WHEN @groupBy = 'Carrier'
					THEN Carrier END ASC,
				CASE WHEN @groupBy = 'Driver'
					THEN Driver END ASC,	
				CASE WHEN @groupBy = 'CustName'
					THEN CustName END ASC,			
				CASE WHEN @sortBy = 'LoadNumber'
				     THEN LoadNumber END ASC,
				CASE WHEN @sortBy = 'Date'
				     THEN CreatedDateTime END ASC
			ELSE
				SELECT *, 
				CASE 
					WHEN @groupsBy = 'userDefinedFieldTrucking' THEN userDefinedFieldTrucking 
				ELSE 
					CASE 
						WHEN @groupsBy = 'DISPATCHER' THEN DISPATCHER
					ELSE
						CASE 
							WHEN @groupsBy = 'CUSTOMERNAME' THEN CustName
						ElSE	
							CASE 
								WHEN @groupsBy = 'Carrier' THEN Carrier
							ELSE
								Driver
							END
						END
					END		
				END 
				AS GrpBy, 
				CASE WHEN @groupsBy = 'DISPATCHER' THEN DispatchCommissionPercent ELSE CommissionPercent END  AS SCommissionPercent,
				CASE WHEN @groupsBy = 'DISPATCHER' THEN DispatchCommissionAmt ELSE CommissionAmt END  AS SCommissionAmt
				FROM vwSalesRepCommission
				WHERE billdate BETWEEN @billDateFrom AND @billDateTo
				AND userDefinedFieldTrucking BETWEEN @salesAgentFrom AND @salesAgentTo
				AND ((Dispatcher BETWEEN @dispatcherFrom AND @dispatcherTo)  
					OR (Dispatcher1 BETWEEN @dispatcherFrom AND @dispatcherTo)
					OR (Dispatcher2 BETWEEN @dispatcherFrom AND @dispatcherTo)
					OR (Dispatcher3 BETWEEN @dispatcherFrom AND @dispatcherTo))
				AND statusText >= @statusTo
				AND statusText <= @statusFrom
				AND EquiptName >= @equipmentFrom
				AND EquiptName <= @equipmentTo
				AND ((OfficeCode >= @officeFrom AND OfficeCode <= @officeTo)
					OR (OfficeCode1 >= @officeFrom AND OfficeCode1 <= @officeTo)
					OR (OfficeCode2 >= @officeFrom AND OfficeCode2 <= @officeTo)
					OR (OfficeCode3 >= @officeFrom AND OfficeCode3 <= @officeTo))
				AND Carrier >= @carrierFrom
				AND Carrier <= @carrierTo
				AND trim(CustName) BETWEEN @customerFrom AND @customerTo
				AND CompanyID = @companyid
				ORDER BY
				CASE WHEN @groupBy = 'userDefinedFieldTrucking' 
					THEN userDefinedFieldTrucking END ASC, 
				CASE WHEN @groupBy = 'dispatcher'
					THEN Dispatcher END ASC,
				CASE WHEN @groupBy = 'Carrier'
					THEN Carrier END ASC,
				CASE WHEN @groupBy = 'Driver'
					THEN Driver END ASC,	
				CASE WHEN @groupBy = 'CustName'
					THEN CustName END ASC,			
				CASE WHEN @sortBy = 'LoadNumber'
				     THEN LoadNumber END ASC,
				CASE WHEN @sortBy = 'Date'
				     THEN billdate END ASC
		ELSE
			IF @datetype = 'Shipdate'
					SELECT *, 
				CASE 
					WHEN @groupsBy = 'SALESAGENT' THEN SALESAGENT 
				ELSE 
					CASE 
						WHEN @groupsBy = 'DISPATCHER' THEN DISPATCHER
					ELSE
						CASE 
							WHEN @groupsBy = 'CUSTOMERNAME' THEN CustName
						ElSE	
							CASE 
								WHEN @groupsBy = 'Carrier' THEN Carrier
							ELSE
								Driver
							END
						END
					END		
				END 
				AS GrpBy, 
				CASE WHEN @groupsBy = 'DISPATCHER' THEN DispatchCommissionPercent ELSE CommissionPercent END  AS SCommissionPercent,
				CASE WHEN @groupsBy = 'DISPATCHER' THEN DispatchCommissionAmt ELSE CommissionAmt END  AS SCommissionAmt
				FROM vwSalesRepCommission
				WHERE orderdate BETWEEN @orderDateFrom AND @orderDateTo
				AND SalesAgent BETWEEN @salesAgentFrom AND @salesAgentTo
				AND ((Dispatcher BETWEEN @dispatcherFrom AND @dispatcherTo)  
					OR (Dispatcher1 BETWEEN @dispatcherFrom AND @dispatcherTo)
					OR (Dispatcher2 BETWEEN @dispatcherFrom AND @dispatcherTo)
					OR (Dispatcher3 BETWEEN @dispatcherFrom AND @dispatcherTo))
				AND statusText >= @statusTo
				AND statusText <= @statusFrom
				AND EquiptName >= @equipmentFrom
				AND EquiptName <= @equipmentTo
				AND ((OfficeCode >= @officeFrom AND OfficeCode <= @officeTo)
					OR (OfficeCode1 >= @officeFrom AND OfficeCode1 <= @officeTo)
					OR (OfficeCode2 >= @officeFrom AND OfficeCode2 <= @officeTo)
					OR (OfficeCode3 >= @officeFrom AND OfficeCode3 <= @officeTo))
				AND Carrier >= @carrierFrom
				AND Carrier <= @carrierTo
				AND trim(CustName) BETWEEN @customerFrom AND @customerTo
				AND CompanyID = @companyid
				ORDER BY
				CASE WHEN @groupBy = 'sales Agent' 
					THEN SalesAgent END ASC, 
				CASE WHEN @groupBy = 'dispatcher'
					THEN Dispatcher END ASC,
				CASE WHEN @groupBy = 'Carrier'
					THEN Carrier END ASC,
				CASE WHEN @groupBy = 'Driver'
					THEN Driver END ASC,	
				CASE WHEN @groupBy = 'CustName'
					THEN CustName END ASC,			
				CASE WHEN @sortBy = 'LoadNumber'
				     THEN LoadNumber END ASC,
				CASE WHEN @sortBy = 'Date'
				     THEN orderdate END ASC
			ELSE IF @datetype = 'Deliverydate'
					SELECT *, 
				CASE 
					WHEN @groupsBy = 'SALESAGENT' THEN SALESAGENT 
				ELSE 
					CASE 
						WHEN @groupsBy = 'DISPATCHER' THEN DISPATCHER
					ELSE
						CASE 
							WHEN @groupsBy = 'CUSTOMERNAME' THEN CustName
						ElSE	
							CASE 
								WHEN @groupsBy = 'Carrier' THEN Carrier
							ELSE
								Driver
							END
						END
					END		
				END 
				AS GrpBy, 
				CASE WHEN @groupsBy = 'DISPATCHER' THEN DispatchCommissionPercent ELSE CommissionPercent END  AS SCommissionPercent,
				CASE WHEN @groupsBy = 'DISPATCHER' THEN DispatchCommissionAmt ELSE CommissionAmt END  AS SCommissionAmt
				FROM vwSalesRepCommission
				WHERE Deliverydate BETWEEN @DeliverydateFrom AND @DeliverydateTo
				AND SalesAgent BETWEEN @salesAgentFrom AND @salesAgentTo
				AND ((Dispatcher BETWEEN @dispatcherFrom AND @dispatcherTo)  
					OR (Dispatcher1 BETWEEN @dispatcherFrom AND @dispatcherTo)
					OR (Dispatcher2 BETWEEN @dispatcherFrom AND @dispatcherTo)
					OR (Dispatcher3 BETWEEN @dispatcherFrom AND @dispatcherTo))
				AND statusText >= @statusTo
				AND statusText <= @statusFrom
				AND EquiptName >= @equipmentFrom
				AND EquiptName <= @equipmentTo
				AND ((OfficeCode >= @officeFrom AND OfficeCode <= @officeTo)
					OR (OfficeCode1 >= @officeFrom AND OfficeCode1 <= @officeTo)
					OR (OfficeCode2 >= @officeFrom AND OfficeCode2 <= @officeTo)
					OR (OfficeCode3 >= @officeFrom AND OfficeCode3 <= @officeTo))
				AND Carrier >= @carrierFrom
				AND Carrier <= @carrierTo
				AND trim(CustName) BETWEEN @customerFrom AND @customerTo
				AND CompanyID = @companyid
				ORDER BY
				CASE WHEN @groupBy = 'sales Agent' 
					THEN SalesAgent END ASC, 
				CASE WHEN @groupBy = 'dispatcher'
					THEN Dispatcher END ASC,
				CASE WHEN @groupBy = 'Carrier'
					THEN Carrier END ASC,
				CASE WHEN @groupBy = 'Driver'
					THEN Driver END ASC,	
				CASE WHEN @groupBy = 'CustName'
					THEN CustName END ASC,			
				CASE WHEN @sortBy = 'LoadNumber'
				     THEN LoadNumber END ASC,
				CASE WHEN @sortBy = 'Date'
				     THEN Deliverydate END ASC
			ELSE IF @datetype = 'Createdate'
					SELECT *, 
				CASE 
					WHEN @groupsBy = 'SALESAGENT' THEN SALESAGENT 
				ELSE 
					CASE 
						WHEN @groupsBy = 'DISPATCHER' THEN DISPATCHER
					ELSE
						CASE 
							WHEN @groupsBy = 'CUSTOMERNAME' THEN CustName
						ElSE	
							CASE 
								WHEN @groupsBy = 'Carrier' THEN Carrier
							ELSE
								Driver
							END
						END
					END		
				END 
				AS GrpBy, 
				CASE WHEN @groupsBy = 'DISPATCHER' THEN DispatchCommissionPercent ELSE CommissionPercent END  AS SCommissionPercent,
				CASE WHEN @groupsBy = 'DISPATCHER' THEN DispatchCommissionAmt ELSE CommissionAmt END  AS SCommissionAmt
				FROM vwSalesRepCommission
				WHERE CAST(CreatedDateTime as date) BETWEEN @createDateFrom AND @createDateTo
				AND SalesAgent BETWEEN @salesAgentFrom AND @salesAgentTo
				AND ((Dispatcher BETWEEN @dispatcherFrom AND @dispatcherTo)  
					OR (Dispatcher1 BETWEEN @dispatcherFrom AND @dispatcherTo)
					OR (Dispatcher2 BETWEEN @dispatcherFrom AND @dispatcherTo)
					OR (Dispatcher3 BETWEEN @dispatcherFrom AND @dispatcherTo))
				AND statusText >= @statusTo
				AND statusText <= @statusFrom
				AND EquiptName >= @equipmentFrom
				AND EquiptName <= @equipmentTo
				AND ((OfficeCode >= @officeFrom AND OfficeCode <= @officeTo)
					OR (OfficeCode1 >= @officeFrom AND OfficeCode1 <= @officeTo)
					OR (OfficeCode2 >= @officeFrom AND OfficeCode2 <= @officeTo)
					OR (OfficeCode3 >= @officeFrom AND OfficeCode3 <= @officeTo))
				AND Carrier >= @carrierFrom
				AND Carrier <= @carrierTo
				AND trim(CustName) BETWEEN @customerFrom AND @customerTo
				AND CompanyID = @companyid
				ORDER BY
				CASE WHEN @groupBy = 'sales Agent' 
					THEN SalesAgent END ASC, 
				CASE WHEN @groupBy = 'dispatcher'
					THEN Dispatcher END ASC,
				CASE WHEN @groupBy = 'Carrier'
					THEN Carrier END ASC,
				CASE WHEN @groupBy = 'Driver'
					THEN Driver END ASC,	
				CASE WHEN @groupBy = 'CustName'
					THEN CustName END ASC,			
				CASE WHEN @sortBy = 'LoadNumber'
				     THEN LoadNumber END ASC,
				CASE WHEN @sortBy = 'Date'
				     THEN CreatedDateTime END ASC
			ELSE
				SELECT *, 
				CASE 
					WHEN @groupsBy = 'SALESAGENT' THEN SALESAGENT 
				ELSE 
					CASE 
						WHEN @groupsBy = 'DISPATCHER' THEN DISPATCHER
					ELSE
						CASE 
							WHEN @groupsBy = 'CUSTOMERNAME' THEN CustName
						ElSE	
							CASE 
								WHEN @groupsBy = 'Carrier' THEN Carrier
							ELSE
								Driver
							END
						END
					END		
				END 
				AS GrpBy, 
				CASE WHEN @groupsBy = 'DISPATCHER' THEN DispatchCommissionPercent ELSE CommissionPercent END  AS SCommissionPercent,
				CASE WHEN @groupsBy = 'DISPATCHER' THEN DispatchCommissionAmt ELSE CommissionAmt END  AS SCommissionAmt
				FROM vwSalesRepCommission
				WHERE billdate BETWEEN @billDateFrom AND @billDateTo
				AND SalesAgent BETWEEN @salesAgentFrom AND @salesAgentTo
				AND ((Dispatcher BETWEEN @dispatcherFrom AND @dispatcherTo)  
					OR (Dispatcher1 BETWEEN @dispatcherFrom AND @dispatcherTo)
					OR (Dispatcher2 BETWEEN @dispatcherFrom AND @dispatcherTo)
					OR (Dispatcher3 BETWEEN @dispatcherFrom AND @dispatcherTo))
				AND statusText >= @statusTo
				AND statusText <= @statusFrom
				AND EquiptName >= @equipmentFrom
				AND EquiptName <= @equipmentTo
				AND ((OfficeCode >= @officeFrom AND OfficeCode <= @officeTo)
					OR (OfficeCode1 >= @officeFrom AND OfficeCode1 <= @officeTo)
					OR (OfficeCode2 >= @officeFrom AND OfficeCode2 <= @officeTo)
					OR (OfficeCode3 >= @officeFrom AND OfficeCode3 <= @officeTo))
				AND Carrier >= @carrierFrom
				AND Carrier <= @carrierTo
				AND trim(CustName) BETWEEN @customerFrom AND @customerTo
				AND CompanyID = @companyid
				ORDER BY
				CASE WHEN @groupBy = 'sales Agent' 
					THEN SalesAgent END ASC, 
				CASE WHEN @groupBy = 'dispatcher'
					THEN Dispatcher END ASC,
				CASE WHEN @groupBy = 'Carrier'
					THEN Carrier END ASC,
				CASE WHEN @groupBy = 'Driver'
					THEN Driver END ASC,	
				CASE WHEN @groupBy = 'CustName'
					THEN CustName END ASC,			
				CASE WHEN @sortBy = 'LoadNumber'
				     THEN LoadNumber END ASC,
				CASE WHEN @sortBy = 'Date'
				     THEN billdate END ASC
END





GO


