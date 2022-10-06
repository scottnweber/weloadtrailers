<!--------------------------------------------------------------------------------------------------------------------------------------------------------->
<!--- DECLARE GATEWAYS --->
<!--------------------------------------------------------------------------------------------------------------------------------------------------------->
<cfif structKeyExists(session, "dashboardUser") and session.dashboardUser eq 1 and not listFindNoCase('dashboard,logout:process,login,login:process', url.event)>
	<cflocation url="index.cfm?event=dashboard" addtoken="yes" />
</cfif>
<cfscript>
	variables.objSecurityGateway = getGateway("gateways.security.securitygateway", MakeParameters("dsn=#Application.dsn#,pwdExpiryDays=#Application.pwdExpiryDays#"));
	variables.objloadGateway = getGateway("gateways.loadgateway", MakeParameters("dsn=#Application.dsn#,pwdExpiryDays=#Application.pwdExpiryDays#"));
	variables.objloadGatewaynew = getGateway("gateways.loadgatewaynew", MakeParameters("dsn=#Application.dsn#,pwdExpiryDays=#Application.pwdExpiryDays#"));
	variables.objAgentGateway = getGateway("gateways.agentgateway", MakeParameters("dsn=#Application.dsn#,pwdExpiryDays=#Application.pwdExpiryDays#"));
	variables.objequipmentGateway = getGateway("gateways.equipmentgateway", MakeParameters("dsn=#Application.dsn#,pwdExpiryDays=#Application.pwdExpiryDays#"));
	variables.objPrivilegeXmlGateway = getGateway("gateways.security.privilegexmlgateway", MakeParameters("xmlFilePath=#ExpandPath('#request.strBase#../config/privileges.xml')#"));

	variables.objCustomerGateway = getGateway("gateways.customergateway", MakeParameters("dsn=#Application.dsn#,pwdExpiryDays=#Application.pwdExpiryDays#"));
	variables.objCarrierGateway = getGateway("gateways.carriergateway", MakeParameters("dsn=#Application.dsn#,pwdExpiryDays=#Application.pwdExpiryDays#"));
	variables.objunitGateway = getGateway("gateways.unitgateway", MakeParameters("dsn=#Application.dsn#,pwdExpiryDays=#Application.pwdExpiryDays#"));
	variables.objAlertGateway = getGateway("gateways.alertgateway", MakeParameters("dsn=#Application.dsn#,pwdExpiryDays=#Application.pwdExpiryDays#"));
	variables.objOfficeGateway = getGateway("gateways.officegateway", MakeParameters("dsn=#Application.dsn#,pwdExpiryDays=#Application.pwdExpiryDays#"));
</cfscript>

<!--------------------------------------------------------------------------------------------------------------------------------------------------------->
<!--- MAIN SECTION - DEFINE YOUR EVENTS HERE --->
<!--------------------------------------------------------------------------------------------------------------------------------------------------------->
<!--- <cfdump var="#request.event#" /><cfabort /> --->
<cfif structKeyExists(request, "event") and listFindNoCase("companyinfo,systemsetup,loadstatussetup,crmNoteTypes,attachmentTypes,QuickBooksExport,CarrierQuoteReport,AgingReports,ExportExcel,Form1099,QuickBooksExportAP,QuickBooksExportHistory,Dashboard,", request.event) and (not isdefined("session.passport.isLoggedIn") or not(session.passport.isLoggedIn))>
	<cflocation url="index.cfm?event=login&AlertMessageID=2" addtoken="no">
