IF NOT EXISTS (SELECT column_name FROM INFORMATION_SCHEMA.columns where table_name = 'Customers' and column_name = 'InternalNotes')
BEGIN
	ALTER TABLE Customers ADD InternalNotes varchar(1000);
END
GO

/****** Object:  StoredProcedure [dbo].[USP_GetCustomerDetails]    Script Date: 25-05-2022 15:43:25 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



ALTER           PROC [dbo].[USP_GetCustomerDetails]
(
@CustomerID varchar(200),
@CompanyID varchar(200)
)
AS
BEGIN

	SELECT 
	C.CustomerID
	,C.CustomerStatusID
	,C.CustomerCode
	,C.CustomerName
	,C.OfficeID
	,C.Location
	,C.City
	,C.Zipcode
	,C.ContactPerson
	,C.PersonMobileNo
	,C.PhoneNo
	,C.Email
	,C.Website
	,C.SalesRepID
	,C.AcctMGRID
	,C.LoadPotential
	,C.BestOpp
	,CAST(C.CustomerDirections AS NVARCHAR(MAX)) CustomerDirections
	,C.CustomerNotes
	,C.IsPayer
	,C.CreatedBy
	,C.LastModifiedBy
	,C.CreatedDateTime
	,C.LastModifiedDateTime
	,C.FinanceID
	,C.CreditLimit
	,C.Balance
	,C.Available
	,C.countryID
	,C.CreatedByIP
	,C.UpdatedByIP
	,CAST(C.GUID AS NVARCHAR(MAX)) GUID
	,ISNULL(C.RatePerMile,0) AS RatePrMile 
	,C.Fax
	,C.QBSales
	,C.QBPurchases
	,C.statecode
	,C.CarrierNotes
	,C.TollFree
	,C.username
	,C.password
	,C.RemitName
	,C.RemitAddress
	,C.RemitCity
	,C.RemitState
	,C.RemitZipcode
	,C.RemitContact
	,C.RemitFax
	,C.RemitPhone
	,C.AYBImport
	,C.InUseBy
	,C.InUseOn
	,C.SessionId
	,C.DefaultCurrency
	,C.MCNumber
	,C.DOTNumber
	,C.PhoneNoExt
	,C.FaxExt
	,C.TollfreeExt
	,C.MobileNoExt
	,C.EDIPartnerID
	,C.CustomerTerms
	,C.ConsolidateInvoices
	,C.Project44ApiUsername
	,C.Project44ApiPassword
	,C.SeperateJobPo
	,C.PushDataToProject44Api
	,C.FactoringID
	,C.CRMCallFrequency
	,C.CRMLastCallDate
	,C.CRMNextCallDate
	,C.TimeZone
	,C.LockSalesAgentOnLoad
	,C.LockDispatcherOnLoad
	,C.IncludeIndividualInvoices
	,(SELECT STUFF((SELECT ',' + CAST(CO1.officeid AS VARCHAR(MAX)) FROM CustomerOffices CO1 WHERE CO1.CustomerID = C.customerid FOR XML PATH('')),1,1,'') ) AS MultipleOfficeIDs
	,(SELECT STUFF((SELECT ';' + O1.[Location] FROM CustomerOffices CO1 INNER JOIN Offices O1 on O1.OfficeID = CO1.OfficeID WHERE CO1.CustomerID = C.customerid FOR XML PATH('')),1,1,'')) AS OfficeLocations
	,(SELECT COUNT(L.LoadID) from Loads L where L.CustomerID = C.CustomerID) as LoadCount
	,C.ConsolidateInvoiceBOL,C.ConsolidateInvoiceRef,C.ConsolidateInvoiceDate
	,C.CRMContactID
	,C.CRMPhoneNo
	,C.CRMPhoneNOExt
	,C.CRMFax
	,C.CRMFaxExt
	,C.CRMTollFree
	,C.CRMTollFreeExt
	,C.CRMCell
	,C.CRMCellExt
	,C.CRMEmail
	,C.CRMNoteType
	,C.CRMRepeatInterval
	,C.CRMUser
	,C.BillFromCompany
	,C.InternalNotes
	FROM Customers C
	INNER JOIN CustomerOffices CO ON C.CustomerID = CO.CustomerID
	INNER JOIN Offices O ON O.OfficeID = CO.OfficeID
	WHERE O.CompanyID = @CompanyID AND C.CustomerID = CASE WHEN @CustomerID='' THEN C.customerID ELSE @CustomerID END

	GROUP BY C.CustomerID
	,C.CustomerStatusID
	,C.CustomerCode
	,C.CustomerName
	,C.OfficeID
	,C.Location
	,C.City
	,C.Zipcode
	,C.ContactPerson
	,C.PersonMobileNo
	,C.PhoneNo
	,C.Email
	,C.Website
	,C.SalesRepID
	,C.AcctMGRID
	,C.LoadPotential
	,C.BestOpp
	, CAST(C.CustomerDirections AS NVARCHAR(MAX))
	,C.CustomerNotes
	,C.IsPayer
	,C.CreatedBy
	,C.LastModifiedBy
	,C.CreatedDateTime
	,C.LastModifiedDateTime
	,C.FinanceID
	,C.CreditLimit
	,C.Balance
	,C.Available
	,C.countryID
	,C.CreatedByIP
	,C.UpdatedByIP
	,CAST(C.GUID AS NVARCHAR(MAX))
	,C.RatePerMile
	,C.Fax
	,C.QBSales
	,C.QBPurchases
	,C.statecode
	,C.CarrierNotes
	,C.TollFree
	,C.username
	,C.password
	,C.RemitName
	,C.RemitAddress
	,C.RemitCity
	,C.RemitState
	,C.RemitZipcode
	,C.RemitContact
	,C.RemitFax
	,C.RemitPhone
	,C.AYBImport
	,C.InUseBy
	,C.InUseOn
	,C.SessionId
	,C.DefaultCurrency
	,C.MCNumber
	,C.DOTNumber
	,C.PhoneNoExt
	,C.FaxExt
	,C.TollfreeExt
	,C.MobileNoExt
	,C.EDIPartnerID
	,C.CustomerTerms
	,C.ConsolidateInvoices
	,C.Project44ApiUsername
	,C.Project44ApiPassword
	,C.SeperateJobPo
	,C.PushDataToProject44Api
	,C.FactoringID
	,C.CRMCallFrequency
	,C.CRMLastCallDate
	,C.CRMNextCallDate
	,C.TimeZone
	,C.LockSalesAgentOnLoad
	,C.LockDispatcherOnLoad
	,C.IncludeIndividualInvoices
	,C.ConsolidateInvoiceBOL,C.ConsolidateInvoiceRef,C.ConsolidateInvoiceDate
	,C.CRMContactID
	,C.CRMPhoneNo
	,C.CRMPhoneNOExt
	,C.CRMFax
	,C.CRMFaxExt
	,C.CRMTollFree
	,C.CRMTollFreeExt
	,C.CRMCell
	,C.CRMCellExt
	,C.CRMEmail
	,C.CRMNoteType
	,C.CRMRepeatInterval
	,C.CRMUser
	,C.BillFromCompany
	,C.InternalNotes
	ORDER BY CustomerName
END
GO



GO

/****** Object:  StoredProcedure [dbo].[USP_InsertCustomer]    Script Date: 25-05-2022 15:45:36 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER     Procedure [dbo].[USP_InsertCustomer]
(
@CustomerStatusID as int,
@CustomerCode as nvarchar(40),
@CustomerName as nvarchar(100),
@OfficeID1 as nvarchar(100),  
@Location as nvarchar(100), 
@City as nvarchar(50),
@State1 as nvarchar(100),
@Zipcode as nvarchar(50),
@website as nvarchar(50),
@salesperson as nvarchar(100)= null,
@Dispatcher as  nvarchar(100)= null,  
@LoadPotential as nvarchar(50),
@BestOpp as nvarchar(100),
@CustomerDirections as ntext,
@CustomerNotes as nvarchar(1000),
@IsPayer as bit,
@createdBy as nvarchar(20) ,
@FinanceID as varchar(20),
@creditLimit as money,
@Balance as money,
@available as money,
@RatePerMile as money,
@country1 as varchar(150),
@remoteAddress as varchar(100),
@ipaddress as varchar(100),
@CarrierNotes as nvarchar(4000),
@RemitName as varchar(100),
@RemitAddress as varchar(200),
@RemitCity as nvarchar(50),
@RemitState as nchar(2),
@RemitZipcode as nvarchar(20),
@RemitContact as varchar(150),
@RemitFax as varchar(150),
@RemitPhone as varchar(150),
@UserName as varchar(50),
@Password as varchar(50),
@DefaultCurrency as int,
@DOTNumber as nvarchar(50),
@MCNumber as nvarchar(50),
@EDIPartnerID as varchar(50),
@CustomerTerms as nvarchar(4000),
@ConsolidateInvoices as bit,
@SeperateJobPo as bit,
@FactoringID as varchar(250),
@TimeZone as varchar(25),
@LockSalesAgentOnLoad as bit,
@LockDispatcherOnLoad as bit,
@IncludeIndividualInvoices as bit,
@contactperson varchar(50),
@PhoneNo varchar(50),
@PhoneNoExt varchar(50),
@Tollfree varchar(50),
@TollfreeExt varchar(50),
@PersonMobileNo varchar(50),
@MobileNoExt varchar(50),
@Fax varchar(50),
@FaxExt varchar(50),
@Email  varchar(max),
@ConsolidateInvoiceBOL as bit,
@ConsolidateInvoiceRef as bit,
@ConsolidateInvoiceDate as bit,
@BillFromCompany varchar(36),
@InternalNotes varchar(1000)
)
as
begin
declare @customerId uniqueidentifier
Set @customerId = NewID()
if @salesperson = ''
set @salesperson = null
if @Dispatcher = ''
set @Dispatcher = null
if @State1 = ''
set @State1 = null
if @CarrierNotes = ''
set @CarrierNotes = null
if @RemitName = ''
set @RemitName = null
if @RemitAddress = ''
set @RemitAddress = null
if @RemitCity = ''
set @RemitCity = null
if @RemitState = ''
set @RemitState = null
if @RemitZipcode = ''
set @RemitZipcode = null
if @RemitContact = ''
set @RemitContact = null
if @RemitFax = ''
set @RemitFax = null
if @RemitPhone = ''
set @RemitPhone = null
IF @IsPayer = 'False' 
BEGIN
    set @UserName = null
    set @Password = null
END
If @EDIPartnerID = ''
set @EDIPartnerID = null
if @CustomerTerms = ''
set @CustomerTerms = null
insert into 
Customers(CustomerId,CustomerStatusID,CustomerCode,CustomerName,OfficeID,Location,City,statecode,Zipcode,Website,SalesRepID,AcctMGRID,LoadPotential,BestOpp,CustomerDirections,CustomerNotes,IsPayer,CreatedBy,LastModifiedBy,CreatedDateTime,LastModifiedDateTime,FinanceID,CreditLimit,Balance,Available,RatePerMile,CountryID,CreatedByIP,GUID,CarrierNotes,RemitName,RemitAddress,RemitCity,RemitState,RemitZipcode,RemitContact,RemitFax,RemitPhone,UserName,Password,DefaultCurrency,DOTNumber,MCNumber,EDIPartnerID,CustomerTerms,ConsolidateInvoices,SeperateJobPo,FactoringID,TimeZone,LockSalesAgentOnLoad,LockDispatcherOnLoad,IncludeIndividualInvoices,contactperson,PhoneNo,PhoneNoExt,Tollfree,TollfreeExt,PersonMobileNo,MobileNoExt,Fax,FaxExt,Email,ConsolidateInvoiceBOL,ConsolidateInvoiceRef,ConsolidateInvoiceDate,BillFromCompany,InternalNotes)
values(
@customerId,
@CustomerStatusID,
@CustomerCode,
@CustomerName,
@OfficeID1,  
@Location, 
@City,
@State1,
@Zipcode,
@website,
@salesperson,
@Dispatcher,  
@LoadPotential,
@BestOpp,
@CustomerDirections,
@CustomerNotes,
@IsPayer,
@createdBy,
@createdBy,
GETDATE(),
GETDATE(),
@FinanceID,
@creditLimit,
@Balance,
@available,
@RatePerMile,
@country1,
@remoteAddress,
@ipaddress,
@CarrierNotes,
@RemitName,
@RemitAddress,
@RemitCity,
@RemitState,
@RemitZipcode,
@RemitContact,
@RemitFax,
@RemitPhone,
@UserName,
@Password,
@DefaultCurrency,
@DOTNumber,
@MCNumber,
@EDIPartnerID,
@CustomerTerms,
@ConsolidateInvoices,
@SeperateJobPo,
@FactoringID,
@TimeZone,
@LockSalesAgentOnLoad,
@LockDispatcherOnLoad,
@IncludeIndividualInvoices,
@contactperson,@PhoneNo,@PhoneNoExt,@Tollfree,@TollfreeExt,@PersonMobileNo,@MobileNoExt,@Fax,@FaxExt,@Email,@ConsolidateInvoiceBOL,@ConsolidateInvoiceRef,@ConsolidateInvoiceDate,@BillFromCompany
,@InternalNotes
)

select @customerId as lastInsertedCustomerid
end


GO


GO

/****** Object:  StoredProcedure [dbo].[USP_UpdateCustomer]    Script Date: 25-05-2022 15:46:29 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER       PROCEDURE [dbo].[USP_UpdateCustomer]
(	
	@CustomerID AS nvarchar(50),
	@CustomerStatusID as int,
	@CustomerCode as nvarchar(40),
	@CustomerName as nvarchar(100),
	@Location as nvarchar(100), 
	@City as nvarchar(50),
	@State1 as nvarchar(100),
	@Zipcode as nvarchar(50),
	@website as nvarchar(50),
	@salesperson as nvarchar(100)= null,
	@Dispatcher as  nvarchar(100)= null,  
	@EDIPartnerID as varchar(50),
	@LoadPotential as nvarchar(50),
	@BestOpp as nvarchar(100),
	@CustomerDirections as ntext,
	@CustomerNotes as nvarchar(1000),
	@IsPayer as bit,
	@updatedBy as nvarchar(20) ,
	@FinanceID as varchar(20),
	@creditLimit as money,
	@Balance as money,
	@available as money,
	@RatePerMile as money,
	@country1 as varchar(150),
	@ipaddress as varchar(100),
	@CarrierNotes as nvarchar(4000),
	@RemitName as varchar(100),
	@RemitAddress as varchar(200),
	@RemitCity as nvarchar(50),
	@RemitState as nchar(2),
	@RemitZipcode as nvarchar(20),
	@RemitContact as varchar(150),
	@RemitPhone as varchar(150),
	@RemitFax as varchar(150),
	@UserName as varchar(50),
	@Password as varchar(50),
	@DefaultCurrency as int,
	@CustomerTerms as nvarchar(4000),
	@MCNumber as nvarchar(50),
	@DOTNumber as nvarchar(50),
	@ConsolidateInvoices as bit,
	@SeperateJobPo as bit,
	@FactoringID as varchar(250),
	@TimeZone as varchar(25),
	@LockSalesAgentOnLoad as bit,
	@LockDispatcherOnLoad as bit,
	@IncludeIndividualInvoices as bit,
	@contactperson varchar(50),
	@PhoneNo varchar(50),
	@PhoneNoExt varchar(50),
	@Tollfree varchar(50),
	@TollfreeExt varchar(50),
	@PersonMobileNo varchar(50),
	@MobileNoExt varchar(50),
	@Fax varchar(50),
	@FaxExt varchar(50),
	@Email  varchar(max),
	@ConsolidateInvoiceBOL as bit,
	@ConsolidateInvoiceRef as bit,
	@ConsolidateInvoiceDate as bit,
	@BillFromCompany varchar(36),
	@InternalNotes varchar(1000)
)
AS
BEGIN
	UPDATE Customers SET
		CustomerStatusID=@CustomerStatusID,
		CustomerCode=@CustomerCode,
		CustomerName=@CustomerName,
		Location=@Location, 
		City=@City,
		statecode=@State1,
		Zipcode=@Zipcode,
		Website=@website,
		SalesRepID=@salesperson,
		AcctMGRID=@Dispatcher,  
		EDIPartnerID=@EDIPartnerID,
		LoadPotential=@LoadPotential,
		BestOpp=@BestOpp,
		CustomerDirections=@CustomerDirections,
		CustomerNotes=@CustomerNotes,
		IsPayer=@IsPayer,
		LastModifiedBy=@updatedBy,
		LastModifiedDateTime=GETDATE(),
		FinanceID=@FinanceID ,
		CreditLimit=@creditLimit,
		Balance=@Balance,
		Available=@available,
		RatePerMile=@RatePerMile,
		countryID=@country1,
		UpdatedByIP=@ipaddress,
		CarrierNotes=@CarrierNotes,
		RemitName=@RemitName,
		RemitAddress=@RemitAddress,
		RemitCity=@RemitCity,
		RemitState=@RemitState,
		RemitZipcode=@RemitZipcode ,
		RemitContact=@RemitContact,
		RemitPhone=@RemitPhone,
		RemitFax=@RemitFax,
		UserName=@UserName,
		Password=@Password,
		DefaultCurrency=@DefaultCurrency,
		CustomerTerms=@CustomerTerms,
		MCNumber=@MCNumber,
		DOTNumber=@DOTNumber,
		ConsolidateInvoices=@ConsolidateInvoices,
		SeperateJobPo=@SeperateJobPo,
		FactoringID=@FactoringID,
		TimeZone=@TimeZone,
		LockSalesAgentOnLoad=@LockSalesAgentOnLoad,
		LockDispatcherOnLoad=@LockDispatcherOnLoad,
		IncludeIndividualInvoices=@IncludeIndividualInvoices,
		contactperson=@contactperson,
		PhoneNo=@PhoneNo,
		PhoneNoExt=@PhoneNoExt,
		Tollfree=@Tollfree,
		TollfreeExt=@TollfreeExt,
		PersonMobileNo=@PersonMobileNo,
		MobileNoExt=@MobileNoExt,
		Fax=@Fax,
		FaxExt=@FaxExt,
		Email=@Email,
		ConsolidateInvoiceBOL=@ConsolidateInvoiceBOL,
		ConsolidateInvoiceRef=@ConsolidateInvoiceRef,
		ConsolidateInvoiceDate=@ConsolidateInvoiceDate,
		BillFromCompany=@BillFromCompany,
		InternalNotes=@InternalNotes
	WHERE CustomerID = @CustomerID
END
								

GO


