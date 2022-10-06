GO

/****** Object:  StoredProcedure [dbo].[USP_GetCustomerReport]    Script Date: 27-09-2022 09:56:08 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
ALTER     PROCEDURE [dbo].[USP_GetCustomerReport]
@LoadID varchar(36)
AS
BEGIN
	SELECT
		L.LoadNumber,
		L.CustomerPONo,
		CASE WHEN isnull(Cust.BestOpp, '') = '' THEN 'Due Upon Receipt' ELSE bestopp END AS PaymentTerms,
		CM.CompanyCode,
		isnull(C.DispatchFee, 0) as DispatchFee,
		CASE WHEN S.BillFromCompanies = 1 AND L.BillFromCompany IS NOT NULL AND L.BillFromCompany <> S.CompanyID THEN BFC.Contact ELSE SR.Name END AS SalesRep,
		CASE WHEN S.BillFromCompanies = 1 AND L.BillFromCompany IS NOT NULL AND L.BillFromCompany <> S.CompanyID THEN BFC.Email ELSE SR.EmailID END AS EmailID,
		L.ContactEmail AS PayerEmail,
		LS.City AS StopCity,
		LS.StateCode AS StopState,
		LS.PostalCode AS StopZip,
		LS.StopDate AS ShipperPickupDate,
		LS.Phone AS ShipperPhone,
		LS.Fax AS ShipperFax,
		LS.EmailID AS ShipperEmail,
		LS.CustName AS StopName,
		LS.Address AS StopAddress,
		L.BOLNum,
		LS.Blind,
		LS.ReleaseNo,
		LS.StopDate,
		LS.LoadType,
		L.customerMilesCharges AS CustomerMilesCharges,
		CASE WHEN S.Dispatch = 0 THEN CASE WHEN S.BillFromCompanies = 1 AND L.BillFromCompany IS NOT NULL AND L.BillFromCompany <> S.CompanyID THEN BFC.CompanyName ELSE CM.CompanyName END ELSE CASE WHEN ISNULL(C.DispatchFee, 0) = 0 THEN CASE WHEN S.BillFromCompanies = 1 AND L.BillFromCompany IS NOT NULL AND L.BillFromCompany <> S.CompanyID THEN BFC.CompanyName ELSE CM.CompanyName END ELSE C.CarrierName END END AS CompanyName,
		CASE WHEN S.Dispatch = 0 THEN CASE WHEN S.BillFromCompanies = 1 AND L.BillFromCompany IS NOT NULL AND L.BillFromCompany <> S.CompanyID THEN BFC.Address ELSE CM.Address END ELSE CASE WHEN ISNULL(C.DispatchFee, 0) = 0 THEN CASE WHEN S.BillFromCompanies = 1 AND L.BillFromCompany IS NOT NULL AND L.BillFromCompany <> S.CompanyID THEN BFC.Address ELSE CM.Address END ELSE C.address END END AS Address,
		CASE WHEN S.Dispatch = 0 THEN CASE WHEN S.BillFromCompanies = 1 AND L.BillFromCompany IS NOT NULL AND L.BillFromCompany <> S.CompanyID THEN BFC.CompanyLogoName ELSE S.companyLogoName END ELSE CASE WHEN ISNULL(C.DispatchFee, 0) = 0 THEN CASE WHEN S.BillFromCompanies = 1 AND L.BillFromCompany IS NOT NULL AND L.BillFromCompany <> S.CompanyID THEN BFC.CompanyLogoName ELSE S.companyLogoName END ELSE NULL END END AS companyLogoName,
		CASE WHEN S.FreightAgentService = 0 THEN CASE WHEN S.ApplyBillFromCompanyToCarrierReport = 1 AND L.BillFromCompany IS NOT NULL AND L.BillFromCompany <> S.CompanyID THEN BFC.State ELSE CM.State END ELSE Cust.StateCode END AS CompanyState,
		CASE WHEN S.FreightAgentService = 0 THEN CASE WHEN S.ApplyBillFromCompanyToCarrierReport = 1 AND L.BillFromCompany IS NOT NULL AND L.BillFromCompany <> S.CompanyID THEN BFC.ZipCode ELSE CM.ZipCode END ELSE Cust.ZipCode END AS CompanyZip,
		CASE WHEN S.FreightAgentService = 0 THEN CASE WHEN S.ApplyBillFromCompanyToCarrierReport = 1 AND L.BillFromCompany IS NOT NULL AND L.BillFromCompany <> S.CompanyID THEN BFC.City ELSE CM.City END ELSE Cust.City END AS CompanyCity,
		CASE WHEN S.Dispatch = 0 THEN CASE WHEN ISNULL(CASE WHEN S.BillFromCompanies = 1 AND L.BillFromCompany IS NOT NULL AND L.BillFromCompany <> S.CompanyID THEN BFC.Fax ELSE CM.Fax END, '') = '' THEN CASE WHEN S.BillFromCompanies = 1 AND L.BillFromCompany IS NOT NULL AND L.BillFromCompany <> S.CompanyID THEN BFC.Fax ELSE C.Fax END ELSE BFC.Fax END ELSE CASE WHEN ISNULL(C.DispatchFee, 0) = 0 THEN CASE WHEN S.BillFromCompanies = 1 AND L.BillFromCompany IS NOT NULL AND L.BillFromCompany <> S.CompanyID THEN BFC.Fax ELSE CM.Fax END ELSE C.fax END END AS Fax,
		CASE WHEN ISNULL(BFC.RemitInfo1,'') <> '' 
		THEN '<p><b><u>REMIT PAYMENT TO:</u></b><br />' 
			+ BFC.RemitInfo1 + '<br />' 
			+ BFC.RemitInfo2 + '<br />' 
			+ BFC.RemitInfo3 + '<br />' 
			+ BFC.RemitInfo4 + '<br />' 
			+ BFC.RemitInfo5 + '<br />' 
			+ BFC.RemitInfo6 + '<br />'
			+ '</p>' 
		ELSE CASE F.PrintOnInvoice WHEN 1 THEN REPLACE(REPLACE(REPLACE(F.InvoiceRemitInformation,'&oacute;','ó'),'&bull;','&#8226;'),'&nbsp;',' ') ELSE NULL END END AS InvoiceRemitInformation,
		L.TotalCustomerCharges AS AmountFC,
		CASE WHEN S.BillFromCompanies = 1 AND L.BillFromCompany IS NOT NULL AND L.BillFromCompany <> S.CompanyID THEN BFC.PhoneNumber ELSE CM.Phone END AS Phone, 
		CASE WHEN Cust.remitname > '""' AND F.UseFactInfoAsBillTo = 1 THEN Cust.RemitName ELSE L.CustName END AS PayerN,
		CASE WHEN Cust.remitname > '""' AND F.UseFactInfoAsBillTo = 1 THEN Cust.RemitAddress ELSE L.Address END AS PayerS, 
		CASE WHEN Cust.remitname > '""' AND F.UseFactInfoAsBillTo = 1 THEN Cust.RemitCity ELSE L.city END AS PayerC,
		CASE WHEN Cust.remitname > '""' AND F.UseFactInfoAsBillTo = 1 THEN Cust.RemitState ELSE L.StateCode END AS PayerST, 
		CASE WHEN Cust.remitname > '""' AND F.UseFactInfoAsBillTo = 1 THEN Cust.RemitZipCode ELSE L.PostalCode END AS PayerZ, 
		CASE WHEN Cust.remitname > '""' AND F.UseFactInfoAsBillTo = 1 THEN Cust.RemitPhone ELSE L.phone END AS PayerP, 
		CASE WHEN Cust.remitname > '""'  AND F.UseFactInfoAsBillTo = 1 THEN Cust.RemitFax ELSE L.fax END AS PayerF,
		CASE WHEN Cust.remitname > '""' AND F.UseFactInfoAsBillTo = 1 THEN Cust.RemitContact ELSE L.ContactPerson END AS PayerCt,
		LS.StopNo,
		LSC.SrNo,
		LST.StatusText,
		LS.ContactPerson AS ShipperContact,
		S.ShowCustomerTermsOnInvoice,REPLACE(REPLACE(LST.Reports,'RATE ','Customer '),'CANCELLED','INVOICE ') AS ReportTitle,
		Cust.CustomerID,
		LSC.LoadStopCommoditiesID,
		L.CustFlatRate,
		ISNULL(U.PaymentAdvance,0) AS PaymentAdvance,
		ISNULL(LSC.CustCharges,0) AS CustCharges,
		ISNULL(LSC.Weight,0) AS Weight,
		ISNULL(LSC.CustRate,0) AS CustRate,
		LSC.Description,
		LSC.Qty,
		LSC.Dimensions,
		C.CarrierID,
		S.CustomerInvoiceformat,
		L.PricingNotes,
		CASE WHEN len(isnull(Cust.CustomerTerms,'')) <> 0 THEN Cust.CustomerTerms ELSE S.CustomerTerms END AS CustomerTerms,
		ISNULL(L.BillDate, GETDATE()) AS BillDate
		From Loads L
			LEFT JOIN LoadStatusTypes LST ON LST.StatusTypeID = L.StatusTypeID
			LEFT JOIN Customers Cust ON Cust.CustomerID = L.CustomerID
			LEFT JOIN LoadStops LS ON LS.LoadID = L.LoadID
			LEFT JOIN LoadStopCommodities LSC ON LSC.LoadStopID = LS.LoadStopID
			LEFT JOIN Units U ON U.UnitID = LSC.UnitID
			LEFT JOIN Carriers C ON C.CarrierID = LS.NewCarrierID
			LEFT JOIN Employees D ON D.EmployeeID = L.DispatcherID

			LEFT JOIN Employees SR ON SR.EmployeeID = L.SalesRepID

			LEFT JOIN Equipments E ON E.EquipmentID = LS.NewEquipmentID

			LEFT JOIN Companies CM ON CM.CompanyID = LST.CompanyID
			LEFT JOIN BillFromCompanies BFC ON BFC.BillFromCompanyID =  L.BillFromCompany
			LEFT JOIN SystemConfig S On S.CompanyID = CM.CompanyID
			LEFT JOIN Factorings F ON F.FactoringID = Cust.FactoringID
			where L.LoadID = @LoadID
			ORDER BY LS.StopNo,LS.LoadType,LSC.SrNo
END
GO


