GO

/****** Object:  StoredProcedure [dbo].[USP_UpdateLoad]    Script Date: 02-08-2022 09:45:36 ******/
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
	CarrierPaid=						@CarrierPaid,
	InUseBy=							NULL,
	InUseOn=							NULL,
	sessionId=							NULL
	where LoadID=@loadID
	Update LoadPostEverywhereDetails  set imprtref= @loadManualNo where imprtref=@PrevloadNo
end




GO


