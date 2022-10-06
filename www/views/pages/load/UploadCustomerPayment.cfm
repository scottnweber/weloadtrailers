<cfparam name="form.LoadText" default="">
<cfif structKeyExists(form, "Upload")>
	<cfinvoke component ="#variables.objLoadGatewayNew#" method="ProcessCustomerPaymentData" frmStruct="#form#" returnvariable="request.qLoadData"/>
</cfif>
<cfoutput>
	<style type="text/css">
		 .DragAndDrop::-webkit-input-placeholder { /* Chrome/Opera/Safari */
            font-size: 50px;
            font-weight: normal;
            color:##cecece;
            text-align: center;
            padding-top: 4%;
        }
		.DragAndDrop{
			border: solid 1px ##cecece;
			padding-top: 35px;
			width: 100%;
			height: 300px;
			padding-left: 10px;
			font-weight: bold;
		}
		.normal-td{
            padding: 0;
            background-color: ##fff;
        }
        .HeaderSelect{
        	width: 100%;
    		background: url(../images/head-bg.gif) left top repeat-x;
    		cursor: pointer;
        }
        .overlay {
            display: none;
            z-index: 2;
            background: ##000;
            position: fixed;
            text-align: center;
            opacity: 0.3;
            overflow: hidden;
             width: 100%;
            height: 100%;
            top: 0;
            right: 0;
            bottom: 0;
            left: 0;
        }
	    .white-con-area{
	    	width: 100%;
	    }
	    .white-mid{
	    	width: 100%;
	    }
	    ##frmImport{
	    	margin-left: -23px;
	    	width: 939px;
	    }
	    ##loadernew{
			position: fixed;
			top:40%;
			left:40%;
			z-index: 999;
			display: none;
			width: 200px;
		}
		##loadingmsgnew{
			font-weight: bold;
			text-align: center;
			margin-top: 1px;
			background-color: ##fff;
			padding-bottom: 2px;
			padding-bottom: 2px;
		}
		##loader{
            position: fixed;
            top:40%;
            left:40%;
            z-index: 999;
            display: none;
        }
        ##loadingmsg{
            font-weight: bold;
            text-align: center;
            margin-top: 1px;
            background-color: ##fff;
        }
	</style>
	<script>
		async function getClipboardContents() {
		  	try {
			  	console.log(navigator)
			    const text = await navigator.clipboard.readText();
			    $('##LoadText').val(text);
		  	} catch (err) {
		    	console.error('Failed to read clipboard contents: ', err);
		  	}
		}

		function validateFrmTxt(){
			var LoadText = $('##LoadText').val();
			if(!$.trim(LoadText).length){
				alert('Please enter Text.');
				return false;
			}
		}

		function validateFrm() {
			if(!$.trim($('##StatusTypeID').val()).length){
				alert("Please select status.")
				$('##StatusTypeID').focus();
				return false;
			}

			var ArrLoadNumber= [];
			$(".LoadNumber").each(function()
            {
                ArrLoadNumber.push($.trim($(this).val()));
            })
			if(confirm('Are you ready to import?')){
				recUpdatePayment(ArrLoadNumber,ArrLoadNumber.length,0);
			}
			return false;
		}

		function recUpdatePayment(ArrLoadNumber,Total,Index){
			if(Index<Total){
				$('.overlay').show();
				var StatusTypeID = $('##StatusTypeID').val();
				var rowIndx = Index+1;
				var PmtRef = $('##PmtRef_'+rowIndx).val();
				var PmtDate = $('##PmtDate_'+rowIndx).val();
				var PmtAmount = $('##PmtAmount_'+rowIndx).val();
				var AppliedAmt = $('##AppliedAmt_'+rowIndx).val();

				$.ajax({
                    type    : 'POST',
                    url     : "ajax.cfm?event=ajxUpdateCustomerPayment&#session.URLToken#",
                    data    : {LoadNumber:ArrLoadNumber[Index],StatusTypeID:StatusTypeID,PmtRef:PmtRef,PmtDate:PmtDate,PmtAmount:PmtAmount,AppliedAmt:AppliedAmt},
                    success :function(data){
                        recUpdatePayment(ArrLoadNumber,Total,Index+1);
                    },
                    beforeSend: function() {
		               	$('##loadingmsgnew').html('Updating '+rowIndx+' of '+Total+', Load## '+ArrLoadNumber[Index]);
		               	$('##loadernew').show();
		            },
                })
				
			}
			else{
				$('.overlay').hide();
				$('##loadernew').hide();
				setTimeout(function(){ 
					alert('Loads have been marked as paid by customer.');
					location.href="index.cfm?event=UploadCustomerPayment&#session.URLToken#";
				}, 500);
			}
		}

		$( document ).ready(function() {
			<cfif structKeyExists(request, "qLoadData")>
				var elmnt = document.getElementById("LoadsTable");
	   			elmnt.scrollIntoView();
   			</cfif>

   			$("##uploadCSV").change(function(){
                var files = $('##uploadCSV')[0].files[0];
                var extension = files.name.substr( (files.name.lastIndexOf('.') +1) );
                if(extension.toUpperCase()=='CSV'){
                	var fd = new FormData();
                	var files = $('##uploadCSV')[0].files[0];
	                fd.append('file',files);
	                uploadData(fd);
                }else{
                	alert("Invalid file format. Please upload csv.");
                	return false;
                }
            });
		})

		function uploadData(formdata){
            $.ajax({
                url: 'ajax.cfm?event=ajxCustomerPaymentCsv&#session.URLToken#',
                type: 'post',
                data: formdata,
                contentType: false,
                processData: false,
                dataType: 'json',
                beforeSend: function() {
                   $(".overlay").show();
                   $("##loader").show();
                },
                success: function(response){
                	$("##loader").hide();
                    $(".overlay").hide();
                    if(response.success==0){
						setTimeout(function(){ 
							alert(response.MESSAGE)
						}, 500);
                    }
                    else{
                    	console.log(response.MESSAGE)
                        $('##LoadText').val(response.MESSAGE);
                    }
                }
            });
        }
	</script>
	<cfform name="frmImport" id="frmImport" action="index.cfm?event=UploadCustomerPayment&#session.URLToken#" method="post">
		<div class="white-con-area" style="height: 36px;background-color: ##82bbef;">
			<h1 style="color:white;font-weight:bold;text-align: center;">Update Loads as "PAID" by Customer</h1>
		</div>
		<div class="white-con-area">
			<div class="white-top"></div>
			<div class="white-mid">
				<div style="padding: 10px 20px 20px 20px;">
					<div style="float: left;width: 75%;">
						<input type="button" class="bttn" value="PASTE TEXT" onclick="getClipboardContents()" style="width: 100px !important;"> 
						<b style="margin-left: 10px;text-decoration: underline;">OR</b>
						<input type="button" name="uploadCsvTriggr" value="UPLOAD CSV FILE..." style="margin-left: 10px;" onclick="document.getElementById('uploadCSV').click();">
						<input type="file" name="uploadCSV" id="uploadCSV" style="display: none;">
						<a style="text-decoration: underline;margin-left: 10px;" href="../../../LoadManagerAdmin/Sample Customer Loads Paid.csv" download="">CLICK HERE TO DOWNLOAD A SAMPLE FILE.</a>
					</div>
					
					<div class="clear"></div>
					<div style="margin-top: 10px;">
						<textarea name="LoadText" id="LoadText" class="DragAndDrop" placeholder="DRAG & DROP&##13;&##10;LOAD NUMBERS&##13;&##10;HERE">#form.LoadText#</textarea>
					</div>
				</div>
			</div>
		</div>
		<div class="white-con-area" style="height: 36px;background-color: ##82bbef;">
			<div style="float: right;margin-right: 5px;margin-top: 3px;">
				<input type="submit" class="bttn" value="Preview" name="Upload" id="Upload" style="width: 75px !important;" onclick="return validateFrmTxt()">
			</div>
		</div>
		<cfif structKeyExists(request, "qLoadData")>
			<input type='hidden' name="totalcount" value="#request.qLoadData.recordcount#">
			<div class="white-con-area">
				<div class="white-top"></div>
				<div class="white-mid">
					<div style="padding: 10px 20px 20px 20px;">
						<div style="border: solid 1px ##cecece;margin-top: 10px;padding:10px;">
							<div class="clear" style="height: 10px;"></div>
							<div style="overflow-x: scroll;width: 875px;">
								<table id="LoadsTable" width="100%" border="0" class="data-table" cellspacing="0" cellpadding="0">
							        <thead>
							            <tr>
							                <th align="center" valign="middle" class="head-bg" style="border-left: 1px solid ##5d8cc9;border-top-left-radius: 5px;height: 20px;">Load Number</th>
							                <th align="center" valign="middle" class="head-bg">Pmt Ref</th>
							                <th align="center" valign="middle" class="head-bg">Pmt Date</th>
							                <th align="center" valign="middle" class="head-bg">Pmt Amount</th>
							                <th align="center" valign="middle" class="head-bg" style="border-top-right-radius: 5px;">Applied Amt</th>
							            </tr>
							        </thead>
							        <tbody>
							        	<cfloop query="request.qLoadData">
									    	<tr>
			                    				<td align="left" valign="middle" nowrap="nowrap" class="normal-td" style="border-left: 1px solid ##5d8cc9;">
			                    					<input type="text" class="LoadNumber" name="LoadNumber_#request.qLoadData.currentrow#" id="LoadNumber_#request.qLoadData.currentrow#" value="#request.qLoadData.LoadNumber#" style="text-align: right;">
			                    				</td>
			                    				<td align="left" valign="middle" nowrap="nowrap" class="normal-td">
			                    					<input type="text" name="PmtRef_#request.qLoadData.currentrow#" id="PmtRef_#request.qLoadData.currentrow#" value="#request.qLoadData.PmtRef#">
			                    				</td>
			                    				<td align="left" valign="middle" nowrap="nowrap" class="normal-td">
			                    					<input type="text" name="PmtDate_#request.qLoadData.currentrow#" id="PmtDate_#request.qLoadData.currentrow#" value="#request.qLoadData.PmtDate#" style="text-align: right;">
			                    				</td>
			                    				<td align="left" valign="middle" nowrap="nowrap" class="normal-td">
			                    					<input type="text" name="PmtAmount_#request.qLoadData.currentrow#" id="PmtAmount_#request.qLoadData.currentrow#" value="#request.qLoadData.PmtAmount#" style="text-align: right;">
			                    				</td>
			                    				<td align="left" valign="middle" nowrap="nowrap" class="normal-td">
			                    					<input type="text" name="AppliedAmt_#request.qLoadData.currentrow#" id="AppliedAmt_#request.qLoadData.currentrow#" value="#request.qLoadData.AppliedAmt#" style="text-align: right;">
			                    				</td>
									    	</tr>
									    </cfloop>
								    </tbody>
							    </table>

							</div>
						</div>
					</div>
				</div>
			</div>
			<div class="clear"></div>
			<div class="white-con-area" style="height: 55px;background-color: ##82bbef;">
				<div style="float: right;margin-right: 5px;margin-top: 3px;">
					<div style="background-color: #request.qsystemoptions.BackgroundColorForContent#;float: left;margin-top: 4px;height: 22px;padding-left: 5px;margin-right: 10px;">
						<label>Update Loads to this Status*</label>
						<select name="StatusTypeID" id="StatusTypeID">
							<option value="">Select</option>
							<cfloop query="request.qLoadStatus">
								<option value="#request.qLoadStatus.value#" <cfif structKeyExists(cookie, "CustomerPaidLoadStatus") AND cookie.CustomerPaidLoadStatus EQ request.qLoadStatus.value> selected </cfif>>#request.qLoadStatus.StatusDescription#</option>
							</cfloop>
						</select>
					</div>
					<input type="submit" class="bttn" name="Import" id="Import" value="UPDATE LOADS" style="width: 65px !important;height: 40px;background-size: contain;white-space: normal;" onclick="return validateFrm();">
				</div>
			</div>
		</cfif>
		<div class="overlay"></div>
		<div id="loadernew">
			<img src="images/loadDelLoader.gif" style="width:200px">
			<p id="loadingmsgnew"></p>
		</div>
		<div id="loader">
	        <img src="images/loadDelLoader.gif">
	        <p id="loadingmsg">Please wait.</p>
	    </div>
	</cfform>
</cfoutput>