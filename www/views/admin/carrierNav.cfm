<cfparam name="event" default="carrier">
<cfparam name="url.maintenanceWithEquipment" default="0">
<cfinvoke component="#variables.objloadGateway#" method="getLoadSystemSetupOptions" returnvariable="request.qSystemSetupOptions1" />
<cfoutput>
<style>
	.navbarDriverAdjust{
		padding: 0px 5px 0px 5px !important;
	}
	.overlay_rp{
	    position: fixed;
	    background-color: ##000000;
	    width: 100%;
	    height: 100%;
	    z-index: 99;
	    top: 0;
	    left: 0;
	    opacity: 0.5;
	    display: none;
	}
	##loader_rp{
		position: fixed;
		top:40%;
		left:30%;
		z-index: 999;
		display: none;
	}
	##loadingmsg_rp{
		top:50%;
		left:31%;
		position: fixed;
		z-index: 999;
		font-size: 14px;
		display: none;
	}
	.overlay{
	    position: fixed;
	    background-color: ##000000;
	    width: 100%;
	    height: 100%;
	    z-index: 99;
	    top: 0;
	    left: 0;
	    opacity: 0.5;
	    display: none;
	}
	##loader{
		position: fixed;
		top:40%;
		left:30%;
		z-index: 999;
		display: none;
	}
	##loadingmsg{
		top:50%;
		left:31%;
		position: fixed;
		z-index: 999;
		font-size: 13px;
		display: none;
	}
