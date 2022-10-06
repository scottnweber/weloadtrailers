
<cfsetting requesttimeout="500">
<!---This is a scheduler script--->
<cfscript>
	
	if(Not isDefined("Application.objLoadGatewayAdd")){
	  Application.objLoadGatewayAdd =getGateway("gateways.loadgatewayAdd", MakeParameters("dsn=#Application.dsn#,pwdExpiryDays=#Application.pwdExpiryDays#"));
	}
	if(Not isDefined("Application.objloadGateway")){
	  Application.objloadGateway = getGateway("gateways.loadgateway", MakeParameters("dsn=#Application.dsn#,pwdExpiryDays=#Application.pwdExpiryDays#"));
	}
	if(Not isDefined("Application.objLoadGatewaynew")){
	  Application.objLoadGatewaynew =getGateway("gateways.loadgatewaynew", MakeParameters("dsn=#Application.dsn#,pwdExpiryDays=#Application.pwdExpiryDays#"));
	}
	if(Not isDefined("Application.objAgentGateway")){
	  Application.objAgentGateway = getGateway("gateways.agentgateway", MakeParameters("dsn=#Application.dsn#,pwdExpiryDays=#Application.pwdExpiryDays#"));
	 }
	if(Not isDefined("Application.objLoadgatewayUpdate")){
	  Application.objLoadgatewayUpdate = getGateway("gateways.loadgatewayUpdate", MakeParameters("dsn=#Application.dsn#,pwdExpiryDays=#Application.pwdExpiryDays#"));
	 }

	// 290615 added  
	if(	NOT isDefined("Application.objProMileGateWay")){
		Application.objProMileGateWay = getGateway("gateways.promile", MakeParameters("dsn=#Application.dsn#,pwdExpiryDays=#Application.pwdExpiryDays#"));
	}
	if(	NOT isDefined("Application.objShipDateUpdateGateWay")){
		Application.objShipDateUpdateGateWay = getGateway("gateways.ShipDateUpdate", MakeParameters("dsn=#Application.dsn#,pwdExpiryDays=#Application.pwdExpiryDays#"));
	}

</cfscript>

<cfinvoke component="#Application.objloadGateway#" method="getSystemSetupOptions" returnvariable="request.qGetSystemSetupOptions" />
<cfif isDefined("request.qGetSystemSetupOptions.LoadLogLimit")>
	<cfinvoke component="#Application.objLoadGateway#" method="clearLoadLog" returnvariable="clearLoadLogReturn">
		<cfinvokeargument name="days" value="#request.qGetSystemSetupOptions.LoadLogLimit#">	
	</cfinvoke>
	<cfoutput>
		<cfif clearLoadLogReturn EQ 1>
			Success
		<cfelse>
			Failed. Message: <cfdump var="#clearLoadLogReturn#">
		</cfif>
	</cfoutput>	
</cfif>