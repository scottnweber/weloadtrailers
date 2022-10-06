<cfparam name="event" default="agent">
<cfoutput>
<style>
	.below-navleft{
		width:630px;
	}
	.below-navleft ul li a {
	    padding: 0 8px 0 8px;
	}
</style>
<cfinvoke component="#variables.objloadGateway#" method="getSystemSetupOptions" returnvariable="request.qSystemOptions" />
<div class="below-navleft" style="width: 890px;">
	
	<ul>
		<li><a href="index.cfm?event=companyinfo&#Session.URLToken#" <cfif listFindNoCase("companyinfo", event)> class="active" </cfif>>Company Info</a></li>
		<li><a href="index.cfm?event=systemsetup&#Session.URLToken#" <cfif event is 'systemsetup'> class="active" </cfif>>Configuration Options</a></li>
		<cfif request.qSystemOptions.BillFromCompanies eq 1>
			<li><a href="index.cfm?event=BillFromCompanies&#Session.URLToken#" <cfif listFindNoCase('BillFromCompanies,AddBillFromCompany', event)> class="active" </cfif>>Bill From Companies</a></li>
		</cfif>
		<li><a href="index.cfm?event=loadstatussetup&#Session.URLToken#" <cfif event is 'loadstatussetup'> class="active" </cfif>>Load Status</a></li>
		<li><a href="index.cfm?event=crmNoteTypes&#Session.URLToken#" <cfif event is 'crmNoteTypes' or event is 'addCRMNoteType'> class="active" </cfif>>CRM Call Note Types</a></li>
		<li><a href="index.cfm?event=attachmentTypes&#session.URLToken#" <cfif listFindNoCase("attachmentTypes,addAttachmentType", event)> class="active" </cfif>>Attachment Types</a></li>
		<cfif request.qSystemOptions.OnBoardCarrier EQ 1>
			<li><a href="index.cfm?event=OnboardCarrierDocs&#session.URLToken#" <cfif listFindNoCase("OnboardCarrierDocs,AddOnBoardingDoc,OnboardSetting,OnboardEquipments,DocsTobeAttached", event)> class="active" </cfif>>Onboard Carrier Setup</a></li>
		</cfif>
		<cfif listFindNoCase(session.rightsList, 'editUserRoles')>
			<li><a href="index.cfm?event=userRoles&#Session.URLToken#" <cfif listFindNoCase("userRoles,loadStatus", event)> class="active" </cfif>>User Roles</a></li>
		</cfif>
	</ul>
<div class="clear"></div>
</div>
<div class="below-navright" id="helpLink" style="padding-top: 4px;width: 30px;">
</div>
	<div style="float:right;margin-right: -100px;margin-top: -59px;"><a href="index.cfm?event=feedback&#Session.URLToken#"><img src="images/support.png" width="100px" border="0"></a></div>
	<div style="float:right;margin-top: -57px;"><a href="javascript:void(0);" onclick="window.open('index.cfm?event=postNote&#session.URLToken#','Map','height=600,width=800');"><img src="images/postedNoteIcon.png" width="100px" border="0"></a></div>
</cfoutput>
