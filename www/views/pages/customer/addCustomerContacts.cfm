<cfif structKeyExists(form, "submit")>
    <cfinvoke component="#variables.objCustomerGateway#" method="addCustomerContact"  frmstruct="#form#" returnvariable="session.CustomerContactMsg" />
    <cflocation url="index.cfm?event=customercontacts&customerId=#form.customerId#&#session.URLToken#">
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
<cfparam name="url.CustomerContactID" default="">
<cfparam name="Active" default="1">
<cfparam name="Location" default="">
<cfparam name="City" default="">
<cfparam name="State1" default="">
<cfparam name="Zipcode" default="">
<cfparam name="Notes" default="">
<cfsilent>
    <cfinvoke component="#variables.objCustomerGateway#" method="getCustomerContacts"  CustomerID="#url.customerid#" CustomerContactID="#url.CustomerContactID#" returnvariable="qCustomerContact" />
    <cfinvoke component="#variables.objCutomerGateway#" method="getAllCustomers" CustomerID="#url.customerid#" returnvariable="request.qCustomer" />
    <cfinvoke component="#variables.objAgentGateway#" method="getAllStaes" returnvariable="request.qstates"/>
</cfsilent>
<cfif len(trim(url.CustomerContactID))>
    <cfset ContactPerson=#qCustomerContact.ContactPerson#>
    <cfset MobileNo=#qCustomerContact.PersonMobileNo#>
    <cfset MobileNoExt=#qCustomerContact.MobileNoExt#>
    <cfset PhoneNo=#qCustomerContact.PhoneNo#>
    <cfset PhoneNoExt=#qCustomerContact.PhoneNoExt#>
    <cfset Tollfree=#qCustomerContact.Tollfree#>
    <cfset TollfreeExt=#qCustomerContact.TollfreeExt#>
    <cfset Fax=#qCustomerContact.Fax#>
    <cfset FaxExt=#qCustomerContact.FaxExt#>
    <cfset Email=#qCustomerContact.Email#>
    <cfset ContactType=#qCustomerContact.ContactType#>
    <cfset Active=#qCustomerContact.Active#>
    <cfset Location=#qCustomerContact.Location#>
    <cfset City=#qCustomerContact.City#>
    <cfset State1=#qCustomerContact.StateCode#>
    <cfset Zipcode=#qCustomerContact.Zipcode#>
    <cfset Notes=#qCustomerContact.Notes#>

