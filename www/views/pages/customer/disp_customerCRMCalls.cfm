<cfparam name="message" default="">
<cfparam name="sortorder" default="desc">
<cfparam name="sortby"  default="">
<cfparam name="searchText"  default=" ">
<cfparam name="pageNo"  default="1">

<cfoutput>
  <style type="text/css">
  .content-area {
    width: 1100px;
  }
</style>
<h1>CRM Calls</h1>
<div style="clear:left"></div>

<cfif isdefined("session.message") and len(session.message)>
<div id="message" class="msg-area" style="width:500px">#session.message#</div>
<cfset exists= structdelete(session, 'message', true)/> 
</cfif>

<cfif isdefined("url.msg") and len(url.msg)>
<div id="msg" class="msg-area" style="width:500px">#url.msg#</div>
</cfif>
 
<div class="search-panel">
<div class="form-search">

<cfset frmAction = "index.cfm?event=customerCRMCalls&#session.URLToken#">



<cfform id="dispCRMCallsForm" name="dispCRMCallsForm" action="#frmAction#" method="post" preserveData="yes">
  <cfinput id="pageNo" name="pageNo" value="1" type="hidden">
    
    <cfinput id="sortOrder" name="sortOrder" value="ASC" type="hidden">
    <cfinput id="sortBy" name="sortBy" value="C.CustomerName" type="hidden">
    
  <fieldset>
    <cfinput name="searchText" type="text" />
    <input name="" onclick="javascript: document.getElementById('pageNo').value=1;" type="submit" class="s-bttn" value="Search" style="width:56px;" />
    <div class="clear"></div>
  </fieldset>
</cfform>     
</div>
</div>


<cfif isdefined("form.searchText") >
	<cfinvoke component="#variables.objCustomerGateway#" method="getCRMCalls" searchText="#form.searchText#" pageNo="#form.pageNo#" sortorder="#form.sortOrder#" sortby="#form.sortBy#" returnvariable="qCRMCalls" />
<cfelse>
	<cfinvoke component="#variables.objCustomerGateway#" method="getCRMCalls" returnvariable="qCRMCalls" />
</cfif>
	
    <cfset pageSize = 30>
    <cfif isdefined("form.pageNo")>
      <cfset rowNum = ((form.pageNo-1)*pageSize)>
    <cfelse>
      <cfset rowNum = 0>
    </cfif>
    
