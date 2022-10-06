
<cfsetting requesttimeout="500">
<cfscript>

	variables.objLoadGatewayAdd =getGateway("gateways.loadgatewayAdd", MakeParameters("dsn=#Application.dsn#,pwdExpiryDays=#Application.pwdExpiryDays#"));
	variables.objloadGateway = getGateway("gateways.loadgateway", MakeParameters("dsn=#Application.dsn#,pwdExpiryDays=#Application.pwdExpiryDays#"));
	variables.objcustomerloadGateway = getGateway("gateways.customerloadgateway", MakeParameters("dsn=#Application.dsn#,pwdExpiryDays=#Application.pwdExpiryDays#"));
	variables.objLoadGatewaynew =getGateway("gateways.loadgatewaynew", MakeParameters("dsn=#Application.dsn#,pwdExpiryDays=#Application.pwdExpiryDays#"));
	variables.objAgentGateway = getGateway("gateways.agentgateway", MakeParameters("dsn=#Application.dsn#,pwdExpiryDays=#Application.pwdExpiryDays#"));
	variables.objLoadgatewayUpdate = getGateway("gateways.loadgatewayUpdate", MakeParameters("dsn=#Application.dsn#,pwdExpiryDays=#Application.pwdExpiryDays#"));

	// 290615 added  
	if(	NOT isDefined("Application.objProMileGateWay")){
		Application.objProMileGateWay = getGateway("gateways.promile", MakeParameters("dsn=#Application.dsn#,pwdExpiryDays=#Application.pwdExpiryDays#"));
	}
	if(	NOT isDefined("Application.objShipDateUpdateGateWay")){
		Application.objShipDateUpdateGateWay = getGateway("gateways.ShipDateUpdate", MakeParameters("dsn=#Application.dsn#,pwdExpiryDays=#Application.pwdExpiryDays#"));
	}
	variables.objCarrierGateway = getGateway("gateways.carrierGateway", MakeParameters("dsn=#Application.dsn#,pwdExpiryDays=#Application.pwdExpiryDays#"));
	variables.objProMileGateWay = Application.objProMileGateWay;
	variables.objShipDateUpdateGateWay = Application.objShipDateUpdateGateWay;
