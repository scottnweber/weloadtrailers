<cfcomponent output="true" extends="loadgatewayupdate">
	<cffunction name="init" access="public" output="false" returntype="void">
		<cfargument name="dsn" type="string" required="yes" />
		<cfset variables.dsn = Application.dsn />
	</cffunction>
	
	<cffunction name="updateshipdateAll" access="remote" output="yes" returntype="Any" returnformat="plain">
		<cfargument name="CompanyID" type="any" required="no" default=""/>
		<cfargument name="loadNumbers" type="array" required="yes" />
		<cfargument name="dsn" type="string" required="yes" />
		<cfargument name="shipperDateToUpdate"  required="yes" />
		<cfargument name="multipleShipperDates"  required="yes" />
		<cfargument name="empId" type="string" required="yes" />
		<cfargument name="statustext" type="string" required="yes" />
		<cfargument name="text" type="string" required="yes" />
		<cfargument name="postits" type="numeric" required="yes" />
		<cfargument name="posteverywhere" type="numeric" required="yes" />
		<cfargument name="post123loadboard" type="numeric" required="yes" />
		<cfargument name="postdatloadboard" type="numeric" required="yes" />
		<cfargument name="postCarrierRatetoTranscore" type="numeric" required="yes" />
		<cfargument name="weekendRollOvercheck" type="numeric" required="yes" default="1"/>
		<cfargument name="clientTime" type="string" required="yes" default="<current time>"/>
		<cfargument name="statusReadableText" type="string" required="yes" default=""/>
		<cfargument name="postdirectfreight" type="numeric" required="yes" default="1"/>
		<cftry>
			<cfset var local=structNew()>
			<cfset local.DirectFreightLoadboard=structNew()>
			<cfset local.DirectFreightLoadboardDeleted=structNew()>
			<cfset local.loadboardits=structNew()>
			<cfset local.loadboarditsDeleted=structNew()>
			<cfset local.datLoadbord=structNew()>
			<cfset local.datLoadbordDeleted=structNew()>
			<cfset local.posteveryWhere=structNew()>
			<cfset local.posteveryWhereDeleted=structNew()>
			<cfset local.Loadbord123=structNew()>
			<cfset local.Loadbord123Deleted=structNew()>
			<cfset local.UpdatedShipDate=structNew()>
			<cfset local.LoadStatus=structNew()>

			<cfset var frmstruct=structNew()>
			<cfset local.DirectFreightLoadboard=arraynew(1)>
			<cfset local.DirectFreightLoadboardDeleted=arraynew(1)>
			<cfset local.loadboardits=arraynew(1)>
			<cfset local.loadboarditsDeleted=arraynew(1)>
			<cfset local.datLoadbord=arraynew(1)>
			<cfset local.datLoadbordDeleted=arraynew(1)>
			<cfset local.posteveryWhere=arraynew(1)>
			<cfset local.posteveryWhereDeleted=arraynew(1)>
			<cfset local.Loadbord123=arraynew(1)>
			<cfset local.Loadbord123Deleted=arraynew(1)>
			<cfset local.UpdatedShipDate=arraynew(1)>
			<cfset local.LoadStatus=arraynew(1)>
		
			<cfset variables.TheKey = 'NAMASKARAM'>
			<cfset local.dsn = Decrypt(ToString(ToBinary(arguments.dsn)), variables.TheKey)>
			<cfset variables.cfcpath=local.dsn &'.www.gateways'>
			<cfif not structKeyExists(variables,"objLoadGateway")>
				<cfscript>variables.objLoadGateway = #variables.cfcpath#&".loadgateway";</cfscript>
			</cfif>		
			<cfquery name="qryGetAgentdetails" datasource="#local.dsn#">
		    	SELECT integratewithTran360,trans360Usename,trans360Password,IntegrationID, 
				(SELECT proMilesStatus FROM SystemConfig WHERE CompanyID = <cfqueryparam value="#arguments.CompanyID#" cfsqltype="cf_sql_varchar">) AS proMilesStatus,
		    	(SELECT PCMilerUsername FROM SystemConfig WHERE CompanyID = <cfqueryparam value="#arguments.CompanyID#" cfsqltype="cf_sql_varchar">) AS PCMilerUsername,
		    	(SELECT PCMilerPassword FROM SystemConfig WHERE CompanyID = <cfqueryparam value="#arguments.CompanyID#" cfsqltype="cf_sql_varchar">) AS PCMilerPassword,
		    	(SELECT PCMilerCompanyCode FROM SystemConfig WHERE CompanyID = <cfqueryparam value="#arguments.CompanyID#" cfsqltype="cf_sql_varchar">) AS CompanyCode,
		    	loadBoard123,loadBoard123Usename,loadBoard123Password,integrationID, Name,PEPcustomerKey,IntegrateWithDirectFreightLoadboard,DirectFreightLoadboardUserName,DirectFreightLoadboardPassword,
		    	integratewithPEP,O.integratewithITS,Name
		        FROM Employees
		        LEFT JOIN Offices O ON O.OfficeID = Employees.OfficeID
		        WHERE EmployeeID = <cfqueryparam cfsqltype="cf_sql_varchar"value="#arguments.empId#">
		    </cfquery>
		    <cfinvoke  method="getSystemSetupOptions" dsn="#local.dsn#" returnvariable="request.qSystemSetupOptions" CompanyID="#arguments.CompanyID#" />
			<cfset local.loadnumbers=ArrayToList(arguments.loadNumbers,", ")>
			<cfif listFindNoCase(local.loadnumbers, 'on', ",")>
				<cfset local.loadnumbers = ListDeleteAt( local.loadnumbers, ListFindnocase(local.loadnumbers,'on',","), ",") />
			</cfif>
			<cfloop list="#local.loadnumbers#" index="i">
				<cfset local.loadNo = i>
				<cfquery name="qryGetLoadDetails" datasource="#local.dsn#">
					select 
					*
					,(select statusText from LoadStatusTypes where LoadStatusTypes.StatusTypeID = Loads.StatusTypeID) AS oldStatus
					from loads where loadnumber=<cfqueryparam cfsqltype="cf_sql_bigint" value="#i#">
					and customerid in (select customerid from customeroffices where officeid in (select officeid from offices where companyid =<cfqueryparam cfsqltype="cf_sql_varchar"value="#arguments.CompanyID#"> ) )
				</cfquery>
				<cfquery name="qryloadstopResult" datasource="#local.dsn#">
					select stopdate,StopNo,LoadType from  loadstops  
					where loadid=<cfqueryparam cfsqltype="cf_sql_varchar"value="#qryGetLoadDetails.loadid#">
					order by StopNo
				</cfquery>
				<cfset var dateComparison=structNew()>
				<cfset variables.loopcount=0>
				<cfset variables.countRryloadstopResult=(qryloadstopResult.recordcount/2)>
				<cfloop from="1" to="#variables.countRryloadstopResult#" index="i">
					<cfquery name="qryCompareshipdate" datasource="#local.dsn#">
						select stopdate,StopNo,LoadType,ISNULL(stopdateDifference,0) AS stopdateDifference from  loadstops  
						where loadid=<cfqueryparam cfsqltype="cf_sql_varchar"value="#qryGetLoadDetails.loadid#">
						and stopno=<cfqueryparam cfsqltype="cf_sql_integer"value="#variables.loopcount#">
						and LoadType=1
					</cfquery>
					<cfquery name="qryComparedeliverydate" datasource="#local.dsn#">
						select stopdate,StopNo,LoadType from  loadstops  
						where loadid=<cfqueryparam cfsqltype="cf_sql_varchar"value="#qryGetLoadDetails.loadid#">
						and stopno=<cfqueryparam cfsqltype="cf_sql_integer"value="#variables.loopcount#">
						and LoadType=2
					</cfquery>
					<cfset variables.noOfDays=qryCompareshipdate.stopdateDifference>
					<cfset StructInsert(dateComparison,"stop#variables.loopcount#",#variables.noOfDays#,"yes")>
					<cfset StructInsert(dateComparison,"stop#variables.loopcount#_Date",#qryCompareshipdate.stopdate#,"yes")>
					<cfset variables.loopcount++>
				</cfloop>
				<cfquery name="qryUpdateShipDetailsInstops" datasource="#local.dsn#">
					select stopdate,StopNo from  loadstops  
					where loadid=<cfqueryparam cfsqltype="cf_sql_varchar"value="#qryGetLoadDetails.loadid#">
					and LoadStops.LoadType =<cfqueryparam cfsqltype="cf_sql_integer"value="2">
					order by StopNo
				</cfquery>
				<cfset variables.dateList=valuelist(qryUpdateShipDetailsInstops.stopdate)>
				<cfset variables.count=0>
				<cfset variables.statutextLoadBoardDeletionOccured=true>

				<cfif len(trim(arguments.text)) and trim(arguments.text) NEQ 'Select Status'>
					<cfswitch expression="#arguments.text#">
						<cfcase value=". TEMPLATE">
							<cfset variables.statusTextNumber=1>
						</cfcase>
						<cfcase value="0. QUOTE">
							<cfset variables.statusTextNumber=2>
						</cfcase>
						<cfcase value="0.1 EDI">
							<cfset variables.statusTextNumber=3>
						</cfcase>
						
						<cfcase value="1. ACTIVE">
							<cfset variables.statusTextNumber=4>
						</cfcase>
						
						<cfcase value="2. BOOKED">
							<cfset variables.statusTextNumber=5>
						</cfcase>
						
						<cfcase value="3. DISPATCHED">
							<cfset variables.statusTextNumber=6>
						</cfcase>
						<cfcase value="4. LOADED">
							<cfset variables.statusTextNumber=7>
						</cfcase>
						<cfcase value="4. LOADED/UNLOADED">
							<cfset variables.statusTextNumber=7>
						</cfcase>
						<cfcase value="5. DELIVERED">
							<cfset variables.statusTextNumber=8>
						</cfcase>
						<cfcase value="6. POD">
							<cfset variables.statusTextNumber=9>
						</cfcase>
						
						<cfcase value="7. INVOICE">
							<cfset variables.statusTextNumber=10>
						</cfcase>
						<cfcase value="7.1 PAID">
							<cfset variables.statusTextNumber=11>
						</cfcase>
						<cfcase value="8. COMPLETED">
							<cfset variables.statusTextNumber=13>
						</cfcase>
						<cfcase value="9. Cancelled">
							<cfset variables.statusTextNumber=14>
						</cfcase>
						<cfcase value="4.1 ARRIVED">
							<cfset variables.statusTextNumber=15>
						</cfcase>
						<cfcase value="4.2 AT SHIPPER">
							<cfset variables.statusTextNumber=15>
						</cfcase>

						<cfcase value="4.3 IN-TRANSIT">
							<cfset variables.statusTextNumber=15>
						</cfcase>

						<cfcase value="4.4 AT DELIVERY">
							<cfset variables.statusTextNumber=15>
						</cfcase>

						<cfcase value="0.1 SPOT">
							<cfset variables.statusTextNumber=16>
						</cfcase>

					</cfswitch>	
					<cfset variables.loadNumberAssignment=0>
					<cfif len(trim(request.qSystemSetupOptions.Triger_loadStatus))>
						<cfquery name="qryGetStatus" datasource="#local.dsn#">
							select StatusText from LoadStatusTypes where StatusTypeID=<cfqueryparam value="#request.qSystemSetupOptions.Triger_loadStatus#" cfsqltype="cf_sql_varchar">
						</cfquery>
						<cfswitch expression="#qryGetStatus.StatusText#">
							<cfcase value=". TEMPLATE">
								<cfset variables.loadNumberAssignment=1>
							</cfcase>
							<cfcase value="0. QUOTE">
								<cfset variables.loadNumberAssignment=2>
							</cfcase>
							<cfcase value="0.1 EDI">
								<cfset variables.loadNumberAssignment=3>
							</cfcase>
							
							<cfcase value="1. ACTIVE">
								<cfset variables.loadNumberAssignment=4>
							</cfcase>
							
							<cfcase value="2. BOOKED">
								<cfset variables.loadNumberAssignment=5>
							</cfcase>
							
							<cfcase value="3. DISPATCHED">
								<cfset variables.loadNumberAssignment=6>
							</cfcase>
							<cfcase value="4. LOADED">
								<cfset variables.loadNumberAssignment=7>
							</cfcase>
							<cfcase value="5. DELIVERED">
								<cfset variables.loadNumberAssignment=8>
							</cfcase>
							<cfcase value="6. POD">
								<cfset variables.loadNumberAssignment=9>
							</cfcase>
							
							<cfcase value="7. INVOICE">
								<cfset variables.loadNumberAssignment=10>
							</cfcase>
							<cfcase value="7.1 PAID">
								<cfset variables.loadNumberAssignment=11>
							</cfcase>
							<cfcase value="8. COMPLETED">
								<cfset variables.loadNumberAssignment=13>
							</cfcase>
							<cfcase value="9. Cancelled">
								<cfset variables.loadNumberAssignment=14>
							</cfcase>
	                        <cfcase value="4.1 ARRIVED">
								<cfset variables.loadNumberAssignment=15>
							</cfcase>

							 <cfcase value="4.2 AT SHIPPER">
								<cfset variables.loadNumberAssignment=15>
							</cfcase>
							 <cfcase value="4.3 IN-TRANSIT">
								<cfset variables.loadNumberAssignment=15>
							</cfcase>
							 <cfcase value="4.4 AT DELIVERY">
								<cfset variables.loadNumberAssignment=15>
							</cfcase>


							<cfcase value="0.1 SPOT">
								<cfset variables.loadNumberAssignment=16>
							</cfcase>
						</cfswitch>	
					</cfif>	
					<cfif variables.statusTextNumber gte  variables.loadNumberAssignment >
						<cfset variables.statutextLoadBoardDeletionOccured=false>
					<cfelse>
						<cfset variables.statutextLoadBoardDeletionOccured=true>
					</cfif>
				</cfif>	
				<cfif len(trim(arguments.shipperDateToUpdate))>
					<cfquery name="qryUpdateShipDetailsInstops1" datasource="#local.dsn#">
						update loadstops set 
						stopdate=<cfqueryparam cfsqltype="cf_sql_date" value="#arguments.shipperDateToUpdate#">
						where loadid=<cfqueryparam cfsqltype="cf_sql_varchar"value="#qryGetLoadDetails.loadid#">
						and LoadStops.LoadType =<cfqueryparam cfsqltype="cf_sql_integer"value="1">
					</cfquery>
					<cfquery name="qryUpdateShipDetails" datasource="#local.dsn#">
						update loads set 
						NewPickupDate=<cfqueryparam cfsqltype="cf_sql_date" value="#arguments.shipperDateToUpdate#">
						where loadid=<cfqueryparam cfsqltype="cf_sql_varchar"value="#qryGetLoadDetails.loadid#">
					</cfquery>
					<cfif len(trim(arguments.multipleShipperDates))>
						<cfquery name="qryUpdateMultipleShipperDates" datasource="#local.dsn#">
							update loadstops set 
							MultipleDates=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.multipleShipperDates#">
							where loadid=<cfqueryparam cfsqltype="cf_sql_varchar"value="#qryGetLoadDetails.loadid#">
							and stopno = 0
							and LoadStops.LoadType =<cfqueryparam cfsqltype="cf_sql_integer"value="1">
						</cfquery>
					</cfif>
					<cfset arrayappend(local.UpdatedShipDate,#qryGetLoadDetails.loadnumber#)>
				</cfif>	
				<cfloop query="qryUpdateShipDetailsInstops">
					<cfset variables.todayDate=#DateFormat(now(), "mm/dd/yyyy")#>

					<cfif len(trim(arguments.shipperDateToUpdate))>
						<cfif IsValid("date",#arguments.shipperDateToUpdate#)>
							<cfset variables.addingNumber=evaluate("dateComparison.stop#variables.count#")>
							<cfif len(trim(variables.addingNumber))>
								<cfset variables.deliverydateIncremented=DateAdd("d", variables.addingNumber, #arguments.shipperDateToUpdate#)>
								<cfif arguments.weekendRollOvercheck eq 1>
									<cfif DayOfWeek(variables.deliverydateIncremented) eq 7 >
										<cfset variables.deliverydateIncremented=DateAdd("d", 2, #variables.deliverydateIncremented#)>
									<cfelseif DayOfWeek(variables.deliverydateIncremented) eq 1>	
										<cfset variables.deliverydateIncremented=DateAdd("d", 1, #variables.deliverydateIncremented#)>
									</cfif>	
								</cfif>	
								<cfquery name="qryUpdateShipDetailsInstops2" datasource="#local.dsn#">
									update loadstops set 
									stopdate=<cfqueryparam cfsqltype="cf_sql_date" value="#variables.deliverydateIncremented#">
									where loadid=<cfqueryparam cfsqltype="cf_sql_varchar"value="#qryGetLoadDetails.loadid#">
									and LoadStops.LoadType =<cfqueryparam cfsqltype="cf_sql_integer"value="2">
									and StopNo=<cfqueryparam cfsqltype="cf_sql_integer"value="#variables.count#">
								</cfquery>
							<cfelse>
								<cfif arguments.weekendRollOvercheck eq 1>
									<cfif DayOfWeek(variables.todayDate) eq 7 >
										<cfset variables.todayDate=DateAdd("d", 2, #variables.todayDate#)>
									<cfelseif DayOfWeek(variables.todayDate) eq 1>	
										<cfset variables.todayDate=DateAdd("d", 1, #variables.todayDate#)>
									</cfif>	
								</cfif>	
								<cfquery name="qryUpdateShipDetailsInstops2" datasource="#local.dsn#">
									update loadstops set 
									stopdate=<cfqueryparam cfsqltype="cf_sql_date" value="#variables.todayDate#">
									where loadid=<cfqueryparam cfsqltype="cf_sql_varchar"value="#qryGetLoadDetails.loadid#">
									and LoadStops.LoadType =<cfqueryparam cfsqltype="cf_sql_integer"value="2">
									and StopNo=<cfqueryparam cfsqltype="cf_sql_integer"value="#variables.count#">
								</cfquery>
							</cfif>	
						</cfif>	
					</cfif>
					<cfset variables.count++>
				</cfloop>
				<cfquery name="qrygetDeliveryDate" datasource="#local.dsn#">
					Select  max(stopdate) as stopdate from loadstops
					where loadid=<cfqueryparam cfsqltype="cf_sql_varchar"value="#qryGetLoadDetails.loadid#">
					and LoadStops.LoadType =<cfqueryparam cfsqltype="cf_sql_integer"value="2">
				</cfquery>
				<cfquery name="qryUpdateShipDetailsInstops3" datasource="#local.dsn#">
					update loads set 
					NEWDELIVERYdATE=<cfqueryparam cfsqltype="cf_sql_date" value="#qrygetDeliveryDate.stopdate#">
					where loadid=<cfqueryparam cfsqltype="cf_sql_varchar"value="#qryGetLoadDetails.loadid#">
				</cfquery>
				<cfif len(trim(arguments.statustext))>
					<cfquery name="qryUpdateStatus" datasource="#local.dsn#">
						update loads set 
						StatusTypeID=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.statustext#">,
						NewDispatchNotes= <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.clientTime# - #qryGetAgentdetails.Name# > Status changed to #arguments.statusReadableText#"> + CHAR(13)+CHAR(10) + ISNULL(NewDispatchNotes, '')
						where loadid=<cfqueryparam cfsqltype="cf_sql_varchar"value="#qryGetLoadDetails.loadid#">
					</cfquery> 
					<cfquery name="qryCreateUnlockedLog" datasource="#local.dsn#" >
						INSERT INTO LoadLogs (LoadID,LoadNumber,FieldLabel,OldValue,NewValue,UpdatedByUserID,UpdatedBy,UpdatedTimestamp)
						VALUES(
							<cfqueryparam value="#qryGetLoadDetails.loadid#" cfsqltype="cf_sql_nvarchar">,
							<cfqueryparam value="#local.loadNo#" cfsqltype="cf_sql_bigint">,
							<cfqueryparam value="STATUS" cfsqltype="cf_sql_nvarchar">,
							<cfqueryparam value="#qryGetLoadDetails.oldStatus#" cfsqltype="cf_sql_nvarchar">,
							<cfqueryparam value="#arguments.statusReadableText#" cfsqltype="cf_sql_nvarchar">,
							<cfqueryparam value="#arguments.empId#" cfsqltype="cf_sql_nvarchar">,
							<cfqueryparam value="#qryGetAgentdetails.Name#" cfsqltype="cf_sql_nvarchar">,
							<cfqueryparam value="#Now()#" cfsqltype="cf_sql_timestamp">
							)
					</cfquery>

					<cfset arrayappend(local.LoadStatus,#qryGetLoadDetails.loadnumber#)>
					
				</cfif>	
				<cfif request.qSystemSetupOptions.freightbroker eq 1>
					<cfif arguments.postdirectfreight eq 1>
						<cfif qryGetAgentdetails.IntegrateWithDirectFreightLoadboard EQ 1>
							<cfif qryGetAgentdetails.DirectFreightLoadboardUserName neq "" and qryGetAgentdetails.DirectFreightLoadboardPassword neq "">
								<cfif qryGetLoadDetails.posttoDirectFreight EQ 1>
									<cfset p_method = 'PATCH'>
								<cfelse>
									<cfset p_method = 'POST'>
								</cfif>
								<cfif NOT StructKeyExists(arguments,"postCarrierRatetoTranscore")>
									<cfset IncludeCarierRate = 0>
								<cfelse>
									<cfset IncludeCarierRate = arguments.postCarrierRatetoTranscore >
								</cfif>
								<cfinvoke method="DirectFreightLoadboard" LoadID="#qryGetLoadDetails.LoadID#" impref="#qryGetLoadDetails.loadnumber#" dsn="#local.dsn#" DirectFreightLoadboardUserName="#qryGetAgentdetails.DirectFreightLoadboardUserName#" DirectFreightLoadboardPassword="#qryGetAgentdetails.DirectFreightLoadboardPassword#" POSTMETHOD="#p_method#"  IncludeCarierRate="#IncludeCarierRate#" CARRIERRATE="#qryGetLoadDetails.CarrFlatRate#" returnvariable="request.DirectFreightLoadboard" />
								<cfif request.DirectFreightLoadboard eq 'Direct Freight Loadboard Says : Load posted successfully.'
								OR request.DirectFreightLoadboard eq 'Direct Freight Loadboard Says : Load updated successfully.'>
									<cfset arrayappend(local.DirectFreightLoadboard,#qryGetLoadDetails.loadnumber#)>
								<cfelse>
									<cfset arrayappend(local.DirectFreightLoadboard,#qryGetLoadDetails.loadnumber#&'$'&#request.DirectFreightLoadboard#)> 
								</cfif>	
							</cfif>
						</cfif>
					<cfelse>
						<cfif qryGetAgentdetails.IntegrateWithDirectFreightLoadboard EQ 1>
							<cfif qryGetAgentdetails.DirectFreightLoadboardUserName neq "" and qryGetAgentdetails.DirectFreightLoadboardPassword neq "">
								<cfif qryGetLoadDetails.posttoDirectFreight EQ 1>
									<cfinvoke method="DirectFreightLoadboard" LoadID="#qryGetLoadDetails.LoadID#" impref="#qryGetLoadDetails.loadnumber#" DirectFreightLoadboardUserName="#qryGetAgentdetails.DirectFreightLoadboardUserName#" DirectFreightLoadboardPassword="#qryGetAgentdetails.DirectFreightLoadboardPassword#" POSTMETHOD="DEL" dsn="#local.dsn#" returnvariable="request.DirectFreightLoadboard" />
									<cfif request.DirectFreightLoadboard EQ 'Direct Freight Loadboard Says : Load deleted successfully.'>
										<cfset arrayappend(local.DirectFreightLoadboardDeleted,#qryGetLoadDetails.loadnumber#)>
									</cfif>
								</cfif>
							</cfif>
						</cfif>
					</cfif>
					<cfif arguments.postits eq 1>
						<cfif qryGetAgentdetails.IntegrateWithITS EQ 1>
							<cfif request.qSystemSetupOptions.ITSUserName neq "" and request.qSystemSetupOptions.ITSPassword neq "">
								<cfif  variables.statutextLoadBoardDeletionOccured>
									<cfif qryGetLoadDetails.posttoITS eq 1>
										<cfset p_action = 'U'>
										<cfset ITS_msg = ITSWebservice(#qryGetLoadDetails.loadnumber#, p_action, #request.qSystemSetupOptions.ITSUserName#, #request.qSystemSetupOptions.ITSPassword#, #qryGetAgentdetails.IntegrationID#,#qryGetLoadDetails.loadnumber#,#qryGetLoadDetails.LoadId#,arguments.CompanyID,#local.dsn#,arguments.empId)>
										<cfif ITS_msg eq 1>
											<cfset arrayappend(local.loadboardits,#qryGetLoadDetails.loadnumber#)>
										<cfelse>
											<cfset arrayappend(local.loadboardits,#ITS_msg#)>
										</cfif>		
									<cfelse>
										<cfset p_action = 'A'>
										<cfset ITS_msg = ITSWebservice(#qryGetLoadDetails.loadnumber#, p_action, #request.qSystemSetupOptions.ITSUserName#, #request.qSystemSetupOptions.ITSPassword#, #qryGetAgentdetails.IntegrationID#,#qryGetLoadDetails.loadnumber#,#qryGetLoadDetails.LoadId#,arguments.CompanyID,#local.dsn#,arguments.empId)>
										<cfif ITS_msg eq 1>
											<cfset arrayappend(local.loadboardits,#qryGetLoadDetails.loadnumber#)>
										<cfelse>
											<cfset arrayappend(local.loadboardits,#ITS_msg#)>
										</cfif>		
									</cfif>	
								</cfif>	
							</cfif>	
						</cfif>	
					<cfelse>
						<cfif qryGetAgentdetails.IntegrateWithITS EQ 1>
							<cfif request.qSystemSetupOptions.ITSUserName neq "" and request.qSystemSetupOptions.ITSPassword neq "">
								<cfif qryGetLoadDetails.posttoITS eq 1>
									<cfset ITS_msg = ITSWebservice(#qryGetLoadDetails.loadnumber#, 'D', #request.qSystemSetupOptions.ITSUserName#, #request.qSystemSetupOptions.ITSPassword#, #qryGetAgentdetails.IntegrationID#,#qryGetLoadDetails.loadnumber#,#qryGetLoadDetails.LoadId#,arguments.CompanyID,#local.dsn#,arguments.empId)>
									<cfif ITS_msg eq 1>
										<cfset arrayappend(local.loadboarditsDeleted,#qryGetLoadDetails.loadnumber#)>
									</cfif>	
								</cfif>
							</cfif>
						</cfif>
					</cfif>	
					<cfif arguments.posteverywhere eq 1>
						<cfif qryGetAgentdetails.integratewithPEP eq 1>
							<cfif request.qSystemSetupOptions.PEPsecretKey neq "" and qryGetAgentdetails.PEPcustomerKey neq "">
								<cfset p_action = 'U'>
								<cfinvoke method="Posteverywhere" LoadId="#qryGetLoadDetails.LoadId#" impref="#qryGetLoadDetails.loadnumber#" PEPcustomerKey="#qryGetAgentdetails.PEPcustomerKey#" PEPsecretKey="#request.qSystemSetupOptions.PEPsecretKey#" POSTACTION="#p_action#" dsn="#local.dsn#"  returnvariable="request.postevrywhere" CARRIERRATE=""/>
								<cfif request.postevrywhere eq 'Post Everywhere Says : Load successfully posted to Post Everywhere.'>
									<cfset arrayappend(local.posteveryWhere,#qryGetLoadDetails.loadnumber#)>
								<cfelse>
									<cfset arrayappend(local.posteveryWhere,#request.postevrywhere#)>
								</cfif>	
							</cfif>		
						</cfif>	
					<cfelse>
						<cfif qryGetAgentdetails.integratewithPEP eq 1>
							<cfif request.qSystemSetupOptions.PEPsecretKey neq "" and qryGetAgentdetails.PEPcustomerKey neq "">
								<cfif qryGetLoadDetails.ISPOST EQ 1>
									<cfinvoke method="Posteverywhere" LoadId="#qryGetLoadDetails.LoadId#"  impref="#qryGetLoadDetails.loadnumber#" PEPcustomerKey="#qryGetAgentdetails.PEPcustomerKey#" PEPsecretKey="#request.qSystemSetupOptions.PEPsecretKey#" POSTACTION="D" dsn="#local.dsn#"  returnvariable="request.postevrywhere" CARRIERRATE=""/>
									<cfif request.postevrywhere eq 'Post Everywhere Says : Load successfully removed from Post Everywhere.'>
										<cfset arrayappend(local.posteveryWhereDeleted,#qryGetLoadDetails.loadnumber#)>
									</cfif>	
								</cfif>
							</cfif>
						</cfif>
					</cfif>	
					<cfif arguments.post123loadboard eq 1>
						<cfif qryGetAgentdetails.loadBoard123 EQ 1>
							<cfif qryGetAgentdetails.loadBoard123Usename neq "" and qryGetAgentdetails.loadBoard123Password neq "">
								<cfif  variables.statutextLoadBoardDeletionOccured>
									<cfset StructInsert(frmstruct,"loadBoard123Username",#qryGetAgentdetails.loadBoard123Usename#,"yes")>
									<cfset StructInsert(frmstruct,"loadBoard123Password",#qryGetAgentdetails.loadBoard123Password#,"yes")>
									<cfset StructInsert(frmstruct,"loadnumber",#qryGetLoadDetails.loadnumber#,"yes")>
									<cfset StructInsert(frmstruct,"editid",#qryGetLoadDetails.loadid#,"yes")>
									<cfset StructInsert(frmstruct,"appDsn",#local.dsn#,"yes")>	
									<cfset StructInsert(frmstruct,"CARRIERRATE",#qryGetLoadDetails.CarrFlatRate#,"yes")>
									<cfif qryGetLoadDetails.postto123loadboard eq 1>
										<cfset p_action = 'U'>
										<cfinvoke method="callLoadboardWebservice" p_action="#p_action#" frmstruct="#frmstruct#"  returnvariable="responseLoadboardWebservice"/>
										<cfif responseLoadboardWebservice eq '123Loadboard Says : Your are successfully posted to 123 LoadBoard'>
											<cfset arrayappend(local.Loadbord123,#qryGetLoadDetails.loadnumber#)>
										<cfelse>
											<cfset arrayappend(local.Loadbord123,#qryGetLoadDetails.loadnumber#&'$'&#responseLoadboardWebservice#)> 
										</cfif>	
									<cfelse>
										<cfset p_action = 'U'>
										<cfinvoke method="callLoadboardWebservice" p_action="#p_action#" frmstruct="#frmstruct#"  returnvariable="responseLoadboardWebservice"/>
										
										<cfif responseLoadboardWebservice eq '123Loadboard Says : Your are successfully posted to 123 LoadBoard'>
											<cfset arrayappend(local.Loadbord123,#qryGetLoadDetails.loadnumber#)>
										<cfelse>
											<cfset arrayappend(local.Loadbord123,#qryGetLoadDetails.loadnumber#&'$'&#responseLoadboardWebservice#)> 
										</cfif>	
									</cfif>	
								</cfif>	
							</cfif>	
						</cfif>	
					<cfelse>
						<cfif qryGetAgentdetails.loadBoard123 EQ 1>
							<cfif qryGetAgentdetails.loadBoard123Usename neq "" and qryGetAgentdetails.loadBoard123Password neq "">
								<cfif qryGetLoadDetails.postto123loadboard eq 1>
									<cfset StructInsert(frmstruct,"loadBoard123Username",#qryGetAgentdetails.loadBoard123Usename#,"yes")>
									<cfset StructInsert(frmstruct,"loadBoard123Password",#qryGetAgentdetails.loadBoard123Password#,"yes")>
									<cfset StructInsert(frmstruct,"loadnumber",#qryGetLoadDetails.loadnumber#,"yes")>
									<cfset StructInsert(frmstruct,"editid",#qryGetLoadDetails.loadid#,"yes")>
									<cfset StructInsert(frmstruct,"appDsn",#local.dsn#,"yes")>	
									<cfset StructInsert(frmstruct,"CARRIERRATE",#qryGetLoadDetails.CarrFlatRate#,"yes")>
									<cfinvoke method="callLoadboardWebservice"  p_action="D" frmstruct="#frmstruct#"  returnvariable="responseLoadboardWebservice"/>
									<cfif responseLoadboardWebservice EQ "123Loadboard Says : This Load has been sucessfully deleted from 123 LoadBoard">
										<cfset arrayappend(local.Loadbord123Deleted,#qryGetLoadDetails.loadnumber#)>
									</cfif>
								</cfif>
							</cfif>
						</cfif>
					</cfif>
					<cfif arguments.postdatloadboard eq 1>
						<cfif qryGetAgentdetails.INTEGRATEWITHTRAN360 EQ 1>
							<cfif qryGetAgentdetails.TRANS360PASSWORD neq "" and qryGetAgentdetails.TRANS360USENAME neq "">
								<cfif variables.statutextLoadBoardDeletionOccured>
									<cfif qryGetLoadDetails.IsTransCorePst eq 1>
										<cfset p_action = 'U'>
										<!--- Begin:Ticket:836 Include Carrier Rate. --->
										<cfif NOT StructKeyExists(arguments,"postCarrierRatetoTranscore")>
											<cfset IncludeCarierRate = 0>
										<cfelse>
											<cfset IncludeCarierRate = arguments.postCarrierRatetoTranscore >
										</cfif>
										<cfinvoke method="Transcore360Webservice" impref="#qryGetLoadDetails.loadnumber#" LoadID="#qryGetLoadDetails.LoadID#" dsn="#local.dsn#" trans360Usename="#qryGetAgentdetails.TRANS360USENAME#" trans360Password="#qryGetAgentdetails.TRANS360PASSWORD#" POSTACTION="#p_action#" IncludeCarierRate="#IncludeCarierRate#" CARRIERRATE="#qryGetLoadDetails.CarrFlatRate#" returnvariable="request.Transcore360Webservice" />
										<!--- End:Ticket:836 Include Carrier Rate. --->
										<cfif request.Transcore360Webservice eq 'DAT Loadboard Says : You have successfully posted to Dat Loadboard'>
											<cfset arrayappend(local.datLoadbord,#qryGetLoadDetails.loadnumber#)>
										<cfelse>
											<cfset arrayappend(local.datLoadbord,#qryGetLoadDetails.loadnumber#&'$'&#request.Transcore360Webservice#)> 
										</cfif>	
									<cfelse>
										<cfset p_action = 'A'>
										<!--- Begin:Ticket:836 Include Carrier Rate. --->
										<cfif NOT StructKeyExists(arguments,"postCarrierRatetoTranscore")>
											<cfset IncludeCarierRate = 0>
										<cfelse>
											<cfset IncludeCarierRate = arguments.postCarrierRatetoTranscore >
										</cfif>
										<cfinvoke method="Transcore360Webservice"  LoadID="#qryGetLoadDetails.LoadID#" impref="#qryGetLoadDetails.loadnumber#" dsn="#local.dsn#" trans360Usename="#qryGetAgentdetails.TRANS360USENAME#" trans360Password="#qryGetAgentdetails.TRANS360PASSWORD#" POSTACTION="#p_action#" IncludeCarierRate="#IncludeCarierRate#" CARRIERRATE="#qryGetLoadDetails.CarrFlatRate#" returnvariable="request.Transcore360Webservice" />
										<!--- End:Ticket:836 Include Carrier Rate. --->
										<cfif request.Transcore360Webservice eq 'DAT Loadboard Says : You have successfully posted to Dat Loadboard'>
											<cfset arrayappend(local.datLoadbord,#qryGetLoadDetails.loadnumber#)>
										<cfelse>
											<cfset arrayappend(local.datLoadbord,#qryGetLoadDetails.loadnumber#&'$'&#request.Transcore360Webservice#)> 
										</cfif>	
									</cfif>	
								</cfif>	
							</cfif>		
						</cfif>
					<cfelse>
						<cfif qryGetAgentdetails.INTEGRATEWITHTRAN360 EQ 1>
							<cfif qryGetAgentdetails.TRANS360PASSWORD neq "" and qryGetAgentdetails.TRANS360USENAME neq "">
								<cfif qryGetLoadDetails.IsTransCorePst eq 1>
									<cfinvoke method="Transcore360Webservice"  LoadID="#qryGetLoadDetails.LoadID#" impref="#qryGetLoadDetails.loadnumber#" dsn="#local.dsn#" trans360Usename="#qryGetAgentdetails.TRANS360USENAME#" trans360Password="#qryGetAgentdetails.TRANS360PASSWORD#" POSTACTION="D" returnvariable="request.Transcore360Webservice" />
									<cfif request.Transcore360Webservice EQ 'DAT Loadboard Says : This Load sucessfully deleted from DAT Loadboard'>
										<cfset arrayappend(local.datLoadbordDeleted,#qryGetLoadDetails.loadnumber#)>
									</cfif>
								</cfif>
							</cfif>
						</cfif>
					</cfif>	
				</cfif> 
			</cfloop> 

			<cfset local.DirectFreightLoadboard=arraytolist(local.DirectFreightLoadboard,", ")>
			<cfset local.DirectFreightLoadboardDeleted=arraytolist(local.DirectFreightLoadboardDeleted,", ")>
			<cfset local.loadboardits=arraytolist(local.loadboardits,", ")>
			<cfset local.loadboarditsDeleted=arraytolist(local.loadboarditsDeleted,", ")>
			<cfset local.datLoadbord=arraytolist(local.datLoadbord,", ")>
			<cfset local.datLoadbordDeleted=arraytolist(local.datLoadbordDeleted,", ")>
			<cfset local.Loadbord123=arraytolist(local.Loadbord123,", ")>
			<cfset local.Loadbord123Deleted=arraytolist(local.Loadbord123Deleted,", ")>
			<cfset local.posteveryWhere=arraytolist(local.posteveryWhere,", ")>
			<cfset local.posteveryWhereDeleted=arraytolist(local.posteveryWhereDeleted,", ")>
			<cfset local.UpdatedShipDate=arraytolist(local.UpdatedShipDate,", ")>
			<cfset local.LoadStatus=arraytolist(local.LoadStatus,", ")>
			<cfset local.status=true>
			<cfset local.LoadBoardDeletionOccuredStatus=variables.statutextLoadBoardDeletionOccured>
			<cfreturn  serializeJSON(local)>
			<cfcatch type="any">
				<cfset errStruct = structNew()>
				<cfset errStruct.status=false>
				<cfreturn  serializeJSON(errStruct)>
			</cfcatch>
		</cftry>
	</cffunction>
	
</cfcomponent>	