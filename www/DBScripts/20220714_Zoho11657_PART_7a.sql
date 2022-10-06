GO

/****** Object:  View [dbo].[vwSalesDispatcher1]    Script Date: 14-07-2022 15:38:31 ******/
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
						,SalesRep.Name AS SalesRep,dbo.Loads.SalesRep2Name AS SalesRep2,dbo.Loads.SalesRep3Name AS SalesRep3,1 AS reportIndex
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

/****** Object:  View [dbo].[vwSalesDispatcher2]    Script Date: 14-07-2022 15:40:17 ******/
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
						,SalesRep.Name AS SalesRep,dbo.Loads.SalesRep2Name AS SalesRep2,dbo.Loads.SalesRep3Name AS SalesRep3,2 AS reportIndex
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

/****** Object:  View [dbo].[vwSalesDispatcher3]    Script Date: 14-07-2022 15:40:31 ******/
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
						,SalesRep.Name AS SalesRep,dbo.Loads.SalesRep2Name AS SalesRep2,dbo.Loads.SalesRep3Name AS SalesRep3,3 AS reportIndex
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

/****** Object:  View [dbo].[vwSalesDispatcher]    Script Date: 14-07-2022 15:38:23 ******/
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

/****** Object:  View [dbo].[vwSalesSalesRep1]    Script Date: 14-07-2022 15:49:10 ******/
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
						 ,Dispatcher.Name AS Dispatcher,dbo.Loads.Dispatcher2Name AS Dispatcher2,dbo.Loads.Dispatcher3Name AS Dispatcher3,1 AS ReportIndex
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

/****** Object:  View [dbo].[vwSalesSalesRep2]    Script Date: 14-07-2022 15:49:44 ******/
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
						,Dispatcher.Name AS Dispatcher,dbo.Loads.Dispatcher2Name AS Dispatcher2,dbo.Loads.Dispatcher3Name AS Dispatcher3,2 AS ReportIndex
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

/****** Object:  View [dbo].[vwSalesSalesRep3]    Script Date: 14-07-2022 15:50:10 ******/
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
						,Dispatcher.Name AS Dispatcher,dbo.Loads.Dispatcher2Name AS Dispatcher2,dbo.Loads.Dispatcher3Name AS Dispatcher3,3 AS ReportIndex
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

/****** Object:  View [dbo].[vwSalesSalesRep]    Script Date: 14-07-2022 15:48:55 ******/
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

/****** Object:  StoredProcedure [dbo].[USP_GetSalesReport]    Script Date: 14-07-2022 15:34:02 ******/
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
@SalesRepReport bit,
@ReportIncludeAllDispatchers bit,
@ReportIncludeAllSalesRep bit
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

	IF(@GroupBy='dispatcher' AND @ReportIncludeAllDispatchers = 0)
	BEGIN
		SET @sql = @sql + ' AND ReportIndex = 1'
	END 
	
	IF(@GroupBy='salesAgent' AND @ReportIncludeAllSalesRep = 0)
	BEGIN
		SET @sql = @sql + ' AND ReportIndex = 1'
	END 
	
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

/****** Object:  View [dbo].[vwSalesDetailDispatcher1Cmdty]    Script Date: 14-07-2022 15:57:18 ******/
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
						 ,SalesRep.Name AS SalesRep,dbo.Loads.SalesRep2Name AS SalesRep2,dbo.Loads.SalesRep3Name AS SalesRep3,1 AS ReportIndex
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

/****** Object:  View [dbo].[vwSalesDetailDispatcher1FlatRate]    Script Date: 14-07-2022 15:57:53 ******/
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
						 ,SalesRep.Name AS SalesRep,dbo.Loads.SalesRep2Name AS SalesRep2,dbo.Loads.SalesRep3Name AS SalesRep3,1 AS ReportIndex
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

/****** Object:  View [dbo].[vwSalesDetailDispatcher1MilesRate]    Script Date: 14-07-2022 15:58:15 ******/
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
						 ,SalesRep.Name AS SalesRep,dbo.Loads.SalesRep2Name AS SalesRep2,dbo.Loads.SalesRep3Name AS SalesRep3,1 AS ReportIndex
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

/****** Object:  View [dbo].[vwSalesDetailDispatcher2Cmdty]    Script Date: 14-07-2022 15:58:52 ******/
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
						 ,SalesRep.Name AS SalesRep,dbo.Loads.SalesRep2Name AS SalesRep2,dbo.Loads.SalesRep3Name AS SalesRep3,2 AS ReportIndex
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

/****** Object:  View [dbo].[vwSalesDetailDispatcher2FlatRate]    Script Date: 14-07-2022 15:59:16 ******/
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
						 ,SalesRep.Name AS SalesRep,dbo.Loads.SalesRep2Name AS SalesRep2,dbo.Loads.SalesRep3Name AS SalesRep3,2 AS ReportIndex
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

/****** Object:  View [dbo].[vwSalesDetailDispatcher2MilesRate]    Script Date: 14-07-2022 15:59:47 ******/
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
						 ,SalesRep.Name AS SalesRep,dbo.Loads.SalesRep2Name AS SalesRep2,dbo.Loads.SalesRep3Name AS SalesRep3,2 AS ReportIndex
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

