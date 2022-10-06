<!--- from:2 executive blvd, 10901 to:100 broadway, ny, ny to:14 Avenue R, Brooklyn, NY 11223 --->
<cfajaximport params="#{googlemapkey='AIzaSyAMvv7YySXPntllOqj7509OH-9N3HgCJmw'}#">
<cfset theAddress = "Lafayette, LA">

<cfparam name="URL.ShpAdd" default="," >
<cfparam name="url.ConAdd" default="," >

<cfparam name="url.currLocLat" default="">
<cfparam name="url.currLocLng" default="">
<cfparam name="url.currLocDateTime" default="">
<cfparam name="url.currLocDiver" default="">
<cfparam name="url.currLocEquipment" default="">

<cfparam name="url.deviceid" default="">
<cfparam name="url.positionid" default="">

<cfset ArrGPSDataPoints = arrayNew(1)>

<cfif len(trim(url.deviceid)) AND len(trim(url.positionid))>
	<cfquery name="qGPSDataPoints" datasource="ZGPSTrackingMPWeb">
		SELECT P.Latitude, P.Longitude, FORMAT(P.servertime , 'MM/dd/yyyy HH:mm:ss') as ServerTime
		FROM Positions P
		WHERE P.DeviceID = <cfqueryparam value="#url.DeviceID#" cfsqltype="cf_sql_varchar">
		AND P.ID <> <cfqueryparam value="#url.positionid#" cfsqltype="cf_sql_varchar">
		GROUP BY P.Latitude, P.Longitude,P.servertime
		ORDER BY P.servertime
	</cfquery>

	<cfloop query="qGPSDataPoints">
		<cfset tempStruct = structNew()>
		<cfset tempStruct['Latitude'] = qGPSDataPoints.Latitude>
		<cfset tempStruct['Longitude'] = qGPSDataPoints.Longitude>
		<cfset tempStruct['ServerTime'] = qGPSDataPoints.ServerTime>
		<cfset tempStruct['Address'] = ''>
		<cfset arrayAppend(ArrGPSDataPoints, tempStruct)>
	</cfloop>
</cfif>
<html>

<head>
<style>

#directionsPanel {
    /*width:500px;*/
	width:290px;
    height: 100%;
    overflow: auto;

}

 .hilight {
         font-weight: bold;
      }
      .hilight, .lolight {
         background-color: white;
         height: 18px;
         width:58px;
		 border-style: solid;
         border-color: black;
         border-width: 2px 1px 1px 2px;
         padding-bottom: 2px;
         font-family: arial, sans-serif;
         font-size: 12px;
      }


</style>

	<script type="text/javascript" src="https://ajax.googleapis.com/ajax/libs/jquery/1/jquery.min.js"></script>
  <script src="https://maps.google.com/maps/api/js?sensor=false&key=AIzaSyA2yTYFWaiOSM-kaPp6fdPEOUuTEQWT3Xg" type="text/javascript"></script>

	<cfhttp url="https://maps.googleapis.com/maps/api/geocode/xml?address=#URL.ShpAdd#&sensor=false"  method="get"  result="geoCode" />

    <cfset geoCodeXML = xmlParse(geoCode.fileContent)>

	<cfif geoCodeXML.GeocodeResponse[1].status.XmlText EQ 'OK'>
		<cfset centerLatitude  = geoCodeXML.GeocodeResponse[1].XmlChildren[2].geometry.location.lat.XmlText>
		<cfset centerlLongitude = geoCodeXML.GeocodeResponse[1].XmlChildren[2].geometry.location.lng.XmlText>
	<cfelse>
		<cfset centerLatitude  = '' >
		<cfset centerlLongitude = '' >
	</cfif>

</head>

<body>

<div style="width: 100%;">
 <div style="width: 22%; height: 100%; float: left;">
 	<div style="text-align:center; padding-top:8px;">
		<form name="me" action="" method="post">
			<input name="button" type="button" id="doDirections" value="Get Directions" onClick="calcRoute()" />
			<cfoutput>
			<input type="hidden" name="centerLatitude" id="centerLatitude" value="#centerLatitude#"  >
			<input type="hidden" name="centerlLongitude" id="centerlLongitude" value="#centerlLongitude#"  >
			</cfoutput>

		</form>
	</div>
 	<div id="directionsPanel"></div>
 </div>
 <div id="panel" style="width:78%; float: left;">
	  <div id="themap" style="width: 100%; height: 100%;"></div>

 </div>
