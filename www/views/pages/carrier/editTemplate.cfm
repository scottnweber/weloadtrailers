<cfset delTempDir = expandPath('../fileupload/carrierdocs/#session.usercompanycode#/')>
<cfif directoryExists(delTempDir)>
	<cfdirectory action="list" directory="#delTempDir#" recurse="false" name="dirList" filter="Temp_*">
	<cfloop query="dirList">
		<cfif dateDiff('h', dirList.DateLastModified, now()) GT 1>
			<cfset DirectoryDelete("#dirList.directory#/#dirList.Name#",true)>
		</cfif>
	</cfloop>
</cfif>

<cfquery name="qGetDoc" datasource="#application.dsn#">
	SELECT UploadFileName,ZohoTemplateID FROM OnboardingDocuments WHERE ID = <cfqueryparam value="#url.ID#" cfsqltype="cf_sql_varchar">
</cfquery>

<cfhttp method="post" url="https://accounts.zoho.com/oauth/v2/token" result="objRespAccessToken">
  <cfhttpparam type="url" name="refresh_token" value="1000.2cea9b0735011dad98cc3479f1734f48.980caac236c9085dfa9bc0aad5ee444a"/>
  <cfhttpparam type="url" name="client_id" value="1000.KW1ZX4LDG0LMC6OC4V3BJZ57Z03AEZ"/>
  <cfhttpparam type="url" name="client_secret" value="df1e7797a0b17ef9cab6a5d827da89a479238734ac"/>
  <cfhttpparam type="url" name="grant_type" value="refresh_token"/>
</cfhttp>

<cfset structRespAccessToken = deserializeJSON(objRespAccessToken.filecontent)>
<cfset auth_token = structRespAccessToken.access_token>
<cfhttp method="get" url="https://sign.zoho.com/api/v1/templates/#qGetDoc.ZohoTemplateID#" result="objRespTemplatesFields">
  <cfhttpparam type="header" name="Authorization" value="Zoho-oauthtoken #auth_token#"/>
</cfhttp>
<cfset structResp = deserializeJSON(objRespTemplatesFields.Filecontent)>
<cfif structResp.status EQ 'failure'>
	<cfoutput>Access to view the document is denied.</cfoutput><cfabort>
</cfif>
<cfset UploadDir = "#expandPath('../fileupload/CarrierDocs/#session.usercompanycode#/')#">

<cfquery name="qrygetCommonDropBox" datasource="#application.dsn#">
  SELECT ISNULL(DropBoxAccessToken,(SELECT DropBoxAccessToken FROM LoadManagerAdmin.dbo.SystemSetup)) AS DropBoxAccessToken FROM SystemConfig WHERE CompanyID = <cfqueryparam value="#session.companyid#" cfsqltype="cf_sql_varchar">
</cfquery>
<cfhttp
	method="POST"
	url="https://api.dropboxapi.com/2/sharing/create_shared_link"	
	result="returnStruct"> 
			<cfhttpparam type="HEADER" name="Authorization" value="Bearer #qrygetCommonDropBox.DropBoxAccessToken#">	
			<cfhttpparam type="HEADER" name="Content-Type" value="application/json">	
			<cfhttpparam type="body" value='{"path":#SerializeJSON('/fileupload/img/#session.usercompanycode#/' & qGetDoc.UploadFileName)#}'>
</cfhttp> 
<cfset filePath = deserializeJSON(returnStruct.fileContent).url.Split('\?')[1] & '?raw=1'>
<cfhttp url="#filePath#" method="get" getAsBinary="yes" path="#UploadDir#" file="#qGetDoc.UploadFileName#"/>

<cfset tempFolder = "Temp_#replaceNoCase(replace(replace(qGetDoc.UploadFileName,"+","","ALL")," ","","ALL"), ".pdf", "")#_#DateTimeFormat(Now(),"YYYYMMDDHHnnssl")#">
<cfset TempDir = "#expandPath('../fileupload/CarrierDocs/#session.usercompanycode#/#tempFolder#/')#">
<cfif not directoryExists(TempDir)>
	<cfdirectory action="create" directory="#TempDir#">
</cfif>
<cfset imagePrefix = replaceNoCase(replace(replace(qGetDoc.UploadFileName,"+","","ALL")," ","","ALL"), ".pdf", "")>
<cfpdf action="thumbnail" source="#UploadDir#\#qGetDoc.UploadFileName#" 
	destination = "#TempDir#" overwrite="yes" resolution= "high" scale ="100" imagePrefix="#imagePrefix#">
