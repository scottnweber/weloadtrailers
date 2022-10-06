<cfoutput>
	<script>
        function closeWin() {
			window.close();
        }
        function openUploader(){
        	$('##file').click();
        }
        $(document).ready(function(){
        	$("##file").change(function(){
        		$('.overlay').show();
        		$('##frmSubManually').submit();
        	})
        	$('##subMan').click(function(){
        		$('.overlay').show();
        	})
        })
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
	<div class="row pb-10" style="background-color: ##defaf9;">
		<div class="col-xs-12 col-lg-12 pl-0 pr-0">
			<h2 class="col-xs-12 col-lg-12 blueBg">SUBMIT MANUALLY</h2>
		</div>
		<div class="col-xs-12 col-lg-12" style="font-size: 14px;">
			<form method="post" enctype="multipart/form-data" id="frmSubManually" action="index.cfm?event=FinishOnBoard&CarrierID=#url.CarrierID#&SubmitManually=1">
				Please fill out the agreement, sign it and upload/email it back to us. Thank you.<br><br>
				<a href="javascript:openUploader();">Upload Signed Document</a><br>
				<a id="download" href="#filePath#" download="#url.UploadFileName#">Download Document again</a><br>
				<a id="subMan" href="index.cfm?event=FinishOnBoard&CarrierID=#url.CarrierID#&SubmitManually=2">Email Signed Document(s) Manually</a>
				<input type="file" id="file" name="SignedDoc" style="display: none;">
			</form>
		</div>
	</div>
</cfoutput>