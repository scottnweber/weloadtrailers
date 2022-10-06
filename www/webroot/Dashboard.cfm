<cfoutput>
	<style type="text/css">
		.reportsSubHeading{
			color: ##7e7e7e;
		    padding-bottom: 10px;
		    margin: 0;
		    font-size: 18px;
		    font-weight: normal;
		    border-bottom: 1px solid ##77463d !important;
		    text-align: left;
		}
		.subLabel{
			font-size: 12px !important;
		    font-weight: bold !important;
		    width: 117px !important;
		}
		.white-con-area,.white-mid {
    		width: 100%;
		}
		.data-table thead tr th:first-child{
  			border-left: 1px solid ##5d8cc9;border-top-left-radius: 5px;
		}
		.data-table tbody tr td:first-child{
  			border-left: 1px solid ##5d8cc9
		}
		.data-table thead tr th:last-child{
  			border-right: 1px solid ##5d8cc9;border-top-right-radius: 5px;
		}
		.data-table tbody tr td:last-child{
  			border-right: 1px solid ##5d8cc9;
		}
		.data-table tbody tr td{
  			padding-right: 2px;
		}
		.disabledSelect{
			pointer-events: none;
			opacity: 0.5;
		}
		.disabledInput{
			opacity: 0.5;
		}
		.white-mid form div.form-con fieldset input.bttn{ 
			background:url(./images/button-bg.gif) left top repeat;
			border:1px solid ##b3b3b3;
			padding:0 10px 0 10px;
			height:20px;
			font-size:11px;
			font-weight:bold;
			line-height:20px;
			text-align:center;
			margin:0 10px 8px 0;
			cursor:pointer;
		}
	</style>
	<cfset AuthLevel = "Sales Representative,Manager,Dispatcher,Administrator,Central Dispatcher">
	<cfinvoke component="#variables.objloadGateway#" AuthLevelId="Dispatcher" method="getSalesPerson" returnvariable="request.qDispatcher" />
    <cfinvoke component="#variables.objloadGateway#" AuthLevel="#AuthLevel#" method="getloadSalesPerson" includeInactive="1" returnvariable="request.qSalesPerson" />
	<cfinvoke component="#variables.objloadGateway#" AuthLevelId="Sales Representative,Dispatcher" method="getSalesPerson" returnvariable="request.qSalesPerson" />
    <cfinvoke component="#variables.objloadGateway#" method="getLoadStatus" returnvariable="request.qLoadStatus" /> 
	<div class="white-con-area" style="height: 36px;background-color: ##82bbef;">
		<div style="float: left;">
			<h2 style="color:white;font-weight:bold;margin-left: 12px;">PERFORMANCE DASHBOARD</h2>
		</div>
		
		<cfif structKeyExists(session, "dashboardUser") and session.dashboardUser eq 1>
			<div style="float: right;margin-right: 10px;padding-top: 5px;"><a id="logout" href="index.cfm?event=logout:process&#Session.URLToken#">Logout</a></div>
		</cfif>

	</div>
	<div style="clear:left"></div>
	<div class="white-con-area">
		<div class="white-top"></div>
	    <div class="white-mid" style="padding-bottom: 50px;">
			<form name="frmCommissionReport" action="##" method="post">
				<div class="form-con dasboardDataTable" style="width: 440px;">
					<fieldset>
						<table cellpadding="0" cellspacing="0">
							<thead>
								<tr>
									<th class="reportsSubHeading" style="border-right: 1px solid ##77463d;">Group By</th>
									<th class="reportsSubHeading" style="padding-left: 10px;width: 300px;">Options:</th>
								</tr>
							</thead>
							<tbody>
								<tr>
									<td valign="top" style="padding-top: 20px;border-right: 1px solid ##77463d;">
										<input type="radio" name="groupBy" value="none" id="none" checked="yes" style="width:15px; padding:0px 0px 0 0px;margin-bottom:15px;"/>
			                			<label class="normal" for="none" style="text-align:left; padding:0 0 0 0;width: 90px;">Month</label>
			                			<div class="clear"></div>
			                			<cfif not ListContains(session.rightsList,'SalesRepReport',',')>
				                			<input type="radio" name="groupBy" value="salesagent" id="salesagent" style="width:15px; padding:0px 0px 0 0px;margin-bottom:15px;"/>
				                			<label class="normal" for="salesagent" style="text-align:left; padding:0 0 0 0;width: 90px;">Sales Rep</label>
				                			<div class="clear"></div>
				                			<input type="radio" name="groupBy" value="dispatcher" id="dispatcher" style="width:15px; padding:0px 0px 0 0px;margin-bottom:15px;"/>
				                			<label class="normal" for="dispatcher" style="text-align:left; padding:0 0 0 0;width: 90px;">Dispatcher</label>
				                			<div class="clear"></div>
				                		</cfif>
			                			<input type="radio" name="groupBy" value="customer" id="customer" style="width:15px; padding:0px 0px 0 0px;margin-bottom:15px;"/>
			                			<label class="normal" for="customer" style="text-align:left; padding:0 0 0 0;width: 90px;">Customer</label>
			                			<div class="clear"></div>
			                			<input type="radio" name="groupBy" value="carrier" id="carrier" style="width:15px; padding:0px 0px 0 0px;margin-bottom:15px;"/>
			                			<label class="normal" for="carrier" style="text-align:left; padding:0 0 0 0;width: 90px;"><cfif request.qsystemsetupoptions1.freightBroker EQ 1>Carrier<cfelseif request.qsystemsetupoptions1.freightBroker EQ 2>Carrier/Driver<cfelse>Driver</cfif></label>
									</td>
									<td valign="top">
										<table cellspacing="0" cellpadding="0" width="100%">
											<tr>
												<td align="right" style="padding-right: 12px;padding-top: 10px;">
													<label class="subLabel" style="width: 78px !important;float: none;padding-right: 17px;">Preset Dates:</label>
													<div class="clear"></div>
													<select name="period" id="period" style="width: 94px;float: none;" onchange="calculatePeriod()">
														<option value="custom">CUSTOM</option>
														<option value="thisweek">THIS WEEK</option>
														<option value="lastweek">LAST WEEK</option>
														<option value="thismonth">THIS MONTH</option>
														<option value="lastmonth">LAST MONTH</option>
														<option value="thisyear" selected>THIS YEAR</option>
														<option value="lastyear">LAST YEAR</option>
													</select>
												</td>
												<td style="padding-top: 10px;">
													<input type="radio" name="dateType" value="NewPickupDate" id="NewPickupDate" checked="yes" style="width:15px; padding:0px 0px 0 0px;margin-left: 10px;margin-bottom: 0;"/>
													<label class="space_it" style="width: 70px;text-align: left;">Pickup Date</label>
													<div class="clear"></div>
													<input type="radio" name="dateType" value="NewDeliveryDate" id="NewDeliveryDate" style="width:15px; padding:0px 0px 0 0px;margin-left: 10px;margin-bottom: 0;"/>
													<label class="space_it" style="width: 70px;text-align: left;">Delivery Date</label>
												</td>
											</tr>
											<tr>
												<td style="padding-top: 10px;">
													<label class="space_it" style="width: 50px;">From</label>
													<input class="sm-input datefield" tabindex=4 name="dateFrom"id="dateFrom"  value="" type="datefield"/>
												</td>
												<td style="padding-top: 10px;">
													<label class="space_it" style="width: 29px;">To</label>
													<input class="sm-input datefield" tabindex=4 name="dateTo"id="dateTo"  value="" type="datefield" />
												</td>
											</tr>
											<tr>
												<td style="border-top: 1px solid ##c8c4c4;padding-top: 10px;padding-bottom: 10px;">
													<label style="width: 50px;">From</label>
													<select name="statusFrom" id="statusFrom" style="width: 94px;">
														<cfloop query="request.qLoadStatus">
															<option value="#request.qLoadStatus.Text#" <cfif request.qLoadStatus.Text EQ '5. DELIVERED'> selected </cfif>>#request.qLoadStatus.StatusDescription#</option>
														</cfloop>
													</select>
												</td>
												<td style="border-top: 1px solid ##c8c4c4;padding-top: 10px;padding-bottom: 10px;">
													<label style="width: 29px;">To</label>
													<select name="statusTo" id="statusTo" style="width: 94px;">
														<cfloop query="request.qLoadStatus">
															<option value="#request.qLoadStatus.Text#" <cfif request.qLoadStatus.Text EQ '8. COMPLETED'> selected </cfif>>#request.qLoadStatus.StatusDescription#</option>
														</cfloop>
													</select>
												</td>
											</tr>
											<tr>
												<td colspan="2" style="border-top: 1px solid ##c8c4c4;padding-top: 10px;;padding-bottom: 10px;">
													<label style="width: 100px;">Dispatcher</label>
													<select name="DispatcherID" id="DispatcherID" style="width: 150px;">
														<cfif structKeyExists(session, "currentusertype") AND session.currentusertype eq 'Dispatcher'>
															<cfloop query="request.qDispatcher">
																<cfif request.qDispatcher.EmployeeID EQ session.empid>
																	<cfset opt = request.qDispatcher.Name>
																	<cfif len(trim(request.qDispatcher.address))>
																		<cfset opt = opt&", ADDRESS: "&request.qDispatcher.address>
																	</cfif>
																	<cfif len(trim(request.qDispatcher.city))>
																		<cfset opt = opt&", CITY: "&request.qDispatcher.city>
																	</cfif>
																	<cfif len(trim(request.qDispatcher.state))>
																		<cfset opt = opt&", STATE: "&request.qDispatcher.state>
																	</cfif>
																	<cfif len(trim(request.qDispatcher.telephone))>
																		<cfset opt = opt&", Phone##: "&request.qDispatcher.telephone>
																	</cfif>
																	<option value="#request.qDispatcher.EmployeeID#">#opt#</option>
																</cfif>
															</cfloop>	
														<cfelse>
															<option value="">Select</option>
															<cfloop query="request.qDispatcher">
																<cfset opt = request.qDispatcher.Name>
																<cfif len(trim(request.qDispatcher.address))>
																	<cfset opt = opt&", ADDRESS: "&request.qDispatcher.address>
																</cfif>
																<cfif len(trim(request.qDispatcher.city))>
																	<cfset opt = opt&", CITY: "&request.qDispatcher.city>
																</cfif>
																<cfif len(trim(request.qDispatcher.state))>
																	<cfset opt = opt&", STATE: "&request.qDispatcher.state>
																</cfif>
																<cfif len(trim(request.qDispatcher.telephone))>
																	<cfset opt = opt&", Phone##: "&request.qDispatcher.telephone>
																</cfif>
																<option value="#request.qDispatcher.EmployeeID#"  dname="#request.qDispatcher.Name#">#opt#</option>
															</cfloop>
														</cfif>	
													</select>
												</td>
											</tr>
											<tr>
												<td colspan="2" align="center" style="font-weight: bold;font-size: 14px;">OR</td>
											</tr>
											<tr>
												<td colspan="2" style="padding-top: 10px;;padding-bottom: 10px;">
													<label style="width:100px;">Sales Rep</label>
													<select name="SalesRep" id="SalesRep" style="width: 150px;">
														<cfif (structKeyExists(session, "currentusertype") AND session.currentusertype eq 'Sales Representative') OR ListContains(session.rightsList,'SalesRepReport',',')>
															<cfloop query="request.qSalesPerson">
																<cfif request.qSalesPerson.EmployeeID EQ session.empid>
																	<cfset opt = request.qSalesPerson.Name>
																   <cfif len(trim(request.qSalesPerson.address))>
																	   <cfset opt = opt&", ADDRESS: "&request.qSalesPerson.address>
																   </cfif>
																   <cfif len(trim(request.qSalesPerson.city))>
																	   <cfset opt = opt&", CITY: "&request.qSalesPerson.city>
																   </cfif>
																   <cfif len(trim(request.qSalesPerson.state))>
																	   <cfset opt = opt&", STATE: "&request.qSalesPerson.state>
																   </cfif>
																   <cfif len(trim(request.qSalesPerson.telephone))>
																	   <cfset opt = opt&", Phone##: "&request.qSalesPerson.telephone>
																   </cfif>
																   <option value="#request.qSalesPerson.EmployeeID#">#opt#</option>
															   </cfif>
														   </cfloop>
														<cfelse>
															<option value="">Select</option>
														   <cfloop query="request.qSalesPerson">
															   <cfset opt = request.qSalesPerson.Name>
															   <cfif len(trim(request.qSalesPerson.address))>
																   <cfset opt = opt&",ADDRESS:"&request.qSalesPerson.address>
															   </cfif>
															   <cfif len(trim(request.qSalesPerson.city))>
																   <cfset opt = opt&",CITY:"&request.qSalesPerson.city>
															   </cfif>
															   <cfif len(trim(request.qSalesPerson.state))>
																   <cfset opt = opt&",STATE:"&request.qSalesPerson.state>
															   </cfif>
															   <cfif len(trim(request.qSalesPerson.telephone))>
																   <cfset opt = opt&",Phone##:"&request.qSalesPerson.telephone>
															   </cfif>
															   <option value="#request.qSalesPerson.EmployeeID#">#opt#</option>
														   </cfloop>
														</cfif>
													</select>
												</td>
											</tr>
											<tr>
												<td colspan="2" style="border-top: 1px solid ##c8c4c4;padding-top: 20px;">
													<label class="subLabel" style="width: 70px !important;">PIE CHART</label>
													<select name="piechart" id="piechart" style="width: 94px;">
														<option value="1" <cfif request.qsystemsetupoptions1.showdashboard EQ 1> selected </cfif>>Sales</option>
														<option value="2" <cfif request.qsystemsetupoptions1.showdashboard EQ 2> selected </cfif>>Profit</option>
														<option value="3" <cfif request.qsystemsetupoptions1.showdashboard EQ 3> selected </cfif>>Loads</option>
													</select>
													<input onclick="updateChart()" id="sReport" type="button" name="viewReport" class="bttn tooltip" value="APPLY" style="width: 110px !important;height: 35px;background-size: contain;margin-left: 12px;">
												</td>
											</tr>
										</table>
									</td>
								</tr>
							</tbody>
						</table>
					</fieldset>
					<div class="clear"></div>
					<table id="myTable" border="0" width="100%" class="data-table" cellspacing="0" cellpadding="0" style="color:##000000;margin-top: 20px;">
						<thead>
      						<tr>
    							<th align="center" valign="middle" class="head-bg" id="LabelHead" onclick="sortTable(0)">Month</th>
    							<th align="center" valign="middle" class="head-bg" onclick="sortTable(1)">Sales</th>
    							<th align="center" valign="middle" class="head-bg" onclick="sortTable(2)">Profit $</th>
    							<th align="center" valign="middle" class="head-bg" onclick="sortTable(3)">Profit %</th>
    							<th align="center" valign="middle" class="head-bg" onclick="sortTable(4)">Loads</th>
      						</tr>
      					</thead>
      					<tbody>
      						
      					</tbody>
      					<tfoot>
					    	<tr>
					    		<td colspan="5" align="left" valign="middle" class="footer-bg" style="border-left: 1px solid ##5d8cc9;border-right: 1px solid ##5d8cc9;border-bottom-left-radius: 5px;;border-bottom-right-radius: 5px;">
					    			<div class="gen-right"><img src="images/loader.gif" alt=""></div>
					    			<div class="clear"></div>
					    		</td>
					    	</tr>	
					   	</tfoot>
					</table>
				</div>
				<div class="form-con dashboardPieChart" style="width: 500px;">
					<canvas id="myChart" style="background-color: ##fff;border: solid 2px ##ccd5ff;padding:5px"></canvas>

				</div>
	   			<div class="clear"></div>
	 		</form>
	    </div>
		<div class="white-bot"></div>
	</div>
	
	<script src="https://cdnjs.cloudflare.com/ajax/libs/Chart.js/3.6.0/chart.min.js"></script>
	<script src="https://cdn.jsdelivr.net/npm/chartjs-plugin-datalabels@2.0.0"></script>
	<script type="text/javascript">
		$(document).ready(function(){
			$( "[type='datefield']" ).datepicker({
			  dateFormat: "mm/dd/yy",
			  showOn: "button",
			  buttonImage: "images/DateChooser.png",
			  buttonImageOnly: true,
			   showButtonPanel: true
			});
			$( ".datefield" ).datepicker( "option", "showButtonPanel", true );
                var old_goToToday = $.datepicker._gotoToday
                $.datepicker._gotoToday = function(id) {
                 old_goToToday.call(this,id)
                 this._selectDate(id)
            }
            calculatePeriod()
            setInterval(function(){
			    updateChart();
			},3600000)
            updateChart();

            // Customer Auto
		    $('##filterBycustomer').each(function(i, tag) {
		        $(tag).autocomplete({
		            multiple: false,
		            width: 400,
		            scroll: true,
		            scrollHeight: 300,
		            cacheLength: 1,
		            highlight: false,
		            dataType: "json",
		            autoFocus: true,
		            source: 'searchCustomersAutoFill.cfm?queryType=getCustomers&CompanyID=#session.CompanyID#',
		            select: function(e, ui) {
		                $(this).val(ui.item.name);
		                $(this).attr('data-customerid',ui.item.value);
		                return false;
		            }
		        });
		        $(tag).data("ui-autocomplete")._renderItem = function(ul, item) {
		            return $( "<li>"+item.name+"</li>" ).appendTo( ul );
		        }
		    });

		    // Carrier Auto
		    $('##filterBycarrier').each(function(i, tag) {
		        $(tag).autocomplete({
		            multiple: false,
		            width: 450,
		            scroll: true,
		            scrollHeight: 300,
		            cacheLength: 1,
		            highlight: false,
		            dataType: "json",
		            source: 'ajax.cfm?event=getDashBoardCarrierAuto',
		            select: function(e, ui) { 
		                $(this).val(ui.item.name);
		                $(this).attr('data-carrierid',ui.item.value);
		                return false;
		            }
		        });
		        $(tag).data("ui-autocomplete")._renderItem = function(ul, item) {
		            return $( "<li>"+item.name+"</li>").appendTo( ul );
		        }
		    });
		    
		});		
	</script>
	<script>
		function sortTable(n) {
			var tfoot = $('##myTable tfoot').html();
			var GroupBy = $("input[name='groupBy']:checked").val();
			$('##myTable tfoot').remove();
		  	var table, rows, switching, i, x, y, shouldSwitch, dir, switchcount = 0;
		  	table = document.getElementById("myTable");
		  	switching = true;
		  	//Set the sorting direction to ascending:
		  	dir = "asc"; 
		  	/*Make a loop that will continue until
		  	no switching has been done:*/
		  	while (switching) {
		    	//start by saying: no switching is done:
		    	switching = false;
		    	rows = table.rows;
		    	/*Loop through all table rows (except the
		    	first, which contains table headers):*/
		    	for (i = 1; i < (rows.length - 1); i++) {
		      		//start by saying there should be no switching:
		      		shouldSwitch = false;
		      		/*Get the two elements you want to compare,
		      		one from current row and one from the next:*/
		      		x = rows[i].getElementsByTagName("TD")[n];
		      		y = rows[i + 1].getElementsByTagName("TD")[n];
		      		/*check if the two rows should switch place,
		      		based on the direction, asc or desc:*/
		      		if (dir == "asc") {
		      			var xHtml = x.innerHTML.toLowerCase();
		      			var yHtml = y.innerHTML.toLowerCase();
		      			if(n!=0){
		      				xHtml = parseFloat(xHtml.replace("$","").replace(/,/g,""));
		      				yHtml = parseFloat(yHtml.replace("$","").replace(/,/g,""));
		      			}
		      			else if(n==0 && GroupBy=='none'){
		      				xHtml = new Date(Date.parse(xHtml +" 1, 2021")).getMonth()+1;
		      				yHtml = new Date(Date.parse(yHtml +" 1, 2021")).getMonth()+1;
		      			}
		        		if (xHtml > yHtml) {
		          			//if so, mark as a switch and break the loop:
		          			shouldSwitch= true;
		          			break;
		        		}
		      		} 
		      	else if (dir == "desc") {
		      			var xHtml = x.innerHTML.toLowerCase();
		      			var yHtml = y.innerHTML.toLowerCase();
		      			if(n!=0){
		      				xHtml = parseFloat(xHtml.replace("$","").replace(/,/g,""));
		      				yHtml = parseFloat(yHtml.replace("$","").replace(/,/g,""));
		      			}
		      			else if(n==0 && GroupBy=='none'){
		      				xHtml = new Date(Date.parse(xHtml +" 1, 2021")).getMonth()+1;
		      				yHtml = new Date(Date.parse(yHtml +" 1, 2021")).getMonth()+1;
		      			}
			        	if (xHtml < yHtml) {
			          	//if so, mark as a switch and break the loop:
			          	shouldSwitch = true;
			          	break;
			        	}
			      	}
		    	}
			    if (shouldSwitch) {
			      	/*If a switch has been marked, make the switch
			      	and mark that a switch has been done:*/
			      	rows[i].parentNode.insertBefore(rows[i + 1], rows[i]);
			      	switching = true;
			      	//Each time a switch is done, increase this count by 1:
			      	switchcount ++;      
			    } 
			    else {
			      	/*If no switching has been done AND the direction is "asc",
			      	set the direction to "desc" and run the while loop again.*/
			      	if (switchcount == 0 && dir == "asc") {
			        	dir = "desc";
			        	switching = true;
			      	}
			    }
		  	}
		  	$('##myTable').append('<tfoot>'+tfoot+'</tfoot>');
		}

		function getFormattedDate(date) {
  			var year = date.getFullYear();
  			var month = (1 + date.getMonth()).toString();
  			month = month.length > 1 ? month : '0' + month;
  			var day = date.getDate().toString();
  			day = day.length > 1 ? day : '0' + day;
  			return month + '/' + day + '/' + year;
		}

		function calculatePeriod(){
			var val = $('##period').val();
				if(val!='custom'){
				if(val=='thisweek'){
					var currentDay = new Date;
					var firstDay = new Date(currentDay.setDate(currentDay.getDate() - currentDay.getDay()));
					var lastDay = new Date;
				}
				else if(val=='lastweek'){
					var currentDay = new Date;
					var firstDay = new Date(currentDay.setDate(currentDay.getDate() - currentDay.getDay()-7));
					var lastDay = new Date(currentDay.setDate(currentDay.getDate() - currentDay.getDay()+6));
				}
				else if(val=='thismonth'){
					var currentDay = new Date; 
					var lastDay = new Date(currentDay.getFullYear(), currentDay.getMonth() + 1, 0);
					var firstDay = new Date(currentDay.setDate(1));
					
				}
				else if(val=='lastmonth'){
					var date = new Date();
					var firstDay = new Date(date.getFullYear(), date.getMonth()-1, 1);
					var lastDay = new Date(date.getFullYear(), date.getMonth(), 0);
				}
				else if(val=='thisyear'){
					var firstDay = new Date(new Date().getFullYear(), 0, 1);
					var lastDay = new Date(new Date().getFullYear(), 11, 31);
				}
				else if(val=='lastyear'){
					var firstDay = new Date(new Date().getFullYear()-1, 0, 1);
					var lastDay = new Date(new Date().getFullYear()-1, 11, 31);
	    			
				}
				$('##dateFrom').val(getFormattedDate(firstDay));
				$('##dateTo').val(getFormattedDate(lastDay));
			}
		}

		function getRandomColor() {
		    var letters = '0123456789ABCDEF'.split('');
		    var arrColor =[];
		    for(var k=1;k<50;k++){
		    	var color = '##';
		    	for (var i = 0; i < 6; i++) {
			        color += letters[Math.floor(Math.random() * 16)];
			    }
			    arrColor.push(color);
		    }
		    return arrColor;
		}
		function updateChart(){

			if(!checkdate()){
                return false;
            }

			var GroupBy = $("input[name='groupBy']:checked").val();
			var piechart = $('##piechart').val();
			var dateFrom = $('##dateFrom').val();
			var dateTo = $('##dateTo').val();
			var statusFrom = $('##statusFrom').val();
			var statusTo = $('##statusTo').val();
			var Dispatcher = $('##DispatcherID').val();
			var SalesRep = $('##SalesRep').val();
			var DateType = $("input[name='dateType']:checked").val();

        	if(piechart==1){
        		var totalField = 'Sales';
        	}
        	else if(piechart==2){
        		var totalField = 'Profit';
        	}
        	else{
        		var totalField = 'LoadCount';
        	}
			$.ajax({
                type    : 'POST',
                url     : "ajax.cfm?event=updateDashboardChart",
                data    : {GroupBy:GroupBy,dateFrom:dateFrom,dateTo:dateTo,totalField:totalField,statusFrom:statusFrom,statusTo:statusTo,Dispatcher:Dispatcher,SalesRep:SalesRep,DateType:DateType},
                beforeSend:function() {
                    $('.data-table tbody').html('<td colspan="5" align="center" valign="middle" class="footer-bg" style="border-left: 1px solid ##5d8cc9;border-right: 1px solid ##5d8cc9;border-bottom-left-radius: 5px;;border-bottom-right-radius: 5px;"><img src="images/loadDelLoader.gif" style="margin-top: 25px;"></td>');
                },
                success :function(response){
                	var respData = jQuery.parseJSON(response);

                	myChart.data.labels = [];
                	myChart.data.datasets[0].data = [];
                	myChart.data.Clabels = [];

                	myChart.options.plugins.title.text= $("##piechart option:selected").text();;
                	$('.data-table tbody').html('');
                	var currRow = 1;
                	var otherPerc = 0;
                	var otherValue = 0;
                	var otherCount = 0;
                    $.each(respData, function( index, item ) {
                		if(piechart==1){
                			var currValue = parseFloat(item.Sales.replace("$","").replace(/,/g,""));
			        		if(item.Value.toFixed(2)>2.5){
	                			myChart.data.labels.push(item.Label.substring(0,10));
	                			myChart.data.datasets[0].data.push(item.Value.toFixed(2));
				        		myChart.data.Clabels.push(item.Sales);
			        		}
			        		else{
			        			if(!isNaN(currValue)){
			        				otherCount++;
			        				otherLabel = item.Label;
			        				otherPerc = otherPerc + item.Value;
			        				otherValue = otherValue + currValue;
			        			}
			        		}
			        	}
			        	else if(piechart==2){
			        		
			        		var currValue = parseFloat(item.Profit.replace("$","").replace(/,/g,""));
			        		if(currValue<0){
			        			currValue = 0;
			        		}
			        		if(item.Value.toFixed(2)>2.5){
				        		myChart.data.labels.push(item.Label.substring(0,10));
	                			myChart.data.datasets[0].data.push(item.Value.toFixed(2));
				        		myChart.data.Clabels.push(item.Profit);
			        		}
			        		else{
			        			if(!isNaN(currValue)){
			        				otherCount++;
			        				otherLabel = item.Label;
			        				otherPerc = otherPerc + item.Value;
			        				otherValue = otherValue + currValue;
			        			}
			        		}
			        	}
			        	else{
			        		var currValue = item.LoadCount;

			        		if(item.Value.toFixed(2)>2.5){
			        			myChart.data.labels.push(item.Label.substring(0,10));
	                			myChart.data.datasets[0].data.push(item.Value.toFixed(2));
				        		myChart.data.Clabels.push(item.LoadCount);
			        		}
			        		else{
			        			if(!isNaN(currValue)){
			        				otherCount++;
			        				otherLabel = item.Label;
			        				otherPerc = otherPerc + item.Value;
			        				otherValue = otherValue + currValue;
			        			}
			        		}
            				
			        	}
                    	if(currRow%2 == 0){
                    		var bgColor = '##FFFFFF';
                    	}
                    	else{
							var bgColor = '##f7f7f7';
                    	}
                    	var trData = '<tr bgcolor="'+bgColor+'"><td  align="left" valign="middle"  class="normal-td">'+item.Label+'</td><td  align="right" valign="middle"  class="normal-td">'+item.Sales+'</td><td  align="right" valign="middle"  class="normal-td">'+item.Profit+'</td><td  align="right" valign="middle"  class="normal-td">'+item.ProfitPerc.toFixed(2)+'%</td><td  align="right" valign="middle" " class="normal-td">'+item.LoadCount+'</td></tr>';
						$('.data-table tbody').append(trData);
						currRow++;
					});

                    if(otherValue>0){
                    	if(otherCount==1){
                    		myChart.data.labels.push(otherLabel);
                    	}
                    	else{
                    		myChart.data.labels.push('Other');
                    	}
                    	
            			myChart.data.datasets[0].data.push(otherPerc.toFixed(2));
            			if(piechart==1 || piechart==2){
		        			myChart.data.Clabels.push(formatDollar(otherValue));
		        		}
		        		else{
		        			myChart.data.Clabels.push(otherValue);
		        		}
                    }

					if($('label[for="'+GroupBy+'"]').html()=='None')
						$('##LabelHead').html('Month');
					else
						$('##LabelHead').html($('label[for="'+GroupBy+'"]').html());
					myChart.update();
                }
            })
			
		}
		/*const legendMargin ={
			id:'legendMargin',
			beforeDraw(chart,args,options){
				console.log(options)
			}
		}*/
		function checkdate(){
            var reg =/((^(10|12|0?[13578])([/])(3[01]|[12][0-9]|0?[1-9])([/])((1[8-9]\d{2})|([2-9]\d{3}))$)|(^(11|0?[469])([/])(30|[12][0-9]|0?[1-9])([/])((1[8-9]\d{2})|([2-9]\d{3}))$)|(^(0?2)([/])(2[0-8]|1[0-9]|0?[1-9])([/])((1[8-9]\d{2})|([2-9]\d{3}))$)|(^(0?2)([/])(29)([/])([2468][048]00)$)|(^(0?2)([/])(29)([/])([3579][26]00)$)|(^(0?2)([/])(29)([/])([1][89][0][48])$)|(^(0?2)([/])(29)([/])([2-9][0-9][0][48])$)|(^(0?2)([/])(29)([/])([1][89][2468][048])$)|(^(0?2)([/])(29)([/])([2-9][0-9][2468][048])$)|(^(0?2)([/])(29)([/])([1][89][13579][26])$)|(^(0?2)([/])(29)([/])([2-9][0-9][13579][26])$))/;
                
            if($('##dateFrom').val().length < 1){
                alert('Please enter a date');
                $('##dateFrom').focus();
                return false;
            }
            if($('##dateFrom').val().length){
                if(!$('##dateFrom').val().match(reg)){
                    alert('Please enter a valid date');
                    $('##dateFrom').focus();
                    $('##dateFrom').val('');
                    return false;
                }
            }   
            if($('##dateTo').val().length < 1){
                alert('Please enter a date');
                $('##dateTo').focus();
                return false;
            }
            if($('##dateTo').val().length){
                if(!$('##dateTo').val().match(reg)){
                    alert('Please enter a valid date');
                    $('##dateTo').focus();
                    $('##dateTo').val('');
                    return false;
                }
            }   
            return true;
        }
		function formatDollar(num) {   
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
            return returnvalue.replace('$-','-$');
        }

		const ctx = document.getElementById('myChart');
		const myChart = new Chart(ctx, {
		    type: 'pie',
		    
		    data: {
		        labels: [],
		        datasets: [{
		            data: [],
		            backgroundColor: getRandomColor(),
		            borderColor : '##fff',
		            datalabels: {}
		        }]
		    },
		    plugins: [ChartDataLabels],
		    options: {

    			plugins: {
      				title: {
        				display: true,
        				text: '',
        				align:"start",
        				color : '##000',
        				font:{
        					size : 16,

        				},
      				},

      				legend: {
      					title : {
      						display : true,
      						padding: 10
      					},

      					position : 'bottom',
      					align: "start",
      					labels :{
      						usePointStyle :true,
      						pointStyle : 'rect',
      						boxWidth:10,
      						color:'##000',
	      					font:{
	        					size : 14,
	        					family : 'Arial',
	        					weight : 'bold'
	        				},
      					}
      				},
      				datalabels: {
        				align :'end',
        	
        				//offset : '80',
        				color:'##000',
        				//display:'auto',
        				textAlign :'center',
        				anchor : 'end',
        				offset : '10',
        				//clamp:true,

        				font:{
        					size : 10,
        					family : 'Arial',
        					weight : 'bold'

        				},
        				borderColor : '##9e9e9e',
        				borderWidth : 1,
        				padding : 2,
        				formatter: function(value, context) {
				          	return context.chart.data.labels[context.dataIndex]+'\n'+context.chart.data.Clabels[context.dataIndex];
				        },
				        /*display: function(context) {
						  	return context.dataIndex % 2; // display labels with an odd index
						}*/
      				}
    			}
			}
		});

		

	</script>
	

</cfoutput>