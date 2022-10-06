<cfoutput>
	<style type="text/css">
		.reportsSubHeading{
			border-bottom: 1px solid ##95cac885 !important;
			margin-bottom: 16px !important;
			padding-left:0px !important;
		}
		.overlay{
		    position: fixed;
		    background-color: ##000000;
		    width: 100%;
		    height: 100%;
		    z-index: 99;
		    top: 0;
		    left: 0;
		    opacity: 0.5;
		    display: none;
		}
		##loader{
			position: fixed;
			top:40%;
			left:30%;
			z-index: 999;
			display: none;
			background-color: ##fff;
		}
		##loadingmsg{
			font-weight: bold;
			text-align: left;
			margin-top: 1px;
			background-color: ##fff;
			padding-left: 5px;
			padding-bottom: 5px;
		}
		.doneMsg{
			display: none;
			color: green;
		}
	</style>
	<div class="white-con-area" style="height: 36px;background-color: ##82bbef;">
		<div style="float: left;"><h2 style="color:white;font-weight:bold;margin-left: 12px;">FORM 1099</h2></div>
	</div>
	<div style="clear:left"></div>
	<style>
		.white-mid div.form-con fieldset.TolExp{
			border: 1px dashed ##a9d6ff;
		    padding: 36px 25px;
		    margin-bottom: 13px;
		}
		.reportsSubHeading.expoCustmr{
			padding: 0px 0 6px 0px !important;
			border-bottom: 1px solid ##95cac885 !important;
    		margin-bottom: 14px !important;
		}
	</style>
	<div class="white-con-area">
		<div class="white-top"></div>
		<div class="white-mid">
			<div class="form-con">
				<cfform name="frm1099" action="" method="post">
					<a id="download" href="" download style="display: none">Download</a>
					<fieldset style="padding-bottom: 10px;">
						<label class="space_it" style="width: 150px;">Select Calendar Year</label>
						<div style="position:relative;float:left;">
							<div style="float:left;">
								<cfset sYr = year(now())>
								<cfset eYr = sYr-5>
								<select name="year" id="year" style="width: 138px">
									<cfloop from="#sYr#" to="#eYr#" index="yr" step="-1">
										<option value="#yr#" <cfif yr EQ sYr-1> selected</cfif>>#yr#</option>
									</cfloop>
								</select>
							</div>
						</div>
						<div class="clear"></div> 
						<label class="space_it" style="width: 150px;">COPY A (IRS)</label>
						<input type="checkbox" name="copyA" value="" id="copyA" checked style="width: 16px;"/>
						<div class="clear"></div> 
						<label class="space_it" style="width: 150px;">COPY 1 (State)</label>
						<input type="checkbox" name="copy1" value="" id="copy1" checked style="width: 16px;"/>
						<div class="clear"></div> 
						<label class="space_it" style="width: 150px;">COPY B (Recipient IRS) & COPY 2 (Recipient State)</label>
						<input type="checkbox" name="copyB2" value="" id="copyB2" checked style="width: 16px;"/>
						<div class="clear"></div> 
						<label class="space_it" style="width: 150px;">COPY C (Payer)</label>
						<input type="checkbox" name="copyC" value="" id="copyC" style="width: 16px;"/>
						<div class="clear"></div> 
						<div style="margin-left: 133px;">
							<input id="submit" type="button" name="submit" class="bttn tooltip" value="Submit" style="width:95px;"/>
							
						</div>
					</fieldset>
				</cfform>
				<cfform name="frm1099Export" id="frm1099Export" action="index.cfm?event=Export1099&#session.URLToken#" method="post">
					<fieldset>
						<div style="margin-left: 133px;">
							<input type="hidden" name="exportYear" id="exportYear" value="#year(now())-1#">
							<input id="export" type="submit" name="export" class="bttn tooltip" value="Export" style="width:95px;"/>
						</div>
					</fieldset>
				</cfform>
			</div>
			
			<div class="clear"></div>
		</div>
		<div class="white-bot"></div>
	</div>
	<div class="overlay">
	</div>
	<div id="loader">
		<img src="images/loadDelLoader.gif">
		<img src="images/loadDelLoader.gif">
		<img src="images/loadDelLoader.gif">
		<p id="loadingmsg"></p>
	</div>
	<script type="text/javascript">
		
		function ajaxRecursiveGenerateCopy(yr,arrCopy,index){
			if(arrCopy.length && index<arrCopy.length){
				var copy = arrCopy[index];
				
				var path = urlComponentPath+"loadgateway.cfc?method=getForm1099Path";

				$.ajax({
                	type: "get",
		            url: path,
		            data:{
		            	year:yr,copy:copy,CompanyID:'#session.CompanyID#',dsn:'#application.dsn#'
		            },
		            success: function(file){
		            	var folderPath = jQuery.parseJSON(file).folderPath;
		            	var fileName = jQuery.parseJSON(file).fileName;
		            	var path1 = urlComponentPath+"loadgateway.cfc?method=getGenerateForm1099";
			            
		            	$.ajax({
		                	type: "get",
				            url: path1,
				            data: {
                            	year:yr,folderPath:folderPath,fileName:fileName,CompanyID:'#session.companyid#',copy:copy
                        	},
				            success: function(data){
				            	$("##download").attr("href", '../fileupload/form1099/'+folderPath+'/'+fileName);
				            	document.getElementById('download').click();
				            	$('##'+copy+'_Done').show();
								ajaxRecursiveGenerateCopy(yr,arrCopy,index+1);
				            },
	
						    error: function(){
						        var interval1 = setInterval(function(){ 
						        	var checkPath = urlComponentPath+"loadgateway.cfc?method=getForm1099Ready";
						        	$.ajax({
					                	type: "get",
							            url: checkPath,
							            data: {
			                            	folderPath:folderPath,fileName:fileName
			                        	},
							            success: function(result){
							            	if(result == 'true'){
							            		clearInterval(interval1);
								            	$("##download").attr("href", '../fileupload/form1099/'+folderPath+'/'+fileName);
								            	document.getElementById('download').click();
								            	$('##'+copy+'_Done').show();
								            	ajaxRecursiveGenerateCopy(yr,arrCopy,index+1);
							            	}
							            }
							        })

						        }, 10000);
						    },
						    timeout:10000
		              	});
		            },
		            beforeSend: function() {
				        $('.overlay').show()
				        $('##loader').show();
						var txtIndx = index + 1;
						var copyTxt = '';
						var msgTxt = $('##loadingmsg').html();
						if(index!=0){
							msgTxt = msgTxt + '<br>';
						}
						if(copy == 'CopyA'){
							copyTxt = 'COPY A (IRS)';
						}
						if(copy == 'Copy1'){
							copyTxt = 'COPY 1 (State)';
						}
						if(copy == 'CopyB-Copy2'){
							copyTxt = 'COPY B (Recipient IRS) & COPY 2 (Recipient State)';
						}
						if(copy == 'CopyC'){
							copyTxt = 'COPY C (Payer)';
						}
				        $('##loadingmsg').html(msgTxt+'Generating 1099 '+txtIndx+' of '+arrCopy.length+','+copyTxt+'...'+'<span class="doneMsg" id="'+copy+'_Done">Done.</span>');
				        $('##loadingmsg').show();
				    },
              	});
			}
			else{
				$('.overlay').hide();
            	$('##loader').hide();
            	$('##loadingmsg').html('');
            	$('##loadingmsg').hide();
			}
		}

		$(document).ready(function(){

			$('##year').change(function(){
				$('##exportYear').val($(this).val());
			})

			$('##submit').click(function(){
				var yr = $('##year').val();
				var arrCopy = new Array();

				if($("##copyA").is(':checked')){
			 		arrCopy.push("CopyA");
			 	}

			 	if($("##copy1").is(':checked')){
			 		arrCopy.push("Copy1");
			 	}

			 	if($("##copyB2").is(':checked')){
			 		arrCopy.push("CopyB-Copy2");
			 	}

			 	if($("##copyC").is(':checked')){
			 		arrCopy.push("CopyC");
			 	}

			 	ajaxRecursiveGenerateCopy(yr,arrCopy,0);
			 	/*$.each( arrCopy, function( i, copy ) {

					var path = urlComponentPath+"loadgateway.cfc?method=getForm1099Path";
	                $.ajax({
	                	type: "get",
			            url: path,
			            data:{
			            	year:yr,copy:copy,CompanyID:'#session.CompanyID#',dsn:'#application.dsn#'
			            },
			            success: function(file){
			            	var folderPath = jQuery.parseJSON(file).folderPath;
			            	var fileName = jQuery.parseJSON(file).fileName;

			            	//var path1 = urlComponentPath+"loadgateway.cfc?method=getGenerateForm1099";
			            
			            	/*$.ajax({
			                	type: "get",
					            url: path1,
					            data: {
	                            	year:yr,folderPath:folderPath,fileName:fileName,CompanyID:'#session.companyid#',copy:copy
	                        	},
					            success: function(data){
					            	$('.overlay').hide();
					            	$('##loader').hide();
					            	$('##loadingmsg').hide();
					            	$("##download").attr("href", '../fileupload/form1099/'+folderPath+'/'+fileName);

					            	document.getElementById('download').click();
					            },
		
							    error: function(){
							        var interval1 = setInterval(function(){ 
							        	var checkPath = urlComponentPath+"loadgateway.cfc?method=getForm1099Ready";
							        	$.ajax({
						                	type: "get",
								            url: checkPath,
								            data: {
				                            	folderPath:folderPath,fileName:fileName
				                        	},
								            success: function(result){
								            	if(result == 'true'){
								            		clearInterval(interval1);
								            		$('.overlay').hide();
									            	$('##loader').hide();
									            	$('##loadingmsg').hide();
									            	$("##download").attr("href", '../fileupload/form1099/'+folderPath+'/'+fileName);
									            	document.getElementById('download').click();
								            	}
								            }
								        })

							        }, 10000);
							    },
							    timeout:10000
			              	});
			              
			            },
			            beforeSend: function() {
					        $('.overlay').show()
					        $('##loader').show();
					        $('##loadingmsg').show();
					    },
	              	});
            	});*/
			})
		})
	</script>
</cfoutput>