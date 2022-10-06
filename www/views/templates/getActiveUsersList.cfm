<cfquery name="qGetAllowedUsers" datasource="#Application.dsn#">
	SELECT *
	FROM SystemConfig 
	<cfif structKeyExists(session, "CompanyID")>
		WHERE CompanyID = '#session.CompanyID#'
	</cfif>
</cfquery>

<cfif qGetAllowedUsers.recordcount>
	<cfset local.allowedUserLimit = qGetAllowedUsers.allowed_users>
</cfif>
<cfquery name="qGetUserCount" datasource="#Application.dsn#" >
	SELECT * FROM  userCountCheck 
</cfquery>
<cfif structkeyexists(session,"empid") and len(session.empid) and structKeyExists(Session, "useruniqueid") and len(Session.useruniqueid)>
	<cfquery name="qGetActiveUsers" datasource="#Application.dsn#" >
		SELECT * FROM  userCountCheck 
		WHERE cutomerId = <cfqueryparam cfsqltype="cf_sql_varchar" value="#Session.empid#">
		AND useruniqueid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#Session.useruniqueid#">
	</cfquery>
	<cfif not  qGetActiveUsers.recordcount>
		<cfset StructDelete(session, "empid")>
		<cfset StructDelete(session, "useruniqueid")>
		<cflocation url="index.cfm?event=logout:process">
	<cfelse>
		<cfquery name="qUpdateActiveStatus" datasource="#Application.dsn#" result="qDeleteUserLogged">
			UPDATE userCountCheck
			SET currenttime=<cfqueryparam cfsqltype="cf_sql_timestamp" value="#CreateODBCDateTime(now())#">
			WHERE cutomerId = <cfqueryparam cfsqltype="cf_sql_varchar" value="#Session.empid#"> 
			AND useruniqueid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#Session.useruniqueid#">
		</cfquery>		
	</cfif>
</cfif> 