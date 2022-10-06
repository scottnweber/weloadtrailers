// Arrays for the origins and destinations inputs
var origins = new Array();
var destinations = new Array();

// Initial query parameters
var query = {
travelMode: "DRIVING",
unitSystem: 1
};


// Google Distance Matrix Service 
var dms = new google.maps.DistanceMatrixService();

// Interval and Limit values for tracking origins groupings (for staying within QUERY_LIMIT)
var originsInterval = 0;
var originsLimit;

// Query Limit - 100 is the non-premier query limit as of this update
var QUERY_LIMIT = 100;

/*
* Updates the query, then uses the Distance Matrix Service
   */
function updateMatrix(stopid, callFrom) {
    updateQuery();
	if(callFrom == "callFromRefreshButton")
	{
		dms.getDistanceMatrix(query, function(response, status) {
        		if (status == "OK") {
          			extractDistances(response.rows,stopid, "callFromRefreshButton");
	        	}else{
    	        	alert("There was a problem with the request to googleMap.  The reported error is '"+status+"'");
        		}
      		}
    	);
	}
	else
	{
		dms.getDistanceMatrix(query, function(response, status) {
        		if (status == "OK") {
          			extractDistances(response.rows,stopid);
	        	}else{
    	        	alert("There was a problem with the request to googleMap.  The reported error is '"+status+"'");
        		}
      		}
    	);
	}
}

$(document).ready(function(){
	var tooltipClassCount=$('body').find('.tooltip').length;
	if (tooltipClassCount >0){
		$( ".tooltip" ).tooltip({
		  	position: {
				my: "top",
				at: "top-35",
			},
		  	show: {
				duration: "fast"
			},
		  	hide: {
				effect: "hide"
		  	}
		});
	}
	var InfotoolTipClassCount=$('body').find('.InfotoolTip').length;
	if (InfotoolTipClassCount >0){
	  	$('.InfotoolTip').tooltip({
		  	position: {
				my: "center bottom-20",
				at: "center top",
				using: function( position, feedback ) {
				  	$( this ).css( position );
				  	$( "<div>" )
					.addClass( "arrow" )
					.addClass( feedback.vertical )
					.addClass( feedback.horizontal )
					.appendTo( this );
				}
	  		}
		});
		setTimeout(function() {
		    $(".ui-tooltip").fadeOut("fast");
		}, 2000);
	}

	$('.floatField').change(function(){
		var val = $(this).val();
		var fieldname = $(this).data("fieldname");
		if(isNaN(val)){
			alert('Invalid '+fieldname+'.');
			$(this).val(0);
			$(this).focus();
		}
	});
});
  
/* 	* Retrieves origins and destinations from textareas and
	* determines how to build the entire matrix within query limitations 	*/
function getInputs(shipperAdd, consigneeAdd){
    var originsString = shipperAdd;
    var destinationsString = consigneeAdd;
	
    
    origins = originsString.split("|");
    destinations = destinationsString.split("|");
    query.destinations = destinations;
    originsLimit = Math.floor(QUERY_LIMIT/destinations.length);
    if(originsLimit > 25){
        originsLimit = 25;
    }
}
  
/*   * Updates the query based on the known sizes of origins and destinations   */
function updateQuery(){
    if(origins.length * destinations.length < QUERY_LIMIT && originsLimit < 25){
        query.origins = origins;
    }else{
        query.origins = origins.slice(originsLimit*originsInterval,originsLimit*(originsInterval+1));
    }
	originsInterval  = 0;
} 
  
/*   * Initializes the matrix data and pulls the first set of near 100 results   */
function matrixInit(shipperAddress, consigneeAddress,stopid, callFrom){
    dms = new google.maps.DistanceMatrixService();
    getInputs(shipperAddress, consigneeAddress);
    updateMatrix(stopid, callFrom);
} 
  
/*	* Accepts rows and populates table content.  Error validation is limited to the "ZERO_RESULTS"
   	* return status.  originsLimit and originsInterval are used to find the correct table cell.   */
function extractDistances(rows,stopid, callFrom) {
	if(document.getElementById("milesUpdateMode"+stopid) != null && document.getElementById("milesUpdateMode"+stopid).value != "auto" && callFrom != "callFromRefreshButton")
	  	return;
	  
    for (var i = 0; i < rows.length; i++) {
      	for (var j = 0; j < rows[i].elements.length; j++) {
        	if(rows[i].elements[j].status != "ZERO_RESULTS"){
				if(rows[i].elements[j].distance == undefined) {	
					distance = "0";
					if(stopid=="")
						alert("Load Manager cannot calculate the miles for Stop 1 because the address is not recognized.");
					else
						alert("Load Manager cannot calculate the miles for Stop "+stopid+" because the address is not recognized.");
				} else
	           		distance = rows[i].elements[j].distance.text;
        	}else{
       		}
      	}
	  
	  	distance = distance.replace(/,/g,"");
	  	distance = distance.replace("mi","");
	  	distance = trim(distance);

	  	if(isNaN(distance))
	  		distance = 0;
		if(document.getElementById("milse"+stopid) != null) {
		  	document.getElementById("milse"+stopid).value = distance;
		  	document.getElementById("milse"+stopid).onchange();
		}
		if(document.getElementById('calculatedMiles') != null) {
			document.getElementById('calculatedMiles').value = distance;
			document.getElementById('calculatedMiles').onchange();
		}
    }
}
  
function getFloat(str){
	if(trim(str) == "")
		str = "0";
	str = str.replace(/,/g,'');
	str = str.replace(/\$/g,'');
	str = str.replace(/\(/,'-');
	str = str.replace(/\)/,'');
	if(isNaN(str))
	{
		alert('invalid number entered')
		str = "0";
	}
	return parseFloat(str);
}
  
function updatedMilesWithLongShort(DSN, UserName) {
	var milseFromGoogle = getFloat(document.getElementById('calculatedMiles').value);
	
	var longMiles = getFloat(document.getElementById('longMiles').value);
	var shortMiles = getFloat(document.getElementById('shortMiles').value);	
	
	
	var customerMiles = milseFromGoogle + ((milseFromGoogle/100)*longMiles);
	var carrierMiles = milseFromGoogle - ((milseFromGoogle/100)*shortMiles);
	
	document.getElementById('customerMiles').value = convertNumberFormat(customerMiles);
	document.getElementById('carrierMiles').value = convertNumberFormat(carrierMiles);
	
	var customerRatePerMile = getFloat(document.getElementById('customerRate').value);
	var carrierRatePerMile = getFloat(document.getElementById('carrierRate').value);
	
	document.getElementById('customerAmount').value = (customerMiles * customerRatePerMile).toFixed(2);
	document.getElementById('carrierAmount').value = (carrierMiles * carrierRatePerMile).toFixed(2);
	
	addQuickCalcInfoToLog(DSN,UserName);
}


  //////////////////////////////////////////////////////////

// Get Customer Info using Coldfusion AJAX

var chkLoad=0;
function checkUnload() {
	chkLoad = 1;
}

function customerRatePerMileChanged() {
	var totalMiles = document.getElementById('CustomerMilesCalc').value;
	var customerRatePerMile = document.getElementById('CustomerRatePerMile').value;
	
	customerRatePerMile = customerRatePerMile.replace("$","");
	customerRatePerMile = customerRatePerMile.replace(/,/g,"");
	
	
	if(isNaN(customerRatePerMile) || !customerRatePerMile.length) {
		alert("Please enter a valid Rate");
		document.getElementById('CustomerRatePerMile').value="$0";
		document.getElementById('CustomerMiles').value = "$0";
		document.getElementById('CustomerMilesTotalAmount').value =  "$0";
		updateTotalAndProfitFields();
	} else {
		var customerRatePerMileFloat = parseFloat(customerRatePerMile);
		var totalmilesCommaReject=parseFloat(totalMiles.replace(/\,/g,''));
		var totalMilesAmount = (customerRatePerMileFloat*totalmilesCommaReject).toFixed(2);
		document.getElementById('CustomerMiles').value = "$"+convertDollarNumberFormat(totalMilesAmount);
		document.getElementById('CustomerMilesTotalAmount').value =  "$"+convertDollarNumberFormat(totalMilesAmount);
		updateTotalAndProfitFields();
	}
}

function carrierRatePerMileChanged() {
	var totalMiles = document.getElementById('CarrierMilesCalc').value;
	var carrierRatePerMile = document.getElementById('CarrierRatePerMile').value;
	
	carrierRatePerMile = carrierRatePerMile.replace("$","");
	carrierRatePerMile = carrierRatePerMile.replace(/,/g,"");
	
	if(isNaN(carrierRatePerMile) || !carrierRatePerMile.length) {
		alert("Please enter a valid Rate");
		document.getElementById('CarrierRatePerMile').value="$0";
		document.getElementById('CarrierMiles').value = "$0";
		document.getElementById('CarrierMilesTotalAmount').value =  "$0";
		updateTotalAndProfitFields();
	} else {
		var carrierRatePerMileFloat = parseFloat(carrierRatePerMile);
		var totalmilesCommaReject=parseFloat(totalMiles.replace(/\,/g,''));
		var totalMilesAmount = (carrierRatePerMileFloat*totalmilesCommaReject).toFixed(2);
		document.getElementById('CarrierMiles').value = "$"+convertDollarNumberFormat(totalMilesAmount);
		document.getElementById('CarrierMilesTotalAmount').value = "$"+convertDollarNumberFormat(totalMilesAmount);
		updateTotalAndProfitFields();
	}
}

function addressChanged(stopid, callFrom) {
	/*miles calculation start*/
	var directionDisplayLoad;
    var directionsServiceLoad= new google.maps.DirectionsService();
	var stop1Shipper=$('#shipperlocation').val();
	var stop1Consignee=$('#consigneelocation').val();
	var consigneeAddress="";
	var shipperAddress="";
	var endPoint="";
	var startPoint="";
	var midPoint="";
	var distanceTotal=0;
	var shipperStreet = "";
	var shipperCity = "";
	var shipperState = "";
	var consigneeStreet = "";
	var consigneeCity = "";
	var consigneeState = "";
	var midStreet = "";
	var midCity = "";
	var midState = "";
	var stopFirst = { "lat": "", "lon": ""};
	var stopMid = { "lat": "", "lon": ""};
	var stopLast = { "lat": "", "lon": ""};
	
	if(stopid == '') {
		if (stop1Shipper !="" && stop1Consignee !="") {
			shipperAddress = stop1Shipper;
			shipperStreet = shipperAddress;
			shipperAddress += " " + trim(document.getElementById("shippercity").value);
			shipperCity = trim(document.getElementById("shippercity").value);
			var e = document.getElementById("shipperstate");
			if(trim(e.options[e.selectedIndex].text) != "Select"){
				shipperAddress += "," + trim(e.options[e.selectedIndex].text);
				shipperState = trim(e.options[e.selectedIndex].text);
			}
			consigneeAddress = stop1Consignee;
			consigneeStreet = stop1Consignee;
			consigneeAddress += " " + trim(document.getElementById("consigneecity").value);
			consigneeCity = trim(document.getElementById("consigneecity").value);
			e = document.getElementById("consigneestate");
			if(trim(e.options[e.selectedIndex].text) != "Select"){
				consigneeAddress += "," + trim(e.options[e.selectedIndex].text);
				consigneeState = trim(e.options[e.selectedIndex].text);
			}
			startPoint=shipperAddress;
			endPoint=consigneeAddress;
			
		} else if(stop1Shipper =="" || stop1Consignee =="") {
			shipperAddress =trim(document.getElementById("shippercity").value);
			shipperCity = trim(document.getElementById("shippercity").value);
			var e = document.getElementById("shipperstate");
			if(trim(e.options[e.selectedIndex].text) != "Select"){
				shipperAddress += "," + trim(e.options[e.selectedIndex].text);
				shipperState = trim(e.options[e.selectedIndex].text);
			}
			consigneeAddress = trim(document.getElementById("consigneecity").value);
			consigneeCity = trim(document.getElementById("consigneecity").value);
			e = document.getElementById("consigneestate");
			if(trim(e.options[e.selectedIndex].text) != "Select"){
				consigneeAddress += "," + trim(e.options[e.selectedIndex].text);
				consigneeState = trim(e.options[e.selectedIndex].text);
			}
			startPoint=shipperAddress;
			endPoint=consigneeAddress;
		} else {
			$('#milse').val(0);
		}
		var constate = document.getElementById("consigneestate");
		var	constateValue='';
		if((constate.options[constate.selectedIndex].text) != "Select")
			constateValue =(constate.options[constate.selectedIndex].text);
		if((trim(document.getElementById("consigneelocation").value) == "") && ((document.getElementById("consigneecity").value) == "") && ((constateValue == "")))  {
			return;
		}
	}

	if(stopid != '') {
		startPoint="";
		endPoint="";
		shipperAddress="";
		consigneeAddress="";
		var prevStopId = stopid-1;
		if(prevStopId == 1){prevStopId=""}
		
		var shipperAddressPrev = trim(document.getElementById("shipperlocation"+prevStopId).value);
		if (shipperAddressPrev =="") {
			shipperAddressPrev = trim(document.getElementById("shippercity"+prevStopId).value);
		} else {
			shipperAddressPrev += " " + trim(document.getElementById("shippercity"+prevStopId).value);
		}
		var e = document.getElementById("shipperstate"+prevStopId);
		if(trim(e.options[e.selectedIndex].text) != "Select")
			shipperAddressPrev += "," + trim(e.options[e.selectedIndex].text);

		var consigneeAddressPrev = document.getElementById("consigneelocation"+prevStopId).value;
		if(consigneeAddressPrev =="") {
			consigneeAddressPrev =trim(document.getElementById("consigneecity"+prevStopId).value);
		} else {
			consigneeAddressPrev += " " + trim(document.getElementById("consigneecity"+prevStopId).value);
		}
		e = document.getElementById("consigneestate"+prevStopId);
		if(trim(e.options[e.selectedIndex].text) != "Select")
			consigneeAddressPrev += "," + trim(e.options[e.selectedIndex].text);
		shipperAddress = trim(document.getElementById("shipperlocation"+stopid).value);
		if(shipperAddress =="") {
			shipperAddress = trim(document.getElementById("shippercity"+stopid).value);
		} else {
			shipperAddress += " " + trim(document.getElementById("shippercity"+stopid).value);
		}
		var e = document.getElementById("shipperstate"+stopid);
		if(trim(e.options[e.selectedIndex].text) != "Select"){
			shipperAddress += "," + trim(e.options[e.selectedIndex].text);
		}
		consigneeAddress = document.getElementById("consigneelocation"+stopid).value;
		if(consigneeAddress =="") {
			consigneeAddress =trim(document.getElementById("consigneecity"+stopid).value);
		} else {
			consigneeAddress += " " + trim(document.getElementById("consigneecity"+stopid).value);
		}
		
		e = document.getElementById("consigneestate"+stopid);
		if(trim(e.options[e.selectedIndex].text) != "Select")
			consigneeAddress += "," + trim(e.options[e.selectedIndex].text);
		var shipperAddressCurrentStop = $('#shipperlocation'+stopid).val();
		var shipperStateCurrentStop = $('#shipperstate'+stopid).val();
		var shipperCityCurrentStop = $('#shippercity'+stopid).val();
		var consigneeAddressCurrentStop = $('#consigneelocation'+stopid).val();
		var shipperCustomer = $('#shipper'+stopid).val();
		var consigneeCustomer = $('#consignee'+stopid).val();
		var consigneecitycheck = $('#consigneecity'+stopid).val();
		var consigneestateCheck = $('#consigneestate'+stopid).val();
		var shipperAddressPrevStop = $('#shipperlocation'+prevStopId).val();
		var shipperCityPrevStop = $('#shippercity'+prevStopId).val();
		var shipperStatePrevStop = $('#shipperstate'+prevStopId).val();
		var consigneeAddressPrevStop = $('#consigneelocation'+prevStopId).val();
		var consigneeCityPrevStop = $('#consigneecity'+prevStopId).val();
		var consigneeStatePrevStop = $('#consigneestate'+prevStopId).val();
		if(consigneeAddressPrevStop != "" || consigneeCityPrevStop !="" ||consigneeStatePrevStop !="") {
			startPoint=consigneeAddressPrev;
			shipperStreet = consigneeAddressPrevStop;
			shipperCity = consigneeCityPrevStop;
			shipperState = consigneeStatePrevStop;
		} else {
			if(shipperAddressPrevStop != "" ||shipperCityPrevStop !="" ||shipperStatePrevStop !="") {
				startPoint=shipperAddressPrev;
				shipperStreet = shipperAddressPrevStop;
				shipperCity = shipperCityPrevStop;
				shipperState = shipperStatePrevStop;
			} else {
				if(stopid ==2){
					var previousStopidVal = document.getElementById("milse").value;
				} else {
					var previousStopid = stopid-1;
					var previousStopidVal = document.getElementById("milse"+previousStopid).value;
				}
				document.getElementById("milse"+stopid).value = previousStopidVal;
				if(trim(consigneeAddressCurrentStop) ==""|| (trim(consigneestateCheck)) =="" || (trim(consigneecitycheck)) ==""){
					return;
				}
			}
		}
		  
		if(trim(shipperAddressCurrentStop) != "" || trim(shipperStateCurrentStop) !="" || trim(shipperCityCurrentStop) !="" ){
			if(trim(consigneeAddressCurrentStop) !=""|| (trim(consigneestateCheck)) !="" || (trim(consigneecitycheck)) !=""){
				if (startPoint != "") {
					midPoint=shipperAddress;
					midStreet = shipperAddressCurrentStop;
					midCity = shipperCityCurrentStop;
					midState = shipperStateCurrentStop;
				}
				else{	
					startPoint=shipperAddress;
					shipperStreet = shipperAddressCurrentStop;
					shipperCity = shipperCityCurrentStop;
					shipperState = shipperStateCurrentStop;
				}
				endPoint=consigneeAddress;
				consigneeStreet = consigneeAddressCurrentStop;
				consigneeCity = consigneecitycheck;
				consigneeState = consigneestateCheck
			}else{
				endPoint=shipperAddress;
				consigneeStreet = shipperAddressCurrentStop;
				consigneeCity = shipperCityCurrentStop;
				consigneeState = shipperStateCurrentStop;
			}
		} else {
			if(trim(consigneeAddressCurrentStop) !="" || (trim(consigneestateCheck)) !="" || (trim(consigneecitycheck)) !=""){
				endPoint=consigneeAddress;
				consigneeStreet = consigneeAddressCurrentStop;
				consigneeCity = consigneecitycheck;
				consigneeState = consigneestateCheck;
			}else{
				if(stopid ==2){
					var previousStopidVal = document.getElementById("milse").value;
				} else{
					var previousStopid = stopid-1;
					var previousStopidVal = document.getElementById("milse"+previousStopid).value;
				}
				document.getElementById("milse"+stopid).value = previousStopidVal;
				return;
			}
		}
	}

	if(midPoint != "") {
		var requestLoad = {
			origin: startPoint,
		    destination: endPoint,
		  	waypoints: [{ location: midPoint}
			], 
			provideRouteAlternatives: false,
			travelMode: google.maps.DirectionsTravelMode.DRIVING
		};
	} else {
		var requestLoad = {
			origin: startPoint,
		    destination: endPoint,
			provideRouteAlternatives: false,
			travelMode: google.maps.DirectionsTravelMode.DRIVING
		};
	}
	
	if(googleMapsPcMiler == 2 && ALKMaps.APIKey){
		/* PC MILER */
		
		map = new ALKMaps.Map('map');
		
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
				/*console.log(stopFirst);
				debugger;*/
				
				//Second map query
				ALKMaps.Geocoder.geocode({
					address:{
						addr: consigneeStreet, 
						city: consigneeCity, 
						state: consigneeState, 
						region: "NA" //Valid values are NA, EU, OC, SA, AS, AF, and ME. Default is NA.
					},
					listSize: 1, //Optional. The number of results returned if the geocoding service finds multiple matches.
					success: function(response){
						stopLast.lat = response[0].Coords.Lat;
						stopLast.lon = response[0].Coords.Lon;
						/*console.log(stopLast);
						debugger;*/

						//Third map query
						if(midStreet != "" || midCity != "" || midState != "" ){
			
							ALKMaps.Geocoder.geocode({
								address:{
									addr: midStreet, 
									city: midCity, 
									state: midState, 
									region: "NA" //Valid values are NA, EU, OC, SA, AS, AF, and ME. Default is NA.
								},
								listSize: 1, //Optional. The number of results returned if the geocoding service finds multiple matches.
								success: function(response){
									stopMid.lat = response[0].Coords.Lat;
									stopMid.lon = response[0].Coords.Lon;
									//console.log(stopMid);
									//debugger;
									
									//Mile calculation
									var stops = [
										new ALKMaps.LonLat(stopFirst.lon,stopFirst.lat)
									];
									if ( stopMid.lon != "") {
										stops.push(new ALKMaps.LonLat(stopMid.lon,stopMid.lat))
									}
									stops.push(new ALKMaps.LonLat(stopLast.lon,stopLast.lat));
									
									stops = ALKMaps.LonLat.transformArray(stops, new ALKMaps.Projection("EPSG:4326"), map.getProjectionObject());

									var coordsArray	= [[stops[0].lon,stops[0].lat],[stops[1].lon,stops[1].lat]];
									if (typeof stops[2] !== 'undefined') {
										coordsArray.push([stops[2].lon,stops[2].lat]);
									}
									
									var opt = {
										vehicleType:"LightTruck", 
										routingType:"Practical", 
										routeOptimization: 1, 
										highwayOnly: false, 
										distanceUnits: "Miles", 
										tollCurrency: "US", 
										inclTollData:true,
										region: "NA"  //Valid values are NA, EU, OC and SA.
									}; 

									var reportOptions = { 
										type: "CalcMiles", //Comma separated report type values
										format: "json",
										lang: "ENUS", //Valid values are ENUS, ENGB, DE, FR, ES, IT
										dataVersion: "current"  //Valid values are Current, PCM_EU, PCM_OC, PCM_SA, PCM_GT, PCM_AF, PCM_AS, PCM_ME, or PCM18 through PCM27
									}; 

									map.getReports({ 
										coords: coordsArray, 
										options: opt, 
										reportOptions: reportOptions, 
										success: function(resp){
											//console.log(resp[0].TMiles);

											distanceTotal = parseFloat(resp[0].TMiles);
											if(isNaN(distanceTotal)){	
												distance = 0;
											 }
											if(document.getElementById("milse"+stopid) != null)
											{
											  document.getElementById("milse"+stopid).value = distanceTotal;
											  document.getElementById("milse"+stopid).onchange();
											}
											if(document.getElementById('calculatedMiles') != null){
												document.getElementById('calculatedMiles').value = distanceTotal;
												document.getElementById('calculatedMiles').onchange();
											}
										},
										failure: function(response){
											if(stopid==""){
												alert("Load Manager cannot calculate the miles for Stop 1 because the address is not recognized.");
											}else{
												alert("Load Manager cannot calculate the miles for Stop "+stopid+" because the address is not recognized.");
											}	
										}
									});
								},
								failure: function(response){
									alert("Load Manager cannot calculate the miles for the given address because it is not recognized.");
								}
							});	
						}else{
							var stops = [
								new ALKMaps.LonLat(stopFirst.lon,stopFirst.lat)
							];
							if ( stopMid.lon != "") {
								stops.push(new ALKMaps.LonLat(stopMid.lon,stopMid.lat))
							}
							stops.push(new ALKMaps.LonLat(stopLast.lon,stopLast.lat));
							
							stops = ALKMaps.LonLat.transformArray(stops, new ALKMaps.Projection("EPSG:4326"), map.getProjectionObject());

							/*console.log(stops);
							debugger;*/
							
							var coordsArray	= [[stops[0].lon,stops[0].lat],[stops[1].lon,stops[1].lat]];
							if (typeof stops[2] !== 'undefined') {
								coordsArray.push([stops[2].lon,stops[2].lat]);
							}
							
							var opt = {
								vehicleType:"LightTruck", 
								routingType:"Practical", 
								routeOptimization: 1, 
								highwayOnly: false, 
								distanceUnits: "Miles", 
								tollCurrency: "US", 
								inclTollData:true,
								region: "NA"  //Valid values are NA, EU, OC and SA.
							}; 

							var reportOptions = { 
								type: "CalcMiles", //Comma separated report type values
								format: "json",
								lang: "ENUS", //Valid values are ENUS, ENGB, DE, FR, ES, IT
								dataVersion: "current"  //Valid values are Current, PCM_EU, PCM_OC, PCM_SA, PCM_GT, PCM_AF, PCM_AS, PCM_ME, or PCM18 through PCM27
							}; 

							map.getReports({ 
								coords: coordsArray, 
								options: opt, 
								reportOptions: reportOptions, 
								success: function(resp){
									//console.log(resp[0].TMiles);

									distanceTotal = parseFloat(resp[0].TMiles);
									if(isNaN(distanceTotal)){	
										distance = 0;
									 }
									if(document.getElementById("milse"+stopid) != null)
									{
									  document.getElementById("milse"+stopid).value = distanceTotal;
									  document.getElementById("milse"+stopid).onchange();
									}
									if(document.getElementById('calculatedMiles') != null){
										document.getElementById('calculatedMiles').value = distanceTotal;
										document.getElementById('calculatedMiles').onchange();
									}
								},
								failure: function(response){
									if(stopid==""){
										alert("Load Manager cannot calculate the miles for Stop 1 because the address is not recognized.");
									}else{
										alert("Load Manager cannot calculate the miles for Stop "+stopid+" because the address is not recognized.");
									}	
								}
							});
						}
					},
					failure: function(response){
						alert("Load Manager cannot calculate the miles for the given address because it is not recognized.");
					}
				});
			},
			failure: function(response){
				alert("Load Manager cannot calculate the miles for the given address because it is not recognized.");
			}
		});		
	}
	else if(googleMapsPcMiler == 1){

		var sAddress = '';
		var sCity = '';
		var sState = '';
		var sZip = '';

		var cAddress = '';
		var cCity = '';
		var cState = '';
		var cZip = '';

		
		if(!$.trim($('#shipperlocation'+$.trim(stopid)).val()).length 
			&&!$.trim($('#shippercity'+$.trim(stopid)).val()).length 
			&& !$.trim($('#shipperstate'+$.trim(stopid)).val()).length 
			&& !$.trim($('#shipperZipcode'+$.trim(stopid)).val()).length 
			&& !$.trim($('#consigneelocation'+$.trim(stopid)).val()).length 
			&& !$.trim($('#consigneecity'+$.trim(stopid)).val()).length 
			&& !$.trim($('#consigneestate'+$.trim(stopid)).val()).length 
			&& !$.trim($('#consigneeZipcode'+$.trim(stopid)).val()).length){
			document.getElementById("milse"+stopid).value = 0;
		}
		else{

			if($.trim($('#shipperlocation'+$.trim(stopid)).val()).length 
				||$.trim($('#shippercity'+$.trim(stopid)).val()).length 
				|| $.trim($('#shipperstate'+$.trim(stopid)).val()).length 
				|| $.trim($('#shipperZipcode'+$.trim(stopid)).val()).length ){
				sAddress = $('#shipperlocation'+$.trim(stopid)).val();
				sCity = $('#shippercity'+$.trim(stopid)).val();
				sState = $('#shipperstate'+$.trim(stopid)).val();
				sZip = $('#shipperZipcode'+$.trim(stopid)).val();
			}
			else{

				var prevStopId = $.trim(stopid) - 1;

				if(prevStopId == 1){
					prevStopId = '';
				}

				if($.trim($('#consigneelocation'+$.trim(prevStopId)).val()).length 
					||$.trim($('#consigneecity'+$.trim(prevStopId)).val()).length 
					|| $.trim($('#consigneestate'+$.trim(prevStopId)).val()).length 
					|| $.trim($('#consigneeZipcode'+$.trim(prevStopId)).val()).length ){

					sAddress = $('#consigneelocation'+$.trim(prevStopId)).val();
					sCity = $('#consigneecity'+$.trim(prevStopId)).val();
					sState = $('#consigneestate'+$.trim(prevStopId)).val();
					sZip = $('#consigneeZipcode'+$.trim(prevStopId)).val();
				}
				else{
					sAddress = $('#shipperlocation'+$.trim(prevStopId)).val();
					sCity = $('#shippercity'+$.trim(prevStopId)).val();
					sState = $('#shipperstate'+$.trim(prevStopId)).val();
					sZip = $('#shipperZipcode'+$.trim(prevStopId)).val();
				}
			}
			var cAddress = $('#consigneelocation'+$.trim(stopid)).val();
			var cCity = $('#consigneecity'+$.trim(stopid)).val();
			var cState = $('#consigneestate'+$.trim(stopid)).val();
			var cZip = $('#consigneeZipcode'+$.trim(stopid)).val();

	        /*var slocationText = '';
			var clocationText = '';*/

			oTripleg = {};
			dTripleg = {};
			if($.trim(sAddress).length){
				oTripleg["address"] = sAddress.split('\n')[0];
			}
			if($.trim(sCity).length){
				oTripleg["city"] = sCity;
			}
			if($.trim(sState).length){
				oTripleg["state"] = sState;
			}
			if($.trim(sZip).length){
				oTripleg["postalCode"] = sZip;
			}


			if($.trim(cAddress).length){
				dTripleg["address"] = cAddress.split('\n')[0];
			}
			if($.trim(cCity).length){
				dTripleg["city"] = cCity;
			}
			if($.trim(cState).length){
				dTripleg["state"] = cState;
			}
			if($.trim(cZip).length){
				dTripleg["postalCode"] = cZip;
			}

			var origin = new PRIMEWebAPI.TripLeg(oTripleg);
            var destination = new PRIMEWebAPI.TripLeg(dTripleg);
           
            var arr = [];
            arr.push(origin);
            arr.push(destination);

            var trip = new PRIMEWebAPI.Trip(
                {
                    tripLegs: arr,
                    routingMethod: PRIMEWebAPI.RoutingMethods.PRACTICAL,
                    borderOpen: true,
                    avoidTollRoads: false,
                    vehicleType: PRIMEWebAPI.VehicleTypes.TRACTOR3AXLETRAILER2AXLE,
                    getDrivingDirections: true,
                    getMapPoints: true,
                    getStateMileage: true,
                    getTripSummary: true,
                    mpg: 6
                });
            $('.loadOverlay').show();
            $('#loader_miles').show();
            PRIMEWebAPI.runTrip(trip, function(TripResult,status){
            	var miles = TripResult.TripDistance;
            	var ResponseMessage = TripResult.ResponseMessage;
            	if(status=='success' && miles >= 0){

            		if(miles==0 && (ResponseMessage.includes("Unable to route to") || ResponseMessage.includes("ERROR"))){
            			oTripleg = {};
						dTripleg = {};

						if($.trim(sCity).length){
							oTripleg["city"] = sCity;
						}
						if($.trim(sState).length){
							oTripleg["state"] = sState;
						}
						if($.trim(sZip).length){
							oTripleg["postalCode"] = sZip;
						}

						if($.trim(cCity).length){
							dTripleg["city"] = cCity;
						}
						if($.trim(cState).length){
							dTripleg["state"] = cState;
						}
						if($.trim(cZip).length){
							dTripleg["postalCode"] = cZip;
						}

						var origin = new PRIMEWebAPI.TripLeg(oTripleg);
			            var destination = new PRIMEWebAPI.TripLeg(dTripleg);
			           
			            var arr = [];
			            arr.push(origin);
			            arr.push(destination);

			            var trip = new PRIMEWebAPI.Trip({
		                    tripLegs: arr,
		                    routingMethod: PRIMEWebAPI.RoutingMethods.PRACTICAL,
		                    borderOpen: true,
		                    avoidTollRoads: false,
		                    vehicleType: PRIMEWebAPI.VehicleTypes.TRACTOR3AXLETRAILER2AXLE,
		                    getDrivingDirections: true,
		                    getMapPoints: true,
		                    getStateMileage: true,
		                    getTripSummary: true,
		                    mpg: 6
			            });

			            PRIMEWebAPI.runTrip(trip, function(TripResult,status){
			            	var miles = TripResult.TripDistance;
			            	if(status=='success' && miles >= 0){
				            	if(document.getElementById("milse"+stopid) != null)
								{
								  document.getElementById("milse"+stopid).value = miles;
								  document.getElementById("milse"+stopid).onchange();
								}
								if(document.getElementById('calculatedMiles') != null){
									document.getElementById('calculatedMiles').value = miles;
									document.getElementById('calculatedMiles').onchange();
								}
								$('.loadOverlay').hide();
           						$('#loader_miles').hide();
							}
							else{
	        					$('.loadOverlay').hide();
           						$('#loader_miles').hide();
				        		document.getElementById("milse"+stopid).value = 0;
				        		document.getElementById("milse"+stopid).onchange();
				        		if(stopid==""){
									alert("Load Manager cannot calculate the miles for Stop 1 because the address is not recognized.");
								}else{
									alert("Load Manager cannot calculate the miles for Stop "+stopid+" because the address is not recognized.");
								}
				        	}
			            });
            		}
            		else{
            			$('.loadOverlay').hide();
           				$('#loader_miles').hide();
            			if(document.getElementById("milse"+stopid) != null)
						{
						  document.getElementById("milse"+stopid).value = miles;
						  document.getElementById("milse"+stopid).onchange();
						}
						if(document.getElementById('calculatedMiles') != null){
							document.getElementById('calculatedMiles').value = miles;
							document.getElementById('calculatedMiles').onchange();
						}
            		}
	        		
	        	}
	        	else{
	        		$('.loadOverlay').hide();
           			$('#loader_miles').hide();
	        		document.getElementById("milse"+stopid).value = 0;
	        		document.getElementById("milse"+stopid).onchange();
	        		if(stopid==""){
						alert("Load Manager cannot calculate the miles for Stop 1 because the address is not recognized.");
					}else{
						alert("Load Manager cannot calculate the miles for Stop "+stopid+" because the address is not recognized.");
					}	
	        	}
            });

		}
	}
	else{
		directionsServiceLoad.route(requestLoad, function(response, status) {
			if(document.getElementById("milesUpdateMode"+stopid) != null && document.getElementById("milesUpdateMode"+stopid).value != "auto" && callFrom != "callFromRefreshButton"){
				return;
			}		
			if (status == "OK"){
				var totalDistance = 0;
				var totalDuration = 0;
				var legs = response.routes[0].legs;
				for(var i=0; i<legs.length; ++i) {
					totalDistance += legs[i].distance.value;
					totalDuration += legs[i].duration.value;
				}
				var METERS_TO_MILES = 0.000621371192;
				distanceTotal+=(Math.round( totalDistance * METERS_TO_MILES * 10 ) / 10);
			}	
			else{
				if(stopid==""){
					alert("Load Manager cannot calculate the miles for Stop 1 because the address is not recognized.");
				}else{
					alert("Load Manager cannot calculate the miles for Stop "+stopid+" because the address is not recognized.");
				}	
			}	
			if(isNaN(distanceTotal)){	
				distance = 0;
			 }
			if(document.getElementById("milse"+stopid) != null)
			{
			  document.getElementById("milse"+stopid).value = distanceTotal;
			  document.getElementById("milse"+stopid).onchange();
			}
			if(document.getElementById('calculatedMiles') != null){
				document.getElementById('calculatedMiles').value = distanceTotal;
				document.getElementById('calculatedMiles').onchange();
			}
		});
	}	

}

function prepareAddressForGoogleApi(str){
	var strToRet=str;
	strToRet = strToRet.replace(/, /g,'+');
	strToRet = strToRet.replace(/,/g,'+');
	strToRet = strToRet.replace(/ /g,'+');
	strToRet = strToRet.replace(/\n/g,'+');
	return strToRet;
}

