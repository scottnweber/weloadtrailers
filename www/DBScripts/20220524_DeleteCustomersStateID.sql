IF EXISTS (SELECT column_name FROM INFORMATION_SCHEMA.columns where table_name = 'Customers' and column_name = 'StateID')
BEGIN
	ALTER TABLE Customers DROP COLUMN StateID;
END
GO

/****** Object:  StoredProcedure [dbo].[searchCustomer]    Script Date: 24-05-2022 10:42:23 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER           proc [dbo].[searchCustomer]
@searchText nvarchar(255),
@PageIndex integer,
@PageSize integer,
@sortOrder nvarchar(255),
@sortBy nvarchar(255),
@searchPayer nvarchar(1),
@officeid nvarchar(MAX),
@companyid nvarchar(MAX) ,
@pending bit,
@showAllOfficeCustomers bit
AS
DECLARE @defPayer nvarchar(15)
SET @defPayer='0 and IsPayer=1'

BEGIN
	CREATE TABLE #FA_Temp(AttachmentTypeID VARCHAR(60),linked_Id  VARCHAR(60));
	INSERT INTO #FA_Temp
	select  FA.AttachmentTypeID,FA.linked_Id from FileAttachments FA
				INNER JOIN Customers  ON FA.linked_Id = CAST(customers.customerid as varchar(50))
				INNER JOIN CustomerOffices CO ON Customers.CustomerID = CO.CustomerID
				INNER JOIN Offices O ON O.OfficeID = CO.OfficeID
				WHERE O.CompanyID = @companyid AND FA.AttachmentTypeID IS NOT NULL;

	WITH page AS ( 
		SELECT 
			Customers.CustomerID
			,Customers.CustomerStatusID
			,Customers.CustomerCode
			,Customers.CustomerName
			,Customers.OfficeID
			,Customers.Location
			,Customers.City
			,Customers.Zipcode
			,Customers.ContactPerson
			,Customers.PersonMobileNo
			,Customers.PhoneNo
			,Customers.Email
			,Customers.Website
			,Customers.SalesRepID
			,Customers.AcctMGRID
			,Customers.LoadPotential
			,Customers.BestOpp
			,CAST(Customers.CustomerDirections AS NVARCHAR(MAX)) CustomerDirections
			,Customers.CustomerNotes
			,Customers.IsPayer
			,Customers.CreatedBy
			,Customers.LastModifiedBy
			,Customers.CreatedDateTime
			,Customers.LastModifiedDateTime
			,Customers.FinanceID
			,Customers.CreditLimit
			,Customers.Balance
			,Customers.Available
			,Customers.countryID
			,Customers.CreatedByIP
			,Customers.UpdatedByIP
			,CAST(Customers.GUID AS NVARCHAR(MAX)) GUID
			,ISNULL(Customers.RatePerMile,0) AS RatePerMile 
			,Customers.Fax
			,Customers.QBSales
			,Customers.QBPurchases
			,Customers.statecode
			,Customers.CarrierNotes
			,Customers.TollFree
			,Customers.username
			,Customers.password
			,Customers.RemitName
			,Customers.RemitAddress
			,Customers.RemitCity
			,Customers.RemitState
			,Customers.RemitZipcode
			,Customers.RemitContact
			,Customers.RemitFax
			,Customers.RemitPhone
			,Customers.AYBImport
			,Customers.InUseBy
			,Customers.InUseOn
			,Customers.SessionId
			,Customers.DefaultCurrency
			,Customers.MCNumber
			,Customers.DOTNumber
			,Customers.PhoneNoExt
			,Customers.FaxExt
			,Customers.TollfreeExt
			,Customers.MobileNoExt
			,Customers.EDIPartnerID
			,Customers.CustomerTerms
			,Customers.ConsolidateInvoices
			,Customers.Project44ApiUsername
			,Customers.Project44ApiPassword
			,Customers.SeperateJobPo
			,Customers.PushDataToProject44Api
			,Customers.FactoringID
			,Customers.CRMCallFrequency
			,Customers.CRMLastCallDate
			,Customers.CRMNextCallDate
			,Customers.TimeZone
			,Customers.LockSalesAgentOnLoad
			,Customers.LockDispatcherOnLoad
			,Customers.IncludeIndividualInvoices
			,(SELECT STUFF((SELECT ',' + CAST(CO1.officeid AS VARCHAR(MAX)) FROM CustomerOffices CO1 WHERE CO1.CustomerID = Customers.customerid FOR XML PATH('')),1,1,'') ) AS MultipleOfficeIDs
			,(SELECT STUFF((SELECT ';' + O1.[Location] FROM CustomerOffices CO1 INNER JOIN Offices O1 on O1.OfficeID = CO1.OfficeID WHERE CO1.CustomerID = Customers.customerid FOR XML PATH('')),1,1,'')) AS OfficeLocation
			,Dispatchers.Name as Dispatcher
			,SalesAgents.name as SalesAgent
			,ROW_NUMBER() OVER (ORDER BY 
				CASE WHEN @sortBy = 'CustomerName' and @sortOrder = 'ASC' 
					THEN CustomerName END ASC, 
				CASE WHEN @sortBy = 'CustomerName' and @SortOrder = 'DESC' 
					THEN CustomerName END DESC,

				CASE WHEN @sortBy = 'address' and @SortOrder = 'DESC' 
					THEN customers.Location END DESC,
				CASE WHEN @sortBy = 'address' and @SortOrder = 'ASC' 
					THEN customers.Location END ASC,

				CASE WHEN @sortBy = 'phoneNo' and @SortOrder = 'DESC' 
					THEN PhoneNo END DESC,
				CASE WHEN @sortBy = 'phoneNo' and @SortOrder = 'ASC' 
					THEN PhoneNo END ASC,

				/*CASE WHEN @sortBy = 'office' and @SortOrder = 'DESC' 
					THEN offices.location END DESC,
				CASE WHEN @sortBy = 'office' and @SortOrder = 'ASC' 
					THEN offices.location END ASC,*/

				CASE WHEN @sortBy = 'status' and @SortOrder = 'DESC' 
					THEN CustomerStatusId END DESC,
				CASE WHEN @sortBy = 'status' and @SortOrder = 'ASC' 
					THEN CustomerStatusId END ASC,

				CASE WHEN @sortBy = 'city' and @SortOrder = 'DESC' 
					THEN customers.city END DESC,
				CASE WHEN @sortBy = 'city' and @SortOrder = 'ASC' 
					THEN customers.city END ASC,

				CASE WHEN @sortBy = 'stateCode' and @SortOrder = 'DESC' 
					THEN customers.stateCode END DESC,
				CASE WHEN @sortBy = 'stateCode' and @SortOrder = 'ASC' 
					THEN customers.stateCode END ASC,

				CASE WHEN @sortBy = 'zipCode' and @SortOrder = 'DESC' 
					THEN customers.zipCode END DESC,
				CASE WHEN @sortBy = 'zipCode' and @SortOrder = 'ASC' 
					THEN customers.zipCode END ASC,

				CASE WHEN @sortBy = 'CRMNextCallDate' and @SortOrder = 'DESC' 
					THEN customers.CRMNextCallDate END DESC,
				CASE WHEN @sortBy = 'CRMNextCallDate' and @SortOrder = 'ASC' 
					THEN customers.CRMNextCallDate END ASC,

				CASE WHEN @sortBy = 'SalesAgent' and @SortOrder = 'DESC' 
					THEN SalesAgents.Name END DESC,
				CASE WHEN @sortBy = 'SalesAgent' and @SortOrder = 'ASC' 
					THEN SalesAgents.Name END ASC,

				CASE WHEN @sortBy = 'Dispatcher' and @SortOrder = 'DESC' 
					THEN Dispatchers.Name END DESC,
				CASE WHEN @sortBy = 'Dispatcher' and @SortOrder = 'ASC' 
					THEN Dispatchers.Name  END ASC
			) AS Row

		FROM Customers 
		INNER JOIN CustomerOffices CO ON Customers.CustomerID = CO.CustomerID
		INNER JOIN Offices O ON O.OfficeID = CO.OfficeID
		LEFT JOIN Employees Dispatchers on Dispatchers.EmployeeID = Customers.AcctMGRID
		LEFT JOIN Employees SalesAgents on SalesAgents.EmployeeID = Customers.SalesRepID
		
		WHERE O.CompanyID = @companyid

		AND 
		(CustomerName like '%'+@searchText+'%'
		or customers.Location like '%'+@searchText+'%'
		or PhoneNo like '%'+@searchText+'%'
		--or offices.location like '%'+@searchText+'%' 
		or SalesAgents.Name like '%'+@searchText+'%' 
		or Dispatchers.Name like '%'+@searchText+'%' )

		AND O.OfficeID = CASE WHEN @officeid='' OR @showAllOfficeCustomers = 1 THEN O.OfficeID ELSE  @officeid  END
		
		AND IsPayer = CASE WHEN @searchPayer <> 2 THEN  @searchPayer ELSE IsPayer END

		AND (@pending = 0 OR 
				(@pending = 1  
				AND  (select count(Att.AttachmentTypeID) from FileAttachmentTypes Att where Att.CompanyID = @companyid AND Att.AttachmentType = 'Customer' and Att.Required = 1 
				and  Att.AttachmentTypeID not in (select MFA.AttachmentTypeID from FileAttachments FA
				inner join MultipleFileAttachmentsTypes MFA ON FA.attachment_Id = MFA.AttachmentID
				where FA.linked_Id=CAST(customers.customerid as varchar(50))) 
				) > 0
				))
		GROUP BY Customers.CustomerID
		,Customers.CustomerStatusID
		,Customers.CustomerCode
		,Customers.CustomerName
		,Customers.OfficeID
		,Customers.Location
		,Customers.City
		,Customers.Zipcode
		,Customers.ContactPerson
		,Customers.PersonMobileNo
		,Customers.PhoneNo
		,Customers.Email
		,Customers.Website
		,Customers.SalesRepID
		,Customers.AcctMGRID
		,Customers.LoadPotential
		,Customers.BestOpp
		, CAST(Customers.CustomerDirections AS NVARCHAR(MAX))
		,Customers.CustomerNotes
		,Customers.IsPayer
		,Customers.CreatedBy
		,Customers.LastModifiedBy
		,Customers.CreatedDateTime
		,Customers.LastModifiedDateTime
		,Customers.FinanceID
		,Customers.CreditLimit
		,Customers.Balance
		,Customers.Available
		,Customers.countryID
		,Customers.CreatedByIP
		,Customers.UpdatedByIP
		,CAST(Customers.GUID AS NVARCHAR(MAX))
		,Customers.RatePerMile
		,Customers.Fax
		,Customers.QBSales
		,Customers.QBPurchases
		,Customers.statecode
		,Customers.CarrierNotes
		,Customers.TollFree
		,Customers.username
		,Customers.password
		,Customers.RemitName
		,Customers.RemitAddress
		,Customers.RemitCity
		,Customers.RemitState
		,Customers.RemitZipcode
		,Customers.RemitContact
		,Customers.RemitFax
		,Customers.RemitPhone
		,Customers.AYBImport
		,Customers.InUseBy
		,Customers.InUseOn
		,Customers.SessionId
		,Customers.DefaultCurrency
		,Customers.MCNumber
		,Customers.DOTNumber
		,Customers.PhoneNoExt
		,Customers.FaxExt
		,Customers.TollfreeExt
		,Customers.MobileNoExt
		,Customers.EDIPartnerID
		,Customers.CustomerTerms
		,Customers.ConsolidateInvoices
		,Customers.Project44ApiUsername
		,Customers.Project44ApiPassword
		,Customers.SeperateJobPo
		,Customers.PushDataToProject44Api
		,Customers.FactoringID
		,Customers.CRMCallFrequency
		,Customers.CRMLastCallDate
		,Customers.CRMNextCallDate
		,Customers.TimeZone
		,Customers.LockSalesAgentOnLoad
		,Customers.LockDispatcherOnLoad
		,Customers.IncludeIndividualInvoices
		,Dispatchers.Name
		,SalesAgents.Name
	)
	
	SELECT *,(select (max(row)/@PageSize) + (CASE WHEN max(row)%@PageSize <> 0 THEN 1 ELSE 0 END)  FROM page) AS TotalPages FROM page WHERE Row between (@PageIndex - 1) * @PageSize + 1 and @PageIndex*@PageSize
	DROP TABLE #FA_Temp;
END

GO


GO

/****** Object:  StoredProcedure [dbo].[USP_GetCustomerDetails]    Script Date: 24-05-2022 10:41:18 ******/
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
	ORDER BY CustomerName
END
GO


