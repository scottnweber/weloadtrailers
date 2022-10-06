<cfoutput>
	<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
	<html xmlns="http://www.w3.org/1999/xhtml">
		<head>
			<title>Load Manager TMS</title>
			<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
			<link rel="shortcut icon" href="../../logofavicon.png">
			 <link rel="stylesheet" href="https://code.jquery.com/ui/1.11.0/themes/smoothness/jquery-ui.css">
			<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css">
			<meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no">
			<style type="text/css">
				body{
					font: normal 11px/16px Arial, Helvetica, sans-serif;background-color: #qSystemConfig.BackgroundColor#;
				}
				h2.blueBg{
					color: white;
    				font-weight: bold;
    				font-size: 18px;
    				background-color: ##82bbef;
    				text-align: center;
    				padding : 5px 0 5px 0;
    				margin-top: 0;
				}
				form{
					background-color: #qSystemConfig.BackgroundColorForContent#;
					margin-top:5px;
				}
				label{
					text-align: right;
					margin-top: 5px;
				}
				input, textarea, select{
					margin-top: 5px;
					padding-left: 5px !important;
					padding-right: 5px !important;
				}
				select{
					height: 22px;
				}
				.redFont{
					color:##ed1d24;
				}
				.bttn{
					background: url(../images/button-bg.gif) left top repeat-x;
					border: 1px solid ##b3b3b3;
					color: ##4c4c4c;
					font-weight: bold;
				}
				.pl-0{
					padding-left: 0;
				}
				.pr-0{
					padding-right: 0;
				}
				.pr-5{
					padding-right: 5;
				}
				.mt-10{
					margin-top: 10px;
				}
				.mt-3{
					margin-top: 3px;
				}
				.mr-10{
					margin-right: 10px;
				}
				.hyperLinkInput{
					color: ##4322cc;
					text-decoration: underline;
    				cursor: pointer;
				}
				.mb-0{
					margin-bottom: 0;
				}
				.pl-5{
					padding-left: 5px;
				}
				.pb-10{
					padding-bottom: 10px;
				}
				input[type="datefield"]{
					width: 25%;
					padding-left: 2px !important;
    				padding-right: 2px !important;
				}
				.ui-datepicker-trigger{
					margin-top: 8px;
					margin-left: 2px;
				}
				.ml-10{
					margin-left: 10px;
				}
				h3.CoveredLanesHeading{
					background-color: red;
				}
				.fs-22{
					font-size: 22px !important;
				}
				.ZoneHeadingChk{
					width: 20px;
					height: 20px;
				}
				.ZoneHeadingLabel{
					font-weight: bold;
					font-size: 16px;
					vertical-align: bottom;
				}
				.ZoneStateChk{
					width: 15px;
					height: 15px;
				}
				.ZoneStateLabel{
					vertical-align: top;
					font-size: 12px;
					font-weight: normal;
				}
				input[value='NEXT'],input[value='SUBMIT CARRIER PACKET']{
					width: 60px;
					height: 50px;
					font-size: 14px;
					background-size: contain;
					color:##599700;
					float: right;
					<cfif structKeyExists(url, "isPdf")>
						display: none;
					</cfif>
				}
				input[value='SUBMIT CARRIER PACKET']{
					width: 90px;
					white-space: normal;
					line-height: 15px;
					font-family: Arial Black;
				}
				input[value='PREVIOUS']{
					width: 90px;
					height: 50px;
					font-size: 14px;
					background-size: contain;
					float: left;
					<cfif structKeyExists(url, "isPdf")>
						display: none;
					</cfif>
				}
				input[value='DOWNLOAD & SUBMIT MANUALLY']{
					height: 50px;
					font-size: 14px;
					background-size: contain;
					float: left;
					width: 110px;
					white-space: normal;
					line-height: 15px;
					font-family: Arial Black;
				}
				.stepLabel{
					font-size: 13px;
					padding-top: 15px;
				}
				@media (min-width: 1200px) {
					.lg-w-20{
						width: 20px;
					}
					input[type="datefield"]{
						width: 19%;
						padding-left: 2px !important;
	    				padding-right: 2px !important;
					}
					.upload-area{
						height: 125px;
					}
				}
				.upload-area{
		            border: 1px solid;
		            text-align: center;
		        }
		        .upload-area:hover{
		            cursor: pointer;
		        }
		        .upload-area h1{
		            color: ##c3c3c3;
		        }
		        ##file,##file_1,##file_2{
		            display: none;
		        }
		        .uploadedFileContainer,.uploadedFileContainer_1,.uploadedFileContainer_2{
		        	display: none;
		        	margin-top: 10px;
		        }
		        .uploadedFile,.uploadedFile_1,.uploadedFile_2{
				    font-size: 16px;
				    background-color: ##82bbef;
				    border: solid 1px;
				    padding-top: 5px;
				    padding-bottom: 5px;
		        }
		        .uploadedFile:before,.uploadedFile_1:before,.uploadedFile_2:before {
					content: url(../images/icon_folder.png);
					position: absolute;
  					bottom: 0;
  					width:10px;
				}
		       
				.ml-25{
					margin-left: 25px;
				}
				.ui-widget-content{
					background-color: ##dfeffc !important;
					border: 1px solid ##aaaaaa;
					position: absolute;
					padding: 0;
				}
				.ui-menu .ui-menu-item {
				    position: relative;
				    margin: 0;
				    padding: 3px 1em 3px 0.4em;
				    cursor: pointer;
				    min-height: 0;
				    list-style-image: url(data:image/gif;base64,R0lGODlhAQABAIAAAAAAAP///yH5BAEAAAAALAAAAAABAAEAAAIBRAA7);
				}
				.ui-state-focus{
					border: 1px solid ##999999;
				    background: ##dadada url(images/ui-bg_glass_75_dadada_1x400.png) 50% 50% repeat-x;
				    font-weight: normal;
				    color: ##212121;
				}
				.ui-helper-hidden-accessible{
					display: none;
				}
			</style>
			<script src="https://code.jquery.com/jquery-1.10.2.min.js"></script>
	    	<script src="https://code.jquery.com/ui/1.11.0/jquery-ui.min.js"></script>
			<script type="text/javascript">

				$(document).ready(function(){
					$('.CityAuto').each(function(i, tag) {
		                $(tag).autocomplete({
		                    multiple: false,
		                    width: 400,
		                    scroll: true,
		                    scrollHeight: 300,
		                    cacheLength: 1,
		                    highlight: false,
		                    dataType: "json",
		                    autoFocus: true,
		                    source: '../searchCustomersAutoFill.cfm?queryType=getCity&CompanyID=#qSystemConfig.CompanyID#',
		                    select: function(e, ui) {
		                        $(this).val(ui.item.city);
		                        var stateEle = $(this).closest('div').find('.StateAuto').attr("id");
		                        var zipEle = $(this).closest('div').find('.ZipAuto').attr("id");
		                        if(!$.trim($('##'+stateEle).val()).length){
		                            if($("##"+stateEle+" option[value='"+ui.item.state+"']").length){
		                                $("##"+stateEle).val(ui.item.state);
		                            }
		                            else{
		                                $("##"+stateEle).val("");
		                            }
		                        }

		                        if(!$.trim($('##'+zipEle).val()).length){
		                            $('##'+zipEle).val(ui.item.zip);
		                        }
		                        return false;
		                    }
		                });
		                $(tag).data("ui-autocomplete")._renderItem = function(ul, item) {
		                    return $( "<li>"+item.city+"<br/><b><u>State</u>:</b> "+ item.state+"&nbsp;&nbsp;&nbsp;<b><u>Zip</u>:</b>" + item.zip+"</li>" )
		                            .appendTo( ul );
		                }
		            });

					$('.ZipAuto').each(function(i, tag) {
		                $(tag).autocomplete({
		                    multiple: false,
		                    width: 400,
		                    scroll: true,
		                    scrollHeight: 300,
		                    cacheLength: 1,
		                    minLength: 1,
		                    highlight: false,
		                    dataType: "json",
		                    autoFocus: true,
		                    source: '../searchCustomersAutoFill.cfm?queryType=GetZip&CompanyID=#qSystemConfig.CompanyID#',
		                    select: function(e, ui) {
		                        $(this).val(ui.item.zip);
		                        var cityEle = $(this).closest('div').find('.CityAuto').attr("id");
		                        var stateEle = $(this).closest('div').find('.StateAuto').attr("id");
		                        if(!$.trim($('##'+cityEle).val()).length){
		                            $('##'+cityEle).val(ui.item.city);
		                        }
		                        if(!$.trim($('##'+stateEle).val()).length){
		                            if($("##"+stateEle+" option[value='"+ui.item.state+"']").length){
		                                $("##"+stateEle).val(ui.item.state);
		                            }
		                            else{
		                                $("##"+stateEle).val("");
		                            }
		                        }
		                        return false;
		                    }
		                });
		                $(tag).data("ui-autocomplete")._renderItem = function(ul, item) {
		                    return $( "<li>"+item.zip+"<br/><b><u>State</u>:</b> "+ item.state+"&nbsp;&nbsp;&nbsp;<b><u>City</u>:</b>" + item.city+"</li>" )
		                            .appendTo( ul );
		                }
		            });

					$( "[type='datefield']" ).datepicker({
					  	dateFormat: "mm/dd/yy",
					  	showOn: "button",
					  	buttonImage: "../images/DateChooser.png",
					  	buttonImageOnly: true,
					});
					$( "[type='datefield']" ).datepicker({
		                showButtonPanel: true
		            });
					$( ".ZoneHeadingChk" ).click(function() {
					  	var cls = $(this).attr('id');
					  	var ckd = $(this).is(":checked");
					  	$('.'+cls).prop('checked', ckd);
					});
					$( "##top-next" ).click(function() {
					  	$('##next-btn').click();
					});
					$( "##top-previous" ).click(function() {
					  	$('##previous-btn').click();
					});
					$( "##top-download" ).click(function() {
					  	$('##download-btn').click();
					});
					$( ".ZoneStateChk" ).click(function() {
					  	var ckd = $(this).is(":checked");
					  	if(!ckd){
					  		var Lane = $(this).val();
					  		$.ajax({
	                            type    : 'POST',
	                            url     : "ajax.cfm?event=ajxDelLane",
	                            data    : {
	                            	Lane : Lane, CarrierID:'#url.CarrierID#'
	                            },
	                            success :function(){}
	                        })
					  	}
					});
					$( "input[name='CarrierEquipments']" ).click(function() {
					  	var ckd = $(this).is(":checked");
					  	if(!ckd){
					  		var EquipmentID = $(this).val();
					  		$.ajax({
	                            type    : 'POST',
	                            url     : "ajax.cfm?event=ajxDelCarrEquip",
	                            data    : {
	                            	EquipmentID : EquipmentID, CarrierID:'#url.CarrierID#'
	                            },
	                            success :function(){}
	                        })
					  	}
					});
					<cfif url.event EQ 'CoveredLanes' AND isDefined('qLanes')>
						var lanes = <cfoutput>#serializeJSON(listtoarray(ValueList(qLanes.PickUpState)))#</cfoutput>;
						for (i = 0; i < lanes.length; i++) {
							$('##'+lanes[i]).prop("checked",true);
							var zoneArr = $('##'+lanes[i]).attr("class").split(" ")
							$('##'+zoneArr[2]).prop("checked",true);
						}
					</cfif>
					<cfif isDefined("currentStep") AND isDefined("TotalStep") AND currentStep EQ TotalStep AND NOT structKeyExists(url, "RenewAttachmentType")>
						$('##top-next,##next-btn').val('SUBMIT CARRIER PACKET');
					</cfif>
				})
            	$( "[type='datefield']" ).datepicker( "option", "showButtonPanel", true );
               
                var old_goToToday = $.datepicker._gotoToday
                	$.datepicker._gotoToday = function(id) {
                 	old_goToToday.call(this,id)
                 	this._selectDate(id)
                }

                function checkDateFormatAll(ele) {
					var reg =/((^(10|12|0?[13578])([/])(3[01]|[12][0-9]|0?[1-9])([/])((1[8-9]\d{2})|([2-9]\d{3}))$)|(^(11|0?[469])([/])(30|[12][0-9]|0?[1-9])([/])((1[8-9]\d{2})|([2-9]\d{3}))$)|(^(0?2)([/])(2[0-8]|1[0-9]|0?[1-9])([/])((1[8-9]\d{2})|([2-9]\d{3}))$)|(^(0?2)([/])(29)([/])([2468][048]00)$)|(^(0?2)([/])(29)([/])([3579][26]00)$)|(^(0?2)([/])(29)([/])([1][89][0][48])$)|(^(0?2)([/])(29)([/])([2-9][0-9][0][48])$)|(^(0?2)([/])(29)([/])([1][89][2468][048])$)|(^(0?2)([/])(29)([/])([2-9][0-9][2468][048])$)|(^(0?2)([/])(29)([/])([1][89][13579][26])$)|(^(0?2)([/])(29)([/])([2-9][0-9][13579][26])$))/;
					var textValue=$(ele).val();
					
					if(textValue.length){
						if(!textValue.match(reg)){
							alert('Please enter a date in mm/dd/yyyy format');
							$(ele).focus();
							$(ele).val('');
						}
					}

				}

				function ParseUSNumber(frmfld,fldName) {
					var phoneText = $(frmfld).val().replace(/\D/g,'');
					phoneText = phoneText.toString().replace(/,/g, "");
					phoneText = phoneText.replace(/-/g, "");
					phoneText = phoneText.replace(/\(/g, "");
					phoneText = phoneText.replace(/\)/g, "");
					phoneText = phoneText.replace(/ /g, "");
					phoneText = phoneText.replace(/ /g, "");
				  	if(phoneText.substring(0,10).search(/[a-zA-Z]/g)==-1 & isFinite(phoneText.substring(0,10)) & phoneText.substring(0,10).length==10){

						var part1 = phoneText.substring(0,6);
						part1 = part1.replace(/(\S{3})/g, "$1-");
						var part2 = phoneText.substring(6,10);
						var ext = phoneText.substring(10);
						if (ext.length) {
							var phoneField = part1 + part2+" "+ext;
						} else {
							var phoneField = part1 + part2;
						}
						$(frmfld).val(phoneField);
					} else if(phoneText.substring(0,10).length !=0) {
						if(fldName != ""){
							alert('Invalid '+fldName+'!');
						}else{
							alert('Invalid Phone Number!');
						}
						
						$(frmfld).focus();
					}
				}

				function AddDriver(){
					var TotalCount = $('##TotalDriverCount').val();
					var NewCount = parseInt(TotalCount)+1;
					var original = document.getElementById('Driver_1');
					var clone = original.cloneNode(true);
					$(clone).find("input").each(function(e){
						$(this).val("");
						var name = $(this).attr("name");
						name = name.replace("_1", "_"+NewCount);
						$(this).attr("name",name);
					})
					$(clone).attr("id","Driver_"+NewCount);
					$('##DriverContacts').append('<h2 class="col-xs-12 col-lg-12 blueBg" id="DriverHdr_'+NewCount+'">Driver '+NewCount+'</h2>');
					$('##DriverContacts').append(clone);
					$('##DriverContacts').append('<div class="col-xs-12 col-lg-12 text-center pb-10" id="DriverAct_'+NewCount+'"><input class="bttn" type="button" value="ADD ANOTHER DRIVER" onclick="AddDriver();">&nbsp;<input class="bttn" type="button" value="Remove" onclick="RemoveDriver('+NewCount+')"></div><div class="clearfix"></div>');
					$('input[name="DriverContactPerson_'+NewCount+'"]') .focus();
					$('##TotalDriverCount').val(NewCount);
				}

				function RemoveDriver(Index){
					var TotalCount = $('##TotalDriverCount').val();
					var ContactID = $('input[name="DriverContactID_'+Index+'"]').val();
					if($.trim(ContactID).length){
						$.ajax({
                            type    : 'POST',
                            url     : "ajax.cfm?event=ajxDelContact",
                            data    : {
                            	CarrierContactID : ContactID
                            },
                            success :function(){}
                        })
					}

					if(TotalCount==1){
						var clone = $('##Driver_1');
						$(clone).find("input").each(function(e){
                            $(this).val("");
                        });
					}
					else{
						$('##DriverHdr_'+Index).remove();
						$('##Driver_'+Index).remove();
						$('##DriverAct_'+Index).remove();
						if(TotalCount>Index){
							for(i=Index+1;i<=TotalCount;i++){
								var clone = $('##Driver_'+i);
								var j = i-1;
								$('##DriverHdr_'+i).html('Driver ' + j);
								$(clone).find("input").each(function(e){
	                            	var name = $(this).attr("name");
		                            name = name.replace("_"+i, "_"+j);
		                            $(this).attr("name",name);
		                        });
		                        $('##DriverAct_'+i).find('input[value="Remove"]').attr('onclick', 'RemoveDriver('+j+')');
		                        $(clone).attr("id","Driver_"+j);
		                        $('##DriverHdr_'+i).attr("id","DriverHdr_"+j);
		                        $('##DriverAct_'+i).attr("id","DriverAct_"+j);

							}
						}
						var NewCount = parseInt(TotalCount)-1;
						$('##TotalDriverCount').val(NewCount);
						$('##DriverHdr_1').html('Add Contact');
					}
				}

				function AddContact(){
					var TotalCount = $('##TotalCount').val();
					var NewCount = parseInt(TotalCount)+1;
					var original = document.getElementById('Contact_1');
					var clone = original.cloneNode(true);
					$(clone).find("input").each(function(e){
						if($(this).attr("type") != "radio"){
							$(this).val("");
						}
						var name = $(this).attr("name");
						name = name.replace("_1", "_"+NewCount);
						$(this).attr("name",name);
					})
					$(clone).find('input[name^="ContactType_"][value="Billing"]').prop("checked",true);;
					$(clone).attr("id","Contact_"+NewCount);
					$('##Contacts').append('<h2 class="col-xs-12 col-lg-12 blueBg" id="ContactHdr_'+NewCount+'">Contact '+NewCount+'</h2>');
					$('##Contacts').append(clone);
					$('##Contacts').append('<div class="col-xs-12 col-lg-12 text-center pb-10" id="ContactAct_'+NewCount+'"><input class="bttn" type="button" value="ADD ANOTHER DRIVER" onclick="AddContact();">&nbsp;<input class="bttn" type="button" value="Remove" onclick="RemoveContact('+NewCount+')"></div><div class="clearfix"></div>');
					$('input[name="ContactPerson_'+NewCount+'"]') .focus();
					$('##TotalCount').val(NewCount);
				}

				function RemoveContact(Index){
					var TotalCount = $('##TotalCount').val();
					var ContactID = $('input[name="ContactID_'+Index+'"]').val();
					if($.trim(ContactID).length){
						$.ajax({
                            type    : 'POST',
                            url     : "ajax.cfm?event=ajxDelContact",
                            data    : {
                            	CarrierContactID : ContactID
                            },
                            success :function(){}
                        })
					}

					if(TotalCount==1){
						var clone = $('##Contact_1');
						$(clone).find("input").each(function(e){
                            $(this).val("");
                        });
					}
					else{
						$('##ContactHdr_'+Index).remove();
						$('##Contact_'+Index).remove();
						$('##ContactAct_'+Index).remove();
						if(TotalCount>Index){
							for(i=Index+1;i<=TotalCount;i++){
								var clone = $('##Contact_'+i);
								var j = i-1;
								$('##ContactHdr_'+i).html('Contact ' + j);
								$(clone).find("input").each(function(e){
	                            	var name = $(this).attr("name");
		                            name = name.replace("_"+i, "_"+j);
		                            $(this).attr("name",name);
		                        });
		                        $('##ContactAct_'+i).find('input[value="Remove"]').attr('onclick', 'RemoveContact('+j+')');
		                        $(clone).attr("id","Contact_"+j);
		                        $('##ContactHdr_'+i).attr("id","ContactHdr_"+j);
		                        $('##ContactAct_'+i).attr("id","ContactAct_"+j);

							}
						}
						var NewCount = parseInt(TotalCount)-1;
						$('##TotalCount').val(NewCount);
						$('##ContactHdr_1').html('Add Contact');
					}
				}

				function validateCarrierInformation(){
					if(!$.trim($("input[name='CarrierName']").val()).length){
						alert('Please enter Carrier Name.');
						$("input[name='CarrierName']").focus();
						return false;
					}
					if(!$.trim($("input[name='City']").val()).length){
						alert('Please enter City.');
						$("input[name='City']").focus();
						return false;
					}
					if(!$.trim($("select[name='StateCode']").val()).length){
						alert($("input[name='StateCode']").val())
						alert('Please choose State.');
						$("input[name='StateCode']").focus();
						return false;
					}
					if(!$.trim($("input[name='ZipCode']").val()).length){
						alert('Please enter ZipCode.');
						$("input[name='ZipCode']").focus();
						return false;
					}
					if(!$.trim($("input[name='Phone']").val()).length){
						alert('Please enter Phone.');
						$("input[name='Phone']").focus();
						return false;
					}
					if(!$.trim($("input[name='EmailID']").val()).length){
						alert('Please enter EmailID.');
						$("input[name='EmailID']").focus();
						return false;
					}
					<cfif qSystemConfig.RequireFedTaxID>
						if(!$.trim($('##TaxID').val()).length){
							alert('Please enter Fed Tax ID.');
							$('##TaxID').focus();
							return false;
						}
					</cfif>
				}

				function validateInsuranceForm(){
					if ($.trim($("input[name='InsCompany']").val()).length || $.trim($("input[name='InsCompPhone']").val()).length || $.trim($("input[name='InsEmail']").val()).length || $.trim($("textarea[name='InsuranceCompanyAddress']").val()).length || $.trim($("input[name='InsPolicyNumber']").val()).length || $.trim($('.uploadedFile').html()).length) {
						if(!$.trim($("input[name='InsExpDate']").val()).length){
							alert('Please enter Expiration Date');
							$("input[name='InsExpDate']").focus();
							return false;
						}else{
							var RenewalDate = $("input[name='InsExpDate']").val();
							if(!validateRenewalDate()){
								alert('Please enter a valid date that is not in the past.');
								$("input[name='InsExpDate']").focus();
								return false;
							}
							function validateRenewalDate(){
								var TodayDate = new Date();
								var RenewalDate= new Date($("input[name='InsExpDate']").val());
								if (RenewalDate<= TodayDate) {
									return false;
								}
								return true;
							}
						
						}
					}
					if ($.trim($("input[name='InsCompanyCargo']").val()).length || $.trim($("input[name='InsCompPhoneCargo']").val()).length || $.trim($("input[name='InsEmailCargo']").val()).length || $.trim($("textarea[name='InsuranceCompanyAddressCargo']").val()).lengt || $.trim($("input[name='InsPolicyNumberCargo']").val()).length || $.trim($('.uploadedFile_1').html()).length) {
						if(!$.trim($("input[name='InsExpDateCargo']").val()).length){
							alert('Please enter Expiration Date');
							$("input[name='InsExpDateCargo']").focus();
							return false;
						}else{
							var RenewalDate = $("input[name='InsExpDateCargo']").val();
							if(!validateRenewalDate()){
								alert('Please enter a valid date that is not in the past.');
								$("input[name='InsExpDateCargo']").focus();
								return false;
							}
							function validateRenewalDate(){
								var TodayDate = new Date();
								var RenewalDate= new Date($("input[name='InsExpDateCargo']").val());
								if (RenewalDate<= TodayDate) {
									return false;
								}
								return true;
							}
						}
					}
					if ($.trim($("input[name='InsCompanyGeneral']").val()).length || $.trim($("input[name='InsCompPhoneGeneral']").val()).length || $.trim($("input[name='InsEmailGeneral']").val()).length || $.trim($("textarea[name='InsuranceCompanyAddressGeneral']").val()).length || $.trim($("input[name='InsPolicyNumberGeneral']").val()).length ||  $.trim($('.uploadedFile_2').html()).length) {
						if(!$.trim($("input[name='InsExpDateGeneral']").val()).length){
							alert('Please enter Expiration Date');
							$("input[name='InsExpDateGeneral']").focus();
							return false;
						}else{
							var RenewalDate = $("input[name='InsExpDateGeneral']").val();
							if(!validateRenewalDate()){
								alert('Please enter a valid date that is not in the past.');
								$("input[name='InsExpDateGeneral']").focus();
								return false;
							}
							function validateRenewalDate(){
								var TodayDate = new Date();
								var RenewalDate= new Date($("input[name='InsExpDateGeneral']").val());
								if (RenewalDate<= TodayDate) {
									return false;
								}
								return true;
							}
						}
					}
					<cfif qSystemConfig.RequireBIPDInsurance>
						if(!$.trim($("input[name='InsCompany']").val()).length){
							alert('Please enter Company.');
							$("input[name='InsCompany']").focus();
							return false;
						}
						if(!$.trim($("input[name='InsCompPhone']").val()).length){
							alert('Please enter Phone.');
							$("input[name='InsCompPhone']").focus();
							return false;
						}
						if(!$.trim($("input[name='InsEmail']").val()).length){
							alert('Please enter Email');
							$("input[name='InsEmail']").focus();
							return false;
						}
						if(!$.trim($("textarea[name='InsuranceCompanyAddress']").val()).length){
							alert('Please enter Address');
							$("input[name='InsuranceCompanyAddress']").focus();
							return false;
						}
						if(!$.trim($("input[name='InsPolicyNumber']").val()).length){
							alert('Please enter PolicyNumber');
							$("input[name='InsPolicyNumber']").focus();
							return false;
						}
						if(!$.trim($("input[name='InsExpDate']").val()).length){
							alert('Please enter Expiration Date');
							$("input[name='InsExpDate']").focus();
							return false;
						}
						if(!$.trim($("input[name='InsLimit']").val()).length){
							alert('Please enter Limit');
							$("input[name='InsLimit']").focus();
							return false;
						}
						var uploadedFile = $('.uploadedFile').html();
						if ($.trim(uploadedFile).length) {
							if(!$.trim($("input[name='InsExpDate']").val()).length){
								alert('Please enter Expiration Date');
								$("input[name='InsExpDate']").focus();
								return false;
							}
							
						}
						if ($('.applyToAll').is(':checked')) {
							return true
						}else{
							var uploadedFile = $('.uploadedFile').html();
							if(!$.trim(uploadedFile).length){
								alert('Please upload the Certificate of BIPD insurance to continue your onboarding process.')
								return false;
							}
						}
					</cfif>
					<cfif qSystemConfig.RequireCargoInsurance>
						if(!$.trim($("input[name='InsCompanyCargo']").val()).length){
							alert('Please enter Company.');
							$("input[name='InsCompanyCargo']").focus();
							return false;
						}
						if(!$.trim($("input[name='InsCompPhoneCargo']").val()).length){
							alert('Please enter Phone.');
							$("input[name='InsCompPhoneCargo']").focus();
							return false;
						}
						if(!$.trim($("input[name='InsEmailCargo']").val()).length){
							alert('Please enter Email');
							$("input[name='InsEmailCargo']").focus();
							return false;
						}
						if(!$.trim($("textarea[name='InsuranceCompanyAddressCargo']").val()).length){
							alert('Please enter Address');
							$("input[name='InsuranceCompanyAddressCargo']").focus();
							return false;
						}
						if(!$.trim($("input[name='InsPolicyNumberCargo']").val()).length){
							alert('Please enter PolicyNumber');
							$("input[name='InsPolicyNumberCargo']").focus();
							return false;
						}
						if(!$.trim($("input[name='InsExpDateCargo']").val()).length){
							alert('Please enter Expiration Date');
							$("input[name='InsExpDateCargo']").focus();
							return false;
						}
						if(!$.trim($("input[name='InsLimitCargo']").val()).length){
							alert('Please enter Limit');
							$("input[name='InsLimitCargo']").focus();
							return false;
						}
						if ($('.applyToAll').is(':checked')) {
							return true;
						}else{
							var uploadedFile = $('.uploadedFile_1').html();
							if(!$.trim(uploadedFile).length){
								alert('Please upload the Certificate of Cargo insurance to continue your onboarding process.')
								return false;
							}
						}
					</cfif>
					<cfif qSystemConfig.RequireGeneralInsurance>
						if(!$.trim($("input[name='InsCompanyGeneral']").val()).length){
							alert('Please enter Company.');
							$("input[name='InsCompanyGeneral']").focus();
							return false;
						}
						if(!$.trim($("input[name='InsCompPhoneGeneral']").val()).length){
							alert('Please enter Phone.');
							$("input[name='InsCompPhoneGeneral']").focus();
							return false;
						}
						if(!$.trim($("input[name='InsEmailGeneral']").val()).length){
							alert('Please enter Email');
							$("input[name='InsEmailGeneral']").focus();
							return false;
						}
						if(!$.trim($("textarea[name='InsuranceCompanyAddressGeneral']").val()).length){
							alert('Please enter Address');
							$("input[name='InsuranceCompanyAddressGeneral']").focus();
							return false;
						}
						if(!$.trim($("input[name='InsPolicyNumberGeneral']").val()).length){
							alert('Please enter PolicyNumber');
							$("input[name='InsPolicyNumberGeneral']").focus();
							return false;
						}
						if(!$.trim($("input[name='InsExpDateGeneral']").val()).length){
							alert('Please enter Expiration Date');
							$("input[name='InsExpDateGeneral']").focus();
							return false;
						}
						if(!$.trim($("input[name='InsLimitGeneral']").val()).length){
							alert('Please enter Limit');
							$("input[name='InsLimitGeneral']").focus();
							return false;
						}
						if ($('.applyToAll').is(':checked')) {
							return true;
						}else{
							var uploadedFile = $('.uploadedFile_2').html();
							if(!$.trim(uploadedFile).length){
								alert('Please upload the Certificate of General insurance to continue your onboarding process.')
								return false;
							}
						}
					</cfif>
					var BIPDMin = #qSystemConfig.BIPDMin#;
					var BIPDMinStr = '#NumberFormat(qSystemConfig.BIPDMin)#';
					var InsLimit = $("input[name='InsLimit']").val();
					InsLimit = InsLimit.replace("$","");
					InsLimit = InsLimit.replace(/,/g,"");
					if(isNaN(InsLimit) || !InsLimit.length) {
						alert("Invalid limit.");
						$("input[name='InsLimit']").val('$0.00');
						$("input[name='InsLimit']").focus();
						return false;
					}
					if(InsLimit<BIPDMin){
						alert("Min BIPD limit is $"+BIPDMinStr+".");
						$("input[name='InsLimit']").focus();
						return false;
					}
					var CargoMin = #qSystemConfig.CargoMin#;
					var CargoMinStr = '#NumberFormat(qSystemConfig.CargoMin)#';
					var InsLimitCargo = $("input[name='InsLimitCargo']").val();
					InsLimitCargo = InsLimitCargo.replace("$","");
					InsLimitCargo = InsLimitCargo.replace(/,/g,"");
					if(isNaN(InsLimitCargo) || !InsLimitCargo.length) {
						alert("Invalid limit.");
						$("input[name='InsLimitCargo']").val('$0.00');
						$("input[name='InsLimitCargo']").focus();
						return false;
					}
					if(InsLimitCargo<CargoMin){
						alert("Min Cargo limit is $"+CargoMinStr+".");
						$("input[name='InsLimitCargo']").focus();
						return false;
					}
					var GeneralMin = #qSystemConfig.GeneralMin#;
					var GeneralMinStr = '#NumberFormat(qSystemConfig.GeneralMin)#';
					var InsLimitGeneral = $("input[name='InsLimitGeneral']").val();
					InsLimitGeneral = InsLimitGeneral.replace("$","");
					InsLimitGeneral = InsLimitGeneral.replace(/,/g,"");
					if(isNaN(InsLimitGeneral) || !InsLimitGeneral.length) {
						alert("Invalid limit.");
						$("input[name='InsLimitGeneral']").val('$0.00');
						$("input[name='InsLimitGeneral']").focus();
						return false;
					}
					if(InsLimitGeneral<GeneralMin){
						alert("Min General limit is $"+GeneralMinStr+".");
						$("input[name='InsLimitGeneral']").focus();
						return false;
					}
					var TodayDate = new Date();
					var InsExpDate= new Date($("input[name='InsExpDate']").val());
					if (InsExpDate< TodayDate) {
					    alert('Invalid Expiration Date.');
					    $("input[name='InsExpDate']").focus();
						return false;
					}
					var TodayDate = new Date();
					var InsExpDateCargo= new Date($("input[name='InsExpDateCargo']").val());
					if (InsExpDateCargo< TodayDate) {
					    alert('Invalid Expiration Date.');
					    $("input[name='InsExpDateCargo']").focus();
						return false;
					}
					var TodayDate = new Date();
					var InsExpDateGeneral= new Date($("input[name='InsExpDateGeneral']").val());
					if (InsExpDateGeneral< TodayDate) {
					    alert('Invalid Expiration Date.');
					    $("input[name='InsExpDateGeneral']").focus();
						return false;
					}
					return true;
				}
				function validateACHInformationForm() {
					<cfif qSystemConfig.RequireVoidedCheck>
						var uploadedFile = $('.uploadedFile').html();
						if (!$.trim(uploadedFile).length) {
								alert("Please upload the copy of voided check")
								return false;
							}
							
					</cfif>
					
				}
			</script>
		</head>
	</html>
	<body>
		<div class="container">
			<div class="row">
				<div class="col-xs-12 col-lg-12">
					<div class="col-xs-3 col-lg-3 pl-0">
						<cfif isDefined("PrevEvent")>
							<cfif url.event EQ 'ZohoSign' AND qSystemConfig.AllowDownloadAndSubmitManually EQ 1>
								<input class="bttn top-btn" id="top-download" type="button" name="back" value="DOWNLOAD & SUBMIT MANUALLY">
							<cfelse>
								<input class="bttn top-btn" type="button" id="top-previous" value="PREVIOUS" onclick="">
							</cfif>
						</cfif>
					</div>
					<div class="col-xs-6 col-lg-6 text-center">
						<img src="../../fileupload/img/#qSystemConfig.CompanyCode#/logo/#qSystemConfig.companyLogoName#" width="120" />
					</div>
					<div class="col-xs-3 col-lg-3 pr-0">
						<cfif isDefined("NextEvent")>
							<input class="bttn top-btn" type="button" id="top-next" value="NEXT">
						</cfif>
					</div>
				</div>
			</div>
			<div class="row">
				<div class="col-xs-12 col-lg-12  text-center"><b>#qSystemConfig.CompanyName#</b> </div></div>
</cfoutput>