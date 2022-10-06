<cfscript>
	variables.objequipmentGateway = getGateway("gateways.equipmentgateway", MakeParameters("dsn=#Application.dsn#,pwdExpiryDays=#Application.pwdExpiryDays#"));
</cfscript>
<cfif  request.event neq 'login' AND request.event neq 'customerlogin'>
		<cfif (not isdefined("session.passport.isLoggedIn") or not(session.passport.isLoggedIn))>
		<cfelse>
		<cfswitch expression="#request.event#">
			<cfcase value="equipment">
				<cfif structkeyexists(url,"EquipmentMaint")>
					<cfset variables.maintenanceWithEquipment = 0>
					<cfif structkeyexists(url,"maintenanceWithEquipment")  and url.maintenanceWithEquipment EQ 1>
						<cfset variables.maintenanceWithEquipment = 1>
					</cfif>
					<cfset variables.EquipmentMaint = 1>
				<cfelse>
					<cfset variables.EquipmentMaint = 0>
					<cfset variables.maintenanceWithEquipment = 0>
				</cfif>
				<cfinvoke component="#variables.objequipmentGateway#" method="getAllEquipments" EquipmentMaint="#variables.EquipmentMaint#" maintenanceWithEquipment="#variables.maintenanceWithEquipment#" returnvariable="request.qEquipments" />
				<cfset request.subnavigation = includeTemplate("views/admin/carrierNav.cfm", true) />
				<cfset request.content = includeTemplate("views/pages/equipment/disp_equipment.cfm", true) />
				<cfset includeTemplate("views/templates/maintemplate.cfm") />
			</cfcase>
			<cfcase value="addequipment">
                 <cfset request.subnavigation = includeTemplate("views/admin/carrierNav.cfm", true) />
				 <cfset request.content=includeTemplate("views/pages/equipment/addequipment.cfm",true)/>
				 <cfset includeTemplate("views/templates/maintemplate.cfm") />
			</cfcase>
			<cfcase value="addequipment:process">                   
				 <cfset formStruct = structNew()>
				 <cfset formStruct = form>
                 <cfif structkeyexists(form,"editid") and len(form.editid) gt 1>
                 	
                 	<cfinvoke component = "#variables.objEquipmentGateway#" method="getUserEditingDetails" equipmentid = '#form.editid#' returnvariable="qUserEditing"/>
                 	<cfif structkeyexists(form,"equipmentdisabledStatus") and form.equipmentdisabledStatus neq true and qUserEditing.InUseBy eq session.empid>
                 	
						<cfinvoke component="#variables.objequipmentGateway#" method="Updateequipment" returnvariable="message">
						   <cfinvokeargument name="formStruct" value="#formStruct#">
						 </cfinvoke>
						<cfinvoke component="#variables.objEquipmentGateway#" method="updateEditingUserId" equipmentid="" userid="#session.empid#" status="true"/> 
					<cfelse>
						<cfset message='Data not saved because it is edited by another person. Please contact administrator to unlock.'>
					</cfif>
				 <cfelse>	 
					 <cfinvoke component="#variables.objequipmentGateway#" method="Addequipment" returnvariable="message">
						<cfinvokeargument name="formStruct" value="#formStruct#">
					 </cfinvoke>
				 </cfif>
				 <cfif structKeyExists(form, "relocationEvent")>
				 	<cflocation url="index.cfm?event=OnboardEquipments&#session.URLToken#&EquipmentSaved=1" />
				 </cfif>
				 <cfif structKeyExists(form, "equipDriver")>
				 	<cfoutput>
					 	<script type="text/javascript">
							
								
						 		window.opener.location.reload();
					 			window.close();
					 	
				 		</script>
				 	</cfoutput>
			 		<cfabort>
				 </cfif>
				 <cfinvoke component="#variables.objequipmentGateway#" method="getAllEquipments" returnvariable="request.qEquipments" />
				 <cfset request.subnavigation = includeTemplate("views/admin/carrierNav.cfm", true) />
				 <cfset request.content=includeTemplate("views/pages/equipment/disp_equipment.cfm",true)/>
				 <cfset includeTemplate("views/templates/maintemplate.cfm") />
			</cfcase>
			<cfcase value="addDriverEquipment">
				<cfif structkeyexists(form,"equipmentId")>
					 <cfset formStruct = structNew()>
					<cfset formStruct = form>
					<cfinvoke component="#variables.objequipmentGateway#" method="insertEquipMaintInformation" returnvariable="message">
					   <cfinvokeargument name="formStruct" value="#formStruct#">
					   <cfinvokeargument name="IsCarrier" value="#url.IsCarrier#">
					 </cfinvoke>
				</cfif>
				<cfif structkeyexists(form,"equipmentIdForMainTrans")>
					 <cfset formStruct = structNew()>
					<cfset formStruct = form>
					<cfinvoke component="#variables.objequipmentGateway#" method="insertEquipMaintTransInformation" returnvariable="message">
					   <cfinvokeargument name="formStruct" value="#formStruct#">
					   <cfinvokeargument name="IsCarrier" value="#url.IsCarrier#">
					 </cfinvoke>
				</cfif>
				<cfset request.subnavigation = includeTemplate("views/admin/carrierNav.cfm", true) />
				<cfset request.content=includeTemplate("views/pages/equipment/addDriverEquipment.cfm",true)/>
				<cfset includeTemplate("views/templates/maintemplate.cfm") />
			</cfcase>
			<cfcase value="maintenanceSetUp">
				<cfinvoke component="#variables.objequipmentGateway#" method="getMaintenanceInformation" returnvariable="request.qGetMaintenanceInformation" />
                 <cfset request.subnavigation = includeTemplate("views/admin/carrierNav.cfm", true) />
				 <cfset request.content=includeTemplate("views/pages/equipment/disp_maintenanceSetup.cfm",true)/>
				 <cfset includeTemplate("views/templates/maintemplate.cfm") />
			</cfcase>
			<cfcase value="addMaintenanceSetUp">
                 <cfset request.subnavigation = includeTemplate("views/admin/carrierNav.cfm", true) />
				 <cfset request.content=includeTemplate("views/pages/equipment/addMaintenanceSetUp.cfm",true)/>
				 <cfset includeTemplate("views/templates/maintemplate.cfm") />
			</cfcase>
			<cfcase value="addmaintenance:process">                   
				 <cfset formStruct = structNew()>
				 <cfset formStruct = form>
                 <cfif structkeyexists(form,"editid") and len(form.editid) gt 0>
					<cfinvoke component="#variables.objequipmentGateway#" method="UpdateMaintenanceInformation" returnvariable="message">
					   <cfinvokeargument name="formStruct" value="#formStruct#">
					 </cfinvoke>
				 <cfelse>	 
					 <cfinvoke component="#variables.objequipmentGateway#" method="AddMaintenanceInformation" returnvariable="message">
						<cfinvokeargument name="formStruct" value="#formStruct#">
					 </cfinvoke>
				 </cfif>
				 <cfinvoke component="#variables.objequipmentGateway#" method="getMaintenanceInformation" returnvariable="request.qGetMaintenanceInformation" />
				 <cfset request.subnavigation = includeTemplate("views/admin/carrierNav.cfm", true) />
				 <cfset request.content=includeTemplate("views/pages/equipment/disp_maintenanceSetup.cfm",true)/>
				 <cfset includeTemplate("views/templates/maintemplate.cfm") />
			</cfcase>
			<cfcase value="addNewMaintenance">
				<cfset request.subnavigation = includeTemplate("views/admin/carrierNav.cfm", true) />
				<cfset request.content=includeTemplate("views/pages/equipment/addNewMaintenance.cfm",true)/>
				<cfset includeTemplate("views/templates/maintemplate.cfm") />
			</cfcase>
			<cfcase value="addNewMaintenance:process">
				<cfset formStruct = structNew()>
				<cfset formStruct = form>
				<cfif structkeyexists(form,"equipmentId")>
					<cfif structkeyexists(form,"editEquipmentmMaintId") and len(trim(formStruct.editEquipmentmMaintId)) gt 0>
						<cfinvoke component="#variables.objequipmentGateway#" method="updadeEquipMaintInformation" returnvariable="message">
							<cfinvokeargument name="formStruct" value="#formStruct#">
							<cfinvokeargument name="IsCarrier" value="#url.isCarrier#">
						</cfinvoke>
					<cfelse>
						<cfinvoke component="#variables.objequipmentGateway#" method="insertEquipMaintInformation" returnvariable="message">
						   <cfinvokeargument name="formStruct" value="#formStruct#">
						   <cfinvokeargument name="IsCarrier" value="#url.isCarrier#">
						</cfinvoke>
					</cfif>	
				</cfif>
				<cfset request.subnavigation = includeTemplate("views/admin/carrierNav.cfm", true) />
				<cfset request.content=includeTemplate("views/pages/equipment/addDriverEquipment.cfm",true)/>
				<cfset includeTemplate("views/templates/maintemplate.cfm") /> 
			</cfcase>
			<cfcase value="addNewMaintenanceTransaction">
				<cfset request.subnavigation = includeTemplate("views/admin/carrierNav.cfm", true) />
				<cfset request.content=includeTemplate("views/pages/equipment/addNewMaintenanceTransaction.cfm",true)/>
				<cfset includeTemplate("views/templates/maintemplate.cfm") />
			</cfcase>
			<cfcase value="iftaDownload">
				<cfif structkeyexists(url,"getExcel")>
					<cfset includeTemplate("views/pages/equipment/getExcel.cfm") />
				</cfif>
				<cfset request.subnavigation = includeTemplate("views/admin/carrierNav.cfm", true) />
				<cfset request.content=includeTemplate("views/pages/equipment/ifta_export.cfm",true)/>
				<cfset includeTemplate("views/templates/maintemplate.cfm") />
			</cfcase>
			<cfcase value="ExpenseSetUp">
				<cfinvoke component="#variables.objequipmentGateway#" method="getExpenseInformation" returnvariable="request.qGetExpenseInformation" />
                 <cfset request.subnavigation = includeTemplate("views/admin/carrierNav.cfm", true) />
				 <cfset request.content=includeTemplate("views/pages/equipment/disp_ExpenseSetup.cfm",true)/>
				 <cfset includeTemplate("views/templates/maintemplate.cfm") />
			</cfcase>
			<cfcase value="AddExpenseSetUp">
                 <cfset request.subnavigation = includeTemplate("views/admin/carrierNav.cfm", true) />
				 <cfset request.content=includeTemplate("views/pages/equipment/addExpenseSetUp.cfm",true)/>
				 <cfset includeTemplate("views/templates/maintemplate.cfm") />
			</cfcase>
			<cfcase value="AddExpenseSetUp:process">                   
				 <cfset formStruct = structNew()>
				 <cfset formStruct = form>
                 <cfif structkeyexists(form,"editid") and len(form.editid) gt 0>
					<cfinvoke component="#variables.objequipmentGateway#" method="UpdateExpenseSetup" returnvariable="message">
					   <cfinvokeargument name="formStruct" value="#formStruct#">
					 </cfinvoke>
				 <cfelse>	 
					 <cfinvoke component="#variables.objequipmentGateway#" method="AddExpenseSetup" returnvariable="message">
						<cfinvokeargument name="formStruct" value="#formStruct#">
					 </cfinvoke>
				 </cfif>
				 <cfinvoke component="#variables.objequipmentGateway#" method="getExpenseInformation" returnvariable="request.qGetExpenseInformation" />
				 <cfset request.subnavigation = includeTemplate("views/admin/carrierNav.cfm", true) />
				 <cfset request.content=includeTemplate("views/pages/equipment/disp_ExpenseSetup.cfm",true)/>
				 <cfset includeTemplate("views/templates/maintemplate.cfm") />
			</cfcase>
			<cfcase value="addDriverExpense">
                 <cfset request.subnavigation = includeTemplate("views/admin/carrierNav.cfm", true) />
				 <cfset request.content=includeTemplate("views/pages/equipment/addCarrierExpense.cfm",true)/>
				 <cfset includeTemplate("views/templates/maintemplate.cfm") />
			</cfcase>
			<cfcase value="addDriverExpense:process">
				<cfset formStruct = structNew()>
				<cfset formStruct = form>
		
				<cfif structkeyexists(form,"editid") and len(trim(formStruct.editid)) gt 0>
					<cfinvoke component="#variables.objequipmentGateway#" method="updadeCarrierExpense" returnvariable="message">
						<cfinvokeargument name="formStruct" value="#formStruct#">
					</cfinvoke>
				<cfelse>
					<cfinvoke component="#variables.objequipmentGateway#" method="insertCarrierExpense" returnvariable="message">
					   <cfinvokeargument name="formStruct" value="#formStruct#">
					</cfinvoke>
				</cfif>	
				<cfif structkeyexists(url,'isCarrier')>
					<cflocation url="index.cfm?event=adddriver&carrierid=#driverid##session.URLToken#&isCarrier=#url.isCarrier#&expmessage=#message#" /> 
					<cfelse>
						<cflocation url="index.cfm?event=adddriver&carrierid=#driverid##session.URLToken#&expmessage=#message#" />
				</cfif>
			</cfcase>
			<cfcase value="delDriverExpense">
		
				<cfinvoke component="#variables.objequipmentGateway#" method="deleteCarrierExpense" carrierExpenseID="#url.carrierExpenseID#" returnvariable="message">
				</cfinvoke>
	
				<cflocation url="index.cfm?event=adddriver&carrierid=#driverid##session.URLToken#&isCarrier=#url.isCarrier#&expmessage=#message#" /> 
			</cfcase>
			<cfcase value="addRecurringExpense">
                 <cfset request.subnavigation = includeTemplate("views/admin/carrierNav.cfm", true) />
				 <cfset request.content=includeTemplate("views/pages/equipment/addRecurringExpense.cfm",true)/>
				 <cfset includeTemplate("views/templates/maintemplate.cfm") />
			</cfcase>

			<cfcase value="addRecurringDriverExpense:process">
				<cfset formStruct = structNew()>
				<cfset formStruct = form>
		
				<cfif structkeyexists(form,"editid") and len(trim(formStruct.editid)) gt 0>
					<cfinvoke component="#variables.objequipmentGateway#" method="updateRecurringCarrierExpense" returnvariable="message">
						<cfinvokeargument name="formStruct" value="#formStruct#">
					</cfinvoke>
				<cfelse>
					<cfinvoke component="#variables.objequipmentGateway#" method="insertRecurringCarrierExpense" returnvariable="message">
					   <cfinvokeargument name="formStruct" value="#formStruct#">
					</cfinvoke>
				</cfif>	
	
				<cflocation url="index.cfm?event=adddriver&carrierid=#driverid##session.URLToken#&isCarrier=#url.isCarrier#&expmessage=#message#" /> 
			</cfcase>

			<cfcase value="delRecurringDriverExpense">
		
				<cfinvoke component="#variables.objequipmentGateway#" method="deleteRecurringCarrierExpense" carrierExpenseRecurringID="#url.carrierExpenseRecurringID#" returnvariable="message">
				</cfinvoke>
	
				<cflocation url="index.cfm?event=adddriver&carrierid=#driverid##session.URLToken#&isCarrier=#url.isCarrier#&expmessage=#message#" /> 
			</cfcase>

			<cfcase value="generateRecurringDriverExpenses">
		
				<cfinvoke component="#variables.objequipmentGateway#" method="generateRecurringDriverExpenses" CompanyID="#session.CompanyID#" driverid="#url.driverid#" returnvariable="message">
				</cfinvoke>
	
				<cflocation url="index.cfm?event=adddriver&carrierid=#driverid##session.URLToken#&isCarrier=#url.isCarrier#&expmessage=#message#" /> 
			</cfcase>
			<cfcase value="EquipmentCsvImportLog">
				<cfset request.subnavigation = includeTemplate("views/admin/loadLogNav.cfm", true) />
				<cfset request.content = includeTemplate("views/pages/equipment/disp_EquipmentCsvImportLog.cfm", true) />
				<cfset includeTemplate("views/templates/maintemplate.cfm") />
			</cfcase>
            <cfdefaultcase>
			</cfdefaultcase>
		</cfswitch>
		</cfif>
</cfif>
