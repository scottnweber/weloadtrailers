
IF NOT EXISTS (SELECT column_name FROM INFORMATION_SCHEMA.columns where table_name = 'Employees' and column_name = 'DefaultSalesRep')
BEGIN
	ALTER TABLE Employees ADD DefaultSalesRep varchar(36);
END

IF NOT EXISTS (SELECT column_name FROM INFORMATION_SCHEMA.columns where table_name = 'Employees' and column_name = 'DefaultDispatcher')
BEGIN
	ALTER TABLE Employees ADD DefaultDispatcher varchar(36);
END

GO

/****** Object:  StoredProcedure [dbo].[USP_InsertAgent]    Script Date: 08-07-2022 08:04:59 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER   PROCEDURE [dbo].[USP_InsertAgent]
(
	@Name as nvarchar(50),
	@Address as nvarchar(max),
	@City as nvarchar(50),
	@State as nvarchar(50),
	@Zip as nvarchar(50),
	@Country as nvarchar(50),
	@Telephone as nvarchar(50),
	@PhoneExtension as varchar(50),
	@cel as nvarchar(50),
	@celextension as varchar(50),
	@fax as varchar(50),	
	@faxextension as varchar(50),
	@emailSignature as text,
	@loginid as varchar(100),	
	@roleid as int,
	@password as nvarchar(50),
	@CreatedDateTime as datetime,
	@createdBy as nvarchar(20),
	@LastModifiedDateTime as datetime,
	@LastModifiedBy as nvarchar(20),
	@IsActive as bit,
	@LastIpAddress as nvarchar(50),
	@lastLoginDate as datetime,
	@EmailID as nvarchar(50),
	@OfficeID as nvarchar(50),
	@SalesCommission as real,
	@CreatedByIP as varchar(50),
	@integratewithTran360 as bit,	
	@trans360Usename as varchar(200),
	@trans360Password as varchar(200),
	@SmtpAddress as varchar(200),
	@SmtpUsername as varchar(200),
	@SmtpPassword as varchar(200),
	@SmtpPort as int,
	@useTLS as bit,
	@useSSL as bit,
	@loadBoard123 as bit,
	@loadBoard123Usename as varchar(200),
	@loadBoard123Password as varchar(200),
	@DefaultCurrency as int,
	@PEPcustomerKey as varchar(100),
	@IntegrateWithDirectFreightLoadboard as bit,
	@DirectFreightLoadboardUserName as varchar(200), 
	@DirectFreightLoadboardPassword as varchar(200),
	@LoadBoard123Default as bit,
	@IntegrateWithTran360Default as bit,
	@IntegrateWithDirectFreightLoadboardDefault as bit,
	@integratewithITS as bit,
	@integratewithITSDefault as bit,
	@integratewithPEP as bit,
	@integratewithPEPDefault as bit,
	@DefaultSalesRepToLoad as bit,
	@DefaultDispatcherToLoad as bit,
	@EmpID varchar(36)
)
AS
BEGIN
	DECLARE @EmployeeID uniqueidentifier;
	SET @EmployeeID = NewID();

	INSERT INTO Employees(employeeid,name,address,city,state,zip,country,telephone,PhoneExtension,cel,celextension,fax,faxextension,emailSignature,loginid,roleid,password,CreatedDateTime,createdBy,LastModifiedDateTime,LastModifiedBy,
		IsActive,LastIpAddress,lastLoginDate,EmailID,OfficeID,SalesCommission,CreatedByIP,integratewithTran360,trans360Usename,trans360Password,SmtpAddress,SmtpUsername,SmtpPassword,SmtpPort,useTLS,useSSL,loadBoard123,loadBoard123Usename,loadBoard123Password,DefaultCurrency,PEPcustomerKey,IntegrateWithDirectFreightLoadboard,DirectFreightLoadboardUserName,DirectFreightLoadboardPassword,LoadBoard123Default,IntegrateWithTran360Default,IntegrateWithDirectFreightLoadboardDefault,integratewithITS,integratewithITSDefault,integratewithPEP,integratewithPEPDefault,DefaultSalesRepToLoad,DefaultDispatcherToLoad)
	VALUES(
		 @EmployeeID
		,@name
		,@address
		,@city
		,@state
		,@zip
		,@country
		,@telephone
		,@PhoneExtension
		,@cel
		,@celextension
		,@fax
		,@faxextension
		,@emailSignature
		,@loginid
		,@roleid
		,@password
		,@CreatedDateTime
		,@createdBy
		,@LastModifiedDateTime
		,@LastModifiedBy
		,@IsActive
		,@LastIpAddress
		,@lastLoginDate
		,@EmailID
		,@OfficeID
		,@SalesCommission
		,@CreatedByIP
		,@integratewithTran360
		,@trans360Usename
		,@trans360Password
		,@SmtpAddress
		,@SmtpUsername
		,@SmtpPassword
		,@SmtpPort
		,@useTLS
		,@useSSL
		,@loadBoard123
		,@loadBoard123Usename
		,@loadBoard123Password
		,@DefaultCurrency
		,@PEPcustomerKey
		,@IntegrateWithDirectFreightLoadboard
		,@DirectFreightLoadboardUserName
		,@DirectFreightLoadboardPassword
		,@LoadBoard123Default
		,@IntegrateWithTran360Default
		,@IntegrateWithDirectFreightLoadboardDefault
		,@integratewithITS,@integratewithITSDefault,@integratewithPEP,@integratewithPEPDefault,@DefaultSalesRepToLoad,@DefaultDispatcherToLoad
	)
	IF(@DefaultSalesRepToLoad=1)
	BEGIN
		UPDATE Employees SET DefaultSalesRep = @EmployeeID WHERE EmployeeID = @EmpID
	END
	ELSE
	BEGIN
		UPDATE Employees SET DefaultSalesRep = NULL WHERE EmployeeID = @EmpID AND DefaultSalesRep = @EmployeeID
	END

	IF(@DefaultDispatcherToLoad=1)
	BEGIN
		UPDATE Employees SET DefaultDispatcher = @EmployeeID WHERE EmployeeID = @EmpID
	END
	ELSE
	BEGIN
		UPDATE Employees SET DefaultDispatcher = NULL WHERE EmployeeID = @EmpID AND DefaultDispatcher = @EmployeeID
	END
	SELECT @EmployeeID AS LastInsertedEmployeeID
END



GO


GO

/****** Object:  StoredProcedure [dbo].[USP_UpdateAgent]    Script Date: 08-07-2022 08:02:51 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




ALTER     PROCEDURE [dbo].[USP_UpdateAgent]
(	
	@EmployeeID AS nvarchar(50),
	@Name as nvarchar(50),
	@roleid as int,
	@password as nvarchar(50),
	@Address as nvarchar(max),
	@City as nvarchar(50),
	@State as nvarchar(50),
	@Zip as nvarchar(50),
	@Country as nvarchar(50),
	@Telephone as nvarchar(50),
	@PhoneExtension as varchar(50),
	@cel as nvarchar(50),
	@celextension as varchar(50),
	@fax as varchar(50),	
	@faxextension as varchar(50),
	@loginid as varchar(100),
	@emailSignature as text,
	@LastModifiedDateTime as datetime,
	@LastModifiedBy as nvarchar(20),
	@IsActive as bit,
	@LastIpAddress as nvarchar(50),
	@EmailID as nvarchar(50),
	@OfficeID as nvarchar(50),
	@SalesCommission as real,
	@UpdatedByIP as varchar(50),
	@integratewithTran360 as bit,	
	@trans360Usename as varchar(200),
	@trans360Password as varchar(200),
	@integrationID AS varchar(50),
	@SmtpAddress as varchar(200),
	@SmtpUsername as varchar(200),
	@SmtpPassword as varchar(200),
	@SmtpPort as int,
	@useTLS as bit,
	@useSSL as bit,
	@loadBoard123 as bit,
	@loadBoard123Usename as varchar(200),
	@loadBoard123Password as varchar(200),
	@DefaultCurrency as int,
	@PEPcustomerKey as varchar(100),
	@IntegrateWithDirectFreightLoadboard as bit,
	@DirectFreightLoadboardUserName as varchar(200), 
	@DirectFreightLoadboardPassword as varchar(200),
	@LoadBoard123Default as bit,
	@IntegrateWithTran360Default as bit,
	@IntegrateWithDirectFreightLoadboardDefault as bit,
	@integratewithITS as bit,
	@integratewithITSDefault as bit,
	@integratewithPEP as bit,
	@integratewithPEPDefault as bit,
	@DefaultSalesRepToLoad as bit,
	@DefaultDispatcherToLoad as bit,
	@EmpID varchar(36)
)
AS
BEGIN

	IF(@DefaultSalesRepToLoad=1)
	BEGIN
		UPDATE Employees SET DefaultSalesRep = @EmployeeID WHERE EmployeeID = @EmpID
	END
	ELSE
	BEGIN
		UPDATE Employees SET DefaultSalesRep = NULL WHERE EmployeeID = @EmpID AND DefaultSalesRep = @EmployeeID
	END

	IF(@DefaultDispatcherToLoad=1)
	BEGIN
		UPDATE Employees SET DefaultDispatcher = @EmployeeID WHERE EmployeeID = @EmpID
	END
	ELSE
	BEGIN
		UPDATE Employees SET DefaultDispatcher = NULL WHERE EmployeeID = @EmpID AND DefaultDispatcher = @EmployeeID
	END

	UPDATE Employees SET
		Name=@Name, 
		roleid=@roleid, 
		password=@password, 
		Address=@Address, 
		City=@City, 
		State=@State, 
		Zip=@Zip, 
		Country=@Country, 
		Telephone=@Telephone, 
		PhoneExtension=@PhoneExtension, 
		cel=@cel, 
		celextension=@celextension, 
		fax=@fax, 	
		faxextension=@faxextension, 
		loginid=@loginid, 
		emailSignature=@emailSignature, 
		LastModifiedDateTime =@LastModifiedDateTime, 
		LastModifiedBy=@LastModifiedBy, 
		IsActive=@IsActive, 
		LastIpAddress=@LastIpAddress, 
		EmailID=@EmailID, 
		OfficeID=@OfficeID, 
		SalesCommission=@SalesCommission,
		UpdatedByIP=@UpdatedByIP, 
		integratewithTran360 =@integratewithTran360, 	
		trans360Usename =@trans360Usename, 
		trans360Password=@trans360Password, 
		integrationID=@integrationID, 
		SmtpAddress =@SmtpAddress, 
		SmtpUsername =@SmtpUsername, 
		SmtpPassword=@SmtpPassword, 
		SmtpPort =@SmtpPort, 
		useTLS =@useTLS, 
		useSSL =@useSSL, 
		loadBoard123=@loadBoard123, 
		loadBoard123Usename=@loadBoard123Usename, 
		loadBoard123Password=@loadBoard123Password, 
		DefaultCurrency=@DefaultCurrency, 
		PEPcustomerKey=@PEPcustomerKey, 
		IntegrateWithDirectFreightLoadboard=@IntegrateWithDirectFreightLoadboard, 
		DirectFreightLoadboardUserName=@DirectFreightLoadboardUserName,  
		DirectFreightLoadboardPassword=@DirectFreightLoadboardPassword, 
		LoadBoard123Default=@LoadBoard123Default, 
		IntegrateWithTran360Default=@IntegrateWithTran360Default, 
		IntegrateWithDirectFreightLoadboardDefault=@IntegrateWithDirectFreightLoadboardDefault
	   ,integratewithITS = @integratewithITS
       ,integratewithITSDefault = @integratewithITSDefault
       ,integratewithPEP = @integratewithPEP
       ,integratewithPEPDefault = @integratewithPEPDefault
	   ,DefaultSalesRepToLoad = @DefaultSalesRepToLoad
	   ,DefaultDispatcherToLoad = @DefaultDispatcherToLoad
	WHERE EmployeeID = @EmployeeID
END
GO