/****** Object:  View [dbo].[vwSalesDetailDispatcher3Cmdty]    Script Date: 14-07-2022 16:00:25 ******/
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
						 ,SalesRep.Name AS SalesRep,dbo.Loads.SalesRep2Name AS SalesRep2,dbo.Loads.SalesRep3Name AS SalesRep3,3 AS ReportIndex
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

/****** Object:  View [dbo].[vwSalesDetailDispatcher3FlatRate]    Script Date: 14-07-2022 16:00:48 ******/
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
						 ,SalesRep.Name AS SalesRep,dbo.Loads.SalesRep2Name AS SalesRep2,dbo.Loads.SalesRep3Name AS SalesRep3,3 AS ReportIndex
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

/****** Object:  View [dbo].[vwSalesDetailDispatcher3MilesRate]    Script Date: 14-07-2022 16:01:06 ******/
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
						 ,SalesRep.Name AS SalesRep,dbo.Loads.SalesRep2Name AS SalesRep2,dbo.Loads.SalesRep3Name AS SalesRep3,3 AS ReportIndex
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

/****** Object:  View [dbo].[vwSalesDetailDispatcher]    Script Date: 14-07-2022 15:57:05 ******/
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

/****** Object:  View [dbo].[vwSalesDetailSalesRep1Cmdty]    Script Date: 14-07-2022 16:04:13 ******/
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
						 ,Dispatcher.Name AS Dispatcher,dbo.Loads.Dispatcher2Name AS Dispatcher2,dbo.Loads.Dispatcher3Name AS Dispatcher3,1 AS ReportIndex
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

/****** Object:  View [dbo].[vwSalesDetailSalesRep1FlatRate]    Script Date: 14-07-2022 16:04:52 ******/
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
						 ,Dispatcher.Name AS Dispatcher,dbo.Loads.Dispatcher2Name AS Dispatcher2,dbo.Loads.Dispatcher3Name AS Dispatcher3,1 AS ReportIndex
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

/****** Object:  View [dbo].[vwSalesDetailSalesRep1MilesRate]    Script Date: 14-07-2022 16:05:16 ******/
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
						 ,Dispatcher.Name AS Dispatcher,dbo.Loads.Dispatcher2Name AS Dispatcher2,dbo.Loads.Dispatcher3Name AS Dispatcher3,1 AS ReportIndex
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

/****** Object:  View [dbo].[vwSalesDetailSalesRep2Cmdty]    Script Date: 14-07-2022 16:05:43 ******/
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
						 ,Dispatcher.Name AS Dispatcher,dbo.Loads.Dispatcher2Name AS Dispatcher2,dbo.Loads.Dispatcher3Name AS Dispatcher3,2 AS ReportIndex
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

/****** Object:  View [dbo].[vwSalesDetailSalesRep2FlatRate]    Script Date: 14-07-2022 16:06:04 ******/
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
						 ,Dispatcher.Name AS Dispatcher,dbo.Loads.Dispatcher2Name AS Dispatcher2,dbo.Loads.Dispatcher3Name AS Dispatcher3,2 AS ReportIndex
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

/****** Object:  View [dbo].[vwSalesDetailSalesRep2MilesRate]    Script Date: 14-07-2022 16:06:15 ******/
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
						 ,Dispatcher.Name AS Dispatcher,dbo.Loads.Dispatcher2Name AS Dispatcher2,dbo.Loads.Dispatcher3Name AS Dispatcher3,2 AS ReportIndex
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

/****** Object:  View [dbo].[vwSalesDetailSalesRep3Cmdty]    Script Date: 14-07-2022 16:06:48 ******/
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
						 ,Dispatcher.Name AS Dispatcher,dbo.Loads.Dispatcher2Name AS Dispatcher2,dbo.Loads.Dispatcher3Name AS Dispatcher3,3 AS ReportIndex
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

/****** Object:  View [dbo].[vwSalesDetailSalesRep3FlatRate]    Script Date: 14-07-2022 16:07:06 ******/
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
						 ,Dispatcher.Name AS Dispatcher,dbo.Loads.Dispatcher2Name AS Dispatcher2,dbo.Loads.Dispatcher3Name AS Dispatcher3,3 AS ReportIndex
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

/****** Object:  View [dbo].[vwSalesDetailSalesRep3MilesRate]    Script Date: 14-07-2022 16:07:12 ******/
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
						 ,Dispatcher.Name AS Dispatcher,dbo.Loads.Dispatcher2Name AS Dispatcher2,dbo.Loads.Dispatcher3Name AS Dispatcher3,3 AS ReportIndex
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

/****** Object:  View [dbo].[vwSalesDetailSalesRep]    Script Date: 14-07-2022 16:04:03 ******/
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

/****** Object:  StoredProcedure [dbo].[USP_GetSalesDetailReport]    Script Date: 14-07-2022 15:55:26 ******/
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
@SalesRepReport bit,
@ReportIncludeAllDispatchers bit,
@ReportIncludeAllSalesRep bit
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
	IF(@GroupBy='dispatcher' AND @ReportIncludeAllDispatchers = 0)
	BEGIN
		SET @sql = @sql + ' AND ReportIndex = 1'
	END 
	
	IF(@GroupBy='salesAgent' AND @ReportIncludeAllSalesRep = 0)
	BEGIN
		SET @sql = @sql + ' AND ReportIndex = 1'
	END 
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


