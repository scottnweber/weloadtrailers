<cftry>
	<cftransaction>
		<cfset variables.dsn = "weloadtrailers">

		<cfquery name="getAllStop" datasource="#variables.dsn#">
		   select loadstopid from loadstops where loadid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#url.delId#">
		</cfquery>

		<cfquery name="getLoadDetailsForLog" datasource="#variables.dsn#">
			select CustName,TotalCustomerCharges,NewPickupDate,LoadNumber
			,(select top 1 CustName from loadstops where loadid= <cfqueryparam cfsqltype="cf_sql_varchar" value="#url.delId#"> order by stopno,loadtype) as PickupName
			,NewDeliveryDate
			,(select top 1 CustName from loadstops where loadid= <cfqueryparam cfsqltype="cf_sql_varchar" value="#url.delId#"> order by stopno desc,loadtype desc) as DeliveryName
			,(SELECT StatusText FROM LoadStatusTypes WHERE StatusTypeID = loads.StatusTypeID) AS LoadStatus
			,orderDate
			from loads where loadid= <cfqueryparam cfsqltype="cf_sql_varchar" value="#url.delId#">
		</cfquery>

		<cfset LoadStopIDList=valueList(getAllStop.loadstopid,",")>

		<cfif len(trim(LoadStopIDList))>
			<cfquery name="deleteAllStopItems" datasource="#variables.dsn#">
			   delete from LoadStopCommodities where loadstopid in (<cfqueryparam value="#LoadStopIDList#" cfsqltype="CF_SQL_VARCHAR" list="yes" />)
			</cfquery>

			<cfquery name="deleteLoadStopIntermodalImport" datasource="#variables.dsn#">
			   delete from LoadStopIntermodalImport where loadstopid in (<cfqueryparam value="#LoadStopIDList#" cfsqltype="CF_SQL_VARCHAR" list="yes" />)
			</cfquery>

			<cfquery name="deleteLoadStopIntermodalExport" datasource="#variables.dsn#">
			   delete from LoadStopIntermodalExport where loadstopid in (<cfqueryparam value="#LoadStopIDList#" cfsqltype="CF_SQL_VARCHAR" list="yes" />)
			</cfquery>

			<cfquery name="deleteLoadStopCargoPickupAddress" datasource="#variables.dsn#">
			   delete from LoadStopCargoPickupAddress where loadstopid in (<cfqueryparam value="#LoadStopIDList#" cfsqltype="CF_SQL_VARCHAR" list="yes" />)
			</cfquery>

			<cfquery name="deleteLoadStopCargoDeliveryAddress" datasource="#variables.dsn#">
			   delete from LoadStopCargoDeliveryAddress where loadstopid in (<cfqueryparam value="#LoadStopIDList#" cfsqltype="CF_SQL_VARCHAR" list="yes" />)
			</cfquery>

			<cfquery name="deleteLoadStopEmptyReturnAddress" datasource="#variables.dsn#">
			   delete from LoadStopEmptyReturnAddress where loadstopid in (<cfqueryparam value="#LoadStopIDList#" cfsqltype="CF_SQL_VARCHAR" list="yes" />)
			</cfquery>

			<cfquery name="deleteLoadStopEmptyPickupAddress" datasource="#variables.dsn#">
			   delete from LoadStopEmptyPickupAddress where loadstopid in (<cfqueryparam value="#LoadStopIDList#" cfsqltype="CF_SQL_VARCHAR" list="yes" />)
			</cfquery>

			<cfquery name="deleteLoadStopLoadingAddress" datasource="#variables.dsn#">
			   delete from LoadStopLoadingAddress where loadstopid in (<cfqueryparam value="#LoadStopIDList#" cfsqltype="CF_SQL_VARCHAR" list="yes" />)
			</cfquery>

			<cfquery name="deleteLoadStopReturnAddress" datasource="#variables.dsn#">
			   delete from LoadStopReturnAddress where loadstopid in (<cfqueryparam value="#LoadStopIDList#" cfsqltype="CF_SQL_VARCHAR" list="yes" />)
			</cfquery>
		</cfif>
		<cfquery name="deleteAllStop" datasource="#variables.dsn#">
		   delete from loadstops where loadid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#url.delId#">
		</cfquery>

		<cfquery name="deleteLoadGPSTracking" datasource="#variables.dsn#">
		   delete from LoadGPSTracking where loadid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#url.delId#">
		</cfquery>

		<cfquery name="deleteMobileAppAccessLogs" datasource="#variables.dsn#">
		   delete from MobileAppAccessLogs where loadid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#url.delId#">
		</cfquery>

		<cfquery name="deleteLoad" datasource="#variables.dsn#">
		   delete from Loads where loadid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#url.delId#">
		</cfquery>

		<cfset local.empid = "D974BDF6-1B92-49A6-A98F-38E377DF9BE3">
		<cfset local.adminUserName = "LoadBoard">
		
		<cfset oldValue = "Customer Name:#getLoadDetailsForLog.custName#, TotalCustomerCharges:#getLoadDetailsForLog.TotalCustomerCharges#, Pickup Date:#dateformat(getLoadDetailsForLog.NewPickupDate,'mm/dd/yyyy')#, Pickup Name:#getLoadDetailsForLog.PickupName#, Delivery Date:#dateformat(getLoadDetailsForLog.NewDeliveryDate,'mm/dd/yyyy')#, Delivery Name:#getLoadDetailsForLog.DeliveryName#">
		
		<cfquery name="insertLoadLog" datasource="#variables.dsn#" result="qResult">
			INSERT INTO LoadLogs (
						LoadID,
						LoadNumber,
						FieldLabel,
						oldValue,
						NewValue,
						UpdatedByUserID,
						UpdatedBy,
						UpdatedTimestamp
						,UpdatedByIP
					)
				values
					(
						<cfqueryparam value="#url.delId#" cfsqltype="cf_sql_nvarchar">,
						<cfqueryparam value="#getLoadDetailsForLog.LoadNumber#" cfsqltype="cf_sql_bigint">,
						<cfqueryparam value="Load Deleted" cfsqltype="cf_sql_nvarchar">,
						<cfqueryparam value="#oldValue#" cfsqltype="cf_sql_nvarchar">,
						<cfqueryparam value="Load Deleted" cfsqltype="cf_sql_nvarchar">,
						<cfqueryparam value="#local.empid#" cfsqltype="cf_sql_nvarchar">,
						<cfqueryparam value="#local.adminUserName#" cfsqltype="cf_sql_nvarchar">,
						<cfqueryparam value="#Now()#" cfsqltype="cf_sql_timestamp">
						,<cfqueryparam cfsqltype="cf_sql_varchar" value="#cgi.REMOTE_ADDR#">
					)
		</cfquery>
	</cftransaction>
	<cfset delMsg = "Load have been deleted successfully.">
	<cfcatch>
		<cfset delMsg =  "Unable to delete the load.">
	</cfcatch>
</cftry>