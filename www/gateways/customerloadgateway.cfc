<cfcomponent output="false">
	<cffunction name="init" access="public" output="false" returntype="void">
		<cfargument name="dsn" type="string" required="yes" />
		<cfset variables.dsn = Application.dsn />
	</cffunction>

	<cffunction name="GetCustomerLoad" access="public" returntype="query">
		<cfargument name="LoadID" type="string" required="yes" />

		<CFSTOREDPROC PROCEDURE="USP_GetCustomerLoad" DATASOURCE="#variables.dsn#">
			<CFPROCPARAM VALUE="#arguments.LoadID#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#session.CustomerID#" cfsqltype="CF_SQL_VARCHAR">
			<cfprocresult name="qLoad">
		</CFSTOREDPROC>

		<cfreturn qLoad>
	</cffunction>
	
	<cffunction name="GetCustomerLoadCopy" access="public" returntype="query">
		<cfargument name="LoadID" type="string" required="yes" />

		<CFSTOREDPROC PROCEDURE="USP_GetCustomerLoadCopy" DATASOURCE="#variables.dsn#">
			<CFPROCPARAM VALUE="#arguments.LoadID#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#session.CompanyID#" cfsqltype="CF_SQL_VARCHAR">
			<cfprocresult name="qLoad">
		</CFSTOREDPROC>

		<cfreturn qLoad>
	</cffunction>

	<cffunction name="AddCustomerLoad" access="public" returntype="string">
		<cfargument name="frmStruct" type="struct" required="no" />
    	<cftransaction>
    		<cfset var customerCommoditiesCharges = ReplaceNoCase(ReplaceNoCase(arguments.frmstruct.customerCommoditiesCharges,'$','','ALL'),',','','ALL')>

    		<CFSTOREDPROC PROCEDURE="USP_InsertCustomerLoad" DATASOURCE="#variables.dsn#">
    			<CFPROCPARAM VALUE="#session.CompanyID#" cfsqltype="CF_SQL_VARCHAR">
    			<cfif structKeyExists(arguments.frmStruct, "Dispatcher") AND len(trim(arguments.frmStruct.Dispatcher))>
    				<CFPROCPARAM VALUE="#arguments.frmStruct.Dispatcher#" cfsqltype="CF_SQL_VARCHAR">
    			<cfelse>
    				<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR" null="true">
    			</cfif>
    			<cfif structKeyExists(arguments.frmStruct, "Salesperson") AND len(trim(arguments.frmStruct.Salesperson))>
    				<CFPROCPARAM VALUE="#arguments.frmStruct.Salesperson#" cfsqltype="CF_SQL_VARCHAR">
    			<cfelse>
    				<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR" null="true">
    			</cfif>
    			<CFPROCPARAM VALUE="#arguments.frmStruct.equipment#" cfsqltype="CF_SQL_VARCHAR" null="#yesNoFormat(NOT len(trim(arguments.frmStruct.equipment)))#">
	    		<CFPROCPARAM VALUE="#trim(arguments.frmStruct.EquipmentWidth)#" cfsqltype="CF_SQL_FLOAT" null="#yesNoFormat(NOT len(trim(arguments.frmStruct.EquipmentWidth)))#">
	    		<CFPROCPARAM VALUE="#trim(arguments.frmStruct.EquipmentLength)#" cfsqltype="CF_SQL_FLOAT" null="#yesNoFormat(NOT len(trim(arguments.frmStruct.EquipmentLength)))#">
	    		<CFPROCPARAM VALUE="#arguments.frmStruct.notes#" cfsqltype="CF_SQL_VARCHAR" null="#yesNoFormat(NOT len(trim(arguments.frmStruct.notes)))#">
	    		<CFPROCPARAM VALUE="#arguments.frmStruct.CustomerID#" cfsqltype="CF_SQL_VARCHAR">
	    		<CFPROCPARAM VALUE="#arguments.frmStruct.CustomerName#" cfsqltype="CF_SQL_VARCHAR">
	    		<CFPROCPARAM VALUE="#arguments.frmStruct.CustomerLocation#" cfsqltype="CF_SQL_VARCHAR">
	    		<CFPROCPARAM VALUE="#arguments.frmStruct.CustomerCity#" cfsqltype="CF_SQL_VARCHAR">
	    		<CFPROCPARAM VALUE="#arguments.frmStruct.CustomerStateCode#" cfsqltype="CF_SQL_VARCHAR">
	    		<CFPROCPARAM VALUE="#arguments.frmStruct.CustomerZipCode#" cfsqltype="CF_SQL_VARCHAR">
	    		<CFPROCPARAM VALUE="#arguments.frmStruct.CustomerContact#" cfsqltype="CF_SQL_VARCHAR" null="#yesNoFormat(NOT len(trim(arguments.frmStruct.CustomerContact)))#">
	    		<CFPROCPARAM VALUE="#arguments.frmStruct.customerPhone#" cfsqltype="CF_SQL_VARCHAR" null="#yesNoFormat(NOT len(trim(arguments.frmStruct.customerPhone)))#">
	    		<CFPROCPARAM VALUE="#arguments.frmStruct.customerCell#" cfsqltype="CF_SQL_VARCHAR" null="#yesNoFormat(NOT len(trim(arguments.frmStruct.customerCell)))#">
	    		<CFPROCPARAM VALUE="#arguments.frmStruct.customerFax#" cfsqltype="CF_SQL_VARCHAR" null="#yesNoFormat(NOT len(trim(arguments.frmStruct.customerFax)))#">
	    		<CFPROCPARAM VALUE="#arguments.frmStruct.CustomerEmail#" cfsqltype="CF_SQL_VARCHAR" null="#yesNoFormat(NOT len(trim(arguments.frmStruct.CustomerEmail)))#">
	    		<CFPROCPARAM VALUE="#arguments.frmStruct.customerPO#" cfsqltype="CF_SQL_VARCHAR" null="#yesNoFormat(NOT len(trim(arguments.frmStruct.customerPO)))#">
	    		<CFPROCPARAM VALUE="#arguments.frmStruct.customerBOL#" cfsqltype="CF_SQL_VARCHAR" null="#yesNoFormat(NOT len(trim(arguments.frmStruct.customerBOL)))#">
	    		<CFPROCPARAM VALUE="#session.adminusername#" cfsqltype="CF_SQL_VARCHAR">
	    		<CFPROCPARAM VALUE="#cgi.REMOTE_ADDR#" cfsqltype="CF_SQL_VARCHAR">
	    		<cfif len(trim(customerCommoditiesCharges)) AND isNumeric(customerCommoditiesCharges)>
		    		<CFPROCPARAM VALUE="#customerCommoditiesCharges#" cfsqltype="CF_SQL_MONEY">
		    	<cfelse>
		    		<CFPROCPARAM VALUE="0" cfsqltype="CF_SQL_MONEY">
		    	</cfif>
		    	<CFPROCPARAM VALUE="#session.CustomerID#" cfsqltype="CF_SQL_VARCHAR">
		    	<CFPROCPARAM VALUE="#arguments.frmStruct.shipperPickupDate_0#" cfsqltype="CF_SQL_DATE" null="#yesNoFormat(NOT len(trim(arguments.frmStruct.shipperPickupDate_0)))#">
		    	<CFPROCPARAM VALUE="#arguments.frmStruct.shipperpickupTime_0#" cfsqltype="CF_SQL_VARCHAR" null="#yesNoFormat(NOT len(trim(arguments.frmStruct.shipperpickupTime_0)))#">
		    	<CFPROCPARAM VALUE="#arguments.frmStruct['consigneePickupDate_#arguments.frmStruct.totalstops#']#" cfsqltype="CF_SQL_DATE" null="#yesNoFormat(NOT len(trim(arguments.frmStruct['consigneePickupDate_#arguments.frmStruct.totalstops#'])))#">
			   	<CFPROCPARAM VALUE="#arguments.frmStruct['consigneePickupTime_#arguments.frmStruct.totalstops#']#" cfsqltype="CF_SQL_VARCHAR" null="#yesNoFormat(NOT len(trim(arguments.frmStruct['consigneePickupTime_#arguments.frmStruct.totalstops#'])))#">
    			<cfprocresult name="qLastInsertedLoad">
    		</CFSTOREDPROC>
    		<!--- End:Insert Load --->
    		<cfset var LoadID = qLastInsertedLoad.LoadID>

    		<cfloop from="0" to="#arguments.frmStruct.totalstops#" index="StopNo">
    			<!--- Begin:Insert LoadStop--->
   				<cfloop list="shipper,consignee" item="Type">
	    			<CFSTOREDPROC PROCEDURE="USP_InsertCustomerLoadStop" DATASOURCE="#variables.dsn#">
	    				<CFPROCPARAM VALUE="#LoadID#" cfsqltype="CF_SQL_VARCHAR">
	    				<CFPROCPARAM VALUE="#StopNo#" cfsqltype="CF_SQL_INTEGER">
	    				<cfif Type EQ 'shipper'>
	    					<CFPROCPARAM VALUE="1" cfsqltype="CF_SQL_INTEGER">
	    				<cfelse>
	    					<CFPROCPARAM VALUE="2" cfsqltype="CF_SQL_INTEGER">
	    				</cfif>
		    			<CFPROCPARAM VALUE="#arguments.frmStruct['#Type#id_#StopNo#']#" cfsqltype="CF_SQL_VARCHAR" null="#yesNoFormat(NOT len(trim(arguments.frmStruct['#Type#id_#StopNo#'])))#">
			    		<CFPROCPARAM VALUE="#arguments.frmStruct['#Type#_#StopNo#']#" cfsqltype="CF_SQL_VARCHAR"  null="#yesNoFormat(NOT len(trim(arguments.frmStruct['#Type#_#StopNo#'])))#">
			    		<CFPROCPARAM VALUE="#arguments.frmStruct['#Type#location_#StopNo#']#" cfsqltype="CF_SQL_VARCHAR" null="#yesNoFormat(NOT len(trim(arguments.frmStruct['#Type#location_#StopNo#'])))#">
			    		<CFPROCPARAM VALUE="#arguments.frmStruct['#Type#city_#StopNo#']#" cfsqltype="CF_SQL_VARCHAR" null="#yesNoFormat(NOT len(trim(arguments.frmStruct['#Type#city_#StopNo#'])))#">
			    		<CFPROCPARAM VALUE="#arguments.frmStruct['#Type#state_#StopNo#']#" cfsqltype="CF_SQL_VARCHAR" null="#yesNoFormat(NOT len(trim(arguments.frmStruct['#Type#state_#StopNo#'])))#">
			    		<CFPROCPARAM VALUE="#arguments.frmStruct['#Type#Zipcode_#StopNo#']#" cfsqltype="CF_SQL_VARCHAR" null="#yesNoFormat(NOT len(trim(arguments.frmStruct['#Type#Zipcode_#StopNo#'])))#">
			    		<CFPROCPARAM VALUE="#arguments.frmStruct['#Type#ContactPerson_#StopNo#']#" cfsqltype="CF_SQL_VARCHAR" null="#yesNoFormat(NOT len(trim(arguments.frmStruct['#Type#ContactPerson_#StopNo#'])))#">
			    		<CFPROCPARAM VALUE="#arguments.frmStruct['#Type#Phone_#StopNo#']#" cfsqltype="CF_SQL_VARCHAR" null="#yesNoFormat(NOT len(trim(arguments.frmStruct['#Type#Phone_#StopNo#'])))#">
			    		<CFPROCPARAM VALUE="#arguments.frmStruct['#Type#Fax_#StopNo#']#" cfsqltype="CF_SQL_VARCHAR" null="#yesNoFormat(NOT len(trim(arguments.frmStruct['#Type#Fax_#StopNo#'])))#">
			    		<CFPROCPARAM VALUE="#arguments.frmStruct['#Type#Email_#StopNo#']#" cfsqltype="CF_SQL_VARCHAR">
			    		<CFPROCPARAM VALUE="#arguments.frmStruct['#Type#PickupNo_#StopNo#']#" cfsqltype="CF_SQL_VARCHAR">
		    			<CFPROCPARAM VALUE="#arguments.frmStruct['#Type#PickupDate_#StopNo#']#" cfsqltype="CF_SQL_VARCHAR" null="#yesNoFormat(NOT len(trim(arguments.frmStruct['#Type#PickupDate_#StopNo#'])))#">
			    		<CFPROCPARAM VALUE="#arguments.frmStruct['#Type#pickupTime_#StopNo#']#" cfsqltype="CF_SQL_VARCHAR">
			    		<cfif structKeyExists(arguments.frmStruct, "#Type#TimeZone_#StopNo#")>
				    		<CFPROCPARAM VALUE="#arguments.frmStruct['#Type#TimeZone_#StopNo#']#" cfsqltype="CF_SQL_VARCHAR" null="#yesNoFormat(NOT len(trim(arguments.frmStruct['#Type#TimeZone_#StopNo#'])))#">
				    	<cfelse>
				    		<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR" null="true">
				    	</cfif>
			    		<CFPROCPARAM VALUE="#arguments.frmStruct['#Type#Notes_#StopNo#']#" cfsqltype="CF_SQL_VARCHAR" null="#yesNoFormat(NOT len(trim(arguments.frmStruct['#Type#Notes_#StopNo#'])))#">
			    		<CFPROCPARAM VALUE="#session.adminusername#" cfsqltype="CF_SQL_VARCHAR">
			    		<CFPROCPARAM VALUE="#arguments.frmStruct.equipment#" cfsqltype="CF_SQL_VARCHAR" null="#yesNoFormat(NOT len(trim(arguments.frmStruct.equipment)))#">
			    		<CFPROCPARAM VALUE="#arguments.frmStruct.temperature#" cfsqltype="CF_SQL_VARCHAR" null="#yesNoFormat(NOT len(trim(arguments.frmStruct.temperature)))#">
			    		<CFPROCPARAM VALUE="#arguments.frmStruct.temperaturescale#" cfsqltype="CF_SQL_VARCHAR" null="#yesNoFormat(NOT len(trim(arguments.frmStruct.temperaturescale)))#">
			    		<CFPROCPARAM VALUE="#session.CustomerID#" cfsqltype="CF_SQL_VARCHAR">
			    		<CFPROCPARAM VALUE="#cgi.REMOTE_ADDR#" cfsqltype="CF_SQL_VARCHAR">
			    		<cfprocresult name="qLastInsertedLoadStop">
	    			</CFSTOREDPROC>
	    	
	    			<cfif Type EQ 'shipper'>
		    			<cfset var LoadStopID = qLastInsertedLoadStop.LoadStopID>
		    		</cfif>
    			</cfloop>
    			<!--- End:Insert LoadStop--->

    			<!--- Begin:Insert LoadStopItem--->
    			<cfloop from="1" to="#arguments.frmStruct['totalcommodity_#StopNo#']#" index="SrNo">
    				<cfset var CustRate = ReplaceNoCase(ReplaceNoCase(arguments.frmStruct['CustomerRate_#StopNo#_#SrNo#'],'$','','ALL'),',','','ALL')>
    				<cfset var CustCharges = ReplaceNoCase(ReplaceNoCase(arguments.frmStruct['CustCharges_#StopNo#_#SrNo#'],'$','','ALL'),',','','ALL')>

    				<CFSTOREDPROC PROCEDURE="USP_InsertCustomerLoadItem" DATASOURCE="#variables.dsn#">
    					<CFPROCPARAM VALUE="#LoadStopID#" cfsqltype="CF_SQL_VARCHAR">
    					<CFPROCPARAM VALUE="#SrNo#" cfsqltype="CF_SQL_INTEGER">
    					<cfif len(trim(arguments.frmStruct['qty_#StopNo#_#SrNo#'])) AND IsNumeric(arguments.frmStruct['qty_#StopNo#_#SrNo#'])>
	    					<CFPROCPARAM VALUE="#arguments.frmStruct['qty_#StopNo#_#SrNo#']#" cfsqltype="CF_SQL_FLOAT">
	    				<cfelse>
	    					<CFPROCPARAM VALUE="1" cfsqltype="CF_SQL_FLOAT">
	    				</cfif>
	    				<CFPROCPARAM VALUE="#arguments.frmStruct['unit_#StopNo#_#SrNo#']#" cfsqltype="CF_SQL_VARCHAR" null="#yesNoFormat(NOT len(trim(arguments.frmStruct['unit_#StopNo#_#SrNo#'])))#">

	    				<CFPROCPARAM VALUE="#arguments.frmStruct['description_#StopNo#_#SrNo#']#" cfsqltype="CF_SQL_VARCHAR" null="#yesNoFormat(NOT len(trim(arguments.frmStruct['description_#StopNo#_#SrNo#'])))#">
	    				<CFPROCPARAM VALUE="#arguments.frmStruct['dimensions_#StopNo#_#SrNo#']#" cfsqltype="CF_SQL_VARCHAR" null="#yesNoFormat(NOT len(trim(arguments.frmStruct['dimensions_#StopNo#_#SrNo#'])))#">
	    				<cfif len(trim(arguments.frmStruct['weight_#StopNo#_#SrNo#'])) AND IsNumeric(arguments.frmStruct['weight_#StopNo#_#SrNo#'])>
	    					<CFPROCPARAM VALUE="#arguments.frmStruct['weight_#StopNo#_#SrNo#']#" cfsqltype="CF_SQL_FLOAT">
	    				<cfelse>
	    					<CFPROCPARAM VALUE="0" cfsqltype="CF_SQL_FLOAT">
	    				</cfif>
	    				<CFPROCPARAM VALUE="#arguments.frmStruct['class_#StopNo#_#SrNo#']#" cfsqltype="CF_SQL_VARCHAR" null="#yesNoFormat(NOT len(trim(arguments.frmStruct['class_#StopNo#_#SrNo#'])))#">
	    				<cfif len(trim(CustRate)) AND isNumeric(CustRate)>
				    		<CFPROCPARAM VALUE="#CustRate#" cfsqltype="CF_SQL_DECIMAL">
				    	<cfelse>
				    		<CFPROCPARAM VALUE="0" cfsqltype="CF_SQL_DECIMAL">
				    	</cfif>
				    	<cfif len(trim(CustCharges)) AND isNumeric(CustCharges)>
				    		<CFPROCPARAM VALUE="#CustCharges#" cfsqltype="CF_SQL_MONEY">
				    	<cfelse>
				    		<CFPROCPARAM VALUE="0" cfsqltype="CF_SQL_MONEY">
				    	</cfif>
				    	<cfif isdefined("arguments.frmStruct.isFee_#StopNo#_#SrNo#")>
							<CFPROCPARAM VALUE="1" cfsqltype="CF_SQL_BIT">
						<cfelse>
							<CFPROCPARAM VALUE="0" cfsqltype="CF_SQL_BIT">
						</cfif>
						<CFPROCPARAM VALUE="#session.CustomerID#" cfsqltype="CF_SQL_VARCHAR">
			    		<CFPROCPARAM VALUE="#cgi.REMOTE_ADDR#" cfsqltype="CF_SQL_VARCHAR">
			    		<CFPROCPARAM VALUE="#session.adminusername#" cfsqltype="CF_SQL_VARCHAR">
    				</CFSTOREDPROC>
    			</cfloop>
    			<!--- End:Insert LoadStopItem--->
    		</cfloop>
    	</cftransaction>
		<cfreturn LoadID>
	</cffunction>

	<cffunction name="deleteStop" access="remote"  output="yes" returntype="string" returnformat="json">
		<cfargument name="dsn" required="yes" type="string">
		<cfargument name="LoadId" required="yes" type="string">
		<cfargument name="StopNo" required="yes" type="string">

		<cfargument name="LoadNumber" required="yes" type="string">
		<cfargument name="UpdatedByUserID" required="yes" type="string">
		<cfargument name="UpdatedBy" required="yes" type="string">

		<cftry>
			<cftransaction>
				<cfquery name="qDelStop" datasource="#arguments.dsn#">
					DELETE FROM LoadStops WHERE LoadID = <cfqueryparam value="#arguments.LoadID#" cfsqltype="cf_sql_varchar"> AND StopNo = <cfqueryparam value="#arguments.StopNo#" cfsqltype="cf_sql_integer">
				</cfquery>

				<cfquery name="qUpdStops" datasource="#arguments.dsn#">
					UPDATE LoadStops SET StopNo = StopNo - 1
					WHERE LoadID = <cfqueryparam value="#arguments.LoadID#" cfsqltype="cf_sql_varchar">
					AND StopNo > <cfqueryparam value="#arguments.StopNo#" cfsqltype="cf_sql_integer">
				</cfquery>

				<cfquery name="qGetCustCharges" datasource="#arguments.dsn#">
			    	SELECT SUM(CustCharges) AS CustCharges from LoadStopCommodities WHERE LoadStopID IN (SELECT LoadStopID FROM LoadStops WHERE LoadID = <cfqueryparam value="#arguments.loadid#" cfsqltype="cf_sql_varchar">)
				</cfquery>

			    <cfquery name="qUpdLoadCustCharges" datasource="#arguments.dsn#">
			    	UPDATE Loads SET 
			    	customerCommoditiesCharges = <cfqueryparam value="#qGetCustCharges.CustCharges#" cfsqltype="cf_sql_money">,
			    	TotalCustomerCharges= <cfqueryparam value="#qGetCustCharges.CustCharges#" cfsqltype="cf_sql_float">
			    	WHERE loadid = <cfqueryparam value="#arguments.loadid#" cfsqltype="cf_sql_varchar">
			    </cfquery>

				<cfquery name="qryCreateUnlockedLog" datasource="#arguments.dsn#" >
					INSERT INTO LoadLogs (LoadID,LoadNumber,FieldLabel,NewValue,UpdatedByUserID,UpdatedBy,UpdatedTimestamp,UpdatedByIP)
					VALUES(
						<cfqueryparam value="#arguments.loadid#" cfsqltype="cf_sql_nvarchar">,
						<cfqueryparam value="#arguments.loadnumber#" cfsqltype="cf_sql_integer">,
						<cfqueryparam value="STOP NO #arguments.stopNo+1#" cfsqltype="cf_sql_nvarchar">,
						<cfqueryparam value="DELETED" cfsqltype="cf_sql_nvarchar">,
						<cfqueryparam value="#arguments.UpdatedByUserID#" cfsqltype="cf_sql_nvarchar">,
						<cfqueryparam value="#arguments.UpdatedBy#" cfsqltype="cf_sql_nvarchar">,
						getdate(),
						<cfqueryparam value="#cgi.REMOTE_ADDR#" cfsqltype="cf_sql_nvarchar">
						)
				</cfquery>

				<cfreturn 'Success'>
			</cftransaction>
			<cfcatch>
		    	<cfreturn 'Error'>
		    </cfcatch>
		</cftry>
	</cffunction>

	<cffunction name="delCommodityRow" access="remote"  output="yes" returntype="string" returnformat="json">
		<cfargument name="dsn" required="yes" type="string">
		<cfargument name="LoadStopCommoditiesID" required="yes" type="string">
		<cfargument name="SrNo" required="yes" type="string">

		<cfargument name="LoadId" required="yes" type="string">
		<cfargument name="LoadNumber" required="yes" type="string">
		<cfargument name="UpdatedByUserID" required="yes" type="string">
		<cfargument name="UpdatedBy" required="yes" type="string">
		<cfargument name="stopNo" required="yes" type="string">
		<cfargument name="description" required="yes" type="string">
		<cfargument name="count" required="yes" type="string">

		<cftry>
			<cftransaction>
				<cfquery name="qGetLoadStop" datasource="#arguments.dsn#">
					SELECT LoadStopID AS ID FROM LoadStopCommodities WHERE LoadStopCommoditiesID = <cfqueryparam value="#arguments.LoadStopCommoditiesID#" cfsqltype="cf_sql_varchar">
				</cfquery>

				<cfquery name="qdelCommodityRows" datasource="#arguments.dsn#">
					<cfif arguments.count EQ 1>
						UPDATE LoadStopCommodities SET 
						Qty = 1,
						UnitID = NULL,
						Description = NULL,
						Weight = NULL,
						ClassID = NULL,
						CustCharges = 0,
						CarrCharges = 0,
						Fee = 0,
						CustRate = 0,
						CarrRate = 0,
						CarrRateOfCustTotal = 0,
						DirectCost = 0,
						DirectCostTotal = 0
						WHERE LoadStopCommoditiesID = <cfqueryparam value="#arguments.LoadStopCommoditiesID#" cfsqltype="cf_sql_varchar">
					<cfelse>
				        DELETE FROM LoadStopCommodities
				        WHERE LoadStopCommoditiesID = <cfqueryparam value="#arguments.LoadStopCommoditiesID#" cfsqltype="cf_sql_varchar">
			        </cfif>
			    </cfquery>

			    <cfquery name="qupdRowCommodities" datasource="#arguments.dsn#">
			    	UPDATE LoadStopCommodities SET SrNo = SrNo - 1
			    	WHERE loadstopid = <cfqueryparam value="#qGetLoadStop.ID#" cfsqltype="cf_sql_varchar">
			        AND SrNo > <cfqueryparam value="#arguments.SrNo#" cfsqltype="cf_sql_integer"> 
			    </cfquery>

			    <cfquery name="qGetCustCharges" datasource="#arguments.dsn#">
			    	SELECT SUM(CustCharges) AS CustCharges from LoadStopCommodities WHERE LoadStopID IN (SELECT LoadStopID FROM LoadStops WHERE LoadID = <cfqueryparam value="#arguments.loadid#" cfsqltype="cf_sql_varchar">)
				</cfquery>

			    <cfquery name="qUpdLoadCustCharges" datasource="#arguments.dsn#">
			    	UPDATE Loads SET 
			    	customerCommoditiesCharges = <cfqueryparam value="#qGetCustCharges.CustCharges#" cfsqltype="cf_sql_money">,
			    	TotalCustomerCharges= <cfqueryparam value="#qGetCustCharges.CustCharges#" cfsqltype="cf_sql_float">
			    	WHERE loadid = <cfqueryparam value="#arguments.loadid#" cfsqltype="cf_sql_varchar">
			    </cfquery>

			    <cfquery name="qryCreateUnlockedLog" datasource="#arguments.dsn#" >
					INSERT INTO LoadLogs (LoadID,LoadNumber,FieldLabel,Oldvalue,NewValue,UpdatedByUserID,UpdatedBy,UpdatedTimestamp,UpdatedByIP)
					VALUES(
						<cfqueryparam value="#arguments.loadid#" cfsqltype="cf_sql_nvarchar">,
						<cfqueryparam value="#arguments.loadnumber#" cfsqltype="cf_sql_integer">,
						<cfqueryparam value="STOP NO #arguments.stopNo+1# - ITEM - #arguments.srNo#" cfsqltype="cf_sql_nvarchar">,
						<cfqueryparam value="#arguments.description#" cfsqltype="cf_sql_nvarchar">,
						<cfqueryparam value="DELETED" cfsqltype="cf_sql_nvarchar">,
						<cfqueryparam value="#arguments.UpdatedByUserID#" cfsqltype="cf_sql_nvarchar">,
						<cfqueryparam value="#arguments.UpdatedBy#" cfsqltype="cf_sql_nvarchar">,
						getdate(),
						<cfqueryparam value="#cgi.REMOTE_ADDR#" cfsqltype="cf_sql_nvarchar">
						)
				</cfquery>
			</cftransaction>
		    <cfreturn 'Success'>
		    <cfcatch>
		    	<cfreturn 'Error'>
		    </cfcatch>
		</cftry>
	</cffunction>


	<cffunction name="UpdateCustomerLoad" access="public" returntype="string">
		<cfargument name="frmStruct" type="struct" required="no" />
		<cftransaction>
			<cfset var customerCommoditiesCharges = ReplaceNoCase(ReplaceNoCase(arguments.frmstruct.customerCommoditiesCharges,'$','','ALL'),',','','ALL')>

			<CFSTOREDPROC PROCEDURE="USP_GetCustomerLoadForLog" DATASOURCE="#variables.dsn#">
				<CFPROCPARAM VALUE="#arguments.frmStruct.LoadID#" cfsqltype="CF_SQL_VARCHAR">
				<cfprocresult name="qGetLoadLogBeforeUpdate">
			</CFSTOREDPROC>
			<!--- Begin:Update Load --->
    		<CFSTOREDPROC PROCEDURE="USP_UpdateCustomerLoad" DATASOURCE="#variables.dsn#">
    			<CFPROCPARAM VALUE="#arguments.frmStruct.LoadID#" cfsqltype="CF_SQL_VARCHAR">
    			<cfif structKeyExists(arguments.frmStruct, "Dispatcher") AND len(trim(arguments.frmStruct.Dispatcher))>
    				<CFPROCPARAM VALUE="#arguments.frmStruct.Dispatcher#" cfsqltype="CF_SQL_VARCHAR">
    			<cfelse>
    				<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR" null="true">
    			</cfif>
    			<cfif structKeyExists(arguments.frmStruct, "Salesperson") AND len(trim(arguments.frmStruct.Salesperson))>
    				<CFPROCPARAM VALUE="#arguments.frmStruct.Salesperson#" cfsqltype="CF_SQL_VARCHAR">
    			<cfelse>
    				<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR" null="true">
    			</cfif>
    			<CFPROCPARAM VALUE="#arguments.frmStruct.equipment#" cfsqltype="CF_SQL_VARCHAR" null="#yesNoFormat(NOT len(trim(arguments.frmStruct.equipment)))#">
	    		<CFPROCPARAM VALUE="#trim(arguments.frmStruct.EquipmentWidth)#" cfsqltype="CF_SQL_FLOAT" null="#yesNoFormat(NOT len(trim(arguments.frmStruct.EquipmentWidth)))#">
	    		<CFPROCPARAM VALUE="#trim(arguments.frmStruct.EquipmentLength)#" cfsqltype="CF_SQL_FLOAT" null="#yesNoFormat(NOT len(trim(arguments.frmStruct.EquipmentLength)))#">
	    		<CFPROCPARAM VALUE="#arguments.frmStruct.notes#" cfsqltype="CF_SQL_VARCHAR" null="#yesNoFormat(NOT len(trim(arguments.frmStruct.notes)))#">
	    		<CFPROCPARAM VALUE="#arguments.frmStruct.CustomerID#" cfsqltype="CF_SQL_VARCHAR">
	    		<CFPROCPARAM VALUE="#arguments.frmStruct.CustomerName#" cfsqltype="CF_SQL_VARCHAR">
	    		<CFPROCPARAM VALUE="#arguments.frmStruct.CustomerLocation#" cfsqltype="CF_SQL_VARCHAR">
	    		<CFPROCPARAM VALUE="#arguments.frmStruct.CustomerCity#" cfsqltype="CF_SQL_VARCHAR">
	    		<CFPROCPARAM VALUE="#arguments.frmStruct.CustomerStateCode#" cfsqltype="CF_SQL_VARCHAR">
	    		<CFPROCPARAM VALUE="#arguments.frmStruct.CustomerZipCode#" cfsqltype="CF_SQL_VARCHAR">
	    		<CFPROCPARAM VALUE="#arguments.frmStruct.CustomerContact#" cfsqltype="CF_SQL_VARCHAR" null="#yesNoFormat(NOT len(trim(arguments.frmStruct.CustomerContact)))#">
	    		<CFPROCPARAM VALUE="#arguments.frmStruct.customerPhone#" cfsqltype="CF_SQL_VARCHAR" null="#yesNoFormat(NOT len(trim(arguments.frmStruct.customerPhone)))#">
	    		<CFPROCPARAM VALUE="#arguments.frmStruct.customerCell#" cfsqltype="CF_SQL_VARCHAR" null="#yesNoFormat(NOT len(trim(arguments.frmStruct.customerCell)))#">
	    		<CFPROCPARAM VALUE="#arguments.frmStruct.customerFax#" cfsqltype="CF_SQL_VARCHAR" null="#yesNoFormat(NOT len(trim(arguments.frmStruct.customerFax)))#">
	    		<CFPROCPARAM VALUE="#arguments.frmStruct.CustomerEmail#" cfsqltype="CF_SQL_VARCHAR" null="#yesNoFormat(NOT len(trim(arguments.frmStruct.CustomerEmail)))#">
	    		<CFPROCPARAM VALUE="#arguments.frmStruct.customerPO#" cfsqltype="CF_SQL_VARCHAR" null="#yesNoFormat(NOT len(trim(arguments.frmStruct.customerPO)))#">
	    		<CFPROCPARAM VALUE="#arguments.frmStruct.customerBOL#" cfsqltype="CF_SQL_VARCHAR" null="#yesNoFormat(NOT len(trim(arguments.frmStruct.customerBOL)))#">
	    		<CFPROCPARAM VALUE="#session.adminusername#" cfsqltype="CF_SQL_VARCHAR">
	    		<CFPROCPARAM VALUE="#cgi.REMOTE_ADDR#" cfsqltype="CF_SQL_VARCHAR">
	    		<cfif len(trim(customerCommoditiesCharges)) AND isNumeric(customerCommoditiesCharges)>
		    		<CFPROCPARAM VALUE="#customerCommoditiesCharges#" cfsqltype="CF_SQL_MONEY">
		    	<cfelse>
		    		<CFPROCPARAM VALUE="0" cfsqltype="CF_SQL_MONEY">
		    	</cfif>
		    	<CFPROCPARAM VALUE="#arguments.frmStruct.shipperPickupDate_0#" cfsqltype="CF_SQL_DATE" null="#yesNoFormat(NOT len(trim(arguments.frmStruct.shipperPickupDate_0)))#">
		    	<CFPROCPARAM VALUE="#arguments.frmStruct.shipperpickupTime_0#" cfsqltype="CF_SQL_VARCHAR" null="#yesNoFormat(NOT len(trim(arguments.frmStruct.shipperpickupTime_0)))#">
		    	<CFPROCPARAM VALUE="#arguments.frmStruct['consigneePickupDate_#arguments.frmStruct.totalstops#']#" cfsqltype="CF_SQL_DATE" null="#yesNoFormat(NOT len(trim(arguments.frmStruct['consigneePickupDate_#arguments.frmStruct.totalstops#'])))#">
			   	<CFPROCPARAM VALUE="#arguments.frmStruct['consigneePickupTime_#arguments.frmStruct.totalstops#']#" cfsqltype="CF_SQL_VARCHAR" null="#yesNoFormat(NOT len(trim(arguments.frmStruct['consigneePickupTime_#arguments.frmStruct.totalstops#'])))#">
    			<cfprocresult name="qLastUpdatedLoad">
    		</CFSTOREDPROC>
    		<!--- End:Update Load --->
    		<CFSTOREDPROC PROCEDURE="USP_GetCustomerLoadForLog" DATASOURCE="#variables.dsn#">
				<CFPROCPARAM VALUE="#arguments.frmStruct.LoadID#" cfsqltype="CF_SQL_VARCHAR">
				<cfprocresult name="qGetLoadLogAfterUpdate">
			</CFSTOREDPROC>

			<cfloop list="#qGetLoadLogBeforeUpdate.columnList#" index="col">
				<cfif qGetLoadLogBeforeUpdate['#col#'][1] NEQ qGetLoadLogAfterUpdate['#col#'][1]>
					<cfquery name="qCreateLog" datasource="#variables.dsn#" >
						INSERT INTO LoadLogs (LoadID,LoadNumber,FieldLabel,OldValue,NewValue,UpdatedByUserID,UpdatedBy,UpdatedTimestamp,UpdatedByIP)
						VALUES(
							<cfqueryparam value="#arguments.frmStruct.LoadID#" cfsqltype="cf_sql_nvarchar">,
							(SELECT LoadNumber FROM Loads WHERE LoadID = <cfqueryparam value="#arguments.frmStruct.LoadID#" cfsqltype="cf_sql_nvarchar">),
							<cfqueryparam value="#col#" cfsqltype="cf_sql_nvarchar">,
							<cfqueryparam value="#qGetLoadLogBeforeUpdate['#col#'][1]#" cfsqltype="cf_sql_nvarchar">,
							<cfqueryparam value="#qGetLoadLogAfterUpdate['#col#'][1]#" cfsqltype="cf_sql_nvarchar">,
							<cfqueryparam value="#session.CustomerID#" cfsqltype="cf_sql_nvarchar">,
							<cfqueryparam value="#session.adminusername#" cfsqltype="cf_sql_nvarchar">,
							getdate(),
							<cfqueryparam value="#cgi.REMOTE_ADDR#" cfsqltype="cf_sql_nvarchar">
							)
					</cfquery>
				</cfif>
			</cfloop>

    		<cfset var LoadID = qLastUpdatedLoad.LoadID>
    		<cfloop from="0" to="#arguments.frmStruct.totalstops#" index="StopNo">
    			<!--- Begin:Insert LoadStop--->
   				<cfloop list="shipper,consignee" item="Type">
   					<cfset var LoadStopID = arguments.frmStruct['#Type#StopID_#StopNo#']>

   					<cfif len(trim(LoadStopID))>
   						<CFSTOREDPROC PROCEDURE="USP_GetCustomerLoadStopForLog" DATASOURCE="#variables.dsn#">
							<CFPROCPARAM VALUE="#LoadStopID#" cfsqltype="CF_SQL_VARCHAR">
							<cfprocresult name="qGetLoadStopLogBeforeUpdate">
						</CFSTOREDPROC>

   						<CFSTOREDPROC PROCEDURE="USP_UpdateCustomerLoadStop" DATASOURCE="#variables.dsn#">
		    				<CFPROCPARAM VALUE="#LoadStopID#" cfsqltype="CF_SQL_VARCHAR">
			    			<CFPROCPARAM VALUE="#arguments.frmStruct['#Type#id_#StopNo#']#" cfsqltype="CF_SQL_VARCHAR" null="#yesNoFormat(NOT len(trim(arguments.frmStruct['#Type#id_#StopNo#'])))#">
				    		<CFPROCPARAM VALUE="#arguments.frmStruct['#Type#_#StopNo#']#" cfsqltype="CF_SQL_VARCHAR"  null="#yesNoFormat(NOT len(trim(arguments.frmStruct['#Type#_#StopNo#'])))#">
				    		<CFPROCPARAM VALUE="#arguments.frmStruct['#Type#location_#StopNo#']#" cfsqltype="CF_SQL_VARCHAR" null="#yesNoFormat(NOT len(trim(arguments.frmStruct['#Type#location_#StopNo#'])))#">
				    		<CFPROCPARAM VALUE="#arguments.frmStruct['#Type#city_#StopNo#']#" cfsqltype="CF_SQL_VARCHAR" null="#yesNoFormat(NOT len(trim(arguments.frmStruct['#Type#city_#StopNo#'])))#">
				    		<CFPROCPARAM VALUE="#arguments.frmStruct['#Type#state_#StopNo#']#" cfsqltype="CF_SQL_VARCHAR" null="#yesNoFormat(NOT len(trim(arguments.frmStruct['#Type#state_#StopNo#'])))#">
				    		<CFPROCPARAM VALUE="#arguments.frmStruct['#Type#Zipcode_#StopNo#']#" cfsqltype="CF_SQL_VARCHAR" null="#yesNoFormat(NOT len(trim(arguments.frmStruct['#Type#Zipcode_#StopNo#'])))#">
				    		<CFPROCPARAM VALUE="#arguments.frmStruct['#Type#ContactPerson_#StopNo#']#" cfsqltype="CF_SQL_VARCHAR" null="#yesNoFormat(NOT len(trim(arguments.frmStruct['#Type#ContactPerson_#StopNo#'])))#">
				    		<CFPROCPARAM VALUE="#arguments.frmStruct['#Type#Phone_#StopNo#']#" cfsqltype="CF_SQL_VARCHAR" null="#yesNoFormat(NOT len(trim(arguments.frmStruct['#Type#Phone_#StopNo#'])))#">
				    		<CFPROCPARAM VALUE="#arguments.frmStruct['#Type#Fax_#StopNo#']#" cfsqltype="CF_SQL_VARCHAR" null="#yesNoFormat(NOT len(trim(arguments.frmStruct['#Type#Fax_#StopNo#'])))#">
				    		<CFPROCPARAM VALUE="#arguments.frmStruct['#Type#Email_#StopNo#']#" cfsqltype="CF_SQL_VARCHAR">
				    		<CFPROCPARAM VALUE="#arguments.frmStruct['#Type#PickupNo_#StopNo#']#" cfsqltype="CF_SQL_VARCHAR">
			    			<CFPROCPARAM VALUE="#arguments.frmStruct['#Type#PickupDate_#StopNo#']#" cfsqltype="CF_SQL_VARCHAR" null="#yesNoFormat(NOT len(trim(arguments.frmStruct['#Type#PickupDate_#StopNo#'])))#">
				    		<CFPROCPARAM VALUE="#arguments.frmStruct['#Type#pickupTime_#StopNo#']#" cfsqltype="CF_SQL_VARCHAR">
				    		<cfif structKeyExists(arguments.frmStruct, "#Type#TimeZone_#StopNo#")>
					    		<CFPROCPARAM VALUE="#arguments.frmStruct['#Type#TimeZone_#StopNo#']#" cfsqltype="CF_SQL_VARCHAR" null="#yesNoFormat(NOT len(trim(arguments.frmStruct['#Type#TimeZone_#StopNo#'])))#">
					    	<cfelse>
					    		<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR" null="yes">
					    	</cfif>
				    		<CFPROCPARAM VALUE="#arguments.frmStruct['#Type#Notes_#StopNo#']#" cfsqltype="CF_SQL_VARCHAR" null="#yesNoFormat(NOT len(trim(arguments.frmStruct['#Type#Notes_#StopNo#'])))#">
				    		<CFPROCPARAM VALUE="#session.adminusername#" cfsqltype="CF_SQL_VARCHAR">
				    		<CFPROCPARAM VALUE="#arguments.frmStruct.equipment#" cfsqltype="CF_SQL_VARCHAR" null="#yesNoFormat(NOT len(trim(arguments.frmStruct.equipment)))#">
				    		<CFPROCPARAM VALUE="#arguments.frmStruct.temperature#" cfsqltype="CF_SQL_VARCHAR" null="#yesNoFormat(NOT len(trim(arguments.frmStruct.temperature)))#">
				    		<CFPROCPARAM VALUE="#arguments.frmStruct.temperaturescale#" cfsqltype="CF_SQL_VARCHAR" null="#yesNoFormat(NOT len(trim(arguments.frmStruct.temperaturescale)))#">
				    		<cfprocresult name="qLastInsertedLoadStop">
		    			</CFSTOREDPROC>

		    			<CFSTOREDPROC PROCEDURE="USP_GetCustomerLoadStopForLog" DATASOURCE="#variables.dsn#">
							<CFPROCPARAM VALUE="#LoadStopID#" cfsqltype="CF_SQL_VARCHAR">
							<cfprocresult name="qGetLoadStopLogAfterUpdate">
						</CFSTOREDPROC>
						<cfloop list="#qGetLoadStopLogBeforeUpdate.columnList#" index="col">
							<cfif qGetLoadStopLogBeforeUpdate['#col#'][1] NEQ qGetLoadStopLogAfterUpdate['#col#'][1]>
								<cfquery name="qCreateLog" datasource="#variables.dsn#" >
									INSERT INTO LoadLogs (LoadID,LoadNumber,FieldLabel,OldValue,NewValue,UpdatedByUserID,UpdatedBy,UpdatedTimestamp,UpdatedByIP)
									VALUES(
										<cfqueryparam value="#arguments.frmStruct.LoadID#" cfsqltype="cf_sql_nvarchar">,
										(SELECT LoadNumber FROM Loads WHERE LoadID = <cfqueryparam value="#arguments.frmStruct.LoadID#" cfsqltype="cf_sql_nvarchar">),
										<cfqueryparam value="STOP NO #StopNo+1# - #col#" cfsqltype="cf_sql_nvarchar">,

										<cfqueryparam value="#qGetLoadStopLogBeforeUpdate['#col#'][1]#" cfsqltype="cf_sql_nvarchar">,
										<cfqueryparam value="#qGetLoadStopLogAfterUpdate['#col#'][1]#" cfsqltype="cf_sql_nvarchar">,

										<cfqueryparam value="#session.CustomerID#" cfsqltype="cf_sql_nvarchar">,
										<cfqueryparam value="#session.adminusername#" cfsqltype="cf_sql_nvarchar">,
										getdate(),
										<cfqueryparam value="#cgi.REMOTE_ADDR#" cfsqltype="cf_sql_nvarchar">
										)
								</cfquery>
							</cfif>
						</cfloop>
   					<cfelse>
   						<CFSTOREDPROC PROCEDURE="USP_InsertCustomerLoadStop" DATASOURCE="#variables.dsn#">
		    				<CFPROCPARAM VALUE="#LoadID#" cfsqltype="CF_SQL_VARCHAR">
		    				<CFPROCPARAM VALUE="#StopNo#" cfsqltype="CF_SQL_INTEGER">
		    				<cfif Type EQ 'shipper'>
		    					<CFPROCPARAM VALUE="1" cfsqltype="CF_SQL_INTEGER">
		    				<cfelse>
		    					<CFPROCPARAM VALUE="2" cfsqltype="CF_SQL_INTEGER">
		    				</cfif>
			    			<CFPROCPARAM VALUE="#arguments.frmStruct['#Type#id_#StopNo#']#" cfsqltype="CF_SQL_VARCHAR" null="#yesNoFormat(NOT len(trim(arguments.frmStruct['#Type#id_#StopNo#'])))#">
				    		<CFPROCPARAM VALUE="#arguments.frmStruct['#Type#_#StopNo#']#" cfsqltype="CF_SQL_VARCHAR"  null="#yesNoFormat(NOT len(trim(arguments.frmStruct['#Type#_#StopNo#'])))#">
				    		<CFPROCPARAM VALUE="#arguments.frmStruct['#Type#location_#StopNo#']#" cfsqltype="CF_SQL_VARCHAR" null="#yesNoFormat(NOT len(trim(arguments.frmStruct['#Type#location_#StopNo#'])))#">
				    		<CFPROCPARAM VALUE="#arguments.frmStruct['#Type#city_#StopNo#']#" cfsqltype="CF_SQL_VARCHAR" null="#yesNoFormat(NOT len(trim(arguments.frmStruct['#Type#city_#StopNo#'])))#">
				    		<CFPROCPARAM VALUE="#arguments.frmStruct['#Type#state_#StopNo#']#" cfsqltype="CF_SQL_VARCHAR" null="#yesNoFormat(NOT len(trim(arguments.frmStruct['#Type#state_#StopNo#'])))#">
				    		<CFPROCPARAM VALUE="#arguments.frmStruct['#Type#Zipcode_#StopNo#']#" cfsqltype="CF_SQL_VARCHAR" null="#yesNoFormat(NOT len(trim(arguments.frmStruct['#Type#Zipcode_#StopNo#'])))#">
				    		<CFPROCPARAM VALUE="#arguments.frmStruct['#Type#ContactPerson_#StopNo#']#" cfsqltype="CF_SQL_VARCHAR" null="#yesNoFormat(NOT len(trim(arguments.frmStruct['#Type#ContactPerson_#StopNo#'])))#">
				    		<CFPROCPARAM VALUE="#arguments.frmStruct['#Type#Phone_#StopNo#']#" cfsqltype="CF_SQL_VARCHAR" null="#yesNoFormat(NOT len(trim(arguments.frmStruct['#Type#Phone_#StopNo#'])))#">
				    		<CFPROCPARAM VALUE="#arguments.frmStruct['#Type#Fax_#StopNo#']#" cfsqltype="CF_SQL_VARCHAR" null="#yesNoFormat(NOT len(trim(arguments.frmStruct['#Type#Fax_#StopNo#'])))#">
				    		<CFPROCPARAM VALUE="#arguments.frmStruct['#Type#Email_#StopNo#']#" cfsqltype="CF_SQL_VARCHAR">
				    		<CFPROCPARAM VALUE="#arguments.frmStruct['#Type#PickupNo_#StopNo#']#" cfsqltype="CF_SQL_VARCHAR">
			    			<CFPROCPARAM VALUE="#arguments.frmStruct['#Type#PickupDate_#StopNo#']#" cfsqltype="CF_SQL_VARCHAR" null="#yesNoFormat(NOT len(trim(arguments.frmStruct['#Type#PickupDate_#StopNo#'])))#">
				    		<CFPROCPARAM VALUE="#arguments.frmStruct['#Type#pickupTime_#StopNo#']#" cfsqltype="CF_SQL_VARCHAR">
				    		<cfif structKeyExists(arguments.frmStruct, "#Type#TimeZone_#StopNo#")>
					    		<CFPROCPARAM VALUE="#arguments.frmStruct['#Type#TimeZone_#StopNo#']#" cfsqltype="CF_SQL_VARCHAR" null="#yesNoFormat(NOT len(trim(arguments.frmStruct['#Type#TimeZone_#StopNo#'])))#">
					    	<cfelse>
					    		<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR" null="yes">
					    	</cfif>
				    		<CFPROCPARAM VALUE="#arguments.frmStruct['#Type#Notes_#StopNo#']#" cfsqltype="CF_SQL_VARCHAR" null="#yesNoFormat(NOT len(trim(arguments.frmStruct['#Type#Notes_#StopNo#'])))#">
				    		<CFPROCPARAM VALUE="#session.adminusername#" cfsqltype="CF_SQL_VARCHAR">
				    		<CFPROCPARAM VALUE="#arguments.frmStruct.equipment#" cfsqltype="CF_SQL_VARCHAR" null="#yesNoFormat(NOT len(trim(arguments.frmStruct.equipment)))#">
				    		<CFPROCPARAM VALUE="#arguments.frmStruct.temperature#" cfsqltype="CF_SQL_VARCHAR" null="#yesNoFormat(NOT len(trim(arguments.frmStruct.temperature)))#">
				    		<CFPROCPARAM VALUE="#arguments.frmStruct.temperaturescale#" cfsqltype="CF_SQL_VARCHAR" null="#yesNoFormat(NOT len(trim(arguments.frmStruct.temperaturescale)))#">
				    		<CFPROCPARAM VALUE="#session.CustomerID#" cfsqltype="CF_SQL_VARCHAR">
			    			<CFPROCPARAM VALUE="#cgi.REMOTE_ADDR#" cfsqltype="CF_SQL_VARCHAR">
				    		<cfprocresult name="qLastInsertedLoadStop">
		    			</CFSTOREDPROC>
   					</cfif>
   					<cfif Type EQ 'shipper'>
		    			<cfset var CommodityLoadStopID = qLastInsertedLoadStop.LoadStopID>
		    		</cfif>
   				</cfloop>
   				<!--- End:Insert LoadStop--->

   				<!--- Begin:Insert LoadStopItem--->
    			<cfloop from="1" to="#arguments.frmStruct['totalcommodity_#StopNo#']#" index="SrNo">
    				<cfset var CustRate = ReplaceNoCase(ReplaceNoCase(arguments.frmStruct['CustomerRate_#StopNo#_#SrNo#'],'$','','ALL'),',','','ALL')>
    				<cfset var CustCharges = ReplaceNoCase(ReplaceNoCase(arguments.frmStruct['CustCharges_#StopNo#_#SrNo#'],'$','','ALL'),',','','ALL')>
    				<cfset var LoadStopCommoditiesID = arguments.frmStruct['LoadStopCommoditiesID_#StopNo#_#SrNo#']>

    				<cfif len(trim(LoadStopCommoditiesID))>

    					<CFSTOREDPROC PROCEDURE="USP_GetCustomerLoadStopItemForLog" DATASOURCE="#variables.dsn#">
							<CFPROCPARAM VALUE="#LoadStopCommoditiesID#" cfsqltype="CF_SQL_VARCHAR">
							<cfprocresult name="qGetLoadStopItemLogBeforeUpdate">
						</CFSTOREDPROC>

    					<CFSTOREDPROC PROCEDURE="USP_UpdateCustomerLoadItem" DATASOURCE="#variables.dsn#">
	    					<CFPROCPARAM VALUE="#LoadStopCommoditiesID#" cfsqltype="CF_SQL_VARCHAR">
	    					<CFPROCPARAM VALUE="#SrNo#" cfsqltype="CF_SQL_INTEGER">
	    					<cfif len(trim(arguments.frmStruct['qty_#StopNo#_#SrNo#'])) AND IsNumeric(arguments.frmStruct['qty_#StopNo#_#SrNo#'])>
		    					<CFPROCPARAM VALUE="#arguments.frmStruct['qty_#StopNo#_#SrNo#']#" cfsqltype="CF_SQL_FLOAT">
		    				<cfelse>
		    					<CFPROCPARAM VALUE="1" cfsqltype="CF_SQL_FLOAT">
		    				</cfif>
		    				<CFPROCPARAM VALUE="#arguments.frmStruct['unit_#StopNo#_#SrNo#']#" cfsqltype="CF_SQL_VARCHAR" null="#yesNoFormat(NOT len(trim(arguments.frmStruct['unit_#StopNo#_#SrNo#'])))#">
		    				<CFPROCPARAM VALUE="#arguments.frmStruct['description_#StopNo#_#SrNo#']#" cfsqltype="CF_SQL_VARCHAR" null="#yesNoFormat(NOT len(trim(arguments.frmStruct['description_#StopNo#_#SrNo#'])))#">
		    				<CFPROCPARAM VALUE="#arguments.frmStruct['dimensions_#StopNo#_#SrNo#']#" cfsqltype="CF_SQL_VARCHAR" null="#yesNoFormat(NOT len(trim(arguments.frmStruct['dimensions_#StopNo#_#SrNo#'])))#">
		    				<cfif len(trim(arguments.frmStruct['weight_#StopNo#_#SrNo#'])) AND IsNumeric(arguments.frmStruct['weight_#StopNo#_#SrNo#'])>
		    					<CFPROCPARAM VALUE="#arguments.frmStruct['weight_#StopNo#_#SrNo#']#" cfsqltype="CF_SQL_FLOAT">
		    				<cfelse>
		    					<CFPROCPARAM VALUE="0" cfsqltype="CF_SQL_FLOAT">
		    				</cfif>
		    				<CFPROCPARAM VALUE="#arguments.frmStruct['class_#StopNo#_#SrNo#']#" cfsqltype="CF_SQL_VARCHAR" null="#yesNoFormat(NOT len(trim(arguments.frmStruct['class_#StopNo#_#SrNo#'])))#">
		    				<cfif len(trim(CustRate)) AND isNumeric(CustRate)>
					    		<CFPROCPARAM VALUE="#CustRate#" cfsqltype="CF_SQL_DECIMAL">
					    	<cfelse>
					    		<CFPROCPARAM VALUE="0" cfsqltype="CF_SQL_DECIMAL">
					    	</cfif>
					    	<cfif len(trim(CustCharges)) AND isNumeric(CustCharges)>
					    		<CFPROCPARAM VALUE="#CustCharges#" cfsqltype="CF_SQL_MONEY">
					    	<cfelse>
					    		<CFPROCPARAM VALUE="0" cfsqltype="CF_SQL_MONEY">
					    	</cfif>
					    	<cfif isdefined("arguments.frmStruct.isFee_#StopNo#_#SrNo#")>
								<CFPROCPARAM VALUE="1" cfsqltype="CF_SQL_BIT">
							<cfelse>
								<CFPROCPARAM VALUE="0" cfsqltype="CF_SQL_BIT">
							</cfif>
	    				</CFSTOREDPROC>
	    				<CFSTOREDPROC PROCEDURE="USP_GetCustomerLoadStopItemForLog" DATASOURCE="#variables.dsn#">
							<CFPROCPARAM VALUE="#LoadStopCommoditiesID#" cfsqltype="CF_SQL_VARCHAR">
							<cfprocresult name="qGetLoadStopItemLogAfterUpdate">
						</CFSTOREDPROC>
						<cfloop list="#qGetLoadStopItemLogBeforeUpdate.columnList#" index="col">
							<cfif qGetLoadStopItemLogBeforeUpdate['#col#'][1] NEQ qGetLoadStopItemLogAfterUpdate['#col#'][1]>
								<cfquery name="qCreateLog" datasource="#variables.dsn#" >
									INSERT INTO LoadLogs (LoadID,LoadNumber,FieldLabel,OldValue,NewValue,UpdatedByUserID,UpdatedBy,UpdatedTimestamp,UpdatedByIP)
									VALUES(
										<cfqueryparam value="#arguments.frmStruct.LoadID#" cfsqltype="cf_sql_nvarchar">,
										(SELECT LoadNumber FROM Loads WHERE LoadID = <cfqueryparam value="#arguments.frmStruct.LoadID#" cfsqltype="cf_sql_nvarchar">),
										<cfqueryparam value="STOP NO #stopNo+1# - ITEM - #SrNo# - #col#" cfsqltype="cf_sql_nvarchar">,

										<cfqueryparam value="#qGetLoadStopItemLogBeforeUpdate['#col#'][1]#" cfsqltype="cf_sql_nvarchar">,
										<cfqueryparam value="#qGetLoadStopItemLogAfterUpdate['#col#'][1]#" cfsqltype="cf_sql_nvarchar">,

										<cfqueryparam value="#session.CustomerID#" cfsqltype="cf_sql_nvarchar">,
										<cfqueryparam value="#session.adminusername#" cfsqltype="cf_sql_nvarchar">,
										getdate(),
										<cfqueryparam value="#cgi.REMOTE_ADDR#" cfsqltype="cf_sql_nvarchar">
										)
								</cfquery>
							</cfif>
						</cfloop>
    				<cfelse>
    					<CFSTOREDPROC PROCEDURE="USP_InsertCustomerLoadItem" DATASOURCE="#variables.dsn#">
	    					<CFPROCPARAM VALUE="#CommodityLoadStopID#" cfsqltype="CF_SQL_VARCHAR">
	    					<CFPROCPARAM VALUE="#SrNo#" cfsqltype="CF_SQL_INTEGER">
	    					<cfif len(trim(arguments.frmStruct['qty_#StopNo#_#SrNo#'])) AND IsNumeric(arguments.frmStruct['qty_#StopNo#_#SrNo#'])>
		    					<CFPROCPARAM VALUE="#arguments.frmStruct['qty_#StopNo#_#SrNo#']#" cfsqltype="CF_SQL_FLOAT">
		    				<cfelse>
		    					<CFPROCPARAM VALUE="1" cfsqltype="CF_SQL_FLOAT">
		    				</cfif>
		    				<CFPROCPARAM VALUE="#arguments.frmStruct['unit_#StopNo#_#SrNo#']#" cfsqltype="CF_SQL_VARCHAR" null="#yesNoFormat(NOT len(trim(arguments.frmStruct['unit_#StopNo#_#SrNo#'])))#">
		    				<CFPROCPARAM VALUE="#arguments.frmStruct['description_#StopNo#_#SrNo#']#" cfsqltype="CF_SQL_VARCHAR" null="#yesNoFormat(NOT len(trim(arguments.frmStruct['description_#StopNo#_#SrNo#'])))#">
		    				<CFPROCPARAM VALUE="#arguments.frmStruct['dimensions_#StopNo#_#SrNo#']#" cfsqltype="CF_SQL_VARCHAR" null="#yesNoFormat(NOT len(trim(arguments.frmStruct['dimensions_#StopNo#_#SrNo#'])))#">
		    				<cfif len(trim(arguments.frmStruct['weight_#StopNo#_#SrNo#'])) AND IsNumeric(arguments.frmStruct['weight_#StopNo#_#SrNo#'])>
		    					<CFPROCPARAM VALUE="#arguments.frmStruct['weight_#StopNo#_#SrNo#']#" cfsqltype="CF_SQL_FLOAT">
		    				<cfelse>
		    					<CFPROCPARAM VALUE="0" cfsqltype="CF_SQL_FLOAT">
		    				</cfif>
		    				<CFPROCPARAM VALUE="#arguments.frmStruct['class_#StopNo#_#SrNo#']#" cfsqltype="CF_SQL_VARCHAR" null="#yesNoFormat(NOT len(trim(arguments.frmStruct['class_#StopNo#_#SrNo#'])))#">
		    				<cfif len(trim(CustRate)) AND isNumeric(CustRate)>
					    		<CFPROCPARAM VALUE="#CustRate#" cfsqltype="CF_SQL_DECIMAL">
					    	<cfelse>
					    		<CFPROCPARAM VALUE="0" cfsqltype="CF_SQL_DECIMAL">
					    	</cfif>
					    	<cfif len(trim(CustCharges)) AND isNumeric(CustCharges)>
					    		<CFPROCPARAM VALUE="#CustCharges#" cfsqltype="CF_SQL_MONEY">
					    	<cfelse>
					    		<CFPROCPARAM VALUE="0" cfsqltype="CF_SQL_MONEY">
					    	</cfif>
					    	<cfif isdefined("arguments.frmStruct.isFee_#StopNo#_#SrNo#")>
								<CFPROCPARAM VALUE="1" cfsqltype="CF_SQL_BIT">
							<cfelse>
								<CFPROCPARAM VALUE="0" cfsqltype="CF_SQL_BIT">
							</cfif>
							<CFPROCPARAM VALUE="#session.CustomerID#" cfsqltype="CF_SQL_VARCHAR">
				    		<CFPROCPARAM VALUE="#cgi.REMOTE_ADDR#" cfsqltype="CF_SQL_VARCHAR">
				    		<CFPROCPARAM VALUE="#session.adminusername#" cfsqltype="CF_SQL_VARCHAR">
	    				</CFSTOREDPROC>
    				</cfif>
    			</cfloop>
    			<!--- End:Insert LoadStopItem--->
    		</cfloop>
		</cftransaction>

		<cfreturn LoadID>
	</cffunction>

	<cffunction name="CopyCustomerLoadToMultiple" access="public" returntype="any">
		<cfargument name="LoadIDToBeCopied" type="string" required="yes" />
		<cfargument name="NoOfCopies" type="string" required="yes" />

		<cfset var i = 1>
		<cfset var arrLoad = arrayNew(1)>
		<cftransaction>
			<cfloop from="1" to="#arguments.NoOfCopies#" index="i">
				<CFSTOREDPROC PROCEDURE="USP_CopyCustomerLoadToMultiple" DATASOURCE="#variables.dsn#">
			    	<CFPROCPARAM VALUE="#arguments.LoadIDToBeCopied#" cfsqltype="CF_SQL_VARCHAR">
			    	<CFPROCPARAM VALUE="#session.CompanyID#" cfsqltype="CF_SQL_VARCHAR">
			    	<CFPROCPARAM VALUE="#session.adminusername#" cfsqltype="CF_SQL_VARCHAR">
		    		<CFPROCPARAM VALUE="#cgi.REMOTE_ADDR#" cfsqltype="CF_SQL_VARCHAR">
			    	<cfprocresult name="qLastInsertedLoad">
			    </CFSTOREDPROC>
			    <cfset var tempStruct = structNew()>
			    <cfset tempStruct.LoadID = qLastInsertedLoad.LoadID>
			    <cfset tempStruct.LoadNumber = qLastInsertedLoad.LoadNumber>
			    <cfset arrayAppend(arrLoad, tempStruct)>
		    </cfloop>
		</cftransaction>
	    <cfsavecontent variable="loadDetails">
			<cfoutput>
			<h3 style='color:##31a047;'>#NoOfCopies# load copied successfully</h3><p>The load numbers are <cfset var Load = ""><cfloop array="#arrLoad#" index="Load"> <a href='index.cfm?event=addcustomerload&loadid=#Load.LoadID#&#session.URLToken#' target='_blank'>#Load.LoadNumber#</a></cfloop></p>
			</cfoutput>
		</cfsavecontent>
		
		<cfreturn loadDetails>

	</cffunction>

	<cffunction name="swapStops" access="remote"  output="yes" returntype="string" returnformat="json">
		<cfargument name="dsn" required="yes" type="string">
		<cfargument name="LoadId" required="yes" type="string">
		<cfargument name="Stop1" required="yes" type="string">
		<cfargument name="Stop2" required="yes" type="string">

		<cfargument name="LoadNumber" required="yes" type="string">
		<cfargument name="UpdatedByUserID" required="yes" type="string">
		<cfargument name="UpdatedBy" required="yes" type="string">

		<cftry>

			<cftransaction>

				<cfquery name="qUpdateStops" datasource="#arguments.dsn#">
			    	SELECT LoadStopID,
						CASE WHEN StopNo = #Stop1# then #Stop2# else #Stop1# end as stopno
					INTO ##temp
					FROM LoadStops WHERE LoadID = <cfqueryparam value="#arguments.LoadID#" cfsqltype="cf_sql_varchar"> and StopNo in (#Stop1# ,#Stop2#) order by StopNo,LoadType

 					UPDATE LS SET StopNo = t.StopNo 
 						FROM LoadStops LS INNER JOIN ##temp t on t.LoadStopID = LS.LoadStopID WHERE ls.StopNo in (#Stop1# ,#Stop2#) 

					DROP TABLE ##temp;
				</cfquery>


				<cfquery name="qryCreateUnlockedLog" datasource="#arguments.dsn#" >
					INSERT INTO LoadLogs (LoadID,LoadNumber,FieldLabel,NewValue,UpdatedByUserID,UpdatedBy,UpdatedTimestamp,UpdatedByIP)
					VALUES(
						<cfqueryparam value="#arguments.loadid#" cfsqltype="cf_sql_nvarchar">,
						<cfqueryparam value="#arguments.loadnumber#" cfsqltype="cf_sql_integer">,
						<cfqueryparam value="STOP NO #arguments.stop1+1# - STOP NO #arguments.stop2+1#" cfsqltype="cf_sql_nvarchar">,
						<cfqueryparam value="INERCHANGED" cfsqltype="cf_sql_nvarchar">,
						<cfqueryparam value="#arguments.UpdatedByUserID#" cfsqltype="cf_sql_nvarchar">,
						<cfqueryparam value="#arguments.UpdatedBy#" cfsqltype="cf_sql_nvarchar">,
						<cfqueryparam value="#Now()#" cfsqltype="cf_sql_timestamp">,
						<cfqueryparam value="#cgi.REMOTE_ADDR#" cfsqltype="cf_sql_nvarchar">
						)
				</cfquery>

				<cfreturn 'Success'>
			</cftransaction>
			<cfcatch>
		    	<cfreturn 'Error'>
		    </cfcatch>
		</cftry>
	</cffunction>
</cfcomponent>
