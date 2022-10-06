<cfoutput>
<cfif not structKeyExists(request, "qGetSystemSetupOptions")>
	<cfinvoke component="#variables.objloadGateway#" method="getSystemSetupOptions" returnvariable="request.qGetSystemSetupOptions" />
</cfif>
<div style="float:left;">
	<div id="customerTabs" class="tabsload ui-tabs ui-widget ui-widget-content ui-corner-all" style="float:left;border:none;padding-bottom: 0;margin-top: -5px;background: #request.qGetSystemSetupOptions.BackgroundColor# !important;">
		<ul class="ui-tabs-nav ui-helper-reset ui-helper-clearfix ui-widget-header ui-corner-all" style="height:27px;background: #request.qGetSystemSetupOptions.BackgroundColor# !important;border:none; ">
	    	<li class="ui-state-default ui-corner-top <cfif url.event eq 'addcarrier'> ui-tabs-active ui-state-active </cfif>">
	    		<cfif request.qGetSystemSetupOptions.freightBroker EQ 0>
	              	<a class="ui-tabs-anchor" href="index.cfm?event=adddriver&#session.URLToken#&CarrierID=#url.CarrierID#">Driver</a>
	            <cfelseif request.qGetSystemSetupOptions.freightBroker EQ 1>
	              	<a class="ui-tabs-anchor" href="index.cfm?event=addcarrier&#session.URLToken#&CarrierID=#url.CarrierID#">Carrier</a>
	            <cfelse>
					<cfif structKeyExists(url, "iscarrier") and url.iscarrier eq 1>
						<a class="ui-tabs-anchor" href="index.cfm?event=addcarrier&#session.URLToken#&CarrierID=#url.CarrierID#&iscarrier=1">Carrier</a>
					<cfelse>
						<a class="ui-tabs-anchor" href="index.cfm?event=adddriver&#session.URLToken#&CarrierID=#url.CarrierID#&iscarrier=0">Driver</a>
					</cfif>
	            </cfif>
	    	</li>
	    	<li class="ui-state-default ui-corner-top <cfif url.event eq 'CarrierContacts' or url.event eq 'addCarrierContact'> ui-tabs-active ui-state-active </cfif>">
	    		<a class="ui-tabs-anchor" href="index.cfm?event=CarrierContacts&#session.URLToken#&carrierid=#url.carrierid#<cfif request.qGetSystemSetupOptions.FreightBroker EQ 2 AND structKeyExists(url, "iscarrier") AND url.iscarrier eq 1>&IsCarrier=1</cfif>">Contacts</a>
	    	</li>
	    	<cfif request.qGetSystemSetupOptions.CarrierLNI EQ 2>
		    	<li class="ui-state-default ui-corner-top <cfif url.event eq 'CarrierLookup'> ui-tabs-active ui-state-active </cfif>">
		    		<a class="ui-tabs-anchor" href="index.cfm?event=CarrierLookup&#session.URLToken#&carrierid=#url.carrierid#<cfif request.qGetSystemSetupOptions.FreightBroker EQ 2 AND structKeyExists(url, "iscarrier") AND url.iscarrier eq 1>&IsCarrier=1</cfif>">Carrier Lookout</a>
		    	</li>
		    </cfif>
	    	<li class="ui-state-default ui-corner-top <cfif url.event eq 'CarrierCRMNotes'> ui-tabs-active ui-state-active </cfif>">
	    		<a class="ui-tabs-anchor" href="index.cfm?event=CarrierCRMNotes&#session.URLToken#&carrierid=#url.carrierid#<cfif request.qGetSystemSetupOptions.FreightBroker EQ 2 AND structKeyExists(url, "iscarrier") AND url.iscarrier eq 1>&IsCarrier=1</cfif>">CRM</a>
	    	</li>
	     	<li class="ui-state-default ui-corner-top <cfif url.event eq 'CarrierLanes'> ui-tabs-active ui-state-active </cfif>">
	    		<a class="ui-tabs-anchor" href="index.cfm?event=CarrierLanes&#session.URLToken#&carrierid=#url.carrierid#<cfif request.qGetSystemSetupOptions.FreightBroker EQ 2 AND structKeyExists(url, "iscarrier") AND url.iscarrier eq 1>&IsCarrier=1</cfif>">Lanes</a>
	    	</li>
		</ul>
	</div>
</div>
</cfoutput>