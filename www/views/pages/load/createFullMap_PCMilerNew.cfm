
<cfparam name="URL.ShpAdd" default="," >
<cfparam name="url.ConAdd" default="," >

<cfparam name="url.currLocLat" default="">
<cfparam name="url.currLocLng" default="">
<cfparam name="url.currLocDateTime" default="">
<cfparam name="url.currLocDiver" default="">
<cfparam name="url.currLocEquipment" default="">
<cfset stops = "">
<cfset popup = "">
<cfset popups = "">

<cfloop from="1" to="10" index="x">					
	<cfif x EQ 1>
		<cfset i = "">
	<cfelse>
		<cfset i = x>
	</cfif>
	
	<cfif isdefined('URL.ShpAdd#i#') and Len(#trim(Evaluate('URL.ShpAdd#i#'))#) gt 5<!--- and #Evaluate('URL.ShpAdd#i#')# neq #Evaluate('URL.ShpAdd#variables.SubtByOne#')#---> >
		<cftry>
			<cfset temp = ListToArray("#URL['ShpAdd#i#']#", ",")>
			<!---<cfdump var="#Len(trim(Evaluate('URL.ShpAdd#i#')))#" >--->
			<cfif ArrayLen(temp) EQ 4 && trim(temp[2]) NEQ "" && trim(temp[4]) NEQ "">
				<cfhttp url="https://pcmiler.alk.com/apis/rest/v1.0/Service.svc/locations?street=#encodeForURL(temp[1])#&city=#encodeForURL(temp[2])#&state=#encodeForURL(temp[3])#&postcode=#encodeForURL(temp[4])#&postcodeFilter=us&list=1&region=NA&dataset=Current&authToken=9EE6B50B6A8FED4D8BA136C1CEDEC352">
			<!---<cfelseif ArrayLen(temp) EQ 3>
				<cfhttp url="https://pcmiler.alk.com/apis/rest/v1.0/Service.svc/locations?city=#encodeForURL(temp[1])#&state=#encodeForURL(temp[2])#&postcode=#encodeForURL(temp[3])#&postcodeFilter=us&list=1&region=NA&dataset=Current&authToken=9EE6B50B6A8FED4D8BA136C1CEDEC352">--->
			<cfelse>
				<cfthrow type="break">
			</cfif>
			<cfif structKeyExists(DeserializeJSON(cfhttp.filecontent)[1], "Coords")>		
				<cfset stops &= "new ALKMaps.LonLat(#DeserializeJSON(cfhttp.filecontent)[1].Coords.Lon#, #DeserializeJSON(cfhttp.filecontent)[1].Coords.Lat#),">				
				
				<cfsavecontent variable="popup">
					<cfoutput>
						var fpopup#x# = new ALKMaps.Popup.FramedCloud("FramedCloud1",
							new ALKMaps.LonLat(#DeserializeJSON(cfhttp.filecontent)[1].Coords.Lon#, #DeserializeJSON(cfhttp.filecontent)[1].Coords.Lat#).transform(new ALKMaps.Projection("EPSG:4326"), map.getProjectionObject()),
							new ALKMaps.Size(180, 800),
							"<p><b>Stop No.###x# | Shipper:</b> #URL['ShpNm#i#']#<br/><b>Address: </b>#URL['ShpAdd#i#']#<br/></p>",
							iconTruck,
							true        // Show close icon
						); 
						
						var mkrTruck#x# = new ALKMaps.Marker(
							new ALKMaps.LonLat(#DeserializeJSON(cfhttp.filecontent)[1].Coords.Lon#, #DeserializeJSON(cfhttp.filecontent)[1].Coords.Lat#).transform(new ALKMaps.Projection("EPSG:4326"), map.getProjectionObject()),
							iconTruck.clone(), 
							null, // Set label text to null in order not to show default label.
							{ 
								map: map,
								eventListeners:{            
									// Show popup when click on the marker icon
									"markerover": function(evt){	
										map.addPopup(fpopup#x#, true);              
										return false; // In order to cancel default marker over event handler
									},
								  "markerout": function(){
									map.removePopup(fpopup#x#);
								  }
								}
							}    
						);
						markerLayer.addMarker(mkrTruck#x#);
					</cfoutput>
				</cfsavecontent>
				<cfset popups &= popup>
			</cfif>
			
			<cfcatch type="break">
				<!--- DO NOTHING - THIS IS A HACK FOR NOT BEING ABLE TO USE CFBREAK inside cfoutput. --->
			</cfcatch>
		</cftry>
		 
	</cfif>
	<cfif isdefined('URL.ConAdd#i#') and Len(#trim(Evaluate('URL.ConAdd#i#'))#) gt 5>
		<cftry>
			<cfset temp = ListToArray("#URL['ConAdd#i#']#", ",", true)>		
			<cfif ArrayLen(temp) EQ 4 && trim(temp[2]) NEQ "" && trim(temp[4]) NEQ "">
				<cfhttp url="https://pcmiler.alk.com/apis/rest/v1.0/Service.svc/locations?street=#encodeForURL(temp[1])#&city=#encodeForURL(temp[2])#&state=#encodeForURL(temp[3])#&postcode=#encodeForURL(temp[4])#&postcodeFilter=us&list=1&region=NA&dataset=Current&authToken=9EE6B50B6A8FED4D8BA136C1CEDEC352">			
			<cfelse>
				<cfthrow type="break">
			</cfif>
			
			<cfif structKeyExists(DeserializeJSON(cfhttp.filecontent)[1], "Coords")>		
				<cfset stops &= "new ALKMaps.LonLat(#DeserializeJSON(cfhttp.filecontent)[1].Coords.Lon#, #DeserializeJSON(cfhttp.filecontent)[1].Coords.Lat#),">
				
				<cfsavecontent variable="popup">
					<cfoutput>
						var fpopupCon#x# = new ALKMaps.Popup.FramedCloud("FramedCloud1",
							new ALKMaps.LonLat(#DeserializeJSON(cfhttp.filecontent)[1].Coords.Lon#, #DeserializeJSON(cfhttp.filecontent)[1].Coords.Lat#).transform(new ALKMaps.Projection("EPSG:4326"), map.getProjectionObject()),
							new ALKMaps.Size(180, 800),
							"<p><b>Stop No.###x# | Consignee:</b> #URL['ConNm#i#']#<br/><b>Address: </b>#URL['ConAdd#i#']#<br/></p>",
							iconTruck,
							true        // Show close icon
						); 
						
						var mkrTruckCon#x# = new ALKMaps.Marker(
							new ALKMaps.LonLat(#DeserializeJSON(cfhttp.filecontent)[1].Coords.Lon#, #DeserializeJSON(cfhttp.filecontent)[1].Coords.Lat#).transform(new ALKMaps.Projection("EPSG:4326"), map.getProjectionObject()),
							iconTruck.clone(), 
							null, // Set label text to null in order not to show default label.
							{ 
								map: map,
								eventListeners:{            
									// Show popup when click on the marker icon
									"markerover": function(evt){	
										map.addPopup(fpopupCon#x#, true);              
										return false; // In order to cancel default marker over event handler
									},
								  "markerout": function(){
									map.removePopup(fpopupCon#x#);
								  }
								}
							}    
						);
						markerLayer.addMarker(mkrTruckCon#x#);
					</cfoutput>
				</cfsavecontent>
				<cfset popups &= popup>
			</cfif>
			<cfcatch type="break">
				<!--- DO NOTHING - THIS IS A HACK FOR NOT BEING ABLE TO USE CFBREAK inside cfoutput. --->
			</cfcatch>
		</cftry>
		
	</cfif>
</cfloop>

<cfoutput>
	<html>
	<head>
	<script src="https://maps.alk.com/api/1.2/ALKMaps.js" type="text/javascript"></script>
	<script>
	function init() {
		ALKMaps.APIKey = "#request.qGetSystemSetupOptions.PCMilerAPIKey#";
		
						
		var map = new ALKMaps.Map("map");
		var layer = new ALKMaps.Layer.BaseMap( "ALK Maps", {}, {displayInLayerSwitcher: false});
		map.addLayer(layer);
		
		//Routing
		var routingLayer = new ALKMaps.Layer.Routing( "Route Layer", {
			originURL: ALKMaps.IMAGE.TRUCK_BLUE,
			waypointURL: ALKMaps.IMAGE.TRUCK_GRAY,
			destinationURL: ALKMaps.IMAGE.TRUCK_RED
		} );
		map.addLayer(routingLayer);
		
		<cfif len(stops) GT 70>
			var stops = [
						#Left(stops, len(stops)-1)#
					//new ALKMaps.LonLat(-75.173297, 39.942892),//bin
					//new ALKMaps.LonLat(-74.438942, 40.362469)
				];					
			stops = ALKMaps.LonLat.transformArray(stops, new ALKMaps.Projection("EPSG:4326"), map.getProjectionObject());
			routingLayer.addRoute({
				stops: stops,
				functionOptions:{
					style: {
						arrows: "line",
						arrowSize: "100%",
						arrowSpacing: 50
					},
					showHandles: false,
				},
				routeOptions: {
					highwayOnly: false, 
					tollDiscourage: true
				},
				reportOptions: {}
			});
		</cfif>
		
		
		//Marker
		var markerLayer = new ALKMaps.Layer.Markers("Marker Layer");
		map.addLayer(markerLayer);
							
		var iconTruck = new ALKMaps.Icon(ALKMaps.IMAGE.TRUCK_GREEN, new ALKMaps.Size(30,30));
		
		#popups#
		
		//Center
		<cfif isDefined("cfhttp") && structKeyExists(DeserializeJSON(cfhttp.filecontent)[1], "Coords")>
			map.setCenter(new ALKMaps.LonLat(#DeserializeJSON(cfhttp.filecontent)[1].Coords.Lon#, #DeserializeJSON(cfhttp.filecontent)[1].Coords.Lat#).transform(new ALKMaps.Projection("EPSG:4326"), map.getProjectionObject()), 9);
		</cfif>

	}
	</script>
	</head>
	<body onLoad="init()">
	
	<cfif stops NEQ "">
		<div id="map" style="width:100%; height:100%"></div>
	<cfelse>
		No Stops or only unidentifiable stops are present in this load.
	</cfif>
	</body>
	</html>
</cfoutput>



<!----//stops
		var stops = [];
		function getLatLongOfStops(stop){
			ALKMaps.Geocoder.geocode({
				address:{
					addr: shipperStreet, 
					city: shipperCity, 
					state: shipperState, 
					region: "NA" //Valid values are NA, EU, OC, SA, AS, AF, and ME. Default is NA.
				},
				listSize: 1, //Optional. The number of results returned if the geocoding service finds multiple matches.
				success: function(response){
					stopFirst.lat = response[0].Coords.Lat;
					stopFirst.lon = response[0].Coords.Lon;
				},					
				failure: function(response){
					//alert(response.status + "\n" +response.statusText + "\n" + response.responseText);
					if(stopid==""){
						alert("System cannot calculate the miles for Stop1 because the address is not recognised");
					}else{
						alert("System cannot calculate the miles for Stop"+stopid+" because the address is not recognised");
					}	
				}
			});
		}
		
		var stops = [
				<cfloop from="2" to="10" index="i">					
					<cfif isdefined('URL.ShpAdd#i#') and Len(#trim(Evaluate('URL.ShpAdd#i#'))#) gt 3 <!---and #Evaluate('URL.ShpAdd#i#')# neq #Evaluate('URL.ShpAdd#variables.SubtByOne#')# --->>
						
					</cfif>
					<cfif isdefined('URL.ConAdd#i#') and Len(#trim(Evaluate('URL.ConAdd#i#'))#) gt 3>
						
					</cfif>
				</cfloop>
				new ALKMaps.LonLat(-75.173297, 39.942892),//bin
				new ALKMaps.LonLat(-74.998242, 39.924469),
				new ALKMaps.LonLat(-74.438942, 39.362469)
			];
			--->