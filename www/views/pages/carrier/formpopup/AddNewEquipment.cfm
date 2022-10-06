<cfoutput>
	<style>
	    ##popup-add-equipment{
	        width: 750px;
	        left: 18%;
	        background-color: #request.qSystemSetupOptions1.BackgroundColorForContent#;
	        top:20%;
	    }
	</style>
	<script type="text/javascript">
		$(document).ready(function(){
			$("##fpEquipmentName").keyup(function(){
			  	var key = $(this).val().replace(/\s+/g, '');
			  	if(key.length <=10){
			  		$("##fpEquipmentCode").val(key);
			  	}
			});
		});
		function openAddNewEquipmentPopup(term,id,type){
			$('##frmAddNewEquipment')[0].reset();
			$('body').addClass('formpopup-body-noscroll');
			$('.formpopup-overlay').show();
			$('##popup-add-equipment').show();
			$('##fpEquipmentName').val(term).focus();
			var Code = term.replace(/\s+/g, '');
			$('##fpEquipmentCode').val(Code);
			$('##tempID').val(id);
			$('##fpEquipmentType').val(type)
			$("##"+id).select2("close");
			$('##fpEquipmentName').focus();
		}
		function submitEquipmentForm(){
			if(!$.trim($('##fpEquipmentCode').val()).length){
	            alert('Please Enter Equipment Code.');
	            $('##fpContactType').focus();
	            return false;
	        }
	        if(!$.trim($('##fpEquipmentName').val()).length){
	            alert('Please Enter Equipment Name.');
	            $('##fpEquipmentName').focus();
	            return false;
	        }
	        var eqLength = document.getElementById('fpEquipmentLength').value;	
			eqLength = eqLength.replace("$","");
			eqLength = eqLength.replace(/,/g,"");
	        if(isNaN(eqLength) || !eqLength.length){
	            alert('Invalid Length.');
	            $('##fpEquipmentLength').focus();
	            return false;
	        }
	        var eqWidth = document.getElementById('fpEquipmentWidth').value;	
			eqWidth = eqWidth.replace("$","");
			eqWidth = eqWidth.replace(/,/g,"");
	        if(isNaN(eqWidth) || !eqWidth.length){
	            alert('Invalid Width.');
	            $('##fpEquipmentWidth').focus();
	            return false;
	        }
	        var eqTemp = document.getElementById('fpEquipmentTemperature').value;	
			eqTemp = eqTemp.replace("$","");
			eqTemp = eqTemp.replace(/,/g,"");
	        if(isNaN(eqTemp) && eqTemp.length){
	            alert('Invalid Temperature.');
	            $('##fpEquipmentTemperature').focus();
	            return false;
	        }

	        var inputs = document.getElementById("frmAddNewEquipment").elements;
	        var formData = $("##frmAddNewEquipment").serialize();
			var path = urlComponentPath+"equipmentgateway.cfc?method=saveEquipmentPopup";
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
                    	var fpID = $('##tempID').val();
                    	var fpType = $('##fpEquipmentType').val();
                    	if(fpType='Truck'){
                    		var opt='<option selected value="'+data.ID+'" data-trailer="">'+inputs["fpEquipmentName"].value+'</option>';
		                	$('##'+fpID).append(opt).change();
                    	}
                    	else{
                    		var opt='<option selected value="'+data.ID+'">'+inputs["fpEquipmentName"].value+'</option>';
		                	$('##'+fpID).append(opt);
                    	}
		                createSelect2();
		                $('body').removeClass('formpopup-body-noscroll');
		                $( ".form-popup" ).hide();
		                $('.formpopup-overlay').hide();
                    }
                }
            });

		}
	</script>
	<div class="form-popup" id="popup-add-equipment">
	    <div class="form-popup-header">
	        Add New Equipment
	        <span class="form-popup-close">&times;</span>
	    </div>
	    <div class="form-popup-content">
	    	<form name="frmAddNewEquipment" id="frmAddNewEquipment">
	    		<input type="hidden" name="dsn" id="dsn" value="#application.dsn#">
	    		<input type="hidden" name="CompanyID" id="CompanyID" value="#session.CompanyID#">
	    		<input type="hidden" name="adminUserName" id="adminUserName" value="#session.adminUserName#">
	    		<input type="hidden" name="EmpID" id="EmpID" value="#session.EmpID#">
	    		<input type="hidden" name="tempID" id="tempID" value="">

	    		<input type="hidden" name="fpEquipmentType" id="fpEquipmentType" value="">
		        <div class="form-popup-content-partition">
		            <label>Equipment Code*</label>
		            <input type="text" name="fpEquipmentCode" id="fpEquipmentCode" maxlength="100" style="width: 124px;">
		            <div class="clear"></div>
		            <label>Name*</label>
		            <input type="text" name="fpEquipmentName" id="fpEquipmentName" maxlength="150">
		            <div class="clear"></div>
		            <label>Length</label>
		            <input class="small-input" type="text" name="fpEquipmentLength" id="fpEquipmentLength" maxlength="50" value="1">
		            <label style="width: 43px;">Width</label>
		            <input class="small-input" type="text" name="fpEquipmentWidth" id="fpEquipmentWidth" maxlength="50" value="1">
		            <div class="clear"></div>
		            <label>ITS Code</label>
		            <input type="text" class="medium-input" name="fpEquipmentITSCode" id="fpEquipmentITSCode" maxlength="50">
		            <div class="clear"></div>
		            <label>DAT Load Board Code</label>
		            <input type="text" class="medium-input" name="fpEquipmentDATCode" id="fpEquipmentDATCode" maxlength="50">
		            <div class="clear"></div>
		            <label>Loadboard Network Code</label>
		            <input type="text" class="medium-input" name="fpEquipmentPECode" id="fpEquipmentPECode" maxlength="50">
		            <div class="clear"></div>
		            <input type="button" name="saveEquipmentForm" class="actbttn" value="Save" style="margin-left: 100px;" onclick="submitEquipmentForm()">
		            <input type="button" class="actbttn form-popup-close" name="closeEquipmentForm" value="Close">
		            <img src="images/loadDelLoader.gif" class="fp-loader">
		        </div>
		        <div class="form-popup-content-partition">
		            <label>Status</label>
		            <select style="width: 100px;" name="fpEquipmentStatus" id="fpEquipmentStatus">
		            	<option value="1">Active</option>
					  	<option value="0">InActive</option>
		            </select>
		            <div class="clear"></div>
		            <label>123Loadboard Code</label>
		            <input type="text" class="medium-input" name="fpEquipment123Code" id="fpEquipment123Code" maxlength="50">
		            <div class="clear"></div>
		            <label>DirectFreight Code</label>
		            <input type="text" class="medium-input" name="fpEquipmentDFCode" id="fpEquipmentDFCode" maxlength="50">
		            <div class="clear"></div>
		            <label>Traccar##</label>
		            <input type="text" class="medium-input" name="fpEquipmentTraccar" id="fpEquipmentTraccar" maxlength="50" onkeyup="if (/\D/g.test(this.value)) this.value = this.value.replace(/\D/g,'')">
		            <div class="clear"></div>
		            <label>Temperature</label>
		            <input class="small-input" type="text" name="fpEquipmentTemperature" id="fpEquipmentTemperature" maxlength="50">
		            <label style="width: 5px;margin-top: -5px;margin-left: 5px;"><sup>o</sup></label>
		            <select style="width: 35px;" name="fpEquipmentTempScale" id="fpEquipmentTempScale">
		            	<option value="C">C</option>
						<option value="F">F</option>
		            </select>
		        </div>
		    </form>
	    </div>
	</div>
</cfoutput>