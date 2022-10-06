<cfparam name="message" default="">
<cfparam name="url.sortorder" default="desc">
<cfparam name="sortby"  default="">
<cfsilent>
    <cfif isdefined("form.searchText") >
        <cfinvoke component="#variables.objCustomerGateway#" method="getSearchedCRMNoteTypes" searchText="#form.searchText#" pageNo="#form.pageNo#" sortorder="#form.sortOrder#" sortby="#form.sortBy#"  returnvariable="qCRMNoteTypes" />
    <cfelse>
        <cfinvoke component="#variables.objCustomerGateway#" method="getSearchedCRMNoteTypes" searchText="" pageNo="1" returnvariable="qCRMNoteTypes" />
    </cfif>
</cfsilent>

<cfoutput>
  <script>
    $(document).ready(function(){
      <cfif structKeyExists(session, "CRMNoteTypeMessage")>
        alert('#session.CRMNoteTypeMessage#');
        <cfset structDelete(session, "CRMNoteTypeMessage")>
      </cfif>
    })
  </script>
<h1>CRM Call Note Types</h1>
<div style="clear:left"></div>
<div class="search-panel">
<div class="form-search">

<cfset frmAction = "index.cfm?event=crmNoteTypes&#session.URLToken#">	

<cfform id="dispCRMNoteTypesForm" name="dispCRMNoteTypesForm" action="#frmAction#" method="post" preserveData="yes">
	<cfinput id="pageNo" name="pageNo" value="1" type="hidden">
    
    <cfinput id="sortOrder" name="sortOrder" value="ASC" type="hidden">
    <cfinput id="sortBy" name="sortBy" value="NoteType" type="hidden">
    
	<fieldset>
		<cfinput name="searchText" type="text" />
		<cfinput name="" onclick="javascript: document.getElementById('pageNo').value=1;" type="submit" class="s-bttn" value="Search" style="width:56px;" />
		<div class="clear"></div>
	</fieldset>
</cfform>			
</div>
<div class="addbutton"><a href="index.cfm?event=addCRMNoteType&#session.URLToken#">Add New</a></div></div>
<table width="100%" border="0" class="data-table" cellspacing="0" cellpadding="0" style="color:##000000;">
      <thead>
      <tr>

    	<th width="5" align="center" valign="middle" class="head-bg" style="border-left: 1px solid ##5d8cc9;border-top-left-radius: 5px;">&nbsp;</th>
    	<th width="25" align="center" valign="middle" class="head-bg" onclick="sortTableBy('NoteType','dispCRMNoteTypesForm');">Note Type</th>
    	<th width="50" align="center" valign="middle" class="head-bg" onclick="sortTableBy('cast(Description as varchar(max))','dispCRMNoteTypesForm');">Description</th>
    	<th width="30" align="center" valign="middle" class="head-bg2"  onclick="sortTableBy('CRMType','dispCRMNoteTypesForm');"  style="border-right: 1px solid ##5d8cc9;border-top-right-radius: 5px;">CRM Type</th>
   
      </tr>
      </thead>
      <tbody>
         <cfloop query="qCRMNoteTypes">	
    	   

            <cfset pageSize = 30>
            <cfif isdefined("form.pageNo")>
            	<cfset rowNum=(qCRMNoteTypes.currentRow) + ((form.pageNo-1)*pageSize)>
            <cfelse>
            	<cfset rowNum=(qCRMNoteTypes.currentRow)>
            </cfif>
    	<tr <cfif qCRMNoteTypes.currentRow mod 2 eq 0>bgcolor="##FFFFFF"<cfelse>bgcolor="##f7f7f7"</cfif>>
		
			<td class="sky-bg2" valign="middle" onclick="document.location.href='index.cfm?event=addCRMNoteType&CRMNoteTypeID=#qCRMNoteTypes.CRMNoteTypeID#&#session.URLToken#'" align="center" style="border-left: 1px solid ##5d8cc9;">#rowNum#</td>
			<td  align="left" valign="middle" nowrap="nowrap" class="normal-td" onclick="document.location.href='index.cfm?event=addCRMNoteType&CRMNoteTypeID=#qCRMNoteTypes.CRMNoteTypeID#&#session.URLToken#'"><a title="#qCRMNoteTypes.NoteType#" href="index.cfm?event=addCRMNoteType&CRMNoteTypeID=#qCRMNoteTypes.CRMNoteTypeID#&#session.URLToken#">#qCRMNoteTypes.NoteType#</a></td>
			<td align="left" valign="middle" nowrap="nowrap" class="normal-td" onclick="document.location.href='index.cfm?event=addCRMNoteType&CRMNoteTypeID=#qCRMNoteTypes.CRMNoteTypeID#&#session.URLToken#'"><a title="#qCRMNoteTypes.NoteType#" href="index.cfm?event=addCRMNoteType&CRMNoteTypeID=#qCRMNoteTypes.CRMNoteTypeID#&#session.URLToken#">#qCRMNoteTypes.Description#</a></td>
      
			<td style="border-right: 1px solid ##5d8cc9;" align="center" valign="middle" nowrap="nowrap" class="normal-td2" onclick="document.location.href='index.cfm?event=addCRMNoteType&CRMNoteTypeID=#qCRMNoteTypes.CRMNoteTypeID#&#session.URLToken#'"><a href="index.cfm?event=addCRMNoteType&CRMNoteTypeID=#qCRMNoteTypes.CRMNoteTypeID#&#session.URLToken#">#qCRMNoteTypes.CRMType#</a></td>
		
    	 </tr>
    	 </cfloop>
    	 </tbody>
    	 <tfoot>
    	 <tr>

    		<td colspan="9" align="left" valign="middle" class="footer-bg" style="border-left: 1px solid ##5d8cc9;border-right: 1px solid ##5d8cc9;border-bottom-left-radius: 5px;;border-bottom-right-radius: 5px;">
    			<div class="up-down">
    				<div class="arrow-top"><a href="javascript: tablePrevPage('dispCRMNoteTypesForm');"><img src="images/arrow-top.gif" alt="" /></a></div>
    				<div class="arrow-bot"><a href="javascript: tableNextPage('dispCRMNoteTypesForm');"><img src="images/arrow-bot.gif" alt="" /></a></div>
    			</div>
    			<div class="gen-left"><a href="javascript: tablePrevPage('dispCRMNoteTypesForm');">Prev </a>-<a href="javascript: tableNextPage('dispCRMNoteTypesForm');"> Next</a></div>
    			<div class="gen-right"><img src="images/loader.gif" alt="" /></div>
    			<div class="clear"></div>
    		</td>

    	 </tr>	
    	 </tfoot>	  
    </table>
    </cfoutput>
    