GO

/****** Object:  View [dbo].[vwSalesDispatcher1]    Script Date: 3/16/2022 9:47:29 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER VIEW [dbo].[vwSalesDispatcher1]
AS
SELECT        dbo.Companies.CompanyID, ISNULL(Employees_1.Name, dbo.Employees.Name) AS Dispatcher, dbo.Loads.LoadNumber, dbo.LoadStatusTypes.StatusText, dbo.Loads.NewPickupDate AS PickupDate, dbo.Loads.NewDeliveryDate AS NewDeliveryDate, dbo.Loads.InvoiceDate, dbo.Loads.CreatedDateTime AS CreatedDate, dbo.Customers.CustomerName, dbo.Loads.CarrierName, 
                         dbo.Loads.ShipperCity + ', ' + dbo.Loads.ShipperState + ' - ' + dbo.Loads.ConsigneeCity + ', ' + dbo.Loads.ConsigneeState AS PickupCityStateDeliveryCityState, 
                         dbo.Loads.TotalCustomerCharges AS [Cust Amt], dbo.Loads.TotalCarrierCharges AS [Carr Amt], dbo.Loads.TotalDirectCost AS [Direct Cost], dbo.Loads.TotalCustomerCharges - dbo.Loads.TotalCarrierCharges AS Margin, CASE WHEN ISNULL(Employees_1.Name, '0') 
                         <> '0' THEN dbo.loads.Dispatcher1Percentage ELSE dbo.employees.salescommission END AS [Comm %], ((CASE WHEN ISNULL(Employees_1.Name, '0') 
                         <> '0' THEN dbo.loads.Dispatcher1Percentage ELSE dbo.employees.salescommission END) * .01) * (dbo.Loads.TotalCustomerCharges - dbo.Loads.TotalCarrierCharges) AS [Comm Amt]
FROM            dbo.Loads INNER JOIN
                         dbo.LoadStatusTypes ON dbo.Loads.StatusTypeID = dbo.LoadStatusTypes.StatusTypeID INNER JOIN
                         dbo.Customers ON dbo.Loads.CustomerID = dbo.Customers.CustomerID INNER JOIN
                         dbo.CustomerOffices ON dbo.Customers.CustomerID = dbo.CustomerOffices.CustomerID INNER JOIN
                         dbo.Offices ON dbo.CustomerOffices.OfficeID = dbo.Offices.OfficeID INNER JOIN
                         dbo.Companies ON dbo.Offices.CompanyID = dbo.Companies.CompanyID INNER JOIN
                         dbo.Employees ON dbo.Loads.DispatcherID = dbo.Employees.EmployeeID LEFT OUTER JOIN
                         dbo.Employees AS Employees_1 ON dbo.Loads.Dispatcher1 = Employees_1.EmployeeID
WHERE        (dbo.Loads.TotalCustomerCharges <> 0) OR
                         (dbo.Loads.TotalCarrierCharges <> 0)
GO

GO

/****** Object:  View [dbo].[vwSalesDispatcher2]    Script Date: 3/16/2022 9:47:29 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER VIEW [dbo].[vwSalesDispatcher2]
AS
SELECT        dbo.Companies.CompanyID, ISNULL(Employees_1.Name, dbo.Employees.Name) AS Dispatcher, dbo.Loads.LoadNumber, dbo.LoadStatusTypes.StatusText, dbo.Loads.NewPickupDate AS PickupDate, dbo.Loads.NewDeliveryDate AS NewDeliveryDate, dbo.Loads.InvoiceDate, dbo.Loads.CreatedDateTime AS CreatedDate, dbo.Customers.CustomerName, dbo.Loads.CarrierName, 
                         dbo.Loads.ShipperCity + ', ' + dbo.Loads.ShipperState + ' - ' + dbo.Loads.ConsigneeCity + ', ' + dbo.Loads.ConsigneeState AS PickupCityStateDeliveryCityState, 
                         dbo.Loads.TotalCustomerCharges AS [Cust Amt], dbo.Loads.TotalCarrierCharges AS [Carr Amt], dbo.Loads.TotalDirectCost AS [Direct Cost], dbo.Loads.TotalCustomerCharges - dbo.Loads.TotalCarrierCharges AS Margin, CASE WHEN ISNULL(Employees_1.Name, '0') 
                         <> '0' THEN dbo.loads.Dispatcher2Percentage ELSE dbo.employees.salescommission END AS [Comm %], ((CASE WHEN ISNULL(Employees_1.Name, '0') 
                         <> '0' THEN dbo.loads.Dispatcher2Percentage ELSE dbo.employees.salescommission END) * .01) * (dbo.Loads.TotalCustomerCharges - dbo.Loads.TotalCarrierCharges) AS [Comm Amt]
FROM            dbo.Loads INNER JOIN
                         dbo.LoadStatusTypes ON dbo.Loads.StatusTypeID = dbo.LoadStatusTypes.StatusTypeID INNER JOIN
                         dbo.Customers ON dbo.Loads.CustomerID = dbo.Customers.CustomerID INNER JOIN
                         dbo.CustomerOffices ON dbo.Customers.CustomerID = dbo.CustomerOffices.CustomerID INNER JOIN
                         dbo.Offices ON dbo.CustomerOffices.OfficeID = dbo.Offices.OfficeID INNER JOIN
                         dbo.Companies ON dbo.Offices.CompanyID = dbo.Companies.CompanyID INNER JOIN
                         dbo.Employees ON dbo.Loads.DispatcherID = dbo.Employees.EmployeeID LEFT OUTER JOIN
                         dbo.Employees AS Employees_1 ON dbo.Loads.Dispatcher2 = Employees_1.EmployeeID
WHERE        (dbo.Loads.TotalCustomerCharges <> 0) OR
                         (dbo.Loads.TotalCarrierCharges <> 0)
GO

GO

/****** Object:  View [dbo].[vwSalesDispatcher3]    Script Date: 3/16/2022 9:47:29 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER VIEW [dbo].[vwSalesDispatcher3]
AS
SELECT        dbo.Companies.CompanyID, ISNULL(Employees_1.Name, dbo.Employees.Name) AS Dispatcher, dbo.Loads.LoadNumber, dbo.LoadStatusTypes.StatusText, dbo.Loads.NewPickupDate AS PickupDate, dbo.Loads.NewDeliveryDate AS NewDeliveryDate, dbo.Loads.InvoiceDate, dbo.Loads.CreatedDateTime AS CreatedDate, dbo.Customers.CustomerName, dbo.Loads.CarrierName, 
                         dbo.Loads.ShipperCity + ', ' + dbo.Loads.ShipperState + ' - ' + dbo.Loads.ConsigneeCity + ', ' + dbo.Loads.ConsigneeState AS PickupCityStateDeliveryCityState, 
                         dbo.Loads.TotalCustomerCharges AS [Cust Amt], dbo.Loads.TotalCarrierCharges AS [Carr Amt], dbo.Loads.TotalDirectCost AS [Direct Cost], dbo.Loads.TotalCustomerCharges - dbo.Loads.TotalCarrierCharges AS Margin, CASE WHEN ISNULL(Employees_1.Name, '0') 
                         <> '0' THEN dbo.loads.Dispatcher3Percentage ELSE dbo.employees.salescommission END AS [Comm %], ((CASE WHEN ISNULL(Employees_1.Name, '0') 
                         <> '0' THEN dbo.loads.Dispatcher3Percentage ELSE dbo.employees.salescommission END) * .01) * (dbo.Loads.TotalCustomerCharges - dbo.Loads.TotalCarrierCharges) AS [Comm Amt]
FROM            dbo.Loads INNER JOIN
                         dbo.LoadStatusTypes ON dbo.Loads.StatusTypeID = dbo.LoadStatusTypes.StatusTypeID INNER JOIN
                         dbo.Customers ON dbo.Loads.CustomerID = dbo.Customers.CustomerID INNER JOIN
                         dbo.CustomerOffices ON dbo.Customers.CustomerID = dbo.CustomerOffices.CustomerID INNER JOIN
                         dbo.Offices ON dbo.CustomerOffices.OfficeID = dbo.Offices.OfficeID INNER JOIN
                         dbo.Companies ON dbo.Offices.CompanyID = dbo.Companies.CompanyID INNER JOIN
                         dbo.Employees ON dbo.Loads.DispatcherID = dbo.Employees.EmployeeID LEFT OUTER JOIN
                         dbo.Employees AS Employees_1 ON dbo.Loads.Dispatcher3 = Employees_1.EmployeeID
WHERE        (dbo.Loads.TotalCustomerCharges <> 0) OR
                         (dbo.Loads.TotalCarrierCharges <> 0)
GO


GO

/****** Object:  View [dbo].[vwSalesDispatcher]    Script Date: 3/16/2022 9:43:27 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER VIEW [dbo].[vwSalesDispatcher]
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

/****** Object:  View [dbo].[vwSalesSalesRep1]    Script Date: 3/16/2022 9:47:29 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER VIEW [dbo].[vwSalesSalesRep1]
AS
SELECT        dbo.Companies.CompanyID, ISNULL(Employees_1.Name, dbo.Employees.Name) AS SalesRep, dbo.Loads.LoadNumber, dbo.LoadStatusTypes.StatusText, dbo.Loads.NewPickupDate AS PickupDate, dbo.Loads.NewDeliveryDate AS NewDeliveryDate, dbo.Loads.InvoiceDate, dbo.Loads.CreatedDateTime AS CreatedDate, dbo.Customers.CustomerName, dbo.Loads.CarrierName, 
                         dbo.Loads.ShipperCity + ', ' + dbo.Loads.ShipperState + ' - ' + dbo.Loads.ConsigneeCity + ', ' + dbo.Loads.ConsigneeState AS PickupCityStateDeliveryCityState, 
                         dbo.Loads.TotalCustomerCharges AS [Cust Amt], dbo.Loads.TotalCarrierCharges AS [Carr Amt], dbo.Loads.TotalDirectCost AS [Direct Cost], dbo.Loads.TotalCustomerCharges - dbo.Loads.TotalCarrierCharges AS Margin, CASE WHEN ISNULL(Employees_1.Name, '0') 
                         <> '0' THEN dbo.loads.SalesRep1Percentage ELSE dbo.employees.salescommission END AS [Comm %], ((CASE WHEN ISNULL(Employees_1.Name, '0') 
                         <> '0' THEN dbo.loads.SalesRep1Percentage ELSE dbo.employees.salescommission END) * .01) * (dbo.Loads.TotalCustomerCharges - dbo.Loads.TotalCarrierCharges) AS [Comm Amt]
FROM            dbo.Loads INNER JOIN
                         dbo.LoadStatusTypes ON dbo.Loads.StatusTypeID = dbo.LoadStatusTypes.StatusTypeID INNER JOIN
                         dbo.Customers ON dbo.Loads.CustomerID = dbo.Customers.CustomerID INNER JOIN
                         dbo.CustomerOffices ON dbo.Customers.CustomerID = dbo.CustomerOffices.CustomerID INNER JOIN
                         dbo.Offices ON dbo.CustomerOffices.OfficeID = dbo.Offices.OfficeID INNER JOIN
                         dbo.Companies ON dbo.Offices.CompanyID = dbo.Companies.CompanyID INNER JOIN
                         dbo.Employees ON dbo.Loads.SalesRepID = dbo.Employees.EmployeeID LEFT OUTER JOIN
                         dbo.Employees AS Employees_1 ON dbo.Loads.SalesRep1 = Employees_1.EmployeeID
WHERE        (dbo.Loads.TotalCustomerCharges <> 0) OR
                         (dbo.Loads.TotalCarrierCharges <> 0)
GO

GO

/****** Object:  View [dbo].[vwSalesSalesRep2]    Script Date: 3/16/2022 9:47:29 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER VIEW [dbo].[vwSalesSalesRep2]
AS
SELECT        dbo.Companies.CompanyID, ISNULL(Employees_1.Name, dbo.Employees.Name) AS SalesRep, dbo.Loads.LoadNumber, dbo.LoadStatusTypes.StatusText, dbo.Loads.NewPickupDate AS PickupDate, dbo.Loads.NewDeliveryDate AS NewDeliveryDate, dbo.Loads.InvoiceDate, dbo.Loads.CreatedDateTime AS CreatedDate, dbo.Customers.CustomerName, dbo.Loads.CarrierName, 
                         dbo.Loads.ShipperCity + ', ' + dbo.Loads.ShipperState + ' - ' + dbo.Loads.ConsigneeCity + ', ' + dbo.Loads.ConsigneeState AS PickupCityStateDeliveryCityState, 
                         dbo.Loads.TotalCustomerCharges AS [Cust Amt], dbo.Loads.TotalCarrierCharges AS [Carr Amt], dbo.Loads.TotalDirectCost AS [Direct Cost], dbo.Loads.TotalCustomerCharges - dbo.Loads.TotalCarrierCharges AS Margin, CASE WHEN ISNULL(Employees_1.Name, '0') 
                         <> '0' THEN dbo.loads.SalesRep2Percentage ELSE dbo.employees.salescommission END AS [Comm %], ((CASE WHEN ISNULL(Employees_1.Name, '0') 
                         <> '0' THEN dbo.loads.SalesRep2Percentage ELSE dbo.employees.salescommission END) * .01) * (dbo.Loads.TotalCustomerCharges - dbo.Loads.TotalCarrierCharges) AS [Comm Amt]
FROM            dbo.Loads INNER JOIN
                         dbo.LoadStatusTypes ON dbo.Loads.StatusTypeID = dbo.LoadStatusTypes.StatusTypeID INNER JOIN
                         dbo.Customers ON dbo.Loads.CustomerID = dbo.Customers.CustomerID INNER JOIN
                         dbo.CustomerOffices ON dbo.Customers.CustomerID = dbo.CustomerOffices.CustomerID INNER JOIN
                         dbo.Offices ON dbo.CustomerOffices.OfficeID = dbo.Offices.OfficeID INNER JOIN
                         dbo.Companies ON dbo.Offices.CompanyID = dbo.Companies.CompanyID INNER JOIN
                         dbo.Employees ON dbo.Loads.SalesRepID = dbo.Employees.EmployeeID LEFT OUTER JOIN
                         dbo.Employees AS Employees_1 ON dbo.Loads.SalesRep2 = Employees_1.EmployeeID
WHERE        (dbo.Loads.TotalCustomerCharges <> 0) OR
                         (dbo.Loads.TotalCarrierCharges <> 0)
GO

GO

/****** Object:  View [dbo].[vwSalesSalesRep3]    Script Date: 3/16/2022 9:47:29 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER VIEW [dbo].[vwSalesSalesRep3]
AS
SELECT        dbo.Companies.CompanyID, ISNULL(Employees_1.Name, dbo.Employees.Name) AS SalesRep, dbo.Loads.LoadNumber, dbo.LoadStatusTypes.StatusText, dbo.Loads.NewPickupDate AS PickupDate, dbo.Loads.NewDeliveryDate AS NewDeliveryDate, dbo.Loads.InvoiceDate, dbo.Loads.CreatedDateTime AS CreatedDate, dbo.Customers.CustomerName, dbo.Loads.CarrierName, 
                         dbo.Loads.ShipperCity + ', ' + dbo.Loads.ShipperState + ' - ' + dbo.Loads.ConsigneeCity + ', ' + dbo.Loads.ConsigneeState AS PickupCityStateDeliveryCityState, 
                         dbo.Loads.TotalCustomerCharges AS [Cust Amt], dbo.Loads.TotalCarrierCharges AS [Carr Amt], dbo.Loads.TotalDirectCost AS [Direct Cost], dbo.Loads.TotalCustomerCharges - dbo.Loads.TotalCarrierCharges AS Margin, CASE WHEN ISNULL(Employees_1.Name, '0') 
                         <> '0' THEN dbo.loads.SalesRep3Percentage ELSE dbo.employees.salescommission END AS [Comm %], ((CASE WHEN ISNULL(Employees_1.Name, '0') 
                         <> '0' THEN dbo.loads.SalesRep3Percentage ELSE dbo.employees.salescommission END) * .01) * (dbo.Loads.TotalCustomerCharges - dbo.Loads.TotalCarrierCharges) AS [Comm Amt]
FROM            dbo.Loads INNER JOIN
                         dbo.LoadStatusTypes ON dbo.Loads.StatusTypeID = dbo.LoadStatusTypes.StatusTypeID INNER JOIN
                         dbo.Customers ON dbo.Loads.CustomerID = dbo.Customers.CustomerID INNER JOIN
                         dbo.CustomerOffices ON dbo.Customers.CustomerID = dbo.CustomerOffices.CustomerID INNER JOIN
                         dbo.Offices ON dbo.CustomerOffices.OfficeID = dbo.Offices.OfficeID INNER JOIN
                         dbo.Companies ON dbo.Offices.CompanyID = dbo.Companies.CompanyID INNER JOIN
                         dbo.Employees ON dbo.Loads.SalesRepID = dbo.Employees.EmployeeID LEFT OUTER JOIN
                         dbo.Employees AS Employees_1 ON dbo.Loads.SalesRep3 = Employees_1.EmployeeID
WHERE        (dbo.Loads.TotalCustomerCharges <> 0) OR
                         (dbo.Loads.TotalCarrierCharges <> 0)
GO

GO

/****** Object:  View [dbo].[vwSalesSalesRep]    Script Date: 3/16/2022 9:43:27 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER VIEW [dbo].[vwSalesSalesRep]
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

/****** Object:  View [dbo].[vwSales]    Script Date: 3/16/2022 9:47:29 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER VIEW [dbo].[vwSales]
AS
SELECT        dbo.Companies.CompanyID, dbo.Loads.LoadNumber, dbo.LoadStatusTypes.StatusText, dbo.Loads.NewPickupDate AS PickupDate, dbo.Loads.NewDeliveryDate AS NewDeliveryDate, dbo.Loads.InvoiceDate, dbo.Loads.CreatedDateTime AS CreatedDate, dbo.Customers.CustomerName, dbo.Loads.CarrierName, 
                         dbo.Loads.ShipperCity + ', ' + dbo.Loads.ShipperState + ' - ' + dbo.Loads.ConsigneeCity + ', ' + dbo.Loads.ConsigneeState AS PickupCityStateDeliveryCityState, 
                         dbo.Loads.TotalCustomerCharges AS [Cust Amt], dbo.Loads.TotalCarrierCharges AS [Carr Amt], '0' AS [Direct Cost], dbo.Loads.TotalCustomerCharges - dbo.Loads.TotalCarrierCharges AS Margin, CASE WHEN (dbo.loads.Dispatcher1 IS NOT NULL OR dbo.loads.Dispatcher2 IS NOT NULL OR dbo.loads.Dispatcher3 IS NOT NULL) THEN dbo.loads.Dispatcher1Percentage+dbo.loads.Dispatcher2Percentage+dbo.loads.Dispatcher3Percentage ELSE dbo.employees.salescommission END AS [Comm %], ((CASE WHEN (dbo.loads.Dispatcher1 IS NOT NULL OR dbo.loads.Dispatcher2 IS NOT NULL OR dbo.loads.Dispatcher3 IS NOT NULL) THEN dbo.loads.Dispatcher1Percentage+dbo.loads.Dispatcher2Percentage+dbo.loads.Dispatcher3Percentage ELSE dbo.employees.salescommission END) * .01) * (dbo.Loads.TotalCustomerCharges - dbo.Loads.TotalCarrierCharges) AS [Comm Amt]
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

/****** Object:  StoredProcedure [dbo].[USP_GetSalesReport]    Script Date: 21-03-2022 11:32:01 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER   PROCEDURE [dbo].[USP_GetSalesReport]

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
@OrderBy varchar(20)
AS
BEGIN

	DECLARE @sql varchar(max);
	SET @sql = 'SELECT * FROM'

	IF(@GroupBy='dispatcher')
	BEGIN
		SET @sql = @sql + ' vwSalesDispatcher'
	END
	ELSE IF(@GroupBy='salesAgent')
	BEGIN
		SET @sql = @sql + ' vwSalesSalesRep'
	END
	ELSE
	BEGIN
		SET @sql = @sql + ' vwSales'
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


