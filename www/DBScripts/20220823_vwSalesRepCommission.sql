GO

/****** Object:  View [dbo].[vwSalesRepCommission]    Script Date: 23-08-2022 12:34:23 ******/
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
                         dbo.Loads WITH (NOLOCK) INNER JOIN
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
                         dbo.Loads WITH (NOLOCK) INNER JOIN
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
                         dbo.Loads WITH (NOLOCK) INNER JOIN
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


