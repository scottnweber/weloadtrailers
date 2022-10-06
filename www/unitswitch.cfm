<cfscript>
	variables.objunitGateway = getGateway("gateways.unitgateway", MakeParameters("dsn=#Application.dsn#,pwdExpiryDays=#Application.pwdExpiryDays#"));
</cfscript>
<cfif  request.event neq 'login' AND request.event neq 'customerlogin'>
		<cfif (not isdefined("session.passport.isLoggedIn") or not(session.passport.isLoggedIn))>
		<cfelse>
		<cfswitch expression="#request.event#">
			<cfcase value="unit">			  
			    <cfinvoke component="#variables.objunitGateway#" method="getAllUnits" returnvariable="request.qUnits" />
				<cfset request.subnavigation = includeTemplate("views/admin/loadNav.cfm", true) />
				<cfset request.content = includeTemplate("views/pages/unit/disp_unit.cfm", true) />
				<cfset includeTemplate("views/templates/maintemplate.cfm") />
			</cfcase>
			<cfcase value="addunit">
                 <cfset request.subnavigation = includeTemplate("views/admin/loadNav.cfm", true) />
				 <cfset request.content=includeTemplate("views/pages/unit/addunit.cfm",true)/>
				 <cfset includeTemplate("views/templates/maintemplate.cfm") />
			</cfcase>
			<cfcase value="addunit:process"> 
				<cfif StructIsEmpty(form)>
					<cflocation url="index.cfm?event=unit&#session.URLToken#" />
				</cfif>                  
				 <cfset formStruct = structNew()>
				 <cfset formStruct = form>
                 <cfif isdefined("form.editid") and len(form.editid) gt 1>
					<cfinvoke component="#variables.objunitGateway#" method="Updateunit" returnvariable="message">
					   <cfinvokeargument name="formStruct" value="#formStruct#">
					 </cfinvoke>
				 <cfelse>	 
					 <cfinvoke component="#variables.objunitGateway#" method="Addunit" returnvariable="message">
						<cfinvokeargument name="formStruct" value="#formStruct#">
					 </cfinvoke>
				 </cfif>
				 <cfinvoke component="#variables.objunitGateway#" method="getAllUnits" returnvariable="request.qUnits" />
				 <cfset request.subnavigation = includeTemplate("views/admin/loadNav.cfm", true) />
				 <cfset request.content=includeTemplate("views/pages/unit/disp_unit.cfm",true)/>
				 <cfset includeTemplate("views/templates/maintemplate.cfm") />
			</cfcase>
            <cfdefaultcase></cfdefaultcase>
		</cfswitch>
		</cfif>
</cfif>
