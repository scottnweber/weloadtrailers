IF NOT EXISTS (SELECT column_name FROM INFORMATION_SCHEMA.columns where table_name = 'Carriers' and column_name = 'DispatchFeeAmount')
BEGIN
	ALTER TABLE Carriers ADD DispatchFeeAmount money not null default 0;
END

GO
/****** Object:  StoredProcedure [dbo].[USP_InsertCarrier]    Script Date: 07/04/2022 11:25:18 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER           PROCEDURE [dbo].[USP_InsertCarrier]
(
	@CompanyID as varchar(50),
	@CarrierName as varchar(50),
	@MCNumber as nvarchar(50),
	@Address as varchar(200),
	@RegNumber as nvarchar(20),
	@TaxID as nvarchar(20),
	@equipmentID as varchar(50),
	@RemitName as varchar(100),
	@RemitAddress as varchar(200),
	@RemitCity as nvarchar(50),
	@RemitState as nchar(2),
	@RemitZipcode as nvarchar(20),
	@RemitContact as varchar(150),
	@RemitPhone as varchar(150),
	@RemitFax as varchar(150),
	@InsCompany as nvarchar(100),
	@InsCompPhone as nvarchar(50),
	@InsAgent as nvarchar(150),
	@InsAgentPhone as nvarchar(50),
	@InsPolicyNumber as nvarchar(50),
	@InsExpDate as datetime,
	@Track1099 as bit,
	@InsLimit as real,
	@StateCode as nchar(10),
	@ZipCode as nvarchar(20),
	@EquipmentNotes as ntext,
	@Status as tinyint,
	@CreatedBy as nvarchar(20),
	@LastModifiedBy as nvarchar(20),
	@CreatedDateTime as datetime,
	@LastModifiedDateTime as datetime,
	@City as varchar(150),
	@country as varchar(50),
	@website as varchar(200),
	@IsInsVerified as bit,
	@IsInsDate as bit,
	@IsContractVerified as bit,
	@IsW9 as bit,
	@IsReferences as bit,
	@CreatedByIP as varchar(50),
	@GUID as text,
	@notes as ntext,
	@CarrierTerms as nvarchar(4000),
	@VendorID as varchar(20),
	@DOTNumber as nvarchar(50),
	@SaferWatch as bit,
	@RiskAssessment as varchar(MAX),
	@MobileAppPassword as varchar(50),
	@isShowDollar as bit,
	@IsCarrier as bit,
	@ContactHow as tinyint,
	@LoadLimit as int,
	@DefaultCurrency as int,
	@CarrierEmailAvailableLoads as bit,
	@DispatchFee as decimal(5, 2),
	@SCAC as varchar(8),
	@Memo as text,
	@InsCompanyCargo as nvarchar(100),
	@InsCompPhoneCargo as nvarchar(50),
	@InsAgentCargo as nvarchar(150),
	@InsAgentPhoneCargo as nvarchar(50),
	@InsPolicyNumberCargo as nvarchar(50),
	@InsExpDateCargo as datetime,
	@InsLimitCargo as real,
	@InsCompanyGeneral as nvarchar(100),
	@InsCompPhoneGeneral as nvarchar(50),
	@InsAgentGeneral as nvarchar(150),
	@InsAgentPhoneGeneral as nvarchar(50),
	@InsPolicyNumberGeneral as nvarchar(50),
	@InsExpDateGeneral as datetime,
	@InsLimitGeneral as real,
	@InsEmail as varchar(50),
	@InsEmailCargo as varchar(50),
	@InsEmailGeneral as varchar(50),
	@InsuranceCompanyAddress as nvarchar(250),
	@ExpirationDate as datetime,
	@DateCreated as datetime,
	@commonStatus as bit,
	@contractStatus as bit,
	@BrokerStatus as bit,
	@commonAppPending as bit,
	@contractAppPending as bit,
	@BrokerAppPending as bit,
	@BIPDInsRequired as bit,
	@cargoInsRequired as bit,
	@BIPDInsonFile as bit,
	@cargoInsonFile as bit,
	@householdGoods as bit,
	@CARGOExpirationDate as datetime,
	@InsuranceCompanyAddressCargo as nvarchar(250),
	@householdGoodsCargo as bit,
	@InsuranceCompanyAddressGeneral as nvarchar(250),
	@householdGoodsGeneral as bit,
	@employeeType as nvarchar(250),
	@source as varchar(150),
	@FactoringID as varchar(150),
	@ContactPerson as varchar(150),
	@Phone as varchar(150),
	@Fax as varchar(150),
	@Cel as varchar(150),
	@EmailID as varchar(150),
	@Tollfree as varchar(150),
	@PhoneExt as varchar(50),
	@FaxExt as varchar(50),
	@TollFreeExt as varchar(50),
	@CellPhoneExt as varchar(50),
	@RatePerMile as money =0,
	@RemitEmail as varchar(250),
	@FF float,
	@DispatchFeeAmount as money =0
)
AS
BEGIN
	DECLARE @CarrierID uniqueidentifier;
	SET @CarrierID = NewID();

	INSERT INTO Carriers(
		CarrierID,
		CompanyID,
		CarrierName,
		MCNumber,
		Address,
		RegNumber,
		TaxID,
		equipmentID,
		RemitName,
		RemitAddress,
		RemitCity,
		RemitState,
		RemitZipcode,
		RemitContact,
		RemitPhone,
		RemitFax,
		InsCompany,
		InsCompPhone,
		InsAgent,
		InsAgentPhone,
		InsPolicyNumber,
		InsExpDate,
		Track1099,
		InsLimit,
		StateCode,
		ZipCode,
		EquipmentNotes,
		Status,
		CreatedBy,
		LastModifiedBy,
		CreatedDateTime,
		LastModifiedDateTime,
		City,
		country,
		website,
		IsInsVerified,
		IsInsDate,
		IsContractVerified,
		IsW9,
		IsReferences,
		CreatedByIP,
		GUID,
		notes,
		CarrierTerms,
		VendorID,
		DOTNumber,
		SaferWatch,
		RiskAssessment,
		MobileAppPassword,
		isShowDollar,
		IsCarrier,
		ContactHow,
		LoadLimit,
		DefaultCurrency,
		CarrierEmailAvailableLoads,
		DispatchFee,
		SCAC,
		Memo,
		InsCompanyCargo,
		InsCompPhoneCargo,
		InsAgentCargo,
		InsAgentPhoneCargo,
		InsPolicyNumberCargo,
		InsExpDateCargo,
		InsLimitCargo,
		InsCompanyGeneral,
		InsCompPhoneGeneral,
		InsAgentGeneral,
		InsAgentPhoneGeneral,
		InsPolicyNumberGeneral,
		InsExpDateGeneral,
		InsLimitGeneral,
		InsEmail,
		InsEmailCargo,
		InsEmailGeneral,
		employeeType,
		[source],
		FactoringID,
		ContactPerson,
		Phone,
		Fax,
		Cel,
		EmailID,
		Tollfree,
		PhoneExt,
		FaxExt,
		TollFreeExt,
		CellPhoneExt,
		RatePerMile,
		RemitEmail,
		FF,
		DispatchFeeAmount
	)
	VALUES(
		@CarrierID,
		@CompanyID,
		@CarrierName,
		@MCNumber,
		@Address,
		@RegNumber,
		@TaxID,
		@equipmentID,
		@RemitName,
		@RemitAddress,
		@RemitCity,
		@RemitState,
		@RemitZipcode,
		@RemitContact,
		@RemitPhone,
		@RemitFax,
		@InsCompany,
		@InsCompPhone,
		@InsAgent,
		@InsAgentPhone,
		@InsPolicyNumber,
		@InsExpDate,
		@Track1099,
		@InsLimit,
		@StateCode,
		@ZipCode,
		@EquipmentNotes,
		@Status,
		@CreatedBy,
		@LastModifiedBy,
		@CreatedDateTime,
		@LastModifiedDateTime,
		@City,
		@country,
		@website,
		@IsInsVerified,
		@IsInsDate,
		@IsContractVerified,
		@IsW9,
		@IsReferences,
		@CreatedByIP,
		@GUID,
		@notes,
		@CarrierTerms,
		@VendorID,
		@DOTNumber,
		@SaferWatch,
		@RiskAssessment,
		@MobileAppPassword,
		@isShowDollar,
		@IsCarrier,
		@ContactHow,
		@LoadLimit,
		@DefaultCurrency,
		@CarrierEmailAvailableLoads,
		@DispatchFee,
		@SCAC,
		@Memo,
		@InsCompanyCargo,
		@InsCompPhoneCargo,
		@InsAgentCargo,
		@InsAgentPhoneCargo,
		@InsPolicyNumberCargo,
		@InsExpDateCargo,
		@InsLimitCargo,
		@InsCompanyGeneral,
		@InsCompPhoneGeneral,
		@InsAgentGeneral,
		@InsAgentPhoneGeneral,
		@InsPolicyNumberGeneral,
		@InsExpDateGeneral,
		@InsLimitGeneral,
		@InsEmail,
		@InsEmailCargo,
		@InsEmailGeneral,
		@employeeType,
		@source,
		@FactoringID,
		@ContactPerson,
		@Phone,
		@Fax,
		@Cel,
		@EmailID,
		@Tollfree,
		@PhoneExt,
		@FaxExt,
		@TollFreeExt,
		@CellPhoneExt,
		@RatePerMile,
		@RemitEmail,
		@FF,
		@DispatchFeeAmount
	)

	INSERT INTO lipublicfmcsa(
		InsuranceCompanyAddress,
		carrierId,
		ExpirationDate,
		DateCreated,
		commonStatus,
		contractStatus,
		BrokerStatus,
		commonAppPending,
		contractAppPending,
		BrokerAppPending,
		BIPDInsRequired,
		cargoInsRequired,
		BIPDInsonFile,
		cargoInsonFile,
		householdGoods,
		CARGOExpirationDate,
		InsuranceCompanyAddressCargo,
		householdGoodsCargo,
		InsuranceCompanyAddressGeneral,
		householdGoodsGeneral
	)
	VALUES(
		@InsuranceCompanyAddress,
		@carrierId,
		@ExpirationDate,
		@DateCreated,
		@commonStatus,
		@contractStatus,
		@BrokerStatus,
		@commonAppPending,
		@contractAppPending,
		@BrokerAppPending,
		@BIPDInsRequired,
		@cargoInsRequired,
		@BIPDInsonFile,
		@cargoInsonFile,
		@householdGoods,
		@CARGOExpirationDate,
		@InsuranceCompanyAddressCargo,
		@householdGoodsCargo,
		@InsuranceCompanyAddressGeneral,
		@householdGoodsGeneral
	)
	SELECT @CarrierID AS LastInsertedCarrierID
END


GO
/****** Object:  StoredProcedure [dbo].[USP_UpdateCarrier]    Script Date: 07/04/2022 11:32:18 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO









ALTER             PROCEDURE [dbo].[USP_UpdateCarrier]
(
	@CarrierID as varchar(50),
	@CarrierName as varchar(50),
	@MCNumber as nvarchar(50),
	@Address as varchar(200),
	@RegNumber as nvarchar(20),
	@TaxID as nvarchar(20),
	@equipmentID as varchar(50),
	@RemitName as varchar(100),
	@RemitAddress as varchar(200),
	@RemitCity as nvarchar(50),
	@RemitState as nchar(2),
	@RemitZipcode as nvarchar(20),
	@RemitContact as varchar(150),
	@RemitPhone as varchar(150),
	@RemitFax as varchar(150),
	@InsCompany as nvarchar(100),
	@InsCompPhone as nvarchar(50),
	@InsAgent as nvarchar(150),
	@InsAgentPhone as nvarchar(50),
	@InsPolicyNumber as nvarchar(50),
	@InsExpDate as datetime,
	@Track1099 as bit,
	@InsLimit as real,
	@StateCode as nchar(10),
	@ZipCode as nvarchar(20),
	@EquipmentNotes as ntext,
	@Status as tinyint,
	@LastModifiedBy as nvarchar(20),
	@LastModifiedDateTime as datetime,
	@City as varchar(150),
	@country as varchar(50),
	@website as varchar(200),
	@UpdatedByIP as varchar(50),
	@notes as ntext,
	@CarrierTerms as nvarchar(4000),
	@VendorID as varchar(20),
	@DOTNumber as nvarchar(50),
	@SaferWatch as bit,
	@RiskAssessment as varchar(MAX),
	@MobileAppPassword as varchar(50),
	@isShowDollar as bit,
	@ContactHow as tinyint,
	@LoadLimit as int,
	@DefaultCurrency as int,
	@CarrierEmailAvailableLoads as bit,
	@DispatchFee as decimal(5, 2),
	@MyCarrierPackets as bit,
	@SCAC as varchar(8),
	@Memo as text,
	@InsCompanyCargo as nvarchar(100),
	@InsCompPhoneCargo as nvarchar(50),
	@InsAgentCargo as nvarchar(150),
	@InsAgentPhoneCargo as nvarchar(50),
	@InsPolicyNumberCargo as nvarchar(50),
	@InsExpDateCargo as datetime,
	@InsLimitCargo as real,
	@InsCompanyGeneral as nvarchar(100),
	@InsCompPhoneGeneral as nvarchar(50),
	@InsAgentGeneral as nvarchar(150),
	@InsAgentPhoneGeneral as nvarchar(50),
	@InsPolicyNumberGeneral as nvarchar(50),
	@InsExpDateGeneral as datetime,
	@InsLimitGeneral as real,
	@InsEmail as varchar(50),
	@InsEmailCargo as varchar(50),
	@InsEmailGeneral as varchar(50),
	@InsuranceCompanyAddress as nvarchar(250),
	@ExpirationDate as datetime,
	@commonStatus as bit,
	@contractStatus as bit,
	@BrokerStatus as bit,
	@commonAppPending as bit,
	@contractAppPending as bit,
	@BrokerAppPending as bit,
	@BIPDInsRequired as bit,
	@cargoInsRequired as bit,
	@BIPDInsonFile as bit,
	@cargoInsonFile as bit,
	@householdGoods as bit,
	@CARGOExpirationDate as datetime,
	@InsuranceCompanyAddressCargo as nvarchar(250),
	@householdGoodsCargo as bit,
	@InsuranceCompanyAddressGeneral as nvarchar(250),
	@householdGoodsGeneral as bit,
	@employeeType as nvarchar(250),
	@FactoringID as varchar(150),
	@ContactPerson as varchar(150),
	@Phone as varchar(150),
	@Fax as varchar(150),
	@Cel as varchar(150),
	@EmailID as varchar(150),
	@Tollfree as varchar(150),
	@PhoneExt as varchar(50),
	@FaxExt as varchar(50),
	@TollFreeExt as varchar(50),
	@CellPhoneExt as varchar(50),
	@RatePerMile as money =0,
	@RemitEmail as varchar(250),
	@FF float,
	@DispatchFeeAmount as money =0
)
AS
BEGIN
	UPDATE Carriers SET
	
	CarrierName=@CarrierName,
	MCNumber=@MCNumber,
	Address=@Address,
	RegNumber=@RegNumber,

	TaxID=@TaxID,
	equipmentID=@equipmentID,
	RemitName=@RemitName,
	RemitAddress=@RemitAddress,
	RemitCity=@RemitCity,
	RemitState=@RemitState,
	RemitZipcode=@RemitZipcode,
	RemitContact=@RemitContact,
	RemitPhone=@RemitPhone,
	RemitFax=@RemitFax,
	InsCompany=@InsCompany,
	InsCompPhone=@InsCompPhone,
	InsAgent=@InsAgent,
	InsAgentPhone=@InsAgentPhone,
	InsPolicyNumber=@InsPolicyNumber,
	InsExpDate=@InsExpDate,
	Track1099=@Track1099,
	InsLimit =@InsLimit,
	StateCode=@StateCode,
	ZipCode=@ZipCode,
	EquipmentNotes=@EquipmentNotes,
	Status=@Status,
	LastModifiedBy=@LastModifiedBy,
	LastModifiedDateTime=@LastModifiedDateTime,
	City=@City,
	country=@country,

	website=@website,

	UpdatedByIP=@UpdatedByIP,
	notes=@notes,
	CarrierTerms=@CarrierTerms,
	VendorID=@VendorID,
	DOTNumber=@DOTNumber,
	SaferWatch=@SaferWatch,
	RiskAssessment=@RiskAssessment,
	MobileAppPassword=@MobileAppPassword,
	isShowDollar=@isShowDollar,
	ContactHow=@ContactHow,
	LoadLimit=@LoadLimit,
	DefaultCurrency=@DefaultCurrency,
	CarrierEmailAvailableLoads=@CarrierEmailAvailableLoads,
	DispatchFee=@DispatchFee,
	MyCarrierPackets=@MyCarrierPackets,
	SCAC=@SCAC,
	Memo=@Memo,
	InsCompanyCargo=@InsCompanyCargo,
	InsCompPhoneCargo=@InsCompPhoneCargo,
	InsAgentCargo=@InsAgentCargo,
	InsAgentPhoneCargo=@InsAgentPhoneCargo,
	InsPolicyNumberCargo=@InsPolicyNumberCargo,
	InsExpDateCargo=@InsExpDateCargo,
	InsLimitCargo=@InsLimitCargo,
	InsCompanyGeneral=@InsCompanyGeneral,
	InsCompPhoneGeneral=@InsCompPhoneGeneral,
	InsAgentGeneral=@InsAgentGeneral,
	InsAgentPhoneGeneral=@InsAgentPhoneGeneral,
	InsPolicyNumberGeneral=@InsPolicyNumberGeneral,
	InsExpDateGeneral=@InsExpDateGeneral,
	InsLimitGeneral=@InsLimitGeneral,

	InsEmail=@InsEmail,
	InsEmailCargo=@InsEmailCargo,
	InsEmailGeneral=@InsEmailGeneral,
	employeeType=@employeeType,
	FactoringID=@FactoringID,
	ContactPerson=@ContactPerson,
	Phone=@Phone,
	Fax=@Fax,
	Cel=@Cel,
	EmailID=@EmailID,
	Tollfree=@Tollfree,
	PhoneExt=@PhoneExt,
	FaxExt=@FaxExt,
	TollFreeExt=@TollFreeExt,
	CellPhoneExt=@CellPhoneExt,
	RatePerMile=@RatePerMile,
	RemitEmail=@RemitEmail,
	FF=@FF,
	DispatchFeeAmount=@DispatchFeeAmount
	WHERE CarrierID = @CarrierID

	IF(SELECT COUNT(*) FROM lipublicfmcsa WHERE carrierId = @CarrierID)=0
		BEGIN
			INSERT INTO lipublicfmcsa(
				InsuranceCompanyAddress,
				carrierId,
				ExpirationDate,
				DateCreated,
				commonStatus,
				contractStatus,
				BrokerStatus,
				commonAppPending,
				contractAppPending,
				BrokerAppPending,
				BIPDInsRequired,
				cargoInsRequired,
				BIPDInsonFile,
				cargoInsonFile,
				householdGoods,
				CARGOExpirationDate,
				InsuranceCompanyAddressCargo,
				householdGoodsCargo,
				InsuranceCompanyAddressGeneral,
				householdGoodsGeneral
				)
			VALUES(
				@InsuranceCompanyAddress,
				@carrierId,
				@ExpirationDate,
				GETDATE(),
				@commonStatus,
				@contractStatus,
				@BrokerStatus,
				@commonAppPending,
				@contractAppPending,
				@BrokerAppPending,
				@BIPDInsRequired,
				@cargoInsRequired,
				@BIPDInsonFile,
				@cargoInsonFile,
				@householdGoods,
				@CARGOExpirationDate,
				@InsuranceCompanyAddressCargo,
				@householdGoodsCargo,
				@InsuranceCompanyAddressGeneral,
				@householdGoodsGeneral
			)
		END
	ELSE
		BEGIN
			UPDATE lipublicfmcsa SET
			InsuranceCompanyAddress=InsuranceCompanyAddress,
			ExpirationDate=ExpirationDate,
			DateModified=GETDATE(),
			commonStatus=commonStatus,
			contractStatus = @contractStatus,
			BrokerStatus= @BrokerStatus,
			commonAppPending= @commonAppPending,
			contractAppPending=  @contractAppPending,
			BrokerAppPending=  @BrokerAppPending,
			BIPDInsRequired= @BIPDInsRequired,
			cargoInsRequired= @cargoInsRequired,
			BIPDInsonFile=@BIPDInsonFile,
			cargoInsonFile= @cargoInsonFile,
			householdGoods= @householdGoods,
			CARGOExpirationDate= @CARGOExpirationDate,
			InsuranceCompanyAddressCargo= @InsuranceCompanyAddressCargo,
			householdGoodsCargo= @householdGoodsCargo,
			InsuranceCompanyAddressGeneral= @InsuranceCompanyAddressGeneral,
			householdGoodsGeneral= @householdGoodsGeneral
			WHERE CarrierID = @CarrierID
		END
END


GO

/****** Object:  View [dbo].[vwSalesRepCommission]    Script Date: 08-04-2022 16:09:47 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




ALTER             VIEW [dbo].[vwSalesRepCommission]
AS
SELECT        TOP (100) PERCENT dbo.Companies.CompanyName,dbo.Companies.CompanyID, dbo.Employees.Name AS Dispatcher, ISNULL(NULLIF (Employees_1.Name, N''), N'(BLANK)') AS SalesAgent1, dbo.Loads.LoadNumber, 
                         dbo.LoadStops.StopDate AS OrderDate, UPPER(dbo.Loads.CustName) AS CustName, ISNULL(NULLIF (dbo.Loads.userDefinedFieldTrucking, ''), N'(BLANK)') AS userDefinedFieldTrucking, 
                         dbo.LoadStops.City + ', ' + dbo.LoadStops.StateCode AS FirstStop, dbo.vwCarrierConfirmationReportFinalDestination.City + ', ' + dbo.vwCarrierConfirmationReportFinalDestination.StateCode AS LastStop, 
                         
						 
						 dbo.Loads.TotalCarrierCharges-dbo.LoadStops.CustomDriverPayFlatRate2-dbo.LoadStops.CustomDriverPayFlatRate3 
						 -((dbo.LoadStops.CustomDriverPayPercentage2*dbo.Loads.TotalCustomerCharges)/100)-((dbo.LoadStops.CustomDriverPayPercentage3*dbo.Loads.TotalCustomerCharges)/100)
						 
						 AS TotalCarrierCharges,
						 
						 
						 dbo.Loads.BillDate, 
                         CASE WHEN dbo.SystemConfig.AutomaticFactoringFee = 0 THEN dbo.Loads.TotalCustomerCharges ELSE (dbo.Loads.TotalCustomerCharges - (dbo.Loads.TotalCustomerCharges * dbo.loads.FF / 100)) 
                         END AS TotalCustomerCharges, 


                         ISNULL(CASE WHEN dbo.SystemConfig.AutomaticFactoringFee = 0 THEN dbo.Loads.TotalCustomerCharges ELSE (dbo.Loads.TotalCustomerCharges - (dbo.Loads.TotalCustomerCharges * dbo.loads.FF / 100)) 
                         END - dbo.Loads.TotalCarrierCharges, 0) AS GrossMargin, 
						 
						 
						 dbo.Carriers.CarrierName, ISNULL(Employees_1.SalesCommission, 0) AS CommissionPercent, 
                         ISNULL((dbo.Loads.TotalCustomerCharges - dbo.Loads.TotalCarrierCharges) * (Employees_1.SalesCommission * .01), 0) AS CommissionAmt, dbo.LoadStatusTypes.StatusTypeID, dbo.LoadStatusTypes.StatusText, 
                         ISNULL(dbo.Equipments.EquipmentName, N'(BLANK)') AS EquiptName, dbo.Employees.SalesCommission AS DispatchCommissionPercent1, ISNULL((dbo.Loads.TotalCustomerCharges - dbo.Loads.TotalCarrierCharges) 
                         * (dbo.Employees.SalesCommission * .01), 0) AS DispatchCommissionAmt1, dbo.Carriers.CarrierName AS Driver, ISNULL(TRIM(dbo.Carriers.CarrierName), N'(BLANK)') AS Carrier, dbo.SystemConfig.FreightBroker, 
                         Employees_1.Name AS SalesAgent, ISNULL(dbo.vwSalesRepCommissionCarrierPay.Payments, 0) AS Payments, dbo.Loads.TotalCarrierCharges - ISNULL(dbo.vwSalesRepCommissionCarrierPay.Payments, 0)-dbo.LoadStops.CustomDriverPayFlatRate2-dbo.LoadStops.CustomDriverPayFlatRate3 AS CarrierPay, 
						 CASE WHEN systemconfig.dispatch = 1 THEN 
						 
							 ISNULL(dbo.Carriers.DispatchFee, 0) / 100 * dbo.Loads.TotalCarrierCharges
						 ELSE 
							ISNULL(Employees_1.SalesCommission, 0) / 100 * ISNULL(CASE WHEN dbo.SystemConfig.AutomaticFactoringFee = 0 THEN dbo.Loads.TotalCustomerCharges ELSE (dbo.Loads.TotalCustomerCharges - (dbo.Loads.TotalCustomerCharges * dbo.loads.FF / 100)) 
							END - dbo.Loads.TotalCarrierCharges, 0)
						 END AS CommissionAmountReport,
						 CASE WHEN systemconfig.dispatch = 1 THEN dbo.Carriers.DispatchFee ELSE ISNULL(Employees_1.SalesCommission, 0) 
                         END AS CommissionPercentReport, 
						 dbo.Carriers.DispatchFee AS DispatchCommissionPercent, 
                         ISNULL(dbo.Carriers.DispatchFee * (CASE WHEN dbo.SystemConfig.Dispatch = 1 THEN dbo.Loads.TotalCustomerCharges ELSE (dbo.Loads.TotalCustomerCharges - dbo.Loads.TotalCarrierCharges) END), 0) 
                         AS DispatchCommissionAmt, ISNULL(dbo.Loads.noOfTrips, 0) AS nooftrips, dbo.Loads.CreatedDateTime, dbo.Loads.NewDeliveryDate AS DeliveryDate,


						 systemconfig.dispatch AS IsDispatch,
						 CASE WHEN systemconfig.dispatch = 1 
						 THEN 
							CASE WHEN ISNULL(Carriers.DispatchFee,0) <> 0 THEN Loads.TotalCustomerCharges*(Carriers.DispatchFee/100) WHEN ISNULL(Carriers.DispatchFeeAmount,0) <> 0 AND Loads.TotalCustomerCharges <> 0 THEN Carriers.DispatchFeeAmount ELSE 0 END
						 ELSE 
							0
						 END AS DispatchFeeNew,

						 CASE WHEN systemconfig.dispatch = 1 
						 THEN 
							CASE WHEN ISNULL(Carriers.DispatchFee,0) <> 0 THEN Carriers.DispatchFee WHEN ISNULL(Carriers.DispatchFeeAmount,0) <> 0 AND Loads.TotalCustomerCharges <> 0 THEN (Carriers.DispatchFeeAmount*100)/Loads.TotalCustomerCharges ELSE 0 END
						 ELSE 
							0
						 END AS DispatchFeePercNew
						 ,dbo.SystemConfig.CompanyLogoName,dbo.Companies.CompanyCode,1 as sortField
						 ,dbo.Loads.HasLateStop
FROM            dbo.Employees AS Employees_1 RIGHT OUTER JOIN
                         dbo.LoadStatusTypes INNER JOIN
                         dbo.Loads INNER JOIN
                         dbo.LoadStops ON dbo.Loads.LoadID = dbo.LoadStops.LoadID INNER JOIN
                         dbo.vwCarrierConfirmationReportFinalDestination ON dbo.Loads.LoadID = dbo.vwCarrierConfirmationReportFinalDestination.LoadID ON dbo.LoadStatusTypes.StatusTypeID = dbo.Loads.StatusTypeID LEFT OUTER JOIN
                         dbo.vwSalesRepCommissionCarrierPay ON dbo.Loads.LoadID = dbo.vwSalesRepCommissionCarrierPay.LoadID LEFT OUTER JOIN
                         dbo.Equipments ON dbo.LoadStops.NewEquipmentID = dbo.Equipments.EquipmentID 
						 LEFT OUTER JOIN dbo.Carriers ON dbo.LoadStops.NewCarrierID = dbo.Carriers.CarrierID
						 ON Employees_1.EmployeeID = dbo.Loads.SalesRepID LEFT OUTER JOIN
                         dbo.Employees ON dbo.Loads.DispatcherID = dbo.Employees.EmployeeID INNER JOIN
						 dbo.Offices ON dbo.Offices.OfficeID = dbo.Employees.OfficeID INNER JOIN 
                         dbo.Companies ON dbo.Companies.CompanyID = dbo.Offices.CompanyID INNER JOIN 
                         dbo.SystemConfig ON  dbo.SystemConfig.CompanyID = dbo.Companies.CompanyID
WHERE        (dbo.LoadStops.LoadType = 1) AND (dbo.LoadStops.StopNo + 1 = 1)


UNION

SELECT        TOP (100) PERCENT dbo.Companies.CompanyName,dbo.Companies.CompanyID, dbo.Employees.Name AS Dispatcher, ISNULL(NULLIF (Employees_1.Name, N''), N'(BLANK)') AS SalesAgent1, dbo.Loads.LoadNumber, 
                         dbo.LoadStops.StopDate AS OrderDate, UPPER(dbo.Loads.CustName) AS CustName, ISNULL(NULLIF (dbo.Loads.userDefinedFieldTrucking, ''), N'(BLANK)') AS userDefinedFieldTrucking, 
                         dbo.LoadStops.City + ', ' + dbo.LoadStops.StateCode AS FirstStop, dbo.vwCarrierConfirmationReportFinalDestination.City + ', ' + dbo.vwCarrierConfirmationReportFinalDestination.StateCode AS LastStop, 
                         
						 (dbo.LoadStops.CustomDriverPayFlatRate2+ ((dbo.LoadStops.CustomDriverPayPercentage2*dbo.Loads.TotalCustomerCharges)/100)) AS TotalCarrierCharges,
						 
						 
						 dbo.Loads.BillDate, 
                         0 AS TotalCustomerCharges, 


                         0 AS GrossMargin, 
						 
						 
						 dbo.Carriers.CarrierName, ISNULL(Employees_1.SalesCommission, 0) AS CommissionPercent, 
                         ISNULL((dbo.Loads.TotalCustomerCharges - dbo.Loads.TotalCarrierCharges) * (Employees_1.SalesCommission * .01), 0) AS CommissionAmt, dbo.LoadStatusTypes.StatusTypeID, dbo.LoadStatusTypes.StatusText, 
                         ISNULL(dbo.Equipments.EquipmentName, N'(BLANK)') AS EquiptName, dbo.Employees.SalesCommission AS DispatchCommissionPercent1, ISNULL((dbo.Loads.TotalCustomerCharges - dbo.Loads.TotalCarrierCharges) 
                         * (dbo.Employees.SalesCommission * .01), 0) AS DispatchCommissionAmt1, dbo.Carriers.CarrierName AS Driver, ISNULL(TRIM(dbo.Carriers.CarrierName), N'(BLANK)') AS Carrier, dbo.SystemConfig.FreightBroker, 
                         Employees_1.Name AS SalesAgent, ISNULL(dbo.vwSalesRepCommissionCarrierPay.Payments, 0) AS Payments, dbo.LoadStops.CustomDriverPayFlatRate2 AS CarrierPay, 
						 CASE WHEN systemconfig.dispatch = 1 THEN 
						 
							 ISNULL(dbo.Carriers.DispatchFee, 0) / 100 * dbo.Loads.TotalCarrierCharges
						 ELSE 
							ISNULL(Employees_1.SalesCommission, 0) / 100 * ISNULL(CASE WHEN dbo.SystemConfig.AutomaticFactoringFee = 0 THEN dbo.Loads.TotalCustomerCharges ELSE (dbo.Loads.TotalCustomerCharges - (dbo.Loads.TotalCustomerCharges * dbo.loads.FF / 100)) 
							END - dbo.Loads.TotalCarrierCharges, 0)
						 END AS CommissionAmountReport,
						 CASE WHEN systemconfig.dispatch = 1 THEN dbo.Carriers.DispatchFee ELSE ISNULL(Employees_1.SalesCommission, 0) 
                         END AS CommissionPercentReport, 
						 dbo.Carriers.DispatchFee AS DispatchCommissionPercent, 
                         ISNULL(dbo.Carriers.DispatchFee * (CASE WHEN dbo.SystemConfig.Dispatch = 1 THEN dbo.Loads.TotalCustomerCharges ELSE (dbo.Loads.TotalCustomerCharges - dbo.Loads.TotalCarrierCharges) END), 0) 
                         AS DispatchCommissionAmt, ISNULL(dbo.Loads.noOfTrips, 0) AS nooftrips, dbo.Loads.CreatedDateTime, dbo.Loads.NewDeliveryDate AS DeliveryDate,


						 systemconfig.dispatch AS IsDispatch,
						 CASE WHEN systemconfig.dispatch = 1 
						 THEN 
							CASE WHEN ISNULL(Carriers.DispatchFee,0) <> 0 THEN Loads.TotalCustomerCharges*(Carriers.DispatchFee/100) WHEN ISNULL(Carriers.DispatchFeeAmount,0) <> 0 AND Loads.TotalCustomerCharges <> 0 THEN Carriers.DispatchFeeAmount ELSE 0 END
						 ELSE 
							0
						 END AS DispatchFeeNew,

						 CASE WHEN systemconfig.dispatch = 1 
						 THEN 
							CASE WHEN ISNULL(Carriers.DispatchFee,0) <> 0 THEN Carriers.DispatchFee WHEN ISNULL(Carriers.DispatchFeeAmount,0) <> 0 AND Loads.TotalCustomerCharges <> 0 THEN (Carriers.DispatchFeeAmount*100)/Loads.TotalCustomerCharges ELSE 0 END
						 ELSE 
							0
						 END AS DispatchFeePercNew
						 ,dbo.SystemConfig.CompanyLogoName,dbo.Companies.CompanyCode,2 as sortField
						 ,dbo.Loads.HasLateStop
FROM            dbo.Employees AS Employees_1 RIGHT OUTER JOIN
                         dbo.LoadStatusTypes INNER JOIN
                         dbo.Loads INNER JOIN
                         dbo.LoadStops ON dbo.Loads.LoadID = dbo.LoadStops.LoadID INNER JOIN
                         dbo.vwCarrierConfirmationReportFinalDestination ON dbo.Loads.LoadID = dbo.vwCarrierConfirmationReportFinalDestination.LoadID ON dbo.LoadStatusTypes.StatusTypeID = dbo.Loads.StatusTypeID LEFT OUTER JOIN
                         dbo.vwSalesRepCommissionCarrierPay ON dbo.Loads.LoadID = dbo.vwSalesRepCommissionCarrierPay.LoadID LEFT OUTER JOIN
                         dbo.Equipments ON dbo.LoadStops.NewEquipmentID = dbo.Equipments.EquipmentID 
						 LEFT OUTER JOIN dbo.Carriers ON dbo.LoadStops.NewCarrierID2 = dbo.Carriers.CarrierID 
						 ON Employees_1.EmployeeID = dbo.Loads.SalesRepID LEFT OUTER JOIN
                         dbo.Employees ON dbo.Loads.DispatcherID = dbo.Employees.EmployeeID INNER JOIN
						 dbo.Offices ON dbo.Offices.OfficeID = dbo.Employees.OfficeID INNER JOIN 
                         dbo.Companies ON dbo.Companies.CompanyID = dbo.Offices.CompanyID INNER JOIN 
                         dbo.SystemConfig ON  dbo.SystemConfig.CompanyID = dbo.Companies.CompanyID
WHERE        (dbo.LoadStops.LoadType = 1) AND (dbo.LoadStops.StopNo + 1 = 1) AND dbo.LoadStops.NewCarrierID2 IS NOT NULL




UNION

SELECT        TOP (100) PERCENT dbo.Companies.CompanyName,dbo.Companies.CompanyID, dbo.Employees.Name AS Dispatcher, ISNULL(NULLIF (Employees_1.Name, N''), N'(BLANK)') AS SalesAgent1, dbo.Loads.LoadNumber, 
                         dbo.LoadStops.StopDate AS OrderDate, UPPER(dbo.Loads.CustName) AS CustName, ISNULL(NULLIF (dbo.Loads.userDefinedFieldTrucking, ''), N'(BLANK)') AS userDefinedFieldTrucking, 
                         dbo.LoadStops.City + ', ' + dbo.LoadStops.StateCode AS FirstStop, dbo.vwCarrierConfirmationReportFinalDestination.City + ', ' + dbo.vwCarrierConfirmationReportFinalDestination.StateCode AS LastStop, 
                         
						 
						 (dbo.LoadStops.CustomDriverPayFlatRate3+ ((dbo.LoadStops.CustomDriverPayPercentage3*dbo.Loads.TotalCustomerCharges)/100)) AS TotalCarrierCharges,
						 
						 
						 dbo.Loads.BillDate, 
                         0 AS TotalCustomerCharges, 


                         0 AS GrossMargin, 
						 
						 
						 dbo.Carriers.CarrierName, ISNULL(Employees_1.SalesCommission, 0) AS CommissionPercent, 
                         ISNULL((dbo.Loads.TotalCustomerCharges - dbo.Loads.TotalCarrierCharges) * (Employees_1.SalesCommission * .01), 0) AS CommissionAmt, dbo.LoadStatusTypes.StatusTypeID, dbo.LoadStatusTypes.StatusText, 
                         ISNULL(dbo.Equipments.EquipmentName, N'(BLANK)') AS EquiptName, dbo.Employees.SalesCommission AS DispatchCommissionPercent1, ISNULL((dbo.Loads.TotalCustomerCharges - dbo.Loads.TotalCarrierCharges) 
                         * (dbo.Employees.SalesCommission * .01), 0) AS DispatchCommissionAmt1, dbo.Carriers.CarrierName AS Driver, ISNULL(TRIM(dbo.Carriers.CarrierName), N'(BLANK)') AS Carrier, dbo.SystemConfig.FreightBroker, 
                         Employees_1.Name AS SalesAgent, ISNULL(dbo.vwSalesRepCommissionCarrierPay.Payments, 0) AS Payments, dbo.LoadStops.CustomDriverPayFlatRate3 AS CarrierPay, 
						 CASE WHEN systemconfig.dispatch = 1 THEN 
						 
							 ISNULL(dbo.Carriers.DispatchFee, 0) / 100 * dbo.Loads.TotalCarrierCharges
						 ELSE 
							ISNULL(Employees_1.SalesCommission, 0) / 100 * ISNULL(CASE WHEN dbo.SystemConfig.AutomaticFactoringFee = 0 THEN dbo.Loads.TotalCustomerCharges ELSE (dbo.Loads.TotalCustomerCharges - (dbo.Loads.TotalCustomerCharges * dbo.loads.FF / 100)) 
							END - dbo.Loads.TotalCarrierCharges, 0)
						 END AS CommissionAmountReport,
						 CASE WHEN systemconfig.dispatch = 1 THEN dbo.Carriers.DispatchFee ELSE ISNULL(Employees_1.SalesCommission, 0) 
                         END AS CommissionPercentReport, 
						 dbo.Carriers.DispatchFee AS DispatchCommissionPercent, 
                         ISNULL(dbo.Carriers.DispatchFee * (CASE WHEN dbo.SystemConfig.Dispatch = 1 THEN dbo.Loads.TotalCustomerCharges ELSE (dbo.Loads.TotalCustomerCharges - dbo.Loads.TotalCarrierCharges) END), 0) 
                         AS DispatchCommissionAmt, ISNULL(dbo.Loads.noOfTrips, 0) AS nooftrips, dbo.Loads.CreatedDateTime, dbo.Loads.NewDeliveryDate AS DeliveryDate,


						 systemconfig.dispatch AS IsDispatch,
						 CASE WHEN systemconfig.dispatch = 1 
						 THEN 
							CASE WHEN ISNULL(Carriers.DispatchFee,0) <> 0 THEN Loads.TotalCustomerCharges*(Carriers.DispatchFee/100) WHEN ISNULL(Carriers.DispatchFeeAmount,0) <> 0 AND Loads.TotalCustomerCharges <> 0 THEN Carriers.DispatchFeeAmount ELSE 0 END
						 ELSE 
							0
						 END AS DispatchFeeNew,

						 CASE WHEN systemconfig.dispatch = 1 
						 THEN 
							CASE WHEN ISNULL(Carriers.DispatchFee,0) <> 0 THEN Carriers.DispatchFee WHEN ISNULL(Carriers.DispatchFeeAmount,0) <> 0 AND Loads.TotalCustomerCharges <> 0 THEN (Carriers.DispatchFeeAmount*100)/Loads.TotalCustomerCharges ELSE 0 END
						 ELSE 
							0
						 END AS DispatchFeePercNew
						 ,dbo.SystemConfig.CompanyLogoName,dbo.Companies.CompanyCode,3 as sortField
						 ,dbo.Loads.HasLateStop
FROM            dbo.Employees AS Employees_1 RIGHT OUTER JOIN
                         dbo.LoadStatusTypes INNER JOIN
                         dbo.Loads INNER JOIN
                         dbo.LoadStops ON dbo.Loads.LoadID = dbo.LoadStops.LoadID INNER JOIN
                         dbo.vwCarrierConfirmationReportFinalDestination ON dbo.Loads.LoadID = dbo.vwCarrierConfirmationReportFinalDestination.LoadID ON dbo.LoadStatusTypes.StatusTypeID = dbo.Loads.StatusTypeID LEFT OUTER JOIN
                         dbo.vwSalesRepCommissionCarrierPay ON dbo.Loads.LoadID = dbo.vwSalesRepCommissionCarrierPay.LoadID LEFT OUTER JOIN
                         dbo.Equipments ON dbo.LoadStops.NewEquipmentID = dbo.Equipments.EquipmentID 
						 LEFT OUTER JOIN dbo.Carriers ON dbo.LoadStops.NewCarrierID3 = dbo.Carriers.CarrierID 
						 ON Employees_1.EmployeeID = dbo.Loads.SalesRepID LEFT OUTER JOIN
                         dbo.Employees ON dbo.Loads.DispatcherID = dbo.Employees.EmployeeID INNER JOIN
						 dbo.Offices ON dbo.Offices.OfficeID = dbo.Employees.OfficeID INNER JOIN 
                         dbo.Companies ON dbo.Companies.CompanyID = dbo.Offices.CompanyID INNER JOIN 
                         dbo.SystemConfig ON  dbo.SystemConfig.CompanyID = dbo.Companies.CompanyID
WHERE        (dbo.LoadStops.LoadType = 1) AND (dbo.LoadStops.StopNo + 1 = 1) AND dbo.LoadStops.NewCarrierID3 IS NOT NULL

ORDER BY dbo.Loads.LoadNumber
GO