</cfif>
<cfoutput>
    <script>
        function validateCustomerContact(){
            if(!$.trim($('##ContactPerson').val()).length){
                alert('Please enter ContactPerson.');
                $('##ContactPerson').focus();
                return false;
            }
            return true;
        }

        $(document).ready(function(){
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
    <h1 style="float: left;"><span style="padding-left:160px;">#request.qCustomer.CustomerName#</span></h1>
    <div style="clear:both"></div>
    <cfif isdefined("url.customerid") and len(trim(url.customerid)) gt 1>
        <div id="customerTabs" class="tabsload ui-tabs ui-widget ui-widget-content ui-corner-all" style="float:left;border:none;padding-bottom: 0;">
            <ul class="ui-tabs-nav ui-helper-reset ui-helper-clearfix ui-widget-header ui-corner-all" style="height:27px;background: ##dfeffc !important;border:none; ">
                <li class="ui-state-default ui-corner-top">
                    <a class="ui-tabs-anchor" href="index.cfm?event=addcustomer&#session.URLToken#&customerId=#url.customerId#">Customer</a>
                </li>
                <li class="ui-state-default ui-corner-top ui-tabs-active ui-state-active">
                  <a class="ui-tabs-anchor">Contacts</a>
                </li>
                <li class="ui-state-default ui-corner-top">
                  <a class="ui-tabs-anchor" href="index.cfm?event=CRMNotes&#session.URLToken#&customerId=#url.customerId#">CRM</a>
                </li>
                <li class="ui-state-default ui-corner-top">
                    <a class="ui-tabs-anchor" href="index.cfm?event=stop&#session.URLToken#&customerId=#url.customerId#">Stops</a>
                </li>
                <li class="ui-state-default ui-corner-top">
                    <a class="ui-tabs-anchor add_quote_txt"  href="index.cfm?event=addstop&#session.URLToken#&customerId=#url.customerId#">Add Stops</a>
                </li>
            </ul>
        </div>
    </cfif>
    <cfif len(trim(url.CustomerContactId))>
        <div class="delbutton" style="margin-right: 100px;">
            <a href="index.cfm?event=CustomerContacts&CustomerID=#url.customerId#&deleteCustomerContactid=#url.CustomerContactId#&#session.URLToken#" onclick="return confirm('Are you sure to delete this contact ?');">  Delete</a>
        </div>
    </cfif>
    <div style="clear:both"></div>
    <div class="white-con-area" style="height: 36px;background-color: ##82bbef;margin-top: 2px;">
        <h2 style="color:white;font-weight:bold;text-align: center;"><cfif structKeyExists(url, "CustomerContactID") and len(trim(url.CustomerContactID))>Edit<cfelse>Add</cfif> Customer Contact</h2>
    </div>
    <div class="white-con-area">
        <div class="white-top"></div>
        <div class="white-mid">
            <cfform name="frmCustomerContact" action="index.cfm?event=addCustomerContact&#session.URLToken#" method="post" onsubmit="return validateCustomerContact()">
                <cfinput type="hidden" name="CustomerID" value="#url.customerId#">
                <cfinput type="hidden" name="CustomerContactId" value="#url.CustomerContactId#">
                <div class="form-con">
                    <fieldset  class="carrierFields">
                        <label>Contact Type</label>
                        <cfset listContactType = "Billing,Credit,Onboarding,Contract,Dispatch,General">
                        <select name="ContactType" tabindex="1">
                            <option value="">Select</option>
                            <cfloop list="#listContactType#" index="type">
                                <option value="#type#" <cfif type eq ContactType> selected </cfif>>#type#</option>
                            </cfloop>
                        </select>
                        <label>Contact Person</label>
                        <cfinput type="text" name="ContactPerson" id="ContactPerson" maxlength="50" value="#ContactPerson#" tabindex="1">
                        <div class="clear"></div>
                        <label>Phone No</label>
                        <cfinput onchange="ParseUSNumber(this,'Phone No');" type="text" name="PhoneNO" maxlength="50" value="#PhoneNO#" tabindex="2" style="width:175px;">
                        <label class="ex" style="width:20px;">Ext.</label>
                        <input type="text" name="PhoneNOExt" tabindex="3" style="width:50px;" value="#PhoneNOExt#" maxlength="10">
                        <div class="clear"></div>
                        <label>Fax</label>
                        <cfinput onchange="ParseUSNumber(this,'Fax');" name="Fax" type="text" maxlength="150" tabindex="4" value="#Fax#" style="width:175px;"/>
                        <label class="ex" style="width:20px;">Ext.</label>
                        <input type="text" name="FaxExt" tabindex="5" style="width:50px;" value="#FaxExt#" maxlength="10">
                        <div class="clear"></div>
                        <label>Toll Free</label>
                        <cfinput onchange="ParseUSNumber(this,'Toll free');" name="Tollfree" type="text" maxlength="250" tabindex="6" value="#Tollfree#" style="width:175px;"/>
                        <label class="ex" style="width:20px;">Ext.</label>
                        <input type="text" name="TollfreeExt" tabindex="7" style="width:50px;" value="#TollfreeExt#" maxlength="10">
                        <div class="clear"></div>
                        <label>Cell</label>
                        <cfinput onchange="ParseUSNumber(this,'Cell');" type="text" name="PersonMobileNo" maxlength="50" value="#MobileNo#" tabindex="8" style="width:175px;">
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
                        <div style="padding-left:100px;padding-top:19px;">
                            <input  type="submit" name="submit" class="bttn" value="Save" style="width:112px;" tabindex="11" />
                            <input  type="button" onclick="javascript:history.back();" name="back" class="bttn" value="Back" style="width:70px;" />
                        </div>
                    </fieldset>
                </div>
                <div class="form-con">
                    <fieldset  class="carrierFields" style="margin-top: -18px;">
                        <div class="fa fa-<cfif NOT len(trim(url.CustomerContactID)) OR len(trim(Location)) OR len(trim(City)) OR len(trim(State1)) OR len(trim(Zipcode))>minus<cfelse>plus</cfif>-circle PlusToggleButton" onclick="toggleAddress(this);" style="position:relative;margin-left: 27px;margin-top: 0px;top:15px;"></div>
                        <label style="width: 50px;position: relative;top:15px;">Address</label>
                        <div class="clear"></div>
                        <div class="AddressDiv" style="display: <cfif NOT len(trim(url.CustomerContactID)) OR len(trim(Location)) OR len(trim(City)) OR len(trim(State1)) OR len(trim(Zipcode))>block<cfelse>none</cfif>;">
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
    