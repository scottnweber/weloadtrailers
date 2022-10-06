<cfset SmtpAddress='smtpout.secureserver.net'>
<cfset SmtpUsername='no-reply@loadmanager.com'>
<cfset SmtpPort='3535'>
<cfset SmtpPassword='wsi11787'>
<cfset FA_SSL=0>
<cfset FA_TLS=1>
<!--- <cfset variables.timeOutPoint = DateAdd('s', -30, Now())> --->
<cfset variables.timeout=this.sessiontimeout>
<cfquery name="qDeleteUserLoggedInCount" datasource="#Application.dsn#">
	update onlineusers
	set
	isActive=0
	where lastseenDatetime <= <cfqueryparam cfsqltype="cf_sql_timestamp" value="#DateAdd('s', '-#variables.timeout#', Now())#">
</cfquery>