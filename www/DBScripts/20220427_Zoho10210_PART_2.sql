GO

/****** Object:  View [dbo].[ExportSalesDetail]    Script Date: 28-04-2022 12:22:32 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
ALTER  VIEW [dbo].[ExportSalesDetail]
AS
SELECT  TOP 100 PERCENT dbo.ExportSalesSummary.Dispatcher, dbo.ExportSalesSummary.SalesAgent1, dbo.ExportSalesSummary.LoadNumber, dbo.ExportSalesSummary.orderDate, dbo.ExportSalesSummary.CustName, 
                         dbo.ExportSalesSummary.[Lane Origin], dbo.ExportSalesSummary.[Lane Destination], dbo.ExportSalesSummary.TotalCarrierCharges, dbo.ExportSalesSummary.InvoiceDate, dbo.ExportSalesSummary.TotalCustomerCharges, 
                         dbo.ExportSalesSummary.GrossMargin, dbo.ExportSalesSummary.TotalMiles, dbo.ExportSalesSummary.DeadHeadMiles, dbo.ExportSalesSummary.CarrierName, dbo.ExportSalesSummary.CommissionPercent, dbo.ExportSalesSummary.CommissionAmt, dbo.ExportSalesSummary.StatusText, dbo.ExportSalesSummary.StatusDescription, 
                         dbo.ExportSalesSummary.EquiptName, dbo.ExportSalesSummary.DispatchCommissionPercent, dbo.ExportSalesSummary.DispatchCommissionAmt, dbo.ExportSalesSummary.[Carrier/Driver], 
                         dbo.ExportSalesSummary.SalesAgent, dbo.ExportSalesSummary.Payments, dbo.ExportSalesSummary.CarrierPay, dbo.ExportSalesSummary.CommissionAmountReport, dbo.ExportSalesSummary.CommissionPercentReport, 
                         dbo.ExportSalesSummary.pickupdate, dbo.ExportSalesSummary.PoNumber, dbo.ExportSalesSummary.[First Stop Name], dbo.ExportSalesSummary.[First Stop City], dbo.ExportSalesSummary.[First Stop State], 
                         dbo.ExportSalesSummary.[First Stop Zip], dbo.ExportSalesSummary.[Last Stop Name], dbo.ExportSalesSummary.[Last Stop City], dbo.ExportSalesSummary.[Last Stop State], dbo.ExportSalesSummary.[Last Stop Zip], 
                         dbo.ExportSalesSummary.WeightTotal, dbo.LoadStopCommodities.SrNo, dbo.LoadStopCommodities.Qty, dbo.LoadStopCommodities.Description + ' ' + ISNULL(dbo.LoadStopCommodities.Dimensions,'') AS Description, dbo.LoadStopCommodities.Weight, dbo.LoadStopCommodities.ClassID, 
                         dbo.LoadStopCommodities.CustCharges, dbo.LoadStopCommodities.CarrCharges, dbo.LoadStopCommodities.Fee, dbo.LoadStopCommodities.CustRate, dbo.LoadStopCommodities.CarrRate, 
                         dbo.LoadStopCommodities.CarrRateOfCustTotal,dbo.ExportSalesSummary.[Delivery Date],dbo.ExportSalesSummary.CompanyID,dbo.ExportSalesSummary.OfficeCode
FROM            dbo.LoadStopCommodities RIGHT OUTER JOIN
                         dbo.ExportSalesSummary ON dbo.LoadStopCommodities.LoadStopID = dbo.ExportSalesSummary.LoadStopID
ORDER BY dbo.ExportSalesSummary.Location, dbo.ExportSalesSummary.LoadNumber, dbo.LoadStopCommodities.SrNo
GO


