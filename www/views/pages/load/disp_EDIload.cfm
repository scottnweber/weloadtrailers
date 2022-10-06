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

  ##loader img{
      margin-left: 628px;
    width: 79px;
    height: 82px;
    margin-top: 215px;
    z-index: -1;
}
.overlay{
  display: none; 
  position: fixed; 
  z-index: 1; 
  left: 0;
  top: 0;
  width: 100%;
  height: 100%; 
  overflow: auto; 

  background-color: rgba(0,0,0,0.4); 
}
.headwidth{
  width: auto;
}
</style>

<div style="clear:left"></div>

<cfif isdefined("session.edimessage") AND (structKeyExists(session.edimessage, 'ediLoadsImported') AND session.edimessage['ediLoadsImported'] OR structkeyexists(session.edimessage,'ediPartnerMissing'))>
  <div id="message" class="msg-area" style="text-align:center;">
    <cfif structKeyExists(session.edimessage, 'ediLoadsImported') AND session.edimessage['ediLoadsImported']>
      #session.edimessage['ediLoadsImported']# Load(s) Imported <br/>
    </cfif>
    <cfif structkeyexists(session.edimessage,'ediPartnerMissing')>
    No matching customers found for EDI Partner #ListRemoveDuplicates(session.edimessage['ediPartnerMissing'],",")#
  </cfif>
 </div>
 <cfset exists= structdelete(session, 'edimessage', true)/> 
</cfif>
 


<cfif isdefined("form.searchText") >
	<cfinvoke component="#variables.objLoadGatewaynew#" method="getPendingEDILoads" searchText="#form.searchText#" pageNo="#form.pageNo#" sortorder="#form.sortOrder#" sortby="#form.sortBy#" returnvariable="qLoadLogs" />
  <cfinvoke component="#variables.objLoadGatewaynew#" method="getPendingEDI820Loads" returnvariable="qEDI820Loads" />  
<cfelseif isdefined("form.search820Text") >
  <cfinvoke component="#variables.objLoadGatewaynew#" method="getPendingEDI820Loads" searchText="#form.search820Text#" pageNo="#form.pageNo#" sortorder="#form.sortOrder#" sortby="#form.sortBy#" returnvariable="qEDI820Loads" />
  <cfinvoke component="#variables.objLoadGatewaynew#" method="getPendingEDILoads" returnvariable="qLoadLogs" />
<cfelse>
	<cfinvoke component="#variables.objLoadGatewaynew#" method="getPendingEDILoads" returnvariable="qLoadLogs" />
  <cfinvoke component="#variables.objLoadGatewaynew#" method="getPendingEDI820Loads" returnvariable="qEDI820Loads" /> 
</cfif>
	 
    <cfset pageSize = 30>
    <cfif isdefined("form.pageNo")>
      <cfset rowNum = ((form.pageNo-1)*pageSize)>
    <cfelse>
      <cfset rowNum = 0>
    </cfif>
<table width="100%">
  <tr><td><h1>Pending EDI 204 Loads</h1></td></tr>
  <tr><td><div class="search-panel">
<div class="form-search">

<cfset frmAction = "index.cfm?event=EDILoads&#session.URLToken#">

 <div class="overlay">
   <div id="loader" style="display:none;"><img src="images/wait.gif" alt="" width="5" height="23" /></div>
 </div>

<cfform id="dispLoadLogsForm" name="dispLoadLogsForm" action="#frmAction#" method="post" preserveData="yes">
  <cfinput id="pageNo" name="pageNo" value="1" type="hidden">
    
    <cfinput id="sortOrder" name="sortOrder" value="ASC" type="hidden">
    <cfinput id="sortBy" name="sortBy" value="lm_EDISetup_SCAC" type="hidden">
    
  <fieldset>
    <cfinput name="searchText" type="text" />
    <input name="search204" id="search204" onclick="javascript: document.getElementById('pageNo').value=1;" type="submit" class="s-bttn" value="Search" style="width:56px;" />

    <input name="import" id="import204"  type="submit" class="s-bttn" value="Import 204" style="width:56px;" />

    <div class="clear"></div>
  </fieldset>
