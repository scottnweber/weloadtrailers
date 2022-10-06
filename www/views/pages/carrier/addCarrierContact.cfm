<cfif structKeyExists(form, "submit")>
    <cfinvoke component="#variables.objCarrierGateway#" method="addCarrierContact"  frmstruct="#form#" returnvariable="session.CarrierContactMsg" />
    <cfset isCarrierStr = "">
    <cfif structKeyExists(url, "IsCarrier")>
        <cfset isCarrierStr &= "&IsCarrier=#url.IsCarrier#">
    </cfif>
    <cflocation url="index.cfm?event=Carriercontacts&CarrierId=#form.CarrierId#&#session.URLToken##isCarrierStr#">
</cfif>
<cfparam name="ContactPerson" default="">
<cfparam name="MobileNo" default="">
<cfparam name="MobileNoExt" default="">
<cfparam name="PhoneNO" default="">
<cfparam name="PhoneNOExt" default="">
<cfparam name="Email" default="">
<cfparam name="Fax" default="">
<cfparam name="FaxExt" default="">
<cfparam name="Tollfree" default="">
<cfparam name="TollfreeExt" default="">
<cfparam name="ContactType" default="">
<cfparam name="carrierEmailAvailableLoads" default="0">
<cfparam name="url.CarrierContactID" default="">
<cfparam name="Active" default="1">
<cfparam name="Location" default="">
<cfparam name="City" default="">
<cfparam name="State1" default="">
<cfparam name="Zipcode" default="">
<cfparam name="Notes" default="">
<cfsilent>
    <cfinvoke component="#variables.objCarrierGateway#" method="getCarrierContacts"  CarrierID="#url.Carrierid#" CarrierContactID="#url.CarrierContactID#" returnvariable="qCarrierContact" />
    <cfinvoke component="#variables.objCarrierGateway#" method="getAllCarriers" returnvariable="request.qCarrier">
        <cfinvokeargument name="carrierid" value="#url.carrierid#">
    </cfinvoke>
    <cfinvoke component="#variables.objAgentGateway#" method="getAllStaes" returnvariable="request.qstates"/>
</cfsilent>
<cfif len(trim(url.CarrierContactID))>
    <cfset ContactPerson=#qCarrierContact.ContactPerson#>
    <cfset MobileNo=#qCarrierContact.PersonMobileNo#>
    <cfset MobileNoExt=#qCarrierContact.MobileNoExt#>
    <cfset PhoneNo=#qCarrierContact.PhoneNo#>
    <cfset PhoneNoExt=#qCarrierContact.PhoneNoExt#>
    <cfset Tollfree=#qCarrierContact.Tollfree#>
    <cfset TollfreeExt=#qCarrierContact.TollfreeExt#>
    <cfset Fax=#qCarrierContact.Fax#>
    <cfset FaxExt=#qCarrierContact.FaxExt#>
    <cfset Email=#qCarrierContact.Email#>
    <cfset ContactType=#qCarrierContact.ContactType#>
    <cfset carrierEmailAvailableLoads=#qCarrierContact.carrierEmailAvailableLoads#>
    <cfset Active=#qCarrierContact.Active#>
    <cfset Location=#qCarrierContact.Location#>
    <cfset City=#qCarrierContact.City#>
    <cfset State1=#qCarrierContact.StateCode#>
    <cfset Zipcode=#qCarrierContact.Zipcode#>
    <cfset Notes=#qCarrierContact.Notes#>