</div>

  <script language="javascript">
    var directionDisplay;
    var directionsService = new google.maps.DirectionsService();
	var map;
    var trafficLayer = null;
	var currentLayer = null;

  	jQuery(document).ready(function() {
  		<cfif structKeyExists(url, "getdirection")>
  			calcRoute();
  		</cfif>
		directionsDisplay = new google.maps.DirectionsRenderer();
		<cfoutput>
		var addrs = [ "#replaceNoCase(replaceNoCase(URL.ConAdd, chr(13), ' ','All'), chr(10), ' ','All')#|Stop No. : 1|#URL.ConNm#"
			<cfif isdefined("URL.ShpAdd2") and Len(#trim(URL.ShpAdd2)#) gt 3 and #URL.ShpAdd2# neq #URL.ShpAdd# >
				 ,"#replaceNoCase(replaceNoCase(URL.ShpAdd2, chr(13), ' ','All'), chr(10), ' ','All')#|Stop No. : 2|Shipper|#URL.ShpNm2#"
			</cfif>
			<cfloop from="3" to="10" index="i">
				<cfset variables.SubtByOne=0>
				<cfset variables.SubtByOne=val(variables.SubtByOne)+(i-1)>
				<cfif isdefined('URL.ShpAdd#i#') and Len(#trim(Evaluate('URL.ShpAdd#i#'))#) gt 3 and #Evaluate('URL.ShpAdd#i#')# neq #Evaluate('URL.ShpAdd#variables.SubtByOne#')# >
					 ,"#replaceNoCase(replaceNoCase(Evaluate('URL.ShpAdd#i#'), chr(13), ' ','All'), chr(10), ' ','All')#|Stop No. : #i#|Shipper|#Evaluate('URL.ShpNm#i#')#"
				</cfif>
				<cfif isdefined('URL.ConAdd#i#') and Len(#trim(Evaluate('URL.ConAdd#i#'))#) gt 3>
					,"#replaceNoCase(replaceNoCase(Evaluate('URL.ConAdd#i#'), chr(13), ' ','All'), chr(10), ' ','All')#|Stop No. : #i#|Consignee|#Evaluate('URL.ConNm#i#')#"
				</cfif>
			</cfloop>
			
		];

		</cfoutput>
		var markers = [];
		var marker_num = 0;
		// Process each address and get it's lat long
		var geocoder = new google.maps.Geocoder();
		var center = new google.maps.LatLngBounds();
		var infowindow = new google.maps.InfoWindow();
		var tempLAT;
		var tempLON;

		<cfoutput>  /**Current Position**/
		var #toScript(URL.currLocLat, "currLocLat")#;
		var #toScript(URL.currLocLng, "currLocLng")#;
		</cfoutput>

		if(document.getElementById('centerLatitude').value.length && document.getElementById('centerlLongitude').value.length){
			tempLAT = document.getElementById('centerLatitude').value;
			tempLON = document.getElementById('centerlLongitude').value;
		}else{
			if(currLocLat.length && currLocLng.length){
			
				tempLAT = currLocLat;
				tempLON =  currLocLng;
			}else{
				tempLAT = "";
				tempLON =  "";
			}
		}
		
		var myLatlng = new google.maps.LatLng(tempLAT, tempLON);

		var myOptions = {
		  zoom: 9,
		  center: myLatlng,
		  mapTypeId: google.maps.MapTypeId.ROADMAP
		}
		map = new google.maps.Map(document.getElementById("themap"), myOptions);

		trafficLayer = new google.maps.TrafficLayer();
		var statArray = [''];

		for(k=0;k<addrs.length;k++){
			//var addr = addrs[k];
			var addr = addrs[k].split("|");
			addr = addr[0];
			statArray[k] = '';
			geocoder.geocode({'address':addr},function(res,stat){
				if(stat==google.maps.GeocoderStatus.OK){
					statArray[k] = stat;
					// add the point to the LatLngBounds to get center point, add point to markers
					center.extend(res[0].geometry.location);
					markers[marker_num]=res[0].geometry.location;
					marker_num++;
					// actually display the map and markers, this is only done the last time
					if(k==addrs.length){
						directionsDisplay.setMap(map);
					    directionsDisplay.setPanel(document.getElementById("directionsPanel"));

						for(p=0;p<markers.length;p++){
							var mark = markers[p];
							addrsValues =  addrs[p].split("|")
							marker = new google.maps.Marker({
								title:addrsValues[1],
								map: map,
								position: mark
							});
							
						  <cfoutput>
						   google.maps.event.addListener(marker, 'click', (function(marker, p) {
							return function() {
							  addrsVal =  addrs[p].split("|");
							  if(addrsVal[1] == "Stop No. : 1")
							  {
							  	infowindow.setContent("<div  style='height:100px;width:500px;'> Load No. : #URL.loadNum#<br/> "+ addrsVal[1] + "<br/> Delivery Name : "+addrsVal[2] + "<br/> Delivery Address : "+addrsVal[0] +"</div>");
							  }
							  else
							  {
							  	if(addrsVal[2] == "Shipper")
							  	{
							  		infowindow.setContent("<div style='height:100px;width:500px;'> Load No. : #URL.loadNum#<br/> "+ addrsVal[1] + "<br/> Pickup Name : "+addrsVal[3] + "<br/> Pickup Address : "+addrsVal[0] +"</div>");
								}
								else
							  	{
							  		infowindow.setContent("<div style='height:100px;width:500px;'> Load No. : #URL.loadNum#<br/> "+ addrsVal[1] + "<br/> Delivery Name : "+addrsVal[3] + "<br/> Delivery Address : "+addrsVal[0] +"</div>");
								}
							  }
							  infowindow.open(map, marker);
							}
						  })(marker, p));
						  </cfoutput>
						}

    					
						for (prev = k; prev >= 0; prev--){
							if(prev > 0 && statArray[prev-1].length){
								// console.log(8888)
								map.fitBounds(center);
								break;
							}
						}
						// traffic button
					   var tbutton = document.createElement("button");
					   tbutton.innerHTML = "Traffic";
					   tbutton.style.position = "absolute";
					   tbutton.style.top = "6px";
					   tbutton.style.right = "112px";
					   tbutton.style.zIndex = 10;
					   tbutton.style.height="19px";
					   tbutton.style.width="55px";
					   map.getDiv().appendChild(tbutton);
					   tbutton.className = "lolight";
					   tbutton.onclick = function() {
					   	 traffic();
					     if (tbutton.className == "hilight") {
							  tbutton.className = "lolight";
						  } else {
							  tbutton.className = "hilight";
						  }
					   }

					}
				}else{
					console.log('Cannot find address');
				}
			});
		}
		if(tempLAT === ""){
			map.fitBounds(center);
		}

		/***** current location *****/
		/*40.944543 | Longitude: -74.075419
		* bronx Latitude: 40.844782 | Longitude: -73.864827
		* */
		var latlng = new google.maps.LatLng(currLocLat, currLocLng);
		//return false;
		geocoder.geocode({latLng: latlng},function(res,stat){

			if(stat==google.maps.GeocoderStatus.OK){
				center.extend(res[0].geometry.location);
				markers[marker_num]=res[0].geometry.location;

				var mark = markers[marker_num];
				marker = new google.maps.Marker({
					title:res[0].formatted_address,
					map: map,
					position: mark,
					icon: '../../../webroot/images/red-truck-tools.png',
				});
				<cfoutput>
				p = marker_num;
				google.maps.event.addListener(marker, 'click', (function(marker, p) {
					return function() {
				    	infowindow.setContent("<div style='height:100px;width:500px;'> <strong>Load No.:</strong> #URL.loadNum#<br/> <strong>Equipment Name:</strong> #URL.currLocEquipment#<br/> <strong>Driver Name:</strong> #url.currLocDiver# <br/> <strong>Date/Time: </strong>#url.currLocDateTime#</strong> <br/> <strong>Address: </strong>" + res[0].formatted_address + " </div>");
				    	infowindow.open(map, marker);
					}
				})(marker, p));
				</cfoutput>

				for (prev = k+1; prev >= 0; prev--){
					// console.log(prev + " : " + statArray[prev-1])
					if(prev > 0 && statArray[prev-1].length){
						// console.log(8888)
						map.fitBounds(center);
						break;
					}
				}


				// traffic button
			   var tbutton = document.createElement("button");
			   tbutton.innerHTML = "Traffic";
			   tbutton.style.position = "absolute";
			   tbutton.style.top = "6px";
			   tbutton.style.right = "112px";
			   tbutton.style.zIndex = 10;
			   tbutton.style.height="19px";
			   tbutton.style.width="55px";
			   map.getDiv().appendChild(tbutton);
			   tbutton.className = "lolight";
			   tbutton.onclick = function() {
			   	 traffic();
			     if (tbutton.className == "hilight") {
					  tbutton.className = "lolight";
				  } else {
					  tbutton.className = "hilight";
				  }
			   }

			}
		});
		/***** current location *****/


	
		var locations = <cfoutput>#serializeJSON(ArrGPSDataPoints)#</cfoutput>;

	    for (i = 0; i < locations.length; i++) {  
	    	if(i==0){
	    		var truckColor = 'green'
	    	}
	    	else{
	    		var truckColor = 'black'
	    	}
      		marker1 = new google.maps.Marker({
	        	position: new google.maps.LatLng(locations[i].Latitude, locations[i].Longitude),
	        	map: map,
	        	icon: '../../../webroot/images/'+truckColor+'-truck-tools.png',
	      
      		});

	      	google.maps.event.addListener(marker1, 'click', (function(marker1, i) {
		        return function() {

			        infowindow.setContent("<div style='height:100px;width:500px;'> <strong>Load No.:</strong> <cfoutput>#URL.loadNum#</cfoutput><br/> <strong>Equipment Name:</strong> <cfoutput>#URL.currLocEquipment#</cfoutput><br/> <strong>Driver Name:</strong> <cfoutput>#url.currLocDiver#</cfoutput> <br/> <strong>Date/Time: </strong>" + locations[i].ServerTime + "</strong> <br/> <strong>Address: </strong><span id='formatted_address"+i+"'></span> </div>");
			        infowindow.open(map, marker1);
			        setMarkerAddress(i)
		        }
	      	})(marker1, i));
    	}

    	function setMarkerAddress(i){
			var currLocLat = locations[i].Latitude;
			var currLocLng =  locations[i].Longitude;
			var currAddress = locations[i].Address
			var latlng = new google.maps.LatLng(currLocLat, currLocLng);

			if(!$.trim(currAddress).length){
				geocoder.geocode({latLng: latlng},function(res,stat){
					$('#formatted_address'+i).html(res[0].formatted_address);
					locations[i].Address = res[0].formatted_address;
				})
			}
			else{
				$('#formatted_address'+i).html(currAddress);
			}
		}
	});



    function traffic() {
		map.setCenter(new google.maps.LatLng(document.getElementById('centerLatitude').value, document.getElementById('centerlLongitude').value));
		map.setZoom(12);
		trafficLayer.setMap(map);
		currentLayer = trafficLayer;
	  }

	function calcRoute() {
	<cfoutput>
		var request = {
			origin: "#replaceNoCase(replaceNoCase(URL.ShpAdd, chr(13), ' ','All'), chr(10), ' ','All')#",
			<cfif isdefined("URL.ConAdd10") and Len(trim(URL.ConAdd10)) gt 3>
				destination: "#URL.ConAdd10#",
				<cfset variables.desinationValue = URL.ConAdd10>
			<cfelseif isdefined("URL.ShpAdd10") and Len(trim(URL.ShpAdd10)) gt 3>
				<cfif (URL.ShpAdd9) neq (URL.ShpAdd10)>
					destination: "#replaceNoCase(replaceNoCase(URL.ShpAdd10, chr(13), ' ','All'), chr(10), ' ','All')#",
					<cfset variables.desinationValue = URL.ShpAdd10>
				</cfif>
			<cfelseif isdefined("URL.ConAdd9") and Len(trim(URL.ConAdd9)) gt 3>
				destination: "#URL.ConAdd9#",
				<cfset variables.desinationValue = URL.ConAdd9>
			<cfelseif isdefined("URL.ShpAdd9") and Len(trim(URL.ShpAdd9)) gt 3>
				<cfif (URL.ShpAdd8) neq (URL.ShpAdd9)>
					destination: "#replaceNoCase(replaceNoCase(URL.ShpAdd9, chr(13), ' ','All'), chr(10), ' ','All')#",
					<cfset variables.desinationValue = URL.ShpAdd9>
				</cfif>
			<cfelseif isdefined("URL.ConAdd8") and Len(trim(URL.ConAdd8)) gt 3>
				destination: "#replaceNoCase(replaceNoCase(URL.ConAdd8, chr(13), ' ','All'), chr(10), ' ','All')#",
				<cfset variables.desinationValue = URL.ConAdd8>
			<cfelseif isdefined("URL.ShpAdd8") and Len(trim(URL.ShpAdd8)) gt 3>
				<cfif (URL.ShpAdd7) neq (URL.ShpAdd8)>
					destination: "#replaceNoCase(replaceNoCase(URL.ShpAdd8, chr(13), ' ','All'), chr(10), ' ','All')#",
					<cfset variables.desinationValue = URL.ShpAdd8>
				</cfif>
			<cfelseif isdefined("URL.ConAdd7") and Len(trim(URL.ConAdd7)) gt 3>
				destination: "#replaceNoCase(replaceNoCase(URL.ConAdd7, chr(13), ' ','All'), chr(10), ' ','All')#",
				<cfset variables.desinationValue = URL.ConAdd7>
			<cfelseif isdefined("URL.ShpAdd7") and Len(trim(URL.ShpAdd7)) gt 3>
				<cfif (URL.ShpAdd6) neq (URL.ShpAdd7)>
					destination: "#replaceNoCase(replaceNoCase(URL.ShpAdd7, chr(13), ' ','All'), chr(10), ' ','All')#",
					<cfset variables.desinationValue = URL.ShpAdd7>
				</cfif>
			<cfelseif isdefined("URL.ConAdd6") and Len(trim(URL.ConAdd6)) gt 3>
				destination: "#replaceNoCase(replaceNoCase(URL.ConAdd6, chr(13), ' ','All'), chr(10), ' ','All')#",
				<cfset variables.desinationValue = URL.ConAdd6>
			<cfelseif isdefined("URL.ShpAdd6") and Len(trim(URL.ShpAdd6)) gt 3>
				<cfif (URL.ShpAdd5) neq (URL.ShpAdd6)>
					destination: "#replaceNoCase(replaceNoCase(URL.ShpAdd6, chr(13), ' ','All'), chr(10), ' ','All')#",
					<cfset variables.desinationValue = URL.ShpAdd6>
				</cfif>
			<cfelseif isdefined("URL.ConAdd5") and Len(trim(URL.ConAdd5)) gt 3>
				destination: "#replaceNoCase(replaceNoCase(URL.ConAdd5, chr(13), ' ','All'), chr(10), ' ','All')#",
				<cfset variables.desinationValue = URL.ConAdd5>
			<cfelseif isdefined("URL.ShpAdd5") and Len(trim(URL.ShpAdd5)) gt 3>
				<cfif (URL.ShpAdd4) neq (URL.ShpAdd5)>
					destination: "#replaceNoCase(replaceNoCase(URL.ShpAdd5, chr(13), ' ','All'), chr(10), ' ','All')#",
					<cfset variables.desinationValue = URL.ShpAdd5>
				</cfif>
			<cfelseif isdefined("URL.ConAdd4") and Len(trim(URL.ConAdd4)) gt 3>
				destination: "#replaceNoCase(replaceNoCase(URL.ConAdd4, chr(13), ' ','All'), chr(10), ' ','All')#",
				<cfset variables.desinationValue = URL.ConAdd4>
			<cfelseif isdefined("URL.ShpAdd4") and Len(trim(URL.ShpAdd4)) gt 3>
				<cfif (URL.ShpAdd3) neq (URL.ShpAdd4)>
					destination: "#replaceNoCase(replaceNoCase(URL.ShpAdd4, chr(13), ' ','All'), chr(10), ' ','All')#",
					<cfset variables.desinationValue = URL.ShpAdd4>
				</cfif>
			<cfelseif isdefined("URL.ConAdd3") and Len(trim(URL.ConAdd3)) gt 3>
				destination: "#replaceNoCase(replaceNoCase(URL.ConAdd3, chr(13), ' ','All'), chr(10), ' ','All')#",
				<cfset variables.desinationValue = URL.ConAdd3>
			<cfelseif isdefined("URL.ShpAdd3") and Len(trim(URL.ShpAdd3)) gt 3>
			    <cfif (URL.ShpAdd2) neq (URL.ShpAdd3)>
					destination: "#replaceNoCase(replaceNoCase(URL.ShpAdd3, chr(13), ' ','All'), chr(10), ' ','All')#",
					<cfset variables.desinationValue = URL.ShpAdd3>
				</cfif>
			<cfelseif isdefined("URL.ConAdd2") and Len(trim(URL.ConAdd2)) gt 3>
				destination: "#replaceNoCase(replaceNoCase(URL.ConAdd2, chr(13), ' ','All'), chr(10), ' ','All')#",
				<cfset variables.desinationValue = URL.ConAdd2>
			<cfelseif isdefined("URL.ShpAdd2") and Len(trim(URL.ShpAdd2)) gt 3>
			    <cfif (URL.ShpAdd) neq (URL.ShpAdd2)>
					destination: "#replaceNoCase(replaceNoCase(URL.ShpAdd2, chr(13), ' ','All'), chr(10), ' ','All')#",
					<cfset variables.desinationValue = URL.ShpAdd2>
				</cfif>
			<cfelse>
		       destination: "#replaceNoCase(replaceNoCase(URL.ConAdd, chr(13), ' ','All'), chr(10), ' ','All')#",
			   <cfset variables.desinationValue = URL.ConAdd>
			</cfif>

		  	waypoints: [
				<cfset variables.locationContains = 0>
				<cfif variables.desinationValue NEQ URL.ConAdd>
					{ location:"#replaceNoCase(replaceNoCase(URL.ConAdd, chr(13), ' ','All'), chr(10), ' ','All')#" }
					<cfset variables.locationContains = 1>
				</cfif>


				<cfif isdefined("URL.ShpAdd2") and Len(trim(URL.ShpAdd2)) gt 3 AND variables.desinationValue NEQ URL.ShpAdd2>
					<cfif (URL.ShpAdd) neq (URL.ShpAdd2)>
						<cfif variables.locationContains EQ 1> , </cfif> <cfset variables.locationContains = 1>
						{ location:"#replaceNoCase(replaceNoCase(URL.ShpAdd2, chr(13), ' ','All'), chr(10), ' ','All')#" }
					</cfif>
				</cfif>

				<cfif isdefined("URL.ConAdd2") and Len(trim(URL.ConAdd2)) gt 3 AND variables.desinationValue NEQ URL.ConAdd2>
					<cfif variables.locationContains EQ 1> , </cfif> <cfset variables.locationContains = 1>
					{ location:"#replaceNoCase(replaceNoCase(URL.ConAdd2, chr(13), ' ','All'), chr(10), ' ','All')#" }
				</cfif>
				<cfloop from="3" to="10" index="i">
					<cfif isdefined("URL.ShpAdd#i#") and Len(trim(Evaluate('URL.ShpAdd#i#'))) gt 3 AND variables.desinationValue NEQ Evaluate('URL.ShpAdd#i#')>
						<cfset variables.SubtractedByOne=0>
						<cfset variables.SubtractedByOne=val(variables.SubtractedByOne)+(i-1)>
						<cfif ('URL.ShpAdd#variables.SubtractedByOne#') neq (Evaluate('URL.ShpAdd#i#'))>
							<cfif variables.locationContains EQ 1> , </cfif> <cfset variables.locationContains = 1>
							{ location:"#replaceNoCase(replaceNoCase(Evaluate('URL.ShpAdd#i#'), chr(13), ' ','All'), chr(10), ' ','All')#" }
						</cfif>
					</cfif>
					<cfif isdefined("URL.ConAdd#i#") and Len(trim(Evaluate('URL.ConAdd#i#'))) gt 3 AND variables.desinationValue NEQ Evaluate('URL.ConAdd#i#')>
						<cfif variables.locationContains EQ 1> , </cfif> <cfset variables.locationContains = 1>
						{ location:"#replaceNoCase(replaceNoCase(Evaluate('URL.ConAdd#i#'), chr(13), ' ','All'), chr(10), ' ','All')#" }
					</cfif>
				</cfloop>





			],
			provideRouteAlternatives: false,
			travelMode: google.maps.DirectionsTravelMode.DRIVING
		  </cfoutput>
		};
		directionsService.route(request, function(response, status) {
			console.log(response);
			console.log(status);
		
		  if (status == google.maps.DirectionsStatus.OK) {
			directionsDisplay.setDirections(response);
		  }
		});


		jQuery("#ext-gen6 div:nth-child(1) div div:nth-child(7) img").each(function(i){
			if($(this).attr('src') == 'http://chart.apis.google.com/chart?cht=mm&chs=32x32&chco=ffffff,009900,000000&ext=.png')
			{
				$(this).hide();
			}
		});

  }

  </script>



</body>
</html>
