<cfparam name="CarrierHead" default="">
<cfparam name="CustInvHead" default="">
<cfparam name="BOLHead" default="">
<cfparam name="WorkImpHead" default="">
<cfparam name="WorkExpHead" default="">
<cfparam name="bitDuplicate" default="0">
<cfparam name="SalesHead" default=""> 
<cfparam name="EDispatchHead" default="">

<cfparam name="variables.DashboardUser" default="dash#RandRange(1000, 9999)#">
<cfparam name="variables.DashboardPassword" default="#RandRange(100000, 999999)#">

<cfset message = "">
<cfsilent>
<cfinvoke component="#variables.objloadGateway#" method="getSystemSetupOptions" returnvariable="request.qGetSystemSetupOptionsLoadNumber" />

<cfif isDefined('FORM.submitSystemConfig')>	
	
    <cfif isdefined("FORM.DispatchNotes")>
		<cfset dispatch_notes = true>
    <cfelse>
    	<cfset dispatch_notes = false>
    </cfif>
    
    <cfif isdefined("FORM.CarrierNotes")>
		<cfset carrier_notes = true>
    <cfelse>
    	<cfset carrier_notes = false>
    </cfif>
    
    <cfif isdefined("FORM.Notes")>
		<cfset simple_notes = true>
    <cfelse>
    	<cfset simple_notes = false>
    </cfif>
	
	<cfif isdefined("FORM.commodityWeight")>
		<cfset commodityWeight = true>
    <cfelse>
    	<cfset commodityWeight = false>
    </cfif>
	
	<cfif isdefined("FORM.chkValidMCNumber")>
		<cfset requireValidMCNumber = true>
    <cfelse>
    	<cfset requireValidMCNumber = false>
    </cfif>
	<cfif isdefined("FORM.integratewithTran360")>
		<cfset integratewithTran360 = true>
	<cfelse>
		<cfset integratewithTran360 = false>
	</cfif>
	<cfif isdefined("FORM.AllowLoadentry")>
		<cfset AllowLoadentry = true>
	<cfelse>
		<cfset AllowLoadentry = false>
	</cfif>
	<cfif isdefined("FORM.EDIloadStatus")>
		<cfset EDIloadStatus = FORM.EDIloadStatus>
	</cfif>

	<cfif isdefined("FORM.lockloadstatus")>
		<cfset lockloadstatus = FORM.lockloadstatus>
	<cfelse>
		<cfset lockloadstatus = "none">
	</cfif>
	
	<cfif isdefined("FORM.rowsperpage")>
		<cfset rowsperpage = FORM.rowsperpage>
	<cfelse>
		<cfset rowsperpage = "">
	</cfif>



	<cfif structKeyExists(form, "showcarrieramount") AND len(form.showcarrieramount)>
		<cfset showcarrieramount = 1>
	<cfelse>	
		<cfset showcarrieramount = 0>
	</cfif>

	<cfif structKeyExists(form, "editDispatchNotes") AND len(form.editDispatchNotes)>
		<cfset editDispatchNotes = 1>
	<cfelse>	
		<cfset editDispatchNotes = 0>
	</cfif>

	<cfif structKeyExists(form, "showcustomeramount") AND len(form.showcustomeramount)>
		<cfset showcustomeramount = 1>
	<cfelse>	
		<cfset showcustomeramount = 0>
	</cfif>



	
	<cfif isdefined("FORM.userDef1")>
		<cfset userDef1 = FORM.userDef1>
	<cfelse>
		<cfset userDef1 = "">
	</cfif>
	<cfif isdefined("FORM.userDef2")>
		<cfset userDef2 = FORM.userDef2>
	<cfelse>
		<cfset userDef2 = "">
	</cfif>
	<cfif isdefined("FORM.userDef3")>
		<cfset userDef3 = FORM.userDef3>
	<cfelse>
		<cfset userDef3 = "">
	</cfif>
	<cfif isdefined("FORM.userDef4")>
		<cfset userDef4 = FORM.userDef4>
	<cfelse>
		<cfset userDef4 = "">
	</cfif>
	<cfif isdefined("FORM.userDef5")>
		<cfset userDef5 = FORM.userDef5>
	<cfelse>
		<cfset userDef5 = "">
	</cfif>
	<cfif isdefined("FORM.userDef6")>
		<cfset userDef6 = FORM.userDef6>
	<cfelse>
		<cfset userDef6 = "">
	</cfif>
	<cfif isdefined("FORM.userDef7")>
		<cfif len(trim(FORM.userDef7))>
			<cfset userDef7 = FORM.userDef7>
		<cfelse>
			<cfset userDef7 = 'userDef7'>
		</cfif>	
	</cfif>
	<cfif isdefined("FORM.minimunLoadNumber")>
		<cfset minimunLoadNumber = FORM.minimunLoadNumber>
	<cfelse>
		<cfset minimunLoadNumber = "">
	</cfif>
	<cfset showReadyArriveDat = false>
	<cfif structKeyExists(FORM,"showReadyArriveDat")>
		<cfset showReadyArriveDat = true>
	</cfif>
	
	<cfif isdefined("FORM.statusDispatchNote")>
		<cfset statusDispatchNote = true>
    <cfelse>
    	<cfset statusDispatchNote = false>
    </cfif>

    <cfif isdefined("FORM.rolloverShipDate")>
		<cfset rolloverShipDateStatus = true>
    <cfelse>
    	<cfset rolloverShipDateStatus = false>
    </cfif>
	
	<cfif isdefined("FORM.showExpCarriers")>
		<cfset showExpCarriers = true>
    <cfelse>
    	<cfset showExpCarriers = false>
    </cfif>
	
	<cfif isdefined("FORM.showCarrierInvoiceNumber")>
		<cfset showCarrierInvoiceNumber = true>
    <cfelse>
    	<cfset showCarrierInvoiceNumber = false>
    </cfif>
	
	<cfif isdefined("FORM.ShowCarrierInvoiceNumberInAllLoads") AND isdefined("FORM.showCarrierInvoiceNumber")>
		<cfset ShowCarrierInvoiceNumberInAllLoads = 1>
    <cfelse>
    	<cfset ShowCarrierInvoiceNumberInAllLoads = 0>
    </cfif>
	
    <cfif structKeyExists(FORM, "CopyLoadIncludeAgentAndDispatcher")>
		<cfset CopyLoadIncludeAgentAndDispatcher = 1>
    <cfelse>
    	<cfset CopyLoadIncludeAgentAndDispatcher = 0>
    </cfif>
	
	<cfif structKeyExists(FORM, "LoadNumberAutoIncrement")>
		<cfset LoadNumberAutoIncrement = 1>
    <cfelse>
    	<cfset LoadNumberAutoIncrement = 0>
    </cfif>	
	
	<cfif structKeyExists(FORM, "StartingActiveLoadNumber") AND form.StartingActiveLoadNumber NEQ "">
		<cfinvoke component="#variables.objloadGateway#" method="checkForDuplicateLoadNumber"  dsn="#application.dsn#" LoadNumber="#FORM.StartingActiveLoadNumber#"   returnvariable="bitDuplicate" /> 		
		<cfif bitDuplicate GT 0 >
			<cfset form.StartingActiveLoadNumber = "">			
		</cfif>
	</cfif>
	
	<cfif isdefined("FORM.EmailReports")>
		<cfset emailReports = true>
    <cfelse>
    	<cfset emailReports = false>
    </cfif>
	<cfif isdefined("FORM.PrintReports")>
		<cfset printReports = true>
    <cfelse>
    	<cfset printReports = false>
    </cfif>
	<cfif request.qGetSystemSetupOptionsLoadNumber.MinimumLoadInvoiceNumber eq 0>
		<cfset loadNumberAssignment=request.qGetSystemSetupOptionsLoadNumber.loadNumberAssignment>
	<cfelse>
		<cfif structKeyExists(FORM,"LoadNumberAssignment")>
			<cfset loadNumberAssignment=form.LoadNumberAssignment>
		<cfelse>
			<cfset loadNumberAssignment=0>
		</cfif>
	</cfif>
	<cfif isdefined("FORM.CheckVendorCode")>
		<cfset checkVendorCode = 1>
    <cfelse>
    	<cfset checkVendorCode = 0>
    </cfif>
	<cfif structKeyExists(FORM, "LoadLimit")>
		<cfset LoadLimit = val(form.LoadLimit)>
    <cfelse>
    	<cfset LoadLimit = 0>
    </cfif>
	<cfif structKeyExists(form, "IsLoadLogEnabled") AND len(form.IsLoadLogEnabled)>
		<cfset IsLoadLogEnabled = 1>
	<cfelse>	
		<cfset IsLoadLogEnabled = 0>
	</cfif>
	<cfif structKeyExists(form, "LoadLogLimit") AND len(form.LoadLogLimit)>
		<cfset LoadLogLimit = Val(form.LoadLogLimit)>
	<cfelse>	
		<cfset LoadLogLimit = 30>
	</cfif>
	<cfif structKeyExists(form, "ForeignCurrencyEnabled") AND len(form.ForeignCurrencyEnabled)>
		<cfset ForeignCurrencyEnabled = 1>
	<cfelse>	
		<cfset ForeignCurrencyEnabled = 0>
	</cfif>
	<cfif structKeyExists(FORM, "defaultSystemCurrency")>
		<cfset DefaultSystemCurrency = val(form.defaultSystemCurrency)>
    <cfelse>
    	<cfset DefaultSystemCurrency = 1>
    </cfif>
	
	<cfif structKeyExists(FORM, "googleMapsPcMiler") AND form.googleMapsPcMiler EQ 2 AND NOT len(PCMilerAPIKey) >
		<cfset googleMapsPcMiler = 0>
		<cfset message &= " PCMiler API key not given, Google Maps selected instead.">
    </cfif>
    <cfif structKeyExists(form, "includeLoadNumber") AND len(form.includeLoadNumber)>
		<cfset includeLoadNumber = 1>
	<cfelse>	
		<cfset includeLoadNumber = 0>
	</cfif> 
	<cfif structKeyExists(form, "activateBulkAndLoadNotificationEmail") AND len(form.activateBulkAndLoadNotificationEmail)>
		<cfset activateBulkAndLoadNotificationEmail = 1>
	<cfelse>	
		<cfset activateBulkAndLoadNotificationEmail = 0>
	</cfif>
	
	<cfif structKeyExists(FORM, "getFMCSAFrom") AND form.getFMCSAFrom EQ 1>
		<cfset getFMCSAFrom = 1>
	<cfelse>
		<cfset getFMCSAFrom = 0>
	</cfif>
	<!--- BEGIN: Settings to switch between Smart Phone e-Dispatch and Web e-Dispatch --->
	<cfif structKeyExists(FORM, "isEDispatchSmartPhone") AND len(form.isEDispatchSmartPhone)>
		<cfset IsEDispatchSmartPhone = 1>
	<cfelse>
		<cfset IsEDispatchSmartPhone = 0>
	</cfif>
	<!--- END: Settings to switch between Smart Phone e-Dispatch and Web e-Dispatch --->
	<!--- BEGIN: System setup option to lock the load Order Date --->
	<cfif structKeyExists(FORM, "isLockOrderDate") AND len(form.isLockOrderDate)>
		<cfset IsLockOrderDate = 1>
	<cfelse>
		<cfset IsLockOrderDate = 0>
	</cfif>
	<!--- END: System setup option to lock the load Order Date --->
	<!--- BEGIN: 604: Add a column to All Loads/ My Loads --->
	<cfif structKeyExists(form, "showMiles") AND len(form.showMiles)>
		<cfset ShowMiles = 1>
	<cfelse>	
		<cfset ShowMiles = 0>
	</cfif>
	<!--- END: 604: Add a column to All Loads/ My Loads --->
	<!--- BEGIN: 604: Add a column to All Loads/ My Loads : Add DeadHead Miles for Load--->
	<cfif structKeyExists(form, "showDeadHeadMiles") AND len(form.showDeadHeadMiles)>
		<cfset ShowDeadHeadMiles = 1>
	<cfelse>	
		<cfset ShowDeadHeadMiles = 0>
	</cfif>
	<!--- END: 604: Add a column to All Loads/ My Loads : Add DeadHead Miles for Load--->
	<cfif structKeyExists(form, "MyCarrierPackets") AND len(form.MyCarrierPackets)>
		<cfset MyCarrierPackets = 1>
	<cfelse>	
		<cfset MyCarrierPackets = 0>
	</cfif>
	<cfif structKeyExists(form, "MyCarrierPacketsUsername") AND len(form.MyCarrierPacketsUsername)>
		<cfset MyCarrierPacketsUsername = form.MyCarrierPacketsUsername>
	<cfelse>	
		<cfset MyCarrierPacketsUsername = "">
	</cfif>
	<cfif structKeyExists(form, "MyCarrierPacketsPassword") AND len(form.MyCarrierPacketsPassword)>
		<cfset MyCarrierPacketsPassword = form.MyCarrierPacketsPassword>
	<cfelse>	
		<cfset MyCarrierPacketsPassword = "">
	</cfif>
	<cfif structKeyExists(form, "CustomerLNI")>
		<cfset CustomerLNI=form.CustomerLNI>
	<cfelse>
		<cfset CustomerLNI="">
	</cfif>
	<cfif structKeyExists(form, "CarrierLNI")>
		<cfset CarrierLNI=form.CarrierLNI>
	<cfelse>
		<cfset CarrierLNI="">
	</cfif>
	<cfif structKeyExists(form, "EDispatchOptions")>
		<cfset EDispatchOptions=form.EDispatchOptions>
	<cfelse>
		<cfset EDispatchOptions="">
	</cfif>
	<cfif structKeyExists(form, "GPSUpdateInterval")>
		<cfset GPSUpdateInterval=form.GPSUpdateInterval>
	<cfelse>
		<cfset GPSUpdateInterval=0>
	</cfif>

	<cfif structKeyExists(form, "editCreditLimit")>
		<cfset editCreditLimit=1>
	<cfelse>
		<cfset editCreditLimit=0>
	</cfif>

	<cfif structKeyExists(form, "showScanButton")>
		<cfset showScanButton=1>
	<cfelse>
		<cfset showScanButton=0>
	</cfif>
	<cfif structKeyExists(form, "ComDataUnitID")>
		<cfset ComDataUnitID=form.ComDataUnitID>
	<cfelse>
		<cfset ComDataUnitID="">
	</cfif>
	<cfif structKeyExists(form, "ComDataCustomerID")>
		<cfset ComDataCustomerID=form.ComDataCustomerID>
	<cfelse>
		<cfset ComDataCustomerID="">
	</cfif>
	<cfif structKeyExists(form, "autoAddCustViaDOT")>
		<cfset autoAddCustViaDOT=1>
	<cfelse>
		<cfset autoAddCustViaDOT=0>
	</cfif>
	<cfif structKeyExists(form, "includeNumberofTripsInReports")>
		<cfset includeNumberofTripsInReports=1>
	<cfelse>
		<cfset includeNumberofTripsInReports=0>
	</cfif>
	<cfif structKeyExists(form, "forceUserToEnterTrip")>
		<cfset forceUserToEnterTrip=1>
	<cfelse>
		<cfset forceUserToEnterTrip=0>
	</cfif>
	<cfif structKeyExists(form, "AutomaticFactoringFee")>
		<cfset AutomaticFactoringFee = 1>
		<cfset FactoringFee = FORM.FactoringFee>		
	<cfelse>	
		<cfset AutomaticFactoringFee = 0>
		<cfset FactoringFee = 0>
	</cfif>
	<cfif structKeyExists(form, "Edi210EsignReq") AND len(form.Edi210EsignReq)>
		<cfset Edi210EsignReq = 1>
	<cfelse>	
		<cfset Edi210EsignReq = 0>
	</cfif>
	<cfif structKeyExists(form, "ShowLoadTypeStatusOnLoadsScreen")>
		<cfset ShowLoadTypeStatusOnLoadsScreen = 1>
	<cfelse>	
		<cfset ShowLoadTypeStatusOnLoadsScreen = 0>
	</cfif>
	<cfif structKeyExists(form, "UpdateCustomerFromLoadScreen")>
		<cfset UpdateCustomerFromLoadScreen = 1>
	<cfelse>	
		<cfset UpdateCustomerFromLoadScreen = 0>
	</cfif>
	<cfif structKeyExists(form, "sortedLoadColumns")>
		<cfset LoadsColumns = '#Form.sortedLoadColumns#'>
	<cfelse>	
		<cfset LoadsColumns = "">
	</cfif>

	<cfif structKeyExists(form, "statusLoadColumns")>
		<cfset LoadsColumnsStatus = '#Form.statusLoadColumns#'>
	<cfelse>	
		<cfset LoadsColumnsStatus = "">
	</cfif>
	<cfif structKeyExists(form, "IsLoadStatusDefaultForReport")>
		<cfset IsLoadStatusDefaultForReport = 1>
	<cfelse>	
		<cfset IsLoadStatusDefaultForReport = 0>
	</cfif>
	<cfif isdefined("FORM.AllowBooking")>
		<cfset AllowBooking = true>
    <cfelse>
    	<cfset AllowBooking = false>
    </cfif>
    <cfif structKeyExists(form, "ShowLoadStatusOnMobileApp")>
		<cfset ShowLoadStatusOnMobileApp = 1>
	<cfelse>	
		<cfset ShowLoadStatusOnMobileApp = 0>
	</cfif>
	<cfif structKeyExists(form, "TurnOnConsolidatedInvoices")>
		<cfset TurnOnConsolidatedInvoices = 1>
	<cfelse>	
		<cfset TurnOnConsolidatedInvoices = 0>
	</cfif>
	<cfif structKeyExists(form, "MacropointId")>
		<cfset MacropointId = '#Form.MacropointId#'>
	<cfelse>	
		<cfset MacropointId = "">
	</cfif>
	<cfif structKeyExists(form, "MacropointApiLogin")>
		<cfset MacropointApiLogin = '#Form.MacropointApiLogin#'>
	<cfelse>	
		<cfset MacropointApiLogin = "">
	</cfif>
	<cfif structKeyExists(form, "MacropointApiPassword")>
		<cfset MacropointApiPassword = '#Form.MacropointApiPassword#'>
	<cfelse>	
		<cfset MacropointApiPassword = "">
	</cfif>
	<cfif structKeyExists(form, "Project44")>
		<cfset Project44 = 1>
	<cfelse>	
		<cfset Project44 = 0>
	</cfif>
	<cfif structKeyExists(form, "SendEmailNoticeMacroPoint")>
		<cfset SendEmailNoticeMacroPoint = 1>
	<cfelse>	
		<cfset SendEmailNoticeMacroPoint = 0>
	</cfif>
	<cfif structKeyExists(form, "TimeZone")>
		<cfset TimeZone = 1>
	<cfelse>	
		<cfset TimeZone = 0>
	</cfif>
	<cfif structKeyExists(form, "UseNonFeeAccOnBOL")>
		<cfset UseNonFeeAccOnBOL = 1>
	<cfelse>	
		<cfset UseNonFeeAccOnBOL = 0>
	</cfif>
	<cfif structKeyExists(form, "ReqAddressWhenAddingCust")>
		<cfset ReqAddressWhenAddingCust = 1>
	<cfelse>	
		<cfset ReqAddressWhenAddingCust = 0>
	</cfif>
	<cfif structKeyExists(form, "IncludeDhMilesInTotalMiles")>
		<cfset IncludeDhMilesInTotalMiles = 1>
	<cfelse>	
		<cfset IncludeDhMilesInTotalMiles = 0>
	</cfif>
	<cfif structKeyExists(form, "ShowCarrierNotesOnMobileApp")>
		<cfset ShowCarrierNotesOnMobileApp = 1>
	<cfelse>	
		<cfset ShowCarrierNotesOnMobileApp = 0>
	</cfif>
	<cfif structKeyExists(form, "UseDirectCost")>
		<cfset UseDirectCost = 1>
	<cfelse>	
		<cfset UseDirectCost = 0>
	</cfif>
	<cfif structKeyExists(form, "RequireDeliveryDate")>
		<cfset RequireDeliveryDate = 1>
	<cfelse>	
		<cfset RequireDeliveryDate = 0>
	</cfif>
	<cfif structKeyExists(FORM, "CopyLoadDeliveryPickupDates")>
		<cfset CopyLoadDeliveryPickupDates = 1>
    <cfelse>
    	<cfset CopyLoadDeliveryPickupDates = 0>
    </cfif>

    <cfif structKeyExists(FORM, "CopyLoadCarrier")>
		<cfset CopyLoadCarrier = 1>
    <cfelse>
    	<cfset CopyLoadCarrier = 0>
    </cfif>
    <cfif structKeyExists(FORM, "ShowLoadCopyOptions")>
		<cfset ShowLoadCopyOptions = 1>
    <cfelse>
    	<cfset ShowLoadCopyOptions = 0>
    </cfif>
    <cfif structKeyExists(form, "ShowCustomerTermsOnInvoice")>
		<cfset ShowCustomerTermsOnInvoice = 1>
	<cfelse>	
		<cfset ShowCustomerTermsOnInvoice = 0>
	</cfif>
	<cfif structKeyExists(form, "QBCarrierInvoiceASRef") AND len(form.QBCarrierInvoiceASRef)>
		<cfset QBCarrierInvoiceASRef = 1>
	<cfelse>	
		<cfset QBCarrierInvoiceASRef = 0>
	</cfif>
	<cfif structKeyExists(form, "QBFactoringNameOnBill") AND len(form.QBFactoringNameOnBill)>
		<cfset QBFactoringNameOnBill = 1>
	<cfelse>	
		<cfset QBFactoringNameOnBill = 0>
	</cfif>
	<cfif structKeyExists(form, "ConsolidateInvoiceDateUpdate")>
		<cfset ConsolidateInvoiceDateUpdate = 1>
	<cfelse>	
		<cfset ConsolidateInvoiceDateUpdate = 0>
	</cfif>
	<cfif structKeyExists(form, "ConsolidateInvoiceTriggerStatus")>
		<cfset ConsolidateInvoiceTriggerStatus = form.ConsolidateInvoiceTriggerStatus>
	<cfelse>	
		<cfset ConsolidateInvoiceTriggerStatus = "">
	</cfif>
	<cfif structKeyExists(form, "ExcludeTemplateLoadNumber")>
		<cfset ExcludeTemplateLoadNumber = 1>
	<cfelse>	
		<cfset ExcludeTemplateLoadNumber = 0>
	</cfif>
	<cfif structKeyExists(form, "DefaultLoadEmails")>
		<cfset DefaultLoadEmails = form.DefaultLoadEmails>
	<cfelse>	
		<cfset DefaultLoadEmails = "">
	</cfif>
	<cfif structKeyExists(form, "AutoSendEMailUpdates")>
		<cfset AutoSendEMailUpdates = 1>
	<cfelse>	
		<cfset AutoSendEMailUpdates = 0>
	</cfif>
	<cfif structKeyExists(form, "MinMarginOverrideApproval")>
		<cfset MinMarginOverrideApproval = 1>
	<cfelse>	
		<cfset MinMarginOverrideApproval = 0>
	</cfif>
	<cfif structKeyExists(form, "QBFactoringNameOnInvoice")>
		<cfset QBFactoringNameOnInvoice = 1>
	<cfelse>	
		<cfset QBFactoringNameOnInvoice = 0>
	</cfif>
	<cfif structKeyExists(form, "useBetaVersion")>
		<cfset useBetaVersion = 1>
	<cfelse>	
		<cfset useBetaVersion = 0>
	</cfif>
	<cfif structKeyExists(form, "UseCondensedReports")>
		<cfset UseCondensedReports = 1>
	<cfelse>	
		<cfset UseCondensedReports = 0>
	</cfif>
	<cfif structKeyExists(form, "BillFromCompanies")>
		<cfset BillFromCompanies = 1>
	<cfelse>	
		<cfset BillFromCompanies = 0>
	</cfif>
	<cfif structKeyExists(form, "ApplyBillFromCompanyToCarrierReport")>
		<cfset ApplyBillFromCompanyToCarrierReport = 1>
	<cfelse>	
		<cfset ApplyBillFromCompanyToCarrierReport = 0>
	</cfif>
	<cfif structKeyExists(form, "IncludeCarrierRate")>
		<cfset IncludeCarrierRate = 1>
	<cfelse>	
		<cfset IncludeCarrierRate = 0>
	</cfif>
	<cfif structKeyExists(form, "ShowAllOfficeCustomers")>
		<cfset ShowAllOfficeCustomers = 0>
	<cfelse>	
		<cfset ShowAllOfficeCustomers = 1>
	</cfif>
	<cfif structKeyExists(form, "AutomaticCustomerRateChanges")>
		<cfset AutomaticCustomerRateChanges = 1>
	<cfelse>	
		<cfset AutomaticCustomerRateChanges = 0>
	</cfif>
	<cfif structKeyExists(form, "AutomaticCarrierRateChanges")>
		<cfset AutomaticCarrierRateChanges = 1>
	<cfelse>	
		<cfset AutomaticCarrierRateChanges = 0>
	</cfif>
	<cfif structKeyExists(form, "ShowMaxCarrRateInLoadScreen")>
		<cfset ShowMaxCarrRateInLoadScreen = 1>
	<cfelse>	
		<cfset ShowMaxCarrRateInLoadScreen = 0>
	</cfif>
	<cfif structKeyExists(form, "NonCommissionable")>
		<cfset NonCommissionable = 1>
	<cfelse>	
		<cfset NonCommissionable = 0>
	</cfif>
	
	<cfif isdefined("FORM.userDef7")>
		<cfinvoke component="#variables.objloadGateway#" method="setSystemSetupOptions" ARAndAPExportStatusID="#FORM.loadStatus#" showExpiredInsuranceCarriers="#showExpCarriers#" 
		showCarrierInvoiceNumber="#showCarrierInvoiceNumber#"  ShowCarrierInvoiceNumberInAllLoads="#ShowCarrierInvoiceNumberInAllLoads#" dispatch_notes="#dispatch_notes#" carrier_notes="#carrier_notes#" simple_notes="#simple_notes#"  requireValidMCNumber="#requireValidMCNumber#" CarrierTerms="#form.CarrierTerms#"  Triger_loadStatus="#form.Triger_loadStatus#" AllowLoadentry="#AllowLoadentry#" showReadyArriveDat="#showReadyArriveDat#"  userDef1="#userDef1#" userDef2="#userDef2#" userDef3="#userDef3#" userDef4="#userDef4#" userDef5="#userDef5#"  userDef6="#userDef6#" userDef7="#userDef7#" googleMapsPcMiler="#googleMapsPcMiler#" minimumMargin="#minimumMargin#" CarrierHead="#form.CarrierHead#" CustInvHead="#form.CustInvHead#" BOLHead="#form.BOLHead#" WorkImpHead="#form.WorkImpHead#" WorkExpHead="#form.WorkExpHead#" SalesHead="#form.SalesHead#" minimunLoadNumber="#form.minimunLoadNumber#" statusDispatchNote="#statusDispatchNote#" emailreports="#emailReports#" printReports="#printReports#" CustomerTerms="#CustomerTerms#" loadNumberAssignment="#loadNumberAssignment#" commodityWeight="#commodityWeight#"  rolloverShipDateStatus="#rolloverShipDateStatus#" showcarrieramount="#showcarrieramount#" showcustomeramount="#showcustomeramount#" rowsperpage="#rowsperpage#" lockloadstatus="#lockloadstatus#" editDispatchNotes="#editDispatchNotes#"  BackgroundColorForContent="#form.BackgroundColorForContent#"  BackgroundColor="#form.bckgrdColor#"  CopyLoadLimit ="#form.CopyLoadLimit#"  CopyLoadIncludeAgentAndDispatcher="#CopyLoadIncludeAgentAndDispatcher#"  LoadNumberAutoIncrement="#LoadNumberAutoIncrement#"  StartingActiveLoadNumber="#form.StartingActiveLoadNumber#" CheckVendorCode="#checkVendorCode#" LoadLimit="#LoadLimit#" IsLoadLogEnabled="#IsLoadLogEnabled#" LoadLogLimit="#LoadLogLimit#" ForeignCurrencyEnabled="#ForeignCurrencyEnabled#" DefaultSystemCurrency="#DefaultSystemCurrency#" AllowedSystemCurrencies="#allowedSystemCurrencies#" PCMilerAPIKey="#trim(PCMilerAPIKey)#" numberOfCarrierInEmail="#form.numberOfCarrierInEmail#" includeLoadNumber="#includeLoadNumber#" activateBulkAndLoadNotificationEmail="#activateBulkAndLoadNotificationEmail#" returnvariable="systemConfigUpdated" getFMCSAFrom="#getFMCSAFrom#" IsEDispatchSmartPhone="#IsEDispatchSmartPhone#" IsLockOrderDate="#IsLockOrderDate#" ShowMiles="#ShowMiles#" ShowDeadHeadMiles="#ShowDeadHeadMiles#" MyCarrierPackets="#MyCarrierPackets#" MyCarrierPacketsUsername="#MyCarrierPacketsUsername#" MyCarrierPacketsPassword="#MyCarrierPacketsPassword#" CarrierLNI="#CarrierLNI#" editCreditLimit="#editCreditLimit#" showScanButton="#showScanButton#" EDIloadStatus="#EDIloadStatus#" CustomerLNI="#CustomerLNI#" ComDataUnitID="#ComDataUnitID#" ComDataCustomerID="#ComDataCustomerID#" autoAddCustViaDOT="#autoAddCustViaDOT#"   includeNumberofTripsInReports="#includeNumberofTripsInReports#" forceUserToEnterTrip="#forceUserToEnterTrip#" TIN="#form.TIN#" AutomaticFactoringFee="#AutomaticFactoringFee#" FactoringFee="#FactoringFee#" Edi210EsignReq="#Edi210EsignReq#" carrierratecon=#form.carrierratecon# UpdateCustomerFromLoadScreen=#UpdateCustomerFromLoadScreen# LoadsColumns=#LoadsColumns# LoadsColumnsStatus=#LoadsColumnsStatus# IsLoadStatusDefaultForReport="#IsLoadStatusDefaultForReport#"
		allowBooking="#allowBooking#" EDispatchOptions="#EDispatchOptions#" GPSUpdateInterval="#GPSUpdateInterval#" ShowLoadStatusOnMobileApp="#ShowLoadStatusOnMobileApp#" TurnOnConsolidatedInvoices="#TurnOnConsolidatedInvoices#" MacropointId='#MacropointId#' MacropointApiLogin='#MacropointApiLogin#' MacropointApiPassword='#MacropointApiPassword#' MobileStopTrackingStatus='#form.MobileStopTrackingStatus#' Project44='#Project44#' SendEmailNoticeMacroPoint='#SendEmailNoticeMacroPoint#' EDispatchTextInstructions="#form.EDispatchTextInstructions#" EDispatchMailText="#form.EDispatchMailText#" BOLReportFormat="#form.BOLReportFormat#" EDispatchTextMessage="#form.EDispatchTextMessage#" QBDefBillAccountName="#form.QBDefBillAccountName#" QBDefInvItemName="#form.QBDefInvItemName#" QBDefInvPayTerm="#form.QBDefInvPayTerm#" QBDefBillPayTerm="#form.QBDefBillPayTerm#" TimeZone="#TimeZone#" RateConPromptOption="#form.RateConPromptOption#" UseNonFeeAccOnBOL="#UseNonFeeAccOnBOL#" CustomerCRMCallBackCircleColor="#form.CustomerCRMCallBackCircleColor#" CarrierCRMCallBackCircleColor="#form.CarrierCRMCallBackCircleColor#" DriverCRMCallBackCircleColor="#form.DriverCRMCallBackCircleColor#" ReqAddressWhenAddingCust="#ReqAddressWhenAddingCust#" DefaultCountry="#form.DefaultCountry#"   ShortBOLTerms="#form.ShortBOLTerms#" BackgroundColorAccounting="#form.BackgroundColorAccounting#"  BackgroundColorForContentAccounting="#form.BackgroundColorForContentAccounting#"  ShowCarrierNotesOnMobileApp="#ShowCarrierNotesOnMobileApp#" IncludeDhMilesInTotalMiles="#IncludeDhMilesInTotalMiles#" CalculateDHOption="#form.CalculateDHOption#"  APExportStatusID="#form.APExportStatusID#"  UseDirectCost="#UseDirectCost#" QBVersion="#form.QBVersion#" CopyLoadDeliveryPickupDates="#CopyLoadDeliveryPickupDates#" CopyLoadCarrier="#CopyLoadCarrier#" ShowLoadCopyOptions="#ShowLoadCopyOptions#" TemperatureSetting="#form.TemperatureSetting#" EDispatchHead="#form.EDispatchHead#" ShowCustomerTermsOnInvoice="#ShowCustomerTermsOnInvoice#" CarrierLoadStatusLaneSave="#form.CarrierLoadStatusLaneSave#" QBCarrierInvoiceASRef="#QBCarrierInvoiceASRef#"  QBFactoringNameOnBill="#QBFactoringNameOnBill#" ConsolidateInvoiceStatusUpdate="#ConsolidateInvoiceStatusUpdate#" ConsolidateInvoiceDateUpdate="#ConsolidateInvoiceDateUpdate#"  ConsolidateInvoiceTriggerStatus="#ConsolidateInvoiceTriggerStatus#" ExcludeTemplateLoadNumber="#ExcludeTemplateLoadNumber#" GPSDistanceInterval="#GPSDistanceInterval#" DefaultLoadEmails="#DefaultLoadEmails#" DefaultLoadEmailtext="#form.DefaultLoadEmailtext#" DefaultLaneAlertEmailtext="#form.DefaultLaneAlertEmailtext#" DefaultLoadEmailSubject="#form.DefaultLoadEmailSubject#" DefaultLaneAlertEmailSubject="#form.DefaultLaneAlertEmailSubject#" DashboardUser="#form.DashboardUser#" DashboardPassword="#form.DashboardPassword#" ShowDashboard="#form.ShowDashboard#" AutoSendEMailUpdates="#AutoSendEMailUpdates#" MinMarginOverrideApproval="#MinMarginOverrideApproval#" QBFactoringNameOnInvoice="#QBFactoringNameOnInvoice#"DefaultOnboardingEmailSubject="#form.DefaultOnboardingEmailSubject#" DefaultOnboardingEmailCC="#form.DefaultOnboardingEmailCC#" DefaultOnboardingEmailtext="#form.DefaultOnboardingEmailtext#" GeoFenceRadius="#form.GeoFenceRadius#" useBetaVersion="#useBetaVersion#" UseCondensedReports="#UseCondensedReports#" BillFromCompanies="#BillFromCompanies#" ApplyBillFromCompanyToCarrierReport="#ApplyBillFromCompanyToCarrierReport#" IncludeCarrierRate="#IncludeCarrierRate#" ShowAllOfficeCustomers="#ShowAllOfficeCustomers#" CustomerPaymentTerms="#form.CustomerPaymentTerms#" RequireDeliveryDate="#RequireDeliveryDate#" CustomerInvoiceformat=#form.CustomerInvoiceformat# AutomaticCustomerRateChanges="#AutomaticCustomerRateChanges#" AutomaticCarrierRateChanges="#AutomaticCarrierRateChanges#" ShowLoadTypeStatusOnLoadsScreen="#ShowLoadTypeStatusOnLoadsScreen#" ShowMaxCarrRateInLoadScreen="#ShowMaxCarrRateInLoadScreen#" NonCommissionable="#NonCommissionable#"/>
	<cfelse>
		<cfinvoke component="#variables.objloadGateway#" method="setSystemSetupOptions"  ARAndAPExportStatusID="#FORM.loadStatus#" showExpiredInsuranceCarriers="#showExpCarriers#" showCarrierInvoiceNumber="#showCarrierInvoiceNumber#"    ShowCarrierInvoiceNumberInAllLoads="#ShowCarrierInvoiceNumberInAllLoads#" dispatch_notes="#dispatch_notes#" carrier_notes="#carrier_notes#" simple_notes="#simple_notes#"  requireValidMCNumber="#requireValidMCNumber#" CarrierTerms="#form.CarrierTerms#"  Triger_loadStatus="#form.Triger_loadStatus#" AllowLoadentry="#AllowLoadentry#" showReadyArriveDat="#showReadyArriveDat#"  userDef1="#userDef1#" userDef2="#userDef2#" userDef3="#userDef3#" userDef4="#userDef4#" userDef5="#userDef5#"  userDef6="#userDef6#"  googleMapsPcMiler="#googleMapsPcMiler#" minimumMargin="#minimumMargin#" CarrierHead="#form.CarrierHead#" CustInvHead="#form.CustInvHead#" BOLHead="#form.BOLHead#" WorkImpHead="#form.WorkImpHead#" WorkExpHead="#form.WorkExpHead#" SalesHead="#form.SalesHead#" minimunLoadNumber="#form.minimunLoadNumber#" statusDispatchNote="#statusDispatchNote#" emailreports="#emailReports#" printReports="#printReports#" CustomerTerms="#CustomerTerms#" loadNumberAssignment="#loadNumberAssignment#" commodityWeight="#commodityWeight#" rolloverShipDateStatus="#rolloverShipDateStatus#" showcarrieramount="#showcarrieramount#" showcustomeramount="#showcustomeramount#" rowsperpage="#rowsperpage#" lockloadstatus="#lockloadstatus#" editDispatchNotes="#editDispatchNotes#" BackgroundColorForContent="#form.BackgroundColorForContent#"   BackgroundColor="#form.bckgrdColor#"  CopyLoadLimit ="#form.CopyLoadLimit#"  CopyLoadIncludeAgentAndDispatcher="#CopyLoadIncludeAgentAndDispatcher#"  LoadNumberAutoIncrement="#LoadNumberAutoIncrement#"   StartingActiveLoadNumber="#form.StartingActiveLoadNumber#"  CheckVendorCode="#checkVendorCode#" LoadLimit="#LoadLimit#" IsLoadLogEnabled="#IsLoadLogEnabled#" LoadLogLimit="#LoadLogLimit#" ForeignCurrencyEnabled="#ForeignCurrencyEnabled#" DefaultSystemCurrency="#DefaultSystemCurrency#" AllowedSystemCurrencies="#allowedSystemCurrencies#" PCMilerAPIKey="#trim(PCMilerAPIKey)#" numberOfCarrierInEmail="#form.numberOfCarrierInEmail#" includeLoadNumber="#includeLoadNumber#" activateBulkAndLoadNotificationEmail="#activateBulkAndLoadNotificationEmail#" returnvariable="systemConfigUpdated" getFMCSAFrom="#getFMCSAFrom#" IsEDispatchSmartPhone="#IsEDispatchSmartPhone#" IsLockOrderDate="#IsLockOrderDate#" ShowMiles="#ShowMiles#" ShowDeadHeadMiles="#ShowDeadHeadMiles#" MyCarrierPackets="#MyCarrierPackets#" MyCarrierPacketsUsername="#MyCarrierPacketsUsername#" MyCarrierPacketsPassword="#MyCarrierPacketsPassword#" CarrierLNI="#CarrierLNI#" editCreditLimit="#editCreditLimit#" showScanButton="#showScanButton#" EDIloadStatus="#EDIloadStatus#" CustomerLNI="#CustomerLNI#" ComDataUnitID="#ComDataUnitID#" ComDataCustomerID="#ComDataCustomerID#" autoAddCustViaDOT="#autoAddCustViaDOT#" includeNumberofTripsInReports="#includeNumberofTripsInReports#" forceUserToEnterTrip="#forceUserToEnterTrip#" TIN="#form.TIN#" AutomaticFactoringFee="#AutomaticFactoringFee#" FactoringFee="#FactoringFee#" Edi210EsignReq="#Edi210EsignReq#" carrierratecon=#form.carrierratecon#  UpdateCustomerFromLoadScreen=#UpdateCustomerFromLoadScreen# LoadsColumns=#LoadsColumns# LoadsColumnsStatus=#LoadsColumnsStatus# IsLoadStatusDefaultForReport="#IsLoadStatusDefaultForReport#"
		allowBooking="#allowBooking#" EDispatchOptions="#EDispatchOptions#" GPSUpdateInterval="#GPSUpdateInterval#" ShowLoadStatusOnMobileApp="#ShowLoadStatusOnMobileApp#" TurnOnConsolidatedInvoices="#TurnOnConsolidatedInvoices#" MacropointId='#MacropointId#' MacropointApiLogin='#MacropointApiLogin#' MacropointApiPassword='#MacropointApiPassword#' MobileStopTrackingStatus='#form.MobileStopTrackingStatus#' Project44='#Project44#' SendEmailNoticeMacroPoint='#SendEmailNoticeMacroPoint#'  EDispatchTextInstructions="#form.EDispatchTextInstructions#" EDispatchMailText="#form.EDispatchMailText#" BOLReportFormat="#form.BOLReportFormat#" EDispatchTextMessage="#form.EDispatchTextMessage#" QBDefBillAccountName="#form.QBDefBillAccountName#" QBDefInvItemName="#form.QBDefInvItemName#" QBDefInvPayTerm="#form.QBDefInvPayTerm#" QBDefBillPayTerm="#form.QBDefBillPayTerm#" TimeZone="#TimeZone#" RateConPromptOption="#form.RateConPromptOption#"  UseNonFeeAccOnBOL="#UseNonFeeAccOnBOL#" CustomerCRMCallBackCircleColor="#form.CustomerCRMCallBackCircleColor#" CarrierCRMCallBackCircleColor="#form.CarrierCRMCallBackCircleColor#" DriverCRMCallBackCircleColor="#form.DriverCRMCallBackCircleColor#" ReqAddressWhenAddingCust="#ReqAddressWhenAddingCust#" DefaultCountry="#form.DefaultCountry#"   ShortBOLTerms="#form.ShortBOLTerms#" BackgroundColorAccounting="#form.BackgroundColorAccounting#"  BackgroundColorForContentAccounting="#form.BackgroundColorForContentAccounting#"  ShowCarrierNotesOnMobileApp="#ShowCarrierNotesOnMobileApp#" IncludeDhMilesInTotalMiles="#IncludeDhMilesInTotalMiles#" CalculateDHOption="#form.CalculateDHOption#" APExportStatusID="#form.APExportStatusID#"   UseDirectCost="#UseDirectCost#" QBVersion="#form.QBVersion#" CopyLoadDeliveryPickupDates="#CopyLoadDeliveryPickupDates#" CopyLoadCarrier="#CopyLoadCarrier#"  ShowLoadCopyOptions="#ShowLoadCopyOptions#" TemperatureSetting="#form.TemperatureSetting#" EDispatchHead="#form.EDispatchHead#" ShowCustomerTermsOnInvoice="#ShowCustomerTermsOnInvoice#" CarrierLoadStatusLaneSave="#form.CarrierLoadStatusLaneSave#" QBCarrierInvoiceASRef="#QBCarrierInvoiceASRef#" ConsolidateInvoiceStatusUpdate="#ConsolidateInvoiceStatusUpdate#" ConsolidateInvoiceDateUpdate="#ConsolidateInvoiceDateUpdate#"  ConsolidateInvoiceTriggerStatus="#ConsolidateInvoiceTriggerStatus#" ExcludeTemplateLoadNumber="#ExcludeTemplateLoadNumber#" GPSDistanceInterval="#GPSDistanceInterval#" QBFactoringNameOnBill="#QBFactoringNameOnBill#" DefaultLoadEmails="#DefaultLoadEmails#" DefaultLoadEmailtext="#form.DefaultLoadEmailtext#" DefaultLaneAlertEmailtext="#form.DefaultLaneAlertEmailtext#" DefaultLoadEmailSubject="#form.DefaultLoadEmailSubject#" DefaultLaneAlertEmailSubject="#form.DefaultLaneAlertEmailSubject#"DashboardUser="#form.DashboardUser#" DashboardPassword="#form.DashboardPassword#" ShowDashboard="#form.ShowDashboard#" AutoSendEMailUpdates="#AutoSendEMailUpdates#" MinMarginOverrideApproval="#MinMarginOverrideApproval#" QBFactoringNameOnInvoice="#QBFactoringNameOnInvoice#"DefaultOnboardingEmailSubject="#form.DefaultOnboardingEmailSubject#" DefaultOnboardingEmailCC="#form.DefaultOnboardingEmailCC#" DefaultOnboardingEmailtext="#form.DefaultOnboardingEmailtext#"GeoFenceRadius="#form.GeoFenceRadius#" useBetaVersion="#useBetaVersion#" BillFromCompanies="#BillFromCompanies#" ApplyBillFromCompanyToCarrierReport="#ApplyBillFromCompanyToCarrierReport#" IncludeCarrierRate="#IncludeCarrierRate#"
		ShowAllOfficeCustomers="#ShowAllOfficeCustomers#" UseCondensedReports="#UseCondensedReports#" CustomerPaymentTerms="#form.CustomerPaymentTerms#" RequireDeliveryDate="#RequireDeliveryDate#" CustomerInvoiceformat=#form.CustomerInvoiceformat# AutomaticCustomerRateChanges="#AutomaticCustomerRateChanges#" AutomaticCarrierRateChanges="#AutomaticCarrierRateChanges#" ShowLoadTypeStatusOnLoadsScreen="#ShowLoadTypeStatusOnLoadsScreen#" ShowMaxCarrRateInLoadScreen="#ShowMaxCarrRateInLoadScreen#" NonCommissionable="#NonCommissionable#"/>
	 </cfif>

	 <cfif form.EDispatchOptionsOld NEQ 0 AND form.EDispatchOptions EQ 0>
	 	<cfinvoke component="#variables.objloadGateway#" method="sendMobileDispatchSupportNotice" status="ON">
	 <cfelseif form.EDispatchOptionsOld EQ 0 AND form.EDispatchOptions NEQ 0>
	 	<cfinvoke component="#variables.objloadGateway#" method="sendMobileDispatchSupportNotice" status="OFF">
	 </cfif>

	 <cfif structKeyExists(form, "EDispatchOptions") AND listFindNoCase("2,3", form.EDispatchOptions)>
	 	<cfinvoke component="#variables.objloadGateway#" method="validateMacropoint" MacropointId="#form.MacropointId#" MacropointApiLogin="#form.MacropointApiLogin#" MacropointApiPassword="#form.MacropointApiPassword#" returnvariable="MPValidationResp">
	 </cfif>

	<cfif structKeyExists(form, "useBetaVersion") AND form.useBetaVersionHidden EQ 0>
		<cfinvoke component="#variables.objloadGatewayNew#" method="relocationToBeta">
		<cflocation url="https://loadmanager.net/loadmanagerbeta/www/webroot/index.cfm" addtoken="no">
	</cfif>

	<cfif NOT structKeyExists(form, "useBetaVersion") AND form.useBetaVersionHidden EQ 1>
		<cfinvoke component="#variables.objloadGatewayNew#" method="relocationToBeta">
		<cflocation url="https://loadmanager.biz/loadmanagerlive/www/webroot/index.cfm" addtoken="no">
	</cfif>
	<cflocation url="index.cfm?event=systemsetup">
