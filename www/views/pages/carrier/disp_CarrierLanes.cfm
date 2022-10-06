<cfparam name="variables.Currency" default="">
<cfsilent>
    <cfinvoke component="#variables.objCarrierGateway#" method="getAllCarriers" returnvariable="request.qCarrier">
        <cfinvokeargument name="carrierid" value="#url.carrierid#">
    </cfinvoke>
    <cfinvoke component="#variables.objCarrierGateway#" method="getCarrierLanes" returnvariable="request.qLanes">
        <cfinvokeargument name="carrierid" value="#url.carrierid#">
    </cfinvoke>
    <cfinvoke component="#variables.objAgentGateway#" method="getAllStaes" returnvariable="request.qStates" />
    <cfinvoke component="#variables.objequipmentGateway#" method="getloadEquipments" returnvariable="request.qEquipments" />
    <cfinvoke component="#variables.objloadGateway#" method="getSystemSetupOptions" returnvariable="request.qSystemSetupOptions" />
    <cfif request.qsystemsetupoptions.ForeignCurrencyEnabled>
        <cfinvoke component="#variables.objloadGateway#" method="getCurrencies" IsActive="1" returnvariable="request.qGetCurrencies" />
        <cfloop query = "request.qGetCurrencies"> 
            <cfif request.qsystemsetupoptions.defaultSystemCurrency eq request.qGetCurrencies.CurrencyID>
                <cfset variables.Currency = CurrencyNameISO>
            </cfif>
        </cfloop>
    </cfif>
