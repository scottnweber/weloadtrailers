<cfsilent>
    <cfinvoke component="#variables.objCarrierGateway#" method="getAllCarriers" returnvariable="request.qCarrier">
        <cfinvokeargument name="carrierid" value="#url.carrierid#">
    </cfinvoke>
    <cfinvoke component="#variables.objloadGateway#" method="getSystemSetupOptions" returnvariable="request.qGetSystemSetupOptions" />

    <cfinvoke component="#variables.objCarrierGateway#" method="getActivePendingInsurance" CarrierID="#url.CarrierID#" DOTNumber="#request.qCarrier.DOTNumber#" returnvariable="request.qGetActivePendingInsurance">

    <cfinvoke component="#variables.objCarrierGateway#" method="getInsuranceHistory" CarrierID="#url.CarrierID#" DOTNumber="#request.qCarrier.DOTNumber#" returnvariable="request.qGetInsuranceHistory">
</cfsilent>



<cfset BasicISS = structNew()>
<cfset InsuranceHistory = structNew()>
<cfset BasicMeasuresByCargoGroup = structNew()>
<cfset Crashes = structNew()>
<cfif len(trim(request.qCarrier.DOTNumber)) and isNumeric(trim(request.qCarrier.DOTNumber))>

    <cftry>
        <cfhttp url="https://api.carriersoftware.com/api/BasicISS?dot=#request.qCarrier.DOTNumber#" method="get"  throwonerror = Yes result="objBasicISS">
            <cfhttpparam type="header" name="API_KEY" value="#request.qGetSystemSetupOptions.CarrierLookoutAPIKey#"/>
        </cfhttp>
        <cfcatch>
            <cfset objBasicISS = structNew()>
            <cfset objBasicISS.Statuscode = 500>
        </cfcatch>
    </cftry>

    <cftry>
        <cfhttp url="https://api.carriersoftware.com/api/BasicMeasuresByCargoGroup?dot=#request.qCarrier.DOTNumber#" method="get"  throwonerror = Yes result="objBasicMeasuresByCargoGroup">
            <cfhttpparam type="header" name="API_KEY" value="#request.qGetSystemSetupOptions.CarrierLookoutAPIKey#"/>
        </cfhttp>
    <cfcatch>
        <cfset objBasicMeasuresByCargoGroup = structNew()>
        <cfset objBasicMeasuresByCargoGroup.Statuscode = 500>
    </cfcatch>
    </cftry>
    <cftry>
        <cfhttp url="https://api.carriersoftware.com/api/Crashes?dot=#request.qCarrier.DOTNumber#" method="get"  throwonerror = Yes result="objCrashes">
            <cfhttpparam type="header" name="API_KEY" value="#request.qGetSystemSetupOptions.CarrierLookoutAPIKey#"/>
        </cfhttp>
        <cfcatch>
            <cfset objCrashes = structNew()>
            <cfset objCrashes.Statuscode = 500>
        </cfcatch>
    </cftry>
    <cfif objBasicISS.Statuscode EQ '200 OK'>
        <cfset BasicISS = DeserializeJSON(objBasicISS.Filecontent)>
        <cfif BasicISS.Total NEQ 0 AND NOT arrayIsEmpty(BasicISS.results)>
            <cfset BasicISS = BasicISS.results[BasicISS.Total]>
        <cfelse>
            <cfset BasicISS = structNew()>
        </cfif>
    </cfif>

    <cfif objBasicMeasuresByCargoGroup.Statuscode EQ '200 OK'>
        <cfset BasicMeasuresByCargoGroup = DeserializeJSON(objBasicMeasuresByCargoGroup.Filecontent)>
    </cfif>

    <cfif objCrashes.Statuscode EQ '200 OK'>
        <cfset Crashes = DeserializeJSON(objCrashes.Filecontent)>
    </cfif>

</cfif>


