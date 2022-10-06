<cfparam name="form.RoleID" default="0"> 
<cfinvoke component="#variables.objloadGateway#" method="getSystemSetupOptions" returnvariable="request.qGetSystemSetupOptions" />
<cfinvoke component="#variables.objagentGateway#" method="getRoles" returnvariable="request.qRoles" />
<cfinvoke component="#variables.objagentGateway#" method="getLoadStatusType" CompanyID="#session.CompanyID#" returnvariable="request.qgetLoadStatusType" />
<cfif structKeyExists(url, "RoleID")>
    <cfset form.RoleID = url.RoleID>
</cfif>
<cfinvoke component="#variables.objagentGateway#" method="getRoleSecurityParameters" RoleID="#form.RoleID#" returnvariable="request.qgetRoleSecurityParameters" />
<cfoutput>
    <style>
        .space_it{
            float: left;
            text-align: right;
            width: 75px;
            padding: 0 10px 0 0;
            font-size: 11px;
            font-weight: bold;
            color: ##000000;
        }
        .medium{
            float: left;
            width: 130px;
            height: 21px;
            background: ##FFFFFF;
            border: 1px solid ##b3b3b3;
            padding: 0;
            margin: 0 0 4px 0;
            font-size: 11px;
        }
    </style>
    <div class="clear"></div>
    <cfinclude template="UserRolesTab.cfm">
    <div class="white-con-area" style="height: 36px;background-color: ##82bbef;width:999px;text-align: center;">
        <h2 style="color:white;font-weight:bold;">Select Role and what Load Status they can edit.</h2>
    </div>
    <form name="userRightsform" id="userRightsform" action="index.cfm?event=LoadStatus&#session.URLToken#" method="POST" style="    margin-top: 15px">
        <label class="space_it">Select Role:</label>
        <select name="RoleID" id="RoleID" class="medium" onchange="this.form.submit()">
            <option value="0">Select</option>
            <cfloop query="request.qRoles">
                <option value="#request.qRoles.RoleID#" <cfif request.qRoles.RoleID eq form.roleID> selected="selected" </cfif> >#request.qRoles.RoleValue#</option>
            </cfloop>
        </select>
    </form>
    <div id="saved" style="float:left; display:none; margin: -7px 20px;"><h3 style="font-weight:700; font-style: italic; color: ##32CD32;">SAVED</h3></div>
    <div class="clear" style="margin-bottom:10px;"></div>
    <table width="100%" border="0" class="data-table" cellspacing="0" cellpadding="0" style="color:##000000;">
        <thead>
            <tr>
                <th align="center" valign="middle" class="head-bg" style="border-left: 1px solid ##5d8cc9;width: 20px;border-top-left-radius: 5px;">&nbsp;</th>
                <th align="center" valign="middle" class="head-bg" onclick="" style="width: 65px">Allow Edit?</th>
                <th align="center" valign="middle" class="head-bg2"  onclick="sortTableBy('Active','dispDocForm');"  style="border-right: 1px solid ##5d8cc9;border-top-right-radius: 5px;">Description</th>
            </tr>
        </thead>
        <tbody>
            <cfif form.RoleID NEQ 0>
                <cfloop query="request.qgetLoadStatusType">	
                    <cfset pageSize = 30>
                    <cfif isdefined("form.pageNo")>
                        <cfset rowNum=(request.qgetLoadStatusType.currentRow) + ((form.pageNo-1)*pageSize)>
                    <cfelse>
                        <cfset rowNum=(request.qgetLoadStatusType.currentRow)>
                    </cfif>
                    <tr>
                        <td class="sky-bg2" valign="middle" align="center" style="border-left: 1px solid ##5d8cc9; width: 20px">#rowNum#</td>
                        <td  align="center" valign="middle" nowrap="nowrap" class="normal-td" style="padding:0">    
                            <input type="checkbox" name="editableStatus" id="editableStatus" class="editableStatus"<cfif listFindNoCase(request.qgetRoleSecurityParameters.EditableStatuses,request.qgetLoadStatusType.StatusText)> checked </cfif>value="#request.qgetLoadStatusType.StatusText#">    
                        </td>
                        <td style="border-right: 1px solid ##5d8cc" align="left" valign="middle" nowrap="nowrap" class="normal-td">#request.qgetLoadStatusType.StatusDescription#</a></td>
                    </tr>
                </cfloop>
            <cfelse>
                <tr>
                    <td colspan="5" align="center" style="border-left: 1px solid ##5d8cc9;border-right: 1px solid ##5d8cc9;">No Records Found.</td>
                </tr>
            </cfif>
        </tbody>
        <tfoot>
            <tr>
                <td colspan="5" align="left" valign="middle" class="footer-bg" style="border-left: 1px solid ##5d8cc9;border-right: 1px solid ##5d8cc9;border-bottom-left-radius: 5px;;border-bottom-right-radius: 5px;">
                    <div class="gen-right"><img src="images/loader.gif" alt="" /></div>
                    <div class="clear"></div>
                </td>
            </tr>	
        </tfoot>
    </table>
    <script>
        $(document).ready(function(){
            $('.editableStatus').click(function(){
                var RoleID = $('##RoleID').val();
                if(RoleID!=0){
                    var editableStatus = [];
                    $(".editableStatus:checked").each(function()
                    {
                        editableStatus.push($(this).val());
                    })

                    $.ajax({
                        type    : 'POST',
                        url     : "ajax.cfm?event=ajxUpdateEditableStatus&#session.URLToken#",
                        data    : {RoleID : RoleID, editableStatus  : JSON.stringify(editableStatus) },
                    })
                    if($(this).prop('checked') == true){
                        setTimeout(() =>{
                            $('##saved').show();
                        },1000);
                        setTimeout(() =>{
                            $('##saved').hide();
                        },3000);
                    }else{
                        setTimeout(() =>{
                            $('##saved').show();
                        },1000);
                        setTimeout(() =>{
                            $('##saved').hide();
                        },3000);
                    }
                }
            })
        })
    </script>
</cfoutput>