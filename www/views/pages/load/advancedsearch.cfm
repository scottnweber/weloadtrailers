<cfif not structKeyExists(Cookie, "advLoadsDaysFilter")>
	<cfcookie name="advLoadsDaysFilter" value="30" expires="never">
</cfif>
<cfif not structKeyExists(Cookie, "advFilterLoadsByDays")>
	<cfcookie name="advFilterLoadsByDays" value="0" expires="never">
</cfif>
<cfoutput>
	<style>
		.normal-td{
			padding-left: 0;
		}
		.normal-td select{
			width: 100%;
			margin-bottom: 0!important;
		}
	</style>
	<script>
        $(document).ready(function(){
        	$(document).on('change', '.CL-Field', function () {
        		var PickUpState = $('##advSearch tr:last .PickUpState').val();
        		var DeliveryState = $('##advSearch tr:last .DeliveryState').val();
        		var EquipmentID = $('##advSearch tr:last .EquipmentID').val();

        		if(PickUpState.length || DeliveryState.length || EquipmentID.length){
        			var row  = $('##advSearch tr:last').clone();
        			var index=$(row).attr('id').split('_')[1];
        			index++;
		            $(row).attr("id","tr_"+index);
		            $('##advSearch').append(row);
        		}
        	})
        })

        function delRow(row){
        	var dRow = $(row).closest("tr");
        	dindx = $(dRow).attr('id').split('_')[1];

        	var lRow  = $('##advSearch tr:last');
        	lindx = $(lRow).attr('id').split('_')[1];

        	if(dindx==lindx){
        		$(dRow).find("select").each(function(e){
	                $(this).val("");
	            })
        	}
        	else{
        		$(dRow).remove();
        	}
        }
    </script>
	<h1>Advanced Load Search</h1>   
	<cfform name="searchload" action="index.cfm?event=load&#session.URLToken#" method="post" preserveData="yes">
		<div class="white-con-area">
			<div class="white-top"></div>
			<div class="white-mid">				
				<div class="form-con">
					<fieldset>
        				<div class="form-con" style="padding-bottom:15px;">
		   					<ul class="load-link">
			   					<li><a href="index.cfm?event=load&linkid=lastweek&#session.URLToken#&thisweek">This Week</a></li>
			   					<li><a href="index.cfm?event=load&linkid=lastweek&#session.URLToken#&lastweek">Last Week</a></li>
			   					<li><a href="index.cfm?event=load&linkid=thismonth&#session.URLToken#&thismonth">This Month</a></li>
			   					<li><a href="index.cfm?event=load&linkid=lastmonth&#session.URLToken#&lastmonth">Last Month</a></li>
		   					</ul>
						</div>
            			<div class="clear"></div>	
            			<div class="float-left">
            				<label>Pickup Date</label>
            				<input class="sm-input shipdate" type="datefield" style="width:60px;" name="startdateAdv" value="">
            			</div>
            			<div class="float-left">
            				<label class="sm-lbl" style="width: 75px;">Delivery Date</label>
            				<input class="sm-input enddate" type="datefield" style="width:60px;" name="enddateAdv" value="">        
            			</div>
            			<div class="clear"></div>
            			<div class="float-left">
            				<label>Order Date</label>
            				<input class="sm-input shipdate" type="datefield" style="width:60px;" name="orderdateAdv" value="">
            			</div>
            			<div class="float-left">
            				<label class="sm-lbl" style="width: 75px;">Invoice Date</label>
            				<input class="sm-input enddate" type="datefield" style="width:60px;" name="invoicedateAdv" value="">
            			</div>
            			<div class="clear"></div>
						<label>Load Status*</label>
            			<select name="LoadStatusAdv">
             				<option value="">Select Status</option>
							<cfloop query="request.qLoadStatus">
								<option value="#request.qLoadStatus.value#">#request.qLoadStatus.StatusDescription#</option>
							</cfloop>
           				</select>
            			<div class="clear"></div>
            			<label>Dispatcher</label>
            			<cfinput type="text" name="txtDispatcher" id="txtDispatcher" value="">
            			<div class="clear"></div>
            			<label>Sales Rep</label>     
						<cfinput type="text" name="txtAgent" id="txtAgent" value="">	
             			<div class="clear"></div>	
             			<label>Internal Ref##</label>     
						<cfinput type="text" name="internalRefAdv" id="internalRefAdv" value="">	
             			<div class="clear"></div>
             			<cfif request.qSystemSetupOptions.freightBroker EQ 0>
	             			<label>#left(request.qSystemSetupOptions.userdef7,12)#</label>     
							<cfinput type="text" name="userDefinedForTruckingAdv" id="userDefinedForTruckingAdv" value="">	
						<cfelse>
							<cfinput type="hidden" name="userDefinedForTruckingAdv" id="userDefinedForTruckingAdv" value="">	
						</cfif>
             			<div class="clear"></div>
					</fieldset>
				</div>
				<div class="form-con">
					<fieldset>
						<div class="right">  
							<label>Customer Name</label>
	             			<cfinput type="text" name="CustomerNameAdv" id="CustomerNameAdv" value="">
				 			<div class="clear"></div>               
	              			<label>Customer PO##</label>
	                		<cfinput type="text" name="CustomerPOAdv" id="CustomerPOAdv" value="">
	               			<div class="clear"></div>
	               			<label>BOL ##</label>
	                		<cfinput type="text" name="txtBol" id="txtBol" value="">
	               			<div class="clear"></div>
							<label>Pickup City</label>
	                		<cfinput type="text" name="shipperCityAdv" id="shipperCityAdv" value="" style="width: 107px;">
							<div class="clear"></div>
	                		<label>Delivery City</label>
	                		<cfinput type="text" name="consigneeCityAdv" id="consigneeCityAdv" value="" style="width: 107px;"> 
	            			<div class="clear"></div>
	                		<label>Carrier Name</label>
	                		<cfinput type="text" name="CarrierNameAdv" id="CarrierNameAdv" value="">
	                		<div class="clear"></div>   
                			<table  border="0" class="data-table" cellspacing="0" cellpadding="0" style="margin-bottom: 5px;margin-left: 39px;">
						        <thead>
						            <tr>
						                <th align="center" valign="middle" class="head-bg" style="border-left: 1px solid ##5d8cc9;border-top-left-radius: 5px;height: 20px;">Pick State</th>
						                <th align="center" valign="middle" class="head-bg">Del State</th>
						                <th align="center" valign="middle" class="head-bg">Equipment</th>
						                <th align="center" valign="middle" class="head-bg" style="border-top-right-radius: 5px;"></th>
						            </tr>
						        </thead>
						        <tbody id="advSearch">
						            <tr id="tr_1">
						                <td  align="left" valign="middle" nowrap="nowrap" class="normal-td" style="border-left: 1px solid ##5d8cc9;">
						                    <select name="ShipperStateAdv" class="PickUpState CL-Field" style="width: 72px;">
						                        <option value="">Select</option>
						                        <cfloop query="request.qStates">
													<option value="#request.qStates.statecode#">#request.qStates.statecode#</option>	
												</cfloop>  
						                    </select>
						                </td>
						                <td  align="left" valign="middle" nowrap="nowrap" class="normal-td">
						                    <select name="ConsigneeStateAdv" class="DeliveryState CL-Field" style="width: 72px;">
						                        <option value="">Select</option>
						                        <cfloop query="request.qStates">
													<option value="#request.qStates.statecode#">#request.qStates.statecode#</option>	
												</cfloop>  
						                    </select>
						                </td>
						                <td  align="left" valign="middle" nowrap="nowrap" class="normal-td">
						                    <select name="EquipmentAdv" class="EquipmentID CL-Field">
						                        <option value="">Select</option>
						                        <cfloop query="request.qEquipments">
													<option value="#request.qEquipments.EquipmentID#">#request.qEquipments.EquipmentName#</option>
												</cfloop>
						                    </select>
						                </td>
						                 <td  align="left" valign="middle" nowrap="nowrap" class="normal-td">
						                    <img onclick="delRow(this)" src="images/delete-icon.gif" style="width:10px;margin-left: 5px;cursor: pointer;">&nbsp;
						                </td>
						            </tr>
						        </tbody>
						        <tfoot>
						            <tr>
						                <td colspan="4" align="left" valign="middle" class="footer-bg" style="border-left: 1px solid ##5d8cc9;border-right: 1px solid ##5d8cc9;border-bottom-left-radius: 5px;border-bottom-right-radius: 5px;">
						                </td>
						            </tr>  
						        </tfoot>  
						    </table> 
						    <div class="clear"></div>
						    <input name="filterDays" type="checkbox" class="s-bttn" value="" <cfif structKeyExists(cookie, "advfilterDays") and cookie.advFilterLoadsByDays EQ 1>checked="true"</cfif> id="filterDays" style="width: 15px;margin-left: 15px;height: 22px;margin-top: 3px;" onclick="updateDaysFilterCookies();" />
						    <div style="margin-top: 5px;float: left;color: ##3a5b96;">Filter Loads for the last</div>
						    <input style="width: 20px;margin-left: 10px;<cfif NOT (structKeyExists(cookie, "advfilterDays") and cookie.advFilterLoadsByDays EQ 1)>background-color: ##e3e3e3;</cfif>" name="daysFilter" id="daysFilter" value="#cookie.advLoadsDaysFilter#" onkeyup="if (/\D/g.test(this.value)) this.value = this.value.replace(/\D/g,'')" onchange="updateDaysFilterCookies();" <cfif NOT (structKeyExists(cookie, "advfilterDays") and cookie.advFilterLoadsByDays EQ 1)>disabled</cfif>>
							<div style="margin-top: 5px;float: left;color: ##3a5b96;;">Days</div>
	                		<div class="clear"></div>
							<input name="searchsubmit" type="submit" class="bttn" onclick="return checkdate();" onclick="return checkLoad();" onfocus="checkUnload();" value="Search" style="width:96px;" />
							<input name="back" type="button" onclick="javascript:history.back();" class="bttn" value="Back" style="width:62px;" />
						</div>
					</fieldset>
         		</div>
				<div class="clear"></div>
			</div>
		</div>
	</cfform>	
	<script>
		function checkdate(){
			var reg =/((^(10|12|0?[13578])([/])(3[01]|[12][0-9]|0?[1-9])([/])((1[8-9]\d{2})|([2-9]\d{3}))$)|(^(11|0?[469])([/])(30|[12][0-9]|0?[1-9])([/])((1[8-9]\d{2})|([2-9]\d{3}))$)|(^(0?2)([/])(2[0-8]|1[0-9]|0?[1-9])([/])((1[8-9]\d{2})|([2-9]\d{3}))$)|(^(0?2)([/])(29)([/])([2468][048]00)$)|(^(0?2)([/])(29)([/])([3579][26]00)$)|(^(0?2)([/])(29)([/])([1][89][0][48])$)|(^(0?2)([/])(29)([/])([2-9][0-9][0][48])$)|(^(0?2)([/])(29)([/])([1][89][2468][048])$)|(^(0?2)([/])(29)([/])([2-9][0-9][2468][048])$)|(^(0?2)([/])(29)([/])([1][89][13579][26])$)|(^(0?2)([/])(29)([/])([2-9][0-9][13579][26])$))/;
			    
	    	if($(".shipdate").val().length){
	    		if(!$(".shipdate").val().match(reg)){
	    			alert('Please enter a valid date');
	    			 $(".shipdate").focus();
	    			$(".shipdate").val('');
	    			return false;
	    		}
	    	}	
			    	
			if($(".enddate").val().length){
	    		if(!$(".enddate").val().match(reg)){
	    			alert('Please enter a valid date');
	    			 $(".enddate").focus();
	    			$(".enddate").val('');
	    			return false;
	    		}
	    	}	
            return true;
		}
		$(document).ready(function(){
			$( "[type='datefield']" ).datepicker({
			  dateFormat: "mm/dd/yy",
			  showOn: "button",
			  buttonImage: "images/DateChooser.png",
			  buttonImageOnly: true,
			  showButtonPanel: true
			});
			$( ".datefield" ).datepicker( "option", "showButtonPanel", true );
			var old_goToToday = $.datepicker._gotoToday
			$.datepicker._gotoToday = function(id) {
				old_goToToday.call(this,id)
				this._selectDate(id)
			}

		});

		function updateDaysFilterCookies(){
			var LoadsDaysFilter = $('##daysFilter').val();
			var FilterDays = $('##filterDays').is(":checked");
			$.ajax({
		        type    : 'POST',
		        url     : "ajax.cfm?event=ajxUpdateDaysFilterCookies&#session.URLToken#",
		        data    : {LoadsDaysFilter:$.trim(LoadsDaysFilter),FilterDays:FilterDays,Advanced:1},
		        beforeSend:function() {
		            $('.overlay').show();
		        },
		        success :function(response){
		        	if(FilterDays==0){
		        		$("##daysFilter").prop('disabled', true);
		        		$("##daysFilter").css('background-color', "##e3e3e3");
		        	}else{
		        		$("##daysFilter").prop('disabled', false);
		        		$("##daysFilter").css('background-color', "##fff");
		        	}
		        }
		    })
		}
	</script>	   
</cfoutput>