function calculateDist(addressField1, addressField2) {
	var add1 = document.getElementById(addressField1).value;
	add1 = trim(add1);

	var e = document.getElementById("Consigneestate");
	
	var conCity = trim(document.getElementById("ConsigneeCity").value);
	var conState = trim(e.options[e.selectedIndex].text);
	var conZip = trim(document.getElementById("ConsigneeZip").value);
	
	add1 += "+" + conCity;
	
	if(conState != "Select")
		add1 += "+" + conState;
	add1 += "+" + conZip;
	
	add1 = prepareAddressForGoogleApi(add1);
	
	var add2 = document.getElementById(addressField2).value;
	add2 = trim(add2);
	e = document.getElementById("Shipperstate");
	var shipperCity = trim(document.getElementById("ShipperCity").value);
	var shipperState = trim(e.options[e.selectedIndex].text);
	var shipperZip = trim(document.getElementById("ShipperZip").value);
	
	add2 += "+" + shipperCity;
	
	if(shipperState != "Select")
		add2 += "+" + shipperState;
	add2 += "+" + shipperZip;
	
	if ( ((shipperCity != '' && shipperState != "Select") || (shipperZip != '')) && ((conCity != '' && conState != "Select") || (conZip != ''))){
		// Continue with calculation
	}
	else
		return;
	
	add2 = prepareAddressForGoogleApi(add2);
	
	matrixInit(add1, add2, '', '');
}


function getCutomerForm(custID,aDsn,urltoken,type) {
    var path = urlComponentPath+"loadgateway.cfc";
    if( $('#editid').length )  {
		var editid=$("#editid").val();
	}
	else if( $('#loadToBeCopied').length )  {
		var editid=$("#loadToBeCopied").val();
	}
	else{
		var editid='';
	}
	$.get(path,
      	{
	        method: "getAjaxLoadCustomerInfo1",
	        dataType: "html",
	        argumentCollection: JSON.stringify( {
	            dsn: aDsn,
	            customerID: custID,
	            urlToken: urltoken,
	            type:type,
	            loadid:editid
	        })
      	},
  	function (data) {
        document.getElementById('CustInfo1').innerHTML = data;	   
    });

  	$.get(path,
  		{
    		method: "getAjaxLoadCustomerInfo2",
    		dataType: "html",
    		argumentCollection: JSON.stringify( {
        		dsn: aDsn,
        		customerID: custID
      		})
  		},
  	function (data) {
   		document.getElementById('CustInfo2').innerHTML = data;
		var loaddisabledStatus=$("#loaddisabledStatus").val();
		if (loaddisabledStatus == 'false'){
			$('#load input[name="save"]').removeAttr('disabled');
			$('#load input[name="submit"]').removeAttr('disabled');
			$('#load input[name="saveexit"]').removeAttr('disabled');
		}
  	});
  
}

function getAjaxLoadCustomerInfo1Handler(response){
	document.getElementById('CustInfo1').innerHTML = response;
}

function getAjaxLoadCustomerInfo2Handler(response) {
	document.getElementById('CustInfo2').innerHTML = response;
	if (loaddisabledStatus == 'false'){
		$('#load input[name="save"]').removeAttr('disabled');
		$('#load input[name="submit"]').removeAttr('disabled');
		$('#load input[name="saveexit"]').removeAttr('disabled');
	}	
}

function tablePrevPage(formName){
	if(parseInt(document.getElementById('pageNo').value)>1) {
		document.getElementById('pageNo').value = parseInt(document.getElementById('pageNo').value)-1;
		$('#'+formName).submit();
	}
}

function refreshMilesClicked(stopid) {
	addressChanged(stopid,"callFromRefreshButton");
}


