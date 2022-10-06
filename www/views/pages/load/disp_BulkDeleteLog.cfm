<cfparam name="message" default="">
<cfparam name="sortorder" default="desc">
<cfparam name="sortby"  default="">
<cfparam name="searchText"  default=" ">
<cfparam name="pageNo"  default="1">

<cfoutput>
  <style type="text/css">
  ul##ui-id-1 {
      overflow: scroll;
      height: 250px;
  }

  .noscroll {
    overflow: hidden;
  }
  .content-area {
    width: 1100px;
  }
  .modal {
  display: none; /* Hidden by default */
  position: fixed; /* Stay in place */
  z-index: 1; /* Sit on top */
  left: 0;
  top: 0;
  width: 100%; /* Full width */
  height: 100%; /* Full height */
  overflow: auto; /* Enable scroll if needed */
  background-color: rgb(0,0,0); /* Fallback color */
  background-color: rgba(0,0,0,0.4); /* Black w/ opacity */
}
.modal-header {
  padding: 2px 16px;
  background-color: ##5cb85c;
  color: white;
}
/* Modal Content/Box */
.modal-content {
  background-color: ##defaf9;
  margin: 15% auto; /* 15% from the top and centered */
  padding: 20px;
  border: 1px solid ##888;
  width: 30%; /* Could be more or less, depending on screen size */
  height:120px;
}
/* The Close Button */
.close {
  color: ##fff;
  float: right;
  font-size: 28px;
  font-weight: bold;
  margin-right: 7px;
  margin-top: 10px;
}

.close:hover,
.close:focus {
  color: black;
  text-decoration: none;
  cursor: pointer;
} 
##ediheading{
  font-size: 15px;
  font-weight: bold;
  padding-top: 12px;
}
##inputcheck{
    margin-left: 12px;
    margin-top: 15px;
}

.labell{
    font-size: 13px;
    position: relative;
    margin-left: 4px;
    font-weight: bold;
}
.modalstyle{
     border-collapse: collapse;
     height: 80px;
}
.modalstyle td{
    /*border: 1px solid ##b0ccef;*/
    min-width: 118px;
    padding-left: 9px;
    padding-top: 4px;
    height: 19px;
}

.modalstyle td:nth-last-child(1) {
    padding-left: 9px;
    text-align: -webkit-center;
    padding-top: 8px;
}

.modalstyle td:first-child {
    /*border: 1px solid ##b0ccef;*/
    min-width: 118px;
    padding-left: 9px;
    padding-top: 25px;
    height: 19px;
}
.modalstyle td:nth-last-child(2) {
    padding-left: 0px;
    padding-top: 0px;
}
.modalstyle th{
     font-size: 13px;
     font-weight: bold;
     text-align: left;
     border: 1px solid ##96bcec;
     padding-left: 8px;
     border-top-color: white;
}
##headbakgrnd{
    background-color: ##82BBEF;
    position: initial;
    height: 38px;
    margin-top: -20px;
    width: 110%;
    margin-left: -20px;
}
.position{
     margin-left: -40px;2px;
}
##headbakgrnd2{
        background-color: ##82BBEF;
    /* position: initial; */
    height: 40px;
    width: 100%;
    /* margin-left: -24px; */
    /* margin-top: -23px; */
}
##tabltitle td{
    font-size: 11px;
    font-weight: bold;
    text-align: center;
    padding: 2px;
    border: black;
    border: 1px solid grey;

}
</style>


<h1>Bulk Delete Log</h1>
<div style="clear:left"></div>

<cfif isdefined("message") and len(message)>
<div id="message" class="msg-area">#message#</div>
</cfif>

   
 
<div class="search-panel">
<div class="form-search">
<cfset frmAction = "index.cfm?event=loadLogs&#session.URLToken#">
<cfform id="dispLoadLogsForm" name="dispLoadLogsForm" action="index.cfm?event=BulkDeleteLog&#session.URLToken#" method="post" preserveData="yes">
  <cfinput id="pageNo" name="pageNo" value="1" type="hidden">
    
    <cfinput id="sortOrder" name="sortOrder" value="ASC" type="hidden">
    <cfinput id="sortBy" name="sortBy" value="LoadNumber" type="hidden">
    
  <fieldset>
    <cfinput name="searchText" type="text" />
    <input name="" onclick="javascript: document.getElementById('pageNo').value=1;" type="submit" class="s-bttn" value="Search" style="width:56px;" />
    <div class="clear"></div>
  </fieldset>
