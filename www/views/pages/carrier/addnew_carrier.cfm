<cfoutput>
	<!---Init the default value------->	  
	<cfsilent>
 		<cfinvoke component="#variables.objloadGateway#" method="getSystemSetupOptions" returnvariable="request.qGetSystemSetupOptions" />
 		<cfset requireValidMCNumber = request.qGetSystemSetupOptions.requireValidMCNumber>			
 		<cfparam name="MCNumber" default=""> 
 		<cfparam name="carrierid" default="">  
	</cfsilent>
	<cfif isDefined("url.carrierid") and len(url.carrierid)>
		<div class="search-panel"><div class="delbutton"><a href="index.cfm?event=carrier&carrierid=#editid#&#session.URLToken#" onclick="return confirm('Are you sure to delete it ?','Delete Carrier');">  Delete</a></div></div>	
		<h1>Edit Carrier <span style="padding-left:180px;">#Ucase(CarrierName)#</span></h1>
	<cfelse>
		<h1>Enter New Carrier</h1>
	</cfif>
 	<cfif isDefined("SaveContinue")>
 		<cfset messageHead='Please enter either MC## or DOT## to add new Carrier. If you dont have that use their phone## instead.'>
		<cfif isDefined("MCNumber") and len(trim(MCNumber)) gt 0>
         	<cfinvoke component="#request.cfcpath#.loadgateway" method="checkcarrierMCNumber" returnvariable="request.qcarrier"> 
         		<cfinvokeargument name="McNumber" value="#McNumber#">
         		<cfinvokeargument name="dsn" value="#application.dsn#">
         	</cfinvoke>
         	<cfif  request.qcarrier.recordcount gte 1>
            	<cfset carierid=request.qcarrier.CarrierID>
            	<cfset message='<a href="index.cfm?event=addcarrier&carrierid=#request.qCarrier.CarrierID#&#session.URLToken#&IsCarrier=1" style="text-decoration:font:bold;padding-left:96px;"> MC##  #McNumber# </a>'  &"ALREADY EXISTS">
         	<cfelse>
         		<cfif request.qGetSystemSetupOptions.CarrierLNI EQ 2>
     				<cfinvoke component="#request.cfcpath#.carriergateway" method="createViaCarrierLookout" MCNumber="#McNumber#" returnvariable="request.CarrierID">
     				<cfif len(trim(request.CarrierID)) EQ 36>
		         		<cflocation url="index.cfm?event=addcarrier&CarrierID=#request.CarrierID#&IsCarrier=1" addtoken="yes"> 
		         	<cfelse>
		         		<cflocation url="index.cfm?event=addcarrier&mcno=#trim(McNumber)#&IsCarrier=1" addtoken="yes"> 
		         	</cfif>
         		<cfelse>
	         		<cflocation url="index.cfm?event=addcarrier&mcno=#trim(McNumber)#&IsCarrier=1" addtoken="yes"> 
	         	</cfif>    
         	</cfif>  
		<cfelseif structKeyExists(form, "DOTNumber") and len(trim(DOTNumber)) gt 0>
         	<cfinvoke component="#request.cfcpath#.loadgateway" method="checkcarrierMCNumber" returnvariable="request.qcarrier"> 
         		<cfinvokeargument name="DOTNumber" value="#form.DOTNumber#">
         		<cfinvokeargument name="dsn" value="#application.dsn#">
        	</cfinvoke>

			<cfif  request.qcarrier.recordcount gte 1>
            	<cfset carierid=request.qcarrier.CarrierID>
            	<cfset message='<a href="index.cfm?event=addcarrier&carrierid=#request.qCarrier.CarrierID#&#session.URLToken#&IsCarrier=1" style="text-decoration:font:bold;padding-left:96px;"> Dot Number##  #form.DOTNumber# </a>'  &"ALREADY EXISTS">
         	<cfelse>
         		<cfif request.qGetSystemSetupOptions.CarrierLNI EQ 2>
         			<cfinvoke component="#request.cfcpath#.carriergateway" method="createViaCarrierLookout" DOTNumber='#trim(DOTNumber)#'returnvariable="request.CarrierID">
         			<cfif len(trim(request.CarrierID)) EQ 36>
	         			<cflocation url="index.cfm?event=addcarrier&CarrierID=#request.CarrierID#&IsCarrier=1" addtoken="yes"> 
	         		<cfelse>
		         		<cfif structKeyExists(session, "CreateViaCLError")>
		         			<cfset message=session.CreateViaCLError>
		         			<cfset structDelete(session, "CreateViaCLError")>
		         		<cfelse>
		         			<cflocation url="index.cfm?event=addcarrier&DOTNumber=#trim(DOTNumber)#&IsCarrier=1" addtoken="yes">  
			         	</cfif>
		         	</cfif>
         		<cfelse>
	        		<cflocation url="index.cfm?event=addcarrier&DOTNumber=#trim(DOTNumber)#&IsCarrier=1" addtoken="yes">  
	        	</cfif>      
         	</cfif> 
        <cfelseif structKeyExists(form, "CarrierName") and len(trim(CarrierName)) gt 0>
         	<cfinvoke component="#request.cfcpath#.loadgateway" method="checkcarrierMCNumber" returnvariable="request.qcarrier"> 
         		<cfinvokeargument name="CarrierName" value="#form.CarrierName#">
         		<cfinvokeargument name="dsn" value="#application.dsn#">
        	</cfinvoke>
        	<cfif  request.qcarrier.recordcount gte 1>
            	<cfset carierid=request.qcarrier.CarrierID>
            	<cfset message='<a href="index.cfm?event=addcarrier&carrierid=#request.qCarrier.CarrierID#&#session.URLToken#&IsCarrier=1" style="text-decoration:font:bold;padding-left:96px;"> Carrier  #form.CarrierName# </a>'  &"ALREADY EXISTS">
            <cfelse>
            	<cflocation url="index.cfm?event=addcarrier&LegalName=#trim(form.CarrierName)#&IsCarrier=1" addtoken="yes">
            </cfif>
	    <cfelseif not structKeyExists(form, "DOTNumber") and not len(trim(DOTNumber)) gt 0> 
	     	 <cflocation url="index.cfm?event=addcarrier&DOTNumber=" addtoken="yes">  
	    <cfelseif not structKeyExists(form, "MCNumber") and not len(trim(MCNumber)) gt 0>      
			 <cflocation url="index.cfm?event=addcarrier&mcno=" addtoken="yes">              
	    </cfif> 
	</cfif>
	<cfif not (isdefined("message") and len(message))>
		<cfif isdefined("messageHead") and len(messageHead)>
		<div class="msg-area" style="margin-left: 13px;">#messageHead#</div>
		</cfif>
	</cfif>

	<div class="white-con-area">
		<div class="white-top"></div>
		<div class="white-mid-carrier">
		 	<cfform name="frmNewCarrier" id="frmNewCarrier" action="index.cfm?event=addnewcarrier:process&#session.urltoken#&IsCarrier=1" method="post">
				<div class="form-con">
				 	<fieldset>
				   		<cfinput type="hidden" name="carrierid" id="carrierid" value="#carrierid#">
			       			<cfif isdefined("message") and len(message)>
			         			<div class="msg-carr">
						           	<div class="form-con">  
							           	<ul class="load-link">                                                           
							       			<li><font size="3">#message#</font></li>
				                       	</ul> 
			                       	</div>                        
			         			</div>
			       			</cfif>
					    <div class="clear"></div>
					   	<label class="DOTNumber" style="padding-left: 10px;"><span style="color:##448bc8;"><i>Please enter...</i></span>DOT ##</label>
                      	<cfinput name="DOTNumber" id="DOTNumber" type="text" value="" maxlength="50"/>
                      		
				        <label style="width:75px;"><span style="color:##448bc8;"><i>...OR...</i></span><span > MC ##</span></label>
						<cfif requireValidMCNumber EQ True>
                    	  <cfinput name="MCNumber" id="MCNumber" type="text" tabindex="1" maxlength="50" value="#MCNumber#"  />	
                    	<cfelse>
						  <cfinput name="MCNumber" id="MCNumber" type="text" tabindex="1" maxlength="50" value="#MCNumber#"  />
						</cfif>
						<cfif request.qGetSystemSetupOptions.CarrierLNI NEQ 3 AND request.qGetSystemSetupOptions.CarrierLNI NEQ 2 >
							<label style="width:130px;"><span style="color:##448bc8;"><i>...OR...</i></span><span> Company Name</span></label>
							<cfinput name="CarrierName" id="CompanyName" type="text" tabindex="1" maxlength="50" value="" style="width: 125px;" placeholder=" "/>
							<cfinput name="Address" id="location" type="hidden">
							<cfinput name="City" id="City" type="hidden">
							<cfinput name="StateValCODE" id="state" type="hidden">
							<cfinput name="Zipcode" id="Zipcode" type="hidden">
							<cfinput name="country1" id="country1" type="hidden">
						</cfif>
						<div class="clear"></div>
                        <cfinput name="SaveContinue" id="continue-btn" type="submit" class="normal-bttn" value="Continue>>"  onfocus="checkUnload();" style="margin-left: 740px; margin-top: -29px;width: 83px !important;"/>                    		 
                  	</fieldset>
				</div>						
				<div class="clear"></div>					
			</cfform>
			<div class="clear"></div>
		</div>					
		<div class="white-bot"></div>
	</div>
	<script type="text/javascript">
		$(document).ready(function(){
			$('##continue-btn').click(function(){
				var MCnum = $('##MCNumber').val();
				var DOTnum = $('##DOTNumber').val();

				<cfif NOT listFindNoCase("1,3", request.qGetSystemSetupOptions.CarrierLNI)>
					var CompanyName = $('##CompanyName').val();
					if(!MCnum.length && !DOTnum.length && CompanyName.length){
						$('##frmNewCarrier').attr('action', "index.cfm?event=addcarrier&#session.urltoken#");
					}
				</cfif>
				$('##continue-btn').hide();

			});
		});
	</script>
	<cfif request.qGetSystemSetupOptions.CarrierLNI NEQ 3 AND request.qGetSystemSetupOptions.GoogleAddressLookup>
		<script src="https://maps.googleapis.com/maps/api/js?key=AIzaSyBPOZyc0LQameJpMi8buq_z3kGwtyYj_Zk&libraries=places&callback=initAutocomplete"
	        async defer></script>
	    <script type="text/javascript">
	     	var input = document.getElementById('CompanyName');
			google.maps.event.addDomListener(input, 'keydown', function(event) { 
			if (event.keyCode === 13) { 
					event.preventDefault(); 
				}
			});
			
			var autocomplete;
			
			function initAutocomplete() {
			  // Create the autocomplete object, restricting the search predictions to
			  // geographical location types.
			  autocomplete = new google.maps.places.Autocomplete(
			      document.getElementById('CompanyName'), {types: ['establishment']});
				  
			  // Avoid paying for data that you don't need by restricting the set of
			  // place fields that are returned to just the address components.
			  //autocomplete.setFields(['address_component']);

			  // When the user selects an address from the drop-down, populate the
			  // address fields in the form.
			  autocomplete.addListener('place_changed', fillInAddress);
			}

			function fillInAddress() {
			  // Get the place details from the autocomplete object.
			  var place = autocomplete.getPlace();

			  // Get each component of the address from the place details,
			  // and then fill-in the corresponding field on the form.
			  
			  document.getElementById('CompanyName').value = place.name;
			  
			  var streetNo = '';
			  var loc = '';
			  var city = '';
			  var state = '';
			  var zip = '';
			  var country = '';
			  
			  console.log(place);

			  for (var i = 0; i < place.address_components.length; i++) {
			
			    var addressType = place.address_components[i].types[0];
			    var val = '';
				
				if(addressType == 'street_number'){
					streetNo = place.address_components[i]['short_name'];
				}
			    if(addressType == 'route'){
					loc = place.address_components[i]['long_name'];
			    }
			    if(addressType == 'locality'){
					city = place.address_components[i]['long_name'];
			    }
			    if(addressType == 'administrative_area_level_1'){
					state = place.address_components[i]['short_name'];
			    }
			    if(addressType == 'postal_code'){
					zip = place.address_components[i]['short_name'];
			    }
			    if(addressType == 'country'){
					country = place.address_components[i]['short_name'];
			    }
			  }
			  
			  if($.trim(streetNo).length){
				document.getElementById('location').value = streetNo+' '+loc;
			  }
			  else{
				document.getElementById('location').value = loc;
			  }
			  document.getElementById('City').value = city;
			  document.getElementById('state').value = state;
			  document.getElementById('Zipcode').value = zip;
			  document.getElementById('country1').value = country;
			  
			}

			// Bias the autocomplete object to the user's geographical location,
			// as supplied by the browser's 'navigator.geolocation' object.
			function geolocate() {
			  if (navigator.geolocation) {
			    navigator.geolocation.getCurrentPosition(function(position) {
			      var geolocation = {
			        lat: position.coords.latitude,
			        lng: position.coords.longitude
			      };
			      var circle = new google.maps.Circle(
			          {center: geolocation, radius: position.coords.accuracy});
			      autocomplete.setBounds(circle.getBounds());
			    });
			  }
			}

	    </script>   
	</cfif>
</cfoutput>	
