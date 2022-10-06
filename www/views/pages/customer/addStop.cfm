<cfoutput>
<cfsilent>
<cfparam name="editid" default="">	
<cfparam name="CustomerStopName" default="">
<cfparam name="location" default="">
<cfparam name="City" default="">
<cfparam name="StateID" default="">
<cfparam name="StateID1" default="">
<cfparam name="ZipCode" default="">
<cfparam name="ContactPerson" default="">
<cfparam name="Phone" default="">
<cfparam name="Fax" default="">
<cfparam name="EmailID" default="">
<cfparam name="CustomerID1" default="">
<cfparam name="NewInstructions" default="">
<cfparam name="NewDirections" default="">
<cfparam name="PhoneExt" default="">
<cfimport taglib="../../../plugins/customtags/mytag/" prefix="myoffices" >	
<cfif isdefined("url.stopid") and len(trim(url.stopid)) gt 1>
	<cfinvoke component="#variables.objCutomerGateway#" method="getStopDetails" CustomerStopID="#url.stopid#" returnvariable="request.qStop" />
	<cfinvoke component="#variables.objCutomerGateway#" method="getAllCustomers" <!--- CustomerID="#request.qStop.customerID#" ---> returnvariable="request.qCustomer" />
<cfset CustomerStopName=#request.qStop.CustomerStopName#>
<cfset location=#request.qStop.location#>
<cfset City=#request.qStop.city#>
<cfset StateID1=#request.qStop.StateID#>
<cfset Zipcode=#request.qStop.PostalCode#>
<cfset ContactPerson=#request.qStop.ContactPerson#>
<cfset Phone=#request.qStop.Phone#>
<cfset PhoneExt=#request.qStop.PhoneExt#>
<cfset Fax=#request.qStop.Fax#>
<cfset EmailID=#request.qStop.EmailID#>
<cfset CustomerID1=#request.qStop.CustomerID#>
<cfset NewInstructions=#request.qStop.NewInstructions#>
<cfset NewDirections=#request.qStop.NewDirections#>
<cfset StopType=request.qStop.StopType>
<cfset editid="#url.stopid#">
</cfif>
</cfsilent>
<cfif isdefined("url.customerId") and len(url.customerId) gt 1>	
	<cfset CustomerID1=url.customerId>
	<cfinvoke component="#variables.objCutomerGateway#" method="getAllCustomers" CustomerID="#url.customerid#" returnvariable="request.qCustomer" />
</cfif>
<cfif isdefined("url.stopid") and len(trim(url.stopid)) gt 1>
	<div class="search-panel"><div class="delbutton"><a href="index.cfm?event=stop<cfif isdefined("url.customerId") and len(url.customerId) gt 1>&customerid=#url.customerId#</cfif>&stopid=#editid#&#session.URLToken#" onclick="return confirm('Are you sure to delete it ?');">  Delete</a></div></div>
<cfset hOne="Edit Stop #CustomerStopName#">
<h1>Edit Stop <span style="padding-left:180px;">#CustomerStopName#</span></h1>
<cfelse>
<cfset session.checkUnload ='add'>
<cfset hOne="Add New Stop">
</cfif>
<h1 style="float: left;"><span style="padding-left:160px;">#request.qCustomer.CustomerName#</span></h1>
<div style="clear:both"></div>
<cfif isdefined("url.customerid") and len(trim(url.customerid)) gt 1>
<div id="customerTabs" class="tabsload ui-tabs ui-widget ui-widget-content ui-corner-all" style="float:left;border:none;padding-bottom: 0;">
    <ul class="ui-tabs-nav ui-helper-reset ui-helper-clearfix ui-widget-header ui-corner-all" style="height:27px;background: ##dfeffc !important;border:none; ">
    	<li class="ui-state-default ui-corner-top">
    		<a class="ui-tabs-anchor" href="index.cfm?event=addcustomer&#session.URLToken#&customerId=#url.customerId#">Customer</a>
    	</li>
    	<li class="ui-state-default ui-corner-top">
    		<a class="ui-tabs-anchor" href="index.cfm?event=CustomerContacts&#session.URLToken#&customerId=#url.customerId#">Contacts</a>
    	</li>
    	<li class="ui-state-default ui-corner-top">
    		<a class="ui-tabs-anchor" href="index.cfm?event=CRMNotes&#session.URLToken#&customerId=#url.customerId#">CRM</a>
    	</li>
        <li class="ui-state-default ui-corner-top">
        	<a class="ui-tabs-anchor" href="index.cfm?event=stop&#session.URLToken#&customerId=#url.customerId#">Stops</a>
        </li>
        <li class="ui-state-default ui-corner-top  ui-tabs-active ui-state-active">
        	<a class="ui-tabs-anchor add_quote_txt">Add Stops</a>
        </li>
	</ul>
</div>
</cfif>
<div style="clear:both"></div>
<div class="white-con-area" style="height: 36px;background-color: ##82bbef;margin-top: 2px;">
    <h2 style="color:white;font-weight:bold;text-align: center;">#hOne#</h2>
