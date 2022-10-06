<cfoutput>
	<script>
		$(document).ready(function(){
			<cfif qSystemConfig.ApplyToAll EQ 1>
				applyToAllInsurance()
			</cfif>
			<cfif structKeyExists(url, 'mssg') AND url.mssg EQ 1>
				alert('Invalid file size.')
			</cfif>
			$(".fileUpload").click(function(){
                $("##file").click();
            });
			$(".fileUpload_1").click(function(){
                $("##file_1").click();
            });
			$(".fileUpload_2").click(function(){
                $("##file_2").click();
            });

            $("##file").change(function(){
                var files = $('##file')[0].files[0];
                if(files.name.indexOf(".") == -1){
					alert('File without extension are not allowed.');
				    $("##file").val(null);
				    return false;
				}
				if (files.name.indexOf(":") != -1) {
					alert('File Name cannot contain any of the following characters:\n\/:*?"<>|');
					$("##file").val(null);
					return false;
				}
				if (files.size == 0) {
					alert('Invalid file size.');
					$("##file").val(null);
				    return false;
				}
                $('.uploadedFile').html('<span class="ml-25" style="font-weight: 700;">'+files.name+'</span>');
                $('.uploadedFileContainer').show();
				$('##applyToAll').show();
				$('.uploadarea').css("display", "none");

            });

            $("##file_1").change(function(){
                var files = $('##file_1')[0].files[0];
                if(files.name.indexOf(".") == -1){
					alert('File without extension are not allowed.');
				    $("##file_1").val(null);
				    return false;
				}
				if (files.name.indexOf(":") != -1) {
					alert('File Name cannot contain any of the following characters:\n\/:*?"<>|');
					$("##file_1").val(null);
					return false;
				}
				if (files.size == 0) {
					alert('Invalid file size.');
					$("##file_1").val(null);
				    return false;
				}
                $('.uploadedFile_1').html('<span class="ml-25" style="font-weight: 700;">'+files.name+'</span>');
                $('.uploadedFileContainer_1').show();
				$('##applyToAll').show();
				$('.uploadarea_1').css("display", "none");

            });
            $("##file_2").change(function(){
                var files = $('##file_2')[0].files[0];
                if(files.name.indexOf(".") == -1){
					alert('File without extension are not allowed.');
				    $("##file_2").val(null);
				    return false;
				}
				if (files.name.indexOf(":") != -1) {
					alert('File Name cannot contain any of the following characters:\n\/:*?"<>|');
					$("##file_2").val(null);
					return false;
				}
				if (files.size == 0) {
					alert('Invalid file size.');
					$("##file_2").val(null);
				    return false;
				}
                $('.uploadedFile_2').html('<span class="ml-25" style="font-weight: 700;">'+files.name+'</span>');
                $('.uploadedFileContainer_2').show();
				$('##applyToAll').show();
				$('.uploadarea_2').css("display", "none");

            });
			<cfif len(trim(qCertificate.attachmentFileName))>
            	$('.uploadedFileContainer').show();
            	$('##applyToAll').show();
            </cfif>
			<cfif len(trim(qCargoCertificate.attachmentFileName))>
            	$('.uploadedFileContainer_1').show();
            	$('##applyToAll').show();
            </cfif>
			<cfif len(trim(qGeneralCertificate.attachmentFileName))>
            	$('.uploadedFileContainer_2').show();
            	$('##applyToAll').show();
            </cfif>
            
			var BIPDuploadedFile = $('.uploadedFile').html();
			var cargoUploadedFile = $('.uploadedFile_1').html();
			var generalUploadedFile = $('.uploadedFile_2').html();
			if($.trim(BIPDuploadedFile).length){
				$('.uploadarea').css("display", "none");
			}
			if($.trim(cargoUploadedFile).length){
				$('.uploadarea_1').css("display", "none");
			}
			if($.trim(generalUploadedFile).length){
				$('.uploadarea_2').css("display", "none");
			}	

		})
		function applyToAllInsurance() {
			var BIPDuploadedFile = $('.uploadedFile').html();
			var cargoUploadedFile = $('.uploadedFile_1').html();
			var generalUploadedFile = $('.uploadedFile_2').html();
			if ($('.applyToAll').is(':checked')) {
				if(!$.trim(BIPDuploadedFile).length){
					$('.uploadarea').css("display", "none");
				}
				if(!$.trim(cargoUploadedFile).length){
					$('.uploadarea_1').css("display", "none");
				}
				if(!$.trim(generalUploadedFile).length){
					$('.uploadarea_2').css("display", "none");
				}
			}else{
				if(!$.trim(BIPDuploadedFile).length){
					$('.uploadarea').show();
				}
				if(!$.trim(cargoUploadedFile).length){
					$('.uploadarea_1').show();
				}
				if(!$.trim(generalUploadedFile).length){
					$('.uploadarea_2').show();
				}
			}
		}
		function deleteFile(ID,Attachment,field){
			var AttachmentID = ID;
			var AttachmentFileName = Attachment;
			var field = field;
			if($.trim(AttachmentID).length){
				$.ajax({
					type    : 'POST',
					url     : "ajax.cfm?event=ajxDelAttachment&CarrierID=#url.CarrierID#",
					data    : {
						AttachmentID : AttachmentID,AttachmentFileName:AttachmentFileName
					},
					success :function(){}
				})
			}
			if(field == 1){
				$("##file").val(null);
				$('.uploadedFileContainer').hide();
				$('.uploadedFile').html('');
				$('##AttachmentID').val('');
				$('.uploadarea').show();
			}
			if(field == 2){
				$("##file_1").val(null);
				$('.uploadedFileContainer_1').hide();
				$('.uploadedFile_1').html('');
				$('##InsCargoAttachmentID').val('');
				$('.uploadarea_1').show();
			}
			if(field == 3){
				$("##file_2").val(null);
				$('.uploadedFileContainer_2').hide();
				$('.uploadedFile_2').html('');
				$('##InsGeneralAttachmentID').val('');
				$('.uploadarea_2').show();
			}
			if (!$.trim($('.uploadedFile').html()).length && !$.trim($('.uploadedFile_2').html()).length && !$.trim($('.uploadedFile_1').html()).length) {
				$('.applyToAll').prop('checked', false);
				$('##applyToAll').hide();
			}
		}
	</script>
	<form method="post" enctype="multipart/form-data" action="index.cfm?event=CarrierInsurance:Process&CarrierID=#url.CarrierID#" onsubmit="return validateInsuranceForm()">
		<div class="row">
			<div class="col-xs-12 col-lg-4 pb-10">
				<h2 class="col-xs-12 col-lg-12 blueBg">Insurance - Auto Liability (BIPD)</h2>
				<div class="col-xs-8 col-lg-8">
			      	<label class="col-xs-12 col-lg-12 text-left pl-0 mb-0">Company<cfif qSystemConfig.RequireBIPDInsurance>*</cfif></label>
			      	<input class="col-xs-12 col-lg-12" maxlength="100" name="InsCompany" value="#qCarrierInsuranceInfo.InsCompany#">
			    </div>
			    <div class="col-xs-4 col-lg-4">
			      	<label class="col-xs-12 col-lg-12 text-left pl-0 mb-0">Phone<cfif qSystemConfig.RequireBIPDInsurance>*</cfif></label>
			      	<input class="col-xs-12 col-lg-12" maxlength="50" name="InsCompPhone" id="InsCompPhone" value="#qCarrierInsuranceInfo.InsCompPhone#" onchange="ParseUSNumber(this,'Phone');">
			    </div>
			    <div class="clearfix"></div>
			    <div class="col-xs-8 col-lg-8">
			      	<label class="col-xs-12 col-lg-12 text-left pl-0 mb-0">Agent</label>
			      	<input class="col-xs-12 col-lg-12" maxlength="150" name="InsAgent" value="#qCarrierInsuranceInfo.InsAgent#">
			    </div>
			    <div class="col-xs-4 col-lg-4">
			      	<label class="col-xs-12 col-lg-12 text-left pl-0 mb-0">Agent Phone</label>
			      	<input class="col-xs-12 col-lg-12" maxlength="50" name="InsAgentPhone" id="InsAgentPhone" value="#qCarrierInsuranceInfo.InsAgentPhone#" onchange="ParseUSNumber(this,'Phone');">
			    </div>
			    <div class="clearfix"></div>
			    <div class="col-xs-12 col-lg-12">
			      	<label class="col-xs-12 col-lg-12 text-left pl-0 mb-0">Email<cfif qSystemConfig.RequireBIPDInsurance>*</cfif></label>
			      	<input class="col-xs-12 col-lg-12" maxlength="50" name="InsEmail" value="#qCarrierInsuranceInfo.InsEmail#">
			    </div>
			    <div class="clearfix"></div>
			    <div class="col-xs-12 col-lg-12">
			      	<label class="col-xs-12 col-lg-12 text-left pl-0 mb-0">Address<cfif qSystemConfig.RequireBIPDInsurance>*</cfif></label>
			      	<textarea class="col-xs-12 col-lg-12" maxlength="250" name="InsuranceCompanyAddress">#qCarrierInsuranceInfo.InsuranceCompanyAddress#</textarea>
			    </div>
			    <div class="clearfix"></div>
			    <div class="col-xs-12 col-lg-12">
				    <label class="col-xs-2 col-lg-2 text-left pl-0 pr-0">Policy ##<cfif qSystemConfig.RequireBIPDInsurance>*</cfif></label>
				    <input class="col-xs-3 col-lg-3" maxlength="50" name="InsPolicyNumber" value="#qCarrierInsuranceInfo.InsPolicyNumber#">
				    <label class="col-xs-3 col-lg-4 pl-0">Expiration Date<cfif qSystemConfig.RequireBIPDInsurance>*</cfif></label>
				    <input class="col-xs-4 col-lg-3" type="datefield" name="InsExpDate" value="#DateFormat(qCarrierInsuranceInfo.InsExpDate,"mm/dd/yyyy")#" onblur="checkDateFormatAll(this);">
				</div>
				<div class="clearfix"></div>
			    <div class="col-xs-12 col-lg-12">
				    <label class="col-xs-2 col-lg-2 text-left pl-0 pr-0">Limit<cfif qSystemConfig.RequireBIPDInsurance>*</cfif></label>
				    <input class="col-xs-3 col-lg-3" name="InsLimit" value="#DollarFormat(qCarrierInsuranceInfo.InsLimit)#">
				    <label class="col-xs-5 col-lg-5 text-left">Household Goods:<cfif qSystemConfig.RequireBIPDInsurance>*</cfif></label>
				    <select class="col-xs-2 col-lg-2" name="householdGoods">
				    	<option value="1" <cfif qCarrierInsuranceInfo.householdGoods eq 1>selected="true"</cfif>>Yes</option>
						<option value="0" <cfif qCarrierInsuranceInfo.householdGoods eq 0>selected="true"</cfif>>No</option>
				    </select>
				</div>
				<div class="clearfix"></div>
				<div class="col-xs-10 col-lg-12">
					<div class="col-xs-12 col-lg-12 uploadarea" style="padding-left: 40px;">
						<div class="fileUploaded" style="margin-top: 20px;">
							<img src="../images/File_Upload.png" style="height:45px;width:65px;cursor: pointer;float:left;"  title="file upload" class="fileUpload">
							<cfif qSystemConfig.RequireBIPDInsurance><span style="color:red;font-size: 18px;padding-top: 9px;float:left;"> *</span></cfif>
							<label style="font-size: 1.1rem;text-decoration: underline;color:blue;cursor: pointer;text-align: left;float: left;padding-left: 2px;margin-top: 5px;" class="fileUpload">CLICK HERE TO UPLOAD YOUR<br>CERTIFICATE OF INSURANCE</label>
						</div>
					</div>
				</div>
				<div class="row">
					<div class="col-xs-10 col-lg-12 uploadedFileContainer" style="margin-top: 25px;">
						<div class="col-xs-8 col-lg-10 uploadedFile" style="font-size:13px;"><cfif len(trim(qCertificate.attachmentFileName))><span class="ml-25" style="font-weight: 700;">#qCertificate.attachmentFileName#</span></cfif></div>
						<div class="col-xs-1 col-lg-1" style="cursor: pointer;">
							<img src="../images/delete-icon.gif" onclick="deleteFile('#qCertificate.attachment_Id#','#qCertificate.AttachmentFileName#',1);">
						</div>
					</div>
					<div class="col-xs-2 col-lg-12" id="applyToAll" style="margin-top:13px; display:none;padding-left: 20px;">
						<input type="checkbox" class="applyToAll" name="applyToAll" <cfif qSystemConfig.ApplyToAll>checked</cfif> style="position: absolute;margin-top: 6px;" onclick="applyToAllInsurance()" value="1">
						<label style="margin-left: 20px;">Apply to all</label>
					</div>
				</div>
				<input type="file" name="file" id="file">
		    	<input type="hidden" name="AttachmentLabel" value="#qCertificate.attachedFileLabel#">
		    	<input type="hidden" name="AttachmentID" id="AttachmentID" value="#qCertificate.attachment_Id#">
		    	<input type="hidden" name="AttachmentFileName" id="AttachmentFileName" value="#qCertificate.AttachmentFileName#">
				<div class="clearfix"></div>
			</div>
			<div class="col-xs-12 col-lg-4 pb-10">
				<h2 class="col-xs-12 col-lg-12 blueBg">Insurance - Cargo</h2>
				<div class="col-xs-8 col-lg-8">
			      	<label class="col-xs-12 col-lg-12 text-left pl-0 mb-0">Company<cfif qSystemConfig.RequireCargoInsurance>*</cfif></label>
			      	<input class="col-xs-12 col-lg-12" maxlength="100" name="InsCompanyCargo" value="#qCarrierInsuranceInfo.InsCompanyCargo#">
			    </div>
			    <div class="col-xs-4 col-lg-4">
			      	<label class="col-xs-12 col-lg-12 text-left pl-0 mb-0">Phone<cfif qSystemConfig.RequireCargoInsurance>*</cfif></label>
			      	<input class="col-xs-12 col-lg-12" maxlength="50" name="InsCompPhoneCargo" id="InsCompPhoneCargo" value="#qCarrierInsuranceInfo.InsCompPhoneCargo#" onchange="ParseUSNumber(this,'Phone');">
			    </div>
			    <div class="clearfix"></div>
			    <div class="col-xs-8 col-lg-8">
			      	<label class="col-xs-12 col-lg-12 text-left pl-0 mb-0">Agent</label>
			      	<input class="col-xs-12 col-lg-12" maxlength="150" name="InsAgentCargo" value="#qCarrierInsuranceInfo.InsAgentCargo#">
			    </div>
			    <div class="col-xs-4 col-lg-4">
			      	<label class="col-xs-12 col-lg-12 text-left pl-0 mb-0">Agent Phone</label>
			      	<input class="col-xs-12 col-lg-12" maxlength="50" name="InsAgentPhoneCargo" name="InsAgentPhoneCargo" value="#qCarrierInsuranceInfo.InsAgentPhoneCargo#" onchange="ParseUSNumber(this,'Phone');">
			    </div>
			    <div class="clearfix"></div>
			    <div class="col-xs-12 col-lg-12">
			      	<label class="col-xs-12 col-lg-12 text-left pl-0 mb-0">Email<cfif qSystemConfig.RequireCargoInsurance>*</cfif></label>
			      	<input class="col-xs-12 col-lg-12" maxlength="50" name="InsEmailCargo" value="#qCarrierInsuranceInfo.InsEmailCargo#">
			    </div>
			    <div class="clearfix"></div>
			    <div class="col-xs-12 col-lg-12">
			      	<label class="col-xs-12 col-lg-12 text-left pl-0 mb-0">Address<cfif qSystemConfig.RequireCargoInsurance>*</cfif></label>
			      	<textarea class="col-xs-12 col-lg-12" maxlength="250" name="InsuranceCompanyAddressCargo">#qCarrierInsuranceInfo.InsuranceCompanyAddressCargo#</textarea>
			    </div>
			    <div class="clearfix"></div>
			    <div class="col-xs-12 col-lg-12">
				    <label class="col-xs-2 col-lg-2 text-left pl-0 pr-0">Policy ##<cfif qSystemConfig.RequireCargoInsurance>*</cfif></label>
				    <input class="col-xs-3 col-lg-3" maxlength="50" name="InsPolicyNumberCargo" value="#qCarrierInsuranceInfo.InsPolicyNumberCargo#">
				    <label class="col-xs-3 col-lg-4 pl-0">Expiration Date<cfif qSystemConfig.RequireCargoInsurance>*</cfif></label>
				    <input class="col-xs-4 col-lg-3" type="datefield" name="InsExpDateCargo" value="#DateFormat(qCarrierInsuranceInfo.InsExpDateCargo,"mm/dd/yyyy")#" onblur="checkDateFormatAll(this);">
				</div>
				<div class="clearfix"></div>
			    <div class="col-xs-12 col-lg-12">
				    <label class="col-xs-2 col-lg-2 text-left pl-0 pr-0">Limit<cfif qSystemConfig.RequireCargoInsurance>*</cfif></label>
				    <input class="col-xs-3 col-lg-3" name="InsLimitCargo" value="#DollarFormat(qCarrierInsuranceInfo.InsLimitCargo)#">
				    <label class="col-xs-5 col-lg-5 text-left">Household Goods:<cfif qSystemConfig.RequireCargoInsurance>*</cfif></label>
				    <select class="col-xs-2 col-lg-2" name="householdGoodsCargo">
				    	<option value="1" <cfif qCarrierInsuranceInfo.householdGoodsCargo eq 1>selected="true"</cfif>>Yes</option>
						<option value="0" <cfif qCarrierInsuranceInfo.householdGoodsCargo eq 0>selected="true"</cfif>>No</option>
				    </select>
				</div>
				<div class="clearfix"></div>
				<div class="col-xs-12 col-lg-12">
					<div class="col-xs-12 col-lg-12 uploadarea_1" style="padding-left: 40px;">
						<div class="fileUploaded" style="margin-top: 20px;">
							<img src="../images/File_Upload.png" style="height:45px;width:65px;cursor: pointer;float:left;"  title="file upload" class="fileUpload_1">
							<cfif qSystemConfig.RequireCargoInsurance><span style="color:red;font-size: 18px;padding-top: 9px;float:left;"> *</span></cfif>
							<label style="font-size: 1.1rem;text-decoration: underline;color:blue;cursor: pointer;text-align: left;float: left;padding-left: 2px;margin-top: 5px;" class="fileUpload_1">CLICK HERE TO UPLOAD YOUR<br>CERTIFICATE OF INSURANCE</label>
						</div>
					</div>
				</div>
				<div class="col-xs-12 col-lg-12 uploadedFileContainer_1" style="margin-top: 25px;">
					<div class="col-xs-8 col-lg-10 uploadedFile_1" style="font-size:13px;"><cfif len(trim(qCargoCertificate.attachmentFileName))><span class="ml-25" style="font-weight: 700;">#qCargoCertificate.attachmentFileName#</span></cfif></div>
					<div class="col-xs-1 col-lg-1" style="cursor: pointer;">
						<img src="../images/delete-icon.gif" onclick="deleteFile('#qCargoCertificate.attachment_Id#','#qCargoCertificate.AttachmentFileName#',2);">
					</div>
				</div>
				<input type="file" name="file_1" id="file_1">
		    	<input type="hidden" name="InsCargoAttachmentLabel" value="#qCargoCertificate.attachedFileLabel#">
		    	<input type="hidden" name="InsCargoAttachmentID" id="InsCargoAttachmentID" value="#qCargoCertificate.attachment_Id#">
		    	<input type="hidden" name="InsCargoAttachmentFileName" id="InsCargoAttachmentFileName" value="#qCargoCertificate.AttachmentFileName#">
				<div class="clearfix"></div>
			</div>
			<div class="col-xs-12 col-lg-4 pb-10">
				<h2 class="col-xs-12 col-lg-12 blueBg">Insurance - General Liability</h2>
				<div class="col-xs-8 col-lg-8">
			      	<label class="col-xs-12 col-lg-12 text-left pl-0 mb-0">Company<cfif qSystemConfig.RequireGeneralInsurance>*</cfif></label>
			      	<input class="col-xs-12 col-lg-12" maxlength="100" name="InsCompanyGeneral" value="#qCarrierInsuranceInfo.InsCompanyGeneral#">
			    </div>
			    <div class="col-xs-4 col-lg-4">
			      	<label class="col-xs-12 col-lg-12 text-left pl-0 mb-0">Phone<cfif qSystemConfig.RequireGeneralInsurance>*</cfif></label>
			      	<input class="col-xs-12 col-lg-12" maxlength="50" name="InsCompPhoneGeneral" value="#qCarrierInsuranceInfo.InsCompPhoneGeneral#" onchange="ParseUSNumber(this,'Phone');">
			    </div>
			    <div class="clearfix"></div>
			    <div class="col-xs-8 col-lg-8">
			      	<label class="col-xs-12 col-lg-12 text-left pl-0 mb-0">Agent</label>
			      	<input class="col-xs-12 col-lg-12" maxlength="150" name="InsAgentGeneral" value="#qCarrierInsuranceInfo.InsAgentGeneral#">
			    </div>
			    <div class="col-xs-4 col-lg-4">
			      	<label class="col-xs-12 col-lg-12 text-left pl-0 mb-0">Agent Phone</label>
			      	<input class="col-xs-12 col-lg-12" maxlength="50" name="InsAgentPhoneGeneral" id="InsAgentPhoneGeneral" value="#qCarrierInsuranceInfo.InsAgentPhoneGeneral#" onchange="ParseUSNumber(this,'Phone');">
			    </div>
			    <div class="clearfix"></div>
			    <div class="col-xs-12 col-lg-12">
			      	<label class="col-xs-12 col-lg-12 text-left pl-0 mb-0">Email<cfif qSystemConfig.RequireGeneralInsurance>*</cfif></label>
			      	<input class="col-xs-12 col-lg-12" maxlength="50" name="InsEmailGeneral" value="#qCarrierInsuranceInfo.InsEmailGeneral#">
			    </div>
			    <div class="clearfix"></div>
			    <div class="col-xs-12 col-lg-12">
			      	<label class="col-xs-12 col-lg-12 text-left pl-0 mb-0">Address<cfif qSystemConfig.RequireGeneralInsurance>*</cfif></label>
			      	<textarea class="col-xs-12 col-lg-12" maxlength="250" name="InsuranceCompanyAddressGeneral">#qCarrierInsuranceInfo.InsuranceCompanyAddressGeneral#</textarea>
			    </div>
			    <div class="clearfix"></div>
			    <div class="col-xs-12 col-lg-12">
				    <label class="col-xs-2 col-lg-2 text-left pl-0 pr-0">Policy ##<cfif qSystemConfig.RequireGeneralInsurance>*</cfif></label>
				    <input class="col-xs-3 col-lg-3" maxlength="50" name="InsPolicyNumberGeneral" value="#qCarrierInsuranceInfo.InsPolicyNumberGeneral#">
				    <label class="col-xs-3 col-lg-4 pl-0">Expiration Date<cfif qSystemConfig.RequireGeneralInsurance>*</cfif></label>
				    <input class="col-xs-4 col-lg-3" type="datefield" name="InsExpDateGeneral" value="#DateFormat(qCarrierInsuranceInfo.InsExpDateGeneral,"mm/dd/yyyy")#" onblur="checkDateFormatAll(this);">
				</div>
				<div class="clearfix"></div>
			    <div class="col-xs-12 col-lg-12">
				    <label class="col-xs-2 col-lg-2 text-left pl-0 pr-0">Limit<cfif qSystemConfig.RequireGeneralInsurance>*</cfif></label>
				    <input class="col-xs-3 col-lg-3" name="InsLimitGeneral" value="#DollarFormat(qCarrierInsuranceInfo.InsLimitGeneral)#">
				    <label class="col-xs-5 col-lg-5 text-left">Household Goods:<cfif qSystemConfig.RequireGeneralInsurance>*</cfif></label>
				    <select class="col-xs-2 col-lg-2" name="householdGoodsGeneral">
				    	<option value="1" <cfif qCarrierInsuranceInfo.householdGoodsGeneral eq 1>selected="true"</cfif>>Yes</option>
						<option value="0" <cfif qCarrierInsuranceInfo.householdGoodsGeneral eq 0>selected="true"</cfif>>No</option>
				    </select>
				</div>
				<div class="clearfix"></div>
				<div class="col-xs-12 col-lg-12">
					<div class="col-xs-12 col-lg-12 uploadarea_2" style="padding-left: 40px;">
						<div class="fileUploaded" style="margin-top: 20px;">
							<img src="../images/File_Upload.png" style="height:45px;width:65px;cursor: pointer;float:left;"  title="file upload" class="fileUpload_2">
							<cfif qSystemConfig.RequireGeneralInsurance><span style="color:red;font-size: 18px;padding-top: 9px;float:left;"> *</span></cfif>
							<label style="font-size: 1.1rem;text-decoration: underline;color:blue;cursor: pointer;text-align: left;float: left;padding-left: 2px;margin-top: 5px;" class="fileUpload_2">CLICK HERE TO UPLOAD YOUR<br>CERTIFICATE OF INSURANCE</label>
						</div>
					</div>
				</div>
				<div class="col-xs-12 col-lg-12 uploadedFileContainer_2" style="margin-top: 25px;">
					<div class="col-xs-8 col-lg-10 uploadedFile_2" style="font-size:13px;"><cfif len(trim(qGeneralCertificate.attachmentFileName))><span class="ml-25" style="font-weight: 700;">#qGeneralCertificate.attachmentFileName#</span></cfif></div>
					<div class="col-xs-1 col-lg-1" style="cursor: pointer;">
						<img src="../images/delete-icon.gif" onclick="deleteFile('#qGeneralCertificate.attachment_Id#','#qGeneralCertificate.AttachmentFileName#',3);">
					</div>
				</div>
				<input type="file" name="file_2" id="file_2">
				<input type="hidden" name="InsGeneralAttachmentLabel" value="#qGeneralCertificate.attachedFileLabel#">
		    	<input type="hidden" name="InsGeneralAttachmentID" id="InsGeneralAttachmentID" value="#qGeneralCertificate.attachment_Id#">
		    	<input type="hidden" name="InsGeneralAttachmentFileName" id="InsGeneralAttachmentFileName" value="#qGeneralCertificate.AttachmentFileName#">
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