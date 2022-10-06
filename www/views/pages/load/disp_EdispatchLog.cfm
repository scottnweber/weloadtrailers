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
<script type="text/javascript">

  function explode(str, maxLength) {
    var buff = "";
    var numOfLines = Math.floor(str.length/maxLength);
    for(var i = 0; i<numOfLines+1; i++) {
        buff += str.substr(i*maxLength, maxLength); if(i !== numOfLines) { buff += "<br>"; }
    }
    return buff;
}

  $( document ).ready(function() {
    $(".EmailBody").each(function(){
      var str = $(this).html();
      $(this).html(explode(str, 80));
    })

  })
</script>
<h1>E-Dispatch Log</h1>
<div style="clear:left"></div>

<cfif isdefined("session.message") and len(session.message)>
<div id="message" class="msg-area" style="width:500px">#session.message#</div>
<cfset exists= structdelete(session, 'message', true)/> 
</cfif>

   
 
<div class="search-panel">
<div class="form-search">

<cfset frmAction = "index.cfm?event=EdispatchLog&#session.URLToken#">



<cfform id="dispLoadLogsForm" name="dispLoadLogsForm" action="#frmAction#" method="post" preserveData="yes">
  <cfinput id="pageNo" name="pageNo" value="1" type="hidden">
    
    <cfinput id="sortOrder" name="sortOrder" value="ASC" type="hidden">
    <cfinput id="sortBy" name="sortBy" value="CreatedDate" type="hidden">
    
  <fieldset>
    <cfinput name="searchText" type="text" />
    <input name="" onclick="javascript: document.getElementById('pageNo').value=1;" type="submit" class="s-bttn" value="Search" style="width:56px;" />
    <div class="clear"></div>
  </fieldset>
</cfform>     
</div>
</div>


<cfif isdefined("form.searchText") >
	<cfinvoke component="#variables.objLoadGateway#" method="getEDispatchLog" searchText="#form.searchText#" pageNo="#form.pageNo#" sortorder="#form.sortOrder#" sortby="#form.sortBy#" returnvariable="qLoadLogs" />
<cfelse>
	<cfinvoke component="#variables.objLoadGateway#" method="getEDispatchLog" returnvariable="qLoadLogs" />
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

      <th width="120" align="center" valign="middle" class="head-bg" onclick="sortTableBy('LoadNumber','dispLoadLogsForm')">Load ##</th>

      <th width="120" align="center" valign="middle" class="head-bg" onclick="sortTableBy('Type','dispLoadLogsForm')">Type</th>

      <th width="120" align="center" valign="middle" class="head-bg" onclick="sortTableBy('Type','dispLoadLogsForm')">Email Body</th>

      <th width="120" align="center" valign="middle" class="head-bg" onclick="sortTableBy('CarrierID','dispLoadLogsForm')">Carrier</th>
       <th width="300" align="center" valign="middle" class="head-bg" onclick="sortTableBy('CustomerID','dispLoadLogsForm')">Customer</th>

      <th width="300" align="center" valign="middle" class="head-bg2" onclick="sortTableBy('CreatedDate','dispLoadLogsForm')">Date/ Time</th>

      <th width="5" align="right" valign="top"><img src="images/top-right.gif" alt="" width="5" height="23" /></th>
      </tr>
      </thead>
      <tbody>
       
        <cfloop query="qLoadLogs">
        <tr style="cursor: default;" <cfif qLoadLogs.currentRow mod 2 eq 0>bgcolor="##FFFFFF"<cfelse>bgcolor="##f7f7f7"</cfif>>
          <td height="20" class="sky-bg">&nbsp;</td>
          <td class="sky-bg2" valign="middle" align="center">#rowNum + qLoadLogs.currentRow#</td>
          <td  align="left" valign="middle" nowrap="nowrap" class="normal-td">#qLoadLogs.LoadNumber#</td>
          <td  align="left" valign="middle" nowrap="nowrap" class="normal-td">#qLoadLogs.type#</td>
          <td  align="left" valign="middle" nowrap="nowrap" class="normal-td EmailBody">#qLoadLogs.body#</td>
          <td  align="left" valign="middle" nowrap="nowrap" class="normal-td">#qLoadLogs.CarrierName#</td>
          <td  align="left" valign="middle" nowrap="nowrap" class="normal-td">#qLoadLogs.CustomerName#</td>
          <td  align="left" valign="middle" nowrap="nowrap" class="normal-td2">#datetimeformat(qLoadLogs.CreatedDate,'mm/dd/yyyy hh:nn tt')# </td>
          <td class="normal-td3">&nbsp;</td>
        </tr>
      </cfloop>

       </tbody>
       <tfoot>
       <tr>
        <td width="5" align="left" valign="top"><img src="images/left-bot.gif" alt="" width="5" height="23" /></td>
        <td colspan="7" align="left" valign="middle" class="footer-bg">
          <div class="up-down">
            <div class="arrow-top"><a href="javascript: tablePrevPage('dispLoadLogsForm');"><img src="images/arrow-top.gif" alt="" /></a></div>
            <div class="arrow-bot"><a href="javascript: tableNextPage('dispLoadLogsForm');"><img src="images/arrow-bot.gif" alt="" /></a></div>
          </div>
          <div class="gen-left" style="font-size: 14px;">
              <cfif qLoadLogs.recordcount>
                  <button type="button" class="bttn_nav" onclick="tablePrevPage('dispLoadLogsForm');">PREV</button>
                Page 
                  <input type="text" onkeyup="if (/\D/g.test(this.value)) this.value = this.value.replace(/\D/g,'')" value="<cfif structKeyExists(form, "pageNo")>#form.pageNo#<cfelse>1</cfif>" id="jumpPageNo" style="text-align: center;width: 25px;" onchange="jumpToPage('dispLoadLogsForm')">
                      <input type="hidden" id="TotalPages" value="#qLoadLogs.TotalPages#">
                  of #qLoadLogs.TotalPages#
                  <button type="button" class="bttn_nav" onclick="tableNextPage('dispLoadLogsForm');">NEXT</button>
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