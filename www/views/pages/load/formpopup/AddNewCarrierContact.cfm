<cfoutput>
	<style>
	    ##popup-carrier-contact{
	        width: 750px;
	        left: 18%;
	        background-color: #request.qSystemSetupOptions1.BackgroundColorForContent#;
	    }
	</style>
	<script type="text/javascript">
		function openAddNewCarrierContactPopup(id){
			$('##frmAddNewCarrierContact')[0].reset();
			$('body').addClass('formpopup-body-noscroll');
			$('.formpopup-overlay').show();
			$('##popup-carrier-contact').show();
			$('##fpContactTempID').val(id)
			var fpContactCarrierID = $('##carrierID'+id).val();
			$('##fpContactCarrierID').val(fpContactCarrierID);
			var fpKey = $('##CarrierContactID'+id).closest('div').find('.CarrierContactAuto').val();
			$('##fpContactName').val(fpKey).focus();
		}

		function submitCarrierContactForm(){
			if(!$.trim($('##fpContactType').val()).length){
	            alert('Please Select Contact Type.');
	            $('##fpContactType').focus();
	            return false;
	        }

			if(!$.trim($('##fpContactName').val()).length){
	            alert('Please Enter Contact Name.');
	            $('##fpContactName').focus();
	            return false;
	        }
	        var inputs = document.getElementById("frmAddNewCarrierContact").elements;
	        var formData = $("##frmAddNewCarrierContact").serialize();
			var path = urlComponentPath+"carriergateway.cfc?method=saveCarrierContactFromLoadScreen";
			$('.actbttn').hide();
			$('.fp-loader').show();
			$.ajax({
                type: "Post",
                url: path,
                dataType: "json",
                async: false,
                data: formData,
                success: function(data){
                	$('.actbttn').show();
					$('.fp-loader').hide();
                    if(data.SUCCESS == 0){
                        alert('Something went wrong. Please try again later.')
                    }
                    else{
                    	var fpContactTempID = $('##fpContactTempID').val();
                    	$('##CarrierContactID'+fpContactTempID).val(data.ID);
                    	$('##CarrierContactID'+fpContactTempID).closest('div').find('.CarrierContactAuto').val(inputs["fpContactName"].value);
                        $('body').removeClass('formpopup-body-noscroll');
		                $( ".form-popup" ).hide();
		                $('.formpopup-overlay').hide();
                    }
                }
            });
		}
	</script>
	<div class="form-popup" id="popup-carrier-contact">
	    <div class="form-popup-header">
	        Add New Carrier Contact
	        <span class="form-popup-close">&times;</span>
	    </div>
	    <div class="form-popup-content">
	    	<form name="frmAddNewCarrierContact" id="frmAddNewCarrierContact">
	    		<input type="hidden" name="fpContactCarrierID" id="fpContactCarrierID" value="">
	    		<input type="hidden" name="fpContactTempID" id="fpContactTempID" value="">
	    		<input type="hidden" name="dsn" id="dsn" value="#application.dsn#">
		        <div class="form-popup-content-partition">
		            <label>Contact Type</label>
		            <cfset listContactType = "Billing,Credit,Onboarding,Contract,Dispatch,General">
		            <select name="fpContactType" id="fpContactType">
		            	<option value="">Select</option>
		            	<cfloop list="#listContactType#" index="type">
                            <option value="#type#">#type#</option>
                        </cfloop>
		            </select>
		            <div class="clear"></div>
		            <label>Contact Name</label>
		            <input type="text" name="fpContactName" id="fpContactName" maxlength="150">
		            <div class="clear"></div>
		            <label>Phone</label>
		            <input type="text" class="medium-input" name="fpContactPhone" id="fpContactPhone" onchange="ParseUSNumber(this,'Phone');" maxlength="50">
		            <label class="small-label">Ext.</label>
		            <input class="small-input" type="text" name="fpContactPhoneExt" id="fpContactPhoneExt" maxlength="50">
		            <div class="clear"></div>
		            <label>Fax</label>
		            <input type="text" class="medium-input" name="fpContactFax" id="fpContactFax" onchange="ParseUSNumber(this,'Fax');" maxlength="50">
		            <label class="small-label">Ext.</label>
		            <input class="small-input" type="text" name="fpContactFaxExt" id="fpContactFaxExt" maxlength="50">
		            <div class="clear"></div>
		            <label>Toll Free</label>
		            <input type="text" class="medium-input" name="fpContactTollFree" id="fpContactTollFree" onchange="ParseUSNumber(this,'TollFree');" maxlength="50">
		            <label class="small-label">Ext.</label>
		            <input class="small-input" type="text" name="fpContactTollFreeExt" maxlength="50" id="fpContactTollFreeExt">
		            <div class="clear"></div>
		            <label>Cell</label>
		            <input type="text" class="medium-input" name="fpContactCell" id="fpContactCell" onchange="ParseUSNumber(this,'Cell');" maxlength="50">
		            <label class="small-label">Ext.</label>
		            <input class="small-input" type="text" name="fpContactCellExt" id="fpContactCellExt"  maxlength="50">
		            <div class="clear"></div>
		            <label>EmailID</label>
		            <input type="text" name="fpContactCellEmailID" id="fpContactCellEmailID">
		            <div class="clear"></div>
		            <label>Status</label>
		            <select class="small-select" name="fpContactActive" id="fpContactActive">
		            	<option value="1">Active</option>
                        <option value="0">InActive</option>
		            </select>
		            <div class="clear"></div>
		            <cfif request.qSystemSetupOptions1.ActivateBulkAndLoadNotificationEmail EQ 1>
			            <label>Email Available Loads</label>
			            <input type="checkbox" name="fpContactEmailAvailableLoads" id="fpContactEmailAvailableLoads">
			            <div class="clear"></div>
			        </cfif>
		            <input type="button" name="saveCarrierContactForm" class="actbttn" value="Save" style="margin-left: 100px;" onclick="submitCarrierContactForm()">
		            <input type="button" class="actbttn form-popup-close" name="closeCarrierContactForm" value="Close">
		            <img src="images/loadDelLoader.gif" class="fp-loader">
		        </div>
		        <div class="form-popup-content-partition">
		            <label>Address</label>
		            <textarea name="fpContactAddress" id="fpContactAddress" maxlength="200"></textarea>
		            <div class="clear"></div>
		            <label>City</label>
		            <input type="text" name="fpContactCity" id="fpContactCity" class="fpCityAuto" maxlength="50">
		            <div class="clear"></div>
		            <label>State</label>
		            <select style="width: 100px;" name="fpContactState" id="fpContactState" class="fpStateAuto">
		            	<option value="">Select</option>
		            	<cfloop query="request.qStates">
		                    <option value="#request.qStates.statecode#">#request.qStates.statecode#</option>
		                </cfloop>
		            </select>
		            <label style="width: 60px;">Zipcode</label>
		            <input type="text" style="width: 80px;" name="fpContactZip" id="fpContactZip" class="fpZipAuto" maxlength="10">
		            <div class="clear"></div>
		            <label>Notes</label>
		            <textarea style="height: 150px;" name="fpContactNotes" id="fpContactNotes"></textarea>
		        </div>
		    </form>
	    </div>
	</div>
</cfoutput>