<cfcomponent>
	<cfsetting enablecfoutputonly="yes" />
	<cfset this.name = trim(listFirst(cgi.SCRIPT_NAME,'/')) ><!---0devBiz2018--->
	<cfset this.SessionManagement = "true" >
    <cfset this.ClientManagement = "false" >
    <cfset this.SetClientCookies = "true" >
    <cfset this.ApplicationTimeout = CreateTimeSpan(10,0,0,0)>
    <cfset this.SessionTimeout = CreateTimeSpan(0,2,0,0) >  
	<cfsetting showdebugoutput=false>
	<cffunction name="OnApplicationStart" >
		<cfset Application.Name = this.name >
		<cfset Application.QBdsn = "LMaccessQB" > <!--- Quickbooks DSN --->
		<cfset Application.dsn = trim(listFirst(cgi.SCRIPT_NAME,'/'))>
		
		<cfset Application.gAPI='AIzaSyAMvv7YySXPntllOqj7509OH-9N3HgCJmw' > <!---Googple Maps API--->
		<cfset Application.strWebsiteTitle = "Load Manager" > <!--- Remember this does not effect the error template title--->
		<cfset Application.strDeveloperEmailAddress = "ScottW@WeberSystems.com;scottnweber@gmail.com" > 
		<cfset Application.ExtrasFolder = ExpandPath("../../extras") > 
		<cfset Application.strDateFormat = "d MMMM YYYY">
		<cfset Application.strDateFormatForTextInput = "dd/MM/YYYY">
		<cfset Application.ResultsPerPage = 10>
		<cfset Application.ImportDSN = "">
		<cfset Application.SchedulerTimeout = 120>
		<cfset Application.pwdExpiryDays = 600 > <!--- How many days before the passwords expire (by default). --->
		<cfset Application.strTimeFormat = "HH:MM">
		<cfparam name="Application.userLoggedInCount" default="">	
		<cfset Application.NoAuthEvents = "login|login:process|lostpassword|lostpassword:process|customerlogin|Customerlogin:process" > <!--- This is a Pipe(|) Separated List of events that do not require the user to be logged in first (e.g. login|login:process).--->
		<cfset Application.strSMSAddress = "ScottW@WeberSystems.com" >
		<cfset Application.strEmailFromAddress = "ScottW@WeberSystems.com" >
		<cfif IsDefined("URL.strDebugMode")>
			<cfif URL.strDebugMode EQ "EntelDebug#DateFormat(Now(),"yyyyMMddHH")#">
				<cfset Application.blnDebugMode = True>
			</cfif>
		<cfelse>
			<cfset Application.blnDebugMode = false>   
		</cfif>
    </cffunction>
	
	<cffunction name="OnApplicationEnd" >
		
    </cffunction>
	
	<cffunction name="onSessionStart" access="public" returntype="void" output="false" hint="I initialize the session.">
		
    </cffunction>

    <cffunction name = "onSessionEnd" returnType = "void" output = "true">
        <cfargument name = "sessionScope" type = "struct" required = "true">
        <cfargument name = "appScope" type = "struct" required = "true">
		<!---Query to select  loads table--->
		<cfquery name="qryGetInuseBy" datasource="#arguments.appScope.dsn#">
			select loadid from loads 
			where sessionId=<cfqueryparam value="#arguments.sessionScope.sessionid#" cfsqltype="cf_sql_varchar">
		</cfquery>
		<cfif qryGetInuseBy.recordcount>
			<!---Query to update loads table--->
			<cfquery name="qryGetInuseBy" datasource="#arguments.appScope.dsn#">
				update loads 
				set 
					InUseBy=null,
					InUseOn=null,
					sessionId=null
				where sessionId=<cfqueryparam value="#arguments.sessionScope.sessionid#" cfsqltype="cf_sql_varchar">	
			</cfquery>
		</cfif>

		<!---Query to select  customer table and release lock--->
		<cfquery name="qryGetCustomerInuseBy" datasource="#arguments.appScope.dsn#">
			select CustomerID from Customers 
			where sessionId=<cfqueryparam value="#arguments.sessionScope.sessionid#" cfsqltype="cf_sql_varchar">
		</cfquery>
		<cfif qryGetInuseBy.recordcount>
			<!---Query to update customers table--->
			<cfquery name="qryGetCustomerInuseBy" datasource="#arguments.appScope.dsn#">
				update Customers 
				set 
					InUseBy=null,
					InUseOn=null,
					sessionId=null
				where sessionId=<cfqueryparam value="#arguments.sessionScope.sessionid#" cfsqltype="cf_sql_varchar">	
			</cfquery>
		</cfif>

		<!---Query to select  carriers table and release lock--->
		<cfquery name="qryGetInuseBy" datasource="#arguments.appScope.dsn#">
			select CarrierID from Carriers 
			where sessionId=<cfqueryparam value="#arguments.sessionScope.sessionid#" cfsqltype="cf_sql_varchar">
		</cfquery>
		<cfif qryGetInuseBy.recordcount>
			<!---Query to update carriers table--->
			<cfquery name="qryGetInuseBy" datasource="#arguments.appScope.dsn#">
				update Carriers 
				set 
					InUseBy=null,
					InUseOn=null,
					sessionId=null
				where sessionId=<cfqueryparam value="#arguments.sessionScope.sessionid#" cfsqltype="cf_sql_varchar">	
			</cfquery>
		</cfif>

		<!---Query to select  employees table and release lock--->
		<cfquery name="qryGetInuseBy" datasource="#arguments.appScope.dsn#">
			select EmployeeId from Employees 
			where sessionId=<cfqueryparam value="#arguments.sessionScope.sessionid#" cfsqltype="cf_sql_varchar">
		</cfquery>
		<cfif qryGetInuseBy.recordcount>
			<!---Query to update employees table--->
			<cfquery name="qryGetInuseBy" datasource="#arguments.appScope.dsn#">
				update Employees 
				set 
					InUseBy=null,
					InUseOn=null,
					sessionId=null
				where sessionId=<cfqueryparam value="#arguments.sessionScope.sessionid#" cfsqltype="cf_sql_varchar">	
			</cfquery>
		</cfif>

		<!---Query to select  equipment table and release lock--->
		<cfquery name="qryGetInuseBy" datasource="#arguments.appScope.dsn#">
			select EquipmentId from Equipments 
			where sessionId=<cfqueryparam value="#arguments.sessionScope.sessionid#" cfsqltype="cf_sql_varchar">
		</cfquery>
		<cfif qryGetInuseBy.recordcount>
			<!---Query to update employees table--->
			<cfquery name="qryGetInuseBy" datasource="#arguments.appScope.dsn#">
				update Equipments 
				set 
					InUseBy=null,
					InUseOn=null,
					sessionId=null
				where sessionId=<cfqueryparam value="#arguments.sessionScope.sessionid#" cfsqltype="cf_sql_varchar">	
			</cfquery>
		</cfif>

		<!---Query to delete UserBrowserTabDetails --->
		<cfquery name="qryDeleteBrowsertabDetails" datasource="#arguments.appScope.dsn#">
			delete from  UserBrowserTabDetails 
			where sessionId=<cfqueryparam value="#arguments.sessionScope.sessionid#" cfsqltype="cf_sql_varchar">
		</cfquery>
    </cffunction>
	
	<!--- Request Functions --->
    <cffunction name="OnRequestStart" output="false" >	
    </cffunction>

    <cffunction name="OnRequest" >		
		<cfargument name="targetPage" required="true"/ >
		<cfif IsDefined("URL.reinit")>
			<!---<cfinclude template="userCountScheduler.cfm">--->
			<cfscript>
				StructDelete(Application, "objLoadGatewayAdd", "True");
				StructDelete(Application, "objloadGateway", "True");
				StructDelete(Application, "objLoadGatewaynew", "True");
				StructDelete(Application, "objAgentGateway", "True");
				StructDelete(Application, "objLoadgatewayUpdate", "True");
			</cfscript>			
			<cfset OnApplicationStart() />
		</cfif>
		
		<cfparam name="Session.blnDebugMode" default="#Application.blnDebugMode#">		
		<cfset basepath = GetDirectoryFromPath(GetBaseTemplatePath())>
		<!--- publicRoot: the directory that Application.cfc resides in (the web root) --->

		<cfset publicRoot = GetDirectoryFromPath(GetCurrentTemplatePath())>
		
		<cfif len(basepath) gt len(publicRoot)>
			<!--- relativePath: the difference between basepath and publicRoot --->
			<cfset relativePath = right(basepath, len(basepath) - len(publicRoot))>
			<!--- publicRootRelative: the relative path from the current template to the web root --->
			<cfset publicRootRelative = ReReplace(relativePath, "[^\\\/]+", "..", "ALL")>
			<cfset publicRootParentRelative = iif(Len(publicRootRelative) GT 3, 'Left(publicRootRelative, Len(publicRootRelative) - 3)', DE(publicRootRelative))>
			<cfset publicRootGrandParentRelative = iif(Len(publicRootParentRelative) GT 3, 'Left(publicRootParentRelative, Len(publicRootParentRelative) - 3)', DE(publicRootParentRelative))>
		<cfelse>
			<!--- the current template resides in the web root, both these variables are empty --->
			<cfset relativePath = "">
			<cfset publicRootRelative = "">
		</cfif>
		
		<cfset session.checkUnload = ''>
		<cfset request.webpath = Replace("http://#cgi.http_host##cgi.script_name#", "\", "/", "ALL")>
		<cfset numDirectories = ListLen(relativePath, "\/") + 1>
		
		<cfloop from="1" to="#numDirectories#" index="i">
			<cfset request.webpath = left(request.webpath, len(request.webpath) - find("/", reverse(request.webpath)))>
		</cfloop>

		<cfset request.imagesPath = request.webpath & "/images/">
		<cfset request.fileUploadedtemp = request.webpath & "/fileupload/imgTemp/">  
		<cfset request.fileUploadedPer = request.webpath & "/filesUpload/imgPrmnt/">
		
		 <cfset request.cfcpath = Application.dsn &'.www.gateways'>  

		
		<cfinclude template="#arguments.TargetPage#"/>
		<!---Sample URL is http://www.loadmanager.biz/cfmps/www/webroot/index.cfm?strDebugMode=EntelDebug2012041106--->
		<!---The 06 in the end is the hour of the current time in the timezone set on the server. This would need to change every hour.---> 
		
		<cfif Application.blnDebugMode Or Session.blnDebugMode>
			<cfsetting showdebugoutput="yes">
		<cfelse>
			<cfsetting showdebugoutput="no">
		</cfif>	
		
	</cffunction>
	
	<cffunction name="OnError" access="public" returntype="void" output="true" hint="Fires when an exception occures that is not caught by a try/catch block">

        <!--- Define arguments. --->
        <cfargument name="Exception" type="any" required="true"/>
        <cfargument name="EventName" type="string" required="false" default=""/>
       	<cfset var template = "">
       	<cfset var companycode ="">
       	<cfset var sourcepage = "">
  		<cfif cgi.HTTP_HOST CONTAINS 'local'>
       		<cfdump var="#arguments.Exception#"><cfabort>
       	</cfif>
       	<cfif structKeyExists(arguments.Exception, "cause") and structKeyExists(arguments.Exception.cause, "Message") and arguments.Exception.cause.Message EQ 'Element COMPANYID is undefined in SESSION.' and not structKeyExists(session, "empid")>
       		<cflocation url="index.cfm?event=login&AlertMessageID=2">
       	</cfif>

		<cfif structKeyExists(arguments.Exception.cause, "TagContext") AND isArray(arguments.Exception.cause.TagContext) AND NOT arrayIsEmpty(arguments.Exception.cause.TagContext) AND isstruct(arguments.Exception.cause.TagContext[1]) AND structKeyExists(arguments.Exception.cause.TagContext[1], "raw_trace")>
			<cfset template = arguments.Exception.cause.TagContext[1].raw_trace>
		</cfif>

		<cfif structKeyExists(session, "usercompanycode")>
			<cfset companycode ="["&session.usercompanycode&"]">
		</cfif>
		
		<cfif isDefined("cgi.HTTP_REFERER")>
			<cfset sourcepage = "#chr(10)#[Sourcepage]:#cgi.HTTP_REFERER#">
		</cfif>

       	<cfif arguments.Exception.Type EQ "Database" AND (FindNoCase("Cannot open database",arguments.Exception.cause.Detail)
       	OR FindNoCase("Connection reset by peer",arguments.Exception.cause.Detail) OR FindNoCase("Timed out trying to establish connection",arguments.Exception.cause.Detail) OR (structKeyExists(application, "dsn") AND FindNoCase("Datasource #application.dsn# could not be found",arguments.Exception.cause.Message)))
       	>
       		<cfoutput>
       			<h3>Your web-site is currently offline, please call technical support at 631-724-9400 to bring it back online.</h3>
       		</cfoutput>
       	<cfelse>
       		<cfoutput>
       			<h3>Something went wrong, please try again later or call technical support at 631-724-9400.</h3>
       		</cfoutput>
       		<cffile action="append" file="#ExpandPath("../webroot/logs")#/Application.Log.txt" output="#dateTimeFormat(now())##chr(10)##(companycode)##arguments.Exception.cause.Detail##arguments.Exception.cause.Message##chr(10)#[URLData]:#SerializeJSON(url)##trim(template)##sourcepage#">

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
