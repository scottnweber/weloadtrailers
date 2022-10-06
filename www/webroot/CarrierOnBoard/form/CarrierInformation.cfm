<cfoutput>
	<form method="post" action="index.cfm?event=CarrierInformation:Process&<cfif structKeyExists(url, "CompanyID")>CompanyID=#url.CompanyID#<cfelse>CarrierID=#url.CarrierID#</cfif>" onsubmit="return validateCarrierInformation()">
		<cfif structKeyExists(url, "CompanyID")>
			<input type="hidden" name="CompanyID" value="#url.CompanyID#">
		</cfif>
		<div class="row">
			<div class="col-xs-12 col-lg-6">
				<h2 class="col-xs-12 col-lg-12 blueBg">Carrier Information</h2>
				<label class="col-xs-3 col-lg-3">DOT##</label>
				<input class="col-xs-3 col-lg-3" maxlength="50" name="DotNumber" value="<cfif structkeyexists(url,"DOTNumber")>#url.DOTNumber#<cfelse>#qCarrierInfo.DotNumber#</cfif>">
				<label class="col-xs-3 col-lg-3">MC##</label>
				<input class="col-xs-3 col-lg-3" maxlength="50" name="MCNumber"  value="<cfif structkeyexists(url,"MCNumber")>#url.MCNumber#<cfelse>#qCarrierInfo.MCNumber#</cfif>">
				<div class="clearfix"></div>
				<label class="col-xs-3 col-lg-3">Name</label>
				<input class="col-xs-9 col-lg-9" maxlength="100" name="CarrierName" value="#qCarrierInfo.CarrierName#">
				<div class="clearfix"></div>
				<label class="col-xs-3 col-lg-3">Fed Tax ID<cfif qSystemConfig.RequireFedTaxID> *</cfif></label>
				<input class="col-xs-3 col-lg-3" maxlength="20" name="TaxID" id="TaxID" value="#qCarrierInfo.TaxID#">
				<label class="col-xs-3 col-lg-3">SCAC</label>
				<input class="col-xs-3 col-lg-3" maxlength="8" name="SCAC" value="#qCarrierInfo.SCAC#">
				<div class="clearfix"></div>
				<label class="col-xs-3 col-lg-3">Address</label>
				<textarea name="Address" class="col-xs-9 col-lg-9" maxlength="200">#qCarrierInfo.Address#</textarea>
				<div class="clearfix"></div>
				<label class="col-xs-3 col-lg-3">City</label>
				<input class="col-xs-9 col-lg-9 CityAuto" maxlength="150" name="City" id="City" value="#qCarrierInfo.City#">
				<div class="clearfix"></div>
				<label class="col-xs-3 col-lg-3">State</label>
				<select class="col-xs-3 col-lg-3 StateAuto" name="StateCode" id="StateCode">
					<option value="">Select</option>
					<cfloop query="qStates">
						<option value="#qStates.StateCode#" <cfif trim(qStates.StateCode) eq trim(qCarrierInfo.StateCode)> selected </cfif>>#qStates.StateCode#</option>
					</cfloop>
				</select>
				<label class="col-xs-3 col-lg-3">Zip</label>
				<input class="col-xs-3 col-lg-3 ZipAuto" maxlength="20" name="ZipCode" id="ZipCode" value="#qCarrierInfo.ZipCode#">
				<div class="clearfix"></div>
				<label class="col-xs-3 col-lg-3">Country</label>
				<select class="col-xs-9 col-lg-9" name="Country">
					<option value="">Select</option>
					<cfloop query="qCountries">
			        	<cfif qCountries.CountryCode EQ 'US'>
			        		<option value="#qCountries.countryID#" <cfif qCountries.CountryID eq qCarrierInfo.Country> selected </cfif> >#qCountries.Country#</option>
			        	</cfif>
			        </cfloop>
			        <cfloop query="qCountries">
			        	<cfif qCountries.CountryCode EQ 'CA'>
			        		<option value="#qCountries.countryID#" <cfif qCountries.CountryID eq qCarrierInfo.Country> selected </cfif> >#qCountries.Country#</option>
			        	</cfif>
			        </cfloop>
			        <cfloop query="qCountries">
			        	<cfif not listFindNoCase("CA,US", qCountries.countrycode)>
			        		<option value="#qCountries.countryID#" <cfif qCountries.CountryID eq qCarrierInfo.Country> selected </cfif> >#qCountries.Country#</option>
			        	</cfif>
			        </cfloop>
				</select>
				<div class="clearfix"></div>
				<label class="col-xs-3 col-lg-3">Phone</label>
				<input class="col-xs-5 col-lg-5" maxlength="150" name="Phone" id="Phone" value="#qCarrierInfo.Phone#" onchange="ParseUSNumber(this,'Phone');">
				<label class="col-xs-2 col-lg-2">Ext.</label>
				<input class="col-xs-2 col-lg-2" name="PhoneExt" maxlength="50" value="#qCarrierInfo.PhoneExt#">
				<div class="clearfix"></div>
				<label class="col-xs-3 col-lg-3">Fax</label>
				<input class="col-xs-5 col-lg-5" maxlength="150" name="Fax" id="Fax" value="#qCarrierInfo.Fax#" onchange="ParseUSNumber(this,'Fax');">
				<label class="col-xs-2 col-lg-2">Ext.</label>
				<input class="col-xs-2 col-lg-2" name="FaxExt" maxlength="50" value="#qCarrierInfo.FaxExt#">
				<div class="clearfix"></div>
				<label class="col-xs-3 col-lg-3">Toll Free</label>
				<input class="col-xs-5 col-lg-5" maxlength="150" name="TollFree" id="TollFree" value="#qCarrierInfo.TollFree#" onchange="ParseUSNumber(this,'Toll Free');">
				<label class="col-xs-2 col-lg-2">Ext.</label>
				<input class="col-xs-2 col-lg-2" name="TollFreeExt" maxlength="50" value="#qCarrierInfo.TollFreeExt#">
				<div class="clearfix"></div>
				<label class="col-xs-3 col-lg-3">Cell</label>
				<input class="col-xs-5 col-lg-5"  maxlength="150" name="Cel" id="Cel" value="#qCarrierInfo.Cel#" onchange="ParseUSNumber(this,'Cell');">
				<label class="col-xs-2 col-lg-2">Ext.</label>
				<input class="col-xs-2 col-lg-2" name="CellPhoneExt" maxlength="50" value="#qCarrierInfo.CellPhoneExt#">
				<div class="clearfix"></div>
				<label class="col-xs-3 col-lg-3">Email</label>
				<input class="col-xs-9 col-lg-9 hyperLinkInput" maxlength="150" name="EmailID" value="#qCarrierInfo.EmailID#">
				<div class="clearfix"></div>
				<label class="col-xs-3 col-lg-3">Website</label>
				<input class="col-xs-9 col-lg-9 hyperLinkInput" maxlength="200" name="Website" value="#qCarrierInfo.Website#">
				<div class="clearfix"></div>
				<label class="col-xs-3 col-lg-3">Contact Person</label>
				<input class="col-xs-9 col-lg-9" maxlength="150" name="ContactPerson" value="#qCarrierInfo.ContactPerson#">
				<div class="clearfix"></div>
				<label class="col-xs-3 col-lg-3">Prefered Contact Method</label>
				<select class="col-xs-9 col-lg-9" name="ContactHow">
					<option value="1" <cfif qCarrierInfo.ContactHow EQ 1> selected="true" </cfif>>E-mail</option>
				    <option value="2" <cfif qCarrierInfo.ContactHow EQ 2> selected="true" </cfif>>Text</option>
				    <option value="3" <cfif qCarrierInfo.ContactHow EQ 3> selected="true" </cfif>>Both</option>
				</select>
				<div class="clearfix"></div>
				<label class="col-xs-3 col-lg-3">Email Available Loads</label>
				<div class="col-xs-9 col-lg-9 pl-0">
					<input type="checkbox" name="carrierEmailAvailableLoads" <cfif qCarrierInfo.carrierEmailAvailableLoads EQ 1>checked="checked"</cfif>>
				</div>
				<div class="clearfix"></div>
			</div>
			<div class="col-xs-12 col-lg-6">
				<h2 class="col-xs-12 col-lg-12 blueBg">Remit Information</h2>
				<div class="col-xs-12 col-lg-12 redFont">
					<b>ONLY ENTER REMIT ADDRESS IF ITS DIFFERENT THAN YOUR REGULAR ADDRESS</b>
				</div>
				<div class="clearfix"></div>
				<div class="col-xs-1 col-lg-1 lg-w-20">
					<input type="checkbox" <cfif len(trim(qCarrierInfo.FactoringID))>checked="checked"</cfif>>
				</div>
				<label class="col-xs-10 col-lg-10 text-left pl-5 mt-3">Is this a factoring company?</label>
				<div class="clearfix"></div>
				<label class="col-xs-3 col-lg-3">Remit Name</label>
				<input class="col-xs-9 col-lg-9" maxlength="100" name="RemitName" value="#qCarrierInfo.RemitName#">
				<div class="clearfix"></div>
				<label class="col-xs-3 col-lg-3">Remit Address</label>
				<textarea name="RemitAddress" maxlength="200" class="col-xs-9 col-lg-9">#qCarrierInfo.RemitAddress#</textarea>
				<div class="clearfix"></div>
				<label class="col-xs-3 col-lg-3">Remit City</label>
				<input class="col-xs-3 col-lg-3 CityAuto" maxlength="50" name="RemitCity" id="RemitCity" value="#qCarrierInfo.RemitCity#">
				<label class="col-xs-3 col-lg-3">Remit State</label>
				<select class="col-xs-3 col-lg-3 StateAuto" name="RemitState" id="RemitState">
					<option value="">Select</option>
					<cfloop query="qStates">
						<option value="#qStates.StateCode#" <cfif trim(qStates.StateCode) eq trim(qCarrierInfo.RemitState)> selected </cfif>>#qStates.StateCode#</option>
					</cfloop>
				</select>
				<div class="clearfix"></div>
				<label class="col-xs-3 col-lg-3">Remit Zipcode</label>
				<input class="col-xs-3 col-lg-3 ZipAuto" maxlength="20" name="RemitZipcode" id="RemitZipcode" value="#qCarrierInfo.RemitZipcode#">
				<label class="col-xs-3 col-lg-3">Contact</label>
				<input class="col-xs-3 col-lg-3" maxlength="150" name="RemitContact" value="#qCarrierInfo.RemitContact#">
				<div class="clearfix"></div>
				<label class="col-xs-3 col-lg-3">Remit Phone</label>
				<input class="col-xs-3 col-lg-3" maxlength="150" name="RemitPhone" value="#qCarrierInfo.RemitPhone#" onchange="ParseUSNumber(this,'Remit Phone');">
				<label class="col-xs-3 col-lg-3">Remit Fax</label>
				<input class="col-xs-3 col-lg-3" maxlength="150" name="RemitFax" value="#qCarrierInfo.RemitFax#" onchange="ParseUSNumber(this,'Remit Fax');">
				<div class="clearfix"></div>
				<label class="col-xs-3 col-lg-3">Remit Email</label>
				<input class="col-xs-9 col-lg-9" maxlength="250" name="RemitEmail" value="#qCarrierInfo.RemitEmail#">
				<div class="clearfix"></div>
				<div class="col-xs-12 col-lg-12 text-center mt-10">
					<label class="stepLabel">STEP #currentStep# OF #TotalStep#</label>
					<cfif isDefined("NextEvent")>
						<input class="bttn" id="next-btn" type="submit" name="submit" value="NEXT">
					</cfif>
				</div>
			</div>
		</div>
	</form>
</cfoutput>