
GO

/****** Object:  View [dbo].[vwAging20180125]    Script Date: 31/03/2022 15:21:04 ******/
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
                         AS Age, CASE WHEN 30 >= (DATEDIFF(day, ISNULL(dbo.Loads.BillDate, GETDATE()), GETDATE())) THEN [TotalCustomerCharges] ELSE 0 END AS CurrentAge, CASE WHEN (DATEDIFF(day, dbo.Loads.BillDate, GETDATE())) 
                         BETWEEN 31 AND 60 THEN [TotalCustomerCharges] ELSE 0 END AS [30Age], CASE WHEN (DATEDIFF(day, dbo.Loads.BillDate, GETDATE())) BETWEEN 61 AND 90 THEN [TotalCustomerCharges] ELSE 0 END AS [60Age], 
                         CASE WHEN (DATEDIFF(day, dbo.Loads.BillDate, GETDATE())) BETWEEN 91 AND 120 THEN [TotalCustomerCharges] ELSE 0 END AS [90Age], CASE WHEN 120 <= (DATEDIFF(day, dbo.Loads.BillDate, GETDATE())) 
                         THEN [TotalCustomerCharges] ELSE 0 END AS [120Age], dbo.Loads.ContactPerson, dbo.Loads.Phone, dbo.Loads.Fax, ISNULL(dbo.Loads.noOfTrips, 0) AS nooftrips, dbo.Loads.CreatedDateTime, dbo.Loads.NewDeliveryDate AS DeliveryDate
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
						 ,dbo.Loads.HasLateStop
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


