<cfscript>
	variables.objCutomerGateway = getGateway("gateways.customergateway", MakeParameters("dsn=#Application.dsn#,pwdExpiryDays=#Application.pwdExpiryDays#"));
	variables.objAgentGateway = getGateway("gateways.agentGateway", MakeParameters("dsn=#Application.dsn#,pwdExpiryDays=#Application.pwdExpiryDays#"));
</cfscript>
<cfif  request.event neq 'login' AND request.event neq 'customerlogin'>
		<cfif (not isdefined("session.passport.isLoggedIn") or not(session.passport.isLoggedIn))>
		<cfelse>
		<cfswitch expression="#request.event#">
			<cfcase value="customer">
				<cfset request.subnavigation = includeTemplate("views/admin/customerNav.cfm", true) />
				<cfset request.content = includeTemplate("views/pages/customer/disp_customer.cfm", true) />
				<cfset includeTemplate("views/templates/maintemplate.cfm") />
			</cfcase>
			<cfcase value="addnewcustomer">
				<cfset request.subnavigation = includeTemplate("views/admin/customerNav.cfm", true) />
				<cfset request.content=includeTemplate("views/pages/customer/addnew_customer.cfm",true)/>
				<cfset includeTemplate("views/templates/maintemplate.cfm") />  
			</cfcase>
			<cfcase value="addnewcustomer:process">
				<cfset request.subnavigation = includeTemplate("views/admin/customerNav.cfm", true) />
				<cfset request.content=includeTemplate("views/pages/customer/addnew_customer.cfm",true)/>
				<cfset includeTemplate("views/templates/maintemplate.cfm") />  
			</cfcase>
			<cfcase value="addcustomer">
				<cfif structKeyExists(url, "CustomerID") AND len(trim(url.customerid)) gt 1>
					<cfinvoke component="#variables.objCutomerGateway#" method="checkCustomerExists" CustomerID="#url.CustomerID#" returnvariable="CustomerCount">
					<cfif CustomerCount EQ 0>
						<cflocation url="index.cfm?event=customer" AddToken="Yes">
					</cfif>
				</cfif>
			     <cfinvoke component="#variables.objAgentGateway#" method="getOffices"  returnvariable="request.qOffices">
			     <cfinvoke component="#variables.objAgentGateway#" method="getAllCountries" returnvariable="request.qCountries" />
				 <cfinvoke component="#variables.objAgentGateway#" method="getAllStaes" returnvariable="request.qstates"/>
			     <cfinvoke component="#variables.objCutomerGateway#" method="getCompanies" returnvariable="request.qCompanies">
				 <cfinvoke component="#variables.objAgentGateway#" AuthLevelId="Sales Representative,Manager,Dispatcher,Administrator,Central Dispatcher,Data Entry" method="getSalesPerson" returnvariable="request.qSalesPerson" />
				 <cfinvoke component="#variables.objAgentGateway#" AuthLevelId="Dispatcher" method="getSalesPerson" returnvariable="request.qDispatcher" />  
                                             		   				                    
				 <cfset request.subnavigation = includeTemplate("views/admin/customerNav.cfm", true) />
				 <cfset request.content=includeTemplate("views/pages/customer/addcustomer.cfm",true)/>
				 <cfset includeTemplate("views/templates/maintemplate.cfm") />
			</cfcase>
            
			<cfcase value="addcustomer:process">
               
				 <cfset formStruct = structNew()>
				 <cfset formStruct = form>

                 <cfif isDefined("url.editid") and len(url.editid) gt 1>
                 	
                 	<cfinvoke component = "#variables.objCutomerGateway#" method="getUserEditingDetails" customerid = '#url.editid#' returnvariable="qUserEditing"/>
                 	              	 
             		<cfif structkeyexists(form,"customerdisabledStatus") and form.customerdisabledStatus neq true and qUserEditing.InUseBy eq session.empid>
                     	<cfinvoke component="#variables.objCutomerGateway#" method="updateCustomers" returnvariable="message">
				     		<cfinvokeargument name="formStruct" value="#formStruct#">
				     	</cfinvoke>  
				    <cfelse>
                    
				    	 <cfset message['msg']='Data not saved because it is edited by another person. Please contact administrator to unlock.'>	
				    </cfif> 	                                     
				 <cfelse>
                      <cfinvoke component="#variables.objCutomerGateway#" method="AddCustomer" returnvariable="message">
						<cfinvokeargument name="formStruct" value="#formStruct#">
                        <cfinvokeargument name="idReturn" value="true">
                     </cfinvoke>
				 </cfif>
					<cfif isDefined("message.msg") and len(message.msg) gt 1>
						<cfset session.message=message.msg>
					</cfif>
	                <cfif form.SaveAndExit eq 0 and isdefined('message.customerID')>
	                	<cflocation url="index.cfm?event=addcustomer&customerid=#message.customerID#" AddToken="Yes">
	                <cfelse>
	                	<cflocation url="index.cfm?event=customer" AddToken="Yes">
	                </cfif>
	                
	                <cfabort>
				 <cfset request.subnavigation = includeTemplate("views/admin/customerNav.cfm", true) />
				 <cfset request.content=includeTemplate("views/pages/customer/disp_customer.cfm",true)/>
				 <cfset includeTemplate("views/templates/maintemplate.cfm") />
			</cfcase>
            
			<cfcase value="stop">
				<cfset request.subnavigation = includeTemplate("views/admin/customerNav.cfm", true) />
				<cfset request.content = includeTemplate("views/pages/customer/disp_stop.cfm", true) />
				<cfset includeTemplate("views/templates/maintemplate.cfm") />
			</cfcase>
			<cfcase value="addstop">
				 <cfinvoke component="#variables.objAgentGateway#" method="getAllStaes" returnvariable="request.qstates"/>
			     <cfinvoke component="#variables.objCutomerGateway#" method="getAllCustomers" returnvariable="request.qCustomer" />
				 <cfset request.subnavigation = includeTemplate("views/admin/customerNav.cfm", true) />
				 <cfset request.content=includeTemplate("views/pages/customer/addStop.cfm",true)/>
				 <cfset includeTemplate("views/templates/maintemplate.cfm") />
			</cfcase>
			<cfcase value="addstop:process">
               
				 <cfset formStruct = structNew()>
				 <cfset formStruct = form>
                 
                 <cfif isDefined("url.editid") and len(url.editid) gt 1>
                     <cfinvoke component="#variables.objCutomerGateway#" method="updatestop" returnvariable="message">
				     <cfinvokeargument name="formStruct" value="#formStruct#">
				     </cfinvoke>                                          
				 <cfelse>
                      <cfinvoke component="#variables.objCutomerGateway#" method="AddStop" returnvariable="message">
						<cfinvokeargument name="formStruct" value="#formStruct#">
					 </cfinvoke>
				 </cfif>
				<cflocation url="index.cfm?event=stop&customerid=#formStruct.customerID#&#session.URLToken#" addtoken="no">
			</cfcase>
			<cfcase value="createconsolidatedinvoices">
				<cfset request.myLoadsAgentUserName = ''>
				<cfset request.subnavigation = includeTemplate("views/admin/customerNav.cfm", true) />
				<cfset request.content = includeTemplate("views/pages/customer/disp_consolidate_loads.cfm", true) />
				<cfset includeTemplate("views/templates/maintemplate.cfm") />
			</cfcase>
			<cfcase value="consolidatedinvoicequeue">
				<cfset request.myLoadsAgentUserName = ''>
				<cfset request.subnavigation = includeTemplate("views/admin/customerNav.cfm", true) />
				<cfset request.content = includeTemplate("views/pages/customer/disp_consolidate_invoice_queue.cfm", true) />
				<cfset includeTemplate("views/templates/maintemplate.cfm") />
			</cfcase>
			<cfcase value="consolidatedInvoiceMail">
				<cfset includeTemplate("reports/consolidatedInvoiceMail.cfm") />
			</cfcase>
			<cfcase value="editconsolidatedinvoicequeue">
				<cfset request.myLoadsAgentUserName = ''>
				<cfset request.subnavigation = includeTemplate("views/admin/customerNav.cfm", true) />
				<cfset request.content = includeTemplate("views/pages/customer/editconsolidatedinvoicequeue.cfm", true) />
				<cfset includeTemplate("views/templates/maintemplate.cfm") />
			</cfcase>
			<cfcase value="CRMNotes">
		    	<cfset request.subnavigation = includeTemplate("views/admin/customerNav.cfm", true) />
				<cfset request.content = includeTemplate("views/pages/customer/disp_crmNotes.cfm", true) />
				<cfset includeTemplate("views/templates/maintemplate.cfm") />
			</cfcase>
			<cfcase value="customerCRMCalls">
				<cfset request.subnavigation = includeTemplate("views/admin/customerNav.cfm", true) />
				<cfset request.content = includeTemplate("views/pages/customer/disp_customerCRMCalls.cfm", true) />
				<cfset includeTemplate("views/templates/maintemplate.cfm") />
			</cfcase>
			<cfcase value="customerCRMCallHistory">
				<cfset request.subnavigation = includeTemplate("views/admin/customerNav.cfm", true) />
				<cfset request.content = includeTemplate("views/pages/customer/disp_customerCRMCallHistory.cfm", true) />
				<cfset includeTemplate("views/templates/maintemplate.cfm") />
			</cfcase>
			<cfcase value="customerCRMReminder">
				<cfset request.subnavigation = includeTemplate("views/admin/customerNav.cfm", true) />
				<cfset request.content = includeTemplate("views/pages/customer/disp_customerCRMReminder.cfm", true) />
				<cfset includeTemplate("views/templates/maintemplate.cfm") />
			</cfcase>
			<cfcase value="CustomerContacts">
		    	<cfset request.subnavigation = includeTemplate("views/admin/customerNav.cfm", true) />
				<cfset request.content = includeTemplate("views/pages/customer/CustomerContacts.cfm", true) />
				<cfset includeTemplate("views/templates/maintemplate.cfm") />
			</cfcase>
			<cfcase value="addCustomerContact">
		    	<cfset request.subnavigation = includeTemplate("views/admin/customerNav.cfm", true) />
				<cfset request.content = includeTemplate("views/pages/customer/addCustomerContacts.cfm", true) />
				<cfset includeTemplate("views/templates/maintemplate.cfm") />
			</cfcase>
			<cfcase value="CustomerCsvImportLog">
				<cfset request.subnavigation = includeTemplate("views/admin/loadLogNav.cfm", true) />
				<cfset request.content = includeTemplate("views/pages/customer/disp_CustomerCsvImportLog.cfm", true) />
				<cfset includeTemplate("views/templates/maintemplate.cfm") />
			</cfcase>
			<cfcase value="saveScheduleCall">
				<cfinvoke component="#variables.objCustomerGateway#" method="saveScheduleCall" CustomerID="#url.CustomerID#" frmstruct="#form#"  returnvariable="session.CRMresponse" />
				
				<cfif form.submit eq 'Save'>
					<cflocation url="index.cfm?event=CRMNotes&CustomerID=#url.CustomerID#&#session.URLToken#" addtoken="no">
				<cfelse>
					<cfif structKeyExists(session, "CRMresponse")>
					    <cfset structdelete(session, 'CRMresponse', true)/> 
					</cfif>
					<cflocation url="index.cfm?event=customer&#session.URLToken#" addtoken="no">
				</cfif>
			</cfcase>
			<cfcase value="customerCRMCallDetail">
				<cfinvoke component="#variables.objCustomerGateway#" method="getCRMCallDetail" CRMNoteID="#url.CRMNoteID#" returnvariable="qCRMCallDetail" />
		    	<cfset request.subnavigation = includeTemplate("views/admin/customerNav.cfm", true) />
				<cfset request.content = includeTemplate("views/pages/customer/customerCRMCallDetail.cfm", true) />
				<cfset includeTemplate("views/templates/maintemplate.cfm") />
			</cfcase>
		</cfswitch>
		</cfif>
</cfif>
