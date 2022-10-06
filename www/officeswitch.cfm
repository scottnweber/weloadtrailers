<cfscript>
	variables.objOfficeGateway = getGateway("gateways.officegateway", MakeParameters("dsn=#Application.dsn#,pwdExpiryDays=#Application.pwdExpiryDays#"));
	variables.objAgentGateway = getGateway("gateways.agentgateway", MakeParameters("dsn=#Application.dsn#,pwdExpiryDays=#Application.pwdExpiryDays#"));
</cfscript>
<cfif  request.event neq 'login' AND request.event neq 'customerlogin'>
		<cfif (not isdefined("session.passport.isLoggedIn") or not(session.passport.isLoggedIn))>
		<cfelse>
		<cfswitch expression="#request.event#">
			<cfcase value="office">
				<cfinvoke component="#variables.objOfficeGateway#" method="getAllOffices" returnvariable="request.qOffice" />
				<cfset request.subnavigation = includeTemplate("views/admin/adminsubnav.cfm", true) />
				<cfset request.content = includeTemplate("views/pages/office/disp_office.cfm", true) />
				<cfset includeTemplate("views/templates/maintemplate.cfm") />
			</cfcase>
			<cfcase value="addoffice">
				 <cfset request.subnavigation = includeTemplate("views/admin/adminsubnav.cfm", true) />
				 <cfset request.content=includeTemplate("views/pages/office/addoffices.cfm",true)/>
				 <cfset includeTemplate("views/templates/maintemplate.cfm") />
			</cfcase>
			<cfcase value="addoffice:process">
				<cfif not structKeyExists(form, "officeCode")>
					<cflocation url="index.cfm?event=office&#session.URLToken#" />
				</cfif>
				 <cfset formStruct = structNew()>
				 <cfset formStruct = form>

				<cfset session.OfcSubResp = "">
				<cfif isdefined("form.editid") and len(form.editId) gt 1>
					<cfinvoke component="#variables.objOfficeGateway#" method="updateOffice" returnvariable="OfficeID">
						<cfinvokeargument name="formStruct" value="#formStruct#">
				    </cfinvoke>
				    <cfset session.OfcSubResp &= "Office has been updated successfully. ">
				<cfelse>	 
					 <cfinvoke component="#variables.objOfficeGateway#" method="Addoffice" returnvariable="OfficeID">
						<cfinvokeargument name="formStruct" value="#formStruct#">
					 </cfinvoke>
					 <cfset session.OfcSubResp &= "Office has been added successfully. ">
				</cfif>

				<cfif structKeyExists(form,"IntegrateWithITS") AND (formStruct.ITSUserNameOld NEQ formStruct.ITSUserName OR formStruct.ITSPasswordOld NEQ formStruct.ITSPassword)>
					<cfinvoke component="#variables.objOfficeGateway#" method="verifyITSLoginStatus" returnvariable="ITSLoginStatus" OfficeID="#OfficeID#"> 
						<cfinvokeargument name="ITSUserName" value="#formStruct.ITSUserName#">
						<cfinvokeargument name="ITSPassword" value="#formStruct.ITSPassword#">
				    </cfinvoke>
					<cfif not ITSLoginStatus>
						<cfset session.OfcSubResp &= "TruckStop credentials failed. ">
					</cfif>
				</cfif>
				 <cflocation url="index.cfm?event=office&#Session.URLToken#">
			</cfcase>
		</cfswitch>
		</cfif>
</cfif>
