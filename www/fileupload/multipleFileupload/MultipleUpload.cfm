<cfparam name="url.userFullName" default="">
<!DOCTYPE html><html dir="ltr" lang="en-US">
	<head>
		<meta charset="UTF-8" />
		<!-- Plupload Rules -->
		<title>Plupload: UI Widget</title>
		<meta name="msvalidate.01" content="CF6A500C2AC11792DD10D5D7A77C685D" />
		<link href="/favicon.ico" rel="shortcut icon" />
		<link type="text/css" rel="stylesheet" href="../css/bootstrap.css" media="screen" />
		<link type="text/css" rel="stylesheet" href="../css/font-awesome.min.css" media="screen" />
		<link type="text/css" rel="stylesheet" href="../css/my.css" media="screen" />
		<link type="text/css" rel="stylesheet" href="../css/prettify.css" media="screen" />
		<link type="text/css" rel="stylesheet" href="../css/shCore.css" media="screen" />
		<link type="text/css" rel="stylesheet" href="../css/shCoreEclipse.css" media="screen" />
		<link type="text/css" rel="stylesheet" href="https://ajax.googleapis.com/ajax/libs/jqueryui/1.10.2/themes/smoothness/jquery-ui.min.css" media="screen" />
		<link type="text/css" rel="stylesheet" href="../css/jquery.ui.plupload.css" media="screen" />
		<link href="../../webroot/styles/style.css" rel="stylesheet" type="text/css" />
		<!--[if lte IE 7]>
		<link rel="stylesheet" type="text/css" href="http://www.plupload.com/css/my_ie_lte7.css" />
		<![endif]-->
		<link href="https://fonts.googleapis.com/css?family=Open+Sans:300italic,400italic,600italic,700italic,400,600,700,300|Bree+Serif" rel="stylesheet" type="text/css">
		<!--[if IE]>
		<link href="http://fonts.googleapis.com/css?family=Open+Sans" rel="stylesheet" type="text/css">
		<link href="http://fonts.googleapis.com/css?family=Open+Sans:300italic" rel="stylesheet" type="text/css">
		<link href="http://fonts.googleapis.com/css?family=Open+Sans:400italic" rel="stylesheet" type="text/css">
		<link href="http://fonts.googleapis.com/css?family=Open+Sans:600italic" rel="stylesheet" type="text/css">
		<link href="http://fonts.googleapis.com/css?family=Open+Sans:700italic" rel="stylesheet" type="text/css">
		<link href="http://fonts.googleapis.com/css?family=Open+Sans:300" rel="stylesheet" type="text/css">
		<link href="http://fonts.googleapis.com/css?family=Open+Sans:400" rel="stylesheet" type="text/css">
		<link href="http://fonts.googleapis.com/css?family=Open+Sans:600" rel="stylesheet" type="text/css">
		<link href="http://fonts.googleapis.com/css?family=Bree+Serif:400" rel="stylesheet" type="text/css">
		<![endif]-->
		<!--[if IE 7]>
			<link rel="stylesheet" href="http://www.plupload.com/css/font-awesome-ie7.min.css">
		<![endif]-->
		<!--[if lt IE 9]>
		<script src="http://www.plupload.com/js/html5shiv.js"></script>
		<![endif]-->
		<script type="text/javascript" src="https://ajax.googleapis.com/ajax/libs/jquery/1/jquery.js" charset="UTF-8"></script>
		<script language="javascript" type="text/javascript" src="../scripts/jquery.form.js"></script>	
		<style type="text/css">
		    .plupload_button.plupload_start
		    {
		         display:none;
		    }
		</style>
	</head>
	<body >			
		<cfoutput>
			<cfif structkeyExists(url,"id") and url.id eq 'systemsetup'>
					<cfset fileLimit ='2mb'>
					<cfset fileLimitText = 'File size should be less than 2MB!'>
				<cfelse>
					<cfset fileLimit = '10mb'>
					<cfset fileLimitText = 'File size should be less than 10MB!'>
			</cfif>
			<cfif structkeyExists(url,"dsn")>
				<cfset url.dsn = listGetAt(url.dsn, 1)>
			<!--- Decrypt String --->
			<cfset TheKey = 'NAMASKARAM'>					
			<cfset dsn = Decrypt(ToString(ToBinary(url.dsn)), TheKey)>
			<cfelse>
				<cfdump var="Invalid Request"><cfabort>
			</cfif>
			<cfparam name="url.attachtype" default="">
			<cfparam name="url.freightBroker" default="">
			<cfparam name="user" default="">
			<cfparam name="url.attachtype" default="">
				<cfif structkeyexists(url,user)>
					<cfset user="#url.user#">
				<cfelseif structkeyexists(form,user)>
					<cfset user="#form.user#">	
				</cfif>
				<cfparam name="newFlag" default="0">
				<cfif structkeyexists(url,newFlag)>
					<cfset newFlag="#url.newFlag#">
				<cfelseif structkeyexists(form,newFlag)>
					<cfset newFlag="#form.newFlag#">	
				</cfif>
				<!--- Begin : DropBox Integration  ---->
				<cfquery name="qrygetSettingsForDropBox" datasource="#dsn#">
					SELECT 
						DropBox,
						DropBoxAccessToken
					FROM SystemConfig WHERE CompanyID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#url.CompanyID#" >
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
				<cfif structKeyExists(url, "attachtype")>
					<cfquery name="qGetAttachmentTypes" datasource="#dsn#">
						SELECT AttachmentTypeID,Description FROM FileAttachmentTypes WHERE 
						AttachmentType = '#url.attachtype#'
						AND CompanyID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#url.CompanyID#" >
					</cfquery>
				</cfif>
				<cfquery name="qGetCompany" datasource="#dsn#">
					SELECT 
						CompanyCode
					FROM Companies WHERE CompanyID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#url.CompanyID#" >
				</cfquery>
				<!--- End : DropBox Integration  ---->
			<div class="container">
				<div class="clearfix"> </div>
				<div id="example">
					<div id="uploader" style="margin: 46px 46px 46px 56px;">
					</div>
					<script type="text/javascript">
					// Initialize the widget when the DOM is ready
					$(function() {
						var counter=1;
						var filename="";					
						$("##uploader").plupload({
							// General settings
							runtimes : 'html5,flash,silverlight,html4',
							url : "../com/cfheadshotuploader.cfc?method=Upload&qqfile='newfile'&flag=#newFlag#&dsn=#URLEncodedFormat(url.dsn)#&id=#url.id#&attachTo=#url.attachTo#&user=#user#&companyID=#url.companyID#&userFullName=#url.UserFullName#",

							// Rename files by clicking on their titles
							rename: true,
							
							// Sort files
							sortable: true,

							// Enable ability to drag'n'drop files onto the widget (currently only HTML5 supports that)
							dragdrop: true,

							// Views to activate
							views: {
								list: true,
								thumbs: true, // Show thumbs
								active: 'thumbs'
							},

							// Flash settings
							flash_swf_url : '../js/Moxie.swf',
						
							// Silverlight settings
							silverlight_xap_url : '../js/Moxie.xap',
							init: {
								FilesAdded: function (up, files) {
									if(up.files.length){
										for(i=0;i<up.files.length;i++){
											if(up.files[i].name.indexOf(":") != -1){
											    alert('File Name cannot contain any of the following characters:\n\/:*?"<>|');
											    up.removeFile(files[i]);
											    return false;
											}
											if(up.files[i].name.indexOf(".") == -1){
												alert('File without extension are not allowed.');
											    up.removeFile(files[i]);
											    return false;
											}
											if (typeof up.files[i].size == 'undefined') {
												alert('Invalid file size.');
											    up.removeFile(files[i]);
											    return false;
											}
										}
									}
									up.start();
								},
								Browse: function(up) {
					                <cfif structkeyExists(url,"id") and url.id eq 'systemsetup'>
										if($("##fileAttachment ##DocType").val() =="0")
										{
											alert('Please select Document Type');
											return false;
										}
									</cfif>
					            },
								UploadComplete: function (up, files) {
									// destroy the uploader and init a new one
								
									if(up.files.length){
										for(i=0;i<up.files.length;i++){
												var newRow = '<tr><td style="color:##000000;padding-left:10px;font-size:12px;padding-right:90px;">'+counter+'. Enter File Description </td><td><input type="hidden" name="file_'+counter+'" value="'+up.files[i].name+'"><input type="hidden" name="fileType_'+counter+'" value="'+$("##fileAttachment ##DocType").val()+'">'
					newRow += '<b>File Description for:</b> '+up.files[i].name+'<input type="text" name="filename_'+counter+'"></td></tr>';
					var nextLineRow='<tr><td></td><td ><input onclick="chkBillingDocument(\'billingDocument'+counter+'\',\''+up.files[i].name+'\')" type="checkbox" name="billingDocument'+counter+'" id="billingDocument'+counter+'" style="margin-top: -2px;"/> <b style="margin-right: 10px;">Billing Document</b><input type="checkbox" name="driverDocument'+counter+'" id="driverDocument'+counter+'" style="margin-top: -2px;"/> <b>Driver Document</b></td></tr>'
					$("table##detail").append(newRow);
					$("table##detail").append(nextLineRow);
					<cfif structKeyExists(url, "attachtype") AND qGetAttachmentTypes.recordcount>
						var attachtypeRow = '<tr><td align="right" style="color:##000000;padding-left:10px;font-size:12px;padding-right:10px;"><b>Attachment Type:</b></td><td ><cfloop query="qGetAttachmentTypes"><input type="checkbox" name="AttachmentType'+counter+'" id="AttachmentType'+counter+'_#qGetAttachmentTypes.currentrow#"  value="#qGetAttachmentTypes.AttachmentTypeID#" style="margin-top: -2px;"/> <b style="margin-right: 10px;">#qGetAttachmentTypes.Description#</b></cfloop></td></tr>';
						$("table##detail").append(attachtypeRow);
					</cfif>
												newRow='';
												counter++;
										}
										var newRow1='<tr><td style="color:##000000;padding-left:10px;font-size:12px;padding-right:90px;">'+counter+'. Update File</td><td><input type="submit" name="Attach" value="Update" style="width:150px !important;"></td></tr>';
										$("table##detail").append(newRow1);
										$("##newload").show();
										$("##step").show();
										$("##counter").val(up.files.length);
									}
								
								},
								  FileUploaded: function(up, file, info) {
									var response = $.parseJSON(info.response);
									if(response.success == false){
										up.removeFile(file);
										alert('Unable to upload the file ' + file.name + '. Please try again later.');
										return false;
									}
									if(filename == ""){
										filename=response.FILENAME;									
									}else{
										filename=filename +'/'+ response.FILENAME;
									}
									var newRow2='<tr><td><input type="hidden" name="fileNamesServer" value="'+filename+'"></td></tr>';
									var count=filename.split('/');
									if(up.files.length == count.length){
										$("table##detail").append(newRow2);
									}

									var opener = window.opener;
									if(opener) {
									    var elem = opener.$(".attText");
									    if (elem) {
									        $(elem).html('View/Attach Files');
									    }
									    var dispNote = opener.$("##dispatchNotes");
									    if (dispNote) {
									        $(dispNote).prepend(clock()+' - '+ opener.$('##Loggedin_Person').val()+ " >" +' File attached > '+filename+'\n');
									    }
									}
								  },
							},
							preinit: {
										BeforeUpload: function (up) {
										   <cfif structkeyExists(url,"id") and url.id eq 'systemsetup'>
											if($("##fileAttachment ##DocType").val() =="0")
											{
												alert('Please select Document Type');
												return false;
											}
											</cfif>
										}
									},
			
						});

						$('.fileLabel').click(function() {
							var txt = $(this).html();
							var id = $(this).attr('id').split("_")[1];
							$(this).hide();
  							$('##text_'+id).val(txt).show().focus();
						});

						$('.fileLabel-td').click(function() {
							var spn_txt = $(this).find( ".fileLabel" ).html();
							var id = $(this).find( ".fileLabel" ).attr('id').split("_")[1];
							if(!$.trim(spn_txt).length){
								$('##text_'+id).val('').show().focus();
							}
						});
						
						$('.fileText').blur(function() {
						  var txt = $(this).val();
						  var attrid = $(this).attr('id');
						  var id = $(this).attr('id').split("_")[1];
						  $.ajax({
								type : 'POST',
								url:"../com/cfheadshotuploader.cfc?method=UpdateLabel",
								data:{
									attachid:id,
									label:txt,
									dsn:'#dsn#'
								},
								success:function(data){
									$('##'+attrid).hide();
						  			$('##label_'+id).html(txt).show();
								},
								error:function(error){
									$('##'+attrid).hide();
						  			$('##label_'+id).html(txt).show();
								}
							});
						  
						});
						
					});
					
					function chkBillingDocument(id,file){
						<cfif structkeyexists(url,'ConsolidateInvoices') AND url.ConsolidateInvoices EQ 1>
							if($('##'+id).is(':checked')){
								var extension = file.substr( (file.lastIndexOf('.') +1) );
								if(extension.toUpperCase() !='PDF' && extension.toUpperCase() !='JPG' && extension.toUpperCase() !='JPEG' && extension.toUpperCase() !='GIF' && extension.toUpperCase() !='PNG'){
									alert('This file format is not supported for Consolidated Invoicing, please only attach billing documents in PDF, JPG/JPEG, GIF or PNG formats.');
									$('##'+id). prop("checked", false);
								}
							}
						</cfif>
					}
					function updateDriverDocument(id,ele,file){
						var dsnvalue='#dsn#';
						if($(ele).prop("checked") == true){
							chechedStatus=1;
						}
						else if($(ele).prop("checked") == false){
							chechedStatus=0;
						}
						$.ajax({
							type : 'POST',
							url:"../com/cfheadshotuploader.cfc?method=updateDriverDocument&companyID=#url.companyID#",
							data:{
								attachid:id,
								checkedStatus:chechedStatus,
								dsn:dsnvalue
							},
							success:function(data){},
							error:function(error){}
						});
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

					function verifyDocument(id,ele){
						var dsnvalue='#dsn#';
						if($(ele).prop("checked") == true){
							var VerifiedBy = '#url.user#';
							var VerifiedDate = new Date();
							$('##timestamp_'+id).html(VerifiedBy+' '+clock());
						}
						else if($(ele).prop("checked") == false){
							var VerifiedBy = '';
							var VerifiedDate = '';
							$('##timestamp_'+id).html('');
						}
						$.ajax({
							type : 'POST',
							url  : "../../webroot/ajax.cfm?event=ajxVerifyDocument&#session.URLToken#",
							data:{
								AttachmentID:id,
								VerifiedBy:VerifiedBy,
								VerifiedDate:VerifiedDate,
								CarrierID:'#url.id#'
							},
							success:function(data){
								var elem = window.opener.$("[name='Status']");
								elem.val(data);
								if(data==0){
									elem.addClass('disAllowStatusEdit');
								}
								else{
									elem.removeClass('disAllowStatusEdit');
								}
							},
							error:function(error){}
						});
					}
					function updateBillingDocument(id,ele,file){
						var chechedStatus=0;
						var dsnvalue='#dsn#';
						var ckBillDocument = 1;
						if($(ele).prop("checked") == true){
							chechedStatus=1;
						}
						else if($(ele).prop("checked") == false){
							chechedStatus=0;
						}

						<cfif structkeyexists(url,'ConsolidateInvoices') AND url.ConsolidateInvoices EQ 1>
							if(chechedStatus == 1){
								var extension = file.substr( (file.lastIndexOf('.') +1) );
								if(extension.toUpperCase() !='PDF' && extension.toUpperCase() !='JPG' && extension.toUpperCase() !='JPEG' && extension.toUpperCase() !='GIF' && extension.toUpperCase() !='PNG'){
									alert('This file format is not supported for Consolidated Invoicing, please only attach billing documents in PDF, JPG/JPEG, GIF or PNG formats.');
									$(ele). prop("checked", false);
									ckBillDocument=0;
								}	
							}
						</cfif>
						if(ckBillDocument==1){
							$.ajax({
								type : 'POST',
								url:"../com/cfheadshotuploader.cfc?method=UpdateBillingDocument&flag=#newFlag#&companyID=#url.companyID#",
								data:{
									attachid:id,
									checkedStatus:chechedStatus,
									dsn:dsnvalue
								},
								success:function(data){
									var jsondata=$.parseJSON(data);
									var attachid=jsondata.attachid;
									var checkedStatus=jsondata.checkedStatus;
									
								},
								error:function(error){
									
								}
							});
						}
					}

				</script>
				</div>
			</div>
		
		<script type="text/javascript" src="../js/bootstrap.js" charset="UTF-8"></script>
		<script type="text/javascript" src="../js/shCore.js" charset="UTF-8"></script>
		<script type="text/javascript" src="../js/shBrushPhp.js" charset="UTF-8"></script>
		<script type="text/javascript" src="../js/shBrushjScript.js" charset="UTF-8"></script>
		<script type="text/javascript" src="https://ajax.googleapis.com/ajax/libs/jqueryui/1.10.2/jquery-ui.min.js" charset="UTF-8"></script>
		<script type="text/javascript" src="../js/plupload.full.min.js" charset="UTF-8"></script>
		<script type="text/javascript" src="../js/jquery.ui.plupload.min.js?#dateFormat(now())#" charset="UTF-8"></script>
		<script type="text/javascript" src="../js/themeswitcher.js" charset="UTF-8"></script>
		<script language="javascript">	
			var percentInt = 0;
			var progress;
			var bar;
			var percent;
			var counter=0;
		
			
			function passFieldDiv(form,id,elemtype){
				$('##alert-'+elemtype+'-'+form+'-'+id).remove();
				$('##'+form+' ##'+id).removeClass('alertbox');
			}	

			function removeFile(){
				$("##divNewFile").html('<input type="file" name="newfile" id="newfile" size="27" />');
				$("##chooseFile").show();
			}

			function popitup(filename,newFlag) {
				newwindow1=window.open('../showAttachment.cfm?companycode=#qGetCompany.companycode#&file='+filename+'&newFlag='+newFlag,'subWindow', 'resizable=1,height=500,width=500');
				return false;
			}
			/* Begin : DropBox Integration*/
			function popupFiles(url,newFlag) {	
				newwindow1=window.open(url,'subWindow', 'resizable=1,height=500,width=500');	
				if(!$.trim(url).length){
					newwindow1.document.write('File not found.');
				}
				
				return false;
			}
			/* End : DropBox Integration*/
			function DeleteFile(fileId,fileName,newFlag)
			{
				var deleteYN=false;
				deleteYN = confirm('Are you sure to delete this file');
				if (deleteYN)
					{	
									$.ajax({url:"../../gateways/loadgateway.cfc?method=deleteAttachments",
									data:{fileId:fileId,
										  fileName:fileName,
										  dsnName:'#dsn#',
										  newFlag:newFlag,
										  CompanyID:'#url.CompanyID#'
										},
									success:function(response)
									{
									  if(response)
									  {
									   //need to add code to update the div content of the opener window
									   <cfif structKeyExists(url, "attachtype") AND url.attachtype EQ "Load">
									   		$.ajax({
					                            url     : "../../gateways/loadgateway.cfc?method=GetAttachmentCount",
					                            data:{loadid:'#url.id#',
													  dsnName:'#dsn#',
													  CompanyID:'#url.CompanyID#'
													},
					                            success :function(res){  
					                            	if(res == 0){
					                            		var opener = window.opener;
														if(opener) {
														    var elem = opener.$(".attText");
														    if (elem) {
														        $(elem).html('Attach Files');
														    }
														}
					                            	}
					                                alert("File Deleted.");
										   			location.reload();
					                            }
					                        });
									   <cfelse>
										   alert("File Deleted.");
										   location.reload();
									   </cfif>
									  }
															  else
															  {
									   alert("There was an error deleting");
									  }
									},
									error:function(response)
									{
									  alert("There was an error deleting");
									}
									});			
					}
				
			}	
			$(function(){
				$('##newfile').change(function(){
					var f = this.files[0];
					var fileSize = parseFloat(f.size)-9210;
					<cfif structkeyExists(url,"id") and url.id eq 'systemsetup'>
						<cfset variables.fileLimitCheck=2097152>
					<cfelse>
							<cfset variables.fileLimitCheck=10485760>
					</cfif>
					if(fileSize >= #variables.fileLimitCheck#){			
						alert('#fileLimitText#');
						$('##newfile').attr({ value: '' }); 
					}
				});
			});		
		</script>
		
		<cfif structKeyExists(form,"counter") and form.counter gt 0 and  structKeyExists(form,"fileNamesServer")>  
			<cfset counter=1>
			<cfloop list="#form.fileNamesServer#" index="i" delimiters="/">
				<cfif structKeyExists(form,"billingDocument#counter#")>
					<cfset variables.billingDocument=1>
				<cfelse>
					<cfset variables.billingDocument=0>
				</cfif>
				
				<cfif structKeyExists(form,"AttachmentType#counter#")>
					<cfset variables.AttachmentType=evaluate("form.AttachmentType#counter#")>
				<cfelse>
					<cfset variables.AttachmentType="">
				</cfif>

				<cfif structKeyExists(form,"driverDocument#counter#")>
					<cfset variables.driverDocument=1>
				<cfelse>
					<cfset variables.driverDocument=0>
				</cfif>
				<cfif newFlag eq 0>
					<cfset tablename = "FileAttachments">
					<cfset isTempTable = "">
				<cfelse>
					<cfset tablename = "FileAttachmentsTemp">
					<cfset isTempTable = "">
				</cfif>
				<cfif structKeyExists(form,"filename_#counter#")>
					<cfquery name="insertFilesUploaded" datasource="#dsn#" result="insertedId">
						update #tablename# set 
						attachedFileLabel = '#replaceNoCase(evaluate("form.filename_"&counter), "'", "''",'ALL')#',
						<cfif structkeyExists(url,"id") and url.id eq 'systemsetup'>
						DocType = '#evaluate("form.fileType_"&counter)#',
						</cfif>
						Billingattachments = <cfqueryparam cfsqltype="cf_sql_bit" value="#variables.billingDocument#" >
						,DriverDocument = <cfqueryparam cfsqltype="cf_sql_bit" value="#variables.DriverDocument#" >
						where attachmentFileName = <cfqueryparam cfsqltype="cf_sql_varchar" value="#i#" >			
					</cfquery>
					<cfif len(trim(variables.AttachmentType))>
						<cfloop list="#variables.AttachmentType#" index="attID">
							<cfquery name="qInsertAttachmentTypes" datasource="#dsn#">
								INSERT INTO MultipleFileAttachmentsTypes 
								VALUES(newid(),
									(SELECT attachment_Id FROM #tablename# WHERE attachmentFileName = <cfqueryparam cfsqltype="cf_sql_varchar" value="#i#" >	),
									<cfqueryparam cfsqltype="cf_sql_varchar" value="#attID#" >	)
							</cfquery>
						</cfloop>
					</cfif>
				</cfif>
				<cfset counter++>
			</cfloop>
			<script language="javascript">
				//need to add code to update the div content of the opener window
				alert("File(s) updated");<!--- linked to the #url.attachtype#--->
				opener.focus();
				window.close();
				
			</script>
			
		<cfelse>
				<cfif newFlag eq 0>
					<CFQUERY NAME="filesLinked" DATASOURCE="#dsn#">
						SELECT FA.*,FAT.Description AS AttachmentTypeDes
						FROM FileAttachments FA 
						LEFT JOIN MultipleFileAttachmentsTypes MFA ON  FA.attachment_Id = MFA.AttachmentID
						LEFT JOIN FileAttachmentTypes FAT ON FAT.AttachmentTypeID = MFA.AttachmentTypeID
						where FA.linked_Id='#id#' and FA.linked_to='#attachTo#'
							<cfif id eq 'systemsetup'>
								and FA.CompanyID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#url.CompanyID#" >
							</cfif>
						ORDER BY FA.attachment_Id
					</CFQUERY>
				<cfelse>
					<CFQUERY NAME="filesLinked" DATASOURCE="#dsn#">
						SELECT FA.*,FAT.Description AS AttachmentTypeDes
						FROM FileAttachmentsTemp FA 
						LEFT JOIN MultipleFileAttachmentsTypes MFA ON  FA.attachment_Id = MFA.AttachmentID
						LEFT JOIN FileAttachmentTypes FAT ON FAT.AttachmentTypeID = MFA.AttachmentTypeID
						where FA.linked_Id='#id#' and FA.linked_to='#attachTo#'
							<cfif id eq 'systemsetup'>
								and FA.CompanyID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#url.CompanyID#" >
							</cfif>
						ORDER BY FA.attachment_Id
					</CFQUERY>
				</cfif>	
				
			<cfif filesLinked.recordcount>
			<b>Click on the file label to edit the label.</b>
			<div>
				<table style="width:100%; font-weight:bold; font-size:9px;"  border="0" cellspacing="0" cellpadding="0" class="data-table">
					  <thead>
						  <tr>
							<th width="40px" align="center" valign="middle" class="head-bg"><p align="center">File Label</p></th>
							<th width="40px" align="center" valign="middle" class="head-bg"><p align="center">File Name</p></th>
							<th width="40px" align="center" valign="middle" class="head-bg"><p align="center">Uploaded On</p></th>
							<cfif structKeyExists(url, "attachtype") AND url.attachtype EQ 'Carrier'>
								<th width="40px" align="center" valign="middle" class="head-bg"><p align="center">Verified By</p></th>
							</cfif>
							<th width="40px" align="center" valign="middle" class="head-bg"><p align="center">View</p></th>
							<th width="40px" align="center" valign="middle" class="head-bg"><p align="center">Billing Doc</p></th>
							<th width="40px" align="center" valign="middle" class="head-bg"><p align="center">Driver Doc</p></th>
							<cfif structKeyExists(url, "attachtype") AND listFind("Customer,Carrier,Driver,Load", url.attachtype)>
								<th width="40px" align="center" valign="middle" class="head-bg"><p align="center">Type</p></th>
							</cfif>
							<cfif not structKeyExists(url, 'viewonly')>
								<th width="40px" align="center" valign="middle" class="head-bg"><p align="center">Delete</p></th>
							</cfif>
						</tr>
					</thead>
				 <tbody>
					<cfloop query="filesLinked" group="attachment_Id">
						<cfset currrow = 0>
						<!--- Encrypt String --->
						<cfset Secret = filesLinked.attachment_Id>
						<cfset TheKey = 'NAMASKARAM'>
						<cfset Encrypted = Encrypt(Secret, TheKey)>
						<cfset fileId = URLEncodedFormat(ToBase64(Encrypted))>
						<!--- Begin : DropBox Integration ---->
						<!--- v2 --->
						<cfhttp
								method="POST"
								url="https://api.dropboxapi.com/2/sharing/create_shared_link"	
								result="returnStruct"> 
										<cfhttpparam type="HEADER" name="Authorization" value="Bearer #qrygetCommonDropBox.DropBoxAccessToken#">	
										<cfhttpparam type="HEADER" name="Content-Type" value="application/json">	
										<cfhttpparam type="body" value='{"path":#SerializeJSON('/fileupload/img/#qGetCompany.CompanyCode#/' & filesLinked.attachmentFileName)#}'>
						</cfhttp> 

						<cfset FileUrl = "">
						<cfif returnStruct.Statuscode EQ "200 OK">
							<cfset FileUrl = deserializeJSON(returnStruct.fileContent).url.Split('\?')[1] & '?raw=1'>
						</cfif>	
						<cfif structkeyexists(url,"dump")>
							<CFDUMP VAR="#returnStruct#">
						</cfif>
										
						<!--- End : DropBox Integration  ---->
					 <tr  onmouseover="this.style.background = '##FFFFFF';"  <cfif filesLinked.currentrow mod 2 eq 0>bgcolor="##FFFFFF"<cfelse>bgcolor="##f7f7f7"</cfif>>
						 <td width="40px" align="center" valign="middle" nowrap="nowrap" class="normal-td fileLabel-td"><span class="fileLabel"  id="label_#filesLinked.attachment_id#">#filesLinked.attachedFileLabel#</span>
						 <input type="text" class="fileText" style="display: none;height: 10px;width:70px;margin-top: 5px;" id="text_#filesLinked.attachment_id#">
						 </td>
						 <td width="40px" align="center" valign="middle" nowrap="nowrap" class="normal-td">#filesLinked.attachmentFileName#</td>
						 <td width="40px" align="center" valign="middle" nowrap="nowrap" class="normal-td">#filesLinked.UploadedDateTime#</td>
						<cfif structKeyExists(url, "attachtype") AND url.attachtype EQ 'Carrier'>
							<td width="40px" align="left" valign="middle" nowrap="nowrap" class="normal-td">
							<input type="checkbox" name="verifyDoc_#filesLinked.attachment_Id#" id="verifyDoc_#filesLinked.attachment_Id#" onclick="verifyDocument(#filesLinked.attachment_Id#,this)"<cfif len(trim(filesLinked.VerifiedBy))> checked</cfif> style="margin-top: -3px;"> 
							<span id="timestamp_#filesLinked.attachment_Id#">#filesLinked.VerifiedBy# #dateTimeFormat(filesLinked.VerifiedDate,'mm/dd/yyyy hh:nn tt')#</span>
							</td>
						</cfif>
							<td width="40px" align="center" valign="middle" nowrap="nowrap" class="normal-td">
							<cfif  filesLinked.DropBoxFile EQ 1 >
								<a href="javascript:void(0);" onclick="popupFiles('#FileUrl#',<cfif structkeyexists(url,"newFlag")>#newFlag#<cfelse>0</cfif>)" title="View"><img src="../../webroot/images/icon_view.png" alt="view" /></a>
							<cfelse>
								<a href="javascript:void(0);" onclick="popitup('#fileId#',<cfif structkeyexists(url,"newFlag")>#newFlag#<cfelse>0</cfif>)" title="View"><img src="../../webroot/images/icon_view.png" alt="view" /></a>
							</cfif>
							<!---  End : DropBox Integration ---->							
							</td>
							<td width="40px" align="center" valign="middle" nowrap="nowrap" class="normal-td">
								<form action="" method="POST"  name="Billingattachments" id="Billingattachments">	
									<input type="checkbox" name="billingAttachments_#filesLinked.attachment_Id#" id="billingAttachments_#filesLinked.attachment_Id#" onclick="updateBillingDocument(#filesLinked.attachment_Id#,this,'#filesLinked.attachmentFileName#')"<cfif filesLinked.Billingattachments eq 1> checked <cfelse> </cfif> style="margin-top: -3px;"> 
								</form>
							</td>
							<td width="40px" align="center" valign="middle" nowrap="nowrap" class="normal-td">
								<form action="" method="POST"  name="Driverattachments" id="Driverattachments">	
									<input type="checkbox" name="DriverAttachments_#filesLinked.attachment_Id#" id="DriverAttachments_#filesLinked.attachment_Id#" onclick="updateDriverDocument(#filesLinked.attachment_Id#,this,'#filesLinked.attachmentFileName#')"<cfif filesLinked.DriverDocument eq 1> checked <cfelse> </cfif> style="margin-top: -3px;"> 
								</form>
							</td>
							<cfif structKeyExists(url, "attachtype") AND listFind("Customer,Carrier,Driver,Load", url.attachtype)>
								<td width="40px" align="center" valign="middle" nowrap="nowrap" class="normal-td">
									<cfloop  group="AttachmentTypeDes"><cfif currrow NEQ 0>, </cfif>#filesLinked.AttachmentTypeDes#<cfset currrow++></cfloop>
								</td>
							</cfif>
							<cfif not structKeyExists(url, 'viewonly')>
								<td width="40px" align="center" valign="middle" nowrap="nowrap" class="normal-td">
									<a href="javascript:void(0);" onclick="DeleteFile('#fileslinked.attachment_Id#','#filesLinked.attachmentFileName#',<cfif structkeyexists(url,"newFlag")>#newFlag#<cfelse>0</cfif>)" title="Delete"><img src="../../webroot/images/icon_delete.png" alt="delete" /></a>
								</td>
							</cfif>
					 </tr>
					</cfloop>
				 </tbody>
				</table>
				</div>
				</cfif>
			</cfif>	
			<cfif not structkeyexists(url,"notShowUpload")>
			<table align="left">
				<tr>
					<td>
			<div style="color:##000000;padding-left:5px;font-size:14px;font-weight:bold;margin-top:20px;<cfif structkeyExists(url,"id") and url.id neq 'systemsetup'>display:none;</cfif>" id="step">Steps</div>
			<div id="upload">	

				<form action='MultipleUpload.cfm?dsn=#URLEncodedFormat(url.dsn)#&id=#url.id#&CompanyId=#url.CompanyID#' method="POST"  name="fileAttachment" id="fileAttachment" enctype="multipart/form-data">	
					<table align="left" width="100%">
						<tr <cfif structkeyExists(url,"id") and url.id eq 'systemsetup'> height="40"</cfif>>
							<td colspan="3">
								<table width="100%">							
									<cfif structkeyExists(url,"id") and url.id eq 'systemsetup'>
										<tr>
											<td style="color:##000000;padding-left:10px;font-size:12px;padding-right:5px;">
												Select The Document Type
											</td>
											<td>
												<span id="chooseFile">
													<div id="selectDocType">
														<select name="DocType" id="DocType">
															<option value="0">-- Select --</option> 
															<option value="Other">Other</option>
															<option value="Agent">User</option>
															<option value="Customer">Customer</option>
															<cfif structKeyExists(url, 'freightBroker') AND url.freightBroker EQ 'Carrier/Driver'>
																<option value="Carrier">Carrier</option>
																<option value="Driver">Driver</option>
															<cfelse>
																<option value="#url.freightBroker#">#url.freightBroker#</option>
															</cfif>
														</select>
													</div>
												</span>	
											</td>
											<td>&nbsp;</td>
										</tr>
									</cfif>
								</table>
							</td>
						</tr>					
					</table>
				</form>
			</div>
			<div id="newload" align="left" style="display:none;">
				<form action='MultipleUpload.cfm?dsn=#URLEncodedFormat(url.dsn)#&attachtype=#url.attachtype#&id=#url.id#&attachTo=#url.attachTo#&user=#user#&CompanyId=#url.CompanyID#' method="post">	
						<input type="hidden" name="attachTo" value="#attachTo#">
						<input type="hidden" name="id" value="#id#">
						<input type="hidden" id="counter" name="counter" value="0">
						<input type="hidden" id="user" name="user" value="#user#">
						<input type="hidden" id="newflag" name="newflag" value="#newflag#" >
						
						<table id="detail" align="left">
						</table>
					</form>
			</div>
			
		</td>
		</tr>
		</table>
		<table width="100%" >
			<tr>
				<td align="left">
					<input type="button" name="Close" value="Cancel" onClick="if(confirm('Are you sure you want to cancel?')){window.close();}" style="color: red;">
				</td>
			</tr>
		</table>
		</table>
		</cfif>
		</cfoutput>
	</body>
</html>
