<cfscript>
	variables.objCarrierGateway = getGateway("gateways.carrierGateway", MakeParameters("dsn=#Application.dsn#,pwdExpiryDays=#Application.pwdExpiryDays#"));
	variables.objequipmentGateway = getGateway("gateways.equipmentGateway", MakeParameters("dsn=#Application.dsn#,pwdExpiryDays=#Application.pwdExpiryDays#"));
</cfscript>

<cfif  request.event neq 'login' AND request.event neq 'customerlogin'>
		<cfif (not isdefined("session.passport.isLoggedIn") or not(session.passport.isLoggedIn))>
		<cfelse>
		<cfswitch expression="#request.event#">
			<cfcase value="carrier">
				<cfset request.subnavigation = includeTemplate("views/admin/carriernav.cfm", true) />
				<cfset request.content = includeTemplate("views/pages/carrier/disp_carrier.cfm", true) />
				<cfset includeTemplate("views/templates/maintemplate.cfm") />
			</cfcase>
            
            <cfcase value="carrierselection">
				<cfset request.subnavigation = includeTemplate("views/admin/carriernav.cfm", true) />
				<cfset request.content = includeTemplate("views/pages/carrier/disp_carrier_selection.cfm", true) />
				<cfset includeTemplate("views/templates/maintemplate.cfm") />
			</cfcase>
            
			<cfcase value="addnewcarrier">
				<cfset request.subnavigation = includeTemplate("views/admin/carriernav.cfm", true) />
				<cfset request.content=includeTemplate("views/pages/carrier/addnew_carrier.cfm",true)/>
				<cfset includeTemplate("views/templates/maintemplate.cfm") />  
			</cfcase>
			<cfcase value="addnewcarrier:process">
			  <cfset request.subnavigation = includeTemplate("views/admin/carriernav.cfm", true) />
			  <cfset request.content=includeTemplate("views/pages/carrier/addnew_carrier.cfm",true)/>
			  <cfset includeTemplate("views/templates/maintemplate.cfm") /> 
			</cfcase>
			<cfcase value="addcarrier">
				<cfif structkeyexists(url,"carrierid") and len(trim(url.carrierid))>
					<cfinvoke component = "#variables.objCarrierGateway#" method="GetExpiredDocuments" carrierid = "#url.carrierid#" returnvariable="request.qGetExpiredDocuments"/>
					<cfinvoke component = "#variables.objCarrierGateway#" method="GetExpiredInsurance" carrierid = "#url.carrierid#" returnvariable="request.qGetExpiredInsurance"/>
				</cfif>
				<cfinvoke component="#variables.objAgentGateway#" method="getAllCountries" returnvariable="request.qCountries" />
				<cfinvoke component="#variables.objAgentGateway#" method="getAllStaes" returnvariable="request.qstates"/>
				<cfinvoke component="#variables.objequipmentGateway#" method="getAllEquipments" returnvariable="request.qEquipments" />
                  			
				 <cfset request.subnavigation = includeTemplate("views/admin/carriernav.cfm", true) />
				 <cfset request.content=includeTemplate("views/pages/carrier/add_carrier.cfm",true)/>
				 <cfset includeTemplate("views/templates/maintemplate.cfm") />
			</cfcase>        
           
			<cfcase value="addcarrier:process">
				 <cfset CarrMessage="">
                 <cfset formStruct = structNew()>
                 <cfset duplicateVendorId = 0>
				 <cfset formStruct = form>	
				 <cfset url.IsCarrier = 1>	
				 <cfif structIsEmpty(form)>
				 	<cflocation url="index.cfm?event=carrier&#Session.URLToken#&IsCarrier=1" addtoken="no">
				 </cfif>		 
                 <cfif isdefined("form.editid") and len(form.editId) gt 1>

                 	<cfinvoke component = "#variables.objCarrierGateway#" method="getUserEditingDetails" carrierid = '#form.editid#' returnvariable="qUserEditing"/>                 	

                 	<cfif structkeyexists(form,"carrierdisabledStatus") and form.carrierdisabledStatus neq true and qUserEditing.InUseBy eq session.empid>

					<cfinvoke component="#variables.objCarrierGateway#" method="UpdateCarrier" returnvariable="message">
						<cfinvokeargument name="formStruct" value="#formStruct#">
				    </cfinvoke>		
                    
                    <cfset duplicateVendorId = message.duplicateVendorId>
                    <cfset CarrMessage=message.msg>
				    <cfif isDefined("duplicateVendorId") AND duplicateVendorId NEQ 1>
						<cfif formStruct.SaferWatch EQ 1 >
							<cfinvoke component="#variables.objCarrierGateway#" method="UpdateWatchList" returnvariable="message">
								<cfinvokeargument name="DOTNumber" value="#formStruct.DOTNumber#">
								<cfinvokeargument name="MCNumber" value="#formStruct.MCNumber#"> 
								<cfinvokeargument name="SaferWatch" value="#formStruct.SaferWatch#">
								<cfif  StructKeyExists(formStruct,"bit_addWatch")>
									<cfinvokeargument name="bit_addWatch" value="#formStruct.bit_addWatch#">   
								<cfelse>
									<cfinvokeargument name="bit_addWatch" value="0">
								</cfif>
								<cfinvokeargument name="editid" value="#formStruct.editid#">					    
							</cfinvoke>
						</cfif>
						<cfloop from="1" to="5" index="fldID"> 
							<cfinvoke component="#variables.objCarrierGateway#" method="UpdateCarrierOffices" returnvariable="message">
								<cfinvokeargument name="formStruct" value="#formStruct#">
							    <cfinvokeargument name="fieldID" value="#fldid#">               
				            </cfinvoke>
		                </cfloop>
		            </cfif>
		     		</cfif>
                    
                     <cfif form.SaveAndExit eq 0 > <!-------save---->
                    <cflocation url="index.cfm?event=addcarrier&carrierid=#form.editid#&#session.URLToken#&IsCarrier=1&CarrMessage=#CarrMessage#" addtoken="no">
                    <cfelse><!---------save & exit-------->
                     <cflocation url="index.cfm?event=carrier&#Session.URLToken#&IsCarrier=1" addtoken="no">
                    </cfif>
				 <cfelse>	 
				 
                   <cfinvoke component="#variables.objCarrierGateway#" method="AddCarrier" returnvariable="message">
						<cfinvokeargument name="formStruct" value="#formStruct#">
					 </cfinvoke>
					<cfset CarrMessage=message.msg>
                    <cfset duplicateVendorId=message.duplicateVendorId>
					<cfif structkeyexists(message, "Carrier_Id")>
						<cfset Carrier_Id=message.Carrier_Id>
					</cfif>
                    
					<cfif isDefined("duplicateVendorId") AND duplicateVendorId NEQ 1>
						 <cfif StructKeyExists(form,"SaferWatch") AND  form.SaferWatch EQ 1 >
							<cfinvoke component="#variables.objCarrierGateway#" method="AddWatch" returnvariable="message">
								<cfinvokeargument name="DOTNumber" value="#formStruct.DOTNumber#">
								<cfinvokeargument name="MCNumber" value="MC#formStruct.MCNumber#">
							</cfinvoke>
						 </cfif>
						<cfinvoke component="#variables.objCarrierGateway#" method="AddLIWebsiteData" carrierid="#Carrier_Id#" returnvariable="message">
							 <cfinvokeargument name="formStruct" value="#formStruct#">
						 </cfinvoke>
						<cfloop from="1" to="5" index="fldID">    
							 <cfinvoke component="#variables.objCarrierGateway#" method="AddCarrierOffices" returnvariable="message">
							     <cfinvokeargument name="formStruct" value="#formStruct#">
							     <cfinvokeargument name="fieldID" value="#fldid#">               
							 </cfinvoke> 
		                </cfloop>        
		            </cfif>
				 </cfif>
				 


				 	<cfset local.SaveAndExit = 0>
				 	<cfif structKeyExists(form, "SaveAndExit")>
				 		<cfset local.SaveAndExit = form.SaveAndExit>
				 	</cfif>

				 	<cfif structKeyExists(form, "CarrierQuoteID")>
				 		<cfinvoke component="#variables.objCarrierGateway#" method="UpdateQuotecarrier" carrierid="#Carrier_Id#" CarrierQuoteID='#form.CarrierQuoteID#' returnvariable="message">
					 	<cfoutput>
					 		<script>
					 			window.opener.HandlePopupResult('#Carrier_Id#',#form.CarrierQuoteID#,'#form.QStopno#','#form.QAmount#',<cfif local.SaveAndExit eq 0>0<cfelse>1</cfif>);
					 			window.close();
					 		</script>
					 	</cfoutput>
					 	<cfabort>
					 </cfif>
				 

                 	<cfif local.SaveAndExit eq 0 and duplicateVendorId eq 0> <!-------save---->
                    <cflocation url="index.cfm?event=addcarrier&carrierid=#Carrier_Id#&#session.URLToken#&IsCarrier=1&CarrMessage=#CarrMessage#" addtoken="no">
                    <cfelse><!---------save & exit-------->
                     <cflocation url="index.cfm?event=carrier&#Session.URLToken#&IsCarrier=1" addtoken="no">
                    </cfif>
        	</cfcase>
			
			<cfcase value="adddriver">
				<cfif NOT ListContains(session.rightsList,'editDrivers',',')>					
					<cflocation url="index.cfm?event=login">
					<cfabort>
				</cfif>
				<cfinvoke component="#variables.objAgentGateway#" method="getAllCountries" returnvariable="request.qCountries" />
				<cfinvoke component="#variables.objAgentGateway#" method="getAllStaes" returnvariable="request.qstates"/>
				<cfinvoke component="#variables.objequipmentGateway#" method="getAllEquipments" returnvariable="request.qEquipments" />
                <cfset request.subnavigation = includeTemplate("views/admin/carriernav.cfm", true) />
                <cfset request.content=includeTemplate("views/pages/carrier/add_driver.cfm",true)/>
				<cfset includeTemplate("views/templates/maintemplate.cfm") />
			</cfcase>        
           
			<cfcase value="adddriver:process">				
				<cfif NOT ListContains(session.rightsList,'editDrivers',',')>					
					<cflocation url="index.cfm?event=login">
					<cfabort>
				</cfif>

				<cfif structIsEmpty(form)>
					<cflocation url="index.cfm?event=carrier&#session.URLToken#&IsCarrier=0" />
				</cfif>
		
				<cfset formStruct = structNew()>
				<cfset formStruct = form>
				<cfset url.IsCarrier = 0>
				<cfif isdefined("form.editid") and len(form.editId) gt 1>
				<cfif ListContains(session.rightsList,'editDrivers',',')>

					<cfinvoke component = "#variables.objCarrierGateway#" method="getUserEditingDetails" carrierid = '#form.editid#' returnvariable="qUserEditing"/>

					<cfif structkeyexists(form,"carrierdisabledStatus") and form.carrierdisabledStatus neq true and qUserEditing.InUseBy eq session.empid>
						<cfinvoke component="#variables.objCarrierGateway#" method="UpdateDriver" returnvariable="message">
							<cfinvokeargument name="formStruct" value="#formStruct#">
						</cfinvoke>
					<cfelse>
						<cfif form.SaveAndExit eq 0 and isdefined('message.driverID')>
							 <cfset session.message = "Data not saved">
							<cflocation url="index.cfm?event=adddriver&carrierid=#form.editid#&#session.URLToken#&IsCarrier=0" addtoken="no">
						<cfelse>
							<cflocation url="index.cfm?event=carrier&#Session.URLToken#&IsCarrier=0">
						</cfif>
						<cfabort/>
					</cfif>

				</cfif>
				<cfelse>	 
					<cfinvoke component="#variables.objCarrierGateway#" method="AddDriver" returnvariable="message">
						<cfinvokeargument name="formStruct" value="#formStruct#">
					</cfinvoke>
					<cfinvoke component="#variables.objCarrierGateway#" method="AddLIWebsiteData" carrierid="#message.driverID#" returnvariable="message1">
						<cfinvokeargument name="formStruct" value="#formStruct#">
					</cfinvoke>					     
				</cfif>
                
				<cfif isdefined("form.editid") and len(form.editId) gt 1>
					<cfset session.message=message.msg>
				<cfelse>
						<cfset session.message= "">
				</cfif>
                <cfif form.SaveAndExit eq 0 and isdefined('message.driverID')>
                	<cflocation url="index.cfm?event=adddriver&carrierid=#message.driverID#&#session.URLToken#&IsCarrier=0" addtoken="no">
                <cfelse>
                	<cflocation url="index.cfm?event=carrier&#Session.URLToken#&IsCarrier=0">
                </cfif>
                		
			</cfcase>
			<cfcase value="bulkEmail">
				<cfset includeTemplate("views/pages/carrier/bulkEmail_carrier_driver.cfm")/>
			</cfcase>
			<cfcase value="CarrierCRMNotes">
		    	<cfset request.subnavigation = includeTemplate("views/admin/carrierNav.cfm", true) />
				<cfset request.content = includeTemplate("views/pages/carrier/disp_carrierCrmNotes.cfm", true) />
				<cfset includeTemplate("views/templates/maintemplate.cfm") />
			</cfcase>
			<cfcase value="carrierCRMCalls">
				<cfset request.subnavigation = includeTemplate("views/admin/carrierNav.cfm", true) />
				<cfset request.content = includeTemplate("views/pages/carrier/disp_carrierCRMCalls.cfm", true) />
				<cfset includeTemplate("views/templates/maintemplate.cfm") />
			</cfcase>
			<cfcase value="carrierCRMReminder">
				<cfset request.subnavigation = includeTemplate("views/admin/carrierNav.cfm", true) />
				<cfset request.content = includeTemplate("views/pages/carrier/disp_carrierCRMReminder.cfm", true) />
				<cfset includeTemplate("views/templates/maintemplate.cfm") />
			</cfcase>
			<cfcase value="CarrierContacts">
		    	<cfset request.subnavigation = includeTemplate("views/admin/carrierNav.cfm", true) />
				<cfset request.content = includeTemplate("views/pages/carrier/CarrierContacts.cfm", true) />
				<cfset includeTemplate("views/templates/maintemplate.cfm") />
			</cfcase>
			<cfcase value="addCarrierContact">
		    	<cfset request.subnavigation = includeTemplate("views/admin/carrierNav.cfm", true) />
				<cfset request.content = includeTemplate("views/pages/carrier/addCarrierContact.cfm", true) />
				<cfset includeTemplate("views/templates/maintemplate.cfm") />
			</cfcase>
			<cfcase value="CarrierLookup">
		    	<cfset request.subnavigation = includeTemplate("views/admin/carrierNav.cfm", true) />
				<cfset request.content = includeTemplate("views/pages/carrier/disp_CarrierLookup.cfm", true) />
				<cfset includeTemplate("views/templates/maintemplate.cfm") />
			</cfcase>
			<cfcase value="CarrierCsvImportLog">
				<cfset request.subnavigation = includeTemplate("views/admin/loadLogNav.cfm", true) />
				<cfset request.content = includeTemplate("views/pages/carrier/disp_CarrierCsvImportLog.cfm", true) />
				<cfset includeTemplate("views/templates/maintemplate.cfm") />
			</cfcase>
			<cfcase value="CarrierLanes">
		    	<cfset request.subnavigation = includeTemplate("views/admin/carrierNav.cfm", true) />
				<cfset request.content = includeTemplate("views/pages/carrier/disp_CarrierLanes.cfm", true) />
				<cfset includeTemplate("views/templates/maintemplate.cfm") />
			</cfcase>
			<cfcase value="CarrierAdvancedSearch">
              <cfinvoke component="#variables.objAgentGateway#" method="getAllStaes" returnvariable="request.qStates">
              <cfinvoke component="#variables.objequipmentGateway#" method="getloadEquipments" returnvariable="request.qEquipments" />
              <cfset request.subnavigation = includeTemplate("views/admin/carrierNav.cfm", true) />
              <cfset request.content=includeTemplate("views/pages/carrier/advancedsearch.cfm",true)/>
              <cfset includeTemplate("views/templates/maintemplate.cfm") />
            </cfcase>
            <cfcase value="CarrierAdvanced">
				<cfset request.subnavigation = includeTemplate("views/admin/carriernav.cfm", true) />
				<cfset request.content = includeTemplate("views/pages/carrier/disp_CarrierAdvanced.cfm", true) />
				<cfset includeTemplate("views/templates/maintemplate.cfm") />
			</cfcase>
			<cfcase value="UpdateViaCarrierLookOut">
				<cfinvoke component="#variables.objCarrierGateway#" method="UpdateViaCarrierLookOut" CarrierID="#url.CarrierID#" DotNumber="#url.DotNumber#" CompanyID="#session.CompanyID#" dsn="#application.dsn#" opt="#url.opt#" AdminUserName="#session.AdminUserName#" returnvariable="session.CLresponse" />
				<cfif structkeyexists(url,'Redirect_To')>
					<cflocation url="index.cfm?event=CarrierLookup&carrierid=#url.CarrierID#&#session.URLToken#&IsCarrier=1" addtoken="no">
				<cfelse>
					<cflocation url="index.cfm?event=addcarrier&carrierid=#url.CarrierID#&#session.URLToken#&IsCarrier=1" addtoken="no">
				</cfif>
			</cfcase>
			<cfcase value="saveCarrierScheduleCall">
				<cfinvoke component="#variables.objCarrierGateway#" method="saveCarrierScheduleCall" CarrierID="#url.CarrierID#" frmstruct="#form#"  returnvariable="session.CRMresponse" />
				<cfset variables.isCarrier = "">
				<cfif structKeyExists(url, 'isCarrier')>
					<cfset variables.isCarrier &= "&IsCarrier=#url.IsCarrier#">
				</cfif>
				<cfif form.submit eq 'Save'>
					<cflocation url="index.cfm?event=CarrierCRMNotes&CarrierID=#url.CarrierID#&#session.URLToken#&#variables.isCarrier#" addtoken="no">
				<cfelse>
					<cfif structKeyExists(session, "CRMresponse")>
					    <cfset structdelete(session, 'CRMresponse', true)/> 
					</cfif>
					<cflocation url="index.cfm?event=carrier&#session.URLToken#&#variables.isCarrier#" addtoken="no">
				</cfif>
			</cfcase>
			<cfcase value="editTemplate">
				<cfset includeTemplate("views/pages/carrier/editTemplate.cfm") />
			</cfcase>
			<cfcase value="carrierCRMCallHistory">
				<cfset request.subnavigation = includeTemplate("views/admin/carrierNav.cfm", true) />
				<cfset request.content = includeTemplate("views/pages/carrier/disp_carrierCRMCallHistory.cfm", true) />
				<cfset includeTemplate("views/templates/maintemplate.cfm") />
			</cfcase>
			<cfcase value="carrierCRMCallDetail">
				<cfinvoke component="#variables.objcarrierGateway#" method="getCRMCallDetail" CRMNoteID="#url.CRMNoteID#" returnvariable="qCRMCallDetail" />
		    	<cfset request.subnavigation = includeTemplate("views/admin/carrierNav.cfm", true) />
				<cfset request.content = includeTemplate("views/pages/carrier/carrierCRMCallDetail.cfm", true) />
				<cfset includeTemplate("views/templates/maintemplate.cfm") />
			</cfcase>
		</cfswitch>
		</cfif>
</cfif>
