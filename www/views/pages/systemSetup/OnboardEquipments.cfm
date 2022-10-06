<cfparam name="url.sortorder" default="desc">
<cfparam name="sortby"  default="">
<cfinvoke component="#variables.objloadGateway#" method="getSystemSetupOptions" returnvariable="request.qGetSystemSetupOptions" />

<cfsilent>
    <cfif isdefined("form.searchText") >
        <cfinvoke component="#variables.objCarrierGateway#" method="getOnBoardEquipments" searchText="#form.searchText#" pageNo="#form.pageNo#" sortorder="#form.sortOrder#" sortby="#form.sortBy#"  returnvariable="qEquipments" />
    <cfelse>
        <cfinvoke component="#variables.objCarrierGateway#" method="getOnBoardEquipments" searchText="" pageNo="1" returnvariable="qEquipments" />
    </cfif>
</cfsilent>

<cfoutput>
    <script>
    $(document).ready(function(){
        $('.SelectAll').click(function(){
            var ckd = $(this).is(":checked");
            $('.EquipmentID').prop('checked', ckd);
            var id = $.map($('.EquipmentID'), function(n, i){
                  return n.value;
            }).join(',');
            $.ajax({
                type    : 'POST',
                url     : "ajax.cfm?event=ajxSelectEquipment&#session.URLToken#",
                data    : {
                    EquipmentID:id,ShowCarrierOnboarding:ckd
                },
                success :function(data){}
            })
        })
    })
    function selectEquipment(ele){
        var ckd = $(ele).is(":checked");
        var id = $(ele).val();
        $.ajax({
            type    : 'POST',
            url     : "ajax.cfm?event=ajxSelectEquipment&#session.URLToken#",
            data    : {
                EquipmentID:id,ShowCarrierOnboarding:ckd
            },
            success :function(data){}
        })
        if(ckd == true){
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
    </script>


    <div class="clear"></div>
    <cfinclude template="OnboardingDocTab.cfm">
    <div class="white-con-area" style="height: 36px;background-color: ##82bbef;width:100%;text-align: center;">
        <h2 style="color:white;font-weight:bold;">Equipments</h2>
    </div>
    <div class="clear"></div>
    <cfif structKeyExists(url, "EquipmentSaved")>
        <div class="msg-area" style="margin-left:10px;margin-top: 2px;">Equipment has been saved Successfully.</div>
    </cfif>
    <div class="search-panel">
        <div class="form-search">
            <cfform id="dispEquipments" name="dispEquipments" action="index.cfm?event=OnboardEquipments&#session.URLToken#" method="post" preserveData="yes">
                <cfinput id="pageNo" name="pageNo" value="1" type="hidden">
                <cfinput id="sortOrder" name="sortOrder" value="ASC" type="hidden">
                <cfinput id="sortBy" name="sortBy" value="E.EquipmentCode" type="hidden">
                <fieldset>
                    <cfinput name="searchText" type="text" />
                    <cfinput name="" onclick="javascript: document.getElementById('pageNo').value=1;" type="submit" class="s-bttn" value="Search" style="width:56px;" />
                    <div id="saved" style="float:right; display:none;"><h3 style="font-weight:700; font-style: italic; margin: -6px 0 0 35px; color: ##32CD32;">SAVED</h3></div>
                    <div class="clear"></div>
                </fieldset>
            </cfform>
        </div>
    </div>
    <cfif request.qGetSystemSetupOptions.freightBroker EQ 0>
        <cfset isCarrier = 0>
    <cfelse>
        <cfset isCarrier = 1>
    </cfif>
    <div class="addbutton"><a href="index.cfm?event=addEquipment&#session.URLToken#&IsCarrier=#isCarrier#&relocationEvent=OnboardEquipments">Add New</a></div>
    <div class="clear"></div>
    <table width="100%" border="0" class="data-table" cellspacing="0" cellpadding="0" style="color:##000000;">
        <thead>
            <tr>
                <th width="5" align="center" valign="middle" class="head-bg" style="border-left: 1px solid ##5d8cc9;border-top-left-radius: 5px;">&nbsp;</th>
                <th align="center" valign="middle" class="head-bg">
                    <input type="checkbox" class="SelectAll">
                </th>
                <th align="center" valign="middle" class="head-bg" onclick="sortTableBy('E.EquipmentCode','dispEquipments');">Equip Code</th>
                <th align="center" valign="middle" class="head-bg" onclick="sortTableBy('E.EquipmentName','dispEquipments');">Description</th>
                <th align="center" valign="middle" class="head-bg" onclick="sortTableBy('E.EquipmentType','dispEquipments');">Type</th>
                <th align="center" valign="middle" class="head-bg" onclick="sortTableBy('E.Length','dispEquipments');">L x W</th>
                <th align="center" valign="middle" class="head-bg" onclick="sortTableBy('E.IsActive','dispEquipments');">Active</th>
                <th align="center" valign="middle" class="head-bg2" onclick="sortTableBy('E.temperature','dispEquipments');" style="border-right: 1px solid ##5d8cc9;border-top-right-radius: 5px;">Temperature</th>
            </tr>
        </thead>
        <tbody>
            <cfloop query="qEquipments">  
                <cfset pageSize = 30>
                <cfset href="index.cfm?event=addEquipment&EquipmentID=#qEquipments.EquipmentID#&#session.URLToken#&relocationEvent=OnboardEquipments">
                <cfif request.qGetSystemSetupOptions.freightBroker EQ 0>
                    <cfset href &= '&IsCarrier=0'>
                <cfelse>
                    <cfset href &= '&IsCarrier=1'>
                </cfif>
                <cfif isdefined("form.pageNo")>
                    <cfset rowNum=(qEquipments.currentRow) + ((form.pageNo-1)*pageSize)>
                <cfelse>
                    <cfset rowNum=(qEquipments.currentRow)>
                </cfif>
                <tr <cfif qEquipments.currentRow mod 2 eq 0>bgcolor="##FFFFFF"<cfelse>bgcolor="##f7f7f7"</cfif>>
                    <td class="sky-bg2" valign="middle" onclick="document.location.href='#href#'" align="center" style="border-left: 1px solid ##5d8cc9;">#rowNum#</td>
                    <td  align="center" valign="middle" nowrap="nowrap" class="normal-td" style="padding-left: 0;">
                        <input type="checkbox" name="EquipmentID" class="EquipmentID" value="#qEquipments.EquipmentID#" <cfif qEquipments.ShowCarrierOnboarding> checked </cfif> onclick="selectEquipment(this);">
                    </td>
                    <td  align="left" valign="middle" nowrap="nowrap" class="normal-td" onclick="document.location.href='#href#'">
                        <a title="#qEquipments.EquipmentCode#" href="#href#">#qEquipments.EquipmentCode#</a>
                    </td>
                    <td  align="left" valign="middle" nowrap="nowrap" class="normal-td" onclick="document.location.href='#href#'">
                        <a title="#qEquipments.EquipmentCode#" href="#href#">#qEquipments.EquipmentName#</a>
                    </td>
                    <td  align="left" valign="middle" nowrap="nowrap" class="normal-td" onclick="document.location.href='#href#'">
                        <a title="#qEquipments.EquipmentCode#" href="#href#">#qEquipments.EquipmentType#</a>
                    </td>
                    <td  align="right" valign="middle" nowrap="nowrap" class="normal-td" onclick="document.location.href='#href#'" style="padding-right: 2px;">
                         <cfif len(trim(qEquipments.Length)) AND len(trim(qEquipments.Width))>
                            <a title="#qEquipments.EquipmentCode#" href="#href#">#qEquipments.Length# x #qEquipments.Width#</a>
                        </cfif>
                    </td>
                    <td  align="left" valign="middle" nowrap="nowrap" class="normal-td" onclick="document.location.href='#href#'">
                        <a title="#qEquipments.EquipmentCode#" href="#href#"><cfif qEquipments.IsActive EQ 1>Yes<cfelse>No</cfif></a>
                    </td>
                    <td style="border-right: 1px solid ##5d8cc9;padding-right: 2px;" align="right" valign="middle" nowrap="nowrap" class="normal-td2" onclick="document.location.href='#href#'">
                        <cfif len(trim(qEquipments.Temperature))><a href="#href#">#qEquipments.Temperature#<sup>o</sup><cfif len(trim(qEquipments.TemperatureScale))>#qEquipments.TemperatureScale#</cfif></a></cfif>
                    </td>
                </tr>
            </cfloop>
        </tbody>
        <tfoot>
            <tr>
                <td colspan="8" align="left" valign="middle" class="footer-bg" style="border-left: 1px solid ##5d8cc9;border-right: 1px solid ##5d8cc9;border-bottom-left-radius: 5px;;border-bottom-right-radius: 5px;">
                    <div class="up-down">
                        <div class="arrow-top"><a href="javascript: tablePrevPage('dispEquipments');"><img src="images/arrow-top.gif" alt="" /></a></div>
                        <div class="arrow-bot"><a href="javascript: tableNextPage('dispEquipments');"><img src="images/arrow-bot.gif" alt="" /></a></div>
                    </div>
                    <div class="gen-left"><a href="javascript: tablePrevPage('dispEquipments');">Prev </a>-<a href="javascript: tableNextPage('dispEquipments');"> Next</a></div>
                    <div class="gen-right"><img src="images/loader.gif" alt="" /></div>
                    <div class="clear"></div>
                </td>
            </tr>  
        </tfoot>
    </table>
</cfoutput>

    