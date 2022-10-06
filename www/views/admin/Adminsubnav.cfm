<cfparam name="event" default="agent">
<cfoutput>
<div class="below-navleft" style="width: 890px;">
	<ul>
		<li><a href="index.cfm?event=agent&sortorder=asc&sortby=Name&#session.URLToken#" <cfif event is 'agent' or event is 'addagent:process'> class="active" </cfif>>Users</a></li>
		<li><a href="index.cfm?event=addagent&#session.URLToken#" <cfif event is 'addagent'> class="active" </cfif>>Add User</a></li>
		<li><a href="index.cfm?event=office&#session.URLToken#" <cfif event is 'office' or event is 'addoffice:process'> class="active" </cfif>>Offices</a></li>
		<li><a href="index.cfm?event=addoffice&#session.URLToken#" <cfif event is 'addoffice'> class="active" </cfif>>Add Office</a></li>
		<li><a href="index.cfm?event=AlertHistory&#session.URLToken#" <cfif event is 'AlertHistory'> class="active" </cfif>>Alert History</a></li>
	</ul>
<div class="clear"></div>
</div>
<div class="below-navright" id="helpLink" style="padding-top: 4px;width: 30px;">
</div>
<div style="float:right;margin-right: -100px;margin-top: -59px;"><a href="index.cfm?event=feedback&#Session.URLToken#"><img src="images/support.png" width="100px" border="0"></a></div>
<div style="float:right;margin-top: -57px;"><a href="javascript:void(0);" onclick="window.open('index.cfm?event=postNote&#session.URLToken#','Map','height=600,width=800');"><img src="images/postedNoteIcon.png" width="100px" border="0"></a></div>
</cfoutput>

