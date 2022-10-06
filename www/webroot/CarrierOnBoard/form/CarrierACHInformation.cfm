<cfoutput>
	<script>
		$(document).ready(function(){
			$(".fileUpload").click(function(){
                $("##file").click();
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
			<cfif len(trim(qCopyOfVoid.attachmentFileName))>
            	$('.uploadedFileContainer').show();
            </cfif>

			var copyOfVoided = $('.uploadedFile').html();
			if($.trim(copyOfVoided).length){
				$('.uploadarea').css("display", "none");
			}
		})
		function deleteFile(){
			var AttachmentID = $('##AttachmentID').val();
			var AttachmentFileName = $('##AttachmentFileName').val();
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
				$("##file").val(null);
				$('.uploadedFileContainer').hide();
				$('.uploadedFile').html('');
				$('##AttachmentID').val('');
				$('.uploadarea').show();
		}
	</script>
	<form method="post" enctype="multipart/form-data" class="col-xs-12 col-lg-6 pl-0 pr-0" action="index.cfm?event=CarrierACHInformation:Process&CarrierID=#url.CarrierID#" onsubmit="return validateACHInformationForm()">
		<div class="row">
			<div class="col-xs-12 col-lg-12 pb-10">
				<h2 class="col-xs-12 col-lg-12 blueBg">ACH Payment Information</h2>
				<div class="col-xs-12 col-lg-12">
					<label class="col-xs-3 col-lg-3">Bank Name</label>
					<input class="col-xs-9 col-lg-9" maxlength="150" name="ACHBankName" value="#qCarrierACH.ACHBankName#">
					<div class="clearfix"></div>
					<label class="col-xs-3 col-lg-3">Address</label>
					<textarea class="col-xs-9 col-lg-9" maxlength="200" name="ACHBankAddress">#qCarrierACH.ACHBankAddress#</textarea>
					<div class="clearfix"></div>
					<label class="col-xs-3 col-lg-3">City</label>
					<input class="col-xs-9 col-lg-9 CityAuto" maxlength="150" name="ACHBankCity" id="ACHBankCity" value="#qCarrierACH.ACHBankCity#" tabindex="-1">
					<div class="clearfix"></div>
					<label class="col-xs-3 col-lg-3">State</label>
					<select class="col-xs-3 col-lg-3 StateAuto" name="ACHBankState" id="ACHBankState" tabindex="-1">
						<option value="">Select</option>
						<cfloop query="qStates">
							<option value="#qStates.StateCode#" <cfif qCarrierACH.ACHBankState EQ qStates.StateCode> selected </cfif>>#qStates.StateCode#</option>
						</cfloop>
					</select>
					<label class="col-xs-3 col-lg-3">Zip</label>
					<input class="col-xs-3 col-lg-3 ZipAuto" maxlength="20" name="ACHBankZip" id="ACHBankZip" value="#qCarrierACH.ACHBankZip#">
					<div class="clearfix"></div>
					<label class="col-xs-3 col-lg-3">Phone</label>
					<input class="col-xs-5 col-lg-5" maxlength="150" name="ACHBankPhone" id="ACHBankPhone" value="#qCarrierACH.ACHBankPhone#" onchange="ParseUSNumber(this,'Phone');">
					<label class="col-xs-2 col-lg-2">Ext.</label>
					<input class="col-xs-2 col-lg-2" name="ACHBankPhoneExt" maxlength="50" value="#qCarrierACH.ACHBankPhoneExt#">
					<div class="clearfix"></div>
					<label class="col-xs-3 col-lg-3">Routing Number</label>
					<input class="col-xs-5 col-lg-5" maxlength="150" name="ACHBankRoutingNumber" value="#qCarrierACH.ACHBankRoutingNumber#">
					<div class="clearfix"></div>
					<label class="col-xs-3 col-lg-3">Checking Account Number</label>
					<input class="col-xs-5 col-lg-5" maxlength="150" name="ACHBankCheckingAccountNumber" value="#qCarrierACH.ACHBankCheckingAccountNumber#">
				</div>
				<div class="clearfix"></div>
				<div class="col-xs-12 col-lg-12">
					<div class="col-xs-12 col-lg-12 uploadarea">
						<div class="fileUploaded" style="margin-top: 10px; text-align:center;">
							<img src="../images/file-upload.png" style="height:30px;width:22px;"  title="file upload">
							<cfif qSystemConfig.RequireVoidedCheck><span style="color:red;font-size: 18px;padding-left: 8px;"> *</span></cfif>
							<label style="font-size: 1.1rem;text-decoration: underline;color:blue;margin-left:10px;"class="fileUpload">Upload copy of voided check here</label>
						</div>
					</div>
				</div>
				<div class="row">
					<div class="col-xs-10 col-lg-12 uploadedFileContainer" style="margin-top: 15px;margin-left: 10px;">
						<div class="col-xs-8 col-lg-10 uploadedFile" style="font-size:13px;"><cfif len(trim(qCopyOfVoid.attachmentFileName))><span class="ml-25" style="font-weight: 700;">#qCopyOfVoid.attachmentFileName#</span></cfif></div>
						<div class="col-xs-1 col-lg-1" style="cursor: pointer;">
							<img src="../images/delete-icon.gif" onclick="deleteFile();">
						</div>
					</div>
				</div>
				<input type="file" name="file" id="file">
		    	<input type="hidden" name="AttachmentLabel" value="#qCopyOfVoid.attachedFileLabel#">
		    	<input type="hidden" name="AttachmentID" id="AttachmentID" value="#qCopyOfVoid.attachment_Id#">
		    	<input type="hidden" name="AttachmentFileName" id="AttachmentFileName" value="#qCopyOfVoid.AttachmentFileName#">
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