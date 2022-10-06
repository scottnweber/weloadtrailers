<cfoutput>
	<cfsilent>
		<cfimport taglib="../../../plugins/customtags/mytag/" prefix="myoffices" >
		<!---Init Default Value------->
		<cfparam name="EquipmentCode" default="">
		<cfparam name="ITSCode" default="">
		<cfparam name="TranscoreCode" default="">
		<cfparam name="PosteverywhereCode" default="">
		<cfparam name="loadboardcode" default="">
		<cfparam name="DirectFreightCode" default="">
		<cfparam name="Length" default="1">
		<cfparam name="Width" default="1">
		<cfparam name="PEPcode" default="0">
		<cfparam name="EquipmentName" default="">
		<cfparam name="Status" default="">
		<cfparam name="url.editid" default="0">
		<cfparam name="url.equipmentid" default="0">
		<cfparam name="tempEquipmentId" default="0">
		<cfparam name="traccarUniqueID" default="">
		<cfparam name="variables.equipmentdisabledStatus" default="false"> 
		<cfparam name="temperature"  default="">
		<cfparam name="temperaturescale"  default="">
		<cfparam name="EquipmentType" default="">
		<cfparam name="TruckTrailerOption" default="">
		<cfparam name="ShowCarrierOnboarding" default="0">
		<cfif structkeyexists(url,"equipmentid") and len(trim(url.equipmentid)) gt 1>
			<cfinvoke component="#variables.objequipmentGateway#" method="getAllEquipments" EquipmentID="#url.equipmentid#" returnvariable="request.qEquipments" />
			<cfif request.qEquipments.recordcount>
				<cfset EquipmentCode=#request.qEquipments.EquipmentCode#>
				<cfset EquipmentName=#request.qEquipments.EquipmentName#>
				<cfset PEPcode=#request.qEquipments.PEPcode#>
				<cfset Length=#request.qEquipments.Length#>
				<cfset Width=#request.qEquipments.Width#>
				<cfset ITSCode=request.qEquipments.ITSCode>
				<cfset TranscoreCode=request.qEquipments.TranscoreCode>
				<cfset PosteverywhereCode=request.qEquipments.PosteverywhereCode>
				<cfset Status=#request.qEquipments.IsActive#>
				<cfset editid=#request.qEquipments.EquipmentID#>
				<cfset LoadboardCode=#request.qEquipments.LoadboardCode#>
				<cfset traccarUniqueID=#request.qEquipments.traccarUniqueID#>
				<cfset temperature=request.qEquipments.temperature>	
				<cfset temperaturescale=request.qEquipments.temperaturescale>
				<cfset DirectFreightCode=request.qEquipments.DirectFreightCode>
				<cfset EquipmentType=request.qEquipments.EquipmentType>
				<cfset TruckTrailerOption=request.qEquipments.TruckTrailerOption>
				<cfset ShowCarrierOnboarding=request.qEquipments.ShowCarrierOnboarding>
			</cfif>
		</cfif>
	</cfsilent>
	<cfif structkeyexists(url,"equipmentid") and len(trim(url.equipmentid)) gt 1>
		<script>			
			$(document).ready(function(){
				//when the page loads for equipment edit ajax call for inserting tab id of the page details
				var path = urlComponentPath+"equipmentgateway.cfc?method=insertTabDetails";
				$.ajax({
					type: "Post",
					url: path,
					dataType: "json",
					async: false,
					data: {
						tabID:tabID,
						equipmentid:'#request.qEquipments.EquipmentId#',
						userid:'#session.empid#',
						sessionid:'#session.sessionid#',
						dsn:'#application.dsn#'
					},
					success: function(data){
						console.log(data);
					}
				});
			});
		</script>
		<!---Object to get corresponding user edited the equipment--->
		<cfinvoke component="#variables.objEquipmentGateway#" method="getUserEditingDetails" equipmentid="#request.qEquipments.EquipmentID#" returnvariable="request.qryEquipmentEditingDetails"/>

		<cfif not len(trim(request.qryEquipmentEditingDetails.InUseBy))>
		<!---Object to update corresponding user edited the equipment--->
			<cfinvoke component="#variables.objEquipmentGateway#" method="updateEditingUserId" equipmentid="#request.qEquipments.EquipmentID#" userid="#session.empid#" status="false"/>
			<cfset session.currentEquipmentId = #request.qEquipments.EquipmentID#/>
		<cfelse>
			<!---Object to get corresponding Previously edited---->
			<cfinvoke component="#variables.objAgentGateway#" method="getEditingUserName" returnvariable="request.qryGetEditingUserName" employeID="#request.qryEquipmentEditingDetails.inuseby#" />
			<!---Condition to check current employee and previous editing employee are not same--->
			<cfif session.empid neq request.qryEquipmentEditingDetails.inuseby>
				<cfif request.qryGetEditingUserName.recordcount>
					<cfset variables.equipmentdisabledStatus=true>
					<div class="msg-area" style="margin-left:10px;margin-bottom:10px">
					<span style="color:##d21f1f">This equipment locked because it is currently being edited by #request.qryGetEditingUserName.Name# #dateformat(request.qryEquipmentEditingDetails.inuseon,"mm/dd/yy hh:mm:ss")#.
						An Administrator can manually override this lock by clicking the unlock button.
					</span>
					</div>
				</cfif>
			</cfif>
		</cfif>	
	</cfif>
	
	<cfset Secret = application.dsn>
	<cfset TheKey = 'NAMASKARAM'>
	<cfset Encrypted = Encrypt(Secret, TheKey)>
	<cfset dsn = URLEncodedFormat(ToBase64(Encrypted))>
	<cfif structkeyexists(url,"equipmentid") and len(trim(url.equipmentid)) gt 1>
		<div class="search-panel">
			<div class="delbutton">
				<cfif PEPcode neq 1 and equipmentdisabledStatus neq true>
					<a href="index.cfm?event=equipment&equipmentid=#editid#&#session.URLToken#<cfif structKeyExists(url,"IsCarrier")>&IsCarrier=#url.IsCarrier#</cfif>" onclick="return confirm('Are you sure to delete it ?');">
					Delete
					</a>
				</cfif>
			</div>
		</div>
		<div class="white-con-area" style="height: 36px;background-color: ##82bbef;">
			<div style="float: left; width: 20%;" id="divUploadedFiles">
				
				<cfif equipmentdisabledStatus neq true>
				&nbsp;
				<a style="display:block;font-size: 13px;padding-left: 10px;color:white;" href="##" onclick="popitupEquip('../fileupload/multipleFileupload/MultipleUpload.cfm?id=#editid#&attachTo=57&user=#session.adminusername#&dsn=#dsn#&attachtype=Equipment&CompanyID=#session.CompanyID#')">
					<img style="vertical-align:bottom;" src="images/attachment.png">
					View/Attach Files
				</a>
				<efelse>

					<span style="display:block;font-size: 13px;padding-left: 10px;color:white;"></span>
				</cfif>
			</div>
			<div style="float: left;"><h2 style="color:white;font-weight:bold;margin-left: 12px;">Edit Equipment <span style="padding-left:40px;">#Ucase(EquipmentName)#</span></h2></div>
		</div>
		<div style="clear:left;"></div>
	<cfelse>
		<cfset tempEquipmentId = #createUUID()#>
			<div class="white-con-area" style="height: 36px;background-color: ##82bbef;">
			<div style="float: left; width: 20%;" id="divUploadedFiles">
				&nbsp;<a style="display:block;font-size: 13px;padding-left: 10px;color:white;" href="##" onclick="popitupEquip('../fileupload/multipleFileupload/MultipleUpload.cfm?id=#tempEquipmentId#&attachTo=57&user=#session.adminusername#&newFlag=1&dsn=#dsn#&attachtype=Equipment&CompanyID=#session.CompanyID#')">
						<img style="vertical-align:bottom;" src="images/attachment.png">
						Attach Files</a>
			</div>
			<div style="float: left;"><h2 style="color:white;font-weight:bold;margin-left: 12px;">Add New Equipment</h2></div>
		</div>
		<div style="clear:left;"></div>
	</cfif>
	<div class="white-con-area">
		<div class="white-top"></div>
		<div class="white-mid">
		<cfset actString = "index.cfm?event=addequipment:process&editid=#editid#&#session.URLToken#">
		<cfif structKeyExists(url,"IsCarrier")>
			<cfset actString  = actString & "&IsCarrier=#url.IsCarrier#">
		</cfif>
		<cfform name="frmEquipment" action="#actString#" method="post">
			<cfinput type="hidden" name="editid" id="editid" value="#editid#">
			<input type="hidden" name="equipmentdisabledStatus" id="equipmentdisabledStatus" value="#variables.equipmentdisabledstatus#">

			<input name="appDsn" id="appDsn" type="hidden" value="#application.dsn#">
			<input type="hidden" name="tabid" id="tabid" value="">
			<input type="hidden" name="isSaveEvent" id="isSaveEvent" value="false"/>
			<cfif structkeyexists(url,"relocationEvent")>
				<input name="relocationEvent" id="relocationEvent" type="hidden" value="#url.relocationEvent#">
			</cfif>
			<div class="form-con">
				<fieldset>
					<label><strong>Equipment Code*</strong></label>
					<cfif PEPcode neq 1>
					<cfinput type="text" name="EquipmentCode"    value="#EquipmentCode#" size="25" required="yes" message="Please  enter the equipment code" maxlength="100" class="disAllowHash" style="width: 110px;">
					<label style="width: 37px;"><strong>Type</strong></label>
					<select name="EquipmentType" id="EquipmentType" style="width: 60px;" onchange="trailerTruckOption(0)">
						<option value="">Select</option>
					  	<option value="Truck" <cfif EquipmentType eq 'Truck'>selected="selected" </cfif>>Truck</option>
					  	<option value="Trailer" <cfif EquipmentType eq 'Trailer'>selected="selected" </cfif>>Trailer</option>
					  	<option value="Other" <cfif EquipmentType eq 'Other'>selected="selected" </cfif>>Other</option>
					</select>
					<div class="clear"></div>
					<label><strong>Name*</strong></label>
					<cfinput type="text" name="EquipmentName" value="#EquipmentName#" size="25" required="yes" message="Please  enter the equipment name" maxlength="100"  class="disAllowHash" style="width:225px;">
					<cfelse>
					<cfinput type="text" name="EquipmentCode"    readonly  value="#EquipmentCode#" size="25" required="yes" message="Please  enter the equipment code">
					<div class="clear"></div>
					<label><strong>Name*</strong></label>
					<cfinput type="text" name="EquipmentName"   readonly  value="#EquipmentName#" size="25" required="yes" message="Please  enter the equipment name">
					</cfif>
					<div class="clear"></div>
					 <label><strong>Length</strong></label>
					<cfinput type="text" name="Length" value="#Length#" size="4" maxlength="4"  style=" width:40px"    required="yes" message="Please  enter the Length">
					 <div class="clear"></div>
					 <label><strong>Width</strong></label>
					<cfinput type="text" name="Width" value="#Width#" size="4" maxlength="4"  style=" width:40px"    required="yes" message="Please  enter the Width">
				   <div class="clear"></div><label>
					<strong>ITS Code</strong></label><input type="text" name="ITSCode" value="#ITSCode#" size="25" maxlength="50">
					<div class="clear"></div>
					<label><strong>DAT Load Board Code</strong></label><input type="text" name="TranscoreCode" value="#TranscoreCode#" size="25" maxlength="50">
					<div class="clear"></div>
					<label><strong>LoadBoard Network Code</strong></label><input type="text" name="PosteverywhereCode" value="#PosteverywhereCode#" size="25" maxlength="50">
					<cfif request.qSystemSetupOptions1.freightBroker>
						<input type="hidden" name="freightBroker" id="freightBroker" value="#request.qSystemSetupOptions1.freightBroker#">
					</cfif>
					<div class="clear"></div>
					<label for="Trailer"><strong id="labelTrOption">
						Truck/Trailer:
					</strong></label>
					<select name="TruckTrailerOption" id="TruckTrailerOption">
					</select>
				</fieldset>
			</div>
			<div class="form-con">
				<fieldset>
					<label><strong>Active*</strong></label>
					<select name="Status">
					  <option value="1" <cfif Status eq '1'>selected="selected" </cfif>>Active</option>
					  <option value="0" <cfif Status eq '0'>selected="selected" </cfif>>InActive</option>
					</select>
					<label><strong>123Loadboard Code</strong></label>
					<input type="text" name="123LoadboardCode" value="#LoadboardCode#" size="25" maxlength="50">
					<div class="clear"></div>
					<label title="V (Dry Van)
