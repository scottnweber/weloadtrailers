
IF NOT EXISTS (SELECT column_name FROM INFORMATION_SCHEMA.columns where table_name = 'Loads' and column_name = 'Dispatcher1')
BEGIN
	ALTER TABLE Loads ADD Dispatcher1 varchar(36);
END

IF NOT EXISTS (SELECT column_name FROM INFORMATION_SCHEMA.columns where table_name = 'Loads' and column_name = 'Dispatcher1Percentage')
BEGIN
	ALTER TABLE Loads ADD Dispatcher1Percentage float not null default 0;
END

IF NOT EXISTS (SELECT column_name FROM INFORMATION_SCHEMA.columns where table_name = 'Loads' and column_name = 'Dispatcher2')
BEGIN
	ALTER TABLE Loads ADD Dispatcher2 varchar(36);
END

IF NOT EXISTS (SELECT column_name FROM INFORMATION_SCHEMA.columns where table_name = 'Loads' and column_name = 'Dispatcher2Percentage')
BEGIN
	ALTER TABLE Loads ADD Dispatcher2Percentage float not null default 0;
END

IF NOT EXISTS (SELECT column_name FROM INFORMATION_SCHEMA.columns where table_name = 'Loads' and column_name = 'Dispatcher3')
BEGIN
	ALTER TABLE Loads ADD Dispatcher3 varchar(36);
END

IF NOT EXISTS (SELECT column_name FROM INFORMATION_SCHEMA.columns where table_name = 'Loads' and column_name = 'Dispatcher3Percentage')
BEGIN
	ALTER TABLE Loads ADD Dispatcher3Percentage float not null default 0;
END


GO

/****** Object:  StoredProcedure [dbo].[USP_GetLoadDetails]    Script Date: 3/10/2022 4:37:06 PM ******/
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


GO

