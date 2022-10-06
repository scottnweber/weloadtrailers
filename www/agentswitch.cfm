<cfscript>
	variables.objAgentGateway = getGateway("gateways.agentgateway", MakeParameters("dsn=#Application.dsn#,pwdExpiryDays=#Application.pwdExpiryDays#"));
</cfscript>

<cfif request.event neq 'login' AND request.event neq 'customerlogin' AND request.event neq 'lostPassword' AND request.event neq 'lostCompanyCode' AND request.event neq 'lostUserName' AND request.event neq "recoveryEmailSuccess" AND request.event neq "GoogleMap">
		<cfif (not isdefined("session.passport.isLoggedIn") or not(session.passport.isLoggedIn))>
			<cflocation url="index.cfm?event=login&AlertMessageID=2" addtoken="no">
		<cfelse>
		<cfswitch expression="#request.event#">
			<cfcase value="agent">
				<cfinvoke component="#variables.objAgentGateway#" method="getAllAgent" returnvariable="request.qAgent" />
			    <cfset request.subnavigation = includeTemplate("views/admin/adminsubnav.cfm", true) />
				<cfset request.content = includeTemplate("views/pages/agent/disp_agent.cfm", true) />
			    <cfset includeTemplate("views/templates/maintemplate.cfm") /> 
			</cfcase>
			<cfcase value="addagent">
				<cfif structKeyExists(url, "agentid") and structKeyExists(session, "companyid")>
					<cfinvoke component="#variables.objAgentGateway#" method="checkAgentCompany" returnvariable="request.validCompany" agentid="#url.agentid#"/>
					<cfif not request.validCompany>
						<cflocation url="index.cfm?event=agent&sortorder=asc&sortby=Name&#Session.URLToken#">
					</cfif>
				</cfif>

				 <cfinvoke component="#variables.objAgentGateway#" method="getAllCountries" returnvariable="request.qCountries" />
				 <cfinvoke component="#variables.objAgentGateway#" method="getAllStaes" returnvariable="request.qstates"/>
				 <cfinvoke component="#variables.objAgentGateway#" method="getAllAgent" returnvariable="request.qAgent" />
				 <cfinvoke component="#variables.objAgentGateway#" method="getOffices" returnvariable="request.qoffices"/>
				 <cfinvoke component="#variables.objAgentGateway#" method="getAllRole" returnvariable="request.qRoles"/>
				 <cfset request.subnavigation = includeTemplate("views/admin/adminsubnav.cfm", true) />
				 <cfset request.content=includeTemplate("views/pages/agent/add_agent.cfm",true)/>
				 <cfset includeTemplate("views/templates/maintemplate.cfm") />
			</cfcase>
			<cfcase value="addagent:process">
				 <cfset formStruct = structNew()>
				 <cfset formStruct = form>
				 <cfset transMsg = "">

				<cfset variables.FailedLBResponse = "">
				
				<cfif structKeyExists(form,"IntegrateWithDirectFreightLoadboard")>
					<cfinvoke component="#variables.objAgentGateway#" method="verifyDirectFreightLoginStatus" returnvariable="DirectFreightLoginStatus">
						<cfinvokeargument name="DirectFreightLoadboardUserName" value="#formStruct.DirectFreightLoadboardUserName#">
						<cfinvokeargument name="DirectFreightLoadboardPassword" value="#formStruct.DirectFreightLoadboardPassword#">
				    </cfinvoke>
					<cfif not DirectFreightLoginStatus>
						<cfset structDelete(formStruct,"IntegrateWithDirectFreightLoadboard")>
						<cfset variables.FailedLBResponse = listAppend(variables.FailedLBResponse, 'DirectFreight')>
					</cfif>
				</cfif>

				<cfif structKeyExists(form,"integratewithPEP")>
					<cfinvoke component="#variables.objAgentGateway#" method="verifyPEPLoginStatus" returnvariable="PEPLoginStatus">
						<cfinvokeargument name="PEPcustomerKey" value="#formStruct.PEPcustomerKey#">
				    </cfinvoke>
					<cfif not PEPLoginStatus>
						<cfset structDelete(formStruct,"integratewithPEP")>
						<cfset variables.FailedLBResponse = listAppend(variables.FailedLBResponse, 'Post Everywhere')>
					</cfif>
				</cfif>

				 <cfif structKeyExists(form,"INTEGRATEWITHTRAN360")>
					<cfinvoke component="#variables.objAgentGateway#" method="verifyTrancoreLoginStatus" returnvariable="transLoginStatus">
						<cfinvokeargument name="tranUname" value="#formStruct.TRANS360USENAME#">
						<cfinvokeargument name="tranPwd" value="#formStruct.TRANS360PASSWORD#">
				    </cfinvoke>
					<cfif not transLoginStatus>
						<cfset structDelete(formStruct,"INTEGRATEWITHTRAN360")>
						<cfset variables.FailedLBResponse = listAppend(variables.FailedLBResponse, 'DAT')>
					</cfif>
				 </cfif>

				 <cfset session.FailedLBResponse = variables.FailedLBResponse>

				 <cfif isdefined("form.editid") and len(form.editId) gt 1>
				 	<cfinvoke component = "#variables.objAgentGateway#" method="getUserEditingDetails" agentid = '#form.editId#' returnvariable="qUserEditing"/>
				 	<cfset employeeID = 0/>
					<cfif structkeyexists(form,"agentdisabledStatus") and form.agentdisabledStatus neq true and qUserEditing.InUseBy eq session.empid>				 	
						<cfinvoke component="#variables.objAgentGateway#" method="UpdateAgent" returnvariable="employeeID">
							<cfinvokeargument name="formStruct" value="#formStruct#">
					    </cfinvoke>
					    <cfinvoke component="#variables.objAgentGateway#" method="updateEditingUserId" agentid="" userid="#session.empid#" status="true"/> 					    
					</cfif>
				 <cfelse>	 
					 <cfinvoke component="#variables.objAgentGateway#" method="AddAgent" returnvariable="employeeID">
						<cfinvokeargument name="formStruct" value="#formStruct#">
					 </cfinvoke>
				 </cfif>
				<cfif employeeID gt 0 and isdefined("form.editid") and len(form.editId) gt 1>
                	 <cfset session.message = 'User has been updated successfully.'>
				<cfelseif  employeeID gt 0>
	                <cfset session.message = 'User has been added successfully.'>
	            <cfelseif employeeID eq 0>
	            	<cfset session.message='Data not saved because it is edited by another person. Please contact administrator to unlock.'>				 
				</cfif>
					 
				 <cfif structKeyExists(form,"verifySMTP")>
					<cfset FA_TLS=False>
					<cfset FA_SSL=False>
					<cfif isdefined("formStruct.FA_SEC") and formStruct.FA_SEC eq "TLS">
						<cfset FA_TLS=True>
					</cfif>
					<cfif isdefined("formStruct.FA_SEC") and formStruct.FA_SEC eq "SSL">
						<cfset FA_SSL=True>
					</cfif>
					 <cfif isdefined("formStruct.FA_smtpPort") and formStruct.FA_smtpPort eq "">
						<cfset FA_port=0>
					 <cfelse>
						<cfset FA_port=formStruct.FA_smtpPort>
					 </cfif>
					 <cfinvoke component="#variables.objAgentGateway#" method="verifyMailServer" returnvariable="status">
						<cfinvokeargument name="host" value="#formStruct.FA_smtpAddress#">
						<cfinvokeargument name="protocol" value="smtp">
						<cfinvokeargument name="port" value=#FA_port#>
						<cfinvokeargument name="user" value="#formStruct.FA_smtpUsername#">
						<cfinvokeargument name="password" value="#formStruct.FA_smtpPassword#">
						<cfinvokeargument name="useTLS" value=#FA_TLS#>
						<cfinvokeargument name="useSSL" value=#FA_SSL#>
						<cfinvokeargument name="overwrite" value=false>
						<cfinvokeargument name="timeout" value=10000>
				     </cfinvoke>
					<cfif status.WASVERIFIED>
						<cfset verifiedStatus = "The SMTP settings are valid.">
						<cfif employeeID neq 0>
							<cfquery name="qsetSMTPverification" datasource="#application.dsn#">
								update employees set EmailValidated = 1
								where employeeid = <cfqueryparam value="#employeeID#" cfsqltype="cf_sql_varchar">
							</cfquery>
						</cfif>
					<cfelse>
						<cfset verifiedStatus = "The SMTP settings are not valid.">	
						<cfif employeeID neq 0>
							<cfquery name="qgetEmployeeSmtpDetails" datasource="#application.dsn#">
								select EmailID,SmtpAddress,SmtpUsername,SmtpPassword,SmtpPort,useSSL,useTLS 
								from employees 
								where employeeid = <cfqueryparam value="#employeeID#" cfsqltype="cf_sql_varchar">
							</cfquery>
							<cfif qgetEmployeeSmtpDetails.recordcount and len(trim(qgetEmployeeSmtpDetails.EmailID)) and len(trim(qgetEmployeeSmtpDetails.SmtpAddress)) and len(trim(qgetEmployeeSmtpDetails.SmtpUsername)) and len(trim(qgetEmployeeSmtpDetails.SmtpPassword)) and len(trim(qgetEmployeeSmtpDetails.SmtpPort))>
								<cfquery name="qsetSMTPverification" datasource="#application.dsn#">
									update employees set  EmailValidated = 0
									where employeeid = <cfqueryparam value="#employeeID#" cfsqltype="cf_sql_varchar">
								</cfquery>
							</cfif>
						</cfif>
					</cfif>
					
				</cfif>
                
                <cfif form.SaveAndExit eq 0 and isdefined('employeeID') and employeeID gt 0>
                 	<cfif isdefined('verifiedStatus')>  
				 	 <cfset redirect="index.cfm?event=addagent&agentId=#employeeID#&&#session.URLToken#&Palert=#verifiedStatus#">
                     <cfelse>
					 <cfset redirect="index.cfm?event=addagent&agentId=#employeeID#&&#session.URLToken#">
                    </cfif>
                	<cflocation url="#redirect#" addtoken="no">
                <cfelse>
                	<cfif isdefined('verifiedStatus')> 
                		<cflocation url="index.cfm?event=agent&sortorder=asc&sortby=Name&#Session.URLToken#&Palert=#verifiedStatus#">
                	<cfelse>
                		<cflocation url="index.cfm?event=agent&sortorder=asc&sortby=Name&#Session.URLToken#">
                	</cfif>
                </cfif>

            </cfcase>
            <cfcase value="postNote">
				<cfset includeTemplate("views/pages/agent/postNote.cfm") />
			</cfcase>
			<cfcase value="Alerts">
			    <cfset request.subnavigation = includeTemplate("views/admin/adminsubnav.cfm", true) />
				<cfset request.content = includeTemplate("views/pages/agent/disp_alert.cfm", true) />
			    <cfset includeTemplate("views/templates/maintemplate.cfm") /> 
			</cfcase>
			<cfcase value="AlertHistory">
			    <cfset request.subnavigation = includeTemplate("views/admin/adminsubnav.cfm", true) />
				<cfset request.content = includeTemplate("views/pages/agent/disp_alertHistory.cfm", true) />
			    <cfset includeTemplate("views/templates/maintemplate.cfm") /> 
			</cfcase>
			<cfcase value="AlertDetail">
				<cfinvoke component="#variables.objAlertGateway#" method="getAlertDetail" AlertID="#url.AlertID#" returnvariable="request.qAlertDetail" />
			    <cfset request.subnavigation = includeTemplate("views/admin/adminsubnav.cfm", true) />
				<cfset request.content = includeTemplate("views/pages/agent/alertDetail.cfm", true) />
			    <cfset includeTemplate("views/templates/maintemplate.cfm") /> 
			</cfcase>
			<cfcase value="claimAlert">
				<cfif form.claim EQ 'claim'>
					<cfinvoke component="#variables.objAlertGateway#" method="claimAlert" AlertID="#form.AlertID#" DueDate="#form.DueDate#" />
					<cfswitch expression="#form.Type#">
                        <cfcase value="Load">
							<cflocation url="index.cfm?event=addLoad&LoadID=#form.TypeID#&ClaimRate=1&#Session.URLToken#">
						</cfcase>
						<cfcase value="Carrier">
							<cflocation url="index.cfm?event=verifyCarrierOnBoardDoc&CurrIndex=1&CarrierID=#form.TypeID#&#Session.URLToken#">
						</cfcase>
						<cfdefaultcase></cfdefaultcase>
					</cfswitch>
				<cfelse>
					<cfinvoke component="#variables.objAlertGateway#" method="unClaimAlert" AlertID="#form.AlertID#" />
					<cfif structKeyExists(form, "Type") AND form.Type EQ 'Carrier'>
						<cfinvoke component="#variables.objCarrierGateway#" method="unVerifyCarrierDocs" CarrierID="#form.TypeID#" />
					</cfif>
					<cflocation url="index.cfm?event=Alerts&#Session.URLToken#">
				</cfif>
			</cfcase>
			<cfcase value="verifyCarrierOnBoardDoc">
				<cfinvoke component="#variables.objCarrierGateway#" method="getCarrierDocsForVerification" CarrierID="#url.CarrierID#" returnvariable="request.qDocs" />
				<cfinvoke component="#variables.objloadGateway#" method="getSystemSetupOptions" returnvariable="request.qGetSystemSetupOptions" />
			    <cfset request.subnavigation = includeTemplate("views/admin/adminsubnav.cfm", true) />
				<cfset request.content = includeTemplate("views/pages/agent/verifyCarrierOnBoardDoc.cfm", true) />
			    <cfset includeTemplate("views/templates/maintemplate.cfm") /> 
			</cfcase>

			<cfcase value="verifyCarrierOnBoardDoc:process">
				<cfinvoke component="#variables.objCarrierGateway#" method="VerifyDocument" frmstruct="#form#" returnvariable="carrierstatus"/>
				
				<cfset NewxIndex = form.CurrIndex+1>
				<cfif form.submit EQ 'NEXT'>
					<cflocation url="index.cfm?event=verifyCarrierOnBoardDoc&CurrIndex=#NewxIndex#&CarrierID=#form.CarrierID#&#Session.URLToken#">
				<cfelse>
					<cflocation url="index.cfm?event=addcarrier&CarrierID=#form.CarrierID#&ISCarrier=1&#Session.URLToken#">
				</cfif>
			</cfcase>
		</cfswitch>
		</cfif>
</cfif>