</cfscript>
<cfif  request.event neq 'login' AND request.event neq 'customerlogin'>
		<cfif (not isdefined("session.passport.isLoggedIn") or not(session.passport.isLoggedIn))  AND request.event neq "GoogleMap">
		<cfelse>
		<cfswitch expression="#request.event#">
			<cfcase value="load">	
				<cfset request.myLoadsAgentUserName = ''>
				<cfset request.subnavigation = includeTemplate("views/admin/loadNav.cfm", true) />
				<cfset request.content = includeTemplate("views/pages/load/disp_load.cfm", true) />
				<cfset includeTemplate("views/templates/maintemplate.cfm") />
			</cfcase>
			<cfcase value="loadMail">
				<cfif isDefined('url.type')>
					<cfswitch expression="#url.type#">
					<cfcase value="Carrier">
						<cfset includeTemplate("reports/carrierReportConfirmMail.cfm") />
					</cfcase>
					<cfcase value="Dispatch">
						<cfset includeTemplate("reports/carrierReportConfirmMail.cfm") />
					</cfcase>
					<cfcase value="importWork">
						<cfset includeTemplate("reports/carrierWorkImportMail.cfm") />
					</cfcase>
					<cfcase value="exportWork">
						<cfset includeTemplate("reports/carrierWorkExportMail.cfm") />
					</cfcase>
					<cfcase value="customer">
						<cfset includeTemplate("reports/customerReportConfirmMail.cfm") />
					</cfcase>
					<cfcase value="BOL">
						<cfset includeTemplate("reports/BOLReportMail.cfm") />
					</cfcase>
					<cfcase value="BOLShort">
						<cfset includeTemplate("reports/BOLShortMail.cfm") />
					</cfcase>
					<cfcase value="sales">
						<cfset includeTemplate("reports/salesCommissionReportMail.cfm") />
					</cfcase>
					<cfcase value="Commission">
						<cfset includeTemplate("reports/salesCommissionReportMail.cfm") />
					</cfcase>
					<cfcase value="mailDoc">
						<cfset includeTemplate("reports/mailDocuments.cfm") />
					</cfcase>
					<cfcase value="viewDoc">
						<cfset includeTemplate("fileupload/showAttachment.cfm") />
					</cfcase>
					<cfcase value="alertEmail">
						<cfset includeTemplate("reports/loadAlertMail.cfm") />
					</cfcase>
					<cfcase value="EDispatch">
						<cfset includeTemplate("reports/loadEDispatchMail.cfm") />
					</cfcase>
					<cfcase value="alertLanesEmail">
						<cfset includeTemplate("reports/loadAlertLanesMail.cfm") />
					</cfcase>
					<cfcase value="LocationUpdates">
						<cfset includeTemplate("reports/loadLocationUpdatesMail.cfm") />
					</cfcase>
					<cfcase value="CarrierOnboard">
						<cfset includeTemplate("reports/CarrierOnboardMail.cfm") />
					</cfcase>
					<cfdefaultcase></cfdefaultcase>
					</cfswitch>
				</cfif>
			</cfcase>
			<cfcase value="myLoad">	
				<cfif structKeyExists(form, "LicenseTermsAccepted")>	
					<cfif form.LicenseTermsAccepted>
						<cfinvoke component="#variables.objagentGateway#" method="LicenseTermsAccept" />
					</cfif> 
					<cfset structDelete(session, "showLicenseTerms")>	
				</cfif>
				<cfif structKeyExists(session, "AdminUserName")>
					<cfset request.myLoadsAgentUserName = session.AdminUserName>
					<cfset request.subnavigation = includeTemplate("views/admin/loadNav.cfm", true) />
					<cfset request.content = includeTemplate("views/pages/load/disp_load.cfm", true) />
					<cfset includeTemplate("views/templates/maintemplate.cfm") />
				<cfelse>
					<cflocation url="index.cfm?event=login&AlertMessageID=3" addtoken="yes" />
				</cfif>
			</cfcase>
			<cfcase value="myexcelupload">			 
				 <cfset request.myLoadsAgentUserName = session.AdminUserName>
				<cfset request.subnavigation = includeTemplate("views/admin/loadNav.cfm", true) />
				<cfset request.content = includeTemplate("views/pages/load/import.cfm", true) />
				
			</cfcase>
			<cfcase value="myLoadNew">			 
				 <cfset request.myLoadsAgentUserName = session.AdminUserName>
				<cfset request.subnavigation = includeTemplate("views/admin/loadNav.cfm", true) />
				<cfset request.content = includeTemplate("views/pages/load/disp_load_new.cfm", true) />
				<cfset includeTemplate("views/templates/maintemplate.cfm") />
			</cfcase>
			<cfcase value="feedback"> 		
                 <cfset request.myLoadsAgentUserName = session.AdminUserName>				 
				 <cfset request.subnavigation = includeTemplate("views/admin/loadNav.cfm", true) />
				 <cfset request.content = includeTemplate("views/pages/load/disp_feedback.cfm", true) />
				<cfset includeTemplate("views/templates/maintemplate.cfm") />
			</cfcase>			
            <cfcase value="dispatchboard">			  
				 <cfset request.myLoadsAgentUserName = session.AdminUserName>
				<cfset request.subnavigation = includeTemplate("views/admin/loadNav.cfm", true) />
				<cfset request.content = includeTemplate("views/pages/load/disp_load.cfm", true) />
				<cfset includeTemplate("views/templates/maintemplate.cfm") />
			</cfcase>
            <cfcase value="nextStopLoad">
				 <cfset includeTemplate("views/pages/load/NextStopAjax.cfm") />
			</cfcase>
			<cfcase value="addload">
				<cfif structKeyExists(session, "empid") and session.empid eq ''>
					<cflocation url="index.cfm?event=logout:process">
				</cfif>
				<cfif structKeyExists(url, "loadid") AND ((len(trim(url.loadid)) AND not isValid("regex", url.loadid,'^[{]?[0-9a-fA-F]{8}-([0-9a-fA-F]{4}-){3}[0-9a-fA-F]{12}[}]?$')) OR NOT len(trim(url.loadid)))>
					<cflocation url="index.cfm?event=myLoad&#session.URLToken#" />
				</cfif>
				<cfif structKeyExists(url, "loadid")>
					<cfinvoke component="#variables.objloadGateway#" method="checkLoadCompany" loadid ="#url.loadid#" returnvariable="validLoad">
					<cfif not validLoad>
						<cflocation url="index.cfm?event=myLoad&#session.URLToken#" />
					</cfif>
				</cfif>
				<cfif structKeyExists(url, "loadToBeCopied")>
					<cfinvoke component="#variables.objloadGateway#" method="checkLoadCompany" loadid ="#url.loadToBeCopied#" returnvariable="validLoad">
					<cfif not validLoad>
						<cflocation url="index.cfm?event=myLoad&#session.URLToken#" />
					</cfif>
				</cfif>
				<cfif structKeyExists(url, "ShowLoadCopyOptions")>
					<cfinvoke component="#variables.objloadGateway#" method="updateLoadCopyOptions" CopyLoadIncludeAgentAndDispatcher="#url.CopyLoadIncludeAgentAndDispatcher#" CopyLoadDeliveryPickupDates ="#url.CopyLoadDeliveryPickupDates#" CopyLoadCarrier ="#url.CopyLoadCarrier#" ShowLoadCopyOptions="#url.ShowLoadCopyOptions#" />
				</cfif>
				<cfif ( structkeyexists(url,"loadToBeCopied")  AND  len(trim(url.loadToBeCopied)) gt 1 ) AND  ( structkeyexists(url,"NoOfCopies")  AND  trim(url.NoOfCopies) gt 1 )>
					<cfinvoke component="#variables.objloadGateway#" method="CopyLoadToMultiple"  LoadId="#url.loadToBeCopied#" NoOfCopies="#url.NoOfCopies#" returnvariable="session.qLoadNumbers" /> 
					 <cflocation url="index.cfm?event=load&#session.URLToken#" />
				</cfif>
				 <cfinvoke component="#variables.objloadGateway#" method="getLoadStatus" returnvariable="request.qLoadStatus" /> 
                 <cfset request.subnavigation = includeTemplate("views/admin/loadNav.cfm", true) />
				 <cfset request.content=includeTemplate("views/pages/load/addload.cfm",true)/>
				 <cfset includeTemplate("views/templates/maintemplate.cfm") />
			</cfcase>
			<cfcase value="addloadnew">
				 <cfinvoke component="#variables.objloadGateway#" method="getLoadStatus" returnvariable="request.qLoadStatus" /> 
                 <cfset request.subnavigation = includeTemplate("views/admin/loadNav.cfm", true) />
				 <cfset request.content=includeTemplate("views/pages/load/addload_new.cfm",true)/>
				 <cfset includeTemplate("views/templates/maintemplate.cfm") />
			</cfcase>
			<cfcase value="promile">
				 <cfset includeTemplate("views/pages/load/createFullMapProMiles.cfm") />
			</cfcase>
			<cfcase value="pcmiler">
				<cfinvoke component="#variables.objloadGateway#" method="getSystemSetupOptions" returnvariable="request.qGetSystemSetupOptions" />
				 <cfset includeTemplate("views/pages/load/createFullMap_PCMilerNew.cfm") />
			</cfcase>
			<cfcase value="addload:process">    
				<cfinvoke component="#variables.objloadGateway#" method="getSystemSetupOptions" returnvariable="request.qGetSystemSetupOptions" />
				<cfset formValidated = 1>
				<cfif StructIsEmpty(form)>
					<cfset formValidated = 0>
				<cfelse>
					<cfif not structKeyExists(form, "loadStatus")>
						<cfset formValidated = 0>
					<cfelseif structKeyExists(form, "loadStatus") AND not len(trim(form.loadStatus))>
						<cfset formValidated = 0>
					</cfif>

					<cfif not structKeyExists(form, "Dispatcher")>
						<cfset formValidated = 0>
					<cfelseif structKeyExists(form, "Dispatcher") AND not len(trim(form.Dispatcher))>
						<cfset formValidated = 0>
					</cfif>
					<cfif form.companyid neq session.companyid>
						<cfset formValidated = 0>
					</cfif>
				</cfif>
				<cfif formValidated EQ 0>
					<cflocation url="index.cfm?event=myLoad&#session.URLToken#" />
				</cfif>
				<cfset formStruct = structNew()>
				<cfset formStruct = form>
				<cfif isdefined("form.editid") and len(form.editid) gt 1>
					<!---Condition to check user is already editing by another person--->
					<cfif structkeyexists(form,"loaddisabledStatus") and form.loaddisabledStatus neq true> 
						
						<cfinvoke component="#variables.objLoadGatewaynew#" method="CheckEdi214" returnvariable="message1">
							<cfinvokeargument name="frmstruct" value="#formStruct#">
						</cfinvoke> 

						<cfinvoke component="#variables.objLoadGatewaynew#" method="getLoadStatusText" returnvariable="newStatus">
							<cfinvokeargument name="loadStatus" value="#form.loadStatus#">
						</cfinvoke> 

						<cfif request.qGetSystemSetupOptions.Project44 AND newStatus GTE request.qGetSystemSetupOptions.MobileStopTrackingStatus>
							<cfinvoke component="#variables.objloadGateway#" method="PushDataToProject44Api" loadid="#form.editid#" dsn="#application.dsn#" PushDataToProject44Api="0" returnvariable="Project44Result" />
						</cfif>

						<cfset MPalert =1>

						<cfif structKeyExists(form, "MacroPointOrderID")>
							<cfif len(trim(form.MacroPointOrderID)) AND form.oldstatus NEQ newStatus AND listFind("9. Cancelled,8. COMPLETED",newStatus)>
								<cfinvoke component="#variables.objloadGateway#" method="stopMacroPointOrder" OrderID="#form.MacroPointOrderID#" CompanyID="#session.CompanyID#" returnvariable="MpResult"/>
								<cfset MPalert = MpResult.message>
							<cfelse>
								<cfinvoke component="#variables.objloadGateway#" method="getMPLoadDetails" returnvariable="qMPLoadDetails" LoadID="#form.editid#"/>
								<cfset UpdateMP = 0>
								<cfset LastStopEventCompleted = 0>
								<cfif form.oldstatus NEQ newStatus AND newStatus GTE '5. DELIVERED' AND newStatus LTE '8. COMPLETED'>
									<cfset UpdateMP = 1>
									<cfset LastStopEventCompleted = 1>
								<cfelseif qMPLoadDetails.recordCount NEQ form.Mp_StopRecordCount OR qMPLoadDetails.DriverCell NEQ form.Mp_DriverCell OR qMPLoadDetails.CarrierID NEQ form.Mp_CarrierID>
									<cfset UpdateMP = 1>
								<cfelse>
									<cfloop query="qMPLoadDetails">
										<cfif (len(evaluate('Mp_StopDate_#qMPLoadDetails.currentrow#')) AND Isdate(evaluate('Mp_StopDate_#qMPLoadDetails.currentrow#')) AND
											len(qMPLoadDetails.stopdate) AND Isdate(qMPLoadDetails.stopdate) AND
											dateCompare(qMPLoadDetails.stopdate, evaluate('Mp_StopDate_#qMPLoadDetails.currentrow#')) NEQ 0)
											OR qMPLoadDetails.StopTime NEQ evaluate('Mp_StopTime_#qMPLoadDetails.currentrow#')
											OR qMPLoadDetails.TimeIn NEQ evaluate('Mp_TimeIn_#qMPLoadDetails.currentrow#')
											OR (isDefined('Mp_TimeOut_#qMPLoadDetails.currentrow#') AND qMPLoadDetails.TimeOut NEQ evaluate('Mp_TimeOut_#qMPLoadDetails.currentrow#'))
											OR qMPLoadDetails.Address NEQ evaluate('Mp_Address_#qMPLoadDetails.currentrow#')
											OR (isdefined('Mp_City_#qMPLoadDetails.currentrow#') and qMPLoadDetails.City NEQ evaluate('Mp_City_#qMPLoadDetails.currentrow#'))
											OR qMPLoadDetails.StateCode NEQ evaluate('Mp_StateCode_#qMPLoadDetails.currentrow#')
											OR qMPLoadDetails.PostalCode NEQ evaluate('Mp_PostalCode_#qMPLoadDetails.currentrow#')
										>
											<cfset UpdateMP = 1>
										</cfif>
									</cfloop>
								</cfif>
								
								<cfif UpdateMP EQ 1>
									<cfinvoke component="#variables.objloadGateway#" method="saveMacroPointOrder" returnvariable="MPResponse" CompanyID="#session.CompanyID#" LoadID="#form.editid#" LastStopEventCompleted="#LastStopEventCompleted#"/>
									<cfif MPResponse.success eq 0>
										<cfset MPalert = "Unable to post to MacroPoint.#MPResponse.error#">
									<cfelse>
										<cfset MPalert = "Changes posted to MacroPoint.">
									</cfif>
								</cfif>
							</cfif>
						</cfif>

						 <cfif NOT findNoCase('~~', message1) AND findNoCase('EDI', message1)>					 	
						 	 <cfoutput>
								<script>
									window.location = "index.cfm?event=addload&loadid=#form.loadToSaveWithoutExit#&AlertvarEDI=#message1#";
								</script>
							</cfoutput>
		                    <cfabort>
						 </cfif>
						
						<!--- Load Logging --->						
						<cfif request.qGetSystemSetupOptions.IsLoadLogEnabled EQ 1>
							<cfinvoke component="#variables.objLoadGateway#" method="addLoadLog" returnvariable="insertLoadLogReturn">
								<cfinvokeargument name="loadID" value="#form.editid#">
								<cfinvokeargument name="logType" value="2">
								<cfinvokeargument name="updatedUserID" value="#session.empid#">
								<cfinvokeargument name="updatedUser" value="#LOGGEDIN_PERSON#">
								<cfinvokeargument name="logData" value="#variables.objLoadGatewaynew.loadLogData#">
							</cfinvoke>
						</cfif>
						
						<cfset message = message1.split("~~")>
					<cfelse>
						<cfset message[1] =1>
						<cfset message[2] ='Data not saved because it is edited by another person. Please contact administrator to unlock.'>
						<cfset message[3] =1>
						<cfset message[4] =1>
						<cfset message[5] =1>
						<cfset message[6] =1>
					</cfif>
				 <cfelse>
					<cfinvoke component="#variables.objLoadGatewayAdd#" method="addLoad" returnvariable="insertedmessage">
						<cfinvokeargument name="frmstruct" value="#formStruct#">
					</cfinvoke>
					<cfset insertedLoadId = insertedmessage.split("~~")>
					
					<!--- Load Logging --->
					<cfif request.qGetSystemSetupOptions.IsLoadLogEnabled EQ 1>
						<cfinvoke component="#variables.objLoadGateway#" method="addLoadLog" returnvariable="insertLoadLogReturn">
							<cfinvokeargument name="loadID" value="#insertedLoadId[1]#">
							<cfinvokeargument name="logType" value="1">
							<cfinvokeargument name="updatedUserID" value="#session.empid#">
							<cfinvokeargument name="updatedUser" value="#LOGGEDIN_PERSON#">
						</cfinvoke>
					</cfif>
					
				 </cfif>
				 <cfif (isdefined("form.loadToSaveAndExit") and len(trim(form.loadToSaveAndExit)) gt 1 )>
					<cfif isdefined("form.editid") and len(form.editid) gt 1>
						<cfset AlertvarP=#message[1]#>
						<cfset AlertvarT=#message[2]#>
						<cfset AlertvarI=#message[3]#>
						<cfset AlertvarM=#message[4]#>
						<cfset AlertvarN=#message[5]#>
						<cfset Alertvarq=#message[6]#>

						<cfif ArrayLen(message) GTE 7>
							<cfset AlertvarDF=#message[7]#>
						<cfelse>
							<cfset AlertvarDF=1>
						</cfif>

						<cfif ArrayLen(message) GTE 8>
							<cfset AlertvarEDI=#message[8]#>
						</cfif>
					<cfelse>
						<cfset AlertvarP=#message[1]#>
						<cfset AlertvarT=#message[2]#>
						<cfset AlertvarI=#message[3]#>
						<cfset AlertvarDF=1>
					</cfif>
					<cfif isDefined('AlertvarEDI')>
						<cfset alertedi = "&AlertvarEDI=#AlertvarEDI#">
					<cfelse>
						<cfset alertedi = "">
					</cfif>
                 	 <cfoutput>
						<script>
							window.location = "index.cfm?event=myLoad&AlertvarP=#AlertvarP#&Ialert=#AlertvarT#&AlertvarI=#AlertvarI#&AlertvarM=#AlertvarM#&AlertvarN=#AlertvarN#&Alertvarq=#Alertvarq#&#session.URLToken#&#alertedi#&MPalert=#MPalert#&AlertvarDF=#AlertvarDF#&Palert=#AlertvarT#";
						</script>
					</cfoutput>
                    <cfabort>
                 </cfif>
				<cfif ( isdefined("form.loadToSaveToCarrierPage") and len(trim(form.loadToSaveToCarrierPage)) gt 1 )>
					<cfif isdefined("form.editid") and len(form.editid) gt 1>
						<cfset AlertvarP=#message[1]#>
						<cfset AlertvarT=#message[2]#>
						<cfset AlertvarI=#message[3]#>
					<cfelse>
						<cfset AlertvarP=#message[1]#>
						<cfset AlertvarT=#message[2]#>
						<cfset AlertvarI=#message[3]#>
					</cfif>
                 	<cfoutput>
						<script>
							window.location = "index.cfm?event=addcarrier&#session.URLToken#";
						</script>
					</cfoutput>
                    <cfabort>
                 </cfif>
				 <cfif ( isdefined("form.loadToSaveWithoutExit") and len(trim(form.loadToSaveWithoutExit)) gt 1 )>
					<cfinvoke component="#variables.objloadGateway#" method="getNoOfStops" LOADID="#form.loadToSaveWithoutExit#" returnvariable="request.NoOfStops" />
					<cfinvoke component="#variables.objloadGateway#" method="getAllLoads" loadid="#form.loadToSaveWithoutExit#"  stopNo="#request.NoOfStops#" returnvariable="qLoadsLastStop" />
					<cfinvoke component="#variables.objloadGateway#" method="getAllLoads" loadid="#form.loadToSaveWithoutExit#"  stopNo="0" returnvariable="qLoadsFirstStop"/> 
				<cfelse>
					<cfif isDefined("insertedmessage")>
						<cfinvoke component="#variables.objloadGateway#" method="getNoOfStops" LOADID="#insertedLoadId[1]#" returnvariable="request.NoOfStops" />
                        <cfinvoke component="#variables.objloadGateway#" method="getAllLoads"  loadid="#insertedLoadId[1]#"  stopNo="#request.NoOfStops#" returnvariable="qLoadsLastStop" /> 
                        <cfinvoke component="#variables.objloadGateway#" method="getAllLoads" loadid="#insertedLoadId[1]#"  stopNo="0" returnvariable="qLoadsFirstStop" />
                 	</cfif>
                 	<cfif isdefined("insertedLoadId") and ArrayLen(insertedLoadId) gt 1>
					     <cfset AlertvarP=#insertedLoadId[2]#>
						 <cfset AlertvarT=#insertedLoadId[3]#>
						 <cfset AlertvarI=#insertedLoadId[4]#>
						 <cfset AlertvarM=#insertedLoadId[5]#>
						 <cfset Alertvarq=#insertedLoadId[6]#>
						 <cfif ArrayLen(insertedLoadId) GTE 7>
							<cfset AlertvarDF=#insertedLoadId[7]#>
						<cfelse>
							<cfset AlertvarDF=1>
						</cfif>
					<cfelse>
					     <cfset AlertvarP="">
						 <cfset AlertvarT="">
						 <cfset AlertvarI="">
						 <cfset AlertvarM="">
						 <cfset Alertvarq="">
						 <cfset AlertvarDF=1>
					</cfif>
					<cfoutput>
						<cfif ( isdefined("form.loadToSaveAndExit") and (form.loadToSaveAndExit) eq 2 )>
							<script>
								window.location = "index.cfm?event=myload&AlertvarP=#AlertvarT#&AlertvarT=#AlertvarP#&AlertvarI=#AlertvarI#&AlertvarM=#AlertvarM#&Alertvarq=#Alertvarq#&#session.URLToken#&AlertvarDF=#AlertvarDF#";
							</script>
							<cfabort>
						</cfif>
						<script>
							window.location = "index.cfm?event=addload&loadid=#insertedLoadId[1]#&AlertvarP=#AlertvarT#&AlertvarT=#AlertvarP#&AlertvarI=#AlertvarI#&AlertvarM=#AlertvarM#&Alertvarq=#Alertvarq#&#session.URLToken#&AlertvarDF=#AlertvarDF#<cfif structKeyExists(form, "focusStop") and len(trim(form.focusStop))>###form.focusStop#</cfif>";
						</script>
					</cfoutput>
				 </cfif> 
				<cfif isdefined("form.LoadNumber") and len(form.LoadNumber) eq "">
					<cfset AlertvarP=#message[1]#>
					<cfset AlertvarT=#message[2]#>
					<cfset AlertvarI=#message[3]#>
				    <cfoutput>
				
						<script>
							window.location = "index.cfm?event=myLoad&AlertvarP=#AlertvarP#&AlertvarT=#AlertvarT#&AlertvarI=#AlertvarI#&#session.URLToken#&MPalert=#MPalert#";
						</script>
					</cfoutput>
				</cfif>
				<cfif isdefined("form.loadToSaveWithoutExit") and len(form.loadToSaveWithoutExit) gt 30 and form.loadToCarrierFilter neq 'true' >
				<cfif isdefined("form.editid") and len(form.editid) gt 1>
					<cfset AlertvarP=#message[1]#>
					<cfset AlertvarT=#message[2]#>
					<cfset AlertvarI=#message[3]#>
					<cfset AlertvarM=#message[4]#>
					<cfset AlertvarN=#message[5]#>
					<cfset Alertvarq=#message[6]#>
					<cfif ArrayLen(message) GTE 7>
						<cfset AlertvarDF=#message[7]#>
					<cfelse>
						<cfset AlertvarDF=1>
					</cfif>
					<cfif ArrayLen(message) GTE 8>
						<cfset AlertvarEDI=#message[8]#>
					</cfif>
					
				<cfelse>
					<cfparam name="insertedmessage" default="">
					<cfset insertedLoadId = insertedmessage.split("~~")>
					<cfset AlertvarP=#insertedLoadId[2]#>
					<cfset AlertvarT=#insertedLoadId[3]#>
					<cfset AlertvarI=#insertedLoadId[4]#>
					<cfset AlertvarDF=1>
				</cfif>
			
				<!--- BEGIN: Fix for issue in redirection Date:19 Sep 2013 --->
				<cfset AlertvarT = replace(AlertvarT, "'", "\'" ,"ALL")>
				<cfset AlertvarT = replace(replace(AlertvarT,chr(10),'','all'),chr(13),'','all')>
				<!--- END: Fix for issue in redirection Date:19 Sep 2013 --->
					<cfif isDefined('AlertvarEDI')>
						<cfset alertedi = "&AlertvarEDI=#AlertvarEDI#">
					<cfelse>
						<cfset alertedi = "">
					</cfif>
					<cfoutput>
						<script>
						window.location = "index.cfm?event=addload&loadid=#form.loadToSaveWithoutExit#&Palert=#AlertvarP#&Ialert=#AlertvarI#&AlertvarM=#AlertvarM#&AlertvarN=#AlertvarN#&Alertvarq=#Alertvarq#&#alertedi#&MPalert=#MPalert#&AlertvarDF=#AlertvarDF#&AlertvarP=#AlertvarT#<cfif structKeyExists(form, "focusStop") and len(trim(form.focusStop))>###form.focusStop#</cfif>";				
						</script>
					</cfoutput>
                <cfelseif (form.loadToCarrierFilter eq true and len(trim("form.loadToSaveWithoutExit") gt 1)  )>
	                 <cfoutput>
						<script>
							window.location='index.cfm?event=carrier&#session.URLToken#&carrierfilter=true&equipment=#qLoadsLastStop.CONSIGNEEEQUIPMENTID#&consigneecity=#qLoadsLastStop.CONSIGNEECITY#&consigneestate=#qLoadsLastStop.CONSIGNEESTATE#&consigneeZipcode=#qLoadsLastStop.CONSIGNEEPOSTALCODE#&shippercity=#qLoadsFirstStop.SHIPPERCITY#&shipperstate=#qLoadsFirstStop.SHIPPERSTATE#&shipperZipcode=#qLoadsFirstStop.SHIPPERPOSTALCODE#&mytest=1';
						</script>
					</cfoutput>
				<cfelse>
					<cfset request.myLoadsAgentUserName = ''>
					<cfset request.subnavigation = includeTemplate("views/admin/loadNav.cfm", true) />
					<cfset request.content = includeTemplate("views/pages/load/disp_load.cfm", true) />
					<cfset includeTemplate("views/templates/maintemplate.cfm") />
				</cfif>
			</cfcase>
            <cfcase value="advancedsearch">
              <cfinvoke component="#variables.objloadGateway#" method="getLoadStatus" returnvariable="request.qLoadStatus" />
              <cfinvoke component="#variables.objAgentGateway#" method="getAllStaes" returnvariable="request.qStates">
              <cfinvoke component="#variables.objequipmentGateway#" method="getloadEquipments" returnvariable="request.qEquipments" />
              <cfinvoke component="#variables.objloadGateway#" method="getSystemSetupOptions" returnvariable="request.qSystemSetupOptions" />
              <cfset request.subnavigation = includeTemplate("views/admin/loadNav.cfm", true) />
              <cfset request.content=includeTemplate("views/pages/load/advancedsearch.cfm",true)/>
              <cfset includeTemplate("views/templates/maintemplate.cfm") />
            </cfcase>
			<cfcase value="BOLReport">
			  <cfset request.subnavigation = includeTemplate("views/admin/loadNav.cfm", true) />
              <cfset request.content=includeTemplate("views/pages/load/getBOLReport.cfm",true)/>
              <cfset includeTemplate("views/templates/maintemplate.cfm") />
            </cfcase>	
			<cfcase value="BOLReport:process">
			  <cfset formStruct = structNew()>
			  <cfset formStruct = form>
			  <cfif structIsEmpty(form)><cfoutput>Unable to generate report</cfoutput><cfabort></cfif>
				<cfif form.submit eq 'Print BOL'>
					<cfinvoke component="#variables.objloadGateway#" method="AddBOLDetails" returnvariable="message">
					   <cfinvokeargument name="frmstruct" value="#formStruct#">
					 </cfinvoke>
					 <cfoutput>
						<cfif form.actionReport eq 'view'>
						<script>
							window.location = "index.cfm?event=BOLReportPrint&loadid=#form.loadid#&#session.URLToken#";
						</script>
						<cfelseif form.actionReport eq 'mail'>
						<script>
							window.location = "index.cfm?event=BOLReport&loadid=#form.loadid#&#session.URLToken#";
							newwindow=window.open('index.cfm?event=loadMail&type=BOL&loadid=#form.loadid#&#session.URLToken#','Map','height=400,width=750');
							if (window.focus) {newwindow.focus()}
						</script>
						</cfif>
					</cfoutput>	 
				<cfelseif form.submit eq 'Straight BOL'>
					<cfinvoke component="#variables.objloadGateway#" method="AddBOLDetails" returnvariable="message">
					   <cfinvokeargument name="frmstruct" value="#formStruct#">
					 </cfinvoke>
					<cfoutput>
						<script>
							window.location = "index.cfm?event=BOLReportShortPrint&loadid=#form.loadid#&#session.URLToken#";
						</script>
					</cfoutput>
				<cfelse>
					<cfoutput>
						<script>
							window.location = "index.cfm?event=BOLReport:print&loadid=#form.loadid#&#session.URLToken#";
						</script>
					</cfoutput>	 
				 </cfif>
              	<cfset includeTemplate("views/templates/maintemplate.cfm") />
            </cfcase>	
			<cfcase value="BOLReportPrint">
				<cfinvoke component="#variables.objloadGatewaynew#" method="getBOLReport" LoadID = "#url.LoadID#" CompanyID="#session.companyID#" returnvariable="qBOLReport" />
				<cfset customPath = "">
				<cfif len(trim(qBOLReport.CompanyCode)) and directoryExists(expandPath("../reports/#trim(qBOLReport.CompanyCode)#")) and fileExists(expandPath("../reports/#trim(qBOLReport.CompanyCode)#/BOLReport.cfm"))>
					<cfset customPath = "#trim(qBOLReport.CompanyCode)#">
				</cfif>
				<cfset includeTemplate("reports/#customPath#/BOLReport.cfm") />
				<cfcontent type="application/pdf" variable="#tobinary(BOLReport)#">
            </cfcase>
			<cfcase value="BOLReportShortPrint">
				<cfinvoke component="#variables.objloadGatewaynew#" method="getBOLReportshort" LoadID = "#url.LoadID#" CompanyID="#session.companyID#" returnvariable="qBOLReportShort" />
				<cfset customPath = "">
				<cfif len(trim(qBOLReportShort.CompanyCode)) and directoryExists(expandPath("../reports/#trim(qBOLReportShort.CompanyCode)#")) and fileExists(expandPath("../reports/#trim(qBOLReportShort.CompanyCode)#/BOLReportShort.cfm"))>
					<cfset customPath = "#trim(qBOLReportShort.CompanyCode)#">
				</cfif>
				<cfset includeTemplate("reports/#customPath#/BOLReportShort.cfm") />
				<cfcontent type="application/pdf" variable="#tobinary(BOLReportShort)#">
            </cfcase>
			<cfcase value="BOLReport:print">
			  <cfset formStruct = structNew()>
			  <cfset formStruct = form>
				<cfset Secret = application.dsn>
				<cfset TheKey = 'NAMASKARAM'>
				<cfset Encrypted = Encrypt(Secret, TheKey)>
				<cfset dsn = URLEncodedFormat(ToBase64(Encrypted))>
                 <cfif isdefined("url.loadid") and len(url.loadid) gt 1>
					  <cflocation url="../reports/loadreportForBOL.cfm?loadid=#url.loadid#&dsn=#dsn#&companyid=#session.companyid#" />
				 </cfif>
              	<cfset includeTemplate("views/templates/maintemplate.cfm") />
            </cfcase>
            <cfcase value="ShortBOLReport:print">
			  <cfset formStruct = structNew()>
			  <cfset formStruct = form>
				<cfset Secret = application.dsn>
				<cfset TheKey = 'NAMASKARAM'>
				<cfset Encrypted = Encrypt(Secret, TheKey)>
				<cfset dsn = URLEncodedFormat(ToBase64(Encrypted))>
                 <cfif isdefined("url.loadid") and len(url.loadid) gt 1>
					  <cflocation url="../reports/loadreportForShortBOL.cfm?loadid=#url.loadid#&dsn=#dsn#" />
				 </cfif>
              	<cfset includeTemplate("views/templates/maintemplate.cfm") />
            </cfcase>
            <cfcase value="loadReportForCarrierConfirmation">
              <cfset request.content=includeTemplate("views/pages/load/loadReportForCarrierConfirmation.cfm",true)/>
              <cfset includeTemplate("views/templates/maintemplate.cfm") />
            </cfcase>
            <cfcase value="loadCommissionReport">
              <cfset request.content=includeTemplate("reports/loadCommissionReport.cfm",true)/>
              <cfset includeTemplate("views/templates/maintemplate.cfm") />
            </cfcase>
            <cfcase value="loadCommissionReportNew">
              <cfset request.content=includeTemplate("views/pages/load/loadCommissionReportNew.cfm",true)/>
              <cfset includeTemplate("views/templates/maintemplate.cfm") />
            </cfcase>
           	<cfcase value="quickRateAndMilesCalc">
				<cfset request.subnavigation = includeTemplate("views/admin/loadNav.cfm", true) />
                <cfset request.content = includeTemplate("views/pages/load/quickRateAndMilesCalc.cfm", true) />
                <cfset includeTemplate("views/templates/maintemplate.cfm") />
            </cfcase>
            <cfcase value="exportData"> <!--- Just taking user to show list of loads ready to exported --->
				<cfset request.myLoadsAgentUserName = ''>
				<cfset request.subnavigation = includeTemplate("views/admin/loadNav.cfm", true) />
                <cfset request.content = includeTemplate("views/pages/load/disp_load.cfm", true) />
                <cfset includeTemplate("views/templates/maintemplate.cfm") />
            </cfcase>
            <cfcase value="exportAllLoads"> <!--- Going to export Data/Load now --->
              <cfset request.content=includeTemplate("views/pages/load/exportAllLoads.cfm",true)/>
              <cfset includeTemplate("views/templates/maintemplate.cfm") />
            </cfcase>
            <cfcase value="uploadFiles">			  
				<cfset request.myLoadsAgentUserName = session.AdminUserName>
				<cfset request.subnavigation = includeTemplate("views/admin/loadNav.cfm", true) />
				<cfset request.content = includeTemplate("fileupload/index.cfm", true) />
 				<cfset includeTemplate("views/templates/popupWindowtemplate.cfm") /> 
			</cfcase>
			<cfcase value="loadIntermodal">
              <cfset request.content = includeTemplate("views/pages/load/interModal.cfm", true) />
			  <cfset includeTemplate("views/templates/intermodaltemplate.cfm") />
			</cfcase>
			<cfcase value="loadLogs"> <!--- Going to export Data/Load now --->
				<cfset request.subnavigation = includeTemplate("views/admin/loadLogNav.cfm", true) />
				<cfset request.content=includeTemplate("views/pages/load/dispLogs.cfm",true)/>				  
				<cfset includeTemplate("views/templates/maintemplate.cfm") />
			</cfcase>
			<cfcase value="carrierquotes"> <!--- Going to export Data/Load now --->
				<cfset request.myLoadsAgentUserName = session.AdminUserName>
				<cfset request.subnavigation = includeTemplate("views/admin/loadNav.cfm", true) />
				<cfset request.content = includeTemplate("views/pages/load/carrier_quotes.cfm", true) />
				<cfset includeTemplate("views/templates/maintemplate.cfm") />
			</cfcase>
			<cfcase value="EDILoads">
				<cfif structKeyExists(form, "import")>
					<cfinvoke component="#variables.objloadGateway#" method="edi204LoadImport" returnvariable="edimessage" />
					<cfif isDefined("edimessage") >
						<cfset session.edimessage=edimessage>
					</cfif>
				</cfif>
				<cfset request.myLoadsAgentUserName = ''>
				<cfset request.subnavigation = includeTemplate("views/admin/loadNav.cfm", true) />
				<cfset request.content = includeTemplate("views/pages/load/disp_EDIload.cfm", true) />
				<cfset includeTemplate("views/templates/maintemplate.cfm") />
			</cfcase>
			<cfcase value="EDI820Loads">
				<cfif structKeyExists(form, "820import")>
					<cfinvoke component="#variables.objloadGateway#" method="edi820LoadImport"  
					returnvariable="edimessage" />
					<cfif isDefined("edimessage") >
						<cfset session.edimessage=edimessage>
					</cfif>/>
				</cfif>
				<cfset request.myLoadsAgentUserName = ''>
				<cfset request.subnavigation = includeTemplate("views/admin/loadNav.cfm", true) />
				<cfset request.content = includeTemplate("views/pages/load/disp_EDIload.cfm", true) />
				<cfset includeTemplate("views/templates/maintemplate.cfm") />
			</cfcase>
			<cfcase value="EDILog">
				<cfset request.myLoadsAgentUserName = ''>
				<cfset request.subnavigation = includeTemplate("views/admin/loadLogNav.cfm", true) />
				<cfset request.content = includeTemplate("views/pages/load/disp_EDILog.cfm", true) />
				<cfset includeTemplate("views/templates/maintemplate.cfm") />
			</cfcase>
			<cfcase value="MyLoadConsolidated">
				<cfset request.myLoadsAgentUserName = session.AdminUserName>
				<cfset request.subnavigation = includeTemplate("views/admin/loadNav.cfm", true) />
				<cfset request.content = includeTemplate("views/pages/load/consolidated_disp_load.cfm", true) />
				<cfset includeTemplate("views/templates/maintemplate.cfm") />
			</cfcase>
			<cfcase value="AllLoadConsolidated">
				<cfset request.myLoadsAgentUserName = ''>
				<cfset request.subnavigation = includeTemplate("views/admin/loadNav.cfm", true) />
				<cfset request.content = includeTemplate("views/pages/load/consolidated_disp_load.cfm", true) />				
				<cfset includeTemplate("views/templates/maintemplate.cfm") />
			</cfcase>
			<cfcase value="Project44Log">
				<cfset request.subnavigation = includeTemplate("views/admin/loadLogNav.cfm", true) />
				<cfset request.content = includeTemplate("views/pages/load/disp_Project44Log.cfm", true) />
				<cfset includeTemplate("views/templates/maintemplate.cfm") />
			</cfcase>
			<cfcase value="EmailLog">
				<cfset request.subnavigation = includeTemplate("views/admin/loadLogNav.cfm", true) />
				<cfset request.content = includeTemplate("views/pages/load/disp_EmailLog.cfm", true) />
				<cfset includeTemplate("views/templates/maintemplate.cfm") />
			</cfcase>
			<cfcase value="TextLog">
				<cfset request.subnavigation = includeTemplate("views/admin/loadLogNav.cfm", true) />
				<cfset request.content = includeTemplate("views/pages/load/disp_TextLog.cfm", true) />
				<cfset includeTemplate("views/templates/maintemplate.cfm") />
			</cfcase>
			<cfcase value="EdispatchLog">
				<cfset request.subnavigation = includeTemplate("views/admin/loadLogNav.cfm", true) />
				<cfset request.content = includeTemplate("views/pages/load/disp_EdispatchLog.cfm", true) />
				<cfset includeTemplate("views/templates/maintemplate.cfm") />
			</cfcase>
			<cfcase value="CsvImportLog">
				<cfset request.subnavigation = includeTemplate("views/admin/loadLogNav.cfm", true) />
				<cfset request.content = includeTemplate("views/pages/load/disp_CsvImportLog.cfm", true) />
				<cfset includeTemplate("views/templates/maintemplate.cfm") />
			</cfcase>
			<cfcase value="Factoring">
				<cfset request.subnavigation = includeTemplate("views/admin/loadNav.cfm", true) />
				<cfset request.content = includeTemplate("views/pages/load/disp_Factoring.cfm", true) />
				<cfset includeTemplate("views/templates/maintemplate.cfm") />
			</cfcase>
			<cfcase value="addFactoring">
				<cfinvoke component="#variables.objAgentGateway#" method="getAllStaes" returnvariable="request.qstates"/>
				<cfset request.subnavigation = includeTemplate("views/admin/loadNav.cfm", true) />
				<cfset request.content = includeTemplate("views/pages/load/addFactoring.cfm", true) />
				<cfset includeTemplate("views/templates/maintemplate.cfm") />
			</cfcase>
			<cfcase value="addFactoring:process">
				<cfset formStruct = structNew()>
				<cfset formStruct = form>
		
				<cfif structkeyexists(form,"editid") and len(trim(form.editid)) gt 0>
					<cfinvoke component="#variables.objloadGateway#" method="updadeFactoring" returnvariable="FactoringID">
						<cfinvokeargument name="formStruct" value="#formStruct#">
					</cfinvoke>
					<cfset session.FactoringMessage = 'Factoring has been updated Successfully.'>
				<cfelse>
					<cfinvoke component="#variables.objloadGateway#" method="insertFactoring" returnvariable="FactoringID">
					   <cfinvokeargument name="formStruct" value="#formStruct#">
					</cfinvoke>
					<cfset session.FactoringMessage  = 'Factoring has been created Successfully.'>
				</cfif>	
				
				<cfif form.stayonpage>
					<cflocation url="index.cfm?event=addFactoring&Factoringid=#FactoringID#&#session.URLToken#" />
				<cfelse>
					<cflocation url="index.cfm?event=Factoring&#session.URLToken#" />
				</cfif>
			</cfcase>
			<cfcase value="delFactoring">
				<cfinvoke component="#variables.objloadGateway#" method="deleteFactoring" Factoringid="#url.Factoringid#"  returnvariable="ID"/>
				<cfset session.FactoringMessage  = 'Factoring has been deleted Successfully.'>
				<cflocation url="index.cfm?event=Factoring&#session.URLToken#" />
			</cfcase>
			<cfcase value="DriverSettlementReport">
		    	<cfset request.subnavigation = includeTemplate("views/admin/reportsSubNav.cfm", true) />
		    	<cfset request.content = includeTemplate("webroot/DriverSettlementReport.cfm", true) />
		        <cfset includeTemplate("views/templates/maintemplate.cfm") />
			</cfcase>
			<cfcase value="reports">
		    	<cfset request.subnavigation = includeTemplate("views/admin/reportsSubNav.cfm", true) />
		    	<cfif request.qsystemsetupoptions1.UseCondensedReports EQ 1>
		    		<cfset request.content = includeTemplate("webroot/Reports.cfm", true) />
		    	<cfelse>
		    		<cfset request.content = includeTemplate("webroot/ReportsBeta.cfm", true) />
		    	</cfif>
		        <cfset includeTemplate("views/templates/maintemplate.cfm") />
			</cfcase>
			<cfcase value="revertDriverSettlement">
				<cfinvoke component="#variables.objloadGateway#" method="revertDriverSettlement" structFrm="#form#" />
				<cfset session.RevertMessage  = 'Last settlement from #form.revdate# has been reverted successfully.'>
				<cflocation url="index.cfm?event=DriverSettlementReport&#session.URLToken#" />
			</cfcase>
			<cfcase value="BulkDeleteLog"> <!--- Going to export Data/Load now --->
				<cfset request.subnavigation = includeTemplate("views/admin/loadLogNav.cfm", true) />
				<cfset request.content=includeTemplate("views/pages/load/disp_BulkDeleteLog.cfm",true)/>				  
				<cfset includeTemplate("views/templates/maintemplate.cfm") />
			</cfcase>
			<cfcase value="InvoiceLoads">			 
				<cfset request.subnavigation = includeTemplate("views/admin/accountingNav.cfm", true) />
				<cfset request.content = includeTemplate("views/pages/accounting/dsp_invoice_loads.cfm", true) />
				<cfset includeTemplate("views/templates/maintemplate.cfm") />
			</cfcase>
			<cfcase value="CustomerPayments">			 
				<cfset request.subnavigation = includeTemplate("views/admin/accountingNav.cfm", true) />
				<cfset request.content = includeTemplate("views/pages/accounting/dsp_customer_payments.cfm", true) />
				<cfset includeTemplate("views/templates/maintemplate.cfm") />
			</cfcase>
			<cfcase value="ChartofAccounts">			 
				<cfset request.subnavigation = includeTemplate("views/admin/accountingNav.cfm", true) />
				<cfset request.content = includeTemplate("views/pages/accounting/dsp_chart_of_accounts.cfm", true) />
				<cfset includeTemplate("views/templates/maintemplate.cfm") />
			</cfcase>
			<cfcase value="LMASettings">			 
				<cfset request.subnavigation = includeTemplate("views/admin/accountingNav.cfm", true) />
				<cfset request.content = includeTemplate("views/pages/accounting/LMASettings.cfm", true) />
				<cfset includeTemplate("views/templates/maintemplate.cfm") />
			</cfcase>
			<cfcase value="InvoiceCarrierLoads">			 
				<cfset request.subnavigation = includeTemplate("views/admin/accountingNav.cfm", true) />
				<cfset request.content = includeTemplate("views/pages/accounting/dsp_invoice_carrier_loads.cfm", true) />
				<cfset includeTemplate("views/templates/maintemplate.cfm") />
			</cfcase>
			<cfcase value="CreateCustomerInvoice">			 
				<cfset request.subnavigation = includeTemplate("views/admin/accountingNav.cfm", true) />
				<cfset request.content = includeTemplate("views/pages/accounting/dsp_create_customer_invoice.cfm", true) />
				<cfset includeTemplate("views/templates/maintemplate.cfm") />
			</cfcase>
			<cfcase value="CreateVendorInvoice">			 
				<cfset request.subnavigation = includeTemplate("views/admin/accountingNav.cfm", true) />
				<cfset request.content = includeTemplate("views/pages/accounting/dsp_create_vendor_invoice.cfm", true) />
				<cfset includeTemplate("views/templates/maintemplate.cfm") />
			</cfcase>
			<cfcase value="InvoiceToPay">			 
				<cfset request.subnavigation = includeTemplate("views/admin/accountingNav.cfm", true) />
				<cfset request.content = includeTemplate("views/pages/accounting/dsp_invoice_to_pay.cfm", true) />
				<cfset includeTemplate("views/templates/maintemplate.cfm") />
			</cfcase>
			<cfcase value="PrintChecks">			 
				<cfset request.subnavigation = includeTemplate("views/admin/accountingNav.cfm", true) />
				<cfset request.content = includeTemplate("views/pages/accounting/dsp_print_checks.cfm", true) />
				<cfset includeTemplate("views/templates/maintemplate.cfm") />
			</cfcase>
			<cfcase value="PaymentTerms">			 
				<cfset request.subnavigation = includeTemplate("views/admin/accountingNav.cfm", true) />
				<cfset request.content = includeTemplate("views/pages/accounting/dsp_payment_terms.cfm", true) />
				<cfset includeTemplate("views/templates/maintemplate.cfm") />
			</cfcase>
			<cfcase value="addLMAPaymentTerms">			 
				<cfset request.subnavigation = includeTemplate("views/admin/accountingNav.cfm", true) />
				<cfset request.content = includeTemplate("views/pages/accounting/add_payment_terms.cfm", true) />
				<cfset includeTemplate("views/templates/maintemplate.cfm") />
			</cfcase>
			<cfcase value="FindGLTransactions">			 
				<cfset request.subnavigation = includeTemplate("views/admin/accountingNav.cfm", true) />
				<cfset request.content = includeTemplate("views/pages/accounting/dsp_find_gltransactions.cfm", true) />
				<cfset includeTemplate("views/templates/maintemplate.cfm") />
			</cfcase>
			<cfcase value="BankAccounts">			 
				<cfset request.subnavigation = includeTemplate("views/admin/accountingNav.cfm", true) />
				<cfset request.content = includeTemplate("views/pages/accounting/dsp_bank_accounts.cfm", true) />
				<cfset includeTemplate("views/templates/maintemplate.cfm") />
			</cfcase>
			<cfcase value="ListChartofAccounts">			 
				<cfset request.subnavigation = includeTemplate("views/admin/accountingNav.cfm", true) />
				<cfset request.content = includeTemplate("views/pages/accounting/dsp_list_chart_of_accounts.cfm", true) />
				<cfset includeTemplate("views/templates/maintemplate.cfm") />
			</cfcase>
			<cfcase value="LMACustomerAgingReport">			 
				<cfset request.subnavigation = includeTemplate("views/admin/accountingNav.cfm", true) />
				<cfset request.content = includeTemplate("webroot/LMACustomerAgingReport.cfm", true) />
				<cfset includeTemplate("views/templates/maintemplate.cfm") />
			</cfcase>
			<cfcase value="LMAVendorAgingReport">			 
				<cfset request.subnavigation = includeTemplate("views/admin/accountingNav.cfm", true) />
				<cfset request.content = includeTemplate("webroot/LMAVendorAgingReport.cfm", true) />
				<cfset includeTemplate("views/templates/maintemplate.cfm") />
			</cfcase>
			<cfcase value="LMACustomerStatementReport">			 
				<cfset request.subnavigation = includeTemplate("views/admin/accountingNav.cfm", true) />
				<cfset request.content = includeTemplate("webroot/LMACustomerStatementReport.cfm", true) />
				<cfset includeTemplate("views/templates/maintemplate.cfm") />
			</cfcase>
			<cfcase value="MailCustomerStatement">
				<cfset includeTemplate("reports/LMAEmailCustomerStatementReport.cfm") />
			</cfcase>
			<cfcase value="LMAPrintTrialBalance">			 
				<cfset request.subnavigation = includeTemplate("views/admin/accountingNav.cfm", true) />
				<cfset request.content = includeTemplate("webroot/LMAPrintTrialBalance.cfm", true) />
				<cfset includeTemplate("views/templates/maintemplate.cfm") />
			</cfcase>
			<cfcase value="GeneralLedgerFinancialSetup">			 
				<cfset request.subnavigation = includeTemplate("views/admin/accountingNav.cfm", true) />
				<cfset request.content = includeTemplate("views/pages/accounting/dsp_gl_financialSetup.cfm", true) />
				<cfset includeTemplate("views/templates/maintemplate.cfm") />
			</cfcase>
			<cfcase value="LMAPrintIncomeStatement">			 
				<cfset request.subnavigation = includeTemplate("views/admin/accountingNav.cfm", true) />
				<cfset request.content = includeTemplate("webroot/LMAPrintIncomeStatement.cfm", true) />
				<cfset includeTemplate("views/templates/maintemplate.cfm") />
			</cfcase>
			<cfcase value="GeneralLedgerBalanceSheetSetup">			 
				<cfset request.subnavigation = includeTemplate("views/admin/accountingNav.cfm", true) />
				<cfset request.content = includeTemplate("views/pages/accounting/dsp_gl_balancesheetSetup.cfm", true) />
				<cfset includeTemplate("views/templates/maintemplate.cfm") />
			</cfcase>
			<cfcase value="LMAPrintBalanceSheet">			 
				<cfset request.subnavigation = includeTemplate("views/admin/accountingNav.cfm", true) />
				<cfset request.content = includeTemplate("webroot/LMAPrintBalanceSheet.cfm", true) />
				<cfset includeTemplate("views/templates/maintemplate.cfm") />
			</cfcase>
			<cfcase value="JournalEntry">			 
				<cfset request.subnavigation = includeTemplate("views/admin/accountingNav.cfm", true) />
				<cfset request.content = includeTemplate("views/pages/accounting/dsp_JournalEntry.cfm", true) />
				<cfset includeTemplate("views/templates/maintemplate.cfm") />
			</cfcase>
			<cfcase value="PostJournalEntry">			 
				<cfset request.subnavigation = includeTemplate("views/admin/accountingNav.cfm", true) />
				<cfset request.content = includeTemplate("views/pages/accounting/PostJournalEntry.cfm", true) />
				<cfset includeTemplate("views/templates/maintemplate.cfm") />
			</cfcase>
			<cfcase value="ReverseJournalEntry">			 
				<cfset request.subnavigation = includeTemplate("views/admin/accountingNav.cfm", true) />
				<cfset request.content = includeTemplate("views/pages/accounting/ReverseJournalEntry.cfm", true) />
				<cfset includeTemplate("views/templates/maintemplate.cfm") />
			</cfcase>
			<cfcase value="LMAPrintCashReceipts">			 
				<cfset request.subnavigation = includeTemplate("views/admin/accountingNav.cfm", true) />
				<cfset request.content = includeTemplate("webroot/LMAPrintCashReceipts.cfm", true) />
				<cfset includeTemplate("views/templates/maintemplate.cfm") />
			</cfcase>
			<cfcase value="LMAInvoicesPickedtoPay">			 
				<cfset request.subnavigation = includeTemplate("views/admin/accountingNav.cfm", true) />
				<cfset request.content = includeTemplate("webroot/LMAInvoicesPickedtoPay.cfm", true) />
				<cfset includeTemplate("views/templates/maintemplate.cfm") />
			</cfcase>
			<cfcase value="AccountDepartments">			 
				<cfset request.subnavigation = includeTemplate("views/admin/accountingNav.cfm", true) />
				<cfset request.content = includeTemplate("views/pages/accounting/AccountDepartments.cfm", true) />
				<cfset includeTemplate("views/templates/maintemplate.cfm") />
			</cfcase>
			<cfcase value="Departments">			 
				<cfset request.subnavigation = includeTemplate("views/admin/accountingNav.cfm", true) />
				<cfset request.content = includeTemplate("views/pages/accounting/dsp_departments.cfm", true) />
				<cfset includeTemplate("views/templates/maintemplate.cfm") />
			</cfcase>
			<cfcase value="LMAPrintLedgerReport">			 
				<cfset request.subnavigation = includeTemplate("views/admin/accountingNav.cfm", true) />
				<cfset request.content = includeTemplate("webroot/LMAPrintLedgerReport.cfm", true) />
				<cfset includeTemplate("views/templates/maintemplate.cfm") />
			</cfcase>
			<cfcase value="OpenNewYear">			 
				<cfset request.subnavigation = includeTemplate("views/admin/accountingNav.cfm", true) />
				<cfset request.content = includeTemplate("views/pages/accounting/OpenNewYear.cfm", true) />
				<cfset includeTemplate("views/templates/maintemplate.cfm") />
			</cfcase>
			<cfcase value="GLRecalculate">			 
				<cfset request.subnavigation = includeTemplate("views/admin/accountingNav.cfm", true) />
				<cfset request.content = includeTemplate("views/pages/accounting/GLRecalculate.cfm", true) />
				<cfset includeTemplate("views/templates/maintemplate.cfm") />
			</cfcase>
			<cfcase value="CustomerInquiry">			 
				<cfset request.subnavigation = includeTemplate("views/admin/accountingNav.cfm", true) />
				<cfset request.content = includeTemplate("views/pages/accounting/CustomerInquiry.cfm", true) />
				<cfset includeTemplate("views/templates/maintemplate.cfm") />
			</cfcase>
			<cfcase value="VendorInquiry">			 
				<cfset request.subnavigation = includeTemplate("views/admin/accountingNav.cfm", true) />
				<cfset request.content = includeTemplate("views/pages/accounting/VendorInquiry.cfm", true) />
				<cfset includeTemplate("views/templates/maintemplate.cfm") />
			</cfcase>
			<cfcase value="PostInvoicePayment">			 
				<cfset request.subnavigation = includeTemplate("views/admin/accountingNav.cfm", true) />
				<cfset request.content = includeTemplate("views/pages/accounting/PostInvoicePayment.cfm", true) />
				<cfset includeTemplate("views/templates/maintemplate.cfm") />
			</cfcase>
			<cfcase value="VoidInvoicePayment">			 
				<cfset request.subnavigation = includeTemplate("views/admin/accountingNav.cfm", true) />
				<cfset request.content = includeTemplate("views/pages/accounting/VoidInvoicePayment.cfm", true) />
				<cfset includeTemplate("views/templates/maintemplate.cfm") />
			</cfcase>
			<cfcase value="VoidCustomerPayment">			 
				<cfset request.subnavigation = includeTemplate("views/admin/accountingNav.cfm", true) />
				<cfset request.content = includeTemplate("views/pages/accounting/VoidCustomerPayment.cfm", true) />
				<cfset includeTemplate("views/templates/maintemplate.cfm") />
			</cfcase>
			<cfcase value="InvoicePaymentReport">			 
				<cfset request.subnavigation = includeTemplate("views/admin/accountingNav.cfm", true) />
				<cfset request.content = includeTemplate("webroot/InvoicePaymentReport.cfm", true) />
				<cfset includeTemplate("views/templates/maintemplate.cfm") />
			</cfcase>
			<cfcase value="addMultipleDates">
				<cfset includeTemplate("views/pages/load/addMultipleDates.cfm") />
			</cfcase>
			<cfcase value="addcustomerload">
				<cfif structKeyExists(url, "ShowLoadCopyOptions")>
					<cfinvoke component="#variables.objloadGateway#" method="updateLoadCopyOptions" CopyLoadIncludeAgentAndDispatcher="#url.CopyLoadIncludeAgentAndDispatcher#" CopyLoadDeliveryPickupDates ="#url.CopyLoadDeliveryPickupDates#" ShowLoadCopyOptions="#url.ShowLoadCopyOptions#" />
				</cfif>
				<cfif ( structkeyexists(url,"loadToBeCopied")  AND  len(trim(url.loadToBeCopied)) gt 1 ) AND  ( structkeyexists(url,"NoOfCopies")  AND  trim(url.NoOfCopies) gt 1 )>
					<cfinvoke component="#variables.objcustomerloadGateway#" method="CopyCustomerLoadToMultiple"  LoadIDToBeCopied="#url.loadToBeCopied#" NoOfCopies="#url.NoOfCopies#" returnvariable="session.qLoadNumbers" /> 
					 <cflocation url="index.cfm?event=load&#session.URLToken#" />
				</cfif>

				<cfset request.subnavigation = includeTemplate("views/admin/loadNav.cfm", true) />
				<cfset request.content=includeTemplate("views/pages/load/addcustomerload.cfm",true)/>
				<cfset includeTemplate("views/templates/maintemplate.cfm") />
			</cfcase>

			<cfcase value="addcustomerload:process">
				<cfif structIsEmpty(form)>
					<cfabort>
				</cfif>
				<cfif len(trim(form.LoadID))>
					<cfinvoke component="#variables.objcustomerloadGateway#" method="UpdateCustomerLoad" returnvariable="LoadID">
				        <cfinvokeargument name="frmstruct" value="#form#">
				    </cfinvoke>
				<cfelse>
					<cfinvoke component="#variables.objcustomerloadGateway#" method="AddCustomerLoad" returnvariable="LoadID">
				        <cfinvokeargument name="frmstruct" value="#form#">
				    </cfinvoke>
				</cfif>
			    <cflocation url="index.cfm?event=addcustomerload&LoadID=#LoadID#&#session.URLToken#" />
			</cfcase>
			<cfcase value="AIImport">
				<cfset request.subnavigation = includeTemplate("views/admin/loadNav.cfm", true) />
				<cfset request.content = includeTemplate("views/pages/load/AIImport.cfm", true) />
				<cfset includeTemplate("views/templates/maintemplate.cfm") />
			</cfcase>
			<cfcase value="AIImportLoad">
				<cfset request.subnavigation = includeTemplate("views/admin/loadNav.cfm", true) />
				<cfset request.content = includeTemplate("views/pages/load/AIImportLoad.cfm", true) />
				<cfset includeTemplate("views/templates/maintemplate.cfm") />
			</cfcase>
			<cfcase value="GoogleMap">
				<cfinvoke component="#variables.objloadGatewayNew#" method="getLoadDetailsForGoogleMap" LoadID = "#url.LoadID#" returnvariable="qLoadDetails" />
				<cfinvoke component="#variables.objloadGatewayNew#" method="getGPSDataPoints" LoadID = "#url.LoadID#" returnvariable="qGPSDataPoints" />
				<cfset includeTemplate("views/pages/load/GoogleMap.cfm") />
			</cfcase>
			<cfcase value="SalesDetail">
		    	<cfset request.subnavigation = includeTemplate("views/admin/reportsSubNav.cfm", true) />
		    	<cfset request.content = includeTemplate("webroot/SalesDetail.cfm", true) />
		        <cfset includeTemplate("views/templates/maintemplate.cfm") />
			</cfcase>

			<cfcase value="SalesDetailReport">
				<cfif structIsEmpty(form)>
					<cflocation  url="index.cfm?event=SalesDetail&#session.URLToken#">
				</cfif>
				<cfinvoke component="#variables.objloadGatewayNew#" method="getSalesDetailReport" frmStruct = "#form#" returnvariable="qSalesDetail" />
				<cfset listLoadId = listRemoveDuplicates(valueList(qSalesDetail.LoadID))>
				<cfinvoke component="#variables.objloadGatewayNew#" method="getLateStopDetails" LoadID = "#listLoadId#" returnvariable="qLateStopDetails" />
				<cfset includeTemplate("reports/SalesDetailReport.cfm") />
			</cfcase>

			<cfcase value="SalesReport">
				<cfif structIsEmpty(form)>
					<cflocation  url="index.cfm?event=Reports&#session.URLToken#">
				</cfif>
				<cfinvoke component="#variables.objloadGatewayNew#" method="getSalesReport" frmStruct = "#form#" returnvariable="qSalesDetail" />
				<cfset listLoadId = listRemoveDuplicates(valueList(qSalesDetail.LoadID))>
				<cfinvoke component="#variables.objloadGatewayNew#" method="getLateStopDetails" LoadID = "#listLoadId#" returnvariable="qLateStopDetails" />
				<cfset includeTemplate("reports/SalesReport.cfm") />
			</cfcase>

			<cfcase value="SalesReportCondensed">
				<cfparam name="url.sortBy" default="LoadNumber">
				<cfparam name="url.groupBy" default="None">
				<cfset groupBy = url.groupBy>
				<cfset sortBy = url.sortBy>
				<cfset orderDateFrom = "">
				<cfset orderDateTo = "">
				<cfset deliveryDateFrom = "">
				<cfset deliveryDateTo = "">
				<cfset billDateFrom = "">
				<cfset billDateTo = "">
				<cfset createDateFrom = "">
				<cfset createDateTo = "">
				<cfset DateFrom = "">
				<cfset DateTo = "">
				<cfparam name="url.datetype" default="Shipdate">
				<cfparam name="url.customerLimitFrom" default="####">
				<cfparam name="url.customerLimitTo" default="ZZZZ">
				<cfparam name="url.marginRangeFrom" default="0">
				<cfparam name="url.marginRangeTo" default="0">
				<cfparam name="url.customerStatus" default="0">
				<cfparam name="url.ShowSummaryStatus" default="0">
				<cfparam name="url.ShowProfit" default="0">
				<cfparam name="url.pageBreakStatus" default="1">
				<cfparam name="url.ShowReportCriteria" default="1">
				<cfparam name="url.reportType" default="Sales">
				<cfparam name="url.StatusTo" default="7. INVOICE">
				<cfparam name="url.StatusFrom" default="7. INVOICE">
				<cfparam name="url.equipmentFrom" default="AAAA">
				<cfparam name="url.equipmentTo" default="ZZZZ">
				<cfparam name="url.officeFrom" default="AAAA">
				<cfparam name="url.officeTo" default="ZZZZ">
				<cfparam name="url.carrierFrom" default="AAAA">
				<cfparam name="url.carrierTo" default="ZZZZ">
				<cfparam name="url.freightBroker" default="Carrrier">
				<cfparam name="url.companyid" default="56BFEDEC-E133-4C0B-9353-07B4BAD63C65">
				<cfif structKeyExists(url, "orderDateFrom") and len(url.orderDateFrom)>
					<cfset orderDateFrom = url.orderDateFrom>
					<cfset DateFrom = url.orderDateFrom>
				</cfif>
				<cfif structKeyExists(url, "orderDateTo") and len(url.orderDateTo)>
					<cfif isDate(url.orderDateTo)>
						<cfset orderDateTo = url.orderDateTo>
						<cfset DateTo = url.orderDateTo>
					<cfelse>
						<cfset orderDateTo = url.orderDateFrom>
						<cfset DateTo = url.orderDateFrom>
					</cfif>
				</cfif>

				<cfif structKeyExists(url, "deliveryDateFrom") and len(url.deliveryDateFrom)>
					<cfset deliveryDateFrom = url.deliveryDateFrom>
					<cfset DateFrom = url.deliveryDateFrom>
				</cfif>
				<cfif structKeyExists(url, "deliveryDateTo") and len(url.deliveryDateTo)>
					<cfset deliveryDateTo = url.deliveryDateTo>
					<cfset DateTo = url.deliveryDateTo>
				</cfif>

				<cfif structKeyExists(url, "billDateFrom") and len(url.billDateFrom)>
					<cfset billDateFrom = url.billDateFrom>
					<cfset DateFrom = url.billDateFrom>
				</cfif>
				<cfif structKeyExists(url, "billDateTo") and len(url.billDateTo)>
					<cfset billDateTo = url.billDateTo>
					<cfset DateTo = url.billDateTo>
				</cfif>
				<cfif structKeyExists(url, "createDateFrom") and len(url.createDateFrom)>
					<cfset createDateFrom = url.createDateFrom>
					<cfset DateFrom = url.createDateFrom>
				</cfif>
				<cfif structKeyExists(url, "createDateTo") and len(url.createDateTo)>
					<cfset createDateTo = url.createDateTo>
					<cfset DateTo = url.createDateTo>
				</cfif>

				<cfset datetype = url.datetype>
				<cfset salesRepFrom = url.salesRepFrom>
				<cfset salesRepFromForQuery = url.salesRepFrom>
				<cfset salesRepTo = url.salesRepTo>
				<cfset salesRepToForQuery = url.salesRepTo>
				<cfset dispatcherFrom = url.dispatcherFrom>
				<cfset dispatcherFromForQuery = url.dispatcherFrom>
				<cfset dispatcherTo = url.dispatcherTo>
				<cfset dispatcherToForQuery = url.dispatcherTo>
				<cfset customerFrom = url.customerLimitFrom>
				<cfset customerFromForQuery = url.customerLimitFrom>
				<cfset customerTo = url.customerLimitTo>
				<cfset customerToForQuery = url.customerLimitTo>
				<cfset marginRangeFrom = url.marginRangeFrom>
				<cfset marginRangeTo = url.marginRangeTo>
				<cfset deductionPercentage = url.deductionPercentage>
				<cfset commissionPercentage = url.commissionPercentage>
				<cfset reportType = url.reportType>
				<cfset statusTo = url.statusTo>
				<cfset statusFrom = url.statusFrom>
				<cfset equipmentFrom = url.equipmentFrom>
				<cfset equipmentFromForQuery = url.equipmentFrom>
				<cfset equipmentTo= url.equipmentTo>
				<cfset equipmentToForQuery= url.equipmentTo>
				<cfset officeFrom = url.officeFrom>
				<cfset officeFromForQuery = url.officeFrom>
				<cfset officeTo= url.officeTo>
				<cfset officeToForQuery= url.officeTo>
				<cfset carrierFrom = url.carrierFrom>
				<cfset carrierFromForQuery = url.carrierFrom>
				<cfset carrierTo= url.carrierTo>
				<cfset carrierToForQuery= url.carrierTo>

				<cfset freightBroker= url.freightBroker>

				<cfif structKeyExists(url, "ShowSummaryStatus")>
					<cfif url.ShowSummaryStatus eq 1>
						<cfset variables.ShowSummaryStatus=1>
					<cfelse>
						<cfset variables.ShowSummaryStatus=0>	
					</cfif>	
				</cfif>	

				<cfif structKeyExists(url, "ShowProfit")>
					<cfif url.ShowProfit eq 1>
						<cfset variables.ShowProfit=1>
					<cfelse>
						<cfset variables.ShowProfit=0>	
					</cfif>	
				</cfif>	

				<cfif structKeyExists(url, "ShowReportCriteria")>
					<cfif url.ShowReportCriteria eq 1>
						<cfset variables.ShowReportCriteria=1>
					<cfelse>
						<cfset variables.ShowReportCriteria=0>	
					</cfif>	
				</cfif>	

				<cfif freightBroker eq 'Driver'>
					<cfif salesRepFrom eq "">
						<cfset salesRepFrom = "########">
					    <cfset salesRepFromForQuery = "(BLANK)">
					</cfif>
					<cfif salesRepTo eq "">
						<cfset salesRepTo = "########">
					    <cfset salesRepToForQuery = "(BLANK)">
					</cfif>
				<cfelse>
					<cfif salesRepFrom eq "AAAA">
						<cfset salesRepFrom = "########">
					    <cfset salesRepFromForQuery = "(BLANK)">
					</cfif>
					<cfif salesRepTo eq "AAAA">
						<cfset salesRepTo = "########">
					    <cfset salesRepToForQuery = "(BLANK)">
					</cfif>
				</cfif>	

				<cfif dispatcherFrom eq "AAAA">
					<cfset dispatcherFrom = "########">
				    <cfset dispatcherFromForQuery = "">
				</cfif>

				<cfif dispatcherTo eq "AAAA">
					<cfset dispatcherTo = "########">
				    <cfset dispatcherToForQuery = "">
				</cfif>

				<cfif customerFrom eq "AAAA">
					<cfset customerFrom = "########">
				    <cfset customerFromForQuery = "(BLANK)">
				</cfif>

				<cfif customerTo eq "AAAA">
					<cfset customerTo = "########">
				    <cfset customerToForQuery = "(BLANK)">
				</cfif>


				<cfif equipmentFrom eq "AAAA">
					<cfset equipmentFrom = "########">
				    <cfset equipmentFromForQuery = "(BLANK)">
				</cfif>

				<cfif equipmentTo eq "AAAA">
					<cfset equipmentTo = "########">
				    <cfset equipmentToForQuery = "(BLANK)">
				</cfif>

				<cfif officeFrom eq "AAAA">
					<cfset officeFrom = "########">
				    <cfset officeFromForQuery = "(BLANK)">
				</cfif>

				<cfif officeTo eq "AAAA">
					<cfset officeTo = "########">
				    <cfset officeToForQuery = "(BLANK)">
				</cfif>

				<cfif carrierFrom eq "AAAA">
					<cfset carrierFrom = "########">
				    <cfset carrierFromForQuery = "(BLANK)">
				</cfif>

				<cfif carrierTo eq "AAAA">
					<cfset carrierTo = "########">
				    <cfset carrierToForQuery = "(BLANK)">
				</cfif>

				<cfif groupBy eq "salesAgent">
					<cfset groupBy = "Sales Agent">
					<cfset groupsBy = "SALESAGENT">
				<cfelseif groupBy eq "Driver">	
					<cfset groupBy = "Driver">
					<cfset groupsBy = "Driver">
				<cfelseif groupBy eq "userDefinedFieldTrucking">	
					<cfset groupBy = "userDefinedFieldTrucking">
					<cfset groupsBy = "userDefinedFieldTrucking">	
				<cfelseif groupBy eq "Carrier">	
					<cfset groupBy = "Carrier">
					<cfset groupsBy = "Carrier">	
				<cfelseif groupBy eq "CustName">	
					<cfset groupBy = "CustName">
					<cfset groupsBy = "CUSTOMERNAME">		
				<cfelseif  groupBy eq 'dispatcher'>
					<cfset groupBy = "Dispatcher">
					<cfset groupsBy = "DISPATCHER">
				<cfelseif  groupBy eq 'Carrier/Driver'>
					<cfset groupBy = "Carrier">
					<cfset groupsBy = "Carrier">
				<cfelse>
					<cfset groupBy = "none">
					<cfset groupsBy = "none">
				</cfif>
				<cfstoredproc procedure="USP_GetLoadsForCommissionReport" datasource="#application.dsn#">
					<cfprocparam value="#datetype#" cfsqltype="cf_sql_varchar">
					<cfprocparam value="#orderDateFrom#" cfsqltype="cf_sql_varchar">
					<cfprocparam value="#orderDateTo#" cfsqltype="cf_sql_varchar">
					<cfprocparam value="#billDateFrom#" cfsqltype="cf_sql_varchar">
					<cfprocparam value="#billDateTo#" cfsqltype="cf_sql_varchar">
					<cfprocparam value="#groupsBy#" cfsqltype="cf_sql_varchar">
					<cfprocparam value="#groupBy#" cfsqltype="cf_sql_varchar">
					<cfprocparam value="#salesRepFromForQuery#" cfsqltype="cf_sql_varchar">
					<cfprocparam value="#salesRepToForQuery#" cfsqltype="cf_sql_varchar">
					<cfprocparam value="#dispatcherFromForQuery#" cfsqltype="cf_sql_varchar">
					<cfprocparam value="#dispatcherToForQuery#" cfsqltype="cf_sql_varchar">
					<cfprocparam value="#statusTo#" cfsqltype="cf_sql_varchar">
					<cfprocparam value="#statusFrom#" cfsqltype="cf_sql_varchar">
					<cfprocparam value="#deductionPercentage#" cfsqltype="cf_sql_varchar">
					<cfprocparam value="#equipmentFromForQuery#" cfsqltype="cf_sql_varchar">
					<cfprocparam value="#equipmentToForQuery#" cfsqltype="cf_sql_varchar">
					<cfprocparam value="#officeFromForQuery#" cfsqltype="cf_sql_varchar">
					<cfprocparam value="#officeToForQuery#" cfsqltype="cf_sql_varchar">
					<cfprocparam value="#carrierFromForQuery#" cfsqltype="cf_sql_varchar">
					<cfprocparam value="#carrierToForQuery#" cfsqltype="cf_sql_varchar">
					<cfprocparam value="#customerFromForQuery#" cfsqltype="cf_sql_varchar">
					<cfprocparam value="#customerToForQuery#" cfsqltype="cf_sql_varchar">
					<cfprocparam value="#freightBroker#" cfsqltype="cf_sql_varchar">
					<cfprocparam value="#createDateFrom#" cfsqltype="cf_sql_varchar">
					<cfprocparam value="#createDateTo#" cfsqltype="cf_sql_varchar">
					<cfprocparam value="#url.companyid#" cfsqltype="cf_sql_varchar">
					<cfprocparam value="#deliveryDateFrom#" cfsqltype="cf_sql_varchar">
					<cfprocparam value="#deliveryDateTo#" cfsqltype="cf_sql_varchar">
					<cfprocparam value="#sortBy#" cfsqltype="cf_sql_varchar">
					<cfif isdefined("session.rightsList") AND ListContains(session.rightsList,'SalesRepReport',',')>
						<cfprocparam value="1" cfsqltype="cf_sql_bit">
					<cfelse>
						<cfprocparam value="0" cfsqltype="cf_sql_bit">
					</cfif>
					<cfif structKeyExists(cookie, "ReportIncludeAllDispatchers") AND cookie.ReportIncludeAllDispatchers>
						<cfprocparam value="1" cfsqltype="cf_sql_bit">
					<cfelse>
						<cfprocparam value="0" cfsqltype="cf_sql_bit">
					</cfif>
					<cfprocresult name="qCommissionReportLoads">
				</cfstoredproc>
				<cfif groupsBy EQ 'dispatcher' AND structKeyExists(cookie, "ReportIncludeAllDispatchers") AND cookie.ReportIncludeAllDispatchers>
					<cfset qCommissionReportLoadsNew = QueryNew(qCommissionReportLoads.columnList)>
					<cfset currRow = 1>
					<cfloop query="qCommissionReportLoads">
						<cfset QueryAddRow(qCommissionReportLoadsNew, 1)>
						<cfloop list="#qCommissionReportLoads.columnList#" index="key">
							<cfset QuerySetCell(qCommissionReportLoadsNew, key, evaluate("qCommissionReportLoads.#key#") , currRow)>
						</cfloop>
						<cfset currRow++>
						<cfif len(trim(qCommissionReportLoads.Dispatcher2))>
							<cfset QueryAddRow(qCommissionReportLoadsNew, 1)>
							<cfloop list="#qCommissionReportLoads.columnList#" index="key">
								<cfset QuerySetCell(qCommissionReportLoadsNew, key, evaluate("qCommissionReportLoads.#key#") , currRow)>
							</cfloop>
							<cfset QuerySetCell(qCommissionReportLoadsNew, "Dispatcher", qCommissionReportLoads.Dispatcher2 , currRow)>
							<cfset QuerySetCell(qCommissionReportLoadsNew, "GrpBy", qCommissionReportLoads.Dispatcher2 , currRow)>
							<cfset currRow++>
						</cfif>
						<cfif len(trim(qCommissionReportLoads.Dispatcher3))>
							<cfset QueryAddRow(qCommissionReportLoadsNew, 1)>
							<cfloop list="#qCommissionReportLoads.columnList#" index="key">
								<cfset QuerySetCell(qCommissionReportLoadsNew, key, evaluate("qCommissionReportLoads.#key#") , currRow)>
							</cfloop>
							<cfset QuerySetCell(qCommissionReportLoadsNew, "Dispatcher", qCommissionReportLoads.Dispatcher3 , currRow)>
							<cfset QuerySetCell(qCommissionReportLoadsNew, "GrpBy", qCommissionReportLoads.Dispatcher3 , currRow)>
							<cfset currRow++>
						</cfif>
					</cfloop>
					<cfset qCommissionReportLoads = qCommissionReportLoadsNew>
				</cfif>
				<cfif groupsBy EQ 'salesAgent' AND structKeyExists(cookie, "ReportIncludeAllSalesRep") AND cookie.ReportIncludeAllSalesRep >
					<cfset qCommissionReportLoadsNew = QueryNew(qCommissionReportLoads.columnList)>
					<cfset currRow = 1>
					<cfloop query="qCommissionReportLoads">
						<cfset QueryAddRow(qCommissionReportLoadsNew, 1)>
						<cfloop list="#qCommissionReportLoads.columnList#" index="key">
							<cfset QuerySetCell(qCommissionReportLoadsNew, key, evaluate("qCommissionReportLoads.#key#") , currRow)>
						</cfloop>
						<cfset currRow++>
						<cfif len(trim(qCommissionReportLoads.SalesAgent2))>
							<cfset QueryAddRow(qCommissionReportLoadsNew, 1)>
							<cfloop list="#qCommissionReportLoads.columnList#" index="key">
								<cfset QuerySetCell(qCommissionReportLoadsNew, key, evaluate("qCommissionReportLoads.#key#") , currRow)>
							</cfloop>
							<cfset QuerySetCell(qCommissionReportLoadsNew, "SalesAgent", qCommissionReportLoads.SalesAgent2 , currRow)>
							<cfset QuerySetCell(qCommissionReportLoadsNew, "GrpBy", qCommissionReportLoads.SalesAgent2 , currRow)>
							<cfset currRow++>
						</cfif>
						<cfif len(trim(qCommissionReportLoads.SalesAgent3))>
							<cfset QueryAddRow(qCommissionReportLoadsNew, 1)>
							<cfloop list="#qCommissionReportLoads.columnList#" index="key">
								<cfset QuerySetCell(qCommissionReportLoadsNew, key, evaluate("qCommissionReportLoads.#key#") , currRow)>
							</cfloop>
							<cfset QuerySetCell(qCommissionReportLoadsNew, "SalesAgent", qCommissionReportLoads.SalesAgent3 , currRow)>
							<cfset QuerySetCell(qCommissionReportLoadsNew, "GrpBy", qCommissionReportLoads.SalesAgent3 , currRow)>
							<cfset currRow++>
						</cfif>
					</cfloop>
					<cfset qCommissionReportLoads = qCommissionReportLoadsNew>
				</cfif>
				<cfset includeTemplate("reports/SalesReportCondensed.cfm") />
			</cfcase>

			<cfcase value="AgingReport">
				<cfset groupBy = url.groupBy>
				<cfset reportType = url.reportType>
				<cfset orderDateFrom = "">
				<cfset orderDateTo = "">
				<cfset billDateFrom = "">
				<cfset billDateTo = "">
				<cfset DateFrom = "">
				<cfset DateTo = "">

				<cfif structKeyExists(url, "orderDateFrom") and len(url.orderDateFrom)>
					<cfset orderDateFrom = url.orderDateFrom>
					<cfset DateFrom = url.orderDateFrom>
				</cfif>
				<cfif structKeyExists(url, "orderDateTo") and len(url.orderDateTo)>
					<cfset orderDateTo = url.orderDateTo>
					<cfset DateTo = url.orderDateTo>
				</cfif>
				<cfif structKeyExists(url, "billDateFrom") and len(url.billDateFrom)>
					<cfset billDateFrom = url.billDateFrom>
					<cfset DateFrom = url.billDateFrom>
				</cfif>
				<cfif structKeyExists(url, "billDateTo") and len(url.billDateTo)>
					<cfset billDateTo = url.billDateTo>
					<cfset DateTo = url.billDateTo>
				</cfif>

				<cfset datetype = url.datetype>
				<cfset salesRepFrom = url.salesRepFrom>
				<cfset salesRepFromForQuery = url.salesRepFrom>
				<cfset salesRepTo = url.salesRepTo>
				<cfset salesRepToForQuery = url.salesRepTo>
				<cfset dispatcherFrom = url.dispatcherFrom>
				<cfset dispatcherFromForQuery = url.dispatcherFrom>
				<cfset dispatcherTo = url.dispatcherTo>
				<cfset dispatcherToForQuery = url.dispatcherTo>
				<cfset customerFrom = url.customerLimitFrom>
				<cfset customerFromForQuery = url.customerLimitFrom>
				<cfset customerTo = url.customerLimitTo>
				<cfset customerToForQuery = url.customerLimitTo>
				<cfset deductionPercentage = url.deductionPercentage>
				<cfset statusTo = url.statusTo>
				<cfset statusFrom = url.statusFrom>
				<cfset equipmentFrom = url.equipmentFrom>
				<cfset equipmentFromForQuery = url.equipmentFrom>
				<cfset equipmentTo= url.equipmentTo>
				<cfset equipmentToForQuery= url.equipmentTo>
				<cfset officeFrom = url.officeFrom>
				<cfset officeFromForQuery = url.officeFrom>
				<cfset officeTo= url.officeTo>
				<cfset officeToForQuery= url.officeTo>
				<cfset carrierFrom = url.carrierFrom>
				<cfset carrierFromForQuery = url.carrierFrom>
				<cfset carrierTo= url.carrierTo>
				<cfset carrierToForQuery= url.carrierTo>
				<cfset freightBroker= url.freightBroker>

				<cfif structKeyExists(url, "ShowSummaryStatus")>
					<cfif url.ShowSummaryStatus eq 1>
						<cfset variables.ShowSummaryStatus=1>
					<cfelse>
						<cfset variables.ShowSummaryStatus=0>
					</cfif>
				</cfif>
				<cfif freightBroker eq 'Driver'>
					<cfif salesRepFrom eq "">
						<cfset salesRepFrom = "########">
						<cfset salesRepFromForQuery = "(BLANK)">
					</cfif>
					<cfif salesRepTo eq "">
						<cfset salesRepTo = "########">
						<cfset salesRepToForQuery = "(BLANK)">
					</cfif>
				<cfelse>
					<cfif salesRepFrom eq "AAAA">
						<cfset salesRepFrom = "########">
						<cfset salesRepFromForQuery = "(BLANK)">
					</cfif>
					<cfif salesRepTo eq "AAAA">
						<cfset salesRepTo = "########">
						<cfset salesRepToForQuery = "(BLANK)">
					</cfif>
				</cfif>

				<cfif dispatcherFrom eq "AAAA">
					<cfset dispatcherFrom = "########">
				    <cfset dispatcherFromForQuery = "">
				</cfif>

				<cfif dispatcherTo eq "AAAA">
					<cfset dispatcherTo = "########">
				    <cfset dispatcherToForQuery = "">
				</cfif>

				<cfif customerFrom eq "AAAA">
					<cfset customerFrom = "########">
					<cfset customerFromForQuery = "(BLANK)">
				</cfif>

				<cfif customerTo eq "AAAA">
					<cfset customerTo = "########">
					<cfset customerToForQuery = "(BLANK)">
				</cfif>

				<cfif equipmentFrom eq "AAAA">
					<cfset equipmentFrom = "########">
				    <cfset equipmentFromForQuery = "(BLANK)">
				</cfif>

				<cfif equipmentTo eq "AAAA">
					<cfset equipmentTo = "########">
					<cfset equipmentToForQuery = "(BLANK)">
				</cfif>

				<cfif carrierFrom eq "AAAA">
					<cfset carrierFrom = "########">
				    <cfset carrierFromForQuery = "(BLANK)">
				</cfif>

				<cfif carrierTo eq "AAAA">
					<cfset carrierTo = "########">
				    <cfset carrierToForQuery = "(BLANK)">
				</cfif>

				<cfif groupBy eq "salesAgent">
					<cfset groupBy = "Sales Agent">
					<cfset groupsBy = "SALESAGENT">
				<cfelseif groupBy eq "Driver">
					<cfset groupBy = "Driver">
					<cfset groupsBy = "Driver">
				<cfelseif groupBy eq "userDefinedFieldTrucking">
					<cfset groupBy = "userDefinedFieldTrucking">
					<cfset groupsBy = "userDefinedFieldTrucking">
				<cfelseif groupBy eq "Carrier">
					<cfset groupBy = "Carrier">
					<cfset groupsBy = "Carrier">
				<cfelseif groupBy eq "CustName">
					<cfset groupBy = "CustName">
					<cfset groupsBy = "CUSTOMERNAME">
				<cfelseif  groupBy eq 'dispatcher'>
					<cfset groupBy = "Dispatcher">
					<cfset groupsBy = "DISPATCHER">
				<cfelse>
					<cfset groupBy = "none">
					<cfset groupsBy = "none">
				</cfif>
				<cfif structKeyExists(url, "ShowReportCriteria")>
					<cfif url.ShowReportCriteria eq 1>
						<cfset variables.ShowReportCriteria=1>
					<cfelse>
						<cfset variables.ShowReportCriteria=0>	
					</cfif>	
				<cfelse>
					<cfset variables.ShowReportCriteria=0>	
				</cfif>	

				<cfstoredproc procedure="USP_GetLoadsForCommissionAging" datasource="#application.dsn#">
					<cfprocparam value="#datetype#" cfsqltype="cf_sql_varchar">
					<cfprocparam value="#orderDateFrom#" cfsqltype="cf_sql_varchar">
					<cfprocparam value="#orderDateTo#" cfsqltype="cf_sql_varchar">
					<cfprocparam value="#billDateFrom#" cfsqltype="cf_sql_varchar">
					<cfprocparam value="#billDateTo#" cfsqltype="cf_sql_varchar">
					<cfprocparam value="#groupsBy#" cfsqltype="cf_sql_varchar">
					<cfprocparam value="#groupBy#" cfsqltype="cf_sql_varchar">
					<cfprocparam value="#salesRepFromForQuery#" cfsqltype="cf_sql_varchar">
					<cfprocparam value="#salesRepToForQuery#" cfsqltype="cf_sql_varchar">
					<cfprocparam value="#dispatcherFromForQuery#" cfsqltype="cf_sql_varchar">
					<cfprocparam value="#dispatcherToForQuery#" cfsqltype="cf_sql_varchar">
					<cfprocparam value="#statusTo#" cfsqltype="cf_sql_varchar">
					<cfprocparam value="#statusFrom#" cfsqltype="cf_sql_varchar">
					<cfprocparam value="#deductionPercentage#" cfsqltype="cf_sql_varchar">
					<cfprocparam value="#equipmentFromForQuery#" cfsqltype="cf_sql_varchar">
					<cfprocparam value="#equipmentToForQuery#" cfsqltype="cf_sql_varchar">
					<cfprocparam value="#officeFromForQuery#" cfsqltype="cf_sql_varchar">
					<cfprocparam value="#officeToForQuery#" cfsqltype="cf_sql_varchar">
					<cfprocparam value="#carrierFromForQuery#" cfsqltype="cf_sql_varchar">
					<cfprocparam value="#carrierToForQuery#" cfsqltype="cf_sql_varchar">
					<cfprocparam value="#customerFromForQuery#" cfsqltype="cf_sql_varchar">
					<cfprocparam value="#customerToForQuery#" cfsqltype="cf_sql_varchar">
					<cfprocparam value="#freightBroker#" cfsqltype="cf_sql_varchar">
					<cfprocparam value="#session.companyid#" cfsqltype="cf_sql_varchar">
					<cfprocparam value="#reportType#" cfsqltype="cf_sql_varchar">
					<cfif isdefined("session.rightsList") AND ListContains(session.rightsList,'SalesRepReport',',')>
						<cfprocparam value="1" cfsqltype="cf_sql_bit">
					<cfelse>
						<cfprocparam value="0" cfsqltype="cf_sql_bit">
					</cfif>
					<cfprocresult name="qCommissionReportLoads">
				</cfstoredproc>
				<cfset includeTemplate("reports/AgingReport.cfm") />
			</cfcase>

			<cfcase value="UploadCustomerPayment">
				<cfset request.subnavigation = includeTemplate("views/admin/loadNav.cfm", true) />
				<cfset request.content = includeTemplate("views/pages/load/UploadCustomerPayment.cfm", true) />
				<cfset includeTemplate("views/templates/maintemplate.cfm") />
			</cfcase>
            <cfdefaultcase></cfdefaultcase>
		</cfswitch>
		</cfif>
</cfif>