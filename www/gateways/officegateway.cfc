<cfcomponent output="false">
<cffunction name="init" access="public" output="false" returntype="void">
	<cfargument name="dsn" type="string" required="yes" />
	<cfset variables.dsn = Application.dsn />
</cffunction>

<!--- Add Office --->
<cffunction name="addOffice" access="public" output="false" returntype="Any">
	<cfargument name="formStruct" type="struct" required="yes">
	<cfquery name="qGet" datasource="#variables.dsn#">
		SELECT NEWID() AS NewOfficeID
	</cfquery>
	<cfquery name="addOffice" datasource="#variables.dsn#">
		insert into offices (OfficeID,officecode,location,adminmanager,contactno,contactNoExt,faxno,faxNoExt,emailid,isActive,createdBy,createdDateTime,lastmodifiedby,lastmodifieddatetime,disclaimertext,customerdisclaimertext,CreatedByIP,GUID,CompanyID,IntegrateWithITS,ITSUserName,ITSPassword,ITSDefaultPosting)
		values (
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#qGet.NewOfficeID#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.officecode#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.location#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.adminmanager#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.contactNo#">,
			<cfif structKeyExists(arguments.formStruct, "contactNoExt")>
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.contactNoExt#">,
			<cfelse>
        		,NULL
      		</cfif> 
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.faxNo#">,
			<cfif structKeyExists(arguments.formStruct, "faxNoExt")>
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.faxNoExt#">,
			<cfelse>
        		,NULL
      		</cfif>
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.emailid#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.isActive#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#session.adminUserName#">,
			<cfqueryparam cfsqltype="cf_sql_date" value="#now()#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#session.adminUserName#">,
			<cfqueryparam cfsqltype="cf_sql_date" value="#Now()#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.disclaimertext#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.customerdisclaimertext#">,
            <cfqueryparam cfsqltype="cf_sql_varchar" value="#cgi.REMOTE_ADDR#">,
            <cfqueryparam cfsqltype="cf_sql_varchar" value="#cgi.HTTP_USER_AGENT#">,
            <cfqueryparam cfsqltype="cf_sql_varchar" value="#session.companyid#">
            <cfif structKeyExists(form,"IntegrateWithITS")>
            	,1
            <cfelse>
            	,0
            </cfif>
            ,<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.ITSUserName#">
            ,<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.ITSPassword#">
            <cfif structKeyExists(form,"ITSDefaultPosting")>
            	,1
            <cfelse>
            	,0
            </cfif>
		   )
	</cfquery>
	<cfreturn qGet.NewOfficeID>
</cffunction>

<!--- Update Office --->
<cffunction name="updateOffice" access="public" output="false" returntype="Any">
	<cfargument name="formStruct" type="struct" required="yes">
	<cfquery name="updateOffice" datasource="#variables.dsn#">
		update offices set
			officecode = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.officecode#">,
			location = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.location#">,
			adminmanager = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.adminmanager#">,
			contactno = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.contactNo#">,
			<cfif structKeyExists(arguments.formStruct, "contactNoExt")>
				contactNoExt = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.contactNoExt#">,
			</cfif>
			faxno = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.faxNo#">,
			<cfif structKeyExists(arguments.formStruct, "faxNoExt")>
				faxNoExt = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.faxNoExt#">,
			</cfif>
			emailid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.emailid#">,
			isActive = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.isActive#">,
			lastmodifiedby = <cfqueryparam cfsqltype="cf_sql_varchar" value="#session.adminUserName#">,
			lastmodifieddatetime = <cfqueryparam cfsqltype="cf_sql_date" value="#Now()#">,
			disclaimertext = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.disclaimertext#">,
			customerdisclaimertext = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.customerdisclaimertext#">,
            UpdatedByIP=<cfqueryparam cfsqltype="cf_sql_varchar" value="#cgi.REMOTE_ADDR#">
            <cfif structKeyExists(form,"IntegrateWithITS")>
            	,IntegrateWithITS=1
            <cfelse>
            	,IntegrateWithITS=0
            </cfif>
            ,ITSUserName = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.ITSUserName#">
            ,ITSPassword = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.ITSPassword#">
            <cfif structKeyExists(form,"ITSDefaultPosting")>
            	,ITSDefaultPosting=1
            <cfelse>
            	,ITSDefaultPosting=0
            </cfif>
		   where officeId = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.editid#">
	</cfquery>
	<cfreturn arguments.formStruct.editid>
