<cfparam name="message" default="">
<cfparam name="url.sortorder" default="desc">
<cfparam name="sortby"  default="">
<cfsilent>	
<cfif isdefined("form.searchText") and len(searchText)>	
	<cfinvoke component="#variables.objCutomerGateway#" method="getSearchedStop" searchText="#form.searchText#" returnvariable="request.qStop" />
	<cfif request.qStop.recordcount lte 0>
		<cfset message="No match found">
	</cfif>
<cfelse>
    <cfif isdefined("url.stopid") and len(url.stopid) gt 1>	
    	<cfinvoke component="#variables.objCutomerGateway#" method="deleteStop" CustomerStopID="#url.stopid#" returnvariable="message" />	
    </cfif>
</cfif>
<cfif isdefined("url.customerId") and len(url.customerId) gt 1> 
    <cfinvoke component="#variables.objCutomerGateway#" method="getAllStopByCustomer" customerId="#url.customerID#" returnvariable="request.qStop" />
    <cfinvoke component="#variables.objCutomerGateway#" method="getAllCustomers" CustomerID="#url.customerid#" returnvariable="request.qCustomer" />
</cfif>
</cfsilent>
<cfoutput>
<h1 style="float: left;"><span style="padding-left:160px;">#request.qCustomer.CustomerName#</span></h1>
<div style="clear:both"></div>
<cfif isdefined("message") and len(message)>
<div class="msg-area">#message#</div>
</cfif>
<cfif isDefined("url.sortorder") and url.sortorder eq 'desc'>
          <cfset sortorder="asc">
 <cfelse>
          <cfset sortorder="desc">
</cfif>
<cfif isDefined("url.sortby")>
    <cfif isdefined("url.customerId") and len(url.customerId) gt 1> 
        <cfinvoke component="#variables.objCutomerGateway#" method="getAllStopByCustomer" CustomerID="#url.customerid#" sortorder="#sortorder#" sortby="#sortby#"  returnvariable="request.qStop" />
    <cfelse>
        <cfinvoke component="#variables.objCutomerGateway#" method="getAllStopByCustomer" sortorder="#sortorder#" sortby="#sortby#"  returnvariable="request.qStop" />
    </cfif>
</cfif> 
<cfif isdefined("url.customerid") and len(trim(url.customerid)) gt 1>
<div id="customerTabs" class="tabsload ui-tabs ui-widget ui-widget-content ui-corner-all" style="float:left;border:none;padding-bottom: 0;">
    <ul class="ui-tabs-nav ui-helper-reset ui-helper-clearfix ui-widget-header ui-corner-all" style="height:27px;background: ##dfeffc !important;border:none; ">
        <li class="ui-state-default ui-corner-top">
            <a class="ui-tabs-anchor" href="index.cfm?event=addcustomer&#session.URLToken#&customerId=#url.customerId#">Customer</a>
        </li>
        <li class="ui-state-default ui-corner-top">
            <a class="ui-tabs-anchor" href="index.cfm?event=CustomerContacts&#session.URLToken#&customerId=#url.customerId#">Contacts</a>
        </li>
        <li class="ui-state-default ui-corner-top">
            <a class="ui-tabs-anchor" href="index.cfm?event=CRMNotes&#session.URLToken#&customerId=#url.customerId#">CRM</a>
        </li>
        <li class="ui-state-default ui-corner-top ui-tabs-active ui-state-active">
            <a class="ui-tabs-anchor">Stops</a>
        </li>
        <li class="ui-state-default ui-corner-top">
            <a class="ui-tabs-anchor add_quote_txt" href="index.cfm?event=addstop&#session.URLToken#&customerId=#url.customerId#">Add Stops</a>
        </li>
    </ul>
</div>
</cfif>
<div class="search-panel" style="width:911px;">
    <div class="form-search" style="margin-left:115px; ">
        <cfform action="index.cfm?event=stop&#session.URLToken#&customerid=#url.customerid#" method="post" preserveData="yes">
        	<fieldset>
        		<cfinput name="searchText" type="text" required="yes" message="Please enter search text"  />
        		<input name="" type="submit" class="s-bttn" value="Search" style="width:56px;" />
        		<div class="clear"></div>
        	</fieldset>
        </cfform>			
    </div>
    <div class="addbutton"><a href="index.cfm?event=addstop<cfif isdefined("url.customerId") and len(url.customerId) gt 1>&customerid=#url.customerId#</cfif>&#session.URLToken#">Add New</a></div>
