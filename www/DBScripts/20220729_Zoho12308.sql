IF NOT EXISTS (SELECT column_name FROM INFORMATION_SCHEMA.columns where table_name = 'SystemConfig' and column_name = 'DefaultBillFromAsCompany')
BEGIN
	ALTER TABLE SystemConfig ADD DefaultBillFromAsCompany bit not null default 1;
END


GO

/****** Object:  View [dbo].[vwCustomerInvoiceReportSub]    Script Date: 7/29/2022 12:40:20 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




ALTER           VIEW [dbo].[vwCustomerInvoiceReportSub]
AS
SELECT        TOP (100) PERCENT dbo.Loads.LoadID, CASE WHEN Isnull(dbo.Loads.invoiceNumber, 0) = 0 THEN dbo.Loads.LoadNumber ELSE dbo.Loads.invoiceNumber END AS LoadNumber, 
                         
						 CASE WHEN dbo.systemConfig.Dispatch = 0 THEN CASE WHEN dbo.SystemConfig.BillFromCompanies = 1 AND dbo.Loads.BillFromCompany IS NOT NULL AND dbo.Loads.BillFromCompany <> dbo.SystemConfig.CompanyID THEN dbo.BillFromCompanies.CompanyName ELSE dbo.Companies.CompanyName END ELSE CASE WHEN ISNULL(dbo.Carriers.DispatchFee, 0) = 0 THEN CASE WHEN dbo.SystemConfig.BillFromCompanies = 1 AND dbo.Loads.BillFromCompany IS NOT NULL AND dbo.Loads.BillFromCompany <> dbo.SystemConfig.CompanyID THEN dbo.BillFromCompanies.CompanyName ELSE dbo.Companies.CompanyName END ELSE dbo.Carriers.CarrierName END END AS CompanyName, 
                         CASE WHEN dbo.systemConfig.Dispatch = 0 THEN CASE WHEN dbo.SystemConfig.BillFromCompanies = 1 AND dbo.Loads.BillFromCompany IS NOT NULL AND dbo.Loads.BillFromCompany <> dbo.SystemConfig.CompanyID THEN dbo.BillFromCompanies.Address ELSE dbo.Companies.Address END ELSE CASE WHEN ISNULL(dbo.Carriers.DispatchFee, 0) = 0 THEN CASE WHEN dbo.SystemConfig.BillFromCompanies = 1 AND dbo.Loads.BillFromCompany IS NOT NULL AND dbo.Loads.BillFromCompany <> dbo.SystemConfig.CompanyID THEN dbo.BillFromCompanies.Address ELSE dbo.Companies.Address END ELSE dbo.Carriers.address END END AS Address, 
                         CASE WHEN dbo.systemConfig.Dispatch = 0 THEN CASE WHEN dbo.SystemConfig.BillFromCompanies = 1 AND dbo.Loads.BillFromCompany IS NOT NULL AND dbo.Loads.BillFromCompany <> dbo.SystemConfig.CompanyID THEN dbo.BillFromCompanies.City ELSE dbo.Companies.City END ELSE CASE WHEN ISNULL(dbo.Carriers.DispatchFee, 0) = 0 THEN CASE WHEN dbo.SystemConfig.BillFromCompanies = 1 AND dbo.Loads.BillFromCompany IS NOT NULL AND dbo.Loads.BillFromCompany <> dbo.SystemConfig.CompanyID THEN dbo.BillFromCompanies.City ELSE dbo.Companies.City END ELSE dbo.Carriers.city END END AS City, 
                         CASE WHEN dbo.systemConfig.Dispatch = 0 THEN CASE WHEN dbo.SystemConfig.BillFromCompanies = 1 AND dbo.Loads.BillFromCompany IS NOT NULL AND dbo.Loads.BillFromCompany <> dbo.SystemConfig.CompanyID THEN dbo.BillFromCompanies.State ELSE dbo.Companies.State END ELSE CASE WHEN ISNULL(dbo.Carriers.DispatchFee, 0) = 0 THEN CASE WHEN dbo.SystemConfig.BillFromCompanies = 1 AND dbo.Loads.BillFromCompany IS NOT NULL AND dbo.Loads.BillFromCompany <> dbo.SystemConfig.CompanyID THEN dbo.BillFromCompanies.State ELSE dbo.Companies.State END ELSE dbo.Carriers.stateCode END END AS state, 
                         CASE WHEN dbo.systemConfig.Dispatch = 0 THEN CASE WHEN dbo.SystemConfig.BillFromCompanies = 1 AND dbo.Loads.BillFromCompany IS NOT NULL AND dbo.Loads.BillFromCompany <> dbo.SystemConfig.CompanyID THEN dbo.BillFromCompanies.ZipCode ELSE dbo.Companies.ZipCode END ELSE CASE WHEN ISNULL(dbo.Carriers.DispatchFee, 0) = 0 THEN CASE WHEN dbo.SystemConfig.BillFromCompanies = 1 AND dbo.Loads.BillFromCompany IS NOT NULL AND dbo.Loads.BillFromCompany <> dbo.SystemConfig.CompanyID THEN dbo.BillFromCompanies.ZipCode ELSE dbo.Companies.ZipCode END ELSE dbo.Carriers.ZipCode END END AS ZipCode, 
                         
						 dbo.Loads.CustName AS PayerName, dbo.Loads.Address AS PayerStreet, dbo.Loads.City AS PayerCity, dbo.Loads.StateCode AS PayerState, dbo.Loads.PostalCode AS PayerZip, dbo.Loads.ContactPerson AS PayerContact, 
                         dbo.Loads.Phone AS PayerPhone, dbo.Loads.Fax AS PayerFax, dbo.vwCarrierConfirmationReportShippers.StopNo, dbo.vwCarrierConfirmationReportShippers.ShipperName, 
                         dbo.vwCarrierConfirmationReportShippers.ShipperAddress, dbo.vwCarrierConfirmationReportShippers.ShipperCity, dbo.vwCarrierConfirmationReportShippers.ShipperState, dbo.vwCarrierConfirmationReportShippers.ShipperZip, 
                         dbo.vwCarrierConfirmationReportShippers.ShipperContact, dbo.vwCarrierConfirmationReportShippers.ShipperPhone, dbo.vwCarrierConfirmationReportShippers.ShipperFax, 
                         dbo.vwCarrierConfirmationReportConsignee.ConName, dbo.vwCarrierConfirmationReportConsignee.ConAddress, dbo.vwCarrierConfirmationReportConsignee.ConCity, dbo.vwCarrierConfirmationReportConsignee.ConState, 
                         dbo.vwCarrierConfirmationReportConsignee.ConZip, dbo.vwCarrierConfirmationReportConsignee.ConFax, dbo.vwCarrierConfirmationReportConsignee.ConContact, dbo.vwCarrierConfirmationReportConsignee.ConPhone, 
                         dbo.vwCarrierConfirmationReportConsignee.NewEquipmentID, dbo.vwCarrierConfirmationReportShippers.RefNo, dbo.vwCustomerInvoiceReportSubCommodities.Type, 
                         dbo.vwCarrierConfirmationReportFinalDestination.CustName AS DestName, dbo.vwCarrierConfirmationReportFinalDestination.Address AS DestAddress, dbo.vwCarrierConfirmationReportFinalDestination.StateCode AS DestState, 
                         dbo.vwCarrierConfirmationReportFinalDestination.City AS DestCity, dbo.vwCarrierConfirmationReportFinalDestination.PostalCode AS DestZip, dbo.vwCarrierConfirmationReportFinalDestination.ContactPerson AS DestContact, 
                         dbo.vwCarrierConfirmationReportFinalDestination.Phone AS DestPhone, dbo.vwCarrierConfirmationReportFinalDestination.Fax AS DestFax, dbo.vwCarrierConfirmationReportShippers.ShipperPickupDate, 
                         dbo.vwCarrierConfirmationReportShippers.ShipperPickupTime, dbo.vwCarrierConfirmationReportConsignee.ConDelivTime, dbo.vwCarrierConfirmationReportConsignee.ConDelivDate, 
                         dbo.vwCarrierConfirmationReportFinalDestination.FinalDelivDate, dbo.vwCarrierConfirmationReportFinalDestination.FinalDelivTime, dbo.Employees.Name AS Dispatcher, 
                         dbo.vwCarrierConfirmationReportShippers.CarrDriverName, dbo.vwCarrierConfirmationReportShippers.CarrDriverCell, dbo.vwCarrierConfirmationReportShippers.CarrTruckNo, 
                         dbo.vwCarrierConfirmationReportShippers.CarrTrailorNo, dbo.Loads.carrierNotes, dbo.SystemConfig.CarrierTerms, dbo.vwCarrierConfirmationReportShippers.LoadStopID, dbo.vwCarrierConfirmationReportShippers.StopNum, 
                         dbo.Equipments.EquipmentName, dbo.Equipments.EquipmentCode,CASE WHEN dbo.SystemConfig.BillFromCompanies = 1 AND dbo.Loads.BillFromCompany IS NOT NULL AND dbo.Loads.BillFromCompany <> dbo.SystemConfig.CompanyID THEN dbo.BillFromCompanies.PhoneNumber ELSE dbo.Companies.Phone END AS Phone, 
                         CASE WHEN dbo.systemConfig.Dispatch = 0 THEN CASE WHEN ISNULL(CASE WHEN dbo.SystemConfig.BillFromCompanies = 1 AND dbo.Loads.BillFromCompany IS NOT NULL AND dbo.Loads.BillFromCompany <> dbo.SystemConfig.CompanyID THEN dbo.BillFromCompanies.Fax ELSE dbo.Companies.Fax END, '') = '' THEN CASE WHEN dbo.SystemConfig.BillFromCompanies = 1 AND dbo.Loads.BillFromCompany IS NOT NULL AND dbo.Loads.BillFromCompany <> dbo.SystemConfig.CompanyID THEN dbo.BillFromCompanies.Fax ELSE dbo.Companies.Fax END ELSE dbo.Offices.faxno END ELSE CASE WHEN ISNULL(dbo.Carriers.DispatchFee, 0) = 0 THEN CASE WHEN dbo.SystemConfig.BillFromCompanies = 1 AND dbo.Loads.BillFromCompany IS NOT NULL AND dbo.Loads.BillFromCompany <> dbo.SystemConfig.CompanyID THEN dbo.BillFromCompanies.Fax ELSE dbo.Companies.Fax END ELSE dbo.Carriers.fax END END AS Fax, 
                         dbo.Customers.CustomerName AS PName, dbo.Customers.Location AS PStreet, dbo.Customers.City AS PCity, dbo.Customers.Zipcode AS PZip, dbo.Customers.statecode AS PState, dbo.Customers.Fax AS PFax, 
                         dbo.Customers.PhoneNo AS PPhone, dbo.Loads.TotalCustomerCharges, ISNULL(dbo.Loads.BillDate, GETDATE()) AS BillDate, dbo.Loads.BOLNum, dbo.Loads.customerMilesCharges, dbo.Loads.CustomerPONo, 
                         dbo.Loads.CustFlatRate, dbo.LoadStatusTypes.StatusText, 
						 CASE WHEN len(isnull(dbo.Customers.CustomerTerms,'')) <> 0 THEN dbo.Customers.CustomerTerms ELSE dbo.SystemConfig.CustomerTerms END AS CustomerTerms,
						 dbo.Loads.PricingNotes, dbo.Customers.RemitName, dbo.Customers.RemitAddress, dbo.Customers.RemitCity, 
                         dbo.Customers.RemitState, dbo.Customers.RemitZipcode, dbo.Customers.RemitContact, dbo.Customers.RemitFax, dbo.Customers.RemitPhone, dbo.Loads.userDefinedFieldTrucking, dbo.SystemConfig.UserDef7, 
                         CASE WHEN isnull(BestOpp, '') = '' THEN 'Due Upon Receipt' ELSE bestopp END AS PaymentTerms, dbo.vwCustomerInvoiceReportSubCommodities.PrintCommodity, dbo.vwCustomerInvoiceReportSubCommodities.QtyTotal, 
                         dbo.vwCustomerInvoiceReportSubCommodities.CustChargesTotal, dbo.vwCustomerInvoiceReportSubCommodities.WeightTotal, dbo.vwCustomerInvoiceReportSubCommodities.SrNo, 
                         dbo.vwCustomerInvoiceReportSubCommodities.Qty, dbo.vwCustomerInvoiceReportSubCommodities.Description, dbo.vwCustomerInvoiceReportSubCommodities.Weight, 
                         dbo.vwCustomerInvoiceReportSubCommodities.CustCharges, dbo.vwCustomerInvoiceReportSubCommodities.CarrCharges, 
                         CASE WHEN ForeignCurrencyEnabled = 0 THEN Format(TotalCustomerCharges - IsNull(vwSalesRepCommissionCarrierPay.CustPayments, 0), 'C') ELSE Format(IsNull(TotalCustomerCharges, 0) 
                         - ISNull(vwSalesRepCommissionCarrierPay.CustPayments, 0), 'N') + ' ' + ISNull(CurrencyNameISO, '""') END AS AmountFC, dbo.Currencies.CurrencyNameISO, 
                         dbo.vwCarrierConfirmationReportShippers.timezone AS shipperTimeZone, dbo.vwCarrierConfirmationReportConsignee.timezone AS conTimeZone, 
                         CASE WHEN dbo.systemConfig.Dispatch = 0 THEN CASE WHEN dbo.SystemConfig.BillFromCompanies = 1 AND dbo.Loads.BillFromCompany IS NOT NULL AND dbo.Loads.BillFromCompany <> dbo.SystemConfig.CompanyID THEN dbo.BillFromCompanies.CompanyLogoName ELSE dbo.systemConfig.companyLogoName END ELSE CASE WHEN ISNULL(dbo.Carriers.DispatchFee, 0) = 0 THEN CASE WHEN dbo.SystemConfig.BillFromCompanies = 1 AND dbo.Loads.BillFromCompany IS NOT NULL AND dbo.Loads.BillFromCompany <> dbo.SystemConfig.CompanyID THEN dbo.BillFromCompanies.CompanyLogoName ELSE dbo.systemConfig.companyLogoName END ELSE NULL 
                         END END AS companyLogoName, dbo.Companies.CompanyCode, dbo.Carriers.DispatchFee, dbo.SystemConfig.Dispatch, dbo.vwSalesRepCommissionCarrierPay.CustPayments, 
                         dbo.vwCustomerInvoiceReportSubCommodities.PaymentAdvance,
						 CASE WHEN dbo.SystemConfig.BillFromCompanies = 1 AND dbo.Loads.BillFromCompany IS NOT NULL AND dbo.Loads.BillFromCompany <> dbo.SystemConfig.CompanyID 
										THEN dbo.BillFromCompanies.Contact ELSE Emp1.Name END AS SalesRep,
						 CASE WHEN dbo.SystemConfig.BillFromCompanies = 1 AND dbo.Loads.BillFromCompany IS NOT NULL AND dbo.Loads.BillFromCompany <> dbo.SystemConfig.CompanyID 
										THEN dbo.BillFromCompanies.Email ELSE Emp1.EmailID END AS EmailID,
						 CASE WHEN ISNULL(dbo.BillFromCompanies.RemitInfo1,'') <> '' 
							THEN '<p><b><u>REMIT PAYMENT TO:</u></b><br />' 
									+ dbo.BillFromCompanies.RemitInfo1 + '<br />' 
									+ dbo.BillFromCompanies.RemitInfo2 + '<br />' 
									+ dbo.BillFromCompanies.RemitInfo3 + '<br />' 
									+ dbo.BillFromCompanies.RemitInfo4 + '<br />' 
									+ dbo.BillFromCompanies.RemitInfo5 + '<br />' 
									+ dbo.BillFromCompanies.RemitInfo6 + '<br />'
									+ '</p>' 
							ELSE CASE dbo.Factorings.PrintOnInvoice WHEN 1 THEN REPLACE(REPLACE(REPLACE(dbo.Factorings.InvoiceRemitInformation,'&oacute;','ó'),'&bull;','&#8226;'),'&nbsp;',' ') ELSE NULL END END AS InvoiceRemitInformation,
						 dbo.SystemConfig.ShowCustomerTermsOnInvoice,REPLACE(REPLACE(dbo.LoadStatusTypes.Reports,'RATE ','Customer '),'CANCELLED','INVOICE ') AS ReportTitle,dbo.Factorings.UseFactInfoAsBillTo,CASE WHEN ISNULL(dbo.BillFromCompanies.RemitInfo1,'') <> ''  THEN '#000000' ELSE dbo.Factorings.InfoColor END AS InfoColor
						,dbo.vwCarrierConfirmationReportShippers.ShipperEmail,dbo.vwCarrierConfirmationReportFinalDestination.EmailID AS DestEmail,dbo.Loads.ContactEmail AS PayerEmail,dbo.SystemConfig.CustomerInvoiceformat
FROM            dbo.vwCustomerInvoiceReportSubCommodities RIGHT OUTER JOIN
                         dbo.Offices INNER JOIN
                         dbo.vwCarrierConfirmationReportFinalDestination INNER JOIN
                         dbo.Companies INNER JOIN
                         dbo.Loads ON dbo.Companies.CompanyID =
                             (SELECT        TOP (1) CompanyID
                               FROM            dbo.Offices AS o1
                               WHERE        (OfficeID IN
                                                             (SELECT        OfficeID
                                                               FROM            dbo.CustomerOffices AS co
                                                               WHERE        (CustomerID = dbo.Loads.CustomerID)))) INNER JOIN
                         dbo.SystemConfig ON dbo.SystemConfig.CompanyID = dbo.Companies.CompanyID INNER JOIN
                         dbo.vwCarrierConfirmationReportShippers ON dbo.Loads.LoadID = dbo.vwCarrierConfirmationReportShippers.LoadID INNER JOIN
                         dbo.vwCarrierConfirmationReportConsignee ON dbo.Loads.LoadID = dbo.vwCarrierConfirmationReportConsignee.LoadID AND 
                         dbo.vwCarrierConfirmationReportShippers.LoadID = dbo.vwCarrierConfirmationReportConsignee.LoadID AND dbo.vwCarrierConfirmationReportShippers.StopNo = dbo.vwCarrierConfirmationReportConsignee.StopNo ON 
                         dbo.vwCarrierConfirmationReportFinalDestination.LoadID = dbo.Loads.LoadID INNER JOIN
                         dbo.Employees ON dbo.Loads.DispatcherID = dbo.Employees.EmployeeID LEFT JOIN
						 dbo.Employees Emp1 ON dbo.Loads.SalesRepID = Emp1.EmployeeID ON dbo.Offices.OfficeID = dbo.Employees.OfficeID INNER JOIN
                         dbo.Customers ON dbo.Loads.CustomerID = dbo.Customers.CustomerID INNER JOIN
                         dbo.LoadStatusTypes ON dbo.Loads.StatusTypeID = dbo.LoadStatusTypes.StatusTypeID LEFT OUTER JOIN
                         dbo.Currencies ON dbo.Loads.CustomerCurrency = dbo.Currencies.CurrencyID ON dbo.vwCustomerInvoiceReportSubCommodities.LoadStopID = dbo.vwCarrierConfirmationReportShippers.LoadStopID LEFT OUTER JOIN
                         dbo.Carriers ON dbo.Loads.CarrierID = dbo.Carriers.CarrierID LEFT OUTER JOIN
                         dbo.Equipments ON dbo.vwCarrierConfirmationReportConsignee.NewEquipmentID = dbo.Equipments.EquipmentID LEFT OUTER JOIN
                         dbo.vwSalesRepCommissionCarrierPay ON dbo.vwSalesRepCommissionCarrierPay.LoadID = dbo.Loads.LoadID
						 LEFT OUTER JOIN dbo.Factorings ON dbo.Factorings.FactoringID =  dbo.Customers.FactoringID
						 LEFT OUTER JOIN dbo.BillFromCompanies ON dbo.BillFromCompanies.BillFromCompanyID =  dbo.Loads.BillFromCompany