<cfelseif isDefined('FORM.updateViaSaferWatch')>
	<cfinvoke component="#variables.objCarrierGateway#" method="updateViaSaferWatch" returnvariable="session.saferWatchMsg"/>
</cfif>
<cfinvoke component="#variables.objloadGateway#" method="getLoadSystemSetupOptions" returnvariable="request.qSystemSetupOptions1" />
<cfif request.qSystemSetupOptions1.freightBroker EQ 2>
	<cfset variables.freightBrokerVal = "Carrier/Driver">
	<cfset variables.expiredType = "Insurance">
<cfelseif request.qSystemSetupOptions1.freightBroker EQ 1>
	<cfset variables.freightBrokerVal = "Carrier">
	<cfset variables.expiredType = "Insurance">
<cfelse>
	<cfset variables.freightBrokerVal = "Driver">
	<cfset variables.expiredType = "Physical">
</cfif> 
<cfinvoke component="#variables.objloadGateway#" method="getSystemSetupOptions" returnvariable="request.qGetSystemSetupOptions" />
<cfinvoke component="#variables.objloadGateway#" method="getCurrencies" returnvariable="request.qGetCurrencies" />

<cfinvoke component="#variables.objloadGateway#" method="getLoadStatus" returnvariable="request.qLoadStatus" /> 
<cfinvoke component="#variables.objloadGateway#" method="getCompanyInformation" returnvariable="request.qGetCompanyInformation" />

