<cfparam name="event" default="agent">
<cfinvoke component="#variables.objloadGateway#" method="getLoadSystemSetupOptions" returnvariable="request.qSystemSetupOptions1" />
<cfoutput>
<div class="below-navleft" style="width: 890px;">
	<ul>
		<li><a href="index.cfm?event=Reports&#Session.URLToken#" <cfif event is 'Reports'> class="active" </cfif>>Sales</a></li>
		<li><a href="index.cfm?event=SalesDetail&#Session.URLToken#" <cfif event EQ 'SalesDetail'> class="active" </cfif>>Sales Detail</a></li>
		<cfif ListContains(session.rightsList,'runReports',',') AND NOT ListContains(session.rightsList,'HideCustomerPricing',',')>
			<cfif NOT ListContains(session.rightsList,'SalesRepReport',',') OR session.currentusertype EQ "Administrator">
				<cfif request.qSystemSetupOptions1.freightBroker NEQ 0>
					<li><a href="index.cfm?event=CarrierQuoteReport&#Session.URLToken#" <cfif event is 'CarrierQuoteReport'> class="active" </cfif>>Carrier Quote</a></li>
				</cfif>
			</cfif>
			<li><a href="index.cfm?event=AgingReports&#session.URLToken#" <cfif event is 'AgingReports'> class="active" </cfif>>Aging</a></li>
			<cfif NOT ListContains(session.rightsList,'SalesRepReport',',') OR session.currentusertype EQ "Administrator">
				<!--- BEGIN: 766: Feature Request- Excel Export Feature --->
				<cfif structkeyexists(session,"rightslist") AND ListContains(session.rightsList,'runExport',',')>
					<li><a href="index.cfm?event=ExportExcel&#session.URLToken#" <cfif event is 'ExportExcel'> class="active" </cfif>>Export</a></li>
				</cfif>
				<!--- END: 766: Feature Request- Excel Export Feature --->
				<li><a href="index.cfm?event=Form1099&#Session.URLToken#" <cfif event is 'Form1099'> class="active" </cfif>>1099</a></li>
				<li><a href="index.cfm?event=DriverSettlementReport&#Session.URLToken#" <cfif event is 'DriverSettlementReport'> class="active" </cfif>>Driver Settlement Report</a></li>
			</cfif>
			<cfif request.qSystemSetupOptions1.QuickBooksIntegration EQ 1 AND structkeyexists(session,"rightslist") AND  ListContains(session.rightsList,'QuickBooks',',')>
				<li><a href="index.cfm?event=QuickBooksExport&#Session.URLToken#" <cfif event EQ 'QuickBooksExport' or event EQ 'QuickBooksExportAP' or event EQ 'QuickBooksExportHistory' or event EQ 'QBNotExported'> class="active" </cfif>>QuickBooks Export</a></li>
			</cfif>
			<li><a href="index.cfm?event=Dashboard&#Session.URLToken#" <cfif event eq 'Dashboard'> class="active" </cfif>>Dashboard</a></li>
		</cfif>
	</ul>
<div class="clear"></div>
</div>
<div class="below-navright" id="helpLink" style="padding-top: 4px;width: 30px;">
</div>
<div style="float:right;margin-right: -100px;margin-top: -59px;"><a href="index.cfm?event=feedback&#Session.URLToken#"><img src="images/support.png" width="100px" border="0"></a></div>
<div style="float:right;margin-top: -57px;"><a href="javascript:void(0);" onclick="window.open('index.cfm?event=postNote&#session.URLToken#','Map','height=600,width=800');"><img src="images/postedNoteIcon.png" width="100px" border="0"></a></div>

</cfoutput>