</div>
<div style="clear:both"></div>
<div class="white-con-area" style="height: 36px;background-color: ##82bbef;margin-top: -4px;width: 998px;">
    <h2 style="color:white;font-weight:bold;text-align: center;">All Stops</h2>
</div>
<table width="100%" border="0" class="data-table" cellspacing="0" cellpadding="0">
      <thead>
      <tr>
    	<th width="5" align="left" valign="top"><img src="images/top-left.gif" alt="" width="5" height="23" /></th>
    	<th width="29" align="center" valign="middle" class="head-bg">&nbsp;</th>
    	<th width="120" align="center" valign="middle" class="head-bg" onclick="document.location.href='index.cfm?event=stop&sortorder=#sortorder#&sortby=CustomerStopName&#session.URLToken#<cfif isdefined("url.customerId") and len(url.customerId) gt 1>&customerid=#url.customerId#</cfif>'">Stop Name</th>
    	<th width="120" align="center" valign="middle" class="head-bg" onclick="document.location.href='index.cfm?event=stop&sortorder=#sortorder#&sortby=Location&#session.URLToken#<cfif isdefined("url.customerId") and len(url.customerId) gt 1>&customerid=#url.customerId#</cfif>'">Address</th>
    	<th width="169" align="center" valign="middle" class="head-bg" onclick="document.location.href='index.cfm?event=stop&sortorder=#sortorder#&sortby=ContactPerson&#session.URLToken#<cfif isdefined("url.customerId") and len(url.customerId) gt 1>&customerid=#url.customerId#</cfif>'">Contact Person</th>
    	<th width="139" align="center" valign="middle" class="head-bg" onclick="document.location.href='index.cfm?event=stop&sortorder=#sortorder#&sortby=Phone&#session.URLToken#<cfif isdefined("url.customerId") and len(url.customerId) gt 1>&customerid=#url.customerId#</cfif>'">Contact No.</th>
    	<th width="109" align="center" valign="middle" class="head-bg" onclick="document.location.href='index.cfm?event=stop&sortorder=#sortorder#&sortby=EmailID&#session.URLToken#<cfif isdefined("url.customerId") and len(url.customerId) gt 1>&customerid=#url.customerId#</cfif>'">Email</th>
    	<th width="109" align="center" valign="middle" class="head-bg2" onclick="document.location.href='index.cfm?event=stop&sortorder=#sortorder#&sortby=CustomerName&#session.URLToken#<cfif isdefined("url.customerId") and len(url.customerId) gt 1>&customerid=#url.customerId#</cfif>'">Customer</th>
    	<th width="5" align="right" valign="top"><img src="images/top-right.gif" alt="" width="5" height="23" /></th>
      </tr>
      </thead>
      <tbody>
    	<cfloop query="request.qStop">	
    	    <cfinvoke component="#variables.objCutomerGateway#" method="getAllCustomers" CustomerID="#request.qStop.customerID#" returnvariable="request.qCustomer" />
    	<tr <cfif request.qStop.currentRow mod 2 eq 0>bgcolor="##FFFFFF"<cfelse>bgcolor="##f7f7f7"</cfif>>
            <td height="20" class="sky-bg">&nbsp;</td>
            <td class="sky-bg2" valign="middle" onclick="document.location.href='index.cfm?event=addstop<cfif isdefined("url.customerId") and len(url.customerId) gt 1>&customerid=#url.customerId#</cfif>&stopid=#request.qStop.CustomerStopID#&#session.URLToken#'" align="center">#request.qStop.currentRow#</td>
            <td class="normal-td" valign="middle" onclick="document.location.href='index.cfm?event=addstop<cfif isdefined("url.customerId") and len(url.customerId) gt 1>&customerid=#url.customerId#</cfif>&stopid=#request.qStop.CustomerStopID#&#session.URLToken#'" align="left"><a title="#request.qStop.CustomerStopName# #request.qStop.Location# #request.qStop.ContactPerson# #request.qStop.Phone# #request.qStop.emailID#" href="index.cfm?event=addstop<cfif isdefined("url.customerId") and len(url.customerId) gt 1>&customerid=#url.customerId#</cfif>&stopid=#request.qStop.CustomerStopID#&#session.URLToken#">#request.qStop.CustomerStopName#</a></td>
            <td class="normal-td" valign="middle" onclick="document.location.href='index.cfm?event=addstop<cfif isdefined("url.customerId") and len(url.customerId) gt 1>&customerid=#url.customerId#</cfif>&stopid=#request.qStop.CustomerStopID#&#session.URLToken#'" align="left"><a title="#request.qStop.CustomerStopName# #request.qStop.Location# #request.qStop.ContactPerson# #request.qStop.Phone# #request.qStop.emailID#" href="index.cfm?event=addstop<cfif isdefined("url.customerId") and len(url.customerId) gt 1>&customerid=#url.customerId#</cfif>&stopid=#request.qStop.CustomerStopID#&#session.URLToken#">#request.qStop.Location#</a></td>
            <td class="normal-td" valign="middle" onclick="document.location.href='index.cfm?event=addstop<cfif isdefined("url.customerId") and len(url.customerId) gt 1>&customerid=#url.customerId#</cfif>&stopid=#request.qStop.CustomerStopID#&#session.URLToken#'" align="left"><a title="#request.qStop.CustomerStopName# #request.qStop.Location# #request.qStop.ContactPerson# #request.qStop.Phone# #request.qStop.emailID#" href="index.cfm?event=addstop<cfif isdefined("url.customerId") and len(url.customerId) gt 1>&customerid=#url.customerId#</cfif>&stopid=#request.qStop.CustomerStopID#&#session.URLToken#">#request.qStop.ContactPerson#</a></td>
            <td class="normal-td" valign="middle" onclick="document.location.href='index.cfm?event=addstop<cfif isdefined("url.customerId") and len(url.customerId) gt 1>&customerid=#url.customerId#</cfif>&stopid=#request.qStop.CustomerStopID#&#session.URLToken#'" align="left"><a title="#request.qStop.CustomerStopName# #request.qStop.Location# #request.qStop.ContactPerson# #request.qStop.Phone# #request.qStop.emailID#" href="index.cfm?event=addstop<cfif isdefined("url.customerId") and len(url.customerId) gt 1>&customerid=#url.customerId#</cfif>&stopid=#request.qStop.CustomerStopID#&#session.URLToken#">#request.qStop.Phone#</a></td>
            <td class="normal-td" valign="middle" onclick="document.location.href='index.cfm?event=addstop<cfif isdefined("url.customerId") and len(url.customerId) gt 1>&customerid=#url.customerId#</cfif>&stopid=#request.qStop.CustomerStopID#&#session.URLToken#'" align="left"><a title="#request.qStop.CustomerStopName# #request.qStop.Location# #request.qStop.ContactPerson# #request.qStop.Phone# #request.qStop.emailID#" href="mailto:#request.qStop.emailID#">#request.qStop.emailID#</a></td>
            <td class="normal-td2" valign="middle" onclick="document.location.href='index.cfm?event=addstop<cfif isdefined("url.customerId") and len(url.customerId) gt 1>&customerid=#url.customerId#</cfif>&stopid=#request.qStop.CustomerStopID#&#session.URLToken#'"  align="left"><a title="#request.qStop.CustomerStopName# #request.qStop.Location# #request.qStop.ContactPerson# #request.qStop.Phone# #request.qStop.emailID#" href="index.cfm?event=addstop<cfif isdefined("url.customerId") and len(url.customerId) gt 1>&customerid=#url.customerId#</cfif>&stopid=#request.qStop.CustomerStopID#&#session.URLToken#"><cfif request.qCustomer.recordcount>#request.qCustomer.customerName#</cfif> </a></td>
            <td class="normal-td3">&nbsp;</td>
         </tr>
    	 </cfloop>
    	 </tbody>
    	 <tfoot>
    	 <tr>
    		<td width="5" align="left" valign="top"><img src="images/left-bot.gif" alt="" width="5" height="23" /></td>
    		<td colspan="7" align="left" valign="middle" class="footer-bg">
    			<div class="up-down">
    				<div class="arrow-top"><a href="##"><img src="images/arrow-top.gif" alt="" /></a></div>
    				<div class="arrow-bot"><a href="##"><img src="images/arrow-bot.gif" alt="" /></a></div>
    			</div>
    			<div class="gen-left"><a href="##">View More</a></div>
    			<div class="gen-right"><img src="images/loader.gif" alt="" /></div>
    			<div class="clear"></div>
    		</td>
    		<td width="5" align="right" valign="top"><img src="images/right-bot.gif" alt="" width="5" height="23" /></td>
    	 </tr>	
    	 </tfoot>	  
    </table>
    </cfoutput>
    