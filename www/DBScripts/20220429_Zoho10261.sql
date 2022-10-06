GO

/****** Object:  StoredProcedure [dbo].[USP_GetCarrierReport]    Script Date: 29-04-2022 11:38:05 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER         PROCEDURE [dbo].[USP_GetCarrierReport]

@LoadID varchar(36)
AS
BEGIN
	SELECT 
				L.LoadNumber,
				L.OrderDate,
				LS.StopNo,
				LS.LoadType,
				C.CarrierID,
				C.CarrierName,
				C.Address AS CarrierAddress,
				C.City AS CarrierCity,
				C.StateCode AS CarrierStateCode,
				C.ZipCode AS CarrierZipCode,
				C.Phone AS CarrierPhone,
				C.Fax AS CarrierFax,
				C.EmailID AS CarrierEMail,
				C.isShowDollar AS isShowDollar,
				D.Name AS DispatcherName,
				D.Telephone AS DispatcherPhone,
				D.PhoneExtension AS DispatcherPhoneExt,
				D.Fax AS DispatcherFax,
				D.FaxExtension AS DispatcherFaxExt,
				D.EmailID AS DispatcherEmail,
				LS.NewDriverName AS Driver1,
				LS.NewDriverCell AS Driver1Cell,
				LS.NewDriverName2 AS Driver2,
				LS.NewDriverCell2 AS Driver2Cell,
				LS.NewTruckNo AS TruckNo,
				LS.NewTrailorNo AS TrailorNo,
				LS.Temperature,
				LS.Temperaturescale,
				E.EquipmentName,
				LS.NewBookedWith AS Contact,
				LS.RefNo,
				CASE WHEN ISNULL(L.TotalMiles,0) <> 0 THEN L.TotalMiles ELSE LS.Miles END AS Miles,
				LS.CustName AS StopName,
				LS.Address AS StopAddress,
				LS.City AS StopCity,
				LS.StateCode AS StopState,
				LS.PostalCode AS StopZip,
				LS.Phone AS StopPhone,
				LS.Fax AS StopFax,
				LS.Instructions,
				LS.ReleaseNo,
				LS.StopDate,
				LS.StopTime,
				LSC.LoadStopCommoditiesID,
				LSC.Qty,
				LSC.Description,
				LSC.Dimensions,
				ISNULL(LSC.Weight,0) AS Weight,
				ISNULL(LSC.CarrRate,0) AS CarrRate,
				ISNULL(LSC.CarrCharges,0) AS CarrCharges,
				L.CriticalNotes,
				L.CarrierNotes,
				CASE WHEN CONVERT(varchar(8000), C.Memo)  > '""' THEN C.Memo ELSE S.CarrierTerms END AS CarrierTerms,
				CASE WHEN S.FreightAgentService = 0 THEN CASE WHEN S.ApplyBillFromCompanyToCarrierReport = 1 AND L.BillFromCompany IS NOT NULL AND L.BillFromCompany <> S.CompanyID THEN BFC.CompanyName ELSE CM.CompanyName END ELSE Cust.CustomerName END AS CompanyName, 
				CASE WHEN S.FreightAgentService = 0 THEN CASE WHEN S.ApplyBillFromCompanyToCarrierReport = 1 AND L.BillFromCompany IS NOT NULL AND L.BillFromCompany <> S.CompanyID THEN BFC.Address ELSE CM.Address END ELSE Cust.Location END AS CompanyAddress, 
				CASE WHEN S.FreightAgentService = 0 THEN CASE WHEN S.ApplyBillFromCompanyToCarrierReport = 1 AND L.BillFromCompany IS NOT NULL AND L.BillFromCompany <> S.CompanyID THEN BFC.City ELSE CM.City END ELSE Cust.City END AS CompanyCity, 
				CASE WHEN S.FreightAgentService = 0 THEN CASE WHEN S.ApplyBillFromCompanyToCarrierReport = 1 AND L.BillFromCompany IS NOT NULL AND L.BillFromCompany <> S.CompanyID THEN BFC.State ELSE CM.State END ELSE Cust.StateCode END AS CompanyState, 
				CASE WHEN S.FreightAgentService = 0 THEN CASE WHEN S.ApplyBillFromCompanyToCarrierReport = 1 AND L.BillFromCompany IS NOT NULL AND L.BillFromCompany <> S.CompanyID THEN BFC.ZipCode ELSE CM.ZipCode END ELSE Cust.ZipCode END AS CompanyZip,
				CASE WHEN S.ApplyBillFromCompanyToCarrierReport = 1 AND L.BillFromCompany IS NOT NULL AND L.BillFromCompany <> S.CompanyID THEN BFC.CompanyLogoName ELSE S.CompanyLogoName END AS CompanyLogoName,
				ISNULL(L.CarrFlatRate,0) AS CarrFlatRate,
				ISNULL(L.carrierMilesCharges,0) AS carrierMilesCharges,
				ISNULL(U.PaymentAdvance,0) AS PaymentAdvance,
				CASE WHEN S.FreightBroker = 1 THEN 'MC#: ' + C.MCNumber ELSE '' END AS MCNo,
				S.CommodityWeight,
				L.Weight AS LoadWeight,
				CASE WHEN S.FreightBroker = 0 THEN 'Driver' ELSE 'Carrier' END AS FreightBrokerText,
				S.FreightBroker,
				S.Dispatch as Dispatch,
				ISNULL(C.DispatchFee,0) AS DispatchFee,
				ISNULL(C.IsCarrier,0) AS IsCarrier,
				LS.ContactPerson,
				LST.StatusText,
				CM.CompanyCode,
				S.CarrierRateConfirmation,
				SR.Name AS SalesAgent,
				SR.Telephone AS SalesAgentPhone,
				SR.EmailID AS SalesAgentEmail,
				LS.Blind
			FROM Loads L
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
			WHERE L.LoadID = @LoadID
			ORDER BY LS.StopNo,LS.LoadType,LSC.SrNo
END
GO


