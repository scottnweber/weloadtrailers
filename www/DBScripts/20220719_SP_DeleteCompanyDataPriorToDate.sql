GO

/****** Object:  StoredProcedure [dbo].[SP_DeleteCompanyDataPriorToDate]    Script Date: 19-07-2022 13:09:11 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER       proc [dbo].[SP_DeleteCompanyDataPriorToDate]
(
@datePriorTo date
)
AS
BEGIN
	DECLARE @remCount int;
	CREATE TABLE #Companies_Temp
	(
	CompanyID varchar(36),CompanyCode varchar(150)
	)

	INSERT INTO #Companies_Temp
	SELECT TOP 10 CompanyID,CompanyCode FROM Companies WHERE CONVERT(Date, LastModifiedDateTime, 101) <= @datePriorTo AND IsActive = 0
	
	delete from LoadsEDispatchSig where loadid in (select loadid from loads where customerid in (select customerid from CustomerOffices where officeid in (select officeid from offices where CompanyID  IN (SELECT CompanyID FROM #Companies_Temp))))
	delete from LoadsConsolidatedDetail WHERE ConsolidatedID IN (select ID from LoadsConsolidated where customerid in (select customerid from CustomerOffices where officeid in (select officeid from offices where CompanyID  IN (SELECT CompanyID FROM #Companies_Temp))))
	delete from LoadsConsolidated where customerid in (select customerid from CustomerOffices where officeid in (select officeid from offices where CompanyID  IN (SELECT CompanyID FROM #Companies_Temp)))
	delete from FileAttachmentTypes where CompanyID  IN (SELECT CompanyID FROM #Companies_Temp)
	delete from EDispatchLog where CompanyID  IN (SELECT CompanyID FROM #Companies_Temp)
	delete from EmailLogs where CompanyID  IN (SELECT CompanyID FROM #Companies_Temp)
	delete from CsvImportLog where CompanyID  IN (SELECT CompanyID FROM #Companies_Temp)
	delete from LoadComDataLogs where CompanyID  IN (SELECT CompanyID FROM #Companies_Temp)
	delete from LoadLogs where loadid in (select loadid from loads where customerid in (select customerid from CustomerOffices where officeid in (select officeid from offices where CompanyID  IN (SELECT CompanyID FROM #Companies_Temp))))
	delete from MobileAppAccessLogs where loadid in (select loadid from loads where customerid in (select customerid from CustomerOffices where officeid in (select officeid from offices where CompanyID  IN (SELECT CompanyID FROM #Companies_Temp))))
	delete from LoadCarrierQuotes where loadid in (select loadid from loads where customerid in (select customerid from CustomerOffices where officeid in (select officeid from offices where CompanyID  IN (SELECT CompanyID FROM #Companies_Temp))))
	delete from LoadStopCommodities where LoadStopID IN (select LoadStopID from loadstops where loadid in (select loadid from loads where customerid in (select customerid from CustomerOffices where officeid in (select officeid from offices where CompanyID  IN (SELECT CompanyID FROM #Companies_Temp)))))
	delete from LoadStopCargoDeliveryAddress where LoadStopID IN (select LoadStopID from loadstops where loadid in (select loadid from loads where customerid in (select customerid from CustomerOffices where officeid in (select officeid from offices where CompanyID  IN (SELECT CompanyID FROM #Companies_Temp)))))
	delete from LoadStopCargoPickupAddress where LoadStopID IN (select LoadStopID from loadstops where loadid in (select loadid from loads where customerid in (select customerid from CustomerOffices where officeid in (select officeid from offices where CompanyID  IN (SELECT CompanyID FROM #Companies_Temp)))))
	delete from LoadStopEmptyPickupAddress where LoadStopID IN (select LoadStopID from loadstops where loadid in (select loadid from loads where customerid in (select customerid from CustomerOffices where officeid in (select officeid from offices where CompanyID  IN (SELECT CompanyID FROM #Companies_Temp)))))
	delete from LoadStopEmptyReturnAddress where LoadStopID IN (select LoadStopID from loadstops where loadid in (select loadid from loads where customerid in (select customerid from CustomerOffices where officeid in (select officeid from offices where CompanyID  IN (SELECT CompanyID FROM #Companies_Temp)))))
	delete from LoadStopIntermodalExport where LoadStopID IN (select LoadStopID from loadstops where loadid in (select loadid from loads where customerid in (select customerid from CustomerOffices where officeid in (select officeid from offices where CompanyID  IN (SELECT CompanyID FROM #Companies_Temp)))))
	delete from LoadStopIntermodalImport where LoadStopID IN (select LoadStopID from loadstops where loadid in (select loadid from loads where customerid in (select customerid from CustomerOffices where officeid in (select officeid from offices where CompanyID  IN (SELECT CompanyID FROM #Companies_Temp)))))
	delete from LoadStopLoadingAddress where LoadStopID IN (select LoadStopID from loadstops where loadid in (select loadid from loads where customerid in (select customerid from CustomerOffices where officeid in (select officeid from offices where CompanyID  IN (SELECT CompanyID FROM #Companies_Temp)))))
	delete from LoadStopReturnAddress where LoadStopID IN (select LoadStopID from loadstops where loadid in (select loadid from loads where customerid in (select customerid from CustomerOffices where officeid in (select officeid from offices where CompanyID  IN (SELECT CompanyID FROM #Companies_Temp)))))
	delete from loadstops where loadid in (select loadid from loads where customerid in (select customerid from CustomerOffices where officeid in (select officeid from offices where CompanyID  IN (SELECT CompanyID FROM #Companies_Temp))))
	delete from FileAttachments WHERE linked_to = 1 AND linked_Id IN (select LoadID from loads where customerid in (select customerid from CustomerOffices where officeid in (select officeid from offices where CompanyID  IN (SELECT CompanyID FROM #Companies_Temp))))
	delete from FileAttachmentsTemp WHERE linked_to = 1 AND linked_Id IN (select LoadID from loads where customerid in (select customerid from CustomerOffices where officeid in (select officeid from offices where CompanyID  IN (SELECT CompanyID FROM #Companies_Temp))))
	delete from LoadStopsBOL where LoadStopIDBOL in (select loadid from loads where customerid in (select customerid from CustomerOffices where officeid in (select officeid from offices where CompanyID  IN (SELECT CompanyID FROM #Companies_Temp))))
	delete from loads where customerid in (select customerid from CustomerOffices where officeid in (select officeid from offices where CompanyID  IN (SELECT CompanyID FROM #Companies_Temp)))
	delete from CommodityClasses where CompanyID  IN (SELECT CompanyID FROM #Companies_Temp)
	delete from carrier_commodity where carrierid in (select carrierid from Carriers where CompanyID  IN (SELECT CompanyID FROM #Companies_Temp))
	delete from CarrierCRMNotes where carrierid in (select carrierid from Carriers where CompanyID  IN (SELECT CompanyID FROM #Companies_Temp))
	delete from CarrierExpensesRecurring where carrierid in (select carrierid from Carriers where CompanyID  IN (SELECT CompanyID FROM #Companies_Temp))
	delete from CarrierExpenses where carrierid in (select carrierid from Carriers where CompanyID  IN (SELECT CompanyID FROM #Companies_Temp))
	delete from CarrierExpensesSetup where CompanyID  IN (SELECT CompanyID FROM #Companies_Temp)
	delete from lipublicfmcsa where carrierid in (select carrierid from Carriers where CompanyID  IN (SELECT CompanyID FROM #Companies_Temp))
	delete from CarrierContacts where carrierid in (select carrierid from Carriers where CompanyID  IN (SELECT CompanyID FROM #Companies_Temp))
	delete from CarrierOffices where carrierid in (select carrierid from Carriers where CompanyID  IN (SELECT CompanyID FROM #Companies_Temp))
	delete from CarriersLNI where carrierid in (select carrierid from Carriers where CompanyID  IN (SELECT CompanyID FROM #Companies_Temp))
	delete from FileAttachments WHERE linked_to = 3 AND LEN(TRIM(linked_Id)) <> 0 AND linked_Id IN (select carrierid from Carriers where CompanyID  IN (SELECT CompanyID FROM #Companies_Temp))
	delete from FileAttachmentsTemp WHERE linked_to = 3 AND linked_Id IN (select carrierid from Carriers where CompanyID  IN (SELECT CompanyID FROM #Companies_Temp))
	delete from CarrierLanes where carrierid in (select carrierid from Carriers where CompanyID  IN (SELECT CompanyID FROM #Companies_Temp))
	UPDATE LOADS SET CarrierID = NULL WHERE CarrierID IN (SELECT CarrierID FROM Carriers where CompanyID  IN (SELECT CompanyID FROM #Companies_Temp))
	delete from Carriers where CompanyID  IN (SELECT CompanyID FROM #Companies_Temp)
	delete from units where CompanyID  IN (SELECT CompanyID FROM #Companies_Temp)
	delete from EquipmentMaintTrans Where EquipID in (select EquipmentID from Equipments where CompanyID  IN (SELECT CompanyID FROM #Companies_Temp))
	delete from EquipmentMaint Where EquipID in (select EquipmentID from Equipments where CompanyID  IN (SELECT CompanyID FROM #Companies_Temp))
	delete from EquipmentMaintSetup where CompanyID  IN (SELECT CompanyID FROM #Companies_Temp)
	delete from FileAttachments WHERE linked_to = 57 AND linked_Id IN (select EquipmentID from Equipments where CompanyID  IN (SELECT CompanyID FROM #Companies_Temp))
	delete from FileAttachmentsTemp WHERE linked_to = 57 AND linked_Id IN (select EquipmentID from Equipments where CompanyID  IN (SELECT CompanyID FROM #Companies_Temp))
	UPDATE LOADS SET EquipmentID = NULL WHERE EquipmentID IN (SELECT EquipmentID FROM Equipments where CompanyID  IN (SELECT CompanyID FROM #Companies_Temp))
	delete from Equipments where CompanyID  IN (SELECT CompanyID FROM #Companies_Temp)
	delete from FileAttachments WHERE linked_to = 2 AND linked_Id IN (select customerid from CustomerOffices where officeid in (select officeid from offices where CompanyID  IN (SELECT CompanyID FROM #Companies_Temp)))
	delete from FileAttachmentsTemp WHERE linked_to = 2 AND linked_Id IN (select customerid from CustomerOffices where officeid in (select officeid from offices where CompanyID  IN (SELECT CompanyID FROM #Companies_Temp)))
	delete from CRMNotes where customerid in (select customerid from CustomerOffices where officeid in (select officeid from offices where CompanyID  IN (SELECT CompanyID FROM #Companies_Temp)))
	delete from CRMNoteTypes where CompanyID  IN (SELECT CompanyID FROM #Companies_Temp)
	delete from customers where customerid in (select customerid from CustomerOffices where officeid in (select officeid from offices where CompanyID  IN (SELECT CompanyID FROM #Companies_Temp)))
	delete from Factorings where CompanyID  IN (SELECT CompanyID FROM #Companies_Temp)
	delete from CustomerOffices where officeid in (select officeid from offices where CompanyID  IN (SELECT CompanyID FROM #Companies_Temp))
	delete from CustomerContacts where customerid in (select customerid from CustomerOffices where officeid in (select officeid from offices where CompanyID  IN (SELECT CompanyID FROM #Companies_Temp)))
	delete from agentsLoadTypes where agentId in (select employeeid from employees where officeid in (select officeid from offices where CompanyID  IN (SELECT CompanyID FROM #Companies_Temp)))
	delete from FileAttachments WHERE linked_to = 4 AND linked_Id IN (select employeeid from employees where officeid in (select officeid from offices where CompanyID  IN (SELECT CompanyID FROM #Companies_Temp)))
	delete from FileAttachmentsTemp WHERE linked_to = 4 AND linked_Id IN (select employeeid from employees where officeid in (select officeid from offices where CompanyID  IN (SELECT CompanyID FROM #Companies_Temp)))
	UPDATE Loads SET SalesRepID = NULL WHERE SalesRepID IN (select employeeid from employees where officeid in (select officeid from offices where CompanyID  IN (SELECT CompanyID FROM #Companies_Temp)))
	UPDATE Loads SET DispatcherID = NULL WHERE DispatcherID IN (select employeeid from employees where officeid in (select officeid from offices where CompanyID  IN (SELECT CompanyID FROM #Companies_Temp)))
	UPDATE Customers SET SalesRepID = NULL WHERE SalesRepID IN (select employeeid from employees where officeid in (select officeid from offices where CompanyID  IN (SELECT CompanyID FROM #Companies_Temp)))
	UPDATE Customers SET AcctMGRID = NULL WHERE AcctMGRID IN (select employeeid from employees where officeid in (select officeid from offices where CompanyID  IN (SELECT CompanyID FROM #Companies_Temp)))
	delete from employees where officeid in (select officeid from offices where CompanyID  IN (SELECT CompanyID FROM #Companies_Temp))
	UPDATE employees set OfficeID = NULL where officeid in (select officeid from offices where CompanyID  IN (SELECT CompanyID FROM #Companies_Temp))
	UPDATE Customers set OfficeID = NULL where officeid in (select officeid from offices where CompanyID  IN (SELECT CompanyID FROM #Companies_Temp))
	delete from offices where CompanyID  IN (SELECT CompanyID FROM #Companies_Temp)
	UPDATE employees set RoleID = 23 where RoleID in (select RoleID from roles where CompanyID  IN (SELECT CompanyID FROM #Companies_Temp))
	delete from roles where CompanyID  IN (SELECT CompanyID FROM #Companies_Temp)
	delete from SystemConfigOnboardCarrier where CompanyID  IN (SELECT CompanyID FROM #Companies_Temp)
	delete from SystemConfig where CompanyID  IN (SELECT CompanyID FROM #Companies_Temp)
	UPDATE Loads SET StatusTypeID = 'EE3B8206-4B32-4935-B282-A5884A2AA679' WHERE StatusTypeID IN (select StatusTypeID from loadstatustypes where CompanyID  IN (SELECT CompanyID FROM #Companies_Temp))
	delete from loadstatustypes where CompanyID  IN (SELECT CompanyID FROM #Companies_Temp)
	delete from companies where CompanyID IN (SELECT CompanyID FROM #Companies_Temp)
	
	delete from [LMA System Config] where CompanyID IN (SELECT CompanyID FROM #Companies_Temp)
	delete from [LMA System Terms] where CompanyID IN (SELECT CompanyID FROM #Companies_Temp)
	delete from [LMA General Ledger Income Statement Setup] where CompanyID IN (SELECT CompanyID FROM #Companies_Temp)
	delete from [LMA General Ledger Balance Sheet Setup] where CompanyID IN (SELECT CompanyID FROM #Companies_Temp)
	
	delete from [LMA Accounts Payable Check Payment Detail Current] where CompanyID IN (SELECT CompanyID FROM #Companies_Temp)
	delete from [LMA Accounts Payable Check Transaction File] where CompanyID IN (SELECT CompanyID FROM #Companies_Temp)
	delete from [LMA Accounts Payable Check Transaction History] where CompanyID IN (SELECT CompanyID FROM #Companies_Temp)
	delete from [LMA Accounts Payable Invoice Footer History] where CompanyID IN (SELECT CompanyID FROM #Companies_Temp)
	delete from [LMA Accounts Payable Invoice Header History] where CompanyID IN (SELECT CompanyID FROM #Companies_Temp)
	delete from [LMA Accounts Payable Transactions] where CompanyID IN (SELECT CompanyID FROM #Companies_Temp)
	delete from [LMA Accounts Receivable Invoice Footer History] where CompanyID IN (SELECT CompanyID FROM #Companies_Temp)
	delete from [LMA Accounts Receivable Invoice Header History] where CompanyID IN (SELECT CompanyID FROM #Companies_Temp)
	delete from [LMA Accounts Receivable Payment Detail] where CompanyID IN (SELECT CompanyID FROM #Companies_Temp)
	delete from [LMA Accounts Receivable Transactions] where CompanyID IN (SELECT CompanyID FROM #Companies_Temp)
	delete from [LMA Check Register Setup] where CompanyID IN (SELECT CompanyID FROM #Companies_Temp)
	delete from [LMA General Journal Transaction Footer] where CompanyID IN (SELECT CompanyID FROM #Companies_Temp)
	delete from [LMA General Journal Transaction Header] where CompanyID IN (SELECT CompanyID FROM #Companies_Temp)
	delete from [LMA General Ledger Transactions] where CompanyID IN (SELECT CompanyID FROM #Companies_Temp)
	delete from [LMA General Ledger Chart of Accounts] where CompanyID IN (SELECT CompanyID FROM #Companies_Temp)

	INSERT INTO [LoadManagerAdmin].[dbo].[Logs] ([LogDetail],[CreatedBy]) (SELECT CompanyCode+'-Deleted Prior to ' +convert(varchar, @datePriorTo, 101),'lm' FROM #Companies_Temp)

	SET @remCount = (SELECT COUNT(CompanyID) FROM Companies WHERE CONVERT(Date, LastModifiedDateTime, 101) <= @datePriorTo AND IsActive = 0)
	DROP TABLE #Companies_Temp;

	SELECT @remCount AS RemCount
END
GO


