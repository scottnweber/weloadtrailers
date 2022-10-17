<cfoutput> 
	<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
	<html xmlns="http://www.w3.org/1999/xhtml">
		<head>
		<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
	  
		<title>Load Manager TMS</title>
          <script type="text/javascript" src="https://maps.google.com/maps/api/js?key=AIzaSyA2yTYFWaiOSM-kaPp6fdPEOUuTEQWT3Xg&v=3"></script>
		<link rel="stylesheet" type="text/css" href="styles/jquery.autocomplete.css" />
          <cfset urlCfcPath = Replace(request.cfcpath, '.', '/','All')/>
		<script>
          urlComponentPath  = "/#urlCfcPath#/";
        </script>
       
		 
        <link rel="stylesheet" href="https://code.jquery.com/ui/1.11.0/themes/smoothness/jquery-ui.css">
		<link href="styles/style.css?#now()#" rel="stylesheet" type="text/css" />
        <script src="https://code.jquery.com/jquery-1.10.2.min.js"></script>
	    <script src="https://code.jquery.com/ui/1.11.0/jquery-ui.min.js"></script>
        <script src="https://ajax.aspnetcdn.com/ajax/jquery.validate/1.9/jquery.validate.min.js"></script>
		<script src="javascripts/Validation.js?#now()#" language="javascript" type="text/javascript"></script>
		<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.13.0/css/all.min.css">
		<cfif request.event EQ "addload">
			<script src="https://maps.alk.com/api/1.2/ALKMaps.js" type="text/javascript"></script>
			<cfif not structKeyExists(request, "qSystemSetupOptions")>
            	<cfinvoke component="#variables.objloadGateway#" method="getSystemSetupOptions" returnvariable="request.qSystemSetupOptions" />
            </cfif>
            <cfif request.qSystemSetupOptions.googleMapsPcMiler EQ 1>
            	<script src="javascripts/PRIMEWebAPI.js" language="javascript" type="text/javascript"></script>
            </cfif>
		</cfif>
		<script>
			var tabID = sessionStorage.tabID && sessionStorage.closedLastTab !== '2' ? sessionStorage.tabID : sessionStorage.tabID = Math.random();
			$(document).ready(function(){

				$('.assign-load').click(function() {
				  $('body').addClass('noscroll');
		          var modal = document.getElementById('myModal');
		          if($(this).attr('id').indexOf('btnAssignLoad') != -1){
		          	$('##LoadLogId').val($(this).attr('data-code'));
		          	if($(this).attr('data-fuel') != ''){
		          		$('##FuelCardNO').val($(this).attr('data-fuel'));
		          	}
		          	else{
		          		$('##FuelCardNO').val(0);
		          	}
		          	
		          	
		          }
		          
		          modal.style.display = "block";
		        });
		        $('.assign-load-close').click(function(){
		        	var modal = document.getElementById('myModal');
		          	modal.style.display = "none";
		          	$('body').removeClass('noscroll');
		        });
		        $('##btnCancel').click(function (){
		          $('##LoadNumber').val('');
		          var modal = document.getElementById('myModal');
		          modal.style.display = "none";
		          $('body').removeClass('noscroll');
		        });
		       



				if($("##tabid").length){
					$("##tabid").val(tabID);
				}
				$("##searchText").focus();
				<cfif request.event EQ "addload">
					function objectifyForm(formArray) {//serialize data function

					  var returnArray = {};
					  for (var i = 0; i < formArray.length; i++){
							returnArray[formArray[i]['name']] = formArray[i]['value'];
					  }
					  return returnArray;
					}					
				</cfif>
				
				<cfif structkeyexists(session,"CompanyID")>
					$("##LoadNumber").autocomplete( {
						width: 450,
			            scroll: true,
			            scrollHeight: 300,
			            cacheLength: 1,
			            highlight: false,
			            dataType: "json",
			            search: function(event, ui){$(this).autocomplete('option', 'source', 'searchCarrierAutoFillComdata.cfm?queryType=getCustomers&CompanyID=#session.CompanyID#&LoadNumber='+$(this).val())},
			            source: 'searchCarrierAutoFillComdata.cfm?queryType=getCustomers&CompanyID=#session.CompanyID#',
			            select: function (event, ui) {
		            		$(this).val(ui.item.loadno);
					        return false;
					    }

					});
					if($("##LoadNumber").val() != undefined){
						$("##LoadNumber").data("ui-autocomplete")._renderItem = function(ul, item) {                          
							return $("<li><b>Load Number:</b>"+item.loadno+"<br><b>Carrier:</b>"+item.carrier+"<br><b>Customer:</b>"+item.customer+"<br><b>Order Date:</b>"+item.orderdate+"</li>").appendTo(ul);
		            	};
	            	}
            	</cfif>
	           	
            	<cfif structkeyexists(session,"P44MSG")>
            		<cfif len(trim(session.P44MSG))>
            			alert('#session.P44MSG#');
            		</cfif>
            		<cfset structDelete(session, "P44MSG")>
            	</cfif>

			});	

			
			
			function assignComdataLoadNumber(){
				
				var path = urlComponentPath+"loadgateway.cfc?method=comdataUpdate<cfif structKeyExists(session, "CompanyID")>&CompanyID=#session.CompanyID#</cfif>";
				if($.trim($('##LoadNumber').val()).length == 0){
					alert('Please enter Load Number');
					$('##LoadNumber').focus();					
				}
				else if($('##FuelCardNO').val() == 0){
					alert('Fuel Card Number is not updated to this log');
					$('##LoadNumber').val('');					
				}
				else{
			        $.ajax({
			            type: "Post",
			            url: path,
			            data: {
			                LoadLogId:$('##LoadLogId').val(),LoadNumber:$('##LoadNumber').val(),Dsn:'#application.dsn#'
			            },
			            success: function(result){
			                $('.loadOverlay').hide();
			                location.reload();     
			            },
			            error: function(result){
			            
			            	if (result.statusText.indexOf('File or directory') != -1 && result.statusText.indexOf('does not exist') != -1){
			            		alert('Fuel file does not exist or deleted from server.');
			            	}
			            	else{
			            		alert('Something went wrong. Please try later.');
			            	}

			            	$('##LoadNumber').val('');
					        var modal = document.getElementById('myModal');
					        modal.style.display = "none";
					        $('body').removeClass('noscroll');

			            	
			            },
			            beforeSend: function() {
			                $('.loadOverlay').show()
			            },
			        });
			    }
			}

			function skipBannerForToday(){
				var path = urlComponentPath+"agentgateway.cfc?method=skipBannerForToday";
				$.ajax({
					type: "Post",
					url: path,		
					dataType: "json",
					data: {
						CompanyID:'<cfif structKeyExists(session, "CompanyID")>#session.CompanyID#</cfif>',
					},
					success: function(data){
						location.reload(); 
					}
				});
			}
		</script>
		<!---Condition to check the user is not in loadedit page--->
		<cfif structKeyExists(url, "event") and url.event neq "addload" and url.event neq "nextStopLoad" and structkeyexists(session,"empid") and len(trim(session.empid)) and structkeyexists(session,"currentloadid") and len(trim(session.currentloadid))>
			<cfoutput>
				<script type="text/javascript">
					$(document).ready(function(){
						var path = urlComponentPath+"loadgateway.cfc?method=deleteTabDetails";
						$.ajax({
						type: "Post",
						url: path,		
						dataType: "json",
						async: false,
						data: {
							tabID:tabID,userid:'#session.empid#',sessionid:'#session.sessionid#',dsn:'#application.dsn#'
						},
						success: function(data){
						 console.log(data);
						}
					  });
					});
				</script>
			</cfoutput>	
		</cfif>

		<!---Condition to check the user is not in customeredit page--->
		<cfif structKeyExists(url, "event") and url.event neq "addcustomer"  and structkeyexists(session,"empid") and len(trim(session.empid)) and structkeyexists(session,"currentcustomerid") and len(trim(session.currentcustomerid))>
			<cfoutput>
				<script type="text/javascript">
					$(document).ready(function(){
						var path = urlComponentPath+"customergateway.cfc?method=deleteTabDetails";
						$.ajax({
						type: "Post",
						url: path,		
						dataType: "json",
						async: false,
						data: {
							tabID:tabID,userid:'#session.empid#',sessionid:'#session.sessionid#',dsn:'#application.dsn#',
							customerid:'#session.currentcustomerid#'
						},
						success: function(data){
						 console.log(data);
						}
					  });
					});
				</script>
			</cfoutput>	
		</cfif>

		<!---Condition to check the user is not in carrieredit page--->
		<cfif structKeyExists(url, "event") and url.event neq "addcarrier"  and structkeyexists(session,"empid") and len(trim(session.empid)) and structkeyexists(session,"currentcarrierid") and len(trim(session.currentcarrierid))>
			<cfoutput>
				<script type="text/javascript">
					$(document).ready(function(){
						var path = urlComponentPath+"carriergateway.cfc?method=deleteTabDetails";
						$.ajax({
						type: "Post",
						url: path,		
						dataType: "json",
						async: false,
						data: {
							tabID:tabID,userid:'#session.empid#',sessionid:'#session.sessionid#',dsn:'#application.dsn#',
							carrierid:'#session.currentcarrierid#'
						},
						success: function(data){
						 console.log(data);
						}
					  });
					});
				</script>
			</cfoutput>	
		</cfif>

		<!---Condition to check the user is not in agentedit page--->
		<cfif structKeyExists(url, "event") and url.event neq "addagent"  and structkeyexists(session,"empid") and len(trim(session.empid)) and structkeyexists(session,"currentagentid") and len(trim(session.currentagentid))>
			<cfoutput>
				<script type="text/javascript">
					$(document).ready(function(){
						var path = urlComponentPath+"agentgateway.cfc?method=deleteTabDetails";
						$.ajax({
						type: "Post",
						url: path,		
						dataType: "json",
						async: false,
						data: {
							tabID:tabID,userid:'#session.empid#',sessionid:'#session.sessionid#',dsn:'#application.dsn#',
							agentid:'#session.currentagentid#'
						},
						success: function(data){
						 console.log(data);
						}
					  });
					});
				</script>
			</cfoutput>	
		</cfif>

		<!---Condition to check the user is not in equipmentedit page--->
		<cfif structKeyExists(url, "event") and url.event neq "addequipment"  and structkeyexists(session,"empid") and len(trim(session.empid)) and structkeyexists(session,"currentequipmentid") and len(trim(session.currentequipmentid))>
			<cfoutput>
				<script type="text/javascript">
					$(document).ready(function(){
						var path = urlComponentPath+"equipmentgateway.cfc?method=deleteTabDetails";
						$.ajax({
						type: "Post",
						url: path,		
						dataType: "json",
						async: false,
						data: {
							tabID:tabID,userid:'#session.empid#',sessionid:'#session.sessionid#',dsn:'#application.dsn#',
							equipmentid:'#session.currentequipmentid#'
						},
						success: function(data){
						 console.log(data);
						}
					  });
					});
				</script>
			</cfoutput>	
		</cfif>

		<!---Condition to check the user is not in carrieredit page--->
		<cfif structKeyExists(url, "event") and url.event neq "adddriver"  and structkeyexists(session,"empid") and len(trim(session.empid)) and structkeyexists(session,"currentdriverid") and len(trim(session.currentdriverid))>
			<cfoutput>
				<script type="text/javascript">
					$(document).ready(function(){
						var path = urlComponentPath+"carriergateway.cfc?method=deleteTabDetails";
						$.ajax({
						type: "Post",
						url: path,		
						dataType: "json",
						async: false,
						data: {
							tabID:tabID,userid:'#session.empid#',sessionid:'#session.sessionid#',dsn:'#application.dsn#',
							carrierid:'#session.currentdriverid#'
						},
						success: function(data){
						 console.log(data);
						}
					  });
					});
				</script>
			</cfoutput>	
		</cfif>
		<cfif structKeyExists(session, "CompanyID")>
			<cfinclude template="getActiveUsersList.cfm">
		</cfif>
		<cfif ((isdefined("url.loadid") and len(trim(url.loadid)) gt 1) OR (isdefined("url.loadToBeCopied") and len(trim(url.loadToBeCopied)) gt 1)) AND url.event neq 'addcustomerload' AND url.event neq 'BOLReport'>
        
		<cfparam name="NewcustomerID" default="">
			<script>
				$('.CustInfo1').ready(function(){
					var statusTxt = $.trim($( "##loadStatus option:selected" ).text());
					var NewcustomerID = $('##cutomerIdAutoValueContainer').val();
					if(statusTxt == '2. BOOKED'){
						getCutomerForm(NewcustomerID,'#application.DSN#','#session.URLToken#','Dispatch');
					}
					else{
						getCutomerForm(NewcustomerID,'#application.DSN#','#session.URLToken#','Billing');
					}
					
				});
			</script>
          </cfif>
		  <cfparam name="userlogged" default="0">
		 <cfif structkeyexists (session,"empid") and structkeyexists(session, "passport")>			
			<cfif Session.empid neq "" and session.passport.isLoggedIn>		
				<cfset userlogged=1>
			</cfif>
		</cfif>	
			<cfinvoke component="#variables.objloadGateway#" method="getLoadSystemSetupOptions" returnvariable="request.qSystemSetupOptions1" />
		  <style>
			.unReadMessage{
				background-color: ##d21f1f;
				border-radius: 50%;
				color: ##fff;
				height: 20px;
				text-align: center;
				width: 20px;
			}
			.unread {
				font-size: 11px;
				position: relative;
				right: 0;
				top: -7px;
			}
			.unReadBtn{
			    color: ##ffffff;
			    border-radius: 50%;
			    font-size: 11px;
			    border: none;
			    cursor: pointer;
			    height: 20px;
			    width: 20px;
			    padding: 0;
			    text-align: center;
			    padding-right: 2px;
			    float: right;
			    margin-top: -10px;
			    margin-left: -20px;
			}
		  </style>
		</head>
		<body style="background-color:<cfif structKeyExists(session, "companyID")><cfif structKeyExists(url, "event") AND listFindNoCase("InvoiceLoads,CustomerPayments,CreateCustomerInvoice,LMACustomerAgingReport,LMACustomerStatementReport,InvoiceCarrierLoads,CreateVendorInvoice,InvoiceToPay,PrintChecks,LMAVendorAgingReport,ListChartofAccounts,ChartofAccounts,FindGLTransactions,BankAccounts,LMAPrintTrialBalance,LMASettings,PaymentTerms,addLMAPaymentTerms,GeneralLedgerFinancialSetup,LMAPrintIncomeStatement,GeneralLedgerBalanceSheetSetup,LMAPrintBalanceSheet,JournalEntry,PostJournalEntry,ReverseJournalEntry,LMAPrintCashReceipts,LMAInvoicesPickedtoPay,AccountDepartments,Departments,LMAPrintLedgerReport,OpenNewYear,GLRecalculate,CustomerInquiry,VendorInquiry,PostInvoicePayment,VoidInvoicePayment,InvoicePaymentReport,QuickBooksExport,QuickBooksExportAP,QuickBooksExportHistory,QBNotExported,VoidCustomerPayment", event) AND len(trim(request.qSystemSetupOptions1.BackgroundColorAccounting))>
		#request.qSystemSetupOptions1.BackgroundColorAccounting#
		<cfelse>
		#request.qSystemSetupOptions1.BackgroundColor#
		</cfif> <cfelse>##fff</cfif> !important;">
		<cfparam name="url.thnks" default="0">
			<!---time stame code added by Furqan--->
    	<cfset todayDate = #Now()#> 
		<cfset logindate = #DateFormat(todayDate, "yyyy-mm-dd")# >
		<cfinvoke component="#variables.objSecurityGateway#" method="timeuser"/>
    <!---Time stame code added by Furqan--->
		<cfif structkeyexists(url,"thnks") and url.thnks eq 1>
			<script>
			alert('Thank you for giving us your feedback.');
			</script>
	 	</cfif>
		
		<cfif structKeyExists(session, "CompanyID")>
			<cfinvoke component="#variables.objequipmentGateway#" method="getCountEquipments" returnvariable="request.qryCountEquipments" />
			<cfinvoke component="#variables.objcustomerGateway#" method="getCustomerCRMOverdue" returnvariable="request.qryCountCustomer" />
			<cfif request.qSystemSetupOptions1.FreightBroker EQ 2>
				<cfinvoke component="#variables.objcarrierGateway#" method="getCarrierCRMOverdue" returnvariable="request.qryCountCarrier" iscarrier="1"/>
				<cfinvoke component="#variables.objcarrierGateway#" method="getCarrierCRMOverdue" returnvariable="request.qryCountDriver" iscarrier="0"/>
			<cfelse>
				<cfinvoke component="#variables.objcarrierGateway#" method="getCarrierCRMOverdue" returnvariable="request.qryCountCarrier" />
			</cfif>
		</cfif>
		

		<cfif structKeyExists(session, "CompanyID")>
			<cfinvoke component="#variables.objLoadGatewaynew#" method="getPendingEDILoads" returnvariable="qEDI204PendingLoads" />
		</cfif>
		<style>
			.white-mid,.carrier-mid{
				background-color:#request.qSystemSetupOptions1.BackgroundColorForContent# !important;
				border:1 px solid !important;
			}
			
			
			.white-bot,.white-top{
				display:none;
			}
			.marginLeft3{
				margin-left:3% !important;
			}
			.margin0auto{
				margin : 0 auto;
			}
		</style>
	
			<cfif structKeyExists(session, "empid") and len(trim(session.empid))>
				<cfinvoke component="#variables.objloadGateway#" method="getcurAgentdetails" returnvariable="request.qcurAgentdetails" employeID="#session.empid#" />
				<cfset integratewithPEP = request.qcurAgentdetails.integratewithPEP>
				<cfset INTEGRATEWITHITS = request.qcurAgentdetails.INTEGRATEWITHITS>
			<cfelse>
				<cfset INTEGRATEWITHITS = 0>
				<cfset integratewithPEP = 0>
			</cfif>
			<!------posteverywhere & transcore alert messages---------->
			<cfif structkeyexists(url,"AlertvarP") and url.AlertvarP neq "1"  and url.AlertvarP neq "" and  integratewithPEP  neq 0 >
				
				<cfset test=#findnocase("APPROVED",url.AlertvarP)# >
				<cfoutput>
					<cfif test eq 0>
						<script>
							var #toScript(AlertvarP, "jsVar")#;
						</script> 
					</cfif>
				</cfoutput> 
			 </cfif>
			<cfif structkeyexists(url,"AlertvarT") and url.AlertvarT neq "1"   and url.AlertvarT neq "" and  integratewithPEP  neq 0 >
				
				<cfset test=#findnocase("APPROVED",url.AlertvarT)# >
				<cfset Testprev=#findnocase("!!!",url.AlertvarT)# >
				<cfset TestDel=#findnocase("sucessfully deleted",url.AlertvarT)# >
				<cfoutput>
					<cfif test eq 0 and Testprev eq 0 and TestDel eq 0>
						<script>
							var #toScript(AlertvarT, "jsVar")#;
						</script> 
					<cfelseif  test eq 0 and Testprev gt 0 and TestDel eq 0>
					
					<cfset AlertvarT=#replace(AlertvarT,"1!!!",'')# ><cfset AlertvarT=#replace(AlertvarT,"!!!",'')# >
						<script>
							var #toScript(AlertvarT, "jsVar")#;
							alert('Display the error message as you are now but modify it as follows: Your Load has been saved however it could not be Updated on the Transcore Load board because of the following error  ['+jsVar+']');
						</script> 
					<cfelseif TestDel gt 0>
					</cfif>
				</cfoutput> 
			 </cfif>
			 <cfif structkeyexists(url,"AlertvarI") and url.AlertvarI neq "1"  and url.AlertvarI neq "" and  integratewithITS  neq 0 >
				
				
				<cfoutput>
					
						<script>
							var #toScript(url.AlertvarI, "jsVar")#;
						</script> 
					
				</cfoutput> 
			</cfif>
			 <cfif structkeyexists(url,"AlertvarM") and url.AlertvarM neq "1">
				<cfoutput>
						<script>
							var settingloadboardStatus=<cfoutput>'#url.AlertvarM#'</cfoutput>;
							if(settingloadboardStatus != '1'){
								$("##PostTo123LoadBoard").attr('checked', false);
							}else{
								$("##PostTo123LoadBoard").attr('checked', true);
							}
							var #toScript(url.AlertvarM,"jsVar")#;
						</script> 
				</cfoutput> 
			</cfif>	
			 <cfif structkeyexists(url,"AlertvarN") and url.AlertvarN neq "1">
				<cfoutput>
						
						<script>
							var settingloadboard=<cfoutput>'#url.AlertvarN#'</cfoutput>;
							if(settingloadboard != '1'){
								$("##PostTo123LoadBoard").attr('checked', true);
							}
							var #toScript(url.AlertvarN,"jsVar")#;
						</script> 
					
				</cfoutput> 
			</cfif>	
			<cfif structkeyexists(url,"Alertvarq") and url.Alertvarq neq 1>
				<cfoutput>
						
						<script>
							
							var #toScript(url.Alertvarq,"jsVar")#;
							alert(jsVar);
						</script> 
					
				</cfoutput> 
			</cfif>	
			<!---------end post & transcore alert message------> 
			<cfparam name="event" default="home">
			<cfparam name="variables.ClassName" default="">
			<cfif StructKeyExists(url,"event")>
				<cfif url.event eq "Myload" or url.event eq "carrierquotes" or url.event eq "AIImport" >
					<cfset variables.ClassName = "MyloadTableWrap" >
				<cfelseif url.event eq "load">
					<cfset variables.ClassName = "MyloadTableWrap AllLoadTableWrap" >
				</cfif>
			</cfif>
			<cfif structKeyExists(session, "CompanyID")>
				<cfinvoke component="#variables.objAgentGateway#" method="getBanner" CompanyID="#session.companyID#" returnvariable="qBanner" />
				<cfif qBanner.recordcount and len(trim(qBanner.BannerText))>
					<table cellpadding="0" cellspacing="0" style="margin-left: auto;margin-right: auto;">
						<tr>
							<td>#qBanner.BannerText#</td>
							<td><img style="cursor:pointer;float: left;" src="images/btnClose.ico" onclick="skipBannerForToday()"> </td>
						</tr>
					</table>
				</cfif>
				<cfif application.dsn EQ 'LoadManagerBeta'>
					<cfinvoke component="#variables.objloadGateway#" method="getPaymentExpiry" CompanyID="#session.companyID#" returnvariable="qPaymentExpiryDays" />
					<cfif qPaymentExpiryDays.recordcount>
						<div style="background-color:##fff;width: 94%;margin-left: 4%;border:1px solid;">
							<cfif qPaymentExpiryDays.SubscriptionCancelled EQ 0>
								<p class="text-center" style="color:##880015;font-weight:bold;font-size:15px;text-align: center;">Your login will expire in #qPaymentExpiryDays.expiryDays# days because your payment is overdue.</p>		
							</cfif>
							<h4 style="text-align: center;color:##3f48cc;font-size:13px;padding: 10px 0;">#qPaymentExpiryDays.Message#</h4>
						</div>
					</cfif>
				</cfif>
				<div style="clear:left;"></div>
			</cfif>
			<div class="container" style="background-color:<cfif structKeyExists(session, "companyID")><cfif structKeyExists(url, "event") AND listFindNoCase("InvoiceLoads,CustomerPayments,CreateCustomerInvoice,LMACustomerAgingReport,LMACustomerStatementReport,InvoiceCarrierLoads,CreateVendorInvoice,InvoiceToPay,PrintChecks,LMAVendorAgingReport,ListChartofAccounts,ChartofAccounts,FindGLTransactions,BankAccounts,LMAPrintTrialBalance,LMASettings,PaymentTerms,addLMAPaymentTerms,GeneralLedgerFinancialSetup,LMAPrintIncomeStatement,GeneralLedgerBalanceSheetSetup,LMAPrintBalanceSheet,JournalEntry,PostJournalEntry,ReverseJournalEntry,LMAPrintCashReceipts,LMAInvoicesPickedtoPay,AccountDepartments,Departments,LMAPrintLedgerReport,OpenNewYear,GLRecalculate,CustomerInquiry,VendorInquiry,PostInvoicePayment,VoidInvoicePayment,InvoicePaymentReport,QuickBooksExport,QuickBooksExportAP,QuickBooksExportHistory,QBNotExported,VoidCustomerPayment", event) AND len(trim(request.qSystemSetupOptions1.BackgroundColorAccounting))>
		#request.qSystemSetupOptions1.BackgroundColorAccounting#
		<cfelse>
		#request.qSystemSetupOptions1.BackgroundColor#
		</cfif> <cfelse>##fff</cfif> !important;">
				<table width="100%" border="0px" cellpadding="0px" style="height:100%;" cellspacing="0px"<cfif Not StructKeyExists(request, "content") And StructKeyExists(request, "tabs")> style="height:100%;"</cfif>>
					<tr>
						<td><table width="100%" border="0px" cellpadding="0px" cellspacing="0px">
								<cfif structKeyExists(session, "dashboardUser") and session.dashboardUser eq 1>
									<style>
										.content-area {
											position: fixed;
											top:0;
											width: 100%;
											overflow: scroll;
										}
										.form-con.dasboardDataTable{
											width: 40% !important;
										}
										.form-con.dashboardPieChart{
											width: 42% !important;
											margin-left: 75px !important;
										}
									</style>
								<cfelse>
								<tr>
									<td>
										<cfif isdefined('session.passport.isLoggedIn') and session.passport.isLoggedIn and  structKeyExists(url,"event") AND url.event NEQ "login" AND url.event NEQ "customerlogin">

											<table class="<cfif structKeyExists(url,"event") AND (url.event EQ "load" OR  url.event EQ "myLoad" OR  url.event EQ "carrierquotes" OR  url.event EQ "AIImport")>marginLeft3<cfelse>margin0auto</cfif>" style="width:1050px !important;" border="0" cellpadding="0" cellspacing="0">
												<tr>
													<td width="29%">
														<cfif structKeyExists(url, "event")>
															<cfquery name="qGetTutVideo" datasource="#application.dsn#">
																SELECT * FROM VideoTutorials WHERE PageEvent = 
																<cfif url.event EQ 'myLoad'>
																	'load'
																<cfelse>
																	<cfqueryparam value="#url.event#" cfsqltype="cf_sql_varchar">
																</cfif>
															</cfquery>
															<cfif qGetTutVideo.recordcount and len(trim(qGetTutVideo.YouTubeURL))>
																<a href="#qGetTutVideo.YouTubeURL#" target="_blank"><img src="images\youtubeIcon.png" width="50px;" /></a>
															<cfelse>
																&nbsp;
															</cfif>
														</cfif>
													</td>
													<td align="center" width="29%">
														<cfif request.qSystemSetupOptions1.companyLogoName NEQ '' AND isDefined("session.userCompanyCode")>

															<cfif application.dsn eq 'LoadManagerBeta'>
																<cfif not directoryExists("C:\home\loadmanager.net\wwwroot\LoadManagerBeta\www\fileupload\img\#trim(session.userCompanyCode)#\logo\")>
																	<cfdirectory action="create" directory="C:\home\loadmanager.net\wwwroot\LoadManagerBeta\www\fileupload\img\#trim(session.userCompanyCode)#\logo\">
																</cfif>
																<cfif not fileExists("C:\home\loadmanager.net\wwwroot\LoadManagerBeta\www\fileupload\img\#trim(session.userCompanyCode)#\logo\#request.qSystemSetupOptions1.companyLogoName#")>

																	<cffile action = "copy" source = "https://loadmanager.biz/loadmanagerlive/www/fileupload/img/#trim(session.userCompanyCode)#/logo/#request.qSystemSetupOptions1.companyLogoName#" destination = "C:\home\loadmanager.net\wwwroot\LoadManagerBeta\www\fileupload\img\#trim(session.userCompanyCode)#\logo\#request.qSystemSetupOptions1.companyLogoName#">

																</cfif>
															</cfif>
															<img src="..\fileupload\img\#trim(session.userCompanyCode)#\logo\#request.qSystemSetupOptions1.companyLogoName#" width="120px;" /><br>
														</cfif>
														<cfif request.qSystemSetupOptions1.companyName NEQ ''>
															<strong>#request.qSystemSetupOptions1.companyName#</strong>
														</cfif>
													</td>
													<td width="29%">
														<b>Code/User:</b> <cfif structKeyExists(session, "userCompanyCode")>#session.userCompanyCode#/</cfif><cfif structKeyExists(session, "AdminUserName")>#session.AdminUserName#</cfif><br>
														<b>Version##:</b>
														<cftry>
															<cfset gitFileInfo =  GetFileInfo("#expandPath("/#trim(listFirst(cgi.SCRIPT_NAME,'/'))#/.git/index")#")>
															3.#dateFormat(gitFileInfo.lastmodified,"YYMMDD")#
															<cfcatch>
																3.#dateFormat(now(),"YYMMDD")#
															</cfcatch>
														</cftry>
													</td>
													<td width="12%">&nbsp;
													</td>
												</tr>
												<cfif isdefined('session.passport.isLoggedIn') and session.passport.isLoggedIn AND structKeyExists(session, "empid") and len(trim(session.empid)) and  structKeyExists(url,"event") AND url.event NEQ "login">
													<cfinvoke component="#variables.objAlertGateway#" method="getAlertCount" returnvariable="request.AlertCount" />
													<cfif request.AlertCount NEQ 0>
														<tr>
															<td colspan="3" align="center" style="padding-top: 5px;padding-bottom: 10px;">
																<a style="text-decoration: underline;font-size: 25px;" href="index.cfm?event=Alerts&#session.URLToken#">Alerts (#request.AlertCount#)</a>
															</td>
															<td colspan="1"></td>
														</tr>
													</cfif>
												</cfif>
											</table>
											<table class="navigation <cfif structKeyExists(url,"event") AND (url.event EQ "load" OR  url.event EQ "myLoad" OR  url.event EQ "carrierquotes" OR  url.event EQ "AIImport")>marginLeft3</cfif>" style="border-collapse:collapse; border:none;width:1050px !important;" border="0" cellpadding="0" cellspacing="0">
												<tr>
													<cfif structKeyExists(session, "currentusertype") AND session.currentusertype EQ "Administrator">
														<td><a href="index.cfm?event=myLoad&#Session.URLToken#" <cfif event is 'Myload'> class="active" </cfif>>My Loads</a></td>
														<cfif ListContains(session.rightsList,'addEditDeleteAgents',',')>
															<cfset agentUrl = "index.cfm?event=agent&sortorder=asc&sortby=Name&#Session.URLToken#">
														<cfelse>
															<cfset agentUrl = "javascript: alert('Sorry!! You do not have rights to the Users screen.');">
														</cfif>
														<td><a href="#agentUrl#" <cfif listFindNoCase("agent,addagent,office,addoffice,AlertHistory", event)> class="active" </cfif>>Users</a></td>
														<td>
															<a href="index.cfm?event=customer&#Session.URLToken#" <cfif listFindNoCase("customer,addcustomer,CustomerContacts,addCustomerContact,CRMNotes,stop,addstop,createconsolidatedinvoices,consolidatedinvoicequeue,editconsolidatedinvoicequeue,customerCRMCalls,customerCRMCallHistory,customerCRMCallDetail", event)> class="active" </cfif>>Customers</a>
															<cfif request.qryCountCustomer.custCount  gt 0>
																<button title="#request.qryCountCustomer.custCount# Customer(s) CRM Due." style="background-color:#request.qSystemSetupOptions1.CustomerCRMCallBackCircleColor# !important;" class="unReadBtn" onclick="document.location.href='index.cfm?event=customerCRMReminder&#Session.URLToken#'">#request.qryCountCustomer.custCount#</button>
															</cfif>
														</td>
														
														<cfif request.qSystemSetupOptions1.freightBroker EQ 2>
															
															<td><a href="index.cfm?event=carrier&#Session.URLToken#&IsCarrier=1" <cfif (event is 'carrier' or event is 'addcarrier:process' or event is 'addnewcarrier' or event is 'addcarrier' or event is 'equipment' or event is 'equipment:process' or event is 'addequipment' or event is 'CarrierCRMNotes'  or event eq 'carrierCRMCalls'  or event eq 'carrierCRMCallHistory'  or event eq 'carrierCRMCallHistory'  or event eq 'CarrierAdvancedSearch' or event eq 'CarrierAdvanced') AND structKeyExists(url,"IsCarrier") AND url.IsCarrier EQ 1> class="active" </cfif>>
																		Carriers
																</a>
																<cfif request.qryCountCarrier.carrCount  gt 0>
																	<button title="#request.qryCountCarrier.carrCount# Carriers(s) CRM Due." style="background-color:#request.qSystemSetupOptions1.CarrierCRMCallBackCircleColor# !important;" class="unReadBtn" onclick="document.location.href='index.cfm?event=carrierCRMReminder&#Session.URLToken#&IsCarrier=1'">#request.qryCountCarrier.carrCount#</button>
																</cfif>
															</td>
															<td>
																<a href="index.cfm?event=carrier&#Session.URLToken#&IsCarrier=0" <cfif (event is 'carrier' or event is 'addcarrier:process' or event is 'addcarrier' or event is 'adddriver' or event is 'equipment' or event is 'equipment:process' or event is 'addequipment' or event eq 'maintenanceSetUp' or event eq 'ExpenseSetUp' or event eq 'IFTA' or event eq 'carrierCRMCalls' or event eq 'carrierCRMCallHistory'  or event eq 'carrierCRMCallHistory'  ) AND structKeyExists(url,"IsCarrier") AND url.IsCarrier EQ 0> class="active" </cfif>>							
																		Drivers	
																</a>

																<cfif request.qryCountDriver.carrCount  gt 0>
																	<button title="#request.qryCountDriver.carrCount# Driver(s) CRM due." style="background-color:#request.qSystemSetupOptions1.DriverCRMCallBackCircleColor# !important;" class="unReadBtn" onclick="document.location.href='index.cfm?event=carrierCRMReminder&#Session.URLToken#&IsCarrier=0'">#request.qryCountDriver.carrCount#</button>
																</cfif>
															</td>
														<cfelse>
															<td>
																<a href="index.cfm?event=carrier&#Session.URLToken#" <cfif event is 'carrier' or event is 'addcarrier:process' or event is 'addcarrier' or event is 'equipment' or event is 'equipment:process' or event is 'addequipment'  or event is 'CarrierCRMNotes' or event eq 'carrierCRMCalls' or event eq 'CarrierAdvancedSearch'or event eq 'CarrierAdvanced' or event eq 'carrierCRMCallHistory'  or event eq 'carrierCRMCallHistory'  > class="active" </cfif>>
																	<cfif request.qSystemSetupOptions1.freightBroker EQ 1>
																		Carriers
																	<cfelse>
																		Drivers															
																	</cfif>
																</a>

																<cfif request.qryCountCarrier.carrCount  gt 0>
																<button id="carrierDueBtn" title="#request.qryCountCarrier.carrCount# <cfif request.qSystemSetupOptions1.freightBroker EQ 1>Carrier<cfelse>Driver</cfif>(s) CRM due." style="background-color:<cfif request.qSystemSetupOptions1.freightBroker EQ 1>#request.qSystemSetupOptions1.CarrierCRMCallBackCircleColor#<cfelse>#request.qSystemSetupOptions1.DriverCRMCallBackCircleColor#</cfif> !important;" class="unReadBtn" onclick="document.location.href='index.cfm?event=carrierCRMReminder&#Session.URLToken#'">#request.qryCountCarrier.carrCount#</button>
																</cfif>
																
																<cfif not request.qSystemSetupOptions1.freightBroker>
																	<cfif request.qryCountEquipments.COMPUTED_COLUMN_1  gt 0>	
																		<button id="equipDueBtn" title="#request.qryCountEquipments.COMPUTED_COLUMN_1# Equipments Need maintenance." style="background-color:##77c9ff !important;" class="unReadBtn" onclick="document.location.href='index.cfm?event=equipment&EquipmentMaint=1&#Session.URLToken#'">#request.qryCountEquipments.COMPUTED_COLUMN_1#</button>
																	</cfif>
																</cfif>
															</td>
														</cfif>																
														
													<!--- </cfif> --->
													<td style="width:55px;"><cfif qEDI204PendingLoads.recordcount  gt 0>
																		<a href="index.cfm?event=EDILoads&#Session.URLToken#">
																			<span class="unReadMessage">
																				<span title="#qEDI204PendingLoads.recordcount# EDI Loads Pending." class="unread">#qEDI204PendingLoads.recordcount#</span>
																			</span>
																		</a>
																	</cfif><a href="index.cfm?event=load&#Session.URLToken#" <cfif event is 'load' or event is 'addload:process' or event is 'unit' or event is 'class' or event is 'addload' or event is 'addcustomerload' or event is 'addunit:process' or event is 'addunit' or event is 'addclass:process' or event is 'addclass' or event is 'advancedsearch' or event is 'Factoring' or event is 'addFactoring' or event is 'AIImport' or event is 'AIImportLoad' or event is 'quickRateAndMilesCalc' or event is 'BOLReport' or event is 'UploadCustomerPayment'> class="active" </cfif>>All Loads</a></td>
													<!--- <cfif Not structKeyExists(session, "IsCustomer")> --->
														
														
														<td><a href="index.cfm?event=myLoadNew&#Session.URLToken#" <cfif event is 'myLoadNew'> class="active" </cfif>>Dispatch Board</a></td>
														
														<cfif (ListContains(session.rightsList,'runReports',',') AND NOT ListContains(session.rightsList,'HideCustomerPricing',',')) OR ListContains(session.rightsList,'SalesRepReport',',')>
															<cfset reportUrl = "index.cfm?event=reports&#Session.URLToken#">
														<cfelse>
															<cfset reportUrl = "javascript: alert('Sorry!! You don\'t have rights to run any reports.');">
														</cfif>
														<td><a href="#reportUrl#" <cfif listFindNoCase("reports,QuickBooksExport,QuickBooksExportAP,QuickBooksExportHistory,QBNotExported,DriverSettlementReport,DashBoard,SalesDetail", event)> class="active" </cfif>>Reports</a></td>
														<cfif ListContains(session.rightsList,'modifySystemSetup',',') AND NOT ListContains(session.rightsList,'HideCustomerPricing',',')>
															<cfset sysSetupUrl = "index.cfm?event=companyinfo&#Session.URLToken#">
														<cfelse>
															<cfset sysSetupUrl = "javascript: alert('Sorry!! You don\'t have rights to modify System Setup.');">
														</cfif>
														<cfif Not structKeyExists(request, "qGetSystemSetupOptions")>
															<cfinvoke component="#variables.objloadGateway#" method="getSystemSetupOptions" returnvariable="request.qGetSystemSetupOptions" />
														</cfif>
														<td>
															<cfif NOT ListContains(session.rightsList,'HideCustomerPricing',',') AND session.currentusertype neq 'Data Entry' AND ListContains(session.rightsList,'AllowLogs',',')>
																<cfset logUrl = "index.cfm?event=loadLogs&#Session.URLToken#">
															<cfelse>
																<cfset logUrl = "javascript: alert('Sorry!! You don\'t have rights to logs.');">
															</cfif>
															<a href="#logUrl#" <cfif listFindNoCase("loadLogs,EDILog,Project44Log,EmailLog,TextLog,EdispatchLog,CsvImportLog,CarrierCsvImportLog,CustomerCsvImportLog,EquipmentCsvImportLog", event)> class="active" </cfif>>Logs</a></td>
														<td><a href="#sysSetupUrl#" <cfif listFind('systemsetup,companyinfo,loadstatussetup,crmNoteTypes,attachmentTypes,addCRMNoteType,addAttachmentType,OnboardCarrierDocs,AddOnBoardingDoc,OnboardSetting,OnboardEquipments,DocsTobeAttached,BillFromCompanies,AddBillFromCompany,userRoles', event)> class="active" </cfif>>Settings</a></td>
													<!--- </cfif> --->
														<cfif request.qSystemSetupOptions1.AccountingIntegration EQ 1 AND ListContains(session.rightsList,'Accounting',',')>
															<td style="width: 64px;"><a href="index.cfm?event=InvoiceLoads&#Session.URLToken#" <cfif listFindNoCase("InvoiceLoads,CustomerPayments,CreateCustomerInvoice,LMACustomerAgingReport,LMACustomerStatementReport,LMAPrintCashReceipts,CustomerInquiry,InvoiceCarrierLoads,CreateVendorInvoice,InvoiceToPay,PrintChecks,LMAVendorAgingReport,LMAInvoicesPickedtoPay,VendorInquiry,PostInvoicePayment,VoidInvoicePayment,ListChartofAccounts,ChartofAccounts,FindGLTransactions,BankAccounts,LMAPrintTrialBalance,LMAPrintIncomeStatement,LMAPrintBalanceSheet,JournalEntry,PostJournalEntry,Departments,AccountDepartments,LMAPrintLedgerReport,LMASettings,PaymentTerms,addLMAPaymentTerms,GeneralLedgerFinancialSetup,GeneralLedgerBalanceSheetSetup,OpenNewYear,GLRecalculate,VoidCustomerPayment", event)> class="active" </cfif>>Accounting</a></td>
														</cfif>
														<td class="nobg"><a id="logout" href="index.cfm?event=logout:process&#Session.URLToken#">Logout</a></td>
													<cfelse>
														<td style="width:55px;">
															<a href="index.cfm?event=load&#Session.URLToken#" <cfif listFindNoCase("load,addload", event)> class="active" </cfif>>All Loads</a>
														</td>
														<cfif NOT structKeyExists(session, "iscustomer")>
															<td>
																<a href="index.cfm?event=customer&#Session.URLToken#" <cfif listFindNoCase("customer,addcustomer", event)> class="active" </cfif>>Brokers</a>
															</td>
														</cfif>
														<td class="nobg"><a id="logout" href="index.cfm?event=logout:process&#Session.URLToken#">Logout</a></td>
													</cfif>
												</tr>
											</table>
									 
											<div class="below-nav   <cfif structKeyExists(url,"event") AND (url.event EQ "load" OR  url.event EQ "myLoad"  OR  url.event EQ "carrierquotes" OR  url.event EQ "AIImport")>marginLeft3</cfif>" style="width:1050px !important;"> #request.subnavigation#
												<div class="clear"></div>
											</div>
										</cfif>
										
										</td>
										
								</tr>
								</cfif>
							</table></td>
					</tr>
					 
					<tr>
						<td valign="top"><cfif StructKeyExists(request, "content") Or Not StructKeyExists(request, "tabs")>
								<div class="content"></div>
								<cfif StructKeyExists(request, "alertMessage")>
									#request.alertMessage#
								</cfif>
								<div class="subheading">
									<cfif StructKeyExists(request, "SubHeading")>
										#request.SubHeading#
									</cfif>
								</div>
                      <!---Content Area for Dispatcher Board Tab--->          
                                <cfif event eq 'dispatchboard'>
									<div class="content-area-for-dispatcher-board" style="height:100%;">
                                
                                <cfelse>
                       <!---Content Area for other Tabs--->                   
                                	<div class="content-area #variables.ClassName#" style="height:100%;">
                                </cfif>
									<cfif StructKeyExists(request, "content")>
										#request.content#
									</cfif>
								</div>
								<cfelseif StructKeyExists(request, "tabs")>
									#request.tabs#
							</cfif></td>
					</tr>
				</table>
			</div>
			<cfif Session.blnDebugMode>
				<br>
				<br>
				<cfset structToDump = StructNew() />
				<cfif IsDefined("Session.Passport")>
					<cfloop list="#StructKeyList(Session.Passport, ',')#" index="strKey">
						<cfif strKey NEQ "CurrentSiteUser">
							<cfset structToDump[strKey] = Duplicate(Session.Passport[strKey]) />
						</cfif>
					</cfloop>
				</cfif>
				<cfif IsDefined("Session.Passport.CurrentSiteUser")>
					<cfset structToDump.CurrentSiteUser = Session.Passport.CurrentSiteUser.dump() />
				</cfif>
			</cfif>
			<cfif structKeyExists(session, "currentusertype") AND session.currentusertype EQ "Administrator">
				<script type="text/javascript" nonce="#ToBase64("LoadManagerLive")#" src="https://desk.zoho.com/portal/api/web/inapp/133848000009815001?orgId=569278284" defer></script>
			</cfif>
		</body>
	</html>
	<cfif (isdefined("url.loadid") and len(trim(url.loadid)) gt 1) OR (isdefined("url.loadToBeCopied") and len(trim(url.loadToBeCopied)) gt 1)>
		<cfparam name="NewcustomerID" default="">
		<script>
	<cfif isdefined('carrierID') and (len(carrierID) gt 1 or len(carrierIDNew) gt 1)>
	</cfif>
	<cfif isdefined('totStops')>
		<cfloop from="2" to="#totStops#" index="stpNo"> 
			useCarrierNext('#application.dsn#',0,#stpNo#,'#session.URLToken#');
		</cfloop> 
	</cfif>
</script>
	</cfif>
	<script>
//	{
		
		window.onbeforeunload = function (evt) 
		{

			var unlockCreatedStatus=true;
			if($("##loaddisabledStatus").length){
				unlockCreatedStatus=$("##loaddisabledStatus").val();
			}
			if(unlockCreatedStatus == true){	
				var path = urlComponentPath+"loadgateway.cfc?method=getAjaxSession";
			} else{
				if($("##editid").length){
					var editid=$("##editid").val();
					if($("##appDsn").length && $("##tabid").length){
						var dsn=$("##appDsn").val();
						var tabid=$("##tabid").val();
						console.log($("##tabid").val());
						<cfif structkeyexists(session,"sessionid") and structKeyExists(session,"empid")>
							var path = urlComponentPath+"loadgateway.cfc?method=getAjaxSession&UnlockStatus="+unlockCreatedStatus+"&loadid="+editid+"&dsn="+dsn+"&sessionid=#session.sessionid#&userid=#session.empid#&tabid="+tabid;
						</cfif>	
					}else{
						var path = urlComponentPath+"loadgateway.cfc?method=getAjaxSession";
					}
				}else{
					var path = urlComponentPath+"loadgateway.cfc?method=getAjaxSession";
				}
				
			}
            var confirmSession = "";

            <cfif structkeyexists(url,"event") and url.event eq "addload">
	            <cfif not structKeyExists(request, "qSystemSetupOptions")>
	            	<cfinvoke component="#variables.objloadGateway#" method="getSystemSetupOptions" returnvariable="request.qSystemSetupOptions" />
	            </cfif>
				$.ajax({
	                type: "get",
	                url: path,		
	                dataType: "json",
	                success: function(data){
	                  confirmSession = data.sessionCheck;
	                }
	            });
	        <cfelse>
	            $.ajax({
	                type: "get",
	                url: path,		
	                dataType: "json",
	                success: function(data){
	                  confirmSession = data.sessionCheck;
	                }
	              });
          	</cfif>

		<cfif isdefined('session.checkUnload') and session.checkUnload eq 'add'>
				if (chkLoad==0 && typeof document.activeElement.href != 'undefined'){
				var message = 'Are you sure you want to leave? Your work is not saved!';
				if (typeof evt == 'undefined') 
				{//IE
					evt = window.event;
				}
				if (evt) 
				{
					evt.returnValue = message;
				}
				<cfset session.checkUnload = ''>
				}
				console.log(message);
				console.log(evt);
			return message;
			</cfif> 
		 }


		/**
		*  Extending window.onbeforeunload for locking other record types
		*/
		$(function() { //Document ready begins

			var existingUnloadHandler = window.onbeforeunload;
			
			var page = {
				customer: {
					gateway : 'customergateway',
					param : 'customerid',
					statusField : 'customerdisabledStatus'
				},
				carrier: {
					gateway: 'carriergateway',
					param: 'carrierid',
					statusField : 'carrierdisabledStatus'
				},
				agent: {
					gateway: 'agentgateway',
					param: 'agentid',
					statusField: 'agentdisabledStatus'
				},
				equipment: {
					gateway: 'equipmentgateway',
					param: 'equipmentid',
					statusField: 'equipmentdisabledStatus'
				}
			};

			window.onbeforeunload = function ( event ) {
			  
			if (existingUnloadHandler) {
				existingUnloadHandler(event);
			} 

				getAjaxSession( page.customer );
			 	getAjaxSession( page.carrier );
			 	getAjaxSession( page.agent );
			 	getAjaxSession( page.equipment );
				var clicked = $( document.activeElement );
				<cfif structKeyExists(url, "Event") AND url.event EQ 'alertDetail'>
					var lockeduser = $('##lockeduser').val();
					var CurrUser = $('##CurrUser').val();
					if($.trim(lockeduser) == $.trim(CurrUser)){
						$.ajax({
				            type: "get",
				            url: urlComponentPath+"alertgateway.cfc?method=unLockAlertForCurrentUser&AlertID=#url.AlertID#",		
				            dataType: "json",
				            success: function(data){
				            }
				        });
					}
				</cfif>
				<cfif structKeyExists(session, "EmpID")>
					if($(document.activeElement).html()=='Logout'){
						$.ajax({
				            type: "get",
				            url: urlComponentPath+"alertgateway.cfc?method=unLockAlertForCurrentUser&EmpID=#session.EmpID#",		
				            dataType: "json",
				            success: function(data){
				            }
				        });
					}
				</cfif>
 			};

 			// Sends required XHR params to release / maintain record lock on Page Leave event
 			function getAjaxSession( page ) {
	
	 			var gateway = page.gateway,
 					param = page.param,
 					statusField = $('##'+ page.statusField );
		
	 			isSaveEvent = $("##isSaveEvent").length ? $('##isSaveEvent').val() : false;
	
				var unlockCreatedStatus=true;
			
				if(statusField.length) {
					unlockCreatedStatus = statusField.val();
				}

				if(unlockCreatedStatus == true) {
					var path = urlComponentPath + gateway + ".cfc?method=getAjaxSession";
				} else {

				if($("##editid").length) {

					var editid=$("##editid").val();

					if( $( "##appDsn" ).length && $( "##tabid" ).length ) {

						var dsn=$("##appDsn").val();
						var tabid=$("##tabid").val();
						
						<cfif structkeyexists(session,"sessionid") and structKeyExists(session,"empid")>

							var path = urlComponentPath + gateway + ".cfc?method=getAjaxSession&UnlockStatus="+unlockCreatedStatus+"&" + param  + "="+editid+"&dsn="+dsn+"&sessionid=#session.sessionid#&userid=#session.empid#&tabid="+tabid;

							if( isSaveEvent == true || isSaveEvent == "true")
							{
								path += '&saveEvent=true';
							}

						</cfif>	

					} else {
						var path = urlComponentPath + gateway + ".cfc?method=getAjaxSession";
					}
				} else {
					var path = urlComponentPath + gateway + ".cfc?method=getAjaxSession";
				}
				
				}

	        $.ajax({
		            type: "get",
		            url: path,		
		            dataType: "json",
		            success: function(data){
		            }
		          });
 			}		
		}); // Document ready ends 
</script>
<script>
	<cfif structKeyExists(session, "rightsList") AND listFindNoCase(session.rightsList, 'addEditLoadOnly')>
		$(document).ready(function(){
			$( ".navigation a" ).click(function() {
				if($(this).html() !='All Loads' && $(this).html() !='My Loads' && $(this).html() !='Logout' && $(this).html() !='Home'){
					alert('Sorry!! You do not have rights to the '+$.trim($(this).html())+' screen.');
			  		return false;
				}
			})
			$( ".below-nav a" ).click(function() {
				if($(this).html() !='All Loads' && $(this).html() !='Add Load'){
					alert('Sorry!! You do not have rights to the '+$.trim($(this).html())+' screen.');
			  		return false;
				}
			})
		})
	</cfif>
</script>
<cfif structKeyExists(variables,"testTime")>
	<!---------To display the time taken to load-------->
	<div style="position:absolute;right:439px;margin-top:-15px;"><font size="4" weight="bold">Time taken to load: #testTime# milliseconds</font></div>
</cfif>
<cfif structKeyExists(url, "event") and url.event EQ 'AddLoad'>
	<div id="responseLoadBoard">
		<cfif structKeyExists(url, 'AlertvarDF') and trim(url.AlertvarDF) neq "1">
			<p>
				<b>Direct Freight: </b>
				<span style="color:<cfif findNoCase("success", url.AlertvarDF)>##0f4100<cfelse>##800000</cfif>" >
					#replaceNoCase(url.AlertvarDF, "Direct Freight Loadboard Says : ", "")#
				</span>
			</p>
		</cfif>
		<cfif structKeyExists(url, 'Ialert') and trim(url.Ialert) neq "1" and findNoCase("ITS", url.Ialert)>
			<p>
				<b>Truckstop: </b>
				<span style="color:<cfif findNoCase("success", url.Ialert)>##0f4100<cfelse>##800000</cfif>">
					#replaceNoCase(url.Ialert, "ITS Says : ", "")#
				</span>
			</p>
		</cfif>
		<cfif structKeyExists(url, 'AlertvarI') and trim(url.AlertvarI) neq "1" and findNoCase("ITS", url.AlertvarI)>
			<p>
				<b>Truckstop: </b>
				<span style="color:<cfif findNoCase("success", url.AlertvarI)>##0f4100<cfelse>##800000</cfif>">
					#replaceNoCase(url.AlertvarI, "ITS Says : ", "")#
				</span>
			</p>
		</cfif>
		<cfif structKeyExists(url, 'Palert') and trim(url.Palert) neq "1" and findNoCase("Post Everywhere", url.Palert) >
				<p>
					<b>Loadboard Network: </b>
					<span style="color:<cfif findNoCase("success", url.Palert)>##0f4100<cfelse>##800000</cfif>">
					#replaceNoCase(url.Palert, "Post Everywhere Says : ", "")#
				</span>
			</p>
		</cfif>
		<cfif structKeyExists(url, 'AlertvarT') and trim(url.AlertvarT) neq "1" and findNoCase("Post Everywhere", url.AlertvarT) >
			<p>
				<b>Loadboard Network: </b>
				<span style="color:<cfif findNoCase("success", url.AlertvarT)>##0f4100<cfelse>##800000</cfif>">
					#replaceNoCase(url.AlertvarT, "Post Everywhere Says : ", "")#
				</span>
			</p>
		</cfif>
		<cfif structKeyExists(url, 'Palert') and trim(url.Palert) neq "1" and findNoCase("Dat Loadboard", url.Palert) >
			<p>
				<b>DAT: </b>
					<span style="color:<cfif findNoCase("success", url.Palert)>##0f4100<cfelse>##800000</cfif>">
					#replaceNoCase(url.Palert, "Dat Loadboard Says : ", "")#
				</span>
			</p>
		</cfif>
		<cfif structKeyExists(url, 'AlertvarP') and trim(url.AlertvarP) neq "1" and findNoCase("Dat Loadboard", url.AlertvarP) >
			<p>
				<b>DAT: </b>
				<span style="color:<cfif findNoCase("success", url.AlertvarP)>##0f4100<cfelse>##800000</cfif>">
					#replaceNoCase(url.AlertvarP, "Dat Loadboard Says : ", "")#
				</span>
			</p>
		</cfif>
		<cfif structKeyExists(url, 'AlertvarN') and trim(url.AlertvarN) neq "1" and findNoCase("123Loadboard", url.AlertvarN) >
			<p>
				<b>123LoadBoard: </b>
				<span style="color:<cfif findNoCase("success", url.AlertvarN)>##0f4100<cfelse>##800000</cfif>">
					#replaceNoCase(url.AlertvarN, "123Loadboard Says : ", "")#
				</span>
			</p>
		</cfif>
		<cfif structKeyExists(url, 'AlertvarM') and trim(url.AlertvarM) neq "1" and findNoCase("123Loadboard", url.AlertvarM) >
			<p>
				<b>123LoadBoard: </b>
				<span style="color:<cfif findNoCase("success", url.AlertvarM)>##0f4100<cfelse>##800000</cfif>">
					#replaceNoCase(url.AlertvarM, "123Loadboard Says : ", "")#
				</span>
			</p>
		</cfif>
	</div>
	<script>
		$(document).ready(function(){
			var resp = $('##responseLoadBoard').html();
			if($.trim(resp).length){
				$("##responseLoadBoard").dialog({
					resizable: false,
					modal: true,
					title: "LOAD BOARD POSTING RESULTS",
					height: 200,
					width: 600,
					open: function( e, ui ) {
				        $( this ).siblings( ".ui-dialog-titlebar" )
				                 .find( "button" ).blur(); 
				    }
				});
			}
			
		});
	</script>
	<style>
		.ui-dialog-title{
			font-size: 11pt;
		}
		##responseLoadBoard p{
			font-size: 12pt;	
		}
		.ui-icon-closethick {
		    background-image: url(images/delete-icon.gif) !important;
		    background-position: left top !important;
		    //margin: 0 !important;
		}
	</style>
</cfif>

<cfif structKeyExists(url, "event") and url.event EQ 'myLoad'>
	<div id="responseLoadBoard">
		<cfif structKeyExists(url, 'AlertvarDF') and trim(url.AlertvarDF) neq "1">
			<p>
				<b>Direct Freight: </b>
				<span style="color:<cfif findNoCase("success", url.AlertvarDF)>##0f4100<cfelse>##800000</cfif>">
					#replaceNoCase(url.AlertvarDF, "Direct Freight Loadboard Says : ", "")#
				</span>
			</p>
		</cfif>
		<cfif structKeyExists(url, 'AlertvarI') and trim(url.AlertvarI) neq "1" and findNoCase("ITS", url.AlertvarI)>
			<p>
				<b>Truckstop: </b>
				<span style="color:<cfif findNoCase("success", url.AlertvarI)>##0f4100<cfelse>##800000</cfif>">
					#replaceNoCase(url.AlertvarI, "ITS Says : ", "")#
				</span>
			</p>
		</cfif>
		<cfif structKeyExists(url, 'AlertvarP') and trim(url.AlertvarP) neq "1" and findNoCase("Post Everywhere", url.AlertvarP) >
			<p>
				<b>Loadboard Network: </b>
				<span style="color:<cfif findNoCase("success", url.AlertvarP)>##0f4100<cfelse>##800000</cfif>">
					#replaceNoCase(url.AlertvarP, "Post Everywhere Says : ", "")#
				</span>
			</p>
		</cfif>
		<cfif structKeyExists(url, 'Palert') and trim(url.Palert) neq "1" and findNoCase("Dat Loadboard", url.Palert) >
			<p>
				<b>DAT: </b>
				<span style="color:<cfif findNoCase("success", url.Palert)>##0f4100<cfelse>##800000</cfif>">
					#replaceNoCase(url.Palert, "Dat Loadboard Says : ", "")#
				</span>
			</p>
		</cfif>
		<cfif structKeyExists(url, 'AlertvarN') and trim(url.AlertvarN) neq "1" and findNoCase("123Loadboard", url.AlertvarN) >
			<p>
				<b>123LoadBoard: </b>
				<span style="color:<cfif findNoCase("success", url.AlertvarN)>##0f4100<cfelse>##800000</cfif>">
					#replaceNoCase(url.AlertvarN, "123Loadboard Says : ", "")#
				</span>
			</p>
		</cfif>
		<cfif structKeyExists(url, 'AlertvarM') and trim(url.AlertvarM) neq "1" and findNoCase("123Loadboard", url.AlertvarM) >
			<p>
				<b>123LoadBoard: </b>
				<span style="color:<cfif findNoCase("success", url.AlertvarM)>##0f4100<cfelse>##800000</cfif>">
					#replaceNoCase(url.AlertvarM, "123Loadboard Says : ", "")#
				</span>
			</p>
		</cfif>
	</div>
	<script>
		$(document).ready(function(){
			var resp = $('##responseLoadBoard').html();
			if($.trim(resp).length){
				$("##responseLoadBoard").dialog({
					resizable: false,
					modal: true,
					title: "LOAD BOARD POSTING RESULTS",
					height: 200,
					width: 600,
					open: function( e, ui ) {
				        $( this ).siblings( ".ui-dialog-titlebar" )
				                 .find( "button" ).blur(); 
				    }
				});
			}
			
		});
	</script>
	<style>
		.ui-dialog-title{
			font-size: 11pt;
		}
		##responseLoadBoard p{
			font-size: 12pt;	
		}
	</style>
</cfif>
	<script>
		$(document).ready(function(){
			var Tab = $.trim($('.navigation').find('.active').text()); 
			if(Tab=='Accounting'){
				var SubMenu = $.trim($('.nav-with-sub-menu').find('.active').text()); 
			}
			else{
				var SubMenu = $.trim($('.below-navleft').find('.active').text()); 
			}
			var path = urlComponentPath+"agentgateway.cfc?method=getHelpSettings";
			$.ajax({
				type: "get",
				url: path,		
				dataType: "json",
				data: {
					Tab:Tab,SubMenu:SubMenu
				},
				success: function(helpLink){
				 	if(helpLink.length){
				 		$('##helpLink').html('<a href="'+helpLink+'" style="color: ##c1d5ed;font-size: 14px;" target="_blank">Help</a>');
				 	}
				}
			});
			var path = urlComponentPath+"agentgateway.cfc?method=getInfoBubble";
			var infoBubbleHtml = '<img src="images/information.png" class="InfotoolTip" style="width:22px;cursor:pointer;float: left;" title="">'

			$.ajax({
				type: "get",
				url: path,		
				dataType: "json",
				async:true,
				data: {
					Tab:Tab,SubMenu:SubMenu
				},
				success: function(data){
					jQuery.each(data, function(index, item) {
						$('label').each(function(index) {
							var innerText = $.trim($(this).html()).replace(":","").replace("*","");

							if(item.Label == innerText){
								if(item.Field==1){
									var ele = $(this).next('input,select');
								}
								else{
									var ele = $(this);
								}
								if(item.InsertAfter==1){
									if(item.Label == "Driver Cell"){
										var readonly = $(ele).attr("readonly");
										var val = $(ele).val();
										if(readonly=="readonly" && $.trim(val).length){
											$(infoBubbleHtml).insertAfter(ele).tooltip({
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
										  		},
										  		content : item.Information
											});
										}
									}
									else{
										$(infoBubbleHtml).insertAfter(ele).tooltip({
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
									  		},
									  		content : item.Information
										});
									}
									
								}
								else{
									$(infoBubbleHtml).insertBefore(ele).tooltip({
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
								  		},
								  		content : item.Information
									});
								}
							}
						});

						$('div.automatic_notes_heading').each(function(index) {
							var innerText = $.trim($(this).html()).replace(":","").replace("*","");
							var infoBubbleHtml = '<img src="images/information.png" class="InfotoolTip" style="width:22px;cursor:pointer;" title="">'
							if(item.Label == innerText){
								if(item.Field==1){
									var ele = $(this).next('input,select');
								}
								else{
									var ele = $(this);
								}
								if(item.InsertAfter==1){
									$(ele).append(infoBubbleHtml).tooltip({
									//$(infoBubbleHtml).insertAfter(ele).tooltip({
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
								  		},
								  		content : item.Information
									});
								}
								else{
									$(infoBubbleHtml).insertBefore(ele).tooltip({
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
								  		},
								  		content : item.Information
									});
								}
							}
						});

						$('th').each(function(index) {
							var innerText = $.trim($(this).html());
							if(item.Label == innerText){
								var pTable = $(this).closest('table');
								var thIndex = $(this).index()+1;
								if(item.InsertAfter==1){
									$(pTable).find("tbody td.normaltd:nth-child("+thIndex+")").append(infoBubbleHtml).tooltip({
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
								  		},
								  		content : item.Information
									});
								}
								else{
									$(pTable).find("tbody td.normaltd:nth-child("+thIndex+")").prepend(infoBubbleHtml).tooltip({
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
								  		},
								  		content : item.Information
									});
								}
							}
						})

						<cfif structKeyExists(url, "event") and url.event eq 'BOLReport'>
							if(Tab=='All Loads' && SubMenu=='Add Load' && item.Label=='BOL'){
								var bolTablePos = $('##AccessorialsTable').position();
								var infoBubbleHtml = '<img src="images/information.png" class="InfotoolTip" style="width:22px;cursor:pointer;position:absolute;left:'+(bolTablePos.left-22)+'px;" title="">'
								$(infoBubbleHtml).insertBefore('##AccessorialsTable').tooltip({
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
							  		},
							  		content : item.Information
								});
							}
						</cfif>

					});
				}
			});

			if($('##carrierDueBtn').length && $('##equipDueBtn').length){
				var equipDueBtnPos = $('##equipDueBtn').position();
				var carrierDueBtnPos = $('##carrierDueBtn').position();
				$("##equipDueBtn").css({left: equipDueBtnPos.left+12, position:'absolute'});
				$("##carrierDueBtn").css({left: carrierDueBtnPos.left-12, position:'absolute'});
			}

		});
	</script>
    <cfif structkeyexists(session,"SMTPValidOnLogin")>
    	<cfif not session.SMTPValidOnLogin>
			<div id="dialog_smtp" title="Alert">
			  	<p>Your email settings are NOT correct. <a target="_blank" style="text-decoration:underline;" href="https://loadmanager.zohodesk.com/portal/en/kb/articles/set-up">Learn More</a></p>
			</div>
			<cfset structDelete(session, "SMTPValidOnLogin")>
			<script type="text/javascript">
				$(document).ready(function(){
	        		$( "##dialog_smtp" ).dialog({
	        			width : 330,
	        			buttons: {
	    					Ok: function() {
	  							$( this ).dialog( "close" );
							}
	  					},
	  					open: function(event,ui) {
					        $(this).parent().focus();
					        $( ".overlay" ).show();
					    },
					    close: function( event, ui ) {
					    	$( ".overlay" ).hide();
					    }
	        		});
				})
			</script>	
		</cfif>
	</cfif>
</cfoutput>