<cfinvoke component="#variables.objunitGateway#" method="getAllUnits" returnvariable="request.qUnits" isActive=1/> 
<cfinvoke component="#variables.objAgentGateway#" method="getAllAgent" returnvariable="request.qAgent" />

<cfset loadStatus = request.qGetSystemSetupOptions.ARAndAPExportStatusID>
<cfset APExportStatusID = request.qGetSystemSetupOptions.APExportStatusID>
<cfset CarrierHead = request.qGetSystemSetupOptions.CarrierHead>
<cfset CustInvHead = request.qGetSystemSetupOptions.CustInvHead>
<cfset BOLHead = request.qGetSystemSetupOptions.BOLHead>
<cfset WorkImpHead = request.qGetSystemSetupOptions.WorkImpHead>
<cfset WorkExpHead = request.qGetSystemSetupOptions.WorkExpHead>
<cfset SalesHead = request.qGetSystemSetupOptions.SalesHead> 
<cfset EDispatchHead = request.qGetSystemSetupOptions.EDispatchHead> 
<cfif len(trim(request.qGetSystemSetupOptions.DashboardUser)) AND len(trim(request.qGetSystemSetupOptions.DashboardPassword))>
	<cfset variables.DashboardUser = request.qGetSystemSetupOptions.DashboardUser> 
	<cfset variables.DashboardPassword = request.qGetSystemSetupOptions.DashboardPassword> 
<cfelse>
	<cfinvoke component="#variables.objloadGatewayNew#" method="setDashBoardLogin" DashboardUser="#variables.DashboardUser#" DashboardPassword="#variables.DashboardPassword#"/>
