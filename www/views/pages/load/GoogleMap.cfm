
<cfoutput>
	<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
	<html xmlns="http://www.w3.org/1999/xhtml">
		<head>
			<title>Load Manager TMS</title>
			<script type="text/javascript" src="https://ajax.googleapis.com/ajax/libs/jquery/1/jquery.min.js"></script>
  			<script src="https://maps.google.com/maps/api/js?sensor=false&key=AIzaSyA2yTYFWaiOSM-kaPp6fdPEOUuTEQWT3Xg" type="text/javascript"></script>

  			<script language="javascript">
  				<cfset ArrGPSDataPoints = arrayNew(1)>
				<cfloop query="qGPSDataPoints">
					<cfset tempStruct = structNew()>
					<cfset tempStruct['Latitude'] = qGPSDataPoints.Latitude>
					<cfset tempStruct['Longitude'] = qGPSDataPoints.Longitude>
					<cfset tempStruct['ServerTime'] = qGPSDataPoints.ServerTime>
					<cfset tempStruct['Address'] = ''>
					<cfset arrayAppend(ArrGPSDataPoints, tempStruct)>
				</cfloop>
				<cfset ArrStops = arrayNew(1)>
				<cfloop query="#qLoadDetails#">
					<cfset tempStruct = structNew()>
					<cfset tempStruct['StopNo'] = qLoadDetails.StopNo>
					<cfset tempStruct['LoadType'] = qLoadDetails.LoadType>
					<cfset tempStruct['CustName'] = qLoadDetails.CustName>
					<cfset tempStruct['Address'] = qLoadDetails.Address>
					<cfset tempStruct['City'] = qLoadDetails.City>
					<cfset tempStruct['StateCode'] = qLoadDetails.StateCode>
					<cfset tempStruct['PostalCode'] = qLoadDetails.PostalCode>
					<cfset tempStruct['ContactPerson'] = qLoadDetails.ContactPerson>
					<cfset tempStruct['Phone'] = qLoadDetails.Phone>
					<cfset arrayAppend(ArrStops, tempStruct)>
				</cfloop>
				var dataPoints = <cfoutput>#serializeJSON(ArrGPSDataPoints)#</cfoutput>;
				var ArrStops = <cfoutput>#serializeJSON(ArrStops)#</cfoutput>;
				var geocoder = new google.maps.Geocoder();
  				$(document).ready(function () {
			        
			        var center = new google.maps.LatLngBounds();
					
					var directionsService = new google.maps.DirectionsService();
					var infowindow = new google.maps.InfoWindow();
				    var centerLatLong = { lat: 0, lng: 0 };
				    map = new google.maps.Map(document.getElementById('map'), {
				        zoom: 12,
				        center: centerLatLong,
				        mapTypeId: google.maps.MapTypeId.ROADMAP
				    });
				    var directionsDisplay = new google.maps.DirectionsRenderer({map: map, suppressMarkers: true});
					var request = {
						origin: "#qLoadDetails.Address# #qLoadDetails.City#, #qLoadDetails.StateCode# #qLoadDetails.PostalCode#",
					    destination: "#qLoadDetails.Address[qLoadDetails.recordcount]# #qLoadDetails.City[qLoadDetails.recordcount]#, #qLoadDetails.StateCode[qLoadDetails.recordcount]# #qLoadDetails.PostalCode[qLoadDetails.recordcount]#",
					  	waypoints: [
					  		<cfset stopIndex = 1>
					  		<cfloop query="qLoadDetails">
					  			<cfif qLoadDetails.currentRow NEQ 1 AND qLoadDetails.currentRow NEQ qLoadDetails.recordcount>
					  				<cfif stopIndex NEQ 1>,</cfif>
					  				{ location:"#qLoadDetails.Address# #qLoadDetails.City#, #qLoadDetails.StateCode# #qLoadDetails.PostalCode#" }
					  				<cfset stopIndex++>
					  			</cfif>
					  			
					  		</cfloop>
					  	],
						provideRouteAlternatives: false,
						travelMode: google.maps.DirectionsTravelMode.DRIVING
					};
					directionsService.route(request, function(response, status) {
					  	if (status == google.maps.DirectionsStatus.OK) {
					  		for(i=0;i<response.routes[0].legs.length;i++){
					  			response.routes[0].legs[i].start_address = ArrStops[i].CustName + ' ' + response.routes[0].legs[i].start_address;
					  			response.routes[0].legs[i].end_address = ArrStops[i+1].CustName + ' ' + response.routes[0].legs[i].end_address;
					  		}
							directionsDisplay.setDirections(response);
							
							var my_route = response.routes[0];
							var routeLen = my_route.legs.length;
							for (var i = 0; i < routeLen; i++) {
								var Pos = my_route.legs[i].start_location;
								var LabelText = (i+1)+ArrStops[i].LoadType;
								var markerN = new google.maps.Marker({
				                    position: Pos,
				                    label:{text: LabelText, color: "white"},
				                    map: map
				                });
				                google.maps.event.addListener(markerN, 'click', (function(markerN, i) {
						         	return function() {
								    	var content = "<div>";
								    	content+= "Stop "+ArrStops[i].StopNo+ArrStops[i].LoadType+"<br>";
								    	content+= ArrStops[i].CustName+"<br>";
								    	if(ArrStops[i].Address.length){
								    		content+= ArrStops[i].Address+"<br>";
								    	}
								    	if(ArrStops[i].City.length){
								    		content+= ArrStops[i].City+", ";
								    	}
								    	if(ArrStops[i].StateCode.length){
								    		content+= ArrStops[i].StateCode+" ";
								    	}
								    	if(ArrStops[i].PostalCode.length){
								    		content+= ArrStops[i].PostalCode+"<br>";
								    	}
								    	if(ArrStops[i].ContactPerson.length){
								    		content+= ArrStops[i].ContactPerson+" ";
								    	}
								    	if(ArrStops[i].Phone.length){
								    		content+= ArrStops[i].Phone;
								    	}
								    	content+= "</div>";
								    	infowindow.setContent(content);
								        infowindow.open(map, markerN);
							         }
					      		})(markerN, i));
							}

							var Pos = my_route.legs[routeLen-1].end_location;
							var LabelText = (routeLen+1)+ArrStops[routeLen].LoadType;
							var markerN = new google.maps.Marker({
			                    position: Pos,
			                    label:{text: LabelText, color: "white"},
			                    map: map
			                });
			                google.maps.event.addListener(markerN, 'click', (function(markerN, i) {
					         	return function() {
							    	var content = "<div>";
							    	content+= "Stop "+ArrStops[i].StopNo+ArrStops[i].LoadType+"<br>";
							    	content+= ArrStops[i].CustName+"<br>";
							    	if(ArrStops[i].Address.length){
							    		content+= ArrStops[i].Address+"<br>";
							    	}
							    	if(ArrStops[i].City.length){
							    		content+= ArrStops[i].City+", ";
							    	}
							    	if(ArrStops[i].StateCode.length){
							    		content+= ArrStops[i].StateCode+" ";
							    	}
							    	if(ArrStops[i].PostalCode.length){
							    		content+= ArrStops[i].PostalCode+"<br>";
							    	}
							    	if(ArrStops[i].ContactPerson.length){
							    		content+= ArrStops[i].ContactPerson+" ";
							    	}
							    	if(ArrStops[i].Phone.length){
							    		content+= ArrStops[i].Phone;
							    	}
							    	content+= "</div>";
							    	infowindow.setContent(content);
							        infowindow.open(map, markerN);
						         }
				      		})(markerN, i));
							//directionsDisplay.setMap(map);
							directionsDisplay.setPanel(document.getElementById("directionsPanel"));
							var indx = 0;
							setTimeout(function() {
							    $( ".adp-marker2" ).each(function() {
							    	var iText = (indx+1)+ArrStops[indx].LoadType;
									indx++;
							    	$(this).attr('src','data:image/svg+xml,<svg%20xmlns%3D"http%3A//www.w3.org/2000/svg"%20xmlns%3Axlink%3D"http%3A//www.w3.org/1999/xlink"%20viewBox%3D"0%200%2027%2043"><defs><path%20id%3D"a"%20d%3D"M12.5%200C5.5961%200%200%205.5961%200%2012.5c0%201.8859.54297%203.7461%201.4414%205.4617%203.425%206.6156%2010.216%2013.566%2010.216%2022.195%200%20.46562.37734.84297.84297.84297s.84297-.37734.84297-.84297c0-8.6289%206.7906-15.58%2010.216-22.195.89844-1.7156%201.4414-3.5758%201.4414-5.4617%200-6.9039-5.5961-12.5-12.5-12.5z"/></defs><g%20fill%3D"none"%20fill-rule%3D"evenodd"><g%20transform%3D"translate%281%201%29"><use%20fill%3D"%23EA4335"%20xlink%3Ahref%3D"%23a"/><path%20d%3D"M12.5-.5c7.18%200%2013%205.82%2013%2013%200%201.8995-.52398%203.8328-1.4974%205.6916-.91575%201.7688-1.0177%201.9307-4.169%206.7789-4.2579%206.5508-5.9907%2010.447-5.9907%2015.187%200%20.74177-.6012%201.343-1.343%201.343s-1.343-.6012-1.343-1.343c0-4.7396-1.7327-8.6358-5.9907-15.187-3.1512-4.8482-3.2532-5.01-4.1679-6.7768-.97449-1.8608-1.4985-3.7942-1.4985-5.6937%200-7.18%205.82-13%2013-13z"%20stroke%3D"%23fff"/></g><text%20text-anchor%3D"middle"%20dy%3D".3em"%20x%3D"14"%20y%3D"15"%20font-family%3D"Roboto%2C%20Arial%2C%20sans-serif"%20font-size%3D"16px"%20fill%3D"%23FFF">'+iText+'</text></g></svg>')
							    })
							}, 1000);
					  	}
					});
					
					for (i = 0; i < dataPoints.length; i++) { 
						var j = i+1;
						if(i==0){
				    		var truckColor = 'green'
				    	}
				    	else if(j==dataPoints.length){
				    		var truckColor = 'red'
				    	}
				    	else{
				    		var truckColor = 'black'
				    	}
				    	marker = new google.maps.Marker({
				        	position: new google.maps.LatLng(dataPoints[i].Latitude, dataPoints[i].Longitude),
				        	map: map,
				        	icon: 'images/'+truckColor+'-truck-tools.png',
			      		});
			      		google.maps.event.addListener(marker, 'click', (function(marker, i) {
					        return function() {
						        infowindow.setContent("<div> <strong>Load##:</strong> #qLoadDetails.LoadNumber#<br/> <strong>Equipment Name:</strong> #qLoadDetails.EquipmentName#<br/> <strong>Driver Name:</strong> #qLoadDetails.Driver# <br/> <strong>Date/Time: </strong>" + dataPoints[i].ServerTime + " <br/> <strong>Address: </strong><span id='formatted_address"+i+"'></span> </div>");
						        infowindow.open(map, marker);
						        setMarkerAddress(i)
					        }
				      	})(marker, i));
					}

				}); 

  				function FormatLocationDate(dateStr){
					var dateObj = new Date(dateStr);
					var utcOffsetLocalServer = '#GetTimeZoneInfo().utcTotalOffset#';
					var utcOffsetLocal = dateObj.getTimezoneOffset();
					dateObj.setSeconds( dateObj.getSeconds() + utcOffsetLocalServer );
					dateObj.setMinutes( dateObj.getMinutes() - utcOffsetLocal );
	
					var monthNames = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];
					var MonthStr = monthNames[dateObj.getMonth()];
					var DateStr = dateObj.getDate();
					var YearStr = dateObj.getFullYear();
					var HourStr = dateObj.getHours();
					var MinutesStr = dateObj.getMinutes();
					var SecondsStr = dateObj.getSeconds();
					if(HourStr<10){
					   	HourStr = '0'+HourStr;
					}
					if(MinutesStr<10){
					   	MinutesStr = '0'+MinutesStr;
					}
					if(SecondsStr<10){
					   	SecondsStr = '0'+SecondsStr;
					}
					return MonthStr + ', ' + DateStr + ' ' + YearStr + ' ' + HourStr + ':' + MinutesStr + ':' + SecondsStr; 
				}

				function setMarkerAddress(i){
					var currLocLat = dataPoints[i].Latitude;
					var currLocLng =  dataPoints[i].Longitude;
					var currAddress = dataPoints[i].Address
					var latlng = new google.maps.LatLng(currLocLat, currLocLng);

					if(!$.trim(currAddress).length){
						geocoder.geocode({latLng: latlng},function(res,stat){
							$('##formatted_address'+i).html(res[0].formatted_address);
							dataPoints[i].Address = res[0].formatted_address;
						})
					}
					else{
						$('##formatted_address'+i).html(currAddress);
					}
				}
  			</script>
  			<style>
  				##directionsPanel{
  					width: 22%;height: 600px;overflow: auto;float: left;
  				}
  				##map{
  					width: 78%;height: 600px;overflow: auto;float: left;
  				}
  			</style>
		</head>
	</html>
	<body>
    	<div id="directionsPanel"></div>
    	<div id="map"></div>
	</body>
</cfoutput>