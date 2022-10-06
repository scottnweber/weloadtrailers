<cfoutput>
	<div class="tabsload ui-tabs ui-widget ui-widget-content ui-corner-all" style="float:left;border:none;padding-bottom: 0;margin-top: -5px;background: #request.qGetSystemSetupOptions.BackgroundColor# !important;">
		<ul class="ui-tabs-nav ui-helper-reset ui-helper-clearfix ui-widget-header ui-corner-all" style="height:27px;background: #request.qGetSystemSetupOptions.BackgroundColor# !important;border:none; ">

			<li class="ui-state-default ui-corner-top <cfif listFindNoCase("userRoles", url.event)>ui-tabs-active ui-state-active</cfif>">
				<a class="ui-tabs-anchor" href="index.cfm?event=userRoles&#session.URLToken#<cfif structKeyExists(form, "RoleID") AND url.event NEQ "userRoles">&RoleID=#form.RoleID#</cfif>">Permissions</a>
			</li>
			<li class="ui-state-default ui-corner-top <cfif listFindNoCase("LoadStatus", url.event)>ui-tabs-active ui-state-active</cfif>">
				<a class="ui-tabs-anchor" href="index.cfm?event=LoadStatus&#session.URLToken#<cfif structKeyExists(form, "RoleID") AND url.event NEQ "LoadStatus">&RoleID=#form.RoleID#</cfif>">Load Status</a>
			</li>
		</ul>
	</div>
	<div class="clear"></div>
</cfoutput>