<cfparam name="event" default="customer">
<cfinvoke component="#variables.objloadGateway#" method="getSystemSetupOptions" returnvariable="request.qGetSystemSetupOptions" />
<cfoutput>
<style type="text/css">
	.below-nav{
		background: url(../webroot/images/below-navbg.gif) left top repeat-y;
	}
	.below-navleft ul li a{
		padding: 0 4px 0 4px;
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
		left:40%;
		z-index: 999;
		display: none;
	}
	##loadingmsg{
		font-weight: bold;
		text-align: center;
		margin-top: 1px;
		background-color: ##fff;
	}
</style>
<div class="below-navleft" style="width:890px;">
	<ul>
		<li><a href="index.cfm?event=customer&#session.URLToken#" <cfif (event is 'customer' or event is 'addcustomer:process') and not structKeyExists(url,'payer') and not structKeyExists(url, "Pending")> class="active" </cfif>>Payers/Shippers/Consignees</a></li>
		<li><a href="index.cfm?event=add<cfif request.qGetSystemSetupOptions.autoAddCustViaDOT EQ 1>new</cfif>customer&#session.URLToken#" <cfif listFind("addcustomer,addnewcustomer,CRMNotes,stop,addstop,CustomerContacts,addCustomerContact", event)> class="active" </cfif>>Add Customer</a></li>
		<li><a href="index.cfm?event=customer&#session.URLToken#&payer=1" <cfif event is 'customer' and structKeyExists(url,'payer') and url.payer is '1'> class="active" </cfif>>Payers</a></li>
		<li><a href="index.cfm?event=customer&#session.URLToken#&payer=0" <cfif event is 'customer' and structKeyExists(url,'payer') and url.payer is '0'> class="active" </cfif>>Shippers/Consignees</a></li>
		<cfif request.qGetSystemSetupOptions.TurnOnConsolidatedInvoices>
			<li><a href="index.cfm?event=createconsolidatedinvoices&#session.URLToken#" <cfif event is 'createconsolidatedinvoices'> class="active" </cfif>>Create Consolidated Invoices</a></li>
			<li><a href="index.cfm?event=consolidatedinvoicequeue&#session.URLToken#" <cfif	listFindNoCase("consolidatedinvoicequeue,editconsolidatedinvoicequeue", event)> class="active" </cfif>>Consolidated Invoice Queue</a></li>
		</cfif>
		<li><a href="index.cfm?event=customerCRMCalls&#session.URLToken#" <cfif event is 'customerCRMCalls'> class="active" </cfif>>CRM Calls</a></li>
		<li><a href="index.cfm?event=customerCRMCallHistory&#session.URLToken#" <cfif listFindNoCase("customerCRMCallHistory,customerCRMCallDetail", event)> class="active" </cfif>>CRM Call History</a></li>
		<li><a href="index.cfm?event=customer&#session.URLToken#&Pending=1" <cfif event is 'customer' and structKeyExists(url, "Pending")> class="active" </cfif>>Pending</a></li>
	</ul>
<div class="clear"></div>
</div>
<div class="below-navright" id="helpLink" style="padding-top: 4px;width: 30px;">
</div>
<cfif listFindNoCase("customer", event)>
	<div style="float: right;margin-right: -362px;margin-top: -33px;">
		<strong>Import Via CSV:</strong><br>
	    <input type="file" id="importCSV"><br>
	    <a style="text-decoration: underline;" href="../../../LoadManagerAdmin/CustomerImportSampleFile.csv"  download>Download Sample File</a>
	</div>		
</cfif>
<div style="float:right;margin-right: -100px;margin-top: -59px;"><a href="index.cfm?event=feedback&#Session.URLToken#"><img src="images/support.png" width="100px" border="0"></a></div>
<div style="float:right;margin-top: -57px;"><a href="javascript:void(0);" onclick="window.open('index.cfm?event=postNote&#session.URLToken#','Map','height=600,width=800');"><img src="images/postedNoteIcon.png" width="100px" border="0"></a></div>
<div class="overlay">
</div>
<div id="loader">
	<img src="images/loadDelLoader.gif">
	<p id="loadingmsg">Please wait.</p>
</div>
<script  type="text/javascript">
	$(document).ready(function(){
		$("##importCSV").change(function(){

			var formData = new FormData();
			formData.append('file', $('##importCSV')[0].files[0]);

			var path = urlComponentPath+"customergateway.cfc?method=uploadCustomerViaCSV&createdBy=#session.AdminUserName#&CompanyID=#session.CompanyID#";

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
			        $('##importCSV').val('');
			        setTimeout(function(){ alert(jQuery.parseJSON(data).MESSAGE); location.reload();}, 500);
			    },
	            beforeSend: function() {
			        $('.overlay').show()
			        $('##loader').show();
			    },
			});
		});
	})
</script>
</cfoutput>