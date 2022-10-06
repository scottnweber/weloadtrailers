<cfparam name="sortorder" default="desc">
<cfparam name="sortby"  default="">
<cfparam name="searchText"  default=" ">
<cfparam name="pageNo"  default="1">
<cfinvoke component="#variables.objloadGateway#" method="getSystemSetupOptions" returnvariable="request.qGetSystemSetupOptions" />
<cfif isdefined("form.searchText") >
    <cfinvoke component="#variables.objLoadGateway#" method="getAttachmentTypes" searchText="#form.searchText#" pageNo="#form.pageNo#" sortorder="#form.sortOrder#" sortby="#form.sortBy#" type="Carrier" returnvariable="qAttachmentTypes" />
<cfelse>
    <cfinvoke component="#variables.objLoadGateway#" method="getAttachmentTypes" type="Carrier" returnvariable="qAttachmentTypes" />
</cfif>

<cfoutput>
    <style type="text/css">
        .msg-area{
            width: 465px;
            float: left;
            margin-top: 5px;
            background-color: ##b9e4b9;
        }
    </style>
    <div class="clear"></div>
    <cfinclude template="OnboardingDocTab.cfm">
    <div class="white-con-area" style="height: 36px;background-color: ##82bbef;width:100%;text-align: center;">
        <h2 style="color:white;font-weight:bold;">Docs To be ATTACHED</h2>
    </div>
    <div class="clear"></div>
    <cfif structKeyExists(session, "Message")>
        <div class="msg-area">#session.Message#</div>
        <cfset structdelete(session, 'Message')/> 
        <div class="clear"></div>
    </cfif>
    <div class="search-panel">
        <div class="form-search">
            <cfform id="attachmentTypesForm" name="attachmentTypesForm" action="index.cfm?event=DocsTobeAttached&#session.URLToken#" method="post" preserveData="yes">
                <cfinput id="pageNo" name="pageNo" value="1" type="hidden">
                <cfinput id="sortOrder" name="sortOrder" value="ASC" type="hidden">
                <cfinput id="sortBy" name="sortBy" value="AttachmentType" type="hidden">
                <fieldset>
                    <cfinput name="searchText" type="text" />
                    <input name="" onclick="javascript: document.getElementById('pageNo').value=1;" type="submit" class="s-bttn" value="Search" style="width:56px;" />
                    <div class="clear"></div>
                 </fieldset>
            </cfform>     
        </div>
        <div class="addbutton" style="float:left;margin-left: 105px;"><a href="index.cfm?event=addAttachmentType&RedirectTo=DocsTobeAttached&&#session.URLToken#">Add New</a></div>
    </div>

    <div class="clear"></div>
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
                <th width="85%" align="center" valign="middle" class="head-bg" onclick="sortTableBy('Description','attachmentTypesForm')">Description</th>
                <th width="10%" align="center" valign="middle" class="head-bg2">Required</th>
                <th  align="right" valign="top"><img src="images/top-right.gif" alt="" width="5" height="23" /></th>
            </tr>
        </thead>
        <tbody>
            <cfloop query="qAttachmentTypes">
                <tr <cfif qAttachmentTypes.currentRow mod 2 eq 0>bgcolor="##FFFFFF"<cfelse>bgcolor="##f7f7f7"</cfif>>
                    <td height="20" class="sky-bg">&nbsp;</td>
                    <td class="sky-bg2" valign="middle" align="center">#rowNum + qAttachmentTypes.currentRow#</td>
                    <td  align="left" valign="middle" nowrap="nowrap" class="normal-td" onclick="document.location.href='index.cfm?event=addAttachmentType&RedirectTo=DocsTobeAttached&ID=#qAttachmentTypes.AttachmentTypeID#&#session.URLToken#'"><a href="index.cfm?event=addAttachmentType&RedirectTo=DocsTobeAttached&ID=#qAttachmentTypes.AttachmentTypeID#&#session.URLToken#">#qAttachmentTypes.Description#</a></td>
                    <td  align="left" valign="middle" nowrap="nowrap" class="normal-td2">
                        <cfif qAttachmentTypes.Required>Yes<cfelse>No</cfif>
                    </td>
                    <td class="normal-td3">&nbsp;</td>
                </tr>
            </cfloop>
       </tbody>
       <tfoot>
            <tr>
                <td width="5" align="left" valign="top"><img src="images/left-bot.gif" alt="" width="5" height="23" /></td>
                <td colspan="3" align="left" valign="middle" class="footer-bg">
                    <div class="up-down">
                        <div class="arrow-top"><a href="javascript: tablePrevPage('attachmentTypesForm');"><img src="images/arrow-top.gif" alt="" /></a></div>
                        <div class="arrow-bot"><a href="javascript: tableNextPage('attachmentTypesForm');"><img src="images/arrow-bot.gif" alt="" /></a></div>
                    </div>
                    <div class="gen-left"><a href="javascript: tablePrevPage('attachmentTypesForm');">Prev </a>-<a href="javascript: tableNextPage('attachmentTypesForm');"> Next</a></div>
                    <div class="gen-right"><img src="images/loader.gif" alt="" /></div>
                    <div class="clear"></div>
                </td>
                <td width="5" align="right" valign="top"><img src="images/right-bot.gif" alt="" width="5" height="23" /></td>
            </tr>  
        </tfoot>   
    </table>
</cfoutput>

    