F (Flatbed)    
R (Reefer)
SD (Step Deck/Single Drop)    
DD (Double Drop)  
RGN (Removable Gooseneck)
MX (Maxi Flat)    
VV (Van+Vented)  
VA (Van+Airride)
VINT (Van+Intermodal)
FINT (Flat+Intermodal)
RINT (Reefer+Intermodal)
CV (Curtain Van)
CONT (Container)
HS (Hotshot)   
CRG (Cargo Van)   
DT (Dump Trailer)
AC (Auto Carrier) 
HB (Hopper Bottom)   
TNK (Tanker)
LB (Lowboy)    
LA (Landall)   
FS (Flat+Sides)
FT (Flat+Tarp)   
PO (Power Only)
O (Other)"><strong>DirectFreight Code</strong></label>
					<input type="text" name="DirectFreightCode" value="#DirectFreightCode#" size="25" maxlength="50">
					<div class="clear"></div>
					<label><strong>Traccar##</strong></label>
					<input type="text" name="traccarUniqueID" value="#traccarUniqueID#" size="25" onkeyup="if (/\D/g.test(this.value)) this.value = this.value.replace(/\D/g,'')" >
					<div class="clear"></div>
					<label><strong>Temperature</strong></label>
					<cfinput type="text" name="temperature" value="#temperature#" size="4" maxlength="5" validate="float"  style="width:40px" message="Please  enter the valid Temperature">
					<label style="width: 5px;margin-top: -5px;margin-left: -5px;"><sup>o</sup></label>
					<select name="temperaturescale" style="width:35px;">
						<option value="C" <cfif temperaturescale EQ "C"> selected </cfif> >C</option>
						<option value="F" <cfif temperaturescale EQ "F"> selected </cfif> >F</option>
					</select>
					<div class="clear"></div>
					<label>Show to Carrier when Onboarding</label>
					<input tabindex="32" type="checkbox" name="ShowCarrierOnboarding" <cfif len(ShowCarrierOnboarding) AND ShowCarrierOnboarding EQ 1>checked="checked"</cfif> class="small_chk" style="float:left">
					<div class="clear"></div>
					<div style="padding-left:150px;">
						<cfif equipmentdisabledStatus neq true>
							<input  type="submit" name="submit" onclick="return validateEquipment(frmEquipment);" class="bttn" value="Save Equipment" style="width:112px;"     />
						<cfelse>

							<cfif structKeyExists(session, 'rightsList') and listContains( session.rightsList, 'UnlockEquipment', ',')>
								<input id="Unlock" name="unlock" type="button" class="bttn" onClick="removeEquipmentEditAccess('#request.qEquipments.equipmentid#');" value="Unlock"  >
							</cfif>

						</cfif>
						<input  type="button" onclick="javascript:history.back();" name="back" class="bttn" value="Back" style="width:70px;" /></div>
					<div class="clear"></div>
				</fieldset>
			</div>
			</cfform>
			<div class="clear"></div>
			<cfif structkeyexists(url,"equipmentid") and len(url.equipmentid) gt 1>
			<p id="footer" style="padding-left:10px;font-family:Verdana, Geneva, sans-serif; font-style:italic bold; text-transform:uppercase;font-family:Verdana, Geneva, sans-serif; font-style:italic; text-transform:uppercase;width:80%;">Last Updated:<cfif isDefined("request.qEquipments")>&nbsp;&nbsp;&nbsp; #request.qEquipments.LastModifiedDateTime#&nbsp;&nbsp;&nbsp;#request.qEquipments.LastModifiedBy#</cfif></p>
			</cfif>
		</div>
		<div class="white-bot"></div>
	</div>
	<script>
		$(function(){
			$('##frmEquipment').submit( function(){
				$('##isSaveEvent').val('true');
			});
			trailerTruckOption(1);
		})

		function trailerTruckOption(pageLoad){
			var val = $('##EquipmentType').val();
			var TruckTrailerOption = '#TruckTrailerOption#';
			if(val == 'Truck'){
				$('##labelTrOption').html('Trailer:');
				var eqType = 'Trailer';
			}
			else if(val == 'Trailer'){
				$('##labelTrOption').html('Truck:');
				var eqType = 'Truck';
			}
			else{
				$('##labelTrOption').html('Truck/Trailer:');
				var eqType = '';
			}
			$('##TruckTrailerOption').html('<option value="">Select</option>');
			$.ajax({
                type    : 'GET',
                url     : "ajax.cfm?event=getEquipmentTruckTrailer&EquipmentType="+eqType,
                success :function(response){
                    var respData = jQuery.parseJSON(response);
                    $.each(respData, function( index, item ) {
                    	if(item.EquipmentID == TruckTrailerOption && pageLoad == 1){
                    		var selText = 'selected'
                    	}
                    	else{
                    		var selText = ''
                    	}
                    	$('##TruckTrailerOption').append('<option value="'+item.EquipmentID+'" '+selText+' data-type="'+item.EquipmentType+'" data-relequip="'+item.RelEquip+'">'+item.EquipmentName+'</option>')
                	})
                	$('.styledSelect').remove();
            		$('.options').remove();
            		var selHtml = $('.select').html();
            		$(selHtml).insertBefore('.select');
            		$('.select').remove();
                	$('##TruckTrailerOption').each(function() {
                		
						var width = $(this).width()-2;
					    // Cache the number of options
					    var $this = $(this),
					    numberOfOptions = $(this).children('option').length;
					    // Hides the select element
					    $this.addClass('s-hidden');
					    // Wrap the select element in a div
					    $this.wrap('<div class="select" style="width:'+width+'px"></div>');
					    // Insert a styled div to sit over the top of the hidden select element
					    $this.after('<div class="styledSelect"></div>');
					    // Cache the styled div
					    var $styledSelect = $this.next('div.styledSelect');
					    // Show the first select option in the styled div
					    $styledSelect.text($this.find('option:selected').text());
					    // Insert an unordered list after the styled div and also cache the list
					    var $table = $('<table />',{'class': 'options','cellspacing':0,'cellpadding':0}).insertAfter($styledSelect);
					    var $thead = $('<thead />').appendTo($table);
					    var $theadtr = $('<tr />').appendTo($thead);
					   	$('<th />', {html: 'Equip','width':'45%'}).appendTo($theadtr);
					   	$('<th />', {html: 'Related Equip','width':'45%'}).appendTo($theadtr);
					   	$('<th />', {html: 'Type','width':'10%'}).appendTo($theadtr);
					   	var $tbody = $('<tbody />').appendTo($table);
					    // Insert a list item into the unordered list for each select option
					    for (var i = 0; i < numberOfOptions; i++) {
					    	var $tbodytr = $('<tr />',{
					    		rel: $this.children('option').eq(i).val()
					    	}).appendTo($tbody);
					        $('<td />', {
					            html: $this.children('option').eq(i).text()
					        }).appendTo($tbodytr);
					        $('<td />', {
					            html: $this.children('option').eq(i).attr('data-relequip')
					        }).appendTo($tbodytr);
					        $('<td />', {
					            html: $this.children('option').eq(i).attr('data-type')
					        }).appendTo($tbodytr);
					    }
					    // Cache the list items
					    var $listItems = $table.children('tbody').children('tr');
					    
					    // Show the unordered list when the styled div is clicked (also hides it if the div is clicked again)
					    $styledSelect.click(function(e) {
					        e.stopPropagation();

					        if($table.is(":visible")){
					        	$table.hide();
					        	return false;
					        }

					        $('div.styledSelect.active').each(function() {
					            $(this).removeClass('active').next('table.options').hide();
					        });
					        $(this).toggleClass('active').next('table.options').toggle();
					        if($(this).next('table.options').css('display')=='table'){
					        	$(this).next('table.options').css('display','block');
					        }
					        if($this.find('option:selected').val() != ''){
					        	$table.children('tbody').children('tr').eq($this.prop('selectedIndex')).addClass('hover');
					        }
					        
					    });
					    // Hides the unordered list when a list item is clicked and updates the styled div to show the selected list item
					    // Updates the select element to have the value of the equivalent option
					    $listItems.click(function(e) {
					        e.stopPropagation();
					        $styledSelect.text($(this).children('td:first').text()).removeClass('active');
					        $this.val($(this).attr('rel'));
					        $table.hide();
					        $this.trigger("change");
					        /* alert($this.val()); Uncomment this for demonstration! */
					    });

					    $listItems.hover(function(e) {
					     	$table.children('tbody').children('tr').removeClass('hover');
					    });
					    // Hides the unordered list when clicking outside of it
					    $(document).click(function() {
					        $styledSelect.removeClass('active');
					        $table.hide();
					    });
					});
                }
            })
		}
	</script>
	<style>
	    .s-hidden {
	        visibility:hidden;
	        padding-right:10px;
	    }
	    .select {
	        cursor:pointer;
	        display:inline-block;
	        position:relative;
	        font:normal 11px/22px Arial,Sans-Serif;
	        color:black;
	        border: 1px solid ##b3b3b3;
	        float: left;
	        height: 21px;
	        margin-bottom: 3px;
	    }
	    .styledSelect {
	        position:absolute;
	        top:0;
	        right:0;
	        bottom:0;
	        left:0;
	        background-color:white;
	        padding:0 4px;
	        height: 21px;
	        overflow: hidden;
	    }
	    .styledSelect:after {
	        content:"";
	        width:0;
	        height:0;
	        border:5px solid transparent;
	        border-color:black transparent transparent transparent;
	        position:absolute;
	        top:9px;
	        right:6px;
	    }
	    .styledSelect:active,.styledSelect.active {
	        background-color:##eee;
	    }
	    .options {
	        display:none;
	        position:absolute;
	        top:100%;
	        right:0;
	        left:0;
	        z-index:999;
	        margin:0 0;
	        padding:0 0;
	        list-style:none;
	        border:1px solid ##b3b3b3;
	        background-color:white;
	        -webkit-box-shadow:0 1px 2px rgba(0,0,0,0.2);
	        -moz-box-shadow:0 1px 2px rgba(0,0,0,0.2);
	        box-shadow:0 1px 2px rgba(0,0,0,0.2);
	        width:352px;
	        max-height: 125px;
	        overflow: auto;
	    }
	    
	    .options tr {
	        padding:0 6px;
	        margin:0 0;
	        padding:0 10px;
	    }
	    .options tr:hover {
	        background-color:##39f;
	        color:white;
	    }
	    .options td {
	        border-top: 1px solid ##b3b3b3;
	        border-right: 1px solid ##b3b3b3;
	        font: 11px/16px Arial,Helvetica,sans-serif !important;
	        padding-left: 3px;
	        padding-right: 3px;
	    }
	    .options th{
	        border-right: 1px solid ##b3b3b3;
	        text-align: left;
	        font: 11px/16px Arial,Helvetica,sans-serif !important;
	        padding-left: 3px;
	        padding-right: 3px;
	        font-weight: bold !important;
	    }
	    .options tr.hover {
	        background-color:##39f;
	        color:white;
	    }
	    .options tbody tr:first-child td:first-child {
	        border-right: none;
	    }
	    .options tbody tr:first-child td:nth-child(2) {
	        border-right: none;
	    }
    </style>
</cfoutput>