</cfform>     
</div>
</div>

<cfif isdefined("form.searchText") >
	<cfinvoke component="#variables.objLoadGatewaynew#" method="getSearchedLoadLogs" searchText="#form.searchText#" pageNo="#form.pageNo#" sortorder="#form.sortOrder#" sortby="#form.sortBy#" bulkdelete="1" returnvariable="qLoadLogs" />
<cfelse>
	<cfinvoke component="#variables.objLoadGatewaynew#" bulkdelete="1" method="getSearchedLoadLogs" returnvariable="qLoadLogs" />
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

    
      <th width="220" align="center" valign="middle" class="head-bg" onclick="sortTableBy('LoadNumber','dispLoadLogsForm')">Load Number</th>
          <th width="105" align="center" valign="middle" class="head-bg" onclick="sortTableBy('FieldLabel','dispLoadLogsForm')">Customer</th>
          <th width="120" align="center" valign="middle" class="head-bg">Cust Amt.</th>
          <th width="120" align="center" valign="middle" class="head-bg">Order Date</th>
          <th width="120" align="center" valign="middle" class="head-bg" onclick="sortTableBy('UpdatedBy','dispLoadLogsForm')">Deleted By</th>
    	  <th width="120" align="center" valign="middle" class="head-bg" onclick="sortTableBy('UpdatedTimestamp','dispLoadLogsForm')">Deleted Date/Time</th>
        <th width="120" align="center" valign="middle" class="head-bg2" onclick="sortTableBy('L.UpdatedByIP','dispLoadLogsForm')">Deleted By IP</th>


      <th width="5" align="right" valign="top"><img src="images/top-right.gif" alt="" width="5" height="23" /></th>
      </tr>
      </thead>
      <tbody>
     
        <cfloop query="qLoadLogs">
          <cfset valString = deserializeJSON(qLoadLogs.OLDVALUE)>
        <tr style="cursor: default;" <cfif qLoadLogs.currentRow mod 2 eq 0>bgcolor="##FFFFFF"<cfelse>bgcolor="##f7f7f7"</cfif>>
          <td height="20" class="sky-bg">&nbsp;</td>
          <td class="sky-bg2" valign="middle" align="center">#rowNum + qLoadLogs.currentRow#</td>
          <td  align="left" valign="middle" nowrap="nowrap" class="normal-td">
            <cfif qLoadLogs.LOADNUMBER>#qLoadLogs.LOADNUMBER#
            <cfelse>
            None 
            <cfif event is 'loadLogs' and structKeyExists(url,'comdata')>
              <input name="btnAssignLoad#qLoadLogs.currentRow#" id="btnAssignLoad#qLoadLogs.currentRow#" data-code="#qLoadLogs.LoadLogId#" data-fuel="#qLoadLogs.FuelCardNo#" style="width:90px !important;height:22px;margin-top: 10px;margin-left: 20px;" type="button" class="black-btn tooltip assign-load" value="Assign Load">
            </cfif>
            </cfif>
          

        </td>
              <td  align="left" valign="middle" nowrap="nowrap" class="normal-td">#valString.CUSTNAME#</td>
              <td  align="left" valign="middle"  class="normal-td">#DollarFormat(valString.CUSTAMT)#</td>
              <td  align="left" valign="middle"  class="normal-td">#DateFormat(valString.ORDERDATE,'MM/DD/YYYY')#</td>
              <td  align="left" valign="middle" nowrap="nowrap" class="normal-td">
                <cfif qLoadLogs.FIELDLABEL NEQ 'LOAD UNLOCKED'>#qLoadLogs.UPDATEDBY#</cfif>
            </td>
    		  <td  align="left" valign="middle" nowrap="nowrap" class="normal-td"><cfif qLoadLogs.FIELDLABEL NEQ 'LOAD UNLOCKED'>#qLoadLogs.UpdatedTimestamp#</cfif></td>
          <td  align="left" valign="middle" nowrap="nowrap" class="normal-td2">#qLoadLogs.UpdatedByIp#</td>
          <td class="normal-td3">&nbsp;</td>
        </tr>
      </cfloop>
     
       </tbody>
       <tfoot>
       <tr>
        <td width="5" align="left" valign="top"><img src="images/left-bot.gif" alt="" width="5" height="23" /></td>
        <td colspan="<cfif event is 'loadLogs' and structKeyExists(url,'comdata')>8<cfelse>10</cfif>" align="left" valign="middle" class="footer-bg">
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

    