</cfsilent>
<cfoutput>
    <script type="text/javascript">
        function popitup(url) {
            newwindow=window.open(url,'Map','height=600,width=800');
            if (window.focus) {newwindow.focus()}
            return false;
        }
    </script>
    <cfset Secret = application.dsn>
    <cfset TheKey = 'NAMASKARAM'>
    <cfset Encrypted = Encrypt(Secret, TheKey)>
    <cfset dsn = URLEncodedFormat(ToBase64(Encrypted))>
    <style type="text/css">
        .normal-td{
            padding: 0;
        }
        .normal-td input{
            font-size: 11px;
        }
        .normal-td select{
            font-size: 11px;
        }
        .head-bg{
            height: 35px;
            background-size: contain;
        }
        .content-area{
            width: 1250px;
        }
        ##loader_cl{
            position: fixed;
            top:40%;
            left:40%;
            z-index: 999;
            display: none;
        }
        ##loadingmsg_cl{
            font-weight: bold;
            text-align: center;
            margin-top: 1px;
            background-color: ##fff;
        }
    </style>
    <script>
        $(document).ready(function(){
            initiateAutoComplete();

            $(document).on('change', '.CL-Field', function () {
                var row = $(this).closest("tr");

                var CarrierLaneID=$(row).attr('id').split('_')[1];
                var EquipmentID = $('##EquipmentID_'+CarrierLaneID).val();

                var PickUpCity = $('##PickUpCity_'+CarrierLaneID).val();
                var PickUpState = $('##PickUpState_'+CarrierLaneID).val();
                var PickUpZip = $('##PickUpZip_'+CarrierLaneID).val();
                var PickDate = $('##PickDate_'+CarrierLaneID).val();

                var DeliveryCity = $('##DeliveryCity_'+CarrierLaneID).val();
                var DeliveryState = $('##DeliveryState_'+CarrierLaneID).val();
                var DeliveryZip = $('##DeliveryZip_'+CarrierLaneID).val();
                var DeliveryDate = $('##DeliveryDate_'+CarrierLaneID).val();

                var Cost = $('##Cost_'+CarrierLaneID).val();
                var Miles = $('##Miles_'+CarrierLaneID).val();
                var RatePerMile = $('##RatePerMile_'+CarrierLaneID).val();
                var IntransitStops = $('##IntransitStops_'+CarrierLaneID).val();

                Cost = Cost.replace("$","");
                Cost = Cost.replace(/,/g,"");
                if(isNaN(Cost) || !Cost.length){
                    alert('Invalid Cost.');
                    $('##Cost_'+CarrierLaneID).focus();
                    return false;
                }
                if(isNaN(Miles) || !Miles.length){
                    alert('Invalid Miles.');
                    $('##Miles_'+CarrierLaneID).focus();
                    return false;
                }
                RatePerMile = RatePerMile.replace("$","");
                RatePerMile = RatePerMile.replace(/,/g,"");
                if(isNaN(RatePerMile) || !RatePerMile.length){
                    alert('Invalid RatePerMile.');
                    $('##RatePerMile_'+CarrierLaneID).focus();
                    return false;
                }
                if(isNaN(IntransitStops) || !IntransitStops.length){
                    alert('Invalid IntransitStops.');
                    $('##IntransitStops_'+CarrierLaneID).focus();
                    return false;
                }
                $.ajax({
                    type    : 'POST',
                    url     : "../gateways/carriergateway.cfc?method=setCarrierLanes",
                    data    : {
                                CarrierLaneID:CarrierLaneID,
                                EquipmentID:EquipmentID,
                                PickUpCity:PickUpCity,
                                PickUpState:PickUpState,
                                PickUpZip:PickUpZip,
                                PickDate:PickDate,
                                DeliveryCity:DeliveryCity,
                                DeliveryState:DeliveryState,
                                DeliveryZip:DeliveryZip,
                                DeliveryDate:DeliveryDate,
                                Cost:Cost,
                                Miles:Miles,
                                RatePerMile:RatePerMile,
                                IntransitStops:IntransitStops,
                                dsn:"#application.dsn#",
                                CreatedBy:'#session.adminusername#',
                                CarrierID:'#url.CarrierID#'
                            },
                    success :function(response){
                        var resData = jQuery.parseJSON(response);

                        if(resData.Success){
                            if(!CarrierLaneID.length){
                                var NewCarrierLaneID = resData.CarrierLaneID;
                                $(row).find("input,select").each(function(e){
                                    var name = $(this).attr("name");
                                    name = name.replace("_", "_"+NewCarrierLaneID);
                                    $(this).attr("name",name);
                                    $(this).attr("id",name);
                                })
                                $(row).find(".delRow").attr("name","delRow_"+NewCarrierLaneID);
                                $(row).find(".delRow").attr("id","delRow_"+NewCarrierLaneID);
                                $(row).attr("id","tr_"+NewCarrierLaneID);
                                $('##CreatedBy_'+NewCarrierLaneID).val('#session.adminusername#');
                                $('##CreatedDateTime_'+NewCarrierLaneID).val(resData.CreatedDateTime);
                                creatNewRow();
                            }
                        }
                        else{
                            alert(resData.Message)
                        }
                        $('.overlay').hide();
                        $('##loader_cl').hide();
                    },
                    beforeSend: function() {
                        $('.overlay').show();
                        $('##loader_cl').show();
                    },
                })
            })
        })
        function creatNewRow(){
            var row    = $('##lanes-list tr:last').clone();
            
            $(row).find("input,select").each(function(e){
                var name = $(this).attr("name").split('_')[0];
                $(this).attr("name",name+'_');
                $(this).attr("id",name+'_');
                $(this).val("");
            })
            $(row).find(".delRow").attr("name","delRow_");
            $(row).find(".delRow").attr("id","delRow_");
            $(row).attr("id","tr_");
            $('##lanes-list').append(row);
            $('##Cost_').val('$0.00');
            $('##Miles_').val('0');
            $('##RatePerMile_').val('$0.00');
            $('##IntransitStops_').val('0');
            initiateAutoComplete();
        }

        function initiateAutoComplete(){
            $('.cityAuto').each(function(i, tag) {
                $(tag).autocomplete({
                    multiple: false,
                    width: 400,
                    scroll: true,
                    scrollHeight: 300,
                    cacheLength: 1,
                    highlight: false,
                    dataType: "json",
                    autoFocus: true,
                    source: 'searchCustomersAutoFill.cfm?queryType=getCity&CompanyID=#session.CompanyID#',
                    select: function(e, ui) {
                        var id = this.id;
                        var type = id.split('City_')[0];
                        var clid = id.split('City_')[1];    

                        if($("##"+type+"State_"+clid).val() == ''){
                            if($("##"+type+"State_"+clid+" option[value='"+ui.item.state+"']").length){
                                $("##"+type+"State_"+clid).val(ui.item.state);
                            }
                        }
                        if($("##"+type+"Zip_"+clid).val() == ''){
                            $("##"+type+"Zip_"+clid).val(ui.item.zip);
                        }
                        $(this).val(ui.item.city);
                        return false;
                    }
                });
                $(tag).data("ui-autocomplete")._renderItem = function(ul, item) {
                    return $( "<li>"+item.city+"<br/><b><u>State</u>:</b> "+ item.state+"&nbsp;&nbsp;&nbsp;<b><u>Zip</u>:</b>" + item.zip+"</li>" )
                    .appendTo( ul );
                }
            })

            $('.zipAuto').each(function(i, tag) {
                $(tag).autocomplete({
                    multiple: false,
                    width: 400,
                    scroll: true,
                    scrollHeight: 300,
                    cacheLength: 1,
                    minLength: 1,
                    highlight: false,
                    dataType: "json",
                    autoFocus: true,
                    source: 'searchCustomersAutoFill.cfm?queryType=GetZip&CompanyID=#session.CompanyID#',
                    select: function(e, ui) {
                        var id = this.id;
                        var type = id.split('Zip_')[0];
                        var clid = id.split('Zip_')[1];  
                        if($("##"+type+"State_"+clid).val() == ''){
                            if($("##"+type+"State_"+clid+" option[value='"+ui.item.state+"']").length){
                                $("##"+type+"State_"+clid).val(ui.item.state);
                            }
                        }
                        if($("##"+type+"City_"+clid).val() == ''){
                            $("##"+type+"City_"+clid).val(ui.item.city);
                        }
                        $(this).val(ui.item.zip);
                        return false;
                    }
                });
                $(tag).data("ui-autocomplete")._renderItem = function(ul, item) {
                    return $( "<li>"+item.zip+"<br/><b><u>State</u>:</b> "+ item.state+"&nbsp;&nbsp;&nbsp;<b><u>City</u>:</b>" + item.city+"</li>" )
                            .appendTo( ul );
                }
            })
        }

        function delRow(row){
           var CarrierLaneID=$(row).attr('id').split('_')[1];
            if(CarrierLaneID.length){
                if (confirm("Are you sure you want to delete this row?")) {
                    $.ajax({
                        type    : 'POST',
                        url     : "../gateways/carriergateway.cfc?method=deleteCarrierLane",
                        data    : {CarrierLaneID:CarrierLaneID,dsn:"#application.dsn#"},
                        success :function(response){
                            var resData = jQuery.parseJSON(response);
                            if(resData.Success){
                                $('##tr_'+CarrierLaneID).remove();
                            }
                            else{
                                alert(resData.Message);
                            }
                            $('.overlay').hide();
                            $('##loader_cl').hide();
                        },
                        beforeSend: function() {
                            $('.overlay').show();
                            $('##loader_cl').show();
                        }
                    })
                }
            }
        }

        function calculateRPM(CarrierLaneID){
            var Cost = $('##Cost_'+CarrierLaneID).val();
            var Miles = $('##Miles_'+CarrierLaneID).val();
            var RatePerMile = 0;
            Cost = Cost.replace("$","");
            Cost = Cost.replace(/,/g,"");

            if(Miles!=0){
                RatePerMile = Cost/Miles;
            }
            $('##RatePerMile_'+CarrierLaneID).val(RatePerMile);
            formatDollarNegative(RatePerMile, 'RatePerMile_'+CarrierLaneID);
        }
    </script>
    <h1 style="float: left;"><span style="padding-left:160px;">#request.qCarrier.CarrierName#</span></h1>
    <div style="clear:both"></div>
    <cfif isdefined("url.CarrierID") and len(trim(url.CarrierID)) gt 1>
        <cfinclude template="carrierTabs.cfm">
    </cfif>
    <div style="clear:both"></div>
    <div class="white-con-area" style="height: 36px;background-color: ##82bbef;margin-top: 2px;width: 100%;">
         <div style="float: left; width: 20%;" id="divUploadedFiles">
            <img id="missingReqAtt" style="float: left;background-color: ##fff;border-radius: 11px;margin-top: 15px;margin-left: 2px;margin-right: 2px;display: none;width: 16px;" src="images/exclamation.ico" title="Required Attachments Missing">
            <cfinvoke component="#variables.objCarrierGateway#" method="getAttachedFiles" linkedid="#url.carrierid#" fileType="3" returnvariable="request.filesAttached" />
            <cfif request.filesAttached.recordcount neq 0>
                &nbsp;<a id="attachFile" style="display:block;font-size: 13px;padding-left: 2px;color:white;" href="##" onclick="popitup('../fileupload/multipleFileupload/MultipleUpload.cfm?id=#url.carrierid#&attachTo=3&user=#session.adminusername#&dsn=#dsn#&attachtype=Carrier&CompanyID=#session.CompanyID#')"><img style="vertical-align:bottom;" src="images/attachment.png">View/Attach Files</a>
            <cfelse>
                &nbsp;<a style="display:block;font-size: 13px;padding-left: 2px;color:white;" href="##" onclick="popitup('../fileupload/multipleFileupload/MultipleUpload.cfm?id=#url.carrierid#&attachTo=3&user=#session.adminusername#&dsn=#dsn#&attachtype=Carrier&CompanyID=#session.CompanyID#')"><img style="vertical-align:bottom;" src="images/attachment.png">Attach Files</a>

            </cfif>
        </div>
        <div style="float: left; width: 46%;margin-left: 150px;"><h2 style="color:white;font-weight:bold;">Active/Pending Insurance</h2></div>
    </div>
    
    <table width="100%" border="0" class="data-table" cellspacing="0" cellpadding="0">
        <thead>
            <tr>
                <th align="center" valign="middle" class="head-bg" style="border-left: 1px solid ##5d8cc9;border-top-left-radius: 5px;height: 20px;" width="5%">Load##</th>
                <th align="center" valign="middle" class="head-bg" width="9%">Pick City</th>
                <th align="center" valign="middle" class="head-bg" width="3%">Pick State</th>
                <th align="center" valign="middle" class="head-bg" width="5%">Pick Zip</th>
                <th align="center" valign="middle" class="head-bg" width="6%">Pick Date</th>
                <th align="center" valign="middle" class="head-bg" width="9%">Del City</th>
                <th align="center" valign="middle" class="head-bg" width="3%">Del State</th>
                <th align="center" valign="middle" class="head-bg" width="5%">Del Zip</th>
                <th align="center" valign="middle" class="head-bg" width="6%">Del Date</th>
                <th align="center" valign="middle" class="head-bg" width="13%">Equipment</th>
                <th align="center" valign="middle" class="head-bg" width="5%">Cost</th>
                <th align="center" valign="middle" class="head-bg" width="5%">Miles</th>
                <th align="center" valign="middle" class="head-bg" width="5%">RPM</th>
                <th align="center" valign="middle" class="head-bg" width="6%">Intransit Stops</th>
                <th align="center" valign="middle" class="head-bg" width="5%">Created By</th>
                <th align="center" valign="middle" class="head-bg" width="8%">Created</th>
                <th align="center" valign="middle" class="head-bg" style="border-top-right-radius: 5px;" width="2%"></th>
            </tr>
        </thead>
        <tbody id="lanes-list">
            <cfloop query="request.qLanes">
                <tr id="tr_#request.qLanes.CarrierLaneID#">
                    <td align="right" valign="middle" nowrap="nowrap" class="normal-td" style="border-left: 1px solid ##5d8cc9;">
                        <input type="hidden" value="#request.qLanes.CarrierLaneID#" id="CarrierLaneID_#request.qLanes.CarrierLaneID#" name="CarrierLaneID_#request.qLanes.CarrierLaneID#">
                        <input type="text" style="width: 95%;text-align: right;" value="#request.qLanes.LoadNumber#" id="LoadNumber_#request.qLanes.CarrierLaneID#" name="LoadNumber_#request.qLanes.CarrierLaneID#">
                    </td>
                    <td align="left" valign="middle" nowrap="nowrap" class="normal-td">
                        <input type="text" style="width: 100%;" value="#request.qLanes.PickUpCity#" id="PickUpCity_#request.qLanes.CarrierLaneID#" name="PickUpCity_#request.qLanes.CarrierLaneID#" class="CL-Field cityAuto" placeholder="Type Text">
                    </td>
                    <td  align="left" valign="middle" nowrap="nowrap" class="normal-td">
                        <select id="PickUpState_#request.qLanes.CarrierLaneID#" name="PickUpState_#request.qLanes.CarrierLaneID#" class="CL-Field" >
                            <option value="">Select</option>
                            <cfloop query="request.qStates">
                                <option value="#request.qStates.statecode#" <cfif request.qLanes.PickUpState EQ request.qStates.statecode> selected </cfif>>#request.qStates.statecode#</option>
                            </cfloop>
                        </select>
                    </td>
                    <td  align="left" valign="middle" nowrap="nowrap" class="normal-td">
                        <input type="text"  style="width: 95%;text-align: right;" value="#request.qLanes.PickUpZip#" id="PickUpZip_#request.qLanes.CarrierLaneID#" name="PickUpZip_#request.qLanes.CarrierLaneID#" placeholder="Type Text" class="CL-Field zipAuto">
                    </td>
                    <td  align="left" valign="middle" nowrap="nowrap" class="normal-td">
                        <input type="text" style="width: 95%;text-align: right;" value="#DateFormat(request.qLanes.PickDate,'mm/dd/yyyy')#" id="PickDate_#request.qLanes.CarrierLaneID#" name="PickDate_#request.qLanes.CarrierLaneID#" class="CL-Field datefield" onchange="checkDateFormatAll(this);">
                    </td>
                    <td  align="left" valign="middle" nowrap="nowrap" class="normal-td">
                        <input type="text" style="width: 100%;" value="#request.qLanes.DeliveryCity#" id="DeliveryCity_#request.qLanes.CarrierLaneID#" name="DeliveryCity_#request.qLanes.CarrierLaneID#" placeholder="Type Text" class="CL-Field cityAuto">
                    </td>
                    <td  align="left" valign="middle" nowrap="nowrap" class="normal-td">
                        <select id="DeliveryState_#request.qLanes.CarrierLaneID#" name="DeliveryState_#request.qLanes.CarrierLaneID#" class="CL-Field" >
                            <option value="">Select</option>
                            <cfloop query="request.qStates">
                                <option value="#request.qStates.statecode#" <cfif request.qLanes.DeliveryState EQ request.qStates.statecode> selected </cfif>>#request.qStates.statecode#</option>
                            </cfloop>
                        </select>
                    </td>
                    <td  align="left" valign="middle" nowrap="nowrap" class="normal-td">
                        <input type="text" style="width: 95%;text-align: right;" value="#request.qLanes.DeliveryZip#" id="DeliveryZip_#request.qLanes.CarrierLaneID#" name="DeliveryZip_#request.qLanes.CarrierLaneID#" placeholder="Type Text" class="CL-Field zipAuto">
                    </td>
                    <td  align="left" valign="middle" nowrap="nowrap" class="normal-td">
                        <input type="text" style="width: 95%;text-align: right;" value="#DateFormat(request.qLanes.DeliveryDate,'mm/dd/yyyy')#" id="DeliveryDate_#request.qLanes.CarrierLaneID#" name="DeliveryDate_#request.qLanes.CarrierLaneID#" class="CL-Field datefield" onchange="checkDateFormatAll(this);">
                    </td>
                    <td  align="left" valign="middle" nowrap="nowrap" class="normal-td">
                        <select  value="#request.qLanes.EquipmentID#" id="EquipmentID_#request.qLanes.CarrierLaneID#" name="EquipmentID_#request.qLanes.CarrierLaneID#" class="CL-Field">
                            <option value="">Select</option>
                            <cfloop query="request.qEquipments">
                                <option value="#request.qEquipments.equipmentID#" <cfif request.qEquipments.equipmentID EQ request.qLanes.EquipmentID> selected </cfif>>#request.qEquipments.equipmentname#</option>
                            </cfloop>
                        </select>
                    </td>
                    <td  align="left" valign="middle" nowrap="nowrap" class="normal-td">
                        <input type="text" style="width: 95%;text-align: right;" value="#DollarFormat(request.qLanes.Cost)#" id="Cost_#request.qLanes.CarrierLaneID#" name="Cost_#request.qLanes.CarrierLaneID#" class="CL-Field" onchange="calculateRPM('#request.qLanes.CarrierLaneID#')">
                    </td>
                    <td  align="left" valign="middle" nowrap="nowrap" class="normal-td">
                        <input type="text" style="width: 95%;text-align: right;" value="#request.qLanes.Miles#" id="Miles_#request.qLanes.CarrierLaneID#" name="Miles_#request.qLanes.CarrierLaneID#" class="CL-Field" onchange="calculateRPM('#request.qLanes.CarrierLaneID#')">
                    </td>
                    <td  align="left" valign="middle" nowrap="nowrap" class="normal-td">
                        <input type="text" style="width: 95%;text-align: right;" value="#DollarFormat(request.qLanes.RatePerMile)#" id="RatePerMile_#request.qLanes.CarrierLaneID#" name="RatePerMile_#request.qLanes.CarrierLaneID#" class="CL-Field">
                    </td>
                    <td  align="left" valign="middle" nowrap="nowrap" class="normal-td">
                        <input type="text" style="width: 95%;text-align: right;" value="#request.qLanes.IntransitStops#" id="IntransitStops_#request.qLanes.CarrierLaneID#" name="IntransitStops_#request.qLanes.CarrierLaneID#" class="CL-Field">
                    </td>
                    <td  align="left" valign="middle" nowrap="nowrap" class="normal-td">
                        <input type="text" style="width: 100%;" value="#request.qLanes.CreatedBy#" id="CreatedBy_#request.qLanes.CarrierLaneID#" name="CreatedBy_#request.qLanes.CarrierLaneID#" class="disabledLoadInputs" readonly>
                    </td>
                    <td  align="left" valign="middle" nowrap="nowrap" class="normal-td">
                        <input type="text" style="width: 95%;text-align: right;" value="#DateTimeFormat(request.qLanes.CreatedDateTime,'short')#" id="CreatedDateTime_#request.qLanes.CarrierLaneID#" name="CreatedDateTime_#request.qLanes.CarrierLaneID#" class="disabledLoadInputs" readonly>
                    </td>
                    <td  align="left" valign="middle" nowrap="nowrap" class="normal-td">
                        <img class="delRow" onclick="delRow(this)" name="delRow_#request.qLanes.CarrierLaneID#" id="delRow_#request.qLanes.CarrierLaneID#" src="images/delete-icon.gif" style="width:10px;margin-left: 5px;cursor: pointer;">
                    </td>
                </tr>
            </cfloop>
        </tbody>
        <tfoot>
            <tr>
                <td colspan="10" align="left" valign="middle" class="footer-bg" style="border-left: 1px solid ##5d8cc9;border-bottom-left-radius: 5px;">
                </td>
                <td align="right" valign="middle" class="footer-bg">
                    #variables.currency#
                </td>
                <td valign="middle" class="footer-bg">
                </td>
                <td align="right" valign="middle" class="footer-bg">
                    #variables.currency#
                </td>
                <td colspan="4" align="left" valign="middle" class="footer-bg" style="border-right: 1px solid ##5d8cc9;border-bottom-right-radius: 5px;">
                </td>
            </tr>  
        </tfoot>  
    </table>    
    <div class="overlay">
    </div>
    <div id="loader_cl">
        <img src="images/loadDelLoader.gif">
        <p id="loadingmsg_cl">Please wait.</p>
    </div>
</cfoutput>
    