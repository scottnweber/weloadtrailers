<!DOCTYPE html>
<html>

<cfquery name="getScanUser" datasource="LoadManagerAdmin">
	select top 1 * from scanapi where companyname='#url.dsn#'
</cfquery>

<head>
    <title>Scanner Demo</title>
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.3.1/jquery.min.js"></script>
    <script>
		
		$(document).ready(function () {
			var scannerurl = '<cfoutput>#getScanUser.url#</cfoutput>'+'/ScannerList';
			var scandocuments = '<cfoutput>#getScanUser.url#</cfoutput>'+'/ScanDocument';
            $.ajax({
                method: "GET", url: scannerurl, success: function (result) {
                    console.log(result);
                    $.each(result, function (data, value) {
                        $("#ddlScannerList").append($("<option></option>").val(value).html(value));
                    });
                }
            });
            $("#btnScanDocument").click(function () {
                var selectImage = $("#ddlimgFormat").val();
                var selectedScanner = $("#ddlScannerList").val();
				var fileDesc = $("#fileDesc").val();
				var Lid = '<cfoutput>#url.id#</cfoutput>';
				var Upuser = '<cfoutput>#url.user#</cfoutput>';
				var billing = 0;
				
				if($("#billing").is(':checked')){
					billing = 1;
				}
				
                if ((selectImage != "") && (selectedScanner != "")) {
                    $("#proccessStatus").html("Processing please wait.....");
                    $.ajax({
                        method: "GET", url: scandocuments, data:{"selectedScanner":selectedScanner, "imageFormat":selectImage,"returnAsBase64":true}, success: function (result) {
                            if (result.HasError) {
                                $("#proccessStatus").html("Completed");
                                alert(result.Message);
                            }
                            else {
                               
								if (selectImage == 'pdf')
									var contentType = 'application/pdf';
								else
									var contentType = 'image/png';
								var b64Data = $.trim(result.Data);
								
								setTimeout(function(){
								
									var blob = b64toBlob(b64Data, contentType);
									var formData = new FormData();
										formData.append('picture', blob);
										formData.append('Loadid', Lid);
										formData.append('Description', fileDesc);
										formData.append('Billing', billing);
										formData.append('ImageFormat', selectImage);
										formData.append('UserUploaded', Upuser);
									$.ajax({
										url: "../gateways/loadgateway.cfc?method=UploadScannedImages", 
										type: "POST", 
										cache: false,
										contentType: false,
										processData: false,
										data: formData})
											.done(function(e){
												$("#proccessStatus").html("Document Uploaded successfully.");
												setTimeout(function(){ $("#proccessStatus").html("");; }, 3000);
									});
									}
								, 2000);
								
								
                            }
                        }
                    });
                }
                else {
                    alert("please select scanner or image format");
                }
            });

		});
		
		function b64toBlob(b64Data, contentType, sliceSize) {
		  contentType = contentType || '';
		  sliceSize = sliceSize || 512;

		  var byteCharacters = atob(b64Data);
		  var byteArrays = [];

		  for (var offset = 0; offset < byteCharacters.length; offset += sliceSize) {
			var slice = byteCharacters.slice(offset, offset + sliceSize);

			var byteNumbers = new Array(slice.length);
			for (var i = 0; i < slice.length; i++) {
			  byteNumbers[i] = slice.charCodeAt(i);
			}

			var byteArray = new Uint8Array(byteNumbers);

			byteArrays.push(byteArray);
		  }

		  var blob = new Blob(byteArrays, {type: contentType});
		  return blob;
		}
    </script>
	<style>
		.labeldiv{
			width:20%;
			float:left;
			margin-top: 10px;
		}
		.inputdiv{
			width:80%;
			float:left;
			margin-top: 10px;
		}
		#btnScanDocument{
			margin-top: 10px;
			margin-left: 20%;
		}
	</style>
</head>
<body>
		
    <div id="div1"><h2>Scan Files</h2></div>
	
	<div> 
		<div class="labeldiv">Select Scanner</div>
		<div class="inputdiv"><select id="ddlScannerList"></select></div>
	</div>
	
	<div> 
		<div class="labeldiv">Scan Format</div>
		<div class="inputdiv">
			<select id="ddlimgFormat">
                <option value="png">png</option>
                <option value="jpeg">Jpeg</option>
				<option value="pdf">PDF</option>
            </select>
		</div>
	</div>
     
	<div> 
		<div class="labeldiv">Description</div>
		<div class="inputdiv">
			<input type="text" id="fileDesc" name="fileDesc">
		</div>
	</div>
 
	<div> 
		<div class="labeldiv">Billing</div>
		<div class="inputdiv">
			<input type="checkbox" name="billing" id="billing">
		</div>
	</div>
    
	<div class="actionDiv">
		<button id="btnScanDocument">Scan Doument</button>
	</div>
	<br/>
	<div id="proccessStatus"></div>
    
</body>
</html>