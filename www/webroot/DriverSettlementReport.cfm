<cfoutput>
	<style type="text/css">
		.reportsSubHeading{
			border-bottom: 1px solid ##95cac885 !important;
			margin-bottom: 16px !important;
			padding-left:0px !important;
		}
	</style>
	<div class="white-con-area" style="height: 36px;background-color: ##82bbef;">
		<div style="float: left;"><h2 style="color:white;font-weight:bold;margin-left: 12px;">Driver Settlement Report</h2></div>
	</div>
	<div style="clear:left"></div>
	<style>
		.white-mid div.form-con fieldset.TolExp{
			border: 1px dashed ##a9d6ff;
		    padding: 36px 25px;
		    margin-bottom: 13px;
		}
		.reportsSubHeading.expoCustmr{
			padding: 0px 0 6px 0px !important;
			border-bottom: 1px solid ##95cac885 !important;
    		margin-bottom: 14px !important;
		}
		.disAllowEditSelectBox {
			background: none repeat scroll 0 0 ##e3e3e3 !important;
			border: 1px solid ##c5c1c1 !important;
			color: ##434343 !important;
			pointer-events: none;
		}
	</style>
	<cfquery name="qGetLastSettlementByUser" datasource="#application.dsn#">
		SELECT TOP 1 L.StatusTypeID,LL.NewValue FROM Loads L
		INNER JOIN LoadLogs LL ON L.LoadID = LL.LoadID
		INNER JOIN CustomerOffices CO ON CO.CustomerID = L.CustomerID
		INNER JOIN Offices O ON O.OfficeID = CO.OfficeID
		WHERE LL.UpdatedByUserID=<cfqueryparam value="#session.empid#" cfsqltype="cf_sql_varchar">
		AND LL.FieldLabel='Driver Paid Date'
		AND LL.OldValue IS NULL AND LL.NewValue IS NOT NULL
		AND L.DriverPaidDate IS NOT NULL
		AND O.CompanyID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#session.companyid#">
		ORDER BY LL.UpdatedTimestamp DESC
	</cfquery>

	<cfquery name="qGetStatus" datasource="#application.dsn#">
		SELECT DriverSettlementStatusID AS StatusID FROM SystemConfig WHERE companyid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#session.companyid#">
	</cfquery>

	<cfquery name="qGetCarriers" datasource="#application.dsn#">
		SELECT CarrierID,CarrierName FROM Carriers WHERE companyid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#session.companyid#">
		ORDER BY CarrierName
	</cfquery>

	<cfquery name="qGetHistory" datasource="#application.dsn#">
		SELECT L.DriverPaidDate AS Date
		FROM Loads L 
		INNER JOIN CustomerOffices CO ON CO.CustomerID = L.CustomerID
		INNER JOIN Offices O ON O.OfficeID = CO.OfficeID
		WHERE L.DriverPaidDate IS NOT NULL 
		AND O.CompanyID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#session.CompanyID#">
		UNION 
		SELECT CE.DriverPaidDate AS Date
		FROM CarrierExpenses CE
		INNER JOIN Carriers C ON C.CarrierID = CE.CarrierID
		WHERE CE.DriverPaidDate IS NOT NULL 
		AND C.CompanyID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#session.CompanyID#">
		GROUP BY DriverPaidDate
		ORDER BY DriverPaidDate DESC
	</cfquery>

	<cfset selStatus = "">

	<cfif qGetLastSettlementByUser.recordcount>
		<cfset selStatus = qGetLastSettlementByUser.StatusTypeID>
	</cfif>
	<cfif len(trim(qGetStatus.StatusID))>
		<cfset selStatus = qGetStatus.StatusID>
	</cfif>

	<cfinvoke component="#variables.objloadGateway#" method="getSystemSetupOptions" returnvariable="request.qGetSystemSetupOptions" />
	<cfif request.qGetSystemSetupOptions.freightBroker EQ 1>
		<cfset variables.freightBroker = "Carrier">
	<cfelseif request.qGetSystemSetupOptions.freightBroker EQ 2>
		<cfset variables.freightBroker = "Carrier/Driver">
	<cfelse>
		<cfset variables.freightBroker = "Driver">
	</cfif>
	<cfif session.currentusertype EQ 'Administrator' OR listFindNoCase(session.rightslist, "showAllOfficeLoads")>
		<cfinvoke component="#variables.objofficeGateway#" method="getAllOffices" sortby="officecode" sortorder="asc"  returnvariable="request.qOffices" />
	<cfelse>
		<cfinvoke component="#variables.objofficeGateway#" method="getAllOffices" sortby="officecode" officeid="#session.officeid#" sortorder="asc"  returnvariable="request.qOffices" />
	</cfif>
	<div class="white-con-area">
		<div class="white-top"></div>
		<div class="white-mid">
			<cfform name="frmSettlement" id="frmSettlement" action="index.cfm?event=revertDriverSettlement&#session.URLToken#" method="post">
				<div class="form-con" style="border-right: solid 1px ##a8aaad;margin-top: 5px;margin-bottom: 5px;">
					<fieldset style="padding-bottom: 10px;">
						<label class="space_it" style="width: 145px;">Select Load Status to Pay</label>
						<div style="position:relative;float:left;">
							<div style="float:left;">
								<cfinvoke component="#variables.objloadGateway#" method="getLoadStatus" returnvariable="request.qLoadStatus" /> 			
					   			<select name="loadStatus" id="loadStatus">
					   				<option value="">Select Status</option>
									<cfloop query="request.qLoadStatus">
										<option value="#request.qLoadStatus.value#" <cfif len(trim(selStatus)) AND selStatus EQ request.qLoadStatus.value> selected </cfif> data-statustext="#request.qLoadStatus.text#">#request.qLoadStatus.statusdescription#</option>
									</cfloop>
								</select>
							</div>
						</div>
						<div class="clear"></div> 
						<label class="space_it" style="width: 145px;">To</label>
						<div style="position:relative;float:left;">
							<div style="float:left;">		
					   			<select name="loadStatusTo" id="loadStatusTo">
					   				<option value="">Select Status</option>
									<cfloop query="request.qLoadStatus">
										<option value="#request.qLoadStatus.value#" <cfif len(trim(selStatus)) AND selStatus EQ request.qLoadStatus.value> selected </cfif> data-statustext="#request.qLoadStatus.text#">#request.qLoadStatus.statusdescription#</option>
									</cfloop>
								</select>
							</div>
						</div>
						<div class="clear"></div> 

						<label class="space_it" style="width: 145px;">Office From</label>
						<div style="position:relative;float:left;">
							<div style="float:left;">		
					   			<select name="officeFrom" id="officeFrom" <cfif NOT (session.currentusertype EQ "administrator" OR ListContains(session.rightsList,'showAllOfficeLoads',','))>class="disAllowEditSelectBox"</cfif>	>
					   				<cfif session.currentusertype EQ 'Administrator' OR listFindNoCase(session.rightslist, "showAllOfficeLoads")>
										<option value="">Select</option>
									</cfif>
									<cfloop query="request.qOffices">
										<option value="#request.qOffices.officecode#">#request.qOffices.officecode#</option>
									</cfloop>
								</select>
							</div>
						</div>
						<div class="clear"></div> 
						<label class="space_it" style="width: 145px;">To</label>
						<div style="position:relative;float:left;">
							<div style="float:left;">		
					   			<select name="officeTo" id="officeTo" <cfif NOT (session.currentusertype EQ "administrator" OR ListContains(session.rightsList,'showAllOfficeLoads',','))>class="disAllowEditSelectBox"</cfif>	>
					   				<cfif session.currentusertype EQ 'Administrator' OR listFindNoCase(session.rightslist, "showAllOfficeLoads")>
										<option value="">Select</option>
									</cfif>
									<cfloop query="request.qOffices">
										<option value="#request.qOffices.officecode#">#request.qOffices.officecode#</option>
									</cfloop>
								</select>
							</div>
						</div>
						<div class="clear"></div> 

						<label class="space_it" style="width: 145px;">Select Driver</label>
						<div style="position:relative;float:left;">
							<div style="float:left;">			
					   			<select name="Driver" id="Driver">
					   				<option value="">All Drivers</option>
									<cfloop query="qGetCarriers">
										<option value="#qGetCarriers.CarrierID#">#qGetCarriers.CarrierName#</option>
									</cfloop>
								</select>
							</div>
						</div>
						<div class="clear"></div> 
						<label class="space_it" style="width: 145px;">End Delivery Date</label>
						<div style="position:relative;float:left;">
							<div style="float:left;">
								<input class="sm-input datefieldN" name="EndDeliveryDate" id="EndDeliveryDate"  value="" validate="date" />
							</div>
						</div>
						<div class="clear"></div> 
						<label class="space_it" style="width: 145px;">Mark Settlement Paid</label>
						<div style="position:relative;float:left;">
							<div style="float:left;">
								<cfinput type="checkbox" name="SettlementPaid" value="" id="SettlementPaid"  style="margin-left: -85px;">
							</div>
						</div>
						<div class="clear"></div> 
						<label class="space_it" style="width: 145px;">Paid Date</label>
						<div style="position:relative;float:left;">
							<div style="float:left;">
								<input class="sm-input datefield" tabindex=4 name="PaidDate" id="PaidDate"  value="#dateformat(Now(),'mm/dd/yyy')#" validate="date" type="datefield" />
							</div>
						</div>
						<div class="clear"></div> 

						<label class="space_it" style="width: 145px;">Group By Load##</label>
						<div style="position:relative;float:left;">
							<div style="float:left;">
								<cfinput type="checkbox" name="GroupByLoad" value="" id="GroupByLoad"  style="margin-left: -85px;">
							</div>
						</div>
						<div class="clear"></div> 
						<label class="space_it" style="width: 145px;">Page Break After Each #variables.freightBroker#?</label>
						<div style="position:relative;float:left;">
							<div style="float:left;">
								<cfinput type="checkbox" checked name="PageBreak" value="" id="PageBreak"  style="margin-left: -85px;">
							</div>
						</div>
						<div class="clear"></div> 
						<div style="margin-left: 155px;margin-top: 10px;">
							<input id="submit" type="button" name="submit" class="bttn tooltip" value="Run Report" style="width:95px;"/>
						</div>
					</fieldset>
				</div>
				<div class="form-con" style="width:400px;margin-top: 5px;margin-bottom: 5px;">
					<fieldset style="padding-bottom: 10px;text-align: center;">
						<strong style="font-size: 13px;">Revert Previous Settlement</strong>
						<div class="clear"></div> 
						<div style="margin-left: 155px;margin-top: 10px;">
							<input id="RevertSettlement" type="button" name="submit" class="bttn tooltip" value="Revert Now" style="width:95px;margin-left: -20px;"/>
							<input type="hidden" id="revDate" name="revDate" value="">
							<input type="hidden" id="revDateF" name="revDateF" value="">
							<input type="submit" id="revSubmit" style="display: none;">
						</div>
					</fieldset>
				</div>

				<div class="form-con" style="width: 335px;margin-top: 5px;margin-bottom: 5px;border-top: 1px solid ##77463d !important;margin-left: 45px;">
					<fieldset style="padding-bottom: 10px;text-align: center;">
						<strong style="font-size: 13px;">View Previously Run Report</strong>
						<br>
						<select name="HistoryDate" id="HistoryDate" style="width: 167px;float: none;margin-top: 25px;">
			   				<option value="">Select Date</option>
							<cfloop query="qGetHistory">
								<option value="#qGetHistory.Date#">#DateFormat(qGetHistory.Date,'mm/dd/yyyy')#</option>
							</cfloop>
						</select><br>
						<input id="history" type="button" name="history" class="bttn tooltip" value="Run Report" style="width:95px;float: none;margin-top: 10px;">
					</fieldset>
				</div>
			</cfform>
			<div class="clear"></div>
		</div>
		<div class="white-bot"></div>
	</div>
	<script type="text/javascript">
		$( document ).ready(function() {
			<cfif structKeyExists(session, "RevertMessage")>
				alert('#session.RevertMessage#');
				<cfset structDelete(session, "RevertMessage")>
			</cfif>
			$('##submit').click(function(){

				var LoadStatus = document.getElementById("loadStatus").value;
				var StatusFrom = $( "##loadStatus option:selected" ).attr('data-statustext');
				var StatusTo = $( "##loadStatusTo option:selected" ).attr('data-statustext');
				var officeFrom = $( "##officeFrom option:selected" ).val();
				var officeTo = $( "##officeTo option:selected" ).val();
				var Driver = document.getElementById("Driver").value;
				if($("##SettlementPaid").is(':checked')){
					var SettlementPaid=1;
				}
				else{
					var SettlementPaid=0;
				}

				if($("##GroupByLoad").is(':checked')){
					var GroupByLoad=1;
				}
				else{
					var GroupByLoad=0;
				}

				if($("##PageBreak").is(':checked')){
					var PageBreak=1;
				}
				else{
					var PageBreak=0;
				}
				
				var PaidDate = document.getElementById('PaidDate').value;
				var EndDeliveryDate = document.getElementById('EndDeliveryDate').value;
				var reg =/((^(10|12|0?[13578])([/])(3[01]|[12][0-9]|0?[1-9])([/])((1[8-9]\d{2})|([2-9]\d{3}))$)|(^(11|0?[469])([/])(30|[12][0-9]|0?[1-9])([/])((1[8-9]\d{2})|([2-9]\d{3}))$)|(^(0?2)([/])(2[0-8]|1[0-9]|0?[1-9])([/])((1[8-9]\d{2})|([2-9]\d{3}))$)|(^(0?2)([/])(29)([/])([2468][048]00)$)|(^(0?2)([/])(29)([/])([3579][26]00)$)|(^(0?2)([/])(29)([/])([1][89][0][48])$)|(^(0?2)([/])(29)([/])([2-9][0-9][0][48])$)|(^(0?2)([/])(29)([/])([1][89][2468][048])$)|(^(0?2)([/])(29)([/])([2-9][0-9][2468][048])$)|(^(0?2)([/])(29)([/])([1][89][13579][26])$)|(^(0?2)([/])(29)([/])([2-9][0-9][13579][26])$))/;

				if($.trim(EndDeliveryDate).length && !EndDeliveryDate.match(reg)){
					alert('Please enter a valid date');
					$('##EndDeliveryDate').focus();
			    	$('##EndDeliveryDate').val('');
			    	return false;
				}

				if($.trim(PaidDate).length && !PaidDate.match(reg)){
					alert('Please enter a valid date');
					$('##PaidDate').focus();
			    	$('##PaidDate').val('');
			    	return false;
				}
				
				window.open('../reports/DriverSettlementReport.cfm?LoadStatus='+LoadStatus+'&StatusFrom='+StatusFrom+'&StatusTo='+StatusTo+'&officeFrom='+officeFrom+'&officeTo='+officeTo+'&CarrierID='+Driver+'&SettlementPaid='+SettlementPaid+'&PaidDate='+PaidDate+'&EndDeliveryDate='+EndDeliveryDate+'&GroupByLoad='+GroupByLoad+'&PageBreak='+PageBreak+'&empid=#session.empid#&companyid=#session.CompanyID#&user=#session.adminusername#&#session.URLToken#');
			})
			$('##SettlementPaid').click(function(){
				if(($(this).is(':checked'))){
					$("##PaidDate").datepicker('enable');
				}
				else{
					$("##PaidDate").datepicker('disable')
				}
			});
			$('##history').click(function(){
				var HistoryDate = document.getElementById('HistoryDate').value;
				if(HistoryDate.length){
					if($("##PageBreak").is(':checked')){
						var PageBreak=1;
					}
					else{
						var PageBreak=0;
					}
					window.open('../reports/DriverSettlementReport.cfm?&History=1&HistoryDate='+HistoryDate+'&PageBreak='+PageBreak+'&companyid=#session.CompanyID#&user=#session.adminusername#&#session.URLToken#');
				}
				else{
					alert('Please select a date.');
					$("##HistoryDate").focus();
				}
			})
			$('##RevertSettlement').click(function(){
				var path = urlComponentPath+"loadgateway.cfc?method=getLastSettlementDate&User=#session.empid#&dsn=#application.dsn#&CompanyID=#session.CompanyID#";
				$.ajax({
		          	type: "get",
		          	url: path,
		          	dataType: "json",
	          		success: function(data){
	          			console.log(data);
	          			if(data.SUCCESS == 0){
	                        alert('Something went wrong. Please try again later.')
	                    }
	                    else{
		          			if (confirm("Are you sure you want to reverse settlement from "+data.DATE+"?")) {
		          				$("##revDateF").val(data.DATEF);
		          				$("##revDate").val(data.DATE);
								$( "##revSubmit" ).click();
		                	}
		                }
	          		}
	      		});
			})


			$( "[type='datefield']" ).datepicker({
				dateFormat: "mm/dd/yy",
				showOn: "button",
				buttonImage: "images/DateChooser.png",
				buttonImageOnly: true,
				showButtonPanel: true
			}).datepicker('disable');

			$( ".datefieldN" ).datepicker({
				dateFormat: "mm/dd/yy",
				showOn: "button",
				buttonImage: "images/DateChooser.png",
				buttonImageOnly: true,
				showButtonPanel: true
			})

		})
	</script>
</cfoutput>