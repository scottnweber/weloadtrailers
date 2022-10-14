<cfcomponent output="true">
	<!--- <cfsetting showdebugoutput="false"> --->

	<cffunction name="init" access="public" output="false" returntype="void">
		<cfargument name="dsn" type="string" required="yes" />
		<cfset variables.dsn = Application.dsn />
	</cffunction>

	<!--- Get current Agent --->
	<cffunction name="getcurAgentdetails" access="public" returntype="query">
		<cfargument name="employeID" required="yes" type="string">
		<cfquery name="qcurAgentdetails" datasource="#variables.dsn#">
	    	SELECT integratewithTran360,trans360Usename,trans360Password,IntegrationID, 
	    	loadBoard123,loadBoard123Usename,loadBoard123Password,RoleID,E.PEPcustomerKey
	    		,IntegrateWithDirectFreightLoadboard,DirectFreightLoadboardUserName,DirectFreightLoadboardPassword,LoadBoard123Default,IntegrateWithTran360Default,IntegrateWithDirectFreightLoadboardDefault,integratewithPEP,O.integratewithITS,integratewithPEPDefault,integratewithITSDefault,DefaultSalesRepToLoad,DefaultDispatcherToLoad
	    		,S.proMilesStatus,S.PCMilerUsername,S.PCMilerPassword,S.PCMilerCompanyCode AS CompanyCode
	        FROM SystemConfig S
	        LEFT JOIN Employees E ON E.EmployeeID = 
	        <cfif len(trim(arguments.employeID))>
	        	<cfqueryparam value="#arguments.employeID#" cfsqltype="cf_sql_varchar">
	        <cfelse>
	        	<cfqueryparam value="" cfsqltype="cf_sql_varchar" null="true">
	        </cfif>
	        LEFT JOIN Offices O ON O.OfficeID = E.OfficeID
	        WHERE S.CompanyID = 
	        <cfif structKeyExists(session, "CompanyID")>
	       		<cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar">
	       	<cfelse>
	       		<cfqueryparam value="" cfsqltype="cf_sql_varchar" null="true">
	        </cfif>
	    </cfquery>
	    <cfif not isDefined("qcurAgentdetails.loadBoard123")>
	    	<cfdocument format="pdf" filename="C:\pdf\Debug_#DateTimeFormat(now(),"YYYY_MM_dd_HH_nn_ss_l")#.pdf" overwrite="true">
	    		<cfdump var="#datetimeformat(now())#">
		    	<cfdump var="#qcurAgentdetails#">
		    	<cfdump var="EmployeeID#arguments.employeID#">
		    	<cfif structKeyExists(session, "CompanyID")>
			    	<cfdump var="CompanyID:#session.CompanyID#">
			    </cfif>
			</cfdocument>
	    </cfif>
	    <cfreturn qcurAgentdetails>
	</cffunction>
<!--- I	get edi204logdata --->
	<cffunction name="getedi204logdata" access="public" returntype="query">
		<cfargument name="loadID" required="yes" type="any">
		<cfquery name="qgetedi204logdata" datasource="#variables.dsn#">
	      
	      SELECT DOCTYPE,CreatedDate,1 as 'exists' FROM EDI204Log WHERE LoadNumber IN (SELECT LoadNumber FROM Loads WHERE LoadID=<cfqueryparam value="#arguments.loadID#" cfsqltype="cf_sql_varchar">)
				UNION  select '204','1900-01-01',0 as 'exists'
				UNION  select '990','1900-01-01',0 as 'exists'
				UNION  select '210','1900-01-01',0 as 'exists'
				UNION  select '212','1900-01-01',0 as 'exists'
				UNION  select '214','1900-01-01',0 as 'exists'
				UNION  select '820','1900-01-01',0 as 'exists'
	    </cfquery>
	    <cfreturn qgetedi204logdata>
	</cffunction>

	<cffunction name="getcurAgentMaildetails" access="public" returntype="query">
		<cfargument name="employeID" required="yes" type="string">
		<cfquery name="qcurAgentdetails" datasource="#variables.dsn#">
	    	SELECT Name, EmailID, SmtpAddress, SmtpUsername, SmtpPassword, SmtpPort, useTLS, useSSL,emailSignature,EmailValidated,Telephone
	        FROM Employees
	        WHERE EmployeeID = <cfif len(trim(arguments.employeID))>
	        	<cfqueryparam value="#arguments.employeID#" cfsqltype="cf_sql_varchar">
	        <cfelse>
	        	<cfqueryparam value="" cfsqltype="cf_sql_varchar" null="true">
	        </cfif>
	    </cfquery>
	    <cfreturn qcurAgentdetails>
	</cffunction>

	<!--- Get Load Status--->
	<cffunction name="getLoadStatus" access="public" returntype="query">
		<cfargument name="LoadStatusID" required="No" type="any">
		<CFSTOREDPROC PROCEDURE="USP_GetStatus" DATASOURCE="#variables.dsn#">
			<cfif isdefined('arguments.LoadStatusID') and len(arguments.LoadStatusID)>
			 	<CFPROCPARAM VALUE="#arguments.LoadStatusID#" cfsqltype="CF_SQL_VARCHAR">
			<cfelse>
			 	<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR">
			</cfif>
			<CFPROCPARAM VALUE="#session.CompanyID#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCRESULT NAME="qrygetstatus">
		</CFSTOREDPROC>
	    <cfreturn qrygetstatus>
	</cffunction>

	<!--- Get Load StatusTypeText self defined --->
	<cffunction name="getLoadStatusTypes" access="public" returntype="query">
	   	<cfquery name="qryGetLoadStatusTypes" datasource="#variables.dsn#">
			SELECT statustypeid, statustext, colorCode, TextColorCode, Filter, ForceNextStatus, AllowOnMobileWebApp, SendEmailForLoads ,StatusDescription, SendUpdateOneTime, IsActive
			FROM LoadStatusTypes WHERE CompanyID = <cfqueryparam value="#session.companyID#" cfsqltype="CF_SQL_VARCHAR">
			ORDER BY StatusOrder 
		</cfquery>
		<cfreturn qryGetLoadStatusTypes>
	</cffunction>

	<!--- Get Load StatusTypeID --->
	<cffunction name="getLoadStatusTypeId" access="public" returntype="query">
		<cfargument name="LoadStatus" required="yes" type="string">
		<cfquery name="qrygetstatusTypeID" datasource="#variables.dsn#">
	    	SELECT StatusTypeID
	        FROM LoadStatusTypes
	        WHERE StatusText = <cfqueryparam value="#arguments.LoadStatus#" cfsqltype="CF_SQL_VARCHAR">
	        AND CompanyID = <cfqueryparam value="#session.companyID#" cfsqltype="CF_SQL_VARCHAR">
	    </cfquery>
	    <cfreturn qrygetstatusTypeID>
	</cffunction>

	<!--- Get Load Details for report--->

	<cffunction name="getCarrierReportInfoFromLoad" access="public" returntype="query">
		<cfargument name="LoadID" required="yes" type="any">
		<CFSTOREDPROC PROCEDURE="USP_GetReportInfoFromLoad" DATASOURCE="#variables.dsn#">
		 	<CFPROCPARAM VALUE="#arguments.LoadID#" cfsqltype="CF_SQL_VARCHAR">

	        <CFPROCRESULT NAME="qrygetstatus">
		</CFSTOREDPROC>
	    <cfreturn qrygetstatus>
	</cffunction>

	<!--- Get Cutomer Info--->

	<cffunction name="getAjaxLoadCustomerInfo1" access="remote" output="yes">
		<cfargument name="dsn" type="string" required="yes" />
		<cfargument name="customerID" required="No" type="any" default="">
		<cfargument name="urlToken" required="no" type="any">
		<cfargument name="type" required="no" type="any">
		<cfargument name="loadid" required="no" type="any" default="">
		<!--- call SP to Get a Customer Info--->
		<CFSTOREDPROC PROCEDURE="USP_GetCustomerinfoForLoad" DATASOURCE="#arguments.dsn#">
			<cfif isdefined('arguments.CustomerID') and len(arguments.CustomerID)>
			 	<CFPROCPARAM VALUE="#arguments.CustomerID#" cfsqltype="CF_SQL_VARCHAR">
			 <cfelse>
			 	<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR">
			 </cfif>
			 <CFPROCPARAM VALUE="#arguments.type#" cfsqltype="CF_SQL_VARCHAR">
			 <CFPROCRESULT NAME="qrygetcustomers">
		</CFSTOREDPROC>

		<cfset local.customerContact = qrygetcustomers.ContactPerson>
		<cfset local.customerPhone = qrygetcustomers.TEL>
		<cfset local.customerPhoneExt = qrygetcustomers.EXT>
		<cfset local.customerCell = qrygetcustomers.Cel>
		<cfset local.customerFax = qrygetcustomers.Fax>
		<cfset local.customerEmail = qrygetcustomers.Email>
		<cfif structKeyExists(arguments, "loadid") and len(trim(arguments.loadid)) and trim(arguments.loadid) neq 0>
			<cfquery name="qGetLoadContact" datasource="#arguments.dsn#">
				select ContactPerson,Phone,PhoneExt,CellNo,Fax,ContactEmail from loads  where loadid=<cfqueryparam Value="#arguments.loadid#" cfsqltype="cf_sql_varchar">
			</cfquery>
			<cfset local.customerContact = qGetLoadContact.ContactPerson>
			<cfset local.customerPhone = qGetLoadContact.Phone>
			<cfset local.customerPhoneExt = qGetLoadContact.PhoneExt>
			<cfset local.customerCell = qGetLoadContact.CellNo>
			<cfset local.customerFax = qGetLoadContact.Fax>
			<cfif len(trim(qGetLoadContact.ContactEmail))>
				<cfset local.customerEmail = qGetLoadContact.ContactEmail>
			</cfif>
		</cfif>

		<cfsavecontent variable="customerInfoForm">
			<cfoutput>
				<input name="customerID" type="hidden" value="#arguments.CustomerID#" />
				<input name="customerAddress" id="customerAddress" type="hidden" value="#qrygetcustomers.location#"/>
				<input name="customerCity" id="customerCity" type="hidden" value="#qrygetcustomers.city#"/>
				<input name="customerState" id="customerState" type="hidden" value="#qrygetcustomers.stateCode#"/>
				<input name="customerZipCode" id="customerZipCode" type="hidden" value="#qrygetcustomers.zipCode#"/>
				<input name="customerDefaultCurrency" id="customerDefaultCurrency" type="hidden" value="#qrygetcustomers.DefaultCurrency#"/>

				<label class="field-textarea" style="width:188px;"><b><a class="customerLink" href="index.cfm?event=addcustomer&customerid=#arguments.CustomerID#&#arguments.urlToken#" style="color:##4322cc;text-decoration:underline;" target="_blank">#qrygetcustomers.custname#</a></b><br/> #qrygetcustomers.location# <br/>
				#qrygetcustomers.City#, #qrygetcustomers.stateCode# #qrygetcustomers.ZIPCODE#</label>
				<div class="clear"></div>
				<label>Contact</label><input name="CustomerContact" value="#local.customerContact#">
				<div class="clear"></div>
				<label>Tel</label>
				<input name="customerPhone" value="#local.customerPhone#" style="width: 89px;">
				<label class="space_load">Ext</label>
                <input name="customerPhoneExt" value="#local.customerPhoneExt#" style="width: 31px;" maxlength="30">
                <div class="clear"></div>
				<label>Cell</label>
				<input name="customerCell" value="#local.customerCell#" style="width: 90px;">
				<label class="space_load">Fax</label>
				<input name="customerFax" value="#local.customerFax#" style="width: 90px;">
				<div class="clear"></div>
				<label>Email</label>
				<input name="CustomerEmail" value="#local.customerEmail#"  style="width: 248px;">
			</cfoutput>
		</cfsavecontent>
		#customerInfoForm#
	</cffunction>

	<cffunction name="getAjaxLoadCustomerInfo2" access="remote" output="yes">
		<cfargument name="dsn" type="string" required="yes" />
		<cfargument name="customerID" required="No" type="any">
		<!--- call SP to Get a Customer Info--->
		<CFSTOREDPROC PROCEDURE="USP_GetCustomerinfoForLoad" DATASOURCE="#arguments.dsn#">
			<cfif isdefined('arguments.CustomerID') and len(arguments.CustomerID)>
			 	<CFPROCPARAM VALUE="#arguments.CustomerID#" cfsqltype="CF_SQL_VARCHAR">
			 <cfelse>
			 	<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR">
			 </cfif>
			 <CFPROCPARAM VALUE="Billing" cfsqltype="CF_SQL_VARCHAR">
			 <CFPROCRESULT NAME="qrygetcustomers">
		</CFSTOREDPROC>

		<cfsavecontent variable="customerInfoForm">
			<cfoutput>
				<fieldset>
					<div style="width:100%">
						<table style="border-collapse: collapse;border-spacing: 0;">
							<tbody>
								<tbody>
								<tr>
								  <td><label style="text-align: left !important;width: 65px !important;padding-right:3px;">Credit Limit</label></td>
								  <td><label class="field-text disabledLoadInputs" id="CreditLimit" style="text-align:right !important; width: 60px !important;margin:0px;">#dollarformat(qrygetcustomers.CreditLimit)#</label></td>
									<input id="CreditLimitInput" name="CreditLimitInput" value="#qrygetcustomers.CreditLimit#" type="hidden"  />
								  <td><label style="text-align: left !important;width: 40px !important;padding: 0 5px 0 14px;">Balance</label></td>
								  <td><label class="field-text disabledLoadInputs" id="Balance" style="text-align:right !important; width: 60px !important;margin:0px;">#dollarformat(qrygetcustomers.Balance)#</label></td>
								  <input id="BalanceInput" name="BalanceInput" value="#qrygetcustomers.Balance#" type="hidden"  />
								  <td><label style="text-align: left !important;width: 50px !important;padding: 0 3px 0 14px;">Available</label></td>
								  <td><label class="field-text disabledLoadInputs" id="Available" style="text-align:right !important; width: 60px !important;margin:0px;">#dollarformat(qrygetcustomers.Available)#</label></td>
								  <input id="AvailableInput" name="AvailableInput" value="#qrygetcustomers.Available#" type="hidden"  />
								</tr>
							</tbody>
							</tbody>
						</table>
					</div>
					<div class="clear"></div>
					<label class="space_it_medium margin_top">Notes</label>
					<div class="clear"></div>
					<textarea name="billToNotes" id="billToNotes" style="width: 375px;">#qrygetcustomers.Notes#</textarea>
					<div class="clear"></div>
					<label class="space_it_medium margin_top">Dispatch Notes</label>
					<div class="clear"></div>
					<textarea name="billToDispNotes" id="billToDispNotes" style="width: 375px;">#qrygetcustomers.DispatchNotes#</textarea>
					<div class="clear"></div>

				</fieldset>
			<!---</div>--->
			</cfoutput>
		</cfsavecontent>
		#customerInfoForm#
	</cffunction>

	<!--- Get Carrier List--->
	<cffunction name="getAjaxCarrierlist" access="remote" returntype="string">
		<cfargument name="dsn" type="string" required="yes" />
		<cfargument name="filterChar" required="No" type="any">
		<!--- call SP to Get a carrier Info--->
		<CFSTOREDPROC PROCEDURE="USP_GetCarrierListByFilterChar" DATASOURCE="#arguments.dsn#">
			<cfif isdefined('arguments.filterChar') and len(arguments.filterChar)>
			 	<CFPROCPARAM VALUE="#arguments.filterChar#" cfsqltype="CF_SQL_VARCHAR">
			 <cfelse>
			 	<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR">
			 </cfif>
			 <CFPROCRESULT NAME="qrygetFilterCarrier">
		</CFSTOREDPROC>

		<cfsavecontent variable="filteredCarrierList">
			<cfoutput>
				<select size="10" name="filterList" class="carrier-select" style="height:162px" onchange="DisplayIntextField(this.value,this.options[this.selectedIndex].text,'#arguments.dsn#');">
					<cfloop query="qrygetFilterCarrier">
						<option value="#qrygetFilterCarrier.value#">
							#ucase(arguments.filterChar)# & #qrygetFilterCarrier.TEXT# &nbsp;&nbsp;&nbsp;#qrygetFilterCarrier.city#&nbsp;#qrygetFilterCarrier.statecode#&nbsp;&nbsp;&nbsp;&nbsp;#qrygetFilterCarrier.phone#&nbsp;&nbsp;&nbsp;&nbsp;#qrygetFilterCarrier.status#
						</option>
					</cfloop>
				</select>
			</cfoutput>
		</cfsavecontent>
		<cfreturn filteredCarrierList>
	</cffunction>

	<!--- Set Long and Short Miles --->
	<cffunction name="setSystemSetupOptions" access="public" returntype="string">
		<cfargument name="ARAndAPExportStatusID" type="string" required="yes"/>
		<cfargument name="showExpiredInsuranceCarriers" type="string" required="yes"/>
		<cfargument name="showCarrierInvoiceNumber" type="string" required="yes"/>
		<cfargument name="dispatch_notes" type="string" required="yes" />
		<cfargument name="carrier_notes" type="string" required="yes" />
		<cfargument name="simple_notes" type="string" required="yes" />
		<cfargument name="requireValidMCNumber" type="string" required="yes"/>
		<cfargument name="CarrierTerms" type="string" required="yes"/>
		<cfargument name="Triger_loadStatus" type="string" required="yes"/>
		<cfargument name="AllowLoadentry" type="string" required="yes"/>
		<cfargument name="showReadyArriveDat" type="string" required="yes"/>
		<cfargument name="userDef1" type="string" required="yes"/>
		<cfargument name="userDef2" type="string" required="yes"/>
		<cfargument name="userDef3" type="string" required="yes"/>
		<cfargument name="userDef4" type="string" required="yes"/>
		<cfargument name="userDef5" type="string" required="yes"/>
		<cfargument name="userDef6" type="string" required="yes"/>
		<cfargument name="userDef7" type="string" required="no"/>
		<cfargument name="googleMapsPcMiler" type="numeric" required="yes"/>
		<cfargument name="minimumMargin" type="numeric" required="yes"/>
		<cfargument name="CarrierHead" type="string" required="yes"/>
		<cfargument name="CustInvHead" type="string" required="yes"/>
		<cfargument name="BOLHead" type="string" required="yes"/>
		<cfargument name="WorkImpHead" type="string" required="yes"/>
		<cfargument name="WorkExpHead" type="string" required="yes"/>
		<cfargument name="SalesHead" type="string" required="yes"/>
		<cfargument name="minimunLoadNumber" type="numeric" required="yes"/>
		<cfargument name="statusDispatchNote" type="string" required="yes"/>
		<cfargument name="emailreports" type="string" required="yes"/>
		<cfargument name="printReports" type="string" required="yes"/>
		<cfargument name="CustomerTerms" type="string" required="yes"/>
		<cfargument name="loadNumberAssignment" type="string" required="yes"/>
		<cfargument name="commodityWeight" type="string" required="yes"/>
		<cfargument name="rolloverShipDateStatus" type="string" required="yes"/>
		<cfargument name="editDispatchNotes" type="string" required="no"/>
		<cfargument name="showcarrieramount" type="string" required="no"/>
		<cfargument name="showcustomeramount" type="string" required="no"/>
		<cfargument name="rowsperpage" type="any" required="no"/>
		<cfargument name="lockloadstatus" type="string" required="no"/>
		<cfargument name="BackgroundColor" type="string" required="no"/>
		<cfargument name="BackgroundColorForContent" type="string" required="no"/>
		<cfargument name="CopyLoadLimit" type="numeric" required="no"/>
		<cfargument name="CopyLoadIncludeAgentAndDispatcher" type="string" required="no"/>	
		<cfargument name="LoadNumberAutoIncrement" type="string" required="no"/>	
		<cfargument name="StartingActiveLoadNumber" type="string" required="no"/>	
		<cfargument name="ShowCarrierInvoiceNumberInAllLoads" type="boolean" required="no" default="0"/>	
		<cfargument name="CheckVendorCode" type="boolean" required="no" default="0"/>
		<cfargument name="LoadLimit" type="string" required="no" default="0"/>
		<cfargument name="IsLoadLogEnabled" type="string" required="no" default="0"/>
		<cfargument name="LoadLogLimit" type="numeric" required="yes" default="0"/>
		<cfargument name="ForeignCurrencyEnabled" type="string" required="no" default="0"/>		
		<cfargument name="DefaultSystemCurrency" type="numeric" required="no" default="1"/>		
		<cfargument name="AllowedSystemCurrencies" type="string" required="no" default=""/>
		<cfargument name="PCMilerAPIKey" type="string" required="no" default=""/>		
		<cfargument name="numberOfCarrierInEmail" type="any" required="no" default="0"/>	
		<cfargument name="includeLoadNumber" type="any" required="no" default="0"/>	
		<cfargument name="activateBulkAndLoadNotificationEmail" type="any" required="no" default="0"/>	
		<cfargument name="getFMCSAFrom" type="numeric" required="no" default="0"/>
		<cfargument name="IsEDispatchSmartPhone" type="numeric" required="no" default="0"/>
		<cfargument name="IsLockOrderDate" type="numeric" required="no" default="0"/>
		<cfargument name="ShowMiles" type="numeric" required="no" default="0"/>
		<cfargument name="ShowDeadHeadMiles" type="numeric" required="no" default="0"/>
		
		<cfargument name="MyCarrierPackets" type="boolean" required="no" default="0"/>
		<cfargument name="MyCarrierPacketsUsername" type="string" required="no" default=""/>
		<cfargument name="MyCarrierPacketsPassword" type="string" required="no" default=""/>

		<cfargument name="CarrierLNI" type="string" required="no" default="0"/>
		<cfargument name="EDispatchOptions" type="string" required="no" default="0"/>
		<cfargument name="GPSUpdateInterval" type="string" required="no" default="0"/>
		<cfargument name="editCreditLimit" type="string" required="no" default="0"/>
		<cfargument name="showScanButton" type="string" required="no" default="0"/>
		<cfargument name="CustomerLNI" type="string" required="no" default="0"/>
		<cfargument name="ComDataUnitID" type="string" required="no" default=""/>
		<cfargument name="ComDataCustomerID" type="string" required="no" default=""/>
		<cfargument name="forceUserToEnterTrip" type="string" required="no" default="0"/>
		<cfargument name="FactoringFee" type="numeric" required="no" default="0"/>
		<cfargument name="Edi210EsignReq" type="boolean" required="no" default="0"/>
		<cfargument name="carrierratecon" type="boolean" required="no" default="1"/>
		<cfargument name="IsLoadStatusDefaultForReport" type="string" required="yes"/>
		<cfargument name="AllowBooking" type="string" required="no" default="0"/>
		<cfargument name="ShowLoadStatusOnMobileApp" type="boolean" required="no" default="0"/>
		<cfargument name="TurnOnConsolidatedInvoices" type="boolean" required="no" default="0"/>
		<cfargument name="MacropointId" type="string" required="no" default="0"/>
		<cfargument name="MacropointApiLogin" type="string" required="no" default="0"/>
		<cfargument name="MacropointApiPassword" type="string" required="no" default="0"/>
		<cfargument name="MobileStopTrackingStatus" type="string" required="no" default="0"/>
		<cfargument name="Project44" type="boolean" required="no" default="0"/>
		<cfargument name="SendEmailNoticeMacroPoint" type="boolean" required="no" default="0"/>
		<cfargument name="EDispatchTextInstructions" type="string" required="no" default=""/>
		<cfargument name="EDispatchMailText" type="string" required="no" default=""/>
		<cfargument name="BOLReportFormat" type="string" required="no" default=""/>
		<cfargument name="EDispatchTextMessage" type="string" required="no" default=""/>
		<cfargument name="QBDefBillAccountName" type="string" required="no" default=""/>
		<cfargument name="QBDefInvItemName" type="string" required="no" default=""/>
		<cfargument name="QBDefInvPayTerm" type="string" required="no" default=""/>
		<cfargument name="QBDefBillPayTerm" type="string" required="no" default=""/>
		<cfargument name="TimeZone" type="boolean" required="no" default="0"/>
		<cfargument name="RateConPromptOption" type="string" required="no" default="0"/>
		<cfargument name="UseNonFeeAccOnBOL" type="boolean" required="no" default="0"/>
		<cfargument name="CustomerCRMCallBackCircleColor" type="string" required="no" default=""/>
		<cfargument name="CarrierCRMCallBackCircleColor" type="string" required="no" default=""/>
		<cfargument name="DriverCRMCallBackCircleColor" type="string" required="no" default=""/>
		<cfargument name="ReqAddressWhenAddingCust" type="boolean" required="no" default="0"/>
		<cfargument name="IncludeDhMilesInTotalMiles" type="boolean" required="no" default="0"/>
		<cfargument name="DefaultCountry" type="string" required="no" default=""/>
		<cfargument name="ShortBOLTerms" type="string" required="yes"/>
		<cfargument name="BackgroundColorAccounting" type="string" required="no"/>
		<cfargument name="BackgroundColorForContentAccounting" type="string" required="no"/>
		<cfargument name="ShowCarrierNotesOnMobileApp" type="boolean" required="no" default="0"/>
		<cfargument name="CalculateDHOption" type="string" required="no" default="0"/>
		<cfargument name="APExportStatusID" type="string" required="yes"/>
		<cfargument name="UseDirectCost" type="boolean" required="no" default="0"/>
		<cfargument name="CopyLoadDeliveryPickupDates" type="string" required="no"/>	
		<cfargument name="CopyLoadCarrier" type="string" required="no"/>	
		<cfargument name="ShowLoadCopyOptions" type="string" required="no"/>	
		<cfargument name="TemperatureSetting" type="string" required="no"/>
		<cfargument name="EDispatchHead" type="string" required="yes"/>
		<cfargument name="ShowCustomerTermsOnInvoice" type="boolean" required="no" default="0"/>
		<cfargument name="CarrierLoadStatusLaneSave" type="string" required="no"/>
		<cfargument name="QBCarrierInvoiceASRef" type="boolean" required="no" default="0"/>
		<cfargument name="QBFactoringNameOnBill" type="boolean" required="no" default="0"/>
		<cfargument name="ConsolidateInvoiceStatusUpdate" type="string" required="no" default=""/>
		<cfargument name="ConsolidateInvoiceDateUpdate" type="boolean" required="no" default="0"/>
		<cfargument name="ConsolidateInvoiceTriggerStatus" type="string" required="no" default=""/>
		<cfargument name="ExcludeTemplateLoadNumber" type="boolean" required="no" default="0"/>
		<cfargument name="GPSDistanceInterval" type="string" required="no" default="0"/>
		<cfargument name="DefaultLoadEmails" type="string" required="no" default=""/>
		<cfargument name="DefaultLoadEmailtext" type="string" required="no" default=""/>
		<cfargument name="DefaultLoadEmailSubject" type="string" required="no" default=""/>
		<cfargument name="DefaultLaneAlertEmailtext" type="string" required="no" default=""/>
		<cfargument name="DefaultLaneAlertEmailSubject" type="string" required="no" default=""/>
		<cfargument name="DashboardUser" type="string" required="no" default=""/>
		<cfargument name="DashboardPassword" type="string" required="no" default=""/>
		<cfargument name="ShowDashboard" type="string" required="no" default=""/>
		<cfargument name="AutoSendEMailUpdates" type="boolean" required="no" default="0"/>
		<cfargument name="MinMarginOverrideApproval" type="boolean" required="no" default="0"/>
		<cfargument name="QBFactoringNameOnInvoice" type="boolean" required="no" default="0"/>
		<cfargument name="DefaultOnboardingEmailSubject" type="string" required="no" default=""/>
		<cfargument name="DefaultOnboardingEmailCC" type="string" required="no" default=""/>
		<cfargument name="DefaultOnboardingEmailtext" type="string" required="no" default=""/>
		<cfargument name="GeoFenceRadius" type="numeric" required="no" default="0"/>
		<cfargument name="useBetaVersion" type="boolean" required="no" default="0"/>
		<cfargument name="BillFromCompanies" type="boolean" required="no" default="0"/>
		<cfargument name="ApplyBillFromCompanyToCarrierReport" type="boolean" required="no" default="0"/>
		<cfargument name="IncludeCarrierRate" type="boolean" required="no" default="0"/>
		<cfargument name="ShowAllOfficeCustomers" type="boolean" required="no" default="0"/>
		<cfargument name="UseCondensedReports" type="boolean" required="no" default="1"/>
		<cfargument name="CustomerPaymentTerms" type="string" required="no" default=""/>
		<cfargument name="RequireDeliveryDate" type="boolean" required="no" default="0"/>
		<cfargument name="CustomerInvoiceformat" type="numeric" required="no" default="0"/>
		<cfargument name="AutomaticCustomerRateChanges" type="boolean" required="no" default="0"/>
		<cfargument name="AutomaticCarrierRateChanges" type="boolean" required="no" default="0"/>
		<cfargument name="ShowMaxCarrRateInLoadScreen" type="boolean" required="no" default="0"/>
		<cfargument name="NonCommissionable" type="boolean" required="no" default="0"/>
		<cfif NOT len(arguments.numberOfCarrierInEmail)>
			<cfset arguments.numberOfCarrierInEmail = 0>
		</cfif>
		<cfif NOT len(arguments.userDef1)>
			<cfset arguments.userDef1 = 'userDef1'>
		</cfif>
		<cfif NOT len(arguments.userDef2)>
			<cfset arguments.userDef2 = 'userDef2'>
		</cfif>
		<cfif NOT len(arguments.userDef3)>
			<cfset arguments.userDef3 = 'userDef3'>
		</cfif>
		<cfif NOT len(arguments.userDef4)>
			<cfset arguments.userDef4 = 'userDef4'>
		</cfif>
		<cfif NOT len(arguments.userDef5)>
			<cfset arguments.userDef5 = 'userDef5'>
		</cfif>
		<cfif NOT len(arguments.userDef6)>
			<cfset arguments.userDef6 = 'userDef6'>
		</cfif>
		<cfif NOT len(arguments.LoadLogLimit)>
			<cfset arguments.LoadLogLimit = 30>
		</cfif>

		<cfif LCase(requireValidMCNumber) EQ 'NO'>
			<cfset requireMCNoInCar = false>
		<cfelse>
			<cfset requireMCNoInCar = true>
		</cfif>
		<cfif LCase(showExpiredInsuranceCarriers) EQ 'NO'>
			<cfset showExpInsCar = false>
		<cfelse>
			<cfset showExpInsCar = true>
		</cfif>

		<cfif LCase(AllowBooking) EQ 'NO'>
			<cfset allowBooking = false>
		<cfelse>
			<cfset allowBooking = true>
		</cfif>
		
		<!--- set active currencies --->
		<cfquery name="qSetActiveCurrencies" datasource="#Application.dsn#">
	    	UPDATE Currencies
			SET IsActive = 1
			WHERE CurrencyID IN (<cfqueryparam value="#arguments.allowedSystemCurrencies#" cfsqltype="cf_sql_varchar" list="yes">)
			
			UPDATE Currencies
			SET IsActive = 0
			WHERE CurrencyID NOT IN (<cfqueryparam value="#arguments.allowedSystemCurrencies#" cfsqltype="cf_sql_varchar" list="yes">)
	    </cfquery>

		<cfquery name="qrySetSystemSetupOptions" datasource="#Application.dsn#" result="qResult">
			SET NOCOUNT ON
			UPDATE SystemConfig
			SET ARAndAPExportStatusID = <cfqueryparam value="#arguments.ARAndAPExportStatusID#" cfsqltype="cf_sql_varchar">,
			showExpiredInsuranceCarriers = <cfqueryparam value="#showExpInsCar#" cfsqltype="cf_sql_bit">,
			showCarrierInvoiceNumber = <cfqueryparam value="#arguments.showCarrierInvoiceNumber#" cfsqltype="cf_sql_bit">,
			DispatchNotes = <cfqueryparam value="#arguments.dispatch_notes#" cfsqltype="cf_sql_bit">,
		    CarrierNotes = <cfqueryparam value="#arguments.carrier_notes#" cfsqltype="cf_sql_bit">,
		    Notes = <cfqueryparam value="#arguments.simple_notes#" cfsqltype="cf_sql_bit">,
		    requireValidMCNumber = <cfqueryparam value="#requireMCNoInCar#" cfsqltype="cf_sql_bit">,

			CarrierTerms=<cfqueryparam value="#CarrierTerms#" cfsqltype="cf_sql_varchar">,
			Triger_loadStatus= <cfqueryparam value="#Triger_loadStatus#" cfsqltype="cf_sql_varchar"> ,
			AllowLoadentry= <cfqueryparam value="#AllowLoadentry#" cfsqltype="cf_sql_bit">,
			showReadyArriveDate = <cfqueryparam value="#showReadyArriveDat#" cfsqltype="cf_sql_bit">,

			userDef1 = <cfqueryparam value="#userDef1#" cfsqltype="cf_sql_varchar">,
			userDef2 = <cfqueryparam value="#userDef2#" cfsqltype="cf_sql_varchar">,
			userDef3 = <cfqueryparam value="#userDef3#" cfsqltype="cf_sql_varchar">,
			userDef4 = <cfqueryparam value="#userDef4#" cfsqltype="cf_sql_varchar">,
			userDef5 = <cfqueryparam value="#userDef5#" cfsqltype="cf_sql_varchar">,
			userDef6 = <cfqueryparam value="#userDef6#" cfsqltype="cf_sql_varchar">,
			<cfif structkeyexists(arguments,"userDef7")>
				userDef7 = <cfqueryparam value="#userDef7#" cfsqltype="cf_sql_varchar">,
			</cfif>
			googleMapsPcMiler = <cfqueryparam value="#googleMapsPcMiler#" cfsqltype="cf_sql_numeric">,
			minimumMargin = <cfqueryparam value="#arguments.minimumMargin#" cfsqltype="cf_sql_float">,
			CarrierHead=<cfqueryparam value="#arguments.CarrierHead#" cfsqltype="cf_sql_varchar">,
			CustInvHead=<cfqueryparam value="#arguments.CustInvHead#" cfsqltype="cf_sql_varchar">,
			BOLHead=<cfqueryparam value="#arguments.BOLHead#" cfsqltype="cf_sql_varchar">,
			WorkImpHead=<cfqueryparam value="#arguments.WorkImpHead#" cfsqltype="cf_sql_varchar">,
			WorkExpHead=<cfqueryparam value="#arguments.WorkExpHead#" cfsqltype="cf_sql_varchar">,
			SalesHead=<cfqueryparam value="#arguments.SalesHead#" cfsqltype="cf_sql_varchar">,
			MinimumLoadStartNumber=<cfqueryparam value="#arguments.minimunLoadNumber#" cfsqltype="cf_sql_numeric">,
			StatusDispatchNotes=<cfqueryparam value="#arguments.statusDispatchNote#" cfsqltype="cf_sql_bit">,
			AutomaticEmailReports = <cfqueryparam value="#arguments.emailreports#" cfsqltype="cf_sql_bit">,
			AutomaticPrintReports = <cfqueryparam value="#arguments.printReports#" cfsqltype="cf_sql_bit">,
			CustomerTerms=<cfqueryparam value="#arguments.CustomerTerms#" cfsqltype="cf_sql_varchar"> ,
			loadNumberAssignment=<cfqueryparam value="#arguments.loadNumberAssignment#" cfsqltype="cf_sql_integer">,
			commodityWeight=<cfqueryparam value="#arguments.commodityWeight#" cfsqltype="cf_sql_bit">,
			rolloverShipDateStatus=<cfqueryparam value="#arguments.rolloverShipDateStatus#" cfsqltype="cf_sql_bit">,
			showcarrieramount=<cfqueryparam value="#arguments.showcarrieramount#" cfsqltype="cf_sql_varchar"> ,
			EditDispatchNotes=<cfqueryparam value="#arguments.editDispatchNotes#" cfsqltype="cf_sql_varchar"> ,
			showcustomeramount=<cfqueryparam value="#arguments.showcustomeramount#" cfsqltype="cf_sql_varchar">,
			rowsperpage=<cfqueryparam value="#arguments.rowsperpage#">,
			lockloadstatus=<cfqueryparam value="#arguments.lockloadstatus#" cfsqltype="cf_sql_varchar">
			<cfif trim(arguments.BackgroundColor)  NEQ "">
				,BackgroundColor=<cfqueryparam value="#arguments.BackgroundColor#" cfsqltype="cf_sql_varchar">
			</cfif>
			<cfif trim(arguments.BackgroundColorForContent)  NEQ "">
				,BackgroundColorForContent=<cfqueryparam value="#arguments.BackgroundColorForContent#" cfsqltype="cf_sql_varchar">
			</cfif>
			<cfif structkeyexists(arguments,"CopyLoadIncludeAgentAndDispatcher") AND  trim(arguments.CopyLoadIncludeAgentAndDispatcher)  NEQ "">
				,CopyLoadIncludeAgentAndDispatcher=<cfqueryparam value="#arguments.CopyLoadIncludeAgentAndDispatcher#" cfsqltype="cf_sql_bit">			
			</cfif>			
			<cfif structkeyexists(arguments,"LoadNumberAutoIncrement") AND  trim(arguments.LoadNumberAutoIncrement)  NEQ "">
				,LoadNumberAutoIncrement=<cfqueryparam value="#arguments.LoadNumberAutoIncrement#" cfsqltype="cf_sql_bit">			
			</cfif>	
			<cfif structkeyexists(arguments,"StartingActiveLoadNumber") AND  trim(arguments.StartingActiveLoadNumber)  NEQ "">
				,StartingActiveLoadNumber=<cfqueryparam value="#arguments.StartingActiveLoadNumber#" cfsqltype="cf_sql_bigint">			
			</cfif>	
			,CopyLoadLimit =<cfqueryparam value="#arguments.CopyLoadLimit#" cfsqltype="cf_sql_integer">
			,ShowCarrierInvoiceNumberInAllLoads =  <cfqueryparam value="#arguments.ShowCarrierInvoiceNumberInAllLoads#" cfsqltype="cf_sql_bit">
			,AllowDuplicateVendorCode =  <cfqueryparam value="#arguments.CheckVendorCode#" cfsqltype="cf_sql_bit">
			,CarrierLoadLimit =  <cfqueryparam value="#val(arguments.LoadLimit)#" cfsqltype="cf_sql_integer">
			,IsLoadLogEnabled =  <cfqueryparam value="#val(arguments.IsLoadLogEnabled)#" cfsqltype="cf_sql_bit">
			,LoadLogLimit = <cfqueryparam value="#val(arguments.LoadLogLimit)#" cfsqltype="cf_sql_integer">
			,ForeignCurrencyEnabled = <cfqueryparam value="#val(arguments.ForeignCurrencyEnabled)#" cfsqltype="cf_sql_bit">
			,DefaultSystemCurrency = <cfqueryparam value="#val(arguments.DefaultSystemCurrency)#" cfsqltype="cf_sql_integer">
			,PCMilerAPIKey = <cfqueryparam value="#arguments.PCMilerAPIKey#" cfsqltype="cf_sql_nvarchar">
			,numberOfCarrierInEmail = <cfqueryparam value="#arguments.numberOfCarrierInEmail#" cfsqltype="cf_sql_integer">
			,IsIncludeLoadNumber = <cfqueryparam value="#arguments.includeLoadNumber#" cfsqltype="cf_sql_bit">
			,ActivateBulkAndLoadNotificationEmail = <cfqueryparam value="#arguments.activateBulkAndLoadNotificationEmail#" cfsqltype="cf_sql_bit">
			,GetFMCSAFrom = <cfqueryparam value="#arguments.getFMCSAFrom#" cfsqltype="cf_sql_integer">
			,IsEDispatchSmartPhone = <cfqueryparam value="#arguments.IsEDispatchSmartPhone#" cfsqltype="cf_sql_bit">
			,IsLockOrderDate = <cfqueryparam value="#arguments.IsLockOrderDate#" cfsqltype="cf_sql_bit">
			,ShowMiles = <cfqueryparam value="#arguments.ShowMiles#" cfsqltype="cf_sql_bit">
			,ShowDeadHeadMiles = <cfqueryparam value="#arguments.ShowDeadHeadMiles#" cfsqltype="cf_sql_bit">

			<cfif structKeyExists(arguments, "MyCarrierPackets")>
				,MyCarrierPackets = <cfqueryparam value="#val(arguments.MyCarrierPackets)#" cfsqltype="cf_sql_bit">
			</cfif>
			<cfif structkeyexists(arguments,"MyCarrierPacketsUsername")>
				,MyCarrierPacketsUsername=<cfqueryparam value="#arguments.MyCarrierPacketsUsername#" cfsqltype="cf_sql_varchar">
			</cfif>
			<cfif structkeyexists(arguments,"MyCarrierPacketsPassword")>
				,MyCarrierPacketsPassword=<cfqueryparam value="#arguments.MyCarrierPacketsPassword#" cfsqltype="cf_sql_varchar">
			</cfif>
			<cfif structkeyexists(arguments,"CarrierLNI") and len(arguments.CarrierLNI)>
				,CarrierLNI=<cfqueryparam value="#arguments.CarrierLNI#" cfsqltype="cf_sql_integer">
			</cfif>
			<cfif structkeyexists(arguments,"EDispatchOptions") and len(arguments.EDispatchOptions)>
				,EDispatchOptions=<cfqueryparam value="#arguments.EDispatchOptions#" cfsqltype="cf_sql_integer">
			</cfif>
			<cfif structkeyexists(arguments,"GPSUpdateInterval") and len(arguments.GPSUpdateInterval)>
				,GPSUpdateInterval=<cfqueryparam value="#arguments.GPSUpdateInterval#" cfsqltype="cf_sql_integer">
			</cfif>
			,editCreditLimit=<cfqueryparam value="#arguments.editCreditLimit#" cfsqltype="cf_sql_bit">
			,showScanButton=<cfqueryparam value="#arguments.showScanButton#" cfsqltype="cf_sql_bit">
			,EDIloadStatus=<cfqueryparam value="#arguments.EDIloadStatus#" cfsqltype="cf_sql_varchar">
			<cfif structkeyexists(arguments,"CustomerLNI") and len(arguments.CustomerLNI)>
				,CustomerLNI=<cfqueryparam value="#arguments.CustomerLNI#" cfsqltype="cf_sql_integer">
			</cfif>
			,ComDataUnitID=<cfqueryparam value="#arguments.ComDataUnitID#" cfsqltype="cf_sql_varchar">
			,ComDataCustomerID=<cfqueryparam value="#arguments.ComDataCustomerID#" cfsqltype="cf_sql_varchar">
			,autoAddCustViaDOT=<cfqueryparam value="#arguments.autoAddCustViaDOT#" cfsqltype="cf_sql_bit">
			,includeNumberofTripsInReports=<cfqueryparam value="#arguments.includeNumberofTripsInReports#" cfsqltype="cf_sql_bit">
			,forceUserToEnterTrip=<cfqueryparam value="#arguments.forceUserToEnterTrip#" cfsqltype="cf_sql_bit">
			,TIN=<cfqueryparam value="#arguments.TIN#" cfsqltype="cf_sql_varchar">
			,AutomaticFactoringFee=<cfqueryparam value="#arguments.AutomaticFactoringFee#" cfsqltype="cf_sql_bit">
			,FactoringFee=<cfqueryparam value="#arguments.FactoringFee#" cfsqltype="cf_sql_float">
			<cfif structKeyExists(arguments, "Edi210EsignReq")>
				,Edi210EsignReq = <cfqueryparam value="#val(arguments.Edi210EsignReq)#" cfsqltype="cf_sql_bit">
			</cfif>
			,CarrierRateConfirmation  = <cfqueryparam value="#arguments.carrierratecon#" cfsqltype="cf_sql_bit">
			,ShowLoadTypeStatusOnLoadsScreen=<cfqueryparam value="#arguments.ShowLoadTypeStatusOnLoadsScreen#" cfsqltype="cf_sql_bit">
			,UpdateCustomerFromLoadScreen=<cfqueryparam value="#arguments.UpdateCustomerFromLoadScreen#" cfsqltype="cf_sql_bit">
			,LoadsColumns=<cfqueryparam value="#arguments.LoadsColumns#" cfsqltype="cf_sql_varchar">
			,LoadsColumnsStatus=<cfqueryparam value="#arguments.LoadsColumnsStatus#" cfsqltype="cf_sql_varchar">
			,IsLoadStatusDefaultForReport = <cfqueryparam value="#arguments.IsLoadStatusDefaultForReport#" cfsqltype="cf_sql_bit">
			,AllowBooking = <cfqueryparam value="#allowBooking#" cfsqltype="cf_sql_bit">
			,ShowLoadStatusOnMobileApp=<cfqueryparam value="#arguments.ShowLoadStatusOnMobileApp#" cfsqltype="cf_sql_bit">
			,TurnOnConsolidatedInvoices=<cfqueryparam value="#arguments.TurnOnConsolidatedInvoices#" cfsqltype="cf_sql_bit">
			,MacropointId=<cfqueryparam value="#arguments.MacropointId#" cfsqltype="cf_sql_varchar">
			,MacropointApiLogin=<cfqueryparam value="#arguments.MacropointApiLogin#" cfsqltype="cf_sql_varchar">
			,MacropointApiPassword=<cfqueryparam value="#arguments.MacropointApiPassword#" cfsqltype="cf_sql_varchar">
			,MobileStopTrackingStatus=<cfqueryparam value="#arguments.MobileStopTrackingStatus#" cfsqltype="cf_sql_varchar">
			,Project44=<cfqueryparam value="#arguments.Project44#" cfsqltype="cf_sql_bit">
			,SendEmailNoticeMacroPoint=<cfqueryparam value="#arguments.SendEmailNoticeMacroPoint#" cfsqltype="cf_sql_bit">
			,EDispatchTextInstructions=<cfqueryparam value="#arguments.EDispatchTextInstructions#" cfsqltype="cf_sql_varchar">
			,EDispatchMailText=<cfqueryparam value="#arguments.EDispatchMailText#" cfsqltype="cf_sql_varchar">
			,BOLReportFormat=<cfqueryparam value="#arguments.BOLReportFormat#" cfsqltype="cf_sql_varchar">
			,EDispatchTextMessage=<cfqueryparam value="#arguments.EDispatchTextMessage#" cfsqltype="cf_sql_varchar">
			,QBDefBillAccountName=<cfqueryparam value="#arguments.QBDefBillAccountName#" cfsqltype="cf_sql_varchar">
			,QBDefInvItemName=<cfqueryparam value="#arguments.QBDefInvItemName#" cfsqltype="cf_sql_varchar">
			,QBDefInvPayTerm=<cfqueryparam value="#arguments.QBDefInvPayTerm#" cfsqltype="cf_sql_varchar">
			,QBDefBillPayTerm=<cfqueryparam value="#arguments.QBDefBillPayTerm#" cfsqltype="cf_sql_varchar">
			,TimeZone=<cfqueryparam value="#arguments.TimeZone#" cfsqltype="cf_sql_bit">
			,RateConPromptOption = <cfqueryparam value="#arguments.RateConPromptOption#" cfsqltype="cf_sql_integer">
			
			,CustomerCRMCallBackCircleColor=<cfqueryparam value="#arguments.CustomerCRMCallBackCircleColor#" cfsqltype="cf_sql_varchar">
			,CarrierCRMCallBackCircleColor=<cfqueryparam value="#arguments.CarrierCRMCallBackCircleColor#" cfsqltype="cf_sql_varchar">
			,DriverCRMCallBackCircleColor=<cfqueryparam value="#arguments.DriverCRMCallBackCircleColor#" cfsqltype="cf_sql_varchar">
			,ReqAddressWhenAddingCust=<cfqueryparam value="#arguments.ReqAddressWhenAddingCust#" cfsqltype="cf_sql_bit">
			,IncludeDhMilesInTotalMiles=<cfqueryparam value="#arguments.IncludeDhMilesInTotalMiles#" cfsqltype="cf_sql_bit">
			,DefaultCountry=<cfqueryparam value="#arguments.DefaultCountry#" cfsqltype="cf_sql_varchar">
			,UseNonFeeAccOnBOL=<cfqueryparam value="#arguments.UseNonFeeAccOnBOL#" cfsqltype="cf_sql_bit">
			,ShortBOLTerms=<cfqueryparam value="#ShortBOLTerms#" cfsqltype="cf_sql_varchar">
			<cfif trim(arguments.BackgroundColorAccounting)  NEQ "">
				,BackgroundColorAccounting=<cfqueryparam value="#arguments.BackgroundColorAccounting#" cfsqltype="cf_sql_varchar">
			</cfif>
			<cfif trim(arguments.BackgroundColorForContentAccounting)  NEQ "">
				,BackgroundColorForContentAccounting=<cfqueryparam value="#arguments.BackgroundColorForContentAccounting#" cfsqltype="cf_sql_varchar">
			</cfif>  
			,ShowCarrierNotesOnMobileApp=<cfqueryparam value="#arguments.ShowCarrierNotesOnMobileApp#" cfsqltype="cf_sql_bit">
			,CalculateDHOption=<cfqueryparam value="#arguments.CalculateDHOption#" cfsqltype="cf_sql_integer">
			,APExportStatusID = <cfqueryparam value="#arguments.APExportStatusID#" cfsqltype="cf_sql_varchar">
			,UseDirectCost=<cfqueryparam value="#arguments.UseDirectCost#" cfsqltype="cf_sql_bit">
			,RequireDeliveryDate=<cfqueryparam value="#arguments.RequireDeliveryDate#" cfsqltype="cf_sql_bit">
			,QBVersion = <cfqueryparam value="#arguments.QBVersion#" cfsqltype="cf_sql_integer">
			,CopyLoadDeliveryPickupDates=<cfqueryparam value="#arguments.CopyLoadDeliveryPickupDates#" cfsqltype="cf_sql_bit">
			,CopyLoadCarrier=<cfqueryparam value="#arguments.CopyLoadCarrier#" cfsqltype="cf_sql_bit">
			,ShowLoadCopyOptions=<cfqueryparam value="#arguments.ShowLoadCopyOptions#" cfsqltype="cf_sql_bit">
			,TemperatureSetting = <cfqueryparam value="#arguments.TemperatureSetting#" cfsqltype="cf_sql_integer">
			,EDispatchHead=<cfqueryparam value="#arguments.EDispatchHead#" cfsqltype="cf_sql_varchar">
			,ShowCustomerTermsOnInvoice = <cfqueryparam value="#arguments.ShowCustomerTermsOnInvoice#" cfsqltype="cf_sql_bit">
			,CarrierLoadStatusLaneSave=<cfqueryparam value="#arguments.CarrierLoadStatusLaneSave#" cfsqltype="cf_sql_varchar">
			<cfif structKeyExists(arguments, "QBCarrierInvoiceASRef")>
				,QBCarrierInvoiceASRef = <cfqueryparam value="#val(arguments.QBCarrierInvoiceASRef)#" cfsqltype="cf_sql_bit">
			</cfif>
			<cfif structKeyExists(arguments, "QBFactoringNameOnBill")>
				,QBFactoringNameOnBill = <cfqueryparam value="#val(arguments.QBFactoringNameOnBill)#" cfsqltype="cf_sql_bit">
			</cfif>
			,ConsolidateInvoiceStatusUpdate=<cfqueryparam value="#arguments.ConsolidateInvoiceStatusUpdate#" cfsqltype="cf_sql_varchar" null="#yesNoFormat(NOT len(arguments.ConsolidateInvoiceStatusUpdate))#">
			,ConsolidateInvoiceDateUpdate=<cfqueryparam value="#arguments.ConsolidateInvoiceDateUpdate#" cfsqltype="cf_sql_bit">
			,ConsolidateInvoiceTriggerStatus=<cfqueryparam value="#arguments.ConsolidateInvoiceTriggerStatus#" cfsqltype="cf_sql_varchar" null="#yesNoFormat(NOT len(arguments.ConsolidateInvoiceTriggerStatus))#">
			,ExcludeTemplateLoadNumber=<cfqueryparam value="#arguments.ExcludeTemplateLoadNumber#" cfsqltype="cf_sql_bit">
			<cfif len(arguments.GPSDistanceInterval) AND isNumeric(arguments.GPSDistanceInterval)>
				,GPSDistanceInterval=<cfqueryparam value="#arguments.GPSDistanceInterval#" cfsqltype="cf_sql_float">
			<cfelse>
				,GPSDistanceInterval=0
			</cfif>
			,DefaultLoadEmails=<cfqueryparam value="#arguments.DefaultLoadEmails#" cfsqltype="cf_sql_varchar" null="#yesNoFormat(NOT len(arguments.DefaultLoadEmails))#">
			,DefaultLoadEmailtext=<cfqueryparam value="#arguments.DefaultLoadEmailtext#" cfsqltype="cf_sql_varchar" null="#yesNoFormat(NOT len(arguments.DefaultLoadEmailtext))#">
			,DefaultLoadEmailSubject=<cfqueryparam value="#arguments.DefaultLoadEmailSubject#" cfsqltype="cf_sql_varchar" null="#yesNoFormat(NOT len(arguments.DefaultLoadEmailSubject))#">
			,DefaultLaneAlertEmailtext=<cfqueryparam value="#arguments.DefaultLaneAlertEmailtext#" cfsqltype="cf_sql_varchar" null="#yesNoFormat(NOT len(arguments.DefaultLaneAlertEmailtext))#">
			,DefaultLaneAlertEmailSubject=<cfqueryparam value="#arguments.DefaultLaneAlertEmailSubject#" cfsqltype="cf_sql_varchar" null="#yesNoFormat(NOT len(arguments.DefaultLaneAlertEmailSubject))#">
			,DashboardUser=<cfqueryparam value="#arguments.DashboardUser#" cfsqltype="cf_sql_varchar" null="#yesNoFormat(NOT len(arguments.DashboardUser))#">
			,DashboardPassword=<cfqueryparam value="#arguments.DashboardPassword#" cfsqltype="cf_sql_varchar" null="#yesNoFormat(NOT len(arguments.DashboardPassword))#">
			,ShowDashboard=<cfqueryparam value="#arguments.ShowDashboard#" cfsqltype="cf_sql_integer">
			,AutoSendEMailUpdates=<cfqueryparam value="#arguments.AutoSendEMailUpdates#" cfsqltype="cf_sql_bit">
			,MinMarginOverrideApproval=<cfqueryparam value="#arguments.MinMarginOverrideApproval#" cfsqltype="cf_sql_bit">
			,QBFactoringNameOnInvoice=<cfqueryparam value="#arguments.QBFactoringNameOnInvoice#" cfsqltype="cf_sql_bit">
			,useBetaVersion=<cfqueryparam value="#arguments.useBetaVersion#" cfsqltype="cf_sql_bit">
			,UseCondensedReports=<cfqueryparam value="#arguments.UseCondensedReports#" cfsqltype="cf_sql_bit">
			,IncludeCarrierRate=<cfqueryparam value="#arguments.IncludeCarrierRate#" cfsqltype="cf_sql_bit">
			,BillFromCompanies=<cfqueryparam value="#arguments.BillFromCompanies#" cfsqltype="cf_sql_bit">
			,GeoFenceRadius=<cfqueryparam value="#arguments.GeoFenceRadius#" cfsqltype="cf_sql_float">
			,ApplyBillFromCompanyToCarrierReport=<cfqueryparam value="#arguments.ApplyBillFromCompanyToCarrierReport#" cfsqltype="cf_sql_bit">
			,ShowAllOfficeCustomers=<cfqueryparam value="#arguments.ShowAllOfficeCustomers#" cfsqltype="cf_sql_bit">
			,CustomerPaymentTerms=<cfqueryparam value="#arguments.CustomerPaymentTerms#" cfsqltype="cf_sql_varchar" null="#yesNoFormat(NOT len(arguments.CustomerPaymentTerms))#">
			,CustomerInvoiceformat  = <cfqueryparam value="#arguments.CustomerInvoiceformat#" cfsqltype="cf_sql_integer">
			,AutomaticCustomerRateChanges=<cfqueryparam value="#arguments.AutomaticCustomerRateChanges#" cfsqltype="cf_sql_bit">
			,AutomaticCarrierRateChanges=<cfqueryparam value="#arguments.AutomaticCarrierRateChanges#" cfsqltype="cf_sql_bit">
			,ShowMaxCarrRateInLoadScreen=<cfqueryparam value="#arguments.ShowMaxCarrRateInLoadScreen#" cfsqltype="cf_sql_bit">
			,NonCommissionable=<cfqueryparam value="#arguments.NonCommissionable#" cfsqltype="cf_sql_bit">
			WHERE CompanyID = <cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar">
			SELECT @@ROWCOUNT as updatedRows
			SET NOCOUNT OFF
		</cfquery>
		<cfquery name="qUpdOnboardingSettings" datasource="#Application.dsn#">
			UPDATE SystemConfigOnboardCarrier
			SET DefaultOnboardingEmailSubject=<cfqueryparam value="#arguments.DefaultOnboardingEmailSubject#" cfsqltype="cf_sql_varchar">
			,DefaultOnboardingEmailCC=<cfqueryparam value="#arguments.DefaultOnboardingEmailCC#" cfsqltype="cf_sql_varchar" null="#yesNoFormat(NOT len(arguments.DefaultOnboardingEmailCC))#">
			,DefaultOnboardingEmailtext=<cfqueryparam value="#arguments.DefaultOnboardingEmailtext#">
			WHERE CompanyID = <cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar">
		</cfquery>
		<cfreturn qrySetSystemSetupOptions.updatedRows>
	</cffunction>

	<cffunction name="getCompanyName" access="remote" returntype="query">
		<cfargument name="dsn" type="any" required="no"/>
	    <cfif isdefined('dsn')>
	    	<cfset companyName=dsn>
	    <cfelse>
	    	<cfset companyName=variables.dsn>
	    </cfif>
		<cfquery name="qCompanyName" datasource="#companyName#">
		    SELECT CompanyName,CompanyCode
			FROM Companies
			WHERE CompanyID = <cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar">
	    </cfquery>
	    <cfreturn qCompanyName>
	</cffunction>

	<cffunction name="getSystemSetupOptions" access="remote" returntype="query">
		<cfargument name="dsn" type="any" required="no"/>
		<cfargument name="CompanyID" type="any" required="no" default=""/>
	    <cfif isdefined('dsn')>
	    	<cfset activedns = dsn>
	    <cfelse>
	    	<cfset activedns = variables.dsn>
	    </cfif>

	    <cfif structKeyExists(arguments, "CompanyID") AND Len(Trim(arguments.CompanyID))>
	    	<cfset CompanyID = arguments.CompanyID>
	    <cfelse>
	    	<cfset CompanyID = session.CompanyID>
	    </cfif>
		<cfquery name="qSystemSetupOptions" datasource="#activedns#">
	    	SELECT ARAndAPExportStatusID, showExpiredInsuranceCarriers, companyName, companyLogoName,DispatchNotes, CarrierNotes, Notes, requireValidMCNumber,PEPsecretKey,PEPcustomerKey,CarrierTerms,TRIGER_LOADSTATUS,AllowLoadentry,showReadyArriveDate,ITSUserName, ITSPassword, userDef1, userDef2, userDef3, userDef4, userDef5, userDef6, userDef7, googleMapsPcMiler, minimumMargin, CarrierHead, CustInvHead, BOLHead, WorkImpHead, WorkExpHead, SalesHead, MinimumLoadStartNumber,StatusDispatchNotes,AutomaticEmailReports,AutomaticPrintReports, emailtype, FreightBroker, CustomerTerms,loadNumberAssignment,commodityWeight,MinimumLoadInvoiceNumber,ShowCarrierInvoiceNumberInAllLoads,rolloverShipDateStatus,showcarrieramount,showcustomeramount,rowsperpage,lockloadstatus,EditDispatchNotes,showCarrierInvoiceNumber,SaferWatch,SaferWatchWebKey,SaferWatchCustomerKey,BackgroundColor,BackgroundColorForContent,DropBox,DropBoxAccessToken,CopyLoadLimit ,CopyLoadIncludeAgentAndDispatcher,LoadNumberAutoIncrement,StartingActiveLoadNumber,AllowDuplicateVendorCode,CarrierLoadLimit,TextAPI,IsLoadLogEnabled,LoadLogLimit,ForeignCurrencyEnabled,DefaultSystemCurrency,PCMilerAPIKey,numberOfCarrierInEmail,IsIncludeLoadNumber, ActivateBulkAndLoadNotificationEmail, IsConcatCarrierDriverIdentifier, GetFMCSAFrom, IsEDispatchSmartPhone, IsLockOrderDate, ShowMiles, ShowDeadHeadMiles
			<!--- #837: Carrier screen add new field Dispatch Fee:  --->
			, Dispatch, MyCarrierPackets, MyCarrierPacketsUsername, MyCarrierPacketsPassword ,CarrierLNI ,editCreditLimit,showScanButton,EDIloadStatus,CustomerLNI,ComDataUnitID,ComDataCustomerID,autoAddCustViaDOT,includeNumberofTripsInReports,forceUserToEnterTrip,TIN,AutomaticFactoringFee,FactoringFee,Edi210EsignReq,CarrierRateConfirmation,ShowLoadTypeStatusOnLoadsScreen,UpdateCustomerFromLoadScreen,LoadsColumns,LoadsColumnsStatus,IsLoadStatusDefaultForReport,EDispatchOptions,AllowBooking,GPSUpdateInterval,ShowLoadStatusOnMobileApp,TurnOnConsolidatedInvoices,MacropointId,MacropointApiLogin,MacropointApiPassword,MobileStopTrackingStatus,Project44,SendEmailNoticeMacroPoint,EDispatchTextInstructions,EDispatchMailText,GoogleAddressLookup,BOLReportFormat,EDispatchTextMessage,QBDefBillAccountName, QBDefInvItemName, QBDefInvPayTerm, QBDefBillPayTerm, TimeZone, RateConPromptOption, UseNonFeeAccOnBOL,CustomerCRMCallBackCircleColor,CarrierCRMCallBackCircleColor,DriverCRMCallBackCircleColor,ReqAddressWhenAddingCust,DefaultCountry,ShortBOLTerms,BackgroundColorAccounting,BackgroundColorForContentAccounting,ShowCarrierNotesOnMobileApp,CarrierLookoutAPIKey,IncludeDhMilesInTotalMiles,CalculateDHOption,APExportStatusID,UseDirectCost,QBInvoiceStatusUpdateTo,QBBillStatusUpdateTo,QBVersion,CopyLoadDeliveryPickupDates,CopyLoadCarrier,ShowLoadCopyOptions,TemperatureSetting,EDispatchHead,ShowCustomerTermsOnInvoice,CarrierLoadStatusLaneSave,QBCarrierInvoiceASRef,ConsolidateInvoiceStatusUpdate,ConsolidateInvoiceDateUpdate,ConsolidateInvoiceTriggerStatus,ExcludeTemplateLoadNumber,GPSDistanceInterval,QBFactoringNameOnBill,UserAccountStatusUpdate,DefaultLoadEmails, DefaultLoadEmailtext,StatusUpdateEmailOption,DefaultLaneAlertEmailtext,DefaultLoadEmailSubject,DefaultLaneAlertEmailSubject,DashboardUser,ShowDashboard,AutoSendEMailUpdates,MinMarginOverrideApproval,OnboardCarrier,QBFactoringNameOnInvoice,DashboardPassword,DefaultOnboardingEmailCC,DefaultOnboardingEmailSubject,DefaultOnboardingEmailtext,GeoFenceRadius,useBetaVersion,BillFromCompanies,ApplyBillFromCompanyToCarrierReport,IncludeCarrierRate,StatusUpdateMailType,LowVolumePlan,MobileAppSwitchConfirmation,ShowAllOfficeCustomers,UseCondensedReports,CustomerPaymentTerms,RequireDeliveryDate,CustomerInvoiceformat,AutomaticCustomerRateChanges,AutomaticCarrierRateChanges,DefaultBillFromAsCompany,KeepCarrierInactive,ShowMaxCarrRateInLoadScreen,NonCommissionable
	        FROM SystemConfig
	        LEFT JOIN SystemConfigOnboardCarrier ON SystemConfig.CompanyID = SystemConfigOnboardCarrier.CompanyID
	        WHERE SystemConfig.CompanyID = <cfqueryparam value="#companyID#" cfsqltype="cf_sql_varchar">
	    </cfquery>
	    <cfreturn qSystemSetupOptions>
	</cffunction>
	<!--------get load add /edit system option---->
	<cffunction name="getLoadSystemSetupOptions" access="remote" returntype="query">
		<cfargument name="dsn" type="any" required="no"/>
	    <cfif isdefined('dsn')>
	    	<cfset activedns = dsn>
	    <cfelse>
	    	<cfset activedns = variables.dsn>
	    </cfif>

		<cfquery name="qSystemSetupOptions" datasource="#activedns#" timeout="120">
	    	SELECT companyLogoName,companyName,freightBroker,rolloverShipDateStatus,userDef7,showcarrieramount,showcustomeramount,rowsperpage,lockloadstatus,EditDispatchNotes,showCarrierInvoiceNumber,BackgroundColor,BackgroundColorForContent,LoadsColumnsSetting,CopyLoadLimit ,CopyLoadIncludeAgentAndDispatcher,LoadNumberAutoIncrement,StartingActiveLoadNumber,ShowCarrierInvoiceNumberInAllLoads, ForeignCurrencyEnabled, ActivateBulkAndLoadNotificationEmail, ShowMiles, ShowDeadHeadMiles,editCreditLimit,EDIloadStatus,LoadsColumnsStatus,LoadsColumns,autoAddCustViaDOT,Project44,GoogleAddressLookup,TimeZone,RateConPromptOption,CustomerCRMCallBackCircleColor,CarrierCRMCallBackCircleColor,DriverCRMCallBackCircleColor,ReqAddressWhenAddingCust,DefaultCountry,BackgroundColorAccounting,BackgroundColorForContentAccounting,IncludeDhMilesInTotalMiles,CalculateDHOption,UseDirectCost,CopyLoadDeliveryPickupDates,CopyLoadCarrier,ShowLoadCopyOptions,TemperatureSetting,ConsolidateInvoiceTriggerStatus,AIImportStatusID,ShowDashboard,ARAndAPExportStatusID,IsLoadStatusDefaultForReport,UseCondensedReports,QuickBooksIntegration,AccountingIntegration
	        FROM SystemConfig 
	        <cfif structkeyexists(session,"companyID")>
	       		WHERE CompanyID = <cfqueryparam value="#session.companyID#" cfsqltype="cf_sql_varchar">
	        <cfelse>
	        	WHERE CompanyID = <cfqueryparam value="" cfsqltype="cf_sql_varchar" null="yes">
	        </cfif>
	    </cfquery>
	    <cfreturn qSystemSetupOptions>
	</cffunction>
	<!--- Get Long and Short Miles --->
	<cffunction name="addQuickCalcInfoToLog" access="remote" returntype="void">
		<cfargument name="dsn" type="string" required="yes"/>
		<cfargument name="consigneeAddress" type="string" required="yes"/>
		<cfargument name="shipperAddress" type="string" required="yes"/>
		<cfargument name="custRatePerMile" type="numeric" required="yes"/>
		<cfargument name="carRatePerMile" type="numeric" required="yes"/>
		<cfargument name="custMiles" type="numeric" required="yes"/>
		<cfargument name="carMiles" type="numeric" required="yes"/>
		<cfargument name="customerAmount" type="numeric" required="yes"/>
		<cfargument name="carrierAmount" type="numeric" required="yes"/>
		<cfargument name="companyName" type="string" required="yes"/>
		<cfargument name="userName" type="string" required="yes"/>

		<cfquery name="qrySetQuickMilesAndRateCalcInfo" datasource="#arguments.dsn#" result="qResult">
			INSERT INTO quickMilesAndRateCalcLog(ConsigneeAddress,ShipperAddress,CustomerRatePerMile,CarrierRatePerMile,customerMiles,carrierMiles,CustomerAmount,CarrierAmount,companyName,DateTime,userName,IP)
			VALUES(
		    <cfqueryparam value="#arguments.consigneeAddress#" cfsqltype="cf_sql_varchar">,
		    <cfqueryparam value="#arguments.shipperAddress#" cfsqltype="cf_sql_varchar">,
		    <cfqueryparam value="#arguments.custRatePerMile#" cfsqltype="cf_sql_float">,
		    <cfqueryparam value="#arguments.carRatePerMile#" cfsqltype="cf_sql_float">,
		    <cfqueryparam value="#arguments.custMiles#" cfsqltype="cf_sql_float">,
		    <cfqueryparam value="#arguments.carMiles#" cfsqltype="cf_sql_float">,
		    <cfqueryparam value="#arguments.customerAmount#" cfsqltype="cf_sql_float">,
		    <cfqueryparam value="#arguments.carrierAmount#" cfsqltype="cf_sql_float">,
		    <cfqueryparam value="#arguments.companyName#" cfsqltype="cf_sql_varchar">,
		    <cfqueryparam cfsqltype="cf_sql_timestamp" value="#Now()#">,
		    <cfqueryparam value="#arguments.userName#" cfsqltype="cf_sql_varchar">,
		    <cfqueryparam value="#cgi.REMOTE_ADDR#" cfsqltype="cf_sql_varchar">)
		</cfquery>
	</cffunction>



	<cffunction name="getAjaxCarrierlistNext" access="remote" returntype="string">
		<cfargument name="dsn" type="string" required="yes" />
		<cfargument name="filterChar" required="No" type="any">
		<cfargument name="stopNo" required="yes" type="any">
		<!--- call SP to Get a carrier Info--->
		<CFSTOREDPROC PROCEDURE="USP_GetCarrierListByFilterChar" DATASOURCE="#arguments.dsn#">
			<cfif isdefined('arguments.filterChar') and len(arguments.filterChar)>
			 	<CFPROCPARAM VALUE="#arguments.filterChar#" cfsqltype="CF_SQL_VARCHAR">
			 <cfelse>
			 	<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR">
			 </cfif>
			 <CFPROCRESULT NAME="qrygetFilterCarrier">
		</CFSTOREDPROC>

		<cfsavecontent variable="filteredCarrierList">
			<cfoutput>
				<select size="10" name="filterList" class="carrier-select" style="height:162px" onchange="DisplayIntextFieldNext(this.value,this.options[this.selectedIndex].text,#arguments.stopNo#,'#arguments.dsn#');">
					<cfloop query="qrygetFilterCarrier">
						<option value="#qrygetFilterCarrier.value#">
							#ucase(arguments.filterChar)# & #qrygetFilterCarrier.TEXT# &nbsp;&nbsp;&nbsp;#qrygetFilterCarrier.city#&nbsp;#qrygetFilterCarrier.statecode#&nbsp;&nbsp;&nbsp;&nbsp;#qrygetFilterCarrier.phone#&nbsp;&nbsp;&nbsp;&nbsp;#qrygetFilterCarrier.status#
						</option>
					</cfloop>
				</select>
			</cfoutput>
		</cfsavecontent>
		<cfreturn filteredCarrierList>
	</cffunction>

	<!--- Get carrier Info Form--->
	<cffunction name="getAjaxCarrierInfoForm" access="remote" returntype="string">
		<cfargument name="dsn" type="string" required="yes" />
		<cfargument name="carrierId" required="No" type="any">
		<cfargument name="urlToken" required="no" type="any">
		<!--- call SP to Get a carrier Info--->
		<CFSTOREDPROC PROCEDURE="USP_GetCarrierDetails" DATASOURCE="#arguments.dsn#">
			<cfif isdefined('arguments.carrierId') and len(arguments.carrierId)>
			 	<CFPROCPARAM VALUE="#arguments.carrierId#" cfsqltype="CF_SQL_VARCHAR">
			 <cfelse>
			 	<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR">
			 </cfif>
			 <CFPROCPARAM VALUE="#session.CompanyID#" cfsqltype="CF_SQL_VARCHAR">
			 <CFPROCRESULT NAME="qrygetCarrierDetails">
		</CFSTOREDPROC>

		<cfsavecontent variable="CarrierInfoForm">
			<cfoutput>
				<div class="clear"></div>
				<div class="clear"></div>
				<label>&nbsp;</label>
				<label class="field-textarea"><b><a href="index.cfm?event=addcarrier&carrierid=#qrygetCarrierDetails.carrierID#&iscarrier=#qrygetCarrierDetails.iscarrier#&#arguments.urlToken#" style="color:##4322cc;text-decoration:underline;">#qrygetCarrierDetails.CarrierName#</a></b><br/>#qrygetCarrierDetails.Address#<br/>#qrygetCarrierDetails.City#<br/>#qrygetCarrierDetails.stateCode#&nbsp;-&nbsp;#qrygetCarrierDetails.ZipCode#</label>
				<div class="clear"></div>
				<label>Tel</label>
				<label class="field-text">#qrygetCarrierDetails.phone#</label>
				<div class="clear"></div>
				<label>Cell</label>
				<label class="field-text">#qrygetCarrierDetails.cel#</label>
				<div class="clear"></div>
				<label>Fax</label>
				<label class="field-text">#qrygetCarrierDetails.fax#</label>
				<div class="clear"></div>
				<label>Email</label>
				<label class="emailbox">#qrygetCarrierDetails.emailID#</label>
			</cfoutput>
		</cfsavecontent>
		<cfreturn CarrierInfoForm>
	</cffunction>

	<!--- Get carrier Info Form--->
	<cffunction name="getCarrierInfoForm" access="public" returntype="string">
		<cfargument name="carrierId" required="No" type="any">
		<cfargument name="urlToken" required="no" type="any">
		<cfargument name="loadid" required="no" type="any" default="">
		<cfargument name="id" required="no" type="any" default="">
		<cfargument name="stopno" required="no" type="any" default="1">
		 <cfset var qSystemSetupOptions = "">
		<cfset risk_assessment = "">
		<!--- call SP to Get a carrier Info--->
		<CFSTOREDPROC PROCEDURE="USP_GetCarrierDetails" DATASOURCE="#variables.dsn#">
			<cfif isdefined('arguments.carrierId') and len(arguments.carrierId)>
			 	<CFPROCPARAM VALUE="#arguments.carrierId#" cfsqltype="CF_SQL_VARCHAR">
			 <cfelse>
			 	<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR">
			 </cfif>
			 <CFPROCPARAM VALUE="#session.CompanyID#" cfsqltype="CF_SQL_VARCHAR">
			 <CFPROCRESULT NAME="qrygetCarrierDetails">
		</CFSTOREDPROC>
		<cfset var CarrierEmailID = qrygetCarrierDetails.EmailID>
		<cfset var CarrierContactID = qrygetCarrierDetails.CarrierID>
		<cfset var CarrierPhoneNo = qrygetCarrierDetails.Phone>
		<cfset var CarrierPhoneNoExt = qrygetCarrierDetails.PhoneExt>
		<cfset var CarrierFax = qrygetCarrierDetails.Fax>
		<cfset var CarrierFaxExt = qrygetCarrierDetails.FaxExt>
		<cfset var CarrierTollFree = qrygetCarrierDetails.TollFree>
		<cfset var CarrierTollFreeExt = qrygetCarrierDetails.TollFreeExt>
		<cfset var CarrierCell = qrygetCarrierDetails.Cel>
		<cfset var CarrierCellExt = qrygetCarrierDetails.CellPhoneExt>
		<cfset var ContactPerson = qrygetCarrierDetails.ContactPerson>

		<cfif structkeyexists(arguments,"loadid") and len(trim(arguments.loadid))>
			<cfset index = "">
			<cfif len(trim(arguments.id))>
				<cfset index = listToArray(arguments.id,"_")[1]>
			</cfif>
			<cfset stn = arguments.stopNo - 1>
			<cfquery name="qGetCarrierDetails" datasource="#Application.dsn#">
				SELECT 
				LoadStops.CarrierEmailID#index# AS CarrierEmailID,
				LoadStops.CarrierContactID#index# AS CarrierContactID,
				LoadStops.CarrierPhoneNo#index# AS CarrierPhoneNo,
				LoadStops.CarrierPhoneNoExt#index# AS CarrierPhoneNoExt,
				LoadStops.CarrierFax#index# AS CarrierFax,
				LoadStops.CarrierFaxExt#index# AS CarrierFaxExt,
				LoadStops.CarrierTollFree#index# AS CarrierTollFree,
				LoadStops.CarrierTollFreeExt#index# AS CarrierTollFreeExt,
				LoadStops.CarrierCell#index# AS CarrierCell,
				LoadStops.CarrierCellExt#index# AS CarrierCellExt,
				CASE WHEN LoadStops.CarrierContactID#index# = Carriers.CarrierID THEN Carriers.ContactPerson ELSE CarrierContacts.ContactPerson END AS ContactPerson 
				FROM LoadStops
				LEFT JOIN CarrierContacts ON CarrierContacts.CarrierContactID = LoadStops.CarrierContactID#index#
				LEFT JOIN Carriers ON Carriers.CarrierID = LoadStops.CarrierContactID#index#
				WHERE LoadID = <cfqueryparam value="#arguments.loadid#" cfsqltype="CF_SQL_VARCHAR"> and stopNo = <cfqueryparam value="#stn#" cfsqltype="CF_SQL_INTEGER">
			</cfquery>
			<cfif len(trim(qGetCarrierDetails.CarrierEmailID))>
				<cfset CarrierEmailID = qGetCarrierDetails.CarrierEmailID>
			</cfif>
			<cfif len(trim(qGetCarrierDetails.CarrierContactID))>
				<cfset CarrierContactID = qGetCarrierDetails.CarrierContactID>
			</cfif>
			<cfif len(trim(qGetCarrierDetails.CarrierPhoneNo))>
				<cfset CarrierPhoneNo = qGetCarrierDetails.CarrierPhoneNo>
			</cfif>
			<cfif len(trim(qGetCarrierDetails.CarrierPhoneNoExt))>
				<cfset CarrierPhoneNoExt = qGetCarrierDetails.CarrierPhoneNoExt>
			</cfif>
			<cfif len(trim(qGetCarrierDetails.CarrierFax))>
				<cfset CarrierFax = qGetCarrierDetails.CarrierFax>
			</cfif>
			<cfif len(trim(qGetCarrierDetails.CarrierFaxExt))>
				<cfset CarrierFaxExt = qGetCarrierDetails.CarrierFaxExt>
			</cfif>
			<cfif len(trim(qGetCarrierDetails.CarrierTollFree))>
				<cfset CarrierTollFree = qGetCarrierDetails.CarrierTollFree>
			</cfif>
			<cfif len(trim(qGetCarrierDetails.CarrierTollFreeExt))>
				<cfset CarrierTollFreeExt = qGetCarrierDetails.CarrierTollFreeExt>
			</cfif>
			<cfif len(trim(qGetCarrierDetails.CarrierCell))>
				<cfset CarrierCell = qGetCarrierDetails.CarrierCell>
			</cfif>
			<cfif len(trim(qGetCarrierDetails.CarrierCellExt))>
				<cfset CarrierCellExt = qGetCarrierDetails.CarrierCellExt>
			</cfif>
			<cfif len(trim(qGetCarrierDetails.ContactPerson))>
				<cfset ContactPerson = qGetCarrierDetails.ContactPerson>
			</cfif>
		</cfif>

		<cfquery name="qSystemSetupOptions"  datasource="#Application.dsn#">
				SELECT SaferWatch,SaferWatchWebKey,SaferWatchCustomerKey,FreightBroker,CarrierLNI
				FROM SystemConfig
				 <cfif structKeyExists(session, "companyid")>
                  where companyid = <cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar">
                 </cfif>
		</cfquery>
		<cfif qSystemSetupOptions.SaferWatch EQ 1  AND  qSystemSetupOptions.FreightBroker EQ 1 >
				<cfif qrygetCarrierDetails.MCNumber NEQ "">
					<cfset number = "MC"&qrygetCarrierDetails.MCNumber >
				<cfelseif  qrygetCarrierDetails.DOTNumber NEQ "" >
					<cfset number = qrygetCarrierDetails.DOTNumber>
				<cfelse>
					<cfset number = 0 >
				</cfif>
				<cfhttp url="http://www.saferwatch.com/webservices/CarrierService32.php?Action=CarrierLookup&ServiceKey=#qSystemSetupOptions.SaferWatchWebKey#&CustomerKey=#qSystemSetupOptions.SaferWatchCustomerKey#&number=#variables.number#" method="get" timeout="60">
				</cfhttp>
				<cfif cfhttp.Statuscode EQ '200 OK' AND trim(cfhttp.Filecontent) NEQ 'Connection Timeout' AND isxml(cfhttp.Filecontent)>
					<cfset variables.resStruct = ConvertXmlToStruct(cfhttp.Filecontent, StructNew())>
					<cfif structKeyExists(variables.resStruct ,"CarrierDetails") AND structKeyExists(variables.resStruct .CarrierDetails,"RiskAssessment") AND structKeyExists(variables.resStruct .CarrierDetails.RiskAssessment,"Overall")  >
						<cfset risk_assessment = variables.resStruct .CarrierDetails.RiskAssessment.Overall>
					</cfif>
				<cfelse>
					<cfset risk_assessment = "">
				</cfif>
			</cfif>
			<cfif qSystemSetupOptions.FreightBroker EQ 1 OR (qSystemSetupOptions.FreightBroker EQ 2 AND qrygetCarrierDetails.iscarrier EQ 1)>
				<cfset editEvent ="addcarrier">
			<cfelse>
				<cfset editEvent ="adddriver">
			</cfif>
		<cfsavecontent variable="CarrierInfoForm">
			<cfoutput>
				<div class="clear"></div>
				<input name="carrierID#arguments.id#" id="carrierID#arguments.id#" type="hidden" value="#qrygetCarrierDetails.carrierID#" />
				<input name="carrierDefaultCurrency" id="carrierDefaultCurrency" type="hidden" value="#qrygetCarrierDetails.DefaultCurrency#" />
				<input name="CalculateDHMiles#arguments.id#" id="CalculateDHMiles#arguments.id#" type="hidden" value="#qrygetCarrierDetails.CalculateDHMiles#" />
				<div class="clear"></div>
				<label>
					<cfif  qSystemSetupOptions.SaferWatch EQ 1  AND  qSystemSetupOptions.FreightBroker EQ 1 AND  qSystemSetupOptions.CarrierLNI NEQ 2>
						<a href="http://www.saferwatch.com/swCarrierDetailsLink.php?&number=#number#" target="_blank">
							<cfif risk_assessment EQ "Unacceptable">
								<img style="vertical-align:bottom;" src="images/SW-Red.png">
							<cfelseif risk_assessment EQ "Moderate">
								<img style="vertical-align:bottom;" src="images/SW-Yellow.png">
							<cfelseif risk_assessment EQ "Acceptable">
								<img style="vertical-align:bottom;" src="images/SW-Green.png">
							<cfelse>
								<img style="vertical-align:bottom;" src="images/SW-Blank.png">
							</cfif>
						</a>
					<cfelseif qSystemSetupOptions.CarrierLNI EQ 2>
						<a href="" target="_blank">
							<cfset risk_assessment = qrygetCarrierDetails.RiskAssessment>
							<cfif risk_assessment EQ "Unacceptable">
								<img style="vertical-align:bottom;" src="images/CL-Red.png">
								<cfset risk_assessment = "images/CL-Red.png" >
							<cfelseif risk_assessment EQ "Moderate">
								<img style="vertical-align:bottom;" src="images/CL-Yellow.png">
							<cfelseif risk_assessment EQ "Acceptable">
								<img style="vertical-align:bottom;" src="images/CL-Green.png">
							<cfelse>
								<img style="vertical-align:bottom;opacity: 0;" src="images/CL-Blank.png">
							</cfif>
						</a>
					<cfelse>
						&nbsp;
					</cfif>
				</label>
				<label class="field-textarea carrier-field-textarea"><b>
				<a href="index.cfm?event=#editEvent#&carrierid=#qrygetCarrierDetails.carrierID#&iscarrier=#qrygetCarrierDetails.iscarrier#&#arguments.urlToken#" style="color:##4322cc;text-decoration:underline;">#qrygetCarrierDetails.CarrierName#</a></b><br/>#qrygetCarrierDetails.Address#<br/>#qrygetCarrierDetails.City#,&nbsp;#qrygetCarrierDetails.stateCode#&nbsp;#qrygetCarrierDetails.ZipCode#<br/><br/><a class='underline'>MC##:</a>#qrygetCarrierDetails.MCNumber#&nbsp;&nbsp;<a class='underline'>DOT##:</a>#qrygetCarrierDetails.DOTNumber#&nbsp;&nbsp;<a class='underline'>SCAC##:</a>#qrygetCarrierDetails.SCAC#&nbsp;&nbsp;</label>
				<div class="clear"></div>

				<label>Contact</label>
				<input class='CarrierContactAuto' data-carrID="#qrygetCarrierDetails.carrierID#" value="#ContactPerson#" placeholder='type text here to display list'>
				<input type='hidden' name='CarrierContactID#arguments.id#' id='CarrierContactID#arguments.id#' value='#CarrierContactID#'>
				<input style='width: 20px !important;height: 18px;padding: 0;' type='button' value='...'' onclick='openViewCarrierContactPopup(this)'>
				<div class="clear"></div>
				<label>Email</label>
				<input name="CarrierEmailID#arguments.id#" id="CarrierEmailID#arguments.id#" data-carrID="#qrygetCarrierDetails.carrierID#" class="emailbox CarrEmail" value="#CarrierEmailID#">
				<div class="clear"></div>
				<label>Phone</label>
				<input type="text" name="CarrierPhoneNo#arguments.id#" id="CarrierPhoneNo#arguments.id#" value="#CarrierPhoneNo#" class="inp70px" onchange="ParseUSNumber(this);">
				<input type="text" name="CarrierPhoneNoExt#arguments.id#" id="CarrierPhoneNoExt#arguments.id#" value="#CarrierPhoneNoExt#" class="inp18px">
				<label class="label45px">Fax</label>
				<input type="text" name="CarrierFax#arguments.id#" value="#CarrierFax#" class="inp70px" onchange="ParseUSNumber(this);">
				<input type="text" name="CarrierFaxExt#arguments.id#" id="CarrierFaxExt#arguments.id#" value="#CarrierFaxExt#" class="inp18px">
				<div class="clear"></div>
				<label>Toll Free</label>
				<input type="text" name="CarrierTollFree#arguments.id#" id="CarrierTollFree#arguments.id#" value="#CarrierTollFree#" class="inp70px" onchange="ParseUSNumber(this);">
				<input type="text" name="CarrierTollFreeExt#arguments.id#" id="CarrierTollFreeExt#arguments.id#" value="#CarrierTollFreeExt#" class="inp18px">
				<label class="label45px">Cell</label>
				<input type="text" name="CarrierCell#arguments.id#" id="CarrierCell#arguments.id#" value="#CarrierCell#" class="inp70px" onchange="ParseUSNumber(this);">
				<input type="text" name="CarrierCellExt#arguments.id#" id="CarrierCellExt#arguments.id#" value="#CarrierCellExt#" class="inp18px">
				<cfif len(trim(qrygetCarrierDetails.RemitName))>
					<div class='clear'></div>
					<label style="width: 102px !important;">Factoring Co.</label>
					<label class="field-text disabledLoadInputs" style="width:273px !important">#qrygetCarrierDetails.RemitName#</label>
				</cfif>
			</cfoutput>
		</cfsavecontent>
		<cfreturn CarrierInfoForm>
	</cffunction>

	<!--- Get carrier Info Form for Next Stop--->
	<cffunction name="getAjaxCarrierInfoFormNext" access="remote" output="yes" returnformat="json">
		<cfargument name="dsn" type="string" required="yes" />
		<cfargument name="carrierId" required="No" type="any">
		<cfargument name="stopNo" required="No" type="any">
		<cfargument name="urltoken" required="no" type="any">
		<cfargument name="loadid" required="no" type="any" default="">
		<cfargument name="CompanyID" required="no" type="any" default="">

		<!--- call SP to Get a carrier Info--->
		<CFSTOREDPROC PROCEDURE="USP_GetCarrierDetails" DATASOURCE="#arguments.dsn#">
			<cfif isdefined('arguments.carrierId') and len(arguments.carrierId)>
			 	<CFPROCPARAM VALUE="#arguments.carrierId#" cfsqltype="CF_SQL_VARCHAR">
			 <cfelse>
			 	<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR">
			 </cfif>
			 <CFPROCPARAM VALUE="#arguments.CompanyID#" cfsqltype="CF_SQL_VARCHAR">
			 <CFPROCRESULT NAME="qrygetCarrierDetails">
		</CFSTOREDPROC>
		<cfset var CarrierEmailID = qrygetCarrierDetails.EmailID>
		<cfset var CarrierContactID = qrygetCarrierDetails.CarrierID>
		<cfset var CarrierPhoneNo = qrygetCarrierDetails.Phone>
		<cfset var CarrierPhoneNoExt = qrygetCarrierDetails.PhoneExt>
		<cfset var CarrierFax = qrygetCarrierDetails.Fax>
		<cfset var CarrierFaxExt = qrygetCarrierDetails.FaxExt>
		<cfset var CarrierTollFree = qrygetCarrierDetails.TollFree>
		<cfset var CarrierTollFreeExt = qrygetCarrierDetails.TollFreeExt>
		<cfset var CarrierCell = qrygetCarrierDetails.Cel>
		<cfset var CarrierCellExt = qrygetCarrierDetails.CellPhoneExt>
		<cfset var ContactPerson = qrygetCarrierDetails.ContactPerson>
		<cfif structkeyexists(arguments,"loadid") and len(trim(arguments.loadid)) and structKeyExists(arguments, "stopNo") and isNumeric(arguments.stopNo)>
			<cfset stn = stopNo - 1>
			<cfquery name="qGetCarrierDetails" datasource="#arguments.dsn#">
				SELECT 
				LoadStops.CarrierEmailID,
				LoadStops.CarrierContactID,
				LoadStops.CarrierPhoneNo,
				LoadStops.CarrierPhoneNoExt,
				LoadStops.CarrierFax,
				LoadStops.CarrierFaxExt,
				LoadStops.CarrierTollFree,
				LoadStops.CarrierTollFreeExt,
				LoadStops.CarrierCell,
				LoadStops.CarrierCellExt,
				CASE WHEN LoadStops.CarrierContactID = Carriers.CarrierID THEN Carriers.ContactPerson ELSE CarrierContacts.ContactPerson END AS ContactPerson 
				FROM LoadStops 
				LEFT JOIN CarrierContacts ON CarrierContacts.CarrierContactID = LoadStops.CarrierContactID
				LEFT JOIN Carriers ON Carriers.CarrierID = LoadStops.CarrierContactID
				WHERE LoadID = <cfqueryparam value="#arguments.loadid#" cfsqltype="CF_SQL_VARCHAR"> and stopNo = <cfqueryparam value="#stn#" cfsqltype="CF_SQL_INTEGER">
			</cfquery>
			<cfif len(trim(qGetCarrierDetails.CarrierEmailID))>
				<cfset CarrierEmailID = qGetCarrierDetails.CarrierEmailID>
			</cfif>
			<cfif len(trim(qGetCarrierDetails.CarrierContactID))>
				<cfset CarrierContactID = qGetCarrierDetails.CarrierContactID>
			</cfif>
			<cfif len(trim(qGetCarrierDetails.CarrierPhoneNo))>
				<cfset CarrierPhoneNo = qGetCarrierDetails.CarrierPhoneNo>
			</cfif>
			<cfif len(trim(qGetCarrierDetails.CarrierPhoneNoExt))>
				<cfset CarrierPhoneNoExt = qGetCarrierDetails.CarrierPhoneNoExt>
			</cfif>
			<cfif len(trim(qGetCarrierDetails.CarrierFax))>
				<cfset CarrierFax = qGetCarrierDetails.CarrierFax>
			</cfif>
			<cfif len(trim(qGetCarrierDetails.CarrierFaxExt))>
				<cfset CarrierFaxExt = qGetCarrierDetails.CarrierFaxExt>
			</cfif>
			<cfif len(trim(qGetCarrierDetails.CarrierTollFree))>
				<cfset CarrierTollFree = qGetCarrierDetails.CarrierTollFree>
			</cfif>
			<cfif len(trim(qGetCarrierDetails.CarrierTollFreeExt))>
				<cfset CarrierTollFreeExt = qGetCarrierDetails.CarrierTollFreeExt>
			</cfif>
			<cfif len(trim(qGetCarrierDetails.CarrierCell))>
				<cfset CarrierCell = qGetCarrierDetails.CarrierCell>
			</cfif>
			<cfif len(trim(qGetCarrierDetails.CarrierCellExt))>
				<cfset CarrierCellExt = qGetCarrierDetails.CarrierCellExt>
			</cfif>
			<cfif len(trim(qGetCarrierDetails.ContactPerson))>
				<cfset ContactPerson = qGetCarrierDetails.ContactPerson>
			</cfif>
		</cfif>
		<cfsavecontent variable="CarrierInfoForm">
			<cfoutput>
				<div class="clear"></div>
				<div class="clear"></div>
				<label>&nbsp;</label>
				<label class="field-textarea  carrier-field-textarea"><b><a href="index.cfm?event=addcarrier&carrierid=#qrygetCarrierDetails.carrierID#&iscarrier=#qrygetCarrierDetails.iscarrier#&#arguments.urlToken#">#qrygetCarrierDetails.carrierName#</a></b><br/>#qrygetCarrierDetails.Address#<br/>#qrygetCarrierDetails.City#,&nbsp;#qrygetCarrierDetails.stateCode#&nbsp;#qrygetCarrierDetails.ZipCode#<br/><br/><a class='underline'>MC##:</a>#qrygetCarrierDetails.MCNumber#&nbsp;&nbsp;<a class='underline'>DOT##:</a>#qrygetCarrierDetails.DOTNumber#&nbsp;&nbsp;<a class='underline'>SCAC##:</a>#qrygetCarrierDetails.SCAC#&nbsp;&nbsp;</label>
				<div class="clear"></div>
				<label>Contact</label>
				<input class='CarrierContactAuto' data-carrID="#qrygetCarrierDetails.carrierID#" value="#ContactPerson#" placeholder='type text here to display list'>
				<input type='hidden' name='CarrierContactID#arguments.stopNo#' id='CarrierContactID#arguments.stopNo#' value='#CarrierContactID#'>
				<input style='width: 20px !important;height: 18px;padding: 0;' type='button' value='...'' onclick='openViewCarrierContactPopup(this)'>
				<div class="clear"></div>
				<label>Email</label>
				<input name="CarrierEmailID#arguments.stopNo#" id="CarrierEmailID#arguments.stopNo#" data-carrID="#qrygetCarrierDetails.carrierID#" class="emailbox CarrEmail" value="#CarrierEmailID#">
				<div class="clear"></div>
				<label>Phone</label>
				<input type="text" name="CarrierPhoneNo#arguments.stopNo#" id="CarrierPhoneNo#arguments.stopNo#" value="#CarrierPhoneNo#" class="inp70px" onchange="ParseUSNumber(this);">
				<input type="text" name="CarrierPhoneNoExt#arguments.stopNo#" id="CarrierPhoneNoExt#arguments.stopNo#" value="#CarrierPhoneNoExt#" class="inp18px">
				<label class="label45px">Fax</label>
				<input type="text" name="CarrierFax#arguments.stopNo#" id="CarrierFax#arguments.stopNo#" value="#CarrierFax#" class="inp70px" onchange="ParseUSNumber(this);">
				<input type="text" name="CarrierFaxExt#arguments.stopNo#" id="CarrierFaxExt#arguments.stopNo#" value="#CarrierFaxExt#" class="inp18px">
				<div class="clear"></div>
				<label>Toll Free</label>
				<input type="text" name="CarrierTollFree#arguments.stopNo#" id="CarrierTollFree#arguments.stopNo#" value="#CarrierTollFree#" class="inp70px" onchange="ParseUSNumber(this);">
				<input type="text" name="CarrierTollFreeExt#arguments.stopNo#" id="CarrierTollFreeExt#arguments.stopNo#" value="#CarrierTollFreeExt#" class="inp18px">
				<label class="label45px">Cell</label>
				<input type="text" name="CarrierCell#arguments.stopNo#" id="CarrierCell#arguments.stopNo#" value="#CarrierCell#" class="inp70px" onchange="ParseUSNumber(this);">
				<input type="text" name="CarrierCellExt#arguments.stopNo#" id="CarrierCellExt#arguments.stopNo#" value="#CarrierCellExt#" class="inp18px">
				<cfif len(trim(qrygetCarrierDetails.RemitName))>
					<div class='clear'></div>
					<label style="width: 102px !important;">Factoring Co.</label>
					<label class="field-text disabledLoadInputs" style="width:273px !important">#qrygetCarrierDetails.RemitName#</label>
				</cfif>
			</div>
			</cfoutput>
		</cfsavecontent>
		<cfset returnVariable = querynew("stopid,CarrierInfoForm")>
		<cfset queryaddrow(returnVariable,1)>
		<cfset querySetCell(returnVariable, 'stopid', '#stopNo#',1)>
	    <cfset querySetCell(returnVariable, "CarrierInfoForm", "#CarrierInfoForm#", 1)>
	      #SerializeJSON(returnVariable)#
	</cffunction>

	<!---Check for free unit--->
	<cffunction name="checkFeeUnit" access="remote" returntype="any">
		<cfargument name="dsn" type="string" required="yes" />
		<cfargument name="unitId" required="No" type="any">
		<cfargument name="CompanyID" type="string" required="yes" >
		<cfquery name="qrygetunits" datasource="#arguments.dsn#">
	         select isFee, UnitCode,CustomerRate,CarrierRate from  Units
	         where CompanyID = '#arguments.CompanyID#'
	 		 <cfif isdefined('arguments.unitId') and len(arguments.unitId)>
	 			and UnitID='#arguments.unitId#'
	 		</cfif>
	     </cfquery>
		<cfif qrygetunits.recordcount and qrygetunits.isfee is true>
			<cfreturn 'true,#qrygetunits.UnitCode#,#qrygetunits.CustomerRate#,#qrygetunits.CarrierRate#'>
		<cfelse>
			<cfreturn 'false,#qrygetunits.UnitCode#,#qrygetunits.CustomerRate#,#qrygetunits.CarrierRate#'>
		</cfif>
	</cffunction>

	<cffunction name="checkAjaxFeeUnit" access="remote" output="yes" returnformat="json">
		<cfargument name="dsn" type="string" required="yes" />
		<cfargument name="unitId" required="No" type="any">
		<cfargument name="CompanyID" type="string" required="yes" >
		<cfquery name="qrygetunits" datasource="#arguments.dsn#">
	         select isFee, UnitCode,CustomerRate,CarrierRate,PaymentAdvance from  Units
	         where CompanyID = <cfqueryparam value="#arguments.CompanyID#" cfsqltype="CF_SQL_VARCHAR">
	 		 <cfif isdefined('arguments.unitId') and len(arguments.unitId)>
	 			and UnitID=<cfqueryparam value="#arguments.unitId#" cfsqltype="CF_SQL_VARCHAR">
	 		</cfif>
	     </cfquery>
		<cfif qrygetunits.recordcount and qrygetunits.isfee is true>
	        <cfset unitsArr = ["true","#qrygetunits.UnitCode#", "#qrygetunits.CustomerRate#", "#qrygetunits.CarrierRate#", "#qrygetunits.PaymentAdvance#"]>
		<cfelse>
	        <cfset unitsArr = ["false","#qrygetunits.UnitCode#", "#qrygetunits.CustomerRate#", "#qrygetunits.CarrierRate#", "#qrygetunits.PaymentAdvance#"]>
		</cfif>
	      #SerializeJSON(unitsArr)#
	</cffunction>



	<!---Update Customer --->
	<cffunction name="updateCustomer" access="public" output="false" returntype="any">
	    <cfargument name="formStruct" type="struct">
		<cfargument name="updateType" type="string">
		<cfargument name="stopNo" type="string">
		<cfif stopNo EQ '0'>
			<cfset stopNo = ''>
		</cfif>
		<cfset custToEditId = Evaluate('arguments.formStruct.#updateType#ValueContainer#stopNo#')>
		<cfif len(custToEditId) AND getSystemSetupOptions().UpdateCustomerFromLoadScreen>
			<cfquery name="qryupdatecustomer" datasource="#variables.dsn#" timeout="120">
		       	UPDATE Customers
		       	SET
					CustomerName=			<cfqueryparam cfsqltype="cf_sql_varchar" value="#EValuate('arguments.formStruct.#updateType#Name#stopNo#')#">,
				 	Location=				<cfqueryparam cfsqltype="cf_sql_varchar" value="#EValuate('arguments.formStruct.#updateType#location#stopNo#')#">,
					City=					<cfqueryparam cfsqltype="cf_sql_varchar" value="#EValuate('arguments.formStruct.#updateType#city#stopNo#')#">,
					<cfif EValuate('arguments.formStruct.#updateType#state#stopNo#') NEQ ''>
					statecode=				<cfqueryparam cfsqltype="cf_sql_varchar" value="#EValuate('arguments.formStruct.#updateType#state#stopNo#')#">,
					</cfif>
					Zipcode=				<cfqueryparam cfsqltype="cf_sql_varchar" value="#EValuate('arguments.formStruct.#updateType#Zipcode#stopNo#')#">,
					ContactPerson=			<cfqueryparam cfsqltype="cf_sql_varchar" value="#EValuate('arguments.formStruct.#updateType#ContactPerson#stopNo#')#">,
					PhoneNo=				<cfqueryparam cfsqltype="cf_sql_varchar" value="#EValuate('arguments.formStruct.#updateType#Phone#stopNo#')#">,
					Email=					<cfqueryparam cfsqltype="cf_sql_varchar" value="#EValuate('arguments.formStruct.#updateType#Email#stopNo#')#">,
					CustomerDirections= 	<cfqueryparam cfsqltype="cf_sql_varchar" value="#EValuate('arguments.formStruct.#updateType#Direction#stopNo#')#">,
					LastModifiedBy=		<cfqueryparam cfsqltype="cf_sql_varchar" value="#session.adminUserName#">,
					LastModifiedDateTime=	<cfqueryparam cfsqltype="cf_sql_date" value="#now()#">,
					UpdatedByIP=			<cfqueryparam cfsqltype="cf_sql_varchar" value="#cgi.REMOTE_ADDR#">
				WHERE CustomerID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#custToEditId#">
			</cfquery>
		</cfif>
		<cfreturn "#custToEditId#">
	</cffunction>


	<cffunction name="formCustStruct" access="public" returntype="any">
		<cfargument name="frmstruct" type="struct" required="yes">
		<cfargument name="type" required="yes">
		<cfargument name="stop" required="false" default="">

		<cfif arguments.type eq "shipper">
			<cfset shipperStruct = {}>
		   	<cfquery name="getShipperDetails" datasource="#variables.dsn#" >
			   select loadPotential,NULL AS companyID,bestOpp
			   from customers where customerID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.frmstruct.cutomerIdAutoValueContainer#">
		  	</cfquery>
	 	  	<cfset shipperStruct.customerStatusID 	= 1>
			<cfset shipperStruct.customerCode 		= evaluate("arguments.frmstruct.shipperName#stop#")>
			<cfset shipperStruct.customerName		= evaluate("arguments.frmstruct.shipperName#stop#")>
			<cfset shipperStruct.officeID1			= session.officeID>
			<cfset shipperStruct.location			= evaluate("arguments.frmstruct.shipperlocation#stop#")>
			<cfset shipperStruct.city				= evaluate("arguments.frmstruct.shipperCity#stop#")>
			<cfset shipperStruct.state1				= evaluate("arguments.frmstruct.shipperState#stop#")>
			<cfset shipperStruct.zipCode		 	= evaluate("arguments.frmstruct.shipperZipCode#stop#")>
			<cfset shipperStruct.contactPerson 		= evaluate("arguments.frmstruct.shipperContactPerson#stop#")>
			<cfset shipperStruct.mobileNo			= "">
			<cfset shipperStruct.phoneNo			= evaluate("arguments.frmstruct.shipperPhone#stop#")>
			<cfset shipperStruct.email 				= evaluate("arguments.frmstruct.shipperEmail#stop#")>
			<cfset shipperStruct.website 			= "">
			<cfif structKeyExists(arguments.frmstruct, "salesPerson")>
				<cfset shipperStruct.salesPerson 		= arguments.frmstruct.salesPerson>
			<cfelse>
				<cfset shipperStruct.salesPerson 		= "">
			</cfif>
			<cfset shipperStruct.dispatcher 		= arguments.frmstruct.Dispatcher>
			<cfset shipperStruct.loadPotential 		= 0>
			<cfset shipperStruct.companyID1			= #getShipperDetails.companyID#>
			<cfset shipperStruct.bestOpp 			= 0>
			<cfset shipperStruct.customerDirections = evaluate("arguments.frmstruct.shipperDirection#stop#")>
			<cfset shipperStruct.customerNotes 		= evaluate("arguments.frmstruct.shipperNotes#stop#")>
			<cfset shipperStruct.isPayer			= 0>
			<cfset shipperStruct.financeID 			= "">
			<cfset shipperStruct.creditLimit		= 0>
			<cfset shipperStruct.balance 			= 0>
			<cfset shipperStruct.available			= 0>
			<cfset shipperStruct.ratePerMile		= 0>
			<cfset shipperStruct.fax				= evaluate("arguments.frmstruct.shipperFax#stop#")>
			<cfset shipperStruct.country1 			= "">
			<cfset shipperStruct.CarrierNotes 		= "">
			<cfset shipperStruct.Tollfree 			= "">
			<cfif structKeyExists(arguments.frmstruct, "timezone")>
				<cfset shipperStruct.timezone 		= arguments.frmstruct.timezone>
			<cfelse>
				<cfset shipperStruct.timezone 		= "">
			</cfif>
			<cfset shipperStruct.AddFromLoad 		= 1>
			<cfreturn #shipperStruct#>
		<cfelseif arguments.type eq "consignee">
			<cfset consigneeStruct = {}>
	 	   	<cfquery name="getConsigneeDetails" datasource="#variables.dsn#" >
				select loadPotential,NULL AS companyID,bestOpp
				from customers where customerID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.frmstruct.cutomerIdAutoValueContainer#">
			</cfquery>

			<cfset consigneeStruct.customerStatusID 	= 1>
			<cfset consigneeStruct.customerCode 		= evaluate("arguments.frmstruct.consigneeName#stop#")>
			<cfset consigneeStruct.customerName			= evaluate("arguments.frmstruct.consigneeName#stop#")>
			<cfset consigneeStruct.officeID1			= session.officeID>
			<cfset consigneeStruct.location				= evaluate("arguments.frmstruct.consigneelocation#stop#")>
			<cfset consigneeStruct.city					= evaluate("arguments.frmstruct.consigneeCity#stop#")>
			<cfset consigneeStruct.state1				= evaluate("arguments.frmstruct.consigneeState#stop#")>
			<cfset consigneeStruct.zipCode		 		= evaluate("arguments.frmstruct.consigneeZipCode#stop#")>
			<cfset consigneeStruct.contactPerson 		= evaluate("arguments.frmstruct.consigneeContactPerson#stop#")>
			<cfset consigneeStruct.mobileNo				= "">
			<cfset consigneeStruct.phoneNo				= evaluate("arguments.frmstruct.consigneePhone#stop#")>
			<cfset consigneeStruct.email 				= evaluate("arguments.frmstruct.consigneeEmail#stop#")>
			<cfset consigneeStruct.website 				= "">
			<cfif structKeyExists(arguments.frmstruct, "salesPerson")>
				<cfset consigneeStruct.salesPerson 			= arguments.frmstruct.salesPerson>
			<cfelse>
				<cfset consigneeStruct.salesPerson 			="">
			</cfif>
			<cfset consigneeStruct.dispatcher 			= arguments.frmstruct.Dispatcher>
			<cfset consigneeStruct.loadPotential 		= getConsigneeDetails.loadPotential>
			<cfset consigneeStruct.companyID1			= getConsigneeDetails.companyID>
			<cfset consigneeStruct.bestOpp 				= getConsigneeDetails.bestOpp>
			<cfset consigneeStruct.customerDirections	= evaluate("arguments.frmstruct.consigneeDirection#stop#")>
			<cfset consigneeStruct.customerNotes 		= evaluate("arguments.frmstruct.consigneeNotes#stop#")>
			<cfset consigneeStruct.isPayer				= 0>
			<cfset consigneeStruct.financeID 			= "">
			<cfset consigneeStruct.creditLimit			= 0>
			<cfset consigneeStruct.balance 				= 0>
			<cfset consigneeStruct.available			= 0>
			<cfset consigneeStruct.ratePerMile			= 0>
			<cfset consigneeStruct.fax					= evaluate("arguments.frmstruct.consigneeFax#stop#")>
			<cfset consigneeStruct.country1 			= "">
			<cfset consigneeStruct.CarrierNotes 		= "">
			<cfset consigneeStruct.Tollfree 			= "">
			<cfif structKeyExists(arguments.frmstruct, "timezone")>
				<cfset consigneeStruct.timezone 			= arguments.frmstruct.timezone>
			<cfelse>
				<cfset consigneeStruct.timezone 			="">
			</cfif>
			<cfset consigneeStruct.AddFromLoad 		= 1>
		    <cfreturn #consigneeStruct#>
		</cfif>
	</cffunction>

	<!-------------posttoITS WEBERVICE start----------------->
	<cffunction name="ITSWebservice" returntype="any" access="remote" returnformat="wddx">
		<cfargument name="impref" type="any" required="true" />
		<cfargument name="postaction" type="any" required="true" />
		<cfargument name="ITSUsername" type="any" required="true" />
		<cfargument name="ITSPassword" type="any" required="true" />
		<cfargument name="ITSintegrationID" type="any" required="true" />
		<!---  add by sp --->
		<cfargument name="loadNumber" type="any" required="false" default="" />
		<!---  add by sp --->
		<cfargument name="LoadID" type="any" required="true" />
		<cfargument name="CompanyID" type="any" required="true" />
		<cfargument name="dsn" type="any" required="no" />
		<cfargument name="EmpID" type="any" required="true" />
		<cfargument name="IncludeCarrierRate" type="any" required="no" default="0" />
		<cfargument name="CARRIERRATE" default="0" type="any" required="no">
		
		<cftry>
			<cfif structkeyexists(arguments,"dsn")>
				<cfset variables.dsn=arguments.dsn>
			</cfif>
			<cfquery name="vwLoadsITS" datasource="#variables.dsn#">
				SELECT * FROM vwLoadsITS WHERE LoadID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.LoadID#">
			</cfquery>

			<cfif not vwLoadsITS.recordcount>
				<cfreturn "Unable to post to ITS. Please check Pickup/Delivery dates/EquipmentCode.">
			</cfif>

			<cfif listFindNoCase('A,U', arguments.postaction) AND (NOT len(trim(vwLoadsITS.DeliveryDate)) OR NOT len(trim(vwLoadsITS.PickupDate)))>
				<cfreturn "Unable to post to ITS. Please check Pickup/Delivery dates.">
			</cfif>

			<cfif not len(trim(vwLoadsITS.ITSEquipmentID))>
				<cfreturn "Unable to post to ITS. Invalid Equipment Code.">
			</cfif>

			<cfquery name="vwLoadsITS" datasource="#variables.dsn#">
				SELECT * FROM vwLoadsITS WHERE LoadID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.LoadID#">
			</cfquery>

			<cfquery name="getLoadMultipleDates" datasource="#variables.dsn#">
				SELECT TOP 1 MultipleDates FROM LoadStops WHERE LoadID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.LoadID#"> AND LoadType=1 ORDER BY StopNo,LoadType
			</cfquery>

			<cfquery name="qGetCompanyITSDetails" datasource="#variables.dsn#">
				SELECT O.ITSAccessToken,O.ITSRefreshToken,O.ITSTokenExpireDate,O.OfficeID,O.ITSUserName,
				O.ITSPassword
				FROM Employees E 
				INNER JOIN Offices O ON E.OfficeID = O.OfficeID
				WHERE E.EmployeeID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.EmpID#">
			</cfquery>

			<cfquery name="qGetITSKey" datasource="LoadManagerAdmin">
				SELECT ITSClientID,ITSSecret
				FROM SystemSetup
			</cfquery>

			<cfif NOT Len(Trim(qGetITSKey.ITSClientID)) OR NOT Len(Trim(qGetITSKey.ITSSecret)) OR NOT Len(Trim(qGetCompanyITSDetails.ITSAccessToken)) OR NOT Len(Trim(qGetCompanyITSDetails.ITSRefreshToken)) OR NOT Len(Trim(qGetCompanyITSDetails.ITSTokenExpireDate))>
				<cfreturn "Unable to post to ITS. Please check the TruckStop credentials.">
			</cfif>

			<cfif dateDiff("n", now(), qGetCompanyITSDetails.ITSTokenExpireDate) LTE 0>
				<cfset var base64 = toBase64('#trim(qGetITSKey.ITSClientID)#:#trim(qGetITSKey.ITSSecret)#')>
				<cfhttp method="post" url="https://api.truckstop.com/auth/token?scope=truckstop" result="objGet">
				    <cfhttpparam type="header" name="Authorization" value="Basic #base64#"/>
				    <cfhttpparam type="header" name="Content-Type" value="application/x-www-form-urlencoded"/>
				    <cfhttpparam type="formfield" name="grant_type" value="refresh_token">
				    <cfhttpparam type="formfield" name="refresh_token" value="#qGetCompanyITSDetails.ITSRefreshToken#">
				</cfhttp>
				<cfif objGet.Statuscode EQ '200 OK'>
					<cfset var FileContent = DeSerializeJSON(objGet.FileContent)>
					<cfif structkeyexists(FileContent,"access_token") and structkeyexists(FileContent,"refresh_token")>
						<cfset var access_token = FileContent.access_token>
						<cfquery name="qUpdITS" datasource="#variables.dsn#">
							UPDATE Offices SET 
							ITSAccessToken = <cfqueryparam value="#FileContent.access_token#" cfsqltype="cf_sql_varchar">
							,ITSRefreshToken = <cfqueryparam value="#FileContent.refresh_token#" cfsqltype="cf_sql_varchar">
							,ITSTokenExpireDate = <cfqueryparam value="#dateAdd("n", 20, now())#" cfsqltype="cf_sql_timestamp">
							WHERE ITSUserName = <cfqueryparam value="#qGetCompanyITSDetails.ITSUserName#" cfsqltype="cf_sql_varchar">
							AND ITSPassword = <cfqueryparam value="#qGetCompanyITSDetails.ITSPassword#" cfsqltype="cf_sql_varchar">
						</cfquery>
					<cfelse>
						<cfreturn "Unable to post to ITS. Invalid authorization.">
					</cfif>
				<cfelse>
					<cfreturn "Unable to post to ITS. Invalid authorization.">
				</cfif>
			<cfelse>
				<cfset var access_token = qGetCompanyITSDetails.ITSAccessToken>
			</cfif>

			<cfif listFindNoCase("A,U", arguments.postaction)>
				<cfset var ITSRequestData = structNew()>
				<cfset ITSRequestData["loadNumber"] = vwLoadsITS.ImportRef>

				<cfset var equipmentAttributes = structNew()>
				<cfset equipmentAttributes["equipmentTypeId"] = vwLoadsITS.ITSEquipmentID>
				<cfif vwLoadsITS.FullOrPartial EQ 0>
					<cfset equipmentAttributes["transportationModeId"] = 1>
				<cfelse>
					<cfset equipmentAttributes["transportationModeId"] = 2>
				</cfif>
				<cfset ITSRequestData["equipmentAttributes"] = equipmentAttributes>
				<cfset ITSRequestData["note"] = vwLoadsITS.notes>

				<cfset var dimensional = structNew()>
				<cfif vwLoadsITS.length eq 0 or vwLoadsITS.length eq "">
					<cfset dimensional["length"] = "">
				<cfelse>
					<cfset dimensional["length"] = vwLoadsITS.length>
				</cfif>
				
				<cfif vwLoadsITS.width eq 0 or vwLoadsITS.width eq "">
					<cfset dimensional["width"] = "">
				<cfelse>
					<cfset dimensional["width"] = vwLoadsITS.width>
				</cfif>

				<cfif vwLoadsITS.weight eq 0  or  vwLoadsITS.weight eq "">
					<cfset dimensional["weight"] = 1>
				<cfelse>
					<cfset dimensional["weight"] = vwLoadsITS.weight>
				</cfif>

				<cfset ITSRequestData["dimensional"] = dimensional>

				<cfset var loadStops = arrayNew(1)>
				<!--- Begin:Pickup Details --->
				<cfset var loadStopsPickup = structNew()>
				<cfset loadStopsPickup["type"] = 1>
				<cfset loadStopsPickup["Sequence"] = 2>
				<cfset ITSDateTime = getITSDateTime(vwLoadsITS.PickupDate,vwLoadsITS.PickupTime)>
				<cfset loadStopsPickup["earlyDateTime"] = ITSDateTime.earlyDateTime>
				<cfif structKeyExists(ITSDateTime, "lateDateTime")>
					<cfset loadStopsPickup["lateDateTime"] = ITSDateTime.lateDateTime>
				</cfif>
				<!--- Begin:Pickup Location Details --->
				<cfset var loadStopsPickupLocation = structNew()> 
				<cfset loadStopsPickupLocation["locationName"] = vwLoadsITS.OriginLocation>
				<cfset loadStopsPickupLocation["city"] = vwLoadsITS.OriginCity>
				<cfset loadStopsPickupLocation["state"] = vwLoadsITS.OriginState>
				<cfset loadStopsPickupLocation["streetAddress1"] = vwLoadsITS.OriginAddress>
				<cfset loadStopsPickupLocation["postalCode"] = vwLoadsITS.OriginPostalCode>
				<cfset loadStopsPickup["location"] = loadStopsPickupLocation>

				<cfset loadStopsPickup["contactName"] = vwLoadsITS.OriginContactPerson>
				<cfif len(trim(replaceNoCase(vwLoadsITS.OriginContactPhone, "-", "","ALL")) LTE 10)>
					<cfset loadStopsPickup["contactPhone"] = replaceNoCase(vwLoadsITS.OriginContactPhone, "-", "","ALL")>
				</cfif>
				<!--- End:Pickup Location Details --->
				<cfset arrayAppend(loadStops, loadStopsPickup)>
				<!--- End:Pickup Details --->

				<!--- Begin:Delivery Details --->
				<cfset var loadStopsDelivery = structNew()>
				<cfset loadStopsDelivery["type"] = 2>
				<cfset loadStopsDelivery["Sequence"] = 1>
				<cfif vwLoadsITS.DeliveryDate EQ vwLoadsITS.PickupDate AND NOT len(trim(vwLoadsITS.DeliveryTime))>
					<cfset loadStopsDelivery["earlyDateTime"] = DateFormat(vwLoadsITS.DeliveryDate,"YYYY-MM-DD")&"T"&"23:59:59">
				<cfelse>
					<cfset ITSDateTime = getITSDateTime(vwLoadsITS.DeliveryDate,vwLoadsITS.DeliveryTime)>
					<cfset loadStopsDelivery["earlyDateTime"] = ITSDateTime.earlyDateTime>
					<cfif structKeyExists(ITSDateTime, "lateDateTime")>
						<cfset loadStopsDelivery["lateDateTime"] = ITSDateTime.lateDateTime>
					</cfif>
				</cfif>
				<!--- Begin:Delivery Location Details --->
				<cfset var loadStopsDeliveryLocation = structNew()> 
				<cfset loadStopsDeliveryLocation["locationName"] = vwLoadsITS.DestLocation>
				<cfset loadStopsDeliveryLocation["city"] = vwLoadsITS.DestCity>
				<cfset loadStopsDeliveryLocation["state"] = vwLoadsITS.DestState>
				<cfset loadStopsDeliveryLocation["streetAddress1"] = vwLoadsITS.DestAddress>
				<cfset loadStopsDeliveryLocation["postalCode"] = vwLoadsITS.DestPostalCode>
				<cfset loadStopsDelivery["location"] = loadStopsDeliveryLocation>

				<cfset loadStopsDelivery["contactName"] = vwLoadsITS.DestContactPerson>
				<cfif len(trim(replaceNoCase(vwLoadsITS.DestContactPhone, "-", "","ALL")) LTE 10)>
					<cfset loadStopsDelivery["contactPhone"] = replaceNoCase(vwLoadsITS.DestContactPhone, "-", "","ALL")>
				</cfif>
				<!--- End:Pickup Location Details --->
				<cfset arrayAppend(loadStops, loadStopsDelivery)>
				<!--- End:Pickup Details --->

				<cfset ITSRequestData["loadStops"] = loadStops>
				<cfif arguments.IncludeCarrierRate EQ 1 AND len(trim(ReplaceNoCase(ReplaceNoCase(arguments.CARRIERRATE,',','','ALL'),'$','','ALL'))) AND isnumeric(trim(ReplaceNoCase(ReplaceNoCase(arguments.CARRIERRATE,',','','ALL'),'$','','ALL')))>
					
					<cfset var rateAttributes = structnew()>
					<cfset var postedAllInRate = structnew()>
					<cfset postedAllInRate['amount'] = trim(ReplaceNoCase(ReplaceNoCase(arguments.CARRIERRATE,',','','ALL'),'$','','ALL'))>
					<cfset rateAttributes['postedAllInRate'] = postedAllInRate>
					<cfset ITSRequestData["rateAttributes"] = rateAttributes>
				</cfif>

				<cfif arguments.postaction EQ 'A'>
					<cfset var p_method = "POST">
					<cfset var p_url = "https://api.truckstop.com/loadmanagement/v2/load">
				<cfelseif arguments.postaction EQ 'U'>
					<cfset var p_method = "PUT">
					<cfset var p_url = "https://api.truckstop.com/loadmanagement/v2/load/#vwLoadsITS.TruckStopLoadID#">
				</cfif>

				<cfhttp method="#p_method#" url="#p_url#" result="objGet">
				    <cfhttpparam type="header" name="Authorization" value="bearer #access_token#"/>
				    <cfhttpparam type="header" name="Content-Type" value="application/json"/>
				    <cfhttpparam type="body" value="#serializeJSON(ITSRequestData)#">
				</cfhttp>

				<cfif getLoadMultipleDates.recordcount>
					<cfif len(trim(vwLoadsITS.PickupDate)) AND len(trim(vwLoadsITS.DeliveryDate)) AND len(trim(getLoadMultipleDates.MultipleDates))>
						<cfset days = DateDiff('d', vwLoadsITS.PickupDate, vwLoadsITS.DeliveryDate)>
						<cfset var TempMultipleTruckStopLoadID = "">
						<cfset mIndx = 0>
						<cfloop list="#getLoadMultipleDates.MultipleDates#" item="PickUpDate">
							<cfif DateCompare(PickUpDate, vwLoadsITS.PickupDate , 'd') NEQ 0>
								<cfset mIndx++>
								<cfset DeliveryDate = DateAdd('d', days, pickUpDate)>
								<cfset var ITSRequestDataMulti = ITSRequestData>
								<cfset ITSRequestDataMulti["loadNumber"] = vwLoadsITS.ImportRef&dateformat(PickUpDate,'YYYYMMDD')>

								<cfset var loadStops = arrayNew(1)>
								<!--- Begin:Pickup Details --->
								<cfset var loadStopsPickup = structNew()>
								<cfset loadStopsPickup["type"] = 1>
								<cfset loadStopsPickup["Sequence"] = 2>
								<cfset ITSDateTime = getITSDateTime(PickupDate,vwLoadsITS.PickupTime)>
								<cfset loadStopsPickup["earlyDateTime"] = ITSDateTime.earlyDateTime>
								<cfif structKeyExists(ITSDateTime, "lateDateTime")>
									<cfset loadStopsPickup["lateDateTime"] = ITSDateTime.lateDateTime>
								</cfif>

								<!--- Begin:Pickup Location Details --->
								<cfset var loadStopsPickupLocation = structNew()> 
								<cfset loadStopsPickupLocation["locationName"] = vwLoadsITS.OriginLocation>
								<cfset loadStopsPickupLocation["city"] = vwLoadsITS.OriginCity>
								<cfset loadStopsPickupLocation["state"] = vwLoadsITS.OriginState>
								<cfset loadStopsPickupLocation["streetAddress1"] = vwLoadsITS.OriginAddress>
								<cfset loadStopsPickupLocation["postalCode"] = vwLoadsITS.OriginPostalCode>
								<cfset loadStopsPickup["location"] = loadStopsPickupLocation>

								<cfset loadStopsPickup["contactName"] = vwLoadsITS.OriginContactPerson>
								<cfif len(trim(replaceNoCase(vwLoadsITS.OriginContactPhone, "-", "","ALL")) LTE 10)>
									<cfset loadStopsPickup["contactPhone"] = replaceNoCase(vwLoadsITS.OriginContactPhone, "-", "","ALL")>
								</cfif>
								<!--- End:Pickup Location Details --->
								<cfset arrayAppend(loadStops, loadStopsPickup)>
								<!--- End:Pickup Details --->

								<!--- Begin:Delivery Details --->
								<cfset var loadStopsDelivery = structNew()>
								<cfset loadStopsDelivery["type"] = 2>
								<cfset loadStopsDelivery["Sequence"] = 1>
								<cfset ITSDateTime = getITSDateTime(DeliveryDate,vwLoadsITS.DeliveryTime)>
								<cfset loadStopsDelivery["earlyDateTime"] = ITSDateTime.earlyDateTime>
								<cfif structKeyExists(ITSDateTime, "lateDateTime")>
									<cfset loadStopsDelivery["lateDateTime"] = ITSDateTime.lateDateTime>
								</cfif>

								<!--- Begin:Delivery Location Details --->
								<cfset var loadStopsDeliveryLocation = structNew()> 
								<cfset loadStopsDeliveryLocation["locationName"] = vwLoadsITS.DestLocation>
								<cfset loadStopsDeliveryLocation["city"] = vwLoadsITS.DestCity>
								<cfset loadStopsDeliveryLocation["state"] = vwLoadsITS.DestState>
								<cfset loadStopsDeliveryLocation["streetAddress1"] = vwLoadsITS.DestAddress>
								<cfset loadStopsDeliveryLocation["postalCode"] = vwLoadsITS.DestPostalCode>
								<cfset loadStopsDelivery["location"] = loadStopsDeliveryLocation>

								<cfset loadStopsDelivery["contactName"] = vwLoadsITS.DestContactPerson>
								<cfif len(trim(replaceNoCase(vwLoadsITS.DestContactPhone, "-", "","ALL")) LTE 10)>
									<cfset loadStopsDelivery["contactPhone"] = replaceNoCase(vwLoadsITS.DestContactPhone, "-", "","ALL")>
								</cfif>
								<!--- End:Pickup Location Details --->
								<cfset arrayAppend(loadStops, loadStopsDelivery)>
								<!--- End:Pickup Details --->

								<cfset ITSRequestDataMulti["loadStops"] = loadStops>
					
								<cfif listLen(vwLoadsITS.MultipleTruckStopLoadID) GTE mIndx>
						            <cfhttp method="PUT" url="https://api.truckstop.com/loadmanagement/v2/load/#listGetAt(vwLoadsITS.MultipleTruckStopLoadID, mIndx)#" result="objGetMulti">
									    <cfhttpparam type="header" name="Authorization" value="bearer #access_token#"/>
									    <cfhttpparam type="header" name="Content-Type" value="application/json"/>
									    <cfhttpparam type="body" value="#serializeJSON(ITSRequestData)#">
									</cfhttp>
									<cfset TempMultipleTruckStopLoadID = listGetAt(vwLoadsITS.MultipleTruckStopLoadID, mIndx)>
						        <cfelse>
						            <cfhttp method="POST" url="https://api.truckstop.com/loadmanagement/v2/load" result="objGetMulti">
									    <cfhttpparam type="header" name="Authorization" value="bearer #access_token#"/>
									    <cfhttpparam type="header" name="Content-Type" value="application/json"/>
									    <cfhttpparam type="body" value="#serializeJSON(ITSRequestData)#">
									</cfhttp>
									<cfif objGetMulti.Statuscode EQ "201 Created">
										<cfset var fileContentMulti = DeSerializeJSON(objGetMulti.fileContent)>
										<cfset TempMultipleTruckStopLoadID = listAppend(TempMultipleTruckStopLoadID, fileContentMulti.LoadID)>
									</cfif>
						        </cfif>
							</cfif>
						</cfloop>
						<cfquery name="updLoad" datasource="#variables.dsn#">
							UPDATE Loads 
							SET MultipleTruckStopLoadID = <cfqueryparam value="#TempMultipleTruckStopLoadID#" cfsqltype="cf_sql_varchar" null="#not len(TempMultipleTruckStopLoadID)#"> 
							WHERE LoadID = <cfqueryparam value="#arguments.LoadID#" cfsqltype="cf_sql_varchar">
						</cfquery>
					</cfif>
				</cfif>

				<cfif objGet.Statuscode EQ "201 Created">
					<cfset var fileContent = DeSerializeJSON(objGet.fileContent)>
					<cfquery name="updLoad" datasource="#variables.dsn#">
						UPDATE Loads 
						SET TruckStopLoadID = <cfqueryparam value="#FileContent.LoadID#" cfsqltype="cf_sql_varchar"> 
							,posttoITS = 1 
							<cfif arguments.IncludeCarrierRate EQ 1>
								,postCarrierRatetoITS = 1
							<cfelse>
								,postCarrierRatetoITS = 0
							</cfif>
						WHERE LoadID = <cfqueryparam value="#arguments.LoadID#" cfsqltype="cf_sql_varchar">
					</cfquery>
					<cfreturn "ITS Says : Added Load successfully." />
				<cfelseif objGet.Statuscode EQ '200 OK'>
					<cfquery name="updLoad" datasource="#variables.dsn#">
						UPDATE Loads SET
						<cfif arguments.IncludeCarrierRate EQ 1>
							postCarrierRatetoITS = 1
						<cfelse>
							postCarrierRatetoITS = 0
						</cfif>
						WHERE LoadID = <cfqueryparam value="#arguments.LoadID#" cfsqltype="cf_sql_varchar">
					</cfquery>
					<cfreturn "ITS Says : Updated Load successfully." />
				<cfelse>
					<cfset var fileContent = DeSerializeJSON(objGet.fileContent)>
					<cfif isStruct(fileContent) AND structKeyExists(fileContent, "success") AND NOT fileContent.success AND structKeyExists(fileContent, "statusSet") AND isArray(fileContent.statusSet) AND NOT arrayIsEmpty(fileContent.statusSet) AND structKeyExists(fileContent.statusSet[1], "descriptor")>
						<cfreturn '#fileContent.statusSet[1].descriptor#. Unable to post to ITS.' />
					<cfelseif isarray(fileContent) AND NOT arrayIsEmpty(fileContent)>
						<cfset fileContentData = fileContent[1]>
						<cfif isStruct(fileContentData) AND structKeyExists(fileContentData, "success") AND NOT fileContentData.success AND structKeyExists(fileContentData, "statusSet") AND isArray(fileContentData.statusSet) AND NOT arrayIsEmpty(fileContentData.statusSet) AND structKeyExists(fileContentData.statusSet[1], "message")>  
							<cfreturn '#fileContentData.statusSet[1].message#. Unable to post to ITS.' />
						</cfif>
					<cfelse>
						<cfreturn 'Something went wrong. Unable to post to ITS.' />
					</cfif>
				</cfif>
			<cfelseif arguments.postaction EQ 'D'>
				<cfset var ITSRequestData = structNew()>
				<cfset ITSRequestData['reason'] = 0>
				<!--- <cfset ITSRequestData['comment'] = "No longer valid load"> --->
				<cfhttp method="DELETE" url="https://api.truckstop.com/loadmanagement/v3/load/#vwLoadsITS.TruckStopLoadID#" result="objGet">
				    <cfhttpparam type="header" name="Authorization" value="bearer #access_token#"/>
				    <cfhttpparam type="header" name="Content-Type" value="application/json"/>
				    <cfhttpparam type="body" value="#serializeJSON(ITSRequestData)#">
				</cfhttp>

				<cfloop list="#vwLoadsITS.MultipleTruckStopLoadID#" item="MTSLoadID">
					<cfset var ITSRequestDataMultiDelete = structNew()>
					<cfset ITSRequestDataMultiDelete['reason'] = 0>
					<cfhttp method="DELETE" url="https://api.truckstop.com/loadmanagement/v3/load/#MTSLoadID#" result="objGetMultiDelete">
					    <cfhttpparam type="header" name="Authorization" value="bearer #access_token#"/>
					    <cfhttpparam type="header" name="Content-Type" value="application/json"/>
					    <cfhttpparam type="body" value="#serializeJSON(ITSRequestDataMultiDelete)#">
					</cfhttp>
				</cfloop>

				<cfif objGet.Statuscode EQ "204 No Content">
					<cfquery name="updLoad" datasource="#variables.dsn#">
						UPDATE Loads 
						SET TruckStopLoadID = NULL
							,MultipleTruckStopLoadID = NULL
							,posttoITS = 0 
							,postCarrierRatetoITS = 0
						WHERE LoadID = <cfqueryparam value="#arguments.LoadID#" cfsqltype="cf_sql_varchar">
					</cfquery>
					<cfreturn "ITS Says : Deleted Load successfully." />
				<cfelse>
					<cfreturn "ITS Says : Unable to Delete Load." />
				</cfif>
			</cfif>
			
			<cfcatch type="any">
				<cfreturn 'Something went wrong. Unable post to ITS.' />
			</cfcatch>
		</cftry>
	</cffunction>

	<cffunction name="getITSDateTime" access="public" returntype="struct">
		<cfargument name="cdate" required="yes" type="date">
		<cfargument name="ctime" required="yes" type="string">

		<cfset var time ="">
		<cfset var starttime ="">
		<cfset var endtime ="">
		<cfset var EarlyDateTime ="">
		<cfset var LateDateTime ="">

		<cfif not len(trim(arguments.ctime)) OR listFindNoCase("ASAP,CALL,FCFS", trim(arguments.ctime))>
	        <cfset time = "0000">
	    <cfelse>
	        <cfset time = arguments.ctime>
	    </cfif>

	    <cfset starttime = listGetAt(time, 1,'-')>
	    <cfif len(trim(starttime)) EQ 4 AND NOT FindNoCase(":",starttime) AND NOT FindNoCase("am",starttime) AND NOT FindNoCase("pm",starttime) >
	        <cfset starttime = insert(":", starttime, 2)>
	    <cfelseif len(trim(starttime)) EQ 1 AND NOT FindNoCase(":",starttime) AND NOT FindNoCase("am",starttime) AND NOT FindNoCase("pm",starttime) >
	        <cfset starttime = starttime&':00'>
	    <cfelseif len(trim(starttime)) EQ 2 AND NOT FindNoCase(":",starttime) AND NOT FindNoCase("am",starttime) AND NOT FindNoCase("pm",starttime) >
	        <cfset starttime = starttime&':00'>
	    </cfif>
	    <cfset starttime = timeformat(starttime,"HH:nn:ss")>

	    <cfif listLen(time,'-') EQ 2>
	        <cfset endtime = listGetAt(time, 2,'-')>
	        <cfif len(trim(endtime)) EQ 4 AND NOT FindNoCase(":",endtime) AND NOT FindNoCase("am",endtime) AND NOT FindNoCase("pm",endtime) >
	            <cfset endtime = insert(":", endtime, 2)>
	        <cfelseif len(trim(endtime)) EQ 1 AND NOT FindNoCase(":",endtime) AND NOT FindNoCase("am",endtime) AND NOT FindNoCase("pm",endtime) >
	            <cfset endtime = endtime&':00'>
	        <cfelseif len(trim(endtime)) EQ 2 AND NOT FindNoCase(":",endtime) AND NOT FindNoCase("am",endtime) AND NOT FindNoCase("pm",endtime) >
	            <cfset endtime = endtime&':00'>
	        </cfif>
	        <cfset endtime = timeformat(endtime,"HH:nn:ss")>
	    <cfelse>
	        <cfset endtime = starttime>
	    </cfif>

	    <cfset str = structNew()>
	    <cfset EarlyDateTime = "{ts '#DateFormat(cdate,'YYYY-MM-DD')# #TRIM(StartTime)#'}">
	    <cfset str.EarlyDateTime = dateFormat(EarlyDateTime,'YYYY-MM-DD')&"T"&timeFormat(EarlyDateTime,"HH:nn:ss")>

	    <cfif StartTime NEQ EndTime>
		    <cfset LateDateTime = "{ts '#DateFormat(cdate,'YYYY-MM-DD')# #TRIM(EndTime)#'}">
		    <cfset str.LateDateTime = dateFormat(LateDateTime,'YYYY-MM-DD')&"T"&timeFormat(LateDateTime,"HH:nn:ss")>
		</cfif>

    	<cfreturn str>
	</cffunction>

	<cffunction name="ITSWebservicesoap" returntype="any" access="remote" returnformat="wddx">
		<cfargument name="impref" type="any" required="true" />
		<cfargument name="postaction" type="any" required="true" />
		<cfargument name="ITSUsername" type="any" required="true" />
		<cfargument name="ITSPassword" type="any" required="true" />
		<cfargument name="ITSintegrationID" type="any" required="true" />
		<!---  add by sp --->
		<cfargument name="loadNumber" type="any" required="false" default="" />
		<!---  add by sp --->
		<cfargument name="LoadID" type="any" required="true" />
		<cfargument name="CompanyID" type="any" required="true" />
		<cfargument name="dsn" type="any" required="no" />
		<cfargument name="EmpID" type="any" required="true" />
		<cfargument name="IncludeCarrierRate" type="any" required="no" default="0" />
		<cfargument name="CARRIERRATE" default="0" type="any" required="no">

		<cftry>
			<cfoutput>

				<cfif structkeyexists(arguments,"dsn")>
					<cfset variables.dsn=arguments.dsn>
				<cfelse>
					<cfset variables.dsn=variables.dsn>
				</cfif>
				<!---  change by sp --->
				<cfset variables.loadnumber = arguments.impref >
				<cfif len(trim(arguments.loadNumber))>
					<cfset variables.loadnumber = arguments.loadNumber >
				</cfif>
				<cfquery name="vwLoadsITS" datasource="#variables.dsn#">
					select * from vwLoadsITS where LoadID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.LoadID#">
				</cfquery>
				<!---  change by sp --->

				<cfquery name="getLoadMultipleDates" datasource="#variables.dsn#">
					SELECT TOP 1 MultipleDates FROM LoadStops WHERE LoadID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.LoadID#"> AND LoadType=1 ORDER BY StopNo,LoadType
				</cfquery>

				<cfif vwLoadsITS.length eq 0  or  vwLoadsITS.length eq "">
					<cfset vwLoadsITS.length=1 />
				</cfif>
				<cfif vwLoadsITS.FullOrPartial is True>
					<cfset vwLoadsITS.FullOrPartial=False/>
				<cfelse>
					<cfset vwLoadsITS.FullOrPartial=True/>
				</cfif>
				<!---  add by sp --->
				<cfif not len(trim(vwLoadsITS.width))>
					<cfset vwLoadsITS.width = 0>
				</cfif>
				<!---  add by sp --->
				
				<cfif CARRIERRATE EQ "" OR NOT isnumeric(CARRIERRATE)>
					<cfset CARRIERRATE  = 0>
				</cfif>
			
			</cfoutput>
			<cfif listFindNoCase('A,U', arguments.postaction) AND (NOT len(trim(vwLoadsITS.DeliveryDate)) OR NOT len(trim(vwLoadsITS.PickupDate)))>
				<cfreturn "Unable to post to ITS. Please check Pickup/Delivery dates.">
			</cfif>
			<cfif arguments.postaction EQ 'A'>
				<!------Post Load to ITS----->
				<cfoutput>
					<cfsavecontent variable="soapHeaderPosttoITStxt">
						<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:v11="http://webservices.truckstop.com/v11" xmlns:web="http://schemas.datacontract.org/2004/07/WebServices" xmlns:web1="http://schemas.datacontract.org/2004/07/WebServices.Posting" xmlns:web2="http://schemas.datacontract.org/2004/07/WebServices.Objects" xmlns:truc="http://schemas.datacontract.org/2004/07/Truckstop2.Objects">
							<soapenv:Header/>
							<soapenv:Body>
								<v11:PostLoads>
									<v11:loads>
										<web:IntegrationId>#arguments.ITSintegrationID#</web:IntegrationId>
										<web:Password>#arguments.ITSPassword#</web:Password>
										<web:UserName>#arguments.ITSUsername#</web:UserName>
										<web1:Loads>
											<web2:Load>
												<web2:DeliveryDate>#dateformat(vwLoadsITS.DeliveryDate,'yyyy-mm-dd')#</web2:DeliveryDate>
												<web2:DeliveryTime>#vwLoadsITS.DeliveryTime#</web2:DeliveryTime>
												<web2:DestinationCity>#vwLoadsITS.DestCity#</web2:DestinationCity>
												<web2:DestinationState>#vwLoadsITS.DestState#</web2:DestinationState>
												<web2:IsFavorite>0</web2:IsFavorite>
												<web2:IsLoadFull>#vwLoadsITS.FullOrPartial#</web2:IsLoadFull>
												<web2:Length>#vwLoadsITS.Length#</web2:Length>
												<web2:LoadId>0</web2:LoadId>
												<web2:LoadNumber>#vwLoadsITS.ImportRef#</web2:LoadNumber>
												<web2:OriginCity>#vwLoadsITS.OriginCity#</web2:OriginCity>
												<web2:OriginState>#vwLoadsITS.OriginState#</web2:OriginState>
												<web2:PaymentAmount>#vwLoadsITS.PaymentAmount#</web2:PaymentAmount>
												<web2:PickUpDate>#dateformat(vwLoadsITS.PickupDate,'yyyy-mm-dd')#</web2:PickUpDate>
												<web2:PickUpTime>#vwLoadsITS.PickupTime#</web2:PickUpTime>
												<web2:Quantity>1</web2:Quantity>
												<web2:SpecInfo>#escapeSpecialCharacters(vwLoadsITS.Notes)#</web2:SpecInfo>
												<web2:TypeOfEquipment>#vwLoadsITS.TypeofEquipment#</web2:TypeOfEquipment>
												<web2:Weight>#vwLoadsITS.Weight#</web2:Weight>
												<web2:Width>#vwLoadsITS.Width#</web2:Width>
												<cfif arguments.IncludeCarrierRate EQ 1>
													<web2:CarrierRate>#arguments.CARRIERRATE#</web2:CarrierRate>
												<cfelse>
													<web2:CarrierRate>0</web2:CarrierRate>
												</cfif>
											</web2:Load>
											<cfif getLoadMultipleDates.recordcount>
												<cfif len(trim(vwLoadsITS.PickupDate)) AND len(trim(vwLoadsITS.DeliveryDate)) AND len(trim(getLoadMultipleDates.MultipleDates))>
													<cfset days = DateDiff('d', vwLoadsITS.PickupDate, vwLoadsITS.DeliveryDate)>
													<cfloop list="#getLoadMultipleDates.MultipleDates#" item="PickUpDate">
														<cfif DateCompare(PickUpDate, vwLoadsITS.PickupDate , 'd') NEQ 0>
															<cfset DeliveryDate = DateAdd('d', days, pickUpDate)>
															<web2:Load>
																<web2:DeliveryDate>#dateformat(DeliveryDate,'yyyy-mm-dd')#</web2:DeliveryDate>
																<web2:DeliveryTime>#vwLoadsITS.DeliveryTime#</web2:DeliveryTime>
																<web2:DestinationCity>#vwLoadsITS.DestCity#</web2:DestinationCity>
																<web2:DestinationState>#vwLoadsITS.DestState#</web2:DestinationState>
																<web2:IsFavorite>0</web2:IsFavorite>
																<web2:IsLoadFull>#vwLoadsITS.FullOrPartial#</web2:IsLoadFull>
																<web2:Length>#vwLoadsITS.Length#</web2:Length>
																<web2:LoadId>0</web2:LoadId>
																<web2:LoadNumber>#vwLoadsITS.ImportRef##dateformat(PickUpDate,'YYYYMMDD')#</web2:LoadNumber>
																<web2:OriginCity>#vwLoadsITS.OriginCity#</web2:OriginCity>
																<web2:OriginState>#vwLoadsITS.OriginState#</web2:OriginState>
																<web2:PaymentAmount>#vwLoadsITS.PaymentAmount#</web2:PaymentAmount>
																<web2:PickUpDate>#dateformat(PickUpDate,'yyyy-mm-dd')#</web2:PickUpDate>
																<web2:PickUpTime>#vwLoadsITS.PickupTime#</web2:PickUpTime>
																<web2:Quantity>1</web2:Quantity>
																<web2:SpecInfo>#escapeSpecialCharacters(vwLoadsITS.Notes)#</web2:SpecInfo>
																<web2:TypeOfEquipment>#vwLoadsITS.TypeofEquipment#</web2:TypeOfEquipment>
																<web2:Weight>#vwLoadsITS.Weight#</web2:Weight>
																<web2:Width>#vwLoadsITS.Width#</web2:Width>
																<cfif arguments.IncludeCarrierRate EQ 1>
																	<web2:CarrierRate>#arguments.CARRIERRATE#</web2:CarrierRate>
																<cfelse>
																	<web2:CarrierRate>0</web2:CarrierRate>
																</cfif>
															</web2:Load>
														</cfif>
													</cfloop>
												</cfif>
											</cfif>
										</web1:Loads>
									</v11:loads>
								</v11:PostLoads>
							</soapenv:Body>
						</soapenv:Envelope>
					</cfsavecontent>
				</cfoutput>

				<!--- Insert into ITS --->
				<cfhttp method="post" url="http://webservices.truckstop.com/V13/Posting/LoadPosting.svc" result="objGet">
					<cfhttpparam type="header" name="SOAPAction" value="http://webservices.truckstop.com/v11/ILoadPosting/PostLoads"/>
					<cfhttpparam type="xml"  value="#trim( soapHeaderPosttoITStxt )#" />
				</cfhttp>

				<cfif objGet.Statuscode EQ "200 OK">
					<cfset objGetITS =  objGet.filecontent />
					<cfset PostToITSResponse = xmlParse(objGetITS) />
					<cfset postAssetSuccess_res = XmlSearch(PostToITSResponse,"//*[name()='ErrorMessage']") />

					<cfif arrayLen(postAssetSuccess_res) NEQ 0>
						<!-----if fail----->
						<cfset sts='Fail' />
			   			<cfset Alertvar ="1" />

						<cfif postAssetSuccess_res[1].xmltext NEQ "">
							<cfset Alertvar = postAssetSuccess_res[1].xmltext >
						</cfif>

						<cfif Alertvar EQ  1>
							<cfset Alertvar="Your ITS Webservice status failed. 100" />
						</cfif>
					<cfelse>
						<!----if success---->
						<cfset sts='Success' />
						<cfset Alertvar="Successfully posted to ITS." />

						<cfquery name="ITSFlagInsert" datasource="#variables.dsn#">
							update Loads SET posttoITS = 1 
							<cfif arguments.IncludeCarrierRate EQ 1>
								,postCarrierRatetoITS = 1
							<cfelse>
                           		,postCarrierRatetoITS = 0
							</cfif>
							where loadid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.LoadID#">
						</cfquery>

						<!-----delete old asset from DB if any---->
						<cfquery name="GetTranceCoreDBcount" datasource="#variables.dsn#">
							delete from LoadPostEverywhereDetails where imprtref=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.impref#"> and From_web='ITS' and status='Success'
						</cfquery>
					</cfif>
					<!-----Insert new asset from DB if any---->
					<cfquery name="PEPinsert" datasource="#variables.dsn#">
						INSERT INTO LoadPostEverywhereDetails (Postrequest_text,Response_text,imprtref,From_web,status) 
						VALUES(
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#soapHeaderPosttoITStxt#">,
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#objGet.filecontent#">,
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.impref#">,
							'ITS',
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#sts#">)
					</cfquery>
				<cfelse>
					<cfset Alertvar="Connection failure in ITS. 101" />
				</cfif>

			<cfelseif arguments.postaction EQ 'U'>
				<!--- Update Post in ITS --->
				<cfif isDefined("form.oldshipperPickupDateMultiple") and len(trim(form.oldshipperPickupDateMultiple))>
					<cfset delLoadDates = ''>
					<cfloop list="#form.oldshipperPickupDateMultiple#" item="delDate">
						<cfif NOT ListContains('#getLoadMultipleDates.MultipleDates#', delDate)>
							<cfset delLoadDates = listAppend(delLoadDates, delDate)>
						</cfif>
					</cfloop>
					<cfif len(trim(delLoadDates))>
						<cfoutput>
							<cfsavecontent variable="soapHeaderDeleteITSTxt">
								<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:v11="http://webservices.truckstop.com/v11" xmlns:web="http://schemas.datacontract.org/2004/07/WebServices" xmlns:web1="http://schemas.datacontract.org/2004/07/WebServices.Posting" xmlns:arr="http://schemas.microsoft.com/2003/10/Serialization/Arrays">
									<soapenv:Header/>
									<soapenv:Body>
										<v11:DeleteLoadsByLoadNumber>
											<v11:deleteRequest>
												<web:IntegrationId>#arguments.ITSintegrationID#</web:IntegrationId>
												<web:Password>#arguments.ITSPassword#</web:Password>
												<web:UserName>#arguments.ITSUsername#</web:UserName>
												<web1:LoadNumbers>
													<cfloop list="#delLoadDates#" item="dLoadDt">
														<arr:string>#vwLoadsITS.ImportRef##dateformat(dLoadDt,'YYYYMMDD')#</arr:string>
													</cfloop>
												</web1:LoadNumbers>
											</v11:deleteRequest>
										</v11:DeleteLoadsByLoadNumber>
									</soapenv:Body>
								</soapenv:Envelope>
							</cfsavecontent>
						</cfoutput>
						<cfhttp method="post" url="http://webservices.truckstop.com/V13/Posting/LoadPosting.svc" result="objGetDel">
							<cfhttpparam type="header" name="SOAPAction" value="http://webservices.truckstop.com/v11/ILoadPosting/DeleteLoadsByLoadNumber"/>
							<cfhttpparam type="xml"  value="#trim(soapHeaderDeleteITSTxt)#" />
						</cfhttp>
					</cfif>
				</cfif>

				<cfoutput>
					<cfsavecontent variable="soapHeaderPosttoITSTxt">
						<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:v11="http://webservices.truckstop.com/v11" xmlns:web="http://schemas.datacontract.org/2004/07/WebServices" xmlns:web1="http://schemas.datacontract.org/2004/07/WebServices.Posting" xmlns:web2="http://schemas.datacontract.org/2004/07/WebServices.Objects" xmlns:truc="http://schemas.datacontract.org/2004/07/Truckstop2.Objects">
							<soapenv:Header/>
							<soapenv:Body>
								<v11:PostLoads>
									<v11:loads>
										<web:IntegrationId>#arguments.ITSintegrationID#</web:IntegrationId>
										<web:Password>#arguments.ITSPassword#</web:Password>
										<web:UserName>#arguments.ITSUsername#</web:UserName>
										<web1:Loads>
											<web2:Load>
												<web2:DeliveryDate>#dateformat(vwLoadsITS.DeliveryDate,'yyyy-mm-dd')#</web2:DeliveryDate>
												<web2:DeliveryTime>#vwLoadsITS.DeliveryTime#</web2:DeliveryTime>
												<web2:DestinationCity>#vwLoadsITS.DestCity#</web2:DestinationCity>
												<web2:DestinationState>#vwLoadsITS.DestState#</web2:DestinationState>
												<web2:IsFavorite>0</web2:IsFavorite>
												<web2:IsLoadFull>#vwLoadsITS.FullOrPartial#</web2:IsLoadFull>
												<web2:Length>#vwLoadsITS.Length#</web2:Length>
												<web2:LoadId>0</web2:LoadId>
												<web2:LoadNumber>#vwLoadsITS.ImportRef#</web2:LoadNumber>
												<web2:OriginCity>#vwLoadsITS.OriginCity#</web2:OriginCity>
												<web2:OriginState>#vwLoadsITS.OriginState#</web2:OriginState>
												<web2:PickUpDate>#dateformat(vwLoadsITS.PickupDate,'yyyy-mm-dd')#</web2:PickUpDate>
												<web2:PickUpTime>#vwLoadsITS.PickupTime#</web2:PickUpTime>
												<web2:Quantity>1</web2:Quantity>
												<web2:SpecInfo>#escapeSpecialCharacters(vwLoadsITS.Notes)#</web2:SpecInfo>											<web2:TypeOfEquipment>#vwLoadsITS.TypeofEquipment#</web2:TypeOfEquipment>
												<web2:Weight>#vwLoadsITS.Weight#</web2:Weight>
												<web2:Width>#vwLoadsITS.Width#</web2:Width>
												<cfif arguments.IncludeCarrierRate EQ 1>
													<web2:CarrierRate>#arguments.CARRIERRATE#</web2:CarrierRate>
												<cfelse>
													<web2:CarrierRate>0</web2:CarrierRate>
												</cfif>
											</web2:Load>

											<cfif getLoadMultipleDates.recordcount>
												<cfif len(trim(vwLoadsITS.PickupDate)) AND len(trim(vwLoadsITS.DeliveryDate)) AND len(trim(getLoadMultipleDates.MultipleDates))>
													<cfset days = DateDiff('d', vwLoadsITS.PickupDate, vwLoadsITS.DeliveryDate)>
													<cfloop list="#getLoadMultipleDates.MultipleDates#" item="PickUpDate">
														<cfif DateCompare(PickUpDate, vwLoadsITS.PickupDate , 'd') NEQ 0>
															<cfset DeliveryDate = DateAdd('d', days, pickUpDate)>
															<web2:Load>
																<web2:DeliveryDate>#dateformat(DeliveryDate,'yyyy-mm-dd')#</web2:DeliveryDate>
																<web2:DeliveryTime>#vwLoadsITS.DeliveryTime#</web2:DeliveryTime>
																<web2:DestinationCity>#vwLoadsITS.DestCity#</web2:DestinationCity>
																<web2:DestinationState>#vwLoadsITS.DestState#</web2:DestinationState>
																<web2:IsFavorite>0</web2:IsFavorite>
																<web2:IsLoadFull>#vwLoadsITS.FullOrPartial#</web2:IsLoadFull>
																<web2:Length>#vwLoadsITS.Length#</web2:Length>
																<web2:LoadId>0</web2:LoadId>
																<web2:LoadNumber>#vwLoadsITS.ImportRef##dateformat(PickUpDate,'YYYYMMDD')#</web2:LoadNumber>
																<web2:OriginCity>#vwLoadsITS.OriginCity#</web2:OriginCity>
																<web2:OriginState>#vwLoadsITS.OriginState#</web2:OriginState>
																<web2:PickUpDate>#dateformat(PickUpDate,'yyyy-mm-dd')#</web2:PickUpDate>
																<web2:PickUpTime>#vwLoadsITS.PickupTime#</web2:PickUpTime>
																<web2:Quantity>1</web2:Quantity>
																<web2:SpecInfo>#escapeSpecialCharacters(vwLoadsITS.Notes)#</web2:SpecInfo>											<web2:TypeOfEquipment>#vwLoadsITS.TypeofEquipment#</web2:TypeOfEquipment>
																<web2:Weight>#vwLoadsITS.Weight#</web2:Weight>
																<web2:Width>#vwLoadsITS.Width#</web2:Width>
																<cfif arguments.IncludeCarrierRate EQ 1>
																	<web2:CarrierRate>#arguments.CARRIERRATE#</web2:CarrierRate>
																<cfelse>
																	<web2:CarrierRate>0</web2:CarrierRate>
																</cfif>
															</web2:Load>
														</cfif>
													</cfloop>
												</cfif>
											</cfif>
										</web1:Loads>
									</v11:loads>
								</v11:PostLoads>
							</soapenv:Body>
						</soapenv:Envelope>
					</cfsavecontent>

				</cfoutput>
				<!--- Update to ITS --->
				<cfhttp method="post" url="http://webservices.truckstop.com/V13/Posting/LoadPosting.svc" result="objGet">
					<cfhttpparam type="header" name="SOAPAction" value= "http://webservices.truckstop.com/v11/ILoadPosting/PostLoads" />
					<cfhttpparam type="xml"  value="#trim(soapHeaderPosttoITSTxt)#" />
				</cfhttp>
				
				<cfif objGet.Statuscode EQ "200 OK">
					<cfset objGetITS =  objGet.filecontent />
					<cfset PostToITSResponse = xmlParse( objGetITS ) />
					<cfset updateAssetSuccess_res = XmlSearch(PostToITSResponse,"//*[name()='ErrorMessage']") />

					<cfif arrayLen(updateAssetSuccess_res) NEQ 0>
						<!--- If fail --->
						<cfset sts='Fail' />
						<cfset Alertvar =1 />

						<cfif updateAssetSuccess_res[1].XmlText NEQ "">
							<cfset Alertvar = updateAssetSuccess_res[1].XmlText/>
						</cfif>

						<cfif Alertvar EQ 1 >
							<cfset Alertvar="Your ITS Webservice status is Failed. 102" />
						</cfif>

						<cfquery name="ITSinsert" datasource="#variables.dsn#">
							INSERT INTO LoadPostEverywhereDetails (Postrequest_text,Response_text,imprtref,From_web,status) VALUES(
								<cfqueryparam cfsqltype="cf_sql_varchar" value="#soapHeaderPosttoITSTxt#">,
								<cfqueryparam cfsqltype="cf_sql_varchar" value="#objGet.filecontent#">,
								<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.impref#">,
								'ITS',
								<cfqueryparam cfsqltype="cf_sql_varchar" value="#sts#">)
						</cfquery>
					<cfelse>
						<!--- If success --->
						<cfset Alertvar	= "Successfully posted to ITS." />

						<cfquery name="ITSFlaginsert" datasource="#variables.dsn#">
							UPDATE Loads SET posttoITS = 1 
								<cfif arguments.IncludeCarrierRate EQ 1>
									,postCarrierRatetoITS = 1
								<cfelse>
									,postCarrierRatetoITS = 0
								</cfif>
							WHERE loadid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.LoadID#">
						</cfquery>

						<cfquery name="UpdateAsset" datasource="#variables.dsn#">
							UPDATE LoadPostEverywhereDetails
							SET
								Postrequest_text	= <cfqueryparam cfsqltype="cf_sql_varchar" value="#soapHeaderPosttoITSTxt#">,
								Response_text		= <cfqueryparam cfsqltype="cf_sql_varchar" value="#objGet.filecontent#">,
								created				= GETDATE()
							WHERE imprtref = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.impref#"> AND From_web = 'ITS' AND status = 'Success'
						</cfquery>
					</cfif>
				<cfelse>
					<cfset Alertvar="Connection failure in ITS. 103" />
				</cfif>

			<cfelseif arguments.postaction EQ 'D'>
				<cfoutput>
					<cfsavecontent variable="soapHeaderDeleteITSTxt">
						<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:v11="http://webservices.truckstop.com/v11" xmlns:web="http://schemas.datacontract.org/2004/07/WebServices" xmlns:web1="http://schemas.datacontract.org/2004/07/WebServices.Posting" xmlns:arr="http://schemas.microsoft.com/2003/10/Serialization/Arrays">
							<soapenv:Header/>
							<soapenv:Body>
								<v11:DeleteLoadsByLoadNumber>
									<v11:deleteRequest>
										<web:IntegrationId>#arguments.ITSintegrationID#</web:IntegrationId>
										<web:Password>#arguments.ITSPassword#</web:Password>
										<web:UserName>#arguments.ITSUsername#</web:UserName>
										<web1:LoadNumbers>
											<arr:string>#vwLoadsITS.ImportRef#</arr:string>
											<cfif getLoadMultipleDates.recordcount>
												<cfif len(trim(vwLoadsITS.PickupDate)) AND len(trim(vwLoadsITS.DeliveryDate)) AND len(trim(getLoadMultipleDates.MultipleDates))>
													<cfloop list="#getLoadMultipleDates.MultipleDates#" item="PickUpDate">
														<cfif DateCompare(PickUpDate, vwLoadsITS.PickupDate , 'd') NEQ 0>
															<arr:string>#vwLoadsITS.ImportRef##dateformat(PickUpDate,'YYYYMMDD')#</arr:string>
														</cfif>
													</cfloop>
												</cfif>
											</cfif>
										</web1:LoadNumbers>
									</v11:deleteRequest>
								</v11:DeleteLoadsByLoadNumber>
							</soapenv:Body>
						</soapenv:Envelope>
					</cfsavecontent>
				</cfoutput>

				<!--- Delete from ITS --->
				<cfhttp method="post" url="http://webservices.truckstop.com/V13/Posting/LoadPosting.svc" result="objGet">
					<cfhttpparam type="header" name="SOAPAction" value="http://webservices.truckstop.com/v11/ILoadPosting/DeleteLoadsByLoadNumber"/>
					<cfhttpparam type="xml"  value="#trim(soapHeaderDeleteITSTxt)#" />
				</cfhttp>
				
				<cfif objGet.Statuscode EQ "200 OK">
					<cfset textResponse = objget.filecontent>
					<cfset PostToITSResponse = xmlparse(textResponse)>
					<cfset deleteAssetSuccess_res = XmlSearch(PostToITSResponse,"//*[name()='ErrorMessage']") />

					<cfif arrayLen(deleteAssetSuccess_res) NEQ 0>
						<!----if Fail---->
						<cfset sts = 'Fail' />
						<cfset Alertvar="1" />

						<cfif deleteAssetSuccess_res[1].XmlText NEQ "">
							<cfset Alertvar = deleteAssetSuccess_res[1].XmlText/>
							<cfif trim(Alertvar) EQ 'Load does not exist.' >
								<cfquery name="ITSFlaginsert" datasource="#variables.dsn#">
									UPDATE Loads SET posttoITS = 0 ,postCarrierRatetoITS = 0
									WHERE loadid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.LoadID#">
								</cfquery>
							</cfif>
						</cfif>
						
						<cfif Alertvar EQ 1 >
							<cfset Alertvar="Your ITS Webservice status is Failed. 104" />
						</cfif>

						<cfquery name="ITSinsert" datasource="#variables.dsn#">
							INSERT INTO LoadPostEverywhereDetails (Postrequest_text,Response_text,imprtref,From_web,status) VALUES(
								<cfqueryparam cfsqltype="cf_sql_varchar" value="#soapHeaderDeleteITSTxt#">,
								<cfqueryparam cfsqltype="cf_sql_varchar" value="#objget.filecontent#">,
								<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.impref#">,
								'ITS',
								<cfqueryparam cfsqltype="cf_sql_varchar" value="#sts#">)
						</cfquery>
					<cfelse>

						<!----if Success---->
						<cfset sts = 'Success' />
						<cfset Alertvar = 'Load successfully removed from ITS.' />
						<cfquery name="ITSFlaginsert" datasource="#variables.dsn#">
							UPDATE Loads SET posttoITS = 0 
								<cfif arguments.IncludeCarrierRate EQ 1>
									,postCarrierRatetoITS = 0
								</cfif>
							WHERE loadid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.LoadID#">
						</cfquery>

						<cfquery name="ITSinsert" datasource="#variables.dsn#">
							DELETE FROM LoadPostEverywhereDetails WHERE imprtref = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.impref#"> AND From_web = 'ITS' AND status = 'Success'
						</cfquery>
					</cfif>
				<cfelse>
					<cfset Alertvar="Connection failure in ITS. 105" />
				</cfif>
			</cfif>

			<cfif Alertvar neq 1>
				<cfset Alertvar="ITS Says : "&Alertvar />
			</cfif>

			<cfif isdefined("Prev_sts")>
				<cfset Alertvar=Alertvar&"!!!" />
			</cfif>
			<cfreturn Alertvar />

			 <cfcatch type="any">
				<cfset Alertvar='Something went wrong. Unable post to ITS.' />
				<cfreturn Alertvar />
			</cfcatch>
		</cftry>
	</cffunction>

	<!-------------posttoITS WEBERVICE End----------------->

	<!-------------posteverywhereWEBERVICE----------------->

	<cffunction name="Posteverywhere" returntype="any" access="remote" returnformat="JSON">
		<cfargument name="impref" type="any" required="yes">
		<cfargument name="LoadID" type="any" required="yes">
		<cfargument name="POSTACTION" type="any" required="yes">
		<cfargument name="PEPcustomerKey" type="any" required="yes">
		<cfargument name="PEPsecretKey" type="any" required="yes">
		<cfargument name="dsn" type="any" required="no" />
		<cfargument name="CARRIERRATE" type="any" required="no" />
		<cfargument name="IncludeCarrierRate" type="numeric" required="no" default="0">
		
		<cfif structkeyexists(arguments,"dsn")>
			<cfset variables.dsn=arguments.dsn>
		<cfelse>
			<cfset variables.dsn=variables.dsn>
		</cfif>
		<cfquery name="ViewPostEveryWhere" datasource="#variables.dsn#">
			select * from vwLoadsPostEveryWhere where LoadID=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.LoadID#">
		</cfquery>
		<cfquery name="getLoadMultipleDates" datasource="#variables.dsn#">
			SELECT TOP 1 MultipleDates FROM LoadStops WHERE LoadID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.LoadID#"> AND LoadType=1 ORDER BY StopNo,LoadType
		</cfquery>
		<cfif ViewPostEveryWhere.length eq 0  or  ViewPostEveryWhere.length eq "">
			<cfset ViewPostEveryWhere.length=48>
		</cfif>
		<cfif ViewPostEveryWhere.FullOrPartial eq false  or  ViewPostEveryWhere.FullOrPartial eq "">
			<cfset FullOrPartial='Full'>
		<cfelse>
			<cfset FullOrPartial='Partial'>
		</cfif>
		<cfif len(trim(ReplaceNoCase(ReplaceNoCase(arguments.CARRIERRATE,',','','ALL'),'$','','ALL')))>
			<cfset CARRIERRATE = DecimalFormat(lsParseCurrency(arguments.CARRIERRATE)) >
		<cfelse>
			<cfset CARRIERRATE = DecimalFormat(0) >
		</cfif>
		<cfoutput>
			<cfsavecontent variable="strXML">
				<PostLoads.Many>
					<LoadDO>
						<postAction>#arguments.postaction#</postAction>
						<importRef>#ViewPostEveryWhere.ImportRef#</importRef>
						<originCity>#ViewPostEveryWhere.OriginCity#</originCity>
						<originState>#ViewPostEveryWhere.OriginState#</originState>
						<pickupDate>#dateformat(ViewPostEveryWhere.PickupDate,'YYYY-MM-DD')#</pickupDate>
						<destCity>#ViewPostEveryWhere.DestCity#</destCity>
						<destState>#ViewPostEveryWhere.DestState#</destState>
						<truckType>#ViewPostEveryWhere.TruckType#</truckType>
						<fullOrPartial>#FullOrPartial#</fullOrPartial>
						<length>#ViewPostEveryWhere.length#</length>
						<weight>#ViewPostEveryWhere.Weight#</weight>
						<cfif arguments.IncludeCarrierRate EQ 1><rate>#CARRIERRATE#</rate></cfif>
						<deliveryDate>#dateformat(ViewPostEveryWhere.FinalDelivDate,'YYYY-MM-DD')#</deliveryDate>
						<note>#replaceNoCase(replaceNoCase(ViewPostEveryWhere.NewNotes, chr(13), ' ','All'), chr(10), ' ','All')#</note>
						<comment></comment>
					</LoadDO>
					<cfif getLoadMultipleDates.recordcount>
						<cfif len(trim(ViewPostEveryWhere.PickupDate)) AND len(trim(ViewPostEveryWhere.FinalDelivDate)) AND len(trim(getLoadMultipleDates.MultipleDates))>
							<cfset days = DateDiff('d', ViewPostEveryWhere.PickupDate, ViewPostEveryWhere.FinalDelivDate)>
							<cfloop list="#getLoadMultipleDates.MultipleDates#" item="PickUpDateNew">
								<cfif DateCompare(PickUpDateNew, ViewPostEveryWhere.PickupDate , 'd') NEQ 0>
									<cfset DeliveryDate = DateAdd('d', days, PickUpDateNew)>
									<LoadDO>
										<postAction>#arguments.postaction#</postAction>
										<importRef>#ViewPostEveryWhere.ImportRef##dateformat(PickUpDateNew,'YYYYMMDD')#</importRef>
										<originCity>#ViewPostEveryWhere.OriginCity#</originCity>
										<originState>#ViewPostEveryWhere.OriginState#</originState>
										<pickupDate>#dateformat(PickUpDateNew,'YYYY-MM-DD')#</pickupDate>
										<destCity>#ViewPostEveryWhere.DestCity#</destCity>
										<destState>#ViewPostEveryWhere.DestState#</destState>
										<truckType>#ViewPostEveryWhere.TruckType#</truckType>
										<fullOrPartial>#FullOrPartial#</fullOrPartial>
										<length>#ViewPostEveryWhere.length#</length>
										<weight>#ViewPostEveryWhere.Weight#</weight>
										<cfif arguments.IncludeCarrierRate EQ 1><rate>#CARRIERRATE#</rate></cfif>
										<deliveryDate>#dateformat(DeliveryDate,'YYYY-MM-DD')#</deliveryDate>
										<note>#replaceNoCase(replaceNoCase(ViewPostEveryWhere.NewNotes, chr(13), ' ','All'), chr(10), ' ','All')#</note>
										<comment></comment>
									</LoadDO>
								</cfif>
							</cfloop>
						</cfif>
					</cfif>
					<cfif isDefined("form.oldshipperPickupDateMultiple") and len(trim(form.oldshipperPickupDateMultiple))>
						<cfloop list="#form.oldshipperPickupDateMultiple#" item="delDate">
							<cfif NOT ListContains('#getLoadMultipleDates.MultipleDates#', delDate)>
								<LoadDO>
									<postAction>D</postAction>
									<importRef>#ViewPostEveryWhere.ImportRef##dateformat(delDate,'YYYYMMDD')#</importRef>
									<originCity>#ViewPostEveryWhere.OriginCity#</originCity>
									<originState>#ViewPostEveryWhere.OriginState#</originState>
									<pickupDate>#dateformat(ViewPostEveryWhere.PickupDate,'YYYY-MM-DD')#</pickupDate>
									<destCity>#ViewPostEveryWhere.DestCity#</destCity>
									<destState>#ViewPostEveryWhere.DestState#</destState>
									<truckType>#ViewPostEveryWhere.TruckType#</truckType>
									<fullOrPartial>#FullOrPartial#</fullOrPartial>
									<length>#ViewPostEveryWhere.length#</length>
									<weight>#ViewPostEveryWhere.Weight#</weight>
									<cfif arguments.IncludeCarrierRate EQ 1><rate>#CARRIERRATE#</rate></cfif>
									<deliveryDate>#dateformat(ViewPostEveryWhere.FinalDelivDate,'YYYY-MM-DD')#</deliveryDate>
									<note>#replaceNoCase(replaceNoCase(ViewPostEveryWhere.NewNotes, chr(13), ' ','All'), chr(10), ' ','All')#</note>
									<comment></comment>
								</LoadDO>
							</cfif>
						</cfloop>
					</cfif>
				</PostLoads.Many>
			</cfsavecontent>
		</cfoutput>

	    <cfhttp method="post" url="https://post.loadboardnetwork.com/api/xml/post-loads/" useragent="#CGI.http_user_agent#" result="objGet">
	    	<cfhttpparam type="HEADER" name="Content-Type" value="application/xml">
			<cfhttpparam type="url" name="ServiceKey" value="#arguments.PEPsecretKey#"/>
			<cfhttpparam type="url" name="CustomerKey"  value="#arguments.PEPcustomerKey#"/>
			<cfhttpparam type="url"  name="ServiceAction"  value="Many" />
			<cfhttpparam type="body" value="#strXML.Trim()#"/>
		</cfhttp>

		<cfset test=#findnocase("APPROVED",objGet.FileContent)# >
		<cfif test neq 0>
			<cfif arguments.postaction EQ 'D'>
				<cfset Alertvar="Load successfully removed from Post Everywhere.">
				<cfquery name="PEPdelete" datasource="#variables.dsn#">
					UPDATE Loads SET iSPost = 0 WHERE loadid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.LoadID#">
				</cfquery>
			<cfelse>
				<cfset Alertvar="Load successfully posted to Post Everywhere.">
				<cfquery name="PEPinsert" datasource="#variables.dsn#">
					UPDATE Loads SET iSPost = 1 WHERE loadid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.LoadID#">
				</cfquery>
			</cfif>
		<cfelse>
			<cftry>
				<cfset techMsg = XmlSearch(objGet.FileContent,"//*[name()='techMsg']")>
				<cfcatch>
					<cfdocument format="pdf" filename="C:\pdf\PEPDebug_#DateTimeFormat(now(),"YYYY_MM_dd_HH_nn_ss_l")#.pdf" overwrite="true">
						<cfdump var="#objGet#">
						<cfdump var="#cfcatch#">
					</cfdocument>
				</cfcatch>
			</cftry>

			<cfif #findnocase("FAILED",objGet.FileContent)# neq 0 and isArray(techMsg) and arrayLen(techMsg) neq 0>
				<cfset Alertvar="Posting FAILED and returned this error: #techMsg[1].XmlText#">
			<cfelseif #findnocase("JPE01149",objGet.FileContent)# neq 0>
				<cfset Alertvar="Posting FAILED and returned this error: Missing or invalid Web Services Key">
			<cfelseif  #findnocase("JPE05900",objGet.FileContent)# neq 0>
				<cfset Alertvar="Posting FAILED and returned this error: Please enter a valid length between 1 and 57">
			<cfelseif  #findnocase("JPE01133",objGet.FileContent)# neq 0>
				<cfset Alertvar="Posting FAILED and returned this error: There was an error processing your request">
			<cfelse>
				<cfset Alertvar="Posting FAILED and returned this error: There was an error processing your request">
			</cfif>

			<cfquery name="PEPinsert" datasource="#variables.dsn#">
				UPDATE Loads SET iSPost = 0 WHERE loadid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.LoadID#">
			</cfquery>
		</cfif>

		<cfquery name="PEPinsert" datasource="#variables.dsn#">
			insert into LoadPostEverywhereDetails (Postrequest_text,Response_text,imprtref) 
				values(
					<cfqueryparam value="#strXML.Trim()#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#objGet.FileContent#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.impref#" cfsqltype="cf_sql_varchar">
					)
		</cfquery>
		<cfif Alertvar neq 1>
			<cfset Alertvar="Post Everywhere Says : "&Alertvar>
		</cfif>

		<cfreturn Alertvar >

	</cffunction>

	<!------------------posteverywhere end---------->

	<!---------------Begin:DirectFreight webservice---->
	<cffunction name="DirectFreightLoadboard" returntype="any" access="remote" returnformat="json">
		<cfargument name="impref" type="any" required="true" />
		<cfargument name="LoadID" type="any" required="true" />
		<cfargument name="DirectFreightLoadboardUserName" type="any" required="true" />
		<cfargument name="DirectFreightLoadboardPassword" type="any" required="true" />
		<cfargument name="POSTMETHOD" type="any" required="true" />
		<cfargument name="IncludeCarierRate" default="0" type="any" required="no">
		<cfargument name="CARRIERRATE" default="0" type="any" required="no">
		<cfargument name="dsn" type="any" required="no" />
		<cftry>
			
			<cfif structkeyexists(arguments,"dsn")>
				<cfset variables.dsn=arguments.dsn>
			<cfelse>
				<cfset variables.dsn=variables.dsn>
			</cfif>

			<cfset APIToken = "015f303e2c3c329b69ed06f21deaf6d2e1fab1c3">
			<!--- Login --->
			<cfset loginBody = structNew()>
			<cfset loginBody['login'] = arguments.DirectFreightLoadboardUserName>
			<cfset loginBody['realm'] = "email">
			<cfset loginBody['secret'] = arguments.DirectFreightLoadboardPassword>

			<cfhttp method="post" url="https://api.directfreight.com/v1/end_user_authentications/" result="DirectFreightLogin">
				<cfhttpparam type="header" name="Accept"  value="application/json" />
				<cfhttpparam type="header" name="Content-Type"  value="application/json" />
				<cfhttpparam type="header" name="api-token"  value="#APIToken#" />
				<cfhttpparam type="body"  value="#serializeJSON(loginBody)#" />
			</cfhttp>

			<!--- Login --->
			<cfif DirectFreightLogin.Statuscode EQ '201 Created'>

				<cfset LoginContent = DeSerializeJSON(DirectFreightLogin.FileContent)>
				<cfset endUserToken = LoginContent['end-user-token']>
				<cfquery name="getLoadMultipleDates" datasource="#variables.dsn#">
					SELECT TOP 1 MultipleDates FROM LoadStops WHERE LoadID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.LoadID#"> AND LoadType=1 ORDER BY StopNo,LoadType
				</cfquery>
				<cfquery name="getLoadDetailForDirectFreightLoadboard" datasource="#variables.dsn#">
						SELECT * FROM vwLoadsDirectFreight WHERE LoadID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.LoadID#">
					</cfquery>
				<cfif listFind("POST,PATCH", arguments.POSTMETHOD)>
					<cfif isDefined("form.oldshipperPickupDateMultiple") and len(trim(form.oldshipperPickupDateMultiple))>
						<cfset custom_id = ''>
						<cfloop list="#form.oldshipperPickupDateMultiple#" item="delDate">
							<cfif NOT ListContains('#getLoadMultipleDates.MultipleDates#', delDate)>
								<cfif DateCompare(delDate, getLoadDetailForDirectFreightLoadboard.NewPickupDate , 'd') NEQ 0>
									<cfset custom_id = listAppend(custom_id, "custom_id=LM#getLoadDetailForDirectFreightLoadboard.ImportRef##DateFormat(delDate,'YYYYMMDD')#",'&')>
								</cfif>
							</cfif>
						</cfloop>
						<cfif len(trim(custom_id))>
							<!--- Begin : Delete --->
							<cfhttp method="DELETE" url="https://api.directfreight.com/v1/postings/loads/?#custom_id#">
								<cfhttpparam type="header" name="Content-Type"  value="application/json" />
								<cfhttpparam type="header" name="api-token"  value="#APIToken#" />
								<cfhttpparam type="header" name="end-user-token"  value="#endUserToken#" />
							</cfhttp>
							<!--- End : Delete --->
						</cfif>
					</cfif>

					<cfset load = structNew()>
					<cfset load['custom_id'] = 'LM#getLoadDetailForDirectFreightLoadboard.ImportRef#'>

					<cfif (arguments.POSTMETHOD EQ "POST") OR (arguments.POSTMETHOD EQ "PATCH" AND Len(trim(getLoadDetailForDirectFreightLoadboard.ShipperCity)))>
							<cfset load['origin_city'] = getLoadDetailForDirectFreightLoadboard.ShipperCity>
					</cfif>

					<cfif (arguments.POSTMETHOD EQ "POST") OR (arguments.POSTMETHOD EQ "PATCH" AND Len(trim(getLoadDetailForDirectFreightLoadboard.ShipperState)))>
							<cfset load['origin_state'] = getLoadDetailForDirectFreightLoadboard.ShipperState>
					</cfif>

					<cfif len(getLoadDetailForDirectFreightLoadboard.NewPickupDate)>
						<cfset load['ship_date'] = dateFormat(getLoadDetailForDirectFreightLoadboard.NewPickupDate,'yyyy-mm-dd')>
					</cfif>

					<cfif len(getLoadDetailForDirectFreightLoadboard.Length) AND isNumeric(getLoadDetailForDirectFreightLoadboard.Length)>
						<cfset load['length'] = getLoadDetailForDirectFreightLoadboard.Length>
					</cfif>

					<cfif len(getLoadDetailForDirectFreightLoadboard.Width) AND isNumeric(getLoadDetailForDirectFreightLoadboard.Width)>
						<cfset load['width'] = getLoadDetailForDirectFreightLoadboard.Width>
					</cfif>

					<cfif len(getLoadDetailForDirectFreightLoadboard.Weight) AND isNumeric(getLoadDetailForDirectFreightLoadboard.Weight)>
						<cfset load['weight'] = getLoadDetailForDirectFreightLoadboard.Weight>
					</cfif>

					<cfif getLoadDetailForDirectFreightLoadboard.IsPartial EQ 1>
						<cfset load['full_load'] = false>
					</cfif>

					<cfset trailertype = listToArray(getLoadDetailForDirectFreightLoadboard.DirectFreightCode,"/")>

					<cfset load['trailer_type'] = trailertype>

					<cfif (arguments.POSTMETHOD EQ "POST") OR (arguments.POSTMETHOD EQ "PATCH" AND Len(trim(getLoadDetailForDirectFreightLoadboard.ConsigneeCity)))>
						<cfset load['destination_city'] = getLoadDetailForDirectFreightLoadboard.ConsigneeCity>
					</cfif>
					<cfif (arguments.POSTMETHOD EQ "POST") OR (arguments.POSTMETHOD EQ "PATCH" AND Len(trim(getLoadDetailForDirectFreightLoadboard.ConsigneeState)))>
						<cfset load['destination_state'] = getLoadDetailForDirectFreightLoadboard.ConsigneeState>
					</cfif>
					<cfif len(getLoadDetailForDirectFreightLoadboard.NewDeliveryDate)>
						<cfset load['receive_date'] = dateFormat(getLoadDetailForDirectFreightLoadboard.NewDeliveryDate,'yyyy-mm-dd')>
					</cfif>
					<cfif arguments.IncludeCarierRate>
						<cfset load['pay_rate'] = replaceNoCase(arguments.CARRIERRATE, '$', '')>
					<cfelse>
						<cfset load['pay_rate'] = 0>
					</cfif>

					<cfif len(getLoadDetailForDirectFreightLoadboard.comment) AND isNumeric(getLoadDetailForDirectFreightLoadboard.comment)>
						<cfset load['comment'] = getLoadDetailForDirectFreightLoadboard.comment>
					</cfif>

					<cfset list = arrayNew(1)>
					<cfset arrayAppend(list, load)>

					<cfif getLoadMultipleDates.recordcount>
						<cfif len(trim(getLoadDetailForDirectFreightLoadboard.NewPickupDate)) AND len(trim(getLoadDetailForDirectFreightLoadboard.NewDeliveryDate)) AND len(trim(getLoadMultipleDates.MultipleDates))>
							<cfset days = DateDiff('d', getLoadDetailForDirectFreightLoadboard.NewPickupDate, getLoadDetailForDirectFreightLoadboard.NewDeliveryDate)>
							<cfloop list="#getLoadMultipleDates.MultipleDates#" item="pickUpDate">
								<cfif DateCompare(pickUpDate, getLoadDetailForDirectFreightLoadboard.NewPickupDate , 'd') NEQ 0>
									<cfset deliveryDate = DateAdd('d', days, pickUpDate)>
									<cfset load = structNew()>
									<cfset load['custom_id'] = 'LM#getLoadDetailForDirectFreightLoadboard.ImportRef##DateFormat(pickUpDate,'YYYYMMDD')#'>

									<cfif (arguments.POSTMETHOD EQ "POST") OR (arguments.POSTMETHOD EQ "PATCH" AND Len(trim(getLoadDetailForDirectFreightLoadboard.ShipperCity)))>
											<cfset load['origin_city'] = getLoadDetailForDirectFreightLoadboard.ShipperCity>
									</cfif>

									<cfif (arguments.POSTMETHOD EQ "POST") OR (arguments.POSTMETHOD EQ "PATCH" AND Len(trim(getLoadDetailForDirectFreightLoadboard.ShipperState)))>
											<cfset load['origin_state'] = getLoadDetailForDirectFreightLoadboard.ShipperState>
									</cfif>

									<cfif len(getLoadDetailForDirectFreightLoadboard.NewPickupDate)>
										<cfset load['ship_date'] = dateFormat(pickUpDate,'yyyy-mm-dd')>
									</cfif>

									<cfset trailertype = listToArray(getLoadDetailForDirectFreightLoadboard.DirectFreightCode,"/")>
									<cfset load['trailer_type'] = trailertype>

									<cfif (arguments.POSTMETHOD EQ "POST") OR (arguments.POSTMETHOD EQ "PATCH" AND Len(trim(getLoadDetailForDirectFreightLoadboard.ConsigneeCity)))>
										<cfset load['destination_city'] = getLoadDetailForDirectFreightLoadboard.ConsigneeCity>
									</cfif>
									<cfif (arguments.POSTMETHOD EQ "POST") OR (arguments.POSTMETHOD EQ "PATCH" AND Len(trim(getLoadDetailForDirectFreightLoadboard.ConsigneeState)))>
										<cfset load['destination_state'] = getLoadDetailForDirectFreightLoadboard.ConsigneeState>
									</cfif>
									<cfif len(getLoadDetailForDirectFreightLoadboard.NewDeliveryDate)>
										<cfset load['receive_date'] = dateFormat(deliveryDate,'yyyy-mm-dd')>
									</cfif>
									<cfif arguments.IncludeCarierRate>
										<cfset load['pay_rate'] = replaceNoCase(arguments.CARRIERRATE, '$', '')>
									<cfelse>
										<cfset load['pay_rate'] = 0>
									</cfif>
									<cfif len(getLoadDetailForDirectFreightLoadboard.comment) AND isNumeric(getLoadDetailForDirectFreightLoadboard.comment)>
										<cfset load['comment'] = getLoadDetailForDirectFreightLoadboard.comment>
									</cfif>
									<cfset arrayAppend(list, load)>
								</cfif>
							</cfloop>
						</cfif>
					</cfif>

					<cfset data = structNew()>
					<cfset data['list'] = list>
					<!--- Begin : Create/Update --->
					<cfhttp method="#arguments.POSTMETHOD#" url="https://api.directfreight.com/v1/postings/loads/" result="DirectFreightPost">
						<cfhttpparam type="header" name="Content-Type"  value="application/json" />
						<cfhttpparam type="header" name="api-token"  value="#APIToken#" />
						<cfhttpparam type="header" name="end-user-token"  value="#endUserToken#" />
						<cfhttpparam type="body"  value="#serializeJSON(data)#" />
					</cfhttp>
					<!--- End : Create/Update --->
					<cfset postDetails = DeSerializeJSON(DirectFreightPost.Filecontent)>
					<cfif NOT StructIsEmpty(postDetails.list[1]) AND postDetails.list[1].status EQ 'Error'>
						<cfset Alertvar="Direct Freight Loadboard Says : #postDetails.list[1].description#.">
					<cfelse>
						<cfquery name="updLoad" datasource="#variables.dsn#">
							UPDATE Loads SET 
							posttoDirectFreight = 1 
							<cfif arguments.IncludeCarierRate>
								,postCarrierRatetoDirectFreight = 1
							<cfelse>
								,postCarrierRatetoDirectFreight = 0
							</cfif>
							WHERE loadid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.LoadID#">
						</cfquery>
						<cfif arguments.POSTMETHOD EQ 'POST'>
							<cfset Alertvar="Direct Freight Loadboard Says : Load posted successfully.">
						<cfelse>
							<cfset Alertvar="Direct Freight Loadboard Says : Load updated successfully.">
						</cfif>
					</cfif>
				<cfelse>
					<cfset custom_id = 'custom_id=LM#getLoadDetailForDirectFreightLoadboard.ImportRef#'>
					<cfif getLoadMultipleDates.recordcount AND len(trim(getLoadMultipleDates.MultipleDates))>
						<cfloop list="#getLoadMultipleDates.MultipleDates#" item="pickUpDate">
							<cfset custom_id = listAppend(custom_id, "custom_id=LM#getLoadDetailForDirectFreightLoadboard.ImportRef##DateFormat(pickUpDate,'YYYYMMDD')#",'&')>
						</cfloop>
					</cfif>
					<!--- Begin : Delete --->
					<cfhttp method="DELETE" url="https://api.directfreight.com/v1/postings/loads/?#custom_id#">
						<cfhttpparam type="header" name="Content-Type"  value="application/json" />
						<cfhttpparam type="header" name="api-token"  value="#APIToken#" />
						<cfhttpparam type="header" name="end-user-token"  value="#endUserToken#" />
					</cfhttp>
					<!--- End : Delete --->
					<cfquery name="updLoad" datasource="#variables.dsn#">
						UPDATE Loads SET 
						posttoDirectFreight = 0,
						postCarrierRatetoDirectFreight = 0
						WHERE loadid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.LoadID#">
					</cfquery>
					<cfset Alertvar="Direct Freight Loadboard Says : Load deleted successfully.">
				</cfif>
				<!--- LogOut --->
				<cfhttp method="delete" url="https://api.directfreight.com/v1/end_user_authentications/">
					<cfhttpparam type="header" name="api-token"  value="#APIToken#" />
					<cfhttpparam type="header" name="end-user-token"  value="#endUserToken#" />
				</cfhttp>
				<!--- LogOut --->
				<cfreturn Alertvar>
			<cfelseif DirectFreightLogin.Statuscode EQ '422 Unprocessable Entity'>
				<cfset Alertvar="Direct Freight Loadboard Says : Login Failure.">
				<cfreturn Alertvar>
			<cfelse>
				<cfset Alertvar="Direct Freight Loadboard Says : Connection Failure.">
				<cfreturn Alertvar>
			</cfif>
			
			<cfcatch>
				<cfset Alertvar="Direct Freight Loadboard Says : Something went wrong.">
				<cfreturn Alertvar>
			</cfcatch>
		</cftry>

		
	</cffunction>
	<!---------------End:DirectFreight webservice---->

	<!---------------Transcore 360 webservice---->

	<cffunction name="Transcore360Webservice" returntype="any" access="remote" returnformat="wddx">
		<cfargument name="impref" type="any" required="true" />
		<cfargument name="LoadID" type="any" required="true" />
		<cfargument name="postaction" type="any" required="true" />
		<cfargument name="trans360Usename" type="any" required="true" />
		<cfargument name="trans360Password" type="any" required="true" />
		<cfargument name="dsn" type="any" required="no" />
		<cfargument name="IncludeCarierRate" default="0" type="any" required="no">
		<cfargument name="CARRIERRATE" default="0" type="any" required="no">
		<cfargument name="Refreshed" default="0" type="any" required="no">

		<cfparam name="Alertvar" default="1">
		<cfparam name="variables.EquipmentName" default="">
		<cfparam name="variables.OriginCity" default="">
		<cfparam name="variables.OriginState" default="">
		<cfparam name="variables.DestCity" default="">
		<cfparam name="variables.DestState" default="">
		<cfparam name="variables.Weight" default="0">
		<cfparam name="variables.Notes" default="">
		<cfparam name="variables.length" default="1">
		<cfparam name="variables.PickupDate" default="">
		<cfparam name="variables.FinalDelivDate" default="">
		<cfparam name="variables.TotalCarrierCharges" default="0">
		<cftry>
			<cfoutput>
				<cfif structkeyexists(arguments,"dsn")>
					<cfset variables.dsn=arguments.dsn>
				<cfelse>
					<cfset variables.dsn=variables.dsn>
				</cfif>
				<cfquery name="ViewPostEveryWhere" datasource="#variables.dsn#">
					select * from vwLoadsTranscore where LoadID=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.LoadID#">
				</cfquery>
				<cfif ViewPostEveryWhere.recordcount>
					<cfset variables.EquipmentName=ViewPostEveryWhere.EquipmentName>
					<cfset variables.OriginCity=ViewPostEveryWhere.OriginCity>
					<cfset variables.OriginState=ViewPostEveryWhere.OriginState>
					<cfset variables.DestCity=ViewPostEveryWhere.DestCity>
					<cfset variables.DestState=ViewPostEveryWhere.DestState>
					<cfset variables.Weight=ViewPostEveryWhere.Weight>
					<cfset variables.PickupDate=ViewPostEveryWhere.PickupDate>
					<cfset variables.FinalDelivDate=ViewPostEveryWhere.FinalDelivDate>
					<cfset variables.length=ViewPostEveryWhere.length>
					<cfset variables.Notes=ViewPostEveryWhere.Notes>
					<cfset variables.TotalCarrierCharges=ViewPostEveryWhere.TotalCarrierCharges>
				</cfif>
				<cfif ViewPostEveryWhere.length eq 0  or  ViewPostEveryWhere.length eq "">
					<cfset ViewPostEveryWhere.length=1 />
				</cfif>

				<cfif ViewPostEveryWhere.FullOrPartial eq false  or  ViewPostEveryWhere.FullOrPartial eq "">
					<cfset FullOrPartial='false' />
				<cfelse>
					<cfset FullOrPartial='true' />
				</cfif>

				<cfquery name="qGetTranscoreSession" datasource="#variables.dsn#">
					select transcorePrimaryKey,transcoreSecondaryKey,transcoreTimeSessionExp,DATEDIFF(hour,getdate(),transcoreTimeSessionExp) AS ExpHrs From Employees where trans360Usename = <cfqueryparam cfsqltype="cf_sql_varchar" value="#trans360Usename#"> and trans360Password=<cfqueryparam cfsqltype="cf_sql_varchar" value="#trans360Password#">
				</cfquery>
				<cfquery name="getLoadMultipleDates" datasource="#variables.dsn#">
					SELECT TOP 1 MultipleDates FROM LoadStops WHERE LoadID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.LoadID#"> AND LoadType=1 ORDER BY StopNo,LoadType
				</cfquery>
				<cfif qGetTranscoreSession.ExpHrs GT 1>
					<cfset arr_primary		= arrayNew(1)>
					<cfset arr_secondary	= arrayNew(1)>
					<cfset var priStruct = structNew()>
					<cfset priStruct['XMLText'] = qGetTranscoreSession.transcorePrimaryKey>
					<cfset arrayAppend(arr_primary, priStruct)>
					<cfset var secStruct = structNew()>
					<cfset secStruct['XMLText'] = qGetTranscoreSession.transcoreSecondaryKey>
					<cfset arrayAppend(arr_secondary, secStruct)>
					<cfset session.primaryKey	= arr_primary />
					<cfset session.SeconKey		= arr_secondary />
				<cfelse>
					<!------login request----->
					<cfsavecontent variable="soapHeaderTransCoreTxt">
						<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:tcor="http://www.tcore.com/TcoreHeaders.xsd" xmlns:tcor1="http://www.tcore.com/TcoreTypes.xsd" xmlns:tfm="http://www.tcore.com/TfmiFreightMatching.xsd">
							<soapenv:Header>
								<tcor:sessionHeader soapenv:mustUnderstand="1">
									<tcor:sessionToken>
										<tcor1:primary></tcor1:primary>
										<tcor1:secondary></tcor1:secondary>
									</tcor:sessionToken>
								</tcor:sessionHeader>
								<tcor:correlationHeader soapenv:mustUnderstand="0">
								</tcor:correlationHeader>
									<tcor:applicationHeader soapenv:mustUnderstand="0">
									<tcor:application>TFMI</tcor:application>
									<tcor:applicationVersion>2</tcor:applicationVersion>
								</tcor:applicationHeader>
							</soapenv:Header>
							<soapenv:Body>
								<tfm:loginRequest>
									<tfm:loginOperation>
										<tfm:loginId>#trans360Usename#</tfm:loginId>
										<tfm:password>#trans360Password#</tfm:password>
										<tfm:thirdPartyId>webersys</tfm:thirdPartyId>
										<tfm:apiVersion>2</tfm:apiVersion>
									</tfm:loginOperation>
								</tfm:loginRequest>
							</soapenv:Body>
						</soapenv:Envelope>
					</cfsavecontent>

					<!--- LIVE URL --->
					<cfhttp method="post" url="http://www.transcoreservices.com:8000/TfmiRequest" result="TranscoreData360">
						<cfhttpparam type="xml"  value="#trim( soapHeaderTransCoreTxt )#" />
					</cfhttp>
						
					<cfset soapResponse = xmlParse( TranscoreData360.FileContent ) />
					<cfdocument format="pdf" filename="C:\pdf\DAT#arguments.impref#.pdf" overwrite="true">
						<cfdump var="#soapResponse#">
					</cfdocument>

					<cfset arr_primary		= XmlSearch(soapResponse,"//*[name()='tcor:primary']")>
					<cfset arr_secondary	= XmlSearch(soapResponse,"//*[name()='tcor:secondary']")>
					<cfif arrayLen(arr_primary) AND  arrayLen(arr_secondary)>
						<cfset session.primaryKey	= arr_primary />
						<cfset session.SeconKey		= arr_secondary />
						<cfset session.timesession_exp = XmlSearch(soapResponse,"//*[name()='tfm:expiration']") />
						<cfquery name="qUpdTranscoreSession" datasource="#variables.dsn#">
							Update Employees
							SET transcorePrimaryKey=<cfqueryparam cfsqltype="cf_sql_varchar"value="#session.primaryKey[1].XmlText#">
								,transcoreSecondaryKey=<cfqueryparam cfsqltype="cf_sql_varchar"value="#session.SeconKey[1].XmlText#">
								,transcoreTimeSessionExp=<cfqueryparam cfsqltype="cf_sql_timestamp" value="#replaceNoCase(replaceNoCase(session.timesession_exp[1].XMLText, "T", " "), "Z", "")#">
							where trans360Usename = <cfqueryparam cfsqltype="cf_sql_varchar"value="#trans360Usename#"> and trans360Password=<cfqueryparam cfsqltype="cf_sql_varchar"value="#trans360Password#">
						</cfquery>
					<cfelse>
						<cfset arr_error	= XmlSearch(soapResponse,"//*[name()='tcor:message']")>
						<cfif arrayLen(arr_error)>
							<cfset Alertvar= "Transcore Says : "&arr_error[1].XmlText>
						<cfelse>
							<cfset Alertvar='Transcore connection failure error. Call Tech Support for more assistance.' />
						</cfif>
						<cfreturn Alertvar />
					</cfif>
					<!------End login request----->
				</cfif>
			</cfoutput>
	
			<cftransaction>
				<cfif arguments.postaction EQ 'D'><!--- Delete from Tanscore360 --->
					<cfquery name="GetTranceCoreDBcount" datasource="#variables.dsn#">
						SELECT imprtref FROM LoadPostEverywhereDetails WHERE (imprtref=<cfqueryparam cfsqltype="cf_sql_varchar" value="#ViewPostEveryWhere.ImportRef#"> OR imprtref=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.impref#">) AND From_web='Tc360' AND status='success'
					</cfquery>

					<cfif GetTranceCoreDBcount.recordcount GT 0>
						<!-----Delete asset from TranceCore---->
						<cfoutput>
							<cfsavecontent variable="soapHeaderDelAsstCoreTxt">
								<Envelope
									xmlns="http://schemas.xmlsoap.org/soap/envelope/"
									xmlns:tcor="http://www.tcore.com/TcoreHeaders.xsd"
									xmlns:tcor1="http://www.tcore.com/TcoreTypes.xsd"
									xmlns:tfm="http://www.tcore.com/TfmiFreightMatching.xsd">
									<Header>
										<tcor:sessionHeader>
											<tcor:sessionToken>
												<tcor1:primary>#trim(session.primaryKey[1].XmlText)#</tcor1:primary>
												<tcor1:secondary>#trim(session.SeconKey[1].XmlText)#</tcor1:secondary>
											</tcor:sessionToken>
										</tcor:sessionHeader>
									</Header>
									<Body>
										<tfm:deleteAssetRequest>
											<tfm:deleteAssetOperation>
												<tfm:deleteAssetByPostersReferenceId>
													<tfm:postersReferenceId>#ViewPostEveryWhere.ImportRef#</tfm:postersReferenceId>
												</tfm:deleteAssetByPostersReferenceId>
											</tfm:deleteAssetOperation>
										</tfm:deleteAssetRequest>
									</Body>
								</Envelope>
							</cfsavecontent>
						</cfoutput>

						<!--- LIVE URL --->
						<cfhttp method="post" url="http://www.transcoreservices.com:8000/TfmiRequest" result="searchlookup_res">
							<cfhttpparam type="xml"  value="#trim( soapHeaderDelAsstCoreTxt )#" />
						</cfhttp>

						<cfif getLoadMultipleDates.recordcount>
							<cfif len(trim(getLoadMultipleDates.MultipleDates))>
								<cfloop list="#getLoadMultipleDates.MultipleDates#" item="delDate">
									<cfif DateCompare(delDate, variables.PickupDate , 'd') NEQ 0>
										<cfoutput>
											<cfsavecontent variable="soapHeaderDelAsstCoreTxt">
												<Envelope
													xmlns="http://schemas.xmlsoap.org/soap/envelope/"
													xmlns:tcor="http://www.tcore.com/TcoreHeaders.xsd"
													xmlns:tcor1="http://www.tcore.com/TcoreTypes.xsd"
													xmlns:tfm="http://www.tcore.com/TfmiFreightMatching.xsd">
													<Header>
														<tcor:sessionHeader>
															<tcor:sessionToken>
																<tcor1:primary>#trim(session.primaryKey[1].XmlText)#</tcor1:primary>
																<tcor1:secondary>#trim(session.SeconKey[1].XmlText)#</tcor1:secondary>
															</tcor:sessionToken>
														</tcor:sessionHeader>
													</Header>
													<Body>
														<tfm:deleteAssetRequest>
															<tfm:deleteAssetOperation>
																<tfm:deleteAssetByPostersReferenceId>
																	<tfm:postersReferenceId>#left(URLEncodedFormat(ToBase64(Encrypt(ViewPostEveryWhere.ImportRef, dateformat(delDate,'YYYYMMDD')))),8)#</tfm:postersReferenceId>
																</tfm:deleteAssetByPostersReferenceId>
															</tfm:deleteAssetOperation>
														</tfm:deleteAssetRequest>
													</Body>
												</Envelope>
											</cfsavecontent>
										</cfoutput>
										<!--- LIVE URL --->
										<cfhttp method="post" url="http://www.transcoreservices.com:8000/TfmiRequest" result="searchlookup_resmulti">
											<cfhttpparam type="xml"  value="#trim( soapHeaderDelAsstCoreTxt )#" />
										</cfhttp>
									</cfif>
								</cfloop>
							</cfif>
						</cfif>
						<cfif isDefined("form.oldshipperPickupDateMultiple") and len(trim(form.oldshipperPickupDateMultiple))>
							<cfloop list="#form.oldshipperPickupDateMultiple#" item="delDate">
								<cfif NOT ListContains('#getLoadMultipleDates.MultipleDates#', delDate)>
									<cfif DateCompare(delDate, variables.PickupDate , 'd') NEQ 0>
										<cfoutput>
											<cfsavecontent variable="soapHeaderDelAsstCoreTxt">
												<Envelope
													xmlns="http://schemas.xmlsoap.org/soap/envelope/"
													xmlns:tcor="http://www.tcore.com/TcoreHeaders.xsd"
													xmlns:tcor1="http://www.tcore.com/TcoreTypes.xsd"
													xmlns:tfm="http://www.tcore.com/TfmiFreightMatching.xsd">
													<Header>
														<tcor:sessionHeader>
															<tcor:sessionToken>
																<tcor1:primary>#trim(session.primaryKey[1].XmlText)#</tcor1:primary>
																<tcor1:secondary>#trim(session.SeconKey[1].XmlText)#</tcor1:secondary>
															</tcor:sessionToken>
														</tcor:sessionHeader>
													</Header>
													<Body>
														<tfm:deleteAssetRequest>
															<tfm:deleteAssetOperation>
																<tfm:deleteAssetByPostersReferenceId>
																	<tfm:postersReferenceId>#left(URLEncodedFormat(ToBase64(Encrypt(ViewPostEveryWhere.ImportRef, dateformat(delDate,'YYYYMMDD')))),8)#</tfm:postersReferenceId>
																</tfm:deleteAssetByPostersReferenceId>
															</tfm:deleteAssetOperation>
														</tfm:deleteAssetRequest>
													</Body>
												</Envelope>
											</cfsavecontent>
										</cfoutput>
										<!--- LIVE URL --->
										<cfhttp method="post" url="http://www.transcoreservices.com:8000/TfmiRequest" result="searchlookup_resmulti">
											<cfhttpparam type="xml"  value="#trim( soapHeaderDelAsstCoreTxt )#" />
										</cfhttp>
									</cfif>
								</cfif>
							</cfloop>
						</cfif>
					</cfif>
					<cfset objDel360 =  searchlookup_res.filecontent />
					<cfset TranscoreobjDelData3601 = xmlParse( objDel360 ) />
					<cfset errorInResultDel = XmlSearch(TranscoreobjDelData3601,"//*[name()='tcor:message']") />

					<cfif isarray(errorInResultDel) AND not arrayIsEmpty(errorInResultDel)
					AND structKeyExists(errorInResultDel[1], "xmltext") AND errorInResultDel[1].xmltext CONTAINS 'Error: 104000010 - Requestor can not access requested asset'>

						<cfif arguments.trans360Usename EQ ViewPostEveryWhere.DATPostedLogin>
							<cfset Alertvar = "Load already unposted from load board." />
							<cfquery name="GetTranceCoreDBcount" datasource="#variables.dsn#">
								DELETE FROM LoadPostEverywhereDetails WHERE imprtref=<cfqueryparam value="#arguments.impref#" cfSqltype="cf_sql_varchar"> AND From_web='Tc360' AND status='success'
							</cfquery>
							<cfquery name="TransFlaginsert" datasource="#variables.dsn#">
								update Loads SET IsTransCorePst=0, Trans_Sucess_Flag=0,DATPostedLogin=NULL WHERE LoadID=<cfqueryparam value="#arguments.LoadID#" cfSqltype="cf_sql_varchar">
							</cfquery>
						<cfelse>
							<cfset Alertvar = "Load was posted by a different user. Load unposting is not allowed." />
							<cfquery name="TransFlaginsert" datasource="#variables.dsn#">
								update Loads SET IsTransCorePst=1,Trans_Sucess_Flag=1 where LoadID=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.LoadID#">
							</cfquery>
						</cfif>
					<cfelse>
						<cfset Alertvar = "This Load sucessfully deleted from DAT Loadboard " />

						<!-----Delete asset from DB if any---->
						<cfquery name="GetTranceCoreDBcount" datasource="#variables.dsn#">
							DELETE FROM LoadPostEverywhereDetails WHERE imprtref=<cfqueryparam value="#arguments.impref#" cfSqltype="cf_sql_varchar"> AND From_web='Tc360' AND status='success'
						</cfquery>

						<cfquery name="TransFlaginsert" datasource="#variables.dsn#">
							update Loads SET IsTransCorePst=0, Trans_Sucess_Flag=0,DATPostedLogin=NULL WHERE LoadID=<cfqueryparam value="#arguments.LoadID#" cfSqltype="cf_sql_varchar">
						</cfquery>
					</cfif>
				<cfelseif arguments.postaction EQ 'A'>
					<!------Post asset to trancecore----->
					<cfoutput>
						<cfsavecontent variable="soapHeaderTransCoreTokenTxt">
							<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:tcor="http://www.tcore.com/TcoreHeaders.xsd" xmlns:tcor1="http://www.tcore.com/TcoreTypes.xsd" xmlns:tfm="http://www.tcore.com/TfmiFreightMatching.xsd">
								<soapenv:Header>
									<tcor:sessionHeader soapenv:mustUnderstand="1">
										<tcor:sessionToken>
											<tcor1:primary>#trim(session.primaryKey[1].XmlText)#</tcor1:primary>
											<tcor1:secondary>#trim(session.SeconKey[1].XmlText)#</tcor1:secondary>
										</tcor:sessionToken>
									</tcor:sessionHeader>											
								</soapenv:Header>
								<soapenv:Body>
									<tfm:postAssetRequest>
										<tfm:postAssetOperations>           
											<tfm:shipment>
												<tfm:equipmentType>#variables.EquipmentName#</tfm:equipmentType>
												<tfm:origin>
													<tfm:cityAndState>
															<tfm:city>#variables.OriginCity#</tfm:city>
															<tfm:stateProvince>#variables.OriginState#</tfm:stateProvince>
													</tfm:cityAndState>
												</tfm:origin>
												<tfm:destination>
													<tfm:cityAndState>
															<tfm:city>#variables.DestCity#</tfm:city>
															<tfm:stateProvince>#variables.DestState#</tfm:stateProvince>
													</tfm:cityAndState>
												</tfm:destination>
												<cfif StructKeyExists(arguments,"INCLUDECARIERRATE") AND arguments.INCLUDECARIERRATE EQ 1> 
													<tfm:rate>
														<tfm:baseRateDollars> #variables.TotalCarrierCharges# </tfm:baseRateDollars>
														<tfm:rateBasedOn>Flat</tfm:rateBasedOn>
														<tfm:rateMiles> 0 </tfm:rateMiles>
													</tfm:rate>
												</cfif>
											</tfm:shipment>
											<tfm:postersReferenceId>#ViewPostEveryWhere.ImportRef#</tfm:postersReferenceId>
											<tfm:ltl>#FullOrPartial#</tfm:ltl>
											<tfm:comments>#left(escapeSpecialCharacters(variables.Notes),70)#</tfm:comments>
											<tfm:dimensions>
												<tfm:lengthFeet>#variables.length#</tfm:lengthFeet>
												<tfm:weightPounds>
														<cfif not isnumeric(variables.Weight) or variables.Weight eq 0>
															1
														<cfelse>
															#variables.Weight#
														</cfif>
												</tfm:weightPounds>
											</tfm:dimensions>
											<tfm:availability>
												<tfm:earliest>#dateformat(variables.PickupDate,"yyyy-mm-dd")#T08:00:00.000Z</tfm:earliest>	
											</tfm:availability>
											<tfm:includeAsset>false</tfm:includeAsset>
										</tfm:postAssetOperations>

										<cfif getLoadMultipleDates.recordcount>
											<cfif len(trim(variables.PickupDate)) AND len(trim(variables.FinalDelivDate)) AND len(trim(getLoadMultipleDates.MultipleDates))>
												<cfset days = DateDiff('d', variables.PickupDate, variables.FinalDelivDate)>
												<cfloop list="#getLoadMultipleDates.MultipleDates#" item="PickUpDateNew">
													<cfif DateCompare(PickUpDateNew, variables.PickupDate , 'd') NEQ 0>
														<tfm:postAssetOperations>           
															<tfm:shipment>
																<tfm:equipmentType>#variables.EquipmentName#</tfm:equipmentType>
																<tfm:origin>
																	<tfm:cityAndState>
																			<tfm:city>#variables.OriginCity#</tfm:city>
																			<tfm:stateProvince>#variables.OriginState#</tfm:stateProvince>
																	</tfm:cityAndState>
																</tfm:origin>
																<tfm:destination>
																	<tfm:cityAndState>
																			<tfm:city>#variables.DestCity#</tfm:city>
																			<tfm:stateProvince>#variables.DestState#</tfm:stateProvince>
																	</tfm:cityAndState>
																</tfm:destination>
																<cfif StructKeyExists(arguments,"INCLUDECARIERRATE") AND arguments.INCLUDECARIERRATE EQ 1> 
																	<tfm:rate>
																		<tfm:baseRateDollars> #variables.TotalCarrierCharges# </tfm:baseRateDollars>
																		<tfm:rateBasedOn>Flat</tfm:rateBasedOn>
																		<tfm:rateMiles> 0 </tfm:rateMiles>
																	</tfm:rate>
																</cfif>
															</tfm:shipment>
															<tfm:postersReferenceId>#left(URLEncodedFormat(ToBase64(Encrypt(ViewPostEveryWhere.IMPORTREF, dateformat(PickUpDateNew,'YYYYMMDD')))),8)#</tfm:postersReferenceId>
															<tfm:ltl>#FullOrPartial#</tfm:ltl>
															<tfm:comments>#left(escapeSpecialCharacters(variables.Notes),70)#</tfm:comments>
															<tfm:dimensions>
																<tfm:lengthFeet>#variables.length#</tfm:lengthFeet>
																<tfm:weightPounds>
																		<cfif not isnumeric(variables.Weight) or variables.Weight eq 0>
																			1
																		<cfelse>
																			#variables.Weight#
																		</cfif>
																</tfm:weightPounds>
															</tfm:dimensions>
															<tfm:availability>
																<tfm:earliest>#dateformat(PickUpDateNew,"yyyy-mm-dd")#T08:00:00.000Z</tfm:earliest>	
															</tfm:availability>
															<tfm:includeAsset>false</tfm:includeAsset>
														</tfm:postAssetOperations>
													</cfif>
												</cfloop>
											</cfif>
										</cfif>
									</tfm:postAssetRequest>
								</soapenv:Body>
							</soapenv:Envelope>
						</cfsavecontent>
					</cfoutput>
					<!--- Insert into transcore --->	
			
					<!--- LIVE URL --->
					<cfhttp method="post" url="http://www.transcoreservices.com:8000/TfmiRequest" result="objGet">
						<cfhttpparam type="xml"  value="#trim( soapHeaderTransCoreTokenTxt )#" />
					</cfhttp>	
					<cfset objGet360 =  objGet.filecontent />
					<cfset TranscoreobjGetData3601 = xmlParse( objGet360 ) />
					
					<cfset postAssetSuccess_res = XmlSearch(TranscoreobjGetData3601,"//*[name()='tfm:postAssetSuccessData']") />
					<cfset errorInResult = XmlSearch(TranscoreobjGetData3601,"//*[name()='message']") />

					<cfif arraylen(postAssetSuccess_res) eq 0>
						<cfquery name="GetTranceCoreDBcount" datasource="#variables.dsn#">
							select imprtref,Postrequest_text from LoadPostEverywhereDetails where imprtref=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.impref#"> and From_web='Tc360' and status='success'
						</cfquery>
						<cfif GetTranceCoreDBcount.recordcount gt 0>
							<!-----rechecking prepost if fail----->
							<!------Post asset to trancecore----->
							<cfoutput>
								<cfsavecontent variable="soapHeaderTransCoreHead">
									<Header>
										<tcor:sessionHeader>
											<tcor:sessionToken>
												<tcor1:primary>#session.primaryKey[1].XmlText#</tcor1:primary>
												<tcor1:secondary>#session.SeconKey[1].XmlText#</tcor1:secondary>
											</tcor:sessionToken>
										</tcor:sessionHeader>
									</Header>
								</cfsavecontent>
								<cfset strHXml = reReplace(GetTranceCoreDBcount.Postrequest_text, "<Header>(.*?)</Header>", soapHeaderTransCoreHead) />
								<cfsavecontent variable="soapHeaderTransCoreTokenTxt">
									#trim(strHXml)#
								</cfsavecontent>
							</cfoutput>
							<cfhttp method="post" url="https://cnx.dat.com/TfmiRequest" result="objGet1">
								<cfhttpparam type="xml"  value="#trim( soapHeaderTransCoreTokenTxt )#" />
							</cfhttp>
							<cfset objGet3601 =  objGet1.filecontent />
							<cfset TranscoreobjGetData36011 = xmlParse( objGet3601 ) />
							<cfset postAssetSuccess_res1 = XmlSearch(TranscoreobjGetData36011,"//*[name()='tfm:postAssetSuccessData']") />
							<cfif arraylen(postAssetSuccess_res1) eq 0>
								<!-----if fail----->
								<cfset sts='Fail' />
								<cfquery name="TransFlaginsert" datasource="#variables.dsn#">
									update Loads SET IsTransCorePst=0,Trans_Sucess_Flag=0 where LoadID=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.LoadID#">
								</cfquery>
								<cfset Alertvar ="1" />
								<cfset msg = XmlSearch(TranscoreobjGetData36011,"//*[name()='message']") />
								<cfif arraylen(msg) eq 0>
									<cfset Alertvar ="1" />
									<cfset msg1 = XmlSearch(TranscoreobjGetData36011,"//*[name()='tcor:message']") />
									<cfif arraylen(msg1) eq 0>
										<cfset Alertvar ="1" />
									<cfelse>
										<cfset Alertvar=replace(#msg1[1].XmlText#,"http://www.tcore.com/TcoreTypes.xsd" ,"") />
									</cfif>
								<cfelse>
									<cfset Alertvar=replace(#msg[1].XmlText#,"http://www.tcore.com/TcoreTypes.xsd" ,"") />
								</cfif>
								<cfif Alertvar eq  1>
									<cfset Alertvar="Your Transcore Webservice status is Failed" />
								</cfif>
								<!-----if fail----->
							<cfelse>
								<!----if success---->
								<cfset sts='success' />
								<cfset Prev_sts='success' />
								<cfset Alertvar="1" />
								<cfset msg = XmlSearch(TranscoreobjGetData3601,"//*[name()='message']") />
								<cfif arraylen(msg) eq 0>
									<cfset Alertvar ="1" />
									<cfset msg1 = XmlSearch(TranscoreobjGetData3601,"//*[name()='tcor:message']") />
									<cfif arraylen(msg1) eq 0>
										<cfset Alertvar ="1" />
									<cfelse>
										<cfset Alertvar=replace(#msg1[1].XmlText#,"http://www.tcore.com/TcoreTypes.xsd" ,"") />
									</cfif>
								<cfelse>
									<cfset Alertvar=replace(#msg[1].XmlText#,"http://www.tcore.com/TcoreTypes.xsd" ,"") />
								</cfif>
								<cfif Alertvar eq  1>
									<cfset Alertvar="Your Transcore Webservice status is Failed" />
								</cfif>
								<cfquery name="TransFlaginsert" datasource="#variables.dsn#">
									update Loads SET IsTransCorePst=1,Trans_Sucess_Flag=1,DATPostedLogin=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.trans360Usename#"> where LoadID=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.LoadID#">
								</cfquery>
								<!-----if success--->
							</cfif>
							<!-----rechecking prepost if fail----->
						<cfelse>
							<!-----if fail----->
							<cfset sts='Fail' />
							<cfquery name="TransFlaginsert" datasource="#variables.dsn#">
								update Loads SET IsTransCorePst=0,Trans_Sucess_Flag=0 where LoadID=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.LoadID#">
							</cfquery>
							<cfset Alertvar ="1" />
							<cfset msg = XmlSearch(TranscoreobjGetData3601,"//*[name()='message']") />
							<cfif arraylen(msg) eq 0>
								<cfset Alertvar ="1" />
								<cfset msg1 = XmlSearch(TranscoreobjGetData3601,"//*[name()='tcor:message']") />
								<cfset detmsg = XmlSearch(TranscoreobjGetData3601,"//*[name()='tcor:detailedMessage']") />
								<cfif arraylen(detmsg)>
									<cfset msg1 = detmsg>
								</cfif>
								<cfif arraylen(msg1) eq 0>
									<cfset Alertvar ="1" />
								<cfelse>
									<cfset Alertvar=replace(#msg1[1].XmlText#,"http://www.tcore.com/TcoreTypes.xsd" ,"") />
								</cfif>
							<cfelse>
								<cfset Alertvar=replace(#msg[1].XmlText#,"http://www.tcore.com/TcoreTypes.xsd" ,"") />
							</cfif>
							<cfif Alertvar eq  1>
								<cfset Alertvar="Your Transcore Webservice status is Failed" />
							</cfif>
							<!-----if fail----->
						</cfif>
					<cfelse>
						<!----if success---->
						<cfset sts='success' />
						<cfif arguments.Refreshed EQ 0>
							<cfset Alertvar="You have successfully posted to Dat Loadboard" />
						<cfelse>
							<cfset Alertvar="You have successfully updated to Dat Loadboard" />
						</cfif>
						<cfquery name="TransFlaginsert" datasource="#variables.dsn#" result="mm">
							update Loads SET IsTransCorePst=1,Trans_Sucess_Flag=1,DATPostedLogin=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.trans360Usename#"> where LoadID=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.LoadID#">
						</cfquery>
						<!-----if success--->
					</cfif>
						<!-----delete asset from DB if any---->
						<cfquery name="GetTranceCoreDBcount" datasource="#variables.dsn#">
							delete from LoadPostEverywhereDetails where imprtref=<cfqueryparam cfsqltype="cf_sql_varchar" value="#ViewPostEveryWhere.IMPORTREF#"> and From_web='Tc360' and status='success'
						</cfquery>
						<!-----Insert new asset from DB if any---->
						<cfquery name="PEPinsert" datasource="#variables.dsn#">
							INSERT INTO LoadPostEverywhereDetails (Postrequest_text,Response_text,imprtref,From_web,status) VALUES(
								<cfqueryparam cfsqltype="cf_sql_varchar" value="#soapHeaderTransCoreTokenTxt#">,
								<cfqueryparam cfsqltype="cf_sql_varchar" value="#objGet.FileContent#">,
								<cfqueryparam cfsqltype="cf_sql_varchar" value="#ViewPostEveryWhere.IMPORTREF#">,
								'Tc360',
								<cfqueryparam cfsqltype="cf_sql_varchar" value="#sts#">)
						</cfquery>
				<cfelseif arguments.postaction EQ 'U'>
						<cfoutput>
							<cfsavecontent variable="soapHeaderDelAsstCoreTxt">
								<Envelope
									xmlns="http://schemas.xmlsoap.org/soap/envelope/"
									xmlns:tcor="http://www.tcore.com/TcoreHeaders.xsd"
									xmlns:tcor1="http://www.tcore.com/TcoreTypes.xsd"
									xmlns:tfm="http://www.tcore.com/TfmiFreightMatching.xsd">
									<Header>
										<tcor:sessionHeader>
											<tcor:sessionToken>
												<tcor1:primary>#session.primaryKey[1].XmlText#</tcor1:primary>
												<tcor1:secondary>#session.SeconKey[1].XmlText#</tcor1:secondary>
											</tcor:sessionToken>
										</tcor:sessionHeader>
									</Header>
									<Body>
										<tfm:deleteAssetRequest>
											<tfm:deleteAssetOperation>
												<tfm:deleteAssetByPostersReferenceId>
													<tfm:postersReferenceId>#ViewPostEveryWhere.IMPORTREF#</tfm:postersReferenceId>
												</tfm:deleteAssetByPostersReferenceId>
											</tfm:deleteAssetOperation>
										</tfm:deleteAssetRequest>
									</Body>
								</Envelope>
							</cfsavecontent>
						</cfoutput>
						<!--- LIVE URL --->
						<cfhttp method="post" url="http://www.transcoreservices.com:8000/TfmiRequest" result="searchlookup_res">
							<cfhttpparam type="xml"  value="#trim( soapHeaderDelAsstCoreTxt )#" />
						</cfhttp>


						<cfif getLoadMultipleDates.recordcount>
							<cfif len(trim(getLoadMultipleDates.MultipleDates))>
								<cfloop list="#getLoadMultipleDates.MultipleDates#" item="delDate">
									<cfif DateCompare(delDate, variables.PickupDate , 'd') NEQ 0>
										<cfoutput>
											<cfsavecontent variable="soapHeaderDelAsstCoreTxt">
												<Envelope
													xmlns="http://schemas.xmlsoap.org/soap/envelope/"
													xmlns:tcor="http://www.tcore.com/TcoreHeaders.xsd"
													xmlns:tcor1="http://www.tcore.com/TcoreTypes.xsd"
													xmlns:tfm="http://www.tcore.com/TfmiFreightMatching.xsd">
													<Header>
														<tcor:sessionHeader>
															<tcor:sessionToken>
																<tcor1:primary>#trim(session.primaryKey[1].XmlText)#</tcor1:primary>
																<tcor1:secondary>#trim(session.SeconKey[1].XmlText)#</tcor1:secondary>
															</tcor:sessionToken>
														</tcor:sessionHeader>
													</Header>
													<Body>
														<tfm:deleteAssetRequest>
															<tfm:deleteAssetOperation>
																<tfm:deleteAssetByPostersReferenceId>
																	<tfm:postersReferenceId>#left(URLEncodedFormat(ToBase64(Encrypt(ViewPostEveryWhere.IMPORTREF, dateformat(delDate,'YYYYMMDD')))),8)#</tfm:postersReferenceId>
																</tfm:deleteAssetByPostersReferenceId>
															</tfm:deleteAssetOperation>
														</tfm:deleteAssetRequest>
													</Body>
												</Envelope>
											</cfsavecontent>
										</cfoutput>
										<!--- LIVE URL --->
										<cfhttp method="post" url="http://www.transcoreservices.com:8000/TfmiRequest" result="searchlookup_resmulti">
											<cfhttpparam type="xml"  value="#trim( soapHeaderDelAsstCoreTxt )#" />
										</cfhttp>
									</cfif>
								</cfloop>
							</cfif>
						</cfif>

						<cfoutput>
							<cfsavecontent variable="soapHeaderTransCoreTokenTxt">
								<Envelope
									xmlns="http://schemas.xmlsoap.org/soap/envelope/"
									xmlns:tcor="http://www.tcore.com/TcoreHeaders.xsd"
									xmlns:tcor1="http://www.tcore.com/TcoreTypes.xsd"
									xmlns:tfm="http://www.tcore.com/TfmiFreightMatching.xsd">
									<Header>
										<tcor:sessionHeader>
											<tcor:sessionToken>
												<tcor1:primary>#session.primaryKey[1].XmlText#</tcor1:primary>
												<tcor1:secondary>#session.SeconKey[1].XmlText#</tcor1:secondary>
											</tcor:sessionToken>
										</tcor:sessionHeader>
									</Header>
									<Body>
										<tfm:postAssetRequest>
											<tfm:postAssetOperations>
												<tfm:shipment>
													<tfm:equipmentType>#variables.EquipmentName#</tfm:equipmentType>
													<tfm:origin>
														<tfm:cityAndState>
															<tfm:city>#variables.OriginCity#</tfm:city>
															<tfm:stateProvince>#variables.OriginState#</tfm:stateProvince>
														</tfm:cityAndState>
													</tfm:origin>
													<tfm:destination>
														<tfm:cityAndState>
															<tfm:city>#variables.DestCity#</tfm:city>
															<tfm:stateProvince>#variables.DestState#</tfm:stateProvince>
														</tfm:cityAndState>
													</tfm:destination>	
													<cfif StructKeyExists(arguments,"INCLUDECARIERRATE") AND arguments.INCLUDECARIERRATE EQ 1>
														<tfm:rate>
															<tfm:baseRateDollars> #variables.TotalCarrierCharges# </tfm:baseRateDollars>
															<tfm:rateBasedOn>Flat</tfm:rateBasedOn>
															<tfm:rateMiles> 0 </tfm:rateMiles>
														</tfm:rate>	
													</cfif>										
												</tfm:shipment>										
												<tfm:postersReferenceId>#ViewPostEveryWhere.IMPORTREF#</tfm:postersReferenceId>
												<tfm:ltl>#FullOrPartial#</tfm:ltl>
												<tfm:comments>#left(escapeSpecialCharacters(variables.Notes),70)#</tfm:comments>
												<tfm:dimensions>
													<tfm:lengthFeet>#variables.length#</tfm:lengthFeet>
													<tfm:weightPounds>
														<cfif not isnumeric(variables.Weight) or variables.Weight eq 0>
															1
														<cfelse>
															#variables.Weight#
														</cfif>
													</tfm:weightPounds>
												</tfm:dimensions>											
												<tfm:availability>
													<tfm:earliest>
														#dateformat(variables.PickupDate,"yyyy-mm-dd")#T08:00:00.000Z
													</tfm:earliest>
												</tfm:availability>
												<tfm:includeAsset>false</tfm:includeAsset>
											</tfm:postAssetOperations>
											<cfif getLoadMultipleDates.recordcount>
											<cfif len(trim(variables.PickupDate)) AND len(trim(variables.FinalDelivDate)) AND len(trim(getLoadMultipleDates.MultipleDates))>
												<cfset days = DateDiff('d', variables.PickupDate, variables.FinalDelivDate)>
												<cfloop list="#getLoadMultipleDates.MultipleDates#" item="PickUpDateNew">
													<cfif DateCompare(PickUpDateNew, variables.PickupDate , 'd') NEQ 0>
														<tfm:postAssetOperations>           
															<tfm:shipment>
																<tfm:equipmentType>#variables.EquipmentName#</tfm:equipmentType>
																<tfm:origin>
																	<tfm:cityAndState>
																			<tfm:city>#variables.OriginCity#</tfm:city>
																			<tfm:stateProvince>#variables.OriginState#</tfm:stateProvince>
																	</tfm:cityAndState>
																</tfm:origin>
																<tfm:destination>
																	<tfm:cityAndState>
																			<tfm:city>#variables.DestCity#</tfm:city>
																			<tfm:stateProvince>#variables.DestState#</tfm:stateProvince>
																	</tfm:cityAndState>
																</tfm:destination>
																<cfif StructKeyExists(arguments,"INCLUDECARIERRATE") AND arguments.INCLUDECARIERRATE EQ 1> 
																	<tfm:rate>
																		<tfm:baseRateDollars> #variables.TotalCarrierCharges# </tfm:baseRateDollars>
																		<tfm:rateBasedOn>Flat</tfm:rateBasedOn>
																		<tfm:rateMiles> 0 </tfm:rateMiles>
																	</tfm:rate>
																</cfif>
															</tfm:shipment>
															<tfm:postersReferenceId>#left(URLEncodedFormat(ToBase64(Encrypt(ViewPostEveryWhere.IMPORTREF, dateformat(PickUpDateNew,'YYYYMMDD')))),8)#</tfm:postersReferenceId>
															<tfm:ltl>#FullOrPartial#</tfm:ltl>
															<tfm:comments>#left(escapeSpecialCharacters(variables.Notes),70)#</tfm:comments>
															<tfm:dimensions>
																<tfm:lengthFeet>#variables.length#</tfm:lengthFeet>
																<tfm:weightPounds>
																		<cfif not isnumeric(variables.Weight) or variables.Weight eq 0>
																			1
																		<cfelse>
																			#variables.Weight#
																		</cfif>
																</tfm:weightPounds>
															</tfm:dimensions>
															<tfm:availability>
																<tfm:earliest>#dateformat(PickUpDateNew,"yyyy-mm-dd")#T08:00:00.000Z</tfm:earliest>	
															</tfm:availability>
															<tfm:includeAsset>false</tfm:includeAsset>
														</tfm:postAssetOperations>
													</cfif>
												</cfloop>
											</cfif>
										</cfif>
										</tfm:postAssetRequest>
									</Body>
								</Envelope>
							</cfsavecontent>
						</cfoutput>

					<!--- Insert into transcore --->
					<!--- LIVE URL --->
					<cfhttp method="post" url="http://www.transcoreservices.com:8000/TfmiRequest" result="objGet">
						<cfhttpparam type="xml"  value="#trim( soapHeaderTransCoreTokenTxt )#" />
					</cfhttp>

					<cfset objGet360 =  objGet.filecontent />
					<cfset TranscoreobjGetData3601 = xmlParse( objGet360 ) />
					<cfset postAssetSuccess_res = XmlSearch(TranscoreobjGetData3601,"//*[name()='tfm:postAssetSuccessData']") />
					<cfset errorInResult = XmlSearch(TranscoreobjGetData3601,"//*[name()='message']") />
							<cfif arraylen(postAssetSuccess_res) eq 0>
								<cfquery name="GetTranceCoreDBcount" datasource="#variables.dsn#">
									select imprtref,Postrequest_text from LoadPostEverywhereDetails where imprtref=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.impref#"> and From_web='Tc360' and status='success'
								</cfquery>
								<cfif GetTranceCoreDBcount.recordcount>
									<!-----rechecking prepost if fail----->
									<!------Post asset to trancecore----->
									<cfoutput>
										<cfsavecontent variable="soapHeaderTransCoreHead">
											<Header>
												<tcor:sessionHeader>
													<tcor:sessionToken>
														<tcor1:primary>#trim(session.primaryKey[1].XmlText)#</tcor1:primary>
														<tcor1:secondary>#trim(session.SeconKey[1].XmlText)#</tcor1:secondary>
													</tcor:sessionToken>
												</tcor:sessionHeader>
											</Header>
										</cfsavecontent>
										<cfset strHXml = reReplace(GetTranceCoreDBcount.Postrequest_text, "<Header>(.*?)</Header>", soapHeaderTransCoreHead) />
										<cfsavecontent variable="soapHeaderTransCoreTokenTxt">
											#trim(strHXml)#
										</cfsavecontent>
									</cfoutput>
									<!--- Live URL --->
									<cfhttp method="post" url="http://www.transcoreservices.com:8000/TfmiRequest" result="objGet1">
										<cfhttpparam type="xml"  value="#trim( soapHeaderTransCoreTokenTxt )#" />
									</cfhttp>
									<cfset objGet3601 =  objGet1.filecontent />
									<cfset TranscoreobjGetData36011 = xmlParse( objGet3601 ) />
									<cfset postAssetSuccess_res1 = XmlSearch(TranscoreobjGetData36011,"//*[name()='tfm:postAssetSuccessData']") />

									<cfif arraylen(postAssetSuccess_res1) eq 0>
										<!-----if fail----->
										<cfset sts='Fail' />
										<cfquery name="TransFlaginsert" datasource="#variables.dsn#">
											update Loads SET IsTransCorePst=0,Trans_Sucess_Flag=0 where LoadID=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.LoadID#">
										</cfquery>
										<cfset Alertvar ="1" />
										<cfset msg = XmlSearch(TranscoreobjGetData36011,"//*[name()='message']") />
										<cfif arraylen(msg) eq 0>
											<cfset Alertvar ="1" />
											<cfset msg1 = XmlSearch(TranscoreobjGetData36011,"//*[name()='tcor:message']") />
											<cfif arraylen(msg1) eq 0>
												<cfset Alertvar ="1" />
											<cfelse>
												<cfset Alertvar=replace(#msg1[1].XmlText#,"http://www.tcore.com/TcoreTypes.xsd" ,"") />
											</cfif>
										<cfelse>
											<cfset Alertvar=replace(#msg[1].XmlText#,"http://www.tcore.com/TcoreTypes.xsd" ,"") />
										</cfif>
										<cfif Alertvar eq  1>
											<cfset Alertvar="Your Transcore Webservice status is Failed" />
										</cfif>
										<!-----if fail----->
									<cfelse>
										<!----if success---->
										<cfset sts='Fail' />
										<cfset Prev_sts='success' />
										<cfset Alertvar="1" />
										<cfset msg = XmlSearch(TranscoreobjGetData3601,"//*[name()='message']") />
										<cfif arraylen(msg) eq 0>
											<cfset Alertvar ="1" />
											<cfset msg1 = XmlSearch(TranscoreobjGetData3601,"//*[name()='tcor:message']") />
											<cfif arraylen(msg1) eq 0>
												<cfset Alertvar ="1" />
											<cfelse>
												<cfset Alertvar=replace(#msg1[1].XmlText#,"http://www.tcore.com/TcoreTypes.xsd" ,"") />
											</cfif>
										<cfelse>
											<cfset Alertvar=replace(#msg[1].XmlText#,"http://www.tcore.com/TcoreTypes.xsd" ,"") />
										</cfif>
										<cfif Alertvar eq  1>
											<cfset Alertvar="Your Transcore Webservice status is Failed" />
										</cfif>
										<cfquery name="TransFlaginsert" datasource="#variables.dsn#">
											update Loads SET IsTransCorePst=0,Trans_Sucess_Flag=0 where LoadID=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.LoadID#">
										</cfquery>
										<!-----if success--->
									</cfif>
									<!-----rechecking prepost if fail----->
								<cfelse>
									<!-----if fail----->
									<cfset sts='Fail' />
									<cfquery name="TransFlaginsert" datasource="#variables.dsn#">
										update Loads SET IsTransCorePst=0,Trans_Sucess_Flag=0 where LoadID=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.LoadID#">
									</cfquery>

									<cfset Alertvar ="1" />
									<cfset msg = XmlSearch(TranscoreobjGetData3601,"//*[name()='message']") />

									<cfif arraylen(msg) eq 0>
										<cfset Alertvar ="1" />
										<cfset msg1 = XmlSearch(TranscoreobjGetData3601,"//*[name()='tcor:message']") />
										<cfif arraylen(msg1) eq 0>
											<cfset Alertvar ="1" />
										<cfelse>
											<cfset Alertvar=replace(#msg1[1].XmlText#,"http://www.tcore.com/TcoreTypes.xsd" ,"") />
										</cfif>
									<cfelse>
										<cfset Alertvar=replace(#msg[1].XmlText#,"http://www.tcore.com/TcoreTypes.xsd" ,"") />
									</cfif>

									<cfif Alertvar eq  1>
										<cfset Alertvar="Your Transcore Webservice status is Failed" />
									</cfif>
									<!-----if fail----->
								</cfif>
							<cfelse>
								<!----if success---->
								<cfset sts='success' />
								<cfset Alertvar="you have successfully posted to Dat Loadboard" />

								<cfquery name="TransFlaginsert" datasource="#variables.dsn#" result="mm">
									update Loads SET IsTransCorePst=1,Trans_Sucess_Flag=1 where LoadID='#arguments.LoadID#'
								</cfquery>
								<!-----if success--->
							</cfif>
							<!-----delete asset from DB if any---->
							<cfquery name="GetTranceCoreDBcount" datasource="#variables.dsn#">
								delete from LoadPostEverywhereDetails where imprtref=<cfqueryparam cfsqltype="cf_sql_varchar" value="#ViewPostEveryWhere.IMPORTREF#"> and From_web='Tc360' and status='success'
								<!--- delete from LoadPostEverywhereDetails where imprtref='#arguments.impref#' and From_web='Tc360' and status='success' --->
							</cfquery>
							<!-----Insert new asset from DB if any---->
							<cfquery name="PEPinsert" datasource="#variables.dsn#" result="result">
								INSERT INTO LoadPostEverywhereDetails (Postrequest_text,Response_text,imprtref,From_web,status) VALUES(
									<cfqueryparam cfsqltype="cf_sql_varchar" value="#soapHeaderTransCoreTokenTxt#">,
									<cfqueryparam cfsqltype="cf_sql_varchar" value="#objGet.FileContent#">,
									<cfqueryparam cfsqltype="cf_sql_varchar" value="#ViewPostEveryWhere.IMPORTREF#">,
									'Tc360',
									<cfqueryparam cfsqltype="cf_sql_varchar" value="#sts#">)
							</cfquery>
						</cfif>
				<!--- </cfif> --->
			</cftransaction>
			<cfif Alertvar neq 1>
				<cfset Alertvar="DAT Loadboard Says : "&Alertvar />
			</cfif>
			<cfif isdefined("Prev_sts")>
				<cfset Alertvar=Alertvar&"!!!" />
			</cfif>
			<cfif findNoCase("Invalid Session Token", Alertvar)>
				<cfdocument format="pdf" filename="C:\pdf\DAT_TOKEN_ERROR_#arguments.impref#.pdf" overwrite="true">
					<cfdump var="#qGetTranscoreSession#">
					<cfdump var="#session.primaryKey#">
					<cfdump var="#session.SeconKey#">
				</cfdocument>
			</cfif>
			<cfreturn Alertvar />

			<cfcatch type="any">
				<cfset Alertvar='DAT Loadboard Says : Transcore have connection failure error. sorry please try later' />
				<cfreturn Alertvar />
			</cfcatch>
		</cftry>
	</cffunction>
	<!---------------Transcore 360 webservice end----->

		<!---------------delete 123loadboard seperateloads end----->
		<cffunction name="delete123LoadBoardWebserviceSeparate" access="remote" returntype="any">
			<cfargument name="username" type="string" required="yes">
			<cfargument name="password" type="string" required="yes">
			<cfargument name="dsn" type="string" required="yes">
			<cfargument name="loadStopId" type="string" required="yes">
			<cfparam name="Alertvar" default="1">
			<cfoutput>
				<cfset variables.PostProviderID='LMGR428AP'>
			<!--- Delete from 123LoadboardAjax--->
				<cfquery name="Get123LoadBoardDBcount" datasource="#arguments.dsn#">
					select * from vwLoads123LoadBoard where LOADSTOPID=<cfqueryparam value="#arguments.loadStopId#" cfsqltype="cf_sql_varchar">
				</cfquery>
				<cfif Get123LoadBoardDBcount.recordcount>
					<!-----Delete asset from TranceCore---->
					<cfsavecontent variable="myVariable">
							<s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/">
								<s:Header>
									<Action>http://ws.123loadboard.com/PostingWS/PostingServiceV00.svc?xsd=xsd0</Action>
								</s:Header>
								<s:Body>
									<CancelLoad xmlns="http://schemas.123loadboard.com/2009/05/06">
										<PostProviderID>#variables.PostProviderID#</PostProviderID>
										<UserName>#arguments.username#</UserName>
										<Password>#arguments.password#</Password>
										<LoadIDs xmlns:a="http://schemas.microsoft.com/2003/10/Serialization/Arrays" xmlns:i="http://www.w3.org/2001/XMLSchema-instance">

												<a:string>#left(arguments.loadStopId,25)#</a:string>

										</LoadIDs>
									</CancelLoad>
								</s:Body>
							</s:Envelope>
					</cfsavecontent>
					<cfscript>
						var getHttpResponse = "";
						var httpServiceParams = [
							{
								type = "xml",
								value = trim(myVariable)
							}
						];
						getHttpResponse = getHttpResponseCancelLoad ( method = "post", setUrl = "http://ws.123loadboard.com/PostingWS/PostingServiceV00.svc?xsd=xsd0", httpParameters = httpServiceParams );
					</cfscript>
					<cfif getHttpResponse.Statuscode eq '200 OK'>
						<cfset variables.status="success">
					<cfelse>
						<cfset variables.status="fail">
					</cfif>
					<cfif variables.status EQ "success">
						<cfset Alertvar = "This Load has been sucessfully deleted from 123 LoadBoard "/>
					<cfelse>
						<cfset Alertvar = "This Load is not sucessfully cancelled from 123 LoadBoard "/>
					</cfif>
				</cfif>
				<cfif Alertvar neq 1>
					<cfset Alertvar="123Loadboard Says : "&Alertvar />
				</cfif>
			</cfoutput>
			<cfreturn Alertvar>
		</cffunction>
	<!------------- Webservice for 123loadboard start----------------->
		<cffunction name="postTo123LoadBoardWebservice" access="remote" returntype="any">
			<cfargument name="postAction" type="string" required="yes">
			<cfargument name="PostProviderID" type="string" required="yes">
			<cfargument name="username" type="string" required="yes">
			<cfargument name="password" type="string" required="yes">
			<cfargument name="impref" type="string" required="yes">
			<cfargument name="dsn" type="string" required="yes">
			<cfargument name="CARRIERRATE" type="string" required="yes">
			<cfargument name="IncludeCarrierRate" type="numeric" required="no" default="0">
			<cfargument name="LoadID" type="string" required="yes">
			<cfparam name="Alertvar" default="1">
			<cftry>
				<cfoutput>
					<cfset variables.dsn=arguments.dsn>
					<cfquery name="ViewPost123LoadBoard" datasource="#variables.dsn#">
						select * from vwLoads123LoadBoard where loadid=<cfqueryparam value="#arguments.loadid#" cfsqltype="cf_sql_varchar">
					</cfquery>
					<cfquery name="qryGetStopNo" datasource="#variables.dsn#">
						select distinct(stopNo) from vwLoads123LoadBoard where loadid=<cfqueryparam value="#arguments.loadid#" cfsqltype="cf_sql_varchar">
					</cfquery>
					<cfquery name="getLoadMultipleDates" datasource="#variables.dsn#">
						SELECT TOP 1 MultipleDates FROM LoadStops WHERE LoadID = '#arguments.LoadID#' AND LoadType=1 ORDER BY StopNo,LoadType
					</cfquery>
					<cfset var stopNumbers=valuelist(qryGetStopNo.stopNo)>
					<!--- Create a new three-column query, specifying the column data types --->
					<cfset qryView123LoadBoard = QueryNew("loadid,loadStopid,EquipmentCode,LoadBoardcode,stopNo,LoadType,sourceCity,sourceStatecode,sourcePostalCode,emailId,contactPerson,phone,sourceStopDate,sourceStopTime,isPartial,notes,LoadNumber,weight,length,qty,commodity,destnationCity,destinationStatecode,destinationPostalcode,destinationStopdate,destinationStoptime")>

					<!--- Make  rows in the query --->
					<cfset newRow = QueryAddRow(qryView123LoadBoard, 1)>
					<cfset rowNum = 1 >
					<cfloop list="#stopNumbers#" index="i">
						 <cfquery name="qryEachStop" datasource="#variables.dsn#">
							select * from vwLoads123LoadBoard where stopNo = <cfqueryparam value="#i#" cfsqltype="cf_sql_integer"> and loadid=<cfqueryparam value="#arguments.loadid#" cfsqltype="cf_sql_varchar">
							order by loadtype asc
						 </cfquery>
						 <cfset variables.loadid=GetQueryRow(qryEachStop,1)>
						  <cfset variables.loadStopid=GetQueryRow(qryEachStop,1)>
						 <cfset variables.EquipmentCode=GetQueryRow(qryEachStop,1)>
						 <cfset variables.LoadBoardcode=GetQueryRow(qryEachStop,1)>
						 <cfset variables.stopNo=GetQueryRow(qryEachStop,1)>
						 <cfset variables.LoadType=GetQueryRow(qryEachStop,1)>
						 <cfset variables.sourceCity=GetQueryRow(qryEachStop,1)>
						 <cfset variables.sourceStatecode=GetQueryRow(qryEachStop,1)>
						 <cfset variables.emailId=GetQueryRow(qryEachStop,1)>
						 <cfset variables.contactPerson=GetQueryRow(qryEachStop,1)>
						 <cfset variables.phone=GetQueryRow(qryEachStop,1)>
						 <cfset variables.sourceStopDate=GetQueryRow(qryEachStop,1)>
						 <cfset variables.sourceStopTime=GetQueryRow(qryEachStop,1)>
						 <cfset variables.sourcePostalcode=GetQueryRow(qryEachStop,1)>
						 <cfset variables.isPartial=GetQueryRow(qryEachStop,1)>
						 <cfset variables.notes=GetQueryRow(qryEachStop,1)>
						 <cfset variables.LoadNumber=GetQueryRow(qryEachStop,1)>
						 <cfset variables.weight=GetQueryRow(qryEachStop,1)>
						 <cfset variables.length=GetQueryRow(qryEachStop,1)>
						 <cfset variables.commodity=GetQueryRow(qryEachStop,1)>
						 <cfset variables.destnationCity=GetQueryRow(qryEachStop,2)>
						 <cfset variables.destinationStatecode=GetQueryRow(qryEachStop,2)>
						 <cfset variables.destinationPostalcode=GetQueryRow(qryEachStop,2)>
						 <cfset variables.destinationStopdate=GetQueryRow(qryEachStop,2)>
						 <cfset variables.destinationStoptime=GetQueryRow(qryEachStop,2)>
						 <cfset QuerySetCell(qryView123LoadBoard, "loadid",variables.loadid.loadid, rowNum)>
						 <cfset QuerySetCell(qryView123LoadBoard, "loadStopid",variables.loadStopid.loadstopid, rowNum)>
						 <cfset QuerySetCell(qryView123LoadBoard, "EquipmentCode", variables.loadid.equipmentcode, rowNum)>
						 <cfset QuerySetCell(qryView123LoadBoard, "LoadBoardcode", variables.LoadBoardcode.LoadBoardcode, rowNum)>
						 <cfset QuerySetCell(qryView123LoadBoard, "stopNo", variables.stopNo.stopNo, rowNum)>
						 <cfset QuerySetCell(qryView123LoadBoard, "LoadType", variables.LoadType.LoadType, rowNum)>
						 <cfset QuerySetCell(qryView123LoadBoard, "sourceCity", variables.sourceCity.City, rowNum)>
						 <cfset QuerySetCell(qryView123LoadBoard, "sourceStatecode", variables.sourceStatecode.Statecode, rowNum)>
						 <cfset QuerySetCell(qryView123LoadBoard, "emailId", variables.emailId.emailId, rowNum)>
						 <cfset QuerySetCell(qryView123LoadBoard, "contactPerson", variables.contactPerson.contactPerson, rowNum)>
						 <cfset QuerySetCell(qryView123LoadBoard, "phone", variables.phone.phone, rowNum)>
						 <cfset QuerySetCell(qryView123LoadBoard, "sourceStopDate", variables.sourceStopDate.Stopdate, rowNum)>
						 <cfset QuerySetCell(qryView123LoadBoard, "sourcePostalCode", variables.sourcePostalcode.Postalcode, rowNum)>
						 <cfset QuerySetCell(qryView123LoadBoard, "sourceStopTime", variables.sourceStopTime.StopTime, rowNum)>
						 <cfset QuerySetCell(qryView123LoadBoard, "isPartial", variables.isPartial.isPartial, rowNum)>
						 <cfset QuerySetCell(qryView123LoadBoard, "notes", variables.notes.notes, rowNum)>
						 <cfset QuerySetCell(qryView123LoadBoard, "LoadNumber", variables.LoadNumber.LoadNumber, rowNum)>
						 <cfset QuerySetCell(qryView123LoadBoard, "weight", variables.weight.weight, rowNum)>
						 <cfset QuerySetCell(qryView123LoadBoard, "length", variables.length.length, rowNum)>
						 <cfset QuerySetCell(qryView123LoadBoard, "commodity", variables.commodity.commodity, rowNum)>
						 <cfset QuerySetCell(qryView123LoadBoard, "destnationCity", variables.destnationCity.City, rowNum)>
						 <cfset QuerySetCell(qryView123LoadBoard, "destinationStatecode", variables.destinationStatecode.Statecode, rowNum)>
						 <cfset QuerySetCell(qryView123LoadBoard, "destinationPostalcode", variables.destinationPostalcode.Postalcode, rowNum)>
						 <cfset QuerySetCell(qryView123LoadBoard, "destinationStopdate", variables.destinationStopdate.Stopdate, rowNum)>
						 <cfset QuerySetCell(qryView123LoadBoard, "destinationStoptime", variables.destinationStoptime.Stoptime, rowNum)>
						 <cfif ListLen(stopNumbers) NEQ rowNum >
							<cfset newRow = QueryAddRow(qryView123LoadBoard, 1)>
						 </cfif>
						 <cfset rowNum ++ >
					</cfloop>
					<cfif arguments.CARRIERRATE NEQ "">												
							<cfset CARRIERRATE = DecimalFormat(lsParseCurrency(arguments.CARRIERRATE)) >					
					<cfelse>
						<cfset CARRIERRATE = DecimalFormat(0) >
					</cfif>
					<cfif listFind("A,U", arguments.postaction) and (not len(trim(qryView123LoadBoard.sourcestopdate)) or not len(trim(qryView123LoadBoard.destinationStopdate)))>
						<cfset Alertvar='123LoadBoard Says : Invalid pickup or delivery date.' />
						<cfreturn Alertvar />
					</cfif>
					<cftransaction>
						<cfif arguments.postaction EQ 'D'><!--- Delete from 123Loadboard --->
							<cfquery name="Get123LoadBoardDBcount" datasource="#variables.dsn#">
								SELECT * FROM LoadPostEverywhereDetails
								WHERE
									imprtref=<cfqueryparam value="#arguments.impref#" cfsqltype="cf_sql_bigint"> AND
									From_web=<cfqueryparam value="123LoadBoard" cfsqltype="cf_sql_varchar"> AND
									status=<cfqueryparam value="success" cfsqltype="cf_sql_varchar">
							</cfquery>
							<cfif Get123LoadBoardDBcount.recordcount>
								<!-----Delete asset from TranceCore---->
								<cfsavecontent variable="myVariable">
										<s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/">
											<s:Header>
												<Action>http://ws.123loadboard.com/PostingWS/PostingServiceV00.svc?xsd=xsd0</Action>
											</s:Header>
											<s:Body>
												<CancelLoad xmlns="http://schemas.123loadboard.com/2009/05/06">
													<PostProviderID>#arguments.PostProviderID#</PostProviderID>
													<UserName>#arguments.username#</UserName>
													<Password>#arguments.password#</Password>
													<LoadIDs xmlns:a="http://schemas.microsoft.com/2003/10/Serialization/Arrays" xmlns:i="http://www.w3.org/2001/XMLSchema-instance">
														<cfloop query="qryView123LoadBoard">
															<cfset count=qryView123LoadBoard.STOPNO+1>
															<a:string>#left(qryView123LoadBoard.loadStopid,25)#</a:string>
														</cfloop>
														<cfif getLoadMultipleDates.recordcount>
															<cfif len(trim(qryView123LoadBoard.sourcestopdate)) AND len(trim(qryView123LoadBoard.destinationStopdate)) AND len(trim(getLoadMultipleDates.MultipleDates))>
																<cfloop list="#getLoadMultipleDates.MultipleDates#" item="PickUpDate">
																	<cfif DateCompare(PickUpDate, qryView123LoadBoard.sourcestopdate , 'd') NEQ 0>
																		<a:string>#left(qryView123LoadBoard.loadStopid,25)##dateformat(PickUpDate,'YYYYMMDD')#</a:string>
																	</cfif>
																</cfloop>
															</cfif>
														</cfif>
	         										</LoadIDs>
												</CancelLoad>
											</s:Body>
										</s:Envelope>
								</cfsavecontent>
								<cfscript>
									var getHttpResponse = "";
									var httpServiceParams = [
										{
											type = "xml",
											value = trim(myVariable)
										}
									];
									getHttpResponse = getHttpResponseCancelLoad ( method = "post", setUrl = "http://ws.123loadboard.com/PostingWS/PostingServiceV00.svc?xsd=xsd0", httpParameters = httpServiceParams );
								</cfscript>
								<cfif getHttpResponse.Statuscode eq '200 OK'>
									<cfset variables.status="success">
								<cfelse>
									<cfset variables.status="fail">
								</cfif>
								<cfif variables.status EQ "success">
									<!-----Delete asset from DB if any---->
									<cfquery name="Get123LoadBoardDbDelete" datasource="#variables.dsn#" >
										DELETE FROM LoadPostEverywhereDetails
										WHERE
											imprtref=<cfqueryparam value="#arguments.impref#" cfsqltype="cf_sql_bigint"> AND
											From_web=<cfqueryparam value="123LoadBoard" cfsqltype="cf_sql_varchar"> AND
											status=<cfqueryparam value="success" cfsqltype="cf_sql_varchar">
									</cfquery>
									<cfquery name="loadBoard123Flaginsert" datasource="#variables.dsn#">
										update Loads
										SET
											postto123loadboard=0
										WHERE
											LoadID=<cfqueryparam value="#arguments.LoadID#" cfsqltype="cf_sql_varchar">
									</cfquery>
									<cfset Alertvar = "This Load has been sucessfully deleted from 123 LoadBoard "/>
								<cfelse>
									<cfset Alertvar = "This Load is not sucessfully cancelled from 123 LoadBoard "/>
								</cfif>
							</cfif>
						<cfelseif arguments.postaction EQ 'A'>
							<!------Post asset to 123loadboard----->

								<cfsavecontent variable="myVariable">

									<?xml version="1.0" encoding="UTF-8"?>
										<s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/">

											<s:Header>
												<Action>http://ws.123loadboard.com/PostingWS/PostingServiceV00.svc?xsd=xsd0</Action>
											</s:Header>
											<s:Body>

												<PostLoad xmlns="http://schemas.123loadboard.com/2009/05/06">
													<PostProviderID>#arguments.PostProviderID#</PostProviderID>
													<UserName>#arguments.username#</UserName>
													<Password>#arguments.password#</Password>

													<Loads xmlns:i="http://www.w3.org/2001/XMLSchema-instance">
														<cfloop query="qryView123LoadBoard">
															<cfset count=qryView123LoadBoard.STOPNO+1>
															<Load>
																<cfif arguments.IncludeCarrierRate  EQ 1>
																	<Amount>#replace(CARRIERRATE, ",", "","ALL")#</Amount>
																	<AmountType>"Flat rate"</AmountType>
																<cfelse>
																	<AmountType i:nil="true"/>
																</cfif>
																<cfif len(trim(qryView123LoadBoard.commodity))>
																	<Commodity>#Replace(qryView123LoadBoard.commodity, "&", "and", "ALL")#</Commodity>
																</cfif>
																<DelivDate>#dateformat(qryView123LoadBoard.destinationstopdate,"yyyy-mm-dd'T'HH:mm:ss")#</DelivDate>
																<DestCity>#qryView123LoadBoard.destnationcity#</DestCity>
																<DestState>#qryView123LoadBoard.destinationstatecode#</DestState>
																<DispatcherEmail i:nil="true">#qryView123LoadBoard.emailid#</DispatcherEmail>
																<DispatcherExt i:nil="true"/>
																<DispatcherName i:nil="true">#qryView123LoadBoard.contactperson#</DispatcherName>
																<DispatcherPhone i:nil="true">#qryView123LoadBoard.phone#</DispatcherPhone>
																<EquipCode>#qryView123LoadBoard.loadboardcode#</EquipCode>
																<cfif len(trim(qryView123LoadBoard.Length)) AND isNumeric(trim(qryView123LoadBoard.Length))>
																	<Length>#trim(qryView123LoadBoard.Length)#</Length>
																</cfif>
																<LoadID>#left(qryView123LoadBoard.loadStopid,25)#</LoadID>
																<LoadSize><cfif qryView123LoadBoard.ISPARTIAL eq 0>TL<cfelse>LTL</cfif></LoadSize>
																<Notes>#escapeSpecialCharacters(qryView123LoadBoard.notes)#</Notes>
																<OrigCity>#qryView123LoadBoard.sourcecity#</OrigCity>
																<OrigLatitude>0</OrigLatitude>
																<OrigLongitude>0</OrigLongitude>
																<OrigState>#qryView123LoadBoard.sourcestatecode#</OrigState>
																<OrigZipcode i:nil="true">#qryView123LoadBoard.sourcepostalcode#</OrigZipcode>
																<PickUpDate>#dateformat(qryView123LoadBoard.sourcestopdate,"yyyy-mm-dd'T'HH:mm:ss")#</PickUpDate>
																<RepeatDaily>true</RepeatDaily>
																<TeamLoad i:nil="true"/>
																<TrackNo i:nil="true"/>
																<DelivTime i:nil="true">#qryView123LoadBoard.destinationstoptime#</DelivTime>
																<DestZipcode i:nil="true">#qryView123LoadBoard.destinationpostalcode#</DestZipcode>
																<LoadQty i:nil="true">#qryView123LoadBoard.qty#</LoadQty>
																<PickUpTime i:nil="true">#qryView123LoadBoard.sourcestoptime#</PickUpTime>
																<Stops>#count#</Stops>
																<cfif len(trim(qryView123LoadBoard.Weight)) AND isNumeric(trim(qryView123LoadBoard.Weight))>
																	<Weight>#trim(qryView123LoadBoard.Weight)#</Weight>
																</cfif>
															</Load>
														</cfloop>
														<cfif getLoadMultipleDates.recordcount>
															<cfif len(trim(qryView123LoadBoard.sourcestopdate)) AND len(trim(qryView123LoadBoard.destinationstopdate)) AND len(trim(getLoadMultipleDates.MultipleDates))>
																<cfset days = DateDiff('d', qryView123LoadBoard.sourcestopdate, qryView123LoadBoard.destinationstopdate)>
																<cfloop list="#getLoadMultipleDates.MultipleDates#" item="PickUpDate">
																	<cfif DateCompare(PickUpDate, qryView123LoadBoard.sourcestopdate , 'd') NEQ 0>
																		<cfset DeliveryDate = DateAdd('d', days, pickUpDate)>
																		<Load>
																			<cfif arguments.IncludeCarrierRate  EQ 1>
																				<Amount>#replace(CARRIERRATE, ",", "","ALL")#</Amount>
																				<AmountType>"Flat rate"</AmountType>
																			<cfelse>
																				<AmountType i:nil="true"/>
																			</cfif>
																			<cfif len(trim(qryView123LoadBoard.commodity))>
																				<Commodity>#Replace(qryView123LoadBoard.commodity, "&", "and", "ALL")#</Commodity>
																			</cfif>
																			<DelivDate>#dateformat(DeliveryDate,"yyyy-mm-dd'T'HH:mm:ss")#</DelivDate>
																			<DestCity>#qryView123LoadBoard.destnationcity#</DestCity>
																			<DestState>#qryView123LoadBoard.destinationstatecode#</DestState>
																			<DispatcherEmail i:nil="true">#qryView123LoadBoard.emailid#</DispatcherEmail>
																			<DispatcherExt i:nil="true"/>
																			<DispatcherName i:nil="true">#qryView123LoadBoard.contactperson#</DispatcherName>
																			<DispatcherPhone i:nil="true">#qryView123LoadBoard.phone#</DispatcherPhone>
																			<EquipCode>#qryView123LoadBoard.loadboardcode#</EquipCode>
																			<cfif len(trim(qryView123LoadBoard.Length)) AND isNumeric(trim(qryView123LoadBoard.Length))>
																				<Length>#trim(qryView123LoadBoard.Length)#</Length>
																			</cfif>
																			<LoadID>#left(qryView123LoadBoard.loadStopid,25)##DateFormat(pickUpDate,'YYYYMMDD')#</LoadID>
																			<LoadSize><cfif qryView123LoadBoard.ISPARTIAL eq 0>TL<cfelse>LTL</cfif></LoadSize>
																			<Notes>#escapeSpecialCharacters(qryView123LoadBoard.notes)#</Notes>
																			<OrigCity>#qryView123LoadBoard.sourcecity#</OrigCity>
																			<OrigLatitude>0</OrigLatitude>
																			<OrigLongitude>0</OrigLongitude>
																			<OrigState>#qryView123LoadBoard.sourcestatecode#</OrigState>
																			<OrigZipcode i:nil="true">#qryView123LoadBoard.sourcepostalcode#</OrigZipcode>
																			<PickUpDate>#dateformat(PickupDate,"yyyy-mm-dd'T'HH:mm:ss")#</PickUpDate>
																			<RepeatDaily>true</RepeatDaily>
																			<TeamLoad i:nil="true"/>
																			<TrackNo i:nil="true"/>
																			<DelivTime i:nil="true">#qryView123LoadBoard.destinationstoptime#</DelivTime>
																			<DestZipcode i:nil="true">#qryView123LoadBoard.destinationpostalcode#</DestZipcode>
																			<LoadQty i:nil="true">#qryView123LoadBoard.qty#</LoadQty>
																			<PickUpTime i:nil="true">#qryView123LoadBoard.sourcestoptime#</PickUpTime>
																			<Stops>1</Stops>
																			<cfif len(trim(qryView123LoadBoard.Weight)) AND isNumeric(trim(qryView123LoadBoard.Weight))>
																				<Weight>#trim(qryView123LoadBoard.Weight)#</Weight>
																			</cfif>
																		</Load>
																	</cfif>
																</cfloop>
															</cfif>
														</cfif>
													</Loads>
												</PostLoad>
											</s:Body>
										</s:Envelope>
								</cfsavecontent>
						
							<cfscript>
								var getHttpResponse = "";
								var httpServiceParams = [
									{
										type = "xml",
										value = trim(myVariable)
									}
								];
								getHttpResponse = getHttpResponseLoadBoard ( method = "post", setUrl = "http://ws.123loadboard.com/PostingWS/PostingServiceV00.svc?xsd=xsd0", httpParameters = httpServiceParams );
							</cfscript>

							<cfif getHttpResponse.Statuscode eq '200 OK'>
								<cfset variables.status="success">
							<cfelse>
								<cfset variables.status="fail">
							</cfif>
							<cfif getHttpResponse.Statuscode eq '200 OK'>
								<cfquery name="LoadBoard123Flaginsert" datasource="#variables.dsn#">
									update Loads SET postto123loadboard=1 WHERE LoadID=<cfqueryparam value="#arguments.LoadID#" cfsqltype="cf_sql_varchar">
								</cfquery>
								<cfquery name="Get123LoadBoardDbDelete" datasource="#variables.dsn#" >
									DELETE FROM LoadPostEverywhereDetails
									WHERE
										imprtref=<cfqueryparam value="#arguments.impref#" cfsqltype="cf_sql_bigint"> AND
										From_web=<cfqueryparam value="123LoadBoard" cfsqltype="cf_sql_varchar"> AND
										status=<cfqueryparam value="success" cfsqltype="cf_sql_varchar">
								</cfquery>
								<cfquery name="LoadboardInsertTOEveryWhere" datasource="#variables.dsn#">
									INSERT INTO LoadPostEverywhereDetails (Postrequest_text,Response_text,imprtref,From_web,status) VALUES(
										<cfqueryparam cfsqltype="cf_sql_varchar" value="#myVariable#">,
										<cfqueryparam cfsqltype="cf_sql_varchar" value="#getHttpResponse.Filecontent#">,
										<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.impref#">,
										'123LoadBoard',
										<cfqueryparam cfsqltype="cf_sql_varchar" value="#variables.status#">);
								</cfquery>
								<cfset Alertvar = "Your are successfully posted to 123 LoadBoard">
							<cfelse>
								<cfquery name="LoadBoard123Flaginsert" datasource="#variables.dsn#">
									update Loads SET postto123loadboard=0 WHERE LoadID=<cfqueryparam value="#arguments.LoadID#" cfsqltype="cf_sql_varchar">
								</cfquery>
								<cfset variables.messages = xmlparse(getHttpResponse.filecontent)>
								<cfset variables.AlertContent=XmlSearch(variables.messages,"s:Envelope/s:Body/s:Fault/detail")>
								<cfif arraylen(variables.AlertContent) gt 0>
									<cfset variables.AlertContent1=variables.AlertContent[1].XmlChildren[1].XmlChildren[1].XmlText>
									<cfif variables.AlertContent1 eq 1001>
										<cfset Alertvar="PostProviderID is invalid for posting load to 123Loadboard">
									<cfelseif variables.AlertContent1 eq 1002>
										<cfset Alertvar="Verify post provider ID failed for posting load to 123Loadboard">
									<cfelseif (variables.AlertContent1) eq 2002 or (variables.AlertContent1) eq 2001>
										<cfset Alertvar="Username/password is incorrect for posting load to 123Loadboard">
									<cfelseif variables.AlertContent1 eq 2003>
										<cfset Alertvar="2003 Verify account failed for posting load to 123Loadboard">
									<cfelseif variables.AlertContent1 eq 3001>
										<cfset Alertvar="Post load(s) failed for 123Loadboard">
									<cfelseif variables.AlertContent1 eq 3002>
										<cfset Alertvar=" Cancel load(s) failed for 123Loadboard.">
									<cfelse>
										<cfset Alertvar= " Your 123Loadboard Webservice posting Failed.">
									</cfif>
								</cfif>
							</cfif>
						<cfelseif arguments.postaction EQ 'U'>

							<cfif isDefined("form.oldshipperPickupDateMultiple") and len(trim(form.oldshipperPickupDateMultiple))>
								<cfset delLoadDates = ''>
								<cfloop list="#form.oldshipperPickupDateMultiple#" item="delDate">
									<cfif NOT ListContains('#getLoadMultipleDates.MultipleDates#', delDate)>
										<cfset delLoadDates = listAppend(delLoadDates, delDate)>
									</cfif>
								</cfloop>
							
								<cfif len(trim(delLoadDates))>
									<cfsavecontent variable="myVariable">
											<s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/">
												<s:Header>
													<Action>http://ws.123loadboard.com/PostingWS/PostingServiceV00.svc?xsd=xsd0</Action>
												</s:Header>
												<s:Body>
													<CancelLoad xmlns="http://schemas.123loadboard.com/2009/05/06">
														<PostProviderID>#arguments.PostProviderID#</PostProviderID>
														<UserName>#arguments.username#</UserName>
														<Password>#arguments.password#</Password>
														<LoadIDs xmlns:a="http://schemas.microsoft.com/2003/10/Serialization/Arrays" xmlns:i="http://www.w3.org/2001/XMLSchema-instance">
															<cfloop list="#delLoadDates#" item="dLoadDt">
																<a:string>#left(qryView123LoadBoard.loadStopid,25)##dateformat(dLoadDt,'YYYYMMDD')#</a:string>
															</cfloop>
		         										</LoadIDs>
													</CancelLoad>
												</s:Body>
											</s:Envelope>
									</cfsavecontent>
									<cfscript>
										var getHttpResponse = "";
										var httpServiceParams = [
											{
												type = "xml",
												value = trim(myVariable)
											}
										];
										getHttpResponse = getHttpResponseCancelLoad ( method = "post", setUrl = "http://ws.123loadboard.com/PostingWS/PostingServiceV00.svc?xsd=xsd0", httpParameters = httpServiceParams );
									</cfscript>
								</cfif>
							</cfif>	
							<!------Post asset to 123loadboard----->
								<cfsavecontent variable="myVariable">
									<?xml version="1.0" encoding="UTF-8"?>
										<s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/">
											<s:Header>
												<Action>http://ws.123loadboard.com/PostingWS/PostingServiceV00.svc?xsd=xsd0</Action>
											</s:Header>
											<s:Body>
												<PostLoad xmlns="http://schemas.123loadboard.com/2009/05/06">
													<PostProviderID>#arguments.PostProviderID#</PostProviderID>
													<UserName>#arguments.username#</UserName>
													<Password>#arguments.password#</Password>
													<Loads xmlns:i="http://www.w3.org/2001/XMLSchema-instance">
														<cfloop query="qryView123LoadBoard">
															<cfset count=qryView123LoadBoard.STOPNO+1>
															<Load>
																<cfif arguments.IncludeCarrierRate  EQ 1>
																	<Amount>#replace(CARRIERRATE, ",", "","ALL")#</Amount><!--- Ticket #838 123 load board issue --->
																	<AmountType>"Flat rate"</AmountType>
																<cfelse>
																	<AmountType i:nil="true"/>
																</cfif>
																<cfif len(trim(qryView123LoadBoard.commodity))>
																	<Commodity>#Replace(qryView123LoadBoard.commodity, "&", "and", "ALL")#</Commodity>
																</cfif>
																<DelivDate>#dateformat(qryView123LoadBoard.destinationstopdate,"yyyy-mm-dd'T'HH:mm:ss")#</DelivDate>
																<DestCity>#qryView123LoadBoard.destnationcity#</DestCity>
																<DestState>#qryView123LoadBoard.destinationstatecode#</DestState>
																<DispatcherEmail i:nil="true">#qryView123LoadBoard.emailid#</DispatcherEmail>
																<DispatcherExt i:nil="true"/>
																<DispatcherName i:nil="true">#qryView123LoadBoard.contactperson#</DispatcherName>
																<DispatcherPhone i:nil="true">#qryView123LoadBoard.phone#</DispatcherPhone>
																<EquipCode>#qryView123LoadBoard.loadboardcode#</EquipCode>
																<cfif len(trim(qryView123LoadBoard.Length)) AND isNumeric(trim(qryView123LoadBoard.Length))>
																	<Length>#trim(qryView123LoadBoard.Length)#</Length>
																</cfif>
																<LoadID>#left(qryView123LoadBoard.loadStopid,25)#</LoadID>
																<LoadSize><cfif qryView123LoadBoard.ISPARTIAL eq 0>TL<cfelse>LTL</cfif></LoadSize>
																<Notes>#escapeSpecialCharacters(qryView123LoadBoard.notes)#</Notes>
																<OrigCity>#qryView123LoadBoard.sourcecity#</OrigCity>
																<OrigLatitude>0</OrigLatitude>
																<OrigLongitude>0</OrigLongitude>
																<OrigState>#qryView123LoadBoard.sourcestatecode#</OrigState>
																<OrigZipcode i:nil="true">#qryView123LoadBoard.sourcepostalcode#</OrigZipcode>
																<PickUpDate>#dateformat(qryView123LoadBoard.sourcestopdate,"yyyy-mm-dd'T'HH:mm:ss")#</PickUpDate>
																<RepeatDaily>false</RepeatDaily>
																<TeamLoad i:nil="true"/>
																<TrackNo i:nil="true"/>
																<DelivTime i:nil="true">#qryView123LoadBoard.destinationstoptime#</DelivTime>
																<DestZipcode i:nil="true">#qryView123LoadBoard.destinationpostalcode#</DestZipcode>
																<LoadQty i:nil="true">#qryView123LoadBoard.qty#</LoadQty>
																<PickUpTime i:nil="true">#qryView123LoadBoard.sourcestoptime#</PickUpTime>
																<Stops>#count#</Stops>
																<cfif len(trim(qryView123LoadBoard.Weight)) AND isNumeric(trim(qryView123LoadBoard.Weight))>
																	<Weight>#trim(qryView123LoadBoard.Weight)#</Weight>
																</cfif>
															</Load>
														</cfloop>
														<cfif getLoadMultipleDates.recordcount>
															<cfif len(trim(qryView123LoadBoard.sourcestopdate)) AND len(trim(qryView123LoadBoard.destinationstopdate)) AND len(trim(getLoadMultipleDates.MultipleDates))>
																<cfset days = DateDiff('d', qryView123LoadBoard.sourcestopdate, qryView123LoadBoard.destinationstopdate)>
																<cfloop list="#getLoadMultipleDates.MultipleDates#" item="PickUpDate">
																	<cfif DateCompare(PickUpDate, qryView123LoadBoard.sourcestopdate , 'd') NEQ 0>
																		<cfset DeliveryDate = DateAdd('d', days, pickUpDate)>
																		<Load>
																			<cfif arguments.IncludeCarrierRate  EQ 1>
																				<Amount>#replace(CARRIERRATE, ",", "","ALL")#</Amount>
																				<AmountType>"Flat rate"</AmountType>
																			<cfelse>
																				<AmountType i:nil="true"/>
																			</cfif>
																			<cfif len(trim(qryView123LoadBoard.commodity))>
																				<Commodity>#Replace(qryView123LoadBoard.commodity, "&", "and", "ALL")#</Commodity>
																			</cfif>
																			<DelivDate>#dateformat(DeliveryDate,"yyyy-mm-dd'T'HH:mm:ss")#</DelivDate>
																			<DestCity>#qryView123LoadBoard.destnationcity#</DestCity>
																			<DestState>#qryView123LoadBoard.destinationstatecode#</DestState>
																			<DispatcherEmail i:nil="true">#qryView123LoadBoard.emailid#</DispatcherEmail>
																			<DispatcherExt i:nil="true"/>
																			<DispatcherName i:nil="true">#qryView123LoadBoard.contactperson#</DispatcherName>
																			<DispatcherPhone i:nil="true">#qryView123LoadBoard.phone#</DispatcherPhone>
																			<EquipCode>#qryView123LoadBoard.loadboardcode#</EquipCode>
																			<cfif len(trim(qryView123LoadBoard.Length)) AND isNumeric(trim(qryView123LoadBoard.Length))>
																				<Length>#trim(qryView123LoadBoard.Length)#</Length>
																			</cfif>
																			<LoadID>#left(qryView123LoadBoard.loadStopid,25)##DateFormat(pickUpDate,'YYYYMMDD')#</LoadID>
																			<LoadSize><cfif qryView123LoadBoard.ISPARTIAL eq 0>TL<cfelse>LTL</cfif></LoadSize>
																			<Notes>#escapeSpecialCharacters(qryView123LoadBoard.notes)#</Notes>
																			<OrigCity>#qryView123LoadBoard.sourcecity#</OrigCity>
																			<OrigLatitude>0</OrigLatitude>
																			<OrigLongitude>0</OrigLongitude>
																			<OrigState>#qryView123LoadBoard.sourcestatecode#</OrigState>
																			<OrigZipcode i:nil="true">#qryView123LoadBoard.sourcepostalcode#</OrigZipcode>
																			<PickUpDate>#dateformat(PickupDate,"yyyy-mm-dd'T'HH:mm:ss")#</PickUpDate>
																			<RepeatDaily>true</RepeatDaily>
																			<TeamLoad i:nil="true"/>
																			<TrackNo i:nil="true"/>
																			<DelivTime i:nil="true">#qryView123LoadBoard.destinationstoptime#</DelivTime>
																			<DestZipcode i:nil="true">#qryView123LoadBoard.destinationpostalcode#</DestZipcode>
																			<LoadQty i:nil="true">#qryView123LoadBoard.qty#</LoadQty>
																			<PickUpTime i:nil="true">#qryView123LoadBoard.sourcestoptime#</PickUpTime>
																			<Stops>1</Stops>
																			<cfif len(trim(qryView123LoadBoard.Weight)) AND isNumeric(trim(qryView123LoadBoard.Weight))>
																				<Weight>#trim(qryView123LoadBoard.Weight)#</Weight>
																			</cfif>
																		</Load>
																	</cfif>
																</cfloop>
															</cfif>
														</cfif>
													</Loads>
												</PostLoad>
											</s:Body>
										</s:Envelope>
								</cfsavecontent>
							<cfscript>
								var getHttpResponse = "";
								var httpServiceParams = [
									{
										type = "xml",
										value = trim(myVariable)
									}
								];
								getHttpResponse = getHttpResponseLoadBoard ( method = "post", setUrl = "http://ws.123loadboard.com/PostingWS/PostingServiceV00.svc?xsd=xsd0", httpParameters = httpServiceParams );
							</cfscript>
							<cfif getHttpResponse.Statuscode eq '200 OK'>
								<cfset variables.status="success">
							<cfelse>
								<cfset variables.status="fail">
							</cfif>
							<cfif getHttpResponse.Statuscode eq '200 OK'>
								<cfquery name="LoadBoard123Flaginsert" datasource="#variables.dsn#">
									update Loads SET postto123loadboard=1 WHERE LoadID=<cfqueryparam value="#arguments.LoadID#" cfsqltype="cf_sql_varchar">
								</cfquery>
								<cfquery name="Get123LoadBoardDbDelete" datasource="#variables.dsn#" >
									DELETE FROM LoadPostEverywhereDetails
									WHERE
										imprtref=<cfqueryparam value="#arguments.impref#" cfsqltype="cf_sql_bigint"> AND
										From_web=<cfqueryparam value="123LoadBoard" cfsqltype="cf_sql_varchar"> AND
										status=<cfqueryparam value="success" cfsqltype="cf_sql_varchar">
								</cfquery>
								<cfquery name="LoadboardInsertTOEveryWhere" datasource="#variables.dsn#">
									INSERT INTO LoadPostEverywhereDetails (Postrequest_text,Response_text,imprtref,From_web,status) VALUES(
										<cfqueryparam cfsqltype="cf_sql_varchar" value="#myVariable#">,
										<cfqueryparam cfsqltype="cf_sql_varchar" value="#getHttpResponse.Filecontent#">,
										<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.impref#">,
										'123LoadBoard',
										<cfqueryparam cfsqltype="cf_sql_varchar" value="#variables.status#">)
								</cfquery>
								<cfset Alertvar = "Your are successfully posted to 123 LoadBoard">
							<cfelse>
								<cfquery name="LoadBoard123Flaginsert" datasource="#variables.dsn#">
									update Loads SET postto123loadboard=0 WHERE LoadID=<cfqueryparam value="#arguments.LoadID#" cfsqltype="cf_sql_varchar">
								</cfquery>
								<cfset variables.messages = xmlparse(getHttpResponse.filecontent)>
								<cfset variables.AlertContent=XmlSearch(variables.messages,"s:Envelope/s:Body/s:Fault/detail")>
								<cfif arraylen(variables.AlertContent) gt 0>
									<cfset variables.AlertContent1=variables.AlertContent[1].XmlChildren[1].XmlChildren[1].XmlText>
									<cfif variables.AlertContent1 eq 1001>
										<cfset Alertvar="PostProviderID is invalid for posting load to 123Loadboard">
									<cfelseif variables.AlertContent1 eq 1002>
										<cfset Alertvar="Verify post provider ID failed for posting load to 123Loadboard">
									<cfelseif (variables.AlertContent1) eq 2002 or (variables.AlertContent1) eq 2001>
										<cfset Alertvar="Username/password is incorrect for posting load to 123Loadboard">
									<cfelseif variables.AlertContent1 eq 2003>
										<cfset Alertvar="2003 Verify account failed for posting load to 123Loadboard">
									<cfelseif variables.AlertContent1 eq 3001>
										<cfset Alertvar="Post load(s) failed for 123Loadboard">
									<cfelseif variables.AlertContent1 eq 3002>
										<cfset Alertvar=" Cancel load(s) failed for 123Loadboard.">
									<cfelse>
										<cfset Alertvar= " Your 123Loadboard Webservice posting Failed.">
									</cfif>
								</cfif>
							</cfif>
						</cfif>
					</cftransaction>
					<cfif Alertvar neq 1>
						<cfset Alertvar="123Loadboard Says : "&Alertvar />
					</cfif>
				</cfoutput>
				<cfreturn Alertvar />
				<cfcatch type="any">
					<cfset Alertvar='123LoadBoard have connection failure error. sorry please try later' />
					<cfreturn Alertvar />
				</cfcatch>
			</cftry>



		</cffunction>
		<!------------- Webservice for posting load in 123loadboard start----------------->
		<!---function to find the current row of a query--->
		<cfscript>
			function GetQueryRow(query, rowNumber) {
				var i = 0;
				var rowData = StructNew();
				var cols = ListToArray(query.columnList);
				for (i = 1; i lte ArrayLen(cols); i = i + 1) {
					rowData[cols[i]] = query[cols[i]][rowNumber];
				}
				return rowData;
			}
		</cfscript>
		<!-----------Live url processing for postload start----------------->

		<cffunction name="getHttpResponseLoadBoard" access="public" returntype="any">
			<cfargument name="method" type="string" required="yes">
			<cfargument name="setUrl" type="string" required="yes">
			<cfargument name="httpParameters" type="array" required="yes">
			<cfscript>
				var httpService = new http();
				httpService.setMethod(arguments.method);
				httpService.setUrl(arguments.setUrl);
				httpService.addParam(type="header",name="Content-Type", value="text/xml; charset=utf-8");
				httpService.addParam(type="header",name="host", value="ws.123loadboard.com");
				httpService.addParam(type="header",name="SOAPAction", value="PostLoad");
				if(arrayLen(arguments.httpParameters)){
					for(var parameter = 1; parameter <= arrayLen(arguments.httpParameters); parameter++) {
						httpService.addParam(type = arguments.httpParameters[parameter].type,value = arguments.httpParameters[parameter].value);
					}
				}
				var httpResponse = httpService.send().getPrefix();
				return httpResponse;
			</cfscript>
		</cffunction>
		<!-----------Live url processing for postload end----------------->
		<!-----------Live url processing for cancelload start----------------->
			<cffunction name="getHttpResponseCancelLoad" access="public" returntype="any">
				<cfargument name="method" type="string" required="yes">
				<cfargument name="setUrl" type="string" required="yes">
				<cfargument name="httpParameters" type="array" required="yes">
				<cfscript>
					var httpService = new http();
					httpService.setMethod(arguments.method);
					httpService.setUrl(arguments.setUrl);
					httpService.addParam(type="header",name="Content-Type", value="text/xml; charset=utf-8");
					httpService.addParam(type="header",name="host", value="ws.123loadboard.com");
					httpService.addParam(type="header",name="SOAPAction", value="CancelLoad");
					if(arrayLen(arguments.httpParameters)){
						for(var parameter = 1; parameter <= arrayLen(arguments.httpParameters); parameter++) {
							httpService.addParam(type = arguments.httpParameters[parameter].type,value = arguments.httpParameters[parameter].value);
						}
					}
					var httpResponse = httpService.send().getPrefix();
					return httpResponse;
				</cfscript>
			</cffunction>
			<!-----------Live url processing for cancelload end----------------->

	<!--- add load--->
	<cffunction name="addLoad" access="public" returntype="any">
		<cfargument name="frmstruct" type="struct" required="yes">
	 	<cfscript>
			variables.objCustomerGatewayAdd = #request.cfcpath#&".loadgatewayadd";
		</cfscript>
		<cfinvoke component ="#variables.objCustomerGatewayadd#" method="addload" formStruct="#arguments.frmstruct#" idReturn="true" returnvariable="Msg"/>
		<cfreturn Msg>
	</cffunction>

	<cffunction name="getCommissionReportInfo" access="public" returntype="query">
	    <cfargument name="groupBy" type="string" required="yes">
	    <cfargument name="orderDateFrom" type="string" required="yes">
	    <cfargument name="orderDateTo" type="string" required="yes">
	    <cfargument name="salesRepFrom" type="string" required="yes">
	    <cfargument name="salesRepTo" type="string" required="yes">
	    <cfargument name="dispatcherFrom" type="string" required="yes">
	    <cfargument name="dispatcherTo" type="string" required="yes">
		<cfargument name="statusTo" type="string" required="yes">
		<cfargument name="statusFrom" type="string" required="yes">

	    <cfstoredproc procedure="USP_GetLoadsForCommissionReportNew" datasource="#variables.dsn#">
	    	<cfprocparam value="#groupBy#" cfsqltype="cf_sql_varchar">
	        <cfprocparam value="#orderDateFrom#" cfsqltype="cf_sql_varchar">
	        <cfprocparam value="#orderDateTo#" cfsqltype="cf_sql_varchar">
	        <cfprocparam value="#salesRepFrom#" cfsqltype="cf_sql_varchar">
	        <cfprocparam value="#salesRepTo#" cfsqltype="cf_sql_varchar">
	        <cfprocparam value="#dispatcherFrom#" cfsqltype="cf_sql_varchar">
	        <cfprocparam value="#dispatcherTo#" cfsqltype="cf_sql_varchar">
			<cfprocparam value="#statusTo#" cfsqltype="cf_sql_varchar">
			<cfprocparam value="#statusFrom#" cfsqltype="cf_sql_varchar">

	        <cfprocresult name="qCommissionReportLoads">
	    </cfstoredproc>

		<cfreturn qCommissionReportLoads>

	</cffunction>


	<!--- A seperate Method is created because method:EditLoad has become too large and causing an Error because of its being extra large
	Logically this method is considered to be called from within the application via method:EditLoad
	Never call it alone otherwise you'll cause the DB inconsistancy --->
	<cffunction name="RunUSP_UpdateLoad" access="public" returntype="string">
		<cfargument name="frmstruct" type="struct" required="yes">

		<cfinvoke method="getSystemSetupOptions" returnvariable="request.qSystemSetupOptions">
	    <cfset variables.IsConcatCarrierDriverIdentifier = request.qSystemSetupOptions.IsConcatCarrierDriverIdentifier />
	    <cfset variables.freightBroker = request.qSystemSetupOptions.freightBroker />

		<cfif isdefined('arguments.frmstruct.posttoloadboard')>
			<cfset posttoloadboard=True>
		<cfelse>
			<cfset posttoloadboard=False>
		</cfif>
		<cfset posttoTranscore=False><!--- Making default value to 0. If the post is success, then it will updated to 1 later. --->
		<cfif isdefined('arguments.frmstruct.posttoTranscore')>
			<cfset posttoTranscore=true>
		</cfif>

		<cfset PostTo123LoadBoard=False><!--- Making default value to 0. If the post is success, then it will updated to 1 later. --->
		<cfif isdefined('arguments.frmstruct.PostTo123LoadBoard')>
			<cfset PostTo123LoadBoard=true>
		</cfif>
		<cfif isdefined('arguments.frmstruct.ARExported')>
			<cfset ARExported="1">
		<cfelse>
			<cfset ARExported="0">
		</cfif>

		<cfif isdefined('arguments.frmstruct.APExported')>
			<cfset APExported="1">
		<cfelse>
			<cfset APExported="0">
		</cfif>

		<cfif NOT structKeyExists(arguments.frmstruct,"InvoiceNumber")>
			<cfset arguments.frmstruct.InvoiceNumber = 0>
		</cfif>

		<cfif request.qSystemSetupOptions.AutomaticFactoringFee eq 1 and structKeyExists(arguments.frmstruct, "FactoringFeePercent") AND isNumeric(arguments.frmstruct.FactoringFeePercent)>
			<cfset FF = arguments.frmstruct.FactoringFeePercent>
		<cfelse>
			<cfset FF = 0>
		</cfif>

		<cftransaction>
			<cfquery name="getinvoiceNumber" datasource="#variables.dsn#">
				select invoiceNumber from loads WITH (NOLOCK)
				where
					loadNumber =
					<cfif NOT len(trim(arguments.frmstruct.loadManualNo))>
			            <cfqueryparam cfsqltype="cf_sql_bigint" value="#trim(arguments.frmstruct.loadManualNo)#"  null="yes" />
			        <cfelse>
			            <cfqueryparam cfsqltype="cf_sql_bigint" value="#trim(arguments.frmstruct.loadManualNo)#" />
			        </cfif>
			       and customerid in (select customerid from CustomerOffices WITH (NOLOCK) inner join offices WITH (NOLOCK) on CustomerOffices.officeid = offices.officeid where offices.companyid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#session.companyid#">)
			</cfquery>
			<cfif getinvoiceNumber.invoiceNumber NEQ "" AND getinvoiceNumber.invoiceNumber NEQ 0>
				<cfset variables.invoiceNumber = getinvoiceNumber.invoiceNumber>
			<cfelse>
				<cfquery name="getloadmanual" datasource="#variables.dsn#">
					SELECT MinimumLoadInvoiceNumber FROM SystemConfig WHERE CompanyID = <cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar">
				</cfquery>
				<cfif getloadmanual.MinimumLoadInvoiceNumber NEQ 0>
					<cfquery name="getloadmanual" datasource="#variables.dsn#">
						SELECT invoiceNumber=[MinimumLoadInvoiceNumber]+1 FROM SystemConfig WHERE CompanyID = <cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar">
					</cfquery>
					<cfquery name="qrySearchAllInvoiceNumbers" datasource="#variables.dsn#">
						select invoiceNumber from loads
						where
							invoiceNumber=<cfqueryparam VALUE="#getloadmanual.invoiceNumber#" cfsqltype="cf_sql_integer"> and
							loadNumber !=<cfqueryparam VALUE="#arguments.frmstruct.loadManualNo#" cfsqltype="cf_sql_bigint">
							and customerid in (select customerid from CustomerOffices inner join offices on CustomerOffices.officeid = offices.officeid where offices.companyid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#session.companyid#">)
					</cfquery>
					<cfif qrySearchAllInvoiceNumbers.recordcount>
						<cfquery name="getloadmanual" datasource="#variables.dsn#">
							SELECT  max(invoiceNumber)+1 as invoiceNumber FROM Loads where customerid in (select customerid from CustomerOffices inner join offices on CustomerOffices.officeid = offices.officeid where offices.companyid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#session.companyid#">)
						</cfquery>
					</cfif>
					<cfquery name="UpdateloadInvoiceNumber" datasource="#variables.dsn#">
						  update SystemConfig set MinimumLoadInvoiceNumber= <cfqueryparam value="#getloadmanual.invoiceNumber#" cfsqltype="cf_sql_integer" >  WHERE CompanyID = <cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar">
					</cfquery>
					<cfset variables.invoiceNumber = getloadmanual.invoiceNumber>
				<cfelse>
					<cfset variables.invoiceNumber = 0>
				</cfif>
			</cfif>

			<cfset var loadManualNo=arguments.frmstruct.loadManualNo>

			<cfset var PrevloadNo=arguments.frmstruct.LoadNumber>
			<cfset var custRatePerMile = ReplaceNoCase(arguments.frmstruct.CustomerRatePerMile,'$','','ALL')>
			<cfset carRatePerMile = ReplaceNoCase(arguments.frmstruct.CarrierRatePerMile,'$','','ALL')>
			<cfset var custRatePerMile = ReplaceNoCase(custRatePerMile,',','','ALL')>
			<cfset carRatePerMile = ReplaceNoCase(carRatePerMile,',','','ALL')>

			<cfif structKeyExists(arguments.frmstruct, "CustomerMiles")>
				<cfset var custMilesCharges = ReplaceNoCase(arguments.frmstruct.CustomerMiles,'$','','ALL')>
				<cfset custMilesCharges = ReplaceNoCase(custMilesCharges,',','','ALL')>
			<cfelse>
				<cfset custMilesCharges = 0>
			</cfif>
			<cfif structKeyExists(arguments.frmstruct, "CarrierMiles")>
				<cfset var carMilesCharges = ReplaceNoCase(arguments.frmstruct.CarrierMiles,'$','','ALL')>
				<cfset carMilesCharges = ReplaceNoCase(carMilesCharges,',','','ALL')>
			<cfelse>
				<cfset carMilesCharges = 0>
			</cfif>

			<cfset var custCommodCharges = ReplaceNoCase(arguments.frmstruct.TotalCustcommodities,'$','','ALL')>
			<cfset custCommodCharges = ReplaceNoCase(custCommodCharges,',','','ALL')>
			<cfset var carCommodCharges = ReplaceNoCase(arguments.frmstruct.TotalCarcommodities,'$','','ALL')>
			<cfset carCommodCharges = ReplaceNoCase(carCommodCharges,',','','ALL')>

			<cfset var custFlatRate = ReplaceNoCase(arguments.frmstruct.CustomerRate,'$','','ALL')>
			<cfset custFlatRate = ReplaceNoCase(custFlatRate,',','','ALL')>
			<cfset var carFlatRate = ReplaceNoCase(arguments.frmstruct.CarrierRate,'$','','ALL')>
			<cfset carFlatRate = ReplaceNoCase(carFlatRate,',','','ALL')>

			<cfset var CustomerMilesCalc = ReplaceNoCase(arguments.frmstruct.CustomerMilesCalc,'$','','ALL')>
			<cfset CustomerMilesCalc = ReplaceNoCase(CustomerMilesCalc,',','','ALL')>

			<cfset var CarrierMilesCalc = ReplaceNoCase(arguments.frmstruct.CarrierMilesCalc,'$','','ALL')>
			<cfset CarrierMilesCalc = ReplaceNoCase(CarrierMilesCalc,',','','ALL')>

			<cfif isdefined('arguments.frmstruct.shipBlind')>
				<cfset shipBlind=True>
			<cfelse>
				<cfset shipBlind=False>
			</cfif>
			<cfif isdefined('arguments.frmstruct.ConsBlind')>
				<cfset ConsBlind=True>
			<cfelse>
				<cfset ConsBlind=False>
			</cfif>
			<cfif isdefined('arguments.frmstruct.ISPARTIAL')>
				<cfset ISPARTIAL=1>
			<cfelse>
				<cfset ISPARTIAL=0>
			</cfif>

			<cfif structKeyExists(arguments.frmstruct,"readyDat") and isDate(arguments.frmstruct.readyDat)>
				<cfset readyDate = arguments.frmstruct.readyDat>
			<cfelse>
				<cfset readyDate = "">
			</cfif>

			<cfif structKeyExists(arguments.frmstruct,"arriveDat") and isDate(arguments.frmstruct.arriveDat)>
				<cfset arriveDate = arguments.frmstruct.arriveDat>
			<cfelse>
				<cfset arriveDate = "">
			</cfif>

			<cfif structKeyExists(arguments.frmstruct,"Excused")>
				<cfset isExcused = arguments.frmstruct.Excused>
			<cfelse>
				<cfset isExcused = "">
			</cfif>

			<cfif structKeyExists(arguments.frmstruct,"bookedBy")>
				<cfset bookedBy = arguments.frmstruct.bookedBy>
			<cfelse>
				<cfset bookedBy = "">
			</cfif>
			<!--- BEGIN: 604: Add a column to All Loads/ My Loads : Add DeadHead Miles for Load--->
			<cfif structKeyExists(arguments.frmstruct,"DeadHeadMiles") AND arguments.frmstruct.DeadHeadMiles NEQ "">
				<cfset DeadHeadMiles = arguments.frmstruct.DeadHeadMiles>
			<cfelse>
				<cfset DeadHeadMiles = 0>
			</cfif>
			<!--- END: 604: Add a column to All Loads/ My Loads : Add DeadHead Miles for Load--->
			<cfif structKeyExists(arguments.frmstruct,"postCarrierRatetoloadboard")>
				<cfset postCarrierRatetoloadboard = arguments.frmstruct.postCarrierRatetoloadboard>
			<cfelse>
				<cfset postCarrierRatetoloadboard = 0>
			</cfif>

			<cfif structKeyExists(arguments.frmstruct,"postCarrierRatetoTranscore")>
				<cfset postCarrierRatetoTranscore = arguments.frmstruct.postCarrierRatetoTranscore>
			<cfelse>
				<cfset postCarrierRatetoTranscore = 0>
			</cfif>

			<cfif structKeyExists(arguments.frmstruct,"postCarrierRateto123LoadBoard")>
				<cfset postCarrierRateto123LoadBoard = arguments.frmstruct.postCarrierRateto123LoadBoard>
			<cfelse>
				<cfset postCarrierRateto123LoadBoard = 0>
			</cfif>
			
			<CFSTOREDPROC PROCEDURE="USP_UpdateLoad" DATASOURCE="#variables.dsn#" debug="true">
				<cfif isdefined('arguments.frmstruct.CARRIERINVOICENUMBER') and arguments.frmstruct.CARRIERINVOICENUMBER GT 0>
					<CFPROCPARAM VALUE="#val(arguments.frmstruct.CARRIERINVOICENUMBER)#" cfsqltype="CF_SQL_BIGINT">
				<cfelse>
					<CFPROCPARAM VALUE="0" cfsqltype="CF_SQL_BIGINT">
				</cfif>
				<CFPROCPARAM VALUE="#arguments.frmstruct.editid#" cfsqltype="CF_SQL_VARCHAR">
				<CFPROCPARAM VALUE="#loadManualNo#" cfsqltype="CF_SQL_BIGINT">
				<CFPROCPARAM VALUE="#PrevloadNo#" cfsqltype="CF_SQL_BIGINT">

				<CFPROCPARAM VALUE="#arguments.frmstruct.cutomerIdAutoValueContainer#" cfsqltype="CF_SQL_VARCHAR">
				<cfif isdefined('arguments.frmstruct.SALESPERSON') and len(arguments.frmstruct.SALESPERSON) gt 1>
					<CFPROCPARAM VALUE="#arguments.frmstruct.SALESPERSON#" cfsqltype="CF_SQL_VARCHAR">
				<cfelse>
					<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR" null="true">
				</cfif>
				<cfif isdefined('arguments.frmstruct.dispatcher') and len(arguments.frmstruct.dispatcher) gt 1>
					<CFPROCPARAM VALUE="#arguments.frmstruct.dispatcher#" cfsqltype="CF_SQL_VARCHAR">
				<cfelse>
					<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR">
				</cfif>
				<CFPROCPARAM VALUE="#arguments.frmstruct.LOADSTATUS#" cfsqltype="CF_SQL_VARCHAR">
				<CFPROCPARAM VALUE="#posttoloadboard#" cfsqltype="CF_SQL_VARCHAR">
				<CFPROCPARAM VALUE="#posttoTranscore#" cfsqltype="CF_SQL_VARCHAR">
				<CFPROCPARAM VALUE="#PostTo123LoadBoard#" cfsqltype="CF_SQL_VARCHAR">
				<CFPROCPARAM VALUE="#postCarrierRatetoloadboard#" cfsqltype="CF_SQL_BIT">
				<CFPROCPARAM VALUE="#postCarrierRatetoTranscore#" cfsqltype="CF_SQL_BIT">
				<CFPROCPARAM VALUE="#postCarrierRateto123LoadBoard#" cfsqltype="CF_SQL_BIT">
				<CFPROCPARAM VALUE="#arguments.frmstruct.notes#" cfsqltype="CF_SQL_VARCHAR">
				<CFPROCPARAM VALUE="#arguments.frmstruct.dispatchnotes#" cfsqltype="CF_SQL_VARCHAR">
				<CFPROCPARAM VALUE="#arguments.frmstruct.carriernotes#" cfsqltype="CF_SQL_VARCHAR">
				<CFPROCPARAM VALUE="#arguments.frmstruct.pricingnotes#" cfsqltype="CF_SQL_VARCHAR">
				<CFPROCPARAM VALUE="#arguments.frmstruct.CUSTOMERPO#" cfsqltype="CF_SQL_VARCHAR">
				<CFPROCPARAM VALUE="#arguments.frmstruct.CUSTOMERBOL#" cfsqltype="CF_SQL_VARCHAR">
				<cfset totCarChg = replace(arguments.frmstruct.TotalCarrierCharges,'$',"")>
				<cfset totCustChg = replace(arguments.frmstruct.TotalCustomerCharges,'$',"")>
				<CFPROCPARAM VALUE="#VAL(totCarChg)#" cfsqltype="CF_SQL_VARCHAR">
				<CFPROCPARAM VALUE="#VAL(totCustChg)#" cfsqltype="CF_SQL_VARCHAR">
				<CFPROCPARAM VALUE="#VAL(carFlatRate)#" cfsqltype="cf_sql_money">
				<CFPROCPARAM VALUE="#VAL(custFlatRate)#" cfsqltype="cf_sql_money">
				<cfif isdefined('arguments.frmstruct.carrierID') and len(arguments.frmstruct.carrierID) gt 1>
					<CFPROCPARAM VALUE="#trim(listfirst(arguments.frmstruct.carrierID,','))#" cfsqltype="CF_SQL_VARCHAR">
				<cfelse>
					<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR">
				</cfif>
				<cfif isdefined('arguments.frmstruct.carrierOfficeID') and len(arguments.frmstruct.carrierOfficeID) gt 1>
					<CFPROCPARAM VALUE="#arguments.frmstruct.carrierOfficeID#" cfsqltype="CF_SQL_VARCHAR">
				<cfelse>
					<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR">
				</cfif>
				<CFPROCPARAM VALUE="#arguments.frmstruct.equipment#" cfsqltype="CF_SQL_VARCHAR">
				<cfif isdefined('arguments.frmstruct.driver') and len(arguments.frmstruct.driver)>
					<CFPROCPARAM VALUE="#arguments.frmstruct.driver#" cfsqltype="CF_SQL_VARCHAR">
				<cfelse>
					<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR"  null="Yes">	
				</cfif>
				<CFPROCPARAM VALUE="#trim(arguments.frmstruct.drivercell)#" cfsqltype="CF_SQL_VARCHAR">
				<CFPROCPARAM VALUE="#arguments.frmstruct.TRUCKNO#" cfsqltype="CF_SQL_VARCHAR">
				<CFPROCPARAM VALUE="#arguments.frmstruct.trailerNo#" cfsqltype="CF_SQL_VARCHAR">
				<CFPROCPARAM VALUE="#arguments.frmstruct.BookedWith#" cfsqltype="CF_SQL_VARCHAR">
				<CFPROCPARAM VALUE="#arguments.frmstruct.shipperPickupNO1#" cfsqltype="CF_SQL_VARCHAR">
				<CFPROCPARAM VALUE="#arguments.frmstruct.shipperPickupDate#" cfsqltype="CF_SQL_dATE" null="#yesNoFormat(NOT len(arguments.frmstruct.shipperPickupDate) OR NOT isdate(arguments.frmstruct.shipperPickupDate))#">
				<CFPROCPARAM VALUE="#arguments.frmstruct.shipperPickupTime#" cfsqltype="CF_SQL_VARCHAR">
				<CFPROCPARAM VALUE="#arguments.frmstruct.shipperTimeIn#" cfsqltype="CF_SQL_VARCHAR">
				<CFPROCPARAM VALUE="#arguments.frmstruct.shipperTimeOut#" cfsqltype="CF_SQL_VARCHAR">
				<CFPROCPARAM VALUE="#arguments.frmstruct.consigneePickupNO#" cfsqltype="CF_SQL_VARCHAR">
				<cfif structkeyexists(arguments.frmstruct,"consigneePickupDate#arguments.frmstruct.totalstop#") >
					<CFPROCPARAM VALUE="#arguments.frmstruct["consigneePickupDate#arguments.frmstruct.totalstop#"]#" cfsqltype="cf_sql_date" null="#yesNoFormat(NOT len(arguments.frmstruct["consigneePickupDate#arguments.frmstruct.totalstop#"]) OR NOT isdate(arguments.frmstruct["consigneePickupDate#arguments.frmstruct.totalstop#"]))#">
				<cfelse>
					<CFPROCPARAM VALUE="#arguments.frmstruct.consigneePickupDate#" cfsqltype="cf_sql_date" null="#yesNoFormat(NOT len(arguments.frmstruct.consigneePickupDate) OR NOT isdate(arguments.frmstruct.consigneePickupDate))#">
				</cfif>
				<CFPROCPARAM VALUE="#arguments.frmstruct.consigneePickupTime#" cfsqltype="CF_SQL_VARCHAR">
				<CFPROCPARAM VALUE="#arguments.frmstruct.consigneeTimeIn#" cfsqltype="CF_SQL_VARCHAR">
				<CFPROCPARAM VALUE="#arguments.frmstruct.consigneeTimeOut#" cfsqltype="CF_SQL_VARCHAR">
				<CFPROCPARAM VALUE="#session.adminUserName#" cfsqltype="CF_SQL_VARCHAR">
				<CFPROCPARAM VALUE="#cgi.REMOTE_ADDR#" cfsqltype="CF_SQL_VARCHAR">
				<CFPROCPARAM value="#VAL(custRatePerMile)#"  cfsqltype="cf_sql_money">
				<CFPROCPARAM value="#VAL(carRatePerMile)#"  cfsqltype="cf_sql_money">
				<cfif isNumeric(CustomerMilesCalc)>
					<CFPROCPARAM value="#CustomerMilesCalc#"  cfsqltype="cf_sql_float">
				<cfelse>
					<CFPROCPARAM value="0"  cfsqltype="cf_sql_float">
				</cfif>
				<cfif isNumeric(CarrierMilesCalc)>
					<CFPROCPARAM value="#CarrierMilesCalc#"  cfsqltype="cf_sql_float">
				<cfelse>
					<CFPROCPARAM value="0"  cfsqltype="cf_sql_float">
				</cfif>
				<CFPROCPARAM VALUE="#session.officeid#" cfsqltype="CF_SQL_VARCHAR">
				<CFPROCPARAM value="#URLDecode(arguments.frmstruct.orderDate)#"  cfsqltype="cf_sql_date">
				<CFPROCPARAM value="#arguments.frmstruct.BillDate#"  cfsqltype="cf_sql_date" null="#not len(arguments.frmstruct.BillDate)#">
				<cfset totalProfit = replace(arguments.frmstruct.totalProfit,'$',"")>
				<CFPROCPARAM value="#VAL(totalProfit)#"  cfsqltype="cf_sql_money">
				<CFPROCPARAM VALUE="#ARExported#" cfsqltype="CF_SQL_VARCHAR">
				<CFPROCPARAM VALUE="#APExported#" cfsqltype="CF_SQL_VARCHAR">
				<cfif isNumeric(custMilesCharges)>
					<CFPROCPARAM VALUE="#custMilesCharges#" cfsqltype="CF_SQL_VARCHAR">
				<cfelse>
					<CFPROCPARAM VALUE="0" cfsqltype="CF_SQL_VARCHAR">
				</cfif>
				<cfif isNumeric(carMilesCharges)>
					<CFPROCPARAM VALUE="#carMilesCharges#" cfsqltype="CF_SQL_VARCHAR">
				<cfelse>
					<CFPROCPARAM VALUE="0" cfsqltype="CF_SQL_VARCHAR">
				</cfif>
				<CFPROCPARAM VALUE="#custCommodCharges#" cfsqltype="CF_SQL_VARCHAR">
				<CFPROCPARAM VALUE="#carCommodCharges#" cfsqltype="CF_SQL_VARCHAR">
				<cfif structKeyExists(arguments.frmstruct, "customerAddress")>
					<CFPROCPARAM VALUE="#arguments.frmstruct.customerAddress#" cfsqltype="CF_SQL_VARCHAR">
				<cfelse>
					<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR">
				</cfif>
				<cfif structKeyExists(arguments.frmstruct, "customerCity")>
					<CFPROCPARAM VALUE="#arguments.frmstruct.customerCity#" cfsqltype="CF_SQL_VARCHAR">
				<cfelse>
					<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR">
				</cfif>
				<cfif structKeyExists(arguments.frmstruct, "customerState")>
					<CFPROCPARAM VALUE="#arguments.frmstruct.customerState#" cfsqltype="CF_SQL_VARCHAR">
				<cfelse>
					<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR">
				</cfif>
				<cfif structKeyExists(arguments.frmstruct, "customerZipCode")>
					<CFPROCPARAM VALUE="#arguments.frmstruct.customerZipCode#" cfsqltype="CF_SQL_VARCHAR">
				<cfelse>
					<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR">
				</cfif>
				<cfif structKeyExists(arguments.frmstruct, "customerContact")>
					<CFPROCPARAM VALUE="#arguments.frmstruct.customerContact#" cfsqltype="CF_SQL_VARCHAR">
				<cfelse>
					<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR">
				</cfif>
				<cfif structKeyExists(arguments.frmstruct, "customerPhone")>
					<CFPROCPARAM VALUE="#arguments.frmstruct.customerPhone#" cfsqltype="CF_SQL_VARCHAR">
				<cfelse>
					<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR">
				</cfif>
				<cfif structKeyExists(arguments.frmstruct, "customerPhoneExt")>
					<CFPROCPARAM VALUE="#arguments.frmstruct.customerPhoneExt#" cfsqltype="CF_SQL_VARCHAR">
				<cfelse>
					<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR">
				</cfif>
				<cfif structKeyExists(arguments.frmstruct, "customerFax")>
					<CFPROCPARAM VALUE="#arguments.frmstruct.customerFax#" cfsqltype="CF_SQL_VARCHAR">
				<cfelse>
					<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR">
				</cfif>
				<cfif structKeyExists(arguments.frmstruct, "customerCell")>
					<CFPROCPARAM VALUE="#arguments.frmstruct.customerCell#" cfsqltype="CF_SQL_VARCHAR">
				<cfelse>
					<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR">
				</cfif>
				<CFPROCPARAM VALUE="#arguments.frmstruct.cutomerIdAuto#" cfsqltype="CF_SQL_VARCHAR">

				<CFPROCPARAM VALUE="#val(ISPARTIAL)#" cfsqltype="CF_SQL_INTEGER">

				<cfif len(trim(readyDate)) gt 0 and isdate(trim(readyDate))>
					<CFPROCPARAM VALUE="#trim(readyDate)#" cfsqltype="cf_sql_date">
				<cfelse>
					<CFPROCPARAM VALUE="#trim(readyDate)#" cfsqltype="cf_sql_date" null="true">
				</cfif>

				<cfif len(trim(arriveDate)) gt 0 and isdate(trim(arriveDate))>
					<CFPROCPARAM VALUE="#trim(arriveDate)#" cfsqltype="cf_sql_date">
				<cfelse>
					<CFPROCPARAM VALUE="#trim(arriveDate)#" cfsqltype="cf_sql_date" null="true">
				</cfif>

				<CFPROCPARAM VALUE="#val(isExcused)#" cfsqltype="CF_SQL_INTEGER">

				<cfif len(trim(bookedBy)) gt 0>
					<CFPROCPARAM VALUE="#trim(bookedBy)#" cfsqltype="CF_SQL_VARCHAR">
				<cfelse>
					<CFPROCPARAM VALUE="#trim(bookedBy)#" cfsqltype="CF_SQL_VARCHAR" null="true">
				</cfif>
				<CFPROCPARAM VALUE="#val(variables.invoiceNumber)#" cfsqltype="CF_SQL_Integer">
				<cfif structkeyexists(arguments.frmstruct,"weightStop1") and isnumeric(arguments.frmstruct.weightStop1)>
					<CFPROCPARAM VALUE="#arguments.frmstruct.weightStop1#" cfsqltype="CF_SQL_INTEGER">
				<cfelse>
					<CFPROCPARAM VALUE="0" cfsqltype="CF_SQL_INTEGER">
				</cfif>
				<CFPROCPARAM VALUE="#arguments.frmstruct.shipperstate#" cfsqltype="CF_SQL_VARCHAR">
				<CFPROCPARAM VALUE="#arguments.frmstruct.shippercity#" cfsqltype="CF_SQL_VARCHAR">
				<CFPROCPARAM VALUE="#arguments.frmstruct.consigneestate#" cfsqltype="CF_SQL_VARCHAR">
				<CFPROCPARAM VALUE="#arguments.frmstruct.consigneecity#" cfsqltype="CF_SQL_VARCHAR">
				
				<cfif structKeyExists(arguments.frmstruct, "defaultCustomerCurrency")>
					<CFPROCPARAM VALUE="#arguments.frmstruct.defaultCustomerCurrency#" cfsqltype="cf_sql_integer">
				<cfelse>
					<CFPROCPARAM VALUE="" cfsqltype="cf_sql_integer" null="yes">
				</cfif>	
				
				<cfif structKeyExists(arguments.frmstruct, "defaultCarrierCurrency")>
					<CFPROCPARAM VALUE="#arguments.frmstruct.defaultCarrierCurrency#" cfsqltype="cf_sql_integer">
				<cfelse>
					<CFPROCPARAM VALUE="" cfsqltype="cf_sql_integer" null="yes">
				</cfif>

				<cfif len(trim(variables.IsConcatCarrierDriverIdentifier)) AND variables.IsConcatCarrierDriverIdentifier EQ 1 AND variables.freightBroker EQ 2>
					<CFPROCPARAM VALUE="1" cfsqltype="cf_sql_bit" >
				<cfelse>
					<CFPROCPARAM VALUE="0" cfsqltype="cf_sql_bit" >
				</cfif>
				<cfif isNumeric(DeadHeadMiles)>
					<CFPROCPARAM VALUE="#DeadHeadMiles#" cfsqltype="cf_sql_float">
				<cfelse>
					<CFPROCPARAM VALUE="0" cfsqltype="cf_sql_float">
				</cfif>
				<cfif structKeyExists(arguments.frmstruct, "InternalRef")>
					<CFPROCPARAM VALUE="#arguments.frmstruct.InternalRef#" cfsqltype="CF_SQL_VARCHAR">
				<cfelse>
					<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR" null="yes">
				</cfif>
				<cfif structKeyExists(arguments.frmstruct, "EquipmentLength") AND len(trim(arguments.frmstruct.EquipmentLength)) and isNumeric(trim(arguments.frmstruct.EquipmentLength))>
					<CFPROCPARAM VALUE="#arguments.frmstruct.EquipmentLength#" cfsqltype="CF_SQL_FLOAT">
				<cfelse>
					<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR" null="yes">
				</cfif>
				<cfif structKeyExists(arguments.frmstruct, "TotalDirectCost")>
					<CFPROCPARAM VALUE="#val(replaceNoCase(replaceNoCase(arguments.frmStruct.TotalDirectCost,'$',''),',','','ALL'))#" cfsqltype="cf_sql_money">
				<cfelse>
					<CFPROCPARAM VALUE="0.00" cfsqltype="cf_sql_money">
				</cfif>
				<cfif structKeyExists(arguments.frmstruct, "EquipmentWidth") AND len(trim(arguments.frmstruct.EquipmentWidth)) AND isNumeric(trim(arguments.frmstruct.EquipmentWidth))>
					<CFPROCPARAM VALUE="#arguments.frmstruct.EquipmentWidth#" cfsqltype="CF_SQL_FLOAT">
				<cfelse>
					<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR" null="yes">
				</cfif>
				<cfif structKeyExists(arguments.frmstruct, "CustomerEmail") AND len(trim(arguments.frmstruct.CustomerEmail))>
					<CFPROCPARAM VALUE="#arguments.frmstruct.CustomerEmail#" cfsqltype="CF_SQL_VARCHAR">
				<cfelse>
					<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR" null="yes">
				</cfif>
				<CFPROCPARAM VALUE="#session.companyid#" cfsqltype="CF_SQL_VARCHAR">
				<CFPROCPARAM VALUE="#FF#" cfsqltype="cf_sql_float">
				<cfif structKeyExists(arguments.frmstruct, "CustomDriverPay")>
					<CFPROCPARAM VALUE="1"  cfsqltype="CF_SQL_BIT">
				<cfelse>
					<CFPROCPARAM VALUE="0"  cfsqltype="CF_SQL_BIT">
				</cfif>
				<CFPROCPARAM VALUE="#arguments.frmstruct.CriticalNotes#" cfsqltype="CF_SQL_VARCHAR">
				<cfif structKeyExists(arguments.frmstruct, "LoadStatusStopNo")>
					<CFPROCPARAM VALUE="#arguments.frmstruct.LoadStatusStopNo#" cfsqltype="CF_SQL_VARCHAR">
				<cfelse>
					<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR" null="true">
				</cfif>
				<cfif structKeyExists(arguments.frmstruct,'BillFromCompany') and len(arguments.frmstruct.BillFromCompany)>
					,<CFPROCPARAM VALUE="#arguments.frmstruct.BillFromCompany#"  cfsqltype="CF_SQL_VARCHAR">
				<cfelse>
					,<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR" null="true">
				</cfif>
				<cfif structKeyExists(arguments.frmstruct,'CustomerPaid')>
					<CFPROCPARAM VALUE="1"  cfsqltype="CF_SQL_BIT">
				<cfelse>
					<CFPROCPARAM VALUE="0" cfsqltype="CF_SQL_BIT">
				</cfif>
				<cfif structKeyExists(arguments.frmstruct,'CarrierPaid')>
					<CFPROCPARAM VALUE="1"  cfsqltype="CF_SQL_BIT">
				<cfelse>
					<CFPROCPARAM VALUE="0" cfsqltype="CF_SQL_BIT">
				</cfif>
				<cfif structKeyExists(arguments.frmstruct,'LimitCarrierRate')>
					<CFPROCPARAM VALUE="1"  cfsqltype="CF_SQL_BIT">
				<cfelse>
					<CFPROCPARAM VALUE="0" cfsqltype="CF_SQL_BIT">
				</cfif>
				<cfif structKeyExists(arguments.frmstruct, "MaxCarrierRate")>
					<cfif totCarChg GT arguments.frmstruct.MaxCarrierRate>
						<CFPROCPARAM VALUE="#VAL(totCarChg)#" cfsqltype="CF_SQL_VARCHAR">
					<cfelse>
						<CFPROCPARAM VALUE="#replace(arguments.frmstruct.MaxCarrierRate,'$',"")#" cfsqltype="CF_SQL_VARCHAR">
					</cfif>
				<cfelse>
					<CFPROCPARAM VALUE="0" cfsqltype="CF_SQL_VARCHAR">
				</cfif>
				<CFPROCRESULT NAME="qInsertedLoadID">
			   </CFSTOREDPROC>
		</cftransaction>
		<cfreturn arguments.frmstruct.editid>
	</cffunction>


	<!--- Edit Load--->
	<cffunction name="EditLoad" access="public" returntype="any">
		<cfargument name="frmstruct" type="struct" required="yes">
		<cfscript>
			variables.objCustomerGatewaynew = #request.cfcpath#&".loadgatewaynew";
		</cfscript>
		<cfinvoke component ="#variables.objCustomerGatewaynew#" method="editload" formStruct="#arguments.frmstruct#" idReturn="true" returnvariable="Msg"/>
		<cfreturn Msg>
	</cffunction>

	<cffunction name="deleteLoadUnpost" access="remote" returntype="any" returnformat="plain">
		<cfargument name="loadid" required="yes" type="any">
		<cfargument name="dsn" required="no" type="any" default="">
		<cfargument name="DirectFreightLoadboardUserName" required="no" type="any" default="">
		<cfargument name="DirectFreightLoadboardPassword" required="no" type="any" default="">

		<cfargument name="ITSUsername" required="no" type="any" default="">
		<cfargument name="ITSPassword" required="no" type="any" default="">
		<cfargument name="ITSIntegrationID" required="no" type="any" default="">

		<cfargument name="PEPsecretKey" required="no" type="any" default="">
		<cfargument name="PEPcustomerKey" required="no" type="any" default="">

		<cfargument name="trans360Usename" required="no" type="any" default="">
		<cfargument name="trans360Password" required="no" type="any" default="">

		<cfargument name="loadBoardtrans360Usename123Usename" required="no" type="any" default="">
		<cfargument name="loadBoard123Password" required="no" type="any" default="">

		<cfquery name="getQry" datasource="#arguments.dsn#">
			select loadid,loadnumber,posttoDirectFreight,posttoITS,ISPOST,IsTransCorePst,postto123loadboard from loads
			where loadid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.LoadID#">
		</cfquery>

		<cfif getQry.posttoDirectFreight EQ 1>
			<cfinvoke method="DirectFreightLoadboard" impref="#getQry.loadnumber#" DirectFreightLoadboardUserName="#arguments.DirectFreightLoadboardUserName#" DirectFreightLoadboardPassword="#arguments.DirectFreightLoadboardPassword#" POSTMETHOD="DEL"  returnvariable="request.DirectFreightLoadboard" />
		</cfif>

		<cfif getQry.posttoITS EQ 1>
			<cfset ITS_msg = ITSWebservice(getQry.loadnumber, "D", arguments.ITSUsername, arguments.ITSPassword, arguments.ITSIntegrationID,getQry.loadnumber,arguments.dsn,0)>
		</cfif>

		<cfif getQry.ISPOST EQ 1>
			<cfinvoke method="Posteverywhere" impref="#getQry.loadnumber#" PEPcustomerKey="#arguments.PEPcustomerKey#" PEPsecretKey="#arguments.PEPsecretKey#" POSTACTION="D"  CARRIERRATE = "0" IncludeCarierRate="0" returnvariable="request.postevrywhere" />
		</cfif>

		<cfif getQry.IsTransCorePst EQ 1>
			<cfinvoke method="Transcore360Webservice" loadid="#getQry.LoadID#" impref="#getQry.loadnumber#" trans360Usename="#arguments.trans360Usename#" trans360Password="#arguments.trans360Password#" POSTACTION="D" returnvariable="request.Transcore360Webservice" />
		</cfif>

		<cfif getQry.postto123loadboard EQ 1>
			<cfset var postLoadResponse = postTo123LoadBoardWebservice("D","LMGR428AP",arguments.loadBoard123Usename,arguments.loadBoard123Password,getQry.loadnumber,arguments.dsn,0,0)>
		</cfif>
		<cfreturn 'success'>
	</cffunction>
	<!--- Delete Load --->

	<cffunction name="deleteLoad" access="remote" returntype="any">
		<cfargument name="loadid" required="yes" type="any">
		<cfargument name="dsn" required="no" type="any" default="">
		<cfargument name="empid" required="no" type="any" default="">
		<cfargument name="adminUserName" required="no" type="any" default="">
		<cfargument name="bulkDelete" required="no" type="any" default="0">
		<cftry>
			<cftransaction>
				<cfif structKeyExists(arguments, "dsn") and len(trim(arguments.dsn))>
					<cfset variables.dsn = arguments.dsn>
				</cfif>

				<cfquery name="getAllStop" datasource="#variables.dsn#">
				   select loadstopid from loadstops where loadid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.LoadID#">
				</cfquery>

				<cfquery name="getLoadDetailsForLog" datasource="#variables.dsn#">
					select CustName,TotalCustomerCharges,NewPickupDate,LoadNumber
					,(select top 1 CustName from loadstops where loadid= <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.LoadID#"> order by stopno,loadtype) as PickupName
					,NewDeliveryDate
					,(select top 1 CustName from loadstops where loadid= <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.LoadID#"> order by stopno desc,loadtype desc) as DeliveryName
					,(SELECT StatusText FROM LoadStatusTypes WHERE StatusTypeID = loads.StatusTypeID) AS LoadStatus
					,orderDate
					from loads where loadid= <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.LoadID#">
				</cfquery>

				<cfset LoadStopIDList=valueList(getAllStop.loadstopid,",")>

				<cfif len(trim(LoadStopIDList))>
					<cfquery name="deleteAllStopItems" datasource="#variables.dsn#">
					   delete from LoadStopCommodities where loadstopid in (<cfqueryparam value="#LoadStopIDList#" cfsqltype="CF_SQL_VARCHAR" list="yes" />)
					</cfquery>

					<cfquery name="deleteLoadStopIntermodalImport" datasource="#variables.dsn#">
					   delete from LoadStopIntermodalImport where loadstopid in (<cfqueryparam value="#LoadStopIDList#" cfsqltype="CF_SQL_VARCHAR" list="yes" />)
					</cfquery>

					<cfquery name="deleteLoadStopIntermodalExport" datasource="#variables.dsn#">
					   delete from LoadStopIntermodalExport where loadstopid in (<cfqueryparam value="#LoadStopIDList#" cfsqltype="CF_SQL_VARCHAR" list="yes" />)
					</cfquery>

					<cfquery name="deleteLoadStopCargoPickupAddress" datasource="#variables.dsn#">
					   delete from LoadStopCargoPickupAddress where loadstopid in (<cfqueryparam value="#LoadStopIDList#" cfsqltype="CF_SQL_VARCHAR" list="yes" />)
					</cfquery>

					<cfquery name="deleteLoadStopCargoDeliveryAddress" datasource="#variables.dsn#">
					   delete from LoadStopCargoDeliveryAddress where loadstopid in (<cfqueryparam value="#LoadStopIDList#" cfsqltype="CF_SQL_VARCHAR" list="yes" />)
					</cfquery>

					<cfquery name="deleteLoadStopEmptyReturnAddress" datasource="#variables.dsn#">
					   delete from LoadStopEmptyReturnAddress where loadstopid in (<cfqueryparam value="#LoadStopIDList#" cfsqltype="CF_SQL_VARCHAR" list="yes" />)
					</cfquery>

					<cfquery name="deleteLoadStopEmptyPickupAddress" datasource="#variables.dsn#">
					   delete from LoadStopEmptyPickupAddress where loadstopid in (<cfqueryparam value="#LoadStopIDList#" cfsqltype="CF_SQL_VARCHAR" list="yes" />)
					</cfquery>

					<cfquery name="deleteLoadStopLoadingAddress" datasource="#variables.dsn#">
					   delete from LoadStopLoadingAddress where loadstopid in (<cfqueryparam value="#LoadStopIDList#" cfsqltype="CF_SQL_VARCHAR" list="yes" />)
					</cfquery>

					<cfquery name="deleteLoadStopReturnAddress" datasource="#variables.dsn#">
					   delete from LoadStopReturnAddress where loadstopid in (<cfqueryparam value="#LoadStopIDList#" cfsqltype="CF_SQL_VARCHAR" list="yes" />)
					</cfquery>
				</cfif>
				<cfquery name="deleteAllStop" datasource="#variables.dsn#">
				   delete from loadstops where loadid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.LoadID#">
				</cfquery>

				<cfquery name="deleteLoadGPSTracking" datasource="#variables.dsn#">
				   delete from LoadGPSTracking where loadid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.LoadID#">
				</cfquery>

				<cfquery name="deleteMobileAppAccessLogs" datasource="#variables.dsn#">
				   delete from MobileAppAccessLogs where loadid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.LoadID#">
				</cfquery>

				<cfquery name="deleteLoad" datasource="#variables.dsn#">
				   delete from Loads where loadid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.LoadID#">
				</cfquery>

				<cfif structKeyExists(arguments, "empid") and len(trim(arguments.empid))>
					<cfset local.empid = arguments.empid>
				<cfelse>
					<cfset local.empid = session.empid>
				</cfif>
				<cfif structKeyExists(arguments, "adminUserName") and len(trim(arguments.adminUserName))>
					<cfset local.adminUserName = arguments.adminUserName>
				<cfelse>
					<cfset local.adminUserName = session.adminUserName>
				</cfif>
				<cfif structKeyExists(session, "iscustomer") and session.iscustomer EQ 1>
					<cfset local.empid = session.customerid>
				</cfif>
				<cfif structKeyExists(arguments, "bulkDelete") and arguments.bulkDelete EQ 1>
					<cfset tempStruct = structNew()>
					<cfset tempStruct.LoadStatus = getLoadDetailsForLog.LoadStatus>
					<cfset tempStruct.custName = getLoadDetailsForLog.custName>
					<cfset tempStruct.custAmt = getLoadDetailsForLog.TotalCustomerCharges>
					<cfset tempStruct.orderDate = getLoadDetailsForLog.orderDate>
					<cfset oldValue = serializeJSON(tempStruct)>
				<cfelse>
					<cfset oldValue = "Customer Name:#getLoadDetailsForLog.custName#, TotalCustomerCharges:#getLoadDetailsForLog.TotalCustomerCharges#, Pickup Date:#dateformat(getLoadDetailsForLog.NewPickupDate,'mm/dd/yyyy')#, Pickup Name:#getLoadDetailsForLog.PickupName#, Delivery Date:#dateformat(getLoadDetailsForLog.NewDeliveryDate,'mm/dd/yyyy')#, Delivery Name:#getLoadDetailsForLog.DeliveryName#">
				</cfif>
				
				<cfquery name="insertLoadLog" datasource="#variables.dsn#" result="qResult">
					INSERT INTO LoadLogs (
								LoadID,
								LoadNumber,
								FieldLabel,
								oldValue,
								NewValue,
								UpdatedByUserID,
								UpdatedBy,
								UpdatedTimestamp
								<cfif structKeyExists(arguments, "bulkDelete") and arguments.bulkDelete EQ 1>
								,bulkDelete
								</cfif>
								,UpdatedByIP
							)
						values
							(
								<cfqueryparam value="#arguments.loadID#" cfsqltype="cf_sql_nvarchar">,
								<cfqueryparam value="#getLoadDetailsForLog.LoadNumber#" cfsqltype="cf_sql_bigint">,
								<cfqueryparam value="Load Deleted" cfsqltype="cf_sql_nvarchar">,
								<cfqueryparam value="#oldValue#" cfsqltype="cf_sql_nvarchar">,
								<cfqueryparam value="Load Deleted" cfsqltype="cf_sql_nvarchar">,
								<cfqueryparam value="#local.empid#" cfsqltype="cf_sql_nvarchar">,
								<cfqueryparam value="#local.adminUserName#" cfsqltype="cf_sql_nvarchar">,
								<cfqueryparam value="#Now()#" cfsqltype="cf_sql_timestamp">
								<cfif structKeyExists(arguments, "bulkDelete") and arguments.bulkDelete EQ 1>
								,1
								</cfif>
								,<cfqueryparam cfsqltype="cf_sql_varchar" value="#cgi.REMOTE_ADDR#">
							)
				</cfquery>
			</cftransaction>
			<cfreturn "Load have been deleted successfully.">
			<cfcatch>
				<cfreturn "Unable to delete the load.">
			</cfcatch>
		</cftry>
	</cffunction>




	<!--- QuickBooks Insert Record in Invoices Table --->
	<cffunction name="insertInInvoices" returntype="void">
		<cfargument name="qLoadsRow" required="yes" type="query">
		<cfargument name="QBdsn" required="yes" type="any">
	    <cfargument name="dsn" required="yes" type="any">

	     <CFSTOREDPROC PROCEDURE="USP_GetCustomerDetails" DATASOURCE="#dsn#">
			<cfif isdefined('qLoadsRow.PayerID') and len(qLoadsRow.PayerID)>
				<CFPROCPARAM VALUE="#qLoadsRow.PayerID#" cfsqltype="CF_SQL_VARCHAR">
			<cfelse>
				<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR">
			</cfif>
			<CFPROCRESULT NAME="qCustomer">
		</CFSTOREDPROC>


	    <CFSTOREDPROC PROCEDURE="USP_GetStateDetails" DATASOURCE="#dsn#">
	    	<cfif isdefined('qCustomer.StateID')>
				<CFPROCPARAM VALUE="#qCustomer.StateID#" cfsqltype="CF_SQL_VARCHAR">
			<cfelse>
				<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR">
	        </cfif>
			 <CFPROCRESULT NAME="qState">
		</CFSTOREDPROC>

	    <cfinvoke method="getNoOfStops" LOADID="#qLoadsRow.LoadID#" dsn="#dsn#" returnvariable="request.NoOfStops" />
		<cfinvoke method="getAllLoads" loadid="#qLoadsRow.LoadID#" dsn="#dsn#" stopNo="#request.NoOfStops#" returnvariable="qLoadsLastStop" />

	    <cfset itemDescriptions = 'Miles: #DollarFormat(qLoadsRow.customerMilesCharges )#, Flate Rate: #DollarFormat(qLoadsRow.CustFlatRate )#, Commodities/Other: #DollarFormat(qLoadsRow.customerCommoditiesCharges )#'>
	    <cfset invTotal = qLoadsRow.customerMilesCharges + qLoadsRow.CustFlatRate + qLoadsRow.customerCommoditiesCharges>

	        <cfquery name="QInsertInInvoice" datasource="#QBdsn#">
	            INSERT INTO Invoices (LoadNum, InvDate, PONum, ItemNames, ItemDescriptions, ItemTotalAmount, ItemQuantities, ItemUnitPrice, ItemTaxable, TotalInvoiceAmount, DueDate, PaymentTerms, BookLoad, BillDate, CustomerName, Street, City, State, Zip, PickUpTelephone, BillToAddr)
	            VALUES ('#qLoadsRow.LoadNumber#', '#DateFormat(NOW(),'mm/dd/yyyy')#', '#qLoadsRow.CustomerPONo#', 'Load', '#itemDescriptions#', '#DollarFormat(invTotal)#', '1', '#DollarFormat(invTotal)#', 'N', '#DollarFormat(invTotal)#', '#DateFormat(qLoadsLastStop.DeliveryDate,'mm/dd/yyyy')#', 'See Contract', '-1', '#DateFormat(qLoadsLastStop.DeliveryDate,'mm/dd/yyyy')#', '#qCustomer.CustomerName#', '#qCustomer.Location#', '#qCustomer.City#', '#qState.StateCode#', '#qCustomer.Zipcode#', '#qCustomer.PhoneNo#', '#qCustomer.Location#, #qCustomer.City#, #qState.StateCode#.')
	        </cfquery>
	</cffunction>


	<!--- QuickBooks Insert Record in Bills Table --->
	<cffunction name="insertInBills" returntype="void">
		<cfargument name="qLoadsRow" required="yes" type="query">
		<cfargument name="QBdsn" required="yes" type="any">
	    <cfargument name="dsn" required="yes" type="any">


	    <CFSTOREDPROC PROCEDURE="USP_GetCustomerDetails" DATASOURCE="#arguments.dsn#">
			<cfif isdefined('qLoadsRow.PayerID') and len(qLoadsRow.PayerID)>
				<CFPROCPARAM VALUE="#qLoadsRow.PayerID#" cfsqltype="CF_SQL_VARCHAR">
			<cfelse>
				<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR">
			</cfif>
			<CFPROCRESULT NAME="qCustomer">
		</CFSTOREDPROC>

	    <cfinvoke method="getNoOfStops" LOADID="#qLoadsRow.LoadID#" dsn="#arguments.dsn#" returnvariable="request.NoOfStops" />
		<cfinvoke method="getAllLoads" loadid="#qLoadsRow.LoadID#" dsn="#arguments.dsn#" stopNo="#request.NoOfStops#" returnvariable="qLoadsLastStop" />

	    <cfquery name="qCarrierID" datasource="#arguments.dsn#">
	    	SELECT CarrierID FROM Loads
	        WHERE LoadID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#qLoadsRow.LoadID#">
	    </cfquery>

	    <CFSTOREDPROC PROCEDURE="USP_GetCarrierDetails" DATASOURCE="#arguments.dsn#">
			<cfif isdefined('qCarrierID.CarrierID') and len(qCarrierID.CarrierID)>
			 	<CFPROCPARAM VALUE="#qCarrierID.CarrierID#" cfsqltype="CF_SQL_VARCHAR">
			 <cfelse>
			 	<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR">
			 </cfif>
			 <CFPROCPARAM VALUE="#session.CompanyID#" cfsqltype="CF_SQL_VARCHAR">
			 <CFPROCRESULT NAME="qCarrier">
		</CFSTOREDPROC>


	    <cfset invTotal = qLoadsRow.carrierMilesCharges + qLoadsRow.carrFlatRate + qLoadsRow.carrierCommoditiesCharges>


	        <cfquery name="QInsertInBills" datasource="#QBdsn#">
	            INSERT INTO Bills (LoadNum, PickUpDate, DateDelv, DueDate, Carrier, Account, Total, BookLoad, FactorName, FactorMailTo, FactorCity, FactorSt, FactorZip, BilledDate, BillDate, Memo, Terms, CustomerCode, VendorCode, CarrierName, CarrierRemitAddr, CarrierRemitCity, CarrierRemitSt, CarrierRemitZip, TollFree)
	            VALUES ('#qLoadsRow.LoadNumber#', '#DateFormat(qLoadsRow.PickupDate,'mm/dd/yyyy')#', '#DateFormat(qLoadsRow.DeliveryDate,'mm/dd/yyyy')#', '#DateFormat(qLoadsLastStop.DeliveryDate,'mm/dd/yyyy')#', '#qCarrier.CarrierName#', 'Purchasing', '#DollarFormat(invTotal)#', '-1', '#qCarrier.CarrierName#', '#qCarrier.Address#', '#qCarrier.City#', '#qCarrier.statecode#', '#qCarrier.ZipCode#', '#DateFormat(qLoadsLastStop.DeliveryDate,'mm/dd/yyyy')#', '#DateFormat(qLoadsLastStop.DeliveryDate,'mm/dd/yyyy')#', '', 'See Contract', '#qCustomer.CustomerCode#', '#qCarrier.MCNumber#', '#qCarrier.CarrierName#', '#qCarrier.Address#', '#qCarrier.City#', '#qCarrier.statecode#', '#qCarrier.ZipCode#', '#qCarrier.TollFree#')
	        </cfquery>
	</cffunction>

	<!---  QuickBooks Export  --->
	<cffunction name="exportAllLoads" access="remote" returntype="array">
		<cfargument name="QBdsn" required="yes">
		<cfargument name="dsn" required="yes">
		<cfargument name="dateFrom" required="yes">
	    <cfargument name="dateTo" required="yes">

		<cfset arrToReturn = '0,0,0'>

		<cfinvoke method="getSystemSetupOptions" returnvariable="request.qGetSystemSetupOptions">
	    	<cfinvokeargument name="dsn" value="#arguments.dsn#">
	    </cfinvoke>

		<cfinvoke method="getSearchLoads" LoadStatus="#request.qGetSystemSetupOptions.ARAndAPExportStatusID#" searchText="" pageNo="-1" returnvariable="qLoads">
	    	<cfinvokeargument name="dsn" value="#arguments.dsn#">
	    </cfinvoke>

	        <cfquery name="qTruncateOldInvoiceData" datasource="#QBdsn#">
	            DELETE FROM Invoices
	            WHERE 1=1
	        </cfquery>

	        <cfquery name="qTruncateOldBillsData" datasource="#QBdsn#">
	            DELETE FROM Bills
	            WHERE 1=1
	        </cfquery>

	        <cfset customerTypeExportsCount = 0>
	        <cfset carrierTypeExportsCount = 0>
	        <cfset bothTypeExportsCount = 0>

	        <cfloop query="qLoads">

	            <cfif not isdefined('request.qLoads.orderDate') OR request.qLoads.orderDate eq ''>
	            	<cfset orderDate = DateFormat(NOW(),'mm/dd/yyyy')>
	            <cfelse>
	            	<cfset orderDate = DateFormat(qLoads.orderDate,'mm/dd/yyyy')>
	            </cfif>

	            <cfset dateFrom = DateFormat(arguments.dateFrom,'mm/dd/yyyy')>
	            <cfset dateTo = DateFormat(arguments.dateTo,'mm/dd/yyyy')>


	        	<cfif (qLoads.ARExportedNN eq '1' AND qLoads.APExportedNN eq '1') OR (orderDate LT dateFrom OR orderDate GT dateTo)>
	            	<cfcontinue>
	            <cfelseif qLoads.ARExportedNN eq '1'> <!--- Already Exported for Customer now just need to export for Client(Bills Table) --->
	            	<!--- Insert in Bills --->
	                <cfinvoke method="insertInBills">
	                	<cfinvokeargument name="qLoadsRow" value="#qLoads#">
						<cfinvokeargument name="QBdsn" value="#QBdsn#">
	                    <cfinvokeargument name="dsn" value="#dsn#">
	                </cfinvoke>
	            	<cfset customerTypeExportsCount = customerTypeExportsCount + 1>

	            <cfelseif qLoads.APExportedNN eq '1'> <!--- Already Exported for Client now just need to export for Customer(Invoices Table) --->
	            	<!--- Insert in Invoices --->
	                <cfinvoke method="insertInInvoices">
	                	<cfinvokeargument name="qLoadsRow" value="#qLoads#">
						<cfinvokeargument name="QBdsn" value="#QBdsn#">
	                    <cfinvokeargument name="dsn" value="#dsn#">
	                </cfinvoke>
	            	<cfset carrierTypeExportsCount = carrierTypeExportsCount + 1>

	            <cfelse> <!--- Not Exported yet for Client or Customer export to both tables(Invoices Table, Bills table) --->
	            	<!--- Insert in Invoices --->
	                <cfinvoke method="insertInBills">
	                	<cfinvokeargument name="qLoadsRow" value="#qLoads#">
						<cfinvokeargument name="QBdsn" value="#QBdsn#">
	                    <cfinvokeargument name="dsn" value="#dsn#">
	                </cfinvoke>

	                <cfinvoke method="insertInInvoices">
	                	<cfinvokeargument name="qLoadsRow" value="#qLoads#">
						<cfinvokeargument name="QBdsn" value="#QBdsn#">
	                    <cfinvokeargument name="dsn" value="#dsn#">
	                </cfinvoke>
	            	<cfset bothTypeExportsCount = bothTypeExportsCount + 1>
	            </cfif>
	        </cfloop>


			<cfset filePath = "#ExpandPath( './views/' )#templates">
			<cfset filePath = replace(filePath,"gateways\","","ALL")>

			<cfzip
				action="zip"
				source="#filePath#/"
				file="#filePath#/QBData.zip"
				filter="QBData.mdb"
				overwrite="true"
			/>
		<!--- index1: Loads Exported for Customer, index2: Loads Exported for Carrier, index3: Loads Exported for Both --->
	    <cfset arrToReturn = ListInsertAt(arrToReturn, 1, '#customerTypeExportsCount#')>
	    <cfset arrToReturn = ListInsertAt(arrToReturn, 2, '#carrierTypeExportsCount#')>
	    <cfset arrToReturn = ListInsertAt(arrToReturn, 3, '#bothTypeExportsCount#')>
	    <cfreturn ListToArray(arrToReturn)>
	</cffunction>

	<cffunction name="getLoadCarriersMails" access="public" returntype="any">
		<cfargument name="loadid" required="true" type="any">
		<cfargument name="dsn" required="no" type="any">
		<cfif isdefined('dsn')>
	    	<cfset activedsn = dsn>
	    <cfelse>
	    	<cfset activedsn = variables.dsn>
	    </cfif>
		<cfset maiList = "">
		<cfif isdefined('arguments.loadid') and len(arguments.loadid) gt 1>
			<cfquery datasource="#activedsn#" name="qrygetcarriers">
				SELECT
	 				DISTINCT a.NewCarrierID,
	 				carr.EmailID
				FROM LoadStops a
				JOIN LoadStops b ON a.LoadID = b.LoadID AND a.StopNo = b.StopNo
				LEFT OUTER JOIN (SELECT [CarrierID],[CarrierName], [EmailID] FROM [Carriers]) AS carr ON carr.CarrierID = a.NewCarrierID
				WHERE a.LoadID = <CFQUERYPARAM VALUE="#arguments.loadid#" cfsqltype="CF_SQL_VARCHAR">
				AND a.LoadType = 1
				AND b.LoadType = 2
				AND b.StopNo =a.StopNo
			</cfquery>

			<cfoutput query="qrygetcarriers">
				<cfif IsValid( "email", qrygetcarriers.EmailID)>
					<cfset maiList = ListAppend(maiList, qrygetcarriers.EmailID,';')>
				</cfif>
			</cfoutput>
		</cfif>
		<cfreturn maiList>
	</cffunction>

	<cffunction name="getAllStopsCount" access="public" returntype="any">
		<cfargument name="loadid" required="true" type="any">
	    <cfargument name="dsn" required="no" type="any">
	    <cfif isdefined('dsn')>
	    	<cfset activedsn = dsn>
	    <cfelse>
	    	<cfset activedsn = variables.dsn>
	    </cfif>
	    <CFSTOREDPROC PROCEDURE="USP_GetLoadStopCount" DATASOURCE="#activedsn#">
			<CFPROCPARAM VALUE="#arguments.loadid#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCRESULT NAME="qrygetloadstopCount">
		</CFSTOREDPROC>
		<cfreturn qrygetloadstopCount.CNT>
	</cffunction>
	<!--- Get All Loads--->
	<cffunction name="getAllLoads" access="public" returntype="query">
		<cfargument name="loadid" required="false" type="any">
		<cfargument name="stopNo" required="false" type="any">
		<cfargument name="sortorder" required="no" type="any">
		<cfargument name="sortby" required="no" type="any">
	    <cfargument name="dsn" required="no" type="any">

	    <cfif isdefined('dsn')>
	    	<cfset activedsn = dsn>
	    <cfelse>
	    	<cfset activedsn = variables.dsn>
	    </cfif>

		<CFSTOREDPROC PROCEDURE="USP_GetLoadDetails" DATASOURCE="#activedsn#">
			<cfif isdefined('arguments.loadid') and len(arguments.loadid) gt 1>
				<CFPROCPARAM VALUE="#arguments.loadid#" cfsqltype="CF_SQL_VARCHAR">
				<CFPROCPARAM VALUE="#arguments.stopNo#" cfsqltype="CF_SQL_INTEGER">
			<cfelse>
				<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR">
				<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR">
			</cfif>
			<cfif isdefined('session.companyid') and len(session.companyid) gt 1>
				<CFPROCPARAM VALUE="#session.companyid#" cfsqltype="CF_SQL_VARCHAR">
			<cfelse>
				<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR" null="true">
			</cfif>
		    <CFPROCRESULT NAME="qrygetload">
		</CFSTOREDPROC>

		<cfif isDefined("arguments.sortorder") and isDefined("arguments.sortby") and len(arguments.sortby)>
			<cfquery datasource="#activedsn#" name="qrygetload">
				SELECT l.Loadid,l.LoadNumber,l.IsPartial,l.CarrierID AS CarrierID,
				ISNULL(l.CustomerRatePerMile,0) AS CustomerRatePerMile,
				ISNULL(l.CarrierRatePerMile,0) AS CarrierRatePerMile,
				ISNULL(l.TotalMiles,0) AS CustomerTotalMiles,
				ISNULL(l.TotalMiles,0) AS CarrierTotalMiles,
				ISNULL(l.ARExported,'0') AS ARExportedNN,
				ISNULL(l.APExported,'0') AS APExportedNN,
				ISNULL(l.orderDate, '') AS orderDate,
				ISNULL(l.customerMilesCharges, 0) AS customerMilesCharges,
				ISNULL(l.carrierMilesCharges, 0) AS carrierMilesCharges,
				ISNULL(l.customerCommoditiesCharges, 0) AS customerCommoditiesCharges,
				ISNULL(l.carrierCommoditiesCharges, 0) AS carrierCommoditiesCharges,
				ISNULL(l.CustFlatRate, 0) AS CustFlatRate,
				ISNULL(l.carrFlatRate, 0) AS carrFlatRate,
				l.readyDate,
				l.arriveDate,
				l.isExcused,
				ISNULL(l.posttoITS,0) AS posttoITS,
				postCarrierRatetoITS,
				postCarrierRatetoloadboard,
				postCarrierRatetoTranscore,
				postCarrierRateto123LoadBoard,
				l.bookedBy,
				l.DeadHeadMiles,
				CustomerPONo,
				StatusTypeID,
				statusText,
				colorCode,
				PayerID,
				TotalCustomerCharges,
				stops.shipperState,
				stops.shipperCity,
				finalconsignee.consigneeState,
				finalconsignee.consigneeCity,
				carr.CarrierName,
				[custName] as CustomerName,
				LoadStopID,
				StopNo,
				[NewPickupDate] as PickupDate ,
				[NewDeliveryDate] as DeliveryDate ,
				NewOfficeID,
				NewNotes,
				isPost,
				IsTransCorePst,
				TotalCarrierCharges,
				TotalCustomerCharges,
				NewCarrierID,
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
				consigneeCustomerID,
				EmergencyResponseNo,
				CODAmt,
				CODFee,
				DeclaredValue,
				postto123loadboard,
				Notes,invoiceNumber,weight,userDefinedFieldTrucking,CarrierInvoiceNumber,TotalDirectCost
	ROW_NUMBER() OVER (ORDER BY
	                  #arguments.sortBy# #arguments.sortOrder#,l.LoadNumber

	                    ) AS Row
	                    ,emailList, shipperDriverCell2, consigneeDriverCell2
	      				FROM LOADS l
	      				left outer join (select
						a.LoadID,
						a.LoadStopID,a.StopNo,
						a.NewCarrierID,
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
						a.userDef1 as userDef1,
						a.userDef2 as userDef2,
						a.userDef3 as userDef3,
						a.userDef4 as userDef4,
						a.userDef5 as userDef5,
						a.userDef6 as userDef6,
						a.NewDriverCell2 AS shipperDriverCell2,
						b.NewDriverCell2 AS consigneeDriverCell2
						FROM LoadStops a WITH (NOLOCK)
						JOIN LoadStops b WITH (NOLOCK) on a.LoadID = b.LoadID and a.StopNo = b.StopNo
	      				where b.LoadID = a.LoadID
	      				and a.LoadType = 1
						and b.LoadType = 2) as stops  on stops.loadid = l.loadid

						left outer join (SELECT [CarrierID],[CarrierName] FROM [Carriers]) as carr WITH (NOLOCK) on carr.CarrierID = stops.NewCarrierID
						left outer join (SELECT [CarrierOfficeID],[Manager]  FROM [CarrierOffices]) as office WITH (NOLOCK) on office.CarrierOfficeID = stops.NewOfficeID
						left outer join (SELECT [StatusTypeID] as stTypeId,[statusText], colorCode FROM [loadStatusTypes]) as loadStatus WITH (NOLOCK) on loadStatus.stTypeId = l.StatusTypeID
						left outer join (SELECT [StatusTypeID] as lststType,[StatusText] as lStatusText FROM [LoadStatusTypes]) as LStatusTypes WITH (NOLOCK)  on LStatusTypes.lststType = l.StatusTypeID
	      				where l.LoadID = l.LoadID
	      				and l.customerid in (select customerid from CustomerOffices inner join offices on CustomerOffices.officeid = offices.officeid where offices.companyid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#session.companyid#">)
					order by #arguments.sortby# #arguments.sortorder#;
			</cfquery>
			<cfreturn qrygetload>
		</cfif>

		<cfreturn qrygetload>
	</cffunction>

	<!--- Get All Loads by Carriers--->
	<cffunction name="getAllLoadsByCarrier" access="public" returntype="query">
		<cfargument name="carrierID" required="false" type="any">
		<cfargument name="stopNo" required="false" type="any">
		<CFSTOREDPROC PROCEDURE="USP_GetLoadDetailsByCarrier" DATASOURCE="#variables.dsn#">
			<cfif isdefined('arguments.carrierID') and len(arguments.carrierID) gt 1>
				<CFPROCPARAM VALUE="#arguments.carrierID#" cfsqltype="CF_SQL_VARCHAR">
			<cfelse>
				<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR">
			</cfif>
		    <CFPROCRESULT NAME="qrygetload">
		</CFSTOREDPROC>
	    <cfreturn qrygetload>
	</cffunction>

	<!--- Get All Items--->

	<cffunction name="getAllItems" access="public" returntype="query">
		<cfargument name="LOADSTOPID" required="false" type="any">

		<CFSTOREDPROC PROCEDURE="USP_GetLoadItems" DATASOURCE="#variables.dsn#">
			<cfif isdefined('arguments.LOADSTOPID') and len(arguments.LOADSTOPID) gt 1>
				<CFPROCPARAM VALUE="#arguments.LOADSTOPID#" cfsqltype="CF_SQL_VARCHAR">
			<cfelse>
				<CFPROCPARAM value="null" null="yes" cfsqltype="CF_SQL_VARCHAR">
			</cfif>
		    <CFPROCRESULT NAME="qrygetloadItems">
		</CFSTOREDPROC>
	    <cfreturn qrygetloadItems>
	</cffunction>

	<!--- Get No of Stops--->

	<cffunction name="getNoOfStops" access="public" returntype="numeric">
		<cfargument name="LOADID" required="true" type="any">
	    <cfargument name="dsn" required="no" type="any">

	    <cfif isdefined('dsn')>
	    	<cfset activedsn = dsn>
	    <cfelse>
	    	<cfset activedsn = variables.dsn>
	    </cfif>

		<cfquery name="toTalNoOfStops" datasource="#activedsn#">
			select isnull(max(stopNo),0) as totStop from LoadStops
			where loadId=<CFQUERYPARAM VALUE="#arguments.LOADID#" cfsqltype="CF_SQL_VARCHAR">
		</cfquery>
		<cfif toTalNoOfStops.recordcount gt 0>
		    <cfreturn toTalNoOfStops.totStop>
		<cfelse>
			<cfreturn 0>
		</cfif>
	</cffunction>

	<!--- Delete Stops--->
	<cffunction name="deleteStops" access="remote" returntype="string">
	<cfargument name="dsn" type="string" required="yes" />
	<cfargument name="stopID" required="No" type="any">
	<cfargument name="stopNo" required="No" type="any">
	<cfargument name="LoadID" required="No" type="any">
	<cftry>
	 <cftransaction>
		<cfquery name="deleteItems" datasource="#arguments.dsn#">
			delete from loadStopCommodities where LoadStopID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.stopID#">
		</cfquery>

		<cfquery name="deleteStop" datasource="#arguments.dsn#">
			delete from loadStops where LoadId = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.LoadID#"> and stopNo = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.StopNo#">
		</cfquery>
	 </cftransaction>
	<cfreturn true>
	<cfcatch type="any">
		<cfreturn cfcatch.Detail>
	</cfcatch>
	</cftry>
	</cffunction>

	<cffunction name="ajaxDeleteStops" access="remote" output="yes" returnformat="json">
	<cfargument name="dsn" type="string" required="yes" />
	<cfargument name="stopID" required="No" type="any">
	<cfargument name="stopNo" required="No" type="any">
	<cfargument name="LoadID" required="No" type="any">
	<cftry>
	 <cftransaction>
		<cfquery name="deleteItems" datasource="#arguments.dsn#">
			delete from loadStopCommodities where LoadStopID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.stopID#">
		</cfquery>

		<cfquery name="deleteModal" datasource="#arguments.dsn#">
			delete from LoadStopIntermodalImport where LoadStopID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.stopID#">
			delete from LoadStopIntermodalExport where LoadStopID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.stopID#">
		</cfquery>

		<cfquery name="deleteStop" datasource="#arguments.dsn#">
			delete from loadStops where LoadId = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.LoadID#"> and stopNo = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.StopNo#">
		</cfquery>
	 </cftransaction>
	<cfscript>
	 transaction = StructNew();
	 StructInsert(transaction, "transaction", "true");
	</cfscript>
	#SerializeJSON(transaction)#
	<cfcatch type="any">
		#cfcatch.Detail#
	</cfcatch>
	</cftry>
	</cffunction>

	<cffunction name="getAllStop" access="public" output="false" returntype="any">
	    <cfargument name="CustomerStopID" required="no" type="any">
	         	<CFSTOREDPROC PROCEDURE="USP_GetStopDetailsforLoads" DATASOURCE="#variables.dsn#">
					<cfif isdefined('arguments.CustomerStopID') and len(arguments.CustomerStopID)>
					 	<CFPROCPARAM VALUE="#arguments.CustomerStopID#" cfsqltype="CF_SQL_VARCHAR">
					 <cfelse>
					 	<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR">
					 </cfif>
					 <CFPROCRESULT NAME="qrygetStops">
				</CFSTOREDPROC>

	             <cfreturn qrygetStops>
	</cffunction>

	<!---Get Sales Person with auth level---->
	<cffunction name="getSalesPerson" access="remote" returntype="any">
	 <cfargument name="AuthLevelId" required="no">
		 <cfquery name="getSalesperson" datasource="#variables.dsn#">
			 SELECT employees.* FROM employees
			 INNER JOIN Roles ON Roles.RoleID = employees.RoleID
			 INNER JOIN Offices ON employees.OfficeID = Offices.OfficeID
	         WHERE ( RoleValue  IN (<cfqueryparam list="true" value="#arguments.AuthLevelId#">) OR  RoleValue = 'Administrator' ) and employees.isActive = 'True'
	         AND Offices.CompanyID = <cfqueryparam VALUE="#session.CompanyID#" cfsqltype="CF_SQL_VARCHAR">
	         ORDER BY Name
		 </cfquery>
	 <cfreturn getSalesperson>
	</cffunction>
	<!--------get load add/edit sales persion--->
	<cffunction name="getloadSalesPerson" access="remote" returntype="any">
	 	<cfargument name="AuthLevel" required="no">
	 	<cfargument name="Salesperson" required="no" default="">
	 	<cfargument name="Dispatcher" required="no" default="">
	 	<cfargument name="includeInactive" required="no" default="0" type="boolean">

		<cfquery name="getSalesperson" datasource="#variables.dsn#">
			SELECT EmployeeID,Name,SalesCommission,DefaultSalesRepToLoad,DefaultDispatcherToLoad FROM employees
			INNER JOIN Roles ON Roles.RoleID = employees.RoleID
			INNER JOIN Offices ON Offices.OfficeID = Employees.OfficeID
	        WHERE 
	        (RoleValue IN (<cfqueryparam list="true" value="#arguments.AuthLevel#">)
	        	OR RoleValue = 'Administrator')
	        <cfif arguments.includeInactive EQ 0>
	        	AND employees.isActive = 'True'
	        </cfif>
	        AND Offices.CompanyID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#session.CompanyID#"> 
	        
	        <cfif structkeyexists(arguments,"Salesperson") AND len(trim(arguments.Salesperson))>
	        	OR EmployeeID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.Salesperson#">
	        </cfif>
	        <cfif structkeyexists(arguments,"Dispatcher") AND len(trim(arguments.Dispatcher))>
	        	OR EmployeeID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.Dispatcher#">
	        </cfif>
	        
	        ORDER BY <cfif arguments.includeInactive EQ 1>employees.isActive DESC,</cfif>Name
		</cfquery>
	 	<cfreturn getSalesperson>
	</cffunction>
	<!---Set Session---->
	<cffunction name="setSession" access="remote" returntype="any">
	 <cfargument name="isSession" required="yes">
		<cfif arguments.isSession is 1>
			<cfset session.checkUnload ='add'>
		<cfelse>
			<cfset session.checkUnload =''>
		</cfif>
	 <cfreturn session.checkUnload>
	</cffunction>

	 <!--- Set Session Ajax version--->
	<cffunction name="setAjaxSession" access="remote" output="yes" returnformat="json">
	 <cfargument name="isSession" required="yes">
		<cfif arguments.isSession is 1>
			<cfset session.checkUnload ='add'>
		<cfelse>
			<cfset session.checkUnload =''>
		</cfif>
	    <cfscript>
	     sessionCheck = StructNew();
	     StructInsert(sessionCheck, "sessionCheck", session.checkUnload);
	    </cfscript>
	    #SerializeJSON(sessionCheck)#
	</cffunction>

	<cffunction name="getSession" access="remote" returntype="any">
	  	<cfif not isdefined('session.checkUnload')>
			<cfset session.checkUnload = 'no'>
		</cfif>
		<cfreturn session.checkUnload>
	</cffunction>

	<!--- Get Session Ajax version--->
	<cffunction name="getAjaxSession" access="remote" output="yes" returnformat="json">
		<cfargument name="UnlockStatus" type="any" required="no">
		<cfargument name="loadid" type="any" required="no">
		<cfargument name="dsn" type="any" required="no">
		<cfargument name="sessionid" type="any" required="no">
		<cfargument name="userid" type="any" required="no">
		<cfargument name="tabid" type="any" required="no">
		<cfif structkeyexists(arguments,"dsn") AND not len(trim(arguments.dsn))>
			<cfset arguments.dsn = trim(listFirst(cgi.SCRIPT_NAME,'/'))>
		</cfif>
		<cfif structkeyexists(arguments,"tabid")>
			<!----query to delete -corresponding rows of tabid--->
			<cfquery name="qryGetBrowserTabDetails" datasource="#arguments.dsn#">
				delete from  UserBrowserTabDetails
				where tabID=<cfqueryparam value="#arguments.tabid#" cfsqltype="cf_sql_varchar">
			</cfquery>
		</cfif>
		<cfif structkeyexists(arguments,"UnlockStatus") and structkeyexists(arguments,"loadid") and arguments.UnlockStatus eq false and len(trim(arguments.loadid)) gt 1 and structkeyexists(arguments,"dsn") and structkeyexists(arguments,"sessionid") and structkeyexists(arguments,"userid")>
			<!---Query to select browser tab details--->
			<cfquery name="qryGetBrowsertabDetails" datasource="#arguments.dsn#">
				select id from UserBrowserTabDetails
				where
					loadid=<cfqueryparam value="#arguments.loadid#" cfsqltype="cf_sql_varchar">
				and sessionid=<cfqueryparam value="#arguments.sessionid#" cfsqltype="cf_sql_varchar">
				and userid=<cfqueryparam value="#arguments.userid#" cfsqltype="cf_sql_varchar">
			</cfquery>
			<cfif not qryGetBrowsertabDetails.recordcount>
				<!---Query to remove lock --->
				<cfinvoke method="updLoadEditingUserSession" dsn="#arguments.dsn#" loadid="#arguments.loadid#">
			</cfif>
		</cfif>
	  	<cfif not isdefined('session.checkUnload')>
			<cfset session.checkUnload = 'no'>
		</cfif>
		<cfscript>
	      sessionCheck = StructNew();
	      StructInsert(sessionCheck, "sessionCheck", session.checkUnload);
	    </cfscript>
	      #SerializeJSON(sessionCheck)#
	</cffunction>

	<cffunction name="updLoadEditingUserSession" access="public" returntype="void">
		<cfargument name="loadid" type="string" required="no" default="">
		<cfargument name="InUseBy" type="string" required="no" default="">
		<cfargument name="dsn" type="string" required="no" default="">

		<cftry>
			<cfif len(trim(arguments.loadid)) OR len(trim(arguments.InUseBy))>
				<cfquery name="qryUpdateEditingUserId" datasource="#arguments.dsn#" result="result">
					UPDATE Loads
					SET
					InUseBy=null,
					InUseOn=null,
					sessionid=null
					WHERE 
					<cfif len(trim(arguments.loadid))>
						loadid=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.loadid#">
					<cfelse>
						InUseBy=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.InUseBy#">
					</cfif>
				</cfquery>
			</cfif>
			<cfcatch>
				<cfdocument format="pdf" filename="C:\pdf\LoadLockErrorTrack_#DateTimeFormat(now(),"YYYY_MM_dd_HH_nn_ss_l")#.pdf" overwrite="true">
					<cfdump var="#arguments#">
					<cfdump var="#cfcatch#">
				</cfdocument>
			</cfcatch>
		</cftry>
	</cffunction>

	<!---function to insert UserBrowserTabDetails--->
	<cffunction name="insertTabDetails" access="remote" output="yes" returnformat="json">
		<cfargument name="tabID" type="any" required="yes">
		<cfargument name="loadid" type="any" required="yes">
		<cfargument name="sessionid" type="any" required="yes">
		<cfargument name="userid" type="any" required="yes">
		<cfargument name="dsn" type="any" required="yes">
		<!---query to select UserBrowserTabDetails--->
		<cfquery name="qryGetBrowserTabDetails" datasource="#arguments.dsn#">
			select * from  UserBrowserTabDetails
			where 1=1
			and loadid=<cfqueryparam value="#arguments.loadid#" cfsqltype="cf_sql_varchar">
			and sessionid=<cfqueryparam value="#arguments.sessionid#" cfsqltype="cf_sql_varchar">
			and userid=<cfqueryparam value="#arguments.userid#" cfsqltype="cf_sql_varchar">
			and tabID=<cfqueryparam value="#arguments.tabID#" cfsqltype="cf_sql_varchar">
		</cfquery>
		<cfif not qryGetBrowserTabDetails.recordcount>
			<!---Query to insert UserBrowserTabDetails--->
			<cfquery name="qryInsertGetBrowserTabDetails" datasource="#arguments.dsn#">
				INSERT INTO UserBrowserTabDetails (userid, loadid, tabid, sessionid, createddate)
	            VALUES (<cfqueryparam value="#arguments.userid#" cfsqltype="cf_sql_varchar">,
						<cfqueryparam value="#arguments.loadid#" cfsqltype="cf_sql_varchar">,
						<cfqueryparam value="#arguments.tabID#" cfsqltype="cf_sql_varchar">	,
						<cfqueryparam value="#arguments.sessionid#" cfsqltype="cf_sql_varchar">,
						<cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">)
			</cfquery>
		</cfif>
	</cffunction>

	<!---function to delete BrowserTabDetails--->
	<cffunction name="deleteTabDetails" access="remote" output="yes" returnformat="json">
		<cfargument name="tabID" type="any" required="yes">
		<cfargument name="sessionid" type="any" required="yes">
		<cfargument name="userid" type="any" required="yes">
		<cfargument name="dsn" type="any" required="yes">
		<!---query to delete UserBrowserTabDetails--->
		<cfquery name="qryGetBrowserTabDetails" datasource="#arguments.dsn#">
			delete from  UserBrowserTabDetails
			where
			 sessionid=<cfqueryparam value="#arguments.sessionid#" cfsqltype="cf_sql_varchar">
			and userid=<cfqueryparam value="#arguments.userid#" cfsqltype="cf_sql_varchar">
			and tabID=<cfqueryparam value="#arguments.tabID#" cfsqltype="cf_sql_varchar">
		</cfquery>
	</cffunction>

	<!--- get Bimdable Value Shipper--->
	<cffunction name="getShipperBindable" output="false" access="remote" returntype="array">
			<cfargument name="customerid" type="any" required="yes">
			<cfargument name="dsn" type="any" required="yes">
			<cfset var dtResult = ArrayNew(2)>
			<cfset shipperStop = "">
				<cfquery name="getshipperStops" datasource="#arguments.dsn#">
					SELECT
					LoadStopID,CustomerStopName,Location,City,
					(cs.statecode) as [state],
					PostalCode,ContactPerson,EmailID,Phone,	Fax,ReleaseNo ReleaseNo,
					Blind Blind,StopDate StopDate,StopTime StopTime,TimeIn TimeIn,
					TimeOut TimeOut,Instructions Instructions,Directions Directions
					FROM LoadStops cs
					where CustomerID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.customerid#">
					AND LoadType = 1
					AND LoadID IS NOT NULL
	                ORDER BY (SELECT UPPER(LTRIM(RTRIM(CustomerStopName))))
				</cfquery>

				<cfset shipperStopId = "">
				<cfset shipperStopNameList="">
				<cfset tempList = "">
				<cfloop query="getshipperStops">
	                <cfset tempList = "#getshipperStops.CustomerStopName#" & chr(9) & "#getshipperStops.Location#" & chr(9) & "#getshipperStops.City#" & chr(9) & "#getshipperStops.State#" & chr(9) & "#getshipperStops.PostalCode#">
					<cfif isdefined('getshipperStops.Instructions') AND Trim(getshipperStops.Instructions) neq ''>
	                	<cfset tempList = tempList &chr(9) & "#Left(getshipperStops.Instructions,10)# ...">
	                </cfif>


					<cfset shipperStopId = ListAppend(shipperStopId,getshipperStops.LoadStopID)>
					<cfset shipperStopNameList = ListAppend(shipperStopNameList,tempList)>
				</cfloop>


				<!--- Convert results to array --->
				<cfif listlen(shipperStopId) gt 0>
					<cfset dtResult[1][1] = "">
					<cfset dtResult[1][2] = "CHOOSE A PICKUP OR ENTER ONE BELOW">
					<cfloop from="1" to="#listlen(shipperStopId)#" index="k">
						<cfset dtResult[k+1][1] = listgetat(shipperStopId,k)>
						<cfset dtResult[k+1][2] = "#listgetat(shipperStopNameList,k)#">
					</cfloop>
				<cfelse>
					<cfset dtResult[1][1] = "">
					<cfset dtResult[1][2] = "Customer's Pickup stop not available">
				</cfif>

			<cfreturn dtResult>
		</cffunction>

	<!--- get Bimdable Value for Consignee  --->
	<cffunction name="getConsigneeBindable" output="false" access="remote" returntype="array">
			<cfargument name="customerid" type="any" required="yes">
			<cfargument name="dsn" type="any" required="yes">
			<cfset var dtResult = ArrayNew(2)>
			<cfset shipperStop = "">
				<cfquery name="getshipperStops" datasource="#arguments.dsn#">
					SELECT
					LoadStopID,CustomerStopName,Location,City,
					(cs.statecode) as [state],
					PostalCode,ContactPerson,EmailID,Phone,	Fax,ReleaseNo ReleaseNo,
					Blind Blind,StopDate StopDate,StopTime StopTime,TimeIn TimeIn,
					TimeOut TimeOut,Instructions Instructions,Directions Directions
					FROM LoadStops cs
					where CustomerID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.customerid#">
					AND LoadType = 2
					AND LoadID IS NOT NULL
	                ORDER BY (SELECT UPPER(LTRIM(RTRIM(CustomerStopName))))
				</cfquery>

				<cfset shipperStopId = "">
				<cfset shipperStopNameList="">
				<cfset tempList = "">
				<cfloop query="getshipperStops">
	                <cfset spaces = "			">
	                <cfset tempList = "#getshipperStops.CustomerStopName#  " & "#spaces#" & "  #getshipperStops.Location#  " & "#spaces#" & "  #getshipperStops.City#  " & "#spaces#" & "  #getshipperStops.State#  " & "#spaces#" & "  #getshipperStops.PostalCode#  ">
					<cfif isdefined('getshipperStops.Instructions') AND Trim(getshipperStops.Instructions) neq ''>
	                	<cfset tempList = tempList & "#spaces#" & "  #Left(getshipperStops.Instructions,10)# ...">
	                </cfif>

					<cfset shipperStopId = ListAppend(shipperStopId,getshipperStops.LoadStopID)>
					<cfset shipperStopNameList = ListAppend(shipperStopNameList,tempList)>
				</cfloop>


				<!--- Convert results to array --->
				<cfif listlen(shipperStopId) gt 0>
					<cfset dtResult[1][1] = "">
					<cfset dtResult[1][2] = "CHOOSE A DELIVERY OR ENTER ONE BELOW">
					<cfloop from="1" to="#listlen(shipperStopId)#" index="k">
						<cfset dtResult[k+1][1] = listgetat(shipperStopId,k)>
						<cfset dtResult[k+1][2] = "#listgetat(shipperStopNameList,k)#">
					</cfloop>
				<cfelse>
					<cfset dtResult[1][1] = "">
					<cfset dtResult[1][2] = "Customer's Delivery Stop not available">
				</cfif>

			<cfreturn dtResult>
		</cffunction>

		<!----Get All Stop Information By Customer---->
	<cffunction name="getAllStopByCustomer" access="public" output="false" returntype="any">
	    <cfargument name="CustomerID" required="no" type="any">
		<cfargument name="StopType" required="no" type="any">
	         	<CFSTOREDPROC PROCEDURE="USP_GetShipperInfoByCustomer" DATASOURCE="#variables.dsn#">
					<cfif isdefined('arguments.CustomerID') and len(arguments.CustomerID)>
					 	<CFPROCPARAM VALUE="#arguments.CustomerID#" cfsqltype="CF_SQL_VARCHAR">
					 	<CFPROCPARAM VALUE="#arguments.StopType#" cfsqltype="CF_SQL_inTEGER">
					 <cfelse>
					 	<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR">
					 </cfif>
					 <CFPROCRESULT NAME="qrygetStops">
				</CFSTOREDPROC>

	<cfreturn qrygetStops>
	</cffunction>
	<!-----Get Loads By Advanced Search ---------------->
	<cffunction name="getSearchLoads" access="public" output="false" returntype="any">
	    <cfargument name="LoadStatus" type="any" required="no">
	    <cfargument name="LoadNumber" type="any" required="no">
	    <cfargument name="Office" type="any" required="no">
		<cfargument name="consigneeCity" type="any" required="no">
	    <cfargument name="shipperCity" type="any" required="no">
	    <cfargument name="ShipperState" type="any" required="no">
	    <cfargument name="ConsigneeState" type="any" required="no">
	    <cfargument name="CustomerName" type="any" required="no">
	    <cfargument name="StartDate" type="any" required="no">
	    <cfargument name="EndDate" type="any" required="no">
	    <cfargument name="CarrierName" type="any" required="no">
	    <cfargument name="CustomerPO" type="any" required="no">
	    <cfargument name="lastweek" type="any" required="no">
	    <cfargument name="thisweek" type="any" required="no">
	    <cfargument name="thismonth" type="any" required="no">
	    <cfargument name="lastmonth" type="any" required="no">
		<cfargument name="searchText" type="any" required="no">
	    <cfargument name="pageNo" required="yes" type="any">
	    <cfargument name="sortOrder" required="no" type="any">
	    <cfargument name="sortBy" required="no" type="any">
	    <cfargument name="dsn" required="no" type="any">
		<cfargument name="agentUsername" required="no" type="any">
		<cfargument name="rowsperpage" required="no" type="numeric">
		<cfargument name="bol" required="no" type="any">
		<cfargument name="dispatcher" required="no" type="any">
		<cfargument name="agent" required="no" type="any">

		<cfargument name="orderdateAdv" required="no" type="any">
		<cfargument name="invoicedateAdv" required="no" type="any">
		<cfargument name="internalRefAdv" required="no" type="any">
		<cfargument name="userDefinedForTruckingAdv" required="no" type="any">
		<cfargument name="EquipmentAdv" required="no" type="any">
		<cfargument name="BillDate" required="no" type="any">

		<cfargument name="pending" required="no" type="any" default="0">

	   	<cfset setter="123456789">
		<cfset var counterForDatefinding=0>
		<cfif isdefined('ARGUMENTS.SEARCHTEXT')>
			<cfif findnocase('/',ARGUMENTS.SEARCHTEXT) or findnocase('-',ARGUMENTS.SEARCHTEXT)>
				<cfset var counterForDatefinding=1>
			</cfif>
		</cfif>
		<cfif isdefined('arguments.dsn')>
	    	<cfset activedsn = arguments.dsn>
	    <cfelse>
	    	<cfset activedsn = variables.dsn>
	    </cfif>
	    <cfif not isdefined('arguments.pageNo') or len(arguments.pageNo) eq 0>
		 	<cfset arguments.pageNo=1>
		</cfif>
	    <cfset pageSize = 30 > <!--- Page Size --->
	    <cfif structKeyExists(arguments, "rowsperpage") AND isNumeric(arguments.rowsperpage)>
	    	<cfset pageSize = arguments.rowsperpage >
	    </cfif>
	    <cfif not isdefined('arguments.sortOrder') or len(arguments.sortOrder) eq 0>
		 	<cfset arguments.sortOrder="ASC">
		</cfif>
		
	    <cfif not isdefined('arguments.sortBy') or len(arguments.sortBy) eq 0>
	    	<cfset arguments.sortBy = "StatusOrder, l.LoadNumber">
		</cfif>
		
		<cfif isDefined("arguments.lastweek") and len(arguments.lastweek) gt 1>
			<!---
				Get today's date; but then subtract 7 days from it so that
				we have "this" day of last week. The Fix() method simply
				removes the time stamp (and converts date to numeric date).
			--->
			<cfset dtLastWeek = (Fix( Now() ) - 7) />
			<!---
				Now that we have a day in last week, we can easily grab the
				start and end of the week.
			--->
			<cfset objLastWeek = StructNew() />
			<!--- Get start of week. --->
			<cfset objLastWeek.Start = DateFormat(
			  	dtLastWeek - DayOfWeek( dtLastWeek ) + 1
			  	) />
			<!--- Get end of week by adding to start date. --->
			<cfset objLastWeek.End = DateFormat( objLastWeek.Start + 6 ) />
			<cfset arguments.StartDate = objLastWeek.Start>
			<cfset arguments.enddate = objLastWeek.End>
		</cfif>
		<cfif isDefined("arguments.thisweek") and len(arguments.thisweek) gt 1>
			<cfset dtToday = Fix( Now() ) />
			<!--- Get the week start date. --->
			<cfset dtWeekStart = (dtToday - DayOfWeek( dtToday ) + 1) />
			<!--- Get the week end date. --->
			<cfset dtWeekEnd = (dtToday + (7 - DayOfWeek( dtToday ))) />
			<cfset arguments.StartDate = dtWeekStart>
			<cfset arguments.enddate = dtWeekEnd>
		</cfif>
		<cfif isDefined("arguments.thismonth") and len(arguments.thismonth) gt 1 >
			<!--- Getting Start and end date of Month --->
			<cfset dtToday = Fix( Now() ) />
			<!--- Get the month start date. --->
			<cfset dtMonthStart = (dtToday - Day( dtToday ) + 1) />
			<!--- Get the month end date. --->
			<cfset dtMonthEnd = (
			dtToday + (DaysInMonth( dtToday ) - Day( dtToday ))
			) />
			<cfset arguments.StartDate = dtMonthStart>
			<cfset arguments.enddate = dtMonthEnd>
		</cfif>
		<cfif isDefined("arguments.lastmonth")   and len(arguments.lastmonth)>
			<!--- Getting Start and end date of Month --->
			<cfset dtToday = Fix( Now() ) />
			<cfset dtToday = DateAdd("m",-1,dtToday)>
			<!--- Get the month start date. --->
			<cfset dtMonthStart = (dtToday - Day( dtToday ) + 1) />
			<!--- Get the month end date. --->
			<cfset dtMonthEnd = (
			dtToday + (DaysInMonth( dtToday ) - Day( dtToday ))
			) />
			<cfset arguments.StartDate = dtMonthStart>
			<cfset arguments.enddate = dtMonthEnd>
		</cfif>
		<cfif NOT listFindNoCase("LoadManagerLive,weloadtrailers", activedsn)><!--- Beta version --->
			<cfset var LoadListProcName = "USP_GetLoadListBETA">
			<cfset arguments.sortBy = replaceNoCase(arguments.sortBy, "statusorder", "lst.statusorder")>
			<cfset arguments.sortBy = replaceNoCase(arguments.sortBy, "StatusDescription", "lst.StatusDescription")>
			<cfset arguments.sortBy = replaceNoCase(arguments.sortBy, "empDispatch", "E.Name")>
			<cfset arguments.sortBy = replaceNoCase(arguments.sortBy, "Equipments.EquipmentType", "Eq.EquipmentType")>
			<cfset arguments.sortBy = replaceNoCase(arguments.sortBy, "RelEquip.EquipmentName", "REq.EquipmentName")>
		<cfelse>
			<cfset var LoadListProcName = "USP_GetLoadList">
		</cfif>

		<cfset local.sortString = "">
		<cfif application.dsn NEQ "LoadManagerLive" and structKeyExists(session, "AdminUserName") and session.AdminUserName EQ 'global'>
			<cfif structKeyExists(cookie, "SortBy1") and len(trim(cookie.SortBy1))>
				<cfset local.sortString = listAppend(local.sortString, "#cookie.SortBy1# #cookie.SortOrder1#")>
			</cfif>
			<cfif structKeyExists(cookie, "SortBy2") and len(trim(cookie.SortBy2))>
				<cfset local.sortString = listAppend(local.sortString, "#cookie.SortBy2# #cookie.SortOrder2#")>
			</cfif>
			<cfif structKeyExists(cookie, "SortBy3") and len(trim(cookie.SortBy3))>
				<cfset local.sortString = listAppend(local.sortString, "#cookie.SortBy3# #cookie.SortOrder3#")>
			</cfif>
			<cfset local.sortString = replaceNoCase(local.sortString, "statusorder", "lst.statusorder")>
			<cfset local.sortString = replaceNoCase(local.sortString, "StatusDescription", "lst.StatusDescription")>
			<cfset local.sortString = replaceNoCase(local.sortString, "empDispatch", "E.Name")>
			<cfset local.sortString = replaceNoCase(local.sortString, "Equipments.EquipmentType", "Eq.EquipmentType")>
			<cfset local.sortString = replaceNoCase(local.sortString, "RelEquip.EquipmentName", "REq.EquipmentName")>
		</cfif>
		<CFSTOREDPROC PROCEDURE="#LoadListProcName#" DATASOURCE="#activedsn#">
			<CFPROCPARAM VALUE="#session.CompanyID#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#arguments.pageNo#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#arguments.sortBy#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#arguments.sortOrder#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#local.sortString#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#pageSize#" cfsqltype="CF_SQL_VARCHAR">
			<cfif structKeyExists(session, "currentusertype")>
				<CFPROCPARAM VALUE="#lcase(session.currentusertype)#" cfsqltype="CF_SQL_VARCHAR">
			<cfelse>
				<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR" null="true">
			</cfif>
			<cfif structKeyExists(session, "empID")>
				<CFPROCPARAM VALUE="#session.empID#" cfsqltype="CF_SQL_VARCHAR">
			<cfelse>
				<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR" null="true">
			</cfif>
			<cfif ListContains(session.rightsList,'showAllOfficeLoads',',')>
				<CFPROCPARAM VALUE="1" cfsqltype="CF_SQL_BIT">
			<cfelse>
				<CFPROCPARAM VALUE="0" cfsqltype="CF_SQL_BIT">
			</cfif>
			<cfif ListContains(session.rightsList,'SalesRepLoad',',')>
				<CFPROCPARAM VALUE="1" cfsqltype="CF_SQL_BIT">
			<cfelse>
				<CFPROCPARAM VALUE="0" cfsqltype="CF_SQL_BIT">
			</cfif>
			<cfif structKeyExists(session, "officeID")>
				<CFPROCPARAM VALUE="#session.officeID#" cfsqltype="CF_SQL_VARCHAR">
			<cfelse>
				<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR" null="true">
			</cfif>
			<cfif structKeyExists(session, "isCustomer") AND session.isCustomer>
				<CFPROCPARAM VALUE="#session.CustomerID#" cfsqltype="CF_SQL_VARCHAR">
			<cfelse>
				<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR" null="true">
			</cfif>
			<cfif structKeyExists(arguments,"LoadStatus")>
	            <CFPROCPARAM VALUE="#arguments.LoadStatus#" cfsqltype="CF_SQL_VARCHAR">
	        <cfelse>
	        	<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR" null="true">
	        </cfif>
	        <cfif structKeyExists(arguments,"LoadNumber")>
	            <CFPROCPARAM VALUE="#trim(arguments.LoadNumber)#" cfsqltype="CF_SQL_VARCHAR">
	        <cfelse>
	        	<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR" null="true">
	        </cfif>
	        <cfif structKeyExists(arguments,"CustomerPO")>
	            <CFPROCPARAM VALUE="#arguments.CustomerPO#" cfsqltype="CF_SQL_VARCHAR">
	        <cfelse>
	        	<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR" null="true">
	        </cfif>
	        <cfif structKeyExists(arguments,"shipperCity")>
	            <CFPROCPARAM VALUE="#replaceNoCase(arguments.shipperCity, "'", "''",'ALL')#" cfsqltype="CF_SQL_VARCHAR">
	        <cfelse>
	        	<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR" null="true">
	        </cfif>
	        <cfif structKeyExists(arguments,"consigneeCity")>
	            <CFPROCPARAM VALUE="#replaceNoCase(arguments.consigneeCity, "'", "''",'ALL')#" cfsqltype="CF_SQL_VARCHAR">
	        <cfelse>
	        	<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR" null="true">
	        </cfif>
	        <cfif structKeyExists(arguments,"ShipperState")>
	            <CFPROCPARAM VALUE="#ListQualify(arguments.ShipperState,"'")#" cfsqltype="CF_SQL_VARCHAR">
	        <cfelse>
	        	<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR" null="true">
	        </cfif>
	        <cfif structKeyExists(arguments,"ConsigneeState")>
	            <CFPROCPARAM VALUE="#ListQualify(arguments.ConsigneeState,"'")#" cfsqltype="CF_SQL_VARCHAR">
	        <cfelse>
	        	<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR" null="true">
	        </cfif>
	        <cfif structKeyExists(arguments,"CustomerName")>
	            <CFPROCPARAM VALUE="#replaceNoCase(arguments.CustomerName, "'", "''",'ALL')#" cfsqltype="CF_SQL_VARCHAR">
	        <cfelse>
	        	<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR" null="true">
	        </cfif> 
	        <cfif structKeyExists(arguments,"StartDate") AND len(trim(arguments.StartDate))>
	            <CFPROCPARAM VALUE="#URLDecode(arguments.StartDate)#" cfsqltype="CF_SQL_DATE">
	        <cfelse>
	        	<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_DATE" null="true">
	        </cfif>
	        <cfif structKeyExists(arguments,"EndDate") AND len(trim(arguments.EndDate))>
	            <CFPROCPARAM VALUE="#URLDecode(arguments.EndDate)#" cfsqltype="CF_SQL_DATE">
	        <cfelse>
	        	<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_DATE" null="true">
	        </cfif>	
			<cfif structKeyExists(arguments,"BillDate") AND len(trim(arguments.BillDate))>
	            <CFPROCPARAM VALUE="#arguments.BillDate#" cfsqltype="CF_SQL_DATE">
	        <cfelse>
	        	<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_DATE" null="true">
	        </cfif>
	        <cfif structKeyExists(arguments,"CarrierName")>
	            <CFPROCPARAM VALUE="#arguments.CarrierName#" cfsqltype="CF_SQL_VARCHAR">
	        <cfelse>
	        	<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR" null="true">
	        </cfif>
	        <cfif structKeyExists(arguments,"bol")>
	            <CFPROCPARAM VALUE="#arguments.bol#" cfsqltype="CF_SQL_VARCHAR">
	        <cfelse>
	        	<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR" null="true">
	        </cfif>
	        <cfif structKeyExists(arguments,"dispatcher")>
	            <CFPROCPARAM VALUE="#arguments.dispatcher#" cfsqltype="CF_SQL_VARCHAR">
	        <cfelse>
	        	<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR" null="true">
	        </cfif>
	        <cfif structKeyExists(arguments,"agent")>
	            <CFPROCPARAM VALUE="#arguments.agent#" cfsqltype="CF_SQL_VARCHAR">
	        <cfelse>
	        	<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR" null="true">
	        </cfif>
	        <cfif structKeyExists(arguments,"searchText") and len(arguments.searchText)>
	        	<CFPROCPARAM VALUE="#replaceNoCase(arguments.searchText, "'", "''",'ALL')#" cfsqltype="CF_SQL_VARCHAR">
	        <cfelse>
	        	<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR" null="true">
	        </cfif>
	        <cfif structKeyExists(form,"exactMatchSearch")>
	        	<CFPROCPARAM VALUE="1" cfsqltype="CF_SQL_BIT">
	        <cfelse>
	        	<CFPROCPARAM VALUE="0" cfsqltype="CF_SQL_BIT">
	        </cfif>
	        <cfif structKeyExists(arguments,"agentUsername") and len(arguments.agentUsername)>
	        	<CFPROCPARAM VALUE="#arguments.agentUsername#" cfsqltype="CF_SQL_VARCHAR">
	        <cfelse>
	        	<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR" null="true">
	        </cfif>
	        <cfif structKeyExists(arguments,"Office") and len(arguments.Office)>
	        	<CFPROCPARAM VALUE="#arguments.Office#" cfsqltype="CF_SQL_VARCHAR">
	        <cfelse>
	        	<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR" null="true">
	        </cfif>

	        <cfif structKeyExists(arguments,"orderdateAdv") AND len(trim(arguments.orderdateAdv))>
	            <CFPROCPARAM VALUE="#arguments.orderdateAdv#" cfsqltype="CF_SQL_DATE">
	        <cfelse>
	        	<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_DATE" null="true">
	        </cfif>
	        <cfif structKeyExists(arguments,"invoicedateAdv") AND len(trim(arguments.invoicedateAdv))>
	            <CFPROCPARAM VALUE="#arguments.invoicedateAdv#" cfsqltype="CF_SQL_DATE">
	        <cfelse>
	        	<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_DATE" null="true">
	        </cfif>
	        <cfif structKeyExists(arguments,"internalRefAdv") and len(arguments.internalRefAdv)>
	        	<CFPROCPARAM VALUE="#arguments.internalRefAdv#" cfsqltype="CF_SQL_VARCHAR">
	        <cfelse>
	        	<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR" null="true">
	        </cfif>
	        <cfif structKeyExists(arguments,"userDefinedForTruckingAdv") and len(arguments.userDefinedForTruckingAdv)>
	        	<CFPROCPARAM VALUE="#arguments.userDefinedForTruckingAdv#" cfsqltype="CF_SQL_VARCHAR">
	        <cfelse>
	        	<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR" null="true">
	        </cfif>
	        <cfif structKeyExists(arguments,"EquipmentAdv") and len(arguments.EquipmentAdv)>
	        	<CFPROCPARAM VALUE="#ListQualify(arguments.EquipmentAdv,"'")#" cfsqltype="CF_SQL_VARCHAR">
	        <cfelse>
	        	<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR" null="true">
	        </cfif>
	        <CFPROCPARAM VALUE="#arguments.pending#" cfsqltype="cf_sql_varchar">

	        <cfif activedsn NEQ "LoadManagerLive"><!--- Beta version --->
		        <cfif structkeyexists(url,"event") and url.event EQ 'Myload' and structKeyExists(session, "UserAssignedLoadStatus") AND structKeyExists(session, "showloadtypestatusonloadsscreen") AND session.showloadtypestatusonloadsscreen EQ 1>
		        	<cfif len(trim(session.UserAssignedLoadStatus["MyLoads"]))>
			        	<CFPROCPARAM VALUE="#ListQualify(session.UserAssignedLoadStatus["MyLoads"],"'")#" cfsqltype="CF_SQL_VARCHAR">
			        <cfelse>
			        	<CFPROCPARAM VALUE="'00000000-0000-0000-0000-000000000000'" cfsqltype="CF_SQL_VARCHAR">
			        </cfif>
		        <cfelseif structkeyexists(url,"event") and url.event EQ 'load' and structKeyExists(session, "UserAssignedLoadStatus") AND structKeyExists(session, "showloadtypestatusonloadsscreen") AND session.showloadtypestatusonloadsscreen EQ 1>
		        	<cfif len(trim(session.UserAssignedLoadStatus["AllLoads"]))>
			        	<CFPROCPARAM VALUE="#ListQualify(session.UserAssignedLoadStatus["AllLoads"],"'")#" cfsqltype="CF_SQL_VARCHAR">
			        <cfelse>
			        	<CFPROCPARAM VALUE="'00000000-0000-0000-0000-000000000000'" cfsqltype="CF_SQL_VARCHAR">
			        </cfif>
		        <cfelse>
		        	<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR" null="true">
		    	</cfif>
		    <cfelse>
		    	<cfif structkeyexists(url,"event") and url.event EQ 'Myload' and structKeyExists(session, "UserAssignedLoadStatus") AND structKeyExists(session, "showloadtypestatusonloadsscreen") AND session.showloadtypestatusonloadsscreen EQ 1>
		        	<CFPROCPARAM VALUE="#ListQualify(session.UserAssignedLoadStatus["MyLoads"],"'")#" cfsqltype="CF_SQL_VARCHAR">
		        <cfelseif structkeyexists(url,"event") and url.event EQ 'load' and structKeyExists(session, "UserAssignedLoadStatus") AND structKeyExists(session, "showloadtypestatusonloadsscreen") AND session.showloadtypestatusonloadsscreen EQ 1>
		        	<CFPROCPARAM VALUE="#ListQualify(session.UserAssignedLoadStatus["AllLoads"],"'")#" cfsqltype="CF_SQL_VARCHAR">
		        <cfelse>
		        	<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR" null="true">
		    	</cfif>
		    </cfif>
	    	<cfif structKeyExists(session, "showloadtypestatusonloadsscreen")>
	    		<CFPROCPARAM VALUE="#session.showloadtypestatusonloadsscreen#" cfsqltype="CF_SQL_BIT">
	    	<cfelse>
	    		<CFPROCPARAM VALUE="0" cfsqltype="CF_SQL_BIT">
	    	</cfif>
	    	<cfif structKeyExists(cookie, "FilterLoadsByDays") AND cookie.FilterLoadsByDays EQ 1 AND structKeyExists(cookie,"LoadsDaysFilter") AND len(trim(cookie.LoadsDaysFilter)) AND isNumeric(cookie.LoadsDaysFilter)>
		    	<CFPROCPARAM VALUE="#cookie.LoadsDaysFilter#" cfsqltype="CF_SQL_INTEGER">
		    <cfelseif structKeyExists(arguments,"LoadStatus") AND structKeyExists(cookie, "advFilterLoadsByDays") AND cookie.advFilterLoadsByDays EQ 1 AND structKeyExists(cookie,"advLoadsDaysFilter") AND len(trim(cookie.advLoadsDaysFilter)) AND isNumeric(cookie.advLoadsDaysFilter)>
		    	<CFPROCPARAM VALUE="#cookie.advLoadsDaysFilter#" cfsqltype="CF_SQL_INTEGER">	
		    <cfelse>
		    	<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_INTEGER" null="true">
		    </cfif>
			<cfprocresult name="qrygetload">
		</CFSTOREDPROC>
	    <cfreturn qrygetload>
	</cffunction>

	<!--- Check MC Number--->
	<cffunction name="checkMCNumber" access="remote" output="false" returntype="boolean" returnformat="json">
	    <cfargument name="McNumber" required="no" type="any">
		<cfargument name="dsn" required="no" type="any">
		<cfargument name="companyid" required="yes" type="string">
		 <cfquery name="checkMc" datasource="#arguments.dsn#">
	    	select * from carriers where MCNumber =<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.McNumber#">
	    	and companyid =<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.companyid#">
		 </cfquery>
		 <cfif checkMc.recordcount gt 0>
		 	<cfreturn true>
		 <cfelse>
		 	<cfreturn false>
		 </cfif>
	</cffunction>

	<!--- Check Agent Login--->
	<cffunction name="checkLoginId" access="remote" output="false" returntype="boolean" returnformat="json">
		<cfargument name="companyid" required="no" type="any">
	    <cfargument name="Loginid" required="no" type="any">
		<cfargument name="dsn" required="no" type="any">
		<cfargument name="empID" required="no" type="any">

		 <cfquery name="checkMc" datasource="#arguments.dsn#">
	    	select employees.employeeid from employees
	    	inner join Offices on Offices.OfficeID = Employees.OfficeID
            inner join Companies on companies.CompanyID = Offices.CompanyID
	    	where loginid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.Loginid#">
	    	AND companies.CompanyID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.CompanyID#">
	    	<cfif structKeyExists(arguments,"empID") AND arguments.empID NEQ 'undefined' AND arguments.empID NEQ 0>
	    		AND EmployeeID != <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.empID#">
	    	</cfif>
		 </cfquery>
		 <cfif checkMc.recordcount gt 0>
		 	<cfreturn true>
		 <cfelse>
		 	<cfreturn false>
		 </cfif>
	</cffunction>

	<!--- get Bimdable Value Sattelite office--->
	<cffunction name="getSatelliteOfficeBindable" output="false" access="remote" returntype="array">
			<cfargument name="carrierid" type="any" required="yes">
			<cfargument name="dsn" type="any" required="yes">
			<cfset var dtResult = ArrayNew(2)>
			<cfset carrierOfficeId ="">
			<cfset carrierOfficeLoacation = "">
			<cfset tempCarrOffId="">
			<cfset tempCarrOffLoc="">
				<cfquery name="getcarrieroffices" datasource="#arguments.dsn#">
					select * from carrieroffices  where location <> '' and carrierID=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.carrierid#">
				</cfquery>
				<cfset tempCarrOffId="#valuelist(getcarrieroffices.CarrierOfficeID)#">
				<cfset tempCarrOffLoc="#valuelist(getcarrieroffices.location)#">
				<cfoutput query="getcarrieroffices">
					<cfset carrierOfficeId = ListAppend(carrierOfficeId,getcarrieroffices.CarrierOfficeID)>
					<cfset carrierOfficeLoacation = ListAppend(carrierOfficeLoacation,getcarrieroffices.location)>
				</cfoutput>
				<!--- Convert results to array --->
				<cfif listlen(tempCarrOffId) gt 0>
					<cfset dtResult[1][1] = "">
					<cfset dtResult[1][2] = "Choose a Satellite Office Contact">
					<cfloop from="1" to="#listlen(tempCarrOffId)#" index="k">
						<cfset dtResult[k+1][1] = listgetat(tempCarrOffId,k)>
						<cfset dtResult[k+1][2] = "#listgetat(tempCarrOffLoc,k)#">
					</cfloop>
				<cfelse>
					<cfset dtResult[1][1] = "">
					<cfset dtResult[1][2] = "Satellite office not available">
				</cfif>

			<cfreturn dtResult>
		</cffunction>

	    <!--- get AJAX Bindable Value Sattelite office--->
	<cffunction name="getAjaxSatelliteOfficeBindable" access="remote" output="yes" returnformat="json">
			<cfargument name="carrierid" type="any" required="yes">
			<cfargument name="dsn" type="any" required="yes">
			<cfset var dtResult = ArrayNew(2)>
			<cfset carrierOfficeId ="">
			<cfset carrierOfficeLoacation = "">
			<cfset tempCarrOffId="">
			<cfset tempCarrOffLoc="">
				<cfquery name="getcarrieroffices" datasource="#arguments.dsn#">
					select * from carrieroffices  where location <> '' and carrierID=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.carrierid#">
				</cfquery>
				<cfset tempCarrOffId="#valuelist(getcarrieroffices.CarrierOfficeID)#">
				<cfset tempCarrOffLoc="#valuelist(getcarrieroffices.location)#">
				<cfoutput query="getcarrieroffices">
					<cfset carrierOfficeId = ListAppend(carrierOfficeId,getcarrieroffices.CarrierOfficeID)>
					<cfset carrierOfficeLoacation = ListAppend(carrierOfficeLoacation,getcarrieroffices.location)>
				</cfoutput>
				<!--- Convert results to array --->
				<cfif listlen(tempCarrOffId) gt 0>
					<cfset dtResult[1][1] = "">
					<cfset dtResult[1][2] = "Choose a Satellite Office Contact">
					<cfloop from="1" to="#listlen(tempCarrOffId)#" index="k">
						<cfset dtResult[k+1][1] = listgetat(tempCarrOffId,k)>
						<cfset dtResult[k+1][2] = "#listgetat(tempCarrOffLoc,k)#">
					</cfloop>
				<cfelse>
					<cfset dtResult[1][1] = "">
					<cfset dtResult[1][2] = "Satellite office not available">
				</cfif>

			<!---<cfreturn dtResult>--->
	        #SerializeJSON(dtResult)#
		</cffunction>
	<!---  Check MC Number for new carrier entry----------->

	<cffunction name="checkcarrierMCNumber" access="remote" output="false" returntype="query">
	    <cfargument name="McNumber" required="no" type="any">
	    <cfargument name="DotNumber" required="no" type="any">
	    <cfargument name="CarrierName" required="no" type="any">
		<cfargument name="dsn" required="no" type="any">
		 	<cfif structKeyExists(arguments, "McNumber")>
				 <cfquery name="checkMc" datasource="#arguments.dsn#">
			    	select * from carriers where MCNumber =<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.McNumber#">
			    	and companyid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#session.CompanyID#">
				 </cfquery>
			<cfelseif structKeyExists(arguments, "DotNumber")>
				<cfquery name="checkMc" datasource="#arguments.dsn#">
			    	select * from carriers where DOTNumber =<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.DotNumber#">
			    	and companyid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#session.CompanyID#">
				 </cfquery>
			<cfelseif structKeyExists(arguments, "CarrierName")>
				<cfquery name="checkMc" datasource="#arguments.dsn#">
			    	select * from carriers where CarrierName =<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.CarrierName#">
			    	and companyid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#session.CompanyID#">
				 </cfquery>
			</cfif>
		<cfreturn checkMc>

	</cffunction>


	<cffunction name="getLoadStopInfo" access="public" returntype="any">
	    <cfargument name="StopNo" required="yes" type="any">
		<cfargument name="LoadType" required="yes" type="any">
		<cfargument name="loadID" required="yes" type="any">

		 <cftry>
			 <cfquery name="qGetLoadStopInfo" datasource="#variables.dsn#">
		    	SELECT
					*
				FROM
					LoadStops
				WHERE
					loadID = <cfqueryparam value="#loadID#" cfsqltype="cf_sql_varchar"> AND
					LoadType = <cfqueryparam value="#LoadType#" cfsqltype="cf_sql_tinyint"> AND
					StopNo = <cfqueryparam value="#StopNo#" cfsqltype="cf_sql_integer">
			 </cfquery>
			<cfcatch>
				<cfset qGetLoadStopInfo.recordcount = 0>
			</cfcatch>
		 </cftry>
		<cfreturn qGetLoadStopInfo>

	</cffunction>

	<!-----------Check whether the Customer data exist or not---------------->
	<cffunction name="customerDataCheck" access="remote" hint="Check whether the Customer data exist or not" returnformat="json" >
		<cfargument name="dsnName" type="string" required="true">
		<cfargument name="CompanyID" type="string" required="true">
		<cfargument name="customerName" type="string" required="true">
		<cfargument name="customerAddress" type="string" required="true">
		<cfargument name="customerCity" type="string" required="true">
		<cfargument name="customerState" type="string" required="true">
		<cfargument name="customerZipCode" type="string" required="true">
		<cfquery name="dataExistenseCheck" datasource="#arguments.dsnName#" >
			select customerID,isPayer  from customers
				where customerName COLLATE Latin1_General_CS_AS = <cfqueryparam cfsqltype="cf_sql_varchar" value="#trim(arguments.customerName)#">
				and location COLLATE Latin1_General_CS_AS = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.customerAddress#">
				and city COLLATE Latin1_General_CS_AS = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.customerCity#">
				<cfif arguments.customerState neq "">
					and statecode = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.customerState#">
				</cfif>
				and zipCode COLLATE Latin1_General_CS_AS = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.customerZipCode#">
				and customerName <> null
				and customerid in (select customerid from CustomerOffices inner join offices on CustomerOffices.officeid = offices.officeid where offices.companyid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.CompanyID#">)
		</cfquery>
		<cfset checkResultStruct = '|'&dataExistenseCheck.recordcount & '|'& dataExistenseCheck.customerID &'|'& dataExistenseCheck.isPayer &'|'>
		<cfreturn checkResultStruct>
	</cffunction>
	<cffunction name="getIsPayer" access="public" returntype="any">
	<cfargument name="loadID" type="string" required="true">
		<cfquery name="payerValue" datasource="#variables.dsn#">
			select c.isPayer
			from Customers c
			inner join Loads l on c.CustomerID=l.CustomerID
			WHERE l.loadID = <cfqueryparam value="#loadID#" cfsqltype="cf_sql_varchar">
		</cfquery>
		<cfreturn payerValue>
	</cffunction>
	<cffunction name="getIsPayerStop" access="public" returntype="query">
		<cfargument name="customerID" type="string" required="true">
		<cfquery name="qGetIsPayer" datasource="#variables.dsn#">
			select isPayer
			from Customers
			<cfif len(trim(arguments.customerID))>
				WHERE CustomerID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.customerID#">
			<cfelse>
				WHERE CustomerID = <cfqueryparam cfsqltype="cf_sql_varchar" value="" null="true">
			</cfif>
		</cfquery>
		<cfreturn qGetIsPayer>
	</cffunction>

	<cffunction name="getPayerStop" access="public" returntype="query">
		<cfargument name="stopID" type="string" required="true">
		<cfquery name="qGetPayer" datasource="#variables.dsn#">
			select isPayer
			from Customers
			where customerid = (select customerID from loadstops where LoadStopID = 
				<cfif len(trim(arguments.stopID))>
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.stopID#">
				<cfelse>
					NULL
				</cfif>
				)
		</cfquery>
		<cfreturn qGetPayer>
	</cffunction>

	<!-----------Get distinct shipper or consignee---------------->
	<cffunction name="GetShipperConsignee" access="public" hint="Check whether the Customer data exist or not" returnType = "any" >
		<cfargument name="loadid" type="string" required="true">
		<cfargument name="loadtype" type="string" required="true">

		<cfquery name="qryShipperConsignee" datasource="#variables.dsn#" >
			select loadstopid,custname,customerID,Address,city,statecode,postalcode,blind,phone,fax,ForBOL from LoadStops where LoadID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.loadid#">
			and loadtype = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.loadtype#">
		</cfquery>
		<cfreturn qryShipperConsignee>
	</cffunction>


	<cffunction name="AddBOLDetails" access="remote" returntype="any">
	<cfargument name="frmstruct" type="struct" required="yes">

		<cfif not structkeyexists(variables,"dsn")>
			<cfset variables.dsn = frmstruct.dsn>
		</cfif>
		<cfset frmstruct.DeclaredValue = replace(frmstruct.DeclaredValue, ",", "", "all")>

		<cfif arguments.frmstruct.DeclaredValue eq ''>
			<cfset DeclaredValue = 0>
		<cfelse>
			<cfset findpos = find("$",arguments.frmstruct.DeclaredValue)>
			<cfif findpos neq 0>
				 <cfset DeclaredValue = #Removechars(arguments.frmstruct.DeclaredValue, findpos, 1)# >
			<cfelse>
				<cfset DeclaredValue = arguments.frmstruct.DeclaredValue>
			</cfif>
		</cfif>

		<cfset frmstruct.CODAmount = replace(frmstruct.CODAmount, ",", "", "all")>
		<cfif arguments.frmstruct.CODAmount eq ''>
			<cfset CODAmt = 0>
		<cfelse>
			<cfset findlen = find("$",arguments.frmstruct.CODAmount)>
			<cfif findlen neq 0>
				 <cfset CODAmt = #Removechars(arguments.frmstruct.CODAmount, findlen, 1)# >
			 <cfelse>
			 	<cfset CODAmt = arguments.frmstruct.CODAmount>
			</cfif>
			
		</cfif>

		<cftransaction>
			<cfquery name="updateLoads" datasource="#variables.dsn#">
				update loads set EmergencyResponseNo = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.frmstruct.EmergencyResponseNo#">,
					CODAmt = <cfqueryparam cfsqltype="cf_sql_money" value="#CODAmt#">,
					CODFee = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.frmstruct.CODFee#">,
					DeclaredValue = <cfqueryparam cfsqltype="cf_sql_money" value="#DeclaredValue#">,
					Notes = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.frmstruct.Notes#">
					,BOLFromName = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.frmstruct.BOLFromName#">
					,BOLFromTel = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.frmstruct.BOLFromTel#">
					,BOLFromEmail = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.frmstruct.BOLFromEmail#">
					,BOLREName = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.frmstruct.BOLREName#">
					,BOLREPO = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.frmstruct.BOLREPO#">
					where loadid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.frmstruct.loadid#">
			</cfquery>

			<cfquery name="resetAllLoadstops" datasource="#variables.dsn#">
				update loadstops set ForBOL = 0 where loadid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.frmstruct.loadid#">
			</cfquery>
			<cfparam name="variables.customeridlist" default="">
			<cfset variables.customeridlist=listAppend(variables.customeridlist, "#arguments.frmstruct.consignee#")>
			<cfset variables.customeridlist=listAppend(variables.customeridlist, "#arguments.frmstruct.shipper#")>
			<cfquery name="updatecheckedShipperConsignee" datasource="#variables.dsn#">
				update loadstops set ForBOL = 1 where loadid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.frmstruct.loadid#">
					<cfif len(trim(variables.customeridlist))>
					and customerId in (<cfqueryparam cfsqltype="cf_sql_varchar" value="#variables.customeridlist#" list="true">)
					</cfif>
			</cfquery>
			<cfinvoke method="getSystemSetupOptions" returnvariable="request.qSystemSetupOptions" CompanyID="#arguments.frmstruct.companyid#">
			<cfif request.qSystemSetupOptions.UseNonFeeAccOnBOL NEQ 1>
				<cfquery name="deleteExisting" DATASOURCE="#variables.dsn#">
					delete from LoadStopsBOL where LoadStopIDBOL =  <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.frmstruct.loadid#">
				</cfquery>
			
				<cfloop from="1" to="5" index="Num">
				     <cfset var desc=evaluate("arguments.frmstruct.description#num#")>
					 <cfset var hazmat=evaluate("arguments.frmstruct.hazmat#num#")>
					 <cfset var class=evaluate("arguments.frmstruct.class#num#")>
					 <cfset var weight=VAL(replaceNoCase(evaluate("arguments.frmstruct.weight#num#"), ",", "","ALL"))>
					 <cfset var pieces=VAL(evaluate("arguments.frmstruct.pieces#num#"))>
					 <cfif desc neq '' or hazmat neq '' or weight neq ''>
						 <CFSTOREDPROC PROCEDURE="USP_InsertLoadStopsBOL" DATASOURCE="#variables.dsn#">
							<CFPROCPARAM VALUE="#arguments.frmstruct.loadid#" cfsqltype="CF_SQL_VARCHAR">
						 	<CFPROCPARAM VALUE="#num#" cfsqltype="CF_SQL_VARCHAR">
						 	<CFPROCPARAM VALUE="#pieces#" cfsqltype="CF_SQL_float">
						 	<CFPROCPARAM VALUE="#desc#" cfsqltype="CF_SQL_VARCHAR">
						 	<CFPROCPARAM VALUE="#weight#" cfsqltype="CF_SQL_float">
						 	<CFPROCPARAM VALUE="#class#" cfsqltype="CF_SQL_VARCHAR">
						 	<CFPROCPARAM VALUE="#hazmat#" cfsqltype="CF_SQL_VARCHAR">
						 	<CFPROCRESULT NAME="qInsertedLoadBOL">
						</cfstoredproc>
					</cfif>
				</cfloop>
			</cfif>
		</cftransaction>

	</cffunction>


	<cffunction name="GetBOLDetails" access="public" returntype="any">
		<cfargument name="loadid" type="string" required="yes">

		<cfinvoke method="getSystemSetupOptions" returnvariable="request.qSystemSetupOptions">

		<cfquery name="getLoadStopBol" datasource="#variables.dsn#">
			<cfif request.qSystemSetupOptions.UseNonFeeAccOnBOL EQ 1>
				SELECT 
				srno,
				qty,
				Description,
				weight,
				classid,
				'' AS hazmat
				FROM loadstopcommodities WHERE loadstopid in (SELECT loadstopid FROM loadstops WHERE loadid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.loadid#">) 
				AND FEE = 0
				ORDER BY srno
			<cfelse>
				SELECT
				srno,
				qty,
				Description,
				weight,
				classid,
				hazmat
				FROM LoadStopsBOL WHERE LoadStopIDBOL = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.loadid#">
				ORDER BY SrNo
			</cfif>
		</cfquery>

		<cfreturn getLoadStopBol>
	</cffunction>

	<cffunction name="getBolterms" access="public" returntype="any">

		<cfquery name="getCarrierTerms" datasource="#variables.dsn#">
			select carrierTerms from systemconfig where CompanyID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#session.companyid#">
		</cfquery>

		<cfreturn getCarrierTerms>
	</cffunction>

	<cffunction name="getAttachedFiles" access="public" returntype="query">
		<cfargument name="linkedid" type="string">
		<cfargument name="fileType" type="string">

		<cfquery name="getFilesAttached" datasource="#variables.dsn#">
			select * from FileAttachments where linked_id=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.linkedid#"> and linked_to=<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.fileType#">
		</cfquery>

		<cfreturn getFilesAttached>
	</cffunction>
	<!-----------get count for add/editload page-------->

	<cffunction name="getloadAttachedFiles" access="public" returntype="query">
		<cfargument name="linkedid" type="string">
		<cfargument name="fileType" type="string">

		<cfquery name="getFilesAttached" datasource="#variables.dsn#">
			select count(*) as recunt from FileAttachments where linked_id=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.linkedid#"> and linked_to=<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.fileType#">
		</cfquery>

		<cfreturn getFilesAttached>
	</cffunction>
	<!--- Delete Files--->
	<cffunction name="deleteAttachments" access="remote" returntype="any" returnformat="JSON">
		<cfargument name="fileId" type="string" required="yes" />
		 <cfargument name="fileName" required="yes" type="string">
		<cfargument name="dsnName" required="yes" type="string">
		<cfargument name="newFlag" required="yes" type="numeric">
		<cfargument name="companyID" type="string" required="yes">
		<!--- Begin : DropBox Integration  ---->
		<cfquery name="qrygetSettingsForDropBox" datasource="#arguments.dsnName#">
			SELECT
				DropBox,
				DropBoxAccessToken
			FROM SystemConfig WHERE CompanyID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.CompanyID#" >
		</cfquery>
		<cfquery name="qGetCompany" datasource="#arguments.dsnName#">
			SELECT 
				CompanyCode
			FROM Companies WHERE CompanyID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.CompanyID#" >
		</cfquery>
		<cfset fileString = "#expandPath('../fileupload/img/#qGetCompany.CompanyCode#/#arguments.fileName#')#">
		<cfquery name="qrygetCommonDropBox" datasource="LoadManagerAdmin">
			SELECT 
			<cfif len(trim(qrygetSettingsForDropBox.DropBoxAccessToken))>
				'#qrygetSettingsForDropBox.DropBoxAccessToken#'
			<cfelse>
				DropBoxAccessToken 
			</cfif>
			AS DropBoxAccessToken
			FROM SystemSetup
		</cfquery>
		<cfif qrygetSettingsForDropBox.DropBox EQ 1>
			<cfoutput>
			<cfset tmpStruct = {"path":"/fileupload/img/#qGetCompany.CompanyCode#/#arguments.fileName#"}>
		</cfoutput>
			<cfhttp
					method="post"
					url="https://api.dropboxapi.com/2/files/delete"
					result="returnStruct">
							<cfhttpparam type="HEADER" name="Authorization" value="Bearer #qrygetCommonDropBox.DropBoxAccessToken#">
							<cfhttpparam type="HEADER" name="Content-Type" value="application/json">
							<cfhttpparam type="body" value="#serializeJSON(tmpStruct)#">
			</cfhttp>

		</cfif>
		<!--- End : DropBox Integration  ---->
				<cfif arguments.newFlag eq 0>
					<cfquery name="deleteItems" datasource="#arguments.dsnName#">
						delete from FileAttachments where attachment_Id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.fileId#">
						delete from MultipleFileAttachmentsTypes where attachmentId = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.fileId#"> 
					</cfquery>
				<cfelse>
					<cfquery name="deleteItems" datasource="#arguments.dsnName#">
						delete from FileAttachmentsTemp where attachment_Id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.fileId#">
						delete from MultipleFileAttachmentsTypes where attachmentId = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.fileId#"> 
					</cfquery>
				</cfif>
				<!--- need to add code to remove the file from the directory aswell --->
				<cfif fileexists(fileString)>
					<cffile action="delete" file="#fileString#">
				</cfif>
			     <cfreturn true>
	</cffunction>

	<cffunction name="GetAttachmentCount" access="remote" returntype="any" returnformat="JSON">
		<cfargument name="loadid" type="string" required="yes" />
		<cfargument name="dsnName" required="yes" type="string">
		<cfargument name="companyID" type="string" required="yes">
		<!--- Begin : DropBox Integration  ---->
		<cfquery name="qGetAttachmentCount" datasource="#arguments.dsnName#">
			select count(attachment_Id) as attCount from FileAttachments where linked_id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.loadid#" >
		</cfquery>
		<cfreturn qGetAttachmentCount.attCount>
	</cffunction>
	<!--- Link attachments --->
	<cffunction name="linkAttachments">
		<cfargument name="tempLoadId" type="string" required="yes" />
		<cfargument name="permLoadId" type="string" required="yes" />

		<cfquery name="retriveFromTemp" datasource="#application.dsn#">
			select * from fileattachmentstemp where linked_id =<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.tempLoadId#" >;
		</cfquery>
		<cfset flagFile = 0>

		<cfif retriveFromTemp.recordcount>
			<cfloop query="retriveFromTemp">
				<cfquery name="insertFilesUploaded" datasource="#application.dsn#" result="insertedId">
					insert into FileAttachments(linked_Id,linked_to,attachedFileLabel,attachmentFileName,uploadedBy,Billingattachments)
					values(
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#permLoadId#" >,
						<cfqueryparam cfsqltype="cf_sql_integer" value="#retriveFromTemp.linked_to#" >,
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#retriveFromTemp.attachedFileLabel#" >,
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#retriveFromTemp.attachmentFileName#" >,
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#retriveFromTemp.uploadedBy#" >,
						<cfqueryparam cfsqltype="cf_sql_bit" value="#retriveFromTemp.Billingattachments#" >)
				</cfquery>
				<cfset variables.attachnumber=1>
				<cfif isnumeric(insertedId.GENERATEDKEY)>
					<cfset variables.attachnumber=insertedId.GENERATEDKEY>
				</cfif>

				<cfset variables.listlength=listlen(retriveFromTemp.attachmentFileName,'.')>
				<cfset listposition=2>
				<cfif isnumeric(variables.listlength)>
					<cfset listposition=val(variables.listlength)-1>
				</cfif>
				<cfset variables.filenametempSecondLast=ListGetAt(retriveFromTemp.attachmentFileName, listposition,'.')>
				<cfset variables.filenameEdited1=Replace(retriveFromTemp.attachmentFileName, '#variables.filenametempSecondLast#', '#variables.attachnumber#' ,'.')>

				<CFSET UploadDir = "#expandPath('../fileupload/img/')#">
				<cfif not directoryExists(UploadDir)>
					<cfdirectory action="create" directory="#UploadDir#">
				</cfif>
				<cffile  action = "rename" destination = "#UploadDir##variables.filenameEdited1#"  source = "#UploadDir##retriveFromTemp.attachmentFileName#">
				<cfquery name="qryUpdate" datasource="#application.dsn#">
					update FileAttachments
					set attachmentFileName=<cfqueryparam cfsqltype="cf_sql_varchar" value="#variables.filenameEdited1#">
					where attachment_Id=<cfqueryparam cfsqltype="cf_sql_integer" value="#variables.attachnumber#">
				</cfquery>
			</cfloop>
			<cfset flagFile =1>
		</cfif>
		<cfif flagFile eq 1>
			<cfquery name="deleteTempFiles" datasource="#application.dsn#">
				delete from fileattachmentstemp where linked_id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#tempLoadId#">
			</cfquery>

		</cfif>

	</cffunction>


	<!--- Function to avoid special characters that causing errors with webservice --->
	<cffunction name="escapeSpecialCharacters" access="public" returntype="String" >
		<cfargument name="filterString" required="true" type="string">

		<cfreturn replace(arguments.filterString, "&", "&amp;","ALL")>
	</cffunction>

	<!--- Function to get LoadStop Intermodal Import --->
	<cffunction name="getLoadStopIntermodalImport" access="public" returntype="query" >
		<cfargument name="loadstopid" default="">
		<cfquery name="qLoadStopIntermodalImport" datasource="#application.dsn#">
			select * from LoadStopIntermodalImport
			where
				loadstopid = <cfqueryparam value="#arguments.loadstopid#" cfsqltype="CF_SQL_VARCHAR">
		</cfquery>
		<cfreturn qLoadStopIntermodalImport>
	</cffunction>

	<!--- Function to get LoadStop Intermodal Export --->
	<cffunction name="getLoadStopIntermodalExport" access="public" returntype="query" >
		<cfargument name="loadstopid" default="">
		<cfquery name="qLoadStopIntermodalExport" datasource="#application.dsn#">
			select * from LoadStopIntermodalExport
			where
				loadstopid = <cfqueryparam value="#arguments.loadstopid#" cfsqltype="CF_SQL_VARCHAR">
		</cfquery>
		<cfreturn qLoadStopIntermodalExport>
	</cffunction>

	<!--- Function to add log for mails on Reports--->
	<cffunction name="setLogMails" access="public">
		<cfargument name="loadID" required="yes" type="string">
		<cfargument name="date" required="yes" type="string">
		<cfargument name="subject" required="yes" type="string">
		<cfargument name="emailBody" required="yes" type="string">
		<cfargument name="reportType" required="yes" type="string">
		<cfargument name="fromAddress" required="yes" type="string">
		<cfargument name="toAddress" required="yes" type="string">

		<cfset loadNo = "n/a" >
		<cfif arguments.loadID neq "n/a">
			<cfquery name="qryGetLoadNumber" datasource="#application.dsn#">
				SELECT LoadNumber FROM Loads WHERE LoadID = <cfqueryparam value="#arguments.loadID#" cfsqltype="cf_sql_varchar">
			</cfquery>
			<cfset loadNo = qryGetLoadNumber.LoadNumber>
		</cfif>

		<cfquery name="qrySetEmailLog" datasource="#application.dsn#" result="qResult">
			INSERT INTO EmailLogs(loadID,loadno,date,subject,emailBody,reportType,createDate,fromAddress,toAddress
				<cfif structkeyexists(session,"CompanyID")>,CompanyID</cfif>)
			VALUES(
		    <cfqueryparam value="#arguments.loadID#" cfsqltype="cf_sql_varchar">,
		    <cfqueryparam value="#loadNo#" cfsqltype="cf_sql_varchar">,
		    <cfqueryparam value="#arguments.date#" cfsqltype="cf_sql_timestamp">,
		    <cfqueryparam value="#arguments.subject#" cfsqltype="cf_sql_varchar">,
		    <cfqueryparam value="#arguments.emailBody#" cfsqltype="cf_sql_varchar">,
		    <cfqueryparam value="#arguments.reportType#" cfsqltype="cf_sql_varchar">,
		    <cfqueryparam value="#Now()#" cfsqltype="cf_sql_timestamp" >,
		    <cfqueryparam value="#arguments.fromAddress#" cfsqltype="cf_sql_varchar">,
		    <cfqueryparam value="#arguments.toAddress#" cfsqltype="cf_sql_varchar">
		    <cfif structkeyexists(session,"CompanyID")>
		    	,<cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar">
		    </cfif>)
		</cfquery>
	</cffunction>

	<cffunction name="getCompanyInformation" access="remote" returntype="query">
		<cfargument name="dsn" type="any" required="no"/>
	    <cfif isdefined('dsn')>
	    	<cfset activedns = dsn>
	    <cfelse>
	    	<cfset activedns = variables.dsn>
	    </cfif>
		<cfquery name="qGetCompanyInformation" datasource="#activedns#">
	    	SELECT S.companyName,S.CompanyLogoName,CompanyCode,MC,phone,fax, address, address2, city, state, zipCode, companies.companyID,email,ccOnEmails,email,
	    	RemitInfo1,RemitInfo2,RemitInfo3,RemitInfo4,RemitInfo5,RemitInfo6,Contact
	        FROM companies, SystemConfig S
	        WHERE companies.companyid = <cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar">
	        AND S.companyid = <cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar">
	    </cfquery>
	    <cfreturn qGetCompanyInformation>
	</cffunction>

	<!---function to update companydetails--->
	<cffunction name="setCompanyInformationUpdate" access="public" returntype="string">
		<cfargument name="companyName" type="string" required="yes"/>
		<cfargument name="MC" type="string" required="yes"/>
		<cfargument name="emailId" type="string" required="yes"/>
		<cfargument name="ccOnEmails" type="string" required="yes"/>
		<cfargument name="address" type="string" required="yes"/>
		<cfargument name="address2" type="string" required="yes"/>
		<cfargument name="city" type="string" required="yes"/>
		<cfargument name="zipCode" type="string" required="yes"/>
		<cfargument name="state" type="string" required="yes"/>
		<cfargument name="companyLogoName" type="string" required="yes"/>
		<cfargument name="RemitInfo1" type="string" required="yes"/>
		<cfargument name="RemitInfo2" type="string" required="yes"/>
		<cfargument name="RemitInfo3" type="string" required="yes"/>
		<cfargument name="RemitInfo4" type="string" required="yes"/>
		<cfargument name="RemitInfo5" type="string" required="yes"/>
		<cfargument name="RemitInfo6" type="string" required="yes"/>
		<cfargument name="phone" type="string" required="yes"/>
		<cfargument name="fax" type="string" required="yes"/>
		<cfargument name="contact" type="string" required="yes"/>
		<!---Query  to update companydetails--->
		<cfquery name="qrySetCompanyInformationUpdate" datasource="#Application.dsn#" result="qResult">
			SET NOCOUNT ON
			UPDATE Companies
			SET 
			CompanyName = <cfqueryparam value="#arguments.companyName#" cfsqltype="cf_sql_varchar">,
			MC = <cfqueryparam value="#replaceNoCase(arguments.MC, "MC", "", "ALL")#" cfsqltype="cf_sql_varchar">,
		    email = <cfqueryparam value="#arguments.emailId#" cfsqltype="cf_sql_varchar">,
		    ccOnEmails = <cfqueryparam value="#arguments.ccOnEmails#" cfsqltype="cf_sql_bit">,
		    phone = <cfqueryparam value="#arguments.phone#" cfsqltype="cf_sql_varchar">,
		    fax = <cfqueryparam value="#arguments.fax#" cfsqltype="cf_sql_varchar">,
		    address = <cfqueryparam value="#arguments.address#" cfsqltype="cf_sql_varchar">,
			address2 = <cfqueryparam value="#arguments.address2#" cfsqltype="cf_sql_varchar">,
			city = <cfqueryparam value="#arguments.city#" cfsqltype="cf_sql_varchar">,
			zipCode = <cfqueryparam value="#arguments.zipCode#" cfsqltype="cf_sql_varchar">,
			state = <cfqueryparam value="#arguments.state#" cfsqltype="cf_sql_varchar">,
			RemitInfo1 = <cfqueryparam value="#arguments.RemitInfo1#" cfsqltype="cf_sql_varchar">,
			RemitInfo2 = <cfqueryparam value="#arguments.RemitInfo2#" cfsqltype="cf_sql_varchar">,
			RemitInfo3 = <cfqueryparam value="#arguments.RemitInfo3#" cfsqltype="cf_sql_varchar">,
			RemitInfo4 = <cfqueryparam value="#arguments.RemitInfo4#" cfsqltype="cf_sql_varchar">,
			RemitInfo5 = <cfqueryparam value="#arguments.RemitInfo5#" cfsqltype="cf_sql_varchar">,
			RemitInfo6 = <cfqueryparam value="#arguments.RemitInfo6#" cfsqltype="cf_sql_varchar">,
			contact = <cfqueryparam value="#arguments.contact#" cfsqltype="cf_sql_varchar">,
			LastModifiedDateTime = getdate(),
			LastModifiedBy = <cfqueryparam value="#session.adminusername#" cfsqltype="cf_sql_varchar">
			WHERE companyid = <cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar">
			SELECT @@ROWCOUNT as updatedRows
			SET NOCOUNT OFF
		</cfquery>
		<cfquery name="qrySetCompanyDetails" datasource="#Application.dsn#" result="qResult">
			
			UPDATE SystemConfig
			SET CompanyName = <cfqueryparam value="#arguments.companyName#" cfsqltype="cf_sql_varchar">
		    <cfif arguments.companyLogoName NEQ ''>,
				companyLogoName = <cfqueryparam value="#arguments.companyLogoName#" cfsqltype="cf_sql_varchar">
			</cfif>
			WHERE companyid = <cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar">			
		</cfquery>
		<cfreturn qrySetCompanyInformationUpdate.updatedRows>
	</cffunction>
	<cffunction name="loadBoardFlagStatus" access="public" returntype="query">
		<cfargument name="loadid" required="yes"/>
		<cfquery name="getLoads" datasource="#Application.dsn#">
			select loadnumber from Loads where loadid= <cfqueryparam value="#arguments.loadid#" cfsqltype="cf_sql_varchar">
		</cfquery>
		<cfquery name="LoadboardInsertTOEveryWhereCount" datasource="#Application.dsn#">
			select * from LoadPostEverywhereDetails where imprtref= <cfqueryparam value="#getLoads.loadnumber#" cfsqltype="cf_sql_varchar"> and From_web=<cfqueryparam value="123LoadBoard" cfsqltype="cf_sql_varchar">
		</cfquery>
		<cfreturn LoadboardInsertTOEveryWhereCount>
	</cffunction>

	<cffunction name="rememberSearchSession" access="remote" returnformat="plain" output="false">
		<cfargument name="isChecked" default="true">
		<cfargument name="searchText" default="">
		<cfif arguments.isChecked>
			<cfset session.searchtext = '#arguments.searchText#'>
		<cfelse>
			<cfset session.searchtext = ''>
		</cfif>
		<cfset variables.sessionvalue=session.searchtext>

		<cfreturn variables.sessionvalue>
	</cffunction>

	<!---function to checkEditLoadId Exists--->
	<cffunction name="checkEditLoadIdExists" access="public" returntype="query">
		<cfargument name="loadid" required="yes"/>
		<cfquery name="qryGetUserEditLoad" datasource="#Application.dsn#">
			select user_id from UserEditingLoads
			where loadid=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.loadid#">
		</cfquery>
		<cfif structkeyexists (session,"empid")>
			<cfif Session.empid neq "" >
				<cfset variables.userId=session.empid>
			</cfif>
		</cfif>
		<cfif structkeyexists (session,"customerid")>
			<cfif Session.customerid neq "" >
				<cfset variables.userId=session.customerid>
			</cfif>
		</cfif>
		<cfif qryGetUserEditLoad.user_id eq variables.userId>
			<cfquery name="qryGetUserEditLoadforRefresh" datasource="#Application.dsn#">
				select user_id from UserEditingLoads
				where loadid=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.loadid#">
				AND user_id !=<cfqueryparam cfsqltype="cf_sql_varchar" value="#variables.userId#">
			</cfquery>
			<cfreturn qryGetUserEditLoadforRefresh>
		<cfelse>
			<cfreturn qryGetUserEditLoad>
		</cfif>

	</cffunction>
	<!---function to insert or update UserEditingLoads--->
	<cffunction name="insertUserEditingLoad" access="public" >
		<cfargument name="loadid" required="yes"/>
			<cfif structkeyexists (session,"empid")>
				<cfif Session.empid neq "">
					<cfquery name="qryGetUsername" datasource="#application.dsn#">
						select name from Employees where EmployeeID=<cfqueryparam cfsqltype="cf_sql_varchar" value="#session.empid#">
					</cfquery>
					<cfquery name="qryGetLoadEdit" datasource="#application.dsn#">
						select * from UserEditingLoads
						where
							LoadId=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.loadid#">
						and
							user_id=<cfqueryparam cfsqltype="cf_sql_varchar" value="#session.empid#">
					</cfquery>
					<cfif qryGetLoadEdit.recordcount and qryGetUsername.recordcount>
						<cfquery name="qryUpdateuserEdit" datasource="#Application.dsn#">
							update UserEditingLoads
							set
								DateCreated = <cfqueryparam cfsqltype="cf_sql_timestamp" value="#CreateODBCDateTime(now())#">
							where
								LoadId=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.loadid#">
							and
								user_id=<cfqueryparam cfsqltype="cf_sql_varchar" value="#session.empid#">
						</cfquery>
					<cfelse>
						<cfquery name="qryInsertUserEdit" datasource="#Application.dsn#">
							insert into UserEditingLoads(Username,LoadId,DateCreated,user_id)
								VALUES(
									<cfqueryparam cfsqltype="cf_sql_varchar" value="#qryGetUsername.name#">,
									<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.loadid#">,
									<cfqueryparam cfsqltype="cf_sql_timestamp" value="#CreateODBCDateTime(now())#">,
									<cfqueryparam cfsqltype="cf_sql_varchar" value="#session.empid#">
								)
						</cfquery>
					</cfif>
				</cfif>
			</cfif>
			<cfif structkeyexists (session,"customerid")>
				<cfif Session.customerid neq "">
					<cfquery name="qryGetUsername" datasource="#application.dsn#">
						select CustomerName from Customers where CustomerID=<cfqueryparam cfsqltype="cf_sql_varchar" value="#session.customerid#">
					</cfquery>
					<cfquery name="qryGetLoadEdit" datasource="#application.dsn#">
						select * from UserEditingLoads
						where
							LoadId=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.loadid#">
						and
							user_id=<cfqueryparam cfsqltype="cf_sql_varchar" value="#session.customerid#">
					</cfquery>
					<cfif qryGetLoadEdit.recordcount and qryGetUsername.recordcount>
						<cfquery name="qryUpdateuserEdit" datasource="#Application.dsn#">
							update UserEditingLoads
							set
								DateCreated = <cfqueryparam cfsqltype="cf_sql_timestamp" value="#CreateODBCDateTime(now())#">
							where
								LoadId=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.loadid#">
							and
								user_id=<cfqueryparam cfsqltype="cf_sql_varchar" value="#session.customerid#">
						</cfquery>
					<cfelse>
						<cfquery name="qryInsertUserEdit" datasource="#Application.dsn#">
							insert into UserEditingLoads(Username,LoadId,DateCreated,user_id)
								VALUES(
									<cfqueryparam cfsqltype="cf_sql_varchar" value="#qryGetUsername.CustomerName#">,
									<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.loadid#">,
									<cfqueryparam cfsqltype="cf_sql_timestamp" value="#CreateODBCDateTime(now())#">,
									<cfqueryparam cfsqltype="cf_sql_varchar" value="#session.customerid#">
								)
						</cfquery>
					</cfif>
				</cfif>
			</cfif>
	</cffunction>

	<!---function to checkEditLoadId Exists--->
	<cffunction name="stopInterChanging" access="remote" returntype="any" returnformat="plain">
		<cfargument name="loadid" required="yes" type="string"/>
		<cfargument name="dsn" required="yes" type="string"/>
		<cfargument name="action" required="yes" type="string"/>
		<cfargument name="stopNumber" required="yes" type="numeric"/>
		<cfargument name="CompanyID" required="yes" type="string"/>
		<cfquery name="qryGetLoadStops" datasource="#arguments.dsn#">
			select LoadID,StopNo,Loadtype from loadstops where LoadID=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.loadid#">
			order by StopNo ASC,Loadtype ASC
		</cfquery>
		<cfif qryGetLoadStops.recordcount>
			<cfloop query="qryGetLoadStops">
				<cfquery name="qryGetLoadStopsUpdate" datasource="#arguments.dsn#">
					update  loadstops set
					previous_StopNo=<cfqueryparam cfsqltype="cf_sql_integer" value="#qryGetLoadStops.StopNo#">
					where LoadID=<cfqueryparam cfsqltype="cf_sql_varchar" value="#qryGetLoadStops.loadid#">
					and StopNo=<cfqueryparam cfsqltype="cf_sql_varchar" value="#qryGetLoadStops.StopNo#">
				</cfquery>
			</cfloop>
		</cfif>
		<cftransaction>
			<cfif len(trim(arguments.stopNumber)) and isNumeric(arguments.stopNumber)>
				<cfif arguments.action eq 'down'>
					<cfquery name="qryUpadteLoadStopOnly" datasource="#arguments.dsn#" result="s">
						update  loadstops set
						StopNo=<cfqueryparam cfsqltype="cf_sql_integer" value="#(arguments.stopNumber+1)#">
						where LoadID=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.loadid#">
						and previous_StopNo=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.stopNumber#">
					</cfquery>
					<cfquery name="qryUpdateLoadNextStopOnly" datasource="#arguments.dsn#" result="s">
						update loadstops set
						StopNo=<cfqueryparam cfsqltype="cf_sql_integer" value="#(arguments.stopNumber)#">
						where LoadID=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.loadid#">
						and previous_StopNo=<cfqueryparam cfsqltype="cf_sql_integer" value="#(arguments.stopNumber+1)#">
					</cfquery>
					<cfif arguments.stopNumber EQ 0>
						<cfinvoke method="getSystemSetupOptions" CompanyID="#arguments.CompanyID#" returnvariable="request.qSystemSetupOptions">
						<cfset variables.IsConcatCarrierDriverIdentifier = request.qSystemSetupOptions.IsConcatCarrierDriverIdentifier />
						<cfset variables.freightBroker = request.qSystemSetupOptions.freightBroker />
						<CFSTOREDPROC PROCEDURE="USP_UpdateLoadNumberIdentifierOnStopChange" DATASOURCE="#arguments.dsn#" debug="true">
							<CFPROCPARAM VALUE="#arguments.loadid#" cfsqltype="cf_sql_varchar">
							<CFPROCPARAM VALUE="0" cfsqltype="cf_sql_integer">
							<cfif len(trim(variables.IsConcatCarrierDriverIdentifier)) AND variables.IsConcatCarrierDriverIdentifier EQ 1 AND variables.freightBroker EQ 2>
								<CFPROCPARAM VALUE="1" cfsqltype="cf_sql_bit" >
							<cfelse>
								<CFPROCPARAM VALUE="0" cfsqltype="cf_sql_bit" >
							</cfif>
							<CFPROCRESULT NAME="qUpadteLoadNumberIdentifier">
						</CFSTOREDPROC>
						<cfif qUpadteLoadNumberIdentifier.result EQ 0>
							<cftransaction action="rollback">
							<cfreturn qUpadteLoadNumberIdentifier.LoadNumber>
						</cfif>
					</cfif>
				<cfelseif arguments.action eq 'up'>
					<cfquery name="qryUpadteLoadStopOnly" datasource="#arguments.dsn#" result="s">
						update  loadstops set
						StopNo=<cfqueryparam cfsqltype="cf_sql_integer" value="#(arguments.stopNumber-1)#">
						where LoadID=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.loadid#">
						and previous_StopNo=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.stopNumber#">
					</cfquery>
					<cfquery name="qryUpdateLoadPrevStopOnly" datasource="#arguments.dsn#" result="s">
						update  loadstops set
						StopNo=<cfqueryparam cfsqltype="cf_sql_integer" value="#(arguments.stopNumber)#">
						where LoadID=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.loadid#">
						and previous_StopNo=<cfqueryparam cfsqltype="cf_sql_varchar" value="#(arguments.stopNumber-1)#">
					</cfquery>
					<cfif arguments.stopNumber EQ 1>
						<cfinvoke method="getSystemSetupOptions" CompanyID="#arguments.CompanyID#"  returnvariable="request.qSystemSetupOptions">
						<cfset variables.IsConcatCarrierDriverIdentifier = request.qSystemSetupOptions.IsConcatCarrierDriverIdentifier />
						<cfset variables.freightBroker = request.qSystemSetupOptions.freightBroker />
						<CFSTOREDPROC PROCEDURE="USP_UpdateLoadNumberIdentifierOnStopChange" DATASOURCE="#arguments.dsn#" debug="true">
							<CFPROCPARAM VALUE="#arguments.loadid#" cfsqltype="cf_sql_varchar">
							<CFPROCPARAM VALUE="0" cfsqltype="cf_sql_integer">
							<cfif len(trim(variables.IsConcatCarrierDriverIdentifier)) AND variables.IsConcatCarrierDriverIdentifier EQ 1 AND variables.freightBroker EQ 2>
								<CFPROCPARAM VALUE="1" cfsqltype="cf_sql_bit" >
							<cfelse>
								<CFPROCPARAM VALUE="0" cfsqltype="cf_sql_bit" >
							</cfif>
							<CFPROCRESULT NAME="qUpadteLoadNumberIdentifier">
					   </CFSTOREDPROC>
						<cfif qUpadteLoadNumberIdentifier.result EQ 0>
							<cftransaction action="rollback">
							<cfreturn qUpadteLoadNumberIdentifier.LoadNumber>
						</cfif>
					</cfif>
				</cfif>
			</cfif>
		</cftransaction>
		<cfreturn 1 >
	</cffunction>
		<!---function to get advance paymentdetails--->
	<cffunction name="getAdvancepaymentDetails" access="public" returntype="query">
		<cfargument name="loadid" required="yes" type="string"/>
		<cfquery name="qryGetSalesRepCommissionCarrierPay" datasource="#application.dsn#" >
			select * from vwSalesRepCommissionCarrierPay where loadid=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.loadid#">
		</cfquery>
		<cfreturn qryGetSalesRepCommissionCarrierPay>
	</cffunction>

	<cffunction name="updateLoadUserDef" access="remote" returntype="any">
		<cfargument name="loadid" required="yes" type="string"/>
		<cfargument name="loadstopid" required="yes" type="string"/>
		<cfargument name="fieldname" required="yes" type="string"/>
		<cfargument name="fieldValue" required="yes" type="string"/>
		<cfargument name="dsn" type="string" required="yes" />

		<cftry>
			<cfset local.returnValue = false>

			<cfquery name="qUpdateLoadUserDef" datasource="#arguments.dsn#" result="qUpdateLoadUserDefResult">
				UPDATE LoadStops
				SET #arguments.fieldname# = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.fieldValue#">
				where loadId = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.loadid#">
				and LoadStopID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.loadstopid#">
			</cfquery>
			<cfif qUpdateLoadUserDefResult.recordcount>
				<cfset local.returnValue = true>
			</cfif>
			<cfreturn local.returnValue>
			<cfcatch>
				<cfreturn false>
			</cfcatch>
		</cftry>
	</cffunction>

	<cffunction name="updateLoadDispatchNote" access="remote" returntype="any">
		<cfargument name="loadid" required="yes" type="string"/>
		<cfargument name="dispatchNote" required="yes" type="string"/>
		<cfargument name="dsn" type="string" required="yes" />
		<cfset local.returnValue = false>

		<cftry>
			<cfquery name="qUpdateLoadDispatchNote" datasource="#arguments.dsn#">
				UPDATE LOADS
				SET NEWDISPATCHNOTES = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.dispatchNote#">
				WHERE loadId = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.loadid#">
			</cfquery>
			<cfset local.returnValue = true>

			<cfcatch>
				<cfset local.returnValue = false>
			</cfcatch>
		</cftry>

		<cfreturn local.returnValue>
	</cffunction>

	<!---function to update the userid for corresponding loads--->
	<cffunction name="updateEditingUserId" access="public" returntype="void">
		<cfargument name="userid" type="string" required="yes"/>
		<cfargument name="loadid" type="string" required="yes"/>
		<cfargument name="status" type="boolean" required="yes"/>
		<cfif  arguments.status>
			<!---Query to update the userid for corresponding loads to null--->
			<cfinvoke method="updLoadEditingUserSession" dsn="#Application.dsn#" InUseBy="#arguments.userid#">
		<cfelse>
			<!---Query to update the userid for corresponding loads--->
			<cfquery name="qryUpdateEditingUserId" datasource="#Application.dsn#" result="result">
				UPDATE Loads
				SET
				InUseBy=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.userid#">,
				InUseOn=<cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">,
				sessionid=<cfqueryparam cfsqltype="cf_sql_varchar" value="#session.sessionid#">
				where loadid=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.loadid#">
			</cfquery>
		</cfif>
	</cffunction>
	<!---function to get the user editing details for corresponding loads--->
	<cffunction name="getUserEditingDetails" access="public" returntype="query">
		<cfargument name="loadid" type="string" required="yes"/>
		<!---Query to get the user editing details for corresponding loads--->
		<cftry>
			<cfquery name="qryUpdateEditingUserId" datasource="#Application.dsn#">
				select  InUseBy,InUseOn from loads
				where loadid=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.loadid#">
			</cfquery>
			<cfreturn qryUpdateEditingUserId>
			<cfcatch>
				 <cfset qryUpdateEditingUserId = queryNew("InUseBy,InUseOn","Varchar,Varchar", {InUseBy="",InUseOn=""})>
				<cfreturn qryUpdateEditingUserId>
			</cfcatch>
		</cftry>
	</cffunction>
	<!---function to update the userid for corresponding loads--->
	<cffunction name="removeUserAccessOnLoad" access="remote" returntype="struct" returnformat="json">
		<cfargument name="dsn" type="string" required="yes"/>
		<cfargument name="loadid" type="string" required="yes"/>
		<cfargument name="unlockedEmpID" type="string" required="yes"/>
			<cfif structkeyexists(arguments,"dsn") AND not len(trim(arguments.dsn))>
				<cfset arguments.dsn = trim(listFirst(cgi.SCRIPT_NAME,'/'))>
			</cfif>
			<cfset var loads=StructNew()>
			<!---Query to get the userid--->
			<cfquery name="qryGetUserId" datasource="#arguments.dsn#" result="result">
				select InUseBy,InUseOn,loadnumber from LoadS where loadid=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.loadid#">
			</cfquery>
			<!---Query to get editing User Name--->
			<cfquery name="qryGetUserName" datasource="#arguments.dsn#" <!--- result="result" --->>
				SELECT NAME
				FROM employees
				WHERE employeeID = 
				<cfif NOT len(trim(qryGetUserId.inuseby))>
                    <cfqueryparam value="#qryGetUserId.inuseby#" cfsqltype="cf_sql_varchar"  null="yes" />
                <cfelse>
                    <cfqueryparam value="#qryGetUserId.inuseby#" cfsqltype="cf_sql_varchar" />
                </cfif>
			</cfquery>
			<cfset loads.userName=qryGetUserName.NAME>
			<cfset loads.loadnumber=qryGetUserId.loadnumber>
			<cfset loads.onDateTime=dateformat(qryGetUserId.InUseOn,"mm/dd/yy hh:mm:ss")>
			<cfset loads.dsn=arguments.dsn>
			<!---Query to update the userid for corresponding loads to null--->
			<cfquery name="qryUpdateEditingUserId" datasource="#arguments.dsn#" <!--- result="result" --->>
				UPDATE LoadS
				SET
				InUseBy=null,
				InUseOn=null
				where loadid=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.loadid#">
			</cfquery>

			<cfquery name="qryGetUnlockedUserName" datasource="#arguments.dsn#" <!--- result="result" --->>
				SELECT NAME
				FROM employees
				WHERE employeeID = <cfqueryparam value="#arguments.unlockedEmpID#" cfsqltype="cf_sql_varchar">
			</cfquery>

			<cfquery name="qryCreateUnlockedLog" datasource="#arguments.dsn#" >
				INSERT INTO LoadLogs (LoadID,LoadNumber,FieldLabel,UpdatedByUserID,UpdatedBy,UnlockedFromUserID,UnlockedFrom,UpdatedTimestamp)
				VALUES(
					<cfqueryparam value="#arguments.loadid#" cfsqltype="cf_sql_nvarchar">,
					<cfqueryparam value="#loads.loadnumber#" cfsqltype="cf_sql_integer">,
					<cfqueryparam value="LOAD UNLOCKED" cfsqltype="cf_sql_nvarchar">,
					<cfqueryparam value="#arguments.unlockedEmpID#" cfsqltype="cf_sql_nvarchar">,
					<cfqueryparam value="#qryGetUnlockedUserName.NAME#" cfsqltype="cf_sql_nvarchar">,
					<cfqueryparam value="#qryGetUserId.inuseby#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#qryGetUserName.NAME#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#Now()#" cfsqltype="cf_sql_timestamp">
					)
			</cfquery>
			<cfreturn loads>
	</cffunction>

	<!--- GetChangedCarriers--->
	<cffunction name="CheckCarrierUpdate" access="public"  returntype="any" >
		<cfquery name="qSystemSetupOptions" datasource="#Application.dsn#">
	    	SELECT SaferWatch,SaferWatchWebKey,SaferWatchCustomerKey,SaferWatchUpdateCarrierInfo,SaferWatchCarrierUpdatedDate
			FROM SystemConfig WHERE CompanyID = <cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar">
	    </cfquery>
		<cfif qSystemSetupOptions.SaferWatch EQ 1 AND   qSystemSetupOptions.SaferWatchUpdateCarrierInfo EQ  1 AND  qSystemSetupOptions.SaferWatchCarrierUpdatedDate NEQ Dateformat(now()-1,'yyyy-mm-dd')>
			<cfreturn 1 >
		<cfelse>
			<cfreturn 0 >
		</cfif>
	</cffunction>

	<cffunction name="GetChangedCarriers" access="remote"  returntype="any" returnformat="plain">
		<cfargument name="dsn" type="string" required="yes"/>
		<cfargument name="adminUserName" type="string" required="yes"/>
		<cfargument name="CompanyID" type="string" required="yes"/>
		<cfset msg =  "Successfully Updated the carrier details.">
		<cfset risk_assessment = "">
		<cfset SaferWatchTimeout = 30>
		<cfquery name="qSystemSetupOptions" datasource="#arguments.dsn#">
	    	SELECT SaferWatch,SaferWatchWebKey,SaferWatchCustomerKey,SaferWatchUpdateCarrierInfo,SaferWatchCarrierUpdatedDate
			FROM SystemConfig WHERE CompanyID = <cfqueryparam value="#arguments.CompanyID#" cfsqltype="cf_sql_varchar">
	    </cfquery>
		<cfquery name="qrygetCarrierUpdateDate" datasource="#arguments.dsn#">
				SELECT SaferWatchCarrierUpdatedDate FROM SystemConfig WHERE CompanyID = <cfqueryparam value="#arguments.CompanyID#" cfsqltype="cf_sql_varchar">
			</cfquery>
		<cfif qSystemSetupOptions.SaferWatch EQ 1 AND  qSystemSetupOptions.SaferWatchUpdateCarrierInfo EQ  1 AND qSystemSetupOptions.SaferWatchCarrierUpdatedDate NEQ Dateformat(now()-1,'yyyy-mm-dd')>
			<cftry>
				<cfquery name="qryupdateCarrierUpdateDate" datasource="#arguments.dsn#">
					UPDATE SystemConfig SET SaferWatchCarrierUpdatedDate = '#Dateformat(now()-1,'yyyy-mm-dd')#' WHERE CompanyID = <cfqueryparam value="#arguments.CompanyID#" cfsqltype="cf_sql_varchar">
				</cfquery>
				<cfset datediffindays = DateDiff("d", Dateformat(qSystemSetupOptions.SaferWatchCarrierUpdatedDate,'yyyy-mm-dd'), Dateformat(now(),'yyyy-mm-dd'))>
				<cfif datediffindays LTE 5>
					<cfset frmDate = Dateformat(qSystemSetupOptions.SaferWatchCarrierUpdatedDate,'yyyy-mm-dd') >
				<cfelse>
					<cfset frmDate = Dateformat(DateAdd("d",now(),-5 ),'yyyy-mm-dd') >
				</cfif> 
				<cfhttp url="http://www.saferwatch.com/webservices/CarrierService32.php?Action=GetChangedCarriers&ServiceKey=#qSystemSetupOptions.SaferWatchWebKey#&CustomerKey=#qSystemSetupOptions.SaferWatchCustomerKey#&pageIndex=BEGIN&fromDate=#frmDate#&fromTime=00:00:00&toDate=#Dateformat(now()-1,'yyyy-mm-dd')#&toTime=00:00:00" method="get"  TIMEOUT="#trim(SaferWatchTimeout)#" throwonerror = Yes>
				</cfhttp>
				<cfif cfhttp.Statuscode EQ '200 OK'>
					<cfset variables.resStruct = ConvertXmlToStruct(cfhttp.Filecontent, StructNew())>
					<cfif StructKeyExists(variables.resStruct,"CarrierList") AND IsStruct(variables.resStruct.CarrierList)>		
						<cfloop from="1" to="#ArrayLen(variables.resStruct.CarrierList.CarrierDetails)#" index="i">
								<cfif len(variables.resStruct.CarrierList.CarrierDetails[i].docketNumber) GT 0 >
									<cfset McNumber = right(variables.resStruct.CarrierList.CarrierDetails[i].docketNumber,len(variables.resStruct.CarrierList.CarrierDetails[i].docketNumber)-2)>
									<cfset dotNumber = variables.resStruct.CarrierList.CarrierDetails[i].dotNumber>
									<cfquery name="qrygetFilterCarriers" datasource="#arguments.dsn#">
										SELECT MCNumber,DOTNumber,car.CarrierID
										FROM Carriers car
											LEFT  JOIN lipublicfmcsa li 	ON car.CarrierID=li.carrierId
										WHERE  car.MCNumber=<cfqueryparam value="#McNumber#" cfsqltype="cf_sql_varchar">
										AND  car.DOTNumber= <cfqueryparam value="#dotNumber#" cfsqltype="cf_sql_varchar">
										AND CompanyID = <cfqueryparam value="#arguments.CompanyID#" cfsqltype="cf_sql_varchar">
									</cfquery>

									<cfif valueList(qrygetFilterCarriers.CarrierID) NEQ "">
										<cfquery name="qryupdate" datasource="#arguments.dsn#">
													UPDATE Carriers
													SET
													CarrierName=<cfqueryparam cfsqltype="cf_sql_varchar" value="#variables.resStruct.CarrierList.CarrierDetails[i].Identity.legalName#">,
													Address=<cfqueryparam cfsqltype="cf_sql_varchar" value="#variables.resStruct.CarrierList.CarrierDetails[i].Identity.businessStreet#">,
													StateCode = <cfqueryparam cfsqltype="cf_sql_varchar" value="#variables.resStruct.CarrierList.CarrierDetails[i].Identity.businessState#">,
													Zipcode=   <cfqueryparam cfsqltype="cf_sql_varchar" value="#variables.resStruct.CarrierList.CarrierDetails[i].Identity.businessZipCode#">,
													country	=   <cfqueryparam cfsqltype="cf_sql_varchar" value="#variables.resStruct.CarrierList.CarrierDetails[i].Identity.businessCountry#">,
													LastModifiedBy= <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.adminUserName#">,
													LastModifiedDateTime=<cfqueryparam cfsqltype="cf_sql_date" value="#Now()#">,
													City= <cfqueryparam cfsqltype="cf_sql_varchar" value="#variables.resStruct.CarrierList.CarrierDetails[i].Identity.businessCity#">,
													Phone=  <cfqueryparam cfsqltype="cf_sql_varchar" value="#variables.resStruct.CarrierList.CarrierDetails[i].Identity.businessPhone#">,
													Fax=  <cfqueryparam cfsqltype="cf_sql_varchar" value="#variables.resStruct.CarrierList.CarrierDetails[i].Identity.businessFax#">,
													Cel=  <cfqueryparam cfsqltype="cf_sql_varchar" value="#variables.resStruct.CarrierList.CarrierDetails[i].Identity.cellPhone#">,
													EmailID=  <cfqueryparam cfsqltype="cf_sql_varchar" value="#variables.resStruct.CarrierList.CarrierDetails[i].Identity.emailAddress#">,
													DOTNumber=<cfqueryparam cfsqltype="cf_sql_varchar" value="#dotNumber#">
													,MCNumber = <cfqueryparam cfsqltype="cf_sql_varchar" value="#McNumber#">
													,RiskAssessment =  <cfqueryparam cfsqltype="cf_sql_varchar" value="#variables.resStruct.CarrierList.CarrierDetails[i].RiskAssessment.Overall#">
													,SaferWatch = 1
													WHERE  CarrierID IN (<cfqueryparam cfsqltype="cf_sql_varchar" list="yes"  value="#valueList(qrygetFilterCarriers.CarrierID)#">)
										</cfquery>
									</cfif>
								</cfif>
							</cfloop>
								<cfhttp url="http://www.saferwatch.com/webservices/CarrierService32.php?Action=AddChangedCarriers&ServiceKey=#qSystemSetupOptions.SaferWatchWebKey#&CustomerKey=#qSystemSetupOptions.SaferWatchCustomerKey#&pageIndex=BEGIN&fromDate=#Dateformat(now()-3,'yyyy-mm-dd')#&fromTime=00:00:00&toDate=#Dateformat(now()-1,'yyyy-mm-dd')#&toTime=00:00:00" method="get" >
								</cfhttp>
								<cfquery name="qrygetCarrierUpdateDate" datasource="#arguments.dsn#">
										SELECT SaferWatchCarrierUpdatedDate FROM SystemConfig WHERE CompanyID = <cfqueryparam value="#arguments.CompanyID#" cfsqltype="cf_sql_varchar">
									</cfquery>
							<cfset msg = '<p style="font-weight:normal !important;font-size:13px !important;color: black !important;">Changed carriers details updated successfully.</p><br>
												<p style="font-weight:normal !important;font-size:13px !important;color: black !important;">Carrier deatils Update Upto <b style="font-weight:normal !important;font-size:13px !important;color: black !important;">#DateFormat(qrygetCarrierUpdateDate.SaferWatchCarrierUpdatedDate,'mm/dd/yyyy')# </b></p><br><br>'>
					<cfelseif structKeyExists(variables.resStruct,"ResponseDO") AND variables.resStruct.ResponseDO.displayMsg NEQ "">
						<cfquery name="qryupdateCarrierUpdateDate" datasource="#arguments.dsn#">
							UPDATE SystemConfig SET SaferWatchCarrierUpdatedDate = <cfqueryparam value="#qrygetCarrierUpdateDate.SaferWatchCarrierUpdatedDate#" cfsqltype="cf_sql_date">
						</cfquery>
						<cfreturn variables.resStruct.ResponseDO.displayMsg>
					</cfif>
				<cfelse>
					<cfquery name="qrygetCarrierUpdateDate" datasource="#arguments.dsn#">
						SELECT SaferWatchCarrierUpdatedDate FROM SystemConfig WHERE CompanyID = <cfqueryparam value="#arguments.CompanyID#" cfsqltype="cf_sql_varchar">
					</cfquery>
					<cfset msg =  '<p style="font-weight:normal !important;font-size:13px !important;color: black !important;">Your Carrier details Updated Successfully.</p><br>
												<p style="font-weight:normal !important;font-size:13px !important;color: black !important;">Carrier deatils Update Upto <b>#DateFormat(qrygetCarrierUpdateDate.SaferWatchCarrierUpdatedDate,'mm/dd/yyyy')# </b></p><br><br>
											'>
				</cfif>
			<cfcatch type="coldfusion.runtime.RequestTimedOutException">
				<cfquery name="qryupdateCarrierUpdateDate" datasource="#arguments.dsn#" timeout ="25">
					UPDATE SystemConfig SET SaferWatchCarrierUpdatedDate = <cfqueryparam value="#qrygetCarrierUpdateDate.SaferWatchCarrierUpdatedDate#" cfsqltype="cf_sql_date"> WHERE CompanyID = <cfqueryparam value="#arguments.CompanyID#" cfsqltype="cf_sql_varchar">
				</cfquery> 
				<cfreturn    "SaferWatch API takes too long to respond.">
			</cfcatch>
			<cfcatch>
				<cfquery name="qryupdateCarrierUpdateDate" datasource="#arguments.dsn#" timeout ="25">
					UPDATE SystemConfig SET SaferWatchCarrierUpdatedDate = <cfqueryparam value="#qrygetCarrierUpdateDate.SaferWatchCarrierUpdatedDate#" cfsqltype="cf_sql_date"> WHERE CompanyID = <cfqueryparam value="#arguments.CompanyID#" cfsqltype="cf_sql_varchar">
				</cfquery>
				<cfset msg =  "Cannot Update changed carriers details."&cfcatch>
			</cfcatch>
			</cftry>
		</cfif>
		<cfif qSystemSetupOptions.SaferWatch EQ 1 >
			<cfquery name="qryCarrier" datasource="#arguments.dsn#">
				SELECT *  FROM   Carriers WHERE CompanyID = <cfqueryparam value="#arguments.CompanyID#" cfsqltype="cf_sql_varchar">
			</cfquery>
			<cfloop query="qryCarrier">
				<cfif qryCarrier.RiskAssessment EQ "">
					<cfhttp url="http://www.saferwatch.com/webservices/CarrierService32.php?Action=CarrierLookup&ServiceKey=#qSystemSetupOptions.SaferWatchWebKey#&CustomerKey=#qSystemSetupOptions.SaferWatchCustomerKey#&number=MC#qryCarrier.MCNumber#" method="get" >
					</cfhttp>
					<cfif cfhttp.Statuscode EQ '200 OK'>
						<cfset variables.resStruct = ConvertXmlToStruct(cfhttp.Filecontent, StructNew())>
						<cfif structKeyExists(variables.resStruct ,"CarrierDetails") AND variables.resStruct.CarrierDetails.dotNumber EQ  qryCarrier.DOTNumber AND variables.resStruct.CarrierDetails.docketNumber EQ "MC"&qryCarrier.MCNumber AND structKeyExists(variables.resStruct .CarrierDetails,"RiskAssessment") AND structKeyExists(variables.resStruct .CarrierDetails.RiskAssessment,"Overall")  >
							<cfset risk_assessment = variables.resStruct .CarrierDetails.RiskAssessment.Overall>
						</cfif>
					</cfif>
					<cfquery name="qryupdate" datasource="#arguments.dsn#">
							UPDATE Carriers
							SET RiskAssessment = <cfqueryparam value="#risk_assessment#" cfsqltype="cf_sql_varchar">
							WHERE  CarrierID=<cfqueryparam value="#qryCarrier.carrierID#" cfsqltype="cf_sql_varchar">
					</cfquery>
				</cfif>
			</cfloop>
		</cfif>
		<cfreturn msg >
	</cffunction>

	<cffunction name="ConvertXmlToStruct" access="public" returntype="struct" output="true"  hint="Parse raw XML response body into ColdFusion structs and arrays and return it.">
		<cfargument name="xmlNode" type="string" required="true" />
		<cfargument name="str" type="struct" required="true" />
		<cfset var i 							= 0 />
		<cfset var axml						= arguments.xmlNode />
		<cfset var astr						= arguments.str />
		<cfset var n 							= "" />
		<cfset var tmpContainer 	= "" />

		<cftry>
			<cfset axml = XmlSearch(XmlParse(arguments.xmlNode),"/node()")>
			<cfcatch>
				<cfdocument format="pdf" filename="C:\pdf\ConvertXmlToStructDebug_#DateTimeFormat(now(),"YYYY_MM_dd_HH_nn_ss_l")#.pdf" overwrite="true">
					<cfdump var="#arguments#">
					<cfdump var="#cfcatch#">
				</cfdocument>
			</cfcatch>
		</cftry>
		<cfset axml = axml[1] />

		<cfloop from="1" to="#arrayLen(axml.XmlChildren)#" index="i">
			<cfset n = replace(axml.XmlChildren[i].XmlName, axml.XmlChildren[i].XmlNsPrefix&":", "") />
			<cfif structKeyExists(astr, n)>
				<cfif not isArray(astr[n])>
					<cfset tmpContainer = astr[n] />
					<cfset astr[n] = arrayNew(1) />
					<cfset astr[n][1] = tmpContainer />
				<cfelse>
				</cfif>

				<cfif arrayLen(axml.XmlChildren[i].XmlChildren) gt 0>
						<cfset astr[n][arrayLen(astr[n])+1] = ConvertXmlToStruct(axml.XmlChildren[i], structNew()) />
				<cfelse>
						<cfset astr[n][arrayLen(astr[n])+1] = axml.XmlChildren[i].XmlText />
				</cfif>
			<cfelse>
				<cfif arrayLen(axml.XmlChildren[i].XmlChildren) gt 0>
					<cfset astr[n] = ConvertXmlToStruct(axml.XmlChildren[i], structNew()) />
				<cfelse>
					<cfif IsStruct(aXml.XmlAttributes) AND StructCount(aXml.XmlAttributes)>
						<cfset at_list = StructKeyList(aXml.XmlAttributes)>
						<cfloop from="1" to="#listLen(at_list)#" index="atr">
							 <cfif ListgetAt(at_list,atr) CONTAINS "xmlns:">
								<cfset Structdelete(axml.XmlAttributes, listgetAt(at_list,atr))>
							 </cfif>
						 </cfloop>
						 <cfif StructCount(axml.XmlAttributes) GT 0>
							 <cfset astr['_attributes'] = axml.XmlAttributes />
						</cfif>
					</cfif>
					<cfif IsStruct(aXml.XmlChildren[i].XmlAttributes) AND StructCount(aXml.XmlChildren[i].XmlAttributes) GT 0>
						<cfset astr[n] = axml.XmlChildren[i].XmlText />
						 <cfset attrib_list = StructKeylist(axml.XmlChildren[i].XmlAttributes) />
						 <cfloop from="1" to="#listLen(attrib_list)#" index="attrib">
							 <cfif ListgetAt(attrib_list,attrib) CONTAINS "xmlns:">
								<cfset Structdelete(axml.XmlChildren[i].XmlAttributes, listgetAt(attrib_list,attrib))>
							 </cfif>
						 </cfloop>
						 <cfif StructCount(axml.XmlChildren[i].XmlAttributes) GT 0>
							 <cfset astr[n&'_attributes'] = axml.XmlChildren[i].XmlAttributes />
						</cfif>
					<cfelse>
						 <cfset astr[n] = axml.XmlChildren[i].XmlText />
					</cfif>
				</cfif>
			</cfif>
		</cfloop>
		<cfreturn astr />
	</cffunction>

	<cffunction name="UpdateCarrier" access="public" output="false" returntype="any">
		<cfargument name="formStruct" type="struct" required="yes">
		<cfquery name="qSystemSetupOptions" datasource="#Application.dsn#">
			SELECT SaferWatch,SaferWatchWebKey,SaferWatchCustomerKey,FreightBroker,SaferWatchUpdateCarrierInfo
			FROM SystemConfig WHERE CompanyID = <cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar">
	</cfquery>
		<cfif trim(arguments.formStruct.carrierID) NEQ ""  AND qSystemSetupOptions.SaferWatch EQ 1 AND qSystemSetupOptions.FreightBroker  EQ 1 AND SaferWatchUpdateCarrierInfo EQ 1>
			<cfquery name="qrygetFilterCarriers" datasource="#Application.dsn#">
				SELECT MCNumber,DOTNumber
				FROM Carriers car
					LEFT  JOIN lipublicfmcsa li 	ON car.CarrierID=li.carrierId
				WHERE  car.CarrierID=<cfqueryparam value="#arguments.formStruct.carrierID#" cfsqltype="cf_sql_varchar">
			</cfquery>
			<cfif  qrygetFilterCarriers.DOTNumber NEQ "">
				 <cfset number = qrygetFilterCarriers.DOTNumber>
			<cfelseif  qrygetFilterCarriers.MCNumber NEQ ""  >
				<cfset number = "MC"&qrygetFilterCarriers.MCNumber >
			<cfelse>
				<cfset number = 0 >
			</cfif>
			<cfhttp url="http://www.saferwatch.com/webservices/CarrierService32.php?Action=CarrierLookup&ServiceKey=#qSystemSetupOptions.SaferWatchWebKey#&CustomerKey=#qSystemSetupOptions.SaferWatchCustomerKey#&number=#variables.number#" method="get" >
			</cfhttp>

			<cfif cfhttp.Statuscode EQ '200 OK'>
				<cfset variables.responsestatus = structNew()>
				<cfset variables.responsestatus = ConvertXmlToStruct(cfhttp.Filecontent, StructNew()) >
				<cfif  variables.responsestatus.ResponseDO.action EQ "OK" AND structKeyExists(variables.responsestatus,"CarrierDetails")>
					<cfquery name="qryupdate" datasource="#Application.dsn#">
								UPDATE Carriers
								SET
								CarrierName=<cfqueryparam cfsqltype="cf_sql_varchar" value="#variables.responsestatus.CarrierDetails.Identity.legalName#">,
								Address=<cfqueryparam cfsqltype="cf_sql_varchar" value="#variables.responsestatus.CarrierDetails.Identity.businessStreet#">,
								StateCode = <cfqueryparam cfsqltype="cf_sql_varchar" value="#variables.responsestatus.CarrierDetails.Identity.businessState#">,
								Zipcode=   <cfqueryparam cfsqltype="cf_sql_varchar" value="#variables.responsestatus.CarrierDetails.Identity.businessZipCode#">,
								LastModifiedBy= <cfqueryparam cfsqltype="cf_sql_varchar" value="#session.adminUserName#">,
								LastModifiedDateTime=<cfqueryparam cfsqltype="cf_sql_date" value="#Now()#">,
								City= <cfqueryparam cfsqltype="cf_sql_varchar" value="#variables.responsestatus.CarrierDetails.Identity.businessCity#">,
								Phone=  <cfqueryparam cfsqltype="cf_sql_varchar" value="#variables.responsestatus.CarrierDetails.Identity.businessPhone#">,
								Fax=  <cfqueryparam cfsqltype="cf_sql_varchar" value="#variables.responsestatus.CarrierDetails.Identity.businessFax#">,
								Cel=  <cfqueryparam cfsqltype="cf_sql_varchar" value="#variables.responsestatus.CarrierDetails.Identity.cellPhone#">,
								EmailID=  <cfqueryparam cfsqltype="cf_sql_varchar" value="#variables.responsestatus.CarrierDetails.Identity.emailAddress#">,
								DOTNumber=<cfqueryparam cfsqltype="cf_sql_varchar" value="#variables.responsestatus.CarrierDetails.dotNumber #" null="#not len(variables.responsestatus.CarrierDetails.dotNumber )#">
								,MCNumber = <cfqueryparam cfsqltype="cf_sql_varchar" value="#right(variables.responsestatus.CarrierDetails.docketNumber,len(variables.responsestatus.CarrierDetails.docketNumber)-2)#">
								,RiskAssessment =  <cfqueryparam cfsqltype="cf_sql_varchar" value="#variables.responsestatus.CarrierDetails.RiskAssessment.Overall#">
								,SaferWatch = 1
								WHERE  CarrierID=<cfqueryparam value="#arguments.formStruct.carrierID#" cfsqltype="cf_sql_varchar">
					</cfquery>
				</cfif>
			</cfif>
			<cfhttp url="http://www.saferwatch.com/webservices/CarrierService32.php?Action=AddWatch&ServiceKey=#qSystemSetupOptions.SaferWatchWebKey#&CustomerKey=#qSystemSetupOptions.SaferWatchCustomerKey#&number=#variables.number#" method="get" >
			</cfhttp>
		</cfif>
	</cffunction>

	<!--- Dispatc load to driver, am email will send to deiver's smart phone with loadid --->
	<cffunction name="carrierDispatchLoad" access="remote" returntype="any" returnformat="JSON">
		<cfargument name="dsn" type="string" required="yes">
		<cfargument name="loadID" type="string" required="yes">
		<cfargument name="userid" type="string" required="yes">
				
		<cfset lst_DriverDetails = "">		
			<cfquery name="getCurrentUserMailDetails" datasource="#arguments.dsn#">
				SELECT 
					EmailID,SmtpAddress,SmtpUsername,SmtpPort,SmtpPassword,useSSL,useTLS
				FROM Employees
				WHERE EmployeeID = <cfqueryparam value="#arguments.userid#" cfsqltype="cf_sql_varchar">
			</cfquery>
		
		<cfset SmtpAddress		= getCurrentUserMailDetails.SmtpAddress>
		<cfset SmtpUsername	= getCurrentUserMailDetails.SmtpUsername>
		<cfset SmtpPort				= getCurrentUserMailDetails.SmtpPort>
		<cfset SmtpPassword	= getCurrentUserMailDetails.SmtpPassword>
		<cfset FA_SSL					= getCurrentUserMailDetails.useSSL>
		<cfset FA_TLS					= getCurrentUserMailDetails.useTLS>

		<cftry>
			<cfset toMailList = ''>
			<cfset fromMailList = ''>

			<cfquery name="getLoadDetails" datasource="#arguments.dsn#"><!--- Carrier email --->
				SELECT  L.LoadID, L.LoadNumber, C.CarrierName  AS DriverName, L.emailList,
						C.CarrierID, C.EmailID
				FROM Loads L
				INNER JOIN Carriers C ON C.CarrierID = L.CarrierID
				WHERE L.LoadID = <cfqueryparam value="#arguments.loadID#" cfsqltype="cf_sql_varchar">
			</cfquery>

			<cfquery name="getMailDetails" datasource="#arguments.dsn#"> <!--- Shipper & Consignee email--->
				SELECT DISTINCT EmailID 
				FROM LoadStops
				WHERE LoadID = <cfqueryparam value="#arguments.loadID#" cfsqltype="cf_sql_varchar">
				AND (EmailID IS NOT NULL AND LEN(EmailID) > 0 )
			</cfquery>
		

			<cfif getCurrentUserMailDetails.recordCount>
				<cfset fromMailList = valuelist(getCurrentUserMailDetails.EmailID)>
			</cfif>
			<cfif not len(fromMailList)>
				<cfset fromMailList = SmtpUsername>
			</cfif>

			<cfset toMailList = listappend(toMailList, getLoadDetails.EmailID)>
			<cfset toMailList = listappend(toMailList, getLoadDetails.emailList)>

			<cfif len(toMailList)>
				<cfset detail  = getLoadDetails.DriverName&", "&toMailList>
				<cfset lst_DriverDetails = ListAppend(lst_DriverDetails,detail)>
				<cfmail to="#toMailList#" from="#fromMailList#"
						subject="Load Manager - ###getLoadDetails.loadNumber#" type="html"
						server="#SmtpAddress#" username="#SmtpUsername#" password="#SmtpPassword#" port="#SmtpPort#" usessl="#FA_SSL#" usetls="#FA_TLS#"

						>
					<p>Hi #getLoadDetails.DriverName# </p>

					<p>The load ###getLoadDetails.loadNumber# has been dispatched.</p>
					<p>Please go to this link:</p>
					<p>
						https://loadmanager.biz/#arguments.dsn#/mobile/index.cfm?event=login&LoadID=#arguments.loadID#
					</p>
					<!--- Test: #getLoadDetails.EmailID# --->
				</cfmail>
			<cfelse>
				<cfreturn "No Driver/Carrier found.">
			</cfif>
			
			<cfreturn "This Load has been E-Dispatched  to "&lst_DriverDetails>
			<cfcatch type="any">
				<cfreturn "Error Occured.">
			</cfcatch>
		</cftry>
	</cffunction>

	<cffunction name="getLoadLastPosition" access="remote" returntype="struct" returnformat="JSON" >
		<cfargument name="dsn" type="string" required="yes">
		<cfargument name="loadId" type="string" required="yes" >
		<cfargument name="CompanyID" type="string" required="no" default="">
		<!---BEGIN: 761: Smart Phone URL deployment --->
		<cfinvoke method="getSystemSetupOptions" returnvariable="request.qSystemSetupOptions">
			<cfinvokeargument name="dsn" value="#arguments.dsn#">
			<cfinvokeargument name="CompanyID" value="#arguments.CompanyID#">
		</cfinvoke>
		<cfquery name="getUniqueIdFromLoad" datasource="#arguments.dsn#">
			SELECT ISNULL(L.GPSDeviceID,0) AS GPSDeviceID
				FROM Loads L WHERE L.LoadID = <cfqueryparam value="#arguments.loadID#" cfsqltype="cf_sql_varchar">
		</cfquery>
		<cfif getUniqueIdFromLoad.GPSDeviceID NEQ 0>
			<cfset uniqueidList = valuelist(getUniqueIdFromLoad.GPSDeviceID) >
			<cfset GPSDataSource = "ZGPSTrackingMPWeb">
			<cfquery name="getLoadLastPosition" datasource="#GPSDataSource#">
				SELECT TOP 1 P.*, FORMAT(P.servertime , 'MM/dd/yyyy HH:mm:ss') as lastUpdatedDateTime, D.uniqueid, '' AS EquipmentName
				FROM devices D
				INNER JOIN positions P ON D.id = P.deviceid
				WHERE D.uniqueid IN (<cfqueryparam value="#uniqueidList#" cfsqltype="cf_sql_varchar" list="true">)
				ORDER BY P.servertime DESC
			</cfquery>
			<cfif getLoadLastPosition.recordCount gt 0>
				<cfquery name="getEquipment" datasource="#arguments.dsn#">
					SELECT ISNULL(EquipmentName,'-') AS EquipmentName FROM Loads WHERE LoadID = <cfqueryparam value="#arguments.loadID#" cfsqltype="cf_sql_varchar">
				</cfquery>

				<!--- <cfquery name="getLoadPath" datasource="#GPSDataSource#">
					SELECT P.Latitude, P.Longitude, FORMAT(P.servertime , 'MM/dd/yyyy HH:mm:ss') as ServerTime
					FROM Positions P
					WHERE P.DeviceID = <cfqueryparam value="#getLoadLastPosition.DeviceID#" cfsqltype="cf_sql_varchar">
					AND P.ID <> <cfqueryparam value="#getLoadLastPosition.ID#" cfsqltype="cf_sql_varchar">
					GROUP BY P.Latitude, P.Longitude,P.servertime
					ORDER BY P.servertime
				</cfquery>
				<cfset var pathArr = arrayNew(1)>
				<cfloop query="getLoadPath">
					<cfset tempStruct = structNew()>
					<cfset tempStruct['Latitude'] = getLoadPath.Latitude>
					<cfset tempStruct['Longitude'] = getLoadPath.Longitude>
					<cfset tempStruct['ServerTime'] = getLoadPath.ServerTime>
					<cfset arrayAppend(pathArr, tempStruct)>
				</cfloop> --->

				<cfset querysetCell(getLoadLastPosition, "EquipmentName", "#getEquipment.EquipmentName#")>
				<!--- <cfset querysetCell(getLoadLastPosition, "ZPathString", "#serializeJSON(pathArr)#")> --->
			<cfelse>
				<cfset getLoadLastPosition = querynew('id')>
			</cfif>
		<cfelse>
			<cfquery name="getUniqueId" datasource="#arguments.dsn#">
				SELECT DISTINCT EQ.traccarUniqueID, EQ.EquipmentName
				FROM LoadStops LS
				LEFT JOIN Equipments EQ ON EQ.EquipmentID = LS.NewEquipmentID
				WHERE LS.LoadID = <cfqueryparam value="#arguments.loadID#" cfsqltype="cf_sql_varchar">
				AND EQ.traccarUniqueID IS NOT NULL
			</cfquery>
			<cfif getUniqueId.recordCount>
				<cfset uniqueidList = valuelist(getUniqueId.traccarUniqueID) >
				<cfquery name="getLoadLastPosition" datasource="ZGPSTrackingMPWeb">
					SELECT TOP 1 P.*, FORMAT(P.servertime , 'MM/dd/yyyy HH:mm:ss') as lastUpdatedDateTime, D.uniqueid, '' AS EquipmentName
					FROM devices D
					INNER JOIN positions P ON D.id = P.deviceid
					WHERE D.uniqueid IN (<cfqueryparam value="#uniqueidList#" cfsqltype="cf_sql_varchar" list="true">)
					ORDER BY P.servertime DESC
				</cfquery>
				<cfif getLoadLastPosition.recordCount>
					<cfquery name="getCurrentEquipment" dbtype="query">
						SELECT EquipmentName
						FROM getUniqueId
						WHERE traccarUniqueID = <cfqueryparam value="#getLoadLastPosition.uniqueid#" cfsqltype="cf_sql_bigint">
					</cfquery>
					<cfset querysetCell(getLoadLastPosition, "EquipmentName", getCurrentEquipment.EquipmentName)>
				<cfelse>
					<cfset getLoadLastPosition = querynew('id')>
				</cfif>
			<cfelse>
				<cfset getLoadLastPosition = querynew('id')>
			</cfif>
		</cfif>
		<!---END: 761: Smart Phone URL deployment --->
		<cfreturn {res: getLoadLastPosition } >

	</cffunction>

	<cffunction name="getLocationFromLatLong" access="remote" returntype="any">
		<cfargument name="latitude" type="string" required="yes">
		<cfargument name="longitude" type="string" required="yes">

		<cftry>
			<cfquery name="getProMileDetails" datasource="#Application.dsn#">
				select PCMilerUsername,PCMilerPassword,PCMilerCompanyCode from SystemConfig
				where CompanyID = <cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar">
			</cfquery>

			<cfif getProMileDetails.recordcount>
				<cfset variables.Username=getProMileDetails.PCMilerUsername>
				<cfset variables.Password=getProMileDetails.PCMilerPassword>
				<cfset variables.CompanyCode=getProMileDetails.PCMilerCompanyCode>
			</cfif>

			<cfoutput>
				<cfsavecontent variable="myVariable">
					<?xml version="1.0" encoding="utf-8"?>
						<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
							<soap:Body>
								<ReverseGeocode   xmlns="http://promiles.com/">
									<c>
										<Username>#variables.Username#</Username>
										<Password>#variables.Password#</Password>
										<CompanyCode>#variables.CompanyCode#</CompanyCode>
									</c>
									<Latitude>#arguments.latitude#</Latitude>
      								<Longitude>#arguments.longitude#</Longitude>
								</ReverseGeocode >
		  					</soap:Body>
						</soap:Envelope>
				</cfsavecontent>
			</cfoutput>
			
			<cfhttp url="http://prime.promiles.com/Webservices/v1_1/PRIMEStandardV1_1.asmx?op=ReverseGeocode" method="post" result="httpResponse">
				<cfhttpparam type="header" name="Content-Type" value="text/xml; charset=utf-8" />
				<cfhttpparam type="header" name="Content-Length" value="length" />
				<cfhttpparam type="header" name="SOAPAction" value="http://promiles.com/ReverseGeocode" />
				<cfhttpparam type="xml" value="#trim(myVariable)#" />
			</cfhttp>

			<cfif not FindNoCase("Failure",httpResponse.Statuscode)>
				<cfset soapResponse = xmlParse(httpResponse.fileContent) />
				<cfinvoke  method="ConvertXmlToStruct" xmlNode="#soapResponse#" str="#structNew()#" returnvariable="xmlToStruct"/>
				<cfif IsDefined('xmlToStruct.Body.ReverseGeocodeResponse.ReverseGeocodeResult.City') AND IsDefined('xmlToStruct.Body.ReverseGeocodeResponse.ReverseGeocodeResult.State')>
					<cfset response = structNew()>
					<cfset response.city = xmlToStruct.Body.ReverseGeocodeResponse.ReverseGeocodeResult.City>
					<cfset response.state = xmlToStruct.Body.ReverseGeocodeResponse.ReverseGeocodeResult.State>
					<cfreturn response>
				<cfelse>
					<cfset response = structNew()>
					<cfset response.city = ''>
					<cfset response.state = ''>
					<cfreturn response>
				</cfif>
			<cfelse>
				<cfset response = structNew()>
				<cfset response.city = ''>
				<cfset response.state = ''>
				<cfreturn response>
			</cfif>
			<cfcatch>
				<cfset response = structNew()>
				<cfset response.city = ''>
				<cfset response.state = ''>
				<cfreturn response>
			</cfcatch>
		</cftry>
	</cffunction>

	<cffunction name="getTraccarDeviceInfo" access="public" returntype="query" >
		<cfargument name="DeviceID" type="numeric" required="no" >
		<cfargument name="UniqueID" type="string" required="no" >

		<cfquery name="getTraccarDeviceInfo" datasource="ZGPSTracking">
			SELECT  *
			FROM devices
			WHERE
				1 = 1
				<cfif structkeyexists(arguments, 'DeviceID') AND len(trim(arguments.DeviceID)) >
					AND id = <cfqueryparam value="#arguments.DeviceID#" cfsqltype="cf_sql_integer">
				</cfif>
				<cfif structkeyexists(arguments, 'UniqueID') AND len(trim(arguments.UniqueID)) >
					AND UniqueID = <cfqueryparam value="#arguments.UniqueID#" cfsqltype="cf_sql_varchar">
				</cfif>
		</cfquery>

		<cfreturn getTraccarDeviceInfo >

	</cffunction>

	<cffunction name="getMobileAppAccessLog" access="public" returntype="query" >
		<cfargument name="loadid" type="string" required="yes" >

		<cfquery name="getMobileAppAccessLog" datasource="#Application.dsn#">
			SELECT TOP 1 *
			FROM MobileAppAccessLogs
			WHERE LoadID = <cfqueryparam value="#arguments.LoadID#" cfsqltype="cf_sql_varchar">
			ORDER BY CreatedDateTime DESC
		</cfquery>

		<cfreturn getMobileAppAccessLog >

	</cffunction>

	<cffunction name="getCustomerDetails" access="public" returntype="query" >
		<cfargument name="PayerID" type="string" required="yes" >

		<CFSTOREDPROC PROCEDURE="USP_GetCustomerDetails" DATASOURCE="#dsn#">
			<cfif isdefined('arguments.PayerID') and len(arguments.PayerID)>
				<CFPROCPARAM VALUE="#arguments.PayerID#" cfsqltype="CF_SQL_VARCHAR">
			<cfelse>
				<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR">
			</cfif>
			<CFPROCRESULT NAME="qCustomer">
		</CFSTOREDPROC>

		<cfreturn qCustomer>
	</cffunction>

	<cffunction name="getSalesPersonDetails" access="public" returntype="any">
		<cfargument name="DispatcherID" default="" type="string" />

		<cfquery name="qrygetsalesPerson" datasource="#variables.dsn#">
			SELECT * FROM Employees
			WHERE EmployeeID = <cfqueryparam value="#arguments.DispatcherID#" cfsqltype="cf_sql_varchar" null="#yesnoformat(not len(arguments.DispatcherID))#">
		</cfquery>

		<cfreturn qrygetsalesPerson>
	</cffunction>

	<cffunction name="getLoadStopDetails" access="public" returntype="any">
		<cfargument name="loadID" required="yes" type="any">
		<cfargument name="LoadStopID" required="NO" type="any" default="">
	    <cfargument name="StopNo" required="no" type="any" default="">
		<cfargument name="LoadType" required="no" type="any" default="">

		<cftry>
			 <cfquery name="qGetLoadStopInfo" datasource="#variables.dsn#">
		    	SELECT LS.*, EQ.*
				FROM LoadStops LS
				LEFT JOIN Equipments EQ ON EQ.EquipmentID = LS.NewEquipmentID
				WHERE
				 	1 = 1
					AND LS.loadID = <cfqueryparam value="#arguments.loadID#" cfsqltype="cf_sql_varchar">
					<cfif structkeyexists(arguments, "LoadStopID") AND len(trim(arguments.LoadStopID)) >
						AND LS.LoadStopID = <cfqueryparam value="#LoadStopID#" cfsqltype="cf_sql_varchar">
					</cfif>
					<cfif structkeyexists(arguments, "StopNo") and len(trim(arguments.StopNo)) >
						AND LS.StopNo = <cfqueryparam value="#arguments.StopNo#" cfsqltype="cf_sql_integer">
					</cfif>
					<cfif structkeyexists(arguments, "LoadType") AND arguments.LoadType GT 0 >
						AND LS.LoadType = <cfqueryparam value="#arguments.LoadType#" cfsqltype="cf_sql_tinyint">
					</cfif>
				ORDER BY LS.loadID, LS.StopNo, LS.LoadType
			 </cfquery>

			<cfcatch>
				<cfset qGetLoadStopInfo.recordcount = 0>
			</cfcatch>
		 </cftry>

		<cfreturn qGetLoadStopInfo>

	</cffunction>

	<cffunction name="updateLoadDispatchEmail" access="remote" returntype="any">
		<cfargument name="loadid" required="yes" type="string"/>
		<cfargument name="emailList" required="yes" type="string"/>
		<cfargument name="dsn" type="string" required="yes" />

		<cfset local.returnValue = false>

		<cftry>
			<cfquery name="qUpdateLoadDispatchEmail" datasource="#arguments.dsn#">
				UPDATE LOADS
				SET emailList = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.emailList#" null="#yesnoformat(not len(arguments.emailList))#">
				WHERE loadId = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.loadid#">
			</cfquery>
			<cfset local.returnValue = true>

			<cfcatch>
				<cfset local.returnValue = false>
			</cfcatch>
		</cftry>

		<cfreturn local.returnValue>

	</cffunction>

	<cffunction name="updateDispatchNotes" access="public" returntype="any">
		<cfargument name="LoadID" required="yes" type="string">
		<cfargument name="Notes" required="yes" type="string">
		<cfquery name="qupdateDispatchNotes" datasource="#variables.dsn#">
	    	UPDATE loads
	    	SET NewDispatchNotes = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.Notes#">+CHAR(13)+NewDispatchNotes
	    	WHERE LoadID =<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.loadid#">
	    </cfquery>
	    <cfreturn 1>
	</cffunction>

	<cffunction name="CopyLoadToMultiple" access="public" returntype="any">
		<cfargument name="LoadId" required="yes" >
		<cfargument name="NoOfCopies" required="yes" >
		<cfinvoke method="getSystemSetupOptions" returnvariable="request.qSystemSetupOptions">
		
		<cfset var EditLoadID = arguments.loadid >
		<cfset var loadDetails = "">
		<cfset var NoOfCopiesNeeded = arguments.NoOfCopies >
		<cfset var lstLoadNumber = "">
		<cfif NOT IsNumeric(NoOfCopiesNeeded)>
			<cfset NoOfCopiesNeeded = 0>
			<cfsavecontent variable="loadDetails">
				<cfoutput>
				<h3 style='color:##31a047;'>Load Not Copied.</h3></p>
				</cfoutput>
			</cfsavecontent>
			<cfreturn loadDetails>
		</cfif>

		<cfquery name="qOrgLoadDetails" datasource="#variables.dsn#">
			SELECT LST.StatusText,LST.StatusTypeID,L.RateApprovalNeeded,L.LoadNumber,L.CarrierID FROM Loads L
			INNER JOIN LoadStatusTypes LST ON L.StatusTypeID = lst.StatusTypeID
			WHERE L.LoadID = <cfqueryparam value="#arguments.LoadID#" cfsqltype="cf_sql_varchar">
		</cfquery>

		<cfset var i = 1>
		<cfloop from="1" to="#NoOfCopiesNeeded#" index="i">
			<cfset var qmaxinvoiceNumber = queryNew("")>
			<cfset var qinsetLoad = queryNew("")>
			<cfset var loadNumber="">
			<!--- Begin : Get Load Number --->
			<CFSTOREDPROC PROCEDURE="spGenerateLoadNumber" DATASOURCE="#variables.dsn#">
			 	<CFPROCPARAM VALUE="#session.CompanyID#" cfsqltype="CF_SQL_VARCHAR">
			 	<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR" null="true">
				<CFPROCRESULT NAME="qGetLoadNum">
			</CFSTOREDPROC>
			<cfset loadNumber=qGetLoadNum.LoadNumber>
			<!--- End : Get Load Number --->

			<cfquery name="qmaxinvoiceNumber" datasource="#variables.dsn#">
				SELECT MAX([invoiceNumber] ) AS invoiceNumber FROM loads		
					WHERE LoadID =<cfqueryparam value="#EditLoadID#" cfsqltype="cf_sql_varchar">			
			</cfquery>
			<cfquery name="qLoadID" datasource="#variables.dsn#">
				SELECT NewID() AS NewLoadID			
			</cfquery>

			<cfquery name="qinsetLoad" datasource="#variables.dsn#">		
				DECLARE @generatedloadID uniqueidentifier;		
				SET @generatedloadID = '#qLoadID.NewLoadID#';
				
				INSERT INTO [Loads]
								([LoadId]
								,[LoadNumber]
								,[CreatedDateTime]
								,[LastModifiedDate]
								,[CreatedBy]
								,[ModifiedBy]
								,[SalesRepID]
								,[DispatcherID]
								,[CustomerPONo]
								,[StatusTypeID]
								,[CustomerID]
								,[HasEnrouteStops]
								,[HasTemp]
								,[TempText]
								,[IsPartial]
								,[IsPost]
								,[IsPepUpload]
								,[IsLocked]
								,[LockedDatetime]
								,[LockedBy]
								,[CustFlatRate]
								,[PricingMemo]
								,[CustomerDirections]
								,[CarrierDirections]
								,[CarrOfficeID]
								,[BookedWith]
								,[EquipmentID]
								,[DriverName]
								,[DriverCell]
								,[TruckNo]
								,[TrailorNo]
								,[RefNo]
								,[CarrFlatRate]
								,[TotalCarrierCharges]
								,[TotalCustomerCharges]
								,[InvoiceDate]
								,[LastModifiedBookLoad]
								,[LastModifiedPricing]
								,[LastModifiedCheckCall]
								,[NewNotes]
								,[NewDispatchNotes]
								,[NewBookedWithLoad]
								,[NewPickupNo]								
								,[NewDeliveryNo]								
								,[UpdatedByIp]
								,[CreatedByIP]
								,[CarrierRatePerMile]
								,[CustomerRatePerMile]
								,[carrierNotes]
								,[TotalMiles]
								,[orderDate]
								,[totalProfit]
								,[ARExported]
								,[APExported]
								,[customerMilesCharges]
								,[carrierMilesCharges]
								,[customerCommoditiesCharges]
								,[carrierCommoditiesCharges]
								,[QBExportDateTime]
								,[QBExportDateTime_AP]
								,[CustName]
								,[Address]
								,[City]
								,[StateCode]
								,[PostalCode]
								,[ContactPerson]
								,[Phone]
								,[Fax]
								,[CellNo]
								,[PricingNotes]
								,[BOLNum]
								,[BillDate]
								,[EmergencyResponseNo]
								,[CODAmt]
								,[CODFee]
								,[DeclaredValue]
								,[Notes]
								,[IsTransCorePst]
								,[Trans_Sucess_Flag]
								,[TransFlagNew]
								,[ReadyDate]
								,[ArriveDate]
								,[isExcused]
								,[posttoITS]
								,postCarrierRatetoITS
								,[ControlNumber]
								,[postto123loadboard]
								,[weight]
								,[invoiceNumber]
								,[userDefinedFieldTrucking]
								,[InUseBy]
								,[InUseOn]
								,[sessionId]
								,[CarrierInvoiceNumber]
								,[emailList]
								,[CarrierName]
								,[ShipperState]
								,[ShipperCity]
								,[ConsigneeState]
								,[ConsigneeCity]
								,[SalesAgent]
								,[EquipmentName]
								,[LoadDriverName]
								,[tripText]
								,[CarrierID]
								,NewPickupDate
								,NewDeliveryDate
								)					   
							SELECT	
									@generatedloadID
									,<cfqueryparam value="#loadNumber#" cfsqltype="CF_SQL_BIGINT">	
									,getdate()
									,getdate()
									,[CreatedBy]
									,[ModifiedBy]
									<cfif request.qSystemSetupOptions.CopyLoadIncludeAgentAndDispatcher OR qOrgLoadDetails.StatusText EQ '. TEMPLATE'>
										,[SalesRepID]
										,[DispatcherID]
									<cfelse>
										,NULL
										,NULL
									</cfif>
									,[CustomerPONo]
									,(select statustypeid from LoadStatusTypes where statustext = '1. ACTIVE' AND CompanyID=<cfqueryparam value="#session.companyid#" cfsqltype="cf_sql_varchar">)
									,[CustomerID]
									,[HasEnrouteStops]
									,[HasTemp]
									,[TempText]
									,[IsPartial]
									,[IsPost]
									,[IsPepUpload]
									,[IsLocked]
									,[LockedDatetime]
									,[LockedBy]
									,[CustFlatRate]
									,[PricingMemo]
									,[CustomerDirections]
									,[CarrierDirections]
									,[CarrOfficeID]
									,[BookedWith]
									,[EquipmentID]
									,[DriverName]
									,[DriverCell]
									,[TruckNo]
									,[TrailorNo]
									,[RefNo]
									,[CarrFlatRate]
									,[TotalCarrierCharges]
									,[TotalCustomerCharges]
									,[InvoiceDate]
									,[LastModifiedBookLoad]
									,[LastModifiedPricing]
									,[LastModifiedCheckCall]
									,'Load copied from #qOrgLoadDetails.LoadNumber#'
									,''
									,[NewBookedWithLoad]
									,[NewPickupNo]									
									,[NewDeliveryNo]									
									,''
									,[CreatedByIP]
									,[CarrierRatePerMile]
									,[CustomerRatePerMile]
									,[carrierNotes]
									,[TotalMiles]
									,getdate()
									,0
									,0
									,0
									,[customerMilesCharges]
									,[carrierMilesCharges]
									,[customerCommoditiesCharges]
									,[carrierCommoditiesCharges]
									,[QBExportDateTime]
									,[QBExportDateTime_AP]
									,[CustName]
									,[Address]
									,[City]
									,[StateCode]
									,[PostalCode]
									,[ContactPerson]
									,[Phone]
									,[Fax]
									,[CellNo]
									,[PricingNotes]
									,[BOLNum]
									,[BillDate]
									,[EmergencyResponseNo]
									,[CODAmt]
									,[CODFee]
									,[DeclaredValue]
									,[Notes]
									,[IsTransCorePst]
									,[Trans_Sucess_Flag]
									,[TransFlagNew]
									,[ReadyDate]
									,[ArriveDate]
									,[isExcused]
									,[posttoITS]
									,postCarrierRatetoITS
									,'#loadNumber#'
									,[postto123loadboard]
									,[weight]
									,'#qmaxinvoiceNumber.invoiceNumber#'
									,[userDefinedFieldTrucking]
									,[InUseBy]
									,getdate()
									,[sessionId]
									,[CarrierInvoiceNumber]
									,[emailList]
									<cfif request.qSystemSetupOptions.CopyLoadCarrier OR qOrgLoadDetails.StatusText EQ '. TEMPLATE'>
										,[CarrierName]
									<cfelse>
										,NULL
									</cfif>
									,[ShipperState]
									,[ShipperCity]
									,[ConsigneeState]
									,[ConsigneeCity]
									,[SalesAgent]
									,[EquipmentName]
									,[LoadDriverName]
									,<cfqueryparam value="Trip #i# of #NoOfCopiesNeeded#" cfsqltype="cf_sql_varchar">
									<cfif request.qSystemSetupOptions.CopyLoadCarrier OR qOrgLoadDetails.StatusText EQ '. TEMPLATE'>
										,[CarrierID]
									<cfelse>
										,NULL
									</cfif>
									<cfif request.qSystemSetupOptions.CopyLoadDeliveryPickupDates OR qOrgLoadDetails.StatusText EQ '. TEMPLATE'>
										,[NewPickupDate]
										,[NewDeliveryDate]
									<cfelse>
										,NULL
										,NULL
									</cfif>
							FROM loads where loadid = <cfqueryparam value="#EditLoadID#" cfsqltype="cf_sql_varchar">						
							
							
							INSERT INTO [LoadStops]
						   ([LoadStopID]
						   ,[LoadID]
						   ,[StopNo]
						   ,[IsOriginPickup]
						   ,[IsFinalDelivery]
						   ,[LoadType]
						   ,[Address]
						   ,[City]
						   ,[StateCode]
						   ,[PostalCode]
						   ,[ContactPerson]
						   ,[Phone]
						   ,[Fax]
						   ,[CellNo]
						   ,[Blind]
						   ,[RefNo]
						   ,[ReleaseNo]
						   ,[StopDate]
						   ,[StopTime]
						   ,[TimeIn]
						   ,[TimeOut]
						   ,[Miles]
						   ,[Instructions]
						   ,[Directions]
						   ,[CreatedDateTime]
						   ,[LastModifiedDate]
						   ,[CreatedBy]
						   ,[ModifiedBy]					   
						   ,[NewEquipmentID]
						   ,[NewOfficeID]
						   ,[CustomerStopName]
						   ,[CustomerID]
						   ,[EmailID]
						   ,[CustName]
						   ,[ForBOL]
						   ,[previous_StopNo]
						   ,[stopdateDifference]
							,[NewCarrierID],[Temperature],[TemperatureScale],[EquipmentTrailer])
						 SELECT 
							NewID()
							,@generatedloadID
							,[StopNo]
							,[IsOriginPickup]
							,[IsFinalDelivery]
							,[LoadType]
							,[Address]
							,[City]
							,[StateCode]
							,[PostalCode]
							,[ContactPerson]
							,[Phone]
							,[Fax]
							,[CellNo]
							,[Blind]
							,''
							,[ReleaseNo]
							<cfif request.qSystemSetupOptions.CopyLoadDeliveryPickupDates OR qOrgLoadDetails.StatusText EQ '. TEMPLATE'>
								,[StopDate]
							   	,[StopTime]
							<cfelse>
								,''
								,''
							</cfif>
							,''
							,''
							,0
							,[Instructions]
							,[Directions]
							,getdate()
							,getdate()
							,[CreatedBy]
							,[ModifiedBy]						
							,[NewEquipmentID]
							,[NewOfficeID]
							,[CustomerStopName]
							,[CustomerID]
							,[EmailID]
							,[CustName]
							,[ForBOL]
							,[previous_StopNo]
							,[stopdateDifference]
							<cfif request.qSystemSetupOptions.CopyLoadCarrier OR qOrgLoadDetails.StatusText EQ '. TEMPLATE'>
								,[NewCarrierID]
							<cfelse>
								,NULL
							</cfif>
							,[Temperature],[TemperatureScale],[EquipmentTrailer]
							FROM  [LoadStops]
							WHERE  loadid = <cfqueryparam value="#EditLoadID#" cfsqltype="cf_sql_varchar">	
							
							DECLARE @maxStopNO INT = 0;
				DECLARE @LoadStopID UNIQUEIDENTIFIER;
				
				SELECT @maxStopNO = MAX(StopNO) FROM loadstops WHERE loadid=<cfqueryparam value="#EditLoadID#" cfsqltype="cf_sql_varchar">	;
				
				WHILE(@maxStopNO >= 0)
				BEGIN
					SELECT @LoadStopID = LoadStopID FROM loadstops WHERE loadid=@generatedloadID AND StopNO = @maxStopNO  AND LoadType = 1;
					
					INSERT INTO [LoadStopCommodities]
						 ([LoadStopID]
							,[SrNo]
							,[Qty]
							,[UnitID]
							,[Description]
							,[Weight]
							,[ClassID]
							,[CustCharges]
							,[CarrCharges]
							,[Fee]
							,[CustRate]
							,[CarrRate]
							,[CarrRateOfCustTotal])
						SELECT 
							@LoadStopID
							,[SrNo]
							,[Qty]
							,[UnitID]
							,[Description]
							,[Weight]
							,[ClassID]
							,[CustCharges]
							,[CarrCharges]
							,[Fee]
							,[CustRate]
							,[CarrRate]
							,[CarrRateOfCustTotal]
						FROM LoadStopCommodities
						WHERE  LoadStopID IN (
							SELECT LoadStopID 
									FROM loadstops 
									WHERE loadid= <cfqueryparam value="#EditLoadID#" cfsqltype="cf_sql_varchar">	
									AND STOPNO = @maxStopNO
									AND LoadType = 1
						)
					SET @maxStopNO = @maxStopNO-1;
				END
					INSERT INTO LoadLogs (
							LoadID,
							LoadNumber,
							FieldLabel,
							NewValue,
							UpdatedByUserID,
							UpdatedBy,
							UpdatedTimestamp
						)
					values
						(
							@generatedloadID,
							<cfqueryparam value="#loadNumber#" cfsqltype="cf_sql_nvarchar">,
							<cfqueryparam value="New Load" cfsqltype="cf_sql_nvarchar">,
							<cfqueryparam value="Load copied from #qOrgLoadDetails.LoadNumber#" cfsqltype="cf_sql_nvarchar">,
							<cfqueryparam value="#session.empid#" cfsqltype="cf_sql_nvarchar">,
							<cfqueryparam value="#session.userfullname#" cfsqltype="cf_sql_nvarchar">,
							<cfqueryparam value="#Now()#" cfsqltype="cf_sql_timestamp">
						)
						INSERT INTO LoadLogs (
							LoadID,
							LoadNumber,
							FieldLabel,
							NewValue,
							UpdatedByUserID,
							UpdatedBy,
							UpdatedTimestamp
							)
						values
							(
							@generatedloadID,
							<cfqueryparam value="#loadNumber#" cfsqltype="cf_sql_nvarchar">,
							<cfqueryparam value="New Load : Carrier" cfsqltype="cf_sql_nvarchar">,
							<cfqueryparam value="#qOrgLoadDetails.carrierid#" cfsqltype="cf_sql_nvarchar">,
							<cfqueryparam value="#session.empid#" cfsqltype="cf_sql_nvarchar">,
							<cfqueryparam value="#session.userfullname#" cfsqltype="cf_sql_nvarchar">,
							<cfqueryparam value="#Now()#" cfsqltype="cf_sql_timestamp">
							)
			</cfquery>		
			<cfset lstLoadNumber = ListAppend(lstLoadNumber,loadNumber)>

			<cfif qOrgLoadDetails.RateApprovalNeeded EQ 1 AND request.qSystemSetupOptions.MinMarginOverrideApproval EQ 1>
				<cfif not structKeyExists(variables,"objAlertGateway")>
					<cfscript>variables.objAlertGateway = dsn&".www.gateways.alertgateway";</cfscript>
				</cfif>

				<cfinvoke component="#variables.objAlertGateway#" method="createAlert" CreatedBy="#session.EmpID#" CompanyID="#session.CompanyID#" Description="Load Margin Override" AssignedType="Role" AssignedTo="Administrator" Type="Load" TypeId="#qLoadID.NewLoadID#" Reference="#loadNumber#"/>
			</cfif>
		</cfloop>
		<cfsavecontent variable="loadDetails">
			<cfoutput>
			<h3 style='color:##31a047;'>#NoOfCopies# load copied successfully</h3><p>	The load numbers are<cfloop list="#lstLoadNumber#" index="ele">	<cfquery name="qgetload" datasource="#variables.dsn#">SELECT loadid FROM loads WHERE loadnumber = <cfqueryparam value="#ele#" cfsqltype="CF_SQL_BIGINT">	 and customerid in (select customerid from CustomerOffices inner join offices on CustomerOffices.officeid = offices.officeid where offices.companyid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#session.companyid#">)</cfquery>	<a href='index.cfm?event=addload&loadid=#qgetload.loadid#' target='_blank'>#ele#</a></cfloop></p>
			</cfoutput>
		</cfsavecontent>
		
		<cfreturn loadDetails>
	</cffunction> 
	
	<cffunction name="ChangeLoadNumber" access="remote"  returntype="any" returnformat="json">
		<cfargument name="dsn" type="string" required="yes"/>
		<cfargument name="adminUserName" type="string" required="yes"/>
		<cfargument name="loadid" type="string" required="yes"/>
		<cfargument name="StatusTypeID" type="string" required="yes"/>
		<cfargument name="StatusText" type="string" required="yes"/>
		<cfargument name="fBStatus" type="numeric" required="yes"/>
		<cfargument name="carrierId" type="any" required="yes"/>
		<cfargument name="CompanyID" type="string" required="yes"/>
		<cfset strMsg =datetimeformat(now(),"mm/dd/yyy hh:mm tt") &" - Load number changed from ">
		<cfset strMsg1 =datetimeformat(now(),"mm/dd/yyy hh:mm tt") &" > Status changed to  "&arguments.StatusText>
				<cfquery name="qgetLoadNumber" datasource="#arguments.dsn#">		
					SELECT LoadNumber FROM loads
					WHERE loadid = <cfqueryparam value="#arguments.LoadID#" cfsqltype="cf_sql_varchar">	
				</cfquery>
				<cfset strMsg =  strMsg&qgetLoadNumber.LoadNumber>
				<cfquery name="qGetGeneratedLoadNumber" datasource="#arguments.dsn#">		
						DECLARE @cnt INT = 1;
					DECLARE @MAXLoadNumber INT = (SELECT MAX(LoadNumber) FROM loads where customerid in (select customerid from CustomerOffices inner join offices on CustomerOffices.officeid = offices.officeid where offices.companyid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.companyid#">));
					DECLARE @StartingActiveLoadNumber INT = (SELECT ISNULL(StartingActiveLoadNumber,0) AS StartingActiveLoadNumber FROM systemconfig where companyid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.companyid#">);
					DECLARE @ActiveLoadNumber INT = @StartingActiveLoadNumber;


					CREATE TABLE ##Loads_Temp(LoadNumber INT)
					INSERT INTO ##Loads_Temp SELECT loadnumber FROM loads WHERE CustomerID IN (SELECT CustomerID FROM CustomerOffices WHERE OfficeID IN (SELECT OfficeID FROM Offices WHERE CompanyID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.companyid#">));


					WHILE @cnt > 0
					BEGIN						
						IF   EXISTS(SELECT @ActiveLoadNumber+@cnt FROM systemconfig WHERE CompanyID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.companyid#"> AND
						 (@ActiveLoadNumber  + @cnt)
						NOT IN (SELECT loadnumber FROM ##Loads_Temp))
							BEGIN
								SELECT @ActiveLoadNumber+@cnt  AS ID FROM systemconfig WHERE CompanyID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.companyid#"> AND
									 (@ActiveLoadNumber  + @cnt)
									NOT IN (SELECT loadnumber FROM ##Loads_Temp);
									DROP TABLE ##Loads_Temp;
									BREAK;
							END
						ELSE
							BEGIN
								SET @cnt = @cnt + 1;
							END   
					END;
				</cfquery>
				<cfif  qGetGeneratedLoadNumber.recordcount GT 0>
					<cfif fBStatus EQ 2>
						<cfquery name="qGetIsConcatCarDriId" datasource="#arguments.dsn#">		
							SELECT IsConcatCarrierDriverIdentifier FROM systemconfig companyid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.companyid#">
						</cfquery>

						<cfif qGetIsConcatCarDriId.IsConcatCarrierDriverIdentifier EQ 1>
							<cfquery name="local.qGetIsCarrier" datasource="#arguments.dsn#">		
								select IsCarrier from [Carriers] where CarrierID = <cfqueryparam value="#arguments.carrierID#" cfsqltype="cf_sql_varchar">	
							</cfquery>
							<cfset loadNoWithoutIdentifier = qGetGeneratedLoadNumber.ID >
							
							<cfset loadNumberflag = true />
							<cfloop condition="loadNumberflag EQ true"> 
						        <!--- Check load number is exists or not --->
						        <cfif local.qGetIsCarrier.IsCarrier EQ 1 >
						        	<cfquery name="qCheckLoadNumExists" datasource="#arguments.dsn#">
									 	SELECT LoadID from loads where LoadNumber = <cfqueryparam cfsqltype="cf_sql_integer" value="1#loadNoWithoutIdentifier#"> and customerid in (select customerid from CustomerOffices inner join offices on CustomerOffices.officeid = offices.officeid where offices.companyid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.companyid#">)
									</cfquery>
								<cfelse>	
									<cfquery name="qCheckLoadNumExists" datasource="#arguments.dsn#">
									 	SELECT LoadID from loads where LoadNumber = <cfqueryparam cfsqltype="cf_sql_integer" value="2#loadNoWithoutIdentifier#">
										and customerid in (select customerid from CustomerOffices inner join offices on CustomerOffices.officeid = offices.officeid where offices.companyid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.companyid#">)
									</cfquery>
								</cfif>
						        <cfif qCheckLoadNumExists.recordcount EQ 0>
						        	<cfset strMsg =  strMsg&" to "&loadNoWithoutIdentifier>
						        	<cfreturn loadNoWithoutIdentifier>
						       		<cfset loadNumberflag = false />
						       	<cfelse>
						       		<cfset loadNoWithoutIdentifier += 1	/>
						        </cfif>
						    </cfloop>
						</cfif>								
					</cfif>
					<cfset strMsg =  strMsg&" to "&qGetGeneratedLoadNumber.ID>
					<cfreturn  qGetGeneratedLoadNumber.ID>					
				</cfif>
				<cfreturn 0>
	</cffunction>
	
	
	<cffunction name="CheckForLoadStopS" access="public" returntype="any">
		<cfargument name="LoadID" required="yes" type="any">
		
		
			<cfset var EditLoadID = arguments.loadid >
			<cfset var qStopCount = queryNew("") >
			<cfquery  name="qStopCount" datasource="#dsn#">			
				SELECT 
					MAX(stopNo) AS totStop 
					FROM LoadStops
				WHERE loadId = <CFQUERYPARAM VALUE="#EditLoadID#" cfsqltype="CF_SQL_VARCHAR">		
			</cfquery>
			<cfif qStopCount.recordcount GT 0 AND qStopCount.totStop GT 0>
				<cfset var count =  qStopCount.totStop>
			<cfelse>
				<cfset var count =  0>
			</cfif>
			<cfparam name="session.empid" default="">

			<cfif not len(session.empid)>
				<cfquery name="rstCurrentSiteUserFirst" datasource="#dsn#">
					SELECT EmployeeID as pkiadminUserID, name as FirstName, name as LastName,loginid as UserName,emailid as EmailAddress,isActive as bEnabled,createdDateTime as dtCreated,LastModifiedDatetime as dtUpdated, Employees.officeId
					FROM Employees
					INNER JOIN (SELECT OfficeID,CompanyID FROM Offices) O ON O.OfficeID = Employees.OfficeID
					WHERE loginId = <cfqueryparam cfsqltype="cf_sql_varchar" value="lm" />
					AND isActive = 1
					AND O.CompanyID  = <cfqueryparam cfsqltype="cf_sql_varchar" value="#session.companyid#" />
				</cfquery>
				<cfif rstCurrentSiteUserFirst.recordcount>
					<cfset session.EmpId= rstCurrentSiteUserFirst.pkiadminUserID>
				</cfif>
			</cfif>
			<cfinvoke method="getcurAgentMaildetails" employeID="#session.empid#"  returnvariable="request.qcurAgentdetailsforMail" />
			<cfset SmtpAddress=request.qcurAgentdetailsforMail.SmtpAddress>
			<cfset SmtpUsername=request.qcurAgentdetailsforMail.SmtpUsername>
			<cfset SmtpPort=request.qcurAgentdetailsforMail.SmtpPort>
			<cfset SmtpPassword=request.qcurAgentdetailsforMail.SmtpPassword>
			<cfset FA_SSL=request.qcurAgentdetailsforMail.useSSL>
			<cfset FA_TLS=request.qcurAgentdetailsforMail.useTLS>
			<cfset MailFrom=request.qcurAgentdetailsforMail.EmailID>
			
			<cfset emailSignature = request.qcurAgentdetailsforMail.emailSignature>

			<cfset var Stop = 0>
			
			<cfloop from="0" to="#count#"  index="Stop">
				<cfset var qGetShipper = queryNew("") >
				<cfquery name="qGetShipper" datasource="#dsn#">		
					SELECT   dbo.Loads.LoadNumber, dbo.LoadStops.StopNo, dbo.Loads.LoadID,dbo.LoadStops.LoadType
					FROM    dbo.Loads 
					INNER JOIN dbo.LoadStops ON dbo.Loads.LoadID = dbo.LoadStops.LoadID
					WHERE dbo.Loads.LoadID =   <cfqueryparam cfsqltype="cf_sql_varchar" value="#EditLoadID#">
					AND dbo.LoadStops.StopNo = <cfqueryparam cfsqltype="cf_sql_integer" value="#Stop#">
					AND dbo.LoadStops.LoadType = 1
				</cfquery>
				
				<cfset var qGetConsignee = queryNew("") >
				<cfquery name="qGetConsignee" datasource="#dsn#">		
					SELECT   dbo.Loads.LoadNumber, dbo.LoadStops.StopNo, dbo.Loads.LoadID,dbo.LoadStops.LoadType
					FROM    dbo.Loads 
					INNER JOIN dbo.LoadStops ON dbo.Loads.LoadID = dbo.LoadStops.LoadID
					WHERE dbo.Loads.LoadID =   <cfqueryparam cfsqltype="cf_sql_varchar" value="#EditLoadID#">
					AND dbo.LoadStops.StopNo = <cfqueryparam cfsqltype="cf_sql_integer" value="#Stop#">
					AND dbo.LoadStops.LoadType = 2
				</cfquery>

				<cfif qGetShipper.recordcount EQ 0 AND qGetConsignee.recordcount GT 0>
					<cfset var qLoad = queryNew("") >
					<cfquery name="qLoad" datasource="#dsn#">		
						SELECT   dbo.Loads.LoadNumber
						FROM    dbo.Loads 						
						WHERE dbo.Loads.LoadID =   <cfqueryparam cfsqltype="cf_sql_varchar" value="#EditLoadID#">					
					</cfquery>
					
					<cfset var qInsEmptyShipper = queryNew("") >
					<cfquery name="qInsEmptyShipper" datasource="#dsn#">
						DECLARE @Shipper uniqueidentifier;
						DECLARE @loadid uniqueidentifier;
						SET @Shipper = NewID();
						SET @loadid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#EditLoadID#">;					

						INSERT INTO [dbo].[LoadStops]
							([LoadStopID],[LoadID],[StopNo],IsOriginPickup,IsFinalDelivery,LoadType,Blind,Miles,CreatedDateTime,LastModifiedDate,CreatedBy,ModifiedBy,RefNo,ReleaseNo,StopTime,TimeIn,[TimeOut]
							)

						VALUES
							(@Shipper,@loadid,#Stop#,1,1,1,0	,0	,getdate(),getdate(),'scott','scott','','','','',''	
							);
						SELECT * FROM [dbo].[LoadStops] WHERE [LoadStopID] = @Shipper;
					</cfquery>
					
					<cfif len(trim(SmtpAddress))>
						<cfmail from='"#SmtpUsername#" <#SmtpUsername#>' 
							subject="Shipper has been added to Load #qLoad.LoadNumber#" 
							to="scottw@webersystems.com" 	 					
							type="text/html" 
							server="#SmtpAddress#" 
							username="#SmtpUsername#" 
							password="#SmtpPassword#" 
							port="#SmtpPort#" 
							usessl="#FA_SSL#" 
							usetls="#FA_TLS#" >						 
								<cfoutput>
								<p>Hi,</p>
								<p>We found load with Load## #qLoad.LoadNumber# has no pickup for stop #Stop# in #dsn#.</p>
								<p>We created an empty pickup for this stop on #datetimeformat(now(),"yyyy/mm/dd hh:mm tt")#.</p>
								</cfoutput>
						</cfmail>
					</cfif>
					
				</cfif>

				<cfif qGetConsignee.recordcount EQ 0 AND qGetShipper.recordcount GT 0>
						<cfset var qLoad = queryNew("") >
						<cfquery name="qLoad" datasource="#dsn#">		
							SELECT   dbo.Loads.LoadNumber
							FROM    dbo.Loads 						
							WHERE dbo.Loads.LoadID =   <cfqueryparam cfsqltype="cf_sql_varchar" value="#EditLoadID#">					
						</cfquery>
						
						<cfset var qInsEmptyConsignee = queryNew("") >
						<cfquery name="qInsEmptyConsignee" datasource="#dsn#">
						DECLARE @Shipper uniqueidentifier;
						DECLARE @loadid uniqueidentifier;
						SET @Shipper = NewID();
						SET @loadid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#EditLoadID#">;					

						INSERT INTO [dbo].[LoadStops]
							([LoadStopID],[LoadID],[StopNo],IsOriginPickup,IsFinalDelivery,LoadType,Blind,Miles,CreatedDateTime,LastModifiedDate,CreatedBy,ModifiedBy,RefNo,ReleaseNo,StopTime,TimeIn,[TimeOut]
							)

						VALUES
							(@Shipper,@loadid,#Stop#,1,1,2,0	,0	,getdate(),getdate(),'scott','scott','','','','',''	
							)

						SELECT * FROM [dbo].[LoadStops] WHERE [LoadStopID] = @Shipper;
					</cfquery>
					
					<cfif len(trim(SmtpAddress))>
						<cfmail from='"#SmtpUsername#" <#SmtpUsername#>' 
							subject="Delivery has been added to Load #qLoad.LoadNumber#" 
							to="scottw@webersystems.com" 
							type="text/html" 
							server="#SmtpAddress#" 
							username="#SmtpUsername#" 
							password="#SmtpPassword#" 
							port="#SmtpPort#" 
							usessl="#FA_SSL#" 
							usetls="#FA_TLS#" >						
								<cfoutput>
								<p>Hi,</p>
								<p>We found load with LoadID## #qLoad.LoadNumber# has no Delivery for stop #Stop# in #dsn#.</p>
								<p>We created an empty Delivery for this stop on #datetimeformat(now(),"yyyy/mm/dd hh:mm tt")#.</p>
								</cfoutput>
						</cfmail>
					</cfif>
				</cfif>
			</cfloop>		
		
		<cfreturn 1>
	</cffunction>
	
	
	<cffunction name="checkForDuplicateLoadNumber" access="remote" returntype="any" returnformat="JSON">		
			<cfargument name="LoadNumber" required="yes" type="any">
			<cfargument name="dsn" required="yes" type="any">
			<cfset bitDuplicate = 0 >
			<cfset MaxLoadNumber = 0 >
			<cfquery name="qcheckForDuplicateLoadNumber" datasource="#arguments.dsn#">		
					SELECT COUNT(*) AS count
					FROM loads 
					WHERE LoadNumber =   <cfqueryparam value="#arguments.LoadNumber#" cfsqltype="cf_sql_integer">
			</cfquery>
			<cfif qcheckForDuplicateLoadNumber.recordcount GT 0>
				<cfset bitDuplicate = qcheckForDuplicateLoadNumber.count >
			</cfif>					
		<cfreturn bitDuplicate>
	</cffunction>	


	<cffunction name="getLoadCarriersContacts" access="public" returntype="any">
		<cfargument name="loadid" required="true" type="any">
		<cfargument name="dsn" required="no" type="any">
		<cfif isdefined('dsn')>
	    	<cfset activedsn = dsn>
	    <cfelse>
	    	<cfset activedsn = variables.dsn>
	    </cfif>
		<cfset var maiList = "">
		<cfset var textList = "">
		<cfif isdefined('arguments.loadid') and len(arguments.loadid) gt 1>
			<cfquery datasource="#activedsn#" name="qrygetcarriers">
				SELECT
	 				DISTINCT a.NewCarrierID,
	 				CASE WHEN ltrim(Rtrim(IsNull(carr.emailid, ''))) = '' THEN
	 				(SELECT TOP 1 Email FROM CarrierContacts CC WHERE CC.CarrierID = carr.CarrierID AND CC.ContactType = 'Dispatch' ) 
	 				ELSE
	 				carr.emailid END
	 				AS EmailID,
	 				carr.cel,
	 				carr.ContactHow
				FROM LoadStops a
				JOIN LoadStops b ON a.LoadID = b.LoadID AND a.StopNo = b.StopNo
				LEFT OUTER JOIN (SELECT [CarrierID],[CarrierName], [EmailID], [cel], [ContactHow] FROM [Carriers]) AS carr ON carr.CarrierID = a.NewCarrierID
				WHERE a.LoadID = <CFQUERYPARAM VALUE="#arguments.loadid#" cfsqltype="CF_SQL_VARCHAR">
				AND a.LoadType = 1
				AND b.LoadType = 2
				AND b.StopNo =a.StopNo
			</cfquery>
			<cfoutput query="qrygetcarriers">
				<cfif qrygetcarriers.ContactHow EQ 1 OR NOT len(trim(qrygetcarriers.ContactHow))>
					<cfif IsValid( "email", qrygetcarriers.EmailID)>
						<cfset maiList = ListAppend(maiList, qrygetcarriers.EmailID,';')>
					</cfif>
				<cfelseif qrygetcarriers.ContactHow EQ 2>
					<cfif REFIND("^(?:(?:\+?1\s*(?:[.-]\s*)?)?(?:\(\s*([2-9]1[02-9]|[2-9][02-8]1|[2-9][02-8][02-9])\s*\)|([2-9]1[02-9]|[2-9][02-8]1|[2-9][02-8][02-9]))\s*(?:[.-]\s*)?)?([2-9]1[02-9]|[2-9][02-9]1|[2-9][02-9]{2})\s*(?:[.-]\s*)?([0-9]{4})(?:\s*(?:##|x\.?|ext\.?|extension)\s*(\d+))?$",qrygetcarriers.cel) >					
						<cfset textList = ListAppend(textList, qrygetcarriers.cel,';')> <!--- If cell number is not valid --->
					<cfelseif IsValid( "email", qrygetcarriers.EmailID)>
						<cfset maiList = ListAppend(maiList, qrygetcarriers.EmailID,';')>
					</cfif>
				<cfelseif qrygetcarriers.ContactHow EQ 3>
					<cfif REFIND("^(?:(?:\+?1\s*(?:[.-]\s*)?)?(?:\(\s*([2-9]1[02-9]|[2-9][02-8]1|[2-9][02-8][02-9])\s*\)|([2-9]1[02-9]|[2-9][02-8]1|[2-9][02-8][02-9]))\s*(?:[.-]\s*)?)?([2-9]1[02-9]|[2-9][02-9]1|[2-9][02-9]{2})\s*(?:[.-]\s*)?([0-9]{4})(?:\s*(?:##|x\.?|ext\.?|extension)\s*(\d+))?$",qrygetcarriers.cel) >					
						<cfset textList = ListAppend(textList, qrygetcarriers.cel,';')>
					</cfif>
					<cfif IsValid( "email", qrygetcarriers.EmailID)>
						<cfset maiList = ListAppend(maiList, qrygetcarriers.EmailID,';')>
					</cfif>
				</cfif>
			</cfoutput>
		</cfif>
		<cfset returnData = {
    						mailList = maiList,
    						textList = textList   
    						} />
		<cfreturn returnData>
	</cffunction>

	<!--- Funtion to get carrier email and phone contact --->
	<cffunction name="getAllCarrierContacts" access="public" returntype="any">
		<cfargument name="freightBroker" required="no" type="any" default="1">
		<cfargument name="numberOfRecords" required="no" type="any" default="100">
		<cfargument name="dsn" required="no" type="any">
		<cfargument name="CarrierID" required="no" type="any" default="">
		<cfif isdefined('dsn')>
	    	<cfset activedsn = dsn>
	    <cfelse>
	    	<cfset activedsn = variables.dsn>
	    </cfif>
	    <cfif arguments.freightBroker EQ 2>
	    	<cfset arguments.freightBroker = 1/>
	    </cfif>
		<cfset var maiList = "">
		<cfset var textList = "">
		<cfset emailAndName = structNew() />
		
		<cfif structKeyExists(arguments, "CarrierID") AND len(trim(arguments.CarrierID))>
			<cfquery datasource="#activedsn#" name="local.qrygetcarrierscontacts">
				SELECT CarrierID,CarrierName, EmailID, cel, ContactHow 
				FROM Carriers 
				WHERE 
				CarrierID IN (<cfqueryparam value="#arguments.CarrierID#" cfsqltype="cf_sql_varchar" list="true">)
				AND CompanyID = <cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar">
			</cfquery>
		<cfelse>
			<cfquery datasource="#activedsn#" name="local.qrygetcarrierscontacts">
				SELECT TOP #numberOfRecords# CarrierID,CarrierName, EmailID, cel, ContactHow 
				FROM Carriers 
				WHERE status = 1 
				AND CarrierEmailAvailableLoads = 1
				AND isCarrier = <CFQUERYPARAM VALUE="#arguments.freightBroker#" cfsqltype="cf_sql_tinyint">
				AND CompanyID = <cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar">
			</cfquery>
		</cfif>
		<cfoutput query="local.qrygetcarrierscontacts">
			<cfif local.qrygetcarrierscontacts.ContactHow EQ 1 OR NOT len(trim(local.qrygetcarrierscontacts.ContactHow))>
				<cfif IsValid( "email", local.qrygetcarrierscontacts.EmailID)>
					<cfset maiList = ListAppend(maiList, local.qrygetcarrierscontacts.EmailID,';')>
					<cfset emailAndName[#local.qrygetcarrierscontacts.EmailID#] = qrygetcarrierscontacts.CarrierName>
				</cfif>
			<cfelseif local.qrygetcarrierscontacts.ContactHow EQ 2>
				<cfif REFIND("^(?:(?:\+?1\s*(?:[.-]\s*)?)?(?:\(\s*([2-9]1[02-9]|[2-9][02-8]1|[2-9][02-8][02-9])\s*\)|([2-9]1[02-9]|[2-9][02-8]1|[2-9][02-8][02-9]))\s*(?:[.-]\s*)?)?([2-9]1[02-9]|[2-9][02-9]1|[2-9][02-9]{2})\s*(?:[.-]\s*)?([0-9]{4})(?:\s*(?:##|x\.?|ext\.?|extension)\s*(\d+))?$",local.qrygetcarrierscontacts.cel) >					
					<cfset textList = ListAppend(textList, local.qrygetcarrierscontacts.cel,';')> <!--- If cell number is not valid --->
				<cfelseif IsValid( "email", local.qrygetcarrierscontacts.EmailID)>
					<cfset maiList = ListAppend(maiList, local.qrygetcarrierscontacts.EmailID,';')>
					<cfset emailAndName[#local.qrygetcarrierscontacts.EmailID#] = qrygetcarrierscontacts.CarrierName>
				</cfif>
			<cfelseif local.qrygetcarrierscontacts.ContactHow EQ 3>
				<cfif REFIND("^(?:(?:\+?1\s*(?:[.-]\s*)?)?(?:\(\s*([2-9]1[02-9]|[2-9][02-8]1|[2-9][02-8][02-9])\s*\)|([2-9]1[02-9]|[2-9][02-8]1|[2-9][02-8][02-9]))\s*(?:[.-]\s*)?)?([2-9]1[02-9]|[2-9][02-9]1|[2-9][02-9]{2})\s*(?:[.-]\s*)?([0-9]{4})(?:\s*(?:##|x\.?|ext\.?|extension)\s*(\d+))?$",local.qrygetcarrierscontacts.cel) >					
					<cfset textList = ListAppend(textList, local.qrygetcarrierscontacts.cel,';')>
				</cfif>
				<cfif IsValid( "email", local.qrygetcarrierscontacts.EmailID)>
					<cfset maiList = ListAppend(maiList, local.qrygetcarrierscontacts.EmailID,';')>
					<cfset emailAndName[#local.qrygetcarrierscontacts.EmailID#] = qrygetcarrierscontacts.CarrierName>
				</cfif>
			</cfif>
		</cfoutput>
	
		<cfset returnData = {
    						mailList = maiList,
    						textList = textList,
    						emailAndName = emailAndName   
    						} />
		<cfreturn returnData>
	</cffunction>

	<!--- Funtion to get carrier and driver email contact --->
	<cffunction name="getAllCarrierDriverContacts" access="public" returntype="any">
		<cfargument name="freightBroker" required="no" type="any" default="1">
		<cfargument name="dsn" required="no" type="any">
		<cfif isdefined('dsn')>
	    	<cfset activedsn = dsn>
	    <cfelse>
	    	<cfset activedsn = variables.dsn>
	    </cfif>
	    <cfif arguments.freightBroker EQ 2>
	    	<cfset arguments.freightBroker = 1/>
	    </cfif>
		<cfset var maiList = "">
				
		<cfquery datasource="#activedsn#" name="local.qrygetcarrierscontacts">
			SELECT EmailID, ContactHow 
			FROM Carriers 
			WHERE status = 1 
			AND CarrierEmailAvailableLoads = 1
			AND isCarrier = <CFQUERYPARAM VALUE="#arguments.freightBroker#" cfsqltype="cf_sql_tinyint">
			AND CompanyID = <cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar">
		</cfquery>

		<cfoutput query="local.qrygetcarrierscontacts">
			<cfif local.qrygetcarrierscontacts.ContactHow EQ 1 OR NOT len(trim(local.qrygetcarrierscontacts.ContactHow))>
				<cfif IsValid( "email", local.qrygetcarrierscontacts.EmailID)>
					<cfset maiList = ListAppend(maiList, local.qrygetcarrierscontacts.EmailID,';')>
				</cfif>
			<cfelseif local.qrygetcarrierscontacts.ContactHow EQ 2>
				<cfif IsValid( "email", local.qrygetcarrierscontacts.EmailID)>
					<cfset maiList = ListAppend(maiList, local.qrygetcarrierscontacts.EmailID,';')>
				</cfif>
			<cfelseif local.qrygetcarrierscontacts.ContactHow EQ 3>
				<cfif IsValid( "email", local.qrygetcarrierscontacts.EmailID)>
					<cfset maiList = ListAppend(maiList, local.qrygetcarrierscontacts.EmailID,';')>
				</cfif>
			</cfif>
		</cfoutput>
	
		<cfset returnData = {
    						mailList = maiList    						    						  
    						} />
		<cfreturn returnData>
	</cffunction>
	
		<!--- Function to add log for texts on Reports--->
	<cffunction name="setLogTexts" access="public">
		<cfargument name="loadID" required="yes" type="string">
		<cfargument name="date" required="yes" type="string">
		<cfargument name="textBody" required="yes" type="string">
		<cfargument name="reportType" required="yes" type="string">
		<cfargument name="fromNumber" required="yes" type="string">
		<cfargument name="toNumber" required="yes" type="string">
		<cfargument name="textAPIID" required="yes" type="string">		

		<cfset loadNo = "n/a" >
		<cfif arguments.loadID neq "n/a">
			<cfquery name="qryGetLoadNumber" datasource="#application.dsn#">
				SELECT LoadNumber FROM Loads WHERE LoadID = <cfqueryparam value="#arguments.loadID#" cfsqltype="cf_sql_varchar">
			</cfquery>
			<cfset loadNo = qryGetLoadNumber.LoadNumber>
		</cfif>

		<cfquery name="qrySetTextLog" datasource="#application.dsn#" result="qResult">
			INSERT INTO TextLogs(loadID,loadno,date,textBody,reportType,createDate,fromNumber,toNumber,textAPIID)
			VALUES(
		    <cfqueryparam value="#arguments.loadID#" cfsqltype="cf_sql_varchar">,
		    <cfqueryparam value="#loadNo#" cfsqltype="cf_sql_varchar">,
		    <cfqueryparam value="#arguments.date#" cfsqltype="cf_sql_timestamp">,
		    <cfqueryparam value="#arguments.textBody#" cfsqltype="cf_sql_varchar">,
		    <cfqueryparam value="#arguments.reportType#" cfsqltype="cf_sql_varchar">,
		    <cfqueryparam value="#Now()#" cfsqltype="cf_sql_timestamp" >,
		    <cfqueryparam value="#arguments.fromNumber#" cfsqltype="cf_sql_varchar">,
		    <cfqueryparam value="#arguments.toNumber#" cfsqltype="cf_sql_varchar">,
			<cfqueryparam value="#val(arguments.textAPIID)#" cfsqltype="cf_sql_integer">)
		</cfquery>
	</cffunction>
	
	
	<cffunction name="addLoadLog" access="public" returntype="any">
		<cfargument name="loadID" default="0" required="true">
		<cfargument name="logType" default="1" required="true"><!--- 1 = new load, 2 = load update --->
		<cfargument name="updatedUserID" default="" required="true">
		<cfargument name="updatedUser" default="" required="true">
		<cfargument name="logData" type="struct" default="#StructNew()#">
		
		<cfset var makeReadable = structNew()>
		<cfset makeReadable.RunUSP_UpdateLoad_STATUSTYPEID.query = getLoadStatus()><!--- value,Text--->
		<cfset makeReadable.RunUSP_UpdateLoad_STATUSTYPEID.from = "value"><!--- value,Text--->
		<cfset makeReadable.RunUSP_UpdateLoad_STATUSTYPEID.to = "Text"><!--- value,Text--->
		<cfset makeReadable.RunUSP_UpdateLoad_STATUSTYPEID.transform = "STATUS"><!--- RunUSP_UpdateLoad_STATUSTYPEID to STATUS in load logs--->

		<cfset makeReadable.RunUSP_UpdateLoad_DISPATCHERID.query = getloadSalesPerson("Sales Representative,Manager,Dispatcher")><!--- EMPLOYEEID 	NAME--->
		<cfset makeReadable.RunUSP_UpdateLoad_DISPATCHERID.from = "EMPLOYEEID"><!--- EMPLOYEEID 	NAME--->
		<cfset makeReadable.RunUSP_UpdateLoad_DISPATCHERID.to = "NAME"><!--- EMPLOYEEID 	NAME--->
		<cfset makeReadable.RunUSP_UpdateLoad_DISPATCHERID.transform = "DISPATCHER"><!--- EMPLOYEEID 	NAME--->
		
		<cfset makeReadable.RunUSP_UpdateLoad_BOOKEDBY.query = getloadSalesPerson("Sales Representative,Manager,Dispatcher,Administrator,Finance Department,Central Dispatcher,Add Loads Only")><!--- EMPLOYEEID 	NAME--->
		<cfset makeReadable.RunUSP_UpdateLoad_BOOKEDBY.from = "EMPLOYEEID"><!--- EMPLOYEEID 	NAME--->
		<cfset makeReadable.RunUSP_UpdateLoad_BOOKEDBY.to = "NAME"><!--- EMPLOYEEID 	NAME--->

		<cfset x = createObject("component","#request.cfcpath#"&".equipmentgateway")>
		<cfset x.init("#Application.dsn#")>
		<cfset makeReadable.equipment.query = x.getloadEquipments()>
		<cfset makeReadable.equipment.from = "EQUIPMENTID">
		<cfset makeReadable.equipment.to = "EQUIPMENTNAME">
		<cfset makeReadable.equipment.transform = "EQUIPMENTNAME">
		
		<cfset x = createObject("component","#request.cfcpath#"&".unitgateway")>
		<cfset x.init("#Application.dsn#")>
		<cfset makeReadable.unit.query = x.getloadUnits()><!---USP_UpdateLoadItem_UNITID--->
		<cfset makeReadable.unit.from = "UNITID">

		<!---<cfdump var="#makeReadable.USP_UpdateLoadItem_UNITID#" abort>--->
		
		<cfset x = createObject("component","#request.cfcpath#"&".classgateway")>
		<cfset x.init("#Application.dsn#")>
		<cfset makeReadable.class.query = x.getloadClasses()>
		<cfset makeReadable.class.from = "CLASSID">
		<cfset makeReadable.class.to = "CLASSNAME">
			
		<cfquery name="qGetLoadNumber" datasource="#variables.dsn#">
			SELECT LoadNumber from Loads where LoadID = <cfqueryparam value="#arguments.loadID#" cfsqltype="cf_sql_varchar">
		</cfquery>
		<cfif NOT(structKeyExists(arguments, "updatedUserID") AND len(arguments.updatedUserID) AND isDefined("arguments.updatedUser") AND len(arguments.updatedUser) AND structKeyExists(qGetLoadNumber, "LoadNumber") and len(qGetLoadNumber.LoadNumber))>
			Load logging failed. Debug info: <cfdump var="#structKeyExists(cookie, "userLogginID")#"> <!--- edit here on cases of problems --->
			<cfabort>
		</cfif>

		<cfif arguments.logType EQ 1> <!--- New load --->
			<cfquery name="insertLoadLog" datasource="#application.dsn#" result="qResult">
				INSERT INTO LoadLogs (
							LoadID,
							LoadNumber,
							FieldLabel,
							NewValue,
							UpdatedByUserID,
							UpdatedBy,
							UpdatedTimestamp
						)
					values
						(
							<cfqueryparam value="#arguments.loadID#" cfsqltype="cf_sql_nvarchar">,
							<cfqueryparam value="#qGetLoadNumber.LoadNumber#" cfsqltype="cf_sql_bigint">,
							<cfqueryparam value="New Load" cfsqltype="cf_sql_nvarchar">,
							<cfqueryparam value="#SerializeJSON(form)#" cfsqltype="cf_sql_nvarchar">,
							<cfqueryparam value="#arguments.updatedUserID#" cfsqltype="cf_sql_nvarchar">,
							<cfqueryparam value="#arguments.updatedUser#" cfsqltype="cf_sql_nvarchar">,
							<cfqueryparam value="#Now()#" cfsqltype="cf_sql_timestamp">
						)
			</cfquery>

			<cfif structKeyExists(form, "carrierid")>
				<cfquery name="insertLoadLog" datasource="#application.dsn#" result="qResult">
					INSERT INTO LoadLogs (
							LoadID,
							LoadNumber,
							FieldLabel,
							NewValue,
							UpdatedByUserID,
							UpdatedBy,
							UpdatedTimestamp
							)
						values
							(
							<cfqueryparam value="#arguments.loadID#" cfsqltype="cf_sql_nvarchar">,
							<cfqueryparam value="#qGetLoadNumber.LoadNumber#" cfsqltype="cf_sql_bigint">,
							<cfqueryparam value="New Load : Carrier" cfsqltype="cf_sql_nvarchar">,
							<cfqueryparam value="#form.carrierid#" cfsqltype="cf_sql_nvarchar">,
							<cfqueryparam value="#arguments.updatedUserID#" cfsqltype="cf_sql_nvarchar">,
							<cfqueryparam value="#arguments.updatedUser#" cfsqltype="cf_sql_nvarchar">,
							<cfqueryparam value="#Now()#" cfsqltype="cf_sql_timestamp">
							)
				</cfquery>
			</cfif>
		<cfelseif arguments.logType EQ 2 AND isStruct(logData) AND StructCount(logData)> <!--- Load update --->
			<cftry>

				<cfquery name="insertLoadLog" datasource="#application.dsn#" result="qResult">
					INSERT INTO LoadLogs (
								LoadID,
								LoadNumber,
								FieldLabel,
								OldValue,
								NewValue,
								UpdatedByUserID,
								UpdatedBy,
								UpdatedTimestamp
							)
						values
						(
					<cfset var structLength = StructCount(logData)>
					<cfset var counter = 1>
					<cfset var fieldLabel = "">
					
					<cfloop collection="#logData#" item="item"><!--- Filter everything that is not needed from logData before this line. Only those items that goes to DB goes past this point[If not the query will break as we employ a counter here]--->
						<cfif isStruct(logData[item]) AND structKeyExists(logData[item],"FieldLabel")>
							
							<cfif structKeyExists(makeReadable,item)>
								<cfquery dbtype="query" name="NameOfQoQ">
									select *
									from makeReadable.#item#.query
									where [#makeReadable[item].from#] = <cfqueryparam value="#logData[item].OldValue#" cfsqltype="cf_sql_longvarchar">
								</cfquery>
								<cfset logData[item].OldValue = NameOfQoQ[makeReadable[item].to]>
															
								<cfquery dbtype="query" name="NameOfQoQ">
									select *
									from makeReadable.#item#.query
									where [#makeReadable[item].from#] = <cfqueryparam value="#logData[item].NewValue#" cfsqltype="cf_sql_longvarchar">
								</cfquery>
								<cfset logData[item].NewValue = NameOfQoQ[makeReadable[item].to]>

								<!--- transform --->
								<cfif StructKeyExists(makeReadable[item], "transform")>
									<cfset logData[item].FieldLabel = makeReadable[item].transform>
								</cfif>
								<!---<cfdump var="#logData[item]#" >--->
							</cfif>
							
							<!---special case unit--->
							<cfif REFindNoCase("^unit\d{0,}_\d{1,}", item) AND structKeyExists(makeReadable,"unit")>
								<cfquery dbtype="query" name="NameOfQoQ">
									select *
									from makeReadable.unit.query
									where [#makeReadable.unit.from#] = <cfqueryparam value="#logData[item].OldValue#" cfsqltype="cf_sql_longvarchar">
								</cfquery>
								<cfset logData[item].OldValue = NameOfQoQ.UNITNAME & "(" & NameOfQoQ.UNITCODE & ")">
															
								<cfquery dbtype="query" name="NameOfQoQ">
									select *
									from makeReadable.unit.query
									where [#makeReadable.unit.from#] = <cfqueryparam value="#logData[item].NewValue#" cfsqltype="cf_sql_longvarchar">
								</cfquery>
								<cfset logData[item].NewValue = NameOfQoQ.UNITNAME & "(" & NameOfQoQ.UNITCODE & ")">
							</cfif>	
							
							<!---special case classes--->
							<cfif REFindNoCase("^class\d{0,}_\d{1,}", item) AND structKeyExists(makeReadable,"class")>
								<cfquery dbtype="query" name="NameOfQoQ">
									select *
									from makeReadable.class.query
									where [#makeReadable.class.from#] = <cfqueryparam value="#logData[item].OldValue#" cfsqltype="cf_sql_longvarchar">
								</cfquery>
								<cfset logData[item].OldValue = NameOfQoQ[makeReadable.class.to]>
																						
								<cfquery dbtype="query" name="NameOfQoQ">
									select *
									from makeReadable.class.query
									where [#makeReadable.class.from#] = <cfqueryparam value="#logData[item].NewValue#" cfsqltype="cf_sql_longvarchar">
								</cfquery>
								<cfset logData[item].NewValue = NameOfQoQ[makeReadable.class.to]>
							</cfif>	
							
							<!--- equipment dropdown --->
							<cfif REFindNoCase("^USP_UpdateLoadStop_NEWEQUIPMENTID\d{1,}", item) AND structKeyExists(makeReadable,"equipment")>
								<cfquery dbtype="query" name="NameOfQoQ">
									select *
									from makeReadable.equipment.query
									where [#makeReadable.equipment.from#] = <cfqueryparam value="#logData[item].OldValue#" cfsqltype="cf_sql_longvarchar">
								</cfquery>
								<cfset logData[item].OldValue = NameOfQoQ[makeReadable.equipment.to]>
															
								<cfquery dbtype="query" name="NameOfQoQ">
									select *
									from makeReadable.equipment.query
									where [#makeReadable.equipment.from#] = <cfqueryparam value="#logData[item].NewValue#" cfsqltype="cf_sql_longvarchar">
								</cfquery>
								<cfset logData[item].NewValue = NameOfQoQ[makeReadable.equipment.to]>
								
								<!--- transform --->
								<cfif StructKeyExists(makeReadable.equipment, "transform")>
									<cfset logData[item].FieldLabel = replace(logData[item].FieldLabel, "NEWEQUIPMENTID", makeReadable.equipment.transform)>
								</cfif>
							</cfif>
							
							<!--- Satellite Office dropdown from stop 2 to end --->
							<cfif REFindNoCase("^stOffice\d{1,}", item) AND structKeyExists(makeReadable,"stOffice")>
								<cfquery dbtype="query" name="NameOfQoQ">
									select *
									from makeReadable.stOffice.query
									where [#makeReadable.stOffice.from#] = <cfqueryparam value="#logData[item].OldValue#" cfsqltype="cf_sql_longvarchar">
								</cfquery>
								<cfset logData[item].OldValue = NameOfQoQ[makeReadable.stOffice.to]>
															
								<cfquery dbtype="query" name="NameOfQoQ">
									select *
									from makeReadable.stOffice.query
									where [#makeReadable.stOffice.from#] = <cfqueryparam value="#logData[item].NewValue#" cfsqltype="cf_sql_longvarchar">
								</cfquery>
								<cfset logData[item].NewValue = NameOfQoQ[makeReadable.stOffice.to]>
							</cfif>
							
								
							<!--- Stop and Row --->
							<cfif REFindNoCase("\d{0,}_\d{1,}", item)>
								<cfset objPattern = CreateObject(
									"java",
									"java.util.regex.Pattern"
									).Compile(
										JavaCast( "string", Trim( "(\d{0,})_(\d{1,})" ) )
										)
								/>
								<cfset objMatcher = objPattern.Matcher(
									JavaCast( "string", item )
									) />
								<cfif objMatcher.Find()>
									<cfset fieldLabel = len(objMatcher.Group( JavaCast( "int", 1 ) )) ? "Stop:" & objMatcher.Group( JavaCast( "int", 1 ) ) & ", " : "Stop:1, ">
									<cfset fieldLabel &= len(objMatcher.Group( JavaCast( "int", 2 ) )) ? "Row:" & objMatcher.Group( JavaCast( "int", 2 ) ): "Row:1">
								</cfif>
								<cfset logData[item].FieldLabel = REReplace(item, "\d{0,}_\d{1,}", "") & " " & fieldLabel>
							</cfif>
							<cfqueryparam value="#arguments.loadID#" cfsqltype="cf_sql_nvarchar">,
							<cfqueryparam value="#qGetLoadNumber.LoadNumber#" cfsqltype="cf_sql_bigint">,
							<cfqueryparam value="#logData[item].FieldLabel#" cfsqltype="cf_sql_nvarchar">,
							<cfif structKeyExists(logData[item], "OldValue")>
								<cfqueryparam value="#logData[item].OldValue#" cfsqltype="cf_sql_longvarchar">,
							<cfelse>
								<cfqueryparam value="" cfsqltype="cf_sql_longvarchar">,
							</cfif>
							<cfif structKeyExists(logData[item], "NewValue")>
								<cfqueryparam value="#logData[item].NewValue#" cfsqltype="cf_sql_longvarchar">,
							<cfelse>
								<cfqueryparam value="" cfsqltype="cf_sql_longvarchar">,
							</cfif>								
							<cfqueryparam value="#arguments.updatedUserID#" cfsqltype="cf_sql_nvarchar">,
							<cfqueryparam value="#arguments.updatedUser#" cfsqltype="cf_sql_nvarchar">,
							<cfqueryparam value="#Now()#" cfsqltype="cf_sql_timestamp">
							
							<cfif counter EQ structLength>
								)
							<cfelse>
								),(
							</cfif>							
						</cfif>
						<cfset counter++>
					</cfloop>
				</cfquery>
			<cfcatch type="any">
				<cfdump var="#cfcatch#" />
				<cfabort>
			</cfcatch>
			</cftry>
		</cfif>

	</cffunction>
	
	<cffunction name="clearLoadLog" access="public" returntype="any">
		<cfargument name="days" default="0" required="true" type="numeric">
		
		<cfif arguments.days LTE 0>
			<cfreturn "Invalid Load Log Days Limit. Set value is less than or equal to 0.">
		</cfif>
		
		<cfquery name="deleteLoadLogs" datasource="#application.dsn#" result="qResult">
			Delete from LoadLogs 
			where DATEDIFF(day, UpdatedTimestamp, GETDATE()) > <cfqueryparam value="#arguments.days#" cfsqltype="cf_sql_integer">
		</cfquery>
		<cfreturn 1>
	</cffunction>
	
	<cffunction name="getCurrencies" access="remote" returntype="query">
		<cfargument name="dsn" type="any" required="no"/>
		<cfargument name="IsActive" type="boolean" required="no"/>
	    <cfif isdefined('dsn')>
	    	<cfset activedns = dsn>
	    <cfelse>
	    	<cfset activedns = variables.dsn>
	    </cfif>

		<cfquery name="qGetCurrencies" datasource="#activedns#">
	    	SELECT *
	        FROM Currencies
			<cfif isdefined('arguments.IsActive')>
				WHERE IsActive = 1
			</cfif>
	    </cfquery>
	    <cfreturn qGetCurrencies>
	</cffunction>
	
	<!---BEGIN: Email E-Dispatch URL for Smart Phone --->
	<cffunction name="smartPhoneDispatchLoad" access="remote" returntype="any" returnformat="JSON">
		<cfargument name="dsn" type="string" required="yes">
		<cfargument name="loadID" type="string" required="yes">
		<cfargument name="userid" type="string" required="yes">
	
		<cftry>
			<cfquery name="getLoadDetails" datasource="#arguments.dsn#">
				SELECT  L.LoadID
						,L.LoadNumber
						,C.CarrierName  AS DriverName
						,L.emailList
						,C.CarrierID
						, C.EmailID
				FROM Loads L
				INNER JOIN Carriers C ON C.CarrierID = L.CarrierID
				WHERE L.LoadID = <cfqueryparam value="#arguments.loadID#" cfsqltype="cf_sql_varchar">
			</cfquery>
			
			<cfset GPSDeviceID =DateFormat(Now(),"YYMMDD")&TimeFormat(Now(),"hhmmss")&getLoadDetails.LoadNumber>

			<cfquery name="selectLoadDetails" datasource="#arguments.dsn#">
				SELECT GPSDeviceID from Loads WHERE LoadID = <cfqueryparam value="#arguments.loadID#" cfsqltype="cf_sql_varchar"> 
			</cfquery>
			
			<cfif selectLoadDetails.GPSDeviceID EQ 0 OR NOT len(selectLoadDetails.GPSDeviceID) >
				<cfquery name="updateLoadDetails" datasource="#arguments.dsn#">
					UPDATE Loads SET 
						GPSDeviceID = <cfqueryparam value="#GPSDeviceID#" cfsqltype="cf_sql_varchar"> 
						WHERE LoadID = <cfqueryparam value="#arguments.loadID#" cfsqltype="cf_sql_varchar"> 
				</cfquery>
				<cfset traccerBody = structNew()>
				<cfset traccerBody['uniqueId'] = GPSDeviceID>
				<cfset traccerBody['name'] = arguments.dsn & '-' & getLoadDetails.LoadNumber>

				<cfhttp method="post" url="http://66.201.99.121:2082/api/devices" username="scottw@webersystems.com"
				    password="Wsi2008!" result="objGet">
					<cfhttpparam type="header" name="Content-Type" value="application/json" />
					<cfhttpparam type="body"    value="#SerializeJSON(traccerBody)#"/>
				</cfhttp>

			</cfif>
			<cfreturn "success">
			<cfcatch type="any">
				<cfreturn "failed">
			</cfcatch>
		</cftry>
	</cffunction>
	<!---END: Email E-Dispatch URL for Smart Phone --->
	<!---BEGIN: 771: All Loads/ My Loads must show first shipper and last consignee  --->
	<cffunction name="getFirstShipperDeatils" access="remote" returntype="query">
		<cfargument name="LoadID" type="string" required="yes"/>
		<cfquery name="qGetFirstShipperDeatils" datasource="#variables.dsn#">
			SELECT Top(1) CITY,StateCode 
				FROM LoadStops WHERE loadId = <cfqueryparam value="#arguments.loadID#" cfsqltype="cf_sql_varchar"> AND  StopNo = 0 AND LoadType = 1;
		</cfquery>
		<cfreturn qGetFirstShipperDeatils>
	</cffunction>
	
	<cffunction name="getLastConsineeDeatils" access="remote" returntype="query">
		<cfargument name="LoadID" type="string" required="yes"/>
		<cfquery name="qGetLastConsineeDeatils" datasource="#variables.dsn#">
			SELECT Top(1) CITY,StateCode 
				FROM LoadStops WHERE loadId = <cfqueryparam value="#arguments.loadID#" cfsqltype="cf_sql_varchar"> AND  StopNo =(SELECT MAX(StopNo) FROM LoadStops WHERE LoadID = <cfqueryparam value="#arguments.loadID#" cfsqltype="cf_sql_varchar">) AND LoadType = 2;
		</cfquery>
		<cfreturn qGetLastConsineeDeatils>
	</cffunction>
	<!---END: 771: All Loads/ My Loads must show first shipper and last consignee  --->
	<!-----Get Loads By Advanced Search ---------------->
	<cffunction name="GetLoadBoardDetails" access="public" output="false" returntype="any">
		<cfargument name="PageNo" type="numeric" required="no" />
		<cfargument name="PageSize" type="numeric" required="no" />
		<cfargument name="SortBy" type="string" required="no"/>
		<cfargument name="SortOrder" type="string" required="no"/>
		<cfargument name="IsCustomer" type="string" required="no"/>
		<cfargument name="StatusArg" type="string" required="no"/>

		<cfquery  name="qryGetFreightBrokerStatus" datasource="#variables.dsn#">
			select FreightBroker,LoadsColumnsSetting from SystemConfig WHERE CompanyID = <cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar">
		</cfquery>

		<cfif qryGetFreightBrokerStatus.LoadsColumnsSetting EQ 1 >
			<cfset storPrc = "usp_GetLoadBoardDetails_With_FreightBroker_LoadColumnSettings">
		<cfelse>
			<cfset storPrc = "usp_GetLoadBoardDetails">
		</cfif>

		<CFSTOREDPROC PROCEDURE="#storPrc#" DATASOURCE="#variables.dsn#">
			<cfif structkeyexists(arguments,"PageNo")>
			 	<CFPROCPARAM VALUE="#arguments.PageNo#" cfsqltype="CF_SQL_INTEGER" dbvarname="@PageNo">
			</cfif>
			<cfif structkeyexists(arguments,"PageSize")>
			 	<CFPROCPARAM VALUE="#arguments.PageSize#" cfsqltype="CF_SQL_INTEGER" dbvarname="@PageSize">
			</cfif>
			<cfif structkeyexists(arguments,"SortBy")>
				<CFPROCPARAM VALUE="#arguments.SortBy#" cfsqltype="CF_SQL_VARCHAR" dbvarname="@SortBy">
			</cfif>
			<cfif structkeyexists(arguments,"SortOrder")>
				<CFPROCPARAM VALUE="#arguments.SortOrder#" cfsqltype="CF_SQL_VARCHAR" dbvarname="@SortOrder">
			</cfif>
			<cfif structkeyexists(session,"Currentusertype")>
				<CFPROCPARAM VALUE="#session.Currentusertype#" cfsqltype="CF_SQL_VARCHAR" dbvarname="@Currentusertype">
			</cfif>
			<cfif structkeyexists(session,"EmpID")>
				<CFPROCPARAM VALUE="#session.EmpID#" cfsqltype="CF_SQL_VARCHAR" dbvarname="@EmpID">
			</cfif>
			<cfif structkeyexists(session,"OfficeID")>
				<CFPROCPARAM VALUE="#session.OfficeID#" cfsqltype="CF_SQL_VARCHAR" dbvarname="@OfficeID">
			</cfif>
			<cfif structkeyexists(arguments,"IsCustomer")>
				<CFPROCPARAM VALUE="#arguments.IsCustomer#" cfsqltype="CF_SQL_VARCHAR" dbvarname="@IsCustomer">
			</cfif>
			<cfif structkeyexists(session,"CustomerID")>
				<CFPROCPARAM VALUE="#session.CustomerID#" cfsqltype="CF_SQL_VARCHAR" dbvarname="@LoadCustomerID">
			</cfif>
			<cfif structkeyexists(arguments,"StatusArg")>
				<CFPROCPARAM VALUE="#arguments.StatusArg#" cfsqltype="CF_SQL_VARCHAR" dbvarname="@StatusArg">
			</cfif>
			<CFPROCPARAM VALUE="#session.CompanyID#" cfsqltype="CF_SQL_VARCHAR" dbvarname="@CompanyID">
			<cfif ListContains(session.rightsList,'showAllOfficeLoads',',')>
				<CFPROCPARAM VALUE="1" cfsqltype="CF_SQL_BIT" dbvarname="@showAllOfficeLoads">
			<cfelse>
				<CFPROCPARAM VALUE="0" cfsqltype="CF_SQL_BIT" dbvarname="@showAllOfficeLoads">
			</cfif>
			<cfif ListContains(session.rightsList,'SalesRepLoad',',')>
				<CFPROCPARAM VALUE="1" cfsqltype="CF_SQL_BIT" dbvarname="@SalesRepLoad">
			<cfelse>
				<CFPROCPARAM VALUE="0" cfsqltype="CF_SQL_BIT" dbvarname="@SalesRepLoad">
			</cfif>
		 	<CFPROCRESULT NAME="qryGetLoadBoardDetails">
		</CFSTOREDPROC>
	    <cfreturn qryGetLoadBoardDetails>

	</cffunction>

	<cffunction name="saveCarrierQuote" access="remote" returntype="any" returnformat="JSON">
		<cfargument name="CarrierQuoteID" required="yes" type="numeric"/>
		<cfargument name="LoadID" required="yes" type="string"/>
		<cfargument name="StopNo" required="yes" type="numeric"/>
		<cfargument name="Amount" required="yes" type="numeric"/>
		<cfargument name="CarrierID" required="yes" type="string"/>
		<cfargument name="EquipmentID" required="yes" type="string"/>
		<cfargument name="TruckNo" required="yes" type="string"/>
		<cfargument name="FuelSurcharge" required="yes" type="string"/>
		<cfargument name="TrailerNo" required="yes" type="string"/>
		<cfargument name="ContainerNo" required="yes" type="string"/>
		<cfargument name="RefNo" required="yes" type="string"/>
		<cfargument name="CarrRefNo" required="yes" type="string"/>
		<cfargument name="Miles" required="yes" type="numeric"/>
		<cfargument name="dsn" type="string" required="yes" />
		<cfargument name="Name" required="no" default="" type="string"/>
		<cfargument name="Phone" required="no" default="" type="string"/>
		<cfargument name="Email" required="no" default="" type="string"/>
		<cfargument name="QuoteAmount" required="no" default=0 type="numeric"/>
		<cfargument name="noOfTrips" required="no" default=0  type="numeric"/>
		<cfargument name="Comments" required="no" default="" type="string"/>

		<cfargument name="QCarrierName" required="no" default="" type="string"/>
		<cfargument name="QMCNumber" required="no" default="" type="string"/>
		<cfargument name="QDOTNumber" required="no" default="" type="string"/>
		<cfargument name="QContactPerson" required="no" default="" type="string"/>
		<cfargument name="QCell" required="no" default="" type="string"/>
		<cfargument name="QPhone" required="no" default="" type="string"/>
		<cfargument name="QPhoneExt" required="no" default="" type="string"/>
		<cfargument name="QEmail" required="no" default="" type="string"/>

		<cfargument name="AdminUserName" required="no" default="" type="string"/>
		<cfset local.returnValue = false>

		<cftry>
			<cfif arguments.CarrierQuoteID>
				<cfquery name="qsaveCarrierQuote" datasource="#arguments.dsn#">
					UPDATE LoadCarrierQuotes SET
				    Amount = <cfqueryparam value="#arguments.Amount#" cfsqltype="cf_sql_float">,
					<cfif len(arguments.EquipmentID)>
						EquipmentID = <cfqueryparam value="#arguments.EquipmentID#" cfsqltype="cf_sql_varchar">,
					<cfelse>
						EquipmentID = <cfqueryparam VALUE="" cfsqltype="CF_SQL_VARCHAR" null="true">,
					</cfif>
					TruckNo = <cfqueryparam value="#arguments.TruckNo#" cfsqltype="cf_sql_varchar">,
					FuelSurcharge = <cfqueryparam value="#arguments.FuelSurcharge#" cfsqltype="cf_sql_varchar">,
					TrailerNo = <cfqueryparam value="#arguments.TrailerNo#" cfsqltype="cf_sql_varchar">,
					ContainerNo = <cfqueryparam value="#arguments.ContainerNo#" cfsqltype="cf_sql_varchar">,
					RefNo = <cfqueryparam value="#arguments.RefNo#" cfsqltype="cf_sql_varchar">,
					CarrRefNo =	<cfqueryparam value="#arguments.CarrRefNo#" cfsqltype="cf_sql_varchar">,
					Miles = <cfqueryparam value="#arguments.Miles#" cfsqltype="cf_sql_float">,
					Comments = <cfqueryparam value="#arguments.Comments#" cfsqltype="cf_sql_varchar">,
					ModifiedBy = <cfqueryparam value="#arguments.AdminUserName#" cfsqltype="cf_sql_varchar">,
					LastModifiedDate = getdate()
					WHERE CarrierQuoteID = <cfqueryparam value="#arguments.CarrierQuoteID#" cfsqltype="cf_sql_integer">
				</cfquery>
				<cfset local.returnValue = structNew()>
				<cfset local.returnValue.carrierQuoteID = arguments.CarrierQuoteID>
			<cfelse>
				<cfquery name="qsaveCarrierQuote" datasource="#arguments.dsn#" result="CarrierQuote">
					INSERT INTO LoadCarrierQuotes (LoadID,StopNo,CarrierID,Amount,EquipmentID,TruckNo,FuelSurcharge,TrailerNo,ContainerNo,RefNo,CarrRefNo,Miles,Name,PhoneNo,Email,QuoteAmount,noOfTrips,Comments,QCarrierName,QMCNumber,QDOTNumber,QContactPerson,QCell,QPhone,QPhoneExt,QEmail,QUnknownCarrier,CreatedBy,ModifiedBy)
					VALUES(
						<cfqueryparam value="#arguments.LoadID#" cfsqltype="cf_sql_varchar">,
						<cfqueryparam value="#arguments.StopNo#" cfsqltype="cf_sql_integer">,
						<cfif arguments.CarrierID NEQ 0>
							<cfqueryparam value="#arguments.CarrierID#" cfsqltype="cf_sql_varchar">,
						<cfelse>
							<cfqueryparam value="" cfsqltype="cf_sql_varchar" null="true">,
						</cfif>
						<cfqueryparam value="#arguments.Amount#" cfsqltype="cf_sql_float">,
						<cfif len(arguments.EquipmentID)>
							<cfqueryparam value="#arguments.EquipmentID#" cfsqltype="cf_sql_varchar">,
						<cfelse>
							<cfqueryparam VALUE="" cfsqltype="CF_SQL_VARCHAR" null="true">,
						</cfif>
						<cfqueryparam value="#arguments.TruckNo#" cfsqltype="cf_sql_varchar">,
						<cfqueryparam value="#arguments.FuelSurcharge#" cfsqltype="cf_sql_varchar">,
						<cfqueryparam value="#arguments.TrailerNo#" cfsqltype="cf_sql_varchar">,
						<cfqueryparam value="#arguments.ContainerNo#" cfsqltype="cf_sql_varchar">,
						<cfqueryparam value="#arguments.RefNo#" cfsqltype="cf_sql_varchar">,
						<cfqueryparam value="#arguments.CarrRefNo#" cfsqltype="cf_sql_varchar">,
						<cfqueryparam value="#arguments.Miles#" cfsqltype="cf_sql_float">,
						<cfqueryparam value="#arguments.Name#" cfsqltype="cf_sql_varchar">,
						<cfqueryparam value="#arguments.Phone#" cfsqltype="cf_sql_varchar">,
						<cfqueryparam value="#arguments.Email#" cfsqltype="cf_sql_varchar">,
						<cfqueryparam value="#arguments.QuoteAmount#" cfsqltype="cf_sql_float">,
						<cfqueryparam value="#arguments.noOfTrips#" cfsqltype="cf_sql_integer">,
						<cfqueryparam value="#arguments.Comments#" cfsqltype="cf_sql_varchar">,

						<cfqueryparam value="#arguments.QCarrierName#" cfsqltype="cf_sql_varchar">,
						<cfqueryparam value="#arguments.QMCNumber#" cfsqltype="cf_sql_varchar">,
						<cfqueryparam value="#arguments.QDOTNumber#" cfsqltype="cf_sql_varchar">,
						<cfqueryparam value="#arguments.QContactPerson#" cfsqltype="cf_sql_varchar">,
						<cfqueryparam value="#arguments.QCell#" cfsqltype="cf_sql_varchar">,
						<cfqueryparam value="#arguments.QPhone#" cfsqltype="cf_sql_varchar">,
						<cfqueryparam value="#arguments.QPhoneExt#" cfsqltype="cf_sql_varchar">,
						<cfqueryparam value="#arguments.QEmail#" cfsqltype="cf_sql_varchar">,
						
						<cfif arguments.CarrierID EQ 0>
							<cfqueryparam value="1" cfsqltype="cf_sql_bit">,
						<cfelse>
							<cfqueryparam value="0" cfsqltype="cf_sql_bit">,
						</cfif>
						<cfqueryparam value="#arguments.AdminUserName#" cfsqltype="cf_sql_varchar">,
						<cfqueryparam value="#arguments.AdminUserName#" cfsqltype="cf_sql_varchar">
						)
				</cfquery>
				<cfquery name="qLoadDetails" datasource="#arguments.dsn#" >
					SELECT 
					(SELECT LS.Address + ',' + LS.City + ',' + LS.StateCode FROM LoadStops LS WHERE LS.LoadID = L.LoadID AND LS.LoadType=1 AND LS.StopNo = 0 )  AS Origin,
					(SELECT TOP 1 LS.Address + ',' + LS.City + ',' + LS.StateCode FROM LoadStops LS WHERE LS.LoadID = L.LoadID AND LS.LoadType=2 order BY LS.StopNo DESC )  AS Destination,
					<cfif arguments.CarrierID NEQ 0>
						(SELECT CarrierName FROM Carriers WHERE CarrierID = <cfqueryparam value="#arguments.CarrierID#" cfsqltype="cf_sql_varchar">)
					<cfelse>
						'#arguments.QCarrierName#'
					</cfif> AS Carrier,
					L.CreatedBy 
					FROM Loads L Where L.LoadID = <cfqueryparam value="#arguments.LoadID#" cfsqltype="cf_sql_varchar">
				</cfquery>
				<cfset local.returnValue = structNew()>
				<cfset local.returnValue.carrierQuoteID = CarrierQuote.GENERATEDKEY>
				<cfset local.returnValue.Origin = qLoadDetails.Origin>
				<cfset local.returnValue.Destination = qLoadDetails.Destination>
				<cfset local.returnValue.Carrier = qLoadDetails.Carrier>
				<cfset local.returnValue.User = qLoadDetails.CreatedBy>
			</cfif>
			<cfcatch>
				<cfset local.returnValue = false>
			</cfcatch>
		</cftry>

		<cfreturn local.returnValue>
	</cffunction>

	<cffunction name="getLoadCarrierQuotes" access="public" returntype="any">
		<cfargument name="loadID" required="yes" type="any">

		<cftry>
			<cfquery name="qGetLoadCarrierQuotes" datasource="#variables.dsn#">
		    	SELECT LCQ.*,C.CarrierName,C.MCNumber,C.ContactPerson,C.phone,CASE C.Status WHEN 1 THEN 'Yes' ELSE 'No' END AS Active,E.EquipmentName,C.RiskAssessment,C.Address,C.City,C.statecode,C.Zipcode,C.cel,C.fax,C.EmailID,LCQ.CreatedBy,LCQ.ModifiedBy
				FROM LoadCarrierQuotes LCQ 
				LEFT JOIN Carriers C ON C.CarrierID = LCQ.CarrierID
				LEFT JOIN Equipments E ON E.EquipmentID = LCQ.EquipmentID 
		    	WHERE LCQ.LoadID = <cfqueryparam value="#arguments.LoadID#" cfsqltype="cf_sql_varchar">
			</cfquery>
			<cfcatch>
				<cfset qGetLoadCarrierQuotes.recordcount = 0>
			</cfcatch>
		 </cftry>

		<cfreturn qGetLoadCarrierQuotes>

	</cffunction>

	<cffunction name="getLoadCarrierQuoteDetail" access="remote" returntype="struct" returnformat="JSON">
		<cfargument name="CarrierQuoteID" required="yes" type="any"> 
		<cfargument name="dsn" type="string" required="yes" />
		<cftry>
			<cfquery name="qGetLoadCarrierQuoteDetail" datasource="#arguments.dsn#">
		    	SELECT LCQ.*,C.CarrierName,C.MCNumber,C.ContactPerson,C.phone,CASE C.Status WHEN 1 THEN 'Yes' ELSE 'No' END AS Active,E.EquipmentName,C.RiskAssessment,C.Address,C.City,C.statecode,C.Zipcode,C.cel,C.fax,C.EmailID,C.IsCarrier
				FROM LoadCarrierQuotes LCQ 
				LEFT JOIN Carriers C ON C.CarrierID = LCQ.CarrierID
				LEFT JOIN Equipments E ON E.EquipmentID = LCQ.EquipmentID 
		    	WHERE LCQ.CarrierQuoteID = <cfqueryparam value="#arguments.CarrierQuoteID#" cfsqltype="cf_sql_integer">
			</cfquery>
			<cfcatch>
				<cfset qGetLoadCarrierQuoteDetail.recordcount = 0>
			</cfcatch>
		</cftry>

		<cfset structLoadCarrierQuoteDetail = structNew()>
		<cfloop list="#qGetLoadCarrierQuoteDetail.columnList#" item="key">
			<cfif key eq 'AMOUNT'>
				<cfset structInsert(structLoadCarrierQuoteDetail, key, DollarFormat(qGetLoadCarrierQuoteDetail.Amount))>
			<cfelse>
				<cfset structInsert(structLoadCarrierQuoteDetail, key, qGetLoadCarrierQuoteDetail[key])>
			</cfif>
			
		</cfloop>
	
		<cfreturn structLoadCarrierQuoteDetail>

	</cffunction>

	<cffunction name="getLoadCarrierQuotesReport" access="public" returntype="any">
		<cfargument name="searchText" type="any" required="no">
		<cfargument name="pageNo" required="yes" type="any">
		<cfargument name="rowsperpage" required="no" type="numeric">
		<cfargument name="sortOrder" required="no" type="any">
	    <cfargument name="sortBy" required="no" type="any">
		<cftry>
			<cfquery name="qGetLoadCarrierQuotesReports" datasource="#variables.dsn#">
				WITH page AS (			
					SELECT L.LoadID
					,L.LoadNumber
					,LS.StatusText
					,LS.StatusDescription
					,LS.ColorCode
					,L.NewPickupDate
					,L.CustName
					,(select top 1 CASE  StateCode WHEN NULL THEN city WHEN '0' THEN city ELSE CASE city WHEN NULL THEN StateCode WHEN '' THEN StateCode ELSE city+','+StateCode END END from loadstops  WHERE Loadid = L.LoadID and LoadType = 1  order by stopno ) as FirstStop
					,(select top 1 CASE  StateCode WHEN NULL THEN city WHEN '0' THEN city ELSE CASE city WHEN NULL THEN StateCode WHEN '' THEN StateCode ELSE city+','+StateCode END END from loadstops  WHERE Loadid = L.LoadID and LoadType = 1  order by stopno desc) as LastStop
					,L.TotalCustomerCharges
					,L.TotalCarrierCharges
					,L.EquipmentName As LoadEquipmentName
					,ISNULL(L.TotalCustomerCharges - L.TotalCarrierCharges, 0) AS GrossMargin
					,(SELECT  TOP 1 DESCRIPTION FROM LoadStopCommodities WHERE LoadStopID IN (SELECT LoadStopID FROM LoadStops WHERE LoadStops.LoadID = l.LoadID) AND DESCRIPTION != '' ORDER BY SrNo asc) AS Commodity
					,ROW_NUMBER() OVER (ORDER BY #arguments.sortBy#  #arguments.sortOrder#,LS.StatusText ) AS Row
					FROM Loads L
					LEFT JOIN LoadStatusTypes LS ON LS.StatusTypeID = L.StatusTypeID
					WHERE L.CustomerID in (select customerid from CustomerOffices inner join offices on CustomerOffices.officeid = offices.officeid where offices.companyid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#session.companyid#">)
					AND (SELECT COUNT(LCQ.CarrierQuoteID) FROM LoadCarrierQuotes LCQ WHERE LCQ.LoadID=L.LoadID) <> 0
					<cfif isDefined("arguments.searchText") and len(arguments.searchText)>
					AND (
							L.CustName like <cfqueryparam value="%#arguments.searchText#%" cfsqltype="cf_sql_varchar">
					 	   or LS.StatusText like <cfqueryparam value="%#arguments.searchText#%" cfsqltype="cf_sql_varchar">
						   or L.LoadNumber like <cfqueryparam value="%#arguments.searchText#%" cfsqltype="cf_sql_varchar">
						)
					</cfif>
				)
				SELECT L.*,LCQ.*,C.CarrierName,C.MCNumber,C.ContactPerson,C.phone,CASE C.Status WHEN 1 THEN 'Yes' ELSE 'No' END AS Active,E.EquipmentName FROM page L
				LEFT JOIN  LoadCarrierQuotes LCQ ON LCQ.LoadID = L.LoadID
				LEFT JOIN Carriers C ON C.CarrierID = LCQ.CarrierID
				LEFT JOIN Equipments E ON E.EquipmentID = LCQ.EquipmentID 
				WHERE Row between (#arguments.pageNo# - 1) * #rowsperpage# + 1 and #arguments.pageNo# * #rowsperpage#
				Order by Row
			</cfquery>
			<cfcatch>
				<cfset qGetLoadCarrierQuotesReports.recordcount = 0>
			</cfcatch>
		 </cftry>

		<cfreturn qGetLoadCarrierQuotesReports>

	</cffunction>

	<cffunction name="getActiveLoads" access="remote" returntype="any" returnformat="JSON">
		<cfargument name="LoadNumber" type="numeric" required="no" default="0">
		<cfargument name="companyid" type="string" required="no" default="">
		<cfquery name="qgetActiveLoads" datasource="#trim(listFirst(cgi.SCRIPT_NAME,'/'))#">
	    	SELECT 
	    	LoadID,
			LoadNumber,
			convert(varchar, NewPickupDate, 101) AS ShipDate
			,(SELECT TOP(1) City FROM LoadStops WHERE loadId = L.Loadid  AND  StopNo = 0 AND LoadType = 1) AS ShipCity
			,(SELECT TOP(1) StateCode FROM LoadStops WHERE loadId = L.Loadid  AND  StopNo = 0 AND LoadType = 1) AS ShipState
			,(SELECT Top(1) City FROM LoadStops WHERE loadId = L.Loadid AND  StopNo =(SELECT MAX(StopNo) FROM LoadStops WHERE LoadID = L.Loadid) AND LoadType = 2) AS DeliveryCity
			,(SELECT Top(1) StateCode FROM LoadStops WHERE loadId = L.Loadid AND  StopNo =(SELECT MAX(StopNo) FROM LoadStops WHERE LoadID = L.Loadid) AND LoadType = 2) AS DeliveryState
			,convert(varchar, NewDeliveryDate, 101) AS deliveryDate
			,EquipmentName as TruckType
			,EquipmentID
			,isnull(noOfTrips,0) as noOfTrips
			,carrierNotes
			,L.totalmiles as carriertotalmiles
			FROM Loads L
			LEFT JOIN LoadStatusTypes LS ON LS.StatusTypeID = L.StatusTypeID
			WHERE StatusText='1. ACTIVE'
			<cfif arguments.LoadNumber neq 0>
				AND L.LoadNumber = <cfqueryparam value="#arguments.LoadNumber#" cfsqltype="cf_sql_integer">
			</cfif>
			and L.customerid in (select customerid from CustomerOffices inner join offices on CustomerOffices.officeid = offices.officeid where offices.companyid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.companyid#">)
		</cfquery>
		
		<cfset arrActiveLoads = arrayNew(1)>
		<cfset keyList = qgetActiveLoads.columnList>

		<cfloop query="qgetActiveLoads">
			<cfset temp = structNew()>
			<cfloop list="#keyList#" item="key">
				<cfset structInsert(temp, key, qgetActiveLoads[key][currentrow])>
			</cfloop>
			<cfset arrayAppend(arrActiveLoads, temp)>
		</cfloop>

		<cfreturn arrActiveLoads>

	</cffunction>

	<cffunction name="getCarrierbyMC" access="remote" returntype="any" returnformat="JSON">

		<cfargument name="MCNumber" type="string" required="no" default="0">
		<cfargument name="companyid" type="string" required="no" default="">
		<cfheader name="Access-Control-Allow-Origin" value="*">
		<cfquery name="qgetCarrierbyMC" datasource="#trim(listFirst(cgi.SCRIPT_NAME,'/'))#">
			SELECT CarrierID FROM Carriers WHERE MCNumber = <cfqueryparam value="#arguments.MCNumber#" cfsqltype="cf_sql_varchar"> and companyid = = <cfqueryparam value="#arguments.companyid#" cfsqltype="cf_sql_varchar">
		</cfquery>

		<cfif qgetCarrierbyMC.recordcount>
			<cfset structCarrier = structNew()>
			<cfloop list="#qgetCarrierbyMC.columnList#" item="key">
				<cfset structInsert(structCarrier, key, qgetCarrierbyMC[key])>
			</cfloop>
			<cfreturn structCarrier>
		<cfelse>
			<cfreturn 0>
		</cfif>

	</cffunction>

	<cffunction name="getLoadShippers" access="remote" returntype="any" returnformat="JSON">

		<cfargument name="loadId" type="string" required="no" default="0">
		<cfargument name="dsn" type="string" required="no" default="0">

		<cfquery name="qgetLoadShippers" datasource="#arguments.dsn#">
			SELECT custname,address,city,statecode,postalcode,stopno FROM loadstops WHERE loadid = <cfqueryparam value="#arguments.loadId#" cfsqltype="cf_sql_varchar">
			AND LoadType = 1 ORDER BY stopNo
		</cfquery>
		<cfset resArr = arrayNew(1)>
		<cfloop query="qgetLoadShippers">
			<cfset tempStruct = structNew()>
			<cfset tempStruct.custname = qgetLoadShippers.custname>
			<cfset tempStruct.address = qgetLoadShippers.address>
			<cfset tempStruct.city = qgetLoadShippers.city>
			<cfset tempStruct.statecode = qgetLoadShippers.statecode>
			<cfset tempStruct.postalcode = qgetLoadShippers.postalcode>
			<cfset tempStruct.stopno = qgetLoadShippers.stopno>
			<cfset arrayAppend(resArr, tempStruct)>
		</cfloop>

		<cfreturn resArr>
	</cffunction>

	<cffunction name="getLoadConsignees" access="remote" returntype="any" returnformat="JSON">

		<cfargument name="loadId" type="string" required="no" default="0">
		<cfargument name="dsn" type="string" required="no" default="0">

		<cfquery name="getLoadConsignees" datasource="#arguments.dsn#">
			SELECT custname,address,city,statecode,postalcode,stopno FROM loadstops WHERE loadid = <cfqueryparam value="#arguments.loadId#" cfsqltype="cf_sql_varchar">
			AND LoadType = 2 ORDER BY stopNo
		</cfquery>
		<cfset resArr = arrayNew(1)>
		<cfloop query="getLoadConsignees">
			<cfset tempStruct = structNew()>
			<cfset tempStruct.custname = getLoadConsignees.custname>
			<cfset tempStruct.address = getLoadConsignees.address>
			<cfset tempStruct.city = getLoadConsignees.city>
			<cfset tempStruct.statecode = getLoadConsignees.statecode>
			<cfset tempStruct.postalcode = getLoadConsignees.postalcode>
			<cfset tempStruct.stopno = getLoadConsignees.stopno>
			<cfset arrayAppend(resArr, tempStruct)>
		</cfloop>

		<cfreturn resArr>
	</cffunction>
	
	<cffunction name="scanAPI" access="remote" returntype="string" output="false">

		<cfargument name="companyName" type="string" required="no" default="">
		<cfargument name="macAddress" type="string" required="no" default="">
		<cfargument name="url" type="string" required="no" default="">
		<cfargument name="installDate" type="string" required="no" default="">
		<cfargument name="updateDate" type="string" required="no" default="#dateFormat(now())#">
		
		<cfset var xml = "">
		
		<cfif not len(trim(arguments.companyName))>
			<cfxml variable="xml">
				<response>
					<success>False</success>
					<error>CompanyName Required</error>
				</response>
			</cfxml>
			<cfreturn xml>
		<cfelseif not len(trim(arguments.macAddress))>
			<cfxml variable="xml">
				<response>
					<success>False</success>
					<error>MacAddress Required</error>
				</response>
			</cfxml>
			<cfreturn xml>
		<cfelseif not len(trim(arguments.url))>
			<cfxml variable="xml">
				<response>
					<success>False</success>
					<error>URL Required</error>
				</response>
			</cfxml>
			<cfreturn xml>
		<cfelseif not len(trim(arguments.installDate))>
			<cfxml variable="xml">
				<response>
					<success>False</success>
					<error>InstallDate Required</error>
				</response>
			</cfxml>
			<cfreturn xml>
		<cfelse>
			<cftry>
			
				<cfquery name="qryScanExists" datasource="loadmanageradmin">
					SELECT ID from scanAPI where companyName = <cfqueryparam value="#arguments.companyName#" cfsqltype="cf_sql_varchar">
				</cfquery>
				<cfquery name="insertScan" datasource="loadmanageradmin" result="scanRes">
					<cfif qryScanExists.recordcount>
						UPDATE scanAPI SET 
						URL=<cfqueryparam value="#arguments.url#" cfsqltype="cf_sql_varchar">
						,updateDate=<cfqueryparam value="#arguments.updateDate#" cfsqltype="cf_sql_date">
						WHERE ID = <cfqueryparam value="#qryScanExists.ID#" cfsqltype="cf_sql_varchar">
					<cfelse>
						INSERT INTO scanAPI (companyName,macAddress,url,installDate,updateDate)
						VALUES(
						<cfqueryparam value="#arguments.companyName#" cfsqltype="cf_sql_varchar">
						,<cfqueryparam value="#arguments.macAddress#" cfsqltype="cf_sql_varchar">
						,<cfqueryparam value="#arguments.url#" cfsqltype="cf_sql_varchar">
						,<cfqueryparam value="#arguments.installDate#" cfsqltype="cf_sql_date">
						,<cfqueryparam value="#arguments.updateDate#" cfsqltype="cf_sql_date">
						)
					</cfif>
				</cfquery>
				
				<cfxml variable="xml">
					<response>
						<success>True</success>
					</response>
				</cfxml>
				
				<cfcatch>
					<cfxml variable="xml">
						<response>
							<success>False</success>
							<error>Data insertion failed (#cfcatch.Message#).</error>
						</response>
					</cfxml>
				</cfcatch>
			</cftry>
		</cfif>
		
		<cfreturn xml>
	</cffunction>
	
	<cffunction name="UploadScannedImages" access="remote" returntype="any">

    	<cfargument name="Loadid" type="string" required="yes"/>
		<cfargument name="Description" type="string" required="no" default=""/>
		<cfargument name="Billing" type="string" required="no" default="0"/>
		<cfargument name="UploadedBy" type="string" required="no" default=""/>
		
		<cftry>
			<cfset dsn = trim(listFirst(cgi.SCRIPT_NAME,'/'))>

			<cfquery name="qrygetSettingsForDropBox" datasource="#dsn#">
				SELECT ISNULL(DropBox,0) AS DropBox FROM SystemConfig
			</cfquery>
			<cfquery name="qrygetCommonDropBox" datasource="LoadManagerAdmin">
				SELECT DropBoxAccessToken FROM SystemSetup
			</cfquery>

			<cfif qrygetSettingsForDropBox.DropBox EQ 1 >
				<cfhttp
					method="post"
					url="https://api.dropboxapi.com/2/users/get_current_account"	
					result="returnStruct"> 
						<cfhttpparam type="HEADER" name="Authorization" value="Bearer #qrygetCommonDropBox.DropBoxAccessToken#">
				</cfhttp> 

				<cfif returnStruct.Statuscode EQ "200 OK"> 
					<cfhttp
							method="POST"
							url="https://api.dropboxapi.com/2/files/get_metadata"	
							result="returnStruct"> 
								<cfhttpparam type="HEADER" name="Authorization" value="Bearer #qrygetCommonDropBox.DropBoxAccessToken#">			
								<cfhttpparam type="HEADER" name="Content-Type" value="application/json">			
								<cfhttpparam type="body" value='{"path": "/fileupload/img/#dsn#"}'>			
					</cfhttp>
					<cfif returnStruct.Statuscode NEQ "200 OK"> <!--- Folder Not Found, Create Folder ---->				
						<cfset tmpStruct = {
							 "path" = '/fileupload/img/#dsn#'
							}>
							<cfhttp
									method="post"
									url="https://api.dropboxapi.com/2/files/create_folder"	
									result="returnStructCreateFolder"> 
											<cfhttpparam type="HEADER" name="Authorization" value="Bearer #qrygetCommonDropBox.DropBoxAccessToken#">		
											<cfhttpparam type="HEADER" name="Content-Type" value="application/json">
											 <cfhttpparam type="body" value="#serializeJSON(tmpStruct)#">
							</cfhttp> 						
					</cfif>
					<cfset tmpStruct = {"path":"/fileupload/img/#dsn#/ScannedImage_#dateTimeFormat(now(),'mddYYhhnnssl')#.#IMAGEFORMAT#"
																	,"mode":{".tag":"add"}
																	,"autorename":true}>
					<cffile action = "readbinary" file = "#form.picture#" variable="filcontent">
					<cfhttp
							method="post"
							url="https://content.dropboxapi.com/2/files/upload"	
							result="returnStruct"> 
									<cfhttpparam type="HEADER" name="Authorization" value="Bearer #qrygetCommonDropBox.DropBoxAccessToken#">		
									<cfhttpparam type="HEADER" name="Content-Type" value="application/octet-stream">
									<cfhttpparam type="HEADER" name="Dropbox-API-Arg" value="#serializeJSON(tmpStruct)#">
									<cfhttpparam type="body" value="#filcontent#">
					</cfhttp> 
					<cfset SERVERFILE = DeserializeJSON(returnStruct.Filecontent).name>
				</cfif>
			<cfelse>
				<cffile action="upload" filefield="picture" destination="#ExpandPath('..\fileupload\img\')#ScannedImage.#IMAGEFORMAT#" nameConflict="MakeUnique" result=uploadedFile>
				<cfset SERVERFILE = uploadedFile.SERVERFILE>
			</cfif>
			
			<cfquery name="qryInsDoc" datasource="#trim(listFirst(cgi.SCRIPT_NAME,'/'))#">
				INSERT INTO FileAttachments(linked_id,linked_to,attachedFileLabel,attachmentFileName,Billingattachments,UploadedDateTime,UploadedBy,DropBoxFile)

				VALUES(
					<cfqueryparam value="#form.Loadid#" cfsqltype="cf_sql_varchar">
					,<cfqueryparam value=1 cfsqltype="cf_sql_integer">
					,<cfqueryparam value="#arguments.Description#" cfsqltype="cf_sql_varchar">
					,<cfqueryparam value="#SERVERFILE#" cfsqltype="cf_sql_varchar">
					,<cfqueryparam value="#arguments.Billing#" cfsqltype="cf_sql_bit">
					,<cfqueryparam value="#dateFormat(now())#" cfsqltype="cf_sql_date">
					,<cfqueryparam value="#form.UserUploaded#" cfsqltype="cf_sql_varchar">
					,<cfqueryparam value="#qrygetSettingsForDropBox.DropBox#" cfsqltype="cf_sql_varchar">
				)
			</cfquery>
			
			<cfcatch>
				<cfdump var="#cfcatch#"><cfabort>
			</cfcatch>	
		</cftry>
	</cffunction>

	<cffunction name="checkDriverFuelCardConflict" access="remote"  output="yes" returntype="boolean" returnformat="json">
	    <cfargument name="dsn" type="string" required="yes">
	    <cfargument name="CarrierID" type="string" required="yes">
	    <cfargument name="fuelCardNo" type="string" required="yes">
	    <cfargument name="CompanyID" type="string" required="yes">

	    <cfquery name="qryCheckDriverFuelCardConflict" datasource="#arguments.dsn#">
	      SELECT count(CarrierID) as conflictCount FROM Carriers WHERE fuelCardNo = <cfqueryparam value="#arguments.fuelCardNo#" cfsqltype="cf_sql_varchar"> 
	      <cfif arguments.CarrierID NEQ 0>
	        AND CarrierID <> <cfqueryparam value="#arguments.CarrierID#" cfsqltype="cf_sql_varchar">
	      </cfif>
	      AND CompanyID = <cfqueryparam value="#arguments.CompanyID#" cfsqltype="cf_sql_varchar">
	    </cfquery>

	    <cfif qryCheckDriverFuelCardConflict.conflictCount>
	      <cfreturn 1>
	    <cfelse>
	      <cfreturn 0>
	    </cfif>
	</cffunction>

	<cffunction name="fuelCardFileDownload" access="remote"  output="yes" >
		<cfset masterPath = expandPath('../../../FuelFiles')>
		<cfdirectory action = "list" directory = "#masterPath#" name = "fileList">
		<cfloop query="fileList">
			<cfset fileName = fileList.name>
			<cffile action = "delete" file = "#masterPath#/#fileName#" >
		</cfloop>
		<cfftp action = "open" username = "IB781" connection = "ftpCon"	password = "Rm3dH4##t" port = "10022" server = "ftp.iconnectdata.com" secure = "yes" result="openConn"> 
		<cfif openConn.succeeded>
			<cfftp action="listdir" directory="/IB781" connection="ftpCon" name="fileList">
			<cfloop query="fileList">
				<cfset fileName = fileList.name>
				<cfftp action="getFile" connection="ftpCon" remotefile="/IB781/#fileName#" 
				localfile="#masterPath#/#fileName#.txt" timeout="3000" failIfExists="no">
			</cfloop>
			<cfftp action="close" connection="ftpCon"/>
		</cfif> 
	</cffunction>


	<cffunction name="fuelCardIntegration" access="remote"  output="yes" >
		<cfif not directoryExists(expandPath('../Fuel'))>
			<cfset directoryCreate(expandPath('../Fuel'))>
		</cfif>

		<cfset fileNameList = "">
		<cfset masterPath = expandPath('../../../FuelFiles/')>
		<cfdirectory action = "list" directory = "#masterPath#" name = "fileList">

		<cfquery name="qGetComDataSystemSettings" datasource="#trim(listFirst(cgi.SCRIPT_NAME,'/'))#">
			select ComDataUnitID,ComDataCustomerID from SystemConfig
		</cfquery>
		<cfset UnitID = qGetComDataSystemSettings.ComDataUnitID>
		<cfloop query="fileList">
			<cfset fileName = fileList.name>
			<cffile action = "copy" source = "#masterPath##fileName#" destination = "#expandPath('../Fuel')#/#fileName#">
			<cfset fileNameList = ListAppend(fileNameList,fileList.name)> 
		</cfloop>

		<cfif listLen(fileNameList)>
			<cfloop list="#fileNameList#" item="fileName">
				<cfif ListGetAt(fileName,2,'.') EQ qGetComDataSystemSettings.ComDataCustomerID>
					<cfset noOfLoadsUpdatedForFile = 0>
					<cfloop file="#expandPath('../Fuel')#/#fileName#" index="fuel">
						<cfif mid(fuel,1,2) EQ '01'>
							<cfset fuelcardno = mid(fuel,195,10)>
							<cfset purchaseDate = dateformat(Insert("/", Insert("/", mid(fuel,12,6), 2), 5))>

							<cfquery name="qgetLoadStop" datasource="#trim(listFirst(cgi.SCRIPT_NAME,'/'))#">
								SELECT TOP 1 LoadStops.LoadID,LoadStops.LoadStopID,
								ISNULL((SELECT MAX(LSC.SrNo) FROM LoadStopCommodities LSC WHERE LSC.LoadStopID = LoadStops.LoadStopID),0)+1 AS SrNo
							    ,ISNULL((SELECT TotalCarrierCharges FROM LOADS WHERE loadid = LoadStops.loadid),0) as TotalCarrierCharges
								,ISNULL((SELECT totalProfit FROM LOADS WHERE loadid = LoadStops.loadid),0) as totalProfit
								,LoadStops.StopDate
								,(SELECT loadnumber FROM LOADS WHERE loadid = LoadStops.loadid) AS loadnumber

								FROM LoadStops 
								left join loadstops b on b.LoadID = LoadStops.LoadID and b.LoadType = 2 and LoadStops.stopNO = b.StopNo 
								where LoadStops.StopDate <= <cfqueryparam value="#purchaseDate#" cfsqltype="cf_sql_date"> AND 
								b.StopDate >= <cfqueryparam value="#purchaseDate#" cfsqltype="cf_sql_date"> AND
								LoadStops.NewCarrierID IN (SELECT CarrierID FROM Carriers WHERE fuelCardNo = <cfqueryparam value="#fuelcardno#" cfsqltype="cf_sql_varchar"> 
						) AND LoadStops.LoadType=1 
								AND (select statustext from LoadStatusTypes where statustypeid in 
									(select statustypeid from loads WHERE loadid = LoadStops.loadid))  
									between '1. ACTIVE' AND '8. COMPLETED'
								order by LoadStops.StopDate desc
							</cfquery> 

							<cfif qgetLoadStop.recordcount>
								<cfset TotalGallons = mid(fuel,90,5)>
								<cfset GallonsPPP = mid(fuel,95,5)>
								<cfset FuelCardAmount = mid(fuel,100,5)>
								<cfset CashAdvance = mid(fuel,131,5)>
								<cfset fuelupd = 0>
								<cfif FuelCardAmount GT 0>
									<cfset TotalGallons = (TotalGallons/100)>
									<cfset GallonsPPP = (GallonsPPP/1000)>
									<cfset CarrierCharges = (FuelCardAmount/100)>
									<cfset TotalCarrierCharges = qgetLoadStop.TotalCarrierCharges+CarrierCharges>
									<cfset TotalProfit = qgetLoadStop.TotalProfit - CarrierCharges>
									<cfif TotalProfit lt 0>
										<cfset TotalProfit = 0>
									</cfif>
									<cfquery name="qinsLoadStopCommodities" datasource="#trim(listFirst(cgi.SCRIPT_NAME,'/'))#">
										INSERT INTO LoadStopCommodities(LoadStopID,SrNo,Qty,UnitID,Description,Weight,CustCharges,CarrCharges,Fee,CustRate,CarrRate,CarrRateOfCustTotal) VALUES(
										<cfqueryparam value="#qgetLoadStop.LoadStopID#" cfsqltype="cf_sql_varchar">,
										<cfqueryparam value="#qgetLoadStop.SrNo#" cfsqltype="cf_sql_integer">,
										<cfqueryparam value="1" cfsqltype="cf_sql_float">,
										<cfqueryparam value="#UnitID#" cfsqltype="cf_sql_varchar">,
										<cfqueryparam value="ComData-Fuel,Gallons:#TotalGallons#,PPG:$#GallonsPPP#" cfsqltype="cf_sql_varchar">,
										<cfqueryparam value="0" cfsqltype="cf_sql_float">,
										<cfqueryparam value="0" cfsqltype="cf_sql_money">,
										<cfqueryparam value="#CarrierCharges#" cfsqltype="cf_sql_money">,
										<cfqueryparam value="0" cfsqltype="cf_sql_bit">,
										<cfqueryparam value="0" cfsqltype="cf_sql_decimal">,
										<cfqueryparam value="#CarrierCharges#" cfsqltype="cf_sql_float">,
										<cfqueryparam value="0" cfsqltype="cf_sql_decimal">
										)
									</cfquery>
									<cfquery name="qupdLoadCharges" datasource="#trim(listFirst(cgi.SCRIPT_NAME,'/'))#">
										UPDATE LOADS SET 
										TotalCarrierCharges = <cfqueryparam value="#TotalCarrierCharges#" cfsqltype="cf_sql_float">,
										TotalProfit = <cfqueryparam value="#TotalProfit#" cfsqltype="cf_sql_money">
										WHERE LoadID = <cfqueryparam value="#qgetLoadStop.LoadID#" cfsqltype="cf_sql_varchar">
									</cfquery>
									<cfquery name="qLnsLoadLog" datasource="#trim(listFirst(cgi.SCRIPT_NAME,'/'))#">
										INSERT INTO LoadComDataLogs(LoadID,LoadNumber,Description,FuelPurchaseDate,StopDate,Amount,FilePath,FuelCardNo)
										VALUES(
											<cfqueryparam value="#qgetLoadStop.LoadID#" cfsqltype="cf_sql_varchar">
											,<cfqueryparam value="#qgetLoadStop.LoadNumber#" cfsqltype="cf_sql_integer">
											,<cfqueryparam value="ComData-Fuel Purchase" cfsqltype="cf_sql_varchar">
											,<cfqueryparam value="#purchaseDate#" cfsqltype="cf_sql_date">
											,<cfqueryparam value="#qgetLoadStop.StopDate#" cfsqltype="cf_sql_date">
											,<cfqueryparam value="#CarrierCharges#" cfsqltype="cf_sql_float">
											,<cfqueryparam value="#fileName#" cfsqltype="cf_sql_varchar">
											,<cfqueryparam value="#FuelCardNo#" cfsqltype="cf_sql_varchar">
											)
									</cfquery>
									<cfset fuelupd = 1>
									<cfset noOfLoadsUpdatedForFile++>
								</cfif>

								<cfif CashAdvance gt 0>
									<cfset CarrierCharges = (CashAdvance/100)>
									<cfif fuelupd eq 0>
										<cfset TotalCarrierCharges = qgetLoadStop.TotalCarrierCharges-CarrierCharges>
										<cfset TotalProfit = qgetLoadStop.TotalProfit + CarrierCharges>
										<cfif TotalCarrierCharges lt 0>
											<cfset TotalCarrierCharges = 0>
										</cfif>	
										<cfset srNo = qgetLoadStop.SrNo>
									<cfelse>
										<cfset TotalCarrierCharges = TotalCarrierCharges-CarrierCharges>
										<cfset TotalProfit = TotalProfit + CarrierCharges>
										<cfif TotalCarrierCharges lt 0>
											<cfset TotalCarrierCharges = 0>
										</cfif>	
										<cfset srNo = qgetLoadStop.SrNo+1>
									</cfif>
									<cfset CarrierCharges =(CarrierCharges * -1)>
									<cfquery name="qinsLoadStopCommodities" datasource="#trim(listFirst(cgi.SCRIPT_NAME,'/'))#">
										INSERT INTO LoadStopCommodities(LoadStopID,SrNo,Qty,UnitID,Description,Weight,CustCharges,CarrCharges,Fee,CustRate,CarrRate,CarrRateOfCustTotal) VALUES(
										<cfqueryparam value="#qgetLoadStop.LoadStopID#" cfsqltype="cf_sql_varchar">,
										<cfqueryparam value="#SrNo#" cfsqltype="cf_sql_integer">,
										<cfqueryparam value="1" cfsqltype="cf_sql_float">,
										<cfqueryparam value="#UnitID#" cfsqltype="cf_sql_varchar">,
										<cfqueryparam value="ComData-CashAdvance" cfsqltype="cf_sql_varchar">,
										<cfqueryparam value="0" cfsqltype="cf_sql_float">,
										<cfqueryparam value="0" cfsqltype="cf_sql_money">,
										<cfqueryparam value="#CarrierCharges#" cfsqltype="cf_sql_money">,
										<cfqueryparam value="0" cfsqltype="cf_sql_bit">,
										<cfqueryparam value="0" cfsqltype="cf_sql_decimal">,
										<cfqueryparam value="#CarrierCharges#" cfsqltype="cf_sql_float">,
										<cfqueryparam value="0" cfsqltype="cf_sql_decimal">
										)
									</cfquery>
									<cfquery name="qupdLoadCharges" datasource="#trim(listFirst(cgi.SCRIPT_NAME,'/'))#">
										UPDATE LOADS SET 
										TotalCarrierCharges = <cfqueryparam value="#TotalCarrierCharges#" cfsqltype="cf_sql_float">,
										TotalProfit = <cfqueryparam value="#TotalProfit#" cfsqltype="cf_sql_money">
										WHERE LoadID = <cfqueryparam value="#qgetLoadStop.LoadID#" cfsqltype="cf_sql_varchar">
									</cfquery>
									<cfquery name="qLnsLoadLog" datasource="#trim(listFirst(cgi.SCRIPT_NAME,'/'))#">
										INSERT INTO LoadComDataLogs(LoadID,LoadNumber,Description,FuelPurchaseDate,StopDate,Amount,filePath,FuelCardNo)
										VALUES(
											<cfqueryparam value="#qgetLoadStop.LoadID#" cfsqltype="cf_sql_varchar">
											,<cfqueryparam value="#qgetLoadStop.LoadNumber#" cfsqltype="cf_sql_integer">
											,<cfqueryparam value="ComData-CashAdvance" cfsqltype="cf_sql_varchar">
											,<cfqueryparam value="#purchaseDate#" cfsqltype="cf_sql_date">
											,<cfqueryparam value="#qgetLoadStop.StopDate#" cfsqltype="cf_sql_date">
											,<cfqueryparam value="#CarrierCharges#" cfsqltype="cf_sql_float">
											,<cfqueryparam value="#fileName#" cfsqltype="cf_sql_varchar">
											,<cfqueryparam value="#FuelCardNo#" cfsqltype="cf_sql_varchar">
											)
									</cfquery>
									<cfset noOfLoadsUpdatedForFile++>
								</cfif>
							<cfelse>
							
							<cfquery name="qLnsLoadLog" datasource="#trim(listFirst(cgi.SCRIPT_NAME,'/'))#">
							INSERT INTO LoadComDataLogs(LoadID,LoadNumber,Description,FuelPurchaseDate,StopDate,Amount,filePath,FuelCardNo)
							VALUES(
								<cfqueryparam value="None" cfsqltype="cf_sql_varchar">
								,<cfqueryparam value=0 cfsqltype="cf_sql_integer">
								,<cfqueryparam value="None" cfsqltype="cf_sql_varchar">
								,<cfqueryparam value="#purchaseDate#" cfsqltype="cf_sql_date">
								,<cfqueryparam value="#dateFormat(now())#" cfsqltype="cf_sql_date">
								,<cfqueryparam value="0" cfsqltype="cf_sql_float">
								,<cfqueryparam value="#fileName#" cfsqltype="cf_sql_varchar">
								,<cfqueryparam value="#FuelCardNo#" cfsqltype="cf_sql_varchar">
								)
						</cfquery>
							</cfif>
						</cfif>
					</cfloop>
					<cfif noOfLoadsUpdatedForFile eq 0>
						<cfquery name="qLnsLoadLog" datasource="#trim(listFirst(cgi.SCRIPT_NAME,'/'))#">
							INSERT INTO LoadComDataLogs(LoadID,LoadNumber,Description,FuelPurchaseDate,StopDate,Amount,filePath,FuelCardNo)
							VALUES(
								<cfqueryparam value="None" cfsqltype="cf_sql_varchar">
								,<cfqueryparam value=0 cfsqltype="cf_sql_integer">
								,<cfqueryparam value="None" cfsqltype="cf_sql_varchar">
								,<cfqueryparam value="#purchaseDate#" cfsqltype="cf_sql_date">
								,<cfqueryparam value="#dateFormat(now())#" cfsqltype="cf_sql_date">
								,<cfqueryparam value="0" cfsqltype="cf_sql_float">
								,<cfqueryparam value="#fileName#" cfsqltype="cf_sql_varchar">
								,<cfqueryparam value="#FuelCardNo#" cfsqltype="cf_sql_varchar">
								)
						</cfquery>
					</cfif>
				<cfelse>
					<cfquery name="qLnsLoadLog" datasource="#trim(listFirst(cgi.SCRIPT_NAME,'/'))#">
						INSERT INTO LoadComDataLogs(LoadID,LoadNumber,Description,FuelPurchaseDate,StopDate,Amount,filePath,FuelCardNo)
						VALUES(
							<cfqueryparam value="None" cfsqltype="cf_sql_varchar">
							,<cfqueryparam value=0 cfsqltype="cf_sql_integer">
							,<cfqueryparam value="None" cfsqltype="cf_sql_varchar">
							,<cfqueryparam value="#purchaseDate#" cfsqltype="cf_sql_date">
							,<cfqueryparam value="#dateFormat(now())#" cfsqltype="cf_sql_date">
							,<cfqueryparam value="0" cfsqltype="cf_sql_float">
							,<cfqueryparam value="#fileName#" cfsqltype="cf_sql_varchar">
							,<cfqueryparam value="#FuelCardNo#" cfsqltype="cf_sql_varchar">
							)
					</cfquery>
				</cfif>
			</cfloop>
		</cfif>
	</cffunction>

	<cffunction name="getLoadLock" access="public" returntype="query">
		<cfargument name="LoadID" required="yes" type="string">
		<cfquery name="qLoadLock" datasource="#variables.dsn#">
	    	SELECT IsLocked
	        FROM Loads
	        WHERE LoadID = <cfqueryparam value="#arguments.LoadID#" cfsqltype="cf_sql_varchar">
	    </cfquery>
	    <cfreturn qLoadLock>
	</cffunction>

	<cffunction name="getAjaxLoadLock" access="remote"  output="yes" returntype="string" returnformat="json">
		<cfargument name="LoadID" required="yes" type="string">
		<cfargument name="dsn" required="yes" type="string">

		<cfquery name="qLoadLock" datasource="#arguments.dsn#">
	    	SELECT IsLocked
	        FROM Loads
	        WHERE LoadID = <cfqueryparam value="#arguments.LoadID#" cfsqltype="cf_sql_varchar">
	    </cfquery>

	    <cfreturn qLoadLock.IsLocked>
	</cffunction>

	<cffunction name="setAjaxLoadLock" access="remote"  output="yes" returntype="string" returnformat="json">
		<cfargument name="LoadID" required="yes" type="string">
		<cfargument name="dsn" required="yes" type="string">

		<cfquery name="qLoadLock" datasource="#arguments.dsn#">
	        UPDATE Loads SET IsLocked = 1
	        WHERE LoadID = <cfqueryparam value="#arguments.LoadID#" cfsqltype="cf_sql_varchar">
	    </cfquery>

	    <cfreturn 'Locked'>
	</cffunction>

	<cffunction name="ajaxLoadUnLock" access="remote"  output="yes" returntype="string" returnformat="json">
		<cfargument name="LoadID" required="yes" type="string">
		<cfargument name="dsn" required="yes" type="string">

		<cfquery name="qLoadLock" datasource="#arguments.dsn#">
	        UPDATE Loads SET IsLocked = 0
	        WHERE LoadID = <cfqueryparam value="#arguments.LoadID#" cfsqltype="cf_sql_varchar">
	    </cfquery>

	    <cfreturn 'UnLocked'>
	</cffunction>

	<cffunction name="delRowCommodities" access="remote"  output="yes" returntype="string" returnformat="json">
		<cfargument name="loadstopCommid" required="yes" type="string">
		<cfargument name="srNo" required="yes" type="string">
		<cfargument name="dsn" required="yes" type="string">

		<cfargument name="LoadId" required="yes" type="string">
		<cfargument name="LoadNumber" required="yes" type="string">
		<cfargument name="UpdatedByUserID" required="yes" type="string">
		<cfargument name="UpdatedBy" required="yes" type="string">
		<cfargument name="stopNo" required="yes" type="string">
		<cfargument name="description" required="yes" type="string">

		<cfquery name="qGetLoadStop" datasource="#arguments.dsn#">
			SELECT LoadStopID AS ID FROM LoadStopCommodities WHERE LoadStopCommoditiesID = <cfqueryparam value="#arguments.loadstopCommid#" cfsqltype="cf_sql_varchar">
		</cfquery>

		<cfquery name="qdelRowCommodities" datasource="#arguments.dsn#">
	        DELETE FROM LoadStopCommodities
	        WHERE LoadStopCommoditiesID = <cfqueryparam value="#arguments.loadstopCommid#" cfsqltype="cf_sql_varchar">
	    </cfquery>

	    <cfif len(trim(qGetLoadStop.ID))>
		    <cfquery name="qupdRowCommodities" datasource="#arguments.dsn#">
		    	UPDATE LoadStopCommodities SET srNo = srNo - 1
		    	WHERE loadstopid = <cfqueryparam value="#qGetLoadStop.ID#" cfsqltype="cf_sql_varchar">
		        AND srNo > <cfqueryparam value="#arguments.srNo#" cfsqltype="cf_sql_integer"> 
		    </cfquery>
		</cfif>
	    <cfif not len(trim(arguments.stopNo))>
	    	<cfset arguments.stopNo = 1>
	    </cfif>

	    <cfquery name="qryCreateUnlockedLog" datasource="#arguments.dsn#" >
			INSERT INTO LoadLogs (LoadID,LoadNumber,FieldLabel,Oldvalue,NewValue,UpdatedByUserID,UpdatedBy,UpdatedTimestamp,UpdatedByIP)
			VALUES(
				<cfqueryparam value="#arguments.loadid#" cfsqltype="cf_sql_nvarchar">,
				<cfqueryparam value="#arguments.loadnumber#" cfsqltype="cf_sql_bigint">,
				<cfqueryparam value="STOPNO:#arguments.stopNo#-LINENO:#arguments.srNo#" cfsqltype="cf_sql_nvarchar">,
				<cfqueryparam value="#arguments.description#" cfsqltype="cf_sql_nvarchar">,
				<cfqueryparam value="DELETED" cfsqltype="cf_sql_nvarchar">,
				<cfqueryparam value="#arguments.UpdatedByUserID#" cfsqltype="cf_sql_nvarchar">,
				<cfqueryparam value="#arguments.UpdatedBy#" cfsqltype="cf_sql_nvarchar">,
				<cfqueryparam value="#Now()#" cfsqltype="cf_sql_timestamp">,
				<cfqueryparam value="#cgi.REMOTE_ADDR#" cfsqltype="cf_sql_nvarchar">
				)
		</cfquery>

	    <cfreturn 'Deleted'>
	</cffunction>

	<cffunction name="edi204LoadImport" access="remote"  output="yes" >
		<cfset dsn = trim(listFirst(cgi.SCRIPT_NAME,'/'))>
		<cfset doctype='204'>
		<cfset resultStruct ={}>
		<cfif structKeyExists(cgi,'REMOTE_ADDR') and cgi.REMOTE_ADDR NEQ "127.0.0.1">
			Aborted<cfabort>
		</cfif>
		<cftry>
			<cfquery name="qgetCompany" datasource="#dsn#">
				SELECT TOP 1 CompanyID FROM [Companies]
			</cfquery>
			
			<cfquery name="qgetEDILoadStatus" datasource="#dsn#">
				SELECT EDIloadStatus, AutomaticFactoringFee, FactoringFee FROM SystemConfig
			</cfquery>

			<cfquery name="qgetEDILoads" datasource="#dsn#">
				SELECT  EDI204.lm_Loads_BOL
				  ,EDI204.receiverID
			      ,EDI204.lm_EDISetup_SCAC
			      ,EDI204.lm_Customers_CustomerCode
			      ,EDI204.ShipmentMethodOfPayment
			      ,EDI204.PurposeCode
			      ,EDI204.NoteReferenceCode
			      ,EDI204.lm_Loads_NewNotes
			      ,EDI204.EquipmentNumber
			      ,EDI204.lm_Equipments_EquipmentCode
			      ,EDI204.lm_Equipments_Length
			      ,EDI204.Imported
				  ,EDI204Stops.lm_LoadStops_StopNo
			      ,EDI204Stops.lm_LoadStops_LoadType
			      ,EDI204Stops.lm_LoadStopCommodities_Weight
			      ,EDI204Stops.WeightUnitCode
			      ,EDI204Stops.VolumeUnitQualifier
			      ,EDI204Stops.lm_LoadStops_StopDateQ
			      ,EDI204Stops.lm_LoadStops_StopDate
			      ,EDI204Stops.lm_LoadStops_StopTimeQ
			      ,EDI204Stops.lm_LoadStops_StopTime
			      ,EDI204Stops.lm_LoadStopCommodities_Qty
			      ,EDI204Stops.NoteReferenceCode2
			      ,EDI204Stops.lm_LoadStops_Miles
			      ,EDI204Stops.EntityIdentityCode
			      ,EDI204Stops.Name
			      ,EDI204Stops.IdentityCodeQ
			      ,EDI204Stops.IdentityCode
			      ,EDI204Stops.lm_LoadStops_Address
			      ,EDI204Stops.lm_LoadStops_City
			      ,EDI204Stops.lm_LoadStops_StateCode
			      ,EDI204Stops.lm_LoadStops_PostalCode
			      ,EDI204Stops.CountryCode
			      ,EDI204Stops.ContactFunctionCode
			      ,EDI204Stops.lm_LoadStops_ContactPerson
			      ,EDI204Stops.CommNumberQ
			      ,EDI204Stops.CommNumber
			      ,EDI204Stops.lm_loads_CustomerPONo
			      ,EDI204Stops.lm_LoadStopCommodities_Description
			      ,EDI204Stops.lm_LoadStopCommodities_Qty2
			      ,EDI204Stops.LadingDesc
	   			FROM Edi204 
				LEFT JOIN Edi204stops ON  Edi204.lm_Loads_BOL = Edi204stops.lm_Loads_BOL 
				WHERE Imported = 0 
				GROUP BY  EDI204.lm_Loads_BOL
				  ,EDI204.receiverID
			      ,EDI204.lm_EDISetup_SCAC
			      ,EDI204.lm_Customers_CustomerCode
			      ,EDI204.ShipmentMethodOfPayment
			      ,EDI204.PurposeCode
			      ,EDI204.NoteReferenceCode
			      ,EDI204.lm_Loads_NewNotes
			      ,EDI204.EquipmentNumber
			      ,EDI204.lm_Equipments_EquipmentCode
			      ,EDI204.lm_Equipments_Length
			      ,EDI204.Imported
				  ,EDI204Stops.lm_LoadStops_StopNo
			      ,EDI204Stops.lm_LoadStops_LoadType
			      ,EDI204Stops.lm_LoadStopCommodities_Weight
			      ,EDI204Stops.WeightUnitCode
			      ,EDI204Stops.VolumeUnitQualifier
			      ,EDI204Stops.lm_LoadStops_StopDateQ
			      ,EDI204Stops.lm_LoadStops_StopDate
			      ,EDI204Stops.lm_LoadStops_StopTimeQ
			      ,EDI204Stops.lm_LoadStops_StopTime
			      ,EDI204Stops.lm_LoadStopCommodities_Qty
			      ,EDI204Stops.NoteReferenceCode2
			      ,EDI204Stops.lm_LoadStops_Miles
			      ,EDI204Stops.EntityIdentityCode
			      ,EDI204Stops.Name
			      ,EDI204Stops.IdentityCodeQ
			      ,EDI204Stops.IdentityCode
			      ,EDI204Stops.lm_LoadStops_Address
			      ,EDI204Stops.lm_LoadStops_City
			      ,EDI204Stops.lm_LoadStops_StateCode
			      ,EDI204Stops.lm_LoadStops_PostalCode
			      ,EDI204Stops.CountryCode
			      ,EDI204Stops.ContactFunctionCode
			      ,EDI204Stops.lm_LoadStops_ContactPerson
			      ,EDI204Stops.CommNumberQ
			      ,EDI204Stops.CommNumber
			      ,EDI204Stops.lm_loads_CustomerPONo
			      ,EDI204Stops.lm_LoadStopCommodities_Description
			      ,EDI204Stops.lm_LoadStopCommodities_Qty2
			      ,EDI204Stops.LadingDesc
				  ORDER BY Edi204.lm_Loads_BOL,edi204stops.lm_LoadStops_LoadType,edi204stops.lm_LoadStops_StopNo
			</cfquery>

			<cfset CompanyID = qgetCompany.CompanyID>
			<cfset StatusTypeID = qgetEDILoadStatus.EDIloadStatus>
			<cfif qgetEDILoadStatus.AutomaticFactoringFee eq 1>
				<cfset FF = qgetEDILoadStatus.FactoringFee>
			<cfelse>
				<cfset FF = 0>
			</cfif>
			<cfset local.lm_Loads_BOL = "">
			<cfset local.lm_Customers_CustomerCode = "">
			<cfset ediPartnerMissing = "">
			<cfset ediLoadsImported = 0>
			<cfset importedLoadIds ="">
			<cfset local.previousLoadType = "">
			<cfset local.noShipper = "">
			
			<cfloop query="qgetEDILoads">
				<cfquery name="getEdiPartner" datasource="#dsn#">
					SELECT receiverID,C.CustomerID,C.AcctMGRID,C.SalesRepID,C.CarrierNotes FROM EDICustomerIDMapping 
					EDICUS INNER JOIN Customers C
					ON c.CustomerID = EDICUS.lm_Customers_CustomerCode Where receiverID = <cfqueryparam value="#qgetEDILoads.receiverID#" cfsqltype="cf_sql_varchar"> 
				</cfquery>
				

				<cfif getEdiPartner.recordcount GT 0 >
					
				<cfif (local.lm_Loads_BOL NEQ qgetEDILoads.lm_Loads_BOL )>

					<cfset loadNumberflag = true/>
					<cfloop condition="loadNumberflag EQ true"> 
						<cfquery name="qmaxloadNumber" datasource="#dsn#">
	                        SELECT LoadNumber=[MinimumLoadStartNumber] FROM SystemConfig
	                    </cfquery>
	                    <cfquery name="Updateloadmanual" datasource="#dsn#">
	                        update SystemConfig set MinimumLoadStartNumber=MinimumLoadStartNumber+1
	                    </cfquery>
	                    <!--- Check load number is exists or not --->
	                    <cfquery name="qCheckLoadNumExists" datasource="#dsn#">
						 	SELECT LoadID from loads where LoadNumber = #qmaxloadNumber.LoadNumber#+1
						</cfquery>
	                    <cfif qCheckLoadNumExists.recordcount EQ 0>
	                   		<cfset loadNumberflag = false />
	                    </cfif>
	                </cfloop>

					<cfset LoadNumber = qmaxloadNumber.LoadNumber+1>
					<cfset BOLNum = qgetEDILoads.lm_Loads_BOL>
					<cfset NewNotes = qgetEDILoads.lm_Loads_NewNotes>
					<cfset CustomerPONo = qgetEDILoads.lm_Loads_CustomerPONo>
					<cfset SCAC = qgetEDILoads.lm_EDISetup_SCAC>
					<cfset NewPickupDate = "">
					<cfif listFindNoCase("LD,CL,CU,UL,PL,PU", qgetEDILoads.lm_LoadStops_LoadType)>						
						<cfif len(qgetEDILoads.lm_LoadStops_StopDateQ) EQ 8>
							<cfset NewPickupDate = Insert("/", Insert("/", qgetEDILoads.lm_LoadStops_StopDateQ, 4), 7)>
						<cfelseif len(qgetEDILoads.lm_LoadStops_StopDate) EQ 8>
							<cfset NewPickupDate = Insert("/", Insert("/", qgetEDILoads.lm_LoadStops_StopDate, 4), 7)>
						</cfif>
					</cfif>					
					
					<cfquery name="qinsLoad" datasource="#dsn#">
						DECLARE @generatedloadID uniqueidentifier;		
						SET @generatedloadID = NewID();
						INSERT INTO loads(LoadID,LoadNumber,NewNotes,CustomerPONo,CreatedDateTime,LastModifiedDate,CreatedBy,ModifiedBy,CompanyID,StatusTypeID,HasEnrouteStops,HasTemp,IsPost,IsPepUpload,IsLocked,LDMiles,CustStopCharges,CustLumperPay,CustFlatRate,CustFSC,CustMiscPay,CustDeduction,PayerID,EquipmentID,BOLNum,EDISCAC,ShipmentMethodOfPayment,FF,TotalCustomerCharges,receiverID,NewPickupDate,IsEDI,
							<cfif len(trim(getEdiPartner.AcctMGRID))>dispatcherid,</cfif><cfif len(trim(getEdiPartner.SalesRepID))>salesrepid,</cfif>carrierNotes) 
						VALUES(@generatedloadID,#LoadNumber#,'#NewNotes#','#CustomerPONo#',getdate(),getdate(),'EDI204','EDI204','#CompanyID#','#StatusTypeID#',0,0,0,0,0,0,0,0,0,0,0,0,'#getEdiPartner.CustomerID#',(SELECT EquipmentID FROM Equipments WHERE EquipmentCode = '#qgetEDILoads.lm_Equipments_EquipmentCode#'),'#BOLNum#','#qgetEDILoads.lm_EDISetup_SCAC#','#qgetEDILoads.ShipmentMethodOfPayment#','#FF#',0,'#qgetEDILoads.receiverID#','#NewPickupDate#',1,<cfif len(trim(getEdiPartner.AcctMGRID))>'#getEdiPartner.AcctMGRID#',</cfif><cfif len(trim(getEdiPartner.SalesRepID))>'#getEdiPartner.SalesRepID#',</cfif>'#getEdiPartner.carrierNotes#')
					</cfquery>
					<cfset ediLoadsImported = ediLoadsImported +1>
					<cfquery name="qinsEDILog" datasource="#dsn#">
						INSERT INTO EDI204Log
						(
							[LoadLogID]
				           ,[BOLNumber]
				           ,[Detail]
				           ,[CreatedDate]
				           ,[LoadNumber]
				           ,[DocType]
				           ,[ModifiedDate]
				           ,CustomerID
				           ,ReceiverID
						)
						 VALUES(newid()
							,<cfqueryparam value="#BOLNum#" cfsqltype="cf_sql_varchar">
							,<cfqueryparam value="Imported Load" cfsqltype="cf_sql_varchar">
							,getdate()
							,<cfqueryparam value="#LoadNumber#" cfsqltype="CF_SQL_INTEGER">
							,<cfqueryparam value="#doctype#" cfsqltype="cf_sql_varchar">
							,getdate()
							,'#getEdiPartner.CustomerID#'
							,'#qgetEDILoads.receiverID#'
							)
					</cfquery>
					<cfset local.lm_Loads_BOL = qgetEDILoads.lm_Loads_BOL>
					
					<cfset local.lm_Customers_CustomerCode = getEdiPartner.CustomerID>
					<cfset local.lm_LoadStops_StopNo = -1>
				</cfif>

				<cfquery name="getLoad" datasource="#dsn#">
					SELECT LoadID,LoadNumber FROM Loads WHERE BOLNum = '#local.lm_Loads_BOL#' order by loadnumber desc
				</cfquery>
				<cfset local.LoadID = getLoad.LoadID>
				<cfset importedLoadIds = importedLoadIds & ","& local.LoadID>
				
				
				<cfif listFindNoCase("LD,CL,PL", qgetEDILoads.lm_LoadStops_LoadType) OR (len(qgetEDILoads.lm_LoadStops_LoadType) EQ 0 AND len(qgetEDILoads.lm_LoadStops_StopNo) EQ 0)>
					<cfset local.lm_LoadStops_LoadType = 1>
					<cfset local.lm_LoadStops_StopNo++>
					<cfset local.previousLoadType = "#qgetEDILoads.lm_LoadStops_LoadType#">
					<cfset local.noShipper = "no">	
					
				<cfelseif listFindNoCase("CU,UL,PU", qgetEDILoads.lm_LoadStops_LoadType)>
					
					<cfset local.lm_LoadStops_LoadType = 2>					
					<cfif  local.previousLoadType EQ 'CU' OR local.previousLoadType EQ 'UL' OR local.previousLoadType EQ 'PU'>
						<cfset local.lm_LoadStops_StopNo++>
						<cfset local.noShipper = "yes">		
						
					</cfif>
					<cfset local.previousLoadType = "#qgetEDILoads.lm_LoadStops_LoadType#">
					
				</cfif>
				<cfset StopDate = "">
				<cfif len(qgetEDILoads.lm_LoadStops_StopDateQ) EQ 8>
					<cfset StopDate = Insert("/", Insert("/", qgetEDILoads.lm_LoadStops_StopDateQ, 4), 7)>
				<cfelseif len(qgetEDILoads.lm_LoadStops_StopDate) EQ 8>
					<cfset StopDate = Insert("/", Insert("/", qgetEDILoads.lm_LoadStops_StopDate, 4), 7)>
				<cfelseif len(qgetEDILoads.lm_LoadStops_StopDate) EQ 17>
					<cfset StopDate = Insert("/", Insert("/", qgetEDILoads.lm_LoadStops_StopDate, 4), 7)>
				</cfif>
				<cfset StopTime = qgetEDILoads.lm_LoadStops_StopTime>
				<cfset Miles = qgetEDILoads.lm_LoadStops_Miles>
				<cfset Address = qgetEDILoads.lm_LoadStops_Address>
				<cfset City = qgetEDILoads.lm_LoadStops_City>
				<cfset StateCode = qgetEDILoads.lm_LoadStops_StateCode>
				<cfset PostalCode = qgetEDILoads.lm_LoadStops_PostalCode>
				<cfset ContactPerson = qgetEDILoads.lm_LoadStops_ContactPerson>
				<cfif len(trim(Miles)) eq 0>
					<cfset Miles =0>
				</cfif>
				
				<cfif local.lm_LoadStops_LoadType EQ 2>
					<cfquery name="qGetMiles" datasource="#dsn#">
						SELECT miles from loadstops WHERE LoadID = '#local.LoadID#' AND StopNo = '#local.lm_LoadStops_StopNo#' AND LoadType = 1 
					</cfquery>
					<cfif qGetMiles.recordcount>
						<cfif len(trim(qGetMiles.Miles))>
							<cfset Miles =qGetMiles.Miles>
						</cfif>
					</cfif>
				</cfif>

				<cfquery name="qCheckStopExists" datasource="#dsn#">
					SELECT Count(LoadStopID) AS StopExists FROM LoadStops WHERE LoadID = '#local.LoadID#' AND StopNo = '#local.lm_LoadStops_StopNo#' AND LoadType = '#local.lm_LoadStops_LoadType#'
				</cfquery>

				<cfif qCheckStopExists.StopExists EQ 0>
				
					<cfquery name="newLoadStop" datasource="#dsn#">
						DECLARE @generatedloadStopID uniqueidentifier;		
						SET @generatedloadStopID = NewID();
						INSERT INTO LoadStops 
						(LoadStopID,LoadID,StopNo,LoadType,
							stopdate,StopTime,Miles,Address,City,StateCode,PostalCode,ContactPerson,IsOriginPickup,IsFinalDelivery,Blind,RefNo,ReleaseNo,TimeIn,TimeOut
						,CreatedDateTime,LastModifiedDate,CreatedBy,ModifiedBy,NewEquipmentID,custName,IdentityCode,IdentityCodeQ,EntityIdentityCode,LoadStopsStopDateQ)
						values
						(
						@generatedloadStopID
						,'#local.LoadID#'
						,'#local.lm_LoadStops_StopNo#'
						,#local.lm_LoadStops_LoadType#
						<cfif isdate(StopDate)>
							,<cfqueryparam value="#StopDate#" cfsqltype="cf_sql_date">
						<cfelseif findnocase('-',StopDate) GT 0>
							,<cfqueryparam value="#Left(StopDate,10)#" cfsqltype="cf_sql_date">
						<cfelse>
							,NULL
						</cfif>
						,'#StopTime#'
						,#Round(Miles)#
						,'#Address#'
						,'#City#'
						,'#StateCode#'
						,'#PostalCode#'
						,'#ContactPerson#'
						,1
						,1
						,0
						,''
						,''
						,''
						,''
						,GETDATE()
						,GETDATE()
						,'EDI204'
						,'EDI204'
						,(SELECT EquipmentID FROM Equipments WHERE EquipmentCode = '#qgetEDILoads.lm_Equipments_EquipmentCode#')
						,'#qgetEDILoads.Name#'
						,'#qgetEDILoads.IdentityCode#'
						,'#qgetEDILoads.IdentityCodeQ#'
						,'#qgetEDILoads.EntityIdentityCode#'
						,'#qgetEDILoads.lm_LoadStops_StopDateQ#')
					</cfquery>

					<cfset local.consigneePickupTime = "">
					<cfset local.shipperPickupTime = "">
					<cfif local.lm_LoadStops_StopNo Eq 0>
						<cfif listFindNoCase("LD,CL,PL", qgetEDILoads.lm_LoadStops_LoadType) OR (len(qgetEDILoads.lm_LoadStops_LoadType) EQ 0 AND len(qgetEDILoads.lm_LoadStops_StopNo) EQ 0)>
							<cfset local.shipperPickupTime = StopTime>
						<cfelseif listFindNoCase("CU,UL,PU", qgetEDILoads.lm_LoadStops_LoadType)>
							<cfset local.consigneePickupTime = StopTime>
						</cfif>
						<cfif IsDefined("local.shipperPickupTime") and len(local.shipperPickupTime)>
							<cfquery name="getLoadStop" datasource="#dsn#">
								Update Loads set NewPickupTime = '#local.shipperPickupTime#' where BOLnum='#local.lm_Loads_BOL#'
							</cfquery>
						</cfif>
						<cfif IsDefined("local.consigneePickupTime") and  len(local.consigneePickupTime)>
							<cfquery name="getLoadStop" datasource="#dsn#">
								Update Loads set NewDeliveryTime = '#local.consigneePickupTime#' where BolNum='#local.lm_Loads_BOL#'
							</cfquery>
						</cfif>
					</cfif>
				</cfif>

				<cfquery name="getLoadStop" datasource="#dsn#">
					SELECT LoadStopID FROM LoadStops WHERE stopNo = #local.lm_LoadStops_StopNo# AND LoadID = '#local.loadid#'
					AND LoadType = #local.lm_LoadStops_LoadType#
				</cfquery>
				<cfset local.LoadStopID = getLoadStop.LoadStopID>

				<cfif len(qgetEDILoads.lm_LoadStopCommodities_Weight)>
					<cfset Weight = qgetEDILoads.lm_LoadStopCommodities_Weight>
				<cfelse>
					<cfset Weight = 0>
				</cfif>
				<cfif len(qgetEDILoads.lm_LoadStopCommodities_Qty)>
					<cfset Qty = qgetEDILoads.lm_LoadStopCommodities_Qty>
				<cfelse>
					<cfset Qty = 0>
				</cfif>
				<cfset Description = qgetEDILoads.lm_LoadStopCommodities_Description & " Cases">

				<cfif local.lm_LoadStops_LoadType EQ 1>
					<cfquery name="qNewSrNo" datasource="#dsn#">
						SELECT (isnull(max(srno),0)+1) as SrNo FROM LoadStopCommodities WHERE LoadSTopID = '#local.LoadStopID#'
					</cfquery>
					<cfquery name="newLoadStopComm" datasource="#dsn#">
						INSERT INTO LoadStopCommodities(LoadSTopID,Weight,Qty,Description,SrNo,CustCharges,CarrCharges,CustRate,CarrRate,CarrRateOfCustTotal )
						VALUES('#local.LoadStopID#',#Weight#,#Qty#,'#Description#','#qNewSrNo.SrNo#',0,0,0,0,0)
					</cfquery>
				<cfelseif local.lm_LoadStops_LoadType EQ 2 AND local.noShipper EQ 'yes'>
					<cfquery name="qNewSrNo" datasource="#dsn#">
						SELECT (isnull(max(srno),0)+1) as SrNo FROM LoadStopCommodities WHERE LoadSTopID = '#local.LoadStopID#'
					</cfquery>
					<cfquery name="newLoadStopComm" datasource="#dsn#">
						INSERT INTO LoadStopCommodities(LoadSTopID,Weight,Qty,Description,SrNo,CustCharges,CarrCharges,CustRate,CarrRate,CarrRateOfCustTotal )
						VALUES('#local.LoadStopID#',#Weight#,#Qty#,'#Description#','#qNewSrNo.SrNo#',0,0,0,0,0)
					</cfquery>
				</cfif>

				<cfquery name="updImport" datasource="#dsn#">
					UPDATE EDI204 SET Imported = 1
					,LoadID ='#local.LoadID#'
					,ModifiedDate = getdate()
					 WHERE lm_Loads_BOL = '#local.lm_Loads_BOL#'
				</cfquery>
				<cfelse>
				<cfset ediPartnerMissing = ediPartnerMissing & "," &qgetEDILoads.receiverID>
				<cfset logMessage="No matching customers found for EDI PartnerID: #qgetEDILoads.receiverID#">
					<cfquery name="qinsEDILog" datasource="#dsn#">
						INSERT INTO EDI204Log(LoadLogId,BOLNumber, Detail,DocType,ReceiverID
												) VALUES(newid()
							,<cfqueryparam value="#qgetEDILoads.lm_Loads_BOL#" cfsqltype="cf_sql_varchar">
							,<cfqueryparam value="#logMessage#" cfsqltype="cf_sql_varchar">
							,<cfqueryparam value="#doctype#" cfsqltype="cf_sql_varchar">
							,'#qgetEDILoads.receiverID#'
							)
					</cfquery> 
				</cfif>

			</cfloop>
			
			<cfloop list="#importedLoadIds#" index="i">
				<cfset CheckForLoadStopS(i)>
			</cfloop>
			
			<cfloop list="#importedLoadIds#" index="i">
				<cfquery name="qGetCommodityStop" datasource="#dsn#">
					select LS.StopNo,LS.LoadStopID from LOADstops LS inner join LoadStopCommodities LSC 
					on LS.LoadStopID =LSC.LoadStopID and loadtype=2  and LS.LoadID = '#i#'
				</cfquery> 
				<cfif qGetCommodityStop.RecordCount>
					<cfquery name="qGetStopID" datasource="#dsn#">
						select LoadStopID from LOADstops where LoadID = '#i#' 
						and stopno = #qGetCommodityStop.StopNo# and LoadType=1
					</cfquery>
					<cfif qGetStopID.RecordCount>
						<cfquery name="qUpdateCommodity" datasource="#dsn#">
							UPDATE LoadStopCommodities 
							SET LoadStopID = '#qGetStopID.LoadStopID#' 
							WHERE LoadStopID ='#qGetCommodityStop.LoadStopID#'
						</cfquery>
					</cfif>
				</cfif>
			</cfloop>

			<cfif Len(ediPartnerMissing)>
				<cfset resultStruct.ediPartnerMissing="#ediPartnerMissing#">
			</cfif>
			<cfif Len(ediLoadsImported)>
				<cfset resultStruct.ediLoadsImported="#ediLoadsImported#">
			</cfif>
			
		<cfcatch>
		
			<cfif structKeyExists(local, "lm_Loads_BOL") AND len(trim(local.lm_Loads_BOL))>
				<cfquery name="qRestore" datasource="#dsn#">
					delete from LoadStopCommodities where loadstopid in (select loadstopid from loadstops where loadid in (select loadid from loads where BOLNum = '#local.lm_Loads_BOL#'))
					delete from loadstops where loadid in (select loadid from loads where BOLNum = '#local.lm_Loads_BOL#')	
					delete from loads where BOLNum = '#local.lm_Loads_BOL#'
					UPDATE EDI204 SET Imported = 0 WHERE lm_Loads_BOL = '#local.lm_Loads_BOL#'
					delete from EDI204Log where BOLNumber = '#local.lm_Loads_BOL#'
				</cfquery>
			</cfif>
			<cfquery name="qgetEDILoadsErr" datasource="#dsn#">
				SELECT lm_Loads_BOL FROM Edi204 WHERE Imported = 0 GROUP BY lm_Loads_BOL
			</cfquery>
			<cfset list_BOl = ValueList(qgetEDILoadsErr.lm_Loads_BOL)>
			<cfquery name="qinsEDILog" datasource="#dsn#">
				INSERT INTO EDI204Log (
							[LoadLogID]
				           ,[BOLNumber]
				           ,[Detail]
				           ,[CreatedDate]
				           ,[LoadNumber]
				           ,[DocType]
				           ,[ModifiedDate]
						)
				VALUES(newid()
					,<cfqueryparam value="#list_BOl#" cfsqltype="cf_sql_varchar">
					,<cfqueryparam value="#cfcatch.message##cfcatch.detail#" cfsqltype="cf_sql_varchar">
					,getdate()
					,<cfqueryparam value="#LoadNumber#" cfsqltype="CF_SQL_INTEGER">
					,<cfqueryparam value="#doctype#" cfsqltype="cf_sql_varchar">
					,getdate())
			</cfquery>
		</cfcatch>
		</cftry>
		<cfreturn resultStruct>
	</cffunction>

	<cffunction name="edi820LoadImport" access="remote"  output="yes" >
		<cfset dsn = trim(listFirst(cgi.SCRIPT_NAME,'/'))>
		<cfset doctype='820'>
		<cfset resultStruct ={}>
		<cftry>
			<cfquery name="qgetEDILoads" datasource="#dsn#">
				SELECT * FROM EDI820  WHERE edi_processed = 0
			</cfquery>
			<cfset ediLoadsImported = 0>
			<cfloop query="qgetEDILoads">				
				<cfset local.loadnumber = qgetEDILoads.Reference_Identification>
				<cfquery name="getLoadsBol" datasource="#dsn#">
						SELECT LoadID,BOLNum 
						FROM Loads 
						WHERE LoadNumber =<cfqueryparam value="#local.loadnumber#" cfsqltype="CF_SQL_INTEGER">
				</cfquery>
				<cfif getLoadsBol.recordcount>

				<cfquery name="UpdateLoads" datasource="#dsn#">
					
						UPDATE Loads  SET
							transactionHandlingCode = <cfqueryparam value="#qgetEDILoads.Transaction_Handling_Code#" cfsqltype="cf_sql_varchar">,
							monetaryAmount =  <cfqueryparam value="#qgetEDILoads.Monetary_Amount#" cfsqltype="cf_sql_float" null="#yesNoFormat(NOT len(trim(qgetEDILoads.Monetary_Amount)))#" >,
							creditOrDebitFlagCode =  <cfqueryparam value="#qgetEDILoads.Credit_Or_Debit_Flag_Code#" cfsqltype="cf_sql_varchar">,
							paymentMethodCode =  <cfqueryparam value="#qgetEDILoads.Payment_Method_Code#" cfsqltype="cf_sql_varchar">,
							paymentFormatCode =  <cfqueryparam value="#qgetEDILoads.Payment_Format_Code#" cfsqltype="cf_sql_varchar">,
							referenceID =  <cfqueryparam value="#qgetEDILoads.Reference_ID#" cfsqltype="cf_sql_varchar">,
							referenceInformationRequested =  <cfqueryparam value="#qgetEDILoads.Reference_Information_Requested#" cfsqltype="cf_sql_date">,
							entityIdentifierCode =  <cfqueryparam value="#qgetEDILoads.Entity_Identifier_Code#" cfsqltype="cf_sql_varchar">,
							name =  <cfqueryparam value="#qgetEDILoads.Name#" cfsqltype="cf_sql_varchar">,
							address1 =  <cfqueryparam value="#qgetEDILoads.Address_1#" cfsqltype="cf_sql_varchar">,
							address2 =  <cfqueryparam value="#qgetEDILoads.Address_2#" cfsqltype="cf_sql_varchar">,
							ediCity =  <cfqueryparam value="#qgetEDILoads.City#" cfsqltype="cf_sql_varchar">,
							ediState =  <cfqueryparam value="#qgetEDILoads.State#" cfsqltype="cf_sql_varchar">,
							ediZip =  <cfqueryparam value="#qgetEDILoads.Zip#" cfsqltype="cf_sql_varchar">,
							ediCountryCode =  <cfqueryparam value="#qgetEDILoads.Country_Code#" cfsqltype="cf_sql_varchar">,
							assignedNumber =  <cfqueryparam value="#qgetEDILoads.Assigned_Number#" cfsqltype="cf_sql_integer">,
							referenceIDQualifier =  <cfqueryparam value="#qgetEDILoads.Reference_ID_Qualifier#" cfsqltype="cf_sql_varchar">,
							referenceIdentification =  <cfqueryparam value="#qgetEDILoads.Reference_Identification#" cfsqltype="cf_sql_varchar">,
							amountPaid =  <cfqueryparam value="#qgetEDILoads.Amount_Paid#" cfsqltype="cf_sql_float" null="#yesNoFormat(NOT len(trim(qgetEDILoads.Amount_Paid)))#" >,
							amountOfInvoice = <cfqueryparam value="#qgetEDILoads.Amount_of_Invoice#" cfsqltype="cf_sql_varchar" null="#yesNoFormat(NOT len(trim(qgetEDILoads.Amount_of_Invoice)))#" >,
							ediProcessed =  <cfqueryparam value="#qgetEDILoads.edi_processed#" cfsqltype="cf_sql_float">,
							receiverID =  <cfqueryparam value="#qgetEDILoads.receiverID #" cfsqltype="cf_sql_varchar">
					WHERE Loadid = <cfqueryparam value="#getLoadsBol.LoadID#" cfsqltype="cf_sql_varchar">
				</cfquery>
				<cfquery name="upd820Import" datasource="#dsn#">
					UPDATE EDI820 SET edi_processed = 1,LoadID='#getLoadsBol.LoadID#' WHERE Reference_Identification = '#qgetEDILoads.Reference_Identification#'
				</cfquery>
				<cfset ediLoadsImported = ediLoadsImported +1>
				<cfquery name="qinsEDILog" datasource="#dsn#">
						INSERT INTO EDI204Log (
							[LoadLogID]
				           ,[BOLNumber]
				           ,[Detail]
				           ,[CreatedDate]
				           ,[LoadNumber]
				           ,[DocType]
				           ,[ModifiedDate]
						)
						VALUES(newid()
							,<cfqueryparam value="#getLoadsBol.BOLNum#" cfsqltype="cf_sql_varchar">
							,<cfqueryparam value="Imported Load" cfsqltype="cf_sql_varchar">
							,getdate()
							,<cfqueryparam value="#LoadNumber#" cfsqltype="CF_SQL_INTEGER">
							,<cfqueryparam value="#doctype#" cfsqltype="cf_sql_varchar">
							,getdate())
				</cfquery>
				</cfif>
			</cfloop>
			<cfif Len(ediLoadsImported)>
				<cfset resultStruct.ediLoadsImported="#ediLoadsImported#">
			</cfif>
		<cfcatch>
			<cfquery name="qinsEDILog" datasource="#dsn#">
				INSERT INTO EDI204Log(LoadLogId,BOLNumber, Detail,DocType) VALUES(newid()
					,<cfqueryparam value="#getLoadsBol.BOLNum#" cfsqltype="cf_sql_varchar">
					,<cfqueryparam value="#cfcatch.message##cfcatch.detail#" cfsqltype="cf_sql_varchar">					
					,<cfqueryparam value="#doctype#" cfsqltype="cf_sql_varchar">
				)
			</cfquery>
			
		</cfcatch>
		</cftry>
		<cfreturn resultStruct>
	</cffunction>

	<cffunction name="checkcustomerMCNumber" access="remote" output="false" returntype="query">
	    <cfargument name="McNumber" required="no" type="any">
	    <cfargument name="DotNumber" required="no" type="any">
		<cfargument name="dsn" required="no" type="any">
	 	<cfif structKeyExists(arguments, "McNumber")>
			 <cfquery name="checkMc" datasource="#arguments.dsn#">
		    	select * from customers where MCNumber ='#arguments.McNumber#' and customerid in (select customerid from CustomerOffices inner join offices on CustomerOffices.officeid = offices.officeid where offices.companyid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#session.companyid#">)
			 </cfquery>
		<cfelseif structKeyExists(arguments, "DotNumber")>
			<cfquery name="checkMc" datasource="#arguments.dsn#">
		    	select * from customers where DOTNumber =<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.DotNumber#"> and customerid in (select customerid from CustomerOffices inner join offices on CustomerOffices.officeid = offices.officeid where offices.companyid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#session.companyid#">)
			 </cfquery>
		</cfif>
		<cfreturn checkMc>

	</cffunction>

	<cffunction name="getForm1099Path" access="remote" output="false" returntype="struct" returnformat="json">
		<cfargument name="year" required="yes" type="any">
		<cfargument name="CompanyID" required="yes" type="any">
		<cfargument name="dsn" required="yes" type="any">
		<cfargument name="copy" required="yes" type="any">
		
		<cfquery name="qCompany" datasource="#arguments.dsn#">
			SELECT CompanyCode FROM companies WHERE CompanyID = <cfqueryparam value="#arguments.CompanyID#" cfsqltype="varchar">
		</cfquery>

		<cfset rootPath = expandPath('../fileupload/form1099/#qCompany.CompanyCode#/')>
		<cfdirectory action="list" directory="#rootPath#" name="dirList">

		<cfloop query="dirList">
			<cfset yr=listGetAt(dirList.name, 2,'_')>
			<cfset month=listGetAt(dirList.name, 3,'_')>
			<cfset date=listGetAt(dirList.name, 4,'_')>

			<cfset date1 = "#yr#/#month#/#date#">
			<cfset date2 = DateTimeFormat(now(),'YYYY/MM/dd')>
			<cfset datediff= dateDiff('d', date1, date2)>

			<cfif datediff GT 1>
				<cfdirectory action="delete" directory="#dirList.Directory#\#dirList.name#" recurse="true">
			</cfif>
		</cfloop>

		<cfif not directoryExists(rootPath)>
			<cfdirectory action = "create" directory = "#rootPath#" > 
		</cfif>

		<cfset folderPath = 'form1099_#DateTimeFormat(now(),"YYYY_MM_dd_HH_nn_ss_l")#_#arguments.copy#'>
		<cfif not directoryExists("#rootPath##folderPath#")>
			<cfdirectory action = "create" directory = "#rootPath##folderPath#" > 
		</cfif>
		<cfset fileName = "#arguments.year#-1099-#arguments.copy#.PDF">
		
		<cfset file = structNew()>
		<cfset file['folderPath'] = qCompany.CompanyCode & '/' &folderPath>
		<cfset file['fileName'] = fileName>
     	<cfreturn file>
	</cffunction>

	<cffunction name="getGenerateForm1099" access="remote" output="false">
		<cfargument name="year" required="yes" type="any">
		<cfargument name="folderPath" required="yes" type="any">
		<cfargument name="fileName" required="yes" type="any">
		<cfargument name="CompanyID" required="yes" type="any">

		<cfset rootPath = expandPath('../fileupload/form1099/')>
		<cfset urlpath = "#cgi.HTTP_HOST#/#trim(listFirst(cgi.SCRIPT_NAME,'/'))#/www/reports/Form1099.cfm?year=#arguments.year#&CompanyID=#arguments.CompanyID#&copy=#arguments.copy#">
		<cfexecute
			name="c:\Program Files\wkhtmltopdf\bin\wkhtmltopdf.exe" 
     		arguments="#urlpath# #rootPath##arguments.folderPath#/temp_#arguments.fileName#" 
     		timeout="1000" />

     	<cffile action = "rename" source = "#rootPath##arguments.folderPath#/temp_#arguments.fileName#" destination = "#rootPath##arguments.folderPath#/#arguments.fileName#">

	</cffunction>

	<cffunction name="getForm1099Ready" access="remote" returntype="boolean" returnformat="plain">
	
		<cfargument name="folderPath" required="yes" type="any">
		<cfargument name="fileName" required="yes" type="any">

		<cfset rootPath = expandPath('../fileupload/form1099/')>
		
		<cfreturn fileExists("#rootPath##arguments.folderPath#/#arguments.fileName#")>

	</cffunction>

	<cffunction name="bookCarrierQuote" access="remote" output="yes" returntype="string" returnformat="json">
		<cfargument name="loadid" required="yes" type="string">
		<cfargument name="stopNo" required="yes" type="numeric">
		<cfargument name="carrierid" required="yes" type="string">
		<cfargument name="CarrFlatRate" required="yes" type="numeric">
		<cfargument name="user" required="yes" type="string">
		<cfargument name="dsn" required="no" type="any">
		<cfargument name="companyid" required="no" type="any">
		<cfargument name="fBStatus" type="numeric" required="yes"/>
		<cfargument name="ChangeLoadNumber" required="no" type="string" default="0">

		<cfif arguments.ChangeLoadNumber EQ 1>
			<cfinvoke method="ChangeLoadNumber" dsn="#arguments.dsn#" adminUserName="" loadid="#arguments.loadid#" StatusTypeID="" StatusText="" fBStatus="#arguments.fBStatus#" carrierId="#arguments.carrierId#" CompanyID="#arguments.companyid#" returnvariable="BookedLoadNumber">
		</cfif>

		<cfset local.stopNO = arguments.stopNO-1>
		<cfquery name="updLoad" datasource="#arguments.dsn#">
	    	update loads set 
	    		CarrFlatRate = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.CarrFlatRate#">,
	    		statustypeid =(select statustypeid from LoadStatusTypes where StatusText='2. BOOKED' AND companyid = '#arguments.companyid#')
	    		<cfif arguments.ChangeLoadNumber EQ 1>
	    			,LoadNumber = <cfqueryparam cfsqltype="cf_sql_integer" value="#BookedLoadNumber#">
	    		</cfif>

	    		where loadid =<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.loadid#">
		</cfquery>

		<cfquery name="updLoadStop" datasource="#arguments.dsn#">
	    	update LoadStops set 
	    		NewCarrierID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.carrierid#">
	    		where loadid =<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.loadid#">
	    		and stopNO = <cfqueryparam cfsqltype="cf_sql_numeric" value="#local.stopNO#">
		</cfquery>

		<cfquery name="qGetSystemConfig" datasource="#arguments.dsn#">
			select statusDispatchNotes from SystemConfig
		</cfquery>

		<cfif qGetSystemConfig.statusDispatchNotes>
			<cfset strMsg =datetimeformat(now(),"m/dd/yyyy h:mm tt")&" - "&arguments.user&" > Status changed to BOOKED">
			<cfquery name="qUpdateLoadDispatchNote" datasource="#arguments.dsn#">						
				UPDATE LOADS
				SET NewDispatchNotes = '#strMsg#'+CHAR(13)+NewDispatchNotes					
				WHERE loadId = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.loadid#">
			</cfquery>
		</cfif>
		<cfreturn 'Success'>
	</cffunction>

	<cffunction name="generateIFTALoads" access="remote" output="false"  returntype="string" returnformat="json">
		
	    <cfargument name="DateFrom" required="no" type="any">
	    <cfargument name="DateTo" required="no" type="any">
	    <cfargument name="empID" required="no" type="any">
	    <cfargument name="CompanyID" required="no" type="any" default="">
	    <cfset dsn = trim(listFirst(cgi.SCRIPT_NAME,'/'))>

	    <cfquery name="getAllLoadsInDateRange" datasource="#dsn#">
	    	SELECT l.LoadNumber
			FROM  dbo.Loads AS l
			INNER JOIN LoadStops ls on l.LoadID = ls.LoadID 
			INNER JOIN Equipments Eq ON Ls.NewEquipmentID = Eq.EquipmentID 
			INNER JOIN LoadStatusTypes LST ON LST.StatusTypeID = L.StatusTypeID
			WHERE     
			l.NewDeliveryDate BETWEEN CONVERT(DATETIME,<cfqueryparam value="#dateformat(arguments.DateFrom,"mm/dd/yyyy")#" cfsqltype="cf_sql_date">,102) AND CONVERT(DATETIME,<cfqueryparam value="#dateformat(arguments.DateTo,"mm/dd/yyyy")#" cfsqltype="cf_sql_date">, 102)
			AND (SELECT COUNT(lm.LoadNumber) FROM LoadIFTAMiles lm WHERE lm.LoadNumber=l.LoadNumber) =0
			AND ISNULL(Eq.IFTA,0) = 1
			AND LST.StatusText BETWEEN N'5' AND N'9'
			AND (SELECT COUNT(ls1.Loadstopid) FROM loadstops ls1  INNER JOIN Equipments Eq1 ON Ls1.NewEquipmentID = Eq1.EquipmentID  WHERE ls1.loadid = l.loadid AND ls1.stopno = ls.stopno	AND ISNULL(Eq1.IFTA,0) = 1
				AND ls1.city <> '' AND ls1.statecode <>'' AND ls1.postalcode <> ''
			) >1
			and customerid in (select customerid from CustomerOffices inner join offices on CustomerOffices.officeid = offices.officeid where offices.companyid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.companyid#">)
			GROUP BY l.LoadNumber 
			ORDER BY l.loadNUmber
		</cfquery>
		
	    <cfreturn serializeJSON(getAllLoadsInDateRange)>
	</cffunction>


	<cffunction name="generateIFTAdata" access="remote" output="false" returntype="any">
		
	    <cfargument name="DateFrom" required="no" type="any">
	    <cfargument name="DateTo" required="no" type="any">
	    <cfargument name="empID" required="no" type="any">
	    <cfargument name="CompanyID" required="no" type="any" default="">
	    <cfargument name="loadNumber" required="no" type="any">
	    <cfset dsn = trim(listFirst(cgi.SCRIPT_NAME,'/'))>

	    <cfif not structKeyExists(variables,"objPromilesGateway")>
			<cfscript>variables.objPromilesGateway = dsn&".www.gateways.promiles";</cfscript>
		</cfif>

	    <cfquery name="getAllLoadsInDateRange" datasource="#dsn#">

	    	SELECT l.LoadID,l.LoadNumber,l.StatusTypeID AS loadStatus,ls.LoadStopID,(ls.StopNo+1) AS StopNo,ls.LoadType,ls.Address,ls.City,ls.StateCode,ls.PostalCode,ls.NewEquipmentID,ls.StopDate
			FROM  dbo.Loads AS l
			INNER JOIN LoadStops ls on l.LoadID = ls.LoadID 
			INNER JOIN Equipments Eq ON Ls.NewEquipmentID = Eq.EquipmentID 
			INNER JOIN LoadStatusTypes LST ON LST.StatusTypeID = L.StatusTypeID
			WHERE      
			l.NewDeliveryDate BETWEEN CONVERT(DATETIME,<cfqueryparam value="#dateformat(arguments.DateFrom,"mm/dd/yyyy")#" cfsqltype="cf_sql_date">,102) AND CONVERT(DATETIME,<cfqueryparam value="#dateformat(arguments.DateTo,"mm/dd/yyyy")#" cfsqltype="cf_sql_date">, 102)
			AND (SELECT COUNT(lm.LoadNumber) FROM LoadIFTAMiles lm WHERE lm.LoadNumber=l.LoadNumber) =0
			<cfif structKeyExists(arguments, "loadNumber")>
				AND l.LoadNumber = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.loadNumber#">
			</cfif>
			AND ISNULL(Eq.IFTA,0) = 1
			AND LST.StatusText BETWEEN N'5' AND N'9'
			<cfif structkeyexists(arguments,"CompanyID") AND Len(Trim(arguments.CompanyID))>
				AND Eq.CompanyID = <cfqueryparam value="#arguments.CompanyID#" cfsqltype="CF_SQL_VARCHAR">
			</cfif>
			ORDER BY l.loadNUmber,ls.StopNo,ls.LoadType
		</cfquery>

		<cfinvoke  method="getEquipmentLastLocation" equipmentID="#getAllLoadsInDateRange.NewEquipmentID#" shipperPickupDate="#getAllLoadsInDateRange.StopDate#" loadid="#getAllLoadsInDateRange.LoadID#" returnvariable="equipDeadHeadLoc" CompanyID="#arguments.CompanyID#"/>

		<cfoutput query="getAllLoadsInDateRange" group="loadnumber">
			<cfset frmstruct = structNew()>
			<cfset frmstruct.loadStatus = getAllLoadsInDateRange.loadStatus>
			<cfset frmstruct.loadnumber = getAllLoadsInDateRange.loadnumber>
			<cfset frmstruct.loadID = getAllLoadsInDateRange.loadID>
			<cfset frmstruct.dsn = dsn>
			<cfset frmstruct.empID = arguments.empID>
			<cfset shipperIndx = 1>
			<cfset consigneeIndex = 1>
			<cfoutput group="LoadStopID">
				<cfif getAllLoadsInDateRange.LoadType EQ 1>
					<cfset frmstruct['shipperAddressLocation#shipperIndx#'] = "">
					<cfif shipperIndx EQ 1>
						<cfset frmstruct['SHIPPERCITY'] = getAllLoadsInDateRange.City>
						<cfset frmstruct['SHIPPERSTATE'] = getAllLoadsInDateRange.StateCode>
						<cfset frmstruct['SHIPPERZIPCODE'] = getAllLoadsInDateRange.PostalCode>
					<cfelse>
						<cfset frmstruct['SHIPPERCITY#shipperIndx#'] = getAllLoadsInDateRange.City>
						<cfset frmstruct['SHIPPERSTATE#shipperIndx#'] = getAllLoadsInDateRange.StateCode>
						<cfset frmstruct['SHIPPERZIPCODE#shipperIndx#'] = getAllLoadsInDateRange.PostalCode>
					</cfif>
					<cfset shipperIndx++>
				<cfelse>
					<cfset frmstruct['consigneeAddressLocation#consigneeIndex#'] = "">
					<cfif consigneeIndex EQ 1>
						<cfset frmstruct['CONSIGNEECITY'] = getAllLoadsInDateRange.City>
						<cfset frmstruct['CONSIGNEESTATE'] = getAllLoadsInDateRange.StateCode>
						<cfset frmstruct['CONSIGNEEZIPCODE'] = getAllLoadsInDateRange.PostalCode>
					<cfelse>
						<cfset frmstruct['CONSIGNEECITY#consigneeIndex#'] = getAllLoadsInDateRange.City>
						<cfset frmstruct['CONSIGNEESTATE#consigneeIndex#'] = getAllLoadsInDateRange.StateCode>
						<cfset frmstruct['CONSIGNEEZIPCODE#consigneeIndex#'] = getAllLoadsInDateRange.PostalCode>
					</cfif>
					<cfset consigneeIndex++>
				</cfif>
			</cfoutput>

			<cfif equipDeadHeadLoc.success>
				<cfset frmstruct['dhSHIPPERCITY'] = equipDeadHeadLoc.City>
				<cfset frmstruct['dhSHIPPERSTATE'] = equipDeadHeadLoc.StateCode>
				<cfset frmstruct['dhSHIPPERZIPCODE'] = equipDeadHeadLoc.PostalCode>
			<cfelse>
				<cfset frmstruct['dhSHIPPERCITY'] = "">
				<cfset frmstruct['dhSHIPPERSTATE'] = "">
				<cfset frmstruct['dhSHIPPERZIPCODE'] = "">
			</cfif>
			<cfset frmstruct['IFTAinclude'] = 1>
			<cfinvoke component="#variables.objPromilesGateway#" method="promilesCalculation" frmstruct="#frmstruct#" returnvariable="responsePromiles"/>
			<cfset StructClear(frmstruct)>
		</cfoutput>
	    <cfreturn 'Success'>
	</cffunction>
	<cffunction name="processEDI" access="remote" output="yes" returntype="string" returnformat="json">
		<cfargument name="loadID" required="yes" type="any">
		<cfargument name="dsn" required="yes" type="any">
		<cfargument name="DocType" required="yes" type="any">


		<cfquery name="qGetLoadDetails" datasource="#arguments.dsn#">
			SELECT EDISCAC,BolNum,LoadNumber,receiverid
			,(SELECT TOP 1 custname FROM loadstops WHERE loadid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.loadID#"> and loadtype = 1) AS Ship_To_Name
			,(SELECT TOP 1 stopdate FROM loadstops WHERE loadid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.loadID#"> and loadtype = 1) AS Ship_Date
			,(SELECT TOP 1 stoptime FROM loadstops WHERE loadid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.loadID#"> and loadtype = 1) AS Ship_Time
			,(SELECT TOP 1 IdentityCode FROM loadstops WHERE loadid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.loadID#">) AS IdentityCode
			,(SELECT TOP 1 EntityIdentityCode FROM loadstops WHERE loadid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.loadID#">) AS EntityIdentityCode
			,(SELECT SUM(Qty) FROM LoadStopCommodities WHERE loadstopid IN (
				SELECT loadstopid FROM loadstops WHERE loadid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.loadID#">)) AS Qty
			,(SELECT SUM(Weight) FROM LoadStopCommodities WHERE loadstopid IN (
				SELECT loadstopid FROM loadstops WHERE loadid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.loadID#">)) AS Weight			
			,(SELECT ISNULL(MAX(Assigned_Number),0)+1 FROM edi212) AS Assigned_Number
			FROM Loads
			where loadid=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.loadID#">
		</cfquery>


		<cfif Arguments.DocType EQ '212'>
			<cfquery name="qInsEDI212" datasource="#arguments.dsn#">
				INSERT INTO EDI212(
					[lm_EDISetup_SCAC]
		           ,[Reference_Identification]
		           ,[Date]
		           ,[Transaction_Set_Purpose_Code]
		           ,[Ship_To_Name]
		           ,[Identification_Code]
		           ,[Shipment_Status_Code]
		           ,[Shipment_Status]
		           ,[Time]
		           ,[Time_Code]
		           ,[Assigned_Number]
		           ,[Purchase_Order_Number]
		           ,[Unit]
		           ,[Quantity]
		           ,[Weight_Unit_Code]
		           ,[Weight]
		           ,[edi_processed]
		           ,[receiverID]
		           ,[CreatedDate]
		           ,[ModifiedDate]
				   ,LoadID
		           )
		           VALUES(
		           	'#qGetLoadDetails.EDISCAC#'
		           	,'#qGetLoadDetails.LoadNumber#'
		           	,'#qGetLoadDetails.Ship_Date#'
		           	,'00'
		           	,'#qGetLoadDetails.Ship_To_Name#'
		           	,'#qGetLoadDetails.IdentityCode#'
		           	,'AV'
		           	,'NS'
		           	,'#qGetLoadDetails.Ship_Time#'
		           	,'LT'
		           	,'#qGetLoadDetails.Assigned_Number#'
		           	,'DQ5434'
		           	,'CT'
		           	,'#qGetLoadDetails.Qty#'
		           	,'L'
		            ,'#qGetLoadDetails.Weight#'
		           	,1
		           	,'#qGetLoadDetails.receiverid#'
		           	,getdate()
		           	,getdate()
					,'#arguments.loadID#'
		           	)
			</cfquery>
		</cfif>

		<cfquery name="qinsEDILog" datasource="#arguments.dsn#">
			INSERT INTO EDI204Log (
					[LoadLogID]
		           ,[BOLNumber]
		           ,[Detail]
		           ,[CreatedDate]
		           ,[LoadNumber]
		           ,[DocType]
		           ,[ModifiedDate]
				)
			VALUES(newid()
				,<cfqueryparam value="#qGetLoadDetails.BolNum#" cfsqltype="cf_sql_varchar">
				,<cfqueryparam value="EDI#DocType# processed." cfsqltype="cf_sql_varchar">
				,getdate()
				,<cfqueryparam value="#qGetLoadDetails.LoadNumber#" cfsqltype="CF_SQL_INTEGER">
				,<cfqueryparam value="#DocType#" cfsqltype="cf_sql_varchar">
				,getdate())
		</cfquery>

		<cfset result = "EDI #DocType# processed successfully.">

		<cfreturn result>
	</cffunction>

	<cffunction name="getEdiStopDetails" access="remote" output="yes" returntype="query" returnformat="json">
		<cfargument name="loadID" required="yes" type="any">
		
			<cfquery name="qgetEdiStopDetails" datasource="#variables.dsn#">
				SELECT 
					ROW_NUMBER() OVER(ORDER BY LoadType) AS RowNumber
					,LoadStopID
					,stopno+1 as stopno
					, case when LoadType=1 then 'S' else 'C' end as stoptype,CustName,Address,City,StateCode,PostalCode
				 FROM LoadStops where loadid=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.loadID#"> 
			</cfquery>
			<cfreturn qgetEdiStopDetails>
 	</cffunction> 
 	<cffunction name="getSelectedEDIStop" access="remote" output="yes" returntype="query" returnformat="json">
		<cfargument name="loadnumber" required="yes" type="any">		
			<cfquery name="qgetEdiStopDetails" datasource="#variables.dsn#">
				select top 1 lm_LoadStops_StopName as stop from EDI214 where Reference_Identification= <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.loadnumber#">  and lm_LoadStops_StopNo =(select  max(lm_LoadStops_StopNo) from EDI214 where Reference_Identification= <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.loadnumber#">)
			</cfquery>
			<cfreturn qgetEdiStopDetails>
 	</cffunction> 
 	
 	<!--- To assign loads to comdata with loadnumber none --->
	<cffunction name="comdataUpdate" access="remote"  output="yes" >
		<cfargument name="LoadLogId" required="yes" type="any">
		<cfargument name="LoadNumber" required="yes" type="any">
		<cfargument name="Dsn" required="yes" type="any">
		<cfargument name="CompanyID" required="yes" type="any">
			<cfquery name="qGetComDataSystemSettings" datasource="#trim(listFirst(cgi.SCRIPT_NAME,'/'))#">
				select ComDataUnitID,ComDataCustomerID from SystemConfig WHERE CompanyID = '#arguments.CompanyID#'
			</cfquery>
			<cfset UnitID = qGetComDataSystemSettings.ComDataUnitID>

			<cfquery name="qgetComdataFilename" datasource="#trim(listFirst(cgi.SCRIPT_NAME,'/'))#">
				SELECT FilePath 
				FROM LoadComDataLogs 
				WHERE LoadLogID = <cfqueryparam value="#arguments.LoadLogId#" cfsqltype="cf_sql_varchar">
			</cfquery>

				<cfif qgetComdataFilename.RecordCount>
					<cfset fileName = qgetComdataFilename.FilePath>
					<cfset noOfLoadsUpdatedForFile = 0>
					<cfloop file="#expandPath('../Fuel')#/#fileName#" index="fuel">
					
						<cfif mid(fuel,1,2) EQ '01'>
							<cfset fuelcardno = mid(fuel,195,10)>
							<cfset purchaseDate = dateformat(Insert("/", Insert("/", mid(fuel,12,6), 2), 5))>
	

	
							<cfquery name="qgetLoadStop" datasource="#trim(listFirst(cgi.SCRIPT_NAME,'/'))#">
								SELECT TOP 1 LoadStops.LoadID,LoadStops.LoadStopID,
								ISNULL((SELECT MAX(LSC.SrNo) FROM LoadStopCommodities LSC WHERE LSC.LoadStopID = LoadStops.LoadStopID),0)+1 AS SrNo
							    ,ISNULL((SELECT TotalCarrierCharges FROM LOADS WHERE loadid = LoadStops.loadid),0) as TotalCarrierCharges
								,ISNULL((SELECT totalProfit FROM LOADS WHERE loadid = LoadStops.loadid),0) as totalProfit
								,LoadStops.StopDate
								,(SELECT loadnumber FROM LOADS WHERE loadid = LoadStops.loadid) AS loadnumber

								FROM LoadStops 
								left join loadstops b on b.LoadID = LoadStops.LoadID and b.LoadType = 2 and LoadStops.stopNO = b.StopNo 
								where
								 LoadStops.LoadId in (select LoadId from loads where loadnumber=<cfqueryparam value="#arguments.LoadNumber#" cfsqltype="cf_sql_varchar">)
								AND customerid in (select customerid from CustomerOffices inner join offices on CustomerOffices.officeid = offices.officeid where offices.companyid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.companyid#">)
						 		AND LoadStops.LoadType=1 
								AND (select statustext from LoadStatusTypes where statustypeid in 
									(select statustypeid from loads WHERE loadid = LoadStops.loadid))  
									between '1. ACTIVE' AND '8. COMPLETED'
								order by LoadStops.StopDate desc
							</cfquery> 


							<cfif qgetLoadStop.recordcount>
								<cfset TotalGallons = mid(fuel,90,5)>
								<cfset GallonsPPP = mid(fuel,95,5)>
								<cfset FuelCardAmount = mid(fuel,100,5)>
								<cfset CashAdvance = mid(fuel,131,5)>
								<cfset fuelupd = 0>
								<cfif FuelCardAmount GT 0>
									<cfset TotalGallons = (TotalGallons/100)>
									<cfset GallonsPPP = (GallonsPPP/1000)>
									<cfset CarrierCharges = (FuelCardAmount/100)>
									<cfset TotalCarrierCharges = qgetLoadStop.TotalCarrierCharges+CarrierCharges>
									<cfset TotalProfit = qgetLoadStop.TotalProfit - CarrierCharges>
									<cfif TotalProfit lt 0>
										<cfset TotalProfit = 0>
									</cfif>
									<cfquery name="qinsLoadStopCommodities" datasource="#trim(listFirst(cgi.SCRIPT_NAME,'/'))#">
										INSERT INTO LoadStopCommodities(LoadStopID,SrNo,Qty,UnitID,Description,Weight,CustCharges,CarrCharges,Fee,CustRate,CarrRate,CarrRateOfCustTotal) VALUES(
										<cfqueryparam value="#qgetLoadStop.LoadStopID#" cfsqltype="cf_sql_varchar">,
										<cfqueryparam value="#qgetLoadStop.SrNo#" cfsqltype="cf_sql_integer">,
										<cfqueryparam value="1" cfsqltype="cf_sql_float">,
										<cfqueryparam value="#UnitID#" cfsqltype="cf_sql_varchar">,
										<cfqueryparam value="ComData-Fuel,Gallons:#TotalGallons#,PPG:$#GallonsPPP#" cfsqltype="cf_sql_varchar">,
										<cfqueryparam value="0" cfsqltype="cf_sql_float">,
										<cfqueryparam value="0" cfsqltype="cf_sql_money">,
										<cfqueryparam value="#CarrierCharges#" cfsqltype="cf_sql_money">,
										<cfqueryparam value="0" cfsqltype="cf_sql_bit">,
										<cfqueryparam value="0" cfsqltype="cf_sql_decimal">,
										<cfqueryparam value="#CarrierCharges#" cfsqltype="cf_sql_float">,
										<cfqueryparam value="0" cfsqltype="cf_sql_decimal">
										)
									</cfquery>
									<cfquery name="qupdLoadCharges" datasource="#trim(listFirst(cgi.SCRIPT_NAME,'/'))#">
										UPDATE LOADS SET 
										TotalCarrierCharges = <cfqueryparam value="#TotalCarrierCharges#" cfsqltype="cf_sql_float">,
										TotalProfit = <cfqueryparam value="#TotalProfit#" cfsqltype="cf_sql_money">
										WHERE LoadID = <cfqueryparam value="#qgetLoadStop.LoadID#" cfsqltype="cf_sql_varchar">
									</cfquery>
									<cfquery name="qUpdateComdataLog" datasource="#trim(listFirst(cgi.SCRIPT_NAME,'/'))#">
										UPDATE LoadComDataLogs
											 SET LoadID = <cfqueryparam value="#qgetLoadStop.LoadID#" cfsqltype="cf_sql_varchar">
											,LoadNumber = <cfqueryparam value="#qgetLoadStop.LoadNumber#" cfsqltype="cf_sql_integer">
											,Description = <cfqueryparam value="ComData-Fuel Purchase" cfsqltype="cf_sql_varchar">
											,FuelPurchaseDate = <cfqueryparam value="#purchaseDate#" cfsqltype="cf_sql_date">
											,StopDate = <cfqueryparam value="#qgetLoadStop.StopDate#" cfsqltype="cf_sql_date">
											,Amount = <cfqueryparam value="#CarrierCharges#" cfsqltype="cf_sql_float">
										WHERE LoadLogID = <cfqueryparam value="#arguments.LoadLogId#" cfsqltype="cf_sql_varchar">
										AND FuelCardNo = <cfqueryparam value="#FuelCardNo#" cfsqltype="cf_sql_varchar">
											
									</cfquery>
									<cfset fuelupd = 1>
									<cfset noOfLoadsUpdatedForFile++>
								</cfif>

								<cfif CashAdvance gt 0>
									<cfset CarrierCharges = (CashAdvance/100)>
									<cfif fuelupd eq 0>
										<cfset TotalCarrierCharges = qgetLoadStop.TotalCarrierCharges-CarrierCharges>
										<cfset TotalProfit = qgetLoadStop.TotalProfit + CarrierCharges>
										<cfif TotalCarrierCharges lt 0>
											<cfset TotalCarrierCharges = 0>
										</cfif>	
										<cfset srNo = qgetLoadStop.SrNo>
									<cfelse>
										<cfset TotalCarrierCharges = TotalCarrierCharges-CarrierCharges>
										<cfset TotalProfit = TotalProfit + CarrierCharges>
										<cfif TotalCarrierCharges lt 0>
											<cfset TotalCarrierCharges = 0>
										</cfif>	
										<cfset srNo = qgetLoadStop.SrNo+1>
									</cfif>
									<cfset CarrierCharges =(CarrierCharges * -1)>
									<cfquery name="qinsLoadStopCommodities" datasource="#trim(listFirst(cgi.SCRIPT_NAME,'/'))#">
										INSERT INTO LoadStopCommodities(LoadStopID,SrNo,Qty,UnitID,Description,Weight,CustCharges,CarrCharges,Fee,CustRate,CarrRate,CarrRateOfCustTotal) VALUES(
										<cfqueryparam value="#qgetLoadStop.LoadStopID#" cfsqltype="cf_sql_varchar">,
										<cfqueryparam value="#SrNo#" cfsqltype="cf_sql_integer">,
										<cfqueryparam value="1" cfsqltype="cf_sql_float">,
										<cfqueryparam value="#UnitID#" cfsqltype="cf_sql_varchar">,
										<cfqueryparam value="ComData-CashAdvance" cfsqltype="cf_sql_varchar">,
										<cfqueryparam value="0" cfsqltype="cf_sql_float">,
										<cfqueryparam value="0" cfsqltype="cf_sql_money">,
										<cfqueryparam value="#CarrierCharges#" cfsqltype="cf_sql_money">,
										<cfqueryparam value="0" cfsqltype="cf_sql_bit">,
										<cfqueryparam value="0" cfsqltype="cf_sql_decimal">,
										<cfqueryparam value="#CarrierCharges#" cfsqltype="cf_sql_float">,
										<cfqueryparam value="0" cfsqltype="cf_sql_decimal">
										)
									</cfquery>
									<cfquery name="qupdLoadCharges" datasource="#trim(listFirst(cgi.SCRIPT_NAME,'/'))#">
										UPDATE LOADS SET 
										TotalCarrierCharges = <cfqueryparam value="#TotalCarrierCharges#" cfsqltype="cf_sql_float">,
										TotalProfit = <cfqueryparam value="#TotalProfit#" cfsqltype="cf_sql_money">
										WHERE LoadID = <cfqueryparam value="#qgetLoadStop.LoadID#" cfsqltype="cf_sql_varchar">
									</cfquery>
									<cfquery name="qUpdateComdataLog" datasource="#trim(listFirst(cgi.SCRIPT_NAME,'/'))#">
										UPDATE LoadComDataLogs
											 SET LoadID = <cfqueryparam value="#qgetLoadStop.LoadID#" cfsqltype="cf_sql_varchar">
											,LoadNumber = <cfqueryparam value="#qgetLoadStop.LoadNumber#" cfsqltype="cf_sql_integer">
											,Description = <cfqueryparam value="ComData-CashAdvance" cfsqltype="cf_sql_varchar">
											,FuelPurchaseDate = <cfqueryparam value="#purchaseDate#" cfsqltype="cf_sql_date">
											,StopDate = <cfqueryparam value="#qgetLoadStop.StopDate#" cfsqltype="cf_sql_date">
											,Amount = <cfqueryparam value="#CarrierCharges#" cfsqltype="cf_sql_float">
										WHERE LoadLogID = <cfqueryparam value="#arguments.LoadLogId#" cfsqltype="cf_sql_varchar">
										AND FuelCardNo = <cfqueryparam value="#FuelCardNo#" cfsqltype="cf_sql_varchar">
											
									</cfquery>
									<cfset noOfLoadsUpdatedForFile++>
								</cfif>
							</cfif>
						</cfif>
						
					</cfloop>
					
				</cfif>
	</cffunction>
	<cffunction name="getEdiReasonCodes" access="remote" output="yes" returntype="query" returnformat="json">
			
			<cfquery name="qgetEdiReasonCodes" datasource="#variables.dsn#">
				SELECT * FROM EDIReasonCodes where active=1 order by ReasonText
			</cfquery>
			<cfreturn qgetEdiReasonCodes>
 	</cffunction> 
 	<cffunction name="saveMacroPointOrder" access="remote" returntype="any" returnformat="JSON">
		<cfargument name="LoadID" required="yes" type="string"/>
		<cfargument name="LastStopEventCompleted" required="no" type="string" default="0"/>
		<cfargument name="User" required="no" type="string" default=""/>
		<cfargument name="CompanyID" required="yes" type="string"/>
		<cftry>
			<cfquery name="getApiDetailsForMP" datasource="#trim(listFirst(cgi.SCRIPT_NAME,'/'))#">
				SELECT MacropointId,MacropointApiLogin,MacropointApiPassword,GPSUpdateInterval,CompanyCode,EDispatchOptions
				FROM companies 
				inner join systemconfig on companies.companyid = systemconfig.companyid
				where systemconfig.companyid = <cfqueryparam value="#arguments.CompanyID#" cfsqltype="cf_sql_varchar">
			</cfquery>

			<cfif not len(trim(getApiDetailsForMP.MacropointId)) OR not len(trim(getApiDetailsForMP.MacropointApiLogin)) OR not len(trim(getApiDetailsForMP.MacropointApiPassword))>
				<cfset response = structNew()>
		        <cfset response.success = 0>
		        <cfset response.field = 0>
		        <cfset response.error = 'Please setup macropoint api crendentials on systemconfig.'>
		        <cfreturn response>
		    <cfelse>
		    	<cfset MacropointApiLoginId = toBase64('#trim(getApiDetailsForMP.MacropointApiLogin)#:#trim(getApiDetailsForMP.MacropointApiPassword)#')>
	        </cfif>

			<cfquery name="getCompanyDetailsForMP" datasource="ZGPSTrackingMPWeb">
				SELECT CompanyName FROM CompanyLookUp WHERE CompanyCode = <cfqueryparam value="#getApiDetailsForMP.CompanyCode#" cfsqltype="cf_sql_varchar">
			</cfquery>

			<cfif not getCompanyDetailsForMP.recordcount>
				<cfset response = structNew()>
		        <cfset response.success = 0>
		        <cfset response.field = 0>
		        <cfset response.error = 'No data found on Company lookup.'>
		        <cfreturn response>
			</cfif>

			<cfquery name="getLoadDetailsForMP" datasource="#trim(listFirst(cgi.SCRIPT_NAME,'/'))#">
				SELECT 
					L.LoadID
					,L.LoadNumber
					,L.GPSDeviceID
					,L.MacroPointOrderID
					,ISNULL(LS.NewDriverCell,LS.NewDriverCell2)  AS DriverCell
					,LS.StopNo
					,LS.LoadType
					,LS.StopDate
					,CASE WHEN LS.stoptime = 'ASAP' THEN '0000' ELSE replace(LS.StopTime,':','') END AS StopTime
					,LS.TimeIn
					,LS.TimeOut
					,LS.CustName
					,LS.Address
					,LS.City
					,LS.StateCode
					,LS.PostalCode
					,C.CarrierID
					,C.CarrierName
					,LS.TimeZone
					,C.EmailID
					,L.CustomerID AS PayerID
					,L.MacropointCarrierID
				FROM Loads L
				LEFT JOIN LoadStops LS ON LS.LoadID = L.LoadID 
				LEFT JOIN Carriers C ON C.CarrierID = L.CarrierID
				WHERE L.LoadID = <cfqueryparam value="#arguments.LoadID#" cfsqltype="cf_sql_varchar">  
				AND (LEN(LS.CustName) <> 0 OR LEN(LS.Address) <> 0 OR LEN(LS.City) <> 0 OR LEN(LS.StateCode) <> 0 OR LEN(LS.PostalCode) <> 0)
				ORDER BY LS.StopNo,LS.LoadType
			</cfquery>

			<cfset response = structNew()>
			<cfset stopXml = "">

			<cfif not len(trim(getLoadDetailsForMP.DriverCell))>
				<cfset response.success = 0>
				<cfset response.field = "driverCell">
				<cfset response.error = 'Driver cell is required.'>
				<cfreturn response>
			</cfif>

			<cfif not len(trim(getLoadDetailsForMP.StopDate[getLoadDetailsForMP.recordcount]))>
				<cfset response.success = 0>
				<cfif getLoadDetailsForMP.stopNO[getLoadDetailsForMP.recordcount] EQ 0>
					<cfset response.field = "consigneePickupDate">
				<cfelse>
					<cfset stopNoVal = getLoadDetailsForMP.stopNO[getLoadDetailsForMP.recordcount]+1>
					<cfset response.field = "consigneePickupDate#stopNoVal#">
				</cfif>
				<cfset response.error = 'Delivery date for last stop is required for tracking end time.'>
				<cfreturn response>
			</cfif>

			<cfif not len(trim(getLoadDetailsForMP.StopTime[getLoadDetailsForMP.recordcount]))>
				<cfset response.success = 0>
				<cfif getLoadDetailsForMP.stopNO[getLoadDetailsForMP.recordcount] EQ 0>
					<cfset response.field = "consigneepickupTime">
				<cfelse>
					<cfset stopNoVal = getLoadDetailsForMP.stopNO[getLoadDetailsForMP.recordcount]+1>
					<cfset response.field = "consigneepickupTime#stopNoVal#">
				</cfif>
				<cfset response.error = 'Apt. time for last stop is required for tracking end time.Valid format is HHMM OR HH:MM.'>
				<cfreturn response>
			</cfif>

			<cfloop list="#trim(getLoadDetailsForMP.StopTime[getLoadDetailsForMP.recordcount])#" index="indxStopTime" delimiters="-">
				<cfif len(trim(indxStopTime)) NEQ 4 OR NOT IsNumeric(trim(indxStopTime))>
					<cfset response.success = 0>
					<cfif getLoadDetailsForMP.stopNO[getLoadDetailsForMP.recordcount] EQ 0>
						<cfset response.field = "consigneepickupTime">
					<cfelse>
						<cfset stopNoVal = getLoadDetailsForMP.stopNO[getLoadDetailsForMP.recordcount]+1>
						<cfset response.field = "consigneepickupTime#stopNoVal#">
					</cfif>
					<cfset response.error = 'Invalid Apt. time for last stop. Valid format is HHMM OR HH:MM.#chr(10)#For example, instead of entering 8am or 4pm please enter 08:00 and 16:00 respectively.'>
					<cfreturn response>
				</cfif>
			</cfloop>
			<cfset var timeZoneList = "GMT,UTC,ECT,EET,ART,EAT,MET,NET,PLT,IST,BST,VST,CTT,JST,ACT,AET,SST,NST,MIT,HST,AST,PST,PNT,MST,CST,EST,IET,PRT,CNT,AGT,BET,CAT,CDT">
			<cfloop query="getLoadDetailsForMP">
				<cfset stopNoVal = "">
				<cfset stopNoTxt = "">

				<cfif getLoadDetailsForMP.stopNO NEQ 0>
					<cfset stopNoVal = getLoadDetailsForMP.stopNO+1>
				</cfif>
				<cfset stopNoTxt = getLoadDetailsForMP.stopNO+1>

				<cfif getLoadDetailsForMP.LoadType EQ 1>
					<cfset stopType='pickup'>
					<cfset fieldType='shipper'>
				<cfelse>
					<cfset stopType='delivery'>
					<cfset fieldType='consignee'>
				</cfif>

				<cfif not len(trim(getLoadDetailsForMP.StopDate))>
					<cfset response.success = 0>
					<cfset response.field = "#fieldType#PickupDate#stopNoVal#">
					<cfset response.error = 'Please provide a #stopType# date for stop #stopNoTxt#.'>
					<cfreturn response>
				</cfif>

				<cfif not len(trim(getLoadDetailsForMP.Address))>
					<cfset response.success = 0>
					<cfset response.field = "#fieldType#location#stopNoVal#">
					<cfset response.error = 'Please provide a #fieldType# adresss for stop #stopNoTxt#.'>
					<cfreturn response>
				</cfif>

				<cfif not len(trim(getLoadDetailsForMP.City))>
					<cfset response.success = 0>
					<cfset response.field = "#fieldType#city#stopNoVal#">
					<cfset response.error = 'Please provide a #fieldType# city for stop #stopNoTxt#.'>
					<cfreturn response>
				</cfif>

				<cfif not len(trim(getLoadDetailsForMP.StateCode))>
					<cfset response.success = 0>
					<cfset response.field = "#fieldType#state#stopNoVal#">
					<cfset response.error = 'Please select a #fieldType# state for stop #stopNoTxt#.'>
					<cfreturn response>
				</cfif>

				<cfif not len(trim(getLoadDetailsForMP.PostalCode))>
					<cfset response.success = 0>
					<cfset response.field = "#fieldType#Zipcode#stopNoVal#">
					<cfset response.error = 'Please provide a #fieldType# zip for stop #stopNoTxt#.'>
					<cfreturn response>
				</cfif>

				<cfif len(trim(getLoadDetailsForMP.TimeZone)) AND NOT listFindNoCase(timeZoneList, getLoadDetailsForMP.TimeZone)>
					<cfset response.success = 0>
					<cfset response.field = "#fieldType#TimeZone#stopNoVal#">
					<cfset response.error = 'Please provide a valid time zone for stop #stopNoTxt# #fieldType#. Time zone should be in Abbreviation format (For example, EST/CST/PST).'>
					<cfreturn response>
				</cfif>

				<cfif getLoadDetailsForMP.LoadType EQ 1>
					<cfset stopType='Pickup'>
				<cfelse>
					<cfset stopType='DropOff'>
				</cfif>

				<cfif not len(trim(getLoadDetailsForMP.StopTime))>
					<cfset StartTime = "00:00">
					<cfset EndTime = "00:00">
				<cfelse>
					<cfloop list="#trim(getLoadDetailsForMP.StopTime)#" index="indxStopTime" delimiters="-">
						<cfif len(trim(indxStopTime)) NEQ 4 OR NOT IsNumeric(trim(indxStopTime))>
							<cfset response.success = 0>
							<cfset response.field = "#fieldType#pickup#stopNoVal#">
							<cfif listLen(getLoadDetailsForMP.StopTime,'-') EQ 2>
								<cfset response.error = 'Invalid Apt. time for stop #stopNoTxt#. Valid format is HHMM-HHMM OR HH:MM-HH:MM.#chr(10)#For example, instead of entering 8am or 4pm please enter 08:00 and 16:00 respectively.'>
							<cfelse>
								<cfset response.error = 'Invalid Apt. time for stop #stopNoTxt#. Valid format is HHMM OR HH:MM.#chr(10)#For example, instead of entering 8am or 4pm please enter 08:00 and 16:00 respectively.'>
							</cfif>
							<cfreturn response>
						</cfif>
					</cfloop>

					<cfset StartTime = Insert(":",listGetAt(getLoadDetailsForMP.StopTime, 1,'-'),2)>

					<cfif listLen(getLoadDetailsForMP.StopTime,'-') EQ 2>
						<cfset EndTime = Insert(":",listGetAt(getLoadDetailsForMP.StopTime, 2,'-'),2)>
					<cfelse>
						<cfset EndTime = Insert(":",listGetAt(getLoadDetailsForMP.StopTime, 1,'-'),2)>
					</cfif>
				</cfif>

				<cfset Date1 = "{ts '#DateFormat(getLoadDetailsForMP.StopDate,'YYYY-MM-DD')# #TRIM(StartTime)#:00'}">
				<cfset Date2 = "{ts '#DateFormat(getLoadDetailsForMP.StopDate,'YYYY-MM-DD')# #TRIM(EndTime)#:00'}">


				<cfif len(trim(getLoadDetailsForMP.TimeZone))>
					<cfset date1LS = DateTimeFormat(Date1,'mmmm dd, yyyy h:nn:ss tt') & ' ' & getLoadDetailsForMP.TimeZone>
					<cfset date2LS = DateTimeFormat(Date2,'mmmm dd, yyyy h:nn:ss tt') & ' ' & getLoadDetailsForMP.TimeZone>
					<cfset date1 = lsParseDateTime(date1LS,"en")>
					<cfset date2 = lsParseDateTime(date2LS,"en")>
					<cfset date1 = dateAdd("h", -1, date1)>
					<cfset date2 = dateAdd("h", -1, date2)>
				</cfif>

				<cfif NOT isvalid("Date",Date1) OR NOT isvalid("Date",Date2)>
			        <cfset response.success = 0>
			        <cfset response.field = 0>
			        <cfset response.error = 'Invaid date/time. Please check Apt. Time.'>
			        <cfreturn response>
			    </cfif>
				<cfset StartDateTime = getIsoTimeString(Date1)>
				<cfset EndDateTime = getIsoTimeString(Date2)>

				<cfif arguments.LastStopEventCompleted eq 1>
					<cfset stopXml &=   '<Stop>
										<Name>#EncodeForXML(getLoadDetailsForMP.CustName)#</Name>
										<StopType>#stopType#</StopType>
										<Address>
											<Line1>#EncodeForXML(getLoadDetailsForMP.Address)#</Line1>
											<Line2></Line2>
											<City>#getLoadDetailsForMP.City#</City>
											<StateOrProvince>#getLoadDetailsForMP.StateCode#</StateOrProvince>
											<PostalCode>#getLoadDetailsForMP.Postalcode#</PostalCode>
										</Address>
										<Latitude></Latitude>
										<Longitude></Longitude>
										<StartDateTime>#StartDateTime#</StartDateTime>
										<EndDateTime>#EndDateTime#</EndDateTime>
										<LastStopEventCompleted>1</LastStopEventCompleted>
									</Stop>'>
				<cfelse>
					<cfset stopXml &=   '<Stop>
										<Name>#EncodeForXML(getLoadDetailsForMP.CustName)#</Name>
										<StopType>#stopType#</StopType>
										<Address>
											<Line1>#EncodeForXML(getLoadDetailsForMP.Address)#</Line1>
											<Line2></Line2>
											<City>#getLoadDetailsForMP.City#</City>
											<StateOrProvince>#getLoadDetailsForMP.StateCode#</StateOrProvince>
											<PostalCode>#getLoadDetailsForMP.Postalcode#</PostalCode>
										</Address>
										<Latitude></Latitude>
										<Longitude></Longitude>
										<StartDateTime>#StartDateTime#</StartDateTime>
										<EndDateTime>#EndDateTime#</EndDateTime>
									</Stop>'>
				</cfif>
			</cfloop>

			<cfif not len(trim(getLoadDetailsForMP.StopTime))>
				<cfset trackingStartTime = "00:00">
			<cfelse>
				<cfset trackingStartTime = Insert(":",listGetAt(getLoadDetailsForMP.StopTime, 1,'-'),2)>
			</cfif>

			<cfset TrackStartDateTime = DateFormat(getLoadDetailsForMP.StopDate,'YYYY-MM-dd')& ' ' & trackingStartTime>

			<cfset TrackStartDateTime = DateTimeFormat(DateAdd("h",-1,TrackStartDateTime),'YYYY-MM-dd HH:nn') & ' ET'>

			<cfset IDNumber = getCompanyDetailsForMP.CompanyName & '_' & getLoadDetailsForMP.LoadNumber>

			<cfset trackingStartDateTime = DateFormat(getLoadDetailsForMP.StopDate,'YYYY-MM-dd')& ' ' & trackingStartTime>

			<cfif listLen(getLoadDetailsForMP.StopTime[getLoadDetailsForMP.recordcount],'-') EQ 2>
				<cfset trackingEndTime = Insert(":",listGetAt(getLoadDetailsForMP.StopTime[getLoadDetailsForMP.recordcount], 2,'-'),2)>
			<cfelse>
				<cfset trackingEndTime = Insert(":",listGetAt(getLoadDetailsForMP.StopTime[getLoadDetailsForMP.recordcount], 1,'-'),2)>
			</cfif>

			<cfset trackingEndDateTime = DateFormat(DateAdd('d',1,getLoadDetailsForMP.StopDate[getLoadDetailsForMP.recordcount]),'YYYY-MM-dd')& ' ' & trackingEndTime>

			<cfset TrackDurationInHours =dateDiff("h", trackingStartDateTime, trackingEndDateTime)>


			<cfset xmlMpOrder = 	'<Order xmlns="http://macropoint-lite.com/xml/1.0">
					<TrackVia>
						<Number Type="Mobile">#getLoadDetailsForMP.DriverCell#</Number>
					</TrackVia>
					<TrackStartDateTime>#TrackStartDateTime#</TrackStartDateTime>
					<Notifications>
						<Notification>
							<PartnerMPID>#getApiDetailsForMP.MacropointId#</PartnerMPID>
							<IDNumber>#IDNumber#</IDNumber>
							<TrackDurationInHours>#TrackDurationInHours#</TrackDurationInHours>
							<TrackIntervalInMinutes>#getApiDetailsForMP.GPSUpdateInterval#</TrackIntervalInMinutes>
						</Notification>
				 	</Notifications>
				 	<Carrier>
						<Name>#EncodeForXML(getLoadDetailsForMP.CarrierName)#</Name>
						<CarrierID>#getLoadDetailsForMP.CarrierID#</CarrierID>
				 	</Carrier>
				 	<TripSheet>
				 		<Stops>
				 			#stopXml#
				 		</Stops>
				 	</TripSheet>
				</Order>'>

			<cfset http_url = "https://macropoint-lite.com/api/1.0/orders/createorder">

			<cfif len(trim(getLoadDetailsForMP.MacroPointOrderID))> 
				<cfif getLoadDetailsForMP.CarrierID EQ getLoadDetailsForMP.MacroPointCarrierID>
					<cfset http_url = "https://macropoint-lite.com/api/1.0/orders/changeorder/#getLoadDetailsForMP.MacroPointOrderID#">
				<cfelse>
					<cfhttp url="https://macropoint-lite.com/api/1.0/orders/stoporder/#getLoadDetailsForMP.MacroPointOrderID#" method="POST" result="MpResult">
						<cfhttpparam type="HEADER" name="Authorization" value="Basic #MacropointApiLoginId#">
					</cfhttp>
				</cfif>
			</cfif>
			<cfhttp url="#http_url#" method="POST" result="MpResult">
				<cfhttpparam type="HEADER" name="Authorization" value="Basic #MacropointApiLoginId#">
				<cfhttpparam type="xml"  value="#trim( xmlMpOrder )#" />
			</cfhttp>
			<cfif MpResult.Statuscode EQ '401 Unauthorized'>
				<cfset response.success = 0>
				<cfset response.field = 0>
				<cfset response.error = "Invalid API Login.">
				<cfreturn response>
			</cfif>
			<cfif MpResult.Filecontent EQ 'Connection Failure' OR NOT Len(MpResult.Filecontent)>
				<cfset response.success = 0>
				<cfset response.field = 0>
				<cfset response.error = "Connection Failure.">
				<cfreturn response>
			</cfif>
			<cfif findNoCase('504 Gateway Time-out', MpResult.Filecontent)>
				<cfset response.success = 0>
				<cfset response.field = 0>
				<cfset response.error = "Unable to Connect Macropoint now. Please try again later.">
				<cfreturn response>
			</cfif>
			<cfif findNoCase('502 Bad Gateway', MpResult.Filecontent)>
				<cfset response.success = 0>
				<cfset response.field = 0>
				<cfset response.error = "Unable to Connect Macropoint now. Please try again later.">
				<cfreturn response>
			</cfif>
			<cfset variables.resStruct = ConvertXmlToStruct(MpResult.Filecontent, StructNew())>

			<cfif variables.resStruct.Status EQ 'Failure'>
				<cfset response.success = 0>
				<cfset response.field = 0>
				<cfif isArray(variables.resStruct.Errors.Error)>
					<cfset response.error = variables.resStruct.Errors.Error[1].Message>
				<cfelse>
					<cfset response.error = variables.resStruct.Errors.Error.Message>
				</cfif>
				<cfreturn response>
			<cfelse>
				<cfif NOT len(trim(getLoadDetailsForMP.MacroPointOrderID)) OR (len(trim(getLoadDetailsForMP.MacroPointOrderID)) AND getLoadDetailsForMP.CarrierID NEQ getLoadDetailsForMP.MacroPointCarrierID)> 
					<cfquery name="setLoadDetailsForMP" datasource="#trim(listFirst(cgi.SCRIPT_NAME,'/'))#">
						UPDATE Loads Set 
						MacroPointOrderID = <cfqueryparam value="#variables.resStruct.OrderID#" cfsqltype="cf_sql_varchar">
						,MacroPointCarrierID= <cfqueryparam value="#getLoadDetailsForMP.CarrierID#" cfsqltype="cf_sql_varchar">
						<cfif getApiDetailsForMP.EDispatchOptions EQ 2>
							,IsEDispatched= 3
						<cfelse>
							,IsEDispatched= 4
						</cfif>
						WHERE LoadID = <cfqueryparam value="#arguments.LoadID#" cfsqltype="cf_sql_varchar">
					</cfquery>

					<cfquery name="qCreateEDispatchLog" datasource="#trim(listFirst(cgi.SCRIPT_NAME,'/'))#">
						INSERT INTO EDispatchLog (type,username,loadnumber,driverphone,carrieremail,customerid,carrierid,loadid)
						VALUES(
								<cfqueryparam value="Macropoint" cfsqltype="cf_sql_varchar">,
								<cfqueryparam value="#arguments.user#" cfsqltype="cf_sql_varchar">,
								<cfqueryparam value="#getLoadDetailsForMP.loadnumber#" cfsqltype="cf_sql_varchar">,
								<cfqueryparam value="#getLoadDetailsForMP.DriverCell#" cfsqltype="cf_sql_varchar">,
								<cfqueryparam value="#getLoadDetailsForMP.EmailID#" cfsqltype="cf_sql_varchar">,
								<cfqueryparam value="#getLoadDetailsForMP.PayerID#" cfsqltype="cf_sql_varchar">,
								<cfqueryparam value="#getLoadDetailsForMP.CarrierID#" cfsqltype="cf_sql_varchar">,
								<cfqueryparam value="#getLoadDetailsForMP.LoadID#" cfsqltype="cf_sql_varchar">
							)
					</cfquery>
				</cfif>
				<cfif NOT len(trim(getLoadDetailsForMP.GPSDeviceID)) OR trim(getLoadDetailsForMP.GPSDeviceID) EQ 0> 
					<cfset GPSDeviceID =DateFormat(Now(),"YYMMDD")&TimeFormat(Now(),"hhmmss")&getLoadDetailsForMP.LoadNumber>
					<cfquery name="setLoadDetailsForMP" datasource="#trim(listFirst(cgi.SCRIPT_NAME,'/'))#">
						UPDATE Loads Set GPSDeviceID = <cfqueryparam value="#GPSDeviceID#" cfsqltype="cf_sql_varchar">
						WHERE LoadID = <cfqueryparam value="#arguments.LoadID#" cfsqltype="cf_sql_varchar">
					</cfquery>
				</cfif>
				<cfset response.success = 1>
				<cfreturn response>
			</cfif>
			<cfcatch type="any">
				<cfset var template = "">
				<cfset var companycode ="">
				<cfset var sourcepage = "">
				<cfset var errordetail = "">

				<cfif structKeyExists(cfcatch, "TagContext") AND isArray(cfcatch.TagContext) AND NOT arrayIsEmpty(cfcatch.TagContext) AND isstruct(cfcatch.TagContext[1]) AND structKeyExists(cfcatch.TagContext[1], "raw_trace")>
					<cfset template = cfcatch.TagContext[1].raw_trace>
				</cfif>
				
				<cfif structkeyexists(arguments,"companyid")>
					<cfquery name="qGetCompanyCode" datasource="#trim(listFirst(cgi.SCRIPT_NAME,'/'))#">
						SELECT CompanyCode FROM Companies WHERE CompanyID = <cfqueryparam value="#arguments.companyid#" cfsqltype="cf_sql_varchar">
					</cfquery>
					<cfset companycode = qGetCompanyCode.companycode>
				</cfif>

				<cfif isDefined("cgi.HTTP_REFERER")>
					<cfset sourcepage = "#chr(10)#[Sourcepage]:#cgi.HTTP_REFERER#">
				</cfif>

				<cfif isDefined('cfcatch.cause.Detail') and isDefined('cfcatch.cause.Message')>
					<cfset errordetail = "#cfcatch.cause.Detail##cfcatch.cause.Message#">
				<cfelseif isDefined('cfcatch.Message') >
					<cfset errordetail = "#cfcatch.Message#">
				</cfif>

				<cffile action="append" file="#ExpandPath("../webroot/logs")#/Application.Log.txt" output="#dateTimeFormat(now())##chr(10)##errordetail#loadgateway.cfc:saveMacroPointOrder#chr(10)#[ArgumentData]:#SerializeJSON(arguments)##chr(10)##trim(template)#">

				<cfquery name="qInsLog" datasource="LoadManagerAdmin">
	       			INSERT INTO LMErrorLog (CompanyCode,Detail,Status,FormData,URLData,Template,SourcePage)
	       			VALUES (
	       				<cfqueryparam value="#companycode#" cfsqltype="cf_sql_varchar">
	       				,<cfqueryparam value="#errordetail#" cfsqltype="cf_sql_varchar">
	       				,'Pending'
	       				<cfif isDefined("arguments")>
	       					,<cfqueryparam value="#SerializeJSON(arguments)#" cfsqltype="cf_sql_varchar">
	       				<cfelse>
	       					,NULL
	       				</cfif>
	       				,<cfqueryparam value="#SerializeJSON(url)#" cfsqltype="cf_sql_varchar">
	       				,<cfqueryparam value="#Template#" cfsqltype="cf_sql_varchar">
	       				<cfif isDefined("cgi.HTTP_REFERER")>
	       					,<cfqueryparam value="#cgi.HTTP_REFERER#" cfsqltype="cf_sql_varchar">
	       				<cfelse>
	       					,NULL
	       				</cfif>
	       				)
	       		</cfquery>

		        <cfset response = structNew()>
		        <cfset response.success = 0>
		        <cfset response.field = 0>
		        <cfset response.error = 'Something went wrong. Please contact support.'>
		        <cfreturn response>
		    </cfcatch>
		</cftry>

	</cffunction>

	<cffunction name="stopMacroPointOrder" access="remote" returntype="any" returnformat="json">
		<cfargument name="OrderID" required="yes" type="string"/>
		<cfargument name="CompanyID" required="yes" type="string"/>
		<cftry>
			<cfquery name="getApiDetailsForMP" datasource="#trim(listFirst(cgi.SCRIPT_NAME,'/'))#">
				SELECT MacropointApiLogin,MacropointApiPassword FROM systemconfig
				WHERE CompanyID= <cfqueryparam value="#arguments.CompanyID#" cfsqltype="cf_sql_varchar">
			</cfquery>

			<cfif not len(trim(getApiDetailsForMP.MacropointApiLogin)) OR not len(trim(getApiDetailsForMP.MacropointApiPassword))>
				<cfset response = structNew()>
		        <cfset response.success = 0>
		        <cfset response.message = 'Macropoint error:Unable to stop the order.Please setup macropoint api crendentials on systemconfig.'>
		        <cfreturn response>
		    <cfelse>
		    	<cfset MacropointApiLoginId = toBase64('#trim(getApiDetailsForMP.MacropointApiLogin)#:#trim(getApiDetailsForMP.MacropointApiPassword)#')>
	        </cfif>
	
			<cfhttp url="https://macropoint-lite.com/api/1.0/orders/stoporder/#OrderID#" method="POST" result="MpResult">
				<cfhttpparam type="HEADER" name="Authorization" value="Basic #MacropointApiLoginId#">
			</cfhttp>
			<cfset response = structNew()>
	        <cfset response.success = 1>
	        <cfset response.message = 'Order stopped successfully on macropoint.'>
	        <cfreturn response>
			<cfcatch type="any">
		        <cfset response = structNew()>
		        <cfset response.success = 0>
		        <cfset response.message = 'Macropoint error:Unable to stop the order.'>
		        <cfreturn response>
		    </cfcatch>
		</cftry>
	</cffunction>
	
	<cffunction name="getIsoTimeString" access="public" returntype="string">
		<cfargument name="datetime" required="yes" type="date">

		<cfset datetime = dateConvert( "local2utc", arguments.datetime )>

		<cfreturn dateFormat( datetime, "yyyy-mm-dd" ) &
            "T" &
            timeFormat( datetime, "HH:mm:ss" ) &
            "Z">
	</cffunction>

	<cffunction name="getMPLoadDetails" access="public" returntype="query">
		<cfargument name="LoadID" required="yes" type="string">
		<cfquery name="qLoadDetailsForMP" datasource="#trim(listFirst(cgi.SCRIPT_NAME,'/'))#">
			SELECT 
				L.LoadID
				,L.MacroPointOrderID
				,ISNULL(LS.NewDriverCell,LS.NewDriverCell2)  AS DriverCell
				,LS.StopNo
				,LS.LoadType
				,LS.StopDate
				,LS.StopTime
				,LS.TimeIn
				,LS.TimeOut
				,LS.CustName
				,LS.Address
				,LS.City
				,LS.StateCode
				,LS.PostalCode
				,C.CarrierID
				,C.CarrierName
			FROM Loads L
			LEFT JOIN LoadStops LS ON LS.LoadID = L.LoadID 
			LEFT JOIN Carriers C ON C.CarrierID = L.CarrierID
			WHERE L.LoadID = <cfqueryparam value="#arguments.LoadID#" cfsqltype="cf_sql_varchar">  
			ORDER BY LS.StopNo,LS.LoadType 
		</cfquery>
	    <cfreturn qLoadDetailsForMP>
	</cffunction>

	<cffunction name="getEmailLocationUpdateEmails" access="public" returntype="any">
		<cfargument name="loadid" required="yes" type="any">

		<cftry>
			<cfquery name="qEmailLocationUpdateEmails" datasource="#variables.dsn#">
		    	SELECT 
				E.EmailID AS DispatcherEmail,
				(select TOP 1 Email from customercontacts cc where cc.customerid = C.customerid and cc.contacttype='Billing') AS CustomerEmail
				FROM Loads L 
				LEFT JOIN Employees E ON E.EmployeeID = L.DispatcherID
				LEFT JOIN Customers C ON C.CustomerID = L.CustomerID
				WHERE L.LoadID = <cfqueryparam value="#arguments.LoadID#" cfsqltype="cf_sql_varchar">
			</cfquery>
			<cfcatch>
				<cfreturn 0>
			</cfcatch>
		 </cftry>

		<cfreturn qEmailLocationUpdateEmails>

	</cffunction>

	<cffunction name="getLoadStatusUpdateMailDetails" access="public" returntype="query">
		<cfargument name="LoadID" required="yes" type="any">

		<cfset var MapLink ="">
		<cfif cgi.https EQ 'on'>
			<cfset mapLink = "https://">
		<cfelse>
			<cfset mapLink = "http://">
		</cfif>
		<cfset mapLink &= "#cgi.HTTP_HOST#/#application.dsn#/www/webroot/index.cfm?event=Googlemap&LoadID=#arguments.LoadID#">

		<cfquery name="qLoadDetails" datasource="#application.dsn#">
			SELECT 
			L.LoadNumber
			,L.ContactEmail
			,E.EmailID AS SalesRepEmail
			,E1.EmailID AS DispatcherEmail
			,L.EmailList
			,'#MapLink#' AS MapLink
			,LST.StatusText
			,LST.StatusDescription
			,LS.CustName
			,LS.Address
			,LS.City
			,LS.StateCode
			,LS.PostalCode
			,LS.ContactPerson
			,LS.Phone
			,L.LoadStatusStopNo
			,L.CustomerPONo
			FROM Loads L 
			INNER JOIN LoadStatusTypes LST ON LST.StatusTypeID = L.StatusTypeID
			INNER JOIN LoadStops LS ON LS.LoadID = L.LoadID
			LEFT JOIN Employees E ON E.EmployeeID = L.SalesRepID
			LEFT JOIN Employees E1 ON E1.EmployeeID = L.DispatcherID
			WHERE L.LoadID = <cfqueryparam value="#arguments.LoadID#" cfsqltype="cf_sql_varchar">
			ORDER BY LS.StopNo,LS.LoadType
		</cfquery>
		
		<cfreturn qLoadDetails>
	</cffunction>

	<cffunction name="generateGoogleMapLink" access="remote" output="yes" returntype="string" returnformat="plain">
		<cfargument name="loadId" type="string" required="yes" >
		<cfargument name="dsn" type="string" required="yes">
		<cfargument name="isLoadList" type="boolean" required="no" default="0">
		<cfargument name="CompanyID" type="string" required="yes" >
		<cftry>
			<cfif cgi.https EQ 'on'>
				<cfset mapLink = "https://">
			<cfelse>
				<cfset mapLink = "http://">
			</cfif>
			<cfset mapLink &= "#cgi.HTTP_HOST#/#arguments.dsn#/www/views/pages/load/createFullMap.cfm?">

			<cfquery name="qGetLoadDetails" datasource="#arguments.dsn#">
				SELECT 
				L.LoadNumber,
				LS.STOPNO,
				LS.LoadType,
				LS.CustName,
				LS.Address,
				LS.City,
				LS.StateCode,
				LS.PostalCode,
				LS.NewDriverName
				FROM Loads L
				JOIN LoadStops LS ON L.LoadID = LS.LoadID
				WHERE L.LoadID = <cfqueryparam value="#arguments.LoadID#" cfsqltype="cf_sql_varchar">
				ORDER BY LS.StopNo,LS.LoadType
			</cfquery>

			<cfset mapLink &= 'loadNum=#qGetLoadDetails.LoadNumber#'>

			<cfloop query="qGetLoadDetails">
				<cfif qGetLoadDetails.STOPNO EQ 0>
					<cfset stpNo = ''>
				<cfelse>
					<cfset stpNo = qGetLoadDetails.STOPNO+1>
				</cfif>

				<cfif qGetLoadDetails.LoadType EQ 1>
					<cfset stpType = 'Shp'>
				<cfelse>
					<cfset stpType = 'Con'>
				</cfif>
				<cfset mapLink &= '&#stpType#Nm#stpNo#=#qGetLoadDetails.CustName#&#stpType#Add#stpNo#=#URLEncodedFormat(qGetLoadDetails.Address&' '&qGetLoadDetails.City&', '&qGetLoadDetails.StateCode&' '&qGetLoadDetails.PostalCode)#'>
			</cfloop>

			<cfset driverNameList = ListChangeDelims(listremoveduplicates(valueList(qGetLoadDetails.NewDriverName)), ", ")>

			<cfset mapLink &= '&currLocDiver=#replace(driverNameList,"'","\'")#'>
			<cfset mapLink &= '&getdirection'>

			<cfif arguments.isLoadList>
				<cfinvoke  method="getLoadLastPosition" returnvariable="qGetLoadLastPosition" dsn="#arguments.dsn#" LoadID="#arguments.LoadID#" CompanyID="#arguments.companyid#"/>
				<cfif structKeyExists(qGetLoadLastPosition, "res") AND structKeyExists(qGetLoadLastPosition.res, "latitude")>
					<cfset mapLink &= '&currLocLat=#qGetLoadLastPosition.res.latitude#&currLocLng=#qGetLoadLastPosition.res.longitude#&currLocDateTime=#DateTimeFormat(qGetLoadLastPosition.res.devicetime,"mmmm, dd yyyy HH:nn")#&currLocEquipment=#qGetLoadLastPosition.res.EquipmentName#&deviceid=#qGetLoadLastPosition.res.deviceid#&positionid=#qGetLoadLastPosition.res.id#'>
				</cfif>			
			</cfif>
			<cfreturn '#mapLink#'>
			<cfcatch>
				<cfreturn 'error'>
			</cfcatch>
		</cftry>
	</cffunction>

	<cffunction name="updateLoadStatusDispatched" access="remote" returntype="any">
		<cfargument name="LoadID" required="yes" type="string" />
		<cfargument name="dsn" required="yes" type="string" />
		<cfargument name="clock" required="yes" type="string" />
		<cfargument name="user" required="yes" type="string" />
		<cfargument name="companyid" required="yes" type="string" />
		<cfargument name="dispatchStatusDesc" required="no" type="string" default="DISPATCHED"/>
		<cfset dispatchNote = '#arguments.clock# - #arguments.user# > Status changed to #arguments.dispatchStatusDesc#'>

		<cfquery name="updateLoad" datasource="#arguments.dsn#">
			UPDATE Loads
			SET
				StatusTypeID = (select statustypeid from LoadStatusTypes where StatusText='3. DISPATCHED' and companyid ='#arguments.companyid#')
				,NewDispatchNotes = <cfqueryparam value="#dispatchNote##chr(13)##chr(10)#" cfsqltype="cf_sql_varchar"> + NewDispatchNotes
			WHERE LoadID = <cfqueryparam value="#arguments.LoadID#" cfsqltype="cf_sql_varchar">
		</cfquery>
		<cfreturn 1>
	</cffunction>

	<cffunction name="ajxUpdDispatchNote" access="remote" returntype="any">
		<cfargument name="LoadID" required="yes" type="string" />
		<cfargument name="dsn" required="yes" type="string" />
		<cfargument name="notes" required="yes" type="string" />

		<cfquery name="updateLoad" datasource="#arguments.dsn#">
			UPDATE Loads
			SET
				NewDispatchNotes = <cfqueryparam value="#arguments.notes#" cfsqltype="cf_sql_varchar">
			WHERE LoadID = <cfqueryparam value="#arguments.LoadID#" cfsqltype="cf_sql_varchar">
		</cfquery>
		<cfreturn 1>
	</cffunction>

	<cffunction name="addToConsolidatedInvoice" access="remote" output="yes" returnformat="json">
		<cfargument name="loadNumbers" type="array" required="yes" />
		<cfargument name="dsn" type="string" required="yes" />
		<cfargument name="empid" type="string" required="yes" />
		<cfargument name="adminusername" type="string" required="yes" />
		<cftry>
			<cftransaction>
			<cfset local.dsn = trim(listFirst(cgi.SCRIPT_NAME,'/'))>
			<cfset ArrayDelete(arguments.loadNumbers,0)>
			<cfset local.loadnumbers=ArrayToList(arguments.loadNumbers,",")>
			<cfquery name="qryGetDetailsToQueue" datasource="#local.dsn#">
				SELECT LoadID,L.CustomerID,CS.CustomerName,TotalCustomerCharges,LoadNumber
				FROM LOADS L INNER JOIN Customers CS
				ON L.CustomerID= CS.CustomerID
				where loadid in (<cfqueryparam value="#local.loadnumbers#" cfsqltype="cf_sql_varchar" list="true">)
				group by L.CustomerID,CustomerName,LoadID,TotalCustomerCharges,LoadNumber
				order by L.CustomerID,CustomerName,LoadID,LoadNumber
			</cfquery>
			<cfset prevPayerID = "">
			<cfset TotalAmount = 0>
			<cfset TotalLoads = 0>
			<cfloop query="qryGetDetailsToQueue">
				<cfif prevPayerID EQ "" OR prevPayerID NEQ '#qryGetDetailsToQueue.CustomerID#'>
					<cfset TotalAmount = 0>
					<cfset TotalLoads = 0>

					<cfquery name="getExistingConsolidated" datasource="#local.dsn#">
						SELECT count(ID) as ExistsCustomer, ID from LoadsConsolidated
						WHERE Customerid = '#qryGetDetailsToQueue.CustomerID#'
						AND Status = 'OPEN'
						GROUP BY ID
					</cfquery>

					<cfif getExistingConsolidated.Recordcount EQ 0 >
						<cfquery name="qget" datasource="#local.dsn#">
							SELECT NEWID() AS NewConsolidatedID
						</cfquery>
						<cfset ConsolidatedID = '#qget.NewConsolidatedID#'>
						<cfquery name="insertToQueue" datasource="#local.dsn#">
							INSERT INTO LoadsConsolidated (ID,Date,Description,CustomerID,Status,LoadCount,Amount,CreatedBy)
							Values( 
									'#qget.NewConsolidatedID#'
									,getdate()
									,'#qryGetDetailsToQueue.CustomerName#'
									,'#qryGetDetailsToQueue.CustomerID#'
									,'OPEN'
									, 0
									,'0.00'
									,<cfqueryparam value="#arguments.adminusername#" cfsqltype="cf_sql_nvarchar">
									)
						</cfquery>
					<cfelse>
						<cfset ConsolidatedID = '#getExistingConsolidated.ID#'>
					</cfif>
					<cfset prevPayerID = '#qryGetDetailsToQueue.CustomerID#'>
				</cfif>

				<cfquery name="getExistingConsolidatedDetail" datasource="#local.dsn#">
					SELECT count(ConsolidatedID) as ExistsLoad FROM LoadsConsolidatedDetail 
					where ConsolidatedID = '#ConsolidatedID#'
					AND LoadID = '#qryGetDetailsToQueue.LoadID#'
				</cfquery>

				<cfif getExistingConsolidatedDetail.ExistsLoad EQ 0>
					<cfquery name="insertToQueueDetail" datasource="#local.dsn#">
						INSERT INTO LoadsConsolidatedDetail 
									(ConsolidatedID,LoadID,CreatedBy)
							Values( 
									 '#ConsolidatedID#'						
									,'#qryGetDetailsToQueue.LoadID#'	
									,<cfqueryparam value="#arguments.adminusername#" cfsqltype="cf_sql_nvarchar">					
									)
					</cfquery>
					<cfset TotalAmount = TotalAmount + qryGetDetailsToQueue.TotalCustomerCharges>
					<cfset TotalLoads = TotalLoads + 1>
					<cfquery name="updateLoadsConsolidated" datasource="#local.dsn#">
						UPDATE LoadsConsolidated
							SET Amount = #TotalAmount#
							   ,LoadCount = LoadCount+1
						WHERE ID ='#ConsolidatedID#'						
									
					</cfquery>
					<cfquery name="insertLoadLog" datasource="#local.dsn#">
						INSERT INTO LoadLogs (
								LoadID,
								LoadNumber,
								FieldLabel,
								oldValue,
								NewValue,
								UpdatedByUserID,
								UpdatedBy,
								UpdatedTimestamp
							)
						values
							(
								<cfqueryparam value="#qryGetDetailsToQueue.LoadID#" cfsqltype="cf_sql_nvarchar">,
								<cfqueryparam value="#qryGetDetailsToQueue.LoadNumber#" cfsqltype="cf_sql_bigint">,
								<cfqueryparam value="Added To Consolidated Invoice" cfsqltype="cf_sql_nvarchar">,
								NULL,
								(SELECT ConsolidatedInvoiceNumber FROM LoadsConsolidated WHERE id = '#ConsolidatedID#'),
								<cfqueryparam value="#arguments.empid#" cfsqltype="cf_sql_nvarchar">,
								<cfqueryparam value="#arguments.adminusername#" cfsqltype="cf_sql_nvarchar">,
								<cfqueryparam value="#Now()#" cfsqltype="cf_sql_timestamp">
							)
					</cfquery>
				</cfif>
			</cfloop>
			</cftransaction>
			<cfset retStruct = structNew()>			
			<cfset retStruct.status=true>
			<cfreturn  serializeJSON(retStruct)>
			<cfcatch>
				<cfset retStruct = structNew()>			
				<cfset retStruct.status=false>
				<cfreturn  serializeJSON(retStruct)>
			</cfcatch>
		</cftry>
	</cffunction>

	<cffunction name="getLoadConsolidatedDetail" access="public" returntype="query">
		<cfargument name="LoadID" type="string">
		<cfquery name="qgetLoadConsolidatedDetail" datasource="#variables.dsn#">
			SELECT * FROM LoadsConsolidated LC
			JOIN LoadsConsolidatedDetail LCD ON LC.ID = LCD.ConsolidatedID
			AND LCD.LoadID = <cfqueryparam value="#arguments.LoadID#" cfsqltype="cf_sql_varchar">
		</cfquery>
		<cfreturn qgetLoadConsolidatedDetail>
	</cffunction>

	<cffunction name="removeFromConsolidatedInvoice" access="remote" output="yes" returntype="Any" returnformat="plain">
		<cfargument name="LoadNo" type="string" required="yes" />
		<cfargument name="dsn" type="string" required="yes" />
		<cfargument name="empid" type="string" required="yes" />
		<cfargument name="adminusername" type="string" required="yes" />
		<cftry>
			<cfset variables.TheKey = 'NAMASKARAM'>
			<cfset local.dsn = trim(listFirst(cgi.SCRIPT_NAME,'/'))>

			<cfquery name="qgetLoadConsolidatedDetail" datasource="#local.dsn#">
				SELECT * FROM LoadsConsolidated LC
				JOIN LoadsConsolidatedDetail LCD ON LC.ID = LCD.ConsolidatedID
				AND LCD.LoadID = <cfqueryparam value="#arguments.LoadNo#" cfsqltype="cf_sql_varchar">
				AND LC.Status = 'OPEN'
			</cfquery>

			<cfquery name="qDeleteLoadConsolidatedDetail" datasource="#local.dsn#">
				DELETE FROM LoadsConsolidatedDetail WHERE 
				ConsolidatedID = <cfqueryparam value="#qgetLoadConsolidatedDetail.ConsolidatedID#" cfsqltype="cf_sql_varchar"> 
				AND LoadId = <cfqueryparam value="#qgetLoadConsolidatedDetail.LoadId#" cfsqltype="cf_sql_varchar">
			</cfquery>
			<cfquery name="insertLoadLog" datasource="#local.dsn#">
				INSERT INTO LoadLogs (
						LoadID,
						LoadNumber,
						FieldLabel,
						oldValue,
						NewValue,
						UpdatedByUserID,
						UpdatedBy,
						UpdatedTimestamp
					)
				values
					(
						<cfqueryparam value="#arguments.LoadNo#" cfsqltype="cf_sql_nvarchar">,
						(SELECT LoadNumber FROM Loads WHERE LoadID = <cfqueryparam value="#arguments.LoadNo#" cfsqltype="cf_sql_nvarchar">),
						<cfqueryparam value="Removed From Consolidated Invoice" cfsqltype="cf_sql_nvarchar">,
						'#qgetLoadConsolidatedDetail.ConsolidatedInvoiceNumber#',
						NULL,
						<cfqueryparam value="#arguments.empid#" cfsqltype="cf_sql_nvarchar">,
						<cfqueryparam value="#arguments.adminusername#" cfsqltype="cf_sql_nvarchar">,
						<cfqueryparam value="#Now()#" cfsqltype="cf_sql_timestamp">
					)
			</cfquery>
			<cfif qgetLoadConsolidatedDetail.LoadCount EQ 1>
				<cfquery name="qDeleteLoadConsolidated" datasource="#local.dsn#">
					DELETE FROM LoadsConsolidated WHERE ID = <cfqueryparam value="#qgetLoadConsolidatedDetail.ID#" cfsqltype="cf_sql_varchar"> 
				</cfquery>
			<cfelse>
				<cfquery name="qUpdateLoadConsolidated" datasource="#local.dsn#">
					UPDATE LoadsConsolidated SET LoadCount = LoadCount - 1 WHERE ID = <cfqueryparam value="#qgetLoadConsolidatedDetail.ID#" cfsqltype="cf_sql_varchar"> 
				</cfquery>
			</cfif>

			<cfset retStruct = structNew()>			
			<cfset retStruct.status=true>
			<cfreturn  serializeJSON(retStruct)>
			<cfcatch>
				<cfset retStruct = structNew()>			
				<cfset retStruct.status=false>
				<cfreturn  serializeJSON(retStruct)>
			</cfcatch>
		</cftry>

	</cffunction>

	<cffunction name="changeConsolidatedStatus" access="remote" output="yes" returntype="Any" returnformat="plain">
		<cfargument name="ConsolidatedInvoiceNumber" type="string" required="yes" />
		<cfargument name="dsn" type="string" required="yes" />
		<cfargument name="Status" type="string" required="yes" />
		<cfargument name="CustomerID" type="string" required="yes" />
		<cfargument name="CompanyID" type="string" required="yes" />
		<cfargument name="ConsolidatedID" type="string" required="yes" />
		<cftry>
			<cfset local.dsn = trim(listFirst(cgi.SCRIPT_NAME,'/'))>

			<cfif arguments.Status eq 'OPEN'>
				<cfquery name="qryCheckOPEN" datasource="#local.dsn#">
					UPDATE LoadsConsolidated SET Status = 'CLOSED' WHERE ID = <cfqueryparam value="#arguments.ConsolidatedID#" cfsqltype="cf_sql_varchar">
				</cfquery>
				<cfquery name="qGetSystemConfig" datasource="#local.dsn#">
					SELECT ConsolidateInvoiceStatusUpdate,StatusText,ConsolidateInvoiceDateUpdate FROM SystemConfig LEFT JOIN LoadStatusTypes ON SystemConfig.ConsolidateInvoiceStatusUpdate = LoadStatusTypes.StatusTypeID
					WHERE SystemConfig.CompanyID = <cfqueryparam value="#arguments.CompanyID#" cfsqltype="cf_sql_varchar">
				</cfquery>
				<cfif len(trim(qGetSystemConfig.ConsolidateInvoiceStatusUpdate))>
					<cfquery name="qUpd" datasource="#local.dsn#">
						UPDATE Loads SET StatusTypeID = <cfqueryparam value="#qGetSystemConfig.ConsolidateInvoiceStatusUpdate#" cfsqltype="cf_sql_varchar">
						WHERE LoadID IN (SELECT LoadID FROM LoadsConsolidatedDetail WHERE ConsolidatedID = <cfqueryparam value="#arguments.ConsolidatedID#" cfsqltype="cf_sql_varchar">)
					</cfquery>
				</cfif>
				<cfif qGetSystemConfig.ConsolidateInvoiceDateUpdate EQ 1>
					<cfquery name="qUpd" datasource="#local.dsn#">
						UPDATE Loads SET BillDate = getdate()
						WHERE LoadID IN (SELECT LoadID FROM LoadsConsolidatedDetail WHERE ConsolidatedID= <cfqueryparam value="#arguments.ConsolidatedID#" cfsqltype="cf_sql_varchar">)
					</cfquery>
				</cfif>
				<cfset retStruct = structNew()>			
				<cfset retStruct.status="CLOSED">
				<cfset var respMsg="">
				<cfif len(trim(qGetSystemConfig.ConsolidateInvoiceStatusUpdate))>
					<cfset respMsg&="Load Statuses have been updated to #qGetSystemConfig.StatusText#.#Chr(10)#">
				</cfif>
				<cfif qGetSystemConfig.ConsolidateInvoiceDateUpdate EQ 1>
					<cfset respMsg&="Invoice Date has been updated to #DateFormat(now(),'mm/dd/yyyy')#.#Chr(10)#">
				</cfif>
				<cfset respMsg&="Consolidated Invoice was CLOSED successfully.">
				<cfset retStruct.msg=respMsg>
				<cfreturn  serializeJSON(retStruct)>
			<cfelse>
				<cfquery name="qryCheckOPEN" datasource="#local.dsn#">
					SELECT ConsolidatedInvoiceNumber FROM LoadsConsolidated WHERE CustomerID = <cfqueryparam value="#arguments.CustomerID#" cfsqltype="cf_sql_varchar"> AND Status = 'OPEN'
				</cfquery>
				<cfif qryCheckOPEN.recordcount>
					<cfset retStruct = structNew()>	
					<cfset retStruct.status=arguments.Status>
					<cfset retStruct.msg="There is already an open consolidation. Consolidation###qryCheckOPEN.ConsolidatedInvoiceNumber#. Please close that out before trying to open this one.">
					<cfreturn  serializeJSON(retStruct)>
				<cfelse>
					<cfquery name="qryCheckOPEN" datasource="#local.dsn#">
						UPDATE LoadsConsolidated SET Status = 'OPEN' WHERE ID = <cfqueryparam value="#arguments.ConsolidatedID#" cfsqltype="cf_sql_varchar">
					</cfquery>
					<cfset retStruct = structNew()>			
					<cfset retStruct.status="OPEN">
					<cfset retStruct.msg="Status changed sucessfully.">
					<cfreturn  serializeJSON(retStruct)>
				</cfif>
			</cfif>
			<cfcatch>

				<cfset retStruct = structNew()>			
				<cfset retStruct.status=arguments.status>
				<cfset retStruct.msg="Something went wrong. Please contact support">
				<cfreturn  serializeJSON(retStruct)>
			</cfcatch>
		</cftry>

	</cffunction>

	<cffunction name="sendProject44" access="remote" returntype="string">
		
		<cfset local.dsn = trim(listFirst(cgi.SCRIPT_NAME,'/'))>
		
		<cfif structKeyExists(cgi,'REMOTE_ADDR') and cgi.REMOTE_ADDR NEQ "127.0.0.1">
			Aborted<cfabort>
		</cfif>

		<cfquery name="qSystemSetupOptions" datasource="#local.dsn#">
			SELECT EDispatchOptions FROM SystemConfig
		</cfquery>

		<cfif listFind("1,2,3", qSystemSetupOptions.EDispatchOptions)>
			<cfset GPSDataSource = "ZGPSTrackingMPWeb">
		<cfelse>
			<cfset GPSDataSource = "ZGPSTracking">
		</cfif>

		<cfquery name="getPositions" datasource="#local.dsn#">
			SELECT 
			C.SCAC
			,C.MCNumber
			,C.DOTNumber
			,(SELECT TOP 1 P.Latitude FROM [#GPSDataSource#].[dbo].[Positions] P WHERE P.deviceid = D.id ORDER BY P.servertime DESC) AS Latitude
			,(SELECT TOP 1 P.Longitude FROM [#GPSDataSource#].[dbo].[Positions] P WHERE P.deviceid = D.id ORDER BY P.servertime DESC) AS Longitude
			,(SELECT TOP 1 P.servertime FROM [#GPSDataSource#].[dbo].[Positions] P WHERE P.deviceid = D.id ORDER BY P.servertime DESC) AS servertime
			,(SELECT TOP 1 P.ID FROM [#GPSDataSource#].[dbo].[Positions] P WHERE P.deviceid = D.id ORDER BY P.servertime DESC) AS PositionID
			,(SELECT TOP 1 P.SendProject44 FROM [#GPSDataSource#].[dbo].[Positions] P WHERE P.deviceid = D.id ORDER BY P.servertime DESC) AS SendProject44
			,CS.CustomerName
			,CS.Project44ApiUsername
			,CS.Project44ApiPassword
			,L.LoadNumber
			,L.BOLNum
			FROM [#local.dsn#].[dbo].[Loads]  L
			LEFT JOIN [#local.dsn#].[dbo].[Carriers]  C ON C.CarrierID = L.CarrierID
			LEFT JOIN [#local.dsn#].[dbo].[Customers]  CS ON CS.CustomerID = L.PayerID
			LEFT JOIN [#GPSDataSource#].[dbo].[devices] D ON L.GPSDeviceID= D.uniqueid
			LEFT JOIN [#local.dsn#].[dbo].[LoadStatusTypes] LST ON LST.StatusTypeID = L.StatusTypeID
			WHERE L.PushDataToProject44Api = 1
			AND LST.StatusText NOT IN ('8. COMPLETED','9. Cancelled')
			AND ISNULL(L.GPSDeviceID,0) <> '0'
		</cfquery>

		<cfloop query="getPositions">
			<cfset error = "">
			
			<cfif NOT len(trim(getPositions.BolNum))>
				<cfset error = "Shipment identifier data(BolNumber) not available.">
			</cfif>
			
			<cfif NOT len(trim(getPositions.latitude)) OR NOT len(trim(getPositions.longitude)) OR NOT len(trim(getPositions.servertime))>
				<cfset error = "Location data not available.">
			</cfif>

			<cfif NOT len(trim(getPositions.Project44ApiUsername)) OR NOT len(trim(getPositions.Project44ApiPassword))>
				<cfset error = "Api crendentials not available.">
			</cfif>

			<cfif NOT len(trim(error))>
				<cfset body = structNew()>
				
				<cfset arr_shipmentIdentifiers = arrayNew(1)>
				<cfset struct_shipmentIdentifiers = structNew()>

				<cfset struct_shipmentIdentifiers["type"] = "ORDER">
				<cfset struct_shipmentIdentifiers["value"] = getPositions.BOLNum>
				<cfset arrayAppend(arr_shipmentIdentifiers, struct_shipmentIdentifiers)>

				<cfset body["shipmentIdentifiers"] = arr_shipmentIdentifiers>

				<cfset body["latitude"] = getPositions.latitude>
				<cfset body["longitude"] = getPositions.longitude>
				<cfset datetime = dateConvert( "local2utc", getPositions.servertime )>
				<cfset utcTime = dateFormat( datetime, "yyyy-mm-dd" ) & "T" & timeFormat( datetime, "HH:mm:ss" )>
				<cfset body["utcTimestamp"] = utcTime>
				<cfset body["customerId"] = getPositions.CustomerName>

				<cfhttp
						method="post"
						url="https://cloud.p-44.com/api/carriers/v2/tl/shipments/statusUpdates"  username="#trim(getPositions.Project44ApiUsername)#" password="#trim(getPositions.Project44ApiPassword)#"
						result="returnStruct">
								<cfhttpparam type="HEADER" name="Content-Type" value="application/json">
								<cfhttpparam type="body" value="#serializeJSON(body)#">
				</cfhttp>

				<cfset filecontent = deserializeJSON(returnStruct.filecontent)>
				<cfif structKeyExists(filecontent, "errors")>
					<cfset error = filecontent.errors[1].message>
				<cfelseif structKeyExists(filecontent, "httpMessage") AND filecontent.httpMessage EQ 'Unauthorized'>
					<cfquery name="qProject44Log" datasource="#local.dsn#">
						INSERT INTO Project44APiLog (LogId,LoadNumber,Message,CreatedDate,Success,RequestData,Type)
						VALUES(newid(),'#getPositions.LoadNumber#','Unauthorized.Please check Api crendentials.',getdate(),0,'#serializeJSON(body)#','Location Update')
					</cfquery>
				<cfelse>
					<cfif getPositions.SendProject44 EQ 1>
						<cfset Message = "No new location updates.">
					<cfelse>
						<cfset Message = "Location data sent successfully.">
					</cfif>

					<cfquery name="qProject44Log" datasource="#local.dsn#">
						INSERT INTO Project44APiLog (LogId,LoadNumber,Message,CreatedDate,Success,RequestData,Type)
						VALUES(newid(),'#getPositions.LoadNumber#','#Message#',getdate(),1,'#serializeJSON(body)#','Location Update')
					</cfquery>

					<cfquery name="qUpdatePosition" datasource="#local.dsn#">
						UPDATE [#GPSDataSource#].[dbo].[Positions] SET SendProject44 = 1 WHERE ID = '#getPositions.PositionID#'
					</cfquery>
				</cfif>
			</cfif>

			<cfif len(trim(error))>
				<cfquery name="qProject44Log" datasource="#local.dsn#">
					INSERT INTO Project44APiLog (LogId,LoadNumber,Message,CreatedDate,Success,RequestData,Type)
					VALUES(newid(),'#getPositions.LoadNumber#','#error#',getdate(),0,NULL,'Location Update')
				</cfquery>
			</cfif>
		</cfloop>
		<cfreturn 'Completed'>
	</cffunction>

	<cffunction name="PushDataToProject44Api" access="remote" output="yes" returnformat="json">
		<cfargument name="loadid" required="yes" type="any">
		<cfargument name="dsn" required="yes" type="any">
		<cfargument name="PushDataToProject44Api" required="yes" type="any">

		<cfset response = structNew()>

		<cftry>

			<cfif arguments.PushDataToProject44Api>
				<cfquery name="qCheckCarrier" datasource="#arguments.dsn#">
					SELECT C.SCAC,C.MCNumber,C.DOTNumber FROM LOADS L 
					LEFT JOIN [Carriers]  C ON C.CarrierID = L.CarrierID WHERE  L.loadid=<cfqueryparam value="#arguments.loadid#" cfsqltype="cf_sql_varchar">
				</cfquery>

				<cfif NOT len(trim(qCheckCarrier.SCAC)) AND NOT len(trim(qCheckCarrier.MCNumber)) AND NOT len(trim(qCheckCarrier.DOTNumber))>
					<cfset response.success = 0>
					<cfset response.msg = "Unable to turn on Project44.Carrier identifier data not available.">
					<cfreturn response>
				</cfif>
			</cfif>

			<cfquery name="updateLoad" datasource="#arguments.dsn#">
				UPDATE loads
				SET
					PushDataToProject44Api = <cfqueryparam value="#arguments.PushDataToProject44Api#" cfsqltype="cf_sql_bit">
				WHERE loadid = <cfqueryparam value="#arguments.loadid#" cfsqltype="cf_sql_varchar">
			</cfquery>

			<cfset response.success = 1>
			<cfif arguments.PushDataToProject44Api>
				<cfset response.msg = "Project44 turned on successfully.">
			<cfelse>
				<cfset response.msg = "Project44 turned off successfully.">
			</cfif>
			<cfreturn response>

			<cfcatch>
				<cfset response.success = 0>
				<cfset response.msg = "Something went wrong. Please contact support.">
				<cfreturn response>
			</cfcatch>
		 </cftry>
	</cffunction>

	<cffunction name="getProject44Log" access="public" output="false" returntype="query">
		<cfargument name="searchText" required="no" type="any">
	    <cfargument name="pageNo" required="no" type="any" default="1">
	    <cfargument name="sortorder" required="no" type="any" default="DESC">
	    <cfargument name="sortby" required="no" type="any" default="CreatedDate">

	    <cfquery name="qgetProject44Loads" datasource="#Application.dsn#">
	    	BEGIN WITH page AS 
	    	(SELECT 
	    		P.LogID
	    		,P.LoadNumber
	    		,P.Message
	    		,P.CreatedDate
	    		,P.Success
				,ROW_NUMBER() OVER (ORDER BY cast(#arguments.sortby# as varchar) #arguments.sortorder#) AS Row
				,C.CustomerName
				,L.BOLNum
	    	FROM Project44APiLog P
			left Join loads L on P.LoadNumber =L.LoadNumber
			Left Join Customers C on L.CustomerID = C.CustomerID
			inner join (select
				    customerid
					from CustomerOffices c1 inner join offices o1 on o1.officeid = c1.OfficeID
					where o1.CompanyID = <cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar">
					group by customerid) Offices ON Offices.CustomerID = C.CustomerID
			WHERE 1=1
	    	<cfif structKeyExists(arguments, "searchText") and len(trim(arguments.searchText))>
			    AND (L.BOLNum LIKE <cfqueryparam value="%#arguments.searchText#%" cfsqltype="cf_sql_varchar">
			    OR L.LoadNumber LIKE <cfqueryparam value="%#arguments.searchText#%" cfsqltype="cf_sql_varchar">
			    OR C.CustomerName LIKE <cfqueryparam value="%#arguments.searchText#%" cfsqltype="cf_sql_varchar">)
		    </cfif>
		    )
		    SELECT
		      *,(select (max(row)/30) + (CASE WHEN max(row)%30 <> 0 THEN 1 ELSE 0 END)  FROM page) AS TotalPages
		    FROM page
		    WHERE Row BETWEEN (#arguments.pageNo# - 1) * 30 + 1 AND #arguments.pageNo# * 30
		    END
		</cfquery>

		<cfreturn qgetProject44Loads>
	</cffunction>

	<cffunction name="getEmailLog" access="public" output="false" returntype="query">
		<cfargument name="searchText" required="no" type="any">
	    <cfargument name="pageNo" required="no" type="any" default="1">
	    <cfargument name="sortorder" required="no" type="any" default="DESC">
	    <cfargument name="sortby" required="no" type="any" default="CreateDate">

	    <cfquery name="qgetEmailLog" datasource="#Application.dsn#">
	    	BEGIN WITH page AS 
	    	(SELECT 
	    		EL.*
				,ROW_NUMBER() OVER (ORDER BY #arguments.sortby# #arguments.sortorder#) AS Row
	    	FROM EmailLogs EL
			WHERE companyid = <cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar">
			<cfif structKeyExists(session, "CompanyID")>
				AND EL.CompanyID = <cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar">
			</cfif>
	    	<cfif structKeyExists(arguments, "searchText") and len(trim(arguments.searchText))>
			    AND (EL.Subject LIKE <cfqueryparam value="%#arguments.searchText#%" cfsqltype="cf_sql_varchar">
			    OR EL.LoadNo LIKE <cfqueryparam value="%#arguments.searchText#%" cfsqltype="cf_sql_varchar">
			    OR EL.EmailBody LIKE <cfqueryparam value="%#arguments.searchText#%" cfsqltype="cf_sql_varchar">
			    OR EL.fromAddress LIKE <cfqueryparam value="%#arguments.searchText#%" cfsqltype="cf_sql_varchar">
			    OR EL.toAddress LIKE <cfqueryparam value="%#arguments.searchText#%" cfsqltype="cf_sql_varchar">)
		    </cfif>
		    )
		    SELECT
		      *,(select (max(row)/30) + (CASE WHEN max(row)%30 <> 0 THEN 1 ELSE 0 END)  FROM page) AS TotalPages
		    FROM page
		    WHERE Row BETWEEN (#arguments.pageNo# - 1) * 30 + 1 AND #arguments.pageNo# * 30
		    END
		</cfquery>

		<cfreturn qgetEmailLog>
	</cffunction>

	<cffunction name="getTextLog" access="public" output="false" returntype="query">
		<cfargument name="searchText" required="no" type="any">
	    <cfargument name="pageNo" required="no" type="any" default="1">
	    <cfargument name="sortorder" required="no" type="any" default="DESC">
	    <cfargument name="sortby" required="no" type="any" default="CreateDate">

	    <cfquery name="qgetTextLog" datasource="#Application.dsn#">
	    	BEGIN WITH page AS 
	    	(SELECT 
	    		TL.*
				,ROW_NUMBER() OVER (ORDER BY #arguments.sortby# #arguments.sortorder#) AS Row
	    	FROM TextLogs TL
	    	left Join loads L on L.LoadID =TL.LoadID
	    	inner join (select
					    customerid
						from CustomerOffices c1 inner join offices o1 on o1.officeid = c1.OfficeID
						where o1.CompanyID = <cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar">
						group by customerid) Offices ON Offices.CustomerID = L.CustomerID
			WHERE 1=1
	    	<cfif structKeyExists(arguments, "searchText") and len(trim(arguments.searchText))>
			    AND (TL.LoadNo LIKE <cfqueryparam value="%#arguments.searchText#%" cfsqltype="cf_sql_varchar">
			    OR TL.TextBody LIKE <cfqueryparam value="%#arguments.searchText#%" cfsqltype="cf_sql_varchar">
			    OR TL.fromNumber LIKE <cfqueryparam value="%#arguments.searchText#%" cfsqltype="cf_sql_varchar">
			    OR TL.toNumber LIKE <cfqueryparam value="%#arguments.searchText#%" cfsqltype="cf_sql_varchar">)
		    </cfif>
		    )
		    SELECT
		      *,(select (max(row)/30) + (CASE WHEN max(row)%30 <> 0 THEN 1 ELSE 0 END)  FROM page) AS TotalPages
		    FROM page
		    WHERE Row BETWEEN (#arguments.pageNo# - 1) * 30 + 1 AND #arguments.pageNo# * 30
		    END
		</cfquery>

		<cfreturn qgetTextLog>
	</cffunction>

	<cffunction name="setLoadStatusSetup" access="public" returntype="boolean">
		<cfargument name="statustypeid" type="string" required="no">
		<cfargument name="newColor" type="string" required="no">
		<cfargument name="newTextColor" type="string" required="no">
		<cfargument name="newFilter" type="string" required="no">
		<cfargument name="newForceNextStatus" type="string" required="no">
		<cfargument name="SendEmailForLoads" type="string" required="no">
		<cfargument name="UserAccountStatusUpdate" type="string" required="no">
		<cfargument name="StatusDescription" type="string" required="no">
		<cfargument name="isActive" type="string" required="no">
		<cfargument name="StatusUpdateMailType" type="string" required="no">
		
		<cftry>
			<cfquery name="qsetLoadStatusSetup" datasource="#variables.dsn#">
				UPDATE loadstatustypes 
				SET ColorCode = <cfqueryparam value="#arguments.newColor#" cfsqltype="cf_sql_varchar">,
				TextColorCode = <cfqueryparam value="#arguments.newTextColor#" cfsqltype="cf_sql_varchar">,
				Filter = <cfqueryparam value="#arguments.newFilter#" cfsqltype="cf_sql_bit">,
				ForceNextStatus = <cfqueryparam value="#arguments.newForceNextStatus#" cfsqltype="cf_sql_bit">,
				AllowOnMobileWebApp = <cfqueryparam value="#arguments.AllowOnMobileWebApp#" cfsqltype="cf_sql_bit">,
				ShowAsActiveLoadOnMobile = <cfqueryparam value="#arguments.AllowOnMobileWebApp#" cfsqltype="cf_sql_bit">,
				SendEmailForLoads = <cfqueryparam value="#arguments.SendEmailForLoads#" cfsqltype="cf_sql_bit">,
				StatusDescription = <cfqueryparam value="#arguments.StatusDescription#" cfsqltype="cf_sql_varchar"> ,
				SendUpdateOneTime = <cfqueryparam value="#arguments.SendUpdateOneTime#" cfsqltype="cf_sql_bit"> ,
				isActive = <cfqueryparam value="#arguments.isActive#" cfsqltype="cf_sql_bit">
				WHERE statustypeid = <cfqueryparam value="#arguments.statustypeid#" cfsqltype="cf_sql_varchar">

				UPDATE Systemconfig 
				SET UserAccountStatusUpdate = <cfqueryparam value="#arguments.UserAccountStatusUpdate#" cfsqltype="cf_sql_varchar"> 
					,StatusUpdateEmailOption = <cfqueryparam value="#arguments.StatusUpdateEmailOption#" cfsqltype="cf_sql_integer">
					,StatusUpdateMailType = <cfqueryparam value="#arguments.StatusUpdateMailType#" cfsqltype="cf_sql_integer"> 
				WHERE CompanyID = <cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar">
			</cfquery>
			<cfreturn 1>
			<cfcatch>
				<cfreturn 0>
			</cfcatch>
		</cftry>
	</cffunction>

	<cffunction name="createEDispatchLog" access="public" returntype="boolean">
		<cfargument name="type" type="string" required="no">
		<cfargument name="user" type="string" required="no">
		<cfargument name="loadnumber" type="string" required="no">
		<cfargument name="driverphone" type="string" required="no">
		<cfargument name="carrieremail" type="string" required="no">
		<cfargument name="customerid" type="string" required="no">
		<cfargument name="carrierid" type="string" required="no">
		<cfargument name="loadid" type="string" required="no">
		<cfargument name="body" type="string" required="no" default="">
		<cftry>
			<cfquery name="qCreateEDispatchLog" datasource="#variables.dsn#">
				INSERT INTO EDispatchLog (type,username,loadnumber,driverphone,carrieremail,customerid,carrierid,loadid,body)
				VALUES(
						<cfqueryparam value="#arguments.type#" cfsqltype="cf_sql_varchar">,
						<cfqueryparam value="#arguments.user#" cfsqltype="cf_sql_varchar">,
						<cfqueryparam value="#arguments.loadnumber#" cfsqltype="cf_sql_varchar">,
						<cfqueryparam value="#arguments.driverphone#" cfsqltype="cf_sql_varchar">,
						<cfqueryparam value="#arguments.carrieremail#" cfsqltype="cf_sql_varchar">,
						<cfqueryparam value="#arguments.customerid#" cfsqltype="cf_sql_varchar">,
						<cfqueryparam value="#arguments.carrierid#" cfsqltype="cf_sql_varchar">,
						<cfqueryparam value="#arguments.loadid#" cfsqltype="cf_sql_varchar">,
						<cfqueryparam value="#arguments.body#" cfsqltype="cf_sql_varchar">
					)
			</cfquery>
			<cfreturn 1>
			<cfcatch>
				<cfreturn 0>
			</cfcatch>
		</cftry>
	</cffunction>

	<cffunction name="getEDispatchLog" access="public" output="false" returntype="query">
		<cfargument name="searchText" required="no" type="any">
	    <cfargument name="pageNo" required="no" type="any" default="1">
	    <cfargument name="sortorder" required="no" type="any" default="DESC">
	    <cfargument name="sortby" required="no" type="any" default="CreatedDate">

	    <cfquery name="qgetEDispatchLog" datasource="#Application.dsn#">
	    	BEGIN WITH page AS 
	    	(SELECT 
	    		E.CreatedDate
		      	,E.Type
		      	,E.UserName
		      	,E.LoadNumber
		      	,E.DriverPhone
		      	,E.CarrierEmail
		      	,E.CustomerID
		      	,E.CarrierID
		      	,E.LoadID
		      	,E.Body
		      	,C.CarrierName
		      	,Cus.CustomerName
				,ROW_NUMBER() OVER (ORDER BY #arguments.sortby# #arguments.sortorder#) AS Row

	    	FROM EDispatchlog E
	    	LEFT JOIN Carriers C ON C.CarrierID = E.CarrierID
	    	LEFT JOIN Customers Cus ON Cus.CustomerID = E.CustomerID
			WHERE E.CompanyID = <cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar"> AND Len(E.CarrierID) <> 0 AND Len(E.CustomerID) <> 0
	    	<cfif structKeyExists(arguments, "searchText") and len(trim(arguments.searchText))>
			    AND (E.Type LIKE <cfqueryparam value="%#arguments.searchText#%" cfsqltype="cf_sql_varchar">
			    OR E.LoadNumber LIKE <cfqueryparam value="%#arguments.searchText#%" cfsqltype="cf_sql_varchar">
			    OR E.CarrierEmail LIKE <cfqueryparam value="%#arguments.searchText#%" cfsqltype="cf_sql_varchar">)
		    </cfif>
		    )
		    SELECT
		      *,(select (max(row)/30) + (CASE WHEN max(row)%30 <> 0 THEN 1 ELSE 0 END)  FROM page) AS TotalPages
		    FROM page
		    WHERE Row BETWEEN (#arguments.pageNo# - 1) * 30 + 1 AND #arguments.pageNo# * 30
		    END
		</cfquery>

		<cfreturn qgetEDispatchLog>
	</cffunction>

	<cffunction name="getEquipmentLastLocation" access="remote" output="yes" returnformat="json">
		<cfargument name="equipmentID" required="yes" type="any">
		<cfargument name="shipperPickupDate" required="yes" type="any">
		<cfargument name="loadid" required="no" type="any" default="0">
		<cfargument name="CompanyID" required="no" type="any" default="">
		<cfargument name="driverid" required="no" type="any" default="">
		<cftry>
			<cfset response = structNew()>	
			<cfset local.dsn = trim(listFirst(cgi.SCRIPT_NAME,'/'))>

			<cfquery name="qGetCalculateDHOption" datasource="#local.dsn#">
				select CalculateDHOption from SystemConfig WHERE CompanyID = <cfqueryparam value="#arguments.CompanyID#" cfsqltype="CF_SQL_VARCHAR">
			</cfquery>

			<cfquery name="qGet" datasource="#local.dsn#">
				SELECT TOP 1
				LS.Address,
				LS.City,
				LS.StateCode,
				LS.PostalCode
				FROM LOADSTOPS LS
				INNER JOIN Equipments E ON E.EquipmentID = LS.NewEquipmentID 
				WHERE 
				<cfif qGetCalculateDHOption.CalculateDHOption EQ 1 AND structKeyExists(arguments, "driverid") AND len(trim(arguments.driverid))>
					LS.NewCarrierID = <cfqueryparam value="#arguments.driverid#" cfsqltype="cf_sql_varchar">
				<cfelse>
					LS.NewEquipmentID  = <cfqueryparam value="#arguments.equipmentID#" cfsqltype="cf_sql_varchar">
				</cfif>				
				AND LS.StopDate <= <cfqueryparam value="#arguments.shipperPickupDate#" cfsqltype="cf_sql_date">
				<cfif arguments.loadid NEQ 0>
					AND LS.LoadID <> <cfqueryparam value="#arguments.loadid#" cfsqltype="cf_sql_varchar">
				</cfif>
				<cfif structkeyexists(arguments,"CompanyID") AND Len(Trim(arguments.CompanyID))>
					AND E.CompanyID = <cfqueryparam value="#arguments.CompanyID#" cfsqltype="CF_SQL_VARCHAR">
				</cfif>
				AND LS.LoadType = 2
				ORDER BY LS.StopDate Desc,LS.StopNo Desc,LS.Loadtype Desc
			</cfquery>
			<cfset response.success = 1>
			<cfset response.Address = qGet.Address>
			<cfset response.City = qGet.City>
			<cfset response.StateCode = qGet.StateCode>
			<cfset response.PostalCode = qGet.PostalCode>
			<cfset response.count = qGet.recordcount>

			<cfreturn response>
			<cfcatch>
				<cfset response.success = 0>
				<cfreturn response>
			</cfcatch>
		 </cftry>
	</cffunction>

	<cffunction name="uploadCSV" access="public" output="yes" returnformat="json">
		<cftry>
			<cfset row="">
			<cfset response = structNew()>	

			<cfset rootPath = expandPath('../fileupload/tempCSV/')>
			<cfif not directoryExists(rootPath)>
				<cfdirectory action = "create" directory = "#rootPath#" > 
			</cfif>

			<cffile action="upload" filefield="file" destination="#rootPath#" nameConflict="MakeUnique" result=uploadedFile>

			<cfif uploadedFile.SERVERFILEEXT NEQ 'csv'>
				<cfset response.success = 0>
				<cfset response.message = "Invalid file extension.Please upload CSV file.">
				<cfreturn response>
			</cfif>

			<cfset fileName = uploadedFile.SERVERFILE>
		
			<cffile action="read" file="#rootPath##fileName#" variable="csvfile">

			<cfset validHeader = "Customer Code,Carrier Flat Rate,Customer Flat Rate,Equipment Name,Agent Login Name,Dispatcher Login Name,Pickup Date,Delivery Date,PRO##,BOL##,PONumber,Pickup##,Shipper Name,Shipper Address,Shipper City,Shipper State,Shipper Zip,Delivery##,Destination Name,Destination Address,Destination City,Destination State,Destination Zip,Notes,Dispatch Notes,Carrier Notes,Commodity Qty,Commidity Type,Commodity Description,Commodity Fee,Commodity Weight,Commodity Class,Commodity Cust Rate,Commodity Carr Rate,Commodity Cust Percent,LTL,Equipment Length">
			<cfset uploadedHeader = listgetAt('#csvfile#',1, '#chr(10)##chr(13)#')>
			<cfif Compare(validHeader, uploadedHeader) NEQ 0>
				<cfset response.success = 0>
				<cfset response.message = "Invalid header format.">
				<cfreturn response>
			</cfif>

			<cfquery name="qGetCustomerCodes" datasource="#variables.dsn#">
				SELECT trim(CustomerCode) AS CustomerCode,Customers.CustomerID,CustomerName 
				FROM Customers 
				INNER JOIN (SELECT customerid
								FROM CustomerOffices c1 INNER JOIN offices o1 ON o1.officeid = c1.OfficeID
									WHERE o1.CompanyID = <cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar">
									GROUP BY customerid) Offices ON Offices.CustomerID = Customers.CustomerID
				WHERE LEN(CustomerCode) >= 1
			</cfquery>

			<cfquery name="qGetEquipmentNames" datasource="#variables.dsn#">
				SELECT trim(EquipmentName) AS EquipmentName,EquipmentID FROM Equipments WHERE CompanyID = <cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar">
			</cfquery>

			<cfquery name="qGetSalesperson" datasource="#variables.dsn#">
				SELECT EmployeeID,Name FROM Employees 
				INNER JOIN Roles ON Roles.RoleID = Employees.RoleID
				INNER JOIN Offices ON Employees.OfficeID = Offices.OfficeID
				WHERE Roles.RoleValue IN ('Sales Representative','Manager','Dispatcher','Administrator','Central Dispatcher')
				AND Offices.CompanyID = <cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar">
				AND Roles.CompanyID = <cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar">
			</cfquery>

			<cfquery name="qGetEmployee" datasource="#variables.dsn#">
				SELECT Name FROM employees 
				INNER JOIN Offices ON Employees.OfficeID = Offices.OfficeID
				WHERE LoginID = <cfqueryparam value="#session.AdminUserName#" cfsqltype="cf_sql_varchar">
				AND Offices.CompanyID = <cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar">
			</cfquery>

			<cfquery name="qGetUnits" datasource="#variables.dsn#">
				SELECT UnitName,UnitID FROM Units WHERE CompanyID = <cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar">
			</cfquery>

			<cfquery name="qGetClasses" datasource="#variables.dsn#">
				SELECT ClassName,ClassID FROM CommodityClasses WHERE CompanyID = <cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar">
			</cfquery>

			<cfset var insStatusTypeID = "">
			<cfquery name="qGetStatus" datasource="#variables.dsn#">
				SELECT StatusTypeID FROM LoadStatusTypes WHERE StatusText = '0.1 SPOT' AND CompanyID = <cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar">
			</cfquery>

			<cfif qGetStatus.recordcount>
				<cfset insStatusTypeID = qGetStatus.StatusTypeID>
			<cfelse>
				<cfquery name="qGetStatus" datasource="#variables.dsn#">
					SELECT newid() AS StatusTypeID
				</cfquery>
				<cfset insStatusTypeID = qGetStatus.StatusTypeID>	
				<cfquery name="qInsStatus" datasource="#variables.dsn#">
					INSERT INTO LoadStatusTypes(StatusTypeID,StatusOrder,StatusText,StatusType,HasNotes,IsActive,CreatedDateTime,LastModifiedDateTime,CreatedBy,LastModifiedBy,ColorCode,Filter,ForceNextStatus,SystemUpdated,AllowOnMobileWebApp,CompanyID)
					VALUES(
						<cfqueryparam value="#insStatusTypeID#" cfsqltype="cf_sql_varchar">
						,99
						,'0.1 SPOT'
						,1
						,0
						,1
						,getdate()
						,getdate()
						,<cfqueryparam value="#session.AdminUserName#" cfsqltype="cf_sql_varchar">
						,<cfqueryparam value="#session.AdminUserName#" cfsqltype="cf_sql_varchar">
						,'87de78'
						,1
						,0
						,0
						,0
						,<cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar">
					)

					UPDATE Roles SET EditableStatuses = EditableStatuses + ',0.1 SPOT' 
					WHERE CompanyID = <cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar"> AND EditableStatuses NOT LIKE '%0.1 SPOT%' AND RoleValue = 'Administrator'

					INSERT INTO agentsLoadTypes VALUES (
						<cfqueryparam value="#session.EmpID#" cfsqltype="cf_sql_varchar">
						,<cfqueryparam value="#insStatusTypeID#" cfsqltype="cf_sql_varchar">
						)
				</cfquery>

				<cfset session.editablestatuses &= ',0.1 SPOT'>
			</cfif>

			<cfset validCustCode = valuelist(qGetCustomerCodes.CustomerCode)>

			<cfset currentRow = 1>
			<cfset bitImportedAll = 1>
			<cfloop index="row" list="#csvfile#" delimiters="#chr(10)##chr(13)#">
				<cfif currentRow NEQ 1>
					<cfset qryRow = CSVToQuery(row)>
		
					<cfset CustomerCode = qryRow.column_1>

					<cfset CarrierFlatRate = ReplaceNoCase(ReplaceNoCase(qryRow.column_2,'$','','ALL'),',','','ALL')>
					<cfset CustomerFlatRate = ReplaceNoCase(ReplaceNoCase(qryRow.column_3,'$','','ALL'),',','','ALL')>
					<cfif structKeyExists(session, "IsCustomer")>
						<cfset CarrierFlatRate = 0>
					<cfelseif NOT len(trim(CarrierFlatRate))>
						<cfset CarrierFlatRate = 0>
					</cfif>
					<cfif structKeyExists(session, "IsCustomer")>
						<cfset CustomerFlatRate = 0>
					<cfelseif NOT len(trim(CustomerFlatRate))>
						<cfset CustomerFlatRate = 0>
					</cfif>

					<cfset EquipmentName = qryRow.column_4>
					<cfif len(trim(qryRow.column_5))>
						<cfset AgentLoginName = listGetAt(qryRow.column_5, 1)>
					<cfelse>
						<cfset AgentLoginName = qryRow.column_5>
					</cfif>
					<cfif len(trim(qryRow.column_6))>
						<cfset DispatcherLoginName = listGetAt(qryRow.column_6, 1)>
					<cfelse>
						<cfset DispatcherLoginName = qryRow.column_6>
					</cfif>
					<cfset PickupDate= qryRow.column_7>
					<cfset DeliveryDate = qryRow.column_8>
					<cfset PRO = qryRow.column_9>
					<cfset BOL = qryRow.column_10>
					<cfset PO = qryRow.column_11>
					<cfset PickupNo = qryRow.column_12>
					<cfset ShipperName = qryRow.column_13>
					<cfset ShipperAddress = qryRow.column_14>
					<cfset ShipperCity = qryRow.column_15>
					<cfset ShipperState = qryRow.column_16>
					<cfset ShipperZip = qryRow.column_17>
					<cfset DeliveryNo = qryRow.column_18>
					<cfset DestinationName = qryRow.column_19>
					<cfset DestinationAddress = qryRow.column_20>
					<cfset DestinationCity = qryRow.column_21>
					<cfset DestinationState = qryRow.column_22>
					<cfset DestinationZip = qryRow.column_23>
					<cfset NewNotes = qryRow.column_24>
					<cfset NewDispatchNotes = qryRow.column_25>
					<cfset CarrierNotes = qryRow.column_26>

					<cfset CommodityQty = qryRow.column_27>
					<cfset CommidityType = qryRow.column_28>
					<cfset CommodityDescription = qryRow.column_29>
					<cfset CommodityFee = qryRow.column_30>
					<cfset CommidityWeight = qryRow.column_31>
					<cfset CommodityClass= qryRow.column_32>
					<cfset CommodityCustRate = ReplaceNoCase(ReplaceNoCase(qryRow.column_33,'$','','ALL'),',','','ALL')>
					<cfset CommidityCarrRate = ReplaceNoCase(ReplaceNoCase(qryRow.column_34,'$','','ALL'),',','','ALL')>
					<cfset CommodityCustPercent= ReplaceNoCase(qryRow.column_35,'%','','ALL')>

					<cfset LTL = qryRow.column_36>

					<cfif qGetEmployee.recordcount>
						<cfif len(trim(NewDispatchNotes))>
							<cfset NewDispatchNotes = '#DateTimeFormat(now(),"m/d/yyyy h:nn tt")# - #qGetEmployee.name# > #NewDispatchNotes#'>
						</cfif>
					</cfif>
					
					<cfif listFindNoCase(validCustCode, CustomerCode)>
						<cfquery dbtype="query" name="qGetCustomerID">
							SELECT CustomerID,CustomerName FROM qGetCustomerCodes WHERE upper(CustomerCode) = upper('#trim(CustomerCode)#')
						</cfquery>

						<cfquery dbtype="query" name="qGetEquipmentID">
							SELECT EquipmentID FROM qGetEquipmentNames WHERE upper(EquipmentName) = upper('#EquipmentName#')
						</cfquery>
						
						<cfquery dbtype="query" name="qGetDispatcherID">
							SELECT EmployeeID FROM qGetSalesperson WHERE upper(Name) = upper('#DispatcherLoginName#')
						</cfquery>	

						<cfquery dbtype="query" name="qGetAgentID">
							SELECT EmployeeID FROM qGetSalesperson WHERE upper(Name) = upper('#AgentLoginName#')
						</cfquery>

						<cfquery dbtype="query" name="qGetUnitID">
							SELECT UnitID FROM qGetUnits WHERE upper(UnitName) = upper('#CommidityType#')
						</cfquery>

						<cfquery dbtype="query" name="qGetClassID">
							SELECT ClassID FROM qGetClasses WHERE upper(ClassName) = upper('#CommodityClass#')
						</cfquery>

						<cfquery name="getloadmanual" datasource="#variables.dsn#">
							SELECT max(loadnumber) + 1 AS loadManualNo FROM Loads WHERE customerid in (select customerid from CustomerOffices inner join offices on CustomerOffices.officeid = offices.officeid where offices.companyid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#session.CompanyID#">)
						</cfquery>
						<cfif len(trim(PRO))>
							<cfset loadManualNo=trim(PRO)>
						<cfelse>
							<cfset loadManualNo=getloadmanual.loadManualNo>
						</cfif>
						
						<cfquery name="getLoadID" datasource="#variables.dsn#">
							SELECT NEWID() AS LoadID 
						</cfquery>

						<cfquery name="qinsLoad" datasource="#variables.dsn#">

							INSERT INTO Loads
							(
								LoadID
								,LoadNumber
								,StatusTypeID
								,CustomerID
								,custName
								,CarrFlatRate
								,CustFlatRate
								<cfif len(trim(qGetEquipmentID.EquipmentID))>,EquipmentID,EquipmentName</cfif>
								<cfif len(trim(qGetAgentID.EmployeeID))>,SalesRepID</cfif>
								,SalesAgent
								<cfif len(trim(qGetDispatcherID.EmployeeID))>,DispatcherID</cfif>
								,InternalRef
								,BOLNum
								,CustomerPONo
								,CreatedDateTime
								,LastModifiedDate
								,CreatedBy
								,ModifiedBy
								<cfif len(trim(PickupDate)) AND isdate(PickupDate)>,NewPickupDate</cfif>
								<cfif len(trim(DeliveryDate)) AND isdate(DeliveryDate)>,NewDeliveryDate</cfif>
								,HasEnrouteStops
								,HasTemp
								,IsPost
								,IsPepUpload
								,IsLocked
								,TotalCustomerCharges
								,TotalCarrierCharges
								,ControlNumber
								,NEWNOTES
								,NEWDISPATCHNOTES
								,ShipperCity
								,ShipperState
								,ConsigneeCity
								,ConsigneeState
								,CarrierNotes
								<cfif len(trim(LTL)) AND listFindNoCase("true,false,0,1", LTL)>,IsPartial</cfif>
							)
							VALUES 
							(
								<cfqueryparam value="#getLoadID.LoadID#" cfsqltype="cf_sql_varchar">
								,<cfqueryparam value="#loadManualNo#" cfsqltype="cf_sql_varchar">
								,<cfqueryparam value="#insStatusTypeID#" cfsqltype="cf_sql_varchar">
								,<cfqueryparam value="#qGetCustomerID.CustomerID#" cfsqltype="cf_sql_varchar">
								,<cfqueryparam value="#qGetCustomerID.CustomerName#" cfsqltype="cf_sql_varchar">
								,<cfqueryparam value="#CarrierFlatRate#" cfsqltype="cf_sql_float">
								,<cfqueryparam value="#CustomerFlatRate#" cfsqltype="cf_sql_float">
								<cfif len(trim(qGetEquipmentID.EquipmentID))>
									,<cfqueryparam value="#qGetEquipmentID.EquipmentID#" cfsqltype="cf_sql_varchar">
									,<cfqueryparam value="#EquipmentName#" cfsqltype="cf_sql_varchar">
								</cfif>
								<cfif len(trim(qGetAgentID.EmployeeID))>,<cfqueryparam value="#qGetAgentID.EmployeeID#" cfsqltype="cf_sql_varchar"></cfif>
								,<cfqueryparam value="#AgentLoginName#" cfsqltype="cf_sql_varchar">
								<cfif len(trim(qGetDispatcherID.EmployeeID))>,<cfqueryparam value="#qGetDispatcherID.EmployeeID#" cfsqltype="cf_sql_varchar"></cfif>
								,<cfqueryparam value="#PRO#" cfsqltype="cf_sql_varchar">
								,<cfqueryparam value="#BOL#" cfsqltype="cf_sql_varchar">
								,<cfqueryparam value="#PO#" cfsqltype="cf_sql_varchar">
								,getdate()
								,getdate()
								,<cfqueryparam value="#session.AdminUserName#" cfsqltype="cf_sql_varchar">
								,<cfqueryparam value="#session.AdminUserName#" cfsqltype="cf_sql_varchar">
								<cfif len(trim(PickupDate)) AND isdate(PickupDate)>,<cfqueryparam value="#PickupDate#" cfsqltype="cf_sql_varchar"></cfif>
								<cfif len(trim(DeliveryDate)) AND isdate(DeliveryDate)>,<cfqueryparam value="#DeliveryDate#" cfsqltype="cf_sql_varchar"></cfif>
								,0
								,0
								,0
								,0
								,0
								,<cfqueryparam value="#CustomerFlatRate#" cfsqltype="cf_sql_float">
								,<cfqueryparam value="#CarrierFlatRate#" cfsqltype="cf_sql_float">
								,<cfqueryparam value="#loadManualNo#" cfsqltype="cf_sql_varchar">
								,<cfqueryparam value="#NEWNOTES#" cfsqltype="cf_sql_varchar">
								,<cfqueryparam value="#NEWDISPATCHNOTES#" cfsqltype="cf_sql_varchar">
								,<cfqueryparam value="#ShipperCity#" cfsqltype="cf_sql_varchar">
								,<cfqueryparam value="#ShipperState#" cfsqltype="cf_sql_varchar">
								,<cfqueryparam value="#DestinationCity#" cfsqltype="cf_sql_varchar">
								,<cfqueryparam value="#DestinationState#" cfsqltype="cf_sql_varchar">
								,<cfqueryparam value="#CarrierNotes#" cfsqltype="cf_sql_varchar">
								<cfif len(trim(LTL)) AND listFindNoCase("true,false,0,1", LTL)>,<cfqueryparam value="#LTL#" cfsqltype="cf_sql_varchar"></cfif>
							)
						</cfquery>

						<cfquery name="getLoadShipperStopID" datasource="#variables.dsn#">
							SELECT newid() AS StopID FROM LoadStops
						</cfquery>	

						<cfquery name="qinsShipperStop" datasource="#variables.dsn#">
							INSERT INTO LoadStops 
							(
								LoadStopID
								,LoadID
								,StopNo
								,LoadType
								,Address
								,City
								,stateCode
								,postalCode
								,ReleaseNo
								<cfif len(trim(PickupDate)) AND isdate(PickupDate)>,StopDate</cfif>
								,IsOriginPickup
								,IsFinalDelivery
								,blind
								,CreatedDateTime
								,LastModifiedDate
								,CreatedBy
								,ModifiedBy
								<cfif len(trim(qGetEquipmentID.EquipmentID))>,NewEquipmentID</cfif>
								,RefNo
								,TimeIn
								,TimeOut
								,StopTime
								,CustName
							)
							VALUES(
								<cfqueryparam value="#getLoadShipperStopID.StopID#" cfsqltype="cf_sql_varchar">
								,<cfqueryparam value="#getLoadID.LoadID#" cfsqltype="cf_sql_varchar">
								,0
								,1
								,<cfqueryparam value="#ShipperAddress#" cfsqltype="cf_sql_varchar">
								,<cfqueryparam value="#ShipperCity#" cfsqltype="cf_sql_varchar">
								,<cfqueryparam value="#ShipperState#" cfsqltype="cf_sql_varchar">
								,<cfqueryparam value="#ShipperZip#" cfsqltype="cf_sql_varchar">
								,<cfqueryparam value="#PickupNo#" cfsqltype="cf_sql_varchar">
								<cfif len(trim(PickupDate)) AND isdate(PickupDate)>,<cfqueryparam value="#PickupDate#" cfsqltype="cf_sql_varchar"></cfif>
								,1
								,0
								,0
								,getdate()
								,getdate()
								,<cfqueryparam value="#session.AdminUserName#" cfsqltype="cf_sql_varchar">
								,<cfqueryparam value="#session.AdminUserName#" cfsqltype="cf_sql_varchar">
								<cfif len(trim(qGetEquipmentID.EquipmentID))>,<cfqueryparam value="#qGetEquipmentID.EquipmentID#" cfsqltype="cf_sql_varchar"></cfif>
								,''
								,''
								,''
								,''
								,<cfqueryparam value="#ShipperName#" cfsqltype="cf_sql_varchar">
							)
						</cfquery>

						<cfquery name="qinsConsigneeStop" datasource="#variables.dsn#">
							INSERT INTO LoadStops 
							(
								LoadStopID
								,LoadID
								,StopNo
								,LoadType
								,Address
								,City
								,stateCode
								,postalCode
								,ReleaseNo
								<cfif len(trim(DeliveryDate)) AND isdate(DeliveryDate)>,StopDate</cfif>
								,IsOriginPickup
								,IsFinalDelivery
								,blind
								,CreatedDateTime
								,LastModifiedDate
								,CreatedBy
								,ModifiedBy
								<cfif len(trim(qGetEquipmentID.EquipmentID))>,NewEquipmentID</cfif>
								,RefNo
								,TimeIn
								,TimeOut
								,StopTime
								,CustName
							)
							VALUES(
								newid()
								,<cfqueryparam value="#getLoadID.LoadID#" cfsqltype="cf_sql_varchar">
								,0
								,2
								,<cfqueryparam value="#DestinationAddress#" cfsqltype="cf_sql_varchar">
								,<cfqueryparam value="#DestinationCity#" cfsqltype="cf_sql_varchar">
								,<cfqueryparam value="#DestinationState#" cfsqltype="cf_sql_varchar">
								,<cfqueryparam value="#DestinationZip#" cfsqltype="cf_sql_varchar">
								,<cfqueryparam value="#DeliveryNo#" cfsqltype="cf_sql_varchar">
								<cfif len(trim(DeliveryDate)) AND isdate(DeliveryDate)>,<cfqueryparam value="#DeliveryDate#" cfsqltype="cf_sql_varchar"></cfif>
								,0
								,1
								,0
								,getdate()
								,getdate()
								,<cfqueryparam value="#session.AdminUserName#" cfsqltype="cf_sql_varchar">
								,<cfqueryparam value="#session.AdminUserName#" cfsqltype="cf_sql_varchar">
								<cfif len(trim(qGetEquipmentID.EquipmentID))>,<cfqueryparam value="#qGetEquipmentID.EquipmentID#" cfsqltype="cf_sql_varchar"></cfif>
								,''
								,''
								,''
								,''
								,<cfqueryparam value="#DestinationName#" cfsqltype="cf_sql_varchar">
							)
						</cfquery>


						<cfquery name="newLoadStopComm" datasource="#variables.dsn#">
							INSERT INTO LoadStopCommodities
							(
								LoadStopID
								,Weight
								,Qty
								,Description
								,SrNo
								,CustCharges
								,CarrCharges
								,CustRate
								,CarrRate
								,CarrRateOfCustTotal 
								<cfif listFind("0,1", CommodityFee)>,Fee</cfif>
								<cfif qGetUnitID.recordcount>,UnitID</cfif>
								<cfif qGetClassID.recordcount>,ClassID</cfif>
							)
							VALUES(
								<cfqueryparam value="#getLoadShipperStopID.StopID#" cfsqltype="cf_sql_varchar">
								,<cfif isnumeric(CommidityWeight)><cfqueryparam value="#CommidityWeight#" cfsqltype="cf_sql_varchar"><cfelse>0</cfif>
								,<cfif isnumeric(CommodityQty)><cfqueryparam value="#CommodityQty#" cfsqltype="cf_sql_varchar"><cfelse>1</cfif>
								,<cfqueryparam value="#CommodityDescription#" cfsqltype="cf_sql_varchar">
								,'1'
								,<cfif isnumeric(CommodityCustRate)><cfqueryparam value="#CommodityCustRate#" cfsqltype="cf_sql_varchar"><cfelse>0</cfif>
								,<cfif isnumeric(CommidityCarrRate)><cfqueryparam value="#CommidityCarrRate#" cfsqltype="cf_sql_varchar"><cfelse>0</cfif>
								,<cfif isnumeric(CommodityCustRate)><cfqueryparam value="#CommodityCustRate#" cfsqltype="cf_sql_varchar"><cfelse>0</cfif>
								,<cfif isnumeric(CommidityCarrRate)><cfqueryparam value="#CommidityCarrRate#" cfsqltype="cf_sql_varchar"><cfelse>0</cfif>
								,<cfif isnumeric(CommodityCustPercent)><cfqueryparam value="#CommodityCustPercent#" cfsqltype="cf_sql_varchar"><cfelse>0</cfif>
								<cfif listFind("0,1", CommodityFee)>,<cfqueryparam value="#CommodityFee#" cfsqltype="cf_sql_varchar"></cfif>
								<cfif qGetUnitID.recordcount>,<cfqueryparam value="#qGetUnitID.UnitID#" cfsqltype="cf_sql_varchar"></cfif>
								<cfif qGetClassID.recordcount>,<cfqueryparam value="#qGetClassID.ClassID#" cfsqltype="cf_sql_varchar"></cfif>
							)
						</cfquery>
						<cfset logMsg = "Imported load:#loadManualNo#(Row Number:#currentRow#).">
						<cfquery name="qInsLog" datasource="#variables.dsn#">
							INSERT INTO CsvImportLog (LogId,Message,CreatedDate,Success,RowData,LoadNumber,CompanyID)
							VALUES(newid(),<cfqueryparam value="#logMsg#" cfsqltype="cf_sql_varchar">,getdate(),1,<cfqueryparam value="#row#" cfsqltype="cf_sql_varchar">,<cfqueryparam value="#loadManualNo#" cfsqltype="cf_sql_varchar">,<cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar">)
						</cfquery>
					<cfelse>
						<cfset bitImportedAll = 0>
						<cfset logMsg = "CustomerCode (#CustomerCode#) not found.Row Number:#currentRow#">
						<cfquery name="qInsLog" datasource="#variables.dsn#">
							INSERT INTO CsvImportLog (LogId,Message,CreatedDate,Success,RowData,CompanyID)
							VALUES(newid(),<cfqueryparam value="#logMsg#" cfsqltype="cf_sql_varchar">,getdate(),0,<cfqueryparam value="#row#" cfsqltype="cf_sql_varchar">,<cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar">)
						</cfquery>
					</cfif>
				</cfif>	
				<cfset currentRow++>
			</cfloop>
			<cfset response.success = 1>
			<cfif bitImportedAll EQ 0>
				<cfset response.message = "Some rows are not imported.Please check log for more details.">
			<cfelse>
				<cfset response.message = "Loads imported successfully.Please check log for more details.">
			</cfif>
			<cfreturn response>
			<cfcatch>
				<cfquery name="qInsLog" datasource="#variables.dsn#">
					INSERT INTO CsvImportLog (LogId,Message,CreatedDate,Success,RowData,CompanyID)
					VALUES(newid(),<cfqueryparam value="#cfcatch.message##cfcatch.detail#" cfsqltype="cf_sql_varchar">,getdate(),0,<cfqueryparam value="#row#" cfsqltype="cf_sql_varchar">,<cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar">)
				</cfquery>

				<cfset response.success = 0>
				<cfset response.message = "Something went wrong. Please contact support.">
				<cfreturn response>
			</cfcatch>
		 </cftry>
	</cffunction>

	<cffunction name="getCsvImportLog" access="public" output="false" returntype="query">
		<cfargument name="searchText" required="no" type="any">
	    <cfargument name="pageNo" required="no" type="any" default="1">
	    <cfargument name="sortorder" required="no" type="any" default="DESC">
	    <cfargument name="sortby" required="no" type="any" default="CreatedDate">

	    <cfquery name="qgetCsvImportLog" datasource="#Application.dsn#">
	    	BEGIN WITH page AS 
	    	(SELECT 
	    		P.LogID
	    		,P.LoadNumber
	    		,P.Message
	    		,P.CreatedDate
	    		,P.Success
				,ROW_NUMBER() OVER (ORDER BY #arguments.sortby# #arguments.sortorder#) AS Row
				,C.CustomerName
				,L.BOLNum
	    	FROM CsvImportLog P
			left Join loads L on P.LoadNumber =L.LoadNumber
			Left Join Customers C on L.CustomerID = C.CustomerID
			WHERE  P.CompanyID = <cfqueryparam value="#session.CompanyID#" cfsqltype="varchar">
	    	<cfif structKeyExists(arguments, "searchText") and len(trim(arguments.searchText))>
			    AND (L.BOLNum LIKE <cfqueryparam value="%#arguments.searchText#%" cfsqltype="cf_sql_varchar">
			    OR L.LoadNumber LIKE <cfqueryparam value="%#arguments.searchText#%" cfsqltype="cf_sql_varchar">
			    OR C.CustomerName LIKE <cfqueryparam value="%#arguments.searchText#%" cfsqltype="cf_sql_varchar">)
		    </cfif>
		    )
		    SELECT
		      *,(select (max(row)/30) + (CASE WHEN max(row)%30 <> 0 THEN 1 ELSE 0 END)  FROM page) AS TotalPages
		    FROM page
		    WHERE Row BETWEEN (#arguments.pageNo# - 1) * 30 + 1 AND #arguments.pageNo# * 30
		    END
		</cfquery>

		<cfreturn qgetCsvImportLog>
	</cffunction>

	<cffunction	name="CSVToQuery" access="public" returntype="query" output="false"	hint="Converts the given CSV string to a query.">

		<cfargument	name="CSV" type="string" required="true"	hint="This is the CSV string that will be manipulated."/>
		<cfargument name="Delimiter" type="string" required="false" default="," hint="This is the delimiter that will separate the fields within the CSV value."/>
		<cfargument name="Qualifier" type="string" required="false"	default="""" hint="This is the qualifier that will wrap around fields that have special characters embeded."/>

		<cfset var LOCAL = StructNew() />
		<cfset ARGUMENTS.Delimiter = Left( ARGUMENTS.Delimiter, 1 ) />
		<cfif Len( ARGUMENTS.Qualifier )>
			<cfset ARGUMENTS.Qualifier = Left( ARGUMENTS.Qualifier, 1 ) />
		</cfif>
		<cfset LOCAL.LineDelimiter = Chr( 10 ) />
		<cfset ARGUMENTS.CSV = ARGUMENTS.CSV.ReplaceAll("\r?\n",LOCAL.LineDelimiter) />
		<cfset LOCAL.Delimiters = ARGUMENTS.CSV.ReplaceAll("[^\#ARGUMENTS.Delimiter#\#LOCAL.LineDelimiter#]+","").ToCharArray()/>
		<cfset ARGUMENTS.CSV = (" " & ARGUMENTS.CSV) />
		<cfset ARGUMENTS.CSV = ARGUMENTS.CSV.ReplaceAll("([\#ARGUMENTS.Delimiter#\#LOCAL.LineDelimiter#]{1})","$1 ") />
		<cfset LOCAL.Tokens = ARGUMENTS.CSV.Split("[\#ARGUMENTS.Delimiter#\#LOCAL.LineDelimiter#]{1}") />
		<cfset LOCAL.Rows = ArrayNew( 1 ) />
		<cfset ArrayAppend(LOCAL.Rows,ArrayNew( 1 )) />
		<cfset LOCAL.RowIndex = 1 />
		<cfset LOCAL.IsInValue = false />
		<cfloop	index="LOCAL.TokenIndex" from="1" to="#ArrayLen( LOCAL.Tokens )#" step="1">
			<cfset LOCAL.FieldIndex = ArrayLen(LOCAL.Rows[ LOCAL.RowIndex ]) />
			<cfset LOCAL.Token = LOCAL.Tokens[ LOCAL.TokenIndex ].ReplaceFirst("^.{1}","") />
			<cfif Len( ARGUMENTS.Qualifier )>
				<cfif LOCAL.IsInValue>
					<cfset LOCAL.Token = LOCAL.Token.ReplaceAll("\#ARGUMENTS.Qualifier#{2}","{QUALIFIER}")/>
					<cfset LOCAL.Rows[ LOCAL.RowIndex ][ LOCAL.FieldIndex ] = (LOCAL.Rows[ LOCAL.RowIndex ][ LOCAL.FieldIndex ] &
						LOCAL.Delimiters[ LOCAL.TokenIndex - 1 ] & LOCAL.Token) />
					<cfif (Right( LOCAL.Token, 1 ) EQ ARGUMENTS.Qualifier)>
						<cfset LOCAL.Rows[ LOCAL.RowIndex ][ LOCAL.FieldIndex ] = LOCAL.Rows[ LOCAL.RowIndex ][ LOCAL.FieldIndex ].ReplaceFirst( ".{1}$", "" ) />
						<cfset LOCAL.IsInValue = false />
					</cfif>
				<cfelse>
					<cfif (Left( LOCAL.Token, 1 ) EQ ARGUMENTS.Qualifier)>
						<cfset LOCAL.Token = LOCAL.Token.ReplaceFirst("^.{1}","")/>
						<cfset LOCAL.Token = LOCAL.Token.ReplaceAll("\#ARGUMENTS.Qualifier#{2}","{QUALIFIER}")/>
						<cfif (Right( LOCAL.Token, 1 ) EQ ARGUMENTS.Qualifier)>
							<cfset ArrayAppend(LOCAL.Rows[ LOCAL.RowIndex ],LOCAL.Token.ReplaceFirst(".{1}$","")) />
						<cfelse>
							<cfset LOCAL.IsInValue = true />
							<cfset ArrayAppend(LOCAL.Rows[ LOCAL.RowIndex ],LOCAL.Token)/>
						</cfif>
					<cfelse>
						<cfset ArrayAppend(LOCAL.Rows[ LOCAL.RowIndex ],LOCAL.Token) />
					</cfif>
				</cfif>
				<cfset LOCAL.Rows[ LOCAL.RowIndex ][ ArrayLen( LOCAL.Rows[ LOCAL.RowIndex ] ) ] = Replace(
					LOCAL.Rows[ LOCAL.RowIndex ][ ArrayLen( LOCAL.Rows[ LOCAL.RowIndex ] ) ],"{QUALIFIER}",ARGUMENTS.Qualifier,
					"ALL") />
			<cfelse>
				<cfset ArrayAppend(LOCAL.Rows[ LOCAL.RowIndex ],LOCAL.Token)/>
			</cfif>
			<cfif ((NOT LOCAL.IsInValue) AND (LOCAL.TokenIndex LT ArrayLen( LOCAL.Tokens )) AND	(LOCAL.Delimiters[ LOCAL.TokenIndex ] EQ LOCAL.LineDelimiter))>
				<cfset ArrayAppend(LOCAL.Rows,ArrayNew( 1 )) />
				<cfset LOCAL.RowIndex = (LOCAL.RowIndex + 1) />
			</cfif>
		</cfloop>

		<cfset LOCAL.MaxFieldCount = 0 />
		<cfset LOCAL.EmptyArray = ArrayNew( 1 ) />
		<cfloop	index="LOCAL.RowIndex"from="1"to="#ArrayLen( LOCAL.Rows )#" step="1">
			<cfset LOCAL.MaxFieldCount = Max(LOCAL.MaxFieldCount,ArrayLen(LOCAL.Rows[ LOCAL.RowIndex ]))/>
			<cfset ArrayAppend(LOCAL.EmptyArray,"")/>
		</cfloop>

		<cfset LOCAL.Query = QueryNew( "" ) />

		<cfloop	index="LOCAL.FieldIndex" from="1" to="#LOCAL.MaxFieldCount#" step="1">
			<cfset QueryAddColumn(LOCAL.Query,"COLUMN_#LOCAL.FieldIndex#","CF_SQL_VARCHAR",LOCAL.EmptyArray) />
		</cfloop>
		<cfloop	index="LOCAL.RowIndex" from="1" to="#ArrayLen( LOCAL.Rows )#"	step="1">
			<cfloop	index="LOCAL.FieldIndex" from="1" to="#ArrayLen( LOCAL.Rows[ LOCAL.RowIndex ] )#" step="1">
				<cfset LOCAL.Query[ "COLUMN_#LOCAL.FieldIndex#" ][ LOCAL.RowIndex ] = JavaCast("string",LOCAL.Rows[ LOCAL.RowIndex ][ LOCAL.FieldIndex ]) />
			</cfloop>
		</cfloop>
		<cfreturn LOCAL.Query />

	</cffunction>

	<cffunction name="getSearchedFactorings" access="public" output="false" returntype="query">
		<cfargument name="searchText" required="yes" type="any" default="">
	    <cfargument name="pageNo" required="yes" type="any" default="-1">
	    <cfargument name="sortorder" required="no" type="any" default="ASC">
	    <cfargument name="sortby" required="no" type="any" default="F.Name">

	    <cfquery name="qFactorings" datasource="#Application.dsn#">
	    	<cfif arguments.pageNo neq -1>WITH page AS (</cfif>
	    	SELECT 
	    		F.FactoringID,
	    		F.Name,
				F.Address, 
				F.City, 
				F.State, 
				F.Zip, 
				F.Phone,
				F.Email,
				F.Contact
				,ROW_NUMBER() OVER (ORDER BY
	                   #arguments.sortBy#  #arguments.sortOrder#
	            ) AS Row
			FROM Factorings F
			WHERE CompanyID = <cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar">
			<cfif isDefined("arguments.searchText") and len(arguments.searchText)>
				AND 
				(
					F.Name like <cfqueryparam value="%#arguments.searchText#%" cfsqltype="cf_sql_varchar">
					OR F.Email like <cfqueryparam value="%#arguments.searchText#%" cfsqltype="cf_sql_varchar">
					OR F.Contact like <cfqueryparam value="%#arguments.searchText#%" cfsqltype="cf_sql_varchar">
				)
			</cfif>
			<cfif arguments.pageNo neq -1>
                )
                SELECT * FROM page WHERE Row between (#arguments.pageNo# - 1) * 30 + 1 and #arguments.pageNo# * 30
            </cfif>
		</cfquery>
		<cfreturn qFactorings>
	</cffunction>

	<cffunction name="getFactoringDuplicate" access="remote" output="false" returntype="any" returnFormat="plain">

		<cfargument name="Name" required="true">
		<cfargument name="editid" required="true">
		<cfargument name="companyid" required="true">
		<cfset local.dsn = trim(listFirst(cgi.SCRIPT_NAME,'/'))>
		<cfquery name="qryFactoringcheck" datasource="#local.dsn#">
			select Name from Factorings
			where
			Name = <cfqueryparam value="#arguments.Name#" cfsqltype="cf_sql_varchar">
			<cfif len(trim(arguments.editid))>
				AND Factoringid <> <cfqueryparam value="#arguments.editid#" cfsqltype="cf_sql_varchar">
			</cfif>
			AND companyid = <cfqueryparam value="#arguments.companyid#" cfsqltype="cf_sql_varchar">
		</cfquery>
		<cfif qryFactoringcheck.recordcount>
			<cfreturn 0>
		</cfif>
		<cfreturn 1>
	</cffunction>

	<cffunction name="insertFactoring" access="public" output="false" returntype="any">
	   	<cfargument name="formStruct" type="struct" required="no" />

	   	<cfquery name="qGetFactoringID" datasource="#variables.dsn#">
	   		SELECT NewID() AS FactoringID
	   	</cfquery>

		<cfquery name="insertquery" datasource="#variables.dsn#">
		   	INSERT INTO Factorings(
		   	 	FactoringID
	           ,Name
	           ,Address
	           ,City
	           ,State
	           ,Zip
	           ,Phone
	           ,Fax
	           ,Email
	           ,Contact
	           ,InvoiceRemitInformation
	           ,CreatedBy
	           ,LastModifiedBy
	           ,CreatedDateTime
	           ,LastModifiedDateTime
	           ,CompanyID
	           ,PrintOnInvoice
	           ,FF
	           ,UseFactInfoAsBillTo
	           ,InfoColor
		   	)
		   	values(	
		   			<cfqueryparam cfsqltype="cf_sql_varchar" value="#qGetFactoringID.FactoringID#">
		   			,<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.Name#">
		   			,<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.Address#">
		   			,<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.City#">
		   			,<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.State#">
		   			,<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.Zip#">
		   			,<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.Phone#">
		   			,<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.Fax#">
		   			,<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.Email#">
		   			,<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.Contact#">
		   			,<cfqueryparam cfsqltype="cf_sql_varchar" value="#replace(arguments.formStruct.InvoiceRemitInformation,chr(13)&chr(10),"","all")#">
		   			,<cfqueryparam cfsqltype="cf_sql_varchar" value="#session.adminUserName#">
		   			,<cfqueryparam cfsqltype="cf_sql_varchar" value="#session.adminUserName#">
					,<cfqueryparam cfsqltype="cf_sql_date" value="#now()#">
					,<cfqueryparam cfsqltype="cf_sql_date" value="#now()#">
					,<cfqueryparam cfsqltype="cf_sql_varchar" value="#session.CompanyID#">
					<cfif structkeyexists(arguments.formStruct,"PrintOnInvoice")>
						,<cfqueryparam cfsqltype="cf_sql_bit" value="1">
					<cfelse>
						,<cfqueryparam cfsqltype="cf_sql_bit" value="0">
					</cfif>
					<cfif isNumeric(arguments.formStruct.ff)>
						,<cfqueryparam cfsqltype="cf_sql_float" value="#arguments.formStruct.ff#">
					<cfelse>
						,<cfqueryparam cfsqltype="cf_sql_float" value="0.00">
					</cfif>
					<cfif structkeyexists(arguments.formStruct,"UseFactInfoAsBillTo")>
						,<cfqueryparam cfsqltype="cf_sql_bit" value="1">
					<cfelse>
						,<cfqueryparam cfsqltype="cf_sql_bit" value="0">
					</cfif>
					,<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.InfoColor#">
				  )
	   </cfquery>
	   <cfif structkeyexists(arguments.formStruct,"ApplyToAllCustomers")>
	   		<cfquery name="updCust" datasource="#variables.dsn#">
	   			UPDATE Customers SET 
	   			FactoringID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#qGetFactoringID.FactoringID#">
	   			,RemitName=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.Name#">
	           	,RemitAddress=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.Address#">
	           	,RemitCity=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.City#">
	           	,RemitState=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.State#">
	           	,RemitZipCode=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.Zip#">
	           	,RemitPhone=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.Phone#">
	           	,RemitFax=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.Fax#">
	           	,RemitContact=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.Contact#">
	   			WHERE CustomerID IN (SELECT CO.CustomerID FROM CustomerOffices CO WHERE CO.OfficeID IN (SELECT O.OfficeID FROM Offices O WHERE O.CompanyID= <cfqueryparam cfsqltype="cf_sql_varchar" value="#session.CompanyID#">))
	   		</cfquery>
	   </cfif>
	   <cfreturn qGetFactoringID.FactoringID>
	</cffunction>

	<cffunction name="getFactoringDetails" access="public" output="false" returntype="query">
		<cfargument name="Factoringid" required="no" type="any" default="">

	    <cfquery name="qFactoring" datasource="#Application.dsn#">
	    	SELECT * FROM Factorings
	    	WHERE CompanyID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#session.CompanyID#">
	    	<cfif structkeyexists(arguments,"Factoringid") AND len(trim(arguments.FactoringID))>
	    		AND Factoringid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.FactoringID#">
	    	</cfif>
	    	ORDER BY Name
		</cfquery>
	
		<cfreturn qFactoring>
	</cffunction>

	<cffunction name="updadeFactoring" access="public" output="false" returntype="any">
	   	<cfargument name="formStruct" type="struct" required="no" />

		<cfquery name="updatequery" datasource="#variables.dsn#">
		   	UPDATE Factorings SET 
		   	 	Name=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.Name#">
	           ,Address=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.Address#">
	           ,City=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.City#">
	           ,State=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.State#">
	           ,Zip=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.Zip#">
	           ,Phone=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.Phone#">
	           ,Fax=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.Fax#">
	           ,Email=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.Email#">
	           ,Contact=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.Contact#">
	           ,InvoiceRemitInformation=<cfqueryparam cfsqltype="cf_sql_varchar" value="#replace(arguments.formStruct.InvoiceRemitInformation,chr(13)&chr(10),"","all")#">
	           ,LastModifiedBy=<cfqueryparam cfsqltype="cf_sql_varchar" value="#session.adminUserName#">
	           ,LastModifiedDateTime=<cfqueryparam cfsqltype="cf_sql_date" value="#now()#">
	           ,CompanyID=<cfqueryparam cfsqltype="cf_sql_varchar" value="#session.CompanyID#">
	           <cfif structkeyexists(arguments.formStruct,"PrintOnInvoice")>
					,PrintOnInvoice=<cfqueryparam cfsqltype="cf_sql_bit" value="1">
				<cfelse>
					,PrintOnInvoice=<cfqueryparam cfsqltype="cf_sql_bit" value="0">
				</cfif>
				<cfif isNumeric(arguments.formStruct.ff)>
					,FF=<cfqueryparam cfsqltype="cf_sql_float" value="#arguments.formStruct.ff#">
				<cfelse>
					,FF=<cfqueryparam cfsqltype="cf_sql_float" value="0.00">
				</cfif>

				<cfif structkeyexists(arguments.formStruct,"UseFactInfoAsBillTo")>
					,UseFactInfoAsBillTo=<cfqueryparam cfsqltype="cf_sql_bit" value="1">
				<cfelse>
					,UseFactInfoAsBillTo=<cfqueryparam cfsqltype="cf_sql_bit" value="0">
				</cfif>
				,InfoColor=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.InfoColor#">
	        WHERE FactoringID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.editid#">
	   </cfquery>

	   <cfif structkeyexists(arguments.formStruct,"ApplyToAllCustomers")>
	   		<cfquery name="updCust" datasource="#variables.dsn#">
	   			UPDATE Customers SET 
	   			FactoringID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.editid#">
	   			,RemitName=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.Name#">
	           	,RemitAddress=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.Address#">
	           	,RemitCity=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.City#">
	           	,RemitState=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.State#">
	           	,RemitZipCode=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.Zip#">
	           	,RemitPhone=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.Phone#">
	           	,RemitFax=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.Fax#">
	           	,RemitContact=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.Contact#">
	   			WHERE CustomerID IN (SELECT CO.CustomerID FROM CustomerOffices CO WHERE CO.OfficeID IN (SELECT O.OfficeID FROM Offices O WHERE O.CompanyID= <cfqueryparam cfsqltype="cf_sql_varchar" value="#session.CompanyID#">))
	   		</cfquery>
	   </cfif>
	   <cfreturn arguments.formStruct.editid>
	</cffunction>

	<cffunction name="deleteFactoring" access="public" output="false" returntype="any">
	   	<cfargument name="Factoringid" type="string" required="yes" />

		<cfquery name="deletequery" datasource="#variables.dsn#">
		   	DELETE FROM Factorings 
	        WHERE FactoringID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.Factoringid#">
	   </cfquery>

	   <cfreturn arguments.Factoringid>
	</cffunction>

	<cffunction name="saveCustFromLoadScreen" access="remote" output="false" returntype="any" returnFormat="json">

		<cfargument name="dsn" type="string" required="yes" />
		<cfargument name="fpCustomerName" type="string" required="yes" />
		<cfargument name="fpCustomerSalesRep" type="string" required="yes" />
		<cfargument name="fpCustomerDispatcher" type="string" required="yes" />
		<cfargument name="fpCustomerAddress" type="string" required="yes" />
		<cfargument name="fpCustomerCity" type="string" required="yes" />
		<cfargument name="fpCustomerState" type="string" required="yes" />
		<cfargument name="fpCustomerZip" type="string" required="yes" />
		<cfargument name="fpCustomerContact" type="string" required="yes" />
		<cfargument name="fpCustomerPhone" type="string" required="yes" />
		<cfargument name="fpCustomerPhoneExt" type="string" required="yes" />
		<cfargument name="fpCustomerFax" type="string" required="yes" />
		<cfargument name="fpCustomerFaxExt" type="string" required="yes" />
		<cfargument name="fpCustomerEmail" type="string" required="yes" />
		<cfargument name="adminUserName" type="string" required="yes" />
		<cfargument name="empID" type="string" required="yes" />
		<cfargument name="sesCmpID" type="string" required="yes" />

		<cftry>
			
			<cfquery name="qGetEmployee" datasource="#arguments.dsn#">
				SELECT OfficeID,Country FROM Employees WHERE EmployeeID = <cfqueryparam value="#arguments.empid#" cfsqltype="CF_SQL_VARCHAR" null="#not len(arguments.empid)#">
			</cfquery>
			<cfquery name="qConfig" datasource="#arguments.dsn#">
				SELECT CustomerPaymentTerms FROM SystemConfig WHERE CompanyID  = <cfqueryparam value="#arguments.sesCmpID#" cfsqltype="CF_SQL_VARCHAR" >
			</cfquery>
			<cfif not qGetEmployee.recordcount>
				<cfquery name="qGetEmployee" datasource="#arguments.dsn#">
					SELECT TOP 1 E.OfficeID,E.Country FROM Employees E
					INNER JOIN Offices O ON O.OfficeID = E.OfficeID
					WHERE O.CompanyID = <cfqueryparam value="#arguments.sesCmpID#" cfsqltype="CF_SQL_VARCHAR">
				</cfquery>
			</cfif>

			<CFSTOREDPROC PROCEDURE="USP_InsertCustomer" DATASOURCE="#arguments.dsn#">
				<CFPROCPARAM VALUE="1" cfsqltype="CF_SQL_INTEGER">
				<CFPROCPARAM VALUE="#left(trim(replace(arguments.fpCustomerName," ","","ALL")),10)#" cfsqltype="CF_SQL_VARCHAR">
				<CFPROCPARAM VALUE="#arguments.fpCustomerName#" cfsqltype="CF_SQL_VARCHAR">,
				<CFPROCPARAM VALUE="#qGetEmployee.OfficeID#" cfsqltype="CF_SQL_VARCHAR">,
				<CFPROCPARAM VALUE="#arguments.fpCustomerAddress#" cfsqltype="CF_SQL_VARCHAR">,
	            <CFPROCPARAM VALUE="#arguments.fpCustomerCity#"  cfsqltype="CF_SQL_VARCHAR">,
	            <CFPROCPARAM VALUE="#arguments.fpCustomerState#"  cfsqltype="CF_SQL_VARCHAR">,
	            <CFPROCPARAM VALUE="#arguments.fpCustomerZip#" cfsqltype="CF_SQL_VARCHAR">,
	            
            	<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR" null="true">,
			 	<cfif len(trim(arguments.fpCustomerSalesRep))>
			 		<CFPROCPARAM VALUE="#arguments.fpCustomerSalesRep#" cfsqltype="CF_SQL_VARCHAR">,
			 	<cfelse>
			 		<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR" null="true">,
			 	</cfif>
			 	<cfif len(trim(arguments.fpCustomerDispatcher))>
			 		<CFPROCPARAM VALUE="#arguments.fpCustomerDispatcher#" cfsqltype="CF_SQL_VARCHAR">,
			 	<cfelse>
			 		<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR" null="true">,
			 	</cfif>
		 		<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR" null="true">,
		 		<CFPROCPARAM VALUE="#qConfig.CustomerPaymentTerms#" cfsqltype="CF_SQL_VARCHAR">,
	            <CFPROCPARAM VALUE="" cfsqltype="CF_SQL_LONGNVARCHAR">  ,
	            <CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR">,
	            <CFPROCPARAM VALUE="1" cfSqltype="Cf_SQL_BIT">,
	            <CFPROCPARAM VALUE="#arguments.adminUserName#"  cfsqltype="CF_SQL_VARCHAR">,
	            <CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR">,
              	<CFPROCPARAM VALUE="0" cfsqltype="Cf_Sql_MONEY">,
				<CFPROCPARAM VALUE="0" cfsqltype="Cf_Sql_MONEY">,
				<CFPROCPARAM VALUE="0" cfsqltype="Cf_Sql_MONEY">,
			  	<CFPROCPARAM VALUE="0" cfsqltype="Cf_Sql_MONEY">,
			    <CFPROCPARAM VALUE="#qGetEmployee.Country#" cfsqltype="CF_SQL_VARCHAR">,
                <CFPROCPARAM VALUE="#cgi.REMOTE_ADDR#"  cfsqltype="cf_sql_varCHAR">,
                <CFPROCPARAM VALUE="#cgi.HTTP_USER_AGENT#"  cfsqltype="cf_sql_varCHAR">,
			  	<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR">,
			  	<CFPROCPARAM VALUE=""  cfsqltype="CF_SQL_VARCHAR">
			  	<CFPROCPARAM VALUE=""  cfsqltype="CF_SQL_VARCHAR">,
				<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR">,
				<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR">,
				<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR">,
				<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR">,
				<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR">,
				<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR">,
		  		<CFPROCPARAM VALUE=""  cfsqltype="CF_SQL_VARCHAR">,
			  	<CFPROCPARAM VALUE=""  cfsqltype="CF_SQL_VARCHAR">,
				<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_INTEGER"  null="Yes">,				
		  		<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR"  null="Yes">,	
		  		<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR"  null="Yes">,
			    <CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR"  null="Yes">,	
			 	<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR">,
			 	<CFPROCPARAM VALUE="0" cfsqltype="CF_SQL_BIT">,
			 	<CFPROCPARAM VALUE="0" cfsqltype="CF_SQL_BIT">,
				<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR"  null="Yes">	,
				<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR"  null="Yes">	,
			 	<CFPROCPARAM VALUE="0" cfsqltype="CF_SQL_BIT">,
			 	<CFPROCPARAM VALUE="0" cfsqltype="CF_SQL_BIT">,
			 	<CFPROCPARAM VALUE="0" cfsqltype="CF_SQL_BIT">,

			 	<CFPROCPARAM VALUE="#arguments.fpCustomerContact#" cfsqltype="CF_SQL_VARCHAR">,
			 	<CFPROCPARAM VALUE="#arguments.fpCustomerPhone#" cfsqltype="CF_SQL_VARCHAR">,
			 	<CFPROCPARAM VALUE="#arguments.fpCustomerPhoneExt#" cfsqltype="CF_SQL_VARCHAR">,
			 	<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR">,
			 	<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR">,
			 	<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR">,
			 	<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR">,
			 	<CFPROCPARAM VALUE="#arguments.fpCustomerFax#" cfsqltype="CF_SQL_VARCHAR">,
			 	<CFPROCPARAM VALUE="#arguments.fpCustomerFaxExt#" cfsqltype="CF_SQL_VARCHAR">,
			 	<CFPROCPARAM VALUE="#arguments.fpCustomerEmail#" cfsqltype="CF_SQL_VARCHAR">,

			 	<CFPROCPARAM VALUE="1" cfSqltype="Cf_SQL_BIT">,
			 	<CFPROCPARAM VALUE="1" cfSqltype="Cf_SQL_BIT">,
			 	<CFPROCPARAM VALUE="1" cfSqltype="Cf_SQL_BIT">,
			 	<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR" null="true">
			 	<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR" null="true">
			 	<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR" null="true">
			 	<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR" null="true">
			 	<CFPROCPARAM VALUE="0" cfsqltype="CF_SQL_BIT">
            	<cfprocresult name="qLastInsertedCustomer">
			</CFSTOREDPROC>

			<cfquery name="qInsertCustomerOffices" datasource="#arguments.dsn#">
			 	INSERT INTO [CustomerOffices]
		           ([CustomerOfficesID]
		           ,[CustomerID]
		           ,[OfficeID])
		        VALUES(
		        	newid(),
		        	<cfqueryparam cfsqltype="cf_sql_varchar" value="#qLastInsertedCustomer.lastInsertedCustomerID#">,
		        	<cfqueryparam cfsqltype="cf_sql_varchar" value="#qGetEmployee.OfficeID#">
		        	)
			</cfquery>

			<cfset response["SUCCESS"] = 1>
			<cfset response["ID"] = qLastInsertedCustomer.lastInsertedCustomerid>
			<cfreturn response>
			<cfcatch type="any">
				<cfset session = structnew()>
				<cfset CreateLogError(cfcatch)>
				<cfset response["SUCCESS"] = 0>
				<cfreturn response>
			</cfcatch>
		</cftry>
	</cffunction>
	<cffunction name="getLastSettlementDate" access="remote" output="false" returntype="any" returnFormat="json">

		<cfargument name="dsn" type="string" required="yes" />
		<cfargument name="User" type="string" required="yes" />
		<cfargument name="CompanyID" type="string" required="yes" />
		<cftry>
			<cfset response = structNew()>
			
			<cfquery name="qgetLastSettlementDate" datasource="#arguments.dsn#">	
				SELECT TOP 1 LL.NewValue,L.DriverPaidDate FROM Loads L
				INNER JOIN LoadLogs LL ON L.LoadID = LL.LoadID
				WHERE LL.UpdatedByUserID=<cfqueryparam value="#arguments.User#" cfsqltype="cf_sql_varchar">
				AND LL.FieldLabel='Driver Paid Date'
				AND LL.OldValue IS NULL AND LL.NewValue IS NOT NULL
				AND L.DriverPaidDate IS NOT NULL
				and L.customerid in (select customerid from CustomerOffices inner join offices on CustomerOffices.officeid = offices.officeid where offices.companyid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.companyid#">)
				ORDER BY LL.UpdatedTimestamp DESC
			</cfquery>

			<cfset response.success = 1>
			<cfset response.date = qgetLastSettlementDate.NewValue>
			<cfset response.dateF = qgetLastSettlementDate.DriverPaidDate>
			<cfreturn response>
			<cfcatch type="any">
				<cfset response.success = 0>
			</cfcatch>
		</cftry>
	</cffunction>

	<cffunction name="revertDriverSettlement" access="public" output="false" returntype="any">
	   	<cfargument name="structFrm" type="struct" required="yes" />
		<cfquery name="qgetDriverSettlementInitial" datasource="#variables.dsn#">	
			SELECT 
			C.CarrierID,
			L.LoadNumber,
			L.LoadID,
			L.DriverPaidDate
			FROM Carriers C
			LEFT JOIN LoadStops LS ON LS.NewCarrierID = C.CarrierID
			LEFT JOIN Loads L ON L.LoadID = LS.LoadID
			WHERE L.DriverPaidDate = <cfqueryparam value="#arguments.structFrm.revDateF#" cfsqltype="cf_sql_date">
			AND C.CompanyID = <cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar">
			ORDER BY C.CarrierName,L.LoadNumber,LS.StopNo,LS.LoadType
		</cfquery>
		<cfset LoadNumberList = ListRemoveDuplicates(ValueList(qgetDriverSettlementInitial.LoadNumber))>
		<CFSTOREDPROC PROCEDURE="spUpdateDriverPaidDate" DATASOURCE="#variables.dsn#">
			<CFPROCPARAM VALUE="" cfsqltype="cf_sql_date" null="true">
			<CFPROCPARAM VALUE="#ListRemoveDuplicates(ValueList(qgetDriverSettlementInitial.LoadID))#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR">
		</CFSTOREDPROC>
		<cfset listLogLoadID = "">
		<cfloop query="qgetDriverSettlementInitial">
			<cfif not listFindNoCase(listLogLoadID, qgetDriverSettlementInitial.LoadID)>
				<cfquery name="insertLoadLog" datasource="#variables.dsn#" result="qResult">
					INSERT INTO LoadLogs (
								LoadID,
								LoadNumber,
								FieldLabel,
								oldValue,
								NewValue,
								UpdatedByUserID,
								UpdatedBy,
								UpdatedTimestamp
							)
						values
							(
								<cfqueryparam value="#qgetDriverSettlementInitial.LoadID#" cfsqltype="cf_sql_nvarchar">,
								<cfqueryparam value="#qgetDriverSettlementInitial.LoadNumber#" cfsqltype="cf_sql_bigint">,
								<cfqueryparam value="Driver Paid Date" cfsqltype="cf_sql_nvarchar">,
								<cfqueryparam value="#arguments.structFrm.revDate#" cfsqltype="cf_sql_nvarchar">,
								NULL,
								<cfqueryparam value="#session.empid#" cfsqltype="cf_sql_nvarchar">,
								<cfqueryparam value="#session.adminusername#" cfsqltype="cf_sql_nvarchar">,
								<cfqueryparam value="#Now()#" cfsqltype="cf_sql_timestamp">
							)
				</cfquery>
				<cfset listLogLoadID = listAppend(listLogLoadID, qgetDriverSettlementInitial.LoadID)>
			</cfif>
		</cfloop>
		<cfset CarrierIDList = ListRemoveDuplicates(ValueList(qgetDriverSettlementInitial.CarrierID))>
		<cfif len(trim(CarrierIDList))>
			<CFSTOREDPROC PROCEDURE="spUpdateDriverPaidDate" DATASOURCE="#variables.dsn#">
				<CFPROCPARAM VALUE="" cfsqltype="cf_sql_date"  null="true">
				<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR">
				<CFPROCPARAM VALUE="#CarrierIDList#" cfsqltype="CF_SQL_VARCHAR">
			</CFSTOREDPROC>
		</cfif>
	</cffunction>

	<cffunction name="updateEDispatchPromptSettingOff" access="remote" returntype="any">
		<cfargument name="dsn" required="yes" type="string" />
		<cfargument name="companyid" required="yes" type="string" />
		<cfquery name="updateSystemSetting" datasource="#arguments.dsn#">
			UPDATE systemconfig
			SET RateConPromptOption = 2 where companyid =<cfqueryparam value="#arguments.companyid#" cfsqltype="cf_sql_varchar">
		</cfquery>
		<cfreturn 1>
	</cffunction>

	<cffunction name="sendProject44Local" access="remote" returntype="string"  returnformat="plain">
		<cfargument name="loadid" type="string" required="yes">
		<cfargument name="stopno" type="string" required="yes">
		<cfargument name="LoadType" type="numeric" required="yes">
		<cfargument name="event" type="string" required="yes">
		<cfargument name="dsn" type="string" required="no" default="">
		<cfargument name="empid" type="string" required="no" default="">
		<cfargument name="time" type="string" required="no" default="">
		<cfargument name="companyid" type="string" required="no" default="">
		<cftry>
			<cfif structkeyexists(arguments,"companyid") and len(trim(arguments.companyid))>
				<cfset local.companyid = arguments.companyid>
			<cfelse>
				<cfset local.companyid = session.companyid>
			</cfif>
			<cfif len(trim(arguments.time))>
				<cfquery name="updateTime" datasource="#arguments.dsn#">
					UPDATE LoadStops Set 
					<cfif event EQ 'ARRIVED'>
						TimeIn 
					<cfelse>
						Timeout
					</cfif> = <cfqueryparam value="#arguments.time#" cfsqltype="cf_sql_varchar">
					WHERE LoadID = <cfqueryparam value="#arguments.loadid#" cfsqltype="cf_sql_varchar">
					AND StopNo = <cfqueryparam value="#arguments.stopno#" cfsqltype="cf_sql_integer">
					AND LoadType = <cfqueryparam value="#arguments.LoadType#" cfsqltype="cf_sql_integer">
				</cfquery>
			</cfif>
			<cfquery name="getLoadDetails" datasource="#arguments.dsn#">
				SELECT 
				C.SCAC
				,C.MCNumber
				,C.DOTNumber
				,CS.CustomerName
				,CS.Project44ApiUsername
				,CS.Project44ApiPassword
				,L.LoadNumber
				,L.BOLNum
				,LS.StopDate
				,LS.TimeIn
				,LS.TimeOut
				,LS.Address
				,LS.City
				,LS.StateCode
				,LS.PostalCode
				FROM Loads L
				INNER JOIN LoadStops LS ON L.LoadID = LS.LoadID
				LEFT JOIN Carriers  C ON C.CarrierID = LS.NewCarrierID
				LEFT JOIN Customers  CS ON CS.CustomerID = L.CustomerID
				WHERE L.LoadID = <cfqueryparam value="#arguments.loadid#" cfsqltype="cf_sql_varchar">
				AND LS.StopNo = <cfqueryparam value="#arguments.stopno#" cfsqltype="cf_sql_integer">
				AND LS.LoadType = <cfqueryparam value="#arguments.LoadType#" cfsqltype="cf_sql_integer">
			</cfquery>

			<cfif arguments.event EQ "ARRIVED">
				<cfset Time = Insert(":",getLoadDetails.TimeIn,2)>
			<cfelse>
				<cfset Time = Insert(":",getLoadDetails.TimeOut,2)>
			</cfif>
			<cfset Date = "{ts '#DateFormat(getLoadDetails.StopDate,'YYYY-MM-DD')# #Time#:00'}">
			<cfset datetime = dateConvert( "local2utc", Date )>
			<cfset utcTime = dateFormat( datetime, "yyyy-mm-dd" ) & "T" & timeFormat( datetime, "HH:mm:ss" )>

			<cfset latitude = ''>
			<cfset longitude = ''>
			<cfif structKeyExists(arguments,"empid")>
				<cfquery name="getProMileDetails" datasource="#arguments.dsn#">
					select PCMilerUsername,PCMilerPassword,PCMilerCompanyCode from SystemConfig
					where companyid = <cfqueryparam value="#local.companyid#" cfsqltype="cf_sql_varchar">
				</cfquery>
			</cfif>
			
			<cfif getProMileDetails.recordcount>
				<cfset variables.Username=getProMileDetails.PCMilerUsername>
				<cfset variables.Password=getProMileDetails.PCMilerPassword>
				<cfset variables.CompanyCode=getProMileDetails.PCMilerCompanyCode>
			</cfif>

			<cfoutput>
				<cfsavecontent variable="myVariable">
					<?xml version="1.0" encoding="utf-8"?>
						<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
							<soap:Body>
								<Geocode  xmlns="http://promiles.com/">
									<c>
										<Username>#variables.Username#</Username>
										<Password>#variables.Password#</Password>
										<CompanyCode>#variables.CompanyCode#</CompanyCode>
									</c>
									<Address>#getLoadDetails.Address#</Address>
								    <City>#getLoadDetails.City#</City>
								    <StateAbbreviation>#getLoadDetails.StateCode#</StateAbbreviation>
								    <PostalCode>#getLoadDetails.PostalCode#</PostalCode>
								</Geocode>
		  					</soap:Body>
						</soap:Envelope>
				</cfsavecontent>
			</cfoutput>
			
			<cfhttp url="http://prime.promiles.com/Webservices/v1_1/PRIMEStandardV1_1.asmx?op=Geocode" method="post" result="httpResponse">
				<cfhttpparam type="header" name="Content-Type" value="text/xml; charset=utf-8" />
				<cfhttpparam type="header" name="Content-Length" value="length" />
				<cfhttpparam type="header" name="SOAPAction" value="http://promiles.com/Geocode" />
				<cfhttpparam type="xml" value="#trim(myVariable)#" />
			</cfhttp>

			<cfif not FindNoCase("Failure",httpResponse.Statuscode)>
				<cfset soapResponse = xmlParse(httpResponse.fileContent) />
				<cfinvoke  method="ConvertXmlToStruct" xmlNode="#soapResponse#" str="#structNew()#" returnvariable="xmlToStruct"/>
				<cfif IsDefined('xmlToStruct.Body.GeocodeResponse.GeocodeResult.GeocodedLocation') >
					<cfif xmlToStruct.Body.GeocodeResponse.GeocodeResult.ResponseStatus eq 'SUCCESS'>
						<cfset latitude = xmlToStruct.Body.GeocodeResponse.GeocodeResult.GeocodedLocation.latitude>
						<cfset longitude = xmlToStruct.Body.GeocodeResponse.GeocodeResult.GeocodedLocation.longitude>
					</cfif>
				</cfif>
			</cfif>

			<cfset type=''>
			<cfif arguments.event EQ "ARRIVED" AND arguments.LoadType EQ 2>
				<cfset type= 'Arrived at delivery.'>
			</cfif>
			<cfif arguments.event EQ "ARRIVED" AND arguments.LoadType EQ 1>
				<cfset type= 'Arrived at pickup.'>
			</cfif>
			<cfif arguments.event EQ "DEPARTED" AND arguments.LoadType EQ 1>
				<cfset type= 'Departed from pickup.'>
			</cfif>
			<cfif arguments.event EQ "DEPARTED" AND arguments.LoadType EQ 2>
				<cfset type= 'Departed from delivery.'>
			</cfif>

			<cfset error = "">
					
			<cfif NOT len(trim(getLoadDetails.BolNum))>
				<cfset error = "Shipment identifier data(BolNumber) not available.">
			</cfif>
			
			<cfif NOT len(trim(latitude)) OR NOT len(trim(longitude))>
				<cfset error = "Location data not available.">
			</cfif>

			<cfif NOT len(trim(getLoadDetails.Project44ApiUsername)) OR NOT len(trim(getLoadDetails.Project44ApiPassword))>
				<cfset error = "Api crendentials not available.">
			</cfif>

			<cfset body = structNew()>
						
			<cfif NOT len(trim(error))>
				<cfset body = structNew()>
				
				<cfset arr_shipmentIdentifiers = arrayNew(1)>
				<cfset struct_shipmentIdentifiers = structNew()>

				<cfset struct_shipmentIdentifiers["type"] = "ORDER">
				<cfset struct_shipmentIdentifiers["value"] = getLoadDetails.BOLNum>
				<cfset arrayAppend(arr_shipmentIdentifiers, struct_shipmentIdentifiers)>

				<cfset body["shipmentIdentifiers"] = arr_shipmentIdentifiers>

				<cfset body["latitude"] = latitude>
				<cfset body["longitude"] = longitude>
				<cfset body["utcTimestamp"] = utcTime>
				<cfset body["customerId"] = getLoadDetails.CustomerName>
				<cfset body["eventType"] = arguments.event>

				<cfhttp
						method="post"
						url="https://cloud.p-44.com/api/carriers/v2/tl/shipments/statusUpdates"  username="#trim(getLoadDetails.Project44ApiUsername)#" password="#trim(getLoadDetails.Project44ApiPassword)#"
						result="returnStruct">
								<cfhttpparam type="HEADER" name="Content-Type" value="application/json">
								<cfhttpparam type="body" value="#serializeJSON(body)#">
				</cfhttp>

				<cfset filecontent = deserializeJSON(returnStruct.filecontent)>
				<cfif structKeyExists(filecontent, "errors")>
					<cfset error = filecontent.errors[1].message>
				<cfelseif structKeyExists(filecontent, "httpMessage") AND filecontent.httpMessage EQ 'Unauthorized'>
					<cfquery name="qProject44Log" datasource="#arguments.dsn#">
						INSERT INTO Project44APiLog (LogId,LoadNumber,Message,CreatedDate,Success,RequestData,Type,CompanyID)
						VALUES(newid(),'#getLoadDetails.LoadNumber#','Unauthorized.Please check Api crendentials.',getdate(),0,'#serializeJSON(body)#','#type#','#local.CompanyID#')
					</cfquery>
				<cfelse>
					<cfquery name="qProject44Log" datasource="#arguments.dsn#">
						INSERT INTO Project44APiLog (LogId,LoadNumber,Message,CreatedDate,Success,RequestData,Type,CompanyID)
						VALUES(newid(),'#getLoadDetails.LoadNumber#','Location data sent successfully.',getdate(),1,'#serializeJSON(body)#','#type#','#local.CompanyID#')
					</cfquery>
				</cfif>
			</cfif>

			<cfif len(trim(error))>
				<cfquery name="qProject44Log" datasource="#arguments.dsn#">
					INSERT INTO Project44APiLog (LogId,LoadNumber,Message,CreatedDate,Success,RequestData,Type,CompanyID)
					VALUES(newid(),'#getLoadDetails.LoadNumber#','#error#',getdate(),0,NULL,'#type#','#local.CompanyID#')
				</cfquery>
				<cfreturn 'Unable to post to project44.#error#'>
			</cfif>
			<cfreturn 'Posted to project44 successfully.'>
			<cfcatch>
				<cfreturn 'Unable to post to project44.'>
			</cfcatch>
		</cftry>
	</cffunction>

	<cffunction name="getLoadsByStatus" access="remote" output="yes" returnformat="json">
		<cfargument name="dsn" type="string" required="yes" />
		<cfargument name="StatusTypeID" required="No" type="any">
		<cfargument name="CompanyID" required="No" type="any">
		<cfquery name="qGetLoadsByStatus" datasource="#arguments.dsn#">
			SELECT LoadID,LoadNumber FROM Loads 
			INNER JOIN (SELECT customerid
						FROM CustomerOffices c1 INNER JOIN offices o1 ON o1.officeid = c1.OfficeID
						WHERE o1.CompanyID = <cfqueryparam value="#arguments.CompanyID#" cfsqltype="cf_sql_varchar">
						Group BY customerid) Offices ON Offices.CustomerID = loads.CustomerID
			WHERE StatusTypeID = <cfqueryparam value="#arguments.StatusTypeID#" cfsqltype="cf_sql_varchar">
		</cfquery>

		<cfset tempArr = arrayNew(1)>
		<cfloop query="qGetLoadsByStatus">
			<cfset tempStruct = structNew()>
			<cfset tempStruct.LoadID = qGetLoadsByStatus.LoadID>
			<cfset tempStruct.LoadNumber = qGetLoadsByStatus.LoadNumber>
			<cfset arrayAppend(tempArr, tempStruct)>
		</cfloop>

		<cfreturn serializeJSON(tempArr)>
	</cffunction>

	<cffunction name="getInvoiceLoads" access="public" returntype="query">
    	<cfargument name="frmStruct" required="no" type="struct">

    	<cfif structKeyExists(arguments.frmStruct, "pageNo")>
    		<cfset local.pageNo = arguments.frmStruct.pageNo>
    	<cfelse>
    		<cfset local.pageNo = 1>
    	</cfif>

    	<cfif structKeyExists(arguments.frmStruct, "sortby")>
    		<cfset local.sortby = arguments.frmStruct.sortby>
    	<cfelse>
    		<cfset local.sortby = "LoadNumber">
    	</cfif>

    	<cfif structKeyExists(arguments.frmStruct, "sortorder")>
    		<cfset local.sortorder = arguments.frmStruct.sortorder>
    	<cfelse>
    		<cfset local.sortorder = "ASC">
    	</cfif>

		<cfquery name="qGetInvoiceLoads" datasource="#variables.dsn#">
			BEGIN WITH page AS( 
				SELECT 
				L.LoadID,
				L.LoadNumber,
				LST.StatusText,
				LST.StatusDescription,
				L.CustName,
				L.TotalCarrierCharges,
				L.NewPickupDate,
				L.BillDate,
				L.TotalCustomerCharges,
				ROW_NUMBER() OVER (ORDER BY #local.sortby# #local.sortorder#) AS Row
				FROM Loads L
				INNER JOIN CustomerOffices CO ON CO.CustomerID = L.CustomerID
				INNER JOIN Offices O ON O.OfficeID = CO.OfficeID
				INNER JOIN LoadStatusTypes LST ON LST.StatusTypeID = L.StatusTypeID AND LST.CompanyID = O.CompanyID
				INNER JOIN SystemConfig S ON S.ARAndAPExportStatusID = L.StatusTypeID AND S.CompanyID = O.CompanyID
				WHERE O.CompanyID = <cfqueryparam value="#session.companyID#" cfsqltype="cf_sql_varchar">
				AND L.ARExported  = 0
				<cfif Len(Trim(arguments.frmStruct.InvoiceDateFrom)) AND Len(Trim(arguments.frmStruct.InvoiceDateTo))>
					AND ISNULL(L.BillDate,L.NewPickupDate) BETWEEN <cfqueryparam value="#Trim(arguments.frmStruct.InvoiceDateFrom)#" cfsqltype="cf_sql_date">
						AND <cfqueryparam value="#Trim(arguments.frmStruct.InvoiceDateTO)#" cfsqltype="cf_sql_date">
				</cfif>
				GROUP BY 
				L.LoadID,
				L.LoadNumber,
				LST.StatusText,
				LST.StatusDescription,
				L.CustName,
				L.TotalCarrierCharges,
				L.NewPickupDate,
				L.BillDate,
				L.TotalCustomerCharges
				)
				SELECT *,(select (max(row)/30) + (CASE WHEN max(row)%30 <> 0 THEN 1 ELSE 0 END)  FROM page) AS TotalPages  FROM page
		    	WHERE Row BETWEEN (#local.pageNo# - 1) * 30 + 1 AND #local.pageNo# * 30
	    	END
		</cfquery>
	    <cfreturn qGetInvoiceLoads>
	</cffunction>

	<cffunction name="getARInvoiceCustomerCarrierTotals" access="public" returntype="query">
		<cfquery name="qGetARInvoiceCustomerCarrierTotals" datasource="#variables.dsn#">
			SELECT L1.LoadID,L1.TotalCustomerCharges,L1.TotalCarrierCharges FROM Loads L1 
			INNER JOIN CustomerOffices CO1 ON CO1.CustomerID = L1.CustomerID
			INNER JOIN Offices O1 ON O1.OfficeID = CO1.OfficeID
			INNER JOIN SystemConfig S1 ON S1.CompanyID =  O1.CompanyID 
			INNER JOIN LoadStatusTypes LST1 ON LST1.StatusTypeID = L1.StatusTypeID AND S1.ARAndAPExportStatusID = L1.StatusTypeID
			WHERE O1.CompanyID = <cfqueryparam value="#session.companyID#" cfsqltype="cf_sql_varchar">
			AND L1.ARExported  = 0
			<cfif Len(Trim(arguments.frmStruct.InvoiceDateFrom)) AND Len(Trim(arguments.frmStruct.InvoiceDateTo))>
				AND (L1.BillDate BETWEEN <cfqueryparam value="#Trim(arguments.frmStruct.InvoiceDateFrom)#" cfsqltype="cf_sql_date">
					AND <cfqueryparam value="#Trim(arguments.frmStruct.InvoiceDateTO)#" cfsqltype="cf_sql_date">
					OR L1.NewPickupDate BETWEEN <cfqueryparam value="#Trim(arguments.frmStruct.InvoiceDateFrom)#" cfsqltype="cf_sql_date">
					AND <cfqueryparam value="#Trim(arguments.frmStruct.InvoiceDateTO)#" cfsqltype="cf_sql_date">
					)
			</cfif>
		</cfquery>
		<cfreturn qGetARInvoiceCustomerCarrierTotals>
	</cffunction>

	<cffunction name="InvoiceLoads" access="public" returntype="struct" returnformat="json">
    	<cfargument name="frmStruct" required="no" type="struct">
    	<cftransaction>
    		<cfquery name="qGetInvoiceLoads" datasource="#variables.dsn#">
				SELECT 
				L.LoadID,
				L.LoadNumber,
				LST.StatusText,
				L.CustName,
				L.TotalCarrierCharges,
				L.NewPickupDate,
				L.BillDate,
				L.TotalCustomerCharges,
				L.CustomerID AS PayerID,
				C.CustomerCode,
				L.CustomerPONo
				FROM Loads L
				INNER JOIN Customers C ON C.CustomerID = L.CustomerID
				INNER JOIN CustomerOffices CO ON CO.CustomerID = C.CustomerID
				INNER JOIN Offices O ON O.OfficeID = CO.OfficeID
				INNER JOIN LoadStatusTypes LST ON LST.StatusTypeID = L.StatusTypeID AND LST.CompanyID = O.CompanyID
				INNER JOIN SystemConfig S ON S.ARAndAPExportStatusID = L.StatusTypeID AND S.CompanyID = O.CompanyID
				WHERE O.CompanyID = <cfqueryparam value="#session.companyID#" cfsqltype="cf_sql_varchar">
				AND L.ARExported  = 0
				<cfif Len(Trim(arguments.frmStruct.InvoiceDateFrom)) AND Len(Trim(arguments.frmStruct.InvoiceDateTo))>
					AND (L.BillDate BETWEEN <cfqueryparam value="#Trim(arguments.frmStruct.InvoiceDateFrom)#" cfsqltype="cf_sql_date">
						AND <cfqueryparam value="#Trim(arguments.frmStruct.InvoiceDateTO)#" cfsqltype="cf_sql_date">
						OR L.NewPickupDate BETWEEN <cfqueryparam value="#Trim(arguments.frmStruct.InvoiceDateFrom)#" cfsqltype="cf_sql_date">
						AND <cfqueryparam value="#Trim(arguments.frmStruct.InvoiceDateTO)#" cfsqltype="cf_sql_date">
						)
				</cfif>
				<cfif structKeyExists(arguments.frmStruct, "ExcludeLoads") AND Len(Trim(arguments.frmStruct.ExcludeLoads))>
					AND L.LoadID NOT IN (<cfqueryparam list="true" value="#arguments.frmStruct.ExcludeLoads#">)
				</cfif>
				GROUP BY L.LoadID,
				L.LoadNumber,
				LST.StatusText,
				L.CustName,
				L.TotalCarrierCharges,
				L.NewPickupDate,
				L.BillDate,
				L.TotalCustomerCharges,
				L.CustomerID,
				C.CustomerCode,
				L.CustomerPONo
			</cfquery>

			<cfloop query="qGetInvoiceLoads">
				<cfset local.LoadID = qGetInvoiceLoads.LoadID>
				<cfset local.CustomerID = qGetInvoiceLoads.PayerID>
				<cfset local.LoadNumber = qGetInvoiceLoads.LoadNumber>
				<cfset local.CustomerCode = qGetInvoiceLoads.CustomerCode>
				<cfset local.Total = qGetInvoiceLoads.TotalCustomerCharges>
				<cfset local.Balance = qGetInvoiceLoads.TotalCustomerCharges>
				<cfset local.Description = qGetInvoiceLoads.CustomerPONo>

				<cfif len(trim(qGetInvoiceLoads.BillDate))>
					<cfset local.InvoiceDate = qGetInvoiceLoads.BillDate>
				<cfelse>
					<cfset local.InvoiceDate = qGetInvoiceLoads.NewPickupDate>
				</cfif>
				
				<cfif NOT len(trim(local.InvoiceDate))>
					<cfset respStr = structNew()>
			    	<cfset respStr.res = 'error'>
			    	<cfset respStr.msg = "Invalid Invoice Date For Load###local.LoadNumber#.">
			    	<cfreturn respStr>
				</cfif>

				<cfinvoke method="check_fiscal" Trans_Date="#local.InvoiceDate#" returnvariable="resCkFiscal" />
				<cfif resCkFiscal.res eq 'error'>
					<cftransaction action="rollback">
			    	<cfreturn resCkFiscal>
			    <cfelse>
			    	<cfset form.year_past = resCkFiscal.year_past>
            	</cfif>
	   			<cfif len(trim(local.InvoiceDate))>
		   			<cfquery name="insQuery" datasource="#variables.dsn#">
		   				INSERT INTO [LMA Accounts Receivable Transactions](
		   					[LoadID]
		   				   ,[CompanyID]
				           ,[CustomerID]
				           ,[TRANS_NUMBER]
				           ,[id]
				           ,[date]
				           ,[Total]
				           ,[Balance]
				           ,[description]
				           ,[term_number]
				           ,[typetrans]
				           ,[department]
				           ,[salesperson]
				           ,[commission]
				           ,[applied]
				           ,[discount]
				           ,[sales_tax]
				           ,[Tax Code Number]
				           ,[DiscountTaken]
				           ,[Created]
				           ,[CreatedBy]
				           ,[CommissionPaid]
				           ,[CommissionPaidDate]
				           ,[Notes]
						)
						VALUES
			           (<cfqueryparam value="#Local.LoadID#" cfsqltype="cf_sql_varchar">
			           ,<cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar">
			           ,<cfqueryparam value="#Local.CustomerID#" cfsqltype="cf_sql_varchar">
			           ,<cfqueryparam value="#Local.LoadNumber#" cfsqltype="cf_sql_varchar">
			           ,<cfqueryparam value="#Local.CustomerCode#" cfsqltype="cf_sql_varchar">
			           ,<cfqueryparam value="#Local.InvoiceDate#" cfsqltype="cf_sql_date">
			           ,<cfqueryparam value="#Local.Total#" cfsqltype="cf_sql_money">
			           ,<cfqueryparam value="#Local.Balance#" cfsqltype="cf_sql_money">
			           ,<cfqueryparam value="#Local.Description#" cfsqltype="cf_sql_varchar">
			           ,9
			           ,'I'
			           ,NULL
			           ,NULL
			           ,NULL
			           ,0
			           ,0
			           ,0
			           ,NULL
			           ,0
			           ,GETDATE()
			           ,<cfqueryparam value="#session.AdminUserName#" cfsqltype="cf_sql_varchar">
			           ,0
			           ,NULL
			           ,NULL)

			            UPDATE Customers SET Balance = Balance + <cfqueryparam value="#Local.Balance#" cfsqltype="cf_sql_money">
			            WHERE CustomerID = <cfqueryparam value="#Local.CustomerID#" cfsqltype="cf_sql_varchar">

			            INSERT INTO [LMA UpdateLog]
					           ([TableName]
					           ,[RecordID]
					           ,[FieldName]
					           ,[OldValue]
					           ,[NewValue]
					           ,[Status]
					           ,[UpdatedBy]
					           ,[DateUpdated]
					           ,[MachineName]
					           ,[Notes]
					           ,[Created]
					           ,[id]
					           ,[CompanyID])
					    VALUES
					           ('Load Manager'
					           ,'AR'
					           ,'NA'
					           ,'NA'
					           ,'NA'
					           ,'NA'
					           ,<cfqueryparam value="#session.AdminUserName#" cfsqltype="cf_sql_varchar">
					           ,GETDATE()
					           ,'DESKTOP-KNQP4R0'
					           ,'N/A'
					           ,GETDATE()
					           ,(SELECT ISNULL(MAX(ID),0)+1 FROM [LMA UpdateLog])
					           ,<cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar">)
					    UPDATE Loads SET ARExported = 1 WHERE LoadID = <cfqueryparam value="#Local.LoadID#" cfsqltype="cf_sql_varchar">
		   			</cfquery>

		   			
		   			<cfif structKeyExists(arguments.frmStruct, "UseDifferentGLAccountForCommodityTypes") AND arguments.frmStruct.UseDifferentGLAccountForCommodityTypes EQ 1>
			   			<cfquery name="qGetLoadPostDetails"  datasource="#variables.dsn#">
			   				SELECT L.CustFlatRate,L.customerMilesCharges,LSC.CustCharges,LSC.Description,U.GLSalesAccount,U.GLBankAccount,ISNULL(U.PaymentAdvance,0) AS PaymentAdvance FROM Loads L
							INNER JOIN LoadStops LS ON LS.LoadID = L.LoadID 
							INNER JOIN LoadStopCommodities LSC ON LSC.LoadStopID = LS.LoadStopID
							LEFT JOIN Units U ON U.UnitID = LSC.UnitID
							WHERE L.LoadID = <cfqueryparam value="#Local.LoadID#" cfsqltype="cf_sql_varchar">
			   			</cfquery>
			   			
			   			<cfset local.post_amt = 0>

			   			<cfif len(trim(qGetLoadPostDetails.CustFlatRate))>
			   				<cfset local.post_amt = local.post_amt+qGetLoadPostDetails.CustFlatRate>
			   			</cfif>

			   			<cfif len(trim(qGetLoadPostDetails.customerMilesCharges))>
			   				<cfset local.post_amt = local.post_amt+qGetLoadPostDetails.customerMilesCharges>
			   			</cfif>
			   			<cfloop query="qGetLoadPostDetails">
							<cfif not len(trim(qGetLoadPostDetails.GLBankAccount))>
								<cfset local.post_amt = local.post_amt+qGetLoadPostDetails.CustCharges>
							</cfif>
						</cfloop>
						<cfinvoke method="PostToGL" returnvariable="qPostToGL" account="#arguments.frmstruct.ARGLAccount#" cv_code="#local.customercode#" year_past="#arguments.frmStruct.year_past#" post_amt="#local.post_amt#" Invoice_Code="#local.LoadNumber#" tran_type="RS" tran_desc="Flat Rate" tran_date="#local.invoiceDate#" module=""/>

						<cfset local.post_amt = 0>

						<cfif len(trim(qGetLoadPostDetails.CustFlatRate))>
			   				<cfset local.post_amt = local.post_amt+qGetLoadPostDetails.CustFlatRate>
			   			</cfif>

			   			<cfif len(trim(qGetLoadPostDetails.customerMilesCharges))>
			   				<cfset local.post_amt = local.post_amt+qGetLoadPostDetails.customerMilesCharges>
			   			</cfif>

			   			<cfloop query="qGetLoadPostDetails">
							<cfif not len(trim(qGetLoadPostDetails.GLSalesAccount))>
								<cfset local.post_amt = local.post_amt+qGetLoadPostDetails.CustCharges>
							</cfif>
						</cfloop>
						<cfset local.post_amt = -1* local.post_amt>
						<cfinvoke method="PostToGL" returnvariable="qPostToGL" account="#arguments.frmstruct.FreightSales#" cv_code="#local.customercode#" year_past="#arguments.frmStruct.year_past#" post_amt="#local.post_amt#" Invoice_Code="#local.LoadNumber#" tran_type="RS" tran_desc="Flat Rate" tran_date="#local.invoiceDate#" module=""/>

						<cfloop query="qGetLoadPostDetails">
							<cfif qGetLoadPostDetails.PaymentAdvance>
								<cfif len(trim(qGetLoadPostDetails.GLBankAccount))>
									<cfset local.post_amt = qGetLoadPostDetails.CustCharges>
									<cfset local.post_acct = qGetLoadPostDetails.GLBankAccount>
									<cfset local.tran_desc = qGetLoadPostDetails.Description>

									<cfinvoke method="PostToGL" returnvariable="qPostToGL" account="#local.post_acct#" cv_code="#local.customercode#" year_past="#arguments.frmStruct.year_past#" post_amt="#local.post_amt#" Invoice_Code="#local.LoadNumber#" tran_type="RS" tran_desc="#local.tran_desc#" tran_date="#local.invoiceDate#" module=""/>

									<cfset local.post_amt = -1*qGetLoadPostDetails.CustCharges>
									<cfinvoke method="PostToGL" returnvariable="qPostToGL" account="#arguments.frmstruct.ARGLAccount#" cv_code="#local.customercode#" year_past="#arguments.frmStruct.year_past#" post_amt="#local.post_amt#" Invoice_Code="#local.LoadNumber#" tran_type="RS" tran_desc="#local.tran_desc#" tran_date="#local.invoiceDate#" module=""/>
								</cfif>
							<cfelse>
								<cfif len(trim(qGetLoadPostDetails.GLSalesAccount))>
									<cfset local.post_amt = -1*qGetLoadPostDetails.CustCharges>
									<cfset local.post_acct = qGetLoadPostDetails.GLSalesAccount>
									<cfset local.tran_desc = qGetLoadPostDetails.Description>

									<cfinvoke method="PostToGL" returnvariable="qPostToGL" account="#local.post_acct#" cv_code="#local.customercode#" year_past="#arguments.frmStruct.year_past#" post_amt="#local.post_amt#" Invoice_Code="#local.LoadNumber#" tran_type="RS" tran_desc="#local.tran_desc#" tran_date="#local.invoiceDate#" module=""/>

								</cfif>
							</cfif>
						</cfloop>
					<cfelse>
						<cfinvoke method="PostToGL" returnvariable="qPostToGL" account="#arguments.frmstruct.ARGLAccount#" cv_code="#local.customercode#" year_past="#arguments.frmStruct.year_past#" post_amt="#local.Total#" Invoice_Code="#local.LoadNumber#" tran_type="RS" tran_desc="Flat Rate" tran_date="#local.invoiceDate#" module=""/>
						<cfset local.Total = -1* local.Total>
						<cfinvoke method="PostToGL" returnvariable="qPostToGL" account="#arguments.frmstruct.FreightSales#" cv_code="#local.customercode#" year_past="#arguments.frmStruct.year_past#" post_amt="#local.Total#" Invoice_Code="#local.LoadNumber#" tran_type="RS" tran_desc="Flat Rate" tran_date="#local.invoiceDate#" module=""/>
					</cfif>
		   		</cfif>
    		</cfloop>
    	</cftransaction>
    	<cfset respStr = structNew()>
    	<cfset respStr.res = 'success'>
    	<cfset respStr.msg = "Invoices have been posted.">
    	<cfreturn respStr>
    </cffunction>

    <cffunction name="getLMAInvoices" access="remote" output="yes" returnformat="plain">
		<cfargument name="dsn" type="string" required="yes" />
		<cfargument name="CompanyID" required="No" type="any">
		<cfargument name="CustomerID" required="No" type="any">
		<cfargument name="SortBy" required="No" type="any" default="TRANS_NUMBER">
		<cfargument name="Sortorder" required="No" type="any" default="ASC">
		<cfargument name="ConsolidationNo" required="No" type="any" default="">
		
		<cfquery name="qgetLMAInvoices" datasource="#arguments.dsn#">
			SELECT 
			[Date],
			typetrans,
			TRANS_NUMBER,
			Total,
			Balance,
			Description,
			0 AS Applied,
			0 AS Discount,
			id,
			[LMA Accounts Receivable Transactions].customerid,
			[LMA Accounts Receivable Transactions].LoadID
			FROM [LMA Accounts Receivable Transactions] 
			inner join (select
				    customerid
					from CustomerOffices c1 inner join offices o1 on o1.officeid = c1.OfficeID
					where o1.CompanyID = '#arguments.companyid#'
					group by customerid) Offices ON Offices.CustomerID = [LMA Accounts Receivable Transactions].CustomerID
			WHERE [LMA Accounts Receivable Transactions].CustomerID = <cfqueryparam value="#arguments.CustomerID#" cfsqltype="cf_sql_varchar"> 
			AND typetrans IN ('I','C')  
			AND Balance <> 0
			<cfif len(trim(arguments.ConsolidationNo))>
			UNION
			SELECT 
				LC.Date
				,'I' AS typetrans
				,L.LoadNumber AS TRANS_NUMBER
				,L.TotalCustomerCharges AS Total
				,L.TotalCustomerCharges AS Balance
				,L.CustomerPONo AS Description
				,0 AS Applied
				,0 AS Discount
				,C.CustomerCode AS id
				,C.CustomerID
				,L.LoadID
				FROM LoadsConsolidated LC
				INNER JOIN LoadsConsolidatedDetail LCD ON LCD.ConsolidatedID = LC.ID
				INNER JOIN Loads L ON L.LoadID = LCD.LoadID
				INNER JOIN Customers C ON C.CustomerID = LC.CustomerID
				WHERE LC.CustomerID = <cfqueryparam value="#arguments.CustomerID#" cfsqltype="cf_sql_varchar"> AND Status = 'OPEN'
					AND ConsolidatedInvoiceNumber = <cfqueryparam value="#arguments.ConsolidationNo#" cfsqltype="cf_sql_integer">
			</cfif>
			ORDER BY #arguments.SortBy# #arguments.Sortorder#
		</cfquery>

		<cfset rowNum = 0>
		<cfsavecontent variable="response">
			<cfif qgetLMAInvoices.recordcount>
				<input type="hidden" name="totalcount" value="#qgetLMAInvoices.recordcount#">
				<input type="hidden" name="companycode" value="#qgetLMAInvoices.id#">
				<input type="hidden" name="customerid" value="#qgetLMAInvoices.customerid#">
				<cfoutput query="qgetLMAInvoices">
		            <tr style="cursor: default;" <cfif qgetLMAInvoices.currentRow mod 2 eq 0>bgcolor="##FFFFFF"<cfelse>bgcolor="##f7f7f7"</cfif>>
		                <td height="20" class="sky-bg">&nbsp;</td>
		                <input type="hidden" name="invoiceno_#qgetLMAInvoices.currentRow#" value="#qgetLMAInvoices.TRANS_NUMBER#">
		                <input type="hidden" name="total_#qgetLMAInvoices.currentRow#" value="#qgetLMAInvoices.total#">
		                <input type="hidden" name="balance_#qgetLMAInvoices.currentRow#" value="#qgetLMAInvoices.balance#">
		                <input type="hidden" name="rembalance_#qgetLMAInvoices.currentRow#" id="rembalance_#qgetLMAInvoices.currentRow#" value="#qgetLMAInvoices.balance#">
		                <input type="hidden" name="LoadID_#qgetLMAInvoices.currentRow#" value="#qgetLMAInvoices.LoadID#">
		                <td class="sky-bg2" valign="middle" align="center">#rowNum + qgetLMAInvoices.currentRow#</td>
		                <td  align="left" valign="middle" nowrap="nowrap" class="normal-td">#DateFormat(qgetLMAInvoices.Date,'mm/dd/yyyy')#</td>
		                <td  align="left" valign="middle" nowrap="nowrap" class="normal-td">#qgetLMAInvoices.typetrans#</td>
		                <td  align="left" valign="middle" nowrap="nowrap" class="normal-td">#qgetLMAInvoices.TRANS_NUMBER#</td>
		                <td  align="right" valign="middle" nowrap="nowrap" class="normal-td">#DollarFormat(qgetLMAInvoices.Total)#</td>
		                <td  align="right" valign="middle" nowrap="nowrap" class="normal-td" id="balance_#qgetLMAInvoices.currentRow#">#DollarFormat(qgetLMAInvoices.Balance)#</td>
		        		<td  align="left" valign="middle" nowrap="nowrap" class="normal-td">#qgetLMAInvoices.Description#</td>
		        		<td  align="left" valign="middle" nowrap="nowrap" class="normal-td"><input value="#DollarFormat(qgetLMAInvoices.Applied)#" class="amtApplied" id="amtApplied_#qgetLMAInvoices.currentRow#" data-amt='#qgetLMAInvoices.Balance#' name="Applied_#qgetLMAInvoices.currentRow#" tabindex="8" onclick="amountApplied(#qgetLMAInvoices.currentRow#,'click')" onchange="amountApplied(#qgetLMAInvoices.currentRow#,'change')" style="text-align: right;"></td>
		        		<td  align="left" valign="middle" nowrap="nowrap" class="normal-td"><input value="#DollarFormat(qgetLMAInvoices.Discount)#" id="discount_#qgetLMAInvoices.currentRow#" name="discount_#qgetLMAInvoices.currentRow#"  tabindex="8" onclick="discountApplied(#qgetLMAInvoices.currentRow#,'click');" onchange="discountApplied(#qgetLMAInvoices.currentRow#,'change');" style="text-align: right;"></td>
		                <td  align="right" valign="middle" nowrap="nowrap" class="normal-td2" id="remaining_#qgetLMAInvoices.currentRow#">#DollarFormat(qgetLMAInvoices.Balance)#</td>
		                <td class="normal-td3">&nbsp;</td>
		            </tr>
		        </cfoutput>
		    <cfelse>
		    	<cfquery name="qget" datasource="#arguments.dsn#">
		    		SELECT CustomerCode FROM Customers WHERE CustomerID = <cfqueryparam value="#arguments.CustomerID#" cfsqltype="cf_sql_varchar">
		    	</cfquery>
				<cfoutput>
					<input type="hidden" name="companycode" value="#qget.CustomerCode#">
					<input type="hidden" name="customerid" value="#arguments.customerid#">
					<tr>
	                    <td height="20" class="sky-bg">&nbsp;</td>
	                    <td colspan="10" align="center" valign="middle" nowrap="nowrap" class="normal-td2">
	                        No Records.
	                    </td>
	                    <td class="normal-td3">&nbsp;</td>
	                </tr>
				</cfoutput>
	        </cfif>
        </cfsavecontent>
        <cfreturn response>
	</cffunction>

	<cffunction name="LMAAccountsReceivablePayment" access="public" returntype="struct">
    	<cfargument name="frmStruct" required="no" type="struct">
    	<cfset local.unusedamt = replaceNoCase(replaceNoCase(arguments.frmStruct.unusedamount,'$',''),',','','ALL')>
    	<cfif len(trim(arguments.frmStruct.checknumber))>
    		<cfset local.checknumber =arguments.frmStruct.checknumber>
    	<cfelse>
    		<cfset local.checknumber = DATETIMEFORMAT(now(),"YYMMddHHNN")>
    	</cfif>
    	<cfset TotalDiscount = 0>
    	<cfset GrandTotal = 0>
    	<cftransaction>
    	<cfif structKeyExists(arguments.frmStruct, "totalcount")>
    	<cfloop from="1" to="#arguments.frmStruct.totalcount#" index="i">
    		<cfif replaceNoCase(replaceNoCase(Evaluate('arguments.frmStruct.Applied_#i#'),'$',''),',','','ALL') NEQ 0>
    			<cfset TotalDiscount =TotalDiscount + replaceNoCase(replaceNoCase(Evaluate('arguments.frmStruct.discount_#i#'),'$',''),',','','ALL')>
    			<cfset GrandTotal = GrandTotal + replaceNoCase(replaceNoCase(Evaluate('arguments.frmStruct.total_#i#'),'$',''),',','','ALL')>
    			<cfset LoadID = replaceNoCase(replaceNoCase(Evaluate('arguments.frmStruct.LoadID_#i#'),'$',''),',','','ALL')>
    			<cfset RemBal = replaceNoCase(replaceNoCase(Evaluate('arguments.frmStruct.rembalance_#i#'),'$',''),',','','ALL')>
		    	<cfquery name="insQuery" datasource="#variables.dsn#">
			    	INSERT INTO [dbo].[LMA Accounts Receivable Payment Detail]
			           ([InvoicNumber]
			           ,[CompanCode]
			           ,[InvoicDate]
			           ,[InvoicAmount]
			           ,[Balance]
			           ,[PurchaOrderNumber]
			           ,[TermCode]
			           ,[TransaType]
			           ,[Depart]
			           ,[Salesp]
			           ,[JobCode]
			           ,[Commis]
			           ,[Applie]
			           ,[Discou]
			           ,[SalesTax1]
			           ,[SalesTaxCode1]
			           ,[CheckNumber]
			           ,[CheckAmount]
			           ,[OpenCreditApplie]
			           ,[Date]
			           ,[CheckDescri]
			           ,[EntereBy]
			           ,[Entered]
			           ,[PaymentNum]
			           ,[Overpayment]
			           ,[CompanyID]
			           ,[CustomerID])
			     	VALUES
			           (<cfqueryparam value="#Evaluate('arguments.frmStruct.invoiceno_#i#')#" cfsqltype="cf_sql_float">
			           ,<cfqueryparam value="#arguments.frmStruct.companycode#" cfsqltype="cf_sql_varchar">
			           ,GETDATE()
			           ,<cfqueryparam value="#replaceNoCase(Evaluate('arguments.frmStruct.total_#i#'),'$','')#" cfsqltype="cf_sql_float">
			           ,<cfqueryparam value="#replaceNoCase(Evaluate('arguments.frmStruct.balance_#i#'),'$','')#" cfsqltype="cf_sql_float">-<cfqueryparam value="#replaceNoCase(replaceNoCase(Evaluate('arguments.frmStruct.Applied_#i#'),'$',''),',','','ALL')#" cfsqltype="cf_sql_float">-<cfqueryparam value="#replaceNoCase(replaceNoCase(Evaluate('arguments.frmStruct.discount_#i#'),'$',''),',','','ALL')#" cfsqltype="cf_sql_float">
			           ,'Invoice'
			           ,9
			           ,'I'
			           ,NULL
			           ,NULL
			           ,NULL
			           ,0
			           ,<cfqueryparam value="#replaceNoCase(replaceNoCase(Evaluate('arguments.frmStruct.Applied_#i#'),'$',''),',','','ALL')#" cfsqltype="cf_sql_float">
			           ,<cfqueryparam value="#replaceNoCase(replaceNoCase(Evaluate('arguments.frmStruct.discount_#i#'),'$',''),',','','ALL')#" cfsqltype="cf_sql_float">
			           ,0
			           ,NULL
			           ,<cfqueryparam value="#local.checknumber#" cfsqltype="cf_sql_varchar">
			           ,<cfqueryparam value="#replaceNoCase(replaceNoCase(arguments.frmStruct.checkamount,'$',''),',','','ALL')#" cfsqltype="cf_sql_float">
			           ,0
			           ,GETDATE()
			           ,<cfqueryparam value="#arguments.frmStruct.Description#" cfsqltype="cf_sql_varchar">
			           ,<cfqueryparam value="#arguments.frmStruct.EnteredBy#" cfsqltype="cf_sql_varchar">
			           ,GETDATE()
			           ,NULL
			           ,0
			           ,<cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar">
			           ,<cfqueryparam value="#arguments.frmStruct.customerid#" cfsqltype="cf_sql_varchar">)
		        </cfquery>
		        <cfquery name="updLMABal" datasource="#variables.dsn#">
		       		UPDATE [LMA Accounts Receivable Transactions] 
			           SET Balance = Balance-<cfqueryparam value="#replaceNoCase(replaceNoCase(Evaluate('arguments.frmStruct.Applied_#i#'),'$',''),',','','ALL')#" cfsqltype="cf_sql_float">-<cfqueryparam value="#replaceNoCase(replaceNoCase(Evaluate('arguments.frmStruct.discount_#i#'),'$',''),',','','ALL')#" cfsqltype="cf_sql_float">,
			           	applied = applied + <cfqueryparam value="#replaceNoCase(replaceNoCase(Evaluate('arguments.frmStruct.Applied_#i#'),'$',''),',','','ALL')#" cfsqltype="cf_sql_float">,
			           	discount = discount + <cfqueryparam value="#replaceNoCase(replaceNoCase(Evaluate('arguments.frmStruct.discount_#i#'),'$',''),',','','ALL')#" cfsqltype="cf_sql_float">

			           WHERE TRANS_NUMBER = <cfqueryparam value="#Evaluate('arguments.frmStruct.invoiceno_#i#')#" cfsqltype="cf_sql_varchar"> AND CompanyID = <cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar">
		    	</cfquery>

		    	<cfquery name="updCustBal" datasource="#variables.dsn#">
		    		UPDATE Customers SET Balance = Balance -<cfqueryparam value="#replaceNoCase(replaceNoCase(Evaluate('arguments.frmStruct.Applied_#i#'),'$',''),',','','ALL')#" cfsqltype="cf_sql_float">-<cfqueryparam value="#replaceNoCase(replaceNoCase(Evaluate('arguments.frmStruct.discount_#i#'),'$',''),',','','ALL')#" cfsqltype="cf_sql_float">
		    		WHERE CustomerID = <cfqueryparam value="#arguments.frmStruct.customerid#" cfsqltype="cf_sql_varchar">
		    	</cfquery>

		    	<cfif len(trim(LoadID)) AND RemBal EQ 0>
		    		<cfquery name="updLoad" datasource="#variables.dsn#">
		    			UPDATE Loads SET CustomerPaid = 1 WHERE LoadID = <cfqueryparam value="#LoadID#" cfsqltype="cf_sql_varchar">
		    		</cfquery>
		    	</cfif>

	        </cfif>
        </cfloop>
    	</cfif>

        <cfquery name="insPaymentQuery" datasource="#variables.dsn#">
	        INSERT INTO [dbo].[LMA Accounts Receivable Transactions]
	           ([LoadID]
	           ,[CustomerID]
	           ,[TRANS_NUMBER]
	           ,[id]
	           ,[date]
	           ,[Total]
	           ,[Balance]
	           ,[description]
	           ,[term_number]
	           ,[typetrans]
	           ,[department]
	           ,[salesperson]
	           ,[commission]
	           ,[applied]
	           ,[discount]
	           ,[sales_tax]
	           ,[Tax Code Number]
	           ,[DiscountTaken]
	           ,[Created]
	           ,[CreatedBy]
	           ,[CommissionPaid]
	           ,[CommissionPaidDate]
	           ,[Notes]
	           ,[CompanyID])
	     	VALUES
	           (NULL
	           ,<cfqueryparam value="#arguments.frmStruct.customerid#" cfsqltype="cf_sql_varchar">
	           ,<cfqueryparam value="#local.checknumber#" cfsqltype="cf_sql_varchar">
	           ,<cfqueryparam value="#arguments.frmStruct.companycode#" cfsqltype="cf_sql_varchar">
	           ,GETDATE()
	           ,<cfqueryparam value="#GrandTotal#" cfsqltype="cf_sql_varchar">
	           ,<cfqueryparam value="#replaceNoCase(replaceNoCase(arguments.frmStruct.TotalRemaining,'$',''),',','','ALL')#" cfsqltype="cf_sql_varchar">
	           ,<cfqueryparam value="#arguments.frmStruct.Description#" cfsqltype="cf_sql_varchar">
	           ,0
	           ,'P'
	           ,NULL
	           ,NULL
	           ,0
	           ,<cfqueryparam value="#replaceNoCase(replaceNoCase(arguments.frmStruct.TotalAppliedPayment,'$',''),',','','ALL')#" cfsqltype="cf_sql_varchar">
	           ,<cfqueryparam value="#TotalDiscount#" cfsqltype="cf_sql_varchar">
	           ,0
	           ,NULL
	           ,0
	           ,GETDATE()
	           ,'#session.adminusername#'
	           ,0
	           ,NULL
	           ,NULL
	           ,<cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar">)
	    </cfquery>
	    <cfif local.unusedamt GT 0 AND arguments.frmstruct.createopencredit>
		    <cfset local.unusedamt = -1*local.unusedamt>
		    <cfquery name="insCreditQuery" datasource="#variables.dsn#">
	        	INSERT INTO [dbo].[LMA Accounts Receivable Transactions]
		           ([CustomerID]
		           ,[TRANS_NUMBER]
		           ,[id]
		           ,[date]
		           ,[Total]
		           ,[Balance]
		           ,[description]
		           ,[term_number]
		           ,[typetrans]
		           ,[commission]
		           ,[applied]
		           ,[discount]
		           ,[sales_tax]
		           ,[DiscountTaken]
		           ,[Created]
		           ,[CreatedBy]
		           ,[CompanyID])
		     	VALUES
		           (<cfqueryparam value="#arguments.frmStruct.customerid#" cfsqltype="cf_sql_varchar">
		           ,(SELECT [Next Invoice Number] FROM [LMA System Config] WHERE CompanyID = <cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar">)
		           ,<cfqueryparam value="#arguments.frmStruct.companycode#" cfsqltype="cf_sql_varchar">
		           ,GETDATE()
		           ,<cfqueryparam value="#local.unusedamt#" cfsqltype="cf_sql_varchar">
		           ,<cfqueryparam value="#local.unusedamt#" cfsqltype="cf_sql_varchar">
		           ,''
		           ,0
		           ,'C'
		           ,0
		           ,0
		           ,0
		           ,0
		           ,0
		           ,GETDATE()
		           ,'#session.adminusername#'
		           ,<cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar">)

		        UPDATE Customers SET Balance = Balance + <cfqueryparam value="#local.unusedamt#" cfsqltype="cf_sql_money">
	            WHERE CustomerID = <cfqueryparam value="#arguments.frmStruct.customerid#" cfsqltype="cf_sql_varchar">

		        INSERT INTO [dbo].[LMA Accounts Receivable Payment Detail]
		           ([InvoicNumber]
		           ,[CompanCode]
		           ,[InvoicDate]
		           ,[InvoicAmount]
		           ,[Balance]
		           ,[PurchaOrderNumber]
		           ,[TermCode]
		           ,[TransaType]
		           ,[Commis]
		           ,[Applie]
		           ,[Discou]
		           ,[SalesTax1]
		           ,[CheckNumber]
		           ,[CheckAmount]
		           ,[OpenCreditApplie]
		           ,[Date]
		           ,[CheckDescri]
		           ,[EntereBy]
		           ,[Entered]
		           ,[Overpayment]
		           ,[CompanyID])
		     	VALUES
		           ((SELECT [Next Invoice Number] FROM [LMA System Config] WHERE CompanyID = <cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar"> )
		           ,<cfqueryparam value="#arguments.frmStruct.companycode#" cfsqltype="cf_sql_varchar">
		           ,GETDATE()
		           ,<cfqueryparam value="#local.unusedamt#" cfsqltype="cf_sql_varchar">
		           ,<cfqueryparam value="#local.unusedamt#" cfsqltype="cf_sql_varchar">
		           ,'Credit Invoice'
		           ,0
		           ,'C'
		           ,0
		           ,0
		           ,0
		           ,0
		           ,<cfqueryparam value="#local.checknumber#" cfsqltype="cf_sql_varchar">
		           ,<cfqueryparam value="#replaceNoCase(replaceNoCase(arguments.frmStruct.checkamount,'$',''),',','','ALL')#" cfsqltype="cf_sql_float">
		           ,0
		           ,GETDATE()
		           ,<cfqueryparam value="#arguments.frmStruct.Description#" cfsqltype="cf_sql_varchar">
		           ,<cfqueryparam value="#arguments.frmStruct.EnteredBy#" cfsqltype="cf_sql_varchar">
		           ,GETDATE()
		           ,0
		           ,<cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar">)
		        UPDATE [LMA System Config] SET [Next Invoice Number] = [Next Invoice Number] + 1
		        WHERE CompanyID = <cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar"> 
			</cfquery>
	    </cfif>
	    <cfset local.post_amt = replaceNoCase(replaceNoCase(arguments.frmStruct.TotalAppliedPayment,'$',''),',','','ALL')>
	    <cfset local.debitTotal = local.post_amt>
	    <cfinvoke method="PostToGL" returnvariable="qPostToGL" account="#form.DepositClearingAccount#" cv_code="#arguments.frmStruct.companycode#" year_past="#form.year_past#" post_amt="#local.post_amt#" Invoice_Code="#local.checknumber#" tran_type="CR" tran_desc="#arguments.frmStruct.Description#" tran_date="#DateFormat(now(),'mm/dd/yyyy')#" module=""/>
	    <cfset local.creditTotal = local.post_amt>
	    <cfset local.post_amt = -1*local.post_amt>
	    <cfinvoke method="PostToGL" returnvariable="qPostToGL" account="#form.ARGLAccount#" cv_code="#arguments.frmStruct.companycode#" year_past="#form.year_past#" post_amt="#local.post_amt#" Invoice_Code="#local.checknumber#" tran_type="CR" tran_desc="#arguments.frmStruct.Description#" tran_date="#DateFormat(now(),'mm/dd/yyyy')#" module=""/>

	    <cfquery name="insLogQuery" datasource="#variables.dsn#">
            INSERT INTO [LMA UpdateLog]
	           ([TableName]
	           ,[RecordID]
	           ,[FieldName]
	           ,[OldValue]
	           ,[NewValue]
	           ,[Status]
	           ,[UpdatedBy]
	           ,[DateUpdated]
	           ,[MachineName]
	           ,[Notes]
	           ,[Created]
	           ,[id]
	           ,[CompanyID])
		    VALUES
	           ('Load Manager'
	           ,'AR'
	           ,'NA'
	           ,'NA'
	           ,'NA'
	           ,'NA'
	           ,<cfqueryparam value="#session.AdminUserName#" cfsqltype="cf_sql_varchar">
	           ,GETDATE()
	           ,'DESKTOP-KNQP4R0'
	           ,'N/A'
	           ,GETDATE()
	           ,(SELECT ISNULL(MAX(ID),0)+1 FROM [LMA UpdateLog])
	           ,<cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar">)
        </cfquery>
        <cfif local.debitTotal NEQ local.creditTotal>
    		<cftransaction action="rollback">
    	</cfif>
        </cftransaction>
    	<cfset respStr = structNew()>
    	<cfset respStr.res = 'success'>
    	<cfset respStr.msg = "Payment have been posted.">
    	<cfreturn respStr>
    </cffunction>

    <cffunction name="getAcctDeptList" access="public" returntype="query">
    	<cfquery name="qGetAcctDeptList" datasource="#variables.dsn#">
    		select GL_ACCT,Description,credit_debit from [LMA General Ledger Chart of Accounts]
    		WHERE CompanyID = <cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar"> 
    	</cfquery>
    	<cfreturn qGetAcctDeptList>
    </cffunction>

    <cffunction name="getLMASystemConfig" access="public" returntype="query">
    	<cfquery name="qgetLMASystemConfig" datasource="#variables.dsn#">
    		select * from [LMA System Config] WHERE CompanyID = <cfqueryparam value="#session.companyid#" cfsqltype="cf_sql_varchar">
    	</cfquery>
    	<cfreturn qgetLMASystemConfig>
    </cffunction>

    <cffunction name="getLMAGeneralLedgerChartofAccounts" access="public" returntype="query">
    	<cfargument name="ID" required="no" type="string">
    	<cfquery name="qGetLMAGeneralLedgerChartofAccounts" datasource="#variables.dsn#">
    		select * from [LMA General Ledger Chart of Accounts]
    		where ID = <cfqueryparam value="#arguments.ID#" cfsqltype="CF_SQL_INTEGER">
    	</cfquery>
    	<cfreturn qGetLMAGeneralLedgerChartofAccounts>
    </cffunction>
    
    <cffunction name="setLMASystemConfig" access="public" returntype="string">
    	<cfargument name="frmstruct" required="no" type="struct">
    	<cfif structKeyExists(arguments.frmstruct, "UseDifferentGLAccountForCommodityTypes")>
			<cfset local.UseDifferentGLAccountForCommodityTypes = 1>
		<cfelse>
			<cfset local.UseDifferentGLAccountForCommodityTypes = 0>
		</cfif>
    	<cfquery name="qsetLMASystemConfig" datasource="#variables.dsn#">
    		<cfif len(trim(arguments.frmstruct.ID))>
	    		UPDATE [LMA System Config] 
	    		SET [AR GL Account] = <cfqueryparam value="#arguments.frmstruct.ARGLAccount#" cfsqltype="cf_sql_varchar">
	    		,[AR Discount GL] = <cfqueryparam value="#arguments.frmstruct.ARDiscountAccount#" cfsqltype="cf_sql_varchar">
	    		,[AR Sales Tax Account] = <cfqueryparam value="#arguments.frmstruct.ARSalesTaxAccount#" cfsqltype="cf_sql_varchar">
	    		,[AR Interest Earned Account] = <cfqueryparam value="#arguments.frmstruct.ARInterestEarnedAccount#" cfsqltype="cf_sql_varchar">
	    		,[Chk_clearing] = <cfqueryparam value="#arguments.frmstruct.DepositClearingAccount#" cfsqltype="cf_sql_varchar">
	    		,[Cust_Deposit_Acct] = <cfqueryparam value="#arguments.frmstruct.CustomerDeposits#" cfsqltype="cf_sql_varchar">
	    		,[Company2] = <cfqueryparam value="#arguments.frmstruct.SalespersonCommisions#" cfsqltype="cf_sql_varchar">
	    		,[Fiscal Year] = <cfqueryparam value="#arguments.frmstruct.FiscalYear#" cfsqltype="cf_sql_date">
	    		,[GL Retain Account] = <cfqueryparam value="#arguments.frmstruct.GLRetainAccount#" cfsqltype="cf_sql_varchar">
				,[PostingWindow] = <cfqueryparam value="#arguments.frmstruct.PostingWindow#" cfsqltype="cf_sql_varchar">
				,[AP GL Account] = <cfqueryparam value="#arguments.frmstruct.APGLAccount#" cfsqltype="cf_sql_varchar">
				,[AP Discount GL] = <cfqueryparam value="#arguments.frmstruct.APDiscountAccount#" cfsqltype="cf_sql_varchar">
				,[Int_Acct] = <cfqueryparam value="#arguments.frmstruct.BankInterestEarned#" cfsqltype="cf_sql_varchar">
				,[Chg_Acct] = <cfqueryparam value="#arguments.frmstruct.BankChargesAccount#" cfsqltype="cf_sql_varchar">
				,[Overshort Acct] = <cfqueryparam value="#arguments.frmstruct.CashOverShortAccount#" cfsqltype="cf_sql_varchar">
				,[AR Sales] = <cfqueryparam value="#arguments.frmstruct.FreightSales#" cfsqltype="cf_sql_varchar">
				,[AR Cost of Sales] = <cfqueryparam value="#arguments.frmstruct.CostOfFreightSales#" cfsqltype="cf_sql_varchar">
				,[UseDifferentGLAccountForCommodityTypes] = <cfqueryparam value="#local.UseDifferentGLAccountForCommodityTypes#" cfsqltype="cf_sql_bit">
				WHERE CompanyID = <cfqueryparam value="#session.companyid#" cfsqltype="cf_sql_varchar">
				AND ID = <cfqueryparam value="#arguments.frmstruct.ID#" cfsqltype="CF_SQL_INTEGER">
			<cfelse>
				INSERT INTO [LMA System Config] ([AR GL Account],[AR Discount GL],[AR Sales Tax Account],[AR Interest Earned Account],[Chk_clearing],[Cust_Deposit_Acct],[Company2],[Fiscal Year],
					[GL Retain Account],[PostingWindow],[AP GL Account],[AP Discount GL],[Int_Acct],[Chg_Acct],[Overshort Acct],[AR Sales] ,[AR Cost of Sales],[UseDifferentGLAccountForCommodityTypes],CompanyID)
					VALUES(
						<cfqueryparam value="#arguments.frmstruct.ARGLAccount#" cfsqltype="cf_sql_varchar">
						,<cfqueryparam value="#arguments.frmstruct.ARDiscountAccount#" cfsqltype="cf_sql_varchar">
						,<cfqueryparam value="#arguments.frmstruct.ARSalesTaxAccount#" cfsqltype="cf_sql_varchar">
						,<cfqueryparam value="#arguments.frmstruct.ARInterestEarnedAccount#" cfsqltype="cf_sql_varchar">
						,<cfqueryparam value="#arguments.frmstruct.DepositClearingAccount#" cfsqltype="cf_sql_varchar">
						,<cfqueryparam value="#arguments.frmstruct.CustomerDeposits#" cfsqltype="cf_sql_varchar">
						,<cfqueryparam value="#arguments.frmstruct.SalespersonCommisions#" cfsqltype="cf_sql_varchar">
						,<cfqueryparam value="#arguments.frmstruct.FiscalYear#" cfsqltype="cf_sql_date">
						,<cfqueryparam value="#arguments.frmstruct.GLRetainAccount#" cfsqltype="cf_sql_varchar">
						,<cfqueryparam value="#arguments.frmstruct.PostingWindow#" cfsqltype="cf_sql_varchar">
						,<cfqueryparam value="#arguments.frmstruct.APGLAccount#" cfsqltype="cf_sql_varchar">
						,<cfqueryparam value="#arguments.frmstruct.APDiscountAccount#" cfsqltype="cf_sql_varchar">
						,<cfqueryparam value="#arguments.frmstruct.BankInterestEarned#" cfsqltype="cf_sql_varchar">
						,<cfqueryparam value="#arguments.frmstruct.BankChargesAccount#" cfsqltype="cf_sql_varchar">
						,<cfqueryparam value="#arguments.frmstruct.CashOverShortAccount#" cfsqltype="cf_sql_varchar">
						,<cfqueryparam value="#arguments.frmstruct.FreightSales#" cfsqltype="cf_sql_varchar">
						,<cfqueryparam value="#arguments.frmstruct.CostOfFreightSales#" cfsqltype="cf_sql_varchar">
						,<cfqueryparam value="#local.UseDifferentGLAccountForCommodityTypes#" cfsqltype="cf_sql_bit">
						,<cfqueryparam value="#session.companyid#" cfsqltype="cf_sql_varchar">
					)
			</cfif>
    	</cfquery>
    	<cfreturn 'Updated successfully.'>
    </cffunction>

    <cffunction name="getPaymentExpiry" access="public" returntype="query">
    	<cfargument name="CompanyID" required="no" type="string">
    	<cfquery name="qPaymentExpiryDays" datasource="#variables.dsn#">
    		SELECT 
				DATEDIFF ( day,getdate(),DATEADD(day, PaymentGracePeriodDays, PaymentFailDate))  AS expiryDays,PaymentFailDate,SubscriptionCancelled,CASE WHEN SubscriptionCancelled = 0 THEN
				(SELECT PaymentDue AS Message FROM  loadmanageradmin.dbo.SystemSetup)
				ELSE
					'Your subscription has been cancelled and your login will expire shortly. To reactivate your subscription please call us at 631-724-9400 and press 4 for customer service.'
				END
			 AS Message
			FROM  systemconfig
			WHERE 
			CompanyID = <cfqueryparam value="#arguments.companyid#" cfsqltype="cf_sql_varchar">
			AND PaymentFailDate != '' AND isnull(PaymentGracePeriodDays,0) > 0
			AND DATEDIFF ( day,getdate(),DATEADD(day, PaymentGracePeriodDays, PaymentFailDate)) <= isnull(PaymentGracePeriodDays,0)
    	</cfquery>
    	<cfreturn qPaymentExpiryDays>
    </cffunction>

    <cffunction name="PostToGL" access="public" returntype="string">
    	<cfargument name="account" required="no" type="string">
     	<cfargument name="cv_code" required="no" type="string">
    	<cfargument name="year_past" required="no" type="string">
    	<cfargument name="post_amt" required="no" type="string">
    	<cfargument name="Invoice_Code" required="no" type="string">
    	<cfargument name="tran_type" required="no" type="string">
    	<cfargument name="tran_desc" required="no" type="string">
    	<cfargument name="tran_date" required="no" type="string">
    	<cfargument name="module" required="no" type="string">
    	<cftransaction>
    		<cfif arguments.post_amt neq 0>
		    	<cfquery name="insQry" datasource="#variables.dsn#">
		    		INSERT INTO [dbo].[LMA General Ledger Transactions]
			           ([GL Account]
			           ,[Date]
			           ,[Code]
			           ,[Invoice Code]
			           ,[Description]
			           ,[D/C]
			           ,[Amount]
			           ,[Damount]
			           ,[Camount]
			           ,[Typetran]
			           ,[EnteredBy]
			           ,[Module]
			           ,[CompanyID])
				     VALUES
			           (<cfqueryparam value="#arguments.account#" cfsqltype="cf_sql_varchar">
			           ,<cfqueryparam value="#arguments.tran_date#" cfsqltype="cf_sql_date">
			           ,<cfqueryparam value="#arguments.cv_code#" cfsqltype="cf_sql_varchar">
			           ,<cfqueryparam value="#arguments.Invoice_Code#" cfsqltype="cf_sql_varchar">
			           ,<cfqueryparam value="#arguments.tran_desc#" cfsqltype="cf_sql_varchar">
			           ,<cfif arguments.post_amt GTE 0>'D'<cfelse>'C'</cfif>
			           ,<cfqueryparam value="#arguments.post_amt#" cfsqltype="cf_sql_float">
			           ,<cfif arguments.post_amt GTE 0>
			           		<cfqueryparam value="#arguments.post_amt#" cfsqltype="cf_sql_float">
			           	<cfelse>
			           		0
			           	</cfif>
			           ,<cfif arguments.post_amt LT 0>
			           		<cfqueryparam value="#arguments.post_amt#" cfsqltype="cf_sql_float">
			           	<cfelse>
			           		0
			           	</cfif>
			           ,<cfqueryparam value="#arguments.tran_type#" cfsqltype="cf_sql_varchar">
			           ,<cfqueryparam value="#session.AdminUserName#" cfsqltype="cf_sql_varchar">
			           ,<cfqueryparam value="#arguments.module#" cfsqltype="cf_sql_varchar">
			           ,<cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar">)  
			    </cfquery>
			    <cfif arguments.year_past EQ 0>
			    	<cfset monthFieldVal = '#dateFormat(arguments.tran_date,'MMM')#_CURRENT'>
			    	<cfset monthFieldValEnd = 'END_CURRENT'>
			    <cfelse>
			    	<cfset monthFieldVal = '#dateFormat(arguments.tran_date,'MMM')#_#year_past#YR'>
			    	<cfset monthFieldValEnd = 'END_#year_past#YR'>
			    </cfif>
			    <cfquery name="updQry" datasource="#variables.dsn#">
			    	UPDATE [LMA General Ledger Chart of Accounts] SET #monthFieldVal# = #monthFieldVal# + <cfqueryparam value="#arguments.post_amt#" cfsqltype="cf_sql_float">
			    	,#monthFieldValEnd# = #monthFieldValEnd# + <cfqueryparam value="#arguments.post_amt#" cfsqltype="cf_sql_float">
			    	where gl_acct = <cfqueryparam value="#arguments.account#" cfsqltype="cf_sql_varchar">
			    	AND CompanyID = <cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar">
			    </cfquery>

			    <cfif arguments.year_past EQ 1 OR arguments.year_past EQ 2>
			    	<cfquery name="qAccType" datasource="#Application.dsn#">
		    			SELECT TYPE_CODE FROM [LMA General Ledger Chart of Accounts] WHERE CompanyID = <cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar"> AND GL_ACCT = <cfqueryparam value="#arguments.account#" cfsqltype="cf_sql_varchar">
		    		</cfquery>

		    		<cfif qAccType.TYPE_CODE EQ 'I' OR  qAccType.TYPE_CODE EQ 'E'>
				    	<cfquery name="qSystemSettings" datasource="#Application.dsn#">
			    			SELECT [GL Retain Account] FROM [LMA System Config] WHERE CompanyID = <cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar">
			    		</cfquery>
			    		<cfset arguments.account = qSystemSettings['GL Retain Account']>
			    	</cfif>

			    	<cfinvoke method="PostToGLRE" returnvariable="retPostToGLRE" account="#arguments.account#" cv_code="#arguments.cv_code#" year_past="#arguments.year_past#" post_amt="#arguments.post_amt#" Invoice_Code="#arguments.Invoice_Code#" tran_type="BB" tran_desc="Beginning Balance" tran_date="#arguments.tran_date#" module=""/>
			    </cfif>
		    </cfif>
	    </cftransaction>
    	<cfreturn 'success'>
    </cffunction>

    <cffunction name="PostToGLRE" access="public" returntype="string">
    	<cfargument name="account" required="no" type="string">
     	<cfargument name="cv_code" required="no" type="string">
    	<cfargument name="year_past" required="no" type="string">
    	<cfargument name="post_amt" required="no" type="string">
    	<cfargument name="Invoice_Code" required="no" type="string">
    	<cfargument name="tran_type" required="no" type="string">
    	<cfargument name="tran_desc" required="no" type="string">
    	<cfargument name="tran_date" required="no" type="string">
    	<cfargument name="module" required="no" type="string" default="">

    	<cftransaction>
    		<cfquery name="updQry" datasource="#variables.dsn#">
    			UPDATE [LMA General Ledger Chart of Accounts] SET
    			<cfif arguments.year_past EQ 2>
    				OPEN_1YR = OPEN_1YR + <cfqueryparam value="#arguments.post_amt#" cfsqltype="cf_sql_float">,
    				END_1YR = END_1YR + <cfqueryparam value="#arguments.post_amt#" cfsqltype="cf_sql_float">,
    			</cfif>
				OPEN_CURRENT = OPEN_CURRENT + <cfqueryparam value="#arguments.post_amt#" cfsqltype="cf_sql_float">,
				END_CURRENT = END_CURRENT + <cfqueryparam value="#arguments.post_amt#" cfsqltype="cf_sql_float">
    			
    			WHERE CompanyID = <cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar">
    			AND GL_ACCT = <cfqueryparam value="#arguments.account#" cfsqltype="cf_sql_varchar">

    			<cfquery name="qSystemSettings" datasource="#Application.dsn#">
	    			SELECT [Fiscal Year] FROM [LMA System Config] WHERE CompanyID = <cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar">
	    		</cfquery>
	    		<cfset local.FiscalYear = qSystemSettings['Fiscal Year']>

    			<cfif arguments.year_past EQ 2>
    				<cfset arguments.tran_date = Dateadd("yyyy",-1,FiscalYear)>
	    			INSERT INTO [dbo].[LMA General Ledger Transactions]
			           ([GL Account]
			           ,[Date]
			           ,[Code]
			           ,[Invoice Code]
			           ,[Description]
			           ,[D/C]
			           ,[Amount]
			           ,[Damount]
			           ,[Camount]
			           ,[Typetran]
			           ,[EnteredBy]
			           ,[Module]
			           ,[CompanyID])
				    VALUES
			           (<cfqueryparam value="#arguments.account#" cfsqltype="cf_sql_varchar">
			           ,<cfqueryparam value="#arguments.tran_date#" cfsqltype="cf_sql_date">
			           ,<cfqueryparam value="#arguments.cv_code#" cfsqltype="cf_sql_varchar">
			           ,<cfqueryparam value="#arguments.Invoice_Code#" cfsqltype="cf_sql_varchar">
			           ,<cfqueryparam value="#arguments.tran_desc#" cfsqltype="cf_sql_varchar">
			           ,<cfif arguments.post_amt GTE 0>'D'<cfelse>'C'</cfif>
			           ,<cfqueryparam value="#arguments.post_amt#" cfsqltype="cf_sql_float">
			           ,<cfif arguments.post_amt GTE 0>
			           		<cfqueryparam value="#arguments.post_amt#" cfsqltype="cf_sql_float">
			           	<cfelse>
			           		0
			           	</cfif>
			           ,<cfif arguments.post_amt LT 0>
			           		<cfqueryparam value="#arguments.post_amt#" cfsqltype="cf_sql_float">
			           	<cfelse>
			           		0
			           	</cfif>
			           	,<cfqueryparam value="#arguments.tran_type#" cfsqltype="cf_sql_varchar">
			           	,<cfqueryparam value="#session.AdminUserName#" cfsqltype="cf_sql_varchar">
			           	,<cfqueryparam value="#arguments.module#" cfsqltype="cf_sql_varchar">
			           	,<cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar">) 
		        </cfif>

		        <cfset arguments.tran_date = FiscalYear>
    			INSERT INTO [dbo].[LMA General Ledger Transactions]
		           ([GL Account]
		           ,[Date]
		           ,[Code]
		           ,[Invoice Code]
		           ,[Description]
		           ,[D/C]
		           ,[Amount]
		           ,[Damount]
		           ,[Camount]
		           ,[Typetran]
		           ,[EnteredBy]
		           ,[Module]
		           ,[CompanyID])
			    VALUES
		           (<cfqueryparam value="#arguments.account#" cfsqltype="cf_sql_varchar">
		           ,<cfqueryparam value="#arguments.tran_date#" cfsqltype="cf_sql_date">
		           ,<cfqueryparam value="#arguments.cv_code#" cfsqltype="cf_sql_varchar">
		           ,<cfqueryparam value="#arguments.Invoice_Code#" cfsqltype="cf_sql_varchar">
		           ,<cfqueryparam value="#arguments.tran_desc#" cfsqltype="cf_sql_varchar">
		           ,<cfif arguments.post_amt GTE 0>'D'<cfelse>'C'</cfif>
		           ,<cfqueryparam value="#arguments.post_amt#" cfsqltype="cf_sql_float">
		           ,<cfif arguments.post_amt GTE 0>
		           		<cfqueryparam value="#arguments.post_amt#" cfsqltype="cf_sql_float">
		           	<cfelse>
		           		0
		           	</cfif>
		           ,<cfif arguments.post_amt LT 0>
		           		<cfqueryparam value="#arguments.post_amt#" cfsqltype="cf_sql_float">
		           	<cfelse>
		           		0
		           	</cfif>
		           	,<cfqueryparam value="#arguments.tran_type#" cfsqltype="cf_sql_varchar">
		           	,<cfqueryparam value="#session.AdminUserName#" cfsqltype="cf_sql_varchar">
		           	,<cfqueryparam value="#arguments.module#" cfsqltype="cf_sql_varchar">
		           	,<cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar">) 
    		</cfquery>
    	</cftransaction>
    </cffunction>
    <cffunction name="getInvoiceCarrierLoads" access="public" returntype="query">
    	<cfargument name="frmStruct" required="no" type="struct">

    	<cfif structKeyExists(arguments.frmStruct, "pageNo")>
    		<cfset local.pageNo = arguments.frmStruct.pageNo>
    	<cfelse>
    		<cfset local.pageNo = 1>
    	</cfif>

    	<cfif structKeyExists(arguments.frmStruct, "sortby")>
    		<cfset local.sortby = arguments.frmStruct.sortby>
    	<cfelse>
    		<cfset local.sortby = "LoadNumber">
    	</cfif>

    	<cfif structKeyExists(arguments.frmStruct, "sortorder")>
    		<cfset local.sortorder = arguments.frmStruct.sortorder>
    	<cfelse>
    		<cfset local.sortorder = "ASC">
    	</cfif>

		<cfquery name="qGetInvoiceLoads" datasource="#variables.dsn#">
			BEGIN WITH page AS( 
				SELECT 
				L.LoadID,
				L.LoadNumber,
				(SELECT LST.StatusText FROM LoadStatusTypes LST WHERE LST.StatusTypeID = L.StatusTypeID) AS StatusText,
				(SELECT LST.StatusDescription FROM LoadStatusTypes LST WHERE LST.StatusTypeID = L.StatusTypeID) AS StatusDescription,
				ISNULL(L.CarrierName,L.LoadDriverName) AS CarrierName,
				L.TotalCarrierCharges,
				L.NewPickupDate,
				L.BillDate,
				L.TotalCustomerCharges,
				ROW_NUMBER() OVER (ORDER BY #local.sortby# #local.sortorder#) AS Row
				FROM Loads L
				WHERE StatusTypeID = (SELECT ARAndAPExportStatusID FROM SystemConfig WHERE CompanyID  = <cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar">)
				AND L.APExported  = 0
				AND ISNULL(L.CarrierName,L.LoadDriverName) IS NOT NULL
				AND L.CustomerID IN (SELECT CustomerID FROM CustomerOffices WHERE OfficeID IN (SELECT OfficeID FROM Offices WHERE CompanyID = <cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar">))
				<cfif Len(Trim(arguments.frmStruct.InvoiceDateFrom)) AND Len(Trim(arguments.frmStruct.InvoiceDateTo))>
					AND ISNULL(L.BillDate,L.NewPickupDate) BETWEEN <cfqueryparam value="#Trim(arguments.frmStruct.InvoiceDateFrom)#" cfsqltype="cf_sql_date">
						AND <cfqueryparam value="#Trim(arguments.frmStruct.InvoiceDateTO)#" cfsqltype="cf_sql_date">
				</cfif>
				)
				SELECT *,(select (max(row)/30) + (CASE WHEN max(row)%30 <> 0 THEN 1 ELSE 0 END)  FROM page) AS TotalPages  FROM page
		    	WHERE Row BETWEEN (#local.pageNo# - 1) * 30 + 1 AND #local.pageNo# * 30
	    	END
		</cfquery>
	    <cfreturn qGetInvoiceLoads>
	</cffunction>

	<cffunction name="getAPInvoiceCustomerCarrierTotals" access="public" returntype="query">
		<cfquery name="qGetARInvoiceCustomerCarrierTotals" datasource="#variables.dsn#">
			SELECT L.LoadID,L.TotalCustomerCharges,L.TotalCarrierCharges 
			FROM Loads L
			WHERE StatusTypeID = (SELECT ARAndAPExportStatusID FROM SystemConfig WHERE CompanyID  = <cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar">)
			AND L.APExported  = 0
			AND ISNULL(L.CarrierName,L.LoadDriverName) IS NOT NULL
			AND L.CustomerID IN (SELECT CustomerID FROM CustomerOffices WHERE OfficeID IN (SELECT OfficeID FROM Offices WHERE CompanyID = <cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar">))
			<cfif Len(Trim(arguments.frmStruct.InvoiceDateFrom)) AND Len(Trim(arguments.frmStruct.InvoiceDateTo))>
				AND (L.BillDate BETWEEN <cfqueryparam value="#Trim(arguments.frmStruct.InvoiceDateFrom)#" cfsqltype="cf_sql_date">
					AND <cfqueryparam value="#Trim(arguments.frmStruct.InvoiceDateTO)#" cfsqltype="cf_sql_date">
					OR L.NewPickupDate BETWEEN <cfqueryparam value="#Trim(arguments.frmStruct.InvoiceDateFrom)#" cfsqltype="cf_sql_date">
					AND <cfqueryparam value="#Trim(arguments.frmStruct.InvoiceDateTO)#" cfsqltype="cf_sql_date">
					)
			</cfif>
		</cfquery>
		<cfreturn qGetARInvoiceCustomerCarrierTotals>
	</cffunction>

	<cffunction name="InvoiceCarrierLoads" access="public" returntype="struct" returnformat="json">
    	<cfargument name="frmStruct" required="no" type="struct">
    	<cftransaction>
    	<cfquery name="qGetInvoiceLoads" datasource="#variables.dsn#">
    		SELECT 
			L.LoadID,
			L.LoadNumber,
			(SELECT LST.StatusText FROM LoadStatusTypes LST WHERE LST.StatusTypeID = L.StatusTypeID) AS StatusText,
			L.CustName,
			ISNULL(L.CarrierName,L.LoadDriverName) AS CarrierName,
			L.TotalCarrierCharges,
			L.NewPickupDate,
			L.BillDate,
			L.TotalCustomerCharges,
			L.CustomerID,
			(SELECT VendorID FROM Carriers WHERE CarrierID = L.CarrierID) AS VendorID,
			L.CustomerPONo,
			L.CarrierID
			FROM Loads L
			WHERE StatusTypeID = (SELECT ARAndAPExportStatusID FROM SystemConfig WHERE CompanyID  = <cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar">)
			AND L.APExported  = 0
			AND ISNULL(L.CarrierName,L.LoadDriverName) IS NOT NULL
			AND L.CustomerID IN (SELECT CustomerID FROM CustomerOffices WHERE OfficeID IN (SELECT OfficeID FROM Offices WHERE CompanyID = <cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar">))
			<cfif Len(Trim(arguments.frmStruct.InvoiceDateFrom)) AND Len(Trim(arguments.frmStruct.InvoiceDateTo))>
				AND (L.BillDate BETWEEN <cfqueryparam value="#Trim(arguments.frmStruct.InvoiceDateFrom)#" cfsqltype="cf_sql_date">
					AND <cfqueryparam value="#Trim(arguments.frmStruct.InvoiceDateTO)#" cfsqltype="cf_sql_date">
					OR L.NewPickupDate BETWEEN <cfqueryparam value="#Trim(arguments.frmStruct.InvoiceDateFrom)#" cfsqltype="cf_sql_date">
					AND <cfqueryparam value="#Trim(arguments.frmStruct.InvoiceDateTO)#" cfsqltype="cf_sql_date">
					)
			</cfif>
			<cfif structKeyExists(arguments.frmStruct, "ExcludeLoads") AND Len(Trim(arguments.frmStruct.ExcludeLoads))>
				AND L.LoadID NOT IN (<cfqueryparam list="true" value="#arguments.frmStruct.ExcludeLoads#">)
			</cfif>
    	</cfquery>
    	<cfloop query="qGetInvoiceLoads">
    		<cfset local.LoadID = qGetInvoiceLoads.LoadID>
    		<cfset local.LoadNumber = qGetInvoiceLoads.LoadNumber>
    		<cfset local.VendorCode = qGetInvoiceLoads.VendorID>
    		<cfset local.CarrierID = qGetInvoiceLoads.CarrierID>
    		<cfset local.Total = qGetInvoiceLoads.TotalCarrierCharges>
    		<cfset local.Balance = qGetInvoiceLoads.TotalCarrierCharges>
			<cfset local.description = qGetInvoiceLoads.CarrierName>
			<cfif len(trim(qGetInvoiceLoads.BillDate))>
				<cfset local.InvoiceDate = qGetInvoiceLoads.BillDate>
			<cfelse>
				<cfset local.InvoiceDate = qGetInvoiceLoads.NewPickupDate>
			</cfif>

			<cfif NOT len(trim(local.InvoiceDate))>
				<cfset respStr = structNew()>
		    	<cfset respStr.res = 'error'>
		    	<cfset respStr.msg = "Invalid Invoice Date For Load###local.LoadNumber#.">
		    	<cfreturn respStr>
			</cfif>
				
			<cfinvoke method="check_fiscal" Trans_Date="#local.InvoiceDate#" returnvariable="resCkFiscal" />
			<cfif resCkFiscal.res eq 'error'>
				<cftransaction action="rollback">
		    	<cfreturn resCkFiscal>
		    <cfelse>
		    	<cfset form.year_past = resCkFiscal.year_past>
        	</cfif>
   			<cfquery name="insQuery" datasource="#variables.dsn#">
   				INSERT INTO [dbo].[LMA Accounts Payable Transactions]
		           	([TRANS_NUMBER]
		           	,[VendorID]
		           	,[date]
		           	,[inv_number]
		           	,[total]
		           	,[balance]
		           	,[description]
		           	,[term_number]
		           	,[typetrans]
		           	,[commission]
		           	,[applied]
		           	,[discount]
		           	,[HandApplied]
		           	,[HandDiscount]
		           	,[DueDate]
		           	,[Importance]
		           	,[EntryDate]
		           	,[EnteredBy]
		           	,[AmtApplied]
		           	,[ChainCredit]
		           	,[CompanyID]
		           	,[CarrierID])
		     	VALUES
		           	(<cfqueryparam value="#Local.LoadNumber#" cfsqltype="cf_sql_varchar">
		           	,<cfqueryparam value="#Local.VendorCode#" cfsqltype="cf_sql_varchar">
		           	,<cfqueryparam value="#Local.InvoiceDate#" cfsqltype="cf_sql_date">
		           	,0
		           	,<cfqueryparam value="#Local.Total#" cfsqltype="cf_sql_money">
	           		,<cfqueryparam value="#Local.Balance#" cfsqltype="cf_sql_money">
	           		,<cfqueryparam value="#Local.description#" cfsqltype="cf_sql_varchar">
		           ,11
		           ,'I'
		           ,0
		           ,0
		           ,0
		           ,0
		           ,0
		           ,GETDATE()
		           ,0
		           ,GETDATE()
		           ,<cfqueryparam value="#session.adminusername#" cfsqltype="cf_sql_varchar">
		           ,0
		           ,0
		           ,<cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar">
		           ,<cfqueryparam value="#Local.CarrierID#" cfsqltype="cf_sql_varchar">
		           )

		        UPDATE Carriers SET Balance = Balance + <cfqueryparam value="#Local.Balance#" cfsqltype="cf_sql_money">
	            WHERE CarrierID = <cfqueryparam value="#Local.CarrierID#" cfsqltype="cf_sql_varchar">

	            INSERT INTO [LMA UpdateLog]
			           ([TableName]
			           ,[RecordID]
			           ,[FieldName]
			           ,[OldValue]
			           ,[NewValue]
			           ,[Status]
			           ,[UpdatedBy]
			           ,[DateUpdated]
			           ,[MachineName]
			           ,[Notes]
			           ,[Created]
			           ,[id]
			           ,[CompanyID])
			    VALUES
			           ('Load Manager'
			           ,'AP'
			           ,'NA'
			           ,'NA'
			           ,'NA'
			           ,'NA'
			           ,<cfqueryparam value="#session.AdminUserName#" cfsqltype="cf_sql_varchar">
			           ,GETDATE()
			           ,'DESKTOP-KNQP4R0'
			           ,'N/A'
			           ,GETDATE()
			           ,(SELECT ISNULL(MAX(ID),0)+1 FROM [LMA UpdateLog])
			           ,<cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar">)

			    UPDATE Loads SET APExported = 1 WHERE LoadID = <cfqueryparam value="#Local.LoadID#" cfsqltype="cf_sql_varchar">

   			</cfquery>
   			<cfif listfind('0,1,2',arguments.frmStruct.year_past)>

   				<cfquery name="qGetLoadPostDetails"  datasource="#variables.dsn#">
	   				SELECT L.CarrFlatRate,L.carrierMilesCharges,LSC.CarrCharges,U.GLExpenseAccount,U.GLBankAccount,ISNULL(U.PaymentAdvance,0) AS PaymentAdvance,LSC.Description 
	   				FROM Loads L
					INNER JOIN LoadStops LS ON LS.LoadID = L.LoadID 
					INNER JOIN LoadStopCommodities LSC ON LSC.LoadStopID = LS.LoadStopID
					LEFT JOIN Units U ON U.UnitID = LSC.UnitID
					WHERE L.LoadID = <cfqueryparam value="#Local.LoadID#" cfsqltype="cf_sql_varchar">
	   			</cfquery>
	   			<cfset local.post_amt = 0>

	   			<cfif len(trim(qGetLoadPostDetails.CarrFlatRate))>
	   				<cfset local.post_amt = local.post_amt+qGetLoadPostDetails.CarrFlatRate>
	   			</cfif>

	   			<cfif len(trim(qGetLoadPostDetails.carrierMilesCharges))>
	   				<cfset local.post_amt = local.post_amt+qGetLoadPostDetails.carrierMilesCharges>
	   			</cfif>

	   			<cfloop query="qGetLoadPostDetails">
					<cfif not len(trim(qGetLoadPostDetails.GLBankAccount))>
						<cfset local.post_amt = local.post_amt+qGetLoadPostDetails.CarrCharges>
					</cfif>
				</cfloop>

	   			<cfinvoke method="PostToGL" returnvariable="qPostToGL" account="#arguments.frmStruct.CostOfFreightSales#" cv_code="#local.VendorCode#" year_past="#arguments.frmStruct.year_past#" post_amt="#local.post_amt#" Invoice_Code="#local.loadnumber#" tran_type="RP" tran_desc="Flat Rate" tran_date="#DateFormat(now(),'mm/dd/yyyy')#" module=""/>

	   			<cfset local.post_amt = 0>

	   			<cfif len(trim(qGetLoadPostDetails.CarrFlatRate))>
	   				<cfset local.post_amt = local.post_amt+qGetLoadPostDetails.CarrFlatRate>
	   			</cfif>

	   			<cfif len(trim(qGetLoadPostDetails.carrierMilesCharges))>
	   				<cfset local.post_amt = local.post_amt+qGetLoadPostDetails.carrierMilesCharges>
	   			</cfif>

	   			<cfloop query="qGetLoadPostDetails">
					<cfif not len(trim(qGetLoadPostDetails.GLBankAccount))>
						<cfset local.post_amt = local.post_amt+qGetLoadPostDetails.CarrCharges>
					</cfif>
				</cfloop>

				<cfset local.post_amt = -1*local.post_amt>

				<cfinvoke method="PostToGL" returnvariable="qPostToGL" account="#arguments.frmStruct.APGLAccount#" cv_code="#local.VendorCode#" year_past="#arguments.frmStruct.year_past#" post_amt="#local.post_amt#" Invoice_Code="#local.loadnumber#" tran_type="RP" tran_desc="Flat Rate" tran_date="#DateFormat(now(),'mm/dd/yyyy')#" module=""/>

	   			<cfloop query="qGetLoadPostDetails">
					<cfif qGetLoadPostDetails.PaymentAdvance>
						<cfif len(trim(qGetLoadPostDetails.GLBankAccount))>
							<cfset local.post_amt = qGetLoadPostDetails.CarrCharges>
							<cfset local.post_acct = qGetLoadPostDetails.GLBankAccount>
							<cfset local.tran_desc = qGetLoadPostDetails.Description>
							<cfinvoke method="PostToGL" returnvariable="qPostToGL" account="#arguments.frmStruct.APGLAccount#" cv_code="#local.VendorCode#" year_past="#arguments.frmStruct.year_past#" post_amt="#local.post_amt#" Invoice_Code="#local.loadnumber#" tran_type="RP"  tran_desc="#local.tran_desc#" tran_date="#DateFormat(now(),'mm/dd/yyyy')#" module=""/>
							<cfset local.post_amt = -1*qGetLoadPostDetails.CarrCharges>
							<cfinvoke method="PostToGL" returnvariable="qPostToGL" account="#local.post_acct#" cv_code="#local.VendorCode#" year_past="#arguments.frmStruct.year_past#" post_amt="#local.post_amt#" Invoice_Code="#local.loadnumber#" tran_type="RP"  tran_desc="#local.tran_desc#" tran_date="#DateFormat(now(),'mm/dd/yyyy')#" module=""/>
						</cfif>
					<cfelse>
						<cfif len(trim(qGetLoadPostDetails.GLExpenseAccount))>
							<cfset local.post_amt = qGetLoadPostDetails.CarrCharges>
							<cfset local.post_acct = qGetLoadPostDetails.GLExpenseAccount>
							<cfset local.tran_desc = qGetLoadPostDetails.Description>

							<cfinvoke method="PostToGL" returnvariable="qPostToGL" account="#local.post_acct#" cv_code="#local.VendorCode#" year_past="#arguments.frmStruct.year_past#" post_amt="#local.post_amt#" Invoice_Code="#local.loadnumber#" tran_type="RP"  tran_desc="#local.tran_desc#" tran_date="#DateFormat(now(),'mm/dd/yyyy')#" module=""/>
						</cfif>
					</cfif>
				</cfloop>


   			</cfif>
    	</cfloop>
    	</cftransaction>
    	<cfset respStr = structNew()>
    	<cfset respStr.res = 'success'>
    	<cfset respStr.msg = "Invoice(s) created successfully.">
    	<cfreturn respStr>
    </cffunction>

    <cffunction name="generateLMAInvoiceNumber" access="remote" returntype="string" returnFormat="plain">
    	<cfargument name="dsn" required="yes" type="string">
    	<cfargument name="companyid" required="yes" type="string">
    	<cfquery name="qgenerateLMAInvoiceNumber" datasource="#arguments.dsn#">
    		SELECT [Next Invoice Number] AS InvoiceNumber FROM [LMA System Config] WHERE CompanyID = <cfqueryparam value="#arguments.CompanyID#" cfsqltype="cf_sql_varchar">
    		UPDATE [LMA System Config] SET [Next Invoice Number] = [Next Invoice Number] + 1 WHERE CompanyID = <cfqueryparam value="#arguments.CompanyID#" cfsqltype="cf_sql_varchar">
    	</cfquery>
    	<cfreturn qgenerateLMAInvoiceNumber.InvoiceNumber>
    </cffunction>

    <cffunction name="LMACreateCustomerInvoice" access="public" returntype="struct" returnformat="json">
    	<cfargument name="frmStruct" required="no" type="struct">
		<cfset local.totalAmount = replaceNoCase(replaceNoCase(arguments.frmStruct.totalAmount,'$',''),',','','ALL')>
		<cfif arguments.frmstruct.type EQ 'I'>
			<cfset local.transdesc = 'Invoice'>
		<cfelseif arguments.frmstruct.type EQ 'P'>
			<cfset local.transdesc = 'Payment - Thank You'>
		<cfelse>
			<cfset local.transdesc = 'Credit Invoice'>
			<cfset local.totalAmount = local.totalAmount * -1>
		</cfif>
		<cftransaction>
    	<cfquery name="insQuery" datasource="#variables.dsn#">
    		INSERT INTO [dbo].[LMA Accounts Receivable Transactions]
				([CustomerID]
				,[TRANS_NUMBER]
				,[id]
				,[date]
				,[Total]
				,[Balance]
				,[description]
				,[term_number]
				,[typetrans]
				,[department]
				,[salesperson]
				,[commission]
				,[applied]
				,[discount]
				,[sales_tax]
				,[DiscountTaken]
				,[Created]
				,[CreatedBy]
				,[CommissionPaid]
				,[Notes]
				,[CompanyID])
		    VALUES
				(<cfqueryparam value="#arguments.frmstruct.customerID#" cfsqltype="cf_sql_varchar">
				,<cfqueryparam value="#arguments.frmstruct.invoice#" cfsqltype="cf_sql_varchar">
				,<cfqueryparam value="#arguments.frmstruct.customercode#" cfsqltype="cf_sql_varchar">
				,<cfqueryparam value="#arguments.frmstruct.invoiceDate#" cfsqltype="cf_sql_varchar">
				,<cfqueryparam value="#local.totalAmount#" cfsqltype="cf_sql_money">
				,<cfqueryparam value="#local.totalAmount#" cfsqltype="cf_sql_money">
				,<cfqueryparam value="#local.transdesc#" cfsqltype="cf_sql_varchar">
				,<cfqueryparam value="#arguments.frmstruct.term_number#" cfsqltype="cf_sql_varchar">
				,<cfqueryparam value="#arguments.frmstruct.type#" cfsqltype="cf_sql_varchar">
				,<cfqueryparam value="#arguments.frmstruct.dept#" cfsqltype="cf_sql_varchar">
				,<cfqueryparam value="WEB" cfsqltype="cf_sql_varchar">
				,0
				,0
				,0
				,0

				,0
				,getdate()
				,<cfqueryparam value="#session.adminusername#" cfsqltype="cf_sql_varchar">
				,0
				,<cfqueryparam value="#arguments.frmstruct.notes#" cfsqltype="cf_sql_varchar">
				,<cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar">)

			UPDATE Customers SET Balance = Balance + <cfqueryparam value="#Local.totalAmount#" cfsqltype="cf_sql_money">
	            WHERE CustomerID = <cfqueryparam value="#arguments.frmstruct.customerID#" cfsqltype="cf_sql_varchar">

			INSERT INTO [dbo].[LMA Accounts Receivable Invoice Header History]
				([Code]
				,[Invoice Number]
				,[Invoice Date]
				,[Description]
				,[Check Register Number]
				,[Terms Description]
				,[Terms Number]
				,[Type Number]
				,[Type Description]
				,[Total Amount]
				,[Department]
				,[Check_Num]
				,[Check_account_num]
				,[Notes]
				,[Salesperson]
				,[CompanyID])
			VALUES
				(<cfqueryparam value="#arguments.frmstruct.customercode#" cfsqltype="cf_sql_varchar">
				,<cfqueryparam value="#arguments.frmstruct.invoice#" cfsqltype="cf_sql_varchar">
				,GETDATE()
				,<cfqueryparam value="#arguments.frmstruct.CompanyName#" cfsqltype="cf_sql_varchar">
				,0
				,'Credit Card'
				,0
				,0
				,<cfqueryparam value="#local.transdesc#" cfsqltype="cf_sql_varchar">
				,<cfqueryparam value="#replaceNoCase(replaceNoCase(arguments.frmStruct.totalAmount,'$',''),',','','ALL')#" cfsqltype="cf_sql_money">
				,<cfqueryparam value="#arguments.frmstruct.dept#" cfsqltype="cf_sql_varchar">
				,0
				,0
				,<cfqueryparam value="#arguments.frmstruct.notes#" cfsqltype="cf_sql_varchar">
				,<cfqueryparam value="WEB" cfsqltype="cf_sql_varchar">
				,<cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar">
				)

				INSERT INTO [LMA UpdateLog]
					([TableName]
					,[RecordID]
					,[FieldName]
					,[OldValue]
					,[NewValue]
					,[Status]
					,[UpdatedBy]
					,[DateUpdated]
					,[MachineName]
					,[Notes]
					,[Created]
					,[id]
					,[CompanyID])
			    VALUES
					('Load Manager'
					,'AR'
					,'NA'
					,'NA'
					,'NA'
					,'NA'
					,<cfqueryparam value="#session.AdminUserName#" cfsqltype="cf_sql_varchar">
					,GETDATE()
					,'DESKTOP-KNQP4R0'
					,'N/A'
					,GETDATE()
					,(SELECT ISNULL(MAX(ID),0)+1 FROM [LMA UpdateLog])
					,<cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar">)
    	</cfquery>
    	
		<cfset local.intPostedAmount = 0>

    	<cfloop from="1" to="10" step="1" index="i">
			<cfset local.GL_ACCT = Evaluate('arguments.frmStruct.glacct_#i#')>
    		<cfif len(trim(local.GL_ACCT))>
    			<cfset local.creditdebit = Evaluate('arguments.frmStruct.creditdebit_#i#')>
    			<cfset local.Description = Evaluate('arguments.frmStruct.description_#i#')>
    			<cfset local.Amount = Evaluate('arguments.frmStruct.amount_#i#')>
    			<cfif local.creditdebit EQ 'D'>
    				<cfset local.intPostedAmount = local.intPostedAmount + replaceNoCase(replaceNoCase(local.Amount,'$',''),',','','ALL')>
    			<cfelse>
    				<cfset local.intPostedAmount = local.intPostedAmount + (replaceNoCase(replaceNoCase(local.Amount,'$',''),',','','ALL')*-1)>
    			</cfif>
    			<cfquery name="insQuery" datasource="#variables.dsn#">
    				INSERT INTO [dbo].[LMA Accounts Receivable Invoice Footer History]
						([Customer Code]
						,[Trans Number]
						,[GL Account]
						,[D/C]
						,[GL Description]
						,[Amount]
						,[companyid])
				    VALUES
						(<cfqueryparam value="#arguments.frmstruct.customercode#" cfsqltype="cf_sql_varchar">
						,<cfqueryparam value="#arguments.frmstruct.invoice#" cfsqltype="cf_sql_varchar">
						,<cfqueryparam value="#local.GL_ACCT#" cfsqltype="cf_sql_varchar">
						,<cfqueryparam value="#local.creditdebit#" cfsqltype="cf_sql_varchar">
						,<cfqueryparam value="#local.Description#" cfsqltype="cf_sql_varchar">
						,<cfqueryparam value="#replaceNoCase(replaceNoCase(local.Amount,'$',''),',','','ALL')#" cfsqltype="cf_sql_money">
						,<cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar">)
    			</cfquery>
    			<cfif listfind('0,1,2',arguments.frmStruct.year_past)>
    				<cfset local.total = replaceNoCase(replaceNoCase(local.Amount,'$',''),',','','ALL')>
    				<cfif local.creditdebit EQ 'C' AND local.total GT 0>
    					<cfset local.total = -1 * local.total>
    				</cfif>
    				<cfinvoke method="PostToGL" returnvariable="qPostToGL" account="#local.GL_ACCT#" cv_code="#arguments.frmstruct.customercode#" year_past="#arguments.frmStruct.year_past#" post_amt="#local.total#" Invoice_Code="#arguments.frmstruct.invoice#" tran_type="RS" tran_desc="#local.Description#" tran_date="#arguments.frmstruct.invoiceDate#" module=""/>
    			</cfif>
    		</cfif>
    	</cfloop>
    	<cfif listFindNoCase("I,C", arguments.frmstruct.type)>
    		<cfset local.GL_ACCT = arguments.frmstruct.ARGLAccount>
			<cfif arguments.frmstruct.type EQ 'I'>
				<cfset local.creditdebit = 'D'>
			<cfelse>
				<cfset local.creditdebit = 'C'>
			</cfif>
			<cfquery name="qGet" datasource="#variables.dsn#">
				select description from [LMA General Ledger Chart of Accounts] where GL_ACCT = <cfqueryparam value="#local.GL_ACCT#" cfsqltype="cf_sql_varchar"> AND CompanyID = <cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar">
			</cfquery>
			<cfset local.Description = qGet.description>
			<cfset local.Amount = arguments.frmStruct.totalAmount>
			<cfif local.creditdebit EQ 'D'>
				<cfset local.intPostedAmount = local.intPostedAmount + replaceNoCase(replaceNoCase(local.Amount,'$',''),',','','ALL')>
			<cfelse>
				<cfset local.intPostedAmount = local.intPostedAmount + (replaceNoCase(replaceNoCase(local.Amount,'$',''),',','','ALL')*-1)>
			</cfif>
			<cfquery name="insQuery" datasource="#variables.dsn#">
				INSERT INTO [dbo].[LMA Accounts Receivable Invoice Footer History]
					([Customer Code]
					,[Trans Number]
					,[GL Account]
					,[D/C]
					,[GL Description]
					,[Amount]
					,[companyid])
			    VALUES
					(<cfqueryparam value="#arguments.frmstruct.customercode#" cfsqltype="cf_sql_varchar">
					,<cfqueryparam value="#arguments.frmstruct.invoice#" cfsqltype="cf_sql_varchar">
					,<cfqueryparam value="#local.GL_ACCT#" cfsqltype="cf_sql_varchar">
					,<cfqueryparam value="#local.creditdebit#" cfsqltype="cf_sql_varchar">
					,<cfqueryparam value="#local.Description#" cfsqltype="cf_sql_varchar">
					,<cfqueryparam value="#replaceNoCase(replaceNoCase(local.Amount,'$',''),',','','ALL')#" cfsqltype="cf_sql_money">
					,<cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar">)
			</cfquery>
			<cfif listfind('0,1,2',arguments.frmStruct.year_past)>
				<cfset local.total = replaceNoCase(replaceNoCase(local.Amount,'$',''),',','','ALL')>
				<cfif local.creditdebit EQ 'C' AND local.total GT 0>
					<cfset local.total = -1 * local.total>
				</cfif>
				<cfinvoke method="PostToGL" returnvariable="qPostToGL" account="#local.GL_ACCT#" cv_code="#arguments.frmstruct.customercode#" year_past="#arguments.frmStruct.year_past#" post_amt="#local.total#" Invoice_Code="#arguments.frmstruct.invoice#" tran_type="RS" tran_desc="#local.Description#" tran_date="#arguments.frmstruct.invoiceDate#" module=""/>
			</cfif>
		</cfif>
    	<cfif local.intPostedAmount NEQ 0>
			<cftransaction action="rollback">
			<cfset respStr = structNew()>
	    	<cfset respStr.res = 'error'>
	    	<cfset respStr.msg = "This transaction is out of balance by #DollarFormat(local.intPostedAmount)#. Please fix this and try again.">
	    	<cfset respStr.frmstruct = arguments.frmstruct>
	    	<cfreturn respStr>
		</cfif>
    	</cftransaction>
    	<cfset respStr = structNew()>
    	<cfset respStr.res = 'success'>
    	<cfset respStr.msg = "Invoice(s) created successfully.">
    	<cfreturn respStr>
    </cffunction>

    <cffunction name="getLMASystemTerms" access="public" returntype="query">
    	<cfquery name="qSystemTerms" datasource="#variables.dsn#">
    		select ID,Description from [LMA System Terms] WHERE CompanyID = <cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar">
    	</cfquery>
    	<cfreturn qSystemTerms>
    </cffunction>

    <cffunction name="LMACreateVendorInvoice" access="public"  returntype="struct" returnformat="json">
    	<cfargument name="frmStruct" required="no" type="struct">

    	<cfset local.totalAmount = replaceNoCase(replaceNoCase(arguments.frmStruct.totalAmount,'$',''),',','','ALL')>
		<cfif arguments.frmstruct.type EQ 'I'>
			<cfset local.transdesc = 'Invoice'>
		<cfelseif arguments.frmstruct.type EQ 'P'>
			<cfset local.transdesc = 'Payment - Thank You'>
		<cfelse>
			<cfset local.transdesc = 'Credit Invoice'>
			<cfset local.totalAmount = local.totalAmount * -1>
		</cfif>
		<cftransaction>
    	<cfquery name="insQuery" datasource="#variables.dsn#">
	    	INSERT INTO [dbo].[LMA Accounts Payable Transactions]
	           ([TRANS_NUMBER]
	           ,[VendorID]
	           ,[date]
	           ,[inv_number]
	           ,[total]
	           ,[balance]
	           ,[description]
	           ,[term_number]
	           ,[typetrans]
	           ,[commission]
	           ,[applied]
	           ,[discount]
	           ,[HandApplied]
	           ,[HandDiscount]
	           ,[DueDate]
	           ,[Reference]
	           ,[Importance]
	           ,[EntryDate]
	           ,[EnteredBy]
	           ,[AmtApplied]
	           ,[Notes]
	           ,[ChainCredit]
	           ,[CompanyID]
	           ,[CarrierID])
	    	VALUES
	           (<cfqueryparam value="#arguments.frmstruct.invoice#" cfsqltype="cf_sql_varchar">
	           ,<cfqueryparam value="#arguments.frmstruct.vendorIDContainer#" cfsqltype="cf_sql_varchar">
	           ,<cfqueryparam value="#arguments.frmstruct.invoiceDate#" cfsqltype="cf_sql_date">
	           ,0
	           ,<cfqueryparam value="#local.totalAmount#" cfsqltype="cf_sql_money">
			   ,<cfqueryparam value="#local.totalAmount#" cfsqltype="cf_sql_money">
	           ,<cfqueryparam value="#arguments.frmstruct.CompanyName#" cfsqltype="cf_sql_varchar">
	           ,<cfqueryparam value="#arguments.frmstruct.term_number#" cfsqltype="cf_sql_integer">
	           ,<cfqueryparam value="#arguments.frmstruct.type#" cfsqltype="cf_sql_varchar">
	           ,0
	           ,0
	           ,0
	           ,0
	           ,0
	           ,<cfqueryparam value="#arguments.frmstruct.dueDate#" cfsqltype="cf_sql_date">
	           ,<cfqueryparam value="#arguments.frmstruct.Reference#" cfsqltype="cf_sql_varchar">
	           <cfif len(trim(arguments.frmstruct.importance))>
	           	,<cfqueryparam value="#arguments.frmstruct.importance#" cfsqltype="cf_sql_float">
	           <cfelse>
	           	,0
	           </cfif>
	           ,GETDATE()
	           ,<cfqueryparam value="#session.AdminUserName#" cfsqltype="cf_sql_varchar">
	           ,0
	           ,<cfqueryparam value="#arguments.frmstruct.notes#" cfsqltype="cf_sql_varchar">
	           ,0
	           ,<cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar">
	           ,<cfqueryparam value="#arguments.frmstruct.carrierid#" cfsqltype="cf_sql_varchar">)

	        UPDATE Carriers SET Balance = Balance + <cfqueryparam value="#Local.totalAmount#" cfsqltype="cf_sql_money">
	            WHERE carrierid = <cfqueryparam value="#arguments.frmstruct.carrierid#" cfsqltype="cf_sql_varchar">

	        INSERT INTO [dbo].[LMA Accounts Payable Invoice Header History]
				([Code]
				,[Invoice Number]
				,[Invoice Date]
				,[Description]
				,[Check Register Number]
				,[Terms Description]
				,[Terms Number]
				,[Type Number]
				,[Type Description]
				,[Total Amount]
				,[Check_Num]
				,[Check_Account_Num]
				,[Purchase Order Number]
				,[EnteredBy]
				,[OriginalAmount]
				,[DueDate]
				,[Reference]
				,[Importance]
				,[EntryDate]
				,[Notes]
				,[CompanyID])
		    VALUES
				(<cfqueryparam value="#arguments.frmstruct.vendorIDContainer#" cfsqltype="cf_sql_varchar">
				,<cfqueryparam value="#arguments.frmstruct.invoice#" cfsqltype="cf_sql_varchar">
				,<cfqueryparam value="#arguments.frmstruct.invoiceDate#" cfsqltype="cf_sql_date">
				,<cfqueryparam value="#arguments.frmstruct.CompanyName#" cfsqltype="cf_sql_varchar">
				,0
				,(select Description from [LMA System Terms] WHERE ID = <cfqueryparam value="#arguments.frmstruct.term_number#" cfsqltype="cf_sql_varchar"> AND CompanyID=<cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar">)
				,<cfqueryparam value="#arguments.frmstruct.term_number#" cfsqltype="cf_sql_integer">
				,0
				,<cfqueryparam value="#local.transdesc#" cfsqltype="cf_sql_varchar">
				,<cfqueryparam value="#local.totalAmount#" cfsqltype="cf_sql_money">
				,0
				,0
				,<cfqueryparam value="#arguments.frmstruct.purchaseorder#" cfsqltype="cf_sql_varchar">
				,<cfqueryparam value="#session.AdminUserName#" cfsqltype="cf_sql_varchar">
				,0
				
				,<cfqueryparam value="#arguments.frmstruct.dueDate#" cfsqltype="cf_sql_date">
	            ,<cfqueryparam value="#arguments.frmstruct.Reference#" cfsqltype="cf_sql_varchar">
				<cfif len(trim(arguments.frmstruct.importance))>
	           		,<cfqueryparam value="#arguments.frmstruct.importance#" cfsqltype="cf_sql_float">
	           	<cfelse>
	           		,0
	           	</cfif>
	            ,GETDATE()
				,<cfqueryparam value="#arguments.frmstruct.notes#" cfsqltype="cf_sql_varchar">
				,<cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar">)

			INSERT INTO [LMA UpdateLog]
				([TableName]
				,[RecordID]
				,[FieldName]
				,[OldValue]
				,[NewValue]
				,[Status]
				,[UpdatedBy]
				,[DateUpdated]
				,[MachineName]
				,[Notes]
				,[Created]
				,[id]
				,[CompanyID])
		    VALUES
				('Load Manager'
				,'AR'
				,'NA'
				,'NA'
				,'NA'
				,'NA'
				,<cfqueryparam value="#session.AdminUserName#" cfsqltype="cf_sql_varchar">
				,GETDATE()
				,'DESKTOP-KNQP4R0'
				,'N/A'
				,GETDATE()
				,(SELECT ISNULL(MAX(ID),0)+1 FROM [LMA UpdateLog])
				,<cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar">)
	    </cfquery>

		<cfset local.intPostedAmount = 0>
		<cfloop from="1" to="10" step="1" index="i">
			<cfset local.GL_ACCT = Evaluate('arguments.frmStruct.glacct_#i#')>
    		<cfif len(trim(local.GL_ACCT))>
    			<cfset local.creditdebit = Evaluate('arguments.frmStruct.creditdebit_#i#')>
    			<cfset local.Description = Evaluate('arguments.frmStruct.description_#i#')>
    			<cfset local.Amount = Evaluate('arguments.frmStruct.amount_#i#')>

    			<cfif local.creditdebit EQ 'D'>
    				<cfset local.intPostedAmount = local.intPostedAmount + replaceNoCase(replaceNoCase(local.Amount,'$',''),',','','ALL')>
    			<cfelse>
    				<cfset local.intPostedAmount = local.intPostedAmount + (replaceNoCase(replaceNoCase(local.Amount,'$',''),',','','ALL')*-1)>
    			</cfif>

    			<cfquery name="insQuery" datasource="#variables.dsn#">
    				INSERT INTO [dbo].[LMA Accounts Payable Invoice Footer History]
						([Customer Code]
						,[Trans Number]
						,[GL Account]
						,[D/C]
						,[GL Description]
						,[Amount]
						,[Stage Code]
						,[EntryDate]
						,[EnteredBy]
						,[CompanyID])
				    VALUES
						(<cfqueryparam value="#arguments.frmstruct.vendorIDContainer#" cfsqltype="cf_sql_varchar">
						,<cfqueryparam value="#arguments.frmstruct.invoice#" cfsqltype="cf_sql_varchar">
						,<cfqueryparam value="#local.GL_ACCT#" cfsqltype="cf_sql_varchar">
						,<cfqueryparam value="#local.creditdebit#" cfsqltype="cf_sql_varchar">
						,<cfqueryparam value="#local.Description#" cfsqltype="cf_sql_varchar">
						,<cfqueryparam value="#replaceNoCase(replaceNoCase(local.Amount,'$',''),',','','ALL')#" cfsqltype="cf_sql_money">
						,0
						,GETDATE()
						,<cfqueryparam value="#session.AdminUserName#" cfsqltype="cf_sql_varchar">
						,<cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar">)
    			</cfquery>
    			<cfif listfind('0,1,2',arguments.frmStruct.year_past)>
    				<cfset local.total = replaceNoCase(replaceNoCase(local.Amount,'$',''),',','','ALL')>
    				<cfif local.creditdebit EQ 'C' AND local.total GT 0>
    					<cfset local.total = -1 * local.total>
    				</cfif>
    				<cfinvoke method="PostToGL" returnvariable="qPostToGL" account="#local.GL_ACCT#" cv_code="#arguments.frmstruct.vendorIDContainer#" year_past="#arguments.frmStruct.year_past#" post_amt="#local.total#" Invoice_Code="#arguments.frmstruct.invoice#" tran_type="RS" tran_desc="#local.Description#" tran_date="#arguments.frmstruct.invoiceDate#" module=""/>
    			</cfif>
    		</cfif>
    	</cfloop>

    	<cfif listFindNoCase("I,C", arguments.frmstruct.type)>
    		<cfset local.GL_ACCT = arguments.frmstruct.ARGLAccount>
			<cfif arguments.frmstruct.type EQ 'I'>
				<cfset local.creditdebit = 'D'>
			<cfelse>
				<cfset local.creditdebit = 'C'>
			</cfif>
			<cfquery name="qGet" datasource="#variables.dsn#">
				select description from [LMA General Ledger Chart of Accounts] where GL_ACCT = <cfqueryparam value="#local.GL_ACCT#" cfsqltype="cf_sql_varchar"> AND CompanyID = <cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar">
			</cfquery>
			<cfset local.Description = qGet.description>
			<cfset local.Amount = arguments.frmStruct.totalAmount>
			<cfif local.creditdebit EQ 'D'>
				<cfset local.intPostedAmount = local.intPostedAmount + replaceNoCase(replaceNoCase(local.Amount,'$',''),',','','ALL')>
			<cfelse>
				<cfset local.intPostedAmount = local.intPostedAmount + (replaceNoCase(replaceNoCase(local.Amount,'$',''),',','','ALL')*-1)>
			</cfif>

			<cfquery name="insQuery" datasource="#variables.dsn#">
				INSERT INTO [dbo].[LMA Accounts Payable Invoice Footer History]
					([Customer Code]
					,[Trans Number]
					,[GL Account]
					,[D/C]
					,[GL Description]
					,[Amount]
					,[Stage Code]
					,[EntryDate]
					,[EnteredBy]
					,[CompanyID])
			    VALUES
					(<cfqueryparam value="#arguments.frmstruct.vendorIDContainer#" cfsqltype="cf_sql_varchar">
					,<cfqueryparam value="#arguments.frmstruct.invoice#" cfsqltype="cf_sql_varchar">
					,<cfqueryparam value="#local.GL_ACCT#" cfsqltype="cf_sql_varchar">
					,<cfqueryparam value="#local.creditdebit#" cfsqltype="cf_sql_varchar">
					,<cfqueryparam value="#local.Description#" cfsqltype="cf_sql_varchar">
					,<cfqueryparam value="#replaceNoCase(replaceNoCase(local.Amount,'$',''),',','','ALL')#" cfsqltype="cf_sql_money">
					,0
					,GETDATE()
					,<cfqueryparam value="#session.AdminUserName#" cfsqltype="cf_sql_varchar">
					,<cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar">)
			</cfquery>
			<cfif listfind('0,1,2',arguments.frmStruct.year_past)>
				<cfset local.total = replaceNoCase(replaceNoCase(local.Amount,'$',''),',','','ALL')>
				<cfif local.creditdebit EQ 'C' AND local.total GT 0>
					<cfset local.total = -1 * local.total>
				</cfif>
				<cfinvoke method="PostToGL" returnvariable="qPostToGL" account="#local.GL_ACCT#" cv_code="#arguments.frmstruct.vendorIDContainer#" year_past="#arguments.frmStruct.year_past#" post_amt="#local.total#" Invoice_Code="#arguments.frmstruct.invoice#" tran_type="RS" tran_desc="#local.Description#" tran_date="#arguments.frmstruct.invoiceDate#" module=""/>
			</cfif>
    	</cfif>

    	<cfif local.intPostedAmount NEQ 0>
    		<cftransaction action="rollback">
			<cfset respStr = structNew()>
	    	<cfset respStr.res = 'error'>
	    	<cfset respStr.msg = "This transaction is out of balance by #DollarFormat(local.intPostedAmount)#. Please fix this and try again.">
	    	<cfreturn respStr>
		</cfif>
    	</cftransaction>
    	<cfset respStr = structNew()>
    	<cfset respStr.res = 'success'>
    	<cfset respStr.msg = "Invoice(s) created successfully.">
    	<cfreturn respStr>
    </cffunction>

    <cffunction name="getLMAVendorInvoices" access="remote" output="yes" returnformat="plain">
		<cfargument name="dsn" type="string" required="yes" />
		<cfargument name="CompanyID" type="string" required="yes" />
		<cfargument name="vendorid" required="No" type="any">
		<cfargument name="SortBy" required="No" type="any" default="TRANS_NUMBER">
		<cfargument name="Sortorder" required="No" type="any" default="ASC">
		<cfquery name="qgetLMAVendorInvoices" datasource="#arguments.dsn#">
			SELECT 
			idcount,
			[Date],
			DueDate,
			TRANS_NUMBER,
			Reference,
			Total,
			Balance,
			Description,
			0 AS Applied,
			Discount,
			VendorID
			FROM [LMA Accounts Payable Transactions]
			WHERE VendorID = <cfqueryparam value="#arguments.vendorid#" cfsqltype="cf_sql_varchar"> 
			AND typetrans = 'I'
			AND balance <> 0
			AND CompanyID = <cfqueryparam value="#arguments.CompanyID#" cfsqltype="cf_sql_varchar">
			ORDER BY #arguments.SortBy# #arguments.Sortorder#
		</cfquery>
		<cfset rowNum = 0>
		<cfsavecontent variable="response">
			<cfif qgetLMAVendorInvoices.recordcount>
				<cfset TotalApplied = 0>
				<cfset TotalDiscount = 0>
				<cfset TotalAmount = 0>
				<input name="TotalRows" value="#qgetLMAVendorInvoices.recordcount#" type="hidden">
				<input name="Description" value="#qgetLMAVendorInvoices.Description#" type="hidden">
				<input name="VendorCode" value="#qgetLMAVendorInvoices.VendorID#" type="hidden">
				<cfoutput query="qgetLMAVendorInvoices">
					<cfset TotalAmount= TotalAmount + qgetLMAVendorInvoices.total>
					<cfset TotalApplied = TotalApplied + qgetLMAVendorInvoices.Applied>
					<cfset TotalDiscount = TotalDiscount + qgetLMAVendorInvoices.Discount>
					<input name="Balance_#qgetLMAVendorInvoices.idcount#" id="Balance_#qgetLMAVendorInvoices.idcount#" value="#qgetLMAVendorInvoices.Balance#" type="hidden">
	                <tr <cfif qgetLMAVendorInvoices.currentRow mod 2 eq 0>bgcolor="##FFFFFF"<cfelse>bgcolor="##f7f7f7"</cfif>>
                        <td align="left" valign="middle" nowrap="nowrap" class="normal-td  left-td-border">#DateFormat(qgetLMAVendorInvoices.Date,'mm/dd/yyyy')#</td>
                        <td align="left" valign="middle" nowrap="nowrap" class="normal-td">#DateFormat(qgetLMAVendorInvoices.DueDate,'mm/dd/yyyy')#</td>
                        <td align="left" valign="middle" nowrap="nowrap" class="normal-td">
                        	#qgetLMAVendorInvoices.TRANS_NUMBER#
                        	<input type="hidden" name="invoice_#qgetLMAVendorInvoices.currentrow#" value="#qgetLMAVendorInvoices.TRANS_NUMBER#">
                        </td>
                        <td align="left" valign="middle" nowrap="nowrap" class="normal-td">#qgetLMAVendorInvoices.Reference#</td>
                        <td align="left" valign="middle" nowrap="nowrap" class="normal-td">
	                        #DollarFormat(qgetLMAVendorInvoices.Total)#
	                        <input type="hidden" name="amount_#qgetLMAVendorInvoices.currentrow#" value="#qgetLMAVendorInvoices.Total#">
	                    </td>
                        <td align="left" valign="middle" nowrap="nowrap" class="normal-td">#DollarFormat(qgetLMAVendorInvoices.Balance)#</td>
                        <td align="left" valign="middle" nowrap="nowrap" class="normal-td">#qgetLMAVendorInvoices.Description#</td>
                        <td align="left" valign="middle" nowrap="nowrap" class="normal-td" style="padding: 0;"><input style="width:99%" class="applied" id="applied_#qgetLMAVendorInvoices.idcount#" name="applied_#qgetLMAVendorInvoices.currentrow#" value="#DollarFormat(qgetLMAVendorInvoices.Applied)#" onclick="calculateTotals('#qgetLMAVendorInvoices.idcount#')"  onchange="formatAppliedDollar('#qgetLMAVendorInvoices.idcount#')"></td>
                        <td align="left" valign="middle" nowrap="nowrap" class="normal-td" style="padding: 0;"><input style="width:95%" class="discount" id="discount_#qgetLMAVendorInvoices.idcount#" name="discount_#qgetLMAVendorInvoices.currentrow#" value="#DollarFormat(qgetLMAVendorInvoices.Discount)#" onclick="calculateDiscount('#qgetLMAVendorInvoices.idcount#')"  onchange="formatDiscountDollar('#qgetLMAVendorInvoices.idcount#')"></td>
                    </tr>
		        </cfoutput>
		        <cfoutput>
		        <tr>
		        	<input name="TotalAmount" value="#TotalAmount#" type="hidden">
		        	<td colspan="7" align="right" colspan="9" class="normal-td left-td-border"><b>Totals:</b></td>
		        	<td align="left" valign="middle" nowrap="nowrap" class="normal-td" style="padding: 0;"><input readonly style="width:99%" id="TotalApplied" name="TotalApplied" value="#DollarFormat(TotalApplied)#"></td>
		        	<td align="left" valign="middle" nowrap="nowrap" class="normal-td" style="padding: 0;"><input style="width:95%" readonly id="TotalDiscount" name="TotalDiscount" value="#DollarFormat(TotalDiscount)#"></td>
		        </tr>
		        </cfoutput>
		    <cfelse>
				<cfoutput>
					<tr>
	                    <td align="center" colspan="9" class="normal-td left-td-border">No Records Found.</td>
	                </tr>
				</cfoutput>
	        </cfif>
        </cfsavecontent>
        <cfreturn response>
	</cffunction>

	<cffunction name="getCheckRegisterSetup" access="public" returntype="query">
    	<cfquery name="qCheckRegisterSetup" datasource="#variables.dsn#">
    		select [Account Code] AS AccountCode,[Account Name] AS AccountName,[General Ledger Code] AS GLAcct from [LMA Check Register Setup]
    		WHERE CompanyID = <cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar">
    	</cfquery>
    	<cfreturn qCheckRegisterSetup>
    </cffunction>

    <cffunction name="updateAccountsPayableTransactions" access="remote" output="yes" returnformat="plain">
		<cfargument name="dsn" type="string" required="yes" />
		<cfargument name="idcount" required="No" type="any">
		<cfargument name="applied" required="No" type="any">
		<cfargument name="discount" required="No" type="any">
		<cfquery name="updQry" datasource="#arguments.dsn#">
    		UPDATE [LMA Accounts Payable Transactions] SET 
    		applied = <cfqueryparam value="#arguments.applied#" cfsqltype="cf_sql_money"> 
    		,discount = <cfqueryparam value="#arguments.discount#" cfsqltype="cf_sql_money"> 
    		WHERE idcount = <cfqueryparam value="#arguments.idcount#" cfsqltype="cf_sql_integer"> 
    	</cfquery>
		<cfreturn 'success'>
	</cffunction>

	<cffunction name="LMAVendorPayment" access="public" returntype="struct">
		<cfargument name="frmStruct" required="no" type="struct">
			<cftransaction>
			<cfset local.description = arguments.frmStruct.description>
			<cfset local.vendorcode = arguments.frmStruct.vendorcode>

			<cfloop from="1" to="#arguments.frmStruct.TotalRows#" index="i">
				<cfset local.invoicenumber = Evaluate('arguments.frmStruct.invoice_#i#')>
				<cfset local.Amount = Evaluate('arguments.frmStruct.Amount_#i#')>
				<cfset local.AmountPaid = Evaluate('arguments.frmStruct.applied_#i#')>
				<cfset local.amountdiscount = Evaluate('arguments.frmStruct.discount_#i#')>

	    		<cfquery name="insQRy" datasource="#variables.dsn#">
	    			INSERT INTO [dbo].[LMA Accounts Payable Check Transaction File]
			           ([description]
			           ,[vendorcode]
			           ,[invoicenumber]
			           ,[amount]
			           ,[amountpaid]
			           ,[amountdiscount]
			           ,[checkaccount]
			           ,[EntryDate]
			           ,[EnteredBy]
			           ,[CompanyID])
			     	VALUES
			           (<cfqueryparam value="#local.description#" cfsqltype="cf_sql_varchar"> 
			           ,<cfqueryparam value="#local.vendorcode#" cfsqltype="cf_sql_varchar"> 
			           ,<cfqueryparam value="#local.invoicenumber#" cfsqltype="cf_sql_integer">
			           ,<cfqueryparam value="#replaceNoCase(replaceNoCase(local.Amount,'$',''),',','','ALL')#" cfsqltype="cf_sql_money">
			           ,<cfqueryparam value="#replaceNoCase(replaceNoCase(local.AmountPaid,'$',''),',','','ALL')#" cfsqltype="cf_sql_money">
			           ,<cfqueryparam value="#replaceNoCase(replaceNoCase(local.amountdiscount,'$',''),',','','ALL')#" cfsqltype="cf_sql_money">
			           ,<cfqueryparam value="#arguments.frmStruct.Acct#" cfsqltype="cf_sql_varchar"> 
			           ,GETDATE()
			           ,<cfqueryparam value="#session.AdminUserName#" cfsqltype="cf_sql_varchar">
			           ,<cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar">)

			        UPDATE [LMA Accounts Payable Transactions] SET Balance = Balance - <cfqueryparam value="#replaceNoCase(replaceNoCase(local.AmountPaid,'$',''),',','','ALL')#" cfsqltype="cf_sql_money">
			        WHERE 
			        TRANS_NUMBER = <cfqueryparam value="#local.invoicenumber#" cfsqltype="cf_sql_integer">
			        AND CompanyID = <cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar">

			        UPDATE Carriers SET Balance = Balance - <cfqueryparam value="#replaceNoCase(replaceNoCase(local.AmountPaid,'$',''),',','','ALL')#" cfsqltype="cf_sql_money">
		            WHERE VendorID = <cfqueryparam value="#Local.vendorcode#" cfsqltype="cf_sql_varchar">
			    </cfquery>

			    <cfquery name="qGetBalance" datasource="#variables.dsn#">
			    	SELECT Balance FROM [LMA Accounts Payable Transactions] WHERE 
			        TRANS_NUMBER = <cfqueryparam value="#local.invoicenumber#" cfsqltype="cf_sql_integer">
			        AND CompanyID = <cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar">
				</cfquery>

				<cfquery name="qGetLoad" datasource="#variables.dsn#">
					SELECT LoadID FROM Loads L 
					INNER JOIN CustomerOffices CO ON CO.CustomerID = L.CustomerID
					INNER JOIN Offices O ON O.OfficeID = CO.OfficeID
					WHERE L.LoadNUmber = <cfqueryparam value="#local.invoicenumber#" cfsqltype="cf_sql_integer"> 
					AND O.CompanyID = <cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar">
				</cfquery>

				<cfif qGetLoad.recordcount and qGetBalance.Balance EQ 0>
					<cfquery name="updLoad" datasource="#variables.dsn#">
		    			UPDATE Loads SET CarrierPaid = 1 WHERE LoadID = <cfqueryparam value="#qGetLoad.LoadID#" cfsqltype="cf_sql_varchar">
		    		</cfquery>
				</cfif>
		    </cfloop>
		</cftransaction>
		<cfset respStr = structNew()>
    	<cfset respStr.res = 'success'>
    	<cfset respStr.msg = "Finished applying payments.">
    	<cfreturn respStr>
    </cffunction>

    <cffunction name="generateCheckNumber" access="remote" returntype="string" returnFormat="plain">
    	<cfargument name="dsn" required="yes" type="string">
    	<cfargument name="AccountCode" required="yes" type="string">
    	<cfargument name="CompanyID" type="string" required="yes" />
    	<cfquery name="qGenerateCheckNumber" datasource="#arguments.dsn#">

    		SELECT [Next Check ##] AS NextCheckNo FROM  [LMA Check Register Setup] WHERE [Account Code] = <cfqueryparam value="#arguments.AccountCode#" cfsqltype="cf_sql_varchar"> 
    		AND CompanyID = <cfqueryparam value="#arguments.CompanyID#" cfsqltype="cf_sql_varchar"> 

    		UPDATE [LMA Check Register Setup] SET [Next Check ##] = [Next Check ##] + 1 WHERE [Account Code] = <cfqueryparam value="#arguments.AccountCode#" cfsqltype="cf_sql_varchar">
    		AND CompanyID =  <cfqueryparam value="#arguments.CompanyID#" cfsqltype="cf_sql_varchar"> 
    	</cfquery>
    	<cfreturn qGenerateCheckNumber.NextCheckNo>
    </cffunction>

    <cffunction name="printChecks" access="remote" returntype="string" returnFormat="plain">
    	<cfargument name="dsn" required="yes" type="string">
    	<cfargument name="account" required="yes" type="string">
    	<cfargument name="checkNumber" required="yes" type="string">
    	<cfargument name="CompanyID" type="string" required="yes" />
    	<cftransaction>
    	<cfquery name="updQry" datasource="#arguments.dsn#">
    		UPDATE [LMA Accounts Payable Check Transaction File] SET
    		checknumber = <cfqueryparam value="#arguments.checkNumber#" cfsqltype="cf_sql_varchar"> 
    		,checkdate = GETDATE()
    		WHERE checkaccount = <cfqueryparam value="#arguments.account#" cfsqltype="CF_SQL_INTEGER"> 
    		AND ISNULL(checknumber,'0') = '0'
    		AND CompanyID = <cfqueryparam value="#arguments.CompanyID#" cfsqltype="cf_sql_varchar"> 
    	</cfquery>

    	<cfquery name="getQry" datasource="#arguments.dsn#">
    		SELECT * FROM [LMA Accounts Payable Check Transaction File] WHERE checknumber = <cfqueryparam value="#arguments.checkNumber#" cfsqltype="cf_sql_varchar"> 
    		AND CompanyID =  <cfqueryparam value="#arguments.CompanyID#" cfsqltype="cf_sql_varchar"> 
    		ORDER BY ID
    	</cfquery>

    	<cfloop query="getQry">
    		<cfquery name="insQry" datasource="#arguments.dsn#">
    			INSERT INTO [dbo].[LMA Accounts Payable Check Payment Detail Current]
			           ([InvoicAmount]
			           ,[InvoicBalancBeforePay]
			           ,[InvoiceBalancAfterPay]
			           ,[VendorCode]
			           ,[ApplieAmount]
			           ,[DiscouAmount]
			           ,[CheckNumber]
			           ,[InvoiceNumber]
			           ,[CheckDate]
			           ,[CheckAccount]
			           ,[EntryDate]
			           ,[EnteredBy]
			           ,[CompanyID])
			     VALUES
			           (<cfqueryparam value="#getQry.amount#" cfsqltype="cf_sql_money"> 
			           ,<cfqueryparam value="#getQry.amount#" cfsqltype="cf_sql_money"> 
			           ,0
			           ,<cfqueryparam value="#getQry.vendorcode#" cfsqltype="cf_sql_varchar">
			           ,<cfqueryparam value="#getQry.amountpaid#" cfsqltype="cf_sql_money">
			           ,<cfqueryparam value="#getQry.amountdiscount#" cfsqltype="cf_sql_money">
			           ,<cfqueryparam value="#getQry.checkNumber#" cfsqltype="cf_sql_varchar"> 
			           ,<cfqueryparam value="#getQry.invoicenumber#" cfsqltype="cf_sql_varchar">
			           ,<cfqueryparam value="#getQry.checkdate#" cfsqltype="cf_sql_date"> 
			           ,<cfqueryparam value="#getQry.checkaccount#" cfsqltype="cf_sql_integer"> 
			           ,<cfqueryparam value="#getQry.EntryDate#" cfsqltype="cf_sql_date"> 
			           ,<cfqueryparam value="#getQry.EnteredBy#" cfsqltype="cf_sql_varchar">
			           ,<cfqueryparam value="#arguments.CompanyID#" cfsqltype="cf_sql_varchar"> )
			</cfquery>
    	</cfloop>
    	</cftransaction>
    	<cfreturn 'Success'>
    </cffunction>

    <cffunction name="closeChecks" access="remote" returntype="string" returnFormat="plain">
    	<cfargument name="dsn" required="yes" type="string">
    	<cfargument name="account" required="yes" type="string">
    	<cfargument name="checkNumber" required="yes" type="string">
    	<cfargument name="CompanyID" type="string" required="yes" />
    	<cfquery name="getQry" datasource="#arguments.dsn#">
    		SELECT * FROM [LMA Accounts Payable Check Transaction File] WHERE checknumber = <cfqueryparam value="#arguments.checkNumber#" cfsqltype="cf_sql_float"> 
    		AND CompanyID =  <cfqueryparam value="#arguments.CompanyID#" cfsqltype="cf_sql_varchar"> 
    		ORDER BY ID
    	</cfquery>
    	<cftransaction>
    	<cfloop query="getQry">
    		<cfquery name="insQry" datasource="#arguments.dsn#">
    			INSERT INTO [dbo].[LMA Accounts Payable Check Transaction History]
		           ([description]
		           ,[vendorcode]
		           ,[invoicenumber]
		           ,[amount]
		           ,[amountpaid]
		           ,[amountdiscount]
		           ,[invoicedate]
		           ,[checknumber]
		           ,[checkdate]
		           ,[checkaccount]
		           ,[Voided]
		           ,[EntryDate]
		           ,[EnteredBy]
		           ,[XRateAmt]
		           ,[CompanyID])
		     	VALUES
		           (<cfqueryparam value="#getQry.description#" cfsqltype="cf_sql_varchar">
		           ,<cfqueryparam value="#getQry.vendorcode#" cfsqltype="cf_sql_varchar">
		           ,<cfqueryparam value="#getQry.invoicenumber#" cfsqltype="cf_sql_varchar">
		           ,<cfqueryparam value="#getQry.amount#" cfsqltype="cf_sql_money"> 
		           ,<cfqueryparam value="#getQry.amountpaid#" cfsqltype="cf_sql_money">
		           ,<cfqueryparam value="#getQry.amountdiscount#" cfsqltype="cf_sql_money">
		           ,<cfqueryparam value="#getQry.invoicedate#" cfsqltype="cf_sql_date">
		           ,<cfqueryparam value="#getQry.checkNumber#" cfsqltype="cf_sql_float"> 
		           ,<cfqueryparam value="#getQry.checkdate#" cfsqltype="cf_sql_date"> 
		           ,<cfqueryparam value="#getQry.checkaccount#" cfsqltype="cf_sql_integer"> 
		           ,0
		           ,<cfqueryparam value="#getQry.EntryDate#" cfsqltype="cf_sql_date"> 
			       ,<cfqueryparam value="#getQry.EnteredBy#" cfsqltype="cf_sql_varchar">
		           ,0
		           ,<cfqueryparam value="#arguments.CompanyID#" cfsqltype="cf_sql_varchar"> )
    		</cfquery>
    	</cfloop>

    	<cfquery name="delQry" datasource="#arguments.dsn#">
    		DELETE FROM [LMA Accounts Payable Check Transaction File] WHERE checknumber = <cfqueryparam value="#arguments.checkNumber#" cfsqltype="cf_sql_float"> 
    		AND CompanyID =  <cfqueryparam value="#arguments.CompanyID#" cfsqltype="cf_sql_varchar"> 
    	</cfquery>
    	</cftransaction>
    </cffunction>

    <cffunction name="getLMAPaymentTerms" access="public" output="false" returntype="query">
		<cfargument name="searchText" required="no" type="any">
	    <cfargument name="pageNo" required="no" type="any" default="1">
	    <cfargument name="sortorder" required="no" type="any" default="ASC">
	    <cfargument name="sortby" required="no" type="any" default="Description">

	    <cfquery name="qPaymentTerms" datasource="#Application.dsn#">
	    	BEGIN WITH page AS 
	    	(SELECT 
	    		ID,
				Description,
				[Discount Amount] AS Discount,
				[Terms Type] AS Type,
				[Max Days] AS DiscountDays,
				[Terms Days] AS NetDays
				,ROW_NUMBER() OVER (ORDER BY #arguments.sortby# #arguments.sortorder#) AS Row
				FROM [LMA System Terms]
				WHERE CompanyID =  <cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar"> 
	    	<cfif structKeyExists(arguments, "searchText") and len(trim(arguments.searchText))>
			    AND (Description LIKE <cfqueryparam value="%#arguments.searchText#%" cfsqltype="cf_sql_varchar">)
		    </cfif>
		    )
		    SELECT
		      *,(select (max(row)/30) + (CASE WHEN max(row)%30 <> 0 THEN 1 ELSE 0 END)  FROM page) AS TotalPages 
		    FROM page
		    WHERE Row BETWEEN (#arguments.pageNo# - 1) * 30 + 1 AND #arguments.pageNo# * 30
		    END
		</cfquery>

		<cfreturn qPaymentTerms>
	</cffunction>

	<cffunction name="savePaymentTerm" access="public" returntype="string">
		<cfargument name="frmStruct" required="no" type="struct">

		<cfif Len(Trim(arguments.frmstruct.ID))>
			<cfquery name="updQry" datasource="#variables.dsn#">
				UPDATE [LMA System Terms]
				SET [Description] = <cfqueryparam value="#arguments.frmstruct.description#" cfsqltype="cf_sql_varchar">
		           ,[Discount Amount] = <cfqueryparam value="#replaceNoCase(replaceNoCase(arguments.frmstruct.discount,'$',''),',','','ALL')#" cfsqltype="cf_sql_float">
		           ,[Terms Type] = <cfqueryparam value="#arguments.frmstruct.Type#" cfsqltype="cf_sql_varchar">
		           ,[Max Days] = <cfqueryparam value="#arguments.frmstruct.DiscountDays#" cfsqltype="CF_SQL_INTEGER">
		           ,[Terms Days] = <cfqueryparam value="#arguments.frmstruct.NetDays#" cfsqltype="CF_SQL_INTEGER">
				WHERE ID = <cfqueryparam value="#arguments.frmstruct.ID#" cfsqltype="CF_SQL_INTEGER">
			</cfquery>
		<cfelse>
			<cfquery name="insQry" datasource="#variables.dsn#">
				INSERT INTO [dbo].[LMA System Terms]
			           ([ID]
			           ,[Description]
			           ,[Discount Amount]
			           ,[Terms Type]
			           ,[Max Days]
			           ,[Terms Days]
			           ,[CompanyID])
			    VALUES
			           ((SELECT ISNULL(MAX(ID),0)+1 FROM [LMA System Terms])
			           ,<cfqueryparam value="#arguments.frmstruct.description#" cfsqltype="cf_sql_varchar">
			           ,<cfqueryparam value="#replaceNoCase(replaceNoCase(arguments.frmstruct.discount,'$',''),',','','ALL')#" cfsqltype="cf_sql_float">
			           ,<cfqueryparam value="#arguments.frmstruct.Type#" cfsqltype="cf_sql_varchar">
			           ,<cfqueryparam value="#arguments.frmstruct.DiscountDays#" cfsqltype="CF_SQL_INTEGER">
			           ,<cfqueryparam value="#arguments.frmstruct.NetDays#" cfsqltype="CF_SQL_INTEGER">
			           ,<cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar"> )
			</cfquery>
		</cfif>
		<cfreturn 'Payment Term saved successfully.'>
	</cffunction>

	<cffunction name="getLMAPaymentTermDetail" access="public" output="false" returntype="query">
		<cfargument name="ID" required="no" type="any">
	    <cfquery name="qPaymentTerm" datasource="#Application.dsn#">
	    	SELECT 
	    	ID,
			Description,
			[Discount Amount] AS Discount,
			[Terms Type] AS Type,
			[Max Days] AS DiscountDays,
			[Terms Days] AS NetDays
	    	FROM [LMA System Terms]
	    	WHERE ID = <cfqueryparam value="#arguments.ID#" cfsqltype="CF_SQL_INTEGER">
	    	AND CompanyID = <cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar"> 
		</cfquery>
		<cfreturn qPaymentTerm>
	</cffunction>

	<cffunction name="deletePaymentTerm" access="public" returntype="string">
		<cfargument name="ID" required="no" type="any">
	    <cfquery name="delPaymentTerm" datasource="#Application.dsn#">
	    	DELETE
	    	FROM [LMA System Terms]
	    	WHERE ID = <cfqueryparam value="#arguments.ID#" cfsqltype="CF_SQL_INTEGER">
	    	AND CompanyID = <cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar"> 
		</cfquery>
		<cfreturn 'Payment Term Deleted.'>
	</cffunction>

	<cffunction name="FindGLTrans" access="public" output="false" returntype="query">
		<cfargument name="frmStruct" required="no" type="any">
	    <cfquery name="qGLTransactions" datasource="#Application.dsn#">
	    	BEGIN WITH page AS 
	    	(SELECT 
	    		GL.[ID]
		        ,GL.[GL Account] AS Account
		        ,GL.[GL Department] AS Department
		        ,GL.[Date]
		        ,GL.[Code]
		        ,GL.[Invoice Code] AS TransactionCode
		        ,GL.[Description]
		        ,GL.[D/C] AS DC
		        ,GL.[Amount]
		        ,GL.[Damount]
		        ,GL.[Camount]
		        ,GL.[Typetran]
		        ,GL.[EnteredBy]
		        ,GL.[Module]
		        ,GL.[EntryDate]
				,ROW_NUMBER() OVER (ORDER BY [#arguments.frmStruct.sortby#] #arguments.frmStruct.sortorder#) AS Row
				FROM [LMA General Ledger Transactions] GL
				INNER JOIN [LMA General Ledger Chart of Accounts] COA ON GL.[GL Account] = COA.[GL_ACCT]
				WHERE GL.CompanyID = <cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar"> 
	    	<cfif structKeyExists(arguments.frmStruct, "GL_ACCT") and len(trim(arguments.frmStruct.GL_ACCT))>
			    AND [GL Account] = <cfqueryparam value="#arguments.frmstruct.GL_ACCT#" cfsqltype="cf_sql_varchar">
		    </cfif>
		    <cfif structKeyExists(arguments.frmStruct, "Description") and len(trim(arguments.frmStruct.Description))>
			    AND GL.[Description] = <cfqueryparam value="#arguments.frmstruct.Description#" cfsqltype="cf_sql_varchar">
		    </cfif>
		    <cfif structKeyExists(arguments.frmStruct, "Amount") and len(trim(arguments.frmStruct.Amount))>
		    	<cfset local.amount = replaceNoCase(replaceNoCase(arguments.frmstruct.Amount,'$',''),',','','ALL')>
		    	<cfset local.amount = listAppend(local.amount, -1*local.amount)>
			    AND [Amount] IN (<cfqueryparam value="#local.amount#" cfsqltype="cf_sql_money" list="true">)
		    </cfif>
		    <cfif structKeyExists(arguments.frmStruct, "Date") and len(trim(arguments.frmStruct.Date))>
			    AND GL.[Date] = <cfqueryparam value="#arguments.frmstruct.Date#" cfsqltype="cf_sql_date">
		    </cfif>
		    <cfif structKeyExists(arguments.frmStruct, "Type") and len(trim(arguments.frmStruct.Type))>
			    AND [Typetran] = <cfqueryparam value="#arguments.frmstruct.Type#" cfsqltype="cf_sql_varchar">
		    </cfif>
		    <cfif structKeyExists(arguments.frmStruct, "Code") and len(trim(arguments.frmStruct.Code))>
			    AND [Code] = <cfqueryparam value="#arguments.frmstruct.Code#" cfsqltype="cf_sql_varchar">
		    </cfif>
		    <cfif structKeyExists(arguments.frmStruct, "EnteredBy") and len(trim(arguments.frmStruct.EnteredBy))>
			    AND [EnteredBy] = <cfqueryparam value="#arguments.frmstruct.EnteredBy#" cfsqltype="cf_sql_varchar">
		    </cfif>
		    <cfif structKeyExists(arguments.frmStruct, "InvoiceCode") and len(trim(arguments.frmStruct.InvoiceCode))>
			    AND [Invoice Code] = <cfqueryparam value="#arguments.frmstruct.InvoiceCode#" cfsqltype="cf_sql_varchar">
		    </cfif>
		    <cfif structKeyExists(arguments.frmStruct, "EntryDate") and len(trim(arguments.frmStruct.EntryDate))>
			    AND CONVERT(varchar, [EntryDate], 101) = <cfqueryparam value="#arguments.frmstruct.EntryDate#" cfsqltype="cf_sql_date">
		    </cfif>
		    <cfif structKeyExists(arguments.frmStruct, "DC") and len(trim(arguments.frmStruct.DC)) and listFindNoCase("D,C",arguments.frmStruct.DC)>
			    AND [D/C] = <cfqueryparam value="#arguments.frmStruct.DC#" cfsqltype="cf_sql_varchar">
		    </cfif>

		    GROUP BY  GL.[ID]
	        ,GL.[GL Account]
	        ,GL.[GL Department] 
	        ,GL.[Date]
	        ,GL.[Code]
	        ,GL.[Invoice Code]
	        ,GL.[Description]
	        ,GL.[D/C] 
	        ,GL.[Amount]
	        ,GL.[Damount]
	        ,GL.[Camount]
	        ,GL.[Typetran]
	        ,GL.[EnteredBy]
	        ,GL.[Module]
	        ,GL.[EntryDate]
		    )
		    SELECT
		      *,(select (max(row)/30) + (CASE WHEN max(row)%30 <> 0 THEN 1 ELSE 0 END)  FROM page) AS TotalPages 
		    FROM page
		    WHERE Row BETWEEN (#arguments.frmStruct.pageNo# - 1) * 30 + 1 AND #arguments.frmStruct.pageNo# * 30 
		    END
		</cfquery>

		<cfreturn qGLTransactions>
	</cffunction>

	<cffunction name="getBankAccounts" access="public" output="false" returntype="query">
		<cfquery name="qBankAccounts" datasource="#Application.dsn#">
			SELECT 
				[ID]
				,[account code] AS AccountCode
				,[General Ledger Code] AS GLAccount
				,[Account Name] AS AccountName
				,[Next Check ##] AS NextCheckNo
				,[DateReconc]
				,[General Ledger Dept]
				,[Openbalance]
				,[Debit]
				,[Credit]
				,[Balance]
				,[Recorded Debits]
				,[BankDeposits]
				,[BankChecks]
				,[BankFees]
				,[BankInterest]
				,[DateReconc]
				,[AdjPosted]
				,[NextHandCheck]
				,[EndBalance]
				,[pathCSV]
		  FROM [dbo].[LMA Check Register Setup]
		  WHERE CompanyID = <cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar">
		</cfquery>
		<cfreturn qBankAccounts>
	</cffunction>

	<cffunction name="LMACheckRegisterSetup" access="remote" output="yes" returnformat="plain">
		<cfargument name="dsn" type="string" required="yes" />
		<cfargument name="fieldName" type="string" required="yes" />
		<cfargument name="id" type="string" required="yes" />
		<cfargument name="value" type="string" required="yes" />
		<cfargument name="companyid" type="string" required="yes" />
		<cftransaction>
		<cfif arguments.id eq 0>
			<cfquery name="qIns" datasource="#arguments.dsn#" result="qBankAcc">
				INSERT INTO [dbo].[LMA Check Register Setup]
			           ([Next Check ##]
			           ,[Openbalance]
			           ,[Debit]
			           ,[Credit]
			           ,[Balance]
			           ,[Recorded Debits]
			           ,[BankDeposits]
			           ,[BankChecks]
			           ,[BankFees]
			           ,[BankInterest]
			           ,[AdjPosted]
			           ,[NextHandCheck]
			           ,[EndBalance]
			           ,[CompanyID])
			    VALUES
			           (0,0,0,0,0,0,0,0,0,0,0,0,0,'#arguments.companyid#')
			</cfquery>
			<cfset arguments.id = qBankAcc.GENERATEDKEY>
			<cfquery name="qBankAcc" datasource="#arguments.dsn#">
				UPDATE [LMA Check Register Setup] SET [account code] = <cfqueryparam value="#arguments.id#" cfsqltype="CF_SQL_INTEGER">
				WHERE ID = <cfqueryparam value="#arguments.id#" cfsqltype="CF_SQL_INTEGER">
				AND CompanyID = '#arguments.companyid#'
			</cfquery>
		</cfif>
		
		<cfquery name="qUpd" datasource="#arguments.dsn#">
			UPDATE [LMA Check Register Setup] SET [#arguments.fieldName#] = 
			<cfif listFindNoCase("General Ledger Code,Account Name", arguments.fieldName)>
				<cfqueryparam value="#arguments.value#" cfsqltype="cf_sql_varchar">
			<cfelseif listFindNoCase("Next Check ##,NextHandCheck", arguments.fieldName)>
				<cfqueryparam value="#arguments.value#" cfsqltype="cf_sql_float">
			<cfelseif listFindNoCase("Openbalance,Debit,Credit,Balance", arguments.fieldName)>
				<cfqueryparam value="#replaceNoCase(replaceNoCase(arguments.value,'$',''),',','','ALL')#" cfsqltype="cf_sql_money">
			<cfelseif arguments.fieldName EQ 'DateReconc'>
				<cfif len(trim(arguments.value)) AND isDate(arguments.value)>
					<cfqueryparam value="#arguments.value#" cfsqltype="cf_sql_date">
				<cfelse>
					NULL
				</cfif>
			</cfif>
			WHERE ID = <cfqueryparam value="#arguments.id#" cfsqltype="CF_SQL_INTEGER">
			AND CompanyID = '#arguments.companyid#'
		</cfquery>
		</cftransaction>
		<cfreturn arguments.id>
	</cffunction>

	<cffunction name="LMADeleteCheckRegisterSetup" access="remote" output="yes" returnformat="plain">
		<cfargument name="dsn" type="string" required="yes" />
		<cfargument name="id" type="string" required="yes" />
		<cfargument name="companyid" type="string" required="yes" />
		<cfquery name="qDel" datasource="#arguments.dsn#">
			DELETE FROM [LMA Check Register Setup] WHERE ID = <cfqueryparam value="#arguments.id#" cfsqltype="CF_SQL_INTEGER"> 
			AND CompanyID = '#arguments.companyid#'
		</cfquery>

		<cfreturn 1>
	</cffunction>

	<cffunction name="getChartofAccountsList" access="public" output="false" returntype="query">
		<cfargument name="searchText" required="no" type="any">
	    <cfargument name="pageNo" required="no" type="any" default="1">
	    <cfargument name="sortorder" required="no" type="any" default="ASC">
	    <cfargument name="sortby" required="no" type="any" default="GL_ACCT">

	    <cfquery name="qChartofAccountsList" datasource="#Application.dsn#">
	    	BEGIN WITH page AS 
	    	(SELECT 
	    		ID,
	    		GL_ACCT,
				Description,
				#DateFormat(now(),'MMM')#_CURRENT AS MTD,
				END_CURRENT AS YTD,
				Type_Description,
				ROW_NUMBER() OVER (ORDER BY #arguments.sortby# #arguments.sortorder#) AS Row
				FROM [LMA General Ledger Chart of Accounts]
				WHERE CompanyID = <cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar">
	    	<cfif structKeyExists(arguments, "searchText") and len(trim(arguments.searchText))>
			    AND (GL_ACCT LIKE <cfqueryparam value="%#arguments.searchText#%" cfsqltype="cf_sql_varchar">)
		    </cfif>
		    )
		    SELECT
		      *,(select (max(row)/30) + (CASE WHEN max(row)%30 <> 0 THEN 1 ELSE 0 END)  FROM page) AS TotalPages 
		    FROM page
		    WHERE Row BETWEEN (#arguments.pageNo# - 1) * 30 + 1 AND #arguments.pageNo# * 30
		    END
		</cfquery>

		<cfreturn qChartofAccountsList>
	</cffunction>

	<cffunction name="getAttachmentTypes" access="public" output="false" returntype="query">
		<cfargument name="searchText" required="no" type="any">
	    <cfargument name="pageNo" required="no" type="any" default="1">
	    <cfargument name="sortorder" required="no" type="any" default="ASC">
	    <cfargument name="sortby" required="no" type="any" default="AttachmentType">
	    <cfargument name="type" required="no" type="string" default="">
	    <cfquery name="qAttachmentTypes" datasource="#Application.dsn#">
	    	BEGIN WITH page AS 
	    	(SELECT 
	    		AttachmentTypeID,
	    		AttachmentType,
				Description,
				Required
				,ROW_NUMBER() OVER (ORDER BY #arguments.sortby# #arguments.sortorder#) AS Row
				FROM FileAttachmentTypes
				WHERE CompanyID = <cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar"> 
	    	<cfif structKeyExists(arguments, "searchText") and len(trim(arguments.searchText))>
	    		AND (Description LIKE <cfqueryparam value="%#arguments.searchText#%" cfsqltype="cf_sql_varchar">
	    			OR AttachmentType LIKE <cfqueryparam value="%#arguments.searchText#%" cfsqltype="cf_sql_varchar">)
		    </cfif>
		    <cfif structKeyExists(arguments, "type") and len(trim(arguments.type))>
		    	AND AttachmentType = <cfqueryparam value="#arguments.type#" cfsqltype="cf_sql_varchar"> 
		    </cfif>
		    )
		    SELECT
		      *
		    FROM page
		    WHERE Row BETWEEN (#arguments.pageNo# - 1) * 30 + 1 AND #arguments.pageNo# * 30
		    END
		</cfquery>

		<cfreturn qAttachmentTypes>
	</cffunction>

	<cffunction name="saveAttachmentType" access="public" returntype="string">
		<cfargument name="frmStruct" required="no" type="struct">

		<cfif structKeyExists(arguments.frmstruct, "Required")>
			<cfset local.Required = 1>
		<cfelse>
			<cfset local.Required = 0>
		</cfif>
		<cfif Len(Trim(arguments.frmstruct.ID))>
			<cfquery name="updQry" datasource="#variables.dsn#">
				UPDATE FileAttachmentTypes
				SET 
					AttachmentType = <cfqueryparam value="#arguments.frmstruct.Type#" cfsqltype="cf_sql_varchar">
					,Description = <cfqueryparam value="#arguments.frmstruct.description#" cfsqltype="cf_sql_varchar">
		            ,Required = <cfqueryparam value="#local.Required#" cfsqltype="cf_sql_bit">
		            <cfif structKeyExists(arguments.frmstruct, "Recurring")>
		            	,Recurring = 1
		            <cfelse>
		            	,Recurring = 0
		            </cfif>
		            <cfif structKeyExists(arguments.frmstruct, "RenewalDate")>
		            	,RenewalDate = <cfqueryparam value="#arguments.frmstruct.RenewalDate#" cfsqltype="cf_sql_date">
		            <cfelse>
		            	,RenewalDate = NULL
		            </cfif>
		            <cfif structKeyExists(arguments.frmstruct, "Interval")>
		            	,Interval = <cfqueryparam value="#arguments.frmstruct.Interval#" cfsqltype="cf_sql_integer">
		            <cfelse>
		            	,Interval = NULL
		            </cfif>
				WHERE AttachmentTypeID = <cfqueryparam value="#arguments.frmstruct.ID#" cfsqltype="cf_sql_varchar">
			</cfquery>
		<cfelse>
			<cfquery name="insQry" datasource="#variables.dsn#">
				INSERT INTO [dbo].[FileAttachmentTypes]
			           (AttachmentType
			           ,Description
			           ,Required
			           ,CompanyID
			           ,Recurring
			           ,RenewalDate
			           ,Interval)
			    VALUES
			           (<cfqueryparam value="#arguments.frmstruct.Type#" cfsqltype="cf_sql_varchar">
			           ,<cfqueryparam value="#arguments.frmstruct.description#" cfsqltype="cf_sql_varchar">
			           ,<cfqueryparam value="#local.Required#" cfsqltype="cf_sql_bit">
			           ,<cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar">
			           ,<cfif structKeyExists(arguments.frmstruct, "Recurring")>1<cfelse>0</cfif>
			            <cfif structKeyExists(arguments.frmstruct, "RenewalDate")>
			            	,<cfqueryparam value="#arguments.frmstruct.RenewalDate#" cfsqltype="cf_sql_date">
			            <cfelse>
			            	,NULL
			            </cfif>
			            <cfif structKeyExists(arguments.frmstruct, "Interval")>
			            	,<cfqueryparam value="#arguments.frmstruct.Interval#" cfsqltype="cf_sql_integer">
			            <cfelse>
			            	,NULL
			            </cfif>
						)
			</cfquery>
		</cfif>
		<cfreturn 'Attachment type saved successfully.'>
	</cffunction>

	<cffunction name="getAttachmentTypeDetail" access="public" output="false" returntype="query">
		<cfargument name="ID" required="no" type="any">
	    <cfquery name="qAttachmentType" datasource="#Application.dsn#">
	    	SELECT 
	    	*
	    	FROM FileAttachmentTypes
	    	WHERE AttachmentTypeID = <cfqueryparam value="#arguments.ID#" cfsqltype="cf_sql_varchar">
		</cfquery>
		<cfreturn qAttachmentType>
	</cffunction>

	<cffunction name="deleteAttachmentType" access="public" returntype="string">
		<cfargument name="ID" required="no" type="any">
	    <cfquery name="delAttachmentType" datasource="#Application.dsn#">
	    	DELETE
	    	FROM FileAttachmentTypes
	    	WHERE AttachmentTypeID = <cfqueryparam value="#arguments.ID#" cfsqltype="cf_sql_varchar">
		</cfquery>
		<cfreturn 'Attachment Type Deleted.'>
	</cffunction>

	<cffunction name="updateLoadRepCommission" access="remote" output="false" returntype="boolean" returnFormat="plain">
		<cfargument name="dsn" type="string" required="yes" />
		<cfargument name="LoadID" type="string" required="yes" />
		
		<cfargument name="fpSalesRep1" type="string" required="yes" />
		<cfargument name="fpSalesRep2" type="string" required="yes" />
		<cfargument name="fpSalesRep3" type="string" required="yes" />
		<cfargument name="fpSalesRep1Per" type="string" required="yes" />
		<cfargument name="fpSalesRep2Per" type="string" required="yes" />
		<cfargument name="fpSalesRep3Per" type="string" required="yes" />

		<cftry>
			<cfquery name="qUpd" datasource="#arguments.dsn#">
				UPDATE Loads SET 
				SalesRep1 = <cfqueryparam value="#arguments.fpSalesRep1#" cfsqltype="cf_sql_varchar" null="#yesNoFormat(NOT len(arguments.fpSalesRep1))#">
				,SalesRep2 = <cfqueryparam value="#arguments.fpSalesRep2#" cfsqltype="cf_sql_varchar"  null="#yesNoFormat(NOT len(arguments.fpSalesRep2))#">
				,SalesRep3 = <cfqueryparam value="#arguments.fpSalesRep3#" cfsqltype="cf_sql_varchar"  null="#yesNoFormat(NOT len(arguments.fpSalesRep3))#">
				,SalesRep2Name = (SELECT Name FROM Employees WHERE EmployeeID = <cfqueryparam value="#arguments.fpSalesRep2#" cfsqltype="cf_sql_varchar" null="#yesNoFormat(NOT len(arguments.fpSalesRep2))#">)
				,SalesRep3Name = (SELECT Name FROM Employees WHERE EmployeeID = <cfqueryparam value="#arguments.fpSalesRep3#" cfsqltype="cf_sql_varchar" null="#yesNoFormat(NOT len(arguments.fpSalesRep3))#">)
				,SalesRep1Percentage = <cfqueryparam value="#arguments.fpSalesRep1Per#" cfsqltype="cf_sql_decimal">
				,SalesRep2Percentage = <cfqueryparam value="#arguments.fpSalesRep2Per#" cfsqltype="cf_sql_decimal">
				,SalesRep3Percentage = <cfqueryparam value="#arguments.fpSalesRep3Per#" cfsqltype="cf_sql_decimal">
				WHERE LoadID = <cfqueryparam value="#arguments.LoadID#" cfsqltype="cf_sql_varchar"> 
			</cfquery>
				<cfreturn 1>
			<cfcatch>
				<cfreturn 0>
			</cfcatch>
		</cftry>
	</cffunction>
	<cffunction name="updateDispatcherCommission" access="remote" output="false" returntype="boolean" returnFormat="plain">
		<cfargument name="dsn" type="string" required="yes" />
		<cfargument name="LoadID" type="string" required="yes" />	
		<cfargument name="fpDispatcher1" type="string" required="yes" />
		<cfargument name="fpDispatcher2" type="string" required="yes" />
		<cfargument name="fpDispatcher3" type="string" required="yes" />
		<cfargument name="fpDispatcher1per" type="string" required="yes" />
		<cfargument name="fpDispatcher2per" type="string" required="yes" />
		<cfargument name="fpDispatcher3per" type="string" required="yes" />
		<cftry>
			<cfquery name="qUpd" datasource="#arguments.dsn#">
				UPDATE Loads SET 
				Dispatcher1 = <cfqueryparam value="#arguments.fpDispatcher1#" cfsqltype="cf_sql_varchar" null="#yesNoFormat(NOT len(arguments.fpDispatcher1))#">
				,Dispatcher2 = <cfqueryparam value="#arguments.fpDispatcher2#" cfsqltype="cf_sql_varchar" null="#yesNoFormat(NOT len(arguments.fpDispatcher2))#">
				,Dispatcher3 = <cfqueryparam value="#arguments.fpDispatcher3#" cfsqltype="cf_sql_varchar" null="#yesNoFormat(NOT len(arguments.fpDispatcher3))#">
				,Dispatcher2Name = (SELECT Name FROM Employees WHERE EmployeeID = <cfqueryparam value="#arguments.fpDispatcher2#" cfsqltype="cf_sql_varchar" null="#yesNoFormat(NOT len(arguments.fpDispatcher2))#">)
				,Dispatcher3Name = (SELECT Name FROM Employees WHERE EmployeeID = <cfqueryparam value="#arguments.fpDispatcher3#" cfsqltype="cf_sql_varchar" null="#yesNoFormat(NOT len(arguments.fpDispatcher3))#">)
				,Dispatcher1Percentage = <cfqueryparam value="#arguments.fpDispatcher1per#" cfsqltype="cf_sql_decimal">
				,Dispatcher2Percentage = <cfqueryparam value="#arguments.fpDispatcher2per#" cfsqltype="cf_sql_decimal">
				,Dispatcher3Percentage = <cfqueryparam value="#arguments.fpDispatcher3per#" cfsqltype="cf_sql_decimal">
				WHERE LoadID = <cfqueryparam value="#arguments.LoadID#" cfsqltype="cf_sql_varchar"> 
			</cfquery>
				<cfreturn 1>
			<cfcatch>
				<cfreturn 0>
			</cfcatch>
		</cftry>
	</cffunction>
	<cffunction name="loadCustomerAutoSave" access="remote" output="yes" returnformat="json">
		<cfargument name="loadid" type="string" required="yes" />
		<cfargument name="payerid" type="string" required="yes" />

		<cfset local.dsn = trim(listFirst(cgi.SCRIPT_NAME,'/'))>
		<cfquery name="qUpd" datasource="#local.dsn#">
			UPDATE Loads SET PayerID = <cfqueryparam value="#arguments.PayerID#" cfsqltype="cf_sql_varchar">
			WHERE LoadID =  <cfqueryparam value="#arguments.loadid#" cfsqltype="cf_sql_varchar">
		</cfquery>
	</cffunction>

	<cffunction name="loadCarrierAutoSave" access="remote" output="yes" returnformat="json">
		<cfargument name="loadid" type="string" required="yes" />
		<cfargument name="carrierid" type="string" required="yes" />
		<cfargument name="stopno" type="string" required="yes" />
		<cfargument name="companyid" type="string" required="yes" />

		<cfset local.dsn = trim(listFirst(cgi.SCRIPT_NAME,'/'))>


		<cfquery name="qValidateLoadData" datasource="#local.dsn#">
			SELECT L.LoadID FROM Loads L
			INNER JOIN CustomerOffices CO ON CO.CustomerID = L.CustomerID
			INNER JOIN Offices O ON O.OfficeID = CO.OfficeID
			WHERE O.CompanyID = <cfqueryparam value="#arguments.CompanyID#" cfsqltype="cf_sql_varchar">
			AND L.LoadID =  <cfqueryparam value="#arguments.LoadID#" cfsqltype="cf_sql_varchar">
		</cfquery> 
		<cfquery name="qCarrierData" datasource="#local.dsn#">
			SELECT CarrierID,EmailID,phone,PhoneExt,fax,FaxExt,TollFree,TollfreeExt,Cel,CellPhoneExt FROM Carriers WHERE CompanyID = <cfqueryparam value="#arguments.CompanyID#" cfsqltype="cf_sql_varchar">
			AND CarrierID =  <cfqueryparam value="#arguments.CarrierID#" cfsqltype="cf_sql_varchar">
		</cfquery>

		<cfif qValidateLoadData.recordcount AND qCarrierData.recordcount>
			<cfquery name="qUpd" datasource="#local.dsn#">

				UPDATE LoadStops SET NewCarrierID = <cfqueryparam value="#arguments.carrierid#" cfsqltype="cf_sql_varchar">
				,CarrierEmailID = <cfqueryparam value="#qCarrierData.EmailID#" cfsqltype="cf_sql_varchar">
				,CarrierContactID = <cfqueryparam value="#arguments.carrierid#" cfsqltype="cf_sql_varchar">
				,CarrierPhoneNo = <cfqueryparam value="#qCarrierData.phone#" cfsqltype="cf_sql_varchar">
				,CarrierPhoneNoExt = <cfqueryparam value="#qCarrierData.PhoneExt#" cfsqltype="cf_sql_varchar">
				,CarrierFax = <cfqueryparam value="#qCarrierData.fax#" cfsqltype="cf_sql_varchar">
				,CarrierFaxExt = <cfqueryparam value="#qCarrierData.FaxExt#" cfsqltype="cf_sql_varchar">
				,CarrierTollFree = <cfqueryparam value="#qCarrierData.TollFree#" cfsqltype="cf_sql_varchar">
				,CarrierTollFreeExt = <cfqueryparam value="#qCarrierData.TollfreeExt#" cfsqltype="cf_sql_varchar">
				,CarrierCell = <cfqueryparam value="#qCarrierData.Cel#" cfsqltype="cf_sql_varchar">
				,CarrierCellExt = <cfqueryparam value="#qCarrierData.CellPhoneExt#" cfsqltype="cf_sql_varchar">
				WHERE LoadID =  <cfqueryparam value="#arguments.loadid#" cfsqltype="cf_sql_varchar">
				AND StopNo = <cfqueryparam value="#arguments.StopNo#" cfsqltype="cf_sql_integer">

				<cfif arguments.StopNo EQ 0>
					UPDATE Loads SET carrierid = <cfqueryparam value="#arguments.carrierid#" cfsqltype="cf_sql_varchar">
					WHERE LoadID =  <cfqueryparam value="#arguments.loadid#" cfsqltype="cf_sql_varchar">
				</cfif>
			</cfquery>
		</cfif>
	</cffunction>

	<cffunction name="getGLFinancialSetup" access="public" output="false" returntype="query">
		<cfquery name="qGLFinancialSetup" datasource="#Application.dsn#">
			SELECT 
				*
		  	FROM [LMA General Ledger Income Statement Setup]
		  	WHERE CompanyID = <cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar">
		  	order by MainSort,subsort
		</cfquery>
		<cfreturn qGLFinancialSetup>
	</cffunction>

	<cffunction name="setGLFinancialSetup" access="remote" output="yes" returnformat="plain">
		<cfargument name="dsn" type="string" required="yes" />
		<cfargument name="fieldName" type="string" required="yes" />
		<cfargument name="id" type="string" required="yes" />
		<cfargument name="value" type="string" required="yes" />
		<cfargument name="companyid" type="string" required="yes" />
		<cftransaction>
			<cfif arguments.id eq 0>
				<cfquery name="qIns" datasource="#arguments.dsn#" result="qGLFinancialSetup">
					INSERT INTO [dbo].[LMA General Ledger Income Statement Setup]
				           (
				           	[ProfitType]
				           	,[CompanyID]
				           )
				    VALUES
				           ('Gross Profit','#arguments.companyid#')
				</cfquery>
				<cfset arguments.id = qGLFinancialSetup.GENERATEDKEY>
			</cfif>
			<cfquery name="qUpd" datasource="#arguments.dsn#">
				UPDATE [LMA General Ledger Income Statement Setup] SET [#arguments.fieldName#] = 
				<cfif listFindNoCase("ProfitType,MainTitle,SubTitle,LAcctFrom,GLAcctTo", arguments.fieldName)>
					<cfqueryparam value="#arguments.value#" cfsqltype="cf_sql_varchar">
				<cfelse>
					<cfqueryparam value="#arguments.value#" cfsqltype="cf_sql_float">
				</cfif>
				WHERE ID = <cfqueryparam value="#arguments.id#" cfsqltype="cf_sql_integer">
			</cfquery>
		</cftransaction>
		<cfreturn arguments.id>
	</cffunction>

	<cffunction name="deleteGLFinancialSetup" access="remote" output="yes" returnformat="plain">
		<cfargument name="dsn" type="string" required="yes" />
		<cfargument name="id" type="string" required="yes" />

		<cfquery name="qDel" datasource="#arguments.dsn#">
			DELETE FROM [LMA General Ledger Income Statement Setup]WHERE ID = <cfqueryparam value="#arguments.id#" cfsqltype="cf_sql_integer"> 
		</cfquery>

		<cfreturn 1>
	</cffunction>

	<cffunction name="getGLBalanceSheetSetup" access="public" output="false" returntype="query">
		<cfquery name="qGLBalanceSheetSetup" datasource="#Application.dsn#">
			SELECT 
				*
		  	FROM [LMA General Ledger Balance Sheet Setup] WHERE CompanyID = <cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar"> 
		  	order by MainSort,subsort
		</cfquery>
		<cfreturn qGLBalanceSheetSetup>
	</cffunction>

	<cffunction name="setGLBalanceSheetSetup" access="remote" output="yes" returnformat="plain">
		<cfargument name="dsn" type="string" required="yes" />
		<cfargument name="fieldName" type="string" required="yes" />
		<cfargument name="id" type="string" required="yes" />
		<cfargument name="value" type="string" required="yes" />
		<cfargument name="companyid" type="string" required="yes" />
		<cftransaction>
			<cfif arguments.id eq 0>
				<cfquery name="qIns" datasource="#arguments.dsn#" result="qGLBalanceSheetSetup">
					INSERT INTO [dbo].[LMA General Ledger Balance Sheet Setup]
				        (
				           	[ProfitType]
				           	,[CompanyID]
				        )
				    VALUES
				        ('Gross Profit','#arguments.companyid#')
				</cfquery>
				<cfset arguments.id = qGLBalanceSheetSetup.GENERATEDKEY>
			</cfif>
			<cfquery name="qUpd" datasource="#arguments.dsn#">
				UPDATE [LMA General Ledger Balance Sheet Setup] SET [#arguments.fieldName#] = 
				<cfif listFindNoCase("ProfitType,MainTitle,SubTitle,LAcctFrom,GLAcctTo", arguments.fieldName)>
					<cfqueryparam value="#arguments.value#" cfsqltype="cf_sql_varchar">
				<cfelse>
					<cfqueryparam value="#arguments.value#" cfsqltype="cf_sql_float">
				</cfif>
				WHERE ID = <cfqueryparam value="#arguments.id#" cfsqltype="cf_sql_integer">
			</cfquery>
		</cftransaction>
		<cfreturn arguments.id>
	</cffunction>

	<cffunction name="deleteGLBalanceSheetSetup" access="remote" output="yes" returnformat="plain">
		<cfargument name="dsn" type="string" required="yes" />
		<cfargument name="id" type="string" required="yes" />

		<cfquery name="qDel" datasource="#arguments.dsn#">
			DELETE FROM [LMA General Ledger Balance Sheet Setup] WHERE ID = <cfqueryparam value="#arguments.id#" cfsqltype="cf_sql_integer"> 
		</cfquery>

		<cfreturn 1>
	</cffunction>

	<cffunction name="getJournalEntries" access="public" output="false" returntype="query">
		<cfargument name="searchText" required="no" type="any">
	    <cfargument name="pageNo" required="no" type="any" default="1">
	    <cfargument name="sortorder" required="no" type="any" default="DESC">
	    <cfargument name="sortby" required="no" type="any" default="TH.Trans_date">

	    <cfquery name="qJournalEntries" datasource="#Application.dsn#">
	    	BEGIN WITH page AS 
	    	(SELECT 
				TH.*
				,ROW_NUMBER() OVER (ORDER BY #arguments.sortby# #arguments.sortorder#) AS Row
				FROM [LMA General Journal Transaction Header] TH
				WHERE CompanyID = <cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar">
	    	<cfif structKeyExists(arguments, "searchText") and len(trim(arguments.searchText))>
			    AND TH.Trans_number LIKE <cfqueryparam value="%#arguments.searchText#%" cfsqltype="cf_sql_varchar">
		    </cfif>
		    )
		    SELECT
		      *,(select (max(row)/30) + (CASE WHEN max(row)%30 <> 0 THEN 1 ELSE 0 END)  FROM page) AS TotalPages 
		    FROM page
		    WHERE Row BETWEEN (#arguments.pageNo# - 1) * 30 + 1 AND #arguments.pageNo# * 30
		    END
		</cfquery>

		<cfreturn qJournalEntries>
	</cffunction>

	<cffunction name="getJournalEntry" access="public" output="false" returntype="query">
		<cfargument name="Trans_Number" required="yes" type="any">
		<cfquery name="qJournalEntry" datasource="#Application.dsn#">
			SELECT 
			H.Trans_Number,
			H.Type,
			H.Trans_Date,
			H.Cust_Vend_Code,
			H.EnteredBy,
			F.ID,
			F.Date,
			F.[GJL Account Number] AS GJLAccountNumber,
			F.Description,
			F.[D/C] AS DC,
			ISNULL(F.Amount,0) AS Amount,
			ISNULL(F.Debit,0) AS Debit,
			ISNULL(F.Credit,0) AS Credit
			FROM [LMA General Journal Transaction Header] H 
			INNER JOIN [LMA General Journal Transaction Footer] F ON H.Trans_Number = F.[GJL Transaction Number] 
			WHERE H.Trans_Number = <cfqueryparam value="#arguments.Trans_Number#" cfsqltype="cf_sql_float">
			AND H.CompanyID = <cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar"> 
		</cfquery>
		<cfreturn qJournalEntry>
	</cffunction>

	<cffunction name="setJournalEntry" access="remote" output="yes" returntype="struct" returnformat="json">
		<cfargument name="dsn" type="string" required="yes" />
		<cfargument name="fieldName" type="string" required="yes" />
		<cfargument name="id" type="string" required="yes" />
		<cfargument name="value" type="string" required="yes" />
		<cfargument name="trans_number" type="string" required="yes" />
		<cfargument name="companyid" type="string" required="yes" />
		<cfargument name="EnteredBy" type="string" required="yes" />
		<cfargument name="debit_credit" type="string" required="no" default=""/>
		<cfargument name="amount" type="string" required="no" default=""/>
		<cftry>
		<cftransaction>
			<cfquery name="qGetTransNumberCheck" datasource="#arguments.dsn#">
				SELECT COUNT(trans_number) AS Count FROM [LMA General Journal Transaction Header] WHERE CompanyID = <cfqueryparam value="#arguments.CompanyID#" cfsqltype="cf_sql_varchar">
					AND trans_number = <cfqueryparam value="#arguments.trans_number#" cfsqltype="cf_sql_float">
			</cfquery>

			<cfif NOT qGetTransNumberCheck.Count>

				<cfquery name="qIns" datasource="#arguments.dsn#">
					INSERT INTO [dbo].[LMA General Journal Transaction Header]
				           (
				           	trans_number,
				           	type,
				           	CompanyID,
				           	EnteredBy
				           )
				    VALUES
				           (
				           	'#arguments.trans_number#',
				           	'GJ',
				           	<cfqueryparam value="#arguments.CompanyID#" cfsqltype="cf_sql_varchar">,
				           	<cfqueryparam value="#arguments.EnteredBy#" cfsqltype="cf_sql_varchar">
				           	)
				</cfquery>

			</cfif>
			
			<cfif arguments.id eq 0>
				<cfquery name="qIns" datasource="#arguments.dsn#" result="qJournalEntry">
					INSERT INTO [dbo].[LMA General Journal Transaction Footer]
				           (
				           	[GJL Transaction Number]
				           	,[Date]
				           	,CompanyID
				           	,EnteredBy
				           )
				    VALUES
				           ('#arguments.trans_number#',GETDATE(),<cfqueryparam value="#arguments.CompanyID#" cfsqltype="cf_sql_varchar">,<cfqueryparam value="#arguments.EnteredBy#" cfsqltype="cf_sql_varchar">)
				</cfquery>
				<cfset arguments.id = qJournalEntry.GENERATEDKEY>
			</cfif>
			<cfquery name="qUpd" datasource="#arguments.dsn#">
				UPDATE [LMA General Journal Transaction Footer] SET [#arguments.fieldName#] = 
				<cfif arguments.fieldName EQ 'Date'>
					<cfqueryparam value="#arguments.value#" cfsqltype="cf_sql_date">
				<cfelseif listFindNoCase("GJL Account Number,Description,D/C", arguments.fieldName)>
					<cfqueryparam value="#arguments.value#" cfsqltype="cf_sql_varchar">
				<cfelse>
					<cfqueryparam value="#replaceNoCase(replaceNoCase(arguments.value,'$',''),',','','ALL')#" cfsqltype="cf_sql_money">
				</cfif>

				<cfif arguments.fieldName EQ 'GJL Account Number'>
					,Description = (SELECT DESCRIPTION FROM [LMA General Ledger Chart of Accounts] WHERE GL_ACCT = <cfqueryparam value="#arguments.value#" cfsqltype="cf_sql_varchar">  AND CompanyID = <cfqueryparam value="#arguments.CompanyID#" cfsqltype="cf_sql_varchar">)
				</cfif>

				<cfif arguments.fieldName NEQ 'D/C'>
					<cfif structKeyExists(arguments, "debit_credit") AND len(trim(arguments.debit_credit))>
						,[D/C] = <cfqueryparam value="#arguments.debit_credit#" cfsqltype="cf_sql_varchar">
					</cfif>
				</cfif>

				
				<cfif structKeyExists(arguments, "amount") AND len(trim(arguments.amount))>
					<cfif arguments.fieldName NEQ 'Amount'>
						,amount= <cfqueryparam value="#replaceNoCase(replaceNoCase(arguments.amount,'$',''),',','','ALL')#" cfsqltype="cf_sql_money">
					</cfif>
					<cfif structKeyExists(arguments, "debit_credit") AND len(trim(arguments.debit_credit))>
						<cfif trim(arguments.debit_credit) EQ 'D'>
							,debit = <cfqueryparam value="#replaceNoCase(replaceNoCase(arguments.amount,'$',''),',','','ALL')#" cfsqltype="cf_sql_money">
							,credit = <cfqueryparam value="" cfsqltype="cf_sql_money" null="true">
						<cfelse>
							,credit = <cfqueryparam value="#replaceNoCase(replaceNoCase(arguments.amount,'$',''),',','','ALL')#" cfsqltype="cf_sql_money">
							,debit = <cfqueryparam value="" cfsqltype="cf_sql_money" null="true">
						</cfif>
					</cfif>
				</cfif>
				

				WHERE ID = <cfqueryparam value="#arguments.id#" cfsqltype="cf_sql_integer">
			</cfquery>
		</cftransaction>
		<cfset resp = structNew()>
		<cfset resp.trans_number = arguments.trans_number>
		<cfset resp.id = arguments.id>
		<cfreturn resp>
		<cfcatch>
			<cfdump var="#cfcatch#"><cfabort>
		</cfcatch>
		</cftry>
	</cffunction>

	<cffunction name="deleteJournalEntry" access="remote" output="yes" returnformat="plain">
		<cfargument name="dsn" type="string" required="yes" />
		<cfargument name="id" type="string" required="yes" />

		<cfquery name="qDel" datasource="#arguments.dsn#">
			DELETE FROM [LMA General Journal Transaction Footer] WHERE ID = <cfqueryparam value="#arguments.id#" cfsqltype="cf_sql_integer"> 
		</cfquery>

		<cfreturn 1>
	</cffunction>

	<cffunction name="check_fiscal" access="public" returntype="struct" returnformat="json">
		<cfargument name="Trans_Date" required="yes" type="string">

		<cfquery name="qLMASystemConfig" datasource="#Application.dsn#">
			SELECT [Fiscal Year] FROM [LMA System Config] WHERE CompanyID = <cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar">
		</cfquery>
		<cfset FiscalYear = qLMASystemConfig['Fiscal Year']>
		<cfset year_past = 0>
	    <cfif len(trim(FiscalYear))>
			<cfset FiscalYearStart = Dateadd("yyyy",-2,FiscalYear)>
			<cfset FiscalYearEnd= DateAdd("d", -1, DateAdd("yyyy", 1, FiscalYear))>
			<cfif (dateCompare(arguments.Trans_Date, FiscalYearStart) NEQ -1) AND
			(dateCompare(arguments.Trans_Date, FiscalYearEnd) NEQ 1)>
				<cfif dateCompare(arguments.Trans_Date, FiscalYear) LT 0>
					<cfset year_past = 1>
				</cfif>

				<cfif dateCompare(arguments.Trans_Date, Dateadd("yyyy",-1,FiscalYear)) LT 0>
					<cfset year_past = 2>
				</cfif>

				<cfset respStr = structNew()>
		    	<cfset respStr.res = 'success'>
		    	<cfset respStr.year_past = year_past>
		    	<cfreturn respStr>
			<cfelse>
				<cfset respStr = structNew()>
		    	<cfset respStr.res = 'error'>
		    	<cfset respStr.msg = 'The transaction date of #dateformat(arguments.Trans_Date,'mm/dd/yyyy')# does not fall within the current fiscal year #dateformat(FiscalYear,'mm/dd/yyyy')# and within the 2 prior years. Please correct the date and try again.'>
		    	<cfreturn respStr>
			</cfif>
	    <cfelse>
	    	<cfset respStr = structNew()>
	    	<cfset respStr.res = 'error'>
	    	<cfset respStr.msg = 'Invalid Fiscal Year. Please check System Settings.'>
	    	<cfreturn respStr>
	    </cfif>
	</cffunction>


	<cffunction name="PostJournal" access="public" returntype="struct" returnformat="json">
    	<cfargument name="frmStruct" required="no" type="struct">
    	<cftransaction>
    		<cftry>
	    		<cfquery name="qJournalEntry" datasource="#Application.dsn#">
	    			SELECT 
					H.Trans_Number,
					H.Trans_Date,
					F.Description,
					H.Cust_Vend_Code,
					F.[GJL Account Number] AS GJLAccountNumber,
					F.[D/C] AS DC,
					ISNULL(F.Debit,0) AS Debit,
					ISNULL(F.Credit,0) AS Credit
					FROM [LMA General Journal Transaction Header] H 
					INNER JOIN [LMA General Journal Transaction Footer] F ON H.Trans_Number = F.[GJL Transaction Number] 
					WHERE H.Trans_Number = <cfqueryparam value="#arguments.frmStruct.Trans_Number#" cfsqltype="cf_sql_float">
					AND H.CompanyID = <cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar">
					AND ISNULL(F.Amount,0) <> 0
	    		</cfquery>

	    		<cfset local.check_fiscal = check_fiscal(qJournalEntry.Trans_Date)>

	    		<cfif local.check_fiscal.res eq "error">
	    			<cfreturn local.check_fiscal>
	    		<cfelse>
	    			<cfset year_past = local.check_fiscal.year_past>
	    		</cfif>

	    		<cfset local.intPostedAmount = 0>
	    		<cfloop query="qJournalEntry">
        			<cfif qJournalEntry.DC EQ 'D'>
        				<cfset post_amt = qJournalEntry.debit>
	    				<cfset local.intPostedAmount = local.intPostedAmount + post_amt>
	    			<cfelse>
	    				<cfset post_amt = -1*qJournalEntry.credit>
	    				<cfset local.intPostedAmount = local.intPostedAmount + post_amt>
	    			</cfif>
	    			<cfinvoke method="PostToGL" returnvariable="qPostToGL" account="#qJournalEntry.GJLAccountNumber#" cv_code="#qJournalEntry.Cust_Vend_Code#" year_past="#year_past#" post_amt="#post_amt#" Invoice_Code="#arguments.frmStruct.Trans_Number#" tran_type="#arguments.frmStruct.Type#" tran_desc="#qJournalEntry.Description#" tran_date="#qJournalEntry.Trans_Date#" module="GL"/>
	    		</cfloop>

	    		<cfquery name="qDel" datasource="#Application.dsn#">
					DELETE FROM [LMA General Journal Transaction Footer] WHERE [GJL Transaction Number] = <cfqueryparam value="#arguments.frmStruct.Trans_Number#" cfsqltype="cf_sql_float"> 
					DELETE FROM [LMA General Journal Transaction Header] WHERE Trans_Number = <cfqueryparam value="#arguments.frmStruct.Trans_Number#" cfsqltype="cf_sql_float">
				</cfquery>
	    		<cfif local.intPostedAmount NEQ 0>
	    		    <cftransaction action="rollback">
		    		<cfset respStr = structNew()>
			    	<cfset respStr.res = 'error'>
			    	<cfset respStr.msg = "This transaction is out of balance by #DollarFormat(local.intPostedAmount)#. Please fix this and try again.">
		    		<cfset respStr.frmstruct = arguments.frmstruct>
			    	<cfreturn respStr>
		    	</cfif>
		    	<cfset respStr = structNew()>
		    	<cfset respStr.res = 'success'>
		    	<cfset respStr.msg = "Journal Posted successfully.">
		    	<cfreturn respStr>
		    	<cfcatch>
		    	 	<cftransaction action="rollback">
		    		<cfset respStr = structNew()>
			    	<cfset respStr.res = 'error'>
			    	<cfset respStr.msg = "Something went wrong. Unable to post Journal.">
			    	<cfreturn respStr>
		    	</cfcatch>
	    	</cftry>
    	</cftransaction>
    </cffunction>

    <cffunction name="setJournalEntryHeader" access="remote" output="yes" returnformat="plain">
		<cfargument name="dsn" type="string" required="yes" />
		<cfargument name="fieldName" type="string" required="yes" />
		<cfargument name="value" type="string" required="yes" />
		<cfargument name="trans_number" type="string" required="yes" />
		<cfargument name="EnteredBy" type="string" required="yes" />
		<cfargument name="companyid" type="string" required="yes" />
		<cftransaction>
			<cfquery name="qGetTransNumberCheck" datasource="#arguments.dsn#">
				SELECT COUNT(trans_number) AS Count FROM [LMA General Journal Transaction Header] WHERE CompanyID = <cfqueryparam value="#arguments.CompanyID#" cfsqltype="cf_sql_varchar">
					AND trans_number = <cfqueryparam value="#arguments.trans_number#" cfsqltype="cf_sql_float">
			</cfquery>

			<cfif NOT qGetTransNumberCheck.Count>

				<cfquery name="qIns" datasource="#arguments.dsn#">
					INSERT INTO [dbo].[LMA General Journal Transaction Header]
				           (
				           	trans_number,
				           	type,
				           	CompanyID,
				           	EnteredBy
				           )
				    VALUES
				           (
				           	'#arguments.trans_number#',
				           	'GJ',
				           	<cfqueryparam value="#arguments.CompanyID#" cfsqltype="cf_sql_varchar">,
				           	<cfqueryparam value="#arguments.EnteredBy#" cfsqltype="cf_sql_varchar">
				           	)
				</cfquery>

			</cfif>
			<cfquery name="qUpd" datasource="#arguments.dsn#">
				UPDATE [LMA General Journal Transaction Header] SET [#arguments.fieldName#] = 
				<cfif arguments.fieldName EQ 'Trans_Date'>
					<cfqueryparam value="#arguments.value#" cfsqltype="cf_sql_date">
				<cfelse>
					<cfqueryparam value="#arguments.value#" cfsqltype="cf_sql_varchar">
				</cfif>
				WHERE trans_number = <cfqueryparam value="#arguments.trans_number#" cfsqltype="cf_sql_float">
			</cfquery>
		</cftransaction>
		<cfreturn INT(arguments.trans_number)>
	</cffunction>

	<cffunction name="deleteJournal" access="public" output="yes" returnformat="plain">
		<cfargument name="Trans_Number" type="string" required="yes" />

		<cfquery name="qDel" datasource="#Application.dsn#">
			DELETE FROM [LMA General Journal Transaction Footer] WHERE [GJL Transaction Number] = <cfqueryparam value="#arguments.Trans_Number#" cfsqltype="cf_sql_float"> 
			DELETE FROM [LMA General Journal Transaction Header] WHERE Trans_Number = <cfqueryparam value="#arguments.Trans_Number#" cfsqltype="cf_sql_float">
		</cfquery>

		<cfset respStr = structNew()>
    	<cfset respStr.res = 'success'>
    	<cfset respStr.msg = "Journal Deleted Successfully.">
    	<cfreturn respStr>

	</cffunction>

	<cffunction name="getReverseJournalEntry" access="public" output="false" returntype="query">
		<cfargument name="Trans_Number" required="yes" type="any">
		<cfquery name="qJournalEntry" datasource="#Application.dsn#">
			SELECT 
			GL.[Invoice Code] AS Trans_Number,
			'GJ' AS Type,
			GL.[Date] AS Trans_Date,
			GL.Code AS Cust_Vend_Code,
			GL.EnteredBy,
			GL.ID,
			GL.Date,
			GL.[GL Account] AS GJLAccountNumber,
			GL.Description,
			GL.[D/C] AS DC,
			ISNULL(GL.Amount,0) AS Amount,
			ISNULL(GL.DAmount,0) AS Debit,
			ISNULL(GL.CAmount,0) AS Credit
			FROM [LMA General Ledger Transactions] GL
			WHERE GL.[Invoice Code] = <cfqueryparam value="#arguments.Trans_Number#" cfsqltype="cf_sql_varchar">
			AND CompanyID =  <cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar">
		</cfquery>
		<cfreturn qJournalEntry>
	</cffunction>

	<cffunction name="ReverseJournal" access="public" returntype="struct" returnformat="JSON">
    	<cfargument name="frmStruct" required="no" type="struct">

    	<cftransaction>
    		<cfquery name="qGetTransNumber"  datasource="#Application.dsn#">
				SELECT ISNULL(MAX(Trans_Number),1000)+1 AS trans_number FROM [LMA General Journal Transaction Header]
			</cfquery>
    		<cfquery name="qIns" datasource="#Application.dsn#">
				INSERT INTO [dbo].[LMA General Journal Transaction Header]
		           (
		           	trans_number,
		           	trans_date,
		           	type,
		           	Cust_Vend_Code,
		           	EnteredBy,
		           	CompanyID
		           )
			    VALUES
		           (
		           	'#qGetTransNumber.trans_number#',
		           	<cfqueryparam value="#arguments.frmStruct.trans_date#" cfsqltype="cf_sql_date">,
		           	<cfqueryparam value="#arguments.frmStruct.type#" cfsqltype="cf_sql_varchar">,
		           	<cfqueryparam value="#arguments.frmStruct.Cust_Vend_Code#" cfsqltype="cf_sql_varchar">,
		           	<cfqueryparam value="#session.adminusername#" cfsqltype="cf_sql_varchar">,
		           	<cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar">
		           	)
			</cfquery>
			<cfset debitTotal = 0>
    		<cfset creditTotal = 0>
    		<cfloop from="1" to="#arguments.frmStruct.totalrows#" index="i">
    			<cfset local.GLACCT = evaluate("arguments.frmStruct.GLACCT_#i#")>
    			<cfset local.Description = evaluate("arguments.frmStruct.Description_#i#")>
    			<cfset local.CreditDebit = evaluate("arguments.frmStruct.CreditDebit_#i#")>
    			<cfset local.Amount = evaluate("arguments.frmStruct.Amount_#i#")>
    			<cfset local.Debit = evaluate("arguments.frmStruct.Debit_#i#")>
    			<cfset local.Credit = evaluate("arguments.frmStruct.Credit_#i#")>
    			<cfset local.Date = evaluate("arguments.frmStruct.Date_#i#")>
    			<cfif local.creditdebit EQ 'D'>
    				<cfset local.debitTotal = local.debitTotal + replaceNoCase(replaceNoCase(local.Amount,'$',''),',','','ALL')>
    			<cfelse>
    				<cfset local.creditTotal = local.creditTotal + replaceNoCase(replaceNoCase(local.Amount,'$',''),',','','ALL')>
    			</cfif>
    			<cfquery name="qIns" datasource="#Application.dsn#" result="qJournalEntry">
					INSERT INTO [dbo].[LMA General Journal Transaction Footer]
				           (
				           	[GJL Transaction Number]
				           	,[GJL Account Number]
				           	,Description
				           	,[D/C]
				           	,Amount
				           	,Debit
				           	,Credit
				           	,EnteredBy
				           	,[Date]
				           	,CompanyID
				           )
				    VALUES
				           ('#qGetTransNumber.trans_number#',
				          	<cfqueryparam value="#local.GLACCT#" cfsqltype="cf_sql_varchar">,
				          	<cfqueryparam value="#local.Description#" cfsqltype="cf_sql_varchar">,
				          	<cfqueryparam value="#local.CreditDebit#" cfsqltype="cf_sql_varchar">,
				          	<cfqueryparam value="#replaceNoCase(replaceNoCase(local.Amount,'$',''),',','','ALL')#" cfsqltype="cf_sql_money">,
				          	<cfqueryparam value="#replaceNoCase(replaceNoCase(local.Debit,'$',''),',','','ALL')#" cfsqltype="cf_sql_money">,
				          	<cfqueryparam value="#replaceNoCase(replaceNoCase(local.Credit,'$',''),',','','ALL')#" cfsqltype="cf_sql_money">,
				          	<cfqueryparam value="#session.adminusername#" cfsqltype="cf_sql_varchar">,
				          	<cfqueryparam value="#local.date#" cfsqltype="cf_sql_date">,
				          	<cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar">
				           	)
				</cfquery>
    		</cfloop>
    		<cfif local.debitTotal NEQ local.creditTotal>
				<cftransaction action="rollback">
				<cfset respStr = structNew()>
		    	<cfset respStr.res = 'error'>
		    	<cfset respStr.msg = "Unable to create invoice. Credit and Debit are not in balance.">
		    	<cfreturn respStr>
			</cfif>
    	</cftransaction>
    	<cfset respStr = structNew()>
    	<cfset respStr.res = 'success'>
    	<cfset respStr.msg = qGetTransNumber.trans_number>
    	<cfreturn respStr>
    </cffunction>

    <cffunction name="getNextGJNumber" access="public" returntype="string">
    	<cfquery name="qgetNextGJNumber" datasource="#variables.dsn#">
    		select ISNULL([Next GJ Number],1) AS Trans_Number from [LMA System Config] WHERE CompanyID = <cfqueryparam value="#session.companyid#" cfsqltype="cf_sql_varchar">
    	</cfquery>

    	<cfquery name="updNextGJNumber" datasource="#variables.dsn#">
    		UPDATE [LMA System Config] SET [Next GJ Number] = ISNULL([Next GJ Number],1)+1 WHERE CompanyID = <cfqueryparam value="#session.companyid#" cfsqltype="cf_sql_varchar">
    	</cfquery>


    	<cfreturn qgetNextGJNumber.Trans_Number>
    </cffunction>

    <cffunction name="checkCOAAcctExists" access="remote" output="yes" returntype="boolean" returnFormat="plain">
    	<cfargument name="GL_ACCT" type="string" default="">
	    <cfargument name="CompanyID" type="string" default="">
	    <cfargument name="dsn" type="string" default="">

	    <cfquery name="qCheck" datasource="#arguments.dsn#" result="result">
	      select count(ID) AS ID_COUNT from [LMA General Ledger Chart of Accounts]
	      where GL_ACCT = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.GL_ACCT#">
	      and companyid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.CompanyID#">
	    </cfquery>

	    <cfreturn qCheck.ID_COUNT>
  </cffunction>

  	<cffunction name="saveChartOfAccounts" access="public" returntype="string">
    	<cfargument name="frmStruct" required="no" type="struct">

    	<cfif arguments.frmStruct.ID EQ 0 OR structKeyExists(arguments.frmStruct, "saveDept")>
	    	<cfquery name="qIns" datasource="#variables.dsn#" result="insCOA">
	    		INSERT INTO [LMA General Ledger Chart of Accounts] 
		    		([GL_ACCT]
		           ,[Description]
		           ,[TYPE_CODE]
		           ,[TYPE_DESCRIPTION]
		           ,[CREDIT_DEBIT]
		           ,[NON_CASH]
		           ,[OPEN_CURRENT]
		           ,[JAN_CURRENT]
		           ,[FEB_CURRENT]
		           ,[MAR_CURRENT]
		           ,[APR_CURRENT]
		           ,[MAY_CURRENT]
		           ,[JUN_CURRENT]
		           ,[JUL_CURRENT]
		           ,[AUG_CURRENT]
		           ,[SEP_CURRENT]
		           ,[OCT_CURRENT]
		           ,[NOV_CURRENT]
		           ,[DEC_CURRENT]
		           ,[END_CURRENT]
		           ,[OPEN_1YR]
		           ,[JAN_1YR]
		           ,[FEB_1YR]
		           ,[MAR_1YR]
		           ,[APR_1YR]
		           ,[MAY_1YR]
		           ,[JUN_1YR]
		           ,[JUL_1YR]
		           ,[AUG_1YR]
		           ,[SEP_1YR]
		           ,[OCT_1YR]
		           ,[NOV_1YR]
		           ,[DEC_1YR]
		           ,[END_1YR]
		           ,[OPEN_2YR]
		           ,[JAN_2YR]
		           ,[FEB_2YR]
		           ,[MAR_2YR]
		           ,[APR_2YR]
		           ,[MAY_2YR]
		           ,[JUN_2YR]
		           ,[JUL_2YR]
		           ,[AUG_2YR]
		           ,[SEP_2YR]
		           ,[OCT_2YR]
		           ,[NOV_2YR]
		           ,[DEC_2YR]
		           ,[END_2YR]
		           ,[OPEN_BUDGET]
		           ,[JAN_BUDGET]
		           ,[FEB_BUDGET]
		           ,[MAR_BUDGET]
		           ,[APR_BUDGET]
		           ,[MAY_BUDGET]
		           ,[JUN_BUDGET]
		           ,[JUL_BUDGET]
		           ,[AUG_BUDGET]
		           ,[SEP_BUDGET]
		           ,[OCT_BUDGET]
		           ,[NOV_BUDGET]
		           ,[DEC_BUDGET]
		           ,[END_BUDGET]
		           ,[CompanyID])
	    		VALUES(
	    			<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.frmStruct.GL_ACCT#">,
	    			<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.frmStruct.Description#">,
	    			<cfqueryparam cfsqltype="cf_sql_varchar" value="#Left(arguments.frmStruct.Type,1)#">,
	    			<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.frmStruct.Type#">,
	    			<cfif structKeyExists(arguments.frmStruct, 'CREDIT_DEBIT')>
	    				<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.frmStruct.CREDIT_DEBIT#">,
	    			<cfelse>
	    				NULL,
	    			</cfif>
	    			'N'
					,0
					,0
					,0
					,0
					,0
					,0
					,0
					,0
					,0
					,0
					,0
					,0
					,0
					,0
					,0
					,0
					,0
					,0
					,0
					,0
					,0
					,0
					,0
					,0
					,0
					,0
					,0
					,0
					,0
					,0
					,0
					,0
					,0
					,0
					,0
					,0
					,0
					,0
					,0
					,0
					,0
					,0
					,0
					,0
					,0
					,0
					,0
					,0
					,0
					,0
					,0
					,0
					,0
					,0
					,0
					,0
	    			,<cfqueryparam cfsqltype="cf_sql_varchar" value="#session.CompanyID#">
	    			)
	    	</cfquery>
	    	<cfset arguments.frmStruct.ID = insCOA.GENERATEDKEY>
	    <cfelse>
		    <cfquery name="qUpd" datasource="#variables.dsn#">
		    UPDATE [LMA General Ledger Chart of Accounts]  
		    SET 
			[Description] = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.frmStruct.Description#">
			,[TYPE_CODE] = <cfqueryparam cfsqltype="cf_sql_varchar" value="#Left(arguments.frmStruct.Type,1)#">
			,[TYPE_DESCRIPTION] = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.frmStruct.Type#">
			,[OPEN_BUDGET] = <cfqueryparam value="#replaceNoCase(replaceNoCase(arguments.frmStruct.OPEN_BUDGET,'$',''),',','','ALL')#" cfsqltype="cf_sql_float">
			,[JAN_BUDGET] = <cfqueryparam value="#replaceNoCase(replaceNoCase(arguments.frmStruct.JAN_BUDGET,'$',''),',','','ALL')#" cfsqltype="cf_sql_float">
			,[FEB_BUDGET] = <cfqueryparam value="#replaceNoCase(replaceNoCase(arguments.frmStruct.FEB_BUDGET,'$',''),',','','ALL')#" cfsqltype="cf_sql_float">
			,[MAR_BUDGET] = <cfqueryparam value="#replaceNoCase(replaceNoCase(arguments.frmStruct.MAR_BUDGET,'$',''),',','','ALL')#" cfsqltype="cf_sql_float">
			,[APR_BUDGET] = <cfqueryparam value="#replaceNoCase(replaceNoCase(arguments.frmStruct.APR_BUDGET,'$',''),',','','ALL')#" cfsqltype="cf_sql_float">
			,[MAY_BUDGET] = <cfqueryparam value="#replaceNoCase(replaceNoCase(arguments.frmStruct.MAY_BUDGET,'$',''),',','','ALL')#" cfsqltype="cf_sql_float">
			,[JUN_BUDGET] = <cfqueryparam value="#replaceNoCase(replaceNoCase(arguments.frmStruct.JUN_BUDGET,'$',''),',','','ALL')#" cfsqltype="cf_sql_float">
			,[JUL_BUDGET] = <cfqueryparam value="#replaceNoCase(replaceNoCase(arguments.frmStruct.JUL_BUDGET,'$',''),',','','ALL')#" cfsqltype="cf_sql_float">
			,[AUG_BUDGET] = <cfqueryparam value="#replaceNoCase(replaceNoCase(arguments.frmStruct.AUG_BUDGET,'$',''),',','','ALL')#" cfsqltype="cf_sql_float">
			,[SEP_BUDGET] = <cfqueryparam value="#replaceNoCase(replaceNoCase(arguments.frmStruct.SEP_BUDGET,'$',''),',','','ALL')#" cfsqltype="cf_sql_float">
			,[OCT_BUDGET] = <cfqueryparam value="#replaceNoCase(replaceNoCase(arguments.frmStruct.OCT_BUDGET,'$',''),',','','ALL')#" cfsqltype="cf_sql_float">
			,[NOV_BUDGET] = <cfqueryparam value="#replaceNoCase(replaceNoCase(arguments.frmStruct.NOV_BUDGET,'$',''),',','','ALL')#" cfsqltype="cf_sql_float">
			,[DEC_BUDGET] = <cfqueryparam value="#replaceNoCase(replaceNoCase(arguments.frmStruct.DEC_BUDGET,'$',''),',','','ALL')#" cfsqltype="cf_sql_float">
			,[END_BUDGET] = <cfqueryparam value="#replaceNoCase(replaceNoCase(arguments.frmStruct.END_BUDGET,'$',''),',','','ALL')#" cfsqltype="cf_sql_float">
			WHERE ID = <cfqueryparam value="#arguments.frmStruct.id#" cfsqltype="CF_SQL_INTEGER"> 
		    </cfquery>
    	</cfif>
    	<cfreturn arguments.frmStruct.ID>
    </cffunction>

    <cffunction name="DeleteChartOfAccounts" access="public" returntype="string">
    	<cfargument name="ID" required="no" type="string">

    	<cfquery name="qDel" datasource="#variables.dsn#" result="insCOA">
    		DELETE FROM [LMA General Ledger Chart of Accounts] 
    		WHERE ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.ID#">
    	</cfquery>
    	<cfreturn "Deleted.">
    </cffunction>

    <cffunction name="getDeptList" access="public" returntype="query">
    	<cfquery name="qGetDeptList" datasource="#variables.dsn#">
    		select Dept,Description from [LMA General Ledger Dept]
    		WHERE CompanyID = <cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar"> 
    		ORDER BY Dept
    	</cfquery>
    	<cfreturn qGetDeptList>
    </cffunction>

    <cffunction name="SaveAccountDepartment" access="public" returntype="struct">
    	<cfargument name="frmStruct" required="no" type="struct">
    	<cftransaction>
    		<cftry>
		    	<cfif structKeyExists(arguments.frmStruct, "id") and not len(arguments.frmStruct.id)>
		    		<cfquery name="qInsDept" datasource="#variables.dsn#" result="insDept">
			    		INSERT INTO [dbo].[LMA General Ledger Dept]
				           ([CompanyID]
				           ,[Dept]
				           ,[Description]
				           ,[Created])
				        VALUES(
				        	<cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar"> 
				        	,<cfqueryparam value="#arguments.frmStruct.Dept#" cfsqltype="cf_sql_varchar">
				        	,<cfqueryparam value="#arguments.frmStruct.DeptDesc#" cfsqltype="cf_sql_varchar">
				        	,GETDATE()
				        	)
			        </cfquery>
			        <cfset arguments.frmStruct.id = insDept.GENERATEDKEY>
			    <cfelse>
			    	<cfquery name="qUpdDept" datasource="#variables.dsn#">
			    		UPDATE [dbo].[LMA General Ledger Dept] SET
			    		[Dept] = <cfqueryparam value="#arguments.frmStruct.Dept#" cfsqltype="cf_sql_varchar">
			    		,[Description] = <cfqueryparam value="#arguments.frmStruct.DeptDesc#" cfsqltype="cf_sql_varchar">
			    		WHERE id = <cfqueryparam value="#arguments.frmStruct.id#" cfsqltype="cf_sql_integer">
			    	</cfquery>
		    	</cfif>
		    	<cfset var respid = arguments.frmStruct.id>
		    	<cfif arguments.frmStruct.totalRows GT 0>
			    	<cfloop from="1" to="#arguments.frmStruct.totalRows#" index="i">
			    		<cfset arguments.frmStruct.GL_ACCT = evaluate("arguments.frmStruct.GLACCT_#i#") & "  " & Rjustify(arguments.frmStruct.Dept,4)>
			    		<cfquery name="qCheckAcctExists" datasource="#variables.dsn#">
				    		SELECT COUNT(id) as ID_COUNT FROM [LMA General Ledger Chart of Accounts] WHERE GL_ACCT 
				    		= <cfqueryparam value="#arguments.frmStruct.GL_ACCT#" cfsqltype="cf_sql_varchar"> 
				    		AND CompanyID = <cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar"> 
				    	</cfquery>

				    	<cfif qCheckAcctExists.ID_COUNT EQ 0>

				    		<cfquery name="qgetCreditDebit" datasource="#variables.dsn#">
				    			SELECT CREDIT_DEBIT,TYPE_DESCRIPTION FROM [LMA General Ledger Chart of Accounts] WHERE GL_ACCT = <cfqueryparam value="#evaluate("arguments.frmStruct.GLACCT_#i#")#" cfsqltype="cf_sql_varchar"> 
				    			AND CompanyID = <cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar"> 
				    		</cfquery>

				    		<cfif qgetCreditDebit.recordcount AND Len(Trim(qgetCreditDebit.CREDIT_DEBIT))>
				    			<cfset arguments.frmStruct.CREDIT_DEBIT = Trim(qgetCreditDebit.CREDIT_DEBIT)>
				    		</cfif>
				    		<cfif qgetCreditDebit.recordcount AND Len(Trim(qgetCreditDebit.TYPE_DESCRIPTION))>
				    			<cfset arguments.frmStruct.Type = Trim(qgetCreditDebit.TYPE_DESCRIPTION)>
				    		</cfif>

				    		<cfif structKeyExists(arguments.frmStruct, "addDeptDesc")>
				    			<cfset arguments.frmStruct.description = evaluate("arguments.frmStruct.description_#i#")&arguments.frmStruct.DescSep&arguments.frmStruct.DeptDesc>
				    		<cfelse>
				    			<cfset arguments.frmStruct.description = evaluate("arguments.frmStruct.description_#i#")>
				    		</cfif>
				    		<cfset arguments.frmStruct.saveDept = 1>
				    		<cfinvoke frmStruct="#arguments.frmStruct#" method="saveChartOfAccounts" returnvariable="resp"/>
				    	</cfif>

			    	</cfloop>
		    	</cfif>
		    	<cfset respStr = structNew()>
		    	<cfset respStr.res = 'success'>
		    	<cfset respStr.msg = 'Added successfully.'>
		    	<cfset respStr.id = respid >
		    	<cfreturn respStr>
		    	<cfcatch>
		    		<cfset respStr = structNew()>
			    	<cfset respStr.res = 'error'>
			    	<cfset respStr.msg = 'Something went wrong. Please try again later.'>
			    	<cfset respStr.id = 0 >
			    	<cfreturn respStr>
		    	</cfcatch>
	    	</cftry>
	    </cftransaction>
    </cffunction>

    <cffunction name="getLMADepartments" access="public" output="false" returntype="query">
		<cfargument name="searchText" required="no" type="any">
	    <cfargument name="pageNo" required="no" type="any" default="1">
	    <cfargument name="sortorder" required="no" type="any" default="ASC">
	    <cfargument name="sortby" required="no" type="any" default="Description">

	    <cfquery name="qDepartments" datasource="#Application.dsn#">
	    	BEGIN WITH page AS 
	    	(SELECT 
	    		ID,
	    		Dept,
				Description
				,ROW_NUMBER() OVER (ORDER BY #arguments.sortby# #arguments.sortorder#) AS Row
				FROM [LMA General Ledger Dept]
				WHERE CompanyID =  <cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar"> 
	    	<cfif structKeyExists(arguments, "searchText") and len(trim(arguments.searchText))>
			    AND (Description LIKE <cfqueryparam value="%#arguments.searchText#%" cfsqltype="cf_sql_varchar">
			    	OR Dept LIKE <cfqueryparam value="%#arguments.searchText#%" cfsqltype="cf_sql_varchar">
			    	)
		    </cfif>
		    )
		    SELECT
		      *,(select (max(row)/30) + (CASE WHEN max(row)%30 <> 0 THEN 1 ELSE 0 END)  FROM page) AS TotalPages 
		    FROM page
		    WHERE Row BETWEEN (#arguments.pageNo# - 1) * 30 + 1 AND #arguments.pageNo# * 30
		    END
		</cfquery>

		<cfreturn qDepartments>
	</cffunction>

	<cffunction name="getDeptDetails" access="public" output="false" returntype="query">
		<cfargument name="ID" required="yes" type="string">

	    <cfquery name="qDeptDetails" datasource="#Application.dsn#">
	    	SELECT 
			GLD.Dept,
			GLD.Description AS DeptDesc,
			COA.GL_ACCT,
			COA.Description
			FROM [LMA General Ledger Dept] GLD
			LEFT JOIN [LMA General Ledger Chart of Accounts] COA ON RIGHT(COA.gl_acct,4)  = gld.dept AND LEN(gl_acct) > 4
			WHERE GLD.ID = <cfqueryparam value="#arguments.ID#" cfsqltype="cf_sql_varchar"> 
			AND GLD.CompanyID = <cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar"> 
		</cfquery>

		<cfreturn qDeptDetails>
	</cffunction>

	<cffunction name="deleteAccountDepartment" access="public" returntype="string">
		<cfargument name="ID" required="no" type="any">
	    <cfquery name="qdelAccDept" datasource="#Application.dsn#">
	    	DELETE
	    	FROM [dbo].[LMA General Ledger Dept]
	    	WHERE ID = <cfqueryparam value="#arguments.ID#" cfsqltype="CF_SQL_INTEGER">
	    	AND CompanyID = <cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar"> 
		</cfquery>
		<cfreturn 'Department Deleted.'>
	</cffunction>

	<cffunction name="openNewYear" access="public" returntype="struct" returnformat="json">
	    <cftransaction>
		    <cftry>
		    	<CFSTOREDPROC PROCEDURE="GLCheckCurrentYearBalance" DATASOURCE="#variables.dsn#">
					<CFPROCPARAM VALUE="#session.CompanyID#" cfsqltype="CF_SQL_VARCHAR">
					<CFPROCRESULT NAME="qryResponse">
				</CFSTOREDPROC>

				<cfif qryResponse.status eq 0>
					<cfset respStr = structNew()>
			    	<cfset respStr.res = 'error'>
			    	<cfset respStr.msg = 'Unable to process Open new year procedures. Current year balance check failed.'>
			    	<cfreturn respStr>
				</cfif>


			    <CFSTOREDPROC PROCEDURE="OpenNewYear" DATASOURCE="#variables.dsn#">
					<CFPROCPARAM VALUE="#session.CompanyID#" cfsqltype="CF_SQL_VARCHAR">
					<CFPROCRESULT NAME="qryResponse">
				</CFSTOREDPROC>

				<cfif qryResponse.res eq 'error'>
					<cftransaction action="rollback">
				</cfif>

				<cfset respStr = structNew()>
		    	<cfset respStr.res = qryResponse.res>
		    	<cfset respStr.msg = qryResponse.msg>
		    	<cfreturn respStr>

		    	<cfcatch>
		    		<cftransaction action="rollback">
		    		<cfset respStr = structNew()>
			    	<cfset respStr.res = 'error'>
			    	<cfset respStr.msg = "Something went wrong. Unable to process Open new year procedures.">
			    	<cfreturn respStr>
		    	</cfcatch>
		    </cftry>
	    </cftransaction>
	    
	</cffunction>

	<cffunction name="checkDOT_MC" access="public" returntype="query">
		<cfargument name="McNumber" required="no" type="any">
	    <cfquery name="qDOT_MC" datasource="ZFMCSA">
	    	select * from MC_DOT where MC = <cfqueryparam value="#arguments.McNumber#" cfsqltype="cf_sql_varchar">
	    </cfquery>
	    <cfreturn qDOT_MC>
	</cffunction>

	<cffunction name="GLRecalculate" access="public" returntype="struct" returnformat="json">
		<cfargument name="Year" required="yes" type="numeric">
	    <cftransaction>
		    <cftry>

			    <CFSTOREDPROC PROCEDURE="GLRecalculate" DATASOURCE="#variables.dsn#">
					<CFPROCPARAM VALUE="#session.CompanyID#" cfsqltype="CF_SQL_VARCHAR">
					<CFPROCPARAM VALUE="#arguments.Year#" cfsqltype="CF_SQL_VARCHAR">
					<CFPROCRESULT NAME="qryResponse">
				</CFSTOREDPROC>

				<cfif qryResponse.res eq 'error'>
					<cftransaction action="rollback">
				</cfif>

				<cfset respStr = structNew()>
		    	<cfset respStr.res = qryResponse.res>
		    	<cfset respStr.msg = qryResponse.msg>
		    	<cfreturn respStr>

		    	<cfcatch>
		    		<cftransaction action="rollback">
		    		<cfset respStr = structNew()>
			    	<cfset respStr.res = 'error'>
			    	<cfset respStr.msg = "Something went wrong. Unable to recalculate.">
			    	<cfreturn respStr>
		    	</cfcatch>
		    </cftry>
	    </cftransaction>
	    
	</cffunction>

	<cffunction name="getCustomerOpenInvoices" access="public" returntype="query">
		<cfargument name="CustomerID" required="yes" type="string">
		<cfargument name="HistoryInvoices" required="no" type="boolean" default="0">
	    <cfquery name="qOpenInvoices" datasource="#variables.dsn#">
	    	SELECT 
				ART.TRANS_NUMBER,
				ART.LoadID,
				(SELECT BOLNum FROM Loads WHERE LoadID = ART.LoadID) AS BOL,
				ART.date AS InvoiceDate,
				(SELECT CustomerPONo FROM Loads WHERE LoadID = ART.LoadID) AS PO,
				(SELECT BillDate FROM Loads WHERE LoadID = ART.LoadID) AS OrderDate,
				ART.Total,
				ART.Balance,
				ART.Notes
				FROM [LMA Accounts Receivable Transactions] ART
				WHERE ART.CustomerID = <cfqueryparam value="#arguments.CustomerID#" cfsqltype="cf_sql_varchar">
				<cfif arguments.HistoryInvoices EQ 0>
					AND ART.Balance <> 0
				</cfif>
				AND TRANS_NUMBER NOT IN (SELECT CAST(InvoicNumber AS varchar(100)) FROM [LMA Accounts Receivable Payment Detail] WHERE CompanyID = <cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar">)
				AND ART.CompanyID = <cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar">
	    </cfquery>
	    <cfreturn qOpenInvoices>
	</cffunction>

	<cffunction name="getCustomerPayments" access="public" returntype="query">
		<cfargument name="CustomerID" required="yes" type="string">

	    <cfquery name="qPayments" datasource="#variables.dsn#">
	    	SELECT 
	    		ARPT.CustomerID,
	    		ARPT.CompanCode,
				ARPT.CheckNumber,
				ARPT.Date,
				ARPT.CheckAmount,
				ARPT.InvoicNumber,
				ARPT.InvoicDate,
				ARPT.Date,
				ARPT.PurchaOrderNumber,
				ARPT.InvoicAmount,
				ARPT.Balance,
				ARPT.Applie,
				ARPT.EntereBy,
				ARPT.Entered,
				ARPT.VoidedBy,
				ARPT.VoidedOn,
				(SELECT LoadID FROM Loads WHERE LoadNumber = ARPT.InvoicNumber AND CustomerID = <cfqueryparam value="#arguments.CustomerID#" cfsqltype="cf_sql_varchar">) AS LoadID
			FROM 
				[LMA Accounts Receivable Payment Detail] ARPT 
			WHERE ARPT.CompanCode = (SELECT CompanCode FROM Customers WHERE CustomerID = <cfqueryparam value="#arguments.CustomerID#" cfsqltype="cf_sql_varchar">)
			AND ARPT.CompanyID = <cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar">	
			ORDER BY ARPT.CheckNumber,ARPT.InvoicNumber
	    </cfquery>
	    <cfreturn qPayments>
	</cffunction>

	<cffunction name="getCustomerCommodities" access="public" returntype="query">
		<cfargument name="CustomerID" required="yes" type="string">

	    <cfquery name="qCommodities" datasource="#variables.dsn#">
	    	SELECT 
			ART.TRANS_NUMBER,
			LS.LoadID ,
			U.UnitName,
			LSC.Description,
			LSC.Qty,
			LSC.CustRate
			FROM [LMA Accounts Receivable Transactions] ART
			INNER JOIN LoadStops LS ON LS.LoadID =ART.LoadID
			INNER JOIN LoadStopCommodities LSC ON LSC.LoadStopID =LS.LoadStopID
			INNER JOIN Units U ON U.UnitID =LSC.UnitID
			WHERE ART.CustomerID = <cfqueryparam value="#arguments.CustomerID#" cfsqltype="cf_sql_varchar">
			AND ART.Balance > 0
			AND TRANS_NUMBER NOT IN (SELECT CAST(InvoicNumber AS varchar(100)) FROM [LMA Accounts Receivable Payment Detail] WHERE CompanyID = <cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar">)
			AND ART.CompanyID = <cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar">
			GROUP BY ART.TRANS_NUMBER,
			LS.LoadID ,
			U.UnitName,
			LSC.Description,
			LSC.Qty,
			LSC.CustRate
			ORDER BY ART.TRANS_NUMBER
	    </cfquery>
	    <cfreturn qCommodities>
	</cffunction>

	<cffunction name="getCarrierOpenInvoices" access="public" returntype="query">
		<cfargument name="VendorID" required="yes" type="string">
		<cfargument name="HistoryInvoices" required="no" type="boolean" default="0">
	    <cfquery name="qOpenInvoices" datasource="#variables.dsn#">
	    	SELECT 
				APT.TRANS_NUMBER,
				(SELECT L.LoadID FROM Loads L WHERE L.LoadNumber = APT.TRANS_NUMBER AND L.CustomerID IN (SELECT Co.CustomerID FROM CustomerOffices CO WHERE CO.OfficeID IN (SELECT O.OfficeID FROM Offices O WHERE O.CompanyID = <cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar">))) AS LoadID,
				APT.Date,
				APT.term_number,
				APT.description,
				APT.Reference,
				APT.Total,
				APT.applied,
				APT.Balance,
				APT.discount,
				APT.VendorID,
				CTF.checkdate,
				CTF.amountdiscount,
				ISNULL(CTF.amount,0) AS amount,
				ISNULL(CTF.amountpaid,0) AS amountpaid,
				CTF.checknumber,
				CTF.checkaccount,
				APT.Notes
				FROM [LMA Accounts Payable Transactions] APT
				LEFT JOIN [LMA Accounts Payable Check Transaction File] CTF ON CTF.invoicenumber = APT.TRANS_NUMBER AND CTF.CompanyID = APT.CompanyID
				WHERE APT.VendorID = <cfqueryparam value="#arguments.VendorID#" cfsqltype="cf_sql_varchar">
				<cfif arguments.HistoryInvoices EQ 0>
					AND APT.Balance > 0
				</cfif>
				AND APT.CompanyID = <cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar">
	    </cfquery>
	    <cfreturn qOpenInvoices>
	</cffunction>

	<cffunction name="getCarrierPayments" access="public" returntype="query">
		<cfargument name="VendorID" required="yes" type="string">

	    <cfquery name="qPayments" datasource="#variables.dsn#">
	    	SELECT 
				CTF.CheckNumber,
				CTF.checkdate,
				CTF.amountpaid,
				CTF.invoicenumber,
				CTF.amountdiscount,
				CTF.amount,
				CTF.amountpaid,
				CTF.Vendorcode,
				CTF.checkaccount,
				CTF.EnteredBy,
				CTF.VoidedBy,
				CTF.VoidedOn,
				(SELECT L.LoadID FROM Loads L WHERE L.LoadNumber = CTF.invoicenumber AND L.CustomerID IN (SELECT Co.CustomerID FROM CustomerOffices CO WHERE CO.OfficeID IN (SELECT O.OfficeID FROM Offices O WHERE O.CompanyID = <cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar">))) AS LoadID
			FROM 
				[LMA Accounts Payable Check Transaction File] CTF

				WHERE CTF.Vendorcode = <cfqueryparam value="#arguments.VendorID#" cfsqltype="cf_sql_varchar">
				AND CTF.CompanyID = <cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar">
	    </cfquery>
	    <cfreturn qPayments>
	</cffunction>

	<cffunction name="getCarrierCommodities" access="public" returntype="query">
		<cfargument name="VendorID" required="yes" type="string">

	    <cfquery name="qCommodities" datasource="#variables.dsn#">
	    	SELECT 
			APT.TRANS_NUMBER,
			LS.LoadID ,
			U.UnitName,
			LSC.Description,
			LSC.Qty,
			LSC.CarrRate
			FROM [LMA Accounts Payable Transactions] APT
			INNER JOIN Loads L ON L.LoadNumber = APT.TRANS_NUMBER AND L.CustomerID IN (SELECT Co.CustomerID FROM CustomerOffices CO WHERE CO.OfficeID IN (SELECT O.OfficeID FROM Offices O WHERE O.CompanyID = <cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar">))
			INNER JOIN LoadStops LS ON LS.LoadID =L.LoadID
			INNER JOIN LoadStopCommodities LSC ON LSC.LoadStopID =LS.LoadStopID
			INNER JOIN Units U ON U.UnitID =LSC.UnitID
			WHERE APT.VendorID = <cfqueryparam value="#arguments.VendorID#" cfsqltype="cf_sql_varchar">
			AND APT.Balance > 0

			AND APT.CompanyID = <cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar">
			GROUP BY APT.TRANS_NUMBER,
			LS.LoadID ,
			U.UnitName,
			LSC.Description,
			LSC.Qty,
			LSC.CarrRate
			ORDER BY APT.TRANS_NUMBER
	    </cfquery>
	    <cfreturn qCommodities>
	</cffunction>

	<cffunction name="getLicenseTerms" access="public" returntype="string">
		<cfquery name="qLicenseTerms" datasource="LoadManagerAdmin">
			SELECT LicenseTerms FROM [SLA Terms]
		</cfquery>
		<cfreturn qLicenseTerms.LicenseTerms>
	</cffunction>

	<cffunction name="getLMAVendorInvoicesPIP" access="remote" output="yes" returnformat="plain">
		<cfargument name="dsn" type="string" required="yes" />
		<cfargument name="CompanyID" type="string" required="yes" />
		<cfargument name="vendorid" required="No" type="any">
		<cfargument name="SortBy" required="No" type="any" default="TRANS_NUMBER">
		<cfargument name="Sortorder" required="No" type="any" default="ASC">
		<cfquery name="qgetLMAVendorInvoices" datasource="#arguments.dsn#">
			SELECT 
			idcount,
			[Date],
			DueDate,
			TRANS_NUMBER,
			Reference,
			Total,
			Balance,
			Description,
			0 AS Applied,
			0 AS Discount,
			VendorID
			FROM [LMA Accounts Payable Transactions]
			WHERE VendorID = <cfqueryparam value="#arguments.vendorid#" cfsqltype="cf_sql_varchar"> 
			AND typetrans = 'I'
			AND balance <> 0
			AND CompanyID = <cfqueryparam value="#arguments.CompanyID#" cfsqltype="cf_sql_varchar">
			ORDER BY #arguments.SortBy# #arguments.Sortorder#
		</cfquery>
		<cfset rowNum = 0>
		<cfsavecontent variable="response">
			<cfif qgetLMAVendorInvoices.recordcount>
				<cfset TotalApplied = 0>
				<cfset TotalDiscount = 0>
				<cfset TotalAmount = 0>
				<input name="TotalRows" value="#qgetLMAVendorInvoices.recordcount#" type="hidden">
				<input name="Description" value="#qgetLMAVendorInvoices.Description#" type="hidden">
				<input name="VendorCode" value="#qgetLMAVendorInvoices.VendorID#" type="hidden">
				<cfoutput query="qgetLMAVendorInvoices">
					<cfset TotalAmount= TotalAmount + qgetLMAVendorInvoices.total>
					<cfset TotalApplied = TotalApplied + qgetLMAVendorInvoices.Applied>
					<cfset TotalDiscount = TotalDiscount + qgetLMAVendorInvoices.Discount>
					<input name="Balance_#qgetLMAVendorInvoices.idcount#" id="Balance_#qgetLMAVendorInvoices.idcount#" value="#qgetLMAVendorInvoices.Balance#" type="hidden">
	                <tr <cfif qgetLMAVendorInvoices.currentRow mod 2 eq 0>bgcolor="##FFFFFF"<cfelse>bgcolor="##f7f7f7"</cfif>>
                        <td align="left" valign="middle" nowrap="nowrap" class="normal-td  left-td-border">#DateFormat(qgetLMAVendorInvoices.Date,'mm/dd/yyyy')#</td>
                        <td align="left" valign="middle" nowrap="nowrap" class="normal-td">
                        	#qgetLMAVendorInvoices.TRANS_NUMBER#
                        	<input type="hidden" name="invoice_#qgetLMAVendorInvoices.currentrow#" value="#qgetLMAVendorInvoices.TRANS_NUMBER#">
                        </td>
                        <td align="left" valign="middle" nowrap="nowrap" class="normal-td">
	                        #DollarFormat(qgetLMAVendorInvoices.Total)#
	                        <input type="hidden" name="amount_#qgetLMAVendorInvoices.currentrow#" value="#qgetLMAVendorInvoices.Total#">
	                    </td>
                        <td align="left" valign="middle" nowrap="nowrap" class="normal-td">#DollarFormat(qgetLMAVendorInvoices.Balance)#</td>
                        <td align="left" valign="middle" nowrap="nowrap" class="normal-td">#qgetLMAVendorInvoices.Description#</td>
                        <td align="left" valign="middle" nowrap="nowrap" class="normal-td" style="padding: 0;"><input style="width:99%" class="applied" id="applied_#qgetLMAVendorInvoices.idcount#" name="applied_#qgetLMAVendorInvoices.currentrow#" value="#DollarFormat(qgetLMAVendorInvoices.Applied)#" onclick="calculateTotals('#qgetLMAVendorInvoices.idcount#')"  onchange="formatAppliedDollar('#qgetLMAVendorInvoices.idcount#')"></td>
                        <td align="left" valign="middle" nowrap="nowrap" class="normal-td" style="padding: 0;"><input style="width:95%" class="discount" id="discount_#qgetLMAVendorInvoices.idcount#" name="discount_#qgetLMAVendorInvoices.currentrow#" value="#DollarFormat(qgetLMAVendorInvoices.Discount)#" onclick="calculateDiscount('#qgetLMAVendorInvoices.idcount#','click')"  onchange="formatDiscountDollar('#qgetLMAVendorInvoices.idcount#','change')"></td>
                        <td align="left" valign="middle" nowrap="nowrap" class="normal-td" style="padding: 0;">
	                        <input readonly class="balAfterChk" style="width:96%;background: none repeat scroll 0 0 ##e3e3e3 !important;border: 1px solid ##c5c1c1 !important;color: ##434343 !important;" id="balAfterCheck_#qgetLMAVendorInvoices.idcount#" name="balAfterCheck_#qgetLMAVendorInvoices.currentrow#" value="#DollarFormat(0)#">
	                    </td>
                    </tr>
		        </cfoutput>
		        <cfoutput>
		        <tr>
		        	<input name="TotalAmount" value="#TotalAmount#" type="hidden">
		        	<td colspan="5" align="right" colspan="9" class="normal-td left-td-border"><b>Totals:</b></td>
		        	<td align="left" valign="middle" nowrap="nowrap" class="normal-td" style="padding: 0;"><input readonly style="width:99%" id="TotalApplied" name="TotalApplied" value="#DollarFormat(TotalApplied)#"></td>
		        	<td align="left" valign="middle" nowrap="nowrap" class="normal-td" style="padding: 0;"><input readonly style="width:95%" id="TotalDiscount" name="TotalDiscount" value="#DollarFormat(TotalDiscount)#"></td>
		        	<td align="left" valign="middle" nowrap="nowrap" class="normal-td" style="padding: 0;">
		        		<input readonly style="width:96%;background: none repeat scroll 0 0 ##e3e3e3 !important;border: 1px solid ##c5c1c1 !important;color: ##434343 !important;" id="balAfterChkTotal" name="balAfterChkTotal" value="#DollarFormat(0)#">
		        	</td>
		        </tr>
		        </cfoutput>
		    <cfelse>
				<cfoutput>
					<tr>
	                    <td align="center" colspan="8" class="normal-td left-td-border">No Records Found.</td>
	                </tr>
				</cfoutput>
	        </cfif>
        </cfsavecontent>
        <cfreturn response>
	</cffunction>

	<cffunction name="PostInvoicePayment" access="public" returntype="struct">
		<cfargument name="frmStruct" required="no" type="struct">
			<cftransaction>
			<cfset local.description = arguments.frmStruct.description>
			<cfset local.vendorcode = arguments.frmStruct.vendorcode>

			<cfset local.TotalApplied = replaceNoCase(replaceNoCase(arguments.frmStruct.TotalApplied,'$',''),',','','ALL')>
			<cfset local.TotalDiscount = replaceNoCase(replaceNoCase(arguments.frmStruct.TotalDiscount,'$',''),',','','ALL')>
			<cfset local.glacct = arguments.frmStruct.glacct>

			<cfloop from="1" to="#arguments.frmStruct.TotalRows#" index="i">
				<cfset local.AmountPaid = replaceNoCase(replaceNoCase(Evaluate('arguments.frmStruct.applied_#i#'),'$',''),',','','ALL')>
				<cfset local.RemBal = replaceNoCase(replaceNoCase(Evaluate('arguments.frmStruct.balAfterCheck_#i#'),'$',''),',','','ALL')>
				<cfif local.AmountPaid neq 0>
					<cfset local.invoicenumber = Evaluate('arguments.frmStruct.invoice_#i#')>
					<cfset local.Amount = Evaluate('arguments.frmStruct.Amount_#i#')>
					<cfset local.amountdiscount = Evaluate('arguments.frmStruct.discount_#i#')>
		    		<cfquery name="insQRy" datasource="#variables.dsn#">
		    			INSERT INTO [dbo].[LMA Accounts Payable Check Transaction File]
				           ([description]
				           ,[vendorcode]
				           ,[invoicenumber]
				           ,[amount]
				           ,[amountpaid]
				           ,[amountdiscount]
				           ,[checknumber]
				           ,[checkdate]
				           ,[checkaccount]
				           ,[EntryDate]
				           ,[EnteredBy]
				           ,[CompanyID]
				           ,[PayType])
				     	VALUES
				           (<cfqueryparam value="#local.description#" cfsqltype="cf_sql_varchar"> 
				           ,<cfqueryparam value="#local.vendorcode#" cfsqltype="cf_sql_varchar"> 
				           ,<cfqueryparam value="#local.invoicenumber#" cfsqltype="cf_sql_integer">
				           ,<cfqueryparam value="#replaceNoCase(replaceNoCase(local.Amount,'$',''),',','','ALL')#" cfsqltype="cf_sql_money">
				           ,<cfqueryparam value="#replaceNoCase(replaceNoCase(local.AmountPaid,'$',''),',','','ALL')#" cfsqltype="cf_sql_money">
				           ,<cfqueryparam value="#replaceNoCase(replaceNoCase(local.amountdiscount,'$',''),',','','ALL')#" cfsqltype="cf_sql_money">
				           ,<cfqueryparam value="#arguments.frmStruct.NextCheckNo#" cfsqltype="cf_sql_varchar"> 
				           ,<cfqueryparam value="#arguments.frmStruct.invoiceDate#" cfsqltype="cf_sql_date"> 
				           ,<cfqueryparam value="#arguments.frmStruct.Acct#" cfsqltype="cf_sql_varchar"> 
				           ,GETDATE()
				           ,<cfqueryparam value="#session.AdminUserName#" cfsqltype="cf_sql_varchar">
				           ,<cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar">
				           ,<cfqueryparam value="#arguments.frmStruct.PayType#" cfsqltype="cf_sql_varchar"> )

				        UPDATE [LMA Accounts Payable Transactions] 
				        SET Balance = Balance - <cfqueryparam value="#replaceNoCase(replaceNoCase(local.AmountPaid,'$',''),',','','ALL')#" cfsqltype="cf_sql_money"> - <cfqueryparam value="#replaceNoCase(replaceNoCase(local.amountdiscount,'$',''),',','','ALL')#" cfsqltype="cf_sql_money">
				        	,Applied = Applied+<cfqueryparam value="#replaceNoCase(replaceNoCase(local.AmountPaid,'$',''),',','','ALL')#" cfsqltype="cf_sql_money">
				        	,Discount = Discount+<cfqueryparam value="#replaceNoCase(replaceNoCase(local.amountdiscount,'$',''),',','','ALL')#" cfsqltype="cf_sql_money">
				        WHERE 
				        TRANS_NUMBER = <cfqueryparam value="#local.invoicenumber#" cfsqltype="cf_sql_integer">
				        AND CompanyID = <cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar">

				        UPDATE Carriers SET Balance = Balance - <cfqueryparam value="#replaceNoCase(replaceNoCase(local.AmountPaid,'$',''),',','','ALL')#" cfsqltype="cf_sql_money">- <cfqueryparam value="#replaceNoCase(replaceNoCase(local.amountdiscount,'$',''),',','','ALL')#" cfsqltype="cf_sql_money">
			            WHERE VendorID = <cfqueryparam value="#Local.vendorcode#" cfsqltype="cf_sql_varchar">
				    </cfquery>
				    <cfquery name="qGetLoad" datasource="#variables.dsn#">
						SELECT LoadID FROM Loads L 
						INNER JOIN CustomerOffices CO ON CO.CustomerID = L.CustomerID
						INNER JOIN Offices O ON O.OfficeID = CO.OfficeID
						WHERE L.LoadNUmber = <cfqueryparam value="#local.invoicenumber#" cfsqltype="cf_sql_integer"> 
						AND O.CompanyID = <cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar">
					</cfquery>
					<cfif qGetLoad.recordcount and local.RemBal EQ 0>
						<cfquery name="updLoad" datasource="#variables.dsn#">
			    			UPDATE Loads SET CarrierPaid = 1 WHERE LoadID = <cfqueryparam value="#qGetLoad.LoadID#" cfsqltype="cf_sql_varchar">
			    		</cfquery>
			    	</cfif>
			    </cfif>
		    </cfloop>
		    <cfif local.TotalApplied neq 0>
		    	<cfinvoke method="PostToGL" returnvariable="qPostToGL" account="#arguments.frmstruct.APGLAccount#" cv_code="#local.vendorcode#" year_past="#arguments.frmStruct.year_past#" post_amt="#local.TotalApplied#" Invoice_Code="#local.invoicenumber#" tran_type="CD" tran_desc="#local.description#" tran_date="#arguments.frmStruct.invoiceDate#" module=""/>
		    	<cfset local.TotalApplied  = -1*local.TotalApplied>
		    	<cfinvoke method="PostToGL" returnvariable="qPostToGL" account="#arguments.frmstruct.glacct#" cv_code="#local.vendorcode#" year_past="#arguments.frmStruct.year_past#" post_amt="#local.TotalApplied#" Invoice_Code="#local.invoicenumber#" tran_type="CD" tran_desc="#local.description#" tran_date="#arguments.frmStruct.invoiceDate#" module=""/>
		    </cfif>

		    <cfif local.TotalDiscount neq 0>
		    	<cfinvoke method="PostToGL" returnvariable="qPostToGL" account="#arguments.frmstruct.APGLAccount#" cv_code="#local.vendorcode#" year_past="#arguments.frmStruct.year_past#" post_amt="#local.TotalDiscount#" Invoice_Code="#local.invoicenumber#" tran_type="CD" tran_desc="#local.description#" tran_date="#arguments.frmStruct.invoiceDate#" module=""/>
		    	<cfset local.TotalDiscount  = -1*local.TotalDiscount>
		    	<cfinvoke method="PostToGL" returnvariable="qPostToGL" account="#arguments.frmstruct.APDiscountAccount#" cv_code="#local.vendorcode#" year_past="#arguments.frmStruct.year_past#" post_amt="#local.TotalDiscount#" Invoice_Code="#local.invoicenumber#" tran_type="CD" tran_desc="#local.description#" tran_date="#arguments.frmStruct.invoiceDate#" module=""/>
		    </cfif>

		    <cfinvoke method="printChecks" dsn="#variables.dsn#" account="#arguments.frmStruct.Acct#" checkNumber="#arguments.frmStruct.NextCheckNo#" CompanyID="#session.CompanyID#" returnvariable="resp"/>
		</cftransaction>
		<cfset respStr = structNew()>
    	<cfset respStr.res = 'success'>
    	<cfset respStr.msg = "Finished applying payments.">
    	<cfreturn respStr>
    </cffunction>

    <cffunction name="getChecksForAccount" access="remote" returntype="array" returnFormat="json">
    	<cfargument name="dsn" required="yes" type="string">
    	<cfargument name="AccountCode" required="yes" type="string">
    	<cfargument name="CompanyID" type="string" required="yes" />
    	<cfquery name="qgetChecksForAccount" datasource="#arguments.dsn#">
    		SELECT 
    		CheckNumber,
    		CheckDate,
    		(SELECT CarrierName FROM Carriers WHERE Carriers.VendorID = CTF.vendorcode AND CompanyID =<cfqueryparam value="#arguments.CompanyID#" cfsqltype="cf_sql_varchar">) AS Payee,
    		sum(amountpaid) as amount
    		FROM [LMA Accounts Payable Check Transaction File] CTF 
    		WHERE
			checkaccount = <cfqueryparam value="#arguments.AccountCode#" cfsqltype="cf_sql_varchar">  AND checknumber IS NOT NULL  AND CompanyID =<cfqueryparam value="#arguments.CompanyID#" cfsqltype="cf_sql_varchar">
			GROUP BY CheckNumber,CheckDate,vendorcode
    	</cfquery>

    	<cfset arrResult = arrayNew(1)>
    	<cfloop query="qgetChecksForAccount">
    		<cfset tmpStr = structnew()>
    		<cfset tmpStr['CheckNumber'] = qgetChecksForAccount.CheckNumber>
    		<cfset tmpStr['CheckDate'] = dateformat(qgetChecksForAccount.CheckDate,'mm/dd/yyyy')>
    		<cfset tmpStr['Payee'] = qgetChecksForAccount.Payee>
    		<cfset tmpStr['Amount'] = dollarformat(qgetChecksForAccount.amount)>
    		<cfset arrayAppend(arrResult, tmpStr)>
    	</cfloop>

    	<cfreturn arrResult>
    </cffunction>

    <cffunction name="VoidInvoicePayment" access="public" returntype="struct">
		<cfargument name="frmStruct" required="no" type="struct">
		<cftransaction>
			<cfquery name="qGetCheckdetails" datasource="#variables.dsn#">
				SELECT 
				*
				FROM [LMA Accounts Payable Check Transaction File]
				WHERE checknumber = <cfqueryparam value="#arguments.frmStruct.checkNumber#" cfsqltype="cf_sql_varchar">
				AND checkaccount = <cfqueryparam value="#arguments.frmStruct.Acct#" cfsqltype="cf_sql_varchar">
				AND CompanyID =<cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar">
			</cfquery>


			<cfloop query="qGetCheckdetails" group="vendorcode">
				<cfset local.TotalApplied = 0>
				<cfset local.TotalDiscount = 0>
				<cfloop group="invoicenumber">
					<cfset local.TotalApplied = local.TotalApplied + qGetCheckdetails.amountpaid>
					<cfset local.TotalDiscount = local.TotalDiscount + qGetCheckdetails.amountdiscount>
					<cfset local.invoicenumber = qGetCheckdetails.invoicenumber>

					<cfquery name="updbalance" datasource="#variables.dsn#">
						Update [LMA Accounts Payable Transactions] SET
						Applied = Applied - <cfqueryparam value="#qGetCheckdetails.amountpaid#" cfsqltype="cf_sql_money">
						,discount = discount - <cfqueryparam value="#qGetCheckdetails.amountdiscount#" cfsqltype="cf_sql_money">
						,balance = balance + <cfqueryparam value="#qGetCheckdetails.amountpaid#" cfsqltype="cf_sql_money"> + <cfqueryparam value="#qGetCheckdetails.amountdiscount#" cfsqltype="cf_sql_money">
						WHERE CompanyID = <cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar">
						AND vendorid = <cfqueryparam value="#qGetCheckdetails.vendorcode#" cfsqltype="cf_sql_varchar">
						AND Trans_Number = <cfqueryparam value="#local.invoicenumber#" cfsqltype="cf_sql_varchar">

						UPDATE Carriers SET balance = balance + <cfqueryparam value="#qGetCheckdetails.amountpaid#" cfsqltype="cf_sql_money"> + <cfqueryparam value="#qGetCheckdetails.amountdiscount#" cfsqltype="cf_sql_money">
						WHERE CompanyID = <cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar">
						AND vendorid = <cfqueryparam value="#qGetCheckdetails.vendorcode#" cfsqltype="cf_sql_varchar">
					</cfquery>
				</cfloop>
				<cfset local.vendorcode = qGetCheckdetails.vendorcode>
				<cfset local.description = qGetCheckdetails.description>

				<cfif local.TotalApplied neq 0>
			    	<cfinvoke method="PostToGL" returnvariable="qPostToGL" account="#arguments.frmstruct.glacct#" cv_code="#local.vendorcode#" year_past="#arguments.frmStruct.year_past#" post_amt="#local.TotalApplied#" Invoice_Code="#local.invoicenumber#" tran_type="CD" tran_desc="#local.description#" tran_date="#arguments.frmStruct.invoiceDate#" module=""/>
			    	<cfset local.TotalApplied  = -1*local.TotalApplied>
			    	<cfinvoke method="PostToGL" returnvariable="qPostToGL" account="#arguments.frmstruct.APGLAccount#" cv_code="#local.vendorcode#" year_past="#arguments.frmStruct.year_past#" post_amt="#local.TotalApplied#" Invoice_Code="#local.invoicenumber#" tran_type="CD" tran_desc="#local.description#" tran_date="#arguments.frmStruct.invoiceDate#" module=""/>
			    </cfif>

			    <cfif local.TotalDiscount neq 0>
			    	<cfinvoke method="PostToGL" returnvariable="qPostToGL" account="#arguments.frmstruct.APDiscountAccount#" cv_code="#local.vendorcode#" year_past="#arguments.frmStruct.year_past#" post_amt="#local.TotalDiscount#" Invoice_Code="#local.invoicenumber#" tran_type="CD" tran_desc="#local.description#" tran_date="#arguments.frmStruct.invoiceDate#" module=""/>
			    	<cfset local.TotalDiscount  = -1*local.TotalDiscount>
			    	<cfinvoke method="PostToGL" returnvariable="qPostToGL" account="#arguments.frmstruct.APGLAccount#" cv_code="#local.vendorcode#" year_past="#arguments.frmStruct.year_past#" post_amt="#local.TotalDiscount#" Invoice_Code="#local.invoicenumber#" tran_type="CD" tran_desc="#local.description#" tran_date="#arguments.frmStruct.invoiceDate#" module=""/>
			    </cfif>
			</cfloop>

			<cfquery name="insHistory" datasource="#variables.dsn#">
				INSERT INTO [LMA Accounts Payable Check Transaction History]
			           ([description]
			           ,[vendorcode]
			           ,[invoicenumber]
			           ,[amount]
			           ,[amountpaid]
			           ,[amountdiscount]
			           ,[invoicedate]
			           ,[checknumber]
			           ,[checkdate]
			           ,[checkaccount]
			           ,[Voided]
			           ,[DateVoided]
			           ,[EntryDate]
			           ,[EnteredBy]
			           ,[RemitCode]
			           ,[RemitName]
			           ,[XRateAmt]
			           ,[CompanyID])
			     SELECT [description]
			           ,[vendorcode]
			           ,[invoicenumber]
			           ,[amount]
			           ,[amountpaid]
			           ,[amountdiscount]
			           ,[invoicedate]
			           ,[checknumber]
			           ,[checkdate]
			           ,[checkaccount]
			           ,1
			           ,GETDATE()
			           ,GETDATE()
			           ,[EnteredBy]
			           ,[RemitCode]
			           ,NULL
			           ,0
			           ,[CompanyID] FROM  [LMA Accounts Payable Check Transaction File]
			           WHERE checknumber = <cfqueryparam value="#arguments.frmStruct.checkNumber#" cfsqltype="cf_sql_varchar">
					AND checkaccount = <cfqueryparam value="#arguments.frmStruct.Acct#" cfsqltype="cf_sql_varchar">
					AND CompanyID =<cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar">
			</cfquery>

			<cfquery name="delCheck" datasource="#variables.dsn#">
				delete from [LMA Accounts Payable Check Transaction File] WHERE checknumber = <cfqueryparam value="#arguments.frmStruct.checkNumber#" cfsqltype="cf_sql_varchar">
				AND checkaccount = <cfqueryparam value="#arguments.frmStruct.Acct#" cfsqltype="cf_sql_varchar">
				AND CompanyID =<cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar">
				delete from [LMA Accounts Payable Check Payment Detail Current]  WHERE checknumber = <cfqueryparam value="#arguments.frmStruct.checkNumber#" cfsqltype="cf_sql_varchar">
				AND checkaccount = <cfqueryparam value="#arguments.frmStruct.Acct#" cfsqltype="cf_sql_varchar">
				AND CompanyID =<cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar">
			</cfquery>
		</cftransaction>
		<cfset respStr = structNew()>
    	<cfset respStr.res = 'success'>
    	<cfset respStr.msg = "Voided.">
    	<cfreturn respStr>
    </cffunction>

    <cffunction name="getChecksList" access="public" returntype="query">

    	<cfquery name="qChecksList" datasource="#variables.dsn#">
    		SELECT 
    		CheckNumber,
    		CheckDate,
    		(SELECT TOP 1 CarrierName FROM Carriers WHERE Carriers.VendorID = CTF.vendorcode AND CompanyID =<cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar">) AS Payee,
    		sum(amountpaid) as amount
    		FROM [LMA Accounts Payable Check Transaction File] CTF 
    		WHERE
			checknumber IS NOT NULL  AND CompanyID =<cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar">
			GROUP BY CheckNumber,CheckDate,vendorcode
    	</cfquery>
    	<cfreturn qChecksList>

    </cffunction>

    <cffunction name="deleteTempQBFile" access="remote" output="yes" returnformat="json">
		<cfargument name="fileName" type="any" required="yes">
		<cfif fileexists("#expandPath( "../temp/")##fileName#")>
			<cffile action="delete" file="#expandPath( "../temp/")##fileName#">
		</cfif>
		<cfreturn 1>
	</cffunction>

	<cffunction name="getQBExportHistory" access="public" returntype="query">
    	<cfargument name="frmStruct" required="no" type="struct">
		<cfinvoke method="getSystemSetupOptions" returnvariable="request.qSystemSetupOptions">

    	<cfif structKeyExists(arguments.frmStruct, "pageNo")>
    		<cfset local.pageNo = arguments.frmStruct.pageNo>
    	<cfelse>
    		<cfset local.pageNo = 1>
    	</cfif>

    	<cfif structKeyExists(arguments.frmStruct, "sortby")>
    		<cfset local.sortby = arguments.frmStruct.sortby>
    	<cfelse>
    		<cfset local.sortby = "Created">
    	</cfif>

    	<cfif structKeyExists(arguments.frmStruct, "sortorder")>
    		<cfset local.sortorder = arguments.frmStruct.sortorder>
    	<cfelse>
    		<cfset local.sortorder = "DESC">
    	</cfif>

		<cfquery name="qGetQBExportHistory" datasource="#variables.dsn#">
			BEGIN WITH page AS( 
				SELECT 
				*
				,ROW_NUMBER() OVER (ORDER BY #local.sortby# #local.sortorder#) AS Row
				FROM tblQBExportedHistory
				WHERE CompanyID = <cfqueryparam value="#session.companyID#" cfsqltype="cf_sql_varchar">
				AND Reverted = 0
				)
				SELECT * FROM page
		    	WHERE Row BETWEEN (#local.pageNo# - 1) * #request.qSystemSetupOptions.RowsPerPage# + 1 AND #local.pageNo# * #request.qSystemSetupOptions.RowsPerPage#
	    	END
		</cfquery>
	    <cfreturn qGetQBExportHistory>
	</cffunction>

	<cffunction name="QBStatusUpdateTo" access="remote" output="yes" returnformat="json">
		<cfargument name="fieldName" type="any" required="yes">
		<cfargument name="value" type="any" required="yes">
		<cfargument name="CompanyID" type="any" required="yes">

		<cfset local.dsn = trim(listFirst(cgi.SCRIPT_NAME,'/'))>

		<cfquery name="qQBStatusUpdateTo" datasource="#local.dsn#">
			UPDATE SystemConfig SET #arguments.fieldName# = <cfqueryparam value="#arguments.value#" cfsqltype="cf_sql_varchar">
			WHERE CompanyID = <cfqueryparam value="#arguments.CompanyID#" cfsqltype="cf_sql_varchar">
		</cfquery>
		<cfreturn 1>
	</cffunction>

	<cffunction name="updateLoadCopyOptions" access="public" returntype="void">
		<cfargument name="CopyLoadIncludeAgentAndDispatcher" type="boolean" required="yes">
		<cfargument name="CopyLoadDeliveryPickupDates" type="boolean" required="yes">
		<cfargument name="CopyLoadCarrier" type="boolean" required="no">
		<cfargument name="ShowLoadCopyOptions" type="boolean" required="yes">

		<cftry>
			<cfquery name="qUpdLoadCopyOptions" datasource="#variables.dsn#">
				UPDATE SystemConfig SET 
				CopyLoadIncludeAgentAndDispatcher = <cfqueryparam value="#arguments.CopyLoadIncludeAgentAndDispatcher#" cfsqltype="cf_sql_bit">
				,CopyLoadDeliveryPickupDates = <cfqueryparam value="#arguments.CopyLoadDeliveryPickupDates#" cfsqltype="cf_sql_bit">
				<cfif structkeyexists(arguments,"CopyLoadCarrier")>
					,CopyLoadCarrier = <cfqueryparam value="#arguments.CopyLoadCarrier#" cfsqltype="cf_sql_bit">
				</cfif>
				,ShowLoadCopyOptions = <cfqueryparam value="#arguments.ShowLoadCopyOptions#" cfsqltype="cf_sql_bit">
				WHERE CompanyID = <cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar">
			</cfquery>
			<cfcatch></cfcatch>
		</cftry>
	</cffunction>

	<cffunction name="checkLoadCompany" access="public" returntype="boolean">
		<cfargument name="LoadID" type="string" required="yes">
		<cfquery name="qcheckLoadCompany" datasource="#variables.dsn#">
			SELECT l.LoadID FROM loads l
			INNER JOIN CustomerOffices CO ON l.CustomerID = CO.CustomerID
			INNER JOIN Offices O ON O.OfficeID = CO.OfficeID
			WHERE l.loadid = <cfqueryparam value="#arguments.LoadID#" cfsqltype="cf_sql_varchar">
			AND O.CompanyID = <cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar">
		</cfquery>

		<cfif qcheckLoadCompany.recordcount>
			<cfreturn 1>
		<cfelse>
			<cfreturn 0>
		</cfif>
	</cffunction>
	
	<cffunction name="ajaxCompareLoadModifiedDate" access="remote" output="yes" returnformat="json">
		<cfargument name="LoadID" type="any" required="yes">
		<cfargument name="LastModifiedDate" type="any" required="yes">

		<cfset local.dsn = trim(listFirst(cgi.SCRIPT_NAME,'/'))>

		<cfquery name="qCheckLoadModifiedDate" datasource="#local.dsn#">
			SELECT COUNT(LoadID) AS allowSubmit FROM Loads WHERE LoadID = <cfqueryparam value="#arguments.LoadID#" cfsqltype="cf_sql_varchar"> AND LastModifiedDate = <cfqueryparam value="#arguments.LastModifiedDate#" cfsqltype="cf_sql_varchar">
		</cfquery>

		<cfreturn qCheckLoadModifiedDate.allowSubmit>
	</cffunction>

	<cffunction name="QBRevertLastInvoice" access="public" returntype="struct" returnformat="json">
		<cftry>
			<cfquery name="qGetLastInvoice" datasource="#variables.dsn#">
				SELECT LoadID,LoadNumber,id FROM tblQBExportedHistory 
				WHERE Type ='Invoice' AND CompanyID = <cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar"> AND Reverted = 0
				AND ExportSetID = (SELECT max(ExportSetID) FROM tblQBExportedHistory WHERE Type ='Invoice' AND CompanyID = <cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar"> AND Reverted = 0)
			</cfquery>

			<cfquery name="qRevertInvoice" datasource="#variables.dsn#">
				UPDATE Loads SET ARExported = 0
				,StatusTypeID = (SELECT ARAndAPExportStatusID FROM SystemConfig WHERE CompanyID = <cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar">)
				WHERE LoadID IN (<cfqueryparam value="#ListRemoveDuplicates(ValueList(qGetLastInvoice.LoadID))#" cfsqltype="cf_sql_varchar" list="yes">)

				UPDATE tblQBExportedHistory SET Reverted = 1 WHERE id IN (<cfqueryparam value="#ListRemoveDuplicates(ValueList(qGetLastInvoice.id))#" cfsqltype="cf_sql_integer" list="yes">)
			</cfquery>

			<cfset respStr = structNew()>
	    	<cfset respStr.res = 'success'>
	    	<cfset respStr.msg = "Successfully reverted the last invoice export. (Load##:#ListRemoveDuplicates(ValueList(qGetLastInvoice.LoadNumber))#).">
	    	<cfreturn respStr>
			<cfcatch>
				<cfset respStr = structNew()>
		    	<cfset respStr.res = 'error'>
		    	<cfset respStr.msg = "Something went wrong. Unable to Revert.">
		    	<cfreturn respStr>
			</cfcatch>
		</cftry>

	</cffunction>

	<cffunction name="QBRevertLastBills" access="public" returntype="struct" returnformat="json">
		<cftry>
			<cfquery name="qGetLastInvoice" datasource="#variables.dsn#">
				SELECT LoadID,LoadNumber,id FROM tblQBExportedHistory 
				WHERE Type ='Bill' AND CompanyID = <cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar"> AND Reverted = 0
				AND ExportSetID = (SELECT max(ExportSetID) FROM tblQBExportedHistory WHERE Type ='Bill' AND CompanyID = <cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar"> AND Reverted = 0)
			</cfquery>

			<cfquery name="qRevertInvoice" datasource="#variables.dsn#">
				UPDATE Loads SET APExported = 0
				,StatusTypeID = (SELECT APExportStatusID FROM SystemConfig WHERE CompanyID = <cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar">) 
				WHERE LoadID IN (<cfqueryparam value="#ListRemoveDuplicates(ValueList(qGetLastInvoice.LoadID))#" cfsqltype="cf_sql_varchar" list="yes">)

				UPDATE tblQBExportedHistory SET Reverted = 1 WHERE id IN (<cfqueryparam value="#ListRemoveDuplicates(ValueList(qGetLastInvoice.id))#" cfsqltype="cf_sql_integer" list="yes">)
			</cfquery>

			<cfset respStr = structNew()>
	    	<cfset respStr.res = 'success'>
	    	<cfset respStr.msg = "Successfully reverted the last bills export. (Load##:#ListRemoveDuplicates(ValueList(qGetLastInvoice.LoadNumber))#).">
	    	<cfreturn respStr>
			<cfcatch>
				<cfset respStr = structNew()>
		    	<cfset respStr.res = 'error'>
		    	<cfset respStr.msg = "Something went wrong. Unable to Revert.">
		    	<cfreturn respStr>
			</cfcatch>
		</cftry>

	</cffunction>

	 <cffunction name="getQBNotExportedLoads" access="public" returntype="query">
    	<cfargument name="frmStruct" required="no" type="struct">
		<cfinvoke method="getSystemSetupOptions" returnvariable="request.qSystemSetupOptions">
    	<cfif structKeyExists(arguments.frmStruct, "pageNo")>
    		<cfset local.pageNo = arguments.frmStruct.pageNo>
    	<cfelse>
    		<cfset local.pageNo = 1>
    	</cfif>

    	<cfif structKeyExists(arguments.frmStruct, "sortby")>
    		<cfset local.sortby = arguments.frmStruct.sortby>
    	<cfelse>
    		<cfset local.sortby = "">
    	</cfif>

    	<cfif structKeyExists(arguments.frmStruct, "sortorder")>
    		<cfset local.sortorder = arguments.frmStruct.sortorder>
    	<cfelse>
    		<cfset local.sortorder = "">
    	</cfif>

		<cfquery name="qGetQBLoads" datasource="#variables.dsn#">
			BEGIN WITH page AS( 
				SELECT 
				L.LoadID
				,L.LoadNumber
				,Lst.StatusText
				,Lst.StatusDescription
				,L.BillDate
				,L.NewPickupDate
				,C.CustomerName
				,C.Email
				,L.TotalCustomerCharges
				,L.TotalCarrierCharges
				<cfif len(local.sortby) and len(local.sortorder)>
					,ROW_NUMBER() OVER (ORDER BY #local.sortby# #local.sortorder#) AS Row
				<cfelse>
					,ROW_NUMBER() OVER (ORDER BY LST.StatusText DESC,L.BillDate ASC ) AS Row
				</cfif>
				FROM Loads L
				INNER JOIN Customers C ON C.CustomerID = L.CustomerID
				INNER JOIN CustomerOffices CO ON CO.CustomerID = C.CustomerID
				INNER JOIN Offices O ON O.OfficeID = CO.OfficeID
				INNER JOIN SystemConfig S ON S.CompanyID =  O.CompanyID 
				INNER JOIN LoadStatusTypes LST ON LST.StatusTypeID = L.StatusTypeID 
				<cfif structKeyExists(arguments.frmStruct, "LoadStatusFilter") AND arguments.frmStruct.LoadStatusFilter>
					AND LST.StatusTypeID <> S.APExportStatusID AND LST.StatusTypeID <> S.ARAndAPExportStatusID
				</cfif>
				WHERE O.CompanyID = <cfqueryparam value="#session.companyID#" cfsqltype="cf_sql_varchar">
				AND L.ARExported  = 0 AND L.APExported = 0
				AND LST.StatusText <= '8. COMPLETED'
				<cfif Len(Trim(arguments.frmStruct.InvoiceDateFrom)) AND Len(Trim(arguments.frmStruct.InvoiceDateTo))>
					AND ISNULL(L.BillDate,L.NewPickupDate) BETWEEN <cfqueryparam value="#Trim(arguments.frmStruct.InvoiceDateFrom)#" cfsqltype="cf_sql_date">
						AND <cfqueryparam value="#Trim(arguments.frmStruct.InvoiceDateTO)#" cfsqltype="cf_sql_date">
				</cfif>
				GROUP BY 
				L.LoadID
				,L.LoadNumber
				,Lst.StatusText
				,Lst.StatusDescription
				,L.BillDate
				,L.NewPickupDate
				,C.CustomerName
				,C.Email
				,L.TotalCustomerCharges
				,L.TotalCarrierCharges
				)
				SELECT * FROM page
		    	WHERE Row BETWEEN (#local.pageNo# - 1) * #request.qSystemSetupOptions.RowsPerPage# + 1 AND #local.pageNo# * #request.qSystemSetupOptions.RowsPerPage#
	    	END
		</cfquery>
	    <cfreturn qGetQBLoads>
	</cffunction>

	<cffunction name="getQBNotExportedCustomerCarrierTotals" access="public" returntype="query">

		<cfquery name="qgetQBCustomerCarrierTotals" datasource="#variables.dsn#">
			SELECT L1.LoadID,L1.TotalCustomerCharges,L1.TotalCarrierCharges FROM Loads L1 
			INNER JOIN CustomerOffices CO1 ON CO1.CustomerID = L1 .CustomerID
			INNER JOIN Offices O1 ON O1.OfficeID = CO1.OfficeID
			INNER JOIN SystemConfig S ON S.CompanyID =  O1.CompanyID 
			INNER JOIN LoadStatusTypes LST1 ON LST1.StatusTypeID = L1.StatusTypeID
			WHERE O1.CompanyID = <cfqueryparam value="#session.companyID#" cfsqltype="cf_sql_varchar">
			AND L1.ARExported  = 0 AND L1.APExported  = 0
			AND LST1.StatusText <= '8. COMPLETED'
			<cfif structKeyExists(arguments.frmStruct, "LoadStatusFilter") AND arguments.frmStruct.LoadStatusFilter>
				AND LST1.StatusTypeID <> S.APExportStatusID AND LST1.StatusTypeID <> S.ARAndAPExportStatusID
			</cfif>
			<cfif Len(Trim(arguments.frmStruct.InvoiceDateFrom)) AND Len(Trim(arguments.frmStruct.InvoiceDateTo))>
				AND ISNULL(L1.BillDate,L1.NewPickupDate) BETWEEN <cfqueryparam value="#Trim(arguments.frmStruct.InvoiceDateFrom)#" cfsqltype="cf_sql_date">
					AND <cfqueryparam value="#Trim(arguments.frmStruct.InvoiceDateTO)#" cfsqltype="cf_sql_date">
			</cfif>
		</cfquery>
		<cfreturn qgetQBCustomerCarrierTotals>
	</cffunction>

	<cffunction name="ProcessAIImportData" access="public" returntype="query">
		<cfargument name="frmStruct" required="yes" type="struct">
		
		<cfquery name="qGetCity" datasource="#variables.dsn#">
			SELECT City,StateCode,City + ' ' + StateCode AS CitySpaceStateCode
			FROM PostalCode GROUP BY City,StateCode
		</cfquery>

		<cfset var LText = arguments.frmStruct.LoadText>
		<cfset var strText = "">
		<cfset var currentIndex = 1>
		<cfset var masterCityList = valueList(qGetCity.City)>
		<cfset var masterStateList = valueList(qGetCity.StateCode)>
		<cfset var masterCitySpaceStateCodeList = valueList(qGetCity.CitySpaceStateCode)>
		<cfset var delimiter = chr(10)>
		<cfset var strLength = listLen(arguments.frmStruct.LoadText,delimiter)>

		<cfset LText = replaceNoCase(LText, Chr(9), delimiter,'ALL')>

		<cfloop index="row" list="#LText#" delimiters="#delimiter#">
			<cfif len(trim(row))>
				<cfif currentIndex NEQ 1>
					<cfset strText &= delimiter>
				</cfif>
				<cfset strText &= trim(row)>
				<cfset currentIndex++>
			</cfif>
		</cfloop>

		<cfloop query="#qGetCity#">
			<cfset var cityDelimiter = replaceNoCase(qGetCity.City, " ", delimiter)>
			<cfif FindNoCase(cityDelimiter,strText) AND FindNoCase(delimiter,cityDelimiter)>
				<cfset strIndx = FindNoCase(cityDelimiter,strText)>
				<cfif strIndx EQ 1 OR mid(strText, strIndx-1, 1) EQ delimiter>
					<cfset strText = replaceNoCase(strText, cityDelimiter, UCASE(qGetCity.City),"ALL")>
				</cfif>
			</cfif>
			<cfset var cityStateStuff = " "&qGetCity.City&", "&qGetCity.statecode&" ">
			<cfif FindNoCase(cityStateStuff,strText)>
				<cfset strText = replaceNoCase(strText,cityStateStuff,delimiter&qGetCity.City&delimiter&qGetCity.statecode&delimiter,"ALL")>
			</cfif>
		</cfloop>

		<cfset var tempText = "">
		<cfset var IsPrevTextCity = 0>
		<cfset var tempHeaders = "PickupCity,PickupState,DelCity,DelState">
		<cfloop from="1" to="15" step="1" index="i">
			<cfset tempHeaders = listAppend(tempHeaders, "Column_#i#")>
		</cfloop>
		<cfset var qryLoad = QueryNew(tempHeaders)>
		<cfset var rowNum = 1>
		<cfset var headerIndx = 1>
		<cfset QueryAddRow(qryLoad, 1)>
		<cfset charIndex = 1>
		<cfloop from="1" to="#len(strText)#" index="i">

			<cfset tempText &= mid(strText, charIndex, 1)>
			<cfset nextOne = mid(strText, charIndex+1, 1)>
			<cfset nextTwoThree = mid(strText, charIndex+2, 2)>
			<cfset nextFourth = mid(strText, charIndex+4, 1)>
			<cfset nextOneTwo = mid(strText, charIndex+1, 2)>
			<cfset nextThreeFour = mid(strText, charIndex+3, 2)>
			<cfset nextFifth = mid(strText, charIndex+5, 1)>
			<cfset nextThird = mid(strText, charIndex+3, 1)>

			<cfset tempTextCityCorr = replaceNoCase(replaceNoCase(tempText, "St.", "SAINT","ALL"), "'", "","ALL")>
			<cfset tempTextCityCorr = replaceNoCase(tempTextCityCorr, "MT ", "MOUNT ","ALL")>

			<cfif (((nextOne EQ delimiter OR nextOne EQ ' ') AND listFindNoCase(masterStateList, trim(nextTwoThree)) AND (listFindNoCase(masterCitySpaceStateCodeList, trim(tempText) & ' ' & trim(nextTwoThree)) OR listFindNoCase(masterCitySpaceStateCodeList, trim(tempTextCityCorr) & ' ' & trim(nextTwoThree))) AND (nextFourth EQ delimiter OR nextFourth EQ ' ')) OR (nextOneTwo EQ ', ' AND listFindNoCase(masterStateList, trim(nextThreeFour)) AND (listFindNoCase(masterCitySpaceStateCodeList, trim(tempText) & ' ' & trim(nextThreeFour))OR listFindNoCase(masterCitySpaceStateCodeList, trim(tempTextCityCorr) & ' ' & trim(nextThreeFour)))AND (nextFifth EQ ' ' OR  nextFifth EQ delimiter))) AND (listFindNoCase(masterCityList, trim(tempText)) OR listFindNoCase(masterCityList, trim(tempTextCityCorr)))>

				<cfif (Len(Trim(qryLoad.PickupCity[#rowNum#])) AND Len(Trim(qryLoad.DelCity[#rowNum#])))>
					<cfset rowNum++>
					<cfset headerIndx = 1>
					<cfset QueryAddRow(qryLoad, 1)>
				</cfif>

				<cfif not Len(Trim(qryLoad.PickupCity[#rowNum#]))>
					<cfset QuerySetCell(qryLoad, "PickupCity", tempText, rowNum)>
				<cfelseif not Len(Trim(qryLoad.DelCity[#rowNum#]))>
					<cfset QuerySetCell(qryLoad, "DelCity", tempText, rowNum)>
				</cfif>
				<cfset IsPrevTextCity = 1>
				<cfset tempText = "">
				<cfif nextOneTwo EQ ', '>
					<cfset charIndex=charIndex+2>
				</cfif>
			<cfelseif (nextOne EQ delimiter OR NOT len(trim(nextOne))) AND listFindNoCase(masterStateList, trim(tempText)) AND IsPrevTextCity EQ 1>
				<cfif not Len(Trim(qryLoad.PickupState[#rowNum#]))>
					<cfset QuerySetCell(qryLoad, "PickupState", trim(tempText), rowNum)>
				<cfelseif not Len(Trim(qryLoad.DelState[#rowNum#]))>
					<cfset QuerySetCell(qryLoad, "DelState", trim(tempText), rowNum)>
				</cfif>
				<cfset IsPrevTextCity = 0>
				<cfset tempText = "">
				<cfif NOT Len(trim(nextOne)) AND nextTwoThree EQ 'to' AND NOT Len(trim(nextFourth)) >
					<cfset charIndex=charIndex+4>
				</cfif>
			<cfelseif nextOne EQ delimiter OR charIndex EQ len(strText)>
				<cfif headerIndx GT 15>
					<cfset rowNum++>
					<cfset headerIndx = 1>
					<cfset QueryAddRow(qryLoad, 1)>
				</cfif>
				<cfset QuerySetCell(qryLoad, "Column_#headerIndx#", tempText, rowNum)>
				<cfset IsPrevTextCity = 0>
				<cfset headerIndx++>
				<cfset tempText = "">
			</cfif> 
			<cfset charIndex++>
		</cfloop>

		<cfreturn qryLoad>
	</cffunction>

	<cffunction name="AIImportData" access="public" returntype="struct" returnformat="json">
		<cfargument name="frmStruct" required="yes" type="struct">
		<cftry>
			<cfset arrLoad = arrayNew(1)>
			<cfset var CustomerNameFound = 0>
			<cfloop from="1" to="15" step="1" index="j">
				<cfif arguments.frmStruct["Column_#j#"] EQ "Customer Name">
					<cfset var CustomerNameFound = 1>
				</cfif>
			</cfloop>
			<cfif CustomerNameFound EQ 0>
				<cfset respStr = structNew()>
		    	<cfset respStr.res = 'error'>
		    	<cfset respStr.msg = "No Customer column found. Please choose one column for Customer Name.">
		    	<cfreturn respStr>
		    </cfif>
			<cftransaction>
				<cfloop from="1" to="#arguments.frmStruct.TotalCount#" step="1" index="i">
					<cfset var structLoad = structnew()>
					<cfset var OtherData = "">
					<cfset var NewDispatchNotes = "">
					<cfset structLoad['PickupCity'] = arguments.frmStruct["PickupCity_#i#"]>
					<cfset structLoad['PickupState'] = arguments.frmStruct["PickupState_#i#"]>
					<cfset structLoad['DelCity'] = arguments.frmStruct["DelCity_#i#"]>
					<cfset structLoad['DelState'] = arguments.frmStruct["DelState_#i#"]>
					<cfloop from="1" to="15" step="1" index="j">
						<cfset structLoad['#arguments.frmStruct["Column_#j#"]#'] = arguments.frmStruct["Column_#j#_#i#"]>
						<cfif arguments.frmStruct["Column_#j#"] EQ "Customer Name">
							<cfif structKeyExists(arguments.frmStruct, "Column_#j#_#i#_CustomerID")>
								<cfset structLoad['CustomerID'] =  arguments.frmStruct["Column_#j#_#i#_CustomerID"]>
							</cfif>
						</cfif>
						<cfif arguments.frmStruct["Column_#j#"] EQ "Column_#j#" AND len(trim(arguments.frmStruct["Column_#j#_#i#"]))>
							<cfset OtherData &= arguments.frmStruct["Column_#j#_#i#"] & chr(10)>
						</cfif>
					</cfloop>

					<cfif len(trim(OtherData))>
						<cfset NewDispatchNotes &= "#DateTimeFormat(now(),"mm/dd/yyyy h:nn: tt")# - #session.UserFullName# > Other Data from Import"  & chr(10) & OtherData>
					</cfif>

					<cfset var CustFlatRate = 0>
					<cfset var CarrFlatRate = 0>
					<cfset var Qty = 0>
					<cfset var Weight = 0>
					<cfset var PickupDate = "">
					<cfset var Deliverydate = "">

					<cfif structkeyexists(structLoad,"Customer Rate")>
						<cfset CustFlatRate = ReplaceNoCase(ReplaceNoCase(structLoad["Customer Rate"],'$','','ALL'),',','','ALL')>
	    				<cfif NOT len(trim(CustFlatRate)) OR NOT isNumeric(CustFlatRate)>
	    					<cfset CustFlatRate = 0>
	    				</cfif>
	    			</cfif>
	    			<cfif structkeyexists(structLoad,"Carrier Rate")>
						<cfset CarrFlatRate = ReplaceNoCase(ReplaceNoCase(structLoad["Carrier Rate"],'$','','ALL'),',','','ALL')>
	    				<cfif NOT len(trim(CarrFlatRate)) OR NOT isNumeric(CarrFlatRate)>
	    					<cfset CarrFlatRate = 0>
	    				</cfif>
	    			</cfif>
	    			<cfif structkeyexists(structLoad,"Qty") AND isNumeric(structLoad.Qty)>
	    				<cfset Qty = structLoad.Qty>
	    			</cfif>
	    			<cfif structkeyexists(structLoad,"Weight") AND isNumeric(structLoad.Weight)>
	    				<cfset Weight = structLoad.Weight>
	    			</cfif>
	    			<cfif structkeyexists(structLoad,"Pickup Date") AND isDate(structLoad["Pickup Date"])>
	    				<cfset PickupDate = structLoad["Pickup Date"]>
	    			</cfif>

	    			<cfif structkeyexists(structLoad,"Delivery Date") AND isDate(structLoad["Delivery Date"])>
	    				<cfset DeliveryDate = structLoad["Delivery Date"]>
	    			</cfif>

					<CFSTOREDPROC PROCEDURE="USP_InsertAIImportLoad" DATASOURCE="#variables.dsn#">
						<CFPROCPARAM VALUE="#session.CompanyID#" cfsqltype="CF_SQL_VARCHAR">
						<CFPROCPARAM VALUE="#session.EmpID#" cfsqltype="CF_SQL_VARCHAR">
						<CFPROCPARAM VALUE="#session.adminusername#" cfsqltype="CF_SQL_VARCHAR">
		    			<CFPROCPARAM VALUE="#cgi.REMOTE_ADDR#" cfsqltype="CF_SQL_VARCHAR">
		    			<cfif structkeyexists(structLoad,"CustomerID")>
		    				<CFPROCPARAM VALUE="#structLoad['CustomerID']#" cfsqltype="CF_SQL_VARCHAR">
		    			<cfelse>
		    				<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR" null="true">
		    			</cfif>
		    			<CFPROCPARAM VALUE="#structLoad['Customer Name']#" cfsqltype="CF_SQL_VARCHAR">
		    			<cfif structkeyexists(structLoad,"Equipment Name")>
		    				<CFPROCPARAM VALUE="#structLoad['Equipment Name']#" cfsqltype="CF_SQL_VARCHAR">
		    			<cfelse>
		    				<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR" null="true">
		    			</cfif>
		    			<cfif structkeyexists(structLoad,"Width") AND len(trim(structLoad.Width)) AND isNumeric(structLoad.Width)>
		    				<CFPROCPARAM VALUE="#structLoad['Width']#" cfsqltype="CF_SQL_FLOAT">
		    			<cfelse>
		    				<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_FLOAT" null="true">
		    			</cfif>
		    			<cfif structkeyexists(structLoad,"Length") AND len(trim(structLoad.Length)) AND isNumeric(structLoad.Length)>
		    				<CFPROCPARAM VALUE="#structLoad['Length']#" cfsqltype="CF_SQL_FLOAT">
		    			<cfelse>
		    				<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_FLOAT" null="true">
		    			</cfif>
		    			<CFPROCPARAM VALUE="#CustFlatRate#" cfsqltype="CF_SQL_FLOAT">
		    			<CFPROCPARAM VALUE="#CarrFlatRate#" cfsqltype="CF_SQL_FLOAT">

		    			<cfif structkeyexists(structLoad,"Internal Ref##")>
		    				<CFPROCPARAM VALUE="#structLoad['Internal Ref##']#" cfsqltype="CF_SQL_VARCHAR">
		    			<cfelse>
		    				<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR" null="true">
		    			</cfif>
		    			

		    			<CFPROCPARAM VALUE="#structLoad['PickupCity']#" cfsqltype="CF_SQL_VARCHAR">
		    			<CFPROCPARAM VALUE="#structLoad['PickupState']#" cfsqltype="CF_SQL_VARCHAR">
		    			<CFPROCPARAM VALUE="#structLoad['DelCity']#" cfsqltype="CF_SQL_VARCHAR">
		    			<CFPROCPARAM VALUE="#structLoad['DelState']#" cfsqltype="CF_SQL_VARCHAR">
		    			<cfif len(trim(PickupDate))>
		    				<CFPROCPARAM VALUE="#PickupDate#" cfsqltype="CF_SQL_DATE">
		    			<cfelse>
		    				<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_DATE" null="true">
		    			</cfif>
		    			<cfif len(trim(DeliveryDate))>
		    				<CFPROCPARAM VALUE="#DeliveryDate#" cfsqltype="CF_SQL_DATE">
		    			<cfelse>
		    				<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_DATE" null="true">
		    			</cfif>
		    			<CFPROCPARAM VALUE="#Qty#" cfsqltype="CF_SQL_FLOAT">
		    			<CFPROCPARAM VALUE="#Weight#" cfsqltype="CF_SQL_FLOAT">
		    			<cfif structkeyexists(structLoad,"Sales Rep") AND len(trim(structLoad['Sales Rep']))>
		    				<CFPROCPARAM VALUE="#structLoad['Sales Rep']#" cfsqltype="CF_SQL_VARCHAR">
		    			<cfelse>
		    				<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR" null="true">
		    			</cfif>
		    			<cfif structkeyexists(structLoad,"Dispatcher") AND len(trim(structLoad['Dispatcher']))>
		    				<CFPROCPARAM VALUE="#structLoad['Dispatcher']#" cfsqltype="CF_SQL_VARCHAR">
		    			<cfelse>
		    				<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR" null="true">
		    			</cfif>
		    			<cfif len(trim(arguments.frmStruct.StatusTypeID))>
		    				<CFPROCPARAM VALUE="#arguments.frmStruct.StatusTypeID#" cfsqltype="CF_SQL_VARCHAR">
		    			<cfelse>
		    				<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR" null="true">
		    			</cfif>
		    			<cfif structkeyexists(structLoad,"LTL")>
		    				<CFPROCPARAM VALUE="1" cfsqltype="CF_SQL_BIT">
		    			<cfelse>
		    				<CFPROCPARAM VALUE="0" cfsqltype="CF_SQL_BIT">
		    			</cfif>
		    			<cfif structkeyexists(structLoad,"Commodity")>
		    				<CFPROCPARAM VALUE="#structLoad['Commodity']#" cfsqltype="CF_SQL_VARCHAR">
		    			<cfelse>
		    				<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR" null="true">
		    			</cfif>
		    			<CFPROCPARAM VALUE="#left(NewDispatchNotes,4000)#" cfsqltype="CF_SQL_VARCHAR">
		    			<cfif structkeyexists(structLoad,"Public Notes") AND len(trim(structLoad['Public Notes']))>
		    				<CFPROCPARAM VALUE="#left(structLoad['Public Notes'],1000)#" cfsqltype="CF_SQL_VARCHAR">
		    			<cfelse>
		    				<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR" null="true">
		    			</cfif>

		    			<cfif structkeyexists(structLoad,"Pickup Name")>
		    				<CFPROCPARAM VALUE="#structLoad['Pickup Name']#" cfsqltype="CF_SQL_VARCHAR">
		    			<cfelse>
		    				<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR" null="true">
		    			</cfif>

		    			<cfif structkeyexists(structLoad,"Pickup Address")>
		    				<CFPROCPARAM VALUE="#structLoad['Pickup Address']#" cfsqltype="CF_SQL_VARCHAR">
		    			<cfelse>
		    				<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR" null="true">
		    			</cfif>

		    			<cfif structkeyexists(structLoad,"Pickup Contact")>
		    				<CFPROCPARAM VALUE="#structLoad['Pickup Contact']#" cfsqltype="CF_SQL_VARCHAR">
		    			<cfelse>
		    				<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR" null="true">
		    			</cfif>
		    			<cfif structkeyexists(structLoad,"Delivery Name")>
		    				<CFPROCPARAM VALUE="#structLoad['Delivery Name']#" cfsqltype="CF_SQL_VARCHAR">
		    			<cfelse>
		    				<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR" null="true">
		    			</cfif>

		    			<cfif structkeyexists(structLoad,"Delivery Address")>
		    				<CFPROCPARAM VALUE="#structLoad['Delivery Address']#" cfsqltype="CF_SQL_VARCHAR">
		    			<cfelse>
		    				<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR" null="true">
		    			</cfif>

		    			<cfif structkeyexists(structLoad,"Delivery Contact")>
		    				<CFPROCPARAM VALUE="#structLoad['Delivery Contact']#" cfsqltype="CF_SQL_VARCHAR">
		    			<cfelse>
		    				<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR" null="true">
		    			</cfif>
		    			<cfprocresult name="qLastInsertedLoad">
					</CFSTOREDPROC>
					<cfset var resLoad = structnew()>
					<cfset resLoad.LoadID = qLastInsertedLoad.LoadID>
					<cfset resLoad.LoadNumber = qLastInsertedLoad.LoadNumber>
					<cfset arrayAppend(arrLoad, resLoad)>
				</cfloop>

				<cfif structKeyExists(arguments.frmStruct, "NewTemplate") AND len(trim(arguments.frmStruct.NewTemplate))>
					<cfquery name="qInsTemplate" datasource="#variables.dsn#">
						INSERT INTO ImportTemplate (TemplateName,CreatedBy,LastModifiedBy,CompanyID
							<cfloop from="1" to="15" step="1" index="i">
								,Column_#i#
							</cfloop>
							)
						VALUES (
							<cfqueryparam value="#arguments.frmStruct.NewTemplate#" cfsqltype="cf_sql_varchar">
							,<cfqueryparam value="#session.adminusername#" cfsqltype="cf_sql_varchar">
							,<cfqueryparam value="#session.adminusername#" cfsqltype="cf_sql_varchar">
							,<cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar">
							<cfloop from="1" to="15" step="1" index="i">
								,<cfqueryparam value="#arguments.frmStruct['Column_#i#']#" cfsqltype="cf_sql_varchar">
							</cfloop>
							)
					</cfquery>
				</cfif>

			</cftransaction>

			<cfset var LoadMsg = "Loads">
			<cfloop from="1" to="#arrayLen(arrLoad)#" index="k">
				<cfset LoadMsg &= " <a href='index.cfm?event=addload&loadid=#arrLoad[k].loadid#&#session.URLToken#' target='_blank'>#arrLoad[k].LoadNumber#</a>">
				<cfif arrayLen(arrLoad) NEQ k>
					<cfset LoadMsg &= ",">
				</cfif>
			</cfloop>
			<cfset LoadMsg &= " Imported Successfully.">
			<cfset respStr = structNew()>
	    	<cfset respStr.res = 'success'>
	    	<cfset respStr.msg = LoadMsg>
	    	<cfreturn respStr>
			<cfcatch>
				<cfset CreateLogError(cfcatch)>
				<cfset respStr = structNew()>
		    	<cfset respStr.res = 'error'>
		    	<cfset respStr.msg = "Something went wrong. Unable to Import.">
		    	<cfreturn respStr>
			</cfcatch>
		</cftry>
	</cffunction>
	<cffunction name="CreateLogError" access="public" returntype="void">
		<cfargument name="Exception" type="any" required="true"/>
		<cfset var errordetail = "">
		<cfset var companycode = "">
		<cfset var template = "">
		<cfset var sourcepage = "">

		<cfif isDefined('arguments.Exception.cause.Detail') and isDefined('arguments.Exception.cause.Message')>
			<cfset errordetail = "#arguments.Exception.cause.Detail##arguments.Exception.cause.Message#">
		<cfelseif isDefined('arguments.Exception.Message') >
			<cfset errordetail = "#arguments.Exception.Message#">
		</cfif>

		<cfif structKeyExists(arguments.Exception, "TagContext") AND isArray(arguments.Exception.TagContext) AND NOT arrayIsEmpty(arguments.Exception.TagContext) AND isstruct(arguments.Exception.TagContext[1]) AND structKeyExists(arguments.Exception.TagContext[1], "raw_trace")>
			<cfset template = arguments.Exception.TagContext[1].raw_trace>
		</cfif>
		
		<cfif structKeyExists(session, "usercompanycode")>
			<cfset companycode ="["&session.usercompanycode&"]">
		</cfif>
		
		<cfif isDefined("cgi.HTTP_REFERER")>
			<cfset sourcepage = "#chr(10)#[Sourcepage]:#cgi.HTTP_REFERER#">
		</cfif>

		<cffile action="append" file="#ExpandPath("../webroot/logs")#/Application.Log.txt" output="#dateTimeFormat(now())##chr(10)##(companycode)##errordetail##chr(10)#[URLData]:#SerializeJSON(url)##chr(10)#[FormData]:#SerializeJSON(form)##chr(10)#[SessionData]:#SerializeJSON(session)##trim(template)##sourcepage#">

		<cfquery name="qInsLog" datasource="LoadManagerAdmin">
   			INSERT INTO LMErrorLog (CompanyCode,Detail,Status,FormData,URLData,Template,SourcePage)
   			VALUES (
   				<cfif structKeyExists(session, "usercompanycode")>
   					<cfqueryparam value="#session.usercompanycode#" cfsqltype="cf_sql_varchar">
   				<cfelse>
   					NULL
   				</cfif>
   				,<cfqueryparam value="#errordetail#" cfsqltype="cf_sql_varchar">
   				,'Pending'
   				<cfif isDefined("form")>
   					,<cfqueryparam value="#SerializeJSON(form)#" cfsqltype="cf_sql_varchar">
   				<cfelse>
   					,NULL
   				</cfif>
   				,<cfqueryparam value="#SerializeJSON(url)#" cfsqltype="cf_sql_varchar">
   				,<cfqueryparam value="#Template#" cfsqltype="cf_sql_varchar">
   				<cfif isDefined("cgi.HTTP_REFERER")>
   					,<cfqueryparam value="#cgi.HTTP_REFERER#" cfsqltype="cf_sql_varchar">
   				<cfelse>
   					,NULL
   				</cfif>
   				)
   		</cfquery>
   		<cfmail from='"support@loadmanager.com" <support@loadmanager.com>' subject="#left((stripHTML(trim(errordetail))),100)#" to="support@loadmanager.com" type="html" server="smtpout.secureserver.net" username="support@loadmanager.com" password="Wsi2008!" port="465" usessl="1" usetls="0">
   			<cfoutput>
   				<cfdump var="#arguments.Exception#">
   				<h2>URL Data:</h2>
   				<cfdump var="#url#">
   				<cfif isDefined("session")>
   					<h2>Session Data:</h2>
   					<cfdump var="#session#">
   				</cfif>
   				<cfif isDefined("form")>
   					<h2>Form Data:</h2>
   					<cfdump var="#form#">
   				</cfif>
   			</cfoutput>
   		</cfmail>
	</cffunction>

	<cffunction name="stripHTML" access="public" returntype="string">
		<cfargument name="str" required="yes" type="string">
		<cfscript>
		    // remove the whole tag and its content
		    var list = "style,script,noscript";
		    for (var tag in list){
		        str = reReplaceNoCase(str, "<s*(#tag#)[^>]*?>(.*?)","","all");
		    }

		    str = reReplaceNoCase(str, "<.*?>","","all");
		    //get partial html in front
		    str = reReplaceNoCase(str, "^.*?>","");
		    //get partial html at end
		    str = reReplaceNoCase(str, "<.*$","");

		    str = ReplaceNoCase(str, "&nbsp;","","ALL");
		    return trim(str);
		</cfscript>
	</cffunction>

	<cffunction name="GetTemplates" access="public" returntype="query">
		<cfquery name="qGetTemplates" datasource="#variables.dsn#">
			SELECT * FROM ImportTemplate WHERE CompanyID = <cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar">
		</cfquery>
		<cfreturn qGetTemplates>
	</cffunction>

	<cffunction name="getTemplateDetails" access="public" returntype="query">
		<cfargument name="TemplateID" required="yes" type="string">
		<cfquery name="qGetTemplateDetails" datasource="#variables.dsn#">
			SELECT * FROM ImportTemplate WHERE TemplateID = <cfqueryparam value="#arguments.TemplateID#" cfsqltype="cf_sql_varchar">
		</cfquery>
		<cfreturn qGetTemplateDetails>
	</cffunction>

	<cffunction name="sendPushNotification" access="public" returntype="boolean">
		<cfargument name="Driver1Cell" required="yes" type="string">
		<cfargument name="Driver2Cell" required="yes" type="string">
		<cfargument name="Driver3Cell" required="no" type="string" default="">
		<cfargument name="LoadID" required="no" type="string" default="">
		<cfargument name="LoadNumber" required="no" type="string" default="">
		<cftry>

			<cfif len(trim(arguments.LoadID))>>
				<cfquery name="qGetLoad" datasource="#variables.dsn#">
					SELECT COUNT(L.LoadID) AS LCount FROM Loads L
					INNER JOIN LoadStatusTypes LST ON LST.StatusTypeID = L.StatusTypeID
					INNER JOIN DriverLoads DL ON DL.LoadID = L.LoadID 
					WHERE L.LoadID = <cfqueryparam value="#arguments.LoadID#" cfsqltype="cf_sql_varchar">
					AND LST.AllowOnMobileWebApp = 1
					AND LEN(ISNULL(AcceptTermsAt,'')) <> 0
				</cfquery>
				<cfif qGetLoad.LCount EQ 0>
					<cfreturn 0>
				</cfif>
			</cfif>

			<cfset body = structNew()>
			<cfset data = structNew()>
			<cfset notification = structNew()>

			<cfif len(trim(arguments.LoadID))>
				<cfset notification["title"] = "Load #arguments.LoadNumber# has been updated">
				<cfset notification["body"] = "Click here to view more details.">
				<cfset data["type"] = "updateload">
			<cfelse>
				<cfset notification["title"] = "New load has been assigned">
				<cfset notification["body"] = "Click here to view more details.">
				<cfset data["type"] = "activeload">
			</cfif>

			<cfset body["notification"] = notification>
			<cfset body["data"] = data>

			<cfif len(trim(arguments.Driver1Cell))>
				<cfquery name="qGetDriverFirebase" datasource="#variables.dsn#">
					SELECT FirebaseToken FROM Drivers WHERE username = <cfqueryparam value="#arguments.Driver1Cell#" cfsqltype="cf_sql_varchar">
				</cfquery>
				<cfif qGetDriverFirebase.recordcount>
					<cfset body["to"] = "#qGetDriverFirebase.FirebaseToken#">
					<cfhttp url="https://fcm.googleapis.com/fcm/send" method="post" result="httpResponse">
					    <cfhttpparam type="header" name="Content-Type" value="application/json" />
					    <cfhttpparam type="header" name="Authorization" value="key=AAAAdqo-cek:APA91bE4N0GULDCoW9PkGf3gzl04YaQpik_L-WroRA1R9fo4tZgLVRGpuR0cvSd9ajfYkTj63_F1KjREjS6bXlKWX6v5Tvq6GmiTFqd_LuUuZv25XG1cDJbqn9Bs-XwN_R8W8saLKRTi" />
					    <cfhttpparam type="body" value="#SerializeJSON(Body)#" />
					</cfhttp>
				</cfif>
			</cfif>
			<cfif len(trim(arguments.Driver2Cell))>
				<cfquery name="qGetDriverFirebase" datasource="#variables.dsn#">
					SELECT FirebaseToken FROM Drivers WHERE username = <cfqueryparam value="#arguments.Driver2Cell#" cfsqltype="cf_sql_varchar">
				</cfquery>
				<cfif qGetDriverFirebase.recordcount>
					<cfset body["to"] = "#qGetDriverFirebase.FirebaseToken#">
					<cfhttp url="https://fcm.googleapis.com/fcm/send" method="post" result="httpResponse">
					    <cfhttpparam type="header" name="Content-Type" value="application/json" />
					    <cfhttpparam type="header" name="Authorization" value="key=AAAAdqo-cek:APA91bE4N0GULDCoW9PkGf3gzl04YaQpik_L-WroRA1R9fo4tZgLVRGpuR0cvSd9ajfYkTj63_F1KjREjS6bXlKWX6v5Tvq6GmiTFqd_LuUuZv25XG1cDJbqn9Bs-XwN_R8W8saLKRTi" />
					    <cfhttpparam type="body" value="#SerializeJSON(Body)#" />
					</cfhttp>
				</cfif>
			</cfif>
			<cfif len(trim(arguments.Driver3Cell))>
				<cfquery name="qGetDriverFirebase" datasource="#variables.dsn#">
					SELECT FirebaseToken FROM Drivers WHERE username = <cfqueryparam value="#arguments.Driver3Cell#" cfsqltype="cf_sql_varchar">
				</cfquery>
				<cfif qGetDriverFirebase.recordcount>
					<cfset body["to"] = "#qGetDriverFirebase.FirebaseToken#">
					<cfhttp url="https://fcm.googleapis.com/fcm/send" method="post" result="httpResponse">
					    <cfhttpparam type="header" name="Content-Type" value="application/json" />
					    <cfhttpparam type="header" name="Authorization" value="key=AAAAdqo-cek:APA91bE4N0GULDCoW9PkGf3gzl04YaQpik_L-WroRA1R9fo4tZgLVRGpuR0cvSd9ajfYkTj63_F1KjREjS6bXlKWX6v5Tvq6GmiTFqd_LuUuZv25XG1cDJbqn9Bs-XwN_R8W8saLKRTi" />
					    <cfhttpparam type="body" value="#SerializeJSON(Body)#" />
					</cfhttp>
				</cfif>
			</cfif>
			<cfcatch>
				<cfset CreateLogError(cfcatch)>
			</cfcatch>
		</cftry>
		<cfreturn 0>
	</cffunction>

	<cffunction name="getInfoBubble" access="public" returntype="struct">
		<cfquery name="qGetInfoBubble" datasource="LoadManagerAdmin">
			SELECT label,Information FROM InfoBubble
		</cfquery>

		<cfset retStruct = structNew()>
		<cfloop query="qGetInfoBubble">
			<cfset str = replaceNoCase(qGetInfoBubble.Information, chr(13), ' ','All')>
        	<cfset str = replaceNoCase(str, chr(10), ' ','All')>
			<cfset retStruct["#qGetInfoBubble.label#"] = str>
		</cfloop>

		<cfreturn retStruct>
	</cffunction>

	<cffunction name="sendMobileDispatchSupportNotice" access="public" returntype="void">
		<cfargument name="status" required="yes" type="string">

		<cfset SmtpAddress='smtpout.secureserver.net'>
		<cfset SmtpUsername='support@loadmanager.com '>
		<cfset SmtpPort='465'>
		<cfset SmtpPassword='Wsi2008!'>
		<cfset FA_SSL=1>
		<cfset FA_TLS=0>

		<cfquery name="qGetCompanyDetails" datasource="#variables.dsn#">
			SELECT C.CompanyCode,C.CompanyName,S.TextAPI FROM Companies C
			INNER JOIN SystemConfig S ON S.CompanyID = C.CompanyID
			WHERE C.CompanyID = <cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar">
		</cfquery>

		<cfmail from="#SmtpUsername#" subject="Mobile Dispatch Settings" to="#SmtpUsername#" type="html" server="#SmtpAddress#" username="#SmtpUsername#" password="#SmtpPassword#" port="#SmtpPort#" usessl="#FA_SSL#" usetls="#FA_TLS#" >
			<cfif arguments.status EQ 'ON'>
				User <b>#qGetCompanyDetails.CompanyCode#/#session.adminusername#</b> from <b>#qGetCompanyDetails.CompanyName#</b> has turned <b><u>ON</u></b> the Mobile App options for Dispatching. The required Texting option has also been turned on.
			<cfelse>
				User <b>#qGetCompanyDetails.CompanyCode#/#session.adminusername#</b> from <b>#qGetCompanyDetails.CompanyName#</b> has turned <b><u>OFF</u></b> the Mobile App options for Dispatching. The Texting option currently <cfif qGetCompanyDetails.TextAPI EQ 1>ON<cfelse>OFF</cfif>.
			</cfif>
		</cfmail>
	</cffunction>

	<cffunction name="validateMacropoint" access="public" returntype="boolean">
		<cfargument name="MacropointId" required="yes" type="string">
		<cfargument name="MacropointApiLogin" required="yes" type="string">
		<cfargument name="MacropointApiPassword" required="yes" type="string">

		<cftry>
			<cfset var MPAuth = toBase64('#trim(arguments.MacropointApiLogin)#:#trim(arguments.MacropointApiPassword)#')>

			<cfhttp url="https://macropoint-lite.com/api/1.0/carrier/requestpartnerstatus/#arguments.MacropointId#" method="GET">
			    <cfhttpparam type="HEADER" name="Authorization" value="Basic #MPAuth#">
			</cfhttp>

			<cfquery name="qGetCompanyDetails" datasource="#variables.dsn#">
				SELECT C.CompanyCode,C.CompanyName 
				FROM Companies C
				WHERE C.CompanyID = <cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar">
			</cfquery>

			<cfquery name="qIns" datasource="ZGPSTrackingMPWeb">
				IF (SELECT COUNT(*) FROM CompanyLookUp WHERE CompanyCode = '#qGetCompanyDetails.CompanyCode#')=0
					BEGIN
						insert into CompanyLookUp values ('#qGetCompanyDetails.CompanyCode#','#qGetCompanyDetails.CompanyName#')
					END
			</cfquery>

			<cfif cfhttp.statusCode EQ '401 Unauthorized'>
				<cfreturn 0>
			<cfelse>
				<cfreturn 1>
			</cfif>

			<cfcatch>
				<cfreturn 0>
			</cfcatch>
		</cftry>
	</cffunction>

	<cffunction name="getLoadDetailsForMailAlert" access="public" returntype="query">
		<cfargument name="LoadID" required="yes" type="string">
		<cfquery name="getLoadDetails" datasource="#Application.dsn#">
			SELECT 
				L.LoadNumber,
				L.TotalCarrierCharges,
				LS.StopNo,
				LS.LoadType,
				LS.StopDate,
				LS.StopTime,
				LS.CustName,
				LS.Address,
				LS.City,
				LS.StateCode,
				LS.PostalCode,
				E.Cel AS DispatcherCel,
				E.Telephone AS DispatcherTelePhone,
				E.EmailID AS DispatcherEmailID
				FROM Loads L 
				INNER JOIN LoadStops LS ON LS.LoadID = L.LoadID 
				LEFT JOIN Employees E ON E.EmployeeID = L.DispatcherID
			WHERE L.LoadID IN  (<cfqueryparam value="#arguments.LoadID#" cfsqltype="cf_sql_varchar" list="true">)
			ORDER BY L.LoadNumber,LS.StopNo,LS.LoadType
		</cfquery>
		<cfreturn getLoadDetails>
	</cffunction>
	<cffunction name="CheckLoadMissingAttachment" access="remote" output="yes" returntype="string" returnformat="json">
		<cfargument name="LoadID" type="string" required="yes">
		<cfargument name="CompanyID" type="string" required="yes">
		<cfargument name="dsn" type="string" required="yes">
		<cftry>
			<cfquery name="qGet" datasource="#arguments.dsn#">
				SELECT COUNT(AttachmentTypeID) AS MissingAttCount FROM FileAttachmentTypes WHERE AttachmentType ='Load' AND Required = 1 AND CompanyID = <cfqueryparam value="#arguments.CompanyID#" cfsqltype="cf_sql_varchar">
				AND AttachmentTypeID NOT IN (SELECT MFA.AttachmentTypeID FROM FileAttachments FA
				INNER JOIN MultipleFileAttachmentsTypes MFA ON FA.attachment_Id = MFA.AttachmentID
				WHERE FA.linked_Id=<cfqueryparam value="#arguments.LoadID#" cfsqltype="cf_sql_varchar" list="true">)
			</cfquery>
			<cfif qGet.MissingAttCount EQ 0>
				<cfreturn 0>
			<cfelse>
				<cfreturn 1>
			</cfif>
			<cfcatch>
				<cfreturn 0>
			</cfcatch>
		</cftry>

	</cffunction>

	<cffunction name="getCarrierReport" access="public" returntype="any">
		<cfargument name="LoadID" type="string" required="yes">
		<CFSTOREDPROC PROCEDURE="USP_GetCarrierReport" DATASOURCE="#Application.dsn#">
			<CFPROCPARAM VALUE="#arguments.LoadID#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCRESULT NAME="qCarrierReport">
		</CFSTOREDPROC>
		<cfreturn qCarrierReport>
	</cffunction>
	
	<cffunction name="getCustomerReport" access="public" returntype="any">
		<cfargument name="LoadID" type="string" required="yes">
		<cfif structkeyexists(url,"loadno") or (structkeyexists(url,"loadid")) AND isValid("regex", url.loadid,'^[{]?[0-9a-fA-F]{8}-([0-9a-fA-F]{4}-){3}[0-9a-fA-F]{12}[}]?$') OR NOT len(trim(url.loadid))>	
			<CFSTOREDPROC PROCEDURE="USP_GetCustomerReport" DATASOURCE="#Application.dsn#">
				<CFPROCPARAM VALUE="#arguments.LoadID#" cfsqltype="CF_SQL_VARCHAR">
				<CFPROCRESULT NAME="qCustomerReport">
			</CFSTOREDPROC>
			<cfreturn qCustomerReport>
		</cfif>
	</cffunction>
</cfcomponent>
