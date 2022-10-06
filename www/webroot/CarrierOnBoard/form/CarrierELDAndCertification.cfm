<cfoutput>
	<script type="text/javascript">
		var check;
		$('input[type="radio"]').hover(function() {
		    check = $(this).is(':checked');
		});
		var checkedradio;
		function docheck(thisradio) {
		    if (checkedradio == thisradio) {
		        thisradio.checked = false;
		        checkedradio = null;
		    }
		    else {checkedradio = thisradio;}
		}
	</script>
	<form method="post" class="col-xs-12 col-lg-6 pl-0 pr-0" action="index.cfm?event=CarrierELDAndCertification:Process&CarrierID=#url.CarrierID#">
		<div class="row">
			<div class="col-xs-12 col-lg-12 pb-10">
				<cfif qSystemConfig.PromptForELDStatus>
					<h2 class="col-xs-12 col-lg-12 blueBg">ELD Provider Information</h2>
					<div class="col-xs-12 col-lg-12">
						<b class="col-xs-12 col-lg-12">Select your ELD compliance status</b>
						<div class="form-check col-xs-12 col-lg-12">
		  					<input name="ELDStatus" class="form-check-input" type="radio" value="1" id="ELDStatus_1" <cfif qCarrierELDCert.ELDComplianceStatus EQ 1> checked</cfif> onClick="javascript:docheck(this);">
		  					<label class="form-check-label" for="ELDStatus_1">ELD Complaint</label>
						</div>
						<div class="form-check col-xs-12 col-lg-12">
		  					<input name="ELDStatus" class="form-check-input" type="radio" value="2" id="ELDStatus_2" <cfif qCarrierELDCert.ELDComplianceStatus EQ 2> checked</cfif> onClick="javascript:docheck(this);">
		  					<label class="form-check-label" for="ELDStatus_2">Exempt per FMCSA guidelines</label>
						</div>
						<div class="form-check col-xs-12 col-lg-12">
		  					<input name="ELDStatus" class="form-check-input" type="radio" value="3" id="ELDStatus_3" <cfif qCarrierELDCert.ELDComplianceStatus EQ 3> checked</cfif> onClick="javascript:docheck(this);">
		  					<label class="form-check-label" for="ELDStatus_3">Not ELD Complaint</label>
						</div>
					</div>
					<div class="clearfix"></div>
				</cfif>
				<cfif qSystemConfig.PromptForCertifications>
					<h2 class="col-xs-12 col-lg-12 blueBg">Certifications</h2>
					<div class="col-xs-12 col-lg-12">
						<div class="form-check col-xs-12 col-lg-12">
		  					<input name="Certifications" class="form-check-input" type="checkbox" value="1" id="Certification_1" <cfif listFind(qCarrierELDCert.Certifications , 1)> checked</cfif>>
		  					<label class="form-check-label" for="Certification_1">Hazmat</label>
						</div>
						<div class="clearfix"></div>
						<div class="col-xs-1 col-lg-1"></div>
						<div class="col-xs-11 col-lg-11">
					      	<label class="col-xs-12 col-lg-12 text-left pl-0">Hazmat Number</label>
					      	<input class="col-xs-12 col-lg-12" maxlength="150" name="HazmatNumber" value="#qCarrierELDCert.HazmatNumber#">
					    </div>
					    <div class="form-check col-xs-12 col-lg-12">
		  					<input name="Certifications" class="form-check-input" type="checkbox" value="2" id="Certification_2">
		  					<label class="form-check-label" for="Certification_2" <cfif listFind(qCarrierELDCert.Certifications , 2)> checked</cfif>>SmartWay</label>
						</div>
						<div class="form-check col-xs-12 col-lg-12">
		  					<input name="Certifications" class="form-check-input" type="checkbox" value="3" id="Certification_3" <cfif listFind(qCarrierELDCert.Certifications , 3)> checked</cfif>>
		  					<label class="form-check-label" for="Certification_3">CARB</label>
						</div>
						<div class="form-check col-xs-12 col-lg-12">
		  					<input name="Certifications" class="form-check-input" type="checkbox" value="4" id="Certification_4" <cfif listFind(qCarrierELDCert.Certifications , 4)> checked</cfif>>
		  					<label class="form-check-label" for="Certification_4">TWIC</label>
						</div>
						<div class="form-check col-xs-12 col-lg-12">
		  					<input name="Certifications" class="form-check-input" type="checkbox" value="5" id="Certification_1" <cfif listFind(qCarrierELDCert.Certifications , 5)> checked</cfif>>
		  					<label class="form-check-label" for="Certification_5">C-TPAT Certified</label>
						</div>
						<div class="clearfix"></div>
						<div class="col-xs-1 col-lg-1"></div>
						<div class="col-xs-11 col-lg-11">
					      	<label class="col-xs-12 col-lg-12 text-left pl-0">C-TPAT SVI Number</label>
					      	<input class="col-xs-12 col-lg-12" maxlength="150" name="CTPATSVINumber" value="#qCarrierELDCert.CTPATSVINumber#">
					    </div>
					</div>
					<div class="clearfix"></div>
				</cfif>
				<div class="col-xs-12 col-lg-12 text-center mt-10">
					<cfif isDefined("PrevEvent")>
						<input type="hidden" name="PrevEvent" value="#PrevEvent#">
						<input class="bttn" id="previous-btn" type="submit" name="back" value="PREVIOUS">
					</cfif>
					<label class="stepLabel">STEP #currentStep# OF #TotalStep#</label>
					<cfif isDefined("NextEvent")>
						<input class="bttn" id="next-btn" type="submit" name="submit" value="NEXT">
					</cfif>
				</div>
			</div>
		</div>
	</form>
</cfoutput>