</cffunction>

<!--- Get Ofiices--->
<cffunction name="getAllOffices" access="public" output="false" returntype="query">
	<cfargument name="officeID" required="no" type="any">
    <cfargument name="sortorder" required="no" type="any">
    <cfargument name="sortby" required="no" type="any">
	<CFSTOREDPROC PROCEDURE="USP_GetOfficeDetails" DATASOURCE="#variables.dsn#"> 
		<cfif isdefined('arguments.officeID') and len(arguments.officeID)>
		 	<CFPROCPARAM VALUE="#arguments.officeID#" cfsqltype="CF_SQL_VARCHAR">  
		 <cfelse>
		 	<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR">  
		 </cfif>
		 <CFPROCPARAM VALUE="#session.companyid#" cfsqltype="CF_SQL_VARCHAR">  
		 <CFPROCRESULT NAME="qrygetoffices"> 
	</CFSTOREDPROC>
    
    <cfif isDefined("arguments.sortorder") and isDefined("arguments.sortby") and len(arguments.sortby)> 
             
          <cfquery datasource="#variables.dsn#" name="getnewAgent">
                      select *  from Offices
                      where CompanyID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#session.CompanyID#">
					  <cfif isdefined('arguments.officeID') and len(arguments.officeID)>
						AND officeID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.officeID#">
					  </cfif>
                      order by #arguments.sortby# #arguments.sortorder#;
          </cfquery>
                    
         <cfreturn getnewAgent>               
                      
    </cfif>
    <cfreturn qrygetoffices>
</cffunction>
<!--- Delete Office--->
<cffunction name="deleteOffice" access="public" output="false" returntype="any">
	<cfargument name="officeID" required="yes" type="any">
	<cftry>
    <cfquery name="qrygetoffices" datasource="#variables.dsn#">
        delete from Offices where officeId  =<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.officeID#">
    </cfquery>
    <cfreturn "Office has been deleted successfully.">
	<cfcatch type="any"><cfreturn "Delete opereation has been not successfull. This record is being used by other module."></cfcatch>
	</cftry>
</cffunction>

<!--- Search Offices --->

<cffunction name="getSearchedOffices" access="public" output="false" returntype="query">
	<cfargument name="searchText" required="yes" type="any">
	<CFSTOREDPROC PROCEDURE="searchOffices" DATASOURCE="#variables.dsn#"> 
		<cfif isdefined('arguments.searchText') and len(arguments.searchText)>
		 	<CFPROCPARAM VALUE="#arguments.searchText#" cfsqltype="CF_SQL_VARCHAR">  
		 <cfelse>
		 	<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR">  
		 </cfif>
		 <CFPROCPARAM VALUE="#session.CompanyID#" cfsqltype="CF_SQL_VARCHAR"> 
		 <CFPROCRESULT NAME="QreturnSearch"> 
	</CFSTOREDPROC>
    <cfreturn QreturnSearch>
</cffunction>

