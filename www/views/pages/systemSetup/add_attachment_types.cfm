<cfinvoke component="#variables.objloadGateway#" method="getSystemSetupOptions" returnvariable="request.qSystemSetupOptions" />
<cfoutput>
    <cfif structKeyExists(url, "deleteID")>
        <cfinvoke component="#variables.objLoadGateway#" method="deleteAttachmentType" ID="#url.deleteID#" returnvariable="session.Message"/>
        <cfif structKeyExists(url, "RedirectTo")>
            <cflocation url="index.cfm?event=#url.RedirectTo#&#session.URLToken#">
        <cfelse>
            <cflocation url="index.cfm?event=attachmentTypes&#session.URLToken#">
        </cfif>
    </cfif>
    <cfif structKeyExists(form, "submitAttachmentType")>
        <cfinvoke component="#variables.objLoadGateway#" method="saveAttachmentType" frmstruct="#form#" returnvariable="session.Message"/>
        <cfif structKeyExists(form, "RedirectTo")>
            <cflocation url="index.cfm?event=#form.RedirectTo#&#session.URLToken#">
        <cfelse>
            <cflocation url="index.cfm?event=attachmentTypes&#session.URLToken#">
        </cfif>
    </cfif>
    <cfparam name="variables.ID" default="">
    <cfparam name="variables.Description" default="">
    <cfparam name="variables.Type" default="">
    <cfparam name="variables.Required" default="0">
    <cfparam name="variables.Recurring" default="0">
    <cfparam name="variables.RenewalDate" default="">
    <cfparam name="variables.Interval" default="12">
    <cfif structKeyExists(url, "ID") AND len(trim(url.ID))>
        <cfinvoke component="#variables.objLoadGateway#" method="getAttachmentTypeDetail" ID="#url.ID#" returnvariable="qAttachmentType" />
        <cfif qAttachmentType.recordcount>
            <cfset variables.ID = qAttachmentType.AttachmentTypeID>
            <cfset variables.Description = qAttachmentType.Description>
            <cfset variables.Type = qAttachmentType.AttachmentType>
            <cfset variables.Required = qAttachmentType.Required>
            <cfset variables.Recurring = qAttachmentType.Recurring>
            <cfset variables.RenewalDate = qAttachmentType.RenewalDate>
            <cfif len(trim(qAttachmentType.Interval))>
                <cfset variables.Interval = qAttachmentType.Interval>
            </cfif>
        </cfif>
    <cfelseif structKeyExists(url, "RedirectTo")>
        <cfset variables.Type = "Carrier">
    </cfif>
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
        .ui-datepicker-trigger{
            float: left;
        }
    </style>
    <script>
        function validateType(){
            if($.trim($('##Description').val().length)==0){
                alert('Please enter Description.');
                $('##Description').focus();
                return false;
            }
            return true;
        }

        $(document).ready(function(){
            <cfif structKeyExists(url, "RedirectTo")>
                $('##Required').click(function(){
                    var ckd = $(this).is(":checked");
                    if(ckd){
                        $('.Recurring').show();
                        $('.Renewal').hide();
                    }
                    else{
                        $('.Recurring').hide();
                        $('##Recurring').prop("checked",false);
                    }
                })
                $('##Recurring').click(function(){
                    var ckd = $(this).is(":checked");
                    if(ckd){
                        $('.Renewal').show();
                    }
                    else{
                        $('.Renewal').hide();
                    }
                })
            </cfif>
        })
    </script>
    <h1><cfif structKeyExists(url, "ID") AND len(trim(url.ID))>Edit<cfelse>Add</cfif> Attachment Type</h1>
    <cfif structKeyExists(url, "ID") AND len(trim(url.ID))>
        <div class="delbutton" style="float:left;margin-left: 340px;margin-top: -33px;">
            <a href="index.cfm?event=addAttachmentType&deleteid=#url.id#&#session.URLToken#<cfif structKeyExists(url, "RedirectTo")>&RedirectTo=#url.RedirectTo#</cfif>" onclick="return confirm('Are you sure you want to delete this attachment type?');">  Delete</a>
        </div>
    </cfif>
    <div class="clear"></div>
    <cfform id="AttachmentTypeForm" name="AttachmentTypeForm" action="index.cfm?event=addAttachmentType&#session.URLToken#" method="post" preserveData="yes" onsubmit="return validateType();">
        <input type="hidden" name="ID" value="#variables.ID#">
        <div class="clear"></div>
        <div class="white-con-area" style="width:999px">
            <div class="white-mid" style="width:999px">
                <div class="form-con" style="width:400px;padding:0;background-color: ##defaf9 !important;">
                    <div style="height: 36px;background-color: ##82bbef;margin-bottom: 5px;float: right;">
                        <h2 style="color:white;font-weight:bold;padding-top: 10px;width:390px;text-align: center;">Attachment Type</h2>
                    </div>
                    <fieldset>
                        <cfif structKeyExists(url, "RedirectTo")>
                            <input type="hidden" name="Type" value="#variables.Type#">
                            <input type="hidden" name="RedirectTo" value="#url.RedirectTo#">
                        <cfelse>
                            <label>Type:</label>
                            <select tabindex="1" name="Type" style="float: left;width: 206px;height: 21px;background: ##FFFFFF;    border: 1px solid ##b3b3b3;padding: 0; margin: 0 0 4px 0;font-size: 11px;">
                                <option <cfif variables.Type EQ "Load"> selected </cfif> value="Load">Load</option>
                                <option <cfif variables.Type EQ "Customer"> selected </cfif> value="Customer">Customer</option>
                                <cfif listFindNoCase("1,2", request.qSystemSetupOptions.freightBroker)>
                                    <option <cfif variables.Type EQ "Carrier"> selected </cfif> value="Carrier">Carrier</option>
                                </cfif>
                                <cfif listFindNoCase("0,2", request.qSystemSetupOptions.freightBroker)>
                                    <option <cfif variables.Type EQ "Driver"> selected </cfif> value="Driver">Driver</option>
                                </cfif>
                            </select>
                            <div class="clear"></div>
                        </cfif>
                        <label>Description:</label>
                        <input name="Description" id="Description" type="text" value="#variables.Description#" maxlength="100" tabindex="2" style="float: left;width: 200px;background: ##FFFFFF;border: 1px solid ##b3b3b3;padding: 2px 2px 0 2px;margin: 0 0 8px 0;font-size: 11px;    margin-right: 8px !important;height: 18px;">
                        <div class="clear"></div>
                        <cfif structKeyExists(url, "RedirectTo")>
                            <label>Required:</label>
                            <input name="Required" id="Required" type="checkbox" value="1" tabindex="3" class="small_chk" <cfif variables.Required> checked </cfif> style="float: left;">
                            <div class="clear"></div>
                        
                            <div class="Recurring" <cfif NOT variables.Required> style="display: none;" </cfif>>
                                <label>Recurring:</label>
                                <input name="Recurring" id="Recurring" type="checkbox" value="1" tabindex="4" class="small_chk" <cfif variables.Recurring> checked </cfif> style="float: left;">
                                <div class="clear"></div>
                                <div class="Renewal"  style="margin-left: 25px;" <cfif NOT variables.Recurring> style="display: none;" </cfif>>
                                    <label style="width: 76px;">Interval:</label>
                                    <select name="Interval" id="Interval" class="medium myElements" style="width: 58px;" tabindex="6">
                                        <cfloop from="1" to="12" index="i">
                                            <option value="#i#" <cfif variables.Interval EQ i> selected </cfif>>#i#</option>
                                        </cfloop>
                                    </select>
                                    <span style="margin-left: 5px;">Months</span>
                                </div>
                                <div class="clear"></div>
                            </div>
                        </cfif>
                        <input id="save" name="submitAttachmentType" type="submit" class="green-btn" value="Save" style="margin-left: 110px;" tabindex="7">
                        <input type="button" onclick="javascript:history.back();" name="cancel" class="bttn" value="Cancel" style="width: 125px !important;" tabindex="8">
                    </fieldset>
                </div>
            </div>
        </div>
    </cfform>  
</cfoutput>

    