<cfoutput>
	<style>
		.uploadedFile{
			font-size: 16px;
		    background-color: ##82bbef;
		    border: solid 1px;
		    padding: 5px;
		    cursor: pointer;
		    margin-left: 10px;
		    margin-right: 10px;
		    height: 30px;
    		float: left;
    		margin-bottom: 10px;
		}
		.actionBlock{
			margin-top: 20px;
			text-align: center;
		}
		input[value='PREVIOUS'] {
		    width: 90px !important;
		    height: 50px !important;
		    font-size: 14px !important;
		    background-size: contain !important;
		    float: left !important;
		}
		input[value='NEXT'], input[value='FINISH'] {
		    width: 60px !important;
		    height: 50px !important;
		    font-size: 14px !important;
		    background-size: contain !important;
		    color: ##599700 !important;
		    float: right !important;
		}
		.stepLabel{
			float: none;
			font-weight: bold;
		}
		##timestamp{
			padding: 5px;
		    background-color: ##e3e3e3;
		    border: 1px solid ##b3b3b3;
		    <cfif NOT len(trim(request.qDocs.VerifiedDate[url.CurrIndex]))>display: none;</cfif>
		}
		.prevAct,.nextAct{
			width: 30%;
			float: left;
		}
		.stepAct{
			width: 40%;
			float: left;
			padding-top: 15px;
		}
	</style>
	<script type="text/javascript">
		function openPopup(url) {	
			newwindow1=window.open(url,'subWindow', 'resizable=1,height=500,width=500');	
			if(!$.trim(url).length){
				newwindow1.document.write('File not found.');
			}
			
			return false;
		}

		function clock(){
			var currentDate = new Date();
	        var currentDay = currentDate.getDate();
	        var currentMonth = currentDate.getMonth() + 1;
	        var currentYear = currentDate.getFullYear();
	        var hours = currentDate.getHours();
	        var minutes = currentDate.getMinutes();
	        var currentDate = currentMonth + "/" + currentDay + "/" + currentYear;
	        var ampm = hours >= 12 ? 'PM' : 'AM';
	        hours = hours % 12;
	        hours = hours ? hours : 12; // the hour '0' should be '12'
	        minutes = minutes < 10 ? '0'+minutes : minutes;
	        var strTime = hours + ':' + minutes + ' ' + ampm;
	        var FinalTime = currentDate+' '+strTime;
			return FinalTime
		}	

		function verifyDocument(ckbx){
			var ckd = $(ckbx).is(":checked");
			$('##timestamp').html('').hide();
			$('##verifiedDate').val('');
			$('##verifiedBy').val('');
			if(ckd){
				var loginid = '#session.adminUserName#';
				$('##timestamp').html(loginid+' '+clock()).show();
				$('##verifiedDate').val(new Date());
				$('##verifiedBy').val('#session.adminusername#');
			}
			
		}
	</script>
	<cfquery name="qrygetSettingsForDropBox" datasource="#application.dsn#">
		SELECT 
			DropBox,
			DropBoxAccessToken
		FROM SystemConfig WHERE CompanyID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#session.CompanyID#" >
	</cfquery>
	<cfquery name="qrygetCommonDropBox" datasource="LoadManagerAdmin">
		SELECT 
		<cfif len(trim(qrygetSettingsForDropBox.DropBoxAccessToken))>
			'#qrygetSettingsForDropBox.DropBoxAccessToken#'
		<cfelse>
			DropBoxAccessToken 
		</cfif>
		AS DropBoxAccessToken
		FROM SystemSetup
	</cfquery>

	<cfhttp method="POST" url="https://api.dropboxapi.com/2/sharing/create_shared_link"	result="returnStruct"> 
		<cfhttpparam type="HEADER" name="Authorization" value="Bearer #qrygetCommonDropBox.DropBoxAccessToken#">
		<cfhttpparam type="HEADER" name="Content-Type" value="application/json">	
		<cfhttpparam type="body" value='{"path":#SerializeJSON('/fileupload/img/#session.usercompanycode#/' & request.qDocs.attachmentFileName[url.CurrIndex])#}'>
	</cfhttp> 
	<cfset FileUrl = "">
	<cfif returnStruct.Statuscode EQ "200 OK">
		<cfset FileUrl = deserializeJSON(returnStruct.fileContent).url.Split('\?')[1] & '?raw=1'>
	</cfif>	
	<h1>#request.qDocs.CarrierName#</h1>

	<cfform id="DocVerificationForm" name="DocVerificationForm" action="index.cfm?event=verifyCarrierOnBoardDoc:process&#session.URLToken#" method="post" preserveData="yes">
		<input type="hidden" name="AttachmentID" value="#request.qDocs.attachment_Id[url.CurrIndex]#">
		<input type="hidden" name="CurrIndex" value="#url.CurrIndex#">
		<input type="hidden" name="CarrierID" value="#url.CarrierID#">
		<input type="hidden" name="verifiedBy" id="verifiedBy" value="#request.qDocs.verifiedBy[url.CurrIndex]#">
		<input type="hidden" name="verifiedDate" id="verifiedDate" value="#request.qDocs.verifiedDate[url.CurrIndex]#">
		<div class="white-con-area" style="width:999px">
            <div class="white-mid" style="width:999px">
            	<div class="form-con" style="width:500px;padding:0;background-color: #request.qGetSystemSetupOptions.BackgroundColorForContent# !important;">
            		<div style="height: 36px;background-color: ##82bbef;margin-bottom: 5px;float: right;">
                        <h2 style="color:white;font-weight:bold;padding-top: 10px;width:490px;text-align: left;">#request.qDocs.attachedFileLabel[url.CurrIndex]#</h2>
                    </div>
                    <div class="clear"></div>
                    <div class="uploadedFile" onclick="openPopup('#FileUrl#')">
                    	<img src="images/icon_folder.png" style="float: left;">
                    	<span style="float: left;margin-top: 5px;">#replaceNoCase(request.qDocs.attachmentFileName[url.CurrIndex], "_#url.carrierid#", "")#</span><br>
                    	<span style="font-size: 10px;">(Click to view the file.)</span>
                    </div>
                    <div class="clear"></div>
                    <fieldset>
                    	<label>Verify Document</label>
                    	<input name="verifyDoc" type="checkbox" class="small_chk" style="float: left;" onclick="verifyDocument(this)" <cfif len(trim(request.qDocs.VerifiedDate[url.CurrIndex]))> checked </cfif>>
                    	<span id="timestamp">#request.qDocs.Verifiedby[url.CurrIndex]# #dateTimeFormat(request.qDocs.VerifiedDate[url.CurrIndex],'mm/dd/yyyy hh:nn tt')#</span>
                    	<div class="clear"></div>
                    	<div class="actionBlock">
                    		<div class="prevAct">
                    			<cfif url.CurrIndex NEQ 1>
		                    		<input class="bttn" id="previous-btn" type="button" name="back" value="PREVIOUS" onclick="document.location.href='index.cfm?event=verifyCarrierOnBoardDoc&CurrIndex=#(url.CurrIndex-1)#&CarrierID=#url.CarrierID#&#Session.URLToken#'">
		                    	<cfelse>
		                    		&nbsp;
		                    	</cfif>
                    		</div>
                    		<div class="stepAct">
                    			STEP #url.CurrIndex# OF #request.qDocs.recordcount#
                    		</div>
                    		<div class="nextAct">
                    			<input class="bttn" id="next-btn" type="submit" name="submit" value="<cfif url.CurrIndex NEQ request.qDocs.recordcount>NEXT<cfelse>FINISH</cfif>">
                    		</div>
                    	</div>
                    </fieldset>
                    
            	</div>
            </div>
        </div>
	</cfform>
</cfoutput>