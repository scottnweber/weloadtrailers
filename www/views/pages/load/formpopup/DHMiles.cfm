<cfinvoke component="#variables.objAgentGateway#" method="getAllCountries" returnvariable="request.qCountries" />
<cfoutput>
	<style>
	    ##popup-dh-miles{
	        left: 27%;
	        background-color: #request.qSystemSetupOptions1.BackgroundColorForContent#;
	        width: 365px;
	    }
	</style>
	<script type="text/javascript">
		function openDHMilesPopup(){
			$('##frmDHMiles')[0].reset();
			$('body').addClass('formpopup-body-noscroll');
			$('.formpopup-overlay').show();
			$('##popup-dh-miles').show();
		}

		function submitDHMilesForm(){
			if(!$.trim($('##fpDHMilesAddress').val()).length){
	            alert('Please Enter Address.');
	            $('##fpDHMilesAddress').focus();
	            return false;
	        }       
	        if(!$.trim($('##fpDHMilesCity').val()).length){
	            alert('Please Enter City.');
	            $('##fpDHMilesCity').focus();
	            return false;
	        } 
	        if(!$.trim($('##fpDHMilesState').val()).length){
	            alert('Please Choose State.');
	            $('##fpDHMilesState').focus();
	            return false;
	        } 
	        if(!$.trim($('##fpDHMilesZip').val()).length){
	            alert('Please Enter ZipCode.');
	            $('##fpDHMilesZip').focus();
	            return false;
	        } 
	        if(!$.trim($('##fpDHMilesCountry').val()).length){
	            alert('Please Choose Country.');
	            $('##fpDHMilesCountry').focus();
	            return false;
	        } 
	        calculateCustomDeadHeadMiles()
	        $('body').removeClass('formpopup-body-noscroll');
            $( ".form-popup" ).hide();
            $('.formpopup-overlay').hide();
		}
	</script>
	<div class="form-popup" id="popup-dh-miles">
	    <div class="form-popup-header">
	        Dead Head Miles
	        <span class="form-popup-close">&times;</span>
	    </div>
	    <div class="form-popup-content">
	    	<form name="frmDHMiles" id="frmDHMiles">
	            <label>Address*</label>
		        <textarea name="fpDHMilesAddress" id="fpDHMilesAddress" maxlength="200" style="width: 188px;"></textarea>
		        <div class="clear"></div>
	            <label>City*</label>
	            <input type="text" name="fpDHMilesCity" id="fpDHMilesCity" class="fpCityAuto" maxlength="50" style="width: 188px;">
	            <div class="clear"></div>
	            <label>State*</label>
	            <select style="width: 194px;" name="fpDHMilesState" id="fpDHMilesState" class="fpStateAuto">
	            	<option value="">Select</option>
	            	<cfloop query="request.qStates">
	                    <option value="#request.qStates.statecode#">#request.qStates.statecode#</option>
	                </cfloop>
	            </select>
	            <div class="clear"></div>
	            <label>Zipcode*</label>
	            <input type="text" style="width: 188px;" name="fpDHMilesZip" id="fpDHMilesZip" class="fpZipAuto" maxlength="50">
	            <div class="clear"></div>
	            <label>Country*</label>
        		<select name="fpDHMilesCountry" id="fpDHMilesCountry" style="width: 194px;">
        			<option value="">Select</option>
			        <cfloop query="request.qCountries">
			        	<cfif request.qCountries.countrycode EQ 'US'>
			        		<option data-code="#request.qCountries.countrycode#" value="#request.qCountries.countryID#" selected>#request.qCountries.country#</option>
			        	</cfif>
			        </cfloop>
			        <cfloop query="request.qCountries">
			        	<cfif request.qCountries.countrycode EQ 'CA'>
			        		<option data-code="#request.qCountries.countrycode#" value="#request.qCountries.countryID#">#request.qCountries.country#</option>
			        	</cfif>
			        </cfloop>
					<cfloop query="request.qCountries">
						<cfif not listFindNoCase("CA,US", request.qCountries.countrycode)>
				        	<option data-code="#request.qCountries.countrycode#" value="#request.qCountries.countryID#">#request.qCountries.country#</option>
				        </cfif>
					</cfloop>
				</select>
				<div class="clear"></div>
	            <input type="button" name="saveDHMilesForm" class="actbttn" value="Calculate" style="margin-left: 170px;" onclick="submitDHMilesForm()">
	            <div class="clear"></div>
		        <input type="button" class="actbttn form-popup-close" name="closeDHMilesForm" class="bttn" value="Close" style="margin-left: 170px;">
		        <img src="images/loadDelLoader.gif" class="fp-loader">
		    </form>
	    </div>
	</div>
</cfoutput>