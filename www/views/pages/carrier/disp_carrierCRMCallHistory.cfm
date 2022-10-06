<cfparam name="message" default="">
<cfparam name="sortorder" default="">
<cfparam name="sortby"  default="">
<cfparam name="searchText"  default=" ">
<cfparam name="pageNo"  default="1">

<cfoutput>
    <style type="text/css">
        .content-area {
            width: 1100px;
        }
    </style>
    <h1>CRM Call History</h1>
    <div style="clear:left"></div>
    <div class="search-panel">
        <div class="form-search">
            <cfform id="dispCRMCallsForm" name="dispCRMCallsForm" action="index.cfm?event=carrierCRMCallHistory&#session.URLToken#" method="post" preserveData="yes">
                <cfinput id="pageNo" name="pageNo" value="1" type="hidden">
                <cfinput id="sortOrder" name="sortOrder" value="ASC" type="hidden">
                <cfinput id="sortBy" name="sortBy" value="" type="hidden">
                <fieldset>
                    <cfinput name="searchText" type="text" />
                    <input name="" onclick="javascript: document.getElementById('pageNo').value=1;" type="submit" class="s-bttn" value="Search" style="width:56px;" />
                    <div class="clear"></div>
                </fieldset>
            </cfform>     
        </div>
    </div>
    <cfif isdefined("form.searchText") >
    	<cfinvoke component="#variables.objcarrierGateway#" method="getCRMCallHistory" searchText="#form.searchText#" pageNo="#form.pageNo#" sortorder="#form.sortOrder#" sortby="#form.sortBy#" returnvariable="qCRMCallHis" />
    <cfelse>
    	<cfinvoke component="#variables.objcarrierGateway#" method="getCRMCallHistory" returnvariable="qCRMCallHis"/>
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
              <th align="center" valign="middle" class="head-bg" style="border-left: 1px solid ##5d8cc9;border-top-left-radius: 5px;">&nbsp;</th>
              <th align="center" valign="middle" class="head-bg" onclick="sortTableBy('CN.NoteUser','dispCRMCallsForm')">User Name</th>
              <th align="center" valign="middle" class="head-bg" onclick="sortTableBy('C.carrierName','dispCRMCallsForm')">Company</th>
              <th align="center" valign="middle" class="head-bg" onclick="sortTableBy('CC.ContactPerson','dispCRMCallsForm')">Contact</th>
              <th align="center" valign="middle" class="head-bg" onclick="sortTableBy('CN.CreatedDateTime','dispCRMCallsForm')">Date</th>
              <th align="center" valign="middle" class="head-bg" onclick="sortTableBy('C.CRMPhoneNo','dispCRMCallsForm')">Phone##</th>
              <th align="center" valign="middle" class="head-bg" onclick="sortTableBy('CNT.NoteType','dispCRMCallsForm')">Call type</th>
              <th align="center" valign="middle" class="head-bg" onclick="sortTableBy('CAST(CN.Note AS varchar(50))','dispCRMCallsForm')">Call Note</th>
              <th align="center" valign="middle" class="head-bg" style="border-right: 1px solid ##5d8cc9;border-top-right-radius: 5px;" onclick="sortTableBy('C.CRMNextCallDate','dispCRMCallsForm')">Next call date</th>
            </tr>
        </thead>
        
        <tbody>
          <cfloop query="qCRMCallHis">
            <cfif structKeyExists(url, 'isCarrier')>
              <cfset IsCarrier = url.isCarrier>
            <cfelse>
              <cfset IsCarrier = "">
            </cfif>
            <cfset href="index.cfm?event=carrierCRMCallDetail&CRMNoteID=#qCRMCallHis.CRMNoteID#&#session.URLToken#&IsCarrier=#IsCarrier#">
            <tr <cfif qCRMCallHis.currentRow mod 2 eq 0>bgcolor="##FFFFFF"<cfelse>bgcolor="##f7f7f7"</cfif>>
              <td class="sky-bg2" style="border-left: 1px solid ##5d8cc9;" valign="middle" align="center" onclick="document.location.href='#href#'">#rowNum + qCRMCallHis.currentRow#</td>
              <td align="left" valign="middle" nowrap="nowrap" class="normal-td" onclick="document.location.href='#href#'"><a href="#href#">#qCRMCallHis.UserName#</a></td>
              <td align="left" valign="middle" nowrap="nowrap" class="normal-td" onclick="document.location.href='#href#'"><a href="#href#">#qCRMCallHis.Company#</a></td>
              <td align="left" valign="middle" nowrap="nowrap" class="normal-td" onclick="document.location.href='#href#'"><a href="#href#">#qCRMCallHis.Contact#</a></td>
              <td align="right" valign="middle" nowrap="nowrap" class="normal-td" onclick="document.location.href='#href#'"><a href="#href#">#DateFormat(qCRMCallHis.Date,"mm/dd/yyyy")#</a>&nbsp;</td>
              <td align="right" valign="middle" nowrap="nowrap" class="normal-td" onclick="document.location.href='#href#'"><a href="#href#">#qCRMCallHis.Phone#</a>&nbsp;</td>
              <td align="left" valign="middle" nowrap="nowrap" class="normal-td" onclick="document.location.href='#href#'"><a href="#href#">#qCRMCallHis.CallType#</a></td>
              <td align="left" valign="middle" nowrap="nowrap" class="normal-td" onclick="document.location.href='#href#'"><a href="#href#">#qCRMCallHis.CallNotes#</a></td>
              <td style="border-right: 1px solid ##5d8cc" align="right" valign="middle" nowrap="nowrap" class="normal-td" onclick="document.location.href='#href#'"><a href="#href#">#DateFormat(qCRMCallHis.NextCallDate,"mm/dd/yyyy")#</a>&nbsp;</td>
              
            </tr>
          </cfloop> 
        </tbody>

      	<tfoot>
          <tr>
           <td colspan="9" align="left" valign="middle" class="footer-bg" style="border-left: 1px solid ##5d8cc9;border-right: 1px solid ##5d8cc9;border-bottom-left-radius: 5px;;border-bottom-right-radius: 5px;">
             <div class="up-down">
               <div class="arrow-top"><a href="javascript: tablePrevPage('dispCRMCallsForm');"><img src="images/arrow-top.gif" alt="" /></a></div>
               <div class="arrow-bot"><a href="javascript: tableNextPage('dispCRMCallsForm');"><img src="images/arrow-bot.gif" alt="" /></a></div>
             </div>
             <div class="gen-left" style="font-size: 14px;">
                   <cfif qCRMCallHis.recordcount>
                       <button type="button" class="bttn_nav" onclick="tablePrevPage('dispCRMCallsForm');">PREV</button>
                       Page 
                       <input type="text" onkeyup="if (/\D/g.test(this.value)) this.value = this.value.replace(/\D/g,'')" value="<cfif structKeyExists(form, "pageNo")>#form.pageNo#<cfelse>1</cfif>" id="jumpPageNo" style="text-align: center;width: 25px;" onchange="jumpToPage('dispCRMCallsForm')">
                             <input type="hidden" id="TotalPages" value="#qCRMCallHis.TotalPages#">
                       of #qCRMCallHis.TotalPages#
                       <button type="button" class="bttn_nav" onclick="tableNextPage('dispCRMCallsForm');">NEXT</button>
                   </cfif>
                </div>
             <div class="gen-right"><img src="images/loader.gif" alt="" /></div>
             <div class="clear"></div>
           </td>
          </tr>	
       </tfoot>
    </table>    
</cfoutput>