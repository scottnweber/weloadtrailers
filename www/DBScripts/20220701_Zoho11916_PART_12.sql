IF NOT EXISTS (SELECT column_name FROM INFORMATION_SCHEMA.columns where table_name = 'Loads' and column_name = 'SalesRep2Name')
BEGIN
	ALTER TABLE Loads ADD SalesRep2Name varchar(150);
END
IF NOT EXISTS (SELECT column_name FROM INFORMATION_SCHEMA.columns where table_name = 'Loads' and column_name = 'SalesRep3Name')
BEGIN
	ALTER TABLE Loads ADD SalesRep3Name varchar(150);
END
GO
UPDATE L SET 
L.SalesRep2Name=S2.Name,L.SalesRep3Name=S3.Name FROM Loads L
LEFT JOIN Employees S2 ON L.SalesRep2 = S2.EmployeeID
LEFT JOIN Employees S3 ON L.SalesRep3 = S3.EmployeeID

GO

/****** Object:  View [dbo].[vwSalesRepCommission]    Script Date: 05-07-2022 11:33:37 ******/
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
						 ,dbo.Loads.HasLateStop, dbo.Offices.OfficeCode, dbo.Loads.Dispatcher2Name AS Dispatcher2, dbo.Loads.Dispatcher3Name AS Dispatcher3
						 ,dbo.Loads.SalesRep2Name AS SalesAgent2, dbo.Loads.SalesRep3Name AS SalesAgent3
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
						 ,dbo.Loads.HasLateStop, dbo.Offices.OfficeCode, dbo.Loads.Dispatcher2Name AS Dispatcher2, dbo.Loads.Dispatcher3Name AS Dispatcher3
						 ,dbo.Loads.SalesRep2Name AS SalesAgent2, dbo.Loads.SalesRep3Name AS SalesAgent3
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
						 ,dbo.Loads.HasLateStop, dbo.Offices.OfficeCode, dbo.Loads.Dispatcher2Name AS Dispatcher2, dbo.Loads.Dispatcher3Name AS Dispatcher3
						 ,dbo.Loads.SalesRep2Name AS SalesAgent2, dbo.Loads.SalesRep3Name AS SalesAgent3
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
						 dbo.Offices ON dbo.Offices.OfficeID = dbo.Employees.OfficeID INNER JOIN 
                         dbo.Companies ON dbo.Companies.CompanyID = dbo.Offices.CompanyID INNER JOIN 
                         dbo.SystemConfig ON  dbo.SystemConfig.CompanyID = dbo.Companies.CompanyID
WHERE        (dbo.LoadStops.LoadType = 1) AND (dbo.LoadStops.StopNo + 1 = 1) AND dbo.LoadStops.NewCarrierID3 IS NOT NULL

ORDER BY dbo.Loads.LoadNumber
GO



GO

/****** Object:  StoredProcedure [dbo].[USP_GetLoadsForCommissionReport]    Script Date: 04-07-2022 18:14:36 ******/
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
	@sortBy varchar(20),
	@SalesRepReport bit
AS
BEGIN
	IF @groupsBy = 'none'
		IF @freightBroker ='Driver'
			IF @datetype = 'Shipdate'
				SELECT *,'none' as GrpBy,'none' as SCommissionPercent,0 as SCommissionAmt FROM vwSalesRepCommission
				WHERE orderdate BETWEEN @orderDateFrom AND @orderDateTo
				AND userDefinedFieldTrucking BETWEEN @salesAgentFrom AND @salesAgentTo
				AND ((Dispatcher BETWEEN @dispatcherFrom AND @dispatcherTo)  
					OR (Dispatcher2 BETWEEN @dispatcherFrom AND @dispatcherTo)
					OR (Dispatcher3 BETWEEN @dispatcherFrom AND @dispatcherTo))
				AND statusText >= @statusTo
				AND statusText <= @statusFrom
				AND EquiptName >= @equipmentFrom
				AND EquiptName <= @equipmentTo
				AND OfficeCode >= @officeFrom AND OfficeCode <= @officeTo
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
					OR (Dispatcher2 BETWEEN @dispatcherFrom AND @dispatcherTo)
					OR (Dispatcher3 BETWEEN @dispatcherFrom AND @dispatcherTo))
				AND statusText >= @statusTo
				AND statusText <= @statusFrom
				AND EquiptName >= @equipmentFrom
				AND EquiptName <= @equipmentTo
				AND OfficeCode >= @officeFrom AND OfficeCode <= @officeTo
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
					OR (Dispatcher2 BETWEEN @dispatcherFrom AND @dispatcherTo)
					OR (Dispatcher3 BETWEEN @dispatcherFrom AND @dispatcherTo))
				AND statusText >= @statusTo
				AND statusText <= @statusFrom
				AND EquiptName >= @equipmentFrom
				AND EquiptName <= @equipmentTo
				AND OfficeCode >= @officeFrom AND OfficeCode <= @officeTo
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
					OR (Dispatcher2 BETWEEN @dispatcherFrom AND @dispatcherTo)
					OR (Dispatcher3 BETWEEN @dispatcherFrom AND @dispatcherTo))

				AND statusText >= @statusTo
				AND statusText <= @statusFrom
				AND EquiptName >= @equipmentFrom
				AND EquiptName <= @equipmentTo
				AND OfficeCode >= @officeFrom AND OfficeCode <= @officeTo
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

				AND (
					(@SalesRepReport = 1 
						AND (SalesAgent = @salesAgentFrom OR SalesAgent2 = @salesAgentFrom OR SalesAgent2 = @salesAgentFrom 
							OR Dispatcher = @dispatcherFrom OR Dispatcher2 = @dispatcherFrom OR Dispatcher3 = @dispatcherFrom)
					) 
					OR 
					(@SalesRepReport = 0 
						AND SalesAgent BETWEEN @salesAgentFrom AND @salesAgentTo
						AND ((Dispatcher BETWEEN @dispatcherFrom AND @dispatcherTo)  
							OR (Dispatcher2 BETWEEN @dispatcherFrom AND @dispatcherTo)
							OR (Dispatcher3 BETWEEN @dispatcherFrom AND @dispatcherTo))
					)
				)

				AND statusText >= @statusTo
				AND statusText <= @statusFrom
				AND EquiptName >= @equipmentFrom
				AND EquiptName <= @equipmentTo
				AND OfficeCode >= @officeFrom AND OfficeCode <= @officeTo
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
				AND (
					(@SalesRepReport = 1 
						AND (SalesAgent = @salesAgentFrom OR SalesAgent2 = @salesAgentFrom OR SalesAgent2 = @salesAgentFrom 
							OR Dispatcher = @dispatcherFrom OR Dispatcher2 = @dispatcherFrom OR Dispatcher3 = @dispatcherFrom)
					) 
					OR 
					(@SalesRepReport = 0 
						AND SalesAgent BETWEEN @salesAgentFrom AND @salesAgentTo
						AND ((Dispatcher BETWEEN @dispatcherFrom AND @dispatcherTo)  
							OR (Dispatcher2 BETWEEN @dispatcherFrom AND @dispatcherTo)
							OR (Dispatcher3 BETWEEN @dispatcherFrom AND @dispatcherTo))
					)
				)
				AND statusText >= @statusTo
				AND statusText <= @statusFrom
				AND EquiptName >= @equipmentFrom
				AND EquiptName <= @equipmentTo
				AND OfficeCode >= @officeFrom AND OfficeCode <= @officeTo
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
				AND (
					(@SalesRepReport = 1 
						AND (SalesAgent = @salesAgentFrom OR SalesAgent2 = @salesAgentFrom OR SalesAgent2 = @salesAgentFrom 
							OR Dispatcher = @dispatcherFrom OR Dispatcher2 = @dispatcherFrom OR Dispatcher3 = @dispatcherFrom)
					) 
					OR 
					(@SalesRepReport = 0 
						AND SalesAgent BETWEEN @salesAgentFrom AND @salesAgentTo
						AND ((Dispatcher BETWEEN @dispatcherFrom AND @dispatcherTo)  
							OR (Dispatcher2 BETWEEN @dispatcherFrom AND @dispatcherTo)
							OR (Dispatcher3 BETWEEN @dispatcherFrom AND @dispatcherTo))
					)
				)
				AND statusText >= @statusTo
				AND statusText <= @statusFrom
				AND EquiptName >= @equipmentFrom
				AND EquiptName <= @equipmentTo
				AND OfficeCode >= @officeFrom AND OfficeCode <= @officeTo
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
				AND (
					(@SalesRepReport = 1 
						AND (SalesAgent = @salesAgentFrom OR SalesAgent2 = @salesAgentFrom OR SalesAgent2 = @salesAgentFrom 
							OR Dispatcher = @dispatcherFrom OR Dispatcher2 = @dispatcherFrom OR Dispatcher3 = @dispatcherFrom)
					) 
					OR 
					(@SalesRepReport = 0 
						AND SalesAgent BETWEEN @salesAgentFrom AND @salesAgentTo
						AND ((Dispatcher BETWEEN @dispatcherFrom AND @dispatcherTo)  
							OR (Dispatcher2 BETWEEN @dispatcherFrom AND @dispatcherTo)
							OR (Dispatcher3 BETWEEN @dispatcherFrom AND @dispatcherTo))
					)
				)
				AND statusText >= @statusTo
				AND statusText <= @statusFrom
				AND EquiptName >= @equipmentFrom
				AND EquiptName <= @equipmentTo
				AND OfficeCode >= @officeFrom AND OfficeCode <= @officeTo
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
					OR (Dispatcher2 BETWEEN @dispatcherFrom AND @dispatcherTo)
					OR (Dispatcher3 BETWEEN @dispatcherFrom AND @dispatcherTo))
				AND statusText >= @statusTo
				AND statusText <= @statusFrom
				AND EquiptName >= @equipmentFrom
				AND EquiptName <= @equipmentTo
				AND OfficeCode >= @officeFrom AND OfficeCode <= @officeTo
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
					OR (Dispatcher2 BETWEEN @dispatcherFrom AND @dispatcherTo)
					OR (Dispatcher3 BETWEEN @dispatcherFrom AND @dispatcherTo))
				AND statusText >= @statusTo
				AND statusText <= @statusFrom
				AND EquiptName >= @equipmentFrom
				AND EquiptName <= @equipmentTo
				AND OfficeCode >= @officeFrom AND OfficeCode <= @officeTo
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
					OR (Dispatcher2 BETWEEN @dispatcherFrom AND @dispatcherTo)
					OR (Dispatcher3 BETWEEN @dispatcherFrom AND @dispatcherTo))
				AND statusText >= @statusTo
				AND statusText <= @statusFrom
				AND EquiptName >= @equipmentFrom
				AND EquiptName <= @equipmentTo
				AND OfficeCode >= @officeFrom AND OfficeCode <= @officeTo
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
					OR (Dispatcher2 BETWEEN @dispatcherFrom AND @dispatcherTo)
					OR (Dispatcher3 BETWEEN @dispatcherFrom AND @dispatcherTo))
				AND statusText >= @statusTo
				AND statusText <= @statusFrom
				AND EquiptName >= @equipmentFrom
				AND EquiptName <= @equipmentTo
				AND OfficeCode >= @officeFrom AND OfficeCode <= @officeTo
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
				AND (
					(@SalesRepReport = 1 
						AND (SalesAgent = @salesAgentFrom OR SalesAgent2 = @salesAgentFrom OR SalesAgent2 = @salesAgentFrom 
							OR Dispatcher = @dispatcherFrom OR Dispatcher2 = @dispatcherFrom OR Dispatcher3 = @dispatcherFrom)
					) 
					OR 
					(@SalesRepReport = 0 
						AND SalesAgent BETWEEN @salesAgentFrom AND @salesAgentTo
						AND ((Dispatcher BETWEEN @dispatcherFrom AND @dispatcherTo)  
							OR (Dispatcher2 BETWEEN @dispatcherFrom AND @dispatcherTo)
							OR (Dispatcher3 BETWEEN @dispatcherFrom AND @dispatcherTo))
					)
				)
				AND statusText >= @statusTo
				AND statusText <= @statusFrom
				AND EquiptName >= @equipmentFrom
				AND EquiptName <= @equipmentTo
				AND OfficeCode >= @officeFrom AND OfficeCode <= @officeTo
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
				AND (
					(@SalesRepReport = 1 
						AND (SalesAgent = @salesAgentFrom OR SalesAgent2 = @salesAgentFrom OR SalesAgent2 = @salesAgentFrom 
							OR Dispatcher = @dispatcherFrom OR Dispatcher2 = @dispatcherFrom OR Dispatcher3 = @dispatcherFrom)
					) 
					OR 
					(@SalesRepReport = 0 
						AND SalesAgent BETWEEN @salesAgentFrom AND @salesAgentTo
						AND ((Dispatcher BETWEEN @dispatcherFrom AND @dispatcherTo)  
							OR (Dispatcher2 BETWEEN @dispatcherFrom AND @dispatcherTo)
							OR (Dispatcher3 BETWEEN @dispatcherFrom AND @dispatcherTo))
					)
				)
				AND statusText >= @statusTo
				AND statusText <= @statusFrom
				AND EquiptName >= @equipmentFrom
				AND EquiptName <= @equipmentTo
				AND OfficeCode >= @officeFrom AND OfficeCode <= @officeTo
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
				AND (
					(@SalesRepReport = 1 
						AND (SalesAgent = @salesAgentFrom OR SalesAgent2 = @salesAgentFrom OR SalesAgent2 = @salesAgentFrom 
							OR Dispatcher = @dispatcherFrom OR Dispatcher2 = @dispatcherFrom OR Dispatcher3 = @dispatcherFrom)
					) 
					OR 
					(@SalesRepReport = 0 
						AND SalesAgent BETWEEN @salesAgentFrom AND @salesAgentTo
						AND ((Dispatcher BETWEEN @dispatcherFrom AND @dispatcherTo)  
							OR (Dispatcher2 BETWEEN @dispatcherFrom AND @dispatcherTo)
							OR (Dispatcher3 BETWEEN @dispatcherFrom AND @dispatcherTo))
					)
				)
				AND statusText >= @statusTo
				AND statusText <= @statusFrom
				AND EquiptName >= @equipmentFrom
				AND EquiptName <= @equipmentTo
				AND OfficeCode >= @officeFrom AND OfficeCode <= @officeTo
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
				AND (
					(@SalesRepReport = 1 
						AND (SalesAgent = @salesAgentFrom OR SalesAgent2 = @salesAgentFrom OR SalesAgent2 = @salesAgentFrom 
							OR Dispatcher = @dispatcherFrom OR Dispatcher2 = @dispatcherFrom OR Dispatcher3 = @dispatcherFrom)
					) 
					OR 
					(@SalesRepReport = 0 
						AND SalesAgent BETWEEN @salesAgentFrom AND @salesAgentTo
						AND ((Dispatcher BETWEEN @dispatcherFrom AND @dispatcherTo)  
							OR (Dispatcher2 BETWEEN @dispatcherFrom AND @dispatcherTo)
							OR (Dispatcher3 BETWEEN @dispatcherFrom AND @dispatcherTo))
					)
				)
				AND statusText >= @statusTo
				AND statusText <= @statusFrom
				AND EquiptName >= @equipmentFrom
				AND EquiptName <= @equipmentTo
				AND OfficeCode >= @officeFrom AND OfficeCode <= @officeTo
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


GO