/****** Object:  StoredProcedure [dbo].[USP_InsertLoad]    Script Date: 3/10/2022 4:41:32 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER                   proc [dbo].[USP_InsertLoad]
(
@loadManualNo bigint,
@customerid varchar(200),
@salesperson VARCHAR(500),
@CarrierInvoiceNumber bigint,
@dispatcher VARCHAR(500),
@Status varchar(200),
@posttoloadboard bit,
@posttoTranscore bit, 
@PostTo123LoadBoard bit,
@postCarrierRatetoloadboard bit ,
@postCarrierRatetoTranscore bit ,
@postCarrierRateto123LoadBoard bit ,
@notes VARCHAR(1000),
@dispatchnotes VARCHAR(8000),
@carriernotes VARCHAR(1000),
@PricingNotes VARCHAR(1000),
@ponumber VARCHAR(100),
@bolnumber VARCHAR(100),
@TotalCarrierCharges VARCHAR(100),
@TotalCustomerCharges VARCHAR(100),
@CarrierRate money,
@CustomerRate money,
@carrierid varchar(200) = null,
@carrierOfficeID varchar(200) = null,
@equipment varchar(200) = null,
@driver VARCHAR(100),
@drivercell VARCHAR(50),
@trucknumber VARCHAR(50),
@trailernumber VARCHAR(50),
@BookedWith varchar(200),
@PickupNO nvarchar(50),
@PickupDate datetime=null,
@PickupTime nvarchar(50),
@PickupTimeIn nvarchar(50),
@PickupTimeOut nvarchar(50),
@DeliveryNo nvarchar(50),
@DeliveryDate datetime=null,
@DeliveryTime nvarchar(50),
@DeliveryTimeIn nvarchar(50),
@DeliveryTimeOut nvarchar(50),
@ModifyBy nvarchar(40),
@CreatedIP nvarchar(50),
@GUID text,
@CustomerRatePerMile money,
@CarrierRatePerMile money,
@CustomerTotalMiles float,
@CarrierTotalMiles float,
@officeid varchar(200),
@orderDate date,
@BillDate date,
@ARExported nvarchar(1),
@APExported nvarchar(1),
@customerMilesCharges money,
@carrierMilesCharges money,
@customerCommoditiesCharges money,
@carrierCommoditiesCharges money,
@CustomerAddress nvarchar(200)=null,
@CustomerCity nvarchar(50)=null,
@CustomerState nvarchar(50)=null,
@CustomerPostalCode nvarchar(50)=null,
@CustomerContact nvarchar(100)=null,
@CustomerPhone nvarchar(30)=null,
@CustomerFax nvarchar(30)=null,
@CustomerCell nvarchar(50)=null,
@CustName nvarchar(100)=null,
@invoiceNumber int,
@weight int,
@CarrierId2 nvarchar(200)=null,-- I dont know whts the purpose of carrierid defined earlier --
@ShipperState nvarchar(10)=null,
@ShipperCity nvarchar(50)=null,
@ConsigneeState nvarchar(10)=null,
@ConsigneeCity nvarchar(50)=null,
@SalesAgentId nvarchar(50)=null,
@EquipmentId nvarchar(200),
@CustomerCurrency int = null,
@CarrierCurrency int = null,
@IsConcatCarrierDriverIdentifier bit,
@InternalRef varchar(50) = null
,@noOfTrips int = null
,@FF float 
,@EquipmentLength float,
@CustRep varchar(150),
@ShipperRep varchar(150),
@CarrierRep varchar(150),
@CustRepPercentage float,
@ShipperRepPercentage float,
@CarrierRepPercentage float,
@TotalDirectCost money,
@EquipmentWidth float,
@ContactEmail varchar(150),
@CustomDriverPay bit = 0,
@CriticalNotes varchar(40),
@Dispatcher1 varchar(150),
@Dispatcher2 varchar(150),
@Dispatcher3 varchar(150),
@Dispatcher1Percentage float,
@Dispatcher2Percentage float,
@Dispatcher3Percentage float,
@userDefinedFieldTrucking varchar(255)=null
)
as
begin
--set @carrierID = null
--set @carrierOfficeID = null

if ltrim(Rtrim(IsNull(@carrierID, ''))) = ''
	set @carrierID = null

if ltrim(Rtrim(IsNull(@carrierOfficeID, ''))) = ''
		set @carrierOfficeID = null

if ltrim(Rtrim(IsNull(@equipment, ''))) = ''
		set @equipment = null

if ltrim(Rtrim(IsNull(@PickupDate, ''))) = ''
		set @PickupDate = null
		
if ltrim(Rtrim(IsNull(@DeliveryDate, ''))) = ''
		set @DeliveryDate = null

if ltrim(Rtrim(IsNull(@officeid, ''))) = ''
		set @officeid = null

if ltrim(Rtrim(IsNull(@orderDate, ''))) = ''
		set @orderDate = null
if ltrim(Rtrim(IsNull(@BillDate, ''))) = ''
		set @BillDate = null
-- customer id
-- sales person
-- dispatcher
-- Status
-- post to load board
-- notes
-- dispatch notes
-- po number
-- miles

-- return generated load ID

declare @generatedloadID uniqueidentifier
set @generatedloadID = NewID()

declare @CompanyID uniqueidentifier
SELECT TOP 1 @CompanyID=[CompanyID] FROM [Companies]


if ltrim(Rtrim(IsNull(@ShipperState, ''))) = ''
		set @ShipperState = null


if ltrim(Rtrim(IsNull(@ShipperCity, ''))) = ''
		set @ShipperCity = null


if ltrim(Rtrim(IsNull(@ConsigneeState, ''))) = ''
		set @ConsigneeState = null

		
if ltrim(Rtrim(IsNull(@ConsigneeCity, ''))) = ''
		set @ConsigneeCity = null
		
DECLARE @SalesAgentName nvarchar(50) 
set @SalesAgentName = null
IF (ltrim(Rtrim(IsNull(@SalesAgentId, ''))) != '')
 SELECT TOP 1 @SalesAgentName = Name FROM [dbo].[Employees] where EmployeeID = ltrim(Rtrim(@SalesAgentId))


DECLARE @EquipmentName nvarchar(200)
set @EquipmentName = null
IF (ltrim(Rtrim(IsNull(@EquipmentId, ''))) != '')
 Select @EquipmentName = EquipmentName from [dbo].[Equipments] where EquipmentID = @EquipmentId


DECLARE @CarrierName nvarchar(200), @DriverName nvarchar(200)

IF (ltrim(Rtrim(IsNull(@CarrierId2, ''))) != '')
BEGIN
	IF ((select IsCarrier from [Carriers] where CarrierID = @CarrierId2) = 1)
	BEGIN
		select top 1 @CarrierName=CarrierName from [Carriers] where CarrierID = @CarrierId2;
		set @DriverName = null
	END
	ELSE
	BEGIN
		select top 1 @DriverName=CarrierName from [Carriers] where CarrierID = @CarrierId2;
		set @CarrierName = null
	END
END


IF (@IsConcatCarrierDriverIdentifier = 1 AND ltrim(Rtrim(IsNull(@CarrierId2, ''))) != '')
BEGIN
	DECLARE @TempDispatchNotes varchar(4000)
	DECLARE @TempModifyBy varchar(100)
	DECLARE @LastChangeDate as varchar(100)
	DECLARE @DriverCarrier as varchar(100)

	SELECT @TempModifyBy = Name FROM Employees WHERE Employees.loginid = @ModifyBy
	SELECT @LastChangeDate = replace(CONVERT(CHAR(10),getdate(),110), '-', '/') + SUBSTRING(CONVERT(varchar,getdate(),0),12,8) 
	
	IF ((select IsCarrier from [Carriers] where CarrierID = @CarrierId2) = 1)
	BEGIN		
		set @loadManualNo = CONCAT('1', @loadManualNo)
		set @TempDispatchNotes = @LastChangeDate+' - '+@TempModifyBy+' > Carrier '+@CarrierName+'  is added to the load (New Load Number is '+ltrim(Rtrim(CONVERT(CHAR(20),@loadManualNo)))+')'

		IF (ltrim(Rtrim(IsNull(@dispatchnotes, ''))) != '')
		BEGIN
			set @dispatchnotes = CONCAT(@dispatchnotes, @TempDispatchNotes)	
		END
		ELSE
		BEGIN
			set @dispatchnotes =  @TempDispatchNotes
		END
	END
	ELSE
	BEGIN		
		set @loadManualNo = CONCAT('2', @loadManualNo)
		set @TempDispatchNotes = @LastChangeDate+' - '+@TempModifyBy+' > Driver '+@DriverName+'  is added to the load (New Load Number is '+ltrim(Rtrim(CONVERT(CHAR(20),@loadManualNo)))+')'

		IF (ltrim(Rtrim(IsNull(@dispatchnotes, ''))) != '')
		BEGIN
			set @dispatchnotes = CONCAT(@dispatchnotes, @TempDispatchNotes)	
		END
		ELSE
		BEGIN
			set @dispatchnotes =  @TempDispatchNotes
		END
	END
END


--set @str1='
INSERT INTO Loads
(LoadID,
LoadNumber,
ControlNumber,
CreatedDateTime,
SalesRepID, 
DispatcherID,
CustomerPONo,
BOLNum,
StatusTypeID,
CustomerID,
IsPost,
IsTransCorePst,
PostTo123LoadBoard,
postCarrierRatetoloadboard,
postCarrierRatetoTranscore,
postCarrierRateto123LoadBoard,
TotalCarrierCharges,
TotalCustomerCharges,
LastModifiedDate,
CreatedBy,
ModifiedBy,
HasEnrouteStops,HasTemp,
IsPepUpload,
IsLocked,
NewNotes,
NewDispatchNotes,
carrierNotes,
PricingNotes,
CustFlatRate,
CarrFlatRate,
EquipmentID,
DriverName,
DriverCell,
TruckNo,
TrailorNo,
newbookedwithload,
NewPickupNo,
NewPickupDate,
NewPickupTime,
NewPickupTimeIn,
NewPickupTimeOut,
NewDeliveryNo,
NewDeliveryDate,
NewDeliveryTime,
NewDeliveryDateTimeIn,
NewDeliveryDateTimeOut,
CarrierID,
CarrOfficeID,
CreatedByIP,
CustomerRatePerMile,
CarrierRatePerMile,
TotalMiles,
orderDate,
BillDate,
ARExported,
APExported,
customerMilesCharges,
carrierMilesCharges,
customerCommoditiesCharges,
carrierCommoditiesCharges,
Address,							
City,								
StateCode,							
PostalCode,							
ContactPerson,						
Phone,								
Fax,								
CellNo,
CustName,
invoiceNumber,
weight,
CarrierInvoiceNumber,
ShipperState,
ShipperCity,
ConsigneeState,
ConsigneeCity,
SalesAgent,
EquipmentName,
CarrierName,
LoadDriverName,
CustomerCurrency,
CarrierCurrency,
InternalRef
,noOfTrips
,FF
,EquipmentLength
,CustRep
,ShipperRep
,CarrierRep
,CustRepPercentage
,ShipperRepPercentage
,CarrierRepPercentage
,TotalDirectCost
,EquipmentWidth
,ContactEmail
,userDefinedFieldTrucking
,CustomDriverPay
,CriticalNotes
,Dispatcher1
,Dispatcher2
,Dispatcher3
,Dispatcher1Percentage
,Dispatcher2Percentage
,Dispatcher3Percentage
)

VALUES
(@generatedloadID, 
@loadManualNo,
@loadManualNo,
GETDATE(),
@salesperson,
@dispatcher,
@ponumber,
@bolnumber,
@Status,
@customerid,
@posttoloadboard,
@posttoTranscore,
@PostTo123LoadBoard,
@postCarrierRatetoloadboard,
@postCarrierRatetoTranscore,
@postCarrierRateto123LoadBoard,
@TotalCarrierCharges,
@TotalCustomerCharges,

GETDATE(),
@ModifyBy,
@ModifyBy,
0,0,0,0,
@notes,@dispatchnotes,@carriernotes,@PricingNotes,@CustomerRate, @CarrierRate,
@equipment,
@driver,
@drivercell,
@trucknumber,
@trailernumber,
@BookedWith,
@PickupNO ,
@PickupDate ,
@PickupTime ,
@PickupTimeIn,
@PickupTimeOut ,
@DeliveryNo ,
@DeliveryDate ,
@DeliveryTime ,
@DeliveryTimeIn ,
@DeliveryTimeOut,
@CarrierID,
@carrierOfficeID,
@CreatedIP,
@CustomerRatePerMile, 
@CarrierRatePerMile,
@CustomerTotalMiles, 
@orderDate,
@BillDate,
@ARExported,
@APExported,
@customerMilesCharges,
@carrierMilesCharges,
@customerCommoditiesCharges,
@carrierCommoditiesCharges,
@CustomerAddress,
@CustomerCity,
@CustomerState,
@CustomerPostalCode,
@CustomerContact,
@CustomerPhone,
@CustomerFax,
@CustomerCell,
@CustName,
@invoiceNumber,
@weight,
@CarrierInvoiceNumber,
@ShipperState,
@ShipperCity,
@ConsigneeState,
@ConsigneeCity,
@SalesAgentName,
@EquipmentName,
@CarrierName,
@DriverName,
@CustomerCurrency,
@CarrierCurrency,
@InternalRef
,@noOfTrips
,@FF
,@EquipmentLength
,@CustRep
,@ShipperRep
,@CarrierRep
,@CustRepPercentage
,@ShipperRepPercentage
,@CarrierRepPercentage
,@TotalDirectCost
,@EquipmentWidth
,@ContactEmail
,@userDefinedFieldTrucking
,@CustomDriverPay
,@CriticalNotes
,@Dispatcher1
,@Dispatcher2
,@Dispatcher3
,@Dispatcher1Percentage
,@Dispatcher2Percentage
,@Dispatcher3Percentage
)
--exec sp_executesql @str1

select @generatedloadID as lastLoadId,@loadManualNo as impref
end

--exec sp_executesql @FinalSQL






/*    ==Scripting Parameters==

    Source Server Version : SQL Server 2016 (13.0.4001)
    Source Database Engine Edition : Microsoft SQL Server Enterprise Edition
    Source Database Engine Type : Standalone SQL Server

    Target Server Version : SQL Server 2017
    Target Database Engine Edition : Microsoft SQL Server Standard Edition
    Target Database Engine Type : Standalone SQL Server
*/



GO



