<cfparam name="url.action" default="">
<cfif url.stopNo EQ 0>
	<cfset stopNumber = ''>
<cfelse>
	<cfset stopNumber = url.stopNo>
</cfif>
<cfoutput>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
	<head>
		<meta http-equiv="X-UA-Compatible" content="IE=edge" />
		<meta http-equiv="X-UA-Compatible" content="IE=8" >
		<link rel="stylesheet" type="text/css" href="styles/jquery.autocomplete.css" />
		<link rel="stylesheet" href="https://code.jquery.com/ui/1.11.0/themes/smoothness/jquery-ui.css">
		<script src="https://code.jquery.com/jquery-1.10.2.min.js"></script>
		<script src="https://code.jquery.com/ui/1.11.0/jquery-ui.min.js"></script>
		<script language="javascript" type="text/javascript" src="../scripts/jquery.form.js"></script>	
		<link href="../webroot/styles/style.css" rel="stylesheet" type="text/css" />

		<script type="text/javascript">
			$(document).ready(function(){
				$( ".datefield" ).datepicker({
					dateFormat: "mm/dd/yy",
					showOn: "button",
					buttonImage: "images/DateChooser.png",
					buttonImageOnly: true,
					showButtonPanel: true
	            });
				<cfif url.action eq 'myloads'>
					$("[id^=date_]").change(function(){
						alert($(this).val())
					})
					$("[id^=date_]").on('change', function(){    // 2nd way
    alert($(this).val())
});
				</cfif>
				var opener = window.opener;
				if(opener) {
					var count = 0;
					var listDates =  opener.$("##shipperPickupDateMultiple#stopNumber#").val();
					var LoadNumber = opener.$("##LoadNumber").val();
					<cfif url.action neq 'myloads'>
						if($.trim(LoadNumber).length){
							$('##HeaderLoadNumber').html('Load##'+LoadNumber)
						}
						else{
							$('##HeaderLoadNumber').html('Add New Load')
						}
					</cfif>
					if(!$.trim(listDates).length){
						var listDates =  opener.$("##shipperPickupDate#stopNumber#").val();
					}
					if($.trim(listDates).length){
						var array = listDates.split(",");
						
						for (i=0;i<array.length;i++){
							date=array[i];
							if(count == 0){
						    	var addDelDiv = '<input onclick="addDeliveryDates()" type="checkbox" id="addDelvDate_'+count+'"><div class="addDelvDate">Add Delv Date</div>';
						    }
						    else{
						    	var addDelDiv = '';
						    }

						    count=count+1;

						    var DeliveryDate = opener.$("##consigneePickupDate#stopNumber#").val();
						    var PickUpDate = opener.$("##shipperPickupDate#stopNumber#").val();
						    
						    if($.trim(DeliveryDate).length && $.trim(PickUpDate).length){
						    	var diffDays = date_diff_indays(PickUpDate,DeliveryDate);
						    	var result = new Date(date);
  								result.setDate(result.getDate() + diffDays);
 								DeliveryDate = getFormattedDate(result);
 								addDelDiv = '' 
							}

							var row='<tr id="row_'+count+'"><td>'+count+'</td><td align="left"><input onclick="editDate('+count+')" onchange="updateDeliveryDate('+count+')" class="datefield" id="date_'+count+'" type="text" value="'+date+'"></td><td align="left"><input disabled class="delDate" id="deldate_'+count+'" type="text" value="'+DeliveryDate+'"></td><td>'+addDelDiv+'</td></tr>'
							$('##bodyDates').append(row);

							$( ".datefield" ).datepicker({
								dateFormat: "mm/dd/yy",
								showOn: "button",
								buttonImage: "images/DateChooser.png",
								buttonImageOnly: true,
								showButtonPanel: true
				            });
						}
					}
					$('##count').val(count);
				}
	             
			})

			function updateDeliveryDate(row){
				var PickUpDate = $('##date_'+row).val();
				var date = new Date(PickUpDate);
				date.setDate(date.getDate() + 1);
				date = getFormattedDate(date); 
				$('##deldate_'+row).val(date);
			}

			function date_diff_indays(date1, date2) {
				dt1 = new Date(date1);
				dt2 = new Date(date2);
				return Math.floor((Date.UTC(dt2.getFullYear(), dt2.getMonth(), dt2.getDate()) - Date.UTC(dt1.getFullYear(), dt1.getMonth(), dt1.getDate()) ) /(1000 * 60 * 60 * 24));
			}

			function addDeliveryDates(){
				if($('##addDelvDate_0').is(":checked")){
					$( ".datefield" ).each(function() {
						var row = $(this).attr('id').split('_')[1];
						var date = new Date($('##date_'+row).val());
						date.setDate(date.getDate() + 1);
						date = getFormattedDate(date); 
						$('##deldate_'+row).val(date);
					});
				}
				else{
					$( ".delDate" ).val('');
				}
				
			}

			function adddate(){
				var count = parseInt($('##count').val());
				if(count == 0){
					var date = new Date();
				}
				else{
					var date = new Date($('##date_'+count).val());
					date.setDate(date.getDate() + 1);  
				}
				<cfif url.action neq 'myloads'>
					if(!$('##incWeekend').is(":checked")){
						if(date.getDay() == 0){
							date.setDate(date.getDate() + 1);  
						}
						else if(date.getDay() == 6){
							date.setDate(date.getDate() + 2); 
						}
					}
				</cfif>
				if(count==0){
					var addDelDiv = '<input onclick="addDeliveryDates()" type="checkbox" id="addDelvDate_'+count+'"><div class="addDelvDate">Add Delv Date</div>';
				}
				else{
					var addDelDiv = '';
				}
				count = count+1;
				date = getFormattedDate(date);

				var DeliveryDate = opener.$("##consigneePickupDate#stopNumber#").val();
				var PickUpDate =  opener.$("##shipperPickupDate#stopNumber#").val();

				
			    if($.trim(DeliveryDate).length && $.trim(PickUpDate).length){
			    	var diffDays = date_diff_indays(PickUpDate,DeliveryDate);

			    	var result = new Date(date);
					result.setDate(result.getDate() + diffDays);
					DeliveryDate = getFormattedDate(result);
					var addDelDiv = '';
				}


				var row='<tr id="row_'+count+'"><td>'+count+'</td><td align="left"><input onclick="editDate('+count+')" onchange="updateDeliveryDate('+count+')"  class="datefield" id="date_'+count+'" type="text" value="'+date+'"></td><td align="left"><input disabled class="delDate" id="deldate_'+count+'" type="text" value="'+DeliveryDate+'"></td><td>'+addDelDiv+'</td></tr>'
				$('##bodyDates').append(row);

				$('##count').val(count);
				$( ".datefield" ).datepicker({
					dateFormat: "mm/dd/yy",
					showOn: "button",
					buttonImage: "images/DateChooser.png",
					buttonImageOnly: true,
					showButtonPanel: true
	            });
			}

			function removedate(){
				var count = parseInt($('##count').val());
				$('##row_'+count).remove();
				count = count-1;
				$('##count').val(count);
			}

			function editDate(id){
				$('.ui-datepicker-trigger').hide();
				$('##row_'+id+' .ui-datepicker-trigger').show();
			}

			function getFormattedDate(date) {
				var year = date.getFullYear();

				var month = (1 + date.getMonth()).toString();
				month = month.length > 1 ? month : '0' + month;

				var day = date.getDate().toString();
				day = day.length > 1 ? day : '0' + day;

				return month + '/' + day + '/' + year;
			}

			function saveDates(){
				var dates = [];
				var i = 0;
				$( ".datefield" ).each(function() {
				    var date = $(this).val();
				    dates.push(date);
				    if(i==0){
				    	if($.trim(opener.$("##shipperPickupDate#stopNumber#").val()).length == 0){
				    		opener.$("##shipperPickupDate#stopNumber#").val(date);
				    	}
				    }
				    if(opener.$("##rollOverShipDate") && i==0){
				    	opener.$("##rollOverShipDate").val(date);
				    }
				    i++;
				});
				$( ".delDate" ).each(function() {
					var delDate = $(this).val();
					var i = 0;
					if(i==0){
						if($.trim(opener.$("##consigneePickupDate#stopNumber#").val()).length == 0){
				    		opener.$("##consigneePickupDate#stopNumber#").val(delDate);
				    	}
					}
					i++;
				});
				var MultipleDates = dates.toString();
				opener.$("##shipperPickupDateMultiple#stopNumber#").val(MultipleDates);
				window.close();
				return false;
			}
		</script>
		<style>
			.datefield{
				width: 70px !important;
				padding: 0 !important;
				margin: 0 !important;
				text-align: right;
			}
			.ui-datepicker-trigger{
				display: none;
				margin-left: 6px;
			}
			.delDate{
				width: 70px !important;
				padding: 0 !important;
				margin: 0 !important;
				text-align: right;
			}
			.addDelvDate{
				float: right;
				font-family: "Arial Narrow";
				margin-right: 7px;
				font-size: 13px;
				color: ##800000;
			}
		</style>
	</head>
	<body>
		<div class="white-con-area" style="height: 40px;background-color: ##82bbef;width: 389px;padding-left: 10px;">
			<div style="float: left; width: 40%; min-height: 40px;">
                <h1 style="color:white;font-weight:bold;" id="HeaderLoadNumber"></h1>
            </div>
		</div>
		<div class="white-con-area" style="width: 399px;">
	        <div class="white-mid" style="min-height: 340px;width: 399px;">
	        	<div style="color:##000000;font-size:14px;font-weight:bold;padding-top: 15px;padding-left: 10px;">
					<p style="font-size: 16px;"><cfif url.action neq 'myloads'>Add Multiple </cfif><span style="color: ##0f4100;">Pickup</span> Dates</span></p>
					<p style="font-weight: normal;">(<span style="color: ##800000;">Delivery Dates</span> will populate automatically)</p>
				</div>
				<div style="border:groove 4px;margin-left: 10px;margin-top: 20px;width: 300px;padding: 5px;">
					<form action = "" method="POST" style="margin-top: 10px;" onsubmit="return saveDates();">
						<input type="hidden" id="count" value="0">
						<fieldset style="float: left;width: 189px;">
							<cfif url.action neq 'myloads'>
								<div style="float: left;"><label style="font-size: 14px;"><b>Include Weekend:?</b></label></div>
								<input type="checkbox" style="width: 14px;height: 18px;margin-left: 7px;" id="incWeekend">
								<div class="clear" style="margin-top: 10px;"></div>
							</cfif>
							<label style="margin-top: 3px;"><b style="font-size: 14px;">Add <cfif url.action eq 'myloads'>More</cfif> Dates:</b></label>
							<button type="button" style="cursor: pointer;background-color: ##0f4100;color: ##fff;border-radius: 6px;font-size: 16px;" onclick="adddate();"><b>+</b></button>  
							<button type="button" style="cursor: pointer;background-color: ##800000;color: ##fff;border-radius: 6px;font-size: 16px;width: 25px;margin-left: 20px;"  onclick="removedate();"><b>-</b></button>
						</fieldset>
						<fieldset>
							<input name="submit" type="submit" class="green-btn" value="Save &amp; Exit" style="width:100px !important; float:right; height:48px; position:relative; -webkit-background-size:contain; -moz-background-size:contain;  -o-background-size:contain; background-size:contain;color: ##599700;margin-top: 0px;">
						</fieldset>
						<div class="clear"></div>
						<hr style="margin-top: 10px;">

						<table cellspacing="0" cellpadding="0" style="<cfif url.action neq 'myloads'>margin-top: 15px;</cfif>width: 307px;">
							<thead>
								<tr>
									<th width="5%">&nbsp;</th>
									<th width="30%" align="left" style="color:##0f4100;font-size: 14px;font-weight: normal;">Pickup Date</th>
									<th  width="35%" align="left" style="color:##800000;font-size: 14px;font-weight: normal">Delivery Date</th>
									<th width="30%">&nbsp;</th>
								</tr>
							</thead>
							<tbody id="bodyDates">
								
							</tbody>
						</table>
					</form>
				</div>
	        </div>
	    </div>
	</body>
</html>
</cfoutput>