<cffunction name="verifyITSLoginStatus" access="public" returntype="boolean">
	<cfargument name="ITSUserName" type="string" required="yes">
	<cfargument name="ITSPassword" type="string" required="yes">
	<cfargument name="OfficeID" type="string" required="yes">
	<cftry>
		<cfset var isSuccess = true>
		<cfquery name="qSystemSetup" datasource="LoadManagerAdmin">
			SELECT ITSClientID,ITSSecret FROM SystemSetup 
		</cfquery>

		<cfhttp method="post" url="https://api.truckstop.com/auth/authorize?response_type=code&scope=truckstop&client_id=#trim(qSystemSetup.ITSClientID)#&redirect_uri=https://api-int.truckstop.com/auth/processcode" result="ITSAuthResp">
			<cfhttpparam type="formfield" name="UserName"  value="#arguments.ITSUserName#" />
			<cfhttpparam type="formfield" name="Password"  value="#arguments.ITSPassword#" />
			<cfhttpparam type="formfield" name="ClientId"  value="#trim(qSystemSetup.ITSClientID)#" />
			<cfhttpparam type="formfield" name="Scope"  value="truckstop" />
		</cfhttp>

		<cfif FindNoCase('processed successfully',ITSAuthResp.FileContent)>
			<cfset authCode = Trim(REReplaceNoCase(ITSAuthResp.FileContent, "<[^[:space:]][^>]*>", "", "ALL"))>
			<cfset authCode = Trim(REReplaceNoCase(authCode, "Authorize", "", "ALL"))>
			<cfset authCode = Trim(REReplaceNoCase(authCode, "Code", "", "ALL"))>
			<cfset authCode = Trim(REReplaceNoCase(authCode, "processed successfully", "", "ALL"))>
	
			<cfset var  base64 = toBase64('#trim(qSystemSetup.ITSClientID)#:#trim(qSystemSetup.ITSSecret)#')>
			<cfhttp method="post" url="https://api.truckstop.com/auth/token?scope=truckstop" result="objGet">
			    <cfhttpparam type="header" name="Authorization" value="Basic #base64#"/>
			    <cfhttpparam type="header" name="Content-Type" value="application/x-www-form-urlencoded"/>
			    <cfhttpparam type="formfield" name="grant_type" value="authorization_code">
			    <cfhttpparam type="formfield" name="code" value="#authCode#">
			    <cfhttpparam type="formfield" name="redirect_uri" value="https://api-int.truckstop.com/auth/processcode">
			</cfhttp>

			<cfif objGet.Statuscode EQ '200 OK'>
				<cfset var FileContent = DeSerializeJSON(objGet.FileContent)>
				<cfif structkeyexists(FileContent,"access_token") and structkeyexists(FileContent,"refresh_token")>
					<cfquery name="qUpd" datasource="#variables.dsn#">
						UPDATE Offices SET 
						ITSAccessToken = <cfqueryparam value="#FileContent.access_token#" cfsqltype="cf_sql_varchar">
						,ITSRefreshToken = <cfqueryparam value="#FileContent.refresh_token#" cfsqltype="cf_sql_varchar">
						,ITSTokenExpireDate = <cfqueryparam value="#dateAdd("n", 20, now())#" cfsqltype="cf_sql_timestamp">
						WHERE ITSUserName = <cfqueryparam value="#arguments.ITSUserName#" cfsqltype="cf_sql_varchar">
						AND ITSPassword = <cfqueryparam value="#arguments.ITSPassword#" cfsqltype="cf_sql_varchar">
					</cfquery>
				</cfif>
			<cfelse>
				<cfquery name="qUpdOfc" datasource="#variables.dsn#">
					UPDATE Offices SET 
					IntegrateWithITS=0
					,ITSDefaultPosting=0
					WHERE ITSUserName = <cfqueryparam value="#arguments.ITSUserName#" cfsqltype="cf_sql_varchar">
					AND ITSPassword = <cfqueryparam value="#arguments.ITSPassword#" cfsqltype="cf_sql_varchar">
				</cfquery>
				<cfset isSuccess = false>
			</cfif>
		<cfelse>
			<cfquery name="qUpdOfc" datasource="#variables.dsn#">
				UPDATE Offices SET 
				IntegrateWithITS=0
				,ITSDefaultPosting=0
				WHERE ITSUserName = <cfqueryparam value="#arguments.ITSUserName#" cfsqltype="cf_sql_varchar">
				AND ITSPassword = <cfqueryparam value="#arguments.ITSPassword#" cfsqltype="cf_sql_varchar">
			</cfquery>
			<cfset isSuccess = false>
		</cfif>
		<cfreturn isSuccess>
		<cfcatch type="any">
			<cfset isSuccess = false>
		</cfcatch>
		
	</cftry>
</cffunction>
</cfcomponent>