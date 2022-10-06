<cfcomponent output="true">
	<cffunction name="init" access="public" output="false" returntype="void">
		<cfargument name="dsn" type="string" required="yes" />
		<cfset variables.dsn = Application.dsn />
	</cffunction>

	<cffunction name="createAlert" access="public" returntype="void">
		<cfargument name="CreatedBy" type="string" required="yes" />
		<cfargument name="CompanyID" type="string" required="yes" />
		<cfargument name="Description" type="string" required="yes" />
		<cfargument name="AssignedType" type="string" required="yes" />
		<cfargument name="AssignedTo" type="string" required="yes" />
		<cfargument name="Type" type="string" required="yes" />
		<cfargument name="TypeID" type="string" required="yes" />
		<cfargument name="Reference" type="string" required="yes" />
		<cfif arguments.AssignedType EQ 'Role'>
			<cfquery name="qGetRole" datasource="#Application.dsn#">
				SELECT RoleID FROM Roles WHERE CompanyID = <cfqueryparam value="#arguments.CompanyID#" cfsqltype="cf_sql_varchar"> AND RoleValue = <cfqueryparam value="#arguments.AssignedTo#" cfsqltype="cf_sql_varchar">
			</cfquery>
			<cfset arguments.AssignedTo = qGetRole.RoleID>
		</cfif>

		<cfquery name="qInsAlert" datasource="#Application.dsn#">
			INSERT INTO Alerts(CreatedBy,CompanyID,Description,AssignedType,AssignedTo,Type,TypeID,Reference)
			VALUES(
				<cfqueryparam value="#arguments.CreatedBy#" cfsqltype="cf_sql_varchar">
				,<cfqueryparam value="#arguments.CompanyID#" cfsqltype="cf_sql_varchar">
				,<cfqueryparam value="#arguments.Description#" cfsqltype="cf_sql_varchar">
				,<cfqueryparam value="#arguments.AssignedType#" cfsqltype="cf_sql_varchar">
				,<cfqueryparam value="#arguments.AssignedTo#" cfsqltype="cf_sql_varchar">
				,<cfqueryparam value="#arguments.Type#" cfsqltype="cf_sql_varchar">
				,<cfqueryparam value="#arguments.TypeID#" cfsqltype="cf_sql_varchar" null="#not len(arguments.TypeID)#">
				,<cfqueryparam value="#arguments.Reference#" cfsqltype="cf_sql_varchar">
				)
		</cfquery>

		<cfif arguments.Type EQ 'Load'>
			<cfquery name="qGetStatus" datasource="#Application.dsn#">
				SELECT StatusTypeID FROM LoadStatusTypes WHERE StatusText='1. ACTIVE' AND CompanyID = <cfqueryparam value="#arguments.CompanyID#" cfsqltype="cf_sql_varchar">
			</cfquery>
			<cfquery name="qUpdLoad" datasource="#Application.dsn#">
				UPDATE Loads SET RateApprovalNeeded = 1,MarginApproved=0 
				,StatusTypeID  = <cfqueryparam value="#qGetStatus.StatusTypeID#" cfsqltype="cf_sql_varchar">
				WHERE LoadID = <cfqueryparam value="#arguments.TypeID#" cfsqltype="cf_sql_varchar">
			</cfquery>
		</cfif>
	</cffunction>

	<cffunction name="getAlertCount" access="public" returntype="numeric">
		<cfquery name="qGetAlert" datasource="#Application.dsn#">
			SELECT A.AlertID FROM Employees E
			INNER JOIN Alerts A ON E.EmployeeID = A.AssignedTo AND A.AssignedType='User'
			WHERE E.EmployeeID =  <cfqueryparam value="#session.EmpID#" cfsqltype="cf_sql_varchar">
			AND A.CompanyID = <cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar">
			AND A.Approved = 0
			UNION
			SELECT A.AlertID FROM Employees E
			INNER JOIN Alerts A ON E.RoleID = A.AssignedTo AND A.AssignedType='Role'
			WHERE E.EmployeeID = <cfqueryparam value="#session.EmpID#" cfsqltype="cf_sql_varchar">
			AND A.CompanyID = <cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar">
			AND A.Approved = 0
			UNION
			SELECT A.AlertID FROM Employees E
			INNER JOIN Roles R ON R.RoleID = E.RoleID 
			INNER JOIN Alerts A ON A.AssignedType='Parameter' AND R.userRights LIKE '%'+AssignedTo+'%'
			WHERE E.EmployeeID = <cfqueryparam value="#session.EmpID#" cfsqltype="cf_sql_varchar">
			AND A.CompanyID = <cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar">
			AND A.Approved = 0
		</cfquery>

		<cfreturn qGetAlert.RecordCount>
	</cffunction>

	<cffunction name="getAlerts" access="public" returntype="query">
		<cfargument name="searchText" required="no" type="any" default="">
	    <cfargument name="pageNo" required="no" type="any" default="1">
	    <cfargument name="sortorder" required="no" type="any" default="ASC">
	    <cfargument name="sortby" required="no" type="any" default="CreatedDateTime">

		<cfquery name="qGetAlert" datasource="#Application.dsn#">
			BEGIN WITH page AS 
	    	(
			SELECT *,ROW_NUMBER() OVER (ORDER BY #arguments.sortby# #arguments.sortorder#) AS Row FROM vwAlertList
			WHERE EmployeeID =  <cfqueryparam value="#session.EmpID#" cfsqltype="cf_sql_varchar">
			AND CompanyID = <cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar">
			AND Approved = 0

			<cfif structKeyExists(arguments, "searchText") and len(trim(arguments.searchText))>
			    AND (ClaimedBy LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#arguments.searchText#%">
			    OR Type LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#arguments.searchText#%">
			    OR Reference LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#arguments.searchText#%">
			    OR Description LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#arguments.searchText#%">
			    OR CreatedBy LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#arguments.searchText#%">
			    OR OpenTo LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#arguments.searchText#%">)
		    </cfif>


			)
		    SELECT
		      *,(select (max(row)/30) + (CASE WHEN max(row)%30 <> 0 THEN 1 ELSE 0 END)  FROM page) AS TotalPages 
		    FROM page
		    WHERE Row BETWEEN (<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.pageNo#"> - 1) * 30 + 1 AND <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.pageNo#"> * 30
		    END
		</cfquery>
		<cfreturn qGetAlert>
	</cffunction>

	<cffunction name="getAlertHistory" access="public" returntype="query">
		<cfargument name="searchText" required="no" type="any" default="">
	    <cfargument name="pageNo" required="no" type="any" default="1">
	    <cfargument name="sortorder" required="no" type="any" default="DESC">
	    <cfargument name="sortby" required="no" type="any" default="A.CreatedDateTime">

		<cfquery name="qGetAlertHistory" datasource="#Application.dsn#">
			BEGIN WITH page AS 
	    	(
			SELECT 
			E.Name AS ClaimedBy,
			A.Type,
			A.Reference,
			A.Description,
			A.CreatedDateTime,
			C.Name AS CreatedBy,
			CASE WHEN A.AssignedType ='Role' THEN R.RoleValue ELSE CASE WHEN A.AssignedType = 'User' THEN U.Name ELSE A.AssignedTo END END AS OpenTo,
			ROW_NUMBER() OVER (ORDER BY #arguments.sortby# #arguments.sortorder#) AS Row 
			FROM Alerts A
			LEFT JOIN Employees E ON E.EmployeeID = A.ClaimedByUserID
			LEFT JOIN Employees C ON E.EmployeeID = A.CreatedBy


			LEFT JOIN Roles R ON CAST(R.RoleID AS VARCHAR(10)) = A.AssignedTo AND A.AssignedType ='Role'
			LEFT JOIN Employees U ON CAST(U.EmployeeID AS VARCHAR(36)) = A.AssignedTo AND A.AssignedType ='User'

			WHERE A.CompanyID = <cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar">

			<cfif structKeyExists(arguments, "searchText") and len(trim(arguments.searchText))>
			    AND (E.Name LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#arguments.searchText#%">
			    OR Type LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#arguments.searchText#%">
			    OR Reference LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#arguments.searchText#%">
			    OR Description LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#arguments.searchText#%">
			    OR C.Name LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#arguments.searchText#%">)
		    </cfif>


			)
		    SELECT
		      *,(select (max(row)/30) + (CASE WHEN max(row)%30 <> 0 THEN 1 ELSE 0 END)  FROM page) AS TotalPages 
		    FROM page
		    WHERE Row BETWEEN (<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.pageNo#"> - 1) * 30 + 1 AND <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.pageNo#"> * 30
		    END
		</cfquery>
		<cfreturn qGetAlertHistory>
	</cffunction>

	<cffunction name="getAlertDetail" access="public" returntype="query">
		<cfargument name="AlertID" type="string" required="yes" />
		<cfquery name="qGetAlert" datasource="#Application.dsn#">
			SELECT A.*,
			ISNULL(L.TotalCarrierCharges,0) AS TotalCarrierCharges,
			CASE WHEN ISNULL(L.TotalCustomerCharges,0) = 0 THEN 0 ELSE (((L.TotalCustomerCharges-L.TotalCarrierCharges) * 100)/L.TotalCustomerCharges)-ISNULL(L.FF,0) END AS Profit,
			ISNULL(L.TotalCustomerCharges,0) AS TotalCustomerCharges,
			CASE WHEN ISNULL(L.FF,0) = 0 THEN 0 ELSE (L.FF/100)*ISNULL(L.TotalCustomerCharges,0) END AS FactoringFee,
			E.Name AS CreatedUser,
			E1.Name AS LockedUser,
			E2.Name AS ClaimedBy,
			C.CarrierName
			FROM Alerts A 
			LEFT JOIN Loads L ON A.TypeID = L.LoadID AND A.Type = 'Load'
			LEFT JOIN Carriers C ON A.TypeID = C.CarrierID AND A.Type = 'Carrier'
			LEFT JOIN Employees E On E.EmployeeID = A.CreatedBy
			LEFT JOIN Employees E1 ON E1.EmployeeID = A.InUseBy
			LEFT JOIN Employees E2 ON E2.EmployeeID = A.ClaimedByUserID
			WHERE A.AlertID =  <cfqueryparam value="#arguments.AlertID#" cfsqltype="cf_sql_varchar">
			AND A.CompanyID = <cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar">
		</cfquery>
		<cfreturn qGetAlert>
	</cffunction>

	<cffunction name="claimAlert" access="public" returntype="void">
		<cfargument name="AlertID" type="string" required="yes" />
		<cfargument name="DueDate" type="string" required="yes" />
		<cfquery name="qClaimAlert" datasource="#Application.dsn#">
			UPDATE Alerts SET ClaimedByUserID = <cfqueryparam value="#session.EmpID#" cfsqltype="cf_sql_varchar">
			<cfif len(trim(arguments.DueDate))>
				,DueDate = <cfqueryparam value="#arguments.DueDate#" cfsqltype="cf_sql_date">
			</cfif>
			WHERE AlertID =  <cfqueryparam value="#arguments.AlertID#" cfsqltype="cf_sql_varchar">
			AND CompanyID = <cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar">
		</cfquery>
	</cffunction>

	<cffunction name="lockAlertForCurrentUser" access="public" returntype="void">
		<cfargument name="AlertID" type="string" required="yes" />
		<cfquery name="qUpdAlert" datasource="#application.dsn#">
			UPDATE Alerts SET InUseBy = <cfqueryparam value="#session.EmpID#" cfsqltype="cf_sql_varchar">
			WHERE AlertID =  <cfqueryparam value="#arguments.AlertID#" cfsqltype="cf_sql_varchar">
		</cfquery>
	</cffunction>

	<cffunction name="unLockAlertForCurrentUser" access="remote" returntype="void">
		<cfargument name="AlertID" type="string" required="no" default=""/>
		<cfargument name="EmpID" type="string" required="no" default=""/>

		<cfif len(trim(arguments.AlertID)) OR len(trim(arguments.EmpID))>
			<cfset variables.dsn = trim(listFirst(cgi.SCRIPT_NAME,'/'))>
			<cfquery name="qUpdAlert" datasource="#variables.dsn#">
				UPDATE Alerts SET InUseBy = NULL
				<cfif len(trim(arguments.AlertID))>
					WHERE AlertID =  <cfqueryparam value="#arguments.AlertID#" cfsqltype="cf_sql_varchar">
				<cfelseif len(trim(arguments.EmpID))>
					WHERE InUseBy = <cfqueryparam value="#arguments.EmpID#" cfsqltype="cf_sql_varchar">
				</cfif>
			</cfquery>
		</cfif>
	</cffunction>

	<cffunction name="deleteAlert" access="public" returntype="void">
		<cfargument name="TypeID" type="string" required="yes" />

		<cfquery name="qDelAlert" datasource="#application.dsn#">
			DELETE FROM Alerts WHERE TypeID = <cfqueryparam value="#arguments.TypeID#" cfsqltype="cf_sql_varchar">
		</cfquery>

		<cfquery name="qUpdLoad" datasource="#application.dsn#">
			UPDATE Loads SET RateApprovalNeeded = 0
			WHERE LoadID = <cfqueryparam value="#arguments.TypeID#" cfsqltype="cf_sql_varchar">
		</cfquery>
	</cffunction>

	<cffunction name="ApproveCarrierRate" access="remote" returntype="void">
		<cfargument name="LoadID" type="string" required="yes" />


		<cfquery name="qgetLoad" datasource="#application.dsn#">
			SELECT L.LoadNumber,A.CreatedBy AS AssignedTo
			,CASE WHEN ISNULL(L.TotalCustomerCharges,0) = 0 THEN 0 ELSE ((L.TotalCustomerCharges-L.TotalCarrierCharges-(L.TotalCustomerCharges*ff/100)) * 100)/L.TotalCustomerCharges END AS Profit
			FROM Loads L
			INNER JOIN Alerts A ON A.TypeID = L.LoadID
			WHERE L.LoadID = <cfqueryparam value="#arguments.LoadID#" cfsqltype="cf_sql_varchar">
		</cfquery>

		<cfquery name="qUpdLoad" datasource="#application.dsn#">
			UPDATE Loads SET RateApprovalNeeded = 0,MarginApproved=1,LastApprovedRate=<cfqueryparam value="#qgetLoad.Profit#" cfsqltype="cf_sql_varchar">
			WHERE LoadID = <cfqueryparam value="#arguments.LoadID#" cfsqltype="cf_sql_varchar">
		</cfquery>

		<cfquery name="qUpdAlert" datasource="#application.dsn#">
			UPDATE Alerts SET Approved = 1
			WHERE TypeID = <cfqueryparam value="#arguments.LoadID#" cfsqltype="cf_sql_varchar">
		</cfquery>

		<cfif qgetLoad.RecordCount>
			<cfinvoke method="createAlert" CreatedBy="#session.empid#" CompanyID="#session.CompanyID#" Description="Carrier Rate Approved" AssignedType="User" AssignedTo="#qgetLoad.AssignedTo#" Type="Message" TypeId="" Reference="#qgetLoad.LoadNumber#"/>
		</cfif>
	</cffunction>

	<cffunction name="AcknowledgeAlert" access="remote" returntype="void">
		<cfargument name="AlertID" type="string" required="yes" />
		<cfquery name="qUpdAlert" datasource="#application.dsn#">
			UPDATE Alerts SET Approved = 1
			WHERE AlertID = <cfqueryparam value="#arguments.AlertID#" cfsqltype="cf_sql_varchar">
		</cfquery>
	</cffunction>

	<cffunction name="unClaimAlert" access="public" returntype="void">
		<cfargument name="AlertID" type="string" required="yes" />
		<cfquery name="qClaimAlert" datasource="#Application.dsn#">
			UPDATE Alerts SET ClaimedByUserID = NULL
			WHERE AlertID =  <cfqueryparam value="#arguments.AlertID#" cfsqltype="cf_sql_varchar">
			AND CompanyID = <cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar">
		</cfquery>
	</cffunction>
</cfcomponent>