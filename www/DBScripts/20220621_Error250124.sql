GO

/****** Object:  StoredProcedure [dbo].[USP_GetSalesReport]    Script Date: 21-06-2022 11:43:17 ******/
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
@BillTo varchar(150)
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


