GO

/****** Object:  StoredProcedure [dbo].[usp_GetLoadBoardDetails]    Script Date: 08-07-2022 09:14:45 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
/*--------------------------------------------------------------------------------

Procedure Name: usp_GetLoadBoardDetails
Purpose: Used to get the new load board with TODAYS LOAD, FUTURE LOAD and DISPATCHED LOADS
Created Date: 04, May 2018

---------------------------------------------------------------------------------*/

ALTER   PROCEDURE [dbo].[usp_GetLoadBoardDetails] @PageNo INT = 1, @PageSize INT = 30, @SortBy VARCHAR(150) ='l.LOADID', @SortOrder VARCHAR(10) = 'desc', @Currentusertype VARCHAR(100) = NULL,
@EmpID VARCHAR(500)=NULL, @OfficeID VARCHAR(100) =NULL, @IsCustomer VARCHAR(10)=NULL, 
@LoadCustomerID VARCHAR(150)=NULL, @StatusArg VARCHAR(100) = NULL,@CompanyID varchar(150),@showAllOfficeLoads bit,@SalesRepLoad bit
AS
BEGIN
    DECLARE @sql VARCHAR(MAX)
	--,@PageNo INT = 1
	--,@PageSize INT = 30
	--,@SortBy VARCHAR(150) ='l.LOADID'
	--,@SortOrder VARCHAR(10) = 'desc'
	,@LoadStatus VARCHAR(150)
	,@WhereStatement VARCHAR(7000) = NULL
	,@StartPage NVARCHAR(10)
	,@LastRecord NVARCHAR(10)
	--,@Currentusertype VARCHAR(100) = 'sales'
	--,@EmpID VARCHAR(500)='BA02BCC8-4F7F-4965-A62D-76CC3FA30273'
	--,@OfficeID VARCHAR(100) ='3D99B3CB-C23D-4491-A445-A2061D4120F3'
	--,@IsCustomer VARCHAR(10)='1'
	--,@LoadCustomerID VARCHAR(150)='504B6C51-CBB9-46EE-8056-FFCD17DD1434'
	,@Pagination VARCHAR(5000) = NULL
	--,@StatusArg VARCHAR(100) = 'Dispatched';
	
	SET @StartPage =(@PageNo - 1) * @PageSize + 1;
	SET @LastRecord  =@PageNo * @PageSize;
	
	IF @PageNo != -1
		SET @sql = N'WITH page AS (SELECT';
	ELSE
		SET @sql = N'SELECT';
    	

					SET @sql =@sql+' l.loadID, 
						l.LoadNumber,
						l.LoadStatusStopNo,
						ReleaseNo,
						l.statusTypeID,
						l.CarrierID AS CarrierID,
						ISNULL(l.TotalMiles,0) AS CarrierTotalMiles,
						l.CarrierInvoiceNumber,
						CustomerPONo,
						statusText,
						TotalCustomerCharges,
						TotalCarrierCharges,
						l.CarrierName,
						l.DeadHeadMiles,
						l.custName as CustomerName,
						[NewPickupDate] as PickupDate ,
						[NewDeliveryDate] as DeliveryDate ,
						empDispatch,
						l.SalesAgent as empAgent,
						userDefinedFieldTrucking,
						Equipments1.EquipmentName,
						l.DriverName,
						CustCurrency.CurrencyNameISO as CustomerCurrencyISO,
						CarrCurrency.CurrencyNameISO as CarrierCurrencyISO,
						finalconsignee.consigneeCity,
						finalconsignee.consigneeState,

						FirstShipper.CITY as shippercity,
						FirstShipper.StateCode as shipperstate,
						statusdescription,
						textcolorcode,
						ROW_NUMBER() OVER (ORDER BY '+@SortBy + ' ' +@SortOrder+', l.loadnumber
	                 ) AS Row
	      			 FROM LOADS l
					 INNER JOIN (SELECT
						    customerid
							FROM CustomerOffices c1 INNER JOIN offices o1 ON o1.officeid = c1.OfficeID
							WHERE o1.CompanyID = '''+@CompanyID+''''
	      				
					IF((@currentusertype = 'sales representative' OR @currentusertype = 'dispatcher' OR @currentusertype = 'manager') AND  ISNULL(LEN(@officeID),0) <> 0 )
					BEGIN
						SET @sql=@sql+' AND o1.officeid = '''+@officeID+''''
					END

					IF(ISNULL(LEN(@officeID),0) <> 0 )
					BEGIN
						SET @sql=@sql+' AND o1.officeid = '''+@officeID+''''
					END

					SET @sql =@sql+' group by customerid) Offices ON Offices.CustomerID = l.CustomerID
						left outer join (SELECT [StatusTypeID] as stTypeId,[statusText],colorCode,statusdescription,textcolorcode FROM [loadStatusTypes]) as loadStatus on loadStatus.stTypeId = l.StatusTypeID 
						left outer join loadstops on loadstops.LoadID = l.LoadID AND  loadstops.StopNo + 1 =  REPLACE(REPLACE(LoadStatusStopNo,''S'',''''),''C'','''') AND LoadType =  CASE WHEN LoadStatusStopNo like ''%S%'' THEN 1 ELSE 2 END
						left outer join (SELECT [Name] as empDispatch,[EmployeeID] FROM [Employees]) as Employees on Employees.EmployeeID =l.DispatcherID
						left outer join (SELECT [EquipmentID],EquipmentName,Driver as EquipDriver FROM [Equipments]) as Equipments1 on Equipments1.EquipmentID = l.EquipmentID
						left outer join (select loadtype,loadid,stopno as finalstop,City AS consigneeCity,CustName as consigneeStopName,Address AS consigneeLocation,PostalCode AS consigneePostalCode,ContactPerson AS consigneeContactPerson,Phone AS consigneePhone,fax AS consigneeFax,EmailID AS consigneeEmailID,ReleaseNo AS consigneeReleaseNo,Blind AS consigneeBlind,Instructions AS consigneeInstructions,Directions AS consigneeDirections,LoadStopID AS consigneeLoadStopID,NewBookedWith AS consigneeBookedWith,NewEquipmentID AS 
consigneeEquipmentID,NewDriverName AS consigneeDriverName,NewDriverName2 AS consigneeDriverName2,NewDriverCell AS consigneeDriverCell,NewTruckNo AS consigneeTruckNo,NewTrailorNo AS consigneeTrailorNo,RefNo AS consigneeRefNo,Miles AS consigneeMiles,CustomerID AS consigneeCustomerID,statecode as consigneeState from loadstops) as finalconsignee on finalconsignee.loadid =l.loadid and finalconsignee.loadtype=2 and finalconsignee.finalstop = (select max(stopno) from loadstops where loadid=l.loadid)
						left outer join (select CITY,StateCode,loadid,StopNo,LoadType from LoadStops) as FirstShipper on FirstShipper.loadid = l.loadid and FirstShipper.StopNo = 0 AND FirstShipper.LoadType = 1
						left outer join Currencies CustCurrency on CustCurrency.CurrencyID = CustomerCurrency
						left outer join Currencies CarrCurrency on CarrCurrency.CurrencyID = CarrierCurrency
	      				where l.LoadID = l.LoadID
						'
	
	
	SET @WhereStatement = ''
	IF @StatusArg = 'Todaysload'
		SET @WhereStatement = @WhereStatement+ 'AND  loadStatus.statusText BETWEEN ''2. BOOKED'' AND ''8. COMPLETED'' AND ( CONVERT(VARCHAR(8), NewPickUpDate, 1) = CONVERT(VARCHAR(8), GETDATE(), 1) OR ( NewPickUpDate < getdate() AND NewDeliveryDate > getdate()))'
	ELSE IF @StatusArg = 'FutureLoads'
		SET @WhereStatement = @WhereStatement+ 'AND  loadStatus.statusText BETWEEN ''1. ACTIVE'' AND ''2. BOOKED'' AND (NewPickUpDate > getdate() OR  NewPickUpDate IS NULL)'
	ELSE IF @StatusArg = 'Dispatched'
		SET @WhereStatement = @WhereStatement+ 'AND  loadStatus.statusText BETWEEN ''1. ACTIVE'' AND ''8. COMPLETED'' AND NewDeliveryDate < getdate() ' 
--print @WhereStatement
	
	IF(@Currentusertype = 'sales representative' AND ISNULL(LEN(@empID),0) <> 0 AND @showAllOfficeLoads = 0)
	BEGIN
		SET @WhereStatement=@WhereStatement+' AND (SalesRepID='''+@empID+''' or SalesRep1='''+@empID+''' or SalesRep2='''+@empID+''' or SalesRep3='''+@empID+''' or DispatcherID = '''+@empID+''' or Dispatcher1 = '''+@empID+''' or Dispatcher2 = '''+@empID+''' or Dispatcher3 = '''+@empID+''')'
	END

	IF(@Currentusertype <> 'Administrator' AND @SalesRepLoad =1)
	BEGIN
		SET @WhereStatement=@WhereStatement+' AND (SalesRepID='''+@empID+''' or SalesRep1='''+@empID+''' or SalesRep2='''+@empID+''' or SalesRep3='''+@empID+''')'
	END

	IF(@Currentusertype = 'dispatcher' AND ISNULL(LEN(@empID),0) <> 0 AND @showAllOfficeLoads = 0)
	BEGIN
		SET @WhereStatement=@WhereStatement+' AND (DispatcherID = '''+@empID+''' or Dispatcher1 = '''+@empID+''' or Dispatcher2 = '''+@empID+''' or Dispatcher3 = '''+@empID+''')'
	END

	IF (@PageNo != -1)
	BEGIN
		SET @Pagination = N')SELECT * FROM page WHERE Row between CONVERT(nvarchar(10), '+@StartPage+') and CONVERT(nvarchar(10), '+@LastRecord+')'
		--print @Pagination
   END
	IF (NOT @WhereStatement IS NULL) 
        SET @sql = @sql + @WhereStatement
	IF (NOT @Pagination IS NULL) 
		SET @sql = @sql + @Pagination

	print @sql;
    EXEC(@sql)
END

--exec usp_GetLoadBoardDetails
GO


