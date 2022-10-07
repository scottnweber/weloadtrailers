<cfquery name="qgetActiveLoads" datasource="weloadtrailers">
	SELECT 
	LoadID,
	LoadNumber,
	convert(varchar, NewPickupDate, 101) AS ShipDate
	,(SELECT TOP(1) City FROM LoadStops WHERE loadId = L.Loadid  AND  StopNo = 0 AND LoadType = 1) AS ShipCity
	,(SELECT TOP(1) StateCode FROM LoadStops WHERE loadId = L.Loadid  AND  StopNo = 0 AND LoadType = 1) AS ShipState
	,(SELECT Top(1) City FROM LoadStops WHERE loadId = L.Loadid AND  StopNo =(SELECT MAX(StopNo) FROM LoadStops WHERE LoadID = L.Loadid) AND LoadType = 2) AS DeliveryCity
	,(SELECT Top(1) StateCode FROM LoadStops WHERE loadId = L.Loadid AND  StopNo =(SELECT MAX(StopNo) FROM LoadStops WHERE LoadID = L.Loadid) AND LoadType = 2) AS DeliveryState
	,convert(varchar, NewDeliveryDate, 101) AS deliveryDate
	,EquipmentName as TruckType
	,EquipmentID
	,isnull(noOfTrips,0) as noOfTrips
	,carrierNotes
	,L.totalmiles as carriertotalmiles
	FROM Loads L
</cfquery>
<cfoutput>
	<style>
		.loadListContainer{
			padding:0 25px 50px 25px;
		}
		.loadListTable thead{
			background-color: ##1c4689;
			color: ##fff;
			font-size: 12px;
		}
		.loadListTable tr{
			border-bottom:none;
		}
		.loadListTable th{
			border-bottom:none;
			text-align:center;
		}
		.loadListTable tbody tr{
			color: ##000;
		}
		.loadListTable td{
			text-align:center;
			border: 1px solid ##c7c3c3;
			font-size: 12px;
			cursor:pointer;
		}
		.loadListTable tbody tr:hover{
			color:##fff;
			background-color: ##848484;
		}
	</style>
	<table class="loadListTable" width="100%">
		<thead>
			<tr>
				<th>Pro ##</th>
				<th>Approx ##<br>of Trips</th>
				<th>Ship Date</th>
				<th>Ship City</th>
				<th>Ship State</th>
				<th>Delivery City</th>
				<th>Delivery State</th>
				<th>Delivery Date</th>
				<th>Truck Type</th>
			</tr>
		</thead>
		<tbody>
			<cfif qgetActiveLoads.recordcount>
				<cfloop query="#qgetActiveLoads#">
					<tr onclick="openLoadDetails('#qgetActiveLoads.LoadID#')">
						<td>#qgetActiveLoads.LoadNumber#</td>
						<td>#qgetActiveLoads.noOfTrips#</td>
						<td>#qgetActiveLoads.ShipDate#</td>
						<td>#qgetActiveLoads.ShipCity#</td>
						<td>#qgetActiveLoads.ShipState#</td>
						<td>#qgetActiveLoads.DeliveryCity#</td>
						<td>#qgetActiveLoads.DeliveryState#</td>
						<td>#qgetActiveLoads.deliveryDate#</td>
						<td>#qgetActiveLoads.TruckType#</td>
					</tr>
				</cfloop>
			<cfelse>
				<tr>
					<td colspan="9" align="center">No Records.</td>
				</tr>
			</cfif>
		</tbody>
	</table>
	<script type="text/javascript">
		function openLoadDetails(LoadID){
			location.href = 'https://loadmanager.net/weloadtrailers/www/webroot/wp_loaddetail.cfm?LoadID='+LoadID;
		}
	</script>
</cfoutput>