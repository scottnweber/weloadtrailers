<cfparam name="message" default="">
<cfparam name="url.sortorder" default="desc">
<cfparam name="sortby"  default="">
<cfsilent>
    <cfif isdefined("form.searchText") >
        <cfinvoke component="#variables.objLoadGateway#" method="getSearchedFactorings" searchText="#form.searchText#" pageNo="#form.pageNo#" sortorder="#form.sortOrder#" sortby="#form.sortBy#"  returnvariable="qFactorings" />
    <cfelse>
        <cfinvoke component="#variables.objLoadGateway#" method="getSearchedFactorings" searchText="" pageNo="1" returnvariable="qFactorings" />
    </cfif>
</cfsilent>

<cfoutput>
  <style>
    .msg-area-success{
            border: 1px solid ##a4da46;
            padding: 5px 15px;
            font-weight: normal;
            width: 82%;
            float: left;
            margin-top: 5px;
            margin-bottom:  5px;
            background-color: ##b9e4b9;
            font-weight: bold;
            font-style: italic;
        }
  </style>
  <cfif structKeyExists(session, "FactoringMessage")>
    <div id="message" class="msg-area-success">#session.FactoringMessage#</div>
    <cfset structDelete(session, "FactoringMessage")>
  </cfif>
  <div style="clear:left"></div>
<h1>All Factorings</h1>
<div style="clear:left"></div>
<div class="search-panel">
<div class="form-search">

<cfset frmAction = "index.cfm?event=Factoring&#session.URLToken#">	

<form id="dispFactoringForm" name="dispFactoringForm" action="#frmAction#" method="post" preserveData="yes">
	<input id="pageNo" name="pageNo" value="1" type="hidden">
    
    <input id="sortOrder" name="sortOrder" value="ASC" type="hidden">
    <input id="sortBy" name="sortBy" value="Name" type="hidden">
    
	<fieldset>
		<input name="searchText" type="text" />
		<input name="" onclick="javascript: document.getElementById('pageNo').value=1;" type="submit" class="s-bttn" value="Search" style="width:56px;" />
		<div class="clear"></div>
	</fieldset>
