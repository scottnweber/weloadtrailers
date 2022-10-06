
<cfsetting requesttimeout="500">
<cfscript>
	
	if(Not isDefined("Application.objLoadGatewayAdd")){
	  Application.objLoadGatewayAdd =getGateway("gateways.loadgatewayAdd", MakeParameters("dsn=#Application.dsn#,pwdExpiryDays=#Application.pwdExpiryDays#"));
	}
	if(Not isDefined("Application.objloadGateway")){
	  Application.objloadGateway = getGateway("gateways.loadgateway", MakeParameters("dsn=#Application.dsn#,pwdExpiryDays=#Application.pwdExpiryDays#"));
	}
	if(Not isDefined("Application.objLoadGatewaynew")){
	  Application.objLoadGatewaynew =getGateway("gateways.loadgatewaynew", MakeParameters("dsn=#Application.dsn#,pwdExpiryDays=#Application.pwdExpiryDays#"));
	}
	if(Not isDefined("Application.objAgentGateway")){
	  Application.objAgentGateway = getGateway("gateways.agentgateway", MakeParameters("dsn=#Application.dsn#,pwdExpiryDays=#Application.pwdExpiryDays#"));
	 }
	if(Not isDefined("Application.objLoadgatewayUpdate")){
	  Application.objLoadgatewayUpdate = getGateway("gateways.loadgatewayUpdate", MakeParameters("dsn=#Application.dsn#,pwdExpiryDays=#Application.pwdExpiryDays#"));
	 }

	// 290615 added  
	if(	NOT isDefined("Application.objProMileGateWay")){
		Application.objProMileGateWay = getGateway("gateways.promile", MakeParameters("dsn=#Application.dsn#,pwdExpiryDays=#Application.pwdExpiryDays#"));
	}
	if(	NOT isDefined("Application.objShipDateUpdateGateWay")){
		Application.objShipDateUpdateGateWay = getGateway("gateways.ShipDateUpdate", MakeParameters("dsn=#Application.dsn#,pwdExpiryDays=#Application.pwdExpiryDays#"));
	}
	variables.objCarrierGateway = getGateway("gateways.carrierGateway", MakeParameters("dsn=#Application.dsn#,pwdExpiryDays=#Application.pwdExpiryDays#"));
	 variables.objLoadGatewayAdd = Application.objLoadGatewayAdd; 
	 variables.objloadGateway = Application.objloadGateway;
	 variables.objLoadGatewaynew = Application.objLoadGatewaynew; 
	 variables.objAgentGateway = Application.objAgentGateway;
	 variables.objLoadgatewayUpdate=Application.objLoadgatewayUpdate;
	 variables.objProMileGateWay = Application.objProMileGateWay;
	 variables.objShipDateUpdateGateWay = Application.objShipDateUpdateGateWay;
</cfscript>

