<cfparam name="event" default="agent">
<cfoutput>
<div class="below-navleft">
	<ul>
		<li><a href="index.cfm?event=systemsetup&#Session.URLToken#" <cfif event is 'systemsetup'> class="active" </cfif>>Long Short Miles</a></li>
		<li><a href="index.cfm?event=quickRateAndMilesCalc&#session.URLToken#" <cfif event is 'quickRateAndMilesCalc'> class="active" </cfif>>Quick Miles and Rate Calculation</a></li>
	</ul>
<div class="clear"></div>
</div>
<div class="below-navright">
	<p align="right">Logged in :<cfif isdefined('session.AdminUserName')> #session.AdminUserName# </cfif></p>
</div>
</cfoutput>