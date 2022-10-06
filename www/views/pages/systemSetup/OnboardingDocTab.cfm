<cfoutput>
	<div class="tabsload ui-tabs ui-widget ui-widget-content ui-corner-all" style="float:left;border:none;padding-bottom: 0;margin-top: -5px;background: #request.qGetSystemSetupOptions.BackgroundColor# !important;">
		<ul class="ui-tabs-nav ui-helper-reset ui-helper-clearfix ui-widget-header ui-corner-all" style="height:27px;background: #request.qGetSystemSetupOptions.BackgroundColor# !important;border:none; ">

			<li class="ui-state-default ui-corner-top <cfif listFindNoCase("OnboardCarrierDocs,AddOnBoardingDoc", url.event)>ui-tabs-active ui-state-active</cfif>">
				<a class="ui-tabs-anchor" href="index.cfm?event=OnboardCarrierDocs&#session.URLToken#">Documents to be SIGNED</a>
			</li>
			<li class="ui-state-default ui-corner-top <cfif listFindNoCase("DocsTobeAttached", url.event)>ui-tabs-active ui-state-active</cfif>">
				<a class="ui-tabs-anchor" href="index.cfm?event=DocsTobeAttached&#session.URLToken#">Documents to be ATTACHED</a>
			</li>
			<li class="ui-state-default ui-corner-top <cfif listFindNoCase("OnboardEquipments", url.event)>ui-tabs-active ui-state-active</cfif>">
				<a class="ui-tabs-anchor" href="index.cfm?event=OnboardEquipments&#session.URLToken#">Equipment</a>
			</li>
			<li class="ui-state-default ui-corner-top <cfif listFindNoCase("OnboardSetting", url.event)>ui-tabs-active ui-state-active</cfif>">
				<a class="ui-tabs-anchor" href="index.cfm?event=OnboardSetting&#session.URLToken#">Onboarding Settings</a>
			</li>
		</ul>
	</div>
	<div class="clear"></div>
</cfoutput>