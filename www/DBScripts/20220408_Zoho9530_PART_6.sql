IF NOT EXISTS (SELECT column_name FROM INFORMATION_SCHEMA.columns where table_name = 'Loads' and column_name = 'PhoneExt')
BEGIN
	ALTER TABLE Loads ADD PhoneExt varchar(10);
END
IF NOT EXISTS (SELECT column_name FROM INFORMATION_SCHEMA.columns where table_name = 'LoadStops' and column_name = 'PhoneExt')
BEGIN
	ALTER TABLE LoadStops ADD PhoneExt varchar(10);
END

GO

/****** Object:  StoredProcedure [dbo].[USP_GetCustomerinfoForLoad]    Script Date: 08-04-2022 12:06:15 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER       PROC [dbo].[USP_GetCustomerinfoForLoad]
(
	@CustomerID varchar(200),
	@contacttype varchar(200)
)
AS
BEGIN

	select customerID, upper( a.CustomerName) as custname , a.location,a.City,c.State,a.StateCode,a.zipCode

	,CASE WHEN (SELECT COUNT(CC.CustomerContactID) FROM CustomerContacts CC WHERE CC.CustomerID = a.CustomerID AND CC.ContactType = @contacttype AND LEN(isnull(CC.ContactPerson,'')) <> 0) <> 0
    THEN 
    (SELECT TOP 1 CC.ContactPerson FROM CustomerContacts CC WHERE CC.CustomerID = a.CustomerID AND CC.ContactType = @contacttype AND LEN(isnull(CC.ContactPerson,'')) <> 0)
    ELSE 
    (SELECT TOP 1 CC.ContactPerson FROM CustomerContacts CC WHERE CC.CustomerID = a.CustomerID AND CC.ContactType <> @contacttype AND LEN(isnull(CC.ContactPerson,'')) <> 0)
    END AS ContactPerson

	,CASE WHEN (SELECT COUNT(CC.CustomerContactID) FROM CustomerContacts CC WHERE CC.CustomerID = a.CustomerID AND CC.ContactType = @contacttype AND LEN(isnull(CC.personMobileNo,'')) <> 0) <> 0
	THEN 
	(SELECT TOP 1 CC.personMobileNo FROM CustomerContacts CC WHERE CC.CustomerID = a.CustomerID AND CC.ContactType = @contacttype AND LEN(isnull(CC.personMobileNo,'')) <> 0)
	ELSE 
	(SELECT TOP 1 CC.personMobileNo FROM CustomerContacts CC WHERE CC.CustomerID = a.CustomerID AND CC.ContactType <> @contacttype AND LEN(isnull(CC.personMobileNo,'')) <> 0)
	END AS Cel

	,CASE WHEN (SELECT COUNT(CC.CustomerContactID) FROM CustomerContacts CC WHERE CC.CustomerID = a.CustomerID AND CC.ContactType = @contacttype AND LEN(isnull(CC.PhoneNO,'')) <> 0) <> 0
		        THEN 
		        (SELECT TOP 1 CC.PhoneNO FROM CustomerContacts CC WHERE CC.CustomerID = a.CustomerID AND CC.ContactType = @contacttype AND LEN(isnull(CC.PhoneNO,'')) <> 0)
		        ELSE 
		        (SELECT TOP 1 CC.PhoneNO FROM CustomerContacts CC WHERE CC.CustomerID = a.CustomerID AND CC.ContactType <> @contacttype AND LEN(isnull(CC.PhoneNO,'')) <> 0)
		        END AS TEL
	,CASE WHEN (SELECT COUNT(CC.CustomerContactID) FROM CustomerContacts CC WHERE CC.CustomerID = a.CustomerID AND CC.ContactType = @contacttype AND LEN(isnull(CC.PhoneNoExt,'')) <> 0) <> 0
		        THEN 
		        (SELECT TOP 1 CC.PhoneNoExt FROM CustomerContacts CC WHERE CC.CustomerID = a.CustomerID AND CC.ContactType = @contacttype AND LEN(isnull(CC.PhoneNoExt,'')) <> 0)
		        ELSE 
		        (SELECT TOP 1 CC.PhoneNoExt FROM CustomerContacts CC WHERE CC.CustomerID = a.CustomerID AND CC.ContactType <> @contacttype AND LEN(isnull(CC.PhoneNoExt,'')) <> 0)
		        END AS EXT
	,CASE WHEN (SELECT COUNT(CC.CustomerContactID) FROM CustomerContacts CC WHERE CC.CustomerID = a.CustomerID AND CC.ContactType = @contacttype AND LEN(isnull(CC.email,'')) <> 0) <> 0
		        THEN 
		        (SELECT TOP 1 CC.email FROM CustomerContacts CC WHERE CC.CustomerID = a.CustomerID AND CC.ContactType = @contacttype AND LEN(isnull(CC.email,'')) <> 0)
		        ELSE 
		        (SELECT TOP 1 CC.email FROM CustomerContacts CC WHERE CC.CustomerID = a.CustomerID AND CC.ContactType <> @contacttype AND LEN(isnull(CC.email,'')) <> 0)
		        END AS email
	,CASE WHEN (SELECT COUNT(CC.CustomerContactID) FROM CustomerContacts CC WHERE CC.CustomerID = a.CustomerID AND CC.ContactType = @contacttype AND LEN(isnull(CC.fax,'')) <> 0) <> 0
		        THEN 
		        (SELECT TOP 1 CC.fax FROM CustomerContacts CC WHERE CC.CustomerID = a.CustomerID AND CC.ContactType = @contacttype AND LEN(isnull(CC.fax,'')) <> 0)
		        ELSE 
		        (SELECT TOP 1 CC.fax FROM CustomerContacts CC WHERE CC.CustomerID = a.CustomerID AND CC.ContactType <> @contacttype AND LEN(isnull(CC.fax,'')) <> 0)
		        END AS fax
	,CustomerNotes Notes ,CustomerDirections DispatchNotes, creditlimit ,balance, Available, a.DefaultCurrency
	from Customers a 
	LEFT OUTER JOIN States c ON c.StateID=a.StateID
	
	where customerID=case when @CustomerID='' then null else @CustomerID end
end

GO


GO

/****** Object:  StoredProcedure [dbo].[USP_InsertLoad]    Script Date: 08-04-2022 12:10:03 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER                   proc [dbo].[USP_InsertLoad]
(
@loadManualNo bigint,
@customerid varchar(200),
@salesperson VARCHAR(500),
@CarrierInvoiceNumber bigint,
@dispatcher VARCHAR(500),
@Status varchar(200),
@posttoloadboard bit,
@posttoTranscore bit, 
@PostTo123LoadBoard bit,
@postCarrierRatetoloadboard bit ,
@postCarrierRatetoTranscore bit ,
@postCarrierRateto123LoadBoard bit ,
@notes VARCHAR(1000),
@dispatchnotes VARCHAR(8000),
@carriernotes VARCHAR(1000),
@PricingNotes VARCHAR(1000),
@ponumber VARCHAR(100),
@bolnumber VARCHAR(100),
@TotalCarrierCharges VARCHAR(100),
@TotalCustomerCharges VARCHAR(100),
@CarrierRate money,
@CustomerRate money,
@carrierid varchar(200) = null,
@carrierOfficeID varchar(200) = null,
@equipment varchar(200) = null,
@driver VARCHAR(100),
@drivercell VARCHAR(50),
@trucknumber VARCHAR(50),
@trailernumber VARCHAR(50),
@BookedWith varchar(200),
@PickupNO nvarchar(50),
@PickupDate datetime=null,
@PickupTime nvarchar(50),
@PickupTimeIn nvarchar(50),
@PickupTimeOut nvarchar(50),
@DeliveryNo nvarchar(50),
@DeliveryDate datetime=null,
@DeliveryTime nvarchar(50),
@DeliveryTimeIn nvarchar(50),
@DeliveryTimeOut nvarchar(50),
@ModifyBy nvarchar(40),
@CreatedIP nvarchar(50),
@GUID text,
@CustomerRatePerMile money,
@CarrierRatePerMile money,
@CustomerTotalMiles float,
@CarrierTotalMiles float,
@officeid varchar(200),
@orderDate date,
@BillDate date,
@ARExported nvarchar(1),
@APExported nvarchar(1),
@customerMilesCharges money,
@carrierMilesCharges money,
@customerCommoditiesCharges money,
@carrierCommoditiesCharges money,
@CustomerAddress nvarchar(200)=null,
@CustomerCity nvarchar(50)=null,
@CustomerState nvarchar(50)=null,
@CustomerPostalCode nvarchar(50)=null,
@CustomerContact nvarchar(100)=null,
@CustomerPhone nvarchar(30)=null,
@CustomerPhoneExt nvarchar(30)=null,
@CustomerFax nvarchar(30)=null,
@CustomerCell nvarchar(50)=null,
@CustName nvarchar(100)=null,
@invoiceNumber int,
@weight int,
@CarrierId2 nvarchar(200)=null,-- I dont know whts the purpose of carrierid defined earlier --
@ShipperState nvarchar(10)=null,
@ShipperCity nvarchar(50)=null,
@ConsigneeState nvarchar(10)=null,
@ConsigneeCity nvarchar(50)=null,
@SalesAgentId nvarchar(50)=null,
@EquipmentId nvarchar(200),
@CustomerCurrency int = null,
@CarrierCurrency int = null,
@IsConcatCarrierDriverIdentifier bit,
@InternalRef varchar(50) = null
,@noOfTrips int = null
,@FF float 
,@EquipmentLength float,
@SalesRep1 varchar(150),
@SalesRep2 varchar(150),
@SalesRep3 varchar(150),
@SalesRep1Percentage float,
@SalesRep2Percentage float,
@SalesRep3Percentage float,
@TotalDirectCost money,
@EquipmentWidth float,
@ContactEmail varchar(150),
@CustomDriverPay bit = 0,
@CriticalNotes varchar(40),
@Dispatcher1 varchar(150),
@Dispatcher2 varchar(150),
@Dispatcher3 varchar(150),
@Dispatcher1Percentage float,
@Dispatcher2Percentage float,
@Dispatcher3Percentage float,
@BillFromCompany varchar(36),
@CustomerPaid bit,
@CarrierPaid bit,
@userDefinedFieldTrucking varchar(255)=null
)
as
begin
--set @carrierID = null
--set @carrierOfficeID = null

if ltrim(Rtrim(IsNull(@carrierID, ''))) = ''
	set @carrierID = null

if ltrim(Rtrim(IsNull(@carrierOfficeID, ''))) = ''
		set @carrierOfficeID = null

if ltrim(Rtrim(IsNull(@equipment, ''))) = ''
		set @equipment = null

if ltrim(Rtrim(IsNull(@PickupDate, ''))) = ''
		set @PickupDate = null
		
if ltrim(Rtrim(IsNull(@DeliveryDate, ''))) = ''
		set @DeliveryDate = null

if ltrim(Rtrim(IsNull(@officeid, ''))) = ''
		set @officeid = null

if ltrim(Rtrim(IsNull(@orderDate, ''))) = ''
		set @orderDate = null
if ltrim(Rtrim(IsNull(@BillDate, ''))) = ''
		set @BillDate = null
-- customer id
-- sales person
-- dispatcher
-- Status
-- post to load board
-- notes
-- dispatch notes
-- po number
-- miles

-- return generated load ID

declare @generatedloadID uniqueidentifier
set @generatedloadID = NewID()

declare @CompanyID uniqueidentifier
SELECT TOP 1 @CompanyID=[CompanyID] FROM [Companies]


if ltrim(Rtrim(IsNull(@ShipperState, ''))) = ''
		set @ShipperState = null


if ltrim(Rtrim(IsNull(@ShipperCity, ''))) = ''
		set @ShipperCity = null


if ltrim(Rtrim(IsNull(@ConsigneeState, ''))) = ''
		set @ConsigneeState = null

		
if ltrim(Rtrim(IsNull(@ConsigneeCity, ''))) = ''
		set @ConsigneeCity = null
		
DECLARE @SalesAgentName nvarchar(50) 
set @SalesAgentName = null
IF (ltrim(Rtrim(IsNull(@SalesAgentId, ''))) != '')
 SELECT TOP 1 @SalesAgentName = Name FROM [dbo].[Employees] where EmployeeID = ltrim(Rtrim(@SalesAgentId))


DECLARE @EquipmentName nvarchar(200)
set @EquipmentName = null
IF (ltrim(Rtrim(IsNull(@EquipmentId, ''))) != '')
 Select @EquipmentName = EquipmentName from [dbo].[Equipments] where EquipmentID = @EquipmentId


DECLARE @CarrierName nvarchar(200), @DriverName nvarchar(200)

IF (ltrim(Rtrim(IsNull(@CarrierId2, ''))) != '')
BEGIN
	IF ((select IsCarrier from [Carriers] where CarrierID = @CarrierId2) = 1)
	BEGIN
		select top 1 @CarrierName=CarrierName from [Carriers] where CarrierID = @CarrierId2;
		set @DriverName = null
	END
	ELSE
	BEGIN
		select top 1 @DriverName=CarrierName from [Carriers] where CarrierID = @CarrierId2;
		set @CarrierName = null
	END
END


IF (@IsConcatCarrierDriverIdentifier = 1 AND ltrim(Rtrim(IsNull(@CarrierId2, ''))) != '')
BEGIN
	DECLARE @TempDispatchNotes varchar(4000)
	DECLARE @TempModifyBy varchar(100)
	DECLARE @LastChangeDate as varchar(100)
	DECLARE @DriverCarrier as varchar(100)

	SELECT @TempModifyBy = Name FROM Employees WHERE Employees.loginid = @ModifyBy
	SELECT @LastChangeDate = replace(CONVERT(CHAR(10),getdate(),110), '-', '/') + SUBSTRING(CONVERT(varchar,getdate(),0),12,8) 
	
	IF ((select IsCarrier from [Carriers] where CarrierID = @CarrierId2) = 1)
	BEGIN		
		set @loadManualNo = CONCAT('1', @loadManualNo)
		set @TempDispatchNotes = @LastChangeDate+' - '+@TempModifyBy+' > Carrier '+@CarrierName+'  is added to the load (New Load Number is '+ltrim(Rtrim(CONVERT(CHAR(20),@loadManualNo)))+')'

		IF (ltrim(Rtrim(IsNull(@dispatchnotes, ''))) != '')
		BEGIN
			set @dispatchnotes = CONCAT(@dispatchnotes, @TempDispatchNotes)	
		END
		ELSE
		BEGIN
			set @dispatchnotes =  @TempDispatchNotes
		END
	END
	ELSE
	BEGIN		
		set @loadManualNo = CONCAT('2', @loadManualNo)
		set @TempDispatchNotes = @LastChangeDate+' - '+@TempModifyBy+' > Driver '+@DriverName+'  is added to the load (New Load Number is '+ltrim(Rtrim(CONVERT(CHAR(20),@loadManualNo)))+')'

		IF (ltrim(Rtrim(IsNull(@dispatchnotes, ''))) != '')
		BEGIN
			set @dispatchnotes = CONCAT(@dispatchnotes, @TempDispatchNotes)	
		END
		ELSE
		BEGIN
			set @dispatchnotes =  @TempDispatchNotes
		END
	END
END


--set @str1='
INSERT INTO Loads
(LoadID,
LoadNumber,
ControlNumber,
CreatedDateTime,
SalesRepID, 
DispatcherID,
CustomerPONo,
BOLNum,
StatusTypeID,
CustomerID,
IsPost,
IsTransCorePst,
PostTo123LoadBoard,
postCarrierRatetoloadboard,
postCarrierRatetoTranscore,
postCarrierRateto123LoadBoard,
TotalCarrierCharges,
TotalCustomerCharges,
LastModifiedDate,
CreatedBy,
ModifiedBy,
HasEnrouteStops,HasTemp,
IsPepUpload,
IsLocked,
NewNotes,
NewDispatchNotes,
carrierNotes,
PricingNotes,
CustFlatRate,
CarrFlatRate,
EquipmentID,
DriverName,
DriverCell,
TruckNo,
TrailorNo,
newbookedwithload,
NewPickupNo,
NewPickupDate,
NewPickupTime,
NewPickupTimeIn,
NewPickupTimeOut,
NewDeliveryNo,
NewDeliveryDate,
NewDeliveryTime,
NewDeliveryDateTimeIn,
NewDeliveryDateTimeOut,
CarrierID,
CarrOfficeID,
CreatedByIP,
CustomerRatePerMile,
CarrierRatePerMile,
TotalMiles,
orderDate,
BillDate,
ARExported,
APExported,
customerMilesCharges,
carrierMilesCharges,
customerCommoditiesCharges,
carrierCommoditiesCharges,
Address,							
City,								
StateCode,							
PostalCode,							
ContactPerson,						
Phone,		
PhoneExt,
Fax,								
CellNo,
CustName,
invoiceNumber,
weight,
CarrierInvoiceNumber,
ShipperState,
ShipperCity,
ConsigneeState,
ConsigneeCity,
SalesAgent,
EquipmentName,
CarrierName,
LoadDriverName,
CustomerCurrency,
CarrierCurrency,
InternalRef
,noOfTrips
,FF
,EquipmentLength
,SalesRep1
,SalesRep2
,SalesRep3
,SalesRep1Percentage
,SalesRep2Percentage
,SalesRep3Percentage
,TotalDirectCost
,EquipmentWidth
,ContactEmail
,userDefinedFieldTrucking
,CustomDriverPay
,CriticalNotes
,Dispatcher1
,Dispatcher2
,Dispatcher3
,Dispatcher1Percentage
,Dispatcher2Percentage
,Dispatcher3Percentage
,BillFromCompany
,CustomerPaid
,CarrierPaid
)

VALUES
(@generatedloadID, 
@loadManualNo,
@loadManualNo,
GETDATE(),
@salesperson,
@dispatcher,
@ponumber,
@bolnumber,
@Status,
@customerid,
@posttoloadboard,
@posttoTranscore,
@PostTo123LoadBoard,
@postCarrierRatetoloadboard,
@postCarrierRatetoTranscore,
@postCarrierRateto123LoadBoard,
@TotalCarrierCharges,
@TotalCustomerCharges,

GETDATE(),
@ModifyBy,
@ModifyBy,
0,0,0,0,
@notes,@dispatchnotes,@carriernotes,@PricingNotes,@CustomerRate, @CarrierRate,
@equipment,
@driver,
@drivercell,
@trucknumber,
@trailernumber,
@BookedWith,
@PickupNO ,
@PickupDate ,
@PickupTime ,
@PickupTimeIn,
@PickupTimeOut ,
@DeliveryNo ,
@DeliveryDate ,
@DeliveryTime ,
@DeliveryTimeIn ,
@DeliveryTimeOut,
@CarrierID,
@carrierOfficeID,
@CreatedIP,
@CustomerRatePerMile, 
@CarrierRatePerMile,
@CustomerTotalMiles, 
@orderDate,
@BillDate,
@ARExported,
@APExported,
@customerMilesCharges,
@carrierMilesCharges,
@customerCommoditiesCharges,
@carrierCommoditiesCharges,
@CustomerAddress,
@CustomerCity,
@CustomerState,
@CustomerPostalCode,
@CustomerContact,
@CustomerPhone,
@CustomerPhoneExt,
@CustomerFax,
@CustomerCell,
@CustName,
@invoiceNumber,
@weight,
@CarrierInvoiceNumber,
@ShipperState,
@ShipperCity,
@ConsigneeState,
@ConsigneeCity,
@SalesAgentName,
@EquipmentName,
@CarrierName,
@DriverName,
@CustomerCurrency,
@CarrierCurrency,
@InternalRef
,@noOfTrips
,@FF
,@EquipmentLength
,@SalesRep1
,@SalesRep2
,@SalesRep3
,@SalesRep1Percentage
,@SalesRep2Percentage
,@SalesRep3Percentage
,@TotalDirectCost
,@EquipmentWidth
,@ContactEmail
,@userDefinedFieldTrucking
,@CustomDriverPay
,@CriticalNotes
,@Dispatcher1
,@Dispatcher2
,@Dispatcher3
,@Dispatcher1Percentage
,@Dispatcher2Percentage
,@Dispatcher3Percentage
,@BillFromCompany
,@CustomerPaid
,@CarrierPaid
)
--exec sp_executesql @str1

select @generatedloadID as lastLoadId,@loadManualNo as impref
end

--exec sp_executesql @FinalSQL






/*    ==Scripting Parameters==

    Source Server Version : SQL Server 2016 (13.0.4001)
    Source Database Engine Edition : Microsoft SQL Server Enterprise Edition
    Source Database Engine Type : Standalone SQL Server

    Target Server Version : SQL Server 2017
    Target Database Engine Edition : Microsoft SQL Server Standard Edition
    Target Database Engine Type : Standalone SQL Server
*/

