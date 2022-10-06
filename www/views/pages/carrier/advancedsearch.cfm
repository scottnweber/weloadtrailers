<cfoutput>
	<style>
		.normal-td{
			padding-left: 0;
		}
		.normal-td select{
			width: 100%;
		}
	</style>
	<script>
        $(document).ready(function(){
        	$(document).on('change', '.CL-Field', function () {
        		var PickUpState = $('##advSearch tr:last .PickUpState').val();
        		var DeliveryState = $('##advSearch tr:last .DeliveryState').val();
        		var EquipmentID = $('##advSearch tr:last .EquipmentID').val();

        		if(PickUpState!=0 || DeliveryState!=0  || EquipmentID!=0 ){
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
	<h1>Advanced Search</h1>   
	<cfform name="frmAdvanceSearch" action="index.cfm?event=CarrierAdvanced&#session.URLToken#&Iscarrier=1" method="post" preserveData="yes">
		<table width="50%" border="0" class="data-table" cellspacing="0" cellpadding="0">
	        <thead>
	            <tr>
	                <th align="center" valign="middle" class="head-bg" style="border-left: 1px solid ##5d8cc9;border-top-left-radius: 5px;height: 20px;">Pick State</th>
	                <th align="center" valign="middle" class="head-bg">Del State</th>
	                <th align="center" valign="middle" class="head-bg" width="50%">Equipment</th>
	                <th align="center" valign="middle" class="head-bg" style="border-top-right-radius: 5px;"></th>
	            </tr>
	        </thead>
	        <tbody id="advSearch">
	            <tr id="tr_1">
	                <td  align="left" valign="middle" nowrap="nowrap" class="normal-td" style="border-left: 1px solid ##5d8cc9;">
	                    <select name="PickUpState" class="PickUpState CL-Field">
	                        <option value="0">Select</option>
	                        <cfloop query="request.qStates">
								<option value="#request.qStates.statecode#">#request.qStates.statecode#</option>	
							</cfloop>  
	                    </select>
	                </td>
	                <td  align="left" valign="middle" nowrap="nowrap" class="normal-td">
	                    <select name="DeliveryState" class="DeliveryState CL-Field">
	                        <option value="0">Select</option>
	                        <cfloop query="request.qStates">
								<option value="#request.qStates.statecode#">#request.qStates.statecode#</option>	
							</cfloop>  
	                    </select>
	                </td>
	                <td  align="left" valign="middle" nowrap="nowrap" class="normal-td">
	                    <select name="EquipmentID" class="EquipmentID CL-Field">
	                        <option value="0">Select</option>
	                        <cfloop query="request.qEquipments">
								<option value="#request.qEquipments.EquipmentID#">#request.qEquipments.EquipmentName#</option>
							</cfloop>
	                    </select>
	                </td>
	                 <td  align="left" valign="middle" nowrap="nowrap" class="normal-td">
	                    <img onclick="delRow(this)" src="images/delete-icon.gif" style="width:10px;margin-left: 5px;cursor: pointer;">
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
	    <div class="white-con-area">
			<div class="white-top"></div>
			<div class="white-mid">				
				<div class="form-con" style="float: right;">
					<input name="searchsubmit" type="submit" class="bttn" onclick="return checkdate();" onclick="return checkLoad();" onfocus="checkUnload();" value="Search" style="width:96px;" />
					<input name="back" type="button" onclick="javascript:history.back();" class="bttn" value="Back" style="width:62px;" />
				</div>
			</div>
		</div>
	</cfform>
	<script>
		
	</script>	   
</cfoutput>