</div>
<div class="white-con-area">
<div class="white-top"></div>
<div class="white-mid">
<cfform name="frmStop" action="index.cfm?event=addstop:process&editid=#editid#&#session.URLToken#" method="post">
	<cfinput type="hidden" name="editid" value="#editid#">
<div class="form-con">
					
	<fieldset>
		<label>Stop Name*</label>
		<cfinput style="width:260px;" name="CustomerStopName" type="text" value="#CustomerStopName#" required="yes" message="Please enter stop name" maxlength="100">
		<div class="clear"></div>
		<label>Address*</label>
		<textarea name="location" rows="" cols="" style="width:260px;" maxlength="100">#location#</textarea>
		<div class="clear"></div>
		<label>City*</label>
		<cfinput name="City"  id="City" type="text" value="#City#" required="yes" message="Please enter city" style="width:260px;" maxlength="50" class="fpCityAuto">
		<div class="clear"></div>
		<label>State*</label>
		<select name="StateID" id="state" style="width: 60px;" class="fpStateAuto">
            <option value="">Select</option>
			<cfloop query="request.qstates">
        		<option value="#request.qstates.stateID#" <cfif request.qstates.stateID is stateID1> selected="selected" </cfif> >#request.qstates.statecode#</option>	
			</cfloop>
		</select>
		<label style="width:58px;">Zip*</label>
	    <cfinput name="ZipCode" maxlength="50" type="text" value="#ZipCode#" required="yes" message="Please enter zipcode" style="width:132px;" class="fpZipAuto"> 
		<div class="clear"></div>
		<label>Contact Person</label>
		<cfinput name="ContactPerson" type="text" value="#ContactPerson#" style="width:260px;" maxlength="100">
		<div class="clear"></div>
		<label>Phone</label>
		<cfinput name="Phone" id="Phone" type="text" value="#Phone#" onchange="ParseUSNumber(this);" maxlength="30"  style="width:155px;">
		<label style="width:30px;">Ext</label>
		<cfinput name="PhoneExt" type="text" value="#PhoneExt#" style="width:50px;" maxlength="50">
		<div class="clear"></div>
		<label>Fax</label>
		<cfinput name="Fax" id="Fax" type="text" value="#fax#" maxlength="30" style="width:260px;" onchange="ParseUSNumber(this);">
		<div class="clear"></div>
		<label>Email</label>
		<cfinput name="EmailID" type="text" value="#EmailID#" validate="email" maxlength="100" style="width:260px;">
	</fieldset>
</div>
<div class="form-con">
	<fieldset>
		<div class="clear"></div>
		<label>Customer*</label>
		<select name="CustomerID" tabindex="7">
			<cfloop query="request.qCustomer">
        		<option value="#request.qCustomer.customerID#" <cfif request.qCustomer.customerID is CustomerID1> selected="selected" </cfif> >#request.qCustomer.customerName#</option>	
			</cfloop>
		</select>
		<div class="clear"></div>
		<label>Instructions</label>
		<textarea name="NewInstructions" tabindex="8" rows="" style="height: 61px;" cols="">#NewInstructions#</textarea>
		<div class="clear"></div>
		<label>Internal Notes</label>
		<textarea name="NewDirections"  tabindex="9" rows="" style="height: 62px;" cols="">#NewDirections#</textarea>
		<div class="clear"></div>
		 <div style="padding-left:150px;"><input tabindex="10" type="submit" name="submit" class="bttn" onClick="return validateStop(frmStop);" value="Save Stop" onfocus="checkUnload();" style="width:112px;" /><input  type="button" onclick="javascript:history.back();" tabindex="11" name="back" class="bttn" value="Back" style="width:70px;" /></div>
		<div class="clear"></div>
	</fieldset>
</div>
  <div class="clear"></div>
</cfform>
<cfif isDefined("url.stopid") and len(url.stopid) gt 1>
<p id="footer" style="padding-left:10px;font-family:Verdana, Geneva, sans-serif; font-style:italic bold; text-transform:uppercase;font-family:Verdana, Geneva, sans-serif; font-style:italic; text-transform:uppercase;width:80%;">Last Updated:<cfif isDefined("request.qStop")>&nbsp;&nbsp;&nbsp; #request.qStop.LastModifiedDateTime#&nbsp;&nbsp;&nbsp;#request.qStop.LastModifiedBy#</cfif></p>
</cfif>
</div>

<div class="white-bot"></div>
</div>
<br /><br /><br />
<script type="text/javascript">
        $( document ).ready(function() {
            $('.form-popup-close').click(function(){
                $('body').removeClass('formpopup-body-noscroll');
                $(this).closest( ".form-popup" ).hide();
                $('.formpopup-overlay').hide();
                $('##FactoringID option:eq(0)').attr("selected", "selected");
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
	</script>
</cfoutput>


