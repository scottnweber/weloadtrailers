GO

/****** Object:  StoredProcedure [dbo].[USP_ImportCustomerViaCSV]    Script Date: 21-06-2022 16:27:00 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER       Procedure [dbo].[USP_ImportCustomerViaCSV]
(
@CompanyID varchar(36),
@Row text,
@RowNo int,
@CustomerCode varchar(40),
@IsPayer bit,
@OfficeCode varchar(20),
@CustomerName varchar(100),
@Location varchar(100),
@City varchar(50),
@ZipCode varchar(50),
@StateCode varchar(50),
@CustomerNotes varchar(1000),
@SalesAgent varchar(50),
@Dispatcher varchar(50),
@BestOpp varchar(100),
@CreditLimit money,
@CreatedBy varchar(100),
@ContactPerson varchar(50),
@PhoneNo varchar(50),
@Fax varchar(150),
@TollFree varchar(150),
@PersonMobileNo varchar(50),
@Email varchar(max),
@RemitName varchar(150),
@RemitAddress varchar(250),
@RemitCity varchar(50),
@RemitState varchar(10),
@RemitZip varchar(50),
@RemitPhone varchar(50),
@RemitFax varchar(50),
@RemitEmail varchar(150),
@RemitContact varchar(150),
@InvoiceRemitInformation varchar(max),
@BillingContact varchar(50),
@BillingPhone varchar(50),
@BillingFax varchar(150),
@BillingTollFree varchar(150),
@BillingCell varchar(50),
@BillingEmail varchar(max),
@DispatchContact varchar(50),
@DispatchPhone varchar(50),
@DispatchFax varchar(150),
@DispatchTollFree varchar(150),
@DispatchCell varchar(50),
@DispatchEmail varchar(max),
@Website varchar(50)
)
AS
BEGIN
	DECLARE @Validated bit = 1,
		@Message varchar(150),
		@CustomerID varchar(36) = NEWID(),
		@OfficeID varchar(36),
		@SalesRepID varchar(36) = NULL,
		@AcctMGRID varchar(36) = NULL,
		@FactoringID varchar(36) = NULL;
	IF(SELECT COUNT(C.CustomerID) FROM Customers C INNER JOIN CustomerOffices CO ON C.CustomerID = CO.CustomerID INNER JOIN Offices O ON O.OfficeID = CO.OfficeID WHERE O.CompanyID = @CompanyID AND C.CustomerCode = @CustomerCode)<>0
	BEGIN
		SET @Validated = 0;
		SET @Message = 'Customer Code ('+@CustomerCode+') already exists. Row Number:'+CAST(@RowNo AS varchar);
	END
	ELSE IF(SELECT COUNT(O.OfficeID) FROM Offices O WHERE CompanyID = @CompanyID AND OfficeCode = @OfficeCode)=0
	BEGIN
		SET @Validated = 0;
		SET @Message = 'Office Code ('+@OfficeCode+') not found. Row Number:'+CAST(@RowNo AS varchar);
	END

	IF(@Validated)=1
	BEGIN
		SET @OfficeID = (SELECT O.OfficeID FROM Offices O WHERE CompanyID = @CompanyID AND OfficeCode = @OfficeCode);
		SET @SalesRepID = (SELECT E.EmployeeID FROM Employees E INNER JOIN Offices O ON O.OfficeID = E.OfficeID WHERE O.CompanyID = @CompanyID AND E.Name=@SalesAgent)
		SET @AcctMGRID = (SELECT E.EmployeeID FROM Employees E INNER JOIN Offices O ON O.OfficeID = E.OfficeID WHERE O.CompanyID = @CompanyID AND E.Name=@Dispatcher)

		IF(LEN(TRIM(@RemitName)))<>0
		BEGIN
			IF(SELECT COUNT(FactoringID) FROM Factorings WHERE CompanyID=@CompanyID AND Name = @RemitName AND Address = @RemitAddress AND Zip =@RemitZip)=0
				BEGIN
					SET @FactoringID = NEWID();
					INSERT INTO Factorings(
						FactoringID,
						Name,
						Address,
						City,
						State,
						Zip,
						Phone,
						Fax,
						Email,
						Contact,
						InvoiceRemitInformation,
						CreatedBy,
						LastModifiedBy,
						CreatedDateTime,
						LastModifiedDateTime,
						CompanyID
					)
					VALUES(
						@FactoringID,
						@RemitName,
						@RemitAddress,
						@RemitCity,
						@RemitState,
						@RemitZip,
						@RemitPhone,
						@RemitFax,
						@RemitEmail,
						@RemitContact,
						@InvoiceRemitInformation,
						@createdBy,
						@createdBy,
						GETDATE(),
						GETDATE(),
						@CompanyID
					)
				END
			ELSE
				BEGIN
					SET @FactoringID = (SELECT TOP 1 FactoringID FROM Factorings WHERE CompanyID=@CompanyID AND Name = @RemitName AND Address = @RemitAddress AND Zip =@RemitZip)
				END
		END

		INSERT INTO Customers(
		CustomerID,
		CustomerCode,
		CustomerName,
		IsPayer,
		OfficeID,
		Location,
		City,
		ZipCode,
		StateCode,
		CountryID,
		CustomerStatusID,
		CustomerDirections,
		CustomerNotes,
		SalesRepID,
		AcctMGRID,
		BestOpp,
		CreditLimit,
		CreatedBy,
		LastModifiedBy,
		CreatedDateTime,
		LastModifiedDateTime,
		FactoringID,
		contactperson,
		PhoneNo,
		Fax,
		Tollfree,
		PersonMobileNo,
		Email,
		Website
		)
		VALUES(
		@CustomerID,
		@CustomerCode,
		@CustomerName,
		@IsPayer,
		@OfficeID,
		@Location,
		@City,
		@ZipCode,
		@StateCode,
		'9BC066A3-2961-4410-B4ED-537CF4EE282A',
		1,
		'',
		@CustomerNotes,
		@SalesRepID,
		@AcctMGRID,
		@BestOpp,
		@CreditLimit,
		@CreatedBy,
		@CreatedBy,
		GETDATE(),
		GETDATE(),
		@FactoringID,
		@ContactPerson,
		@PhoneNo,
		@Fax,
		@TollFree,
		@PersonMobileNo,
		@Email,
		@Website
		)

		INSERT INTO [dbo].[CustomerOffices]
			([CustomerOfficesID]
			,[CustomerID]
			,[OfficeID])
		VALUES
			(
			newid(),
			@CustomerID,
			@OfficeID
			)

		IF(len(trim(@BillingContact)) <> 0 OR len(trim(@BillingEmail)) <> 0)
		BEGIN
			INSERT INTO [dbo].[CustomerContacts]
				([CustomerContactID]
				,[CustomerID]
				,[ContactPerson]
				,[PhoneNo]
				,[Fax]
				,[TollFree]
				,[PersonMobileNo]
				,[Email]
				,[ContactType])
			VALUES(
				newid(),
				@CustomerID,
				@BillingContact,
				@BillingPhone,
				@BillingFax,
				@BillingTollFree,
				@BillingCell,
				@BillingEmail,
				'Billing'
				)
		END

		IF(len(trim(@DispatchContact)) <> 0 OR len(trim(@DispatchEmail)) <> 0)
		BEGIN
			INSERT INTO [dbo].[CustomerContacts]
				([CustomerContactID]
				,[CustomerID]
				,[ContactPerson]
				,[PhoneNo]
				,[Fax]
				,[TollFree]
				,[PersonMobileNo]
				,[Email]
				,[ContactType])
			VALUES(
				newid(),
				@CustomerID,
				@DispatchContact,
				@DispatchPhone,
				@DispatchFax,
				@DispatchTollFree,
				@DispatchCell,
				@DispatchEmail,
				'Dispatch'
				)
		END
		SET @Message = 'Imported Customer:'+@CustomerCode+'(Row Number:'+CAST(@RowNo AS varchar)+').'
	END

	--Insert Log
	INSERT INTO CustomerCsvImportLog (LogId,Message,CreatedDate,Success,RowData,CustomerCode,CompanyID,CreatedBy)
	VALUES(newid(),@Message,GETDATE(),@Validated,@Row,@CustomerCode,@CompanyID,@CreatedBy)
	SELECT @Validated AS Success

END


GO


