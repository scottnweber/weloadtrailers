<cfparam name="form.LoadText" default="">
<cfparam name="form.Template" default="">
<cfparam name="form.NewTemplate" default="">
<cfif structKeyExists(form, "Refresh")>
	<cfinvoke component ="#variables.objLoadGateway#" method="ProcessAIImportData" frmStruct="#form#" idReturn="true" returnvariable="request.qLoadData"/>
</cfif>
<cfif structKeyExists(form, "Import")>
	<cfinvoke component ="#variables.objLoadGateway#" method="AIImportData" frmStruct="#form#" idReturn="true" returnvariable="session.qImportResponse"/>
	<cfif session.qImportResponse.res eq 'success'>
		<cflocation url="index.cfm?event=AIImport" addtoken="true">
	<cfelse>
		<cfinvoke component ="#variables.objLoadGateway#" method="ProcessAIImportData" frmStruct="#form#" idReturn="true" returnvariable="request.qLoadData"/>
	</cfif>
</cfif>
<cfif structKeyExists(form, "Template") AND len(trim(form.Template))>
	<cfinvoke component="#variables.objloadGateway#" method="getTemplateDetails" TemplateID="#form.Template#" returnvariable="request.qTemplateDetail" />
</cfif>
<cfinvoke component="#variables.objloadGateway#" method="getLoadSystemSetupOptions" returnvariable="request.qSystemSetupOptions1" />
<cfinvoke component="#variables.objloadGateway#" method="getTemplates" returnvariable="request.Templates" />
<cfinvoke component="#variables.objequipmentGateway#" method="getloadEquipments" returnvariable="request.qEquipments" />
<cfinvoke component="#variables.objAgentGateway#" method="getAllStaes" returnvariable="request.qStates" />
<cfset AuthLevel = "Sales Representative,Manager,Dispatcher,Administrator,Central Dispatcher">
<cfinvoke component="#variables.objloadGateway#" AuthLevel="#AuthLevel#" method="getloadSalesPerson" returnvariable="request.qSalesPerson" />
<cfinvoke component="#variables.objloadGateway#" AuthLevel="Dispatcher" method="getloadSalesPerson" returnvariable="request.qDispatcher" />
<cfinvoke component="#variables.objloadGateway#" method="getLoadStatus" returnvariable="request.qLoadStatus" /> 
<cfinvoke component="#variables.objloadGatewayNew#"  method="getValidCustomers" returnvariable="request.qCustomers"/>

