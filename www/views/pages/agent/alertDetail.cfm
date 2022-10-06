<cfparam name="variables.isLocked" default="0">
<cfoutput>
   <cfinvoke component="#variables.objloadGateway#" method="getSystemSetupOptions" returnvariable="request.qSystemSetupOptions" />
    <style type="text/css">
        .white-mid div.form-con label {
            float: left;
            text-align: right;
            width: 70px;
            padding: 0 10px 0 0;
            font-size: 11px;
            font-weight: bold;
            color: ##000000;
        }


        .white-mid div.form-con input {
            float: left;
            width: 200px;
            background: ##FFFFFF;
            border: 1px solid ##b3b3b3;
            padding: 2px 2px 0 2px;
            margin: 0 0 8px 0;
            font-size: 11px;
            margin-right: 8px !important;
            height: 18px;
        }

        .datefield{
            width: 60px !important;
        }
    </style>
    <script>

        $(document).ready(function(){
            $( ".datefield" ).datepicker({
                dateFormat: "mm/dd/yy",
                showOn: "button",
                buttonImage: "images/DateChooser.png",
                buttonImageOnly: true,
                showButtonPanel: true
            });
            $( ".datefield" ).datepicker( "option", "showButtonPanel", true );
            var old_goToToday = $.datepicker._gotoToday
            $.datepicker._gotoToday = function(id) {
                old_goToToday.call(this,id)
                this._selectDate(id)
            }
        })

        function AcknowledgeAlert(AlertID){
            $.ajax({
                type    : 'POST',
                url     : "ajax.cfm?event=ajxAcknowledgeAlert&AlertID="+AlertID+"&#session.URLToken#",
                data    : {},
                success :function(data){
                    document.location.href='index.cfm?event=Alerts&#session.URLToken#'
                }
            })
        }
    </script>
    <cfform id="AlertClaimForm" name="AlertClaimForm" action="index.cfm?event=claimAlert&#session.URLToken#" method="post" preserveData="yes">
        <input type="hidden" name="TypeID" value="#request.qAlertDetail.TypeID#">
        <input type="hidden" name="Type" value="#request.qAlertDetail.Type#">
        <input type="hidden" name="AlertID" value="#request.qAlertDetail.AlertID#">
        <input type="hidden" name="CurrUser" id="CurrUser" value="#session.empid#">

        <cfif len(trim(request.qAlertDetail.InUseBy)) AND request.qAlertDetail.InUseBy NEQ session.EmpID>
            <cfset variables.isLocked = 1>
            <input type="hidden" name="lockeduser" id="lockeduser" value="#request.qAlertDetail.InUseBy#">
            <div class="msg-area" style="margin-left:0px;margin-bottom:10px;width: 368px;">
                <span style="color:##d21f1f">
                    This alert is locked by #request.qAlertDetail.LockedUser#.
                </span>
            </div>
            <div class="clear"></div>
        <cfelse>
            <input type="hidden" name="lockeduser" id="lockeduser" value="#session.empid#">
            <cfinvoke component="#variables.objAlertGateway#" method="lockAlertForCurrentUser" AlertID="#url.AlertID#"/>
        </cfif>


        <div class="white-con-area" style="width:999px">
            <div class="white-mid" style="width:999px">
                <div class="form-con" style="width:400px;padding:0;background-color: ##defaf9 !important;">
                    <div style="height: 36px;background-color: ##82bbef;margin-bottom: 5px;float: right;">
                        <h2 style="color:white;font-weight:bold;padding-top: 10px;width:390px;text-align: left;">Alert Details</h2>
                    </div>
                    <div style="margin-left: 5px;font-size: 14px;font-weight: bold;text-decoration: underline;"><cfif len(trim(request.qAlertDetail.Reference))>#request.qAlertDetail.Type####request.qAlertDetail.Reference# </cfif>#request.qAlertDetail.Description#</div>
                    <div class="clear"></div>

                    <cfswitch expression="#request.qAlertDetail.Type#">
                        <cfcase value="Load">
                            <table width="100%">
                                <tbody>
                                    <tr>
                                        <td align="right" style="font-weight: bold;">Created By:</td>
                                        <td>#request.qAlertDetail.CreatedUser#</td>
                                        <td align="right" style="font-weight: bold;">Created On:</td>
                                        <td>#DateFormat(request.qAlertDetail.CreatedDateTime,"mm/dd/yyyy")#</td>
                                    </tr>
                                    <tr>
                                        <td align="right" style="font-weight: bold;">CarrierRate:</td>
                                        <td>#dollarformat(request.qAlertDetail.TotalCarrierCharges)#</td>
                                        <td align="right" style="font-weight: bold;">Profit:</td>
                                        <td>#NumberFormat(request.qAlertDetail.Profit, "0.00")#%</td>
                                    </tr>
                                    <tr>
                                        <td align="right" style="font-weight: bold;">CustomerRate:</td>
                                        <td>#dollarformat(request.qAlertDetail.TotalCustomerCharges)#</td>
                                        <cfif request.qSystemSetupOptions.AutomaticFactoringFee eq 1>
                                            <td align="right" style="font-weight: bold;">Factoring Fee:</td>
                                            <td>#DollarFormat(request.qAlertDetail.FactoringFee)#</td>
                                        </cfif>
                                    </tr>
                                    <tr>
                                        <td align="right" style="font-weight: bold;">Due Date:</td>
                                        <td colspan="3"><input class="sm-input datefield" name="DueDate" id="DueDate" onchange="checkDateFormatAll(this);" value="#dateformat(request.qAlertDetail.DueDate,'mm/dd/yyyy')#" type="text" /></td>
                                    </tr>
                                    <cfif len(trim(request.qAlertDetail.ClaimedBy))>
                                        <tr>
                                            <td align="right" style="font-weight: bold;">Claimed By:</td>
                                            <td colspan="3">#request.qAlertDetail.ClaimedBy#</td>
                                        </tr>
                                    </cfif>
                                </tbody>
                            </table>
                            <div class="clear"></div>
                            <div style="text-align: right;padding-right: 10px;padding-bottom: 10px;">
                                <fieldset>
                                    <cfif variables.isLocked EQ 0>
                                        <input type="submit" name="claim" class="bttn" value="<cfif session.EmpID EQ request.qAlertDetail.ClaimedByUserID>Unclaim<cfelse>Claim</cfif>" style="width:70px !important;float: none;">
                                        <input type="button" onclick="javascript:history.back();" name="cancel" class="bttn" value="Cancel" style="width:70px !important;float: none;">
                                    </cfif>
                                </fieldset>
                            </div> 
                        </cfcase>
                        <cfcase value="Message">
                            <table width="100%">
                                <tbody>
                                    <tr>
                                        <td align="right" style="font-weight: bold;">Approved By:</td>
                                        <td>#request.qAlertDetail.CreatedUser#</td>
                                        <td align="right" style="font-weight: bold;">Approved On:</td>
                                        <td>#DateFormat(request.qAlertDetail.CreatedDateTime,"mm/dd/yyyy")#</td>
                                    </tr>
                                </tbody>
                            </table>
                            <div class="clear"></div>
                            <div style="text-align: right;padding-right: 10px;padding-bottom: 10px;">
                                <fieldset>
                                    <cfif variables.isLocked EQ 0>
                                        <input type="button" name="Acknowledge" class="bttn" value="Acknowledge" style="width:95px !important;float: none;"  onclick="AcknowledgeAlert('#request.qAlertDetail.AlertID#')">
                                        <input type="button" onclick="javascript:history.back();" name="cancel" class="bttn" value="Cancel" style="width:70px !important;float: none;">
                                    </cfif>
                                </fieldset>
                            </div> 
                        </cfcase>
                        <cfcase value="Carrier">
                            <table width="100%">
                                <tbody>
                                    <tr>
                                        <td align="right" style="font-weight: bold;">Created By:</td>
                                        <td>#request.qAlertDetail.CarrierName#</td>
                                        <td align="right" style="font-weight: bold;">Created On:</td>
                                        <td>#DateFormat(request.qAlertDetail.CreatedDateTime,"mm/dd/yyyy")#</td>
                                    </tr>
                                    <tr>
                                        <td align="right" style="font-weight: bold;">Due Date:</td>
                                        <td colspan="3"><input class="sm-input datefield" name="DueDate" id="DueDate" onchange="checkDateFormatAll(this);" value="#dateformat(request.qAlertDetail.DueDate,'mm/dd/yyyy')#" type="text" /></td>
                                    </tr>
                                    <cfif len(trim(request.qAlertDetail.ClaimedBy))>
                                        <tr>
                                            <td align="right" style="font-weight: bold;">Claimed By:</td>
                                            <td colspan="3">#request.qAlertDetail.ClaimedBy#</td>
                                        </tr>
                                    </cfif>
                                </tbody>
                            </table>
                            <div class="clear"></div>
                            <div style="text-align: right;padding-right: 10px;padding-bottom: 10px;">
                                <fieldset>
                                    <cfif variables.isLocked EQ 0>
                                        <input type="submit" name="claim" class="bttn" value="<cfif session.EmpID EQ request.qAlertDetail.ClaimedByUserID>Unclaim<cfelse>Claim</cfif>" style="width:70px !important;float: none;">
                                        <input type="button" onclick="javascript:history.back();" name="cancel" class="bttn" value="Cancel" style="width:70px !important;float: none;">
                                    </cfif>
                                </fieldset>
                            </div> 
                        </cfcase>
                        <cfdefaultcase></cfdefaultcase>
                    </cfswitch>
                </div>
            </div>
        </div>
    </cfform>  
</cfoutput>

    