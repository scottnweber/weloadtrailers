GO

/****** Object:  View [dbo].[vwSalesDispatcher1]    Script Date: 25-03-2022 14:31:27 ******/
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
						,Officies_1.OfficeCode
FROM            dbo.Loads INNER JOIN
                         dbo.LoadStatusTypes ON dbo.Loads.StatusTypeID = dbo.LoadStatusTypes.StatusTypeID INNER JOIN
                         dbo.Customers ON dbo.Loads.CustomerID = dbo.Customers.CustomerID INNER JOIN
                         dbo.CustomerOffices ON dbo.Customers.CustomerID = dbo.CustomerOffices.CustomerID INNER JOIN
                         dbo.Offices ON dbo.CustomerOffices.OfficeID = dbo.Offices.OfficeID INNER JOIN
                         dbo.Companies ON dbo.Offices.CompanyID = dbo.Companies.CompanyID INNER JOIN
                         dbo.Employees ON dbo.Loads.DispatcherID = dbo.Employees.EmployeeID LEFT OUTER JOIN
                         dbo.Employees AS Employees_1 ON dbo.Loads.Dispatcher1 = Employees_1.EmployeeID LEFT OUTER JOIN
                         dbo.Offices AS Officies_1 ON Officies_1.OfficeID = ISNULL(Employees_1.OfficeID,dbo.Employees.OfficeID)
WHERE        (dbo.Loads.TotalCustomerCharges <> 0) OR
                         (dbo.Loads.TotalCarrierCharges <> 0)
GO


GO

/****** Object:  View [dbo].[vwSalesDispatcher2]    Script Date: 25-03-2022 14:32:20 ******/
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
						,Officies_1.OfficeCode
FROM            dbo.Loads INNER JOIN
                         dbo.LoadStatusTypes ON dbo.Loads.StatusTypeID = dbo.LoadStatusTypes.StatusTypeID INNER JOIN
                         dbo.Customers ON dbo.Loads.CustomerID = dbo.Customers.CustomerID INNER JOIN
                         dbo.CustomerOffices ON dbo.Customers.CustomerID = dbo.CustomerOffices.CustomerID INNER JOIN
                         dbo.Offices ON dbo.CustomerOffices.OfficeID = dbo.Offices.OfficeID INNER JOIN
                         dbo.Companies ON dbo.Offices.CompanyID = dbo.Companies.CompanyID INNER JOIN
                         dbo.Employees ON dbo.Loads.DispatcherID = dbo.Employees.EmployeeID LEFT OUTER JOIN
                         dbo.Employees AS Employees_1 ON dbo.Loads.Dispatcher2 = Employees_1.EmployeeID LEFT OUTER JOIN
                         dbo.Offices AS Officies_1 ON Officies_1.OfficeID = ISNULL(Employees_1.OfficeID,dbo.Employees.OfficeID)
WHERE        (dbo.Loads.TotalCustomerCharges <> 0) OR
                         (dbo.Loads.TotalCarrierCharges <> 0)
GO

GO

/****** Object:  View [dbo].[vwSalesDispatcher3]    Script Date: 25-03-2022 14:32:44 ******/
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
						,Officies_1.OfficeCode
FROM            dbo.Loads INNER JOIN
                         dbo.LoadStatusTypes ON dbo.Loads.StatusTypeID = dbo.LoadStatusTypes.StatusTypeID INNER JOIN
                         dbo.Customers ON dbo.Loads.CustomerID = dbo.Customers.CustomerID INNER JOIN
                         dbo.CustomerOffices ON dbo.Customers.CustomerID = dbo.CustomerOffices.CustomerID INNER JOIN
                         dbo.Offices ON dbo.CustomerOffices.OfficeID = dbo.Offices.OfficeID INNER JOIN
                         dbo.Companies ON dbo.Offices.CompanyID = dbo.Companies.CompanyID INNER JOIN
                         dbo.Employees ON dbo.Loads.DispatcherID = dbo.Employees.EmployeeID LEFT OUTER JOIN
                         dbo.Employees AS Employees_1 ON dbo.Loads.Dispatcher3 = Employees_1.EmployeeID LEFT OUTER JOIN
                         dbo.Offices AS Officies_1 ON Officies_1.OfficeID = ISNULL(Employees_1.OfficeID,dbo.Employees.OfficeID)
WHERE        (dbo.Loads.TotalCustomerCharges <> 0) OR
                         (dbo.Loads.TotalCarrierCharges <> 0)
GO


GO

/****** Object:  View [dbo].[vwSalesDispatcher]    Script Date: 25-03-2022 14:33:30 ******/
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

/****** Object:  View [dbo].[vwSalesSalesRep1]    Script Date: 25-03-2022 14:34:14 ******/
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
						 ,Officies_1.OfficeCode
FROM            dbo.Loads INNER JOIN
                         dbo.LoadStatusTypes ON dbo.Loads.StatusTypeID = dbo.LoadStatusTypes.StatusTypeID INNER JOIN
                         dbo.Customers ON dbo.Loads.CustomerID = dbo.Customers.CustomerID INNER JOIN
                         dbo.CustomerOffices ON dbo.Customers.CustomerID = dbo.CustomerOffices.CustomerID INNER JOIN
                         dbo.Offices ON dbo.CustomerOffices.OfficeID = dbo.Offices.OfficeID INNER JOIN
                         dbo.Companies ON dbo.Offices.CompanyID = dbo.Companies.CompanyID INNER JOIN
                         dbo.Employees ON dbo.Loads.SalesRepID = dbo.Employees.EmployeeID LEFT OUTER JOIN
                         dbo.Employees AS Employees_1 ON dbo.Loads.SalesRep1 = Employees_1.EmployeeID LEFT OUTER JOIN
                         dbo.Offices AS Officies_1 ON Officies_1.OfficeID = ISNULL(Employees_1.OfficeID,dbo.Employees.OfficeID)
WHERE        (dbo.Loads.TotalCustomerCharges <> 0) OR
                         (dbo.Loads.TotalCarrierCharges <> 0)
GO

GO

/****** Object:  View [dbo].[vwSalesSalesRep2]    Script Date: 25-03-2022 14:34:27 ******/
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
						,Officies_1.OfficeCode
FROM            dbo.Loads INNER JOIN
                         dbo.LoadStatusTypes ON dbo.Loads.StatusTypeID = dbo.LoadStatusTypes.StatusTypeID INNER JOIN
                         dbo.Customers ON dbo.Loads.CustomerID = dbo.Customers.CustomerID INNER JOIN
                         dbo.CustomerOffices ON dbo.Customers.CustomerID = dbo.CustomerOffices.CustomerID INNER JOIN
                         dbo.Offices ON dbo.CustomerOffices.OfficeID = dbo.Offices.OfficeID INNER JOIN
                         dbo.Companies ON dbo.Offices.CompanyID = dbo.Companies.CompanyID INNER JOIN
                         dbo.Employees ON dbo.Loads.SalesRepID = dbo.Employees.EmployeeID LEFT OUTER JOIN
                         dbo.Employees AS Employees_1 ON dbo.Loads.SalesRep2 = Employees_1.EmployeeID LEFT OUTER JOIN
                         dbo.Offices AS Officies_1 ON Officies_1.OfficeID = ISNULL(Employees_1.OfficeID,dbo.Employees.OfficeID)
WHERE        (dbo.Loads.TotalCustomerCharges <> 0) OR
                         (dbo.Loads.TotalCarrierCharges <> 0)
GO



GO

/****** Object:  View [dbo].[vwSalesSalesRep3]    Script Date: 25-03-2022 14:34:51 ******/
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
						,Officies_1.OfficeCode
FROM            dbo.Loads INNER JOIN
                         dbo.LoadStatusTypes ON dbo.Loads.StatusTypeID = dbo.LoadStatusTypes.StatusTypeID INNER JOIN
                         dbo.Customers ON dbo.Loads.CustomerID = dbo.Customers.CustomerID INNER JOIN
                         dbo.CustomerOffices ON dbo.Customers.CustomerID = dbo.CustomerOffices.CustomerID INNER JOIN
                         dbo.Offices ON dbo.CustomerOffices.OfficeID = dbo.Offices.OfficeID INNER JOIN
                         dbo.Companies ON dbo.Offices.CompanyID = dbo.Companies.CompanyID INNER JOIN
                         dbo.Employees ON dbo.Loads.SalesRepID = dbo.Employees.EmployeeID LEFT OUTER JOIN
                         dbo.Employees AS Employees_1 ON dbo.Loads.SalesRep3 = Employees_1.EmployeeID LEFT OUTER JOIN
                         dbo.Offices AS Officies_1 ON Officies_1.OfficeID = ISNULL(Employees_1.OfficeID,dbo.Employees.OfficeID)
WHERE        (dbo.Loads.TotalCustomerCharges <> 0) OR
                         (dbo.Loads.TotalCarrierCharges <> 0)
GO


GO

/****** Object:  View [dbo].[vwSalesSalesRep]    Script Date: 25-03-2022 14:35:42 ******/
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