GO


GO

/****** Object:  StoredProcedure [dbo].[USP_UpdateLoad]    Script Date: 08-04-2022 12:13:17 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER                 proc [dbo].[USP_UpdateLoad]
(
@carrierInvoiceNo bigint,
@Loadid varchar(200),
@loadManualNo bigint,
@PrevloadNo bigint,
@customerid varchar(200),
@salesperson VARCHAR(500),
@dispatcher VARCHAR(500),
@Status VARCHAR(100),
@posttoloadboard bit,
@posttoTranscore bit,
@PostTo123LoadBoard bit,
@postCarrierRatetoloadboard bit ,
@postCarrierRatetoTranscore bit ,
@postCarrierRateto123LoadBoard bit ,
@notes VARCHAR(1000),
@dispatchnotes VARCHAR(max),
@carriernotes VARCHAR(1000),
@pricingnotes VARCHAR(1000),
@ponumber VARCHAR(100),
@bollnumber VARCHAR(100),
@TotalCarrierCharges VARCHAR(100),
@TotalCustomerCharges VARCHAR(100),
@CarrierRate money,
@CustomerRate money,
@carrierid varchar(200) = null,
@carrierOfficeID varchar(200) = null,
@equipment varchar(200) = null,
@driver VARCHAR(100),
@drivercell VARCHAR(50),
@trucknumber VARCHAR(50),
@trailernumber VARCHAR(50),
@bookedWith nvarchar(1000),
@PickupNO  nvarchar(50),
@PickupDate datetime=null,
@PickupTime  nvarchar(50),
@PickupTimeIn  nvarchar(50),
@PickupTimeOut nvarchar(50),
@DeliveryNo		nvarchar(50),
@DeliveryDate datetime=null,
@DeliveryTime varchar(50),
@DeliveryTimeIn varchar(50),
@DeliveryTimeOut varchar(50),
@ModifyBy nvarchar(150),
@UpdatedByIP varchar(50),
@CustomerRatePerMile money,
@CarrierRatePerMile money,
@CustomerTotalMiles float,
@CarrierTotalMiles float,
@officeid varchar(200),
@orderDate date,
@billingDate date,
@totalProfit money,
@ARExported nvarchar(1),
@APExported nvarchar(1),
@customerMilesCharges money,
@carrierMilesCharges money,
@customerCommoditiesCharges money,
@carrierCommoditiesCharges money,
@CustomerAddress nvarchar(200)=null,
@CustomerCity nvarchar(50)=null,
@CustomerState nvarchar(50)=null,
@CustomerPostalCode nvarchar(50)=null,
@CustomerContact nvarchar(100)=null,
@CustomerPhone nvarchar(30)=null,
@CustomerPhoneExt nvarchar(30)=null,
@CustomerFax nvarchar(30)=null,
@CustomerCell nvarchar(50)=null,
@CustomerName nvarchar(100),
@IsPartial int=0,
@readyDate datetime=null,
@arriveDate datetime=null,
@isExcused int=0,
@bookedBy varchar(64)=null,
@invoicenumber int,
@weight int,
@ShipperState nvarchar(10)=null,
@ShipperCity nvarchar(50)=null,
@ConsigneeState nvarchar(10)=null,
@ConsigneeCity nvarchar(50)=null,
@CustomerCurrency int=null,
@CarrierCurrency int=null,
@IsConcatCarrierDriverIdentifier bit = 0,
@DeadHeadMiles float,
@InternalRef varchar(50) = null,
@EquipmentLength float,
@TotalDirectCost money,
@EquipmentWidth float,
@ContactEmail varchar(150)
,@CompanyID VARCHAR(60)
,@ff float
,@CustomDriverPay bit = 0
,@CriticalNotes varchar(40)
,@LoadStatusStopNo varchar(10)
,@BillFromCompany varchar(36)
,@CustomerPaid bit
,@CarrierPaid bit
)
as
begin
if ltrim(Rtrim(IsNull(@carrierID, ''))) = ''
		set @carrierID = null

if ltrim(Rtrim(IsNull(@carrierOfficeID, ''))) = ''
		set @carrierOfficeID = null

if ltrim(Rtrim(IsNull(@equipment, ''))) = ''
		set @equipment = null

if ltrim(Rtrim(IsNull(@DeliveryDate, ''))) = ''
		set @DeliveryDate = null

if ltrim(Rtrim(IsNull(@officeid, ''))) = ''
		set @officeid = null
if ltrim(Rtrim(IsNull(@PickupDate, ''))) = ''
		set @PickupDate = null
		
if ltrim(Rtrim(IsNull(@DeliveryDate, ''))) = ''
		set @DeliveryDate = null



if ltrim(Rtrim(IsNull(@ShipperState, ''))) = ''
		set @ShipperState = null


if ltrim(Rtrim(IsNull(@ShipperCity, ''))) = ''
		set @ShipperCity = null


if ltrim(Rtrim(IsNull(@ConsigneeState, ''))) = ''
		set @ConsigneeState = null

		
if ltrim(Rtrim(IsNull(@ConsigneeCity, ''))) = ''
		set @ConsigneeCity = null


DECLARE @SalesAgentName nvarchar(50) 
set @SalesAgentName = null
IF (ltrim(Rtrim(IsNull(@salesperson, ''))) != '')
 SELECT TOP 1 @SalesAgentName = Name FROM [dbo].[Employees] where EmployeeID = ltrim(Rtrim(@salesperson))


DECLARE @EquipmentName nvarchar(200)
set @EquipmentName = null
IF (ltrim(Rtrim(IsNull(@equipment, ''))) != '')
 Select @EquipmentName = EquipmentName from [dbo].[Equipments] where EquipmentID = @equipment


DECLARE @CarrierName nvarchar(200), @DriverName nvarchar(200)

IF (ltrim(Rtrim(IsNull(@carrierID, ''))) != '')
BEGIN
	IF ((select IsCarrier from [Carriers] where CarrierID = @carrierID) = 1)
	BEGIN
		select top 1 @CarrierName=CarrierName from [Carriers] where CarrierID = @carrierID AND CompanyID = @CompanyID;
		set @DriverName = null
	END
	ELSE
	BEGIN
		select top 1 @DriverName=CarrierName from [Carriers] where CarrierID = @carrierID AND CompanyID = @CompanyID;
		set @CarrierName = null
	END
	

END

IF (@IsConcatCarrierDriverIdentifier = 1)
BEGIN
	DECLARE @ExistingCarrierID varchar(200)
	DECLARE @ExistingLoadManualNo varchar(200)
	DECLARE @addIdentifier bit = 0
	DECLARE @replaceIdentifier bit = 0
	DECLARE @TempDispatchNotes varchar(4000)
	DECLARE @TempModifyBy varchar(100)		
	DECLARE @LastChangeDate as varchar(100)

	SELECT @LastChangeDate = replace(CONVERT(CHAR(10),getdate(),110), '-', '/') + SUBSTRING(CONVERT(varchar,getdate(),0),12,8)
	SELECT @TempModifyBy = Name FROM Employees WHERE Employees.loginid = @ModifyBy

	select @ExistingCarrierID = CarrierID, @ExistingLoadManualNo = LoadNumber from loads where LoadID = @loadid
	
	IF((@carrierid IS NOT NULL) AND (ltrim(Rtrim(IsNull(@carrierid, ''))) != '')) 
	BEGIN
		IF (@ExistingCarrierID = '' OR @ExistingCarrierID IS NULL )
		BEGIN
			set @addIdentifier = 1
		END

		IF ((@ExistingCarrierID IS NOT NULL) AND (@ExistingCarrierID != @carrierid) AND (@ExistingCarrierID != '') AND (@ExistingLoadManualNo = @loadManualNo))
		BEGIN
			set @replaceIdentifier = 1
			set @addIdentifier = 1
		END

		IF (@ExistingLoadManualNo != @loadManualNo)
		BEGIN
			set @addIdentifier = 1
		END
		
		IF (@addIdentifier = 1)
		BEGIN
			 
			IF(@replaceIdentifier = 1 AND ((LEFT(@loadManualNo, 1) = 1) OR (LEFT(@loadManualNo, 1) = 2)))
			BEGIN
				set @loadManualNo = RIGHT(@loadManualNo, LEN(@loadManualNo) - 1)
			END

			IF ((select IsCarrier from [Carriers] where CarrierID = @carrierid) = 1)
			BEGIN		
				set @loadManualNo = CONCAT('1', @loadManualNo)
				set @TempDispatchNotes =  @LastChangeDate+' - '+@TempModifyBy+' > Carrier '+@CarrierName+' is added to the load(New Load Number is '+ltrim(Rtrim(CONVERT(CHAR(20),@loadManualNo)))+')'

				IF (ltrim(Rtrim(IsNull(@dispatchnotes, ''))) != '')
				BEGIN
					set @dispatchnotes = CONCAT(@dispatchnotes, CHAR(13), @TempDispatchNotes)
				END
				ELSE
				BEGIN
					set @dispatchnotes = @TempDispatchNotes
				END
			END
			ELSE
			BEGIN		
				set @loadManualNo = CONCAT('2', @loadManualNo)
				set @TempDispatchNotes = @LastChangeDate+' - '+@TempModifyBy+' > Driver '+@DriverName+' is added to the load(New Load Number is '+ltrim(Rtrim(CONVERT(CHAR(20),@loadManualNo)))+')'

				IF (ltrim(Rtrim(IsNull(@dispatchnotes, ''))) != '')
				BEGIN
					set @dispatchnotes = CONCAT(@dispatchnotes, CHAR(13), @TempDispatchNotes)
				END
				ELSE
				BEGIN
					set @dispatchnotes =  @TempDispatchNotes
				END
			END
		END
	END

	IF(ltrim(Rtrim(IsNull(@carrierid, ''))) = '' AND (@ExistingCarrierID IS NOT NULL) AND (@ExistingCarrierID != '') AND (@ExistingLoadManualNo = @loadManualNo)) 
	BEGIN
		IF((LEFT(@loadManualNo, 1) = 1) OR (LEFT(@loadManualNo, 1) = 2))
		BEGIN
			set @loadManualNo = RIGHT(@loadManualNo, LEN(@loadManualNo) - 1)
			
			IF ((select IsCarrier from [Carriers] where CarrierID = @ExistingCarrierID) = 1)
			BEGIN		
				select top 1 @CarrierName=CarrierName from [Carriers] where CarrierID = @ExistingCarrierID;
				set @TempDispatchNotes =  @LastChangeDate+' - '+@TempModifyBy+' > Carrier '+@CarrierName+' is removed from the load(New Load Number is '+ltrim(Rtrim(CONVERT(CHAR(20),@loadManualNo)))+')'

				IF (ltrim(Rtrim(IsNull(@dispatchnotes, ''))) != '')
				BEGIN
					set @dispatchnotes = CONCAT(@dispatchnotes, CHAR(13), @TempDispatchNotes)
				END
				ELSE
				BEGIN
					set @dispatchnotes =  @TempDispatchNotes
				END
			END
			ELSE
			BEGIN
				select top 1 @DriverName=CarrierName from [Carriers] where CarrierID = @ExistingCarrierID;
				set @TempDispatchNotes =  @LastChangeDate+' - '+@TempModifyBy+' > Driver '+@DriverName+' is removed from the load(New Load Number is '+ltrim(Rtrim(CONVERT(CHAR(20),@loadManualNo)))+')'

				IF (ltrim(Rtrim(IsNull(@dispatchnotes, ''))) != '')
				BEGIN
					set @dispatchnotes = CONCAT(@dispatchnotes, CHAR(13), @TempDispatchNotes)
				END
				ELSE
				BEGIN
					set @dispatchnotes =  @TempDispatchNotes
				END
			END
		END
	END
END
-- customer id
-- sales person
-- dispatcher
-- Status
-- post to load board
-- notes
-- dispatch notes
-- po number
-- miles

-- return generated load ID

	update Loads
	set

	LoadID=                            @loadID, 
	LoadNumber=                        @loadManualNo,
	SalesRepID=						   @salesperson,
	DispatcherID=					   @dispatcher,
	CustomerPONo=					   @ponumber,
	BOLNum=							   @bollnumber,
	StatusTypeID=					   @Status,
	CustomerID=						   @customerid,
	IsPost=							   @posttoloadboard,
	IsTransCorePst=					   @posttoTranscore,
	PostTo123LoadBoard=                @PostTo123LoadBoard,
	TotalCarrierCharges=			   @TotalCarrierCharges,
	TotalCustomerCharges=			   @TotalCustomerCharges,
	LastModifiedDate=				   GETDATE(),
	ModifiedBy=						   @ModifyBy,
	UpdatedByIP=                       @UpdatedByIP, 
	NewNotes=						   @notes,
	NewDispatchNotes=				   @dispatchnotes,
	carrierNotes=					   @carriernotes,
	pricingNotes=					   @pricingnotes,
	CustFlatRate=					   @CustomerRate,
	CarrFlatRate=					   @carrierRate ,
	CarrierID=						   CASE WHEN @carrierID IS NULL THEN @carrierID ELSE CASE WHEN (SELECT COUNT(CarrierID) FROM  Carriers WHERE CompanyID = @CompanyID AND CarrierID = @carrierID) <> 0 THEN @carrierID ELSE CarrierID END END,
	CarrOfficeID=						@carrierOfficeID,
	EquipmentID=					   @equipment,
	DriverName=						   @driver,
	DriverCell=						   @drivercell,
	TruckNo=						   @trucknumber,
	TrailorNo=						   @trailernumber,
	newbookedwithload=					 @bookedWith ,
	NewPickupNo =						@PickupNO ,
	NewPickupDate =						@PickupDate ,
	NewPickupTime =						@PickupTime ,
	NewPickupTimeIn =					@PickupTimeIn,
	NewPickupTimeOut =					@PickupTimeOut ,
	NewDeliveryNo =						@DeliveryNo ,
	NewDeliveryDate =					@DeliveryDate ,
	NewDeliveryTime =					@DeliveryTime ,
	NewDeliveryDateTimeIn =				@DeliveryTimeIn ,
	NewDeliveryDateTimeOut =			@DeliveryTimeOut,
	CustomerRatePerMile =				@CustomerRatePerMile,
	CarrierRatePerMile=					@CarrierRatePerMile,
	TotalMiles =						@CustomerTotalMiles,
	orderDate=							@orderDate,
	BillDate=							@billingDate,
	totalProfit=						@totalProfit,
	ARExported=							@ARExported,
	APExported=							@APExported,
	customerMilesCharges=				@customerMilesCharges,
	carrierMilesCharges=				@carrierMilesCharges,
	customerCommoditiesCharges=			@customerCommoditiesCharges,
	carrierCommoditiesCharges=			@carrierCommoditiesCharges,
	Address=							@CustomerAddress,
	City=								@CustomerCity,
	StateCode=							@CustomerState,
	PostalCode=							@CustomerPostalCode,
	ContactPerson=						@CustomerContact,
	Phone=								@CustomerPhone,
	PhoneExt=							@CustomerPhoneExt,
	Fax=								@CustomerFax,
	CellNo=								@CustomerCell,
	CustName=							@CustomerName,
	IsPartial=							@IsPartial,
	readyDate=							@readyDate,
	arriveDate=							@arriveDate,
	isExcused=							@isExcused,
	bookedBy=							@bookedBy,
	invoiceNumber=                      @invoicenumber, 
	weight=                             @weight,
	CarrierInvoiceNumber=               @carrierInvoiceNo,
	postCarrierRatetoloadboard=         @postCarrierRatetoloadboard,
	postCarrierRatetoTranscore=         @postCarrierRatetoTranscore ,
	postCarrierRateto123LoadBoard=      @postCarrierRateto123LoadBoard,
	ShipperState=						@ShipperState,
	ShipperCity=						@ShipperCity,
	ConsigneeState=						@ConsigneeState,
	ConsigneeCity=						@ConsigneeCity,
	SalesAgent=							@SalesAgentName,
	EquipmentName=						@EquipmentName,
	CarrierName=						@CarrierName,
	LoadDriverName=						@DriverName,
	CustomerCurrency=					@CustomerCurrency,
	CarrierCurrency=					@CarrierCurrency,
	DeadHeadMiles=                      @DeadHeadMiles,
	InternalRef=						@InternalRef,
	EquipmentLength=					@EquipmentLength,
	TotalDirectCost=                    @TotalDirectCost,
	EquipmentWidth=						@EquipmentWidth,
	ContactEmail=						@ContactEmail,
	ff=									@ff,
	CustomDriverPay=					@CustomDriverPay,
	CriticalNotes=						@CriticalNotes,
	LoadStatusStopNo=					@LoadStatusStopNo,
	BillFromCompany=                    @BillFromCompany,
	CustomerPaid=						@CustomerPaid,
	CarrierPaid=						@CarrierPaid
	where LoadID=@loadID
	Update LoadPostEverywhereDetails  set imprtref= @loadManualNo where imprtref=@PrevloadNo
end




GO


GO

/****** Object:  StoredProcedure [dbo].[USP_InsertLoadStop]    Script Date: 08-04-2022 12:22:38 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER                   proc [dbo].[USP_InsertLoadStop]
(
@loadid varchar(200),
@isoriginpickup VARCHAR(10),
@isfinaldelivery VARCHAR(10),
@bookedwith VARCHAR(100),
@equipment varchar(200) = null,
@driver VARCHAR(100),

@drivercell VARCHAR(50),
@trucknumber VARCHAR(50),
@trailernumber VARCHAR(50),
@refnumber VARCHAR(100),
@miles float,
@carrierid varchar(200) = null,
@carrierOfficeID varchar(200) = null,
@PickupNO nvarchar(50),
@stopDate datetime=null,
@stopTime nvarchar(50),
@TimeIn nvarchar(50),
@TimeOut nvarchar(50),
@ModifyBy nvarchar(150),
@customerID varchar(200)=null,
@Blind nvarchar(200),
@instructions nvarchar(500),
@directions nvarchar(500),
@loadType integer,
@address nvarchar(200)=null,
@city nvarchar(50)=null,
@state nvarchar(50)=null,
@postalCode nvarchar(50)=null,
@contact nvarchar(100)=null,
@phone nvarchar(30)=null,
@phoneExt nvarchar(30)=null,
@fax nvarchar(30)=null,
@email nvarchar(100)=null,
@custName nvarchar(100)=null,
@userDef1 varchar(200)=null,
@userDef2 varchar(200)=null,
@userDef3 varchar(200)=null,
@userDef4 varchar(200)=null,
@userDef5 varchar(200)=null,
@userDef6 varchar(200)=null,
@StopNo integer ,
@stopdateDifference integer,
@driver2 VARCHAR(100),
@NewDriverCell2 VARCHAR(15)
,@temperature varchar(150)
,@temperaturescale VARCHAR(5)
,@TimeZone as varchar(25)
,@CarrierEmailID as VARCHAR(150)
,@MultipleDates as VARCHAR(250)
,@NewCarrierID2 varchar(60)
,@NewCarrierID3 varchar(60)
,@NewDriverCell3 varchar(15)
,@CustomDriverPayFlatRate float = 0
,@CustomDriverPayFlatRate2 float = 0
,@CustomDriverPayFlatRate3 float = 0
,@CustomDriverPayPercentage float = 0
,@CustomDriverPayPercentage2 float = 0
,@CustomDriverPayPercentage3 float = 0
,@CustomDriverPayOption int = 0
,@CustomDriverPayOption2 int = 0
,@CustomDriverPayOption3 int = 0
,@CarrierContactID varchar(36)
,@CarrierPhoneNo varchar(50)
,@CarrierPhoneNoExt varchar(50)
,@CarrierFax varchar(50)
,@CarrierFaxExt varchar(50)
,@CarrierTollFree varchar(50)
,@CarrierTollFreeExt varchar(50)
,@CarrierCell varchar(50)
,@CarrierCellExt varchar(50)
,@CarrierEmailID2 as VARCHAR(150)
,@CarrierContactID2 varchar(36)
,@CarrierPhoneNo2 varchar(50)
,@CarrierPhoneNoExt2 varchar(50)
,@CarrierFax2 varchar(50)
,@CarrierFaxExt2 varchar(50)
,@CarrierTollFree2 varchar(50)
,@CarrierTollFreeExt2 varchar(50)
,@CarrierCell2 varchar(50)
,@CarrierCellExt2 varchar(50)
,@CarrierEmailID3 as VARCHAR(150)
,@CarrierContactID3 varchar(36)
,@CarrierPhoneNo3 varchar(50)
,@CarrierPhoneNoExt3 varchar(50)
,@CarrierFax3 varchar(50)
,@CarrierFaxExt3 varchar(50)
,@CarrierTollFree3 varchar(50)
,@CarrierTollFreeExt3 varchar(50)
,@CarrierCell3 varchar(50)
,@CarrierCellExt3 varchar(50)
,@EquipmentTrailer varchar(36)
)
as
begin

if ltrim(Rtrim(IsNull(@carrierID, ''))) = ''
		set @carrierID = null

if ltrim(Rtrim(IsNull(@carrierOfficeID, ''))) = ''
		set @carrierOfficeID = null

if ltrim(Rtrim(IsNull(@equipment, ''))) = ''
		set @equipment = null

if ltrim(Rtrim(IsNull(@carrierOfficeID, ''))) = 'Null'
		set @carrierOfficeID = null

if(@customerID='00000000-0000-0000-0000-000000000000')
	set @customerID =null
--declare @StopNo int
--set @StopNo = 0
--if @loadType = '1'
--	SELECT @StopNo= isnull(MAX(StopNo)+1,0) FROM LoadStops where [LoadID] = @loadid
--else if @loadType = '2'
--	SELECT @StopNo= isnull(MAX(StopNo),0) FROM LoadStops where [LoadID] = @loadid
	

declare @Shipper uniqueidentifier
Set @Shipper = NewID()
declare @StateID uniqueidentifier
--select top 1 @StateID =  stateid from States where StateCode =@State 

INSERT INTO [dbo].[LoadStops]
([LoadStopID]
,[LoadID]
,[StopNo]
,ReleaseNo
,Blind
,StopDate
,StopTime
,TimeIn
,TimeOut
,Instructions
,Directions
,CustomerID
,CreatedBy
,CreatedDateTime
,ModifiedBy
,LastModifiedDate
,loadType
,isoriginpickup
,IsFinalDelivery
,newBookedwith
,NewEquipmentID
,NewDriverName
,NewDriverName2
,NewDriverCell
,NewTruckNo
,NewTrailorNo
,RefNo
,Miles
,NewCarrierID
,NewOfficeID
,Address 	
,City 	
,StateCode 
,PostalCode 	
,ContactPerson 
,Phone 
,PhoneExt
,Fax 
,EmailID
,CustName
,userDef1
,userDef2
,userDef3
,userDef4
,userDef5
,userDef6
,stopdateDifference
,NewDriverCell2
,temperature
,temperaturescale
,timezone
,CarrierEmailID
,MultipleDates
,NewCarrierID2
,NewCarrierID3
,NewDriverCell3
,CustomDriverPayFlatRate
,CustomDriverPayFlatRate2
,CustomDriverPayFlatRate3
,CustomDriverPayPercentage
,CustomDriverPayPercentage2
,CustomDriverPayPercentage3
,CustomDriverPayOption
,CustomDriverPayOption2
,CustomDriverPayOption3
,CarrierContactID
,CarrierPhoneNo
,CarrierPhoneNoExt
,CarrierFax
,CarrierFaxExt
,CarrierTollFree
,CarrierTollFreeExt
,CarrierCell
,CarrierCellExt
,CarrierEmailID2
,CarrierContactID2
,CarrierPhoneNo2
,CarrierPhoneNoExt2
,CarrierFax2
,CarrierFaxExt2
,CarrierTollFree2
,CarrierTollFreeExt2
,CarrierCell2
,CarrierCellExt2
,CarrierEmailID3
,CarrierContactID3
,CarrierPhoneNo3
,CarrierPhoneNoExt3
,CarrierFax3
,CarrierFaxExt3
,CarrierTollFree3
,CarrierTollFreeExt3
,CarrierCell3
,CarrierCellExt3
,EquipmentTrailer
)

VALUES
(@Shipper,
@loadid,
@StopNo,
@PickupNO,
@Blind,
@stopDate,
@stopTime ,
@timein,
@timeout,
@instructions,
@directions,
@CustomerID,
@ModifyBy,
GETDATE(),
@ModifyBy,
GETDATE()
,@loadType
,@isoriginpickup
,@isfinaldelivery
,@bookedwith
,@equipment
,@driver
,@driver2
,@drivercell
,@trucknumber
,@trailernumber
,@refnumber
,@miles
,@carrierid
,@carrierOfficeID
,@address
,@city
,@state
,@postalCode
,@contact
,@phone
,@phoneExt
,@fax
,@email
,@custName
,@userDef1
,@userDef2
,@userDef3
,@userDef4
,@userDef5
,@userDef6
,@stopdateDifference
,@NewDriverCell2
,@temperature
,@temperaturescale
,@timezone
,@CarrierEmailID
,@MultipleDates
,@NewCarrierID2
,@NewCarrierID3
,@NewDriverCell3
,@CustomDriverPayFlatRate
,@CustomDriverPayFlatRate2
,@CustomDriverPayFlatRate3
,@CustomDriverPayPercentage
,@CustomDriverPayPercentage2
,@CustomDriverPayPercentage3
,@CustomDriverPayOption
,@CustomDriverPayOption2
,@CustomDriverPayOption3
,@CarrierContactID
,@CarrierPhoneNo
,@CarrierPhoneNoExt
,@CarrierFax
,@CarrierFaxExt
,@CarrierTollFree
,@CarrierTollFreeExt
,@CarrierCell
,@CarrierCellExt
,@CarrierEmailID2
,@CarrierContactID2
,@CarrierPhoneNo2
,@CarrierPhoneNoExt2
,@CarrierFax2
,@CarrierFaxExt2
,@CarrierTollFree2
,@CarrierTollFreeExt2
,@CarrierCell2
,@CarrierCellExt2
,@CarrierEmailID3
,@CarrierContactID3
,@CarrierPhoneNo3
,@CarrierPhoneNoExt3
,@CarrierFax3
,@CarrierFaxExt3
,@CarrierTollFree3
,@CarrierTollFreeExt3
,@CarrierCell3
,@CarrierCellExt3
,@EquipmentTrailer
)
Select @Shipper as lastStopID 
end



GO

GO

/****** Object:  StoredProcedure [dbo].[USP_UpdateLoadStop]    Script Date: 08-04-2022 12:23:56 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER                     proc [dbo].[USP_UpdateLoadStop]
(
@loadid varchar(200),
@isoriginpickup VARCHAR(10),
@isfinaldelivery VARCHAR(10),
@bookedwith VARCHAR(100),
@equipment varchar(200) = null,
@driver VARCHAR(100),
@drivercell VARCHAR(50),
@trucknumber VARCHAR(50),
@trailernumber VARCHAR(50),
@refnumber VARCHAR(100),
@miles float,
@carrierid varchar(200) = null,
@carrierOfficeID varchar(200) = null,
@PickupNO nvarchar(50),
@stopDate datetime=null,
@stopTime nvarchar(50),
@TimeIn nvarchar(50),
@TimeOut nvarchar(50),
@ModifyBy nvarchar(40),
@customerID varchar(200)=null,
@Blind nvarchar(200),
@instructions nvarchar(500),
@directions nvarchar(500),
@loadType integer,
@stopNo integer,
@address nvarchar(200)=null,
@city nvarchar(50)=null,
@state nvarchar(50)=null,
@postalCode nvarchar(50)=null,
@contact nvarchar(100)=null,
@phone nvarchar(30)=null,
@phoneExt nvarchar(30)=null,
@fax nvarchar(30)=null,
@email nvarchar(100)=null,
@customerName nvarchar(100),
@userDef1 varchar(200)=null,
@userDef2 varchar(200)=null,
@userDef3 varchar(200)=null,
@userDef4 varchar(200)=null,
@userDef5 varchar(200)=null,
@userDef6 varchar(200)=null,
@NewStopNo integer,
@stopdateDifference integer,
@driver2 VARCHAR(100),
@NewDriverCell2 VARCHAR(15)
,@temperature varchar(150)
,@temperaturescale VARCHAR(5)
,@TimeZone as varchar(25)
,@CarrierEmailID as VARCHAR(150)
,@MultipleDates as VARCHAR(250)
,@CompanyID VARCHAR(60)
,@NewCarrierID2 varchar(60)
,@NewCarrierID3 varchar(60)
,@NewDriverCell3 varchar(15)
,@CustomDriverPayFlatRate float = 0
,@CustomDriverPayFlatRate2 float = 0
,@CustomDriverPayFlatRate3 float = 0
,@CustomDriverPayPercentage float = 0
,@CustomDriverPayPercentage2 float = 0
,@CustomDriverPayPercentage3 float = 0
,@CustomDriverPayOption int = 0
,@CustomDriverPayOption2 int = 0
,@CustomDriverPayOption3 int = 0
,@CarrierContactID varchar(36)
,@CarrierPhoneNo varchar(50)
,@CarrierPhoneNoExt varchar(50)
,@CarrierFax varchar(50)
,@CarrierFaxExt varchar(50)
,@CarrierTollFree varchar(50)
,@CarrierTollFreeExt varchar(50)
,@CarrierCell varchar(50)
,@CarrierCellExt varchar(50)
,@CarrierEmailID2 as VARCHAR(150)
,@CarrierContactID2 varchar(36)
,@CarrierPhoneNo2 varchar(50)
,@CarrierPhoneNoExt2 varchar(50)
,@CarrierFax2 varchar(50)
,@CarrierFaxExt2 varchar(50)
,@CarrierTollFree2 varchar(50)
,@CarrierTollFreeExt2 varchar(50)
,@CarrierCell2 varchar(50)
,@CarrierCellExt2 varchar(50)
,@CarrierEmailID3 as VARCHAR(150)
,@CarrierContactID3 varchar(36)
,@CarrierPhoneNo3 varchar(50)
,@CarrierPhoneNoExt3 varchar(50)
,@CarrierFax3 varchar(50)
,@CarrierFaxExt3 varchar(50)
,@CarrierTollFree3 varchar(50)
,@CarrierTollFreeExt3 varchar(50)
,@CarrierCell3 varchar(50)
,@CarrierCellExt3 varchar(50)
,@EquipmentTrailer varchar(36)
)
as
begin

Declare @ckLoad integer,@ckCarrier integer;

if ltrim(Rtrim(IsNull(@carrierID, ''))) = ''
		set @carrierID = null

if ltrim(Rtrim(IsNull(@carrierOfficeID, ''))) = ''
		set @carrierOfficeID = null

if ltrim(Rtrim(IsNull(@equipment, ''))) = ''
		set @equipment = null

if ltrim(Rtrim(IsNull(@carrierOfficeID, ''))) = 'Null'
		set @carrierOfficeID = null

SET @ckLoad = (SELECT COUNT(L.LoadID) FROM Loads L
			INNER JOIN CustomerOffices CO ON CO.CustomerID = L.CustomerID
			INNER JOIN Offices O ON O.OfficeID = CO.OfficeID
			WHERE O.CompanyID = @CompanyID AND L.LoadID = @loadid)
SET @ckCarrier = 1;
IF (@carrierID IS NOT NULL)
BEGIN
	SET @ckCarrier = (SELECT COUNT(CarrierID) FROM Carriers WHERE CompanyID = @CompanyID AND CarrierID = @carrierid)
END

--select top 1 @StateID =  stateid from States where StateCode =@State 

BEGIN
IF(Select count(LoadStopID) FROM LoadStops WHERE LoadStops.LoadID = @loadid AND LoadStops.StopNo = @NewStopNo AND LoadStops.LoadType = @loadType) = 0
	BEGIN
		INSERT INTO LoadStops 
		(loadid
		,loadstopid
		,LoadType
		,ReleaseNo
		,Blind 
		,StopDate 
		,StopTime 
		,TimeIn 
		,TimeOut
		,Instructions
		,Directions
		,CustomerID
		,CreatedBy
		,CreatedDateTime
		,ModifiedBy
		,LastModifiedDate
		,isoriginpickup
		,IsFinalDelivery
		,newBookedwith
		,NewEquipmentID
		,NewDriverName
		,NewDriverName2
		,NewDriverCell
		,NewTruckNo
		,NewTrailorNo
		,RefNo
		,Miles
		,NewCarrierID
		,NewOfficeID
		,Address
		,City	
		,StateCode
		,PostalCode
		,ContactPerson
		,Phone
		,PhoneExt 
		,Fax
		,EmailID
		,CustName
		,userDef1
		,userDef2
		,userDef3
		,userDef4
		,userDef5
		,userDef6
		,StopNo
		,stopdateDifference
		,NewDriverCell2
		,temperature
		,temperaturescale
		,timezone
		,CarrierEmailID
		,MultipleDates
		,NewCarrierID2
		,NewCarrierID3
		,NewDriverCell3
		,CustomDriverPayFlatRate
		,CustomDriverPayFlatRate2
		,CustomDriverPayFlatRate3
		,CustomDriverPayPercentage
		,CustomDriverPayPercentage2
		,CustomDriverPayPercentage3
		,CustomDriverPayOption
		,CustomDriverPayOption2
		,CustomDriverPayOption3
		,CarrierContactID
		,CarrierPhoneNo
		,CarrierPhoneNoExt
		,CarrierFax
		,CarrierFaxExt
		,CarrierTollFree
		,CarrierTollFreeExt
		,CarrierCell
		,CarrierCellExt
		,CarrierEmailID2
		,CarrierContactID2
		,CarrierPhoneNo2
		,CarrierPhoneNoExt2
		,CarrierFax2
		,CarrierFaxExt2
		,CarrierTollFree2
		,CarrierTollFreeExt2
		,CarrierCell2
		,CarrierCellExt2
		,CarrierEmailID3
		,CarrierContactID3
		,CarrierPhoneNo3
		,CarrierPhoneNoExt3
		,CarrierFax3
		,CarrierFaxExt3
		,CarrierTollFree3
		,CarrierTollFreeExt3
		,CarrierCell3
		,CarrierCellExt3
		,EquipmentTrailer)
		VALUES(@loadid,NewID(),@loadType,
		@PickupNO
		,@Blind
		,@stopDate
		,@stopTime
		,@TimeIn
		,@TimeOut
		,@instructions
		,@directions
		,@customerID
		,@ModifyBy
		,GETDATE()
		,@ModifyBy
		,GETDATE()
		,@isoriginpickup
		,@isfinaldelivery
		,@bookedwith
		,@equipment
		,@driver
		,@driver2
		,@drivercell
		,@trucknumber
		,@trailernumber
		,@refnumber
		,@miles
		,(CASE WHEN (@ckLoad <> 0 AND @ckCarrier <>0) THEN @carrierid ELSE NULL END)
		,@carrierOfficeID
		,@address	
		,@city	
		,@state
		,@postalCode	
		,@contact
		,@phone
		,@phoneExt
		,@fax
		,@email
		,@customerName
		,@userDef1
		,@userDef2
		,@userDef3
		,@userDef4
		,@userDef5
		,@userDef6
		,@NewStopNo
		,@stopdateDifference
		,@NewDriverCell2
		,@temperature
		,@temperaturescale
		,@timezone
		,@CarrierEmailID
		,@MultipleDates
		,@NewCarrierID2
		,@NewCarrierID3
		,@NewDriverCell3
		,@CustomDriverPayFlatRate
		,@CustomDriverPayFlatRate2
		,@CustomDriverPayFlatRate3
		,@CustomDriverPayPercentage
		,@CustomDriverPayPercentage2
		,@CustomDriverPayPercentage3
		,@CustomDriverPayOption
		,@CustomDriverPayOption2
		,@CustomDriverPayOption3
		,@CarrierContactID
		,@CarrierPhoneNo
		,@CarrierPhoneNoExt
		,@CarrierFax
		,@CarrierFaxExt
		,@CarrierTollFree
		,@CarrierTollFreeExt
		,@CarrierCell
		,@CarrierCellExt
		,@CarrierEmailID2
		,@CarrierContactID2
		,@CarrierPhoneNo2
		,@CarrierPhoneNoExt2
		,@CarrierFax2
		,@CarrierFaxExt2
		,@CarrierTollFree2
		,@CarrierTollFreeExt2
		,@CarrierCell2
		,@CarrierCellExt2
		,@CarrierEmailID3
		,@CarrierContactID3
		,@CarrierPhoneNo3
		,@CarrierPhoneNoExt3
		,@CarrierFax3
		,@CarrierFaxExt3
		,@CarrierTollFree3
		,@CarrierTollFreeExt3
		,@CarrierCell3
		,@CarrierCellExt3
		,@EquipmentTrailer)
	END
ELSE
	BEGIN
		UPDATE [dbo].[LoadStops]
		SET ReleaseNo = @PickupNO
		,Blind = @Blind
		,StopDate = @stopDate
		,StopTime = @stopTime
		,TimeIn = @TimeIn
		,TimeOut = @TimeOut
		,Instructions = @instructions
		,Directions = @directions
		,CustomerID = @customerID
		,ModifiedBy = @ModifyBy
		,LastModifiedDate = GETDATE()
		,isoriginpickup = @isoriginpickup
		,IsFinalDelivery = @isfinaldelivery
		,newBookedwith = @bookedwith
		,NewEquipmentID = @equipment
		,NewDriverName = @driver
		,NewDriverName2 = @driver2
		,NewDriverCell = @drivercell
		,NewTruckNo = @trucknumber
		,NewTrailorNo = @trailernumber
		,RefNo = @refnumber
		,Miles = @miles
		,NewCarrierID = (CASE WHEN (@ckLoad <> 0 AND @ckCarrier <>0) THEN @carrierid ELSE NULL END)
		,NewOfficeID = @carrierOfficeID
		,Address = @address	
		,City =@city	
		,StateCode =@state
		,PostalCode =@postalCode	
		,ContactPerson =@contact
		,Phone =@phone
		,PhoneExt =@phoneExt
		,Fax =@fax
		,EmailID=@email
		,CustName =@customerName
		,userDef1 =@userDef1
		,userDef2 =@userDef2
		,userDef3 =@userDef3
		,userDef4 =@userDef4
		,userDef5 =@userDef5
		,userDef6 =@userDef6
		,StopNo =@NewStopNo
		,stopdateDifference=@stopdateDifference
		,NewDriverCell2=@NewDriverCell2
		,temperature = @temperature
		,temperaturescale = @temperaturescale
		,timezone=@timezone
		,CarrierEmailID=@CarrierEmailID
		,MultipleDates=@MultipleDates
		,NewCarrierID2=@NewCarrierID2
		,NewCarrierID3=@NewCarrierID3
		,NewDriverCell3=@NewDriverCell3
		,CustomDriverPayFlatRate=@CustomDriverPayFlatRate
		,CustomDriverPayFlatRate2=@CustomDriverPayFlatRate2
		,CustomDriverPayFlatRate3=@CustomDriverPayFlatRate3
		,CustomDriverPayPercentage=@CustomDriverPayPercentage
		,CustomDriverPayPercentage2=@CustomDriverPayPercentage2
		,CustomDriverPayPercentage3=@CustomDriverPayPercentage3
		,CustomDriverPayOption=@CustomDriverPayOption
		,CustomDriverPayOption2=@CustomDriverPayOption2
		,CustomDriverPayOption3=@CustomDriverPayOption3
		,CarrierContactID=@CarrierContactID
		,CarrierPhoneNo=@CarrierPhoneNo
		,CarrierPhoneNoExt=@CarrierPhoneNoExt
		,CarrierFax=@CarrierFax
		,CarrierFaxExt=@CarrierFaxExt
		,CarrierTollFree=@CarrierTollFree
		,CarrierTollFreeExt=@CarrierTollFreeExt
		,CarrierCell=@CarrierCell
		,CarrierCellExt=@CarrierCellExt
		,CarrierEmailID2=@CarrierEmailID2
		,CarrierContactID2=@CarrierContactID2
		,CarrierPhoneNo2=@CarrierPhoneNo2
		,CarrierPhoneNoExt2=@CarrierPhoneNoExt2
		,CarrierFax2=@CarrierFax2
		,CarrierFaxExt2=@CarrierFaxExt2
		,CarrierTollFree2=@CarrierTollFree2
		,CarrierTollFreeExt2=@CarrierTollFreeExt2
		,CarrierCell2=@CarrierCell2
		,CarrierCellExt2=@CarrierCellExt2
		,CarrierEmailID3=@CarrierEmailID3
		,CarrierContactID3=@CarrierContactID3
		,CarrierPhoneNo3=@CarrierPhoneNo3
		,CarrierPhoneNoExt3=@CarrierPhoneNoExt3
		,CarrierFax3=@CarrierFax3
		,CarrierFaxExt3=@CarrierFaxExt3
		,CarrierTollFree3=@CarrierTollFree3
		,CarrierTollFreeExt3=@CarrierTollFreeExt3
		,CarrierCell3=@CarrierCell3
		,CarrierCellExt3=@CarrierCellExt3
		,EquipmentTrailer=@EquipmentTrailer
		WHERE LoadStops.LoadID = @loadid
		AND LoadStops.StopNo = @stopNo
		AND LoadStops.LoadType = @loadType
	END
Select LoadStopID as lastStopID 
FROM LoadStops
WHERE LoadStops.LoadID = @loadid
AND LoadStops.StopNo = @NewStopNo
AND LoadStops.LoadType = @loadType

END

END
GO


GO

/****** Object:  StoredProcedure [dbo].[USP_GetLoadDetails]    Script Date: 08-04-2022 12:30:44 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



ALTER                         PROC [dbo].[USP_GetLoadDetails]

(

@LoadID VARCHAR(200),

@StopNo int,
@CompanyID VARCHAR(50)
)

AS

BEGIN

	IF ltrim(Rtrim(IsNull(@StopNo, ''))) = ''
	BEGIN
		SET @StopNo = 0
	END

	IF(LEN(@LoadID)<>0)
	BEGIN
		SELECT 
			l.Loadid,l.LoadNumber,l.IsPartial,l.CarrierID AS CarrierID,
			ISNULL(l.CustomerRatePerMile,0) AS CustomerRatePerMile,
			ISNULL(l.CarrierRatePerMile,0) AS CarrierRatePerMile,
			ISNULL(l.TotalMiles,0) AS CustomerTotalMiles,
			ISNULL(l.TotalMiles,0) AS CarrierTotalMiles,
			ISNULL(l.ARExported,'0') AS ARExportedNN,
			ISNULL(l.APExported,'0') AS APExportedNN,
			ISNULL(l.orderDate, '') AS orderDate,
			ISNULL(l.BillDate, '') AS BillDate,
			ISNULL(l.customerMilesCharges, 0) AS customerMilesCharges,
			ISNULL(l.carrierMilesCharges, 0) AS carrierMilesCharges,
			ISNULL(l.customerCommoditiesCharges, 0) AS customerCommoditiesCharges,
			ISNULL(l.carrierCommoditiesCharges, 0) AS carrierCommoditiesCharges,
			ISNULL(l.CustFlatRate, 0) AS CustFlatRate,
			ISNULL(l.carrFlatRate, 0) AS carrFlatRate,
			l.ModifiedBy,
			l.LastModifiedDate,
			l.EquipmentID,
			l.RefNo,
			l.readyDate,
			l.arriveDate,
			l.isExcused,
			l.bookedBy,
			l.DeadHeadMiles,
			ISNULL(l.posttoITS,0) AS posttoITS,
			postCarrierRatetoITS,
			postCarrierRatetoloadboard,
			postCarrierRatetoTranscore,
			postCarrierRateto123LoadBoard,
			shipperStopDate,
			consigneeStopDate,
			shipperStopTime,
			consigneeStopTime,
			shipperStopTimeIn,
			consigneeStopTimeIn,
			shipperStopTimeOut,
			consigneeStopTimeOut,
			CustomerPONo,
			BOLNum,
			StatusTypeID,
			PricingNotes,
			statusText,
			colorCode,
			L.CustomerID AS PayerID,
			TotalCustomerCharges,
			stops.shipperState,
			stops.shipperCity,
			stops.consigneeState,
			stops.consigneeCity,
			carr.CarrierName,
			Iscarrier,
			CustomerName,
			LoadStopID,
			StopNo,
			[NewPickupDate] as PickupDate,
			[NewPickupTime] as PickupTime,
			[NewDeliveryDate] as DeliveryDate,
			[NewDeliveryTime] as DeliveryTime,
			NewOfficeID,
			NewNotes,
			isPost,
			IsTransCorePst,
			TotalCarrierCharges,
			TotalCustomerCharges,
			NewCarrierID,
			NewCarrierID2,
			NewCarrierID3,
			carrierNotes,
			NewDispatchNotes,
			DispatcherID,
			SalesRepID,
			shipperStopName,
			consigneeStopName,
			shipperLocation,
			consigneeLocation,
			shipperPostalCode,
			consigneePostalCode,
			shipperContactPerson,
			consigneeContactPerson,
			shipperPhone,
			consigneePhone,
			shipperPhoneExt,
			consigneePhoneExt,
			shipperFax,
			consigneeFax,
			shipperEmailID,
			consigneeEmailID,
			shipperReleaseNo,
			consigneeReleaseNo,
			shipperBlind,
			consigneeBlind,
			shipperInstructions,
			consigneeInstructions,
			shipperDirections,
			consigneeDirections,
			shipperLoadStopID,
			consigneeLoadStopID,
			shipperBookedWith,
			consigneeBookedWith,
			shipperEquipmentID,
			consigneeEquipmentID,
			shipperDriverName,
			consigneeDriverName,
			consigneeDriverName2,
			shipperDriverCell,
			consigneeDriverCell,
			shipperTruckNo,
			consigneeTruckNo,
			shipperTrailorNo,
			consigneeTrailorNo,
			shipperRefNo,
			consigneeRefNo,
			shipperMiles,
			consigneeMiles,
			shipperCustomerID,
			consigneeCustomerID
			consigneeCustomerID,EmergencyResponseNo,CODAmt,CODFee,DeclaredValue,postto123loadboard,Notes,invoiceNumber,weight,userDefinedFieldTrucking,CarrierInvoiceNumber
			, emailList, shipperDriverCell2, consigneeDriverCell2, l.CustomerCurrency, l.CarrierCurrency, l.InternalRef
			,l.noOfTrips,l.tripText
			,l.BOLFromName,l.BOLFromTel,l.BOLFromEmail,l.BOLREName,l.BOLREPO
			,temperature
			,temperaturescale
			,l.ediInvoiced
			,l.EDISCAC
			,l.FF
			,l.PODSignature
			,l.MacroPointOrderID
			,l.LoadStatusStopNo
			,l.posttoDirectFreight
			,l.postCarrierRatetoDirectFreight
			,l.PushDataToProject44Api
			,shipperTimeZone
			,consigneeTimeZone
			,l.EquipmentLength
			,SalesRep1
			,SalesRep2
			,SalesRep3
			,SalesRep1Percentage
			,SalesRep2Percentage
			,SalesRep3Percentage
			,l.TotalDirectCost
			,l.EquipmentWidth
			,shipperDriverCell3
			,consigneeDriverCell3
			,l.ContactEmail
			,l.CustomDriverPay,
			CustomDriverPayFlatRate,
			CustomDriverPayFlatRate2,
			CustomDriverPayFlatRate3,
			CustomDriverPayPercentage,
			CustomDriverPayPercentage2,
			CustomDriverPayPercentage3,
			stops.CustomDriverPayOption,
			stops.CustomDriverPayOption2,
			stops.CustomDriverPayOption3,
			CriticalNotes,
			l.IsEDispatched,
			ShowStopOnLoadStatus,
			Reports AS CustomerReportButton
			,EquipmentTrailer
			,L.RateApprovalNeeded
			,L.MarginApproved
			,L.LastApprovedRate
			,(select count(distinct ls1.NewCarrierID) from loadstops ls1 where ls1.loadid = L.loadid) AS CarrierCount
			,L.Dispatcher1
			,L.Dispatcher2
			,L.Dispatcher3
			,L.Dispatcher1Percentage
			,L.Dispatcher2Percentage
			,L.Dispatcher3Percentage
			,LateStop
			,L.BillFromCompany
			,L.CustomerPaid
			,L.CarrierPaid
		FROM LOADS l
		LEFT OUTER JOIN (SELECT 
							a.LoadID,
							a.LoadStopID,a.StopNo,
							a.NewCarrierID,
							a.NewCarrierID2,
							a.NewCarrierID3,
							a.NewOfficeID,
							a.City AS shipperCity,
							b.City AS consigneeCity,
							a.custName AS shipperStopName,
							b.custName AS consigneeStopName,
							a.Address AS shipperLocation,
							b.Address AS consigneeLocation,
							a.PostalCode AS shipperPostalCode,
							b.PostalCode AS consigneePostalCode,
							a.ContactPerson AS shipperContactPerson,
							b.ContactPerson AS consigneeContactPerson,
							a.Phone AS shipperPhone,
							b.Phone AS consigneePhone,
							a.PhoneExt AS shipperPhoneExt,
							b.PhoneExt AS consigneePhoneExt,
							a.fax AS shipperFax,
							b.fax AS consigneeFax,
							a.EmailID AS shipperEmailID,
							b.EmailID AS consigneeEmailID,
							a.StopDate AS shipperStopDate,
							b.StopDate AS consigneeStopDate,
							a.StopTime AS shipperStopTime,
							b.StopTime AS consigneeStopTime,
							a.TimeIn AS shipperStopTimeIn,
							b.TimeIn AS consigneeStopTimeIn,
							a.TimeOut AS shipperStopTimeOut,
							b.TimeOut AS consigneeStopTimeOut,
							a.ReleaseNo AS shipperReleaseNo,
							b.ReleaseNo AS consigneeReleaseNo,
							a.Blind AS shipperBlind,
							b.Blind AS consigneeBlind,
							a.Instructions AS shipperInstructions,
							b.Instructions AS consigneeInstructions,
							a.Directions AS shipperDirections,
							b.Directions AS consigneeDirections,
							a.LoadStopID AS shipperLoadStopID,
							b.LoadStopID AS consigneeLoadStopID,
							a.NewBookedWith AS shipperBookedWith,
							b.NewBookedWith AS consigneeBookedWith,
							a.NewEquipmentID AS shipperEquipmentID,
							b.NewEquipmentID AS consigneeEquipmentID,
							a.NewDriverName AS shipperDriverName,
							b.NewDriverName AS consigneeDriverName,
							b.NewDriverName2 AS consigneeDriverName2,
							a.NewDriverCell AS shipperDriverCell,
							b.NewDriverCell AS consigneeDriverCell,
							a.NewTruckNo AS shipperTruckNo,
							b.NewTruckNo AS consigneeTruckNo,
							a.NewTrailorNo AS shipperTrailorNo,
							b.NewTrailorNo AS consigneeTrailorNo,
							a.RefNo AS shipperRefNo,
							b.RefNo AS consigneeRefNo,
							a.Miles AS shipperMiles,
							b.Miles AS consigneeMiles,
							a.CustomerID AS shipperCustomerID,
							b.CustomerID AS consigneeCustomerID,
							a.StateCode as shipperState,
							b.StateCode as consigneeState, 
							a.NewDriverCell2 AS shipperDriverCell2,
							b.NewDriverCell2 AS consigneeDriverCell2,
							b.temperature,
							b.temperaturescale,
							a.timeZone as shipperTimeZone,
							b.timeZone as consigneeTimeZone,
							a.NewDriverCell3 AS shipperDriverCell3,
							b.NewDriverCell3 AS consigneeDriverCell3,
							a.CustomDriverPayFlatRate,
							a.CustomDriverPayFlatRate2,
							a.CustomDriverPayFlatRate3,
							a.CustomDriverPayPercentage,
							a.CustomDriverPayPercentage2,
							a.CustomDriverPayPercentage3,
							a.CustomDriverPayOption,
							a.CustomDriverPayOption2,
							a.CustomDriverPayOption3
							,a.EquipmentTrailer
							,a.latestop
						FROM LoadStops a 
						JOIN LoadStops b on a.LoadID = b.LoadID AND a.StopNo = b.StopNo
						WHERE a.LoadID = @LoadID AND a.LoadType = 1 AND b.LoadType = 2 AND a.StopNo =@StopNo AND b.StopNo =@StopNo) as stops  on stops.loadid = l.loadid
		left outer join (SELECT [CarrierID],[CarrierName], Iscarrier FROM [Carriers] WHERE CompanyID = @CompanyID) as carr on carr.CarrierID = stops.NewCarrierID
		left outer join (SELECT [CarrierOfficeID],[Manager]  FROM [CarrierOffices]) as office on office.CarrierOfficeID = stops.NewOfficeID
		left outer join (SELECT [StatusTypeID] as stTypeId,[statusText],[colorCode],[ShowStopOnLoadStatus],[Reports] FROM [loadStatusTypes]) as loadStatus on loadStatus.stTypeId = l.StatusTypeID

		left outer join (SELECT [CustomerName],[CustomerID] FROM [Customers]) as cust on cust.CustomerID = l.CustomerID
		left outer join (SELECT [CustomerID],[OfficeID] FROM [CustomerOffices]) as custOffices on custOffices.CustomerID = cust.CustomerID
		left outer join (SELECT [OfficeID],[CompanyID] FROM [Offices]) as O on O.OfficeID = custOffices.OfficeID


		left outer join (SELECT [StatusTypeID] as lststType,[StatusText] as lStatusText FROM [LoadStatusTypes]) as LStatusTypes on LStatusTypes.lststType = l.StatusTypeID
		WHERE l.LoadID = @LoadID AND O.CompanyID = @CompanyID
		ORDER BY loadStatus.statusText
	END
	ELSE
	BEGIN
		SELECT 
			l.Loadid,l.LoadNumber,l.IsPartial,l.CarrierID AS CarrierID,
			ISNULL(l.CustomerRatePerMile,0) AS CustomerRatePerMile,
			ISNULL(l.CarrierRatePerMile,0) AS CarrierRatePerMile,
			ISNULL(l.TotalMiles,0) AS CustomerTotalMiles,
			ISNULL(l.TotalMiles,0) AS CarrierTotalMiles,
			ISNULL(l.ARExported,'0') AS ARExportedNN,
			ISNULL(l.APExported,'0') AS APExportedNN,
			ISNULL(l.orderDate, '') AS orderDate,
			ISNULL(l.BillDate, '') AS BillDate,
			ISNULL(l.customerMilesCharges, 0) AS customerMilesCharges,
			ISNULL(l.carrierMilesCharges, 0) AS carrierMilesCharges,
			ISNULL(l.customerCommoditiesCharges, 0) AS customerCommoditiesCharges,
			ISNULL(l.carrierCommoditiesCharges, 0) AS carrierCommoditiesCharges,
			ISNULL(l.CustFlatRate, 0) AS CustFlatRate,
			ISNULL(l.carrFlatRate, 0) AS carrFlatRate,
			l.ModifiedBy,
			l.LastModifiedDate,
			l.EquipmentID,
			l.RefNo,
			l.readyDate,
			l.arriveDate,
			l.isExcused,
			l.bookedBy,
			l.DeadHeadMiles,
			ISNULL(l.posttoITS,0) AS posttoITS,
			postCarrierRatetoITS,
			postCarrierRatetoloadboard,
			postCarrierRatetoTranscore,
			postCarrierRateto123LoadBoard,
			shipperStopDate,
			consigneeStopDate,
			shipperStopTime,
			consigneeStopTime,
			shipperStopTimeIn,
			consigneeStopTimeIn,
			shipperStopTimeOut,
			consigneeStopTimeOut,
			CustomerPONo,
			BOLNum,
			StatusTypeID,
			PricingNotes,
			statusText,
			colorCode,
			L.CustomerID AS PayerID,
			TotalCustomerCharges,
			stops.shipperState,
			stops.shipperCity,
			stops.consigneeState,
			stops.consigneeCity,
			carr.CarrierName,
			Iscarrier,
			CustomerName,
			LoadStopID,
			StopNo,
			[NewPickupDate] as PickupDate,
			[NewPickupTime] as PickupTime,
			[NewDeliveryDate] as DeliveryDate,
			[NewDeliveryTime] as DeliveryTime,
			NewOfficeID,
			NewNotes,
			isPost,
			IsTransCorePst,
			TotalCarrierCharges,
			TotalCustomerCharges,
			NewCarrierID,
			NewCarrierID2,
			NewCarrierID3,
			carrierNotes,
			NewDispatchNotes,
			DispatcherID,
			SalesRepID,
			shipperStopName,
			consigneeStopName,
			shipperLocation,
			consigneeLocation,
			shipperPostalCode,
			consigneePostalCode,
			shipperContactPerson,
			consigneeContactPerson,
			shipperPhone,
			consigneePhone,
			shipperFax,
			consigneeFax,
			shipperEmailID,
			consigneeEmailID,
			shipperReleaseNo,
			consigneeReleaseNo,
			shipperBlind,
			consigneeBlind,
			shipperInstructions,
			consigneeInstructions,
			shipperDirections,
			consigneeDirections,
			shipperLoadStopID,
			consigneeLoadStopID,
			shipperBookedWith,
			consigneeBookedWith,
			shipperEquipmentID,
			consigneeEquipmentID,
			shipperDriverName,
			consigneeDriverName,
			consigneeDriverName2,
			shipperDriverCell,
			consigneeDriverCell,
			shipperTruckNo,
			consigneeTruckNo,
			shipperTrailorNo,
			consigneeTrailorNo,
			shipperRefNo,
			consigneeRefNo,
			shipperMiles,
			consigneeMiles,
			shipperCustomerID,
			consigneeCustomerID
			consigneeCustomerID,EmergencyResponseNo,CODAmt,CODFee,DeclaredValue,postto123loadboard,Notes,invoiceNumber,weight,userDefinedFieldTrucking,CarrierInvoiceNumber
			, emailList, shipperDriverCell2, consigneeDriverCell2, l.CustomerCurrency, l.CarrierCurrency, l.InternalRef
			,l.noOfTrips,l.tripText
			,l.BOLFromName,l.BOLFromTel,l.BOLFromEmail,l.BOLREName,l.BOLREPO
			,temperature
			,temperaturescale
			,l.ediInvoiced
			,l.EDISCAC
			,l.FF
			,l.PODSignature
			,l.MacroPointOrderID
			,l.LoadStatusStopNo
			,l.posttoDirectFreight
			,l.postCarrierRatetoDirectFreight
			,l.PushDataToProject44Api
			,shipperTimeZone
			,consigneeTimeZone
			,l.EquipmentLength
			,SalesRep1
			,SalesRep2
			,SalesRep3
			,SalesRep1Percentage
			,SalesRep2Percentage
			,SalesRep3Percentage
			,l.TotalDirectCost
			,l.EquipmentWidth, shipperDriverCell3, consigneeDriverCell3,CriticalNotes 
			,EquipmentTrailer
		FROM LOADS l
		LEFT OUTER JOIN (SELECT 
							a.LoadID,
							a.LoadStopID,a.StopNo,
							a.NewCarrierID,
							a.NewCarrierID2,
							a.NewCarrierID3,
							a.NewOfficeID,
							a.City AS shipperCity,
							b.City AS consigneeCity,
							a.custName AS shipperStopName,
							b.custName AS consigneeStopName,
							a.Address AS shipperLocation,
							b.Address AS consigneeLocation,
							a.PostalCode AS shipperPostalCode,
							b.PostalCode AS consigneePostalCode,
							a.ContactPerson AS shipperContactPerson,
							b.ContactPerson AS consigneeContactPerson,
							a.Phone AS shipperPhone,
							b.Phone AS consigneePhone,
							a.fax AS shipperFax,
							b.fax AS consigneeFax,
							a.EmailID AS shipperEmailID,
							b.EmailID AS consigneeEmailID,
							a.StopDate AS shipperStopDate,
							b.StopDate AS consigneeStopDate,
							a.StopTime AS shipperStopTime,
							b.StopTime AS consigneeStopTime,
							a.TimeIn AS shipperStopTimeIn,
							b.TimeIn AS consigneeStopTimeIn,
							a.TimeOut AS shipperStopTimeOut,
							b.TimeOut AS consigneeStopTimeOut,
							a.ReleaseNo AS shipperReleaseNo,
							b.ReleaseNo AS consigneeReleaseNo,
							a.Blind AS shipperBlind,
							b.Blind AS consigneeBlind,
							a.Instructions AS shipperInstructions,
							b.Instructions AS consigneeInstructions,
							a.Directions AS shipperDirections,
							b.Directions AS consigneeDirections,
							a.LoadStopID AS shipperLoadStopID,
							b.LoadStopID AS consigneeLoadStopID,
							a.NewBookedWith AS shipperBookedWith,
							b.NewBookedWith AS consigneeBookedWith,
							a.NewEquipmentID AS shipperEquipmentID,
							b.NewEquipmentID AS consigneeEquipmentID,
							a.EquipmentTrailer,
							a.NewDriverName AS shipperDriverName,
							b.NewDriverName AS consigneeDriverName,
							b.NewDriverName2 AS consigneeDriverName2,
							a.NewDriverCell AS shipperDriverCell,
							b.NewDriverCell AS consigneeDriverCell,
							a.NewTruckNo AS shipperTruckNo,
							b.NewTruckNo AS consigneeTruckNo,
							a.NewTrailorNo AS shipperTrailorNo,
							b.NewTrailorNo AS consigneeTrailorNo,
							a.RefNo AS shipperRefNo,
							b.RefNo AS consigneeRefNo,
							a.Miles AS shipperMiles,
							b.Miles AS consigneeMiles,
							a.CustomerID AS shipperCustomerID,
							b.CustomerID AS consigneeCustomerID,
							a.StateCode as shipperState,
							b.StateCode as consigneeState, 
							a.NewDriverCell2 AS shipperDriverCell2,
							b.NewDriverCell2 AS consigneeDriverCell2,
							a.NewDriverCell3 AS shipperDriverCell3,
							b.NewDriverCell3 AS consigneeDriverCell3,
							b.temperature,
							b.temperaturescale,
							a.timeZone as shipperTimeZone,
							b.timeZone as consigneeTimeZone
						FROM LoadStops a 
						JOIN LoadStops b on a.LoadID = b.LoadID AND a.StopNo = b.StopNo
						WHERE  a.LoadType = 1 AND b.LoadType = 2 AND a.StopNo =@StopNo AND b.StopNo =@StopNo) as stops  on stops.loadid = l.loadid
		left outer join (SELECT [CarrierID],[CarrierName], Iscarrier FROM [Carriers]  WHERE CompanyID = @CompanyID) as carr on carr.CarrierID = stops.NewCarrierID
		left outer join (SELECT [CarrierOfficeID],[Manager]  FROM [CarrierOffices]) as office on office.CarrierOfficeID = stops.NewOfficeID
		left outer join (SELECT [StatusTypeID] as stTypeId,[statusText], [colorCode] FROM [loadStatusTypes]) as loadStatus on loadStatus.stTypeId = l.StatusTypeID
		left outer join (SELECT [CustomerName],[CustomerID] FROM [Customers] ) as cust on cust.CustomerID = l.CustomerID
		left outer join (SELECT [CustomerID],[OfficeID] FROM [CustomerOffices]) as custOffices on custOffices.CustomerID = cust.CustomerID
		left outer join (SELECT [OfficeID],[CompanyID] FROM [Offices]) as O on O.OfficeID = custOffices.OfficeID
		left outer join (SELECT [StatusTypeID] as lststType,[StatusText] as lStatusText FROM [LoadStatusTypes]) as LStatusTypes on LStatusTypes.lststType = l.StatusTypeID
		WHERE O.CompanyID = @CompanyID
		ORDER BY loadStatus.statusText
	END
END




GO



