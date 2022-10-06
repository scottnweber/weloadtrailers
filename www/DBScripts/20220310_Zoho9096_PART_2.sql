IF NOT EXISTS (SELECT column_name FROM INFORMATION_SCHEMA.columns where table_name = 'LoadStops' and column_name = 'LateStop')
BEGIN
	ALTER TABLE LoadStops ADD LateStop bit not null default 0;
END

GO

/****** Object:  StoredProcedure [dbo].[USP_GetLoadDetails]    Script Date: 3/10/2022 7:36:18 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER                         PROC [dbo].[USP_GetLoadDetails]

(

@LoadID VARCHAR(200),

@StopNo int,
@CompanyID VARCHAR(50)
)

AS

BEGIN

	IF ltrim(Rtrim(IsNull(@StopNo, ''))) = ''
	BEGIN
		SET @StopNo = 0
	END

	IF(LEN(@LoadID)<>0)
	BEGIN
		SELECT 
			l.Loadid,l.LoadNumber,l.IsPartial,l.CarrierID AS CarrierID,
			ISNULL(l.CustomerRatePerMile,0) AS CustomerRatePerMile,
			ISNULL(l.CarrierRatePerMile,0) AS CarrierRatePerMile,
			ISNULL(l.TotalMiles,0) AS CustomerTotalMiles,
			ISNULL(l.TotalMiles,0) AS CarrierTotalMiles,
			ISNULL(l.ARExported,'0') AS ARExportedNN,
			ISNULL(l.APExported,'0') AS APExportedNN,
			ISNULL(l.orderDate, '') AS orderDate,
			ISNULL(l.BillDate, '') AS BillDate,
			ISNULL(l.customerMilesCharges, 0) AS customerMilesCharges,
			ISNULL(l.carrierMilesCharges, 0) AS carrierMilesCharges,
			ISNULL(l.customerCommoditiesCharges, 0) AS customerCommoditiesCharges,
			ISNULL(l.carrierCommoditiesCharges, 0) AS carrierCommoditiesCharges,
			ISNULL(l.CustFlatRate, 0) AS CustFlatRate,
			ISNULL(l.carrFlatRate, 0) AS carrFlatRate,
			l.ModifiedBy,
			l.LastModifiedDate,
			l.EquipmentID,
			l.RefNo,
			l.readyDate,
			l.arriveDate,
			l.isExcused,
			l.bookedBy,
			l.DeadHeadMiles,
			ISNULL(l.posttoITS,0) AS posttoITS,
			postCarrierRatetoITS,
			postCarrierRatetoloadboard,
			postCarrierRatetoTranscore,
			postCarrierRateto123LoadBoard,
			shipperStopDate,
			consigneeStopDate,
			shipperStopTime,
			consigneeStopTime,
			shipperStopTimeIn,
			consigneeStopTimeIn,
			shipperStopTimeOut,
			consigneeStopTimeOut,
			CustomerPONo,
			BOLNum,
			StatusTypeID,
			PricingNotes,
			statusText,
			colorCode,
			L.CustomerID AS PayerID,
			TotalCustomerCharges,
			stops.shipperState,
			stops.shipperCity,
			stops.consigneeState,
			stops.consigneeCity,
			carr.CarrierName,
			Iscarrier,
			CustomerName,
			LoadStopID,
			StopNo,
			[NewPickupDate] as PickupDate,
			[NewPickupTime] as PickupTime,
			[NewDeliveryDate] as DeliveryDate,
			[NewDeliveryTime] as DeliveryTime,
			NewOfficeID,
			NewNotes,
			isPost,
			IsTransCorePst,
			TotalCarrierCharges,
			TotalCustomerCharges,
			NewCarrierID,
			NewCarrierID2,
			NewCarrierID3,
			carrierNotes,
			NewDispatchNotes,
			DispatcherID,
			SalesRepID,
			shipperStopName,
			consigneeStopName,
			shipperLocation,
			consigneeLocation,
			shipperPostalCode,
			consigneePostalCode,
			shipperContactPerson,
			consigneeContactPerson,
			shipperPhone,
			consigneePhone,
			shipperFax,
			consigneeFax,
			shipperEmailID,
			consigneeEmailID,
			shipperReleaseNo,
			consigneeReleaseNo,
			shipperBlind,
			consigneeBlind,
			shipperInstructions,
			consigneeInstructions,
			shipperDirections,
			consigneeDirections,
			shipperLoadStopID,
			consigneeLoadStopID,
			shipperBookedWith,
			consigneeBookedWith,
			shipperEquipmentID,
			consigneeEquipmentID,
			shipperDriverName,
			consigneeDriverName,
			consigneeDriverName2,
			shipperDriverCell,
			consigneeDriverCell,
			shipperTruckNo,
			consigneeTruckNo,
			shipperTrailorNo,
			consigneeTrailorNo,
			shipperRefNo,
			consigneeRefNo,
			shipperMiles,
			consigneeMiles,
			shipperCustomerID,
			consigneeCustomerID
			consigneeCustomerID,EmergencyResponseNo,CODAmt,CODFee,DeclaredValue,postto123loadboard,Notes,invoiceNumber,weight,userDefinedFieldTrucking,CarrierInvoiceNumber
			, emailList, shipperDriverCell2, consigneeDriverCell2, l.CustomerCurrency, l.CarrierCurrency, l.InternalRef
			,l.noOfTrips,l.tripText
			,l.BOLFromName,l.BOLFromTel,l.BOLFromEmail,l.BOLREName,l.BOLREPO
			,temperature
			,temperaturescale
			,l.ediInvoiced
			,l.EDISCAC
			,l.FF
			,l.PODSignature
			,l.MacroPointOrderID
			,l.LoadStatusStopNo
			,l.posttoDirectFreight
			,l.postCarrierRatetoDirectFreight
			,l.PushDataToProject44Api
			,shipperTimeZone
			,consigneeTimeZone
			,l.EquipmentLength
			,CustRep
			,ShipperRep
			,CarrierRep
			,CustRepPercentage
			,ShipperRepPercentage
			,CarrierRepPercentage
			,l.TotalDirectCost
			,l.EquipmentWidth
			,shipperDriverCell3
			,consigneeDriverCell3
			,l.ContactEmail
			,l.CustomDriverPay,
			CustomDriverPayFlatRate,
			CustomDriverPayFlatRate2,
			CustomDriverPayFlatRate3,
			CustomDriverPayPercentage,
			CustomDriverPayPercentage2,
			CustomDriverPayPercentage3,
			stops.CustomDriverPayOption,
			stops.CustomDriverPayOption2,
			stops.CustomDriverPayOption3,
			CriticalNotes,
			l.IsEDispatched,
			ShowStopOnLoadStatus,
			Reports AS CustomerReportButton
			,EquipmentTrailer
			,L.RateApprovalNeeded
			,L.MarginApproved
			,L.LastApprovedRate
			,(select count(distinct ls1.NewCarrierID) from loadstops ls1 where ls1.loadid = L.loadid) AS CarrierCount
			,L.Dispatcher1
			,L.Dispatcher2
			,L.Dispatcher3
			,L.Dispatcher1Percentage
			,L.Dispatcher2Percentage
			,L.Dispatcher3Percentage
			,LateStop
		FROM LOADS l
		LEFT OUTER JOIN (SELECT 
							a.LoadID,
							a.LoadStopID,a.StopNo,
							a.NewCarrierID,
							a.NewCarrierID2,
							a.NewCarrierID3,
							a.NewOfficeID,
							a.City AS shipperCity,
							b.City AS consigneeCity,
							a.custName AS shipperStopName,
							b.custName AS consigneeStopName,
							a.Address AS shipperLocation,
							b.Address AS consigneeLocation,
							a.PostalCode AS shipperPostalCode,
							b.PostalCode AS consigneePostalCode,
							a.ContactPerson AS shipperContactPerson,
							b.ContactPerson AS consigneeContactPerson,
							a.Phone AS shipperPhone,
							b.Phone AS consigneePhone,
							a.fax AS shipperFax,
							b.fax AS consigneeFax,
							a.EmailID AS shipperEmailID,
							b.EmailID AS consigneeEmailID,
							a.StopDate AS shipperStopDate,
							b.StopDate AS consigneeStopDate,
							a.StopTime AS shipperStopTime,
							b.StopTime AS consigneeStopTime,
							a.TimeIn AS shipperStopTimeIn,
							b.TimeIn AS consigneeStopTimeIn,
							a.TimeOut AS shipperStopTimeOut,
							b.TimeOut AS consigneeStopTimeOut,
							a.ReleaseNo AS shipperReleaseNo,
							b.ReleaseNo AS consigneeReleaseNo,
							a.Blind AS shipperBlind,
							b.Blind AS consigneeBlind,
							a.Instructions AS shipperInstructions,
							b.Instructions AS consigneeInstructions,
							a.Directions AS shipperDirections,
							b.Directions AS consigneeDirections,
							a.LoadStopID AS shipperLoadStopID,
							b.LoadStopID AS consigneeLoadStopID,
							a.NewBookedWith AS shipperBookedWith,
							b.NewBookedWith AS consigneeBookedWith,
							a.NewEquipmentID AS shipperEquipmentID,
							b.NewEquipmentID AS consigneeEquipmentID,
							a.NewDriverName AS shipperDriverName,
							b.NewDriverName AS consigneeDriverName,
							b.NewDriverName2 AS consigneeDriverName2,
							a.NewDriverCell AS shipperDriverCell,
							b.NewDriverCell AS consigneeDriverCell,
							a.NewTruckNo AS shipperTruckNo,
							b.NewTruckNo AS consigneeTruckNo,
							a.NewTrailorNo AS shipperTrailorNo,
							b.NewTrailorNo AS consigneeTrailorNo,
							a.RefNo AS shipperRefNo,
							b.RefNo AS consigneeRefNo,
							a.Miles AS shipperMiles,
							b.Miles AS consigneeMiles,
							a.CustomerID AS shipperCustomerID,
							b.CustomerID AS consigneeCustomerID,
							a.StateCode as shipperState,
							b.StateCode as consigneeState, 
							a.NewDriverCell2 AS shipperDriverCell2,
							b.NewDriverCell2 AS consigneeDriverCell2,
							b.temperature,
							b.temperaturescale,
							a.timeZone as shipperTimeZone,
							b.timeZone as consigneeTimeZone,
							a.NewDriverCell3 AS shipperDriverCell3,
							b.NewDriverCell3 AS consigneeDriverCell3,
							a.CustomDriverPayFlatRate,
							a.CustomDriverPayFlatRate2,
							a.CustomDriverPayFlatRate3,
							a.CustomDriverPayPercentage,
							a.CustomDriverPayPercentage2,
							a.CustomDriverPayPercentage3,
							a.CustomDriverPayOption,
							a.CustomDriverPayOption2,
							a.CustomDriverPayOption3
							,a.EquipmentTrailer
							,a.latestop
						FROM LoadStops a 
						JOIN LoadStops b on a.LoadID = b.LoadID AND a.StopNo = b.StopNo
						WHERE a.LoadID = @LoadID AND a.LoadType = 1 AND b.LoadType = 2 AND a.StopNo =@StopNo AND b.StopNo =@StopNo) as stops  on stops.loadid = l.loadid
		left outer join (SELECT [CarrierID],[CarrierName], Iscarrier FROM [Carriers] WHERE CompanyID = @CompanyID) as carr on carr.CarrierID = stops.NewCarrierID
		left outer join (SELECT [CarrierOfficeID],[Manager]  FROM [CarrierOffices]) as office on office.CarrierOfficeID = stops.NewOfficeID
		left outer join (SELECT [StatusTypeID] as stTypeId,[statusText],[colorCode],[ShowStopOnLoadStatus],[Reports] FROM [loadStatusTypes]) as loadStatus on loadStatus.stTypeId = l.StatusTypeID

		left outer join (SELECT [CustomerName],[CustomerID] FROM [Customers]) as cust on cust.CustomerID = l.CustomerID
		left outer join (SELECT [CustomerID],[OfficeID] FROM [CustomerOffices]) as custOffices on custOffices.CustomerID = cust.CustomerID
		left outer join (SELECT [OfficeID],[CompanyID] FROM [Offices]) as O on O.OfficeID = custOffices.OfficeID


		left outer join (SELECT [StatusTypeID] as lststType,[StatusText] as lStatusText FROM [LoadStatusTypes]) as LStatusTypes on LStatusTypes.lststType = l.StatusTypeID
		WHERE l.LoadID = @LoadID AND O.CompanyID = @CompanyID
		ORDER BY loadStatus.statusText
	END
	ELSE
	BEGIN
		SELECT 
			l.Loadid,l.LoadNumber,l.IsPartial,l.CarrierID AS CarrierID,
			ISNULL(l.CustomerRatePerMile,0) AS CustomerRatePerMile,
			ISNULL(l.CarrierRatePerMile,0) AS CarrierRatePerMile,
			ISNULL(l.TotalMiles,0) AS CustomerTotalMiles,
			ISNULL(l.TotalMiles,0) AS CarrierTotalMiles,
			ISNULL(l.ARExported,'0') AS ARExportedNN,
			ISNULL(l.APExported,'0') AS APExportedNN,
			ISNULL(l.orderDate, '') AS orderDate,
			ISNULL(l.BillDate, '') AS BillDate,
			ISNULL(l.customerMilesCharges, 0) AS customerMilesCharges,
			ISNULL(l.carrierMilesCharges, 0) AS carrierMilesCharges,
			ISNULL(l.customerCommoditiesCharges, 0) AS customerCommoditiesCharges,
			ISNULL(l.carrierCommoditiesCharges, 0) AS carrierCommoditiesCharges,
			ISNULL(l.CustFlatRate, 0) AS CustFlatRate,
			ISNULL(l.carrFlatRate, 0) AS carrFlatRate,
			l.ModifiedBy,
			l.LastModifiedDate,
			l.EquipmentID,
			l.RefNo,
			l.readyDate,
			l.arriveDate,
			l.isExcused,
			l.bookedBy,
			l.DeadHeadMiles,
			ISNULL(l.posttoITS,0) AS posttoITS,
			postCarrierRatetoITS,
			postCarrierRatetoloadboard,
			postCarrierRatetoTranscore,
			postCarrierRateto123LoadBoard,
			shipperStopDate,
			consigneeStopDate,
			shipperStopTime,
			consigneeStopTime,
			shipperStopTimeIn,
			consigneeStopTimeIn,
			shipperStopTimeOut,
			consigneeStopTimeOut,
			CustomerPONo,
			BOLNum,
			StatusTypeID,
			PricingNotes,
			statusText,
			colorCode,
			L.CustomerID AS PayerID,
			TotalCustomerCharges,
			stops.shipperState,
			stops.shipperCity,
			stops.consigneeState,
			stops.consigneeCity,
			carr.CarrierName,
			Iscarrier,
			CustomerName,
			LoadStopID,
			StopNo,
			[NewPickupDate] as PickupDate,
			[NewPickupTime] as PickupTime,
			[NewDeliveryDate] as DeliveryDate,
			[NewDeliveryTime] as DeliveryTime,
			NewOfficeID,
			NewNotes,
			isPost,
			IsTransCorePst,
			TotalCarrierCharges,
			TotalCustomerCharges,
			NewCarrierID,
			NewCarrierID2,
			NewCarrierID3,
			carrierNotes,
			NewDispatchNotes,
			DispatcherID,
			SalesRepID,
			shipperStopName,
			consigneeStopName,
			shipperLocation,
			consigneeLocation,
			shipperPostalCode,
			consigneePostalCode,
			shipperContactPerson,
			consigneeContactPerson,
			shipperPhone,
			consigneePhone,
			shipperFax,
			consigneeFax,
			shipperEmailID,
			consigneeEmailID,
			shipperReleaseNo,
			consigneeReleaseNo,
			shipperBlind,
			consigneeBlind,
			shipperInstructions,
			consigneeInstructions,
			shipperDirections,
			consigneeDirections,
			shipperLoadStopID,
			consigneeLoadStopID,
			shipperBookedWith,
			consigneeBookedWith,
			shipperEquipmentID,
			consigneeEquipmentID,
			shipperDriverName,
			consigneeDriverName,
			consigneeDriverName2,
			shipperDriverCell,
			consigneeDriverCell,
			shipperTruckNo,
			consigneeTruckNo,
			shipperTrailorNo,
			consigneeTrailorNo,
			shipperRefNo,
			consigneeRefNo,
			shipperMiles,
			consigneeMiles,
			shipperCustomerID,
			consigneeCustomerID
			consigneeCustomerID,EmergencyResponseNo,CODAmt,CODFee,DeclaredValue,postto123loadboard,Notes,invoiceNumber,weight,userDefinedFieldTrucking,CarrierInvoiceNumber
			, emailList, shipperDriverCell2, consigneeDriverCell2, l.CustomerCurrency, l.CarrierCurrency, l.InternalRef
			,l.noOfTrips,l.tripText
			,l.BOLFromName,l.BOLFromTel,l.BOLFromEmail,l.BOLREName,l.BOLREPO
			,temperature
			,temperaturescale
			,l.ediInvoiced
			,l.EDISCAC
			,l.FF
			,l.PODSignature
			,l.MacroPointOrderID
			,l.LoadStatusStopNo
			,l.posttoDirectFreight
			,l.postCarrierRatetoDirectFreight
			,l.PushDataToProject44Api
			,shipperTimeZone
			,consigneeTimeZone
			,l.EquipmentLength
			,CustRep
			,ShipperRep
			,CarrierRep
			,CustRepPercentage
			,ShipperRepPercentage
			,CarrierRepPercentage
			,l.TotalDirectCost
			,l.EquipmentWidth, shipperDriverCell3, consigneeDriverCell3,CriticalNotes 
			,EquipmentTrailer
		FROM LOADS l
		LEFT OUTER JOIN (SELECT 
							a.LoadID,
							a.LoadStopID,a.StopNo,
							a.NewCarrierID,
							a.NewCarrierID2,
							a.NewCarrierID3,
							a.NewOfficeID,
							a.City AS shipperCity,
							b.City AS consigneeCity,
							a.custName AS shipperStopName,
							b.custName AS consigneeStopName,
							a.Address AS shipperLocation,
							b.Address AS consigneeLocation,
							a.PostalCode AS shipperPostalCode,
							b.PostalCode AS consigneePostalCode,
							a.ContactPerson AS shipperContactPerson,
							b.ContactPerson AS consigneeContactPerson,
							a.Phone AS shipperPhone,
							b.Phone AS consigneePhone,
							a.fax AS shipperFax,
							b.fax AS consigneeFax,
							a.EmailID AS shipperEmailID,
							b.EmailID AS consigneeEmailID,
							a.StopDate AS shipperStopDate,
							b.StopDate AS consigneeStopDate,
							a.StopTime AS shipperStopTime,
							b.StopTime AS consigneeStopTime,
							a.TimeIn AS shipperStopTimeIn,
							b.TimeIn AS consigneeStopTimeIn,
							a.TimeOut AS shipperStopTimeOut,
							b.TimeOut AS consigneeStopTimeOut,
							a.ReleaseNo AS shipperReleaseNo,
							b.ReleaseNo AS consigneeReleaseNo,
							a.Blind AS shipperBlind,
							b.Blind AS consigneeBlind,
							a.Instructions AS shipperInstructions,
							b.Instructions AS consigneeInstructions,
							a.Directions AS shipperDirections,
							b.Directions AS consigneeDirections,
							a.LoadStopID AS shipperLoadStopID,
							b.LoadStopID AS consigneeLoadStopID,
							a.NewBookedWith AS shipperBookedWith,
							b.NewBookedWith AS consigneeBookedWith,
							a.NewEquipmentID AS shipperEquipmentID,
							b.NewEquipmentID AS consigneeEquipmentID,
							a.EquipmentTrailer,
							a.NewDriverName AS shipperDriverName,
							b.NewDriverName AS consigneeDriverName,
							b.NewDriverName2 AS consigneeDriverName2,
							a.NewDriverCell AS shipperDriverCell,
							b.NewDriverCell AS consigneeDriverCell,
							a.NewTruckNo AS shipperTruckNo,
							b.NewTruckNo AS consigneeTruckNo,
							a.NewTrailorNo AS shipperTrailorNo,
							b.NewTrailorNo AS consigneeTrailorNo,
							a.RefNo AS shipperRefNo,
							b.RefNo AS consigneeRefNo,
							a.Miles AS shipperMiles,
							b.Miles AS consigneeMiles,
							a.CustomerID AS shipperCustomerID,
							b.CustomerID AS consigneeCustomerID,
							a.StateCode as shipperState,
							b.StateCode as consigneeState, 
							a.NewDriverCell2 AS shipperDriverCell2,
							b.NewDriverCell2 AS consigneeDriverCell2,
							a.NewDriverCell3 AS shipperDriverCell3,
							b.NewDriverCell3 AS consigneeDriverCell3,
							b.temperature,
							b.temperaturescale,
							a.timeZone as shipperTimeZone,
							b.timeZone as consigneeTimeZone
						FROM LoadStops a 
						JOIN LoadStops b on a.LoadID = b.LoadID AND a.StopNo = b.StopNo
						WHERE  a.LoadType = 1 AND b.LoadType = 2 AND a.StopNo =@StopNo AND b.StopNo =@StopNo) as stops  on stops.loadid = l.loadid
		left outer join (SELECT [CarrierID],[CarrierName], Iscarrier FROM [Carriers]  WHERE CompanyID = @CompanyID) as carr on carr.CarrierID = stops.NewCarrierID
		left outer join (SELECT [CarrierOfficeID],[Manager]  FROM [CarrierOffices]) as office on office.CarrierOfficeID = stops.NewOfficeID
		left outer join (SELECT [StatusTypeID] as stTypeId,[statusText], [colorCode] FROM [loadStatusTypes]) as loadStatus on loadStatus.stTypeId = l.StatusTypeID
		left outer join (SELECT [CustomerName],[CustomerID] FROM [Customers] ) as cust on cust.CustomerID = l.CustomerID
		left outer join (SELECT [CustomerID],[OfficeID] FROM [CustomerOffices]) as custOffices on custOffices.CustomerID = cust.CustomerID
		left outer join (SELECT [OfficeID],[CompanyID] FROM [Offices]) as O on O.OfficeID = custOffices.OfficeID
		left outer join (SELECT [StatusTypeID] as lststType,[StatusText] as lStatusText FROM [LoadStatusTypes]) as LStatusTypes on LStatusTypes.lststType = l.StatusTypeID
		WHERE O.CompanyID = @CompanyID
		ORDER BY loadStatus.statusText
	END
END

GO


