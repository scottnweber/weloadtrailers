<cfscript>
	variables.objequipmentGateway = getGateway("gateways.equipmentgateway", MakeParameters("dsn=#Application.dsn#,pwdExpiryDays=#Application.pwdExpiryDays#"));
	variables.objCutomerGateway = getGateway("gateways.customergateway", MakeParameters("dsn=#Application.dsn#,pwdExpiryDays=#Application.pwdExpiryDays#"));
</cfscript>
<cfsilent>
	<cfif session.currentusertype EQ 'Administrator' OR listFindNoCase(session.rightslist, "showAllOfficeLoads")>
		<cfinvoke component="#variables.objofficeGateway#" method="getAllOffices" sortby="officecode" sortorder="asc"  returnvariable="request.qOffices" />
	<cfelse>
		<cfinvoke component="#variables.objofficeGateway#" method="getAllOffices" sortby="officecode" officeid="#session.officeid#" sortorder="asc"  returnvariable="request.qOffices" />
	</cfif>
	<cfinvoke component="#variables.objloadGateway#" AuthLevelId="3" method="getSalesPerson" returnvariable="request.qDispatcher" />
	<cfinvoke component="#variables.objloadGateway#" method="getSystemSetupOptions" returnvariable="request.qGetSystemSetupOptions" />
	<cfinvoke component="#variables.objequipmentGateway#" method="getloadEquipments" returnvariable="request.qEquipments" />
	<cfinvoke component="#variables.objCutomerGateway#" method="getAllpayerCustomers" returnvariable="request.qryCustomersList" />
	<cfinvoke component="#variables.objAgentGateway#" method="getAllStaes" returnvariable="request.qstates"/>
	<cfinvoke component="#variables.objloadGateway#" method="getLoadStatus" returnvariable="request.qLoadStatus" />
	<cfif request.qGetSystemSetupOptions.freightBroker EQ 1>
		<cfset variables.freightBroker = "Carrier">
		<cfinvoke component="#variables.objCarrierGateway#" method="getAllCarriersForReport" IsCarrier="1" returnvariable="request.qCarrier"></cfinvoke>
	<cfelseif request.qGetSystemSetupOptions.freightBroker EQ 2>
		<cfset variables.freightBroker = "Carrier/Driver">
		<cfinvoke component="#variables.objCarrierGateway#" method="getAllCarriersForReport" returnvariable="request.qCarrier"></cfinvoke>
	<cfelse>
		<cfset variables.freightBroker = "Driver">
		<cfinvoke component="#variables.objCarrierGateway#" method="getAllCarriersForReport" IsCarrier="0" returnvariable="request.qCarrier"></cfinvoke>
	</cfif>
</cfsilent>

