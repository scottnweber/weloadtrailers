<cfoutput>
	<form method="post" action="index.cfm?event=AddContact:Process&CarrierID=#url.CarrierID#">
		<input type="hidden" name="TotalDriverCount" ID="TotalDriverCount" value="<cfif qDrivers.recordcount>#qDrivers.recordcount#<cfelse>1</cfif>">
		<input type="hidden" name="TotalCount" ID="TotalCount" value="<cfif qContacts.recordcount>#qContacts.recordcount#<cfelse>1</cfif>">
		<div class="row">
			<div class="col-xs-12 col-lg-6" id="DriverContacts">
				<cfif qDrivers.recordcount>
					<cfloop query="qDrivers">
						<h2 class="col-xs-12 col-lg-12 blueBg" id="DriverHdr_#qDrivers.CurrentRow#"><cfif qDrivers.CurrentRow EQ 1>Add Driver<cfelse>Driver #qDrivers.CurrentRow#</cfif></h2>
						<div class="col-xs-12 col-lg-12 pb-10" id="Driver_#qDrivers.CurrentRow#">
							<label class="col-xs-4 col-lg-4">Contact Name</label>
							<input type="hidden"  name="DriverContactID_#qDrivers.CurrentRow#" value="#qDrivers.CarrierContactID#">
							<input class="col-xs-8 col-lg-8" maxlength="150" name="DriverContactPerson_#qDrivers.CurrentRow#" value="#qDrivers.ContactPerson#">
							<div class="clearfix"></div>
							<label class="col-xs-4 col-lg-4">Phone</label>
							<input class="col-xs-4 col-lg-4" maxlength="150" name="DriverPhoneNo_#qDrivers.CurrentRow#" value="#qDrivers.PhoneNo#" onchange="ParseUSNumber(this,'Phone');">
							<label class="col-xs-2 col-lg-2">Ext.</label>
							<input class="col-xs-2 col-lg-2" maxlength="50" name="DriverPhoneNoExt_#qDrivers.CurrentRow#" value="#qDrivers.PhoneNoExt#">
							<div class="clearfix"></div>
							<label class="col-xs-4 col-lg-4">Fax</label>
							<input class="col-xs-4 col-lg-4" maxlength="150" name="DriverFax_#qDrivers.CurrentRow#" value="#qDrivers.Fax#" onchange="ParseUSNumber(this,'Fax');">
							<label class="col-xs-2 col-lg-2">Ext.</label>
							<input class="col-xs-2 col-lg-2" maxlength="50" name="DriverFaxExt_#qDrivers.CurrentRow#" value="#qDrivers.FaxExt#">
							<div class="clearfix"></div>
							<label class="col-xs-4 col-lg-4">Toll Free</label>
							<input class="col-xs-4 col-lg-4" maxlength="150" name="DriverTollFree_#qDrivers.CurrentRow#" value="#qDrivers.TollFree#" onchange="ParseUSNumber(this,'Toll Free');">
							<label class="col-xs-2 col-lg-2">Ext.</label>
							<input class="col-xs-2 col-lg-2" maxlength="50" name="DriverTollFreeExt_#qDrivers.CurrentRow#" value="#qDrivers.TollFreeExt#">
							<div class="clearfix"></div>
							<label class="col-xs-4 col-lg-4">Cell</label>
							<input class="col-xs-4 col-lg-4" maxlength="150" name="DriverPersonMobileNo_#qDrivers.CurrentRow#" value="#qDrivers.PersonMobileNo#" onchange="ParseUSNumber(this,'Cell');">
							<label class="col-xs-2 col-lg-2">Ext.</label>
							<input class="col-xs-2 col-lg-2" maxlength="50" name="DriverMobileNoExt_#qDrivers.CurrentRow#" value="#qDrivers.MobileNoExt#">
							<div class="clearfix"></div>
							<label class="col-xs-4 col-lg-4">Email</label>
							<input class="col-xs-8 col-lg-8" maxlength="150" name="DriverEmail_#qDrivers.CurrentRow#" value="#qDrivers.Email#">
						</div>
						<div class="col-xs-12 col-lg-12 text-center pb-10" id="DriverAct_#qDrivers.CurrentRow#">
							<input class="bttn" type="button" value="ADD ANOTHER DRIVER" onclick="AddDriver();">
							<input class="bttn" type="button" value="Remove" onclick="RemoveDriver(#qDrivers.CurrentRow#)">
						</div>
						<div class="clearfix"></div>
					</cfloop>
				<cfelse>
					<h2 class="col-xs-12 col-lg-12 blueBg" id="DriverHdr_1">Add Driver</h2>
					<div class="col-xs-12 col-lg-12 pb-10" id="Driver_1">
						<label class="col-xs-4 col-lg-4">Contact Name</label>
						<input type="hidden"  name="DriverContactID_1" value="">
						<input class="col-xs-8 col-lg-8" maxlength="150" name="DriverContactPerson_1" value="">
						<div class="clearfix"></div>
						<label class="col-xs-4 col-lg-4">Phone</label>
						<input class="col-xs-4 col-lg-4" maxlength="150" name="DriverPhoneNo_1" value="" onchange="ParseUSNumber(this,'Phone');">
						<label class="col-xs-2 col-lg-2">Ext.</label>
						<input class="col-xs-2 col-lg-2" maxlength="50" name="DriverPhoneNoExt_1" value="">
						<div class="clearfix"></div>
						<label class="col-xs-4 col-lg-4">Fax</label>
						<input class="col-xs-4 col-lg-4" maxlength="150" name="DriverFax_1" value="" onchange="ParseUSNumber(this,'Fax');">
						<label class="col-xs-2 col-lg-2">Ext.</label>
						<input class="col-xs-2 col-lg-2" maxlength="50" name="DriverFaxExt_1" value="">
						<div class="clearfix"></div>
						<label class="col-xs-4 col-lg-4">Toll Free</label>
						<input class="col-xs-4 col-lg-4" maxlength="150" name="DriverTollFree_1" value="" onchange="ParseUSNumber(this,'Toll Free');">
						<label class="col-xs-2 col-lg-2">Ext.</label>
						<input class="col-xs-2 col-lg-2" maxlength="50" name="DriverTollFreeExt_1" value="">
						<div class="clearfix"></div>
						<label class="col-xs-4 col-lg-4">Cell</label>
						<input class="col-xs-4 col-lg-4" maxlength="150" name="DriverPersonMobileNo_1" value="" onchange="ParseUSNumber(this,'Cell');">
						<label class="col-xs-2 col-lg-2">Ext.</label>
						<input class="col-xs-2 col-lg-2" maxlength="50" name="DriverMobileNoExt_1" value="">
						<div class="clearfix"></div>
						<label class="col-xs-4 col-lg-4">Email</label>
						<input class="col-xs-8 col-lg-8" maxlength="150" name="DriverEmail_1" value="">
					</div>
					<div class="col-xs-12 col-lg-12 text-center pb-10" id="DriverAct_1">
						<input class="bttn" type="button" value="ADD ANOTHER DRIVER" onclick="AddDriver();">
						<input class="bttn" type="button" value="Remove" onclick="RemoveDriver(#qDrivers.CurrentRow#)">
					</div>
					<div class="clearfix"></div>
				</cfif>
			</div>
			<div class="col-xs-12 col-lg-6" id="Contacts">
				<cfif qContacts.recordcount>
					<cfloop query="qContacts">
						<h2 class="col-xs-12 col-lg-12 blueBg" id="ContactHdr_#qContacts.CurrentRow#"><cfif qContacts.CurrentRow EQ 1>Add Contact<cfelse>Contact #qContacts.CurrentRow#</cfif></h2>
						<div class="col-xs-12 col-lg-12 pb-10" id="Contact_#qContacts.CurrentRow#">
							<label class="col-xs-4 col-lg-4">Contact Name</label>
							<input type="hidden"  name="ContactID_#qContacts.CurrentRow#" value="#qContacts.CarrierContactID#">
							<input class="col-xs-8 col-lg-8" maxlength="150" name="ContactPerson_#qContacts.CurrentRow#" value="#qContacts.ContactPerson#">
							<div class="clearfix"></div>
							<label class="col-xs-4 col-lg-4">Phone</label>
							<input class="col-xs-4 col-lg-4" maxlength="150" name="PhoneNo_#qContacts.CurrentRow#" value="#qContacts.PhoneNo#" onchange="ParseUSNumber(this,'Phone');">
							<label class="col-xs-2 col-lg-2">Ext.</label>
							<input class="col-xs-2 col-lg-2" maxlength="50" name="PhoneNoExt_#qContacts.CurrentRow#" value="#qContacts.PhoneNoExt#">
							<div class="clearfix"></div>
							<label class="col-xs-4 col-lg-4">Fax</label>
							<input class="col-xs-4 col-lg-4" maxlength="150" name="Fax_#qContacts.CurrentRow#" value="#qContacts.Fax#" onchange="ParseUSNumber(this,'Fax');">
							<label class="col-xs-2 col-lg-2">Ext.</label>
							<input class="col-xs-2 col-lg-2" maxlength="50" name="FaxExt_#qContacts.CurrentRow#" value="#qContacts.FaxExt#">
							<div class="clearfix"></div>
							<label class="col-xs-4 col-lg-4">Toll Free</label>
							<input class="col-xs-4 col-lg-4" maxlength="150" name="TollFree_#qContacts.CurrentRow#" value="#qContacts.TollFree#" onchange="ParseUSNumber(this,'Toll Free');">
							<label class="col-xs-2 col-lg-2">Ext.</label>
							<input class="col-xs-2 col-lg-2" maxlength="50" name="TollFreeExt_#qContacts.CurrentRow#" value="#qContacts.TollFreeExt#">
							<div class="clearfix"></div>
							<label class="col-xs-4 col-lg-4">Cell</label>
							<input class="col-xs-4 col-lg-4" maxlength="150" name="PersonMobileNo_#qContacts.CurrentRow#" value="#qContacts.PersonMobileNo#" onchange="ParseUSNumber(this,'Cell');">
							<label class="col-xs-2 col-lg-2">Ext.</label>
							<input class="col-xs-2 col-lg-2" maxlength="50" name="MobileNoExt_#qContacts.CurrentRow#" value="#qContacts.MobileNoExt#">
							<div class="clearfix"></div>
							<label class="col-xs-4 col-lg-4">Email</label>
							<input class="col-xs-8 col-lg-8" maxlength="150" name="Email_#qContacts.CurrentRow#" value="#qContacts.Email#">
							<div class="clearfix"></div>
							<label class="col-xs-4 col-lg-4">Type '#qContacts.ContactType#'</label>
							<div class="col-xs-8 col-lg-8 pl-0">
								<label>
								    <input type="radio" name="ContactType_#qContacts.CurrentRow#" <cfif qContacts.ContactType EQ "Billing"> checked </cfif> value="Billing"> Billing
								</label>
								<label class="ml-10">
								    <input type="radio" name="ContactType_#qContacts.CurrentRow#" <cfif qContacts.ContactType EQ "Credit"> checked </cfif> value="Credit"> Credit
								</label>
								<label class="ml-10">
								    <input type="radio" name="ContactType_#qContacts.CurrentRow#" <cfif qContacts.ContactType EQ "General"> checked </cfif> value="General"> General
								</label> 
							</div>
						</div>
						<div class="col-xs-12 col-lg-12 text-center pb-10" id="ContactAct_#qContacts.CurrentRow#">
							<input class="bttn" type="button" value="ADD ANOTHER CONTACT" onclick="AddContact();">
							<input class="bttn" type="button" value="Remove" onclick="RemoveContact(#qContacts.CurrentRow#)">
						</div>
						<div class="clearfix"></div>
					</cfloop>
				<cfelse>
					<h2 class="col-xs-12 col-lg-12 blueBg" id="ContactHdr_1">Add Contact</h2>
					<div class="col-xs-12 col-lg-12 pb-10" id="Contact_1">
						<label class="col-xs-4 col-lg-4">Contact Name</label>
						<input type="hidden"  name="ContactID_1" value="">
						<input class="col-xs-8 col-lg-8" maxlength="150" name="ContactPerson_1" value="">
						<div class="clearfix"></div>
						<label class="col-xs-4 col-lg-4">Phone</label>
						<input class="col-xs-4 col-lg-4" maxlength="150" name="PhoneNo_1" value="" onchange="ParseUSNumber(this,'Phone');">
						<label class="col-xs-2 col-lg-2">Ext.</label>
						<input class="col-xs-2 col-lg-2" maxlength="50" name="PhoneNoExt_1" value="">
						<div class="clearfix"></div>
						<label class="col-xs-4 col-lg-4">Fax</label>
						<input class="col-xs-4 col-lg-4" maxlength="150" name="Fax_1" value="" onchange="ParseUSNumber(this,'Fax');">
						<label class="col-xs-2 col-lg-2">Ext.</label>
						<input class="col-xs-2 col-lg-2" maxlength="50" name="FaxExt_1" value="">
						<div class="clearfix"></div>
						<label class="col-xs-4 col-lg-4">Toll Free</label>
						<input class="col-xs-4 col-lg-4" maxlength="150" name="TollFree_1" value="" onchange="ParseUSNumber(this,'Toll Free');">
						<label class="col-xs-2 col-lg-2">Ext.</label>
						<input class="col-xs-2 col-lg-2" maxlength="50" name="TollFreeExt_1" value="">
						<div class="clearfix"></div>
						<label class="col-xs-4 col-lg-4">Cell</label>
						<input class="col-xs-4 col-lg-4" maxlength="150" name="PersonMobileNo_1" value="" onchange="ParseUSNumber(this,'Cell');">
						<label class="col-xs-2 col-lg-2">Ext.</label>
						<input class="col-xs-2 col-lg-2" maxlength="50" name="MobileNoExt_1" value="">
						<div class="clearfix"></div>
						<label class="col-xs-4 col-lg-4">Email</label>
						<input class="col-xs-8 col-lg-8" maxlength="150" name="Email_1" value="">
						<div class="clearfix"></div>
						<label class="col-xs-4 col-lg-4">Type</label>
						<div class="col-xs-8 col-lg-8 pl-0">
							<label>
							    <input type="radio" name="ContactType_1" checked="" value="Billing"> Billing
							</label>
							<label class="ml-10">
							    <input type="radio" name="ContactType_1" value="Credit"> Credit
							</label>
							<label class="ml-10">
							    <input type="radio" name="ContactType_1" value="General"> General
							</label> 
						</div>
					</div>
					<div class="col-xs-12 col-lg-12 text-center pb-10" id="ContactAct_1">
						<input class="bttn" type="button" value="ADD ANOTHER CONTACT" onclick="AddContact();">
						<input class="bttn" type="button" value="Remove" onclick="RemoveContact(#qContacts.CurrentRow#)">
					</div>
					<div class="clearfix"></div>
				</cfif>
			</div>
			<div class="clearfix"></div>
			<div class="col-xs-12 col-lg-12 text-center mt-10">
				<cfif isDefined("PrevEvent")>
					<input type="hidden" name="PrevEvent" value="#PrevEvent#">
					<input class="bttn ml-10" id="previous-btn" type="submit" name="back" value="PREVIOUS">
				</cfif>
				<label class="stepLabel">STEP #currentStep# OF #TotalStep#</label>
				<cfif isDefined("NextEvent")>
					<input class="bttn mr-10" id="next-btn" type="submit" name="submit" value="NEXT">
				</cfif>
			</div>
		</div>
	</form>
</cfoutput>