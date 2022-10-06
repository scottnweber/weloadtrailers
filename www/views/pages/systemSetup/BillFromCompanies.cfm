<cfinvoke component="#variables.objloadGateway#" method="getSystemSetupOptions" returnvariable="request.qGetSystemSetupOptions" />
<cfparam name="message" default="">
<cfparam name="url.sortorder" default="asc">
<cfparam name="sortby"  default="">
<cfsilent>
    <cfif isdefined("form.searchText") >
        <cfinvoke component="#variables.objAgentGateway#" method="SearchBillFromCompanies" searchText="#form.searchText#" pageNo="#form.pageNo#" sortorder="#form.sortOrder#" sortby="#form.sortBy#"  returnvariable="request.qCompanies" />
    <cfelse>
        <cfinvoke component="#variables.objAgentGateway#" method="SearchBillFromCompanies"  searchText="" pageNo="1" returnvariable="request.qCompanies" />
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
	<script>
		function setDefaultBillFromCompany(){
			if ($('##DefaultBillFrom').prop('checked') == true) {
				var checked = 1;
			} else {
				var checked = 0;
			}
			var CompanyID = "#session.companyID#"
			$.ajax({
				type    : 'POST',
				url     : "ajax.cfm?event=ajxsetDefaultBillFromCompany&#session.URLToken#",
				data    : {CompanyID : CompanyID, checked : checked}
			})
		}
	</script>
	<h1>Bill From Companies</h1>
	<div style="clear:left"></div>
	<div class="search-panel">
		<div class="form-search">
			<cfform id="dispBillFromCompanyForm" name="dispBillFromCompanyForm" action="index.cfm?event=BillFromCompanies&#session.URLToken#" method="post" preserveData="yes">
				<cfinput id="pageNo" name="pageNo" value="1" type="hidden">
    			<cfinput id="sortOrder" name="sortOrder" value="ASC" type="hidden">
    			<cfinput id="sortBy" name="sortBy" value="CompanyName" type="hidden">
				<fieldset>
					<cfinput name="searchText" type="text" />
					<cfinput name="" onclick="javascript: document.getElementById('pageNo').value=1;" type="submit" class="s-bttn" value="Search" style="width:56px;" />
					<div class="clear"></div>
				</fieldset>
			</cfform>			
		</div>
	</div>
	<div class="addbutton" style="float: left;margin: 4px 0 0px 10px;"><a href="index.cfm?event=AddBillFromCompany&#session.URLToken#">Add Bill From Company</a></div>
	<div class="DefaultBillFrom" style="float: left;margin: 13px 0px 0px 75px;">
		<input name="DefaultBillFrom" id="DefaultBillFrom" type="checkbox" value="1" class="small_chk" style="float: left;margin: 2px 10px 0 0px;"<cfif request.qGetSystemSetupOptions.DefaultBillFromAsCompany>checked</cfif> onclick="setDefaultBillFromCompany();">
		<label style="width: 210px;">Set Default "Bill From" as #request.qGetSystemSetupOptions.companyName#</label>
	</div>
	<cfif structKeyExists(session, "CompanySaveMessage")>
        <div id="message" class="msg-area-#session.CompanySaveMessage.res#">#session.CompanySaveMessage.msg#</div>
        <cfset structDelete(session, "CompanySaveMessage")>
        <div class="clear"></div>
    </cfif>

	<table width="100%" border="0" class="data-table" cellspacing="0" cellpadding="0" style="color:##000000;">
      	<thead>
      		<tr>
      			<th align="center" valign="middle" class="head-bg" style="border-left: 1px solid ##5d8cc9;border-top-left-radius: 5px;">&nbsp;</th>
    			<th align="center" valign="middle" class="head-bg" onclick="sortTableBy('CompanyName','dispBillFromCompanyForm');">Company Name</th>
    			<th align="center" valign="middle" class="head-bg" onclick="sortTableBy('Email','dispBillFromCompanyForm');">Email</th>
    			<th align="center" valign="middle" class="head-bg" onclick="sortTableBy('Address','dispBillFromCompanyForm');">Address</th>
    			<th align="center" valign="middle" class="head-bg" onclick="sortTableBy('City','dispBillFromCompanyForm');">City</th>
    			<th align="center" valign="middle" class="head-bg" onclick="sortTableBy('State','dispBillFromCompanyForm');">State</th>
    			<th align="center" valign="middle" class="head-bg" onclick="sortTableBy('Zipcode','dispBillFromCompanyForm');">Zipcode</th>
    			<th align="center" valign="middle" class="head-bg" onclick="sortTableBy('PhoneNumber','dispBillFromCompanyForm');">PhoneNumber</th>
    			<th width="30" align="center" valign="middle" class="head-bg2"  onclick="sortTableBy('Fax','dispBillFromCompanyForm');"  style="border-right: 1px solid ##5d8cc9;border-top-right-radius: 5px;">Fax</th>
      		</tr>
      	</thead>
      	<tbody>
      		<cfloop query="request.qCompanies">	
	            <cfset pageSize = 30>
	            <cfif isdefined("form.pageNo")>
	            	<cfset rowNum=(request.qCompanies.currentRow) + ((form.pageNo-1)*pageSize)>
	            <cfelse>
	            	<cfset rowNum=(request.qCompanies.currentRow)>
	            </cfif>
	            <cfset linkStr = "index.cfm?event=AddBillFromCompany&ID=#request.qCompanies.BillFromCompanyID#&#session.URLToken#">
	    		<tr <cfif request.qCompanies.currentRow mod 2 eq 0>bgcolor="##FFFFFF"<cfelse>bgcolor="##f7f7f7"</cfif>>
	    			<td class="sky-bg2" valign="middle" onclick="document.location.href='#linkStr#'" align="center" style="border-left: 1px solid ##5d8cc9;">#rowNum#</td>
					<td  align="left" valign="middle" nowrap="nowrap" class="normal-td" onclick="document.location.href='#linkStr#'"><a title="#request.qCompanies.CompanyName#" href="#linkStr#">#request.qCompanies.CompanyName#</a></td>
					<td  align="left" valign="middle" nowrap="nowrap" class="normal-td" onclick="document.location.href='#linkStr#'"><a title="#request.qCompanies.CompanyName#" href="#linkStr#">#request.qCompanies.Email#</a></td>
					<td style="padding-right: 2px;" align="right" valign="middle" nowrap="nowrap" class="normal-td" onclick="document.location.href='#linkStr#'"><a title="#request.qCompanies.CompanyName#" href="#linkStr#">#request.qCompanies.Address#</a></td>
					<td  align="left" valign="middle" nowrap="nowrap" class="normal-td" onclick="document.location.href='#linkStr#'"><a title="#request.qCompanies.CompanyName#" href="#linkStr#">#request.qCompanies.City#</a></td>
					<td  align="left" valign="middle" nowrap="nowrap" class="normal-td" onclick="document.location.href='#linkStr#'"><a title="#request.qCompanies.CompanyName#" href="#linkStr#">#request.qCompanies.State#</a></td>
					<td  align="left" valign="middle" nowrap="nowrap" class="normal-td" onclick="document.location.href='#linkStr#'"><a title="#request.qCompanies.CompanyName#" href="#linkStr#">#request.qCompanies.ZipCode#</a></td>
					<td  align="left" valign="middle" nowrap="nowrap" class="normal-td" onclick="document.location.href='#linkStr#'"><a title="#request.qCompanies.CompanyName#" href="#linkStr#">#request.qCompanies.PhoneNumber#</a></td>
					<td style="border-right: 1px solid ##5d8cc" align="left" valign="middle" nowrap="nowrap" class="normal-td" onclick="document.location.href='#linkStr#'"><a title="#request.qCompanies.CompanyName#" href="#linkStr#">#request.qCompanies.Fax#</a>
					</td>
	    	 	</tr> 
	    	</cfloop>
	    	<cfif NOT request.qCompanies.recordcount>
	    		<tr>
    				<td colspan="8" align="center" style="border-left: 1px solid ##5d8cc9;border-right: 1px solid ##5d8cc9;border-bottom-left-radius: 5px;;border-bottom-right-radius: 5px;">No Records Found.</td>
    			</tr>
	    	</cfif>
      	</tbody>
      	<tfoot>
    	 	<tr>
    			<td colspan="9" align="left" valign="middle" class="footer-bg" style="border-left: 1px solid ##5d8cc9;border-right: 1px solid ##5d8cc9;border-bottom-left-radius: 5px;;border-bottom-right-radius: 5px;">
	    			<div class="up-down">
	    				<div class="arrow-top"><a href="javascript: tablePrevPage('dispBillFromCompanyForm');"><img src="images/arrow-top.gif" alt="" /></a></div>
	    				<div class="arrow-bot"><a href="javascript: tableNextPage('dispBillFromCompanyForm');"><img src="images/arrow-bot.gif" alt="" /></a></div>
	    			</div>
	    			<div class="gen-left" style="font-size: 14px;">
			            <cfif request.qCompanies.recordcount>
			                <button type="button" class="bttn_nav" onclick="tablePrevPage('dispBillFromCompanyForm');">PREV</button>
			                Page 
			                <input type="text" onkeyup="if (/\D/g.test(this.value)) this.value = this.value.replace(/\D/g,'')" value="<cfif structKeyExists(form, "pageNo")>#form.pageNo#<cfelse>1</cfif>" id="jumpPageNo" style="text-align: center;width: 25px;" onchange="jumpToPage('dispBillFromCompanyForm')">
			                      <input type="hidden" id="TotalPages" value="#request.qCompanies.TotalPages#">
			                of #request.qCompanies.TotalPages#
			                <button type="button" class="bttn_nav" onclick="tableNextPage('dispBillFromCompanyForm');">NEXT</button>
			            </cfif>
			         </div>
	    			<div class="gen-right"><img src="images/loader.gif" alt="" /></div>
	    			<div class="clear"></div>
    			</td>
    	 	</tr>	
    	</tfoot>	
    </table>
</cfoutput>