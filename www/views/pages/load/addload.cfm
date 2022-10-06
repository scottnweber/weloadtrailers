<!--- :::::
---------------------------------
Changing 571 Line Extra line comment of consigneeZipcode already use in getdistance.cfm page
---------------------------------
::::: --->
<!--- Start timing test --->
<cfinvoke component="#variables.objloadGateway#" method="getSystemSetupOptions" returnvariable="request.qSystemSetupOptions" />
<cfinvoke component="#variables.objagentGateway#" method="getBillFromCompanies" returnvariable="request.qBillFromCompanies" />
<cfif ( structkeyexists(url,"loadid") and len(trim(url.loadid)) gt 1 )>
    <cfinvoke component="#variables.objloadGateway#" method="getLoadLock" returnvariable="request.qLoadLock" LoadID="#url.loadid#"/>
</cfif>
<cfoutput>
    <style>
    .content-area{
        margin: 0;
        width: 932px;
    }
    .container{
        width: 932px;
        margin: 0 auto;
    }
    .s-hidden {
        visibility:hidden;
        padding-right:10px;
    }
    .select {
        cursor:pointer;
        display:inline-block;
        position:relative;
        font:normal 11px/22px Arial,Sans-Serif;
        color:black;
        border: 1px solid ##b3b3b3;
        float: left;
        height: 21px;
        margin-bottom: 3px;
    }
    .styledSelect {
        position:absolute;
        top:0;
        right:0;
        bottom:0;
        left:0;
        background-color:white;
        padding:0 4px;
        height: 21px;
        overflow: hidden;
    }
    .styledSelect:after {
        content:"";
        width:0;
        height:0;
        border:5px solid transparent;
        border-color:black transparent transparent transparent;
        position:absolute;
        top:9px;
        right:6px;
    }
    .styledSelect:active,.styledSelect.active {
        background-color:##eee;
    }
    .options {
        display:none;
        position:absolute;
        top:100%;
        right:0;
        left:0;
        z-index:999;
        margin:0 0;
        padding:0 0;
        list-style:none;
        border:1px solid ##b3b3b3;
        background-color:white;
        -webkit-box-shadow:0 1px 2px rgba(0,0,0,0.2);
        -moz-box-shadow:0 1px 2px rgba(0,0,0,0.2);
        box-shadow:0 1px 2px rgba(0,0,0,0.2);
        width:352px;
        height: 223px;
        overflow: auto;
    }
    
    .options tr {
        padding:0 6px;
        margin:0 0;
        padding:0 10px;
    }
    .options tr:hover {
        background-color:##39f;
        color:white;
    }
    .options td {
        border-top: 1px solid ##b3b3b3;
        border-right: 1px solid ##b3b3b3;
        font: 11px/16px Arial,Helvetica,sans-serif !important;
        padding-left: 3px;
        padding-right: 3px;
    }
    .options th{
        border-right: 1px solid ##b3b3b3;
        text-align: left;
        font: 11px/16px Arial,Helvetica,sans-serif !important;
        padding-left: 3px;
        padding-right: 3px;
        font-weight: bold !important;
    }
    .options tr.hover {
        background-color:##39f;
        color:white;
    }
    .options tbody tr:first-child td:first-child {
        border-right: none;
    }
    .options tbody tr:first-child td:nth-child(2) {
        border-right: none;
    }
    .hyperLinkLabel{
        text-decoration: underline;
        color:##4322cc !important;
        cursor: pointer;
    }
    .hyperLinkLabelStop{
        text-decoration: underline;
        color:##4322cc !important;
        cursor: pointer;
    }
    input[name^="driverCell"]::placeholder {
      font-size: 10px;
    }
    </style>
    <script type="text/javascript">
        $( window ).on( "load", function() {
            $(".loadOverlay").css("display","none");
        });
        $( document ).ready(function() {
            for(i=2;i<11;i++){
                $("##totalResult"+i).val(0);
            }  

            if($('##ediInvoiced').val()==1){
                 $('select,input,textarea').each(function () {
                    if (this.id!= 'payments' && this.id != 'edidocs' && this.id != 'edi212' && this.id != 'edi214' ) {
                   $(this).css("pointer-events","none");
                   $(this).css("opacity","0.5")
               }
                })
                $('.addLoadWrap img').css("pointer-events","none").css("opacity","0.5");
                $('.addLoadWrap a').css("pointer-events","none").css("opacity","0.5");
                $('.addLoadWrap a').css("pointer-events","none").css("opacity","0.5");
                $('##divUploadedFiles a').css("pointer-events","none").css("opacity","0.5");
                $('.green-btn,.green-btnUnlock').css("pointer-events","");
                $('.green-btn,.green-btnUnlock').css("opacity", "1");
                $('input[name=addstopButton]').css("pointer-events","none");
                $('input[name=addstopButton]').css("opacity","0.5")
                $('input[name=submit]').css("pointer-events","none");
                $('input[name=submit]').css("opacity","0.5")
                $('input[name=save]').css("pointer-events","none");
                $('input[name=save]').css("opacity","0.5")
                $('input[name=saveexit]').css("pointer-events","none");
                $('input[name=saveexit]').css("opacity","0.5")
                var i = 1
                $('input[name=unlock]').each(function() {
                    if(i > 1){
                        $(this).hide();
                    }
                    i++;
                });
            }   

            $("##defaultCarrierCurrency").change(function(){
                var that = $(this).find('option:selected').text();
                $("table[id^=commodity] .carrierCurrencyISO").text(that.replace(/\(.*\)/,""));
                $(".carrierLanes .carrierCurrencyISO").text(that.replace(/\(.*\)/,""));
                if($("##defaultCarrierCurrency").val() != $("##defaultCustomerCurrency").val()){
                    $("input[id^=CarrierPer]").css( "color", "##c4c7ca" );
                    $("input[id^=CarrierPer]").prop( "readonly", true );
                }else{
                    $("input[id^=CarrierPer]").css( "color", "##00000" );
                    $("input[id^=CarrierPer]").prop( "readonly", false );
                }
            });
            $("##defaultCarrierCurrency").trigger("change");
            
            
            $("##defaultCustomerCurrency").change(function(){
                var that = $(this).find('option:selected').text();
                $("table[id^=commodity] .customerCurrencyISO").text(that.replace(/\(.*\)/,""));
                if($("##defaultCarrierCurrency").val() != $("##defaultCustomerCurrency").val()){
                    $("input[id^=CarrierPer]").css( "color", "##c4c7ca" );
                    $("input[id^=CarrierPer]").prop( "readonly", true );
                }else{
                    $("input[id^=CarrierPer]").css( "color", "##00000" );
                    $("input[id^=CarrierPer]").prop( "readonly", false );
                }
            });
            $("##defaultCustomerCurrency").trigger("change");
            
            
            $("##defaultCarrierCurrency, ##defaultCustomerCurrency").change(function(){
                $("select[id^=unit]:visible").trigger("change");
            });

            $( "##deadHeadMiles" ).change(function() {
                var milseVal = $(this).val();
                if($.trim(milseVal).length && isNaN(milseVal)){
                    alert('Invalid DeadHead Miles.')
                    $(this).val(0);
                    $(this).focus();
                }
            });

           
            const timeZoneAbbreviated = () => {
                const { 1: tz } = new Date().toString().match(/\((.+)\)/);
                if (tz.includes(" ")) {
                    return tz
                    .split(" ")
                    .map(([first]) => first)
                    .join("");
                } else {
                    return tz;
                }
            };
            $( ".showLocalTime" ).each(function() {
                var serverTime = $.trim($(this).html());
                var utcOffsetLocalServer = <cfoutput>#GetTimeZoneInfo().utcTotalOffset#</cfoutput>;
                var dateObj = new Date(serverTime);
                var utcOffsetLocal = dateObj.getTimezoneOffset();
                dateObj.setSeconds( dateObj.getSeconds() + utcOffsetLocalServer );
                dateObj.setMinutes( dateObj.getMinutes() - utcOffsetLocal );
                var m = dateObj.getMonth();
                var d = dateObj.getDate();
                var yyyy = dateObj.getFullYear();
                var HH = dateObj.getHours();
                var nn = dateObj.getMinutes()
                if(HH<10){
                    HH = '0'+HH;
               }
               if(nn<10){
                    nn = '0'+nn;
               }
                $(this).html(m+'/'+d+'/'+yyyy+' '+HH+':'+nn+' '+timeZoneAbbreviated());

            })
           
        });
    </script>

    <style>
        span.iconediting {
            position: absolute;
            right: -10px;
            top: 3px;
            font-size: 20px;
        }
        .tbl_quote_list tbody tr:nth-child(odd) {background: ##CCC}
        .tbl_quote_list tbody tr:nth-child(even) {background: ##f3f1f1}     
        .carrierlink{
            cursor: pointer;
            color:##0000ff;
        }
        .tbl_quote_list tbody tr td{text-align: center;}

        .white-mid div.form-con fieldset input{
            margin-bottom: 3px !important;
        }
        .white-mid div.form-con fieldset textarea{
            margin-bottom: 3px !important;
        }
        .white-mid div.form-con fieldset select{
            margin-bottom: 3px !important;
        }
        .InfoStopLeft input{
            width : 260px !important;;
        }
        .InfoStopLeft input[id^=shipperZipcode]{
            width : 132px !important;;
        }
        .InfoStopLeft input[id^=consigneeZipcode]{
            width : 132px !important;;
        }
        .InfoStopLeft textarea{
            width : 260px !important;;
        }
        .carrierLanes th{
            height: 35px;
            background-size: contain;
        }
    </style>

    <cfparam name="variables.totalStopcount" default="2">
    <cfparam name="variables.totalStopcounts" default="1">
    <cfset includeTemplate("views/pages/load/cleanJavaScriptData.cfm") />
    <cfparam name="url.loadid" default="0">

    <cfset variables.loaddisabledStatus=false>
    <cfif ( structkeyexists(url,"loadid") and len(trim(url.loadid)) gt 1 )>
        <cfset session.currentloadid=url.loadid>
        <script>            
            $(document).ready(function(){
                var path = urlComponentPath+"loadgateway.cfc?method=CheckLoadMissingAttachment";
                var curLdStatus =$("##loadStatus option:selected").text().trim();
                if(curLdStatus == 'ACTIVE' || curLdStatus == 'BOOKED'){
                    $.ajax({
                        type: "Post",
                        url: path,
                        dataType: "json",
                        data: {
                            LoadID:'#url.loadid#',companyid:'#session.companyid#',dsn:'#application.dsn#'
                        },
                        success: function(data){
                            if(data==1){
                                $('##missingReqAtt').show();
                            }
                        }
                    });
                }
            });
        </script>
        <!---Object to get corresponding roleid of user--->
        <cfinvoke component="#variables.objAgentGateway#" method="getRoleid" returnvariable="request.qryGetRoleId" employeID="#session.empid#" />
        <!---Object to get corresponding user edited the load--->
        <cfinvoke component="#variables.objloadGateway#" method="getUserEditingDetails" loadid="#loadID#" returnvariable="request.qryUserEditingDetails"/>
        <!---Condition to check user edited the load or not--->
        <cfif not len(trim(request.qryUserEditingDetails.InUseBy))>
            <!---Object to update corresponding user edited the load--->
            <cfinvoke component="#variables.objAgentGateway#" method="checkUserLoginActive" returnvariable="request.UserActive"/>
            <cfif request.UserActive>
                <cfinvoke component="#variables.objloadGateway#" method="updateEditingUserId" loadid="#loadID#" userid="#session.empid#" status="false"/>
            </cfif>
        <cfelse>
            <!---Object to get corresponding Previously edited---->
            <cfinvoke component="#variables.objAgentGateway#" method="getEditingUserName" returnvariable="request.qryGetEditingUserName" employeID="#request.qryUserEditingDetails.inuseby#" />
            <!---Condition to check current employee and previous editing employee are not same--->
            <cfif session.empid neq request.qryUserEditingDetails.inuseby>
                <cfif request.qryGetEditingUserName.recordcount>
                    <cfset variables.loaddisabledStatus=true>
                    <div class="msg-area" style="margin-left:10px;margin-bottom:10px">
                        <span style="color:##d21f1f">This load locked because it is currently being edited by #request.qryGetEditingUserName.Name# #dateformat(request.qryUserEditingDetails.inuseon,"mm/dd/yy hh:mm:ss")#.
                            An Administrator can manually override this lock by clicking the unlock button.
                        </span>
                    </div>
                </cfif>
            </cfif>
        </cfif>
    </cfif>
</cfoutput>
<cfinvoke component="#variables.objloadGateway#" method="getLoadSystemSetupOptions" returnvariable="request.qSystemSetupOptions1" />
<cfinvoke component="#variables.objloadGateway#" method="getCompanyInformation" returnvariable="request.qGetCompanyInformation" />
<cfinvoke component="#variables.objloadGateway#" method="getLoadCarriersMails" loadid="#url.loadid#" returnvariable="request.qcarriers" />
<cfinvoke component="#variables.objloadGateway#" method="getcurAgentdetails" returnvariable="request.qcurAgentdetails" employeID="#session.empid#" />
<cfinvoke component="#variables.objloadGateway#" method="getcurAgentMaildetails" returnvariable="request.qcurMailAgentdetails" employeID="#session.empid#" />
<cfset tickBegin = GetTickCount()>
<cfoutput>
    <cfif request.qcurMailAgentdetails.recordcount gt 0 and (
       (structKeyExists(request.qcurMailAgentdetails, "SmtpAddress") AND request.qcurMailAgentdetails.SmtpAddress eq "") 
    or (structKeyExists(request.qcurMailAgentdetails, "SmtpUsername") AND request.qcurMailAgentdetails.SmtpUsername eq "") 
    or (structKeyExists(request.qcurMailAgentdetails, "SmtpPort") AND request.qcurMailAgentdetails.SmtpPort eq "") 
    or (structKeyExists(request.qcurMailAgentdetails, "SmtpPassword") AND request.qcurMailAgentdetails.SmtpPassword eq "")
    or (structKeyExists(request.qcurMailAgentdetails, "SmtpPort") AND request.qcurMailAgentdetails.SmtpPort eq 0)
    or (structKeyExists(request.qcurMailAgentdetails, "EmailValidated") AND request.qcurMailAgentdetails.EmailValidated eq 0)
    )>
        <cfset mailsettings = "false">
    <cfelse>
        <cfset mailsettings = "true">
    </cfif>
    <cfset variables.statusDispatch='Customer Invoice'>
    <cfif request.qSystemSetupOptions.freightBroker EQ 1>
        <cfset variables.freightBroker = "Carrier">
        <cfset variables.freightBrokerShortForm = "Carr">
        <cfset variables.freightBrokerReport = "Carrier">
        <cfset variables.carrierDispatch = 'Rate Con'>  
        <cfset variables.rateCon = 'Rate Con'> 
    <cfelseif request.qSystemSetupOptions.freightBroker EQ 2> 
        <cfset variables.freightBroker = "Carrier/Driver">
        <cfset variables.freightBrokerShortForm = "Carr">
    <cfelse>
        <cfset variables.freightBroker = "Driver">
        <cfset variables.freightBrokerShortForm = "Driv">
        <cfset variables.freightBrokerReport = "Dispatch">
        <cfset variables.carrierDispatch = 'Dispatch'>
        <cfset variables.rateCon = 'Dispatch Report'>
    </cfif>

    <cfparam name="url.editid" default="0">
    <cfparam name="url.loadToBeCopied" default="0">
    <cfparam name="LoadNumber" default="">
    <cfparam name="NewcustomerID" default="0">
    <cfparam name="LOADSTOPID" default="">
    <cfparam name="loadStatus" default="">
    <cfparam name="Salesperson" default="">
    <cfparam name="Dispatcher" default="">
    <cfparam name="Notes" default="">
    <cfparam name="IsPartial" default="0">
    <cfparam name="posttoITS" default="">
    <cfparam name="posttoloadboard" default="0">
    <cfparam name="postto123loadboard" default="0">
    <cfparam name="postFlagStatus" default="0">
    <cfparam name="posttoTranscore" default="0">
    <cfparam name="postCarrierRatetoITS" default="0">
    <cfparam name="postCarrierRatetoloadboard" default="0">
    <cfparam name="postCarrierRatetoTranscore" default="0">
    <cfparam name="postCarrierRateto123LoadBoard" default="0">
    <cfparam name="ARExported" default="0">
    <cfparam name="APExported" default="0">
    <cfparam name="CustomerRatePerMile" default="0">
    <cfparam name="CarrierRatePerMile" default="0">
    <cfparam name="TotalCustomerCharges" default="0">
    <cfparam name="TotalCarrierCharges" default="0">
    <cfparam name="TotalDirectCost" default="0">
    <cfparam name="TotalCustcommodities" default="0">
    <cfparam name="TotalCarcommodities" default="0">
    <cfparam name="dispatchNotes" default="">
    <cfparam name="carrierNotes" default="">
    <cfparam name="CriticalNotes" default="">
    <cfparam name="StatusDispatchNotes" default="">
    <cfparam name="customerID" default="">
    <cfparam name="isPayer" default="">
    <cfparam name="shipIsPayer" default="">
    <cfparam name="carrierID" default="">
    <cfparam name="carrierID2_1" default="">
    <cfparam name="carrierID3_1" default="">
    <cfparam name="customerPO" default="">
    <cfparam name="BOLNum" default="">
    <cfparam name="loadCustomerName" default="">
    <cfparam name="ShipCustomerStopName" default="">
    <cfparam name="ShipIsPayer" default="">
    <cfparam name="ConsineeCustomerStopName" default="">
    <cfparam name="shipperCustomerID" default="">
    <cfparam name="consigneeCustomerID" default="">
    <cfparam name="Invoicenumber" default="0">
    <cfparam name="CarrierInvoiceNumber" default="">
    <cfparam name="consigneeLoadStopId" default="">
    <cfparam name="totalProfit" default="0">
    <cfparam name="PricingNotes" default="">
    <cfparam name="perc" default="0">
    <cfparam name="Shiplocation" default="">
    <cfparam name="Shipcity" default="">
    <cfparam name="Shipstate1" default="">
    <cfparam name="Shipzipcode" default="">
    <cfparam name="ShipcontactPerson" default="">
    <cfparam name="ShipPhone" default="">
    <cfparam name="ShipPhoneExt" default="">
    <cfparam name="Shipfax" default="">
    <cfparam name="Shipemail" default="">
    <cfparam name="ShipPickupNo" default="">
    <cfparam name="ShippickupDate" default="">
    <cfparam name="ShippickupDateMultiple" default="">
    <cfparam name="ShippickupTime" default="">
    <cfparam name="ShipperTimeZone" default="">
    <cfparam name="LateStop" default="0">
    <cfparam name="shipperStopDateQ" default="">
    <cfparam name="ShiptimeIn" default="">
    <cfparam name="ShiptimeOut" default="">
    <cfparam name="ShipInstructions" default="">
    <cfparam name="Shipdirection" default="">
    <cfparam name="Consigneelocation" default="">
    <cfparam name="Consigneecity" default="">
    <cfparam name="Consigneestate1" default="">
    <cfparam name="Consigneezipcode" default="">
    <cfparam name="ConsigneecontactPerson" default="">
    <cfparam name="ConsigneePhone" default="">
    <cfparam name="ConsigneePhoneExt" default="">
    <cfparam name="Consigneefax" default="">
    <cfparam name="Consigneeemail" default="">
    <cfparam name="ConsigneePickupNo" default="">
    <cfparam name="ConsigneepickupDate" default="">
    <cfparam name="ConsigneepickupTime" default="">
    <cfparam name="consigneeTimeZone" default="">
    <cfparam name="ConsigneetimeIn" default="">
    <cfparam name="ConsigneetimeOut" default="">
    <cfparam name="ConsigneeStopDateQ" default="">
    <cfparam name="ConsigneeInstructions" default="">
    <cfparam name="Consigneedirection" default="">
    <cfparam name="shipBlind" default="False">
    <cfparam name="ConsBlind" default="False">
    <cfparam name="bookedwith1" default="">
    <cfparam name="equipment1" default="">
    <cfparam name="driver" default="">
    <cfparam name="driver2" default="">
    <cfparam name="driverCell" default="">
    <cfparam name="truckNo" default="">
    <cfparam name="TrailerNo" default="">
    <cfparam name="refNo" default="">
    <cfparam name="milse" default="0">
    <cfparam name="stofficeid" default="">
    <cfparam name="editid" default="0">
    <cfparam name="statename" default="0">
    <cfparam name="rdyDate" default="">
    <cfparam name="ariveDate" default="">
    <cfparam name="isExcused" default="0">
    <cfparam name="bookedBy" default="">
    <cfparam name="IsITSPst" default="0">
    <cfparam name="Is123LoadBoardPst" default="0">
    <cfparam name="customerrate" default="0">
    <cfparam name="carrierrate" default="0">
    <cfparam name="consigneeIsPayer" default="0">
    <cfparam name="userDef1" default="">
    <cfparam name="userDef2" default="">
    <cfparam name="userDef3" default="">
    <cfparam name="userDef4" default="">
    <cfparam name="userDef5" default="">
    <cfparam name="userDef6" default="">
    <cfparam name="variables.flagstatus" default="0">
    <cfparam name="variables.flagstatusConsignee" default="0">
    <cfparam name="weight1" default="0">
    <cfparam name="userDefinedFieldTrucking" default="">
    <cfparam name="variables.custAdvancepayments" default="0">
    <cfparam name="variables.carrierAdvancepayments" default="0">
    <cfparam name="currLocDiver" default="">
    <cfparam name="emailList" default="">
    <cfparam name="driverNameList" default="">
    <cfparam name="EquipmentNameList" default="">
    <cfparam name="secDriverCell" default="">
    <cfparam name="thirdDriverCell" default="">
    <cfparam name="deadHeadMiles" default="">
    <cfparam name="temperature"  default="">
    <cfparam name="EquipmentLength"  default="">
    <cfparam name="EquipmentWidth"  default="">
    <cfparam name="temperaturescale"  default="">
    <cfparam name="dispatchStatusDesc"  default="DISPATCHED">
    <cfparam name="dispatchStatusActive"  default="1">
    <cfparam name="dispatchStatusID"  default="">
    <cfif request.qSystemSetupOptions.forceUserToEnterTrip>
        <cfparam name="noOfTrips" default="">
    <cfelse>
        <cfparam name="noOfTrips" default="1">
    </cfif>
    <cfparam name="ediInvoiced" default="0">
    <cfparam name="FF" default="0">
    <cfparam name="PODSignature" default="">
    <cfparam name="EDISCAC" default="">
    <cfparam name="ISPOST" default="0">

    <cfparam name="posttoDirectFreight" default="0">
    <cfparam name="postCarrierRatetoDirectFreight" default="0">
    <cfparam name="SalesRep1" default="">
    <cfparam name="SalesRep2" default="">
    <cfparam name="SalesRep3" default="">
    <cfparam name="SalesRep1Percentage" default="0">
    <cfparam name="SalesRep2Percentage" default="0">
    <cfparam name="SalesRep3Percentage" default="0">
    <cfparam name="Dispatcher1" default="">
    <cfparam name="Dispatcher2" default="">
    <cfparam name="Dispatcher3" default="">
    <cfparam name="Dispatcher1Percentage" default="0">
    <cfparam name="Dispatcher2Percentage" default="0">
    <cfparam name="Dispatcher3Percentage" default="0">

    <cfparam name="CustomDriverPay" default="0">
    <cfparam name="CustomDriverPayOption" default="0">
    <cfparam name="CustomDriverPayOption2" default="0">
    <cfparam name="CustomDriverPayOption3" default="0">
    <cfparam name="CustomDriverPayFlatRate" default="0">
    <cfparam name="CustomDriverPayFlatRate2" default="0">
    <cfparam name="CustomDriverPayFlatRate3" default="0">
    <cfparam name="CustomDriverPayPercentage" default="0">
    <cfparam name="CustomDriverPayPercentage2" default="0">
    <cfparam name="CustomDriverPayPercentage3" default="0">
    <cfparam name="equipmentTrailer" default="">
    <cfparam name="RateApprovalNeeded" default="0">
    <cfparam name="MarginApproved" default="0">
    <cfparam name="LastApprovedRate" default="0">
    <cfparam name="BillFromCompany" default="">
    <cfparam name="CustomerPaid" default="0">
    <cfparam name="CarrierPaid" default="">
    <cfparam name="LimitCarrierRate" default="">
    <cfparam name="MaxCarrierRate" default="0">
<!--- Encrypt String --->
    <cfset Secret = application.dsn>
    <cfset TheKey = 'NAMASKARAM'>
    <cfset Encrypted = Encrypt(Secret, TheKey)>
    <cfset dsn = URLEncodedFormat(ToBase64(Encrypted))>

    <cfinvoke component="#variables.objAgentGateway#" method="getAllStaes" returnvariable="request.qStates" />
    <cfinvoke component="#variables.objequipmentGateway#" method="getloadEquipments" returnvariable="request.qEquipments" />
    <cfinvoke component="#variables.objunitGateway#" method="getloadUnits" status="True" returnvariable="request.qUnits" />
    <cfinvoke component="#variables.objclassGateway#" method="getloadClasses" status="True" returnvariable="request.qClasses" />

    <cfif request.qsystemsetupoptions.ForeignCurrencyEnabled>
        <cfinvoke component="#variables.objloadGateway#" method="getCurrencies" IsActive="1" returnvariable="request.qGetCurrencies" />
    </cfif>

    <cfquery  name="request.qoffices" datasource="#application.dsn#">
        select CarrierOfficeID,location,carrierID from carrieroffices  where location <> '' and carrierID is not null
        and carrierid in (select carrierid from carriers where companyid = <cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar">)
        ORDER BY Location ASC
    </cfquery>

    <cfset AuthLevel = "Sales Representative,Manager,Dispatcher,Administrator,Central Dispatcher,Data Entry">
    <cfinvoke component="#variables.objloadGateway#" AuthLevel="#AuthLevel#" method="getloadSalesPerson" returnvariable="request.qSalesPerson" />
    <cfinvoke component="#variables.objloadGateway#" AuthLevel="Dispatcher" method="getloadSalesPerson" returnvariable="request.qDispatcher" />
    <cfinvoke component="#variables.objloadGateway#" AuthLevel="Administrator" method="getloadSalesPerson" returnvariable="request.qBookedBy" />


    <cfset NoOfStopsToShow = 0>
    <cfset loadID = "">

    <cfif  structkeyexists(url,"loadid") and len(trim(url.loadid)) gt 1>
        <cfset loadID = url.loadid>
    <cfelseif structkeyexists(url,"loadToBeCopied") and len(trim(url.loadToBeCopied)) gt 1>
        <cfset loadID = url.loadToBeCopied>
    </cfif>
    <cfset DispatchNotesToShow = request.qSystemSetupOptions.DispatchNotes>
    <cfset CarrierNotesToShow = request.qSystemSetupOptions.CarrierNotes>
    <cfset NotesToShow = request.qSystemSetupOptions.Notes>
    <cfset StatusDispatchNotesToShow = request.qSystemSetupOptions.statusdispatchnotes>
    <cfinvoke component="#variables.objloadGateway#" method="getLoadSystemSetupOptions" returnvariable="request.qSystemSetupOptions1" />
    
    <cfif ( structkeyexists(url,"loadid") and len(trim(url.loadid)) gt 1 )>
        <cfinvoke component="#variables.objloadGateway#" method="CheckForLoadStopS" loadid="#loadID#"  returnvariable="request.qCheckForLoadStopSMsg" />
    </cfif>

    <cfif ( structkeyexists(url,"loadid") and len(trim(url.loadid)) gt 1 ) OR ( structkeyexists(url,"loadToBeCopied")  and len(trim(url.loadToBeCopied)) gt 1 )>
        <cfinvoke component="#variables.objloadGateway#" method="CheckForLoadStopS" loadid="#loadID#"  returnvariable="request.qCheckForLoadStopSMsg" />
        <cfinvoke component="#variables.objloadGateway#" method="getAllLoads" loadid="#loadID#" stopNo="0" returnvariable="request.qLoads" />
        <cfinvoke component="#variables.objloadGateway#" method="getAllStopsCount" loadid="#loadID#"  returnvariable="request.loadstopcount" />
        <cfinvoke component="#variables.objloadGateway#" method="getAdvancepaymentDetails" loadid="#loadID#"  returnvariable="request.loadAdvancePayment" />
        <cfinvoke component="#variables.objloadGateway#" method="getAllItems" LOADSTOPID="#request.qLoads.shipperLoadStopID#" returnvariable="request.qItems" />
        <cfinvoke component="#variables.objloadGateway#" method="getNoOfStops" LOADID="#loadID#" returnvariable="request.NoOfStops" />
        <cfinvoke component="#variables.objloadGateway#" method="getIsPayer"  loadid="#loadID#"  returnvariable="request.payer" />
        <cfinvoke component="#variables.objloadGateway#" method="loadBoardFlagStatus"  loadid="#loadID#"  returnvariable="request.loadBoardFlag" />

        <cfinvoke component="#variables.objloadGateway#" method="getLoadStopDetails" loadid="#loadID#"  returnvariable="request.qLoadStopDetails" />   

        <cfinvoke component="#variables.objloadGateway#" method="getLoadCarrierQuotes" loadid="#loadID#"  returnvariable="request.qLoadCarrierQuotes" /> 

        <cfif request.loadAdvancePayment.recordcount>
            <cfset variables.custAdvancepayments=request.loadAdvancePayment.CUSTPAYMENTS>
            <cfset variables.carrierAdvancepayments=request.loadAdvancePayment.PAYMENTS>
        </cfif>

        <cfif request.qLoadStopDetails.recordCount>
            <cfset driverNameList = ListChangeDelims(listremoveduplicates(valueList(request.qLoadStopDetails.NewDriverName)), ", ")>
            <cfif structKeyExists(request.qLoadStopDetails, "EquipmentName")>
                <cfset EquipmentNameList = ListChangeDelims(listremoveduplicates(valueList(request.qLoadStopDetails.EquipmentName)), ", ")>
            <cfelse>
                <cfset EquipmentNameList="">
            </cfif>
        </cfif>

        <cfset isPayer = request.payer.isPayer>
        <cfset NoOfStopsToShow = request.NoOfStops>
        <cfset url.editid=loadID>
        <cfset session.AllInfo.editid = loadid>
        <cfset loadID=loadID>
        <cfset session.AllInfo.loadid=loadID>
        <cfset LoadNumber = request.qLoads.LoadNumber>
        <cfset session.AllInfo.loadnumber = request.qLoads.LoadNumber>
        <cfset LOADSTOPID = request.qLoads.LOADSTOPID>
        <cfset session.AllInfo.LOADSTOPID = request.qLoads.LOADSTOPID>
        <cfset loadStatus=request.qLoads.STATUSTYPEID>
        <cfif  NOT ( structkeyexists(url,"loadToBeCopied")  and len(trim(url.loadToBeCopied)) gt 1 ) OR (( structkeyexists(url,"loadToBeCopied")  and len(trim(url.loadToBeCopied)) gt 1 )  AND (request.qSystemSetupOptions1.CopyLoadIncludeAgentAndDispatcher EQ 1 OR request.qLoads.STATUSTEXT EQ '. TEMPLATE'))>
            <cfset Salesperson=request.qLoads.SALESREPID>
            <cfset Dispatcher=request.qLoads.DISPATCHERID>
            <cfinvoke component="#variables.objloadGateway#" Salesperson="#Salesperson#" Dispatcher="#Dispatcher#" AuthLevel="#AuthLevel#" method="getloadSalesPerson" returnvariable="request.qSalesPerson" />
        </cfif>
        <cfset Notes=request.qLoads.NEWNOTES>
        <cfset posttoTranscore=request.qLoads.IsTransCorePst>
        <cfset userDefinedFieldTrucking=request.qLoads.userDefinedFieldTrucking>
        <cfset weight1=request.qLoads.weight>
        <cfset posttoloadboard=request.qLoads.ISPOST>
        <cfset ISPOST=request.qLoads.ISPOST>
        <cfset postto123loadboard=request.qLoads.postto123loadboard>
        <cfset ARExported=request.qLoads.ARExportedNN>
        <cfset APExported=request.qLoads.APExportedNN>
        <cfset CustomerPaid=request.qLoads.CustomerPaid>
        <cfset CarrierPaid=request.qLoads.CarrierPaid>
        <cfset LimitCarrierRate=request.qLoads.LimitCarrierRate>
        <cfset CustomerRate=request.qLoads.CUSTFLATRATE>
        <cfset CarrierRate=request.qLoads.CARRFLATRATE>
        <cfset customerID = request.qLoads.payerID>
        <cfset CustomerRatePerMile = request.qLoads.CustomerRatePerMile>
        <cfset CarrierRatePerMile = request.qLoads.CarrierRatePerMile>
        <cfset TotalCustomerCharges=request.qLoads.TotalCustomerCharges>
        <cfset session.AllInfo.TotalCustomerCharges=request.qLoads.TotalCustomerCharges>
        <cfset TotalCarrierCharges=request.qLoads.TotalCarrierCharges>
        <cfset MaxCarrierRate=request.qLoads.MaxCarrierRate>
        <cfset TotalDirectCost=request.qLoads.TotalDirectCost>
        <cfset session.AllInfo.TotalCarrierCharges=request.qLoads.TotalCarrierCharges>
        <cfset dispatchNotes=request.qLoads.NEWDISPATCHNOTES>
        <cfset NewcustomerID=request.qLoads.PAYERID>
        <cfset session.AllInfo.NewcustomerID=request.qLoads.PAYERID>
        <cfif  NOT ( structkeyexists(url,"loadToBeCopied")  and len(trim(url.loadToBeCopied)) gt 1 ) OR (( structkeyexists(url,"loadToBeCopied")  and len(trim(url.loadToBeCopied)) gt 1 )  AND (request.qSystemSetupOptions1.CopyLoadCarrier EQ 1 or request.qLoads.STATUSTEXT EQ '. TEMPLATE'))>
            <cfset carrierID=request.qLoads.NEWCARRIERID>
            <cfset carrierID2_1=request.qLoads.NEWCARRIERID2>
            <cfset carrierID3_1=request.qLoads.NEWCARRIERID3>
        </cfif>
        <cfset IsPartial=request.qLoads.IsPartial>
        <cfset carrierNotes=request.qLoads.carrierNotes>
        <cfset CriticalNotes =request.qLoads.CriticalNotes>
        <cfset PricingNotes=request.qLoads.PricingNotes>
        <cfset ariveDate = request.qLoads.arriveDate>
        <cfset rdyDate = request.qLoads.readyDate>
        <cfset isExcused = request.qLoads.isExcused>
        <cfif NOT (structkeyexists(url,"loadToBeCopied") and len(trim(url.loadToBeCopied)) gt 1)>
            <cfset bookedBy = request.qLoads.bookedBy>
        </cfif>
        <cfset posttoITS = request.qLoads.posttoITS> 
        <cfset ediInvoiced = request.qLoads.ediInvoiced>
        <cfset EquipmentLength = request.qLoads.EquipmentLength>
        <cfset EquipmentWidth = request.qLoads.EquipmentWidth>
        <cfset posttoDirectFreight = request.qLoads.posttoDirectFreight> 
        <cfset SalesRep1 = request.qLoads.SalesRep1> 
        <cfset SalesRep2 = request.qLoads.SalesRep2> 
        <cfset SalesRep3 = request.qLoads.SalesRep3> 
        <cfset SalesRep1Percentage = request.qLoads.SalesRep1Percentage> 
        <cfset SalesRep2Percentage = request.qLoads.SalesRep2Percentage> 
        <cfset SalesRep3Percentage = request.qLoads.SalesRep3Percentage> 
        <cfset Dispatcher1 = request.qLoads.Dispatcher1> 
        <cfset Dispatcher2 = request.qLoads.Dispatcher2> 
        <cfset Dispatcher3 = request.qLoads.Dispatcher3> 
        <cfset Dispatcher1Percentage = request.qLoads.Dispatcher1Percentage> 
        <cfset Dispatcher2Percentage = request.qLoads.Dispatcher2Percentage> 
        <cfset Dispatcher3Percentage = request.qLoads.Dispatcher3Percentage> 
        <cfset CustomDriverPay=request.qLoads.CustomDriverPay>
        <cfset BillFromCompany=request.qLoads.BillFromCompany>
        <cfif  posttoDirectFreight EQ 1>
            <cfset postCarrierRatetoDirectFreight =  request.qLoads.postCarrierRatetoDirectFreight>
        </cfif>
        <cfif  posttoITS EQ 1>
            <cfset postCarrierRatetoITS =  request.qLoads.postCarrierRatetoITS>
        </cfif>
        <cfif posttoloadboard EQ 1>
            <cfset postCarrierRatetoloadboard =  request.qLoads.postCarrierRatetoloadboard>
        </cfif>
        <cfif posttoTranscore EQ 1>
            <cfset postCarrierRatetoTranscore =  request.qLoads.postCarrierRatetoTranscore>
        </cfif>
        <cfif postto123loadboard EQ 1>
            <cfset postCarrierRateto123LoadBoard =  request.qLoads.postCarrierRateto123LoadBoard>
        </cfif>
        <cfset postFlagStatus=request.loadBoardFlag.flag>
        <cfset emailList = request.qLoads.emailList>
        <cfif NOT (structkeyexists(url,"loadToBeCopied") and len(trim(url.loadToBeCopied)) gt 1)>
            <cfset deadHeadMiles = request.qLoads.DeadHeadMiles>
        </cfif>
        <cfif len(request.qLoads.noOfTrips)>
            <cfif structkeyexists(url,"loadToBeCopied")  and len(trim(url.loadToBeCopied)) gt 1>
                <cfset noOfTrips = 1>
            <cfelse>
                <cfset noOfTrips = request.qLoads.noOfTrips>
            </cfif>
        </cfif>
        <cfif len(request.qLoads.FF)>
            <cfset FF = request.qLoads.FF>
        </cfif>
        <cfif len(request.qLoads.EDISCAC)>
            <cfset EDISCAC = request.qLoads.EDISCAC>
        </cfif>
        <cfif len(request.qLoads.PODSignature)>
            <cfset PODSignature = request.qLoads.PODSignature>
        </cfif>
        <cfif request.qSystemSetupOptions.minimumMargin NEQ 0>
            <cfset RateApprovalNeeded = request.qLoads.RateApprovalNeeded>
        <cfelse>
            <cfset RateApprovalNeeded = 0>
        </cfif>
        <cfset MarginApproved = request.qLoads.MarginApproved>
        <cfset LastApprovedRate = request.qLoads.LastApprovedRate>
        <cfset statusText = "">
        <cfloop query="request.qLoadStatus">
            <cfif loadStatus is request.qLoadStatus.value>
                <cfset statusText = request.qLoadStatus.TEXT>
            </cfif> 

            <cfif request.qLoadStatus.Text EQ '3. DISPATCHED'>
                <cfset dispatchStatusDesc =  request.qLoadStatus.StatusDescription>
                <cfset dispatchStatusID =  request.qLoadStatus.value>
                <cfset dispatchStatusActive =  1>
            </cfif>
        </cfloop>
        <cfif not listFindNoCase(valueList(request.qLoadStatus.Text), '3. DISPATCHED')>
            <cfset dispatchStatusActive =  0>
        </cfif>
        <cfquery name="qryGetLoadNumberAssignment" datasource="#application.dsn#">
            SELECT loadNumberAssignment FROM SystemConfig where companyid = <cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar">
        </cfquery>

        <cfif qryGetLoadNumberAssignment.loadNumberAssignment gt 0>
            <cfswitch expression="#statusText#">
                <cfcase value=". TEMPLATE">
                    <cfset variables.loadNumberAssignment=1>
                </cfcase>

                <cfcase value="0. QUOTE">
                    <cfset variables.loadNumberAssignment=2>
                </cfcase>

                <cfcase value="1. ACTIVE">
                    <cfset variables.loadNumberAssignment=3>
                </cfcase>

                <cfcase value="2. BOOKED">
                    <cfset variables.loadNumberAssignment=4>
                </cfcase>

                <cfcase value="3. DISPATCHED">
                    <cfset variables.loadNumberAssignment=5>
                </cfcase>

                <cfcase value="4. LOADED/UNLOADED">
                    <cfset variables.loadNumberAssignment=6>
                </cfcase>

                <cfcase value="5. DELIVERED">
                    <cfset variables.loadNumberAssignment=7>
                </cfcase>

                <cfcase value="6. POD">
                    <cfset variables.loadNumberAssignment=8>
                </cfcase>

                <cfcase value="7. INVOICE">
                    <cfset variables.loadNumberAssignment=9>
                </cfcase>

                <cfcase value="7.1 PAID">
                    <cfset variables.loadNumberAssignment=10>
                </cfcase>

                <cfcase value="8. COMPLETED">
                    <cfset variables.loadNumberAssignment=11>
                </cfcase>

                <cfcase value="9. Cancelled">
                    <cfset variables.loadNumberAssignment=12>
                </cfcase>

                <cfdefaultcase> 
                    <cfset variables.loadNumberAssignment=13>
                </cfdefaultcase> 
            </cfswitch>
        </cfif>

        <cfif variables.loadNumberAssignment gte qryGetLoadNumberAssignment.loadNumberAssignment>
            <cfset Invoicenumber=request.qLoads.invoiceNumber>
        <cfelse>
            <cfset Invoicenumber=0>
        </cfif>

        <cfif val(request.qLoads.CarrierInvoiceNumber) GT 0 >
            <cfset CarrierInvoiceNumber = request.qLoads.CarrierInvoiceNumber >
        </cfif>

        <cfif len(carrierID) gt 1>
            <cfquery  name="request.qoffices"  dbtype="query">
                select CarrierOfficeID,location from request.qoffices  where location <> '' and carrierID=<cfqueryparam value="#carrierID#" cfsqltype="cf_sql_varchar">
                ORDER BY Location ASC
            </cfquery>
        </cfif>

        <cfset carrierIDNew=request.qLoads.NEWCARRIERID>
        <cfset session.AllInfo.carrierID=request.qLoads.NEWCARRIERID>
        <cfset customerPO=request.qLoads.CUSTOMERPONO>
        <cfset session.AllInfo.customerPO=request.qLoads.CUSTOMERPONO>
        <cfset stofficeid = request.qLoads.NEWofficeID>
        <cfset BOLNum=request.qLoads.BOLNum>
        <cfset request.ShipperStop = request.qLoads>
        <cfinvoke component="#variables.objloadGateway#" method="getLoadStopInfo" StopNo="0" LoadType="1" loadID="#loadID#" returnvariable="request.LoadStopInfoShipper" />
        <cfset ShipCustomerStopName=request.ShipperStop.ShipperStopName>
        <cfset shipperCustomerID=request.ShipperStop.shipperCustomerID>
        <cfset shiplocation=trim(request.ShipperStop.shipperLocation)>
        <cfset session.AllInfo.shiplocation=trim(request.ShipperStop.shipperLocation)>
        <cfset shipcity=request.ShipperStop.ShipperCity>
        <cfset shipstate1=request.ShipperStop.shipperState>
        <cfset shipzipcode=request.ShipperStop.shipperPostalcode>
        <cfset shipcontactPerson=request.ShipperStop.shipperContactPerson>
        <cfset session.AllInfo.shipcontactPerson=request.ShipperStop.shipperContactPerson>
        <cfset shipPhone=request.ShipperStop.shipperPhone>
        <cfset shipPhoneExt=request.ShipperStop.shipperPhoneExt>
        <cfset session.AllInfo.shipPhone=request.ShipperStop.shipperPhone>
        <cfset shipfax=request.ShipperStop.shipperFax>
        <cfset session.AllInfo.shipfax=request.ShipperStop.shipperFax>
        <cfset shipemail=request.ShipperStop.shipperemailId>
        <cfset shipPickupNo=request.ShipperStop.ShipperReleaseNo>
        <cfset shipperTimeZone=request.ShipperStop.shipperTimeZone>
        
        <cfset session.AllInfo.shipPickupNo=request.ShipperStop.ShipperReleaseNo>
        
        <cfif NOT ( structkeyexists(url,"loadToBeCopied")  and len(trim(url.loadToBeCopied)) gt 1 ) OR (( structkeyexists(url,"loadToBeCopied")  and len(trim(url.loadToBeCopied)) gt 1 )  AND (request.qSystemSetupOptions1.CopyLoadDeliveryPickupDates EQ 1 OR request.qLoads.STATUSTEXT EQ '. TEMPLATE'))>
            <cfif  request.LoadStopInfoShipper.StopDate NEQ "01/01/1900">
                <cfset shippickupDate=request.LoadStopInfoShipper.StopDate>
            </cfif>
            <cfset ShippickupDateMultiple=request.LoadStopInfoShipper.MultipleDates>
            <cfset session.AllInfo.shippickupDate=request.LoadStopInfoShipper.StopDate>
            <cfset shippickupTime=request.LoadStopInfoShipper.StopTime>
            <cfset ShipperStopDateQ=request.LoadStopInfoShipper.LoadStopsStopDateQ>           
        <cfelse>
            <cfset session.AllInfo.shippickupDate="">
        </cfif>
        <cfif NOT (structkeyexists(url,"loadToBeCopied") and len(trim(url.loadToBeCopied)) gt 1)>
            <cfset userDef1 = request.LoadStopInfoShipper.userDef1>
            <cfset userDef2 = request.LoadStopInfoShipper.userDef2>
            <cfset userDef3 = request.LoadStopInfoShipper.userDef3>
            <cfset userDef4 = request.LoadStopInfoShipper.userDef4>
            <cfset userDef5 = request.LoadStopInfoShipper.userDef5>
            <cfset userDef6 = request.LoadStopInfoShipper.userDef6>
            <cfset LateStop=request.ShipperStop.LateStop>
            <cfif len(trim(request.LoadStopInfoShipper.DriverTimeIn))>
                <cfset shiptimeIn=request.LoadStopInfoShipper.DriverTimeIn>
            <cfelse>
                <cfset shiptimeIn=request.LoadStopInfoShipper.TimeIn>
            </cfif>
            <cfif len(trim(request.LoadStopInfoShipper.DriverTimeOut))>
                <cfset shiptimeOut=request.LoadStopInfoShipper.DriverTimeOut>
            <cfelse>
                <cfset shiptimeOut=request.LoadStopInfoShipper.TimeOut>
            </cfif>
        </cfif>
        <cfinvoke component="#variables.objloadGateway#" method="getPayerStop" stopID="#request.LoadStopInfoShipper.loadstopid#" returnvariable="request.shipIsPayer" />

        <cfif request.shipIsPayer.recordcount>
            <cfset shipIsPayer = request.shipIsPayer.IsPayer>
        <cfelse>
            <cfset shipIsPayer = 0>
        </cfif>

        <cfset shipBlind=request.ShipperStop.ShipperBlind>
        <cfset shipInstructions=trim(request.ShipperStop.ShipperInstructions)>
        <cfset session.AllInfo.shipInstructions=trim(request.ShipperStop.ShipperInstructions)>
        <cfset Shipdirection =trim(request.ShipperStop.ShipperDirections)>
        <cfset consigneeLoadStopId=request.qLoads.consigneeLoadStopID>
        <cfset loadCustomerName = request.qLoads.CustomerName>
        <cfset request.ConsineeStop = request.qLoads>

        <cfinvoke component="#variables.objloadGateway#" method="getLoadStopInfo" StopNo="0"  LoadType="2" loadID="#loadID#" returnvariable="request.LoadStopInfoConsignee" />

        <cfset ConsineeCustomerStopName=request.ConsineeStop.consigneeStopName>
        <cfset consigneeCustomerID=request.ConsineeStop.consigneeCustomerID>
        <cfset consigneelocation=trim(request.ConsineeStop.consigneeLocation)>
        <cfset session.AllInfo.consigneelocation=trim(request.ConsineeStop.consigneeLocation)>
        <cfset consigneecity=request.ConsineeStop.consigneecity>
        <cfset consigneestate1=request.ConsineeStop.consigneeState>
        <cfset consigneezipcode=request.ConsineeStop.consigneepostalcode>
        <cfset consigneecontactPerson=request.ConsineeStop.consigneeContactPerson>
        <cfset session.AllInfo.consigneecontactPerson=request.ConsineeStop.consigneeContactPerson>
        <cfset consigneePhone=request.ConsineeStop.consigneePhone>
        <cfset consigneePhoneExt=request.ConsineeStop.consigneePhoneExt>
        <cfset session.AllInfo.consigneePhone=request.ConsineeStop.consigneePhone>
        <cfset consigneefax=request.ConsineeStop.consigneefax>
        <cfset session.AllInfo.consigneefax=request.ConsineeStop.consigneefax>
        <cfset consigneeemail=request.ConsineeStop.consigneeemailId>
        <cfset consigneePickupNo=request.ConsineeStop.consigneeReleaseNo>
        <cfset consigneeTimeZone=request.ConsineeStop.consigneeTimeZone>
        <cfset session.AllInfo.consigneePickupNo=request.ConsineeStop.consigneeReleaseNo>
        <cfif NOT ( structkeyexists(url,"loadToBeCopied")  and len(trim(url.loadToBeCopied)) gt 1 ) OR (( structkeyexists(url,"loadToBeCopied")  and len(trim(url.loadToBeCopied)) gt 1 )  AND (request.qSystemSetupOptions1.CopyLoadDeliveryPickupDates EQ 1 OR request.qLoads.STATUSTEXT EQ '. TEMPLATE'))>
            <cfif  request.LoadStopInfoConsignee.StopDate NEQ "01/01/1900">
                <cfset ConsigneepickupDate=request.LoadStopInfoConsignee.StopDate>
            </cfif>
            <cfset session.AllInfo.consigneepickupDate=request.LoadStopInfoConsignee.StopDate>
            <cfset consigneepickupTime=request.LoadStopInfoConsignee.StopTime>
            <cfset consigneeStopdateQ=request.LoadStopInfoConsignee.LoadStopsStopDateQ>
        <cfelse>
            <cfset session.AllInfo.consigneepickupDate="">
        </cfif>
        <cfif NOT (structkeyexists(url,"loadToBeCopied") and len(trim(url.loadToBeCopied)) gt 1)>
            <cfif len(trim(request.LoadStopInfoConsignee.DriverTimeIn))>
                <cfset consigneetimeIn=request.LoadStopInfoConsignee.DriverTimeIn>
            <cfelse>
                <cfset consigneetimeIn=request.LoadStopInfoConsignee.TimeIn>
            </cfif>
            <cfif len(trim(request.LoadStopInfoConsignee.DriverTimeOut))>
                <cfset consigneetimeOut=request.LoadStopInfoConsignee.DriverTimeOut>
            <cfelse>
                <cfset consigneetimeOut=request.LoadStopInfoConsignee.TimeOut>
            </cfif>
        </cfif>
        <cfinvoke component="#variables.objloadGateway#" method="getPayerStop" stopID="#request.LoadStopInfoConsignee.loadstopid#" returnvariable="request.ConsigneeIsPayer" />

        <cfif request.ConsigneeIsPayer.recordcount>
            <cfset consigneeIsPayer = request.ConsigneeIsPayer.IsPayer>
        <cfelse>
            <cfset consigneeIsPayer = 0>
        </cfif>

        <cfset ConsBlind=request.ConsineeStop.consigneeBlind>
        <cfset consigneeInstructions=trim(request.ConsineeStop.consigneeInstructions)>
        <cfset session.AllInfo.consigneeInstructions=trim(request.ConsineeStop.consigneeInstructions)>
        <cfset consigneedirection=trim(request.ConsineeStop.consigneeDirections)>
        <cfif NOT (structkeyexists(url,"loadToBeCopied") and len(trim(url.loadToBeCopied)) gt 1)>
            <cfset bookedwith1=request.ConsineeStop.consigneeBookedWith>
        </cfif>
        <cfset session.AllInfo.bookedwith1 = request.ConsineeStop.consigneeBookedWith>
        <cfset equipment1=request.ConsineeStop.ConsigneeEquipmentId>
        <cfset equipmentTrailer=request.ConsineeStop.equipmentTrailer>
        <cfset session.AllInfo.equipment1=request.ConsineeStop.ConsigneeEquipmentId>
        <cfif NOT (structkeyexists(url,"loadToBeCopied") and len(trim(url.loadToBeCopied)) gt 1)>
            <cfset driver=request.ConsineeStop.consigneeDriverName>
            <cfset driver2=request.ConsineeStop.consigneeDriverName2>
            <cfset driverCell=request.ConsineeStop.consigneeDRIVERCELL>
            <cfset truckNo=request.ConsineeStop.consigneeTRUCKNO>
            <cfset TrailerNo=request.ConsineeStop.consigneeTRAILORNO>
            <cfset refNo=request.ConsineeStop.consigneeREFNO>
            <cfset milse=request.ConsineeStop.consigneeMILES>
            <cfset secDriverCell=request.ConsineeStop.consigneeDriverCell2>
            <cfset thirdDriverCell=request.ConsineeStop.consigneeDriverCell3>
        </cfif>
        <cfset editid=loadID>
        <cfset temperature=request.ConsineeStop.temperature>
        <cfset temperaturescale=request.ConsineeStop.temperaturescale>
        <cfset CustomDriverPayFlatRate=request.ConsineeStop.CustomDriverPayFlatRate>
        <cfset CustomDriverPayFlatRate2=request.ConsineeStop.CustomDriverPayFlatRate2>
        <cfset CustomDriverPayFlatRate3=request.ConsineeStop.CustomDriverPayFlatRate3>
        <cfset CustomDriverPayPercentage=request.ConsineeStop.CustomDriverPayPercentage>
        <cfset CustomDriverPayPercentage2=request.ConsineeStop.CustomDriverPayPercentage2>
        <cfset CustomDriverPayPercentage3=request.ConsineeStop.CustomDriverPayPercentage3>
        <cfset CustomDriverPayOption=request.ConsineeStop.CustomDriverPayOption>
        <cfset CustomDriverPayOption2=request.ConsineeStop.CustomDriverPayOption2>
        <cfset CustomDriverPayOption3=request.ConsineeStop.CustomDriverPayOption3>
    </cfif>
    
    <!--- currency --->
    <cfif structkeyexists(request,"qLoads")>
        <cfif Len(request.qLoads.CarrierCurrency)>
            <cfset carrierCurrency = request.qLoads.CarrierCurrency>
        <cfelse>
            <cfset carrierCurrency = request.qSystemSetupOptions.DefaultSystemCurrency>     
        </cfif>
        
        <cfif Len(request.qLoads.CustomerCurrency)>
            <cfset customerCurrency = request.qLoads.CustomerCurrency>
        <cfelse>
            <cfset customerCurrency = request.qSystemSetupOptions.DefaultSystemCurrency>
        </cfif>
    <cfelse>
        <cfset customerCurrency = request.qSystemSetupOptions.DefaultSystemCurrency>
        <cfset carrierCurrency = request.qSystemSetupOptions.DefaultSystemCurrency>
    </cfif>
        
    <cfif ShipCustomerStopName neq "" or shiplocation neq "" or shipcity neq "" or (shipstate1 neq 0 AND shipstate1 neq "") or shipzipcode neq "" or shipcontactPerson neq "" or shipPhone neq "" or shipfax neq "" or shipemail neq "" or shipPickupNo neq "" or shippickupDate neq "" or shippickupTime neq "" or shiptimeIn neq "" or shiptimeOut neq "" or shipInstructions neq "" or Shipdirection neq "">
        <cfset variables.flagstatus=1>
    </cfif>

    <cfif ConsineeCustomerStopName neq "" or consigneelocation neq "" or consigneecity neq "" or (consigneestate1 neq 0 AND consigneestate1 neq "") or consigneezipcode neq "" or consigneecontactPerson neq "" or consigneePhone neq "" or consigneefax neq "" or consigneeemail neq "" or consigneePickupNo neq "" or consigneepickupDate neq "" or consigneepickupTime neq "" or consigneetimeIn neq "" or consigneetimeOut neq "" or consigneeInstructions neq "" or consigneedirection neq "">
        <cfset variables.flagstatusConsignee=1>
    </cfif>

    <cfif request.qSystemSetupOptions.freightBroker EQ 2 AND structkeyexists(request,"qLoads") AND  structkeyexists(request.qLoads,"Iscarrier") AND request.qLoads.Iscarrier EQ 1>
        <cfset variables.freightBroker = "Carrier">
        <cfset variables.freightBrokerShortForm = "Carr">
        <cfset variables.freightBrokerReport = "Carrier">
        <cfset variables.carrierDispatch = 'Rate Con'>
        <cfset variables.rateCon = 'Rate Con'>
    <cfelseif request.qSystemSetupOptions.freightBroker EQ 2 AND structkeyexists(request,"qLoads")  AND structkeyexists(request.qLoads,"Iscarrier") AND  
    (request.qLoads.Iscarrier EQ 0  OR request.qLoads.Iscarrier EQ "")>
        <cfset variables.freightBroker = "Driver">
        <cfset variables.freightBrokerShortForm = "Driv">
        <cfset variables.freightBrokerReport = "Dispatch">
        <cfset variables.carrierDispatch = 'Dispatch'>
        <cfset variables.rateCon = 'Dispatch Report'>
    </cfif>

    <cfif request.qSystemSetupOptions.dispatch EQ 1>
        <cfset variables.rateCon = 'Dispatch Report'>
        <cfif structkeyexists(request,"qLoads") AND structkeyexists(request.qLoads,"LoadID") AND len(trim(request.qLoads.LoadID))>
            <cfquery name="qChkCarrierDispatchFee" datasource="#application.dsn#">
                SELECT COUNT(LS.LoadStopID) AS CarrCount FROM LoadStops LS 
                INNER JOIN Carriers C ON C.CarrierID = LS.NewCarrierID
                WHERE LS.LoadID = <cfqueryparam value="#request.qLoads.LoadID#" cfsqltype="cf_sql_varchar">
                AND ISNULL(C.IsCarrier,0) = 1
                AND ISNULL(C.DispatchFee,0) = 0
            </cfquery>
            <cfif qChkCarrierDispatchFee.CarrCount NEQ 0>
                <cfset variables.rateCon = 'Rate Con'>
            </cfif>
        </cfif>
    </cfif>
    <script type="text/javascript">
        var prevStatus = ''
        $(document).ready(function(){
            prevStatus = $("##loadStatus option:selected").text().trim();
            setStopValue();
            var loadidExists='<cfoutput>#loadID#</cfoutput>';
            var shipperValue='<cfoutput>#clean_javascript_data(ShipCustomerStopName)#</cfoutput>';
            var shiplocation='<cfoutput>#clean_javascript_data(shiplocation)#</cfoutput>';
            var shipcity='<cfoutput>#clean_javascript_data(shipcity)#</cfoutput>';
            var shipstate1='<cfoutput>#clean_javascript_data(shipstate1)#</cfoutput>';
            var shipzipcode='<cfoutput>#clean_javascript_data(shipzipcode)#</cfoutput>';
            var shipcontactPerson='<cfoutput>#clean_javascript_data(shipcontactPerson)#</cfoutput>';
            var shipPhone='<cfoutput>#clean_javascript_data(shipPhone)#</cfoutput>';
            var shipfax='<cfoutput>#clean_javascript_data(shipfax)#</cfoutput>';
            var shipemail='<cfoutput>#clean_javascript_data(shipemail)#</cfoutput>';
            var shipPickupNo='<cfoutput>#clean_javascript_data(shipPickupNo)#</cfoutput>';
            var shippickupDate='<cfoutput>#clean_javascript_data(shippickupDate)#</cfoutput>';
            var shippickupTime='<cfoutput>#clean_javascript_data(shippickupTime)#</cfoutput>';
            var shipperStopDateQ='<cfoutput>#clean_javascript_data(shipperStopDateQ)#</cfoutput>';
            var shiptimeOut='<cfoutput>#clean_javascript_data(shiptimeOut)#</cfoutput>';
            var shiptimeIn='<cfoutput>#clean_javascript_data(shiptimeIn)#</cfoutput>';
            var shipInstructions="<cfoutput>#clean_javascript_data(shipInstructions)#</cfoutput>";
            var Shipdirection='<cfoutput>#clean_javascript_data(Shipdirection)#</cfoutput>';
            var consineeValue='<cfoutput>#clean_javascript_data(ConsineeCustomerStopName)#</cfoutput>';
            var consigneelocation='<cfoutput>#clean_javascript_data(consigneelocation)#</cfoutput>';
            var consigneecity='<cfoutput>#clean_javascript_data(consigneecity)#</cfoutput>';
            var consigneestate1='<cfoutput>#clean_javascript_data(consigneestate1)#</cfoutput>';
            var consigneezipcode='<cfoutput>#clean_javascript_data(consigneezipcode)#</cfoutput>';
            var consigneecontactPerson='<cfoutput>#clean_javascript_data(consigneecontactPerson)#</cfoutput>';
            var consigneePhone='<cfoutput>#clean_javascript_data(consigneePhone)#</cfoutput>';
            var consigneefax='<cfoutput>#clean_javascript_data(consigneefax)#</cfoutput>';
            var consigneeemail='<cfoutput>#clean_javascript_data(consigneeemail)#</cfoutput>';
            var consigneePickupNo='<cfoutput>#clean_javascript_data(consigneePickupNo)#</cfoutput>';
            var consigneetimeIn='<cfoutput>#clean_javascript_data(consigneetimeIn)#</cfoutput>';
            var consigneetimeOut='<cfoutput>#clean_javascript_data(consigneetimeOut)#</cfoutput>';
            var consigneepickupTime='<cfoutput>#clean_javascript_data(consigneepickupTime)#</cfoutput>';
            var consigneepickupDate='<cfoutput>#clean_javascript_data(consigneepickupDate)#</cfoutput>';
            var consigneeStopDateQ='<cfoutput>#clean_javascript_data(consigneeStopDateQ)#</cfoutput>';
            var consigneeInstructions='<cfoutput>#clean_javascript_data(consigneeInstructions)#</cfoutput>';
            var consigneedirection='<cfoutput>#clean_javascript_data(consigneedirection)#</cfoutput>';

            if(loadidExists !=""){
                if (shipstate1=='<![CDATA[0]]>'){
                    shipstate1='<![CDATA[]]>';
                }
                if(shipperValue !="<![CDATA[]]>" || shiplocation !="<![CDATA[]]>" || shipcity !="<![CDATA[]]>" || shipstate1 !='<![CDATA[]]>' || shipzipcode !="<![CDATA[]]>" || shipPhone !="<![CDATA[]]>" || shipfax !="<![CDATA[]]>" || shipemail !="<![CDATA[]]>" || shipPickupNo !="<![CDATA[]]>" || shippickupDate !="<![CDATA[]]>" || shippickupTime !="<![CDATA[]]>" || shiptimeIn !="<![CDATA[]]>" || shiptimeOut !="<![CDATA[]]>" || shipInstructions!="<![CDATA[]]>"){
                    $(".InfoShipping1").show();
                }else{
                    $(".InfoShipping1").hide();
                }
                if(consineeValue !="<![CDATA[]]>" || consigneelocation !="<![CDATA[]]>" || consigneecity !="<![CDATA[]]>" || consigneestate1 !="<![CDATA[]]>" || consigneezipcode !="<![CDATA[]]>" || consigneecontactPerson !="<![CDATA[]]>" || consigneePhone !="<![CDATA[]]>" || consigneefax !="<![CDATA[]]>" || consigneeemail !="<![CDATA[]]>" || consigneePickupNo !="<![CDATA[]]>" || consigneetimeIn !="<![CDATA[]]>" || consigneetimeOut !="<![CDATA[]]>" || consigneetimeOut !="<![CDATA[]]>" || consigneepickupTime !="<![CDATA[]]>" || consigneepickupDate !="<![CDATA[]]>" || consigneeInstructions !="<![CDATA[]]>"|| consigneedirection!="<![CDATA[]]>"){
                    $(".InfoConsinee1").show();
                }else{
                    $(".InfoConsinee1").hide();
                }
            }
        });

        function changeShipperConsigneeNote(){
            var onChangeFlagStatusVal = $("##loadStatus option:selected").data('statustext').trim();
            var onChangeFlagStatusDesc = $("##loadStatus option:selected").text().trim();
            var dataCode = '';
            if(onChangeFlagStatusVal == '4. LOADED/UNLOADED' || onChangeFlagStatusVal == '4.1 ARRIVED' || onChangeFlagStatusVal == '5. DELIVERED'){
                var dataCode = '-'+$('##shipperConsignee option:selected').data('code');
            }
            $("##dispatchNotes").prepend(clock()+' - '+ $('##Loggedin_Person').val()+ " >" +' Status changed to '+onChangeFlagStatusDesc+dataCode+'\n');
        }
        var initialization=false;
        function changeValueStatus(){
            var lockoverride = $("##loadStatus").attr('data-lock-override');
            if(lockoverride==1){
                var dispText = 'Load Status Override from ' + prevStatus;
            }
            else{
                var dispText = 'Status changed'
            }
            if(initialization==true){
                if($('##LoadNumberAutoIncrement').val().trim() == 1){
                    var onChangeFlagStatusVal = $("##loadStatus option:selected").data('statustext').trim();
                    var onChangeFlagStatusDesc = $("##loadStatus option:selected").text().trim();        
                    var status = $("##loadStatus option:selected").val();
                    var dataCode = '';
                    if($('##shipperConsignee').length && (onChangeFlagStatusVal == '4. LOADED/UNLOADED' || onChangeFlagStatusVal == '4.1 ARRIVED' || onChangeFlagStatusVal == '5. DELIVERED')){
                        var dataCode = '-'+$('##shipperConsignee option:selected').data('code');
                    }
                    if(onChangeFlagStatusVal != "9. Cancelled" && onChangeFlagStatusVal != "9.5 do not use"){
                        <cfif structKeyExists(url,"loadid") AND url.loadid NEQ "">

                            var strDispatch = clock()+' - '+ $('##Loggedin_Person').val()+ '>' +' '+dispText+' to '+onChangeFlagStatusDesc+dataCode+'\n';
                            if( $('##oldStatus').val().trim() != "" &&  
                            ($('##oldStatus').val().trim() == "0. QUOTE"  ||  $('##oldStatus').val().trim() == "1. ACTIVE"  ||  $('##oldStatus').val().trim() == ". TEMPLATE" )
                            && (onChangeFlagStatusVal != "0. QUOTE" ||  onChangeFlagStatusVal != "1. ACTIVE" || onChangeFlagStatusVal != ". TEMPLATE"  || onChangeFlagStatusVal !="9. Cancelled" || onChangeFlagStatusVal !="9.5 do not use")
                            ){

                                var frieghtBrokerStatus = document.getElementById('frieghtBroker').value;
                                var carrierId = document.getElementById('carrierID').value;

                                $.ajax({
                                    url: "../gateways/loadgateway.cfc?method=ChangeLoadNumber", 
                                    data:{dsn:'#Application.dsn#',adminUserName:'#session.adminUserName#',loadid:'#url.loadid#',StatusTypeID:status,StatusText:onChangeFlagStatusVal,fBStatus:frieghtBrokerStatus,carrierId:carrierId,CompanyID:'#session.CompanyID#'},
                                    success: function(data){
                                        console.log(data);
                                        if(data >  0){
                                            var oldLoadNumber = $('##LoadNumber').val();
                                            $('##load input[name="loadnumber"]').val(data);
                                            $('##loadManualNo').val(data);
                                            $("##HeaderLoadNumber").text("Load##"+data);
                                            $("##dispatchNotes").prepend(clock()+' - '+ $('##Loggedin_Person').val()+ " >" +' - Load number changed from '+oldLoadNumber + ' to '+data+'\n');
                                            $("##loadManualNo").trigger("onblur");
                                        }                                       
                                    },
                                    error: function(ErrorMsg){
                                       console.log("Error"); 
                                    }
                                });
                            }
                        </cfif>
                    }
                    if(($('##StatusDispatchNotesToShowHidden').val())=='1'){
                        var onChangeFlagStatusVal = $("##loadStatus option:selected").data('statustext');
                        onChangeFlagStatusVal=$.trim(onChangeFlagStatusVal);
                        var dataCode = '';

                        if($('##shipperConsignee').length && (onChangeFlagStatusVal == '4. LOADED/UNLOADED' || onChangeFlagStatusVal == '4.1 ARRIVED' || onChangeFlagStatusVal == '5. DELIVERED')){
                            var dataCode = '-'+$('##shipperConsignee option:selected').data('code');
                        }
                        $("##dispatchNotes").prepend(clock()+' - '+ $('##Loggedin_Person').val()+ " >" +' '+dispText+' to '+onChangeFlagStatusDesc+dataCode+'\n');
                    }
 
                }else{
                    if(($('##StatusDispatchNotesToShowHidden').val())=='1'){
                        var onChangeFlagStatusVal = $("##loadStatus option:selected").data('statustext');
                        onChangeFlagStatusVal=$.trim(onChangeFlagStatusVal);
                        var onChangeFlagStatusDesc = $("##loadStatus option:selected").text().trim();
                        var dataCode = '';
                        if($('##shipperConsignee').length && (onChangeFlagStatusVal == '4. LOADED/UNLOADED' || onChangeFlagStatusVal == '4.1 ARRIVED' || onChangeFlagStatusVal == '5. DELIVERED')){
                            var dataCode = '-'+$('##shipperConsignee option:selected').data('code');
                        }
                        $("##dispatchNotes").prepend(clock()+' - '+ $('##Loggedin_Person').val()+ " >" +' '+dispText+' to '+onChangeFlagStatusDesc+dataCode+'\n');
                    }
                }               
                prevStatus = onChangeFlagStatusDesc;
                
            } else{
                initialization=true;
            }
        }

        function popitup(url) {
            newwindow=window.open(url,'Map','height=600,width=800');
            if (window.focus) {newwindow.focus()}
            return false;
        }
        
        function changeQuantityWithtype(ele,stop){
            if($(ele).find('option:selected').text()==='FSC M(FUEL SURCHARGE MILES)'){
                var mileValue=$('##milse'+stop).val();
                $(ele).parents('tr:first').find('input[name*=qty]').val(mileValue);
            }
        }

        function changeQuantityWithValue(ele, stop){
            var mileValue = $(ele).val();
            $.each($('.typeSelect'+stop).find('option:selected'), function(){
                if($(this).html()== 'FSC M(FUEL SURCHARGE MILES)'){
                    $(this).parents('tr:first').find('input[name*=qty]').val(mileValue);
                }
            });
        }

        function changeQuantity(id,milevalue,type){
            var itemno = id.replace("milse","");
            var fsctext = "milse";
            for(i=1;i<=7;i++){
                try {
                    var index = document.getElementById(type+i+''+itemno).selectedIndex;
                }
                catch(e){
                    type='unit';
                    try{
                    var unittype = document.getElementById(type+i+''+itemno).options[index].text;
                    }catch(e){}
                }
                try{
                    if(unittype.indexOf("FSC Mxxx") > -1){
                        document.getElementById('qty'+i+''+itemno).value = milevalue;
                    }
                }
                catch(e) {
                }
            }
            CalculateTotal('#Application.dsn#');
        }

        function autoloaddescription(self, loadnumber, itemRowNo, dsn) {
            var unitId = self.value;
            var attrname = $(self).attr('name');
            attrname = attrname.replace('unit','');
            
            $.ajax({
                type    : 'POST',
                url     : "../gateways/unitgateway.cfc?method=getloadUnitsForAutoLoading",
                data    : {UnitID : unitId, dsn : dsn, CompanyID:'#session.CompanyID#'},
                success :function(unit){
                    $('[name=description'+attrname+']').val(JSON.parse(unit).UNITCODE);

                    <cfif request.qSystemSetupOptions.UseDirectCost>
                        var paymentAdvance = JSON.parse(unit).PAYMENTADVANCE;
                        $('[name=directCost'+attrname+']').val('$0.00');
                        if(paymentAdvance==1){
                           $('[name=directCost'+attrname+']').attr('readonly', true); 
                           $('[name=directCost'+attrname+']').css('background-color', '##e3e3e3'); 
                        }
                        else{
                           $('[name=directCost'+attrname+']').attr('readonly', false); 
                           $('[name=directCost'+attrname+']').css('background-color', '##FFFFFF'); 
                        }
                    </cfif>

                }
            });
        }



            function ConfirmMessage(index,stopno){
                if(stopno !=0){
                    index=stopno+"_"+index;
                }
                else{
                    index="_"+index;
                }
                percentagedata=$('##CarrierPer'+index).val();
                percentagedata=percentagedata.replace("%", "");
                if(percentagedata.indexOf("%")==-1){
                    if(percentagedata<1){
                        percentagedata=percentagedata*100;
                    }
                    $('##CarrierPer'+index).val(percentagedata+"%");
                }
                if(percentagedata.indexOf("%")>-1){
                    $('##CarrierPer'+index).val(percentagedata+"%");
                }
                data = $('##CarrierRate'+index).val();
                data=data.replace("$", "");
                if(parseFloat(data)>0){
                    if (confirm("Do you want to set #variables.freightBroker# rate to 0 ?")) {
                        $('##CarrierRate'+index).val('$0.00');
                    }
                }
                CalculateTotal('#Application.dsn#');
            }

            function setStopValue(){
                var shownStopArray = [];
                var nonShownStopArray = [];
                for(i=2;i<=$('##totalStop').val();i++){
                    ($('##stop'+i).css('display')=="block" ? shownStopArray.push(i):nonShownStopArray.push(i));
                    $('##stop'+i+'h2').text('Stop '+i);
                }
                $('##shownStopArray').val(shownStopArray);
                $('##nonShownStopArray').val(nonShownStopArray);
                var c = ''
                $.each(shownStopArray,function(index, value){
                    var index = index+2;
                    c = c+'<li><a href="##StopNo'+value+'">##'+index+'</a></li>';
                    $('##StopNo'+value+' h2').html('Stop '+index);
                    $('##tabs'+value+' ul li:eq(0) a').html('Stop '+index);
                })
                var c = '<li><a href="##StopNo1">##1</a></li>'+c
                for(j=0;j<=shownStopArray.length;j++){
                    $('##ulStopNo1').html(c);
                    $('##ulStopNo'+shownStopArray[j]).html(c);
                    $('.load-link').html(c);
                }

                for(g=0;g<=shownStopArray.length;g++){
                    if(g!=shownStopArray.length){
                        k = g+1
                        //$('##stop'+k+' .green-btn[value="Add Stop"]').hide();
                    }
                    if(shownStopArray.length != 0){
                        //$('##tabs1 .green-btn[value="Add Stop"]').hide();
                    }
                }
            }


        function CarrierContactAutoComplete(){
            $('.CarrierContactAuto').each(function(i, tag) {
                var carrID = $( this ).data( "carrid" );
                var id = $(this).closest('div').find('[id^=CarrierContactID]').attr('id').replace("CarrierContactID", "");
                $(tag).autocomplete({
                    multiple: false,
                    width: 450,
                    scroll: true,
                    scrollHeight: 300,
                    cacheLength: 1,
                    highlight: false,
                    dataType: "json",
                    minLength:0,
                    autoFocus: true,
                    source: 'searchCarrierContactAutoFill.cfm?carrierID='+carrID+'&type=contact',
                    select: function(e, ui) { 
                        $(this).val(ui.item.ContactPerson);
                        $('##CarrierContactID'+id).val(ui.item.CarrierContactID);
                        $(this).closest('div').find('[name^=CarrierEmailID]').val(ui.item.email);
                        $(this).closest('div').find('[name^=CarrierPhoneNo]').val(ui.item.phoneno);
                        $(this).closest('div').find('[name^=CarrierPhoneNoExt]').val(ui.item.phonenoext);
                        $(this).closest('div').find('[name^=CarrierFax]').val(ui.item.fax);
                        $(this).closest('div').find('[name^=CarrierFaxExt]').val(ui.item.faxext);
                        $(this).closest('div').find('[name^=CarrierFax]').val(ui.item.fax);
                        $(this).closest('div').find('[name^=CarrierFaxExt]').val(ui.item.faxext);
                        $(this).closest('div').find('[name^=CarrierTollFree]').val(ui.item.tollfree);
                        $(this).closest('div').find('[name^=CarrierTollFreeExt]').val(ui.item.tollfreeext);
                        $(this).closest('div').find('[name^=CarrierCell]').val(ui.item.PersonMobileNo);
                        $(this).closest('div').find('[name^=CarrierCellExt]').val(ui.item.MobileNoExt);
                        $('##equipmentTrailer'+id).val(ui.item.EqTrailer);
                        return false;
                    },
                    focus: function( event, ui ) {
                        $(this).val(ui.item.ContactPerson);
                        $('##CarrierContactID'+id).val(ui.item.CarrierContactID);
                        return false;
                    },
                    response: function(event, ui) {
                        if(ui.content.length == 0){
                            if(confirm('There is no matching contact found. Do you like to add a new contact?')){
                                openAddNewCarrierContactPopup(id);
                            }
                            else{
                                $(this).val('');
                            }
                        }
                    },
                }).focus(function() { 
                    $(this).keydown();
                })
                $(tag).data("ui-autocomplete")._renderItem = function(ul, item) {
                    return $( "<li><b><u>Contact</u>:</b> "+ item.ContactPerson+"&nbsp;&nbsp;&nbsp;<b><u>Phone</u>:</b> "+ item.phoneno+"<br/><b><u>cell</u>:</b>" + item.PersonMobileNo+"&nbsp;&nbsp;&nbsp;<b><u>Type</u>:</b> " + item.ContactType+"<b><br/><u>Email</u>:</b>"+item.email+"</li>" )
                .appendTo( ul );
                }
            })
        }
        function DriverContactAutoComplete(stopNo){

            if($("input[name='driver"+stopNo+"']").hasClass('ui-autocomplete-input')) {
                $("input[name='driver"+stopNo+"']").autocomplete("destroy");
            }

            if($("input[name='Secdriver"+stopNo+"']").hasClass('ui-autocomplete-input')) {
                $("input[name='Secdriver"+stopNo+"']").autocomplete("destroy");
            }

            var carrID = $( "##carrierID"+stopNo ).val();
            $("input[name='driver"+stopNo+"']").each(function(i, tag) {
                $(tag).autocomplete({
                    multiple: false,
                    width: 450,
                    scroll: true,
                    scrollHeight: 300,
                    cacheLength: 1,
                    highlight: false,
                    dataType: "json",
                    minLength:0,
                    source: 'searchCarrierContactAutoFill.cfm?carrierID='+carrID+'&type=contact&contactType=Driver',
                    select: function(e, ui) { 
                        $(this).val(ui.item.ContactPerson);
                        if($.trim(ui.item.phoneno).length){
                           $("input[name='driverCell"+stopNo+"']").val(ui.item.phoneno); 
                        }
                        if($.trim(ui.item.PersonMobileNo).length){
                           $("input[name='driverCell"+stopNo+"']").val(ui.item.PersonMobileNo); 
                        }
                        else if($.trim(ui.item.phoneno).length){
                           $("input[name='driverCell"+stopNo+"']").val(ui.item.phoneno); 
                        }
                        $('##equipmentTrailer'+stopNo).val(ui.item.EqTrailer);
                        return false;
                    },
                    focus: function( event, ui ) {
                        $(this).val(ui.item.ContactPerson);
                        if($.trim(ui.item.PersonMobileNo).length){
                           $("input[name='driverCell"+stopNo+"']").val(ui.item.PersonMobileNo); 
                        }
                        else if($.trim(ui.item.phoneno).length){
                           $("input[name='driverCell"+stopNo+"']").val(ui.item.phoneno); 
                        }
                        return false;
                    },
                }).focus(function() { 
                    $(this).autocomplete('search', $(this).val());
                })
                $(tag).data("ui-autocomplete")._renderItem = function(ul, item) {
                    return $( "<li><b><u>Contact</u>:</b> "+ item.ContactPerson+"&nbsp;&nbsp;&nbsp;<b><u>Phone</u>:</b> "+ item.phoneno+"<br/><b><u>cell</u>:</b>" + item.PersonMobileNo+"&nbsp;&nbsp;&nbsp;<b><u>Type</u>:</b> " + item.ContactType+"<b><br/><u>Email</u>:</b>"+item.email+"</li>" )
                .appendTo( ul );
                }
            })
            $("input[name='Secdriver"+stopNo+"']").each(function(i, tag) {
                $(tag).autocomplete({
                    multiple: false,
                    width: 450,
                    scroll: true,
                    scrollHeight: 300,
                    cacheLength: 1,
                    highlight: false,
                    dataType: "json",
                    minLength:0,
                    source: 'searchCarrierContactAutoFill.cfm?carrierID='+carrID+'&type=contact&contactType=Driver',
                    select: function(e, ui) { 
                        $(this).val(ui.item.ContactPerson);
                        if($.trim(ui.item.phoneno).length){
                           $("input[name='secDriverCell"+stopNo+"']").val(ui.item.phoneno); 
                        }
                        else if($.trim(ui.item.PersonMobileNo).length){
                           $("input[name='secDriverCell"+stopNo+"']").val(ui.item.PersonMobileNo); 
                        }
                        $('##equipmentTrailer'+stopNo).val(ui.item.EqTrailer);
                        return false;
                    },
                    focus: function( event, ui ) {
                        $(this).val(ui.item.ContactPerson);
                        if($.trim(ui.item.phoneno).length){
                           $("input[name='secDriverCell"+stopNo+"']").val(ui.item.phoneno); 
                        }
                        else if($.trim(ui.item.PersonMobileNo).length){
                           $("input[name='secDriverCell"+stopNo+"']").val(ui.item.PersonMobileNo); 
                        }
                        return false;
                    },
                }).focus(function() { 
                    $(this).autocomplete('search', $(this).val());
                })
                $(tag).data("ui-autocomplete")._renderItem = function(ul, item) {
                    return $( "<li><b><u>Contact</u>:</b> "+ item.ContactPerson+"&nbsp;&nbsp;&nbsp;<b><u>Phone</u>:</b> "+ item.phoneno+"<br/><b><u>cell</u>:</b>" + item.PersonMobileNo+"&nbsp;&nbsp;&nbsp;<b><u>Type</u>:</b> " + item.ContactType+"<b><br/><u>Email</u>:</b>"+item.email+"</li>" )
                .appendTo( ul );
                }
            })
        }
    </script>

    <style type="text/css">
        .ui-widget, .ui-widget input, .ui-widget select, .ui-widget textarea, .ui-widget button{
            font:11px/16px Arial,Helvetica,sans-serif !important;
        }
        .typeAddress{
            color:##ccc;
            z-index:-1;
        }
        .ui-widget textarea {
            width:190px;
        }
        .carriertextbox {
            width:110px !important; float:left;
        }
        .carrierrightdiv label.carrierrightlabel {
            width:65px !important;float:left;
        }
        ##tabs1, ##tabs2, ##tabs3, ##tabs4, ##tabs5, ##tabs6, ##tabs7, ##tabs8, ##tabs9, ##tabs10 {
            width:932px;
        }
        .ui-tabs .ui-tabs-panel{
            padding:0 !important;
        }
        .white-bottom {
            background-color: white;
            border-bottom-left-radius: 4px;
            border-bottom-right-radius: 4px;
            height: 8px;
            width: 857px;
        }
        .ui-widget-content{
            border:0px !important;
        }
        .ui-corner-all, .ui-corner-bottom, .ui-corner-left, .ui-corner-bl {
            border-bottom-left-radius:0px !important;
        }
        .ui-corner-all, .ui-corner-bottom, .ui-corner-right, .ui-corner-br {
            border-bottom-right-radius:0px !important;
        }
        .form-heading-loop {
            background: none repeat scroll 0 0 ##ffffff;
            margin: 0 auto;
            padding: 0 10px;
            width: 837px;
        }
        input[type="button"],input[type="submit"] {
            font-family:Arial,Helvetica,sans-serif !important;
            font-size:11px !important;
            font-weight:bold !important;
        }
        li.ui-menu-item{
            background:##EDEEF2 !important;
            color:black !important;
        }
        li.ui-state-focus{
            background:##20358A !important;
            color:##fff  !important;
        }
        li.ui-tabs-active{
            background:##ffffff !important;
        }
        .lineBreak{
            background: none repeat scroll 0 0 ##9fcef5;
            height: 3px;
            margin-bottom: 15px;
            margin-top: 15px;
        }
        .overlay {
            display: none;
            z-index: 2;
            background: ##000;
            position: fixed;
            text-align: center;
            opacity: 0.3;
            overflow: hidden;
             width: 100%;
            height: 100%;
            top: 0;
            right: 0;
            bottom: 0;
            left: 0;
        }

        .loadOverlay {
            z-index: 2;
            background: ##000;
            position: fixed;
            text-align: center;
            opacity: 0.3;
            overflow: hidden;
             width: 100%;
            height: 100%;
            top: 0;
            right: 0;
            bottom: 0;
            left: 0;
        }

        .dispatchNotesPopup, .dispatchMailsPopup {
            position: absolute;
            z-index: 3;
            width: 400px;
            height: auto;
            background: ##dfeffc;
            color: ##000;
            top: 189.5px;
            left: 378.5px;
            display:none;
            padding: 2px;
            border:1px solid ##ccc;
            border-radius: 2px;
        }
        .dispatchNotesPopup{
            width: 600px;
            height: 350px;
            left: 300px;
            top:150px;
        }
        .dispatchNotesPopup label{
            text-align: left !important;
            font-size: 12px !important;

        }
        .modalHead {
            background: ##fff;
            background-color: ##82BBEF !important;
            border: 1px solid ##aaaaaa;
            color: ##fff;
            font-weight: bold;
            padding: 5px;
            border-radius: 2px;
            margin-bottom: 5px;
        }
        .closModal, .closdispatchMailsModal {
            float: right;
            padding: 2px;
            color: ##fff;
            cursor: pointer;
        }
        .modalBody {
            border-bottom: 1px solid ##ccc;
            width: 100%;
            text-align: center;
            padding: 20px;
        }
        .modalBody textarea {
            float: left;
            width: 90% !important;
            height: 100px;
            border: 1px solid ##b3b3b3;
            padding: 0px !important;
            margin: 0px !important;
        }
        .clear {
            clear: both;
        }
        .noteAdd, .dispatchMailsAdd {
            border: 1px solid ##999999;
            background: ##dadada url(images/ui-bg_glass_75_dadada_1x400.png) 50% 50% repeat-x;
            font-weight: normal;
            color: ##212121;
            padding: 5px 10px;
            cursor: pointer;
        }
        .modalFooter{
            padding: 10px;
        }
        .white-mid div.form-con fieldset input[type=button]{
            margin-bottom: 6px;
        }
        .calculationblock{margin-top: 17px;}
        .white-mid div.form-con fieldset label.field-textarea{height: 110px;}
        .underline{text-decoration: underline;}
        .field-textarea.carrier-field-textarea{width:280px !important;}
        ##loader{
            position: fixed;
            top:40%;
            left:30%;
            z-index: 999;
            display: none;
        }
        ##loadingmsg{
            top:50%;
            left:31%;
            position: fixed;
            z-index: 999;
            font-size: 14px;
            display: none;
        }
        .inp70px{
            width: 70px !important;
        }
        .inp18px{
            width: 18px !important;
        }
        .selContact{
            width: 280px !important;
        }
        .label45px{
            width: 42px !important;
        }
        .CarrEmail{
           width: 273px !important; 
        }
        .label40px{
            width: 40px !important;
        }
        .inp83px{
           width: 83px !important; 
        }
        .CarrierContactAuto{
            width: 225px;
        }
        .bottom-btns input[type=button]{
            background: url(images/button-bg.gif) left top repeat-x;
            border: 1px solid ##b3b3b3;
            padding: 0 10px;
            height: 20px;
            font-size: 11px;
            font-weight: bold;
            line-height: 20px;
            text-align: center;
            margin: 2px;
            color: ##4c4c4c;
            width: 140px !important;
            cursor: pointer;
        }
        .bottom-btns input{
            float: left;
            margin-right: 8px !important;
            margin-bottom: 3px !important;
        }
        .bottom-btns input.green-btn {
            background: url(images/button-bg.gif) left top repeat-x;
            border: 1px solid ##b3b3b3;
            padding: 0 10px;
            height: 20px;
            font-size: 11px;
            font-weight: bold;
            line-height: 20px;
            text-align: center;
            margin: 2px;
            color: ##599700;
            width: 125px !important;
            cursor: pointer;
        }
    </style>

    <style>
    /* The Modal (background) */
.modal {
  display: none; /* Hidden by default */
  position: fixed; /* Stay in place */
  z-index: 1; /* Sit on top */
  left: 0;
  top: 0;
  width: 100%; /* Full width */
  height: 100%; /* Full height */
  overflow: auto; /* Enable scroll if needed */
  background-color: rgb(0,0,0); /* Fallback color */
  background-color: rgba(0,0,0,0.4); /* Black w/ opacity */
}
.modal-header {
  padding: 2px 16px;
  background-color: ##5cb85c;
  color: white;
}
/* Modal Content/Box */
.modal-content {
  background-color: ##defaf9;
  margin: 15% auto; /* 15% from the top and centered */
  padding: 20px;
  border: 1px solid ##888;
  width: 30%; /* Could be more or less, depending on screen size */
  height:220px;
}
.modal-content-payment {
    background-color: ##defaf9;
    margin: 15% auto;
    padding: 0px;
    border: 1px solid ##888;
    width: 90%;
    min-height: 107px;
    position: relative;
    /* display: table; */
    /* overflow-x: auto; */
    overflow: hidden;
}
/* The Close Button */
.close {
  color: ##fff;
  float: right;
  font-size: 28px;
  font-weight: bold;
  margin-right: 7px;
  margin-top: 10px;
}

.close:hover,
.close:focus {
  color: black;
  text-decoration: none;
  cursor: pointer;
} 
##ediheading,##NewCustomerHeading,##commCustomerHeading{
  font-size: 15px;
  font-weight: bold;
  padding-top: 12px;
}
##inputcheck{
    margin-left: 12px;
    margin-top: 15px;
}

.labell{
    font-size: 13px;
    position: relative;
    margin-left: 4px;
    font-weight: bold;
}
.modalstyle{
     border-collapse: collapse;
     height: 141px;
}
.modalstyle td{
    border: 1px solid ##b0ccef;
    min-width: 118px;
    padding-left: 9px;
    padding-top: 4px;
    height: 19px;
}
.modalstyle td:nth-last-child(2) {
     border-right: 1px solid ##dddddd;
} 
.modalstyle td:nth-last-child(1) {
    padding-left: 0px;
    text-align: -webkit-center;
}

.modalstyle td:first-child {
    border: 1px solid ##b0ccef;
    min-width: 118px;
    padding-left: 9px;
    padding-top: 4px;
    height: 19px;
}
.modalstyle td:nth-last-child(2) {
    padding-left: 0px;
}
.modalstyle th{
     font-size: 13px;
     font-weight: bold;
     text-align: left;
     border: 1px solid ##96bcec;
     padding-left: 8px;
     border-top-color: white;
}
##headbakgrnd{
    background-color: ##82BBEF;
    position: initial;
    height: 38px;
    margin-top: -20px;
    width: 110%;
    margin-left: -20px;
}
.position{
     margin-left: -40px;2px;
}
##headbakgrnd2{
    background-color: ##82BBEF;
    height: 40px;
    width: 100%;
}
##tabltitle td{
    font-size: 11px;
    font-weight: bold;
    text-align: center;
    padding: 2px;
    border: black;
    border: 1px solid grey;

}
.paymenttble{
 border: 1px solid grey;
    border-collapse: collapse;
    font: normal 11px/16px Arial, Helvetica, sans-serif !important;
    width: 100%;
    height: 80px;
}
##paymentSection{
   
    position: initial;
    padding: 20px 23px;
    overflow-y: auto;
}
.sky-bg2{
        padding: 5px;
}
.head-bg3{
        width: 1%
}
.divNewCustInfo{
    margin-top: 10px;
}
.custLabelNew{
    float: left;
    width:65px;
    text-align: right;
    margin-right: 10px;
}
.divNewCustInfo .clear{
    margin-top: 10px;
}
.divNewCustInfo input{
    padding: 2px 2px 2px 2px;
    font-size: 12px;
    width:202px;
}
##commheadbakgrnd{
    background-color: ##82BBEF;
    position: initial;
    height: 38px;
    margin-top: -20px;
    width: 110%;
    margin-left: -20px;
}
.divCommisionInfo{
    margin-top: 10px;
}
.divCommisionInfo .clear{
    margin-top: 10px;
}
.divCommisionInfo input{
    padding: 2px 2px 2px 2px;
    font-size: 12px;
    width:50px;
}
.divCommisionInfo .custLabelNew{
    width:80px;
}
</style>
     <cfif structkeyexists(url,"loadid") and len(trim(url.loadid)) gt 1>
        <cfinvoke component="#variables.objloadGateway#" method="getedi204logdata" loadID="#url.loadID#" returnvariable="qgetedi204logdata" />
        <cfinvoke component="#variables.objloadGatewayNew#" method="getEDI820Data" loadID="#url.loadID#" returnvariable="qEDI820Data" />
        <cfinvoke component="#variables.objloadGateway#" method="getEdiStopDetails" loadID="#url.loadID#" returnvariable="qgetEdiStopDetails" />
        <cfinvoke component="#variables.objloadGateway#" method="getEdiReasonCodes" loadID="#url.loadID#" returnvariable="qgetEdiReasonCodes" />
        <cfinvoke component="#variables.objloadGateway#" method="getSelectedEDIStop" loadnumber="#loadnumber#" returnvariable="qgetSelectedEDIStop" />
     </cfif>  

<div id="paymentModal" class="modal">
  <div class="modal-content-payment">
    <div id="headbakgrnd2">
    <span class="close paymentclose">&times;</span>
   <div id="ediheading"> <center>EDI Payments</center></div>
   </div>
   <div id="paymentSection"> 
    <table class="paymenttble" width="100%" border="0" class="data-table" cellspacing="0" cellpadding="0" style="color:##000000;">

      <thead>
         

      <tr id="tabltitle">
          <td class="head-bg3">Load Number</td>
          <td class="head-bg3">Invoice Number</td>
          <td class="head-bg3">Monetary Amount</td>
          <td class="head-bg3">Credit/ Debit</td>
          <td class="head-bg3">Payment Format</td>
          <td class="head-bg3">Name</td>
          <td class="head-bg3">Address 1</td>
          <td class="head-bg3">Address 2</td>
          <td class="head-bg3">City</td>
          <td class="head-bg3">State</td>
          <td class="head-bg3">Zip</td>
          <td class="head-bg3">Country Code</td>
          <td class="head-bg3">Amount Of Invoice</td>
          <td class="head-bg3">Amount Paid</td>         
          <td class="head-bg3">EDI Processed</td>
          <td class="head-bg3">Receiver ID</td>
      </tr>
      </thead>
      <tbody>
      <cfif IsDefined('qEDI820Data')>
        <cfloop query="qEDI820Data">
          <tr bgcolor="##f7f7f7">                     
             <td class="sky-bg2" valign="middle" align="center">#qEDI820Data.Reference_Identification#</td>
             <td class="sky-bg2" valign="middle" align="center">#qEDI820Data.Reference_Identification#</td>
             <td class="sky-bg2" valign="middle" align="center">#qEDI820Data.Monetary_Amount#</td>
             <td class="sky-bg2" valign="middle" align="center">#qEDI820Data.Credit_Or_Debit_Flag_Code#</td> 

             <td class="sky-bg2" valign="middle" align="center">#qEDI820Data.Payment_Format_Code#</td> 
             <td class="sky-bg2" valign="middle" align="center">#qEDI820Data.Name#</td>
             <td class="sky-bg2" valign="middle" align="center">#qEDI820Data.Address_1#</td>
             <td class="sky-bg2" valign="middle" align="center">#qEDI820Data.Address_2#</td>
             <td class="sky-bg2" valign="middle" align="center">#qEDI820Data.City#</td>
             <td class="sky-bg2" valign="middle" align="center">#qEDI820Data.State#</td>
             <td class="sky-bg2" valign="middle" align="center">#qEDI820Data.Zip#</td>            
             <td class="sky-bg2" valign="middle" align="center">#qEDI820Data.Country_Code#</td>
             <td class="sky-bg2" valign="middle" align="center">#qEDI820Data.Amount_of_Invoice#</td>
             <td class="sky-bg2" valign="middle" align="center">#qEDI820Data.Amount_Paid#</td>
             <td class="sky-bg2" valign="middle" align="center">#qEDI820Data.EDI_Processed#</td>
              <td class="sky-bg2" valign="middle" align="center">#qEDI820Data.receiverID#</td>
          </tr>
        </cfloop>
        </cfif>
    </tbody>
     
</table>
 
   </div>
</div>
</div>
<div id="myModal" class="modal">
  <div class="modal-content">
    <div id="headbakgrnd">
    <span class="close ediclose">&times;</span>
   <div id="ediheading"> <center>EDI Documents Processed</center></div>
    </div>
   <cfset lstALLDocTypes ="204,990,210,212,214,820">
   <cfset lstEDIDocTypeProcessed = "">
    <div id="inputcheck">
    <table class="modalstyle">
        <tr><th class="head-bg">EDI docs</th><th class="head-bg" >Date</th><th class="head-bg">997 Receipt</th></tr>
        <cfif IsDefined('qgetedi204logdata')>
        <cfloop query = "qgetedi204logdata"> 
            <cfif qgetedi204logdata.exists eq 1 AND ListFind(lstEDIDocTypeProcessed,qgetedi204logdata.DOCTYPE) EQ 0>
                <cfset lstEDIDocTypeProcessed =lstEDIDocTypeProcessed&","&qgetedi204logdata.DOCTYPE >
               <tr><td>
            <input type="checkbox"  id="ediDoc" name="ediDoc" checked ><span class="labell"> #qgetedi204logdata.DOCTYPE#</span>
             </td>
              <td>
             <span class="labell">#dateformat(qgetedi204logdata.CreatedDate,'mm/dd/yyyy')#</span>
             </td><td><input type="radio" name="receiptradio" value="" class="position"></td></tr>
            </cfif>
        </cfloop> 
        <cfloop query = "qgetedi204logdata"> 
            <cfif qgetedi204logdata.exists eq 0 AND ListFind(lstEDIDocTypeProcessed,qgetedi204logdata.DOCTYPE) EQ 0> 
            <tr><td>           
                <input type="checkbox"  id="ediDoc" name="ediDoc"  ><span class="labell"> #qgetedi204logdata.DOCTYPE#</span>
            </td><td> &nbsp;</td><td><input type="radio" name="receiptradio" value="" class="position"></td></tr> 
               
            </cfif>
        </cfloop> 
        </cfif>
    </table>
   </div>
    </div>
</div>

<div id="ModalEDispatchPrompt" class="modal"> 
    <div class="modal-content" style="height: 100px;background-color: ##ffffff;border: solid 2px ##e8e6e6;">
        
        <div style="font-size: 15px;">
            Do you want to change the Load Status to "#dispatchStatusDesc#"?
        </div>
    
        <div style="text-align: right;margin-right: 50px;margin-top: 10px;">
            <input type="button" value="OK" class="black-btn tooltip" style="width:72px !important;height:22px;margin-top: 10px;" onclick="openRateCon(1)">          
            <input type="button" value="Cancel" class="black-btn tooltip" style="width:72px !important;height:22px;margin-top: 10px;margin-right:-24px;" onclick="openRateCon(0)">
        </div>
        <div style="margin-top: 10px;">
            <div style="float: left;margin-top: 1px;"><input type="checkbox" id="EDispatchPromptOff"></div><div>Don't ask me this anymore.</div>
        </div>
    </div>
</div>
    <div class="loadOverlay"></div>
    <div class="overlay"></div>
    <cfset local.selectedLockStatus = ''>
    <!--- Assigning the lock load status --->
    <cfloop query="request.qLoadStatus">
        <cfif not len(trim(url.loadToBeCopied)) gt 2>
            <cfif loadStatus is request.qLoadStatus.value AND url.loadToBeCopied EQ 0>
                <cfset local.selectedLockStatus = request.qLoadStatus.value>
            </cfif>
        <cfelse>
            <cfif request.qLoadStatus.text is '1. ACTIVE'>
                <cfset local.selectedLockStatus = request.qLoadStatus.value>
            </cfif>
        </cfif>
    </cfloop>

    <cfset local.lockStartFlag = false>
    <cfset local.loclList = "">

    <cfloop query="request.qLoadStatus">
        <cfif request.qSystemSetupOptions1.lockloadstatus EQ request.qLoadStatus.value>
            <cfset local.lockStartFlag = true>
        </cfif>
        <cfif local.lockStartFlag>
            <cfset local.loclList = ListAppend(local.loclList, "#request.qLoadStatus.value#")>
        </cfif>
    </cfloop>

    <cfset local.lockloadStatsFlag = false>

    <cfif not listFindNoCase(session.rightsList,'EditLockedLoad') AND local.selectedLockStatus NEQ 'none'>
        <cfset local.isInTheList = ListFindNoCase(local.loclList, local.selectedLockStatus, ",")>
        <cfif local.isInTheList>
          <cfset local.lockloadStatsFlag = true>
        </cfif>
    </cfif>

    <cfif structkeyexists(url,"loadid") and len(trim(url.loadid)) gt 1>
        <cfinvoke component="#variables.objloadGateway#" method="getloadAttachedFiles" linkedid="#url.loadID#" fileType="1" returnvariable="request.filesAttached" />
        <div class="search-panel">
        </div>
        <cfinvoke component="#variables.objloadGateway#" method="getLoadConsolidatedDetail" LoadID="#url.loadID#" returnvariable="request.loadConsolidatedDetail" />
        <cfquery name="qGetCustCons" datasource="#application.dsn#">
            SELECT ConsolidateInvoices,PushDataToProject44Api FROM Customers WHERE CustomerID = <cfqueryparam value="#request.qloads.payerid#" cfsqltype="cf_sql_varchar">
        </cfquery>
        <cfif ListContains(session.rightsList,'DeleteLoad',',')>
            <div class="delbutton" style="margin-top: -20px;margin-bottom: 15px;">
                <a href="index.cfm?event=myload&loadid=#url.loadID#&#session.URLToken#" onclick="return confirm('Are you sure to delete this load?');">  Delete</a>
            </div>
            <div class="clear"></div>
        </cfif>
        <div style="width: 932px;">
            <div style="text-align: center;width: 95%;">
                <cfquery name="qGetLoadDispatch" datasource="#application.dsn#">
                    SELECT IsEDispatched FROM Loads WHERE LoadID = <cfqueryparam value="#request.qloads.LoadID#" cfsqltype="cf_sql_varchar">
                </cfquery>
                <cfif request.qloads.IsEDispatched NEQ 0>
                    <cfinvoke component="#variables.objloadGateway#" method="getLoadLastPosition" loadId="#url.loadID#" dsn="#application.dsn#" returnvariable="request.LoadLastPosition" />
                    <cfif request.LoadLastPosition.res.recordcount>
                        <cfset locAttr = {}>
                        <cfif isJSON(request.LoadLastPosition.res.attributes)>
                            <cfset locAttr = deserializeJSON(request.LoadLastPosition.res.attributes)>
                        </cfif>
                        <cfif structKeyExists(locAttr, "city") AND structKeyExists(locAttr, "state")>
                            <a onClick="showfullmap('createFullMap.cfm','load', 'googlemap');" style="text-decoration: underline;cursor: pointer;">Driver's location is #locAttr.city#, #locAttr.state# as of <span class="showLocalTime">#DatetimeFormat(request.LoadLastPosition.res.servertime,"m/d/yyyy HH:nn")#</span></a>
                        <cfelse>
                            <cfinvoke component="#variables.objloadGateway#" method="getLocationFromLatLong"  latitude="#request.LoadLastPosition.res.latitude#" longitude="#request.LoadLastPosition.res.longitude#" returnvariable="request.LoadLastPositionFromLatLong" />
                            <a onClick="showfullmap('createFullMap.cfm','load', 'googlemap');" style="text-decoration: underline;cursor: pointer;">Driver's location is <cfif len(trim(request.LoadLastPositionFromLatLong.city))>#request.LoadLastPositionFromLatLong.city#,</cfif> <cfif len(trim(request.LoadLastPositionFromLatLong.state))>#request.LoadLastPositionFromLatLong.state#,</cfif> as of <span class="showLocalTime">#DatetimeFormat(request.LoadLastPosition.res.servertime,"m/d/yyyy HH:nn")#</span></a>
                        </cfif>
                    <cfelse>
                        <span style="color:red">No GPS Data Found.</span>
                    </cfif>
                </cfif>
            </div>
            <div style="float:right;">
                <cfif request.qSystemSetupOptions.Project44>
                    <strong>Project 44 Setup</strong>
                    <input id="PushDataToProject44Api" name="PushDataToProject44Api" type="checkbox" class="small_chk myElements" <cfif request.qLoads.PushDataToProject44Api> checked </cfif> onclick="PushDataToProject44Api()">
                </cfif>
            </div>
            <input name="dsn" type="hidden" value="#dsn#" id="dsn">
            <input name="s_empid" type="hidden" value="#session.empid#" id="s_empid">
            <input name="s_adminusername" type="hidden" value="#session.adminusername#" id="s_adminusername">
            <cfif request.qSystemSetupOptions.TurnOnConsolidatedInvoices>
                <div class="div_consInv" style="float:right;<cfif NOT qGetCustCons.ConsolidateInvoices>display:none;</cfif>">
                    <cfif request.loadConsolidatedDetail.recordcount>
                        <cfif request.loadConsolidatedDetail.status EQ 'OPEN'>
                            <input id="ConsolidatedQueueBtn" style="width:210px !important;height:22px;margin-top: -7px;margin-right: 5px;" type="button" class="black-btn tooltip" value="Remove From Consolidated Invoice" onclick="removeFromConsolidatedQueue('#url.loadid#');">
                        <cfelse>
                            <input disabled="true" style="width:210px !important;height:22px;margin-top: -7px;margin-right: 5px;" type="button" class="black-btn tooltip" value="Consolidated Invoice##: #request.loadConsolidatedDetail.ConsolidatedInvoiceNumber#">
                        </cfif>
                    <cfelse>
                        <input id="ConsolidatedQueueBtn" style="width:210px !important;height:22px;margin-top: -7px;margin-right: 5px;" type="button" class="black-btn tooltip" value="Add To Consolidated Invoice" onclick="addToConsolidatedQueue('#url.loadid#');">
                    </cfif>
                </div>
            </cfif>
        </div>
        <div class="clear"></div>

        <cfif RateApprovalNeeded EQ 1>
            <div class="msg-area" style="margin-left:10px;margin-bottom:10px">
                <span style="color:##d21f1f">
                    MINIMUM MARGIN ALERT: The rates on this load does not meet the minimum margin.<br>
                    The "ACTIVE" Load Status is locked until an Administrator approves the rates or until you edit the rate to increase the margin.
                </span>
            </div>
            <div class="clear"></div>
        </cfif>

<!---Color Change #82bbef --->
        <div class="white-con-area" style="height: 40px;background-color: ##82bbef;width: 932px;">
            <div style="float: left; min-height: 40px;width: 40%;" id="divUploadedFiles">
                <img id="missingReqAtt" style="float: left;background-color: ##fff;border-radius: 11px;margin-top: 12px;margin-left: 2px;display:none;width: 16px;" src="images/exclamation.ico" title="Required Attachments Missing">
                <cfif request.filesAttached.recunt neq 0>
                    &nbsp;<a style="display:block;font-size: 13px;padding-left: 5px;color:white;width: 131px;float: left;margin-top: 12px;" href="##" onclick="popitup('../fileupload/multipleFileupload/MultipleUpload.cfm?id=#url.loadid#&attachTo=1&user=#session.adminusername#&userFullName=#session.UserFullName#&dsn=#dsn#&attachtype=Load<cfif request.qSystemSetupOptions.TurnOnConsolidatedInvoices AND qGetCustCons.ConsolidateInvoices>&ConsolidateInvoices=1</cfif>&CompanyID=#session.CompanyID#<cfif local.lockloadStatsFlag OR (isDefined('statusText') AND NOT ListContains(session.editableStatuses,statusText,','))>&viewonly=1</cfif>')">
                    <img style="vertical-align:bottom;" src="images/attachment.png">
                    <span class="attText">View/Attach Files</span>
                    </a>
                    <cfif request.qSystemSetupOptions.showScanButton>
                       <span><input id="ScanButtonLink" style="width:57px !important;height:22px;margin-top: 10px;" type="button" class="black-btn tooltip" value="Scan" onclick="popitup('../scanfiles/scanfile.cfm?id=<cfoutput>#url.loadid#</cfoutput>'+'&user='+'<cfoutput>#session.adminusername#</cfoutput>'+'&dsn='+'<cfoutput>#application.dsn#</cfoutput>')"></span>
                    </cfif>
                <cfelse>
                    &nbsp;<a style="display:block;font-size: 13px;padding-left: 5px;color:white;float: left;margin-top: 12px;" href="##" onclick="popitup('../fileupload/multipleFileupload/MultipleUpload.cfm?id=#url.loadid#&attachTo=1&user=#session.adminusername#&userFullName=#session.UserFullName#&dsn=#dsn#&attachtype=Load<cfif request.qSystemSetupOptions.TurnOnConsolidatedInvoices AND qGetCustCons.ConsolidateInvoices>&ConsolidateInvoices=1</cfif>&CompanyID=#session.CompanyID#<cfif local.lockloadStatsFlag OR (isDefined('statusText') AND NOT ListContains(session.editableStatuses,statusText,','))>&viewonly=1</cfif>')">
                    <img style="vertical-align:bottom;" src="images/attachment.png">
                    <span class="attText">Attach Files</span>
                    </a>
                    <cfif request.qSystemSetupOptions.showScanButton>
                        <span><input id="ScanButtonLink" style="width:57px !important;height:22px;margin-top: 10px;" type="button" class="black-btn tooltip" value="Scan" onclick="popitup('../scanfiles/scanfile.cfm?id=<cfoutput>#url.loadid#</cfoutput>'+'&user='+'<cfoutput>#session.adminusername#</cfoutput>'+'&dsn='+'<cfoutput>#application.dsn#</cfoutput>')"></span>
                    </cfif>
                </cfif>
                <cfif structkeyexists(url,"loadid") and len(trim(url.loadid)) gt 1>
                    <span><input id="btnLocationUpdate" style="width:100px !important;height:22px;margin-top: 10px;" type="button" class="black-btn tooltip" value="Email Updates"></span>
                </cfif>
                <cfif len(EDISCAC)>
                <cfset edi212processed = 0>
                <cfset edi214processed = 0>
                <cfif IsDefined('qgetedi204logdata')>
                    <cfloop query = "qgetedi204logdata">
                        <cfif qgetedi204logdata.DOCTYPE EQ 212 AND qgetedi204logdata.exists>
                            <cfset edi212processed = 1>
                        </cfif>
                        <cfif qgetedi204logdata.DOCTYPE EQ 214 AND qgetedi204logdata.exists>
                            <cfset edi214processed = 1>
                        </cfif>
                    </cfloop>
                </cfif>
                <span><input id="edi212" style="width:72px !important;height:22px;margin-top: 10px;position: absolute;margin-left: 10px;<cfif edi212processed>pointer-events:none;opacity:0.5</cfif>" type="button" class="black-btn tooltip" value="212" onclick="processEDI(212)"></span>                 
                <span><input id="edidocs" style="width:72px !important;height:22px;margin-top: 10px;position: absolute;margin-left: 450px;" type="button" class="black-btn tooltip" value="EDI Docs" ></span>
                 <span><input id="payments" style="width:72px !important;height:22px;margin-top: 10px;position: absolute;margin-left: 530px;" type="button" class="black-btn tooltip" value="Payments" ></span>
                </cfif>
            </div>
            
            
            <cfif local.lockloadStatsFlag OR (isDefined('statusText') AND (NOT ListContains(session.editableStatuses,statusText,',') OR (isDefined('statusText') AND structkeyexists(session,"editableStatusesOverride") AND NOT ListContains(session.editableStatusesOverride,statusText,','))))>
                <div style="float: left; width: 40%; min-height: 40px;"><h1 style="color:white;font-weight:bold;display:inline-block;padding: 14px 10px 10px 50px;">Load###Ucase(loadnumber)#</h1><h3 id="ViewOnlyH" style="font-weight: bold;color: red;width:100%;display: none;">VIEW ONLY. EDIT NOT ALLOWED</h3></div>
            <cfelseif ediInvoiced EQ 1>
                <div style="float: left; width: 40%; min-height: 40px;"><h1 style="color:white;font-weight:bold;display:inline-block;">Load###Ucase(loadnumber)#</h1><h3 style="float: left;font-weight: bold;color: ##ab0707;width:100%;padding: 14px 10px 10px 0px;">View Only (EDI Lock)</h3></div>
            <cfelse>
                <div style="float: left; width: 40%; min-height: 40px;">
                    <h1 style="color:white;font-weight:bold;" id="HeaderLoadNumber">Load###Ucase(loadnumber)#</h1>
                </div>
            </cfif>
            
            <div style="float: left;width: 17%;min-height: 40px;padding-top: 13px;font-size: 15px;color: ##fff;">
                #request.qLoads.tripText#
            </div>
        </div>
    <cfelse>
        <cfset tempLoadId = #createUUID()#>
        <cfset session.checkUnload ='add'>

<!---Color Change #82bbef --->
        <div class="white-con-area" style="height: 40px;background-color: ##82bbef;width: 932px;">
            <div style="float: left; min-height: 40px; width: 43%;" id="divUploadedFiles">
            </div>
            <div style="float: left; width: 57%; min-height: 40px;"><h1 style="color:white;font-weight:bold;">Add New Load</h1></div>
        </div>
    </cfif>

    <cfset totStops = NoOfStopsToShow +1>
    <div id="dialog-confirm"></div>
    <form name="load"  class="addLoadWrap" id="load" action="index.cfm?event=addload:process&#session.URLToken#" method="post">

    <cfif  structkeyexists(url,"loadid") and len(url.loadid) gt 1>
        <input type="hidden" id="LastModifiedDate" name="LastModifiedDate" value="#request.qLoads.LastModifiedDate#">
    </cfif>    

    <input type="hidden" name="IncludeDhMilesInTotalMiles" id="IncludeDhMilesInTotalMiles" value="<cfif request.qSystemSetupOptions.IncludeDhMilesInTotalMiles>1<cfelse>0</cfif>">

    <input type="hidden" name="UseDirectCost" id="UseDirectCost" value="<cfif request.qSystemSetupOptions.UseDirectCost>1<cfelse>0</cfif>">
    <input type="hidden" name="RequireDeliveryDate" id="RequireDeliveryDate" value="#request.qSystemSetupOptions.RequireDeliveryDate#">
    <input type="hidden" name="focusStop" id="focusStop" value="">

    <input type="hidden" name="MinimumMarginReached" id="MinimumMarginReached" value="1">
    <input type="hidden" name="RateApprovalNeeded" id="RateApprovalNeeded" value="#RateApprovalNeeded#">
    <input type="hidden" name="MarginApproved" id="MarginApproved" value="#MarginApproved#">
    <input type="hidden" name="LastApprovedRate" id="LastApprovedRate" value="#LastApprovedRate#">
    <input type="hidden" name="inputChanged" id="inputChanged" value="0">
    <input type="hidden" name="CompanyID" id="CompanyID" value="#session.CompanyID#">
    <input type="hidden" name="loaddisabledStatus" id="loaddisabledStatus" value="#variables.loaddisabledStatus#">
     <input type="hidden" name="tabid" id="tabid" value="">

     <cfif structKeyExists(request.qcurAgentdetails, "IntegrateWithDirectFreightLoadboard") AND request.qcurAgentdetails.IntegrateWithDirectFreightLoadboard EQ 1 >
        <input type="hidden" name="IntegrateWithDirectFreightLoadboard" id="IntegrateWithDirectFreightLoadboard" value="#request.qcurAgentdetails.IntegrateWithDirectFreightLoadboard#">
        <input type="hidden" name="DirectFreightLoadboardUserName" id="DirectFreightLoadboardUserName" value="#request.qcurAgentdetails.DirectFreightLoadboardUserName#">
        <input type="hidden" name="DirectFreightLoadboardPassword" id="DirectFreightLoadboardPassword" value="#request.qcurAgentdetails.DirectFreightLoadboardPassword#">
        <input type="hidden" name="loadDirectFreightPost" id="loadDirectFreightPost" value="#posttoDirectFreight#">
    <cfelse>
        <input type="hidden" name="loadDirectFreightPost" id="loadDirectFreightPost" value="0">
    </cfif>

    <cfif  structKeyExists(request.qcurAgentdetails, "PEPcustomerKey") AND #request.qcurAgentdetails.integratewithPEP# eq true>
        <input type="hidden" name="integratewithPEP" id="integratewithPEP" value="#request.qcurAgentdetails.integratewithPEP#">
        <input type="hidden" name="PEPsecretKey" id="PEPsecretKey" value="#request.qSystemSetupOptions.PEPsecretKey#">
        <input type="hidden" name="PEPcustomerKey" id="PEPcustomerKey" value="#request.qcurAgentdetails.PEPcustomerKey#">
    </cfif>

    <cfif structKeyExists(request.qcurAgentdetails, "integratewithTran360") AND  #request.qcurAgentdetails.integratewithTran360# eq true>
        <input type="hidden" name="integratewithTran360" id="integratewithTran360" value="#request.qcurAgentdetails.integratewithTran360#">
        <input type="hidden" name="trans360Usename" id="trans360Usename" value="#request.qcurAgentdetails.trans360Usename#">
        <input type="hidden" name="trans360Password" id="trans360Password" value="#request.qcurAgentdetails.trans360Password#">
        <input type="hidden" name="Triger_loadStatus" id="Triger_loadStatus" value="#request.qSystemSetupOptions.Triger_loadStatus#">
        <input type="hidden" name="IsTransCorePst" id="IsTransCorePst" value="#posttoTranscore#">
    <cfelse>
       <input type="hidden" name="IsTransCorePst" id="IsTransCorePst" value="0">
    </cfif>
    <cfif structKeyExists(request.qcurAgentdetails, "integratewithITS") AND  #request.qcurAgentdetails.integratewithITS# eq true>
        <input type="hidden" name="integratewithITS" id="integratewithITS" value="#request.qcurAgentdetails.integratewithITS#">
        <input type="hidden" name="ITSUsername" id="ITSUsename" value="#request.qSystemSetupOptions.ITSUserName#">
        <input type="hidden" name="ITSPassword" id="ITSPassword" value="#request.qSystemSetupOptions.ITSPassword#">
        <input type="hidden" name="ITSIntegrationID" id="ITSIntegrationID" value="#request.qcurAgentdetails.IntegrationID#">
        <input type="hidden" name="IsITSPst" id="IsITSPst" value="#posttoITS#">
    </cfif>

    <cfif request.qcurAgentdetails.loadBoard123 EQ 1 >
        <input type="hidden" name="loadBoard123Username" id="loadBoard123Username" value="#request.qcurAgentdetails.loadBoard123Usename#">
        <input type="hidden" name="loadBoard123" id="loadBoard123" value="#request.qcurAgentdetails.loadBoard123#">
        <input type="hidden" name="loadBoard123Password" id="loadBoard123Password" value="#request.qcurAgentdetails.loadBoard123Password#">
        <input type="hidden" name="Is123LoadBoardPst" id="Is123LoadBoardPst" value="#PostTo123LoadBoard#">
    <cfelse>
        <input type="hidden" name="loadBoard123" id="loadBoard123" value="0">
    </cfif>
    <cfif request.qcurAgentdetails.integratewithPEP EQ 1 >
        <input type="hidden" name="ISPOST" id="ISPOST" value="#ISPOST#">
    </cfif>
    <input type="hidden" name="ediLoad" id="ediLoad" value="<cfif len(EDISCAC)>1<cfelse>0</cfif>">
    <input type="hidden" name="Edi210EsignReq" id="Edi210EsignReq" value="<cfif request.qSystemSetupOptions.Edi210EsignReq>1<cfelse>0</cfif>">
    <cfif request.qSystemSetupOptions.TimeZone>
        <input type="hidden" name="TimeZone" id="TimeZone" value="">
    </cfif>
    <cfif structkeyexists(url,"loadid") and len(trim(url.loadid)) gt 1 and listFind("2,3", request.qSystemSetupOptions.EDispatchOptions) and len(trim(request.qLoads.MacroPointOrderID))>
        <cfinvoke component="#variables.objloadGateway#" method="getMPLoadDetails" returnvariable="request.qMPLoadDetails" LoadID="#url.loadid#"/>
        <input type="hidden" name="MacroPointOrderID" value="#request.qMPLoadDetails.MacroPointOrderID
        #">
        <input type="hidden" name="Mp_DriverCell" value="#request.qMPLoadDetails.DriverCell#">
        <input type="hidden" name="Mp_CarrierID" value="#request.qMPLoadDetails.CarrierID#">
        <input type="hidden" name="Mp_StopRecordCount" value="#request.qMPLoadDetails.recordcount#">
        <cfloop query="#request.qMPLoadDetails#">
            <input type="hidden" name="Mp_StopDate_#request.qMPLoadDetails.currentrow#" value="#request.qMPLoadDetails.StopDate#">
            <input type="hidden" name="Mp_StopTime_#request.qMPLoadDetails.currentrow#" value="#request.qMPLoadDetails.StopTime#">
            <input type="hidden" name="Mp_TimeIn_#request.qMPLoadDetails.currentrow#" value="#request.qMPLoadDetails.TimeIn#">
            <input type="hidden" name="Mp_TimeOut_#request.qMPLoadDetails.currentrow#" value="#request.qMPLoadDetails.TimeOut#">
            <input type="hidden" name="Mp_Address_#request.qMPLoadDetails.currentrow#" value="#request.qMPLoadDetails.Address#">
            <input type="hidden" name="Mp_City_#request.qMPLoadDetails.currentrow#" value="#request.qMPLoadDetails.City#">
            <input type="hidden" name="Mp_StateCode_#request.qMPLoadDetails.currentrow#" value="#request.qMPLoadDetails.StateCode#">
            <input type="hidden" name="Mp_PostalCode_#request.qMPLoadDetails.currentrow#" value="#request.qMPLoadDetails.PostalCode#">
        </cfloop>
    </cfif>
    <div class="white-con-area">
        <div class="white-mid" style="width: 932px;">
            <cfif (not  structkeyexists(url,"loadToBeCopied") OR url.loadToBeCopied eq 0) AND ( structkeyexists(url,"loadid") )>
                <input type="hidden" id="editid" name="editid" value="#editid#">
            </cfif>
            <cfif structKeyExists(url, "loadToBeCopied")>
                <input type="hidden" id="loadToBeCopied" name="loadToBeCopied" value="#url.loadToBeCopied#">
            </cfif>
            <cfif structkeyexists(url,"loadid") and len(trim(url.loadid)) gt 1 and LoadNumber neq "">
                <cfquery name="GetTranceCoreDBSucesscount" datasource="#application.dsn#">
                    select imprtref,Postrequest_text from LoadPostEverywhereDetails where imprtref=<cfqueryparam value="#LoadNumber#" cfsqltype="cf_sql_varchar"> and From_web='Tc360' and status='sucess'
                </cfquery>
                 <input type="hidden" name="Trancore_checkDelete"  id="Trancore_checkDelete" value="#GetTranceCoreDBSucesscount.recordcount#">
            <cfelse>
                <input type="hidden" name="Trancore_checkDelete"  id="Trancore_checkDelete" value="0">
            </cfif>
            <input type="hidden" name="Trancore_DeleteFlag"  id="Trancore_DeleteFlag" value="">
            <input type="hidden" name="LoadNumber"  id="LoadNumber" value="#LoadNumber#">
            <input type="hidden" name="nextLoadStopId" value="#loadstopid#">
            <input type="hidden" name="LOADSTOPID" value="#LOADSTOPID#">
            <input type="hidden" name="totalStop" id="totalStop" value="#totStops#">
            <input type="hidden" name="custChk" id="custChk" value="">
            <input type="hidden" name="Loggedin_Person" id="Loggedin_Person" value="#session.UserFullName#">

            <div class="form-con" style="width:480px;">
                <fieldset>
                    <div class="clear"></div>
                    <input type="hidden" name="allowloadentry" value="#request.qSystemSetupOptions.AllowLoadentry#"  />
                    <input type="hidden" name="carrierratecon" id="carrierratecon" value="#request.qSystemSetupOptions.CarrierRateConfirmation#"  />
                    <div class="right_billdate_area">
                        <cfif structkeyexists(url,"loadid") and len(trim(url.loadid)) gt 1 and LoadNumber neq "">
                            <cfif #request.qSystemSetupOptions.AllowLoadentry# eq true >
                                <div class="clear"></div><span id="myDiv"></span>
                                <label class="space_it">Load Number</label>
                                <input type="Text" name="loadManualNo" class="mid-textbox-1" style="text-align:left;margin: 0 0 8px 0;"  id="loadManualNo" value="#LoadNumber#"  maxlength="12" onkeyup="checkloadNUmberDB(this.value,'#application.dsn#');"  onblur="checkloadNUmberDB(this.value,'#application.dsn#');" />
                                <div class="clear"></div>
                            <cfelse>
                                <input type="hidden" name="loadManualNo" class="mid-textbox-1" style="text-align:left;margin: 0 0 8px 0;"  id="loadManualNo"  value="#LoadNumber#"   style="display:none" />
                            </cfif>
                        <cfelse>
                            <cfif #request.qSystemSetupOptions.AllowLoadentry# eq true >
                                <div class="clear"></div>
                                <span id="myDiv"></span>
                                <label class="space_it">Load Number</label>
                                <input type="Text" name="loadManualNo" class="mid-textbox-1" style="text-align:left;margin: 0 0 8px 0;"  id="loadManualNo" value=""  maxlength="12" onkeyup="checkloadNUmberDB(this.value,'#application.dsn#');"  onblur="checkloadNUmberDB(this.value,'#application.dsn#');" />
                                <div class="clear"></div>
                            <cfelse>
                                <input type="hidden" name="loadManualNo" class="mid-textbox-1" style="text-align:left;margin: 0 0 8px 0;"  id="loadManualNo"  style="display:none" />
                            </cfif>
                        </cfif>

                        <input type="hidden" name="loadManualNoExists" id="loadManualNoExists" value=""   />
                        <input type="hidden" name="loadManualNoIdentExists" id="loadManualNoIdentExists" value=""   />
                        <label class="space_it">Status*</label>
                        <cfset oldStatus = ""> 
                        <cfset ForceNextStatusFlag =false>
                        <cfset ForceNextStatusFlagAny =false>
                        <cfset ForceNextStatusFieldValue =0>
                                            
                        <cfloop query="request.qLoadStatus">
                            <cfif ForceNextStatusFlag EQ "true" AND ForceNextStatusFieldValue EQ 0>
                                <cfset ForceNextStatusFieldValue = request.qLoadStatus.value>

                            </cfif>
                            <cfif ForceNextStatusFlagAny EQ "true" and len(oldStatus)>
                                <cfset ForceNextStatusFieldValue = request.qLoadStatus.value>
                                <cfset ForceNextStatusFlagAny =false>
                            </cfif>
                            <cfif request.qLoadStatus.value EQ loadStatus>
                                <cfset oldStatus = request.qLoadStatus.Text>
                                <cfif  request.qLoadStatus.ForceNextStatus Eq True>
                                    <cfset ForceNextStatusFlag =true>
                                </cfif>                                
                            <cfelse>
                            <cfif request.qLoadStatus.ForceNextStatus Eq True AND Not Len(oldStatus)>
                                <cfset ForceNextStatusFlagAny =true>
                            </cfif>   
                            </cfif> 
                                                    
                        </cfloop>
                       
                        <cfif ForceNextStatusFieldValue NEQ 0>
                            <cfset ForceNextStatusFlag =true>
                        </cfif>

                        <cfif ListContains(session.rightsList,'LoadStatusOverride',',') AND ForceNextStatusFlag>
                            <cfset ForceNextStatusFlag = false>
                            <cfset variables.lockloadOverride=true>
                        </cfif>

                        <input type="hidden" id="oldStatusVal" name="oldStatusVal" value="#loadStatus#">
                        <input type="hidden" id="oldStatus" name="oldStatus" value="#oldStatus#">
                        <input type="hidden" id="ediInvoiced" name="ediInvoiced" value="#ediInvoiced#">
                      
                        <select name="loadStatus" id="loadStatus" tabindex=1 class="medium " onchange="changeValueStatus();" style="margin: 0 0 8px 0;width:75px" data-lock-override="<cfif isDefined("variables.lockloadOverride")>1<cfelse>0</cfif>">
                            <option value="">Select Status</option>
                            <cfloop query="request.qLoadStatus">
                                <cfif request.qLoadStatus.Text EQ '3. DISPATCHED'>
                                    <cfset dispatchStatusDesc =  request.qLoadStatus.StatusDescription>
                                </cfif>
                               <cfif request.qLoadStatus.value  EQ loadStatus OR request.qLoadStatus.SystemUpdated EQ 0 OR ListContains(session.rightsList,'EditSystemLoadStatus',',')>

                                <cfif not len(trim(url.loadToBeCopied)) gt 2>
                                    <cfif oldStatus eq '0.1 EDI'>
                                        <cfif listFindNoCase("0.1 EDI,1. ACTIVE,9. Cancelled", request.qLoadStatus.Text)>
                                            <option data-send-update="#request.qLoadStatus.SendEmailForLoads#" value="#request.qLoadStatus.value#" data-statusText="#request.qLoadStatus.Text#"
                                                <cfif loadStatus is request.qLoadStatus.value AND url.loadToBeCopied EQ 0> selected="selected" </cfif>>
                                                #request.qLoadStatus.StatusDescription#
                                            </option>
                                        </cfif>
                                    <cfelse>
                                        <cfif Not Len(loadStatus)>
                                             <option data-send-update="#request.qLoadStatus.SendEmailForLoads#" value="#request.qLoadStatus.value#" data-statusText="#request.qLoadStatus.Text#"
                                                <cfif request.qLoadStatus.text is '1. ACTIVE'> selected="selected" </cfif>>
                                                #request.qLoadStatus.StatusDescription#
                                            </option>
                                        <cfelseif ForceNextStatusFlag Eq "false">
                                            <cfif request.qLoadStatus.Text NEQ "0.1 EDI">
                                                <option data-send-update="#request.qLoadStatus.SendEmailForLoads#" data-statusText="#request.qLoadStatus.Text#" value="#request.qLoadStatus.value#"
                                                    <cfif loadStatus is request.qLoadStatus.value AND url.loadToBeCopied EQ 0> selected="selected" </cfif>>
                                                    #request.qLoadStatus.StatusDescription#
                                                </option>
                                            </cfif>
                                         <cfelse>
                                            <cfif request.qLoadStatus.Text NEQ "0.1 EDI" AND (request.qLoadStatus.value EQ ForceNextStatusFieldValue OR loadStatus is request.qLoadStatus.value)>
                                                <option data-send-update="#request.qLoadStatus.SendEmailForLoads#" data-statusText="#request.qLoadStatus.Text#" value="#request.qLoadStatus.value#"
                                                    <cfif loadStatus is request.qLoadStatus.value AND url.loadToBeCopied EQ 0> selected="selected" </cfif>>
                                                            #request.qLoadStatus.StatusDescription#
                                                </option>
                                            </cfif>
                                            
                                        </cfif> 
                                    </cfif>
                                <cfelse>
                                    <option data-send-update="#request.qLoadStatus.SendEmailForLoads#" data-statusText="#request.qLoadStatus.Text#" value="#request.qLoadStatus.value#"
                                        <cfif request.qLoadStatus.text is '1. ACTIVE'> selected="selected" </cfif>>
                                        #request.qLoadStatus.StatusDescription#
                                    </option>
                                </cfif>
                            </cfif>
                            </cfloop>
                        </select>
                        <cfif IsDefined('qgetEdiStopDetails') and Len(EDISCAC)>
                            <select name="shipperConsignee" id="shipperConsignee" tabindex=1 class="medium " style="margin-left:0px;width:37px;" onchange="changeShipperConsigneeNote()">
                                <cfloop query="qgetEdiStopDetails"> 
                                    <cfif Len(custname)>
                                        <option value="#LoadStopID#" data-code="#stopno##stoptype#" <cfif structKeyExists(qgetSelectedEDIStop, "stop") AND Len(qgetSelectedEDIStop.stop) AND Findnocase(#qgetSelectedEDIStop.stop#,#custname#)> selected </cfif>>
                                            #stopno##stoptype# #custname# #address# #city# #statecode# #postalcode#
                                        </option>
                                    </cfif>
                                </cfloop>
                            </select>
                        <cfelseif structkeyexists(url,"loadid") and len(trim(url.loadid)) gt 1>
                           <cfset stopCount = request.loadstopcount/2>
                            <select name="LoadStatusStopNo" style="margin-left:0px;width:37px;<cfif request.qLoads.ShowStopOnLoadStatus EQ 0>display:none</cfif>">
                                <cfloop from="1" to="#stopCount#" index="ind">
                                    <option value="#ind#S" <cfif request.qLoads.LoadStatusStopNo EQ "#ind#S"> selected </cfif>>#ind#P</option>
                                    <option value="#ind#C" <cfif request.qLoads.LoadStatusStopNo EQ "#ind#C"> selected </cfif>>#ind#D</option>
                                </cfloop>
                            </select>
                        </cfif>

                        <cfset reqSetStatus="#request.qSystemSetupOptions.ARAndAPExportStatusID#">
                        <input type="hidden" name="qLoadDefaultSystemStatus" id="qLoadDefaultSystemStatus" value="#reqSetStatus#" />
                        <input type="hidden" name="StatusDispatchNotesToShowHidden" id="StatusDispatchNotesToShowHidden" value="#StatusDispatchNotesToShow#" />
                        <div class="clear"></div>
                        <div id="slsP" style="color:red;display:none;padding-left:150px;"></div>
                        <div class="clear"></div>

                        <cfif ((structkeyexists(url,"loadid") and len(trim(url.loadid)) gt 1)

                            or ( structkeyexists(url,"loadToBeCopied")  and len(trim(url.loadToBeCopied)) gt 1 )

                        )>
                            <cfquery name="qGetCustLocks" datasource="#application.dsn#">
                                SELECT LockSalesAgentOnLoad,LockDispatcherOnLoad,LockDispatcher2OnLoad FROM Customers WHERE CustomerID = <cfqueryparam value="#request.qloads.payerid#" cfsqltype="cf_sql_varchar">
                            </cfquery>
                        </cfif>
                        <input type="hidden" name="Dispatcher1" id="Dispatcher1" value="#Dispatcher1#">
                        <input type="hidden" name="Dispatcher2" id="Dispatcher2" value="#Dispatcher2#">
                        <input type="hidden" name="Dispatcher3" id="Dispatcher3" value="#Dispatcher3#">
                        <input type="hidden" name="Dispatcher1Percentage" id="Dispatcher1Percentage" value="#Dispatcher1Percentage#">
                        <input type="hidden" name="Dispatcher2Percentage" id="Dispatcher2Percentage" value="#Dispatcher2Percentage#">
                        <input type="hidden" name="Dispatcher3Percentage" id="Dispatcher3Percentage" value="#Dispatcher3Percentage#">
                        <input type="hidden" name="LockDispatcher2OnLoad" id="LockDispatcher2OnLoad" <cfif (structkeyexists(url,"loadid") and len(trim(url.loadid)) gt 1) AND qGetCustLocks.LockDispatcher2OnLoad>value="1"</cfif>>
                        <label class="space_it">Dispatcher*</label>

                        <select id="Dispatcher" name="Dispatcher" tabindex=3 class="medium" style="margin: 0 0 8px 0;<cfif (( structkeyexists(url,"loadid") and len(trim(url.loadid)) gt 1 ) OR ( structkeyexists(url,"loadToBeCopied")  and len(trim(url.loadToBeCopied)) gt 1 )) and qGetCustLocks.LockDispatcherOnLoad>
                        pointer-events:none;opacity: 0.5;<cfif structkeyexists(url,"loadToBeCopied")  and len(trim(url.loadToBeCopied)) gt 1 AND not len(trim(Dispatcher))><cfset Dispatcher=request.qLoads.DISPATCHERID></cfif></cfif>width:90px;">
                            <option value="" data-per="0">Select</option>
                            <cfloop query="request.qSalesPerson">
                                <option value="#request.qSalesPerson.EmployeeID#" <cfif request.qSalesPerson.EmployeeID eq  Dispatcher> selected="selected" </cfif> <cfif structkeyexists(url,"loadid") AND url.loadid eq 0 AND request.qcurAgentdetails.DefaultDispatcherToLoad EQ 1 AND request.qSalesPerson.EmployeeID EQ session.empid> selected </cfif> data-per="#request.qSalesPerson.SalesCommission#">#request.qSalesPerson.Name#</option>
                            </cfloop>
                        </select><input id="multipleDispatcherBtn" style="width: 20px !important;height: 18px;padding: 0;" type="button" value="..." onclick="openDispatcherCommisionPopup()">

                        <div class="clear"></div>
                        <cfif request.qSystemSetupOptions.freightBroker EQ 1 OR request.qSystemSetupOptions.freightBroker EQ 2>
                            <input type="hidden" name="SalesRep1" id="SalesRep1" value="#SalesRep1#">
                            <input type="hidden" name="SalesRep2" id="SalesRep2" value="#SalesRep2#">
                            <input type="hidden" name="SalesRep3" id="SalesRep3" value="#SalesRep3#">
                            <input type="hidden" name="SalesRep1Percentage" id="SalesRep1Percentage" value="#SalesRep1Percentage#">
                            <input type="hidden" name="SalesRep2Percentage" id="SalesRep2Percentage" value="#SalesRep2Percentage#">
                            <input type="hidden" name="SalesRep3Percentage" id="SalesRep3Percentage" value="#SalesRep3Percentage#">
                            <label class="space_it">Sales Rep*</label>
                            <select id="Salesperson" name="Salesperson" tabindex=2 class="medium" style="margin: 0 0 8px 0;<cfif (( structkeyexists(url,"loadid") and len(trim(url.loadid)) gt 1 ) OR ( structkeyexists(url,"loadToBeCopied")  and len(trim(url.loadToBeCopied)) gt 1 )) and qGetCustLocks.LockSalesAgentOnLoad>pointer-events:none;opacity: 0.5;<cfif structkeyexists(url,"loadToBeCopied")  and len(trim(url.loadToBeCopied)) gt 1 AND not len(trim(Salesperson))><cfset Salesperson=request.qLoads.SALESREPID></cfif>
                        </cfif>width:90px;">
                                <option value="" data-per="0">Select</option>
                                <cfloop query="request.qSalesPerson">
                                    <option value="#request.qSalesPerson.EmployeeID#" <cfif request.qSalesPerson.EmployeeID eq  Salesperson> selected="selected" </cfif> <cfif structkeyexists(url,"loadid") AND url.loadid eq 0 AND request.qcurAgentdetails.DefaultSalesRepToLoad EQ 1 AND request.qSalesPerson.EmployeeID EQ session.empid> selected </cfif> data-per="#request.qSalesPerson.SalesCommission#">#request.qSalesPerson.Name#</option>
                                </cfloop>
                            </select><input style="width: 20px !important;height: 18px;padding: 0;" type="button" value="..." onclick="openSalesRepCommisionPopup()" id="multipleSalesRepBtn">
                            <div class="clear"></div>
                        <cfelse>
                            <label class="space_it_little" style="margin-left: 6px;">#left(request.qSystemSetupOptions.userdef7,12)#</label>
                            <input class="sm-input" tabindex="4" name="userDefinedForTrucking" id="userDefinedForTrucking" value="#userDefinedFieldTrucking#" type="text" style="margin-left: 30px;width: 105px;" maxlength="250">
                            <div class="clear"></div>
                        </cfif>

                        <cfif structKeyExists(request, "qLoads") and structKeyExists(request.qLoads, "InternalRef")>
                            <cfset InternalRef = request.qLoads.InternalRef>
                        <cfelse>
                            <cfset InternalRef = "">
                        </cfif>
                        <label class="space_it">Internal Ref##</label>
                        <div style="position:relative;float:left;">
                            <div style="float:left;">
                                <input class="sm-input myElements" tabindex="4" name="InternalRef" id="InternalRef" value="#InternalRef#" type="text" style="width:105px" maxlength="150">
                            </div>
                        </div>

                        <cfif request.qSystemSetupOptions.FreightBroker NEQ 0>
                            <div class="notes" style="<cfif not (request.qSystemSetupOptions.freightBroker EQ 1 OR request.qSystemSetupOptions.freightBroker EQ 2) AND #request.qSystemSetupOptions.AllowLoadentry# NEQ true >margin-top: 32px;width:30%;<cfelseif  (request.qSystemSetupOptions.freightBroker EQ 1 OR request.qSystemSetupOptions.freightBroker EQ 2) AND NOT request.qSystemSetupOptions.AllowLoadentry>margin-top: 60px;width:30%;</cfif><cfif request.qSystemSetupOptions.showCarrierInvoiceNumber EQ 1>margin-top: 47px;</cfif>"><!--- Include Carrier Rate Change --->
                                <label class="space_it_little" style="width: 82px;">Notes - Public</label>
                                <textarea id="Notes" class="medium-textbox <cfif NotesToShow eq true>applynotesPl</cfif>" name="Notes" tabindex=5 cols="" rows="" style="margin-left: 6px; <cfif request.qSystemSetupOptions.freightBroker EQ 0 OR (structkeyexists(url,"loadid") and len(trim(url.loadid)) gt 1 and request.qloads.statustext GTE '2. BOOKED' and PostTo123LoadBoard NEQ 1 and posttoDirectFreight NEQ 1 and posttoloadboard NEQ 1 and posttoTranscore NEQ 1 and posttoITS NEQ 1)>width:394px;</cfif>"><cfif url.loadToBeCopied EQ 0>#Notes#<cfelse><cfif structkeyexists(url,'loadNumber')>Load copied from #url.loadNumber#</cfif></cfif></textarea><!--- Include Carrier Rate Change --->
                                <div class="clear"></div>
                                <cfif not (request.qSystemSetupOptions.freightBroker EQ 1 OR request.qSystemSetupOptions.freightBroker EQ 2 )>
                                    <input name="statusfreightBroker" ID="statusfreightBroker" type="hidden" value="0" />
                                </cfif>
                                <label class="space_it">&nbsp;</label>
                            </div>
                        </cfif>
                    </div>
                    <div class="left_billdate_area"  <cfif request.qSystemSetupOptions.FreightBroker EQ 0>style="height:117px;"<cfelse>style="height:228px;"</cfif>>
                        <cfif not isdefined('request.qLoads.orderDate') OR request.qLoads.orderDate eq "01/01/1900" >
                        <!--- SQL returns this when date is null --->
                            <cfset orderDate = dateformat(NOW(),'mm/dd/yyyy')>
                        <cfelse>
                            <cfset orderDate = dateformat(request.qLoads.orderDate,'mm/dd/yyyy')>
                        </cfif>
                        <cfif  structkeyexists(url,"loadToBeCopied") and url.loadToBeCopied neq 0 >
                             <cfset orderDate = dateformat(NOW(),'mm/dd/yyyy')>
                        </cfif>
                        <label class="space_it" style="width: 85px;">Order Date</label>
                        <div style="position:relative;float:left;">
                            <div style="float:left;">
                                <input tabindex=4 name="orderDate" id="orderDate"  onchange="checkDateFormatAll(this);" value="#dateformat(orderDate,'mm/dd/yyyy')#" validate="date" required="yes" message="Please enter a valid date" type="datefield" <cfif (structkeyexists(url,"loadid") and len(trim(url.loadid)) gt 1) AND (request.qSystemSetupOptions.IsLockOrderDate NEQ 1)>readonly class="sm-input disabledLoadInputs"<cfelse>class="sm-input datefield"</cfif>/>
                            </div>
                        </div>
                        <div id="BillDate_Area" style="height: 70px;">
                            <cfif not isdefined('request.qLoads.BillDate') OR request.qLoads.BillDate eq "01/01/1900">
                                <cfset BillDate = "">
                            <cfelse>
                                <cfset BillDate = dateformat(request.qLoads.BillDate,'mm/dd/yyyy')>
                            </cfif>
                            <cfif  structkeyexists(url,"loadToBeCopied") and url.loadToBeCopied neq 0 >
                                <cfset BillDate = ''>
                                <cfset Invoicenumber=0>
                            </cfif>

                            <label class="space_it" style="width: 85px;">Invoice Date</label>
                            <cfif request.qSystemSetupOptions.ARAndAPExportStatusID neq loadStatus>
                                <cfset abc = "yes">
                            <cfelse>
                                <cfset abc = "no">
                            </cfif>

                            <div style="position:relative;float:left;">
                                <div style="float:left;">
                                    <input class="sm-input datefield" tabindex=4 name="BillDate" id="BillDate"  onchange="checkDateFormatAll(this);" value="#dateformat(BillDate,'mm/dd/yyyy')#" type="text" />
                                    <input type="hidden"  id="BillDate_Static" value="#dateformat(BillDate,'mm/dd/yyy')#" />
                                </div>
                            </div>
                            <cfif request.qSystemSetupOptions.MinimumLoadInvoiceNumber neq 0>
                                <label class="space_it">Invoice##</label>
                                <input class="sm-input " tabindex=4 name="InvoiceNumber" id="InvoiceNumber" value="#Invoicenumber#" type="text" readonly/>
                            </cfif>
                            <cfif request.qSystemSetupOptions.showCarrierInvoiceNumber EQ 1>
                                <div style="padding-bottom:10px;">
                                    <label class="space_it" style="width: 85px;">Carrier Invoice##</label>
                                    <input class="sm-input " tabindex=4 name="CarrierInvoiceNumber" id="CarrierInvoiceNumber" value="#CarrierInvoiceNumber#" type="text" onkeyup="this.value=this.value.replace(/[^\d]/,'')"  />
                                </div>
                            </cfif>
                            <cfif len(EDISCAC)>
                                <label class="space_it">POD Signature</label>
                                <input class="sm-input " tabindex=4 name="PODSignature" id="PODSignature" value="#PODSignature#" type="text" style="width:80px" maxlength="100" />
                            </cfif>
                            <div class="clear"></div>
                        </div>
                        <div class="clear"></div>    

                        <cfif request.qSystemSetupOptions.FreightBroker NEQ 0>
                            <cfif request.qSystemSetupOptions.showCarrierInvoiceNumber EQ 1></br></cfif>
                            <!--- Modified  : Include Carrier Rate Change --->
                                <div id="divLoadBoard" <cfif structkeyexists(url,"loadid") and len(trim(url.loadid)) gt 1 and request.qloads.statustext GTE '2. BOOKED' and PostTo123LoadBoard NEQ 1 and posttoDirectFreight NEQ 1 and posttoloadboard NEQ 1 and posttoTranscore NEQ 1 and posttoITS NEQ 1>
                                    style="display: none;"
                                </cfif>>
                                <div style="float:left;width: 132px;border-right: 1px ##b3b3b3 solid;border-bottom: 1px ##b3b3b3 solid;"><b>Post To Load Boards</b></div>
                                <div style="float: right;margin-right: -19px;border-bottom: 1px ##b3b3b3 solid;padding-left: 5px;-moz-margin-end:-20px"><b>Include Rate</b></div>
                                <div class="clear"></div>

                                <div style="float:left;width: 132px;border-right: 1px ##b3b3b3 solid;">
                                    <div class="load_opt" style="padding-left: 0px;margin-top: 11px;">123LoadBoard
                                        <input name="PostTo123LoadBoard" ID="PostTo123LoadBoard" type="checkbox" tabindex=6 class="small_chk" onchange="uncheckCarrierRate123LoadBoard(this.checked)" <cfif (PostTo123LoadBoard is 1)  OR (url.loadid eq 0 AND request.qcurAgentdetails.LoadBoard123Default EQ 1)>checked="checked" </cfif> value="#PostTo123LoadBoard#" />
                                    </div>
                                    <div class="clear"></div>

                                    <div class="load_opt" style="padding-left: 0px;">Direct Freight <span style="color:##11c511">(FREE)</span>
                                        <input name="posttoDirectFreight" ID="posttoDirectFreight" type="checkbox" tabindex=6 class="small_chk" <cfif (posttoDirectFreight is 1) OR (url.loadid eq 0 AND request.qcurAgentdetails.IntegrateWithDirectFreightLoadboardDefault EQ 1)> checked="checked" </cfif> value="" />
                                    </div>
                                    <div class="clear"></div>
                                    <div class="load_opt" style="padding-left: 0px;">LoadBoard Network
                                        <input name="posttoloadboard" ID="posttoloadboard" type="checkbox" tabindex=6 class="small_chk" onchange="uncheckCarrierRateEveryWhere(this.checked)" <cfif posttoloadboard is 1 OR (url.loadid eq 0 AND request.qcurAgentdetails.integratewithPEPDefault EQ 1)> checked="checked" </cfif> value="1" />
                                    </div>
                                    <div class="clear"></div>
                                    <div class="load_opt" style="padding-left: 0px;">DAT Loads
                                        <input name="posttoTranscore"   ID="posttoTranscore" type="checkbox" tabindex=6 class="small_chk" onchange="uncheckCarrierRateTranscore(this.checked)" <cfif (posttoTranscore is 1)  OR (url.loadid eq 0 AND request.qcurAgentdetails.IntegrateWithTran360Default EQ 1)> checked="checked" </cfif> value="#posttoTranscore#" />
                                    </div>
                                    <div class="clear"></div>
                                    <div class="load_opt" style="padding-left: 0px;">Truckstop
                                        <input name="posttoITS" ID="posttoITS" type="checkbox" tabindex=6 class="small_chk" onchange="uncheckCarrierRateITS(this.checked)" <cfif (posttoITS is 1) OR (url.loadid eq 0 AND request.qcurAgentdetails.integratewithITSDefault EQ 1)> checked="checked" </cfif> value="" />
                                    </div>
                                    <div class="clear"></div>
                                </div>
                                <div style="float: right;padding-left: 5px;margin-top: 11px;">
                                    <input onchange="checkCarrierRate()" name="postCarrierRateto123LoadBoard"  <cfif postCarrierRateto123LoadBoard EQ 1>checked</cfif>   ID="postCarrierRateto123LoadBoard" type="checkbox" tabindex=6 class="small_chk"  value="1" />
                                    <div class="clear"></div>
                                    <input name="postCarrierRatetoDirectFreight" ID="postCarrierRatetoDirectFreight" <cfif postCarrierRatetoDirectFreight EQ 1>checked</cfif>  type="checkbox" tabindex=6 class="small_chk"  value="1" />
                                    <div class="clear"></div>
                                    <input onchange="checkCarrierRate()" name="postCarrierRatetoloadboard"  <cfif postCarrierRatetoloadboard EQ 1>checked</cfif>    ID="postCarrierRatetoloadboard" type="checkbox" tabindex=6 class="small_chk"  value="1" />
                                    <div class="clear"></div>
                                     <input onchange="checkCarrierRate()"   name="postCarrierRatetoTranscore"  <cfif postCarrierRatetoTranscore EQ 1>checked</cfif>  ID="postCarrierRatetoTranscore" type="checkbox" tabindex=6 class="small_chk"  value="1" />
                                    <div class="clear"></div>
                                    <input onchange="checkCarrierRate()" name="postCarrierRatetoITS" ID="postCarrierRatetoITS" <cfif postCarrierRatetoITS EQ 1>checked</cfif>  type="checkbox" tabindex=6 class="small_chk"  value="1" />
                                    <div class="clear"></div>
                                </div>
                            </div>
                            <div class="clear" style="border-bottom: 1px ##b3b3b3 solid;width: 204px;<cfif structkeyexists(url,"loadid") and len(trim(url.loadid)) gt 1 and request.qloads.statustext GTE '2. BOOKED' and PostTo123LoadBoard NEQ 1 and posttoDirectFreight NEQ 1 and posttoloadboard NEQ 1 and posttoTranscore NEQ 1 and posttoITS NEQ 1>
                                    display: none;
                                </cfif>"></div>
                            <input name="statusfreightBroker" ID="statusfreightBroker" type="hidden" value="1" />
                            
                        </cfif>
                        
                        <input type="hidden" id="LoadNumberAutoIncrement" name="LoadNumberAutoIncrement" value="#request.qSystemSetupOptions1.LoadNumberAutoIncrement#">
                        <input type="hidden" id="StartingActiveLoadNumber" name="StartingActiveLoadNumber" value="#request.qSystemSetupOptions1.StartingActiveLoadNumber#">
                        <!--- Modified  : Include Carrier Rate Change --->
                    </div>
                    <div class="clear"></div>
                    
                    <cfif request.qSystemSetupOptions.FreightBroker EQ 0>
                        <div class="notes" style="margin-top:15px;"><!--- Include Carrier Rate Change --->
                            <label class="space_it_little" style="width: 80px;">Internal Notes</label></br>
                            <textarea class="medium-textbox <cfif NotesToShow eq true>applynotesPl</cfif>" name="Notes" tabindex=5 cols="" rows="" style="margin-left: 6px;width:394px;"><cfif url.loadToBeCopied EQ 0>#Notes#</cfif></textarea><!--- Include Carrier Rate Change --->
                            <div class="clear"></div>
                            <cfif not (request.qSystemSetupOptions.freightBroker EQ 1 OR request.qSystemSetupOptions.freightBroker EQ 2 )>
                                <input name="statusfreightBroker" ID="statusfreightBroker" type="hidden" value="0" />
                            </cfif>
                            <label class="space_it">&nbsp;</label>
                        </div>
                    </cfif>
                    <cfif request.qSystemSetupOptions.FreightBroker EQ 2>
                        <input name="statusfreightBroker" ID="statusfreightBroker" type="hidden" value="2" />
                    </cfif>
                    <div class="clear"></div>

                    <label class="space_it" style="width:135px;">About how many trips?*</label>
                    <div style="float: left;margin-right: 11px;margin-top: -1px;" >
                        <div style="float:left;">
                        <input class="mid-textbox-1" type="text" name="noOfTrips"  id="noOfTrips" value="#noOfTrips#" style="width:45px;" onkeyup="if (/\D/g.test(this.value)) this.value = this.value.replace(/\D/g,'')" maxlength="3">
                        </div>
                    </div>
                    <!--- <div class="clear"></div> --->

                    <label class="space_it" style="width:107px;padding-right: 2px;">Less than truck load</label>
                    <div style="float: left;margin-right: 11px;margin-top: -1px;" >
                        <div style="float:left;">
                            <input name="IsPartial" ID="IsPartial" type="checkbox" tabindex=6 class="small_chk" <cfif IsPartial is 1> checked="checked" </cfif> value="" />
                        </div>
                    </div>
                    <div class="clear"></div>
                      <cfif NOT (request.qSystemSetupOptions.freightBroker EQ 1 OR request.qSystemSetupOptions.freightBroker EQ 2)><div class="clear"></div></cfif>
                    <input type="hidden" name="dispatchHiddenValue" id="dispatchHiddenValue" value=""/>
                    <label class="space_it_medium dispatch_note" <cfif not (request.qSystemSetupOptions.freightBroker EQ 1 OR request.qSystemSetupOptions.freightBroker EQ 2)> style="margin-top:1.8%;width: 155px;"<cfelse>style="margin-top: 3%;width: 155px;"</cfif>>Internal Dispatch Notes</label>
                    <div class="clear"></div>
                    <textarea class="carrier-textarea-medium <cfif DispatchNotesToShow eq true>applynotesPl</cfif> <cfif request.qSystemSetupOptions1.editdispatchnotes EQ 0>displayDispatchNotesPopup</cfif>" style="margin-bottom: 0.5%" data-username="#session.userfullname#" name="dispatchNotes" id="dispatchNotes" tabindex=7 cols="" rows="" data-loadid="#url.loadid#" <cfif request.qSystemSetupOptions1.editdispatchnotes EQ 0>readonly</cfif>><cfif url.loadToBeCopied EQ 0>#replaceNoCase(replaceNoCase(dispatchNotes, ': AM',' AM', 'ALL'), ': PM',' PM', 'ALL')#</cfif></textarea>
                    <div class="dispatchNotesPopup">
                        <div class="modalHead">
                            <p>Dispatch Notes<span class="closModal">X</span></p>
                        </div>
                        <div class="modalBody">
                            <div style="float:left;;">
                                <label>SPOKE TO:</label>
                                <div class="clear"></div>
                                <input class="sm-input myElements dispatchNotesFields" name="dispatchNotesSpokeTo" id="dispatchNotesSpokeTo" value="" type="text" style="width: 150px;" placeholder="Click or Type here">
                            </div>
                             <div style="float:left;">
                                <label style="width: 140px;">CURRENT LOCATION:</label>
                                <div class="clear"></div>
                                <input class="sm-input myElements dispatchNotesFields" name="dispatchNotesCurrLocation" id="dispatchNotesCurrLocation" value="" type="text" style="width: 150px;" placeholder="Type text here">
                            </div>
                            <div style="float:left;">
                                <label>ETA:</label>
                                <div class="clear"></div>
                                <input class="sm-input myElements dispatchNotesFields" name="dispatchNotesETA" id="dispatchNotesETA" value="" type="text" style="width:100px;" placeholder="Type text here">
                            </div>
                            <div style="float:left;">
                                <label>STOP:</label>
                                <div class="clear"></div>
                                <select name="dispatchNotesETAStopNo" id="dispatchNotesETAStopNo" style="margin-left:0px;width:37px;" class="myElements dispatchNotesFields">
                                    <cfif structkeyexists(url,"loadid") and len(trim(url.loadid)) gt 1>
                                        <cfset stopCount = request.loadstopcount/2>
                                        <cfloop from="1" to="#stopCount#" index="ind">
                                            <option value="#ind#S" <cfif request.qLoads.LoadStatusStopNo EQ "#ind#S"> selected </cfif>>#ind#P</option>
                                            <option value="#ind#C" <cfif request.qLoads.LoadStatusStopNo EQ "#ind#C"> selected </cfif>>#ind#D</option>
                                        </cfloop>
                                    </cfif>
                                </select>
                            </div>
                            <div class="clear"></div>
                            <textarea class="dispatchPopupNotes" placeholder="Enter Dispatch Notes..." style="padding: 2px 2px 0 2px !important;margin-top: 10px !important;height:175px;"></textarea>
                            <div class="clear"></div>
                        </div>
                        <div class="modalFooter">
                            <span class="noteAdd">Add</span>
                        </div>
                    </div>
                    <div class="clear" style="height: 10px;"></div>
                    <label class="space_it" style="width:129px;">Critical Notes to Driver:</label>
                    <input class="sm-input myElements" tabindex="8" name="CriticalNotes" id="CriticalNotes" value="#CriticalNotes#" type="text" style="width: 241px;padding-right: 0;margin-right: 0 !important;margin-top: -2px;" maxlength="40">
                    <div class="clear"></div>
                    <label class="space_it_medium" id="labelcarrNotes" style="margin-top: 10px;width:300px;">#variables.freightBroker# Notes <cfif isDefined("variables.rateCon")>For <cfif variables.rateCon EQ 'Rate Con'>Rate Confirmation Report<cfelse>#variables.rateCon#</cfif></cfif>
                    </label>
                    <div class="clear"></div>
                    <textarea class="carrier-textarea-medium <cfif CarrierNotesToShow eq true>applynotesPl</cfif>" name="carrierNotes" id="carrierNotes" tabindex=8 cols="" rows="" maxlength="8000">#carrierNotes#</textarea>
                    <div class="clear"></div>

                </fieldset>
            </div>
            <div class="form-con">
                <fieldset>
                    <div class="right" style="height:76px">
                        <input type="hidden" value="#request.qSystemSetupOptions.minimumMargin#" id="minimumMargin">
                        <cfset carrierReportOnClick = "window.open('../reports/loadReportForCarrierConfirmation.cfm?loadid=#editid#&#session.URLToken#')">
                        <cfset CarrierWorkOrderImportOnClick = "window.open('../reports/CarrierWorkOrderImport.cfm?loadid=#editid#&#session.URLToken#')">
                        <cfset CarrierWorkOrderExportOnClick = "window.open('../reports/CarrierWorkOrderExport.cfm?loadid=#editid#&#session.URLToken#')">
                        <cfset customerReportOnClick = "window.open('../reports/CustomerInvoiceReport.cfm?loadid=#editid#&#session.URLToken#')">
                        <cfif structkeyexists(url,"loadid") and len(trim(url.loadid)) gt 1>
                            <div>
                                <div style="cursor:pointer;width:27px;background-color: ##bfbcbc;float: left;margin: 3px 0;text-align: center;">
                                    <img id="carrierReportImg" style="vertical-align:bottom;" src="images/black_mail.png" data-action="view">
                                </div>

                                <input id="carrierReportLink" style="width:110px !important;" type="button" class="black-btn tooltip"  value="#variables.rateCon#"
                                 <cfif carrierReportOnClick eq ""> disabled </cfif><cfif mailsettings OR request.qSystemSetupOptions.TextAPI NEQ 2>data-allowmail="true"<cfelse>data-allowmail="false"</cfif> />
                                <div style="cursor:pointer;width:27px;float: left;margin: 3px 0;text-align: center;">&nbsp;</div>
                                <cfif request.qSystemSetupOptions1.CopyLoadLimit NEQ 0>
                                    <input type="button" class="blue-btn"  value="Copy Load"  id="CopyLoad"  onclick="CopyLoad1('#url.loadid#','#session.URLToken#',#request.qSystemSetupOptions1.CopyLoadLimit#)" style="width:110px !important;">
                                </cfif>
                                <cfif session.currentusertype EQ "administrator" and structkeyexists(session,"rightslist") and len(trim(url.loadid)) gt 0 and variables.loaddisabledStatus and ListContains(session.rightsList,'UnlockLoad',',')>
                                    <input id="Unlock" name="unlock" type="button" class="green-btnUnlock" onClick="removeEditAccess('#url.loadid#','#session.empid#');" value="Unlock" style="width:100px !important;float:right;">
                                <cfelse>
                                    <cfif request.qcurAgentdetails.integratewithTran360 EQ false AND posttoTranscore EQ 1>
                                        <cfif structkeyexists(session,"rightslist") and len(trim(url.loadid)) gt 0 and variables.loaddisabledStatus and ListContains(session.rightsList,'UnlockLoad',',')>
                                            <input id="Unlock" name="unlock" type="button" class="green-btnUnlock" onClick="removeEditAccess('#url.loadid#','#session.empid#');" value="Unlock" style="width:100px !important;float:right;">
                                        <cfelse>
                                            <input id="saveLoad" name="save" type="submit" class="green-btn"   onClick="alert('Any changes you make will not be updated to the DAT Load Board because you do not have credentials setup on your User Profile.');javascript:return saveButStayOnPage('#url.loadid#');" onFocus="checkUnload();" value="Save" style="width:100px !important;float:right;">
                                        </cfif>
                                    <cfelseif request.qcurAgentdetails.loadBoard123 EQ false AND PostTo123LoadBoard EQ 1>
                                        <cfif structkeyexists(session,"rightslist") and len(trim(url.loadid)) gt 0 and variables.loaddisabledStatus and ListContains(session.rightsList,'UnlockLoad',',')>
                                            <input id="Unlock" name="unlock" type="button" class="green-btnUnlock" onClick="removeEditAccess('#url.loadid#','#session.empid#');" value="Unlock" style="width:100px !important;float:right;">
                                        <cfelse>
                                            <input id="saveLoad" name="save" type="submit" class="green-btn"  disabled onClick="alert('Any changes you make will not be updated to the 123Load Board because you do not have credentials setup on your User Profile.');javascript:return saveButStayOnPage('#url.loadid#');" onFocus="checkUnload();" value="Save" style="width:100px !important;float:right;">
                                        </cfif>
                                            <input name="notpostingTo123LoadBoard" value="1" type="hidden">
                                    <cfelse>
                                        <cfif structkeyexists(session,"rightslist") and len(trim(url.loadid)) gt 0 and variables.loaddisabledStatus and ListContains(session.rightsList,'UnlockLoad',',')>
                                            <input id="Unlock" name="unlock" type="button" class="green-btnUnlock" onClick="removeEditAccess('#url.loadid#','#session.empid#');" value="Unlock" style="width:100px !important;float:right;">
                                        <cfelse>
                                            <input id="saveLoad" name="save" type="submit"  class="green-btn"  onClick="return saveButStayOnPage('#url.loadid#');" onFocus="checkUnload();" value="Save" disabled="yes" style="width:101px !important;float:right;" />
                                        </cfif>
                                    </cfif>
                                </cfif>
                            </div>
                            <div class="clear"></div>
                            <div>
                                <div style="cursor:pointer;width:27px;background-color: ##bfbcbc;float: left;margin: 3px 0;text-align: center;">
                                <!--- envelop --->
                                </div>
                                <!--- BEGIN: Switch between Smart Phone e-Dispatch and Web e-Dispatch according to settings--->
                                <input id="carrierDispatch" name="carrierDispatch" type="button" class="black-btn" value="<cfif listFind("0,1", request.qSystemSetupOptions.EDispatchOptions)>Mobile #variables.carrierDispatch#<cfelseif request.qSystemSetupOptions.EDispatchOptions EQ 2>MP-Dispatch<cfelse>MP-GPS</cfif>" style="width:110px !important;"/>
                                <!--- END: Switch between Smart Phone e-Dispatch and Web e-Dispatch according to settings--->
                                <div class="dispatchMailsPopup">
                                    <div class="modalHead">
                                        <p>E-#variables.carrierDispatch# Email<span class="closdispatchMailsModal">X</span></p>
                                    </div>
                                    <div class="modalBody">
                                        <textarea class="dispatchMailsPopupContent" placeholder="Enter Emial Address">#emailList#</textarea>
                                        <div class="clear"></div>
                                    </div>
                                    <div class="modalFooter">
                                        <span class="dispatchMailsAdd">Add</span>
                                    </div>
                                </div>
                                <!--- END: Prevent already transcore synced load update from Agent has no Transcore Login setup in their profile Date:20 Sep 2013  --->
                                <cfif NOT ListContains(session.rightsList,'HideCustomerPricing',',') AND request.qLoads.CustomerReportButton NEQ '(NONE)'>

                                    <div style="cursor:pointer;width:27px;background-color: ##bfbcbc;float: left;margin: 3px 0;text-align: center;">
                                        <img id="custInvReportImg" style="vertical-align:bottom;" src="images/black_mail.png" data-action="view">
                                    </div>
                                    <input id="custInvReportLink" style="width:110px !important;" type="button" class="black-btn tooltip custInvReportLink" value="#replaceNoCase(replaceNoCase(request.qLoads.CustomerReportButton, "RATE ", "Customer "), "CANCELLED", "Invoice")#"  <cfif customerReportOnClick eq "">  disabled </cfif> <cfif mailsettings>data-allowmail="true"<cfelse>data-allowmail="false"</cfif>/>
                                </cfif>
                            </div>
                            <div class="clear"></div>
                            <div>
                                <div style="cursor:pointer;width:27px;background-color: ##bfbcbc;float: left;margin: 3px 0;text-align: center;">
                                </div>

                                <cfif request.qSystemSetupOptions.BOLReportFormat EQ 'Preprinted'>
                                    <input style="width:110px !important;" id="BOLReport"type="button" class="black-btn" value="B.O.L. Report" onClick="window.open('../reports/BOLReportPreprinted.cfm?loadid=#editid#&#session.URLToken#')"/>
                                <cfelse>
                                    <input style="width:110px !important;" type="button" id="BOLReport" class="black-btn" value="B.O.L. Report" onClick="self.location='index.cfm?event=BOLReport&loadid=#url.loadid#&#session.URLToken#'"/>
                                </cfif>
                                <!--- Promiles condition is blocked due to map issue using 1 EQ 2 --->
                                <cfif len(trim(request.qSystemSetupOptions.googleMapsPcMiler)) and len(trim(request.qcurAgentdetails.proMilesStatus))>
                                    <cfif val(request.qSystemSetupOptions.googleMapsPcMiler) EQ 1 AND request.qcurAgentdetails.proMilesStatus>
                                        <div style="cursor:pointer;width:27px;float: left;margin: 3px 0;text-align: center;">&nbsp;</div>
                                        <input style="width:110px !important;" name="map-button" type="button" class="black-btn" onClick="showfullmap('createFullMap.cfm',this.form, 'googlemap');" value="Google Map" />
                                    <cfelseif val(request.qSystemSetupOptions.googleMapsPcMiler) EQ 2>
                                        <div style="cursor:pointer;width:27px;float: left;margin: 3px 0;text-align: center;">&nbsp;</div>
                                        <Cfset encryptedDsn = ToBase64(Encrypt(application.DSN, 'load')) >
                                        <input style="width:110px !important;" name="map-button" type="button" class="black-btn" onClick="showfullmap('pcmiler',this.form, 'pcmiler', '#encryptedDsn#');" value="PCMiler Map" />
                                    <cfelse>
                                        <div style="cursor:pointer;width:27px;float: left;margin: 3px 0;text-align: center;">&nbsp;</div>
                                        <input style="width:110px !important;" name="map-button" type="button" class="black-btn" onClick="showfullmap('createFullMap.cfm',this.form, 'googlemap');" value="Google Map" />
                                    </cfif>
                                <cfelse>
                                    <div style="cursor:pointer;width:27px;float: left;margin: 3px 0;text-align: center;">&nbsp;</div>
                                    <input style="width:110px !important;" name="map-button" type="button" class="black-btn" onClick="showfullmap('createFullMap.cfm',this.form, 'googlemap');" value="Google Map" />
                                </cfif>
                                <!--- BEGIN: Prevent already transcore synced load update from Agent has no Transcore Login setup in their profile Date:20 Sep 2013  --->
                                <cfif request.qcurAgentdetails.integratewithTran360 EQ false AND posttoTranscore EQ 1>
                                    <cfif not (structkeyexists(session,"rightslist") and len(trim(url.loadid)) gt 0 and variables.loaddisabledStatus and ListContains(session.rightsList,'UnlockLoad',','))>
                                        <input name="saveexit" type="submit" class="green-btn"   onClick="alert('Any changes you make will not be updated to the DAT Load Board because you do not have credentials setup on your User Profile.');javascript:return saveButExitPage('#url.loadid#');" onfocus="checkUnload();"  value="Save & Exit"
                                                    style="width:100px !important; float:right; height:48px; position:relative; top:-28px; -webkit-background-size:contain; -moz-background-size:contain;  -o-background-size:contain; background-size:contain;"/>
                                    </cfif>
                                <cfelseif request.qcurAgentdetails.loadBoard123 EQ false AND PostTo123LoadBoard EQ 1>
                                    <cfif not (structkeyexists(session,"rightslist") and len(trim(url.loadid)) gt 0 and variables.loaddisabledStatus and ListContains(session.rightsList,'UnlockLoad',','))>
                                        <input name="saveexit" type="submit" class="green-btn"   onClick="alert('Any changes you make will not be updated to the 123Load Board because you do not have credentials setup on your User Profile.');javascript:return saveButExitPage('#url.loadid#');" onfocus="checkUnload();"  value="Save & Exit"
                                                    style="width:100px !important; float:right; height:48px; position:relative; top:-28px; -webkit-background-size:contain; -moz-background-size:contain;  -o-background-size:contain; background-size:contain;"/>
                                    </cfif>
                                <cfelse>
                                    <cfif not (structkeyexists(session,"rightslist") and len(trim(url.loadid)) gt 0 and variables.loaddisabledStatus and ListContains(session.rightsList,'UnlockLoad',','))>
                                        <input name="saveexit" type="submit" class="green-btn"  onclick="javascript:return saveButExitPage('#url.loadid#');" onFocus="checkUnload();" value="Save & Exit" disabled="yes"
                                                    style="width:100px !important; float:right; height:48px; position:relative; top:-28px; -webkit-background-size:contain; -moz-background-size:contain;  -o-background-size:contain; background-size:contain;">
                                    </cfif>
                                </cfif>
                                <div class="clear"></div>
                            </div>
                            <div class="clear"></div>
                        <cfelse>
                        <!--- temploadid added for fileattachment --->
                            <input type="hidden" name="tempLoadId" value="#tempLoadId#">
                            <cfif structkeyexists(session,"rightslist") and len(trim(url.loadid)) gt 0 and variables.loaddisabledStatus and ListContains(session.rightsList,'UnlockLoad',',')>
                                <input id="Unlock" name="unlock" type="button" class="green-btnUnlock" onClick="removeEditAccess('#url.loadid#','#session.empid#');" value="Unlock" style="width:100px !important;float:right;">
                            <cfelse>
                                <cfif local.lockloadStatsFlag>
                                    <input id="save" name="save" type="button" class="green-btn" value="Save" />
                                <cfelse>
                                    <input name="save" type="submit" class="green-btn"  onClick="return saveButStayOnPage('#url.loadid#');" onFocus="checkUnload();" value="Save" disabled="yes" />
                                </cfif>
                            </cfif>
                            <cfif not (structkeyexists(session,"rightslist") and len(trim(url.loadid)) gt 0 and variables.loaddisabledStatus and ListContains(session.rightsList,'UnlockLoad',','))>
                                <cfif local.lockloadStatsFlag>
                                    <input id="saveexit" name="saveexit" type="button" class="green-btn" value="Save & Exit" />
                                <cfelse>
                                    <input name="saveexit" type="submit" class="green-btn" <cfif local.lockloadStatsFlag > disabled </cfif> onClick="return saveButExitPage('2');" onFocus="checkUnload();" value="Save & Exit" disabled="yes"/>
                                </cfif>

                            </cfif>
                        </cfif>
                        <input type="hidden" name="loadToSaveWithoutExit" id="loadToSaveWithoutExit" value="0" />
                        <input type="hidden" name="loadToSaveAndExit" id="loadToSaveAndExit" value="0" />
                        <input type="hidden" name="loadToSaveToCarrierPage" id="loadToSaveToCarrierPage" value="" />
                        <input type="hidden" name="loadToCarrierFilter" id="loadToCarrierFilter" value="0" />
                        <input type="hidden" name="loadToCarrierURL" id="loadToCarrierURL" value="" />
                        <input type="hidden" name="frieghtBroker" id="frieghtBroker" value="#request.qSystemSetupOptions.freightBroker#" />
                        <input type="hidden" name="iscarrier" id="iscarrier" <cfif structKeyexists(request,"qLoads") AND structKeyexists(request.qLoads,"Iscarrier")> value="#request.qLoads.Iscarrier#"<cfelse>value="0"</cfif> />
                    </div>
                    <div class="clear"  <cfif ListContains(session.rightsList,'HideFinancialRates',',')>style="height: 323px;"</cfif>></div>
                    <div class="calculationblock" <cfif ListContains(session.rightsList,'HideFinancialRates',',')>style="display:none;"</cfif>>
                        <table style="border-collapse: collapse;border-spacing: 0;">
                            <colgroup>
                                <col width="15%">
                                <col width="10%">
                                <col width="3%" >
                                <col width="10%">
                                <col width="5%" >
                                <col>
                            </colgroup>
                            <thead style="background-color: ##82bbef;">
                                <tr style="height: 25px;">
                                    <th>&nbsp;</th>
                                    <th><label class="custlabel" style="text-align: center;padding:0px; margin:0px;color: ##fff;">MILES</label></th>
                                    <th>&nbsp;</th>
                                    <th><label class="custlabel2" style="text-align: center;padding:0px; margin:0px;color: ##fff;">RATE</label></th>
                                    <th>&nbsp;</th>
                                    <th><label class="custlabel1" style="text-align: left;padding:0px; margin:0px;color: ##fff;margin-left: 20px;">AMOUNT</label></th>
                                </tr>
                            </thead>
                            <tbody>
                                <tr><td colspan="6" style="height: 5px;"></td></tr>
                                <tr>
                                    <td><label>Customer Miles</label></td>
                                    <td><input class="mid-textbox-1 <CFIF not FindNoCase('ipad;','#CGI.HTTP_USER_AGENT#') GREATER THAN 0>  disabledLoadInputs </cfif>" style="text-align:right;" value="#DecimalFormat(0.00)#" id="CustomerMilesCalc" name="CustomerMilesCalc" type="text" disabled required="no" /></td>
                                    <td>x</td>
                                    <td>
                                        <cfif ListContains(session.rightsList,'HideCustomerPricing',',')>
                                            <input class="mid-textbox-1" style="text-align:right;" type="text" value=""/>
                                        </cfif>
                                        <input class="mid-textbox-1 dollarField" style="text-align:right;" id="CustomerRatePerMile" name="CustomerRatePerMile" type="<cfif ListContains(session.rightsList,'HideCustomerPricing',',')>hidden<cfelse>text</cfif>" value="#DollarFormat(CustomerRatePerMile)#" required="no" onBlur="customerRatePerMileChanged();"/>
                    
                                    </td>
                                    <td>=</td>
                                    <td>
                                        <cfif ListContains(session.rightsList,'HideCustomerPricing',',')>
                                            <input class="mid-textbox-1 disabledLoadInputs" style="text-align:right;<cfif ( structkeyexists(url,"loadid") and len(trim(url.loadid)) gt 1 )>margin-left: 10px;</cfif>" type="text" value="" required="no" disabled />
                                        </cfif>
                                        <input class="mid-textbox-1 <CFIF not FindNoCase('ipad;','#CGI.HTTP_USER_AGENT#') GREATER THAN 0>  disabledLoadInputs </cfif>" style="text-align:right;<cfif ( structkeyexists(url,"loadid") and len(trim(url.loadid)) gt 1 )>margin-left: 10px;</cfif>" id="CustomerMilesTotalAmount" name="CustomerMilesTotalAmount" value="$0.00" type="<cfif ListContains(session.rightsList,'HideCustomerPricing',',')>hidden<cfelse>text</cfif>" required="yes" disabled message="Please enter Customer Rate for calculation of Total Amount of Customer Miles" />
                                    </td>
                                    </tr>
                                    <tr>
                                    <td><label>#variables.freightBroker# Miles</label></td>
                                    <td><input class="mid-textbox-1 <CFIF not FindNoCase('ipad;','#CGI.HTTP_USER_AGENT#') GREATER THAN 0>  disabledLoadInputs </cfif>" style="text-align:right;" value="0.00" id="CarrierMilesCalc" name="CarrierMilesCalc" type="text" disabled required="no" /></td>
                                    <td>x</td>
                                    <td><input class="mid-textbox-1 dollarField" style="text-align:right;" id="CarrierRatePerMile" name="CarrierRatePerMile" type="text" value="#DollarFormat(CarrierRatePerMile)#" required="no" onBlur="carrierRatePerMileChanged();" onchange="" data-oldValue="#DollarFormat(CarrierRatePerMile)#"/></td>
                                    <td>=</td>
                                    <td><input class="mid-textbox-1 <CFIF not FindNoCase('ipad;','#CGI.HTTP_USER_AGENT#') GREATER THAN 0>  disabledLoadInputs </cfif>" style="text-align:right;<cfif ( structkeyexists(url,"loadid") and len(trim(url.loadid)) gt 1 )>margin-left: 10px;</cfif>" id="CarrierMilesTotalAmount" name="CarrierMilesTotalAmount" type="text" value="$0.00" required="yes" disabled message="Please enter #variables.freightBroker# Rate for calculation of Total Amount of #variables.freightBroker# Miles" /></td>
                                </tr>
                            </tbody>
                        </table>
                    </div>
                    <div class="clear"></div>
                    <cfif TotalCustomerCharges gt 0>
                        <cfset perc=(1-(TotalCarrierCharges/TotalCustomerCharges))>
                        <cfelse>
                        <cfset perc=0>
                    </cfif>
                    <div class="calculationCustomerBlock" <cfif ListContains(session.rightsList,'HideFinancialRates',',')>style="display:none;"</cfif>>
                        <table style="border-collapse: collapse;border-spacing: 0;">
                            <colgroup>
                                <col width="15%">
                                <col width="10%">
                                <col width="3%" >
                                <col width="10%">
                                <col width="5%" >
                                <col>
                            </colgroup>
                            <thead style="background-color: ##82bbef;">
                                <tr style="height: 25px;">
                                    <th>&nbsp;</th>
                                    <th style="border-right:1px solid ##b3b3b3;"><label class="custlabel" style="text-align: center;padding:0px; margin:0px;color: ##fff;">Customer</label></th>
                                    <th>&nbsp;</th>
                                    <th><label class="custlabel2" style="text-align: center;padding:0px; margin:0px;color: ##fff;">#variables.freightBroker#<cfif variables.freightBroker EQ 'Driver'>(s)</cfif></label></th>
                                    <cfif request.qSystemSetupOptions.ShowMaxCarrRateInLoadScreen EQ 1>
                                        <th><label class="custlabel2" style="text-align: left;padding:0px; margin:0px;color: ##fff;font-size: 11px;width: 73px;">Maximum<br>Carr.Rate</label></th>
                                    <cfelse>
                                        <th>&nbsp;</th>
                                    </cfif>
                                    <th style="border-left:1px solid ##b3b3b3;">
                                        <cfif ListContains(session.rightsList,'HideCustomerPricing',',')>
                                            <label class="custlabel" style="width: auto;margin-left: 30px;padding:0px; margin:0px;color: ##fff;">Profit</label>
                                        </cfif>
                                        <label id="percentageProfit" class="custlabel" style="width: auto;<cfif ListContains(session.rightsList,'HideCustomerPricing',',')>display:none;</cfif><cfif request.qSystemSetupOptions.ShowMaxCarrRateInLoadScreen>padding-left: 5px;<cfelse>padding:0px;</cfif> margin:0px;color: ##fff;">x% Profit</label>
                                    </th>
                                </tr>
                            </thead>
                            <tbody>
                                <td colspan="6" style="height: 5px;"></td>
                                <tr>
                                    <td><label <cfif request.qSystemSetupOptions.UseDirectCost OR request.qSystemSetupOptions.ShowMaxCarrRateInLoadScreen EQ 1>style="width: 75px;"</cfif>>Flat Rate</label></td>
                                    <td style="border-right:1px solid ##b3b3b3;">
                                        <cfif ListContains(session.rightsList,'HideCustomerPricing',',')>
                                            <input class="mid-textbox-1 dollarField" style="text-align:right;" type="text" value=""/>
                                        </cfif>
                                        <input class="mid-textbox-1 dollarField" style="text-align:right;" id="CustomerRate" name="CustomerRate" type="<cfif ListContains(session.rightsList,'HideCustomerPricing',',')>hidden<cfelse>text</cfif>"  onblur="updateTotalAndProfitFields();" validate="float" message="Please endter customer rate." value="#DollarFormat(CustomerRate)#"/>
                                    </td>
                                    <td>&nbsp;</td>
                                    <td><input <cfif CustomDriverPay EQ 1> readonly </cfif> class="mid-textbox-1 dollarField" style="text-align:right;<cfif CustomDriverPay EQ 1>background-color:##e3e3e3;</cfif>" id="CarrierRate" name="CarrierRate" type="text" onblur="updateTotalAndProfitFields();" validate="float" message="Please enter #variables.freightBroker# rate." value="#DollarFormat(CarrierRate)#" data-oldValue="#DollarFormat(CarrierRate)#"/></td>
                                    <input id="MaxCarrierRate" name="MaxCarrierRate" value="#MaxCarrierRate#" type="hidden"  />
                                    <cfif request.qSystemSetupOptions.ShowMaxCarrRateInLoadScreen EQ 1>
                                        <td style="border-right:1px solid ##b3b3b3;"><label style="display:none;">MaxCarrRate</label><input type="checkBox" name="LimitCarrierRate" id="LimitCarrierRate" class="mid-textbox-1" style="width: 20px;margin-top: 3px;<cfif NOT ListContains(session.rightsList,'ShowMaxCarrRateInLoadScreen',',')>pointer-events: none;</cfif>" <cfif LimitCarrierRate EQ 1>checked</cfif>></td>
                                    <cfelse>
                                        <td style="border-right:1px solid ##b3b3b3;">&nbsp;</td>
                                    </cfif>

                                    <td style="padding-left:2px;">
                                        <cfif ListContains(session.rightsList,'HideCustomerPricing',',')>
                                            <input class="mid-textbox-1 <CFIF not FindNoCase('ipad;','#CGI.HTTP_USER_AGENT#') GREATER THAN 0>  disabledLoadInputs </cfif>" style="text-align:right;"  type="text" value="" disabled />
                                        </cfif>
                                        <input class="mid-textbox-1 <CFIF not FindNoCase('ipad;','#CGI.HTTP_USER_AGENT#') GREATER THAN 0>  disabledLoadInputs </cfif>" style="text-align:right;" id="flatRateProfit" name="flatRateProfit" type="<cfif ListContains(session.rightsList,'HideCustomerPricing',',')>hidden<cfelse>text</cfif>" value="#DollarFormat(0)#" disabled />
                                    </td>
                                </tr>
                                <tr>
                                    <td><label <cfif request.qSystemSetupOptions.UseDirectCost OR request.qSystemSetupOptions.ShowMaxCarrRateInLoadScreen EQ 1>style="width: 75px;"</cfif>>Commodities</label></td>
                                    <td style="border-right:1px solid ##b3b3b3;">
                                        <cfif ListContains(session.rightsList,'HideCustomerPricing',',')>
                                            <input class="mid-textbox-1 <CFIF not FindNoCase('ipad;','#CGI.HTTP_USER_AGENT#') GREATER THAN 0>  disabledLoadInputs </cfif>" style="text-align:right;" value="" disabled type="text"  />
                                        </cfif>
                                        <input class="mid-textbox-1 <CFIF not FindNoCase('ipad;','#CGI.HTTP_USER_AGENT#') GREATER THAN 0>  disabledLoadInputs </cfif>" style="text-align:right;" id="TotalCustcommodities" name="TotalCustcommodities" value="#DollarFormat(0)#" readonly type="<cfif ListContains(session.rightsList,'HideCustomerPricing',',')>hidden<cfelse>text</cfif>"  />
                                    </td>
                                    <td>&nbsp;</td>
                                    <td><input class="mid-textbox-1 <CFIF not FindNoCase('ipad;','#CGI.HTTP_USER_AGENT#') GREATER THAN 0>  disabledLoadInputs </cfif>" style="text-align:right;" id="TotalCarcommodities" name="TotalCarcommodities" value="#DollarFormat(0)#" readonly type="text"  /></td>
                                    <cfif not request.qSystemSetupOptions.UseDirectCost OR NOT request.qSystemSetupOptions.ShowMaxCarrRateInLoadScreen>
                                        <td style="border-right:1px solid ##b3b3b3;">&nbsp;</td>
                                    <cfelseif request.qSystemSetupOptions.UseDirectCost AND request.qSystemSetupOptions.ShowMaxCarrRateInLoadScreen>
                                        <td style="border-right:1px solid ##b3b3b3;">&nbsp;</td>
                                    </cfif>
                                    <td style="padding-left:2px;">
                                        <cfif ListContains(session.rightsList,'HideCustomerPricing',',')>
                                            <input class="mid-textbox-1 <CFIF not FindNoCase('ipad;','#CGI.HTTP_USER_AGENT#') GREATER THAN 0>  disabledLoadInputs </cfif>" style="text-align:right;"  type="text" value="" disabled  />
                                        </cfif>
                                        <input class="mid-textbox-1 <CFIF not FindNoCase('ipad;','#CGI.HTTP_USER_AGENT#') GREATER THAN 0>  disabledLoadInputs </cfif>" style="text-align:right;" id="carcommoditiesProfit" name="carcommoditiesProfit" type="<cfif ListContains(session.rightsList,'HideCustomerPricing',',')>hidden<cfelse>text</cfif>" value="#DollarFormat(0)#" disabled  />
                                    </td>
                                </tr>
                                <tr>
                                    <td><label <cfif request.qSystemSetupOptions.UseDirectCost OR request.qSystemSetupOptions.ShowMaxCarrRateInLoadScreen EQ 1>style="width: 75px;"</cfif>>Miles Charge</label></td>
                                    <td style="border-right:1px solid ##b3b3b3;">
                                        <cfif ListContains(session.rightsList,'HideCustomerPricing',',')>
                                            <input class="mid-textbox-1 <CFIF not FindNoCase('ipad;','#CGI.HTTP_USER_AGENT#') GREATER THAN 0>  disabledLoadInputs </cfif>" style="text-align:right;"  disabled type="text" value=""  />
                                        </cfif>
                                        <input class="mid-textbox-1 <CFIF not FindNoCase('ipad;','#CGI.HTTP_USER_AGENT#') GREATER THAN 0>  disabledLoadInputs </cfif>" style="text-align:right;" id="CustomerMiles" name="CustomerMiles" readonly type="<cfif ListContains(session.rightsList,'HideCustomerPricing',',')>hidden<cfelse>text</cfif>" value="#DollarFormat(0)#"  />
                                    </td>
                                    <td style="border-bottom:1px solid ##b3b3b3;">&nbsp;</td>
                                    <td style="border-bottom:1px solid ##b3b3b3;"><input class="mid-textbox-1 <CFIF not FindNoCase('ipad;','#CGI.HTTP_USER_AGENT#') GREATER THAN 0>  disabledLoadInputs </cfif>" style="text-align:right;" id="CarrierMiles" name="CarrierMiles" type="text" readonly value="#DollarFormat(0)#"  /></td>
                                    <cfif not request.qSystemSetupOptions.UseDirectCost OR NOT request.qSystemSetupOptions.ShowMaxCarrRateInLoadScreen>
                                        <td style="border-right:1px solid ##b3b3b3;border-bottom:1px solid ##b3b3b3;">&nbsp;</td>
                                    <cfelseif request.qSystemSetupOptions.UseDirectCost AND request.qSystemSetupOptions.ShowMaxCarrRateInLoadScreen>
                                        <td style="border-right:1px solid ##b3b3b3;border-bottom:1px solid ##b3b3b3;">&nbsp;</td>
                                    </cfif>
                                    <td style="padding-left:2px;">
                                        <cfif ListContains(session.rightsList,'HideCustomerPricing',',')>
                                            <input class="mid-textbox-1 <CFIF not FindNoCase('ipad;','#CGI.HTTP_USER_AGENT#') GREATER THAN 0>  disabledLoadInputs </cfif>" style="text-align:right;" type="text" value="" disabled />
                                        </cfif>
                                        <input class="mid-textbox-1 <CFIF not FindNoCase('ipad;','#CGI.HTTP_USER_AGENT#') GREATER THAN 0>  disabledLoadInputs </cfif>" style="text-align:right;" id="amountOfMilesProfit" name="amountOfMilesProfit" type="<cfif ListContains(session.rightsList,'HideCustomerPricing',',')>hidden<cfelse>text</cfif>" value="#DollarFormat(0)#" disabled />
                                    </td>
                                </tr>
                                <tr>
                                    <td><label style="color:red;<cfif request.qSystemSetupOptions.UseDirectCost OR request.qSystemSetupOptions.ShowMaxCarrRateInLoadScreen EQ 1>width:75px;</cfif>">Advance Payment(s)</label></td>
                                    <td style="border-right:1px solid ##b3b3b3;">
                                        <cfif ListContains(session.rightsList,'HideCustomerPricing',',')>
                                            <input class="mid-textbox-1 <CFIF not FindNoCase('ipad;','#CGI.HTTP_USER_AGENT#') GREATER THAN 0>  disabledLoadInputs </cfif>" style="text-align:right;color:##0fbc65 !important;" disabled type="textcfif>" value=""  />
                                        </cfif>
                                        <input class="mid-textbox-1 <CFIF not FindNoCase('ipad;','#CGI.HTTP_USER_AGENT#') GREATER THAN 0>  disabledLoadInputs </cfif>" style="text-align:right;color:red !important;" id="AdvancePaymentsCustomer" name="AdvancePaymentsCustomer" disabled type="<cfif ListContains(session.rightsList,'HideCustomerPricing',',')>hidden<cfelse>text</cfif>" value="#DollarFormat(-1*variables.custAdvancepayments)#"  />
                                        <input type="hidden" name="AdvancePaymentsCustomerHidden" id="AdvancePaymentsCustomerHidden" value="#variables.custAdvancepayments#">
                                       
                                    </td>
                                    <td>&nbsp;</td>
                                    <cfif variables.carrierAdvancepayments lt 0>
                                    <td><input class="mid-textbox-1 <CFIF not FindNoCase('ipad;','#CGI.HTTP_USER_AGENT#') GREATER THAN 0>  disabledLoadInputs </cfif>" style="text-align:right;color:red !important;" id="AdvancePaymentsCarrier" name="AdvancePaymentsCarrier" type="text" disabled value="$#Numberformat(variables.carrierAdvancepayments,"___.__")#"  /></td>
                                    
                                    <input type="hidden" name="AdvancePaymentsCarrierhidden" id="AdvancePaymentsCarrierhidden" value="#variables.carrierAdvancepayments#">
                                    <cfelse>
                                    <td><input class="mid-textbox-1 <CFIF not FindNoCase('ipad;','#CGI.HTTP_USER_AGENT#') GREATER THAN 0>  disabledLoadInputs </cfif>" style="text-align:right;color:red !important;" id="AdvancePaymentsCarrier" name="AdvancePaymentsCarrier" type="text" disabled value="#DollarFormat(-1*variables.carrierAdvancepayments)#"  />
                                    <cfif request.qSystemSetupOptions.UseDirectCost>
                                        <p style="font-weight: bold;font-size: 10px;font-family: 'Arial Black';margin-top: 0px;width: 103px;position: absolute;margin-top: 18px;margin-left: 73px;">DIRECT COSTS</p>
                                    </cfif>
                                    </td>
                                    <input type="hidden" name="AdvancePaymentsCarrierhidden" id="AdvancePaymentsCarrierhidden" value="#variables.carrierAdvancepayments#">
                                    </cfif>
                                    <cfif request.qSystemSetupOptions.AutomaticFactoringFee eq 1>
                                        <td><cfif not ListContains(session.rightsList,'HideCustomerPricing',',')><span id="spanFF">#FF#</span>%FF</cfif></td>
                                        <cfset FactoringFeeAmount = (TotalCustomerCharges * FF) /100>
                                        <td style="padding-left:2px;">
                                            <input type="hidden" name="FactoringFeePercent" id="FactoringFeePercent" value="#FF#">
                                            <cfif ListContains(session.rightsList,'HideCustomerPricing',',')>
                                                <input class="mid-textbox-1 disabledLoadInputs" style="text-align:right" type="text" value="" disabled>
                                            </cfif>
                                            <input class="mid-textbox-1 disabledLoadInputs" style="text-align:right" type="<cfif ListContains(session.rightsList,'HideCustomerPricing',',')>hidden<cfelse>text</cfif>" name="FactoringFeeAmount" id="FactoringFeeAmount" value="-#DollarFormat(FactoringFeeAmount)#" disabled>
                                        </td>
                                    </cfif>
                                </tr>
                                <tr style="line-height: 2px;"><td colspan="6">&nbsp;</td></tr>
                                <tr style="border-bottom: 1px solid ##b3b3b3; border-top: 1px solid ##b3b3b3; line-height: 2px;"><td colspan="6">&nbsp;</td></tr>
                                <tr style="line-height: 3px;background-color: ##82bbef;"><td colspan="6">&nbsp;</td></tr>
                                <tr style="background-color: ##82bbef;">
                                    <td><label style="color: ##fff;font-size: 13px;<cfif request.qSystemSetupOptions.UseDirectCost OR request.qSystemSetupOptions.ShowMaxCarrRateInLoadScreen EQ 1>width: 75px;</cfif>">TOTALS</label></td>
                                    <td>
                                    <cfif ListContains(session.rightsList,'HideCustomerPricing',',')>
                                        <input class="mid-textbox-1 <CFIF not FindNoCase('ipad;','#CGI.HTTP_USER_AGENT#') GREATER THAN 0>  disabledLoadInputs </cfif>" style="text-align:right;" value="" disabled type="text"  />
                                    </cfif>
                                    <input class="mid-textbox-1 <CFIF not FindNoCase('ipad;','#CGI.HTTP_USER_AGENT#') GREATER THAN 0>  disabledLoadInputs </cfif>" style="text-align:right;font-weight: bold;" id="TotalCustomerCharges" name="TotalCustomerChargesDisplay" value="#DollarFormat(TotalCustomerCharges)#" disabled type="<cfif ListContains(session.rightsList,'HideCustomerPricing',',')>hidden<cfelse>text</cfif>"  />
                                    <input id="TotalCustomerChargesHidden" name="TotalCustomerCharges" value="#TotalCustomerCharges#" type="hidden"  />
                                    </td>
                                    <td><cfif request.qSystemSetupOptions.UseDirectCost><i class="fa fa-minus" style="margin-left: -5px;"></i><cfelse>&nbsp;</cfif></td>
                                    <td>
                                    <input class="mid-textbox-1 <CFIF not FindNoCase('ipad;','#CGI.HTTP_USER_AGENT#') GREATER THAN 0>  disabledLoadInputs </cfif>" style="text-align:right;font-weight: bold;" id="TotalCarrierCharges" name="TotalCarrierChargesDisplay" value="#DollarFormat(TotalCarrierCharges)#" disabled type="text"  />
                                    <input id="TotalCarrierChargesHidden" name="TotalCarrierCharges" value="#TotalCarrierCharges#" type="hidden"  />
                                    <cfif request.qSystemSetupOptions.UseDirectCost><i class="fa fa-minus" style="margin-left: -5px;width: 0px;margin-top: 7px;"></i></cfif>
                                    </td>

                                    <td>
                                        <cfif request.qSystemSetupOptions.UseDirectCost>
                                            <input class="mid-textbox-1 disabledLoadInputs myElements" style="text-align:right;font-weight: bold;" id="TotalDirectCost" name="TotalDirectCostDisplay" value="#DollarFormat(TotalDirectCost)#" disabled="" type="text">
                                            <input id="TotalDirectCostHidden" name="TotalDirectCost" value="#TotalDirectCost#" type="hidden"  />

                                        </cfif>
                                    </td>
                                    <td>
                                        <cfif request.qSystemSetupOptions.UseDirectCost>
                                            <b style="float: left;margin-top: 3px;margin-left: -6px;margin-right: 2px;font-size: 15px;">=</b>
                                        </cfif>
                                        <cfif ListContains(session.rightsList,'HideCustomerPricing',',')>
                                            <input class="mid-textbox-1 <CFIF not FindNoCase('ipad;','#CGI.HTTP_USER_AGENT#') GREATER THAN 0>  disabledLoadInputs </cfif>" style="text-align:right;"  value="" disabled type="text"  />
                                        </cfif>
                                        <input class="mid-textbox-1 <CFIF not FindNoCase('ipad;','#CGI.HTTP_USER_AGENT#') GREATER THAN 0>  disabledLoadInputs </cfif>" style="text-align:right;font-weight: bold;<cfif request.qSystemSetupOptions.UseDirectCost>width:55px;</cfif>" id="totalProfit" name="totalProfit"  value="#DollarFormat(totalProfit)#" disabled type="<cfif ListContains(session.rightsList,'HideCustomerPricing',',')>hidden<cfelse>text</cfif>"  />
                                    </td>
                                </tr>
                                <tr style="border-bottom: 1px solid ##b3b3b3; border-top: 1px solid ##b3b3b3;"><td colspan="6"></td></tr>
                                <tr style="line-height: 2px;"><td colspan="6">&nbsp;</td></tr>
                                <tr>
                                    <td>&nbsp;</td>
                                    <td colspan="5">
                                        <label style="text-align: left;width: 55px;padding-right: 2px;margin-left: -10px;">Cust. Paid</label>
                                        <input name="CustomerPaid" id="CustomerPaid" type="checkbox" <cfif CustomerPaid EQ 1>checked</cfif> class="check" style="width: 18px";/>

                                        <label style="text-align: left;width: 55px;margin-left: -2px;padding-right: 2px;">Carr. Paid</label>
                                        <input name="CarrierPaid" id="CarrierPaid" type="checkbox" <cfif CarrierPaid EQ 1>checked</cfif> class="check" style="width: 18px";/>
                                    </td>
                                </tr>
                            </tbody>
                        </table>
                    </div>
                    <div class="clear"></div>
                    <div id="checkProfit" style="color: red; text-align: center;"></div>
                    <div class="clear"></div>
                    <input class="mid-textbox-1" id="perc" name="perc" value="#DollarFormat(perc)#" readonly="true" type="hidden"/>
                    <div class="clear"></div>
                    <cfif not request.qSystemSetupOptions.commodityWeight>
                        <div style="float:right">
                            <label style="margin-left: -59px; margin-top: 10px;">Weight</label>
                            <input class="floatField" data-fieldname="Weight" id="weightStop1" type="text" name="weightStop1" value="#weight1#" tabindex="" style="margin-top: 6px; width: 50px;">
                        </div>
                        <div class="clear"></div>
                    </cfif>
                    <div  <cfif request.qSystemSetupOptions.AllowLoadentry EQ 1>style="margin-top: 38px;"<cfelseif request.qSystemSetupOptions.FreightBroker EQ 1>style="margin-top: 32px;"<cfelseif request.qSystemSetupOptions.FreightBroker EQ 0>style="margin-top: 32px;"<cfelse>style="margin-top: 32px;"</cfif> id='pricingNotes'>
                        <label class="space_it_medium margin_top" id="label_cic" style="<cfif not request.qSystemSetupOptions.commodityWeight> margin-top: 2px;width: 175px; <cfelse> margin-top: 0px;width: 175px;</cfif>">Customer Invoice Comments</label>
                        <div class="clear"></div>
                        <textarea class="carrier-textarea-medium" name="pricingNotes" id="pricingnotes" tabindex=8 cols="" rows="" style="margin-left:0px; width:391px;" >#PricingNotes#</textarea>
                    </div>
                    <div class="clear"></div>
                </fieldset>
            </div>
            <input name="customerID" id="customerID" type="hidden" value="#customerID#" />
            <input name="isPayer" id="isPayer" type="hidden" value="#isPayer#" />
            <div class="clear"></div>

<!---Color Change #82bbef --->
            <div class="white-con-area" style="height: 36px;background-color: ##82bbef;width: 932px;">
                <div style="padding: 0 18px;overflow:hidden;">
                    <h2 style="color:white;font-weight:bold;float: left;">BILL TO:</h2>
                    <cfif request.qsystemoptions.BillFromCompanies EQ 1>
                        <h2 style="color:white;font-weight:bold;float: right;">BILL FROM:
                            <select name="BillFromCompany" id="BillFromCompany">
                                <cfif request.qsystemoptions.DefaultBillFromAsCompany EQ 0>
                                    <option value="" selected>Select</option>
                                </cfif>
                                <option value="#session.companyid#" <cfif request.qsystemoptions.DefaultBillFromAsCompany EQ 0 AND "#session.companyid#" EQ BillFromCompany>selected="selected"</cfif>>#request.qsystemoptions.companyname#</option>
                                <cfloop query="request.qBillFromCompanies">
                                    <option value="#request.qBillFromCompanies.BillFromCompanyID#"<cfif request.qBillFromCompanies.BillFromCompanyID eq  BillFromCompany> selected="selected" </cfif>>#request.qBillFromCompanies.CompanyName#</option>
                                </cfloop>
                            </select>
                        </h2>
                    </cfif>
                    <cfif request.qSystemSetupOptions.ForeignCurrencyEnabled>
                        <div style="float:right;padding:10px 0;">
                            <label>Currency</label>
                            <select name="defaultCustomerCurrency" id="defaultCustomerCurrency">
                                <cfloop query = "request.qGetCurrencies"> 
                                    <option value="#CurrencyID#" <cfif customerCurrency eq CurrencyID> selected="selected" </cfif>>#CurrencyNameISO#(#CurrencyName#)</option>
                                </cfloop>       
                            </select>
                        </div>
                    </cfif>
                </div>
            </div>
            <div class="form-con" style="width: 480px;">
                <fieldset>
                    <label class="bold">Customer*</label>
                    <input name="cutomerIdAuto" id="cutomerIdAuto" value="#loadCustomerName#" tabindex=9 title="Type text here to display list." />
                    <cfif ListContains(session.rightsList,'DeleteLoad',',')>
                        <div class="" style="margin-top: 5px;margin-right: 50px;">
                            <img src="images/clearRed.gif" style="height:14px;width:14px;"  title="Click here to clear the customer"  onclick="clearTheCustomer();">
                        </div>
                        <div class="clear"></div>
                    </cfif>
                    <input type="hidden" name="cutomerIdAutoValueContainer" id="cutomerIdAutoValueContainer" value="#customerID#" required="yes" message="Please select a Customer" />
                    <div class="clear"></div>
                    <label>Customer Info</label>
                    <div id="CustInfo1">
                        <label class="field-textarea" tabindex=10 style="width:188px;"><b><a href="" >&nbsp;&nbsp;</a></b><br/>
                        &nbsp;&nbsp;</label>
                        <div class="clear"></div>
                        <label>Contact</label>
                        <input name="CustomerContact" value="">
                        <div class="clear"></div>
                        <label>Tel</label>
                        <input name="customerPhone" value="" style="width: 89px;">
                        <label class="space_load">Ext</label>
                        <input name="customerPhoneExt" value="" style="width: 31px;" maxlength="30">
                        <div class="clear"></div>
                        <label>Cell</label>
                        <input name="customerCell" value="" style="width: 90px;">
                        <label class="space_load">Fax</label>
                        <input name="customerFax" value="" style="width: 90px;">
                        <div class="clear"></div>
                        <label>Email</label>
                        <input name="CustomerEmail" value=""  style="width: 248px;">
                        <div class="clear"></div>
                    </div>
                    <label>PO##</label>
                    <input name="customerPO" type="text" value="#customerPO#" tabindex=16 class="sm-input disAllowHash" style="width:93px;" maxlength="50" />
                    <label class="space_it_little">BOL##</label>
                    <input name="customerBOL" type="text" value="#BOLNum#" tabindex=16 class="sm-input disAllowHash" style="width:92px;" maxlength="30" />
                    <div class="clear"></div>
                    <cfif request.qSystemSetupOptions.showReadyArriveDate eq true>
                        <label>Ready Date</label>
                        <div style="position:relative;float:left;">
                        <div style="float:left;">
                        <input type="datefield" name="readyDat" onchange="checkDateFormatAll(this);" id="readyDat" class="sm-input datefield" value="#dateformat(rdyDate,'mm/dd/yyyy')#">
                        </div></div>
                        <label class="space_it_little">Arrive</label>
                        <div style="position:relative;float:left;">
                        <div style="float:left;">
                        <input type="datefield" name="arriveDat" id="arriveDat" onchange="checkDateFormatAll(this);" class="sm-input datefield" value="#dateformat(ariveDate,'mm/dd/yyyy')#">
                        </div></div>
                        <label style="width: 50px;">Excused</label>
                        <input type="checkbox" name="Excused" class="small_chk" value="1" <cfif isExcused EQ 1>checked</cfif> style="float:left;">
                    <cfelse>
                        <label>&nbsp;</label>
                    </cfif>
                </fieldset>
            </div>
            <div>
                <div class="form-con">
                    <div id="CustInfo2">
                        <fieldset>
                            <div style="width:100%">
                                <table style="border-collapse: collapse;border-spacing: 0;">
                                    <tbody>
                                        <tbody>
                                        <tr>
                                          <td><label style="text-align: left !important;width: 65px !important;">Credit Limit</label></td>
                                          <td><input type="text" class="mid-textbox-1" style="text-align:right;" tabindex=17></td>
                                          <td><label style="text-align: left !important;width: 40px !important;">Balance</label></td>
                                          <td><input type="text" class="mid-textbox-1" style="text-align:right;" tabindex=18></td>
                                          <td><label style="text-align: left !important;width: 50px !important;">Available</label></td>
                                          <td><input type="text" class="mid-textbox-1" style="text-align:right;" tabindex=19></td>
                                        </tr>
                                    </tbody>
                                    </tbody>
                                </table>
                            </div>
                            <div class="clear"></div>
                            <label class="space_it_medium margin_top">Notes</label>
                            <div class="clear"></div>
                            <textarea class="carrier-textarea-medium" name="" tabindex=20 cols="" rows="" ></textarea>
                            <div class="clear"></div>
                            <label class="space_it_medium margin_top">Dispatch Notes</label>
                            <div class="clear"></div>
                            <textarea class="carrier-textarea-medium" name="" tabindex=21 cols="" rows=""></textarea>
                            <div class="clear"></div>
                        </fieldset>
                    </div>
                    <fieldset>
                        <cfif structKeyExists(session, "currentusertype") and session.currentusertype EQ "administrator">
                            <cfset exp_Disabled = "">
                        <cfelse>
                            <cfset exp_Disabled = "disabled">
                        </cfif>
                        <label class="ch-box" style="margin-left:80px;">
                        <input name="ARExported" id="ARExported" type="checkbox" class="check"  #exp_Disabled#  <cfif ARExported is 1 AND url.loadToBeCopied EQ 0> checked="checked" </cfif>/>
                        A/R Exported
                        </label>
                        <label class="ch-box">
                        <input name="APExported" id="APExported" type="checkbox" class="check"  #exp_Disabled#  <cfif APExported is 1 AND url.loadToBeCopied EQ 0> checked="checked" </cfif>/>
                        A/P Exported
                        </label>
                        <div class="clear"></div>
                    </fieldset>
                </div>
            </div>
            <div class="clear"></div>
        </div>
        <div class="white-bot"></div>
    </div>
    <!--- Set shown stop and non shown stop on every delete stop and add stop  --->
    <input type="hidden" name="shownStopArray" id="shownStopArray" value="">
    <input type="hidden" name="nonShownStopArray" id="nonShownStopArray" value="">
    <div class="gap"></div>
    <!-- stop block-->
    <div id="tabs1" class="tabsload ui-tabs ui-widget ui-widget-content ui-corner-all">
        <ul class="ui-tabs-nav ui-helper-reset ui-helper-clearfix ui-widget-header ui-corner-all" style="height:27px;">
            <li class="ui-state-default ui-corner-top ui-tabs-active ui-state-active"><a class="ui-tabs-anchor" href="##tabs-1" style="font-weight: bolder;font-size: 12px;padding-bottom: 4px;">Stop 1</a></li>
            <li class="ui-state-default ui-corner-top"><a class="ui-tabs-anchor" href="index.cfm?event=loadIntermodal&stopno=&loadID=#loadID#&#Session.URLToken#">Intermodal</a></li>
            <div style="float: left;width: 23%; margin-left: 27px;">
                <div class="form-con" style="width:203%" id="StopNo1">
                    <ul class="load-link" id="ulStopNo1" style="line-height:26px;">
                        <cfloop from="1" to="#totStops#" index='stpNoid'>
                            <cfif stpNoid is 1>
                                <li><a href="##StopNo#stpNoid#">###stpNoid#</a></li>

                                <cfelse>
                                <li><a href="##StopNo#stpNoid#">###stpNoid#</a></li>
                            </cfif>
                        </cfloop>
                    </ul>
                    <div class="clear"></div>
                </div>
            </div>
            <div style="float: left; width: 56%; height:6px;">
                <h2 id="loadNumber" style="color:white;font-weight:bold;margin-top: -11px;float: left;">Load###Ucase(loadnumber)#</h2>
            </div>
        </ul>

        <div id="tabs-1">
            <div class="white-con-area">
                <div class="white-mid" style="width: 932px;">
                    <div>
                        <div class="rt-button1" style="margin-top: -32px;">
                            <cfif ( structkeyexists(url,"loadid") and len(trim(url.loadid)) gt 1 )>
                                <cfset variables.totalStopcount=request.loadstopcount/2>
                                <cfset variables.totalStopcounts=request.loadstopcount>
                                <cfif variables.totalStopcounts gt 2>
                                    <a href="javascript:void(0);"><img src="images/upButton.png" style="position:absolute;margin-left: 225px;-ms-transform: rotate(180deg);-webkit-transform: rotate(180deg);transform: rotate(180deg);" onclick="return stopInterChanging('down','#url.loadid#','#application.dsn#',0);" title="By clicking this  stop 1 and stop 2 get swaped "></a>
                                </cfif>
                            </cfif>
                        </div>
                        <div id="ShipperInfo"  style="clear:both">
                            <div class="">
                                <div class="fa fa-<cfif not len(loadID) gt 1>minus<cfelse><cfif variables.flagstatus>minus<cfelse>plus</cfif></cfif>-circle PlusToggleButton" onclick="showHideIcons(this,1);" style="position:relative;margin-left: 5px;">
                                </div>
                                <label style="float: left;width: 90px;padding: 0 10px 0 0;font-size: 12px;font-weight: bold;color: ##000000;margin-top: 7px;text-align: right;">Pickup Name</label>
                            </div>
                            <div style="position: absolute;right: 0;line-height: 25px;width: 475px;">
                                <span style="display:inline-block;text-align:right;" name="span_Shipper" id="span_Shipper"></span>
                            </div>
                            <div class="form-heading-carrier">
                                <div class="rt-button"></div>
                                <div class="clear"></div>
                            </div>

                            <div class="form-con InfoShipping1 InfoStopLeft" style="margin-top:-25px;width: 440px;">
                                <cfset shipperStopId = "">
                                <cfset shipperStopNameList="">
                                <cfset tempList = "">
                                <input name="appDsn" id="appDsn" type="hidden" value="#application.dsn#">
                                <fieldset style="margin-left: -25px;">
                                    <input class="myElements <cfif len(trim(shipperCustomerID))>hyperLinkLabelStop</cfif>" name="shipper" style="margin-left:112px;" id="shipper" value="#ShipCustomerStopName#" onkeyup="ChkUpdteShipr(this.value,'Shipper',''); showChangeAlert('shipper',''); " onblur="ChkUpdteShipr(this.value,'Shipper',''); showChangeAlert('shipper',''); " onchange="updateIsPayer(shipperValueContainer);"  title="Type text here to display list." tabindex="22"/ onclick="openCustomerPopup('#shipperCustomerID#',this);"><img src="images/clearRed.gif" style="height:14px;width:14px;"  title="Click here to clear pickup information"  onclick="ChkUpdteShipr('','Shipper1','');">
                                    <input type="hidden" name="shipperValueContainer" id="shipperValueContainer" value="#shipperCustomerID#"/>
                                    <input type="hidden" name="shipIsPayer" class="updateCreateAlert" id="shipIsPayer" value="#shipIsPayer#">
                                    <div class="clear"></div>
                                    <input type="hidden" name="shipperIsPayer" id="shipperIsPayer" value="#ShipIsPayer#">
                                    <div class="clear"></div>

                                    <input style="display: none;" name="shipperName" id="shipperName" value="#ShipCustomerStopName#" onkeyup="ChkUpdteShipr(this.value,'Shipper',''); showChangeAlert('shipper',''); "   type="text" maxlength="100" />
                                    <input type="hidden" name="shipperNameText" id="shipperNameText" value="#ShipCustomerStopName#">
                                    <input type="hidden" name="shipperUpAdd" id="shipperUpAdd" value="">
                                    <div class="clear"></div>
                                    <p style="transform: rotate(-90deg);width: 300px;margin-left: -137px;color: ##0f4100;font-weight: bold;font-size: 20px;font-family: 'Arial Black';letter-spacing: 5px;">PICKUP</p>
                                    <div class="clear" style="margin-top: -15px;"></div>
                                    <label>
                                        <p id="newShipper" style="float: left;font-size: 14px;color: ##2c9500;display:none;">* NEW *</p>Address
                                        <div class="clear"></div>
                                        <span class="float_right">
                                            <cfif request.qSystemSetupOptions.googleMapsPcMiler AND request.qcurAgentdetails.proMilesStatus>
                                                <a href="##" onclick="Mypopitup('create_map.cfm?loc=#shiplocation#&city=#shipcity#&state=#shipstate1# #shipzipcode#&stopNo=1&shipOrConsName=#ShipCustomerStopName#&loadNum=#loadnumber#' );"><img style="float:left;" align="absmiddle" src="./map.jpg" width="24" height="24" alt="Pro Miles Map"  /></a>
                                            <cfelse>
                                                <a href="##" onclick="Mypopitup('create_map.cfm?loc=#shiplocation#&city=#shipcity#&state=#stateName# #shipzipcode#&stopNo=1&shipOrConsName=#ShipCustomerStopName#&loadNum=#loadnumber#' );"><img style="float:left;" align="absmiddle" src="./map.jpg" width="24" height="24" alt="Google Map"  /></a>
                                            </cfif>
                                        </span>
                                    </label>
                                    <textarea class="addressChange" rows="" name="shipperlocation" id="shipperlocation" cols=""   onkeydown="ChkUpdteShiprAddress(this.value,'Shipper','');" data-role=""  tabindex="23" maxlength="100" onchange="checkShipperUpdated('');" style="height: 40px;">#left(shiplocation,100)#</textarea>
                                    <div class="clear"></div>

                                    <label>City</label>
                                    <input class="addressChange" name="shippercity" id="shippercity" value="#shipcity#" type="text" data-role="" onkeydown="ChkUpdteShiprCity(this.value,'Shipper','');" tabindex="-1" maxlength="50" onchange="checkShipperUpdated('');"/>
                                    <div class="clear"></div>

                                    <label>State</label>
                                    <select name="shipperstate" id="shipperstate" onChange="addressChanged('');loadState(this,'shipper','');checkShipperUpdated('');"  tabindex="-1" style="width:60px;">
                                        <option value="">Select</option>
                                        <cfloop query="request.qStates">
                                            <option value="#request.qStates.statecode#" <cfif request.qStates.statecode is shipstate1> selected="selected" </cfif> >#request.qStates.statecode#</option>
                                            <cfif request.qStates.statecode is shipstate1>
                                            <cfset variables.stateName = #request.qStates.statecode#>
                                            </cfif>
                                        </cfloop>
                                    </select>
                                    <input type="hidden" name="shipperStateName" id="shipperStateName" value ="<cfif structKeyExists(variables,"stateName")>#variables.stateName#</cfif>">
                                    <!--- <div class="clear"></div> --->

                                    <label style="width: 58px;">Zip</label>
                                    <input name="shipperZipcode" id="shipperZipcode" value="#shipzipcode#" type="text"  tabindex="26"  maxlength="50"  onchange="checkShipperUpdated('');" style="width:60px;"/>
                                    <div class="clear"></div>

                                    <!---for promiles--->
                                    <input type="hidden" name="shipperAddressLocation1" id="shipperAddressLocation1" value="#shipcity#<cfif len(shipcity)>,</cfif> #shipstate1# #shipzipcode#">
                                    <cfif len(url.loadid) gt 1>
                                        <cfset currentTab = "26">
                                    <cfelse>
                                        <cfset currentTab = "26">
                                    </cfif>

                                    <label>Contact</label>
                                    <input name="shipperContactPerson" id="shipperContactPerson" value="#shipcontactPerson#" type="text" tabindex="#evaluate(currentTab+1)#" maxlength="100"  onchange="checkShipperUpdated('');"/>
                                    <div class="clear"></div>

                                    <label>Phone</label>
                                    <input class="phoneFormatValid" name="shipperPhone" id="shipperPhone" value="#shipPhone#" type="text" onChange="ParseUSNumber(this);" tabindex="#evaluate(currentTab+2)#" maxlength="30"  onchange="checkShipperUpdated('');" style="width:155px !important;"/>

                                    <label style="width:30px !important;">Ext</label>
                                    <input name="shipperPhoneExt" id="shipperPhoneExt" value="#shipPhoneExt#" type="text" tabindex="#evaluate(currentTab+2)#" maxlength="10"  onchange="checkShipperUpdated('');" style="width:50px !important;" />
                                    <div class="clear"></div>

                                    <label>Fax</label>
                                    <input name="shipperFax" id="shipperFax" value="#shipfax#" type="text" tabindex="#evaluate(currentTab+3)#" maxlength="150"/>
                                    <div class="clear"></div>
                                    <label>Email</label>
                                    <input name="shipperEmail" id="shipperEmail" value="#shipemail#" type="text" tabindex="#evaluate(currentTab+4)#" maxlength="100" onchange="checkShipperUpdated('');"/>
                                    <script>
                                        var thisFrom = document.forms["load"];
                                        function Mypopitup(url) {
                                            newwindow=window.open(url,'name','height=560,width=965');
                                            if (window.focus) {newwindow.focus()}
                                            return false;
                                        }
                                    </script>

                                </fieldset>
                            </div>
                            
                            <div class="form-con InfoShipping1" style="margin-top:-37px;">
                                <fieldset>
                                    <div class="edique-pickup" style="height:11px;font-size: 12px;color: green"></div>
                                    <label class="stopsLeftLabel">Pickup##</label>
                                    <input name="shipperPickupNo1" id="shipperPickupNo1" value="#shipPickupNo#" type="text" tabindex="#evaluate(currentTab+5)#" maxlength="50" />
          
                                    <label class="ch-box" style="width: 80px;text-align: right;margin-right: -5px;">Pickup Blind</label>
                                    <input name="shipBlind" id="shipBlind" type="checkbox" <cfif shipBlind is true> checked="checked" </cfif> class="check" tabindex="#evaluate(currentTab+6)#" style="width:18px;"/>
                                    <div class="clear"></div>
                                    <label class="stopsLeftLabel">
                                        <cfif request.qSystemSetupOptions.FreightBroker NEQ 0 AND request.qSystemSetupOptions.FreightBroker NEQ 0 AND structkeyexists(url,"loadid") and len(trim(url.loadid)) gt 1 and request.qloads.statustext GTE '2. BOOKED' and PostTo123LoadBoard NEQ 1 and posttoDirectFreight NEQ 1 and posttoloadboard NEQ 1 and posttoTranscore NEQ 1 and posttoITS NEQ 1>
                                            Pickup Date
                                        <cfelse>
                                            <a style="color: ##4322cc;text-decoration:underline;" href="javascript:void(null)" onclick="window.open('index.cfm?event=addMultipleDates&stopNo=0&#session.URLToken#','Map','height=400,width=400');">Pickup Date</a>
                                        </cfif>
                                    </label>
                                    <div style="position:relative;float:left;">
                                        <div style="float:left;">
                                        <input type="hidden" name="oldShipperPickupDate" value="#dateformat(ShippickupDate,'yyyymmdd')#">
                                        <input type="hidden" id="oldshipperPickupDateMultiple" name="oldshipperPickupDateMultiple" value="#ShippickupDateMultiple#">
                                        <input type="hidden" id="shipperPickupDateMultiple" name="shipperPickupDateMultiple" value="#ShippickupDateMultiple#">
                                        <input class="sm-input datefield" name="shipperPickupDate" <cfif not len(EDISCAC) >onchange="checkDateFormatAll(this);checkMultiplePickupDate('');" </cfif> id="shipperPickupDate" value="#dateformat(ShippickupDate,'mm/dd/yyyy')#"  type="datefield" tabindex="#evaluate(currentTab+7)#" data-stop="1"/>
                                        </div>
                                    </div>

                                    <label class="sm-lbl" style="width: 50px;">Apt. Time</label>

                                    <input type="hidden" name="oldShipperpickupTime" id="oldShipperpickupTime" value="#shippickupTime#">
                                    <input type="hidden" id="ShipperStopDateQ" name="ShipperStopDateQ" value="#ShipperStopDateQ#">
                                    <input class="pick-input <cfif len(EDISCAC)>NumericOnlyFields </cfif>" name="shipperpickupTime" id="shipperpickupTime" value="#shippickupTime#" type="text" tabindex="#evaluate(currentTab+8)#" style="width:40px;" <cfif len(EDISCAC)> maxlength="4"</cfif>/>
                                    <cfif request.qSystemSetupOptions.timezone>
                                        <label class="sm-lbl" style="width: 55px;">Time Zone</label>
                                        <input class="pick-input" name="shipperTimeZone" id="shipperTimeZone" value="#shipperTimeZone#" type="text" tabindex="#evaluate(currentTab+9)#" style="width:30px;"/>
                                    </cfif>
                                    <div class="clear"></div>

                                    <label class="stopsLeftLabel labelShipperTimein1" style="width:80px !important;">Arrived<br><span <cfif LateStop EQ 1> style="color: ##800000;" </cfif>>Late?</span> <input name="LateStop" id="LateStop" type="checkbox" class="check myElements" style="width: 12px;float: right;margin-right: 0 !important;margin-left: 2px;" <cfif LateStop EQ 1> checked </cfif>></label>
                                    
                                    <input type="hidden" name="oldShipperTimeIn" id="oldShipperTimeIn" value="#shiptimeIn#">

                                    <input style="width:60px;" class="sm-input <cfif len(EDISCAC)>NumericOnlyFields edidatetime</cfif>" name="shipperTimeIn" id="shipperTimeIn" value="#shiptimeIn#" type="text" tabindex="#evaluate(currentTab+10)#"  <cfif len(EDISCAC)> maxlength="4"</cfif> onchange="checkTimeForProject44('','shipper','ARRIVED')"/>
                                    <cfif request.qSystemSetupOptions.Project44 AND ( structkeyexists(url,"loadid") and len(trim(url.loadid)) gt 1 ) AND qGetCustCons.PushDataToProject44Api>
                                        <img class="44Logo" style="float:left;border-radius: 50%;cursor: pointer;" src="images/44Logo.png" onclick="sendProject44Local('','shipper','ARRIVED');">
                                    </cfif>
                                    <label class="sm-lbl" style="width:65px !important;">Departed</label>
                                    
                                    <input type="hidden" name="oldshipperTimeOut" id="oldshipperTimeOut" value="#shipTimeOut#">
                                    
                                    <input style="width:40px;" class="pick-input <cfif len(EDISCAC)>NumericOnlyFields edidatetime</cfif>" name="shipperTimeOut" id="shipperTimeOut" value="#shipTimeOut#" type="text" tabindex="#evaluate(currentTab+11)#"  <cfif len(EDISCAC)> maxlength="4"</cfif> onchange="checkTimeForProject44('','shipper','DEPARTED')"/>
                                    <cfif request.qSystemSetupOptions.Project44 AND ( structkeyexists(url,"loadid") and len(trim(url.loadid)) gt 1 ) AND qGetCustCons.PushDataToProject44Api>
                                        <img class="44Logo" style="float:left;border-radius: 50%;cursor: pointer;" src="images/44Logo.png" onclick="sendProject44Local('','shipper','DEPARTED');">
                                    </cfif>
                                     <cfif len(EDISCAC)>
                                        <label class="stopsLeftLabel labelShipperTimein1" style="width: 66px !important;margin-left: 17px;display:none;">Late Reason</label>                                   
                                        <select name="shipperEdiReasonCode" id="shipperEdiReasonCode" class="medium " style="margin-left:0px;width:70px;display:none;">
                                        <option value="">Select Reason</option> 
                                        <cfloop query="qgetEdiReasonCodes">
                                             <option value="#qgetEdiReasonCodes.ReasonCode#"> #qgetEdiReasonCodes.ReasonText#</option>
                                        </cfloop>      
                                        </select>
                                    </cfif>
                                    <div class="clear"></div>
                                    <div style="color:red;" id="shipperProject44Text"></div>
                                    <div class="clear"></div>
                                    <label class="stopsLeftLabel margin_top">Instructions</label>

                                    <textarea rows="" name="shipperNotes" id="shipperNotes" class="carrier-textarea-medium" cols="" tabindex="#evaluate(currentTab+12)#" style="width: 298px;height: 65px;margin-left: 0px;">#shipInstructions#</textarea>
     
                                    <div class="clear"></div>
                                    <label class="stopsLeftLabel margin_top">Internal Notes</label>
                                    <textarea maxlength="1000" rows="" name="shipperDirection" id="shipperDirection" class="carrier-textarea-medium" cols="" tabindex="#evaluate(currentTab+13)#" onchange="checkShipperUpdated('');"  style="width: 298px;height: 68px;margin-left: 0px;">#shipdirection#</textarea>
                                    <div class="clear"></div>
                                </fieldset>
                            </div>
                        </div>
                        <div class="clear"></div>
                        <div align="center">
                            <div style="border-bottom:1px solid ##e6e6e6; padding-top:7px;margin-bottom: 8px;"></div>
                        </div>
                        <div class="clear"></div>
                    </div>
                    <div>
                        <div id="ConsigneeInfo" style="height:15px;">
                            <div class="" style="clear:both;">
                                <div class="fa fa-<cfif not len(loadID) gt 1>minus<cfelse><cfif variables.flagstatusConsignee>minus<cfelse>plus</cfif></cfif>-circle PlusToggleButton" onclick="showHideConsineeIcons(this,1);" style="position:absolute;left:-16px;margin-top: -4px;"></div>
                                <span class="ShipperHead" style="position:absolute;left:26px;color:##000000;font-size: 12px;padding-top: 0;">Delivery Name</span>
                            </div>
                            <div style="position: absolute;right: 0;line-height: 25px;width: 475px;">
                                <span style="display:inline-block;" name="span_Consignee" id ="span_Consignee"></span>
                            </div>
                            <div class="form-con InfoStopLeft InfoConsinee1" style="margin-top:-6px;width:463px !important;">
                                <fieldset>
                                    <cfset shipperStopId = "">
                                    <cfset shipperStopNameList="">
                                    <cfset tempList = "">
                                    <input name="consignee" class="myElements <cfif len(trim(consigneeCustomerID))>hyperLinkLabelStop</cfif>" style="margin-left:112px;" id="consignee"  value="#ConsineeCustomerStopName#" onkeyup="ChkUpdteShipr(this.value,'consignee',''); showChangeAlert('consignee',''); " onblur="ChkUpdteShipr(this.value,'consignee',''); showChangeAlert('consignee',''); "     title="Type text here to display list." tabindex="#evaluate(currentTab+14)#" onclick="openCustomerPopup('#consigneeCustomerID#',this);"/><img src="images/clearRed.gif" style="height:14px;width:14px"  title="Click here to clear consignee information"  onclick="ChkUpdteShipr('','consignee1','');">
                                    <input type="hidden" name="consigneeValueContainer" id="consigneeValueContainer" value="#consigneeCustomerID#"  message="Please select a Consignee"/>
                                    <input type="hidden" name="consigneeIsPayer" class="updateCreateAlert" id="consigneeIsPayer" value="#consigneeIsPayer#">
                                    <div class="clear"></div>

                                    <input style="display: none;" name="consigneeName" id="consigneeName" value="#ConsineeCustomerStopName#" type="text" onkeyup="ChkUpdteShipr(this.value,'consignee',''); showChangeAlert('consignee',''); " tabindex="#evaluate(currentTab+15)#" maxlength="100" />
                                    <input type="hidden" name="consigneeNameText" id="consigneeNameText" value="#ConsineeCustomerStopName#">
                                    <div class="clear"></div>
                                    <input type="hidden" name="consigneeUpAdd" id="consigneeUpAdd" value="">
                                    <div class="clear"></div>
                                    <p style="transform: rotate(-90deg);width: 350px;margin-left: -163px;color: ##800000;font-weight: bold;font-size: 20px;font-family: 'Arial Black';letter-spacing: 5px;">DELIVERY</p>
                                    <div class="clear" style="margin-top: -15px;"></div>
                                    <label><p id="newConsignee" style="float: left;font-size: 14px;color: ##2c9500;display:none;">* NEW *</p>Address
                                        <div class="clear"></div>
                                        <span class="float_right">
                                           <script>var thisFromC = document.forms["load"]; </script>
                                            <cfif request.qSystemSetupOptions.googleMapsPcMiler AND request.qcurAgentdetails.proMilesStatus>
                                                <a href="##" onclick="Mypopitup('create_map.cfm?loc=#Consigneelocation#&city=#Consigneecity#&state=#Consigneestate1# #Consigneezipcode#&stopNo=1&shipOrConsName=#ConsineeCustomerStopName#&loadNum=#loadnumber#');" ><img style="float:left;" align="absmiddle" src="./map.jpg" width="24" height="24" alt="Pro Miles Map"/></a>
                                            <cfelse>
                                                <a href="##" onclick="Mypopitup('create_map.cfm?loc=#Consigneelocation#&city=#Consigneecity#&state=#Consigneestate1# #Consigneezipcode#&stopNo=1&shipOrConsName=#ConsineeCustomerStopName#&loadNum=#loadnumber#');" ><img style="float:left;" align="absmiddle" src="./map.jpg" width="24" height="24" alt="Google Map"/></a>
                                            </cfif>
                                        </span>
                                    </label>

                                    <textarea class="addressChange"  rows="" name="consigneelocation" id="consigneelocation" cols=""   data-role="" onkeydown="ChkUpdteShiprAddress(this.value,'consignee','');"  tabindex="#evaluate(currentTab+16)#" maxlength="100" onchange="checkConsngeeUpdated('');" style="height: 40px;">#left(Consigneelocation,100)#</textarea>
                                    <div class="clear"></div>

                                    <label>City</label>
                                    <input class="addressChange" name="consigneecity" id="consigneecity" value="#Consigneecity#" type="text"  data-role=""  onkeydown="ChkUpdteShiprCity(this.value,'consignee','');" tabindex="-1" maxlength="50" onchange="checkConsngeeUpdated('');"/>
                                    <div class="clear"></div>

                                    <label>State</label>
                                        <select name="consigneestate" id="consigneestate" onChange="addressChanged('');loadState(this,'consignee','');checkConsngeeUpdated('');" tabindex="-1" style="width:60px;">
                                            <option value="">Select</option>
                                            <cfloop query="request.qStates">
                                                <option value="#request.qStates.statecode#" <cfif request.qStates.statecode is Consigneestate1> selected="selected" </cfif> >#request.qStates.statecode#</option>
                                                <cfif request.qStates.statecode is Consigneestate1>
                                                    <cfset variables.statecode = #request.qStates.statecode#>
                                                </cfif>
                                            </cfloop>
                                        </select>
                                    <input type="hidden" name="consigneeStateName" id="consigneeStateName" value ="<cfif structKeyExists(variables,"statecode")>#variables.statecode#</cfif>" onchange="checkConsngeeUpdated('');">
                                    <!--- <div class="clear"></div> --->

                                    <label style="width:58px;">Zip</label>
                                    <cfinclude template="getdistance.cfm">
                                    <input name="consigneeZipcode" id="consigneeZipcode" value="#Consigneezipcode#" type="text" <cfif len(trim(url.loadid)) gt 1> tabindex="#evaluate(currentTab+19)#"<cfelse> tabindex="#evaluate(currentTab+19)#"</cfif> maxlength="50" onchange="checkConsngeeUpdated('');"  style="width:60px;"/>
                                    <div class="clear"></div>

                                    <label>Contact</label>
                                    <input name="consigneeContactPerson" id="consigneeContactPerson" value="#ConsigneecontactPerson#" type="text" tabindex="#evaluate(currentTab+20)#" maxlength="100"  onchange="checkConsngeeUpdated('');"/>
                                    <div class="clear"></div>

                                    <label>Phone</label>
                                    <input class="phoneFormatValid" name="consigneePhone" id="consigneePhone" value="#ConsigneePhone#" onChange="ParseUSNumber(this);" type="text" tabindex="#evaluate(currentTab+21)#" maxlength="30" onchange="checkConsngeeUpdated('');" style="width:155px !important;"/>
                                    <label style="width:30px !important;">Ext</label>
                                    <input name="consigneePhoneExt" id="consigneePhoneExt" value="#ConsigneePhoneExt#" type="text" tabindex="#evaluate(currentTab+21)#" maxlength="10" onchange="checkConsngeeUpdated('');" style="width:50px !important;"/>
                                    <div class="clear"></div>
                                    <label>Fax</label>
                                    <input name="consigneeFax" id="consigneeFax" value="#Consigneefax#" type="text" tabindex="#evaluate(currentTab+22)#" maxlength="150" />
                                    <div class="clear"></div>
                                    <label>Email</label>
                                    <input name="consigneeEmail" id="consigneeEmail" value="#Consigneeemail#" type="text" tabindex="#evaluate(currentTab+23)#" maxlength="100" onchange="checkConsngeeUpdated('');"/>
                                </fieldset>
                            </div>
                            <!---for promiles--->
                            <input type="hidden" name="consigneeAddressLocation1" id="consigneeAddressLocation1" value="#Consigneecity#<cfif len(Consigneecity)>,</cfif> #Consigneestate1# #Consigneezipcode#">
                            <div class="form-con InfoConsinee1" style="margin-top: -7px;">
                                <fieldset>
                                    <label class="stopsLeftLabel">Delivery##</label>
                                    <input name="consigneePickupNo" id="consigneePickupNo" value="#ConsigneePickupNo#" type="text" tabindex="#evaluate(currentTab+24)#" maxlength="50" />

                                    <label class="ch-box" style="width: 80px;text-align: right;margin-right: -7px;">Delivery Blind</label>
                                    <input name="ConsBlind" id="ConsBlind" type="checkbox" <cfif ConsBlind is true> checked="checked" </cfif> class="check" tabindex="#evaluate(currentTab+25)#" style="width:18px;"/>

                                    <div class="clear"></div>
                                    <label class="stopsLeftLabel">Delivery Date</label>
                                    <div style="position:relative;float:left;">
                                        <div style="float:left;">
                                        <input type="hidden" name="oldConsigneePickupDate" value="#dateformat(ConsigneepickupDate,'yyyymmdd')#">
                                           <input class="sm-input datefield" name="consigneePickupDate" <cfif not len(ediscac)>onchange="checkDateFormatAll(this);"</cfif>  id="consigneePickupDate" value="#dateformat(ConsigneepickupDate,'mm/dd/yyyy')#" validate="date" message="Please enter a valid date" type="datefield" tabindex="#evaluate(currentTab+26)#" data-stop="1"/>
                                       </div>
                                    </div>
                                    <label class="sm-lbl"  style="width: 50px;">Apt. Time</label>
                                    
                                    <input type="hidden" name="oldConsigneepickupTime" id="oldConsigneepickupTime"  value="#ConsigneepickupTime#">
                                    <input type="hidden" id="ConsigneeStopDateQ" name="ConsigneeStopDateQ" value="#ConsigneeStopDateQ#">
                                    <input class="pick-input <cfif len(EDISCAC)>NumericOnlyFields edidatetime</cfif>" name="consigneepickupTime" id="consigneepickupTime" value="#ConsigneepickupTime#" type="text"  tabindex="#evaluate(currentTab+27)#" style="width:40px;"  <cfif len(EDISCAC)> maxlength="9"</cfif> />
                                    <cfif request.qSystemSetupOptions.timezone>
                                        <label class="sm-lbl" style="width: 55px;">Time Zone</label>
                                        <input class="pick-input" name="consigneeTimeZone" id="consigneeTimeZone" value="#consigneeTimeZone#" type="text" tabindex="#evaluate(currentTab+28)#" style="width:30px;"/>
                                    </cfif>
                                    <div class="clear"></div>
                                    <label class="stopsLeftLabel labelConsigneeTimein1" style="width:80px !important;">Arrived</label>

                                    <input type="hidden" name="oldConsigneeTimeIn" id="oldConsigneeTimeIn" value="#ConsigneetimeIn#">

                                    <input style="width:60px;" class="sm-input <cfif len(EDISCAC)>NumericOnlyFields edidatetime</cfif>" name="consigneeTimeIn" id="consigneeTimeIn" value="#ConsigneetimeIn#" type="text" tabindex="#evaluate(currentTab+29)#" <cfif len(EDISCAC)>maxlength="4" </cfif>  onchange="checkTimeForProject44('','consignee','ARRIVED')"/>
                                    <cfif request.qSystemSetupOptions.Project44 AND ( structkeyexists(url,"loadid") and len(trim(url.loadid)) gt 1 ) AND qGetCustCons.PushDataToProject44Api>
                                        <img class="44Logo" style="float:left;border-radius: 50%;cursor: pointer;" src="images/44Logo.png" onclick="sendProject44Local('','consignee','ARRIVED');">
                                    </cfif>

                                    <label class="sm-lbl" style="width:65px !important;">Departed</label>

                                    <input type="hidden" name="oldConsigneeTimeOut" id="oldConsigneeTimeOut" value="#ConsigneeTimeOut#">

                                    <input style="width:40px;" class="pick-input <cfif len(EDISCAC)>NumericOnlyFields edidatetime</cfif>" name="consigneeTimeOut" id="consigneeTimeOut" value="#ConsigneeTimeOut#" type="text" tabindex="#evaluate(currentTab+30)#" <cfif len(EDISCAC)>maxlength="4" </cfif> onchange="checkTimeForProject44('','consignee','DEPARTED')"/>
                                    <cfif request.qSystemSetupOptions.Project44 AND ( structkeyexists(url,"loadid") and len(trim(url.loadid)) gt 1 ) AND qGetCustCons.PushDataToProject44Api>
                                        <img class="44Logo" style="float:left;border-radius: 50%;cursor: pointer;" src="images/44Logo.png" onclick="sendProject44Local('','consignee','DEPARTED');">
                                    </cfif>
                                    <cfif len(EDISCAC)>
                                        <label class="stopsLeftLabel labelConsigneeTimein1" style="width: 66px !important;margin-left: 17px;display:none;">Late Reason</label>                                   
                                        <select name="consigneeEdiReasonCode" id="consigneeEdiReasonCode" class="medium " style="margin-left:0px;width:70px;display:none;">
                                        <option value="">Select Reason</option> 
                                        <cfloop query="qgetEdiReasonCodes">
                                             <option value="#qgetEdiReasonCodes.ReasonCode#"> #qgetEdiReasonCodes.ReasonText#</option>
                                        </cfloop>      
                                        </select>
                                    </cfif>
                                    <div class="clear"></div>
                                    <div style="color:red;" id="consigneeProject44Text"></div>
                                    <div class="clear"></div>
                                    <label class="stopsLeftLabel margin_top">Instructions</label>
                                    <textarea rows="" name="consigneeNotes" id="consigneeNotes" class="carrier-textarea-medium"cols="" tabindex="#evaluate(currentTab+31)#" style="width: 298px;height: 65px;margin-left: 0px;">#ConsigneeInstructions#</textarea>
                                    <div class="clear"></div>
                                    <label class="stopsLeftLabel  margin_top">Internal Notes</label>
                  
                                    <textarea rows="" maxlength="1000" name="consigneeDirection" id="consigneeDirection" class="carrier-textarea-medium" cols="" tabindex="#evaluate(currentTab+32)#" onchange="checkConsngeeUpdated('');" style="width: 298px;height: 70px;margin-left: 0px;">#Consigneedirection#</textarea>
                                    <div class="clear"></div>
                                </fieldset>
                            </div>
                        </div>
                        <div class="clear"></div>
                        <div align="center">
                            <div style="border-bottom:1px solid ##e6e6e6; padding-top:7px;"></div>
                        </div>
                        <div class="clear"></div>
                    </div>

                    <cfset chckdCarrier = "">
                    <cfif trim(carrierID) NEQ ""> 
                        <cfinvoke component="#variables.objcarrierGateway#" method="getAllCarriers" returnvariable="qgetcarier" carrierId="#carrierID#"  />  
                        <cfset chckdCarrier = qgetcarier.ISCARRIER >                                    
                    </cfif> 
                    
                    <div id="carriertabs1" class="tabsload ui-tabs ui-widget ui-widget-content ui-corner-all">
                        <ul class="ui-tabs-nav ui-helper-reset ui-helper-clearfix ui-widget-header ui-corner-all" style="height:27px;">
                            <li class="ui-state-default ui-corner-top ui-tabs-active ui-state-active"><a class="ui-tabs-anchor" href="##carriertabs-1-carrier" <cfif len(url.loadid) gt 1 AND NOT (request.qSystemSetupOptions.freightBroker EQ 0 OR (request.qSystemSetupOptions.freightBroker EQ 2 AND chckdCarrier EQ 0))>onclick="clearQuote(1);toggleCommodities(1);"<cfelse>onclick="toggleCommodities(1,'');"</cfif>>
                                <cfif request.qSystemSetupOptions.freightBroker EQ 2>
                                    <cfif chckdCarrier EQ  "">
                                        Carrier/Driver
                                    <cfelseif  chckdCarrier EQ 0>
                                        Driver
                                    <cfelseif  chckdCarrier EQ 1>  
                                        Carrier 
                                    </cfif>
                                <cfelse>
                                    #variables.freightBroker#
                                </cfif>
                            </a></li>

                            <cfif request.qSystemSetupOptions.freightBroker EQ 0 OR (request.qSystemSetupOptions.freightBroker EQ 2 AND chckdCarrier EQ 0)>
                                <li class="ui-state-default ui-corner-top">
                                    <a class="ui-tabs-anchor" href="##carriertabs-1-carrier2" onclick="toggleCommodities(0,'')">Driver2</a>
                                </li>
                                <li class="ui-state-default ui-corner-top">
                                    <a class="ui-tabs-anchor" href="##carriertabs-1-carrier3" onclick="toggleCommodities(0,'')">Driver3</a>
                                </li>
                            </cfif>

                            <cfif len(url.loadid) gt 1 AND NOT (request.qSystemSetupOptions.freightBroker EQ 0 OR (request.qSystemSetupOptions.freightBroker EQ 2 AND chckdCarrier EQ 0))>
                                <li class="ui-state-default ui-corner-top"><a class="ui-tabs-anchor" href="##carriertabs-1-QuoteList" onclick="clearQuote(1)">Quote List</a></li>
                                <li class="ui-state-default ui-corner-top"><a class="ui-tabs-anchor add_quote_txt" href="##carriertabs-1-QuoteDetail" onclick="clearQuote(1)">Add Quote</a></li>
                                <li class="ui-state-default ui-corner-top"><a class="ui-tabs-anchor" href="##carriertabs-1-Lanes" onclick="clearQuote(1)">Carrier Search</a></li>
                                <div style="float: left; width: 56%; height:6px;">
                                    <h2 style="color:white;font-weight:bold;margin-top: -11px;margin-left: 60px;">
                                        <cfif request.qSystemSetupOptions.freightBroker EQ 2>
                                            <cfif chckdCarrier EQ  "">
                                                Carrier/Driver
                                            <cfelseif  chckdCarrier EQ 0>
                                                Driver
                                            <cfelseif  chckdCarrier EQ 1>  
                                                Carrier 
                                            </cfif>
                                        <cfelse>
                                            #variables.freightBroker#
                                        </cfif>
                                    </h2>
                                </div>
                            </cfif>
                        </ul>
                        <div id="carriertabs-1-carrier">
                            <div class="white-con-area" style="background-color: ##defaf9;">
                                <div class="fa fa-minus-circle PlusToggleButton" onclick="showHideCarrierBlock(this,1);" style="position:relative;margin-left: 0;margin-top: 10px"></div>
                                <div class="pg-title-carrier" style="float: left; width: 35%;padding-left:10px;font-weight:bold;font-size: 15px;">
                                    <cfif request.qSystemSetupOptions.freightBroker EQ 2>                                
                                        <cfif chckdCarrier EQ  "">
                                            <div class="" style="margin:12px 0px 0px 0px !important;">
                                                <input type="radio" name="Rad_freightBroker"  id="Rad_freightBroker"  value="2" <cfif chckdCarrier EQ  "">checked</cfif>  onclick="ChangeLabel(2)">&nbsp;Both&nbsp;
                                                <input type="radio" name="Rad_freightBroker"  id="Rad_freightBroker"  value="1" onclick="ChangeLabel(1)" <cfif chckdCarrier EQ 1>checked</cfif> >&nbsp;Carrier&nbsp;
                                                <input type="radio" name="Rad_freightBroker"  id="Rad_freightBroker"  value="0" onclick="ChangeLabel(0)" <cfif chckdCarrier EQ 0>checked</cfif> >&nbsp;Driver&nbsp;
                                            </div>
                                        <cfelseif  chckdCarrier EQ 0>
                                            <h2 class="div_freightBrokerHeading" style="font-weight:bold;display:none;">Driver</h2>
                                            <div class="div_freightBroker" style="margin:12px 0px 0px 0px !important;">
                                                <input type="radio" name="Rad_freightBroker"  id="Rad_freightBroker"  value="2" <cfif chckdCarrier EQ  "">checked</cfif>  onclick="ChangeLabel(2)">&nbsp;Both&nbsp;
                                                <input type="radio" name="Rad_freightBroker"  id="Rad_freightBroker"  value="1" onclick="ChangeLabel(1)" <cfif chckdCarrier EQ 1>checked</cfif> >&nbsp;Carrier&nbsp;
                                                <input type="radio" name="Rad_freightBroker"  id="Rad_freightBroker"  value="0" onclick="ChangeLabel(0)" <cfif chckdCarrier EQ 0>checked</cfif> >&nbsp;Driver&nbsp;
                                            </div>
                                        <cfelseif  chckdCarrier EQ 1>
                                            <h2 class="div_freightBrokerHeading" style="font-weight:bold;">Carrier</h2>
                                            <div class="div_freightBroker" style="margin:12px 0px 0px 0px !important;display:none;">
                                                <input type="radio" name="Rad_freightBroker"  id="Rad_freightBroker"  value="2" <cfif chckdCarrier EQ  "">checked</cfif>  onclick="ChangeLabel(2)">&nbsp;Both&nbsp;
                                                <input type="radio" name="Rad_freightBroker"  id="Rad_freightBroker"  value="1" onclick="ChangeLabel(1)" <cfif chckdCarrier EQ 1>checked</cfif> >&nbsp;Carrier&nbsp;
                                                <input type="radio" name="Rad_freightBroker"  id="Rad_freightBroker"  value="0" onclick="ChangeLabel(0)" <cfif chckdCarrier EQ 0>checked</cfif> >&nbsp;Driver&nbsp;
                                            </div>
                                        </cfif>
                                    <cfelse>
                                        <h2 style="font-weight:bold;">#variables.freightBroker# </h2>
                                    </cfif>
                                </div>
                                <cfif request.qSystemSetupOptions.ForeignCurrencyEnabled>
                                    <div style="float:right;padding:10px 15px;" class="carrierBlock1">
                                        <label>Currency</label>
                                        <select name="defaultCarrierCurrency" id="defaultCarrierCurrency" style="font-size:13px!important;">
                                            <cfloop query = "request.qGetCurrencies"> 
                                                <option value="#CurrencyID#" <cfif carrierCurrency eq CurrencyID> selected="selected" </cfif>>#CurrencyNameISO#(#CurrencyName#)</option>
                                            </cfloop>       
                                        </select>
                                        <input type="hidden" value="#request.qSystemSetupOptions.DefaultSystemCurrency#" id="defaultSystemCurrency">
                                    </div>
                                </cfif>
                                
                            </div>

                            <div class="form-heading-carrier carrierBlock1">
                                <div class="rt-button">
                                </div>
                                <div class="form-con" style="font-weight:bold;text-transform:uppercase;padding: 6px 10px 0 4px;">
                                    <cfset carrierLinksOnClick = "">
                                    <a href="javascript:void(0);" onClick="chooseCarrier();"  id="removeCarrierTag"  <cfif  structkeyexists(url,"loadid") and len(trim(url.loadid)) gt 1  AND  carrierID EQ "">style="display:none;"<cfelseif structkeyexists(url,"loadToBeCopied") and len(trim(url.loadToBeCopied)) gt 1  AND  carrierID EQ "" >style="display:none;"<cfelse>style="color:##236334;"</cfif>>
                                        <img style="vertical-align:bottom;" src="images/change.png">
                                        <span class="removetxt">
                                              <cfif request.qSystemSetupOptions.freightBroker EQ 2> 
                                                    Remove   
                                                    <cfif  chckdCarrier EQ 0>
                                                            Driver
                                                        <cfelseif  chckdCarrier EQ 1>
                                                            Carrier
                                                        <cfelse>
                                                            Carrier/Driver
                                                        </cfif>
                                                    <cfelse>
                                                        Remove #variables.freightBroker#
                                                    </cfif>
                                        </span>
                                    </a>

                                    <cfif request.qSystemSetupOptions1.ActivateBulkAndLoadNotificationEmail EQ 1>
                                        <div style="float: right;padding-right: 100px;">
                                            <div style="cursor:pointer;width:27px;background-color: ##bfbcbc;float: left;text-align: center;">
                                                <img id="carrierLoadAlertEmailImg" style="vertical-align:bottom;" src="images/black_mail.png" data-action="view">
                                            </div>   
                                            <cfif request.qSystemSetupOptions.freightBroker EQ 1 OR request.qSystemSetupOptions.freightBroker EQ 2>
                                                <cfset emailActiveCarriers='Email Active Carriers'/>
                                            <cfelse>
                                                <cfset emailActiveCarriers='Email Active Drivers'/>
                                            </cfif>
                                            <input id="carrierLoadAlertEmailButton" style="margin:0 0 0 1px;" class="black-btn tooltip" <cfif mailsettings>data-allowmail="true"<cfelse>data-allowmail="false"</cfif> value="#emailActiveCarriers#" type="button">
                                        </div>
                                    </cfif>

                                </div>
                                <div class="clear"></div>
                            </div>

                            <div class="form-con carrierBlock1" style="width:425px">
                                <input name="carrierID" id="carrierID" type="hidden" value="#carrierID#" />
                                <fieldset>
                                    <div id="choosCarrier" style="<cfif len(carrierID) gt 0>display:none<cfelse>display:block</cfif>;"><input type="hidden" name="carrier_id" id="carrier_id" value="#carrierID#" data-limit="<cfif trim(carrierID) NEQ "">#qgetcarier.LoadLimit#</cfif>">
                                    <div class="clear"></div>
                                    <cfset CarrierFilter = "openCarrierFilter();">
                                    <label class="LabelfreightBroker" style="width: 102px !important;">Choose #variables.freightBroker#</label>
                                    <input name="selectedCarrier" id="selectedCarrierValue" class="carrier-box" style="margin-left: 0;width: 230px !important;" type="text" <cfif carrierLinksOnClick NEQ ''> disabled </cfif> tabindex="#evaluate(currentTab+33)#" title="Type text here to display list." data-stop="1"/><img style="display: none;" width="25" class="spinner" src="images/spinner.gif">
                                    <input name="selectedCarrierValueContainer" id="selectedCarrierValueValueContainer" type="hidden" />
                                    <div class="clear"></div>
                                    <div class="clear"></div>
                                    </div>
                                    <div id="CarrierInfo" style="<cfif len(carrierID) gt 0>display:block<cfelse>display:none</cfif>;">

                                    <cfif structkeyexists(url,"loadid") and len(trim(url.loadid)) gt 1 and url.loadid NEQ 0>
                                        <cfset cLoadID=url.loadid>
                                    <cfelse>
                                        <cfset cLoadID=''>
                                    </cfif>
                                    <cfinvoke component="#variables.objloadGateway#" method="getCarrierInfoForm" returnvariable="formHTML" carrierId="#carrierID#" urlToken="#session.URLToken#" loadid='#cLoadID#'/>
                                    #formHTML#
                                    </div>
                                    <label style="width: 102px !important;">Satellite Office</label>
                                    <select name="stOffice" id="stOffice">
                                        <option value="">Choose a Satellite Office Contact</option>
                                        <cfloop query="request.qOffices">
                                            <option value="#request.qOffices.CarrierOfficeID#" <cfif stofficeid is request.qOffices.CarrierOfficeID>selected ="selected"</cfif>>#request.qOffices.location#</option>
                                        </cfloop>
                                    </select>
                                </fieldset>
                            </div>

                            <div class="form-con carrierBlock1" style="width:460px">
                                <fieldset>
                                    <div style="width:50%;float: left;" class="carrierrightdiv">
                                        <cfif request.qSystemSetupOptions.freightBroker EQ 0 OR (request.qSystemSetupOptions.freightBroker EQ 2 AND chckdCarrier EQ 0)>
                                            <div style="width:195px;float:left;border:1px solid ##b3b3b3;margin-left: -7px;margin-top: -65px;padding-top: 5px;margin-bottom: 5px;">
                                                <label class="carrierrightlabel" style="width: 58% !important;">Custom Driver Pay</label>
                                                <label class="switch switch-flat" style="padding: 0;width: 60px;height: 23px;">
                                                    <input class="switch-input CustomDriverPay" id="CustomDriverPay" name="CustomDriverPay" type="checkbox" onchange="customDriverPay(this);" <cfif CustomDriverPay EQ 1> checked </cfif>  />
                                                    <span class="switch-label" data-on="On" data-off="Off"></span> 
                                                    <span class="switch-handle"></span> 
                                                </label>
                                                <div class="divCustomDriverPayOptions" <cfif CustomDriverPay NEQ 1>style="display: none"</cfif>>
                                                    <span style="float: left;width: 39%;text-align: right;font-weight: bold;">Flat Rate $
                                                    </span> 
                                                    <input type="checkbox" class="small_chk myElements chkCustomDriverPayFlatRate" style="float: left;margin-left: 5px;" id="chkCustomDriverPayFlatRate" name="chkCustomDriverPayFlatRate" onclick="customDriverPayOption(this)" <cfif CustomDriverPayOption EQ 1> checked </cfif>> 

                                                    <span id="span_CustomDriverPayFlatRate" class="span_CustomDriverPayFlatRate" <cfif CustomDriverPayOption NEQ 1>style="display:none;"</cfif>>
                                                        <span style="float: left;">$</span>
                                                        <input type="text" style="width: 40px;margin-left: 5px;" class="customDriverPayFlatRate" id="customDriverPayFlatRate" name="customDriverPayFlatRate" onchange="calculateCustomDriverPay()" value="#customDriverPayFlatRate#">
                                                    </span>

                                                    <div class="clear"></div>

                                                    <span style="float: left;width: 39%;text-align: right;font-weight: bold;">Percentage %
                                                    </span> 
                                                    <input type="checkbox" class="small_chk myElements chkCustomDriverPayPercentage" style="float: left;margin-left: 5px;" id="chkCustomDriverPayPercentage" name="chkCustomDriverPayPercentage" onclick="customDriverPayOption(this)" <cfif CustomDriverPayOption EQ 2> checked </cfif>> 

                                                    <span id="span_CustomDriverPayPercentage" class="span_CustomDriverPayPercentage" <cfif CustomDriverPayOption NEQ 2>style="display:none;"</cfif>>
                                                        <input type="text" style="width: 40px;" class="customDriverPayPercentage" id="customDriverPayPercentage" name="customDriverPayPercentage" onchange="calculateCustomDriverPay()" value="#customDriverPayPercentage#">
                                                        <span style="float: left;">%</span>
                                                    </span>

                                                </div>
                                            </div>
                                            <div class="clear"></div>
                                        </cfif>
                                        <div style="width:200px;float:left;">
                                            <label class="carrierrightlabel">Driver 1</label>
                                            <input name="driver" value="#driver#" type="text" tabindex="#evaluate(currentTab+33)#" class="carriertextbox" maxlength="50" />
                                        </div>
                                        <div class="clear"></div>
                                        <div style="width:235px;float:left;">
                                            <label class="carrierrightlabel">Driver Cell</label>
                                            <input name="driverCell" value="#driverCell#" type="text" tabindex="#evaluate(currentTab+34)#" class="carriertextbox" maxlength="15" onchange="ParseUSNumber(this,'Driver Cell');"<cfif request.qSystemSetupOptions.EDispatchOptions EQ 0> placeholder="Enter Cell for Mobile App" <cfif len(trim(driverCell))> readonly style="background-color: ##e3e3e3;"</cfif></cfif>/>
                                        </div>
                                        <div class="clear"></div>
                                        <cfif NOT (request.qSystemSetupOptions.freightBroker EQ 0 OR (request.qSystemSetupOptions.freightBroker EQ 2 AND chckdCarrier EQ 0))>
                                            <div style="width:200px;float:left;">
                                                <label class="carrierrightlabel">Driver 2</label>
                                                <input name="Secdriver" value="#driver2#" type="text" tabindex="#evaluate(currentTab+35)#" class="carriertextbox" maxlength="50" />
                                            </div>
                                            <div class="clear"></div>
                                            <div style="width:200px;float:left;">
                                                <label class="carrierrightlabel">Driver Cell</label>
                                                <input name="secDriverCell" value="#secDriverCell#" type="text" tabindex="#evaluate(currentTab+36)#" class="carriertextbox" maxlength="15" onchange="ParseUSNumber(this,'Driver Cell');"/>
                                            </div>
                                        </cfif>
                                        <div class="clear"></div>
                                        <div style="width:200px;float:left;">
                                            <label class="carrierrightlabel">Truck##</label>
                                            <input name="truckNo" id="truckNo" value="#truckNo#" type="text" tabindex="#evaluate(currentTab+37)#" class="carriertextbox" maxlength="20" />
                                        </div>
                                        <div class="clear"></div>
                                        <div style="width:200px;float:left;">
                                            <label class="carrierrightlabel">Trailer##</label>
                                            <input name="TrailerNo" value="#TrailerNo#" type="text" tabindex="#evaluate(currentTab+38)#" class="carriertextbox" maxlength="20"/>
                                        </div>
                                        <div class="clear"></div>
                                        <div style="width:200px;float:left;">
                                            <label class="carrierrightlabel">Ref##</label>
                                            <input name="refNo" value="#refNo#" type="text" tabindex="#evaluate(currentTab+39)#" class="carriertextbox" maxlength="50" />
                                        </div>
                                        <div class="clear"></div>
                                        <div style="width:200px;float:left;">
                                            <label class="carrierrightlabel">Miles##</label>
                                            <input name="milse" class="careermilse carriertextbox" id="milse" tabindex="#evaluate(currentTab+40)#"  value=<cfif len(trim(milse))>"#milse#"<cfelse>0</cfif> type="text" onClick="showWarningEnableButton('block','');" onBlur="showWarningEnableButton('none','');CalculateTotal('#Application.dsn#');changeQuantityWithValue(this, 1);" onChange="changeQuantity(this.id,this.value,'type');calculateTotalRates('#application.DSN#');" style="width:81px !important;" />
                                            <input id="refreshBtn" value="" type="button" <!---  disabled  ---> onClick="refreshMilesClicked('');" style="width:17px; height:22px; background: url('images/refresh.png') no-repeat left top;"/>
                                            <input id="milesUpdateMode" name="milesUpdateMode" type="hidden" value="auto">
                                        </div>
                                        <div class="clear"></div>
                                        <div style="width:200px;float:left;">
                                            <label class="carrierrightlabel">Dead Head Miles</label>
                                            <input onBlur="CalculateTotal('#Application.dsn#');" onChange="calculateTotalRates('#application.DSN#');" name="deadHeadMiles" id="deadHeadMiles" value="#deadHeadMiles#" type="text" tabindex="#evaluate(currentTab+41)#" class="carriertextbox" data-loadid="#url.loadid#" data-inputname="deadHeadMiles" style="width:50px !important;"/>
                                            <input id="refreshBtn" value="" type="button" <!---  disabled  ---> onClick="calculateDeadHeadMiles('');" style="width:17px; height:22px; background: url('images/refresh.png') no-repeat left top;"/>
                                            <input style="width: 20px !important;height: 18px;padding: 0;" type="button" value="..." onclick="openDHMilesPopup(this)">
                                        </div>
                                        <div class="clear"></div>
                                        <div style="width:200px;float:left;">
                                            <label class="carrierrightlabel">Booked With</label>
                                            <input name="bookedWith" value="#bookedWith1#" type="text" tabindex="#evaluate(currentTab+42)#" class="carriertextbox" maxlength="500" />
                                        </div>
                                         <div class="clear"></div>
                                    </div>
                                    <div style="width:50%;float: left;" class="carrierrightdiv">
                                        <div style="width:200px;float:left;position: relative;">
                                            <label class="carrierrightlabel">Equip/L x W</label>
                                            <select name="equipment" id="equipment" class="selEquipment" tabindex="#evaluate(currentTab+44)#" class="carriertextbox" style="width: 68px !important;" onchange="calculateDeadHeadMiles();">
                                                <option value="">Select</option>
                                                <cfloop query="request.qEquipments">
                                                    <option value="#request.qEquipments.equipmentID#" <cfif equipment1 is request.qEquipments.equipmentID> selected="selected" </cfif> data-truck-number="#request.qEquipments.UnitNumber#" data-temperature="#request.qEquipments.temperature#" data-temperaturescale="#request.qEquipments.temperaturescale#" data-type="#request.qEquipments.equipmenttype#" data-RelEquip="#request.qEquipments.RelEquip#" data-truckTrailer="#request.qEquipments.TruckTrailerOption#">#request.qEquipments.equipmentname#</option>
                                                </cfloop>
                                            </select>
                                            <input type="text" tabindex="#evaluate(currentTab+45)#" class="floatField" data-fieldname="Length" name="EquipmentLength" id="EquipmentLength" value="#EquipmentLength#" size="4" maxlength="5" validate="float"  style="width:15px;margin-left: 4px;margin-right: 1px !important;" message="Please  enter the valid length"><b style="float: left;margin-top: 3px;">x</b>
                                            <input type="text" tabindex="#evaluate(currentTab+46)#" class="floatField" data-fieldname="Width" name="EquipmentWidth" id="EquipmentWidth" value="#EquipmentWidth#" size="4" maxlength="5" validate="float"  style="width:15px;margin-left: 1px;margin-right: 1px !important;" message="Please  enter the valid length">
                                        </div>
                                        <div class="clear"></div>
                                        <div style="width:200px;float:left;position: relative;">
                                            <label class="carrierrightlabel hyperLinkLabel">Trailer</label>
                                            <select name="equipmentTrailer" id="equipmentTrailer" tabindex="#evaluate(currentTab+44)#" class="carriertextbox">
                                                <option value="">Select</option>
                                                <cfloop query="request.qEquipments">
                                                    <cfif listFindNoCase('Trailer,Other', request.qEquipments.EquipmentType)>
                                                        <option <cfif equipmentTrailer is request.qEquipments.equipmentID> selected="selected" </cfif> value="#request.qEquipments.equipmentID#">#request.qEquipments.equipmentname#</option>
                                                    </cfif>
                                                </cfloop>
                                            </select>
                                        </div>
                                        <div class="clear"></div>
                                        <div style="width:200px;float:left;position: relative;">
                                            <label style="text-align: left;width: 65px;"><strong>Temperature</strong></label>
                                            <input type="text" tabindex="#evaluate(currentTab+47)#" name="temperature" id="temperature" value="#temperature#" size="4" maxlength="5" validate="float"  style="width:40px" message="Please  enter the valid Temperature">
                                            <label style="width: 5px;margin-top: -5px;margin-left: -5px;"><sup>o</sup></label>
                                            <cfif request.qSystemSetupOptions.TemperatureSetting EQ 0>
                                                <select tabindex="#evaluate(currentTab+47)#" name="temperaturescale" id="temperaturescale" style="width:35px;">
                                                    <option value="C" <cfif temperaturescale EQ "C"> selected </cfif> >C</option>
                                                    <option value="F" <cfif temperaturescale EQ "F"> selected </cfif> >F</option>
                                                </select>
                                            <cfelseif request.qSystemSetupOptions.TemperatureSetting EQ 1>
                                                F<input type="hidden" name="temperaturescale" value="F">
                                            <cfelse>
                                                C<input type="hidden" name="temperaturescale" value="C">
                                            </cfif>
                                        </div>
                                        <div class="clear"></div>
                                        <div style="width:200px;float:left;position: relative;">
                                            <label class="carrierrightlabel">#request.qSystemSetupOptions.userDef1#</label>
                                            <input name="userDef1" value="#userDef1#" type="text" tabindex="#evaluate(currentTab+48)#" class="carriertextbox userOnchageUpdate" data-loadid="#url.loadid#" data-inputname="userDef1" maxlength="200" />
                                        </div>
                                        <div class="clear"></div>
                                        <div style="width:200px;float:left;position: relative;">
                                            <label class="carrierrightlabel">#request.qSystemSetupOptions.userDef2#</label>
                                            <input name="userDef2" value="#userDef2#" type="text" tabindex="#evaluate(currentTab+49)#" class="carriertextbox userOnchageUpdate" data-loadid="#url.loadid#" data-inputname="userDef2" maxlength="200" />
                                        </div>
                                        <div class="clear"></div>
                                        <div style="width:200px;float:left;position: relative;">
                                            <label class="carrierrightlabel">#request.qSystemSetupOptions.userDef3#</label>
                                            <input name="userDef3" value="#userDef3#" type="text" tabindex="#evaluate(currentTab+50)#" class="carriertextbox userOnchageUpdate" data-loadid="#url.loadid#" data-inputname="userDef3" maxlength="200"/>
                                        </div>
                                        <div class="clear"></div>
                                        <div style="width:200px;float:left;position: relative;">
                                            <label class="carrierrightlabel">#request.qSystemSetupOptions.userDef4#</label>
                                            <input name="userDef4" value="#userDef4#" type="text" tabindex="#evaluate(currentTab+51)#" class="carriertextbox userOnchageUpdate" data-loadid="#url.loadid#" data-inputname="userDef4" maxlength="200" />
                                        </div>
                                        <div class="clear"></div>
                                        <div style="width:200px;float:left;position: relative;">
                                            <label class="carrierrightlabel">#request.qSystemSetupOptions.userDef5#</label>
                                            <input name="userDef5" value="#userDef5#" type="text" tabindex="#evaluate(currentTab+52)#" class="carriertextbox userOnchageUpdate" data-loadid="#url.loadid#" data-inputname="userDef5" maxlength="200" />
                                        </div>
                                        <div class="clear"></div>
                                        <div style="width:200px;float:left;position: relative;">
                                            <label class="carrierrightlabel">#request.qSystemSetupOptions.userDef6#</label>
                                            <input name="userDef6" value="#userDef6#" type="text" tabindex="#evaluate(currentTab+53)#" class="carriertextbox userOnchageUpdate" data-loadid="#url.loadid#" data-inputname="userDef6" maxlength="200" />
                                        </div>
                                         <div class="clear"></div>
                                        <div style="width:200px;float:left;">
                                            <label class="carrierrightlabel">Booked By</label>
                                            <select name="bookedBy" tabindex="#evaluate(currentTab+43)#" class="carriertextbox" style="width: 116px !important;">
                                                <option value="">Select</option>
                                                <cfloop query="request.qSalesPerson">
                                                    <option value="#request.qSalesPerson.EmployeeID#" <cfif request.qSalesPerson.EmployeeID eq  bookedBy> selected="selected" </cfif>>#request.qSalesPerson.Name#</option>
                                                </cfloop>
                                            </select>
                                        </div>
                                    </div>

                                    <div class="clear"></div>
                                    

                                    <div id="warning" class="msg-area" style="display:none; width:180px;">Warning!! Mannual Miles change has disabled automatic miles update on address change for Stop1. After changing an address use<b>Recalculate Miles</b>button to calculate miles again.</div>
                                </fieldset>
                            </div>
                        </div>


                        <cfif request.qSystemSetupOptions.freightBroker EQ 0 OR (request.qSystemSetupOptions.freightBroker EQ 2 AND chckdCarrier EQ 0)>
                            <div id="carriertabs-1-carrier2">
                                <div class="white-con-area" style="background-color: ##defaf9;">
                                    <div class="fa fa-minus-circle PlusToggleButton" onclick="showHideCarrierBlock(this,1);" style="position:relative;margin-left: 0;margin-top: 10px"></div>
                                    <div class="pg-title-carrier" style="float: left; width: 35%;padding-left:10px;font-weight:bold;font-size: 15px;">
                                        <h2 style="font-weight:bold;">Driver</h2>
                                    </div>
                                </div>

                                <div class="form-heading-carrier carrierBlock1">
                                    <div class="rt-button">
                                    </div>
                                    <div class="form-con" style="font-weight:bold;text-transform:uppercase;padding: 6px 10px 0 4px;">
                                        <cfset carrierLinksOnClick = "">
                                        <a href="javascript:void(0);" onClick="chooseCarrier2();"  id="removeCarrierTag1_2"  <cfif  structkeyexists(url,"loadid") and len(trim(url.loadid)) gt 1  AND  carrierID2_1 EQ "">style="display:none;"<cfelseif structkeyexists(url,"loadToBeCopied") and len(trim(url.loadToBeCopied)) gt 1  AND  carrierID2_1 EQ "" >style="display:none;"<cfelse>style="color:##236334;"</cfif>>
                                            <img style="vertical-align:bottom;" src="images/change.png">
                                            <span class="removetxt">Remove Driver</span>
                                        </a>

                                        <cfif request.qSystemSetupOptions1.ActivateBulkAndLoadNotificationEmail EQ 1>
                                            <div style="float: right;padding-right: 100px;">
                                                <div style="cursor:pointer;width:27px;background-color: ##bfbcbc;float: left;text-align: center;">
                                                    <img id="carrierLoadAlertEmailImg2" style="vertical-align:bottom;" src="images/black_mail.png" data-action="view">
                                                </div>   
                                                <cfif request.qSystemSetupOptions.freightBroker EQ 1 OR request.qSystemSetupOptions.freightBroker EQ 2>
                                                    <cfset emailActiveCarriers='Email Active Carriers'/>
                                                <cfelse>
                                                    <cfset emailActiveCarriers='Email Active Drivers'/>
                                                </cfif>
                                                <input id="carrierLoadAlertEmailButton2" style="margin:0 0 0 1px;" class="black-btn tooltip" <cfif mailsettings>data-allowmail="true"<cfelse>data-allowmail="false"</cfif> value="#emailActiveCarriers#" type="button">
                                            </div>
                                        </cfif>

                                    </div>
                                    <div class="clear"></div>
                                </div>

                                <div class="form-con carrierBlock1" style="width:400px">
                                    <input name="carrierID2_1" id="carrierID2_1" type="hidden" value="#carrierID2_1#" />
                                    <fieldset>
                                        <div id="choosCarrier2_1" style="<cfif len(carrierID2_1) gt 0>display:none<cfelse>display:block</cfif>;"><input type="hidden" name="carrier_id2_1" id="carrier_id2_1" value="#carrierID2_1#" data-limit="0">
                                        <div class="clear"></div>
                                        <cfset CarrierFilter = "openCarrierFilter();">
                                        <label class="LabelfreightBroker" style="width: 102px !important;">Choose Driver</label>
                                        <input name="selectedCarrier2_1" id="selectedCarrierValue2_1" class="carrier-box" style="margin-left: 0;width: 230px !important;" type="text" <cfif carrierLinksOnClick NEQ ''> disabled </cfif> tabindex="#evaluate(currentTab+33)#" title="Type text here to display list." data-stop="1"/>
                                        <input name="selectedCarrierValueContainer2_1" id="selectedCarrierValueValueContainer2_1" type="hidden" />
                                        <div class="clear"></div>
                                        <div class="clear"></div>
                                        </div>
                                        <div id="CarrierInfo2_1" style="<cfif len(carrierID2_1) gt 0>display:block<cfelse>display:none</cfif>;">

                                        <cfif structkeyexists(url,"loadid") and len(trim(url.loadid)) gt 1 and url.loadid NEQ 0>
                                            <cfset cLoadID=url.loadid>
                                        <cfelse>
                                            <cfset cLoadID=''>
                                        </cfif>
                                        <cfinvoke component="#variables.objloadGateway#" method="getCarrierInfoForm" returnvariable="formHTML" carrierId="#carrierID2_1#" urlToken="#session.URLToken#" loadid='#cLoadID#' id="2_1"/>
                                        #formHTML#
                                        </div>
                                        <label style="width: 102px !important;">Satellite Office</label>
                                        <select name="stOffice2_1" id="stOffice2_1">
                                            <option value="">Choose a Satellite Office Contact</option>
                                            <cfloop query="request.qOffices">
                                                <option value="#request.qOffices.CarrierOfficeID#">#request.qOffices.location#</option>
                                            </cfloop>
                                        </select>
                                    </fieldset>
                                </div>

                                <div class="form-con carrierBlock1" style="width:400px">
                                    <fieldset>
                                        <div style="width:100%" class="carrierrightdiv">

                                            <cfif request.qSystemSetupOptions.freightBroker EQ 0 OR (request.qSystemSetupOptions.freightBroker EQ 2 AND chckdCarrier EQ 0)>
                                                <div style="width:195px;float:left;border: 1px solid ##b3b3b3;margin-left: -7px;margin-top: -65px;padding-top: 5px;margin-bottom: 5px;">
                                                    <label class="carrierrightlabel" style="width: 58% !important;">Custom Driver Pay</label>
                                                    <label class="switch switch-flat" style="padding: 0;width: 60px;height: 23px;">
                                                        <input class="switch-input CustomDriverPay" id="CustomDriverPay2_1" name="CustomDriverPay2_1" type="checkbox" onchange="customDriverPay(this);" <cfif CustomDriverPay EQ 1> checked </cfif>/>
                                                        <span class="switch-label" data-on="On" data-off="Off"></span> 
                                                        <span class="switch-handle"></span> 
                                                    </label>
                                                    <div class="divCustomDriverPayOptions" <cfif CustomDriverPay NEQ 1>style="display: none"</cfif>>
                                                        <span style="float: left;width: 39%;text-align: right;font-weight: bold;">Flat Rate $
                                                        </span> 
                                                        <input type="checkbox" class="small_chk myElements chkCustomDriverPayFlatRate" style="float: left;margin-left: 5px;" id="chkCustomDriverPayFlatRate2_1" name="chkCustomDriverPayFlatRate2_1" onclick="customDriverPayOption(this)" <cfif CustomDriverPayOption2 EQ 1> checked </cfif>> 

                                                        <span id="span_CustomDriverPayFlatRate2_1" class="span_CustomDriverPayFlatRate" <cfif CustomDriverPayOption2 NEQ 1>style="display:none;"</cfif>>
                                                            <span style="float: left;">$</span>
                                                            <input type="text" style="width: 40px;margin-left: 5px;" class="customDriverPayFlatRate" id="customDriverPayFlatRate2_1" name="customDriverPayFlatRate2_1" onchange="calculateCustomDriverPay()" value="#CustomDriverPayFlatRate2#">
                                                        </span>
                                                        <div class="clear"></div>

                                                        <span style="float: left;width: 39%;text-align: right;font-weight: bold;">Percentage %
                                                        </span> 
                                                        <input type="checkbox" class="small_chk myElements chkCustomDriverPayPercentage" style="float: left;margin-left: 5px;" id="chkCustomDriverPayPercentage2_1" name="chkCustomDriverPayPercentage2_1" onclick="customDriverPayOption(this)" <cfif CustomDriverPayOption2 EQ 2> checked </cfif>> 
                                                        
                                                        <span id="span_CustomDriverPayPercentage2_1" class="span_CustomDriverPayPercentage" <cfif CustomDriverPayOption2 NEQ 2>style="display:none;"</cfif>>
                                                            <input type="text" style="width: 40px;" class="customDriverPayPercentage" id="customDriverPayPercentage2_1" name="customDriverPayPercentage2_1" onchange="calculateCustomDriverPay()" value="#customDriverPayPercentage2#">
                                                            <span style="float: left;">%</span>
                                                        </span>
                                                    </div>
                                                </div>
                                                <div class="clear"></div>
                                            </cfif>

                                            <div style="width:200px;float:left;">
                                                <label class="carrierrightlabel">Driver Cell</label>
                                                <input name="secDriverCell" value="#secDriverCell#" type="text" tabindex="#evaluate(currentTab+35)#" class="carriertextbox" maxlength="15" onchange="ParseUSNumber(this,'Driver Cell');"/>
                                            </div>
                                        </div>
                                    </fieldset>
                                </div>
                            </div>

                            <div id="carriertabs-1-carrier3">
                                <div class="white-con-area" style="background-color: ##defaf9;">
                                    <div class="fa fa-minus-circle PlusToggleButton" onclick="showHideCarrierBlock(this,1);" style="position:relative;margin-left: 0;margin-top: 10px"></div>
                                    <div class="pg-title-carrier" style="float: left; width: 35%;padding-left:10px;font-weight:bold;font-size: 15px;">
                                        <h2 style="font-weight:bold;">Driver</h2>
                                    </div>
                                </div>

                                <div class="form-heading-carrier carrierBlock1">
                                    <div class="rt-button">
                                    </div>
                                    <div class="form-con" style="font-weight:bold;text-transform:uppercase;padding: 6px 10px 0 4px;">
                                        <cfset carrierLinksOnClick = "">
                                        <a href="javascript:void(0);" onClick="chooseCarrier3();"  id="removeCarrierTag1_3"  <cfif  structkeyexists(url,"loadid") and len(trim(url.loadid)) gt 1  AND  carrierID3_1 EQ "">style="display:none;"<cfelseif structkeyexists(url,"loadToBeCopied") and len(trim(url.loadToBeCopied)) gt 1  AND  carrierID3_1 EQ "" >style="display:none;"<cfelse>style="color:##236334;"</cfif>>
                                            <img style="vertical-align:bottom;" src="images/change.png">
                                            <span class="removetxt">Remove Driver</span>
                                        </a>

                                        <cfif request.qSystemSetupOptions1.ActivateBulkAndLoadNotificationEmail EQ 1>
                                            <div style="float: right;padding-right: 100px;">
                                                <div style="cursor:pointer;width:27px;background-color: ##bfbcbc;float: left;text-align: center;">
                                                    <img id="carrierLoadAlertEmailImg3" style="vertical-align:bottom;" src="images/black_mail.png" data-action="view">
                                                </div>   
                                                <cfif request.qSystemSetupOptions.freightBroker EQ 1 OR request.qSystemSetupOptions.freightBroker EQ 2>
                                                    <cfset emailActiveCarriers='Email Active Carriers'/>
                                                <cfelse>
                                                    <cfset emailActiveCarriers='Email Active Drivers'/>
                                                </cfif>
                                                <input id="carrierLoadAlertEmailButton3" style="margin:0 0 0 1px;" class="black-btn tooltip" <cfif mailsettings>data-allowmail="true"<cfelse>data-allowmail="false"</cfif> value="#emailActiveCarriers#" type="button">
                                            </div>
                                        </cfif>

                                    </div>
                                    <div class="clear"></div>
                                </div>

                                <div class="form-con carrierBlock1" style="width:400px">
                                    <input name="carrierID3_1" id="carrierID3_1" type="hidden" value="#carrierID3_1#" />
                                    <fieldset>
                                        <div id="choosCarrier3_1" style="<cfif len(carrierID3_1) gt 0>display:none<cfelse>display:block</cfif>;"><input type="hidden" name="carrier_id3_1" id="carrier_id3_1" value="#carrierID3_1#" data-limit="0">
                                        <div class="clear"></div>
                                        <cfset CarrierFilter = "openCarrierFilter();">
                                        <label class="LabelfreightBroker" style="width: 102px !important;">Choose Driver</label>
                                        <input name="selectedCarrier3_1" id="selectedCarrierValue3_1" class="carrier-box" style="margin-left: 0;width: 230px !important;" type="text" <cfif carrierLinksOnClick NEQ ''> disabled </cfif> tabindex="#evaluate(currentTab+33)#" title="Type text here to display list." data-stop="1"/>
                                        <input name="selectedCarrierValueContainer3_1" id="selectedCarrierValueValueContainer3_1" type="hidden" />
                                        <div class="clear"></div>
                                        <div class="clear"></div>
                                        </div>
                                        <div id="CarrierInfo3_1" style="<cfif len(carrierID3_1) gt 0>display:block<cfelse>display:none</cfif>;">

                                        <cfif structkeyexists(url,"loadid") and len(trim(url.loadid)) gt 1 and url.loadid NEQ 0>
                                            <cfset cLoadID=url.loadid>
                                        <cfelse>
                                            <cfset cLoadID=''>
                                        </cfif>
                                        <cfinvoke component="#variables.objloadGateway#" method="getCarrierInfoForm" returnvariable="formHTML" carrierId="#carrierID3_1#" urlToken="#session.URLToken#" loadid='#cLoadID#' id="3_1"/>
                                        #formHTML#
                                        </div>
                                        <label style="width: 102px !important;">Satellite Office</label>
                                        <select name="stOffice3_1" id="stOffice3_1">
                                            <option value="">Choose a Satellite Office Contact</option>
                                            <cfloop query="request.qOffices">
                                                <option value="#request.qOffices.CarrierOfficeID#">#request.qOffices.location#</option>
                                            </cfloop>
                                        </select>
                                    </fieldset>
                                </div>

                                <div class="form-con carrierBlock1" style="width:400px">
                                    <fieldset>
                                        <div style="width:100%" class="carrierrightdiv">
                                            <cfif request.qSystemSetupOptions.freightBroker EQ 0 OR (request.qSystemSetupOptions.freightBroker EQ 2 AND chckdCarrier EQ 0)>
                                                <div style="width:195px;float:left;border: 1px solid ##b3b3b3;margin-left: -7px;margin-top: -65px;padding-top: 5px;margin-bottom: 5px;">
                                                    <label class="carrierrightlabel" style="width: 58% !important;">Custom Driver Pay</label>
                                                    <label class="switch switch-flat" style="padding: 0;width: 60px;height: 23px;">
                                                        <input class="switch-input CustomDriverPay" id="CustomDriverPay3_1" name="CustomDriverPay3_1" type="checkbox" onchange="customDriverPay(this);" <cfif CustomDriverPay EQ 1> checked </cfif>/>
                                                        <span class="switch-label" data-on="On" data-off="Off"></span> 
                                                        <span class="switch-handle"></span> 
                                                    </label>
                                                    <div class="divCustomDriverPayOptions" style="<cfif CustomDriverPay NEQ 1>display: none;</cfif>">
                                                        <span style="float: left;width: 39%;text-align: right;font-weight: bold;">Flat Rate $
                                                        </span> 
                                                        <input type="checkbox" class="small_chk myElements chkCustomDriverPayFlatRate" style="float: left;margin-left: 5px;" id="chkCustomDriverPayFlatRate3_1" name="chkCustomDriverPayFlatRate3_1" onclick="customDriverPayOption(this)" <cfif CustomDriverPayOption3 EQ 1> checked </cfif>> 
                                                        
                                                        <span id="span_CustomDriverPayFlatRate3_1" class="span_CustomDriverPayFlatRate" <cfif CustomDriverPayOption3 NEQ 1>style="display:none;"</cfif>>
                                                            <span style="float: left;">$</span>
                                                            <input type="text" style="width: 40px;margin-left: 5px;" class="customDriverPayFlatRate" id="customDriverPayFlatRate3_1" name="customDriverPayFlatRate3_1" onchange="calculateCustomDriverPay()" value="#CustomDriverPayFlatRate3#">
                                                        </span>

                                                        <div class="clear"></div>

                                                        <span style="float: left;width: 39%;text-align: right;font-weight: bold;">Percentage %
                                                        </span> 
                                                        <input type="checkbox" class="small_chk myElements chkCustomDriverPayPercentage" style="float: left;margin-left: 5px;" id="chkCustomDriverPayPercentage3_1" name="chkCustomDriverPayPercentage3_1" onclick="customDriverPayOption(this)" <cfif CustomDriverPayOption3 EQ 2> checked </cfif>> 
                                                        <span id="span_CustomDriverPayPercentage3_1" class="span_CustomDriverPayPercentage" <cfif CustomDriverPayOption3 NEQ 2>style="display:none;"</cfif>>
                                                            <input type="text" style="width: 40px;" class="customDriverPayPercentage" id="customDriverPayPercentage3_1" name="customDriverPayPercentage3_1" onchange="calculateCustomDriverPay()" value="#CustomDriverPayPercentage3#">
                                                            <span style="float: left;">%</span>
                                                        </span>

                                                    </div>
                                                </div>
                                                <div class="clear"></div>
                                            </cfif>

                                            <div style="width:200px;float:left;">
                                                <label class="carrierrightlabel">Driver Cell</label>
                                                <input name="thirdDriverCell" value="#thirdDriverCell#" type="text" tabindex="#evaluate(currentTab+35)#" class="carriertextbox" maxlength="15" onchange="ParseUSNumber(this,'Driver Cell');"/>
                                            </div>
                                        </div>
                                    </fieldset>
                                </div>
                            </div>
                        </cfif>
                        <cfif len(url.loadid) gt 1 AND NOT (request.qSystemSetupOptions.freightBroker EQ 0 OR (request.qSystemSetupOptions.freightBroker EQ 2 AND chckdCarrier EQ 0))>
                            <div id="carriertabs-1-QuoteList">
                                <div class="white-con-area" style="background-color: ##defaf9;">
                                    <h2 style="font-weight: bold;float: left;">Carrier Quote List For Load</h2>
                                    <div class="clear"></div>
                                    <div style="height:15px">
                                        <strong class="quoteSuccessMsg" style="color: ##2fb135;display: none;">
                                        New Quote Added Succesfully</strong>
                                    </div>
                                    <table width="100%" class="tbl_quote_list" id="tbl_quote_list_1">
                                        <thead style="background-color: ##4a98dc;color: ##fff;">
                                            <tr>
                                                <th>Quote Amt</th>
                                                <th>Carrier Name</th>
                                                <th>Carrier MC</th>
                                                <th>Contact</th>
                                                <th>Phone</th>
                                                <th>Active</th>
                                                <th>Mileage</th>
                                                <th>Price/Mile</th>
                                                <th>Equipment</th>
                                                <th>Created By</th>
                                                <th>Updated By</th>
                                                <th>&nbsp;</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <cfif len(url.loadid) gt 1 and request.qLoadCarrierQuotes.recordcount>
                                                <cfloop query="request.qLoadCarrierQuotes">
                                                    <cfif request.qLoadCarrierQuotes.StopNo eq 1> 
                                                        <tr>
                                                            <td id="quoteAmount_#request.qLoadCarrierQuotes.CarrierQuoteID#_1">
                                                                #DollarFormat(request.qLoadCarrierQuotes.Amount)#
                                                            </td>
                                                            <td><p onclick="openCarrierQuote(#request.qLoadCarrierQuotes.CarrierQuoteID#,1)" style="cursor: pointer;text-decoration: underline;color: ##0000ff;"><cfif request.qLoadCarrierQuotes.QUnknownCarrier>#request.qLoadCarrierQuotes.QCarrierName#<cfelse>#request.qLoadCarrierQuotes.CarrierName#</cfif></p></td>
                                                            <td><cfif request.qLoadCarrierQuotes.QUnknownCarrier>#request.qLoadCarrierQuotes.QMCNumber#<cfelse>#request.qLoadCarrierQuotes.MCNumber#</cfif></td>
                                                            <td><cfif request.qLoadCarrierQuotes.QUnknownCarrier>#request.qLoadCarrierQuotes.QContactPerson#<cfelse>#request.qLoadCarrierQuotes.ContactPerson#</cfif></td>
                                                            <td><cfif request.qLoadCarrierQuotes.QUnknownCarrier>#request.qLoadCarrierQuotes.QPhone#<cfelse>#request.qLoadCarrierQuotes.Phone#</cfif></td>
                                                            <td>#request.qLoadCarrierQuotes.Active#</td>
                                                            <td id="quoteMiles_#request.qLoadCarrierQuotes.CarrierQuoteID#_1">#request.qLoadCarrierQuotes.Miles#</td>
                                                            <td id="quotePricePerMiles_#request.qLoadCarrierQuotes.CarrierQuoteID#_1">
                                                            <cfif request.qLoadCarrierQuotes.Amount GT 0 AND request.qLoadCarrierQuotes.Miles GT 0>
                                                            #DollarFormat(request.qLoadCarrierQuotes.Amount/request.qLoadCarrierQuotes.Miles)#
                                                            <cfelse>
                                                                N/A
                                                            </cfif>
                                                            </td>
                                                            <td id="quoteEquipmentName_#request.qLoadCarrierQuotes.CarrierQuoteID#_1">#request.qLoadCarrierQuotes.EquipmentName#</td>
                                                            <td id="quoteCreatedBy_#request.qLoadCarrierQuotes.CarrierQuoteID#_1">#request.qLoadCarrierQuotes.CreatedBy#</td>
                                                            <td id="quoteUpdatedBy_#request.qLoadCarrierQuotes.CarrierQuoteID#_1">#request.qLoadCarrierQuotes.ModifiedBy#</td>
                                                            <td id="quoteAddBook_#request.qLoadCarrierQuotes.CarrierQuoteID#_1">
                                                                <input type="button" value="<cfif request.qLoadCarrierQuotes.QUnknownCarrier>Add<cfelse>Book</cfif>" 
                                                                    <cfif request.qLoadCarrierQuotes.QUnknownCarrier>
                                                                        onclick="addQuoteCarrier('1','#request.qLoadCarrierQuotes.Amount#','#request.qLoadCarrierQuotes.CarrierQuoteID#')"
                                                                    <cfelse>
                                                                        onclick="bookQuote('1','#request.qLoadCarrierQuotes.carrierid#','#request.qLoadCarrierQuotes.Amount#')"
                                                                    </cfif>
                                                                     style="width:50px !important;height: 17px;">
                                                            </td>
                                                        </tr>
                                                    </cfif>
                                                </cfloop>
                                            <cfelse>
                                                <tr>
                                                    <td colspan="12" class="noQuotesMsg">No Quotes Found</td>
                                                </tr>
                                            </cfif>
                                        </tbody>
                                    </table>
                                </div>
                            </div>
                            <div id="carriertabs-1-QuoteDetail">
                                <div class="white-con-area" style="background-color: ##defaf9;">
                                    <h2 style="font-weight: bold" class="add_quote_txt">Add Quote</h2>
                                </div>
                                <div class="form-heading-carrier">
                                    <div class="rt-button">
                                    </div>
                                    <div class="form-con" style="font-weight:bold;text-transform:uppercase;padding: 6px 10px 0 4px;">
                                        <a href="javascript:void(0);" onclick="changeCarrier(1);"  id="changeCarrier1" style="color:##236334;display:none">
                                            <img style="vertical-align:bottom;" src="images/change.png">
                                            <span class="removetxt">
                                                  <cfif request.qSystemSetupOptions.freightBroker EQ 2> 
                                                    Change   
                                                    <cfif  chckdCarrier EQ 0>
                                                            Driver
                                                        <cfelseif  chckdCarrier EQ 1>
                                                            Carrier
                                                        <cfelse>
                                                            Carrier/Driver
                                                        </cfif>
                                                    <cfelse>
                                                        Change #variables.freightBroker#
                                                    </cfif>
                                            </span>
                                        </a>
                                    </div>
                                    <div class="clear"></div>
                                </div>
                                <div class="form-con" style="width:400px">
                                    <fieldset>
                                        <div id="chooseQuoteCarrier1">
                                            <div class="clear"></div>
                                            <label style="width: 102px !important;">Carrier Name</label>
                                            <input class="quote-carrier-box" data-stop="1" style="margin-left: 0;width: 230px !important;" type="text" title="Type text here to display list." tabindex="#evaluate(currentTab++)#"/>
                                            <input type="hidden" id="CarrierQuoteID" value="0" name="CarrierQuoteID1">
                                            <input type="hidden" id="valueContainer" name="quoteCarrierID1">
                                            <input type="hidden" id="carrierName">
                                            <input type="hidden" id="carrierMCNumber">
                                            <input type="hidden" id="carrierContactPerson">
                                            <input type="hidden" id="carrierPhoneNo">
                                            <input type="hidden" id="carrierActive">
                                        </div>
                                        <div id="quoteCarrierInfo1">
                                        </div>
                                    </fieldset>
                                </div>
                                <div class="form-con" style="width:400px">
                                    <fieldset>
                                        <div style="width:100%" class="carrierrightdiv">
                                            <div style="width:200px;float:left;">
                                                <label class="carrierrightlabel">Amount</label>
                                                <input id="quoteAmount1" value="$0.00" type="text" class="carriertextbox myElements" name="quoteAmount1">
                                            </div>
                                            <div style="width:200px;float:left;">
                                                <label class="carrierrightlabel">Equipment</label>
                                                <select id="quoteEquipment1" name="quoteEquipment1" class="carriertextbox myElements" style="width: 116px !important;">
                                                    <option value="">Select</option>
                                                    <cfloop query="request.qEquipments">
                                                        <option value="#request.qEquipments.equipmentID#">#request.qEquipments.equipmentname#</option>
                                                    </cfloop>
                                                </select>
                                            </div>
                                        </div>
                                        <div class="clear"></div>

                                        <div style="width:100%" class="carrierrightdiv">
                                            <div style="width:200px;float:left;">
                                                <label class="carrierrightlabel">Truck##</label>
                                                <input id="quoteTruckNo1" name="quoteTruckNo1" value="" type="text" class="carriertextbox myElements">
                                            </div>
                                            <div style="width:200px;float:left;position: relative;">
                                                <label class="carrierrightlabel">Fuel Surcharge</label>
                                                <input id="quoteFuelSurcharge1" name="quoteFuelSurcharge1" value="" type="text" class="carriertextbox myElements">
                                            </div>
                                        </div>
                                        <div class="clear"></div>

                                        <div style="width:100%" class="carrierrightdiv">
                                            <div style="width:200px;float:left;">
                                                <label class="carrierrightlabel">Trailer##</label>
                                                <input id="quoteTrailerNo1" name="quoteTrailerNo1" value="" type="text" class="carriertextbox myElements">
                                            </div>
                                            <div style="width:200px;float:left;position: relative;">
                                                <label class="carrierrightlabel">Container##</label>
                                                <input id="quoteContainerNo1" name="quoteContainerNo1" value="" type="text" class="carriertextbox myElements">
                                            </div>
                                        </div>
                                        <div class="clear"></div>

                                        <div style="width:100%" class="carrierrightdiv">
                                            <div style="width:200px;float:left;">
                                                <label class="carrierrightlabel">Ref##</label>
                                                <input id="quoteRefNo1" name="quoteRefNo1" value="" type="text" class="carriertextbox myElements">
                                            </div>
                                            <div style="width:200px;float:left;position: relative;">
                                                <label class="carrierrightlabel">Carr Ref##</label>
                                                <input id="quoteCarrRefNo1" name="quoteCarrRefNo1" value="" type="text" class="carriertextbox myElements">
                                            </div>
                                        </div>
                                        <div class="clear"></div>

                                        <div style="width:100%" class="carrierrightdiv">
                                            <div style="width:200px;float:left;">
                                                <label class="carrierrightlabel">Miles##</label>
                                                <input id="quoteMiles1" name="quoteMiles1" value="0" type="text" class="carriertextbox myElements">
                                            </div>
                                            
                                        </div>
                                        <div class="clear"></div>
                                        <div style="width:100%" class="carrierrightdiv">
                                            <div style="width:400px;float:left;position: relative;">
                                                <label class="carrierrightlabel">Comments</label>
                                                <textarea id="quotecomments1" name="quotecomments1" style="width: 310px;height: 75px;"></textarea>
                                            </div>
                                        </div>
                                        <div class="clear"></div>
                                        <div style="width:100%" class="carrierrightdiv">
                                            <div style="width:200px;float:right;">
                                                <input type="button" onclick ="saveQuote(1)" value="Save Quote">
                                            </div>
                                        </div>
                                    </fieldset>
                                </div>
                            </div>
                            <cfinvoke component="#variables.objCarrierGateway#" method="searchCarrierLanes" LoadID ="#url.LoadID#" returnvariable="request.qLanes" />
                            <div id="carriertabs-1-Lanes">
                                <table width="100%" border="0" class="data-table carrierLanes" cellspacing="0" cellpadding="0">
                                    <thead>
                                        <tr>
                                            <th align="center" valign="middle" class="head-bg" style="border-left: 1px solid ##5d8cc9;border-top-left-radius: 5px;height: 20px;" width="2%">Select<br><input type="checkbox" class="myElements" checked onclick="selectAllCarriers(this);"></th>
                                            <th align="center" valign="middle" class="head-bg" width="8%">Carrier</th>
                                            <th align="center" valign="middle" class="head-bg" width="5%">Load##</th>
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
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <cfif request.qLanes.recordcount>
                                            <cfloop query="request.qLanes">
                                                <tr <cfif request.qLanes.currentRow mod 2 eq 0>bgcolor="##FFFFFF"<cfelse>bgcolor="##f7f7f7"</cfif>>
                                                    <td align="left" valign="middle" nowrap="nowrap" class="normal-td" style="border-left: 1px solid ##5d8cc9;">
                                                        <input type="checkbox" class="ckLanes" checked value="#request.qLanes.CarrierID#">
                                                    </td>
                                                    <td align="left" valign="middle" nowrap="nowrap" class="normal-td">
                                                        #request.qLanes.CarrierName#
                                                    </td>
                                                    <td align="right" valign="middle" nowrap="nowrap" class="normal-td">
                                                        #request.qLanes.LoadNumber#
                                                    </td>
                                                    <td align="left" valign="middle" nowrap="nowrap" class="normal-td">
                                                        #request.qLanes.PickUpCity#
                                                    </td>
                                                    <td align="left" valign="middle" nowrap="nowrap" class="normal-td">
                                                        #request.qLanes.PickUpState#
                                                    </td>
                                                    <td align="right" valign="middle" nowrap="nowrap" class="normal-td">
                                                        #request.qLanes.PickUpZip#
                                                    </td>
                                                    <td align="right" valign="middle" nowrap="nowrap" class="normal-td">
                                                        #DateFormat(request.qLanes.PickDate,'mm/dd/yyyy')#
                                                    </td>
                                                    <td align="left" valign="middle" nowrap="nowrap" class="normal-td">
                                                        #request.qLanes.DeliveryCity#
                                                    </td>
                                                    <td align="left" valign="middle" nowrap="nowrap" class="normal-td">
                                                        #request.qLanes.DeliveryState#
                                                    </td>
                                                    <td align="right" valign="middle" nowrap="nowrap" class="normal-td">
                                                        #request.qLanes.DeliveryZip#
                                                    </td>
                                                    <td align="right" valign="middle" nowrap="nowrap" class="normal-td">
                                                        #DateFormat(request.qLanes.DeliveryDate,'mm/dd/yyyy')#
                                                    </td>
                                                     <td align="left" valign="middle" nowrap="nowrap" class="normal-td">
                                                        #request.qLanes.EquipmentName#
                                                    </td>
                                                    <td align="right" valign="middle" nowrap="nowrap" class="normal-td">
                                                        #DollarFormat(request.qLanes.Cost)#
                                                    </td>
                                                    <td align="right" valign="middle" nowrap="nowrap" class="normal-td">
                                                        #request.qLanes.Miles#
                                                    </td>
                                                    <td align="right" valign="middle" nowrap="nowrap" class="normal-td">
                                                        #DollarFormat(request.qLanes.RatePerMile)#
                                                    </td>
                                                    <td align="right" valign="middle" nowrap="nowrap" class="normal-td">
                                                        #request.qLanes.IntransitStops#
                                                    </td>
                                                    <td align="left" valign="middle" nowrap="nowrap" class="normal-td">
                                                        #request.qLanes.CreatedBy#
                                                    </td>
                                                </tr>
                                            </cfloop>
                                        <cfelse>
                                            <tr>
                                                <td colspan="17" align="center" style="border-left: 1px solid ##5d8cc9;border-right: 1px solid ##5d8cc9;">No Records Found</td>
                                            </tr>
                                        </cfif>
                                    </tbody>
                                    <tfoot>
                                        <tr>
                                            <td colspan="12" align="left" valign="middle" class="footer-bg" style="border-left: 1px solid ##5d8cc9;border-bottom-left-radius: 5px;">
                                            </td>
                                            <td align="right" valign="middle" class="footer-bg carrierCurrencyISO">
                                            </td>
                                            <td valign="middle" class="footer-bg">
                                            </td>
                                            <td align="right" valign="middle" class="footer-bg carrierCurrencyISO">
                                            </td>
                                            <td colspan="2" align="left" valign="middle" class="footer-bg" style="border-right: 1px solid ##5d8cc9;border-bottom-right-radius: 5px;">
                                            </td>
                                        </tr>  
                                    </tfoot> 
                                </table>
                                <cfif request.qLanes.recordcount>
                                    <div style="text-align: right;">
                                        <input id="carrierLanesEmailButton" class="black-btn tooltip" data-allowmail="true" value="Email Carriers" type="button" <cfif mailsettings>data-allowmail="true"<cfelse>data-allowmail="false"</cfif>>
                                    </div>
                                </cfif>
                            </div>
                        </cfif>
                    </div>

                    <div class="clear"></div>
                    <div class="carrier-gap">&nbsp;</div>
                    <div class="clear"></div>
                    <div class="commodityToggle">
                    <div class="white-con-area" style="height: 36px;background-color: ##82bbef;width: 932px;">
                        <div style="padding: 0 18px;overflow:hidden;">
                            <h2 onclick="window.open('index.cfm?event=unit&#session.URLToken#', '_blank');" style="color:white;font-weight:bold;float: left;cursor: pointer;">Commodities and Accessorials Table</h2>
                        </div>
                    </div>
<div class="carrier-mid" style="width:932px">
    <table width="100%" class="noh carrierCalTable" border="0" cellspacing="0" cellpadding="0" id="commodity_1">
        <thead>
            <tr>
                <th width="5" align="right" valign="top">
                    <img src="images/top-left.gif" alt="" width="5" height="23" />
                </th>
                <th align="right" valign="middle" class="head-bg">Fee</th>
                <th align="right" valign="middle" class="head-bg">Qty</th>
                <th align="left" valign="middle" class="head-bg textalign">Type</th>
                <th align="left" valign="middle" class="head-bg">Description</th>
                <th align="left" valign="middle" class="head-bg">Dimensions</th>
                <cfif request.qSystemSetupOptions.commodityWeight>
                    <th align="right" valign="middle" class="head-bg">Wt(lbs)</th>
                </cfif>

                <th align="right" valign="middle" class="head-bg"><a style="text-decoration: underline;color:##4322cc;" href="index.cfm?event=class&#session.URLToken#">Class</a></th>

                <cfif NOT ListContains(session.rightsList,'HideCustomerPricing',',')>
                    <th align="right" valign="middle" class="head-bg">Cust. Rate</th>
                </cfif>
                                
                <th align="right" valign="middle" class="head-bg textalign">#variables.freightBrokerShortForm#. Rate</th>

                <cfif NOT ListContains(session.rightsList,'HideCustomerPricing',',')>
                    <th align="right" valign="middle" class="head-bg textalign">
                        % of Total
                    </th>
                </cfif>

                <cfif request.qSystemSetupOptions.UseDirectCost>
                    <th align="right" valign="middle" class="head-bg textalign">Direct Cost</th>
                </cfif>

                <cfif NOT ListContains(session.rightsList,'HideCustomerPricing',',')>
                    <th align="right" valign="middle" class="head-bg textalign">Cust. Total</th>
                </cfif>

                <th align="right" valign="middle" class="head-bg textalign">#variables.freightBrokerShortForm#. Total</th>

                <cfif request.qSystemSetupOptions.UseDirectCost>
                    <th align="right" valign="middle" class="head-bg textalign">D.Cost Total</th>
                </cfif>

                <th align="right" valign="middle" class="head-bg2 textalign" style="width:40px;"></th>
                <th width="5" align="right" valign="top">
                    <img src="images/top-right.gif" alt="" width="5" height="23" />
                </th>
            </tr>
        </thead>
        <cfset descriptionWidth = 510>
        <cfif request.qSystemSetupOptions.commodityWeight>
            <cfset descriptionWidth = descriptionWidth-58>
        </cfif>
        <cfif NOT ListContains(session.rightsList,'HideCustomerPricing',',')>
            <cfset descriptionWidth = descriptionWidth-192>
        </cfif>
        <cfif request.qSystemSetupOptions.UseDirectCost>
            <cfset descriptionWidth = descriptionWidth-130>
        </cfif>
        <tbody class="commRows">
            <cfif (structkeyexists(url,"loadid") and len(trim(url.loadid)) gt 1) OR (structkeyexists(url,"loadToBeCopied") and len(trim(url.loadToBeCopied)) gt 1)>
                <cfset countCommodities=1>
                <cfset currentTab = 75>
                <cfloop query="request.qItems">
                    <tr <cfif request.qItems.currentRow mod 2 eq 0>bgcolor="##FFFFFF"<cfelse>  bgcolor="##f7f7f7"</cfif> id="commodities1_#countCommodities#">
                        <td height="20" class="lft-bg">&nbsp;</td>
                        <td class="lft-bg2" valign="middle" align="center">
                            <input <cfif structkeyexists(session,"rightslist") and NOT ListContains(session.rightsList,'ComData',',') AND ListContains('ComData-Fuel,ComData-CashAdvance',request.qItems.description,',')> style="opacity: 0.5;" onclick="return false;"</cfif> name="isFee_#countCommodities#" id="isFee_#countCommodities#" class="check isFee" <cfif request.qItems.fee is 1> checked="checked" </cfif> type="checkbox" tabindex="#evaluate(currentTab+1)#" />
                        </td>
                        <td class="normaltdC" valign="middle" align="left">
                            <input <cfif structkeyexists(session,"rightslist") and NOT ListContains(session.rightsList,'ComData',',') AND ListContains('ComData-Fuel,ComData-CashAdvance',request.qItems.description,',')> style="opacity: 0.5;" readonly</cfif> name="qty_#countCommodities#" id="qty_#countCommodities#" onchange="CalculateTotal('#Application.dsn#')" class="q-textbox qty" type="text" value="#request.qItems.qty#"  tabindex="#evaluate(currentTab+1)#"/>
                        </td>

                        <td class="normaltdC" valign="middle" align="left">
                            <select <cfif structkeyexists(session,"rightslist") and NOT ListContains(session.rightsList,'ComData',',') AND ListContains('ComData-Fuel,ComData-CashAdvance',request.qItems.description,',')> style="opacity: 0.5;pointer-events: none;"</cfif> name="unit_#countCommodities#" id="unit_#countCommodities#" class="t-select unit typeSelect1" onChange="changeQuantityWithtype(this,'');checkForFee(this.value,'#request.qItems.currentRow#','','#application.dsn#');CalculateTotal('#Application.dsn#'); autoloaddescription(this, '', '#countCommodities#','#application.dsn#');" tabindex="#evaluate(currentTab+1)#">
                                <option value=""></option>
                                <cfloop query="request.qUnits">
                                    <option value="#request.qUnits.unitID#" <cfif request.qUnits.unitID is request.qItems.unitid> selected="selected" </cfif>>#request.qUnits.unitName#<cfif trim(request.qUnits.unitCode) neq ''>(#request.qUnits.unitCode#)</cfif>
                                    </option>
                                </cfloop>
                            </select>
                        </td>

                        <td class="normaltdC" valign="middle" align="left">
                            <input <cfif structkeyexists(session,"rightslist") and NOT ListContains(session.rightsList,'ComData',',') AND ListContains('ComData-Fuel,ComData-CashAdvance',request.qItems.description,',')> style="opacity: 0.5;width:#descriptionWidth#px;" Readonly <cfelse>style="width:#descriptionWidth#px;"</cfif> name="description_#countCommodities#" id="description_#countCommodities#" class="t-textbox" value="#replace(request.qItems.description,'"','&quot;','all')#" type="text" tabindex="#evaluate(currentTab+1)#"/>
                        </td>

                        <td class="normaltdC" valign="middle" align="left">
                            <input <cfif structkeyexists(session,"rightslist") and NOT ListContains(session.rightsList,'ComData',',') AND ListContains('ComData-Fuel,ComData-CashAdvance',request.qItems.description,',')> style="opacity: 0.5;width:58px;" Readonly <cfelse>style="width:58px;"</cfif> name="dimensions_#countCommodities#" id="dimensions_#countCommodities#" class="t-textbox" value="#replace(request.qItems.dimensions,'"','&quot;','all')#" type="text" maxlength="150" tabindex="#evaluate(currentTab+1)#"/>
                        </td>

                        <cfif request.qSystemSetupOptions.commodityWeight>
                            <td class="normaltdC" valign="middle" align="left"><input <cfif structkeyexists(session,"rightslist") and NOT ListContains(session.rightsList,'ComData',',') AND ListContains('ComData-Fuel,ComData-CashAdvance',request.qItems.description,',')> style="opacity: 0.5;" Readonly</cfif> name="weight_#countCommodities#" id="weight_#countCommodities#" class="wt-textbox" value="#request.qItems.weight#" type="text" tabindex="#evaluate(currentTab+1)#" /></td>
                        </cfif>
                        
                        <td class="normaltdC" valign="middle" align="left" >
                            <select <cfif structkeyexists(session,"rightslist") and NOT ListContains(session.rightsList,'ComData',',') AND ListContains('ComData-Fuel,ComData-CashAdvance',request.qItems.description,',')> style="width:60px;opacity: 0.5;pointer-events: none;"<cfelse> style="width:60px;" </cfif> name="class_#countCommodities#"  class="t-select sel_class" tabindex="#evaluate(currentTab+1)#" >
                                <option value=""></option>
                                <cfloop query="request.qClasses">
                                    <option value="#request.qClasses.classId#" <cfif request.qClasses.classId is request.qItems.classid> selected="selected" </cfif>>
                                        #request.qClasses.className#
                                    </option>
                                </cfloop>
                            </select>
                        </td>

                        <cfif request.qItems.CUSTRATE eq "">
                            <cfset variables.CUSTRATE = '0.00' >
                        <cfelse>
                            <cfset variables.CUSTRATE = request.qItems.CUSTRATE >
                        </cfif>
                        <cfif request.qItems.CARRRATE eq "">
                            <cfset variables.CARRRATE = '0.00' >
                        <cfelse>
                            <cfset variables.CARRRATE = request.qItems.CARRRATE >
                        </cfif>

                        <cfif request.qSystemSetupOptions.ForeignCurrencyEnabled>
                            <cfset variables.CUSTRATE = replace((variables.CUSTRATE),",","","ALL")>
                        <cfelse>
                            <cfset variables.CUSTRATE = replace(myCurrencyFormatter(variables.CUSTRATE),",","","ALL")>
                        </cfif>

                        <cfif request.qSystemSetupOptions.ForeignCurrencyEnabled>
                            <cfset variables.CARRRATE = replace((variables.CARRRATE),",","","ALL")>
                        <cfelse>
                            <cfset variables.CARRRATE = replace(myCurrencyFormatter(variables.CARRRATE),",","","ALL")>
                        </cfif>

                        <cfif request.qItems.paymentadvance EQ 1>
                            <cfif request.qItems.CUSTRATE GT 0>
                                <cfset variables.CUSTRATE = "("&variables.CUSTRATE&")">
                            </cfif>
                            <cfif request.qItems.CARRRATE GT 0>
                                <cfset variables.CARRRATE = "("&variables.CARRRATE&")">
                            </cfif>
                        </cfif>

                        <cfif NOT ListContains(session.rightsList,'HideCustomerPricing',',')>
                            <td class="normaltdC" valign="middle" align="left">
                               <input <cfif structkeyexists(session,"rightslist") and NOT ListContains(session.rightsList,'ComData',',') AND ListContains('ComData-Fuel,ComData-CashAdvance',request.qItems.description,',')> style="opacity: 0.5;" Readonly</cfif> name="CustomerRate_#countCommodities#" id="CustomerRate_#countCommodities#" class="q-textbox CustomerRate" value="#variables.CUSTRATE#" onChange="CalculateTotal('#Application.dsn#');formatDollarNegative(this.value, this.id);"  type="text" tabindex="#evaluate(currentTab+1)#" <cfif request.qItems.paymentadvance EQ 1>style="color: red;"</cfif>/>
                            </td>
                        <cfelse>
                            <input type="hidden" name="CustomerRate_#countCommodities#" id="CustomerRate_#countCommodities#" <cfif request.qSystemSetupOptions.ForeignCurrencyEnabled>value="#replace((variables.CUSTRATE),",","","ALL")#"<cfelse>value="#variables.CUSTRATE#"</cfif>>
                        </cfif>

                        <td class="normaltd2C" valign="middle" align="left">
                            <input <cfif structkeyexists(session,"rightslist") and NOT ListContains(session.rightsList,'ComData',',') AND ListContains('ComData-Fuel,ComData-CashAdvance',request.qItems.description,',')> style="opacity: 0.5;" Readonly</cfif> name="CarrierRate_#countCommodities#" id="CarrierRate_#countCommodities#" class="q-textbox CarrierRate" value="#variables.CARRRATE#" onChange="CalculateTotal('#Application.dsn#');formatDollarNegative(this.value, this.id);"  type="text" data-oldval="#variables.CARRRATE#" tabindex="#evaluate(currentTab+1)#" <cfif request.qItems.paymentadvance EQ 1>style="color: red;"</cfif>/>
                        </td>

                        <cfif request.qItems.CarrRateOfCustTotal EQ "">
                            <cfset variables.CarrRateOfCustTotal = 0.00>
                        <cfelse>
                            <cfset variables.CarrRateOfCustTotal = request.qItems.CarrRateOfCustTotal>
                        </cfif>

                        <cfif NOT ListContains(session.rightsList,'HideCustomerPricing',',')>
                            <td class="normaltd2C" valign="middle" align="left">
                                <input <cfif structkeyexists(session,"rightslist") and NOT ListContains(session.rightsList,'ComData',',') AND ListContains('ComData-Fuel,ComData-CashAdvance',request.qItems.description,',')> style="opacity: 0.5;width:105px;" Readonly</cfif> name="CarrierPer_#countCommodities#" id="CarrierPer_#countCommodities#" class="q-textbox CarrierPer" value="#variables.CarrRateOfCustTotal#%" onChange="ConfirmMessage('#request.qItems.currentRow#',0)"  type="text" tabindex="#evaluate(currentTab+1)#" />
                            </td>
                        <cfelse>
                            <input type="hidden" name="CarrierPer_#countCommodities#" id="CarrierPer_#countCommodities#"  value="#variables.CarrRateOfCustTotal#%" >
                            
                        </cfif>

                        <cfif len(trim(request.qItems.DirectCost))>
                            <cfset variables.directCost = request.qItems.DirectCost>
                        <cfelse>
                            <cfset variables.directCost = '0.00'>
                        </cfif>
                        <cfif request.qSystemSetupOptions.UseDirectCost>
                            <td class="normaltdC" valign="middle" align="left">
                                <input onChange="CalculateTotal('#Application.dsn#');formatDollarNegative(this.value, this.id);" name="directCost_#countCommodities#" id="directCost_#countCommodities#" class="q-textbox directCost" value="#myCurrencyFormatter(variables.directCost)#" type="text" <cfif LEN(TRIM(request.qItems.paymentAdvance)) AND request.qItems.paymentAdvance>style="background-color: ##e3e3e3;" Readonly
                                </cfif> tabindex="#evaluate(currentTab+1)#"/>
                            </td>
                        <cfelse>
                            <input  name="directCost_#countCommodities#" id="directCost_#countCommodities#"  value="#variables.directCost#" type="hidden" />
                        </cfif>

                        <cfif NOT ListContains(session.rightsList,'HideCustomerPricing',',')>
                            <td class="normaltdC" valign="middle" align="left">
                                <input style="background-color: ##e3e3e3;" Readonly name="custCharges_#countCommodities#" id="custCharges_#countCommodities#" class="q-textbox custCharges" value="#request.qItems.CUSTCHARGES#" onChange="CalculateTotal('#Application.dsn#');" type="text" />
                            </td>
                        <cfelse>
                            <input type="hidden" name="custCharges_#countCommodities#" id="custCharges_#countCommodities#" value="#request.qItems.CUSTCHARGES#">
                        </cfif>

                        <td class="normaltd2C" valign="middle" align="left">
                            <input  style="background-color: ##e3e3e3;" Readonly name="carrCharges_#countCommodities#" id="carrCharges_#countCommodities#" class="q-textbox carrCharges" value="#request.qItems.CARRCHARGES#" onChange="CalculateTotal('#Application.dsn#');" type="text" data-oldval="#request.qItems.CARRCHARGES#"/>
                        </td>

                        <cfif len(trim(request.qItems.DirectCostTotal))>
                            <cfset variables.DirectCostTotal = request.qItems.DirectCostTotal>
                        <cfelse>
                            <cfset variables.DirectCostTotal = '0.00'>
                        </cfif>
                        <cfif request.qSystemSetupOptions.UseDirectCost>
                            <td class="normaltdC" valign="middle" align="left">
                                <input  name="directCostTotal_#countCommodities#" id="directCostTotal_#countCommodities#" class="q-textbox directCostTotal" value="#myCurrencyFormatter(variables.DirectCostTotal)#" type="text"  style="background-color: ##e3e3e3;width: 60px;" Readonly />
                            </td>
                        <cfelse>
                            <input  name="directCostTotal_#countCommodities#" id="directCostTotal_#countCommodities#" class="q-textbox" value="#DollarFormat(variables.DirectCostTotal)#" type="hidden" />
                        </cfif>

                        <td class="normaltdC" valign="middle" align="left">
                            <img onclick="delRowCommodities(this)" name="delComm_#countCommodities#" id="delComm_#countCommodities#" src="images/delete-icon-red.gif" style="width:10px;margin-left: 5px;cursor: pointer;float:left">
                            <img name="sortComm_#countCommodities#" id="sortComm_#countCommodities#" src="images/sort.png" style="width:12px;margin-left: 5px;cursor: pointer">
                            <input type="hidden" name="commStopId_#countCommodities#" id="commStopId_#countCommodities#" value="<cfif structKeyExists(url, "loadToBeCopied") and len(trim(url.loadToBeCopied)) gt 1>0<cfelse>#request.qItems.LoadStopCommoditiesID#</cfif>">
                            <input type="hidden" name="commSrNo_#countCommodities#" id="commSrNo_#countCommodities#" value="#request.qItems.SrNo#">
                        </td>
                        <td class="normal-td3">&nbsp;</td>
                    </tr>
                    <cfset countCommodities++>
                </cfloop>           
            <cfelse>
                <cfset currentTab=74>
                <cfloop from ="1" to="1" index="rowNum">
                    <tr <cfif rowNum mod 2 eq 0>bgcolor="##FFFFFF"<cfelse>  bgcolor="##f7f7f7"</cfif> id="commodities1_#rowNum#">
                        <td height="20" class="lft-bg">&nbsp;</td>
                        <td class="lft-bg2" valign="middle" align="center">
                            <input name="isFee_#rowNum#" id="isFee_#rowNum#" class="isFee check" type="checkbox" tabindex="#evaluate(currentTab+1)#"/>
                        </td>
                        <td class="normaltdC" valign="middle" align="left">
                            <input name="qty_#rowNum#" id="qty_#rowNum#" onChange="CalculateTotal('#Application.dsn#')" class="qty q-textbox" type="text" value="1" tabindex="#evaluate(currentTab+1)#"/>
                        </td>
                        <td class="normaltdC" valign="middle" align="left">
                            <select name="unit_#rowNum#" id="unit_#rowNum#" class="t-select unit typeSelect1" onChange="changeQuantityWithtype(this,'');checkForFee(this.value,'#rowNum#','','#application.dsn#');CalculateTotal('#Application.dsn#'); autoloaddescription(this, '', '#rowNum#','#application.dsn#');" tabindex="#evaluate(currentTab+1)#" >
                                <option value=""></option>
                                <cfloop query="request.qUnits">
                                    <option value="#request.qUnits.unitID#">#request.qUnits.unitName#<cfif trim(request.qUnits.unitCode) neq ''>(#request.qUnits.unitCode#)</cfif>
                                            </option>
                                </cfloop>
                            </select>
                        </td>
                        <td class="normaltdC" valign="middle" align="left">
                            <input name="description_#rowNum#" id="description_#rowNum#" class="t-textbox" type="text" tabindex="#evaluate(currentTab+1)#" style="width:#descriptionWidth#px;"/>
                        </td>
                        <td class="normaltdC" valign="middle" align="left">
                            <input name="dimensions_#rowNum#" id="dimensions_#rowNum#" class="t-textbox" type="text" tabindex="#evaluate(currentTab+1)#" maxlength="150" style="width: 58px;"/>
                        </td>
                        <cfif request.qSystemSetupOptions.commodityWeight>
                            <td class="normaltdC" valign="middle" align="left">
                                <input name="weight_#rowNum#" id="weight_#rowNum#" class="wt-textbox" type="text" tabindex="#evaluate(currentTab+1)#"/>
                            </td>
                        </cfif>

                        <td class="normaltdC" valign="middle" align="left">
                            <select name="class_#rowNum#" class="t-select" tabindex="#evaluate(currentTab+1)#" style="width:60px;">
                                <option value=""></option>
                                <cfloop query="request.qClasses">
                                    <option value="#request.qClasses.classId#">#request.qClasses.className#</option>
                                </cfloop>
                            </select>
                        </td>

                        <cfset variables.carrierPercentage = 0>
                        <cfif IsDefined("request.qItems.CarrRateOfCustTotal") and IsNumeric(request.qItems.CarrRateOfCustTotal)>
                            <cfset variables.carrierPercentage = request.qItems.CarrRateOfCustTotal>
                        </cfif>

                        <cfif NOT ListContains(session.rightsList,'HideCustomerPricing',',')>
                            <td class="normaltdC" valign="middle" align="left">
                                <input name="CustomerRate_#rowNum#" id="CustomerRate_#rowNum#" tabindex="#evaluate(currentTab+1)#" class="q-textbox CustomerRate" onChange="CalculateTotal('#Application.dsn#')"  type="text" <cfif request.qSystemSetupOptions.ForeignCurrencyEnabled>value="#variables.CustomerRate#"<cfelse>value="#DollarFormat(variables.CustomerRate)#"</cfif> />
                            </td>
                        <cfelse>
                            <input type="hidden" name="CustomerRate_#rowNum#" id="CustomerRate_#rowNum#" <cfif request.qSystemSetupOptions.ForeignCurrencyEnabled>value="#variables.CustomerRate#"<cfelse>value="#DollarFormat(variables.CustomerRate)#"</cfif>>
                        </cfif>

                        <td class="normaltd2C" valign="middle" align="left">
                            <input name="CarrierRate_#rowNum#" id="CarrierRate_#rowNum#" tabindex="#evaluate(currentTab+1)#"  class="q-textbox CarrierRate"  onChange="CalculateTotal('#Application.dsn#')" type="text" <cfif request.qSystemSetupOptions.ForeignCurrencyEnabled>value="#(variables.CarrierRate)#"<cfelse>value="#DollarFormat(variables.CarrierRate)#"</cfif>/>
                        </td>
 
                        <cfif NOT ListContains(session.rightsList,'HideCustomerPricing',',')>
                            <td class="normaltd2C" valign="middle" align="left">
                                <input name="CarrierPer_#rowNum#" id="CarrierPer_#rowNum#" class="q-textbox CarrierPer" value="#variables.carrierPercentage#%" onChange="ConfirmMessage('#rowNum#',0)"  type="text" tabindex="#evaluate(currentTab+1)#" />
                            </td>
                        <cfelse>
                            <input name="CarrierPer_#rowNum#" id="CarrierPer_#rowNum#" value="#variables.carrierPercentage#%" type="hidden"  />
                        </cfif>

                        <cfif request.qSystemSetupOptions.UseDirectCost>
                            <td class="normaltdC" valign="middle" align="left">
                                <input name="directCost_#rowNum#" id="directCost_#rowNum#" class="q-textbox directCost"  type="text" value="$0.00" onChange="CalculateTotal('#Application.dsn#');formatDollarNegative(this.value, this.id);" tabindex="#evaluate(currentTab+1)#"/>
                            </td>
                        <cfelse>
                            <input name="directCost_#rowNum#" id="directCost_#rowNum#" type="hidden" value="$0.00" />
                        </cfif>

                        <cfif NOT ListContains(session.rightsList,'HideCustomerPricing',',')>
                            <td class="normaltdC" valign="middle" align="left">
                                <input name="custCharges_#rowNum#" id="custCharges_#rowNum#" class="q-textbox custCharges" onChange="CalculateTotal('#Application.dsn#');" type="text" value="0.00" readonly style="background-color: ##e3e3e3;" />
                            </td>
                        <cfelse>
                            <input name="custCharges_#rowNum#" id="custCharges_#rowNum#" type="hidden" value="0.00" />
                        </cfif>

                        <td class="normaltd2C" valign="middle" align="left">
                            <input name="carrCharges_#rowNum#" id="carrCharges_#rowNum#" class="q-textbox carrCharges" onChange="CalculateTotal('#Application.dsn#');" type="text" value="0.00" readonly style="background-color: ##e3e3e3;" />
                        </td>
                                
                        <cfif request.qSystemSetupOptions.UseDirectCost>
                            <td class="normaltdC" valign="middle" align="left">
                                <input name="directCostTotal_#rowNum#" id="directCostTotal_#rowNum#" class="q-textbox directCostTotal"  type="text" value="$0.00" readonly style="background-color: ##e3e3e3;width: 60px;"/>
                            </td>
                        <cfelse>
                            <input name="directCostTotal_#rowNum#" id="directCostTotal_#rowNum#" type="hidden" value="$0.00"/>
                        </cfif>

                        <td class="normaltdC" valign="middle" align="left">
                            <img onclick="delRowCommodities(this)" name="delComm_#rowNum#" id="delComm_#rowNum#" src="images/delete-icon-red.gif" style="width:10px;margin-left: 5px;cursor: pointer;float: left">
                            <img name="sortComm_#rowNum#" id="sortComm_#rowNum#" src="images/sort.png" style="width:12px;margin-left: 5px;cursor: pointer">
                            <input type="hidden" name="commStopId_#rowNum#" id="commStopId_#rowNum#" value="0">
                            <input type="hidden" name="commSrNo_#rowNum#" id="commSrNo_#rowNum#" value="0">
                        </td>
                        <td class="normal-td3C normal-td3">&nbsp;</td>
                    </tr>
                </cfloop>
            </cfif>
        </tbody>
        <tfoot>
            <cfif (structkeyexists(url,"loadid") and len(trim(url.loadid)) gt 1) OR (structkeyexists(url,"loadToBeCopied") and len(trim(url.loadToBeCopied)) gt 1)>
                <cfif structkeyexists(url,"loadid") and len(trim(url.loadid)) gt 1>
                    <input type="hidden" value="#request.qItems.Recordcount#" name="TotalrowCommodities1"  id="TotalrowCommodities1">
                    <input type="hidden" value="#request.qItems.Recordcount#" name="totalResult1"  id="totalResult1">
                    <input type="hidden" value="#request.qItems.Recordcount#" name="commoditityAlreadyCount1"  id="commoditityAlreadyCount1">
                </cfif>
                <cfif structkeyexists(url,"loadToBeCopied") and len(trim(url.loadToBeCopied)) gt 1>
                    <input type="hidden" value="#request.qItems.Recordcount#" name="TotalrowCommodities1"  id="TotalrowCommodities1">
                    <input type="hidden" value="#request.qItems.Recordcount#" name="totalResult1"  id="totalResult1">
                    <input type="hidden" value="#request.qItems.Recordcount#" name="commoditityAlreadyCount1"  id="commoditityAlreadyCount1">
                </cfif>
            <cfelse>
                <input type="hidden" value="1" name="TotalrowCommodities1"  id="TotalrowCommodities1">
                <input type="hidden" value="1" name="totalResult1"  id="totalResult1">
            </cfif>
            <tr>
                <td width="5" align="left" valign="top">
                    <img src="images/left-bot.gif" alt="" width="5" height="23" />
                </td>
                <td <cfif request.qSystemSetupOptions.commodityWeight> colspan="6" <cfelse>  colspan="5"</cfif> align="left" valign="middle" class="footer-bg"></td>
                <td width="5" align="right" valign="top" class="footer-bg"></td>
                <cfif NOT ListContains(session.rightsList,'HideCustomerPricing',',')>
                    <td width="5" align="right" valign="top" class="footer-bg customerCurrencyISO"></td>
                </cfif>
                <td width="5" align="right" valign="top" class="footer-bg carrierCurrencyISO"></td>
                <cfif NOT ListContains(session.rightsList,'HideCustomerPricing',',')>
                    <td width="5" align="right" valign="top" class="footer-bg"></td>
                </cfif>
                <cfif request.qSystemSetupOptions.UseDirectCost>
                    <td width="5" align="right" valign="top" class="footer-bg"></td>
                </cfif>
                <cfif NOT ListContains(session.rightsList,'HideCustomerPricing',',')>
                    <td width="5" align="right" valign="top" class="footer-bg customerCurrencyISO"></td>
                </cfif>
                <td width="5" align="right" valign="top" class="footer-bg carrierCurrencyISO"></td>
                <cfif request.qSystemSetupOptions.UseDirectCost>
                    <td width="5" align="right" valign="top" class="footer-bg"></td>
                </cfif>
                <td width="5" align="right" valign="top" class="footer-bg"></td>
                <td width="5" align="right" valign="top">
                    <img src="images/right-bot.gif" alt="" width="5" height="23" />
                </td>
            </tr>
        </tfoot>
    </table>
    <div class="clear"></div>
</div>
                    <div class="addcommodityButton">
                        <input type="button" onclick="addNewRowCommodities(this,1)" value="Add New Row" >
                    </div>
                </div>
                    <div class="carrier-gap">&nbsp;</div>
                </div>
            </div>
        </div>
        <div class="form-heading" style="background-color: #request.qSystemSetupOptions1.BackgroundColorForContent# !important;margin-top: -15px;">
            <div class="rt-button2">
            </div>

            <div class="clear"></div>


            <div class="right bottom-btns" style="<cfif len(trim(url.loadid)) gt 0 and url.loadid NEQ 0>height:30px;</cfif>margin-top: -28px;width: 275px;">

                <div>
                    <input name="addstopButton" type="button" class="green-btn" onclick="AddStop('stop2',2);setStopValue();" value="Add Stop" style="color: ##599700;">
                </div>
                <cfif ListContains(session.rightsList,'runReports',',')>
                    <cfset carrierReportOnClick = "window.open('../reports/loadReportForCarrierConfirmation.cfm?loadid=#editid#&#session.URLToken#')">
                    <cfset customerReportOnClick = "window.open('../reports/CustomerInvoiceReport.cfm?loadid=#editid#&#session.URLToken#')">
                <cfelse>
                    <cfset carrierReportOnClick = "">
                    <cfset customerReportOnClick = "">
                </cfif>
                <input type="hidden" name="shipperFlag" id="shipperFlag" value="0">
                <input type="hidden" name="consigneeFlag" id="consigneeFlag" value="0">
                <cfif structkeyexists(url,"loadid") and len(trim(url.loadid)) gt 1>

                    <div>
                        <!--- BEGIN: Prevent already transcore synced load update from Agent has no Transcore Login setup in their profile Date:20 Sep 2013  --->
                    <cfif request.qcurAgentdetails.integratewithTran360 EQ false AND posttoTranscore EQ 1>
                        <cfif structkeyexists(session,"rightslist") and len(trim(url.loadid)) gt 0 and variables.loaddisabledStatus and ListContains(session.rightsList,'UnlockLoad',',')>
                            <input id="Unlock" name="unlock" type="button" class="green-btnUnlock" onClick="removeEditAccess('#url.loadid#','#session.empid#');" value="Unlock" style="width:100px !important;float:right;">
                        <cfelse>
                            <input name="save" type="submit" class="green-btn"  onClick="alert('Any changes you make will not be updated to the DAT Load Board because you do not have credentials setup on your User Profile.');javascript:return saveButStayOnPage('#url.loadid#');" onfocus="checkUnload();" value="Save">
                        </cfif>
                    <cfelseif request.qcurAgentdetails.loadBoard123 EQ false AND PostTo123LoadBoard EQ 1>
                        <cfif structkeyexists(session,"rightslist") and len(trim(url.loadid)) gt 0 and variables.loaddisabledStatus and ListContains(session.rightsList,'UnlockLoad',',')>
                            <input id="Unlock" name="unlock" type="button" class="green-btnUnlock" onClick="removeEditAccess('#url.loadid#','#session.empid#');" value="Unlock" style="width:100px !important;float:right;">
                        <cfelse>
                            <input name="save" type="submit" class="green-btn"   onClick="alert('Any changes you make will not be updated to the 123Load Board because you do not have credentials setup on your User Profile.');javascript:return saveButStayOnPage('#url.loadid#');" onfocus="checkUnload();" value="Save">
                        </cfif>
                    <cfelse>
                        <cfif structkeyexists(session,"rightslist") and len(trim(url.loadid)) gt 0 and variables.loaddisabledStatus and ListContains(session.rightsList,'UnlockLoad',',')>
                            <input id="Unlock" name="unlock" type="button" class="green-btnUnlock" onClick="removeEditAccess('#url.loadid#','#session.empid#');" value="Unlock" style="width:100px !important;float:right;">
                        <cfelse>
                            <input name="save" type="submit" class="green-btn"  onClick="return saveButStayOnPage('#url.loadid#');" onFocus="checkUnload();" value="Save" disabled="yes" tabindex="#evaluate(currentTab+2)#"/>
                        </cfif>
                    </cfif>
                    </div>
                    <div class="clear"></div>
                <!--- END: Prevent already transcore synced load update from Agent has no Transcore Login setup in their profile Date:20 Sep 2013  --->
                <!--- </p> --->
                <cfelse>
                    <!--- <p> --->
            <cfif structkeyexists(session,"rightslist") and len(trim(url.loadid)) gt 0 and variables.loaddisabledStatus and ListContains(session.rightsList,'UnlockLoad',',')>
                <input id="Unlock" name="unlock" type="button" class="green-btnUnlock" onClick="removeEditAccess('#url.loadid#','#session.empid#');" value="Unlock" style="width:100px !important;float:right;">
            <cfelse>
                <cfif local.lockloadStatsFlag>
                    <input name="submit" type="button" class="green-btn" value="Save" />
                <cfelse>
                    <input name="save" type="submit" class="green-btn"  onClick="return saveButStayOnPage('#url.loadid#');" onFocus="checkUnload();" value="Save" disabled="yes" tabindex="#evaluate(currentTab+2)#"/>
                </cfif>
            </cfif>
                </cfif>
            </div> 
            <div class="clear"></div>
        </div>
        <div class="clear"></div>
        <cfif totStops eq  1>
            <cfif  structkeyexists(url,"loadid") and len(url.loadid) gt 1>
                <cfif request.qLoads.RecordCount GT 0 AND IsDefined("request.qLoads.LastModifiedDate") AND IsDefined("request.qLoads.ModifiedBy")>
                    <p id="footer" style="padding-left:10px;font-family:Verdana, Geneva, sans-serif; font-style:italic bold; text-transform:uppercase;">Last Updated:
                        <cfif isDefined("request.qLoads")>
                            &nbsp;&nbsp;&nbsp;#request.qLoads.LastModifiedDate#&nbsp;&nbsp;&nbsp;#request.qLoads.ModifiedBy#
                        </cfif>
                    </p>
                </cfif>
            </cfif>
        </cfif>
        <div class="white-bot"></div>
    </div>

  <!---End stop block 1--->
  <div class="gap"></div>
  <!--- stop block 2--->
  <cfset StopNoIs = 1>
  <input type="hidden" name="CurrStopNo" id="CurrStopNo" value="0">
  <cfloop from="2" to="#totStops#" index="stopNo">

    <cfif NoOfStopsToShow gte StopNoIs>
    <div class="white-con-area">
        <div id="stop#stopNo#" <cfif NoOfStopsToShow gte StopNoIs>style="display:block"</cfif>>
            <div id="tabs#stopNo#" class="tabsload">
                <ul style="height:27px;">
                    <li><a href="##tabs-1" style="font-weight: bolder;font-size: 12px;padding-bottom: 4px;">Stop #stopNo#</a></li>
                    <li><a href="index.cfm?event=loadIntermodal&stopno=#stopNo#&loadID=#loadID#&#Session.URLToken#">Intermodal</a></li>
                    <div style="float: left;width: 23%; margin-left: 27px;" id="StopNo#stopNo#">
                        <div class="form-con" style="width:203%">
                            <ul class="load-link" id="ulStopNo1" style="line-height:26px;">
                                <cfloop from="1" to="#totStops#" index='stpNoid'>
                                    <cfif stpNoid is 1>
                                        <li><a href="##StopNo#stpNoid#">###stpNoid#</a></li>
                                    <cfelse>
                                        <li><a href="##StopNo#stpNoid#">###stpNoid#</a></li>
                                    </cfif>
                                </cfloop>
                            </ul>
                            <div class="clear"></div>
                        </div>
                    </div>
                    <div style="float: left; width: 56%; height:6px;">
                        <h2 id="loadNumber" style="color:white;font-weight:bold;margin-top: -11px;">Load###Ucase(loadnumber)#</h2>
                    </div>
                </ul>
                <div id="tabs-1">
                    <cfset stopNumber=stopNo>
                    <cfif request.qLoads.CarrierCount EQ 1>
                        <cfset collapseCarrierBlock = 1>
                    <cfelse>
                        <cfset collapseCarrierBlock = 0>
                    </cfif>
                    <cfinclude template="nextStop.cfm">
                </div>
            </div>

            <div class="form-heading-loop" style="background-color: #request.qSystemSetupOptions1.BackgroundColorForContent# !important;position: relative;top: -15px;">
                <div class="rt-button3">
                </div>
                <div class="clear"></div>
                <cfif ListContains(session.rightsList,'runReports',',')>
                    <cfset carrierReportOnClick = "window.open('../reports/loadReportForCarrierConfirmation.cfm?loadid=#editid#&#session.URLToken#')">
                    <cfset customerReportOnClick = "window.open('customer-confirmation.cfm?AllNeededVlue=AllInfo&#session.URLToken#')">
                <cfelse>
                    <cfset carrierReportOnClick = "">
                    <cfset customerReportOnClick = "">
                </cfif>
                <cfif isdefined("url.loadid") and len(trim(url.loadid)) gt 1>

                    <div class="right bottom-btns" style="<cfif len(trim(url.loadid)) gt 0 and url.loadid NEQ 0>height:30px;</cfif>margin-top: -30px;width: 430px;">
                        <div>
                            <input name="addstopButton" type="button" class="green-btn" onclick="AddStop('stop#(stopNumber+1)#',#(stopNumber+1)#);setStopValue();" value="Add Stop" style="color: ##599700;"/>
                            <input name="" type="button" class="red-btn" onclick="deleteStop('stop#stopNumber#',#(stopNumber-1)#,#showItems#,'#nextLoadStopId#','#application.DSN#','#loadIDN#');setStopValue();" value="Delete Stop" style="color:##800000;"  /> 
                        </div>
                        <div>
                            <cfif request.qcurAgentdetails.integratewithTran360 EQ false AND posttoTranscore EQ 1>
                                <cfif structkeyexists(session,"rightslist") and len(trim(url.loadid)) gt 0 and variables.loaddisabledStatus and ListContains(session.rightsList,'UnlockLoad',',')>
                                    <input id="Unlock" name="unlock" type="button" class="green-btnUnlock" onClick="removeEditAccess('#url.loadid#','#session.empid#');" value="Unlock" style="width:100px !important;float:right;">
                                <cfelse>
                                    <input name="submit" type="submit" class="green-btn"  onClick="alert('Any changes you make will not be Added to the DAT Board because you do not have credentials setup on your User Profile.');return saveButStayOnPage('#url.loadid#');setStopValue();" onFocus="checkUnload();" value="Save"  disabled/>
                                </cfif>
                            <cfelseif  request.qcurAgentdetails.loadBoard123 EQ false AND PostTo123LoadBoard EQ 1>
                                <cfif not (structkeyexists(session,"rightslist") and len(trim(url.loadid)) gt 0 and variables.loaddisabledStatus and ListContains(session.rightsList,'UnlockLoad',','))>
                                    <input id="Unlock" name="unlock" type="button" class="green-btnUnlock" onClick="removeEditAccess('#url.loadid#','#session.empid#');" value="Unlock" style="width:100px !important;float:right;">
                                <cfelse>
                                    <cfif ListContains(session.editableStatuses,statusText,',')>
                                        <input name="submit" type="submit" class="green-btn"  onClick="alert('Any changes you make will not be Added to the 123Load Board because you do not have credentials setup on your User Profile.');return saveButStayOnPage('#url.loadid#');setStopValue();" onFocus="checkUnload();" value="Save"  disabled />
                                    </cfif>
                                </cfif>
                            <cfelse>
                                <cfif structkeyexists(session,"rightslist") and len(trim(url.loadid)) gt 0 and variables.loaddisabledStatus and ListContains(session.rightsList,'UnlockLoad',',')>
                                    <input id="Unlock" name="unlock" type="button" class="green-btnUnlock" onClick="removeEditAccess('#url.loadid#','#session.empid#');" value="Unlock" style="width:100px !important;float:right;">
                                <cfelse>
                                    <input name="submit" type="submit" class="green-btn"  onClick="return saveButStayOnPage('#url.loadid#');setStopValue();" onFocus="checkUnload();" value="Save"  disabled  tabindex="#evaluate(currentTab+2)#"/>
                                </cfif>
                            </cfif>
                        </div>
                        <div class="clear"></div>
                    </div>
                    <div class="clear"></div>
                    
                </cfif>
                <input type="hidden" name="shipperFlag#stopNumber#" id="shipperFlag#stopNumber#" value="0">
                <input type="hidden" name="consigneeFlag#stopNumber#" id="consigneeFlag#stopNumber#" value="0">
                <br class="clear"/>
                <div class="clear"></div>
                <cfif #stopNumber# eq #totStops#>
                    <cfif  loadIDN neq "">
                        <cfif request.qLoads.RecordCount GT 0 AND IsDefined("request.qLoads.LastModifiedDate") AND IsDefined("request.qLoads.ModifiedBy")>
                            <p id="footer" style="padding-left:10px;font-family:Verdana, Geneva, sans-serif; font-style:italic bold; text-transform:uppercase;font-family:Verdana, Geneva, sans-serif; font-style:italic; text-transform:uppercase;width:80%;"> Last Updated:&nbsp;&nbsp;&nbsp; #request.qLoads.LastModifiedDate#&nbsp;&nbsp;&nbsp;#request.qLoads.ModifiedBy# </p>
                        </cfif>
                    </cfif>
                </cfif>
            </div>
            <div class="white-bottom">&nbsp;</div>
        </div>
    </div>
    <div class="gap"></div>
    </cfif>
    <cfset StopNoIs = StopNoIs + 1>
  </cfloop>
  <!--- End stop block 2--->
<cfset rownum=0>

<cfloop from ="1" to="1" index="i">
    <tr <cfif rowNum mod 2 eq 0>bgcolor="##FFFFFF"<cfelse>  bgcolor="##f7f7f7"</cfif> class="commodities_1" id="commodities_#i#" style="display:none;">
        <td height="20" class="lft-bg">&nbsp;</td>
        <td class="lft-bg2" valign="middle" align="center">
            <input name="isFee_#rowNum#" id="isFee_#rowNum#" class="isFee check" type="checkbox" tabindex="#evaluate(currentTab+1)#"/>
        </td>
        <td class="normaltdC" valign="middle" align="left">
            <input name="qty_#rowNum#" id="qty_#rowNum#" onChange="CalculateTotal('#Application.dsn#')" class="qty q-textbox" type="text" value="1" tabindex="#evaluate(currentTab+1)#"/>
        </td>
        <td class="normaltdC" valign="middle" align="left">
            <select name="unit_#rowNum#" id="unit_#rowNum#" class="t-select unit typeSelect1" onChange="changeQuantityWithtype(this,'');checkForFee(this.value,'#rowNum#','','#application.dsn#');CalculateTotal('#Application.dsn#'); autoloaddescription(this, '', '#rowNum#', '#application.dsn#');" tabindex="#evaluate(currentTab+1)#">
                <option value=""></option>
                <cfloop query="request.qUnits">
                    <option value="#request.qUnits.unitID#">#request.qUnits.unitName#<cfif trim(request.qUnits.unitCode) neq ''>(#request.qUnits.unitCode#)</cfif></option>
                </cfloop>
            </select>
        </td>
        <td class="normaltdC" valign="middle" align="left">
            <input name="description_#rowNum#" id="description_#rowNum#" class="t-textbox" type="text" tabindex="#evaluate(currentTab+1)#" style="width:#descriptionWidth#px;"/>
        </td>
        <td class="normaltdC" valign="middle" align="left">
            <input name="dimensions_#rowNum#" id="dimensions_#rowNum#" class="t-textbox" type="text" tabindex="#evaluate(currentTab+1)#" maxlength="150" style="width:58px;"/>
        </td>
        <cfif request.qSystemSetupOptions.commodityWeight>
            <td class="normaltdC" valign="middle" align="left">
                <input name="weight_#rowNum#" id="weight_#rowNum#" class="wt-textbox" type="text" tabindex="#evaluate(currentTab+1)#"/>
            </td>
        </cfif>
        <td class="normaltdC" valign="middle" align="left">
            <select name="class_#rowNum#" class="t-select" tabindex="#evaluate(currentTab+1)#" style="width:60px;">
                <option value=""></option>
                <cfloop query="request.qClasses">
                    <option value="#request.qClasses.classId#">#request.qClasses.className#</option>
                </cfloop>
            </select>
        </td>
        <cfset variables.carrierPercentage = 0>
        <cfif IsDefined("request.qItems.CarrRateOfCustTotal") and IsNumeric(request.qItems.CarrRateOfCustTotal)>
            <cfset variables.carrierPercentage = request.qItems.CarrRateOfCustTotal>
        </cfif>

        <cfif NOT ListContains(session.rightsList,'HideCustomerPricing',',')>
            <td class="normaltdC" valign="middle" align="left"><input name="CustomerRate_#rowNum#" id="CustomerRate_#rowNum#" tabindex="#evaluate(currentTab+1)#" class="q-textbox CustomerRate" onChange="CalculateTotal('#Application.dsn#')"  type="text" <cfif request.qSystemSetupOptions.ForeignCurrencyEnabled>value="#(0)#"<cfelse>value="#DollarFormat(0)#"</cfif> /></td>
        <cfelse>
            <input name="CustomerRate_#rowNum#" id="CustomerRate_#rowNum#" type="hidden" <cfif request.qSystemSetupOptions.ForeignCurrencyEnabled>value="#(0)#"<cfelse>value="#DollarFormat(0)#"</cfif> />
        </cfif>
        <td class="normaltd2C" valign="middle" align="left">
            <input name="CarrierRate_#rowNum#" id="CarrierRate_#rowNum#" tabindex="#evaluate(currentTab+1)#"  class="q-textbox CarrierRate"  onChange="CalculateTotal('#Application.dsn#')" type="text" <cfif request.qSystemSetupOptions.ForeignCurrencyEnabled>value="#(0)#"<cfelse>value="#DollarFormat(0)#"</cfif>/>
        </td>

        <cfif NOT ListContains(session.rightsList,'HideCustomerPricing',',')>
            <td class="normaltd2C" valign="middle" align="left">
                <input name="CarrierPer_#rowNum#" id="CarrierPer_#rowNum#" class="q-textbox CarrierPer" value="0%" onChange="ConfirmMessage('#rowNum#',0)"  type="text" tabindex="#evaluate(currentTab+1)#" />
            </td>
        <cfelse>
            <input name="CarrierPer_#rowNum#" id="CarrierPer_#rowNum#" value="0%" type="hidden"/>
        </cfif>


        <cfif request.qSystemSetupOptions.UseDirectCost>
            <td class="normaltdC" valign="middle" align="left">
                <input name="directCost_#rowNum#" id="directCost_#rowNum#" class="q-textbox directCost" type="text" value="$0.00" onChange="CalculateTotal('#Application.dsn#');formatDollarNegative(this.value, this.id);" tabindex="#evaluate(currentTab+1)#"/>
            </td>
        <cfelse>
            <input name="directCost_#rowNum#" id="directCost_#rowNum#" type="hidden" value="$0.00" />
        </cfif>

        <cfif NOT ListContains(session.rightsList,'HideCustomerPricing',',')>
            <td class="normaltdC" valign="middle" align="left">
                <input name="custCharges_#rowNum#" id="custCharges_#rowNum#" class="q-textbox custCharges" onChange="CalculateTotal('#Application.dsn#');" type="text" value="0.00" style="background-color: ##e3e3e3;" readonly />
            </td>
            <input name="custCharges_#rowNum#" id="custCharges_#rowNum#" type="hidden" value="0.00"/>
        </cfif>


        <td class="normaltd2C" valign="middle" align="left">
            <input name="carrCharges_#rowNum#" id="carrCharges_#rowNum#" class="q-textbox carrCharges" onChange="CalculateTotal('#Application.dsn#');" type="text" value="0.00" readonly style="background-color: ##e3e3e3;" />
        </td>

        <cfif request.qSystemSetupOptions.UseDirectCost>
            <td class="normaltdC" valign="middle" align="left">
                <input name="directCostTotal_#rowNum#" id="directCostTotal_#rowNum#" class="q-textbox directCostTotal" type="text" value="$0.00"  readonly="" style="background-color: ##e3e3e3;width: 60px;"/>
            </td>
        <cfelse>
            <input name="directCostTotal_#rowNum#" id="directCostTotal_#rowNum#" type="hidden" value="$0.00"/>
        </cfif>

        <td class="normaltdC" valign="middle" align="left">
            <img name="delComm_#rowNum#" id="delComm_#rowNum#" src="images/delete-icon-red.gif" style="width:10px;margin-left: 5px;cursor: pointer;float: left" onclick="delRowCommodities(this)" >
            <img name="sortComm_#rowNum#" id="sortComm_#rowNum#" src="images/sort.png" style="width:12px;margin-left: 5px;cursor: pointer">
            <input type="hidden" name="commStopId_#rowNum#" id="commStopId_#rowNum#" value="0">
            <input type="hidden" name="commSrNo_#rowNum#" id="commSrNo_#rowNum#" value="0">
        </td>
        <td class="normal-td3C normal-td3">&nbsp;</td>
    </tr>
    <cfset rownum++>
</cfloop>

<cfloop from="2" to="100" index="stopNumber">
    <cfloop from ="1" to="1" index="rowNum">
        <tr <cfif rowNum mod 2 eq 0>bgcolor="##FFFFFF"<cfelse>  bgcolor="##f7f7f7"</cfif> class="commodities_#stopNumber#" id="commodities_#stopNumber#" style="display:none;">
            <td height="20" class="lft-bg">&nbsp;</td>
            <td class="lft-bg2" valign="middle" align="center">
                <input name="isFee#stopNumber#_#rowNum#" id="isFee#stopNumber#_#rowNum#" class="isFee check" type="checkbox" tabindex="#evaluate(currentTab+1)#"/>
            </td>
            <td class="normaltdC" valign="middle" align="left">
                <input name="qty#stopNumber#_#rowNum#" id="qty#stopNumber#_#rowNum#" onChange="CalculateTotal('#Application.dsn#')" value="1" class="qty q-textbox" type="text"  tabindex="#evaluate(currentTab+1)#"/>
            </td>
            <td class="normaltdC" valign="middle" align="left">
                <select name="unit#stopNumber#_#rowNum#" id="unit#stopNumber#_#rowNum#" class="unit t-select typeSelect#stopNumber#" onchange="changeQuantityWithtype(this,'#stopNumber#');checkForFee(this.value,'#rowNum#','#stopNumber#','#application.dsn#'); autoloaddescription(this, '#stopNumber#', '#rowNum#', '#application.dsn#');" tabindex="#evaluate(currentTab+1)#">
                    <option value=""></option>
                    <cfloop query="request.qUnits">
                        <option value="#request.qUnits.unitID#">#request.qUnits.unitName#<cfif trim(request.qUnits.unitCode) neq ''>(#request.qUnits.unitCode#)</cfif></option>
                    </cfloop>
                </select>
            </td>
            <td class="normaltdC" valign="middle" align="left">
                <input name="description#stopNumber#_#rowNum#" id="description#stopNumber#_#rowNum#" class="t-textbox" type="text" tabindex="#evaluate(currentTab+1)#" style="width:#descriptionwidth#px;"/>
            </td>
            <td class="normaltdC" valign="middle" align="left">
                <input name="dimensions#stopNumber#_#rowNum#" id="dimensions#stopNumber#_#rowNum#" class="t-textbox" type="text" tabindex="#evaluate(currentTab+1)#" style="width:58px;"/>
            </td>
            <cfif request.qSystemSetupOptions.commodityWeight>
                <td class="normaltdC" valign="middle" align="left">
                    <input name="weight#stopNumber#_#rowNum#" class="wt-textbox" type="text" tabindex="#evaluate(currentTab+1)#"/>
                </td>
            </cfif>
            <td class="normaltdC" valign="middle" align="left">
                <select name="class#stopNumber#_#rowNum#" id="class#stopNumber#_#rowNum#" class="t-select" tabindex="#evaluate(currentTab+1)#" style="width:60px;">
                    <option value=""></option>
                    <cfloop query="request.qClasses">
                        <option value="#request.qClasses.classId#">#request.qClasses.className#</option>
                    </cfloop>
                </select>
            </td>

            <cfset variables.carrierPercentage = 0>
            <cfif IsDefined("request.qItems.CarrRateOfCustTotal") and IsNumeric(request.qItems.CarrRateOfCustTotal)>
                <cfset variables.carrierPercentage = request.qItems.CarrRateOfCustTotal>
            </cfif>

            <cfif NOT ListContains(session.rightsList,'HideCustomerPricing',',')>
                <td class="normaltdC" valign="middle" align="left">
                    <input name="CustomerRate#stopNumber#_#rowNum#" id="CustomerRate#stopNumber#_#rowNum#" tabindex="#evaluate(currentTab+1)#" onChange="CalculateTotal('#Application.dsn#');formatDollarNegative(this.value, this.id);" class="CustomerRate q-textbox"  type="text" <cfif request.qSystemSetupOptions.ForeignCurrencyEnabled>value="0.00"<cfelse>value="$0.00"</cfif> />
              </td>
            <cfelse>
                <input name="CustomerRate#stopNumber#_#rowNum#" id="CustomerRate#stopNumber#_#rowNum#"  type="hidden" <cfif request.qSystemSetupOptions.ForeignCurrencyEnabled>value="0.00"<cfelse>value="$0.00"</cfif> />
            </cfif>
            <td class="normaltd2C" valign="middle" align="left">
                <input name="CarrierRate#stopNumber#_#rowNum#" id="CarrierRate#stopNumber#_#rowNum#" tabindex="#evaluate(currentTab+1)#"  onChange="CalculateTotal('#Application.dsn#');formatDollarNegative(this.value, this.id);" class="CarrierRate q-textbox"  type="text" <cfif request.qSystemSetupOptions.ForeignCurrencyEnabled>value="0.00"<cfelse>value="$0.00"</cfif>/>
            </td>
 
            <cfif NOT ListContains(session.rightsList,'HideCustomerPricing',',')>
                <td class="normaltd2C" valign="middle" align="left">
                    <input name="CarrierPer#stopNumber#_#rowNum#" id="CarrierPer#stopNumber#_#rowNum#" class="q-textbox CarrierPer" value="0.00%" onChange="ConfirmMessage('#rowNum##stopNumber#',0)"  type="text" tabindex="#evaluate(currentTab+1)#" />
                </td>
            <cfelse>
                <input name="CarrierPer#stopNumber#_#rowNum#" id="CarrierPer#stopNumber#_#rowNum#" value="0.00%"  type="hidden"  />
            </cfif>

            <cfif request.qSystemSetupOptions.UseDirectCost>
                <td class="normaltdC" valign="middle" align="left">
                    <input name="directCost#stopNumber#_#rowNum#" id="directCost#stopNumber#_#rowNum#" class="q-textbox directCost" type="text" value="$0.00" onChange="CalculateTotal('#Application.dsn#');" tabindex="#evaluate(currentTab+1)#"/>
                </td>
            <cfelse>
                <input name="directCost#stopNumber#_#rowNum#" id="directCost#stopNumber#_#rowNum#" type="hidden" value="$0.00"/>
            </cfif>

            <cfif NOT ListContains(session.rightsList,'HideCustomerPricing',',')>
                <td class="normaltdC" valign="middle" align="left">
                    <input name="custCharges#stopNumber#_#rowNum#" id="custCharges#stopNumber#_#rowNum#" onchange="CalculateTotal('#Application.dsn#');" class="custCharges q-textbox" type="text" value="$0.00" readonly style="background-color: ##e3e3e3;"/>
                </td>
            <cfelse>
                <input name="custCharges#stopNumber#_#rowNum#" id="custCharges#stopNumber#_#rowNum#" type="hidden" value="$0.00" />
            </cfif>

            <td class="normaltd2C" valign="middle" align="left">
                <input name="carrCharges#stopNumber#_#rowNum#" id="carrCharges#stopNumber#_#rowNum#" onchange="CalculateTotal('#Application.dsn#');" class="carrCharges q-textbox" type="text"  value="$0.00"  style="background-color: ##e3e3e3;" readonly/>
            </td>

            <cfif request.qSystemSetupOptions.UseDirectCost>
                <td class="normaltdC" valign="middle" align="left">
                    <input name="directCostTotal#stopNumber#_#rowNum#" id="directCostTotal#stopNumber#_#rowNum#" class="q-textbox directCostTotal" type="text" value="$0.00" readonly style="background-color: ##e3e3e3;width: 60px;"/>
                </td>
            <cfelse>
                <input name="directCostTotal#stopNumber#_#rowNum#" id="directCostTotal#stopNumber#_#rowNum#"  type="hidden" value="$0.00"/>
            </cfif>

            <td class="normaltdC" valign="middle" align="left">
                <img name="delComm#stopNumber#_#rowNum#" id="delComm#stopNumber#_#rowNum#" src="images/delete-icon-red.gif" style="width:10px;margin-left: 5px;cursor: pointer;float:left" onclick="delRowCommodities(this)" >
                <img name="sortComm#stopNumber#_#rowNum#" id="sortComm#stopNumber#_#rowNum#" src="images/sort.png" style="width:12px;margin-left: 5px;cursor: pointer">
                <input type="hidden" name="commStopId#stopNumber#_#rowNum#" id="commStopId#stopNumber#_#rowNum#" value="0">
                <input type="hidden" name="commSrNo#stopNumber#_#rowNum#" id="commSrNo#stopNumber#_#rowNum#" value="0">
            </td>
            <td class="normal-td3C normal-td3">&nbsp;</td>
        </tr>
    </cfloop>
</cfloop>
</form>
<style>
    ##copyNoOfLoads{
        width: 60px;
        height: 18px;
        background: ##FFFFFF;
        border: 1px solid ##b3b3b3;
        padding: 2px 2px 0 2px;
        margin: 0 0 8px 0;
        font-size: 11px;
    }

    ##copyOptionPopup{
        width: 450px;
        position: absolute;
        top: 40%;
        left: 30%;
        z-index: 9999;
        display: none;
        box-shadow: 0 2px 6px rgba(0,0,0,0.2);
    }
    .copyOptionPopupHeader{
        background-color: ##82bbef;
        padding-left: 5px;
    }
    .copyOptionPopupContent{
        background-color:#request.qSystemSetupOptions1.BackgroundColorForContent# !important;
        padding-left: 15px;
        font-size: 14px;
        padding-right:10px;
        padding-bottom:10px;
        padding-top: 10px;
    }

    .copyOptionPopupContent label{
        vertical-align:middle;
    }

    .copyOptionPopupContent .popupChk{
        height: 22px;
        width: 18px;
        vertical-align:middle;
    }
    .copyOptionPopupContent .smallChk{
        vertical-align:middle;
    }

    .copyLoadSysOpt{
        border:solid 1px;
        width: 260px;
        padding:5px;
    }
</style>  
<style>
    .switch {
        position: relative;
        display: block;
        vertical-align: top;
        width: 100px;
        height: 30px;
        padding: 3px;
        margin: 0 10px 10px 0;
        background: linear-gradient(to bottom, ##eeeeee, ##FFFFFF 25px);
        background-image: -webkit-linear-gradient(top, ##eeeeee, ##FFFFFF 25px);
        border-radius: 18px;
        box-shadow: inset 0 -1px white, inset 0 1px 1px rgba(0, 0, 0, 0.05);
        cursor: pointer;
        box-sizing:content-box;
    }
    .switch-input {
        position: absolute;
        top: 0;
        left: 0;
        opacity: 0;
        box-sizing:content-box;
    }
    .switch-label {
        position: relative;
        display: block;
        height: inherit;
        font-size: 10px;
        text-transform: uppercase;
        background: ##eceeef;
        border-radius: inherit;
        box-shadow: inset 0 1px 2px rgba(0, 0, 0, 0.12), inset 0 0 2px rgba(0, 0, 0, 0.15);
        box-sizing:content-box;
    }
    .switch-label:before, .switch-label:after {
        position: absolute;
        top: 50%;
        margin-top: -.5em;
        line-height: 1;
        -webkit-transition: inherit;
        -moz-transition: inherit;
        -o-transition: inherit;
        transition: inherit;
        box-sizing:content-box;
    }
    .switch-label:before {
        content: attr(data-off);
        right: 11px;
        color: ##aaaaaa;
        text-shadow: 0 1px rgba(255, 255, 255, 0.5);
    }
    .switch-label:after {
        content: attr(data-on);
        left: 11px;
        color: ##FFFFFF;
        text-shadow: 0 1px rgba(0, 0, 0, 0.2);
        opacity: 0;
    }
    .switch-input:checked ~ .switch-label {
        background: ##50ba77;
        box-shadow: inset 0 1px 2px rgba(0, 0, 0, 0.15), inset 0 0 3px rgba(0, 0, 0, 0.2);
    }
    .switch-input:checked ~ .switch-label:before {
        opacity: 0;
    }
    .switch-input:checked ~ .switch-label:after {
        opacity: 1;
    }
    .switch-handle {
        position: absolute;
        top: 1px;
        left: 4px;
        width: 20px;
        height: 20px;
        background: linear-gradient(to bottom, ##FFFFFF 40%, ##f0f0f0);
        background-image: -webkit-linear-gradient(top, ##FFFFFF 40%, ##f0f0f0);
        border-radius: 100%;
        box-shadow: 1px 1px 5px rgba(0, 0, 0, 0.2);
    }
    .switch-handle:before {
        content: "";
        position: absolute;
        top: 50%;
        left: 50%;
        margin: -6px 0 0 -6px;
        width: 12px;
        height: 12px;
        background: linear-gradient(to bottom, ##eeeeee, ##FFFFFF);
        background-image: -webkit-linear-gradient(top, ##eeeeee, ##FFFFFF);
        border-radius: 6px;
        box-shadow: inset 0 1px rgba(0, 0, 0, 0.02);
    }
    .switch-input:checked ~ .switch-handle {
        left: 37px;
        box-shadow: -1px 1px 5px rgba(0, 0, 0, 0.2);
    }
     
    /* Transition
    ========================== */
    .switch-label, .switch-handle {
        transition: All 0.3s ease;
        -webkit-transition: All 0.3s ease;
        -moz-transition: All 0.3s ease;
        -o-transition: All 0.3s ease;
    }

    /* Switch Left Right
    ==========================*/
    .switch-left-right .switch-label {
        overflow: hidden;
    }
    .switch-left-right .switch-label:before, .switch-left-right .switch-label:after {
        width: 20px;
        height: 20px;
        top: 4px;
        left: 0;
        right: 0;
        bottom: 0;
        padding: 11px 0 0 0;
        text-indent: -12px;
        border-radius: 20px;
        box-shadow: inset 0 1px 4px rgba(0, 0, 0, 0.2), inset 0 0 3px rgba(0, 0, 0, 0.1);
    }
    .switch-left-right .switch-label:before {
        background: ##eceeef;
        text-align: left;
        padding-left: 80px;
    }
    .switch-left-right .switch-label:after {
        text-align: left;
        text-indent: 9px;
        background: ##FF7F50;
        left: -100px;
        opacity: 1;
        width: 100%;
    }
    .switch-left-right .switch-input:checked ~ .switch-label:before {
        opacity: 1;
        left: 100px;
    }
    .switch-left-right .switch-input:checked ~ .switch-label:after {
        left: 0;
    }
    .switch-left-right .switch-input:checked ~ .switch-label {
        background: inherit;
    }
    
</style>
<div id="copyOptionPopup">
    <div class="copyOptionPopupHeader"><h1 style="color:white;font-weight:bold;">Copy Load</h1></div>
    <div class="copyOptionPopupContent">
        <fieldset>
            <input type="hidden" value="" id="copyOptionloadid">
            <input type="hidden" value="" id="copyOptiontoken">
            <input type="hidden" value="" id="copyOptionmaxValue">
            <cfif request.qSystemSetupOptions.LowVolumePlan EQ 1>
                <input type="hidden" value="" id="copyNoOfLoads" value="1">
            <cfelse>
                <label style="font-size: 14px;font-weight: bold;">How many copies would you like? (Maximum of #request.qSystemSetupOptions1.CopyLoadLimit#)</label>
                <input type="text" id="copyNoOfLoads" value="1" onkeyup="if (/\D/g.test(this.value)) this.value = this.value.replace(/\D/g,'')">
                <div class="clear"></div>
            </cfif>
            <cfif request.qSystemSetupOptions1.ShowLoadCopyOptions and structKeyExists(request, "qloads") and request.qloads.statustext NEQ '. TEMPLATE'>
                <div class="copyLoadSysOpt">
                    <div style="border-bottom: solid 1px;">
                        <b style="font-size: 12px;">Load Copy Options</b>
                        (<label style="font-size: 11px;">Do not show this again</label>
                        <input type="checkbox" class="smallChk" id="cpyShowLoadCopyOptions">)
                    </div>
                    <label style="font-size: 12px;">Copy Sales Rep/Dispatcher?</label>
                    <input type="checkbox" id="cpyIncSalesDisp" class="popupChk" <cfif request.qSystemSetupOptions1.CopyLoadIncludeAgentAndDispatcher EQ 1>checked="checked"</cfif> style="margin-left: 2px;">
                    <div class="clear"></div>
                    <label style="font-size: 12px;">Copy Delivery/Pickup Dates?</label>
                    <input type="checkbox" id="cpyIncDates" class="popupChk" <cfif request.qSystemSetupOptions1.CopyLoadDeliveryPickupDates EQ 1>checked="checked"</cfif>>
                    <div class="clear"></div>
                    <label style="font-size: 12px;margin-left: 81px;">Copy Carrier?</label>
                    <input type="checkbox" id="cpyIncCarrier" class="popupChk" <cfif request.qSystemSetupOptions1.CopyLoadCarrier EQ 1>checked="checked"</cfif>>
                </div>
            </cfif>
            <input type="button" value="OK" style="margin-left:305px;width: 40px !important" onclick="CopyLoad2()">
            <input type="button" value="Cancel" style="width: 65px !important" onclick="closeCopyPopup()">
        </fieldset>
    </div>
</div> 
                                                                                
<div id="responseCopyLoad"></div>
  <script  type="text/javascript">
    var percentageProfit1 = 0;
    $(document).ready(function(){
        var html = "";
    <cfif structKeyExists(request,"qLoadNumbers")>
        $("##responseCopyLoad").html("<h3 style='color:##31a047;'>Loads Numbers #request.qLoadNumbers#</h3>");          
        $("##responseCopyLoad").append("<ul><cfloop list='#request.qLoadNumbers#' index='ele'>  <li><h3 style='color:##31a047;'><a href=''> #ele#</a></h3></li></cfloop>    </ul>");    
        $("##responseCopyLoad").dialog({
            resizable: false,
            modal: true,
            title: "Load Copied Successfully",
            height: 450,
            width: 500
        });
    </cfif>

        percentageProfit1 = document.getElementById('percentageProfit').innerHTML;
        percentageProfit1 = $.trim(percentageProfit1.replace("% Profit", ""));
         
    });
    
    
     //mailUrlToken will be used for passing urlToken
    var mailUrlToken = "#session.URLToken#";
    <cfif structkeyexists(url,"loadid") and len(trim(url.loadid)) gt 1>
    var mailLoadId = "#url.loadid#";
    </cfif>
    document.getElementById("milse").onchange();
    CalculateTotal('#Application.dsn#');

    <cfif session.currentUserType neq "LmAdmin" AND (ARExported eq "1" AND APExported eq "1")>
        EnableDisableForm(forms.load, true);
    <cfelseif session.currentUserType eq "LmAdmin">
        <!--- Enable A/R and A/P Export options for Admin--->
        document.getElementById('ARExported').disabled = false;
        document.getElementById('APExported').disabled = false;
    </cfif>

    function CopyLoad1(loadid,token,maxValue){
        <cfif request.qSystemOptions.LowVolumePlan EQ 1>
            $.ajax({
                type    : 'POST',
                url     : "ajax.cfm?event=ajxCheckLoadLmit",
                data    : {},
                beforeSend:function() {
                    $('.overlay').show();
                },
                success :function(LoadLimitReached){
                    if(LoadLimitReached==1){
                        $('.overlay').hide();
                        alert("Your plan has a limit of 30 loads per month. If you'd like to upgrade your account please login to your billing account and change your plan.");
                    }
                    else{
                        $('.overlay').hide();
                        $("##copyNoOfLoads").removeAttr('disabled');
                        $("##copyNoOfLoads").removeAttr('readonly');

                        $("##copyNoOfLoads").val(1);
                        $("##cpyShowLoadCopyOptions").removeAttr('disabled');
                        $("##cpyIncSalesDisp").removeAttr('disabled');
                        $("##cpyIncDates").removeAttr('disabled');
                        $("##cpyIncCarrier").removeAttr('disabled');

                        $('##copyOptionloadid').val(loadid);
                        $('##copyOptiontoken').val(token);
                        $('##copyOptionmaxValue').val(maxValue);
                        $('.overlay').show();
                        $('##copyOptionPopup').show();
                        $('##copyNoOfLoads').focus();
                    }
                }
            })
        <cfelse>
            $("##copyNoOfLoads").removeAttr('disabled');
            $("##copyNoOfLoads").removeAttr('readonly');

            $("##copyNoOfLoads").val(1);
            $("##cpyShowLoadCopyOptions").removeAttr('disabled');
            $("##cpyIncSalesDisp").removeAttr('disabled');
            $("##cpyIncDates").removeAttr('disabled');
            $("##cpyIncCarrier").removeAttr('disabled');

            $('##copyOptionloadid').val(loadid);
            $('##copyOptiontoken').val(token);
            $('##copyOptionmaxValue').val(maxValue);
            $('.overlay').show();
            $('##copyOptionPopup').show();
            $('##copyNoOfLoads').focus();
        </cfif>
    }

    function CopyLoad2(){
        var loadid=$('##copyOptionloadid').val();
        var token=$('##copyOptiontoken').val();
        var maxValue=$('##copyOptionmaxValue').val();
        var loadNumber = $('input[name="loadManualNo"]').val();
        var NoOfCopies=$('##copyNoOfLoads').val(); 

        if(isNaN(NoOfCopies) || parseInt(NoOfCopies) < 0 ||  isNaN(parseInt(NoOfCopies))){
            alert("Please enter a valid numeric value.");
            $('##copyNoOfLoads').focus();
            return false;
        }else if (parseInt(NoOfCopies)  > parseInt(maxValue) ){
            alert("The value should be less than "+maxValue);
            $('##copyNoOfLoads').focus();
            return false;
        }
        else if (parseInt(NoOfCopies) == 0) {
            alert('Please enter value greater than 0.');
            $('##copyNoOfLoads').focus();
            return false;
        }
        else{
            NoOfCopies = parseInt(NoOfCopies);
        }       

        var url = "index.cfm?event=addload";
        url += "&NoOfCopies="+parseInt(NoOfCopies);
        url += "&loadToBeCopied="+loadid;
        url += "&loadNumber="+loadNumber;

        <cfif request.qSystemSetupOptions1.ShowLoadCopyOptions and structKeyExists(request, "qloads") and request.qloads.statustext NEQ '. TEMPLATE'>
            if($("##cpyShowLoadCopyOptions").is(':checked')){
                url += "&ShowLoadCopyOptions=0"
            }
            else{
                url += "&ShowLoadCopyOptions=1"
            }
            if($("##cpyIncSalesDisp").is(':checked')){
                url += "&CopyLoadIncludeAgentAndDispatcher=1"
            }
            else{
                url += "&CopyLoadIncludeAgentAndDispatcher=0"
            }
            if($("##cpyIncDates").is(':checked')){
                url += "&CopyLoadDeliveryPickupDates=1"
            }
            else{
                url += "&CopyLoadDeliveryPickupDates=0"
            }
            if($("##cpyIncCarrier").is(':checked')){
                url += "&CopyLoadCarrier=1"
            }
            else{
                url += "&CopyLoadCarrier=0"
            }
        </cfif>

        url += "&"+token;
        window.open(url);
        closeCopyPopup();

    }

    function closeCopyPopup(){
        $('.overlay').hide();
        $('##copyOptionPopup').hide();
    }
</script>
<script>
    var modal = document.getElementById('myModal');
    var btn = document.getElementById('edidocs');
    var span = document.getElementsByClassName("ediclose")[0];
    if(btn != null){
        btn.onclick = function() {
         modal.style.display = "block";
         }
    }
    if(span != null){
     span.onclick = function() {
      modal.style.display = "none";
    }
    }
// When the user clicks anywhere outside of the modal, close it
window.onclick = function(event) {
  if (event.target == modal) {
    modal.style.display = "none";
}
}
</script>
<script>
    var modalPay = document.getElementById('paymentModal');
    var btnPay = document.getElementById('payments');
    var spanPay = document.getElementsByClassName("paymentclose")[0];
    if(btnPay != null){
        btnPay.onclick = function() {
         modalPay.style.display = "block";
     }
    }
    if(spanPay != null){
         spanPay.onclick = function() {
          modalPay.style.display = "none";
        } 
    }
// When the user clicks anywhere outside of the modal, close it
window.onclick = function(event) {
  if (event.target == modalPay) {
    modalPay.style.display = "none";
}
}
</script>

    <script type="text/javascript">

        $(document).ready(function(){
            <cfif structKeyExists(url, 'Talert') and trim(url.Palert) neq "1">alert("#url.Talert#");</cfif>
            <cfif structKeyExists(url, 'MPalert') and trim(url.MPalert) neq "1">alert("#url.MPalert#");</cfif>

            $( ".tabsload" ).tabs({
                beforeLoad: function( event, ui ) {
                    ui.jqXHR.error(function() {
                        ui.panel.html(
                            "Couldn't load this tab. We'll try to fix this as soon as possible. " +
                            "If this wouldn't be a demo."
                        );
                    });
                }
            });

            $('##carrierReportImg,.carrierReportImg').click(function(){
                if(!$("##carrierReportLink").data('allowmail')) {
                    alert('You must setup your email address in your profile before you can email reports.');
                } else {
                    carrierMailReportOnClick(mailLoadId,mailUrlToken,percentageProfit1);
                }
             });
            <cfif structkeyexists(url,"loadid") and len(trim(url.loadid)) gt 1>
            $('##carrierDispatch,.carrierDispatch').click(function(){
                if($('##carrier_id').val() == ''){
                    alert('Please book a #variables.freightBroker# to this load before using the E-#variables.carrierDispatch# button.');
                }
                else{
                    <cfif listFind("0,1", request.qSystemSetupOptions.EDispatchOptions)>
                        <cfif structkeyexists(url,"loadid") and len(trim(url.loadid)) gt 1 AND qGetCustCons.PushDataToProject44Api AND request.qSystemSetupOptions.Project44>
                            if($('##PushDataToProject44Api').prop("checked") == false){
                                $( "##PushDataToProject44Api" ).click();
                            }
                        </cfif>

                        <cfif request.qSystemSetupOptions.EDispatchOptions EQ 0 AND request.qloads.IsEDispatched EQ 1>
                            openEDispatchpopup();
                        <cfelse>
                            newwindow=window.open('index.cfm?event=loadMail&type=EDispatch&loadid='+mailLoadId+'&'+mailUrlToken+'&carrierDispatch=#variables.carrierDispatch#','Map','height=550,width=750');
                            if (window.focus) {
                                newwindow.focus()
                            }
                        </cfif>
                    <cfelseif listFind("2,3", request.qSystemSetupOptions.EDispatchOptions)>
                        $(".loadOverlay").show();
                        $.ajax({
                            type    : 'POST',
                            url     : "../gateways/loadgateway.cfc?method=saveMacroPointOrder&User=#session.adminUserName#&CompanyID=#session.companyid#&Loadid="+mailLoadId,
                            success :function(response){
                                $(".loadOverlay").hide();
                                var resData = jQuery.parseJSON(response);
                                if(resData.SUCCESS == 0){
                                    alert('MacroPoint Error: '+resData.ERROR);
                                    if(resData.FIELD != 0){
                                       $(('[name="' + resData.FIELD + '"]')).focus(); 
                                    }
                                }
                                else{
                                    <cfif structkeyexists(url,"loadid") and len(trim(url.loadid)) gt 1 AND qGetCustCons.PushDataToProject44Api AND request.qSystemSetupOptions.Project44>
                                        if($('##PushDataToProject44Api').prop("checked") == false){
                                            $( "##PushDataToProject44Api" ).click();
                                        }
                                    </cfif>
                                    <cfif request.qSystemSetupOptions.SendEmailNoticeMacroPoint>
                                        newwindow=window.open('index.cfm?event=loadMail&type=EDispatch&loadid='+mailLoadId+'&'+mailUrlToken+'&carrierDispatch=#variables.carrierDispatch#','Map','height=550,width=750');
                                        if (window.focus) {
                                            newwindow.focus()
                                        }
                                    <cfelse>
                                        alert('MacroPoint invitation has been sent. GPS Tracking is set to start 1 hour prior to the pickup date/time.');
                                    </cfif>
                                }
                            }
                        });
                    </cfif>
                                  
                }


            });
            </cfif>
            /* Following code is use for sending the email to all active carrier*/
            $('##carrierLoadAlertEmailImg, ##carrierLoadAlertEmailButton').click(function(){
                if(!$("##carrierLoadAlertEmailButton").data('allowmail')) {
                    alert('You must setup your email address in your profile before sending email.');
                } else {
                    carrierLoadAlertEmailOnClick(mailLoadId,mailUrlToken);
                }               
            });

            $('##carrierLanesEmailButton').click(function(){
                if(!$("##carrierLanesEmailButton").data('allowmail')) {
                    alert('You must setup your email address in your profile before sending email.');
                } else {
                    var ArrCarrierID = ['00000000-0000-0000-0000-000000000000'];
                    $(".ckLanes:checked").each(function()
                    {
                        ArrCarrierID.push($(this).val());
                    })
                    carrierLaneAlertEmailOnClick(ArrCarrierID,mailLoadId,mailUrlToken);
                }               
             });

            $('##carrierReportLink,.carrierReportLink').click(function(){
                <cfif RateApprovalNeeded EQ 1>
                    var minimumMargin = document.getElementById('minimumMargin').value;
                    alert('You cannot print the Carrier Rate Confirmation because the Margin does not meet the minimum Margin percent of '+minimumMargin+'%');
                    //return false;
                </cfif>
                var dsn = '#dsn#';
                <cfif structkeyexists(url,"loadid") and len(trim(url.loadid)) gt 1 and statustext LT '3. DISPATCHED'>
                    var user = $('##Loggedin_Person').val();
                    <cfif request.qSystemSetupOptions.RateConPromptOption EQ 0>
                        carrierReportOnClick(mailLoadId,mailUrlToken,dsn);
                        var printDisplayStatus='<cfoutput>#request.qSystemSetupOptions.automaticprintreports#</cfoutput>';
                        if(printDisplayStatus == '1'){
                            $('##dispatchHiddenValue').val('Printed #variables.freightBroker# Report >');
                            $("##dispatchNotes").prepend(clock()+' - '+ $('##Loggedin_Person').val()+ ' > Printed #variables.freightBroker# Report > \n');
                            ajxUpdDispatchNote('#url.loadid#');
                        }
                        <cfif dispatchStatusActive EQ 1>
                            $.ajax({
                                type    : 'POST',
                                url     : "../gateways/loadgateway.cfc?method=updateLoadStatusDispatched",
                                data    : {LoadID : '#url.loadid#' , dsn : '#Application.dsn#' , user : user, companyid:'#session.companyid#' , clock:clock() , dispatchStatusDesc : '#dispatchStatusDesc#'},
                                success :function(){   
                                    $.ajax({
                                        type    : 'POST',
                                        url     : "ajax.cfm?event=ajxSendLoadEmailUpdate&LoadID=#url.loadid#&NewStatus=#dispatchStatusID#&#session.URLToken#",
                                        data    : {},
                                        success :function(data){
                                            location.reload();
                                        }
                                    })
                                }
                            });
                        </cfif>
                    <cfelseif request.qSystemSetupOptions.RateConPromptOption EQ 1 AND dispatchStatusActive EQ 1>
                        <cfif ListContains(session.rightsList,'modifySystemSetup',',')>
                            document.getElementById('ModalEDispatchPrompt').style.display = "block";
                        <cfelse>
                            if(confirm('Do you want to change the Load Status to "#dispatchStatusDesc#"?')){ 
                                $.ajax({
                                    type    : 'POST',
                                    url     : "../gateways/loadgateway.cfc?method=updateLoadStatusDispatched",
                                    data    : {LoadID : '#url.loadid#' , dsn : '#Application.dsn#' , user : user, companyid:'#session.companyid#', clock:clock(), dispatchStatusDesc : '#dispatchStatusDesc#'},
                                    success :function(){     
                                        $.ajax({
                                            type    : 'POST',
                                            url     : "ajax.cfm?event=ajxSendLoadEmailUpdate&LoadID=#url.loadid#&NewStatus=#dispatchStatusID#&#session.URLToken#",
                                            data    : {},
                                            success :function(data){
                                                location.reload();
                                            }
                                        })
                                    }
                                });
                                carrierReportOnClick(mailLoadId,mailUrlToken,dsn);
                                var printDisplayStatus='<cfoutput>#request.qSystemSetupOptions.automaticprintreports#</cfoutput>';
                                if(printDisplayStatus == '1'){
                                    $('##dispatchHiddenValue').val('Printed #variables.freightBroker# Report >');
                                    $("##dispatchNotes").prepend(clock()+' - '+ $('##Loggedin_Person').val()+ ' > Printed #variables.freightBroker# Report > \n');
                                    ajxUpdDispatchNote('#url.loadid#');
                                }
                            }
                            else{
                                carrierReportOnClick(mailLoadId,mailUrlToken,dsn);
                                var printDisplayStatus='<cfoutput>#request.qSystemSetupOptions.automaticprintreports#</cfoutput>';
                                if(printDisplayStatus == '1'){
                                    $('##dispatchHiddenValue').val('Printed #variables.freightBroker# Report >');
                                    $("##dispatchNotes").prepend(clock()+' - '+ $('##Loggedin_Person').val()+ ' > Printed #variables.freightBroker# Report > \n');
                                    ajxUpdDispatchNote('#url.loadid#');
                                }
                            }
                        </cfif>
                    <cfelse>
                        carrierReportOnClick(mailLoadId,mailUrlToken,dsn);
                        var printDisplayStatus='<cfoutput>#request.qSystemSetupOptions.automaticprintreports#</cfoutput>';
                        if(printDisplayStatus == '1'){
                            $('##dispatchHiddenValue').val('Printed #variables.freightBroker# Report >');
                            $("##dispatchNotes").prepend(clock()+' - '+ $('##Loggedin_Person').val()+ ' > Printed #variables.freightBroker# Report > \n');
                            ajxUpdDispatchNote('#url.loadid#');
                        }
                    </cfif>
                <cfelseif structkeyexists(url,"loadid") and len(trim(url.loadid)) gt 1 and statustext GTE '3. DISPATCHED'>
                    carrierReportOnClick(mailLoadId,mailUrlToken,dsn);
                    var printDisplayStatus='<cfoutput>#request.qSystemSetupOptions.automaticprintreports#</cfoutput>';
                    if(printDisplayStatus == '1'){
                        $('##dispatchHiddenValue').val('Printed #variables.freightBroker# Report >');
                        $("##dispatchNotes").prepend(clock()+' - '+ $('##Loggedin_Person').val()+ ' > Printed #variables.freightBroker# Report > \n');
                        ajxUpdDispatchNote('#url.loadid#');
                    }
                </cfif>
                    
            });

            $('##impWorkReportImg').click(function(){
                if(!$('##impWorkReportLink').data('allowmail')) {
                    alert('You must setup your email address in your profile before you can email reports.');
                } else {
                    CarrierMailWorkOrderImportOnClick(mailLoadId,mailUrlToken);
                    $("##dispatchNotes").prepend(clock()+' - '+ $('##Loggedin_Person').val()+ ' > Emailed Import Work Order > \n');
                }

             });

            $('##impWorkReportLink').click(function(){
                var dsn='#dsn#';
                CarrierWorkOrderImportOnClick(mailLoadId,mailUrlToken,dsn);

                var printDisplayStatus='<cfoutput>#request.qSystemSetupOptions.automaticprintreports#</cfoutput>';
                if(printDisplayStatus == '1'){
                    $('##dispatchHiddenValue').val('Printed Import Work Order >');
                    $("##dispatchNotes").prepend(clock()+' - '+ $('##Loggedin_Person').val()+ ' > Printed Import Work Order > \n');
                }
             });

            $('##expWorkReportImg').click(function(){
                if(!$('##expWorkReportLink').data('allowmail')) {
                    alert('You must setup your email address in your profile before you can email reports.');
                } else {
                    CarrierMailWorkOrderExportOnClick(mailLoadId,mailUrlToken);
                    $("##dispatchNotes").prepend(clock()+' - '+ $('##Loggedin_Person').val()+ ' > Printed Export Work Order > \n');
                }

             });

            $('##expWorkReportLink').click(function(){
                var dsn='#dsn#';
                CarrierWorkOrderExportOnClick(mailLoadId,mailUrlToken,dsn);

                var printDisplayStatus='<cfoutput>#request.qSystemSetupOptions.automaticprintreports#</cfoutput>';
                if(printDisplayStatus == '1'){
                    $('##dispatchHiddenValue').val('Printed Export Work Order >');
          $("##dispatchNotes").prepend(clock()+' - '+ $('##Loggedin_Person').val()+ ' > Printed Export Work Order > \n');

                }
             });

            $('##custInvReportImg,.custInvReportImg').click(function(){
                if(!$('##custInvReportLink').data('allowmail')) {
                    alert('You must setup your email address in your profile before you can email reports.');
                } else {
                    CustomerMailReportOnClick(mailLoadId,mailUrlToken,'#NewcustomerID#');
                }
             });

            $('.custInvReportLink').on("click",function(){
                var dsn='#dsn#';
                CustomerReportOnClick(mailLoadId,mailUrlToken,dsn);
            
                var printDisplayStatus='<cfoutput>#request.qSystemSetupOptions.automaticprintreports#</cfoutput>';
                if(printDisplayStatus == '1'){
                    $('##dispatchHiddenValue').val('Printed <cfoutput>#variables.statusDispatch#</cfoutput> >');
                    $("##dispatchNotes").prepend(clock()+' - '+ $('##Loggedin_Person').val()+ ' > Printed <cfoutput>#variables.statusDispatch#</cfoutput> > \n');

                }
             });

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


            $( "body" ).on( "change", ".addressChange",function() {
                var stop = $(this).data( "role" );
                addressChanged(stop);
              });


            $('##shipperlocation,##shippercity,##shipperstate,##shipperZipcode').change(function() {
                calculateDeadHeadMiles();
            })

            // Setup form validation on the load element
            $("##load").validate({
                rules: {
                    orderDate: {
                        required: true
                    }
                },
                messages: {
                    orderDate: {
                        required: "Please enter a Order date"
                    }
                },

                errorPlacement: function(error, element) {
                  alert(error.text());
                }
            });

            $('.datePicker').on("click",function() {
                var itemId = $(this).attr("id");
                $(itemId).datepicker("show");
            });
        });
        function togglechange(x){
            $(".datePicker").datepicker();
            if(x == 1) {
                togglechange(0);
            }
        }


    </script>

  <script type="text/javascript">

    $(document).ready(function(){
        if($.trim($('##load input[name="loadnumber"]').val()).length == 0){
            $('##load input[name="save"]').removeAttr('disabled');
            $('##load input[name="submit"]').removeAttr('disabled');
            $('##load input[name="saveexit"]').removeAttr('disabled');
        }
        $('##PostTo123LoadBoard').click(function() {
            if($(this).is(":checked"))
            {
                $(this).val("1");

            } else {
                $(this).val("0");
            }
        });
        $('##posttoTranscore').click(function() {
            if($(this).is(":checked"))
            {
                $(this).val("1");

            } else {
                $(this).val("0");
                $('##Trancore_DeleteFlag').val(1);
            }
        });
        <cfif (request.qSystemSetupOptions.freightBroker EQ 2 AND chckdCarrier EQ 0) OR request.qSystemSetupOptions.freightBroker EQ 0> 
            $("##equipment").change(function(){     
                if(!$.trim($("##truckNo").val()).length){
                  $("##truckNo").val($("##equipment option:selected").data("truck-number"));  
                } 
            });
        </cfif>     
        
    });
    function changeCarrier(stop){
        document.getElementById("quoteCarrierInfo"+stop).style.display = 'none';
        document.getElementById('chooseQuoteCarrier'+stop).style.display = 'block';
        $('##quoteCarrierInfo'+stop).html('');
        $('##changeCarrier'+stop).hide();
        $('##chooseQuoteCarrier'+stop+' ##valueContainer').val('');
        $('##chooseQuoteCarrier'+stop+' .quote-carrier-box').val('');
        $('##chooseQuoteCarrier'+stop+' ##carrierName').val('');
        $('##chooseQuoteCarrier'+stop+' ##carrierMCNumber').val('');
        $('##chooseQuoteCarrier'+stop+' ##carrierContactPerson').val('');
        $('##chooseQuoteCarrier'+stop+' ##carrierPhoneNo').val('')
        $('##chooseQuoteCarrier'+stop+' ##carrierActive').val('');
    }

    function saveQuote(stop){
        var quoteCarrierID = $('##chooseQuoteCarrier'+stop+' ##valueContainer').val();
        var quoteAmount = $('##quoteAmount'+stop).val().replace('$', '');
        var quoteAmount = quoteAmount.replace(',', '');
        var quoteEquipment = $('##quoteEquipment'+stop).val();
        var quoteTruckNo = $('##quoteTruckNo'+stop).val();
        var quoteFuelSurcharge = $('##quoteFuelSurcharge'+stop).val();
        var quoteTrailerNo = $('##quoteTrailerNo'+stop).val();
        var quoteContainerNo = $('##quoteContainerNo'+stop).val();
        var quoteRefNo = $('##quoteRefNo'+stop).val();
        var quoteCarrRefNo = $('##quoteCarrRefNo'+stop).val();
        var quoteMiles = $('##quoteMiles'+stop).val();
        var quotecomments = $('##quotecomments'+stop).val();
        var CarrierQuoteID = $('##chooseQuoteCarrier'+stop+' ##CarrierQuoteID').val();

        if(CarrierQuoteID == 0){
            var act = 'ins'; 
        }
        else{
            var act = 'upd';  
        }

        if(!quoteCarrierID.length){
            alert("Please choose a carrier.");
            $('##chooseQuoteCarrier'+stop+' .quote-carrier-box').focus();
            return false;
        }

        if(!quoteAmount.length){
            quoteAmount = 0;
        }

        if(!quoteMiles.length){
            quoteMiles = 0;
        }

        var QDotNo = '';
        var QCell = ''; 
        var QExt = ''; 
        var QEmail = ''; 

        if(quoteCarrierID==0){
            var QCarrierName = $('##chooseQuoteCarrier'+stop+' .quote-carrier-box').val();
            var QMCNo = $('##QMCNo_'+stop).val();
            var QContact = $('##QContact_'+stop).val();
            var QPhone = $('##QPhone_'+stop).val();
            var QDotNo = $('##QDotNo_'+stop).val();
            var QCell = $('##QCell_'+stop).val();
            var QExt = $('##QExt_'+stop).val();
            var QEmail = $('##QEmail_'+stop).val();

            $('##chooseQuoteCarrier'+stop+' ##carrierName').val(QCarrierName);
            $('##chooseQuoteCarrier'+stop+' ##carrierMCNumber').val(QMCNo);
            $('##chooseQuoteCarrier'+stop+' ##carrierContactPerson').val(QContact);
            $('##chooseQuoteCarrier'+stop+' ##carrierPhoneNo').val(QPhone);
            $('##chooseQuoteCarrier'+stop+' ##carrierActive').val('Yes');
        }

        var carrierName = $('##chooseQuoteCarrier'+stop+' ##carrierName').val();
        var carrierMCNumber = $('##chooseQuoteCarrier'+stop+' ##carrierMCNumber').val();
        var carrierContactPerson = $('##chooseQuoteCarrier'+stop+' ##carrierContactPerson').val();
        var carrierPhoneNo = $('##chooseQuoteCarrier'+stop+' ##carrierPhoneNo').val();
        var carrierActive = $('##chooseQuoteCarrier'+stop+' ##carrierActive').val();

        var data    = {CarrierQuoteID : CarrierQuoteID, LoadID : '#loadid#', StopNo : stop, Amount : quoteAmount, CarrierID: quoteCarrierID, EquipmentID : quoteEquipment, TruckNo : quoteTruckNo, FuelSurcharge : quoteFuelSurcharge, TrailerNo : quoteTrailerNo, ContainerNo : quoteContainerNo, RefNo : quoteRefNo, CarrRefNo : quoteCarrRefNo, Miles : quoteMiles, Comments : quotecomments, dsn:'#application.dsn#',QCarrierName:carrierName,QMCNumber:carrierMCNumber,QDOTNumber:QDotNo,QContactPerson:carrierContactPerson,QCell:QCell,QPhone:carrierPhoneNo,QPhoneExt:QExt,QEmail:QEmail,AdminUserName:'#session.AdminUserName#'};

        $.ajax({
            type    : 'POST',
            url     : "../gateways/loadgateway.cfc?method=saveCarrierQuote",
            data    : data,
            success :function(resp){
                var respData = jQuery.parseJSON(resp);
                var CarrierQuoteID = respData.CARRIERQUOTEID;
                if(quoteAmount > 0 && quoteMiles > 0){
                    var rate_per_mile = '$'+(quoteAmount/quoteMiles).toFixed(2);
                }
                else{
                    var rate_per_mile = 'N/A';
                }
                if(!quoteEquipment.length){
                    var Equipment = '';
                }
                else{
                    var Equipment = $('##quoteEquipment'+stop+' option:selected').text();
                }
                changeCarrier(stop);
                $('##quoteAmount'+stop).val('$0.00');
                $('##quoteEquipment'+stop).prop('selectedIndex',0);
                $('##quoteTruckNo'+stop).val('');
                $('##quoteFuelSurcharge'+stop).val('');
                $('##quoteTrailerNo'+stop).val('');
                $('##quoteContainerNo'+stop).val('');
                $('##quoteRefNo'+stop).val('');
                $('##quoteCarrRefNo'+stop).val('');
                $('##quoteMiles'+stop).val(0);

                if(act == 'ins'){
                    if(quoteCarrierID==0){
                        var quoteListHtml = '<tr><td id="quoteAmount_'+CarrierQuoteID+'_'+stop+'">$'+quoteAmount+'</td><td><p onclick="openCarrierQuote('+CarrierQuoteID+','+stop+')" style="cursor: pointer;text-decoration: underline;color: ##0000ff;">'+carrierName+'</p></td><td>'+carrierMCNumber+'</td><td>'+carrierContactPerson+'</td><td>'+carrierPhoneNo+'</td><td>'+carrierActive+'</td><td id="quoteMiles_'+CarrierQuoteID+'_'+stop+'">'+quoteMiles+'</td><td id="quotePricePerMiles_'+CarrierQuoteID+'_'+stop+'">'+rate_per_mile+'</td><td id="quoteEquipmentName_'+CarrierQuoteID+'_'+stop+'">'+Equipment+'</td><td id="quoteCreatedBy_'+CarrierQuoteID+'_'+stop+'">#session.AdminUserName#</td><td id="quoteUpdatedBy_'+CarrierQuoteID+'_'+stop+'">#session.AdminUserName#</td><td id="quoteAddBook_'+CarrierQuoteID+'_'+stop+'"><input type="button" value="Add" onclick="addQuoteCarrier('+stop+','+quoteAmount+','+CarrierQuoteID+')" style="width:50px !important;height: 17px;"></td></tr>';
                    }
                    else{
                        var quoteListHtml = '<tr><td id="quoteAmount_'+CarrierQuoteID+'_'+stop+'">$'+quoteAmount+'</td><td><p onclick="openCarrierQuote('+CarrierQuoteID+','+stop+')" style="cursor: pointer;text-decoration: underline;color: ##0000ff;">'+carrierName+'</p></td><td>'+carrierMCNumber+'</td><td>'+carrierContactPerson+'</td><td>'+carrierPhoneNo+'</td><td>'+carrierActive+'</td><td id="quoteMiles_'+CarrierQuoteID+'_'+stop+'">'+quoteMiles+'</td><td id="quotePricePerMiles_'+CarrierQuoteID+'_'+stop+'">'+rate_per_mile+'</td><td id="quoteEquipmentName_'+CarrierQuoteID+'_'+stop+'">'+Equipment+'</td><td id="quoteCreatedBy_'+CarrierQuoteID+'_'+stop+'">#session.AdminUserName#</td><td id="quoteUpdatedBy_'+CarrierQuoteID+'_'+stop+'">#session.AdminUserName#</td><td id="quoteAddBook_'+CarrierQuoteID+'_'+stop+'"><input type="button" value="Book" onclick="bookQuote('+stop+',\''+quoteCarrierID+'\','+quoteAmount+')" style="width:50px !important;height: 17px;"></td></tr>';
                    }
                    
                    $('##tbl_quote_list_'+stop+' tbody .noQuotesMsg').hide();
                    $('##tbl_quote_list_'+stop+' tbody').append(quoteListHtml);
                    $('##carriertabs-'+stop+'-QuoteList .quoteSuccessMsg').show();
                    $('##carriertabs-'+stop+'-QuoteList .quoteSuccessMsg').fadeOut(5000);
                }  
                else{
                    $('##quoteAmount_'+CarrierQuoteID+'_'+stop).html('$'+quoteAmount);
                    $('##quoteMiles_'+CarrierQuoteID+'_'+stop).html(quoteMiles);
                    $('##quotePricePerMiles_'+CarrierQuoteID+'_'+stop).html(rate_per_mile);
                    $('##quoteEquipmentName_'+CarrierQuoteID+'_'+stop).html(Equipment);
                    $('##quoteUpdatedBy_'+CarrierQuoteID+'_'+stop).html('#session.AdminUserName#');
                } 
                $('##carriertabs'+stop).tabs("option", "active", 1);
                $('##carriertabs'+stop+' .add_quote_txt').html('Add Quote');
            }
        });
    }

    function addQuoteCarrier(stopNo,CarrFlatRate,CarrierQuoteID){
        var url = 'index.cfm?event=addcarrier&#session.URLToken#&IsCarrier=1&CarrierQuoteID='+CarrierQuoteID;
        newwindow=window.open(url,'targetWindow','height=560,width=1024,toolbar=0,scrollbars=0,location=0,statusbar=0,menubar=0,resizable=0');

        if (window.focus) {newwindow.focus()}
        return false;
    }

    function HandlePopupResult(carrierid,CarrierQuoteID,stopNo,CarrFlatRate,book) {
        $('##quoteAddBook_'+CarrierQuoteID+'_'+stopNo).html('<input type="button" value="Book" onclick="bookQuote('+stopNo+',\''+carrierid+'\','+CarrFlatRate+')" style="width:50px !important;height: 17px;">');

        if(book==1){
            bookQuote(stopNo,carrierid,CarrFlatRate);
        }
    }

    function bookQuote(stopNo,carrierid,CarrFlatRate){
         
        var path = urlComponentPath+"loadgateway.cfc?method=bookCarrierQuote";
        var user = $('##Loggedin_Person').val();
        var ChangeLoadNumber = 0;
        var frieghtBrokerStatus = document.getElementById('frieghtBroker').value;
        <cfif structKeyExists(url,"loadid") AND url.loadid NEQ "">
            if($('##LoadNumberAutoIncrement').val().trim() == 1){
                var onChangeFlagStatusVal = $("##loadStatus option:selected").data('statustext').trim();
                if(onChangeFlagStatusVal != "9. Cancelled" && onChangeFlagStatusVal != "9.5 do not use"){
                    if( $('##oldStatus').val().trim() != "" &&  
                            ($('##oldStatus').val().trim() == "0. QUOTE"  ||  $('##oldStatus').val().trim() == "1. ACTIVE"  ||  $('##oldStatus').val().trim() == ". TEMPLATE" )
                            && (onChangeFlagStatusVal != "0. QUOTE" ||  onChangeFlagStatusVal != "1. ACTIVE" || onChangeFlagStatusVal != ". TEMPLATE"  || onChangeFlagStatusVal !="9. Cancelled" || onChangeFlagStatusVal !="9.5 do not use")
                            ){
                        ChangeLoadNumber = 1;
                    }
                }
            }
        </cfif>
        $.ajax({
            type: "Post",
            url: path,
            dataType: "json",
            data: {loadid:'#url.loadid#',stopNo:stopNo,carrierid:carrierid,CarrFlatRate:CarrFlatRate,user:user,dsn:'#application.dsn#',companyid:'#session.companyid#',ChangeLoadNumber:ChangeLoadNumber,fBStatus:frieghtBrokerStatus},
            success: function(res){
                $(".overlay").hide();
                location.reload();
            },
            beforeSend: function() {
               $(".overlay").show();
            },
        });
    }

    function openCarrierQuote(CarrierQuoteID,stop){
        document.getElementById("quoteCarrierInfo"+stop).style.display = 'block';
        document.getElementById('chooseQuoteCarrier'+stop).style.display = 'none';
        $('##carriertabs'+stop+' .add_quote_txt').html('Quote Detail')
        $.ajax({
            type    : 'GET',
            url     : "../gateways/loadgateway.cfc?method=getLoadCarrierQuoteDetail",
            data    : {CarrierQuoteID : CarrierQuoteID, dsn:<cfoutput>"#application.dsn#"</cfoutput>},
            success :function(result){
                var quoteData = jQuery.parseJSON(result);
                var risk_assessment = quoteData.RISKASSESSMENT;
                var MCNumber = quoteData.MCNUMBER;
                var link = 'http://www.saferwatch.com/swCarrierDetailsLink.php?&number='+MCNumber;
                
                var QUnknownCarrier = quoteData.QUNKNOWNCARRIER;

                if(QUnknownCarrier==0){
                    var CarrierID = quoteData.CARRIERID;
                    var CarrierName = quoteData.CARRIERNAME;
                    var phoneNo = quoteData.PHONE;
                    var cell = quoteData.CEL;
                    var email = quoteData.EMAILID;
                }
                else{
                    var CarrierID = 0;
                    var phoneNo = quoteData.QPHONE;
                    var cell = quoteData.QCELL;
                    var CarrierName = quoteData.QCARRIERNAME;
                    var email = quoteData.QEMAIL;
                }
                var address = quoteData.ADDRESS;
                var city = quoteData.CITY;
                var zip = quoteData.ZIPCODE;
                var state = quoteData.STATECODE;
                var fax = quoteData.FAX;
                
                var quoteAmount = quoteData.AMOUNT;
                var quoteEquipment = quoteData.EQUIPMENTID;
                var quoteTruckNo = quoteData.TRUCKNO;
                var quoteFuelSurcharge = quoteData.FUELSURCHARGE;
                var quoteTrailerNo = quoteData.TRAILERNO;
                var quoteContainerNo = quoteData.CONTAINERNO;
                var quoteMiles = quoteData.MILES;
                var quoteCarrRefNo = quoteData.CARRREFNO;
                var quoteRefNo = quoteData.REFNO;
                var quotecomments = quoteData.COMMENTS;
                

                if(risk_assessment == 'Unacceptable'){
                    risk_assessment = 'images/SW-Red.png';
                }
                else if(risk_assessment == 'Moderate'){
                    risk_assessment = 'images/SW-Yellow.png';
                }
                else if(risk_assessment == 'Acceptable'){
                    risk_assessment = 'images/SW-Green.png';
                }
                else{
                    risk_assessment = 'images/SW-Blank.png';
                }

                var strHtml = "<div class='clear'></div>";
                strHtml = strHtml + "<div class='clear'></div>";
                if(risk_assessment != ""){
                    strHtml = strHtml + "<label><a target='_blank' href='"+link+"'><img src='"+risk_assessment+"' alt='Risk Assement Icon'></a></label>";
                }else{
                    strHtml = strHtml + "<label>&nbsp;</label>";
                }
                strHtml = strHtml + "<label class='field-textarea'>";
                strHtml = strHtml + "<b>";
                <cfset Iscarrier = "">
                <cfif ListContains(session.rightsList,'bookCarrierToLoad',',')>


                if(CarrierID==0){
                    strHtml = strHtml + "<a href='javascript: alert(\"Unable to open. Please add the carrier first.\");' style='color:##4322cc;text-decoration:underline;'>"
                }
                else{
                    <cfif request.qSystemSetupOptions.FreightBroker EQ 1>
                        strHtml = strHtml + "<a href='index.cfm?event=addcarrier&#Iscarrier#&carrierid="+CarrierID+"' style='color:##4322cc;text-decoration:underline;'>"
                    <cfelseif request.qSystemSetupOptions.FreightBroker EQ 2>
                        if(quoteData.iscarrier == 1){
                            strHtml = strHtml + "<a href='index.cfm?event=addcarrier&Iscarrier=1&carrierid="+CarrierID+"' style='color:##4322cc;text-decoration:underline;'>"
                        }else{
                            strHtml = strHtml + "<a href='index.cfm?event=adddriver&&Iscarrier=0&carrierid="+CarrierID+"' style='color:##4322cc;text-decoration:underline;'>"
                        }
                    <cfelse>
                          strHtml = strHtml + "<a href='index.cfm?event=adddriver&#Iscarrier#&carrierid="+CarrierID+"' style='color:##4322cc;text-decoration:underline;'>"
                    </cfif>

                }
                <cfelse>
                    strHtml = strHtml + "<a href='javascript: alert('Sorry!! You don\'t have rights to add/edit #variables.freightBroker#.'); return false;' style='color:##4322cc;text-decoration:underline;'>"
                </cfif>
                strHtml = strHtml + CarrierName
                strHtml = strHtml + "</a>"
                strHtml = strHtml + "</b>"
                strHtml = strHtml + "<br/>"
                if(QUnknownCarrier==0){
                    strHtml = strHtml + ""+address+"<br/>"+city+"<br/>"+state+"&nbsp;-&nbsp;"+zip+""
                }
                strHtml = strHtml + "</label>"
                strHtml = strHtml + "<div class='clear'></div>"
                strHtml = strHtml + "<label>Tel</label>"
                strHtml = strHtml + "<label class='cellnum-text'>"+phoneNo+"</label>"
                strHtml = strHtml + "<label class='space_load'>Cell</label>"
                strHtml = strHtml + "<label class='cellnum-text'>"+cell+"</label>"
                strHtml = strHtml + "<div class='clear'></div>"
                strHtml = strHtml + "<label>Fax</label>"
                strHtml = strHtml + "<label class='field-text'>"+fax+"</label>"
                strHtml = strHtml + "<div class='clear'></div>"
                strHtml = strHtml + "<label>Email</label>"
                strHtml = strHtml + "<label class='emailbox' style='width:260px'>"+email+"</label>";

                $('##chooseQuoteCarrier'+stop+' ##CarrierQuoteID').val(CarrierQuoteID);
                $('##chooseQuoteCarrier'+stop+' ##valueContainer').val(CarrierID);
                $('##quoteAmount'+stop).val(quoteAmount);
                $('##quoteEquipment'+stop).val(quoteEquipment);
                $('##quoteTruckNo'+stop).val(quoteTruckNo);
                $('##quoteFuelSurcharge'+stop).val(quoteFuelSurcharge);
                $('##quoteTrailerNo'+stop).val(quoteTrailerNo);
                $('##quoteContainerNo'+stop).val(quoteContainerNo);
                $('##quoteRefNo'+stop).val(quoteRefNo);
                $('##quoteCarrRefNo'+stop).val(quoteCarrRefNo);
                $('##quoteMiles'+stop).val(quoteMiles);
                $('##quotecomments'+stop).val(quotecomments);
                $('##quoteCarrierInfo'+stop).html(strHtml);
                $('##carriertabs'+stop).tabs("option", "active", 2);
            }
        });
    }   

    function clearQuote(stop){
        changeCarrier(stop);
        $('##chooseQuoteCarrier'+stop+' ##CarrierQuoteID').val(0);
        changeCarrier(stop);
        $('##quoteAmount'+stop).val('$0.00');
        $('##quoteEquipment'+stop).prop('selectedIndex',0);
        $('##quoteTruckNo'+stop).val('');
        $('##quoteFuelSurcharge'+stop).val('');
        $('##quoteTrailerNo'+stop).val('');
        $('##quoteContainerNo'+stop).val('');
        $('##quoteRefNo'+stop).val('');
        $('##quoteCarrRefNo'+stop).val('');
        $('##quotecomments'+stop).val('');
        $('##quoteMiles'+stop).val(0);
        $('##carriertabs'+stop+' .add_quote_txt').html('Add Quote');
    }

    function ChkUpdteShiprAddress(Shipr,type,stpno)
    {
        if (type=='Shipper')
        {
             $("##shipperUpAdd"+stpno).val(1);
        }
        if (type=='consignee')
        {
             $("##consigneeUpAdd"+stpno).val(1);
        }
    }
    function ChkUpdteShiprCity(Shipr,type,stpno)
    {
        if (type=='Shipper')
        {
             $("##shipperUpAdd"+stpno).val(2);
        }
        if (type=='consignee')
        {
             $("##consigneeUpAdd"+stpno).val(2);
        }
    }
    function ChkUpdteShipr(Shipr,type,stpno)
    {
        if ((type=='Shipper1' || type=='Shipper') && ( Shipr=='' || Shipr.length <=0) )
        {
            if (type=='Shipper1')
            {
                $("##shipper"+stpno).val('');
                $("##shipper"+stpno).removeClass('hyperLinkLabelStop');
                document.getElementById('milse').value = 0;             
            }
            $("##shipperValueContainer"+stpno).val('');
            $("##shipperName"+stpno).val('');
            $("##shipperNameText"+stpno).val('');
            $("##shipperlocation"+stpno).val('');
            $("##shippercity"+stpno).val('');
            $("##shipperstate"+stpno).val('');
            $("##shipperStateName"+stpno).val('');
            $("##shipperZipcode"+stpno).val('');
            $("##shipperContactPerson"+stpno).val('');
            $("##shipperPhone"+stpno).val('');
            $("##shipperFax"+stpno).val('');
            $("##shipperEmail"+stpno).val('');
            $("##shipperIsPayer"+stpno).val('');
            $("##shipIsPayer"+stpno).val('');
            if (type=='Shipper')
            {
                $('##newShipper'+stpno).show();
            }
            else
            {
                $("##span_Shipper"+stpno).html("");
                $('##newShipper'+stpno).hide();
            }
        }
        else if ( (type=='consignee' || type=='consignee1') && (Shipr=='' || Shipr.length  <=0) )
        {
            if (type=='consignee1')
            {
                $("##consignee"+stpno).val('');
                $("##consignee"+stpno).removeClass('hyperLinkLabelStop');
                document.getElementById('milse').value = 0;            
            }
            $("##consigneeValueContainer"+stpno).val('');
            $("##consigneeName"+stpno).val('');
            $("##consigneeNameText"+stpno).val('');
            $("##consigneelocation"+stpno).val('');
            $("##consigneecity"+stpno).val('');
            $("##consigneestate"+stpno).val('');
            $("##consigneeStateName"+stpno).val('');
            $("##consigneeZipcode"+stpno).val('');
            $("##consigneeContactPerson"+stpno).val('');
            $("##consigneePhone"+stpno).val('');
            $("##consigneeFax"+stpno).val('');
            $("##consigneeEmail"+stpno).val('');
            $("##consigneeIsPayer"+stpno).val('');
            if (type=='consignee')
            {
                $('##newConsignee'+stpno).show();
            }
            else
            {
                $("##span_Consignee"+stpno).html("");
                $('##newConsignee'+stpno).show();
            }
        }
        if ((type=='Shipper1' || type=='Shipper') && ( Shipr!='' || Shipr.length >0) && (Shipr != $("##shipperName"+stpno).val()))
        {
             $("##shipperName"+stpno).val(Shipr);
        }
        if ((type=='Shipper1' || type=='Shipper') && ( Shipr!='' || Shipr.length >0) && (Shipr != $("##shipper"+stpno).val()))
        {

             $("##shipper"+stpno).val(Shipr).removeClass('hint');
        }
        if ((type=='consignee1' || type=='consignee') && ( Shipr!='' || Shipr.length >0) && (Shipr != $("##consigneeName"+stpno).val()))
        {
             $("##consigneeName"+stpno).val(Shipr);
        }
        if ((type=='consignee1' || type=='consignee') && ( Shipr!='' || Shipr.length >0) && (Shipr != $("##consignee"+stpno).val()))
        {
             $("##consignee"+stpno).val(Shipr).removeClass('hint');
        }
        if (type=='consignee' || type=='consignee1')
        {$("##consigneeUpAdd"+stpno).val('');

        }
        if (type=='Shipper1' || type=='Shipper')
        {   $("##shipperUpAdd"+stpno).val('');

        }

    }
    
    function typeAddressfield(myVal){
        var thisVal = $(myVal).attr("value");
        if(thisVal == ''){
            $(this).val("TYPE NEW ADDRESS BELOW");
            $(this).css("color","##ccc");
            $(this).css("z-index","-1");
        }
    }
function showChangeAlert(customerType,stopNumber)
    {
    if(customerType=='shipper')
    {
        var ContainerVal='shipperValueContainer';

    }
    else
    {
        var ContainerVal='consigneeValueContainer';

    }
    if($("##"+ContainerVal+stopNumber).val()=="")
    {
        if($("##"+customerType+"Name"+stopNumber).val() !="" || $("##"+customerType+"location"+stopNumber).val()!="" || $("##"+customerType+"city"+stopNumber).val() !="" ||  $("##"+customerType+"state"+stopNumber).val() !="" ||  $("##"+customerType+"ZipCode"+stopNumber).val() !="")
        {

                var data = {
                            dsnName         :'#application.dsn#',
                            CompanyID       :'#session.CompanyID#',
                            customerName    :$("##"+customerType+"Name"+stopNumber).val(),
                            customerAddress :$("##"+customerType+"location"+stopNumber).val(),
                            customerCity    :$("##"+customerType+"city"+stopNumber).val(),
                            customerState   :$("##"+customerType+"state"+stopNumber).val(),
                            customerZipCode :$("##"+customerType+"Zipcode"+stopNumber).val()
                    };


                $.ajax({
                    url: '../gateways/loadgateway.cfc?method=customerDataCheck',
                    type: 'POST',
                    data: data,
                    success: function(resultData, textStatus, XMLHttpRequest)
                    {
                        resultData= resultData.split("|");

                        if(resultData[1] ==0)
                        {
                            if(customerType== "shipper")
                            {
                                if($("##"+customerType+"Name"+stopNumber).val() != $("##shipperNameText"+stopNumber).val())
                                {
                                    $('##newShipper'+stopNumber).show();
                                    $("##shipperFlag"+stopNumber).val(1);
                                    <cfif request.qSystemSetupOptions.TimeZone>
                                        var timeZone = moment.tz.guess();
                                        var time = new Date();
                                        var timeZoneOffset = time.getTimezoneOffset();
                                        $("##shipperTimeZone"+stopNumber).val(moment.tz.zone(timeZone).abbr(timeZoneOffset));
                                    </cfif>
                                }
                                else if ($("##shipperUpAdd"+stopNumber).val()==1)
                                {
                                    $("##span_Shipper"+stopNumber).html("<font color='red' size=2>Pickup address will be saved</font>");
                                    $("##shipperFlag"+stopNumber).val(2);
                                }
                                else if ($("##shipperUpAdd"+stopNumber).val()=='')
                                {
                                    $("##span_Shipper"+stopNumber).html("");
                                    $('##newShipper'+stopNumber).hide();

                                }
                                 else if ($("##shipperUpAdd"+stopNumber).val()==2)
                                {
                                    if($('##shipIsPayer'+stopNumber).val()== 1){
                                    } else {
                                        $("##span_Shipper"+stopNumber).html("<font color='red' size=2>Pickup city change will be saved</font>");
                                    }
                                }
                            }
                            else if(customerType== "consignee")
                            {
                                if($("##"+customerType+"Name"+stopNumber).val() != $("##consigneeNameText"+stopNumber).val())
                                {
                                    $('##newConsignee'+stopNumber).show();
                                    $("##consigneeFlag"+stopNumber).val(1);
                                    <cfif request.qSystemSetupOptions.TimeZone>
                                        var timeZone = moment.tz.guess();
                                        var time = new Date();
                                        var timeZoneOffset = time.getTimezoneOffset();
                                        $("##consigneeTimeZone"+stopNumber).val(moment.tz.zone(timeZone).abbr(timeZoneOffset));
                                    </cfif>
                                }
                                else if ($("##consigneeUpAdd"+stopNumber).val()==1)
                                {
                                    $("##span_Consignee"+stopNumber).html("<font color='red' size=2>Consignee address will be saved</font>");
                                    $("##consigneeFlag"+stopNumber).val(2);
                                }
                                else if ($("##consigneeUpAdd"+stopNumber).val()=='')
                                {
                                    $("##span_Consignee"+stopNumber).html("");
                                    $('##newConsignee'+stopNumber).hide();

                                }
                                else if ($("##consigneeUpAdd"+stopNumber).val()==2)
                                {
                                    if($('##consigneeIsPayer'+stopNumber).val()== 1){
                                    } else {
                                        $("##consigneeTimeZone"+stopNumber).html("<font color='red' size=2>Consignee city change will be saved</font>");
                                    }
                                    $("##consigneeFlag"+stopNumber).val(2);
                                }
                            }
                        }
                        else
                        {
                            if(customerType== "shipper")
                            {
                                $("##span_Shipper"+stopNumber).html("");
                                $("##newShipper"+stopNumber).hide();
                                $("##shipperFlag"+stopNumber).val(0);
                                $("##shipperValueContainer"+stopNumber).val(resultData[2]);
                            }
                            else if(customerType== "consignee")
                            {
                                $("##span_Consignee"+stopNumber).html("");
                                $("##newConsignee"+stopNumber).hide();
                                $("##consigneeFlag"+stopNumber).val(0);
                                $("##consigneeValueContainer"+stopNumber).val(resultData[2]);
                            }
                        }
                        //is commented because while updating the address of shipper or consignee, so many popups are invoked leading                           to hang of page. Alternatively function called using onchange and onblur.
                    }
                });
            }

    }
    else
    {
        if(customerType== "shipper")
        {
            if($("##"+customerType+"Name"+stopNumber).val() != $("##shipperNameText"+stopNumber).val())
            {
                if($('##shipIsPayer'+stopNumber).val()== 1){
                }
                else {
                    $("##span_Shipper"+stopNumber).html("<font color='red' size=2>Pickup Name change will be updated </font>");
                }
                $("##shipperFlag"+stopNumber).val(2);
            }
            else if ($("##shipperUpAdd"+stopNumber).val()== 1)
            {
                if($('##shipIsPayer'+stopNumber).val()== 1){
                    $("##shipperFlag"+stopNumber).val(2);
                }
                else{
                    $("##span_Shipper"+stopNumber).html("<font color='red' size=2>Pickup address will be updated</font>");
                    $("##shipperFlag"+stopNumber).val(2);
                }

            }
            else if ($("##shipperUpAdd"+stopNumber).val()==2)
            {
                if($('##shipIsPayer'+stopNumber).val()== 1){
                } else {
                    $("##span_Shipper"+stopNumber).html("<font color='red' size=2>Pickup city change will be saved</font>");
                }
                $("##shipperFlag"+stopNumber).val(2);
            }
            else
            {
                $("##span_Shipper"+stopNumber).html("");
                $("##shipperFlag"+stopNumber).val(2);
                $("##newShipper"+stopNumber).hide();
            }

        }
        else if(customerType== "consignee")
        {
            if($("##"+customerType+"Name"+stopNumber).val() != $("##consigneeNameText"+stopNumber).val())
            {
                if($('##consigneeIsPayer'+stopNumber).val()== 1){
                } else {
                    $("##span_Consignee"+stopNumber).html("<font color='red' size=2>Consignee Name change will be updated </font>");
                }
                $("##consigneeFlag"+stopNumber).val(2);
            }
            else if ($("##consigneeUpAdd"+stopNumber).val()==1)
            {
                if($('##consigneeIsPayer'+stopNumber).val()== 1){
                    $("##consigneeFlag"+stopNumber).val(2);
                }
                else{
                    $("##span_Consignee"+stopNumber).html("<font color='red' size=2>Consignee address will be updated</font>");
                    $("##consigneeFlag"+stopNumber).val(2);
                }

                $("##consigneeFlag"+stopNumber).val(2);
            }
            else if ($("##consigneeUpAdd"+stopNumber).val()==2)
            {
                if($('##consigneeIsPayer'+stopNumber).val()== 1){
                } else {
                    $("##span_Consignee"+stopNumber).html("<font color='red' size=2>Consignee city change will be saved</font>");
                }
                $("##consigneeFlag"+stopNumber).val(2);
            }
            else
            {
                $("##span_Consignee"+stopNumber).html("");
                $("##consigneeFlag"+stopNumber).val(2);
                $("##newConsignee"+stopNumber).hide();
            }
        }

    }


    }
    function updateMilseFunction(id){
        addressChanged(id);
    }


    function updateIsPayer(id){

    }

    function loadState(fldObj,from,stopNumber)
    {
        if($("##"+from+"StateName"+stopNumber).attr('id'))
        {
            if(fldObj.value!="")
                $("##"+from+"StateName"+stopNumber).val($("##"+fldObj.name+" option:selected").text());
            else
                $("##"+from+"StateName"+stopNumber).val('');
        }
    }
$(function() {

    // City DropBox
    function format(mail) {
        return mail.name + "<br/><b><u>Address</u>:</b> " + mail.location+"&nbsp;&nbsp;&nbsp;<b><u>City</u>:</b>" + mail.city+"&nbsp;&nbsp;&nbsp;<b><u>State</u>:</b> " + mail.state+"<br><b><u>Zip</u>:</b> " + mail.zip;
    }

        function Cityformat(mail)
        {
            return mail.city + "<br/><b><u>State</u>:</b> " + mail.state+"&nbsp;&nbsp;&nbsp;<b><u>Zip</u>:</b> " + mail.zip;
        }

        function Zipformat(mail)
        {
            return mail.zip + "<br/><b><u>State</u>:</b> " + mail.state+"&nbsp;&nbsp;&nbsp;<b><u>City</u>:</b> " + mail.city;
        }
    function formatCurrency(total) {
        var neg = false;
        if(total < 0) {
            neg = true;
            total = Math.abs(total);
        }
        return (neg ? "-$" : '$') + parseFloat(total, 10).toFixed(2).replace(/(\d)(?=(\d{3})+\.)/g, "$1,").toString();
    }
    // Customer DropBox
    $('##cutomerIdAuto').each(function(i, tag) {
        $(tag).autocomplete({
            multiple: false,
            width: 400,
            scroll: true,
            scrollHeight: 300,
            cacheLength: 1,
            highlight: false,
            dataType: "json",
            autoFocus: true,
            source: 'searchCustomersAutoFill.cfm?queryType=getCustomers&CompanyID=#session.CompanyID#',

            <cfif ListContains(session.rightsList,'changeCustomerActiveStatus',',')>
                response: function(event, ui) {
                    if(ui.content.length == 0){
                        if(confirm('There is no matching customer found. Do you like to add a new customer?')){
                            openAddNewCustomerPopup();
                        }
                    }
                },
            </cfif>
            select: function(e, ui) {
                console.log(ui);
                var creditLimitshow=formatCurrency(ui.item.creditLimit);
                var balanceAmount=formatCurrency(ui.item.balance);
                var availableAmount=formatCurrency(ui.item.available);
                $(this).val(ui.item.name);
                $('##'+this.id+'ValueContainer').val(ui.item.value);
                if(ui.item.consolidateinvoices == 1){
                    $('.div_consInv').show();
                }
                else{
                    $('.div_consInv').hide();
                }
                var strHtml ="<div id='CustInfo1'>"
                strHtml = strHtml +"<input name='customerAddress' id='customerAddress' type='hidden' value='"+ui.item.location+"'/>";
                strHtml = strHtml +"<input name='customerCity' id='customerCity' type='hidden' value='"+ui.item.city+"'/>";
                strHtml = strHtml +"<input name='customerState' id='customerState' type='hidden' value='"+ui.item.state+"'/>";
                strHtml = strHtml +"<input name='customerZipCode' id='customerZipCode' type='hidden' value='"+ui.item.zip+"'/>";
                strHtml = strHtml +"<input name='customerPayer' id='customerPayer' type='hidden' value='"+ui.item.isPayer+"'/>";
                strHtml = strHtml +"<input name='shipIsPayer' id='shipIsPayer' type='hidden' value='"+ui.item.isPayer+"'/>";
                if(!ui.item.isPayer){ui.item.currency = "";}
                strHtml = strHtml +"<input name='customerDefaultCurrency' id='customerDefaultCurrency' type='hidden' value='"+ui.item.currency+"'/>";
                <cfif listFindNoCase(session.rightsList, 'addEditLoadOnly')>
                strHtml = strHtml + "<label class='field-textarea'><b>"+ui.item.name+"</b><br/>"+ui.item.location+"<br/>"+ui.item.city+", "+ui.item.state+"<br/>"+ui.item.zip+"</label>"
                <cfelse>
                    strHtml = strHtml + "<label class='field-textarea'><b><a style='text-decoration:underline;'  target='_blank' href=index.cfm?event=addcustomer&customerid="+ui.item.value+" >"+ui.item.name+"</a></b><br/>"+ui.item.location+"<br/>"+ui.item.city+", "+ui.item.state+" "+ui.item.zip+"</label>"
                </cfif>
                strHtml = strHtml + "<div class='clear'></div>"
                strHtml = strHtml + "<label>Contact</label><input name='CustomerContact' value='"+ui.item.contactPerson+"'>"
                strHtml = strHtml + "<div class='clear'></div>"
                strHtml = strHtml + "<label>Tel</label>"
                strHtml = strHtml + "<input name='customerPhone' value='"+ui.item.phoneNo+"' style='width: 89px'>"
                strHtml = strHtml + "<label class='space_load'>Ext</label>"
                strHtml = strHtml + "<input name='customerPhoneExt' value='"+ui.item.phoneNoExt+"' style='width: 31px' maxlength='30'>"
                strHtml = strHtml + "<div class='clear'></div>"
                strHtml = strHtml + "<label>Cell</label>"
                strHtml = strHtml + "<input name='customerCell' value='"+ui.item.cellNo+"' style='width: 90px'>"
                strHtml = strHtml + "<label class='space_load'>Fax</label>"
                strHtml = strHtml + "<input name='customerFax' value='"+ui.item.fax+"' style='width: 90px'>"
                strHtml = strHtml + "<div class='clear'></div>"
                strHtml = strHtml + "<label>Email</label>"
                strHtml = strHtml + "<input name='CustomerEmail' value='"+ui.item.email+"' style='width: 248px'>"
                strHtml = strHtml + "<div class='clear'></div>"
                strHtml = strHtml + "<div class='clear'></div>"
                strHtml = strHtml + "</div>";
                $('##CustInfo1').html(strHtml);
                var strHtml = "<div class='form-con'>"
                strHtml = strHtml + "<fieldset>"
                strHtml = strHtml + "<label>Credit Limit</label>"
                strHtml = strHtml + "<input name='CreditLimit' id='CreditLimit' type='text' value='"+creditLimitshow+"'/>"
                strHtml = strHtml + "<input name='CreditLimitInput' id='CreditLimitInput' type='hidden' value='"+ui.item.creditLimit+"'/>"
                strHtml = strHtml + "<div class='clear'></div>"
                strHtml = strHtml + "<label >Balance</label>"
                strHtml = strHtml + "<input name='balanceAmount' id='balanceAmount' type='text' value='"+balanceAmount+"' />"
                strHtml = strHtml + "<input name='BalanceInput' id='BalanceInput' type='hidden' value='"+ui.item.balance+"'/>"
                strHtml = strHtml + "<div class='clear'></div>"
                strHtml = strHtml + "<label>Available</label>"
                strHtml = strHtml + "<input name='Available' id='Available' type='text' value='"+availableAmount+"' />"
                strHtml = strHtml + "<input name='AvailableInput' id='AvailableInput' type='hidden' value='"+ui.item.available+"' />"
                strHtml = strHtml + "<div class='clear'></div>"
                strHtml = strHtml + "<label>Notes</label>"
                strHtml = strHtml + "<textarea name='' cols='' style='height:76px;' rows=''>"+ui.item.notes+"</textarea>"
                strHtml = strHtml + "<div class='clear'></div>"
                strHtml = strHtml + "<label>Dispatch Notes</label>"
                strHtml = strHtml + "<textarea name='' cols='' style='height:76px;' rows=''>"+ui.item.dispatchNotes+"</textarea>"
                strHtml = strHtml + "<div class='clear'></div>"
                strHtml = strHtml + "</fieldset>"
                strHtml = strHtml + "</div>"
                $('##CustInfo2').html(strHtml);
                if($("##customerDefaultCurrency").val().length){
                    $('##defaultCustomerCurrency option[value=' +$("##customerDefaultCurrency").val()+']').prop('selected', true);
                }else{
                    $('##defaultCustomerCurrency option[value=' +$("##defaultSystemCurrency").val()+']').prop('selected', true);
                }
                $('##defaultCustomerCurrency').trigger("change");
                
                if((ui.item.CarrierNotes)!=''){
                    $('##carrierNotes').val(ui.item.CarrierNotes);
                }

                $('##CreditLimit').change(function(){
                    var CreditLimit = $(this).val();
                    CreditLimit = CreditLimit.replace("$","");
                    CreditLimit = CreditLimit.replace(/,/g,"");

                    if(isNaN(CreditLimit)){
                        alert('Invalid Credit Limit.');
                        $(this).val('$0.00');   
                        $(this).focus();
                    }   
                });

                $('##balanceAmount').change(function(){
                    var balanceAmount = $(this).val();
                    balanceAmount = balanceAmount.replace("$","");
                    balanceAmount = balanceAmount.replace(/,/g,"");

                    if(isNaN(balanceAmount)){
                        alert('Invalid Balance Amount.');
                        $(this).val('$0.00');   
                        $(this).focus();
                    }   
                });

                $('##Available').change(function(){
                    var Available = $(this).val();
                    Available = Available.replace("$","");
                    Available = Available.replace(/,/g,"");

                    if(isNaN(Available)){
                        alert('Invalid Available Amount.');
                        $(this).val('$0.00');   
                        $(this).focus();
                    }   
                });

                //Setting default sales rep of the customer
                if(ui.item.locksalesagentonload){
                    $('##Salesperson').val(ui.item.salesRep);
                    $('##Salesperson').css("pointer-events","none");
                    $('##Salesperson').css("opacity","0.5")
                }
                else{
                    $('##Salesperson').css("pointer-events","");
                    $('##Salesperson').css("opacity","1")
                    if($('##Salesperson').val()=='')
                    {
                        $('##Salesperson').val(ui.item.salesRep);
                    }
                }
                
                //Setting default dispatcher of the customer
                if(ui.item.lockdispatcheronload){
                    $('##Dispatcher').val(ui.item.dispatcher);
                    $('##Dispatcher').css("pointer-events","none");
                    $('##Dispatcher').css("opacity","0.5")
                }
                else{
                    $('##Dispatcher').css("pointer-events","");
                    $('##Dispatcher').css("opacity","1")
                    if($('##Dispatcher').val()=='')
                    {
                        $('##Dispatcher').val(ui.item.dispatcher);
                    }
                }
                if(ui.item.lockdispatcher2onload){
                    $('##LockDispatcher2OnLoad').val("1")
                }

                if($.trim(ui.item.dispatcher2).length && !$.trim($('##fpDispatcher2').val()).length){
                    $('##fpDispatcher2').val(ui.item.dispatcher2);
                    $('##Dispatcher2').val(ui.item.dispatcher2);
                }
                
                if($.trim(ui.item.salesRep2).length && !$.trim($('##fpSalesRep2').val()).length){
                    $('##fpSalesRep2').val(ui.item.salesRep2);
                    $('##SalesRep2').val(ui.item.salesRep2);
                }

                <cfif request.qSystemSetupOptions.AutomaticFactoringFee eq 1>
                    $('##FactoringFeePercent').val(ui.item.ff);
                    <cfif not ListContains(session.rightsList,'HideCustomerPricing',',')>
                        $('##spanFF').html(ui.item.ff);
                    </cfif>
                    updateTotalAndProfitFields();
                </cfif>

                <cfif request.qsystemoptions.BillFromCompanies EQ 1>
                    if($.trim(ui.item.billfromcompany).length){
                        $('##BillFromCompany').val(ui.item.billfromcompany);
                    }
                    else if(!$.trim(ui.item.billfromcompany).length && "#request.qsystemoptions.DefaultBillFromAsCompany#" == 1){
                        $('##BillFromCompany').val('#session.CompanyID#');
                    }else{
                        $('##BillFromCompany').val('');
                    }
                </cfif>
                return false;
            }
        });
        $(tag).data("ui-autocomplete")._renderItem = function(ul, item) {
            return $( "<li>"+item.name+"<br/><b><u>Address</u>:</b> "+ item.location+"&nbsp;&nbsp;&nbsp;<b><u>City</u>:</b>" + item.city+"&nbsp;&nbsp;&nbsp;<b><u>State</u>:</b> " + item.state+"<br/><b><u>Zip</u>:</b> " + item.zip+"</li>" )
                    .appendTo( ul );
        }
    });

    // Shippper DropBox
    $('##shipper, ##consignee').each(function(i, tag) {
        $(tag).autocomplete({
            multiple: false,
            width: 400,
            scroll: true,
            scrollHeight: 300,
            cacheLength: 1,
            highlight: false,
            dataType: "json",
            autoFocus: true,
            source: 'searchCustomersAutoFill.cfm?queryType=getShippers&CompanyID=#session.CompanyID#&stoptype='+this.id,
            select: function(e, ui) {
                $(this).removeClass('hyperLinkLabelStop');
                $(this).val(ui.item.name);
                $(this).parent().find('.updateCreateAlert').val(ui.item.isPayer);
                if(ui.item.value != "NA"){
                    $('##'+this.id+'ValueContainer').val(ui.item.value);
                    $(this).attr("onclick","openCustomerPopup('"+ui.item.value+"',this);");
                    $(this).addClass('hyperLinkLabelStop');
                }
                $('##'+this.id+'Name').val(ui.item.name);
                $('##'+this.id+'NameText').val(ui.item.name);
                $('##'+this.id+'location').val(ui.item.location);
                $('##'+this.id+'city').val(ui.item.city);
                $('##'+this.id+'Zipcode').val(ui.item.zip);
                $('##'+this.id+'ContactPerson').val(ui.item.contactPerson);
                $('##'+this.id+'Phone').val(ui.item.phoneNo);
                $('##'+this.id+'PhoneExt').val(ui.item.phoneNoExt);
                $('##'+this.id+'Fax').val(ui.item.fax);
                $('##'+this.id+'state').val(ui.item.state);
                $('##'+this.id+'StateName').val(ui.item.state);
                $('##'+this.id+'Email').val(ui.item.email);
                $('##'+this.id+'Notes').val(ui.item.notes);
                <cfif request.qSystemSetupOptions.timezone>
                    $('##'+this.id+'TimeZone').val(ui.item.timezone);
                </cfif>
                var stopNum ="";
                var customerType ="";
                var idText = $(this).attr('id');

                 if(idText.indexOf("shipper")!=-1)
                {
                    customerType= 'shipper';
                    idText = idText.split("shipper");
                }
                else if(idText.indexOf("consignee")!=-1)
                {
                    customerType= 'consignee';
                    var idText = idText.split("consignee");
                    <cfif request.qSystemSetupOptions.BOLReportFormat EQ 'Preprinted'>
                        if((ui.item.CarrierNotes)!=''){
                            $('##carrierNotes').val(ui.item.CarrierNotes);
                        }
                    </cfif>
                }
                refreshMilesClicked('');
                stopNum =idText[1];
                
                showChangeAlert(customerType,stopNum);

                if(customerType == 'shipper' && !$.trim(stopNum).length){
                    calculateDeadHeadMiles();
                }


                return false;
            }
        });
        $(tag).data("ui-autocomplete")._renderItem = function(ul, item) {
            return $( "<li>"+item.name+"<br/><b><u>Address</u>:</b> "+ item.location+"&nbsp;&nbsp;&nbsp;<b><u>City</u>:</b>" + item.city+"&nbsp;&nbsp;&nbsp;<b><u>State</u>:</b> " + item.state+"<br/><b><u>Zip</u>:</b> " + item.zip+"</li>" )
                    .appendTo( ul );
        }
    });

    //City Shippper City
    $('##shippercity, ##consigneecity').each(function(i, tag) {
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
                $(this).val(ui.item.city);
                strId = this.id;
                initialStr = strId.substr(0, 7);
                if(initialStr != 'shipper')
                {
                    initialStr = 'consignee';
                }

                if($("##"+initialStr+"state option[value='"+ui.item.state+"']").length){
                    $('##'+initialStr+'state').val(ui.item.state);
                }
                else{
                    $('##'+initialStr+'state').val("");
                }
                $('##'+initialStr+'StateName').val(ui.item.state);
                $('##'+initialStr+'Zipcode').val(ui.item.zip);
                addressChanged('');
                return false;
            }
        });
        $(tag).data("ui-autocomplete")._renderItem = function(ul, item) {
            return $( "<li>"+item.city+"<br/><b><u>State</u>:</b> "+ item.state+"&nbsp;&nbsp;&nbsp;<b><u>Zip</u>:</b>" + item.zip+"</li>" )
                    .appendTo( ul );
        }
    });
    //zip AutoComplete
    $('##shipperZipcode, ##consigneeZipcode').each(function(i, tag) {
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
                $(this).val(ui.item.zip);
                strId = this.id;
                zipCodeVal=$('##'+strId).val();
                //auto complete the state and city based on first 5 characters of zip code
                if(zipCodeVal.length == 5)
                {
                    initialStr = strId.substr(0, 7);
                    if(initialStr != 'shipper')
                    {
                        initialStr = 'consignee';
                    }
                    //Donot update a field if there is already a value entered
                    if($('##'+initialStr+'state').val() == '')
                    {   
                        if($("##"+initialStr+"state option[value='"+ui.item.state+"']").length){
                            $('##'+initialStr+'state').val(ui.item.state);
                        }
                        else{
                            $('##'+initialStr+'state').val("");
                        }
                        $('##'+initialStr+'StateName').val(ui.item.state);
                    }
                    if($('##'+initialStr+'city').val() == '')
                    {
                        $('##'+initialStr+'city').val(ui.item.city);
                    }
                    addressChanged('');
                }
                return false;
            }
        });
        $(tag).data("ui-autocomplete")._renderItem = function(ul, item) {
            return $( "<li>"+item.zip+"<br/><b><u>State</u>:</b> "+ item.state+"&nbsp;&nbsp;&nbsp;<b><u>City</u>:</b>" + item.city+"</li>" )
                    .appendTo( ul );
        }
    });

    function formatCarrier(mail) {
        return mail.name + "<br/><b><u>City</u>:</b> " + mail.city+"&nbsp;&nbsp;&nbsp;<b><u>State</u>:</b> " + mail.state+"&nbsp;&nbsp;&nbsp;<b><u>Zip</u>:</b> " + mail.zip+"&nbsp;&nbsp;&nbsp;<b><u>Insurance Expiry</u>:</b> " + mail.InsExpDate;
    }
    // Customer TropBox

    $('.quote-carrier-box').each(function(i, tag) {
        $(tag).autocomplete({
            multiple: false,
            width: 450,
            scroll: true,
            scrollHeight: 300,
            cacheLength: 1,
            highlight: false,
            dataType: "json",
            autoFocus: true,
            response: function(event, ui) {
                var stop = $(this).data("stop");
                var tempID = $('##chooseQuoteCarrier'+stop+' ##valueContainer').val();

                if(ui.content.length == 0 && !tempID.length){
                    if(confirm('There is no matching carrier found in our system. Would you like to enter a quote from an unknown carrier?')){
                        
                        var strHtml = "<div class='clear'></div>";
                        strHtml = strHtml + "<label>MC ##</label>";
                        strHtml = strHtml + "<input type='text' id='QMCNo_"+stop+"'  value='' class='inp83px'>";
                        strHtml = strHtml + "<label class='label40px'>DOT ##</label>";
                        strHtml = strHtml + "<input type='text' id='QDotNo_"+stop+"'  value='' class='inp83px'>";
                        strHtml = strHtml + "<div class='clear'></div>";

                        strHtml = strHtml + "<label>Contact</label>";
                        strHtml = strHtml + "<input type='text' id='QContact_"+stop+"' value='' class='inp83px'>";
                        strHtml = strHtml + "<label class='label40px'>Cell</label>";
                        strHtml = strHtml + "<input type='text' id='QCell_"+stop+"' value='' class='inp83px' onchange='ParseUSNumber(this);'>";
                        strHtml = strHtml + "<div class='clear'></div>";

                        strHtml = strHtml + "<label>Phone</label>";
                        strHtml = strHtml + "<input type='text' id='QPhone_"+stop+"' value='' class='inp83px' onchange='ParseUSNumber(this);'>";
                        strHtml = strHtml + "<label class='label40px'>Ext</label>";
                        strHtml = strHtml + "<input type='text' id='QExt_"+stop+"' value='' class='inp83px'>";
                        strHtml = strHtml + "<div class='clear'></div>";

                        strHtml = strHtml + "<label>Email</label>";
                        strHtml = strHtml + "<input type='text' id='QEmail_"+stop+"' style='width:230px;' value=''>";
                        strHtml = strHtml + "<div class='clear'></div>";

                        document.getElementById("quoteCarrierInfo"+stop).style.display = 'block';
                        $('##quoteCarrierInfo'+stop).html(strHtml);
                        $('##chooseQuoteCarrier'+stop+' ##valueContainer').val('0');

                    }
                }
            },

            search: function(event, ui){$(this).autocomplete('option', 'source', 'searchCarrierAutoFill.cfm?queryType=getCustomers&companyid=#session.companyid#&loadid=#loadid#&pickupdate=' + $("##shipperPickupDate"+(($(this).data("stop") == 1) ? "" : $(this).data("stop"))).val() + '&deliverydate=' + $("##consigneePickupDate"+(($(this).data("stop") == 1) ? "" : $(this).data("stop"))).val())},
            source: 'searchCarrierAutoFill.cfm?queryType=getCustomers&companyid=#session.companyid#&loadid=#loadid#&pickupdate=',
            select: function(e, ui) { 
                var stop = $(this).data("stop");

                if(ui.item.isoverlimit == 'yes')
                {
                    alert("#ReReplace(variables.freightBroker,"\b(\w)","\u\1")# has reached their daily limit for this pickup date.");
                    return false;
                }
                $(this).val(ui.item.name);
                $('##chooseQuoteCarrier'+stop+' ##valueContainer').val(ui.item.value);
                $('##chooseQuoteCarrier'+stop+' ##carrierName').val(ui.item.name);
                $('##chooseQuoteCarrier'+stop+' ##carrierMCNumber').val(ui.item.MCNumber);
                $('##chooseQuoteCarrier'+stop+' ##carrierContactPerson').val(ui.item.ContactPerson);
                $('##chooseQuoteCarrier'+stop+' ##carrierPhoneNo').val(ui.item.phoneNo);
                if(ui.item.Status == 'ACTIVE'){
                    $('##chooseQuoteCarrier'+stop+' ##carrierActive').val('Yes');
                }
                else{
                    $('##chooseQuoteCarrier'+stop+' ##carrierActive').val('No');
                }

                var strHtml = "<div class='clear'></div>"
                strHtml = strHtml + "<div class='clear'></div>"
                if(ui.item.risk_assessment != ""){
                    strHtml = strHtml + "<label><a target='_blank' href='"+ui.item.link+"'><img src='"+ui.item.risk_assessment+"' alt='Risk Assement Icon'></a></label>"
                }else{
                    strHtml = strHtml + "<label>&nbsp;</label>"
                }
                strHtml = strHtml + "<label class='field-textarea'>"
                strHtml = strHtml + "<b>"

                <cfset Iscarrier = "">
                <cfif structkeyexists(request,"qLoads") AND structkeyexists(request.qLoads,"Iscarrier") AND request.qLoads.Iscarrier NEQ "" >
                     <cfset Iscarrier = "&Iscarrier=#request.qLoads.Iscarrier#">
                </cfif>


                <cfif ListContains(session.rightsList,'bookCarrierToLoad',',')>
                    <cfif request.qSystemSetupOptions.FreightBroker EQ 1>
                        strHtml = strHtml + "<a href='index.cfm?event=addcarrier&#Iscarrier#&carrierid="+ui.item.value+"' style='color:##4322cc;text-decoration:underline;'>"
                    <cfelseif request.qSystemSetupOptions.FreightBroker EQ 2>
                        if(ui.item.iscarrier == 1){
                            strHtml = strHtml + "<a href='index.cfm?event=addcarrier&Iscarrier=1&carrierid="+ui.item.value+"' style='color:##4322cc;text-decoration:underline;'>"
                        }else{
                            strHtml = strHtml + "<a href='index.cfm?event=adddriver&&Iscarrier=0&carrierid="+ui.item.value+"' style='color:##4322cc;text-decoration:underline;'>"
                        }
                    <cfelse>
                          strHtml = strHtml + "<a href='index.cfm?event=adddriver&#Iscarrier#&carrierid="+ui.item.value+"' style='color:##4322cc;text-decoration:underline;'>"
                    </cfif>
                <cfelse>
                    strHtml = strHtml + "<a href='javascript: alert('Sorry!! You don\'t have rights to add/edit #variables.freightBroker#.'); return false;' style='color:##4322cc;text-decoration:underline;'>"
                </cfif>
                strHtml = strHtml + ui.item.name
                strHtml = strHtml + "</a>"
                strHtml = strHtml + "</b>"
                strHtml = strHtml + "<br/>"
                strHtml = strHtml + ""+ui.item.name+"<br/>"+ui.item.city+"<br/>"+ui.item.state+"&nbsp;-&nbsp;"+ui.item.zip+""
                strHtml = strHtml + "</label>"
                strHtml = strHtml + "<div class='clear'></div>"
                strHtml = strHtml + "<label>Tel</label>"
                strHtml = strHtml + "<label class='cellnum-text'>"+ui.item.phoneNo+"</label>"
                strHtml = strHtml + "<label class='space_load'>Cell</label>"
                strHtml = strHtml + "<label class='cellnum-text'>"+ui.item.cell+"</label>"
                strHtml = strHtml + "<div class='clear'></div>"
                strHtml = strHtml + "<label>Fax</label>"
                strHtml = strHtml + "<label class='field-text'>"+ui.item.fax+"</label>"
                strHtml = strHtml + "<div class='clear'></div>"
                strHtml = strHtml + "<label>Email</label>"
                strHtml = strHtml + "<label class='emailbox' style='width:260px'>"+ui.item.email+"</label>";
                if(ui.item.status == 'INACTIVE'){
                    alert('#variables.freightBroker# is Inactive.');
                    changeCarrier(stop);
                    return false;
                }

                if(ui.item.iscarrier == 1 && ui.item.insuranceExpired == 'yes')
                {
                    if(! (#request.qSystemSetupOptions.AllowBooking#)){
                            alert("One or more of the Carrier's insurances has an expiration date prior to the final delivery of this load." );
                            $(this).val('');
                            return false;
                        }
                    else{
                        alert("One or more of the Carrier's insurances has an expiration date prior to the final delivery of this load." );
                    }

                }

                document.getElementById("quoteCarrierInfo"+stop).style.display = 'block';
                document.getElementById('chooseQuoteCarrier'+stop).style.display = 'none';

                $('##quoteCarrierInfo'+stop).html(strHtml);
                $('##changeCarrier'+stop).show();
                return false;
            }

        });
        $(tag).data("ui-autocomplete")._renderItem = function(ul, item) {
            if(item.risk_assessment != ""){
                var url = "<a target='_blank' href='"+item.link+"'><img src='"+item.risk_assessment+"' alt='Risk Assement Icon'></a>";
            }else{
                var url = "";
            }

            return $( "<li>"+item.name+"&nbsp;&nbsp;&nbsp;<b><u>Status</u>:</b> "+ item.status+"&nbsp;&nbsp;&nbsp;"+url+"<br/><b><u>City</u>:</b> "+ item.city+"&nbsp;&nbsp;&nbsp;<b><u>State</u>:</b>" + item.state+"&nbsp;&nbsp;&nbsp;<b><u>Zip</u>:</b> " + item.zip+"&nbsp;&nbsp;&nbsp;<b><u>Insurance Expiry</u>:</b> " + item.InsExpDate+"</li>" )
                    .appendTo( ul );
        }
    })

    $('.CarrEmail').each(function(i, tag) {
        var carrID = $( this ).data( "carrid" );
        $(tag).autocomplete({
            multiple: false,
            width: 450,
            scroll: true,
            scrollHeight: 300,
            cacheLength: 1,
            highlight: false,
            dataType: "json",
            minLength:0,
            autoFocus: true,
            source: 'searchCarrierContactAutoFill.cfm?carrierID='+carrID,
            select: function(e, ui) {
                $('##CarrierPhoneNo').val(ui.item.phoneno);
                $('##CarrierPhoneNoExt').val(ui.item.phonenoext);
                $('##CarrierFax').val(ui.item.fax);
                $('##CarrierFaxExt').val(ui.item.faxext);
                $('##CarrierTollFree').val(ui.item.tollfree);
                $('##CarrierTollFreeExt').val(ui.item.tollfreeext);
                $('##CarrierCell').val(ui.item.PersonMobileNo);
                $('##CarrierCellExt').val(ui.item.MobileNoExt);
            },
        }).focus(function() { 
                $(this).keydown();
            })
        $(tag).data("ui-autocomplete")._renderItem = function(ul, item) {
            return $( "<li><b><u>Email</u>:</b> "+item.email+"<br/><b><u>Contact</u>:</b> "+ item.ContactPerson+"&nbsp;&nbsp;&nbsp;<b><u>Phone</u>:</b> "+ item.phoneno+"<br/><b><u>cell</u>:</b> " + item.PersonMobileNo+"&nbsp;&nbsp;&nbsp;<b><u>Type</u>:</b> " + item.ContactType+"</li>" )
                    .appendTo( ul );
        }
    })
    $('##selectedCarrierValue').keyup(function(){
        $('.spinner').show();
        if(!$.trim($(this).val()).length){
           $('.spinner').hide(); 
        }
    });

    CarrierContactAutoComplete();
    DriverContactAutoComplete('');
    $('##selectedCarrierValue').each(function(i, tag) {
        $(tag).autocomplete({
            multiple: false,
            width: 450,
            scroll: true,
            scrollHeight: 300,
            cacheLength: 1,
            highlight: false,
            dataType: "json",
            delay:500,
            autoFocus: true,
            search: function(event, ui){$(this).autocomplete('option', 'source', 'searchCarrierAutoFill.cfm?queryType=getCustomers&companyid=#session.companyid#&loadid=#loadid#&pickupdate=' + $("##shipperPickupDate"+(($(this).data("stop") == 1) ? "" : $(this).data("stop"))).val() + '&deliverydate=' + $("##consigneePickupDate"+(($(this).data("stop") == 1) ? "" : $(this).data("stop"))).val())},
            source: 'searchCarrierAutoFill.cfm?queryType=getCustomers&companyid=#session.companyid#&loadid=#loadid#&pickupdate=',
            response:function(event, ui){
                $('.spinner').hide();
            },
            select: function(e, ui) { 
                if(ui.item.ExpDocCount != 0){
                    $(this).val('');
                    if(confirm("This carrier has expired document(s), would you liked to request the carrier to provide new documents now?")){
                        openCarrierOnboardPopup('#session.URLToken#&ExpiredDocuments=1',ui.item.value);
                    }
                    else{
                        window.open("index.cfm?event=addcarrier&Iscarrier=1&carrierid="+ui.item.value+"&#session.URLToken#", '_blank');
                        //location.href="index.cfm?event=addcarrier&Iscarrier=1&carrierid="+ui.item.value+"&#session.URLToken#";
                    }
                    return false;
                }
                if(ui.item.isoverlimit == 'yes')
                {
                    alert("#ReReplace(variables.freightBroker,"\b(\w)","\u\1")# has reached their daily limit for this pickup date.");
                    return false;
                }
                $(this).val(ui.item.name);
                $('##'+this.id+'ValueContainer').val(ui.item.value);                
                var strHtml = "<div class='clear'></div>"
                    strHtml = strHtml + "<input name='carrierID' id='carrierID' type='hidden' value='"+ui.item.value+"' /><input name='carrierDefaultCurrency' id='carrierDefaultCurrency' type='hidden' value='"+ui.item.currency+"' /><input name='CalculateDHMiles' id='CalculateDHMiles' type='hidden' value='"+ui.item.CalculateDHMiles+"' />"
                    strHtml = strHtml + "<div class='clear'></div>"
                    if(ui.item.risk_assessment != ""){
                        strHtml = strHtml + "<label><a target='_blank' href='"+ui.item.link+"'><img src='"+ui.item.risk_assessment+"' alt='Risk Assement Icon'></a></label>"
                    }else{
                        strHtml = strHtml + "<label>&nbsp;</label>"
                    }
                    strHtml = strHtml + "<label class='field-textarea carrier-field-textarea'>"
                    strHtml = strHtml + "<b>"

                    <cfset Iscarrier = "">
                    <cfif structkeyexists(request,"qLoads") AND structkeyexists(request.qLoads,"Iscarrier") AND request.qLoads.Iscarrier NEQ "" >
                         <cfset Iscarrier = "&Iscarrier=#request.qLoads.Iscarrier#">
                    </cfif>


                    <cfif ListContains(session.rightsList,'bookCarrierToLoad',',')>
                        <cfif request.qSystemSetupOptions.FreightBroker EQ 1>
                            strHtml = strHtml + "<a href='index.cfm?event=addcarrier&#Iscarrier#&carrierid="+ui.item.value+"' style='color:##4322cc;text-decoration:underline;'>"
                        <cfelseif request.qSystemSetupOptions.FreightBroker EQ 2>
                            if(ui.item.iscarrier == 1){
                                strHtml = strHtml + "<a href='index.cfm?event=addcarrier&Iscarrier=1&carrierid="+ui.item.value+"' style='color:##4322cc;text-decoration:underline;'>"
                            }else{
                                strHtml = strHtml + "<a href='index.cfm?event=adddriver&&Iscarrier=0&carrierid="+ui.item.value+"' style='color:##4322cc;text-decoration:underline;'>"
                            }
                        <cfelse>
                              strHtml = strHtml + "<a href='index.cfm?event=adddriver&#Iscarrier#&carrierid="+ui.item.value+"' style='color:##4322cc;text-decoration:underline;'>"
                        </cfif>
                    <cfelse>
                        strHtml = strHtml + "<a href='javascript: alert('Sorry!! You don\'t have rights to add/edit #variables.freightBroker#.'); return false;' style='color:##4322cc;text-decoration:underline;'>"
                    </cfif>
                    strHtml = strHtml + ui.item.name
                    strHtml = strHtml + "</a>"
                    strHtml = strHtml + "</b>"
                    strHtml = strHtml + "<br/>"
                    strHtml = strHtml + ""+ui.item.location+"<br/>"+ui.item.city+",&nbsp;"+ui.item.state+"&nbsp;"+ui.item.zip+"<br><br><a class='underline'>MC##:</a>"+ui.item.MCNumber+"&nbsp;&nbsp;<a class='underline'>DOT##:<a>"+ui.item.DOTNumber+"&nbsp;&nbsp;<a class='underline'>SCAC##:<a>"+ui.item.SCAC+""
                    strHtml = strHtml + "</label>"
                    strHtml = strHtml + "<div class='clear'></div>"
                    strHtml = strHtml + "<label>Contact</label>"
                    strHtml = strHtml + "<input data-carrID='"+ui.item.value+"' class='CarrierContactAuto' placeholder='type text here to display list' value='"+ui.item.ContactPerson+"'>";
                    strHtml = strHtml + "<input type='hidden' name='CarrierContactID' id='CarrierContactID' value=''>";
                    strHtml = strHtml + "<input style='width: 20px !important;height: 18px;padding: 0;' type='button' value='...' onclick='openViewCarrierContactPopup(this)'>";
                    strHtml = strHtml + "<div class='clear'></div>"
                    strHtml = strHtml + "<label>Email</label>"
                    strHtml = strHtml + "<input name='CarrierEmailID' data-carrID='"+ui.item.value+"' class='emailbox CarrEmail' value="+ui.item.email+">";
                    strHtml = strHtml + "<div class='clear'></div>"
                    strHtml = strHtml + "<label>Phone</label>"
                    strHtml = strHtml + "<input type='text' name='CarrierPhoneNo' id='CarrierPhoneNo' value='"+ui.item.phoneNo+"' class='inp70px' onchange='ParseUSNumber(this);'>"
                    strHtml = strHtml + "<input type='text' name='CarrierPhoneNoExt' id='CarrierPhoneNoExt' value='"+ui.item.phoneext+"' class='inp18px'>"
                    strHtml = strHtml + "<label class='label45px'>Fax</label>"
                    strHtml = strHtml + "<input type='text' name='CarrierFax' id='CarrierFax' value='"+ui.item.fax+"' class='inp70px' onchange='ParseUSNumber(this);'>"
                    strHtml = strHtml + "<input type='text' name='CarrierFaxExt' id='CarrierFaxExt' value='"+ui.item.faxext+"' class='inp18px'>"
                    strHtml = strHtml + "<div class='clear'></div>"
                    strHtml = strHtml + "<label>Toll Free</label>"
                    strHtml = strHtml + "<input type='text' name='CarrierTollFree' id='CarrierTollFree' value='"+ui.item.tollfree+"' class='inp70px' onchange='ParseUSNumber(this);'>"
                    strHtml = strHtml + "<input type='text' name='CarrierTollFreeExt' id='CarrierTollFreeExt' value='"+ui.item.tollfreeext+"' class='inp18px'>"
                    strHtml = strHtml + "<label class='label45px'>Cell</label>"
                    strHtml = strHtml + "<input type='text' name='CarrierCell' id='CarrierCell' value='"+ui.item.cell+"' class='inp70px' onchange='ParseUSNumber(this);'>"
                    strHtml = strHtml + "<input type='text' name='CarrierCellExt' id='CarrierCellExt' value='"+ui.item.cellphoneext+"' class='inp18px'>"
                    
                    if($.trim(ui.item.RemitName).length){
                        strHtml = strHtml + "<div class='clear'></div>";
                        strHtml = strHtml + '<label style="width: 102px !important;">Factoring Co.</label>';
                        strHtml = strHtml + '<label class="field-text disabledLoadInputs" style="width:273px !important">'+ui.item.RemitName+'</label>';
                    }

                    //strHtml = strHtml + "<label class='emailbox'>"+ui.item.email+"</label>";
                if(ui.item.status == 'INACTIVE'){
                    alert('#variables.freightBroker# is Inactive.');
                    chooseCarrier();
                    return false;
                }


                if(ui.item.iscarrier == 1 && ui.item.insuranceExpired == 'yes')
                {
                    if(! (#request.qSystemSetupOptions.AllowBooking#)){
                        alert("One or more of the Carrier's insurances has an expiration date prior to the final delivery of this load." );
                        $(this).val('');
                        return false;
                    }
                    else{
                        alert("One or more of the Carrier's insurances has an expiration date prior to the final delivery of this load." );
                    }
                    
                }

                <cfif ( structkeyexists(url,"loadid") and len(trim(url.loadid)) gt 1 )>
                    loadCarrierAutoSave('#url.loadid#',ui.item.value,0,'#session.companyid#');
                </cfif>
                
                document.getElementById("CarrierInfo").style.display = 'block';
                document.getElementById('choosCarrier').style.display = 'none';
                DisplayIntextField(ui.item.value,'#Application.dsn#');
                $('##CarrierInfo').html(strHtml);

                $('.CarrEmail').each(function(i, tag) {
                    var carrID = $( this ).data( "carrid" );
                    $(tag).autocomplete({
                        multiple: false,
                        width: 450,
                        scroll: true,
                        scrollHeight: 300,
                        cacheLength: 1,
                        highlight: false,
                        dataType: "json",
                        minLength:0,
                        autoFocus: true,
                        source: 'searchCarrierContactAutoFill.cfm?carrierID='+carrID,
                        select: function(e, ui) { 
                            $('##CarrierPhoneNo').val(ui.item.phoneno);
                            $('##CarrierPhoneNoExt').val(ui.item.phonenoext);
                            $('##CarrierFax').val(ui.item.fax);
                            $('##CarrierFaxExt').val(ui.item.faxext);
                            $('##CarrierTollFree').val(ui.item.tollfree);
                            $('##CarrierTollFreeExt').val(ui.item.tollfreeext);
                            $('##CarrierCell').val(ui.item.PersonMobileNo);
                            $('##CarrierCellExt').val(ui.item.MobileNoExt);
                        },
                        focus: function( event, ui ) {
                            $(this).val(ui.item.value);
                            return false;
                        },
                    }).focus(function() { 
                        $(this).keydown();
                    })
                    $(tag).data("ui-autocomplete")._renderItem = function(ul, item) {
                        return $( "<li><b><u>Email</u>:</b>"+item.email+"<br/><b><u>Contact</u>:</b> "+ item.ContactPerson+"&nbsp;&nbsp;&nbsp;<b><u>Phone</u>:</b> "+ item.phoneno+"<br/><b><u>cell</u>:</b>" + item.PersonMobileNo+"&nbsp;&nbsp;&nbsp;<b><u>Type</u>:</b> " + item.ContactType+"</li>" )
                    .appendTo( ul );
                    }
                })

                CarrierContactAutoComplete();
                DriverContactAutoComplete('');
                
                if($("##carrierDefaultCurrency").val().length){
                    $('##defaultCarrierCurrency option[value=' +$("##carrierDefaultCurrency").val()+']').prop('selected', true);
                }else{
                    $('##defaultCarrierCurrency option[value=' +$("##defaultSystemCurrency").val()+']').prop('selected', true);
                }               
                $('##defaultCarrierCurrency').trigger("change");
                getCarrierCommodityValue(ui.item.value,"unit","");              
                $('##carrier_id').data("limit", ui.item.loadLimit);
                var carrierId =$('##carrierID').val();

                if(ui.item.EquipmentID.trim() != "" && $("##equipment").val() ==""){
                    if(ui.item.eqActive.trim() == 1){
                        $("##equipment").val(ui.item.EquipmentID);
                        $("##equipment").trigger("change");
                        $("##equipment").closest('table').find("tr [rel='"+ui.item.EquipmentID+"']").click();
                    }
                    else{
                        alert('The default equipment assigned to this #variables.freightBroker# is inactive.');
                    }
                    
                }
                    
                if((ui.item.unitNumber != -1)){
                    if(ui.item.unitNumber.trim() != ""){
                        $("##truckNo").val(ui.item.unitNumber);
                    }
                    
                    $( "##equipment" ).unbind( "change" );
                    $("##equipment").change(function(){     
                        $("##truckNo").val($("##equipment option:selected").data("truck-number"));
                    });
                    $("##equipment").trigger("change");
                }else{
                    $( "##equipment" ).unbind( "change" );                  
                }
                $("##removeCarrierTag").show();
                $("##loadManualNo").trigger("onblur");
                if($.trim($( "##loadStatus option:selected" ).data('statustext')) == '0. QUOTE' || $.trim($( "##loadStatus option:selected" ).data('statustext')) == '1. ACTIVE'){
                    $("##loadStatus option").each(function () {
                        if ($.trim($(this).data('statustext')) == "2. BOOKED") {
                            $(this).attr("selected", "selected");
                            $("##posttoTranscore").attr('checked', false);
                            $("##posttoloadboard").attr('checked', false);
                            $("##posttoITS").attr('checked', false);
                            $("##PostTo123LoadBoard").attr('checked', false);
                            $("##posttoDirectFreight").attr('checked', false);
                            getCutomerForm($('##cutomerIdAutoValueContainer').val(),'#application.DSN#','#session.URLToken#','Dispatch');

                        }
                    });
                    changeValueStatus();
                    <cfif request.qSystemSetupOptions.StatusUpdateEmailOption EQ 1 and structkeyexists(url,"loadid") and len(trim(url.loadid)) gt 1>
                        var sendUpdMail = $("##loadStatus option:selected").data("send-update");
                        if(sendUpdMail==1){
                            var selStatusText = $.trim($( "##loadStatus option:selected" ).text());
                            newwindow=window.open('index.cfm?event=loadMail&type=LocationUpdates&LoadID=#url.LoadID#&LoadStatus='+selStatusText+'&#session.URLToken#','Map','height=600,width=850');
                            if (window.focus) {
                                newwindow.focus()
                            }
                        }
                    </cfif>
                }

                $('##CarrierRatePerMile').val(ui.item.RatePerMile);
                carrierRatePerMileChanged();
                return false;
            }
        });
        $(tag).data("ui-autocomplete")._renderItem = function(ul, item) {
            if(item.risk_assessment != ""){
                var url = "<a target='_blank' href='"+item.link+"'><img src='"+item.risk_assessment+"' alt='Risk Assement Icon'></a>";
            }else{
                var url = "";
            }

            return $( "<li>"+item.name+"&nbsp;&nbsp;&nbsp;<b><u>Status</u>:</b> "+ item.status+"&nbsp;&nbsp;&nbsp;"+url+"<br/><b><u>City</u>:</b> "+ item.city+"&nbsp;&nbsp;&nbsp;<b><u>State</u>:</b>" + item.state+"&nbsp;&nbsp;&nbsp;<b><u>Zip</u>:</b> " + item.zip+"&nbsp;&nbsp;&nbsp;<b><u>Insurance Expiry</u>:</b> " + item.InsExpDate+"</li>" )
                    .appendTo( ul );
        }
    });

    $('##selectedCarrierValue2_1').each(function(i, tag) {
        $(tag).autocomplete({
            multiple: false,
            width: 450,
            scroll: true,
            scrollHeight: 300,
            cacheLength: 1,
            highlight: false,
            dataType: "json",
            autoFocus: true,
            search: function(event, ui){$(this).autocomplete('option', 'source', 'searchCarrierAutoFill.cfm?queryType=getCustomers&iscarrier=0&companyid=#session.companyid#&loadid=#loadid#&pickupdate=' + $("##shipperPickupDate"+(($(this).data("stop") == 1) ? "" : $(this).data("stop"))).val() + '&deliverydate=' + $("##consigneePickupDate"+(($(this).data("stop") == 1) ? "" : $(this).data("stop"))).val())},
            source: 'searchCarrierAutoFill.cfm?queryType=getCustomers&iscarrier=0&companyid=#session.companyid#&loadid=#loadid#&pickupdate=',
            select: function(e, ui) { 
                if(ui.item.isoverlimit == 'yes'){
                    alert("#ReReplace(variables.freightBroker,"\b(\w)","\u\1")# has reached their daily limit for this pickup date.");
                    return false;
                }
                $(this).val(ui.item.name);
                $('##selectedCarrierValueValueContainer2_1').val(ui.item.value);
                <cfif ( structkeyexists(url,"loadid") and len(trim(url.loadid)) gt 1 )>
                    //loadCarrierAutoSave('#url.loadid#',ui.item.value,0,'#session.companyid#');
                </cfif>
                var strHtml = "<div class='clear'></div>"
                    strHtml = strHtml + "<input name='carrierID2_1' id='carrierID2_1' type='hidden' value='"+ui.item.value+"' /><input name='carrierDefaultCurrency2_1' id='carrierDefaultCurrency2_1' type='hidden' value='"+ui.item.currency+"' />"
                    strHtml = strHtml + "<div class='clear'></div>"
                    if(ui.item.risk_assessment != ""){
                        strHtml = strHtml + "<label><a target='_blank' href='"+ui.item.link+"'><img src='"+ui.item.risk_assessment+"' alt='Risk Assement Icon'></a></label>"
                    }else{
                        strHtml = strHtml + "<label>&nbsp;</label>"
                    }
                    strHtml = strHtml + "<label class='field-textarea carrier-field-textarea'>"
                    strHtml = strHtml + "<b>"

                    <cfset Iscarrier = "">
                    <cfif structkeyexists(request,"qLoads") AND structkeyexists(request.qLoads,"Iscarrier") AND request.qLoads.Iscarrier NEQ "" >
                         <cfset Iscarrier = "&Iscarrier=#request.qLoads.Iscarrier#">
                    </cfif>


                    <cfif ListContains(session.rightsList,'bookCarrierToLoad',',')>
                        <cfif request.qSystemSetupOptions.FreightBroker EQ 1>
                            strHtml = strHtml + "<a href='index.cfm?event=addcarrier&#Iscarrier#&carrierid="+ui.item.value+"' style='color:##4322cc;text-decoration:underline;'>"
                        <cfelseif request.qSystemSetupOptions.FreightBroker EQ 2>
                            if(ui.item.iscarrier == 1){
                                strHtml = strHtml + "<a href='index.cfm?event=addcarrier&Iscarrier=1&carrierid="+ui.item.value+"' style='color:##4322cc;text-decoration:underline;'>"
                            }else{
                                strHtml = strHtml + "<a href='index.cfm?event=adddriver&&Iscarrier=0&carrierid="+ui.item.value+"' style='color:##4322cc;text-decoration:underline;'>"
                            }
                        <cfelse>
                              strHtml = strHtml + "<a href='index.cfm?event=adddriver&#Iscarrier#&carrierid="+ui.item.value+"' style='color:##4322cc;text-decoration:underline;'>"
                        </cfif>
                    <cfelse>
                        strHtml = strHtml + "<a href='javascript: alert('Sorry!! You don\'t have rights to add/edit #variables.freightBroker#.'); return false;' style='color:##4322cc;text-decoration:underline;'>"
                    </cfif>
                    strHtml = strHtml + ui.item.name
                    strHtml = strHtml + "</a>"
                    strHtml = strHtml + "</b>"
                    strHtml = strHtml + "<br/>"
                    strHtml = strHtml + ""+ui.item.location+"<br/>"+ui.item.city+",&nbsp;"+ui.item.state+"&nbsp;"+ui.item.zip+"<br><br><a class='underline'>MC##:</a>"+ui.item.MCNumber+"&nbsp;&nbsp;<a class='underline'>DOT##:<a>"+ui.item.DOTNumber+"&nbsp;&nbsp;<a class='underline'>SCAC##:<a>"+ui.item.SCAC+""
                    strHtml = strHtml + "</label>"
                    strHtml = strHtml + "<div class='clear'></div>"

                    strHtml = strHtml + "<label>Contact</label>"
                    strHtml = strHtml + "<input data-carrID='"+ui.item.value+"' class='CarrierContactAuto' value='' placeholder='type text here to display list'>";
                    strHtml = strHtml + "<input type='hidden' name='CarrierContactID2_1' id='CarrierContactID2_1' value=''>";
                    strHtml = strHtml + "<div class='clear'></div>"
                    strHtml = strHtml + "<label>Email</label>"
                    strHtml = strHtml + "<input name='CarrierEmailID2_1' data-carrID='"+ui.item.value+"' class='emailbox CarrEmail' value="+ui.item.email+">";
                    strHtml = strHtml + "<div class='clear'></div>"
                    strHtml = strHtml + "<label>Phone</label>"
                    strHtml = strHtml + "<input type='text' name='CarrierPhoneNo2_1' id='CarrierPhoneNo2_1' value='"+ui.item.phoneNo+"' class='inp70px' onchange='ParseUSNumber(this);'>"
                    strHtml = strHtml + "<input type='text' name='CarrierPhoneNoExt2_1' id='CarrierPhoneNoExt2_1' value='"+ui.item.phoneext+"' class='inp18px'>"
                    strHtml = strHtml + "<label class='label45px'>Fax</label>"
                    strHtml = strHtml + "<input type='text' name='CarrierFax2_1' id='CarrierFax2_1' value='"+ui.item.fax+"' class='inp70px' onchange='ParseUSNumber(this);'>"
                    strHtml = strHtml + "<input type='text' name='CarrierFaxExt2_1' id='CarrierFaxExt2_1' value='"+ui.item.faxext+"' class='inp18px'>"
                    strHtml = strHtml + "<div class='clear'></div>"
                    strHtml = strHtml + "<label>Toll Free</label>"
                    strHtml = strHtml + "<input type='text' name='CarrierTollFree2_1' id='CarrierTollFree2_1' value='"+ui.item.tollfree+"' class='inp70px' onchange='ParseUSNumber(this);'>"
                    strHtml = strHtml + "<input type='text' name='CarrierTollFreeExt2_1' id='CarrierTollFreeExt2_1' value='"+ui.item.tollfreeext+"' class='inp18px'>"
                    strHtml = strHtml + "<label class='label45px'>Cell</label>"
                    strHtml = strHtml + "<input type='text' name='CarrierCell2_1' id='CarrierCell2_1' value='"+ui.item.cell+"' class='inp70px' onchange='ParseUSNumber(this);'>"
                    strHtml = strHtml + "<input type='text' name='CarrierCellExt2_1' id='CarrierCellExt2_1' value='"+ui.item.cellphoneext+"' class='inp18px'>"
                    
                if(ui.item.status == 'INACTIVE'){
                    alert('#variables.freightBroker# is Inactive.');
                    //chooseCarrier();
                    return false;
                }

                if(ui.item.iscarrier == 1 && ui.item.insuranceExpired == 'yes')
                {
                    if(! (#request.qSystemSetupOptions.AllowBooking#)){
                        alert("One or more of the Carrier's insurances has an expiration date prior to the final delivery of this load." );
                        $(this).val('');
                        return false;
                    }
                    else{
                        alert("One or more of the Carrier's insurances has an expiration date prior to the final delivery of this load." );
                    }
                }
                document.getElementById("CarrierInfo2_1").style.display = 'block';
                document.getElementById('choosCarrier2_1').style.display = 'none';
                //DisplayIntextField(ui.item.value,'#Application.dsn#');
                $('##CarrierInfo2_1').html(strHtml);
                CarrierContactAutoComplete();
                $('.CarrEmail').each(function(i, tag) {
                    var carrID = $( this ).data( "carrid" );
                    $(tag).autocomplete({
                        multiple: false,
                        width: 450,
                        scroll: true,
                        scrollHeight: 300,
                        cacheLength: 1,
                        highlight: false,
                        dataType: "json",
                        minLength:0,
                        autoFocus: true,
                        source: 'searchCarrierContactAutoFill.cfm?carrierID='+carrID,
                        select: function(e, ui) { 
                            $('##CarrierPhoneNo2_1').val(ui.item.phoneno);
                            $('##CarrierPhoneNoExt2_1').val(ui.item.phonenoext);
                            $('##CarrierFax2_1').val(ui.item.fax);
                            $('##CarrierFaxExt2_1').val(ui.item.faxext);
                            $('##CarrierTollFree2_1').val(ui.item.tollfree);
                            $('##CarrierTollFreeExt2_1').val(ui.item.tollfreeext);
                            $('##CarrierCell2_1').val(ui.item.PersonMobileNo);
                            $('##CarrierCellExt2_1').val(ui.item.MobileNoExt);
                        },
                    }).focus(function() { 
                        $(this).keydown();
                    })
                    $(tag).data("ui-autocomplete")._renderItem = function(ul, item) {
                        return $( "<li><b><u>Email</u>:</b>"+item.email+"<br/><b><u>Contact</u>:</b> "+ item.ContactPerson+"&nbsp;&nbsp;&nbsp;<b><u>Phone</u>:</b> "+ item.phoneno+"<br/><b><u>cell</u>:</b>" + item.PersonMobileNo+"&nbsp;&nbsp;&nbsp;<b><u>Type</u>:</b> " + item.ContactType+"</li>" )
                    .appendTo( ul );
                    }
                })
                return false;
            }
        });
        $(tag).data("ui-autocomplete")._renderItem = function(ul, item) {
            if(item.risk_assessment != ""){
                var url = "<a target='_blank' href='"+item.link+"'><img src='"+item.risk_assessment+"' alt='Risk Assement Icon'></a>";
            }else{
                var url = "";
            }

            return $( "<li>"+item.name+"&nbsp;&nbsp;&nbsp;<b><u>Status</u>:</b> "+ item.status+"&nbsp;&nbsp;&nbsp;"+url+"<br/><b><u>City</u>:</b> "+ item.city+"&nbsp;&nbsp;&nbsp;<b><u>State</u>:</b>" + item.state+"&nbsp;&nbsp;&nbsp;<b><u>Zip</u>:</b> " + item.zip+"&nbsp;&nbsp;&nbsp;<b><u>Insurance Expiry</u>:</b> " + item.InsExpDate+"</li>" )
                    .appendTo( ul );
        }
    });
    
    $('##selectedCarrierValue3_1').each(function(i, tag) {
        $(tag).autocomplete({
            multiple: false,
            width: 450,
            scroll: true,
            scrollHeight: 300,
            cacheLength: 1,
            highlight: false,
            dataType: "json",
            autoFocus: true,
            search: function(event, ui){$(this).autocomplete('option', 'source', 'searchCarrierAutoFill.cfm?queryType=getCustomers&iscarrier=0&companyid=#session.companyid#&loadid=#loadid#&pickupdate=' + $("##shipperPickupDate"+(($(this).data("stop") == 1) ? "" : $(this).data("stop"))).val() + '&deliverydate=' + $("##consigneePickupDate"+(($(this).data("stop") == 1) ? "" : $(this).data("stop"))).val())},
            source: 'searchCarrierAutoFill.cfm?queryType=getCustomers&iscarrier=0&companyid=#session.companyid#&loadid=#loadid#&pickupdate=',
            select: function(e, ui) { 
                if(ui.item.isoverlimit == 'yes'){
                    alert("#ReReplace(variables.freightBroker,"\b(\w)","\u\1")# has reached their daily limit for this pickup date.");
                    return false;
                }
                $(this).val(ui.item.name);
                $('selectedCarrierValueValueContainer3_1').val(ui.item.value);
                <cfif ( structkeyexists(url,"loadid") and len(trim(url.loadid)) gt 1 )>
                    //loadCarrierAutoSave('#url.loadid#',ui.item.value,0,'#session.companyid#');
                </cfif>
                var strHtml = "<div class='clear'></div>"
                    strHtml = strHtml + "<input name='carrierID3_1' id='carrierID3_1' type='hidden' value='"+ui.item.value+"' /><input name='carrierDefaultCurrency3_1' id='carrierDefaultCurrency3_1' type='hidden' value='"+ui.item.currency+"' />"
                    strHtml = strHtml + "<div class='clear'></div>"
                    if(ui.item.risk_assessment != ""){
                        strHtml = strHtml + "<label><a target='_blank' href='"+ui.item.link+"'><img src='"+ui.item.risk_assessment+"' alt='Risk Assement Icon'></a></label>"
                    }else{
                        strHtml = strHtml + "<label>&nbsp;</label>"
                    }
                    strHtml = strHtml + "<label class='field-textarea carrier-field-textarea'>"
                    strHtml = strHtml + "<b>"

                    <cfset Iscarrier = "">
                    <cfif structkeyexists(request,"qLoads") AND structkeyexists(request.qLoads,"Iscarrier") AND request.qLoads.Iscarrier NEQ "" >
                         <cfset Iscarrier = "&Iscarrier=#request.qLoads.Iscarrier#">
                    </cfif>


                    <cfif ListContains(session.rightsList,'bookCarrierToLoad',',')>
                        <cfif request.qSystemSetupOptions.FreightBroker EQ 1>
                            strHtml = strHtml + "<a href='index.cfm?event=addcarrier&#Iscarrier#&carrierid="+ui.item.value+"' style='color:##4322cc;text-decoration:underline;'>"
                        <cfelseif request.qSystemSetupOptions.FreightBroker EQ 2>
                            if(ui.item.iscarrier == 1){
                                strHtml = strHtml + "<a href='index.cfm?event=addcarrier&Iscarrier=1&carrierid="+ui.item.value+"' style='color:##4322cc;text-decoration:underline;'>"
                            }else{
                                strHtml = strHtml + "<a href='index.cfm?event=adddriver&&Iscarrier=0&carrierid="+ui.item.value+"' style='color:##4322cc;text-decoration:underline;'>"
                            }
                        <cfelse>
                              strHtml = strHtml + "<a href='index.cfm?event=adddriver&#Iscarrier#&carrierid="+ui.item.value+"' style='color:##4322cc;text-decoration:underline;'>"
                        </cfif>
                    <cfelse>
                        strHtml = strHtml + "<a href='javascript: alert('Sorry!! You don\'t have rights to add/edit #variables.freightBroker#.'); return false;' style='color:##4322cc;text-decoration:underline;'>"
                    </cfif>
                    strHtml = strHtml + ui.item.name
                    strHtml = strHtml + "</a>"
                    strHtml = strHtml + "</b>"
                    strHtml = strHtml + "<br/>"
                    strHtml = strHtml + ""+ui.item.location+"<br/>"+ui.item.city+",&nbsp;"+ui.item.state+"&nbsp;"+ui.item.zip+"<br><br><a class='underline'>MC##:</a>"+ui.item.MCNumber+"&nbsp;&nbsp;<a class='underline'>DOT##:<a>"+ui.item.DOTNumber+"&nbsp;&nbsp;<a class='underline'>SCAC##:<a>"+ui.item.SCAC+""
                    strHtml = strHtml + "</label>"
                    strHtml = strHtml + "</select>"
                    strHtml = strHtml + "<div class='clear'></div>"
                    strHtml = strHtml + "<label>Contact</label>"
                    strHtml = strHtml + "<input data-carrID='"+ui.item.value+"' class='CarrierContactAuto' value='' placeholder='type text here to display list'>";
                    strHtml = strHtml + "<input type='hidden' name='CarrierContactID3_1' id='CarrierContactID3_1' value=''>";
                    strHtml = strHtml + "<div class='clear'></div>"
                    strHtml = strHtml + "<label>Email</label>"
                    strHtml = strHtml + "<input name='CarrierEmailID3_1' id='CarrierEmailID3_1' data-carrID='"+ui.item.value+"' class='emailbox CarrEmail' value="+ui.item.email+">";
                    strHtml = strHtml + "<div class='clear'></div>"
                    strHtml = strHtml + "<label>Phone</label>"
                    strHtml = strHtml + "<input type='text' name='CarrierPhoneNo3_1' id='CarrierPhoneNo3_1' value='"+ui.item.phoneNo+"' class='inp70px' onchange='ParseUSNumber(this);'>"
                    strHtml = strHtml + "<input type='text' name='CarrierPhoneNoExt3_1' id='CarrierPhoneNoExt3_1' value='"+ui.item.phoneext+"' class='inp18px'>"
                    strHtml = strHtml + "<label class='label45px'>Fax</label>"
                    strHtml = strHtml + "<input type='text' name='CarrierFax3_1' id='CarrierFax3_1' value='"+ui.item.fax+"' class='inp70px' onchange='ParseUSNumber(this);'>"
                    strHtml = strHtml + "<input type='text' name='CarrierFaxExt3_1' id='CarrierFaxExt3_1' value='"+ui.item.faxext+"' class='inp18px'>"
                    strHtml = strHtml + "<div class='clear'></div>"
                    strHtml = strHtml + "<label>Toll Free</label>"
                    strHtml = strHtml + "<input type='text' name='CarrierTollFree3_1' id='CarrierTollFree3_1' value='"+ui.item.tollfree+"' class='inp70px' onchange='ParseUSNumber(this);'>"
                    strHtml = strHtml + "<input type='text' name='CarrierTollFreeExt3_1' id='CarrierTollFreeExt3_1' value='"+ui.item.tollfreeext+"' class='inp18px'>"
                    strHtml = strHtml + "<label class='label45px'>Cell</label>"
                    strHtml = strHtml + "<input type='text' name='CarrierCell3_1' id='CarrierCell3_1' value='"+ui.item.cell+"' class='inp70px' onchange='ParseUSNumber(this);'>"
                    strHtml = strHtml + "<input type='text' name='CarrierCellExt3_1' id='CarrierCellExt3_1' value='"+ui.item.cellphoneext+"' class='inp18px'>"

                if(ui.item.status == 'INACTIVE'){
                    alert('#variables.freightBroker# is Inactive.');
                    //chooseCarrier();
                    return false;
                }

                if(ui.item.iscarrier == 1 && ui.item.insuranceExpired == 'yes')
                {
                    if(! (#request.qSystemSetupOptions.AllowBooking#)){
                        alert("One or more of the Carrier's insurances has an expiration date prior to the final delivery of this load." );
                        $(this).val('');
                        return false;
                    }
                    else{
                        alert("One or more of the Carrier's insurances has an expiration date prior to the final delivery of this load." );
                    }
                }
                document.getElementById("CarrierInfo3_1").style.display = 'block';
                document.getElementById('choosCarrier3_1').style.display = 'none';
                //DisplayIntextField(ui.item.value,'#Application.dsn#');
                $('##CarrierInfo3_1').html(strHtml);
                CarrierContactAutoComplete();
                $('.CarrEmail').each(function(i, tag) {
                    var carrID = $( this ).data( "carrid" );
                    $(tag).autocomplete({
                        multiple: false,
                        width: 450,
                        scroll: true,
                        scrollHeight: 300,
                        cacheLength: 1,
                        highlight: false,
                        dataType: "json",
                        minLength:0,
                        autoFocus: true,
                        source: 'searchCarrierContactAutoFill.cfm?carrierID='+carrID,
                        select: function(e, ui) { 
                            $('##CarrierPhoneNo3_1').val(ui.item.phoneno);
                            $('##CarrierPhoneNoExt3_1').val(ui.item.phonenoext);
                            $('##CarrierFax3_1').val(ui.item.fax);
                            $('##CarrierFaxExt3_1').val(ui.item.faxext);
                            $('##CarrierTollFree3_1').val(ui.item.tollfree);
                            $('##CarrierTollFreeExt3_1').val(ui.item.tollfreeext);
                            $('##CarrierCell3_1').val(ui.item.PersonMobileNo);
                            $('##CarrierCellExt3_1').val(ui.item.MobileNoExt);
                        },
                    }).focus(function() { 
                        $(this).keydown();
                    })
                    $(tag).data("ui-autocomplete")._renderItem = function(ul, item) {
                        return $( "<li><b><u>Email</u>:</b>"+item.email+"<br/><b><u>Contact</u>:</b> "+ item.ContactPerson+"&nbsp;&nbsp;&nbsp;<b><u>Phone</u>:</b> "+ item.phoneno+"<br/><b><u>cell</u>:</b>" + item.PersonMobileNo+"&nbsp;&nbsp;&nbsp;<b><u>Type</u>:</b> " + item.ContactType+"</li>" )
                    .appendTo( ul );
                    }
                })
                return false;
            }
        });
        $(tag).data("ui-autocomplete")._renderItem = function(ul, item) {
            if(item.risk_assessment != ""){
                var url = "<a target='_blank' href='"+item.link+"'><img src='"+item.risk_assessment+"' alt='Risk Assement Icon'></a>";
            }else{
                var url = "";
            }

            return $( "<li>"+item.name+"&nbsp;&nbsp;&nbsp;<b><u>Status</u>:</b> "+ item.status+"&nbsp;&nbsp;&nbsp;"+url+"<br/><b><u>City</u>:</b> "+ item.city+"&nbsp;&nbsp;&nbsp;<b><u>State</u>:</b>" + item.state+"&nbsp;&nbsp;&nbsp;<b><u>Zip</u>:</b> " + item.zip+"&nbsp;&nbsp;&nbsp;<b><u>Insurance Expiry</u>:</b> " + item.InsExpDate+"</li>" )
                    .appendTo( ul );
        }
    });

    $("##loadStatus").change(function () {
        var statusVal = $(this).val();
        var defaultStatus = $("##qLoadDefaultSystemStatus").val();
        if(statusVal == defaultStatus){
            $("##BillDate").focus();
        }else{
            if($("##BillDate_Static").val().length){
                $("##BillDate").val($("##BillDate_Static").val());
            }
        }
    }).change();
    <!--- BEGIN: Uncheck Post Everywhere? and Post Transcore 360? when choosing load status other than Active Date:20 Sep 2013  --->
    $("##loadStatus").change(function () {
        
        if(!($.trim($( "##loadStatus option:selected" ).data('statustext')) == '1. ACTIVE' || $("##loadStatus").val() == ''))
        {

            $("##posttoTranscore").attr('checked', false);
            $("##posttoloadboard").attr('checked', false);
            $("##posttoITS").attr('checked', false);
            $("##PostTo123LoadBoard").attr('checked', false);
            $("##posttoDirectFreight").attr('checked', false);
        }


        if ($.trim($( "##loadStatus option:selected" ).data('statustext')) == '4. LOADED/UNLOADED'){
            $("##shipperConsignee > option").each(function() {
            if($(this).attr('data-code') == '1S'){
                $('select[id^="shipperConsignee"] option[data-code="1S"]').prop('selected', true);                
            }
            else{
                $('option:selected', this).attr("selected","");
            }
        });
        }
        if ($.trim($( "##loadStatus option:selected" ).data('statustext')) == '4.1 ARRIVED'){
            $("##shipperConsignee > option").each(function() {
            if($(this).attr('data-code') == '1C'){
                $('select[id^="shipperConsignee"] option[data-code="1C"]').prop('selected', true);                
            }
            else{
                $('option:selected', this).attr("selected","");
            }
        });
        }
        
        if ($.trim($( "##loadStatus option:selected" ).data('statustext')) == '5. DELIVERED'){
            $("##shipperConsignee > option").each(function() {
            if($(this).attr('data-code') == '1C'){
                $('select[id^="shipperConsignee"] option[data-code="1C"]').prop('selected', true);                
            }
            else{
                $('option:selected', this).attr("selected","");
            }
        });
        }
        <cfif request.qSystemSetupOptions.StatusUpdateEmailOption EQ 1 and structkeyexists(url,"loadid") and len(trim(url.loadid)) gt 1>
            var sendUpdMail = $("##loadStatus option:selected").data("send-update");
            if(sendUpdMail==1){
                var selStatusText = $.trim($( "##loadStatus option:selected" ).text());
                newwindow=window.open('index.cfm?event=loadMail&type=LocationUpdates&LoadID=#url.LoadID#&LoadStatus='+selStatusText+'&#session.URLToken#','Map','height=600,width=850');
                if (window.focus) {
                    newwindow.focus()
                }
            }
        </cfif>
        
    })
    <!--- END: Uncheck Post Everywhere? and Post Transcore 360? when choosing load status other than Active Date:20 Sep 2013  --->
    $('.userOnchageUpdate').focus(function() {
        $('input.userOnchageUpdate').parent().find('span.iconediting').remove();
        $( this ).after( '<span style="float:left;" class="iconediting">&##9998;</span>' );
    });
    $('.userOnchageUpdate').blur(function() {
        $('input.userOnchageUpdate').parent().find('span.iconediting').remove();
    });

    $('##dispatchNotes').focus(function() {
       $('span.iconediting1').remove();
        $('.dispatch_note' ).after( '<span style="float:left;" class="iconediting1">&##9998;</span>' );
        return false;
    });
    $('##dispatchNotes').blur(function() {
        $('span.iconediting1').remove();
    });

    $('##dispatchNotes').change(function() {
        var stopNumber   = $( this ).attr( "data-stopNumber" );
        var loadid             = $( this ).attr( "data-loadid" );
        var dispatchNote = $( this ).val().trim();
        if(dispatchNote.length >  0){
             $.ajax({
                    type    : 'POST',
                    url     : "../gateways/loadgateway.cfc?method=updateLoadDispatchNote",
                    data    : {loadid : loadid,  dispatchNote : dispatchNote,dsn:<cfoutput>"#application.dsn#"</cfoutput>},
                    success :function(data){

                    }
                });
            }
    });


    $('.userOnchageUpdate').change(function() {
        var self = this;
        var stopNumber = $( this ).attr( "data-stopNumber" );
        var loadid = $( this ).attr( "data-loadid" );
        var userDefname = $(this).attr('data-inputname');
        var userDefValue = $(this).val();

        if ( typeof stopNumber == 'undefined'){
            stopNumber = '';
        }
        var getloadstopid = 'nextLoadStopId'+stopNumber;
        var loadStopId = $("input[name="+getloadstopid+"]").val();

         $.ajax({
            type    : 'POST',
            url     : "../gateways/loadgateway.cfc?method=updateLoadUserDef",
            data    : {loadid : loadid, loadstopid : loadStopId, fieldname : userDefname, fieldValue : userDefValue,dsn:<cfoutput>"#application.dsn#"</cfoutput>},
            success :function(data){
            }
        });
    });
    
    var SpokeToSourceJSON = [
        {label:'DISPATCH',value:'DISPATCH'},
        {label:'DRIVER',value:'DRIVER'},
        {label:'LEFT MESSAGE',value:'LEFT MESSAGE'},
        {label:'NO ANSWER',value:'NO ANSWER'},
        {label:'OTHER',value:'OTHER'},
        ]
    $('##dispatchNotesSpokeTo').autocomplete({
        source: SpokeToSourceJSON,
        minLength: 0,
        focus: function( event, ui ) {
            $(this).val( ui.item.value );
        },
        select: function(e, ui) {
            $(this).val( ui.item.value );
            $( this ).trigger( "change" );
            return false;
        }  
    }).focus(function() { $(this).keydown(); });


    $("##dispatchNotesCurrLocation").each(function(i, tag) {
        $(tag).autocomplete({
            multiple: false,
            width: 400,
            scroll: true,
            scrollHeight: 300,
            cacheLength: 1,
            highlight: false,
            dataType: "json",
            autoFocus: true,
            source: 'searchCustomersAutoFill.cfm?queryType=getZipCityState&CompanyID=#session.CompanyID#',
            select: function(e, ui) {
                if(ui.item.showZip){
                    $(this).val(ui.item.city+", "+ui.item.state+" "+ui.item.zip);
                }
                else{
                    $(this).val(ui.item.city+", "+ui.item.state);
                }
                $( this ).trigger( "change" );
                return false;
            },
            focus: function(e, ui) {
                if(ui.item.showZip){
                    $(this).val(ui.item.city+", "+ui.item.state+" "+ui.item.zip);
                }
                else{
                    $(this).val(ui.item.city+", "+ui.item.state);
                }
                return false;
            }
        });
        $(tag).data("ui-autocomplete")._renderItem = function(ul, item) {
            if(item.showZip){
                return $( "<li>"+item.city+", "+item.state+" "+item.zip+"</li>").appendTo( ul );
            }
            else{
                return $( "<li>"+item.city+", "+item.state+"</li>").appendTo( ul );
            }
        }
    });

    $('.displayDispatchNotesPopup').on( 'keyup', function( e ) {
        if( e.which == 9 ) {
            var loadid = $( this ).attr( "data-loadid" );
        if(!$(this).hasClass('applynotesPl')){
            $(".dispatchNotesPopup").css("display","block");
            $(".overlay").css("display","block");
            $(".dispatchPopupNotes").focus();
            $(".noteAdd").click(function(){
                var quote = $(".dispatchPopupNotes").val();
                if (quote != ''){
                    $(".displayDispatchNotesPopup").prepend(quote+'\n');
                    $(".dispatchPopupNotes").val('');
                    $( ".closModal" ).trigger( "click" );
                    var  dispatchNote =  $('.displayDispatchNotesPopup').val().trim();
                    $.ajax({
                        type    : 'POST',
                        url     : "../gateways/loadgateway.cfc?method=updateLoadDispatchNote",
                        data    : {loadid : loadid,  dispatchNote : dispatchNote,dsn:<cfoutput>"#application.dsn#"</cfoutput>},
                        success :function(data){

                        }
                    });
                }
            });
        } else {
            var username=$( ".displayDispatchNotesPopup" ).attr( "data-username" );

            var currentDate = new Date();
            var currentDay = currentDate.getDate();
            var currentMonth = currentDate.getMonth() + 1;
            var currentYear = currentDate.getFullYear();
            var hours = currentDate.getHours();
            var minutes = currentDate.getMinutes();

            var currentDate = currentMonth + "/" + currentDay + "/" + currentYear;
            var ampm = hours >= 12 ? 'PM' : 'AM';
            hours = hours % 12;
            hours = hours ? hours : 12; // the hour '0' should be '12'
            minutes = minutes < 10 ? '0'+minutes : minutes;
            var strTime = hours + ':' + minutes + ' ' + ampm;
            var dateTime = currentDate+' '+strTime

            var dispatchAutoTimeStamp = dateTime+' - '+username+' > ';

            $(".dispatchNotesPopup").css("display","block");
            $(".overlay").css("display","block");
            $(".dispatchPopupNotes").focus();
            $(".noteAdd").on("click",function() {
                var quote = $(".dispatchPopupNotes").val();
                if (quote != ''){
                    quote = dispatchAutoTimeStamp+' '+quote;
                    $(".displayDispatchNotesPopup").prepend(quote+'\n');
                    $(".dispatchPopupNotes").val('');
                    $( ".closModal" ).trigger( "click" );
                    var  dispatchNote =  $('.displayDispatchNotesPopup').val().trim();
                     $.ajax({
                        type    : 'POST',
                        url     : "../gateways/loadgateway.cfc?method=updateLoadDispatchNote",
                        data    : {loadid : loadid,  dispatchNote : dispatchNote,dsn:<cfoutput>"#application.dsn#"</cfoutput>},
                        success :function(data){

                        }
                    });
                }
            });
        }
        }
    } );

    $('.displayDispatchNotesPopup').click(function() { 
        var loadid = $( this ).attr( "data-loadid" );
        if(!$(this).hasClass('applynotesPl')){
            $(".dispatchNotesPopup").css("display","block");
            $(".overlay").css("display","block");
            $(".dispatchPopupNotes").focus();
            $(".noteAdd").click(function(){
                var quote = $(".dispatchPopupNotes").val();
                var spoketo = $.trim($('##dispatchNotesSpokeTo').val());
                var currLoc = $.trim($('##dispatchNotesCurrLocation').val());
                var eta = $.trim($('##dispatchNotesETA').val());
                var stopNo = $.trim($('##dispatchNotesETAStopNo option:selected').text());
                if(quote.length && (spoketo.length || currLoc.length || eta.length)){
                    quote = quote + '\n';
                }
                if(spoketo.length){
                    quote = quote + 'SPOKE TO: '+spoketo+', ';
                }
                if(currLoc.length){
                    quote = quote + 'LOC: '+currLoc+', ';
                }
                if(eta.length){
                    quote = quote + 'ETA: '+eta+', ';
                }
                if(stopNo.length && (spoketo.length || currLoc.length || eta.length)){
                    quote = quote + 'STOP: '+stopNo;
                }

                if (quote != ''){
                    $(".displayDispatchNotesPopup").prepend(quote+'\n');
                    $(".dispatchPopupNotes").val('');
                    $("##dispatchNotesSpokeTo").val('');
                    $("##dispatchNotesCurrLocation").val('');
                    $("##dispatchNotesETA").val('');
                    $("##dispatchNotesETAStopNo").val('1S');
                    $( ".closModal" ).trigger( "click" );
                    var  dispatchNote =  $('.displayDispatchNotesPopup').val().trim();
                    $.ajax({
                        type    : 'POST',
                        url     : "../gateways/loadgateway.cfc?method=updateLoadDispatchNote",
                        data    : {loadid : loadid,  dispatchNote : dispatchNote,dsn:<cfoutput>"#application.dsn#"</cfoutput>},
                        success :function(data){

                        }
                    });
                }
            });
        } else {
            var username=$( ".displayDispatchNotesPopup" ).attr( "data-username" );

            $(".dispatchNotesPopup").css("display","block");
            $(".overlay").css("display","block");
            $(".dispatchPopupNotes").focus();
            $(".noteAdd").on("click",function() {
                var quote = $(".dispatchPopupNotes").val();
                var spoketo = $.trim($('##dispatchNotesSpokeTo').val());
                var currLoc = $.trim($('##dispatchNotesCurrLocation').val());
                var eta = $.trim($('##dispatchNotesETA').val());
                var stopNo = $.trim($('##dispatchNotesETAStopNo option:selected').text());
                
                if(quote.length && (spoketo.length || currLoc.length || eta.length)){
                    quote = quote + '\n';
                }

                if(spoketo.length){
                    quote = quote + 'SPOKE TO: '+spoketo+', ';
                }
                if(currLoc.length){
                    quote = quote + 'LOC: '+currLoc+', ';
                }
                if(eta.length){
                    quote = quote + 'ETA: '+eta+', ';
                }
                if(stopNo.length && (spoketo.length || currLoc.length || eta.length)){
                    quote = quote + 'STOP: '+stopNo;
                }
                if (quote != ''){
                    var currentDate = new Date();
                    var currentDay = currentDate.getDate();
                    var currentMonth = currentDate.getMonth() + 1;
                    var currentYear = currentDate.getFullYear();
                    var hours = currentDate.getHours();
                    var minutes = currentDate.getMinutes();
                    var currentDate = currentMonth + "/" + currentDay + "/" + currentYear;
                    var ampm = hours >= 12 ? 'PM' : 'AM';
                    hours = hours % 12;
                    hours = hours ? hours : 12; // the hour '0' should be '12'
                    minutes = minutes < 10 ? '0'+minutes : minutes;
                    var strTime = hours + ':' + minutes + ' ' + ampm;
                    var dateTime = currentDate+' '+strTime
                    var dispatchAutoTimeStamp = dateTime+' - '+username+' > ';
                    quote = dispatchAutoTimeStamp+' '+quote;
                    $(".displayDispatchNotesPopup").prepend(quote+'\n');
                    $(".dispatchPopupNotes").val('');
                    $("##dispatchNotesSpokeTo").val('');
                    $("##dispatchNotesCurrLocation").val('');
                    $("##dispatchNotesETA").val('');
                    $("##dispatchNotesETAStopNo").val('1S');
                    $( ".closModal" ).trigger( "click" );
                    var  dispatchNote =  $('.displayDispatchNotesPopup').val().trim();
                     $.ajax({
                        type    : 'POST',
                        url     : "../gateways/loadgateway.cfc?method=updateLoadDispatchNote",
                        data    : {loadid : loadid,  dispatchNote : dispatchNote,dsn:<cfoutput>"#application.dsn#"</cfoutput>},
                        success :function(data){

                        }
                    });
                }
            });
        }
    });
    $('##carrierDispatchImg').click(function() {
        var loadid = $( this ).attr( "data-loadid" );
        $(".dispatchMailsPopup").css("display","block");
        $(".overlay").css("display","block");
        $(".dispatchMailsPopupContent").focus();
        $(".dispatchMailsAdd").click(function(){
            $( ".closdispatchMailsModal" ).trigger( "click" );
            var emailList = $(".dispatchMailsPopupContent").val();
            $.ajax({
                type    : 'POST',
                url     : "../gateways/loadgateway.cfc?method=updateLoadDispatchEmail",
                data    : {loadid : loadid, emailList : emailList, dsn:<cfoutput>"#application.dsn#"</cfoutput>},
                success :function(data){

                }
            });
        });
    });

    $('.applynotesPl').focus(function() {
      if(!$(this).hasClass('displayDispatchNotesPopup')){
        applyNotes(this, "bfb");
      }
    });

    $(".closModal").click(function() {
        $(".dispatchNotesPopup").css("display","none");
        $(".overlay").css("display","none");
    });
    $(".closdispatchMailsModal").click(function() {
        $(".dispatchMailsPopup").css("display","none");
        $(".overlay").css("display","none");
    });

        //==============================Hint Box Code============================\\
        //Shows the title in the text box, and removes it when modifying it
    $('input[title]').each(function(i) {
        if(!$(this).val()) {
            $(this).val($(this).attr('title')).addClass('hint');
        }


    $(this).focus(
        function() {
        if ($(this).val() == $(this).attr('title')) {
        $(this).val('')
        .removeClass('hint');
        }
    });

    $(this).blur(
        function() {
            if ($(this).val() == '') {
            $(this).val($(this).attr('title'))
            .addClass('hint');
            }
        }
    );
    });

    //Clear input hints on form submit
    $('form').submit(function() {
    $('input.hint').val('');
    return true;
    });

        //======End hint Box Code==========\\
});

    function applyNotes( thisObj, type ) {
        var myDate = new Date();
        var displayDate = (myDate.getMonth()+1) + '/' + (myDate.getDate()) + '/' + myDate.getFullYear();
        var textHiddenValue=$("##dispatchHiddenValue").val();
        if(($('##dispatchHiddenValue').val())== textHiddenValue){
            var statusText=$("##dispatchHiddenValue").val();
            $("##dispatchHiddenValue").val('');
        } else {
            var statusText="";
        }
        if($.trim($(thisObj).val()) == ""){
            var nextline=' ';
        } else {
            var nextline='\n';
        }
        var lines = $('##dispatchNotes').val().split('\n');
        if(lines[0].split('>')[1].trim() != ""){
            $(thisObj).val( + '\n' + clock()+' - '+ $('##Loggedin_Person').val()+ " >" +statusText+nextline+ "" + $.trim($(thisObj).val()));
        }
        var myString = clock()+' - '+ $('##Loggedin_Person').val()+ " >" +statusText+nextline;
        var n = myString.length;
        setSelectionRange(thisObj, n, n);
        return false;
    }

 function getCarrierCommodityValue(carrierid,type,stopno){
 if(stopno==0){
    $('##carrier_id').val(carrierid);
 }
 else{
    $('##carrier_id'+stopno).val(carrierid);
 }

 var searchIndex="";
 var indexStopNo="";
    $.ajax({
          type: "get",
          url: "getCarrierCommodityValue.cfm?carrierid="+carrierid,

          success: function(data){
            data =data.split(",");
            dataLength = data.length/3;
            realStop = (stopno == "" || stopno == 0) ? 1 : stopno;

            for(i=1;i<=$("##commodity_" + realStop + " tbody tr").length;i++){
                if(stopno!=0 || stopno!=""){
                    searchIndex=type+stopno+"_"+i;
                    indexStopNo=stopno;
                }else{
                    searchIndex=type+"_"+i;
                    indexStopNo=""
                }
                for(j=0;j<dataLength;j++){
                index=j*3;
                if($.trim($('##'+searchIndex).val()).length && $('##'+searchIndex).val()==data[index]){
                    var carrRate=data[index+1];
                    if(carrRate.indexOf(".")==-1){
                        carrRate=carrRate+".00";
                    }
                    $('##CarrierRate'+indexStopNo+"_"+i).val('$'+carrRate);
                    $('##CarrierPer'+indexStopNo+"_"+i).val(data[index+2]+'%');

                }
                }
                CalculateTotal('#Application.dsn#');
            }
          }

        });
 }
    function setSelectionRange(input, selectionStart, selectionEnd) {
        if (input.setSelectionRange) {
            input.focus();
            input.setSelectionRange(selectionStart, selectionEnd);
            return false;
        } else if (input.createTextRange) {
            var range = input.createTextRange();
            range.collapse(true);
            range.moveEnd('character', selectionEnd);
            range.moveStart('character', selectionStart);
            range.select();
        }
    }

    function clock(){
        var currentDate = new Date();
        var currentDay = currentDate.getDate();
        var currentMonth = currentDate.getMonth() + 1;
        var currentYear = currentDate.getFullYear();
        var hours = currentDate.getHours();
        var minutes = currentDate.getMinutes();

        var currentDate = currentMonth + "/" + currentDay + "/" + currentYear;
        var ampm = hours >= 12 ? 'PM' : 'AM';
        hours = hours % 12;
        hours = hours ? hours : 12; // the hour '0' should be '12'
        minutes = minutes < 10 ? '0'+minutes : minutes;
        var strTime = hours + ':' + minutes + ' ' + ampm;
        var FinalTime = currentDate+' '+strTime;
        return FinalTime
    }

    function openCarrierFilter(){
        var url = document.getElementById('equipment').value+'&consigneecity='+document.getElementById('consigneecity').value+'&consigneestate='+document.getElementById('consigneestate').value+'&consigneeZipcode='+document.getElementById('consigneeZipcode').value+'&shippercity='+document.getElementById('shippercity').value+'&shipperstate='+document.getElementById('shipperstate').value+'&shipperZipcode='+document.getElementById('shipperZipcode').value;

        window.location='index.cfm?event=carrier&#session.URLToken#&carrierfilter=true&equipment='+url;
    }
    
    
    $(window).bind('keydown', function(event) {
        if (event.altKey || event.metaKey) {
            switch (String.fromCharCode(event.which).toLowerCase()) {
            case 's':
                event.preventDefault();
                 $("##saveLoad").trigger("click");
                break;
            case 'e':
                event.preventDefault();
                $('input[name="saveexit"]').trigger("click");
                break;     
            case 'c':
                event.preventDefault();
                $('##CopyLoad').trigger("click");
                break;  
            case 'm':
                event.preventDefault(); 
                $('input[name="map-button"]').trigger("click");
                break;  
            }
        }
    });

</script>
<!--- To detect browser and increase the font size by 1px for Select Customer label for Chrome and Safari --->
<script type="text/javascript">
    var chromesafari_externalcss='styles/style_chrome_safari.css?t=10' //if "external", specify Mac css file here
    var isChrome = /Chrome/.test(navigator.userAgent) && /Google Inc/.test(navigator.vendor);
    var isSafari = /Safari/.test(navigator.userAgent) && /Apple Computer/.test(navigator.vendor);
    if (isChrome || isSafari){
        document.write('<link rel="stylesheet" type="text/css" href="'+ chromesafari_externalcss +'">')
    }
    
    function ChangeLabel(val){ 
        switch(val) {
            case 0: $(".LabelfreightBroker").text('Choose Driver');                     
                    $(" .removetxt").text('Remove Driver'); 
                    chooseCarrier();                    
                     break;
            case 1:
                    $(".LabelfreightBroker").text('Choose Carrier');                    
                    $(".removetxt").text('Remove Carrier');  
                    chooseCarrier();
                    break; 
            case 2:
                    $(".LabelfreightBroker").text('Choose Carrier/Driver');                 
                   $(".removetxt").text('Remove Carrier/Driver'); 
                   chooseCarrier();
                    break;                
        }
        $("##removeCarrierTag").hide();
        $("##LinkRemoveCarrier").trigger("click");
         $("##selectedCarrierValue").autocomplete({
                multiple: false,
                width: 450,
                scroll: true,
                scrollHeight: 300,
                cacheLength: 1,
                highlight: false,
                dataType: "json",
                search: function(event, ui){$(this).autocomplete('option', 'source', 'searchCarrierAutoFill.cfm?queryType=getCustomers&iscarrier='+val+'&companyid=#session.companyid#&loadid=#loadid#&pickupdate=' + $("##shipperPickupDate"+(($(this).data("stop") == 1) ? "" : $(this).data("stop"))).val() + '&deliverydate=' + $("##consigneePickupDate"+(($(this).data("stop") == 1) ? "" : $(this).data("stop"))).val())},
                source: 'searchCarrierAutoFill.cfm?queryType=getCustomers&companyid=#session.companyid#&loadid=#loadid#&iscarrier='+val+'&pickupdate=',
                select: function(e, ui) { 
                    if(ui.item.isoverlimit == 'yes')
                    {
                        alert("#ReReplace(variables.freightBroker,"\b(\w)","\u\1")# has reached their daily limit for this pickup date.");
                        return false;
                    }
                    
                    $(this).val(ui.item.name);
                    $('##'+this.id+'ValueContainer').val(ui.item.value);
                    <cfif ( structkeyexists(url,"loadid") and len(trim(url.loadid)) gt 1 )>
                        loadCarrierAutoSave('#url.loadid#',ui.item.value,0,'#session.companyid#');
                    </cfif>
                    var strHtml = "<div class='clear'></div>"
                        strHtml = strHtml + "<input name='carrierID' id='carrierID' type='hidden' value='"+ui.item.value+"' /><input name='carrierDefaultCurrency' id='carrierDefaultCurrency' type='hidden' value='"+ui.item.currency+"' />"
                        strHtml = strHtml + "<div class='clear'></div>"
                        if(ui.item.risk_assessment != ""){
                            strHtml = strHtml + "<label><a target='_blank' href='"+ui.item.link+"'><img src='"+ui.item.risk_assessment+"' alt='Risk Assement Icon'></a></label>"
                        }else{
                            strHtml = strHtml + "<label>&nbsp;</label>"
                        }
                        strHtml = strHtml + "<label class='field-textarea'>"
                        strHtml = strHtml + "<b>"

                        <cfset Iscarrier = "">
                        <cfif structkeyexists(request,"qLoads") AND structkeyexists(request.qLoads,"Iscarrier") AND request.qLoads.Iscarrier NEQ "" >
                             <cfset Iscarrier = "&Iscarrier=#request.qLoads.Iscarrier#">
                        </cfif>


                        <cfif ListContains(session.rightsList,'bookCarrierToLoad',',')>
                            <cfif request.qSystemSetupOptions.FreightBroker EQ 1>
                                strHtml = strHtml + "<a href='index.cfm?event=addcarrier&#Iscarrier#&carrierid="+ui.item.value+"' style='color:##4322cc;text-decoration:underline;'>"
                            <cfelseif request.qSystemSetupOptions.FreightBroker EQ 2>
                                if(ui.item.iscarrier == 1){
                                    strHtml = strHtml + "<a href='index.cfm?event=addcarrier&Iscarrier=1&carrierid="+ui.item.value+"' style='color:##4322cc;text-decoration:underline;'>"
                                }else{
                                    strHtml = strHtml + "<a href='index.cfm?event=adddriver&&Iscarrier=0&carrierid="+ui.item.value+"' style='color:##4322cc;text-decoration:underline;'>"
                                }
                            <cfelse>
                                  strHtml = strHtml + "<a href='index.cfm?event=adddriver&#Iscarrier#&carrierid="+ui.item.value+"' style='color:##4322cc;text-decoration:underline;'>"
                            </cfif>
                        <cfelse>
                            strHtml = strHtml + "<a href='javascript: alert('Sorry!! You don\'t have rights to add/edit #variables.freightBroker#.'); return false;' style='color:##4322cc;text-decoration:underline;'>"
                        </cfif>
                        strHtml = strHtml + ui.item.name
                        strHtml = strHtml + "</a>"
                        strHtml = strHtml + "</b>"
                        strHtml = strHtml + "<br/>"
                        strHtml = strHtml + ""+ui.item.name+"<br/>"+ui.item.city+"<br/>"+ui.item.state+"&nbsp;-&nbsp;"+ui.item.zip+""
                        strHtml = strHtml + "</label>"
                        strHtml = strHtml + "<div class='clear'></div>"
                        strHtml = strHtml + "<label>Tel</label>"
                        strHtml = strHtml + "<label class='cellnum-text'>"+ui.item.phoneNo+"</label>"
                        strHtml = strHtml + "<label class='space_load'>Cell</label>"
                        strHtml = strHtml + "<label class='cellnum-text'>"+ui.item.cell+"</label>"
                        strHtml = strHtml + "<div class='clear'></div>"
                        strHtml = strHtml + "<label>Fax</label>"
                        strHtml = strHtml + "<label class='field-text'>"+ui.item.fax+"</label>"
                        strHtml = strHtml + "<div class='clear'></div>"
                        strHtml = strHtml + "<label>Email</label>"
                        strHtml = strHtml + "<label class='emailbox'>"+ui.item.email+"</label>";
                    if(ui.item.status == 'INACTIVE'){
                        alert('#variables.freightBroker# is Inactive.');
                        chooseCarrier();
                        return false;
                    }


                        if(ui.item.iscarrier == 1 && ui.item.insuranceExpired == 'yes')
                        {
                            if(! (#request.qSystemSetupOptions.AllowBooking#)){
                                alert("One or more of the Carrier's insurances has an expiration date prior to the final delivery of this load." );
                                $(this).val('');
                                return false;
                            }
                            else{
                                alert("One or more of the Carrier's insurances has an expiration date prior to the final delivery of this load." );
                            }
                        }                        

                    document.getElementById("CarrierInfo").style.display = 'block';
                    document.getElementById('choosCarrier').style.display = 'none';
                    DisplayIntextField(ui.item.value,'#Application.dsn#');
                    $('##CarrierInfo').html(strHtml);
                    $('##defaultCarrierCurrency option[value=' +$("##carrierDefaultCurrency").val()+']').prop('selected', true);
                    $('##defaultCarrierCurrency').trigger("change");
                    getCarrierCommodityValue(ui.item.value,"unit","");               
                    $('##carrier_id').data("limit", ui.item.loadLimit);
                    var carrierId =$('##carrierID').val();
                    if(ui.item.EquipmentID.trim() != "" && $("##equipment").val() ==""){
                        if(ui.item.eqActive.trim() == 1){
                            $("##equipment").val(ui.item.EquipmentID);
                        }
                        else{
                            alert('The default equipment assigned to this #variables.freightBroker# is inactive.');
                        }
                    }
                    
                    if((ui.item.unitNumber != -1)){
                        if(ui.item.unitNumber.trim() != ""){
                            $("##truckNo").val(ui.item.unitNumber);
                        }

                        $( "##equipment" ).unbind( "change" );
                        $("##equipment").change(function(){     
                            $("##truckNo").val($("##equipment option:selected").data("truck-number"));
                        });
                        $("##equipment").trigger("change");
                    }else{
                        $( "##equipment" ).unbind( "change" );
                    }

                    $(".form-heading-carrier").show(); 
                    $("##removeCarrierTag").show(); 
                    $("##loadManualNo").trigger("onblur");    
                    DriverContactAutoComplete('');      
                    return false;
                }
            });
            $("##selectedCarrierValue").data("ui-autocomplete")._renderItem = function(ul, item) {
                if(item.risk_assessment != ""){
                    var url = "<a target='_blank' href='"+item.link+"'><img src='"+item.risk_assessment+"' alt='Risk Assement Icon'></a>";
                }else{
                    var url = "";
                }

                return $( "<li>"+item.name+"&nbsp;&nbsp;&nbsp;<b><u>Status</u>:</b> "+ item.status+"&nbsp;&nbsp;&nbsp;"+url+"<br/><b><u>City</u>:</b> "+ item.city+"&nbsp;&nbsp;&nbsp;<b><u>State</u>:</b>" + item.state+"&nbsp;&nbsp;&nbsp;<b><u>Zip</u>:</b> " + item.zip+"&nbsp;&nbsp;&nbsp;<b><u>Insurance Expiry</u>:</b> " + item.InsExpDate+"</li>" )
                        .appendTo( ul );
            }
    }
</script>

<script type="text/javascript">
    window.onload = function() {
        CalculateTotal('#Application.dsn#');
        updateTotalRates('<cfoutput>#application.DSN#</cfoutput>');
    }

    $( document ).ready(function() {
        <cfif variables.loaddisabledStatus>
            $(".green-btn").prop("disabled",true);
            $(".green-btn").attr("title","This load is edited by another person. Please ask administrator to unlock this load.");
            $(".green-btn").css("color",":##adadad !important");
            $(".green-btn").css("cursor","not-allowed");
            $("[id^=delComm_]").attr("hidden", true);

        </cfif>
        $('input[type=text]').addClass('myElements');
        $('input[type=checkbox]').addClass('myElements');
        $('input[type=datefield]').addClass('myElements');
        $('select').addClass('myElements');
        $('textarea').addClass('myElements');
        $('.myElements').each(function() {
           var elem = $(this);
           // Save current value of element
           elem.data('oldVal', elem.val());
           // Look for changes in the value
           elem.bind("propertychange change click keyup input paste", function(event){
              // If value has changed...
              if (elem.data('oldVal') != elem.val()) {
               // Updated stored value
               elem.data('oldVal', elem.val());
               $("##inputChanged").val(1);
             }
        });
     });
    
    $(document).on("focus", "[id^=shipperPickupDate]", function(){
      $(this).data('lastdata', $(this).val());
    });

    $(document).on("focus", "[id^=consigneePickupDate]", function(){
        var stp = $(this).attr('id').replace("consigneePickupDate", "")
        var pickupdate = $('##shipperPickupDate'+stp).val();
        if($.trim(pickupdate).length){
            $(this).datepicker('destroy');
            $( this ).datepicker({
              dateFormat: "mm/dd/yy",
              showOn: "button",
              buttonImage: "images/DateChooser.png",
              buttonImageOnly: true,
              showButtonPanel: true
            });
            $(this).datepicker('option', 'minDate', new Date(pickupdate));
        }
    });
    
    $(document).on("change", "[id^=shipperPickupDate]", function(){
      var stopappend = ($(this).data("stop") == "1") ? "" : $(this).data("stop");
      if($("##carrier_id"+stopappend).val() != "" &&  ($("##carrier_id"+stopappend).data("limit") || #request.qSystemSetupOptions.CARRIERLOADLIMIT#)){
        alert("The #variables.freightBroker# for this stop needs to be removed to set the pickup date. Please remove the respective #variables.freightBroker# and try again.");
        $(this).val($(this).data('lastdata'));
      }
    });
    
    $(document).on("focus", "[id^=consigneePickupDate]", function(){
      $(this).data('lastdata', $(this).val());
    });
    $(document).on("change", "[id^=consigneePickupDate]", function(){
      var stopappend = ($(this).data("stop") == "1") ? "" : $(this).data("stop");
      if($("##carrier_id"+stopappend).val() != "" &&  ($("##carrier_id"+stopappend).data("limit") || #request.qSystemSetupOptions.CARRIERLOADLIMIT#)){
        alert("The #variables.freightBroker# for this stop needs to be removed to set the delivery date. Please remove the respective #variables.freightBroker# and try again.");
        $(this).val($(this).data('lastdata'));
      }
    });

    <cfif (isDefined('statusText') AND NOT ListContains(session.editableStatuses,statusText,',')) OR (isDefined("local.lockloadStatsFlag") AND local.lockloadStatsFlag EQ true)>
        $('.overlay').show();
        setTimeout(function(){
            $("input,select,textarea,.field-textarea,.styledSelect,[id^=delComm_]").attr("readonly", true).addClass('disabledLoadInputs').css("pointer-events","none");
            $("##carrierReportLink,##custInvReportLink,##BOLReport").attr("readonly", false).removeClass('disabledLoadInputs').css("pointer-events","auto")
            $('.ui-datepicker-trigger').hide();
            $('##ViewOnlyH').show();
            <cfif ListContains(session.rightsList,'LoadStatusOverride',',')>
                $('##loadStatus').attr("readonly", false).removeClass('disabledLoadInputs ').css('pointer-events','auto');
                $('input[type=submit]').attr("readonly", false).removeClass('disabledLoadInputs ').css('pointer-events','auto');
                $('##ViewOnlyH').hide();
            </cfif>

            <cfif ListContains(session.rightsList,'editUserDefinedFields',',')>
                $('.userOnchageUpdate ').attr("readonly", false).removeClass('disabledLoadInputs ').css('pointer-events','auto');
                $('input[type=submit]').attr("readonly", false).removeClass('disabledLoadInputs ').css('pointer-events','auto');
                $('##ViewOnlyH').hide();
            </cfif>

            <cfif ListContains(session.rightsList,'EditLockedExceptLoadDates',',')>
                $("input,select,textarea,.field-textarea,.styledSelect,[id^=delComm_]").attr("readonly", false).removeClass('disabledLoadInputs ').css('pointer-events','auto');
                $('.hasDatepicker').attr("readonly", true).addClass('disabledLoadInputs').css("pointer-events","none");
                $('.ui-datepicker-trigger').hide();
                $("##CustomerMilesCalc,##CarrierMilesCalc,##CustomerMilesTotalAmount,##CarrierMilesTotalAmount,##flatRateProfit,##TotalCustcommodities,##TotalCarcommodities,##carcommoditiesProfit,##CustomerMiles,##CarrierMiles,##amountOfMilesProfit,##AdvancePaymentsCustomer,##AdvancePaymentsCarrier,##FactoringFeeAmount,##TotalCustomerCharges,##TotalCarrierCharges,##TotalDirectCost,##totalProfit").addClass('disabledLoadInputs');
                $('input[type=submit]').attr("readonly", false).removeClass('disabledLoadInputs ').css('pointer-events','auto');
                $('##ViewOnlyH').hide();
            </cfif>

            <cfif ListContains(session.rightsList,'EditLockedLoadDatesOnly',',')>
                $('.hasDatepicker').attr("readonly", false).removeClass('disabledLoadInputs').css("pointer-events","auto");
                $('.ui-datepicker-trigger').show();
                $('input[type=submit]').attr("readonly", false).removeClass('disabledLoadInputs ').css('pointer-events','auto');
                $('##ViewOnlyH').hide();
            </cfif>

            <cfif ListContains(session.rightsList,'LockLoadAmounts',',')>
                $('##CustomerRatePerMile,##CarrierRatePerMile,##CustomerRate,##CarrierRate,.qty,.CustomerRate,.CarrierRate,##TotalCustcommodities,##TotalCarcommodities,##CustomerMiles,##CarrierMiles').attr("readonly", true).addClass('disabledLoadInputs');
                $("[id^=delComm_]").addClass('disabledLoadInputs').css("pointer-events","none");
            </cfif>

            <cfif ListContains(session.rightsList,'EditLockedLoadNotePads',',')>
                $("##Notes,##dispatchNotes,##carrierNotes,##pricingnotes,##billToNotes,##billToDispNotes,##shipperDirection,##consigneeDirection").attr("readonly", false).removeClass('disabledLoadInputs ').css("pointer-events","auto");
                $('input[type=submit]').attr("readonly", false).removeClass('disabledLoadInputs ').css('pointer-events','auto');
                $('##ViewOnlyH').hide();
            </cfif>

            <cfif ListContains(session.rightsList,'EditLockedLoadCustPaidCarrPaid',',')>
                $("##CustomerPaid,##CarrierPaid").attr("readonly", false).removeClass('disabledLoadInputs ').css("pointer-events","auto");
                $('input[type=submit]').attr("readonly", false).removeClass('disabledLoadInputs ').css('pointer-events','auto');
                $('##ViewOnlyH').hide();
            </cfif>

            <cfif ListContains(session.rightsList,'EditInvoiceDate',',')>
                $('##BillDate').attr("readonly", false).removeClass('disabledLoadInputs').css("pointer-events","auto");
                $('##BillDate').parent().find('.ui-datepicker-trigger').show();
                //$('.ui-datepicker-trigger').show();
                $('input[type=submit]').attr("readonly", false).removeClass('disabledLoadInputs ').css('pointer-events','auto');
                $('##ViewOnlyH').hide();
            </cfif>

            $('.overlay').hide();
        },1000)
    </cfif>
  });

   function addNewRowCommodities(evnt, comid) {
      var i = $('##totalResult'+comid).val();
      var original = document.getElementById('commodities_'+comid);
      var clone = original.cloneNode(true);
      i =++i;
      $(clone).find("input,radio,select,textArea,tr,img").each(function(e){
        var name = $(this).attr("name");
        name = name.split('_');
        if(name[0] == 'CarrierPer'){
           $(this).attr("onchange","ConfirmMessage('"+i+"',0)"); 
        }
        if(name[0] == 'CarrierPer'+comid){
           $(this).attr("onchange","ConfirmMessage('"+i+"',"+comid+")"); 
        }
        if(name[0] == 'unit'+comid){     
           $(this).removeAttr("onchange"); 
           $(this).attr("onchange","changeQuantityWithtype(this,'"+comid+"');checkForFee(this.value,'"+i+"','"+comid+"','#Application.dsn#');autoloaddescription(this,'"+comid+"','"+i+"','#Application.dsn#');autoloaddescription(this,'"+comid+"','"+i+"','#Application.dsn#');");
        }
        if(name[0] == 'unit'){     
            $(this).removeAttr("onchange");
            $(this).attr("onchange","changeQuantityWithtype(this,'');checkForFee(this.value,'"+i+"','','#Application.dsn#');autoloaddescription(this,'','"+i+"','#Application.dsn#');");   
        }

        if(name[0] == 'description'+comid){ 
            $(this).val('');
        }
         if(name[0] == 'description'){ 
            $(this).val('');
        }
        if(name[0] == 'isFee'+comid){ 
            $(this).prop('checked',false);;
        }
        if(name[0] == 'isFee'){ 
           $(this).prop('checked',false);;
        }
        $(this).attr("name",name[0]+"_"+i);
        $(this).attr("id",name[0]+"_"+i);
      });
      $(clone).find("[id^=delComm]").show();
      $("##commodity_"+comid+" tbody").append(clone);
      $('##commodities_'+comid).removeAttr("style");
      $('##totalResult'+comid).val(i);
      $('##commodity_'+comid+' tr').removeAttr("id");
      reSortCommodities()
    }
    <cfif not structKeyExists(session, "empid")>
        <cflocation url="index.cfm?event=logout:process">
    </cfif>
    function delRowCommodities(comm){
        if (confirm("Are you sure you want to delete this item?")) {
            var name = $(comm).attr("name").replace('delComm','');
            var stop_comm = name.split('_');
            var stop = stop_comm[0];
            var commid = parseInt(stop_comm[1]);
            var loadstopCommid = $('##commStopId'+stop+'_'+commid).val();
            var srNo = $('##commSrNo'+stop+'_'+commid).val();
            var description = $('##description'+stop+'_'+commid).val();
            $(comm).closest('tr').remove();
            CalculateTotal('#Application.dsn#');
            if(loadstopCommid != 0 && srNo !=0){
                var path = urlComponentPath+"loadgateway.cfc?method=delRowCommodities";
                $.ajax({
                    type: "Post",
                    url: path,
                    dataType: "json",
                    async: false,
                    data: {loadstopCommid:loadstopCommid,srNo:srNo,dsn:'#application.dsn#',LoadId:'#url.editid#',LoadNumber:'#loadnumber#',UpdatedByUserID:'#session.empid#',UpdatedBy:'#session.adminUserName#',stopNo:stop,description:description},
                    success: function(data){
                        if(stop.length){
                            var commoditityAlreadyCount = parseInt($('##commoditityAlreadyCount'+stop).val());
                            $('##commoditityAlreadyCount'+stop).val(commoditityAlreadyCount-1);
                        }
                        else{
                            var commoditityAlreadyCount = parseInt($('##commoditityAlreadyCount1').val());
                            $('##commoditityAlreadyCount1').val(commoditityAlreadyCount-1);
                        }
                        
                    }
                });
            }
            if(stop.length){
                var count = $('##totalResult'+stop).val();
            }
            else{
                var count = $('##totalResult1').val();
            }

            if(count>commid){
                for(i=commid+1;i<=count;i++){
                    var row = $("##delComm"+stop+"_"+i).closest('tr');
                    $(row).find("input,radio,select,textArea,tr,img").each(function(e){
                        var name = $(this).attr("name");
                        name = name.split('_');
                        var j = i-1;
                        $(this).attr("name",name[0]+"_"+j);
                        $(this).attr("id",name[0]+"_"+j);
                    });
                }
            }
            count =--count;
            if(stop.length){
                $('##totalResult'+stop).val(count);
            }
            else{
                $('##totalResult1').val(count);
            } 
            if(count==0){
                if(stop.length){
                    addNewRowCommodities(this, stop);
                }
                else{
                    addNewRowCommodities(this, 1);
                }
            }
        }
    }
    
    var googleMapsPcMiler = #request.qSystemSetupOptions.googleMapsPcMiler#;
    ALKMaps.APIKey = "#request.qSystemSetupOptions.PCMilerAPIKey#";
</script>

<script type="text/javascript">
    $( document ).ready(function() {

         resetAddStopButton();

         var url = window.location.href.slice(window.location.href.indexOf('AlertvarEDI') ).split('&'); 
         
            for (var i = 0; i < url.length; i++) {  
                var urlparam = url[i].split('=');  
                if (urlparam[0] == 'AlertvarEDI') {  
                   alert(decodeURIComponent(urlparam[1]).replace(/\./g, '.\n') ) ; 
                   
                    if(decodeURIComponent(urlparam[1]).indexOf('Please select a reason for late pickup on Stop ')!= -1){
                        var alertText = decodeURIComponent(urlparam[1]).split("Please select a reason for late pickup on Stop "); 
                        var stopNo = alertText[1];
                        $('.labelShipperTimein'+stopNo).css('color','red'); 
                        $('.labelShipperTimein'+stopNo).css('display','block'); 

                        if(stopNo ==1){
                            $('##shipperEdiReasonCode').focus();
                            $('##shipperEdiReasonCode').css('display','block'); 
                        }
                        else{
                            $('##shipperEdiReasonCode'+stopNo).focus();
                            $('##shipperEdiReasonCode'+stopNo).css('display','block'); 
                        }
                        
                    }
                    if(decodeURIComponent(urlparam[1]).indexOf('Please select a reason for late delivery on Stop ')!= -1){
                        var alertText = decodeURIComponent(urlparam[1]).split("Please select a reason for late delivery on Stop "); 
                        var stopNo = alertText[1];
                        $('.labelConsigneeTimein'+stopNo).css('color','red');                       
                        $('.labelConsigneeTimein'+stopNo).css('display','block'); 
                        
                        if(stopNo ==1){
                            $('##consigneeEdiReasonCode').focus();
                            $('##consigneeEdiReasonCode').css('display','block'); 
                        }
                        else{
                            $('##consigneeEdiReasonCode'+stopNo).focus();
                            $('##consigneeEdiReasonCode'+stopNo).css('display','block'); 
                        }
                        
                    }

                    if(decodeURIComponent(urlparam[1]).indexOf('EDI 214 Pickup time in for stop')!= -1){
                        var alertText = decodeURIComponent(urlparam[1]).split("EDI 214 Pickup time in for stop "); 
                        var alertText2 = decodeURIComponent(alertText[1]).split(" is not in the range"); 
                        
                        var stopNo = alertText2[0];
                        
                        $('.labelShipperTimein'+stopNo).css('color','red'); 
                        $('.labelShipperTimein'+stopNo).css('display','block'); 

                        if(stopNo ==1){
                            $('##shipperEdiReasonCode').focus();
                            $('##shipperEdiReasonCode').css('display','block'); 
                        }
                        else{
                            $('##shipperEdiReasonCode'+stopNo).focus();
                            $('##shipperEdiReasonCode'+stopNo).css('display','block'); 
                        }
                        
                    }

                    if(decodeURIComponent(urlparam[1]).indexOf('EDI 214 Pickup time out for stop')!= -1){
                        var alertText = decodeURIComponent(urlparam[1]).split("EDI 214 Pickup time out for stop "); 
                        var alertText2 = decodeURIComponent(alertText[1]).split(" is not in the range"); 
                        
                        var stopNo = alertText2[0];
                        
                        $('.labelShipperTimein'+stopNo).css('color','red'); 
                        $('.labelShipperTimein'+stopNo).css('display','block'); 

                        if(stopNo ==1){
                            $('##shipperEdiReasonCode').focus();
                            $('##shipperEdiReasonCode').css('display','block'); 
                        }
                        else{
                            $('##shipperEdiReasonCode'+stopNo).focus();
                            $('##shipperEdiReasonCode'+stopNo).css('display','block'); 
                        }
                        
                    }

                    if(decodeURIComponent(urlparam[1]).indexOf('EDI 214 Delivery time in for stop')!= -1){
                        var alertText = decodeURIComponent(urlparam[1]).split("EDI 214 Delivery time in for stop "); 
                        var alertText2 = decodeURIComponent(alertText[1]).split(" is not in the range"); 
                        
                        var stopNo = alertText2[0];
                        
                        $('.labelConsigneeTimein'+stopNo).css('color','red'); 
                        $('.labelConsigneeTimein'+stopNo).css('display','block'); 

                        if(stopNo ==1){
                            $('##consigneeEdiReasonCode').focus();
                            $('##consigneeEdiReasonCode').css('display','block'); 
                        }
                        else{
                            $('##consigneeEdiReasonCode'+stopNo).focus();
                            $('##consigneeEdiReasonCode'+stopNo).css('display','block'); 
                        }
                        
                    }

                    if(decodeURIComponent(urlparam[1]).indexOf('EDI 214 Delivery time out for stop')!= -1){
                        var alertText = decodeURIComponent(urlparam[1]).split("EDI 214 Delivery time out for stop "); 
                        var alertText2 = decodeURIComponent(alertText[1]).split(" is not in the range"); 
                        
                        var stopNo = alertText2[0];
                        
                        $('.labelConsigneeTimein'+stopNo).css('color','red'); 
                        $('.labelConsigneeTimein'+stopNo).css('display','block'); 

                        if(stopNo ==1){
                            $('##consigneeEdiReasonCode').focus();
                            $('##consigneeEdiReasonCode').css('display','block'); 
                        }
                        else{
                            $('##consigneeEdiReasonCode'+stopNo).focus();
                            $('##consigneeEdiReasonCode'+stopNo).css('display','block'); 
                        }
                        
                    }


                }               
            } 
            
            /*Validation for Numeric Only */
            var mask = new RegExp('^([0-9]*)$')
            $(".NumericOnlyFields").regexMask(mask);    
          
            $( ".NumericOnlyFields" ).change(function() {
              var mask = new RegExp('^([0-9]*)$');
              if(!mask.test($(this).val().trim())){
                $(this).val('');
              }
              var mask = new RegExp('^([0-9]*)$');
              if(!mask.test($(this).val().trim())){
                $(this).val('');
              }
            });
        
        $( ".edidatetime" ).change(function() {
          checkValidDateTime(this);
          
        });

        
        if ($.trim($( "##loadStatus option:selected" ).data('statustext'))== "4. LOADED/UNLOADED"){
            $("##shipperConsignee > option").each(function() {
            if($(this).attr('data-code') == '1S'){
                
                $('select[id^="shipperConsignee"] option[data-code="1S"]').attr("selected","selected");
                
            }
        });
        }

        $("##equipment").change(function(){ 
           if(typeof $("##equipment option:selected").data("temperature") != 'undefined' && $("##equipment option:selected").data("temperature") != ''){
                $("##temperature").val($("##equipment option:selected").data("temperature"));
           }
           else{
                $("##temperature").val('');
           }
           if(typeof $("##equipment option:selected").data("temperaturescale") != 'undefined' && $("##equipment option:selected").data("temperaturescale") != ''){
                $("##temperaturescale").val($("##equipment option:selected").data("temperaturescale"));
           }
           else{
                $("##temperaturescale").val('C');
           }

           var dataTruckTrailer = $("##equipment option:selected").data("trucktrailer");
           if($("##equipmentTrailer option[value='"+dataTruckTrailer+"']").length && !$('##equipmentTrailer').val().length){
            $('##equipmentTrailer').val(dataTruckTrailer);
           }
        })
        reSortCommodities();
    })

    function editLoadLock(){
       var path = urlComponentPath+"loadgateway.cfc?method=getAjaxLoadLock";
        $.ajax({
            type: "get",
            url: path,
            data: {loadid:'#url.loadid#',dsn:'#application.dsn#'},
            success: function(isLocked){
                if(isLocked==1){
                    alert('This load is currently being edited by another user.')
                    document.location.href='index.cfm?event=addload&loadid=#LOADID#&#session.URLToken#'
                }
                else{
                    var path = urlComponentPath+"loadgateway.cfc?method=setAjaxLoadLock";
                    $.ajax({
                        type: "Post",
                        url: path,
                        dataType: "json",
                        async: false,
                        data: {loadid:'#url.loadid#',dsn:'#application.dsn#'},
                        success: function(data){
                            document.location.href='index.cfm?event=addload&loadid=#LOADID#&#session.URLToken#&showSaveButton'
                        }
                    });
                }
            }
        });
    }

    function unlockLoad(){
        var path = urlComponentPath+"loadgateway.cfc?method=ajaxLoadUnLock";
        $.ajax({
            type: "Post",
            url: path,
            dataType: "json",
            async: false,
            data: {loadid:'#url.loadid#',dsn:'#application.dsn#'},
            success: function(data){
                document.location.href='index.cfm?event=load&#session.URLToken#';
            }
        });
    }

    $('.commRows').sortable({
        start: function(e, ui) {
        // creates a temporary attribute on the element with the old index
        $(this).attr('data-previndex', ui.item.index());
    },
    update: function(e, ui) {
        // gets the new and old index then removes the temporary attribute
        var newIndex = ui.item.index();
        var oldIndex = $(this).attr('data-previndex');

        $(this).removeAttr('data-previndex');

        var tableId = $(this).parent().attr("id");
        
        $('##'+tableId+' tbody tr').each(function (i, tr){
            $(this).find('input,select,img').each(function () {
                var Name = this.name;
                var ind = i+1;
                $(this).attr("name",Name.split('_')[0]+'_'+ind);
                $(this).attr("id",Name.split('_')[0]+'_'+ind);
            });
        })
        reSortCommodities()
    }

    });

    $( ".commRows" ).disableSelection();

    function reSortCommodities(){
        $('.commRows').each(function (i, stops){
            var totalCommCount = $(this).find('tr:last').index();
            if(totalCommCount==0){
                $(this).find('[id^=sortComm]').hide();
            }
            else{
                $(this).find('[id^=sortComm]').show();
                $(this).find('tr').each(function (j,comm) {
                    if(j==0){
                        $(this).find('[id^=sortComm]').attr('src','images/sortdwn.png')
                        $(this).find('[id^=sortComm]').css('width','12px');
                    }
                    else if(j==totalCommCount){
                        $(this).find('[id^=sortComm]').attr('src','images/sortup.png');
                        $(this).find('[id^=sortComm]').css('width','12px');
                    }
                    else{
                        $(this).find('[id^=sortComm]').attr('src','images/sort.png');
                        $(this).find('[id^=sortComm]').css('width','12px');
                    }
                })
            }  
        })
    }
    function processEDI(DocType){
        var path = urlComponentPath+"loadgateway.cfc?method=processEDI";
        $.ajax({
            type: "Post",
            url: path,
            data: {
                loadid:'#url.loadid#',dsn:'#application.dsn#',DocType:DocType
            },
            success: function(result){
                $('.loadOverlay').hide();
                alert(jQuery.parseJSON(result)); 
                location.reload();     
            },
            beforeSend: function() {
                $('.loadOverlay').show()
            },
        });
    }
    $.fn.regexMask = function(mask) {
        $(this).keypress(function (event) {
        if (!event.charCode) return true;
        var part1 = this.value.substring(0, this.selectionStart);
        var part2 = this.value.substring(this.selectionEnd, this.value.length);
        if (!mask.test(part1 + String.fromCharCode(event.charCode) + part2) && event.which != 13)
            return false;
        });
    };

    function checkShipperUpdated(stpno){
        if($('##shipperValueContainer'+stpno).val().length != 0){
            $('##shipperFlag'+stpno).val(2)
        }
        else{
            $('##shipperFlag'+stpno).val(1)
        }

    }

    function checkConsngeeUpdated(stpno){
        if($('##consigneeValueContainer'+stpno).val().length != 0){
            $('##consigneeFlag'+stpno).val(2)
        }
        else{
            $('##consigneeFlag'+stpno).val(1)
        }
    }

    <cfif structkeyexists(url,"LoadID") and len(trim(url.LoadID)) gt 1>
        $(document).ready(function(){
            $('##btnLocationUpdate').click(function() {
                newwindow=window.open('index.cfm?event=loadMail&type=LocationUpdates&LoadID=#url.LoadID#&#session.URLToken#','Map','height=600,width=850');
                if (window.focus) {
                    newwindow.focus()
                }
            });
        })

        function PushDataToProject44Api(){
            var PushDataToProject44Api = 0;
            if($('##PushDataToProject44Api').is(":checked")){
                PushDataToProject44Api =1;
            }
            var path = urlComponentPath+"loadgateway.cfc?method=PushDataToProject44Api";
            $.ajax({
                type: "Post",
                url: path,
                dataType: "json",
                async: false,
                data: {
                    loadid:'#url.loadid#',dsn:'#application.dsn#',PushDataToProject44Api:PushDataToProject44Api
                },
                success: function(data){
                    alert(data.MSG);
                    $('##PushDataToProject44Api').removeAttr("disabled");
                    if(data.SUCCESS == 0){
                        $("##PushDataToProject44Api").prop("checked", false);
                    }
                }
            });  
        }
    </cfif>

    function openRateCon(opt){
        var dsn = '#dsn#';
        var user = $('##Loggedin_Person').val();

        if(($('##EDispatchPromptOff').is(':checked'))){
            $.ajax({
                type    : 'POST',
                url     : "../gateways/loadgateway.cfc?method=updateEDispatchPromptSettingOff",
                data    : {dsn : '#Application.dsn#',companyid:'#session.companyid#'},
                success :function(){     
                }
            });
        }
    
        if(opt==1){
            $.ajax({
                type    : 'POST',
                url     : "../gateways/loadgateway.cfc?method=updateLoadStatusDispatched",
                data    : {LoadID : '#url.loadid#' , dsn : '#Application.dsn#' , user : user, companyid:'#session.companyid#' , clock:clock(), dispatchStatusDesc : '#dispatchStatusDesc#'},
                success :function(){     
                    $.ajax({
                        type    : 'POST',
                        url     : "ajax.cfm?event=ajxSendLoadEmailUpdate&LoadID=#url.loadid#&NewStatus=#dispatchStatusID#&#session.URLToken#",
                        data    : {},
                        success :function(data){
                            location.reload();
                        }
                    })
                }
            });
        }
        document.getElementById('ModalEDispatchPrompt').style.display = "none";
        carrierReportOnClick(mailLoadId,mailUrlToken,dsn);
        var printDisplayStatus='<cfoutput>#request.qSystemSetupOptions.automaticprintreports#</cfoutput>';
        if(printDisplayStatus == '1'){
            $('##dispatchHiddenValue').val('Printed #variables.freightBroker# Report >');
            $("##dispatchNotes").prepend(clock()+' - '+ $('##Loggedin_Person').val()+ ' > Printed #variables.freightBroker# Report > \n');
        }

        if(($('##EDispatchPromptOff').is(':checked'))){
            location.reload();
        }
    }


    function showfullmap(url,form, type, dsn) {
        var h = screen.height;
        var w = screen.width;
        var url ='index.cfm?event=Googlemap&LoadID=#url.LoadID#&#session.URLToken#'
        newwindow=window.open(url,'name','height='+h +',width='+w +',toolbar=0,scrollbars=0,location=0,statusbar=0,menubar=0,resizable=0');
        if (window.focus) {newwindow.focus()}
        return false;           
    }
        <cfif listFindNoCase(session.rightsList, 'addEditLoadOnly')>
            $(document).ready(function(){
                $(".customerLink" ).click(function() {
                    alert('Sorry!! You do not have rights to the customer screen.');
                    return false;
                })
                $("##CarrierInfo a" ).click(function() {
                    alert('Sorry!! You do not have rights to the carrier screen.');
                    return false;
                })
            })
        </cfif>
        
        function checkTimeForProject44(stopno,type,event){
            <cfif request.qSystemSetupOptions.Project44 AND ( structkeyexists(url,"loadid") and len(trim(url.loadid)) gt 1 )>
                if($('##PushDataToProject44Api').prop('checked')){
                    $('##'+type+'Project44Text'+stopno).html('Project44 milestone event for ' + event +' time will be sent.');
                }
            </cfif>
        }

        function sendProject44Local(stopno,type,event){
            <cfif request.qSystemSetupOptions.Project44 AND ( structkeyexists(url,"loadid") and len(trim(url.loadid)) gt 1 )>
                if(event == 'ARRIVED'){
                    var ev = 'TimeIn';
                }
                else{
                    var ev = 'TimeOut';
                }
                if(type=='shipper'){
                    ajxType = 1;
                }
                else{
                    ajxType=2;
                }
                var time = $('##'+type+ev+stopno).val();
                if(!$.trim(time).length){
                    alert("Please enter time.");
                    $('##'+type+ev+stopno).focus();
                }
                else{
                   if(confirm("Do you want to post the "+ event +" date/time to Project44?")){
                        $(".loadOverlay").show();
                        $('##loader').show();
                        $('##loadingmsg').show();
                        if(!$.trim(stopno).length){
                            var stop = 0;
                        }
                        else{
                            var stop = parseInt(stopno)-1;
                        }

                        $.ajax({
                            type    : 'POST',
                            url     : "../gateways/loadgateway.cfc?method=sendProject44Local",
                            data    : {dsn : '#application.DSN#',companyid:'#session.companyid#', loadId : '#url.loadid#', stopno:stop, LoadType:ajxType,event:event,empid:'#session.empid#',time:time},
                            success :function(ajaxRes){
                                if(type=='shipper'){
                                    $('##oldShipper'+ev+stopno).val(time)
                                }
                                else{
                                    $('##oldConsignee'+ev+stopno).val(time)
                                }
                                $(".loadOverlay").hide();
                                $('##loader').hide();
                                $('##loadingmsg').hide();
                                alert(ajaxRes);
                            }
                        });

                    } 
                }
            </cfif>
        }
        function openSalesRepPopup(){

            var SalesRep1 = $('##SalesRep1').val();
            var SalesRep2 = $('##SalesRep2').val();
            var SalesRep3 = $('##SalesRep3').val();
            var SalesRep1Per = $('##SalesRep1Percentage').val();
            var SalesRep2Per = $('##SalesRep2Percentage').val();
            var SalesRep3Per = $('##SalesRep3Percentage').val();
            $('##ppSalesRep1').val(SalesRep1);
            $('##ppSalesRep2').val(SalesRep2);
            $('##ppSalesRep3').val(SalesRep3);
            $('##ppSalesRep1Per').val(SalesRep1Per);
            $('##ppSalesRep2Per').val(SalesRep2Per);
            $('##ppSalesRep3Per').val(SalesRep3Per);
            $('body').addClass('noscroll');
            document.getElementById('ModalSalesRepCommission').style.display = "block";
        }

        function saveCommision(){
            var SalesRep1 = $('##ppSalesRep1').val();
            var SalesRep2 = $('##ppSalesRep2').val();
            var SalesRep3 = $('##ppSalesRep3').val();
            var SalesRep1Per = $('##ppSalesRep1Per').val();
            var SalesRep2Per = $('##ppSalesRep2Per').val();
            var SalesRep3Per = $('##ppSalesRep3Per').val();
            <cfif structKeyExists(url, "loadid") AND len(trim(url.loadid)) AND url.loadID NEQ 0>
                $(".loadOverlay").show();
                $('##loader').show();
                $('##loadingmsg').show();
                $.ajax({
                    type    : 'POST',
                    url     : "../gateways/loadgateway.cfc?method=updateLoadRepCommission",
                    data    : {dsn : '#application.DSN#', loadId : '#url.loadid#',SalesRep1:SalesRep1,SalesRep2:SalesRep2,SalesRep3:SalesRep3,SalesRep1Per:SalesRep1Per,SalesRep2Per:SalesRep2Per,SalesRep3Per:SalesRep3Per},
                    success :function(ajaxRes){
                        $(".loadOverlay").hide();
                        $('##loader').hide();
                        $('##loadingmsg').hide();
                    }
                });
            </cfif>
            $('##SalesRep1').val(SalesRep1);
            $('##SalesRep2').val(SalesRep2);
            $('##SalesRep3').val(SalesRep3);
            $('##SalesRep1Per').val(SalesRep1Per);
            $('##SalesRep2Per').val(SalesRep2Per);
            $('##SalesRep3Per').val(SalesRep3Per);
            
            document.getElementById('ModalSalesRepCommission').style.display= "none";
            $('body').removeClass('noscroll');
        }
        function ajxUpdDispatchNote(loadid){

            var dispatchNotes = $('##dispatchNotes').val();
            $.ajax({
                type    : 'POST',
                url     : "../gateways/loadgateway.cfc?method=ajxUpdDispatchNote",
                data    : {LoadID : loadid , dsn : '#application.dsn#' , notes:dispatchNotes},
                success :function(){     
                }
            });
        }

        function customDriverPay(customDriverPay){
            if($(customDriverPay).prop("checked")){
                $('.CustomDriverPay').prop('checked',true);
                $('.divCustomDriverPayOptions').show();
            }
            else{
                $('.CustomDriverPay').prop('checked',false);
                $('.divCustomDriverPayOptions').hide();
                $('.chkCustomDriverPayFlatRate').prop('checked',false);
                $('.chkCustomDriverPayPercentage').prop('checked',false);
                $('.span_CustomDriverPayFlatRate').hide();
                $('.span_CustomDriverPayPercentage').hide();
                $('.customDriverPayFlatRate').val(0);
                $('.customDriverPayPercentage').val(0);
                $('##CarrierRate').attr('readonly',false);
                $('##CarrierRate').css('background-color','##ffffff');
            }
            calculateCustomDriverPay();
        }

        function customDriverPayOption(chkBx){
            var id = $(chkBx).prop('id');

            $('##CarrierRate').attr('readonly',false);
            $('##CarrierRate').css('background-color','##ffffff');

            if($(chkBx).hasClass('chkCustomDriverPayFlatRate')){
                var index = id.replace("chkCustomDriverPayFlatRate","");
                if($(chkBx).prop('checked')){
                    $('##span_CustomDriverPayFlatRate'+index).show();
                    $('##span_CustomDriverPayPercentage'+index).hide();
                    $('##chkCustomDriverPayPercentage'+index).prop('checked',false);
                    $('##customDriverPayPercentage'+index).val(0);
                }
                else{
                    $('##span_CustomDriverPayFlatRate'+index).hide();
                    $('##customDriverPayFlatRate'+index).val(0);
                }
            }

            if($(chkBx).hasClass('chkCustomDriverPayPercentage')){
                var index = id.replace("chkCustomDriverPayPercentage","");
                if($(chkBx).prop('checked')){
                    $('##span_CustomDriverPayPercentage'+index).show();
                    $('##span_CustomDriverPayFlatRate'+index).hide();
                    $('##chkCustomDriverPayFlatRate'+index).prop('checked',false);
                    $('##customDriverPayFlatRate'+index).val(0);
                }
                else{
                    $('##span_CustomDriverPayPercentage'+index).hide();
                    $('##customDriverPayPercentage'+index).val(0);
                }
            }

            $('.chkCustomDriverPayFlatRate,.chkCustomDriverPayPercentage').each(function(i, obj) {
                if($(this).prop('checked')){
                    $('##CarrierRate').attr('readonly',true);
                    $('##CarrierRate').css('background-color','##e3e3e3');
                }
            })

            calculateCustomDriverPay();
        }

        function calculateCustomDriverPay(){
            var CarrierRate = 0;
            var TotalCustomerCharges = $('##TotalCustomerChargesHidden').val();
            $('.customDriverPayFlatRate').each(function(i, obj) {
                var flatRate=$.trim($(this).val());
                if(isNaN(flatRate) || !flatRate.length){
                    alert('Invalid FlatRate.');
                    $(this).val(0);
                    $(this).focus();
                }
                else{
                     CarrierRate = CarrierRate + parseFloat(flatRate);
                }
            })

            $('.customDriverPayPercentage').each(function(i, obj) {
                var Percentage=$.trim($(this).val());
                if(isNaN(Percentage) || !Percentage.length){
                    alert($(this).attr('id'));
                    alert('Invalid Percentage.');
                    $(this).val(0);
                    $(this).focus();
                }
                else{
                    var rate = (TotalCustomerCharges*Percentage)/100;
                    CarrierRate = CarrierRate + parseFloat(rate);
                }
            })

            $('##CarrierRate').val(CarrierRate);
            formatDollarNegative(CarrierRate, "CarrierRate");
            updateTotalAndProfitFields();
        }

        function toggleCommodities(cntrl,stop){
            if(cntrl==0){
                $('.commodityToggle'+stop).hide();
            }
            else{
                $('.commodityToggle'+stop).show();
            }
        }

        function checkMultiplePickupDate(stop){
            var date = $('##shipperPickupDate'+stop).val();
            var multipleDates = $('##shipperPickupDateMultiple'+stop).val();
            var newMultipleDates = [];

            if($.trim(multipleDates).length){
                var arr = multipleDates.split(",");
                var newmultipleDates = "" 
                for(var i = 0 ; i < arr.length ; i++) {
                    var mDate = arr[i];
                    if(new Date(mDate) >= new Date(date))
                    {
                        newMultipleDates.push(mDate);
                    }
                }
            }
            $('##shipperPickupDateMultiple'+stop).val(newMultipleDates)
        }

        function selectAllCarriers(ckbox){
            if($(ckbox).prop("checked")){
                 $(".ckLanes").prop('checked', true);
            }
            else{
                $(".ckLanes").prop('checked', false);
            }
        }
</script>
<img src="images/loadingbar.gif" id="loader">
<strong id="loadingmsg">Please Wait.</strong>
<script src="https://momentjs.com/downloads/moment.js"></script>
<script src="https://momentjs.com/downloads/moment-timezone-with-data.js"></script>
<script type="text/javascript">
    $(document).ready(function(){
        var timeZone = moment.tz.guess();
        var time = new Date();
        var timeZoneOffset = time.getTimezoneOffset();
        $('##TimeZone').val(moment.tz.zone(timeZone).abbr(timeZoneOffset));
    })
</script>
</cfoutput>
<cfset tickEnd = GetTickCount()>
<cfset testTime = tickEnd - tickBegin>

<cfscript>
    public string function myCurrencyFormatter(num) {
      var neg = (num < 0);
      var str = dollarFormat(abs(num));
      if (neg) {
        str = Replace(str,"$","-$","all");
      }
      return str;
    }
</cfscript>
<cfoutput>
    <script type="text/javascript">
        $( document ).ready(function() { 
            $('.hyperLinkLabel').on("click",function() {
                var EquipID = $(this).next().val();
                if($.trim(EquipID).length){
                    var frieghtBrokerStatus = document.getElementById('frieghtBroker').value;
                    if(frieghtBrokerStatus==0){
                        var url ='index.cfm?event=addDriverEquipment&equipmentid='+EquipID+'&#session.URLToken#&iscarrier=1'
                    }
                    else{
                        var url ='index.cfm?event=addEquipment&equipmentid='+EquipID+'&#session.URLToken#&iscarrier=1'
                    }
                    window.open(url, "_blank");
                }
                else{
                    alert('Please select a Trailer.')
                }
            });
        })
        function openCustomerPopup(custID,ele){
            
            var eleId = $(ele).attr("id");
            var txtLen = document.getElementById(eleId).value.length
            var clickedIndex = document.getElementById(eleId).selectionStart;
            if($.trim(custID).length && clickedIndex < txtLen){
                window.open('index.cfm?event=addCustomer&CustomerID='+custID+'&#session.URLToken#', "_blank");
            }
        }
    </script>
</cfoutput>
<cfif ListContains(session.rightsList,'HideSalesRepNames',',')>
    <cfoutput>
        <script type="text/javascript">
            $( document ).ready(function() {
                $('##multipleSalesRepBtn').hide();
                $("##Salesperson").children("option[value!=#session.empid#]").hide();
            })
        </script>
    </cfoutput>
</cfif>
<cfif ListContains(session.rightsList,'HideDispatcherNames',',')>
    <cfoutput>
        <script type="text/javascript">
            $( document ).ready(function() {
                $('##multipleDispatcherBtn').hide();
                $("##Dispatcher").children("option[value!=#session.empid#]").hide();
            })
        </script>
    </cfoutput>
</cfif>
<!--- Rate Approval --->
<cfif RateApprovalNeeded EQ 1>
    <cfoutput>
        <script type="text/javascript">
        $( document ).ready(function() {    
            $("##loadStatus").css("pointer-events","none").css("opacity","0.5");
            <cfif structKeyExists(url, "ClaimRate")>
                var ele = $('input[name="saveexit"]');
                $('<input name="approveRate" id="approveRate" onclick="approveCarrierRate()" type="button" class="green-btn" value="Approve" style="width:100px !important; float:right; height:48px; position:relative; top:-28px; -webkit-background-size:contain; -moz-background-size:contain;  -o-background-size:contain; background-size:contain;">').insertAfter(ele);
                $(ele).hide();
            </cfif>
        })
        function approveCarrierRate(){
            $.ajax({
                type    : 'POST',
                url     : "ajax.cfm?event=ajxApproveCarrierRate&LoadID=#url.loadid#&#session.URLToken#",
                data    : {},
                success :function(data){
                    document.location.href='index.cfm?event=addload&loadid=#url.loadid#&#session.URLToken#'
                }
            })
        }
        </script>
    </cfoutput>
</cfif>
<!--- Rate Approval --->
<cfif request.qSystemOptions.AutomaticCustomerRateChanges EQ 1>
    <cfoutput>
        <script type="text/javascript">
            $( document ).ready(function() {
                var prevCustomerRate = $('##CustomerRate').val();
                var prevCustomerRatePerMile = $('##CustomerRatePerMile').val();
                var prevTotalCustcommodities = $('##TotalCustcommodities').val();
                $('##CustomerRate,##CustomerRatePerMile,.CustomerRate').change(function(){
                    var id = $(this).attr('id');
                    var custRate = $(this).val();
                    switch(id){
                        case 'CustomerRate':
                            field = "Customer Flat Rate";
                            preRate = $.trim(prevCustomerRate);
                            break;
                        case 'CustomerRatePerMile':
                            field = "Customer Miles Rate";
                            preRate = $.trim(prevCustomerRatePerMile);
                            break;
                        default:
                            field = "Customer Commodities Rate";
                            custRate = $('##TotalCustcommodities').val();
                            preRate = $.trim(prevTotalCustcommodities);
                    }
                    custRate = $.trim(custRate);
                    custRate = custRate.replace('$','');
                    custRate = custRate.replace(/,/g,'');
                    custRate = parseFloat(custRate);
                    custRate = (custRate).toFixed(2);

                    preRate = preRate.replace('$','');
                    preRate = preRate.replace(/,/g,'');
                    preRate = parseFloat(preRate);
                    preRate = (preRate).toFixed(2);

                    switch(id){
                        case 'CustomerRate':
                            prevCustomerRate = custRate;
                            break;
                        case 'CustomerRatePerMile':
                            prevCustomerRatePerMile = custRate;
                            break;
                        default:
                            prevTotalCustcommodities = custRate;
                    }

                    $("##dispatchNotes").prepend(clock()+' - '+ $('##Loggedin_Person').val()+ ' > '+field+' changed from $'+convertDollarNumberFormat(preRate)+' to $'+convertDollarNumberFormat(custRate)+' \n');
                })
            })
        </script>
    </cfoutput>
</cfif>
<cfif request.qSystemOptions.AutomaticCarrierRateChanges EQ 1>
    <cfoutput>
        <script type="text/javascript">
            $( document ).ready(function() {
                var prevCarrierRate = $('##CarrierRate').val();
                var prevCustomerRatePerMile = $('##CarrierRatePerMile').val();
                var prevTotalCarcommodities = $('##TotalCarcommodities').val();
                $('##CarrierRate,##CarrierRatePerMile,.CarrierRate').change(function(){
                    var id = $(this).attr('id');
                    var carrRate = $(this).val();
                    switch(id){
                        case 'CarrierRate':
                            field = "#variables.freightBroker# Flat Rate";
                            preRate = $.trim(prevCarrierRate);
                            break;
                        case 'CarrierRatePerMile':
                            field = "#variables.freightBroker# Miles Rate";
                            preRate = $.trim(prevCustomerRatePerMile);
                            break;
                        default:
                            field = "#variables.freightBroker# Commodities Rate";
                            carrRate = $('##TotalCarcommodities').val();
                            preRate = $.trim(prevTotalCarcommodities);
                    }
                    carrRate = $.trim(carrRate);
                    carrRate = carrRate.replace('$','');
                    carrRate = carrRate.replace(/,/g,'');
                    carrRate = parseFloat(carrRate);
                    carrRate = (carrRate).toFixed(2)

                    preRate = preRate.replace('$','');
                    preRate = preRate.replace(/,/g,'');
                    preRate = parseFloat(preRate);
                    preRate = (preRate).toFixed(2);

                    switch(id){
                        case 'CarrierRate':
                            prevCarrierRate = carrRate;
                            break;
                        case 'CarrierRatePerMile':
                            prevCustomerRatePerMile = carrRate;
                            break;
                        default:
                            prevTotalCarcommodities = carrRate;
                    }

                    $("##dispatchNotes").prepend(clock()+' - '+ $('##Loggedin_Person').val()+ ' > '+field+' changed from $'+convertDollarNumberFormat(preRate)+' to $'+convertDollarNumberFormat(carrRate)+' \n');
                })
            })
        </script>
    </cfoutput>
</cfif>
<cfif request.qSystemOptions.AutomaticCarrierRateChanges EQ 1 OR request.qSystemOptions.AutomaticCarrierRateChanges EQ 1>
    <cfoutput>
        <script type="text/javascript">
            $( document ).ready(function() {
                var prevDirectCost = $('##TotalDirectCost').val();
                $('.directCost ').change(function(){
                    var directCost = $('##TotalDirectCost').val();
                    preRate = $.trim(prevDirectCost);

                    directCost = $.trim(directCost);
                    directCost = directCost.replace('$','');
                    directCost = directCost.replace(/,/g,'');
                    directCost = parseFloat(directCost);
                    directCost = (directCost).toFixed(2)

                    preRate = preRate.replace('$','');
                    preRate = preRate.replace(/,/g,'');
                    preRate = parseFloat(preRate);
                    preRate = (preRate).toFixed(2);

                    prevDirectCost = directCost;
                    $("##dispatchNotes").prepend(clock()+' - '+ $('##Loggedin_Person').val()+ ' > Direct Cost changed from $'+convertDollarNumberFormat(preRate)+' to $'+convertDollarNumberFormat(directCost)+' \n');
                });
            });
        </script>
    </cfoutput>
</cfif>
<!--- Form-Popups --->
<cfoutput>
    <script type="text/javascript">
        $( document ).ready(function() {
            $('.form-popup-close').click(function(){
                $('body').removeClass('formpopup-body-noscroll');
                $(this).closest( ".form-popup" ).hide();
                $('.formpopup-overlay').hide();
            });

            $('.fpCityAuto').each(function(i, tag) {
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
                        $(this).val(ui.item.city);
                        var stateEle = $(this).closest('div').find('.fpStateAuto').attr("id");
                        var zipEle = $(this).closest('div').find('.fpZipAuto').attr("id");
                        if(!$.trim($('##'+stateEle).val()).length){
                            if($("##"+stateEle+" option[value='"+ui.item.state+"']").length){
                                $("##"+stateEle).val(ui.item.state);
                            }
                            else{
                                $("##"+stateEle).val("");
                            }
                        }

                        if(!$.trim($('##'+zipEle).val()).length){
                            $('##'+zipEle).val(ui.item.zip);
                        }
                        return false;
                    }
                });
                $(tag).data("ui-autocomplete")._renderItem = function(ul, item) {
                    return $( "<li>"+item.city+"<br/><b><u>State</u>:</b> "+ item.state+"&nbsp;&nbsp;&nbsp;<b><u>Zip</u>:</b>" + item.zip+"</li>" )
                            .appendTo( ul );
                }
            });

            $('.fpZipAuto').each(function(i, tag) {
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
                        $(this).val(ui.item.zip);
                        var cityEle = $(this).closest('div').find('.fpCityAuto').attr("id");
                        var stateEle = $(this).closest('div').find('.fpStateAuto').attr("id");
                        if(!$.trim($('##'+cityEle).val()).length){
                            $('##'+cityEle).val(ui.item.city);
                        }
                        if(!$.trim($('##'+stateEle).val()).length){
                            if($("##"+stateEle+" option[value='"+ui.item.state+"']").length){
                                $("##"+stateEle).val(ui.item.state);
                            }
                            else{
                                $("##"+stateEle).val("");
                            }
                        }
                        return false;
                    }
                });
                $(tag).data("ui-autocomplete")._renderItem = function(ul, item) {
                    return $( "<li>"+item.zip+"<br/><b><u>State</u>:</b> "+ item.state+"&nbsp;&nbsp;&nbsp;<b><u>City</u>:</b>" + item.city+"</li>" )
                            .appendTo( ul );
                }
            });
        })

        function clearTheCustomer() {
            $('##cutomerIdAuto').val('');
            $('##cutomerIdAutoValueContainer').val('');
            $('##CustInfo1 label[class="field-textarea"]').html('');
            $('##CustInfo1 input[name="CustomerContact"]').val('');
            $('##CustInfo1 input[name="customerPhone"]').val('');
            $('##CustInfo1 input[name="customerPhoneExt"]').val('');
            $('##CustInfo1 input[name="customerCell"]').val('');
            $('##CustInfo1 input[name="customerFax"]').val('');
            $('##CustInfo1 input[name="CustomerEmail"]').val('');
            $('input[name="customerPO"]').val('');
            $('input[name="customerBOL"]').val('');
            $('input[name="readyDat"]').val('');
            $('input[name="customerBOL"]').val('');
            $('input[name="arriveDat"]').val('');
            $('input[name="Excused"]').prop('checked', false);
        }
        <cfif request.qSystemSetupOptions.ShowMaxCarrRateInLoadScreen EQ 1 AND NOT ListContains(session.rightsList,'ShowMaxCarrRateInLoadScreen',',')>
            $( document ).ready(function() {
                $( "body" ).on( "focusin", ".CarrierRate",function() {
                    var oldval = $(this).val();
                    $(this).attr('data-oldval', oldval);
                    
                });

                $( "body" ).on( "change", ".CarrierRate",function() {
                    var prev = $(this).attr('data-oldval').replace("$","").replace(/,/g,'');
                    var current = $(this).val().replace("$","").replace(/,/g,'');
                    var check = document.getElementById('LimitCarrierRate')
                    var MaxCarrRate = $("##MaxCarrierRate").val();
                    var totalCarrCharges = $("##TotalCarrierChargesHidden").val();
                    if(check.checked){
                        if(totalCarrCharges > MaxCarrRate){
                                alert("You exceeded the maximum rate of $"+ MaxCarrRate)
                                var oldVal = $(this).attr('data-oldval');
                                $(this).val(oldVal);
                                CalculateTotal('#Application.dsn#');
                                return false
                        }
                    }
                });
                $( "body" ).on( "focusin", "##CarrierRatePerMile",function() {
                    var oldval = $(this).val();
                    $(this).attr('data-oldvalue', oldval);
                    
                });

                $( "body" ).on( "change", "##CarrierRatePerMile",function() {
                    var prev = $(this).attr('data-oldvalue')
                    var current = $(this).val().replace("$","").replace(/,/g,'');
                    var check = document.getElementById('LimitCarrierRate')
                    var MaxCarrRate = $("##MaxCarrierRate").val();
                    carrierRatePerMileChanged();
                    var totalCarrCharges = $("##TotalCarrierChargesHidden").val();
                    if(check.checked){
                        if(Number(totalCarrCharges) > Number(MaxCarrRate)){
                                alert("You exceeded the maximum rate of $"+ MaxCarrRate)
                                var oldVal = $(this).attr('data-oldvalue');
                                document.getElementById('CarrierRatePerMile').value = prev;
                                return false
                        }
                    }
                });
                $( "body" ).on( "focusin", "##CarrierRate",function() {
                    var oldval = $(this).val();
                    $(this).attr('data-oldvalue', oldval);
                    
                });

                $( "body" ).on( "change", "##CarrierRate",function() {
                    var prev = $(this).attr('data-oldvalue')
                    var current = $(this).val().replace("$","").replace(/,/g,'');
                    var check = document.getElementById('LimitCarrierRate')
                    var MaxCarrRate = $("##MaxCarrierRate").val();
                    carrierRatePerMileChanged();
                    var totalCarrCharges = $("##TotalCarrierChargesHidden").val();
                    if(check.checked){
                        if(Number(totalCarrCharges) > Number(MaxCarrRate)){
                                alert("You exceeded the maximum rate of $"+ MaxCarrRate)
                                var oldVal = $(this).attr('data-oldvalue');
                                document.getElementById('CarrierRate').value = prev;
                                return false
                        }
                    }
                });

            });
        </cfif>
    </script>
    <div class="formpopup-overlay"></div>
</cfoutput>
<cfinclude template="formpopup/AddSalesRepCommision.cfm">
<cfinclude template="formpopup/AddNewCustomer.cfm">
<cfinclude template="formpopup/AddNewCarrierContact.cfm">
<cfinclude template="formpopup/ViewCarrierContact.cfm">
<cfinclude template="formpopup/DHMiles.cfm">
<cfinclude template="formpopup/EDispatch.cfm">
<cfinclude template="formpopup/AddDispatcherCommision.cfm">