<cfoutput>
	<style type="text/css">
		.reportsSubHeading{
			border-bottom: 1px solid ##77463d !important;
			margin-bottom: 5px !important;
			margin-top: 20px !important;
		}
		.fromLabel{
			text-align: left !important;
    		margin-left: 10px !important;
    		width: 25px !important;
		}
		.toLabel{
			width:12px !important;
			text-align: left !important;
			margin-left: 10px !important;
		}
		input.fromInput{
			width:150px !important;
		}
		input.toInput{
			width:150px !important;
		}
		select.fromInput{
			width:156px !important;
			margin-right: 10px !important;
		}
		select.toInput{
			width:156px !important;
		}
		.fromInputDate{
			width:132px !important;
		}
		.toInputDate{
			width:132px !important;
		}
		.disAllowEditSelectBox {
			background: none repeat scroll 0 0 ##e3e3e3 !important;
			border: 1px solid ##c5c1c1 !important;
			color: ##434343 !important;
			pointer-events: none;
		}
	</style>
	<div class="white-con-area" style="height: 36px;background-color: ##82bbef;">
		<div style="float: left;"><h2 style="color:white;font-weight:bold;margin-left: 12px;">Reporting System</h2></div>
	</div>
	<div style="clear:left"></div>

	<div class="white-con-area">
		<div class="white-top"></div>
	    <div class="white-mid">
			<cfform name="frmCarrierQuoteReport" action="##" method="post">
				<div class="form-con" style="margin-bottom: 40px;">
					<fieldset>
						<div>
							<h2 class="reportsSubHeading">Load##</h2>
		            		<label class="fromLabel">From</label>
	                        <input class="fromInput" name="loadNoFrom" id="loadNoFrom" />
				        	<label class="toLabel">To</label>
	                        <input class="toInput" name="loadNoTo" id="loadNoTo"/> 
	                    </div>
	    				<div class="clear"></div>
	    				<cfset loadStatusFrom=request.qGetSystemSetupOptions.ARANDAPEXPORTSTATUSID>
						<cfset loadStatusTo=request.qGetSystemSetupOptions.ARANDAPEXPORTSTATUSID>
						<cfset isLoadStatusDefault=request.qGetSystemSetupOptions.IsLoadStatusDefaultForReport>	
						<cfif not isLoadStatusDefault>
							<cfquery name="qryGetStatusFrom" datasource="#application.dsn#">
								select StatusTypeID AS StatusID from LoadStatusTypes where StatusText='1. ACTIVE' and companyid = '#session.companyid#'
							</cfquery>
							<cfquery name="qryGetStatusTo" datasource="#application.dsn#">
								select StatusTypeID AS StatusID from LoadStatusTypes where StatusText='8. COMPLETED' and companyid = '#session.companyid#'
							</cfquery>
							<cfset loadStatusFrom=qryGetStatusFrom.StatusID>
							<cfset loadStatusTo=qryGetStatusTo.StatusID>
						</cfif>
						<div>
							<h2 class="reportsSubHeading">Load Status</h2>
				            <label class="fromLabel">From</label>			
				   			<select name="statusFrom" id="statusFrom" class="fromInput">
				   				<option value="0">Select</option>
								<cfloop query="request.qLoadStatus">
									<option data-statustext="#request.qLoadStatus.text#" value="#request.qLoadStatus.value#" <cfif loadStatusFrom EQ  request.qLoadStatus.value>selected="selected"</cfif>>#request.qLoadStatus.statusdescription#</option>
								</cfloop>
							</select>
							<label class="toLabel">To</label>				
				   			<select name="statusTo" id="statusTo" class="toInput">
				   				<option value="0">Select</option>
								<cfloop query="request.qLoadStatus">
									<option data-statustext="#request.qLoadStatus.text#" value="#request.qLoadStatus.value#" <cfif loadStatusTo EQ  request.qLoadStatus.value>selected="selected"</cfif>>#request.qLoadStatus.statusdescription#</option>
								</cfloop>
							</select>
						</div>
						<div class="clear"></div>	
						<div>
							<h2 style="margin-top:14px;" class="reportsSubHeading">#variables.freightBroker#</h2>
				            <label class="fromLabel">From</label>			
				   			<select name="carrierFrom" id="carrierFrom" class="fromInput">
								<option value="0">Select</option>
								<cfloop query="request.qCarrier">
									<option value="#request.qCarrier.carrierID#">#request.qCarrier.carriername#</option>
								</cfloop>
							</select>
							<label class="toLabel">To</label>					
				   			<select name="carrierTo" id="carrierTo" class="toInput">
								<option value="0">Select</option>
								<cfloop query="request.qCarrier">
									<option value="#request.qCarrier.carrierID#">#request.qCarrier.carriername#</option>
								</cfloop>
							</select>
						</div>
						<div class="clear"></div>
						<div>
							<h2 class="reportsSubHeading">MC Number</h2>
		            		<label class="fromLabel">From</label>
	                        <input class="fromInput" name="mcFrom" id="mcFrom"/>
				        	<label class="toLabel">To</label>
	                        <input class="toInput" name="mcTo" id="mcTo"/> 
	                    </div>
	                    <div class="clear"></div>
						<div>
							<h2 class="reportsSubHeading">Customer</h2>
				            <label class="fromLabel">From</label>			
				   			<select name="customerFrom" id="customerFrom" class="fromInput">
								<option value="0">Select</option>
								<cfloop query="request.qryCustomersList">
									<option value="#request.qryCustomersList.customerid#">#request.qryCustomersList.customername#</option>
								</cfloop>
							</select>
							<label class="toLabel">To</label>				
				   			<select name="customerTo" id="customerTo" class="toInput">
								<option value="0">Select</option>
								<cfloop query="request.qryCustomersList">
									<option value="#request.qryCustomersList.customerid#">#request.qryCustomersList.customername#</option>
								</cfloop>
							</select>
						</div>
						<div class="clear"></div>
						<div>
							<h2 class="reportsSubHeading">PO ##</h2>
		            		<label class="fromLabel">From</label>
	                        <input class="fromInput" name="poFrom" id="poFrom"/>
				        	<label class="toLabel">To</label>
	                        <input class="toInput" name="poTo" id="poTo"/> 
	                    </div>
	                    <div class="clear"></div>
						<div>
							<h2 class="reportsSubHeading">Equipment</h2>
				            <label class="fromLabel">From</label>			
				   			<select name="equipmentFrom" id="equipmentFrom" class="fromInput">
								<option value="0">Select</option>
								<cfloop query="request.qEquipments">
									<option value="#request.qEquipments.equipmentID#">#request.qEquipments.equipmentname#</option>
								</cfloop>
							</select>
							<label class="toLabel">To</label>				
				   			<select name="equipmentTo" id="equipmentTo" class="toInput">
								<option value="0">Select</option>
								<cfloop query="request.qEquipments">
									<option value="#request.qEquipments.equipmentID#">#request.qEquipments.equipmentname#</option>
								</cfloop>
							</select>
						</div>
						<div class="clear"></div>
						<div>
							<h2 class="reportsSubHeading">Office</h2>
				            <label class="fromLabel">From</label>	
				            <cfset fromToOfcClass="">
							<cfif NOT (session.currentusertype EQ "administrator" OR ListContains(session.rightsList,'showAllOfficeLoads',','))>
								<cfset fromToOfcClass="disAllowEditSelectBox">
							</cfif>		
				   			<select name="officeFrom" id="officeFrom" class="fromInput #fromToOfcClass#">
				   				<cfif session.currentusertype EQ 'Administrator' OR listFindNoCase(session.rightslist, "showAllOfficeLoads")>
									<option value="0">Select</option>
								</cfif>
								<cfloop query="request.qOffices">
									<option value="#request.qOffices.officecode#">#request.qOffices.officecode#</option>
								</cfloop>
							</select>
							<label class="toLabel">To</label>				
				   			<select name="officeTo" id="officeTo" class="toInput #fromToOfcClass#">
								<cfif session.currentusertype EQ 'Administrator' OR listFindNoCase(session.rightslist, "showAllOfficeLoads")>
									<option value="0">Select</option>
								</cfif>
								<cfloop query="request.qOffices">
									<option value="#request.qOffices.officecode#">#request.qOffices.officecode#</option>
								</cfloop>
							</select>
						</div>
						<div class="clear"></div>
						<div>
							<h2 class="reportsSubHeading">Dispatcher</h2>
				            <label class="fromLabel">From</label>			
				   			<select name="dispatcherFrom" id="dispatcherFrom" class="fromInput">
								<option value="0">Select</option>
				                <cfloop query="request.qDispatcher">
						        	<option value="#request.qDispatcher.EmployeeID#">#request.qDispatcher.Name#</option>
						        </cfloop>
							</select>
							<label class="toLabel">To</label>				
				   			<select name="dispatcherTo" id="dispatcherTo" class="toInput">
								<option value="0">Select</option>
				                <cfloop query="request.qDispatcher">
						        	<option value="#request.qDispatcher.EmployeeID#">#request.qDispatcher.Name#</option>
						        </cfloop>
							</select>
						</div>
					</fieldset>
				</div>
				<div class="form-con">
					<fieldset>	
		        		<div>
							<h2 class="reportsSubHeading">Pickup Date</h2>
		            		<label class="fromLabel">From</label>
		            		 <div style="float:left;">
		                        <input class="sm-input datefield fromInputDate" name="pickupDateFrom" id="pickupDateFrom" value="" type="datefield"/>
		                    </div>
				        	<label class="toLabel">To</label>
				        	<div style="float:left;">
		                        <input class="sm-input datefield toInputDate" name="pickupDateTo" id="pickupDateTo" value="" type="datefield"/> 
		                    </div>
	                    </div>
	                    <div class="clear"></div>
	    				<div>
							<h2 class="reportsSubHeading">Pickup City</h2>
		            		<label class="fromLabel">From</label>
	                        <input class="fromInput" name="pickupCityFrom" id="pickupCityFrom"/>
				        	<label class="toLabel">To</label>
	                        <input class="toInput" name="pickupCityTo" id="pickupCityTo"/> 
	                    </div>
	                    <div class="clear"></div>
	            		<div>
							<h2 class="reportsSubHeading">Pickup State</h2>
				            <label class="fromLabel">From</label>			
				   			<select name="pickupStateFrom" id="pickupStateFrom" class="fromInput">
								<option value="0">Select</option>
				                <cfloop query="request.qStates">
						        	<option value="#request.qStates.statecode#">#request.qStates.statecode#</option>
						        </cfloop>
							</select>
							<label class="toLabel">To</label>				
				   			<select name="pickupStateTo" id="pickupStateTo" class="toInput">
								<option value="0">Select</option>
				                <cfloop query="request.qStates">
						        	<option value="#request.qStates.statecode#">#request.qStates.statecode#</option>
						        </cfloop>
							</select>
						</div>
						<div class="clear"></div>
	    				<div>
							<h2 class="reportsSubHeading">Pickup Zip</h2>
		            		<label class="fromLabel">From</label>
	                        <input class="fromInput" name="pickupZipFrom" id="pickupZipFrom"/>
				        	<label class="toLabel">To</label>
	                        <input class="toInput" name="pickupZipTo" id="pickupZipTo"/> 
	                    </div>
	                    <div class="clear"></div>
	    				<div>
							<h2 class="reportsSubHeading">Delivery Date</h2>
		            		<label class="fromLabel">From</label>
		            		 <div style="float:left;">
		                        <input class="sm-input datefield fromInputDate" name="deliveryDateFrom" id="deliveryDateFrom" value="" type="datefield"/>
		                    </div>
				        	<label class="toLabel">To</label>
				        	<div style="float:left;">
		                        <input class="sm-input datefield toInputDate" name="deliveryDateTo" id="deliveryDateTo" value="" type="datefield"/> 
		                    </div>
	                    </div>
	    				<div class="clear"></div>
	    				<div>
							<h2 class="reportsSubHeading">Delivery City</h2>
		            		<label class="fromLabel">From</label>
	                        <input class="fromInput" name="deliveryCityFrom" id="deliveryCityFrom"/>
				        	<label class="toLabel">To</label>
	                        <input class="toInput" name="deliveryCityTo" id="deliveryCityTo"/> 
	                    </div>
	                    <div class="clear"></div>
	            		<div>
							<h2 class="reportsSubHeading">Delivery State</h2>
				            <label class="fromLabel">From</label>			
				   			<select name="deliveryStateFrom" id="deliveryStateFrom" class="fromInput">
								<option value="0">Select</option>
				                <cfloop query="request.qStates">
						        	<option value="#request.qStates.statecode#">#request.qStates.statecode#</option>
						        </cfloop>
							</select>
							<label class="toLabel">To</label>				
				   			<select name="deliveryStateTo" id="deliveryStateTo" class="toInput">
								<option value="0">Select</option>
				                <cfloop query="request.qStates">
						        	<option value="#request.qStates.statecode#">#request.qStates.statecode#</option>
						        </cfloop>
							</select>
						</div>
	    				<div class="clear"></div>
	    				<div>
							<h2 class="reportsSubHeading">Delivery Zip</h2>
		            		<label class="fromLabel">From</label>
	                        <input class="fromInput" name="deliveryZipFrom" id="deliveryZipFrom"/>
				        	<label class="toLabel">To</label>
	                        <input class="toInput" name="deliveryZipTo" id="deliveryZipTo"/> 
	                    </div>
	                    <div class="clear"></div>
	    				<div>
							<h2 class="reportsSubHeading">Carrier Total</h2>
		            		<label class="fromLabel">From</label>
	                        <input class="fromInput number" name="carrierTotalFrom" id="carrierTotalFrom"/>
				        	<label class="toLabel">To</label>
	                        <input class="toInput number" name="carrierTotalTo" id="carrierTotalTo"/> 
	                    </div>
	                    <div class="clear"></div>
	                    <div style="margin-top: 40px;margin-left: 75px;">
	                    	<input id="viewReport" type="button" name="view" class="bttn tooltip" value="View Report" style="width:95px;" onclick="generateReport(0)"/>
	                    	<input id="exportReport" type="button" name="export" class="bttn tooltip" value="Export" style="width:95px;"  onclick="generateReport(1)"/>
	                    </div>
					</fieldset>
	        		<div class="clear"></div>
			        <div id="message" class="msg-area" style="width:153px; margin-left:200px; display:none;"></div>
			        <div class="clear"></div>
				</div>
	   			<div class="clear"></div>
	 		</cfform>
	    </div>
		<div class="white-bot"></div>
	</div>

	<script type="text/javascript">
		$(document).ready(function(){
			$('.number').keypress(function(event) {
			    if(event.which == 8 || event.keyCode == 37 || event.keyCode == 39 || event.keyCode == 46) 
			        return true;
			    else if((event.which != 46 || $(this).val().indexOf('.') != -1) && (event.which < 48 || event.which > 57))
			        event.preventDefault();
			});
			$( "[type='datefield']" ).datepicker({
				dateFormat: "mm/dd/yy",
				showOn: "button",
				buttonImage: "images/DateChooser.png",
				buttonImageOnly: true
			});
		});		
		
		function generateReport(opt){
			var loadNoFrom = $.trim($('##loadNoFrom').val());
			var loadNoTo = $.trim($('##loadNoTo').val());
			var statusFrom = '';
			var statusTo = '';
			var carrierFrom = '';
			var carrierTo = '';
			var mcFrom = $.trim($('##mcFrom').val());
			var mcTo = $.trim($('##mcTo').val());
			var customerFrom = '';
			var customerTo = '';
			var poFrom = $.trim($('##poFrom').val());
			var poTo = $.trim($('##poTo').val());
			var equipmentFrom = '';
			var equipmentTo = '';
			var officeFrom = '';
			var officeTo = '';
			var dispatcherFrom = '';
			var dispatcherTo = '';
			var pickupDateFrom = $.trim($('##pickupDateFrom').val());
			var pickupDateTo = $.trim($('##pickupDateTo').val());
			var pickupCityFrom = $.trim($('##pickupCityFrom').val());
			var pickupCityTo = $.trim($('##pickupCityTo').val());
			var pickupStateFrom = '';
			var pickupStateTo = '';
			var deliveryDateFrom = $.trim($('##deliveryDateFrom').val());
			var deliveryDateTo = $.trim($('##deliveryDateTo').val());
			var deliveryCityFrom = $.trim($('##deliveryCityFrom').val());
			var deliveryCityTo = $.trim($('##deliveryCityTo').val());
			var deliveryStateFrom = '';
			var deliveryStateTo = '';
			var carrierTotalFrom = $.trim($('##carrierTotalFrom').val());
			var carrierTotalTo = $.trim($('##carrierTotalTo').val());
			var pickupZipFrom = $.trim($('##pickupZipFrom').val());
			var pickupZipTo = $.trim($('##pickupZipTo').val());
			var deliveryZipFrom = $.trim($('##deliveryZipFrom').val());
			var deliveryZipTo = $.trim($('##deliveryZipTo').val());

			if($('##statusFrom').val() != 0){
				var statusFrom = $('##statusFrom option:selected').data('statustext');
			}
			if($('##statusTo').val() != 0){
				var statusTo = $('##statusTo option:selected').data('statustext');
			}
			if($('##carrierFrom').val() != 0){
				var carrierFrom = $('##carrierFrom option:selected').html();
			}
			if($('##carrierTo').val() != 0){
				var carrierTo = $('##carrierTo option:selected').html();
			}
			if($('##equipmentFrom').val() != 0){
				var equipmentFrom = $('##equipmentFrom option:selected').html();
			}
			if($('##equipmentTo').val() != 0){
				var equipmentTo = $('##equipmentTo option:selected').html();
			}
			if($('##officeFrom').val() != 0){
				var officeFrom = $('##officeFrom option:selected').html();
			}
			if($('##officeTo').val() != 0){
				var officeTo = $('##officeTo option:selected').html();
			}
			if($('##customerFrom').val() != 0){
				var customerFrom = $('##customerFrom option:selected').html();
			}
			if($('##customerTo').val() != 0){
				var customerTo = $('##customerTo option:selected').html();
			}
			if($('##dispatcherFrom').val() != 0){
				var dispatcherFrom = $('##dispatcherFrom option:selected').html();
			}
			if($('##dispatcherTo').val() != 0){
				var dispatcherTo = $('##dispatcherTo option:selected').html();
			}
			if($('##pickupStateFrom').val() != 0){
				var pickupStateFrom = $('##pickupStateFrom option:selected').html();
			}
			if($('##pickupStateTo').val() != 0){
				var pickupStateTo = $('##pickupStateTo option:selected').html();
			}
			if($('##deliveryStateFrom').val() != 0){
				var deliveryStateFrom = $('##deliveryStateFrom option:selected').html();
			}
			if($('##deliveryStateTo').val() != 0){
				var deliveryStateTo = $('##deliveryStateTo option:selected').html();
			}
			var errFlag = 0;
			var url = '';
			if(loadNoFrom.length && !$.isNumeric(loadNoFrom)){
				errFlag=1;
				$('##loadNoFrom').focus();
				alert('LoadNumber Should Be Numeric');
			}
			if(loadNoTo.length && !$.isNumeric(loadNoTo)){
				errFlag=1;
				$('##loadNoTo').focus();
				alert('LoadNumber Should Be Numeric');
			}

			var reg =/((^(10|12|0?[13578])([/])(3[01]|[12][0-9]|0?[1-9])([/])((1[8-9]\d{2})|([2-9]\d{3}))$)|(^(11|0?[469])([/])(30|[12][0-9]|0?[1-9])([/])((1[8-9]\d{2})|([2-9]\d{3}))$)|(^(0?2)([/])(2[0-8]|1[0-9]|0?[1-9])([/])((1[8-9]\d{2})|([2-9]\d{3}))$)|(^(0?2)([/])(29)([/])([2468][048]00)$)|(^(0?2)([/])(29)([/])([3579][26]00)$)|(^(0?2)([/])(29)([/])([1][89][0][48])$)|(^(0?2)([/])(29)([/])([2-9][0-9][0][48])$)|(^(0?2)([/])(29)([/])([1][89][2468][048])$)|(^(0?2)([/])(29)([/])([2-9][0-9][2468][048])$)|(^(0?2)([/])(29)([/])([1][89][13579][26])$)|(^(0?2)([/])(29)([/])([2-9][0-9][13579][26])$))/;

			if(pickupDateFrom.length && !pickupDateFrom.match(reg)){
				errFlag=1;
				$('##pickupDateFrom').focus();
				alert('Please enter a valid pickup date');
			}
			if(pickupDateTo.length && !pickupDateTo.match(reg)){
				errFlag=1;
				$('##pickupDateTo').focus();
				alert('Please enter a valid pickup date');
			}
			if(deliveryDateFrom.length && !deliveryDateFrom.match(reg)){
				errFlag=1;
				$('##deliveryDateFrom').focus();
				alert('Please enter a valid delivery date');
			}
			if(deliveryDateTo.length && !deliveryDateTo.match(reg)){
				errFlag=1;
				$('##deliveryDateTo').focus();
				alert('Please enter a valid delivery date');
			}

			if(errFlag == 0){
				url += '&loadNoFrom='+loadNoFrom;
				url += '&loadNoTo='+loadNoTo;
				url += '&statusFrom='+encodeURIComponent(statusFrom);
				url += '&statusTo='+encodeURIComponent(statusTo);
				url += '&carrierFrom='+encodeURIComponent(carrierFrom);
				url += '&carrierTo='+encodeURIComponent(carrierTo);
				url += '&mcFrom='+encodeURIComponent(mcFrom);
				url += '&mcTo='+encodeURIComponent(mcTo);
				url += '&customerFrom='+encodeURIComponent(customerFrom);
				url += '&customerTo='+encodeURIComponent(customerTo);
				url += '&poFrom='+encodeURIComponent(poFrom);
				url += '&poTo='+encodeURIComponent(poTo);
				url += '&equipmentFrom='+encodeURIComponent(equipmentFrom);
				url += '&equipmentTo='+encodeURIComponent(equipmentTo);
				url += '&officeFrom='+encodeURIComponent(officeFrom);
				url += '&officeTo='+encodeURIComponent(officeTo);
				url += '&dispatcherFrom='+encodeURIComponent(dispatcherFrom);
				url += '&dispatcherTo='+encodeURIComponent(dispatcherTo);
				url += '&pickupDateFrom='+encodeURIComponent(pickupDateFrom);
				url += '&pickupDateTo='+encodeURIComponent(pickupDateTo);
				url += '&pickupCityFrom='+encodeURIComponent(pickupCityFrom);
				url += '&pickupCityTo='+encodeURIComponent(pickupCityTo);
				url += '&pickupStateFrom='+encodeURIComponent(pickupStateFrom);
				url += '&pickupStateTo='+encodeURIComponent(pickupStateTo);
				url += '&deliveryDateFrom='+encodeURIComponent(deliveryDateFrom);
				url += '&deliveryDateTo='+encodeURIComponent(deliveryDateTo);
				url += '&deliveryCityFrom='+encodeURIComponent(deliveryCityFrom);
				url += '&deliveryCityTo='+encodeURIComponent(deliveryCityTo);
				url += '&deliveryStateFrom='+encodeURIComponent(deliveryStateFrom);
				url += '&deliveryStateTo='+encodeURIComponent(deliveryStateTo);
				url += '&carrierTotalFrom='+encodeURIComponent(carrierTotalFrom);
				url += '&carrierTotalTo='+encodeURIComponent(carrierTotalTo);
				url += '&pickupZipFrom='+encodeURIComponent(pickupZipFrom);
				url += '&pickupZipTo='+encodeURIComponent(pickupZipTo);
				url += '&deliveryZipFrom='+encodeURIComponent(deliveryZipFrom);
				url += '&deliveryZipTo='+encodeURIComponent(deliveryZipTo);

				if(opt == 1){
					url += '&export=1';
				}
				url += '&#session.urltoken#';
				window.open('../reports/carrierQuoteReport.cfm?'+url)
			}
		}
	</script>
</cfoutput>