</cfif>
<cfswitch expression="#request.event#">
	<cfcase value="noPrivileges">
		<cfset request.content = includeTemplate("views/security/noaccess.cfm", true) />
		<cfif IsDefined("URL.blnIsTab") And URL.blnIsTab>
			<cfset includeTemplate("views/templates/iframetemplate.cfm") />
		<cfelseif IsDefined("URL.blnIFrame") And URL.blnIFrame>
			<cfset request.blnIncludeBorder = False />
			<cfset includeTemplate("views/templates/iframetemplate.cfm") />
		<cfelse>
			<cfset includeTemplate("views/templates/maintemplate.cfm") />
		</cfif>
	</cfcase>
	<cfcase value="login">
		<cfset variables.showCaptcha = 1>
		<cfquery name="qPaymentDue" datasource="LoadManagerAdmin">
			SELECT PaymentDue AS Message
			FROM  SystemSetup
		</cfquery>
		<cfif isDefined("Cookie") and isStruct(Cookie) and structKeyExists(Cookie, "CaptchaCookie")>
			<cfset variables.showCaptcha = 0>
		</cfif>
		<cfset request.content = includeTemplate("views/security/loginform.cfm", true) />
		<cfset includeTemplate("views/templates/maintemplate.cfm") />
	</cfcase>
	<cfcase value="login:process">

		<cfif structKeyExists(Form, "CompanyCode")>
			<cfset Form.txtCompanyCode = Form.CompanyCode>
		</cfif>

		<cfif not structKeyExists(Form, "txtCompanyCode")>
			<cflocation url="index.cfm?event=login&AlertMessageID=12" addtoken="yes" />	
		</cfif>
		<cfif structKeyExists(form, "Captcha") and structKeyExists(form, "CaptchaCheck") and  form.Captcha NEQ form.CaptchaCheck>
			<cflocation url="index.cfm?event=login&AlertMessageID=10" addtoken="yes" />
		</cfif>
		<cfset session.dashboardUser = 0>
		<cfquery name="qDashBoardUser" datasource="#Application.dsn#">
			SELECT 
			S.SystemConfigID,
			S.DashboardUser,
			S.DashboardPassword,
			C.CompanyID
			FROM SystemConfig S
			INNER JOIN Companies C ON C.CompanyID = S.CompanyID
			WHERE S.DashboardUser = <cfqueryparam value="#Form.TXTUSERNAME#" cfsqltype="cf_sql_varchar"> AND S.DashboardPassword = <cfqueryparam value="#Form.TXTLOGINPASSWORD#" cfsqltype="cf_sql_varchar">
			AND C.CompanyCode = <cfqueryparam value="#Form.TXTCOMPANYCODE#" cfsqltype="cf_sql_varchar"> AND C.IsActive = 1
		</cfquery>
		<cfif qDashBoardUser.recordcount>
			<cfset session.dashboardUser = 1>
			<cfset session.passport.isLoggedIn = 1>
			<cfset session.passport.PasswordExpired = 0>
			<cfset session.CompanyID = qDashBoardUser.CompanyID>
			<cfset session.EmpID = qDashBoardUser.SystemConfigID>
			<cfset session.showLicenseTerms = 0>
			<cflocation url="index.cfm?event=dashboard" addtoken="yes" />
		</cfif>

		<cfif StructKeyExists(Form, "txtCompanyCode")>
			<cfquery name="qDelExpiredUsers" datasource="#Application.dsn#" result="sample">
				DELETE FROM userCountCheck
				WHERE DATEDIFF(hour, currenttime, getdate()) >= 24
				AND CUTOMERID IN (SELECT E.EmployeeID from Employees E INNER JOIN Offices O ON O.OfficeID = E.OfficeID
				INNER JOIN Companies C ON C.CompanyID = O.CompanyID WHERE C.CompanyCode = <cfqueryparam value="#Form.txtCompanyCode#" cfsqltype="cf_sql_varchar">)
			</cfquery>
		</cfif>

		<cfif StructKeyExists(Form, "txtUsername")>
			<cfquery name="qActiveUsers" datasource="#Application.dsn#" result="sample">
				DELETE FROM userCountCheck
				WHERE loginname = <cfqueryparam value="#Form.txtUsername#" cfsqltype="cf_sql_varchar">
				AND CUTOMERID IN (SELECT E.EmployeeID from Employees E INNER JOIN Offices O ON O.OfficeID = E.OfficeID
				INNER JOIN Companies C ON C.CompanyID = O.CompanyID WHERE C.CompanyCode = <cfqueryparam value="#Form.txtCompanyCode#" cfsqltype="cf_sql_varchar">)
			</cfquery>
		</cfif>
		<cfquery name="qCheckCompanyActive" datasource="#Application.dsn#">
			SELECT isActive FROM Companies WHERE CompanyCode = <cfqueryparam value="#Form.txtCompanyCode#" cfsqltype="cf_sql_varchar">
		</cfquery>
		<cfif qCheckCompanyActive.recordcount AND qCheckCompanyActive.isActive EQ 0>
			<cflocation url="index.cfm?event=login&AlertMessageID=11" addtoken="yes" />
		</cfif>
		<cfquery name="qActiveUsers" datasource="#Application.dsn#">
			SELECT 	cutomerId
			FROM	userCountCheck
			WHERE CUTOMERID IN (SELECT E.EmployeeID from Employees E INNER JOIN Offices O ON O.OfficeID = E.OfficeID
				INNER JOIN Companies C ON C.CompanyID = O.CompanyID WHERE C.CompanyCode = <cfqueryparam value="#Form.txtCompanyCode#" cfsqltype="cf_sql_varchar">)
		</cfquery>

		<cfquery name="qGetAllowedUsers" datasource="#Application.dsn#">
			SELECT *
			FROM SystemConfig INNER JOIN Companies ON SystemConfig.CompanyID = Companies.CompanyID WHERE Companies.CompanyCode = <cfqueryparam cfsqltype="cf_sql_varchar" value="#form.TXTCOMPANYCODE#" />
		</cfquery>
		<cfif application.dsn EQ 'LoadManagerBeta'>
			<cfif qGetAllowedUsers.recordcount>
				<cfinvoke component="#variables.objloadGateway#" method="getPaymentExpiry" CompanyID = "#qGetAllowedUsers.CompanyID#" returnvariable="qPaymentExpiryDays" />
				<cfif qPaymentExpiryDays.recordcount and qPaymentExpiryDays.expiryDays LTE 0>
					<cfset session.PaymentExpired = 1>
					<cflocation url="index.cfm?event=login" addtoken="yes" />
				</cfif>
			</cfif>
		</cfif>
		<cfif qGetAllowedUsers.recordcount>
			<cfset local.allowedUserLimit = qGetAllowedUsers.allowed_users>
		<cfelse>
			<cfset local.allowedUserLimit = 999999>
		</cfif>
		
		<cfquery name="qGetEmployee" datasource="#Application.dsn#">
			SELECT E.Name as EmployeeName
			FROM Employees E
			INNER JOIN Offices O ON O.OfficeID = E.OfficeID
			INNER JOIN Companies C ON C.CompanyID = O.CompanyID
			WHERE E.loginId = <cfqueryparam cfsqltype="cf_sql_varchar" value="#form.TXTUSERNAME#" />
				AND E.password = <cfqueryparam cfsqltype="cf_sql_varchar" value="#form.TXTLOGINPASSWORD#" />
				AND C.CompanyCode = <cfqueryparam cfsqltype="cf_sql_varchar" value="#form.TXTCOMPANYCODE#" /> 
				AND E.isActive = 1 
		</cfquery>
		
		<cfquery name="checkGlobalUser" datasource="LoadManagerAdmin">
			SELECT ID FROM GlobalUsers WHERE LoginID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#form.TXTUSERNAME#" />
			AND Password = <cfqueryparam cfsqltype="cf_sql_varchar" value="#form.TXTLOGINPASSWORD#" />
		</cfquery>

		<cfif qActiveUsers.recordcount LT local.allowedUserLimit OR (qGetEmployee.recordcount AND qGetEmployee.EmployeeName EQ "Z. Scott Weber") OR checkGlobalUser.recordCount>
			<!--- Check if the variables exists --->
			<cfif Not StructKeyExists(Form, "txtUsername")>
				<cfthrow errorcode="1001" message="Username Missing" detail="The Username has not been specified on the previous page" />
			</cfif>
			<cfif Not StructKeyExists(Form, "txtLoginPassword")>
				<cfthrow errorcode="1001" message="Password Missing" detail="The Password has not been specified on the previous page" />
			</cfif>
			<cfif Not StructKeyExists(Form, "TXTCOMPANYCODE")>
				<cfthrow errorcode="1001" message="Company Code Missing" detail="The Company Code has not been specified on the previous page" />
			</cfif>
			<cfif StructKeyExists(session,"CustomerID") AND session.CustomerID NEQ "">
				<cfset structDelete(session, "CustomerID") />
				<cfset structDelete(session, "iscustomer") />
			</cfif>
			<cfset session.passport = doLogin(strUsername=FORM.txtUsername, strPassword=FORM.txtLoginPassword, strCompanycode = FORM.TXTCOMPANYCODE) />

	        <cfif session.passport.isLoggedIn>
				<cfset session.AdminUserName = FORM.txtUsername>
				<cfset session.UserCompanyCode = FORM.txtCompanyCode>
	            <cfinvoke component="#variables.objAgentGateway#" method="GetUserInfo" returnvariable="request.qUserInfo">
	            	<cfinvokeargument name="userName" value="#session.AdminUserName#">
	            	<cfinvokeargument name="CompanyCode" value="#session.UserCompanyCode#">
	            </cfinvoke>

	            <cfif structKeyExists(form, "Captcha") and structKeyExists(form, "CaptchaCheck") and structKeyExists(form, "Remember")>
	            	<cfcookie name="CaptchaCookie" value="#DateTimeFormat(now(),"YYYYMMddHHnnssl")#" expires="never">
		        </cfif>

		        <cfif not (isDefined("Cookie") and isStruct(Cookie) and structKeyExists(Cookie, "CompanyCode"))>
		        	<cfcookie name="CompanyCode" value="#session.UserCompanyCode#" expires="never">
		        </cfif>
				<!---USP_GetUserInfoUserName--->
	            <cfset session.currentUserType = request.qUserInfo.RoleValue>
	            <cfset session.empid = request.qUserInfo.EmployeeID>
	            <cfset session.UserFullName = request.qUserInfo.Name>
	            <cfset session.rightsList = request.qUserInfo.userRights>
	            <cfset session.CompanyID = request.qUserInfo.CompanyID>

	            <cfquery name="qUpdLastLogin" datasource="#Application.dsn#">
					UPDATE Companies SET LastLoginDate = GETDATE(),LastLoginName=<cfqueryparam cfsqltype="cf_sql_varchar" value="#session.AdminUserName#">
					WHERE CompanyID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#request.qUserInfo.CompanyID#">
				</cfquery>
				<cfset session.editableStatuses = request.qUserInfo.EditableStatuses>
				<cfset session.dashboardUser = 0>
	            <cfset session.userUniqueId = CreateUUID()>
	            <cfquery name="qInsertActiveStatus" datasource="#Application.dsn#" result="qInsertActiveStatus">
					insert into userCountCheck (cutomerId,currenttime,isactive,isLoggedIn,username,useruniqueid,loginname,companyid)
					VALUES(
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#Session.empid#">,
						<cfqueryparam cfsqltype="cf_sql_timestamp" value="#CreateODBCDateTime(now())#">,
						<cfqueryparam cfsqltype="cf_sql_integer" value="1">,
						<cfqueryparam cfsqltype="cf_sql_integer" value="1">,
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#session.UserFullName#" null="#yesNoFormat(NOT len(session.UserFullName))#">,
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#session.userUniqueId#">,
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#session.AdminUserName#">,
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#session.CompanyID#">
					)
				</cfquery>

				<cfquery name="qGetUserStatus" datasource="#Application.dsn#">
					SELECT LoadStatusTypeID FROM AgentsLoadTypes WHERE AgentID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#Session.empid#">
				</cfquery>

				<cfset session.UserAssignedLoadStatus["MyLoads"] = valueList(qGetUserStatus.LoadStatusTypeID)>
				<cfset session.UserAssignedLoadStatus["AllLoads"] = valueList(qGetUserStatus.LoadStatusTypeID)>
				<cfset session.UserAssignedLoadStatus["Default"] = valueList(qGetUserStatus.LoadStatusTypeID)>

				<cfinvoke component="#variables.objAgentGateway#" method="validateAndUpdateSMTP" returnvariable="session.SMTPValidOnLogin">
		           	<cfinvokeargument name="login" value="#FORM.txtUsername#">
		           	<cfinvokeargument name="password" value="#FORM.txtLoginPassword#">
		           	<cfinvokeargument name="CompanyCode" value="#FORM.txtCompanyCode#">
		           	<cfinvokeargument name="dsn" value="#Application.dsn#">
		        </cfinvoke>
				<cfif session.passport.PasswordExpired Or session.passport.PasswordAlmostExpired>
					<cflocation url="index.cfm?event=passwordExpired" addtoken="yes" />
				<cfelse>
					<cfif CheckObjectAccess("navMainClients")>
						<cflocation url="index.cfm?event=SearchClient" addtoken="yes" />
					<cfelse>
						<cfinvoke component="#variables.objloadGateway#" method="CheckCarrierUpdate" returnvariable="session.isSaferWatchCarrierUpdate" />
						<cfif not request.qUserInfo.LicenseTermsAccepted>
							<cfset session.showLicenseTerms = 0>
						</cfif>
						<cflocation url="index.cfm?event=Myload" addtoken="yes" />
					</cfif>
				</cfif>
			<cfelse>
				<cflocation url="index.cfm?event=login&AlertMessageID=1" addtoken="yes" />
			</cfif>
		<cfelse>
			<cfif structKeyExists(Form, "txtCompanyCode")>
				<cflocation url="index.cfm?event=login&allowedUserFlagID=0&txtCompanyCode=#form.txtCompanyCode#" addtoken="yes" />
			<cfelse>
				<cflocation url="index.cfm?event=login&allowedUserFlagID=0" addtoken="yes" />
			</cfif>
			
		</cfif>

	</cfcase>
	<cfcase value="customerlogin">
		<cfset request.content = includeTemplate("views/security/Customerloginform.cfm", true) />
		<cfset includeTemplate("views/templates/maintemplate.cfm") />
	</cfcase>

	<cfcase value="Customerlogin:process">
		<!--- Check if the variables exists --->
		<cfif Not StructKeyExists(Form, "Username")>
			<cfthrow errorcode="1001" message="Username Missing" detail="The Username has not been specified on the previous page" />
		</cfif>
		<cfif Not StructKeyExists(Form, "LoginPassword")>
			<cfthrow errorcode="1001" message="Password Missing" detail="The Password has not been specified on the previous page" />
		</cfif>
		<cfif Not StructKeyExists(Form, "txtCompanyCode")>
			<cfthrow errorcode="1001" message="Company Code Missing" detail="The Company Code has not been specified on the previous page" />
		</cfif>
		<cfset session.passport = CustomerdoLogin(strUsername=FORM.Username, strPassword=FORM.LoginPassword,strCompanycode = FORM.TXTCOMPANYCODE) />
        <cfif session.passport.isLoggedIn>
			<cfset session.AdminUserName = FORM.Username>
			<cfset request.qUserRole.RoleValue = 8>
			<cfset request.qUserRole.userRights = 'ViewLoad'>
            <cfquery name="request.qUserInfo" datasource="#Application.dsn#">
            	SELECT C.CustomerName,CMP.CompanyID FROM Customers C
            	INNER JOIN CustomerOffices CO ON CO.CustomerID = C.CustomerID
            	INNER JOIN Offices O on O.OfficeID = CO.OfficeID
            	INNER JOIN Companies CMP on CMP.CompanyID = O.CompanyID
            	WHERE C.username = <cfqueryparam value="#session.AdminUserName#" cfsqltype="cf_sql_varchar">
            	AND CMP.CompanyCode = <cfqueryparam value="#FORM.TXTCOMPANYCODE#" cfsqltype="cf_sql_varchar">
            </cfquery>

            <!---USP_GetUserInfoUserName--->

            <cfset session.currentUserType = request.qUserRole.RoleValue>
            <cfset session.UserFullName = request.qUserInfo.CUSTOMERNAME>
            <cfset session.rightsList = request.qUserRole.userRights>
			<cfif session.passport.PasswordExpired Or session.passport.PasswordAlmostExpired>
				<cflocation url="index.cfm?event=passwordExpired" addtoken="yes" />
			<cfelse>
				<cfif CheckObjectAccess("navMainClients")>
					<cflocation url="index.cfm?event=SearchClient" addtoken="yes" />
				<cfelse>
					<cflocation url="index.cfm?event=load" addtoken="yes" />
				</cfif>
			</cfif>
		<cfelse>
			<cflocation url="index.cfm?event=CustomerLogin&AlertMessageID=1" addtoken="yes" />
		</cfif>

	</cfcase>

	<cfcase value="passwordExpired">
		<cfset request.content = includeTemplate("views/security/passwordexpired.cfm", true) />
		<cfset includeTemplate("views/templates/maintemplate.cfm") />
	</cfcase>

	<cfcase value="changePassword:Form">
		<cfset request.SubHeading = "Change Password">
		<cfset request.content = includeTemplate("views/security/loginchangepwd.cfm", true) />
		<cfset includeTemplate("views/templates/maintemplate.cfm") />
	</cfcase>

	<cfcase value="lostpassword">
		<cfset request.content = includeTemplate("views/security/lostpassword.cfm", true) />
		<cfset includeTemplate("views/templates/maintemplate.cfm") />
	</cfcase>

	<cfcase value="lostCompanyCode">
		<cfset request.content = includeTemplate("views/security/lostCompanyCode.cfm", true) />
		<cfset includeTemplate("views/templates/maintemplate.cfm") />
	</cfcase>

	<cfcase value="lostUserName">
		<cfset request.content = includeTemplate("views/security/lostUserName.cfm", true) />
		<cfset includeTemplate("views/templates/maintemplate.cfm") />
	</cfcase>

    <cfcase value="recoveryEmailSuccess">
		<cfset request.content = includeTemplate("views/security/recoveryEmailSuccess.cfm", true) />
		<cfset includeTemplate("views/templates/maintemplate.cfm") />
	</cfcase>

	<cfcase value="lostpassword:process">

		<cfset SmtpAddress='smtpout.secureserver.net'>
		<cfset SmtpUsername='support@loadmanager.com '>
		<cfset SmtpPort='465'>
		<cfset SmtpPassword='Wsi2008!'>
		<cfset FA_SSL=1>
		<cfset FA_TLS=0>

		<cfif StructKeyExists(url,'type') and url.type eq 'c'>
			<cfset request.CustomerDetails = variables.objSecurityGateway.checkCustomerLostPassword("#form.txtEmailAddress#","#form.txtUsername#","#form.txtCompanyCode#")>

			<cfif request.CustomerDetails.recordcount GT 0>
				<cfmail from="#SmtpUsername#" subject="Lost Password Retrieval" to="#form.txtEmailAddress#" type="html" server="#SmtpAddress#" username="#SmtpUsername#" password="#SmtpPassword#" port="#SmtpPort#" usessl="#FA_SSL#" usetls="#FA_TLS#" >
					<table>
						<tr>
							<td>Dear #request.CustomerDetails.CustomerName#</td>
						</tr>
						<tr>
							<td>&nbsp;</td>
						</tr>
						<tr>
							<td>You entered the "Lost Password" section of the system and have asked us to retrieve your password. If you have received this email in error please contact the system administrator immediately.</td>
						</tr>
						<tr>
							<td>Username: #request.CustomerDetails.userName#</td>
						</tr>
						<tr>
							<td>Password: #request.CustomerDetails.Password#</td>
						</tr>
					</table>
				</cfmail>
				<cflocation url="index.cfm?event=recoveryEmailSuccess&Success=y&type=c" addtoken="yes" />
			<cfelse>
				<cflocation url="index.cfm?event=lostpassword&Failed=y&type=c" addtoken="yes" />
			</cfif>
		<cfelse>
			<cfif structIsEmpty(form)>
				<cflocation url="index.cfm?event=lostpassword" addtoken="yes" />
			</cfif>
			<cfset request.UserDetails = variables.objSecurityGateway.checkLostPassword("#form.txtCompanyCode#","#form.txtUsername#","#form.txtEmailAddress#")>

			<cfif request.UserDetails.recordcount GT 0 AND len(trim(request.UserDetails.EmailId))>
				<cfmail from="#SmtpUsername#" subject="Lost Password Retrieval" to="#request.UserDetails.EmailId#" type="html" server="#SmtpAddress#" username="#SmtpUsername#" password="#SmtpPassword#" port="#SmtpPort#" usessl="#FA_SSL#" usetls="#FA_TLS#" >
					<table>
						<tr>
							<td>Dear #request.UserDetails.Name#</td>
						</tr>
						<tr>
							<td>&nbsp;</td>
						</tr>
						<tr>
							<td>You entered the "Lost Password" section of the system and have asked us to retrieve your password. If you have received this email in error please contact the system administrator immediately.</td>
						</tr>
						<tr>
							<td>Username: #request.UserDetails.loginid#</td>
						</tr>
						<tr>
							<td>Password: #request.UserDetails.Password#</td>
						</tr>
					</table>
				</cfmail>
				<cflocation url="index.cfm?event=recoveryEmailSuccess&Success=y" addtoken="yes" />
			<cfelse>
				<cflocation url="index.cfm?event=lostpassword&Failed=y" addtoken="yes" />
			</cfif>
		</cfif>
	</cfcase>

	<cfcase value="lostCompanyCode:process">

		<cftry>
			<cfset SmtpAddress='smtpout.secureserver.net'>
			<cfset SmtpUsername='support@loadmanager.com '>
			<cfset SmtpPort='465'>
			<cfset SmtpPassword='Wsi2008!'>
			<cfset FA_SSL=1>
			<cfset FA_TLS=0>

			<cfset request.UserDetails = variables.objSecurityGateway.checkLostCompanyCode("#form.txtCompanyName#","#form.txtEmailAddress#")>

			<cfif request.UserDetails.recordcount>
				<cfmail from="#SmtpUsername#" subject="Account Recovery" to="#form.txtEmailAddress#" type="html" server="#SmtpAddress#" username="#SmtpUsername#" password="#SmtpPassword#" port="#SmtpPort#" usessl="#FA_SSL#" usetls="#FA_TLS#" >
					<table>
						<tr>
							<td>Dear #form.txtUsername#</td>
						</tr>
						<tr>
							<td>&nbsp;</td>
						</tr>
						<tr>
							<td>You entered the "Account Recovery" section of the system and have asked us to retrieve your company code. If you have received this email in error please contact the system administrator immediately.</td>
						</tr>
						<tr>
							<td>Company Code: #request.UserDetails.CompanyCode#</td>
						</tr>
						<tr>
							<td>Company Name: #form.txtCompanyName#</td>
						</tr>
					</table>
				</cfmail>
				<cflocation url="index.cfm?event=recoveryEmailSuccess&Success=y&Type=CompanyCode" addtoken="yes" />
			<cfelse>
				<cflocation url="index.cfm?event=lostCompanyCode&Failed=y" addtoken="yes" />
			</cfif>
		<cfcatch>
			<cflocation url="index.cfm?event=lostCompanyCode&Failed=y" addtoken="yes" />
		</cfcatch>
		</cftry>
	</cfcase>

	<cfcase value="lostUserName:process">

		<cfif NOT structKeyExists(form, "txtCompanyCode") OR NOT structKeyExists(form, "txtUsername") OR NOT structKeyExists(form, "txtEmailAddress")>
			<cflocation url="index.cfm?event=lostUsername&Failed=y" addtoken="yes" />
		</cfif>

		<cfset SmtpAddress='smtpout.secureserver.net'>
		<cfset SmtpUsername='support@loadmanager.com '>
		<cfset SmtpPort='465'>
		<cfset SmtpPassword='Wsi2008!'>
		<cfset FA_SSL=1>
		<cfset FA_TLS=0>

		<cfset request.UserDetails = variables.objSecurityGateway.checkLostUserName("#form.txtCompanyCode#","#form.txtUsername#","#form.txtEmailAddress#")>

		<cfif request.UserDetails.recordcount>
			<cfmail from="#SmtpUsername#" subject="Account Recovery" to="#request.UserDetails.EmailId#" type="html" server="#SmtpAddress#" username="#SmtpUsername#" password="#SmtpPassword#" port="#SmtpPort#" usessl="#FA_SSL#" usetls="#FA_TLS#" >
					<table>
						<tr>
							<td>Dear #form.txtUsername#</td>
						</tr>
						<tr>
							<td>&nbsp;</td>
						</tr>
						<tr>
							<td>You entered the "Account Recovery" section of the system and have asked us to retrieve your password. If you have received this email in error please contact the system administrator immediately.</td>
						</tr>
						<tr>
							<td>Username: #request.UserDetails.loginid#</td>
						</tr>
						<tr>
							<td>Password: #request.UserDetails.Password#</td>
						</tr>
					</table>
				</cfmail>
			<cflocation url="index.cfm?event=recoveryEmailSuccess&Success=y&Type=UserName" addtoken="yes" />
		<cfelse>
			<cflocation url="index.cfm?event=lostUsername&Failed=y" addtoken="yes" />
		</cfif>
	</cfcase>

	<cfcase value="changePassword:Process">
		<cfset request.SubHeading = "Change Password">
		<cfset PasswordCheck = doLogin(strUsername=FORM.txtUsername, strPassword=FORM.txtOldPassword) />
		<cfset request.siteUserBean = GetBean("beans.siteuserbean") />
		<cfif PasswordCheck.isLoggedIn>
			<cfinvoke component="#variables.objSecurityGateway#" method="ChangeUserPassword" returnvariable="request.intSiteUserID">
				<cfinvokeargument name="intSiteUserID" value="#session.passport.CurrentSiteUser.getSiteUserID()#" />
				<cfinvokeargument name="strUsername" value="#session.passport.CurrentSiteUser.getUsername()#" />
				<cfinvokeargument name="strPassword" value="#FORM.txtNewPassword#" />
			</cfinvoke>
			<cfset Session.Passport.PasswordExpired = false>
			<cfset request.content = includeTemplate("views/security/loginchangepwdsuccess.cfm", true) />
			<cfset includeTemplate("views/templates/maintemplate.cfm") />
		<cfelse>
			<cfset request.content = includeTemplate("views/security/loginchangepwd.cfm", true) />
			<cfset includeTemplate("views/templates/maintemplate.cfm") />
		</cfif>
	</cfcase>

	<cfcase value="logout:process">
		<cfif structkeyexists(Session,"empid") and len(trim(Session.empid)) and structKeyExists(Session, "useruniqueid") and len(Session.useruniqueid)>
			<cfif structKeyExists(url, "event") and url.event neq "addload" and url.event neq "nextStopLoad" and structkeyexists(session,"currentloadid") and len(trim(session.currentloadid))>
				<cfinvoke component="#variables.objloadGateway#" method="getUserEditingDetails" loadid="#session.currentloadid#" returnvariable="request.qryUserId"/>
				<cfif request.qryUserId.recordcount and request.qryUserId.inuseby eq  session.empid >
					<cfinvoke component="#variables.objloadGateway#" method="updateEditingUserId" loadid="" userid="#session.empid#" status="true"/>
				</cfif>
			</cfif>
			<!--- on load a session when user enters an edit record--->

			<!--- Release lock on customer record while logging off --->
			<cfif structKeyExists(url, "event") and url.event neq "addCustomer" and structkeyexists(session,"currentCustomerId") and len(trim(session.currentCustomerId))>
				<cfinvoke component="#variables.objCustomerGateway#" method="getUserEditingDetails" customerid="#session.currentCustomerId#" returnvariable="request.qryUserId"/>
				<cfif request.qryUserId.recordcount and request.qryUserId.inuseby eq  session.empid >
					<cfinvoke component="#variables.objCustomerGateway#" method="updateEditingUserId" customerid="" userid="#session.empid#" status="true"/>
				</cfif>
			</cfif>



			<!--- Release lock on carrier record while logging off --->
			<cfif structKeyExists(url, "event") and url.event neq "addcarrier" and structkeyexists(session,"currentCarrierId") and len(trim(session.currentCarrierId))>
				<cfinvoke component="#variables.objCarrierGateway#" method="getUserEditingDetails" carrierid="#session.currentCarrierId#" returnvariable="request.qryUserId"/>
				<cfif request.qryUserId.recordcount and request.qryUserId.inuseby eq  session.empid >
					<cfinvoke component="#variables.objCarrierGateway#" method="updateEditingUserId" carrierid="" userid="#session.empid#" status="true"/>
				</cfif>
			</cfif>

			<!--- Release lock on agent record while logging off --->
			<cfif structKeyExists(url, "event") and url.event neq "addagent" and structkeyexists(session,"currentAgentId") and len(trim(session.currentAgentId))>
				<cfinvoke component="#variables.objAgentGateway#" method="getUserEditingDetails" agentid="#session.currentAgentId#" returnvariable="request.qryUserId"/>
				<cfif request.qryUserId.recordcount and request.qryUserId.inuseby eq  session.empid >
					<cfinvoke component="#variables.objAgentGateway#" method="updateEditingUserId" agentid="" userid="#session.empid#" status="true"/>
				</cfif>
			</cfif>


			<!--- Release lock on equipments record while logging off --->
			<cfif structKeyExists(url, "event") and url.event neq "addEquipment" and structkeyexists(session,"currentEquipmentId") and len(trim(session.currentEquipmentId))>
				<cfinvoke component="#variables.objEquipmentGateway#" method="getUserEditingDetails" equipmentid="#session.currentEquipmentId#" returnvariable="request.qryUserId"/>
				<cfif request.qryUserId.recordcount and request.qryUserId.inuseby eq  session.empid >
					<cfinvoke component="#variables.objEquipmentGateway#" method="updateEditingUserId" equipmentid="" userid="#session.empid#" status="true"/>
				</cfif>
			</cfif>			


			<!--- Release lock on carrier record while logging off --->
			<cfif structKeyExists(url, "event") and url.event neq "adddriver" and structkeyexists(session,"currentDriverId") and len(trim(session.currentDriverId))>
				<cfinvoke component="#variables.objCarrierGateway#" method="getUserEditingDetails" carrierid="#session.currentDriverId#" returnvariable="request.qryUserId"/>
				<cfif request.qryUserId.recordcount and request.qryUserId.inuseby eq  session.empid >
					<cfinvoke component="#variables.objCarrierGateway#" method="updateEditingUserId" carrierid="" userid="#session.empid#" status="true"/>
				</cfif>
			</cfif>

			<cfquery name="qGetUserLoggedInCount" datasource="#Application.dsn#">
				select cutomerId,currenttime
				from userCountCheck
				where cutomerId = <cfqueryparam cfsqltype="cf_sql_varchar" value="#Session.empid#">
				AND useruniqueid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#Session.useruniqueid#">
			</cfquery>

			<cfif qGetUserLoggedInCount.recordcount>
				<cfquery name="qUpdateIsLoggin" datasource="#Application.dsn#" result="a">
					delete from userCountCheck
					where 	cutomerId = <cfqueryparam cfsqltype="cf_sql_varchar" value="#Session.empid#">
					AND useruniqueid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#Session.useruniqueid#">
				</cfquery>
			</cfif>
			<!---Query to delete UserBrowserTabDetails with corresponding employeeid--->
			<cfquery name="qUpdateIsLoggin" datasource="#Application.dsn#" result="a">
				delete from UserBrowserTabDetails
				where 	userid=	<cfqueryparam cfsqltype="cf_sql_varchar" value="#Session.empid#">
			</cfquery>
			<cfset listPos = ListFindNoCase(Application.userLoggedInCount, Session.empid)>
			<cfif listPos>
				<cfset Application.userLoggedInCount = ListDeleteAt(Application.userLoggedInCount, listPos)>
				<cfset structDelete(cookie, "userLogginID") />
			</cfif>
		</cfif>
		<!--- set your session var like normal --->
		<cfif structkeyexists(Session,"customerid") and len(trim(Session.customerid))>
			<cfquery name="qGetUserLoggedInCount" datasource="#Application.dsn#">
				select cutomerId,currenttime
				from userCountCheck
				where cutomerId = <cfqueryparam cfsqltype="cf_sql_varchar" value="#Session.customerid#">
			</cfquery>
			<cfif qGetUserLoggedInCount.recordcount>
				<cfquery name="qUpdateIsLoggin" datasource="#Application.dsn#">
					delete from userCountCheck
					where 	cutomerId = <cfqueryparam cfsqltype="cf_sql_varchar" value="#Session.customerid#">
				</cfquery>
			</cfif>
			<cfset listPos = ListFindNoCase(Application.userLoggedInCount, Session.customerid)>

			<cfif listPos>
				<cfset Application.userLoggedInCount = ListDeleteAt(Application.userLoggedInCount, listPos)>
				<cfset structDelete(cookie, "userLogginID") />
			</cfif>
		</cfif>
		<cfif StructKeyExists(session,"UserAssignedLoadStatus")>
			<cfset structDelete(session, "UserAssignedLoadStatus") />
		</cfif>
		<cfset logoutvar = logoutuser()>
		<cfset structDelete(session, "passport") />
		<cfset session.searchtext="" />
		<cfif StructKeyExists(session,"CompanyID")>
			<cfset structDelete(session, "CompanyID") />
		</cfif>
		<cfif StructKeyExists(session,"dashboardUser")>
			<cfset structDelete(session, "dashboardUser") />
		</cfif>
		<cfif StructKeyExists(session,"showLicenseTerms")>
			<cfset structDelete(session, "showLicenseTerms") />
		</cfif>
		<cfif StructKeyExists(session,"CustomerID") AND session.CustomerID NEQ "">
			<cfset structDelete(session, "CustomerID") />
			<cfset structDelete(session, "iscustomer") />
			<cflocation url="index.cfm?event=customerlogin&AlertMessageID=3" addtoken="yes" />
		<cfelse>
			<cflocation url="index.cfm?event=login&AlertMessageID=3" addtoken="yes" />
		</cfif>
	</cfcase>
	<cfcase value="DashboardDefault">
		<cfset request.tabs = includeTemplate("views/general/tabs.cfm", true) />
		<cfset request.content = includeTemplate("views/pages/load/disp_load.cfm", true) />
		<cfset includeTemplate("views/templates/maintemplate.cfm") />
	</cfcase>
	<!--- Site Users --->
	<cfcase value="SecurityMainPage">
		<cfset request.lstTabs = "">
		<cfif CheckObjectAccess('subNavSiteUserManagement')>
			<cfset request.lstTabs = ListAppend(request.lstTabs, "Site Users,index.cfm?event=SecurityMaintenance&#Session.URLToken#") />
		</cfif>
		<cfif checkObjectAccess('lnkGroupAccess')>
			<cfset request.lstTabs = ListAppend(request.lstTabs, "|Groups,index.cfm?event=GroupMaintenance&#Session.URLToken#") />
		</cfif>
		<cfset request.tabs = includeTemplate("views/general/tabs.cfm", true) />
		<cfset request.subnavigation = includeTemplate("views/admin/adminsubnav.cfm", true) />
		<cfset includeTemplate("views/templates/maintemplate.cfm") />
	</cfcase>
	<cfcase value="SecurityMaintenance">
		<cfset request.structGroups = getGroupList() />
		<cfset request.SubHeading = "Search Site Users">
		<cfset request.initialFunctions = includeTemplate("views/admin/security/siteusers/initialfunctions.cfm", true) />
		<cfset request.content = includeTemplate("views/admin/security/securitymaintenance.cfm", true) />
		<cfif IsDefined("URL.blnIFrame") And URL.blnIFrame>
			<cfset includeTemplate("views/templates/maintemplate.cfm") />
		<cfelse>
			<cfset includeTemplate("views/templates/iframetemplate.cfm") />
		</cfif>
	</cfcase>
	<cfcase value="ajax_GetSearchSiteUserForm">
		<cfsetting showdebugoutput="no" />
		<cfset includeTemplate("views/admin/security/siteusers/searchsiteuserform.cfm") />
	</cfcase>
	<cfcase value="ajax_GetSiteUserList">
		<cfsetting showdebugoutput="no" />
		<cfset request.structSiteUsers = getSiteUserList() />

		<cfif Not (isdefined('URL.blnAllRecords') And URL.blnAllRecords)>
			<cfinvoke method="getRecordPages" returnvariable="request.structPageNumbers">
				<cfif isdefined('FORM.intPageNumber')>
					<cfinvokeargument name="intCurrentPageNumber" value="#FORM.intPageNumber#">
				</cfif>
				<cfinvokeargument name="intResultsPerPage" value="#Application.ResultsPerPage#">
				<cfinvokeargument name="intTotalRecords" value="#request.structSiteUsers.rstEnumTotalCount.iCount#">
				<cfinvokeargument name="strEvent" value="#request.event#">
			</cfinvoke>
		</cfif>
		<cfinvoke method="getListPageTableHeaders" returnvariable="request.structTableHeader">
			<cfinvokeargument name="lstHeaderNames" value="FirstName|sFirstName|left,Last Name|sLastName|left,Mobile Number|sMobileNumber|left,EmailAddress|sEmailAddress|left,Enabled?|bEnabled|center,&nbsp;,&nbsp;,&nbsp;,&nbsp;">
			<cfinvokeargument name="strEvent" value="#request.event#">
			<cfinvokeargument name="FilterVariableName" value="strOrderBy">
		</cfinvoke>

		<cfset includeTemplate("views/admin/security/siteusers/listsiteusers.cfm") />
	</cfcase>
	<cfcase value="ajax_ViewSiteUser">
		<cfsetting showdebugoutput="no" />
		<cfset request.SubHeading = "View Site User">
		<cfset request.siteUserBean = fetchCurrentSiteUser(intSiteUserID=URL.intSiteUserID) />
		<cfset request.content = includeTemplate("views/admin/security/siteusers/viewsiteuser.cfm", true) />
		<cfset includeTemplate("views/templates/iframetemplate.cfm") />
	</cfcase>
	<cfcase value="ajax_GetAddEditSiteUserForm">
		<cfsetting showdebugoutput="no" />

		<cfif IsDefined("URL.intSiteUserID")>
			<cfset request.siteUserBean = fetchCurrentSiteUser(intSiteUserID=URL.intSiteUserID) />
		<cfelse>
			<cfset request.siteUserBean = CreateObject('component', 'beans.siteuserbean') />
			<cfset request.siteUserBean.setCreatedSiteUser(CreateObject('component', 'beans.siteuserbean')) />
			<cfset request.siteUserBean.setUpdatedSiteUser(CreateObject('component', 'beans.siteuserbean')) />
			<cfset request.siteUserBean.setDeletedSiteUser(CreateObject('component', 'beans.siteuserbean')) />
		</cfif>
		<cfif IsDefined("URL.intSiteUserID")>
			<cfset request.SubHeading = "Edit Site User" />
		<cfelse>
			<cfset request.SubHeading = "Add  Site User" />
		</cfif>
		<cfset request.content = includeTemplate("views/admin/security/siteusers/addeditsiteuser.cfm", true) />
		<cfset includeTemplate("views/templates/iframetemplate.cfm") />
	</cfcase>
	<cfcase value="ajax_SaveSiteUser">
		<cfset request.siteUserBean = GetBean("beans.siteuserbean") />
		<cfsetting showdebugoutput="no" />
		<cfif FORM.hdnSiteUserID GT 0>
			<cfinvoke component="#variables.objSecurityGateway#" method="updateSiteUser" returnvariable="request.intSiteUserID">
				<cfinvokeargument name="intSiteUserID" value="#request.siteUserBean.getSiteUserID()#" />
				<cfinvokeargument name="strFirstName" value="#request.siteUserBean.getFirstName()#" />
				<cfinvokeargument name="strLastName" value="#request.siteUserBean.getLastName()#" />
				<cfinvokeargument name="strUsername" value="#request.siteUserBean.getUsername()#" />
				<cfinvokeargument name="strEmailAddress" value="#request.siteUserBean.getEmailAddress()#" />
				<cfinvokeargument name="strMobileNumber" value="#request.siteUserBean.getMobileNumber()#" />
				<cfinvokeargument name="blnEnabled" value="#request.siteUserBean.getEnabled()#" />
				<cfif LEN(request.siteUserBean.getPassword()) GT 0>
					<cfinvokeargument name="strPassword" value="#request.siteUserBean.getPassword()#" />
				</cfif>
				<cfinvokeargument name="intUpdatedSiteUserID" value="#Session.passport.currentSiteUser.getSiteUserID()#" />
			</cfinvoke>
		<cfelse>
			<cfinvoke component="#variables.objSecurityGateway#" method="addSiteUser" returnvariable="request.intSiteUserID">
				<cfinvokeargument name="strFirstName" value="#request.siteUserBean.getFirstName()#" />
				<cfinvokeargument name="strLastName" value="#request.siteUserBean.getLastName()#" />
				<cfinvokeargument name="strUsername" value="#request.siteUserBean.getUsername()#" />
				<cfinvokeargument name="strEmailAddress" value="#request.siteUserBean.getEmailAddress()#" />
				<cfinvokeargument name="strMobileNumber" value="#request.siteUserBean.getMobileNumber()#" />
				<cfinvokeargument name="blnEnabled" value="#request.siteUserBean.getEnabled()#" />
				<cfinvokeargument name="strPassword" value="#request.siteUserBean.getPassword()#" />
				<cfinvokeargument name="intCreatedSiteUserID" value="#Session.passport.currentSiteUser.getSiteUserID()#" />
			</cfinvoke>
		</cfif>

		<cfif IsDefined("FORM.chkResetOnNextLogin") And FORM.chkResetOnNextLogin>
			<cfinvoke component="#variables.objSecurityGateway#" method="expirePassword">
				<cfinvokeargument name="intSiteUserID" value="#request.intSiteUserID#" />
			</cfinvoke>
		</cfif>

		<cfif IsDefined("URL.strCriteria")>
			<cfset strExtraParams = "strCriteria=#URL.strCriteria#" />
		<cfelse>
			<cfset strExtraParams = "" />
		</cfif>
	</cfcase>
	<cfcase value="ajax_DeleteSiteUser">
		<cfsetting showdebugoutput="no" />
		<cfinvoke component="#variables.objSecurityGateway#" method="deleteSiteUser">
			<cfinvokeargument name="intSiteUserID" value="#URL.intSiteUserID#" />
			<cfinvokeargument name="intDeletedSiteUserID" value="#Session.passport.currentSiteUser.getSiteUserID()#" />
		</cfinvoke>
		<cfif IsDefined("URL.strCriteria")>
			<cfset strExtraParams = "strCriteria=#URL.strCriteria#" />
		<cfelse>
			<cfset strExtraParams = "" />
		</cfif>
		<cflocation url="index.cfm?event=ajax_GetSiteUserList&#strExtraParams#" addtoken="yes" />
	</cfcase>

	<cfcase value="popup_SearchSiteUsers">
		<cfset request.content = includeTemplate("views/admin/security/siteusers/searchsiteuserform.cfm", true) />
		<cfset includeTemplate("views/templates/iframetemplate.cfm") />
	</cfcase>

	<cfcase value="popup_SearchSiteUsers:Results">
		<cfset request.structSiteUsers = getSiteUserList() />

		<cfif Not (isdefined('URL.blnAllRecords') And URL.blnAllRecords)>
			<cfinvoke method="getRecordPages" returnvariable="request.structPageNumbers">
				<cfif isdefined('URL.intPageNumber')>
					<cfinvokeargument name="intCurrentPageNumber" value="#URL.intPageNumber#">
				<cfelseif isdefined('FORM.intPageNumber')>
					<cfinvokeargument name="intCurrentPageNumber" value="#FORM.intPageNumber#">
				</cfif>
				<cfinvokeargument name="intResultsPerPage" value="#Application.ResultsPerPage#">
				<cfinvokeargument name="intTotalRecords" value="#request.structSiteUsers.rstEnumTotalCount.iCount#">
				<cfinvokeargument name="strEvent" value="#request.event#">
			</cfinvoke>
		</cfif>
		<cfinvoke method="getListPageTableHeaders" returnvariable="request.structTableHeader">
			<cfinvokeargument name="lstHeaderNames" value="First Name|sFirstName|left,Last Name|sLastName|left,Mobile Number|sMobileNumber|left,Email Address|sEmailAddress|left,&nbsp;,&nbsp;,&nbsp;,&nbsp;">
			<cfinvokeargument name="strEvent" value="#request.event#">
			<cfinvokeargument name="FilterVariableName" value="strOrderBy">
		</cfinvoke>

		<cfset request.content = includeTemplate("views/admin/security/siteusers/listsiteusers.cfm", true) />
		<cfset includeTemplate("views/templates/iframetemplate.cfm") />
	</cfcase>

	<!--- GROUPS --->
	<cfcase value="GroupMaintenance">
		<cfset request.SubHeading = "Search User Groups">
		<cfset request.initialFunctions = includeTemplate("views/admin/security/groups/initialfunctions.cfm", true) />
		<cfset request.content = includeTemplate("views/admin/security/securitymaintenance.cfm", true) />
		<cfif IsDefined("URL.blnIFrame") And URL.blnIFrame>
			<cfset includeTemplate("views/templates/maintemplate.cfm") />
		<cfelse>
			<cfset includeTemplate("views/templates/iframetemplate.cfm") />
		</cfif>
	</cfcase>

	<cfcase value="ajax_GetSearchGroupForm">
		<cfsetting showdebugoutput="no" />
		<cfset includeTemplate("views/admin/security/groups/searchgroupform.cfm") />
	</cfcase>

	<cfcase value="ajax_GetGroupSelecter">
		<cfsetting showdebugoutput="no" />
		<cfparam name="URL.intParentGroupID" type="integer" default="-1" />
		<cfset request.structGroups = variables.objSecurityGateway.enumGroups(blnAllRecords=True,intParentGroupID=URL.intParentGroupID) />
		<cfset includeTemplate("views/admin/groups/groupselecter.cfm") />
	</cfcase>

	<cfcase value="ajax_GetGroupList">
		<cfsetting showdebugoutput="no" />
		<cfset request.SubHeading = "List Groups">
		<cfset request.structGroups = getGroupList() />

		<cfif Not (isdefined('URL.blnAllRecords') And URL.blnAllRecords)>
			<cfinvoke method="getRecordPages" returnvariable="request.structPageNumbers">
				<cfif isdefined('FORM.intPageNumber')>
					<cfinvokeargument name="intCurrentPageNumber" value="#FORM.intPageNumber#">
				</cfif>
				<cfinvokeargument name="intResultsPerPage" value="#Application.ResultsPerPage#">
				<cfinvokeargument name="intTotalRecords" value="#request.structGroups.rstEnumTotalCount.iCount#">
				<cfinvokeargument name="strEvent" value="#request.event#">
			</cfinvoke>
		</cfif>
		<cfinvoke method="getListPageTableHeaders" returnvariable="request.structTableHeader">
			<cfinvokeargument name="lstHeaderNames" value="Group|sGroup|left,&nbsp;,&nbsp;,&nbsp;,&nbsp;,&nbsp;,&nbsp;">
			<cfinvokeargument name="strEvent" value="#request.event#">
			<cfinvokeargument name="FilterVariableName" value="strOrderBy">
		</cfinvoke>

		<cfset includeTemplate("views/admin/security/groups/listgroups.cfm") />
	</cfcase>

	<cfcase value="ajax_GetAddEditGroupForm">
		<cfsetting showdebugoutput="no" />
		<cfif IsDefined("URL.intGroupID")>
			<cfset request.groupBean = fetchGroupAsBean(intGroupID=URL.intGroupID) />
		<cfelse>
			<cfset request.groupBean = CreateObject('component', 'beans.groupbean') />
		</cfif>
		<cfif IsDefined("URL.intGroupID")>
			<cfset request.SubHeading = "Edit Group" />
		<cfelse>
			<cfset request.SubHeading = "Add Group" />
		</cfif>
		<cfset includeTemplate("views/templates/iframetemplate.cfm") />
		<cfset includeTemplate("views/admin/security/groups/addeditgroup.cfm") />
	</cfcase>

	<cfcase value="ajax_SaveGroup">
		<!--- Prepare Group Bean --->
		<cfset request.groupBean = GetBean("beans.groupbean") />
		<!--- Determine Add or Edit --->
		<cfif FORM.hdnGroupID GT 0>
			<cfset strMethod = "updateGroup" />
			<cfset strSiteUserArgumentName = "intUpdatedSiteUserID" />
		<cfelse>
			<cfset strMethod = "addGroup" />
			<cfset strSiteUserArgumentName = "intCreatedSiteUserID" />
		</cfif>
		<!--- Invoke Add / Update Function --->
		<cfinvoke component="#variables.objSecurityGateway#" method="#strMethod#">
			<cfif FORM.hdnGroupID GT 0>
				<cfinvokeargument name="intGroupID" value="#FORM.hdnGroupID#" />
			</cfif>
			<cfinvokeargument name="strGroup" value="#FORM.txtGroup#" />
			<cfinvokeargument name="blnAllowEdit" value="#FORM.cboAllowEdit#" />
			<cfinvokeargument name="blnAllowDelete" value="#FORM.cboAllowDelete#" />
			<cfinvokeargument name="#strSiteUserArgumentName#" value="#Session.passport.currentSiteUser.getSiteUserID()#" />
		</cfinvoke>

		<!--- Get the list of Groups --->
	</cfcase>

	<cfcase value="ajax_ViewGroup">
		<cfsetting showdebugoutput="no" />
		<cfset request.groupBean = fetchGroupAsBean(intGroupID=URL.intGroupID) />
		<cfset request.SubHeading = "View Group" />
		<cfset includeTemplate("views/templates/iframetemplate.cfm") />
		<cfset includeTemplate("views/admin/security/groups/viewgroup.cfm") />
	</cfcase>

	<cfcase value="ajax_DeleteGroup">
		<cfsetting showdebugoutput="no" />
		<cfinvoke component="#variables.objSecurityGateway#" method="deleteGroup">
			<cfinvokeargument name="intGroupID" value="#URL.intGroupID#" />
			<cfinvokeargument name="intDeletedSiteUserID" value="#Session.passport.currentSiteUser.getSiteUserID()#" />
		</cfinvoke>
		<!--- Get the list of Groups --->
		<cflocation url="index.cfm?event=ajax_GetGroupList" addtoken="yes" />
	</cfcase>

	<cfcase value="popup_SearchGroups">
		<cfset request.content = includeTemplate("views/admin/groups/searchgroupform.cfm", true) />
		<cfset includeTemplate("views/templates/iframetemplate.cfm") />
	</cfcase>

	<cfcase value="popup_SearchGroups:Results">
		<cfset request.structGroups = getGroupList() />

		<cfif Not (isdefined('URL.blnAllRecords') And URL.blnAllRecords)>
			<cfinvoke method="getRecordPages" returnvariable="request.structPageNumbers">
				<cfif isdefined('FORM.intPageNumber')>
					<cfinvokeargument name="intCurrentPageNumber" value="#FORM.intPageNumber#">
				</cfif>
				<cfinvokeargument name="intResultsPerPage" value="#Application.ResultsPerPage#">
				<cfinvokeargument name="intTotalRecords" value="#request.structGroups.rstEnumTotalCount.iCount#">
				<cfinvokeargument name="strEvent" value="#request.event#">
			</cfinvoke>
		</cfif>
		<cfinvoke method="getListPageTableHeaders" returnvariable="request.structTableHeader">
			<cfinvokeargument name="lstHeaderNames" value="&nbsp;,Group|sGroup|left,Code|sGroupCode|left,Telephone Number|sTelephoneNumber|left,Email Address|sEmailAddress|left,&nbsp;,&nbsp;,&nbsp;,&nbsp;">
			<cfinvokeargument name="strEvent" value="#request.event#">
			<cfinvokeargument name="FilterVariableName" value="strOrderBy">
		</cfinvoke>

		<cfset request.content = includeTemplate("views/admin/groups/listgroups.cfm", true) />
		<cfset includeTemplate("views/templates/iframetemplate.cfm") />
	</cfcase>

	<cfcase value="ajax_AddSiteUserToGroup">
		<cfsetting showdebugoutput="no">
		<cfinvoke component="#variables.objSecurityGateway#" method="AddSiteUserToGroup">
				<cfinvokeargument name="SiteUserID" value="#URL.intSiteUserID#" />
				<cfinvokeargument name="intGroupID" value="#URL.intGroupID#"/>
		</cfinvoke>
		<cfinvoke component="#variables.objSecurityGateway#" method="GetGroupSiteUsers" returnvariable="request.structReturn">
			<cfinvokeargument name="GroupID" value="#URL.intGroupID#">
			<cfif IsDefined("FORM.strOrderBy")>
				<cfinvokeargument name="strOrderBy" value="#FORM.strOrderBy#" />
			</cfif>
			<cfif IsDefined("URL.blnAllRecords")>
				<cfinvokeargument name="blnAllRecords" value="#URL.blnAllRecords#" />
			</cfif>
			<cfif IsDefined("FORM.intPageNumber")>
				<cfinvokeargument name="intPageNumber" value="#FORM.intPageNumber#" />
			</cfif>
			<cfinvokeargument name="intResultsPerPage" value="#Application.ResultsPerPage#" />
		</cfinvoke>
		<cfinvoke method="getRecordPages" returnvariable="request.structPageNumbers">
			<cfif isdefined('FORM.intPageNumber')>
				<cfinvokeargument name="intCurrentPageNumber" value="#FORM.intPageNumber#">
			</cfif>
			<cfinvokeargument name="intResultsPerPage" value="#Application.ResultsPerPage#">
			<cfinvokeargument name="intTotalRecords" value="#request.structReturn.rstGetGroupSiteUsersTotalCount.iCount#">
			<cfinvokeargument name="strEvent" value="#request.event#">
			<cfinvokeargument name="strExtraURLParams" value="">
		</cfinvoke>

		<cfinvoke method="getListPageTableHeaders" returnvariable="request.structTableHeader">
			<cfinvokeargument name="lstHeaderNames" value="FirstName|sFirstName|left,LastName|sLastName|left,Mobile Number|sMobileNumber|left,Email Address|sEmailAddress|left,&nbsp;,&nbsp;,&nbsp;,&nbsp;">
			<cfinvokeargument name="strEvent" value="#request.event#">
			<cfinvokeargument name="FilterVariableName" value="strOrderBy">
		</cfinvoke>

		<cfset request.content = includeTemplate("views/admin/security/groups/listgroupSiteUsers.cfm", true) />
		<cfset includeTemplate("views/templates/iframetemplate.cfm") />
	</cfcase>

	<cfcase value="ajax_GetGroupSiteUsers">
		<cfsetting showdebugoutput="no">
		<cfset request.SubHeading = "List Group SiteUsers">
		<cfinvoke component="#variables.objSecurityGateway#" method="GetGroupSiteUsers" returnvariable="request.structReturn">
			<cfinvokeargument name="GroupID" value="#URL.intGroupID#">
			<cfif IsDefined("FORM.strOrderBy")>
				<cfinvokeargument name="strOrderBy" value="#FORM.strOrderBy#" />
			</cfif>
			<cfif IsDefined("URL.blnAllRecords")>
				<cfinvokeargument name="blnAllRecords" value="#URL.blnAllRecords#" />
			</cfif>
			<cfif IsDefined("FORM.intPageNumber")>
				<cfinvokeargument name="intPageNumber" value="#FORM.intPageNumber#" />
			</cfif>
			<cfinvokeargument name="intResultsPerPage" value="#Application.ResultsPerPage#" />
		</cfinvoke>

		<cfinvoke method="getRecordPages" returnvariable="request.structPageNumbers">
			<cfif isdefined('FORM.intPageNumber')>
				<cfinvokeargument name="intCurrentPageNumber" value="#FORM.intPageNumber#">
			</cfif>
			<cfinvokeargument name="intResultsPerPage" value="#Application.ResultsPerPage#">
			<cfinvokeargument name="intTotalRecords" value="#request.structReturn.rstGetGroupSiteUsersTotalCount.iCount#">
			<cfinvokeargument name="strEvent" value="#request.event#">
			<cfinvokeargument name="strExtraURLParams" value="">
		</cfinvoke>

		<cfinvoke method="getListPageTableHeaders" returnvariable="request.structTableHeader">
			<cfinvokeargument name="lstHeaderNames" value="FirstName|sFirstName|left,LastName|sLastName|left,Mobile Number|sMobileNumber|left,Email Address|sEmailAddress|left,&nbsp;,&nbsp;,&nbsp;,&nbsp;">
			<cfinvokeargument name="strEvent" value="#request.event#">
			<cfinvokeargument name="FilterVariableName" value="strOrderBy">
		</cfinvoke>
		<cfset request.content = includeTemplate("views/admin/security/groups/listgroupSiteUsers.cfm", true) />
		<cfset includeTemplate("views/templates/iframetemplate.cfm") />
	</cfcase>

	<cfcase value="ajax_SearchPrivileges">
		<cfsetting showdebugoutput="no">
		<cfif IsDefined("URL.intGroupID")>
			<cfset request.rstCurrentPrivileges = fetchGroupPrivilegeList(intGroupID=URL.intGroupID)>
		</cfif>
		<cfif IsDefined("URL.intSiteUserID")>
			<cfset request.rstCurrentPrivileges = fetchSiteUserPrivilegeList(intSiteUserID=URL.intSiteUserID)>
		</cfif>
		<cfset request.SubHeading = "Add Privileges to Group">
		<cfset rstPrivilegeSearchResults = fetchAllPrivilegeList()>
		<cfset request.content = includeTemplate("views/admin/security/privileges/listPrivileges.cfm", true) />
		<cfset includeTemplate("views/templates/iframetemplate.cfm") />
	</cfcase>

	<cfcase value="ajax_AddSiteUserPrivileges">
		<cfsetting showdebugoutput="no">
		<cfif IsDefined("URL.intGroupID")>
			<cfset request.rstCurrentPrivileges = fetchGroupPrivilegeList(intGroupID=URL.intGroupID)>
		</cfif>
		<cfif IsDefined("URL.intSiteUserID")>
			<cfset request.rstCurrentPrivileges = fetchSiteUserPrivilegeList(intSiteUserID=URL.intSiteUserID)>
		</cfif>
		<cfset request.SubHeading = "Add Privileges to Site User">
		<cfset rstPrivilegeSearchResults = fetchAllPrivilegeList()>
		<cfset request.content = includeTemplate("views/admin/security/privileges/listPrivileges.cfm", true) />
		<cfset includeTemplate("views/templates/iframetemplate.cfm") />
	</cfcase>

	<cfcase value="ajax_ListGroupPrivileges">
		<cfsetting showdebugoutput="no">
		<cfset request.SubHeading = "Privileges for Group">
		<cfset rstGroupPrivileges= fetchGroupPrivilegeList(intGroupID=#URL.intGroupID#)>
		<cfset request.content = includeTemplate("views/admin/security/groups/listGroupPrivileges.cfm", true) />
		<cfset includeTemplate("views/templates/iframetemplate.cfm") />
	</cfcase>

	<cfcase value="SavePrivilegesToGroup">
		<cftransaction action="begin">
			<cfinvoke component="#variables.objSecurityGateway#" method="AddPrivilegeToGroup">
				<cfinvokeargument name="GroupID" value="#URL.GroupID#">
				<cfinvokeargument name="lstPrivilegeIDs" value="#Form.PrivilegeID#">
			</cfinvoke>
			<cftransaction action="commit" />
		</cftransaction>
	</cfcase>

	<cfcase value="SavePrivilegesToSiteUser">
		<cfsetting showdebugoutput="no">
		<cfinvoke component="#variables.objSecurityGateway#" method="AddPrivilegeToSiteUser">
			<cfinvokeargument name="SiteUserID" value="#URL.SiteUserID#">
			<cfinvokeargument name="lstPrivilegeIDs" value="#Form.PrivilegeID#">
		</cfinvoke>
	</cfcase>

	<cfcase value="ajax_ListSiteUserPrivileges">
		<cfsetting showdebugoutput="no">
		<cfset request.SubHeading = "Privileges for SiteUser">
		<cfset rstSiteUserPrivileges= fetchSiteUserPrivilegeList(intSiteUserID=#URL.intSiteUserID#)>
		<cfset request.content = includeTemplate("views/admin/security/SiteUsers/listSiteUserPrivileges.cfm", true) />
		<cfset includeTemplate("views/templates/iframetemplate.cfm") />
	</cfcase>

	<cfcase value="ajax_DeleteSiteUserFromGroup">
		<cfsetting showdebugoutput="no">
		<cfinvoke component="#variables.objSecurityGateway#" method="removeSiteUserFromGroup">
			<cfinvokeargument name="GroupID" value="#url.intGroupID#">
			<cfinvokeargument name="SiteUserID" value="#url.intSiteUserID#">
		</cfinvoke>
	</cfcase>

	<cfcase value="ajax_RemovePrivilegeFromGroup">
		<cfsetting showdebugoutput="no">
		<cfinvoke component="#variables.objSecurityGateway#" method="RemovePrivilegeFromGroup">
			<cfinvokeargument name="GroupID" value="#url.intGroupID#">
			<cfinvokeargument name="PrivilegeID" value="#url.intPrivilegeID#">
		</cfinvoke>
	</cfcase>

	<cfcase value="ajax_RemovePrivilegeFromSiteUser">
		<cfsetting showdebugoutput="no">
		<cfinvoke component="#variables.objSecurityGateway#" method="RemovePrivilegeFromSiteUser">
			<cfinvokeargument name="SiteUserID" value="#url.intSiteUserID#">
			<cfinvokeargument name="PrivilegeID" value="#url.intPrivilegeID#">
		</cfinvoke>
	</cfcase>

	<cfcase value="systemsetup">
		<cfif StructKeyExists(session,"adminusername")>
			<cfinvoke component="#variables.objAgentGateway#" method="getAllCountries" returnvariable="request.qCountries" />
			<cfset request.subnavigation = includeTemplate("views/admin/sysSetupSubnav.cfm", true) />
			<cfset request.content = includeTemplate("webroot/systemSetup.cfm", true) />
			<cfset includeTemplate("views/templates/maintemplate.cfm") />
		</cfif>
	</cfcase>

	<cfcase value="companyinfo">
    	<cfset request.subnavigation = includeTemplate("views/admin/sysSetupSubnav.cfm", true) />
    	<cfset request.content = includeTemplate("webroot/companyinfo.cfm", true) />
        <cfset includeTemplate("views/templates/maintemplate.cfm") />
	</cfcase>	

	<cfcase value="OnboardingLink:process">
    	<cfinvoke component="#variables.objCarrierGateway#" method="GetCarrierOnBoardLink" CompanyID="#url.CompanyID#" returnvariable="request.OnBoardLink">
		   	<cfinvokeargument name="DOTNumber" value="#form.DOTNumber#">
		   	<cfinvokeargument name="MCNumber" value="#form.MCNumber#">
		</cfinvoke>

		<cfif len(trim(request.OnBoardLink.CarrierID))>
			<cflocation url="https://#cgi.HTTP_HOST#/#trim(listFirst(cgi.SCRIPT_NAME,'/'))#/www/webroot/CarrierOnBoard/index.cfm?event=CarrierInformation&CarrierID=#request.OnBoardLink.CarrierID#&CarrierOnBoardStatus=#request.OnBoardLink.OnBoardStatus#" />
		<cfelse>
			<cflocation url="https://#cgi.HTTP_HOST#/#trim(listFirst(cgi.SCRIPT_NAME,'/'))#/www/webroot/CarrierOnBoard/index.cfm?event=CarrierInformation&CompanyID=#url.CompanyID#&DOTNumber=#form.DOTNumber#&MCNumber=#form.MCNumber#" />
		</cfif>
	</cfcase>	

	<cfcase value="loadstatussetup">
    	<cfset request.subnavigation = includeTemplate("views/admin/sysSetupSubnav.cfm", true) />
    	<cfset request.content = includeTemplate("webroot/loadStatusSetup.cfm", true) />
        <cfset includeTemplate("views/templates/maintemplate.cfm") />
	</cfcase>
	
	<cfcase value="AgingReports">
    	<cfset request.subnavigation = includeTemplate("views/admin/reportsSubNav.cfm", true) />
    	<cfset request.content = includeTemplate("webroot/agingReports.cfm", true) />
        <cfset includeTemplate("views/templates/maintemplate.cfm") />
	</cfcase>
	
	<cfcase value="CarrierQuoteReport">
    	<cfset request.subnavigation = includeTemplate("views/admin/reportsSubNav.cfm", true) />
    	<cfset request.content = includeTemplate("webroot/carrierQuoteReport.cfm", true) />
        <cfset includeTemplate("views/templates/maintemplate.cfm") />
	</cfcase>

	<cfcase value="Form1099">
    	<cfset request.subnavigation = includeTemplate("views/admin/reportsSubNav.cfm", true) />
    	<cfset request.content = includeTemplate("webroot/Form1099.cfm", true) />
        <cfset includeTemplate("views/templates/maintemplate.cfm") />
	</cfcase>
	
	 <cfcase value="saferWatchCarrierUpdate">    	
        <cfset includeTemplate("views/pages/load/saferWatchCarrierUpdate.cfm") />
	</cfcase>

	<!--- BEGIN: 766: Feature Request- Excel Export Feature --->
	<cfcase value="ExportExcel">
    	<cfset request.subnavigation = includeTemplate("views/admin/reportsSubNav.cfm", true) />
    	<cfset request.content = includeTemplate("webroot/exportExcel.cfm", true) />
        <cfset includeTemplate("views/templates/maintemplate.cfm") />
	</cfcase>
	<cfcase value="ExportExcel:customers">
		<cfinvoke component="#variables.objSecurityGateway#" method="exportCustomersExcel">
		</cfinvoke>
	</cfcase>
	<cfcase value="ExportExcel:carriersDrivers">
		<cfinvoke component="#variables.objSecurityGateway#" method="exportCarriersDriversExcel">
		</cfinvoke>
	</cfcase>
	<cfcase value="ExportExcel:salesSummary">
		<cfif structIsEmpty(form)>
			<cflocation url="index.cfm?event=ExportExcel&#session.URLToken#" />
		</cfif>
		<cfinvoke component="#variables.objSecurityGateway#" method="exportSalesSummaryExcel">
			<cfif structKeyExists(form, "summaryDateFrom")>
				<cfinvokeargument name="dateFrom" value="#URLDecode(FORM.summaryDateFrom)#" />
			<cfelse>
				<cfinvokeargument name="dateFrom" value="" />
			</cfif>
			<cfif structKeyExists(form, "summaryDateTo")>
				<cfinvokeargument name="dateTo" value="#URLDecode(FORM.summaryDateTo)#" />
			<cfelse>
				<cfinvokeargument name="dateTo" value="" />
			</cfif>
			<cfinvokeargument name="statusFrom" value="#FORM.summaryStatusFrom#" />
			<cfinvokeargument name="statusTo" value="#FORM.summaryStatusTo#" />
			<cfif structKeyExists(form, "summaryInvoiceDateFrom")>
				<cfinvokeargument name="invoiceDateFrom" value="#FORM.summaryInvoiceDateFrom#" />
			<cfelse>
				<cfinvokeargument name="invoiceDateFrom" value="" />
			</cfif>
			<cfif structKeyExists(form, "summaryInvoiceDateTo")>
				<cfinvokeargument name="invoiceDateTo" value="#FORM.summaryInvoiceDateTo#" />
			<cfelse>
				<cfinvokeargument name="invoiceDateTo" value="" />
			</cfif>
			<cfinvokeargument name="pickupDateFrom" value="#FORM.summaryPickupDateFrom#" />
			<cfinvokeargument name="pickupDateTo" value="#FORM.summaryPickupDateTo#" />
			<cfif structKeyExists(form, "summarydeliveryDateFrom")>
				<cfinvokeargument name="deliveryDateFrom" value="#URLDecode(FORM.summarydeliveryDateFrom)#" />
			<cfelse>
				<cfinvokeargument name="deliveryDateFrom" value="" />
			</cfif>
			<cfif structKeyExists(form, "summarydeliveryDateTo")>
				<cfinvokeargument name="deliveryDateTo" value="#URLDecode(FORM.summarydeliveryDateTo)#" />
			<cfelse>
				<cfinvokeargument name="deliveryDateTo" value="" />
			</cfif>
			<cfinvokeargument name="poFrom" value="#FORM.summaryPOFrom#" />
			<cfinvokeargument name="poTo" value="#FORM.summaryPOTo#" />
			<cfinvokeargument name="carrierFrom" value="#FORM.summaryCarrierFrom#" />
			<cfinvokeargument name="carrierTo" value="#FORM.summaryCarrierTo#" />
			<cfinvokeargument name="customerFrom" value="#FORM.summaryCustomerFrom#" />
			<cfinvokeargument name="customerTo" value="#FORM.summaryCustomerTo#" />
			<cfinvokeargument name="OfficeFrom" value="#FORM.summaryOfficeFrom#" />
			<cfinvokeargument name="OfficeTo" value="#FORM.summaryOfficeTo#" />
		</cfinvoke>
	</cfcase>
	<cfcase value="ExportExcel:salesDetail">
		<cfif structIsEmpty(form)>
			<cflocation url="index.cfm?event=ExportExcel&#session.URLToken#" />
		</cfif>
		<cfinvoke component="#variables.objSecurityGateway#" method="exportSalesDetailExcel">
			<cfif structKeyExists(form, "detailDateFrom")>
				<cfinvokeargument name="dateFrom" value="#URLDecode(FORM.detailDateFrom)#" />
			<cfelse>
				<cfinvokeargument name="dateFrom" value="" />
			</cfif>
			<cfif structKeyExists(form, "detailDateFrom")>
				<cfinvokeargument name="dateTo" value="#URLDecode(FORM.detailDateFrom)#" />
			<cfelse>
				<cfinvokeargument name="dateTo" value="" />
			</cfif>
			<cfinvokeargument name="statusFrom" value="#FORM.detailStatusFrom#" />
			<cfinvokeargument name="statusTo" value="#FORM.detailStatusTo#" />
			<cfinvokeargument name="invoiceDateFrom" value="#FORM.detailInvoiceDateFrom#" />
			<cfinvokeargument name="invoiceDateTo" value="#FORM.detailInvoiceDateTo#" />
			<cfinvokeargument name="pickupDateFrom" value="#FORM.detailPickupDateFrom#" />
			<cfinvokeargument name="pickupDateTo" value="#FORM.detailPickupDateTo#" />
			<cfif structKeyExists(form, "detailDeliveryDateFrom")>
				<cfinvokeargument name="deliveryDateFrom" value="#URLDecode(FORM.detailDeliveryDateFrom)#" />
			<cfelse>
				<cfinvokeargument name="deliveryDateFrom" value="" />
			</cfif>
			<cfif structKeyExists(form, "detailDeliveryDateTo")>
				<cfinvokeargument name="deliveryDateTo" value="#URLDecode(FORM.detailDeliveryDateTo)#" />
			<cfelse>
				<cfinvokeargument name="deliveryDateTo" value="" />
			</cfif>
			<cfinvokeargument name="poFrom" value="#FORM.detailPOFrom#" />
			<cfinvokeargument name="poTo" value="#FORM.detailPOTo#" />
			<cfinvokeargument name="carrierFrom" value="#FORM.detailCarrierFrom#" />
			<cfinvokeargument name="carrierTo" value="#FORM.detailCarrierTo#" />
			<cfinvokeargument name="customerFrom" value="#FORM.detailCustomerFrom#" />
			<cfinvokeargument name="customerTo" value="#FORM.detailCustomerTo#" />
			<cfinvokeargument name="OfficeFrom" value="#FORM.detailOfficeFrom#" />
			<cfinvokeargument name="OfficeTo" value="#FORM.detailOfficeTo#" />
		</cfinvoke>
	</cfcase>
	<cfcase value="crmNoteTypes">
    	<cfset request.subnavigation = includeTemplate("views/admin/sysSetupSubnav.cfm", true) />
    	<cfset request.content = includeTemplate("webroot/crmNoteTypes.cfm", true) />
        <cfset includeTemplate("views/templates/maintemplate.cfm") />
	</cfcase>	
	<cfcase value="addCRMNoteType">
		<cfset request.subnavigation = includeTemplate("views/admin/sysSetupSubnav.cfm", true) />
		<cfset request.content = includeTemplate("webroot/addCRMNoteType.cfm", true) />
		<cfset includeTemplate("views/templates/maintemplate.cfm") />
	</cfcase>
	<cfcase value="addCRMNoteType:process">
		<cfset formStruct = structNew()>
		<cfset formStruct = form>

		<cfif structkeyexists(form,"editid") and len(trim(form.editid)) gt 0>
			<cfinvoke component="#variables.objCustomerGateway#" method="updadeCRMNoteType" returnvariable="CRMNoteTypeID">
				<cfinvokeargument name="formStruct" value="#formStruct#">
			</cfinvoke>
			<cfset session.CRMNoteTypeMessage = 'CRM NoteType has been updated Successfully.'>
		<cfelse>
			<cfinvoke component="#variables.objCustomerGateway#" method="insertCRMNoteType" returnvariable="CRMNoteTypeID">
			   <cfinvokeargument name="formStruct" value="#formStruct#">
			</cfinvoke>
			<cfset session.CRMNoteTypeMessage  = 'CRM NoteType has been created Successfully.'>
		</cfif>	
		
		<cfif form.stayonpage>
			<cflocation url="index.cfm?event=addCRMNoteType&CRMNoteTypeID=#CRMNoteTypeID##session.URLToken#" />
		<cfelse>
			<cflocation url="index.cfm?event=crmNoteTypes&#session.URLToken#" />
		</cfif>
	</cfcase>
	<cfcase value="delCRMNoteType">
		<cfinvoke component="#variables.objCustomerGateway#" method="deleteCRMNoteType" CRMNoteTypeID="#url.CRMNoteTypeID#"  returnvariable="ID"/>
		<cfset session.CRMNoteTypeMessage  = 'CRM NoteType has been deleted Successfully.'>
		<cflocation url="index.cfm?event=crmNoteTypes&#session.URLToken#" />
	</cfcase>
	<cfcase value="attachmentTypes">
    	<cfset request.subnavigation = includeTemplate("views/admin/sysSetupSubnav.cfm", true) />
    	<cfset request.content = includeTemplate("views/pages/systemSetup/dsp_attachment_types.cfm", true) />
        <cfset includeTemplate("views/templates/maintemplate.cfm") />
	</cfcase>
	<cfcase value="addAttachmentType">			 
		<cfset request.subnavigation = includeTemplate("views/admin/sysSetupSubnav.cfm", true) />
		<cfset request.content = includeTemplate("views/pages/systemSetup/add_attachment_types.cfm", true) />
		<cfset includeTemplate("views/templates/maintemplate.cfm") />
	</cfcase>
	<!--- END: 766: Feature Request- Excel Export Feature --->
	<cfcase value="Export1099">
		<cfinvoke component="#variables.objSecurityGateway#" method="export1099csv">
			<cfinvokeargument name="year" value="#FORM.exportYear#" />
		</cfinvoke>
	</cfcase>
	<cfcase value="QuickBooksExport">
    	<cfset request.subnavigation = includeTemplate("views/admin/reportsSubNav.cfm", true) />
    	<cfset request.content = includeTemplate("webroot/QuickBooksExport.cfm", true) />
        <cfset includeTemplate("views/templates/maintemplate.cfm") />
	</cfcase>
	<cfcase value="QuickBooksExportAP">
    	<cfset request.subnavigation = includeTemplate("views/admin/reportsSubNav.cfm", true) />
    	<cfset request.content = includeTemplate("webroot/QuickBooksExportAP.cfm", true) />
        <cfset includeTemplate("views/templates/maintemplate.cfm") />
	</cfcase>
	<cfcase value="QuickBooksExportHistory">
    	<cfset request.subnavigation = includeTemplate("views/admin/reportsSubNav.cfm", true) />
    	<cfset request.content = includeTemplate("webroot/QuickBooksExportHistory.cfm", true) />
        <cfset includeTemplate("views/templates/maintemplate.cfm") />
	</cfcase>
	<cfcase value="QBNotExported">
    	<cfset request.subnavigation = includeTemplate("views/admin/reportsSubNav.cfm", true) />
    	<cfset request.content = includeTemplate("webroot/QBNotExported.cfm", true) />
        <cfset includeTemplate("views/templates/maintemplate.cfm") />
	</cfcase>
	<cfcase value="DashBoard">
    	<cfset request.subnavigation = includeTemplate("views/admin/reportsSubNav.cfm", true) />
    	<cfset request.content = includeTemplate("webroot/DashBoard.cfm", true) />
        <cfset includeTemplate("views/templates/maintemplate.cfm") />
	</cfcase>
	<cfcase value="CarrierReport">
		<cfinvoke component="#variables.objloadGateway#" method="getCarrierReport" LoadID = "#url.LoadID#" returnvariable="qCarrierReport" />
		<cfset customPath = "">
		<cfif len(trim(qCarrierReport.CompanyCode)) and directoryExists(expandPath("../reports/#trim(qCarrierReport.CompanyCode)#")) and fileExists(expandPath("../reports/#trim(qCarrierReport.CompanyCode)#/CarrierReport.cfm"))>
			<cfset customPath = "#trim(qCarrierReport.CompanyCode)#">
		</cfif>
        <cfset includeTemplate("reports/#customPath#/CarrierReport.cfm") />
        <cfcontent type="application/pdf" variable="#tobinary(CarrierReport)#">
	</cfcase>
	<cfcase value="CustomerInvoiceReport">
		<cfinvoke component="#variables.objloadGateway#" method="getCustomerReport" LoadID = "#url.LoadID#" returnvariable="qCustomerReport" />
		<cfset customPath = "">
		<cfif len(trim(qCustomerReport.CompanyCode)) and directoryExists(expandPath("../reports/#trim(qCustomerReport.CompanyCode)#")) and fileExists(expandPath("../reports/#trim(qCustomerReport.CompanyCode)#/CustomerInvoice.cfm"))>
			<cfset customPath = "#trim(qCustomerReport.CompanyCode)#">
		</cfif>
		<cfif qCustomerReport.recordcount>
            <cfset dueDate = "">
            <cfif len(trim(qCustomerReport.PaymentTerms)) AND qCustomerReport.ReportTitle EQ 'Invoice'>
                <cfset arrMatch = rematch("NET[\d]+",replace(qCustomerReport.PaymentTerms, " ", "","ALL"))>
                <cfif not arrayIsEmpty(arrMatch)>
                    <cfset dueDays = replaceNoCase(arrMatch[1], "NET", "")>
                    <cfset dueDate = dateAdd("d", dueDays, qCustomerReport.BillDate)>
                </cfif>
            </cfif>
        </cfif>
        <cfset includeTemplate("reports/#customPath#/CustomerInvoice.cfm") />
        <cfcontent type="application/pdf" variable="#tobinary(CustomerDocumentReport)#">
	</cfcase>
	<cfcase value="OnboardCarrierDocs">
    	<cfset request.subnavigation = includeTemplate("views/admin/sysSetupSubnav.cfm", true) />
    	<cfset request.content = includeTemplate("views/pages/systemSetup/OnboardCarrierDocs.cfm", true) />
        <cfset includeTemplate("views/templates/maintemplate.cfm") />
	</cfcase>
	<cfcase value="userRoles">
    	<cfset request.subnavigation = includeTemplate("views/admin/sysSetupSubnav.cfm", true) />
    	<cfset request.content = includeTemplate("views/pages/systemSetup/UserRoles.cfm", true) />
        <cfset includeTemplate("views/templates/maintemplate.cfm") />
	</cfcase>
	
	<cfcase value="LoadStatus">
    	<cfset request.subnavigation = includeTemplate("views/admin/sysSetupSubnav.cfm", true) />
    	<cfset request.content = includeTemplate("views/pages/systemSetup/LoadStatus.cfm", true) />
        <cfset includeTemplate("views/templates/maintemplate.cfm") />
	</cfcase>

	<cfcase value="AddOnboardingDoc">
    	<cfset request.subnavigation = includeTemplate("views/admin/sysSetupSubnav.cfm", true) />
		<cfset request.content = includeTemplate("views/pages/systemSetup/AddOnboardingDoc.cfm", true) />
		<cfset includeTemplate("views/templates/maintemplate.cfm") />
	</cfcase>

	<cfcase value="AddOnboardingDoc:Process">
	
		<cfif structkeyexists(form,"ID") and len(trim(form.ID)) gt 0>
			<cfinvoke component="#variables.objCarrierGateway#" method="UdpateOnboardingDoc" returnvariable="session.OnboardingDocSaveMessage">
			   <cfinvokeargument name="formStruct" value="#form#">
			</cfinvoke>
		<cfelse>
			<cfinvoke component="#variables.objCarrierGateway#" method="InsertOnboardingDoc" returnvariable="session.OnboardingDocSaveMessage">
			   <cfinvokeargument name="formStruct" value="#form#">
			</cfinvoke>
		</cfif>	
		<cfif structKeyExists(session.OnboardingDocSaveMessage, "ID")>
			<cflocation url="index.cfm?event=AddOnBoardingDoc&ID=#session.OnboardingDocSaveMessage.ID#&#session.URLToken#" />
		<cfelse>
			<cflocation url="index.cfm?event=AddOnBoardingDoc&#session.URLToken#" />
		</cfif>
	</cfcase>

	<cfcase value="DeleteOnboardingDoc">
		<cfinvoke component="#variables.objCarrierGateway#" method="DeleteOnboardingDoc" returnvariable="session.OnboardingDocSaveMessage">
			<cfinvokeargument name="ID" value="#url.ID#">
			<cfinvokeargument name="UploadFileName" value="#url.UploadFileName#">
			<cfinvokeargument name="ZohoTemplateID" value="#url.ZohoTemplateID#">
		</cfinvoke>
		<cflocation url="index.cfm?event=OnboardCarrierDocs&#session.URLToken#" />
	</cfcase>

	<cfcase value="OnboardSetting">
    	<cfset request.subnavigation = includeTemplate("views/admin/sysSetupSubnav.cfm", true) />
    	<cfset request.content = includeTemplate("views/pages/systemSetup/OnboardSetting.cfm", true) />
        <cfset includeTemplate("views/templates/maintemplate.cfm") />
	</cfcase>

	<cfcase value="OnboardSetting:Process">
		<cfinvoke component="#variables.objCarrierGateway#" method="SaveOnboardingSetting" returnvariable="session.OnboardingSettingMessage">
			   <cfinvokeargument name="formStruct" value="#form#">
		</cfinvoke>
		<cflocation url="index.cfm?event=OnboardSetting&#session.URLToken#" />
	</cfcase>

	<cfcase value="OnboardEquipments">
    	<cfset request.subnavigation = includeTemplate("views/admin/sysSetupSubnav.cfm", true) />
    	<cfset request.content = includeTemplate("views/pages/systemSetup/OnboardEquipments.cfm", true) />
        <cfset includeTemplate("views/templates/maintemplate.cfm") />
	</cfcase>

	<cfcase value="DocsTobeAttached">
    	<cfset request.subnavigation = includeTemplate("views/admin/sysSetupSubnav.cfm", true) />
    	<cfset request.content = includeTemplate("views/pages/systemSetup/DocsTobeAttached.cfm", true) />
        <cfset includeTemplate("views/templates/maintemplate.cfm") />
	</cfcase>

	<cfcase value="BillFromCompanies">
    	<cfset request.subnavigation = includeTemplate("views/admin/sysSetupSubnav.cfm", true) />
    	<cfset request.content = includeTemplate("views/pages/systemSetup/BillFromCompanies.cfm", true) />
        <cfset includeTemplate("views/templates/maintemplate.cfm") />
	</cfcase>

	<cfcase value="AddBillFromCompany">
    	<cfset request.subnavigation = includeTemplate("views/admin/sysSetupSubnav.cfm", true) />
    	<cfset request.content = includeTemplate("views/pages/systemSetup/AddBillFromCompany.cfm", true) />
        <cfset includeTemplate("views/templates/maintemplate.cfm") />
	</cfcase>

	<cfcase value="AddBillFromCompany:Process">
		<cfinvoke component="#variables.objAgentGateway#" method="SaveBillFromCompany" returnvariable="session.CompanySaveMessage">
			   <cfinvokeargument name="formStruct" value="#form#">
		</cfinvoke>
		<cflocation url="index.cfm?event=BillFromCompanies&#session.URLToken#" />
	</cfcase>

	<cfcase value="deleteBillFromCompany">
		<cfinvoke component="#variables.objAgentGateway#" method="DeleteBillFromCompany" returnvariable="session.CompanySaveMessage">
			   <cfinvokeargument name="ID" value="#url.ID#">
		</cfinvoke>
		<cflocation url="index.cfm?event=BillFromCompanies&#session.URLToken#" />
	</cfcase>
</cfswitch>