/****** Object:  View [dbo].[vwSales]    Script Date: 25-03-2022 14:36:23 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER   VIEW [dbo].[vwSales]
AS
SELECT        dbo.Companies.CompanyID, dbo.Loads.LoadID, dbo.Loads.LoadNumber, dbo.Loads.HasLateStop, dbo.LoadStatusTypes.StatusText, dbo.Loads.NewPickupDate AS PickupDate, dbo.Loads.NewDeliveryDate AS DeliveryDate, dbo.Loads.BillDate AS InvoiceDate, dbo.Loads.CreatedDateTime AS CreatedDate, dbo.Customers.CustomerName, dbo.Loads.CarrierName, 
                         dbo.Loads.ShipperCity + ', ' + dbo.Loads.ShipperState + ' - ' + dbo.Loads.ConsigneeCity + ', ' + dbo.Loads.ConsigneeState AS PickupCityStateDeliveryCityState, 
                         dbo.Loads.TotalCustomerCharges AS [Cust Amt], dbo.Loads.TotalCarrierCharges AS [Carr Amt], '0' AS [Direct Cost], dbo.Loads.TotalCustomerCharges - dbo.Loads.TotalCarrierCharges AS Margin, CASE WHEN (dbo.loads.Dispatcher1 IS NOT NULL OR dbo.loads.Dispatcher2 IS NOT NULL OR dbo.loads.Dispatcher3 IS NOT NULL) THEN dbo.loads.Dispatcher1Percentage+dbo.loads.Dispatcher2Percentage+dbo.loads.Dispatcher3Percentage ELSE dbo.employees.salescommission END AS [Comm %], ((CASE WHEN (dbo.loads.Dispatcher1 IS NOT NULL OR dbo.loads.Dispatcher2 IS NOT NULL OR dbo.loads.Dispatcher3 IS NOT NULL) THEN dbo.loads.Dispatcher1Percentage+dbo.loads.Dispatcher2Percentage+dbo.loads.Dispatcher3Percentage ELSE dbo.employees.salescommission END) * .01) * (dbo.Loads.TotalCustomerCharges - dbo.Loads.TotalCarrierCharges) AS [Comm Amt]
						,dbo.Offices.OfficeCode
FROM            dbo.Loads INNER JOIN
                         dbo.LoadStatusTypes ON dbo.Loads.StatusTypeID = dbo.LoadStatusTypes.StatusTypeID INNER JOIN
                         dbo.Customers ON dbo.Loads.CustomerID = dbo.Customers.CustomerID INNER JOIN
                         dbo.CustomerOffices ON dbo.Customers.CustomerID = dbo.CustomerOffices.CustomerID INNER JOIN
                         dbo.Offices ON dbo.CustomerOffices.OfficeID = dbo.Offices.OfficeID INNER JOIN
                         dbo.Companies ON dbo.Offices.CompanyID = dbo.Companies.CompanyID INNER JOIN
                         dbo.Employees ON dbo.Loads.DispatcherID = dbo.Employees.EmployeeID
WHERE        (dbo.Loads.TotalCustomerCharges <> 0) OR
                         (dbo.Loads.TotalCarrierCharges <> 0)
GO


GO

/****** Object:  View [dbo].[vwSalesDetailDispatcher1Cmdty]    Script Date: 3/16/2022 9:44:28 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER VIEW [dbo].[vwSalesDetailDispatcher1Cmdty]
AS
SELECT        dbo.Companies.CompanyID, ISNULL(Employees_1.Name, dbo.Employees.Name) AS Dispatcher, dbo.Loads.LoadID, dbo.Loads.LoadNumber, dbo.Loads.HasLateStop, dbo.LoadStatusTypes.StatusText, dbo.Loads.NewPickupDate AS PickupDate, dbo.Loads.NewDeliveryDate AS DeliveryDate, dbo.Loads.BillDate AS InvoiceDate, dbo.Loads.CreatedDateTime AS CreatedDate, dbo.Customers.CustomerName, dbo.Loads.CarrierName, 
                         dbo.Loads.ShipperCity + ', ' + dbo.Loads.ShipperState + ' - ' + dbo.Loads.ConsigneeCity + ', ' + dbo.Loads.ConsigneeState AS PickupCityStateDeliveryCityState, dbo.LoadStopCommodities.Qty, 
                         dbo.LoadStopCommodities.Description, dbo.LoadStopCommodities.Weight AS LBS, dbo.LoadStopCommodities.CustCharges AS [Cust Amt], dbo.LoadStopCommodities.CarrCharges AS [Carr Amt], 
                         ISNULL(dbo.LoadStopCommodities.DirectCostTotal,0) AS [Direct Cost], dbo.LoadStopCommodities.CustCharges - dbo.LoadStopCommodities.CarrCharges - ISNULL(ISNULL(dbo.LoadStopCommodities.DirectCostTotal,0), 0) AS Margin, 
                         CASE WHEN ISNULL(Employees_1.Name, '0') <> '0' THEN dbo.loads.Dispatcher1Percentage ELSE dbo.employees.salescommission END AS [Comm %], ((CASE WHEN ISNULL(Employees_1.Name, '0') 
                         <> '0' THEN dbo.loads.Dispatcher1Percentage ELSE dbo.employees.salescommission END) * 0.01) 
                         * (dbo.LoadStopCommodities.CustCharges - dbo.LoadStopCommodities.CarrCharges - ISNULL(ISNULL(dbo.LoadStopCommodities.DirectCostTotal,0), 0)) AS [Comm Amt]
FROM            dbo.Loads INNER JOIN
                         dbo.LoadStatusTypes ON dbo.Loads.StatusTypeID = dbo.LoadStatusTypes.StatusTypeID INNER JOIN
                         dbo.Customers ON dbo.Loads.CustomerID = dbo.Customers.CustomerID INNER JOIN
                         dbo.CustomerOffices ON dbo.Customers.CustomerID = dbo.CustomerOffices.CustomerID INNER JOIN
                         dbo.Offices ON dbo.CustomerOffices.OfficeID = dbo.Offices.OfficeID INNER JOIN
                         dbo.Companies ON dbo.Offices.CompanyID = dbo.Companies.CompanyID INNER JOIN
                         dbo.Employees ON dbo.Loads.DispatcherID = dbo.Employees.EmployeeID INNER JOIN
                         dbo.LoadStops ON dbo.Loads.LoadID = dbo.LoadStops.LoadID INNER JOIN
                         dbo.LoadStopCommodities ON dbo.LoadStops.LoadStopID = dbo.LoadStopCommodities.LoadStopID LEFT OUTER JOIN
                         dbo.Employees AS Employees_1 ON dbo.Loads.Dispatcher1 = Employees_1.EmployeeID
WHERE        (dbo.LoadStopCommodities.Description <> N'') OR
                         (dbo.LoadStopCommodities.Weight <> 0) OR
                         (dbo.LoadStopCommodities.CustCharges <> 0) OR
                         (dbo.LoadStopCommodities.CarrCharges <> 0) OR
                         (ISNULL(dbo.LoadStopCommodities.DirectCostTotal,0) <> 0)
GO



GO

/****** Object:  View [dbo].[vwSalesDetailDispatcher1FlatRate]    Script Date: 3/16/2022 9:47:29 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER VIEW [dbo].[vwSalesDetailDispatcher1FlatRate]
AS
SELECT        dbo.Companies.CompanyID, ISNULL(Employees_1.Name, dbo.Employees.Name) AS Dispatcher, dbo.Loads.LoadID, dbo.Loads.LoadNumber, dbo.Loads.HasLateStop, dbo.LoadStatusTypes.StatusText, dbo.Loads.NewPickupDate AS PickupDate, dbo.Loads.NewDeliveryDate AS DeliveryDate, dbo.Loads.BillDate AS InvoiceDate, dbo.Loads.CreatedDateTime AS CreatedDate, dbo.Customers.CustomerName, dbo.Loads.CarrierName, 
                         dbo.Loads.ShipperCity + ', ' + dbo.Loads.ShipperState + ' - ' + dbo.Loads.ConsigneeCity + ', ' + dbo.Loads.ConsigneeState AS PickupCityStateDeliveryCityState, '1' AS Qty, 'Flat Rate' AS Descrition, '0' AS LBS, 
                         dbo.Loads.CustFlatRate AS [Cust Amt], dbo.Loads.CarrFlatRate AS [Carr Amt], '0' AS [Direct Cost], dbo.Loads.CustFlatRate - dbo.Loads.CarrFlatRate AS Margin, CASE WHEN ISNULL(Employees_1.Name, '0') 
                         <> '0' THEN dbo.loads.Dispatcher1Percentage ELSE dbo.employees.salescommission END AS [Comm %], ((CASE WHEN ISNULL(Employees_1.Name, '0') 
                         <> '0' THEN dbo.loads.Dispatcher1Percentage ELSE dbo.employees.salescommission END) * .01) * (dbo.Loads.CustFlatRate - dbo.Loads.CarrFlatRate) AS [Comm Amt]
FROM            dbo.Loads INNER JOIN
                         dbo.LoadStatusTypes ON dbo.Loads.StatusTypeID = dbo.LoadStatusTypes.StatusTypeID INNER JOIN
                         dbo.Customers ON dbo.Loads.CustomerID = dbo.Customers.CustomerID INNER JOIN
                         dbo.CustomerOffices ON dbo.Customers.CustomerID = dbo.CustomerOffices.CustomerID INNER JOIN
                         dbo.Offices ON dbo.CustomerOffices.OfficeID = dbo.Offices.OfficeID INNER JOIN
                         dbo.Companies ON dbo.Offices.CompanyID = dbo.Companies.CompanyID INNER JOIN
                         dbo.Employees ON dbo.Loads.DispatcherID = dbo.Employees.EmployeeID LEFT OUTER JOIN
                         dbo.Employees AS Employees_1 ON dbo.Loads.Dispatcher1 = Employees_1.EmployeeID
WHERE        (dbo.Loads.CarrFlatRate <> 0) OR
                         (dbo.Loads.CustFlatRate <> 0)
GO



GO

/****** Object:  View [dbo].[vwSalesDetailDispatcher1MilesRate]    Script Date: 3/16/2022 9:50:42 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER VIEW [dbo].[vwSalesDetailDispatcher1MilesRate]
AS
SELECT        dbo.Companies.CompanyID, ISNULL(Employees_1.Name, dbo.Employees.Name) AS Dispatcher, dbo.Loads.LoadID, dbo.Loads.LoadNumber, dbo.Loads.HasLateStop, dbo.LoadStatusTypes.StatusText, dbo.Loads.NewPickupDate AS PickupDate, dbo.Loads.NewDeliveryDate AS DeliveryDate, dbo.Loads.BillDate AS InvoiceDate, dbo.Loads.CreatedDateTime AS CreatedDate, dbo.Customers.CustomerName, dbo.Loads.CarrierName, 
                         dbo.Loads.ShipperCity + ', ' + dbo.Loads.ShipperState + ' - ' + dbo.Loads.ConsigneeCity + ', ' + dbo.Loads.ConsigneeState AS PickupCityStateDeliveryCityState, '1' AS Qty, 'Miles Charge' AS Descrition, '0' AS LBS, 
                         dbo.Loads.CustomerRatePerMile * dbo.Loads.TotalMiles AS [Cust Amt], dbo.Loads.CarrierRatePerMile * dbo.Loads.TotalMiles AS [Carr Amt], '0' AS [Direct Cost], 
                         dbo.Loads.CustomerRatePerMile * dbo.Loads.TotalMiles - dbo.Loads.CarrierRatePerMile * dbo.Loads.TotalMiles AS Margin, CASE WHEN ISNULL(Employees_1.Name, '0') 
                         <> '0' THEN dbo.loads.Dispatcher1Percentage ELSE dbo.employees.salescommission END AS [Comm %], ((CASE WHEN ISNULL(Employees_1.Name, '0') 
                         <> '0' THEN dbo.loads.Dispatcher1Percentage ELSE dbo.employees.salescommission END) * .01) * (dbo.Loads.CustomerRatePerMile * dbo.Loads.TotalMiles - dbo.Loads.CarrierRatePerMile * dbo.Loads.TotalMiles) 
                         AS [Comm Amt]
FROM            dbo.Loads INNER JOIN
                         dbo.LoadStatusTypes ON dbo.Loads.StatusTypeID = dbo.LoadStatusTypes.StatusTypeID INNER JOIN
                         dbo.Customers ON dbo.Loads.CustomerID = dbo.Customers.CustomerID INNER JOIN
                         dbo.CustomerOffices ON dbo.Customers.CustomerID = dbo.CustomerOffices.CustomerID INNER JOIN
                         dbo.Offices ON dbo.CustomerOffices.OfficeID = dbo.Offices.OfficeID INNER JOIN
                         dbo.Companies ON dbo.Offices.CompanyID = dbo.Companies.CompanyID INNER JOIN
                         dbo.Employees ON dbo.Loads.DispatcherID = dbo.Employees.EmployeeID LEFT OUTER JOIN
                         dbo.Employees AS Employees_1 ON dbo.Loads.Dispatcher1 = Employees_1.EmployeeID
WHERE        (dbo.Loads.CustomerRatePerMile * dbo.Loads.TotalMiles <> 0) OR
                         (dbo.Loads.CarrierRatePerMile * dbo.Loads.TotalMiles <> 0)
GO


GO

/****** Object:  View [dbo].[vwSalesDetailDispatcher2Cmdty]    Script Date: 3/16/2022 10:00:55 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER VIEW [dbo].[vwSalesDetailDispatcher2Cmdty]
AS
SELECT        dbo.Companies.CompanyID, dbo.Employees.Name AS Dispatcher, dbo.Loads.LoadID, dbo.Loads.LoadNumber, dbo.Loads.HasLateStop, dbo.LoadStatusTypes.StatusText, dbo.Loads.NewPickupDate AS PickupDate, dbo.Loads.NewDeliveryDate AS DeliveryDate, dbo.Loads.BillDate AS InvoiceDate, dbo.Loads.CreatedDateTime AS CreatedDate, dbo.Customers.CustomerName, dbo.Loads.CarrierName, 
                         dbo.Loads.ShipperCity + ', ' + dbo.Loads.ShipperState + ' - ' + dbo.Loads.ConsigneeCity + ', ' + dbo.Loads.ConsigneeState AS PickupCityStateDeliveryCityState, dbo.LoadStopCommodities.Qty, 
                         dbo.LoadStopCommodities.Description, dbo.LoadStopCommodities.Weight AS LBS, dbo.LoadStopCommodities.CustCharges AS [Cust Amt], dbo.LoadStopCommodities.CarrCharges AS [Carr Amt], 
                         ISNULL(dbo.LoadStopCommodities.DirectCostTotal,0) AS [Direct Cost], dbo.LoadStopCommodities.CustCharges - dbo.LoadStopCommodities.CarrCharges - ISNULL(ISNULL(dbo.LoadStopCommodities.DirectCostTotal,0), 0) AS Margin, 
                         dbo.Loads.Dispatcher2Percentage AS [Comm %], (dbo.Loads.Dispatcher2Percentage * 0.01) 
                         * (dbo.LoadStopCommodities.CustCharges - dbo.LoadStopCommodities.CarrCharges - ISNULL(ISNULL(dbo.LoadStopCommodities.DirectCostTotal,0), 0)) AS [Comm Amt]
FROM            dbo.Loads INNER JOIN
                         dbo.LoadStatusTypes ON dbo.Loads.StatusTypeID = dbo.LoadStatusTypes.StatusTypeID INNER JOIN
                         dbo.Customers ON dbo.Loads.CustomerID = dbo.Customers.CustomerID INNER JOIN
                         dbo.CustomerOffices ON dbo.Customers.CustomerID = dbo.CustomerOffices.CustomerID INNER JOIN
                         dbo.Offices ON dbo.CustomerOffices.OfficeID = dbo.Offices.OfficeID INNER JOIN
                         dbo.Companies ON dbo.Offices.CompanyID = dbo.Companies.CompanyID INNER JOIN
                         dbo.LoadStops ON dbo.Loads.LoadID = dbo.LoadStops.LoadID INNER JOIN
                         dbo.LoadStopCommodities ON dbo.LoadStops.LoadStopID = dbo.LoadStopCommodities.LoadStopID INNER JOIN
                         dbo.Employees ON dbo.Loads.Dispatcher2 = dbo.Employees.EmployeeID
WHERE        (dbo.LoadStopCommodities.Description <> N'') OR
                         (dbo.LoadStopCommodities.Weight <> 0) OR
                         (dbo.LoadStopCommodities.CustCharges <> 0) OR
                         (dbo.LoadStopCommodities.CarrCharges <> 0) OR
                         (ISNULL(dbo.LoadStopCommodities.DirectCostTotal,0) <> 0)
GO



GO

/****** Object:  View [dbo].[vwSalesDetailDispatcher2FlatRate]    Script Date: 3/16/2022 10:05:45 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER VIEW [dbo].[vwSalesDetailDispatcher2FlatRate]
AS
SELECT        dbo.Companies.CompanyID, dbo.Employees.Name AS Dispatcher, dbo.Loads.LoadID, dbo.Loads.LoadNumber, dbo.Loads.HasLateStop, dbo.LoadStatusTypes.StatusText, dbo.Loads.NewPickupDate AS PickupDate, dbo.Loads.NewDeliveryDate AS DeliveryDate, dbo.Loads.BillDate AS InvoiceDate, dbo.Loads.CreatedDateTime AS CreatedDate, dbo.Customers.CustomerName, dbo.Loads.CarrierName, 
                         dbo.Loads.ShipperCity + ', ' + dbo.Loads.ShipperState + ' - ' + dbo.Loads.ConsigneeCity + ', ' + dbo.Loads.ConsigneeState AS PickupCityStateDeliveryCityState, '1' AS Qty, 'Flat Rate' AS Descrition, '0' AS LBS, 
                         dbo.Loads.CustFlatRate AS [Cust Amt], dbo.Loads.CarrFlatRate AS [Carr Amt], '0' AS [Direct Cost], dbo.Loads.CustFlatRate - dbo.Loads.CarrFlatRate AS Margin, dbo.Loads.Dispatcher2Percentage AS [Comm %], 
                         (dbo.Loads.Dispatcher2Percentage * 0.01) * (dbo.Loads.CustFlatRate - dbo.Loads.CarrFlatRate) AS [Comm Amt]
FROM            dbo.Loads INNER JOIN
                         dbo.LoadStatusTypes ON dbo.Loads.StatusTypeID = dbo.LoadStatusTypes.StatusTypeID INNER JOIN
                         dbo.Customers ON dbo.Loads.CustomerID = dbo.Customers.CustomerID INNER JOIN
                         dbo.CustomerOffices ON dbo.Customers.CustomerID = dbo.CustomerOffices.CustomerID INNER JOIN
                         dbo.Offices ON dbo.CustomerOffices.OfficeID = dbo.Offices.OfficeID INNER JOIN
                         dbo.Companies ON dbo.Offices.CompanyID = dbo.Companies.CompanyID INNER JOIN
                         dbo.Employees ON dbo.Loads.Dispatcher2 = dbo.Employees.EmployeeID
WHERE        (dbo.Loads.CustFlatRate <> 0) OR
                         (dbo.Loads.CarrFlatRate <> 0)
GO



GO

/****** Object:  View [dbo].[vwSalesDetailDispatcher2MilesRate]    Script Date: 3/16/2022 10:06:55 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER VIEW [dbo].[vwSalesDetailDispatcher2MilesRate]
AS
SELECT        dbo.Companies.CompanyID, dbo.Employees.Name AS Dispatcher, dbo.Loads.LoadID, dbo.Loads.LoadNumber, dbo.Loads.HasLateStop, dbo.LoadStatusTypes.StatusText, dbo.Loads.NewPickupDate AS PickupDate, dbo.Loads.NewDeliveryDate AS DeliveryDate, dbo.Loads.BillDate AS InvoiceDate, dbo.Loads.CreatedDateTime AS CreatedDate, dbo.Customers.CustomerName, dbo.Loads.CarrierName, 
                         dbo.Loads.ShipperCity + ', ' + dbo.Loads.ShipperState + ' - ' + dbo.Loads.ConsigneeCity + ', ' + dbo.Loads.ConsigneeState AS PickupCityStateDeliveryCityState, '1' AS Qty, 'Miles Charge' AS Descrition, '0' AS LBS, 
                         dbo.Loads.CustomerRatePerMile * dbo.Loads.TotalMiles AS [Cust Amt], dbo.Loads.CarrierRatePerMile * dbo.Loads.TotalMiles AS [Carr Amt], '0' AS [Direct Cost], 
                         dbo.Loads.CustomerRatePerMile * dbo.Loads.TotalMiles - dbo.Loads.CarrierRatePerMile * dbo.Loads.TotalMiles AS Margin, dbo.Loads.Dispatcher2Percentage AS [Comm %], (dbo.Loads.Dispatcher2Percentage * 0.01) 
                         * (dbo.Loads.CustomerRatePerMile * dbo.Loads.TotalMiles - dbo.Loads.CarrierRatePerMile * dbo.Loads.TotalMiles) AS [Comm Amt]
FROM            dbo.Loads INNER JOIN
                         dbo.LoadStatusTypes ON dbo.Loads.StatusTypeID = dbo.LoadStatusTypes.StatusTypeID INNER JOIN
                         dbo.Customers ON dbo.Loads.CustomerID = dbo.Customers.CustomerID INNER JOIN
                         dbo.CustomerOffices ON dbo.Customers.CustomerID = dbo.CustomerOffices.CustomerID INNER JOIN
                         dbo.Offices ON dbo.CustomerOffices.OfficeID = dbo.Offices.OfficeID INNER JOIN
                         dbo.Companies ON dbo.Offices.CompanyID = dbo.Companies.CompanyID INNER JOIN
                         dbo.Employees ON dbo.Loads.Dispatcher2 = dbo.Employees.EmployeeID
WHERE        (dbo.Loads.CustomerRatePerMile * dbo.Loads.TotalMiles <> 0) OR
                         (dbo.Loads.CarrierRatePerMile * dbo.Loads.TotalMiles <> 0)
GO


GO

/****** Object:  View [dbo].[vwSalesDetailDispatcher3Cmdty]    Script Date: 3/16/2022 10:10:13 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER VIEW [dbo].[vwSalesDetailDispatcher3Cmdty]
AS
SELECT        dbo.Companies.CompanyID, dbo.Employees.Name AS Dispatcher, dbo.Loads.LoadID, dbo.Loads.LoadNumber, dbo.Loads.HasLateStop, dbo.LoadStatusTypes.StatusText, dbo.Loads.NewPickupDate AS PickupDate, dbo.Loads.NewDeliveryDate AS DeliveryDate, dbo.Loads.BillDate AS InvoiceDate, dbo.Loads.CreatedDateTime AS CreatedDate, dbo.Customers.CustomerName, dbo.Loads.CarrierName, 
                         dbo.Loads.ShipperCity + ', ' + dbo.Loads.ShipperState + ' - ' + dbo.Loads.ConsigneeCity + ', ' + dbo.Loads.ConsigneeState AS PickupCityStateDeliveryCityState, dbo.LoadStopCommodities.Qty, 
                         dbo.LoadStopCommodities.Description, dbo.LoadStopCommodities.Weight AS LBS, dbo.LoadStopCommodities.CustCharges AS [Cust Amt], dbo.LoadStopCommodities.CarrCharges AS [Carr Amt], 
                         ISNULL(dbo.LoadStopCommodities.DirectCostTotal,0) AS [Direct Cost], dbo.LoadStopCommodities.CustCharges - dbo.LoadStopCommodities.CarrCharges - ISNULL(ISNULL(dbo.LoadStopCommodities.DirectCostTotal,0), 0) AS Margin, 
                         dbo.Loads.Dispatcher3Percentage AS [Comm %], (dbo.Loads.Dispatcher3Percentage * 0.01) 
                         * (dbo.LoadStopCommodities.CustCharges - dbo.LoadStopCommodities.CarrCharges - ISNULL(ISNULL(dbo.LoadStopCommodities.DirectCostTotal,0), 0)) AS [Comm Amt]
FROM            dbo.Loads INNER JOIN
                         dbo.LoadStatusTypes ON dbo.Loads.StatusTypeID = dbo.LoadStatusTypes.StatusTypeID INNER JOIN
                         dbo.Customers ON dbo.Loads.CustomerID = dbo.Customers.CustomerID INNER JOIN
                         dbo.CustomerOffices ON dbo.Customers.CustomerID = dbo.CustomerOffices.CustomerID INNER JOIN
                         dbo.Offices ON dbo.CustomerOffices.OfficeID = dbo.Offices.OfficeID INNER JOIN
                         dbo.Companies ON dbo.Offices.CompanyID = dbo.Companies.CompanyID INNER JOIN
                         dbo.LoadStops ON dbo.Loads.LoadID = dbo.LoadStops.LoadID INNER JOIN
                         dbo.LoadStopCommodities ON dbo.LoadStops.LoadStopID = dbo.LoadStopCommodities.LoadStopID INNER JOIN
                         dbo.Employees ON dbo.Loads.Dispatcher3 = dbo.Employees.EmployeeID
WHERE        (dbo.LoadStopCommodities.Description <> N'') OR
                         (dbo.LoadStopCommodities.Weight <> 0) OR
                         (dbo.LoadStopCommodities.CustCharges <> 0) OR
                         (dbo.LoadStopCommodities.CarrCharges <> 0) OR
                         (ISNULL(dbo.LoadStopCommodities.DirectCostTotal,0) <> 0)
GO


GO

/****** Object:  View [dbo].[vwSalesDetailDispatcher3FlatRate]    Script Date: 3/16/2022 10:11:45 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER VIEW [dbo].[vwSalesDetailDispatcher3FlatRate]
AS
SELECT        dbo.Companies.CompanyID, dbo.Employees.Name AS Dispatcher, dbo.Loads.LoadID, dbo.Loads.LoadNumber, dbo.Loads.HasLateStop, dbo.LoadStatusTypes.StatusText, dbo.Loads.NewPickupDate AS PickupDate, dbo.Loads.NewDeliveryDate AS DeliveryDate, dbo.Loads.BillDate AS InvoiceDate, dbo.Loads.CreatedDateTime AS CreatedDate, dbo.Customers.CustomerName, dbo.Loads.CarrierName, 
                         dbo.Loads.ShipperCity + ', ' + dbo.Loads.ShipperState + ' - ' + dbo.Loads.ConsigneeCity + ', ' + dbo.Loads.ConsigneeState AS PickupCityStateDeliveryCityState, '1' AS Qty, 'Flat Rate' AS Descrition, '0' AS LBS, 
                         dbo.Loads.CustFlatRate AS [Cust Amt], dbo.Loads.CarrFlatRate AS [Carr Amt], '0' AS [Direct Cost], dbo.Loads.CustFlatRate - dbo.Loads.CarrFlatRate AS Margin, dbo.Loads.Dispatcher3Percentage AS [Comm %], 
                         (dbo.Loads.Dispatcher3Percentage * 0.01) * (dbo.Loads.CustFlatRate - dbo.Loads.CarrFlatRate) AS [Comm Amt]
FROM            dbo.Loads INNER JOIN
                         dbo.LoadStatusTypes ON dbo.Loads.StatusTypeID = dbo.LoadStatusTypes.StatusTypeID INNER JOIN
                         dbo.Customers ON dbo.Loads.CustomerID = dbo.Customers.CustomerID INNER JOIN
                         dbo.CustomerOffices ON dbo.Customers.CustomerID = dbo.CustomerOffices.CustomerID INNER JOIN
                         dbo.Offices ON dbo.CustomerOffices.OfficeID = dbo.Offices.OfficeID INNER JOIN
                         dbo.Companies ON dbo.Offices.CompanyID = dbo.Companies.CompanyID INNER JOIN
                         dbo.Employees ON dbo.Loads.Dispatcher3 = dbo.Employees.EmployeeID
WHERE        (dbo.Loads.CustFlatRate <> 0) OR
                         (dbo.Loads.CarrFlatRate <> 0)
GO


GO

/****** Object:  View [dbo].[vwSalesDetailDispatcher3MilesRate]    Script Date: 3/16/2022 10:13:28 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER VIEW [dbo].[vwSalesDetailDispatcher3MilesRate]
AS
SELECT        dbo.Companies.CompanyID, dbo.Employees.Name AS Dispatcher, dbo.Loads.LoadID, dbo.Loads.LoadNumber, dbo.Loads.HasLateStop, dbo.LoadStatusTypes.StatusText, dbo.Loads.NewPickupDate AS PickupDate, dbo.Loads.NewDeliveryDate AS DeliveryDate, dbo.Loads.BillDate AS InvoiceDate, dbo.Loads.CreatedDateTime AS CreatedDate, dbo.Customers.CustomerName, dbo.Loads.CarrierName, 
                         dbo.Loads.ShipperCity + ', ' + dbo.Loads.ShipperState + ' - ' + dbo.Loads.ConsigneeCity + ', ' + dbo.Loads.ConsigneeState AS PickupCityStateDeliveryCityState, '1' AS Qty, 'Miles Charge' AS Descrition, '0' AS LBS, 
                         dbo.Loads.CustomerRatePerMile * dbo.Loads.TotalMiles AS [Cust Amt], dbo.Loads.CarrierRatePerMile * dbo.Loads.TotalMiles AS [Carr Amt], '0' AS [Direct Cost], 
                         dbo.Loads.CustomerRatePerMile * dbo.Loads.TotalMiles - dbo.Loads.CarrierRatePerMile * dbo.Loads.TotalMiles AS Margin, dbo.Loads.Dispatcher3Percentage AS [Comm %], (dbo.Loads.Dispatcher3Percentage * 0.01) 
                         * (dbo.Loads.CustomerRatePerMile * dbo.Loads.TotalMiles - dbo.Loads.CarrierRatePerMile * dbo.Loads.TotalMiles) AS [Comm Amt]
FROM            dbo.Loads INNER JOIN
                         dbo.LoadStatusTypes ON dbo.Loads.StatusTypeID = dbo.LoadStatusTypes.StatusTypeID INNER JOIN
                         dbo.Customers ON dbo.Loads.CustomerID = dbo.Customers.CustomerID INNER JOIN
                         dbo.CustomerOffices ON dbo.Customers.CustomerID = dbo.CustomerOffices.CustomerID INNER JOIN
                         dbo.Offices ON dbo.CustomerOffices.OfficeID = dbo.Offices.OfficeID INNER JOIN
                         dbo.Companies ON dbo.Offices.CompanyID = dbo.Companies.CompanyID INNER JOIN
                         dbo.Employees ON dbo.Loads.Dispatcher3 = dbo.Employees.EmployeeID
WHERE        (dbo.Loads.CustomerRatePerMile * dbo.Loads.TotalMiles <> 0) OR
                         (dbo.Loads.CarrierRatePerMile * dbo.Loads.TotalMiles <> 0)
GO


GO

/****** Object:  View [dbo].[vwSalesDetailDispatcher]    Script Date: 3/16/2022 9:43:27 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER VIEW [dbo].[vwSalesDetailDispatcher]
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

/****** Object:  View [dbo].[vwSalesDetailSalesRep1Cmdty]    Script Date: 3/16/2022 9:44:28 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER VIEW [dbo].[vwSalesDetailSalesRep1Cmdty]
AS
SELECT        dbo.Companies.CompanyID, ISNULL(Employees_1.Name, dbo.Employees.Name) AS SalesRep, dbo.Loads.LoadID, dbo.Loads.LoadNumber, dbo.Loads.HasLateStop, dbo.LoadStatusTypes.StatusText, dbo.Loads.NewPickupDate AS PickupDate, dbo.Loads.NewDeliveryDate AS DeliveryDate, dbo.Loads.BillDate AS InvoiceDate, dbo.Loads.CreatedDateTime AS CreatedDate, dbo.Customers.CustomerName, dbo.Loads.CarrierName, 
                         dbo.Loads.ShipperCity + ', ' + dbo.Loads.ShipperState + ' - ' + dbo.Loads.ConsigneeCity + ', ' + dbo.Loads.ConsigneeState AS PickupCityStateDeliveryCityState, dbo.LoadStopCommodities.Qty, 
                         dbo.LoadStopCommodities.Description, dbo.LoadStopCommodities.Weight AS LBS, dbo.LoadStopCommodities.CustCharges AS [Cust Amt], dbo.LoadStopCommodities.CarrCharges AS [Carr Amt], 
                         ISNULL(dbo.LoadStopCommodities.DirectCostTotal,0) AS [Direct Cost], dbo.LoadStopCommodities.CustCharges - dbo.LoadStopCommodities.CarrCharges - ISNULL(ISNULL(dbo.LoadStopCommodities.DirectCostTotal,0), 0) AS Margin, 
                         CASE WHEN ISNULL(Employees_1.Name, '0') <> '0' THEN dbo.loads.SalesRep1Percentage ELSE dbo.employees.salescommission END AS [Comm %], ((CASE WHEN ISNULL(Employees_1.Name, '0') 
                         <> '0' THEN dbo.loads.SalesRep1Percentage ELSE dbo.employees.salescommission END) * 0.01) 
                         * (dbo.LoadStopCommodities.CustCharges - dbo.LoadStopCommodities.CarrCharges - ISNULL(ISNULL(dbo.LoadStopCommodities.DirectCostTotal,0), 0)) AS [Comm Amt]
FROM            dbo.Loads INNER JOIN
                         dbo.LoadStatusTypes ON dbo.Loads.StatusTypeID = dbo.LoadStatusTypes.StatusTypeID INNER JOIN
                         dbo.Customers ON dbo.Loads.CustomerID = dbo.Customers.CustomerID INNER JOIN
                         dbo.CustomerOffices ON dbo.Customers.CustomerID = dbo.CustomerOffices.CustomerID INNER JOIN
                         dbo.Offices ON dbo.CustomerOffices.OfficeID = dbo.Offices.OfficeID INNER JOIN
                         dbo.Companies ON dbo.Offices.CompanyID = dbo.Companies.CompanyID INNER JOIN
                         dbo.Employees ON dbo.Loads.SalesRepID = dbo.Employees.EmployeeID INNER JOIN
                         dbo.LoadStops ON dbo.Loads.LoadID = dbo.LoadStops.LoadID INNER JOIN
                         dbo.LoadStopCommodities ON dbo.LoadStops.LoadStopID = dbo.LoadStopCommodities.LoadStopID LEFT OUTER JOIN
                         dbo.Employees AS Employees_1 ON dbo.Loads.SalesRep1 = Employees_1.EmployeeID
WHERE        (dbo.LoadStopCommodities.Description <> N'') OR
                         (dbo.LoadStopCommodities.Weight <> 0) OR
                         (dbo.LoadStopCommodities.CustCharges <> 0) OR
                         (dbo.LoadStopCommodities.CarrCharges <> 0) OR
                         (ISNULL(dbo.LoadStopCommodities.DirectCostTotal,0) <> 0)
GO



GO

/****** Object:  View [dbo].[vwSalesDetailSalesRep1FlatRate]    Script Date: 3/16/2022 9:47:29 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER VIEW [dbo].[vwSalesDetailSalesRep1FlatRate]
AS
SELECT        dbo.Companies.CompanyID, ISNULL(Employees_1.Name, dbo.Employees.Name) AS SalesRep, dbo.Loads.LoadID, dbo.Loads.LoadNumber, dbo.Loads.HasLateStop, dbo.LoadStatusTypes.StatusText, dbo.Loads.NewPickupDate AS PickupDate, dbo.Loads.NewDeliveryDate AS DeliveryDate, dbo.Loads.BillDate AS InvoiceDate, dbo.Loads.CreatedDateTime AS CreatedDate, dbo.Customers.CustomerName, dbo.Loads.CarrierName, 
                         dbo.Loads.ShipperCity + ', ' + dbo.Loads.ShipperState + ' - ' + dbo.Loads.ConsigneeCity + ', ' + dbo.Loads.ConsigneeState AS PickupCityStateDeliveryCityState, '1' AS Qty, 'Flat Rate' AS Descrition, '0' AS LBS, 
                         dbo.Loads.CustFlatRate AS [Cust Amt], dbo.Loads.CarrFlatRate AS [Carr Amt], '0' AS [Direct Cost], dbo.Loads.CustFlatRate - dbo.Loads.CarrFlatRate AS Margin, CASE WHEN ISNULL(Employees_1.Name, '0') 
                         <> '0' THEN dbo.loads.SalesRep1Percentage ELSE dbo.employees.salescommission END AS [Comm %], ((CASE WHEN ISNULL(Employees_1.Name, '0') 
                         <> '0' THEN dbo.loads.SalesRep1Percentage ELSE dbo.employees.salescommission END) * .01) * (dbo.Loads.CustFlatRate - dbo.Loads.CarrFlatRate) AS [Comm Amt]
FROM            dbo.Loads INNER JOIN
                         dbo.LoadStatusTypes ON dbo.Loads.StatusTypeID = dbo.LoadStatusTypes.StatusTypeID INNER JOIN
                         dbo.Customers ON dbo.Loads.CustomerID = dbo.Customers.CustomerID INNER JOIN
                         dbo.CustomerOffices ON dbo.Customers.CustomerID = dbo.CustomerOffices.CustomerID INNER JOIN
                         dbo.Offices ON dbo.CustomerOffices.OfficeID = dbo.Offices.OfficeID INNER JOIN
                         dbo.Companies ON dbo.Offices.CompanyID = dbo.Companies.CompanyID INNER JOIN
                         dbo.Employees ON dbo.Loads.SalesRepID = dbo.Employees.EmployeeID LEFT OUTER JOIN
                         dbo.Employees AS Employees_1 ON dbo.Loads.SalesRep1 = Employees_1.EmployeeID
WHERE        (dbo.Loads.CarrFlatRate <> 0) OR
                         (dbo.Loads.CustFlatRate <> 0)
GO



GO

/****** Object:  View [dbo].[vwSalesDetailSalesRep1MilesRate]    Script Date: 3/16/2022 9:50:42 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER VIEW [dbo].[vwSalesDetailSalesRep1MilesRate]
AS
SELECT        dbo.Companies.CompanyID, ISNULL(Employees_1.Name, dbo.Employees.Name) AS SalesRep, dbo.Loads.LoadID, dbo.Loads.LoadNumber, dbo.Loads.HasLateStop, dbo.LoadStatusTypes.StatusText, dbo.Loads.NewPickupDate AS PickupDate, dbo.Loads.NewDeliveryDate AS DeliveryDate, dbo.Loads.BillDate AS InvoiceDate, dbo.Loads.CreatedDateTime AS CreatedDate, dbo.Customers.CustomerName, dbo.Loads.CarrierName, 
                         dbo.Loads.ShipperCity + ', ' + dbo.Loads.ShipperState + ' - ' + dbo.Loads.ConsigneeCity + ', ' + dbo.Loads.ConsigneeState AS PickupCityStateDeliveryCityState, '1' AS Qty, 'Miles Charge' AS Descrition, '0' AS LBS, 
                         dbo.Loads.CustomerRatePerMile * dbo.Loads.TotalMiles AS [Cust Amt], dbo.Loads.CarrierRatePerMile * dbo.Loads.TotalMiles AS [Carr Amt], '0' AS [Direct Cost], 
                         dbo.Loads.CustomerRatePerMile * dbo.Loads.TotalMiles - dbo.Loads.CarrierRatePerMile * dbo.Loads.TotalMiles AS Margin, CASE WHEN ISNULL(Employees_1.Name, '0') 
                         <> '0' THEN dbo.loads.SalesRep1Percentage ELSE dbo.employees.salescommission END AS [Comm %], ((CASE WHEN ISNULL(Employees_1.Name, '0') 
                         <> '0' THEN dbo.loads.SalesRep1Percentage ELSE dbo.employees.salescommission END) * .01) * (dbo.Loads.CustomerRatePerMile * dbo.Loads.TotalMiles - dbo.Loads.CarrierRatePerMile * dbo.Loads.TotalMiles) 
                         AS [Comm Amt]
FROM            dbo.Loads INNER JOIN
                         dbo.LoadStatusTypes ON dbo.Loads.StatusTypeID = dbo.LoadStatusTypes.StatusTypeID INNER JOIN
                         dbo.Customers ON dbo.Loads.CustomerID = dbo.Customers.CustomerID INNER JOIN
                         dbo.CustomerOffices ON dbo.Customers.CustomerID = dbo.CustomerOffices.CustomerID INNER JOIN
                         dbo.Offices ON dbo.CustomerOffices.OfficeID = dbo.Offices.OfficeID INNER JOIN
                         dbo.Companies ON dbo.Offices.CompanyID = dbo.Companies.CompanyID INNER JOIN
                         dbo.Employees ON dbo.Loads.SalesRepID = dbo.Employees.EmployeeID LEFT OUTER JOIN
                         dbo.Employees AS Employees_1 ON dbo.Loads.SalesRep1 = Employees_1.EmployeeID
WHERE        (dbo.Loads.CustomerRatePerMile * dbo.Loads.TotalMiles <> 0) OR
                         (dbo.Loads.CarrierRatePerMile * dbo.Loads.TotalMiles <> 0)
GO


GO

/****** Object:  View [dbo].[vwSalesDetailSalesRep2Cmdty]    Script Date: 3/16/2022 10:00:55 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER VIEW [dbo].[vwSalesDetailSalesRep2Cmdty]
AS
SELECT        dbo.Companies.CompanyID, dbo.Employees.Name AS SalesRep, dbo.Loads.LoadID, dbo.Loads.LoadNumber, dbo.Loads.HasLateStop, dbo.LoadStatusTypes.StatusText, dbo.Loads.NewPickupDate AS PickupDate, dbo.Loads.NewDeliveryDate AS DeliveryDate, dbo.Loads.BillDate AS InvoiceDate, dbo.Loads.CreatedDateTime AS CreatedDate, dbo.Customers.CustomerName, dbo.Loads.CarrierName, 
                         dbo.Loads.ShipperCity + ', ' + dbo.Loads.ShipperState + ' - ' + dbo.Loads.ConsigneeCity + ', ' + dbo.Loads.ConsigneeState AS PickupCityStateDeliveryCityState, dbo.LoadStopCommodities.Qty, 
                         dbo.LoadStopCommodities.Description, dbo.LoadStopCommodities.Weight AS LBS, dbo.LoadStopCommodities.CustCharges AS [Cust Amt], dbo.LoadStopCommodities.CarrCharges AS [Carr Amt], 
                         ISNULL(dbo.LoadStopCommodities.DirectCostTotal,0) AS [Direct Cost], dbo.LoadStopCommodities.CustCharges - dbo.LoadStopCommodities.CarrCharges - ISNULL(ISNULL(dbo.LoadStopCommodities.DirectCostTotal,0), 0) AS Margin, 
                         dbo.Loads.SalesRep2Percentage AS [Comm %], (dbo.Loads.SalesRep2Percentage * 0.01) 
                         * (dbo.LoadStopCommodities.CustCharges - dbo.LoadStopCommodities.CarrCharges - ISNULL(ISNULL(dbo.LoadStopCommodities.DirectCostTotal,0), 0)) AS [Comm Amt]
FROM            dbo.Loads INNER JOIN
                         dbo.LoadStatusTypes ON dbo.Loads.StatusTypeID = dbo.LoadStatusTypes.StatusTypeID INNER JOIN
                         dbo.Customers ON dbo.Loads.CustomerID = dbo.Customers.CustomerID INNER JOIN
                         dbo.CustomerOffices ON dbo.Customers.CustomerID = dbo.CustomerOffices.CustomerID INNER JOIN
                         dbo.Offices ON dbo.CustomerOffices.OfficeID = dbo.Offices.OfficeID INNER JOIN
                         dbo.Companies ON dbo.Offices.CompanyID = dbo.Companies.CompanyID INNER JOIN
                         dbo.LoadStops ON dbo.Loads.LoadID = dbo.LoadStops.LoadID INNER JOIN
                         dbo.LoadStopCommodities ON dbo.LoadStops.LoadStopID = dbo.LoadStopCommodities.LoadStopID INNER JOIN
                         dbo.Employees ON dbo.Loads.SalesRep2 = dbo.Employees.EmployeeID
WHERE        (dbo.LoadStopCommodities.Description <> N'') OR
                         (dbo.LoadStopCommodities.Weight <> 0) OR
                         (dbo.LoadStopCommodities.CustCharges <> 0) OR
                         (dbo.LoadStopCommodities.CarrCharges <> 0) OR
                         (ISNULL(dbo.LoadStopCommodities.DirectCostTotal,0) <> 0)
GO



GO

/****** Object:  View [dbo].[vwSalesDetailSalesRep2FlatRate]    Script Date: 3/16/2022 10:05:45 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER VIEW [dbo].[vwSalesDetailSalesRep2FlatRate]
AS
SELECT        dbo.Companies.CompanyID, dbo.Employees.Name AS SalesRep, dbo.Loads.LoadID, dbo.Loads.LoadNumber, dbo.Loads.HasLateStop, dbo.LoadStatusTypes.StatusText, dbo.Loads.NewPickupDate AS PickupDate, dbo.Loads.NewDeliveryDate AS DeliveryDate, dbo.Loads.BillDate AS InvoiceDate, dbo.Loads.CreatedDateTime AS CreatedDate, dbo.Customers.CustomerName, dbo.Loads.CarrierName, 
                         dbo.Loads.ShipperCity + ', ' + dbo.Loads.ShipperState + ' - ' + dbo.Loads.ConsigneeCity + ', ' + dbo.Loads.ConsigneeState AS PickupCityStateDeliveryCityState, '1' AS Qty, 'Flat Rate' AS Descrition, '0' AS LBS, 
                         dbo.Loads.CustFlatRate AS [Cust Amt], dbo.Loads.CarrFlatRate AS [Carr Amt], '0' AS [Direct Cost], dbo.Loads.CustFlatRate - dbo.Loads.CarrFlatRate AS Margin, dbo.Loads.SalesRep2Percentage AS [Comm %], 
                         (dbo.Loads.SalesRep2Percentage * 0.01) * (dbo.Loads.CustFlatRate - dbo.Loads.CarrFlatRate) AS [Comm Amt]
FROM            dbo.Loads INNER JOIN
                         dbo.LoadStatusTypes ON dbo.Loads.StatusTypeID = dbo.LoadStatusTypes.StatusTypeID INNER JOIN
                         dbo.Customers ON dbo.Loads.CustomerID = dbo.Customers.CustomerID INNER JOIN
                         dbo.CustomerOffices ON dbo.Customers.CustomerID = dbo.CustomerOffices.CustomerID INNER JOIN
                         dbo.Offices ON dbo.CustomerOffices.OfficeID = dbo.Offices.OfficeID INNER JOIN
                         dbo.Companies ON dbo.Offices.CompanyID = dbo.Companies.CompanyID INNER JOIN
                         dbo.Employees ON dbo.Loads.SalesRep2 = dbo.Employees.EmployeeID
WHERE        (dbo.Loads.CustFlatRate <> 0) OR
                         (dbo.Loads.CarrFlatRate <> 0)
GO



GO

/****** Object:  View [dbo].[vwSalesDetailSalesRep2MilesRate]    Script Date: 3/16/2022 10:06:55 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER VIEW [dbo].[vwSalesDetailSalesRep2MilesRate]
AS
SELECT        dbo.Companies.CompanyID, dbo.Employees.Name AS SalesRep, dbo.Loads.LoadID, dbo.Loads.LoadNumber, dbo.Loads.HasLateStop, dbo.LoadStatusTypes.StatusText, dbo.Loads.NewPickupDate AS PickupDate, dbo.Loads.NewDeliveryDate AS DeliveryDate, dbo.Loads.BillDate AS InvoiceDate, dbo.Loads.CreatedDateTime AS CreatedDate, dbo.Customers.CustomerName, dbo.Loads.CarrierName, 
                         dbo.Loads.ShipperCity + ', ' + dbo.Loads.ShipperState + ' - ' + dbo.Loads.ConsigneeCity + ', ' + dbo.Loads.ConsigneeState AS PickupCityStateDeliveryCityState, '1' AS Qty, 'Miles Charge' AS Descrition, '0' AS LBS, 
                         dbo.Loads.CustomerRatePerMile * dbo.Loads.TotalMiles AS [Cust Amt], dbo.Loads.CarrierRatePerMile * dbo.Loads.TotalMiles AS [Carr Amt], '0' AS [Direct Cost], 
                         dbo.Loads.CustomerRatePerMile * dbo.Loads.TotalMiles - dbo.Loads.CarrierRatePerMile * dbo.Loads.TotalMiles AS Margin, dbo.Loads.SalesRep2Percentage AS [Comm %], (dbo.Loads.SalesRep2Percentage * 0.01) 
                         * (dbo.Loads.CustomerRatePerMile * dbo.Loads.TotalMiles - dbo.Loads.CarrierRatePerMile * dbo.Loads.TotalMiles) AS [Comm Amt]
FROM            dbo.Loads INNER JOIN
                         dbo.LoadStatusTypes ON dbo.Loads.StatusTypeID = dbo.LoadStatusTypes.StatusTypeID INNER JOIN
                         dbo.Customers ON dbo.Loads.CustomerID = dbo.Customers.CustomerID INNER JOIN
                         dbo.CustomerOffices ON dbo.Customers.CustomerID = dbo.CustomerOffices.CustomerID INNER JOIN
                         dbo.Offices ON dbo.CustomerOffices.OfficeID = dbo.Offices.OfficeID INNER JOIN
                         dbo.Companies ON dbo.Offices.CompanyID = dbo.Companies.CompanyID INNER JOIN
                         dbo.Employees ON dbo.Loads.SalesRep2 = dbo.Employees.EmployeeID
WHERE        (dbo.Loads.CustomerRatePerMile * dbo.Loads.TotalMiles <> 0) OR
                         (dbo.Loads.CarrierRatePerMile * dbo.Loads.TotalMiles <> 0)
GO


GO

/****** Object:  View [dbo].[vwSalesDetailSalesRep3Cmdty]    Script Date: 3/16/2022 10:10:13 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER VIEW [dbo].[vwSalesDetailSalesRep3Cmdty]
AS
SELECT        dbo.Companies.CompanyID, dbo.Employees.Name AS SalesRep, dbo.Loads.LoadID, dbo.Loads.LoadNumber, dbo.Loads.HasLateStop, dbo.LoadStatusTypes.StatusText, dbo.Loads.NewPickupDate AS PickupDate, dbo.Loads.NewDeliveryDate AS DeliveryDate, dbo.Loads.BillDate AS InvoiceDate, dbo.Loads.CreatedDateTime AS CreatedDate, dbo.Customers.CustomerName, dbo.Loads.CarrierName, 
                         dbo.Loads.ShipperCity + ', ' + dbo.Loads.ShipperState + ' - ' + dbo.Loads.ConsigneeCity + ', ' + dbo.Loads.ConsigneeState AS PickupCityStateDeliveryCityState, dbo.LoadStopCommodities.Qty, 
                         dbo.LoadStopCommodities.Description, dbo.LoadStopCommodities.Weight AS LBS, dbo.LoadStopCommodities.CustCharges AS [Cust Amt], dbo.LoadStopCommodities.CarrCharges AS [Carr Amt], 
                         ISNULL(dbo.LoadStopCommodities.DirectCostTotal,0) AS [Direct Cost], dbo.LoadStopCommodities.CustCharges - dbo.LoadStopCommodities.CarrCharges - ISNULL(ISNULL(dbo.LoadStopCommodities.DirectCostTotal,0), 0) AS Margin, 
                         dbo.Loads.SalesRep3Percentage AS [Comm %], (dbo.Loads.SalesRep3Percentage * 0.01) 
                         * (dbo.LoadStopCommodities.CustCharges - dbo.LoadStopCommodities.CarrCharges - ISNULL(ISNULL(dbo.LoadStopCommodities.DirectCostTotal,0), 0)) AS [Comm Amt]
FROM            dbo.Loads INNER JOIN
                         dbo.LoadStatusTypes ON dbo.Loads.StatusTypeID = dbo.LoadStatusTypes.StatusTypeID INNER JOIN
                         dbo.Customers ON dbo.Loads.CustomerID = dbo.Customers.CustomerID INNER JOIN
                         dbo.CustomerOffices ON dbo.Customers.CustomerID = dbo.CustomerOffices.CustomerID INNER JOIN
                         dbo.Offices ON dbo.CustomerOffices.OfficeID = dbo.Offices.OfficeID INNER JOIN
                         dbo.Companies ON dbo.Offices.CompanyID = dbo.Companies.CompanyID INNER JOIN
                         dbo.LoadStops ON dbo.Loads.LoadID = dbo.LoadStops.LoadID INNER JOIN
                         dbo.LoadStopCommodities ON dbo.LoadStops.LoadStopID = dbo.LoadStopCommodities.LoadStopID INNER JOIN
                         dbo.Employees ON dbo.Loads.SalesRep3 = dbo.Employees.EmployeeID
WHERE        (dbo.LoadStopCommodities.Description <> N'') OR
                         (dbo.LoadStopCommodities.Weight <> 0) OR
                         (dbo.LoadStopCommodities.CustCharges <> 0) OR
                         (dbo.LoadStopCommodities.CarrCharges <> 0) OR
                         (ISNULL(dbo.LoadStopCommodities.DirectCostTotal,0) <> 0)
GO


GO

/****** Object:  View [dbo].[vwSalesDetailSalesRep3FlatRate]    Script Date: 3/16/2022 10:11:45 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER VIEW [dbo].[vwSalesDetailSalesRep3FlatRate]
AS
SELECT        dbo.Companies.CompanyID, dbo.Employees.Name AS SalesRep, dbo.Loads.LoadID, dbo.Loads.LoadNumber, dbo.Loads.HasLateStop, dbo.LoadStatusTypes.StatusText, dbo.Loads.NewPickupDate AS PickupDate, dbo.Loads.NewDeliveryDate AS DeliveryDate, dbo.Loads.BillDate AS InvoiceDate, dbo.Loads.CreatedDateTime AS CreatedDate, dbo.Customers.CustomerName, dbo.Loads.CarrierName, 
                         dbo.Loads.ShipperCity + ', ' + dbo.Loads.ShipperState + ' - ' + dbo.Loads.ConsigneeCity + ', ' + dbo.Loads.ConsigneeState AS PickupCityStateDeliveryCityState, '1' AS Qty, 'Flat Rate' AS Descrition, '0' AS LBS, 
                         dbo.Loads.CustFlatRate AS [Cust Amt], dbo.Loads.CarrFlatRate AS [Carr Amt], '0' AS [Direct Cost], dbo.Loads.CustFlatRate - dbo.Loads.CarrFlatRate AS Margin, dbo.Loads.SalesRep3Percentage AS [Comm %], 
                         (dbo.Loads.SalesRep3Percentage * 0.01) * (dbo.Loads.CustFlatRate - dbo.Loads.CarrFlatRate) AS [Comm Amt]
FROM            dbo.Loads INNER JOIN
                         dbo.LoadStatusTypes ON dbo.Loads.StatusTypeID = dbo.LoadStatusTypes.StatusTypeID INNER JOIN
                         dbo.Customers ON dbo.Loads.CustomerID = dbo.Customers.CustomerID INNER JOIN
                         dbo.CustomerOffices ON dbo.Customers.CustomerID = dbo.CustomerOffices.CustomerID INNER JOIN
                         dbo.Offices ON dbo.CustomerOffices.OfficeID = dbo.Offices.OfficeID INNER JOIN
                         dbo.Companies ON dbo.Offices.CompanyID = dbo.Companies.CompanyID INNER JOIN
                         dbo.Employees ON dbo.Loads.SalesRep3 = dbo.Employees.EmployeeID
WHERE        (dbo.Loads.CustFlatRate <> 0) OR
                         (dbo.Loads.CarrFlatRate <> 0)
GO


GO

/****** Object:  View [dbo].[vwSalesDetailSalesRep3MilesRate]    Script Date: 3/16/2022 10:13:28 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER VIEW [dbo].[vwSalesDetailSalesRep3MilesRate]
AS
SELECT        dbo.Companies.CompanyID, dbo.Employees.Name AS SalesRep, dbo.Loads.LoadID, dbo.Loads.LoadNumber, dbo.Loads.HasLateStop, dbo.LoadStatusTypes.StatusText, dbo.Loads.NewPickupDate AS PickupDate, dbo.Loads.NewDeliveryDate AS DeliveryDate, dbo.Loads.BillDate AS InvoiceDate, dbo.Loads.CreatedDateTime AS CreatedDate, dbo.Customers.CustomerName, dbo.Loads.CarrierName, 
                         dbo.Loads.ShipperCity + ', ' + dbo.Loads.ShipperState + ' - ' + dbo.Loads.ConsigneeCity + ', ' + dbo.Loads.ConsigneeState AS PickupCityStateDeliveryCityState, '1' AS Qty, 'Miles Charge' AS Descrition, '0' AS LBS, 
                         dbo.Loads.CustomerRatePerMile * dbo.Loads.TotalMiles AS [Cust Amt], dbo.Loads.CarrierRatePerMile * dbo.Loads.TotalMiles AS [Carr Amt], '0' AS [Direct Cost], 
                         dbo.Loads.CustomerRatePerMile * dbo.Loads.TotalMiles - dbo.Loads.CarrierRatePerMile * dbo.Loads.TotalMiles AS Margin, dbo.Loads.SalesRep3Percentage AS [Comm %], (dbo.Loads.SalesRep3Percentage * 0.01) 
                         * (dbo.Loads.CustomerRatePerMile * dbo.Loads.TotalMiles - dbo.Loads.CarrierRatePerMile * dbo.Loads.TotalMiles) AS [Comm Amt]
FROM            dbo.Loads INNER JOIN
                         dbo.LoadStatusTypes ON dbo.Loads.StatusTypeID = dbo.LoadStatusTypes.StatusTypeID INNER JOIN
                         dbo.Customers ON dbo.Loads.CustomerID = dbo.Customers.CustomerID INNER JOIN
                         dbo.CustomerOffices ON dbo.Customers.CustomerID = dbo.CustomerOffices.CustomerID INNER JOIN
                         dbo.Offices ON dbo.CustomerOffices.OfficeID = dbo.Offices.OfficeID INNER JOIN
                         dbo.Companies ON dbo.Offices.CompanyID = dbo.Companies.CompanyID INNER JOIN
                         dbo.Employees ON dbo.Loads.SalesRep3 = dbo.Employees.EmployeeID
WHERE        (dbo.Loads.CustomerRatePerMile * dbo.Loads.TotalMiles <> 0) OR
                         (dbo.Loads.CarrierRatePerMile * dbo.Loads.TotalMiles <> 0)
GO


GO

/****** Object:  View [dbo].[vwSalesDetailSalesRep]    Script Date: 3/16/2022 9:43:27 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER VIEW [dbo].[vwSalesDetailSalesRep]
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

/****** Object:  View [dbo].[vwSalesDetailCmdty]    Script Date: 3/16/2022 9:44:28 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER VIEW [dbo].[vwSalesDetailCmdty]
AS
SELECT        dbo.Companies.CompanyID, dbo.Loads.LoadID, dbo.Loads.LoadNumber, dbo.Loads.HasLateStop, dbo.LoadStatusTypes.StatusText, dbo.Loads.NewPickupDate AS PickupDate, dbo.Loads.NewDeliveryDate AS DeliveryDate, dbo.Loads.BillDate AS InvoiceDate, dbo.Loads.CreatedDateTime AS CreatedDate, dbo.Customers.CustomerName, dbo.Loads.CarrierName, 
                         dbo.Loads.ShipperCity + ', ' + dbo.Loads.ShipperState + ' - ' + dbo.Loads.ConsigneeCity + ', ' + dbo.Loads.ConsigneeState AS PickupCityStateDeliveryCityState, dbo.LoadStopCommodities.Qty, 
                         dbo.LoadStopCommodities.Description, dbo.LoadStopCommodities.Weight AS LBS, dbo.LoadStopCommodities.CustCharges AS [Cust Amt], dbo.LoadStopCommodities.CarrCharges AS [Carr Amt], 
                         ISNULL(dbo.LoadStopCommodities.DirectCostTotal,0) AS [Direct Cost], dbo.LoadStopCommodities.CustCharges - dbo.LoadStopCommodities.CarrCharges - ISNULL(ISNULL(dbo.LoadStopCommodities.DirectCostTotal,0), 0) AS Margin, 
                        CASE WHEN (dbo.loads.Dispatcher1 IS NOT NULL OR dbo.loads.Dispatcher2 IS NOT NULL OR dbo.loads.Dispatcher3 IS NOT NULL) THEN dbo.loads.Dispatcher1Percentage+dbo.loads.Dispatcher2Percentage+dbo.loads.Dispatcher3Percentage ELSE dbo.employees.salescommission END AS [Comm %], 
						((CASE WHEN (dbo.loads.Dispatcher1 IS NOT NULL OR dbo.loads.Dispatcher2 IS NOT NULL OR dbo.loads.Dispatcher3 IS NOT NULL) THEN dbo.loads.Dispatcher1Percentage+dbo.loads.Dispatcher2Percentage+dbo.loads.Dispatcher3Percentage ELSE dbo.employees.salescommission END) * 0.01) 
                         * (dbo.LoadStopCommodities.CustCharges - dbo.LoadStopCommodities.CarrCharges - ISNULL(ISNULL(dbo.LoadStopCommodities.DirectCostTotal,0), 0)) AS [Comm Amt]
FROM            dbo.Loads INNER JOIN
                         dbo.LoadStatusTypes ON dbo.Loads.StatusTypeID = dbo.LoadStatusTypes.StatusTypeID INNER JOIN
                         dbo.Customers ON dbo.Loads.CustomerID = dbo.Customers.CustomerID INNER JOIN
                         dbo.CustomerOffices ON dbo.Customers.CustomerID = dbo.CustomerOffices.CustomerID INNER JOIN
                         dbo.Offices ON dbo.CustomerOffices.OfficeID = dbo.Offices.OfficeID INNER JOIN
                         dbo.Companies ON dbo.Offices.CompanyID = dbo.Companies.CompanyID INNER JOIN
                         dbo.Employees ON dbo.Loads.DispatcherID = dbo.Employees.EmployeeID INNER JOIN
                         dbo.LoadStops ON dbo.Loads.LoadID = dbo.LoadStops.LoadID INNER JOIN
                         dbo.LoadStopCommodities ON dbo.LoadStops.LoadStopID = dbo.LoadStopCommodities.LoadStopID
WHERE        (dbo.LoadStopCommodities.Description <> N'') OR
                         (dbo.LoadStopCommodities.Weight <> 0) OR
                         (dbo.LoadStopCommodities.CustCharges <> 0) OR
                         (dbo.LoadStopCommodities.CarrCharges <> 0) OR
                         (ISNULL(dbo.LoadStopCommodities.DirectCostTotal,0) <> 0)
GO


GO

/****** Object:  View [dbo].[vwSalesDetailFlatRate]    Script Date: 3/16/2022 9:47:29 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER VIEW [dbo].[vwSalesDetailFlatRate]
AS
SELECT        dbo.Companies.CompanyID, dbo.Loads.LoadID, dbo.Loads.LoadNumber, dbo.Loads.HasLateStop, dbo.LoadStatusTypes.StatusText, dbo.Loads.NewPickupDate AS PickupDate, dbo.Loads.NewDeliveryDate AS DeliveryDate, dbo.Loads.BillDate AS InvoiceDate, dbo.Loads.CreatedDateTime AS CreatedDate, dbo.Customers.CustomerName, dbo.Loads.CarrierName, 
                         dbo.Loads.ShipperCity + ', ' + dbo.Loads.ShipperState + ' - ' + dbo.Loads.ConsigneeCity + ', ' + dbo.Loads.ConsigneeState AS PickupCityStateDeliveryCityState, '1' AS Qty, 'Flat Rate' AS Descrition, '0' AS LBS, 
                         dbo.Loads.CustFlatRate AS [Cust Amt], dbo.Loads.CarrFlatRate AS [Carr Amt], '0' AS [Direct Cost], dbo.Loads.CustFlatRate - dbo.Loads.CarrFlatRate AS Margin, CASE WHEN (dbo.loads.Dispatcher1 IS NOT NULL OR dbo.loads.Dispatcher2 IS NOT NULL OR dbo.loads.Dispatcher3 IS NOT NULL) THEN dbo.loads.Dispatcher1Percentage+dbo.loads.Dispatcher2Percentage+dbo.loads.Dispatcher3Percentage ELSE dbo.employees.salescommission END AS [Comm %], ((CASE WHEN (dbo.loads.Dispatcher1 IS NOT NULL OR dbo.loads.Dispatcher2 IS NOT NULL OR dbo.loads.Dispatcher3 IS NOT NULL) THEN dbo.loads.Dispatcher1Percentage+dbo.loads.Dispatcher2Percentage+dbo.loads.Dispatcher3Percentage ELSE dbo.employees.salescommission END) * .01) * (dbo.Loads.CustFlatRate - dbo.Loads.CarrFlatRate) AS [Comm Amt]
FROM            dbo.Loads INNER JOIN
                         dbo.LoadStatusTypes ON dbo.Loads.StatusTypeID = dbo.LoadStatusTypes.StatusTypeID INNER JOIN
                         dbo.Customers ON dbo.Loads.CustomerID = dbo.Customers.CustomerID INNER JOIN
                         dbo.CustomerOffices ON dbo.Customers.CustomerID = dbo.CustomerOffices.CustomerID INNER JOIN
                         dbo.Offices ON dbo.CustomerOffices.OfficeID = dbo.Offices.OfficeID INNER JOIN
                         dbo.Companies ON dbo.Offices.CompanyID = dbo.Companies.CompanyID INNER JOIN
                         dbo.Employees ON dbo.Loads.DispatcherID = dbo.Employees.EmployeeID
WHERE        (dbo.Loads.CarrFlatRate <> 0) OR
                         (dbo.Loads.CustFlatRate <> 0)
GO

GO

/****** Object:  View [dbo].[vwSalesDetailMilesRate]    Script Date: 3/16/2022 9:50:42 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER VIEW [dbo].[vwSalesDetailMilesRate]
AS
SELECT        dbo.Companies.CompanyID, dbo.Loads.LoadID, dbo.Loads.LoadNumber, dbo.Loads.HasLateStop, dbo.LoadStatusTypes.StatusText, dbo.Loads.NewPickupDate AS PickupDate, dbo.Loads.NewDeliveryDate AS DeliveryDate, dbo.Loads.BillDate AS InvoiceDate, dbo.Loads.CreatedDateTime AS CreatedDate, dbo.Customers.CustomerName, dbo.Loads.CarrierName, 
                         dbo.Loads.ShipperCity + ', ' + dbo.Loads.ShipperState + ' - ' + dbo.Loads.ConsigneeCity + ', ' + dbo.Loads.ConsigneeState AS PickupCityStateDeliveryCityState, '1' AS Qty, 'Miles Charge' AS Descrition, '0' AS LBS, 
                         dbo.Loads.CustomerRatePerMile * dbo.Loads.TotalMiles AS [Cust Amt], dbo.Loads.CarrierRatePerMile * dbo.Loads.TotalMiles AS [Carr Amt], '0' AS [Direct Cost], 
                         dbo.Loads.CustomerRatePerMile * dbo.Loads.TotalMiles - dbo.Loads.CarrierRatePerMile * dbo.Loads.TotalMiles AS Margin, CASE WHEN (dbo.loads.Dispatcher1 IS NOT NULL OR dbo.loads.Dispatcher2 IS NOT NULL OR dbo.loads.Dispatcher3 IS NOT NULL) THEN dbo.loads.Dispatcher1Percentage+dbo.loads.Dispatcher2Percentage+dbo.loads.Dispatcher3Percentage ELSE dbo.employees.salescommission END AS [Comm %], ((CASE WHEN (dbo.loads.Dispatcher1 IS NOT NULL OR dbo.loads.Dispatcher2 IS NOT NULL OR dbo.loads.Dispatcher3 IS NOT NULL) THEN dbo.loads.Dispatcher1Percentage+dbo.loads.Dispatcher2Percentage+dbo.loads.Dispatcher3Percentage ELSE dbo.employees.salescommission END) * .01) * (dbo.Loads.CustomerRatePerMile * dbo.Loads.TotalMiles - dbo.Loads.CarrierRatePerMile * dbo.Loads.TotalMiles) 
                         AS [Comm Amt]
FROM            dbo.Loads INNER JOIN
                         dbo.LoadStatusTypes ON dbo.Loads.StatusTypeID = dbo.LoadStatusTypes.StatusTypeID INNER JOIN
                         dbo.Customers ON dbo.Loads.CustomerID = dbo.Customers.CustomerID INNER JOIN
                         dbo.CustomerOffices ON dbo.Customers.CustomerID = dbo.CustomerOffices.CustomerID INNER JOIN
                         dbo.Offices ON dbo.CustomerOffices.OfficeID = dbo.Offices.OfficeID INNER JOIN
                         dbo.Companies ON dbo.Offices.CompanyID = dbo.Companies.CompanyID INNER JOIN
                         dbo.Employees ON dbo.Loads.DispatcherID = dbo.Employees.EmployeeID
WHERE        (dbo.Loads.CustomerRatePerMile * dbo.Loads.TotalMiles <> 0) OR
                         (dbo.Loads.CarrierRatePerMile * dbo.Loads.TotalMiles <> 0)
GO

GO

/****** Object:  View [dbo].[vwSalesDetail]    Script Date: 3/16/2022 9:43:27 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER VIEW [dbo].[vwSalesDetail]
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