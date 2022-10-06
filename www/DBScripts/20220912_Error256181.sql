GO

/****** Object:  StoredProcedure [dbo].[USP_InsertAIImportLoad]    Script Date: 12-09-2022 15:17:21 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER               Procedure [dbo].[USP_InsertAIImportLoad]
(
@CompanyID varchar(36),
@EmpID varchar(36),
@CreatedBy varchar(150),
@CreatedByIP  varchar(50),
@CustomerID varchar(36),
@CustName varchar(250),
@EquipmentName varchar(250),
@EquipmentWidth float,
@EquipmentLength float,
@CustFlatRate float,
@CarrFlatRate float,
@InternalRef varchar(150),
@pickcity nvarchar(50),
@pickstate nvarchar(50),
@delcity nvarchar(50),
@delstate nvarchar(50),
@PickupDate datetime,
@DeliveryDate datetime,
@Qty float,
@Weight float,
@SalesRep varchar(100),
@Dispatcher varchar(100),
@StatusTypeID varchar(36),
@LTL bit,
@Commodity nvarchar(1000),
@NewDispatchNotes varchar(max),
@NewNotes varchar(1000),
@PickupName varchar(100),
@PickupAddress varchar(200),
@PickupContact varchar(100),
@DeliveryName varchar(100),
@DeliveryAddress varchar(200),
@DeliveryContact varchar(100)
)
AS
BEGIN
	DECLARE @LoadNumber int,
			@MinimumLoadStartNumber int,
			@LoadNumberAutoIncrement int,
			@StartingActiveLoadNumber int,
			@LoadCount INT = 0,
			@LoadNumberNew INT,
			@LoadID varchar(36),
			@LoadStopID uniqueidentifier,
			@SalesRepID varchar(36),
			@DispatcherID varchar(36);

	/*Begin : Generate LoadNumber*/
	SET @MinimumLoadStartNumber = (SELECT ISNULL(MinimumLoadStartNumber,0)+1 FROM SystemConfig WHERE CompanyID = @CompanyID);
	SET @LoadNumberAutoIncrement = (SELECT ISNULL(LoadNumberAutoIncrement,0) FROM SystemConfig WHERE CompanyID = @CompanyID);
	SET @StartingActiveLoadNumber = (SELECT ISNULL(StartingActiveLoadNumber,0) FROM SystemConfig WHERE CompanyID = @CompanyID);
	IF(@LoadNumber IS NULL)
	BEGIN
		SET @LoadNumber = @MinimumLoadStartNumber;
	END
	IF(@StartingActiveLoadNumber=0)
	BEGIN
		SET @LoadNumberAutoIncrement = 0;
	END
	SET @LoadCount = (SELECT COUNT(L.LoadID) AS LoadCount FROM Loads L WITH (NOLOCK)
					INNER JOIN CustomerOffices CO ON CO.CustomerID = L.CustomerID
					INNER JOIN Offices O ON O.OfficeID = CO.OfficeID
					WHERE O.CompanyID = @CompanyID AND L.LoadNumber=@LoadNumber)

	IF(@LoadCount <> 0)
	BEGIN
		SET @LoadNumber = (SELECT MAX(LoadNumber)+1 FROM Loads L
					INNER JOIN CustomerOffices CO ON CO.CustomerID = L.CustomerID
					INNER JOIN Offices O ON O.OfficeID = CO.OfficeID
					WHERE O.CompanyID = @CompanyID)

		IF(@LoadNumberAutoIncrement) = 0
		BEGIN
			IF(@MinimumLoadStartNumber > @LoadNumber)
			BEGIN
				SET @LoadNumber = @MinimumLoadStartNumber
			END
		END
		ELSE
		BEGIN
			SET @LoadNumberNew = (SELECT MAX(LoadNumber) FROM Loads L
					INNER JOIN LoadStatusTypes LST ON LST.StatusTypeID = L.StatusTypeID
					INNER JOIN CustomerOffices CO ON CO.CustomerID = L.CustomerID
					INNER JOIN Offices O ON O.OfficeID = CO.OfficeID
					WHERE O.CompanyID = @CompanyID AND LST.StatusText < '2. BOOKED')

			IF(@LoadNumberNew<@StartingActiveLoadNumber)
			BEGIN
				PRINT 1;
				SET @LoadNumber = @LoadNumberNew+1;
			END

			IF(@LoadNumber < @MinimumLoadStartNumber)
			BEGIN
				SET @LoadNumber = @MinimumLoadStartNumber
			END
		END
	END
	/*End : Generate LoadNumber*/
	
	SET @LoadID = newid();

	IF(ltrim(Rtrim(IsNull(@CustomerID, ''))))=''
	BEGIN
		SET @CustomerID = (SELECT TOP 1 CustomerID FROM Customers WHERE CustomerName  =@CustName AND IsPayer = 1 AND CustomerID IN (SELECT CustomerID FROM CustomerOffices WHERE OfficeID IN (SELECT OfficeID FROM Offices WHERE CompanyID =@CompanyID)))	
	END

	IF(ltrim(Rtrim(IsNull(@SalesRep, ''))))=''
	BEGIN
		SET @SalesRepID = (SELECT SalesRepID FROM Customers WHERE CustomerID  =@CustomerID)	
	END
	ELSE
	BEGIN
		SET @SalesRepID = (SELECT EmployeeID FROM Employees WHERE Name = @SalesRep)
	END

	IF(ltrim(Rtrim(IsNull(@Dispatcher, ''))))=''
	BEGIN
		SET @DispatcherID = (SELECT AcctMGRID FROM Customers WHERE CustomerID  =@CustomerID)	
	END
	ELSE
	BEGIN
		SET @DispatcherID = (SELECT E.EmployeeID FROM Employees E INNER JOIN Offices O ON O.OfficeID = E.OfficeID WHERE E.Name = @Dispatcher AND O.CompanyID = @CompanyID)
	END

	INSERT INTO LOADS 
		(LoadID,
		LoadNumber,
		ControlNumber,
		StatusTypeID,
		DispatcherID,
		SalesRepID,
		EquipmentID,
		EquipmentName,
		EquipmentWidth,
		EquipmentLength,
		CustomerID,
		CustName,
		Address,
		City,
		StateCode,
		PostalCode,
		ContactPerson,
		Phone,
		CellNo,
		Fax,
		ContactEmail,
		CreatedDateTime,
		LastModifiedDate,
		CreatedBy,
		ModifiedBy,
		CreatedByIP,
		customerCommoditiesCharges,
		TotalCustomerCharges,
		HasEnrouteStops,
		HasTemp,
		IsPost,
		IsPepUpload,
		IsLocked,
		CustFlatRate,
		TotalCarrierCharges,
		CarrFlatRate,
		TotalMiles,
		customerMilesCharges,
		carrierMilesCharges,
		carrierCommoditiesCharges,
		CarrierRatePerMile,
		CustomerRatePerMile,
		NewPickupDate,
		NewDeliveryDate,
		IsPartial,
		ShipperCity,
		ShipperState,
		ConsigneeCity,
		ConsigneeState,
		NewDispatchNotes,
		NewNotes
		)
	VALUES
		(@LoadID,
		@LoadNumber,
		@LoadNumber,
		@StatusTypeID,
		@DispatcherID,
		@SalesRepID,
		(SELECT TOP 1 EquipmentID FROM Equipments WHERE EquipmentName = @EquipmentName AND CompanyID=@CompanyID AND IsActive = 1),
		@EquipmentName,
		@EquipmentWidth,
		@EquipmentLength,
		@CustomerID,
		@CustName,
		(SELECT Location From Customers WHERE CustomerID = @CustomerID),
		(SELECT City From Customers WHERE CustomerID = @CustomerID),
		(SELECT statecode From Customers WHERE CustomerID = @CustomerID),
		(SELECT ZipCode From Customers WHERE CustomerID = @CustomerID),
		(SELECT ContactPerson From Customers WHERE CustomerID = @CustomerID),
		(SELECT PhoneNo From Customers WHERE CustomerID = @CustomerID),
		(SELECT PersonMobileNo From Customers WHERE CustomerID = @CustomerID),
		(SELECT Fax From Customers WHERE CustomerID = @CustomerID),
		(SELECT Email From Customers WHERE CustomerID = @CustomerID),
		getdate(),
		getdate(),
		@CreatedBy,
		@CreatedBy,
		@CreatedByIP,
		0,
		@CustFlatRate,
		0,
		0,
		0,
		0,
		0,
		@CustFlatRate,
		@CarrFlatRate,
		@CarrFlatRate,
		0,
		0,
		0,
		0,
		0,
		0,
		@PickupDate,
		@DeliveryDate,
		@LTL,
		@pickcity,	
		@pickstate,
		@delcity ,	
		@delstate,
		@NewDispatchNotes,
		@NewNotes
		)
	SET @LoadStopID = NEWID();
	INSERT INTO LoadStops 
	(LoadStopID
	,LoadID
	,StopNo
	,LoadType
	,CreatedBy
	,CreatedDateTime
	,ModifiedBy
	,LastModifiedDate
	,City
	,StateCode
	,isoriginpickup
	,IsFinalDelivery
	,Blind
	,RefNo
	,ReleaseNo
	,StopTime
	,TimeIn
	,TimeOut
	,NewEquipmentID
	,StopDate
	,CustName
	,Address
	,ContactPerson
	)
	VALUES(
	@LoadStopID,
	@LoadID,
	0,
	1,
	@CreatedBy,
	getdate(),
	@CreatedBy,
	getdate(),
	@pickcity ,	
	@pickstate,
	1,
	0,
	0,
	'',
	'',
	'',
	'',
	'',
	(SELECT TOP 1 EquipmentID FROM Equipments WHERE EquipmentName = @EquipmentName AND CompanyID=@CompanyID AND IsActive = 1),
	@PickupDate,
	@PickupName,
	@PickupAddress,
	@PickupContact
	)

	INSERT INTO LoadStops 
	(LoadStopID
	,LoadID
	,StopNo
	,LoadType
	,CreatedBy
	,CreatedDateTime
	,ModifiedBy
	,LastModifiedDate
	,City
	,StateCode
	,isoriginpickup
	,IsFinalDelivery
	,Blind
	,RefNo
	,ReleaseNo
	,StopTime
	,TimeIn
	,TimeOut
	,NewEquipmentID
	,StopDate
	,CustName
	,Address
	,ContactPerson
	)
	VALUES(
	NEWID(),
	@LoadID,
	0,
	2,
	@CreatedBy,
	getdate(),
	@CreatedBy,
	getdate(),
	@delcity ,	
	@delstate ,
	0,
	1,
	0,
	'',
	'',
	'',
	'',
	'',
	(SELECT TOP 1 EquipmentID FROM Equipments WHERE EquipmentName = @EquipmentName AND CompanyID=@CompanyID AND IsActive = 1),
	@DeliveryDate,
	@DeliveryName,
	@DeliveryAddress,
	@DeliveryContact
	)

	INSERT INTO LoadStopCommodities
	(LoadStopID,SrNo,Qty,Fee,Weight,Description)
	VALUES
	(@LoadStopID,1,@Qty,0,@Weight,@Commodity)


	INSERT INTO LoadLogs (LoadID,LoadNumber,FieldLabel,UpdatedByUserID,UpdatedBy,UpdatedTimestamp,UpdatedByIP)
	VALUES(@LoadID,@LoadNumber,'NEW LOAD',@EmpID,@CreatedBy,getdate(),@CreatedByIP)

	SELECT @LoadID AS LoadID,@LoadNumber AS LoadNumber
	
END
GO


