GO

/****** Object:  View [dbo].[vwSalesDispatcher1]    Script Date: 20-07-2022 16:02:10 ******/
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
						,SalesRep.Name AS SalesRep,dbo.Loads.SalesRep2Name AS SalesRep2,dbo.Loads.SalesRep3Name AS SalesRep3,1 AS reportIndex,  (dbo.Loads.TotalCustomerCharges - dbo.Loads.TotalCarrierCharges) / CASE WHEN ((CASE WHEN (dbo.loads.Dispatcher1Percentage > 0) THEN 1 ELSE 0 END) + (CASE WHEN (dbo.loads.Dispatcher2Percentage > 0) 
                         THEN 1 ELSE 0 END) + (CASE WHEN (dbo.loads.Dispatcher3Percentage > 0) THEN 1 ELSE 0 END)) > 0 THEN ((CASE WHEN (dbo.loads.Dispatcher1Percentage > 0) THEN 1 ELSE 0 END) 
                         + (CASE WHEN (dbo.loads.Dispatcher2Percentage > 0) THEN 1 ELSE 0 END) + (CASE WHEN (dbo.loads.Dispatcher3Percentage > 0) THEN 1 ELSE 0 END)) ELSE 1 END AS DispatchSplitAmt
						 
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

/****** Object:  View [dbo].[vwSalesDispatcher2]    Script Date: 20-07-2022 16:02:27 ******/
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
						,SalesRep.Name AS SalesRep,dbo.Loads.SalesRep2Name AS SalesRep2,dbo.Loads.SalesRep3Name AS SalesRep3,2 AS reportIndex,  (dbo.Loads.TotalCustomerCharges - dbo.Loads.TotalCarrierCharges) / CASE WHEN ((CASE WHEN (dbo.loads.Dispatcher1Percentage > 0) THEN 1 ELSE 0 END) + (CASE WHEN (dbo.loads.Dispatcher2Percentage > 0) 
                         THEN 1 ELSE 0 END) + (CASE WHEN (dbo.loads.Dispatcher3Percentage > 0) THEN 1 ELSE 0 END)) > 0 THEN ((CASE WHEN (dbo.loads.Dispatcher1Percentage > 0) THEN 1 ELSE 0 END) 
                         + (CASE WHEN (dbo.loads.Dispatcher2Percentage > 0) THEN 1 ELSE 0 END) + (CASE WHEN (dbo.loads.Dispatcher3Percentage > 0) THEN 1 ELSE 0 END)) ELSE 1 END AS DispatchSplitAmt
						
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

/****** Object:  View [dbo].[vwSalesDispatcher3]    Script Date: 20-07-2022 16:02:38 ******/
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
						,SalesRep.Name AS SalesRep,dbo.Loads.SalesRep2Name AS SalesRep2,dbo.Loads.SalesRep3Name AS SalesRep3,3 AS reportIndex,  (dbo.Loads.TotalCustomerCharges - dbo.Loads.TotalCarrierCharges) / CASE WHEN ((CASE WHEN (dbo.loads.Dispatcher1Percentage > 0) THEN 1 ELSE 0 END) + (CASE WHEN (dbo.loads.Dispatcher2Percentage > 0) 
                         THEN 1 ELSE 0 END) + (CASE WHEN (dbo.loads.Dispatcher3Percentage > 0) THEN 1 ELSE 0 END)) > 0 THEN ((CASE WHEN (dbo.loads.Dispatcher1Percentage > 0) THEN 1 ELSE 0 END) 
                         + (CASE WHEN (dbo.loads.Dispatcher2Percentage > 0) THEN 1 ELSE 0 END) + (CASE WHEN (dbo.loads.Dispatcher3Percentage > 0) THEN 1 ELSE 0 END)) ELSE 1 END AS DispatchSplitAmt
						
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

/****** Object:  View [dbo].[vwSalesDispatcher]    Script Date: 20-07-2022 16:02:51 ******/
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