function getCommissionReport(URLToken, action,dsn,customerStatus,pageBreakStatus,ShowSummaryStatus,ShowProfit,ShowReportCriteria,NonCommissionable){
	var url = "";
	var datetype = $("input[name='datetype']:checked").val();
	var freightBrokerValues=$("#freightBroker").val();
	var appDsn=$("#appDsn").val();
	var companyid=$("#companyid").val();
	if( document.getElementById('none').checked ) {
		var groupBy='none';
	} else if( document.getElementById('salesAgent').checked ) {
		if(freightBrokerValues =='Driver'){
			var groupBy='userDefinedFieldTrucking';
		}else{
			var groupBy='salesAgent';
		}
	} else if ( document.getElementById('dispatcher').checked ) {
		var groupBy='dispatcher';
	}else if ( document.getElementById('customer').checked ) {
		var groupBy='CustName';	
	} else if ( document.getElementById('Carrier') != null && document.getElementById('Carrier').checked ) {
		var groupBy='Carrier';
	} else if ( document.getElementById('Driver') != null && document.getElementById('Driver').checked ) {
		var groupBy='Driver';
	}else if ( document.getElementById('Carrier/Driver') != null && document.getElementById('Carrier/Driver').checked ) {
		var groupBy='Carrier/Driver';
	}
	url += "groupBy="+groupBy;
	if( document.getElementById('loadno').checked ) {
		var sortBy='LoadNumber';
	}
	else{
		var sortBy='date';
	}

	url += "&sortBy="+sortBy;
	if(datetype=='Shipdate') {
		url += "&orderDateFrom="+document.getElementById('dateFrom').value;
		url += "&orderDateTo="+document.getElementById('dateTo').value;
	} 
	if(datetype=='Deliverydate') {
		url += "&deliveryDateFrom="+document.getElementById('dateFrom').value;
		url += "&deliveryDateTo="+document.getElementById('dateTo').value;
	} 
	if(datetype=='Invoicedate') {
		url += "&billDateFrom="+document.getElementById('dateFrom').value;
		url += "&billDateTo="+document.getElementById('dateTo').value;	
	}
	if(datetype=='Createdate') {
		url += "&createDateFrom="+document.getElementById('dateFrom').value;
		url += "&createDateTo="+document.getElementById('dateTo').value;	
	}
	url += "&deductionPercentage=0";
	url += "&commissionPercentage="+getFloat(document.getElementById('commissionPercent').value);
	var salesRepFrom='';
	var salesRepTo='';
	if(freightBrokerValues =='Driver') {
		salesRepFrom=$("#salesRepFrom").val();
		salesRepTo=$("#salesRepTo").val();
	} else {
		var s=document.getElementById("salesRepFrom");
		salesRepFrom=trim(s.options[s.selectedIndex].getAttribute("srname"));
		var t=document.getElementById("salesRepTo");
		salesRepTo=trim(t.options[t.selectedIndex].getAttribute("srname"));
	}
	var e = document.getElementById("salesRepFrom");
	url += "&salesRepFrom="+salesRepFrom;
	
	e = document.getElementById("salesRepTo");
	url += "&salesRepTo="+salesRepTo;
	
	e = document.getElementById("dispatcherFrom");
	url += "&dispatcherFrom="+trim(e.options[e.selectedIndex].getAttribute("dname"));
	
	e = document.getElementById("dispatcherTo");
	url += "&dispatcherTo="+trim(e.options[e.selectedIndex].getAttribute("dname"));
	
	e = document.getElementById("customerFrom");
	url += "&customerFrom="+encodeURIComponent(trim(e.options[e.selectedIndex].getAttribute("custname")));
	
	e = document.getElementById("customerTo");
	url += "&customerTo="+encodeURIComponent(trim(e.options[e.selectedIndex].getAttribute("custname")));
	
	e = document.getElementById("reportType");
	var type = trim(e.options[e.selectedIndex].text);
	url += "&reportType="+type;
	
	url += "&marginRangeFrom="+getFloat(document.getElementById('marginFrom').value);
	url += "&marginRangeTo="+getFloat(document.getElementById('marginTo').value);

	//Status Loads From To
	e = document.getElementById("StatusTo");
	url += "&StatusTo="+trim(e.options[e.selectedIndex].getAttribute('data-statustext'));
	
	//Status Loads From To
	e = document.getElementById("StatusFrom");
	url += "&StatusFrom="+trim(e.options[e.selectedIndex].getAttribute('data-statustext'));
	
	//customer From To
	e = document.getElementById("customerFrom");
	url += "&customerLimitFrom="+encodeURIComponent(trim(e.options[e.selectedIndex].getAttribute("custname")));
	
	//customer From To
	e = document.getElementById("customerTo");
	url += "&customerLimitTo="+encodeURIComponent(trim(e.options[e.selectedIndex].getAttribute("custname")));
	
	//equipment From To
	e = document.getElementById("equipmentFrom");
	url += "&equipmentFrom="+trim(e.options[e.selectedIndex].text);
	
	//equipment From To
	e = document.getElementById("equipmentTo");
	url += "&equipmentTo="+trim(e.options[e.selectedIndex].text);

	//office From To
	e = document.getElementById("officeFrom");
	url += "&officeFrom="+trim(e.options[e.selectedIndex].text);
	
	//office From To
	e = document.getElementById("officeTo");
	url += "&officeTo="+trim(e.options[e.selectedIndex].text);

	e = document.getElementById("carrierFrom");
	url += "&carrierFrom="+encodeURIComponent(trim(e.options[e.selectedIndex].getAttribute("cname")));
	
	e = document.getElementById("carrierTo");
	url += "&carrierTo="+encodeURIComponent(trim(e.options[e.selectedIndex].getAttribute("cname")));

	//salesRep From and To Id's
	e = document.getElementById("salesRepFrom");
	url += "&salesRepFromId="+trim(e.value);
	
	e = document.getElementById("salesRepTo");
	url += "&salesRepToId="+trim(e.value);
	
	//dispatcherRep From and To Id's
	e = document.getElementById("dispatcherFrom");
	url += "&dispatcherFromId="+trim(e.value);
	
	e = document.getElementById("dispatcherTo");
	url += "&dispatcherToId="+trim(e.value);

	e = document.getElementById("freightBroker");
	url += "&freightBroker="+trim(e.value);
	
	e = document.getElementById("companyid");
	url += "&companyid="+trim(e.value);

	e = NonCommissionable;
	url += "&NonCommissionable="+e;
	url = url.replace(/####/g,'AAAA');
	if(action == 'view')
	{
		window.open('index.cfm?event=SalesReportCondensed&'+url+'&dsn='+dsn+'&customerStatus='+customerStatus+'&pageBreakStatus='+pageBreakStatus+'&ShowSummaryStatus='+ShowSummaryStatus+'&ShowProfit='+ShowProfit+'&ShowReportCriteria='+ShowReportCriteria+'&datetype='+datetype+'&'+URLToken);
	}
	else if(action == 'mail')
	{
		newwindow=window.open('index.cfm?event=loadMail&type='+type+'&'+url+'&dsn='+dsn+'&customerStatus='+customerStatus+'&pageBreakStatus='+pageBreakStatus+'&ShowSummaryStatus='+ShowSummaryStatus+'&ShowProfit='+ShowProfit+'&ShowReportCriteria='+ShowReportCriteria+'&datetype='+datetype+'&'+URLToken+'','Map','height=400,width=750');
		if (window.focus) {newwindow.focus()}
	}
}

function getAndUpdateLongShortMilesFields(dsn) {
	document.getElementById('longMiles').value = 0;
	document.getElementById('shortMiles').value = 0;
}

function phoneFormatValid(val) {
	var phoneText = val;
	phoneText = phoneText.toString().replace(/,/g, "");
	phoneText = phoneText.replace(/-/g, "");
	phoneText = phoneText.replace(/\(/g, "");
	phoneText = phoneText.replace(/\)/g, "");
	phoneText = phoneText.replace(/ /g, "");
	if(!isNaN(phoneText.substring(0,10)) & phoneText.substring(0,10).length==10) {
		var part1 = phoneText.substring(0,6);
		part1 = part1.replace(/(\S{3})/g, "$1-");
		var part2 = phoneText.substring(6,10);
		var ext = phoneText.substring(10);
		var phoneField = part1 + part2 + " " + ext;
	}
	else if(phoneText.substring(0,10).length!=0){alert('Invalid Phone Number!')}
}

$( "body" ).on( "change", ".phoneFormatValid",function() {
	var phoneText = $(this).val();
	phoneText.replace(/,/g,'');
	console.log(phoneText);
});

function EnableDisableForm(xForm,flag) {
	objElems = xForm.elements;
	for(i=0;i<objElems.length;i++){
		objElems[i].disabled = flag;
	}
}

function tableNextPage(formName) {
	if(document.getElementById('message') == null || (document.getElementById('message') != null && document.getElementById('message').innerHTML != "No match found")) {
		document.getElementById('pageNo').value = parseInt(document.getElementById('pageNo').value)+1;
		$('#'+formName).submit();
	}
	if(formName == 'dispLoadForm' && document.getElementById('message').style.display != 'block') {
		document.getElementById('pageNo').value = parseInt(document.getElementById('pageNo').value)+1;
		$('#'+formName).submit();
	}
}

function showErrorMessage(flag) {
	document.getElementById('message').style.display = flag;
}

function clearPreviousSearchHiddenFields() {
	document.getElementById('pageNo').value=1;
	document.getElementById('LoadStatus').value="";
	document.getElementById('LoadNumber').value="";
	document.getElementById('Office').value="";
	document.getElementById('ShipperState').value="";
	document.getElementById('ConsigneeState').value="";
	document.getElementById('CustomerName').value="";
	document.getElementById('StartDate').value="";
	document.getElementById('EndDate').value="";
	document.getElementById('CarrierName').value="";
	document.getElementById('CustomerPO').value="";
	document.getElementById('weekMonth').value="";
}

function sortTableBy(fieldName, formName) { 
	if(document.getElementById('sortBy').value == fieldName) {
		if(document.getElementById('sortOrder').value == "ASC")
			document.getElementById('sortOrder').value = "DESC"
		else if(document.getElementById('sortOrder').value == "DESC")
			document.getElementById('sortOrder').value = "ASC"
	}
	document.getElementById('sortBy').value = fieldName;
	$('#'+formName).submit();
}

function showWarningEnableButton(flagWarning, stopid) {
	document.getElementById('milesUpdateMode'+stopid).value = "manual";
	document.getElementById('warning'+stopid).style.display =flagWarning;
	if(flagWarning == "block"){
	}
}

// Open Choose carrier
function chooseCarrier() {
	document.getElementById("selectedCarrierValue").value = '';
	document.getElementById("CarrierInfo").style.display = 'none';
	document.getElementById('choosCarrier').style.display = 'block';
	document.getElementById('carrier_id').value = "";
	$('[name=carrierID]').val("");//2 elements with same id. That why we need add this
	$('.div_freightBroker').show();
	$('.div_freightBrokerHeading').hide();
	//Reset the carrier currency to the default system currency on carrier removal
	$('#defaultCarrierCurrency option[value=' +$("#defaultSystemCurrency").val()+']').prop('selected', true);
	$('#defaultCarrierCurrency').trigger("change");
    $("#loadManualNo").trigger("onblur");   
    $("#stOffice").empty();
    $('#stOffice').append($('<option>', { value : '' }).text('Choose a Satellite Office Contact'));
    $('[name="driver"]').val("")
    $('[name="driverCell"]').val("");
    $('[name="driverCell"]').removeAttr("readonly");
    $('[name="driverCell"]').removeAttr("style");
    $('[name="driverCell"]').css("background-color","#fff");
    $('[name="driverCell"]').css("width","110px !important");
    $('[name="driverCell"]').parent().find(".InfotoolTip").hide();
    $('[name="Secdriver"]').val("")
    $('[name="secDriverCell"]').val("");

    if($("input[name='driver']").hasClass('ui-autocomplete-input')) {
        $("input[name='driver']").autocomplete("destroy");
    }
    if($("input[name='Secdriver']").hasClass('ui-autocomplete-input')) {
        $("input[name='Secdriver']").autocomplete("destroy");
    }
}

function chooseCarrier2() {
	document.getElementById("selectedCarrierValue2_1").value = '';
	document.getElementById("CarrierInfo2_1").style.display = 'none';
	document.getElementById('choosCarrier2_1').style.display = 'block';
	document.getElementById('carrierID2_1').value = "";
	$('[name=carrierID2_1]').val("");
}
function chooseCarrier3() {
	document.getElementById("selectedCarrierValue3_1").value = '';
	document.getElementById("CarrierInfo3_1").style.display = 'none';
	document.getElementById('choosCarrier3_1').style.display = 'block';
	document.getElementById('carrierID3_1').value = "";
	$('[name=carrierID3_1]').val("");
}

function chooseCarrierNext2(stopno) {
	document.getElementById("selectedCarrierValue2_"+stopno).value = '';
	document.getElementById("CarrierInfo2_"+stopno).style.display = 'none';
	document.getElementById('choosCarrier2_'+stopno).style.display = 'block';
	document.getElementById('carrierID2_'+stopno).value = "";
	$('[name=carrierID2_'+stopno+']').val("");
}
function chooseCarrierNext3(stopno) {
	document.getElementById("selectedCarrierValue3_"+stopno).value = '';
	document.getElementById("CarrierInfo3_"+stopno).style.display = 'none';
	document.getElementById('choosCarrier3_'+stopno).style.display = 'block';
	document.getElementById('carrierID3_'+stopno).value = "";
	$('[name=carrierID3_'+stopno+']').val("");
}

// Removes leading whitespaces
function LTrim( value ) {	
	var re = /\s*((\S+\s*)*)/;
	return value.replace(re, "$1");
}

// Removes ending whitespaces
function RTrim( value ) {
	var re = /((\s*\S+)*)\s*/;
	return value.replace(re, "$1");
}

// Removes leading and ending whitespaces
function trim( value ) {
	return LTrim(RTrim(value));
}


function chooseCarrierNext(stopid) {
	document.getElementById("selectedCarrierValue"+stopid).value = '';
	document.getElementById("CarrierInfo"+stopid).style.display = 'none';
	document.getElementById('choosCarrier'+stopid).style.display = 'block';
	document.getElementById('carrier_id'+stopid).value = "";
	document.getElementById('carrierID'+stopid).value = "";	
	$('.div_freightBroker'+stopid).show();
	$('.div_freightBrokerHeading'+stopid).hide();
	$("#stOffice"+stopid).empty();
    $('#stOffice'+stopid).append($('<option>', { value : '' }).text('Choose a Satellite Office Contact'));
}

// Go for edit carrier
function editCarrier(url) {
	var carrId = document.getElementById("carrierID").value; 
	if (carrId == '') {
		alert('Please select a carrier');
		return false;	
	} else {
		location.href=url + '&carrierid=' + carrId; 
	}
}

function editCarrierNext(url,stopid) {
	var carrId = document.getElementById("carrierID"+stopid).value; 
	if (carrId == '') {
		alert('Please select a carrier');
		return false;	
	} else {
		location.href=url + '&carrierid=' + carrId; 
	}
}

function getAjaxCarrierInfoFormHandler(newCarrierFrm) {
	document.getElementById('CarrierInfo').innerHTML = newCarrierFrm;
}

function useCarrierNext(aDsn,lFlag,stopid,urltoken) {
	var carrId = document.getElementById("carrierID"+stopid).value; 
	var CompanyID = document.getElementById("CompanyID").value; 
	if( $('#editid').length )  {
		var editid=$("#editid").val();
	}
	else{
		var editid='';
	}

	var stopID_temp = stopid;
	if (carrId == '') {
		if (lFlag == 1) {
			alert('Please select a carrier');
			return false;
		}	
	} else {
		document.getElementById("CarrierInfo"+stopid).style.display = 'block';
		document.getElementById('choosCarrier'+stopid).style.display = 'none';
        var path = urlComponentPath+"loadgateway.cfc?method=getAjaxCarrierInfoFormNext";
        var newCarrierFrm = "";
        $.ajax({
            type: "get",
            url: path,		
            dataType: "json",
            data: {
                dsn: aDsn,
                carrierId: carrId,
                stopNo: stopid,
                urltoken: urltoken,
                loadID:editid,
                CompanyID:CompanyID
              },
            success: function(data){
              getAjaxCarrierInfoFormNextHandler(data)
            }
        });
	}
}

function getAjaxCarrierInfoFormNextHandler(response) {
	newCarrierFrm = response;
	var stopid = newCarrierFrm.DATA[0][0];
	var newCarrierFrm = newCarrierFrm.DATA[0][1];
	document.getElementById('CarrierInfo'+stopid).innerHTML = newCarrierFrm;

	$('.CarrEmail').each(function(i, tag) {
        var carrID = $( this ).data( "carrid" );
        $(tag).autocomplete({
            multiple: false,
            width: 450,
            scroll: true,
            scrollHeight: 300,
            cacheLength: 1,
            highlight: false,
            dataType: "json",
            minLength:0,
            source: 'searchCarrierContactAutoFill.cfm?carrierID='+carrID,
            select: function(e, ui) { 
            	$('#CarrierPhoneNo'+stopid).val(ui.item.phoneno);
                $('#CarrierPhoneNoExt'+stopid).val(ui.item.phonenoext);
                $('#CarrierFax'+stopid).val(ui.item.fax);
                $('#CarrierFaxExt'+stopid).val(ui.item.faxext);
                $('#CarrierTollFree'+stopid).val(ui.item.tollfree);
                $('#CarrierTollFreeExt'+stopid).val(ui.item.tollfreeext);
                $('#CarrierCell'+stopid).val(ui.item.PersonMobileNo);
                $('#CarrierCellExt'+stopid).val(ui.item.MobileNoExt);
            },
        }).focus(function() { 
	        	$(this).keydown();
	        })
        $(tag).data("ui-autocomplete")._renderItem = function(ul, item) {
            return $( "<li><b><u>Email</u>:</b> "+item.email+"<br/><b><u>Contact</u>:</b> "+ item.ContactPerson+"&nbsp;&nbsp;&nbsp;<b><u>Phone</u>:</b> "+ item.phoneno+"<br/><b><u>cell</u>:</b> " + item.PersonMobileNo+"&nbsp;&nbsp;&nbsp;<b><u>Type</u>:</b> " + item.ContactType+"</li>" )
                    .appendTo( ul );
        }
    })
}

function noCarrier() {
	document.getElementById("carrierID").value=''; 
	document.getElementById("selectedCarrierValue").value = '';	
	document.getElementById("CarrierInfo").style.display = 'none';
	document.getElementById('choosCarrier').style.display = 'block';
	var k;
	for(k=document.getElementById("stOffice").options.length-1;k>=0;k--)
	{
		document.getElementById("stOffice").remove(k);
	}
	
	var optn = document.createElement("OPTION");
	optn.text = 'Choose a Satellite Office Contact';
	optn.value = '';
	document.getElementById("stOffice").options.add(optn);
}

function noCarrierNext(stopNo) {
	document.getElementById("carrierID"+stopNo).value=''; 
	document.getElementById("selectedCarrierValue"+stopNo).value = '';	
	document.getElementById("CarrierInfo"+stopNo).style.display = 'none';
	document.getElementById('choosCarrier'+stopNo).style.display = 'block';
	var k;
	for(k=document.getElementById("stOffice"+stopNo).options.length-1;k>=0;k--)
	{
		document.getElementById("stOffice"+stopNo).remove(k);
	}
	
	var optn = document.createElement("OPTION");
	optn.text = 'Choose a Satellite Office Contact';
	optn.value = '';
	document.getElementById("stOffice"+stopNo).options.add(optn);
}
//check for free unit

function checkForFee(unitId,itemRowNo,stopNo,aDsn) {

	var isfree = false;
	var CompanyID=document.getElementById("CompanyID").value;
    var path = urlComponentPath+"loadgateway.cfc?method=checkAjaxFeeUnit";
    $.ajax({
        type: "get",
        url: path,		
        dataType: "json",
        async: false,
        data: {
            dsn: aDsn,
            unitId: unitId,
            CompanyID:CompanyID
          },
        success: function(data){
          retValue = data;
        }
    }); 
  
	var fsctext = "milse";
	isfree = retValue[0];
	carrier_id=$('#carrier_id'+stopNo).val();
	frmfld = document.getElementById('isFee'+stopNo+'_'+itemRowNo);
	PaymentAdvance = retValue[4];
	try {
		if (isfree === true || isfree == 'true'){
			frmfld.checked = true;
		}
		else{
			frmfld.checked = false;
		}
		
		if(itemRowNo==1 && stopNo == ''){
			frmfld0 = document.getElementById('isFee'+stopNo+'_'+0);
			if (isfree === true || isfree == 'true'){
				frmfld0.checked = true;
			}
			else{
				frmfld0.checked = false;
			}
			document.getElementById('description'+stopNo+'_'+0).value = retValue[1];
		}

		document.getElementById('description'+stopNo+'_'+itemRowNo).value = retValue[1];
		if($("#defaultCarrierCurrency").length){
			if($("#customerDefaultCurrency").val() == $("#defaultCustomerCurrency").val()){
				document.getElementById('CustomerRate'+stopNo+'_'+itemRowNo).value = retValue[2];//'$'+
			}else{
				document.getElementById('CustomerRate'+stopNo+'_'+itemRowNo).value = 0;
			}
			if($("#carrierDefaultCurrency").val() == $("#defaultCarrierCurrency").val()){
				document.getElementById('CarrierRate'+stopNo+'_'+itemRowNo).value = retValue[3];//'$'+
			}else{
				document.getElementById('CarrierRate'+stopNo+'_'+itemRowNo).value = 0;
			}
		}else{
			document.getElementById('CustomerRate'+stopNo+'_'+itemRowNo).value = '$'+retValue[2];
			document.getElementById('CarrierRate'+stopNo+'_'+itemRowNo).value = '$'+retValue[3];
			formatDollarNegative(retValue[2],'CustomerRate'+stopNo+'_'+itemRowNo)
			formatDollarNegative(retValue[3],'CarrierRate'+stopNo+'_'+itemRowNo)
		}
		
		if(PaymentAdvance==1){
			$('#CustomerRate'+stopNo+'_'+itemRowNo).css('color','red');
			$('#CarrierRate'+stopNo+'_'+itemRowNo).css('color','red');
			DollarParenthesisFormat('CustomerRate'+stopNo+'_'+itemRowNo)
			DollarParenthesisFormat('CarrierRate'+stopNo+'_'+itemRowNo)
		}
		else{
			$('#CustomerRate'+stopNo+'_'+itemRowNo).css('color','black');
			$('#CarrierRate'+stopNo+'_'+itemRowNo).css('color','black');
		}
		try {
			var index = document.getElementById('type'+stopNo+'_'+itemRowNo).selectedIndex;
			var unittype = document.getElementById('type'+stopNo+'_'+itemRowNo).options[index].text;
			if(carrier_id.length){
				getCarrierCommodityValue(carrier_id,"type",stopNo);
			}
		}
		catch(e) {
			var index = document.getElementById('unit'+stopNo+'_'+itemRowNo).selectedIndex;
			var unittype = document.getElementById('unit'+stopNo+'_'+itemRowNo).options[index].text;
			if(carrier_id.length){
				getCarrierCommodityValue(carrier_id,"unit",stopNo);
			}
		}
		if(unittype.indexOf("FSC Mxxx") > -1) {
			if(stopNo>1){
				 fsctext = "milse"+stopNo;	
			}
			document.getElementById('qty'+stopNo+'_'+itemRowNo).value = document.getElementById(fsctext).value;
		}	
	}
	catch(e) {
		console.log(e);
	}
	CalculateTotal(aDsn);
}

function DollarParenthesisFormat(id){
	var val = $('#'+id).val();
	if(val.replace('$','').replace(/,/g,'') > 0){
		$('#'+id).val('('+val+')');
	}

}

function DisplayIntextField(fldVal,dsn) {
	var path = urlComponentPath+"loadgateway.cfc?method=getAjaxSatelliteOfficeBindable";
    var newCarrierOffice = "";
  
    $.ajax({
        type: "get",
        url: path,		
        dataType: "json",
        async: false,
        data: {
            carrierid: fldVal,
            dsn: dsn
          },
        success: function(data){
          newCarrierOffice = data;
        }
    });
  
	var k;
	for(k=document.getElementById("stOffice").options.length-1;k>=0;k--) {
		document.getElementById("stOffice").remove(k);
	}
	
	for (var j=0;j<newCarrierOffice.length;j++) {
		var optn = document.createElement("OPTION");
		optn.text = newCarrierOffice[j][1];
		optn.value = newCarrierOffice[j][0];
		document.getElementById("stOffice").options.add(optn);
	}
	document.getElementById("carrierID").value = fldVal;
}

function DisplayIntextFieldNext(fldVal,stopid,dsn) {
	document.getElementById("carrierID"+stopid).value = fldVal;
    var path = urlComponentPath+"loadgateway.cfc?method=getAjaxSatelliteOfficeBindable";
    var newCarrierOffice = "";
  
    $.ajax({
        type: "get",
        url: path,		
        dataType: "json",
        async: false,
        data: {
            carrierid: fldVal,
            dsn: dsn
          },
        success: function(data){
          newCarrierOffice = data;
        }
    });
  
	var k;
	for(k=document.getElementById("stOffice"+stopid).options.length-1;k>=0;k--)	{
		document.getElementById("stOffice"+stopid).remove(k);
	}
	
	for(var j=0;j<newCarrierOffice.length;j++)	{
		var optn = document.createElement("OPTION");
		optn.text = newCarrierOffice[j][1];
		optn.value = newCarrierOffice[j][0];
		document.getElementById("stOffice"+stopid).options.add(optn);
	}
}

//ajax function to load all the tabs that are not needed and are to be made invisble(helps the page to be faster)
function ajaxloadNextStops(loadid, totStops, LoadNumber, currentTab) {
	if(LoadNumber == "novalue")	{
		LoadNumber = '';
	}
	$.ajax({
        type: "get",
        url: "index.cfm?event=nextStopLoad&loadid="+loadid+"&LoadNumber="+LoadNumber+"&totStops="+totStops+"&currentTab="+currentTab,		 dataType: "html",
        success: function(response){
			//append all the tabs to the form(id - load)
			$( "#load" ).append(response);
			
			//initialise all the tabs again
			$( ".tabsload" ).tabs({
				beforeLoad: function( event, ui ) {
					ui.jqXHR.error(function() {
						ui.panel.html(
							"Couldn't load this tab. We'll try to fix this as soon as possible. " +
							"If this wouldn't be a demo." 
						);
					});
				}
			});
			
			//initialise all the datepickers again for the new tabs
			$( ".datefield" ).datepicker({ 
              dateFormat: "mm/dd/yy",
              showOn: "button",
              buttonImage: "images/DateChooser.png",
              buttonImageOnly: true
            });
			
			//remove the disabled attributes of the input fields of the newly loaded tabs
			if($.trim($('#load input[name="loadnumber"]').val()).length == 0){
				var loaddisabledStatus=$("#loaddisabledStatus").val();
				if (loaddisabledStatus == 'false'){
					$('#load input[name="save"]').removeAttr('disabled');
					$('#load input[name="submit"]').removeAttr('disabled');
					$('#load input[name="saveexit"]').removeAttr('disabled');
					$('#load input[name="addstopButton"]').removeAttr('disabled');
				}	
			}
        }
    });
}

function AddStop(stopName,stopid) {
	var LoadNumber = $.trim($('#LoadNumber').val());
	var editid=$("#editid").val();
	if (typeof editid == 'undefined') {
		editid = 0;
	}
	$.ajax({
        type: "get",
        url: "index.cfm?event=nextStopLoad&loadid="+editid+"&LoadNumber="+LoadNumber+"&stopNo="+stopid,
        dataType: "html",
        success: function(response){
			//append all the tabs to the form(id - load)
			$( "#load" ).append(response);
			
			//initialise all the tabs again
			$( ".tabsload" ).tabs({
				beforeLoad: function( event, ui ) {
					ui.jqXHR.error(function() {
						ui.panel.html(
							"Couldn't load this tab. We'll try to fix this as soon as possible. " +
							"If this wouldn't be a demo." 
						);
					});
				}
			});
			
			//initialise all the datepickers again for the new tabs
			$( ".datefield" ).datepicker({ 
              dateFormat: "mm/dd/yy",
              showOn: "button",
              buttonImage: "images/DateChooser.png",
              buttonImageOnly: true
            });
			
			//remove the disabled attributes of the input fields of the newly loaded tabs
			if($.trim($('#load input[name="loadnumber"]').val()).length == 0){
				var loaddisabledStatus=$("#loaddisabledStatus").val();
				if (loaddisabledStatus == 'false'){
					$('#load input[name="save"]').removeAttr('disabled');
					$('#load input[name="submit"]').removeAttr('disabled');
					$('#load input[name="saveexit"]').removeAttr('disabled');
					$('#load input[name="addstopButton"]').removeAttr('disabled');
				}	
			}

			if(editid !=0){
				var Totalcount=$('#totalResult'+stopid).val();
				for(i=2;i<=Totalcount;i++){
					$('#commodities'+stopid+'_'+i).remove();
				}
				$('#TotalrowCommodities'+stopid).val(1);
				$('#totalResult'+stopid).val(1);
				$('#commoditityAlreadyCount'+stopid).val(1);
				
				$('#isFee'+stopid+'_1').prop('checked',false);
				$('#unit'+stopid+'_1 option[value=""]').attr("selected", "selected");
				$('#class'+stopid+'_1 option[value=""]').attr("selected", "selected");
				$('#description'+stopid+'_1').val('');
				$('#weight'+stopid+'_1').val(0);
				
				if($("#defaultCarrierCurrency").length){
					$('#CustomerRate'+stopid+'_1').val('0.00');//$
					$('#CarrierRate'+stopid+'_1').val('0.00');//$
					$('#CarrierPer'+stopid+'_1').val('0.00%');
					$('#custCharges'+stopid+'_1').val('0.00');//$
					$('#carrCharges'+stopid+'_1').val('0.00');//$
				}else{
					$('#CustomerRate'+stopid+'_1').val('$0.00');
					$('#CarrierRate'+stopid+'_1').val('$0.00');
					$('#CarrierPer'+stopid+'_1').val('0.00%');
					$('#custCharges'+stopid+'_1').val('$0.00');
					$('#carrCharges'+stopid+'_1').val('$0.00');
				}
			}
			document.getElementById(stopName).style.display='block';
			$('input[type=text]').addClass('myElements');
		    $('input[type=checkbox]').addClass('myElements');
			$('input[type=datefield]').addClass('myElements');
		    $('select').addClass('myElements');
		    $('textarea').addClass('myElements');
			var prevStopId=stopid-1;
			if(prevStopId==1){prevStopId=""}
			$('#consigneeValueContainer'+stopid).val($('#consigneeValueContainer'+prevStopId).val());
			document.getElementById('shipperstate'+stopid).onchange();
			if(trim($('#shipperlocation'+prevStopId).val()) == "" ||  trim($('#consigneelocation'+prevStopId).val()) == "" ){
				document.getElementById("milse"+stopid).value = 0;
			}
			document.getElementById("milse").onchange();
			document.getElementById('totalStop').value=stopid;
			document.getElementById('shipper'+stopid).focus();
			resetAddStopButton();
			setStopValue();
        }
    });
}

function resetAddStopButton(){
	var totalStop = parseInt(document.getElementById('totalStop').value);
    $('input[name=addstopButton]').attr("onclick","AddStop('stop"+(totalStop+1)+"',"+(totalStop+1)+");setStopValue();")
}

function deleteStop(stopName,stopNo,flag,stopID,aDsn,loadID) {
	var deleteYN=false;
	if(flag == true && $('#editid').length) {
 		deleteYN = confirm('Are you sure to delete this stop?')
 		if (deleteYN) {
            var frieghtBroker=$('#frieghtBroker').val();                    
            var PostTo123LoadBoard=$('#PostTo123LoadBoard').val();                    
            var loadBoard123=$('#loadBoard123').val();                    
            var Is123LoadBoardPst=$('#Is123LoadBoardPst').val();                    
            var path = urlComponentPath+"loadgateway.cfc?method=ajaxDeleteStops";
            var  pathDeleteSingleLoad= urlComponentPath+"loadgateway.cfc?method=delete123LoadBoardWebserviceSeparate";
            var confirmDeleteStop = "";
			if (frieghtBroker==1 && PostTo123LoadBoard==1 && loadBoard123==1 && Is123LoadBoardPst==1){
				var username=$('#loadBoard123Username').val(); 	
				var password=$('#loadBoard123Password').val(); 	
				$.ajax({
					type: "get",
					url: pathDeleteSingleLoad,		
					dataType: "json",
					async: false,
					data: {
						   dsn: aDsn,
						loadStopId: stopID,
						username:username,
						password:password
					  },
					success: function(data){
					  
					}
				});		
			}

            $.ajax({
                type: "get",
                url: path,		
                dataType: "json",
                async: false,
                data: {
                    dsn: aDsn,
                    stopID: stopID,
                    stopNo: stopNo,
                    LoadID: loadID
                  },
                success: function(data){
					confirmDeleteStop = data.transaction;
					if(data.transaction)
					{
					    document.getElementById(stopName).style.display='none';
					    document.getElementById("milse").onchange();
						
					}
                }
            });							
 		}
	} else {
		document.getElementById(stopName).style.display='none';
		document.getElementById("milse").onchange();
	}
	 
	if(document.getElementById('totalStop').value==(stopNo+1)){
		document.getElementById('totalStop').value=(document.getElementById('totalStop').value-1)
	}
	strStopLinks = "";

	for(i=1;i<=document.getElementById('totalStop').value;i++) {
		if(i!=(stopNo+1))
			strStopLinks = strStopLinks+"<li><a href='#StopNo"+i+"'>#"+i+"</a></li>";
	}
	for(j=1;j<=document.getElementById('totalStop').value;j++) {
		if(document.getElementById('ulStopNo'+j))
			document.getElementById('ulStopNo'+j).innerHTML = strStopLinks;
	}
	//show add stop btn    
    var ary = [];
    var ary2 = []
    for(i=2;i<11;i++) {
        ($('#stop'+i).css('display')=="block" ? ary.push(i):ary2.push(i));
        $('#stop'+i+'h2').text('Stop '+i);
    }
    k = ary[ary.length-1]
    
    $('#stop'+k+' .green-btn[value="Add Stop"]').show();
    if(ary.length == 0){
        $('#tabs1 .green-btn[value="Add Stop"]').show();
    }
    resetAddStopButton();
}

function eDispatch(aDsn, loadID, userid){
	console.log(urlComponentPath);
        var  pathDispatchLoad= urlComponentPath+"loadgateway.cfc?method=carrierDispatchLoad";
        console.log(aDsn);
        console.log(loadID);

		$.ajax({
			type: "post",
			url: pathDispatchLoad,		
			dataType: "json",
			async: false, 
			data: {
				dsn: aDsn,
				loadID: loadID,
				userid: userid
			},
			success: function(data){
				console.log(data);
				alert(data);
			}
		});		
	/*} else {
		
	}*/
}


function CheckStops(frmState,frmlocation) {
	var location=frmlocation.value;
	if(location=="") {
		alert('Please enter the address');
		frmlocation.focus();
		return false;
	}
	var state=frmState.value;
	if(state=="") {
		alert('Please select a state');
		frmState.focus();
		return false;
	}
}

function CheckCarrier(frmaddress,frmstate,frmcountry,frmequipment) {
	var address=frmaddress.value;
	if(address=="")	{
		alert('Please enter the address');
		frmaddress.focus();
		return false;
	}
	
	var state=frmstate.value;
	if(state=="") {
		alert('Please select a state');
		frmstate.focus();
		return false;
	}
	var country=frmcountry.value;
	if(country=="")	{
		alert('Please select a country');
		frmcountry.focus();
		return false;
	}
	var equipment=frmequipment.value;
	if(equipment=="") {
	    alert('Please select an equipment');
		frmequipment.focus();
		return false;	
	}
}
	
var loadExported = false;
	
function enableDisableMainCalcFields(flag){
	document.getElementById('TotalCarrierCharges').disabled = flag;
	document.getElementById('TotalCustomerCharges').disabled = flag;
	document.getElementById('CustomerMilesCalc').disabled = flag;
	document.getElementById('CarrierMilesCalc').disabled = flag;
	if(document.getElementById('totalProfit') != null)
		document.getElementById('totalProfit').disabled = flag;
	document.getElementById('ARExported').disabled = flag;
	document.getElementById('APExported').disabled = flag;
	document.getElementById('CustomerRate').disabled = flag;
	document.getElementById('CarrierRate').disabled = flag;

	if(flag==true){
		$("[name='save']").show();
		$("[name='saveexit']").show();
		$(".loadOverlay").hide();
	}
	else{
		$("[name='save']").hide();
		$("[name='saveexit']").hide();
		$(".loadOverlay").show();
	}
}

function saveButStayOnPage(loadid) {

	var focused = $( document.activeElement )
	var fID = $( focused ).closest('[id^=stop]').attr('id');
	$('#focusStop').val("");
	if(fID != undefined){
		$('#focusStop').val(fID);
	}
	
	if($.trim($('#noOfTrips').val()).length==0){
		alert('Please enter a value into About How Many Trips');
		$('#noOfTrips').focus();
		return false;
	}
	
	if($('#totalStop').val() == 1){
		var stpIndx = '';
	}
	else{
		var stpIndx = $('#totalStop').val();
	}
	var endDeliveryDate = $('#consigneePickupDate'+stpIndx).val();
	var selStatusText = $.trim($( "#loadStatus option:selected" ).data('statustext'));
	var RequireDeliveryDate = $('#RequireDeliveryDate').val();
	if(RequireDeliveryDate==1 && !$.trim(endDeliveryDate).length && selStatusText >= '1. ACTIVE' && selStatusText <= '9. Cancelled'){
		alert('Please enter final delivery date.');
		$('#consigneePickupDate'+stpIndx).focus();
		return false;
	}
	
	var miles1 = document.getElementById('milse').value;
	if(isNaN(miles1) || !miles1.length){
		document.getElementById('milse').value=0;
		alert('Inavlid miles');
		document.getElementById('milse').focus();
	}

	if($('#ediLoad').val()==1){
	if ($.trim($( "#loadStatus option:selected" ).text())== "4. LOADED"){
		if($('option:selected','#shipperConsignee').attr('data-code').indexOf('S') == -1)
    		{
	            alert('Please choose a pickup location (e.g. 1S, 2S)');
	            $('#shipperConsignee').focus();
	            return false;
	        }
        }
        else if($.trim($( "#loadStatus option:selected" ).text())== "4.1 ARRIVED" || $.trim($( "#loadStatus option:selected" ).text())== "5. DELIVERED" ){
		 	if($('option:selected','#shipperConsignee').attr('data-code').indexOf('C') == -1)
	    		{
		            alert('Please choose a delivery location (e.g. 1C, 2C)');
		            $('#shipperConsignee').focus();
		            return false;
		        }
	      }

	      /*Validate Time In, Time Out on Save*/
	      var inputs = $(".edidatetime");

	      for(var i = 0; i < inputs.length; i++){
	      		if($(inputs[i]).attr('id').indexOf('shipperTimeIn') != -1){

	      			var shipperTimeInId = $(inputs[i]).attr('id');	      			
	      			
	      			var oldShipperTimeIn = shipperTimeInId.replace('shipperTimeIn','oldShipperTimeIn');
	      			var shipperTimeOut = shipperTimeInId.replace('shipperTimeIn','shipperTimeOut'); 
	      			var oldshipperTimeOut = shipperTimeInId.replace('shipperTimeIn','oldshipperTimeOut');
	      			var shipperpickupTime = shipperTimeInId.replace('shipperTimeIn','shipperpickupTime');
	      			var oldshipperpickupTime = shipperTimeInId.replace('shipperTimeIn','oldShipperpickupTime');
	      			var shipperpickupDate = shipperTimeInId.replace('shipperTimeIn','shipperPickupDate');

					var shipperStopdateQ = shipperTimeInId.replace('shipperTimeIn','ShipperStopDateQ');  
					var varshipperEdiReasonCodeId = shipperTimeInId.replace('shipperTimeIn','shipperEdiReasonCode'); 
					var varshipperEdiReasonLabelId = shipperTimeInId.replace('shipperTimeIn','labelShipperTimein'); 

					/*shipper time in changed */
	      			if($.trim($('#'+oldShipperTimeIn).val()) != $.trim($('#'+shipperTimeInId).val())
	      				|| $.trim($('#'+oldshipperpickupTime).val()) != $.trim($('#'+shipperpickupTime).val())
	      			 ){
	      			 	
	      			 	

	      			 	if($.trim($('#'+oldShipperTimeIn).val()) != $.trim($('#'+shipperTimeInId).val())){
	      			 		var hourPart = $('#'+shipperTimeInId).val().substr(0, 2);
							var minutePart = $('#'+shipperTimeInId).val().substr(2, 2);
							if(hourPart > 23 || minutePart > 59){
								alert('Please enter valid pick up time-in in HHMM format');
								return false;
							}

							

	      			 	}
	      			 	
	      			 	if($.trim($('#'+oldshipperpickupTime).val()) != $.trim($('#'+shipperpickupTime).val())){
	      			 		var hourPart = $('#'+shipperpickupTime).val().substr(0, 2);
							var minutePart = $('#'+shipperpickupTime).val().substr(2, 2);
							if(hourPart > 23 || minutePart > 59){
								alert('Please enter valid pick up Apt. time in HHMM format');
								return false;
							}
	      			 		
	      			 	}
	      				
	      				if($.trim($('#'+shipperTimeInId).val()).length && $.trim($('#'+shipperTimeOut).val()).length && ( $.trim($('#'+shipperTimeInId).val()) > $.trim($('#'+shipperTimeOut).val()))){
	      					alert ('Pickup Time In is after Time Out');
	      					return false;
	      				}


	      				/*shipper pick up time in range*/
	      				if($.trim($('#'+shipperStopdateQ).val()).indexOf('37-38') != -1 && $.trim($('#'+shipperpickupTime).val()).indexOf('-') != -1){
	      					
	      					if( !$.trim($('#'+varshipperEdiReasonCodeId).val()).length &&

	      						($('#'+shipperTimeInId).val() < $('#'+shipperpickupTime).val().substring(0,4)
								|| $('#'+shipperTimeInId).val() > $('#'+shipperpickupTime).val().substring(5,9)
							 
							 ))
	      					{
							 	alert ('Pick up Time In is not in range');
							 	$('#'+varshipperEdiReasonCodeId).css("display","block"); 
								$('.'+varshipperEdiReasonLabelId+stopnum).css("display","block"); 
								$('.'+varshipperEdiReasonLabelId+stopnum).css('color','red');
								return false;
	      					} 

	      					
	      				}
	      				else if( $('#'+shipperTimeInId).val() > $('#'+shipperpickupTime).val() 
	      						&& !$('#'+varshipperEdiReasonCodeId).val().length

	      					){
	      					alert ('Please choose the reason for late arrival');
	      						$('#'+varshipperEdiReasonCodeId).css("display","block"); 
								$('.'+varshipperEdiReasonLabelId+stopnum).css("display","block"); 
								$('.'+varshipperEdiReasonLabelId+stopnum).css('color','red');
	      					return false;
	      				}

	      				}

	      			/*shipper time out changed */
	      			if($.trim($('#'+oldshipperTimeOut).val()) != $.trim($('#'+shipperTimeOut).val()) ){
	      				var hourPart = $('#'+shipperTimeOut).val().substr(0, 2);
						var minutePart = $('#'+shipperTimeOut).val().substr(2, 2);
						if(hourPart > 23 || minutePart > 59){
							alert('Please enter valid pick up time in HHMM format');
							return false;
						}
	      				
	      				if($.trim($('#'+shipperTimeInId).val()) > $.trim($('#'+shipperTimeOut).val())){
	      					alert ('Pickup Time In is after Time Out');
	      					return false;
	      				}
	      				if($.trim($('#'+shipperStopdateQ).val()).indexOf('37-38') != -1 && $.trim($('#'+shipperpickupTime).val()).indexOf('-') != -1){
		      				if( !$.trim($('#'+varshipperEdiReasonCodeId).val()).length &&

		      						($('#'+shipperTimeOut).val() < $('#'+shipperpickupTime).val().substring(0,4)
									|| $('#'+shipperTimeOut).val() > $('#'+shipperpickupTime).val().substring(5,9)
								 
								 ))
		      					{
								 	alert ('Pick up Time Out is not in range');
								 	$('#'+varshipperEdiReasonCodeId).css("display","block"); 
									$('.'+varshipperEdiReasonLabelId+stopnum).css("display","block"); 
									$('.'+varshipperEdiReasonLabelId+stopnum).css('color','red');
									return false;
		      					} 
	      				}
	      			}
	      			
	      		}

	      		//consignee timein

	      		if($(inputs[i]).attr('id').indexOf('consigneeTimeIn') != -1){

	      			var consigneeTimeInId = $(inputs[i]).attr('id');	      			
	      			
	      			var oldConsigneeTimeIn = consigneeTimeInId.replace('consigneeTimeIn','oldConsigneeTimeIn');
	      			var consigneeTimeOut = consigneeTimeInId.replace('consigneeTimeIn','consigneeTimeOut'); 
	      			var oldconsigneeTimeOut = consigneeTimeInId.replace('consigneeTimeIn','oldConsigneeTimeOut');
	      			var consigneepickupTime = consigneeTimeInId.replace('consigneeTimeIn','consigneepickupTime');
	      			var oldconsigneepickupTime = consigneeTimeInId.replace('consigneeTimeIn','oldConsigneepickupTime');
	      			var consigneepickupDate = consigneeTimeInId.replace('consigneeTimeIn','consigneePickupDate');
					var consigneeStopdateQ = consigneeTimeInId.replace('consigneeTimeIn','ConsigneeStopDateQ');  
					var varconsigneeEdiReasonCodeId = consigneeTimeInId.replace('consigneeTimeIn','consigneeEdiReasonCode'); 
					var varconsigneeEdiReasonLabelId = consigneeTimeInId.replace('consigneeTimeIn','labelConsigneeTimein'); 

					/*consignee time in changed */
	      			if($.trim($('#'+oldConsigneeTimeIn).val()) != $.trim($('#'+consigneeTimeInId).val()) 
	      					|| $.trim($('#'+oldconsigneepickupTime).val()) != $.trim($('#'+consigneepickupTime).val())
	      				){
	      				

	      				if($.trim($('#'+oldConsigneeTimeIn).val()) != $.trim($('#'+consigneeTimeInId).val()) ){
	      			 		var hourPart = $('#'+consigneeTimeInId).val().substr(0, 2);
							var minutePart = $('#'+consigneeTimeInId).val().substr(2, 2);
							if(hourPart > 23 || minutePart > 59){
								alert('Please enter valid delivery Apt. time in HHMM format');
								return false;
							}

							
	      			 		
	      			 	}

	      			 	if($.trim($('#'+oldconsigneepickupTime).val()) != $.trim($('#'+consigneepickupTime).val()))
	      			 	{

	      				var hourPart = $('#'+consigneepickupTime).val().substr(0, 2);
						var minutePart = $('#'+consigneepickupTime).val().substr(2, 2);
						if(hourPart > 23 || minutePart > 59){
							alert('Please enter valid delivery Apt. time in HHMM format');
							return false;
						}
						}

	      				if($.trim($('#'+consigneeTimeInId).val()).length && $.trim($('#'+consigneeTimeOut).val()).length 
	      					&& (
	      					$.trim($('#'+consigneeTimeInId).val()) > $.trim($('#'+consigneeTimeOut).val()))
	      					){
	      					alert ('Delivery Time In is after Time Out');
	      					return false;
	      				}


	      				/*consignee pick up time in range*/
	      				if($.trim($('#'+consigneeStopdateQ).val()).indexOf('53-54') != -1 && $.trim($('#'+consigneepickupTime).val()).indexOf('-') != -1){
	      					var hourPart = $('#'+consigneeTimeInId).val().substr(0, 2);
							var minutePart = $('#'+consigneeTimeInId).val().substr(2, 2);
							if(hourPart > 23 || minutePart > 59){
								alert('Please enter valid time in HHMM format');
								return false;
							}
	      					if(
	      						 !$('#'+varconsigneeEdiReasonCodeId).val().length &&

	      					 ($('#'+consigneeTimeInId).val() < $('#'+consigneepickupTime).val().substring(0,4)
							|| $('#'+consigneeTimeInId).val() > $('#'+consigneepickupTime).val().substring(5,9))


							 ){
							 	alert ('Delivery Time In is not in range');
							 	$('#'+varconsigneeEdiReasonCodeId).css("display","block"); 
								$('.'+varconsigneeEdiReasonLabelId+stopnum).css("display","block"); 
								$('.'+varconsigneeEdiReasonLabelId+stopnum).css('color','red');
								return false;
	      					} 
	      				}
	      				else if( $('#'+consigneeTimeInId).val() > $('#'+consigneepickupTime).val()
	      						&& !$('#'+varconsigneeEdiReasonCodeId).val().length
	      					){
	      					alert ('Please choose the reason for late departure');
	      					$('#'+varconsigneeEdiReasonCodeId).css("display","block"); 
							$('.'+varconsigneeEdiReasonLabelId+stopnum).css("display","block"); 
							$('.'+varconsigneeEdiReasonLabelId+stopnum).css('color','red');
								
	      					return false;
	      				}

	      				}

	      			/*consignee time out changed */
	      			if($.trim($('#'+oldconsigneeTimeOut).val()) != $.trim($('#'+consigneeTimeOut).val()) ){
	      				var hourPart = $('#'+consigneeTimeOut).val().substr(0, 2);
						var minutePart = $('#'+consigneeTimeOut).val().substr(2, 2);
						if(hourPart > 23 || minutePart > 59){
							alert('Please enter valid delivery time out in HHMM format');
							return false;
						}
	      				
	      				if($.trim($('#'+consigneeTimeInId).val()).length && $.trim($('#'+consigneeTimeOut).val()).length 
	      					&& (
	      					$.trim($('#'+consigneeTimeInId).val()) > $.trim($('#'+consigneeTimeOut).val()))
	      					){
	      					alert ('Delivery Time In is after Time Out');
	      					return false;
	      				}

	      				if($.trim($('#'+consigneeStopdateQ).val()).indexOf('53-54') != -1 && $.trim($('#'+consigneepickupTime).val()).indexOf('-') != -1){

	      				if( !$.trim($('#'+varconsigneeEdiReasonCodeId).val()).length &&

	      						($('#'+consigneeTimeOut).val() < $('#'+consigneepickupTime).val().substring(0,4)
								|| $('#'+consigneeTimeOut).val() > $('#'+consigneepickupTime).val().substring(5,9)
							 
							 ))
	      					{
							 	alert ('Delivery Time Out is not in range');
							 	$('#'+varconsigneeEdiReasonCodeId).css("display","block"); 
								$('.'+varconsigneeEdiReasonLabelId+stopnum).css("display","block"); 
								$('.'+varconsigneeEdiReasonLabelId+stopnum).css('color','red');
								return false;
	      					} 
	      				}
	      			}
	      			
	      		}
			    

			}

			
	 }     	
	if($('#BillFromCompany').length){
	 	var defaultBillFromCompany = $('#BillFromCompany').val()
		if (!$.trim(defaultBillFromCompany).length) {
			alert("Select a Bill From Company");
			$('#BillFromCompany').focus();
			return false;
		}
	}
	 
	
	if(checkLoad())	{
		document.getElementById('loadToSaveWithoutExit').value = loadid;
		return true;
	}
	return false; 
}

function saveButExitPage(loadid){
	if($.trim($('#noOfTrips').val()).length==0){
		alert('Please enter a value into About How Many Trips');
		$('#noOfTrips').focus();
		return false;
	}
	if($('#ediLoad').val()==1){
	if ($.trim($( "#loadStatus option:selected" ).text())== "4. LOADED"){
		if($('option:selected','#shipperConsignee').attr('data-code').indexOf('S') == -1)
    		{
	            alert('Please choose a pickup location (e.g. 1S, 2S)');
	            $('#shipperConsignee').focus();
	            return false;
	        }
        }
        else if($.trim($( "#loadStatus option:selected" ).text())== "4.1 ARRIVED" || $.trim($( "#loadStatus option:selected" ).text())== "5. DELIVERED" ){
		 	if($('option:selected','#shipperConsignee').attr('data-code').indexOf('C') == -1)
	    		{
		            alert('Please choose a delivery location (e.g. 1C, 2C)');
		            $('#shipperConsignee').focus();
		            return false;
		        }
	      }

	      /*Validate Time In, Time Out on Save*/
	      var inputs = $(".edidatetime");

	      for(var i = 0; i < inputs.length; i++){
	      		if($(inputs[i]).attr('id').indexOf('shipperTimeIn') != -1){

	      			var shipperTimeInId = $(inputs[i]).attr('id');	      			
	      			
	      			var oldShipperTimeIn = shipperTimeInId.replace('shipperTimeIn','oldShipperTimeIn');
	      			var shipperTimeOut = shipperTimeInId.replace('shipperTimeIn','shipperTimeOut'); 
	      			var oldshipperTimeOut = shipperTimeInId.replace('shipperTimeIn','oldshipperTimeOut');
	      			var shipperpickupTime = shipperTimeInId.replace('shipperTimeIn','shipperpickupTime');
	      			var oldshipperpickupTime = shipperTimeInId.replace('shipperTimeIn','oldShipperpickupTime');
	      			var shipperpickupDate = shipperTimeInId.replace('shipperTimeIn','shipperPickupDate');

					var shipperStopdateQ = shipperTimeInId.replace('shipperTimeIn','ShipperStopDateQ');  
					var varshipperEdiReasonCodeId = shipperTimeInId.replace('shipperTimeIn','shipperEdiReasonCode'); 
					var varshipperEdiReasonLabelId = shipperTimeInId.replace('shipperTimeIn','labelShipperTimein'); 

					/*shipper time in changed */
	      			if($.trim($('#'+oldShipperTimeIn).val()) != $.trim($('#'+shipperTimeInId).val())
	      				|| $.trim($('#'+oldshipperpickupTime).val()) != $.trim($('#'+shipperpickupTime).val())
	      			 ){
	      			 	
	      			 	

	      			 	if($.trim($('#'+oldShipperTimeIn).val()) != $.trim($('#'+shipperTimeInId).val())){
	      			 		var hourPart = $('#'+shipperTimeInId).val().substr(0, 2);
							var minutePart = $('#'+shipperTimeInId).val().substr(2, 2);
							if(hourPart > 23 || minutePart > 59){
								alert('Please enter valid pick up time-in in HHMM format');
								return false;
							}

							

	      			 	}
	      			 	
	      			 	if($.trim($('#'+oldshipperpickupTime).val()) != $.trim($('#'+shipperpickupTime).val())){
	      			 		var hourPart = $('#'+shipperpickupTime).val().substr(0, 2);
							var minutePart = $('#'+shipperpickupTime).val().substr(2, 2);
							if(hourPart > 23 || minutePart > 59){
								alert('Please enter valid pick up Apt. time in HHMM format');
								return false;
							}
	      			 		
	      			 	}
	      				
	      				if($.trim($('#'+shipperTimeInId).val()).length && $.trim($('#'+shipperTimeOut).val()).length && ( $.trim($('#'+shipperTimeInId).val()) > $.trim($('#'+shipperTimeOut).val()))){
	      					alert ('Pickup Time In is after Time Out');
	      					return false;
	      				}


	      				/*shipper pick up time in range*/
	      				if($.trim($('#'+shipperStopdateQ).val()).indexOf('37-38') != -1 && $.trim($('#'+shipperpickupTime).val()).indexOf('-') != -1){
	      					
	      					if( !$.trim($('#'+varshipperEdiReasonCodeId).val()).length &&

	      						($('#'+shipperTimeInId).val() < $('#'+shipperpickupTime).val().substring(0,4)
								|| $('#'+shipperTimeInId).val() > $('#'+shipperpickupTime).val().substring(5,9)
							 
							 ))
	      					{
							 	alert ('Pick up Time In is not in range');
							 	$('#'+varshipperEdiReasonCodeId).css("display","block"); 
								$('.'+varshipperEdiReasonLabelId+stopnum).css("display","block"); 
								$('.'+varshipperEdiReasonLabelId+stopnum).css('color','red');
								return false;
	      					} 

	      					
	      				}
	      				else if( $('#'+shipperTimeInId).val() > $('#'+shipperpickupTime).val() 
	      						&& !$('#'+varshipperEdiReasonCodeId).val().length

	      					){
	      					alert ('Please choose the reason for late arrival');
	      						$('#'+varshipperEdiReasonCodeId).css("display","block"); 
								$('.'+varshipperEdiReasonLabelId+stopnum).css("display","block"); 
								$('.'+varshipperEdiReasonLabelId+stopnum).css('color','red');
	      					return false;
	      				}

	      				}

	      			/*shipper time out changed */
	      			if($.trim($('#'+oldshipperTimeOut).val()) != $.trim($('#'+shipperTimeOut).val()) ){
	      				var hourPart = $('#'+shipperTimeOut).val().substr(0, 2);
						var minutePart = $('#'+shipperTimeOut).val().substr(2, 2);
						if(hourPart > 23 || minutePart > 59){
							alert('Please enter valid pick up time in HHMM format');
							return false;
						}
	      				
	      				if($.trim($('#'+shipperTimeInId).val()) > $.trim($('#'+shipperTimeOut).val())){
	      					alert ('Pickup Time In is after Time Out');
	      					return false;
	      				}
	      				if($.trim($('#'+shipperStopdateQ).val()).indexOf('37-38') != -1 && $.trim($('#'+shipperpickupTime).val()).indexOf('-') != -1){
		      				if( !$.trim($('#'+varshipperEdiReasonCodeId).val()).length &&

		      						($('#'+shipperTimeOut).val() < $('#'+shipperpickupTime).val().substring(0,4)
									|| $('#'+shipperTimeOut).val() > $('#'+shipperpickupTime).val().substring(5,9)
								 
								 ))
		      					{
								 	alert ('Pick up Time Out is not in range');
								 	$('#'+varshipperEdiReasonCodeId).css("display","block"); 
									$('.'+varshipperEdiReasonLabelId+stopnum).css("display","block"); 
									$('.'+varshipperEdiReasonLabelId+stopnum).css('color','red');
									return false;
		      					} 
	      				}
	      			}
	      			
	      		}

	      		//consignee timein

	      		if($(inputs[i]).attr('id').indexOf('consigneeTimeIn') != -1){

	      			var consigneeTimeInId = $(inputs[i]).attr('id');	      			
	      			
	      			var oldConsigneeTimeIn = consigneeTimeInId.replace('consigneeTimeIn','oldConsigneeTimeIn');
	      			var consigneeTimeOut = consigneeTimeInId.replace('consigneeTimeIn','consigneeTimeOut'); 
	      			var oldconsigneeTimeOut = consigneeTimeInId.replace('consigneeTimeIn','oldConsigneeTimeOut');
	      			var consigneepickupTime = consigneeTimeInId.replace('consigneeTimeIn','consigneepickupTime');
	      			var oldconsigneepickupTime = consigneeTimeInId.replace('consigneeTimeIn','oldConsigneepickupTime');
	      			var consigneepickupDate = consigneeTimeInId.replace('consigneeTimeIn','consigneePickupDate');
					var consigneeStopdateQ = consigneeTimeInId.replace('consigneeTimeIn','ConsigneeStopDateQ');  
					var varconsigneeEdiReasonCodeId = consigneeTimeInId.replace('consigneeTimeIn','consigneeEdiReasonCode'); 
					var varconsigneeEdiReasonLabelId = consigneeTimeInId.replace('consigneeTimeIn','labelConsigneeTimein'); 

					/*consignee time in changed */
	      			if($.trim($('#'+oldConsigneeTimeIn).val()) != $.trim($('#'+consigneeTimeInId).val()) 
	      					|| $.trim($('#'+oldconsigneepickupTime).val()) != $.trim($('#'+consigneepickupTime).val())
	      				){
	      				

	      				if($.trim($('#'+oldConsigneeTimeIn).val()) != $.trim($('#'+consigneeTimeInId).val()) ){
	      			 		var hourPart = $('#'+consigneeTimeInId).val().substr(0, 2);
							var minutePart = $('#'+consigneeTimeInId).val().substr(2, 2);
							if(hourPart > 23 || minutePart > 59){
								alert('Please enter valid delivery Apt. time in HHMM format');
								return false;
							}

							
	      			 		
	      			 	}

	      			 	if($.trim($('#'+oldconsigneepickupTime).val()) != $.trim($('#'+consigneepickupTime).val()))
	      			 	{

	      				var hourPart = $('#'+consigneepickupTime).val().substr(0, 2);
						var minutePart = $('#'+consigneepickupTime).val().substr(2, 2);
						if(hourPart > 23 || minutePart > 59){
							alert('Please enter valid delivery Apt. time in HHMM format');
							return false;
						}
						}

	      				if($.trim($('#'+consigneeTimeInId).val()).length && $.trim($('#'+consigneeTimeOut).val()).length 
	      					&& (
	      					$.trim($('#'+consigneeTimeInId).val()) > $.trim($('#'+consigneeTimeOut).val()))
	      					){
	      					alert ('Delivery Time In is after Time Out');
	      					return false;
	      				}


	      				/*consignee pick up time in range*/
	      				if($.trim($('#'+consigneeStopdateQ).val()).indexOf('53-54') != -1 && $.trim($('#'+consigneepickupTime).val()).indexOf('-') != -1){
	      					var hourPart = $('#'+consigneeTimeInId).val().substr(0, 2);
							var minutePart = $('#'+consigneeTimeInId).val().substr(2, 2);
							if(hourPart > 23 || minutePart > 59){
								alert('Please enter valid time in HHMM format');
								return false;
							}
	      					if(
	      						 !$('#'+varconsigneeEdiReasonCodeId).val().length &&

	      					 ($('#'+consigneeTimeInId).val() < $('#'+consigneepickupTime).val().substring(0,4)
							|| $('#'+consigneeTimeInId).val() > $('#'+consigneepickupTime).val().substring(5,9))


							 ){
							 	alert ('Delivery Time In is not in range');
							 	$('#'+varconsigneeEdiReasonCodeId).css("display","block"); 
								$('.'+varconsigneeEdiReasonLabelId+stopnum).css("display","block"); 
								$('.'+varconsigneeEdiReasonLabelId+stopnum).css('color','red');
								return false;
	      					} 
	      				}
	      				else if( $('#'+consigneeTimeInId).val() > $('#'+consigneepickupTime).val()
	      						&& !$('#'+varconsigneeEdiReasonCodeId).val().length
	      					){
	      					alert ('Please choose the reason for late departure');
	      					$('#'+varconsigneeEdiReasonCodeId).css("display","block"); 
							$('.'+varconsigneeEdiReasonLabelId+stopnum).css("display","block"); 
							$('.'+varconsigneeEdiReasonLabelId+stopnum).css('color','red');
								
	      					return false;
	      				}

	      				}

	      			/*consignee time out changed */
	      			if($.trim($('#'+oldconsigneeTimeOut).val()) != $.trim($('#'+consigneeTimeOut).val()) ){
	      				var hourPart = $('#'+consigneeTimeOut).val().substr(0, 2);
						var minutePart = $('#'+consigneeTimeOut).val().substr(2, 2);
						if(hourPart > 23 || minutePart > 59){
							alert('Please enter valid delivery time out in HHMM format');
							return false;
						}
	      				
	      				if($.trim($('#'+consigneeTimeInId).val()).length && $.trim($('#'+consigneeTimeOut).val()).length 
	      					&& (
	      					$.trim($('#'+consigneeTimeInId).val()) > $.trim($('#'+consigneeTimeOut).val()))
	      					){
	      					alert ('Delivery Time In is after Time Out');
	      					return false;
	      				}

	      				if($.trim($('#'+consigneeStopdateQ).val()).indexOf('53-54') != -1 && $.trim($('#'+consigneepickupTime).val()).indexOf('-') != -1){

	      				if( !$.trim($('#'+varconsigneeEdiReasonCodeId).val()).length &&

	      						($('#'+consigneeTimeOut).val() < $('#'+consigneepickupTime).val().substring(0,4)
								|| $('#'+consigneeTimeOut).val() > $('#'+consigneepickupTime).val().substring(5,9)
							 
							 ))
	      					{
							 	alert ('Delivery Time Out is not in range');
							 	$('#'+varconsigneeEdiReasonCodeId).css("display","block"); 
								$('.'+varconsigneeEdiReasonLabelId+stopnum).css("display","block"); 
								$('.'+varconsigneeEdiReasonLabelId+stopnum).css('color','red');
								return false;
	      					} 
	      				}
	      			}
	      			
	      		}
	      	}

	}  
	enableDisableMainCalcFields(false);
	if(checkLoad()) { 
		document.getElementById('loadToSaveAndExit').value = loadid;
		 $('#load').submit();
		return true;
	}
	return false;
}
	
function checkLoad() { 
	enableDisableMainCalcFields(false);
	try{
        setAjaxSession(0);
	}catch(e){

	}
	var ajaxFlag=1;
	if($('#editid').length && $('#editid').val() !=0){
		var LastModifiedDate = $('#LastModifiedDate').val();
		var path = urlComponentPath+"loadgateway.cfc?method=ajaxCompareLoadModifiedDate";

	  	$.ajax({
	      	type: "get",
	      	url: path,		
	      	dataType: "json",
	      	async: false,
	      	data: {
	          LastModifiedDate: LastModifiedDate,
	          LoadID:$('#editid').val(),
	        },
	      	success: function(allowSubmit){
	      		if(allowSubmit==0){
	      			if(confirm('Load data is modified by another user. You need to reload the load before saving the load. Click OK to reload.')){
	      				location.reload();
	      			}
	      			enableDisableMainCalcFields(true);
	      			ajaxFlag=0;
	      		}
	        	
	      	}
	    });
	}

	if(ajaxFlag==0){
		return false;
	}

	$('.carrierCalTable').each(function(i, obj) {
		var index = this.id.split('_')[1];
		var count = $('#'+this.id+' >tbody >tr').length;
		$('#totalResult'+index).val(count);

		$('#'+this.id+' >tbody >tr').each(function (i, row){
			$(row).find("input,select").each(function(e){
				var name = $(this).attr("name");
				var index = i+1
        		name = name.split('_');
        		$(this).attr("name",name[0]+"_"+index);
			})
		})
	})

	var loadManualNoExists= document.getElementById('loadManualNoExists').value;
	var CreditLimit=$('#CreditLimit').length;
	var Available=$('#Available').length;

	if(CreditLimit && Available >0){
		var CreditValue=$('#CreditLimitInput').val();
		var AvailableValue=$('#AvailableInput').val();
		var BalanceValue=$('#BalanceInput').val();
		var TotalCustomerChargesHidden=$('#TotalCustomerChargesHidden').val();
		if ((BalanceValue>0) && (CreditValue > 0) && (AvailableValue < TotalCustomerChargesHidden)){
			alert('The customer has exceeded their credit limit.');

		}
	}
	
	if($('#editid').length && $('#editid').val() !=0 && $('#LoadNumber').length && $('#loadManualNo').val()==""){
		alert('Load number you have been entered is invalid , Please correct and try again');
		$('#loadManualNo').focus();
		enableDisableMainCalcFields(true);
		return false;
	}

	if (document.getElementById('LoadNumber').value=="") {
		if(document.getElementById('loadManualNoExists').value==1)
		{
			alert('Load number you have been entered is duplicate , Please correct and try again');
			 
			enableDisableMainCalcFields(true);
			return false;
		}
	}
	if(document.getElementById('LoadNumber').value !="" && (document.getElementById('LoadNumber').value != document.getElementById('loadManualNo').value ) ) {
		 if(document.getElementById('loadManualNoExists').value==1)
		{
			alert('Load number you have been entered is duplicate , Please correct and try again');
			 
			enableDisableMainCalcFields(true);
			return false;
		}
	}
	if(document.getElementById('loadManualNoIdentExists').value == 1){
		 if(document.getElementById('loadManualNoExists').value==1)
		{
			alert('Load number you have been entered is duplicate , Please correct and try again');
			 
			enableDisableMainCalcFields(true);
			return false;
		}

	}

	var status1= document.getElementById('loadStatus').value;
	if(status1=="")	{
		alert('Please select the load status type');
		loadStatus.focus();
		enableDisableMainCalcFields(true);
		return false;
	}

	if($('#ediLoad').val()==1 && $.trim($( "#loadStatus option:selected" ).text())=='7. INVOICE'){
		if($.trim($('#BillDate').val()).length==0){
			alert('Invoice Date Required.');
			$('#BillDate').focus();
			return false;
		}
		if($.trim($('#PODSignature').val()).length==0){
			alert('POD Signature Required.');
			$('#PODSignature').focus();
			return false;
		}

		if($('#TotalCustomerCharges').val().replace('$','')==0){
			alert('Total Customer Charges Should Be Greater Than 0.');
			return false;
		}

	}


	if ( $( "#Salesperson" ).length ) {
		var sales= document.getElementById('Salesperson').value;
		if(sales=="")
		{
			alert('Please select a Sales Rep.');
			Salesperson.focus();
			enableDisableMainCalcFields(true);
			return false;
		}
	}	
	var disp= document.getElementById('Dispatcher').value;
	if(disp=="") {
		alert('Please select a Dispatcher');
		Dispatcher.focus();
		enableDisableMainCalcFields(true);
		return false;
	}

	var custId=document.getElementById("cutomerIdAuto").value;
	var custIdContainer=document.getElementById("cutomerIdAutoValueContainer").value;

	if(custId=="" || custIdContainer=="") {
		alert('Please select a valid customer');
		document.getElementById('cutomerIdAuto').focus();
		enableDisableMainCalcFields(true);
		return false;
	}
	var chkProcess = true;
	var stopid=1;
	var toStop = document.getElementById('totalStop').value;
	
	for (stopid=1;stopid<=toStop;stopid++) {  
		if(stopid == 1)
			chkProcess = checkLoadNext('');
		else
			chkProcess = checkLoadNext(stopid);
			
		if(!chkProcess && chkProcess != undefined){ 
			enableDisableMainCalcFields(true);
			return false;
		}
	}
	var Trans_Del= document.getElementById('Trancore_checkDelete').value;
	
	if(Trans_Del !=0 && document.getElementById('posttoTranscore').checked == false) { 
		document.getElementById('Trancore_DeleteFlag').value=1;
	}
	return true;
}

function setAjaxSession(value) {
  	var path = urlComponentPath+"loadgateway.cfc?method=setAjaxSession";
  	var setSession = "";
  	$.ajax({
      	type: "get",
      	url: path,		
      	dataType: "json",
      	async: false,
      	data: {
          isSession: value
        },
      	success: function(data){
        	setSession = data.sessionCheck;
      	}
    });
    return setSession;
}
	
function checkLoadNext(stopid) {
	if(stopid == 0){
		stopidForMessage = '1';
	} else {
		stopidForMessage = stopid;
	}	
	enableDisableMainCalcFields(false);
	var statusfreightBroker=document.getElementById('statusfreightBroker').value;
	if(statusfreightBroker==1) {
		var PostTo123LoadBoardStatus =document.getElementById('PostTo123LoadBoard').value;
		var loadnumber =document.getElementById('LoadNumber').value; 
		if(PostTo123LoadBoardStatus==1){
			var loardBoard123Exists=$("#loadBoard123").val();
			var equipment = document.getElementById('equipment'+stopid).value;	
			if(loadnumber == "" && equipment == "")	{
				document.getElementById('equipment'+stopid).focus();
				alert('Please select equipment for stop '+stopidForMessage);
				enableDisableMainCalcFields(true);
				return false;	
			}
		}
	}	
	return true;
}	

function ParseUSNumber(frmfld,fldName) {
	var phoneText = $(frmfld).val().replace(/\D/g,'');

	phoneText = phoneText.toString().replace(/,/g, "");
	phoneText = phoneText.replace(/-/g, "");
	phoneText = phoneText.replace(/\(/g, "");
	phoneText = phoneText.replace(/\)/g, "");
	phoneText = phoneText.replace(/ /g, "");
	phoneText = phoneText.replace(/ /g, "");
	  
  	if(phoneText.substring(0,10).search(/[a-zA-Z]/g)==-1 & isFinite(phoneText.substring(0,10)) & phoneText.substring(0,10).length==10){
		var part1 = phoneText.substring(0,6);
		part1 = part1.replace(/(\S{3})/g, "$1-");
		var part2 = phoneText.substring(6,10);
		var ext = phoneText.substring(10);
		if (ext.length) {
			var phoneField = part1 + part2+" "+ext;
		} else {
			var phoneField = part1 + part2;
		}
		$(frmfld).val(phoneField);
	} else if(phoneText.substring(0,10).length !=0) {
		if(fldName != ""){
			alert('Invalid '+fldName+'!');
		}else{
			alert('Invalid Phone Number!');
		}
		
		$(frmfld).focus();
	}
}

function ParseSSNumber(frmfld) {
	var phoneText = $(frmfld).val();
	phoneText = phoneText.toString().replace(/,/g, "");
	phoneText = phoneText.replace(/-/g, "");
	phoneText = phoneText.replace(/\(/g, "");
	phoneText = phoneText.replace(/\)/g, "");
	phoneText = phoneText.replace(/ /g, "");
	phoneText = phoneText.replace(/ /g, "");
	  
	if(phoneText.substring(0,9).search(/[a-zA-Z]/g)==-1 & isFinite(phoneText.substring(0,9)) & phoneText.substring(0,9).length==9){
		var part1 = phoneText.substring(0,5);
		part1 = part1.replace(/(\S{3})/g, "$1-");
		part1 = part1.replace(/(\S{6})/g, "$1-");
		var part2 = phoneText.substring(5,9);
		var ext = "";
		if (ext.length) {
			var phoneField = part1 + part2+" "+ext;
		} else {
			var phoneField = part1 + part2;
		}
		$(frmfld).val(phoneField);
	} else if(phoneText.substring(0,9).length !=0) {
		alert('Invalid SS Number!');
		$(frmfld).focus();
	}
}
 
function validateAgent(frm,dsn,flag) {
	var agentName = frm.FA_name.value;
	if (agentName == '') {
		alert('Please enter the User Name');
		frm.FA_name.focus();
		return false;
	} 
		
	var agentaddress=frm.address.value;
	if(agentaddress == '') {
		alert('Please enter the User Address');
		frm.address.focus();
		return false;
	}

	var agentcity=frm.city.value;
	if(agentcity == '')	{
		alert('Please enter the User City');
		frm.city.focus();
		return false;
	}
	var state=frm.state.value;
	if(state=="") {
		alert('Please select a state');
		frm.state.focus();
		return false;
	}	

	var zip=frm.Zipcode.value;
	if(zip=='')	{
		alert('Please enter the User Zipcode');
		frm.Zipcode.focus();
		return false;
	}

	var agentcountry=frm.country.value;
	if(agentcountry=="") {
		alert('Please select a country');
		frm.country.focus();
		return false;
	}

	var emailid=frm.FA_email.value;
	if(emailid=='')	{
		alert('Please enter a valid EmailId');
		frm.FA_email.focus();
		return false;
	}	
	var companyid = frm.companyid.value;
	var login=frm.loginid.value;
	var empID = frm.editId.value;
	if(login=="") {
		alert('Please enter the User Login');
		frm.loginid.focus();
		return false;
	}
	
	if (flag == 1) {	
		var validLogin = checkLogin(companyid,login,dsn);
		if (validLogin == false) {
			return false;
		}
	}
	else if (flag == 0) {
		var validLogin = checkLogin(companyid,login,dsn,empID);
		if (validLogin == false) {
			return false;
		}
	}
	var password=frm.FA_password.value;	
	if(password=="") {
		alert('Please enter the User Password');
		frm.FA_password.focus();
		return false;
	}
	var authlevel=frm.FA_roleid.value;
	
	if(authlevel=="") {
		alert('Please select an Auth Level');
		frm.FA_roleid.focus();
		return false;
	}

	var office=frm.FA_office.value;
	if(office=="") {
		alert('Please select an Office');
		frm.FA_office.focus();
		return false;
	}	
	
	var FmtStr="";
    var index = 0;
    var LimitCheck;
    var PhoneNumberInitialString=frm.tel.value;
    
    LimitCheck = PhoneNumberInitialString.length;
   	if (PhoneNumberInitialString !='') {
      	var FmtStr=PhoneNumberInitialString;
      	if (FmtStr.length == 12) {      	
      		if((FmtStr.charAt(3)== "-")&& (FmtStr.charAt(7)== "-")) {
        		FmtStr = FmtStr.substring(0,2) + "-" + FmtStr.substring(4,6) + "-" + FmtStr.substring(8,11);
      		} else {
	        	alert("Please enter phone number in the format of(xxx-xxx-xxxx)");
	        	frm.tel.focus();
	        	return false;
        	}  
      	} else {
	        FmtStr=PhoneNumberInitialString;        
	        alert("Please enter phone number in the format of(xxx-xxx-xxxx)");
	        frm.tel.focus();
	        return false;
      	}
	}
	return true;
}

function validateOffices(frm) {
 	var code=frm.officeCode.value;
 	if(code=='') {
		alert('Please enter the Office Code');
		frm.officeCode.focus();
		return false;
	}
 	var loc=frm.Location.value;
 	if(loc=='')	{
		alert('Please enter the Office Location');
		frm.Location.focus();
		return false;
	}
 	var manager=frm.adminManager.value;
 	if(manager=='')	{
		alert('Please enter the Admin Manager');
		frm.adminManager.focus();
		return false;
	}

	var FmtStr="";
    var index = 0;
    var LimitCheck;
    var PhoneNumberInitialString=frm.contactNo.value;
    
    LimitCheck = PhoneNumberInitialString.length;
   	if (PhoneNumberInitialString !='') {
      	var FmtStr=PhoneNumberInitialString;
      	if (FmtStr.length == 12) {      	
      		if((FmtStr.charAt(3)== "-")&& (FmtStr.charAt(7)== "-")) {
        		FmtStr = FmtStr.substring(0,2) + "-" + FmtStr.substring(4,6) + "-" + FmtStr.substring(8,11);
      		} else {
	        	alert("Please enter phone number in the format of(xxx-xxx-xxxx)");
	        	frm.contactNo.focus();
	        	return false;
        	}  
      	} else {
	        FmtStr=PhoneNumberInitialString;        
	        alert("Please enter phone number in the format of(xxx-xxx-xxxx)");
	        frm.contactNo.focus();
	        return false;
      	}
    	return true;
   	}
 	var contact=frm.contactNo.value;
 	if(contact=='')	{
		alert('Please enter the Contact Number');
		frm.contactNo.focus();
		return false;
	}

 	var fax=frm.faxno.value;
 	if(fax=='')	{
		alert('Please enter the Fax Number');
		frm.faxno.focus();
		return false;
	}	

	var email=frm.emailID.value;
	if(email=='') {
	    alert('Please enter a valid EmailId');
		frm.emailID.focus();
		return false;
	}		
}

function validateCustomer(frm,save_exit) {
	var code=frm.CustomerCode.value;
	var ReqAddressWhenAddingCust = frm.ReqAddressWhenAddingCust.value;
 	if(code=='') {
		alert('Please enter the Customer Code');
		frm.CustomerCode.focus();
		return false;
	}
 	var custname=frm.CustomerName.value;

 	if(custname=='') {
		alert('Please enter the Customer Name');
		frm.CustomerName.focus();
		return false;
	}
 	var office=frm.OfficeID1.value;
 	if(office=="") {
		alert('Please select an Office');
		frm.OfficeID1.focus();
		return false;
	}
 	
 	if(ReqAddressWhenAddingCust == 1){
 		var address=frm.Location.value;
	 	if(address=='') {
			alert('Please enter the Customer Address');
			frm.Location.focus();
			return false;
	 	}

	 	var custcity=frm.City.value;
	 	if(custcity=='') {
		 	alert('Please enter the Customer city');
			frm.City.focus();
			return false;
	 	}

	 	var custstate=frm.state1.value;
	 	if(custstate=="") {
		 	alert('Please select a State');
			frm.state1.focus();
			return false;
		}

	 	var zip=frm.Zipcode.value;
	 	if(zip=='') {
		 	alert('Please enter the Zipcode');
			frm.Zipcode.focus();
			return false;
		}

		var country=frm.country1.value;
		if(country=="") {
		 	alert('Please select a Country');
			frm.country1.focus();
			return false;
		}
 	}
 	

    var FmtStr="";
    var index = 0;
    var LimitCheck;
    var PhoneNumberInitialString=frm.PhoneNO.value;
    
    LimitCheck = PhoneNumberInitialString.length;

	var emailText = $('#Email').val();
  	if($.trim(emailText).length)
  	{
  		var mails = emailText.split(/,|;/);
  		var regex = /^([a-zA-Z0-9_.+-])+\@(([a-zA-Z0-9-])+\.)+([a-zA-Z0-9]{2,4})+$/; 
	    for(var i = 0; i < mails.length; i++) {
	        if(!regex.test(mails[i])){
	        	alert('Wrong Email Address(es) format! Please reEnter correct format.');
	            $('#Email').focus();
	            return false;
	        }
	    }
  	}

	var CreditLimit = document.getElementById('CreditLimit').value;	
	CreditLimit = CreditLimit.replace("$","");
	CreditLimit = CreditLimit.replace(/,/g,"");

	if(isNaN(CreditLimit) || !CreditLimit.length){
		alert('Invalid CreditLimit.');
		document.getElementById('CreditLimit').focus();
		return false;
	}	

	if (typeof save_exit == 'undefined') {
		save_exit=0;
    }
	$("#SaveAndExit").val(save_exit);
	
	return true;
}

	function saveExit(save_exit){		
			$("#SaveAndExit").val(save_exit);		
		}


function validateStop(frm) {
	var stopname=frm.CustomerStopName.value;
	if(stopname=='') {
		alert('Please enter the Customer Stop Name');
		frm.CustomerStopName.focus();
		return false;
	}	
	var address=frm.location.value;
	if(address=='') {
		alert('Please enter the Customer Address');
		frm.location.focus();
		return false;
	}	
	var stopcity=frm.City.value;
 	if(stopcity=='') {
	 	alert('Please enter the Customer city');
		frm.City.focus();
		return false;
	}
	var custstate=frm.StateID.value;
 	if(custstate=="") {
	 	alert('Please select a State');
		frm.StateID.focus();
		return false;
	}
	var zip=frm.Zipcode.value;
 	if(zip=='') {
	 	alert('Please enter the Zipcode');
		frm.Zipcode.focus();
		return false;
	}
	var customer=frm.cutomerIdAuto.value;
	if(customer=='') {
	    alert('Please select a customer');
		frm.cutomerIdAuto.focus();
		return false;
	}		
}

function MultipleSort(fieldName,val){
	var urlToken=$('#urlToken').val();
	var resp = $.ajax({
	    type: "POST",
	    url: "ajax.cfm?event=ajxUpdateSortCookies&"+urlToken,
	    data:{fieldName:fieldName,val:val},
	    async: false
	}).responseText;
	if(resp==1){
		location.href = location.href;
	}
}

function updateReportCookies(fieldName,ele){
	var ckd = $(ele).is(":checked");
	var urlToken=$('#urlToken').val();
	var resp = $.ajax({
	    type: "POST",
	    url: "ajax.cfm?event=ajxUpdateReportCookies&"+urlToken,
	    data:{fieldName:fieldName,val:ckd},
	    async: false
	}).responseText;
}

function clearMultipleSort(){
	var urlToken=$('#urlToken').val();
	var resp = $.ajax({
	    type: "POST",
	    url: "ajax.cfm?event=ajxClearSortCookies&"+urlToken,
	    data:{},
	    async: false
	}).responseText;
	if(resp==1){
		location.href = location.href;
	}
}

function validateAddCarrier(frm) {
	try {
		var VendorID = frm.venderId.value;
		var urlToken=$('#urlToken').val();
		var editid=document.getElementById('editid').value;

		if($.trim(VendorID).length && editid ==0){
			var duplicateVendorID = $.ajax({
			    type: "GET",
			    url: "ajax.cfm?event=ajxCheckCarrierVendorID&VendorID="+encodeURIComponent(VendorID)+"&"+urlToken,
			    async: false
			}).responseText;

			if(duplicateVendorID == 1){
				alert('Duplicate Vendor Code.');
				frm.venderId.focus();
	        	return false;
			}
		}

		var InsLimit = frm.InsLimit.value;
 		InsLimit = InsLimit.replace("$","");
		InsLimit = InsLimit.replace(/,/g,"");

		if(isNaN(InsLimit) || !InsLimit.length){
			alert("Invalid Limit.")
			frm.InsLimit.value='$0.00';
			frm.InsLimit.focus();
			return false;
		}

		var InsLimitCargo = frm.InsLimitCargo.value;
 		InsLimitCargo = InsLimitCargo.replace("$","");
		InsLimitCargo = InsLimitCargo.replace(/,/g,"");

		if(isNaN(InsLimitCargo) || !InsLimitCargo.length){
			alert("Invalid Limit.")
			frm.InsLimitCargo.value='$0.00';
			frm.InsLimitCargo.focus();
			return false;
		}

		var InsLimitGeneral = frm.InsLimitGeneral.value;
 		InsLimitGeneral = InsLimitGeneral.replace("$","");
		InsLimitGeneral = InsLimitGeneral.replace(/,/g,"");

		if(isNaN(InsLimitGeneral) || !InsLimitGeneral.length){
			alert("Invalid Limit.")
			frm.InsLimitGeneral.value='$0.00';
			frm.InsLimitGeneral.focus();
			return false;
		}
	}
	catch(e){

	}
}
function validateCarrier(frm,dsn,flag,type) {
	try {
		var mcno=frm.MCNumber.value.trim();
		if(type == 'carrier') {
			var numberType = 'MC';
		} else {
			var numberType = 'Lic';
		}
		// Remove validation from driver lic field if type is driver and lic field is empty 
		if(mcno=='' && type == 'driver'){
			return true;
		}
		if(mcno=='' && type == 'carrier') {
			alert('Please enter the ' + numberType +' Number');
			frm.MCNumber.focus();
			return false;
		} else {
			if(flag==0 && type == 'carrier') {
				alert('Please enter a Valid ' + numberType + ' Number');
				frm.MCNumber.focus();
				return false;
			}
		}
		var editid=document.getElementById('editid').value;
		var CompanyID=document.getElementById('CompanyID').value;
		if(editid=="") {
			var path = urlComponentPath+"loadgateway.cfc?method=checkMCNumber&dsn="+dsn+"&mcno="+mcnomcno+"&CompanyID="+CompanyID;
			var mcNoStatus = $.ajax({
			    type: "GET",
			    url: path,
			    async: false
			}).responseText;
			if (mcNoStatus=="true") {
				alert(numberType + ' Number is already exist in database.');				
				document.getElementById("MCNumber").focus();
				return false;
			}
		}
		var carname=frm.CarrierName.value;
		if(carname=='') {
			alert('Please enter the carrierName');
			frm.MCNumber.focus();
			frm.CarrierName.focus();
			return false;
		}
		var IsCarrier = document.getElementById('IsCarrier').value;

		var address=frm.Address.value;

 		if(IsCarrier == 1){
 			var phone=frm.Phone.value.trim();
	 		if(phone=='') {
			 	alert('Please enter the Phone');
				frm.Phone.focus();
				return false;
	 		} else {
				var phoneText = frm.Phone.value;
			  	phoneText = phoneText.toString().replace(/,/g, "");
			  	phoneText = phoneText.replace(/-/g, "");
			  	phoneText = phoneText.replace(/\(/g, "");
			  	phoneText = phoneText.replace(/\)/g, "");
			  	phoneText = phoneText.replace(/ /g, "");
			  	phoneText = phoneText.replace(/ /g, "");
		  		if(phoneText.substring(0,10).search(/[a-zA-Z]/g)==-1 & isFinite(phoneText.substring(0,10)) & phoneText.substring(0,10).length==10){
		  		} else if(phoneText.substring(0,10).length !=0) {
			  		alert("Please enter phone number in the format of(xxx-xxx-xxxx)");
			  		frm.Phone.value='';
			  		frm.Phone.focus();
		      		return false;
		  		}
			}
			if(address=='') {
				alert('Please enter the Carrier Address');
				frm.Address.focus();
				return false;
			}	
			var carcity=frm.City.value;
	 		if(carcity=='') {
			 	alert('Please enter the  city');
				frm.City.focus();
				return false;
			}
			var custstate=frm.State.value;
			if(custstate=="") {
			 	alert('Please select a State');
				frm.State.focus();
				return false;
			}
			var zip=frm.Zipcode.value;
			if(zip=='') {
	 			alert('Please enter the Zipcode');
				frm.Zipcode.focus();
				return false;
	 		}

	 		var InsLimit = frm.InsLimit.value;
	 		InsLimit = InsLimit.replace("$","");
			InsLimit = InsLimit.replace(/,/g,"");

			if(isNaN(InsLimit) || !InsLimit.length){
				alert("Invalid Limit.")
				frm.InsLimit.value='$0.00';
				frm.InsLimit.focus();
				return false;
			}

			var InsLimitCargo = frm.InsLimitCargo.value;
	 		InsLimitCargo = InsLimitCargo.replace("$","");
			InsLimitCargo = InsLimitCargo.replace(/,/g,"");

			if(isNaN(InsLimitCargo) || !InsLimitCargo.length){
				alert("Invalid Limit.")
				frm.InsLimitCargo.value='$0.00';
				frm.InsLimitCargo.focus();
				return false;
			}

			var InsLimitGeneral = frm.InsLimitGeneral.value;
	 		InsLimitGeneral = InsLimitGeneral.replace("$","");
			InsLimitGeneral = InsLimitGeneral.replace(/,/g,"");

			if(isNaN(InsLimitGeneral) || !InsLimitGeneral.length){
				alert("Invalid Limit.")
				frm.InsLimitGeneral.value='$0.00';
				frm.InsLimitGeneral.focus();
				return false;
			}

			var FF = $('#FF').val();
			if(!$.trim(FF).length || isNaN(FF)){
				alert('Invalid Factoring Fee%.');
				$('#FF').val(0);
				$('#FF').focus();
				return false;
			}

			var emailText = $('#Email').val();
		  	if($.trim(emailText).length)
		  	{
		  		var mails = emailText.split(/, |; /);
		  		var regex = /^([a-zA-Z0-9_.+-])+\@(([a-zA-Z0-9-])+\.)+([a-zA-Z0-9]{2,4})+$/; 
			    for(var i = 0; i < mails.length; i++) {
			        if(!regex.test(mails[i])){
			        	alert('Wrong Email Address(es) format! Please reEnter correct format.');
			            $('#Email').focus();
			            return false;
			        }
			    }
		  	}

		}

		var RatePerMile = frm.RatePerMile.value;
	 		RatePerMile = RatePerMile.replace("$","");
			RatePerMile = RatePerMile.replace(/,/g,"");

		if(isNaN(RatePerMile) || !RatePerMile.length){
			alert("Invalid Rate Per Mile.")
			frm.RatePerMile.value='$0.00';
			frm.RatePerMile.focus();
			return false;
		}
			
		if(IsCarrier == 0){
			var CarrierID = document.getElementById('editid').value;
			var fuelCardNo = document.getElementById('fuelCardNo').value.trim();
			if(fuelCardNo.length){
				var path = urlComponentPath+"loadgateway.cfc?method=checkDriverFuelCardConflict&dsn="+dsn+"&CarrierID="+CarrierID+"&fuelCardNo="+fuelCardNo+"&CompanyID="+CompanyID;
				var fuelCardConflict = $.ajax({
				    type: "GET",
				    url: path,
				    async: false
				}).responseText;
				if (fuelCardConflict=="true") {
					alert('Fuel Card Number is conflicting with another driver.');				
					document.getElementById("fuelCardNo").focus();
					return false;
				}

			}
		}
		
	}catch(e){

	}

}

function validateEquipment(frm,dsn) {
	var code=frm.EquipmentCode.value;
	if(code=='') {
		alert('Please enter the Equipment Code');
		frm.EquipmentCode.focus();
		return false;
	}	
	var eqname=frm.EquipmentName.value;
	if(eqname=='') {
		alert('Please enter the Equipment Name');
		frm.EquipmentName.focus();
		return false;
	}
}

function validateUnit(frm) {
	var code=frm.UnitCode.value;
	if(code=='') {
		alert('Please enter the Unit Code');
		frm.UnitCode.focus();
		return false;	
	}
	var unit=frm.UnitName.value;
	if(unit=='') {
		alert('Please enter the Unit Name');
		frm.UnitName.focus();
		return false;	
	} 
}

function CalcCustomerTotal() {
	var TotalCustCharges = 0;
	var TotalCustChargesNext = 0;
	var cutomerCharges=document.getElementById("CustomerRate").value;
	var i = 1;
	for (i=1;i<=7;i++) {
		TotalCustCharges = parseFloat((TotalCustCharges) + parseFloat(document.getElementById("CustomerRate"+i).value) * parseFloat(document.getElementById("qty"+i).value));
	}
	var j=2;
	for (j=2;j<=10;j++) {
		var k=1
		for (k=1;k<=7;k++) {
			TotalCustChargesNext = parseFloat(TotalCustChargesNext) + parseFloat(document.getElementById("CustomerRate"+k+j).value * parseFloat(document.getElementById("qty"+k+''+j).value));
		}
	}
	var custMilesCharges = document.getElementById("CustomerMiles").value;
	custMilesCharges = custMilesCharges.replace('$','');
	custMilesCharges = custMilesCharges.replace(/,/g,'');
		
	var TotalCustcommodities = (parseFloat(TotalCustCharges) + parseFloat(TotalCustChargesNext)).toFixed(2);
	document.getElementById("TotalCustcommodities").value ='$'+convertDollarNumberFormat(TotalCustcommodities);
	cutomerCharges = cutomerCharges.replace(/\$/,"");
	var TotalCustomerCharges = (parseFloat(TotalCustCharges) + parseFloat(TotalCustChargesNext) + parseFloat(cutomerCharges) + parseFloat(custMilesCharges) ).toFixed(2);
	document.getElementById("TotalCustomerCharges").value ='$'+ convertDollarNumberFormat(TotalCustomerCharges);
	$( "#TotalCustomerChargesHidden" ).attr( "value", TotalCustomerCharges);
	updateTotalAndProfitFields();
}

function CalculateTotal(dsn) {

	var TotalCustCharges = 0;
	var TotalCarrCharges = 0;
	var TotalDirectCost = 0;
	var newcharge = 0;
	var newcustcharge = 0;
	var newcareermilse = 0;
	var UnitIdArray='';
	var counter=1;
	var subCounter=1;
	var CompanyID = document.getElementById('CompanyID').value;
	var path=urlComponentPath+"unitgateway.cfc?method=getUnitIdsOfPaymentAdvance";
		$.ajax({
		  	type: "post",
		  	url: path,		
		  	dataType: "text",
		  	async: false,
		  	data: {
			  	dsn:dsn,CompanyID:CompanyID
			},
		  	success: function(data){
			 	UnitIdArray=data;
		  	}
		});
	var Dmask = new RegExp("^[+-]?(?:[$]|)[0-9]{1,6}(?:[0-9]*(?:[.,][0-9]{1})?|(?:,[0-9]{3})*(?:\.[0-9]{1,2})?|(?:\.[0-9]{3})*(?:,[0-9]{1,2})?)$");
	var Pmask = new RegExp("^[0-9]{1,9}([\.][0-9]{1,2})?[\%]?$");

	$('.noh').each(function(i, obj) {
		$(this).find('.CustomerRate').each(function(i, obj){
			var parentDiv = $(obj).parent().parent();

			var qtyF = $(parentDiv).find(".qty ").val();
			if(isNaN(qtyF)){
				$(parentDiv).find(".qty").val('1');
				alert('Invalid Quantity.');
				$(parentDiv).find(".qty").focus();
				return false;
			}

			var CustomerRateDollar = $(parentDiv).find(".CustomerRate").val().replace("(","").replace(")","");

			if(!Dmask.test(CustomerRateDollar.trim())){
				$(parentDiv).find(".CustomerRate").val('0');
				alert('Invalid Customer Rate.');
				$(parentDiv).find(".CustomerRate").focus();
				return false;
			}

			var CarrierRateDollar = $(parentDiv).find(".CarrierRate").val().replace("(","").replace(")","");
			if(!Dmask.test(CarrierRateDollar.trim())){
				$(parentDiv).find(".CarrierRate").val('0');
				alert('Invalid Carrier Rate.');
				$(parentDiv).find(".CarrierRate").focus();
				return false;
			}

			var CarrierPerF = $(parentDiv).find(".CarrierPer").val();
			if(!Pmask.test(CarrierPerF.trim())){
				$(parentDiv).find(".CarrierPer").val('0%');
				alert('Invalid Percentage.');
				$(parentDiv).find(".CarrierPer").focus();
				return false;
			}

			var directCostDollar = $(parentDiv).find(".directCost").val();

			if (directCostDollar != undefined) {
				if(!Dmask.test(directCostDollar.trim())){
					$(parentDiv).find(".directCost").val('0');
					alert('Invalid DirectCost.');
					$(parentDiv).find(".directCost").focus();
					return false;
				}
			}
			

			var CustomerRate = $(parentDiv).find(".CustomerRate").val().replace(/\$/,"").replace("(","").replace(")","").replace(/,/g,'');
			var carrCharges = $(parentDiv).find(".CarrierRate").val().replace(/\$/,"").replace("(","").replace(")","").replace(/,/g,'');
			var qty = $(parentDiv).find(".qty").val();
			var CarrierPer =$(parentDiv).find(".CarrierPer").val();
			
			
			try{
				CarrierPer=parseFloat(CarrierPer);
			}
			catch(e){
				CarrierPer=0
			}
			
			var custTotal = (parseFloat(CustomerRate) * parseFloat(qty)).toFixed(2);
			CarrierPer=(CarrierPer*custTotal)/100;
			var carrTotal = (parseFloat(carrCharges) * parseFloat(qty)+CarrierPer).toFixed(2);
			
			if($("#defaultCarrierCurrency").length){
				$(parentDiv).find(".custCharges").val(custTotal);//'$'+
				if($("#defaultCarrierCurrency").val() == $("#defaultCustomerCurrency").val()){
					$(parentDiv).find(".carrCharges").val(carrTotal );//'$'+
				}else{
					$(parentDiv).find(".carrCharges").val(0);
				}
				
			}else{
					if(custTotal.indexOf('-') != -1){
						$(parentDiv).find(".custCharges").val('-$'+custTotal.replace('-',''));
					}
					else{
						$(parentDiv).find(".custCharges").val('$'+custTotal);						
					}
					if(carrTotal.indexOf('-') != -1){
						$(parentDiv).find(".carrCharges").val('-$'+carrTotal.replace('-','') );
					}
					else{
						$(parentDiv).find(".carrCharges").val('$'+carrTotal );
					}
				}

			if($('#UseDirectCost').val()==1){
				var directCost = $(parentDiv).find(".directCost").val().replace(/\$/,"").replace(/,/g,'');
				var directCostTotal = (parseFloat(directCost) * parseFloat(qty)).toFixed(2);
				$(parentDiv).find(".directCostTotal").val('$'+directCostTotal);
				TotalDirectCost = parseFloat((TotalDirectCost) + parseFloat(directCost) * parseFloat(qty));	
			}
			
			
			TotalCustCharges = parseFloat((TotalCustCharges) + parseFloat(CustomerRate) * parseFloat(qty));
			TotalCarrCharges = parseFloat((TotalCarrCharges) + parseFloat(carrCharges) * parseFloat(qty));	
		});
	});

	$('.carrCharges').each(function(i, obj) {
		data= this.value.replace("$","").replace(/,/g,'');
		if(!isNaN(data) && this.offsetWidth > 0){
			var arraycontainsmatchvalues = (UnitIdArray.indexOf($(this).parent().parent().find(".unit").val()));
			if(arraycontainsmatchvalues ==0 || arraycontainsmatchvalues ==-1){
			newcharge = newcharge+parseFloat(data);
			}
		}
	});
	
	$('.custCharges').each(function(i, obj) {
		data= this.value.replace("$","").replace(/,/g,'');
		if(!isNaN(data) && this.offsetWidth > 0) {
			var arraycontainsmatchvalues = (UnitIdArray.indexOf($(this).parent().parent().find(".unit").val()));
			if(arraycontainsmatchvalues ==0 || arraycontainsmatchvalues ==-1) {
				newcustcharge = newcustcharge+parseFloat(data);
			}
		}
	});
	
	$('.careermilse').each(function(i, obj) {
		data= this.value.replace("$","");
		if(!isNaN(data) && this.offsetWidth > 0) {
			newcareermilse = newcareermilse+parseFloat(data);
		}
	});

	TotalCustCharges=newcharge;
	var cutomerRate= $("#CustomerRate").val();
	var custMilesRate = $("#CustomerMiles").val().replace('$','').replace(/,/g,'');
	var carrierRate= $("#CarrierRate").val();
	var carrMilesRate = $("#CarrierMiles").val().replace('$','').replace(/,/g,'');
	if($("#defaultCarrierCurrency").length){
		$('#TotalCustcommodities').val( convertNumberFormat(newcustcharge));//'$'+
		$('#TotalCarcommodities').val( convertNumberFormat(newcharge));//'$'+
	}else{
		$('#TotalCustcommodities').val( '$'+convertNumberFormat(newcustcharge));
		$('#TotalCarcommodities').val( '$'+convertNumberFormat(newcharge));
		$('#TotalCustcommodities').val($('#TotalCustcommodities').val().replace('$-','-$'));
		$('#TotalCarcommodities').val($('#TotalCarcommodities').val().replace('$-','-$'));
	}
	var IncludeDhMilesInTotalMiles = document.getElementById('IncludeDhMilesInTotalMiles').value;
	var frieghtBroker = document.getElementById('frieghtBroker').value;
	var deadHeadMiles = document.getElementById('deadHeadMiles').value;
	if(frieghtBroker !=1 && IncludeDhMilesInTotalMiles ==1 &  $.trim(deadHeadMiles).length && !isNaN($.trim(deadHeadMiles))){
		newcareermilse = newcareermilse + parseFloat(deadHeadMiles);
	}
	$('#CustomerMilesCalc').val(convertNumberFormat(newcareermilse));
	var TotalCustomerCharges = (parseFloat(TotalCustCharges) + parseFloat(cutomerRate)+parseFloat(custMilesRate)).toFixed(2);
	var TotalCarrierCharges = (parseFloat(TotalCarrCharges) + parseFloat(carrierRate)+parseFloat(carrMilesRate)).toFixed(2);
	$('#TotalCustomerCharges').val(convertDollarNumberFormat(TotalCustomerCharges));
	$( "#TotalCustomerChargesHidden" ).attr( "value", TotalCustomerCharges);
	$('#TotalCarrierCharges').val(convertDollarNumberFormat(TotalCarrierCharges));
	$( "#TotalCarrierChargesHidden" ).attr( "value", TotalCarrierCharges);
	if($('#UseDirectCost').val()==1){
		$('#TotalDirectCost').val(convertDollarNumberFormat(TotalDirectCost));
		$("#TotalDirectCostHidden" ).attr( "value", TotalDirectCost);
	}
	updateTotalAndProfitFields();
}

function formatDollar(num, idValue) {
	var DecimalSeparator = Number("1.2").toLocaleString().substr(1,1);
	var AmountWithCommas = num.toLocaleString();
	var arParts = String(AmountWithCommas).split(DecimalSeparator);
	var intPart = arParts[0];
	var decPart = (arParts.length > 1 ? arParts[1] : '');
	decPart = (decPart + '00').substr(0,2);
	if((intPart + DecimalSeparator + decPart )[0] != "$") {
		var returnvalue = '$' + intPart + DecimalSeparator + decPart;
	} else {
		var returnvalue = intPart + DecimalSeparator + decPart;
	}
	$('#'+idValue).val(returnvalue);
}
function formatDollarNegative(num, idValue) {	
	var DecimalSeparator = Number("1.2").toLocaleString().substr(1,1);
	var AmountWithCommas = num.toLocaleString();
	var arParts = String(AmountWithCommas).split(DecimalSeparator);
	var intPart = arParts[0];
	var decPart = (arParts.length > 1 ? arParts[1] : '');
	decPart = (decPart + '00').substr(0,2);
	if((intPart + DecimalSeparator + decPart )[0] != "$") {
		var returnvalue = '$' + intPart + DecimalSeparator + decPart;
	} else {
		var returnvalue = intPart + DecimalSeparator + decPart;
	}
	$('#'+idValue).val(returnvalue.replace('$-','-$'));
}

function CalcCarrierTotal() { 
	var TotalCarrCharges=0;
	var TotalCarrChargesNext=0;
	var carrierCharges=document.getElementById("CarrierRate").value;
	var i = 1;
	for (i=1;i<=7;i++) {
		TotalCarrCharges = parseFloat((TotalCarrCharges) + parseFloat(document.getElementById("CarrierRate"+i).value) * parseFloat(document.getElementById("qty"+i).value));
	}
	var j=2;
	for (j=2;j<=10;j++)	{
		var k=1
		for (k=1;k<=7;k++) {
			TotalCarrChargesNext = parseFloat(TotalCarrChargesNext) + parseFloat(document.getElementById("CarrierRate"+k+j).value * parseFloat(document.getElementById("qty"+k+''+j).value)) ;
		}
	}
	var totalCommodities = (parseFloat(TotalCarrCharges) + parseFloat(TotalCarrChargesNext)).toFixed(2);
	document.getElementById("TotalCarcommodities").value ='$'+convertDollarNumberFormat(totalCommodities);
	carrierCharges = carrierCharges.replace(/\$/,"");
	carrierCharges = (carrierCharges * 1);
	TotalCarrCharges = (TotalCarrCharges * 1);
	TotalCarrChargesNext = (TotalCarrChargesNext * 1);
	var TotalCarrierCharges = (TotalCarrCharges + TotalCarrChargesNext + carrierCharges).toFixed(2);
	document.getElementById("TotalCarrierCharges").value = '$'+ convertDollarNumberFormat(TotalCarrierCharges);
	$( "#TotalCarrierChargesHidden" ).attr( "value", TotalCarrierCharges);		
	updateTotalAndProfitFields();
}

function getbalance() {
	var credit=document.getElementById("CreditLimit").value;
	var avail=document.getElementById("Available").value;
	credit = credit.replace(/\$/,"");
	credit = (credit * 1);
	avail = avail.replace(/\$/,"");
	avail = (avail * 1);      
	var balance=credit-avail;
	document.getElementById("Balance").value='$'+balance;
}

function Autofillwebsite(frm) {
	var strarray="";
	var emailText=frm.Email.value;
	var mails = emailText.split(/,|;/);
	var email = mails[0];
	var mystring=email.toString();
	var strlength=mystring.length;
	var regexp='@';
	var matchpos=mystring.search(regexp);
	if(matchpos!=-1) {
		var i;
        for (i=matchpos+1;i<strlength;i++) {
	       	var indexvalue=mystring.charAt(i);       	
	       	strarray=strarray+indexvalue;       
	        frm.website.value='http://www.'+strarray;
        }
	}
	return false;	
}

// Calaculate Distance
var zipNo = 1;
function getLongitudeLatitude(frm) { 
	var firstzip=frm.shipperZipcode.value;
	var secondzip=frm.consigneeZipcode.value;
	var res1=ColdFusion.Map.getLatitudeLongitude(firstzip, callbackHandler);
	var res2=ColdFusion.Map.getLatitudeLongitude(secondzip, callbackHandler);
} 

function callbackHandler(result) {
	if (zipNo > 2) {
		zipNo = 1;
	}
	document.getElementById('result'+zipNo).value=result;
	var myList = result.toString();
	var myvalue=myList.split(',');
	var myLastVal1=myvalue[0];
	var myLastVal2=myvalue[1];
	var myLastVal1Len = myLastVal1.length;
	var myLastVal2Len = myLastVal2.length;
	document.getElementById('lat'+zipNo).value=myLastVal1.substring(1,myLastVal1Len);
	document.getElementById('long'+zipNo).value=myLastVal2.substring(1,myLastVal2Len-1);
	zipNo=zipNo+1;
}

function  ClaculateDistance(frmload) {
	addressChanged("");
}

// Calculate distance for next stop

function sleep(milliseconds) {
	var start = new Date().getTime();
		for (var i = 0; i < 1e7; i++) {
			if ((new Date().getTime() - start) > milliseconds){
			break;
		}
	}
}

var zipNoNext = 1;
var stpNo;
function getLongitudeLatitudeNext(frm,stpNo) { 
	document.getElementById('CurrStopNo').value = stpNo;
	var firstzip=document.getElementById('shipperZipcode'+stpNo).value;
	var secondzip=document.getElementById('consigneeZipcode'+stpNo).value;
	var res1=ColdFusion.Map.getLatitudeLongitude(firstzip, callbackHandlerNext);
	var res2=ColdFusion.Map.getLatitudeLongitude(secondzip, callbackHandlerNext);
} 

function callbackHandlerNext(result) {
	stpNo = document.getElementById('CurrStopNo').value;
	if (zipNoNext > 2) {
		zipNoNext = 1;
	}
	document.getElementById('result'+zipNoNext+stpNo).value=result;	
	var myList = result.toString();
	var myvalue=myList.split(',');
	var myLastVal1=myvalue[0];
	var myLastVal2=myvalue[1];
	var myLastVal1Len = myLastVal1.length;
	var myLastVal2Len = myLastVal2.length;
	document.getElementById('lat'+zipNoNext+stpNo).value=myLastVal1.substring(1,myLastVal1Len);
	document.getElementById('long'+zipNoNext+stpNo).value=myLastVal2.substring(1,myLastVal2Len-1);
	zipNoNext=zipNoNext+1;
}

function CalcDist(stpNo){
	addressChanged(stpNo);
}

// Updates total fileds and all the profit fields
function updateTotalAndProfitFields() {

	// updating total charges for Customers
	var flatRate = document.getElementById('CustomerRate').value;	
	flatRate = flatRate.replace("$","");
	flatRate = flatRate.replace(/,/g,"");

	if(isNaN(flatRate) || !flatRate.length || flatRate.length>15){
		alert('Invalid Rate.');
		document.getElementById('CustomerRate').focus();
		document.getElementById('CustomerRate').value='$0.00';
		flatRate = 0;		
	}
	else if(flatRate<0){
		alert('You entered a negative value, please enter a positive flat rate.');
		document.getElementById('CustomerRate').focus();
		document.getElementById('CustomerRate').value='$0.00';
		flatRate = 0;
	}
	var custCommodities = document.getElementById('TotalCustcommodities').value;
	custCommodities = custCommodities.replace("$","");
	custCommodities = custCommodities.replace(/,/g,"");
	if(isNaN(custCommodities)){
		custCommodities = 0;		
	}
	var CustomerMilesAmount = document.getElementById('CustomerMiles').value;
	CustomerMilesAmount = CustomerMilesAmount.replace("$","");
	CustomerMilesAmount = CustomerMilesAmount.replace(/,/g,"");
	if(isNaN(CustomerMilesAmount)){
		CustomerMilesAmount = 0;		
	}
	
	CustomerMilesAmount = parseFloat(CustomerMilesAmount).toFixed(2);

	var totalCustCharges = (parseFloat(flatRate) + parseFloat(custCommodities) + parseFloat(CustomerMilesAmount)).toFixed(2);
	var AdvancePaymentsCustomer=$("#AdvancePaymentsCustomerHidden").val().replace("$","").replace(/,/g,"");
	var TotalCustomerChargesDisplay=0;
	//console.log(totalCustCharges);

	if(parseFloat(totalCustCharges) >= parseFloat(AdvancePaymentsCustomer)){
		TotalCustomerChargesDisplay=(parseFloat(totalCustCharges)- parseFloat(AdvancePaymentsCustomer)).toFixed(2);
	}else{
      var TotalCustomerChargesDisplay=totalCustCharges;
	}
	document.getElementById('TotalCustomerCharges').value = "$"+convertDollarNumberFormat(TotalCustomerChargesDisplay);
	$( "#TotalCustomerChargesHidden" ).attr( "value", totalCustCharges);

	// updating total charges for Carriers
	var flatRateCar = document.getElementById('CarrierRate').value;
	flatRateCar = flatRateCar.replace("$","");
	flatRateCar = flatRateCar.replace(/,/g,"");
	if(isNaN(flatRateCar) || !flatRateCar.length || flatRateCar.length>15){		
		alert('Invalid Rate.');
		document.getElementById('CarrierRate').focus();
		document.getElementById('CarrierRate').value='$0.00';
		flatRateCar = 0;			
	}
	else if(flatRateCar<0){
		alert('You entered a negative value, please enter a positive flat rate.');
		document.getElementById('CarrierRate').focus();
		document.getElementById('CarrierRate').value='$0.00';
		flatRateCar = 0;
	}
	var carCommodities = document.getElementById('TotalCarcommodities').value;
	carCommodities = carCommodities.replace("$","");
	carCommodities = carCommodities.replace(/,/g,"");
	if(isNaN(carCommodities)){		
		carCommodities = 0;			
	}
	var CarMilesAmount = document.getElementById('CarrierMiles').value;
	CarMilesAmount = CarMilesAmount.replace("$","");
	CarMilesAmount = CarMilesAmount.replace(/,/g,"");
	if(isNaN(CarMilesAmount)){		CarMilesAmount = 0;			}
	var AdvancePaymentsCarrier=$("#AdvancePaymentsCarrierhidden").val();
	if(isNaN(AdvancePaymentsCarrier)){		AdvancePaymentsCarrier = 0;			}
	var totalCarCharges = (parseFloat(flatRateCar) + parseFloat(carCommodities) + parseFloat(CarMilesAmount)).toFixed(2);
	var TotalCarrierChargesDisplay=0;
	if(parseFloat(totalCarCharges) >=parseFloat(AdvancePaymentsCarrier)){
		TotalCarrierChargesDisplay=(parseFloat(totalCarCharges)- (parseFloat(AdvancePaymentsCarrier))).toFixed(2);
	}else{
		TotalCarrierChargesDisplay=totalCarCharges;
	}
	document.getElementById('TotalCarrierCharges').value = "$"+convertDollarNumberFormat(TotalCarrierChargesDisplay);
	$( "#TotalCarrierChargesHidden" ).attr( "value", totalCarCharges);
	
	// updating profits fields
	var flatRateProfit = (flatRate - flatRateCar).toFixed(2);
	document.getElementById('flatRateProfit').value = "$"+convertDollarNumberFormat(flatRateProfit);
	
	var carcommoditiesProfit = (custCommodities - carCommodities).toFixed(2);
	document.getElementById('carcommoditiesProfit').value = "$"+convertDollarNumberFormat(carcommoditiesProfit);
	document.getElementById('carcommoditiesProfit').value = document.getElementById('carcommoditiesProfit').value.replace('$-','-$');
	var amountOfMilesProfit = (CustomerMilesAmount - CarMilesAmount).toFixed(2);

	document.getElementById('amountOfMilesProfit').value = "$"+convertDollarNumberFormat(amountOfMilesProfit);
	if(document.getElementById('FactoringFeePercent') != null){
		var FFPercent = document.getElementById('FactoringFeePercent').value;
	
	FactoringFeeAmount = FFPercent.replace("$","");
	FactoringFeeAmount = FFPercent.replace(/,/g,"");
	if(isNaN(FFPercent)){
		FFPercent = 0;		
	}
	FactoringFeeAmount = totalCustCharges * (FFPercent/100);
	FactoringFeeAmount = FactoringFeeAmount.toFixed(2);

	document.getElementById('FactoringFeeAmount').value ="-$"+convertDollarNumberFormat(FactoringFeeAmount);
	
	var totalProfit = (parseFloat(flatRateProfit)+parseFloat(carcommoditiesProfit)+parseFloat(amountOfMilesProfit)-parseFloat(FactoringFeeAmount)).toFixed(2);
	}
	else{
	var totalProfit = (parseFloat(flatRateProfit)+parseFloat(carcommoditiesProfit)+parseFloat(amountOfMilesProfit)).toFixed(2);
	}

	if($('#UseDirectCost').val()==1){
		var TotalDirectCost = document.getElementById('TotalDirectCost').value;
		TotalDirectCost = TotalDirectCost.replace("$","");
		TotalDirectCost = TotalDirectCost.replace(/,/g,"");
		if(isNaN(TotalDirectCost)){
			TotalDirectCost = 0;		
		}
		document.getElementById('TotalDirectCost').value = "$"+convertDollarNumberFormat(parseFloat(TotalDirectCost).toFixed(2));
		var totalProfit = totalProfit - parseFloat(TotalDirectCost).toFixed(2);
	}
	document.getElementById('totalProfit').value = "$"+convertDollarNumberFormat(totalProfit);
	
	// updating percentage profits
	if(totalProfit==0 && totalCustCharges==0) {
		document.getElementById('percentageProfit').firstChild.data = "0% Profit";
	} else {
		var calcPerc = Math.round((totalProfit/totalCustCharges)*100);

		if(isNaN(calcPerc)){		calcPerc = 0;			}
		document.getElementById('percentageProfit').firstChild.data = calcPerc+"% Profit";

		var frieghtBrokerStatus = document.getElementById('frieghtBroker').value;
		var minimumMargin = document.getElementById('minimumMargin').value;

		// if % profit less then minimum margin, display message
		if(Number(calcPerc) <  Number(minimumMargin)) {
			$('#checkProfit').html('');
			var MarginApproved = document.getElementById('MarginApproved').value; 
			var LastApprovedRate = Math.round(document.getElementById('LastApprovedRate').value); 
			if(MarginApproved==0 || LastApprovedRate != Number(calcPerc)){
				if(minimumMargin!=0){
					document.getElementById("checkProfit").innerHTML+= "Load does not meet Minimum Margin requirements.";
				}
            	document.getElementById("MinimumMarginReached").value = 0;
			}
            // set margin 
            if(frieghtBrokerStatus == 0){
                $("#pricingNotes").css('margin-top','16px');
            }else{  
                $("#pricingNotes").css('margin-top','3px');
            }
        }
        else{
        	$('#checkProfit').html('');
        	document.getElementById("MinimumMarginReached").value = 1;
        	// reset margin
        	if(frieghtBrokerStatus == 0){
                $("#pricingNotes").css('margin-top','32px');
            }else{  
            	if($('input[name=allowloadentry]').val() == 1){
                	$("#pricingNotes").css('margin-top','38px');
            	}
            	else{
            		$("#pricingNotes").css('margin-top','14px');
            	}



            }
        }    
	}
}

function carrierReportOnClick(loadid,URLToken,dsn) {
	var minimumMargin = document.getElementById('minimumMargin').value;
	var percentageProfit = document.getElementById('percentageProfit').innerHTML;
	var frieghtBrokerStatus = document.getElementById('frieghtBroker').value;
	var carrierratecon = document.getElementById('carrierratecon').value;
	var iscarrier = document.getElementById('iscarrier').value;
	var percentageProfit = trim(percentageProfit.replace("% Profit", ""));
	var CompanyID = document.getElementById('CompanyID').value;
	var frieghtBrokerName='Dispatch';
	if(frieghtBrokerStatus ==1 || (frieghtBrokerStatus == 2 && iscarrier == 1 )){
		var frieghtBrokerName='Carrier';
	}
	// Validation removed
	//window.open('../reports/loadReportForDispatch.cfm?type='+frieghtBrokerName+'&loadid='+loadid+'&CompanyID='+CompanyID+'&carrierratecon='+carrierratecon+'&dsn='+dsn+'&'+URLToken+'');
	window.open('index.cfm?event=CarrierReport&LoadID='+loadid+'&'+URLToken+'');
}

function carrierMailReportOnClick(loadid,URLToken,percentageProfit1) {
	var minimumMargin = document.getElementById('minimumMargin').value;
	var frieghtBrokerStatus = document.getElementById('frieghtBroker').value;
	var iscarrier = document.getElementById('iscarrier').value;
	var MarginApproved = document.getElementById('MarginApproved').value;
	var frieghtBrokerName='Dispatch';
	if(frieghtBrokerStatus ==1 || (frieghtBrokerStatus == 2 && iscarrier == 1 )){
		var frieghtBrokerName='Carrier';
	}
	if(Number(percentageProfit1) >=  Number(minimumMargin) || Number(minimumMargin) == 0 || MarginApproved==1) {
		newwindow=window.open('index.cfm?event=loadMail&type='+frieghtBrokerName+'&loadid='+loadid+'&'+URLToken+'','Map','height=600,width=850');/*,'Map','height=400,width=750'*/
		if (window.focus) {
			newwindow.focus()
		}
	} 
	else {
		alert('You cannot print the Carrier Rate Confirmation because the Margin does not meet the minimum Margin percent of '+minimumMargin+'%');
		return false;
	}
}

function BOLReportOnClick(loadid,URLToken) {
	newwindow=window.open('index.cfm?event=loadMail&type=BOL&loadid='+loadid+'&'+URLToken+'','Map','height=400,width=750');/*,'Map','height=400,width=750'*/
	if (window.focus) {
		newwindow.focus()
	}
}
function shortBOLOnClick(loadid,URLToken) {
	newwindow=window.open('index.cfm?event=loadMail&type=BOLShort&loadid='+loadid+'&'+URLToken+'','Map','height=400,width=750');/*,'Map','height=400,width=750'*/
	if (window.focus) {
		newwindow.focus()
	}
}

function CarrierWorkOrderImportOnClick(loadid,URLToken,dsn) {
	window.open('../reports/CarrierWorkOrderImport.cfm?loadid='+loadid+'&dsn='+dsn+'&'+URLToken+'');
}

function CarrierMailWorkOrderImportOnClick(loadid,URLToken) {
	newwindow=window.open('index.cfm?event=loadMail&type=importWork&loadid='+loadid+'&'+URLToken+'','Map','height=400,width=750');
	if (window.focus) {
		newwindow.focus()
	}
}

function CarrierWorkOrderExportOnClick(loadid,URLToken,dsn) {
	window.open('../reports/CarrierWorkOrderExport.cfm?loadid='+loadid+'&dsn='+dsn+'&'+URLToken+'');
}

function CarrierMailWorkOrderExportOnClick(loadid,URLToken) {
	newwindow=window.open('index.cfm?event=loadMail&type=exportWork&loadid='+loadid+'&'+URLToken+'','Map','height=400,width=750');
	if (window.focus) {
		newwindow.focus()
	}
}

function CustomerReportOnClick(loadid,URLToken,dsn) {
	var CompanyID=document.getElementById('CompanyID').value;
	var dsn=document.getElementById('dsn').value;
	window.open('index.cfm?event=CustomerInvoiceReport&LoadID='+loadid+'&'+URLToken+'');
}

function CustomerMailReportOnClick(loadid,URLToken,customerID) {
	newwindow=window.open('index.cfm?event=loadMail&type=customer&loadid='+loadid+'&customerID='+customerID+'&'+URLToken+'','Map','height=400,width=750');
	if (window.focus) {
		newwindow.focus()
	}
}
function mailDocOnClick(URLToken,docType,ID) {
	var urlID ="";
	if(ID != ""){urlID = '&id='+ID;}
	newwindow=window.open('index.cfm?event=loadMail&type=mailDoc&attachTo=10&docType='+docType+'&'+URLToken+''+urlID+'','Map','height=600,width=750');
	if (window.focus) {
		newwindow.focus()
	}
}

function openCarrierOnboardPopup(URLToken,ID){
	
	if(ID != ""){
		newwindow=window.open('index.cfm?event=loadMail&type=CarrierOnboard&CarrierID='+ID+'&'+URLToken,'Map','height=600,width=750');
	}
}
//BOL report url is in loadswitch.cfm
// Updates the total RatePerMiles

function updateTotalRates(dsn) { 
	var TotalMiles=0;
	var miles1 = document.getElementById('milse').value;
	if(isNaN(miles1) || !miles1.length){
		miles1 = 0;
		document.getElementById('milse').value=0;
	}
	TotalMiles = parseFloat(miles1);

	var IncludeDhMilesInTotalMiles = document.getElementById('IncludeDhMilesInTotalMiles').value;
	var frieghtBroker = document.getElementById('frieghtBroker').value;
	var deadHeadMiles = document.getElementById('deadHeadMiles').value;
	if(frieghtBroker !=1 && IncludeDhMilesInTotalMiles ==1 &  $.trim(deadHeadMiles).length && !isNaN($.trim(deadHeadMiles))){
		TotalMiles = TotalMiles + parseFloat(deadHeadMiles);
	}

	var custElem = $('#cutomerIdValueContainer').val();
	var customerId = custElem; //custElem.options[custElem.selectedIndex].value;
	
	var CustomerRates = 0; // TODO: get correct rate/mile from DB
	var CarrierRates = 0; // TODO: get correct rate/mile from DB
	
	for(var i=1; i<=10; i++) {
		if(document.getElementById('stop'+i)==null || document.getElementById('stop'+i).style.display == 'none')
			continue;
		var ithMile = document.getElementById('milse'+i).value;
		if(isNaN(ithMile)){
			ithMile = 0;
			document.getElementById('milse'+i).value=0;
		}
		TotalMiles += parseFloat(ithMile);
	}
		
	// correct calculation:
	var custTotalMiles = TotalMiles + ((TotalMiles/100)*0);
	var carTootalMiles = TotalMiles - ((TotalMiles/100)*0);
	document.getElementById('CustomerMilesCalc').value = convertNumberFormat(custTotalMiles);
	document.getElementById('CarrierMilesCalc').value = convertNumberFormat(carTootalMiles);
	
	var customerRatePerMile = document.getElementById('CustomerRatePerMile').value;
	var carrierRatePerMile = document.getElementById('CarrierRatePerMile').value;
	
	customerRatePerMile = customerRatePerMile.replace("$","");
	customerRatePerMile = customerRatePerMile.replace(/,/g,"");
	
	carrierRatePerMile = carrierRatePerMile.replace("$","");
	carrierRatePerMile = carrierRatePerMile.replace(/,/g,"");
	
	if(trim(customerRatePerMile) == "0" || trim(customerRatePerMile)=="")
		document.getElementById('CustomerRatePerMile').value = "$"+CustomerRates; // 0.00 for now. Need to get it from DB
	else
		CustomerRates = parseFloat(customerRatePerMile);
		
	if(trim(carrierRatePerMile) == "0" || trim(carrierRatePerMile)=="")
		document.getElementById('CarrierRatePerMile').value = "$"+CarrierRates;  // 0.00 for now. Need to get it from DB
	else
		CarrierRates = parseFloat(carrierRatePerMile);
	
	var totalCustomerMilesRate = custTotalMiles * CustomerRates;
	var totalCarrierMilesRate = carTootalMiles * CarrierRates;
	
	totalCustomerMilesRate = totalCustomerMilesRate.toFixed(2); // till 2 decimal places
	totalCarrierMilesRate = totalCarrierMilesRate.toFixed(2); // till 2 decimal places
	
	document.getElementById('CustomerMiles').value = "$"+convertDollarNumberFormat(totalCustomerMilesRate);
	document.getElementById('CarrierMiles').value = "$"+convertDollarNumberFormat(totalCarrierMilesRate);
	document.getElementById('CustomerMilesTotalAmount').value = "$"+convertDollarNumberFormat(totalCustomerMilesRate);
	document.getElementById('CarrierMilesTotalAmount').value = "$"+convertDollarNumberFormat(totalCarrierMilesRate);

	updateTotalAndProfitFields();
}

function calculateTotalRates(dsn) {
	updateTotalRates(dsn);
}

function ClaculateDistanceNext(frmload1,stpNo1) {   
	var calFunc="CalcDist('+stpNo1+')";
	setTimeout(calFunc,1000);
}

function isValidPercentage(strValue) {
	if(isNaN(strValue))	{
		return false;
	} else {
		if(strValue.indexOf('.') >= 0){
			if(strValue[1] != '.' && strValue[2] != '.')
				return false;
		}
		else{
			if(strValue.length >2)
				return false;
		}
	}
	return true;
}

function addQuickCalcInfoToLog(dsn,userName) {
	var companyName = document.getElementById('companyName').value;
	var consigneeAddress = document.getElementById('conAddress').value;
	var shipperAddress = document.getElementById('shipperAddress').value;
	var custRatePerMile = getFloat(document.getElementById('customerRate').value);
	var carRatePerMile = getFloat(document.getElementById('carrierRate').value);
	var custMiles = getFloat(document.getElementById('customerMiles').value);
	var carMiles = getFloat(document.getElementById('carrierMiles').value);
	var customerAmount = getFloat(document.getElementById('customerAmount').value);
	var carrierAmount = getFloat(document.getElementById('carrierAmount').value);
	var path= urlComponentPath+"loadgateway.cfc?method=addQuickCalcInfoToLog";
	$.ajax({
		type: "post",
		url: path,
		dataType: "json",
		async: false, 
		data: {
			dsn: dsn,
			consigneeAddress: consigneeAddress,
			shipperAddress: shipperAddress,
			custRatePerMile: custRatePerMile,
			carRatePerMile: carRatePerMile,
			custMiles: custMiles,
			carMiles: carMiles,
			customerAmount: customerAmount,
			carrierAmount: carrierAmount,
			companyName: companyName,
			userName: userName,
		},
		success: function(){}
	});

}

function clearQuickCalcFields() {
	document.getElementById('companyName').value = "";
	document.getElementById('conAddress').value = "";
	document.getElementById('shipperAddress').value = "";
	document.getElementById('customerRate').value = "0.00";
	document.getElementById('carrierRate').value = "0.00";
	document.getElementById('customerAmount').value = "0.00";
	document.getElementById('customerMiles').value = "0.00";
	document.getElementById('carrierMiles').value = "0.00";
	document.getElementById('carrierAmount').value = "0.00";
}


function validateFields() {
	
	var minimunLoadNumber = document.getElementById('minimunLoadNumber').value.trim();
	if(!minimunLoadNumber.length || isNaN(minimunLoadNumber)){
		alert('Invalid Starting Load#');
		$("#minimunLoadNumber").focus();
		return false;
	}

	var StartingActiveLoadNumber = document.getElementById('StartingActiveLoadNumber').value.trim();
	var LoadNumberAutoIncrement = $('#LoadNumberAutoIncrement').prop('checked');
	if(LoadNumberAutoIncrement && !StartingActiveLoadNumber.length || isNaN(StartingActiveLoadNumber)){
		alert('Invalid Starting Load#');
		$("#StartingActiveLoadNumber").focus();
		return false;
	}
	
	var FactoringFee = document.getElementById('FactoringFee').value.trim();
	if(!FactoringFee.length || isNaN(FactoringFee)){
		alert('Invalid Factoring Fee.');
		$("#FactoringFee").focus();
		return false;
	}

	var GPSDistanceInterval = document.getElementById('GPSDistanceInterval').value.trim();
	if(!GPSDistanceInterval.length || isNaN(GPSDistanceInterval)){
		alert('Invalid GPS Distance Interval.');
		$("#GPSDistanceInterval").val(0);
		$("#GPSDistanceInterval").focus();
		return false;
	}
	
	var minimumMargin = document.getElementById('minimumMargin').value.trim();
	if(!minimumMargin.length || isNaN(minimumMargin)){
		alert('Invalid Minimum Margin.');
		$("#minimumMargin").focus();
		return false;
	}

	var longMiles = document.getElementById('longMiles').value;
	var shortMiles = document.getElementById('shortMiles').value;
	if(longMiles[longMiles.length - 1] == '.')
		document.getElementById('longMiles').value = longMiles+'0';
	if(shortMiles[shortMiles.length - 1] == '.')
		document.getElementById('shortMiles').value = shortMiles+'0';
	if(isValidPercentage(longMiles) && isValidPercentage(shortMiles)){
		if(jQuery.inArray($("#defaultSystemCurrency").val(), $("#allowedSystemCurrencies").val()) == -1) {
			alert("Default System Currency is not selected in the Allowed Currencies list.");
			$("#defaultSystemCurrency").focus();
			return false;
		} 
		
		return true;
	}		
	alert('Invalid percentage entered');
	return false;
}

function getMCDetails(url,mcno,dsn,type) {
	if(type == 'carrier') {
		var numberType = 'MC';
	} else {
		var numberType = 'Lic';
	}
	var CompanyID=document.getElementById('CompanyID').value;
	var path = urlComponentPath+"loadgateway.cfc?method=checkMCNumber&dsn="+dsn+"&mcno="+mcnomcno+"&CompanyID="+CompanyID;
	var mcNoStatus = $.ajax({
	    type: "GET",
	    url: path,
	    async: false
	}).responseText;   
	if (mcNoStatus=="true") {
		alert(numberType + ' Number is already exist in database.');
		document.getElementById("MCNumber").focus();
		return false;
	}
}

function checkLogin(companyid,loginid,dsn,empID) {	

	var path = urlComponentPath+"loadgateway.cfc?method=checkLoginId&dsn="+dsn+"&loginid="+loginid+"&companyid="+companyid+"&empID="+empID;
	var loginStatus = $.ajax({
	    type: "GET",
	    url: path,
	    async: false
	}).responseText;
	if (loginStatus=="true") {
		alert('Login name already exists. Please change it and click save.');
		document.getElementById("loginid").focus();
		return false;
	}
	checkUnload();
}

function ChangeCustomerInfo(customerid) {
	alert('Please delete stops from different customer, Before changing the customer');
	document.getElementById("cutomerId").value=customerid;
	return false;
}

function convertNumberFormat(cNumber) {
    var parts = cNumber.toFixed(2).toString().split(".");
    parts[0] = parts[0].replace(/,/g, "").replace(/\B(?=(\d{3})+(?!\d))/g, ",");
    return parts.join(".");
}

function convertDollarNumberFormat(cNumber) {
    var parts = cNumber.toString().split(".");
    parts[0] = parts[0].replace(/,/g, "").replace(/\B(?=(\d{3})+(?!\d))/g, ",");
    return parts.join(".");
}

function checkloadNUmberDB(val,varDsn) {
	document.getElementById("loadManualNo").value = val.replace(/[^0-9]/g,'');
	var valGt=document.getElementById("loadManualNo").value;
	var carID = document.getElementById("carrierID").value;
	var extLN = document.getElementById("LoadNumber").value;
	var CompanyID=document.getElementById("CompanyID").value;
	var xmlhttp;
	if (window.XMLHttpRequest) {
  		xmlhttp=new XMLHttpRequest();
	} else {
  		xmlhttp=new ActiveXObject("Microsoft.XMLHTTP");
  	}
	xmlhttp.onreadystatechange=function() {
  		if (xmlhttp.readyState==4 && xmlhttp.status==200) {
  				document.getElementById("myDiv").innerHTML='';
				document.getElementById("loadManualNoExists").value='';
			if(xmlhttp.responseText ==1) {  
				if (document.getElementById('LoadNumber').value=="") {
					document.getElementById("myDiv").innerHTML='<font color="red">Load number duplicate in system</font>';
					document.getElementById("loadManualNoExists").value=1;
		  		} else if(document.getElementById('LoadNumber').value !="" && (document.getElementById('LoadNumber').value != document.getElementById('loadManualNo').value ) ) {
			 		document.getElementById("myDiv").innerHTML='<font color="red">Load number duplicate in system</font>';
					document.getElementById("loadManualNoExists").value=1;
		  		}
			} else if(xmlhttp.responseText ==0){			
				document.getElementById("myDiv").innerHTML='';
				document.getElementById("loadManualNoExists").value='';
			} else {
				if(document.getElementById('LoadNumber').value !="" && (document.getElementById('LoadNumber').value != (xmlhttp.responseText.trim()) )) {
					document.getElementById("myDiv").innerHTML='<font color="red">Duplicate Load number('+xmlhttp.responseText.trim()+')</font>';
					document.getElementById("loadManualNoExists").value=1;
					document.getElementById("loadManualNoIdentExists").value=1;
				}else if(document.getElementById('LoadNumber').value==""){
					document.getElementById("myDiv").innerHTML='<font color="red">Duplicate Load number('+xmlhttp.responseText.trim()+')</font>';
					document.getElementById("loadManualNoExists").value=1;
					document.getElementById("loadManualNoIdentExists").value=1;
				}
			}
    	}
  	}
	xmlhttp.open("GET","checkloadNoexists.cfm?val="+valGt+"&varDsn="+varDsn+"&carID="+carID+"&extLN="+extLN+"&CompanyID="+CompanyID,true);
	xmlhttp.send();
}

function rememberSearchSession(data) {
	var isChecked = $(data).prop('checked');
	var searchText = $("#searchText").val();
	var csfrToken = $("#csfrToken").val();
	var getPath=urlComponentPath.split("/");
	var path = "/"+getPath[1]+"/www/webroot/sessionSettingajax.cfm?checked="+isChecked+"&searchText="+searchText+"&csfrToken="+csfrToken;
    $.ajax({
		type: "get",
		url: path,	
		success: function(data){

		}, 
		error: function(err){
			console.log(err);
		}
    });
}

function FilterStatus(data) {
	var isChecked = $(data).prop('checked');
	var csfrToken = $("#csfrToken").val();
	var getPath=urlComponentPath.split("/");
	var path = "/"+getPath[1]+"/www/webroot/sessionSettingajax.cfm?showStatus="+isChecked+"&csfrToken="+csfrToken;
    $.ajax({
		type: "get",
		url: path,	
		success: function(data){
			location.reload();
		}, 
		error: function(err){
			console.log(err);
		}
    });
	if(isChecked){
		$('.mystatusbox').show();
	}
	else{
		$('.mystatusbox').hide();
	}
}
function validationMaintenance(dsName) {
	var milesInterval=document.getElementById("milesInterval").value;
	var description=document.getElementById("description").value;
	var editid=document.getElementById("editid").value;
	var dateInterval=document.getElementById("dateInterval").value;
	var CompanyID=document.getElementById("CompanyID").value; 
	var intRegex = /[0-9 -()+]+$/;
	if (description==""){
		alert('please enter Description');
		document.getElementById("description").focus();
		return false;
	}
	if(dateInterval ==0 && milesInterval ==""){
		alert('please enter MilesInterval or DateInterval');
		document.getElementById("milesInterval").focus();
		return false;
	}
	if(milesInterval!=""){
		if (!milesInterval.match(intRegex)){
			alert('please enter miles interval in numbers');
			document.getElementById("milesInterval").focus();
			return false;
		}	
	}	
	var path = urlComponentPath+"equipmentgateway.cfc?method=getDescriptionDuplicate&dsName="+encodeURIComponent(dsName)+"&description="+description+"&editid="+editid+"&CompanyID="+CompanyID;
	$.ajax({
		type: "get",
		url: path,	
		success: function(data){
			if(data==1){
				$("#frmMaintenance").submit();
			}else{
				$("#errorShow").show();
				return false;
			}
		}, 
		error: function(err){
			return false;
		}
    });
}

function getmaintenancesetUpValues(dsName,CompanyID) {
	var description=document.getElementById("description").value;
	var path = urlComponentPath+"equipmentgateway.cfc?method=getMaintenanceInformationAjax&EquipmentMaintSetupId="+description+"&dsName="+dsName+"&CompanyID="+CompanyID;
	$.ajax({
		type: "get",
		url: path,	
		success: function(data) {
			if(data!=1){
				var returnedData = $.parseJSON($.trim(data));
				for(dataIndex=0;dataIndex < returnedData.DATA.length;dataIndex++){
					for(columnsIndex=0;columnsIndex < returnedData.COLUMNS.length;columnsIndex++){
						if (columnsIndex==1){
							$('#MilesInterval').val(returnedData.DATA[dataIndex][2]);
							$('#DateInterval option').each(function() {
								if($(this).val() == returnedData.DATA[dataIndex][3]) {
									$(this).prop("selected", true);
								}
							});
							$('#Notes').val(returnedData.DATA[dataIndex][4]);
						 }
					}
				}	
			} else {
				$("#MilesInterval").val('');
				$("#DateInterval").val(0);
				$("#Notes").val('');
			}
		}, 
		error: function(err) {
			return false;
		}
    });
}

function checkValidation() {
	var description=$("#description").val();
	var milesInterval=document.getElementById("MilesInterval").value;
	var dateInterval=document.getElementById("DateInterval").value;
	var Date=document.getElementById("Date").value;
	var intRegex = /[0-9 -()+]+$/;
	if(description=="") {
		alert('Please select the description');	
		return false;
	}
	if(dateInterval ==0 && milesInterval =="" && Date == "") {
		alert('please enter milesInterval or dateinterval or nextdate');
		document.getElementById("MilesInterval").focus();
		return false;
	}
	if(milesInterval!="") {
		if (!milesInterval.match(intRegex)){
			alert('please enter miles interval in numbers');
			document.getElementById("MilesInterval").focus();
			return false;
		}	
	}	
}

function checkDateFormatAll(ele) {
	var reg =/((^(10|12|0?[13578])([/])(3[01]|[12][0-9]|0?[1-9])([/])((1[8-9]\d{2})|([2-9]\d{3}))$)|(^(11|0?[469])([/])(30|[12][0-9]|0?[1-9])([/])((1[8-9]\d{2})|([2-9]\d{3}))$)|(^(0?2)([/])(2[0-8]|1[0-9]|0?[1-9])([/])((1[8-9]\d{2})|([2-9]\d{3}))$)|(^(0?2)([/])(29)([/])([2468][048]00)$)|(^(0?2)([/])(29)([/])([3579][26]00)$)|(^(0?2)([/])(29)([/])([1][89][0][48])$)|(^(0?2)([/])(29)([/])([2-9][0-9][0][48])$)|(^(0?2)([/])(29)([/])([1][89][2468][048])$)|(^(0?2)([/])(29)([/])([2-9][0-9][2468][048])$)|(^(0?2)([/])(29)([/])([1][89][13579][26])$)|(^(0?2)([/])(29)([/])([2-9][0-9][13579][26])$))/;
	var textValue=$(ele).val();
	
	if(textValue.length){
		if(!textValue.match(reg)){
			alert('Please enter a date in mm/dd/yyyy format');
			$(ele).focus();
			$(ele).val('');
		}
		else if($(ele).attr('id')=='shipperPickupDate'){
			calculateDeadHeadMiles();
		}
	}

}

function InvoiceDateFormat(ele){
	var dateValue=$(ele).val();
	if(dateValue.length){
		arr = dateValue.split('/');
		if(arr.length == 3){
			var m = String(arr[0]);
			var d = String(arr[1]);
			var y = String(arr[2]);
			if(y.length == 2){
				y = '20'+y;
			}
			$(ele).val(m+'/'+d+'/'+y);
		}
	}
}

function checkValidDateTime(ele){
	varID = $(ele).attr('id');
	
	if(varID.indexOf('Time')!=-1)
	{
		varTimeId = varID;
		if(varTimeId.indexOf('shipperTimeIn') !=-1)
		{
		varDateId = varTimeId.replace('shipperTimeIn','shipperPickupDate');
		varPickupTimeId = varTimeId.replace('shipperTimeIn','shipperpickupTime');
		varPickupStopdateQ = varTimeId.replace('shipperTimeIn','ShipperStopDateQ');  
		varshipperEdiReasonCodeId = varTimeId.replace('shipperTimeIn','shipperEdiReasonCode'); 
		varshipperTimeOut = varTimeId.replace('shipperTimeIn','shipperTimeOut'); 
		var stop = varTimeId.split('shipperTimeIn');
		if (stop[1]==''){
			stopnum = 1;
		}
		else{
			stopnum = '';
		}
		
		varshipperEdiReasonLabelId = varTimeId.replace('shipperTimeIn','labelShipperTimein'); 


			if  (  $.trim($('#'+varPickupTimeId).val()).length 
				&& $.trim($('#'+varPickupStopdateQ).val()).length){		
					
				if($('#'+varPickupTimeId).val().indexOf('-') != -1 
					&& $('#'+varPickupStopdateQ).val().indexOf('-') != -1 
					&& $('#'+varPickupStopdateQ).val() == '37-38' 
					){
						if( $('#'+varTimeId).val() < $('#'+varPickupTimeId).val().substring(0,4)
							|| $('#'+varTimeId).val() > $('#'+varPickupTimeId).val().substring(5,9)
							 ){
						$('#'+varshipperEdiReasonCodeId).css("display","block"); 
						$('.'+varshipperEdiReasonLabelId+stopnum).css("display","block"); 
						$('.'+varshipperEdiReasonLabelId+stopnum).css('color','red'); 
						}
						else{							
							$('#'+varshipperEdiReasonCodeId).css("display","none"); 
							$("label:contains('Late Reason')").css("display","none");
							$('.'+varshipperEdiReasonLabelId+stopnum).css('color','black');

						}					

				}				
				else{
					$('#'+varshipperEdiReasonCodeId).css("display","none"); 
					$("label:contains('Late Reason')").css("display","none");
					$('.'+varshipperEdiReasonLabelId+stopnum).css('color','black');
				}



			}
			else if ($('#'+varTimeId).val() > $('#'+varPickupTimeId).val())
					{
						$('#'+varshipperEdiReasonCodeId).css("display","block"); 
						$('.'+varshipperEdiReasonLabelId+stopnum).css("display","block"); 
						$('.'+varshipperEdiReasonLabelId+stopnum).css('color','red'); 	

					}
					else{
					$('#'+varshipperEdiReasonCodeId).css("display","none"); 
					$("label:contains('Late Reason')").css("display","none");
					$('.'+varshipperEdiReasonLabelId+stopnum).css('color','black');
				}

			if( $.trim($('#'+varTimeId).val()).length && $.trim($('#'+varshipperTimeOut).val()).length &&
				($('#'+varTimeId).val() > $('#'+varshipperTimeOut).val())
				){
				alert('The Time in is after the Time out.');
				$('#'+varTimeId).focus();
			}
			
		}


		/*Shipper Time out*/
		if(varTimeId.indexOf('shipperTimeOut') !=-1)
		{
		varDateId = varTimeId.replace('shipperTimeOut','shipperPickupDate');
		varPickupTimeId = varTimeId.replace('shipperTimeOut','shipperpickupTime');
		varPickupStopdateQ = varTimeId.replace('shipperTimeOut','ShipperStopDateQ');  
		varshipperEdiReasonCodeId = varTimeId.replace('shipperTimeOut','shipperEdiReasonCode'); 
		var stop = varTimeId.split('shipperTimeOut');
		if (stop[1]==''){
			stopnum = 1;
		}
		else{
			stopnum = '';
		}
		
		varshipperEdiReasonLabelId = varTimeId.replace('shipperTimeOut','labelShipperTimein'); 
		

			if  (  $.trim($('#'+varPickupTimeId).val()).length 
				&& $.trim($('#'+varPickupStopdateQ).val()).length){		
					
				if($('#'+varPickupTimeId).val().indexOf('-') != -1 
					&& $('#'+varPickupStopdateQ).val().indexOf('-') != -1 
					&& $('#'+varPickupStopdateQ).val() == '37-38' 
					){
						if( $('#'+varTimeId).val() < $('#'+varPickupTimeId).val().substring(0,4)
							|| $('#'+varTimeId).val() > $('#'+varPickupTimeId).val().substring(5,9)
							 ){
						$('#'+varshipperEdiReasonCodeId).css("display","block"); 
						$('.'+varshipperEdiReasonLabelId+stopnum).css("display","block"); 
						$('.'+varshipperEdiReasonLabelId+stopnum).css('color','red'); 
						}
						else{							
							$('#'+varshipperEdiReasonCodeId).css("display","none"); 
							$("label:contains('Late Reason')").css("display","none");
							$('.'+varshipperEdiReasonLabelId+stopnum).css('color','black');

						}					

				}
				else{
					$('#'+varshipperEdiReasonCodeId).css("display","none"); 
					$("label:contains('Late Reason')").css("display","none");
					$('.'+varshipperEdiReasonLabelId+stopnum).css('color','black');
				}


			}
			varshipperTimeIn = varTimeId.replace('shipperTimeOut','shipperTimeIn');
			if($.trim($('#'+varTimeId).val()).length && $.trim($('#'+varshipperTimeIn).val()).length &&
				$('#'+varshipperTimeIn).val() > $('#'+varTimeId).val()
				){
				alert('The Time in is after the Time out.');
				$('#'+varTimeId).focus();
			}
			
		}


		if(varTimeId.indexOf('consigneeTimeIn') !=-1)
		{
		varDateId = varTimeId.replace('consigneeTimeIn','consigneePickupDate');
		varPickupTimeId = varTimeId.replace('consigneeTimeIn','consigneepickupTime'); 
		varConsigneeStopdateQ = varTimeId.replace('consigneeTimeIn','ConsigneeStopDateQ');  
		varconsigneeEdiReasonCodeId = varTimeId.replace('consigneeTimeIn','consigneeEdiReasonCode'); 
		var stop = varTimeId.split('consigneeTimeIn');
		if (stop[1]==''){
			stopnum = 1;
		}
		else{
			stopnum = '';
		}
		
		varconsigneeEdiReasonLabelId = varTimeId.replace('consigneeTimeIn','labelConsigneeTimein'); 

		if  (  $.trim($('#'+varPickupTimeId).val()).length 
				&& $.trim($('#'+varConsigneeStopdateQ).val()).length){		
				
				if($('#'+varPickupTimeId).val().indexOf('-') != -1 
					&& $('#'+varConsigneeStopdateQ).val().indexOf('-') != -1 
					&& $('#'+varConsigneeStopdateQ).val() == '53-54' 
					){
						if( $('#'+varTimeId).val() < $('#'+varPickupTimeId).val().substring(0,4)
					|| $('#'+varTimeId).val() > $('#'+varPickupTimeId).val().substring(5,9)
					 ){
						$('#'+varconsigneeEdiReasonCodeId).css("display","block"); 
						$('.'+varconsigneeEdiReasonLabelId+stopnum).css("display","block"); 
						$('.'+varconsigneeEdiReasonLabelId+stopnum).css('color','red'); 	
						}
						else{
							$('#'+varconsigneeEdiReasonCodeId).css("display","none"); 
							$("label:contains('Late Reason')").css("display","none");
							$('.'+varconsigneeEdiReasonLabelId+stopnum).css('color','black');
						}				

				}
				else if ($('#'+varTimeId).val() > $('#'+varPickupTimeId).val())
				{
					$('#'+varconsigneeEdiReasonCodeId).css("display","block"); 
					$('.'+varconsigneeEdiReasonLabelId+stopnum).css("display","block"); 
					$('.'+varconsigneeEdiReasonLabelId+stopnum).css('color','red'); 	

				}
				else{
					$('#'+varconsigneeEdiReasonCodeId).css("display","none"); 
					$("label:contains('Late Reason')").css("display","none");
					$('.'+varconsigneeEdiReasonLabelId+stopnum).css('color','black');
				}


			}
			varconsigneeTimeOut = varTimeId.replace('consigneeTimeIn','consigneeTimeOut');
			if($.trim($('#'+varTimeId).val()).length && $.trim($('#'+varconsigneeTimeOut).val()).length &&
				$('#'+varTimeId).val() > $('#'+varconsigneeTimeOut).val()){
				alert('The Time in is after the Time out.');
				$('#'+varTimeId).focus();
			}
		
		}

		/*Consignee time out*/
		if(varTimeId.indexOf('consigneeTimeOut') !=-1)
		{
		varDateId = varTimeId.replace('consigneeTimeOut','consigneePickupDate');
		varPickupTimeId = varTimeId.replace('consigneeTimeOut','consigneepickupTime'); 
		varConsigneeStopdateQ = varTimeId.replace('consigneeTimeOut','ConsigneeStopDateQ');  
		varconsigneeEdiReasonCodeId = varTimeId.replace('consigneeTimeOut','consigneeEdiReasonCode'); 
		var stop = varTimeId.split('consigneeTimeOut');
		if (stop[1]==''){
			stopnum = 1;
		}
		else{
			stopnum = '';
		}
		
		varconsigneeEdiReasonLabelId = varTimeId.replace('consigneeTimeOut','labelConsigneeTimein'); 

		if  (  $.trim($('#'+varPickupTimeId).val()).length 
				&& $.trim($('#'+varConsigneeStopdateQ).val()).length){		
				
				if($('#'+varPickupTimeId).val().indexOf('-') != -1 
					&& $('#'+varConsigneeStopdateQ).val().indexOf('-') != -1 
					&& $('#'+varConsigneeStopdateQ).val() == '53-54' 
					){
						if( $('#'+varTimeId).val() < $('#'+varPickupTimeId).val().substring(0,4)
					|| $('#'+varTimeId).val() > $('#'+varPickupTimeId).val().substring(5,9)
					 ){
						$('#'+varconsigneeEdiReasonCodeId).css("display","block"); 
						$('.'+varconsigneeEdiReasonLabelId+stopnum).css("display","block"); 
						$('.'+varconsigneeEdiReasonLabelId+stopnum).css('color','red'); 	
						}
						else{
							$('#'+varconsigneeEdiReasonCodeId).css("display","none"); 
							$("label:contains('Late Reason')").css("display","none");
							$('.'+varconsigneeEdiReasonLabelId+stopnum).css('color','black');
						}				

				}
				else{
					$('#'+varconsigneeEdiReasonCodeId).css("display","none"); 
					$("label:contains('Late Reason')").css("display","none");
					$('.'+varconsigneeEdiReasonLabelId+stopnum).css('color','black');
				}


			}
			varconsigneeTimeIn = varTimeId.replace('consigneeTimeOut','consigneeTimeIn');
			if($.trim($('#'+varTimeId).val()).length && $.trim($('#'+varconsigneeTimeIn).val()).length &&
				$('#'+varconsigneeTimeIn).val() > $('#'+varTimeId).val()){
				alert('The Time in is after the Time out.');
				$('#'+varTimeId).focus();
			}
		
		}


		if(varTimeId.indexOf('shipperpickupTime') !=-1)
		{

		varDateId = varTimeId.replace('shipperpickupTime','shipperPickupDate');
		varPickupTimeId = varTimeId.replace('shipperpickupTime','shipperpickupTime');
		varPickupStopdateQ = varTimeId.replace('shipperpickupTime','ShipperStopDateQ');  
		varshipperEdiReasonCodeId = varTimeId.replace('shipperpickupTime','shipperEdiReasonCode'); 
		varshipperTimeIn = varTimeId.replace('shipperpickupTime','shipperTimeIn'); 
		varshipperTimeOut = varTimeId.replace('shipperpickupTime','shipperTimeOut'); 
		var stop = varTimeId.split('shipperpickupTime');
		if (stop[1]==''){
			stopnum = 1;
		}
		else{
			stopnum = '';
		}
		
		varshipperEdiReasonLabelId = varTimeId.replace('shipperpickupTime','labelShipperTimein'); 


			if  (  $.trim($('#'+varPickupTimeId).val()).length 
				&& $.trim($('#'+varPickupStopdateQ).val()).length){		
					
				if($('#'+varPickupTimeId).val().indexOf('-') != -1 
					&& $('#'+varPickupStopdateQ).val().indexOf('-') != -1 
					&& $('#'+varPickupStopdateQ).val() == '37-38' 
					){
						if( $('#'+varshipperTimeIn).val() < $('#'+varPickupTimeId).val().substring(0,4)
							|| $('#'+varshipperTimeIn).val() > $('#'+varPickupTimeId).val().substring(5,9)
							 ){
						$('#'+varshipperEdiReasonCodeId).css("display","block"); 
						$('.'+varshipperEdiReasonLabelId+stopnum).css("display","block"); 
						$('.'+varshipperEdiReasonLabelId+stopnum).css('color','red'); 
						}
						else{							
							$('#'+varshipperEdiReasonCodeId).css("display","none"); 
							$("label:contains('Late Reason')").css("display","none");
							$('.'+varshipperEdiReasonLabelId+stopnum).css('color','black');

						}					

				}
				else if ($('#'+varshipperTimeIn).val() > $('#'+varPickupTimeId).val())
					{
						$('#'+varshipperEdiReasonCodeId).css("display","block"); 
						$('.'+varshipperEdiReasonLabelId+stopnum).css("display","block"); 
						$('.'+varshipperEdiReasonLabelId+stopnum).css('color','red'); 	

					}
				else{
					$('#'+varshipperEdiReasonCodeId).css("display","none"); 
					$("label:contains('Late Reason')").css("display","none");
					$('.'+varshipperEdiReasonLabelId+stopnum).css('color','black');
				}


			}

			if( $.trim($('#'+varshipperTimeIn).val()).length && $.trim($('#'+varshipperTimeOut).val()).length &&
				($('#'+varshipperTimeIn).val() > $('#'+varshipperTimeOut).val())
				){
				alert('The Time in is after the Time out.');
				$('#'+varshipperTimeIn).focus();
			}
			
		}

		if(varTimeId.indexOf('consigneepickupTime') !=-1)
		{
		varDateId = varTimeId.replace('consigneepickupTime','consigneePickupDate');
		varPickupTimeId = varTimeId.replace('consigneepickupTime','consigneepickupTime'); 
		varConsigneeStopdateQ = varTimeId.replace('consigneepickupTime','ConsigneeStopDateQ');  
		varconsigneeEdiReasonCodeId = varTimeId.replace('consigneepickupTime','consigneeEdiReasonCode'); 
		varconsigneeTimeIn = varTimeId.replace('consigneepickupTime','consigneeTimeIn'); 
		varconsigneeTimeOut = varTimeId.replace('consigneepickupTime','consigneeTimeOut'); 

		var stop = varTimeId.split('consigneepickupTime');
		if (stop[1]==''){
			stopnum = 1;
		}
		else{
			stopnum = '';
		}
		
		varconsigneeEdiReasonLabelId = varTimeId.replace('consigneepickupTime','labelConsigneeTimein'); 

		if  (  $.trim($('#'+varPickupTimeId).val()).length 
				&& $.trim($('#'+varConsigneeStopdateQ).val()).length){		
				
				if($('#'+varPickupTimeId).val().indexOf('-') != -1 
					&& $('#'+varConsigneeStopdateQ).val().indexOf('-') != -1 
					&& $('#'+varConsigneeStopdateQ).val() == '53-54' 
					){
						if( $('#'+varconsigneeTimeIn).val() < $('#'+varPickupTimeId).val().substring(0,4)
					|| $('#'+varconsigneeTimeIn).val() > $('#'+varPickupTimeId).val().substring(5,9)
					 ){
						$('#'+varconsigneeEdiReasonCodeId).css("display","block"); 
						$('.'+varconsigneeEdiReasonLabelId+stopnum).css("display","block"); 
						$('.'+varconsigneeEdiReasonLabelId+stopnum).css('color','red'); 	
						}
						else{
							$('#'+varconsigneeEdiReasonCodeId).css("display","none"); 
							$("label:contains('Late Reason')").css("display","none");
							$('.'+varconsigneeEdiReasonLabelId+stopnum).css('color','black');
						}				

				}
				else if ($('#'+varconsigneeTimeIn).val() > $('#'+varPickupTimeId).val())
				{
					//alert('here'+varconsigneeEdiReasonLabelId);
					$('#'+varconsigneeEdiReasonCodeId).css("display","block"); 
					$('.'+varconsigneeEdiReasonLabelId+stopnum).css("display","block"); 
					$('.'+varconsigneeEdiReasonLabelId+stopnum).css('color','red'); 	

				}
				else{
					$('#'+varconsigneeEdiReasonCodeId).css("display","none"); 
					$("label:contains('Late Reason')").css("display","none");
					$('.'+varconsigneeEdiReasonLabelId+stopnum).css('color','black');
				}


			}
			
			if($.trim($('#'+varconsigneeTimeIn).val()).length && $.trim($('#'+varconsigneeTimeOut).val()).length &&
				$('#'+varconsigneeTimeIn).val() > $('#'+varconsigneeTimeOut).val()){
				alert('The Time in is after the Time out.');
				$('#'+varconsigneeTimeIn).focus();
			}
		
		}

		







		
		if(varTimeId.indexOf('shipperTimeOut') !=-1)
		{
		varDateId = varTimeId.replace('shipperTimeOut','shipperPickupDate');
		}
		if(varTimeId.indexOf('consigneeTimeOut') !=-1)
		{
		varDateId = varTimeId.replace('consigneeTimeOut','consigneePickupDate');
		}

		if ($('#'+varTimeId).val().length == 4 ){
		var hourPart = $('#'+varTimeId).val().substr(0, 2);
		var minutePart = $('#'+varTimeId).val().substr(2, 2);
		if(hourPart > 23 || minutePart > 59){
			alert('Please enter valid time in HHMM format');
			$('#'+varTimeId).focus();
		}
		else{
			checkDateFormatNear($('#'+varDateId));
		}
	}
	else if($.trim($('#'+varTimeId).val()).length){
		alert('Please enter pickup time in HHMM format');
			$('#'+varTimeId).focus();
			
	}
	}
	else{
		varDateId = varID;
		if(varDateId.indexOf('shipperPickupDate') !=-1)
		{
		varTimeId = varDateId.replace('shipperPickupDate','shipperTimeIn');
		}
		if(varDateId.indexOf('consigneePickupDate') !=-1)
		{
		varTimeId = varDateId.replace('consigneePickupDate','consigneeTimeIn');
		}
	}	
	
	
}

function checkDateFormatNear(ele) {
	var reg =/((^(10|12|0?[13578])([/])(3[01]|[12][0-9]|0?[1-9])([/])((1[8-9]\d{2})|([2-9]\d{3}))$)|(^(11|0?[469])([/])(30|[12][0-9]|0?[1-9])([/])((1[8-9]\d{2})|([2-9]\d{3}))$)|(^(0?2)([/])(2[0-8]|1[0-9]|0?[1-9])([/])((1[8-9]\d{2})|([2-9]\d{3}))$)|(^(0?2)([/])(29)([/])([2468][048]00)$)|(^(0?2)([/])(29)([/])([3579][26]00)$)|(^(0?2)([/])(29)([/])([1][89][0][48])$)|(^(0?2)([/])(29)([/])([2-9][0-9][0][48])$)|(^(0?2)([/])(29)([/])([1][89][2468][048])$)|(^(0?2)([/])(29)([/])([2-9][0-9][2468][048])$)|(^(0?2)([/])(29)([/])([1][89][13579][26])$)|(^(0?2)([/])(29)([/])([2-9][0-9][13579][26])$))/;
	var textValue=$(ele).val();
	
	if(textValue.length){
		if(!textValue.match(reg)){
			alert('Please enter a date in mm/dd/yyyy format');
			$(ele).focus();
			return false;
		}
		else{
			var nowDate = new Date();	
			var currDate = nowDate.getFullYear()+'/'+(nowDate.getMonth()+1)+'/'+nowDate.getDate(); 		
			var selectedDate = new Date(textValue);
			var newselectedDate = selectedDate.getFullYear()+'/'+(selectedDate.getMonth()+1)+'/'+selectedDate.getDate();
			if (newselectedDate != currDate && selectedDate < nowDate) {
				alert('You are using a date in the past, please correct it if needed.');
				$(ele).focus();				
				return false;
			}	
			
		return true;
		}
	}
	else{
		alert('Please enter a date in mm/dd/yyyy format');
		$(ele).focus();		
		return false;
	}	
	
}

function deleteEquipmaintTrans(ele,id,dsName,equipMaintId) {
	var equipmentId=document.getElementById("equipmentId").value;
	var path = urlComponentPath+"equipmentgateway.cfc?method=deleteEquipmentsMainTransaction&equipMainID="+id+"&dsName="+dsName+"&equipmentId="+equipmentId+"&equipMaintId="+equipMaintId;
	if(confirm("Are you sure to delete it ?")) {
		$.ajax({
			type: "get",
			url: path,	
			success: function(data){
				$(ele).parent().parent().remove();
				location.reload();
				
			}, error: function(err){
				console.log(err);
				return false;
			}
		});
    }
    else{
        return false;
    }
}

function checkValidationTransaction() {
	var Odometer=$("#Odometer").val();
	var Date=$("#Date").val();
	var intRegex = /[0-9 -()+]+$/;
	if (!Odometer.match(intRegex) ) {
		alert('Please enter odometer in digits');
		$("#Odometer").focus();
		return false;
	}	
	if(Date==""){
		alert('Please enter the Date');	
		$("#Date").focus();
		return false;
	}
}

function popitupEquip(url) {
	newwindow=window.open(url,'Map','height=600,width=600');
	if (window.focus) {newwindow.focus()}
	return false;
}

function exportTaxSummary() {
	var DateFrom=document.getElementById("DateFrom").value;
	var DateTo=document.getElementById("DateTo").value;
	var empid=document.getElementById("empid").value;
	var CompanyID=document.getElementById("CompanyID").value;
	if(DateFrom=="") {
		alert('please enter a date for datefrom field');
		return false;
	}
	if(DateTo==""){
		alert('please enter a date for dateto field');
		return false;
	}
	var path = urlComponentPath+"loadgateway.cfc?method=generateIFTALoads&DateFrom="+DateFrom+"&DateTo="+DateTo+"&empid="+empid+"&CompanyID="+CompanyID;
	$.ajax({
    	type: "get",
        url: path,
        success: function(response){
        	var arrLoads = jQuery.parseJSON(response).DATA;
        	if(arrLoads.length == 0){
        		$('.overlay').hide();
	        	$('#loader').hide();
	        	$('#loadingmsg').hide();
	        	document.getElementById('exportLink').className = 'exportbutton';
				$("#disptaxSummary").submit();
			}
			else{
				$.each( arrLoads, function( key, value ) {
					var path = urlComponentPath+"loadgateway.cfc?method=generateIFTAdata&DateFrom="+DateFrom+"&DateTo="+DateTo+"&empid="+empid+"&loadNumber="+value+"&CompanyID="+CompanyID;
				    $.ajax({
				    	type: "get",
				        url: path,
				        //async : false,
				        success: function(data){
				        	$('#loadingmsg').text('Generating Data For Load#'+value+'.Please Wait.');
				        	if(parseInt(key)+1 == parseInt(arrLoads.length)){
				        		$('.overlay').hide();
					        	$('#loader').hide();
					        	$('#loadingmsg').hide();
					        	document.getElementById('exportLink').className = 'exportbutton';
					        	$("#disptaxSummary").submit();
				        	}
				        	
				        },
				        beforeSend: function() {
					    },
				  	});

				})
			}
        },
        beforeSend: function() {
	        $('.overlay').show()
	        $('#loader').show();
	        $('#loadingmsg').show();
	        document.getElementById('exportLink').className = 'busyButton';
	    },
  	});
}

function showHideIcons(ele,stopId) {
	var checkClass=$(ele).hasClass( "fa-plus-circle" );
	if (checkClass){
		$(ele).removeClass("fa-plus-circle");
		$(ele).addClass("fa-minus-circle");
		$(ele).parent().parent().find(".InfoShipping"+stopId).slideDown();
	} else {
		$(ele).removeClass("fa-minus-circle");
		$(ele).addClass("fa-plus-circle");
		$(ele).parent().parent().find(".InfoShipping"+stopId).slideUp();
		if(stopId ==1) {
			var stopId="";
		}
		$("#span_Shipper"+stopId).hide();
	}
}

function toggleAddress(ele) {
	var checkClass=$(ele).hasClass( "fa-plus-circle" );
	if (checkClass){
		$(ele).removeClass("fa-plus-circle");
		$(ele).addClass("fa-minus-circle");
		$('.AddressDiv').slideDown();
	} else {
		$(ele).removeClass("fa-minus-circle");
		$(ele).addClass("fa-plus-circle");
		$('.AddressDiv').slideUp();
	}
}

function showHideStopInfo(ele,stopId,type) {
	var checkClass=$(ele).hasClass( "fa-plus-circle" );
	if (checkClass){
		$(ele).removeClass("fa-plus-circle");
		$(ele).addClass("fa-minus-circle");
		$("#Info"+type+"_"+stopId).slideDown();
	} else {
		$(ele).removeClass("fa-minus-circle");
		$(ele).addClass("fa-plus-circle");
		$("#Info"+type+"_"+stopId).slideUp();
	}
}

function showHideInterModalImport(ele,stopId) {
	var checkClass=$(ele).hasClass( "fa-plus-circle" );
	if (checkClass){
		$(ele).removeClass("fa-plus-circle");
		$(ele).addClass("fa-minus-circle");

		$(".InterModalImport"+stopId).slideDown();
	} else {
		$(ele).removeClass("fa-minus-circle");
		$(ele).addClass("fa-plus-circle");
		$(".InterModalImport"+stopId).slideUp();
	}
}

function showHideInterModalExport(ele,stopId) {
	var checkClass=$(ele).hasClass( "fa-plus-circle" );
	if (checkClass){
		$(ele).removeClass("fa-plus-circle");
		$(ele).addClass("fa-minus-circle");

		$(".InterModalExport"+stopId).slideDown();
	} else {
		$(ele).removeClass("fa-minus-circle");
		$(ele).addClass("fa-plus-circle");
		$(".InterModalExport"+stopId).slideUp();
	}
}

function showHideCarrierBlock(ele,stopId) {
	var checkClass=$(ele).hasClass( "fa-plus-circle" );
	if (checkClass){
		$(ele).removeClass("fa-plus-circle");
		$(ele).addClass("fa-minus-circle");
		$('.carrierBlock'+stopId).slideDown();
	}
	else{
		$(ele).removeClass("fa-minus-circle");
		$(ele).addClass("fa-plus-circle");
		$('.carrierBlock'+stopId).slideUp();
	}
}

function showHideConsineeIcons(ele,stopId) {
	var checkClass=$(ele).hasClass( "fa-plus-circle" );
	if (checkClass){
		$(ele).removeClass("fa-plus-circle");
		$(ele).addClass("fa-minus-circle");
		$(ele).parent().parent().find(".InfoConsinee"+stopId).slideDown();
	} else {
		$(ele).removeClass("fa-minus-circle");
		$(ele).addClass("fa-plus-circle");
		$(ele).parent().parent().find(".InfoConsinee"+stopId).slideUp();
		if(stopId==1){
			var stopId="";
		}
		$("#span_Consignee"+stopId).hide();
	}
}

/*checkBox select unselect  on allload starts*/
function checkboxOperation(ele) {
	if ($(ele).prop('checked')==true){ 
		$(".checkboxSelect:not(:disabled)").prop("checked", true);
    }else{
		$(".checkboxSelect").prop("checked", false);
	} 
}

function UpdateLoadsCheck(){
	return ValidationCheckUpdateLoads();
}

function fnOpenNormalDialog() {
    $("#dialog-confirm").html("Update these loads now?");
    // Define the Dialog and its properties.
    $("#dialog-confirm").dialog({
        resizable: false,
        modal: true,
        title: "Confirm Box",
        height: 160,
        width: 350,
        buttons: {
            "Yes": function () {
                $(this).dialog('close');
                callback(true);
            },
                "No": function () {
                $(this).dialog('close');
            }
        }
    });
}

function fnOpenNormalDialogProcess() {
    $("#Information").html("<img width='325px' style='margin-top: 13px;' src='images/loadingbar.gif'>");
    // Define the Dialog and its properties.
    $("#Information").dialog({
        resizable: false,
        modal: true,
        title: "Information",
        height: 160,
        width: 350
    }); 
}
function responseUploadProcess(numbers,loadboard,datloadboard,loadstatus1,itsloadboard,LoadBoardDeletionOccuredStatus,loadboarditsDeleted,datLoadbordDeleted,Loadbord123Deleted,posteveryWhere,posteveryWhereDeleted,directFreightLoadBoard,directFreightLoadBoardDeleted,postits,posteverywhere,post123loadboard,postdatloadboard,postdirectfreight) {
	if(numbers !=""){
		$("#responseUploadProcess").html("<h3 style='color:#31a047;'>ShipDate Updated Loads</h3>");
		$("#responseUploadProcess").append("<div style='word-wrap:break-word;'>"+numbers+"</div>");
	}
	if(loadstatus1.length != 0){
		$("#responseUploadProcess").append("<h3 style='color:#31a047;'>LoadStatus  Updated  Loads</h3>");	
		$("#responseUploadProcess").append("<div style='word-wrap:break-word;'>"+loadstatus1+"</div>");
	}
	if(LoadBoardDeletionOccuredStatus ==true){

		if(postdatloadboard == 1){
			$("#responseUploadProcess").append("<h3 style='color:#31a047;'>ShipDate Updated DatLoadBoard Loads</h3>");	
			if(datloadboard.length == 0 && datLoadbordDeleted.length == 0){
				$("#responseUploadProcess").append("<div style='word-wrap:break-word;'>DatLoadBoard Says:None</div>");
			}else if(datloadboard.length != 0){
				$("#responseUploadProcess").append("<div style='word-wrap:break-word;'>POST:"+datloadboard+"</div>");
			}else if(datLoadbordDeleted.length != 0){
				$("#responseUploadProcess").append("<div style='word-wrap:break-word;'>UNPOST:"+datLoadbordDeleted+"</div>");
			}
		}

		if(postdirectfreight == 1){
			$("#responseUploadProcess").append("<h3 style='color:#31a047;'>ShipDate Updated DirectFrieght Loads</h3>");	
			if(directFreightLoadBoard.length == 0 && directFreightLoadBoardDeleted.length == 0){
				$("#responseUploadProcess").append("<div style='word-wrap:break-word;'>DirectFrieght Says:None</div>");
			}else if(directFreightLoadBoard.length != 0){
				$("#responseUploadProcess").append("<div style='word-wrap:break-word;'>POST:"+directFreightLoadBoard+"</div>");
			}else if(directFreightLoadBoardDeleted.length != 0){
				$("#responseUploadProcess").append("<div style='word-wrap:break-word;'>UNPOST:"+directFreightLoadBoardDeleted+"</div>");
			}
		}

		if(post123loadboard == 1){
			$("#responseUploadProcess").append("<h3 style='color:#31a047;'>ShipDate Updated 123LoadBoard Loads</h3>");	
			if(loadboard.length == 0 && Loadbord123Deleted.length == 0){
				$("#responseUploadProcess").append("<div style='word-wrap:break-word;'>123 LoadBoard Says:None</div>");
			}else if(loadboard.length != 0){
				$("#responseUploadProcess").append("<div style='word-wrap:break-word;'>POST:"+loadboard+"</div>");
			}else if(Loadbord123Deleted.length != 0){
				$("#responseUploadProcess").append("<div style='word-wrap:break-word;'>UNPOST:"+Loadbord123Deleted+"</div>");
			}
		}

		if(postits == 1){
			$("#responseUploadProcess").append("<h3 style='color:#31a047;'>ShipDate Updated ITS LoadBoard Loads</h3>");	
			if(itsloadboard.length == 0 && loadboarditsDeleted.length == 0){
				$("#responseUploadProcess").append("<div style='word-wrap:break-word;'>ITS LoadBoard Says:None</div>");
			}else if(itsloadboard.length != 0){
				$("#responseUploadProcess").append("<div style='word-wrap:break-word;'>POST:"+itsloadboard+"</div>");
			}else if(loadboarditsDeleted.length != 0){
				$("#responseUploadProcess").append("<div style='word-wrap:break-word;'>UNPOST:"+loadboarditsDeleted+"</div>");
			}
		}

		if(posteverywhere == 1){
			$("#responseUploadProcess").append("<h3 style='color:#31a047;'>ShipDate Updated LoadBoard Network Loads</h3>");	
			if(posteveryWhere.length == 0 && posteveryWhereDeleted.length==0){
				$("#responseUploadProcess").append("<div style='word-wrap:break-word;'>LoadBoard Network Says:None</div>");
			}else if(posteveryWhere.length != 0){
				$("#responseUploadProcess").append("<div style='word-wrap:break-word;'>POST:"+posteveryWhere+"</div>");
			}else if(posteveryWhereDeleted.length != 0){
				$("#responseUploadProcess").append("<div style='word-wrap:break-word;'>UNPOST:"+posteveryWhereDeleted+"</div>");
			}
		}
	}else{
		if(postdatloadboard == 1){
			$("#responseUploadProcess").append("<h3 style='color:#31a047;'>DatLoadBoard deletion occured loads due to system setup statusTrigger</h3>");	
			if(datLoadbordDeleted.length == 0){
				$("#responseUploadProcess").append("<div style='word-wrap:break-word;'>DatLoadBoard Says:None</div>");
			}else{
				$("#responseUploadProcess").append("<div style='word-wrap:break-word;'>"+datLoadbordDeleted+"</div>");
			}
		}
		
		if(post123loadboard == 1){
			$("#responseUploadProcess").append("<h3 style='color:#31a047;'>123LoadBoard deletion occured loads due to system setup statusTrigger</h3>");	
			if(Loadbord123Deleted.length == 0){
				$("#responseUploadProcess").append("<div style='word-wrap:break-word;'>123 LoadBoard Says:None</div>");
			}else{
				$("#responseUploadProcess").append("<div style='word-wrap:break-word;'>"+Loadbord123Deleted+"</div>");
			}
		}

		if(postits == 1){
			$("#responseUploadProcess").append("<h3 style='color:#31a047;'>ITS LoadBoard deletion occured loads due to system setup statusTrigger</h3>");	
			if(loadboarditsDeleted.length == 0){
				$("#responseUploadProcess").append("<div style='word-wrap:break-word;'>ITS LoadBoard Says:None</div>");
			}else{
				$("#responseUploadProcess").append("<div style='word-wrap:break-word;'>"+loadboarditsDeleted+"</div>");
			}
		}

		if(posteverywhere == 1){
			$("#responseUploadProcess").append("<h3 style='color:#31a047;'>Posteverywhere LoadBoard deletion occured loads due to system setup statusTrigger</h3>");	
			if(posteveryWhereDeleted.length == 0){
				$("#responseUploadProcess").append("<div style='word-wrap:break-word;'>LoadBoard Network Says:None</div>");
			}else{
				$("#responseUploadProcess").append("<div style='word-wrap:break-word;'>"+posteveryWhereDeleted+"</div>");
			}
		}

		if(postdirectfreight == 1){
			$("#responseUploadProcess").append("<h3 style='color:#31a047;'>DirectFrieght LoadBoard deletion occured loads due to system setup statusTrigger</h3>");	
			if(directFreightLoadBoardDeleted.length == 0){
				$("#responseUploadProcess").append("<div style='word-wrap:break-word;'>DirectFrieght LoadBoard Says:None</div>");
			}else{
				$("#responseUploadProcess").append("<div style='word-wrap:break-word;'>"+directFreightLoadBoardDeleted+"</div>");
			}	
		}
	}	
    // Define the Dialog and its properties.
    $("#responseUploadProcess").dialog({
        resizable: false,
        modal: true,
        title: "Updated Information",
        minHeight: 'auto',
        width: 500
    });
}

function ValidationCheckUpdateLoads(){
	var shipperDateToUpdate=$('#rollOverShipDate').val();
	var statustext=$('#loadStatusUpdate').val();
	fnOpenNormalDialog(); 
}

function recursiveAjaxPostLoad(loadNumbers,totalLoads,indx,newData,loadIds,statusIDs){

	var shipperDateToUpdate=$('#rollOverShipDate').val();
	var multipleShipperDates = $('#shipperPickupDateMultiple').val();
	var statustext=$('#loadStatusUpdate').val();
	var text = $.trim($('#loadStatusUpdate option:selected').data('statustext'))
	var dsn=$('#dsn').val();
	var CompanyID=$('#CompanyID').val();
	var loadstatus=$('#loadStatusUpdate').val();
	var urlToken=$('#urlToken').val();
	if($('#weekendRollOvercheck').prop('checked')==true){
		var weekendRollOvercheck=1;
	}else{
		var weekendRollOvercheck=0;
	}
	
	if($('#postToIts').prop('checked')==true){
		var postits=1;
	}else{
		var postits=0;
	}
	if($('#posteverywhere').prop('checked')==true){
		var posteverywhere=1;
	}else{
		var posteverywhere=0;
	}
	if($('#post123loadboard').prop('checked')==true){
		var post123loadboard=1;
	}else{
		var post123loadboard=0;
	}
	if($('#postdatloadboard').prop('checked')==true){
		var postdatloadboard=1;
	}else{
		var postdatloadboard=0;
	}
	if($('#postCarrierRatetoTranscore').prop('checked')==true){
		var postCarrierRatetoTranscore=1;
	}else{
		var postCarrierRatetoTranscore=0;
	}
	if($('#postdirectfreight').prop('checked')==true){
		var postdirectfreight=1;
	}else{
		var postdirectfreight=0;
	}
	var path = urlComponentPath+"ShipDateUpdate.cfc?method=updateshipdateAll";
	var setSession = "";
	var empId=$('#Id').val();


	if(indx<totalLoads){
		var value = loadNumbers[indx];
		var loadID = loadIds[indx];
		var statusTypeID = statusIDs[indx];
		var arrLoadNo = [];
		arrLoadNo.push(value);
		var loadNumber = JSON.stringify(arrLoadNo);
		$.ajax({
			type: "post",
			url: path,		
			dataType: "json",
			//async: false,
			data: {
			  	CompanyID:CompanyID,loadNumbers:loadNumber,dsn:dsn,shipperDateToUpdate:shipperDateToUpdate,multipleShipperDates:multipleShipperDates,empId:empId,statustext:statustext,text:text,postdirectfreight:postdirectfreight,postits:postits,posteverywhere:posteverywhere,post123loadboard:post123loadboard,postdatloadboard:postdatloadboard,postCarrierRatetoTranscore:postCarrierRatetoTranscore,weekendRollOvercheck:weekendRollOvercheck,clientTime:new Date().toLocaleString(),statusReadableText:$("#loadStatusUpdate option:selected").text()
			},
			success: function(data){

				if (data.STATUS==true){
					if(indx == 0){
						newData = data;
					}
					else{
						if($.trim(data.UPDATEDSHIPDATE).length){
							newData.UPDATEDSHIPDATE = newData.UPDATEDSHIPDATE + ',' + data.UPDATEDSHIPDATE
						}
						if($.trim(data.LOADBORD123).length){
							newData.LOADBORD123 = newData.LOADBORD123 + ',' + data.LOADBORD123
						}
						if($.trim(data.DATLOADBORD).length){
							newData.DATLOADBORD = newData.DATLOADBORD + ',' + data.DATLOADBORD
						}
						if($.trim(data.LOADSTATUS).length){
							newData.LOADSTATUS = newData.LOADSTATUS + ',' + data.LOADSTATUS
						}
						if($.trim(data.LOADBOARDITS).length){
							newData.LOADBOARDITS = newData.LOADBOARDITS + ',' + data.LOADBOARDITS
						}
						if($.trim(data.LOADBOARDDELETIONOCCUREDSTATUS).length && newData.LOADBOARDDELETIONOCCUREDSTATUS != true){
							newData.LOADBOARDDELETIONOCCUREDSTATUS = newData.LOADBOARDDELETIONOCCUREDSTATUS + ',' + data.LOADBOARDDELETIONOCCUREDSTATUS
						}
						if($.trim(data.LOADBOARDITSDELETED).length){
							newData.LOADBOARDITSDELETED = newData.LOADBOARDITSDELETED + ',' + data.LOADBOARDITSDELETED
						}
						if($.trim(data.DATLOADBORDDELETED).length){
							newData.DATLOADBORDDELETED = newData.DATLOADBORDDELETED + ',' + data.DATLOADBORDDELETED
						}
						if($.trim(data.LOADBORD123DELETED).length){
							newData.LOADBORD123DELETED = newData.LOADBORD123DELETED + ',' + data.LOADBORD123DELETED
						}
						if($.trim(data.POSTEVERYWHERE).length){
							newData.POSTEVERYWHERE = newData.POSTEVERYWHERE + ',' + data.POSTEVERYWHERE
						}
						if($.trim(data.POSTEVERYWHEREDELETED).length){
							newData.POSTEVERYWHEREDELETED = newData.POSTEVERYWHEREDELETED + ',' + data.POSTEVERYWHEREDELETED
						}
						if($.trim(data.DIRECTFREIGHTLOADBOARD).length){
							newData.DIRECTFREIGHTLOADBOARD = newData.DIRECTFREIGHTLOADBOARD + ',' + data.DIRECTFREIGHTLOADBOARD
						}
						if($.trim(data.DIRECTFREIGHTLOADBOARDDELETED).length){
							newData.DIRECTFREIGHTLOADBOARDDELETED = newData.DIRECTFREIGHTLOADBOARDDELETED + ',' + data.DIRECTFREIGHTLOADBOARDDELETED
						}
					}
					if(statusTypeID!=loadstatus){
						$.ajax({
							type    : 'POST',
		                	url     : "ajax.cfm?event=ajxSendLoadEmailUpdate&LoadID="+loadID+"&NewStatus="+loadstatus+"&"+urlToken,
		                	data    : {},
		                	success :function(data){
		                	}
						})
					}
					recursiveAjaxPostLoad(loadNumbers,totalLoads,indx+1,newData,loadIds,statusIDs);
				}
				else{
					$('.overlay').hide();
					$('#loadernew').hide();
					$("#responseUploadProcess").append("<div style='word-wrap:break-word;'>Something went wrong.Please try again later.</div>");
					$("#responseUploadProcess").dialog({
				        resizable: false,
				        modal: true,
				        title: "Updated Information",
				        height: 100,
				        width: 500
					});
				}
			},
			beforeSend:function(){
				$('.overlay').show();
				$('#loadernew').show();
				var ind = indx+1
				$('#loadingmsgnew').html('Posting Load '+value+', '+ind+' of '+totalLoads);
			}
		});
	}
	else{
		$('.overlay').hide();
		$('#loadernew').hide();

		if(postits==1 || posteverywhere==1 || post123loadboard==1 || postdatloadboard==1 || postdirectfreight==1){
			
			$("#responseUploadProcess").dialog({
				close : function( event, ui ){
					location.href = location.href;
				}
			});
			responseUploadProcess(newData.UPDATEDSHIPDATE,newData.LOADBORD123,newData.DATLOADBORD,newData.LOADSTATUS,newData.LOADBOARDITS,newData.LOADBOARDDELETIONOCCUREDSTATUS,newData.LOADBOARDITSDELETED,newData.DATLOADBORDDELETED,newData.LOADBORD123DELETED,newData.POSTEVERYWHERE,newData.POSTEVERYWHEREDELETED,newData.DIRECTFREIGHTLOADBOARD,newData.DIRECTFREIGHTLOADBOARDDELETED,postits,posteverywhere,post123loadboard,postdatloadboard,postdirectfreight);
		}
		else{
			location.href = location.href;
		}
	}
}

function callback(value) {
    if (value) {
		var matches = [];
		var matchesID = [];
		var statusIDs = [];
		$(".checkboxSelect:checked").each(function() {
			if(this.value != 'on'){
				matches.push(this.value);
				matchesID.push($(this).attr('data-loadid'));
				statusIDs.push($(this).attr('data-status'));
			}
		});
	
		if(matches !="") {
			var indx = 0;
			var totalLoads = matches.length;
			var newData = {};
			recursiveAjaxPostLoad(matches,totalLoads,indx,newData,matchesID,statusIDs);
		}	
	}	
} 

$(document).ready(function() {
	$(".checkboxSelect").click(function() {		
	  	var ischecked = $('.checkboxSelect:checked').length;
	  	var LoadNm = $(this).val();
	  	var bitAlreadySelectedNormalLoad = 0;
	  	var bitAlreadySelectedDisabledLoad = 0;
	  	var selectedStatus = '';

	  	$('.checkboxSelect:checked').each(function () {
	  		if($(this).val() !== LoadNm){
	  			if($(this).attr('data-code') != 'disabled'){
	  				bitAlreadySelectedNormalLoad = 1;
	  			}
	  		}
  		})

	  	$('.checkboxSelect:checked').each(function () {
	  		if($(this).val() !== LoadNm){
	  			if($(this).attr('data-code') == 'disabled'){
	  				bitAlreadySelectedDisabledLoad = 1;
	  				selectedStatus = $(this).attr('data-status');
	  			}
	  		}
  		})


	  	if($(this).attr('data-code') == 'disabled'){
	  		if(bitAlreadySelectedNormalLoad == 1){
	  			alert("Changing this Load Status here is not supported because it's 'Force Next Load Status' option is turned on and you already selected load(s) with 'Force Next Load Status' option is off.");
				$(this).attr('checked',false);
				return false;
	  		}
	  		if(bitAlreadySelectedDisabledLoad == 1 && selectedStatus != $(this).attr('data-status')){
	  			alert("Multiple status not supported because you already selected load(s) with 'Force Next Load Status' option is turned on.");
				$(this).attr('checked',false);
				return false;
	  		}
		}

		if($.type($(this).attr('data-code')) != 'undefined' && $(this).attr('data-code') != 'disabled'){
	  		if(bitAlreadySelectedDisabledLoad == 1){
	  			alert("Changing this Load Status here is not supported because you already selected load(s) with 'Force Next Load Status' option is turned on.");
				$(this).attr('checked',false);
				return false;
	  		}
		}



	  	if(ischecked !=0){
	  		$('.mystatusbox').css("display","none");
		  	$('.hideDate').css("display","block");
		  	$('.hideStatus').css("display","block");
		  	
		  	loadboardsstatus();

		  	$('#loadStatusUpdate option').hide();
		  	selectedStatus = $(this).attr('data-status');
		  	var showNxtStatus = 0;


		  	if($(this).attr('data-code') == 'disabled'){
		  		$('#loadStatusUpdate > option').each(function () {
			  			if($(this).val()==selectedStatus){
			  				$(this).show();
			  				showNxtStatus = 1;
			  			}
			  			else if(showNxtStatus==1){
			  				$(this).show();
			  				showNxtStatus = 0;
			  			}
		  			}
		  		);
		  	}
		  	else{
		  		$('#loadStatusUpdate option').show();
		  		$('#loadStatusUpdate').prop('selectedIndex',0);
		  	}
		  	

	  	} else {
		  	$('.hideDate').css("display","none");
		  	$('.hideStatus').css("display","none");
		  	$('.mystatusbox').css("display","block");
	  	}
	});

	$(".chk-my-status").click(function() {		
	  	var ischecked = $(this).prop("checked") ;
  		if(ischecked){
  			var action = 'insert';
  		}
  		else{
  			var action = 'delete';
  		}
  		var dsn = $('#dsn').val();
	  	var urlToken = $('#urlToken').val();
	  	var urlEvent = $('#urlEvent').val();
	  	var path = "ajax.cfm?event=updateUserAssignedLoadStatus&"+urlToken;
		$.ajax({
			  type: "post",
			  url: path,		
			  dataType: "json",
			  async: false,
			  data: {
				  	dsn:dsn,urlEvent:urlEvent,action:action,checkedStatus:$(this).val()
				},
			  success: function(data){
			  	location.reload();
			  }
		});
	});

	if (document.getElementById(responseUploadProcess)) {
		$('div#responseUploadProcess').on('dialogclose', function(event) {
			window.location.href=window.location.href;
		});
	}
	
	if ( $.isFunction($.datepicker) ) {
	   $( "[type='datefield']" ).datepicker({
	     dateFormat: "mm/dd/yy",
	     showOn: "button",
	     buttonImage: "images/DateChooser.png",
	     buttonImageOnly: true
	   });
	}


	$(".disAllowHash").keypress(function(e){
		if (e.which == 35) { 
	      return false;
	    }
	})

	$('.fa-eye').click(function() {
    	var password = $(this).prev("input");
    	var type = password.attr('type') === 'password' ? 'text' : 'password';
		password.attr('type', type);
    	this.classList.toggle('fa-eye-slash');
    })
});
$(document).ready(function(){
	if($('#BillFromCompanies').is(':checked')){
		$('.hidecheckBoxGroup').show();
	}
})

function checkActivateBill(){
	if($('#BillFromCompanies').is(':checked')){
		$('#ApplyBillFromCompanyToCarrierReport').prop('checked', true);
		$('.hidecheckBoxGroup').show();
	}else{
		$('#ApplyBillFromCompanyToCarrierReport').prop('checked', false);
		$('.hidecheckBoxGroup').hide();
	}
}
function showDispSplitAmt() {
	var ckd = $('#incAllDispatchers').is(":checked");
	$('.hidecheckBoxSplitAmt').show();
	if(!ckd){
		$('#dispatcherSplitAmt').prop("disabled",true).prop("checked",false);
	}
	else{
		$('#dispatcherSplitAmt').prop("disabled",false);
	}
}

function showCustomerCheckBox() {
	$('.hidecheckBox').css("display","block");
}

function hideCustomerCheckBox() {
	$('.hidecheckBox,.hidecheckBoxSplitAmt').css("display","none");
	$('#customerCheck').prop('checked', true);
	$('#dispatcherSplitAmt').prop('checked', false);
}

function showcheckBoxGroup() {
	$('.hidecheckBoxGroup').css("display","block");
	$('#customerCheckGroup').prop('checked', true);
	$('.hideAllSalesRep').hide();
	$('.hideAllDispatcher').show();
}

function shwIncSalesrep(){
	$('.hideAllSalesRep').show();
	$('.hideAllDispatcher').hide();
}

function hidecheckBoxGroup() {
	$('.hidecheckBoxGroup').css("display","none");
	$('#customerCheckGroup').prop('checked', true);
	$('.hideAllSalesRep').hide();
	$('.hideAllDispatcher').show();
}

function loadboardsstatus() {
	var loadstatus=$('#loadStatusUpdate').val();
	if($("#LoadNumberAutoIncrement").val().trim() == 1){
		var loadStatusText  = $('#loadStatusUpdate option:selected').data('statustext');
		var lstStatusText = "";	
		
		$('input[name=rolloverShipDateCheckSub]:checked').each(function(){
				if(lstStatusText == ""){lstStatusText = ($("#StatusText"+this.value).val());}
				else{lstStatusText = lstStatusText +","+($("#StatusText"+this.value).val());}				
		});	
		
		if (loadStatusText != "Select Status" && (loadStatusText == "0. QUOTE" || loadStatusText == "1. ACTIVE" ||  loadStatusText == ". TEMPLATE") &&  (lstStatusText.match("2. BOOKED|3. DISPATCHED|4. LOADED|4.1 CALL CHECK|5. DELIVERED|5.1 CALL CHECK|6. POD|7. INVOICE|7.1 PAID|7.2 CARRIER PAID|8. COMPLETED|9. Cancelled|9.5 do not use")) ){
			alert("You are not able to change status  to "+loadStatusText.trim() +".");
			$('#loadStatusUpdate').val('');
		}	
		
	}
}

function stopInterChanging(action,loadid,dsn,stopNumber) {
	var InputChanged=$("#inputChanged").val();
	var CompanyID=$("#CompanyID").val();
	if(InputChanged==1){
		$("#dialog-confirm").html("Are you sure want to save the information you edited now, If Yes please click Yes otherwise No?");
		// Define the Dialog and its properties.
		$("#dialog-confirm").dialog({
			resizable: false,
			modal: true,
			title: "Confirm Box",
			height: 160,
			width: 350,
			buttons: {
				"Yes": function () {
					$(this).dialog('close');
					$("#saveLoad").click();
				},
					"No": function () {
					$(this).dialog('close');
					var path=urlComponentPath+"loadgateway.cfc?method=stopInterChanging";
					$.ajax({
						  type: "post",
						  url: path,		
						  dataType: "json",
						  async: false,
						  data: {
							  action:action,dsn:dsn,loadid:loadid,stopNumber:stopNumber,CompanyID:CompanyID
							},
						  success: function(data){
							  if (data==1){
								window.location.href=window.location.href;
							  }	
							 else{
								 alert("Duplicate Load number("+data+")");
								 document.getElementById("loadManualNoExists").value=1;
								 document.getElementById("loadManualNoIdentExists").value=1;
							  }
						  }
					});
				}
			}
		});
	} else if (InputChanged==0) {
		var path=urlComponentPath+"loadgateway.cfc?method=stopInterChanging";
		$.ajax({
			type: "post",
			url: path,		
			dataType: "json",
			async: false,
			data: {
			  	action:action,dsn:dsn,loadid:loadid,stopNumber:stopNumber,CompanyID:CompanyID
			},
			success: function(data){
				if (data==1){
					window.location.href=window.location.href;
				}
				 else{
					 alert("Duplicate Load number("+data+")");
					 document.getElementById("loadManualNoExists").value=1;
					 document.getElementById("loadManualNoIdentExists").value=1;
				  }
			}
		});
	}
}

function getConfirmation() {
  	if(confirm("Load Manager uses the FMCSA Data API to update carrier insurance information but Load Manager is not endorsed or certified by the FMSCA. Are you ready to update this Carriers data?")){
		var dotnumber=$("#DOTNumber").val();
		var MCNumber=$("#MCNumber").val();
		var editid=$("#editid").val();
		var stoken=$("#stoken").val();
		if(dotnumber !="") {
			window.location='index.cfm?event=addcarrier&DOTNumber='+dotnumber+'&carrierid='+editid+'&apidetails=1&'+stoken+'';  
		} else if(MCNumber !=""){
			window.location='index.cfm?event=addcarrier&mcno='+MCNumber+'&carrierid='+editid+'&apidetails=1&'+stoken+''; 
		} else {
			alert('Please enter DotNumber or mc number');
			return false;
		}
  	}
}

function getsaferwatchConfirmation() {
  	if(confirm("Are you ready to update this Carriers data using SaferWatch API ?")){
		var dotnumber=$("#DOTNumber").val();
		var MCNumber=$("#MCNumber").val();
		var editid=$("#editid").val();
		var stoken=$("#stoken").val();
		var CompanyID=$("#CompanyID").val();
		 if(MCNumber !=""){
		 	updateCarrierSaferWatch(editid,CompanyID);
		var CompanyID=$("#CompanyID").val();
			window.location='index.cfm?event=addcarrier&CompanyID='+CompanyID+'&mcno='+MCNumber+'&carrierid='+editid+'&saferWatchUpdate=1&'+stoken+''; 
		}else if(dotnumber !="") {
			updateCarrierSaferWatch(editid,CompanyID);
			window.location='index.cfm?event=addcarrier&CompanyID='+CompanyID+'&DOTNumber='+dotnumber+'&carrierid='+editid+'&saferWatchUpdate=1&'+stoken+'';  
		} 
		else {
			alert('Please enter DotNumber or mc number');
			return false;
		}
  	}
}


function updateCarrierSaferWatch(carrierid,companyid){
	var dsn =$("#appDsn").val();
	var path=urlComponentPath+"carriergateway.cfc?method=updateCarrierSaferWatch";
	$.ajax({
		type: "post",
		url: path,		
		dataType: "json",
		async: false,
		data: {
		  	dsn:dsn,carrierid:carrierid,companyid:companyid
		},
		success: function(data){
		}
	});
}


function validateEmail(frmfld,strFld) {
    var x = $(frmfld).val();
    var atpos = x.indexOf("@");
    var dotpos = x.lastIndexOf(".");
    if (x !="" && (atpos<1 || dotpos<atpos+2 || dotpos+2>=x.length)) {
        alert("Invalid "+strFld+" !");
        $(frmfld).focus();
    }
}

/*function to remove values in inuseby field*/
function removeEditAccess(loadid,empID){

	if(confirm('Warning:  You are about to unlock this load any changes will CAUSE DATA LOSS.')){
		if(confirm('Warning:  This action is not recommended, please confirm to unlock load.')){
			var dsn =$("#appDsn").val();
			var path=urlComponentPath+"loadgateway.cfc?method=removeUserAccessOnLoad";
			$.ajax({
				type: "post",
				url: path,		
				dataType: "json",
				async: false,
				data: {
				  	dsn:dsn,loadid:loadid,unlockedEmpID:empID
				},
				success: function(data){
					alert('The load editing lock for load# '+data.LOADNUMBER+' has been removed');
					location.href = location.href;
				}
			});
		}
		else{
			return false;
		}
	}
	else{
		return false;
	}
}

function shownotes(row){
	$(".DivDispatchNotes_"+row).toggle();
}	


function checkforNumeric(ele){
	if(isNaN(ele.value.trim() ) || isNaN(parseInt(ele.value)) || ele.value < 0){
		ele.value = 0;
	}else if(parseInt(ele.value) > 10){
		ele.value = 10;
	}
	else{
		ele.value = parseInt(ele.value);
	}
	
}


function checkforNumericForTimeout(ele){
	if(isNaN(ele.value.trim() ) || isNaN(parseInt(ele.value)) || ele.value < 0){
		ele.value = 0;
	}else if(parseInt(ele.value) > 60){
		ele.value = 60;
	}
	else{
		ele.value = parseInt(ele.value);
	}
	
}

/* Include Carrier Rate Change */

function checkCarrierRate(){
	if($('#postCarrierRatetoITS').prop('checked')){
		if(!$('#posttoITS').prop('checked')){
			$('#postCarrierRatetoITS').prop('checked',false);
		}
	}
	if($('#postCarrierRatetoloadboard').prop('checked')){
		if(!$('#posttoloadboard').prop('checked')){
			$('#postCarrierRatetoloadboard').prop('checked',false);
		}
	}
	if($('#postCarrierRatetoTranscore').prop('checked')){
		if(!$('#posttoTranscore').prop('checked')){
			$('#postCarrierRatetoTranscore').prop('checked',false);
		}
	}
	if($('#postCarrierRateto123LoadBoard').prop('checked')){
		if(!$('#PostTo123LoadBoard').prop('checked')){
			$('#postCarrierRateto123LoadBoard').prop('checked',false);
		}
	}
}

function CheckLoadNumberIncrease(){
	if(! $('#LoadNumberAutoIncrement').is(":checked")){
		$('.StartingLoad').hide();
	}else{
		$('.StartingLoad').show();
	}
}

function checkForLoadNumber(ele,dsn){
	if(isNaN(ele.value.trim()) || ele.value.trim() == "" || ele.value.trim() < 0){
		alert("Please enter a valid Numeric value.");
		ele.value = '';
	}else{
			$.ajax({
				type: "get",
				url: urlComponentPath+"loadgateway.cfc?method=checkForDuplicateLoadNumber",			  			
				data: {
								LoadNumber: ele.value.trim(),dsn:dsn
						},
			success: function(data){
							var bitDuplicate = jQuery.parseJSON( data );						
							if(bitDuplicate ==1){
								alert("The New Starting Load# already exists in the system.");
								ele.value = '';
							}
						}
			});
	}
}

function DisplayCarrierIncNumber(chkd){
	if(chkd){
		$(".DivIncNumber").show();
	}else{
		$(".DivIncNumber").hide();
	}
}

function uncheckCarrierRateITS(chkd){
	if(!chkd)	{
		$("#postCarrierRatetoITS").removeAttr("checked");
	}
}

function uncheckCarrierRateTranscore(chkd){
	if(!chkd)	{
		$("#postCarrierRatetoTranscore").removeAttr("checked");
	}
}

function uncheckCarrierRateEveryWhere(chkd){
	if(!chkd)	{
		$("#postCarrierRatetoloadboard").removeAttr("checked");
	}
}

function uncheckCarrierRate123LoadBoard(chkd){
	if(!chkd)	{
		$("#postCarrierRateto123LoadBoard").removeAttr("checked");
	}
}



/*function to remove values in inuseby field*/
function removeCustomerEditAccess(customerId){
	var dsn =$("#appDsn").val();
	var path=urlComponentPath+"customergateway.cfc?method=removeUserAccessOnLoad";
		$.ajax({
			type: "post",
			url: path,		
			dataType: "json",
			async: false,
			data: {
			  	dsn:dsn,customerid:customerId
			},
			success: function(data){
				console.log(data);
				alert('The customer editing lock for customer has been removed');
				window.location = 'index.cfm?event=customer';
			
			}
		});
}

/*function to remove values in inuseby field for agents*/
function removeAgentEditAccess(agentid){
	var dsn =$("#appDsn").val();
	var path=urlComponentPath+"agentgateway.cfc?method=removeUserAccessOnAgent";
		$.ajax({
			type: "post",
			url: path,		
			dataType: "json",
			async: false,
			data: {
			  	dsn:dsn,agentid:agentid
			},
			success: function(data){
				console.log(data);
				//alert('Administrator has removed load editing permission of '+data.userName+''+data.onDateTime+' for load '+data.loadnumber);
				alert('The editing lock for agent has been removed');
				window.location = 'index.cfm?event=agent&sortorder=asc&sortby=Name';
			
			}
		});
}

/*function to remove values in inuseby field*/
function removeCarrierEditAccess(carrierid){
	var dsn =$("#appDsn").val();
	var path=urlComponentPath+"carriergateway.cfc?method=removeUserAccessOnCarrier";
	$.ajax({
		type: "post",
		url: path,		
		data: {
		  	dsn:dsn,carrierid:carrierid
		},
		success: function(data){
			console.log(data);
			//alert('Administrator has removed load editing permission of '+data.userName+''+data.onDateTime+' for load '+data.loadnumber);
			alert('The editing lock for carrier has been removed');
			window.location = 'index.cfm?event=carrier&IsCarrier=1';
		
		}
	});
}

/*function to remove values in inuseby field*/
function removeDriverEditAccess(carrierid){
	var dsn =$("#appDsn").val();
	var path=urlComponentPath+"carriergateway.cfc?method=removeUserAccessOnCarrier";
		$.ajax({
			type: "post",
			url: path,		
			dataType: "json",
			async: false,
			data: {
			  	dsn:dsn,carrierid:carrierid
			},
			success: function(data){
				alert('The editing lock for driver has been removed');
				window.location = 'index.cfm?event=carrier&IsCarrier=0';
			
			}
		});
}

/*function to remove values in inuseby field for agents*/
function removeEquipmentEditAccess(equipmentid){
	
	var dsn =$("#appDsn").val();
	var path=urlComponentPath+"equipmentgateway.cfc?method=removeUserAccessOnEquipment";
		$.ajax({
			type: "post",
			url: path,		
			dataType: "json",
			async: false,
			data: {
			  	dsn:dsn,equipmentid:equipmentid
			},
			success: function(data){
				console.log(data);
				alert('The editing lock for this equipment has been removed');
				window.location = 'index.cfm?event=equipment';
			
			}
		});
}

function carrierLoadAlertEmailOnClick(loadid,URLToken) {
	var totalCarrierCharges = document.getElementById('TotalCarrierChargesHidden').value;
	var alertEmail= 'alertEmail'
	var dispatcherId = document.getElementById('Dispatcher').value;
	newwindow=window.open('index.cfm?event=loadMail&type='+alertEmail+'&loadid='+loadid+'&dispatcherId='+dispatcherId+'&totalCarrierCharges='+totalCarrierCharges+'&'+URLToken+'','Map','height=465,width=750');/*,'Map','height=400,width=750'*/
		if (window.focus) {
			newwindow.focus()
	 	}
	
}

function carrierLaneAlertEmailOnClick(CarrierID,LoadID,URLToken) {
	newwindow=window.open('index.cfm?event=loadMail&type=alertLanesEmail&loadid='+LoadID+'&CarrierID='+CarrierID+'&'+URLToken+'','Map','height=465,width=750');/*,'Map','height=400,width=750'*/
	if (window.focus) {
		newwindow.focus()
 	}
}

function sendBulkEmailOnClick(URLToken){
   newwindow=window.open('index.cfm?event=bulkEmail&'+URLToken+'','Map','height=465,width=750');
   if (window.focus) {
		newwindow.focus()
 	}
}

/*BEGIN: function to mail E-Dispatch URL for Smart Phone*/
function eDispatchSmartPhone(aDsn, loadID, userid){
	var  pathDispatchLoad= urlComponentPath+"loadgateway.cfc?method=smartPhoneDispatchLoad";
	$.ajax({
		type: "post",
		url: pathDispatchLoad,
		dataType: "json",
		async: false, 
		data: {
			dsn: aDsn,
			loadID: loadID,
			userid: userid
		},
		success: function(data){
			alert(data);
		}
	});
}
/*END: function to mail E-Dispatch URL for Smart Phone*/

/*BEGIN: 722 : Aging Report*/
function getCommissionAgingReport(URLToken, action,dsn,customerStatus,pageBreakStatus,ShowSummaryStatus,ShowProfit){
	var url = "";
	var datetype = $("input[name='datetype']:checked").val();
	var freightBrokerValues=$("#freightBroker").val();
	var appDsn = $("#appDsn").val();
	if( document.getElementById('none').checked ) {
		var groupBy='none';
	} else if( document.getElementById('salesAgent').checked ) {
		if(freightBrokerValues =='Driver'){
			var groupBy='userDefinedFieldTrucking';
		}else{
			var groupBy='salesAgent';
		}
	} else if ( document.getElementById('dispatcher').checked ) {
		var groupBy='dispatcher';
	}else if ( document.getElementById('customer').checked ) {
		var groupBy='CustName';	
	} else if ( document.getElementById('Carrier') != null && document.getElementById('Carrier').checked ) {
		var groupBy='Carrier';
	} else if ( document.getElementById('Driver') != null && document.getElementById('Driver').checked ) {
		var groupBy='Driver';
	}
	url += "groupBy="+groupBy;

	if( document.getElementById('reportType_1').checked) {
		url += "&reportType=Customer";
	}
	else{
		url += "&reportType=Carrier";
	}
	if(datetype=='Shipdate') {
		url += "&orderDateFrom="+document.getElementById('dateFrom').value;
		url += "&orderDateTo="+document.getElementById('dateTo').value;
	} 
	if(datetype=='Invoicedate') {
		url += "&billDateFrom="+document.getElementById('dateFrom').value;
		url += "&billDateTo="+document.getElementById('dateTo').value;	
	}
	url += "&deductionPercentage=0";
	var salesRepFrom='';
	var salesRepTo='';
	if(freightBrokerValues =='Driver') {
		salesRepFrom=$("#salesRepFrom").val();
		salesRepTo=$("#salesRepTo").val();
	} else {
		var s=document.getElementById("salesRepFrom");
		salesRepFrom=trim(s.options[s.selectedIndex].getAttribute("srname"));
		var t=document.getElementById("salesRepTo");
		salesRepTo=trim(t.options[t.selectedIndex].getAttribute("srname"));
	}
	var e = document.getElementById("salesRepFrom");
	url += "&salesRepFrom="+salesRepFrom;
	
	e = document.getElementById("salesRepTo");
	url += "&salesRepTo="+salesRepTo;
	
	e = document.getElementById("dispatcherFrom");
	url += "&dispatcherFrom="+trim(e.options[e.selectedIndex].getAttribute("dname"));
	
	e = document.getElementById("dispatcherTo");
	url += "&dispatcherTo="+trim(e.options[e.selectedIndex].getAttribute("dname"));
	
	e = document.getElementById("customerFrom");
	url += "&customerFrom="+trim(e.options[e.selectedIndex].getAttribute("custName"));
	
	e = document.getElementById("customerTo");
	url += "&customerTo="+trim(e.options[e.selectedIndex].getAttribute("custName"));

	//Status Loads From To
	e = document.getElementById("StatusTo");
	url += "&StatusTo="+trim(e.options[e.selectedIndex].getAttribute('data-statustext'));
	
	//Status Loads From To
	e = document.getElementById("StatusFrom");
	url += "&StatusFrom="+trim(e.options[e.selectedIndex].getAttribute('data-statustext'));
	
	//customer From To
	e = document.getElementById("customerFrom");
	url += "&customerLimitFrom="+trim(e.options[e.selectedIndex].getAttribute("custName"));
	
	//customer From To
	e = document.getElementById("customerTo");
	url += "&customerLimitTo="+trim(e.options[e.selectedIndex].getAttribute("custName"));
	
	//office From To
	e = document.getElementById("officeFrom");
	url += "&officeFrom="+trim(e.options[e.selectedIndex].text);
	
	//office From To
	e = document.getElementById("officeTo");
	url += "&officeTo="+trim(e.options[e.selectedIndex].text);
	
	//equipment From To
	e = document.getElementById("equipmentFrom");
	url += "&equipmentFrom="+trim(e.options[e.selectedIndex].text);
	
	//equipment From To
	e = document.getElementById("equipmentTo");
	url += "&equipmentTo="+trim(e.options[e.selectedIndex].text);
	
	//carrier From To
	e = document.getElementById("carrierFrom");
	url += "&carrierFrom="+trim(e.options[e.selectedIndex].getAttribute("cname"));
	
	//carrier From To
	e = document.getElementById("carrierTo");
	url += "&carrierTo="+trim(e.options[e.selectedIndex].getAttribute("cname"));
	
	//salesRep From and To Id's
	e = document.getElementById("salesRepFrom");
	url += "&salesRepFromId="+trim(e.value);
	
	e = document.getElementById("salesRepTo");
	url += "&salesRepToId="+trim(e.value);
	
	//dispatcherRep From and To Id's
	e = document.getElementById("dispatcherFrom");
	url += "&dispatcherFromId="+trim(e.value);
	
	e = document.getElementById("dispatcherTo");
	url += "&dispatcherToId="+trim(e.value);

	e = document.getElementById("freightBroker");
	url += "&freightBroker="+trim(e.value);
	
	url = url.replace(/####/g,'AAAA');
	if(action == 'view')
	{
		window.open('index.cfm?event=AgingReport&'+url+'&dsn='+dsn+'&customerStatus='+customerStatus+'&pageBreakStatus='+pageBreakStatus+'&ShowSummaryStatus='+ShowSummaryStatus+'&ShowProfit='+ShowProfit+'&datetype='+datetype+'&'+URLToken);
	}
	else if(action == 'mail')
	{
		newwindow=window.open('index.cfm?event=loadMail&type='+type+'&'+url+'&dsn='+dsn+'&customerStatus='+customerStatus+'&pageBreakStatus='+pageBreakStatus+'&ShowSummaryStatus='+ShowSummaryStatus+'&ShowProfit='+ShowProfit+'&datetype='+datetype+'&'+URLToken+'','Map','height=400,width=750');
		if (window.focus) {newwindow.focus()}
	}
}
/*END: 722 : Aging Report*/
// #837: Carrier screen add new field Dispatch Fee: Begins 
function isNumberKey(evt)
{
  var charCode = (evt.which) ? evt.which : event.keyCode
  if (charCode != 46 && charCode > 31 
	&& (charCode < 48 || charCode > 57))
	 return false;

  return true;
}
// #837: Carrier screen add new field Dispatch Fee: Ends 

function TodaysLoadTablePrevPage(){
	if(parseInt(document.getElementById('TodaysLoadPageNo').value)>1) {
		document.getElementById('TodaysLoadPageNo').value = parseInt(document.getElementById('TodaysLoadPageNo').value)-1;
		$('#dispLoadForm').submit();
	}
}

function TodaysLoadTableNextPage() {
	document.getElementById('TodaysLoadPageNo').value = parseInt(document.getElementById('TodaysLoadPageNo').value)+1;
	$('#dispLoadForm').submit();
}

function sortTodaysLoadBy(fieldName) { 
	if(document.getElementById('TodaysLoadSortBy').value == fieldName) {
		if(document.getElementById('TodaysLoadSortOrder').value == "ASC")
			document.getElementById('TodaysLoadSortOrder').value = "DESC"
		else if(document.getElementById('TodaysLoadSortOrder').value == "DESC")
			document.getElementById('TodaysLoadSortOrder').value = "ASC"
	}
	document.getElementById('TodaysLoadSortBy').value = fieldName;
	$('#dispLoadForm').submit();
}

function FutureLoadsTablePrevPage(){
	if(parseInt(document.getElementById('FutureLoadsPageNo').value)>1) {
		document.getElementById('FutureLoadsPageNo').value = parseInt(document.getElementById('FutureLoadsPageNo').value)-1;
		$('#dispLoadForm').submit();
	}
}

function FutureLoadsTableNextPage() {
	document.getElementById('FutureLoadsPageNo').value = parseInt(document.getElementById('FutureLoadsPageNo').value)+1;
	$('#dispLoadForm').submit();
}

function sortFutureLoadsBy(fieldName) { 
	if(document.getElementById('FutureLoadsSortBy').value == fieldName) {
		if(document.getElementById('FutureLoadsSortOrder').value == "ASC")
			document.getElementById('FutureLoadsSortOrder').value = "DESC"
		else if(document.getElementById('FutureLoadsSortOrder').value == "DESC")
			document.getElementById('FutureLoadsSortOrder').value = "ASC"
	}
	document.getElementById('FutureLoadsSortBy').value = fieldName;
	$('#dispLoadForm').submit();
}

function DispatchedTablePrevPage(){
	if(parseInt(document.getElementById('DispatchedPageNo').value)>1) {
		document.getElementById('DispatchedPageNo').value = parseInt(document.getElementById('DispatchedPageNo').value)-1;
		$('#dispLoadForm').submit();
	}
}

function DispatchedTableNextPage() {
	document.getElementById('DispatchedPageNo').value = parseInt(document.getElementById('DispatchedPageNo').value)+1;
	$('#dispLoadForm').submit();
}

function sortDispatchedBy(fieldName) { 
	if(document.getElementById('DispatchedSortBy').value == fieldName) {
		if(document.getElementById('DispatchedSortOrder').value == "ASC")
			document.getElementById('DispatchedSortOrder').value = "DESC"
		else if(document.getElementById('DispatchedSortOrder').value == "DESC")
			document.getElementById('DispatchedSortOrder').value = "ASC"
	}
	document.getElementById('DispatchedSortBy').value = fieldName;
	$('#dispLoadForm').submit();
}

function checkboxConsolidated(ele) {
	var err=0
	if ($(ele).prop('checked')==true){ 
		$( ".checkboxSelectConsolidate" ).each(function() {
		  	if(!$(this).data("billdocerror")){
		  		$(this).prop("checked", true);
		  	}
		  	else{
		  		err=1;
		  	}
		});
    }else{
		$(".checkboxSelectConsolidate").prop("checked", false);
	} 
	if(err){
		alert("Some loads has attachments that are not supported. We only support PDF, JPG, PNG & GIF file formats. Please fix this and try to add this loads again.");
	}
}
function loadCustomerAutoSave(loadid,payerid){
	var path = urlComponentPath+"loadgateway.cfc?method=loadCustomerAutoSave";
	fnOpenNormalDialogProcess();
	$.ajax({
		  type: "post",
		  url: path,		
		  dataType: "json",
		  data: {
			  loadid:loadid,payerid:payerid
			},
		success: function(data){
		  	
		}
	});		
}

function loadCarrierAutoSave(loadid,carrierid,stopno,companyid){
	var path = urlComponentPath+"loadgateway.cfc?method=loadCarrierAutoSave";
	fnOpenNormalDialogProcess();
	$.ajax({
		  type: "post",
		  url: path,		
		  dataType: "json",
		  data: {
			  loadid:loadid,carrierid:carrierid,stopno:stopno,companyid:companyid
			},
		success: function(data){
		  	
		}
	});		
}
function addToConsolidatedQueue(LoadNm){
	var dsn=$('#dsn').val();
	var s_empid=$('#s_empid').val();
	var s_adminusername=$('#s_adminusername').val();
	var matches = [];
	if(LoadNm == 0){
		$(".checkboxSelectConsolidate:checked").each(function() {
			matches.push(this.value);
		});
	}
	else{
		matches.push(LoadNm);
	}
	if(matches !="") {
			var loadNumbers = JSON.stringify(matches);
			var path = urlComponentPath+"loadgateway.cfc?method=addToConsolidatedInvoice";
			
			fnOpenNormalDialogProcess();
			$.ajax({
				  type: "post",
				  url: path,		
				  dataType: "json",
				  data: {
					  loadNumbers:loadNumbers,dsn:dsn,empid:s_empid,adminusername:s_adminusername
					},
				  success: function(data){
				  	if (data.STATUS==true){
						$( "#Information" ).dialog( "close" );	
						alert('Load(s) added to queue.');					
					}
					else{
						$( "#Information" ).dialog( "close" );
						alert('Something went wrong. Please contact support.');
					}
					if($('#ConsolidatedQueueBtn').length && data.STATUS==true){
						$('#ConsolidatedQueueBtn').val('Remove From Consolidated Invoice');
						$("#ConsolidatedQueueBtn").attr("onclick","removeFromConsolidatedQueue('"+LoadNm+"')");
					}
					else{
						$(".checkboxSelectConsolidate:checked").each(function() {
							$(this).removeAttr('checked');
							location.reload(true);
						});	
					}
				  }
			});
		}		

}

function removeFromConsolidatedQueue(LoadNo){
	var dsn=$('#dsn').val();
	var path = urlComponentPath+"loadgateway.cfc?method=removeFromConsolidatedInvoice";
	var s_empid=$('#s_empid').val();
	var s_adminusername=$('#s_adminusername').val();
	fnOpenNormalDialogProcess();
	$.ajax({
		type: "post",
		url: path,		
		dataType: "json",
		data: {
		  LoadNo:LoadNo,dsn:dsn,empid:s_empid,adminusername:s_adminusername
		},
		success: function(data){
			if (data.STATUS==true){
				$( "#Information" ).dialog( "close" );	
				alert('Load removed from queue.');					
			}
			else{
				$( "#Information" ).dialog( "close" );
				alert('Something went wrong. Please contact support');
			}
			if($('#ConsolidatedQueueBtn').length){
				$('#ConsolidatedQueueBtn').val('Add To Consolidated Invoice');
				$("#ConsolidatedQueueBtn").attr("onclick","addToConsolidatedQueue('"+LoadNo+"')");
			}
		}
	});

}

function changeConsolidatedStatus(ConsolidatedInvoiceNumber,CustomerID,CompanyID,ConsolidatedID){
	var dsn=$('#dsn').val();
	var path = urlComponentPath+"loadgateway.cfc?method=changeConsolidatedStatus";
	var status = $('#btn_consolidate_status_'+ConsolidatedInvoiceNumber).val();

	fnOpenNormalDialogProcess();
	$.ajax({
		type: "post",
		url: path,		
		dataType: "json",
		data: {
		  ConsolidatedInvoiceNumber:ConsolidatedInvoiceNumber,dsn:dsn,Status:status,CustomerID:CustomerID,CompanyID:CompanyID,ConsolidatedID:ConsolidatedID
		},
		success: function(data){
			$( "#Information" ).dialog( "close" );	
				
			setTimeout(function(){ alert(data.MSG);if($('#reload').length){location.reload();} }, 500);
			$('#btn_consolidate_status_'+ConsolidatedInvoiceNumber).val(data.STATUS);

			
		}
	});

}
function consolidatedInvoiceReportOnClick(ConsolidatedInvoiceNumber,URLToken,CustomerID,CompanyID,ConsolidatedID) {
	var dsn=$('#dsn').val();
	var status = $('#btn_consolidate_status_'+ConsolidatedInvoiceNumber).val();
	window.open('../reports/ConsolidatedInvoiceReport.cfm?ConsolidatedInvoiceNumber='+ConsolidatedInvoiceNumber+'&dsn='+dsn+'&'+URLToken+'&CompanyID='+CompanyID);

	if(status == 'OPEN'){
		$('<div></div>').appendTo('body').html('<div><h4>Do you want to CLOSE out this CONSOLIDATION?</h4>(You can re-open anytime.)</div>').dialog({
		    modal: true,
		    title: 'Close Consolidation',
		    zIndex: 10000,
		    autoOpen: true,
		    width: 'auto',
		    resizable: false,
		    buttons: {
		        Yes: function() {
		        	changeConsolidatedStatus(ConsolidatedInvoiceNumber,CustomerID,CompanyID,ConsolidatedID)
		          	$(this).dialog("close");
		        },
		        No: function() {
		          	$(this).dialog("close");
		        }
		    },
		    close: function(event, ui) {
		        $(this).remove();
		    }
		});
	}	
}
function consolidatedInvoiceEmailOnClick(ConsolidatedInvoiceNumber,URLToken,CustomerID,CompanyID,ConsolidatedID) {
	var status = $('#btn_consolidate_status_'+ConsolidatedInvoiceNumber).val();
	if(status == 'OPEN'){
		$('<div></div>').appendTo('body').html('<div><h4>Do you want to CLOSE out this consolidation??</h4></div>').dialog({
		    modal: true,
		    title: 'Close Consolidation',
		    zIndex: 10000,
		    autoOpen: true,
		    width: 'auto',
		    resizable: false,
		    buttons: {
		        Yes: function() {
		        	changeConsolidatedStatus(ConsolidatedInvoiceNumber,CustomerID,CompanyID,ConsolidatedID)
		          	$(this).dialog("close");
		          	window.open('index.cfm?event=consolidatedInvoiceMail&ConsolidatedInvoiceNumber='+ConsolidatedInvoiceNumber+'&'+URLToken+'','Map','height=400,width=750');
		        },
		        No: function() {
		          	$(this).dialog("close");
		          	window.open('index.cfm?event=consolidatedInvoiceMail&ConsolidatedInvoiceNumber='+ConsolidatedInvoiceNumber+'&'+URLToken+'','Map','height=400,width=750');
		        }
		    },
		    close: function(event, ui) {
		        $(this).remove();
		    }
		});
	}
	else{
		window.open('index.cfm?event=consolidatedInvoiceMail&ConsolidatedInvoiceNumber='+ConsolidatedInvoiceNumber+'&'+URLToken+'','Map','height=400,width=750');
	}
}	

function ConfirmDialog(CustomerID) {
	$('<div></div>').appendTo('body').html('<div><h6>Do you want to CLOSE out this consolidation??</h6></div>').dialog({
	    modal: true,
	    title: 'Delete message',
	    zIndex: 10000,
	    autoOpen: true,
	    width: 'auto',
	    resizable: false,
	    buttons: {
	        Yes: function() {
	          $('body').append('<h1>Confirm Dialog Result: <i>Yes</i></h1>');
	          $(this).dialog("close");
	        },
	        No: function() {
	          $('body').append('<h1>Confirm Dialog Result: <i>No</i></h1>');

	          $(this).dialog("close");
	        }
	    },
	    close: function(event, ui) {
	        $(this).remove();
	    }
	});
}

function validationExpense(dsName,CompanyID) {
	
	var description=document.getElementById("description").value;
	var amount=document.getElementById("amount").value;
	var category=document.getElementById("category").value;
	var editid=document.getElementById("editid").value;

	var intRegex = /^\d+(\.\d{1,2})?$/;

	if (description==""){
		alert('Please enter Description.');
		document.getElementById("description").focus();
		return false;
	}

	amount = amount.replace("$","");
	amount = amount.replace(/,/g,"");

	if(isNaN(amount) || !amount.length){
		alert('Please enter valid amount');
		document.getElementById("amount").focus();
		return false;
	}	

	var path = urlComponentPath+"equipmentgateway.cfc?method=getExpenseDescriptionDuplicate&dsName="+encodeURIComponent(dsName)+"&description="+description+"&editid="+editid+"&CompanyID="+CompanyID;
	$.ajax({
		type: "get",
		url: path,	
		success: function(data){
			if(data==1){
				$("#frmExpense").submit();
			}else{
				$("#errorShow").show();
				return false;
			}
		}, 
		error: function(err){
			return false;
		}
    });
}

function validationCarrierExpense() {
	
	var description=document.getElementById("description").value;
	var amount=document.getElementById("amount").value;
	var category=document.getElementById("category").value;
	var driverid=document.getElementById("driverid").value;
	var editid=document.getElementById("editid").value;
	var date=document.getElementById("date").value;

	var intRegex = /^\d+(\.\d{1,2})?$/;

	if (description==""){
		alert('Please enter Description.');
		document.getElementById("description").focus();
		return false;
	}

	if(amount ==""){
		alert('Please enter Amount.');
		document.getElementById("amount").focus();
		return false;
	}

	amount = amount.replace("$","");
	amount = amount.replace(/,/g,"");

	if(isNaN(amount) || !amount.length){
		alert('Please enter valid amount');
		document.getElementById("amount").focus();
		return false;
	}		

	if(date ==""){
		alert('Please enter Date.');
		document.getElementById("date").focus();
		return false;
	}

	if(category ==""){
		alert('Please enter Category.');
		document.getElementById("category").focus();
		return false;
	}
	$("#frmCarrierExpense").submit();
}

function validationRecurringCarrierExpense() {
	
	var description=document.getElementById("description").value;
	var amount=document.getElementById("amount").value;
	var category=document.getElementById("category").value;
	var driverid=document.getElementById("driverid").value;
	var editid=document.getElementById("editid").value;
	var date=document.getElementById("date").value;
	var Interval=document.getElementById("Interval").value;

	var intRegex = /^\d+(\.\d{1,2})?$/;

	if (description==""){
		alert('Please enter Description.');
		document.getElementById("description").focus();
		return false;
	}

	amount = amount.replace("$","");
	amount = amount.replace(/,/g,"");

	if(isNaN(amount) || !amount.length){
		alert('Please enter valid amount');
		document.getElementById("amount").focus();
		return false;
	}	

	if(date ==""){
		alert('Please enter Date.');
		document.getElementById("date").focus();
		return false;
	}

	if(Interval =="0"){
		alert('Please Select Interval.');
		document.getElementById("Interval").focus();
		return false;
	}

	if(category ==""){
		alert('Please enter Category.');
		document.getElementById("category").focus();
		return false;
	}
	$("#frmRecurringCarrierExpense").submit();
}

function calculateCustomDeadHeadMiles(){
	var shipperlocation = $('#shipperlocation').val();
	var shippercity = $('#shippercity').val();
	var shipperstate = $('#shipperstate').val();
	var shipperZipcode = $('#shipperZipcode').val();

	if($.trim(shipperlocation).length && $.trim(shippercity).length && $.trim(shipperstate).length && $.trim(shipperZipcode).length){
		if(googleMapsPcMiler == 1){
			var origin = '';
			var destination = '';
			var sCity = $('#fpDHMilesCity').val();
			var sState = $('#fpDHMilesState').val();
			var sZip = $('#fpDHMilesZip').val();
			var sLocation = $('#fpDHMilesAddress').val();
			var cCity = shippercity;
			var cState = shipperstate;
			var cZip = shipperZipcode;
			var cLocation = shipperlocation;
			var origin = sLocation + ' ' + sCity + ' ' +sState + ' ' + sZip;
			var destination =  cLocation + ' ' + cCity + ' ' +cState + ' ' + cZip;
	        PRIMEWebAPI.getMiles(origin, destination, PRIMEWebAPI.RoutingMethods.PRACTICAL, function(miles,status){
	        	if(status=='success' && miles !=0){
					document.getElementById("deadHeadMiles").value = miles;
					document.getElementById('deadHeadMiles').onchange();
	        	}
	        	else{
	        		alert("Load Manager cannot calculate the DeadHead Miles because the address is not recognized.");
	        	}
	        });
		}

		else{
			var endPoint="";
			var startPoint="";
			var distanceTotal=0;

			shipperAddress = $('#fpDHMilesAddress').val();
			shipperAddress += " " + trim($('#fpDHMilesCity').val());
			shipperAddress += "," + trim($('#fpDHMilesState').val());

			consigneeAddress = shipperlocation;
			consigneeAddress += " " + trim(shippercity);
			consigneeAddress += "," + trim(shipperstate);

			startPoint=shipperAddress;
			endPoint=consigneeAddress;

			var requestLoad = {
				origin: startPoint,
			    destination: endPoint,
				provideRouteAlternatives: false,
				travelMode: google.maps.DirectionsTravelMode.DRIVING
			};
			var directionsServiceLoad= new google.maps.DirectionsService();
			directionsServiceLoad.route(requestLoad, function(response, status) {
				if (status == "OK"){
					var totalDistance = 0;
					var totalDuration = 0;
					var legs = response.routes[0].legs;
					for(var i=0; i<legs.length; ++i) {
						totalDistance += legs[i].distance.value;
						totalDuration += legs[i].duration.value;
					}
					var METERS_TO_MILES = 0.000621371192;
					distanceTotal+=(Math.round( totalDistance * METERS_TO_MILES * 10 ) / 10);
				}	
				else{
					alert("Load Manager cannot calculate the DeadHead Miles because the address is not recognized.");
				}
				if(isNaN(distanceTotal)){	
					distance = 0;
				}
				document.getElementById('deadHeadMiles').value = distanceTotal;
				document.getElementById('deadHeadMiles').onchange();
			});
		}
	}

}

function calculateDeadHeadMiles(){
	var shipperlocation = $('#shipperlocation').val();
	var shippercity = $('#shippercity').val();
	var shipperstate = $('#shipperstate').val();
	var shipperZipcode = $('#shipperZipcode').val();
	var shipperPickupDate = $('#shipperPickupDate').val();
	var equipment = $('#equipment').val();
	var editid=$("#editid").val();
	var driverid=$("#carrierID").val();
	var CompanyID=$("#CompanyID").val();
	var CalculateDHMiles = $("#CalculateDHMiles").val();

	if($.trim(shipperlocation).length && $.trim(shippercity).length && $.trim(shipperstate).length
		 && $.trim(shipperZipcode).length && $.trim(shipperPickupDate).length && $.trim(equipment).length && CalculateDHMiles == 1){
		
		var path = urlComponentPath+"loadgateway.cfc?method=getEquipmentLastLocation";
	    $.ajax({
	        type: "get",
	        url: path,		
	        dataType: "json",
	        async: false,
	        data: {
	            shipperPickupDate: shipperPickupDate,
	            equipmentID:equipment,
	            loadID : editid,
	            driverid:driverid,
	            CompanyID:CompanyID
	          },
	        success: function(eqLoc){
	        	if(eqLoc.SUCCESS){
	        		if(eqLoc.COUNT == 0){
	        			document.getElementById("deadHeadMiles").value = 0;
	        			document.getElementById('deadHeadMiles').onchange();
	        		}
	        		else{
	        			if(googleMapsPcMiler == 2 && ALKMaps.APIKey){
			          		map = new ALKMaps.Map('map');
			          		ALKMaps.Geocoder.geocode({
			          			address:{
									addr: eqLoc.ADDRESS, 
									city: eqLoc.CITY, 
									state: eqLoc.STATECODE, 
									region: "NA" //Valid values are NA, EU, OC, SA, AS, AF, and ME. Default is NA.
								},
								listSize: 1, //Optional. The number of results returned if the geocoding service finds multiple matches.

								success: function(response){
									stopFirst.lat = response[0].Coords.Lat;
									stopFirst.lon = response[0].Coords.Lon;

									ALKMaps.Geocoder.geocode({
										address:{
											addr: shipperlocation, 
											city: shippercity, 
											state: shipperstate, 
											region: "NA" //Valid values are NA, EU, OC, SA, AS, AF, and ME. Default is NA.
										},
										listSize: 1,

										success: function(response){
											stopLast.lat = response[0].Coords.Lat;
											stopLast.lon = response[0].Coords.Lon;

											var stops = [
												new ALKMaps.LonLat(stopFirst.lon,stopFirst.lat)
											];



											stops.push(new ALKMaps.LonLat(stopLast.lon,stopLast.lat));
							
											stops = ALKMaps.LonLat.transformArray(stops, new ALKMaps.Projection("EPSG:4326"), map.getProjectionObject());

											/*console.log(stops);
											debugger;*/
											
											var coordsArray	= [[stops[0].lon,stops[0].lat],[stops[1].lon,stops[1].lat]];
											if (typeof stops[2] !== 'undefined') {
												coordsArray.push([stops[2].lon,stops[2].lat]);
											}
											
											var opt = {
												vehicleType:"LightTruck", 
												routingType:"Practical", 
												routeOptimization: 1, 
												highwayOnly: false, 
												distanceUnits: "Miles", 
												tollCurrency: "US", 
												inclTollData:true,
												region: "NA"  //Valid values are NA, EU, OC and SA.
											}; 

											var reportOptions = { 
												type: "CalcMiles", //Comma separated report type values
												format: "json",
												lang: "ENUS", //Valid values are ENUS, ENGB, DE, FR, ES, IT
												dataVersion: "current"  //Valid values are Current, PCM_EU, PCM_OC, PCM_SA, PCM_GT, PCM_AF, PCM_AS, PCM_ME, or PCM18 through PCM27
											}; 

											map.getReports({ 
												coords: coordsArray, 
												options: opt, 
												reportOptions: reportOptions, 
												success: function(resp){
													//console.log(resp[0].TMiles);

													distanceTotal = parseFloat(resp[0].TMiles);
													if(isNaN(distanceTotal)){	
														distance = 0;
													}
													document.getElementById('deadHeadMiles').value = distanceTotal;
													document.getElementById('deadHeadMiles').onchange();
												},
												failure: function(response){
													alert("Load Manager cannot calculate the DeadHead Miles because the address is not recognized.");
												}
											});
										},
										failure: function(response){
											alert("Load Manager cannot calculate the DeadHead Miles because the address is not recognized.");
										}
									});
								},
								failure: function(response){
									alert("Load Manager cannot calculate the DeadHead Miles because the address is not recognized.");
								}
			          		})
			          	}
			          	else if(googleMapsPcMiler == 1){

					    	var origin = '';
					    	var destination = '';
					    	
							var sCity = eqLoc.CITY;
							var sState = eqLoc.STATECODE;
							var sZip = eqLoc.POSTALCODE;
							var cCity = shippercity;
							var cState = shipperstate;
							var cZip = shipperZipcode;

							var origin = sCity + ' ' +sState + ' ' + sZip;
							var destination =  cCity + ' ' +cState + ' ' + cZip;
							
					        PRIMEWebAPI.getMiles(origin, destination, PRIMEWebAPI.RoutingMethods.PRACTICAL, function(miles,status){
					        	if(status=='success' && miles !=0){
									document.getElementById("deadHeadMiles").value = miles;
									document.getElementById('deadHeadMiles').onchange();
					        	}
					        	else{
					        		if(eqLoc.POSTALCODE.split(' ').length>1){
					        			var sZip = eqLoc.POSTALCODE.split(' ')[0];
										var origin = sCity + ' ' +sState + ' ' + sZip;
										var destination = cCity + ' ' +cState + ' ' + cZip;
										PRIMEWebAPI.getMiles(origin, destination, PRIMEWebAPI.RoutingMethods.PRACTICAL, function(miles,status){
											if(status=='success' && miles !=0){
												document.getElementById("deadHeadMiles").value = miles;
												document.getElementById('deadHeadMiles').onchange();
								        	}
								        	else{
								        		alert("Load Manager cannot calculate the DeadHead Miles because the address is not recognized.");
								        	}
										});
					        		}
					        	}
					        });
						}

						else{
							var endPoint="";
							var startPoint="";
							var distanceTotal=0;

							shipperAddress = eqLoc.ADDRESS;
							shipperAddress += " " + trim(eqLoc.CITY);
							shipperAddress += "," + trim(eqLoc.STATECODE);


							consigneeAddress = shipperlocation;
							consigneeAddress += " " + trim(shippercity);
							consigneeAddress += "," + trim(shipperstate);


							startPoint=shipperAddress;
							endPoint=consigneeAddress;

							var requestLoad = {
								origin: startPoint,
							    destination: endPoint,
								provideRouteAlternatives: false,
								travelMode: google.maps.DirectionsTravelMode.DRIVING
							};
							var directionsServiceLoad= new google.maps.DirectionsService();
							directionsServiceLoad.route(requestLoad, function(response, status) {
								if (status == "OK"){
									var totalDistance = 0;
									var totalDuration = 0;
									var legs = response.routes[0].legs;
									for(var i=0; i<legs.length; ++i) {
										totalDistance += legs[i].distance.value;
										totalDuration += legs[i].duration.value;
									}
									var METERS_TO_MILES = 0.000621371192;
									distanceTotal+=(Math.round( totalDistance * METERS_TO_MILES * 10 ) / 10);
								}	
								else{
									alert("Load Manager cannot calculate the DeadHead Miles because the address is not recognized.");
								}
								if(isNaN(distanceTotal)){	
									distance = 0;
								}
								document.getElementById('deadHeadMiles').value = distanceTotal;
								document.getElementById('deadHeadMiles').onchange();
							});
						}


	        		}
	        	}
	        	else{
	        		document.getElementById("deadHeadMiles").value = 0;
	        		document.getElementById('deadHeadMiles').onchange();
	        	}

	          	
	        }
	    }); 

	}

}

function validateFactoring(stayonpage) {
	
	var Name=document.getElementById("Name").value;
	var Address=document.getElementById("Address").value;
	var City=document.getElementById("City").value;
	var state=document.getElementById("state").value;
	var Zip=document.getElementById("Zip").value;
	var editid=document.getElementById("editid").value;
	var companyid=document.getElementById("companyid").value;
	if (!$.trim(Name).length){
		alert('Please enter the name.');
		document.getElementById("Name").focus();
		return false;
	}

	if (!$.trim(Address).length){
		alert('Please enter the address.');
		document.getElementById("Address").focus();
		return false;
	}

	if (!$.trim(City).length){
		alert('Please enter the city.');
		document.getElementById("City").focus();
		return false;
	}

	if (!$.trim(state).length){
		alert('Please select the state.');
		document.getElementById("state").focus();
		return false;
	}

	if (!$.trim(City).length){
		alert('Please enter the city.');
		document.getElementById("City").focus();
		return false;
	}


	var path = urlComponentPath+"loadgateway.cfc?method=getFactoringDuplicate&Name="+Name+"&editid="+editid+"&companyid="+companyid;
	$.ajax({
		type: "get",
		url: path,	
		success: function(data){
			if(data==1){
				$('#stayonpage').val(stayonpage);
				$("#frmFactoring").submit();
			}else{
				alert('Name already exists.');
				document.getElementById("Name").focus();
				return false;
			}
		}, 
		error: function(err){
			return false;
		}
    });
}

function validateCRMNoteType(stayonpage) {
	
	var NoteType=document.getElementById("NoteType").value;
	var Description=document.getElementById("Description").value;
	var CRMType=document.getElementById("CRMType").value;
	var editid=document.getElementById("editid").value;
	var companyid=document.getElementById("companyid").value;
	if (!$.trim(NoteType).length){
		alert('Please enter the NoteType.');
		document.getElementById("NoteType").focus();
		return false;
	}

	if (!$.trim(Description).length){
		alert('Please enter the Description.');
		document.getElementById("Description").focus();
		return false;
	}

	if (!$.trim(CRMType).length){
		alert('Please select the CRM Type.');
		document.getElementById("CRMType").focus();
		return false;
	}

	var path = urlComponentPath+"customergateway.cfc?method=getCRMNoteTypeDuplicate&companyid="+companyid+"&NoteType="+NoteType+"&CRMType="+CRMType+"&editid="+editid;
	$.ajax({
		type: "get",
		url: path,	
		success: function(data){
			if(data==1){
				$('#stayonpage').val(stayonpage);
				$("#frmCRMNoteType").submit();
			}else{
				alert('NoteType already exists for '+CRMType+'.');
				document.getElementById("Name").focus();
				return false;
			}
		}, 
		error: function(err){
			return false;
		}
    });
}
function saveCRMCallFrequency() {

	var CallFrequency=document.getElementById("CallFrequency").value;
	var NextCall=document.getElementById("NextCall").value;
	var editid=document.getElementById("editid").value;
	var cftoken=document.getElementById("cftoken").value;
	var frmEvent=document.getElementById("frmEvent").value;
	var path = urlComponentPath+"customergateway.cfc?method=saveCRMCallFrequency&CallFrequency="+CallFrequency+"&NextCall="+NextCall+"&editid="+editid;
	$.ajax({
		type: "get",
		url: path,	
		success: function(data){
			var msg = "Changes are saved successfully.";
			if(trim(frmEvent).length){
				location.href = "index.cfm?event="+frmEvent+"&"+cftoken+"&msg="+msg;
			}

		}, 
		error: function(err){
			return false;
		}
    });
}
function saveCarrierCRMCallFrequency() {

	var CallFrequency=document.getElementById("CallFrequency").value;
	var NextCall=document.getElementById("NextCall").value;
	var editid=document.getElementById("editid").value;
	var cftoken=document.getElementById("cftoken").value;
	var frmEvent=document.getElementById("frmEvent").value;
	var path = urlComponentPath+"carriergateway.cfc?method=saveCRMCallFrequency&CallFrequency="+CallFrequency+"&NextCall="+NextCall+"&editid="+editid;
	$.ajax({
		type: "get",
		url: path,	
		success: function(data){
			var msg = "Changes are saved successfully.";
			if(trim(frmEvent).length){
				location.href = "index.cfm?event="+frmEvent+"&"+cftoken+"&msg="+msg;
			}
		}, 
		error: function(err){
			return false;
		}
    });
}

function UpdateViaCarrierLookOut(opt) {
	$('.overlay').hide();
	$('#CLPopup').hide();
	var CarrierID=$("#editid").val();
	var stoken=$("#stoken").val();
	var DOTNumber=$("#DOTNumber").val();
	var Redirect_To = "";
	if( $('#Redirect_To').length )
	{	
	    var Redirect_To = "Redirect_To=CarrierLookup";
	}

	window.location='index.cfm?event=UpdateViaCarrierLookOut&CarrierID='+CarrierID+'&DOTNumber='+DOTNumber+'&opt='+opt+'&'+stoken+'&'+Redirect_To;
}

function getCarrierLookoutConfirmation() {
	var dotnumber=$("#DOTNumber").val();
	if(dotnumber !="") {
		$('.overlay').show();
		$('#CLPopup').show();
	}
	else{
		alert('Please enter DotNumber.');
		return false;
	}
}


function jumpToPage(formName){

	var jumpPageNo =  document.getElementById('jumpPageNo').value;
	var TotalPages =  document.getElementById('TotalPages').value;

	if($.trim(jumpPageNo).length && !isNaN(jumpPageNo) && parseInt(jumpPageNo) <= parseInt(TotalPages)){
		document.getElementById('pageNo').value = parseInt(jumpPageNo);
		$('#'+formName).submit();
	}
}

function ckreportType(value){
	$("input[name='reportType'][value="+value+"]").prop("checked", true);
}

$(document).ready(function(){
	$('.selEquipment').each(function() {
		var width = $(this).width()-2;
	    // Cache the number of options
	    var $this = $(this),
	    numberOfOptions = $(this).children('option').length;
	    // Hides the select element
	    $this.addClass('s-hidden');
	    // Wrap the select element in a div
	    $this.wrap('<div class="select" style="width:'+width+'px"></div>');
	    // Insert a styled div to sit over the top of the hidden select element
	    $this.after('<div class="styledSelect"></div>');
	    // Cache the styled div
	    var $styledSelect = $this.next('div.styledSelect');
	    // Show the first select option in the styled div
	    $styledSelect.text($this.find('option:selected').text());
	    // Insert an unordered list after the styled div and also cache the list
	    var $table = $('<table />',{'class': 'options','cellspacing':0,'cellpadding':0}).insertAfter($styledSelect);
	    var $thead = $('<thead />').appendTo($table);
	    var $theadtr = $('<tr />').appendTo($thead);
	   	$('<th />', {html: 'Equip','width':'45%'}).appendTo($theadtr);
	   	$('<th />', {html: 'Related Equip','width':'45%'}).appendTo($theadtr);
	   	$('<th />', {html: 'Type','width':'10%'}).appendTo($theadtr);
	   	var $tbody = $('<tbody />').appendTo($table);
	    // Insert a list item into the unordered list for each select option
	    for (var i = 0; i < numberOfOptions; i++) {
	    	var $tbodytr = $('<tr />',{
	    		rel: $this.children('option').eq(i).val()
	    	}).appendTo($tbody);
	        $('<td />', {
	            html: $this.children('option').eq(i).text()
	        }).appendTo($tbodytr);
	        $('<td />', {
	            html: $this.children('option').eq(i).attr('data-relequip')
	        }).appendTo($tbodytr);
	        $('<td />', {
	            html: $this.children('option').eq(i).attr('data-type')
	        }).appendTo($tbodytr);
	    }
	    // Cache the list items
	    var $listItems = $table.children('tbody').children('tr');
	    
	    // Show the unordered list when the styled div is clicked (also hides it if the div is clicked again)
	    $styledSelect.click(function(e) {
	        e.stopPropagation();

	        if($table.is(":visible")){
	        	$table.hide();
	        	return false;
	        }

	        $('div.styledSelect.active').each(function() {
	            $(this).removeClass('active').next('table.options').hide();
	        });
	        $(this).toggleClass('active').next('table.options').toggle();
	        if($(this).next('table.options').css('display')=='table'){
	        	$(this).next('table.options').css('display','block');
	        }
	        if($this.find('option:selected').val() != ''){
	        	$table.children('tbody').children('tr').eq($this.prop('selectedIndex')).addClass('hover');
	        }
	        
	    });
	    // Hides the unordered list when a list item is clicked and updates the styled div to show the selected list item
	    // Updates the select element to have the value of the equivalent option
	    $listItems.click(function(e) {
	        e.stopPropagation();
	        $styledSelect.text($(this).children('td:first').text()).removeClass('active');
	        $this.val($(this).attr('rel'));
	        $table.hide();
	        $this.trigger("change");
	        /* alert($this.val()); Uncomment this for demonstration! */
	    });

	    $listItems.hover(function(e) {
	     	$table.children('tbody').children('tr').removeClass('hover');
	    });
	    // Hides the unordered list when clicking outside of it
	    $(document).click(function() {
	        $styledSelect.removeClass('active');
	        $table.hide();
	    });
	});
})

function validateDispatchFeeAmount() {
	var DispatchFee = $('#DispatchFee').val();
	var DispatchFeeAmount = $('#DispatchFeeAmount').val();
	DispatchFeeAmount = DispatchFeeAmount.replace("$","");

	if(DispatchFeeAmount > 0){
	 	DispatchFee = $('#DispatchFee').val('0.00%');
	}	

}
function validateDispatchFee() {
	var DispatchFee = $('#DispatchFee').val();
	var DispatchFeeAmount = $('#DispatchFeeAmount').val();
	DispatchFee = DispatchFee.replace("%","");
	
	if(DispatchFee > 0){
		DispatchFeeAmount = $('#DispatchFeeAmount').val('$0.00');
	}	

}

function ckExZeroItems(){
	var ckd = $('#ExZeroItems').is(":checked");
	if(ckd){
		$('.zeroWeightGrp').show();
	}
	else{
		$('.zeroWeightGrp').hide();
		$('#ExZeroWeight').prop("checked",false);
	}
}
function activeAllConsolidateCheckbox(){
	if ($('#ConsolidateInvoices').is(':checked')) {
		$('#IncludeIndividualInvoices').prop('checked', true);
		$('#SeperateJobPo').prop('checked', true);
		$('#ConsolidateInvoiceBOL').prop('checked', true);
		$('#ConsolidateInvoiceRef').prop('checked', true);
		$('#ConsolidateInvoiceDate').prop('checked', true);
	} else {
		$('#IncludeIndividualInvoices').prop('checked', false);
		$('#SeperateJobPo').prop('checked', false);
		$('#ConsolidateInvoiceBOL').prop('checked', false);
		$('#ConsolidateInvoiceRef').prop('checked', false);
		$('#ConsolidateInvoiceDate').prop('checked', false);
	}
}