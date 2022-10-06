<cfinvoke component="#variables.objloadGateway#" method="getSystemSetupOptions" returnvariable="request.qSystemSetupOptions" />
<cfinvoke component="#variables.objAgentGateway#" method="getAllStaes" returnvariable="request.qStates" />
<cfinvoke component="#variables.objequipmentGateway#" method="getloadEquipments" returnvariable="request.qEquipments" />
<cfinvoke component="#variables.objunitGateway#" method="getloadUnits" status="True" returnvariable="request.qUnits" />
<cfinvoke component="#variables.objclassGateway#" method="getloadClasses" status="True" returnvariable="request.qClasses" />
<cfinvoke component="#variables.objloadGateway#" method="getcurAgentMaildetails" returnvariable="request.qcurMailAgentdetails" employeID="#session.empid#" />
<cfset Secret = application.dsn>
<cfset TheKey = 'NAMASKARAM'>
<cfset Encrypted = Encrypt(Secret, TheKey)>
<cfset dsn = URLEncodedFormat(ToBase64(Encrypted))>
<cfquery  name="request.qoffices" datasource="#application.dsn#">
   select CarrierOfficeID,location,carrierID from carrieroffices  where location <> '' and carrierID=null
    and carrierID in (select carrierID from carriers where CompanyID = <cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar">)
   ORDER BY Location ASC
</cfquery> 
	<cfif isdefined("url.loadid") and len(trim(url.loadid)) gt 1 >
		<cfinvoke component="#variables.objloadGateway#" method="getAllLoads" loadid="#loadID#" stopNo="0" returnvariable="request.qLoads" />
		 <cfset loadStatus=request.qLoads.STATUSTEXT>
		 <cfset impref=request.qLoads.LoadNumber>
		<cfset loadIDN = url.loadid>
	<cfelse>
		<cfset loadIDN = "">
		<cfset impref = "">
	</cfif>
	<cfif isdefined("url.totStops") and len(trim(url.totStops))>
		<cfset totStops = url.totStops>
		<cfset totalStops = totStops + 1>	
	</cfif>
	<cfif isdefined("url.LoadNumber") and len(trim(url.LoadNumber))>
	  	<cfset loadNumber = url.LoadNumber>
	<cfelse>
		<cfset loadNumber = "">
  	</cfif>
	<cfif isdefined("url.currentTab") and len(trim(url.currentTab))>
	  	<cfset currentTab = url.currentTab>
  	</cfif>
	<cfif request.qSystemSetupOptions.freightBroker>
		<cfset variables.freightBrokerReport = "Carrier">
	<cfelse>
		<cfset variables.freightBrokerReport = "Dispatch">
	</cfif>
	<cfset htmlString = "">
		<cfset stopNumber = url.stopNo>
		<cfset StopNoIs = stopNumber - 1>
		<cfsavecontent variable="content">
			<cfoutput>
			<div class="white-con-area">
				<div id="stop#stopNumber#" style="display:none">
					<div id="tabs#stopNumber#" class="tabsload">
						<ul style="height:27px;">
							<li><a href="##tabs-1" style="font-weight: bolder;font-size: 12px;padding-bottom: 4px;">Stop #stopNumber#</a></li>
							<li><a href="index.cfm?event=loadIntermodal&stopno=#stopNumber#&loadID=#loadID#&#Session.URLToken#">Intermodal</a></li>
							<div style="float: left;width: 23%;margin-left: 27px;">
								<div class="form-con" style="width:203%" id="StopNo#stopNumber#">
									<ul class="load-link" id="ulStopNo#stopNumber#" style="line-height:26px;">
										<cfif IsDefined("loadIDN")>
											<cfloop from="1" to="#stopNumber#" index='stpNoid'>
												<cfif stpNoid is 1>
													<li><a href="##StopNo#stpNoid#">###stpNoid#</a></li>
												<cfelse>
													<li><a href="##StopNo#stpNoid#">###stpNoid#</a></li>
												</cfif>
											</cfloop>
										<cfelse>
											<li><a href="##StopNo#stpNoid#">###stopNumber#</a></li>
										</cfif>
									</ul>
									<div class="clear"></div>
								</div>
							</div>
							<div style="float: left; width: 56%;height: 26px;">
								<h2 style="color:white;font-weight:bold;margin-top: -8px;">Load###Ucase(loadnumber)#</h2>
							</div>
						</ul>
						<div id="tabs-1">
							<cfinclude template="loadStopAjax.cfm">
						</div>				
					</div>
					<div class="form-heading-loop" style="background-color: #request.qSystemSetupOptions.BackgroundColorForContent# !important;position: relative;top: -15px;">
						<div class="rt-button3">
						</div>
						<div class="clear"></div>
						<cfif ListContains(session.rightsList,'runReports',',')>
							<cfset carrierReportOnClick = "window.open('../reports/loadReportForCarrierConfirmation.cfm?loadid=#loadIDN#&#session.URLToken#')">
						<cfelse>
							<cfset carrierReportOnClick = "">
						</cfif>
						<cfif isdefined("url.loadid") and len(trim(url.loadid)) gt 1>

							<div class="right bottom-btns" style="height:30px;width: 460px;">
								<div style="margin-top: -30px;margin-left: 27px;">
		                            <input name="addstopButton" disabled="yes" type="button" class="green-btn" onclick="AddStop('stop#(stopNumber+1)#',#(stopNumber+1)#);setStopValue();" value="Add Stop"/>
									<input style="color:##800000;" name="" type="button" class="red-btn" onclick="deleteStop('stop#stopNumber#',#(stopNumber-1)#,#showItems#,'#nextLoadStopId#','#application.DSN#','#loadIDN#');setStopValue();" value="Delete Stop" /> 
		                        </div>
								<div> 
		                            <input name="submit" type="submit" class="green-btn" onClick="return saveButStayOnPage('#url.loadid#');" onFocus="checkUnload();" value="Save" disabled="disabled" tabindex="#evaluate(currentTab+2)#"/>
								</div>
								<div class="clear"></div>
		                        
							</div>
						<cfelse>
							<div class="rt-button" style="margin-top: -30px;">
								
								<input name="addstopButton" disabled="yes" type="button" class="green-btn" onclick="AddStop('stop#(stopNumber+1)#',#(stopNumber+1)#);setStopValue();" value="Add Stop"/>
								<input style="color:##800000;width: 134px !important;" name="" type="button" class="red-btn" onclick="deleteStop('stop#stopNumber#',#(stopNumber-1)#,#showItems#,'#nextLoadStopId#','#application.DSN#','#loadIDN#');setStopValue();" value="Delete Stop" />
								<input name="submit" type="submit" class="green-btn" onClick="return saveButStayOnPage('#url.loadid#');" onFocus="checkUnload();" value="Save" disabled="disabled" tabindex="#evaluate(currentTab+2)#"/>
							</div>
						</cfif>
						<input type="hidden" name="shipperFlag#stopNumber#" id="shipperFlag#stopNumber#" value="0">
						<input type="hidden" name="consigneeFlag#stopNumber#" id="consigneeFlag#stopNumber#" value="0">
						<br class="clear"/>
						<div class="clear"></div>
					</div>
					<div class="white-bottom">&nbsp;</div>
				</div>
			</div>
			<div class="gap"></div>
		</cfoutput>
		</cfsavecontent>
		<cfset htmlString &= "#content#">
		<cfset htmlString &= "<div class='gap'></div><div class='gap'></div>">
			
		<cfoutput>#htmlString#</cfoutput>	
		
		
		