<table width="100%" border="0" class="data-table" cellspacing="0" cellpadding="0" style="color:##000000;">
      <thead>
      <tr>
      <th width="5" align="left" valign="top"><img src="images/top-left.gif" alt="" width="5" height="23" /></th>
      <th width="29" align="center" valign="middle" class="head-bg">&nbsp;</th>

      <th width="25" align="center" valign="middle" class="head-bg" onclick="sortTableBy('C.CustomerName','dispCRMCallsForm')">Name</th>

      <th width="50" align="center" valign="middle" class="head-bg" onclick="sortTableBy('C.Location','dispCRMCallsForm')">Address</th>
      <th width="40" align="center" valign="middle" class="head-bg" onclick="sortTableBy('C.City','dispCRMCallsForm')">City</th>
       <th width="40" align="center" valign="middle" class="head-bg" onclick="sortTableBy('C.Statecode','dispCRMCallsForm')">State</th>
       <th width="50" align="center" valign="middle" class="head-bg" onclick="sortTableBy('C.Zipcode','dispCRMCallsForm')">Zip</th>
       <th width="50" align="center" valign="middle" class="head-bg" onclick="sortTableBy('C.PhoneNo','dispCRMCallsForm')">Phone No.</th>
       <th width="40" align="center" valign="middle" class="head-bg">Office</th>
       <th width="40" align="center" valign="middle" class="head-bg"  onclick="sortTableBy('CRMNextCallDate','dispCRMCallsForm');">Next Call</th>
       <cfif listFindNoCase("1,2", request.qGetSystemSetupOptions.freightbroker)>
          <th width="40" align="center" valign="middle" class="head-bg" onclick="sortTableBy('SalesAgents.name','dispCRMCallsForm');">Sales Rep</th>
        </cfif>
        <th width="40" align="center" valign="middle" class="head-bg" onclick="sortTableBy('Dispatchers.name','dispCRMCallsForm');">Dispatcher</th>
      <th width="30" align="center" valign="middle" class="head-bg2" onclick="sortTableBy('C.CustomerStatusID','dispCRMCallsForm')">Status</th>

      <th width="5" align="right" valign="top"><img src="images/top-right.gif" alt="" width="5" height="23" /></th>
      </tr>
      </thead>
      <tbody>
       
        <cfloop query="qCRMCalls">
        <tr <cfif qCRMCalls.currentRow mod 2 eq 0>bgcolor="##FFFFFF"<cfelse>bgcolor="##f7f7f7"</cfif>>
          <td height="20" class="sky-bg">&nbsp;</td>
          <td class="sky-bg2" valign="middle" align="center">#rowNum + qCRMCalls.currentRow#</td>
          <td  align="left" valign="middle" nowrap="nowrap" class="normal-td" onclick="document.location.href='index.cfm?event=CRMNotes&frmEvent=#url.event#&customerid=#qCRMCalls.CustomerID#&#session.URLToken#'"><a href="index.cfm?event=CRMNotes&frmEvent=#url.event#&customerid=#qCRMCalls.CustomerID#&#session.URLToken#">#qCRMCalls.CustomerName#</a></td>
          <td  align="left" valign="middle" nowrap="nowrap" class="normal-td" onclick="document.location.href='index.cfm?event=CRMNotes&frmEvent=#url.event#&customerid=#qCRMCalls.CustomerID#&#session.URLToken#'"><a href="index.cfm?event=CRMNotes&frmEvent=#url.event#&customerid=#qCRMCalls.CustomerID#&#session.URLToken#">#qCRMCalls.Location#</a></td>
          <td  align="left" valign="middle" nowrap="nowrap" class="normal-td" onclick="document.location.href='index.cfm?event=CRMNotes&frmEvent=#url.event#&customerid=#qCRMCalls.CustomerID#&#session.URLToken#'"><a href="index.cfm?event=CRMNotes&frmEvent=#url.event#&customerid=#qCRMCalls.CustomerID#&#session.URLToken#">#qCRMCalls.City#</a></td>
          <td  align="left" valign="middle" nowrap="nowrap" class="normal-td" onclick="document.location.href='index.cfm?event=CRMNotes&frmEvent=#url.event#&customerid=#qCRMCalls.CustomerID#&#session.URLToken#'"><a href="index.cfm?event=CRMNotes&frmEvent=#url.event#&customerid=#qCRMCalls.CustomerID#&#session.URLToken#">#qCRMCalls.Statecode#</a></td>

          <td  align="left" valign="middle" nowrap="nowrap" class="normal-td" onclick="document.location.href='index.cfm?event=CRMNotes&frmEvent=#url.event#&customerid=#qCRMCalls.CustomerID#&#session.URLToken#'"><a href="index.cfm?event=CRMNotes&frmEvent=#url.event#&customerid=#qCRMCalls.CustomerID#&#session.URLToken#">#qCRMCalls.Zipcode#</a></td>

          <td  align="left" valign="middle" nowrap="nowrap" class="normal-td" onclick="document.location.href='index.cfm?event=CRMNotes&frmEvent=#url.event#&customerid=#qCRMCalls.CustomerID#&#session.URLToken#'"><a href="index.cfm?event=CRMNotes&frmEvent=#url.event#&customerid=#qCRMCalls.CustomerID#&#session.URLToken#">#qCRMCalls.PhoneNo#</a></td>
           <td  align="left" valign="middle" nowrap="nowrap" class="normal-td" onclick="document.location.href='index.cfm?event=CRMNotes&frmEvent=#url.event#&customerid=#qCRMCalls.CustomerID#&#session.URLToken#'"><a href="index.cfm?event=CRMNotes&frmEvent=#url.event#&customerid=#qCRMCalls.CustomerID#&#session.URLToken#">
            #replace(qCRMCalls.OfficeLocations, ";", '<br>','all')#</a>
        </td>

        <td  align="left" valign="middle" nowrap="nowrap" class="normal-td" onclick="document.location.href='index.cfm?event=CRMNotes&frmEvent=#url.event#&customerid=#qCRMCalls.CustomerID#&#session.URLToken#'"><a href="index.cfm?event=CRMNotes&frmEvent=#url.event#&customerid=#qCRMCalls.CustomerID#&#session.URLToken#">#dateformat(qCRMCalls.CRMNextCallDate,'mm/dd/yyyy')#</a></td>

        <cfif listFindNoCase("1,2", request.qGetSystemSetupOptions.freightbroker)>
          <td  align="left" valign="middle" nowrap="nowrap" class="normal-td" onclick="document.location.href='index.cfm?event=CRMNotes&frmEvent=#url.event#&customerid=#qCRMCalls.CustomerID#&#session.URLToken#'"><a href="index.cfm?event=CRMNotes&frmEvent=#url.event#&customerid=#qCRMCalls.CustomerID#&#session.URLToken#">#qCRMCalls.SalesAgent#</a></td>
        </cfif>
        <td  align="left" valign="middle" nowrap="nowrap" class="normal-td" onclick="document.location.href='index.cfm?event=CRMNotes&frmEvent=#url.event#&customerid=#qCRMCalls.CustomerID#&#session.URLToken#'"><a href="index.cfm?event=CRMNotes&frmEvent=#url.event#&customerid=#qCRMCalls.CustomerID#&#session.URLToken#">#qCRMCalls.Dispatcher#</a></td>


          <td  align="left" valign="middle" nowrap="nowrap" class="normal-td2"  onclick="document.location.href='index.cfm?event=CRMNotes&frmEvent=#url.event#&customerid=#qCRMCalls.CustomerID#&#session.URLToken#'"><a href="index.cfm?event=CRMNotes&frmEvent=#url.event#&customerid=#qCRMCalls.CustomerID#&#session.URLToken#"><cfif #qCRMCalls.CustomerStatusId# eq 1>Active<cfelse>Inactive</cfif></a></td>
          <td class="normal-td3">&nbsp;</td>
        </tr>
      </cfloop>

       </tbody>
       <tfoot>
       <tr>
        <td width="5" align="left" valign="top"><img src="images/left-bot.gif" alt="" width="5" height="23" /></td>
        <td colspan="<cfif listFindNoCase("1,2", request.qGetSystemSetupOptions.freightbroker)>12<cfelse>11</cfif>" align="left" valign="middle" class="footer-bg">
          <div class="up-down">
            <div class="arrow-top"><a href="javascript: tablePrevPage('dispCRMCallsForm');"><img src="images/arrow-top.gif" alt="" /></a></div>
            <div class="arrow-bot"><a href="javascript: tableNextPage('dispCRMCallsForm');"><img src="images/arrow-bot.gif" alt="" /></a></div>
          </div>
          <div class="gen-left" style="font-size: 14px;">
              <cfif qCRMCalls.recordcount>
                <button type="button" class="bttn_nav" onclick="tablePrevPage('dispCRMCallsForm');">PREV</button>
                  Page
                  <input type="text" onkeyup="if (/\D/g.test(this.value)) this.value = this.value.replace(/\D/g,'')" value="<cfif structKeyExists(form, "pageNo")>#form.pageNo#<cfelse>1</cfif>" id="jumpPageNo" style="text-align: center;width: 25px;" onchange="jumpToPage('dispCRMCallsForm')">
                      <input type="hidden" id="TotalPages" value="#qCRMCalls.TotalPages#">
                  of #qCRMCalls.TotalPages#
                  <button type="button" class="bttn_nav" onclick="tableNextPage('dispCRMCallsForm');">NEXT</button>
              </cfif>
          </div>
          <div class="gen-right"><img src="images/loader.gif" alt="" /></div>
          <div class="clear"></div>
        </td>
        <td width="5" align="right" valign="top"><img src="images/right-bot.gif" alt="" width="5" height="23" /></td>
       </tr>  
       </tfoot>   
    </table>
    </cfoutput>