<cfoutput>
    <style type="text/css">
        ##crashSummary-wrapper{
            height: 400px !important;
        }
        ##crashSummary{
            overflow: auto !important;
        }
        .msg-area-success{
            border: 1px solid ##a4da46;
            padding: 5px 15px;
            font-weight: normal;
            width: 85%;
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
            width: 85%;
            float: left;
            margin-top: 5px;
            margin-bottom:  5px;
            background-color: ##e4b9c6;
            font-weight: bold;
            font-style: italic;
        }
        ##ActiveInsuranceList td{
            padding: 0;
        }
        .normal-td input {
            font-size: 11px;
        }
        .normal-td select {
            font-size: 11px;
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
        .ui-datepicker-trigger {
            right: 0px;
            margin-left: -15px;
            top:0;
            height: 12px;
        }
        .head-bg,.head-bg2{
            background-size: contain;
        }
    </style>
    <script>

        $(document).ready(function(){

            $('.DatePicker').datepicker({
                dateFormat: "mm/dd/yy",
                showOn: "button",
                buttonImage: "images/DateChooser.png",
                buttonImageOnly: true,
                showButtonPanel: true,
            });
            $('.DatePicker').datepicker( "option", "showButtonPanel", true );
                var old_goToToday = $.datepicker._gotoToday
                $.datepicker._gotoToday = function(id) {
                old_goToToday.call(this,id)
                this._selectDate(id)
            }

            $( ".AlertStatus td" ).each(function( index ) {
                if($.trim($( this ).text())=='ALERT'){
                    $(this).css('background-color','##f0614e');
                }
                else if($.trim($( this ).text())=='No'){
                    $(this).css('background-color','##38c69f');
                }
            });

            $( ".CompToAvg" ).each(function( index ) {
                if($.trim($( this ).text())=='Worse'){
                    $(this).css('background-color','##f0614e');
                }
                else if($.trim($( this ).text())=='Better'){
                    $(this).css('background-color','##38c69f');
                }
                else{
                    $(this).css('background-color','##FFFFFF');
                }
            });

            $(document).on('change', '.Ins-Field', function () {
                var row = $(this).closest("tr");
                var ID=$(row).attr('id').split('_')[1];
                var FieldName = $(this).attr('id').split('_')[0];
                var FieldVal = $(this).val();
                var BIPDClass = "";
                var InsType = "";
                if(FieldName == 'Type'){
                    var TypeText = $(this).find("option:selected").text();
                    if(TypeText=='BIPD/Primary'){
                        var BIPDClass = "P";
                    }
                    else if(TypeText=='BIPD/Excess'){
                        var BIPDClass = "E";
                    }

                    $('##td_Req_'+ID).html('<input type="text" name="Req_'+ID+'" id="Req_'+ID+'" value="$0.00" style="width: 95%;" class="Ins-Field">');
                    $('##td_OnFile_'+ID).html('<input type="text" name="OnFile_'+ID+'" id="OnFile_'+ID+'" value="$0.00" style="width: 95%;" class="Ins-Field">');
                }

                if(FieldName == 'CoveredTo'){
                    var CovTo = $(this).val();
                    CovTo = CovTo.replace("$","");
                    CovTo = CovTo.replace(/,/g,"");
                    if(isNaN(CovTo) || !CovTo.length){
                        alert('Invalid Amount.');
                        $(this).val('$0.00');
                        $(this).focus();
                        return false;
                    }
                }

                if(FieldName == 'Req'){
                    var Type = $('##Type_'+ID).val();
                    if(Type==1){
                        var Req = $(this).val();
                        Req = Req.replace("$","");
                        Req = Req.replace(/,/g,"");
                        if(isNaN(Req) || !Req.length){
                            alert('Invalid Amount.');
                            $(this).val('$0.00');
                            $(this).focus();
                            return false;
                        }
                    }
                }

                if(FieldName == 'OnFile'){
                    var Type = $('##Type_'+ID).val();
                    if(Type==1){
                        var OnFile = $(this).val();
                        OnFile = OnFile.replace("$","");
                        OnFile = OnFile.replace(/,/g,"");
                        if(isNaN(OnFile) || !OnFile.length){
                            alert('Invalid Amount.');
                            $(this).val('$0.00');
                            $(this).focus();
                            return false;
                        }
                    }
                }

                if(FieldName == 'EffectiveDate' || FieldName == 'ExpirationDate' || FieldName == 'CancelDate'){
                    var DateVal = $(this).val();
                    var reg =/((^(10|12|0?[13578])([/])(3[01]|[12][0-9]|0?[1-9])([/])((1[8-9]\d{2})|([2-9]\d{3}))$)|(^(11|0?[469])([/])(30|[12][0-9]|0?[1-9])([/])((1[8-9]\d{2})|([2-9]\d{3}))$)|(^(0?2)([/])(2[0-8]|1[0-9]|0?[1-9])([/])((1[8-9]\d{2})|([2-9]\d{3}))$)|(^(0?2)([/])(29)([/])([2468][048]00)$)|(^(0?2)([/])(29)([/])([3579][26]00)$)|(^(0?2)([/])(29)([/])([1][89][0][48])$)|(^(0?2)([/])(29)([/])([2-9][0-9][0][48])$)|(^(0?2)([/])(29)([/])([1][89][2468][048])$)|(^(0?2)([/])(29)([/])([2-9][0-9][2468][048])$)|(^(0?2)([/])(29)([/])([1][89][13579][26])$)|(^(0?2)([/])(29)([/])([2-9][0-9][13579][26])$))/;
                    if(DateVal.length && !DateVal.match(reg)){
                        alert('Invalid Date.');
                        $(this).val('');
                        $(this).focus();
                        return false;
                    }
                }
                InsType = $('##Type_'+ID).val();
                $.ajax({
                    type    : 'POST',
                    url     : "../gateways/carriergateway.cfc?method=SetCarrierInsurance",
                    data    : {
                                ID:ID,
                                FieldName:FieldName,
                                dsn:"#application.dsn#",
                                CreatedBy:'#session.adminusername#',
                                CarrierID:'#url.CarrierID#',
                                FieldVal:FieldVal,
                                BIPDClass:BIPDClass,
                                InsType:InsType
                            },
                    success :function(response){
                        var resData = jQuery.parseJSON(response);

                        if(resData.Success){
                            if(!ID.length){
                                var NewID = resData.ID;

                                $(".DatePicker").datepicker("destroy");

                                $(row).find("input,select").each(function(e){
                                    var name = $(this).attr("name");
                                    name = name.replace("_", "_"+NewID);
                                    $(this).attr("name",name);
                                    $(this).attr("id",name);
                                })

                                $(row).find(".delRow").attr("name","delRow_"+NewID);
                                $(row).find(".delRow").attr("id","delRow_"+NewID);
                                $(row).attr("id","tr_"+NewID);
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
            });

        })

        function creatNewRow(){
            var row  = $('##ActiveInsuranceList tr:last').clone();

            $(row).find("input,select").each(function(e){
                var name = $(this).attr("name").split('_')[0];
                $(this).attr("name",name+'_');
                $(this).attr("id",name+'_');
                $(this).val("");
            })

            $(row).find(".delRow").attr("name","delRow_");
            $(row).find(".delRow").attr("id","delRow_");
            $(row).attr("id","tr_");
            $('##ActiveInsuranceList').append(row);

            $('.DatePicker').datepicker({
                dateFormat: "mm/dd/yy",
                showOn: "button",
                buttonImage: "images/DateChooser.png",
                buttonImageOnly: true,
                showButtonPanel: true,
            });
            $('.DatePicker').datepicker( "option", "showButtonPanel", true );
                var old_goToToday = $.datepicker._gotoToday
                $.datepicker._gotoToday = function(id) {
                old_goToToday.call(this,id)
                this._selectDate(id)
            }

        }

        function delRow(row){
            var ID=$(row).attr('id').split('_')[1];
            if(ID.length){
                if (confirm("Are you sure you want to delete this row?")) {
                    $.ajax({
                        type    : 'POST',
                        url     : "../gateways/carriergateway.cfc?method=DeleteCarrierInsurance",
                        data    : {ID:ID,dsn:"#application.dsn#"},
                        success :function(response){
                            var resData = jQuery.parseJSON(response);
                            if(resData.Success){
                                $('##tr_'+ID).remove();
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
    </script>
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
    <cfif structKeyExists(session, "CLresponse") and len(session.CLresponse)>
        <div id="message" class="msg-area-#session.CLresponse#"><cfif session.CLresponse EQ "error">Something went wrong. Unable to update via Carrier Lookout. Please try again later.<cfelse>Updated via Carrier Lookout successfully.</cfif></div>
        <cfset structdelete(session, 'CLresponse', true)/> 
    </cfif>
    <div style="clear:both"></div>
    <cfif structKeyExists(session, "CLInsuranceResponse")>
        <div id="message" class="msg-area-#session.CLInsuranceResponse.res#">#session.CLInsuranceResponse.msg#</div>
        <cfset structdelete(session, 'CLInsuranceResponse', true)/> 
    </cfif>
    <div style="clear:both"></div>
    <h1 style="float: left;"><span style="padding-left:160px;">#request.qCarrier.CarrierName#</span></h1>
    <div style="clear:both"></div>
    <cfif isdefined("url.CarrierID") and len(trim(url.CarrierID)) gt 1>
        <cfinclude template="carrierTabs.cfm">
    </cfif>
    <cfset risk_assessment = request.qCarrier.riskassessment>
    <cfif risk_assessment EQ "Unacceptable">
        &nbsp;<img style="vertical-align:middle;width: 15px;" src="images/CL-Red.png">
    <cfelseif risk_assessment EQ "Moderate">
        &nbsp;<img style="vertical-align:middle;width: 15px;" src="images/CL-Yellow.png">
    <cfelseif risk_assessment EQ "Acceptable">
        &nbsp;<img style="vertical-align:middle;width: 15px;" src="images/CL-Green.png">
    </cfif>
    <input name="Update" id="update_btn" type="button" class="normal-bttn"  onclick="return getCarrierLookoutConfirmation();" value="Update Via Carrier Lookout" style="width:180px !important;" />
   <input type="hidden" id="editid" name="editid" value="#url.carrierid#">
   <input type="hidden" value="#session.urltoken#" name="stoken" id="stoken">
   <input type="hidden" id="DOTNumber" name="DOTNumber" value="#request.qCarrier.DOTNumber#">
   <input type="hidden" id="Redirect_To" name="Redirect_To" value="CarrierLookup">
   <div style="clear:both"></div>

   <div class="white-con-area" style="height: 36px;background-color: ##82bbef;width:999px;">
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
    <table width="100%" border="0" class="data-table" cellspacing="0" cellpadding="0" style="color:##000000;">
        <thead>
            <tr>
                <th  align="center" valign="middle" class="head-bg" style="border-left: 1px solid ##5d8cc9;border-top-left-radius: 5px;" width="8%">Docket No.</th>
                <th align="center" valign="middle" class="head-bg" width="4%">Form</th>
                <th align="center" valign="middle" class="head-bg" width="8%">Type</th>
                <th align="center" valign="middle" class="head-bg" width="22%">Insurance Carrier</th>
                <th align="center" valign="middle" class="head-bg" width="8%">Policy/Surety</th>
                <th align="center" valign="middle" class="head-bg" width="8%">Cov. To</th>
                <th align="center" valign="middle" class="head-bg" width="8%">Req.</th>
                <th align="center" valign="middle" class="head-bg" width="8%">On File</th>
                <th align="center" valign="middle" class="head-bg" width="8%">Effective Date</th>
                <th align="center" valign="middle" class="head-bg" width="8%">Expiration Date</th>
                <th align="center" valign="middle" class="head-bg" width="8%">Cancel Date</th>
                <th align="center" valign="middle" class="head-bg2" style="border-right: 1px solid ##5d8cc9;"  width="2%"></th>
            </tr>
        </thead>
        <tbody id="ActiveInsuranceList">
            <cfloop query="request.qGetActivePendingInsurance">
                <tr id="tr_#request.qGetActivePendingInsurance.ID#">
                    <td align="left" valign="middle" nowrap="nowrap" class="normal-td" style="border-left: 1px solid ##5d8cc9;">
                        <input type="text" name="DocketNo_#request.qGetActivePendingInsurance.ID#" id="DocketNo_#request.qGetActivePendingInsurance.ID#" value="#request.qGetActivePendingInsurance.DocketNo#" style="width: 95%;" class="Ins-Field">
                    </td>
                    <td  align="left" valign="middle" nowrap="nowrap" class="normal-td">
                        <input type="text" name="Form_#request.qGetActivePendingInsurance.ID#" id="Form_#request.qGetActivePendingInsurance.ID#" value="#request.qGetActivePendingInsurance.Form#" style="width: 90%;" class="Ins-Field">
                    </td>
                    <td  align="left" valign="middle" nowrap="nowrap" class="normal-td">
                        <select name="Type_#request.qGetActivePendingInsurance.ID#" id="Type_#request.qGetActivePendingInsurance.ID#"  style="width: 100%;" class="Ins-Field">
                            <option value="">Select</option>
                            <option value="1" <cfif request.qGetActivePendingInsurance.Type EQ 1> selected </cfif>>BIPD</option>
                            <option value="1" <cfif request.qGetActivePendingInsurance.Type EQ 1 AND request.qGetActivePendingInsurance.BiPdClass EQ 'P'> selected </cfif>>BIPD/Primary</option>
                            <option value="1" <cfif request.qGetActivePendingInsurance.Type EQ 1 AND request.qGetActivePendingInsurance.BiPdClass EQ 'E'> selected </cfif>>BIPD/Excess</option>
                            <option value="2" <cfif request.qGetActivePendingInsurance.Type EQ 2> selected </cfif>>CARGO</option>
                            <option value="3" <cfif request.qGetActivePendingInsurance.Type EQ 3> selected </cfif>>SURETY</option>
                            <option value="4" <cfif request.qGetActivePendingInsurance.Type EQ 4> selected </cfif>>TRUST FUND</option>
                            <option value="5" <cfif request.qGetActivePendingInsurance.Type EQ 5> selected </cfif>>OTHER</option>
                        </select>
                    </td>
                    <td  align="left" valign="middle" nowrap="nowrap" class="normal-td">
                        <input type="text" name="InsuranceCarrier_#request.qGetActivePendingInsurance.ID#" id="InsuranceCarrier_#request.qGetActivePendingInsurance.ID#" value="#request.qGetActivePendingInsurance.InsuranceCarrier#"  style="width: 98%;"  class="Ins-Field">
                    </td>
                    <td  align="left" valign="middle" nowrap="nowrap" class="normal-td">
                        <input type="text" name="PolicyNo_#request.qGetActivePendingInsurance.ID#" id="PolicyNo_#request.qGetActivePendingInsurance.ID#" value="#request.qGetActivePendingInsurance.PolicyNo#"  style="width: 94%;" class="Ins-Field">
                    </td>
                    <td  align="right" valign="middle" nowrap="nowrap" class="normal-td">
                        <input type="text" name="CoveredTo_#request.qGetActivePendingInsurance.ID#" id="CoveredTo_#request.qGetActivePendingInsurance.ID#" value="#request.qGetActivePendingInsurance.CoveredTo#" style="width: 95%;text-align: right;" class="Ins-Field">
                    </td>
                    <td  align="right" valign="middle" nowrap="nowrap" class="normal-td" id="td_Req_#request.qGetActivePendingInsurance.ID#">
                        <input type="text" name="Req_#request.qGetActivePendingInsurance.ID#" id="Req_#request.qGetActivePendingInsurance.ID#" value="#request.qGetActivePendingInsurance.Req#"  style="width: 95%;text-align: right;" class="Ins-Field">
                    </td>
                    <td  align="right" valign="middle" nowrap="nowrap" class="normal-td" id="td_OnFile_#request.qGetActivePendingInsurance.ID#">
                        <input type="text" name="OnFile_#request.qGetActivePendingInsurance.ID#" id="OnFile_#request.qGetActivePendingInsurance.ID#" value="#request.qGetActivePendingInsurance.OnFile#"  style="width: 95%;text-align: right;" class="Ins-Field">
                    </td>
                    <td  align="left" valign="middle" nowrap="nowrap" class="normal-td">
                        <input type="text" name="EffectiveDate_#request.qGetActivePendingInsurance.ID#" id="EffectiveDate_#request.qGetActivePendingInsurance.ID#" value="#DateFormat(request.qGetActivePendingInsurance.EffectiveDate,"mm/dd/yyyy")#" style="width: 95%;" class="Ins-Field DatePicker"  placeholder="mm/dd/yyyy">
                    </td>
                    <td  align="left" valign="middle" nowrap="nowrap" class="normal-td">
                        <input type="text" name="ExpirationDate_#request.qGetActivePendingInsurance.ID#" id="ExpirationDate_#request.qGetActivePendingInsurance.ID#" value="#DateFormat(request.qGetActivePendingInsurance.ExpirationDate,"mm/dd/yyyy")#" style="width: 96%;" class="Ins-Field DatePicker"  placeholder="mm/dd/yyyy">
                    </td>
                    <td align="center" valign="middle" nowrap="nowrap" class="normal-td">
                        <input type="text" name="CancelDate_#request.qGetActivePendingInsurance.ID#" id="CancelDate_#request.qGetActivePendingInsurance.ID#" value="#DateFormat(request.qGetActivePendingInsurance.CancelDate,"mm/dd/yyyy")#"  style="width: 94%;" class="Ins-Field DatePicker" placeholder="mm/dd/yyyy">
                    </td>
                    <td style="border-right: 1px solid ##5d8cc9;" align="left" valign="middle" nowrap="nowrap" class="normal-td2">
                        <img class="delRow" onclick="delRow(this)" name="delRow_#request.qGetActivePendingInsurance.ID#" id="delRow_#request.qGetActivePendingInsurance.ID#" src="images/delete-icon.gif" style="width:10px;margin-left: 5px;cursor: pointer;">
                    </td>
                </tr>
            </cfloop> 
        </tbody>
        <tfoot>
            <tr>
                <td colspan="12" align="left" valign="middle" class="footer-bg" style="border-left: 1px solid ##5d8cc9;border-right: 1px solid ##5d8cc9;border-bottom-left-radius: 5px;;border-bottom-right-radius: 5px;">
                </td>
            </tr>   
        </tfoot>
    </table>

    <div style="clear:both"></div>
    <div class="white-con-area" style="height: 36px;background-color: ##82bbef;margin-top: 5px;width: 100%;">
        <h2 style="color:white;font-weight:bold;text-align: center;">Insurance History</h2>
    </div>
    <table width="100%" border="0" class="data-table" cellspacing="0" cellpadding="0" style="color:##000000;">
        <thead>
            <tr>
                <th  align="center" valign="middle" class="head-bg" style="border-left: 1px solid ##5d8cc9;border-top-left-radius: 5px;">Docket No.</th>
                <th align="center" valign="middle" class="head-bg">Form</th>
                <th align="center" valign="middle" class="head-bg">Type</th>
                <th align="center" valign="middle" class="head-bg">Insurance Carrier</th>
                <th align="center" valign="middle" class="head-bg">Policy/Surety</th>
                <th align="center" valign="middle" class="head-bg">Coverage To</th>
                <th align="center" valign="middle" class="head-bg">Effective Date From</th>
                <th align="center" valign="middle" class="head-bg2" style="border-right: 1px solid ##5d8cc9;">Effective Date To</th>
            </tr>
        </thead>
        <cfif request.qGetInsuranceHistory.recordcount>
            <cfloop query="request.qGetInsuranceHistory">

                <tr <cfif request.qGetInsuranceHistory.currentrow mod 2 eq 0>bgcolor="##FFFFFF"<cfelse>bgcolor="##f7f7f7"</cfif>>
                    <td align="left" valign="middle" nowrap="nowrap" class="normal-td" style="border-left: 1px solid ##5d8cc9;">#request.qGetInsuranceHistory.DocketNo#</td>
                    <td  align="left" valign="middle" nowrap="nowrap" class="normal-td">#request.qGetInsuranceHistory.Form#</td>
                    <td  align="left" valign="middle" nowrap="nowrap" class="normal-td">
                        #request.qGetInsuranceHistory.Type#
                    </td>
                    <td  align="left" valign="middle" nowrap="nowrap" class="normal-td">#request.qGetInsuranceHistory.InsuranceCarrier#</td>
                    <td  align="left" valign="middle" nowrap="nowrap" class="normal-td">#request.qGetInsuranceHistory.PolicyNo#</td>
                    <td  align="right" valign="middle" nowrap="nowrap" class="normal-td">#DollarFormat(request.qGetInsuranceHistory.CoveredTo*1000)#</td>
                    <td  align="left" valign="middle" nowrap="nowrap" class="normal-td">#DateFormat(request.qGetInsuranceHistory.EffectiveDateFrom,"mm/dd/yyyy")#</td>
                    <td style="border-right: 1px solid ##5d8cc9;" align="center" valign="middle" nowrap="nowrap" class="normal-td2">
                        <cfif len(trim(request.qGetInsuranceHistory.EffectiveDateTo))>
                            #DateFormat(request.qGetInsuranceHistory.EffectiveDateTo,"mm/dd/yyyy")#
                        <cfelse>
                            <cfif len(trim(request.qGetInsuranceHistory.EffectiveDateFrom))>
                                #DateFormat(dateAdd("yyyy", 1, request.qGetInsuranceHistory.EffectiveDateFrom),"mm/dd/yyyy")#
                            </cfif>
                        </cfif>
                        <br>#request.qGetInsuranceHistory.EndAction#</td>
                </tr>
            </cfloop>
        <cfelse>
            <tr>
                <tr><td  colspan="8" align="center" style="border-left: 1px solid ##5d8cc9;border-right: 1px solid ##5d8cc9;">No Records Found.</td></tr>
            </tr>
        </cfif>
        <tfoot>
            <tr>
                <td colspan="8" align="left" valign="middle" class="footer-bg" style="border-left: 1px solid ##5d8cc9;border-right: 1px solid ##5d8cc9;border-bottom-left-radius: 5px;;border-bottom-right-radius: 5px;">
                </td>
            </tr>   
        </tfoot>
    </table>
    <div style="clear:both"></div>
    <div class="white-con-area" style="height: 36px;background-color: ##82bbef;margin-top: 5px;width: 100%;">
        <h2 style="color:white;font-weight:bold;text-align: center;">Estimated BASIC Scores</h2>
    </div>
    <table width="100%" border="0" class="data-table" cellspacing="0" cellpadding="0" style="color:##000000;">
        <thead>
            <tr>
                <th  align="center" valign="middle" class="head-bg" style="border-left: 1px solid ##5d8cc9;border-top-left-radius: 5px;">&nbsp;</th>
                <th align="center" valign="middle" class="head-bg">Unsafe Driving</th>
                <th align="center" valign="middle" class="head-bg">Hours of Service</th>
                <th align="center" valign="middle" class="head-bg">Driver Fitness</th>
                <th align="center" valign="middle" class="head-bg">Controlled Sub./Alcohol</th>
                <th align="center" valign="middle" class="head-bg">Vehicle Maintaenance</th>
                <th align="center" valign="middle" class="head-bg2" style="border-right: 1px solid ##5d8cc9;">Crash</th>
            </tr>
        </thead>
         <cfif NOT StructIsEmpty(BasicISS)>
            <tr>
                <td align="left" valign="middle" nowrap="nowrap" class="normal-td" style="border-left: 1px solid ##5d8cc9;"><b>Relative Scores</b></td>
                <td align="center" valign="middle" nowrap="nowrap" class="normal-td">
                    <cfif isDefined('BasicISS.UnsafeDrivPct')>#BasicISS.UnsafeDrivPct#<cfelse>0</cfif>%
                </td>
                <td align="center" valign="middle" nowrap="nowrap" class="normal-td">
                    <cfif isDefined('BasicISS.HOSPct')>#BasicISS.HOSPct#<cfelse>0</cfif>%
                </td>
                <td align="center" valign="middle" nowrap="nowrap" class="normal-td">
                    <cfif isDefined('BasicISS.DriverFitnessPercentile')>#BasicISS.DriverFitnessPercentile#<cfelse>0</cfif>%
                </td>
                <td align="center" valign="middle" nowrap="nowrap" class="normal-td">
                    <cfif isDefined('BasicISS.ControlledSubPercentile')>#BasicISS.ControlledSubPercentile#<cfelse>0</cfif>%
                </td>
                <td align="center" valign="middle" nowrap="nowrap" class="normal-td">
                    <cfif isDefined('BasicISS.VehMaintPct')>#BasicISS.VehMaintPct#<cfelse>0</cfif>%
                </td>
                <td align="center" valign="middle" nowrap="nowrap" class="normal-td">
                     <cfif isDefined('BasicISS.CrashPct')>#BasicISS.CrashPct#<cfelse>0</cfif>%
                </td>
            </tr>
            <tr class="AlertStatus">
                <td align="left" valign="middle" nowrap="nowrap" class="normal-td" style="border-left: 1px solid ##5d8cc9;"><b>Alert Status</b></td>
                <td align="center" valign="middle" nowrap="nowrap" class="normal-td">
                    <cfif BasicISS.UnsafeDriveBasicAlert EQ 'Y'>
                        ALERT
                    <cfelse>
                        No
                    </cfif>
                </td>
                <td align="center" valign="middle" nowrap="nowrap" class="normal-td">
                    <cfif BasicISS.HOSBasicAlert EQ 'Y'>
                        ALERT
                    <cfelse>
                        No
                    </cfif>
                </td>
                <td align="center" valign="middle" nowrap="nowrap" class="normal-td">
                    <cfif BasicISS.DrivFitBasicAlert EQ 'Y'>
                        ALERT
                    <cfelse>
                        No
                    </cfif>
                </td>
                <td align="center" valign="middle" nowrap="nowrap" class="normal-td">
                    <cfif BasicISS.ContrSubstBasicAlert EQ 'Y'>
                        ALERT
                    <cfelse>
                        No
                    </cfif>
                </td>
                <td align="center" valign="middle" nowrap="nowrap" class="normal-td">
                    <cfif BasicISS.VehMaintBasicAlert EQ 'Y'>
                        ALERT
                    <cfelse>
                        No
                    </cfif>
                </td>
                <td align="center" valign="middle" nowrap="nowrap" class="normal-td">
                    <cfif BasicISS.CrashBasicAlert EQ 'Y'>
                        ALERT
                    <cfelse>
                        No
                    </cfif>
                </td>
            </tr>
        <cfelse>
            <tr>
                <tr><td  colspan="7" align="center" style="border-left: 1px solid ##5d8cc9;border-right: 1px solid ##5d8cc9;">No Records Found.</td></tr>
            </tr>
        </cfif>
        <tfoot>
            <tr>
                <td colspan="7" align="left" valign="middle" class="footer-bg" style="border-left: 1px solid ##5d8cc9;border-right: 1px solid ##5d8cc9;border-bottom-left-radius: 5px;;border-bottom-right-radius: 5px;">
                </td>
            </tr>   
        </tfoot>
    </table>
    <div style="clear:both"></div>
    <div class="white-con-area" style="height: 36px;background-color: ##82bbef;margin-top: 5px;width: 100%;">
        <h2 style="color:white;font-weight:bold;text-align: center;">BASIC Measures By Cargo Group</h2>
    </div>
    <table width="100%" border="0" class="data-table" cellspacing="0" cellpadding="0">
        <thead>
            <cfif not structIsEmpty(BasicMeasuresByCargoGroup)>
                <tr>
                    <th colspan="11" align="left" valign="middle" class="head-bg" style="border-left: 1px solid ##5d8cc9;border-top-left-radius: 5px;border-right: 1px solid ##5d8cc9;padding-left: 5px;">Fleet Size: <cfif isdefined('BasicMeasuresByCargoGroup.Fleetsize')>#BasicMeasuresByCargoGroup.Fleetsize# PUs<cfelse>N/A</cfif></th>
                </tr>
            </cfif>
            <tr>
                <th align="center" valign="middle" class="head-bg" style="border-left: 1px solid ##5d8cc9;border-top-left-radius: 5px;">&nbsp;</th>
                <th colspan="2" align="center" valign="middle" class="head-bg">Unsafe Driving</th>
                <th colspan="2" align="center" valign="middle" class="head-bg">Hours of Service</th>
                <th colspan="2" align="center" valign="middle" class="head-bg">Driver Fitness</th>
                <th colspan="2" align="center" valign="middle" class="head-bg">Controlled Substance</th>
                <th colspan="2" align="center" valign="middle" class="head-bg2" style="border-right: 1px solid ##5d8cc9;">Vehicle Maintaenance</th>
            </tr>
        </thead>
        <cfif not structIsEmpty(BasicMeasuresByCargoGroup) and  isdefined("BasicMeasuresByCargoGroup.BasicMeasuresByCargoGroupList") and not arrayIsEmpty(BasicMeasuresByCargoGroup.BasicMeasuresByCargoGroupList)>
            <tr>
                <td align="center" valign="middle" nowrap="nowrap" class="normal-td" style="border-left: 1px solid ##5d8cc9;"><b>Cargo Group (Companies)</b></td>
                <td align="center" valign="middle" nowrap="nowrap" class="normal-td"><b>Avg.</b></td>
                <td align="center" valign="middle" nowrap="nowrap" class="normal-td"><b>Comp.<br>to Avg.</b></td>
                <td align="center" valign="middle" nowrap="nowrap" class="normal-td"><b>Avg.</b></td>
                <td align="center" valign="middle" nowrap="nowrap" class="normal-td"><b>Comp.<br>to Avg.</b></td>
                <td align="center" valign="middle" nowrap="nowrap" class="normal-td"><b>Avg.</b></td>
                <td align="center" valign="middle" nowrap="nowrap" class="normal-td"><b>Comp.<br>to Avg.</b></td>
                <td align="center" valign="middle" nowrap="nowrap" class="normal-td"><b>Avg.</b></td>
                <td align="center" valign="middle" nowrap="nowrap" class="normal-td"><b>Comp.<br>to Avg.</b></td>
                <td align="center" valign="middle" nowrap="nowrap" class="normal-td"><b>Avg.</b></td>
                <td align="center" valign="middle" nowrap="nowrap" class="normal-td"><b>Comp.<br>to Avg.</b></td>
            </tr>
            <cfloop array="#BasicMeasuresByCargoGroup.BasicMeasuresByCargoGroupList#" index="Measures">
                <tr>
                    <td align="center" valign="middle" nowrap="nowrap" class="normal-td" style="border-left: 1px solid ##5d8cc9;">#Measures.GroupName# (#Measures.CompaniesNo#)</td>

                    <td align="right" valign="middle" nowrap="nowrap" class="normal-td">#Measures.UnsafeDriving.GroupAverage#</td>
                    <td align="center" valign="middle" nowrap="nowrap" class="normal-td CompToAvg">
                        <cfif structKeyExists(BasicISS, "UnsafeDrivMeasure")>
                            <cfif Measures.UnsafeDriving.GroupAverage LT BasicISS.UnsafeDrivMeasure>
                                Worse
                            <cfelseif Measures.UnsafeDriving.GroupAverage GT BasicISS.UnsafeDrivMeasure>
                                Better
                            <cfelse>
                                Average
                            </cfif>
                        </cfif>
                    </td>

                    <td align="right" valign="middle" nowrap="nowrap" class="normal-td">#Measures.HoursOfService.GroupAverage#</td>
                    <td align="center" valign="middle" nowrap="nowrap" class="normal-td CompToAvg">
                        <cfif structKeyExists(BasicISS, "HOSMeasure")>
                            <cfif Measures.HoursOfService.GroupAverage LT BasicISS.HOSMeasure>
                                Worse
                            <cfelseif Measures.HoursOfService.GroupAverage GT BasicISS.HOSMeasure>
                                Better
                            <cfelse>
                                Average
                            </cfif>
                        </cfif>
                    </td>

                    <td align="right" valign="middle" nowrap="nowrap" class="normal-td">#Measures.DriverFitness.GroupAverage#</td>
                    <td align="center" valign="middle" nowrap="nowrap" class="normal-td CompToAvg">
                        <cfif structKeyExists(BasicISS, "DrivFitMeasure")>
                            <cfif Measures.DriverFitness.GroupAverage LT BasicISS.DrivFitMeasure>
                                Worse
                            <cfelseif Measures.DriverFitness.GroupAverage GT BasicISS.DrivFitMeasure>
                                Better
                            <cfelse>
                                Average
                            </cfif>
                        </cfif>
                    </td>

                    <td align="right" valign="middle" nowrap="nowrap" class="normal-td">#Measures.ControlledSubstance.GroupAverage#</td>
                    <td align="center" valign="middle" nowrap="nowrap" class="normal-td CompToAvg">
                        <cfif structKeyExists(BasicISS, "ContrSubstMeasure")>
                            <cfif Measures.ControlledSubstance.GroupAverage LT BasicISS.ContrSubstMeasure>
                                Worse
                            <cfelseif Measures.ControlledSubstance.GroupAverage GT BasicISS.ContrSubstMeasure>
                                Better
                            <cfelse>
                                Average
                            </cfif>
                        </cfif>
                    </td>

                    <td align="right" valign="middle" nowrap="nowrap" class="normal-td">#Measures.VehicleMaintenance.GroupAverage#</td>
                    <td align="center" valign="middle" nowrap="nowrap" class="normal-td CompToAvg">
                        <cfif structKeyExists(BasicISS, "VehMaintMeasure")>
                            <cfif Measures.VehicleMaintenance.GroupAverage LT BasicISS.VehMaintMeasure>
                                Worse
                            <cfelseif Measures.VehicleMaintenance.GroupAverage GT BasicISS.VehMaintMeasure>
                                Better
                            <cfelse>
                                Average
                            </cfif>
                        </cfif>
                    </td>
                </tr>
            </cfloop>
            <tr>
                <td align="center" valign="middle" nowrap="nowrap" class="normal-td" style="border-left: 1px solid ##5d8cc9;height: 30px;"></td>
                <td colspan="2" align="center" valign="middle" nowrap="nowrap" class="normal-td"><cfif structKeyExists(BasicISS, "UnsafeDrivMeasure")>#BasicISS.UnsafeDrivMeasure#</cfif></td>
                <td colspan="2" align="center" valign="middle" nowrap="nowrap" class="normal-td"><cfif structKeyExists(BasicISS, "HOSMeasure")>#BasicISS.HOSMeasure#</cfif></td>
                <td colspan="2" align="center" valign="middle" nowrap="nowrap" class="normal-td"><cfif structKeyExists(BasicISS, "DrivFitMeasure")>#BasicISS.DrivFitMeasure#</cfif></td>
                <td colspan="2" align="center" valign="middle" nowrap="nowrap" class="normal-td"><cfif structKeyExists(BasicISS, "ContrSubstMeasure")>#BasicISS.ContrSubstMeasure#</cfif></td>
                <td colspan="2" align="center" valign="middle" nowrap="nowrap" class="normal-td"><cfif structKeyExists(BasicISS, "VehMaintMeasure")>#BasicISS.VehMaintMeasure#</cfif></td>
            </tr>
        <cfelse>
            <tr>
                <td  colspan="11" align="center" style="border-left: 1px solid ##5d8cc9;border-right: 1px solid ##5d8cc9;">No Records Found.</td></tr>
            </tr>
        </cfif>
        <tfoot>
            <tr>
                <td colspan="11" align="left" valign="middle" class="footer-bg" style="border-left: 1px solid ##5d8cc9;border-right: 1px solid ##5d8cc9;border-bottom-left-radius: 5px;;border-bottom-right-radius: 5px;">
                    <cfif not structIsEmpty(BasicMeasuresByCargoGroup) and  isdefined("BasicMeasuresByCargoGroup.BasicMeasuresByCargoGroupList") and  not arrayIsEmpty(BasicMeasuresByCargoGroup.BasicMeasuresByCargoGroupList) and structKeyExists(BasicISS, "ISSScore")>
                        <b>Estimated ISS Score: #BasicISS.ISSScore# Inspect</b>
                    </cfif>
                </td>
            </tr>   
        </tfoot>
    </table>

    <div style="clear:both"></div>
    <div class="white-con-area" style="height: 36px;background-color: ##82bbef;margin-top: 5px;width: 100%;">
        <h2 style="color:white;font-weight:bold;text-align: center;">Crashes Summary - Chart</h2>
    </div>



    <cfset Fatalities_1_6 = 0>
    <cfset Fatalities_7_12 = 0>
    <cfset Fatalities_13_18 = 0>
    <cfset Fatalities_19_24 = 0>
    <cfset Fatalities_25_30 = 0>
    <cfset Fatalities_31_36 = 0>
    <cfset Fatalities_37_41 = 0>
    <cfset Fatalities_42_48 = 0>
    <cfset Fatalities_49 = 0>

    <cfset Injuries_1_6 = 0>
    <cfset Injuries_7_12 = 0>
    <cfset Injuries_13_18 = 0>
    <cfset Injuries_19_24 = 0>
    <cfset Injuries_25_30 = 0>
    <cfset Injuries_31_36 = 0>
    <cfset Injuries_37_41 = 0>
    <cfset Injuries_42_48 = 0>
    <cfset Injuries_49 = 0>

    <cfset TowAway_1_6 = 0>
    <cfset TowAway_7_12 = 0>
    <cfset TowAway_13_18 = 0>
    <cfset TowAway_19_24 = 0>
    <cfset TowAway_25_30 = 0>
    <cfset TowAway_31_36 = 0>
    <cfset TowAway_37_41 = 0>
    <cfset TowAway_42_48 = 0>
    <cfset TowAway_49 = 0>

    <cfset WithCitations_1_6 = 0>
    <cfset WithCitations_7_12 = 0>
    <cfset WithCitations_13_18 = 0>
    <cfset WithCitations_19_24 = 0>
    <cfset WithCitations_25_30 = 0>
    <cfset WithCitations_31_36 = 0>
    <cfset WithCitations_37_41 = 0>
    <cfset WithCitations_42_48 = 0>
    <cfset WithCitations_49 = 0>

    <cfset FederalRecordable_1_6 = 0>
    <cfset FederalRecordable_7_12 = 0>
    <cfset FederalRecordable_13_18 = 0>
    <cfset FederalRecordable_19_24 = 0>
    <cfset FederalRecordable_25_30 = 0>
    <cfset FederalRecordable_31_36 = 0>
    <cfset FederalRecordable_37_41 = 0>
    <cfset FederalRecordable_42_48 = 0>
    <cfset FederalRecordable_49 = 0>

    <cfif not structIsEmpty(Crashes) and not arrayIsEmpty(Crashes.results)>
        <cfloop array="#Crashes.results#" index="CrashSummary">
            <cfset repDate = Insert("-", Insert("-", CrashSummary.ReportDate, 6), 4)>
            <cfset datedf = Datediff("m",repDate,now())>
            <cfif datedf LTE 6>
                <cfset Fatalities_1_6 = Fatalities_1_6 + CrashSummary.Fatalities>
                <cfset Injuries_1_6 = Injuries_1_6 + CrashSummary.Injuries>
                <cfif CrashSummary.TowAway EQ 'Y'>
                    <cfset TowAway_1_6 = TowAway_1_6 + 1>
                </cfif>
                <cfif isDefined("CrashSummary.Citation") AND CrashSummary.Citation EQ 'Yes'>
                    <cfset WithCitations_1_6 = WithCitations_1_6 + 1>
                </cfif>
                <cfif isdefined("CrashSummary.FederalRecordable") AND CrashSummary.FederalRecordable EQ 'Y'>
                    <cfset FederalRecordable_1_6 = FederalRecordable_1_6 + 1>
                </cfif>
            </cfif>

            <cfif datedf GTE 7 AND datedf LTE 12>
                <cfset Fatalities_7_12 = Fatalities_7_12 + CrashSummary.Fatalities>
                <cfset Injuries_7_12 = Injuries_7_12 + CrashSummary.Injuries>
                <cfif CrashSummary.TowAway EQ 'Y'>
                    <cfset TowAway_7_12 = TowAway_7_12 + 1>
                </cfif>
                <cfif isDefined("CrashSummary.Citation") AND CrashSummary.Citation EQ 'Yes'>
                    <cfset WithCitations_7_12 = WithCitations_7_12 + 1>
                </cfif>
                <cfif CrashSummary.FederalRecordable EQ 'Y'>
                    <cfset FederalRecordable_7_12 = FederalRecordable_7_12 + 1>
                </cfif>
            </cfif>

            <cfif datedf GTE 13 AND datedf LTE 18>
                <cfset Fatalities_13_18 = Fatalities_13_18 + CrashSummary.Fatalities>
                <cfset Injuries_13_18 = Injuries_13_18 + CrashSummary.Injuries>
                <cfif CrashSummary.TowAway EQ 'Y'>
                    <cfset TowAway_13_18 = TowAway_13_18 + 1>
                </cfif>
                <cfif isDefined("CrashSummary.Citation") AND CrashSummary.Citation EQ 'Yes'>
                    <cfset WithCitations_13_18 = WithCitations_13_18 + 1>
                </cfif>
                <cfif CrashSummary.FederalRecordable EQ 'Y'>
                    <cfset FederalRecordable_13_18 = FederalRecordable_13_18 + 1>
                </cfif>
            </cfif>

            <cfif datedf GTE 19 AND datedf LTE 24>
                <cfset Fatalities_19_24 = Fatalities_19_24 + CrashSummary.Fatalities>
                <cfset Injuries_19_24 = Injuries_19_24 + CrashSummary.Injuries>
                <cfif CrashSummary.TowAway EQ 'Y'>
                    <cfset TowAway_19_24 = TowAway_19_24 + 1>
                </cfif>
                <cfif isDefined("CrashSummary.Citation") AND CrashSummary.Citation EQ 'Yes'>
                    <cfset WithCitations_19_24 = WithCitations_19_24 + 1>
                </cfif>
                <cfif CrashSummary.FederalRecordable EQ 'Y'>
                    <cfset FederalRecordable_19_24 = FederalRecordable_19_24 + 1>
                </cfif>
            </cfif>

            <cfif datedf GTE 25 AND datedf LTE 30>
                <cfset Fatalities_25_30 = Fatalities_25_30 + CrashSummary.Fatalities>
                <cfset Injuries_25_30 = Injuries_25_30 + CrashSummary.Injuries>
                <cfif CrashSummary.TowAway EQ 'Y'>
                    <cfset TowAway_25_30 = TowAway_25_30 + 1>
                </cfif>
                <cfif isDefined("CrashSummary.Citation") AND CrashSummary.Citation EQ 'Yes'>
                    <cfset WithCitations_25_30 = WithCitations_25_30 + 1>
                </cfif>
                <cfif CrashSummary.FederalRecordable EQ 'Y'>
                    <cfset FederalRecordable_25_30 = FederalRecordable_25_30 + 1>
                </cfif>
            </cfif>

            <cfif datedf GTE 31 AND datedf LTE 36>
                <cfset Fatalities_31_36 = Fatalities_31_36 + CrashSummary.Fatalities>
                <cfset Injuries_31_36 = Injuries_31_36 + CrashSummary.Injuries>
                <cfif CrashSummary.TowAway EQ 'Y'>
                    <cfset TowAway_31_36 = TowAway_31_36 + 1>
                </cfif>
                <cfif isDefined("CrashSummary.Citation") AND CrashSummary.Citation EQ 'Yes'>
                    <cfset WithCitations_31_36 = WithCitations_31_36 + 1>
                </cfif>
                <cfif CrashSummary.FederalRecordable EQ 'Y'>
                    <cfset FederalRecordable_31_36 = FederalRecordable_31_36 + 1>
                </cfif>
            </cfif>

            <cfif datedf GTE 37 AND datedf LTE 41>
                <cfset Fatalities_37_41 = Fatalities_37_41 + CrashSummary.Fatalities>
                <cfset Injuries_37_41 = Injuries_37_41 + CrashSummary.Injuries>
                <cfif CrashSummary.TowAway EQ 'Y'>
                    <cfset TowAway_37_41 = TowAway_37_41 + 1>
                </cfif>
                <cfif isDefined("CrashSummary.Citation") AND CrashSummary.Citation EQ 'Yes'>
                    <cfset WithCitations_37_41 = WithCitations_37_41 + 1>
                </cfif>
                <cfif CrashSummary.FederalRecordable EQ 'Y'>
                    <cfset FederalRecordable_37_41 = FederalRecordable_37_41 + 1>
                </cfif>
            </cfif>

            <cfif datedf GTE 42 AND datedf LTE 48>
                <cfset Fatalities_42_48 = Fatalities_42_48 + CrashSummary.Fatalities>
                <cfset Injuries_42_48 = Injuries_42_48 + CrashSummary.Injuries>
                <cfif CrashSummary.TowAway EQ 'Y'>
                    <cfset TowAway_42_48 = TowAway_42_48 + 1>
                </cfif>
                <cfif isDefined("CrashSummary.Citation") AND CrashSummary.Citation EQ 'Yes'>
                    <cfset WithCitations_42_48 = WithCitations_42_48 + 1>
                </cfif>
                <cfif CrashSummary.FederalRecordable EQ 'Y'>
                    <cfset FederalRecordable_42_48 = FederalRecordable_42_48 + 1>
                </cfif>
            </cfif>

            <cfif datedf GTE 49>
                <cfset Fatalities_49 = Fatalities_49 + CrashSummary.Fatalities>
                <cfset Injuries_49 = Injuries_49 + CrashSummary.Injuries>
                <cfif CrashSummary.TowAway EQ 'Y'>
                    <cfset TowAway_49 = TowAway_49 + 1>
                </cfif>
                <cfif isDefined("CrashSummary.Citation") AND CrashSummary.Citation EQ 'Yes'>
                    <cfset WithCitations_49 = WithCitations_49 + 1>
                </cfif>
                <cfif CrashSummary.FederalRecordable EQ 'Y'>
                    <cfset FederalRecordable_49 = FederalRecordable_49 + 1>
                </cfif>
            </cfif>
        </cfloop>
    </cfif>
    <cfscript>
           xAxis={"label":{"text":"Historical Date Range (by Month Interval)"}};
           yAxis={"label":{"text":"Number"}};
    </cfscript>
    <cfchart format="flash" chartHeight="400" chartWidth="1000"  title="Crashes Summary" xaxis="#xaxis#" yaxis="#yaxis#" id="crashSummary">
        <cfchartseries type="bar" serieslabel="Fatalities" markerstyle="circle" color="##418cf0">
            <cfchartdata item="Over 49<br>months" value="#Fatalities_49#"/>
            <cfchartdata item="42-48<br>months" value="#Fatalities_42_48#"/>
            <cfchartdata item="37-41<br>months" value="#Fatalities_37_41#"/>
            <cfchartdata item="31-36<br>months" value="#Fatalities_31_36#"/>
            <cfchartdata item="25-30<br>months" value="#Fatalities_25_30#"/>
            <cfchartdata item="19-24<br>months" value="#Fatalities_19_24#"/>
            <cfchartdata item="13-18<br>months" value="#Fatalities_13_18#"/>
            <cfchartdata item="7-12<br>months" value="#Fatalities_7_12#"/>
            <cfchartdata item="1-6<br>months" value="#Fatalities_1_6#"/>
        </cfchartseries>
        <cfchartseries type="bar" serieslabel="Injuries" markerstyle="circle" color="##fcb441" >
            <cfchartdata item="Over 49<br>months" value="#Injuries_49#"/>
            <cfchartdata item="42-48<br>months" value="#Injuries_42_48#"/>
            <cfchartdata item="37-41<br>months" value="#Injuries_37_41#"/>
            <cfchartdata item="31-36<br>months" value="#Injuries_31_36#"/>
            <cfchartdata item="25-30<br>months" value="#Injuries_25_30#"/>
            <cfchartdata item="19-24<br>months" value="#Injuries_19_24#"/>
            <cfchartdata item="13-18<br>months" value="#Injuries_13_18#"/>
            <cfchartdata item="7-12<br>months" value="#Injuries_7_12#"/>
            <cfchartdata item="1-6<br>months" value="#Injuries_1_6#"/>
        </cfchartseries>
        <cfchartseries type="bar" serieslabel="Tow Away" markerstyle="circle" color="##e04009" >
            <cfchartdata item="Over 49<br>months" value="#TowAway_49#"/>
            <cfchartdata item="42-48<br>months" value="#TowAway_42_48#"/>
            <cfchartdata item="37-41<br>months" value="#TowAway_37_41#"/>
            <cfchartdata item="31-36<br>months" value="#TowAway_31_36#"/>
            <cfchartdata item="25-30<br>months" value="#TowAway_25_30#"/>
            <cfchartdata item="19-24<br>months" value="#TowAway_19_24#"/>
            <cfchartdata item="13-18<br>months" value="#TowAway_13_18#"/>
            <cfchartdata item="7-12<br>months" value="#TowAway_7_12#"/>
            <cfchartdata item="1-6<br>months" value="#TowAway_1_6#"/>
        </cfchartseries>
        <cfchartseries type="bar" serieslabel="With Citations" markerstyle="circle" color="##0e6391" >
            <cfchartdata item="Over 49<br>months" value="#WithCitations_49#"/>
            <cfchartdata item="42-48<br>months" value="#WithCitations_42_48#"/>
            <cfchartdata item="37-41<br>months" value="#WithCitations_37_41#"/>
            <cfchartdata item="31-36<br>months" value="#WithCitations_31_36#"/>
            <cfchartdata item="25-30<br>months" value="#WithCitations_25_30#"/>
            <cfchartdata item="19-24<br>months" value="#WithCitations_19_24#"/>
            <cfchartdata item="13-18<br>months" value="#WithCitations_13_18#"/>
            <cfchartdata item="7-12<br>months" value="#WithCitations_7_12#"/>
            <cfchartdata item="1-6<br>months" value="#WithCitations_1_6#"/>
        </cfchartseries>
        <cfchartseries type="bar" serieslabel="Federal Recordable" markerstyle="circle" color="##bebebe" >
            <cfchartdata item="Over 49<br>months" value="#FederalRecordable_49#"/>
            <cfchartdata item="42-48<br>months" value="#FederalRecordable_42_48#"/>
            <cfchartdata item="37-41<br>months" value="#FederalRecordable_37_41#"/>
            <cfchartdata item="31-36<br>months" value="#FederalRecordable_31_36#"/>
            <cfchartdata item="25-30<br>months" value="#FederalRecordable_25_30#"/>
            <cfchartdata item="19-24<br>months" value="#FederalRecordable_19_24#"/>
            <cfchartdata item="13-18<br>months" value="#FederalRecordable_13_18#"/>
            <cfchartdata item="7-12<br>months" value="#FederalRecordable_7_12#"/>
            <cfchartdata item="1-6 months" value="#FederalRecordable_1_6#"/>
        </cfchartseries>
    </cfchart>


    <div style="clear:both"></div>
    <div class="white-con-area" style="height: 36px;background-color: ##82bbef;margin-top: 5px;width: 100%;">
        <h2 style="color:white;font-weight:bold;text-align: center;">Crashes Summary - Table</h2>
    </div>
    <table width="100%" border="0" class="data-table" cellspacing="0" cellpadding="0">
        <thead>
            <tr>
                <th align="center" valign="middle" class="head-bg" style="border-left: 1px solid ##5d8cc9;border-top-left-radius: 5px;">Report Date</th>
                <th align="center" valign="middle" class="head-bg">Report Number</th>
                <th align="center" valign="middle" class="head-bg">Report State</th>
                <th align="center" valign="middle" class="head-bg">Vehicle License Number</th>
                <th align="center" valign="middle" class="head-bg">Vehicle License State</th>
                <th align="center" valign="middle" class="head-bg">Fatal/Inj./Tow/HM</th>
                <th align="center" valign="middle" class="head-bg2" style="border-right: 1px solid ##5d8cc9;">Sev/Time/Total</th>
            </tr>
        </thead>
        <cfif not structIsEmpty(Crashes) and not arrayIsEmpty(Crashes.results)>
            <cfloop array="#Crashes.results#" index="CrashSummary">
                <tr>
                    <td align="center" valign="middle" nowrap="nowrap" class="normal-td" style="border-left: 1px solid ##5d8cc9;">#DateFormat(dateFormat(Insert("-", Insert("-", CrashSummary.ReportDate, 6), 4),"mm/dd/yyyy"),"mm/dd/yyyy")#</td>
                    <td align="center" valign="middle" nowrap="nowrap" class="normal-td">#CrashSummary.ReportNumber#</td>
                    <td align="center" valign="middle" nowrap="nowrap" class="normal-td">#CrashSummary.ReportState#</td>
                    <td align="center" valign="middle" nowrap="nowrap" class="normal-td">
                        <cfif isDefined("CrashSummary.VehicleLicenseNumber")>
                            #CrashSummary.VehicleLicenseNumber#
                        </cfif>
                    </td>
                    <td align="center" valign="middle" nowrap="nowrap" class="normal-td"><cfif isDefined("CrashSummary.VehicleLicenseState")>#CrashSummary.VehicleLicenseState#<cfelse>OFF</cfif></td>
                    <td align="center" valign="middle" nowrap="nowrap" class="normal-td">#CrashSummary.Fatalities#/#CrashSummary.Injuries#/#CrashSummary.TowAway#/<cfif isDefined('CrashSummary.HazmatReleased')>#CrashSummary.HazmatReleased#<cfelse>N</cfif></td>
                    <td align="center" valign="middle" nowrap="nowrap" class="normal-td">#CrashSummary.SeverityWeight#/#CrashSummary.TimeWeight#/#CrashSummary.SeverityWeight*CrashSummary.TimeWeight#</td>
                </tr>
            </cfloop>
        <cfelse>
            <tr>
                <td  colspan="7" align="center" style="border-left: 1px solid ##5d8cc9;border-right: 1px solid ##5d8cc9;">No Records Found.</td></tr>
            </tr>
        </cfif>
        <tfoot>
            <tr>
                <td colspan="7" align="left" valign="middle" class="footer-bg" style="border-left: 1px solid ##5d8cc9;border-right: 1px solid ##5d8cc9;border-bottom-left-radius: 5px;;border-bottom-right-radius: 5px;">
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
    