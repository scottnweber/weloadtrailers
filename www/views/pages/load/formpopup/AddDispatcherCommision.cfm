<cfoutput>
    <style>
	    ##popupDispatchercommision{
	        left: 27%;
	        top:35%;
	        background-color: #request.qSystemSetupOptions1.BackgroundColorForContent#;
	        width: 450px;
	    }
	</style>
    <script type="text/javascript">
        function openDispatcherCommisionPopup(){
			$('##frmAddDispatcherCommision')[0].reset();
			var Dispatcher = $('##Dispatcher').val();
			var DispatcherPer = $( "##Dispatcher option:selected" ).attr('data-per');
			var Dispatcher1 = $('##Dispatcher1').val();
            var Dispatcher2 = $('##Dispatcher2').val();
            var Dispatcher3 = $('##Dispatcher3').val();
            var Dispatcher1Percentage = $('##Dispatcher1Percentage').val();
            var Dispatcher2Percentage = $('##Dispatcher2Percentage').val();
            var Dispatcher3Percentage = $('##Dispatcher3Percentage').val();			
            var LockDispatcher2OnLoad = $('##LockDispatcher2OnLoad').val();			
			if($.trim(Dispatcher1).length){
				$('##fpDispatcher1').val(Dispatcher1);
			}else{
				$('##fpDispatcher1').val(Dispatcher);
			}
			if(LockDispatcher2OnLoad == 1){	
				$('##fpDispatcher2').css("pointer-events","none");
				$('##fpDispatcher2').css("opacity","0.5")
			}
            $('##fpDispatcher2').val(Dispatcher2);
            $('##fpDispatcher3').val(Dispatcher3);
            if(Dispatcher1Percentage != 0){
            	$('##fpDispatcher1per').val(Dispatcher1Percentage);
            }
            else{
            	$('##fpDispatcher1per').val(DispatcherPer);
            }
            $('##fpDispatcher2per').val(Dispatcher2Percentage);
            $('##fpDispatcher3per').val(Dispatcher3Percentage);
			$('body').addClass('formpopup-body-noscroll');
			$('.formpopup-overlay').show();
            $('##popupDispatchercommision').show();
        }

        function populateDispatcherPer(indx) {
        	var DispatcherPer = $( "##fpDispatcher"+indx+" option:selected" ).attr('data-per');
        	$('##fpDispatcher'+indx+'per').val(DispatcherPer);
        }

		function submitDispatcherCommisionForm() {
			var inputs = document.getElementById("frmAddDispatcherCommision").elements;
			
			var per1=$.trim($('##fpDispatcher1per').val());
			var per2=$.trim($('##fpDispatcher2per').val());
			var per3=$.trim($('##fpDispatcher3per').val());
			if(isNaN(per1) || !per1.length){
				alert('Invalid Commision %');
				$('##fpDispatcher1per').focus();
				return false;
			}
			if(isNaN(per2) || !per2.length){
				alert('Invalid Commision %');
				$('##fpDispatcher2per').focus();
				return false;
			}
			if(isNaN(per3) || !per3.length){
				alert('Invalid Commision %');
				$('##fpDispatcher3per').focus();
				return false;
			}

			<cfif structKeyExists(url, "LoadID") AND len(trim(url.LoadID)) AND url.LoadID NEQ 0>
				var formData = $("##frmAddDispatcherCommision").serialize();
				var path = urlComponentPath+"loadgateway.cfc?method=updateDispatcherCommission&LoadID=#url.LoadID#";
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
	                    	$('##Dispatcher1').val(inputs["fpDispatcher1"].value);
				            $('##Dispatcher2').val(inputs["fpDispatcher2"].value);
				            $('##Dispatcher3').val(inputs["fpDispatcher3"].value);
				            $('##Dispatcher1Percentage').val(inputs["fpDispatcher1per"].value);
				            $('##Dispatcher2Percentage').val(inputs["fpDispatcher2per"].value);
				            $('##Dispatcher3Percentage').val(inputs["fpDispatcher3per"].value);
	                        $('body').removeClass('formpopup-body-noscroll');
			                $( ".form-popup" ).hide();
			                $('.formpopup-overlay').hide();
	                    }
	                }
	            });
	        <cfelse>
	        	$('##Dispatcher1').val(inputs["fpDispatcher1"].value);
	            $('##Dispatcher2').val(inputs["fpDispatcher2"].value);
	            $('##Dispatcher3').val(inputs["fpDispatcher3"].value);
	            $('##Dispatcher1Percentage').val(inputs["fpDispatcher1per"].value);
	            $('##Dispatcher2Percentage').val(inputs["fpDispatcher2per"].value);
	            $('##Dispatcher3Percentage').val(inputs["fpDispatcher3per"].value);
                $('body').removeClass('formpopup-body-noscroll');
                $( ".form-popup" ).hide();
                $('.formpopup-overlay').hide();
			</cfif>
		}
    </script>
    <div class="form-popup" id="popupDispatchercommision">
        <div class="form-popup-header">
	        Dispatcher Commision
	        <span class="form-popup-close">&times;</span>
	    </div>
	    <div class="form-popup-content">
	    	<form name="frmAddDispatcherCommision" id="frmAddDispatcherCommision">
	    		<input type="hidden" name="dsn" id="dsn" value="#application.dsn#">
	     		<label>Dispatcher 1</label>
	            <select name="fpDispatcher1" id="fpDispatcher1" class="medium-select" onchange="populateDispatcherPer(1);">
	            	<option value="" data-per="0">Select</option>
	            	<cfloop query="request.qSalesPerson">
	                    <option value="#request.qSalesPerson.EmployeeID#" data-per="#request.qSalesPerson.SalesCommission#">#request.qSalesPerson.Name#</option>
	                </cfloop>
	            </select>
				<label <cfif NOT ListContains(session.rightsList,'addEditDeleteAgents',',')>style="display: none"</cfif>>Commision%</label>
				<input class="small-input NumericOnlyFields" type="text" name="fpDispatcher1per" id="fpDispatcher1per" <cfif NOT ListContains(session.rightsList,'addEditDeleteAgents',',')>style="display: none"</cfif>>
		        <div class="clear"></div>

		        <label>Dispatcher 2</label>
	            <select name="fpDispatcher2" id="fpDispatcher2" class="medium-select" onchange="populateDispatcherPer(2);">
	            	<option value="" data-per="0">Select</option>
	            	<cfloop query="request.qSalesPerson">
	                    <option value="#request.qSalesPerson.EmployeeID#" data-per="#request.qSalesPerson.SalesCommission#">#request.qSalesPerson.Name#</option>
	                </cfloop>
	            </select>
				<label <cfif NOT ListContains(session.rightsList,'addEditDeleteAgents',',')>style="display: none"</cfif>>Commision%</label>
				<input class="small-input NumericOnlyFields" type="text" name="fpDispatcher2per" id="fpDispatcher2per" <cfif NOT ListContains(session.rightsList,'addEditDeleteAgents',',')>style="display: none"</cfif>>
		        <div class="clear"></div>

		        <label>Dispatcher 3</label>
	            <select name="fpDispatcher3" id="fpDispatcher3" class="medium-select" onchange="populateDispatcherPer(3);">
	            	<option value="" data-per="0">Select</option>
	            	<cfloop query="request.qSalesPerson">
	                    <option value="#request.qSalesPerson.EmployeeID#" data-per="#request.qSalesPerson.SalesCommission#">#request.qSalesPerson.Name#</option>
	                </cfloop>
	            </select>
				<label <cfif NOT ListContains(session.rightsList,'addEditDeleteAgents',',')>style="display: none"</cfif>>Commision%</label>
				<input class="small-input NumericOnlyFields" type="text" name="fpDispatcher3per" id="fpDispatcher3per" <cfif NOT ListContains(session.rightsList,'addEditDeleteAgents',',')>style="display: none"</cfif>>
		        <div class="clear"></div>

	            <input type="button" name="closeDispatcherCommisionForm" class="actbttn" value="Save" style="margin-left: 100px;" onclick="submitDispatcherCommisionForm()">
		        <input type="button" class="actbttn form-popup-close" name="closeDispatcherCommisionForm" class="bttn" value="Close">
		        <img src="images/loadDelLoader.gif" class="fp-loader">
		    </form>
	    </div>
    </div>    
</cfoutput>