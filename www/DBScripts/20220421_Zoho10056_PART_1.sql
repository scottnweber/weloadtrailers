GO

/****** Object:  View [dbo].[ExportSalesSummary]    Script Date: 22-04-2022 09:05:08 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



ALTER VIEW [dbo].[ExportSalesSummary]
AS
SELECT        TOP (100) PERCENT dbo.Offices.Location, dbo.Offices.OfficeCode, dbo.Employees.Name AS Dispatcher, ISNULL(NULLIF (Employees_1.Name, N''), N'(BLANK)') AS SalesAgent1, dbo.Loads.LoadNumber, dbo.Loads.orderDate, 
                         dbo.Loads.CustName, dbo.LoadStops.City + ', ' + dbo.LoadStops.StateCode AS [Lane Origin], 
                         dbo.vwCarrierConfirmationReportFinalDestination.City + ', ' + dbo.vwCarrierConfirmationReportFinalDestination.StateCode AS [Lane Destination],
						 STUFF((SELECT  ',' + Description FROM LoadStopCommodities LSC WHERE  LSC.LoadStopID=dbo.LoadStops.LoadStopID AND ISNULL(DirectCostTotal,0) <> 0 ORDER BY SrNo FOR XML PATH(''), TYPE).value('text()[1]','nvarchar(max)'), 1, LEN(','), '') AS ListCommodities,
						 dbo.Loads.TotalCarrierCharges, dbo.Loads.BillDate AS InvoiceDate, 
                         dbo.Loads.TotalCustomerCharges, ISNULL(dbo.Loads.TotalCustomerCharges - dbo.Loads.TotalCarrierCharges, 0) AS GrossMargin, dbo.Loads.TotalMiles, dbo.Loads.DeadHeadMiles, dbo.Carriers.CarrierName, ISNULL(Employees_1.SalesCommission, 0) AS CommissionPercent, 
                         ISNULL((dbo.Loads.TotalCustomerCharges - dbo.Loads.TotalCarrierCharges) * (Employees_1.SalesCommission * .01), 0) AS CommissionAmt, dbo.LoadStatusTypes.StatusText, dbo.LoadStatusTypes.StatusDescription, 
                         ISNULL(dbo.Equipments.EquipmentName, N'(BLANK)') AS EquiptName, dbo.Employees.SalesCommission AS DispatchCommissionPercent, ISNULL((dbo.Loads.TotalCustomerCharges - dbo.Loads.TotalCarrierCharges) 
                         * (dbo.Employees.SalesCommission * .01), 0) AS DispatchCommissionAmt, dbo.Carriers.CarrierName AS [Carrier/Driver], Employees_1.Name AS SalesAgent, 
                         ISNULL(dbo.vwSalesRepCommissionCarrierPay.Payments, 0) AS Payments, dbo.Loads.TotalCarrierCharges - ISNULL(dbo.vwSalesRepCommissionCarrierPay.Payments, 0) AS CarrierPay, 
                         ISNULL((dbo.Loads.TotalCustomerCharges - dbo.Loads.TotalCarrierCharges) * (Employees_1.SalesCommission * .01), 0) AS CommissionAmountReport, ISNULL(Employees_1.SalesCommission, 0) AS CommissionPercentReport,
                          dbo.Loads.NewPickupDate AS pickupdate, dbo.Loads.CustomerPONo AS PoNumber, dbo.vwCarrierRateConfirmationWeight.WeightTotal, dbo.LoadStops.CustName AS [First Stop Name], 
                         dbo.LoadStops.Address AS [First Stop Address], dbo.LoadStops.City AS [First Stop City], dbo.LoadStops.StateCode AS [First Stop State], dbo.LoadStops.PostalCode AS [First Stop Zip], 
                         dbo.vwCarrierConfirmationReportFinalDestination.CustName AS [Last Stop Name], dbo.vwCarrierConfirmationReportFinalDestination.Address AS [Last Stop Address], 
                         dbo.vwCarrierConfirmationReportFinalDestination.City AS [Last Stop City], dbo.vwCarrierConfirmationReportFinalDestination.StateCode AS [Last Stop State], 
                         dbo.vwCarrierConfirmationReportFinalDestination.PostalCode AS [Last Stop Zip], dbo.vwCarrierConfirmationReportFinalDestination.FinalDelivDate AS [Delivery Date], dbo.LoadStops.LoadStopID, 
                         dbo.Companies.CompanyID
FROM            dbo.vwCarrierRateConfirmationWeight RIGHT OUTER JOIN
                         dbo.Loads ON dbo.vwCarrierRateConfirmationWeight.LoadID = dbo.Loads.LoadID INNER JOIN
                         dbo.vwCarrierConfirmationReportFinalDestination ON dbo.Loads.LoadID = dbo.vwCarrierConfirmationReportFinalDestination.LoadID INNER JOIN
                         dbo.LoadStatusTypes ON dbo.LoadStatusTypes.StatusTypeID = dbo.Loads.StatusTypeID INNER JOIN
                         dbo.LoadStops ON dbo.Loads.LoadID = dbo.LoadStops.LoadID LEFT OUTER JOIN
                         dbo.Employees AS Employees_1 ON dbo.Loads.SalesRepID = Employees_1.EmployeeID LEFT OUTER JOIN
                         dbo.Employees ON dbo.Loads.DispatcherID = dbo.Employees.EmployeeID LEFT OUTER JOIN
                         dbo.vwSalesRepCommissionCarrierPay ON dbo.Loads.LoadID = dbo.vwSalesRepCommissionCarrierPay.LoadID LEFT OUTER JOIN
                         dbo.Equipments ON dbo.LoadStops.NewEquipmentID = dbo.Equipments.EquipmentID LEFT OUTER JOIN
                         dbo.Carriers ON dbo.LoadStops.NewCarrierID = dbo.Carriers.CarrierID INNER JOIN
                         dbo.CustomerOffices ON dbo.CustomerOffices.CustomerID = dbo.Loads.CustomerID INNER JOIN
                         dbo.Offices ON dbo.Offices.OfficeID = dbo.CustomerOffices.OfficeID INNER JOIN
                         dbo.Companies ON dbo.Companies.CompanyID = dbo.Offices.CompanyID INNER JOIN
                         dbo.SystemConfig ON dbo.SystemConfig.CompanyID = dbo.Companies.CompanyID
WHERE        (dbo.LoadStops.LoadType = 1) AND (dbo.LoadStops.StopNo + 1 = 1)
ORDER BY dbo.Offices.Location, dbo.Loads.LoadNumber
GO


