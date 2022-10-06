<cfparam name="message" default="">
<cfparam name="url.sortorder" default="desc">
<cfparam name="sortby"  default="">
<cfsilent>
    <cfif isdefined("form.searchText") >
        <cfinvoke component="#variables.objAlertGateway#" method="getAlertHistory" searchText="#form.searchText#" pageNo="#form.pageNo#" sortorder="#form.sortOrder#" sortby="#form.sortBy#"  returnvariable="request.qGetAlert" />
    <cfelse>
        <cfinvoke component="#variables.objAlertGateway#" method="getAlertHistory"  searchText="" pageNo="1" returnvariable="request.qGetAlert" />
    </cfif>
</cfsilent>

<cfoutput>

	<div style="border:groove 1px;background-color: ##82bbef;">
		<h1 style="color:##FFFFFF;margin-left: 5px;font-weight:bold;">Alert History</h1>
	</div>
	<div style="clear:left"></div>
	<div class="search-panel">
		<div class="form-search">
			<cfform id="dispAlertForm" name="dispAlertForm" action="index.cfm?event=AlertHistory&#session.URLToken#" method="post" preserveData="yes">
				<cfinput id="pageNo" name="pageNo" value="1" type="hidden">
    			<cfinput id="sortOrder" name="sortOrder" value="DESC" type="hidden">
    			<cfinput id="sortBy" name="sortBy" value="A.CreatedDateTime" type="hidden">
				<fieldset>
					<cfinput name="searchText" type="text" />
					<cfinput name="" onclick="javascript: document.getElementById('pageNo').value=1;" type="submit" class="s-bttn" value="Search" style="width:56px;" />
					<div class="clear"></div>
				</fieldset>
			</cfform>			
		</div>
	</div>
	<table width="100%" border="0" class="data-table" cellspacing="0" cellpadding="0" style="color:##000000;">
      	<thead>
      		<tr>
      			<th align="center" valign="middle" class="head-bg" style="border-left: 1px solid ##5d8cc9;border-top-left-radius: 5px;">&nbsp;</th>
    			<th align="center" valign="middle" class="head-bg" onclick="sortTableBy('E.Name','dispAlertForm');">Claimed By</th>
    			<th align="center" valign="middle" class="head-bg" onclick="sortTableBy('A.Type','dispAlertForm');">Type</th>
    			<th align="center" valign="middle" class="head-bg" onclick="sortTableBy('A.Reference','dispAlertForm');">Reference</th>
    			<th align="center" valign="middle" class="head-bg" onclick="sortTableBy('A.Description','dispAlertForm');">Description</th>
    			<th align="center" valign="middle" class="head-bg" onclick="sortTableBy('A.CreatedDateTime','dispAlertForm');">Created On</th>
    			<th align="center" valign="middle" class="head-bg" onclick="sortTableBy('C.Name','dispAlertForm');">Created by</th>
    			<th width="30" align="center" valign="middle" class="head-bg2"  onclick="sortTableBy('A.AssignedTo','dispAlertForm');"  style="border-right: 1px solid ##5d8cc9;border-top-right-radius: 5px;">Open To</th>
      		</tr>
      	</thead>
      	<tbody>
	        <cfloop query="request.qGetAlert">	
	            <cfset pageSize = 30>
	            <cfif isdefined("form.pageNo")>
	            	<cfset rowNum=(request.qGetAlert.currentRow) + ((form.pageNo-1)*pageSize)>
	            <cfelse>
	            	<cfset rowNum=(request.qGetAlert.currentRow)>
	            </cfif>
	    		<tr <cfif request.qGetAlert.currentRow mod 2 eq 0>bgcolor="##FFFFFF"<cfelse>bgcolor="##f7f7f7"</cfif>>
	    			<td class="sky-bg2" valign="middle" align="center" style="border-left: 1px solid ##5d8cc9;">#rowNum#</td>
					<td  align="left" valign="middle" nowrap="nowrap" class="normal-td">#request.qGetAlert.ClaimedBy#</td>
					<td  align="left" valign="middle" nowrap="nowrap" class="normal-td">#request.qGetAlert.Type#</td>
					<td style="padding-right: 2px;" align="right" valign="middle" nowrap="nowrap" class="normal-td">#request.qGetAlert.Reference#</td>
					<td  align="left" valign="middle" nowrap="nowrap" class="normal-td">#request.qGetAlert.Description#</td>
					<td style="padding-right: 2px" align="right" valign="middle" nowrap="nowrap" class="normal-td">#dateTimeFormat(request.qGetAlert.CreatedDateTime,"mm/dd/yyyy h:mm:ss tt 'ET'")#</td>
					<td  align="left" valign="middle" nowrap="nowrap" class="normal-td">#request.qGetAlert.CreatedBy#</td>
					<td style="border-right: 1px solid ##5d8cc" align="left" valign="middle" nowrap="nowrap" class="normal-td">#request.qGetAlert.OpenTo#</td>
	    	 	</tr> 
	    	</cfloop>
	    </tbody>
    	<tfoot>
    	 	<tr>
    			<td colspan="8" align="left" valign="middle" class="footer-bg" style="border-left: 1px solid ##5d8cc9;border-right: 1px solid ##5d8cc9;border-bottom-left-radius: 5px;;border-bottom-right-radius: 5px;">
	    			<div class="up-down">
	    				<div class="arrow-top"><a href="javascript: tablePrevPage('dispAlertForm');"><img src="images/arrow-top.gif" alt="" /></a></div>
	    				<div class="arrow-bot"><a href="javascript: tableNextPage('dispAlertForm');"><img src="images/arrow-bot.gif" alt="" /></a></div>
	    			</div>
	    			<div class="gen-left" style="font-size: 14px;">
			            <cfif request.qGetAlert.recordcount>
			                <button type="button" class="bttn_nav" onclick="tablePrevPage('dispAlertForm');">PREV</button>
			                Page 
			                <input type="text" onkeyup="if (/\D/g.test(this.value)) this.value = this.value.replace(/\D/g,'')" value="<cfif structKeyExists(form, "pageNo")>#form.pageNo#<cfelse>1</cfif>" id="jumpPageNo" style="text-align: center;width: 25px;" onchange="jumpToPage('dispAlertForm')">
			                      <input type="hidden" id="TotalPages" value="#request.qGetAlert.TotalPages#">
			                of #request.qGetAlert.TotalPages#
			                <button type="button" class="bttn_nav" onclick="tableNextPage('dispAlertForm');">NEXT</button>
			            </cfif>
			         </div>
	    			<div class="gen-right"><img src="images/loader.gif" alt="" /></div>
	    			<div class="clear"></div>
    			</td>
    	 	</tr>	
    	</tfoot>	  
    </table>
</cfoutput>