</cfform>     
</div>
</div>
</td></tr>
  <tr>
    <td>
  <table width="100%" border="0" class="data-table" cellspacing="0" cellpadding="0" style="color:##000000;">
      <thead>
      <tr>
      <th width="5" align="left" valign="top"><img src="images/top-left.gif" alt="" width="5" height="23" /></th>
      <th width="29" align="center" valign="middle" class="head-bg">&nbsp;</th>

    
      <th width="120" align="center" valign="middle" class="head-bg" onclick="sortTableBy('lm_EDISetup_SCAC','dispLoadLogsForm')">BOL Number</th>
      <th width="120" align="center" valign="middle" class="head-bg" onclick="sortTableBy('lm_EDISetup_SCAC','dispLoadLogsForm')">Customer</th>
      <th width="300" align="center" valign="middle" class="head-bg" onclick="sortTableBy('lm_Customers_CustomerCode','dispLoadLogsForm')">Notes</th>

      <th width="300" align="center" valign="middle" class="head-bg2 headwidth" onclick="sortTableBy('lm_Equipments_EquipmentCode','dispLoadLogsForm')">EquipmentCode</th>


      <th width="5" align="right" valign="top"><img src="images/top-right.gif" alt="" width="5" height="23" /></th>
      </tr>
      </thead>
      <tbody>
        <cfloop query="qLoadLogs">
        <tr <cfif qLoadLogs.currentRow mod 2 eq 0>bgcolor="##FFFFFF"<cfelse>bgcolor="##f7f7f7"</cfif>>
          <td height="20" class="sky-bg">&nbsp;</td>
          <td class="sky-bg2" valign="middle" align="center">#rowNum + qLoadLogs.currentRow#</td>
          <td  align="left" valign="middle" nowrap="nowrap" class="normal-td">#qLoadLogs.lm_Loads_BOL#</td>
          <td  align="left" valign="middle" nowrap="nowrap" class="normal-td">#qLoadLogs.custName#</td>
          <td  align="left" valign="middle" nowrap="nowrap" class="normal-td">#qLoadLogs.lm_Loads_NewNotes#</td>
          <td  align="left" valign="middle" nowrap="nowrap" class="normal-td2">#qLoadLogs.lm_Equipments_EquipmentCode#</td>
          <td class="normal-td3">&nbsp;</td>
        </tr>
      </cfloop>

       </tbody>        
       <tfoot>
       <tr>
        <td width="5" align="left" valign="top"><img src="images/left-bot.gif" alt="" width="5" height="23" /></td>
        <td colspan="5" align="left" valign="middle" class="footer-bg">
          <div class="up-down">
            <div class="arrow-top"><a href="javascript: tablePrevPage('dispLoadLogsForm');"><img src="images/arrow-top.gif" alt="" /></a></div>
            <div class="arrow-bot"><a href="javascript: tableNextPage('dispLoadLogsForm');"><img src="images/arrow-bot.gif" alt="" /></a></div>
          </div>
          <div class="gen-left"><a href="javascript: tablePrevPage('dispLoadLogsForm');">Prev </a>-<a href="javascript: tableNextPage('dispLoadLogsForm');"> Next</a></div>
          <div class="gen-right"><img src="images/loader.gif" alt="" /></div>
          <div class="clear"></div>
        </td>
        <td width="5" align="right" valign="top"><img src="images/right-bot.gif" alt="" width="5" height="23" /></td>
       </tr>  
       </tfoot>   
    </table>
    
   
    </td>
  </tr>
  <tr><td>&nbsp; </td></tr>
  <tr><td><h1>Pending EDI 820 Loads</h1></td></tr>
  <tr><td><div class="search-panel">
<div class="form-search">

<cfset frm820Action = "index.cfm?event=EDI820Loads&#session.URLToken#">