</cfif>
<cfoutput>
    <script>
        function validateCarrierContact(){
            return true;
        }

        $(document).ready(function(){
            $('##ContactType').change(function(){
                if($(this).val()=='Dispatch'){
                    $('##carrierEmailAvailableLoads').prop('checked', true);
                }
                else{
                    $('##carrierEmailAvailableLoads').prop('checked', false);
                }
            })
            $('##City').autocomplete({
                multiple: false,
                width: 400,
                scroll: true,
                scrollHeight: 300,
                cacheLength: 1,
                highlight: false,
                dataType: "json",
                source: 'searchCustomersAutoFill.cfm?queryType=getCity&CompanyID=#session.CompanyID#',
                select: function(e, ui) {
                    $(this).val(ui.item.city);
                    if(!$('##State1').val().length && $("##State1 option[value='"+ui.item.state+"']").length){
                        $('##State1').val(ui.item.state);
                    }
                    if(!$('##Zipcode').val().length){
                        $('##Zipcode').val(ui.item.zip);
                    }
                    return false;
                }
            });
            $('##City').data("ui-autocomplete")._renderItem = function(ul, item) {
                return $( "<li>"+item.city+"<br/><b><u>State</u>:</b> "+ item.state+"&nbsp;&nbsp;&nbsp;<b><u>Zip</u>:</b>" + item.zip+"</li>" )
                        .appendTo( ul );
            }

            $('##Zipcode').autocomplete({
                multiple: false,
                width: 400,
                scroll: true,
                scrollHeight: 300,
                cacheLength: 1,
                minLength: 1,
                highlight: false,
                dataType: "json",
                source: 'searchCustomersAutoFill.cfm?queryType=GetZip&CompanyID=#session.CompanyID#',
                select: function(e, ui) {
                    $(this).val(ui.item.zip);

                    if(!$('##State1').val().length && $("##State1 option[value='"+ui.item.state+"']").length){
                        $('##State1').val(ui.item.state);
                    }
                    if(!$('##City').val().length){
                        $('##City').val(ui.item.city);
                    }
                    return false;
                }
            });
            $('##Zipcode').data("ui-autocomplete")._renderItem = function(ul, item) {
                return $( "<li>"+item.zip+"<br/><b><u>State</u>:</b> "+ item.state+"&nbsp;&nbsp;&nbsp;<b><u>City</u>:</b>" + item.city+"</li>" )
                        .appendTo( ul );
            }
        })
    </script>
    <h1 style="float: left;"><span style="padding-left:160px;">#request.qCarrier.CarrierName#</span></h1>
    <div style="clear:both"></div>
    <cfif isdefined("url.Carrierid") and len(trim(url.Carrierid)) gt 1>
        <cfinclude template="carrierTabs.cfm">
    </cfif>
    <cfif len(trim(url.CarrierContactId))>
        <div class="delbutton" style="margin-right: 100px;">
            <a href="index.cfm?event=CarrierContacts&CarrierID=#url.CarrierId#&deleteCarrierContactid=#url.CarrierContactId#&#session.URLToken#" onclick="return confirm('Are you sure to delete this contact ?');">  Delete</a>
        </div>
    </cfif>
    <div style="clear:both"></div>
    <div class="white-con-area" style="height: 36px;background-color: ##82bbef;margin-top: 2px;">
        <h2 style="color:white;font-weight:bold;text-align: center;"><cfif structKeyExists(url, "CarrierContactID") and len(trim(url.CarrierContactID))>Edit<cfelse>Add</cfif> Carrier Contact</h2>
    </div>
    <div class="white-con-area">
        <div class="white-top"></div>
        <div class="white-mid">
            <cfset frmact = "index.cfm?event=addCarrierContact&#session.URLToken#">
            <cfif structKeyExists(url, "IsCarrier")>
                <cfset frmact &= "&IsCarrier=#url.IsCarrier#">
            </cfif>
            <cfform name="frmCarrierContact" action="#frmact#" method="post" onsubmit="return validateCarrierContact()">
                <cfinput type="hidden" name="CarrierID" value="#url.CarrierId#">
                <cfinput type="hidden" name="CarrierContactId" value="#url.CarrierContactId#">
                <div class="form-con">
                    <fieldset  class="carrierFields">
                        <label>Contact Type</label>
                        <cfset listContactType = "Billing,Credit,Onboarding,Contract,Dispatch,General,Driver">
                        <select name="ContactType" tabindex="1" id="ContactType">
                            <option value="">Select</option>
                            <cfloop list="#listContactType#" index="type">
                                <option value="#type#" <cfif type eq ContactType> selected </cfif>>#type#</option>
                            </cfloop>
                        </select>
                        <label>Contact Name</label>
                        <cfinput type="text" name="ContactPerson" id="ContactPerson" maxlength="50" value="#ContactPerson#" tabindex="1">
                        <div class="clear"></div>
                        <label>Phone</label>
                        <cfinput onchange="ParseUSNumber(this);" type="text" name="PhoneNO" maxlength="50" value="#PhoneNO#" tabindex="2" style="width:175px;">
                        <label class="ex" style="width:20px;">Ext.</label>
                        <input type="text" name="PhoneNOExt" tabindex="3" style="width:50px;" value="#PhoneNOExt#" maxlength="10">
                        <div class="clear"></div>
                        <label>Fax</label>
                        <cfinput onchange="ParseUSNumber(this);" name="Fax" type="text" maxlength="150" tabindex="4" value="#Fax#" style="width:175px;"/>
                        <label class="ex" style="width:20px;">Ext.</label>
                        <input type="text" name="FaxExt" tabindex="5" style="width:50px;" value="#FaxExt#" maxlength="10">
                        <div class="clear"></div>
                        <label>Toll Free</label>
                        <cfinput onchange="ParseUSNumber(this);" name="Tollfree" type="text" maxlength="250" tabindex="6" value="#Tollfree#" style="width:175px;"/>
                        <label class="ex" style="width:20px;">Ext.</label>
                        <input type="text" name="TollfreeExt" tabindex="7" style="width:50px;" value="#TollfreeExt#" maxlength="10">
                        <div class="clear"></div>
                        <label>Cell</label>
                        <cfinput onchange="ParseUSNumber(this);" type="text" name="PersonMobileNo" maxlength="50" value="#MobileNo#" tabindex="8" style="width:175px;">
                        <label class="ex" style="width:20px;">Ext.</label>
                        <input type="text" name="MobileNoExt" tabindex="9" style="width:50px;" value="#MobileNoExt#" maxlength="10">
                        <div class="clear"></div>
                        <label>Email Id</label>
                        <cfinput type="text" maxlength="250" name="Email" class="emailbox" value="#Email#" tabindex="10">
                        <div class="clear"></div>
                        <label>Status*</label>
                        <select name="Active" tabindex="10" style="width: 60px;">
                            <option value="1" <cfif Active> selected </cfif>>Active</option>
                            <option value="0" <cfif NOT Active> selected </cfif>>InActive</option>
                        </select>
                        <div class="clear"></div>
                        <cfif request.qGetSystemSetupOptions.ActivateBulkAndLoadNotificationEmail EQ 1>
                                <!--- Activate/Deactivate load alert email --->
                            <label>Email Available Loads</label>
                            <input type="checkbox" name="carrierEmailAvailableLoads" id="carrierEmailAvailableLoads" <cfif len(carrierEmailAvailableLoads) AND carrierEmailAvailableLoads EQ 1>checked="checked"</cfif> class="small_chk" style="float:left">
                            <div class="clear"></div>
                        </cfif>
                        <div style="padding-left:100px;padding-top:19px;">
                            <input  type="submit" name="submit" class="bttn" value="Save" style="width:112px;" tabindex="11" />
                            <input  type="button" onclick="javascript:history.back();" name="back" class="bttn" value="Back" style="width:70px;" />
                        </div>
                    </fieldset>
                </div>
                <div class="form-con">
                    <fieldset  class="carrierFields" style="margin-top: -18px;">
                        <div class="fa fa-<cfif NOT len(trim(url.CarrierContactID)) OR len(trim(Location)) OR len(trim(City)) OR len(trim(State1)) OR len(trim(Zipcode))>minus<cfelse>plus</cfif>-circle PlusToggleButton" onclick="toggleAddress(this);" style="position:relative;margin-left: 27px;margin-top: 0px;top:15px;"></div>
                        <label style="width: 50px;position: relative;top:15px;">Address</label>
                        <div class="clear"></div>
                        <div class="AddressDiv" style="display: <cfif NOT len(trim(url.CarrierContactID)) OR len(trim(Location)) OR len(trim(City)) OR len(trim(State1)) OR len(trim(Zipcode))>block<cfelse>none</cfif>;">
                            <label>&nbsp;</label>
                            <textarea  maxlength="200" id="Location" name="Location" style="height: 42px;">#Location#</textarea>
                            <div class="clear"></div>
                            <label>City</label>
                            <cfinput name="City" id="City" type="text" value="#City#" maxlength="50">
                            <div class="clear"></div>
                            <label>State</label>
                            <select name="State1" id="State1" tabindex="6" style="width:100px;">
                                <option value="">Select</option>
                                <cfloop query="request.qStates">
                                    <option value="#request.qStates.statecode#" <cfif request.qStates.statecode is State1> selected="selected" </cfif> >#request.qStates.statecode#</option>
                                </cfloop>
                            </select>
                            <label style="width:70px;">Zipcode</label>
                            <cfinput type="text" name="Zipcode" value="#Zipcode#" maxlength="50" style="width:100px;">
                        </div>
                        <div class="clear"></div>
                        <div style="margin-top: 20px;"></div>
                        <label>Notes</label>
                        <textarea maxlength="4000" id="Notes" name="Notes" style="height: 150px;">#Notes#</textarea>
                    </fieldset>
                </div>
                <div class="clear"></div>
            </cfform>
        </div>
        <div class="white-bot"></div>
    </div>
    
    <div class="clear"></div>
</cfoutput>
    