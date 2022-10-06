<cfparam name="message" default="">
<cfparam name="sortorder" default="desc">
<cfparam name="sortby"  default="">
<cfparam name="searchText"  default=" ">
<cfparam name="pageNo"  default="1">
<cfoutput>
    <style type="text/css">
        .msg-area{
            width: 465px;
            float: left;
            margin-top: 5px;
            background-color: ##b9e4b9;
        }
    </style>
    <h1>Departments</h1>
    <div style="clear:left"></div>

    <cfif structKeyExists(session, "AcctDeptMsg")>
        <div class="msg-area" style="width:500px">#session.AcctDeptMsg#</div>
        <cfset structdelete(session, 'AcctDeptMsg')/> 
    </cfif>
    <div style="clear:left"></div>
    <div class="search-panel">
        <div class="form-search">
            <cfform id="DepartmentsForm" name="DepartmentsForm" action="index.cfm?event=Departments&#session.URLToken#" method="post" preserveData="yes">
                <cfinput id="pageNo" name="pageNo" value="1" type="hidden">
                <cfinput id="sortOrder" name="sortOrder" value="ASC" type="hidden">
                <cfinput id="sortBy" name="sortBy" value="Description" type="hidden">
                <fieldset>
                    <cfinput name="searchText" type="text" />
                    <input name="" onclick="javascript: document.getElementById('pageNo').value=1;" type="submit" class="s-bttn" value="Search" style="width:56px;" />
                    <div class="clear"></div>
                 </fieldset>
            </cfform>     
        </div>
        <div class="addbutton" style="float:left;margin-left: 105px;"><a href="index.cfm?event=AccountDepartments&#session.URLToken#">Add New</a></div>
    </div>
    <cfif isdefined("form.searchText") >
    	<cfinvoke component="#variables.objLoadGateway#" method="getLMADepartments" searchText="#form.searchText#" pageNo="#form.pageNo#" sortorder="#form.sortOrder#" sortby="#form.sortBy#" returnvariable="qDepartments" />
    <cfelse>
    	<cfinvoke component="#variables.objLoadGateway#" method="getLMADepartments" returnvariable="qDepartments" />
    </cfif>
	
    <cfset pageSize = 30>
    <cfif isdefined("form.pageNo")>
        <cfset rowNum = ((form.pageNo-1)*pageSize)>
    <cfelse>
        <cfset rowNum = 0>
    </cfif>
    <div class="clear"></div>
    <table width="50%" border="0" class="data-table" cellspacing="0" cellpadding="0" style="color:##000000;">
        <thead>
            <tr>
                <th  align="left" valign="top"><img src="images/top-left.gif" alt="" width="5" height="23" /></th>
                <th  align="center" valign="middle" class="head-bg">&nbsp;</th>
                <th align="center" valign="middle" class="head-bg" onclick="sortTableBy('Dept','DepartmentsForm')">Dept</th>
                <th align="center" valign="middle" class="head-bg2"  onclick="sortTableBy('Description','DepartmentsForm')">Description</th>
                <th  align="right" valign="top"><img src="images/top-right.gif" alt="" width="5" height="23" /></th>
            </tr>
        </thead>
        <tbody>
            <cfloop query="qDepartments">
                <tr <cfif qDepartments.currentRow mod 2 eq 0>bgcolor="##FFFFFF"<cfelse>bgcolor="##f7f7f7"</cfif>>
                    <td height="20" class="sky-bg">&nbsp;</td>
                    <td class="sky-bg2" valign="middle" align="center" onclick="document.location.href='index.cfm?event=AccountDepartments&ID=#qDepartments.ID#&#session.URLToken#'"><a href="index.cfm?event=AccountDepartments&ID=#qDepartments.ID#&#session.URLToken#">#rowNum + qDepartments.currentRow#</a></td>
                    <td  align="left" valign="middle" nowrap="nowrap" class="normal-td" onclick="document.location.href='index.cfm?event=AccountDepartments&ID=#qDepartments.ID#&#session.URLToken#'"><a href="index.cfm?event=AccountDepartments&ID=#qDepartments.ID#&#session.URLToken#">#qDepartments.Dept#</a></td>
                    <td  align="left" valign="middle" nowrap="nowrap" class="normal-td2" onclick="document.location.href='index.cfm?event=AccountDepartments&ID=#qDepartments.ID#&#session.URLToken#'"><a href="index.cfm?event=AccountDepartments&ID=#qDepartments.ID#&#session.URLToken#">#qDepartments.Description#</a></td>
                    <td class="normal-td3">&nbsp;</td>
                </tr>
            </cfloop>
       </tbody>
       <tfoot>
            <tr>
                <td width="5" align="left" valign="top"><img src="images/left-bot.gif" alt="" width="5" height="23" /></td>
                <td colspan="3" align="left" valign="middle" class="footer-bg">
                    <div class="up-down">
                        <div class="arrow-top"><a href="javascript: tablePrevPage('DepartmentsForm');"><img src="images/arrow-top.gif" alt="" /></a></div>
                        <div class="arrow-bot"><a href="javascript: tableNextPage('DepartmentsForm');"><img src="images/arrow-bot.gif" alt="" /></a></div>
                    </div>
                    <div class="gen-left" style="font-size: 14px;">
                          <cfif qDepartments.recordcount>
                              <button type="button" class="bttn_nav" onclick="tablePrevPage('DepartmentsForm');">PREV</button>
                              Page
                              <input type="text" onkeyup="if (/\D/g.test(this.value)) this.value = this.value.replace(/\D/g,'')" value="<cfif structKeyExists(form, "pageNo")>#form.pageNo#<cfelse>1</cfif>" id="jumpPageNo" style="text-align: center;width: 25px;" onchange="jumpToPage('DepartmentsForm')">
                                  <input type="hidden" id="TotalPages" value="#qDepartments.TotalPages#">
                              of #qDepartments.TotalPages#
                              <button type="button" class="bttn_nav" onclick="tableNextPage('DepartmentsForm');">NEXT</button>
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