<cfform id="dispLoadLogsForm" name="dispLoadLogsForm" action="#frm820Action#" method="post" preserveData="yes">
  <cfinput id="pageNo" name="pageNo" value="1" type="hidden">
    
    <cfinput id="sortOrder" name="sortOrder" value="ASC" type="hidden">
    <cfinput id="sortBy" name="sortBy" value="lm_EDISetup_SCAC" type="hidden">
    
  <fieldset>
    <cfinput name="search820Text" type="text" />
    <input name="search820" id="search820" onclick="javascript: document.getElementById('pageNo').value=1;" type="submit" class="s-bttn" value="Search" style="width:56px;" />

    <input name="820import" id="import820" onclick="" type="submit" class="s-bttn" value="Import 820" style="width:56px;" />

    <div class="clear"></div>
  </fieldset>
</cfform>     
</div>
</div>
</td></tr>
  <tr>
    <td>
    <table width="100%" border="0" class="data-table" cellspacing="0" cellpadding="0" style="color:##000000;">

      <thead>

      <tr>
      <th width="5" align="left" valign="top"><img src="images/top-left.gif" alt="" width="5" height="23" /></th>
      <th width="29" align="center" valign="middle" class="head-bg">&nbsp;</th>

    
      <th width="120" align="center" valign="middle" class="head-bg" onclick="sortTableBy('lm_EDISetup_SCAC','dispLoadLogsForm')">LoadNumber</th>
      
      <th width="300" align="center" valign="middle" class="head-bg" onclick="sortTableBy('lm_Customers_CustomerCode','dispLoadLogsForm')">Amount</th>

      <th width="300" align="center" valign="middle" class="head-bg2 headwidth" onclick="sortTableBy('lm_Equipments_EquipmentCode','dispLoadLogsForm')">Payment Method Code</th>


      <th width="5" align="right" valign="top"><img src="images/top-right.gif" alt="" width="5" height="23" style="position: absolute; margin-left: -10px;" /></th>
      </tr>
      </thead>
      <tbody>
        <cfloop query="qEDI820Loads">
          <tr <cfif qEDI820Loads.currentRow mod 2 eq 0>bgcolor="##FFFFFF"<cfelse>bgcolor="##f7f7f7"</cfif>>
             <td height="20" class="sky-bg">&nbsp;</td>
             <td class="sky-bg2" valign="middle" align="center">#rowNum + qEDI820Loads.currentRow#</td>
             <td class="sky-bg2" valign="middle" align="center">#rowNum + qEDI820Loads.Reference_Identification#</td>
             <td class="sky-bg2" valign="middle" align="center">#rowNum + qEDI820Loads.Monetary_Amount#</td>
             <td class="sky-bg2" valign="middle" align="center">#qEDI820Loads.Payment_Method_Code#</td>
            
          </tr>
        </cfloop>

       </tbody>        
       <tfoot>
       <tr>
        <td width="5" align="left" valign="top"><img src="images/left-bot.gif" alt="" width="5" height="23" /></td>
        <td colspan="5" align="left" valign="middle" class="footer-bg" style="position: absolute;width: 1081px;">
          <div class="up-down">
            <div class="arrow-top"><a href="javascript: tablePrevPage('dispLoadLogsForm');"><img src="images/arrow-top.gif" alt="" /></a></div>
            <div class="arrow-bot"><a href="javascript: tableNextPage('dispLoadLogsForm');"><img src="images/arrow-bot.gif" alt="" /></a></div>
          </div>
          <div class="gen-left"><a href="javascript: tablePrevPage('dispLoadLogsForm');">Prev </a>-<a href="javascript: tableNextPage('dispLoadLogsForm');"> Next</a></div>
          <div class="gen-right"><img src="images/loader.gif" alt="" /></div>
          <div class="clear"></div>
        </td>
        <td width="5" align="right" valign="top"><img src="images/right-bot.gif" alt="" width="5" height="23" style="position: initial; margin-left: 869%;"/></td>
       </tr>  
       </tfoot>   
    </table>
  </td>
</tr>
</table>

    <script>
      $(document).ready(function(){
       $( '##import204' ).click(function() {
        myFunction(this);
      });
        $( '##import820' ).click(function() {
        myFunction(this);
      });
        $( '##search204' ).click(function() {
        myFunction(this);
      });
        $( '##search820' ).click(function() {
        myFunction(this);
      });

       function myFunction(div) {
         $("##loader").toggle();
         $(".overlay").toggle();
       }
     });
   </script>
    </cfoutput>