/****** Object:  View [dbo].[vwSalesDispatcher1]    Script Date: 05-07-2022 12:41:21 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



ALTER   VIEW [dbo].[vwSalesDispatcher1]
AS
SELECT        dbo.Companies.CompanyID, ISNULL(Employees_1.Name, dbo.Employees.Name) AS Dispatcher, dbo.Loads.LoadID, dbo.Loads.LoadNumber, dbo.Loads.HasLateStop, dbo.LoadStatusTypes.StatusText, dbo.Loads.NewPickupDate AS PickupDate, dbo.Loads.NewDeliveryDate AS DeliveryDate, dbo.Loads.BillDate AS InvoiceDate, dbo.Loads.CreatedDateTime AS CreatedDate, dbo.Customers.CustomerName, dbo.Loads.CarrierName, 
                         dbo.Loads.ShipperCity + ', ' + dbo.Loads.ShipperState + ' - ' + dbo.Loads.ConsigneeCity + ', ' + dbo.Loads.ConsigneeState AS PickupCityStateDeliveryCityState, 
                         dbo.Loads.TotalCustomerCharges AS [Cust Amt], dbo.Loads.TotalCarrierCharges AS [Carr Amt], ISNULL(dbo.Loads.TotalDirectCost,0) AS [Direct Cost], dbo.Loads.TotalCustomerCharges - dbo.Loads.TotalCarrierCharges AS Margin, CASE WHEN ISNULL(Employees_1.Name, '0') 
                         <> '0' THEN dbo.loads.Dispatcher1Percentage ELSE dbo.employees.salescommission END AS [Comm %], ((CASE WHEN ISNULL(Employees_1.Name, '0') 
                         <> '0' THEN dbo.loads.Dispatcher1Percentage ELSE dbo.employees.salescommission END) * .01) * (dbo.Loads.TotalCustomerCharges - dbo.Loads.TotalCarrierCharges) AS [Comm Amt]
						,Officies_1.OfficeCode,ISNULL(dbo.BillFromCompanies.CompanyName,dbo.Companies.CompanyName) AS BillFromCompany,ISNULL(dbo.Loads.NoOfTrips,0) AS NoOfTrips
						,SalesRep.Name AS SalesRep,dbo.Loads.SalesRep2Name AS SalesRep2,dbo.Loads.SalesRep3Name AS SalesRep3
FROM            dbo.Loads INNER JOIN
                         dbo.LoadStatusTypes ON dbo.Loads.StatusTypeID = dbo.LoadStatusTypes.StatusTypeID INNER JOIN
                         dbo.Customers ON dbo.Loads.CustomerID = dbo.Customers.CustomerID INNER JOIN
                         dbo.CustomerOffices ON dbo.Customers.CustomerID = dbo.CustomerOffices.CustomerID INNER JOIN
                         dbo.Offices ON dbo.CustomerOffices.OfficeID = dbo.Offices.OfficeID INNER JOIN
                         dbo.Companies ON dbo.Offices.CompanyID = dbo.Companies.CompanyID INNER JOIN
                         dbo.Employees ON dbo.Loads.DispatcherID = dbo.Employees.EmployeeID LEFT OUTER JOIN
                         dbo.Employees AS Employees_1 ON dbo.Loads.Dispatcher1 = Employees_1.EmployeeID LEFT OUTER JOIN
                         dbo.Offices AS Officies_1 ON Officies_1.OfficeID = ISNULL(Employees_1.OfficeID,dbo.Employees.OfficeID) LEFT OUTER JOIN
                         dbo.Employees AS SalesRep ON dbo.Loads.SalesRepID = SalesRep.EmployeeID LEFT OUTER JOIN
						 dbo.BillFromCompanies ON dbo.BillFromCompanies.BillFromCompanyID =  dbo.Loads.BillFromCompany
WHERE        (dbo.Loads.TotalCustomerCharges <> 0) OR
                         (dbo.Loads.TotalCarrierCharges <> 0)
GO


GO

/****** Object:  View [dbo].[vwSalesDispatcher2]    Script Date: 05-07-2022 13:09:18 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



ALTER   VIEW [dbo].[vwSalesDispatcher2]
AS
SELECT        dbo.Companies.CompanyID, ISNULL(Employees_1.Name, dbo.Employees.Name) AS Dispatcher, dbo.Loads.LoadID, dbo.Loads.LoadNumber, dbo.Loads.HasLateStop, dbo.LoadStatusTypes.StatusText, dbo.Loads.NewPickupDate AS PickupDate, dbo.Loads.NewDeliveryDate AS DeliveryDate, dbo.Loads.BillDate AS InvoiceDate, dbo.Loads.CreatedDateTime AS CreatedDate, dbo.Customers.CustomerName, dbo.Loads.CarrierName, 
                         dbo.Loads.ShipperCity + ', ' + dbo.Loads.ShipperState + ' - ' + dbo.Loads.ConsigneeCity + ', ' + dbo.Loads.ConsigneeState AS PickupCityStateDeliveryCityState, 
                         dbo.Loads.TotalCustomerCharges AS [Cust Amt], dbo.Loads.TotalCarrierCharges AS [Carr Amt], ISNULL(dbo.Loads.TotalDirectCost,0) AS [Direct Cost], dbo.Loads.TotalCustomerCharges - dbo.Loads.TotalCarrierCharges AS Margin, CASE WHEN ISNULL(Employees_1.Name, '0') 
                         <> '0' THEN dbo.loads.Dispatcher2Percentage ELSE dbo.employees.salescommission END AS [Comm %], ((CASE WHEN ISNULL(Employees_1.Name, '0') 
                         <> '0' THEN dbo.loads.Dispatcher2Percentage ELSE dbo.employees.salescommission END) * .01) * (dbo.Loads.TotalCustomerCharges - dbo.Loads.TotalCarrierCharges) AS [Comm Amt]
						,Officies_1.OfficeCode,ISNULL(dbo.BillFromCompanies.CompanyName,dbo.Companies.CompanyName) AS BillFromCompany,ISNULL(dbo.Loads.NoOfTrips,0) AS NoOfTrips
						,SalesRep.Name AS SalesRep,dbo.Loads.SalesRep2Name AS SalesRep2,dbo.Loads.SalesRep3Name AS SalesRep3
FROM            dbo.Loads INNER JOIN
                         dbo.LoadStatusTypes ON dbo.Loads.StatusTypeID = dbo.LoadStatusTypes.StatusTypeID INNER JOIN
                         dbo.Customers ON dbo.Loads.CustomerID = dbo.Customers.CustomerID INNER JOIN
                         dbo.CustomerOffices ON dbo.Customers.CustomerID = dbo.CustomerOffices.CustomerID INNER JOIN
                         dbo.Offices ON dbo.CustomerOffices.OfficeID = dbo.Offices.OfficeID INNER JOIN
                         dbo.Companies ON dbo.Offices.CompanyID = dbo.Companies.CompanyID INNER JOIN
                         dbo.Employees ON dbo.Loads.DispatcherID = dbo.Employees.EmployeeID LEFT OUTER JOIN
                         dbo.Employees AS Employees_1 ON dbo.Loads.Dispatcher2 = Employees_1.EmployeeID LEFT OUTER JOIN
                         dbo.Offices AS Officies_1 ON Officies_1.OfficeID = ISNULL(Employees_1.OfficeID,dbo.Employees.OfficeID) LEFT OUTER JOIN
						 dbo.Employees AS SalesRep ON dbo.Loads.SalesRepID = SalesRep.EmployeeID LEFT OUTER JOIN
						 dbo.BillFromCompanies ON dbo.BillFromCompanies.BillFromCompanyID =  dbo.Loads.BillFromCompany
WHERE        (dbo.Loads.TotalCustomerCharges <> 0) OR
                         (dbo.Loads.TotalCarrierCharges <> 0)
GO


GO

/****** Object:  View [dbo].[vwSalesDispatcher3]    Script Date: 05-07-2022 13:10:10 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



ALTER   VIEW [dbo].[vwSalesDispatcher3]
AS
SELECT        dbo.Companies.CompanyID, ISNULL(Employees_1.Name, dbo.Employees.Name) AS Dispatcher, dbo.Loads.LoadID, dbo.Loads.LoadNumber, dbo.Loads.HasLateStop, dbo.LoadStatusTypes.StatusText, dbo.Loads.NewPickupDate AS PickupDate, dbo.Loads.NewDeliveryDate AS DeliveryDate, dbo.Loads.BillDate AS InvoiceDate, dbo.Loads.CreatedDateTime AS CreatedDate, dbo.Customers.CustomerName, dbo.Loads.CarrierName, 
                         dbo.Loads.ShipperCity + ', ' + dbo.Loads.ShipperState + ' - ' + dbo.Loads.ConsigneeCity + ', ' + dbo.Loads.ConsigneeState AS PickupCityStateDeliveryCityState, 
                         dbo.Loads.TotalCustomerCharges AS [Cust Amt], dbo.Loads.TotalCarrierCharges AS [Carr Amt], ISNULL(dbo.Loads.TotalDirectCost,0) AS [Direct Cost], dbo.Loads.TotalCustomerCharges - dbo.Loads.TotalCarrierCharges AS Margin, CASE WHEN ISNULL(Employees_1.Name, '0') 
                         <> '0' THEN dbo.loads.Dispatcher3Percentage ELSE dbo.employees.salescommission END AS [Comm %], ((CASE WHEN ISNULL(Employees_1.Name, '0') 
                         <> '0' THEN dbo.loads.Dispatcher3Percentage ELSE dbo.employees.salescommission END) * .01) * (dbo.Loads.TotalCustomerCharges - dbo.Loads.TotalCarrierCharges) AS [Comm Amt]
						,Officies_1.OfficeCode,ISNULL(dbo.BillFromCompanies.CompanyName,dbo.Companies.CompanyName) AS BillFromCompany,ISNULL(dbo.Loads.NoOfTrips,0) AS NoOfTrips
						,SalesRep.Name AS SalesRep,dbo.Loads.SalesRep2Name AS SalesRep2,dbo.Loads.SalesRep3Name AS SalesRep3
FROM            dbo.Loads INNER JOIN
                         dbo.LoadStatusTypes ON dbo.Loads.StatusTypeID = dbo.LoadStatusTypes.StatusTypeID INNER JOIN
                         dbo.Customers ON dbo.Loads.CustomerID = dbo.Customers.CustomerID INNER JOIN
                         dbo.CustomerOffices ON dbo.Customers.CustomerID = dbo.CustomerOffices.CustomerID INNER JOIN
                         dbo.Offices ON dbo.CustomerOffices.OfficeID = dbo.Offices.OfficeID INNER JOIN
                         dbo.Companies ON dbo.Offices.CompanyID = dbo.Companies.CompanyID INNER JOIN
                         dbo.Employees ON dbo.Loads.DispatcherID = dbo.Employees.EmployeeID LEFT OUTER JOIN
                         dbo.Employees AS Employees_1 ON dbo.Loads.Dispatcher3 = Employees_1.EmployeeID LEFT OUTER JOIN
                         dbo.Offices AS Officies_1 ON Officies_1.OfficeID = ISNULL(Employees_1.OfficeID,dbo.Employees.OfficeID) LEFT OUTER JOIN
						 dbo.Employees AS SalesRep ON dbo.Loads.SalesRepID = SalesRep.EmployeeID LEFT OUTER JOIN
						 dbo.BillFromCompanies ON dbo.BillFromCompanies.BillFromCompanyID =  dbo.Loads.BillFromCompany
WHERE        (dbo.Loads.TotalCustomerCharges <> 0) OR
                         (dbo.Loads.TotalCarrierCharges <> 0)
GO


GO

/****** Object:  View [dbo].[vwSalesDispatcher]    Script Date: 05-07-2022 13:11:10 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



ALTER   VIEW [dbo].[vwSalesDispatcher]
AS
SELECT        *
FROM            vwSalesDispatcher1
UNION ALL

SELECT        *
FROM            vwSalesDispatcher2
UNION ALL

SELECT        *
FROM            vwSalesDispatcher3

GO


GO

/****** Object:  View [dbo].[vwSalesSalesRep1]    Script Date: 05-07-2022 13:13:07 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



ALTER   VIEW [dbo].[vwSalesSalesRep1]
AS
SELECT        dbo.Companies.CompanyID, ISNULL(Employees_1.Name, dbo.Employees.Name) AS SalesRep, dbo.Loads.LoadID, dbo.Loads.LoadNumber, dbo.Loads.HasLateStop, dbo.LoadStatusTypes.StatusText, dbo.Loads.NewPickupDate AS PickupDate, dbo.Loads.NewDeliveryDate AS DeliveryDate, dbo.Loads.BillDate AS InvoiceDate, dbo.Loads.CreatedDateTime AS CreatedDate, dbo.Customers.CustomerName, dbo.Loads.CarrierName, 
                         dbo.Loads.ShipperCity + ', ' + dbo.Loads.ShipperState + ' - ' + dbo.Loads.ConsigneeCity + ', ' + dbo.Loads.ConsigneeState AS PickupCityStateDeliveryCityState, 
                         dbo.Loads.TotalCustomerCharges AS [Cust Amt], dbo.Loads.TotalCarrierCharges AS [Carr Amt], ISNULL(dbo.Loads.TotalDirectCost,0) AS [Direct Cost], dbo.Loads.TotalCustomerCharges - dbo.Loads.TotalCarrierCharges AS Margin, CASE WHEN ISNULL(Employees_1.Name, '0') 
                         <> '0' THEN dbo.loads.SalesRep1Percentage ELSE dbo.employees.salescommission END AS [Comm %], ((CASE WHEN ISNULL(Employees_1.Name, '0') 
                         <> '0' THEN dbo.loads.SalesRep1Percentage ELSE dbo.employees.salescommission END) * .01) * (dbo.Loads.TotalCustomerCharges - dbo.Loads.TotalCarrierCharges) AS [Comm Amt]
						 ,Officies_1.OfficeCode,ISNULL(dbo.BillFromCompanies.CompanyName,dbo.Companies.CompanyName) AS BillFromCompany,ISNULL(dbo.Loads.NoOfTrips,0) AS NoOfTrips
						 ,Dispatcher.Name AS Dispatcher,dbo.Loads.Dispatcher2Name AS Dispatcher2,dbo.Loads.Dispatcher3Name AS Dispatcher3
FROM            dbo.Loads INNER JOIN
                         dbo.LoadStatusTypes ON dbo.Loads.StatusTypeID = dbo.LoadStatusTypes.StatusTypeID INNER JOIN
                         dbo.Customers ON dbo.Loads.CustomerID = dbo.Customers.CustomerID INNER JOIN
                         dbo.CustomerOffices ON dbo.Customers.CustomerID = dbo.CustomerOffices.CustomerID INNER JOIN
                         dbo.Offices ON dbo.CustomerOffices.OfficeID = dbo.Offices.OfficeID INNER JOIN
                         dbo.Companies ON dbo.Offices.CompanyID = dbo.Companies.CompanyID INNER JOIN
                         dbo.Employees ON dbo.Loads.SalesRepID = dbo.Employees.EmployeeID LEFT OUTER JOIN
                         dbo.Employees AS Employees_1 ON dbo.Loads.SalesRep1 = Employees_1.EmployeeID LEFT OUTER JOIN
                         dbo.Offices AS Officies_1 ON Officies_1.OfficeID = ISNULL(Employees_1.OfficeID,dbo.Employees.OfficeID) LEFT OUTER JOIN
						 dbo.Employees AS Dispatcher ON dbo.Loads.DispatcherID = Dispatcher.EmployeeID LEFT OUTER JOIN
						 dbo.BillFromCompanies ON dbo.BillFromCompanies.BillFromCompanyID =  dbo.Loads.BillFromCompany
WHERE        (dbo.Loads.TotalCustomerCharges <> 0) OR
                         (dbo.Loads.TotalCarrierCharges <> 0)
GO


GO

/****** Object:  View [dbo].[vwSalesSalesRep2]    Script Date: 05-07-2022 13:16:09 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



ALTER   VIEW [dbo].[vwSalesSalesRep2]
AS
SELECT        dbo.Companies.CompanyID, ISNULL(Employees_1.Name, dbo.Employees.Name) AS SalesRep, dbo.Loads.LoadID, dbo.Loads.LoadNumber, dbo.Loads.HasLateStop, dbo.LoadStatusTypes.StatusText, dbo.Loads.NewPickupDate AS PickupDate, dbo.Loads.NewDeliveryDate AS DeliveryDate, dbo.Loads.BillDate AS InvoiceDate, dbo.Loads.CreatedDateTime AS CreatedDate, dbo.Customers.CustomerName, dbo.Loads.CarrierName, 
                         dbo.Loads.ShipperCity + ', ' + dbo.Loads.ShipperState + ' - ' + dbo.Loads.ConsigneeCity + ', ' + dbo.Loads.ConsigneeState AS PickupCityStateDeliveryCityState, 
                         dbo.Loads.TotalCustomerCharges AS [Cust Amt], dbo.Loads.TotalCarrierCharges AS [Carr Amt], ISNULL(dbo.Loads.TotalDirectCost,0) AS [Direct Cost], dbo.Loads.TotalCustomerCharges - dbo.Loads.TotalCarrierCharges AS Margin, CASE WHEN ISNULL(Employees_1.Name, '0') 
                         <> '0' THEN dbo.loads.SalesRep2Percentage ELSE dbo.employees.salescommission END AS [Comm %], ((CASE WHEN ISNULL(Employees_1.Name, '0') 
                         <> '0' THEN dbo.loads.SalesRep2Percentage ELSE dbo.employees.salescommission END) * .01) * (dbo.Loads.TotalCustomerCharges - dbo.Loads.TotalCarrierCharges) AS [Comm Amt]
						,Officies_1.OfficeCode,ISNULL(dbo.BillFromCompanies.CompanyName,dbo.Companies.CompanyName) AS BillFromCompany,ISNULL(dbo.Loads.NoOfTrips,0) AS NoOfTrips
						,Dispatcher.Name AS Dispatcher,dbo.Loads.Dispatcher2Name AS Dispatcher2,dbo.Loads.Dispatcher3Name AS Dispatcher3
FROM            dbo.Loads INNER JOIN
                         dbo.LoadStatusTypes ON dbo.Loads.StatusTypeID = dbo.LoadStatusTypes.StatusTypeID INNER JOIN
                         dbo.Customers ON dbo.Loads.CustomerID = dbo.Customers.CustomerID INNER JOIN
                         dbo.CustomerOffices ON dbo.Customers.CustomerID = dbo.CustomerOffices.CustomerID INNER JOIN
                         dbo.Offices ON dbo.CustomerOffices.OfficeID = dbo.Offices.OfficeID INNER JOIN
                         dbo.Companies ON dbo.Offices.CompanyID = dbo.Companies.CompanyID INNER JOIN
                         dbo.Employees ON dbo.Loads.SalesRepID = dbo.Employees.EmployeeID LEFT OUTER JOIN
                         dbo.Employees AS Employees_1 ON dbo.Loads.SalesRep2 = Employees_1.EmployeeID LEFT OUTER JOIN
                         dbo.Offices AS Officies_1 ON Officies_1.OfficeID = ISNULL(Employees_1.OfficeID,dbo.Employees.OfficeID) LEFT OUTER JOIN
						 dbo.Employees AS Dispatcher ON dbo.Loads.DispatcherID = Dispatcher.EmployeeID LEFT OUTER JOIN
						 dbo.BillFromCompanies ON dbo.BillFromCompanies.BillFromCompanyID =  dbo.Loads.BillFromCompany
WHERE        (dbo.Loads.TotalCustomerCharges <> 0) OR
                         (dbo.Loads.TotalCarrierCharges <> 0)
GO


GO

/****** Object:  View [dbo].[vwSalesSalesRep3]    Script Date: 05-07-2022 13:16:51 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



ALTER   VIEW [dbo].[vwSalesSalesRep3]
AS
SELECT        dbo.Companies.CompanyID, ISNULL(Employees_1.Name, dbo.Employees.Name) AS SalesRep, dbo.Loads.LoadID, dbo.Loads.LoadNumber, dbo.Loads.HasLateStop, dbo.LoadStatusTypes.StatusText, dbo.Loads.NewPickupDate AS PickupDate, dbo.Loads.NewDeliveryDate AS DeliveryDate, dbo.Loads.BillDate AS InvoiceDate, dbo.Loads.CreatedDateTime AS CreatedDate, dbo.Customers.CustomerName, dbo.Loads.CarrierName, 
                         dbo.Loads.ShipperCity + ', ' + dbo.Loads.ShipperState + ' - ' + dbo.Loads.ConsigneeCity + ', ' + dbo.Loads.ConsigneeState AS PickupCityStateDeliveryCityState, 
                         dbo.Loads.TotalCustomerCharges AS [Cust Amt], dbo.Loads.TotalCarrierCharges AS [Carr Amt], ISNULL(dbo.Loads.TotalDirectCost,0) AS [Direct Cost], dbo.Loads.TotalCustomerCharges - dbo.Loads.TotalCarrierCharges AS Margin, CASE WHEN ISNULL(Employees_1.Name, '0') 
                         <> '0' THEN dbo.loads.SalesRep3Percentage ELSE dbo.employees.salescommission END AS [Comm %], ((CASE WHEN ISNULL(Employees_1.Name, '0') 
                         <> '0' THEN dbo.loads.SalesRep3Percentage ELSE dbo.employees.salescommission END) * .01) * (dbo.Loads.TotalCustomerCharges - dbo.Loads.TotalCarrierCharges) AS [Comm Amt]
						,Officies_1.OfficeCode,ISNULL(dbo.BillFromCompanies.CompanyName,dbo.Companies.CompanyName) AS BillFromCompany,ISNULL(dbo.Loads.NoOfTrips,0) AS NoOfTrips
						,Dispatcher.Name AS Dispatcher,dbo.Loads.Dispatcher2Name AS Dispatcher2,dbo.Loads.Dispatcher3Name AS Dispatcher3
FROM            dbo.Loads INNER JOIN
                         dbo.LoadStatusTypes ON dbo.Loads.StatusTypeID = dbo.LoadStatusTypes.StatusTypeID INNER JOIN
                         dbo.Customers ON dbo.Loads.CustomerID = dbo.Customers.CustomerID INNER JOIN
                         dbo.CustomerOffices ON dbo.Customers.CustomerID = dbo.CustomerOffices.CustomerID INNER JOIN
                         dbo.Offices ON dbo.CustomerOffices.OfficeID = dbo.Offices.OfficeID INNER JOIN
                         dbo.Companies ON dbo.Offices.CompanyID = dbo.Companies.CompanyID INNER JOIN
                         dbo.Employees ON dbo.Loads.SalesRepID = dbo.Employees.EmployeeID LEFT OUTER JOIN
                         dbo.Employees AS Employees_1 ON dbo.Loads.SalesRep3 = Employees_1.EmployeeID LEFT OUTER JOIN
                         dbo.Offices AS Officies_1 ON Officies_1.OfficeID = ISNULL(Employees_1.OfficeID,dbo.Employees.OfficeID) LEFT OUTER JOIN
						 dbo.Employees AS Dispatcher ON dbo.Loads.DispatcherID = Dispatcher.EmployeeID LEFT OUTER JOIN
						 dbo.BillFromCompanies ON dbo.BillFromCompanies.BillFromCompanyID =  dbo.Loads.BillFromCompany
WHERE        (dbo.Loads.TotalCustomerCharges <> 0) OR
                         (dbo.Loads.TotalCarrierCharges <> 0)
GO


GO

/****** Object:  View [dbo].[vwSalesSalesRep]    Script Date: 05-07-2022 13:17:37 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



ALTER   VIEW [dbo].[vwSalesSalesRep]
AS
SELECT        *
FROM            vwSalesSalesRep1
UNION ALL

SELECT        *
FROM            vwSalesSalesRep2
UNION ALL

SELECT        *
FROM            vwSalesSalesRep3

GO


GO

/****** Object:  View [dbo].[vwSales]    Script Date: 05-07-2022 13:18:17 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



ALTER   VIEW [dbo].[vwSales]
AS
SELECT        dbo.Companies.CompanyID, dbo.Loads.LoadID, dbo.Loads.LoadNumber, dbo.Loads.HasLateStop, dbo.LoadStatusTypes.StatusText, dbo.Loads.NewPickupDate AS PickupDate, dbo.Loads.NewDeliveryDate AS DeliveryDate, dbo.Loads.BillDate AS InvoiceDate, dbo.Loads.CreatedDateTime AS CreatedDate, dbo.Customers.CustomerName, dbo.Loads.CarrierName, 
                         dbo.Loads.ShipperCity + ', ' + dbo.Loads.ShipperState + ' - ' + dbo.Loads.ConsigneeCity + ', ' + dbo.Loads.ConsigneeState AS PickupCityStateDeliveryCityState, 
                         dbo.Loads.TotalCustomerCharges AS [Cust Amt], dbo.Loads.TotalCarrierCharges AS [Carr Amt], '0' AS [Direct Cost], dbo.Loads.TotalCustomerCharges - dbo.Loads.TotalCarrierCharges AS Margin, CASE WHEN (dbo.loads.Dispatcher1 IS NOT NULL OR dbo.loads.Dispatcher2 IS NOT NULL OR dbo.loads.Dispatcher3 IS NOT NULL) THEN dbo.loads.Dispatcher1Percentage+dbo.loads.Dispatcher2Percentage+dbo.loads.Dispatcher3Percentage ELSE dbo.employees.salescommission END AS [Comm %], ((CASE WHEN (dbo.loads.Dispatcher1 IS NOT NULL OR dbo.loads.Dispatcher2 IS NOT NULL OR dbo.loads.Dispatcher3 IS NOT NULL) THEN dbo.loads.Dispatcher1Percentage+dbo.loads.Dispatcher2Percentage+dbo.loads.Dispatcher3Percentage ELSE dbo.employees.salescommission END) * .01) * (dbo.Loads.TotalCustomerCharges - dbo.Loads.TotalCarrierCharges) AS [Comm Amt]
						,dbo.Offices.OfficeCode,ISNULL(dbo.BillFromCompanies.CompanyName,dbo.Companies.CompanyName) AS BillFromCompany,ISNULL(dbo.Loads.NoOfTrips,0) AS NoOfTrips
						,SalesRep.Name AS SalesRep,dbo.Loads.SalesRep2Name AS SalesRep2,dbo.Loads.SalesRep3Name AS SalesRep3
						,dbo.Employees.Name AS Dispatcher,dbo.Loads.Dispatcher2Name AS Dispatcher2,dbo.Loads.Dispatcher3Name AS Dispatcher3
FROM            dbo.Loads INNER JOIN
                         dbo.LoadStatusTypes ON dbo.Loads.StatusTypeID = dbo.LoadStatusTypes.StatusTypeID INNER JOIN
                         dbo.Customers ON dbo.Loads.CustomerID = dbo.Customers.CustomerID INNER JOIN
                         dbo.CustomerOffices ON dbo.Customers.CustomerID = dbo.CustomerOffices.CustomerID INNER JOIN
                         dbo.Offices ON dbo.CustomerOffices.OfficeID = dbo.Offices.OfficeID INNER JOIN
                         dbo.Companies ON dbo.Offices.CompanyID = dbo.Companies.CompanyID INNER JOIN
                         dbo.Employees ON dbo.Loads.DispatcherID = dbo.Employees.EmployeeID LEFT OUTER JOIN
						 dbo.Employees SalesRep ON dbo.Loads.SalesRepID = SalesRep.EmployeeID LEFT OUTER JOIN
						 dbo.BillFromCompanies ON dbo.BillFromCompanies.BillFromCompanyID =  dbo.Loads.BillFromCompany
WHERE        (dbo.Loads.TotalCustomerCharges <> 0) OR
                         (dbo.Loads.TotalCarrierCharges <> 0)
GO


GO

/****** Object:  StoredProcedure [dbo].[USP_GetSalesReport]    Script Date: 05-07-2022 12:34:13 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



ALTER     PROCEDURE [dbo].[USP_GetSalesReport]

@CompanyID varchar(36),
@GroupBy varchar(36),
@DateType varchar(10),
@DateFrom date,
@DateTo date,
@StatusFrom varchar(50),
@StatusTo varchar(50),
@SalesRepFrom varchar(150),
@SalesRepTo varchar(150),
@DispatcherFrom varchar(150),
@DispatcherTo varchar(150),
@CustomerFrom varchar(150),
@CustomerTo varchar(150),
@CarrierFrom varchar(150),
@CarrierTo varchar(150),
@OrderBy varchar(20),
@OfficeFrom varchar(150),
@OfficeTo varchar(150),
@BillFrom varchar(150),
@BillTo varchar(150),
@SalesRepReport bit
AS
BEGIN

	DECLARE @sql varchar(max);
	SET @sql = 'SELECT * FROM'

	IF(@GroupBy='dispatcher')
	BEGIN
		SET @sql = @sql + ' vwSalesDispatcher WITH (NOLOCK)'
	END
	ELSE IF(@GroupBy='salesAgent')
	BEGIN
		SET @sql = @sql + ' vwSalesSalesRep WITH (NOLOCK)'
	END
	ELSE
	BEGIN
		SET @sql = @sql + ' vwSales WITH (NOLOCK)'
	END

	SET @sql = @sql + ' WHERE CompanyID = '''+@CompanyID+''''

	SET @sql = @sql + ' AND StatusText BETWEEN '''+@StatusFrom+''' AND '''+@StatusTo+''''

	IF(@DateType='Pickup')
	BEGIN
		SET @sql = @sql + ' AND PickupDate BETWEEN '''+CAST(@DateFrom AS varchar(30))+''' AND '''+CAST(@DateTo AS varchar(30))+''''
	END
	ELSE IF(@DateType='Delivery')
	BEGIN
		SET @sql = @sql + ' AND DeliveryDate BETWEEN '''+CAST(@DateFrom AS varchar(30))+''' AND '''+CAST(@DateTo AS varchar(30))+''''
	END
	ELSE IF(@DateType='Invoice')
	BEGIN
		SET @sql = @sql + ' AND InvoiceDate BETWEEN '''+CAST(@DateFrom AS varchar(30))+''' AND '''+CAST(@DateTo AS varchar(30))+''''
	END
	ELSE
	BEGIN
		SET @sql = @sql + ' AND CreatedDate BETWEEN '''+CAST(@DateFrom AS varchar(30))+''' AND '''+CAST(@DateTo AS varchar(30))+''''
	END

	IF(@SalesRepReport=0)
	BEGIN
		IF(len(trim(@DispatcherFrom)) <> 0 AND @GroupBy='dispatcher')
		BEGIN
			SET @sql = @sql + ' AND trim(Dispatcher) >= '''+trim(@DispatcherFrom)+''''
		END

		IF(len(trim(@DispatcherTo)) <> 0 AND @GroupBy='dispatcher')
		BEGIN
			SET @sql = @sql + ' AND trim(Dispatcher) <= '''+trim(@DispatcherTo)+''''
		END


		IF(len(trim(@SalesRepFrom)) <> 0 AND (@GroupBy='salesAgent' OR @GroupBy='none'))
		BEGIN
			SET @sql = @sql + ' AND trim(SalesRep) >= '''+trim(@SalesRepFrom)+''''
		END

		IF(len(trim(@SalesRepTo)) <> 0 AND (@GroupBy='salesAgent' OR @GroupBy='none'))
		BEGIN
			SET @sql = @sql + ' AND trim(SalesRep) <= '''+trim(@SalesRepTo)+''''
		END
	END 
	ELSE
	BEGIN
		IF(@GroupBy='dispatcher')
		BEGIN
			SET @sql = @sql + ' AND (trim(Dispatcher) = '''+trim(@DispatcherFrom)+''' OR trim(SalesRep) = '''+trim(@SalesRepTo)+''' OR trim(SalesRep2) = '''+trim(@SalesRepTo)+''' OR trim(SalesRep3) = '''+trim(@SalesRepTo)+''')'
		END
		ELSE IF(@GroupBy='salesAgent')
		BEGIN
			SET @sql = @sql + ' AND (trim(Dispatcher) = '''+trim(@DispatcherFrom)+''' OR trim(Dispatcher2) = '''+trim(@DispatcherFrom)+''' OR trim(Dispatcher3) = '''+trim(@DispatcherFrom)+''' OR trim(SalesRep) = '''+trim(@SalesRepTo)+''')'
		END
		ELSE
		BEGIN
			SET @sql = @sql + ' AND (trim(Dispatcher) = '''+trim(@DispatcherFrom)+''' OR trim(Dispatcher2) = '''+trim(@DispatcherFrom)+''' OR trim(Dispatcher3) = '''+trim(@DispatcherFrom)+''' OR trim(SalesRep) = '''+trim(@SalesRepTo)+''' OR trim(SalesRep2) = '''+trim(@SalesRepTo)+''' OR trim(SalesRep3) = '''+trim(@SalesRepTo)+''')'
		END
	END
	IF(len(trim(@CustomerFrom)) <> 0)
	BEGIN
		SET @sql = @sql + ' AND trim(CustomerName) >= '''+trim(@CustomerFrom)+''''
	END

	IF(len(trim(@CustomerTo)) <> 0)
	BEGIN
		SET @sql = @sql + ' AND trim(CustomerName) <= '''+trim(@CustomerTo)+''''
	END

	IF(len(trim(@CarrierFrom)) <> 0)
	BEGIN
		SET @sql = @sql + ' AND trim(CarrierName) >= '''+trim(@CarrierFrom)+''''
	END

	IF(len(trim(@CarrierTo)) <> 0)
	BEGIN
		SET @sql = @sql + ' AND trim(CarrierName) <= '''+trim(@CarrierTo)+''''
	END

	IF(len(trim(@OfficeFrom)) <> 0)
	BEGIN
		SET @sql = @sql + ' AND trim(OfficeCode) >= '''+trim(@OfficeFrom)+''''
	END

	IF(len(trim(@OfficeTo)) <> 0)
	BEGIN
		SET @sql = @sql + ' AND trim(OfficeCode) <= '''+trim(@OfficeTo)+''''
	END
	
	IF(len(trim(@BillFrom)) <> 0)
	BEGIN
		SET @sql = @sql + ' AND trim(BillFromCompany) >= '''+trim(@BillFrom)+''''
	END

	IF(len(trim(@BillTo)) <> 0)
	BEGIN
		SET @sql = @sql + ' AND trim(BillFromCompany) <= '''+trim(@BillTo)+''''
	END

	SET @sql = @sql + 'ORDER BY OfficeCode,'

	IF(@GroupBy='dispatcher')
	BEGIN
		SET @sql = @sql + ' Dispatcher,'
	END
	ELSE IF(@GroupBy='salesAgent')
	BEGIN
		SET @sql = @sql + ' SalesRep,'
	END
	ELSE IF(@GroupBy='customer')
	BEGIN
		SET @sql = @sql + ' CustomerName,'
	END
	ELSE IF(@GroupBy='carrier')
	BEGIN
		SET @sql = @sql + ' CarrierName,'
	END

	SET @sql = @sql + 'LoadNumber'

	EXEC(@sql);
	--SELECT @sql
END

GO

GO

/****** Object:  View [dbo].[vwSalesDetailDispatcher1Cmdty]    Script Date: 05-07-2022 13:48:21 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER VIEW [dbo].[vwSalesDetailDispatcher1Cmdty]
AS
SELECT        dbo.Companies.CompanyID, ISNULL(Employees_1.Name, dbo.Employees.Name) AS Dispatcher, dbo.Loads.LoadID, dbo.Loads.LoadNumber, dbo.Loads.HasLateStop, dbo.LoadStatusTypes.StatusText, 
                         dbo.Loads.NewPickupDate AS PickupDate, dbo.Loads.NewDeliveryDate AS DeliveryDate, dbo.Loads.BillDate AS InvoiceDate, dbo.Loads.CreatedDateTime AS CreatedDate, dbo.Customers.CustomerName, 
                         dbo.Loads.CarrierName, dbo.Loads.ShipperCity + ', ' + dbo.Loads.ShipperState + ' - ' + dbo.Loads.ConsigneeCity + ', ' + dbo.Loads.ConsigneeState AS PickupCityStateDeliveryCityState, dbo.LoadStopCommodities.Qty, 
                         dbo.LoadStopCommodities.Description, dbo.LoadStopCommodities.Weight AS LBS, dbo.LoadStopCommodities.CustCharges AS [Cust Amt], dbo.LoadStopCommodities.CarrCharges AS [Carr Amt], 
                         ISNULL(dbo.LoadStopCommodities.DirectCostTotal, 0) AS [Direct Cost], dbo.LoadStopCommodities.CustCharges - dbo.LoadStopCommodities.CarrCharges - ISNULL(ISNULL(dbo.LoadStopCommodities.DirectCostTotal, 0), 0) 
                         AS Margin, CASE WHEN ISNULL(Employees_1.Name, '0') <> '0' THEN dbo.loads.Dispatcher1Percentage ELSE dbo.employees.salescommission END AS [Comm %], ((CASE WHEN ISNULL(Employees_1.Name, '0') 
                         <> '0' THEN dbo.loads.Dispatcher1Percentage ELSE dbo.employees.salescommission END) * 0.01) 
                         * (dbo.LoadStopCommodities.CustCharges - dbo.LoadStopCommodities.CarrCharges - ISNULL(ISNULL(dbo.LoadStopCommodities.DirectCostTotal, 0), 0)) AS [Comm Amt], 
                         (dbo.LoadStopCommodities.CustCharges - dbo.LoadStopCommodities.CarrCharges - ISNULL(ISNULL(dbo.LoadStopCommodities.DirectCostTotal, 0), 0)) / CASE WHEN ((CASE WHEN (dbo.loads.Dispatcher1Percentage > 0) 
                         THEN 1 ELSE 0 END) + (CASE WHEN (dbo.loads.Dispatcher2Percentage > 0) THEN 1 ELSE 0 END) + (CASE WHEN (dbo.loads.Dispatcher3Percentage > 0) THEN 1 ELSE 0 END)) 
                         > 0 THEN ((CASE WHEN (dbo.loads.Dispatcher1Percentage > 0) THEN 1 ELSE 0 END) + (CASE WHEN (dbo.loads.Dispatcher2Percentage > 0) THEN 1 ELSE 0 END) + (CASE WHEN (dbo.loads.Dispatcher3Percentage > 0) 
                         THEN 1 ELSE 0 END)) ELSE 1 END AS DispatchSplitAmt,dbo.Offices.OfficeCode,ISNULL(dbo.BillFromCompanies.CompanyName,dbo.Companies.CompanyName) AS BillFromCompany,ISNULL(dbo.Loads.NoOfTrips,0) AS NoOfTrips
						 ,SalesRep.Name AS SalesRep,dbo.Loads.SalesRep2Name AS SalesRep2,dbo.Loads.SalesRep3Name AS SalesRep3
FROM            dbo.Loads INNER JOIN
                         dbo.LoadStatusTypes ON dbo.Loads.StatusTypeID = dbo.LoadStatusTypes.StatusTypeID INNER JOIN
                         dbo.Customers ON dbo.Loads.CustomerID = dbo.Customers.CustomerID INNER JOIN
                         dbo.CustomerOffices ON dbo.Customers.CustomerID = dbo.CustomerOffices.CustomerID INNER JOIN
                         dbo.Offices ON dbo.CustomerOffices.OfficeID = dbo.Offices.OfficeID INNER JOIN
                         dbo.Companies ON dbo.Offices.CompanyID = dbo.Companies.CompanyID INNER JOIN
                         dbo.Employees ON dbo.Loads.DispatcherID = dbo.Employees.EmployeeID INNER JOIN
                         dbo.LoadStops ON dbo.Loads.LoadID = dbo.LoadStops.LoadID INNER JOIN
                         dbo.LoadStopCommodities ON dbo.LoadStops.LoadStopID = dbo.LoadStopCommodities.LoadStopID LEFT OUTER JOIN
                         dbo.Employees AS Employees_1 ON dbo.Loads.Dispatcher1 = Employees_1.EmployeeID LEFT OUTER JOIN
                         dbo.Employees AS SalesRep ON dbo.Loads.SalesRepID = SalesRep.EmployeeID LEFT OUTER JOIN
						 dbo.BillFromCompanies ON dbo.BillFromCompanies.BillFromCompanyID =  dbo.Loads.BillFromCompany
WHERE        (dbo.LoadStopCommodities.Description <> N'') OR
                         (dbo.LoadStopCommodities.Weight <> 0) OR
                         (dbo.LoadStopCommodities.CustCharges <> 0) OR
                         (dbo.LoadStopCommodities.CarrCharges <> 0) OR
                         (ISNULL(dbo.LoadStopCommodities.DirectCostTotal, 0) <> 0)
GO



GO

/****** Object:  View [dbo].[vwSalesDetailDispatcher1FlatRate]    Script Date: 05-07-2022 13:50:43 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER VIEW [dbo].[vwSalesDetailDispatcher1FlatRate]
AS
SELECT        dbo.Companies.CompanyID, ISNULL(Employees_1.Name, dbo.Employees.Name) AS Dispatcher, dbo.Loads.LoadID, dbo.Loads.LoadNumber, dbo.Loads.HasLateStop, dbo.LoadStatusTypes.StatusText, 
                         dbo.Loads.NewPickupDate AS PickupDate, dbo.Loads.NewDeliveryDate AS DeliveryDate, dbo.Loads.BillDate AS InvoiceDate, dbo.Loads.CreatedDateTime AS CreatedDate, dbo.Customers.CustomerName, 
                         dbo.Loads.CarrierName, dbo.Loads.ShipperCity + ', ' + dbo.Loads.ShipperState + ' - ' + dbo.Loads.ConsigneeCity + ', ' + dbo.Loads.ConsigneeState AS PickupCityStateDeliveryCityState, '1' AS Qty, 'Flat Rate' AS Descrition, 
                         '0' AS LBS, dbo.Loads.CustFlatRate AS [Cust Amt], dbo.Loads.CarrFlatRate AS [Carr Amt], '0' AS [Direct Cost], dbo.Loads.CustFlatRate - dbo.Loads.CarrFlatRate AS Margin, CASE WHEN ISNULL(Employees_1.Name, '0') 
                         <> '0' THEN dbo.loads.Dispatcher1Percentage ELSE dbo.employees.salescommission END AS [Comm %], ((CASE WHEN ISNULL(Employees_1.Name, '0') 
                         <> '0' THEN dbo.loads.Dispatcher1Percentage ELSE dbo.employees.salescommission END) * .01) * (dbo.Loads.CustFlatRate - dbo.Loads.CarrFlatRate) AS [Comm Amt], 
                         (dbo.Loads.TotalCustomerCharges - dbo.Loads.TotalCarrierCharges) / CASE WHEN ((CASE WHEN (dbo.loads.Dispatcher1Percentage > 0) THEN 1 ELSE 0 END) + (CASE WHEN (dbo.loads.Dispatcher2Percentage > 0) 
                         THEN 1 ELSE 0 END) + (CASE WHEN (dbo.loads.Dispatcher3Percentage > 0) THEN 1 ELSE 0 END)) > 0 THEN ((CASE WHEN (dbo.loads.Dispatcher1Percentage > 0) THEN 1 ELSE 0 END) 
                         + (CASE WHEN (dbo.loads.Dispatcher2Percentage > 0) THEN 1 ELSE 0 END) + (CASE WHEN (dbo.loads.Dispatcher3Percentage > 0) THEN 1 ELSE 0 END)) ELSE 1 END AS DispatchSplitAmt,dbo.Offices.OfficeCode,ISNULL(dbo.BillFromCompanies.CompanyName,dbo.Companies.CompanyName) AS BillFromCompany,ISNULL(dbo.Loads.NoOfTrips,0) AS NoOfTrips
						 ,SalesRep.Name AS SalesRep,dbo.Loads.SalesRep2Name AS SalesRep2,dbo.Loads.SalesRep3Name AS SalesRep3
FROM            dbo.Loads INNER JOIN
                         dbo.LoadStatusTypes ON dbo.Loads.StatusTypeID = dbo.LoadStatusTypes.StatusTypeID INNER JOIN
                         dbo.Customers ON dbo.Loads.CustomerID = dbo.Customers.CustomerID INNER JOIN
                         dbo.CustomerOffices ON dbo.Customers.CustomerID = dbo.CustomerOffices.CustomerID INNER JOIN
                         dbo.Offices ON dbo.CustomerOffices.OfficeID = dbo.Offices.OfficeID INNER JOIN
                         dbo.Companies ON dbo.Offices.CompanyID = dbo.Companies.CompanyID INNER JOIN
                         dbo.Employees ON dbo.Loads.DispatcherID = dbo.Employees.EmployeeID LEFT OUTER JOIN
                         dbo.Employees AS Employees_1 ON dbo.Loads.Dispatcher1 = Employees_1.EmployeeID LEFT OUTER JOIN
						 dbo.Employees AS SalesRep ON dbo.Loads.SalesRepID = SalesRep.EmployeeID LEFT OUTER JOIN
						 dbo.BillFromCompanies ON dbo.BillFromCompanies.BillFromCompanyID =  dbo.Loads.BillFromCompany
WHERE        (dbo.Loads.CarrFlatRate <> 0) OR
                         (dbo.Loads.CustFlatRate <> 0)
GO
GO

/****** Object:  View [dbo].[vwSalesDetailDispatcher1MilesRate]    Script Date: 05-07-2022 13:54:30 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER VIEW [dbo].[vwSalesDetailDispatcher1MilesRate]
AS
SELECT        dbo.Companies.CompanyID, ISNULL(Employees_1.Name, dbo.Employees.Name) AS Dispatcher, dbo.Loads.LoadID, dbo.Loads.LoadNumber, dbo.Loads.HasLateStop, dbo.LoadStatusTypes.StatusText, 
                         dbo.Loads.NewPickupDate AS PickupDate, dbo.Loads.NewDeliveryDate AS DeliveryDate, dbo.Loads.BillDate AS InvoiceDate, dbo.Loads.CreatedDateTime AS CreatedDate, dbo.Customers.CustomerName, 
                         dbo.Loads.CarrierName, dbo.Loads.ShipperCity + ', ' + dbo.Loads.ShipperState + ' - ' + dbo.Loads.ConsigneeCity + ', ' + dbo.Loads.ConsigneeState AS PickupCityStateDeliveryCityState, '1' AS Qty, 'Miles Charge' AS Descrition, 
                         '0' AS LBS, dbo.Loads.CustomerRatePerMile * dbo.Loads.TotalMiles AS [Cust Amt], dbo.Loads.CarrierRatePerMile * dbo.Loads.TotalMiles AS [Carr Amt], '0' AS [Direct Cost], 
                         dbo.Loads.CustomerRatePerMile * dbo.Loads.TotalMiles - dbo.Loads.CarrierRatePerMile * dbo.Loads.TotalMiles AS Margin, CASE WHEN ISNULL(Employees_1.Name, '0') 
                         <> '0' THEN dbo.loads.Dispatcher1Percentage ELSE dbo.employees.salescommission END AS [Comm %], ((CASE WHEN ISNULL(Employees_1.Name, '0') 
                         <> '0' THEN dbo.loads.Dispatcher1Percentage ELSE dbo.employees.salescommission END) * .01) * (dbo.Loads.CustomerRatePerMile * dbo.Loads.TotalMiles - dbo.Loads.CarrierRatePerMile * dbo.Loads.TotalMiles) 
                         AS [Comm Amt], (dbo.Loads.CustomerRatePerMile * dbo.Loads.TotalMiles - dbo.Loads.CarrierRatePerMile * dbo.Loads.TotalMiles) / CASE WHEN ((CASE WHEN (dbo.loads.Dispatcher1Percentage > 0) THEN 1 ELSE 0 END) 
                         + (CASE WHEN (dbo.loads.Dispatcher2Percentage > 0) THEN 1 ELSE 0 END) + (CASE WHEN (dbo.loads.Dispatcher3Percentage > 0) THEN 1 ELSE 0 END)) > 0 THEN ((CASE WHEN (dbo.loads.Dispatcher1Percentage > 0) 
                         THEN 1 ELSE 0 END) + (CASE WHEN (dbo.loads.Dispatcher2Percentage > 0) THEN 1 ELSE 0 END) + (CASE WHEN (dbo.loads.Dispatcher3Percentage > 0) THEN 1 ELSE 0 END)) ELSE 1 END AS DispatchSplitAmt,dbo.Offices.OfficeCode,ISNULL(dbo.BillFromCompanies.CompanyName,dbo.Companies.CompanyName) AS BillFromCompany,ISNULL(dbo.Loads.NoOfTrips,0) AS NoOfTrips
						 ,SalesRep.Name AS SalesRep,dbo.Loads.SalesRep2Name AS SalesRep2,dbo.Loads.SalesRep3Name AS SalesRep3
FROM            dbo.Loads INNER JOIN
                         dbo.LoadStatusTypes ON dbo.Loads.StatusTypeID = dbo.LoadStatusTypes.StatusTypeID INNER JOIN
                         dbo.Customers ON dbo.Loads.CustomerID = dbo.Customers.CustomerID INNER JOIN
                         dbo.CustomerOffices ON dbo.Customers.CustomerID = dbo.CustomerOffices.CustomerID INNER JOIN
                         dbo.Offices ON dbo.CustomerOffices.OfficeID = dbo.Offices.OfficeID INNER JOIN
                         dbo.Companies ON dbo.Offices.CompanyID = dbo.Companies.CompanyID INNER JOIN
                         dbo.Employees ON dbo.Loads.DispatcherID = dbo.Employees.EmployeeID LEFT OUTER JOIN
                         dbo.Employees AS Employees_1 ON dbo.Loads.Dispatcher1 = Employees_1.EmployeeID LEFT OUTER JOIN
						 dbo.Employees AS SalesRep ON dbo.Loads.SalesRepID = SalesRep.EmployeeID LEFT OUTER JOIN
						 dbo.BillFromCompanies ON dbo.BillFromCompanies.BillFromCompanyID =  dbo.Loads.BillFromCompany
WHERE        (dbo.Loads.CustomerRatePerMile * dbo.Loads.TotalMiles <> 0) OR
                         (dbo.Loads.CarrierRatePerMile * dbo.Loads.TotalMiles <> 0)
GO


GO

/****** Object:  View [dbo].[vwSalesDetailDispatcher2Cmdty]    Script Date: 05-07-2022 13:55:28 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER VIEW [dbo].[vwSalesDetailDispatcher2Cmdty]
AS
SELECT        dbo.Companies.CompanyID, dbo.Employees.Name AS Dispatcher, dbo.Loads.LoadID, dbo.Loads.LoadNumber, dbo.Loads.HasLateStop, dbo.LoadStatusTypes.StatusText, dbo.Loads.NewPickupDate AS PickupDate, 
                         dbo.Loads.NewDeliveryDate AS DeliveryDate, dbo.Loads.BillDate AS InvoiceDate, dbo.Loads.CreatedDateTime AS CreatedDate, dbo.Customers.CustomerName, dbo.Loads.CarrierName, 
                         dbo.Loads.ShipperCity + ', ' + dbo.Loads.ShipperState + ' - ' + dbo.Loads.ConsigneeCity + ', ' + dbo.Loads.ConsigneeState AS PickupCityStateDeliveryCityState, dbo.LoadStopCommodities.Qty, 
                         dbo.LoadStopCommodities.Description, dbo.LoadStopCommodities.Weight AS LBS, dbo.LoadStopCommodities.CustCharges AS [Cust Amt], dbo.LoadStopCommodities.CarrCharges AS [Carr Amt], 
                         ISNULL(dbo.LoadStopCommodities.DirectCostTotal, 0) AS [Direct Cost], dbo.LoadStopCommodities.CustCharges - dbo.LoadStopCommodities.CarrCharges - ISNULL(ISNULL(dbo.LoadStopCommodities.DirectCostTotal, 0), 0) 
                         AS Margin, dbo.Loads.Dispatcher2Percentage AS [Comm %], (dbo.Loads.Dispatcher2Percentage * 0.01) 
                         * (dbo.LoadStopCommodities.CustCharges - dbo.LoadStopCommodities.CarrCharges - ISNULL(ISNULL(dbo.LoadStopCommodities.DirectCostTotal, 0), 0)) AS [Comm Amt], 
                         (dbo.LoadStopCommodities.CustCharges - dbo.LoadStopCommodities.CarrCharges - ISNULL(ISNULL(dbo.LoadStopCommodities.DirectCostTotal, 0), 0)) / CASE WHEN ((CASE WHEN (dbo.loads.Dispatcher1Percentage > 0) 
                         THEN 1 ELSE 0 END) + (CASE WHEN (dbo.loads.Dispatcher2Percentage > 0) THEN 1 ELSE 0 END) + (CASE WHEN (dbo.loads.Dispatcher3Percentage > 0) THEN 1 ELSE 0 END)) 
                         > 0 THEN ((CASE WHEN (dbo.loads.Dispatcher1Percentage > 0) THEN 1 ELSE 0 END) + (CASE WHEN (dbo.loads.Dispatcher2Percentage > 0) THEN 1 ELSE 0 END) + (CASE WHEN (dbo.loads.Dispatcher3Percentage > 0) 
                         THEN 1 ELSE 0 END)) ELSE 1 END AS DispatchSplitAmt,dbo.Offices.OfficeCode,ISNULL(dbo.BillFromCompanies.CompanyName,dbo.Companies.CompanyName) AS BillFromCompany,ISNULL(dbo.Loads.NoOfTrips,0) AS NoOfTrips
						 ,SalesRep.Name AS SalesRep,dbo.Loads.SalesRep2Name AS SalesRep2,dbo.Loads.SalesRep3Name AS SalesRep3
FROM            dbo.Loads INNER JOIN
                         dbo.LoadStatusTypes ON dbo.Loads.StatusTypeID = dbo.LoadStatusTypes.StatusTypeID INNER JOIN
                         dbo.Customers ON dbo.Loads.CustomerID = dbo.Customers.CustomerID INNER JOIN
                         dbo.CustomerOffices ON dbo.Customers.CustomerID = dbo.CustomerOffices.CustomerID INNER JOIN
                         dbo.Offices ON dbo.CustomerOffices.OfficeID = dbo.Offices.OfficeID INNER JOIN
                         dbo.Companies ON dbo.Offices.CompanyID = dbo.Companies.CompanyID INNER JOIN
                         dbo.LoadStops ON dbo.Loads.LoadID = dbo.LoadStops.LoadID INNER JOIN
                         dbo.LoadStopCommodities ON dbo.LoadStops.LoadStopID = dbo.LoadStopCommodities.LoadStopID INNER JOIN
                         dbo.Employees ON dbo.Loads.Dispatcher2 = dbo.Employees.EmployeeID LEFT OUTER JOIN
						 dbo.Employees AS SalesRep ON dbo.Loads.SalesRepID = SalesRep.EmployeeID LEFT OUTER JOIN
						 dbo.BillFromCompanies ON dbo.BillFromCompanies.BillFromCompanyID =  dbo.Loads.BillFromCompany
WHERE        (dbo.LoadStopCommodities.Description <> N'') OR
                         (dbo.LoadStopCommodities.Weight <> 0) OR
                         (dbo.LoadStopCommodities.CustCharges <> 0) OR
                         (dbo.LoadStopCommodities.CarrCharges <> 0) OR
                         (ISNULL(dbo.LoadStopCommodities.DirectCostTotal, 0) <> 0)
GO

GO

/****** Object:  View [dbo].[vwSalesDetailDispatcher2FlatRate]    Script Date: 05-07-2022 13:56:09 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER VIEW [dbo].[vwSalesDetailDispatcher2FlatRate]
AS
SELECT        dbo.Companies.CompanyID, dbo.Employees.Name AS Dispatcher, dbo.Loads.LoadID, dbo.Loads.LoadNumber, dbo.Loads.HasLateStop, dbo.LoadStatusTypes.StatusText, dbo.Loads.NewPickupDate AS PickupDate, 
                         dbo.Loads.NewDeliveryDate AS DeliveryDate, dbo.Loads.BillDate AS InvoiceDate, dbo.Loads.CreatedDateTime AS CreatedDate, dbo.Customers.CustomerName, dbo.Loads.CarrierName, 
                         dbo.Loads.ShipperCity + ', ' + dbo.Loads.ShipperState + ' - ' + dbo.Loads.ConsigneeCity + ', ' + dbo.Loads.ConsigneeState AS PickupCityStateDeliveryCityState, '1' AS Qty, 'Flat Rate' AS Descrition, '0' AS LBS, 
                         dbo.Loads.CustFlatRate AS [Cust Amt], dbo.Loads.CarrFlatRate AS [Carr Amt], '0' AS [Direct Cost], dbo.Loads.CustFlatRate - dbo.Loads.CarrFlatRate AS Margin, dbo.Loads.Dispatcher2Percentage AS [Comm %], 
                         (dbo.Loads.Dispatcher2Percentage * 0.01) * (dbo.Loads.CustFlatRate - dbo.Loads.CarrFlatRate) AS [Comm Amt], (dbo.Loads.TotalCustomerCharges - dbo.Loads.TotalCarrierCharges) 
                         / CASE WHEN ((CASE WHEN (dbo.loads.Dispatcher1Percentage > 0) THEN 1 ELSE 0 END) + (CASE WHEN (dbo.loads.Dispatcher2Percentage > 0) THEN 1 ELSE 0 END) + (CASE WHEN (dbo.loads.Dispatcher3Percentage > 0) 
                         THEN 1 ELSE 0 END)) > 0 THEN ((CASE WHEN (dbo.loads.Dispatcher1Percentage > 0) THEN 1 ELSE 0 END) + (CASE WHEN (dbo.loads.Dispatcher2Percentage > 0) THEN 1 ELSE 0 END) 
                         + (CASE WHEN (dbo.loads.Dispatcher3Percentage > 0) THEN 1 ELSE 0 END)) ELSE 1 END AS DispatchSplitAmt,dbo.Offices.OfficeCode,ISNULL(dbo.BillFromCompanies.CompanyName,dbo.Companies.CompanyName) AS BillFromCompany,ISNULL(dbo.Loads.NoOfTrips,0) AS NoOfTrips
						 ,SalesRep.Name AS SalesRep,dbo.Loads.SalesRep2Name AS SalesRep2,dbo.Loads.SalesRep3Name AS SalesRep3
FROM            dbo.Loads INNER JOIN
                         dbo.LoadStatusTypes ON dbo.Loads.StatusTypeID = dbo.LoadStatusTypes.StatusTypeID INNER JOIN
                         dbo.Customers ON dbo.Loads.CustomerID = dbo.Customers.CustomerID INNER JOIN
                         dbo.CustomerOffices ON dbo.Customers.CustomerID = dbo.CustomerOffices.CustomerID INNER JOIN
                         dbo.Offices ON dbo.CustomerOffices.OfficeID = dbo.Offices.OfficeID INNER JOIN
                         dbo.Companies ON dbo.Offices.CompanyID = dbo.Companies.CompanyID INNER JOIN
                         dbo.Employees ON dbo.Loads.Dispatcher2 = dbo.Employees.EmployeeID LEFT OUTER JOIN
						 dbo.Employees AS SalesRep ON dbo.Loads.SalesRepID = SalesRep.EmployeeID LEFT OUTER JOIN
						 dbo.BillFromCompanies ON dbo.BillFromCompanies.BillFromCompanyID =  dbo.Loads.BillFromCompany
WHERE        (dbo.Loads.CustFlatRate <> 0) OR
                         (dbo.Loads.CarrFlatRate <> 0)
GO


GO

/****** Object:  View [dbo].[vwSalesDetailDispatcher2MilesRate]    Script Date: 05-07-2022 13:56:56 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER VIEW [dbo].[vwSalesDetailDispatcher2MilesRate]
AS
SELECT        dbo.Companies.CompanyID, dbo.Employees.Name AS Dispatcher, dbo.Loads.LoadID, dbo.Loads.LoadNumber, dbo.Loads.HasLateStop, dbo.LoadStatusTypes.StatusText, dbo.Loads.NewPickupDate AS PickupDate, 
                         dbo.Loads.NewDeliveryDate AS DeliveryDate, dbo.Loads.BillDate AS InvoiceDate, dbo.Loads.CreatedDateTime AS CreatedDate, dbo.Customers.CustomerName, dbo.Loads.CarrierName, 
                         dbo.Loads.ShipperCity + ', ' + dbo.Loads.ShipperState + ' - ' + dbo.Loads.ConsigneeCity + ', ' + dbo.Loads.ConsigneeState AS PickupCityStateDeliveryCityState, '1' AS Qty, 'Miles Charge' AS Descrition, '0' AS LBS, 
                         dbo.Loads.CustomerRatePerMile * dbo.Loads.TotalMiles AS [Cust Amt], dbo.Loads.CarrierRatePerMile * dbo.Loads.TotalMiles AS [Carr Amt], '0' AS [Direct Cost], 
                         dbo.Loads.CustomerRatePerMile * dbo.Loads.TotalMiles - dbo.Loads.CarrierRatePerMile * dbo.Loads.TotalMiles AS Margin, dbo.Loads.Dispatcher2Percentage AS [Comm %], (dbo.Loads.Dispatcher2Percentage * 0.01) 
                         * (dbo.Loads.CustomerRatePerMile * dbo.Loads.TotalMiles - dbo.Loads.CarrierRatePerMile * dbo.Loads.TotalMiles) AS [Comm Amt], 
                         (dbo.Loads.CustomerRatePerMile * dbo.Loads.TotalMiles - dbo.Loads.CarrierRatePerMile * dbo.Loads.TotalMiles) / CASE WHEN ((CASE WHEN (dbo.loads.Dispatcher1Percentage > 0) THEN 1 ELSE 0 END) 
                         + (CASE WHEN (dbo.loads.Dispatcher2Percentage > 0) THEN 1 ELSE 0 END) + (CASE WHEN (dbo.loads.Dispatcher3Percentage > 0) THEN 1 ELSE 0 END)) > 0 THEN ((CASE WHEN (dbo.loads.Dispatcher1Percentage > 0) 
                         THEN 1 ELSE 0 END) + (CASE WHEN (dbo.loads.Dispatcher2Percentage > 0) THEN 1 ELSE 0 END) + (CASE WHEN (dbo.loads.Dispatcher3Percentage > 0) THEN 1 ELSE 0 END)) ELSE 1 END AS DispatchSplitAmt,dbo.Offices.OfficeCode,ISNULL(dbo.BillFromCompanies.CompanyName,dbo.Companies.CompanyName) AS BillFromCompany,ISNULL(dbo.Loads.NoOfTrips,0) AS NoOfTrips
						 ,SalesRep.Name AS SalesRep,dbo.Loads.SalesRep2Name AS SalesRep2,dbo.Loads.SalesRep3Name AS SalesRep3
FROM            dbo.Loads INNER JOIN
                         dbo.LoadStatusTypes ON dbo.Loads.StatusTypeID = dbo.LoadStatusTypes.StatusTypeID INNER JOIN
                         dbo.Customers ON dbo.Loads.CustomerID = dbo.Customers.CustomerID INNER JOIN
                         dbo.CustomerOffices ON dbo.Customers.CustomerID = dbo.CustomerOffices.CustomerID INNER JOIN
                         dbo.Offices ON dbo.CustomerOffices.OfficeID = dbo.Offices.OfficeID INNER JOIN
                         dbo.Companies ON dbo.Offices.CompanyID = dbo.Companies.CompanyID INNER JOIN
                         dbo.Employees ON dbo.Loads.Dispatcher2 = dbo.Employees.EmployeeID LEFT OUTER JOIN
						 dbo.Employees AS SalesRep ON dbo.Loads.SalesRepID = SalesRep.EmployeeID LEFT OUTER JOIN
						 dbo.BillFromCompanies ON dbo.BillFromCompanies.BillFromCompanyID =  dbo.Loads.BillFromCompany
WHERE        (dbo.Loads.CustomerRatePerMile * dbo.Loads.TotalMiles <> 0) OR
                         (dbo.Loads.CarrierRatePerMile * dbo.Loads.TotalMiles <> 0)
GO


GO

/****** Object:  View [dbo].[vwSalesDetailDispatcher3Cmdty]    Script Date: 05-07-2022 13:57:48 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER VIEW [dbo].[vwSalesDetailDispatcher3Cmdty]
AS
SELECT        dbo.Companies.CompanyID, dbo.Employees.Name AS Dispatcher, dbo.Loads.LoadID, dbo.Loads.LoadNumber, dbo.Loads.HasLateStop, dbo.LoadStatusTypes.StatusText, dbo.Loads.NewPickupDate AS PickupDate, 
                         dbo.Loads.NewDeliveryDate AS DeliveryDate, dbo.Loads.BillDate AS InvoiceDate, dbo.Loads.CreatedDateTime AS CreatedDate, dbo.Customers.CustomerName, dbo.Loads.CarrierName, 
                         dbo.Loads.ShipperCity + ', ' + dbo.Loads.ShipperState + ' - ' + dbo.Loads.ConsigneeCity + ', ' + dbo.Loads.ConsigneeState AS PickupCityStateDeliveryCityState, dbo.LoadStopCommodities.Qty, 
                         dbo.LoadStopCommodities.Description, dbo.LoadStopCommodities.Weight AS LBS, dbo.LoadStopCommodities.CustCharges AS [Cust Amt], dbo.LoadStopCommodities.CarrCharges AS [Carr Amt], 
                         ISNULL(dbo.LoadStopCommodities.DirectCostTotal, 0) AS [Direct Cost], dbo.LoadStopCommodities.CustCharges - dbo.LoadStopCommodities.CarrCharges - ISNULL(ISNULL(dbo.LoadStopCommodities.DirectCostTotal, 0), 0) 
                         AS Margin, dbo.Loads.Dispatcher3Percentage AS [Comm %], (dbo.Loads.Dispatcher3Percentage * 0.01) 
                         * (dbo.LoadStopCommodities.CustCharges - dbo.LoadStopCommodities.CarrCharges - ISNULL(ISNULL(dbo.LoadStopCommodities.DirectCostTotal, 0), 0)) AS [Comm Amt], 
                         (dbo.LoadStopCommodities.CustCharges - dbo.LoadStopCommodities.CarrCharges - ISNULL(ISNULL(dbo.LoadStopCommodities.DirectCostTotal, 0), 0)) / CASE WHEN ((CASE WHEN (dbo.loads.Dispatcher1Percentage > 0) 
                         THEN 1 ELSE 0 END) + (CASE WHEN (dbo.loads.Dispatcher2Percentage > 0) THEN 1 ELSE 0 END) + (CASE WHEN (dbo.loads.Dispatcher3Percentage > 0) THEN 1 ELSE 0 END)) 
                         > 0 THEN ((CASE WHEN (dbo.loads.Dispatcher1Percentage > 0) THEN 1 ELSE 0 END) + (CASE WHEN (dbo.loads.Dispatcher2Percentage > 0) THEN 1 ELSE 0 END) + (CASE WHEN (dbo.loads.Dispatcher3Percentage > 0) 
                         THEN 1 ELSE 0 END)) ELSE 1 END AS DispatchSplitAmt,dbo.Offices.OfficeCode,ISNULL(dbo.BillFromCompanies.CompanyName,dbo.Companies.CompanyName) AS BillFromCompany,ISNULL(dbo.Loads.NoOfTrips,0) AS NoOfTrips
						 ,SalesRep.Name AS SalesRep,dbo.Loads.SalesRep2Name AS SalesRep2,dbo.Loads.SalesRep3Name AS SalesRep3
FROM            dbo.Loads INNER JOIN
                         dbo.LoadStatusTypes ON dbo.Loads.StatusTypeID = dbo.LoadStatusTypes.StatusTypeID INNER JOIN
                         dbo.Customers ON dbo.Loads.CustomerID = dbo.Customers.CustomerID INNER JOIN
                         dbo.CustomerOffices ON dbo.Customers.CustomerID = dbo.CustomerOffices.CustomerID INNER JOIN
                         dbo.Offices ON dbo.CustomerOffices.OfficeID = dbo.Offices.OfficeID INNER JOIN
                         dbo.Companies ON dbo.Offices.CompanyID = dbo.Companies.CompanyID INNER JOIN
                         dbo.LoadStops ON dbo.Loads.LoadID = dbo.LoadStops.LoadID INNER JOIN
                         dbo.LoadStopCommodities ON dbo.LoadStops.LoadStopID = dbo.LoadStopCommodities.LoadStopID INNER JOIN
                         dbo.Employees ON dbo.Loads.Dispatcher3 = dbo.Employees.EmployeeID LEFT OUTER JOIN
						 dbo.Employees AS SalesRep ON dbo.Loads.SalesRepID = SalesRep.EmployeeID LEFT OUTER JOIN
						 dbo.BillFromCompanies ON dbo.BillFromCompanies.BillFromCompanyID =  dbo.Loads.BillFromCompany
WHERE        (dbo.LoadStopCommodities.Description <> N'') OR
                         (dbo.LoadStopCommodities.Weight <> 0) OR
                         (dbo.LoadStopCommodities.CustCharges <> 0) OR
                         (dbo.LoadStopCommodities.CarrCharges <> 0) OR
                         (ISNULL(dbo.LoadStopCommodities.DirectCostTotal, 0) <> 0)
GO

GO

/****** Object:  View [dbo].[vwSalesDetailDispatcher3FlatRate]    Script Date: 05-07-2022 13:58:34 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER VIEW [dbo].[vwSalesDetailDispatcher3FlatRate]
AS
SELECT        dbo.Companies.CompanyID, dbo.Employees.Name AS Dispatcher, dbo.Loads.LoadID, dbo.Loads.LoadNumber, dbo.Loads.HasLateStop, dbo.LoadStatusTypes.StatusText, dbo.Loads.NewPickupDate AS PickupDate, 
                         dbo.Loads.NewDeliveryDate AS DeliveryDate, dbo.Loads.BillDate AS InvoiceDate, dbo.Loads.CreatedDateTime AS CreatedDate, dbo.Customers.CustomerName, dbo.Loads.CarrierName, 
                         dbo.Loads.ShipperCity + ', ' + dbo.Loads.ShipperState + ' - ' + dbo.Loads.ConsigneeCity + ', ' + dbo.Loads.ConsigneeState AS PickupCityStateDeliveryCityState, '1' AS Qty, 'Flat Rate' AS Descrition, '0' AS LBS, 
                         dbo.Loads.CustFlatRate AS [Cust Amt], dbo.Loads.CarrFlatRate AS [Carr Amt], '0' AS [Direct Cost], dbo.Loads.CustFlatRate - dbo.Loads.CarrFlatRate AS Margin, dbo.Loads.Dispatcher3Percentage AS [Comm %], 
                         (dbo.Loads.Dispatcher3Percentage * 0.01) * (dbo.Loads.CustFlatRate - dbo.Loads.CarrFlatRate) AS [Comm Amt], (dbo.Loads.TotalCustomerCharges - dbo.Loads.TotalCarrierCharges) 
                         / CASE WHEN ((CASE WHEN (dbo.loads.Dispatcher1Percentage > 0) THEN 1 ELSE 0 END) + (CASE WHEN (dbo.loads.Dispatcher2Percentage > 0) THEN 1 ELSE 0 END) + (CASE WHEN (dbo.loads.Dispatcher3Percentage > 0) 
                         THEN 1 ELSE 0 END)) > 0 THEN ((CASE WHEN (dbo.loads.Dispatcher1Percentage > 0) THEN 1 ELSE 0 END) + (CASE WHEN (dbo.loads.Dispatcher2Percentage > 0) THEN 1 ELSE 0 END) 
                         + (CASE WHEN (dbo.loads.Dispatcher3Percentage > 0) THEN 1 ELSE 0 END)) ELSE 1 END AS DispatchSplitAmt,dbo.Offices.OfficeCode,ISNULL(dbo.BillFromCompanies.CompanyName,dbo.Companies.CompanyName) AS BillFromCompany,ISNULL(dbo.Loads.NoOfTrips,0) AS NoOfTrips
						 ,SalesRep.Name AS SalesRep,dbo.Loads.SalesRep2Name AS SalesRep2,dbo.Loads.SalesRep3Name AS SalesRep3
FROM            dbo.Loads INNER JOIN
                         dbo.LoadStatusTypes ON dbo.Loads.StatusTypeID = dbo.LoadStatusTypes.StatusTypeID INNER JOIN
                         dbo.Customers ON dbo.Loads.CustomerID = dbo.Customers.CustomerID INNER JOIN
                         dbo.CustomerOffices ON dbo.Customers.CustomerID = dbo.CustomerOffices.CustomerID INNER JOIN
                         dbo.Offices ON dbo.CustomerOffices.OfficeID = dbo.Offices.OfficeID INNER JOIN
                         dbo.Companies ON dbo.Offices.CompanyID = dbo.Companies.CompanyID INNER JOIN
                         dbo.Employees ON dbo.Loads.Dispatcher3 = dbo.Employees.EmployeeID LEFT OUTER JOIN
						 dbo.Employees AS SalesRep ON dbo.Loads.SalesRepID = SalesRep.EmployeeID LEFT OUTER JOIN
						 dbo.BillFromCompanies ON dbo.BillFromCompanies.BillFromCompanyID =  dbo.Loads.BillFromCompany
WHERE        (dbo.Loads.CustFlatRate <> 0) OR
                         (dbo.Loads.CarrFlatRate <> 0)
GO


GO

/****** Object:  View [dbo].[vwSalesDetailDispatcher3MilesRate]    Script Date: 05-07-2022 13:59:18 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER VIEW [dbo].[vwSalesDetailDispatcher3MilesRate]
AS
SELECT        dbo.Companies.CompanyID, dbo.Employees.Name AS Dispatcher, dbo.Loads.LoadID, dbo.Loads.LoadNumber, dbo.Loads.HasLateStop, dbo.LoadStatusTypes.StatusText, dbo.Loads.NewPickupDate AS PickupDate, 
                         dbo.Loads.NewDeliveryDate AS DeliveryDate, dbo.Loads.BillDate AS InvoiceDate, dbo.Loads.CreatedDateTime AS CreatedDate, dbo.Customers.CustomerName, dbo.Loads.CarrierName, 
                         dbo.Loads.ShipperCity + ', ' + dbo.Loads.ShipperState + ' - ' + dbo.Loads.ConsigneeCity + ', ' + dbo.Loads.ConsigneeState AS PickupCityStateDeliveryCityState, '1' AS Qty, 'Miles Charge' AS Descrition, '0' AS LBS, 
                         dbo.Loads.CustomerRatePerMile * dbo.Loads.TotalMiles AS [Cust Amt], dbo.Loads.CarrierRatePerMile * dbo.Loads.TotalMiles AS [Carr Amt], '0' AS [Direct Cost], 
                         dbo.Loads.CustomerRatePerMile * dbo.Loads.TotalMiles - dbo.Loads.CarrierRatePerMile * dbo.Loads.TotalMiles AS Margin, dbo.Loads.Dispatcher3Percentage AS [Comm %], (dbo.Loads.Dispatcher3Percentage * 0.01) 
                         * (dbo.Loads.CustomerRatePerMile * dbo.Loads.TotalMiles - dbo.Loads.CarrierRatePerMile * dbo.Loads.TotalMiles) AS [Comm Amt], 
                         (dbo.Loads.CustomerRatePerMile * dbo.Loads.TotalMiles - dbo.Loads.CarrierRatePerMile * dbo.Loads.TotalMiles) / CASE WHEN ((CASE WHEN (dbo.loads.Dispatcher1Percentage > 0) THEN 1 ELSE 0 END) 
                         + (CASE WHEN (dbo.loads.Dispatcher2Percentage > 0) THEN 1 ELSE 0 END) + (CASE WHEN (dbo.loads.Dispatcher3Percentage > 0) THEN 1 ELSE 0 END)) > 0 THEN ((CASE WHEN (dbo.loads.Dispatcher1Percentage > 0) 
                         THEN 1 ELSE 0 END) + (CASE WHEN (dbo.loads.Dispatcher2Percentage > 0) THEN 1 ELSE 0 END) + (CASE WHEN (dbo.loads.Dispatcher3Percentage > 0) THEN 1 ELSE 0 END)) ELSE 1 END AS DispatchSplitAmt,dbo.Offices.OfficeCode,ISNULL(dbo.BillFromCompanies.CompanyName,dbo.Companies.CompanyName) AS BillFromCompany,ISNULL(dbo.Loads.NoOfTrips,0) AS NoOfTrips
						 ,SalesRep.Name AS SalesRep,dbo.Loads.SalesRep2Name AS SalesRep2,dbo.Loads.SalesRep3Name AS SalesRep3
FROM            dbo.Loads INNER JOIN
                         dbo.LoadStatusTypes ON dbo.Loads.StatusTypeID = dbo.LoadStatusTypes.StatusTypeID INNER JOIN
                         dbo.Customers ON dbo.Loads.CustomerID = dbo.Customers.CustomerID INNER JOIN
                         dbo.CustomerOffices ON dbo.Customers.CustomerID = dbo.CustomerOffices.CustomerID INNER JOIN
                         dbo.Offices ON dbo.CustomerOffices.OfficeID = dbo.Offices.OfficeID INNER JOIN
                         dbo.Companies ON dbo.Offices.CompanyID = dbo.Companies.CompanyID INNER JOIN
                         dbo.Employees ON dbo.Loads.Dispatcher3 = dbo.Employees.EmployeeID LEFT OUTER JOIN
						 dbo.Employees AS SalesRep ON dbo.Loads.SalesRepID = SalesRep.EmployeeID LEFT OUTER JOIN
						 dbo.BillFromCompanies ON dbo.BillFromCompanies.BillFromCompanyID =  dbo.Loads.BillFromCompany
WHERE        (dbo.Loads.CustomerRatePerMile * dbo.Loads.TotalMiles <> 0) OR
                         (dbo.Loads.CarrierRatePerMile * dbo.Loads.TotalMiles <> 0)
GO




GO

/****** Object:  View [dbo].[vwSalesDetailDispatcher]    Script Date: 05-07-2022 14:00:04 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER   VIEW [dbo].[vwSalesDetailDispatcher]
AS
SELECT        *
FROM            vwSalesDetailDispatcher1Cmdty
UNION ALL

SELECT        *
FROM            vwSalesDetailDispatcher2Cmdty
UNION ALL

SELECT        *
FROM            vwSalesDetailDispatcher3Cmdty
UNION ALL

SELECT        *
FROM            vwSalesDetailDispatcher1FlatRate
UNION ALL

SELECT        *
FROM            vwSalesDetailDispatcher2FlatRate
UNION ALL

SELECT        *
FROM            vwSalesDetailDispatcher3FlatRate
UNION ALL

SELECT        *
FROM            vwSalesDetailDispatcher1MilesRate
UNION ALL

SELECT        *
FROM            vwSalesDetailDispatcher2MilesRate
UNION ALL

SELECT        *
FROM            vwSalesDetailDispatcher3MilesRate

GO

GO

/****** Object:  View [dbo].[vwSalesDetailSalesRep1Cmdty]    Script Date: 05-07-2022 14:00:23 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER   VIEW [dbo].[vwSalesDetailSalesRep1Cmdty]
AS
SELECT        dbo.Companies.CompanyID, ISNULL(Employees_1.Name, dbo.Employees.Name) AS SalesRep, dbo.Loads.LoadID, dbo.Loads.LoadNumber, dbo.Loads.HasLateStop, dbo.LoadStatusTypes.StatusText, dbo.Loads.NewPickupDate AS PickupDate, dbo.Loads.NewDeliveryDate AS DeliveryDate, dbo.Loads.BillDate AS InvoiceDate, dbo.Loads.CreatedDateTime AS CreatedDate, dbo.Customers.CustomerName, dbo.Loads.CarrierName, 
                         dbo.Loads.ShipperCity + ', ' + dbo.Loads.ShipperState + ' - ' + dbo.Loads.ConsigneeCity + ', ' + dbo.Loads.ConsigneeState AS PickupCityStateDeliveryCityState, dbo.LoadStopCommodities.Qty, 
                         dbo.LoadStopCommodities.Description, dbo.LoadStopCommodities.Weight AS LBS, dbo.LoadStopCommodities.CustCharges AS [Cust Amt], dbo.LoadStopCommodities.CarrCharges AS [Carr Amt], 
                         ISNULL(dbo.LoadStopCommodities.DirectCostTotal,0) AS [Direct Cost], dbo.LoadStopCommodities.CustCharges - dbo.LoadStopCommodities.CarrCharges - ISNULL(ISNULL(dbo.LoadStopCommodities.DirectCostTotal,0), 0) AS Margin, 
                         CASE WHEN ISNULL(Employees_1.Name, '0') <> '0' THEN dbo.loads.SalesRep1Percentage ELSE dbo.employees.salescommission END AS [Comm %], ((CASE WHEN ISNULL(Employees_1.Name, '0') 
                         <> '0' THEN dbo.loads.SalesRep1Percentage ELSE dbo.employees.salescommission END) * 0.01) 
                         * (dbo.LoadStopCommodities.CustCharges - dbo.LoadStopCommodities.CarrCharges - ISNULL(ISNULL(dbo.LoadStopCommodities.DirectCostTotal,0), 0)) AS [Comm Amt],dbo.Offices.OfficeCode,ISNULL(dbo.BillFromCompanies.CompanyName,dbo.Companies.CompanyName) AS BillFromCompany,ISNULL(dbo.Loads.NoOfTrips,0) AS NoOfTrips
						 ,Dispatcher.Name AS Dispatcher,dbo.Loads.Dispatcher2Name AS Dispatcher2,dbo.Loads.Dispatcher3Name AS Dispatcher3
FROM            dbo.Loads INNER JOIN
                         dbo.LoadStatusTypes ON dbo.Loads.StatusTypeID = dbo.LoadStatusTypes.StatusTypeID INNER JOIN
                         dbo.Customers ON dbo.Loads.CustomerID = dbo.Customers.CustomerID INNER JOIN
                         dbo.CustomerOffices ON dbo.Customers.CustomerID = dbo.CustomerOffices.CustomerID INNER JOIN
                         dbo.Offices ON dbo.CustomerOffices.OfficeID = dbo.Offices.OfficeID INNER JOIN
                         dbo.Companies ON dbo.Offices.CompanyID = dbo.Companies.CompanyID INNER JOIN
                         dbo.Employees ON dbo.Loads.SalesRepID = dbo.Employees.EmployeeID INNER JOIN
                         dbo.LoadStops ON dbo.Loads.LoadID = dbo.LoadStops.LoadID INNER JOIN
                         dbo.LoadStopCommodities ON dbo.LoadStops.LoadStopID = dbo.LoadStopCommodities.LoadStopID LEFT OUTER JOIN
                         dbo.Employees AS Employees_1 ON dbo.Loads.SalesRep1 = Employees_1.EmployeeID LEFT OUTER JOIN
						 dbo.Employees AS Dispatcher ON dbo.Loads.DispatcherID = Dispatcher.EmployeeID LEFT OUTER JOIN
						 dbo.BillFromCompanies ON dbo.BillFromCompanies.BillFromCompanyID =  dbo.Loads.BillFromCompany
WHERE        (dbo.LoadStopCommodities.Description <> N'') OR
                         (dbo.LoadStopCommodities.Weight <> 0) OR
                         (dbo.LoadStopCommodities.CustCharges <> 0) OR
                         (dbo.LoadStopCommodities.CarrCharges <> 0) OR
                         (ISNULL(dbo.LoadStopCommodities.DirectCostTotal,0) <> 0)
GO


GO

/****** Object:  View [dbo].[vwSalesDetailSalesRep1FlatRate]    Script Date: 05-07-2022 14:01:58 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER   VIEW [dbo].[vwSalesDetailSalesRep1FlatRate]
AS
SELECT        dbo.Companies.CompanyID, ISNULL(Employees_1.Name, dbo.Employees.Name) AS SalesRep, dbo.Loads.LoadID, dbo.Loads.LoadNumber, dbo.Loads.HasLateStop, dbo.LoadStatusTypes.StatusText, dbo.Loads.NewPickupDate AS PickupDate, dbo.Loads.NewDeliveryDate AS DeliveryDate, dbo.Loads.BillDate AS InvoiceDate, dbo.Loads.CreatedDateTime AS CreatedDate, dbo.Customers.CustomerName, dbo.Loads.CarrierName, 
                         dbo.Loads.ShipperCity + ', ' + dbo.Loads.ShipperState + ' - ' + dbo.Loads.ConsigneeCity + ', ' + dbo.Loads.ConsigneeState AS PickupCityStateDeliveryCityState, '1' AS Qty, 'Flat Rate' AS Descrition, '0' AS LBS, 
                         dbo.Loads.CustFlatRate AS [Cust Amt], dbo.Loads.CarrFlatRate AS [Carr Amt], '0' AS [Direct Cost], dbo.Loads.CustFlatRate - dbo.Loads.CarrFlatRate AS Margin, CASE WHEN ISNULL(Employees_1.Name, '0') 
                         <> '0' THEN dbo.loads.SalesRep1Percentage ELSE dbo.employees.salescommission END AS [Comm %], ((CASE WHEN ISNULL(Employees_1.Name, '0') 
                         <> '0' THEN dbo.loads.SalesRep1Percentage ELSE dbo.employees.salescommission END) * .01) * (dbo.Loads.CustFlatRate - dbo.Loads.CarrFlatRate) AS [Comm Amt],dbo.Offices.OfficeCode,ISNULL(dbo.BillFromCompanies.CompanyName,dbo.Companies.CompanyName) AS BillFromCompany,ISNULL(dbo.Loads.NoOfTrips,0) AS NoOfTrips
						 ,Dispatcher.Name AS Dispatcher,dbo.Loads.Dispatcher2Name AS Dispatcher2,dbo.Loads.Dispatcher3Name AS Dispatcher3
FROM            dbo.Loads INNER JOIN
                         dbo.LoadStatusTypes ON dbo.Loads.StatusTypeID = dbo.LoadStatusTypes.StatusTypeID INNER JOIN
                         dbo.Customers ON dbo.Loads.CustomerID = dbo.Customers.CustomerID INNER JOIN
                         dbo.CustomerOffices ON dbo.Customers.CustomerID = dbo.CustomerOffices.CustomerID INNER JOIN
                         dbo.Offices ON dbo.CustomerOffices.OfficeID = dbo.Offices.OfficeID INNER JOIN
                         dbo.Companies ON dbo.Offices.CompanyID = dbo.Companies.CompanyID INNER JOIN
                         dbo.Employees ON dbo.Loads.SalesRepID = dbo.Employees.EmployeeID LEFT OUTER JOIN
                         dbo.Employees AS Employees_1 ON dbo.Loads.SalesRep1 = Employees_1.EmployeeID LEFT OUTER JOIN
						 dbo.Employees AS Dispatcher ON dbo.Loads.DispatcherID = Dispatcher.EmployeeID LEFT OUTER JOIN
						 dbo.BillFromCompanies ON dbo.BillFromCompanies.BillFromCompanyID =  dbo.Loads.BillFromCompany
WHERE        (dbo.Loads.CarrFlatRate <> 0) OR
                         (dbo.Loads.CustFlatRate <> 0)
GO


GO

/****** Object:  View [dbo].[vwSalesDetailSalesRep1MilesRate]    Script Date: 05-07-2022 14:02:35 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER   VIEW [dbo].[vwSalesDetailSalesRep1MilesRate]
AS
SELECT        dbo.Companies.CompanyID, ISNULL(Employees_1.Name, dbo.Employees.Name) AS SalesRep, dbo.Loads.LoadID, dbo.Loads.LoadNumber, dbo.Loads.HasLateStop, dbo.LoadStatusTypes.StatusText, dbo.Loads.NewPickupDate AS PickupDate, dbo.Loads.NewDeliveryDate AS DeliveryDate, dbo.Loads.BillDate AS InvoiceDate, dbo.Loads.CreatedDateTime AS CreatedDate, dbo.Customers.CustomerName, dbo.Loads.CarrierName, 
                         dbo.Loads.ShipperCity + ', ' + dbo.Loads.ShipperState + ' - ' + dbo.Loads.ConsigneeCity + ', ' + dbo.Loads.ConsigneeState AS PickupCityStateDeliveryCityState, '1' AS Qty, 'Miles Charge' AS Descrition, '0' AS LBS, 
                         dbo.Loads.CustomerRatePerMile * dbo.Loads.TotalMiles AS [Cust Amt], dbo.Loads.CarrierRatePerMile * dbo.Loads.TotalMiles AS [Carr Amt], '0' AS [Direct Cost], 
                         dbo.Loads.CustomerRatePerMile * dbo.Loads.TotalMiles - dbo.Loads.CarrierRatePerMile * dbo.Loads.TotalMiles AS Margin, CASE WHEN ISNULL(Employees_1.Name, '0') 
                         <> '0' THEN dbo.loads.SalesRep1Percentage ELSE dbo.employees.salescommission END AS [Comm %], ((CASE WHEN ISNULL(Employees_1.Name, '0') 
                         <> '0' THEN dbo.loads.SalesRep1Percentage ELSE dbo.employees.salescommission END) * .01) * (dbo.Loads.CustomerRatePerMile * dbo.Loads.TotalMiles - dbo.Loads.CarrierRatePerMile * dbo.Loads.TotalMiles) 
                         AS [Comm Amt],dbo.Offices.OfficeCode,ISNULL(dbo.BillFromCompanies.CompanyName,dbo.Companies.CompanyName) AS BillFromCompany,ISNULL(dbo.Loads.NoOfTrips,0) AS NoOfTrips
						 ,Dispatcher.Name AS Dispatcher,dbo.Loads.Dispatcher2Name AS Dispatcher2,dbo.Loads.Dispatcher3Name AS Dispatcher3
FROM            dbo.Loads INNER JOIN
                         dbo.LoadStatusTypes ON dbo.Loads.StatusTypeID = dbo.LoadStatusTypes.StatusTypeID INNER JOIN
                         dbo.Customers ON dbo.Loads.CustomerID = dbo.Customers.CustomerID INNER JOIN
                         dbo.CustomerOffices ON dbo.Customers.CustomerID = dbo.CustomerOffices.CustomerID INNER JOIN
                         dbo.Offices ON dbo.CustomerOffices.OfficeID = dbo.Offices.OfficeID INNER JOIN
                         dbo.Companies ON dbo.Offices.CompanyID = dbo.Companies.CompanyID INNER JOIN
                         dbo.Employees ON dbo.Loads.SalesRepID = dbo.Employees.EmployeeID LEFT OUTER JOIN
                         dbo.Employees AS Employees_1 ON dbo.Loads.SalesRep1 = Employees_1.EmployeeID LEFT OUTER JOIN
						 dbo.Employees AS Dispatcher ON dbo.Loads.DispatcherID = Dispatcher.EmployeeID LEFT OUTER JOIN
						 dbo.BillFromCompanies ON dbo.BillFromCompanies.BillFromCompanyID =  dbo.Loads.BillFromCompany
WHERE        (dbo.Loads.CustomerRatePerMile * dbo.Loads.TotalMiles <> 0) OR
                         (dbo.Loads.CarrierRatePerMile * dbo.Loads.TotalMiles <> 0)
GO

GO

/****** Object:  View [dbo].[vwSalesDetailSalesRep2Cmdty]    Script Date: 05-07-2022 14:04:21 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER   VIEW [dbo].[vwSalesDetailSalesRep2Cmdty]
AS
SELECT        dbo.Companies.CompanyID, dbo.Employees.Name AS SalesRep, dbo.Loads.LoadID, dbo.Loads.LoadNumber, dbo.Loads.HasLateStop, dbo.LoadStatusTypes.StatusText, dbo.Loads.NewPickupDate AS PickupDate, dbo.Loads.NewDeliveryDate AS DeliveryDate, dbo.Loads.BillDate AS InvoiceDate, dbo.Loads.CreatedDateTime AS CreatedDate, dbo.Customers.CustomerName, dbo.Loads.CarrierName, 
                         dbo.Loads.ShipperCity + ', ' + dbo.Loads.ShipperState + ' - ' + dbo.Loads.ConsigneeCity + ', ' + dbo.Loads.ConsigneeState AS PickupCityStateDeliveryCityState, dbo.LoadStopCommodities.Qty, 
                         dbo.LoadStopCommodities.Description, dbo.LoadStopCommodities.Weight AS LBS, dbo.LoadStopCommodities.CustCharges AS [Cust Amt], dbo.LoadStopCommodities.CarrCharges AS [Carr Amt], 
                         ISNULL(dbo.LoadStopCommodities.DirectCostTotal,0) AS [Direct Cost], dbo.LoadStopCommodities.CustCharges - dbo.LoadStopCommodities.CarrCharges - ISNULL(ISNULL(dbo.LoadStopCommodities.DirectCostTotal,0), 0) AS Margin, 
                         dbo.Loads.SalesRep2Percentage AS [Comm %], (dbo.Loads.SalesRep2Percentage * 0.01) 
                         * (dbo.LoadStopCommodities.CustCharges - dbo.LoadStopCommodities.CarrCharges - ISNULL(ISNULL(dbo.LoadStopCommodities.DirectCostTotal,0), 0)) AS [Comm Amt],dbo.Offices.OfficeCode,ISNULL(dbo.BillFromCompanies.CompanyName,dbo.Companies.CompanyName) AS BillFromCompany,ISNULL(dbo.Loads.NoOfTrips,0) AS NoOfTrips
						 ,Dispatcher.Name AS Dispatcher,dbo.Loads.Dispatcher2Name AS Dispatcher2,dbo.Loads.Dispatcher3Name AS Dispatcher3
FROM            dbo.Loads INNER JOIN
                         dbo.LoadStatusTypes ON dbo.Loads.StatusTypeID = dbo.LoadStatusTypes.StatusTypeID INNER JOIN
                         dbo.Customers ON dbo.Loads.CustomerID = dbo.Customers.CustomerID INNER JOIN
                         dbo.CustomerOffices ON dbo.Customers.CustomerID = dbo.CustomerOffices.CustomerID INNER JOIN
                         dbo.Offices ON dbo.CustomerOffices.OfficeID = dbo.Offices.OfficeID INNER JOIN
                         dbo.Companies ON dbo.Offices.CompanyID = dbo.Companies.CompanyID INNER JOIN
                         dbo.LoadStops ON dbo.Loads.LoadID = dbo.LoadStops.LoadID INNER JOIN
                         dbo.LoadStopCommodities ON dbo.LoadStops.LoadStopID = dbo.LoadStopCommodities.LoadStopID INNER JOIN
                         dbo.Employees ON dbo.Loads.SalesRep2 = dbo.Employees.EmployeeID LEFT OUTER JOIN
						 dbo.Employees AS Dispatcher ON dbo.Loads.DispatcherID = Dispatcher.EmployeeID LEFT OUTER JOIN
						 dbo.BillFromCompanies ON dbo.BillFromCompanies.BillFromCompanyID =  dbo.Loads.BillFromCompany
WHERE        (dbo.LoadStopCommodities.Description <> N'') OR
                         (dbo.LoadStopCommodities.Weight <> 0) OR
                         (dbo.LoadStopCommodities.CustCharges <> 0) OR
                         (dbo.LoadStopCommodities.CarrCharges <> 0) OR
                         (ISNULL(dbo.LoadStopCommodities.DirectCostTotal,0) <> 0)
GO
GO

/****** Object:  View [dbo].[vwSalesDetailSalesRep2FlatRate]    Script Date: 05-07-2022 14:05:31 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




ALTER   VIEW [dbo].[vwSalesDetailSalesRep2FlatRate]
AS
SELECT        dbo.Companies.CompanyID, dbo.Employees.Name AS SalesRep, dbo.Loads.LoadID, dbo.Loads.LoadNumber, dbo.Loads.HasLateStop, dbo.LoadStatusTypes.StatusText, dbo.Loads.NewPickupDate AS PickupDate, dbo.Loads.NewDeliveryDate AS DeliveryDate, dbo.Loads.BillDate AS InvoiceDate, dbo.Loads.CreatedDateTime AS CreatedDate, dbo.Customers.CustomerName, dbo.Loads.CarrierName, 
                         dbo.Loads.ShipperCity + ', ' + dbo.Loads.ShipperState + ' - ' + dbo.Loads.ConsigneeCity + ', ' + dbo.Loads.ConsigneeState AS PickupCityStateDeliveryCityState, '1' AS Qty, 'Flat Rate' AS Descrition, '0' AS LBS, 
                         dbo.Loads.CustFlatRate AS [Cust Amt], dbo.Loads.CarrFlatRate AS [Carr Amt], '0' AS [Direct Cost], dbo.Loads.CustFlatRate - dbo.Loads.CarrFlatRate AS Margin, dbo.Loads.SalesRep2Percentage AS [Comm %], 
                         (dbo.Loads.SalesRep2Percentage * 0.01) * (dbo.Loads.CustFlatRate - dbo.Loads.CarrFlatRate) AS [Comm Amt],dbo.Offices.OfficeCode,ISNULL(dbo.BillFromCompanies.CompanyName,dbo.Companies.CompanyName) AS BillFromCompany,ISNULL(dbo.Loads.NoOfTrips,0) AS NoOfTrips
						 ,Dispatcher.Name AS Dispatcher,dbo.Loads.Dispatcher2Name AS Dispatcher2,dbo.Loads.Dispatcher3Name AS Dispatcher3
FROM            dbo.Loads INNER JOIN
                         dbo.LoadStatusTypes ON dbo.Loads.StatusTypeID = dbo.LoadStatusTypes.StatusTypeID INNER JOIN
                         dbo.Customers ON dbo.Loads.CustomerID = dbo.Customers.CustomerID INNER JOIN
                         dbo.CustomerOffices ON dbo.Customers.CustomerID = dbo.CustomerOffices.CustomerID INNER JOIN
                         dbo.Offices ON dbo.CustomerOffices.OfficeID = dbo.Offices.OfficeID INNER JOIN
                         dbo.Companies ON dbo.Offices.CompanyID = dbo.Companies.CompanyID INNER JOIN
                         dbo.Employees ON dbo.Loads.SalesRep2 = dbo.Employees.EmployeeID LEFT OUTER JOIN
						 dbo.Employees AS Dispatcher ON dbo.Loads.DispatcherID = Dispatcher.EmployeeID LEFT OUTER JOIN
						 dbo.BillFromCompanies ON dbo.BillFromCompanies.BillFromCompanyID =  dbo.Loads.BillFromCompany
WHERE        (dbo.Loads.CustFlatRate <> 0) OR
                         (dbo.Loads.CarrFlatRate <> 0)
GO



GO

/****** Object:  View [dbo].[vwSalesDetailSalesRep2MilesRate]    Script Date: 05-07-2022 14:06:30 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




ALTER   VIEW [dbo].[vwSalesDetailSalesRep2MilesRate]
AS
SELECT        dbo.Companies.CompanyID, dbo.Employees.Name AS SalesRep, dbo.Loads.LoadID, dbo.Loads.LoadNumber, dbo.Loads.HasLateStop, dbo.LoadStatusTypes.StatusText, dbo.Loads.NewPickupDate AS PickupDate, dbo.Loads.NewDeliveryDate AS DeliveryDate, dbo.Loads.BillDate AS InvoiceDate, dbo.Loads.CreatedDateTime AS CreatedDate, dbo.Customers.CustomerName, dbo.Loads.CarrierName, 
                         dbo.Loads.ShipperCity + ', ' + dbo.Loads.ShipperState + ' - ' + dbo.Loads.ConsigneeCity + ', ' + dbo.Loads.ConsigneeState AS PickupCityStateDeliveryCityState, '1' AS Qty, 'Miles Charge' AS Descrition, '0' AS LBS, 
                         dbo.Loads.CustomerRatePerMile * dbo.Loads.TotalMiles AS [Cust Amt], dbo.Loads.CarrierRatePerMile * dbo.Loads.TotalMiles AS [Carr Amt], '0' AS [Direct Cost], 
                         dbo.Loads.CustomerRatePerMile * dbo.Loads.TotalMiles - dbo.Loads.CarrierRatePerMile * dbo.Loads.TotalMiles AS Margin, dbo.Loads.SalesRep2Percentage AS [Comm %], (dbo.Loads.SalesRep2Percentage * 0.01) 
                         * (dbo.Loads.CustomerRatePerMile * dbo.Loads.TotalMiles - dbo.Loads.CarrierRatePerMile * dbo.Loads.TotalMiles) AS [Comm Amt],dbo.Offices.OfficeCode,ISNULL(dbo.BillFromCompanies.CompanyName,dbo.Companies.CompanyName) AS BillFromCompany,ISNULL(dbo.Loads.NoOfTrips,0) AS NoOfTrips
						 ,Dispatcher.Name AS Dispatcher,dbo.Loads.Dispatcher2Name AS Dispatcher2,dbo.Loads.Dispatcher3Name AS Dispatcher3
						 FROM            dbo.Loads INNER JOIN
                         dbo.LoadStatusTypes ON dbo.Loads.StatusTypeID = dbo.LoadStatusTypes.StatusTypeID INNER JOIN
                         dbo.Customers ON dbo.Loads.CustomerID = dbo.Customers.CustomerID INNER JOIN
                         dbo.CustomerOffices ON dbo.Customers.CustomerID = dbo.CustomerOffices.CustomerID INNER JOIN
                         dbo.Offices ON dbo.CustomerOffices.OfficeID = dbo.Offices.OfficeID INNER JOIN
                         dbo.Companies ON dbo.Offices.CompanyID = dbo.Companies.CompanyID INNER JOIN
                         dbo.Employees ON dbo.Loads.SalesRep2 = dbo.Employees.EmployeeID LEFT OUTER JOIN
						 dbo.Employees AS Dispatcher ON dbo.Loads.DispatcherID = Dispatcher.EmployeeID LEFT OUTER JOIN
						 dbo.BillFromCompanies ON dbo.BillFromCompanies.BillFromCompanyID =  dbo.Loads.BillFromCompany
WHERE        (dbo.Loads.CustomerRatePerMile * dbo.Loads.TotalMiles <> 0) OR
                         (dbo.Loads.CarrierRatePerMile * dbo.Loads.TotalMiles <> 0)
GO


GO

/****** Object:  View [dbo].[vwSalesDetailSalesRep3Cmdty]    Script Date: 05-07-2022 14:07:08 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER   VIEW [dbo].[vwSalesDetailSalesRep3Cmdty]
AS
SELECT        dbo.Companies.CompanyID, dbo.Employees.Name AS SalesRep, dbo.Loads.LoadID, dbo.Loads.LoadNumber, dbo.Loads.HasLateStop, dbo.LoadStatusTypes.StatusText, dbo.Loads.NewPickupDate AS PickupDate, dbo.Loads.NewDeliveryDate AS DeliveryDate, dbo.Loads.BillDate AS InvoiceDate, dbo.Loads.CreatedDateTime AS CreatedDate, dbo.Customers.CustomerName, dbo.Loads.CarrierName, 
                         dbo.Loads.ShipperCity + ', ' + dbo.Loads.ShipperState + ' - ' + dbo.Loads.ConsigneeCity + ', ' + dbo.Loads.ConsigneeState AS PickupCityStateDeliveryCityState, dbo.LoadStopCommodities.Qty, 
                         dbo.LoadStopCommodities.Description, dbo.LoadStopCommodities.Weight AS LBS, dbo.LoadStopCommodities.CustCharges AS [Cust Amt], dbo.LoadStopCommodities.CarrCharges AS [Carr Amt], 
                         ISNULL(dbo.LoadStopCommodities.DirectCostTotal,0) AS [Direct Cost], dbo.LoadStopCommodities.CustCharges - dbo.LoadStopCommodities.CarrCharges - ISNULL(ISNULL(dbo.LoadStopCommodities.DirectCostTotal,0), 0) AS Margin, 
                         dbo.Loads.SalesRep3Percentage AS [Comm %], (dbo.Loads.SalesRep3Percentage * 0.01) 
                         * (dbo.LoadStopCommodities.CustCharges - dbo.LoadStopCommodities.CarrCharges - ISNULL(ISNULL(dbo.LoadStopCommodities.DirectCostTotal,0), 0)) AS [Comm Amt],dbo.Offices.OfficeCode,ISNULL(dbo.BillFromCompanies.CompanyName,dbo.Companies.CompanyName) AS BillFromCompany,ISNULL(dbo.Loads.NoOfTrips,0) AS NoOfTrips
						 ,Dispatcher.Name AS Dispatcher,dbo.Loads.Dispatcher2Name AS Dispatcher2,dbo.Loads.Dispatcher3Name AS Dispatcher3
FROM            dbo.Loads INNER JOIN
                         dbo.LoadStatusTypes ON dbo.Loads.StatusTypeID = dbo.LoadStatusTypes.StatusTypeID INNER JOIN
                         dbo.Customers ON dbo.Loads.CustomerID = dbo.Customers.CustomerID INNER JOIN
                         dbo.CustomerOffices ON dbo.Customers.CustomerID = dbo.CustomerOffices.CustomerID INNER JOIN
                         dbo.Offices ON dbo.CustomerOffices.OfficeID = dbo.Offices.OfficeID INNER JOIN
                         dbo.Companies ON dbo.Offices.CompanyID = dbo.Companies.CompanyID INNER JOIN
                         dbo.LoadStops ON dbo.Loads.LoadID = dbo.LoadStops.LoadID INNER JOIN
                         dbo.LoadStopCommodities ON dbo.LoadStops.LoadStopID = dbo.LoadStopCommodities.LoadStopID INNER JOIN
                         dbo.Employees ON dbo.Loads.SalesRep3 = dbo.Employees.EmployeeID LEFT OUTER JOIN
						 dbo.Employees AS Dispatcher ON dbo.Loads.DispatcherID = Dispatcher.EmployeeID LEFT OUTER JOIN
						 dbo.BillFromCompanies ON dbo.BillFromCompanies.BillFromCompanyID =  dbo.Loads.BillFromCompany
WHERE        (dbo.LoadStopCommodities.Description <> N'') OR
                         (dbo.LoadStopCommodities.Weight <> 0) OR
                         (dbo.LoadStopCommodities.CustCharges <> 0) OR
                         (dbo.LoadStopCommodities.CarrCharges <> 0) OR
                         (ISNULL(dbo.LoadStopCommodities.DirectCostTotal,0) <> 0)
GO

GO

/****** Object:  View [dbo].[vwSalesDetailSalesRep3FlatRate]    Script Date: 05-07-2022 14:07:54 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER   VIEW [dbo].[vwSalesDetailSalesRep3FlatRate]
AS
SELECT        dbo.Companies.CompanyID, dbo.Employees.Name AS SalesRep, dbo.Loads.LoadID, dbo.Loads.LoadNumber, dbo.Loads.HasLateStop, dbo.LoadStatusTypes.StatusText, dbo.Loads.NewPickupDate AS PickupDate, dbo.Loads.NewDeliveryDate AS DeliveryDate, dbo.Loads.BillDate AS InvoiceDate, dbo.Loads.CreatedDateTime AS CreatedDate, dbo.Customers.CustomerName, dbo.Loads.CarrierName, 
                         dbo.Loads.ShipperCity + ', ' + dbo.Loads.ShipperState + ' - ' + dbo.Loads.ConsigneeCity + ', ' + dbo.Loads.ConsigneeState AS PickupCityStateDeliveryCityState, '1' AS Qty, 'Flat Rate' AS Descrition, '0' AS LBS, 
                         dbo.Loads.CustFlatRate AS [Cust Amt], dbo.Loads.CarrFlatRate AS [Carr Amt], '0' AS [Direct Cost], dbo.Loads.CustFlatRate - dbo.Loads.CarrFlatRate AS Margin, dbo.Loads.SalesRep3Percentage AS [Comm %], 
                         (dbo.Loads.SalesRep3Percentage * 0.01) * (dbo.Loads.CustFlatRate - dbo.Loads.CarrFlatRate) AS [Comm Amt],dbo.Offices.OfficeCode,ISNULL(dbo.BillFromCompanies.CompanyName,dbo.Companies.CompanyName) AS BillFromCompany,ISNULL(dbo.Loads.NoOfTrips,0) AS NoOfTrips
						 ,Dispatcher.Name AS Dispatcher,dbo.Loads.Dispatcher2Name AS Dispatcher2,dbo.Loads.Dispatcher3Name AS Dispatcher3
FROM            dbo.Loads INNER JOIN
                         dbo.LoadStatusTypes ON dbo.Loads.StatusTypeID = dbo.LoadStatusTypes.StatusTypeID INNER JOIN
                         dbo.Customers ON dbo.Loads.CustomerID = dbo.Customers.CustomerID INNER JOIN
                         dbo.CustomerOffices ON dbo.Customers.CustomerID = dbo.CustomerOffices.CustomerID INNER JOIN
                         dbo.Offices ON dbo.CustomerOffices.OfficeID = dbo.Offices.OfficeID INNER JOIN
                         dbo.Companies ON dbo.Offices.CompanyID = dbo.Companies.CompanyID INNER JOIN
                         dbo.Employees ON dbo.Loads.SalesRep3 = dbo.Employees.EmployeeID LEFT OUTER JOIN
						 dbo.Employees AS Dispatcher ON dbo.Loads.DispatcherID = Dispatcher.EmployeeID LEFT OUTER JOIN
						 dbo.BillFromCompanies ON dbo.BillFromCompanies.BillFromCompanyID =  dbo.Loads.BillFromCompany
WHERE        (dbo.Loads.CustFlatRate <> 0) OR
                         (dbo.Loads.CarrFlatRate <> 0)
GO

GO

/****** Object:  View [dbo].[vwSalesDetailSalesRep3MilesRate]    Script Date: 05-07-2022 14:08:30 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER   VIEW [dbo].[vwSalesDetailSalesRep3MilesRate]
AS
SELECT        dbo.Companies.CompanyID, dbo.Employees.Name AS SalesRep, dbo.Loads.LoadID, dbo.Loads.LoadNumber, dbo.Loads.HasLateStop, dbo.LoadStatusTypes.StatusText, dbo.Loads.NewPickupDate AS PickupDate, dbo.Loads.NewDeliveryDate AS DeliveryDate, dbo.Loads.BillDate AS InvoiceDate, dbo.Loads.CreatedDateTime AS CreatedDate, dbo.Customers.CustomerName, dbo.Loads.CarrierName, 
                         dbo.Loads.ShipperCity + ', ' + dbo.Loads.ShipperState + ' - ' + dbo.Loads.ConsigneeCity + ', ' + dbo.Loads.ConsigneeState AS PickupCityStateDeliveryCityState, '1' AS Qty, 'Miles Charge' AS Descrition, '0' AS LBS, 
                         dbo.Loads.CustomerRatePerMile * dbo.Loads.TotalMiles AS [Cust Amt], dbo.Loads.CarrierRatePerMile * dbo.Loads.TotalMiles AS [Carr Amt], '0' AS [Direct Cost], 
                         dbo.Loads.CustomerRatePerMile * dbo.Loads.TotalMiles - dbo.Loads.CarrierRatePerMile * dbo.Loads.TotalMiles AS Margin, dbo.Loads.SalesRep3Percentage AS [Comm %], (dbo.Loads.SalesRep3Percentage * 0.01) 
                         * (dbo.Loads.CustomerRatePerMile * dbo.Loads.TotalMiles - dbo.Loads.CarrierRatePerMile * dbo.Loads.TotalMiles) AS [Comm Amt],dbo.Offices.OfficeCode,ISNULL(dbo.BillFromCompanies.CompanyName,dbo.Companies.CompanyName) AS BillFromCompany,ISNULL(dbo.Loads.NoOfTrips,0) AS NoOfTrips
						 ,Dispatcher.Name AS Dispatcher,dbo.Loads.Dispatcher2Name AS Dispatcher2,dbo.Loads.Dispatcher3Name AS Dispatcher3
FROM            dbo.Loads INNER JOIN
                         dbo.LoadStatusTypes ON dbo.Loads.StatusTypeID = dbo.LoadStatusTypes.StatusTypeID INNER JOIN
                         dbo.Customers ON dbo.Loads.CustomerID = dbo.Customers.CustomerID INNER JOIN
                         dbo.CustomerOffices ON dbo.Customers.CustomerID = dbo.CustomerOffices.CustomerID INNER JOIN
                         dbo.Offices ON dbo.CustomerOffices.OfficeID = dbo.Offices.OfficeID INNER JOIN
                         dbo.Companies ON dbo.Offices.CompanyID = dbo.Companies.CompanyID INNER JOIN
                         dbo.Employees ON dbo.Loads.SalesRep3 = dbo.Employees.EmployeeID LEFT OUTER JOIN
						 dbo.Employees AS Dispatcher ON dbo.Loads.DispatcherID = Dispatcher.EmployeeID LEFT OUTER JOIN
						 dbo.BillFromCompanies ON dbo.BillFromCompanies.BillFromCompanyID =  dbo.Loads.BillFromCompany
WHERE        (dbo.Loads.CustomerRatePerMile * dbo.Loads.TotalMiles <> 0) OR
                         (dbo.Loads.CarrierRatePerMile * dbo.Loads.TotalMiles <> 0)
GO
GO

/****** Object:  View [dbo].[vwSalesDetailSalesRep]    Script Date: 05-07-2022 14:09:41 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER   VIEW [dbo].[vwSalesDetailSalesRep]
AS
SELECT        *
FROM            vwSalesDetailSalesRep1Cmdty
UNION ALL

SELECT        *
FROM            vwSalesDetailSalesRep2Cmdty
UNION ALL

SELECT        *
FROM            vwSalesDetailSalesRep3Cmdty
UNION ALL

SELECT        *
FROM            vwSalesDetailSalesRep1FlatRate
UNION ALL

SELECT        *
FROM            vwSalesDetailSalesRep2FlatRate
UNION ALL

SELECT        *
FROM            vwSalesDetailSalesRep3FlatRate
UNION ALL

SELECT        *
FROM            vwSalesDetailSalesRep1MilesRate
UNION ALL

SELECT        *
FROM            vwSalesDetailSalesRep2MilesRate
UNION ALL

SELECT        *
FROM            vwSalesDetailSalesRep3MilesRate

GO


GO

/****** Object:  View [dbo].[vwSalesDetailCmdty]    Script Date: 05-07-2022 14:19:53 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER   VIEW [dbo].[vwSalesDetailCmdty]
AS
SELECT        dbo.Companies.CompanyID, dbo.Loads.LoadID, dbo.Loads.LoadNumber, dbo.Loads.HasLateStop, dbo.LoadStatusTypes.StatusText, dbo.Loads.NewPickupDate AS PickupDate, dbo.Loads.NewDeliveryDate AS DeliveryDate, dbo.Loads.BillDate AS InvoiceDate, dbo.Loads.CreatedDateTime AS CreatedDate, dbo.Customers.CustomerName, dbo.Loads.CarrierName, 
                         dbo.Loads.ShipperCity + ', ' + dbo.Loads.ShipperState + ' - ' + dbo.Loads.ConsigneeCity + ', ' + dbo.Loads.ConsigneeState AS PickupCityStateDeliveryCityState, dbo.LoadStopCommodities.Qty, 
                         dbo.LoadStopCommodities.Description, dbo.LoadStopCommodities.Weight AS LBS, dbo.LoadStopCommodities.CustCharges AS [Cust Amt], dbo.LoadStopCommodities.CarrCharges AS [Carr Amt], 
                         ISNULL(dbo.LoadStopCommodities.DirectCostTotal,0) AS [Direct Cost], dbo.LoadStopCommodities.CustCharges - dbo.LoadStopCommodities.CarrCharges - ISNULL(ISNULL(dbo.LoadStopCommodities.DirectCostTotal,0), 0) AS Margin, 
                        CASE WHEN (dbo.loads.Dispatcher1 IS NOT NULL OR dbo.loads.Dispatcher2 IS NOT NULL OR dbo.loads.Dispatcher3 IS NOT NULL) THEN dbo.loads.Dispatcher1Percentage+dbo.loads.Dispatcher2Percentage+dbo.loads.Dispatcher3Percentage ELSE dbo.employees.salescommission END AS [Comm %], 
						((CASE WHEN (dbo.loads.Dispatcher1 IS NOT NULL OR dbo.loads.Dispatcher2 IS NOT NULL OR dbo.loads.Dispatcher3 IS NOT NULL) THEN dbo.loads.Dispatcher1Percentage+dbo.loads.Dispatcher2Percentage+dbo.loads.Dispatcher3Percentage ELSE dbo.employees.salescommission END) * 0.01) 
                         * (dbo.LoadStopCommodities.CustCharges - dbo.LoadStopCommodities.CarrCharges - ISNULL(ISNULL(dbo.LoadStopCommodities.DirectCostTotal,0), 0)) AS [Comm Amt],dbo.Offices.OfficeCode,ISNULL(dbo.BillFromCompanies.CompanyName,dbo.Companies.CompanyName) AS BillFromCompany,ISNULL(dbo.Loads.NoOfTrips,0) AS NoOfTrips
						 ,SalesRep.Name AS SalesRep,dbo.Loads.SalesRep2Name AS SalesRep2,dbo.Loads.SalesRep3Name AS SalesRep3
						,dbo.Employees.Name AS Dispatcher,dbo.Loads.Dispatcher2Name AS Dispatcher2,dbo.Loads.Dispatcher3Name AS Dispatcher3
FROM            dbo.Loads INNER JOIN
                         dbo.LoadStatusTypes ON dbo.Loads.StatusTypeID = dbo.LoadStatusTypes.StatusTypeID INNER JOIN
                         dbo.Customers ON dbo.Loads.CustomerID = dbo.Customers.CustomerID INNER JOIN
                         dbo.CustomerOffices ON dbo.Customers.CustomerID = dbo.CustomerOffices.CustomerID INNER JOIN
                         dbo.Offices ON dbo.CustomerOffices.OfficeID = dbo.Offices.OfficeID INNER JOIN
                         dbo.Companies ON dbo.Offices.CompanyID = dbo.Companies.CompanyID INNER JOIN
                         dbo.Employees ON dbo.Loads.DispatcherID = dbo.Employees.EmployeeID INNER JOIN
                         dbo.LoadStops ON dbo.Loads.LoadID = dbo.LoadStops.LoadID INNER JOIN
                         dbo.LoadStopCommodities ON dbo.LoadStops.LoadStopID = dbo.LoadStopCommodities.LoadStopID LEFT OUTER JOIN
						 dbo.Employees SalesRep ON dbo.Loads.SalesRepID = SalesRep.EmployeeID LEFT OUTER JOIN
						 dbo.BillFromCompanies ON dbo.BillFromCompanies.BillFromCompanyID =  dbo.Loads.BillFromCompany
WHERE        (dbo.LoadStopCommodities.Description <> N'') OR
                         (dbo.LoadStopCommodities.Weight <> 0) OR
                         (dbo.LoadStopCommodities.CustCharges <> 0) OR
                         (dbo.LoadStopCommodities.CarrCharges <> 0) OR
                         (ISNULL(dbo.LoadStopCommodities.DirectCostTotal,0) <> 0)
GO

GO

/****** Object:  View [dbo].[vwSalesDetailFlatRate]    Script Date: 05-07-2022 14:21:10 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER   VIEW [dbo].[vwSalesDetailFlatRate]
AS
SELECT        dbo.Companies.CompanyID, dbo.Loads.LoadID, dbo.Loads.LoadNumber, dbo.Loads.HasLateStop, dbo.LoadStatusTypes.StatusText, dbo.Loads.NewPickupDate AS PickupDate, dbo.Loads.NewDeliveryDate AS DeliveryDate, dbo.Loads.BillDate AS InvoiceDate, dbo.Loads.CreatedDateTime AS CreatedDate, dbo.Customers.CustomerName, dbo.Loads.CarrierName, 
                         dbo.Loads.ShipperCity + ', ' + dbo.Loads.ShipperState + ' - ' + dbo.Loads.ConsigneeCity + ', ' + dbo.Loads.ConsigneeState AS PickupCityStateDeliveryCityState, '1' AS Qty, 'Flat Rate' AS Descrition, '0' AS LBS, 
                         dbo.Loads.CustFlatRate AS [Cust Amt], dbo.Loads.CarrFlatRate AS [Carr Amt], '0' AS [Direct Cost], dbo.Loads.CustFlatRate - dbo.Loads.CarrFlatRate AS Margin, CASE WHEN (dbo.loads.Dispatcher1 IS NOT NULL OR dbo.loads.Dispatcher2 IS NOT NULL OR dbo.loads.Dispatcher3 IS NOT NULL) THEN dbo.loads.Dispatcher1Percentage+dbo.loads.Dispatcher2Percentage+dbo.loads.Dispatcher3Percentage ELSE dbo.employees.salescommission END AS [Comm %], ((CASE WHEN (dbo.loads.Dispatcher1 IS NOT NULL OR dbo.loads.Dispatcher2 IS NOT NULL OR dbo.loads.Dispatcher3 IS NOT NULL) THEN dbo.loads.Dispatcher1Percentage+dbo.loads.Dispatcher2Percentage+dbo.loads.Dispatcher3Percentage ELSE dbo.employees.salescommission END) * .01) * (dbo.Loads.CustFlatRate - dbo.Loads.CarrFlatRate) AS [Comm Amt],dbo.Offices.OfficeCode,ISNULL(dbo.BillFromCompanies.CompanyName,dbo.Companies.CompanyName) AS BillFromCompany,ISNULL(dbo.Loads.NoOfTrips,0) AS NoOfTrips
						 ,SalesRep.Name AS SalesRep,dbo.Loads.SalesRep2Name AS SalesRep2,dbo.Loads.SalesRep3Name AS SalesRep3
						,dbo.Employees.Name AS Dispatcher,dbo.Loads.Dispatcher2Name AS Dispatcher2,dbo.Loads.Dispatcher3Name AS Dispatcher3
FROM            dbo.Loads INNER JOIN
                         dbo.LoadStatusTypes ON dbo.Loads.StatusTypeID = dbo.LoadStatusTypes.StatusTypeID INNER JOIN
                         dbo.Customers ON dbo.Loads.CustomerID = dbo.Customers.CustomerID INNER JOIN
                         dbo.CustomerOffices ON dbo.Customers.CustomerID = dbo.CustomerOffices.CustomerID INNER JOIN
                         dbo.Offices ON dbo.CustomerOffices.OfficeID = dbo.Offices.OfficeID INNER JOIN
                         dbo.Companies ON dbo.Offices.CompanyID = dbo.Companies.CompanyID INNER JOIN
                         dbo.Employees ON dbo.Loads.DispatcherID = dbo.Employees.EmployeeID LEFT OUTER JOIN
						 dbo.Employees SalesRep ON dbo.Loads.SalesRepID = SalesRep.EmployeeID LEFT OUTER JOIN
						 dbo.BillFromCompanies ON dbo.BillFromCompanies.BillFromCompanyID =  dbo.Loads.BillFromCompany
WHERE        (dbo.Loads.CarrFlatRate <> 0) OR
                         (dbo.Loads.CustFlatRate <> 0)
GO

GO

/****** Object:  View [dbo].[vwSalesDetailMilesRate]    Script Date: 05-07-2022 14:22:17 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER   VIEW [dbo].[vwSalesDetailMilesRate]
AS
SELECT        dbo.Companies.CompanyID, dbo.Loads.LoadID, dbo.Loads.LoadNumber, dbo.Loads.HasLateStop, dbo.LoadStatusTypes.StatusText, dbo.Loads.NewPickupDate AS PickupDate, dbo.Loads.NewDeliveryDate AS DeliveryDate, dbo.Loads.BillDate AS InvoiceDate, dbo.Loads.CreatedDateTime AS CreatedDate, dbo.Customers.CustomerName, dbo.Loads.CarrierName, 
                         dbo.Loads.ShipperCity + ', ' + dbo.Loads.ShipperState + ' - ' + dbo.Loads.ConsigneeCity + ', ' + dbo.Loads.ConsigneeState AS PickupCityStateDeliveryCityState, '1' AS Qty, 'Miles Charge' AS Descrition, '0' AS LBS, 
                         dbo.Loads.CustomerRatePerMile * dbo.Loads.TotalMiles AS [Cust Amt], dbo.Loads.CarrierRatePerMile * dbo.Loads.TotalMiles AS [Carr Amt], '0' AS [Direct Cost], 
                         dbo.Loads.CustomerRatePerMile * dbo.Loads.TotalMiles - dbo.Loads.CarrierRatePerMile * dbo.Loads.TotalMiles AS Margin, CASE WHEN (dbo.loads.Dispatcher1 IS NOT NULL OR dbo.loads.Dispatcher2 IS NOT NULL OR dbo.loads.Dispatcher3 IS NOT NULL) THEN dbo.loads.Dispatcher1Percentage+dbo.loads.Dispatcher2Percentage+dbo.loads.Dispatcher3Percentage ELSE dbo.employees.salescommission END AS [Comm %], ((CASE WHEN (dbo.loads.Dispatcher1 IS NOT NULL OR dbo.loads.Dispatcher2 IS NOT NULL OR dbo.loads.Dispatcher3 IS NOT NULL) THEN dbo.loads.Dispatcher1Percentage+dbo.loads.Dispatcher2Percentage+dbo.loads.Dispatcher3Percentage ELSE dbo.employees.salescommission END) * .01) * (dbo.Loads.CustomerRatePerMile * dbo.Loads.TotalMiles - dbo.Loads.CarrierRatePerMile * dbo.Loads.TotalMiles) 
                         AS [Comm Amt],dbo.Offices.OfficeCode,ISNULL(dbo.BillFromCompanies.CompanyName,dbo.Companies.CompanyName) AS BillFromCompany,ISNULL(dbo.Loads.NoOfTrips,0) AS NoOfTrips
						 ,SalesRep.Name AS SalesRep,dbo.Loads.SalesRep2Name AS SalesRep2,dbo.Loads.SalesRep3Name AS SalesRep3
						,dbo.Employees.Name AS Dispatcher,dbo.Loads.Dispatcher2Name AS Dispatcher2,dbo.Loads.Dispatcher3Name AS Dispatcher3
FROM            dbo.Loads INNER JOIN
                         dbo.LoadStatusTypes ON dbo.Loads.StatusTypeID = dbo.LoadStatusTypes.StatusTypeID INNER JOIN
                         dbo.Customers ON dbo.Loads.CustomerID = dbo.Customers.CustomerID INNER JOIN
                         dbo.CustomerOffices ON dbo.Customers.CustomerID = dbo.CustomerOffices.CustomerID INNER JOIN
                         dbo.Offices ON dbo.CustomerOffices.OfficeID = dbo.Offices.OfficeID INNER JOIN
                         dbo.Companies ON dbo.Offices.CompanyID = dbo.Companies.CompanyID INNER JOIN
                         dbo.Employees ON dbo.Loads.DispatcherID = dbo.Employees.EmployeeID LEFT OUTER JOIN
						 dbo.Employees SalesRep ON dbo.Loads.SalesRepID = SalesRep.EmployeeID LEFT OUTER JOIN
						 dbo.BillFromCompanies ON dbo.BillFromCompanies.BillFromCompanyID =  dbo.Loads.BillFromCompany
WHERE        (dbo.Loads.CustomerRatePerMile * dbo.Loads.TotalMiles <> 0) OR
                         (dbo.Loads.CarrierRatePerMile * dbo.Loads.TotalMiles <> 0)
GO


GO

/****** Object:  View [dbo].[vwSalesDetail]    Script Date: 05-07-2022 14:23:20 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER   VIEW [dbo].[vwSalesDetail]
AS
SELECT        *
FROM            vwSalesDetailCmdty
UNION ALL

SELECT        *
FROM            vwSalesDetailFlatRate
UNION ALL

SELECT        *
FROM            vwSalesDetailMilesRate

GO


GO

/****** Object:  StoredProcedure [dbo].[USP_GetSalesDetailReport]    Script Date: 05-07-2022 14:41:09 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



ALTER   PROCEDURE [dbo].[USP_GetSalesDetailReport]

@CompanyID varchar(36),
@GroupBy varchar(36),
@DateType varchar(10),
@DateFrom date,
@DateTo date,
@StatusFrom varchar(50),
@StatusTo varchar(50),
@SalesRepFrom varchar(150),
@SalesRepTo varchar(150),
@DispatcherFrom varchar(150),
@DispatcherTo varchar(150),
@CustomerFrom varchar(150),
@CustomerTo varchar(150),
@CarrierFrom varchar(150),
@CarrierTo varchar(150),
@OrderBy varchar(20),
@ExcludeZeroItems bit,
@ExcludeZeroWeights bit,
@OfficeFrom varchar(150),
@OfficeTo varchar(150),
@BillFrom varchar(150),
@BillTo varchar(150),
@SalesRepReport bit
AS
BEGIN

	DECLARE @sql varchar(max);
	SET @sql = 'SELECT * FROM'

	IF(@GroupBy='dispatcher')
	BEGIN
		SET @sql = @sql + ' vwSalesDetailDispatcher'
	END
	ELSE IF(@GroupBy='salesAgent')
	BEGIN
		SET @sql = @sql + ' vwSalesDetailSalesRep'
	END
	ELSE
	BEGIN
		SET @sql = @sql + ' vwSalesDetail'
	END

	SET @sql = @sql + ' WHERE CompanyID = '''+@CompanyID+''''

	SET @sql = @sql + ' AND StatusText BETWEEN '''+@StatusFrom+''' AND '''+@StatusTo+''''

	IF(@DateType='Pickup')
	BEGIN
		SET @sql = @sql + ' AND PickupDate BETWEEN '''+CAST(@DateFrom AS varchar(30))+''' AND '''+CAST(@DateTo AS varchar(30))+''''
	END
	ELSE IF(@DateType='Delivery')
	BEGIN
		SET @sql = @sql + ' AND DeliveryDate BETWEEN '''+CAST(@DateFrom AS varchar(30))+''' AND '''+CAST(@DateTo AS varchar(30))+''''
	END
	ELSE IF(@DateType='Invoice')
	BEGIN
		SET @sql = @sql + ' AND InvoiceDate BETWEEN '''+CAST(@DateFrom AS varchar(30))+''' AND '''+CAST(@DateTo AS varchar(30))+''''
	END
	ELSE
	BEGIN
		SET @sql = @sql + ' AND CreatedDate BETWEEN '''+CAST(@DateFrom AS varchar(30))+''' AND '''+CAST(@DateTo AS varchar(30))+''''
	END

	IF(@SalesRepReport=0)
	BEGIN
		IF(len(trim(@DispatcherFrom)) <> 0 AND @GroupBy='dispatcher')
		BEGIN
			SET @sql = @sql + ' AND trim(Dispatcher) >= '''+trim(@DispatcherFrom)+''''
		END

		IF(len(trim(@DispatcherTo)) <> 0 AND @GroupBy='dispatcher')
		BEGIN
			SET @sql = @sql + ' AND trim(Dispatcher) <= '''+trim(@DispatcherTo)+''''
		END


		IF(len(trim(@SalesRepFrom)) <> 0 AND @GroupBy='salesAgent')
		BEGIN
			SET @sql = @sql + ' AND trim(SalesRep) >= '''+trim(@SalesRepFrom)+''''
		END

		IF(len(trim(@SalesRepTo)) <> 0 AND @GroupBy='salesAgent')
		BEGIN
			SET @sql = @sql + ' AND trim(SalesRep) <= '''+trim(@SalesRepTo)+''''
		END
	END
	ELSE
	BEGIN
		IF(@GroupBy='dispatcher')
		BEGIN
			SET @sql = @sql + ' AND (trim(Dispatcher) = '''+trim(@DispatcherFrom)+''' OR trim(SalesRep) = '''+trim(@SalesRepTo)+''' OR trim(SalesRep2) = '''+trim(@SalesRepTo)+''' OR trim(SalesRep3) = '''+trim(@SalesRepTo)+''')'
		END
		ELSE IF(@GroupBy='salesAgent')
		BEGIN
			SET @sql = @sql + ' AND (trim(Dispatcher) = '''+trim(@DispatcherFrom)+''' OR trim(Dispatcher2) = '''+trim(@DispatcherFrom)+''' OR trim(Dispatcher3) = '''+trim(@DispatcherFrom)+''' OR trim(SalesRep) = '''+trim(@SalesRepTo)+''')'
		END
		ELSE
		BEGIN
			SET @sql = @sql + ' AND (trim(Dispatcher) = '''+trim(@DispatcherFrom)+''' OR trim(Dispatcher2) = '''+trim(@DispatcherFrom)+''' OR trim(Dispatcher3) = '''+trim(@DispatcherFrom)+''' OR trim(SalesRep) = '''+trim(@SalesRepTo)+''' OR trim(SalesRep2) = '''+trim(@SalesRepTo)+''' OR trim(SalesRep3) = '''+trim(@SalesRepTo)+''')'
		END
	END

	IF(len(trim(@CustomerFrom)) <> 0)
	BEGIN
		SET @sql = @sql + ' AND trim(CustomerName) >= '''+trim(@CustomerFrom)+''''
	END

	IF(len(trim(@CustomerTo)) <> 0)
	BEGIN
		SET @sql = @sql + ' AND trim(CustomerName) <= '''+trim(@CustomerTo)+''''
	END

	IF(len(trim(@CarrierFrom)) <> 0)
	BEGIN
		SET @sql = @sql + ' AND trim(CarrierName) >= '''+trim(@CarrierFrom)+''''
	END

	IF(len(trim(@CarrierTo)) <> 0)
	BEGIN
		SET @sql = @sql + ' AND trim(CarrierName) <= '''+trim(@CarrierTo)+''''
	END

	IF(len(trim(@OfficeFrom)) <> 0)
	BEGIN
		SET @sql = @sql + ' AND trim(OfficeCode) >= '''+trim(@OfficeFrom)+''''
	END

	IF(len(trim(@OfficeTo)) <> 0)
	BEGIN
		SET @sql = @sql + ' AND trim(OfficeCode) <= '''+trim(@OfficeTo)+''''
	END
	
	IF(len(trim(@BillFrom)) <> 0)
	BEGIN
		SET @sql = @sql + ' AND trim(BillFromCompany) >= '''+trim(@BillFrom)+''''
	END

	IF(len(trim(@BillTo)) <> 0)
	BEGIN
		SET @sql = @sql + ' AND trim(BillFromCompany) <= '''+trim(@BillTo)+''''
	END
	
	IF(@ExcludeZeroItems=1)
	BEGIN
		SET @sql = @sql + ' AND ([Cust Amt] != 0 OR [Carr Amt] !=0 OR [Direct Cost] !=0)'
	END
	
	IF(@ExcludeZeroWeights=1)
	BEGIN
		SET @sql = @sql + ' AND LBS ! = 0'
	END
	
	SET @sql = @sql + 'ORDER BY '

	IF(@GroupBy='dispatcher')
	BEGIN
		SET @sql = @sql + ' Dispatcher,'
	END
	ELSE IF(@GroupBy='salesAgent')
	BEGIN
		SET @sql = @sql + ' SalesRep,'
	END
	ELSE IF(@GroupBy='customer')
	BEGIN
		SET @sql = @sql + ' CustomerName,'
	END
	ELSE IF(@GroupBy='carrier')
	BEGIN
		SET @sql = @sql + ' CarrierName,'
	END

	SET @sql = @sql + 'LoadNumber'

	EXEC(@sql);
	--SELECT @sql
END

GO
GO

/****** Object:  View [dbo].[vwAging20180125]    Script Date: 05-07-2022 14:43:34 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER   VIEW [dbo].[vwAging20180125]
AS
SELECT        TOP (100) PERCENT dbo.Companies.CompanyName,dbo.Companies.CompanyID, dbo.Employees.Name AS Dispatcher, ISNULL(NULLIF (Employees_1.Name, N''), N'(BLANK)') AS SalesAgent1, dbo.Loads.LoadNumber, 
                         dbo.LoadStops.StopDate AS OrderDate, dbo.Loads.CustName, ISNULL(NULLIF (dbo.Loads.userDefinedFieldTrucking, ''), N'(BLANK)') AS userDefinedFieldTrucking, 
                         dbo.LoadStops.City + ', ' + dbo.LoadStops.StateCode AS FirstStop, dbo.vwCarrierConfirmationReportFinalDestination.City + ', ' + dbo.vwCarrierConfirmationReportFinalDestination.StateCode AS LastStop, 
                         dbo.Loads.TotalCarrierCharges, dbo.Loads.BillDate, dbo.Loads.TotalCustomerCharges, ISNULL(dbo.Loads.TotalCustomerCharges - dbo.Loads.TotalCarrierCharges, 0) AS GrossMargin, dbo.Carriers.CarrierName, 
                         ISNULL(Employees_1.SalesCommission, 0) AS CommissionPercent, ISNULL((dbo.Loads.TotalCustomerCharges - dbo.Loads.TotalCarrierCharges) * (Employees_1.SalesCommission * .01), 0) AS CommissionAmt, 
                         dbo.LoadStatusTypes.StatusTypeID, dbo.LoadStatusTypes.StatusText, ISNULL(dbo.Equipments.EquipmentName, N'(BLANK)') AS EquiptName, dbo.Employees.SalesCommission AS DispatchCommissionPercent, 
                         ISNULL((dbo.Loads.TotalCustomerCharges - dbo.Loads.TotalCarrierCharges) * (dbo.Employees.SalesCommission * .01), 0) AS DispatchCommissionAmt, dbo.Carriers.CarrierName AS Driver, ISNULL(dbo.Carriers.CarrierName, 
                         N'(BLANK)') AS Carrier, dbo.SystemConfig.FreightBroker, Employees_1.Name AS SalesAgent, ISNULL(dbo.vwSalesRepCommissionCarrierPay.Payments, 0) AS Payments, 
                         dbo.Loads.TotalCarrierCharges - ISNULL(dbo.vwSalesRepCommissionCarrierPay.Payments, 0) AS CarrierPay, ISNULL((dbo.Loads.TotalCustomerCharges - dbo.Loads.TotalCarrierCharges) 
                         * (Employees_1.SalesCommission * .01), 0) AS CommissionAmountReport, ISNULL(Employees_1.SalesCommission, 0) AS CommissionPercentReport, dbo.Loads.CustomerPONo, DATEDIFF(day, dbo.Loads.BillDate, GETDATE()) 
                         AS Age, 
						 CASE WHEN 30 >= (DATEDIFF(day, ISNULL(dbo.Loads.BillDate, GETDATE()), GETDATE())) THEN [TotalCustomerCharges] ELSE 0 END AS CurrentAge, 
						 CASE WHEN (DATEDIFF(day, dbo.Loads.BillDate, GETDATE())) BETWEEN 31 AND 60 THEN [TotalCustomerCharges] ELSE 0 END AS [30Age], 
						 CASE WHEN (DATEDIFF(day, dbo.Loads.BillDate, GETDATE())) BETWEEN 61 AND 90 THEN [TotalCustomerCharges] ELSE 0 END AS [60Age], 
                         CASE WHEN (DATEDIFF(day, dbo.Loads.BillDate, GETDATE())) BETWEEN 91 AND 120 THEN [TotalCustomerCharges] ELSE 0 END AS [90Age], 
						 CASE WHEN 120 <= (DATEDIFF(day, dbo.Loads.BillDate, GETDATE())) THEN [TotalCustomerCharges] ELSE 0 END AS [120Age], 
						 CASE WHEN 30 >= (DATEDIFF(day, ISNULL(dbo.Loads.BillDate, GETDATE()), GETDATE())) THEN [TotalCarrierCharges] ELSE 0 END AS CarrierCurrentAge, 
						 CASE WHEN (DATEDIFF(day, dbo.Loads.BillDate, GETDATE())) BETWEEN 31 AND 60 THEN [TotalCarrierCharges] ELSE 0 END AS [Carrier30Age], 
						 CASE WHEN (DATEDIFF(day, dbo.Loads.BillDate, GETDATE())) BETWEEN 61 AND 90 THEN [TotalCarrierCharges] ELSE 0 END AS [Carrier60Age], 
                         CASE WHEN (DATEDIFF(day, dbo.Loads.BillDate, GETDATE())) BETWEEN 91 AND 120 THEN [TotalCarrierCharges] ELSE 0 END AS [Carrier90Age], 
						 CASE WHEN 120 <= (DATEDIFF(day, dbo.Loads.BillDate, GETDATE())) THEN [TotalCarrierCharges] ELSE 0 END AS [Carrier120Age], 
						 dbo.Loads.ContactPerson, dbo.Loads.Phone, dbo.Loads.Fax, ISNULL(dbo.Loads.noOfTrips, 0) AS nooftrips, dbo.Loads.CreatedDateTime, dbo.Loads.NewDeliveryDate AS DeliveryDate
						 ,CASE WHEN systemconfig.dispatch = 1 
						 THEN 
							CASE WHEN ISNULL(Carriers.DispatchFee,0) <> 0 THEN Carriers.DispatchFee  ELSE 0 END
						 ELSE 
							0
						 END AS DispatchFeePercNew
						 ,CASE WHEN systemconfig.dispatch = 1 
						 THEN 
							CASE WHEN ISNULL(Carriers.DispatchFee,0) <> 0 THEN Loads.TotalCustomerCharges*(Carriers.DispatchFee/100) ELSE 0 END
						 ELSE 
							0
						 END AS DispatchFeeNew
						 ,systemconfig.dispatch AS IsDispatch,dbo.SystemConfig.CompanyLogoName,dbo.Companies.CompanyCode,1 as sortField
						 ,dbo.Loads.HasLateStop, dbo.Loads.CustomerPaid, dbo.Loads.CarrierPaid, dbo.Offices.OfficeCode
						 , dbo.Loads.Dispatcher2Name AS Dispatcher2, dbo.Loads.Dispatcher3Name AS Dispatcher3
						 ,dbo.Loads.SalesRep2Name AS SalesAgent2, dbo.Loads.SalesRep3Name AS SalesAgent3
FROM            dbo.Carriers RIGHT OUTER JOIN
                         dbo.LoadStatusTypes INNER JOIN
                         dbo.Loads INNER JOIN
                         dbo.LoadStops ON dbo.Loads.LoadID = dbo.LoadStops.LoadID INNER JOIN
                         dbo.vwCarrierConfirmationReportFinalDestination ON dbo.Loads.LoadID = dbo.vwCarrierConfirmationReportFinalDestination.LoadID ON dbo.LoadStatusTypes.StatusTypeID = dbo.Loads.StatusTypeID LEFT OUTER JOIN
                         dbo.vwSalesRepCommissionCarrierPay ON dbo.Loads.LoadID = dbo.vwSalesRepCommissionCarrierPay.LoadID LEFT OUTER JOIN
                         dbo.Equipments ON dbo.LoadStops.NewEquipmentID = dbo.Equipments.EquipmentID ON dbo.Carriers.CarrierID = dbo.LoadStops.NewCarrierID LEFT OUTER JOIN
                         dbo.Employees AS Employees_1 ON dbo.Loads.SalesRepID = Employees_1.EmployeeID LEFT OUTER JOIN
                         dbo.Employees ON dbo.Loads.DispatcherID = dbo.Employees.EmployeeID INNER JOIN
						 dbo.Offices ON dbo.Offices.OfficeID = dbo.Employees.OfficeID INNER JOIN 
                         dbo.Companies ON dbo.Companies.CompanyID = dbo.Offices.CompanyID INNER JOIN 
                         dbo.SystemConfig ON  dbo.SystemConfig.CompanyID = dbo.Companies.CompanyID
WHERE        (dbo.LoadStops.LoadType = 1) AND (dbo.LoadStops.StopNo + 1 = 1)
ORDER BY dbo.Loads.CustName, CASE WHEN 30 >= (DATEDIFF(day, ISNULL(dbo.Loads.BillDate, GETDATE()), GETDATE())) THEN [TotalCustomerCharges] ELSE 0 END
GO


GO

/****** Object:  StoredProcedure [dbo].[USP_GetLoadsForCommissionAging]    Script Date: 05-07-2022 14:40:39 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER   PROCEDURE [dbo].[USP_GetLoadsForCommissionAging] 
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
	@companyid VARCHAR(200),
	@reportType VARCHAR(25) = 'Customer',
	@SalesRepReport bit
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	IF @groupsBy = 'none'
		IF @freightBroker ='Driver'
			IF @datetype = 'Shipdate'
				SELECT *,'none' as GrpBy,'none' as SCommissionPercent,0 as SCommissionAmt FROM vwAging20180125
				WHERE orderdate BETWEEN @orderDateFrom AND @orderDateTo
				AND userDefinedFieldTrucking BETWEEN @salesAgentFrom AND @salesAgentTo
				AND Dispatcher BETWEEN @dispatcherFrom AND @dispatcherTo
				AND statusText >= @statusTo
				AND statusText <= @statusFrom
				AND EquiptName >= @equipmentFrom
				AND EquiptName <= @equipmentTo
				AND OfficeCode >= @officeFrom
				AND OfficeCode <= @officeTo
				AND Carrier >= @carrierFrom
				AND Carrier <= @carrierTo
				AND CustName BETWEEN @customerFrom AND @customerTo
				AND CompanyID = @companyid
				AND ((@reportType = 'Customer' AND CustomerPaid = 0) OR (@reportType = 'Carrier'AND CarrierPaid = 0))
				ORDER BY
					CustName ASC
			ELSE 
				SELECT *,'none' as GrpBy,'none' as SCommissionPercent,0 as SCommissionAmt FROM vwAging20180125
				WHERE billdate BETWEEN @billDateFrom AND @billDateTo
				AND userDefinedFieldTrucking BETWEEN @salesAgentFrom AND @salesAgentTo
				AND Dispatcher BETWEEN @dispatcherFrom AND @dispatcherTo
				AND statusText >= @statusTo
				AND statusText <= @statusFrom
				AND EquiptName >= @equipmentFrom
				AND EquiptName <= @equipmentTo
				AND OfficeCode >= @officeFrom
				AND OfficeCode <= @officeTo
				AND Carrier >= @carrierFrom
				AND Carrier <= @carrierTo
				AND CustName BETWEEN @customerFrom AND @customerTo
				AND CompanyID = @companyid
				AND ((@reportType = 'Customer' AND CustomerPaid = 0) OR (@reportType = 'Carrier'AND CarrierPaid = 0))
				ORDER BY
					CustName ASC
		ELSE
			IF @datetype = 'Shipdate'
				SELECT *,'none' as GrpBy,'none' as SCommissionPercent,0 as SCommissionAmt FROM vwAging20180125
				WHERE orderdate BETWEEN @orderDateFrom AND @orderDateTo
				AND (
					(@SalesRepReport = 1 
						AND (SalesAgent = @salesAgentFrom OR SalesAgent2 = @salesAgentFrom OR SalesAgent2 = @salesAgentFrom 
							OR Dispatcher = @dispatcherFrom OR Dispatcher2 = @dispatcherFrom OR Dispatcher3 = @dispatcherFrom)
					) 
					OR 
					(@SalesRepReport = 0 
						AND SalesAgent BETWEEN @salesAgentFrom AND @salesAgentTo
						AND ((Dispatcher BETWEEN @dispatcherFrom AND @dispatcherTo)  
							OR (Dispatcher2 BETWEEN @dispatcherFrom AND @dispatcherTo)
							OR (Dispatcher3 BETWEEN @dispatcherFrom AND @dispatcherTo))
					)
				)
				AND statusText >= @statusTo
				AND statusText <= @statusFrom
				AND EquiptName >= @equipmentFrom
				AND EquiptName <= @equipmentTo
				AND OfficeCode >= @officeFrom
				AND OfficeCode <= @officeTo
				AND Carrier >= @carrierFrom
				AND Carrier <= @carrierTo
				AND CustName BETWEEN @customerFrom AND @customerTo
				AND CompanyID = @companyid
				AND ((@reportType = 'Customer' AND CustomerPaid = 0) OR (@reportType = 'Carrier'AND CarrierPaid = 0))
				ORDER BY
					CustName ASC
			ELSE
				SELECT *,'none' as GrpBy,'none' as SCommissionPercent,0 as SCommissionAmt FROM vwAging20180125
				WHERE billdate BETWEEN @billDateFrom AND @billDateTo
				AND (
					(@SalesRepReport = 1 
						AND (SalesAgent = @salesAgentFrom OR SalesAgent2 = @salesAgentFrom OR SalesAgent2 = @salesAgentFrom 
							OR Dispatcher = @dispatcherFrom OR Dispatcher2 = @dispatcherFrom OR Dispatcher3 = @dispatcherFrom)
					) 
					OR 
					(@SalesRepReport = 0 
						AND SalesAgent BETWEEN @salesAgentFrom AND @salesAgentTo
						AND ((Dispatcher BETWEEN @dispatcherFrom AND @dispatcherTo)  
							OR (Dispatcher2 BETWEEN @dispatcherFrom AND @dispatcherTo)
							OR (Dispatcher3 BETWEEN @dispatcherFrom AND @dispatcherTo))
					)
				)
				AND statusText >= @statusTo
				AND statusText <= @statusFrom
				AND EquiptName >= @equipmentFrom
				AND EquiptName <= @equipmentTo
				AND OfficeCode >= @officeFrom
				AND OfficeCode <= @officeTo
				AND Carrier >= @carrierFrom
				AND Carrier <= @carrierTo
				AND CustName BETWEEN @customerFrom AND @customerTo
				AND CompanyID = @companyid
				AND ((@reportType = 'Customer' AND CustomerPaid = 0) OR (@reportType = 'Carrier'AND CarrierPaid = 0))
				ORDER BY
					CustName ASC
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
				FROM vwAging20180125
				WHERE orderdate BETWEEN @orderDateFrom AND @orderDateTo
				AND userDefinedFieldTrucking BETWEEN @salesAgentFrom AND @salesAgentTo
				AND Dispatcher BETWEEN @dispatcherFrom AND @dispatcherTo
				AND statusText >= @statusTo
				AND statusText <= @statusFrom
				AND EquiptName >= @equipmentFrom
				AND EquiptName <= @equipmentTo
				AND OfficeCode >= @officeFrom
				AND OfficeCode <= @officeTo
				AND Carrier >= @carrierFrom
				AND Carrier <= @carrierTo
				AND CustName BETWEEN @customerFrom AND @customerTo
				AND CompanyID = @companyid
				AND ((@reportType = 'Customer' AND CustomerPaid = 0) OR (@reportType = 'Carrier'AND CarrierPaid = 0))
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
				LoadNumber ASC
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
				FROM vwAging20180125
				WHERE billdate BETWEEN @billDateFrom AND @billDateTo
				AND userDefinedFieldTrucking BETWEEN @salesAgentFrom AND @salesAgentTo
				AND Dispatcher BETWEEN @dispatcherFrom AND @dispatcherTo
				AND statusText >= @statusTo
				AND statusText <= @statusFrom
				AND EquiptName >= @equipmentFrom
				AND EquiptName <= @equipmentTo
				AND OfficeCode >= @officeFrom
				AND OfficeCode <= @officeTo
				AND Carrier >= @carrierFrom
				AND Carrier <= @carrierTo
				AND CustName BETWEEN @customerFrom AND @customerTo
				AND CompanyID = @companyid
				AND ((@reportType = 'Customer' AND CustomerPaid = 0) OR (@reportType = 'Carrier'AND CarrierPaid = 0))
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
				LoadNumber ASC
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
				FROM vwAging20180125
				WHERE orderdate BETWEEN @orderDateFrom AND @orderDateTo
				AND (
					(@SalesRepReport = 1 
						AND (SalesAgent = @salesAgentFrom OR SalesAgent2 = @salesAgentFrom OR SalesAgent2 = @salesAgentFrom 
							OR Dispatcher = @dispatcherFrom OR Dispatcher2 = @dispatcherFrom OR Dispatcher3 = @dispatcherFrom)
					) 
					OR 
					(@SalesRepReport = 0 
						AND SalesAgent BETWEEN @salesAgentFrom AND @salesAgentTo
						AND ((Dispatcher BETWEEN @dispatcherFrom AND @dispatcherTo)  
							OR (Dispatcher2 BETWEEN @dispatcherFrom AND @dispatcherTo)
							OR (Dispatcher3 BETWEEN @dispatcherFrom AND @dispatcherTo))
					)
				)
				AND statusText >= @statusTo
				AND statusText <= @statusFrom
				AND EquiptName >= @equipmentFrom
				AND EquiptName <= @equipmentTo
				AND OfficeCode >= @officeFrom
				AND OfficeCode <= @officeTo
				AND Carrier >= @carrierFrom
				AND Carrier <= @carrierTo
				AND CustName BETWEEN @customerFrom AND @customerTo
				AND CompanyID = @companyid
				AND ((@reportType = 'Customer' AND CustomerPaid = 0) OR (@reportType = 'Carrier'AND CarrierPaid = 0))
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
				LoadNumber ASC
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
				FROM vwAging20180125
				WHERE billdate BETWEEN @billDateFrom AND @billDateTo
				AND (
					(@SalesRepReport = 1 
						AND (SalesAgent = @salesAgentFrom OR SalesAgent2 = @salesAgentFrom OR SalesAgent2 = @salesAgentFrom 
							OR Dispatcher = @dispatcherFrom OR Dispatcher2 = @dispatcherFrom OR Dispatcher3 = @dispatcherFrom)
					) 
					OR 
					(@SalesRepReport = 0 
						AND SalesAgent BETWEEN @salesAgentFrom AND @salesAgentTo
						AND ((Dispatcher BETWEEN @dispatcherFrom AND @dispatcherTo)  
							OR (Dispatcher2 BETWEEN @dispatcherFrom AND @dispatcherTo)
							OR (Dispatcher3 BETWEEN @dispatcherFrom AND @dispatcherTo))
					)
				)
				AND statusText >= @statusTo
				AND statusText <= @statusFrom
				AND EquiptName >= @equipmentFrom
				AND EquiptName <= @equipmentTo
				AND OfficeCode >= @officeFrom
				AND OfficeCode <= @officeTo
				AND Carrier >= @carrierFrom
				AND Carrier <= @carrierTo
				AND CustName BETWEEN @customerFrom AND @customerTo
				AND CompanyID = @companyid
				AND ((@reportType = 'Customer' AND CustomerPaid = 0) OR (@reportType = 'Carrier'AND CarrierPaid = 0))
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
				LoadNumber ASC
END



GO













