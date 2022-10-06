<cfoutput>
	<style>
	    ##popup-add-new-customer{
	        left: 27%;
	        background-color: #request.qSystemSetupOptions1.BackgroundColorForContent#;
	        width: 450px;
	    }
	</style>
	<script type="text/javascript">
		function openAddNewCustomerPopup(){
			$('##frmAddNewCustomer')[0].reset();
			$('body').addClass('formpopup-body-noscroll');
			$('.formpopup-overlay').show();
			$('##popup-add-new-customer').show();
			var fpKey = $('##cutomerIdAuto').val();
			$('##fpCustomerName').val(fpKey).focus();
		}

		function submitCustomerForm(){
			if(!$.trim($('##fpCustomerName').val()).length){
	            alert('Please Enter Customer Name.');
	            $('##fpCustomerName').focus();
	            return false;
	        }
	        var inputs = document.getElementById("frmAddNewCustomer").elements;
			var formData = $("##frmAddNewCustomer").serialize();
			var path = urlComponentPath+"loadgateway.cfc?method=saveCustFromLoadScreen";
			$('.actbttn').hide();
			$('.fp-loader').show();
			$.ajax({
                type: "Post",
                url: path,
                dataType: "json",
                async: false,
                data: formData,
                success: function(data){
                	$('.actbttn').show();
					$('.fp-loader').hide();
                    if(data.SUCCESS == 0){
                        alert('Something went wrong. Please try again later.')
                    }
                    else{
                        $('##cutomerIdAuto').val(inputs["fpCustomerName"].value);
                        $('##cutomerIdAutoValueContainer').val(data.ID);

                        var strHtml ="<div id='CustInfo1'>";
                        var strHtml ="<input name='customerAddress' id='customerAddress' type='hidden' value='"+inputs["fpCustomerAddress"].value+"'/>";
                        strHtml = strHtml +"<input name='customerCity' id='customerCity' type='hidden' value='"+inputs["fpCustomerCity"].value+"'/>";
                        strHtml = strHtml +"<input name='customerState' id='customerState' type='hidden' value='"+inputs["fpCustomerState"].value+"'/>";
                        strHtml = strHtml +"<input name='customerZipCode' id='customerZipCode' type='hidden' value='"+inputs["fpCustomerZip"].value+"'/>";
                        strHtml = strHtml +"<input name='customerContact' id='customerContact' type='hidden' value='"+inputs["fpCustomerContact"].value+"'/>";
                        strHtml = strHtml +"<input style='width: 89px' name='customerPhone' id='customerPhone' type='hidden' value='"+inputs["fpCustomerPhone"].value+"'/>";
                        strHtml = strHtml +"<input name='customerCell' id='customerCell' type='hidden' value=''/>";
                        strHtml = strHtml +"<input name='customerFax' id='customerFax' type='hidden' value='"+inputs["fpCustomerFax"].value+"'/>";
                        strHtml = strHtml +"<input name='CustomerEmail' id='CustomerEmail' type='hidden' value='"+inputs["fpCustomerEmail"].value+"'/>";
                        strHtml = strHtml +"<input name='customerPayer' id='customerPayer' type='hidden' value='1'/>";
                        strHtml = strHtml +"<input name='shipIsPayer' id='shipIsPayer' type='hidden' value='1'/>";
                        strHtml = strHtml +"<input name='customerDefaultCurrency' id='customerDefaultCurrency' type='hidden' value=''/>";
                        <cfif listFindNoCase(session.rightsList, 'addEditLoadOnly')>
                        strHtml = strHtml + "<label class='field-textarea'><b>"+inputs["fpCustomerName"].value+"</b><br/>"+inputs["fpCustomerAddress"].value+"<br/>"+inputs["fpCustomerCity"].value+", "+inputs["fpCustomerState"].value+" "+inputs["fpCustomerZip"].value+"</label>"
                        <cfelse>
                            strHtml = strHtml + "<label class='field-textarea'><b><a style='text-decoration: underline;' target='_blank' href=index.cfm?event=addcustomer&customerid="+data.ID+" >"+inputs["fpCustomerName"].value+"</a></b><br/>"+inputs["fpCustomerAddress"].value+"<br/>"+inputs["fpCustomerCity"].value+", "+inputs["fpCustomerState"].value+" "+inputs["fpCustomerZip"].value+"</label>"
                        </cfif>


                        strHtml = strHtml + "<div class='clear'></div>"
		                strHtml = strHtml + "<label>Contact</label><input name='customerContact' value='"+inputs["fpCustomerContact"].value+"'>"
		                strHtml = strHtml + "<div class='clear'></div>"
		                strHtml = strHtml + "<label>Tel</label>"
		                strHtml = strHtml + "<input name='customerPhone' value='"+inputs["fpCustomerPhone"].value+"' style='width: 89px'>"
                        strHtml = strHtml + "<label class='space_load'>Ext</label>"
                        strHtml = strHtml + "<input name='customerPhoneExt' value='"+inputs["fpCustomerPhoneExt"].value+"' style='width: 31px'>"
                		strHtml = strHtml + "<div class='clear'></div>"
		                strHtml = strHtml + "<label>Cell</label>"
		                strHtml = strHtml + "<input name='customerCell' value='' style='width: 90px'>"
		                strHtml = strHtml + "<label class='space_load'>Fax</label>"
		                strHtml = strHtml + "<input name='customerFax' value='"+inputs["fpCustomerFax"].value+"' style='width: 90px'>"
		                strHtml = strHtml + "<div class='clear'></div>"
		                strHtml = strHtml + "<label>Email</label>"
		                strHtml = strHtml + "<input name='CustomerEmail' value='"+inputs["fpCustomerEmail"].value+"' style='width: 248px'>"
		                strHtml = strHtml + "<div class='clear'></div>"
		                strHtml = strHtml + "<div class='clear'></div>"
		                strHtml = strHtml + "</div>";
                        $('##CustInfo1').html(strHtml);
                        <cfif structkeyexists(url,"loadid") and url.loadid eq 0 >
                            $('##Dispatcher').val(inputs["fpCustomerSalesRep"].value);
                            $('##Salesperson').val(inputs["fpCustomerDispatcher"].value);
                        </cfif>
                        $('body').removeClass('formpopup-body-noscroll');
		                $( ".form-popup" ).hide();
		                $('.formpopup-overlay').hide();
                    }
                }
            });

		}
	</script>
	<div class="form-popup" id="popup-add-new-customer">
	    <div class="form-popup-header">
	        Add New Customer
	        <span class="form-popup-close">&times;</span>
	    </div>
	    <div class="form-popup-content">
	    	<form name="frmAddNewCustomer" id="frmAddNewCustomer">
	    		<input type="hidden" name="dsn" id="dsn" value="#application.dsn#">
	    		<input type="hidden" name="adminUserName" id="adminUserName" value="#session.adminUserName#">
	    		<input type="hidden" name="EmpID" id="adminUserName" value="#session.EmpID#">
	    		<input type="hidden" name="sesCmpID" id="sesCmpID" value="#session.CompanyID#">
	        	<label>Name*</label>
	            <input type="text" name="fpCustomerName" id="fpCustomerName" maxlength="100">
	            <div class="clear"></div>
	     		<label>Sales Rep</label>
	            <select name="fpCustomerSalesRep" id="fpCustomerSalesRep">
	            	<option value="">Select</option>
	            	<cfloop query="request.qSalesPerson">
	                    <option value="#request.qSalesPerson.EmployeeID#">#request.qSalesPerson.Name#</option>
	                </cfloop>
	            </select>
	            <div class="clear"></div>
	     		<label>Dispatcher</label>
	            <select name="fpCustomerDispatcher" id="fpCustomerDispatcher">
	            	<option value="">Select</option>
	            	<cfloop query="request.qSalesPerson">
	                    <option value="#request.qSalesPerson.EmployeeID#">#request.qSalesPerson.Name#</option>
	                </cfloop>
	            </select>
	            <div class="clear"></div>
	            <label>Address</label>
		        <textarea name="fpCustomerAddress" id="fpCustomerAddress" maxlength="200" style="font-family: Arial"></textarea>
		        <div class="clear"></div>
	            <label>City</label>
	            <input type="text" name="fpCustomerCity" id="fpCustomerCity" class="fpCityAuto" maxlength="50"  tabindex="-1">
	            <div class="clear"></div>
	            <label>State</label>
	            <select style="width: 100px;" name="fpCustomerState" id="fpCustomerState" class="fpStateAuto"  tabindex="-1">
	            	<option value="">Select</option>
	            	<cfloop query="request.qStates">
	                    <option value="#request.qStates.statecode#">#request.qStates.statecode#</option>
	                </cfloop>
	            </select>
	            <label style="width: 60px;">Zipcode</label>
	            <input type="text" style="width: 80px;" name="fpCustomerZip" id="fpCustomerZip" class="fpZipAuto" maxlength="50">
	            <div class="clear"></div>
	            <label>Contact</label>
	            <input type="text" name="fpCustomerContact" name="fpCustomerContact" maxlength="50">
	            <div class="clear"></div>
	            <label>Phone</label>
	            <input type="text" class="medium-input" name="fpCustomerPhone" name="fpCustomerPhone" onchange="ParseUSNumber(this,'Phone');" maxlength="50">
	            <label class="small-label">Ext.</label>
	            <input class="small-input" type="text" name="fpCustomerPhoneExt" name="fpCustomerPhoneExt"   maxlength="50">
	            <div class="clear"></div>
	            <label>Fax</label>
	            <input type="text" class="medium-input" name="fpCustomerFax" name="fpCustomerFax" onchange="ParseUSNumber(this,'Fax');" maxlength="50">
	            <label class="small-label">Ext.</label>
	            <input class="small-input" type="text" name="fpCustomerFaxExt" name="fpCustomerFaxExt" maxlength="50">
	            <div class="clear"></div>
	            <label>Email</label>
	            <input type="text" name="fpCustomerEmail" name="fpCustomerEmail">
	            <div class="clear"></div>
	            <input type="button" name="saveCustomerForm" class="actbttn" value="Save" style="margin-left: 100px;" onclick="submitCustomerForm()">
		        <input type="button" class="actbttn form-popup-close" name="closeCustomerForm" class="bttn" value="Close">
		        <img src="images/loadDelLoader.gif" class="fp-loader">
		    </form>
	    </div>
	</div>
</cfoutput>