</style>
<div class="below-navleft" style="width:890px !important;">
	<cfset iscarrier = "">	
	<cfif structKeyExists(url,"IsCarrier") >
		<cfset iscarrier = "&IsCarrier=#url.IsCarrier#">
	</cfif>
	<ul>
		<li>
			<a href="index.cfm?event=carrier&#session.URLToken##iscarrier#" class="navbarDriverAdjust <cfif (event is 'carrier' or event is 'addcarrier:process') and not structKeyExists(url, "Pending")>active</cfif>">
				<cfif  request.qSystemSetupOptions1.freightBroker EQ 1 OR (request.qSystemSetupOptions1.freightBroker EQ 2 AND  structKeyExists(url,"IsCarrier") AND url.IsCarrier EQ 1) >
					Carriers
				<cfelse>
					Drivers
				</cfif>
			</a>
		</li>
		<cfif  request.qSystemSetupOptions1.freightBroker EQ 1 OR (request.qSystemSetupOptions1.freightBroker EQ 2 AND  structKeyExists(url,"IsCarrier") AND url.IsCarrier EQ 1) >
			<cfif ListContains(session.rightsList,'addCarrier',',')>
				<cfset addCarrUrl = "index.cfm?event=addnewcarrier&#session.URLToken#&IsCarrier=1">
			<cfelse>
				<cfset addCarrUrl = "javascript: alert('Sorry!! You do not have rights to Add Carrier.');">
			</cfif>
			<li><a href="#addCarrUrl#"  class="navbarDriverAdjust <cfif listFindNoCase("addcarrier,addnewcarrier,addnewcarrier:process,CarrierCRMNotes,CarrierContacts,CarrierLookup,addCarrierContact", event)>active</cfif>">Add Carrier</a></li>
		<cfelse>
			<li><a href="index.cfm?event=adddriver&#session.URLToken#&IsCarrier=0"  class="navbarDriverAdjust <cfif event is 'adddriver' or event eq 'CarrierCRMNotes'>active</cfif>" >Add Driver</a></li>
		</cfif>
		<li>
			<a href="index.cfm?event=equipment&#session.URLToken#&companyID=#session.CompanyID#&#iscarrier#" class="navbarDriverAdjust <cfif event is 'equipment' or event is 'addequipment:process' or event is 'addequipment' or event is 'addDriverEquipment:process' or event is 'addDriverEquipment' or event is 'addNewMaintenanceTransaction' or event is 'addNewMaintenance:process' or event is 'addNewMaintenance'><cfif url.maintenanceWithEquipment neq 1>active</cfif></cfif>" >
				Equipment
			</a>
		</li>
		<cfif not request.qSystemSetupOptions1.freightBroker OR (structKeyExists(url,"IsCarrier") AND url.IsCarrier EQ 0 )>			
			<li>				
				<a href="index.cfm?event=equipment&EquipmentMaint=1&maintenanceWithEquipment=1&#session.URLToken##iscarrier#" class="navbarDriverAdjust <cfif event is 'equipment' > <cfif url.maintenanceWithEquipment eq 1> active</cfif> </cfif>" >
				Equip Maintenance 
				</a>
			</li>
			<li>
				<a href="index.cfm?event=maintenanceSetUp&#session.URLToken##iscarrier#" class="navbarDriverAdjust <cfif event is 'maintenanceSetUp' or event is 'addMaintenanceSetUp'>active</cfif>" >
				Equip Maintenance Setup
				</a>
			</li>
			<cfif listFind("0,2", request.qSystemSetupOptions1.freightBroker)>
				<li>
					<a onclick="processRecurringExpenses();" style="cursor: pointer;" class="navbarDriverAdjust" >
					Process Recurring Expenses
					</a>
				</li>
				<li>
					<a href="index.cfm?event=ExpenseSetUp&#session.URLToken##iscarrier#" class="navbarDriverAdjust <cfif event is 'ExpenseSetUp' or event eq 'addExpenseSetUp' or event eq 'addExpenseSetUp:process' or event eq 'addDriverExpense' or event eq 'addRecurringExpense'>active</cfif>" >
					Expense Setup
					</a>
				</li>
			</cfif>
			<li>
				<a href="index.cfm?event=iftaDownload&#session.URLToken##iscarrier#" class="navbarDriverAdjust <cfif event is 'iftaDownload'>active</cfif>" >
				IFTA
				</a>
			</li>
		</cfif>
		<cfif request.qSystemSetupOptions1.ActivateBulkAndLoadNotificationEmail EQ 1>
			<cfif  request.qSystemSetupOptions1.freightBroker EQ 1 OR (request.qSystemSetupOptions1.freightBroker EQ 2 AND  structKeyExists(url,"IsCarrier") AND url.IsCarrier EQ 1) >
				<li>
					<a href="javascript:void(0);" id="sendBulkEmail" class="navbarDriverAdjust">
						Bulk Email All Carriers
					</a>
				</li>
			<cfelseif request.qSystemSetupOptions1.freightBroker EQ 0>
				<li>
					<a href="javascript:void(0);" id="sendBulkEmail"  class="navbarDriverAdjust">
						Bulk Email All Drivers
					</a>		
				</li>
			</cfif>
		</cfif>
		<li><a style="padding: 0 5px 0 5px;" href="index.cfm?event=carrierCRMCalls&#session.URLToken#<cfif request.qSystemSetupOptions1.FreightBroker EQ 2 AND structKeyExists(url, "iscarrier")>&IsCarrier=#url.isCarrier#</cfif>" <cfif event is 'carrierCRMCalls'> class="active" </cfif>>CRM Calls</a></li>
		<li><a style="padding: 0 5px 0 5px;" href="index.cfm?event=carrierCRMCallHistory&#session.URLToken#<cfif request.qSystemSetupOptions1.FreightBroker EQ 2 AND structKeyExists(url, "iscarrier")>&IsCarrier=#url.isCarrier#</cfif>" <cfif listFindNoCase("carrierCRMCallHistory,carrierCRMCallDetail", event)> class="active" </cfif>>CRM Call History</a></li>
		<li>
			<a href="index.cfm?event=carrier&#session.URLToken##iscarrier#&pending=1" class="navbarDriverAdjust <cfif event is 'carrier' and structKeyExists(url, "Pending")>active</cfif>">
				Pending
			</a>
		</li>
		<cfif  request.qSystemSetupOptions1.freightBroker EQ 1 OR (request.qSystemSetupOptions1.freightBroker EQ 2 AND  structKeyExists(url,"IsCarrier") AND url.IsCarrier EQ 1) >
			<li>
				<a href="index.cfm?event=CarrierAdvancedSearch&#session.URLToken##iscarrier#" class="navbarDriverAdjust <cfif event is 'CarrierAdvancedSearch' or event eq 'CarrierAdvanced'>active</cfif>">
					Advanced Search
				</a>
			</li>
		</cfif>
	</ul>
<div class="clear"></div>
</div>
<div class="below-navright" id="helpLink" style="padding-top: 4px;width: 30px;">
</div>
<cfif listFindNoCase("carrier", event)>
	<div style="float: right;margin-right: -362px;margin-top: -33px;">
		<strong>Import Via CSV:</strong><br>
	    <input type="file" id="importCSV"><br>
	    <a style="text-decoration: underline;" href="../../../LoadManagerAdmin/CarrierImportSampleFile.csv"  download>Download Sample File</a>
	</div>	
<cfelseif listFindNoCase("equipment", event)>
	<div style="float: right;margin-right: -362px;margin-top: -33px;">
		<strong>Import Via CSV:</strong><br>
	    <input type="file" id="importEquipmentCSV"><br>
	    <a style="text-decoration: underline;" href="../../../LoadManagerAdmin/EquipmentImportSampleFile.csv"  download>Download Sample File</a>
	</div>	
