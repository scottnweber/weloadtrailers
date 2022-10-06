GO

/****** Object:  StoredProcedure [dbo].[USP_InsertCustomerLoad]    Script Date: 13-09-2022 11:37:39 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER             Procedure [dbo].[USP_InsertCustomerLoad]
(
@CompanyID varchar(36),
@DispatcherID varchar(36),
@SalesRepID varchar(36),
@EquipmentID varchar(36),
@EquipmentWidth float,
@EquipmentLength float,
@NewNotes varchar(1000),
@CustomerID varchar(36),
@CustName varchar(100),
@Address varchar(200),
@City varchar(50), 
@StateCode varchar(50), 
@PostalCode varchar(50), 
@ContactPerson varchar(100),
@Phone varchar(50),
@CellNo varchar(50),
@Fax varchar(30),
@ContactEmail varchar(150),
@CustomerPONo varchar(50),
@BOLNum varchar(30),
@CreatedBy varchar(150),
@CreatedByIP  varchar(50),
@customerCommoditiesCharges money,
@UpdatedByUserID varchar(36),
@NewPickupDate datetime,
@NewPickupTime nvarchar(50),
@NewDeliveryDate datetime,
@NewDeliveryTime nvarchar(50)
)
AS
BEGIN
	DECLARE @LoadNumber int,
			@MinimumLoadStartNumber int,
			@LoadNumberAutoIncrement int,
			@StartingActiveLoadNumber int,
			@cnt INT = 0,
			@StartingLoadNumber INT = 0,
			@LoadID varchar(36),
			@StatusTypeID varchar(36);

	/*Begin : Generate LoadNumber*/
	SET @LoadNumberAutoIncrement = (SELECT ISNULL(LoadNumberAutoIncrement,0) FROM SystemConfig WHERE CompanyID = @CompanyID)
	SET @StartingActiveLoadNumber = (SELECT StartingActiveLoadNumber FROM SystemConfig WHERE CompanyID = @CompanyID)

	CREATE TABLE #Loads_Temp(LoadNumber INT,StatusText varchar(50))
	INSERT INTO #Loads_Temp SELECT LoadNumber,(SELECT StatusText FROM LoadStatusTypes WHERE LoadStatusTypes.StatusTypeID = Loads.StatusTypeID) FROM Loads WHERE CustomerID IN (SELECT CustomerID FROM CustomerOffices WHERE OfficeID IN (SELECT OfficeID FROM Offices WHERE CompanyID = @CompanyID));


	BEGIN
		SET @MinimumLoadStartNumber = (SELECT ISNULL(MinimumLoadStartNumber,0) FROM SystemConfig WHERE CompanyID = @CompanyID);
		IF(@LoadNumberAutoIncrement) = 0
			BEGIN
				SET @LoadNumber = (SELECT ISNULL(MAX(LoadNumber)+1,0) FROM #Loads_Temp);
				IF(@LoadNumber < @MinimumLoadStartNumber)
				BEGIN
					SET @LoadNumber = @MinimumLoadStartNumber;
				END
			END
		ELSE
			BEGIN
				IF(SELECT MAX(LoadNumber) FROM #Loads_Temp WHERE StatusText < '2. BOOKED') > = @StartingActiveLoadNumber
					BEGIN
						SET @LoadNumber = (SELECT ISNULL(MAX(LoadNumber)+1,0) FROM #Loads_Temp);
					END
				ELSE
					BEGIN
						SET @LoadNumber = (SELECT ISNULL(MAX(LoadNumber)+1,0)  FROM #Loads_Temp  WHERE StatusText < '2. BOOKED');
					END
				IF(@LoadNumber < @MinimumLoadStartNumber)
				BEGIN
					SET @LoadNumber = @MinimumLoadStartNumber;
				END
			END
	END
	/*End : Generate LoadNumber*/
	
	SET @LoadID = newid();

	IF(SELECT COUNT(StatusTypeID) FROM LoadStatusTypes WHERE StatusText = '0.1 EDI' AND CompanyID=@CompanyID)=0
	BEGIN
		INSERT INTO [dbo].[LoadStatusTypes]
						   ([StatusTypeID]
						   ,[StatusOrder]
						   ,[StatusText]
						   ,[IsActive]
						   ,[CreatedDateTime]
						   ,[LastModifiedDateTime]
						   ,[CreatedBy]
						   ,[LastModifiedBy]
						   ,[ColorCode]
						   ,[Filter]
						   ,[ForceNextStatus]
						   ,[SystemUpdated]
						   ,[AllowOnMobileWebApp]
						   ,[CompanyID]
						   ,[SendEmailForLoads]
				           ,[ShowAsActiveLoadOnMobile]
				           ,[StatusDescription]
				           ,[Reports]
				           ,[ShowStopOnLoadStatus])

					SELECT
							NEWID() 
						   ,[StatusOrder]
						   ,[StatusText]
						   ,[IsActive]
						   ,getdate()
						   ,getdate()
						   ,'lm'
						   ,'lm'
						   ,[ColorCode]
						   ,[Filter]
						   ,[ForceNextStatus]
						   ,0
						   ,[AllowOnMobileWebApp]
						   ,@CompanyID 
						   ,[SendEmailForLoads]
				           ,[ShowAsActiveLoadOnMobile]
				           ,[StatusDescription]
				           ,[Reports]
				           ,[ShowStopOnLoadStatus]
					FROM [LoadManagerTemplate].[dbo].[StatusTemplate] WHERE StatusText = '0.1 EDI'
	END

	SET @StatusTypeID = (SELECT StatusTypeID FROM LoadStatusTypes WHERE StatusText = '0.1 EDI' AND CompanyID=@CompanyID)

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
		NewNotes,
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
		CustomerPONo,
		BOLNum,
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
		NewPickupTime,
		NewDeliveryDate,
		NewDeliveryTime
		)
	VALUES
		(@LoadID,
		@LoadNumber,
		@LoadNumber,
		@StatusTypeID,
		@DispatcherID,
		@SalesRepID,
		@EquipmentID,
		(SELECT EquipmentName FROM Equipments WHERE EquipmentID = @EquipmentID),
		@EquipmentWidth,
		@EquipmentLength,
		@NewNotes,
		@CustomerID,
		@CustName,
		@Address,
		@City,
		@StateCode,
		@PostalCode,
		@ContactPerson,
		@Phone,
		@CellNo,
		@Fax,
		@ContactEmail,
		@CustomerPONo,
		@BOLNum,
		getdate(),
		getdate(),
		@CreatedBy,
		@CreatedBy,
		@CreatedByIP,
		@customerCommoditiesCharges,
		@customerCommoditiesCharges,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		@NewPickupDate,
		@NewPickupTime,
		@NewDeliveryDate,
		@NewDeliveryTime)


	INSERT INTO LoadLogs (LoadID,LoadNumber,FieldLabel,UpdatedByUserID,UpdatedBy,UpdatedTimestamp,UpdatedByIP)
	VALUES(@LoadID,@LoadNumber,'NEW LOAD',@UpdatedByUserID,@CreatedBy,getdate(),@CreatedByIP)
	DROP TABLE #Loads_Temp;
	SELECT @LoadID AS LoadID
	
END
GO


