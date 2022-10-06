<cfoutput>
    <style>
	    ##popup-add-new-factory{
	        left: 27%;
	        background-color: #request.qSystemSetupOptions.BackgroundColorForContent#;
	        width: 450px;
	    }
	</style>
    <script type="text/javascript">
        function openAddNewFactoryPopup(){
			$('##frmAddNewFactory')[0].reset();
			$('body').addClass('formpopup-body-noscroll');
			$('.formpopup-overlay').show();
			$('##popup-add-new-factory').show();
			var fpKey = $('##cutomerIdAuto').val();
			$('##fpFactoringCompanyName').val(fpKey).focus();
		}

		function submitCustomerForm(){
			if(!$.trim($('##fpFactoringCompanyName').val()).length){
	            alert('Please Enter Factory Name.');
	            $('##fpFactoringCompanyName').focus();
	            return false;
	        }
	        var inputs = document.getElementById("frmAddNewFactory").elements;
			var formData = $("##frmAddNewFactory").serialize();
			var path = urlComponentPath+"customergateway.cfc?method=saveFactoryFromCustScreen";
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
                        var opt = '<option value="'+data.ID+'" data-remitname="'+inputs["fpFactoringCompanyName"].value+'" data-remitaddress="'+inputs["fpFactoringCompanyAddress"].value+'" data-remitcity="'+inputs["fpFactoringCompanyCity"].value+'" data-remitstate="'+inputs["fpFactoringCompanyState"].value+'" data-remitzip="'+inputs["fpFactoringCompanyZip"].value+'" data-remitcontact="'+inputs["fpFactoringCompanyContact"].value+'" data-remitphone="'+inputs["fpFactoringCompanyPhone"].value+'" data-remitfax="'+inputs["fpFactoringCompanyFax"].value+'">'+inputs["fpFactoringCompanyName"].value+'</option>';
                        $('##FactoringID').append(opt);
                        $('##FactoringID option[value="'+data.ID+'"]').attr("selected", "selected");
                        $('##RemitName').val(inputs["fpFactoringCompanyName"].value);
                        $('##RemitAddress').val(inputs["fpFactoringCompanyAddress"].value);
                        $('##RemitCity').val(inputs["fpFactoringCompanyCity"].value);
                        $('##RemitState').val(inputs["fpFactoringCompanyState"].value);
                        $('##RemitZipcode').val(inputs["fpFactoringCompanyZip"].value);
                        $('##RemitContact').val(inputs["fpFactoringCompanyContact"].value);
                        $('##RemitPhone').val(inputs["fpFactoringCompanyPhone"].value);
                        $('##RemitFax').val(inputs["fpFactoringCompanyFax"].value);
                        $('body').removeClass('formpopup-body-noscroll');
		                $( ".form-popup" ).hide();
		                $('.formpopup-overlay').hide();
                    }
                }
            });

		}
    </script>

<div class="form-popup" id="popup-add-new-factory">
    <div class="form-popup-header">
        Add New Factory
        <span class="form-popup-close">&times;</span>
    </div>
    <div class="form-popup-content">
        <form name="frmAddNewFactory" id="frmAddNewFactory">
            <input type="hidden" name="dsn" id="dsn" value="#application.dsn#">
            <input type="hidden" name="adminUserName" id="adminUserName" value="#session.adminUserName#">
            <input type="hidden" name="EmpID" id="adminUserName" value="#session.EmpID#">
            <input type="hidden" name="CompanyID" id="CompanyID" value="#session.CompanyID#">
            <label>Factoring Company Name*</label>
            <input type="text" name="fpFactoringCompanyName" id="fpFactoringCompanyName" maxlength="100">
            <div class="clear"></div>
            <label>Address</label>
            <textarea name="fpFactoringCompanyAddress" id="fpFactoringCompanyAddress" maxlength="200" style="font-family: Arial"></textarea>
            <div class="clear"></div>
            <label>City</label>
            <input type="text" name="fpFactoringCompanyCity" id="fpFactoringCompanyCity" class="fpCityAuto" maxlength="50"  tabindex="-1">
            <div class="clear"></div>
            <label>State</label>
            <select style="width: 100px;" name="fpFactoringCompanyState" id="fpFactoringCompanyState" class="fpStateAuto"  tabindex="-1">
                <option value="">Select</option>
                <cfloop query="request.qStates">
                    <option value="#request.qStates.statecode#">#request.qStates.statecode#</option>
                </cfloop>
            </select>
            <label style="width: 60px;">Zipcode</label>
            <input type="text" style="width: 80px;" name="fpFactoringCompanyZip" id="fpFactoringCompanyZip" class="fpZipAuto" maxlength="50">
            <div class="clear"></div>
            <label>Contact</label>
            <input type="text" name="fpFactoringCompanyContact" name="fpFactoringCompanyContact" maxlength="50">
            <div class="clear"></div>
            <label>Phone</label>
            <input type="text" class="medium-input" name="fpFactoringCompanyPhone" name="fpFactoringCompanyPhone" onchange="ParseUSNumber(this,'Phone');" maxlength="50">
            <div class="clear"></div>
            <label>Fax</label>
            <input type="text" class="medium-input" name="fpFactoringCompanyFax" name="fpFactoringCompanyFax" onchange="ParseUSNumber(this,'Fax');" maxlength="50">
            <div class="clear"></div>
            <input type="button" name="saveCustomerForm" class="actbttn" value="Save" style="margin-left: 100px;" onclick="submitCustomerForm()">
            <input type="button" class="actbttn form-popup-close" name="closeCustomerForm" class="bttn" value="Close">
            <img src="images/loadDelLoader.gif" class="fp-loader">
        </form>
    </div>
</div>
</cfoutput>