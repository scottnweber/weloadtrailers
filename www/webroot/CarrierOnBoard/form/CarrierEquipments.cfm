<cfoutput>
	<form method="post" class="col-xs-12 col-lg-6 pl-0 pr-0" action="index.cfm?event=CarrierEquipments:Process&CarrierID=#url.CarrierID#">
		<div class="row" id="Driver_1">
			<div class="col-xs-12 col-lg-12 pb-10">
				<h2 class="col-xs-12 col-lg-12 blueBg">Select your Equipment</h2>
				<cfloop query="qEquipments">
					<div class="form-check col-xs-6 col-lg-4">
	  					<input name="CarrierEquipments" class="form-check-input" type="checkbox" value="#qEquipments.EquipmentID#" id="#qEquipments.EquipmentID#"
	  					<cfif listFindNoCase(valuelist(qCarrierEquipments.EquipmentID), qEquipments.EquipmentID)> checked </cfif>>
	  					<label class="form-check-label" for="#qEquipments.EquipmentID#">#qEquipments.EquipmentName#</label>
					</div>
				</cfloop>
				<div class="clearfix"></div>
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