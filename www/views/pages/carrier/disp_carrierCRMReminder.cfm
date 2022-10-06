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

<cfset frmAction = "index.cfm?event=carrierCRMCalls&#session.URLToken#">



<cfform id="dispCRMCallsForm" name="dispCRMCallsForm" action="#frmAction#" method="post" preserveData="yes">
  <cfinput id="pageNo" name="pageNo" value="1" type="hidden">
    
    <cfinput id="sortOrder" name="sortOrder" value="ASC" type="hidden">
    <cfinput id="sortBy" name="sortBy" value="cn.CreatedDateTime" type="hidden">
    
  <fieldset>
    <cfinput name="searchText" type="text" />
    <input name="" onclick="javascript: document.getElementById('pageNo').value=1;" type="submit" class="s-bttn" value="Search" style="width:56px;" />
    <div class="clear"></div>
  </fieldset>
</cfform>     
</div>
</div>
<cfif structKeyExists(url, "iscarrier") and len(trim(url.iscarrier))>
  <cfset iscarrier = url.iscarrier>
<cfelse>
  <cfset iscarrier = "">
</cfif>

<cfif isdefined("form.searchText") >
	<cfinvoke component="#variables.objCarrierGateway#" method="getarrierCRMReminder" searchText="#form.searchText#" pageNo="#form.pageNo#" sortorder="#form.sortOrder#" sortby="#form.sortBy#" iscarrier="#iscarrier#"  returnvariable="qCRMCalls" />