</cfif>
<div style="float:right;margin-right: -100px;margin-top: -59px;"><a href="index.cfm?event=feedback&#Session.URLToken#"><img src="images/support.png" width="100px" border="0"></a></div>
<div style="float:right;margin-top: -57px;"><a href="javascript:void(0);" onclick="window.open('index.cfm?event=postNote&#session.URLToken#','Map','height=600,width=800');"><img src="images/postedNoteIcon.png" width="100px" border="0"></a></div>
<div class="overlay_rp">
</div>
<img src="images/loadingbar.gif" id="loader_rp">
<strong id="loadingmsg_rp">Generating PDF.It will take some time.Please Wait.</strong>

<div class="overlay">
</div>
<img src="images/loadingbar.gif" id="loader">
<strong id="loadingmsg">Uploading <cfif  request.qSystemSetupOptions1.freightBroker EQ 1 OR (request.qSystemSetupOptions1.freightBroker EQ 2 AND  structKeyExists(url,"IsCarrier") AND url.IsCarrier EQ 1) >Carriers<cfelse>Drivers</cfif>.It will take some time.Please Wait.</strong>
<script  type="text/javascript">
	$(document).ready(function(){
		var mailUrlToken = "#session.URLToken#";
		//call function on click 
	    $('##sendBulkEmail').click(function(){
	        sendBulkEmailOnClick(mailUrlToken);
	    });

	    $("##importCSV").change(function(){

			var formData = new FormData();
			formData.append('file', $('##importCSV')[0].files[0]);
			var IsCarrier = <cfif  request.qSystemSetupOptions1.freightBroker EQ 1 OR (request.qSystemSetupOptions1.freightBroker EQ 2 AND  structKeyExists(url,"IsCarrier") AND url.IsCarrier EQ 1) >1<cfelse>0</cfif>;
			var Type = '<cfif  request.qSystemSetupOptions1.freightBroker EQ 1 OR (request.qSystemSetupOptions1.freightBroker EQ 2 AND  structKeyExists(url,"IsCarrier") AND url.IsCarrier EQ 1) >Carriers<cfelse>Drivers</cfif>';
			var path = urlComponentPath+"carriergateway.cfc?method=uploadCarrierViaCSV&createdBy=#session.AdminUserName#&CompanyID=#session.CompanyID#&IsCarrier="+IsCarrier;

			$.ajax({
			    url: path,
	            type: "POST",
	            data: formData,
	            enctype: 'multipart/form-data',
	            processData: false,  // tell jQuery not to process the data
	            contentType: false,   // tell jQuery not to set contentType
			    success : function(data) {
			    	$('.overlay').hide()
			        $('##loader').hide();
			        $('##loadingmsg').hide();
			        $('##importCSV').val('');
			        setTimeout(function(){ alert(jQuery.parseJSON(data).MESSAGE.replace("[Type]", Type)); location.reload();}, 500);
			    },
	            beforeSend: function() {
			        $('.overlay').show()
			        $('##loader').show();
			        $('##loadingmsg').show();
			  
			    },
			});
		});

		$("##importEquipmentCSV").change(function(){

			var formData = new FormData();
			formData.append('file', $('##importEquipmentCSV')[0].files[0]);

			var path = urlComponentPath+"equipmentgateway.cfc?method=uploadEquipmentViaCSV&createdBy=#session.AdminUserName#&CompanyID=#session.CompanyID#";

			$.ajax({
			    url: path,
	            type: "POST",
	            data: formData,
	            enctype: 'multipart/form-data',
	            processData: false,  // tell jQuery not to process the data
	            contentType: false,   // tell jQuery not to set contentType
			    success : function(data) {
			    	$('.overlay').hide()
			        $('##loader').hide();
			        $('##loadingmsg').hide();
			        $('##importEquipmentCSV').val('');
			        setTimeout(function(){ alert(jQuery.parseJSON(data).MESSAGE); location.reload();}, 500);
			    },
	            beforeSend: function() {
			        $('.overlay').show()
			        $('##loader').show();
			        $('##loadingmsg').html('Uploading Equipments. Please Wait.').show();
			  
			    },
			});
		});
	});

	function processRecurringExpenses(){
		var path = urlComponentPath+"equipmentGateway.cfc?method=generateRecurringDriverExpenses";
		            
    	$.ajax({
        	type: "POST",
            url: path,
            data:{
            	adminUserName : '#session.adminUserName#',
				CompanyID : '#session.CompanyID#'
            },
            success: function(data){
            	$('.overlay_rp').hide();
            	$('##loader_rp').hide();
            	$('##loadingmsg_rp').hide();
            	setTimeout(function () {
	              	alert(data);
	            }, 200)
            },
            beforeSend: function() {
		        $('.overlay_rp').show()
		        $('##loader_rp').show();
		        $('##loadingmsg_rp').show();
		    },
		   
      	});
	}
</script>

</cfoutput>