<cfinvoke component="#variables.objloadGateway#" method="getLoadSystemSetupOptions" returnvariable="request.qSystemSetupOptions1" />
<cfoutput>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
	<head>
		<meta http-equiv="X-UA-Compatible" content="IE=edge" />
		<meta http-equiv="X-UA-Compatible" content="IE=8" >
		<script src="https://code.jquery.com/jquery-3.6.0.js"></script>
  		<script src="https://code.jquery.com/ui/1.13.1/jquery-ui.js"></script>
  		<!--- <link rel="stylesheet" type="text/css" href="http://code.jquery.com/ui/1.9.2/themes/base/jquery-ui.css"/> --->
		<link href="../webroot/styles/style.css" rel="stylesheet" type="text/css" />
		<title>Load Manager TMS</title>
		<style>
			.pdfcontent{
				float: left;
				max-height: 550px;
				overflow: auto;
				width: 900px;
				padding-left: 20px;
				background-color:white;
			}
			.droppable{
				width: 812.5px;
				height: 1057px;
				border: solid 2px ##ccd5ff;
				margin-top: 10px;
				position: relative;
			}
			.FieldsContent{
				float: left;
				padding-top:10px;
				padding-left: 2%;
				width: 300px;
			}
			.selector-box{
				width: 120px;
			    float: left;
			    border: solid 1px ##82bbef;
			    margin-top: 10px;
			    cursor: all-scroll;
			    font-size: 12px;
			    margin-right: 20px;
				background-color:white;

			}
			.selector-type:before {
				float: left;
			    content: "\2263";
			    color: ##82bbef;
			    width: 20px;
			    text-align: center;
			    font-size: 14px;
			}
			.selector-type:after{
				float: right;
			    background-color: ##82bbef;
			    color: ##fff;
			    width: 20px;
			    text-align: center;
			    font-size: 14px;
			}
			
			##Textfield:after{
				content: "\0054";	
			}
			##Signature:after{
				content: "\270E";	
			}
			##Initial:after{
				content: "\2110";	
			}
			##Company:after{
				content: "\00A9";	
			}
			##Name:after{
				content: "\0046";	
			}
			##Checkbox:after{
				content: "\2611";	
			}
			##CityStateZip:after{
				content: "\205D";	
			}
			##Radio:after{
				content: "\25C9";	
			}
			.text_drag{
				font-family: arial;
				padding:2px 0 0 2px;
				height: 15px;
				border: dotted 2px ##82bbef;
				float: left;

			}
			.dragField{
 				position:absolute;
 				float:left;
 			}
			.dragField:before{
				content: "\2263";
				cursor: all-scroll;
				float: left;
				color:##fff;
				background-color: ##82bbef;
				width: 15px;
    			text-align: center;
			}
			.text_drag{overflow:hidden;}
			.text_drag:focus{
				outline: none !important;
				border: solid 2px ##82bbef;
			}
			.overlay{
	            position: fixed;
	            width: 100%;
	            height: 100%;
	            top: 0;
	            background-color: ##000;
	            opacity: 0.5;
	            z-index: 1;
	            display: none;
	            left: 0;
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
	        ##Date:after,##CustomDate:after{
				content: "\229E";	
			}
			##Address:after{
				content: "\0041";
			}
			##City:after{
				content: "\0043";
			}
			##State:after{
				content: "\0053";
			}
			##Zip:after{
				content: "\005A";
			}
			##Dot:after{
				content: "\0044";
			}
			##MC:after{
				content: "\004D";
			}
			##TaxID:after{
				content: "\0192";
			}
			##Email:after{
				content: "\2709";
			}
			##Contact:after{
				content: "\260A";
			}
			##Phone:after{
				content: "\260E";
			}
			##Fax:after{
				content: "\25A4";
			}
			.fieldaction{
				height: 250px;
			}
			.actions{
				display: none;
			}
			.delIcon{
				cursor: pointer;
				height: 10px;
    			margin-left: 2px;
			}
			##selectedField{
				display: none;
			}
			##RadGroupName{
				background: ##FFFFFF;
	    	border: 1px solid ##b3b3b3;
	    	padding: 2px 2px 0 2px;
	    	height: 18px;
	    	font-size: 11px;
			}
		</style>
		<script type="text/javascript">
			$(document).ready(function(){
				<cfset i = 1>;
				<cfloop array="#structResp.templates.actions[1].fields#" item="field">
					<cfif field.field_type_name EQ 'Radiogroup'>
						<cfloop array="#field.sub_fields#" item="subfield">
							var id = "page_#field.page_no#_#field.field_type_name#_#i#";
							var mtop = '#subfield.y_value#%';
							var mleft = '#subfield.x_value#%';
							var field_name = '#subfield.sub_field_name#';
							var is_mandatory = '#field.is_mandatory#';
							var fieldhtml = '<div class="dragField" id="drag_'+id+'" style="top:'+mtop+';left:'+mleft+';">';
							fieldhtml+='<input data-zohoid="#field.field_id#" value="'+field_name+'" type="radio" class="text_drag" id="'+id+'" name="'+id+'" data-mandatory="'+is_mandatory+'" data-grpname="#field.field_name#">';
							fieldhtml+='<img onclick="deleteField(this)" id="del_'+id+'" class="delIcon" src="../webroot/images/delete-icon.gif"></div>';
							$('##droppable#field.page_no#').append(fieldhtml);
				  		$(".dragField").draggable({});
						</cfloop>
					<cfelse> 
						var id = "page_#field.page_no#_#field.field_type_name#_#i#";
						var mtop = '#field.y_value#%';
						var mleft = '#field.x_value#%';
						var field_name = '#field.field_name#';
						var is_mandatory = '#field.is_mandatory#';
						var w = '#field.width#';
						w = (w/100)*812.5;
						var fieldhtml = '<div class="dragField" id="drag_'+id+'" style="top:'+mtop+';left:'+mleft+';">';
						<cfif field.field_type_name EQ 'Checkbox'>
							fieldhtml+='<input data-zohoid="#field.field_id#" value="'+field_name+'" type="checkbox" class="text_drag" id="'+id+'" name="'+id+'" data-mandatory="'+is_mandatory+'">';
						<cfelse>
							fieldhtml+='<textarea data-zohoid="#field.field_id#" placeholder="Enter field name." class="text_drag" id="'+id+'" name="'+id+'" style="width:'+w+'px" data-mandatory="'+is_mandatory+'">'+field_name+'</textarea>';
						</cfif>
						fieldhtml+='<img onclick="deleteField(this)" id="del_'+id+'" class="delIcon" src="../webroot/images/delete-icon.gif"></div>';
						$('##droppable#field.page_no#').append(fieldhtml);
			  		$(".dragField").draggable({});
		  		</cfif>
					<cfset i++>
				</cfloop>
				$(".draggable").draggable({
				    helper: 'clone',
				});

				$( ".droppable" ).droppable({
				  	drop: function( event, ui ) {
	 					var eleDragged = ui.draggable[0];
				  		var pagepos = $(this).position();
				 		var uipos = ui.position;
				 		var mtop = uipos.top-pagepos.top;
				 		var mleft = uipos.left-pagepos.left;
						var pageNo = $(this).attr('id').replace("droppable", "");
				 		if($(eleDragged).hasClass('selector-box')){
				 			var fieldType = $(eleDragged).find('.selector-type').attr('id');
				 			if(fieldType=='Checkbox' || fieldType=='Radio'){
				 				var NewCount = parseInt($("input[id*='_"+fieldType+"_']").length)+1;
				 			}
				 			else{
				 				var NewCount = parseInt($("textarea[id*='_"+fieldType+"_']").length)+1;
				 			}
				 			var id = "page_"+pageNo+"_"+fieldType+"_"+NewCount;
				 			var field_name = $(eleDragged).find('.selector-type').html();
				 			if(NewCount != 1){
				 				field_name = field_name + '-' + NewCount;
				 			}
				 			var fieldhtml = '<div class="dragField" id="drag_'+id+'" style="top:'+mtop+'px;left:'+mleft+'px;">';
				 			if(fieldType=='Checkbox'){
				 				fieldhtml+='<input data-zohoid="" value="'+field_name+'" type="checkbox" class="text_drag" id="'+id+'" name="'+id+'" data-mandatory="NO">';
				 			}
				 			else if(fieldType=='Radio'){
				 				fieldhtml+='<input data-zohoid="" value="'+field_name+'" type="radio" class="text_drag" id="'+id+'" name="'+id+'"data-mandatory="NO" data-grpname="RadioGroup">';
				 			}
				 			else{
				 				fieldhtml+='<textarea data-zohoid="" placeholder="Enter field name." class="text_drag" id="'+id+'" name="'+id+'" data-mandatory="NO">'+field_name+'</textarea>';
				 			}
				 			fieldhtml+='<img onclick="deleteField(this)" id="del_'+id+'" class="delIcon" src="../webroot/images/delete-icon.gif"></div>';
				  			$(this).append(fieldhtml);
				  			$(".dragField").draggable({});
				  			$('##'+id).focus();
				  			$('.text_drag ').click(function(){
									var name = $(this).val();
									var mandatory = $(this).attr('data-mandatory');
									var val = $(this).attr('id');
									var type = $(this).attr('type');
									$('.reqCk').val(val);
									if(mandatory=="YES"){
										$('.reqCk').prop("checked",true);
									}
									else{
										$('.reqCk').prop("checked",false);
									}
									if(type=='radio'){
										var grpname = $(this).attr('data-grpname'); 
										$('##RadGroupName').val(grpname).show();
										$('.RadGroupName').show();
									}
									else{
										$('##RadGroupName').val('').hide();
										$('.RadGroupName').hide();
									}
									$('##selectedField h3').html(name);
									$('##selectedField').show();
								})
				  		}
				  	}
				});

				$('.text_drag ').click(function(){
					var name = $(this).val();
					var mandatory = $(this).attr('data-mandatory');
					var val = $(this).attr('id');
					var type = $(this).attr('type');
					$('.reqCk').val(val);
					if(mandatory=="YES"){
						$('.reqCk').prop("checked",true);
					}
					else{
						$('.reqCk').prop("checked",false);
					}
					if(type=='radio'){
						var grpname = $(this).attr('data-grpname'); 
						$('##RadGroupName').val(grpname).show();
						$('.RadGroupName').show();
					}
					else{
						$('##RadGroupName').val('').hide();
						$('.RadGroupName').hide();
					}
					$('##selectedField h3').html(name);
					$('##selectedField').show();
				})

				$('.reqCk').click(function(){
					var ckd = $(this).is(":checked");
					var id = $(this).val();
					if(ckd){
						$('##'+id).attr('data-mandatory',"YES");
					}
					else{
						$('##'+id).attr('data-mandatory',"NO");
					}
				})

				$('##RadGroupName').change(function(){
					var id = $('.reqCk').val();
					var val = $(this).val();
					$('##'+id).attr('data-grpname',val);
				})
			})

			function deleteField(ele){
				var id = $(ele).attr('id').replace("del", "drag");
				var zohoid = $('##'+id).find('.text_drag').data('zohoid');
				if($.trim(zohoid).length){
					var val = $('##deleted_fields').val();
					var del = zohoid;
					if($.trim(val).length){
						val+=',';
					}
					val+=zohoid;
					$('##deleted_fields').val(val);
				}
				$('##'+id).remove();
			}

			function saveTemplatesFields(){
				var arrayFields = [];
				var Totalpages = $('##TotalPages').val();
				for(i=0;i<Totalpages;i++){
					var j = 0;
					$('[id^=page_'+i+'_]').each(function() {
						var page_no = $(this).attr('id').split("_")[1];
						var field_type_name = $(this).attr('id').split("_")[2];
						if(field_type_name=='Dot' || field_type_name=='MC' || field_type_name=='Address' || field_type_name=='City' || field_type_name=='State' || field_type_name=='Zip' || field_type_name=='Email' || field_type_name=='Contact' || field_type_name=='Phone' || field_type_name=='Fax' || field_type_name=='TaxID' || field_type_name=='CityStateZip'){
							field_type_name = 'Textfield';
						}
						var field_name = $(this).val();
						var radGroupName = '';
						if(field_type_name=='Radio'){
							var x_coord = (($(this).parent().position().left+15) *100)/ $(this).parent().parent().width();
							var y_coord = ($(this).parent().position().top*100) / $(this).parent().parent().height();
							var radGroupName = $(this).attr('data-grpname');
						}
						else{
							var x_coord =$(this).parent().position().left*0.75;
							var y_coord =$(this).parent().position().top*0.75;
						}
						var abs_width = $(this).width()*0.75;
						var abs_height = $(this).height();
						var field_id = $(this).data('zohoid');
						var is_mandatory = $(this).attr('data-mandatory');

						arrayFields.push({page_no: page_no,field_id:field_id, field_type_name: field_type_name, field_name:field_name, x_coord:parseInt(x_coord),y_coord:parseInt(y_coord),abs_width:parseInt(abs_width),abs_height:parseInt(abs_height),is_mandatory:is_mandatory,radGroupName:radGroupName});
					})
				}
				var deleted_fields = $('##deleted_fields').val();
				$.ajax({
					type    : 'POST',
	                url: 'ajax.cfm?event=ajxUploadTemplateFields&#session.URLToken#',
	                type: 'post',
	                data: {TemplateFields:JSON.stringify(arrayFields),ID:"#url.ID#",del_fields:deleted_fields},
	                beforeSend: function() {
	                   $(".overlay").show();
	                   $("##loader").show();
	                },
	                success: function(relocate){
	                	if(relocate==1){
	                		window.opener.location = 'index.cfm?event=OnboardCarrierDocs&#session.URLToken#';
	                	}
	                  window.close();
	                }
	            });
			}
		</script>
	</head>
	<body style="background-color:#request.qSystemSetupOptions1.BackgroundColor#">
		<h1 style="color:white;font-weight:bold;background-color: ##82bbef;padding-left: 10px;">
			Edit Template
		</h1>
	 	<div class="pdfcontent">
	 		<cfdirectory action="list" directory="#TempDir#" recurse="false" name="dirList">
 			<cfloop query="dirList">
 				<div class="droppable" id="droppable#(dirList.currentrow-1)#" style="background: url('../fileupload/CarrierDocs/#session.usercompanycode#/#tempFolder#/#imagePrefix#_page_#dirList.currentrow#.jpg');">
 				</div>
 			</cfloop>
	 	</div>

	 	<div class="FieldsContent">
			<h3 style="background-color: ##82bbef;color:white;font-weight:bold;width: 100%;padding-left: 10px;margin-top: 10px;">Fields</h3>

			<div class="selector-box draggable">
				<span class="selector-type" id="Name">Full Name</span>
			</div>
			<div class="selector-box draggable">
				<span class="selector-type" id="Company">Company</span>
			</div>
			<div class="selector-box draggable">
				<span class="selector-type" id="Dot">Dot Number</span>
			</div>
			<div class="selector-box draggable">
				<span class="selector-type" id="MC">MC Number</span>
			</div>
			<div class="selector-box draggable">
				<span class="selector-type" id="TaxID">Fed Tax ID</span>
			</div>
			<div class="selector-box draggable">
				<span class="selector-type" id="Address">Address</span>
			</div>
			<div class="selector-box draggable">
				<span class="selector-type" id="CityStateZip">City, State Zip</span>
			</div>
			<div class="selector-box draggable">
				<span class="selector-type" id="City">City</span>
			</div>
			<div class="selector-box draggable">
				<span class="selector-type" id="State">State</span>
			</div>
			<div class="selector-box draggable">
				<span class="selector-type" id="Zip">Zip</span>
			</div>
			<div class="selector-box draggable">
				<span class="selector-type" id="Email">Email</span>
			</div>
			<div class="selector-box draggable">
				<span class="selector-type" id="Contact">Contact Name</span>
			</div>
			<div class="selector-box draggable">
				<span class="selector-type" id="Phone">Phone</span>
			</div>
			<div class="selector-box draggable">
				<span class="selector-type" id="Fax">Fax</span>
			</div>
			<div class="selector-box draggable">
				<span class="selector-type" id="Signature">Signature</span>
			</div>
			<div class="selector-box draggable">
				<span class="selector-type" id="Initial">Initial</span>
			</div>
			<div class="selector-box draggable">
				<span class="selector-type" id="Textfield">Text</span>
			</div>
			<div class="selector-box draggable">
				<span class="selector-type" id="Date">Sign Date</span>
			</div>
			<div class="selector-box draggable">
				<span class="selector-type" id="CustomDate" data-fieldtype="CustomDate">Date</span>
			</div>
			<div class="selector-box draggable">
				<span class="selector-type" id="Checkbox" data-fieldtype="Checkbox">Checkbox</span>
			</div>
			<div class="selector-box draggable">
				<span class="selector-type" id="Radio" data-fieldtype="Radio">Radio</span>
			</div>
			<div class="clear"></div>
			<input type="hidden" id="TotalPages" name="TotalPages" value="#dirlist.recordcount#">
			<input type="hidden" id="deleted_fields" name="deleted_fields" value="">
			<input type="button" name="submit" value="Save" style="margin-top: 25px;color: ##599700;" onclick="saveTemplatesFields()">
		</div>
		<div class="FieldsContent" id="selectedField">
			<h3 style="background-color: ##82bbef;color:white;font-weight:bold;width: 100%;padding-left: 10px;margin-top: 10px;">Fields</h3>
			<label style="float: left;margin-top: 5px;">Required</label>
			<input type="checkbox" class="reqCk" style="margin-left: 5px;;margin-top: 5px;">
			<div class="clear"></div>
			<label class="RadGroupName" style="float: left;margin-top: 5px;">Group Name: </label>
			<input type="text" id="RadGroupName" value="">
		</div>
		<div class="overlay"></div>
	    <div id="loader">
	        <img src="images/loadDelLoader.gif">
	        <p id="loadingmsg">Please wait.</p>
	    </div>
	</body>  
</html>
</cfoutput>
<cffile action="delete" file="#UploadDir#\#qGetDoc.UploadFileName#">