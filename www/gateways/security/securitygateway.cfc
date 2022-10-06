<cfcomponent>
	<cfscript>
		variables.dsn = "";
		variables.pwdExpiryDays = 60;
	</cfscript>
	
	<!--- INIT FUNCTION TO INITIALIZE VARIABLES --->
	<cffunction name="init" access="public" output="false" returntype="void">
		<cfargument name="dsn" type="string" required="yes" />
		<cfargument name="pwdExpiryDays" type="numeric" required="yes" />
		<cfset variables.dsn = replaceNoCase(arguments.dsn, "Beta", "Live") />
		<cfset variables.pwdExpiryDays = arguments.pwdExpiryDays />
    </cffunction>
    
    
	<!--- Function used to fetch a user from their username and password --->
	<cffunction name="checkLogin" access="public" output="false" returntype="query">
		<cfargument name="strUsername" required="yes" type="string" />
		<cfargument name="strPassword" required="yes" type="string" />
		<cfargument name="strCompanycode" required="yes" type="string" />
		<cfset var rstCurrentSiteUser = "" />
		
		<!--- RUN QUERY TO FETCH THE USER FROM THE DATABASE [2 new fields have been added allowed_users and current_count- Furqan] --->
			<cfquery name="rstCurrentSiteUserFirst" datasource="#variables.dsn#">
				SELECT E.EmployeeID as pkiadminUserID, 
				   E.Name as FirstName, 
				   E.Name as LastName,
				   E.loginid as UserName,
				   E.emailid as EmailAddress,
				   E.isActive as bEnabled,
				   E.createdDateTime as dtCreated,
				   E.LastModifiedDatetime as dtUpdated, 
				   E.officeId,
				   C.CompanyID,
				   C.companycode
				FROM Employees E
				INNER JOIN Offices O ON O.OfficeID = E.OfficeID
				INNER JOIN Companies C ON C.CompanyID = O.CompanyID
				WHERE E.loginId = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.strUsername#" />
				AND E.password =<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.strPassword#" />
				AND C.companycode =<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.strCompanycode#" />
				AND E.isActive = 1 AND C.isActive = 1
			</cfquery>

			<cfif rstCurrentSiteUserFirst.recordcount eq 0>
				<cfquery name="qCompany" datasource="#variables.dsn#">
					SELECT CompanyID FROM Companies WHERE companycode =<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.strCompanycode#" /> AND isActive = 1
				</cfquery>
				<cfif qCompany.recordcount>
					<cfquery name="rstCurrentSiteUserFirst" datasource="LoadManagerAdmin">
						SELECT E.ID as pkiadminUserID, 
						   E.Name as FirstName, 
						   E.Name as LastName,
						   E.loginid as UserName,
						   E.emailid as EmailAddress,
						   1 as bEnabled,
						   E.createdDateTime as dtCreated,
						   E.LastModifiedDatetime as dtUpdated, 
						  	(SELECT TOP 1 OfficeID FROM [#variables.dsn#].[dbo].Offices WHERE CompanyID = '#qCompany.CompanyID#') AS officeId,
						   '#qCompany.CompanyID#' AS CompanyID,
						   '#arguments.strCompanycode#' AS companycode
						FROM GlobalUsers E
						WHERE E.loginId = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.strUsername#" />
						AND E.password =<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.strPassword#" />
					</cfquery>

					<cfif rstCurrentSiteUserFirst.recordcount eq 0>
						<cfquery name="rstCurrentSiteUserFirst" datasource="#variables.dsn#">
							SELECT 
							S.SystemConfigID as pkiadminUserID, 
							S.DashboardUser as FirstName, 
						   	S.DashboardUser as LastName,
						   	S.DashboardUser as UserName,
						   	C.Email as EmailAddress,
						   	1 as bEnabled,
						   	C.CreatedDateTime as dtCreated,
						   	C.LastModifiedDateTime as dtUpdated, 
						  	(SELECT TOP 1 OfficeID FROM Offices WHERE CompanyID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#qCompany.CompanyID#" />) AS officeId,
						   '#qCompany.CompanyID#' AS CompanyID,
						   '#arguments.strCompanycode#' AS companycode
							FROM SystemConfig S
							INNER JOIN Companies C ON C.CompanyID = S.CompanyID
							WHERE S.CompanyID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#qCompany.CompanyID#" />
							AND S.DashboardUser = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.strUsername#" /> AND S.DashboardPassword = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.strPassword#" />
						</cfquery>
					</cfif>
				</cfif>
			</cfif>

			<cfquery name="qryUserCount" datasource="#variables.dsn#">
				SELECT allowed_users,usercount
				FROM SystemConfig INNER JOIN Companies ON SystemConfig.CompanyID = Companies.CompanyID WHERE Companies.CompanyCode = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.strCompanycode#" />
				AND SystemConfig.allowed_users >= SystemConfig.usercount
			</cfquery>
			<cfset rstCurrentSiteUser = QueryNew("pkiadminUserID, LastName, UserName,EmailAddress,bEnabled,dtCreated,dtUpdated,officeId,allowed_users,usercount,CompanyID,companycode", "VarChar, VarChar, VarChar,VarChar,bit,date,date,VarChar,integer,integer,VarChar,VarChar")>
			<cfif rstCurrentSiteUserFirst.recordcount and qryUserCount.recordcount>
				<!--- Make one rows in the query ---> 
				<cfset QueryAddRow(rstCurrentSiteUser, 1)> 
				<!--- Set the values of the cells in the query ---> 
				<cfset QuerySetCell(rstCurrentSiteUser, "pkiadminUserID", "#rstCurrentSiteUserFirst.pkiadminUserID#", 1)> 
				<cfset QuerySetCell(rstCurrentSiteUser, "LastName", "#rstCurrentSiteUserFirst.LastName#", 1)> 
				<cfset QuerySetCell(rstCurrentSiteUser, "UserName", "#rstCurrentSiteUserFirst.UserName#", 1)> 
				<cfset QuerySetCell(rstCurrentSiteUser, "EmailAddress", "#rstCurrentSiteUserFirst.EmailAddress#", 1)> 
				<cfset QuerySetCell(rstCurrentSiteUser, "bEnabled", "#rstCurrentSiteUserFirst.bEnabled#", 1)> 
				<cfset QuerySetCell(rstCurrentSiteUser, "dtCreated", "#rstCurrentSiteUserFirst.dtCreated#", 1)> 
				<cfset QuerySetCell(rstCurrentSiteUser, "dtUpdated", "#rstCurrentSiteUserFirst.dtUpdated#", 1)> 
				<cfset QuerySetCell(rstCurrentSiteUser, "officeId", "#rstCurrentSiteUserFirst.officeId#", 1)> 
				<cfset QuerySetCell(rstCurrentSiteUser, "allowed_users", "#qryUserCount.allowed_users#", 1)> 
				<cfset QuerySetCell(rstCurrentSiteUser, "usercount", "#qryUserCount.usercount#", 1)> 
				<cfset QuerySetCell(rstCurrentSiteUser, "CompanyID", "#rstCurrentSiteUserFirst.CompanyID#", 1)> 
				<cfset QuerySetCell(rstCurrentSiteUser, "companycode", "#rstCurrentSiteUserFirst.companycode#", 1)> 
				<cfset session.allowed_users ="#rstCurrentSiteUser.allowed_users#" />
				<cfset variables.userloggegInCount=listlen(Application.userLoggedInCount)+1>
				<cfif rstCurrentSiteUser.allowed_users Gte rstCurrentSiteUser.userCount>
					<cfset userip = #REMOTE_ADDR#>
					<cfset session.userip = #userip#>
					<cfset todayDate = #Now()#> 
					<cfset logindate = #DateFormat(todayDate, "yyyy-mm-dd")# >
					<cfset logintime = #TimeFormat(todayDate, "HH")#>
					
					<cfset userpin = #Rand("SHA1PRNG")#>
					<cfset session.userpin = #userpin#>
					<cfquery name="addtracking" datasource="#variables.dsn#" result="t">
						Insert into User_Track
						(user_id,ip,dated,timing,userpin,status)
						Values
						('#rstCurrentSiteUser.pkiadminUserID#','#userip#','#logindate#','#logintime#','#userpin#','active')
					 </cfquery>
				</cfif>
				<!---My Code Ends here--->
				<!---Code That Put inactive users counter down and change their status to inactive from active--->
				<cfset todayDate = #Now()#> 
				<cfset logindate = #DateFormat(todayDate, "yyyy-mm-dd")# >
				<cfset logintime = #TimeFormat(todayDate, "HH")#>
				<cfquery name="chkusers" datasource="#variables.dsn#" result="c">
					SELECT User_Track.user_id, User_Track.track_id, User_Track.ip, User_Track.dated, User_Track.timing
					FROM User_Track
					WHERE User_Track.dated = '#logindate#' AND User_Track.timing ! = #logintime# And User_Track.status = 'active'
				</cfquery>
				<!---Status Code Ends Here--->
				<cfset session.officeid= rstCurrentSiteUserFirst.officeid>
				<cfset session.EmpId= rstCurrentSiteUserFirst.pkiadminUserID>
			<cfelse>
				<!---Additional code added by Furqan for displaying limit over message--->
				<cfif structkeyexists(Session,"empid") and len(trim(Session.empid))>
					<cfset listPos = ListFindNoCase(Application.userLoggedInCount, Session.empid)>
					<cfif listPos>
						<cfset Application.userLoggedInCount = ListDeleteAt(Application.userLoggedInCount, listPos)>
						<cfquery name="update" datasource="#Application.dsn#">
							UPDATE SystemConfig
							set
							userCount =  <cfqueryparam cfsqltype="cf_sql_integer" value="#listlen(Application.userLoggedInCount)#" />
							where companyid = (select companyid from companies where companycode = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.strCompanycode#" />)
						</cfquery>
					</cfif>		
				</cfif>
				<cfif structkeyexists(Session,"customerid") and len(trim(Session.customerid))>	
					<cfset listPos = ListFindNoCase(Application.userLoggedInCount, Session.customerid)>
					<cfif listPos>
						<cfset Application.userLoggedInCount = ListDeleteAt(Application.userLoggedInCount, listPos)>
						<cfquery name="update" datasource="#Application.dsn#">
							UPDATE SystemConfig
							set
							userCount =  <cfqueryparam cfsqltype="cf_sql_integer" value="#listlen(Application.userLoggedInCount)#" />
							where companyid = (select companyid from companies where companycode = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.strCompanycode#" />)
						</cfquery>
					</cfif>
				</cfif>	
				<!---limit over code ends here--->   
				<cfset session.officeid="">
			</cfif>
			<cfreturn rstCurrentSiteUser />
		<!--- </cfif> --->
	</cffunction>

	<!--- Function used to fetch a user from their username and password --->
	<cffunction name="checkCustomerLogin" access="public" output="false" returntype="query">
		<cfargument name="strUsername" required="yes" type="string" />
		<cfargument name="strPassword" required="yes" type="string" />
		<cfargument name="strCompanycode" required="yes" type="string" />
		<cfset var rstCurrentSiteUser = "" />
		
		<!--- RUN QUERY TO FETCH THE USER FROM THE DATABASE [2 new fields have been added allowed_users and current_count- Furqan] --->

    	<cfquery name="rstCurrentSiteUser" datasource="#variables.dsn#">
			select C.CustomerID as pkiadminUserID, CustomerName as FirstName, CustomerName as LastName, UserName, C.Email as EmailAddress, 1 as bEnabled, c.createdDateTime as dtCreated,
			C.LastModifiedDateTime as dtUpdated ,Cmp.CompanyID
			from customers c
			inner join CustomerOffices co on co.CustomerID = c.CustomerID
			inner join offices o on o.OfficeID = co.OfficeID
			inner join Companies Cmp on cmp.CompanyID = o.CompanyID

			WHERE Username = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.strUsername#" />
		  	AND password =<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.strPassword#" />
		  	AND Cmp.CompanyCode = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.strCompanycode#" />
		  	AND isPayer = 1
		</cfquery>

		<cfif rstCurrentSiteUser.recordcount>
            <cfset session.officeid="">
            <cfset session.EmpId="">
            <cfset session.isCustomer=1>
            <cfset session.CustomerID = rstCurrentSiteUser.pkiadminUserID>
            <cfset session.CompanyID = rstCurrentSiteUser.CompanyID>
		<cfelse>
			<cfset session.isCustomer="">
			<cfset session.CustomerID = "">
		</cfif>
		<cfreturn rstCurrentSiteUser />
	</cffunction>
    
	<cffunction name="UserLoginLog" access="public" output="false" returntype="void">
		<cfargument name="strUsername" type="string" />
		<cfargument name="strPassword" type="string" />
		<cfargument name="rstCurrentSiteUser" required="yes"/>
		<cfargument name="strCompanycode" type="string" />
		<cfif (rstCurrentSiteUser.RecordCount GT 0)>
			<cfset variables.LoginSuccess = 1>
		<cfelse>
			<cfset variables.LoginSuccess = 0>
		</cfif>		
		<cfset DateLogged = Now()>
		<cfif structkeyexists(session,"EmpId") AND session.EmpId NEQ "">
			<cfquery name="newq1" datasource="#variables.dsn#">
				SELECT NAME
				from Employees
				WHERE EmployeeID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#session.EmpId#">
			</cfquery>
			<cfif newq1.recordcount>
				<cfset variables.employeename = newq1.NAME>
			<cfelse>
				<cfset variables.employeename = "">
			</cfif>
		</cfif>
		<cfquery name="qCompanyInfo" datasource="#variables.dsn#">
			select companyID, companyName from companies where CompanyCode = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.strCompanycode#">
		</cfquery>
		
		<cfif IsDefined("cookie.uniqueid")>
			<cfset variables.uniqueId = cookie.uniqueid >
		<cfelse>
			<cfset variables.uniqueId = createuuid() >
			<cfcookie expires="never" name="uniqueid" value="#variables.uniqueId#" >			
		</cfif>
		<cfquery name="addLoginLog" datasource="LoadManagerAdmin">
			Insert into UserLoginLog
			(
				LoginSuccess, UserNameEntered, UserPasswordEntered,DateLogged
				<cfif structkeyexists(session,"EmpId") AND session.EmpId NEQ "">
					,EmployeeID ,EmployeeName
				</cfif>
				<cfif structkeyexists(session,"userip") AND session.userip NEQ "">
					,PublicIP
				</cfif>
				, CompanyID, CompanyName,localip
			)
			Values
			(
				<cfqueryparam cfsqltype="cf_sql_bit" value="#variables.LoginSuccess#">,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.strUsername#">,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.strPassword#">,
				<cfqueryparam cfsqltype="cf_sql_timestamp" value="#DateLogged#">
				<cfif structkeyexists(session,"EmpId") AND session.EmpId NEQ "">
					,<cfqueryparam cfsqltype="cf_sql_varchar" value="#session.EmpId#">
					,<cfqueryparam cfsqltype="cf_sql_varchar" value="#variables.employeename#">
				</cfif>
				<cfif structkeyexists(session,"userip") AND session.userip NEQ "">
					,<cfqueryparam cfsqltype="cf_sql_varchar" value="#session.userip#">
				</cfif>
				,<cfqueryparam cfsqltype="cf_sql_varchar" value="#qCompanyInfo.companyID#">
				,<cfqueryparam cfsqltype="cf_sql_varchar" value="#qCompanyInfo.companyName#">
				,<cfqueryparam cfsqltype="cf_sql_varchar" value="#variables.uniqueId#">
			)
		</cfquery>
	</cffunction>
	
	<!---LOGOUT CODE ADDED BY FURQAN--->
    <cffunction name="logoutuser" access="public" output="false">
    
	   <!---Logout Code added for managing allowed user by Furqan--->
	        
	    <cfset todayDate = #Now()#> 
		<cfset logindate = #DateFormat(todayDate, "yyyy-mm-dd")# >
	   	<cfif structKeyExists(session, "EmpId") AND session.EmpId NEQ "">
	   		<cfquery name="newq1" datasource="#variables.dsn#" result="q">
			SELECT Employees.EmployeeID, Employees.allowed_users
			from Employees
			WHERE Employees.EmployeeID = '#session.EmpId#'
			</cfquery>

		  	<cfquery name="tupdate" datasource="#variables.dsn#">
		    UPDATE User_Track
		    set User_Track.status = 'inactive' 
		    WHERE User_Track.user_id= '#session.EmpId#' AND User_Track.ip= '#session.userip#' AND User_Track.dated= '#logindate#' AND User_Track.userpin= '#session.userpin#'
			</cfquery>
	   	</cfif>
    
        
        <!---Code Ended by Furqan--->
		<cfreturn logoutuser />
	</cffunction>
    
    <!---LOGOUT CODE ENDED--->
    
    
     <!---Time Stamping User CODE ADDED BY FURQAN--->
    <cffunction name="timeuser" access="public">
    
   <!---Time Stamp Code added for managing allowed user by Furqan--->
        <cfset todayDate = #Now()#> 
		<cfset logindate = #DateFormat(todayDate, "yyyy-mm-dd")# >
        <cfif isdefined ("session.EmpId") AND isdefined ("session.userip")>
        
        <cfquery name="timeupdate" datasource="#variables.dsn#">
            UPDATE User_Track
            set User_Track.timing = '#TimeFormat(todayDate, "HH")#' 
            WHERE User_Track.user_id= '#session.EmpId#' AND User_Track.ip= '#session.userip#' AND User_Track.dated= '#logindate#' AND User_Track.userpin= '#session.userpin#' AND User_Track.status= 'active'
        </cfquery>
        </cfif>   
          <!---<cfdump var="#timeupdate#">
          <cfabort>--->
        
        <!---Code Ended by Furqan--->
		<cfreturn timeuser />
	</cffunction>
    
    <!---User Time Check CODE ENDED--->
    
      <!--- ADDED BY FURQAN--->
    <cffunction name="UserTimeCheck" access="public">
    
		<cfset todayDate = #Now()#> 
        <cfset logindate = #DateFormat(todayDate, "yyyy-mm-dd")# >
        <cfset logintime = #TimeFormat(todayDate, "HH")#>
           
            <cfquery name="chkusers" datasource="#variables.dsn#" result="c">
                SELECT User_Track.user_id, User_Track.track_id, User_Track.ip, User_Track.dated, User_Track.timing
                FROM User_Track
                WHERE User_Track.dated = '#logindate#' AND User_Track.timing ! = #logintime# And User_Track.status = 'active'
             
            </cfquery>
        
        <cfloop query="chkusers">
        
            <cfquery name="editstatus2" datasource="#variables.dsn#" result="e">
            
                 UPDATE	User_Track
                 set 
                 User_Track.status = 'inactive'
                 WHERE User_Track.track_id = #chkusers.track_id#
                 
            </cfquery>

        </cfloop>

		<cfreturn UserTimeCheck />
	</cffunction>
    
    <!---Code Ended --->
    
    

	<!--- Function used to fetch a user from their site user id --->
	<cffunction name="getSiteUser" access="public" output="false" returntype="query">
		<cfargument name="intSiteUserID" required="yes" type="any" />
		<cfset var rstCurrentSiteUser = "" />

		<!--- RUN QUERY TO FETCH THE USER FROM THE DATABASE --->
		<cfif structKeyExists(session,'isCustomer')>
			<cfquery name="rstCurrentSiteUser" datasource="#variables.dsn#">
				SELECT CustomerID as pkiadminUserID, CustomerName as FirstName, CustomerName as LastName, UserName, Email as EmailAddress, 1 as bEnabled, createdDateTime as dtCreated, LastModifiedDateTime as dtUpdated
				FROM Customers
				WHERE CustomerID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.intSiteUserID#" />
			</cfquery>
			<cfreturn rstCurrentSiteUser />
		<cfelseif len(arguments.intSiteUserID) lt 10 >
			<cfquery name="rstCurrentSiteUser" datasource="#variables.dsn#">
				SELECT pkiadminUserID, FirstName, LastName, UserName, EmailAddress, bEnabled, dtCreated, dtUpdated
				FROM fa_AdminUsers
				WHERE fa_adminUsers.pkiadminUserID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.intSiteUserID#" />
			</cfquery>
			<cfreturn rstCurrentSiteUser />
		<cfelse>
			<cfquery name="rstCurrentSiteUser" datasource="#variables.dsn#">
				SELECT employeeid as pkiadminUserID, name as FirstName, name as LastName,loginid as UserName,emailid as EmailAddress,isActive as bEnabled,createdDateTime as dtCreated,LastModifiedDatetime as dtUpdated
				FROM employees
				WHERE employeeid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.intSiteUserID#" />
			</cfquery>
			<cfif rstCurrentSiteUser.recordcount eq 0>
				<cfquery name="rstCurrentSiteUser" datasource="LoadManagerAdmin">
					SELECT id as pkiadminUserID, name as FirstName, name as LastName,loginid as UserName,emailid as EmailAddress,1 as bEnabled,createdDateTime as dtCreated,LastModifiedDatetime as dtUpdated
					FROM GlobalUsers
					WHERE id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.intSiteUserID#" />
				</cfquery>
				<cfif rstCurrentSiteUser.recordcount eq 0>
					<cfquery name="rstCurrentSiteUser" datasource="#variables.dsn#">
						SELECT S.SystemConfigID as pkiadminUserID, S.DashboardUser as FirstName, S.DashboardUser as LastName,S.DashboardUser as UserName,C.Email as EmailAddress,1 as bEnabled,C.createdDateTime as dtCreated,C.LastModifiedDatetime as dtUpdated
						FROM SystemConfig S
						INNER JOIN Companies C ON C.CompanyID = S.CompanyID
						WHERE S.SystemConfigID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.intSiteUserID#" />
					</cfquery>
				</cfif>
			</cfif>
			<cfreturn rstCurrentSiteUser />
		</cfif>
	</cffunction>
	
	<cffunction name="checkLostPassword" access="public" output="false" returntype="query">
		<cfargument name="CompanyCode" required="yes" type="string" />
		<cfargument name="Username" required="yes" type="string" />
		<cfargument name="EmailAddress" required="yes" type="string" />
		
		<cfset var rstUserDetails = "" />

		<!--- LastModifiedDatetime 7/10/15  spericorn(cfprabhu)--->
		<cfquery name="rstUserDetails" datasource="#variables.dsn#">
			SELECT E.EmailId,E.Password,E.Name,E.SmtpAddress,E.SmtpUserName,E.SmtpPassword,E.SmtpPort,E.LoginID,E.UseSSL
			FROM Employees E
			INNER JOIN Offices O on O.OfficeID = E.OfficeID
        	INNER JOIN Companies CMP on CMP.CompanyID = O.CompanyID
			WHERE 1=1
			<cfif len(trim(arguments.EmailAddress))>
				AND E.EmailId = <cfqueryparam value='#arguments.EmailAddress#' cfsqltype="cf_sql_varchar">	
			<cfelseif len(trim(arguments.Username))>
				AND E.LoginID = <cfqueryparam value='#arguments.Username#' cfsqltype="cf_sql_varchar">	
			</cfif>
			AND CMP.CompanyCode = <cfqueryparam value="#arguments.CompanyCode#" cfsqltype="cf_sql_varchar">
		</cfquery>
		
		<cfreturn rstUserDetails />
	</cffunction>

	<cffunction name="checkCustomerLostPassword" access="public" output="false" returntype="query">
		<cfargument name="EmailAddress" required="yes" type="string" />
		<cfargument name="Username" required="yes" type="string" />
		<cfargument name="CompanyCode" required="yes" type="string" />
		<cfset var rstCustomerDetails = "" />
		<cfquery name="rstCustomerDetails" datasource="#variables.dsn#">
			SELECT C.Email,C.UserName,C.password,C.CustomerName 
			FROM Customers C
			INNER JOIN CustomerOffices CO ON CO.CustomerID = C.CustomerID
        	INNER JOIN Offices O on O.OfficeID = CO.OfficeID
        	INNER JOIN Companies CMP on CMP.CompanyID = O.CompanyID
			WHERE 1=1
			<cfif len(trim(arguments.EmailAddress))>
				AND C.Email = <cfqueryparam value='#arguments.EmailAddress#' cfsqltype="cf_sql_varchar">	
			<cfelseif len(trim(arguments.Username))>
				AND C.Username = <cfqueryparam value='#arguments.Username#' cfsqltype="cf_sql_varchar">	
			</cfif>
			AND CMP.CompanyCode = <cfqueryparam value="#arguments.CompanyCode#" cfsqltype="cf_sql_varchar">
		</cfquery>
		<cfreturn rstCustomerDetails>
	</cffunction>	

	<!--- Function used to get all the privilege ID's for a site user --->
	<cffunction name="getSiteUserPrivileges" access="public" output="false" returntype="query">
		<cfargument name="intSiteUserID" required="yes" type="numeric" />
		<cfargument name="blnIncludeGroup" required="no" type="boolean" default="false" />
		
		<cfset var rstSiteUserPrivileges = "" />

		<!--- RUN QUERY TO FETCH THE USER FROM THE DATABASE --->
		<cfquery name="rstSiteUserPrivileges" datasource="#variables.dsn#">
			SELECT DISTINCT fkiPrivilegeID
			FROM 	(
					SELECT fkiPrivilegeID
					FROM tSiteUser_Privileges
					WHERE tSiteUser_Privileges.fkiSiteUserID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.intSiteUserID#" />
					<cfif arguments.blnIncludeGroup>
						UNION
						SELECT fkiPrivilegeID
						FROM tGroup_Privileges
						INNER JOIN tSiteUser_Groups ON tSiteUser_Groups.fkiGroupID = tGroup_Privileges.fkiGroupID
						WHERE tSiteUser_Groups.fkiSiteUserID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.intSiteUserID#" />
					</cfif>
					) AS tmpPrivileges
		</cfquery>
		<cfreturn rstSiteUserPrivileges />
	</cffunction>
	
	<!--- Function used to get all the privilege ID's for a group --->
	<cffunction name="getGroupPrivileges" access="public" output="false" returntype="query">
		<cfargument name="intGroupID" required="yes" type="numeric" />
		
		<cfset var rstGroupPrivileges = "" />

		<!--- RUN QUERY TO FETCH THE USER FROM THE DATABASE --->
		<cfquery name="rstGroupPrivileges" datasource="#variables.dsn#">
			SELECT DISTINCT fkiPrivilegeID
			FROM 	(
					SELECT fkiPrivilegeID
					FROM tGroup_Privileges
					WHERE tGroup_Privileges.fkiGroupID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.intGroupID#" />
					) AS tmpPrivileges
		</cfquery>
		
		<cfreturn rstGroupPrivileges />
	</cffunction>
	
	<!---BEGIN: 766: Feature Request- Excel Export Feature --->
	<cffunction name="exportCustomersExcel" access="public" output="false">

		<!--- RUN QUERY TO FETCH THE DATA FROM VIEW 'ExportCustomers'--->
		<cfquery name="getCustomersDetails" datasource="#variables.dsn#">
			SELECT * FROM ExportCustomers WHERE CompanyID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#session.CompanyID#" />
		</cfquery>
		
		<cfscript> 
			theDir=expandPath( "../temp/" );
			if(! DirectoryExists(theDir)){
				directoryCreate(expandPath("../temp/"));
			}
			theFile=theDir & "Customers.xlsx"; 
			theSheet = SpreadsheetNew("CustomersDetails",true);
			SpreadSheetAddRow(theSheet,ArrayToList(getCustomersDetails.getColumnNames()));
			SpreadsheetformatRow(theSheet,{bold=true},1);
			SpreadsheetAddRows(theSheet,getCustomersDetails); 
		</cfscript> 
		
		<cfspreadsheet 
			action="write" 
			filename="#theFile#" 
			name="theSheet"
			sheetname="getCustomersDetails" 
			overwrite=true> 
			
		<cfheader name="Content-Disposition" value="attachment;filename=Customers.xlsx">,
		<cfcontent deleteFile = "yes" type="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" file="#theFile#"> 
		
	</cffunction>

	<cffunction name="exportCarriersDriversExcel" access="public" output="false">

		<!--- RUN QUERY TO FETCH THE DATA FROM VIEW 'ExportCarriersAndDrivers'--->
		<cfquery name="getCarriersDriversDetails" datasource="#variables.dsn#">
			SELECT * FROM ExportCarriersAndDrivers WHERE CompanyID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#session.CompanyID#" /> 
		</cfquery>
		
		<cfscript> 
			theDir=expandPath( "../temp/" );
			if(! DirectoryExists(theDir)){
				directoryCreate(expandPath("../temp/"));
			}
			theFile=theDir & "CarriersDrivers.xlsx"; 
			theSheet = SpreadsheetNew("CarriersDriversDetails",true);
			SpreadSheetAddRow(theSheet,ArrayToList(getCarriersDriversDetails.getColumnNames()));
			SpreadsheetformatRow(theSheet,{bold=true},1);
			SpreadsheetAddRows(theSheet,getCarriersDriversDetails); 
		</cfscript> 
		
		<cfspreadsheet 
			action="write" 
			filename="#theFile#" 
			name="theSheet"
			sheetname="getCarriersDriversDetails" 
			overwrite=true> 
			
		<cfheader name="Content-Disposition" value="attachment;filename=Carriers_Drivers.xlsx">,
		<cfcontent deleteFile = "yes" type="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" file="#theFile#"> 
		
	</cffunction>
	
	<cffunction name="checkExportSalesSummaryExcelCount"  access="remote" output="yes" returntype="numeric" returnformat="plain">
		
		<cfargument name="summarysummarydateFrom" required="no" type="string" />
		<cfargument name="summarydateTo" required="no" type="string" />
		<cfargument name="summarystatusFrom" required="no" type="string" />
		<cfargument name="summarystatusTo" required="no" type="string" />
		<cfargument name="summaryinvoiceDateFrom" required="no" type="string" />
		<cfargument name="summaryinvoiceDateTo" required="no" type="string" />
		<cfargument name="summarypickupDateFrom" required="no" type="string" />
		<cfargument name="summarypickupDateTo" required="no" type="string" />
		<cfargument name="summarypoFrom" required="no" type="string" />
		<cfargument name="summarypoTo" required="no" type="string" />
		<cfargument name="summarycarrierFrom" required="no" type="string" />
		<cfargument name="summarycarrierTo" required="no" type="string" />
		<cfargument name="summarycustomerFrom" required="no" type="string" />
		<cfargument name="summarycustomerTo" required="no" type="string" />
		<cfargument name="CompanyID" required="no" type="string" />
		<!--- RUN QUERY TO FETCH THE DATA FROM VIEW 'ExportSalesSummary'--->
		<cfset variables.dsn = trim(listFirst(cgi.SCRIPT_NAME,'/'))>

		<cfquery name="getSalesSummaryDetails" datasource="#variables.dsn#">
			SELECT count(*) AS rCount FROM ExportSalesSummary 
				WHERE CompanyID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.CompanyID#" />
				AND StatusText BETWEEN(SELECT StatusText FROM LoadStatusTypes WHERE StatusTypeID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.summarystatusFrom#" />) 
				AND (SELECT StatusText FROM LoadStatusTypes WHERE StatusTypeID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.summarystatusTo#" />)
				<cfif len(arguments.summarydateFrom) and len(arguments.summarydateTo)>
						AND (OrderDate BETWEEN <cfqueryparam cfsqltype="cf_sql_date" value="#arguments.summarydateFrom#" /> AND <cfqueryparam cfsqltype="cf_sql_date" value="#arguments.summarydateTo#" />)
				</cfif>
				<cfif len(arguments.summaryinvoiceDateFrom) and len(arguments.summaryinvoiceDateTo)>
					AND (InvoiceDate BETWEEN <cfqueryparam cfsqltype="cf_sql_date" value="#arguments.summaryinvoiceDateFrom#" /> AND <cfqueryparam cfsqltype="cf_sql_date" value="#arguments.summaryinvoiceDateTo#" />)
				</cfif>
				<cfif len(arguments.summarypickupDateFrom) and len(arguments.summarypickupDateTo)>
					AND (PickUpDate BETWEEN <cfqueryparam cfsqltype="cf_sql_date" value="#arguments.summarypickupDateFrom#" /> AND <cfqueryparam cfsqltype="cf_sql_date" value="#arguments.summarypickupDateTo#" />)
				</cfif>
				<cfif len(arguments.summarypoFrom) and len(arguments.summarypoTo)>
					AND (PONUMBER BETWEEN <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.summarypoFrom#" /> AND <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.summarypoTo#" />)
				</cfif>
				<cfif len(arguments.summarycarrierFrom) and len(arguments.summarycarrierTo)>
					AND (CarrierName BETWEEN <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.summarycarrierFrom#" /> AND <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.summarycarrierTo#" />)
				</cfif>
				<cfif len(arguments.summarycustomerFrom) and len(arguments.summarycustomerTo)>
					AND (CustName BETWEEN <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.summarycustomerFrom#" /> AND <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.summarycustomerTo#" />)
				</cfif>
		</cfquery>
			
		<cfreturn getSalesSummaryDetails.rCount>
	</cffunction>
	
	<cffunction name="exportSalesSummaryExcel" access="public" output="false">
		<cfargument name="dateFrom" required="no" type="string" />
		<cfargument name="dateTo" required="no" type="string" />
		<cfargument name="statusFrom" required="no" type="string" />
		<cfargument name="statusTo" required="no" type="string" />
		<cfargument name="invoiceDateFrom" required="no" type="string" />
		<cfargument name="invoiceDateTo" required="no" type="string" />
		<cfargument name="pickupDateFrom" required="no" type="string" />
		<cfargument name="pickupDateTo" required="no" type="string" />
		<cfargument name="deliveryDateFrom" required="no" type="string" />
		<cfargument name="deliveryDateTo" required="no" type="string" />
		<cfargument name="poFrom" required="no" type="string" />
		<cfargument name="poTo" required="no" type="string" />
		<cfargument name="carrierFrom" required="no" type="string" />
		<cfargument name="carrierTo" required="no" type="string" />
		<cfargument name="customerFrom" required="no" type="string" />
		<cfargument name="customerTo" required="no" type="string" />
		<cfargument name="OfficeFrom" required="no" type="string" />
		<cfargument name="OfficeTo" required="no" type="string" />
		<!--- RUN QUERY TO FETCH THE DATA FROM VIEW 'ExportSalesSummary'--->

		<cfquery name="getSalesSummaryDetails" datasource="#variables.dsn#">
			SELECT * FROM ExportSalesSummary WITH (NOLOCK)
				WHERE 
				CompanyID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#session.CompanyID#" /> AND
				StatusText BETWEEN(SELECT StatusText FROM LoadStatusTypes WHERE StatusTypeID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.statusFrom#" />) 
				AND (SELECT StatusText FROM LoadStatusTypes WHERE StatusTypeID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.statusTo#" />)
				AND OfficeCode BETWEEN <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.OfficeFrom#" /> AND <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.OfficeTo#" /> 
				<cfif len(arguments.dateFrom) and len(arguments.dateTo)>
						AND (OrderDate BETWEEN <cfqueryparam cfsqltype="cf_sql_date" value="#arguments.dateFrom#" /> AND <cfqueryparam cfsqltype="cf_sql_date" value="#arguments.dateTo#" />)
				</cfif>
				<cfif len(arguments.invoiceDateFrom) and len(arguments.invoiceDateTo)>
					AND (InvoiceDate BETWEEN <cfqueryparam cfsqltype="cf_sql_date" value="#arguments.invoiceDateFrom#" /> AND <cfqueryparam cfsqltype="cf_sql_date" value="#arguments.invoiceDateTo#" />)
				</cfif>
				<cfif len(arguments.pickupDateFrom) and len(arguments.pickupDateTo)>
					AND (PickUpDate BETWEEN <cfqueryparam cfsqltype="cf_sql_date" value="#arguments.pickupDateFrom#" /> AND <cfqueryparam cfsqltype="cf_sql_date" value="#arguments.pickupDateTo#" />)
				</cfif>
				<cfif len(arguments.deliveryDateFrom) and len(arguments.deliveryDateTo)>
					AND ([Delivery Date] BETWEEN <cfqueryparam cfsqltype="cf_sql_date" value="#arguments.deliveryDateFrom#" /> AND <cfqueryparam cfsqltype="cf_sql_date" value="#arguments.deliveryDateTo#" />)
				</cfif>
				<cfif len(arguments.poFrom) and len(arguments.poTo)>
					AND (PONUMBER BETWEEN <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.poFrom#" /> AND <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.poTo#" />)
				</cfif>
				<cfif len(arguments.carrierFrom) and len(arguments.carrierTo)>
					AND (CarrierName BETWEEN <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.carrierFrom#" /> AND <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.carrierTo#" />)
				</cfif>
				<cfif len(arguments.customerFrom) and len(arguments.customerTo)>
					AND (CustName BETWEEN <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.customerFrom#" /> AND <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.customerTo#" />)
				</cfif>
		</cfquery>

		<cfquery name="qUserDefConfig" datasource="#variables.dsn#">
			SELECT userDef1,userDef2,userDef3,userDef3,userDef4,userDef5,userDef6 FROM SystemConfig WHERE CompanyID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#session.CompanyID#" />
		</cfquery>

		<cfset var tempColumnList = "">
		<cfset var tempDirectCostDesc = structNew()>
		<cfset var tempDirectCost = structNew()>
		<cfloop query="getSalesSummaryDetails">
			<cfif listlen(getSalesSummaryDetails.DirectCostDesc)>
				<cfloop from="1" to="#listlen(getSalesSummaryDetails.DirectCostDesc)#" index="i">
					<cfif not ListFindNoCase(tempColumnList,"#i# DIRECT COST DESC")>
						<cfset tempColumnList=listAppend(tempColumnList, "#i# DIRECT COST DESC")>
						<cfset tempColumnList=listAppend(tempColumnList, "#i# DIRECT COST")>
					</cfif>
				</cfloop>
			</cfif>
			<cfset tempDirectCostDesc["#getSalesSummaryDetails.LoadNumber#"] = getSalesSummaryDetails.DirectCostDesc>
			<cfset tempDirectCost["#getSalesSummaryDetails.LoadNumber#"] = getSalesSummaryDetails.DirectCost>
		</cfloop>
		<cfset QueryDeleteColumn(getSalesSummaryDetails, "LOADSTOPID")>
		<cfset QueryDeleteColumn(getSalesSummaryDetails, "COMPANYID")>
		<cfset QueryDeleteColumn(getSalesSummaryDetails, "DIRECTCOSTDESC")>
		<cfset QueryDeleteColumn(getSalesSummaryDetails, "DIRECTCOST")>
		<cfset var ColumnList = ArrayToList(getSalesSummaryDetails.getColumnNames())>
		<cfif len(trim(tempColumnList))>
			<cfset ColumnList=ListInsertAt(ColumnList,10,"#tempColumnList#")>
		</cfif>
		<cfset ColumnListNew = ColumnList>
		<cfif len(trim(qUserDefConfig.userDef1))>
			<cfset ColumnListNew = replaceNoCase(ColumnListNew, "userDef1", qUserDefConfig.userDef1)>
		</cfif>
		<cfif len(trim(qUserDefConfig.userDef2))>
			<cfset ColumnListNew = replaceNoCase(ColumnListNew, "userDef2", qUserDefConfig.userDef2)>
		</cfif>
		<cfif len(trim(qUserDefConfig.userDef3))>
			<cfset ColumnListNew = replaceNoCase(ColumnListNew, "userDef3", qUserDefConfig.userDef3)>
		</cfif>
		<cfif len(trim(qUserDefConfig.userDef4))>
			<cfset ColumnListNew = replaceNoCase(ColumnListNew, "userDef4", qUserDefConfig.userDef4)>
		</cfif>
		<cfif len(trim(qUserDefConfig.userDef5))>
			<cfset ColumnListNew = replaceNoCase(ColumnListNew, "userDef5", qUserDefConfig.userDef5)>
		</cfif>
		<cfif len(trim(qUserDefConfig.userDef6))>
			<cfset ColumnListNew = replaceNoCase(ColumnListNew, "userDef6", qUserDefConfig.userDef6)>
		</cfif>
		<cfscript> 
			theDir=expandPath( "../temp/" );
			if(! DirectoryExists(theDir)){
				directoryCreate(expandPath("../temp/"));
			}
			theFile=theDir & "SalesSummary.xlsx"; 
			theSheet = SpreadsheetNew("SalesSummaryDetailsData",true);
			SpreadSheetAddRow(theSheet,ColumnListNew);
			SpreadsheetformatRow(theSheet,{bold=true},1);

			cfloop(query = getSalesSummaryDetails){
				for(col in ColumnList){
					comindx = 1;
					if(not findNoCase('DIRECT COST', col)){
						if(listFindNoCase("ORDERDATE,INVOICEDATE,PICKUPDATE,DELIVERY DATE", col)){
							SpreadsheetSetCellValue(theSheet, getSalesSummaryDetails[col][currentrow], getSalesSummaryDetails.currentrow+1, ListFindNoCase(ColumnList, col),'date');
						}else{
							SpreadsheetSetCellValue(theSheet, getSalesSummaryDetails[col][currentrow], getSalesSummaryDetails.currentrow+1, ListFindNoCase(ColumnList, col));
						}
					}else{
						for(com in tempDirectCostDesc["#getSalesSummaryDetails.LoadNumber#"]){
							SpreadsheetSetCellValue(theSheet, com, getSalesSummaryDetails.currentrow+1, ListFindNoCase(ColumnList, '#comindx# DIRECT COST DESC'));
							SpreadsheetSetCellValue(theSheet, listGetAt(tempDirectCost["#getSalesSummaryDetails.LoadNumber#"], comindx), getSalesSummaryDetails.currentrow+1, ListFindNoCase(ColumnList, '#comindx# DIRECT COST'));
							comindx++;
						}
					}
				}
			}
		</cfscript>
		
		<cfspreadsheet 
			action="write" 
			filename="#theFile#" 
			name="theSheet"
			sheetname="getSalesSummaryDetails" 
			overwrite=true> 
			
		<cfheader name="Content-Disposition" value="attachment;filename=SalesSummary.xlsx">,
		<cfcontent deleteFile = "yes" type="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" file="#theFile#"> 
		
	</cffunction>
	
	<cffunction name="exportSalesDetailExcel" access="public" output="false">
		<cfargument name="dateFrom" required="no" type="string" />
		<cfargument name="dateTo" required="no" type="string" />
		<cfargument name="statusFrom" required="no" type="string" />
		<cfargument name="statusTo" required="no" type="string" />
		<cfargument name="invoiceDateFrom" required="no" type="string" />
		<cfargument name="invoiceDateTo" required="no" type="string" />
		<cfargument name="pickupDateFrom" required="no" type="string" />
		<cfargument name="pickupDateTo" required="no" type="string" />
		<cfargument name="deliveryDateFrom" required="no" type="string" />
		<cfargument name="deliveryDateTo" required="no" type="string" />
		<cfargument name="poFrom" required="no" type="string" />
		<cfargument name="poTo" required="no" type="string" />
		<cfargument name="carrierFrom" required="no" type="string" />
		<cfargument name="carrierTo" required="no" type="string" />
		<cfargument name="customerFrom" required="no" type="string" />
		<cfargument name="customerTo" required="no" type="string" />
		<cfargument name="OfficeFrom" required="no" type="string" />
		<cfargument name="OfficeTo" required="no" type="string" />
		<!--- RUN QUERY TO FETCH THE DATA FROM VIEW 'ExportSalesDetail'--->
		<cfquery name="getSalesDetails" datasource="#variables.dsn#">
			SELECT * FROM ExportSalesDetail
				WHERE 
				CompanyID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#session.CompanyID#" /> AND 
				StatusText BETWEEN (SELECT StatusText FROM LoadStatusTypes WHERE StatusTypeID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.statusFrom#" />) 
				AND (SELECT StatusText FROM LoadStatusTypes WHERE StatusTypeID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.statusTo#" />)
				AND OfficeCode BETWEEN <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.OfficeFrom#" /> AND <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.OfficeTo#" />
				<cfif len(arguments.dateFrom) and len(arguments.dateTo)>
					AND (OrderDate BETWEEN <cfqueryparam cfsqltype="cf_sql_date" value="#arguments.dateFrom#" /> AND <cfqueryparam cfsqltype="cf_sql_date" value="#arguments.dateTo#" />)
				</cfif>
				<cfif len(arguments.invoiceDateFrom) and len(arguments.invoiceDateTo)>
					AND (InvoiceDate BETWEEN <cfqueryparam cfsqltype="cf_sql_date" value="#arguments.invoiceDateFrom#" /> AND <cfqueryparam cfsqltype="cf_sql_date" value="#arguments.invoiceDateTo#" />)
				</cfif>
				<cfif len(arguments.pickupDateFrom) and len(arguments.pickupDateTo)>
					AND (PickUpDate BETWEEN <cfqueryparam cfsqltype="cf_sql_date" value="#arguments.pickupDateFrom#" /> AND <cfqueryparam cfsqltype="cf_sql_date" value="#arguments.pickupDateTo#" />)
				</cfif>
				<cfif len(arguments.deliveryDateFrom) and len(arguments.deliveryDateTo)>
					AND ([Delivery Date] BETWEEN <cfqueryparam cfsqltype="cf_sql_date" value="#arguments.deliveryDateFrom#" /> AND <cfqueryparam cfsqltype="cf_sql_date" value="#arguments.deliveryDateTo#" />)
				</cfif>
				<cfif len(arguments.poFrom) and len(arguments.poTo)>
					AND (PONUMBER BETWEEN <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.poFrom#" /> AND <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.poTo#" />)
				</cfif>
				<cfif len(arguments.carrierFrom) and len(arguments.carrierTo)>
					AND (CarrierName BETWEEN <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.carrierFrom#" /> AND <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.carrierTo#" />)
				</cfif>
				<cfif len(arguments.customerFrom) and len(arguments.customerTo)>
					AND (CustName BETWEEN <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.customerFrom#" /> AND <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.customerTo#" />)
				</cfif>
		</cfquery>
		<cfset QueryDeleteColumn(getSalesDetails, "COMPANYID")>
		<cfset QueryDeleteColumn(getSalesDetails, "OFFICECODE")>
		<cfscript> 
			theDir=expandPath( "../temp/" );
			if(! DirectoryExists(theDir)){
				directoryCreate(expandPath("../temp/"));
			}
			theFile=theDir & "Sales_Details.xlsx"; 
			theSheet = SpreadsheetNew("SalesDetails",true);
			SpreadSheetAddRow(theSheet,ArrayToList(getSalesDetails.getColumnNames()));
			SpreadsheetformatRow(theSheet,{bold=true},1);
			SpreadsheetAddRows(theSheet,getSalesDetails); 
		</cfscript> 
		
		<cfspreadsheet 
			action="write" 
			filename="#theFile#" 
			name="theSheet"
			sheetname="getSalesDetails" 
			overwrite=true> 
			
		<cfheader name="Content-Disposition" value="attachment;filename=Sales_Details.xlsx">,
		<cfcontent deleteFile = "yes" type="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" file="#theFile#"> 
		
	</cffunction>
	<!---END: 766: Feature Request- Excel Export Feature --->

	<cffunction name="export1099csv" access="public" output="false">
		<cfargument name="Year" required="no" type="string" />

		<cfstoredproc procedure="spForm1099" datasource="#variables.dsn#">
			<cfprocparam value="#session.companyID#" cfsqltype="cf_sql_varchar">
			<cfprocparam value="#arguments.year#" cfsqltype="cf_sql_varchar">
			<cfprocresult name="qForm1099">
		</cfstoredproc>

		<cfscript> 
			theDir=expandPath( "../temp/" );
			if(! DirectoryExists(theDir)){
				directoryCreate(expandPath("../temp/"));
			}
			theFile=theDir & "Export1099.csv"; 
			theSheet = SpreadsheetNew("Export1099");
			SpreadSheetAddRow(theSheet,ArrayToList(qForm1099.getColumnNames()));
			SpreadsheetformatRow(theSheet,{bold=true},1);
			SpreadsheetAddRows(theSheet,qForm1099); 
			SpreadsheetFormatCell(theSheet, {alignment='right'}, 1, 9);
			for(i=1;i<=qForm1099.recordcount;i++){
				local.TotalCarrierCharges = SpreadsheetGetCellValue(theSheet, i+1, 9);
				SpreadsheetSetCellValue(theSheet, dollarFormat(local.TotalCarrierCharges), i+1, 9);
				SpreadsheetFormatCell(theSheet, {alignment='right',bold=false}, i+1, 9);
			}
		</cfscript> 
		
		<cfspreadsheet 
			action="write" 
			filename="#theFile#" 
			name="theSheet"
			sheetname="Export1099" 
			overwrite=true> 
			
		<cfheader name="Content-Disposition" value="attachment;filename=Export1099.csv">,
		<cfcontent deleteFile = "yes" type="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" file="#theFile#"> 
	</cffunction>

	<cffunction name="checkLostCompanyCode" access="public" output="false" returntype="query">
		<cfargument name="CompanyName" required="yes" type="string" />
		<cfargument name="EmailAddress" required="yes" type="string" />
		
		<cfset var rstUserDetails = "" />

		<cfquery name="rstUserDetails" datasource="#variables.dsn#">
			SELECT C.CompanyCode
			FROM Companies C
			WHERE C.CompanyName = <cfqueryparam value="#arguments.CompanyName#" cfsqltype="cf_sql_varchar">
			AND C.Email = <cfqueryparam value="#arguments.EmailAddress#" cfsqltype="cf_sql_varchar">
		</cfquery>
		
		<cfreturn rstUserDetails />
	</cffunction>

	<cffunction name="checkLostUserName" access="public" output="false" returntype="query">
		<cfargument name="CompanyCode" required="yes" type="string" />
		<cfargument name="Username" required="yes" type="string" />
		<cfargument name="EmailAddress" required="yes" type="string" />
		
		<cfset var rstUserDetails = "" />

		<cfquery name="rstUserDetails" datasource="#variables.dsn#">
			SELECT E.EmailId,E.LoginID,E.Password
			FROM Employees E
			INNER JOIN Offices O on  O.OfficeID = E.OfficeID
        	INNER JOIN Companies CMP on CMP.CompanyID = O.CompanyID
			WHERE E.EmailId = <cfqueryparam value='#arguments.EmailAddress#' cfsqltype="cf_sql_varchar">	
			AND E.Name = <cfqueryparam value='#arguments.Username#' cfsqltype="cf_sql_varchar">	
			AND CMP.CompanyCode = <cfqueryparam value="#arguments.CompanyCode#" cfsqltype="cf_sql_varchar">
		</cfquery>
		
		<cfreturn rstUserDetails />
	</cffunction>
</cfcomponent>