</form>			
</div>
<div class="addbutton"><a href="index.cfm?event=addFactoring&#session.URLToken#">Add New</a></div></div>
<table width="100%" border="0" class="data-table" cellspacing="0" cellpadding="0" style="color:##000000;">
      <thead>
      <tr>

    	<th width="29" align="center" valign="middle" class="head-bg" style="border-left: 1px solid ##5d8cc9;border-top-left-radius: 5px;">&nbsp;</th>
    	<th width="25" align="center" valign="middle" class="head-bg" onclick="sortTableBy('Name','dispFactoringForm');">Name</th>
    	<th width="50" align="center" valign="middle" class="head-bg" onclick="sortTableBy('Address','dispFactoringForm');">Address</th>
      <th width="40" align="center" valign="middle" class="head-bg" onclick="sortTableBy('City','dispFactoringForm');">City</th>
      <th width="40" align="center" valign="middle" class="head-bg" onclick="sortTableBy('State','dispFactoringForm');">State</th>
      <th width="50" align="center" valign="middle" class="head-bg" onclick="sortTableBy('Zip','dispFactoringForm');">Zip</th>
    	<th width="50" align="center" valign="middle" class="head-bg" onclick="sortTableBy('Phone','dispFactoringForm');">Phone No.</th>
        <th width="40" align="center" valign="middle" class="head-bg" onclick="sortTableBy('Email','dispFactoringForm');">Email</th>
    	<th width="30" align="center" valign="middle" class="head-bg2" onclick="sortTableBy('Contact','dispFactoringForm');" style="border-right: 1px solid ##5d8cc9;border-top-right-radius: 5px;">Contact</th>
   
      </tr>
      </thead>
      <tbody>
         <cfloop query="qFactorings">	
    	   

            <cfset pageSize = 30>
            <cfif isdefined("form.pageNo")>
            	<cfset rowNum=(qFactorings.currentRow) + ((form.pageNo-1)*pageSize)>
            <cfelse>
            	<cfset rowNum=(qFactorings.currentRow)>
            </cfif>
    	<tr <cfif qFactorings.currentRow mod 2 eq 0>bgcolor="##FFFFFF"<cfelse>bgcolor="##f7f7f7"</cfif>>
		
			<td class="sky-bg2" valign="middle" onclick="document.location.href='index.cfm?event=addFactoring&Factoringid=#qFactorings.FactoringID#&#session.URLToken#'" align="center" style="border-left: 1px solid ##5d8cc9;">#rowNum#</td>
			<td  align="left" valign="middle" nowrap="nowrap" class="normal-td" onclick="document.location.href='index.cfm?event=addFactoring&Factoringid=#qFactorings.FactoringID#&#session.URLToken#'"><a title="#qFactorings.Name#" href="index.cfm?event=addFactoring&Factoringid=#qFactorings.FactoringID#&#session.URLToken#">#qFactorings.Name#</a></td>
			<td align="left" valign="middle" nowrap="nowrap" class="normal-td" onclick="document.location.href='index.cfm?event=addFactoring&Factoringid=#qFactorings.FactoringID#&#session.URLToken#'"><a title="#qFactorings.Name#" href="index.cfm?event=addFactoring&Factoringid=#qFactorings.FactoringID#&#session.URLToken#">#qFactorings.Address#</a></td>
      <td align="left" valign="middle" nowrap="nowrap" class="normal-td" onclick="document.location.href='index.cfm?event=addFactoring&Factoringid=#qFactorings.FactoringID#&#session.URLToken#'"><a title="#qFactorings.Name#" href="index.cfm?event=addFactoring&Factoringid=#qFactorings.FactoringID#&#session.URLToken#">#qFactorings.City#</a></td>
      <td align="left" valign="middle" nowrap="nowrap" class="normal-td" onclick="document.location.href='index.cfm?event=addFactoring&Factoringid=#qFactorings.FactoringID#&#session.URLToken#'"><a title="#qFactorings.Name#" href="index.cfm?event=addFactoring&Factoringid=#qFactorings.FactoringID#&#session.URLToken#">#qFactorings.state#</a></td>
      <td align="left" valign="middle" nowrap="nowrap" class="normal-td" onclick="document.location.href='index.cfm?event=addFactoring&Factoringid=#qFactorings.FactoringID#&#session.URLToken#'"><a title="#qFactorings.Name#" href="index.cfm?event=addFactoring&Factoringid=#qFactorings.FactoringID#&#session.URLToken#">#qFactorings.zip#</a></td>
			<td align="left" valign="middle" nowrap="nowrap" class="normal-td" onclick="document.location.href='index.cfm?event=addFactoring&Factoringid=#qFactorings.FactoringID#&#session.URLToken#'"><a title="#qFactorings.Name#" href="index.cfm?event=addFactoring&Factoringid=#qFactorings.FactoringID#&#session.URLToken#">#qFactorings.Phone#</a></td>
			
      <td align="left" valign="middle" nowrap="nowrap" class="normal-td" onclick="document.location.href='index.cfm?event=addFactoring&Factoringid=#qFactorings.FactoringID#&#session.URLToken#'">
    
            <a title="#qFactorings.Name#" href="index.cfm?event=addFactoring&Factoringid=#qFactorings.FactoringID#&#session.URLToken#">#qFactorings.Email#
            </a>
      </td>

			<td style="border-right: 1px solid ##5d8cc9;" align="center" valign="middle" nowrap="nowrap" class="normal-td2" onclick="document.location.href='index.cfm?event=addFactoring&Factoringid=#qFactorings.FactoringID#&#session.URLToken#'"><a href="index.cfm?event=addFactoring&Factoringid=#qFactorings.FactoringID#&#session.URLToken#">#qFactorings.Contact#</a></td>
		
    	 </tr>
    	 </cfloop>
    	 </tbody>
    	 <tfoot>
    	 <tr>

    		<td colspan="9" align="left" valign="middle" class="footer-bg" style="border-left: 1px solid ##5d8cc9;border-right: 1px solid ##5d8cc9;border-bottom-left-radius: 5px;;border-bottom-right-radius: 5px;">
    			<div class="up-down">
    				<div class="arrow-top"><a href="javascript: tablePrevPage('dispFactoringForm');"><img src="images/arrow-top.gif" alt="" /></a></div>
    				<div class="arrow-bot"><a href="javascript: tableNextPage('dispFactoringForm');"><img src="images/arrow-bot.gif" alt="" /></a></div>
    			</div>
    			<div class="gen-left"><a href="javascript: tablePrevPage('dispFactoringForm');">Prev </a>-<a href="javascript: tableNextPage('dispFactoringForm');"> Next</a></div>
    			<div class="gen-right"><img src="images/loader.gif" alt="" /></div>
    			<div class="clear"></div>
    		</td>

    	 </tr>	
    	 </tfoot>	  
    </table>
    </cfoutput>
    