</cfif>
</cfsilent>
<cfoutput>
	<link rel="stylesheet" href="//code.jquery.com/ui/1.12.1/themes/base/jquery-ui.css">
 
  <style>
  ##sortable { list-style-type: none; margin: 0; padding: 0; width: 60%; color:green; }
  ##sortable li { margin: 0 3px 3px 3px; padding: 0.4em; padding-left: 1.5em; font-size: 1.4em; height: 18px; }
  ##sortable li span { position: absolute; margin-left: -1.3em; }
  
  .active-color{background-color: ##74acf5;}
  .inactive-color{background-color: ##cccfff;}

  .overlay{
	    position: fixed;
	    background-color: ##000000;
	    width: 100%;
	    height: 100%;
	    z-index: 99;
	    top: 0;
	    left: 0;
	    opacity: 0.5;
	    display: none;
	}
	##loader{
		position: fixed;
		top:40%;
		left:30%;
		z-index: 999;
		display: none;
	}
	##loadingmsg{
		top:50%;
		left:32%;
		position: fixed;
		z-index: 999;
		font-size: 14px;
		display: none;
	}
	.msg-area-success{
        border: 1px solid ##a4da46;
        padding: 5px 15px;
        font-weight: normal;
        width: 82%;
        float: left;
        margin-top: 5px;
        margin-bottom:  5px;
        background-color: ##b9e4b9;
        font-weight: bold;
        font-style: italic;
    }
    .msg-area-error{
        border: 1px solid ##da4646;
        padding: 5px 15px;
        font-weight: normal;
        width: 82%;
        float: left;
        margin-top: 5px;
        margin-bottom:  5px;
        background-color: ##e4b9c6;
        font-weight: bold;
        font-style: italic;
    }

    .ui-tooltip{
    	opacity: 1;
    	z-index: 999;
    }
	h4.bg-line{
		position: relative;
    	z-index: 1;
	}
	h4.bg-line:before{
		border-top: 1px solid ##c1c1c1;
		content:"";
		margin: 0 auto;
		position: absolute;
		top: 50%; left: 0; right: 0; bottom: 0;
		width: 100%;
		z-index: -1;
	}
	h4.bg-line span{
		background-color: #request.qGetSystemSetupOptions.BackgroundColorForContent#;
        padding: 0 5px; 
	}
  </style>
  <script src="https://code.jquery.com/jquery-1.12.4.js"></script>
  <script src="https://code.jquery.com/ui/1.12.1/jquery-ui.js"></script>
  <script>
  $( function() {
  	var UserDef7 = '#request.qGetSystemSetupOptions.UserDef7#';
    $( "##sortable" ).sortable({
	  stop: function( event, ui ) {
		_arrayObj = [];	
	  	_arrayActive = [];  	
		$('##sortable li').each(function(){
			_text = $.trim($(this).text());
			if(_text==UserDef7){
				_text='UserDef7';
			}
			_arrayObj.push(_text ); 	
			$('##sortedLoadColumns').val(_arrayObj);		
		})

		$('##sortable li').each(function(){
			if($(this).hasClass('active-color')){
				_arrayActive.push(1);
			}
			else{
				_arrayActive.push(0);
			}
			$('##statusLoadColumns').val(_arrayActive);
		})
		
	
	  }

	});
	

    $( "##sortable" ).disableSelection();

    $('##sortable li').on('click',function(){
    	_arrayActive = [];
		if($(this).hasClass('active-color')){
			$(this).removeClass('active-color');
			$(this).addClass('inactive-color');
		}
		else{
			$(this).removeClass('inactive-color');
			$(this).addClass('active-color');
		}
		$('##sortable li').each(function(){
			if($(this).hasClass('active-color')){
				_arrayActive.push(1);
			}
			else{
				_arrayActive.push(0);
			}
			$('##statusLoadColumns').val(_arrayActive);
		})
		
	});
	<cfif structKeyExists(url, "IDFocus")>
		$('###url.IDFocus#').focus();
		$([document.documentElement, document.body]).animate({
	        scrollTop: $("###url.IDFocus#").offset().top-125
	    }, 500);
	</cfif>

	$("##ShowCustomerTermsOnInvoice").click(function(){
	  	var ckd = $(this).is(':checked');
	  	if(ckd){
	  		$("##CustomerTerms").prop("readonly",false);
	  		$("##CustomerTerms").css("background-color","##fff");
	  	}
	  	else{
	  		$("##CustomerTerms").prop("readonly",true);
	  		$("##CustomerTerms").css("background-color","##e3e3e3");
	  	}
	});

	<cfif isDefined("MPValidationResp") and MPValidationResp EQ 0>
		alert('The Macropoint credentials failed. Please update and try again.');
	</cfif>

  } );

  	function generateNewDashboardPassword(){
  		$('##DashboardPassword').val(Math.floor(100000 + Math.random() * 900000));
  	}


  function getDotNumberForUpdate(){
  	
  		var path = urlComponentPath+"carriergateway.cfc?method=getDotNumberForUpdate";
        $.ajax({
        	type: "get",
            url: path,
            data:{
            	companyid:'#session.companyid#',dsn:'#application.dsn#'
            },
            success: function(data){
            	dataJson = jQuery.parseJSON(data);
            	if(dataJson.length){
                	recAjxUpdateViaCarrierLookout(dataJson,0);
            	}
            	else{
            		$('.overlay').hide()
			        $('##loader').hide();
			        $('##loadingmsg').hide();
            	}
            },
            beforeSend: function() {
		        $('.overlay').show()
		        $('##loader').show();
		        $('##loadingmsg').show();
		    },
      	});
	}

	function recAjxUpdateViaCarrierLookout(dataJson,index){
		var nextIndx = index+1;
		var path = urlComponentPath+"carriergateway.cfc?method=updateViaCarrierLookout";
		$.ajax({
        	type: "get",
            url: path,
            data:{
            	DotNumber:dataJson[index].DOTNUMBER,CarrierID:dataJson[index].CARRIERID,dsn:'#application.dsn#',CompanyID:'#session.CompanyID#',AdminUserName:'#session.AdminUserName#',opt:2
            },
            success: function(data){
            	if(nextIndx<dataJson.length){
	        		recAjxUpdateViaCarrierLookout(dataJson,nextIndx)
	        	}
	        	else{
	        		$('.overlay').hide()
			        $('##loader').hide();
			        $('##loadingmsg').hide();
	        	}
            },
      	});

	}
  </script>
<script type="text/javascript">

	function popitup(url) {
		newwindow=window.open(url,'Map','height=600,width=600');
		if (window.focus) {newwindow.focus()}
		return false;
	}
	
	function newBackgroundColor(color) {            
        document.getElementById("bckgrdColor").value = color;			
    }

    function newBackgroundColorAcc(color) {            
        document.getElementById("BackgroundColorAccounting").value = color;			
    }

	function newCustCRMCallBackCircleColor(color) {            
        document.getElementById("CustomerCRMCallBackCircleColor").value = color;			
    }

    function newCarrCRMCallBackCircleColor(color) {            
        document.getElementById("CarrierCRMCallBackCircleColor").value = color;			
    }

    function newDrivCRMCallBackCircleColor(color) {            
        document.getElementById("DriverCRMCallBackCircleColor").value = color;			
    }

		
	function newBackgroundColorContent(color) {           
        document.getElementById("BackgroundColorForContent").value = color;			
    }
		
	function newBackgroundColorContentAcc(color) {           
        document.getElementById("BackgroundColorForContentAccounting").value = color;			
    }
	function setDropbox(val){
		if(val == 1){
			$("##divDropBox").show();
		}else{
			$("##divDropBox").hide();
		}
	}

	function checkFiletype(){
        var fileExtension = ['jpg', 'png'];
        if ($.inArray($("##companyLogo").val().split('.').pop().toLowerCase(), fileExtension) == -1) {
            alert("Please select  "+fileExtension.join(', ')+" images for Company Logo");
            $("##companyLogo").val('');
        }
    }
	
    $( document ).ready(function() {
		
		$("##IsLoadLogEnabled").change(function() {
			if($("##IsLoadLogEnabled").is(':checked')){
				$("##LoadLogLimit").prop( "disabled", false );
			}else{
				$("##LoadLogLimit").prop( "disabled", true );
			}
		});
		
		$("##IsLoadLogEnabled").change();
		
		$("##foreignCurrencyEnabled").change(function() {
			if($("##foreignCurrencyEnabled").is(':checked')){
				$(".foreignCurrencyActivatedDiv").show();  // checked
			}else{
				$(".foreignCurrencyActivatedDiv").hide();  // unchecked
			}
		});
		
		$("##foreignCurrencyEnabled").change();
		
		$("##AutomaticFactoringFee").change(function() {
			if($("##AutomaticFactoringFee").is(':checked')){
				$(".automaticFactoringFeeDiv").show();  // checked
			}else{
				$(".automaticFactoringFeeDiv").hide();  // unchecked
			}
		});
		
		$("##AutomaticFactoringFee").change();
		
		$("[name=googleMapsPcMiler]").change(function() {
			if($("[name=googleMapsPcMiler]:checked").val() == 2){
				$(".keyContainer .PCMiler").show();  // checked
			}else{
				$(".keyContainer .PCMiler").hide();  // unchecked
			}
		});
		
		$("[name=googleMapsPcMiler]").change();

		$("[name=CarrierLNI]").change(function() {

			$("[name=updateViaSaferWatch]").hide();
			$("[name=updateViaCarrierLookout]").hide();

			if($("[name=CarrierLNI]:checked").val()==3){
				$("[name=updateViaSaferWatch]").show();
			}

			if($("[name=CarrierLNI]:checked").val()==2){
				$("[name=updateViaCarrierLookout]").show();
			}
		});
	});
	function maxLen(value,max) {
     if(parseInt(value) > max) 
        return max; 
    else return value;
    }

	function showGPSInterval(val){
		if(val == 1){
			$("##divGPSInterval").show();
		}else{
			$("##divGPSInterval").hide();
		}
	}		

	function showMpApi(val){
		if(val == 1){
			$("##divMpApi").show();
		}else{
			$("##divMpApi").hide();
		}
	}

	function showTextIns(val){
		if(val == 1){
			$("##divTextIns").show();
		}else{
			$("##divTextIns").hide();
		}
	}

	function showAutoEmailUpdates(val){
		if(val == 1){
			$("##AutoSendEMailUpdates").show();
			$("##spn_AutoSendEMailUpdates").show();
		}else{
			$("##AutoSendEMailUpdates").hide();
			$("##spn_AutoSendEMailUpdates").hide();
		}
	}

	function validateGPSInterval(){
		var val = $('[name="EDispatchOptions"]:checked').val();
		var interval = $('##GPSUpdateInterval').val();
		if(  (val == 0 || val == 1 || val == 2) &&  (!$.isNumeric(interval))){
			alert('Invalid GPS Update Interval.');
			$('##GPSUpdateInterval').val(5)
		}
	}	

	function validateFloatField(fld){
		var val = $(fld).val();
		if(isNaN(val) || !val.length){
			$(fld).val(0);
		}
	}

	function resetDefaultLoadEmailtext(){
		$('##DefaultLoadEmailtext').val('Hi,\nNew Update for Load## {LoadNumber}:\n{Map}\n\nStatus: {LoadStatus}\nPO##: {PONumber}\n\n{StopDetails}\n\n{EmailSignature}');
	}
	function resetOnboardingEmailtext(){
		$('##DefaultOnboardingEmailSubject').val('Welcome aboard!');
		$('##DefaultOnboardingEmailtext').val("{CompanyName} welcomes you to our onboarding process. Please {ClickThisLink} to begin. You will be able to update your information with us, upload and sign any required documents. If you don't finish everything you can come back later and finish. If you have any questions please give us a call or email us.\nRegards,\n{CompanyName}");
	}
	function resetLaneAlertEmailtext(){
		$('##DefaultLaneAlertEmailSubject').val('AVAILABLE LOADS');
		$('##DefaultLaneAlertEmailtext').val('Hi,\nWe are looking for any truck(s) that you may have available for the following truck type and lane(s)\nTruck Type(s): {Equipment}\nLanes:\nPickup: {Pickup City} {Pickup State}\nDelivery: {Delivery City} {Delivery State}\n\nPlease reply with your availability or give us a call.\n\n{EmailSignature}');
	}
</script>
<!--- Encrypt String --->
<cfset Secret = application.dsn>
<cfset TheKey = 'NAMASKARAM'>
<cfset Encrypted = Encrypt(Secret, TheKey)>
<cfset dsn = URLEncodedFormat(ToBase64(Encrypted))>
<cfif structKeyExists(session, "saferWatchMsg")>
    <div id="message" class="msg-area-#session.saferWatchMsg.res#">#session.saferWatchMsg.msg#</div>
    <cfset structDelete(session, "saferWatchMsg")>
</cfif>
<div style="clear:left"></div>
<div class="white-con-area" style="height: 40px;background-color: ##82bbef;">
		<div style="float: left; min-height: 40px; width: 43%;" id="divUploadedFiles">
			&nbsp;<a style="display:block;font-size: 13px;padding-left: 10px;color:white;" href="##" onclick="popitup('../fileupload/multipleFileupload/MultipleUpload.cfm?id=systemsetup&attachTo=10&user=#session.adminusername#&dsn=#dsn#&attachtype=systemSetup&freightBroker=#variables.freightBrokerVal#&companyid=#session.companyid#')">
			<img style="vertical-align:bottom;" src="images/attachment.png">
			File Cabinet</a>
		</div>
		<div style="float: left; width: 57%; min-height: 40px;"><h1 style="color:white;font-weight:bold;">System Setup</h1></div>
	</div>
<div style="clear:left"></div>