<cfoutput>
	<style type="text/css">
		 .DragAndDrop::-webkit-input-placeholder { /* Chrome/Opera/Safari */
            font-size: 50px;
            font-weight: normal;
            color:##cecece;
            text-align: left;
            padding-top: 6%;
            padding-left: 36%;
        }
		.DragAndDrop{
			border: solid 1px ##cecece;
			padding-top: 35px;
			width: 100%;
			height: 300px;
			padding-left: 10px;
			background: transparent;
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
        .msg-area-success{
            border: 1px solid ##a4da46;
            padding: 5px 15px;
            font-weight: normal;
            width: 98%;
            float: left;
            margin-top: 5px;
            margin-bottom:  5px;
            background-color: ##b9e4b9;
            font-weight: bold;
            font-style: italic;
        }
        .msg-area-error{
            border: 1px solid ##da4646;
            padding: 5px 15px;
            font-weight: normal;
            width: 98%;
            float: left;
            margin-top: 5px;
            margin-bottom:  5px;
            background-color: ##e4b9c6;
            font-weight: bold;
            font-style: italic;
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
	    .ui-datepicker-trigger{
	    	right: 0px;
	    	margin-left: -15px;
	    }
	    ##LaneCity,##LaneState{
		    height: 18px;
		    background: ##FFFFFF;
		    border: 1px solid ##b3b3b3;
		    padding: 2px 2px 0 2px;
		    margin: 0 0 8px 0;
		    font-size: 11px;
	    }
	    ##LaneCity{
	    	width: 107px;
	    }
	    ##LaneState{
	    	width: 45px;
	    }
	    ##AddLane{
	    	width: 50px !important;
	    	color: ##599700;
	    }
	    ##StatusTypeID{
		    width: 111px;
		    height: 21px;
		    background: ##FFFFFF;
		    border: 1px solid ##b3b3b3;
		    padding: 0;
		    margin: 0 0 4px 4px;
		    font-size: 11px;
		}
		.LTL{
			width: 50px;
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

		function TemplateChange(){

			var template = $('##Template').val();

			if(template.length){
				$('##NewTemplate').attr('readonly',true);
                $('##NewTemplate').css('background-color','##c4c7ca');
			}
			else{
				$('##NewTemplate').attr('readonly',false);
                $('##NewTemplate').css('background-color','##fff');
			}

			if($('.HeaderSelect').length){
				$('##Refresh').click();
			}
		}
		function validateFrm(){
			if($('.HeaderSelect').length){
				var CustomerHeaderFound = 0;
				var customerClass ='';
				var customerValidated = 1;

				var pickupDateClass ='';
				var pickupDateValidated = 1;

				var deliveryDateClass ='';
				var deliveryDateValidated = 1;

				var reg =/((^(10|12|0?[13578])([/])(3[01]|[12][0-9]|0?[1-9])([/])((1[8-9]\d{2})|([2-9]\d{3}))$)|(^(11|0?[469])([/])(30|[12][0-9]|0?[1-9])([/])((1[8-9]\d{2})|([2-9]\d{3}))$)|(^(0?2)([/])(2[0-8]|1[0-9]|0?[1-9])([/])((1[8-9]\d{2})|([2-9]\d{3}))$)|(^(0?2)([/])(29)([/])([2468][048]00)$)|(^(0?2)([/])(29)([/])([3579][26]00)$)|(^(0?2)([/])(29)([/])([1][89][0][48])$)|(^(0?2)([/])(29)([/])([2-9][0-9][0][48])$)|(^(0?2)([/])(29)([/])([1][89][2468][048])$)|(^(0?2)([/])(29)([/])([2-9][0-9][2468][048])$)|(^(0?2)([/])(29)([/])([1][89][13579][26])$)|(^(0?2)([/])(29)([/])([2-9][0-9][13579][26])$))/;

				$('.HeaderSelect').each(function(i, obj){
					if($(obj).val()=='Customer Name'){
						CustomerHeaderFound=1;
						customerClass = $(obj).attr('id');
					}
					if($(obj).val()=='Pickup Date'){
						pickupDateClass = $(obj).attr('id');
					}
				})
				if(!CustomerHeaderFound){
					alert('No Customer column found.\nPlease choose one column for Customer Name.');
					return false;
				}
				else{
					var arrValidCustomers = #serializeJSON(valueArray(request.qCustomers, "customername"))#;
					$('.'+customerClass).each(function(i, obj){
						if(!$.trim($(obj).val()).length){
							var rowNo = i+1;
							alert('Please choose a Customer for Row ' + rowNo + '.');
							$(obj).focus();
							customerValidated = 0;
							return false;
						}
						else if(jQuery.inArray($(obj).val(), arrValidCustomers) == -1){
							alert('Invalid Customer.');
							$(obj).focus();
							customerValidated = 0;
							return false;
						}
					})
					if(!customerValidated){
						return false;
					}
				}
				if(pickupDateClass.length){
					$('.'+pickupDateClass).each(function(i, ele){
						var textValue=$(ele).val();
						var rowNo = i+1;
						if(textValue.length){
							if(!textValue.match(reg)){
								alert('Please enter a date in mm/dd/yyyy format for Row ' + rowNo + '.');
								$(ele).focus();
								$(ele).val('');
								pickupDateValidated = 0;
								return false;
							}
						}
					})
				}
				
				if(deliveryDateClass.length){
					$('.'+deliveryDateClass).each(function(i, ele){
						var textValue=$(ele).val();
						var rowNo = i+1;
						if(textValue.length){
							if(!textValue.match(reg)){
								alert('Please enter a date in mm/dd/yyyy format for Row ' + rowNo + '.');
								$(ele).focus();
								$(ele).val('');
								deliveryDateValidated = 0;
								return false;
							}
						}
					})
				}
				if(!pickupDateValidated || !deliveryDateValidated){
					return false;
				}
				var StatusTypeID = $('##StatusTypeID').val();
				if(!$.trim(StatusTypeID).length){
					alert('Please select status.');
					$('##StatusTypeID').focus();
					return false;
				}
			}
		}

		function verifyColumns(column){
			var val = $(column).val();
			var columnIndex=$(column).attr('id').split('_')[1];
			var duplicateField = 0;
			$('.HeaderSelect').each(function(i, obj){
			    var tempVal = $(obj).val();
			    var tempIndex=$(obj).attr('id').split('_')[1];
			    if(tempVal==val && columnIndex !=tempIndex){
			    	alert("Field Header "+val+ " is already selected.\nPlease choose another Field Header.");
			    	$(column).val("Column_"+columnIndex);
			    	duplicateField = 1;
			    }
			});
			if(duplicateField==0){
				var id = $(column).attr('id');
				removeAutoComplete(id);
				removeDatePicker(id);
				removeEquipmentAutoComplete(id);
				removePickupDeliveryAutoComplete(id);
				removeLTL(id);
				$('.'+id).removeClass("Commodity");
				$('.'+id).removeClass("Length");
				$('.'+id).removeClass("PublicNotes");
				if(val=='Customer Name'){
					addAutoComplete(id);
				}
				else if(val=='Pickup Date' || val=='Delivery Date'){
					addDatePicker(id);
				}
				else if(val=='Equipment Name'){
					addEquipmentAutoComplete(id);
				}
				else if(val=='Sales Rep' || val=='Dispatcher'){
					addSalesRepAutoComplete(id);
				}
				else if(val=='Pickup Name' || val=='Delivery Name'){
					addPickupDeliveryAutoComplete(id);
				}
				else if(val=='Commodity'){
					$('.'+id).addClass("Commodity");
				}
				else if(val=='Public Notes'){
					$('.'+id).addClass("PublicNotes");
				}
				else if(val=='LTL'){
					addLTL(id);
				}
				else if(val=='Length'){
					$('.'+id).addClass("Length");
				}
				else if(val=='Weight' || val=='Length' || val=='Width' || val=='Qty'){
					$('.'+id).each(function(i, obj){
						var orgVal = $(obj).val();
						$(obj).val(orgVal.replace(/\D/g,''));
					})
				}
			}
		}
		function addLTL(className){
			$('.'+className).attr("type", "checkbox");
			$('.'+className).addClass("LTL");
		}
		function removeLTL(className){
			if($('.'+className).hasClass('LTL')) {
				$('.'+className).attr("type", "text");
				$('.'+className).removeClass("LTL");
			}
		}
		function addSalesRepAutoComplete(className){
			var sourceJson = [
            <cfloop query="request.qSalesPerson">
                {label: "#request.qSalesPerson.Name#", value: "#request.qSalesPerson.Name#"},
            </cfloop>
            ]
			$('.'+className).attr("placeholder", "Type here to search");
			$('.'+className).each(function(i, tag) {
                $(tag).autocomplete({
                    multiple: false,
                    width: 400,
                    scroll: true,
                    scrollHeight: 300,
                    cacheLength: 1,
                    highlight: false,
                    dataType: "json",
                    source:function( request, response ) {
               			var matcher = new RegExp( "^" + $.ui.autocomplete.escapeRegex( request.term ), "i" );
             			response( $.grep( sourceJson, function( item ){
                 			return matcher.test( item.label );
             			}));
    				},
                    focus: function( event, ui ) {
                        $(this).val(ui.item.value);
                        return false;
                    },
                    select: function(e, ui) {
                        $(this).val(ui.item.value);

                        $('.'+className).each(function( index, element ) {
		            		var tempVal = $(element).val();
		            		if(i != index && !$.trim(tempVal).length){
		            			$(element).val(ui.item.value);
		            		}
		            	})

                        return false;
                    }  
                });
            });
		}

		function removeDatePicker(className){
			$('.'+className).removeAttr("placeholder");
			if($('.'+className).hasClass('hasDatepicker')) {
				$('.'+className).datepicker("destroy");
			}
		}

		function addDatePicker(className){
			$('.'+className).attr("placeholder", "mm/dd/yyyy");
			$('.'+className).datepicker({
              	dateFormat: "mm/dd/yy",
              	showOn: "button",
              	buttonImage: "images/DateChooser.png",
              	buttonImageOnly: true,
              	showButtonPanel: true,
              	onSelect: function(dte) {
              		var ck = $('##copyrow').is(':checked')
		            if(ck){
				        $('.'+className).each(function( index, element ) {
					       	var tempVal = $(element).val();
		            		if(i != index && !$.trim(tempVal).length){
		            			$(element).val(dte);
		            		}
	            		})
			    	}
			    }
            });
            $('.'+className).datepicker( "option", "showButtonPanel", true );
            	var old_goToToday = $.datepicker._gotoToday
            	$.datepicker._gotoToday = function(id) {
             	old_goToToday.call(this,id)
             	this._selectDate(id)
            }
		}

		function removeAutoComplete(className){
			if($('.'+className).hasClass('CustomerAutoComplete')) {
				$('.'+className).removeAttr("placeholder");
				if($('.'+className).hasClass('ui-autocomplete-input')) {
					$('.'+className).autocomplete("destroy");
					$('.CustomerID').remove();
				}
				$('.'+className).removeClass( "CustomerAutoComplete" )
			}
		}
		function addEquipmentAutoComplete(className){
			var sourceJson = [
            <cfloop query="request.qEquipments">
                {label: "#request.qEquipments.EquipmentName#", value: "#request.qEquipments.EquipmentName#"},
            </cfloop>
            ]
			$('.'+className).attr("placeholder", "Type here to search");
			$('.'+className).each(function(i, tag) {
                $(tag).autocomplete({
                    multiple: false,
                    width: 400,
                    scroll: true,
                    scrollHeight: 300,
                    cacheLength: 1,
                    highlight: false,
                    dataType: "json",
                    source:function( request, response ) {
               			var matcher = new RegExp( "^" + $.ui.autocomplete.escapeRegex( request.term ), "i" );
             			response( $.grep( sourceJson, function( item ){
                 			return matcher.test( item.label );
             			}));
    				},
                    focus: function( event, ui ) {
                        $(this).val(ui.item.value);
                        return false;
                    },
                    select: function(e, ui) {
                        $(this).val(ui.item.value);
                        var ck = $('##copyrow').is(':checked')
		            	if(ck){
	                        $('.'+className).each(function( index, element ) {
			            		var tempVal = $(element).val();
			            		if(i != index && !$.trim(tempVal).length){
			            			$(element).val(ui.item.value);
			            		}
			            	})
                    	}
                        return false;
                    }  
                });
            });
		}
		function removeEquipmentAutoComplete(className){
			$('.'+className).removeAttr("placeholder");
			if($('.'+className).hasClass('ui-autocomplete-input')) {
				$('.'+className).autocomplete("destroy");
			}
		}

		function removePickupDeliveryAutoComplete(className){
			$('.'+className).removeAttr("placeholder");
			if($('.'+className).hasClass('ui-autocomplete-input')) {
				$('.'+className).autocomplete("destroy");
			}
		}

		function addPickupDeliveryAutoComplete(className){
			$('.'+className).attr("placeholder", "Type here to search");

			$('.'+className).each(function(i, tag) {
				$(tag).autocomplete({
		            multiple: false,
		            width: 400,
		            scroll: true,
		            scrollHeight: 300,
		            cacheLength: 1,
		            highlight: false,
		            dataType: "json",
		            autoFocus: true,
		            source: 'searchCustomersAutoFill.cfm?queryType=getShippers&CompanyID=#session.CompanyID#&stoptype='+this.id,
		            select: function(e, ui) {
		                $(this).val(ui.item.name);
		                return false;
		            }
	        	});
		        $(tag).data("ui-autocomplete")._renderItem = function(ul, item) {
		            return $( "<li>"+item.name+"<br/><b><u>Address</u>:</b> "+ item.location+"&nbsp;&nbsp;&nbsp;<b><u>City</u>:</b>" + item.city+"&nbsp;&nbsp;&nbsp;<b><u>State</u>:</b> " + item.state+"<br/><b><u>Zip</u>:</b> " + item.zip+"</li>" )
		                    .appendTo( ul );
		        }
			})
		}

		function addAutoComplete(className){
			$('.'+className).attr("placeholder", "Type here to search");
			$('.'+className).addClass("CustomerAutoComplete");
			$('.'+className).each(function(i, tag) {
				var id = $(tag).attr('id');
				id = id+'_CustomerID';
				$(tag).after( "<input class='CustomerID' type='hidden' name='"+id+"' id='"+id+"'>" );
				$(tag).autocomplete({
		            multiple: false,
		            width: 400,
		            scroll: true,
		            scrollHeight: 300,
		            cacheLength: 1,
		            highlight: false,
		            dataType: "json",
		            source: 'searchCustomersAutoFill.cfm?queryType=getCustomers&CompanyID=#session.CompanyID#',
		            select: function(e, ui) {
		            	$(this).val(ui.item.name);
		            	$('##'+id).val(ui.item.value);
		            	var ck = $('##copyrow').is(':checked')
		            	if(ck){
		            		$('.'+className).each(function( index, element ) {
			            		var tempVal = $(element).val();
			            		if(i != index && !$.trim(tempVal).length){
			            			var tempID = $(element).attr('id')+'_CustomerID'
			            			$(element).val(ui.item.name);
			            			$('##'+tempID).val(ui.item.value);
			            		}
			            	})
		            	}
		            	return false;
		            },
		            focus: function( event, ui ) {
                        $(this).val(ui.item.name);
                        return false;
                    },
		        })
		        $(tag).data("ui-autocomplete")._renderItem = function(ul, item) {
		            return $( "<li>"+item.name+"<br/><b><u>Address</u>:</b> "+ item.location+"&nbsp;&nbsp;&nbsp;<b><u>City</u>:</b>" + item.city+"&nbsp;&nbsp;&nbsp;<b><u>State</u>:</b> " + item.state+"<br/><b><u>Zip</u>:</b> " + item.zip+"</li>" )
		                    .appendTo( ul );
		        }
			})
		}

		function initiateAutoComplete(){
			$('.HeaderSelect').each(function(i, obj){
			    var val = $(obj).val();
			    var id = $(obj).attr('id');
			    if(val=='Customer Name'){
					addAutoComplete(id);
				}
				else if(val=='Pickup Date' || val=='Delivery Date'){
					addDatePicker(id);
				}
				else if(val=='Equipment Name'){
					addEquipmentAutoComplete(id);
				}
				else if(val=='Sales Rep' || val=='Dispatcher'){
					addSalesRepAutoComplete(id);
				}
				else if(val=='Pickup Name' || val=='Delivery Name'){
					addPickupDeliveryAutoComplete(id);
				}
				else if(val=='Commodity'){
					$('.'+id).addClass("Commodity");
				}
				else if(val=='Length'){
					$('.'+id).addClass("Length");
				}
				else if(val=='LTL'){
					addLTL(id);
				}
				else if(val=='Public Notes'){
					$('.'+id).addClass("PublicNotes");
				}
				else if(val=='Weight' || val=='Length' || val=='Width' || val=='Qty'){
					$('.'+id).each(function(i, obj){
						var orgVal = $(obj).val();
						$(obj).val(orgVal.replace(/\D/g,''));
					})
				}
			});
		}

		function AddCityStateRecord(){
			var City = $('##LaneCity').val();
			var State = $('##LaneState').val();

			if(!$.trim(City).length){
				alert('Please Enter City');
				$('##LaneCity').focus();
			}
			else if(!$.trim(State).length){
				alert('Please Enter State');
				$('##LaneState').focus();
			}
			else{
				var url = "ajax.cfm?event=AddCityStateRecord&#session.URLToken#";
				$.ajax({
					type    : 'POST',
                	url     : url,
                	data    : {City:City,State:State},
                	success :function(data){
                		var resp = jQuery.parseJSON(data).MSG
                		alert(resp);
                	}
				})
			}
			return false;
		}
		$( document ).ready(function() {


			


			<cfif structKeyExists(request, "qLoadData")>
				var elmnt = document.getElementById("LoadsTable");
	   			elmnt.scrollIntoView();

	   			var position = $( "##Column_1").position();
	   			$(".InfotoolTip").css('left', position.left);
   			</cfif>

   			<cfif structKeyExists(request, "qTemplateDetail")>
   				initiateAutoComplete();
   			</cfif>
   			$('.cityAuto').each(function(i, tag) {
                $(tag).autocomplete({
                    multiple: false,
                    width: 400,
                    scroll: true,
                    scrollHeight: 300,
                    cacheLength: 1,
                    highlight: false,
                    dataType: "json",
                    autoFocus: true,
                    source: 'searchCustomersAutoFill.cfm?queryType=getCity&CompanyID=#session.CompanyID#',
                    select: function(e, ui) {
                        var id = this.id;
                        var type = id.split('City_')[0];
                        var clid = id.split('City_')[1];    

                        if($("##"+type+"State_"+clid).val() == ''){
                            if($("##"+type+"State_"+clid+" option[value='"+ui.item.state+"']").length){
                                $("##"+type+"State_"+clid).val(ui.item.state);
                            }
                        }
                        $(this).val(ui.item.city);
                        return false;
                    }
                });
                $(tag).data("ui-autocomplete")._renderItem = function(ul, item) {
                    return $( "<li>"+item.city+"<br/><b><u>State</u>:</b> "+ item.state+"&nbsp;&nbsp;&nbsp;<b><u>Zip</u>:</b>" + item.zip+"</li>" )
                    .appendTo( ul );
                }
            })

            $('##LaneCity').each(function(i, tag) {
                $(tag).autocomplete({
                    multiple: false,
                    width: 400,
                    scroll: true,
                    scrollHeight: 300,
                    cacheLength: 1,
                    highlight: false,
                    dataType: "json",
                    autoFocus: true,
                    source: 'searchCustomersAutoFill.cfm?queryType=getCity&CompanyID=#session.CompanyID#',
                    select: function(e, ui) {
                        $(this).val(ui.item.city);
                        return false;
                    }
                });
                $(tag).data("ui-autocomplete")._renderItem = function(ul, item) {
                    return $( "<li><b><u>City</u>:</b> "+item.city+"<br/><b><u>State</u>:</b> "+ item.state+"</li>" )
                    .appendTo( ul );
                }
            })

            $('##LaneState').each(function(i, tag) {
                $(tag).autocomplete({
                    multiple: false,
                    width: 400,
                    scroll: true,
                    scrollHeight: 300,
                    cacheLength: 1,
                    highlight: false,
                    dataType: "json",
                    autoFocus: true,
                    source: 'searchCustomersAutoFill.cfm?queryType=GetState&CompanyID=#session.CompanyID#',
                    select: function(e, ui) {
                        $(this).val(ui.item.state);
                        return false;
                    }
                });
                $(tag).data("ui-autocomplete")._renderItem = function(ul, item) {
                    return $( "<li><b><u>State</u>:</b> "+ item.state+"</li>" )
                    .appendTo( ul );
                }
            })
            $(document).on("change", ".Commodity", function(){
			    var ID = $(this).attr('id');
			  	var val = $(this).val();

			  	var ck = $('##copyrow').is(':checked')
		        if(ck){
				  	$('.Commodity').each(function() {
				  		var tempID = $(this).attr('id');
				  		var tempVal = $(this).val();
				  		if(ID!=tempID && !$.trim(tempVal).length){
				  			$(this).val(val);
				  		}
	            	})
			  	}

			});
			$(document).on("change", ".PublicNotes", function(){
			    var ID = $(this).attr('id');
			  	var val = $(this).val();

			  	var ck = $('##copyrow').is(':checked')
		        if(ck){
				  	$('.PublicNotes').each(function() {
				  		var tempID = $(this).attr('id');
				  		var tempVal = $(this).val();
				  		if(ID!=tempID && !$.trim(tempVal).length){
				  			$(this).val(val);
				  		}
	            	})
			  	}

			});
			$(document).on("change", ".LTL", function(){
				var ck = $('##copyrow').is(':checked')
		        if(ck){
					$('.LTL').prop('checked', $(this).is(':checked'));
				}
			});
			$(document).on("change", ".Length", function(){
			    var ID = $(this).attr('id');
			  	var val = $(this).val();

			  	var ck = $('##copyrow').is(':checked')
		        if(ck){
				  	$('.Length').each(function() {
				  		var tempID = $(this).attr('id');
				  		var tempVal = $(this).val();
				  		if(ID!=tempID && !$.trim(tempVal).length){
				  			$(this).val(val);
				  		}
	            	})
				}
			});

			$('.InfotoolTip').tooltip({
			  	position: {
					my: "center bottom-20",
					at: "center top",
					using: function( position, feedback ) {
					  	$( this ).css( position );
					  	$( "<div>" )
						.addClass( "arrow" )
						.addClass( feedback.vertical )
						.addClass( feedback.horizontal )
						.appendTo( this );
					}
		  		},
		  		content : 'Click the drop down arrow on Column_1 to map the extra data to an import field shown on the list. Do the same for other columns. Any data left in a column without a matching field will be imported into the Internal Dispatch Notes.'
			});
			setTimeout(function() {
			    $(".ui-tooltip").fadeOut("fast");
			}, 2000);

		})
	</script>
	<cfform name="frmImport" id="frmImport" action="index.cfm?event=AIImport&#session.URLToken#" method="post">
		<cfif structKeyExists(session, "qImportResponse")>
            <div id="message" class="msg-area-#session.qImportResponse.res#">#session.qImportResponse.msg#</div>
            <cfset structDelete(session, "qImportResponse")>
        </cfif>
        <div class="clear"></div>
		<div class="white-con-area" style="height: 36px;background-color: ##82bbef;">
			<h1 style="color:white;font-weight:bold;text-align: center;">Free Style Text for Smart Load Import</h1>
		</div>
		<div class="white-con-area">
			<div class="white-top"></div>
			<div class="white-mid">
				<div style="padding: 10px 20px 20px 20px;">
					<div style="text-align: right;">
						<label>Template Name:</label>
						<select style="width: 113px;" name="Template" id="Template" onchange="TemplateChange()">
							<option value="">Select or Enter</option>
							<cfloop query="request.Templates">
								<option value="#request.Templates.TemplateID#"
								<cfif form.Template EQ request.Templates.TemplateID> selected </cfif>>#request.Templates.TemplateName#</option>
							</cfloop>
						</select>

						<cfif len(trim(form.Template))>
							<input type="text" placeholder="Enter Template" id="NewTemplate" name="NewTemplate" style="width: 100px;background-color:##c4c7ca;" readonly>
						<cfelse>
							<input type="text" placeholder="Enter Template" id="NewTemplate" name="NewTemplate" style="width: 100px;background-color:##fff;" value="#form.NewTemplate#">
						</cfif>
					</div>
					<div style="float: left;width: 75%;">
						<input type="button" class="bttn" value="PASTE TEXT" onclick="getClipboardContents()" style="width: 100px !important;">
					</div>
					<div style="float: left;width: 25%;text-align: right;">
						<label style="color: ##599700;">Add Lane:</label> 
						<input type="text" placeholder="Enter City" id="LaneCity">
						<input type="text" placeholder="Enter ST" id="LaneState">
						<input type="button" class="bttn" value="Add" id="AddLane" onclick="AddCityStateRecord()">
					</div>
					<div class="clear"></div>
					<div style="margin-top: 10px;">
						<textarea name="LoadText" id="LoadText" class="DragAndDrop" placeholder="DRAG & DROP &##13;&##10; TEXT HERE">#form.LoadText#</textarea>
					</div>
				</div>
			</div>
		</div>
		<div class="white-con-area" style="height: 36px;background-color: ##82bbef;">
			<cfif structKeyExists(request, "qLoadData")>
				<div style="float: left;width: 70%;text-align: right;">
					<h2 style="font-weight:bold;color:##000000">IMPORT PREVIEW<span style="font-weight: normal;font-size: 12px;margin-left: 5px;">(edit data below as needed)</span></h2> 
				</div>
			</cfif>
			<div style="float: right;margin-right: 5px;margin-top: 3px;">
				<input type="submit" class="bttn" value="<cfif structKeyExists(request, "qLoadData")>REFRESH<cfelse>Process</cfif>" name="Refresh" id="Refresh" style="width: 75px !important;" onclick="return validateFrmTxt()">
			</div>
		</div>
		<cfif structKeyExists(request, "qLoadData")>
			<input type='hidden' name="totalcount" value="#request.qLoadData.recordcount#">
			<div class="white-con-area">
				<div class="white-top"></div>
				<div class="white-mid">
					<div style="padding: 10px 20px 20px 20px;">
						<div style="border: solid 1px ##cecece;margin-top: 10px;padding:10px;">
							<div>
								<label style="font-weight: bold;float: left;">Copy manually entered data to other rows?</label>
								<input style="float: left;margin: 2px 0 0 2px;" type="checkbox" id="copyrow" checked>
								<img src="images/information.png" class="InfotoolTip" style="width:22px;cursor:pointer;position: absolute;" title="">
							</div>
							<div class="clear" style="height: 10px;"></div>
							<div style="overflow-x: scroll;width: 1210px;">
								<table id="LoadsTable" width="100%" border="0" class="data-table" cellspacing="0" cellpadding="0">
							        <thead>
							            <tr>
							                <th align="center" valign="middle" class="head-bg" style="border-left: 1px solid ##5d8cc9;border-top-left-radius: 5px;height: 20px;">Pickup City</th>
							                <th align="center" valign="middle" class="head-bg">Pickup State</th>
							                <th align="center" valign="middle" class="head-bg">Del City</th>
							                <th align="center" valign="middle" class="head-bg">Del State</th>

											<cfset listHeaders = "Customer Name,Customer Rate,Carrier Rate,Public Notes,LTL,Pickup Date,Pickup Name,Pickup Address,Pickup Contact,Delivery Date,Delivery Name,Delivery Address,Delivery Contact,Commodity,Qty,Equipment Name,Weight,Length,Width,Internal Ref##">


							                <cfif request.qSystemSetupOptions1.FreightBroker NEQ 1>
							                	<cfset listHeaders = listAppend(listHeaders, "Sales Rep,Dispatcher")>
							                </cfif>
							                <cfloop from="1" to="15" step="1" index="i">
												<th align="center" valign="middle" class="head-bg" <cfif i eq 15>style="border-top-right-radius: 5px;"</cfif>>
													<select class="HeaderSelect" id="Column_#i#" name="Column_#i#" onchange="verifyColumns(this)">
														<option value="Column_#i#">Column_#i#</option>
														<cfloop list="#listHeaders#" item="header">
															<option value="#header#"
															<cfif structKeyExists(request, "qTemplateDetail") AND request.qTemplateDetail['Column_#i#'][1] EQ header>
																selected 
															</cfif>
															>#header#<cfif header EQ 'Customer Name'>*</cfif></option>
														</cfloop>
													</select>
												</th>
											</cfloop>
							            </tr>
							        </thead>
							        <tbody>
							        	<cfloop query="request.qLoadData">
									    	<tr>
			                    				<td align="left" valign="middle" nowrap="nowrap" class="normal-td" style="border-left: 1px solid ##5d8cc9;">
			                    					<input type="text" class="cityAuto" name="PickupCity_#request.qLoadData.currentrow#" id="PickupCity_#request.qLoadData.currentrow#" value="#request.qLoadData.PickupCity#">
			                    				</td>
			                    				<td align="left" valign="middle" nowrap="nowrap" class="normal-td">
			                    					<select style="width: 70px;" type="text" name="PickupState_#request.qLoadData.currentrow#" id="PickupState_#request.qLoadData.currentrow#">
			                    						<option value="">Select</option>
							                            <cfloop query="request.qStates">
							                                <option value="#request.qStates.statecode#" <cfif request.qLoadData.PickupState EQ request.qStates.statecode> selected </cfif>>#request.qStates.statecode#</option>
							                            </cfloop>
			                    					</select>
			                    				</td>
			                    				<td align="left" valign="middle" nowrap="nowrap" class="normal-td">
			                    					<input type="text" class="cityAuto" name="DelCity_#request.qLoadData.currentrow#" id="DelCity_#request.qLoadData.currentrow#" value="#request.qLoadData.DelCity#">
			                    				</td>
			                    				<td align="left" valign="middle" nowrap="nowrap" class="normal-td">
			                    					<select style="width: 70px;" type="text" name="DelState_#request.qLoadData.currentrow#" id="DelState_#request.qLoadData.currentrow#">
			                    						<option value="">Select</option>
							                            <cfloop query="request.qStates">
							                                <option value="#request.qStates.statecode#" <cfif request.qLoadData.DelState EQ request.qStates.statecode> selected </cfif>>#request.qStates.statecode#</option>
							                            </cfloop>
			                    					</select>
			                    				</td>
			                    				<cfloop from="1" to="15" step="1" index="i">
													<td align="left" valign="middle" nowrap="nowrap" class="normal-td">
														<input type="text" class="Column_#i#" name="Column_#i#_#request.qLoadData.currentrow#" id="Column_#i#_#request.qLoadData.currentrow#" 
														value="#replace(request.qLoadData['Column_#i#'][currentrow], '"', "''")#"
														>
				                    				</td>
												</cfloop>
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
			<div class="white-con-area" style="height: 36px;background-color: ##82bbef;">
				<div style="float: right;margin-right: 5px;margin-top: 3px;">
					<div style="background-color: #request.qSystemSetupOptions1.BackgroundColorForContent#;float: left;margin-top: 4px;height: 22px;padding-left: 5px;margin-right: 10px;">
						<label>Status*</label>
						<select name="StatusTypeID" id="StatusTypeID">
							<option value="">Select</option>
							<cfloop query="request.qLoadStatus">
								<option <cfif request.qLoadStatus.value EQ request.qSystemSetupOptions1.AIImportStatusID> selected </cfif> value="#request.qLoadStatus.value#">#request.qLoadStatus.StatusDescription#</option>
							</cfloop>
						</select>
					</div>
					<input type="submit" class="bttn" name="Import" id="Import" value="IMPORT" style="width: 65px !important;" onclick="return validateFrm();">
				</div>
			</div>
		</cfif>
		<div class="overlay"></div>
	</cfform>
</cfoutput>