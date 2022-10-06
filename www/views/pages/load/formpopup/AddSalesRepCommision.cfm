<cfoutput>
	<style>
	    ##popup-add-salesrep-commision{
	        left: 27%;
	        top:35%;
	        background-color: #request.qSystemSetupOptions1.BackgroundColorForContent#;
	        width: 450px;
	    }
	</style>
	<script type="text/javascript">
		function openSalesRepCommisionPopup(){
			$('##frmAddSalesRepCommision')[0].reset();
			var Salesperson = $('##Salesperson').val();
			var SalespersonPer = $( "##Salesperson option:selected" ).attr('data-per');
			var SalesRep1 = $('##SalesRep1').val();
            var SalesRep2 = $('##SalesRep2').val();
            var SalesRep3 = $('##SalesRep3').val();
            var SalesRep1Per = $('##SalesRep1Percentage').val();
            var SalesRep2Per = $('##SalesRep2Percentage').val();
            var SalesRep3Per = $('##SalesRep3Percentage').val();
			if($.trim(SalesRep1).length){
				$('##fpSalesRep1').val(SalesRep1);
			}else{
				$('##fpSalesRep1').val(Salesperson);
			}
            $('##fpSalesRep2').val(SalesRep2);
            $('##fpSalesRep3').val(SalesRep3);
            if(SalesRep1Per != 0){
            	$('##fpSalesRep1Per').val(SalesRep1Per);
            }
            else{
            	$('##fpSalesRep1Per').val(SalespersonPer);
            }
            $('##fpSalesRep2Per').val(SalesRep2Per);
            $('##fpSalesRep3Per').val(SalesRep3Per);
			$('body').addClass('formpopup-body-noscroll');
			$('.formpopup-overlay').show();
			$('##popup-add-salesrep-commision').show();
		}

		function populateSalesRepPer(indx) {
        	var SalesRepPer = $( "##fpSalesRep"+indx+" option:selected" ).attr('data-per');
        	$('##fpSalesRep'+indx+'Per').val(SalesRepPer);
        }

		function submitSalesRepCommisionForm(){
	        var inputs = document.getElementById("frmAddSalesRepCommision").elements;
			var per1=$.trim($('##fpSalesRep1Per').val());
			var per2=$.trim($('##fpSalesRep2Per').val());
			var per3=$.trim($('##fpSalesRep3Per').val());
			if(isNaN(per1) || !per1.length){
				alert('Invalid Commision %');
				$('##fpSalesRep1Per').focus();
				return false;
			}
			if(isNaN(per2) || !per2.length){
				alert('Invalid Commision %');
				$('##fpSalesRep2Per').focus();
				return false;
			}
			if(isNaN(per3) || !per3.length){
				alert('Invalid Commision %');
				$('##fpSalesRep3Per').focus();
				return false;
			}
			<cfif structKeyExists(url, "LoadID") AND len(trim(url.LoadID)) AND url.LoadID NEQ 0>
				var formData = $("##frmAddSalesRepCommision").serialize();
				var path = urlComponentPath+"loadgateway.cfc?method=updateLoadRepCommission&LoadID=#url.LoadID#";
				$('.actbttn').hide();
				$('.fp-loader').show();
				$.ajax({
	                type: "Post",
	                url: path,
	                dataType: "json",
	                async: false,
	                data: formData,
	                success: function(success){
	                	$('.actbttn').show();
						$('.fp-loader').hide();
	                    if(success == 0){
	                        alert('Something went wrong. Please try again later.')
	                    }
	                    else{
	                    	$('##SalesRep1').val(inputs["fpSalesRep1"].value);
				            $('##SalesRep2').val(inputs["fpSalesRep2"].value);
				            $('##SalesRep3').val(inputs["fpSalesRep3"].value);
				            $('##SalesRep1Percentage').val(inputs["fpSalesRep1Per"].value);
				            $('##SalesRep2Percentage').val(inputs["fpSalesRep2Per"].value);
				            $('##SalesRep3Percentage').val(inputs["fpSalesRep3Per"].value);
	                        $('body').removeClass('formpopup-body-noscroll');
			                $( ".form-popup" ).hide();
			                $('.formpopup-overlay').hide();
	                    }
	                }
	            });
	        <cfelse>
	        	$('##SalesRep1').val(inputs["fpSalesRep1"].value);
	            $('##SalesRep2').val(inputs["fpSalesRep2"].value);
	            $('##SalesRep3').val(inputs["fpSalesRep3"].value);
	            $('##SalesRep1Percentage').val(inputs["fpSalesRep1Per"].value);
				$('##SalesRep2Percentage').val(inputs["fpSalesRep2Per"].value);
				$('##SalesRep3Percentage').val(inputs["fpSalesRep3Per"].value);
                $('body').removeClass('formpopup-body-noscroll');
                $( ".form-popup" ).hide();
                $('.formpopup-overlay').hide();
			</cfif>
		}
	</script>
	<div class="form-popup" id="popup-add-salesrep-commision">
	    <div class="form-popup-header">
	        Split Commision
	        <span class="form-popup-close">&times;</span>
	    </div>
	    <div class="form-popup-content">
	    	<form name="frmAddSalesRepCommision" id="frmAddSalesRepCommision">
	    		<input type="hidden" name="dsn" id="dsn" value="#application.dsn#">
	     		<label>Sales Rep 1</label>
	            <select name="fpSalesRep1" id="fpSalesRep1" class="medium-select" onchange="populateSalesRepPer(1)">
	            	<option value="" data-per="0">Select</option>
	            	<cfloop query="request.qSalesPerson">
	                    <option value="#request.qSalesPerson.EmployeeID#" data-per="#request.qSalesPerson.SalesCommission#">#request.qSalesPerson.Name#</option>
	                </cfloop>
	            </select>
	            <label <cfif NOT ListContains(session.rightsList,'addEditDeleteAgents',',')>style="display: none"</cfif>>Commision%</label>
	            <input class="small-input NumericOnlyFields" type="text" name="fpSalesRep1Per" id="fpSalesRep1Per" <cfif NOT ListContains(session.rightsList,'addEditDeleteAgents',',')>style="display: none"</cfif>>
		        <div class="clear"></div>

		        <label>Sales Rep 2</label>
	            <select name="fpSalesRep2" id="fpSalesRep2" class="medium-select" onchange="populateSalesRepPer(2)">
	            	<option value="" data-per="0">Select</option>
	            	<cfloop query="request.qSalesPerson">
	                    <option value="#request.qSalesPerson.EmployeeID#" data-per="#request.qSalesPerson.SalesCommission#">#request.qSalesPerson.Name#</option>
	                </cfloop>
	            </select>
	            <label <cfif NOT ListContains(session.rightsList,'addEditDeleteAgents',',')>style="display: none"</cfif>>Commision%</label>
	            <input class="small-input NumericOnlyFields" type="text" name="fpSalesRep2Per" id="fpSalesRep2Per" <cfif NOT ListContains(session.rightsList,'addEditDeleteAgents',',')>style="display: none"</cfif>>
		        <div class="clear"></div>

		        <label>Sales Rep 3</label>
	            <select name="fpSalesRep3" id="fpSalesRep3" class="medium-select" onchange="populateSalesRepPer(3)">
	            	<option value="" data-per="0">Select</option>
	            	<cfloop query="request.qSalesPerson">
	                    <option value="#request.qSalesPerson.EmployeeID#" data-per="#request.qSalesPerson.SalesCommission#">#request.qSalesPerson.Name#</option>
	                </cfloop>
	            </select>
	            <label <cfif NOT ListContains(session.rightsList,'addEditDeleteAgents',',')>style="display: none"</cfif>>Commision%</label>
	            <input class="small-input NumericOnlyFields" type="text" name="fpSalesRep3Per" id="fpSalesRep3Per" <cfif NOT ListContains(session.rightsList,'addEditDeleteAgents',',')>style="display: none"</cfif>>
		        <div class="clear"></div>

	            <input type="button" name="saveSalesRepCommisionForm" class="actbttn" value="Save" style="margin-left: 100px;" onclick="submitSalesRepCommisionForm()">
		        <input type="button" class="actbttn form-popup-close" name="closeSalesRepCommisionForm" class="bttn" value="Close">
		        <img src="images/loadDelLoader.gif" class="fp-loader">
		    </form>
	    </div>
	</div>
</cfoutput>