<div class="white-con-area">
	<div class="white-top"></div>
	<div class="white-mid">
	<cfform name="frmLongShortMiles" enctype="multipart/form-data" method="post">
	<div style="margin-left:692px;">
		<input  type="submit" name="submitSystemConfig" onclick="return validateFields();" onfocus="" class="bttn" value="Save" style="width:80px;" />
	</div>
	<div id="message" class="msg-area" style="width:153px;margin-left:660px;margin-top:10px; display:<cfif isDefined('systemConfigUpdated')>block;<cfelse>none;</cfif>">
		<cfif bitDuplicate GT 0 >
			The New Starting Load## already exists in the system.
		<cfelse>
			<cfif isDefined('systemConfigUpdated') AND systemConfigUpdated GT 0>
				Information saved successfully. #message#			
			<cfelseif isDefined('systemConfigUpdated')>
				unknown <b>Error</b> occured while saving
			</cfif>
		</cfif>
	</div>
	
	<div class="form-con">
	<fieldset>
		      
			<label style="width:160px;">Automatic Factoring Fee?</label>
			<input type="checkbox" name="AutomaticFactoringFee" id="AutomaticFactoringFee" style="width:12px;margin-left: -4px;" <cfif request.qGetSystemSetupOptions.AutomaticFactoringFee EQ 1>checked</cfif>>		
		<div class="automaticFactoringFeeDiv" style="display: none;">
        <cfinput type="text" name="FactoringFee" id="FactoringFee" value="#NumberFormat(request.qGetSystemSetupOptions.FactoringFee,'0.00')#" tabindex="2" style="width:28px;">%
		</div>
        <div class="clear">&nbsp;</div>
		<hr>
		
		<div style="float: left;width: 45%;border-right: solid 1px;margin-top: 2px;margin-bottom: 2px;">
			<label style="width: 150px;text-align: left;">Carrier Rate Con Format:</label>
			<div class="clear">&nbsp;</div>
			<input type="radio" name="carrierratecon"  value="1" style="width:12px;margin-bottom: 0;margin-left: 10px;" <cfif request.qGetSystemSetupOptions.CarrierRateConfirmation EQ true>checked</cfif> ><span style="float: left;">Sequential</span>
			<input type="radio" name="carrierratecon" value="0" style="width:12px;margin-bottom: 0;margin-left: 10px;" <cfif request.qGetSystemSetupOptions.CarrierRateConfirmation EQ  false >checked</cfif> ><span style="float: left;">Classic </span>
		</div>
		<div style="float: left;width: 45%;margin-left:10px;margin-top: 2px;margin-bottom: 2px;">
			<label style="width: 150px;text-align: left;">Customer Invoice Format:</label>
			<div class="clear">&nbsp;</div>
			<input type="radio" name="CustomerInvoiceformat"  value="0" style="width:12px;margin-bottom: 0;margin-left: 10px;" <cfif request.qGetSystemSetupOptions.CustomerInvoiceformat EQ 0>checked</cfif> ><span style="float: left;">Sequential</span>
			<input type="radio" name="CustomerInvoiceformat" value="1" style="width:12px;margin-bottom: 0;margin-left: 10px;" <cfif request.qGetSystemSetupOptions.CustomerInvoiceformat EQ  1>checked</cfif> ><span style="float: left;">Hide Stops</span>
		</div>
		<div class="clear">&nbsp;</div>
		<hr>

		<div>
			<div style="float:left;width:50%;">
				<label>Require Valid MC##</label>
		<input type="checkbox" name="chkValidMCNumber" id="chkValidMCNumber" <cfif request.qGetSystemSetupOptions.requireValidMCNumber EQ true>checked="checked"</cfif>  style="width:12px;" />
				<div class="clear"></div>
			</div>
			<div style="float:left;width:50%;">
				<label>Commodity Weight</label>
				<input type="checkbox" name="commodityWeight" id="commodityWeight" <cfif request.qGetSystemSetupOptions.commodityWeight EQ true>checked="checked"</cfif>  style="width:12px;" />
				<div class="clear"></div>
			</div>
		</div>
		<div class="clear">&nbsp;</div>
		<hr>
		<label>Status Trigger for Loadboards </label> 
		<select name="Triger_loadStatus" id="Triger_loadStatus" >
			 <option value="">Select Status</option> 
			<cfloop query="request.qLoadStatus">
				<option value="#request.qLoadStatus.value#" <cfif request.qGetSystemSetupOptions.Triger_loadStatus eq request.qLoadStatus.value> selected="selected" </cfif>>#request.qLoadStatus.statusdescription#</option>
			</cfloop>
		</select>
		<div class="clear">&nbsp;</div>
		<hr>
		<label>Allow Load ## Entry?  </label> 
        <input type="checkbox" name="AllowLoadentry" id="AllowLoadentry" <cfif request.qGetSystemSetupOptions.AllowLoadentry EQ true>checked="checked"</cfif>  style="width:12px;" >
		
		<div class="clear"></div> 
			
		<label>Show Ready & Arrive Dates on Load Entry</label>
		<input type="checkbox" name="showReadyArriveDat" id="showReadyArriveDat" <cfif request.qGetSystemSetupOptions.showReadyArriveDate EQ true>checked="checked"</cfif>  style="width:12px;" >
		<div class="clear">&nbsp;</div>
		<hr>	
		
		<label style="width:150px;">Maps and Miles calculation </label> 
		<input type="radio" name="googleMapsPcMiler" id="googleMapsPcMiler" value="0" style="width:12px;" <cfif request.qGetSystemSetupOptions.googleMapsPcMiler EQ false>checked</cfif> ><span>Google Maps</span><br/>
		<input type="radio" name="googleMapsPcMiler" id="googleMapsPcMiler" value="1" style="width:12px;position:relative;right:21px;"<cfif request.qGetSystemSetupOptions.googleMapsPcMiler EQ 1>checked</cfif> ><span style="position:relative;right:21px;">Pro Miles</span><br/>
		<input type="radio" name="googleMapsPcMiler" id="googleMapsPcMiler" value="2" style="width:12px;position:relative;right:42px;"<cfif request.qGetSystemSetupOptions.googleMapsPcMiler EQ 2>checked</cfif> ><span style="position:relative;right:42px;">PC Miler</span>
		<div class="clear">&nbsp;</div>
		<hr>	
		
		<div class="keyContainer">
			<div class="PCMiler" style="">
				<label>PC Miler API Key</label> 
				<input type="text" name="pcMilerAPIKey" id="pcMilerAPIKey"  value="#request.qGetSystemSetupOptions.pcMilerAPIKey#" />
			</div>
		</div>
		
		<div class="clear" style="border-top: 1px solid ##E6E6E6;" >&nbsp;</div>	
		
		
		<table cellpadding="0" cellspacing="0" width="100%">
			<thead>
				<tr>
					<th>&nbsp;</th>
					<th align="center" style="padding-right: 5px;border-right: 1px solid ##808080;">TMS</th>
					<th align="center" style="padding-right: 5px;">Accounting</th>
				</tr>
			</thead>
			<tbody>
				<tr>
					<td><label style="width:150px;">Select a back-ground color</label></td>
					<td style="border-right: 1px solid ##808080;">
						<input name="bckgrdColor" id="bckgrdColor" type="text" value="#request.qGetSystemSetupOptions.BackgroundColor#"  style="width:50px;margin-top:10px;" maxlength="50" />
						<input name="colorpicker" id="color1" type="color" value="#request.qGetSystemSetupOptions.BackgroundColor#"  onchange="newBackgroundColor(colorpicker.value);"  style="width:20px;margin-top:10px;" />	
					</td>
					<td style="padding-left: 5px;">
						<input name="BackgroundColorAccounting" id="BackgroundColorAccounting" type="text" value="#request.qGetSystemSetupOptions.BackgroundColorAccounting#"  style="width:50px;margin-top:10px;" maxlength="50" />
						<input name="colorpickerAcc" id="color1Acc" type="color" value="#request.qGetSystemSetupOptions.BackgroundColorAccounting#"  onchange="newBackgroundColorAcc(colorpickerAcc.value);"  style="width:20px;margin-top:10px;" />	
					</td>
				</tr>
				<tr><td colspan="3"><hr></td></tr>
				<tr>
					<td><label style="width:150px;">Select a back-ground color for content</label></td>
					<td  style="border-right: 1px solid ##808080;">
						<input name="BackgroundColorForContent" id="BackgroundColorForContent" type="text" value="#request.qGetSystemSetupOptions.BackgroundColorForContent#"  style="width:50px;margin-top:10px;" maxlength="50"/>
						<input name="colorpicker2" id="color2" type="color" value="#request.qGetSystemSetupOptions.BackgroundColorForContent#"  onchange="newBackgroundColorContent(colorpicker2.value);"  style="width:20px;margin-top:10px;"/>	
					</td>
					<td style="padding-left: 5px;">
						<input name="BackgroundColorForContentAccounting" id="BackgroundColorForContentAccounting" type="text" value="#request.qGetSystemSetupOptions.BackgroundColorForContentAccounting#"  style="width:50px;margin-top:10px;" maxlength="50"/>
						<input name="colorpicker2Acc" id="color2Acc" type="color" value="#request.qGetSystemSetupOptions.BackgroundColorForContentAccounting#"  onchange="newBackgroundColorContentAcc(colorpicker2Acc.value);"  style="width:20px;margin-top:10px;"/>
					</td>
				</tr>
			</tbody>
		</table>
		<hr>	
		
		<label style="margin-top:12px;">Starting Load##</label> 
		<input type="text" name="minimunLoadNumber" id="minimunLoadNumber" value="#request.qGetSystemSetupOptions.MinimumLoadStartNumber#" style="margin-top:10px;width: 125px;"/>
		<label style="margin-top:12px;width: 120px;">Exclude . TEMPLATE</label>
		<input type="checkbox" name="ExcludeTemplateLoadNumber" id="ExcludeTemplateLoadNumber" <cfif request.qGetSystemSetupOptions.ExcludeTemplateLoadNumber EQ true>checked="checked"</cfif>  style="margin-top:12px;width: 12px;" />
		<div class="clear">&nbsp;</div>
		<hr>	

		<label style="margin-top:12px;">Rows Per Page##</label> 
		<input type="text" name="rowsperpage" id="rowsperpage" value="#request.qGetSystemSetupOptions.rowsperpage#"style="margin-top:10px;" oninput ="this.value = maxLen(this.value,150)"/>
		<div class="clear">&nbsp;</div>
		<hr>		

		<cfif not request.qGetSystemSetupOptions.freightBroker>
			<label style="margin-top:12px;">Searchable UserDef7</label> 
			<input type="text" name="userDef7" id="userDef7" value="#request.qGetSystemSetupOptions.userDef7#" style="margin-top:16px;"/>
			<div class="clear">&nbsp;</div>
			<hr>	
		</cfif>	
		<label style="margin-top:12px;">Payment Terms</label> 
		<input type="text" name="CustomerPaymentTerms" id="CustomerPaymentTerms" value="#request.qGetSystemSetupOptions.CustomerPaymentTerms#" maxlength="100" style="margin-top:10px;width: 240px;"/>
		<div class="clear">&nbsp;</div>

		<label style="margin-top:12px;">Customer Terms</label> 
		<label style="width: 220px;margin-top: 12px;">Show Customer Terms on Invoice</label>
		<input type="checkbox" name="ShowCustomerTermsOnInvoice" id="ShowCustomerTermsOnInvoice" <cfif request.qGetSystemSetupOptions.ShowCustomerTermsOnInvoice EQ true>checked="checked"</cfif>  style="width:12px;margin-top: 12px;" >


		<cfif request.qGetSystemSetupOptions.ShowCustomerTermsOnInvoice EQ true>
			<cftextarea name="CustomerTerms" id="CustomerTerms" style="height:200px;width:400px" maxlength="8000">#request.qGetSystemSetupOptions.CustomerTerms#</cftextarea>
		<cfelse>
			<cftextarea name="CustomerTerms" id="CustomerTerms" style="height:200px;width:400px;background-color: ##e3e3e3;" maxlength="8000" readonly>#request.qGetSystemSetupOptions.CustomerTerms#</cftextarea>
		</cfif>
		<div class="clear">&nbsp;</div>
		<hr>		
		<div class="clear">&nbsp;</div>
		<label style="margin-top:12px;width: 110px;">Straight BOL Terms</label> 
		<cftextarea name="ShortBOLTerms" style="height:200px;width:400px" maxlength="8000">#request.qGetSystemSetupOptions.ShortBOLTerms#</cftextarea>
		<div class="clear">&nbsp;</div>
		<cfif request.qGetSystemSetupOptions.MinimumLoadInvoiceNumber neq 0>
			<label style="margin-top:12px;"> Invoice Number Assignment</label> 
			<select name="LoadNumberAssignment" id="LoadNumberAssignment" style="margin-top:16px;">
				 <option value="0">Select Status</option> 
				 <cfset variables.loadValue=1>
				<cfloop query="request.qLoadStatus">
					<option value="#variables.loadValue#" <cfif request.qGetSystemSetupOptions.loadNumberAssignment eq variables.loadValue> selected="selected" </cfif>>#request.qLoadStatus.Text#</option>
					<cfset variables.loadValue++>
				</cfloop>
			</select>
		</cfif>	
		<div style="display:none;"><label>Carrier / Driver Load Limit Per Day</label> <!---We dont need this as per https://loadmanager.freshdesk.com/support/tickets/653--->
        <cfinput name="LoadLimit" type="text" value="#trim(request.qGetSystemSetupOptions.CarrierLoadLimit)#" tabindex="18"/>
		<div class="clear"></div>
		<label>&nbsp;</label>
		0 = No Limit</div>
		<div class="clear"></div>
		<label>Enable Load Log</label>
		<input type="checkbox" name="IsLoadLogEnabled" id="IsLoadLogEnabled" style="width:12px;" <cfif request.qGetSystemSetupOptions.IsLoadLogEnabled>checked="checked"</cfif> >
		<div class="clear"></div>

		<label>Keep Logs For</label>
		<input name="LoadLogLimit" id="LoadLogLimit" value="#trim(request.qGetSystemSetupOptions.LoadLogLimit)#" tabindex="" type="text"> days
		<div class="clear"></div>
		
		
		<div class="clear">&nbsp;</div>
		<hr>	
		
		<div class="automatic_notes_heading">Foreign currency</div>
		<label>Activate Foreign currency</label>
		<input type="checkbox" name="foreignCurrencyEnabled" id="foreignCurrencyEnabled" <cfif request.qGetSystemSetupOptions.ForeignCurrencyEnabled EQ true>checked="checked"</cfif> style="width:12px;" />
		<div class="clear"></div>
		
		<div class="foreignCurrencyActivatedDiv" style="display:none;">
			<label>Default System Currency</label>		
			<select name="defaultSystemCurrency" id="defaultSystemCurrency" ><!--- need to make this dynamic --->
					<option value="1" <cfif request.qGetSystemSetupOptions.DefaultSystemCurrency eq 1> selected="selected" </cfif>>USD(United States Dollar)</option>
					<option value="2" <cfif request.qGetSystemSetupOptions.DefaultSystemCurrency eq 2> selected="selected" </cfif>>CAD(Canadian Dollar)</option>
			</select>
			<div class="clear"></div>
			
			<label>Select Allowed Currencies</label>		
			<select name="allowedSystemCurrencies" id="allowedSystemCurrencies" multiple style="height:auto;margin-right:10px;">
				<cfloop query = "request.qGetCurrencies"> 
					<option value="#CurrencyID#" <cfif IsActive eq 1> selected="selected" </cfif>>#CurrencyNameISO#(#CurrencyName#)</option>
				</cfloop>		
			</select> Use CTL + Mouse for selecting multiple currencies
			<div class="clear"></div>
		</div>

		<label>Number of Carriers in Email List</label>
		<input name="numberOfCarrierInEmail" id="numberOfCarrierInEmail" value="#trim(request.qGetSystemSetupOptions.numberOfCarrierInEmail)#" tabindex="" type="text" maxlength="9">
		<div class="clear"></div>
		
		<label style="width:132px;margin-top:12px;">Activate Bulk Email and Load Available Notification to Carriers/Drivers</label>
		<input type="checkbox" name="activateBulkAndLoadNotificationEmail" id="activateBulkAndLoadNotificationEmail" <cfif request.qGetSystemSetupOptions.ActivateBulkAndLoadNotificationEmail EQ true>checked="checked"</cfif> style="width:12px;margin-top:12px;" />
		<div class="clear"></div>
		<div class="automatic_notes_heading">My Carrier Packets</div>
		<label>Activate My Carrier Packets</label>
		<input type="checkbox" name="MyCarrierPackets" id="MyCarrierPackets" <cfif request.qGetSystemSetupOptions.MyCarrierPackets EQ true>checked="checked"</cfif> style="width:12px;" />
		<div class="clear"></div>
		<label>MCP Username</label>
		<input name="dummyUN" id="dummyUN" type="text" style="width:0px;margin-left:-15px;opacity:0">
		<input name="MyCarrierPacketsUsername" id="MyCarrierPacketsUsername" value="#trim(request.qGetSystemSetupOptions.MyCarrierPacketsUsername)#" tabindex="" type="text" maxlength="100">
		<div class="clear"></div>
		<label>MCP Password</label>
		<input name="dummyPW" id="dummyPW" type="password" style="width:0px;margin-left:-15px;opacity:0">
		<input name="MyCarrierPacketsPassword" id="MyCarrierPacketsPassword" value="#trim(request.qGetSystemSetupOptions.MyCarrierPacketsPassword)#" tabindex="" type="password" maxlength="100">
		<div class="clear"></div>

		<div class="automatic_notes_heading">Accounting Export</div>
		<label>A/R Export Status</label>
		<select name="loadStatus" id="loadStatus" onchange="document.getElementById('message').style.display='none';" style="width:100px;">
			<cfloop query="request.qLoadStatus">
				<option value="#request.qLoadStatus.value#" <cfif loadStatus is request.qLoadStatus.value> selected="selected" </cfif>>#request.qLoadStatus.statusdescription#</option>
			</cfloop>
		</select>
		<label style="text-align: left;margin-left: 15px;width: 122px;">Default Report Range?</label>
		<input type="checkbox" class="input_width"  name="IsLoadStatusDefaultForReport" id="IsLoadStatusDefaultForReport" <cfif request.qGetSystemSetupOptions.IsLoadStatusDefaultForReport EQ true>checked="checked"</cfif>>
        <div class="clear"></div>
		
		<label>A/P Export Status</label>
		<select name="APExportStatusID" id="APExportStatusID" onchange="document.getElementById('message').style.display='none';" style="width:100px;">
			<cfloop query="request.qLoadStatus">
				<option value="#request.qLoadStatus.value#" <cfif APExportStatusID is request.qLoadStatus.value> selected="selected" </cfif>>#request.qLoadStatus.statusdescription#</option>
			</cfloop>
		</select>

		<div class="clear"></div>
		<div class="automatic_notes_heading">QuickBooks Integration</div>

        <label>QuickBooks Version</label>		
		<select name="QBVersion" id="QBVersion" >
			<option value="0" <cfif request.qGetSystemSetupOptions.QBVersion eq 0> selected="selected" </cfif>>QuickBooks Online</option>
			<option value="1" <cfif request.qGetSystemSetupOptions.QBVersion eq 1> selected="selected" </cfif>>QuickBooks Desktop</option>
		</select>
		<div class="clear"></div>
		<label>G/L Account for Bills</label>
		<input name="QBDefBillAccountName" id="QBDefBillAccountName" value="#trim(request.qGetSystemSetupOptions.QBDefBillAccountName)#" tabindex="" type="text" maxlength="100">
		<div class="clear"></div>
		<label>G/L Account for Invoices</label>
		<input name="QBDefInvItemName" id="QBDefInvItemName" value="#trim(request.qGetSystemSetupOptions.QBDefInvItemName)#" tabindex="" type="text" maxlength="100">
		<div class="clear"></div>
		<label>Invoice Pay Terms</label>
		<input name="QBDefInvPayTerm" id="QBDefInvPayTerm" value="#trim(request.qGetSystemSetupOptions.QBDefInvPayTerm)#" tabindex="" type="text" maxlength="100">
		<div class="clear"></div>
		<label>Bills Pay Terms</label>
		<input name="QBDefBillPayTerm" id="QBDefBillPayTerm" value="#trim(request.qGetSystemSetupOptions.QBDefBillPayTerm)#" tabindex="" type="text" maxlength="100">
		<div class="clear"></div>

		<label>Export Bills:</label>
		<input type="checkbox" name="QBCarrierInvoiceASRef" id="QBCarrierInvoiceASRef" <cfif request.qGetSystemSetupOptions.QBCarrierInvoiceASRef EQ true>checked="checked"</cfif> style="width:12px;">
		<span>Use carrier invoice number as ref ##?</span>
		<div class="clear"></div>
		<input type="checkbox" name="QBFactoringNameOnBill" id="QBFactoringNameOnBill" <cfif request.qGetSystemSetupOptions.QBFactoringNameOnBill EQ true>checked="checked"</cfif> style="width:12px;margin-left: 112px;">
		<span>Use Factoring Name and Address on Bill</span>
		<div class="clear"></div>

		<label>Export Invoices:</label>
		<input type="checkbox" name="QBFactoringNameOnInvoice" id="QBFactoringNameOnInvoice" <cfif request.qGetSystemSetupOptions.QBFactoringNameOnInvoice EQ true>checked="checked"</cfif> style="width:12px;">
		<span>Use Factoring Name and Address on Invoices</span>
		<div class="clear"></div>

		<div class="automatic_notes_heading">Call Back Reminder Circle Color</div>
		
		<label style="margin-top:12px;">Customer</label> 
		<input name="CustomerCRMCallBackCircleColor" id="CustomerCRMCallBackCircleColor" type="text" value="#request.qGetSystemSetupOptions.CustomerCRMCallBackCircleColor#"  style="width:154px;margin-top:10px;" maxlength="50" />
		<input name="colorpicker3" id="color3" type="color" value="#request.qGetSystemSetupOptions.CustomerCRMCallBackCircleColor#"  onchange="newCustCRMCallBackCircleColor(colorpicker3.value);"  style="width:20px;margin-top:10px;" />
		<div class="clear"></div>

		<div <cfif NOT listFindNoCase("1,2", request.qGetSystemSetupOptions.FreightBroker)>style="display:none;"</cfif>>
			<label style="margin-top:12px;">Carrier</label> 
			<input name="CarrierCRMCallBackCircleColor" id="CarrierCRMCallBackCircleColor" type="text" value="#request.qGetSystemSetupOptions.CarrierCRMCallBackCircleColor#"  style="width:154px;margin-top:10px;" maxlength="50" />
			<input name="colorpicker4" id="color4" type="color" value="#request.qGetSystemSetupOptions.CarrierCRMCallBackCircleColor#"  onchange="newCarrCRMCallBackCircleColor(colorpicker4.value);"  style="width:20px;margin-top:10px;" />
			<div class="clear"></div>
		</div>

		<div <cfif NOT listFindNoCase("0,2", request.qGetSystemSetupOptions.FreightBroker)>style="display:none;"</cfif>>
			<label style="margin-top:12px;">Driver</label> 
			<input name="DriverCRMCallBackCircleColor" id="DriverCRMCallBackCircleColor" type="text" value="#request.qGetSystemSetupOptions.DriverCRMCallBackCircleColor#"  style="width:154px;margin-top:10px;" maxlength="50" />
			<input name="colorpicker5" id="color5" type="color" value="#request.qGetSystemSetupOptions.DriverCRMCallBackCircleColor#"  onchange="newDrivCRMCallBackCircleColor(colorpicker5.value);"  style="width:20px;margin-top:10px;" />
			<div class="clear"></div>
		</div>

		<div class="automatic_notes_heading">ComData</div>
		<label>CustomerID</label>
		<input name="ComDataCustomerID" id="ComDataCustomerID" value="#trim(request.qGetSystemSetupOptions.ComDataCustomerID)#" tabindex="" type="text" maxlength="100">
		<div class="clear"></div>
		<label>Commodity Type</label>		
		<select name="ComDataUnitID" id="ComDataUnitID" >
			<cfloop query="request.qunits">
				<option value="#request.qunits.unitID#" <cfif request.qGetSystemSetupOptions.ComDataUnitID eq request.qunits.unitID> selected="selected" </cfif>>#request.qunits.unitName#(#request.qunits.unitCode#)</option>
			</cfloop>
		</select>

		<div class="clear"></div>
		<div class="automatic_notes_heading">1099</div>
		<label>1099 TIN##</label>
		<input name="TIN" id="TIN" value="#trim(request.qGetSystemSetupOptions.TIN)#" tabindex="" type="text" maxlength="100">
		<div class="clear"></div>

		<div class="automatic_notes_heading">Consolidated Invoice</div>
		<div style="width:414px;float: left;">
			<label style="width:121px;">Turn On Consolidated Invoices</label>
			<input type="checkbox" name="TurnOnConsolidatedInvoices" id="TurnOnConsolidatedInvoices" style="width:12px;margin-left: -4px;" <cfif request.qGetSystemSetupOptions.TurnOnConsolidatedInvoices EQ 1>checked</cfif>>
		</div>
		<div class="clear" style="margin-bottom:5px;"></div>
		<label>Status Update</label> 
		<select name="ConsolidateInvoiceStatusUpdate" id="ConsolidateInvoiceStatusUpdate" >
			 <option value="">Select Status</option> 
			<cfloop query="request.qLoadStatus">
				<option value="#request.qLoadStatus.value#" <cfif request.qGetSystemSetupOptions.ConsolidateInvoiceStatusUpdate eq request.qLoadStatus.value> selected="selected" </cfif>>#request.qLoadStatus.statusdescription#</option>
			</cfloop>
		</select>
		<div class="clear"></div>

		<label>Invoice Date Update</label>
		<input type="checkbox" name="ConsolidateInvoiceDateUpdate" id="ConsolidateInvoiceDateUpdate" <cfif request.qGetSystemSetupOptions.ConsolidateInvoiceDateUpdate EQ true>checked="checked"</cfif> style="width:12px;" />
		<div class="clear"></div>

		<label>Trigger Status<br><br><br><span style="font-weight: normal;">"Use CTL + Mouse"</span></label>
		<select style="height: 160px;" name="ConsolidateInvoiceTriggerStatus" id="ConsolidateInvoiceTriggerStatus" multiple="multiple" >
			<cfloop query="request.qLoadStatus">
				<option <cfif listFindNoCase(request.qGetSystemSetupOptions.ConsolidateInvoiceTriggerStatus, request.qLoadStatus.value)> selected </cfif> value="#request.qLoadStatus.value#">#request.qLoadStatus.statusdescription#</option>
			</cfloop>
		</select>
		<div class="clear"></div>
		<div class="automatic_notes_heading">EDI210</div>
		<label>Electronic Signature Required</label>
		<input type="checkbox" name="Edi210EsignReq" id="Edi210EsignReq" <cfif request.qGetSystemSetupOptions.Edi210EsignReq EQ true>checked="checked"</cfif> style="width:12px;" />
		<div class="clear"></div>
		<br>
		<div class="automatic_notes_heading">Customize "My Loads" Columns</div>
		<br>
		<!--- Customize Load Screen Columns --->
		<cfif Len(request.qGetSystemSetupOptions.LoadsColumns)>
		<div>
			<input type="hidden" name="sortedLoadColumns" id="sortedLoadColumns" value="#request.qGetSystemSetupOptions.LoadsColumns#">
			<input type="hidden" name="statusLoadColumns" id="statusLoadColumns" value="#request.qGetSystemSetupOptions.LoadsColumnsStatus#">
			<cfset loadsColumnStatus="#request.qGetSystemSetupOptions.LoadsColumnsStatus#">
			<ul id="sortable">
				
			<cfloop list="#request.qGetSystemSetupOptions.LoadsColumns#" item="colname" index="i">	
				<cfset activeColumn = ListGetAt(loadsColumnStatus,i)>
				<cfif activeColumn eq 1>
					<cfset clsStatus = 'active-color'>
				<cfelse>
					<cfset clsStatus = 'inactive-color'>
				</cfif>
				<li style="font-size: 12px;font-weight: bold;" class="ui-state-default #clsStatus#">		
					<span class="ui-icon ui-icon-arrowthick-2-n-s"></span><cfif colname EQ 'UserDef7'>#request.qGetSystemSetupOptions.UserDef7#<cfelse>#colname#</cfif>
				</li>
			</cfloop>
			</ul>
		</div>
		<br>
		</cfif>
		<div class="clear"></div>
		<div class="automatic_notes_heading">Dashboard Login</div>
		<label>User</label> 
		<input name="DashboardUser" id="DashboardUser" type="text" value="#variables.DashboardUser#" maxlength="8" readonly style="background-color: ##cdc7c7;width: 50px;">
		<div class="clear"></div>
		<label>Password</label> 
		<input name="DashboardPassword" id="DashboardPassword" type="text" value="#variables.DashboardPassword#" maxlength="8" readonly style="background-color: ##cdc7c7;width: 50px;">
		<input type="button" value="Generate New Password" style="width:155px !important;" onclick="generateNewDashboardPassword()">
		<div class="clear"></div>
		<label>Show</label> 
		<select name="ShowDashboard" id="ShowDashboard" style="width: 55px;">
			<option value="0">Select</option> 
			<option value="1" <cfif request.qGetSystemSetupOptions.ShowDashboard EQ 1> selected="selected" </cfif> >Sales</option>
			<option value="2" <cfif request.qGetSystemSetupOptions.ShowDashboard EQ 2> selected="selected" </cfif>>Profit</option>
			<option value="3" <cfif request.qGetSystemSetupOptions.ShowDashboard EQ 3> selected="selected" </cfif>>Loads</option>
		</select>
		<div class="clear"></div><hr>
		<label style="width:120px;">Use BETA version</label>
		<input type="hidden" name="UseBetaVersionHidden" value="#request.qGetSystemSetupOptions.useBetaVersion#" >
		<input type="checkbox" name="useBetaVersion" id="useBetaVersion" style="width:12px;" <cfif request.qGetSystemSetupOptions.useBetaVersion> checked="checked"</cfif> value="1">
		<div class="clear"></div>
		<hr>
		<label style="width:120px;">Use Condensed Reports</label>
		<input type="checkbox" name="UseCondensedReports" id="UseCondensedReports" style="width:12px;" <cfif request.qGetSystemSetupOptions.UseCondensedReports> checked="checked"</cfif> value="1">
		<div class="clear"></div>
		<div class="automatic_notes_heading">Multi-Company Settings</div>
		<label style="width:110px;margin-top:15px;">Activate Bill From</label>
		<input type="checkbox" name="BillFromCompanies" onclick="checkActivateBill();" id="BillFromCompanies" style="width:12px;margin-top:15px;" <cfif request.qGetSystemSetupOptions.BillFromCompanies EQ 1>checked</cfif>>
		<cfif request.qGetSystemSetupOptions.FreightBroker EQ 1>
			<cfset variables.ApplyBillFromCompanyToCarrierReport = 'Carrier Rate Con'>
		<cfelseif request.qGetSystemSetupOptions.FreightBroker EQ 0>
			<cfset variables.ApplyBillFromCompanyToCarrierReport = 'Dispatch'>
		<cfelse>
			<cfset variables.ApplyBillFromCompanyToCarrierReport = 'Carrier Rate Con And Dispatch'>
		</cfif>

		<cfif request.qGetSystemSetupOptions.Dispatch EQ 1>
			<cfset variables.ApplyBillFromCompanyToCarrierReport = 'Carrier Rate Con/Dispatch'>
		</cfif>
		<div class="hidecheckBoxGroup">
			<input type="checkbox" name="ApplyBillFromCompanyToCarrierReport" id="ApplyBillFromCompanyToCarrierReport" style="width:12px;margin-top:15px;float:right;" <cfif request.qGetSystemSetupOptions.ApplyBillFromCompanyToCarrierReport EQ 1>checked</cfif>>
			<label style="width:230px;margin-top:15px;float:right;">Apply To #variables.ApplyBillFromCompanyToCarrierReport# Report</label>
		</div>
		<div class="clear">&nbsp;</div><hr>
		<div class="automatic_notes_heading">Customer Offices</div>
		<label style="width:160px;margin-top:15px;">Only display customers if they belong to the User's office</label>
		<input type="checkbox" name="ShowAllOfficeCustomers" id="ShowAllOfficeCustomers" style="width:12px;margin-top:15px;" <cfif request.qGetSystemSetupOptions.ShowAllOfficeCustomers EQ 0>checked</cfif>>
		<cfif session.CompanyID EQ '0CF71FC3-DACA-4926-A00F-95FD39C30257'>
			<div class="clear"></div><hr>
			<label style="width:120px;">Include Carrier Rate</label>
			<input type="checkbox" name="IncludeCarrierRate" id="IncludeCarrierRate" style="width:12px;" <cfif request.qGetSystemSetupOptions.IncludeCarrierRate> checked="checked"</cfif> >
		</cfif>
		</fieldset>
		</div>
		<div class="form-con">
		<fieldset>	

        <label>Minimum Margin</label>
        <cfinput type="text" name="minimumMargin" id="minimumMargin" value="#NumberFormat(request.qGetSystemSetupOptions.minimumMargin,'0.00')#" tabindex="3" onClick="document.getElementById('message').style.display='none';" style="width:28px;"><span style="float: left">%</span>

        <label>Prompt Admin for override approval</label>
        <input type="checkbox" class="input_width"  name="MinMarginOverrideApproval" id="MinMarginOverrideApproval"  value="2"  <cfif request.qGetSystemSetupOptions.MinMarginOverrideApproval EQ true>checked="checked"</cfif>>
        <div class="clear"></div>
        <hr>
		<label>Enter Carrier Invoice##</label>
        <input type="checkbox" class="input_width"  name="showCarrierInvoiceNumber" id="showCarrierInvoiceNumber" <cfif request.qGetSystemSetupOptions.showCarrierInvoiceNumber EQ true>checked="checked"</cfif> onchange="DisplayCarrierIncNumber(this.checked)">
		<div class="DivIncNumber" <cfif request.qGetSystemSetupOptions.showCarrierInvoiceNumber NEQ true>style="display:none"</cfif>>
			<label>Show on "All Loads" screen?</label>
			<input type="checkbox" class="input_width"  name="ShowCarrierInvoiceNumberInAllLoads" id="ShowCarrierInvoiceNumberInAllLoads"  value="2"  <cfif request.qGetSystemSetupOptions.ShowCarrierInvoiceNumberInAllLoads EQ true>checked="checked"</cfif>>
		</div>
		<div class="clear">&nbsp;</div>
		<hr>
		<label>Show #variables.freightBrokerVal#s with Expired #variables.expiredType#</label>
        <input type="checkbox" class="input_width"  name="showExpCarriers" id="showExpCarriers" <cfif request.qGetSystemSetupOptions.showExpiredInsuranceCarriers EQ true>checked="checked"</cfif>>
        <label>Allow Booking</label>
        <input type="checkbox" class="input_width"  name="allowBooking" id="allowBooking" <cfif request.qGetSystemSetupOptions.allowBooking EQ true>checked="checked"</cfif>>
		<div class="clear">&nbsp;</div>
		<hr>
		<label style="margin-top: 6px;">Status for Dispatch Notes</label>
        <input type="checkbox"  class="input_width" name="statusDispatchNote" id="statusDispatchNote" <cfif request.qGetSystemSetupOptions.StatusDispatchNotes EQ true>checked="checked"</cfif> style="margin-top:12px;">
		<div class="clear">&nbsp;</div>
		
		<label style="margin-top: 6px;">Edit Dispatch Notes</label>
        <input type="checkbox"  class="input_width" name="editDispatchNotes" id="editDispatchNotes" <cfif request.qGetSystemSetupOptions.editDispatchNotes EQ 1>checked="checked"</cfif>style="margin-top:12px;">
		<div class="clear">&nbsp;</div>

		<label style="margin-top: 6px;">Copy Loads Limit</label>
        <input type="text" name="CopyLoadLimit" id="CopyLoadLimit" value="#request.qGetSystemSetupOptions.CopyLoadLimit#" style="margin-top:10px;" onchange="checkforNumeric(this)"  maxlength="3"/>
		<div class="clear">&nbsp;</div>

		<label style="margin-top: 6px;">Copy Sales Rep/Dispatcher?</label>
		<input type="checkbox"  class="input_width" name="CopyLoadIncludeAgentAndDispatcher" id="CopyLoadIncludeAgentAndDispatcher" <cfif request.qGetSystemSetupOptions.CopyLoadIncludeAgentAndDispatcher EQ 1>checked="checked"</cfif>style="margin-top:12px;">
		<div class="clear"> </div>

		<label style="margin-top: 6px;">Copy Delivery/Pickup Dates?</label>
		<input type="checkbox"  class="input_width" name="CopyLoadDeliveryPickupDates" id="CopyLoadDeliveryPickupDates" <cfif request.qGetSystemSetupOptions.CopyLoadDeliveryPickupDates EQ 1>checked="checked"</cfif>style="margin-top:12px;">
		<div class="clear"> </div>

		<label style="margin-top:14px;">Copy Carrier?</label>
		<input type="checkbox"  class="input_width" name="CopyLoadCarrier" id="CopyLoadCarrier" <cfif request.qGetSystemSetupOptions.CopyLoadCarrier EQ 1>checked="checked"</cfif>style="margin-top:12px;">
		<div class="clear"> </div>

		<label style="margin-top:6px;">Show copy options in Load Screen?</label>
		<input type="checkbox"  class="input_width" name="ShowLoadCopyOptions" id="ShowLoadCopyOptions" <cfif request.qGetSystemSetupOptions.ShowLoadCopyOptions EQ 1>checked="checked"</cfif>style="margin-top:12px;">
		<div class="clear"> </div>

		<label style="margin-top: 6px;">Check for duplicate Vendor Code while updating Carriers?</label>
		<input id="" class="input_width" name="CheckVendorCode" <cfif request.qGetSystemSetupOptions.AllowDuplicateVendorCode EQ 1>checked="checked"</cfif> style="margin-top:12px;" type="checkbox">
		<div class="clear">&nbsp;</div>		
		
		<div style="margin:3px;">
			<hr>
			<label style="margin-top: 6px;">Assign New Load ## For Booked Loads</label>
			<input type="checkbox"  class="input_width" name="LoadNumberAutoIncrement" id="LoadNumberAutoIncrement" <cfif request.qGetSystemSetupOptions.LoadNumberAutoIncrement EQ 1>checked="checked"</cfif>  style="margin-top:12px;" onchange="CheckLoadNumberIncrease();">
			
			<div class="StartingLoad"  <cfif request.qGetSystemSetupOptions.LoadNumberAutoIncrement EQ 0>style="display:none;"</cfif> >
			<label style="margin-top: 6px;">New Starting Load##</label>
			<input type="text"  class=" " name="StartingActiveLoadNumber" maxlength="9" id="StartingActiveLoadNumber" value="#request.qGetSystemSetupOptions.StartingActiveLoadNumber#" style="margin-top:12px;width:134px !important;" >
			</div>
			<div class="clear">&nbsp;</div>
			<hr>
		</div>
		
		<div class="AutomaticNotesStamp" style="width:88%;border-top: 0;">
			<div class="automatic_notes_heading">Default Emails for Load Status Updates</div>
			<div class="clear">&nbsp;</div>
			<div style="width:250px;float:left;">	
				<cfset DefaultLoadEmailsList ="Customer">
				<cfif len(trim(request.qGetCompanyInformation.email)) AND request.qGetSystemSetupOptions.FreightBroker NEQ 0>
					<cfset DefaultLoadEmailsList =listAppend(DefaultLoadEmailsList, "Sales Rep")>
				</cfif>
				<cfset DefaultLoadEmailsList =listAppend(DefaultLoadEmailsList, "Dispatcher,Company")>

				<cfloop list="#DefaultLoadEmailsList#" item="defEmail">
					<div class="float_left" style="width: 350px;">
						<input class="input_width" type="checkbox" name="DefaultLoadEmails" value="#defEmail#" <cfif listFindNoCase(request.qGetSystemSetupOptions.DefaultLoadEmails, defEmail)> checked="checked" </cfif>/>
						<span class="notes_msg">#defEmail#<cfif defEmail EQ "Company"> (#request.qGetCompanyInformation.email#)</cfif></span>
					</div>
					<div class="clear"></div>
				</cfloop>
			</div>
			<div class="clear"></div>
			<label style="width:112px;">Default Subject Text</label>
			<input type="text" name="DefaultLoadEmailSubject" style="width:400px" value="#request.qGetSystemSetupOptions.DefaultLoadEmailSubject#" maxlength="100">
			<div class="clear"></div>
			<label>Default Email Text</label> <input type="button" value="Default Email" onclick="resetDefaultLoadEmailtext();" style="width: 100px !important;margin-top: -5px;">
			<cftextarea name="DefaultLoadEmailtext" style="height:200px;width:400px" maxlength="4000">#request.qGetSystemSetupOptions.DefaultLoadEmailtext#</cftextarea>

			<div class="clear"></div>
		</div>
		<div class="clear"></div><hr>


		<div class="AutomaticNotesStamp" style="width:88%;border-top: 0;">
			<div class="automatic_notes_heading">Onboarding Email</div>
			<div class="clear">&nbsp;</div>
			<label style="width:112px;">Default Subject Text</label>
			<input type="text" name="DefaultOnboardingEmailSubject" id="DefaultOnboardingEmailSubject" style="width:400px" value="#request.qGetSystemSetupOptions.DefaultOnboardingEmailSubject#" maxlength="100">
			<div class="clear"></div>
			<label style="width:22px;">CC</label>
			<input type="text" name="DefaultOnboardingEmailCC" style="width:400px" value="#request.qGetSystemSetupOptions.DefaultOnboardingEmailCC#" maxlength="100">
			<div class="clear"></div>
			<label>Default Email Text</label> <input type="button" value="Default Email" onclick="resetOnboardingEmailtext();" style="width: 100px !important;margin-top: -5px;">
			<cftextarea name="DefaultOnboardingEmailtext" style="height:200px;width:400px" maxlength="4000">#request.qGetSystemSetupOptions.DefaultOnboardingEmailtext#</cftextarea>
			<div class="clear"></div>
		</div>
		<div class="clear"></div><hr>


		<div class="AutomaticNotesStamp" style="width:88%;border-top: 0;">
			<div class="automatic_notes_heading">Lane Alert Default Email Text</div>

			<label style="width:112px;">Default Subject Text</label>
			<input type="text" name="DefaultLaneAlertEmailSubject" id="DefaultLaneAlertEmailSubject" style="width:400px" value="#request.qGetSystemSetupOptions.DefaultLaneAlertEmailSubject#" maxlength="100">
			<div class="clear"></div>
			<label>Default Email Text</label><input type="button" value="Default Email" onclick="resetLaneAlertEmailtext();" style="width: 100px !important;margin-top: -5px;">
			<cftextarea name="DefaultLaneAlertEmailtext" style="height:200px;width:400px" maxlength="4000">#request.qGetSystemSetupOptions.DefaultLaneAlertEmailtext#</cftextarea>
			<div class="clear"></div>
		</div>
		<div class="clear"></div><hr>
		<div class="AutomaticNotesStamp" style="width:88%;border-top: 0;">
			<div class="automatic_notes_heading">Automatic Dispatch Notes</div>
			<div class="clear">&nbsp;</div>
			<div style="width:165px;float:left;">	
				<div class="float_left">
					<input class="input_width" type="checkbox" name="EmailReports" value="" <cfif request.qGetSystemSetupOptions.AutomaticEmailReports EQ true>checked="checked"</cfif>/>
					<span class="notes_msg">Email Reports</span>
				</div>
				<div class="clear"></div>
				<div class="float_left">
					<input class="input_width" type="checkbox" name="PrintReports" value="" <cfif request.qGetSystemSetupOptions.AutomaticPrintReports EQ true>checked="checked"</cfif>/>
					<span class="notes_msg">Print Reports</span>
				</div>
				<div class="clear"></div>
				<div class="float_left">
					<input class="input_width" type="checkbox" name="AutomaticCustomerRateChanges" value="" <cfif request.qGetSystemSetupOptions.AutomaticCustomerRateChanges EQ 1>checked="checked"</cfif>/>
					<span class="notes_msg">Customer Rate Changes</span>
				</div>
				<div class="clear"></div>
				<div class="float_left">
					<input class="input_width" type="checkbox" name="AutomaticCarrierRateChanges" value="" <cfif request.qGetSystemSetupOptions.AutomaticCarrierRateChanges EQ 1>checked="checked"</cfif>/>
					<span class="notes_msg">Carrier Rate Changes</span>
				</div>
			</div>
		</div>
		<div class="clear">&nbsp;</div>	<hr>	
		<!-- Automatic Notes Stamp starts here -->
        
		<div class="AutomaticNotesStamp" style="width:88%;border-top: 0;">
			
			<div class="automatic_notes_heading">Automatic Notes Stamp</div>
			<div class="clear">&nbsp;</div>
			<div style="width:165px;float:left;">	
				<div class="float_left">
					<input class="input_width" type="checkbox" name="DispatchNotes" value="" <cfif request.qGetSystemSetupOptions.DispatchNotes EQ true>checked="checked"</cfif>/>
					<span class="notes_msg">Dispatch Notes</span>
				</div>
				<div class="clear"></div>
				<div class="float_left">
					<input class="input_width" type="checkbox" name="CarrierNotes" value=""  <cfif request.qGetSystemSetupOptions.CarrierNotes EQ true>checked="checked"</cfif>/>
					<span class="notes_msg">#variables.freightBrokerVal# Notes</span>
				</div>
				<div class="clear"></div>
				<div class="float_left">
					<input class="input_width" type="checkbox" name="Notes" value="" <cfif request.qGetSystemSetupOptions.Notes EQ true>checked="checked"</cfif>/>
					<span class="notes_msg">Notes</span>
				</div>
			</div>
			<div style="width:212px;float:left;">
				<div><span style="padding-left:5px;float:left">UserDef1</span><input type="text" name="userDef1" value="#request.qGetSystemSetupOptions.userDef1#" style="position:relative;left:10px;width:146px;" maxlength="200" /></div>
				<div><span style="padding-left:5px;float:left">UserDef2</span><input type="text" name="userDef2" value="#request.qGetSystemSetupOptions.userDef2#" style="position:relative;left:10px;width:146px;" maxlength="200"/></div>
				<div><span style="padding-left:5px;float:left">UserDef3</span><input type="text" name="userDef3" value="#request.qGetSystemSetupOptions.userDef3#" style="position:relative;left:10px;width:146px;" maxlength="200"/></div>
				<div><span style="padding-left:5px;float:left">UserDef4</span><input type="text" name="userDef4" value="#request.qGetSystemSetupOptions.userDef4#" style="position:relative;left:10px;width:146px;" maxlength="200"/></div>
				<div><span style="padding-left:5px;float:left">UserDef5</span><input type="text" name="userDef5" value="#request.qGetSystemSetupOptions.userDef5#" style="position:relative;left:10px;width:146px;" maxlength="200"/></div>
				<div><span style="padding-left:5px;float:left">UserDef6</span><input type="text" name="userDef6" value="#request.qGetSystemSetupOptions.userDef6#" style="position:relative;left:10px;width:146px;" maxlength="200"/></div>
			</div>

			<div class="clear"></div>
			<label>Lock Load Status</label>
			<select name="lockloadStatus" id="lockloadStatus" onchange="document.getElementById('message').style.display='none';">
				<option value="none" selected>None</option>
				<cfloop query="request.qLoadStatus">
					<option value="#request.qLoadStatus.value#" <cfif request.qSystemSetupOptions1.lockloadstatus EQ request.qLoadStatus.value> selected </cfif> >#request.qLoadStatus.statusdescription#</option>
				</cfloop>
			</select>
        	<div class="clear"></div>
        	<label style="width:103px">EDI204 Load Status</label>
			<select name="EDIloadStatus" id="EDIloadStatus">
				<cfloop query="request.qLoadStatus">
					<option value="#request.qLoadStatus.value#" <cfif request.qSystemSetupOptions1.EDIloadStatus EQ request.qLoadStatus.value> selected </cfif> >#request.qLoadStatus.statusdescription#</option>
				</cfloop>
			</select>
        	<div class="clear"></div>
			<label style="width:103px">Carrier Load Status Lane Save</label>
			<select name="CarrierLoadStatusLaneSave" id="CarrierLoadStatusLaneSave">
				<cfloop query="request.qLoadStatus">
					<option value="#request.qLoadStatus.value#" <cfif request.qGetSystemSetupOptions.CarrierLoadStatusLaneSave EQ request.qLoadStatus.value> selected </cfif> >#request.qLoadStatus.statusdescription#</option>
				</cfloop>
			</select>
        	<div class="clear"></div>
		</div>
		<div class="clear"></div>
		<div style="margin-top: 35px;">
         	<div class="clear"></div>
			<label>#variables.freightBrokerVal# terms</label><label style="display: none;">eSignature</label> 
			<cftextarea name="CarrierTerms" style="height:200px;width:400px;margin-top:5px;" maxlength="4000">#request.qGetSystemSetupOptions.CarrierTerms#</cftextarea>
			<div class="clear"></div>
         </div>
		<div class="AutomaticNotesStamp" style="width:100%">
			<div class="automatic_notes_heading">Subject Content Reports
				<span style="font-size: 11px;margin: 0 8px 0 40px;">Include Load ##</span>
				<input type="checkbox" name="includeLoadNumber" id="includeLoadNumber" <cfif request.qGetSystemSetupOptions.IsIncludeLoadNumber EQ true>checked="checked"</cfif> style="width:12px; position: absolute;" />
			</div>
			<div class="clear"> </div>
			<label style="width: 155px;text-align:left;">
				<cfif request.qSystemSetupOptions1.freightBroker>
					#variables.freightBrokerVal#
				<cfelse>
					Dispatch
				</cfif>
				Report
			</label> 
			<input type="text" name="CarrierHead" style="width:400px" value="#CarrierHead#" maxlength="1000">
			<div class="clear"></div>
			<label style="width: 155px;text-align:left;">Customer Invoice Report</label> 
			<input type="text" name="CustInvHead" style="width:400px" value="#CustInvHead#" maxlength="1000">
			<div class="clear"></div>
			<label style="width: 155px;text-align:left;">BOL Report</label> 
			<input type="text" name="BOLHead" style="width:400px" value="#BOLHead#" maxlength="1000">
			<div class="clear"></div>
			<label style="width: 155px;text-align:left;">Work Order Import</label> 
			<input type="text" name="WorkImpHead" style="width:400px" value="#WorkImpHead#" maxlength="1000">
			<div class="clear"></div>
			<label style="width: 155px;text-align:left;">Work Order Export</label> 
			<input type="text" name="WorkExpHead" style="width:400px" value="#WorkExpHead#" maxlength="1000">
			<div class="clear"></div>
			<label style="width: 155px;text-align:left;">Sales/Commission Report</label> 
			<input type="text" name="SalesHead" style="width:400px" value="#SalesHead#" maxlength="1000">
			<label style="width: 155px;text-align:left;">E-dispatch (mobile web app) </label> 
			<input type="text" name="EDispatchHead" style="width:400px" value="#EDispatchHead#" maxlength="1000">
			<div class="clear"></div>
		</div>
         <!-- Automatic Notes Stamp ends here -->
		<hr>
		<div>
			<div class="automatic_notes_heading">Mobile Dispatch Settings</div>
			<input type="hidden" name="EDispatchOptionsOld" value="#request.qGetSystemSetupOptions.EDispatchOptions#">
			<label style="width:117px;">Mobile App Type</label>
			<input type="radio" name="EDispatchOptions" value="0" style="width:12px;margin-bottom:0;" <cfif request.qGetSystemSetupOptions.EDispatchOptions EQ 0>checked</cfif> onclick="showGPSInterval(1);showMpApi(0);showTextIns(0);showAutoEmailUpdates(1);"><span style="float:left">Mobile App</span>
			<input type="checkbox" name="AutoSendEMailUpdates" id="AutoSendEMailUpdates" style="width:12px;float:left;margin-left:10px;margin-right:2px !important;margin-bottom: 0;<cfif request.qGetSystemSetupOptions.EDispatchOptions NEQ 0>display:none;</cfif>" <cfif request.qGetSystemSetupOptions.AutoSendEMailUpdates EQ 1>checked</cfif>>
			<span id="spn_AutoSendEMailUpdates" style="<cfif request.qGetSystemSetupOptions.EDispatchOptions NEQ 0>display:none;</cfif>">Auto-Send email updates</span>
			<div class="clear"></div>
			<input type="radio" name="EDispatchOptions" value="1" style="width:12px;margin-left: 127px;margin-bottom:0;" <cfif request.qGetSystemSetupOptions.EDispatchOptions EQ 1>checked</cfif> onclick="showGPSInterval(1);showMpApi(0);showTextIns(1);showAutoEmailUpdates(0);"><span>Web App</span>
			<div class="clear"></div>
			<input type="radio" name="EDispatchOptions" value="2" style="width:12px;margin-left: 127px;margin-bottom:0;" <cfif request.qGetSystemSetupOptions.EDispatchOptions EQ 2>checked</cfif> onclick="showGPSInterval(1);showMpApi(1);showTextIns(0);showAutoEmailUpdates(0);"><span>Web App with MacroPoint</span>
			<div class="clear"></div>
			<input type="radio" name="EDispatchOptions" value="3" style="width:12px;margin-left: 127px;" <cfif request.qGetSystemSetupOptions.EDispatchOptions EQ 3>checked</cfif> onclick="showGPSInterval(0);showMpApi(1);showTextIns(0);showAutoEmailUpdates(0);"><span>Macro Point only</span>
		</div>
		<div class="clear">&nbsp;</div>
		<label style="width:118px">GPS Update Interval</label> 
		<input name="GPSUpdateInterval" id="GPSUpdateInterval" type="text" value="#request.qGetSystemSetupOptions.GPSUpdateInterval#" style="width:30px;" onchange="validateGPSInterval()"/>mins
		<div class="clear">&nbsp;</div>
		<label style="width:118px">GPS Distance Interval</label> 
		<input name="GPSDistanceInterval" id="GPSDistanceInterval" type="text" value="#request.qGetSystemSetupOptions.GPSDistanceInterval#" style="width:30px;" onchange="validateFloatField(this)"/>miles
		<div class="clear">&nbsp;</div>

		<label style="width:118px">GeoFence Radius</label> 
		<input name="GeoFenceRadius" id="GeoFenceRadius" type="text" value="#request.qGetSystemSetupOptions.GeoFenceRadius#" style="width:30px;" onchange="validateFloatField(this)"/>yards
		<div class="clear">&nbsp;</div>

		<div id="divMpApi" <cfif listFind("0,1", request.qGetSystemSetupOptions.EDispatchOptions)>style="display:none;"</cfif>>
			<label style="width:118px">MacroPoint ID</label> 
			<input name="MacropointId" id="MacropointId" type="text" value="#request.qGetSystemSetupOptions.MacropointId#"/>
			<div class="clear">&nbsp;</div>
			<label style="width:118px">MacroPoint API Login</label> 
			<input name="MacropointApiLogin" id="MacropointApiLogin" type="text" value="#request.qGetSystemSetupOptions.MacropointApiLogin#"/>
			<div class="clear">&nbsp;</div>
			<label style="width:118px">MacroPoint API Password</label> 
			<input name="MacropointApiPassword" id="MacropointApiPassword" type="password" value="#request.qGetSystemSetupOptions.MacropointApiPassword#"/>
		</div>
		<div class="clear">&nbsp;</div>
		<div id="divGPSInterval" <cfif request.qGetSystemSetupOptions.EDispatchOptions EQ 3>style="display:none;"</cfif>>
			<label style="width:118px">Stop GPS Load Status</label> 

			<select name="MobileStopTrackingStatus" id="MobileStopTrackingStatus">
				<cfloop query="request.qLoadStatus">
					<option value="#request.qLoadStatus.Text#" <cfif request.qGetSystemSetupOptions.MobileStopTrackingStatus EQ request.qLoadStatus.Text> selected </cfif> >#request.qLoadStatus.statusdescription#</option>
				</cfloop>
			</select>

		</div>
		<div class="clear">&nbsp;</div>
		<div id="divTextIns" <cfif listFind("0,2,3", request.qGetSystemSetupOptions.EDispatchOptions)>style="display:none;"</cfif>>
			<label style="width:118px">TEXT Message for<br>E-Dispatch Instructions</label> 
			<textarea name="EDispatchTextInstructions">#request.qGetSystemSetupOptions.EDispatchTextInstructions#</textarea>
		</div>
		<div class="clear">&nbsp;</div>
		<div>
			<label style="width:118px">Default TEXT<br>Message for<br>E-Dispatch </label> 
			<textarea name="EDispatchTextMessage" style="width: 120px;">#request.qGetSystemSetupOptions.EDispatchTextMessage#</textarea>
		</div>
		<div class="clear">&nbsp;</div>
		<div>
			<label style="width:118px">Default EMAIL<br>Message for<br>E-Dispatch</label> 
			<textarea name="EDispatchMailText" style="width: 120px;">#request.qGetSystemSetupOptions.EDispatchMailText#</textarea>
		</div>
		<div class="clear">&nbsp;</div>



		<label style="width:118px;">Show Load Status on Mobile App?</label>
		<input type="checkbox" class="input_width"  name="ShowLoadStatusOnMobileApp" id="ShowLoadStatusOnMobileApp" style="width:12px;" <cfif request.qGetSystemSetupOptions.ShowLoadStatusOnMobileApp EQ 1>checked</cfif>>
		<div class="clear">&nbsp;</div>

		<label style="width:118px;">Show #variables.freightBrokerVal# notes on Mobile App?</label>
		<input type="checkbox" class="input_width"  name="ShowCarrierNotesOnMobileApp" id="ShowCarrierNotesOnMobileApp" style="width:12px;" <cfif request.qGetSystemSetupOptions.ShowCarrierNotesOnMobileApp EQ 1>checked</cfif>>
		<div class="clear">&nbsp;</div>
		<hr>
		<div>
			<label style="width:117px;">Carrier LNI</label>

			<input type="radio" name="CarrierLNI" value="0" style="width:12px;position:relative;right:0px;" <cfif request.qGetSystemSetupOptions.CarrierLNI EQ 0>checked</cfif>><span style="position:relative;right:0px;">FMCSA DB</span><br/>

			<input type="radio" name="CarrierLNI" value="1" style="width:12px;position:relative;right:20px;" <cfif request.qGetSystemSetupOptions.CarrierLNI EQ 1>checked</cfif>><span style="position:relative;right:20px;">FMCSA SERVER</span><br/>

			<input type="submit" name="updateViaSaferWatch" value="Update Via SaferWatch" style="width:12px;position:relative;right:80px;float:right;<cfif request.qGetSystemSetupOptions.CarrierLNI NEQ 3>display:none;</cfif>">

			<input type="button" onclick="getDotNumberForUpdate();" name="updateViaCarrierLookout" value="Update Via Carrier Lookout" style="width:160px !important;position:relative;right:80px;float:right;<cfif request.qGetSystemSetupOptions.CarrierLNI NEQ 2>display:none;</cfif>">
			
		</div>
		<div class="clear">&nbsp;</div>
		<div style="width:414px;float: left;">
			<label style="width:121px;">Auto-add Customer via DOT ##?</label>
			<input type="checkbox" name="autoAddCustViaDOT" id="autoAddCustViaDOT" style="width:12px;margin-left: -4px;" <cfif request.qGetSystemSetupOptions.autoAddCustViaDOT EQ 1>checked</cfif>>
		</div>
		<div class="clear">&nbsp;</div>
		<div>
			<label style="width:117px;">Customer LNI</label>
			<input type="radio" name="CustomerLNI" value="0" style="width:12px;" <cfif request.qGetSystemSetupOptions.CustomerLNI EQ 0>checked</cfif>><span>FMCSA DB</span><br/>
			<input type="radio" name="CustomerLNI" value="1" style="width:12px;position:relative;right:20px;" <cfif request.qGetSystemSetupOptions.CustomerLNI EQ 1>checked</cfif>><span style="position:relative;right:20px;">FMCSA SERVER</span><br/>
			<input type="radio" name="CustomerLNI" value="3" style="width:12px;position:relative;right:40px;" <cfif request.qGetSystemSetupOptions.CustomerLNI EQ 3>checked</cfif>><span style="position:relative;right:40px;">SAFERWATCH</span><br>
			<cfif request.qGetSystemSetupOptions.CustomerLNI EQ 3>
				<input type="submit" name="updateViaSaferWatchCustomer" value="Update Via SaferWatch" style="width:12px;position:relative;right:80px;float:right;">
			</cfif>
		</div>
		<div class="clear">&nbsp;</div>
		<hr>
		<!--- BEGIN: System setup option to lock the load Order Date --->
		<div style="width:414px;float: left;">
		<label style="width:118px;">Display Update Loads Button</label>
        <input type="checkbox" name="rolloverShipDate" id="rolloverShipDate" <cfif request.qGetSystemSetupOptions.rolloverShipDateStatus EQ true>checked="checked"</cfif> style="width:12px;">
		</div>
		<div style="width:414px;float: left;">
			<label style="width:118px;">Edit Order Date</label>
			<input type="checkbox" name="isLockOrderDate" id="isLockOrderDate" style="width:12px;" <cfif request.qGetSystemSetupOptions.IsLockOrderDate EQ 1>checked</cfif>>
		</div>
		<!--- END: System setup option to lock the load Order Date --->
		<div style="width:414px;float: left;">
			<label style="width:121px;">Edit Credit Limit</label>
			<input type="checkbox" name="editCreditLimit" id="editCreditLimit" style="width:12px;margin-left: -4px;" <cfif request.qGetSystemSetupOptions.editCreditLimit EQ 1>checked</cfif>>
		</div>
		<div style="width:414px;float: left;">
			<label style="width:121px;">Show Scan Button</label>
			<input type="checkbox" name="showScanButton" id="showScanButton" style="width:12px;margin-left: -4px;" <cfif request.qGetSystemSetupOptions.showScanButton EQ 1>checked</cfif>>
		</div>
		<div style="width:414px;float: left;">
			<label style="width:121px;">Include ## of Trips in Reports?</label>
			<input type="checkbox" name="includeNumberofTripsInReports" id="includeNumberofTripsInReports" style="width:12px;margin-left: -4px;" <cfif request.qGetSystemSetupOptions.includeNumberofTripsInReports EQ 1>checked</cfif>>
		</div>
		<div style="width:414px;float: left;">
			<label style="width:121px;">Force user to enter trip ##?</label>
			<input type="checkbox" name="forceUserToEnterTrip" id="forceUserToEnterTrip" style="width:12px;margin-left: -4px;" <cfif request.qGetSystemSetupOptions.forceUserToEnterTrip EQ 1>checked</cfif>>
		</div>
		<div style="width:414px;float: left;">
			<label style="width:121px;">Show Load Status Filter?</label>
			<input type="checkbox" name="ShowLoadTypeStatusOnLoadsScreen" id="ShowLoadTypeStatusOnLoadsScreen" style="width:12px;margin-left: -4px;" <cfif request.qGetSystemSetupOptions.ShowLoadTypeStatusOnLoadsScreen EQ 1>checked</cfif>>
		</div>
		<div style="width:414px;float: left;">
			<label style="width:121px;">Update customer from load screen?</label>
			<input type="checkbox" name="UpdateCustomerFromLoadScreen" id="UpdateCustomerFromLoadScreen" style="width:12px;margin-left: -4px;" <cfif request.qGetSystemSetupOptions.UpdateCustomerFromLoadScreen EQ 1>checked</cfif>>
		</div>
		<div style="width:414px;float: left;">
			<label style="width:121px;">Project44</label>
			<input type="checkbox" name="Project44" id="Project44" style="width:12px;margin-left: -4px;" <cfif request.qGetSystemSetupOptions.Project44 EQ 1>checked</cfif>>
		</div>
		<div style="width:414px;float: left;">
			<label style="width:121px;">Send Email Notice when deploying MacroPoint</label>
			<input type="checkbox" name="SendEmailNoticeMacroPoint" id="SendEmailNoticeMacroPoint" style="width:12px;margin-left: -4px;" <cfif request.qGetSystemSetupOptions.SendEmailNoticeMacroPoint EQ 1>checked</cfif>>
		</div>
		<div style="width:414px;float: left;">
			<label style="width:121px;">B.O.L Report Format</label>
			<select name="BOLReportFormat" id="BOLReportFormat" style="width:100px;">>
				<option value="Preprinted" <cfif request.qGetSystemSetupOptions.BOLReportFormat EQ 'Preprinted'> selected="selected" </cfif>>Preprinted</option>
				<option value="Laser" <cfif request.qGetSystemSetupOptions.BOLReportFormat EQ 'Laser'> selected="selected" </cfif>>Laser</option>
			</select>
		</div>
		<div style="width:414px;float: left;">
			<label style="width:121px;">Time Zone</label>
			<input type="checkbox" name="TimeZone" id="TimeZone" style="width:12px;margin-left: -4px;" <cfif request.qGetSystemSetupOptions.TimeZone EQ 1>checked</cfif>>
		</div>
		<div style="width:414px;float: left;">
			<label style="width:121px;">Rate Con/E-Dispatch Prompt Options</label>
			<input type="radio" name="RateConPromptOption" value="0" style="width:12px;" <cfif request.qGetSystemSetupOptions.RateConPromptOption EQ 0> checked </cfif>><span>Update Load Status to Dispatched<br>after Rate Con</span><br/>
			<input type="radio" name="RateConPromptOption" value="1" style="width:12px;position:relative;right:20px;margin-left: 151px;" <cfif request.qGetSystemSetupOptions.RateConPromptOption EQ 1> checked </cfif>><span style="position:relative;right:20px;">Prompt user to Update Load status to Dispatched.</span><br/>
			<input type="radio" name="RateConPromptOption" value="2" style="width:12px;position:relative;right:20px;margin-left: 152px;" <cfif request.qGetSystemSetupOptions.RateConPromptOption EQ 2> checked </cfif>><span style="position:relative;right:20px;">Do not prompt user to Update Load status.</span>
		</div>
		<div style="width:414px;float: left;">
			<label style="width:121px;">Use Non-Fee Accessorials on<br>BOL report?</label>
			<input type="checkbox" name="UseNonFeeAccOnBOL" id="UseNonFeeAccOnBOL" style="width:12px;margin-left: -4px;" <cfif request.qGetSystemSetupOptions.UseNonFeeAccOnBOL EQ 1>checked</cfif>>
		</div>
		<div style="width:414px;float: left;">
			<label style="width:121px;">Require Address When Adding Customers</label>
			<input type="checkbox" name="ReqAddressWhenAddingCust" id="ReqAddressWhenAddingCust" style="width:12px;margin-left: -4px;" <cfif request.qGetSystemSetupOptions.ReqAddressWhenAddingCust EQ 1>checked</cfif>>
		</div>
		<cfif request.qSystemSetupOptions1.freightBroker NEQ 1>
			<div style="width:414px;float: left;">
				<label style="width:121px;">Include DH Miles in Total Miles</label>
				<input type="checkbox" name="IncludeDhMilesInTotalMiles" id="IncludeDhMilesInTotalMiles" style="width:12px;margin-left: -4px;" <cfif request.qGetSystemSetupOptions.IncludeDhMilesInTotalMiles EQ 1>checked</cfif>>
			</div>
		</cfif>
		<div style="width:414px;float: left;">
			<label style="width:121px;">Default Country</label>
			<select name="DefaultCountry" id="DefaultCountry" style="width:100px;">>
				<option value="">Select</option>
				<cfloop query="request.qCountries">
		        	<cfif request.qCountries.countrycode EQ 'US'>
		        		<option value="#request.qCountries.countryID#" <cfif request.qCountries.countryID EQ request.qGetSystemSetupOptions.DefaultCountry> selected="selected" </cfif> >#request.qCountries.country#</option>
		        	</cfif>
		        </cfloop>
		        <cfloop query="request.qCountries">
		        	<cfif request.qCountries.countrycode EQ 'CA'>
		        		<option data-code="#request.qCountries.countrycode#" value="#request.qCountries.countryID#" <cfif request.qCountries.countryID EQ request.qGetSystemSetupOptions.DefaultCountry> selected="selected" </cfif> >#request.qCountries.country#</option>
		        	</cfif>
		        </cfloop>
				<cfloop query="request.qCountries">
					<cfif not listFindNoCase("CA,US", request.qCountries.countrycode)>
			        	<option data-code="#request.qCountries.countrycode#" value="#request.qCountries.countryID#" <cfif request.qCountries.countryID EQ request.qGetSystemSetupOptions.DefaultCountry> selected="selected" </cfif>>#request.qCountries.country#</option>
			        </cfif>
				</cfloop>
			</select>
		</div>
		<div style="width:414px;float: left;">
			<label style="width:121px;">Calculate Deadhead Miles Using</label>
			<input type="radio" name="CalculateDHOption" value="0" style="width:12px;" <cfif request.qGetSystemSetupOptions.CalculateDHOption EQ 0> checked </cfif>><span>Equipment</span><br/>
			<input type="radio" name="CalculateDHOption" value="1" style="width:12px;position:relative;right:20px;" <cfif request.qGetSystemSetupOptions.CalculateDHOption EQ 1> checked </cfif>><span style="position:relative;right:20px;">Driver</span>
		</div>
		<div style="width:414px;float: left;">
			<label style="width:121px;">Use Direct Cost</label>
			<input type="checkbox" name="UseDirectCost" id="UseDirectCost" style="width:12px;margin-left: -4px;" <cfif request.qGetSystemSetupOptions.UseDirectCost EQ 1>checked</cfif>>
		</div>
		<div style="width:414px;float: left;">
			<label style="width:121px;">Show Maximum Carrier Rate in<br>Load screen</label>
			<input type="checkbox" name="ShowMaxCarrRateInLoadScreen" id="ShowMaxCarrRateInLoadScreen" style="width:12px;margin-left: -4px;" <cfif request.qGetSystemSetupOptions.ShowMaxCarrRateInLoadScreen EQ 1>checked</cfif>>
		</div>
		<div style="width:414px;float: left;">
			<label style="width:121px;">Temperature Setting</label>
			<select name="TemperatureSetting" id="TemperatureSetting" style="width:100px;">>
				<option value="1" <cfif request.qGetSystemSetupOptions.TemperatureSetting EQ 1> selected="selected" </cfif>>Fahrenheit</option>
				<option value="2" <cfif request.qGetSystemSetupOptions.TemperatureSetting EQ 2> selected="selected" </cfif>>Celsius</option>
				<option value="0" <cfif request.qGetSystemSetupOptions.TemperatureSetting EQ 0> selected="selected" </cfif>>Either</option>
			</select>
		</div>
    	<div style="width:414px;float: left;">
			<label style="width:121px;">Require Delivery Date</label>
			<input type="checkbox" name="RequireDeliveryDate" id="RequireDeliveryDate" style="width:12px;margin-left: -4px;" <cfif request.qGetSystemSetupOptions.RequireDeliveryDate EQ 1>checked</cfif>>
		</div>
		<div class="clear"></div>	
		<div style="width:414px;float: left;">
			<label style="width:121px;">Non-Commissionable</label>
			<input type="checkbox" name="NonCommissionable" id="NonCommissionable" style="width:12px;margin-left: -4px;" <cfif request.qGetSystemSetupOptions.NonCommissionable EQ 1>checked</cfif>>
		</div>
		<div class="clear"></div>	
		<div class="clear">&nbsp;</div>
		<div class="clear">&nbsp;</div>
        <div class="clear"></div>     
	</div>
   <div class="clear"></div>
 </cfform>
    </div>
    
	<div class="white-bot"></div>
</div>
<div class="overlay">
</div>
<img src="images/loadingbar.gif" id="loader">
<strong id="loadingmsg">Updating.It will take some time.Please Wait.</strong>
</cfoutput>