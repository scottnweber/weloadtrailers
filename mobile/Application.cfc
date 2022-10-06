<cfcomponent>
	<cfsetting enablecfoutputonly="yes" />
	<cfset this.name = "MobileApp" >
	<cfset this.dsnname = trim(listFirst(cgi.SCRIPT_NAME,'/')) >
	<cfset this.SessionManagement = "true" >
    <cfset this.ClientManagement = "false" >
    <cfset this.SetClientCookies = "true" >
    <cfset this.ApplicationTimeout = CreateTimeSpan(10,0,0,0)>
    <cfset this.SessionTimeout = CreateTimeSpan(0,2,0,0) >

	<cfset this.mappings = structNew() />
	<cfset this.mappings["/local"] = getDirectoryFromPath(ExpandPath("../../LoadManagerDevMobile/"))>


	<cffunction name="OnApplicationStart" >
		<cfset Application.Name = this.name >
		<cfset Application.dsnName_temp = trim(listGetAt(cgi.SCRIPT_NAME, 2, '/') )>
		<cfset Application.dsn = this.dsnname >

		<cfset Application.gAPI='AIzaSyAMvv7YySXPntllOqj7509OH-9N3HgCJmw' > <!---Googple Maps API--->
		<cfset Application.strWebsiteTitle = "Load Manager" > <!--- Remember this does not effect the error template title--->
		<cfset Application.strDeveloperEmailAddress = "ScottW@WeberSystems.com;sumi@techversantinfotech.com" >

    </cffunction>

	<cffunction name="OnApplicationEnd" >

    </cffunction>

	<cffunction name="onSessionStart" access="public" returntype="void" output="false" hint="I initialize the session.">

    </cffunction>

    <cffunction name = "onSessionEnd" returnType = "void" output = "true">
		<cfdump var="session End">
    </cffunction>

    <cffunction name="OnRequestStart" output="false" >
    </cffunction>

    <cffunction name="OnRequest" >
		<cfargument name="targetPage" required="true"/ >
		<cfif IsDefined("URL.reinit")>
			<cfset OnApplicationStart() />
		</cfif>

		<cfset request.webpath = Replace("http://#cgi.http_host##cgi.script_name#", "\", "/", "ALL")>

		<cfset request.fileUploadedtemp = request.webpath & "/fileupload/imgTemp/">
		<cfset request.fileUploadedPer = request.webpath & "/filesUpload/imgPrmnt/">

		<cfinclude template="#arguments.TargetPage#"/>

	</cffunction>

	<cffunction name="onError" returnType="void">
		<cfargument name="Exception" required=true/>
		<cfargument name="EventName" type="String" required=true/>

       	<cfset var template = "">
       	<cfset var companycode ="">
       	<cfset var sourcepage = "">

		<cfif structKeyExists(arguments.Exception.cause, "TagContext") AND isArray(arguments.Exception.cause.TagContext) AND NOT arrayIsEmpty(arguments.Exception.cause.TagContext) AND isstruct(arguments.Exception.cause.TagContext[1]) AND structKeyExists(arguments.Exception.cause.TagContext[1], "raw_trace")>
			<cfset template = arguments.Exception.cause.TagContext[1].raw_trace>
		</cfif>

		<cfif structKeyExists(session, "loaddetails") and structKeyExists(session.loaddetails, "companycode")>
			<cfset companycode ="["&session.loaddetails.companycode&"]">
		</cfif>
		
		<cfif isDefined("cgi.HTTP_REFERER")>
			<cfset sourcepage = "#chr(10)#[Sourcepage]:#cgi.HTTP_REFERER#">
		</cfif>

		<cfif arguments.Exception.Type EQ "Database" AND (FindNoCase("Cannot open database",arguments.Exception.cause.Detail) OR FindNoCase("Connection reset by peer",arguments.Exception.cause.Detail))>
       		<cfoutput>
       			<h6 style="padding:10px;">Your web-site is currently offline, please call technical support at 631-724-9400 to bring it back online.</h6>
       		</cfoutput>
       	<cfelse>
       		<cfoutput>
       			<script type="text/javascript">
       				document.getElementsByClassName("form-box")[0].innerHTML = '<h6 style="padding:10px;text-align:center;">Something went wrong, please try again later or call technical support at 631-724-9400.</h6>';
       			</script>
       		</cfoutput>
       		<cffile action="append" file="#ExpandPath("../www/webroot/logs")#/Application.Log.txt" output="#dateTimeFormat(now())##chr(10)##(companycode)##arguments.Exception.cause.Detail##arguments.Exception.cause.Message##chr(10)#[URLData]:#SerializeJSON(url)##trim(template)##sourcepage#">

       		<cfquery name="qInsLog" datasource="LoadManagerAdmin">
       			INSERT INTO LMErrorLog (CompanyCode,Detail,Status,FormData,URLData,Template,SourcePage)
       			VALUES (
       				<cfif structKeyExists(session, "usercompanycode")>
       					<cfqueryparam value="#session.usercompanycode#" cfsqltype="cf_sql_varchar">
       				<cfelse>
       					NULL
       				</cfif>
       				,<cfqueryparam value="#arguments.Exception.cause.Detail##arguments.Exception.cause.Message#" cfsqltype="cf_sql_varchar">
       				,'Pending'
       				<cfif isDefined("form")>
       					,<cfqueryparam value="#SerializeJSON(form)#" cfsqltype="cf_sql_varchar">
       				<cfelse>
       					,NULL
       				</cfif>
       				,<cfqueryparam value="#SerializeJSON(url)#" cfsqltype="cf_sql_varchar">
       				,<cfqueryparam value="#Template#" cfsqltype="cf_sql_varchar">
       				<cfif isDefined("cgi.HTTP_REFERER")>
       					,<cfqueryparam value="#cgi.HTTP_REFERER#" cfsqltype="cf_sql_varchar">
       				<cfelse>
       					,NULL
       				</cfif>
       				)
       		</cfquery>

       	</cfif>
	</cffunction>
</cfcomponent>
