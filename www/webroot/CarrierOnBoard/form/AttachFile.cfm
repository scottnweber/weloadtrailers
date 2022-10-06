<cfoutput>
	<script type="text/javascript">
		$(document).ready(function(){
			$("html").on("dragover", function(e) {
                e.preventDefault();
                e.stopPropagation();
                $(".uplH1").text("Drag here");
            });
            $("html").on("drop", function(e) { e.preventDefault(); e.stopPropagation(); });
            $('.upload-area').on('dragenter', function (e) {
                e.stopPropagation();
                e.preventDefault();
                $(".uplH1").text("Drop");
            });

            $('.upload-area').on('dragover', function (e) {
                e.stopPropagation();
                e.preventDefault();
                $(".uplH1").text("Drop");
            });

            $('.upload-area').on('drop', function (e) {
                e.stopPropagation();
                e.preventDefault();
                var file = e.originalEvent.dataTransfer.files;		
				if (file[0].size == 0) {
					alert('Invalid file size.');
					$(".uplH1").html("DRAG AND DROP FILE HERE <br> OR CLICK TO BROWSE");
				    return false;
				}
                $("input[type='file']").prop("files", file);
                $('.uploadedFile').html('<span class="ml-25">'+file[0].name+'</span>');
                $('.uploadedFileContainer').show();
                $(".uplH1").html("DRAG AND DROP FILE HERE <br> OR CLICK TO BROWSE");
            });

            $(".upload-area").click(function(){
                $("##file").click();
            });

            $("##file").change(function(){
                var files = $('##file')[0].files[0];
                if(files.name.indexOf(".") == -1){
					alert('File without extension are not allowed.');
				    $("##file").val(null);
				    return false;
				}
				if (files.name.indexOf(":") != -1 || files.name.indexOf("*") != -1) {
					alert('File Name cannot contain any of the following characters:\n\/:*?"<>|');
					$("##file").val(null);
					return false;
				}
				if (files.size == 0) {
					alert('Invalid file size.');
					$("##file").val(null);
				    return false;
				}
                $('.uploadedFile').html('<span class="ml-25">'+files.name+'</span>');
                $('.uploadedFileContainer').show();
            });

            <cfif len(trim(qCarrAtt.attachmentFileName))>
            	$('.uploadedFileContainer').show();
            </cfif>
		})

		function validateAttachment(){
			<cfif qAttDetail.required>
				var uploadedFile = $('.uploadedFile').html();
				if(!$.trim(uploadedFile).length){
					alert('Please upload the #qAttDetail.Description# to continue your onboarding process.')
					return false;
				}
			</cfif>
			var ExpiredAttachmentFileName = $('##ExpiredAttachmentFileName').val();
			var uploadedFile = $.trim($('.uploadedFile .ml-25').html());
			if($.trim(ExpiredAttachmentFileName).length && $.trim(uploadedFile).length && ExpiredAttachmentFileName==uploadedFile){
				alert('Document is expired. Please renew.');
				return false;
			}
		}

		function deleteFile(){

			var AttachmentID = $('##AttachmentID').val();
			var AttachmentFileName = $('##AttachmentFileName').val();
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
		}
	</script>
	<form method="post" enctype="multipart/form-data" action="index.cfm?event=#AttachmentTypeID#_AttachFile:Process&CarrierID=#url.CarrierID#<cfif structKeyExists(url, "RenewAttachmentType")>&RenewAttachmentType=#url.RenewAttachmentType#</cfif>" onsubmit="return validateAttachment();">
		<div class="row">
			<div class="col-xs-12 col-lg-12">
				<h2 class="col-xs-12 col-lg-12 blueBg">#qAttDetail.Description#<cfif qAttDetail.required><span style="color:red;"> *</span></cfif></h2>
			</div>
			<div class="col-xs-12 col-lg-12">
				<div class="col-xs-12 col-lg-12 upload-area">
			        <h1 class="col-xs-12 col-lg-12 uplH1">DRAG AND DROP FILE HERE<br>OR CLICK TO BROWSE</h1>
			    </div>
		    </div>
		    <div class="col-xs-12 col-lg-12 uploadedFileContainer">
		    	<div class="col-xs-10 col-lg-6 uploadedFile"><cfif len(trim(qCarrAtt.attachmentFileName))><span class="ml-25">#qCarrAtt.attachmentFileName#</span></cfif></div>
			    <div class="col-xs-2 col-lg-1" style="cursor: pointer;">
			    	<img src="../images/delete-icon.gif" onclick="deleteFile();">
			    </div>
		    </div>
		    <div class="clearfix"></div>
		    <div class="col-xs-12 col-lg-12 text-center mt-10">
		    	<input type="hidden" name="AttachmentTypeID" value="#AttachmentTypeID#">
		    	<input type="hidden" name="AttachmentLabel" value="#qAttDetail.Description#">
		    	<input type="hidden" name="AttachmentID" id="AttachmentID" value="#qCarrAtt.attachment_Id#">
		    	<input type="hidden" name="AttachmentFileName" id="AttachmentFileName" value="#qCarrAtt.attachmentFileName#">
		    	<input type="hidden" name="ExpiredAttachmentFileName" id="ExpiredAttachmentFileName" value="<cfif len(trim(qAttDetail.RenewalDate)) AND len(trim(qCarrAtt.UploadedDateTime)) AND dateCompare(qAttDetail.RenewalDate, qCarrAtt.UploadedDateTime) EQ 1>#qCarrAtt.attachmentFileName#</cfif>">
		    	<input type="file" name="file" id="file">
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
	</form>
</cfoutput>