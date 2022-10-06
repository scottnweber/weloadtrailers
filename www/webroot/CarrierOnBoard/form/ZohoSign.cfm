<cfoutput>
	<script type="text/javascript">
		function validateZohoSign(){

			var path = 'ajax.cfm?event=ajxISDocumentSigned&RequestID=#zohoEmbedded.request_id#';
			var IsSigned = $.ajax({
			    type: "GET",
			    url: path,
			    async: false
			}).responseText;  

			if(IsSigned==0){
				alert('Please sign the document to continue.');
				return false;
			}
			
		}

		function downloadManual(){
			if(confirm('Are you sure you want to download & submit manually?')){
				$('.overlay').show();
				document.getElementById('download').click();
				setTimeout(function() {
				    location.href="index.cfm?event=SubmitManually&CarrierID=#url.CarrierID#&UploadFileName=#zohoEmbedded.UploadFileName#";
				}, 1000);
			}
		}
	</script>
	<div class="overlay" style="position: fixed;
	    background-color: ##000000;
	    width: 100%;
	    height: 100%;
	    z-index: 99;
	    top: 0;
	    left: 0;
	    opacity: 0.5;
	    display: none;"></div>
	<div class="row">
		<div class="col-xs-12 col-lg-12">
			<iframe class="col-xs-12 col-lg-12" src="#zohoEmbedded.sign_url#" title="Zoho Sign" id="Iframe" style="height: 100vh;position: relative;"></iframe>
		</div>
		<div class="clearfix"></div>
		<form method="post" id="frmZohoSign" action="index.cfm?event=#ID#_ZohoSign:Process&CarrierID=#url.CarrierID#" onsubmit="return validateZohoSign()">
			<div class="col-xs-12 col-lg-12 text-center mt-10">
				<cfif isDefined("PrevEvent")>
					<input type="hidden" name="PrevEvent" value="#PrevEvent#">
					<cfif qSystemConfig.AllowDownloadAndSubmitManually EQ 1>
						<cfhttp
							method="POST"
							url="https://api.dropboxapi.com/2/files/get_temporary_link"	
							result="returnStruct"> 
							<cfhttpparam type="HEADER" name="Authorization" value="Bearer #qSystemConfig.DropBoxAccessToken#">	
							<cfhttpparam type="HEADER" name="Content-Type" value="application/json">	
							<cfhttpparam type="body" value='{"path":#SerializeJSON('/fileupload/img/#qSystemConfig.CompanyCode#/' & zohoEmbedded.UploadFileName)#}'>
						</cfhttp> 
						<cfset filePath = deserializeJSON(returnStruct.fileContent).link>
						<a id="download" href="#filePath#" download="#zohoEmbedded.UploadFileName#" style="display: none">Download</a>
						<input class="bttn" id="download-btn" type="button" name="back" value="DOWNLOAD & SUBMIT MANUALLY" onclick="downloadManual()">
					<cfelse>
						<input class="bttn" id="previous-btn" type="submit" name="back" value="PREVIOUS">
					</cfif>
				</cfif>
				<label class="stepLabel">STEP #currentStep# OF #TotalStep#</label>
				<cfif isDefined("NextEvent")>
					<input class="bttn" id="next-btn" type="submit" name="submit" value="NEXT">
				</cfif>
			</div>
		</form>
	</div>
</cfoutput>