<cfelse>
	<cfinvoke component="#variables.objCarrierGateway#" method="getarrierCRMReminder" iscarrier="#iscarrier#"  returnvariable="qCRMCalls" />
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

      <th width="300" align="center" valign="middle" class="head-bg" onclick="sortTableBy('C.CarrierName','dispCRMCallsForm')">Name</th>

      <th width="300" align="center" valign="middle" class="head-bg" onclick="sortTableBy('C.MCNumber','dispCRMCallsForm')">MCNumber</th>

      <th width="120" align="center" valign="middle" class="head-bg" onclick="sortTableBy('C.DOTNumber','dispCRMCallsForm')">DotNumber</th>
      <th width="120" align="center" valign="middle" class="head-bg" onclick="sortTableBy('C.City','dispCRMCallsForm')">City</th>
       <th width="120" align="center" valign="middle" class="head-bg" onclick="sortTableBy('C.stateCode','dispCRMCallsForm')">State</th>

        <th width="120" align="center" valign="middle" class="head-bg" onclick="sortTableBy('C.Phone','dispCRMCallsForm')">Phone</th>
         <th width="120" align="center" valign="middle" class="head-bg" onclick="sortTableBy('C.EmailID','dispCRMCallsForm')">Email</th>
      <th width="120" align="center" valign="middle" class="head-bg" onclick="sortTableBy('C.Status','dispCRMCallsForm')">Status</th>
      <th width="120" align="center" valign="middle" class="head-bg2" onclick="sortTableBy('E.Name','dispCRMCallsForm')">Assinged To</th>
      <th width="5" align="right" valign="top"><img src="images/top-right.gif" alt="" width="5" height="23" /></th>
      </tr>
      </thead>
      <tbody>
       
        <cfloop query="qCRMCalls">
        <tr <cfif qCRMCalls.currentRow mod 2 eq 0>bgcolor="##FFFFFF"<cfelse>bgcolor="##f7f7f7"</cfif>>
          <td height="20" class="sky-bg">&nbsp;</td>
          <td class="sky-bg2" valign="middle" align="center">#rowNum + qCRMCalls.currentRow#</td>
          <td  align="left" valign="middle" nowrap="nowrap" class="normal-td" onclick="document.location.href='index.cfm?event=CarrierCRMNotes&frmEvent=#url.event#&&carrierid=#qCRMCalls.carrierid#&#session.URLToken#<cfif structKeyExists(url, "iscarrier") and len(trim(url.iscarrier))>&IsCarrier=#url.IsCarrier#</cfif>'"><a href="index.cfm?event=CarrierCRMNotes&frmEvent=#url.event#&&carrierid=#qCRMCalls.carrierid#&#session.URLToken#<cfif structKeyExists(url, "iscarrier") and len(trim(url.iscarrier))>&IsCarrier=#url.IsCarrier#</cfif>">#qCRMCalls.CarrierName#</a></td>
          <td  align="left" valign="middle" nowrap="nowrap" class="normal-td" onclick="document.location.href='index.cfm?event=CarrierCRMNotes&frmEvent=#url.event#&&carrierid=#qCRMCalls.carrierid#&#session.URLToken#<cfif structKeyExists(url, "iscarrier") and len(trim(url.iscarrier))>&IsCarrier=#url.IsCarrier#</cfif>'"><a href="index.cfm?event=CarrierCRMNotes&frmEvent=#url.event#&&carrierid=#qCRMCalls.carrierid#&#session.URLToken#<cfif structKeyExists(url, "iscarrier") and len(trim(url.iscarrier))>&IsCarrier=#url.IsCarrier#</cfif>">#qCRMCalls.MCNumber#</a></td>
          <td  align="left" valign="middle" nowrap="nowrap" class="normal-td" onclick="document.location.href='index.cfm?event=CarrierCRMNotes&frmEvent=#url.event#&&carrierid=#qCRMCalls.carrierid#&#session.URLToken#<cfif structKeyExists(url, "iscarrier") and len(trim(url.iscarrier))>&IsCarrier=#url.IsCarrier#</cfif>'"><a href="index.cfm?event=CarrierCRMNotes&frmEvent=#url.event#&&carrierid=#qCRMCalls.carrierid#&#session.URLToken#<cfif structKeyExists(url, "iscarrier") and len(trim(url.iscarrier))>&IsCarrier=#url.IsCarrier#</cfif>">#qCRMCalls.DOTNumber#</a></td>
          <td  align="left" valign="middle" nowrap="nowrap" class="normal-td" onclick="document.location.href='index.cfm?event=CarrierCRMNotes&frmEvent=#url.event#&&carrierid=#qCRMCalls.carrierid#&#session.URLToken#<cfif structKeyExists(url, "iscarrier") and len(trim(url.iscarrier))>&IsCarrier=#url.IsCarrier#</cfif>'"><a href="index.cfm?event=CarrierCRMNotes&frmEvent=#url.event#&&carrierid=#qCRMCalls.carrierid#&#session.URLToken#<cfif structKeyExists(url, "iscarrier") and len(trim(url.iscarrier))>&IsCarrier=#url.IsCarrier#</cfif>">#qCRMCalls.City#</a></td>
          <td  align="left" valign="middle" nowrap="nowrap" class="normal-td" onclick="document.location.href='index.cfm?event=CarrierCRMNotes&frmEvent=#url.event#&&carrierid=#qCRMCalls.carrierid#&#session.URLToken#<cfif structKeyExists(url, "iscarrier") and len(trim(url.iscarrier))>&IsCarrier=#url.IsCarrier#</cfif>'"><a href="index.cfm?event=CarrierCRMNotes&frmEvent=#url.event#&&carrierid=#qCRMCalls.carrierid#&#session.URLToken#<cfif structKeyExists(url, "iscarrier") and len(trim(url.iscarrier))>&IsCarrier=#url.IsCarrier#</cfif>">#qCRMCalls.stateCode#</a></td>
          <td  align="left" valign="middle" nowrap="nowrap" class="normal-td" onclick="document.location.href='index.cfm?event=CarrierCRMNotes&frmEvent=#url.event#&&carrierid=#qCRMCalls.carrierid#&#session.URLToken#<cfif structKeyExists(url, "iscarrier") and len(trim(url.iscarrier))>&IsCarrier=#url.IsCarrier#</cfif>'"><a href="index.cfm?event=CarrierCRMNotes&frmEvent=#url.event#&&carrierid=#qCRMCalls.carrierid#&#session.URLToken#<cfif structKeyExists(url, "iscarrier") and len(trim(url.iscarrier))>&IsCarrier=#url.IsCarrier#</cfif>">#qCRMCalls.Phone#</a></td>
          <td  align="left" valign="middle" nowrap="nowrap" class="normal-td" onclick="document.location.href='index.cfm?event=CarrierCRMNotes&frmEvent=#url.event#&&carrierid=#qCRMCalls.carrierid#&#session.URLToken#<cfif structKeyExists(url, "iscarrier") and len(trim(url.iscarrier))>&IsCarrier=#url.IsCarrier#</cfif>'"><a href="index.cfm?event=CarrierCRMNotes&frmEvent=#url.event#&&carrierid=#qCRMCalls.carrierid#&#session.URLToken#<cfif structKeyExists(url, "iscarrier") and len(trim(url.iscarrier))>&IsCarrier=#url.IsCarrier#</cfif>">#qCRMCalls.EmailID#</a></td>
          <td  align="left" valign="middle" nowrap="nowrap" class="normal-td" onclick="document.location.href='index.cfm?event=CarrierCRMNotes&frmEvent=#url.event#&&carrierid=#qCRMCalls.carrierid#&#session.URLToken#<cfif structKeyExists(url, "iscarrier") and len(trim(url.iscarrier))>&IsCarrier=#url.IsCarrier#</cfif>'"><a href="index.cfm?event=CarrierCRMNotes&frmEvent=#url.event#&&carrierid=#qCRMCalls.carrierid#&#session.URLToken#<cfif structKeyExists(url, "iscarrier") and len(trim(url.iscarrier))>&IsCarrier=#url.IsCarrier#</cfif>"><cfif #qCRMCalls.Status# eq 1>Active<cfelse>Inactive</cfif></a></td>
          <td  align="left" valign="middle" nowrap="nowrap" class="normal-td2" onclick="document.location.href='index.cfm?event=CarrierCRMNotes&frmEvent=#url.event#&&carrierid=#qCRMCalls.carrierid#&#session.URLToken#<cfif structKeyExists(url, "iscarrier") and len(trim(url.iscarrier))>&IsCarrier=#url.IsCarrier#</cfif>'"><a href="index.cfm?event=CarrierCRMNotes&frmEvent=#url.event#&&carrierid=#qCRMCalls.carrierid#&#session.URLToken#<cfif structKeyExists(url, "iscarrier") and len(trim(url.iscarrier))>&IsCarrier=#url.IsCarrier#</cfif>">#qCRMCalls.AssingedTo#</a></td> 
          <td class="normal-td3">&nbsp;</td>
        </tr>
      </cfloop>

       </tbody>
       <tfoot>
       <tr>
        <td width="5" align="left" valign="top"><img src="images/left-bot.gif" alt="" width="5" height="23" /></td>
        <td colspan="10" align="left" valign="middle" class="footer-bg">
          <div class="up-down">
            <div class="arrow-top"><a href="javascript: tablePrevPage('dispCRMCallsForm');"><img src="images/arrow-top.gif" alt="" /></a></div>
            <div class="arrow-bot"><a href="javascript: tableNextPage('dispCRMCallsForm');"><img src="images/arrow-bot.gif" alt="" /></a></div>
          </div>
          <div class="gen-left"><a href="javascript: tablePrevPage('dispCRMCallsForm');">Prev </a>-<a href="javascript: tableNextPage('dispCRMCallsForm');"> Next</a></div>
          <div class="gen-right"><img src="images/loader.gif" alt="" /></div>
          <div class="clear"></div>
        </td>
        <td width="5" align="right" valign="top"><img src="images/right-bot.gif" alt="" width="5" height="23" /></td>
       </tr>  
       </tfoot>   
    </table>
    </cfoutput>