<cfif  request.event neq 'login' AND request.event neq 'customerlogin'>
		<cfif (not isdefined("session.passport.isLoggedIn") or not(session.passport.isLoggedIn))>
			<!--- <cfset request.content = includeTemplate("views/security/loginform.cfm", true) />
			<cfset includeTemplate("views/templates/maintemplate.cfm") /> --->
		<cfelse>
		<cfswitch expression="#request.event#">
			<cfcase value="load">	
			   <!---   <cfinvoke component="#variables.objloadGateway#" method="getAllLoads" returnvariable="request.qLoads" />
				 <cfdump var="#request.qLoads#"> --->
				 <cfset request.myLoadsAgentUserName = ''>

				<cfset request.subnavigation = includeTemplate("views/admin/loadNav.cfm", true) />

				<cfset request.content = includeTemplate("views/pages/load/disp_load.cfm", true) />
				<!--- <cfdump var="4" /><cfabort> --->
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
					<cfdefaultcase></cfdefaultcase>
					</cfswitch>
				</cfif>
			</cfcase>
			<cfcase value="myLoad">			 
			     <!---<cfinvoke component="#variables.objloadGateway#" method="getAllLoads" returnvariable="request.qLoads" />--->
				 <!--- <cfdump var="#request.qLoads#"> --->
				 <cfset request.myLoadsAgentUserName = session.AdminUserName>
				<cfset request.subnavigation = includeTemplate("views/admin/loadNav.cfm", true) />
				<cfset request.content = includeTemplate("views/pages/load/disp_load.cfm", true) />
				<cfset includeTemplate("views/templates/maintemplate.cfm") />
			</cfcase>
			<cfcase value="myexcelupload">			 
			     <!---<cfinvoke component="#variables.objloadGateway#" method="getAllLoads" returnvariable="request.qLoads" />--->
				 <!--- <cfdump var="#request.qLoads#"> --->
				 <cfset request.myLoadsAgentUserName = session.AdminUserName>
				<cfset request.subnavigation = includeTemplate("views/admin/loadNav.cfm", true) />
				<cfset request.content = includeTemplate("views/pages/load/import.cfm", true) />
				
			</cfcase>
			<cfcase value="myLoadNew">			 
			     <!---<cfinvoke component="#variables.objloadGateway#" method="getAllLoads" returnvariable="request.qLoads" />--->
				 <!--- <cfdump var="#request.qLoads#"> --->
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
			     <!---<cfinvoke component="#variables.objloadGateway#" method="getAllLoads" returnvariable="request.qLoads" />--->
				 <!--- <cfdump var="#request.qLoads#"> --->
				 <cfset request.myLoadsAgentUserName = session.AdminUserName>
				<cfset request.subnavigation = includeTemplate("views/admin/loadNav.cfm", true) />
				<cfset request.content = includeTemplate("views/pages/load/disp_load.cfm", true) />
				<cfset includeTemplate("views/templates/maintemplate.cfm") />
			</cfcase>
            <cfcase value="nextStopLoad">
				 <cfset includeTemplate("views/pages/load/NextStopAjax.cfm") />
			</cfcase>
			<cfcase value="addload">
				<cfif ( structkeyexists(url,"loadToBeCopied")  AND  len(trim(url.loadToBeCopied)) gt 1 ) AND  ( structkeyexists(url,"NoOfCopies")  AND  trim(url.NoOfCopies) gt 1 )>
					<cfinvoke component="#variables.objloadGateway#" method="CopyLoadToMultiple"  LoadId="#url.loadToBeCopied#" NoOfCopies="#url.NoOfCopies#" returnvariable="session.qLoadNumbers" /> 
					 <cflocation url="index.cfm?event=load" />
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
										<cfif (len(evaluate('Mp_StopDate_#qMPLoadDetails.currentrow#')) AND dateCompare(qMPLoadDetails.stopdate, evaluate('Mp_StopDate_#qMPLoadDetails.currentrow#')) NEQ 0)
											OR qMPLoadDetails.StopTime NEQ evaluate('Mp_StopTime_#qMPLoadDetails.currentrow#')
											OR qMPLoadDetails.TimeIn NEQ evaluate('Mp_TimeIn_#qMPLoadDetails.currentrow#')
											OR qMPLoadDetails.TimeOut NEQ evaluate('Mp_TimeOut_#qMPLoadDetails.currentrow#')
											OR qMPLoadDetails.Address NEQ evaluate('Mp_Address_#qMPLoadDetails.currentrow#')
											OR qMPLoadDetails.City NEQ evaluate('Mp_City_#qMPLoadDetails.currentrow#')
											OR qMPLoadDetails.StateCode NEQ evaluate('Mp_StateCode_#qMPLoadDetails.currentrow#')
											OR qMPLoadDetails.PostalCode NEQ evaluate('Mp_PostalCode_#qMPLoadDetails.currentrow#')
										>
											<cfset UpdateMP = 1>
										</cfif>
									</cfloop>
								</cfif>
								
								<cfif UpdateMP EQ 1>
									<cfinvoke component="#variables.objloadGateway#" method="saveMacroPointOrder" returnvariable="MPResponse"  CompanyID="#session.CompanyID#"  LoadID="#form.editid#" LastStopEventCompleted="#LastStopEventCompleted#"/>
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
							window.location = "index.cfm?event=myLoad&AlertvarP=#AlertvarP#&Ialert=#AlertvarT#&AlertvarI=#AlertvarI#&AlertvarM=#AlertvarM#&AlertvarN=#AlertvarN#&Alertvarq=#Alertvarq#&#session.URLToken#&#alertedi#&MPalert=#MPalert#&AlertvarDF=#AlertvarDF#";
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
							window.location = "index.cfm?event=addload&loadid=#insertedLoadId[1]#&AlertvarP=#AlertvarT#&AlertvarT=#AlertvarP#&AlertvarI=#AlertvarI#&AlertvarM=#AlertvarM#&Alertvarq=#Alertvarq#&#session.URLToken#&AlertvarDF=#AlertvarDF#";
							// <!--- window.location = "index.cfm?event=addload&loadid=#insertedLoadId[1]#&AlertvarP=#AlertvarP#&AlertvarT=#AlertvarT#&AlertvarI=#AlertvarI#&" --->
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
						window.location = "index.cfm?event=addload&loadid=#form.loadToSaveWithoutExit#&Palert=#AlertvarT#&Ialert=#AlertvarI#&AlertvarM=#AlertvarM#&AlertvarN=#AlertvarN#&Alertvarq=#Alertvarq#&#alertedi#&MPalert=#MPalert#&AlertvarDF=#AlertvarDF#";				
						
						</script>
					</cfoutput>
                <cfelseif (form.loadToCarrierFilter eq true and len(trim("form.loadToSaveWithoutExit") gt 1)  )>
                <!---and ( isdefined("form.loadToSaveWithoutExit") and len(trim(form.loadToSaveWithoutExit)) gt 1 ) and trim(insertedLoadId) neq '' --->
	                 <cfoutput>
						<script>
							window.location='index.cfm?event=carrier&#session.URLToken#&carrierfilter=true&equipment=#qLoadsLastStop.CONSIGNEEEQUIPMENTID#&consigneecity=#qLoadsLastStop.CONSIGNEECITY#&consigneestate=#qLoadsLastStop.CONSIGNEESTATE#&consigneeZipcode=#qLoadsLastStop.CONSIGNEEPOSTALCODE#&shippercity=#qLoadsFirstStop.SHIPPERCITY#&shipperstate=#qLoadsFirstStop.SHIPPERSTATE#&shipperZipcode=#qLoadsFirstStop.SHIPPERPOSTALCODE#&mytest=1';
						</script>
					</cfoutput>
				<cfelse>
					<cfset request.myLoadsAgentUserName = ''>
					<cfset request.subnavigation = includeTemplate("views/admin/loadNav.cfm", true) />
					<cfset request.content=includeTemplate("views/pages/load/disp_load.cfm",true)/>
					<cfset includeTemplate("views/templates/maintemplate.cfm") />
				</cfif>
			</cfcase>
            <cfcase value="advancedsearch">
              <cfinvoke component="#variables.objloadGateway#" method="getLoadStatus" returnvariable="request.qLoadStatus" />
              <cfinvoke component="#variables.objAgentGateway#" method="getAllStaes" returnvariable="request.qStates">
              <cfinvoke component="#variables.objAgentGateway#" method="getOffices" returnvariable="request.qoffices"/>
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
				<cfif form.submit eq 'Print BOL'>
					<cfinvoke component="#variables.objloadGateway#" method="AddBOLDetails" returnvariable="message">
					   <cfinvokeargument name="frmstruct" value="#formStruct#">
					 </cfinvoke>
					 <cfoutput>
						<cfif form.actionReport eq 'view'>
						<script>
							window.location = "index.cfm?event=BOLReport:print&loadid=#form.loadid#&#session.URLToken#";
						</script>
						<cfelseif form.actionReport eq 'mail'>
						<script>
							window.location = "index.cfm?event=BOLReport&loadid=#form.loadid#&#session.URLToken#";
							newwindow=window.open('index.cfm?event=loadMail&type=BOL&loadid=#form.loadid#&#session.URLToken#','Map','height=400,width=750');
							if (window.focus) {newwindow.focus()}
						</script>
						</cfif>
					</cfoutput>	 
				<cfelseif form.submit eq 'Print Short BOL'>
					<cfinvoke component="#variables.objloadGateway#" method="AddBOLDetails" returnvariable="message">
					   <cfinvokeargument name="frmstruct" value="#formStruct#">
					 </cfinvoke>
					<cfoutput>
						<script>
							window.location = "index.cfm?event=ShortBOLReport:print&loadid=#form.loadid#&#session.URLToken#";
						</script>
					</cfoutput>
				<cfelse>
					<cfoutput>
						<script>
							window.location = "index.cfm?event=BOLReport:print&loadid=#form.loadid#&#session.URLToken#";
						</script>
					</cfoutput>	 
				 </cfif>
                 <!---<cfif form.submit eq 'Save & View Report'>
					<cfinvoke component="#variables.objloadGateway#" method="AddBOLDetails" returnvariable="message">
					   <cfinvokeargument name="frmstruct" value="#formStruct#">
					 </cfinvoke>
					 <cfoutput>
						<script>
							window.location = "index.cfm?event=BOLReport:print&loadid=#form.loadid#&#session.URLToken#";
						</script>
					</cfoutput>	 
				<cfelse>
					<cfoutput>
						<script>
							window.location = "index.cfm?event=BOLReport:print&loadid=#form.loadid#&#session.URLToken#";
						</script>
					</cfoutput>	 
				 </cfif>---> 
              	<cfset includeTemplate("views/templates/maintemplate.cfm") />
            </cfcase>	
			<cfcase value="BOLReport:print">
			  <cfset formStruct = structNew()>
			  <cfset formStruct = form>
				<cfset Secret = application.dsn>
				<cfset TheKey = 'NAMASKARAM'>
				<cfset Encrypted = Encrypt(Secret, TheKey)>
				<cfset dsn = URLEncodedFormat(ToBase64(Encrypted))>
                 <cfif isdefined("url.loadid") and len(url.loadid) gt 1>
					  <cflocation url="../reports/loadreportForBOL.cfm?loadid=#url.loadid#&dsn=#dsn#" />
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
			     <!---<cfinvoke component="#variables.objloadGateway#" method="getAllLoads" returnvariable="request.qLoads" />--->
				 <!--- <cfdump var="#request.qLoads#"> --->
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
            <cfdefaultcase></cfdefaultcase>
		</cfswitch>
		</cfif>
</cfif>