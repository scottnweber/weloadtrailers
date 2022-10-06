<cfinvoke component="#variables.objloadGateway#" method="getSystemSetupOptions" returnvariable="request.qGetSystemSetupOptions" />
<cfparam name="message" default="">
<cfparam name="url.sortorder" default="desc">
<cfparam name="sortby"  default="">
<cfsilent>
    <cfif isdefined("form.searchText") >
        <cfinvoke component="#variables.objCarrierGateway#" method="getOnboardingDocs" searchText="#form.searchText#" pageNo="#form.pageNo#" sortorder="#form.sortOrder#" sortby="#form.sortBy#"  returnvariable="request.qGetDoc" />
    <cfelse>
        <cfinvoke component="#variables.objCarrierGateway#" method="getOnboardingDocs"  searchText="" pageNo="1" returnvariable="request.qGetDoc" />
    </cfif>
</cfsilent>
<cfoutput>
	<style>
		.msg-area-success{
            border: 1px solid ##a4da46;
            padding: 5px 15px;
            font-weight: normal;
            width: 97%;
            float: left;
            margin-top: 5px;
            margin-bottom:  5px;
            background-color: ##b9e4b9;
            font-weight: bold;
            font-style: italic;
        }
        .msg-area-error{
            border: 1px solid ##da4646;
            padding: 5px 15px;
            font-weight: normal;
            width: 97%;
            float: left;
            margin-top: 5px;
            margin-bottom:  5px;
            background-color: ##e4b9c6;
            font-weight: bold;
            font-style: italic;
        }
	</style>
	<div class="clear"></div>
	<cfinclude template="OnboardingDocTab.cfm">
	<div class="white-con-area" style="height: 36px;background-color: ##82bbef;width:999px;text-align: center;">
		<h2 style="color:white;font-weight:bold;">Docs to be SIGNED</h2>
	</div>
	<div style="clear:left"></div>
	<div class="search-panel">
		<div class="form-search">
			<cfform id="dispDocForm" name="dispDocForm" action="index.cfm?event=OnboardCarrierDocs&#session.URLToken#" method="post" preserveData="yes">
				<cfinput id="pageNo" name="pageNo" value="1" type="hidden">
    			<cfinput id="sortOrder" name="sortOrder" value="ASC" type="hidden">
    			<cfinput id="sortBy" name="sortBy" value="CreatedDateTime" type="hidden">
				<fieldset>
					<cfinput name="searchText" type="text" />
					<cfinput name="" onclick="javascript: document.getElementById('pageNo').value=1;" type="submit" class="s-bttn" value="Search" style="width:56px;" />
					<div class="addbutton" style="margin: -5px 0 0 8px;"><a href="index.cfm?event=AddOnboardingDoc&#session.URLToken#">Add New</a></div>
					<div class="clear"></div>
				</fieldset>
			</cfform>			
		</div>
	</div>

	<cfif structKeyExists(session, "OnboardingDocSaveMessage")>
        <div id="message" class="msg-area-#session.OnboardingDocSaveMessage.res#">#session.OnboardingDocSaveMessage.msg#</div>
        <cfset structDelete(session, "OnboardingDocSaveMessage")>
        <div class="clear"></div>
    </cfif>

	<table width="100%" border="0" class="data-table" cellspacing="0" cellpadding="0" style="color:##000000;">
      	<thead>
      		<tr>
      			<th align="center" valign="middle" class="head-bg" style="border-left: 1px solid ##5d8cc9;border-top-left-radius: 5px;">&nbsp;</th>
    			<th align="center" valign="middle" class="head-bg" onclick="sortTableBy('Name','dispDocForm');">Document Name</th>
    			<th align="center" valign="middle" class="head-bg" onclick="sortTableBy('Description','dispDocForm');">Document Description</th>
    			<th align="center" valign="middle" class="head-bg" onclick="sortTableBy('UpdatedDateTime','dispDocForm');">Last Updated</th>
    			<th align="center" valign="middle" class="head-bg" onclick="sortTableBy('UpdateBy','dispDocForm');">Updated By</th>
    			<th width="30" align="center" valign="middle" class="head-bg2"  onclick="sortTableBy('Active','dispDocForm');"  style="border-right: 1px solid ##5d8cc9;border-top-right-radius: 5px;">Active</th>
      		</tr>
      	</thead>
      	<tbody>
      		<cfloop query="request.qGetDoc">	
	            <cfset pageSize = 30>
	            <cfif isdefined("form.pageNo")>
	            	<cfset rowNum=(request.qGetDoc.currentRow) + ((form.pageNo-1)*pageSize)>
	            <cfelse>
	            	<cfset rowNum=(request.qGetDoc.currentRow)>
	            </cfif>
	            <cfset linkStr = "index.cfm?event=AddOnBoardingDoc&ID=#request.qGetDoc.ID#&#session.URLToken#">
	    		<tr <cfif request.qGetDoc.currentRow mod 2 eq 0>bgcolor="##FFFFFF"<cfelse>bgcolor="##f7f7f7"</cfif>>
	    			<td class="sky-bg2" valign="middle" onclick="document.location.href='#linkStr#'" align="center" style="border-left: 1px solid ##5d8cc9;">#rowNum#</td>
					<td  align="left" valign="middle" nowrap="nowrap" class="normal-td" onclick="document.location.href='#linkStr#'"><a title="#request.qGetDoc.Name#" href="#linkStr#">#request.qGetDoc.Name#</a></td>
					<td  align="left" valign="middle" nowrap="nowrap" class="normal-td" onclick="document.location.href='#linkStr#'"><a title="#request.qGetDoc.Name#" href="#linkStr#">#request.qGetDoc.Description#</a></td>
					<td style="padding-right: 2px;" align="right" valign="middle" nowrap="nowrap" class="normal-td" onclick="document.location.href='#linkStr#'"><a title="#request.qGetDoc.Name#" href="#linkStr#">#DateFormat(request.qGetDoc.UpdatedDateTime,"mm/dd/yyyy")#</a></td>
					<td  align="left" valign="middle" nowrap="nowrap" class="normal-td" onclick="document.location.href='#linkStr#'"><a title="#request.qGetDoc.Name#" href="#linkStr#">#request.qGetDoc.UpdateBy#</a></td>
					<td style="border-right: 1px solid ##5d8cc" align="left" valign="middle" nowrap="nowrap" class="normal-td" onclick="document.location.href='#linkStr#'"><a title="#request.qGetDoc.Name#" href="#linkStr#">#YesNoFormat(request.qGetDoc.Active)#</a>
					</td>
	    	 	</tr> 
	    	</cfloop>
	    	<cfif NOT request.qGetDoc.recordcount>
	    		<tr>
    				<td colspan="8" align="center" style="border-left: 1px solid ##5d8cc9;border-right: 1px solid ##5d8cc9;border-bottom-left-radius: 5px;;border-bottom-right-radius: 5px;">No Records Found.</td>
    			</tr>
	    	</cfif>
      	</tbody>
      	<tfoot>
    	 	<tr>
    			<td colspan="8" align="left" valign="middle" class="footer-bg" style="border-left: 1px solid ##5d8cc9;border-right: 1px solid ##5d8cc9;border-bottom-left-radius: 5px;;border-bottom-right-radius: 5px;">
	    			<div class="up-down">
	    				<div class="arrow-top"><a href="javascript: tablePrevPage('dispDocForm');"><img src="images/arrow-top.gif" alt="" /></a></div>
	    				<div class="arrow-bot"><a href="javascript: tableNextPage('dispDocForm');"><img src="images/arrow-bot.gif" alt="" /></a></div>
	    			</div>
	    			<div class="gen-left" style="font-size: 14px;">
			            <cfif request.qGetDoc.recordcount>
			                <button type="button" class="bttn_nav" onclick="tablePrevPage('dispDocForm');">PREV</button>
			                Page 
			                <input type="text" onkeyup="if (/\D/g.test(this.value)) this.value = this.value.replace(/\D/g,'')" value="<cfif structKeyExists(form, "pageNo")>#form.pageNo#<cfelse>1</cfif>" id="jumpPageNo" style="text-align: center;width: 25px;" onchange="jumpToPage('dispDocForm')">
			                      <input type="hidden" id="TotalPages" value="#request.qGetDoc.TotalPages#">
			                of #request.qGetDoc.TotalPages#
			                <button type="button" class="bttn_nav" onclick="tableNextPage('dispDocForm');">NEXT</button>
			            </cfif>
			         </div>
	    			<div class="gen-right"><img src="images/loader.gif" alt="" /></div>
	    			<div class="clear"></div>
    			</td>
    	 	</tr>	
    	</tfoot>	
    </table>
</cfoutput>