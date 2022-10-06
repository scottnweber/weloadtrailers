<cfinvoke component="#variables.objloadGateway#" method="getSystemSetupOptions" returnvariable="request.qGetSystemSetupOptions" />
<cfinvoke component="#variables.objAgentGateway#" method="getAllAgent" returnvariable="request.qAgent" />
<cfinvoke component="#variables.objloadGateway#" method="getcurAgentMaildetails" returnvariable="request.qcurMailAgentdetails" employeID="#session.empid#" />
<cfoutput>
    
    <cfparam name="variables.PromptToAddDispatchers" default="0">
    <cfparam name="variables.PromptToAddDrivers" default="0">
    <cfparam name="variables.PromptToAddOtherContacts" default="0">
    <cfparam name="variables.PromptForLanes" default="0">
    <cfparam name="variables.PromptForELDStatus" default="0">
    <cfparam name="variables.PromptForCertifications" default="0">
    <cfparam name="variables.PromptForTruckTrailer" default="0">
    <cfparam name="variables.PromptForModesofTransportation" default="0">
    <cfparam name="variables.PromptForPaymentoptions" default="0">
    <cfparam name="variables.PromptForACHInformation" default="0">
    <cfparam name="variables.KeepCarrierInactive" default="0">
    <cfparam name="variables.RequireFedTaxID" default="1">
    <cfparam name="variables.UserOnBoardingInvite" default="">
    <cfparam name="variables.UseEmail" default="">
    <cfparam name="variables.RequireBIPDInsurance" default="0">
    <cfparam name="variables.RequireCargoInsurance" default="0">
    <cfparam name="variables.RequireGeneralInsurance" default="0">
    <cfparam name="variables.RequireVoidedCheck" default="0">
    <cfparam name="variables.BIPDMin" default="750000">
    <cfparam name="variables.CargoMin" default="100000">
    <cfparam name="variables.GeneralMin" default="0">
    <cfparam name="variables.AllowDownloadAndSubmitManually" default="0">

    <cfinvoke component="#variables.objCarrierGateway#" method="getOnboardingSettings" returnvariable="qSettings" />
    <cfset variables.PromptToAddDispatchers = qSettings.PromptToAddDispatchers>
    <cfset variables.PromptToAddDrivers = qSettings.PromptToAddDrivers>
    <cfset variables.PromptToAddOtherContacts = qSettings.PromptToAddOtherContacts>
    <cfset variables.PromptForLanes = qSettings.PromptForLanes>
    <cfset variables.PromptForELDStatus = qSettings.PromptForELDStatus>
    <cfset variables.PromptForCertifications = qSettings.PromptForCertifications>
    <cfset variables.PromptForTruckTrailer = qSettings.PromptForTruckTrailer>
    <cfset variables.PromptForModesofTransportation = qSettings.PromptForModesofTransportation>
    <cfset variables.PromptForPaymentoptions = qSettings.PromptForPaymentoptions>
    <cfset variables.PromptForACHInformation = qSettings.PromptForACHInformation>
    <cfset variables.KeepCarrierInactive = qSettings.KeepCarrierInactive>
    <cfset variables.RequireFedTaxID = qSettings.RequireFedTaxID>
    <cfset variables.UserOnBoardingInvite = qSettings.UserOnBoardingInvite>
    <cfset variables.UseEmail = qSettings.UseEmail>
    <cfset variables.RequireBIPDInsurance = qSettings.RequireBIPDInsurance>
    <cfset variables.RequireCargoInsurance = qSettings.RequireCargoInsurance>
    <cfset variables.RequireGeneralInsurance = qSettings.RequireGeneralInsurance>
    <cfset variables.RequireVoidedCheck = qSettings.RequireVoidedCheck>
    <cfset variables.BIPDMin = qSettings.BIPDMin>
    <cfset variables.CargoMin = qSettings.CargoMin>
    <cfset variables.GeneralMin = qSettings.GeneralMin>
    <cfset variables.AllowDownloadAndSubmitManually = qSettings.AllowDownloadAndSubmitManually>
    <style type="text/css">
        .white-mid div.form-con label {
            float: left;
            text-align: right;
            width: 140px;
            padding: 0 10px 0 0;
            font-size: 11px;
            font-weight: bold;
            color: ##000000;
        }
        header{
            border: 1px solid;
            height: 75px;
            position: relative;
            margin-top: 10px;
            width: 360px;
        }

        header > h3{
            position: absolute;
            top: -8px;
            left: 21px;
            background: ##defaf9;
            padding: 0px 0px;
            font-weight: bold;
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

        
        .white-mid div.form-con input.small_chk{
            width: 14px;
            border: 0px solid ##b3b3b3;
            padding: 0px 0px 0 0px;
            margin: 0 0 2px 0;
            font-size: 11px;
            margin-right: 8px !important;
        }
    
        .btn {
            background: url(../webroot/images/button-bg.gif) left top repeat-x;
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
            margin-left: 150px;
        }
        .msg-area-success{
            border: 1px solid ##a4da46;
            padding: 5px 15px;
            font-weight: normal;
            width: 82%;
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
            width: 82%;
            float: left;
            margin-top: 5px;
            margin-bottom:  5px;
            background-color: ##e4b9c6;
            font-weight: bold;
            font-style: italic;
        }
        .InfotoolTip{
            margin-top: -5px;
        }
    </style>
    <script type="text/javascript">
        function validateOnboardSettings(){
            var BIPDMin = $("input[name='BIPDMin']").val();
            BIPDMin = BIPDMin.replace("$","");
            BIPDMin = BIPDMin.replace(/,/g,"");
            if(isNaN(BIPDMin) || !BIPDMin.length) {
                alert("Invalid BIPD Coverage.");
                $("input[name='BIPDMin']").focus();
                return false;
            }

            var CargoMin = $("input[name='CargoMin']").val();
            CargoMin = CargoMin.replace("$","");
            CargoMin = CargoMin.replace(/,/g,"");
            if(isNaN(CargoMin) || !CargoMin.length) {
                alert("Invalid Cargo Coverage.");
                $("input[name='CargoMin']").focus();
                return false;
            }

            var GeneralMin = $("input[name='GeneralMin']").val();
            GeneralMin = GeneralMin.replace("$","");
            GeneralMin = GeneralMin.replace(/,/g,"");
            if(isNaN(GeneralMin) || !GeneralMin.length) {
                alert("Invalid General Coverage.");
                $("input[name='GeneralMin']").focus();
                return false;
            }
        }

        function copyToClipboard() {
            var $temp = $("<input>");
            $("body").append($temp);
            $temp.val('https://#cgi.HTTP_HOST#/#trim(listFirst(cgi.SCRIPT_NAME,'/'))#/www/webroot/OnboardingLink.cfm?CompanyID=#session.CompanyID#').select();
            document.execCommand("copy");
            $temp.remove();
            alert('Onboarding Link copied.');
        }

        $(document).ready(function(){
            $( "input[name='UseEmail']" ).click(function() {
                var UseEmailSelected = $(this).val();
                var UseEmail = #variables.UseEmail#;
                var EmailValidated = '#request.qcurMailAgentdetails.EmailValidated#'
                if(UseEmailSelected == 2 && EmailValidated == 0){
                    alert("Email not validated.");
                    return false;
                }
            })
            if($("input[name='PromptForACHInformation']").is(':checked')){
                $("##voidedCheck").show();
                $("##voided").show();
            }
            
        })
        function reqvoidedCheck() {
            
            if($("input[name='PromptForACHInformation']").is(':checked')){
                $("##voidedCheck").show();
                $("##voided").show();
            }else{
                $("##voidedCheck").prop('checked',false)
                $("##voidedCheck").hide();
                $("##voided").hide();
            }
        }
    </script>
    <cfif structKeyExists(session, "OnboardingSettingMessage")>
        <div id="message" class="msg-area-#session.OnboardingSettingMessage.res#">#session.OnboardingSettingMessage.msg#</div>
        <cfset structDelete(session, "OnboardingSettingMessage")>
        <div class="clear"></div>
    </cfif>

    <div class="clear"></div>
    <cfinclude template="OnboardingDocTab.cfm">
    <div class="white-con-area" style="height: 36px;background-color: ##82bbef;width:852px;text-align: center;">
        <h2 style="color:white;font-weight:bold;">Onboarding Settings</h2>
    </div>
    <div class="clear"></div>
    <cfform id="DocForm" name="DocForm" action="index.cfm?event=OnboardSetting:Process&#session.URLToken#" method="post" preserveData="yes" onsubmit="return validateOnboardSettings();">
        <div class="clear"></div>
        <div class="white-con-area">
            <div class="white-mid">
                <div class="form-con" style="width: 430px;">
                    <fieldset>
                        <label style="width: 210px;">Prompt carrier to add dispatchers?</label>
                        <input name="PromptToAddDispatchers" type="checkbox" value="1" class="small_chk" style="float: left;" <cfif variables.PromptToAddDispatchers> checked </cfif>>
                        <div class="clear"></div>

                        <label style="width: 210px;">Prompt carrier to add drivers?</label>
                        <input name="PromptToAddDrivers" type="checkbox" value="1" class="small_chk" style="float: left;" <cfif variables.PromptToAddDrivers> checked </cfif>>
                        <div class="clear"></div>

                        <label style="width: 210px;">Prompt carrier to add other contacts?</label>
                        <input name="PromptToAddOtherContacts" type="checkbox" value="1" class="small_chk" style="float: left;" <cfif variables.PromptToAddOtherContacts> checked </cfif>>
                        <div class="clear"></div>

                        <label style="width: 210px;">Prompt carrier for lanes they run?</label>
                        <input name="PromptForLanes" type="checkbox" value="1" class="small_chk" style="float: left;" <cfif variables.PromptForLanes> checked </cfif>>
                        <div class="clear"></div>

                        <label style="width: 210px;">Prompt for ELD status?</label>
                        <input name="PromptForELDStatus" type="checkbox" value="1" class="small_chk" style="float: left;" <cfif variables.PromptForELDStatus> checked </cfif>>
                        <div class="clear"></div>

                        <label style="width: 210px;">Prompt for Certifications?</label>
                        <input name="PromptForCertifications" type="checkbox" value="1" class="small_chk" style="float: left;" <cfif variables.PromptForCertifications> checked </cfif>>
                        <div class="clear"></div>

                        <label style="width: 210px;">Prompt for Truck & Trailer info?</label>
                        <input name="PromptForTruckTrailer" type="checkbox" value="1" class="small_chk" style="float: left;" <cfif variables.PromptForTruckTrailer> checked </cfif>>
                        <div class="clear"></div>

                        <label style="width: 210px;">Prompt for Modes of Transportation?</label>
                        <input name="PromptForModesofTransportation" type="checkbox" value="1" class="small_chk" style="float: left;" <cfif variables.PromptForModesofTransportation> checked </cfif>>
                        <div class="clear"></div>

                        <label style="width: 210px;">Prompt for Payment options?</label>
                        <input name="PromptForPaymentoptions" type="checkbox" value="1" class="small_chk" style="float: left;" <cfif variables.PromptForPaymentoptions> checked </cfif>>
                        <div class="clear"></div>

                        <label style="width: 210px;">Prompt for ACH Information?</label>
                        <input name="PromptForACHInformation" type="checkbox" value="1" onclick="return reqvoidedCheck()" class="small_chk" style="float: left;" <cfif variables.PromptForACHInformation> checked </cfif>>
                        <label style="width: 120px;display:none;" id="voided">Require Voided Check</label>
                        <input type="checkbox" name="voidedCheck" id="voidedCheck" style="float: left;display:none;" class="small_chk" <cfif variables.RequireVoidedCheck>checked</cfif>>
                        <div class="clear"></div>

                        <label style="width: 210px;">Keep Carrier inactive until onboarding is completed and user verified</label>
                        <input name="KeepCarrierInactive" type="checkbox" value="1" class="small_chk" style="float: left;" <cfif variables.KeepCarrierInactive> checked </cfif>>
                        <div class="clear"></div>

                        <label style="width: 210px;">Allow Download & Submit Manually</label>
                        <input name="AllowDownloadAndSubmitManually" type="checkbox" value="1" class="small_chk" style="float: left;" <cfif variables.AllowDownloadAndSubmitManually> checked </cfif>>
                        <div class="clear"></div>

                        <label style="width: 210px;">Require Fed Tax ID</label>
                        <input name="RequireFedTaxID" type="checkbox" value="1" class="small_chk" style="float: left;" <cfif variables.RequireFedTaxID> checked </cfif>>
                        <div class="clear"></div>

                        <label style="width: 210px;">Require BIPD Insurance</label>
                        <input name="RequireBIPDInsurance" type="checkbox" value="1" class="small_chk" style="float: left;" <cfif variables.RequireBIPDInsurance> checked </cfif>>
                        <label style="width: 100px;">BIPD Coverage:</label>
                        <input type="text" name="BIPDMin" value="$#numberFormat(variables.BIPDMin)#" style="width: 60px;text-align: right;">
                        <div class="clear"></div>

                        <label style="width: 210px;">Require Cargo Insurance</label>
                        <input name="RequireCargoInsurance" type="checkbox" value="1" class="small_chk" style="float: left;" <cfif variables.RequireCargoInsurance> checked </cfif>>
                        <label style="width: 100px;">Cargo Coverage:</label>
                        <input type="text" name="CargoMin" value="$#numberFormat(variables.CargoMin)#" style="width: 60px;text-align: right;">
                        <div class="clear"></div>

                        <label style="width: 210px;">Require General Liability Insurance</label>
                        <input name="RequireGeneralInsurance" type="checkbox" value="1" class="small_chk" style="float: left;" <cfif variables.RequireGeneralInsurance> checked </cfif>>
                        <label style="width: 100px;">General Coverage:</label>
                        <input type="text" name="GeneralMin" value="$#numberFormat(variables.GeneralMin)#" style="width: 60px;text-align: right;">
                        <div class="clear"></div>

                        <input id="save" name="save" type="submit" class="green-btn" value="Save" style="margin-left: 110px;">
                        <input type="button" onclick="javascript:history.back();" name="cancel" class="bttn" value="Cancel" style="width: 125px !important;position:relative;">
                        <cfif request.qsystemoptions.OnBoardCarrier EQ 1>
                            <input type="button" onclick="copyToClipboard()" name="CopyOnboardingLink" class="bttn" value="Copy Onboarding Link" style="width: 140px !important; float:right; position:absolute; text-align:center;">
                        </cfif>
                    </fieldset>
                </div>
                <div class="form-con" style="width: 375px;">
                    <fieldset style="border: solid 1px;padding: 5px;">
                        <legend style="font-weight: bold;font-size: 12px;">Select Email Address to Send Onboarding Email</legend>
                        <div style="margin:15px 15px;">       
                            <input type="radio" name="UseEmail" value="0" style="width:15px; padding:0px 0px 0 0px;margin-bottom:5px;" <cfif variables.UseEmail EQ 0> checked </cfif>>
                            <label class="normal" for="none" style="text-align:left; padding:2px 0 0 0;width: 110px;">Use Company Email:</label>
                            <select name="UserOnBoardingInvite" id="UserOnBoardingInvite">
                                <option value="">Select</option>
                                <cfloop query="request.qAgent">
                                    <cfif request.qAgent.EmailValidated EQ 1>
                                        <option value="#request.qAgent.employeeID#" <cfif variables.UserOnBoardingInvite EQ request.qAgent.employeeID> selected </cfif>  >#request.qAgent.name#(#request.qAgent.emailId#)</option>
                                    </cfif>
                                </cfloop>
                            </select>
                            <div class="clear"></div>
                            <input type="radio" name="UseEmail" value="1" style="width:15px; padding:0 0 0 0;margin-bottom:5px;" <cfif variables.UseEmail EQ 1> checked </cfif>>
                            <label class="normal" for="none" style="text-align:left; padding:2px 0 0 0;width: 110px;">Use No Reply Email:</label>
                            <input class="disabledLoadInputs" style="position:absolute;" type="text" value="noreply@loadmanager.com" readonly> 
                            <div class="clear" style="margin-top: 28px;"></div>
                            <input type="radio" name="UseEmail" value="2" style="width:15px; padding:0 0 0 0;margin-bottom:5px;" <cfif variables.UseEmail EQ 2> checked </cfif>>
                            <label class="normal" for="none" style="text-align:left; padding:2px 0 0 0;width: 110px;">Use User's Email</label>
                        </div>        
                    </fieldset>
                </div>
                <div class="clear"></div>
            </div>
            <div class="white-bot"></div>
        </div>
    </cfform>  
</cfoutput>

    