<cfoutput>
<cfsilent>
<cfimport taglib="../../../plugins/customtags/mytag/" prefix="myoffices" >
<!---Init default Value------->
<cfparam name="CustomerStatusID" default="">
<cfparam name="CustomerCode" default="">
<cfparam name="MCNumber" default="">
<cfparam name="DOTNumber" default="">
<cfparam name="CustomerName" default="">
<cfparam name="OfficeID" default="">
<cfparam name="OfficeID1" default="">
<cfparam name="Location" default="">
<cfparam name="City" default="">
<cfparam name="State1" default="">
<cfparam name="Zipcode" default="">
<cfparam name="TimeZone" default="">
<cfparam name="ContactPerson" default="">
<cfparam name="MobileNo" default="">
<cfparam name="MobileNoExt" default="">
<cfparam name="PhoneNO" default="">
<cfparam name="PhoneNOExt" default="">
<cfparam name="Email" default="">
<cfparam name="Fax" default="">
<cfparam name="FaxExt" default="">
<cfparam name="Tollfree" default="">
<cfparam name="TollfreeExt" default="">
<cfparam name="website" default="http://">
<cfparam name="country1" default="9bc066a3-2961-4410-b4ed-537cf4ee282a">
<cfparam name="SalesRepID" default="">
<cfparam name="AcctMGRID" default="">
<cfparam name="SalesRepID2" default="">
<cfparam name="AcctMGRID2" default="">
<cfparam name="LoadPotential" default="">
<cfparam name="RatePerMile" default="0">
<cfparam name="BillFromCompany" default="">
<cfparam name="BestOpp" default="#request.qgetsystemsetupoptions.CustomerPaymentTerms#">
<cfparam name="CustomerDirections" default="">
<cfparam name="CustomerNotes" default="">
<cfparam name="InternalNotes" default="">
<cfparam name="CarrierNotes" default="">
<cfparam name="IsPayer" default="1">
<cfparam name="FinanceID" default="">
<cfparam name="CreditLimit" default="">
<cfparam name="Balance" default="0">
<cfparam name="Available" default="">
<cfparam name="url.editid" default="0">
<cfparam name="url.customerid" default="0">
<cfparam name="salesperson" default="">
<cfparam name="Dispatcher" default="">
<cfparam name="EDIPartnerID" default="">
<cfparam name="UserName" default="">
<cfparam name="Password" default="">
<cfparam name="RemitName" default="">
<cfparam name="RemitAddress" default="">
<cfparam name="RemitCity" default="">
<cfparam name="RemitState" default="">
<cfparam name="RemitZipCode" default="">
<cfparam name="RemitContact" default="">
<cfparam name="RemitPhone" default="">
<cfparam name="RemitFax" default="">
<cfparam name="variables.customerdisabledStatus" default="false"> 
<cfparam name="defaultCurrency" default="0">
<cfparam name="CustomerTerms" default="">
<cfparam name="ConsolidateInvoices" default="0">
<cfparam name="SeperateJobPo" default="0">
<cfparam name="custFactoringID" default=""> 
<cfparam name="LockSalesAgentOnLoad" default="0">
<cfparam name="LockDispatcherOnLoad" default="0">
<cfparam name="LockDispatcher2OnLoad" default="0">
<cfparam name="IncludeIndividualInvoices" default="0">
<cfparam name="ConsolidateInvoiceBOL" default="0">
<cfparam name="ConsolidateInvoiceRef" default="0">
<cfparam name="ConsolidateInvoiceDate" default="0">
<!--- Encrypt String --->
<cfset Secret = application.dsn>
<cfset TheKey = 'NAMASKARAM'>
<cfset Encrypted = Encrypt(Secret, TheKey)>
<cfset dsn = URLEncodedFormat(ToBase64(Encrypted))>
<cfinvoke component="#variables.objloadGateway#" method="getcurAgentMaildetails" returnvariable="request.qcurMailAgentdetails" employeID="#session.empid#" />
	<cfif request.qcurMailAgentdetails.recordcount gt 0 and (request.qcurMailAgentdetails.SmtpAddress eq "" or request.qcurMailAgentdetails.SmtpUsername eq "" or request.qcurMailAgentdetails.SmtpPort eq "" or request.qcurMailAgentdetails.SmtpPassword eq "" or request.qcurMailAgentdetails.SmtpPort eq 0)>
	  <cfset mailsettings = "false">
  <cfelse>
	  <cfset mailsettings = "true">
  </cfif>
<cfinvoke component="#variables.objloadGateway#" method="getLoadSystemSetupOptions" returnvariable="request.qSystemSetupOptions" />
<cfinvoke component="#variables.objagentGateway#" method="getBillFromCompanies" returnvariable="request.qBillFromCompanies" />
<cfif request.qSystemSetupOptions.ForeignCurrencyEnabled>
	<cfinvoke component="#variables.objloadGateway#" method="getCurrencies" IsActive="1" returnvariable="request.qGetCurrencies" />
</cfif>

<cfif request.qSystemSetupOptions.freightBroker>
	<cfset variables.freightBroker = "Carrier">
<cfelse>
	<cfset variables.freightBroker = "Driver">
</cfif>
</cfsilent>

<cfif isdefined("url.customerid") and len(trim(url.customerid)) gt 1>
	<cfinvoke component="#variables.objCutomerGateway#" method="getAllCustomers" CustomerID="#url.customerid#" returnvariable="request.qCustomer" />
	<cfif not request.qCustomer.recordcount>
		<cflocation url="index.cfm?event=customer&#session.URLToken#" />
	</cfif>
	<cfset CustomerStatusID=#request.qCustomer.CustomerStatusID#>
	<cfset CustomerCode=#request.qCustomer.CustomerCode#>
	<cfset MCNumber=#request.qCustomer.MCNumber#>
	<cfset DOTNumber=#request.qCustomer.DOTNumber#>
	<cfset CustomerName=#request.qCustomer.CustomerName#>
	<cfset OfficeID1=#request.qCustomer.MultipleOfficeIDs#>
	<cfset Location=#request.qCustomer.Location#>
	<cfset City=#request.qCustomer.City#>
	<cfset State1=#request.qCustomer.Statecode#>
	<cfset Zipcode=#request.qCustomer.Zipcode#>
	<cfset TimeZone=#request.qCustomer.TimeZone#>
	<cfset ContactPerson=#request.qCustomer.ContactPerson#>
	<cfset MobileNo=#request.qCustomer.PersonMobileNo#>
	<cfset MobileNoExt=#request.qCustomer.MobileNoExt#>
	<cfset PhoneNo=#request.qCustomer.PhoneNo#>
	<cfset PhoneNoExt=#request.qCustomer.PhoneNoExt#>
	<cfset Tollfree=#request.qCustomer.Tollfree#>
	<cfset TollfreeExt=#request.qCustomer.TollfreeExt#>
	<cfset Fax=#request.qCustomer.Fax#>
	<cfset FaxExt=#request.qCustomer.FaxExt#>
	<cfset Email=#request.qCustomer.Email#>
	<cfset Website=#request.qCustomer.Website#>
	<cfset SalesRepID=#request.qCustomer.SalesRepID#>
	<cfset AcctMGRID=#request.qCustomer.AcctMGRID#>
	<cfset SalesRepID2=#request.qCustomer.SalesRepID2#>
	<cfset AcctMGRID2=#request.qCustomer.AcctMGRID2#>
	<cfset LoadPotential=#request.qCustomer.LoadPotential#>
    <cfset RatePerMile=#request.qCustomer.RatePrMile#>
	<cfset BillFromCompany=#request.qCustomer.BillFromCompany#>
	<cfset BestOpp=#request.qCustomer.BestOpp#>
	<cfset CustomerDirections=#request.qCustomer.CustomerDirections#>
	<cfset CustomerNotes=#request.qCustomer.CustomerNotes#>
	<cfset InternalNotes=#request.qCustomer.InternalNotes#>
	<cfset ConsolidateInvoices=#request.qCustomer.ConsolidateInvoices#>
	<cfset LockSalesAgentOnLoad=#request.qCustomer.LockSalesAgentOnLoad#>
	<cfset LockDispatcherOnLoad=#request.qCustomer.LockDispatcherOnLoad#>
	<cfset LockDispatcher2OnLoad=#request.qCustomer.LockDispatcher2OnLoad#>
	<cfset SeperateJobPo=#request.qCustomer.SeperateJobPo#>
	<cfset IncludeIndividualInvoices=#request.qCustomer.IncludeIndividualInvoices#>
	<cfset CarrierNotes=#request.qCustomer.CarrierNotes#>
	<cfset IsPayer=#request.qCustomer.IsPayer#>
	<cfset FinanceID=#request.qCustomer.FinanceID#>
	<cfset CreditLimit=#request.qCustomer.CreditLimit#>
	<cfset Balance=#request.qCustomer.Balance#>
	<cfset Available=#request.qCustomer.Available#>
	<cfset country1=#request.qCustomer.countryID#>
	<cfset UserName=#request.qCustomer.UserName#>
	<cfset Password=#request.qCustomer.Password#>
	<cfset editid="#url.customerid#">
	<cfset RemitName=request.qCustomer.RemitName>
	<cfset RemitAddress=request.qCustomer.RemitAddress>
	<cfset RemitCity=request.qCustomer.RemitCity>
	<cfset RemitState=request.qCustomer.RemitState>
	<cfset RemitZipCode=request.qCustomer.RemitZipCode>
	<cfset RemitContact=request.qCustomer.RemitContact>
	<cfset RemitPhone=request.qCustomer.RemitPhone>
	<cfset RemitFax=request.qCustomer.RemitFax>
	<cfset defaultCurrency=request.qCustomer.defaultCurrency>
	<cfset EDIPartnerID=request.qCustomer.EDIPartnerID>
	<cfset CustomerTerms=#request.qCustomer.CustomerTerms#>
	<cfset custFactoringID=#request.qCustomer.FactoringID#>
	<cfset ConsolidateInvoiceBOL=#request.qCustomer.ConsolidateInvoiceBOL#>
	<cfset ConsolidateInvoiceRef=#request.qCustomer.ConsolidateInvoiceRef#>
	<cfset ConsolidateInvoiceDate=#request.qCustomer.ConsolidateInvoiceDate#>
	<script>			
		$(document).ready(function(){
			//when the page loads for load edit ajax call for inserting tab id of the page details
			var path = urlComponentPath+"customergateway.cfc?method=insertTabDetails";
			$.ajax({
	            type: "Post",
	            url: path,
	            dataType: "json",
	            async: false,
				data: {
					tabID:tabID,customerid:'#request.qCustomer.CustomerId#',userid:'#session.empid#',sessionid:'#session.sessionid#',dsn:'#application.dsn#'
				},
	            success: function(data){
	            }
          	});
          	var path = urlComponentPath+"customergateway.cfc?method=CheckCustomerMissingAttachment";
            $.ajax({
                type: "Post",
                url: path,
                dataType: "json",
                data: {
                    CustomerId:'#request.qCustomer.CustomerId#',companyid:'#session.companyid#',dsn:'#application.dsn#'
                },
                success: function(data){
                    if(data==1){
                        $('##missingReqAtt').show();
                    }
                }
            });
		});
	</script>
	<!---Object to get corresponding user edited the customer--->
	<cfinvoke component="#variables.objCutomerGateway#" method="getUserEditingDetails" customerid="#request.qCustomer.CustomerID#" returnvariable="request.qryCustomerEditingDetails"/>

	
		<!---Condition to check user edited the customer or not--->
	<cfif not len(trim(request.qryCustomerEditingDetails.InUseBy))>
		<!---Object to update corresponding user edited the customer--->
		<cfinvoke component="#variables.objCutomerGateway#" method="updateEditingUserId" customerid="#request.qCustomer.CustomerID#" userid="#session.empid#" status="false"/>
		<cfset session.currentCustomerId = #request.qCustomer.CustomerID#/>
	<cfelse>

			<!---Object to get corresponding Previously edited---->
		<cfinvoke component="#variables.objAgentGateway#" method="getEditingUserName" returnvariable="request.qryGetEditingUserName" employeID="#request.qryCustomerEditingDetails.inuseby#" />
			<!---Condition to check current employee and previous editing employee are not same--->
		<cfif session.empid neq request.qryCustomerEditingDetails.inuseby>
			<cfif request.qryGetEditingUserName.recordcount>
				<cfset variables.customerdisabledStatus=true>
					<div class="msg-area" style="margin-left:10px;margin-bottom:10px">
						<span style="color:##d21f1f">This customer locked because it is currently being edited by #request.qryGetEditingUserName.Name# #dateformat(request.qryCustomerEditingDetails.inuseon,"mm/dd/yy hh:mm:ss")#.
							An Administrator can manually override this lock by clicking the unlock button.
						</span>
					</div>
			</cfif>
		</cfif>
	</cfif>
<cfelse>
	<cfif len(trim(request.qSystemSetupOptions.DefaultCountry))>
		<cfset country1 = request.qSystemSetupOptions.DefaultCountry>
	</cfif>
	<cfif request.qGetSystemSetupOptions.autoAddCustViaDOT EQ 1>
		<cfif request.qGetSystemSetupOptions.CustomerLNI EQ 3>
			<cfinclude template="websiteDATACustomer_Saferwatch.cfm">
		<cfelse>
			<cfinclude template="websiteDATACustomer.cfm">
		</cfif>
	</cfif>
</cfif>


	
<input name="appDsn" id="appDsn" type="hidden" value="#application.dsn#">
<script type="text/javascript" language="javascript" src="javascripts/jquery.js"></script>
<script type='text/javascript' language="javascript" src='javascripts/jquery.autocomplete.js'></script>
<script type="text/javascript">
	$Auto = jQuery.noConflict( true );
	$(function() {

	// City DropBox
		function Cityformat(mail)
		{
			return mail.city + "<br/><b><u>State</u>:</b> " + mail.state+"&nbsp;&nbsp;&nbsp;<b><u>Zip</u>:</b> " + mail.zip;
		}

		function Zipformat(mail)
		{
			return mail.zip + "<br/><b><u>State</u>:</b> " + mail.state+"&nbsp;&nbsp;&nbsp;<b><u>City</u>:</b> " + mail.city;
		}

		//City
		$Auto("##City, ##RemitCity").autocomplete('searchCityAutoFill.cfm', {
		extraParams: {queryType: 'getCity'},
		multiple: false,
		width: 400,
		scroll: true,
		scrollHeight: 300,
		cacheLength: 1,
		highlight: false,
		dataType: "json",
		autoFocus: true,
		parse: function(data) {
			return $.map(data, function(row) {
				return {
					data: row,
					value: row.value,
					result: row.city
				}
			});
		},
		formatItem: function(item) {
			return Cityformat(item);
		}
		}).result(function(event, data, formatted) {
		var strId = this.id;
			if(strId == "City")
			{
				$('##state').val(data.state);
				$('##Zipcode').val(data.zip);
			}
			else if(strId == "RemitCity")
			{
				$('##RemitState').val(data.state);
				$('##RemitZipcode').val(data.zip);
			}

		});

		//zip AutoComplete
		$Auto("##Zipcode, ##RemitZipcode").autocomplete('searchCityAutoFill.cfm', {

		extraParams: {queryType: 'GetZip'},
		multiple: false,
		width: 400,
		scroll: true,
		scrollHeight: 300,
		cacheLength: 5,
		minLength: 5,
		highlight: false,
		dataType: "json",
		autoFocus: true,
		parse: function(data) {
			return $.map(data, function(row) {
				return {
					data: row,
					value: row.value,
					result: row.zip
				}
			});
		},
		formatItem: function(item) {
			return Zipformat(item);
		}
	}).result(function(event, data, formatted) {
		strId = this.id;
		zipCodeVal=$('##'+strId).val();
		//auto complete the state and city based on first 5 characters of zip code
		if(zipCodeVal.length == 5)
		{

			var strId = this.id;
			if(strId == "Zipcode")
			{
				initialStr = strId.substr(0, 7);
				//Donot update a field if there is already a value entered
				if($('##state').val() == '')
				{
					$('##state').val(data.state);
				}

				if($('##City').val() == '')
				{
					$('##City').val(data.city);
				}
			}
			else if(strId == "RemitZipcode")
			{
				$('##RemitState').val(data.state);
				$('##RemitCity').val(data.city);
			}
		}
		});

		$('##IsPayer').change(function(){
			if($(this).val() == 'True')
				$('##CustomerCreds').css('display','block');
			else
				$('##CustomerCreds').css('display','none');
		});


});
function popitup(url) {
	newwindow=window.open(url,'Map','height=600,width=800');
	if (window.focus) {newwindow.focus()}
	return false;
}
function copyToClipboard(element) {
  var $temp = $("<input>");
  $("body").append($temp);
  $temp.val($(element).text()).select();
  document.execCommand("copy");
  $temp.remove();
}
function openTab(url){
	window.open(url, '_blank');
}
</script>


	<cfform name="frmCustomer" action="index.cfm?event=addcustomer:process&editid=#editid#&#session.URLToken#" method="post">
	    <input type="hidden" name="customerdisabledStatus" id="customerdisabledStatus" value="#variables.customerdisabledstatus#">
	    <input type="hidden" name="tabid" id="tabid" value="">
	    <input type="hidden" name="isSaveEvent" id="isSaveEvent" value="false"/>
		<cfif isdefined("url.customerid") and len(trim(url.customerid)) gt 1>
			<cfinvoke component="#variables.objCutomerGateway#" method="getAttachedFiles" linkedid="#url.customerid#" fileType="2" returnvariable="request.filesAttached" />
			<div class="search-panel">
			</div>
			<div style="clear:both"></div>
			<cfif isdefined("session.message") and len(session.message)>
				<div id="message" class="msg-area" style="width:500px">#session.message#</div>
				<cfset exists= structdelete(session, 'message', true)/> 
			</cfif>
			<div style="clear:both"></div>

			<h1 style="float: left;"><span style="padding-left:160px;">#CustomerName#</span></h1>
			<cfif not customerdisabledStatus and request.qCustomer.loadcount eq 0>
				<div class="delbutton" style="margin-right: 100px;">
					<a href="index.cfm?event=customer&customerid=#editid#&#session.URLToken#" onclick="return confirm('Are you sure to delete it ?');">  Delete</a>
				</div>
			</cfif>
		<div style="clear:left;" id="divUploadedFiles">
			<div style="float:left;">
				<div id="customerTabs" class="tabsload ui-tabs ui-widget ui-widget-content ui-corner-all" style="float:left;border:none;padding-bottom: 0;">
					<ul class="ui-tabs-nav ui-helper-reset ui-helper-clearfix ui-widget-header ui-corner-all" style="height:27px;background: ##dfeffc !important;border:none; ">
				    	<li class="ui-state-default ui-corner-top ui-tabs-active ui-state-active">
				    		<a class="ui-tabs-anchor" href="##cust-detail">Customer</a>
				    	</li>
				    	<li class="ui-state-default ui-corner-top">
				    		<a class="ui-tabs-anchor" href="index.cfm?event=CustomerContacts&#session.URLToken#&customerId=#url.customerId#">Contacts</a>
				    	</li>
				    	<li class="ui-state-default ui-corner-top">
				    		<a class="ui-tabs-anchor" href="index.cfm?event=CRMNotes&#session.URLToken#&customerId=#url.customerId#">CRM</a>
				    	</li>
				        <li class="ui-state-default ui-corner-top">
				        	<a class="ui-tabs-anchor" href="index.cfm?event=stop&#session.URLToken#&customerId=#url.customerId#">Stops</a>
				        </li>
				        <li class="ui-state-default ui-corner-top">
				        	<a class="ui-tabs-anchor add_quote_txt"  href="index.cfm?event=addstop&#session.URLToken#&customerId=#url.customerId#">Add Stops</a>
				        </li>
					</ul>
				</div>
			</div>

			<div style="float:right;margin-right: 151px;margin-top: 8px;">
				<div style="float:left;">
					<input id="mailDocLink" <cfif mailsettings>data-allowmail="true"<cfelse>data-allowmail="false"</cfif> style="width:110px !important;" type="button" class="bttn"value="Email Doc" />
				</div>
				<div style="float:left;">
					<cfif variables.customerdisabledStatus>
						
						<cfif structKeyExists(session, 'rightsList') and listContains( session.rightsList, 'UnlockCustomer', ',')>

						<input id="Unlock" name="unlock" type="button" class="green-btnUnlock" onClick="removeCustomerEditAccess('#request.qCustomer.customerId#');" value="Unlock" style="width:100px !important;float:right;">
						</cfif>
					<cfelse>
					<input  type="submit" name="submit" class="bttn" onClick="return validateCustomer(frmCustomer,0);" onfocus="checkUnload();" value="Save" style="width:112px;"  />
		               <input  type="submit" name="submit" class="bttn" onClick="return validateCustomer(frmCustomer,1);" onfocus="checkUnload();" value="Save & Exit" style="width:112px;"  />
	               <input type="hidden" id="SaveAndExit" name="SaveAndExit" value="0"/>
	                
				</cfif>
				</div>
				<div class="clear"></div>
			</div>
		</div>
	    <div class="clear"></div>

		<div class="white-con-area" style="height: 36px;background-color: ##82bbef;margin-top: 2px;">
		<div style="float: left; width: 40%;" id="divUploadedFiles">
			<img id="missingReqAtt" style="float: left;background-color: ##fff;border-radius: 11px;margin-top: 15px;margin-left: 2px;margin-right: 2px;display: none;width: 16px;" src="images/exclamation.ico" title="Required Attachments Missing">
		 	<cfif customerdisabledstatus neq true>
			<cfif request.filesAttached.recordcount neq 0>
			&nbsp;<a id="attachFile" style="display:block;font-size: 13px;padding-left: 2px;color:white;" href="##" onclick="popitup('../fileupload/multipleFileupload/MultipleUpload.cfm?id=#url.customerid#&attachTo=2&user=#session.adminusername#&dsn=#dsn#&attachtype=Customer<cfif request.qGetSystemSetupOptions.TurnOnConsolidatedInvoices AND ConsolidateInvoices>&ConsolidateInvoices=1</cfif>&CompanyID=#session.CompanyID#')"><img style="vertical-align:bottom;" src="images/attachment.png">View/Attach Files</a>
			<cfelse>
				&nbsp;<a style="display:block;font-size: 13px;padding-left: 2px;color:white;" href="##" onclick="popitup('../fileupload/multipleFileupload/MultipleUpload.cfm?id=#url.customerid#&attachTo=2&user=#session.adminusername#&dsn=#dsn#&attachtype=Customer<cfif request.qGetSystemSetupOptions.TurnOnConsolidatedInvoices AND ConsolidateInvoices>&ConsolidateInvoices=1</cfif>&CompanyID=#session.CompanyID#')"><img style="vertical-align:bottom;" src="images/attachment.png">Attach Files</a>
			</cfif>
		<cfelse>
			&nbsp;
			<span style="display:block;font-size: 13px;padding-left: 2px;color:white;"></span>
		</cfif>
		</div>
		<div style="float: left; width: 45%;"><h2 style="color:white;font-weight:bold;">Customer Information</h2>
		</div>

		<cfif request.qSystemSetupOptions.project44>
			<div style="float: left; width: 15%;">
			 <input id="Project44Api" style="width:120px !important;height:22px;margin-top: 10px;" type="button" class="black-btn" value="Project 44 Setup">
			</div>
		</cfif>
		</div>
<cfelse>
<cfset tempLoadId = #createUUID()#>
<cfset session.checkUnload ='add'>
<h1>Add New Customer</h1>
	<div style="float:right;margin-right: 151px;margin-top: -10px;">
		<div style="float:left;">
			<input id="mailDocLink" <cfif mailsettings>data-allowmail="true"<cfelse>data-allowmail="false"</cfif> style="width:110px !important;" type="button" class="bttn"value="Email Doc" />
		</div>
		<div style="float:left;">
            
            <input  type="submit" name="submit" class="bttn" onClick="return validateCustomer(frmCustomer,0);" onfocus="checkUnload();" value="Save" style="width:112px;" tabindex="27" />
	           <input  type="submit" name="submit" class="bttn" onClick="return validateCustomer(frmCustomer,1);" onfocus="checkUnload();" value="Save & Exit" style="width:112px;" tabindex="27" />
	           <input type="hidden" id="SaveAndExit" name="SaveAndExit" value="0"/>

		</div>
		<div style="float:left;">
			<input  type="button" onclick="javascript:history.back();" name="back" class="bttn" value="Back" style="width:70px;" />
		</div>
		<div class="clear"></div>
	</div>
<div class="white-con-area" style="height: 36px;background-color: ##82bbef;margin-top: 19px;">
	<div style="float: left; width: 40%;" id="divUploadedFiles">
	</div>
	<div style="float: left; width: 60%;"><h2 style="color:white;font-weight:bold;">Customer Information</h2></div>
</div>
</cfif>
<cfif isdefined("message") and len(message)>
<div class="msg-area" style="margin-left: 13px;">#message#</div>
</cfif>
<div class="white-con-area">
<div class="white-top"></div>
<div class="white-mid">
	<h3 id="hViewOnly" style="font-weight: bold;color: red;width:100%;text-align:center;display: none;">VIEW ONLY. EDIT NOT ALLOWED</h3>
	<cfinput type="hidden" name="editid" id="editid" value="#editid#">
	<cfinput type="hidden" name="ReqAddressWhenAddingCust" id="ReqAddressWhenAddingCust" value="#request.qSystemSetupOptions.ReqAddressWhenAddingCust#">
	 <div class="form-con">
	<fieldset class="carrierFields">
		<cfif request.qSystemSetupOptions.autoAddCustViaDOT>
			<label>MC ##</label>
			<cfinput name="MCNumber" id="MCNumber" type="text" tabindex="1"  value="#MCNumber#"  required="no" message="Please enter MC Number" maxlength="50"/>
			<label class="DOTNumber">DOT ##</label>
			<cfinput name="DOTNumber" id="DOTNumber" type="text" tabindex="2" value="#Dotnumber#" maxlength="50"/>
			<div class="clear"></div>
		</cfif>
	    <label>Company*</label>
	    <cfif request.qSystemSetupOptions.GoogleAddressLookup>
	        <cfinput type="text" maxlength="100" name="CustomerName" id="CustomerName" placeholder=" " value="#CustomerName#" tabindex="3" size="25" required="yes" message="Please  enter the name" onFocus="geolocate()" class="disAllowHash">
	    <cfelse>
	    	<cfinput type="text" maxlength="100" name="CustomerName" id="CustomerName" placeholder=" " value="#CustomerName#" tabindex="3" size="25" required="yes" message="Please  enter the name" class="disAllowHash">
	    </cfif>
        <div class="clear"></div>
        <label>Customer Code*</label>
	    <cfif isdefined("url.customerid") AND len(trim(url.customerid)) GT 1 AND (request.qCustomer.AYBImport EQ true) >
	    	<cfif structKeyExists(session, 'rightsList') and listContains( session.rightsList, 'customerCode', ',')>
	    		<cfinput type="text" name="CustomerCode" id="CustomerCode" maxlength="10" value="#CustomerCode#" size="25" required="yes" message="Please  enter the customer code">
	    	<cfelse>
		    	<cfinput type="text" name="CustomerCode" id="CustomerCode" maxlength="10" value="#CustomerCode#" size="25" required="yes" message="Please  enter the customer code" readonly>
		    </cfif>
	    <cfelse>
	    	<cfinput type="text" name="CustomerCode" id="CustomerCode" maxlength="10" value="#CustomerCode#" size="25" required="yes" message="Please  enter the customer code">
	    </cfif>

        <div class="clear"></div>
        <label>Address<cfif request.qSystemSetupOptions.ReqAddressWhenAddingCust>*</cfif></label>
		<textarea rows="2" cols="" maxlength="100" id="location" name="Location" tabindex="4" style="height: 42px;">#Location#</textarea>
        <div class="clear"></div>
        <label>City<cfif request.qSystemSetupOptions.ReqAddressWhenAddingCust>*</cfif></label>
        <cfif request.qSystemSetupOptions.ReqAddressWhenAddingCust>
	        <cfinput type="text" name="City" maxlength="50" value="#City#" tabindex="-1" required="yes" message="Please enter the city">
	    <cfelse>
	    	<cfinput type="text" name="City" maxlength="50" value="#City#" tabindex="-1">
	    </cfif>
        <div class="clear"></div>
        <label>State<cfif request.qSystemSetupOptions.ReqAddressWhenAddingCust>*</cfif></label>
		<select name="state1" id="state" tabindex="-1" style="width:100px;">
         <option value="">Select</option>
		<cfloop query="request.qStates">
        	<option value="#request.qStates.statecode#" <cfif request.qStates.statecode is state1> selected="selected" </cfif> >#request.qStates.statecode#</option>
		</cfloop>
		</select>
		<label style="width:70px;">Zipcode<cfif request.qSystemSetupOptions.ReqAddressWhenAddingCust>*</cfif></label>
		<cfif request.qSystemSetupOptions.ReqAddressWhenAddingCust>
	 		<cfinput type="text" name="Zipcode" value="#Zipcode#" maxlength="50" tabindex="7" required="yes" message="Please enter a zipcode" style="width:100px;">
	 	<cfelse>
	 		<cfinput type="text" name="Zipcode" value="#Zipcode#" maxlength="50" tabindex="7" style="width:100px;">
	 	</cfif>
        <div class="clear"></div>

        <cfif request.qSystemSetupOptions.TimeZone>
	        <label>Time Zone</label>
	 		<cfinput type="text" name="TimeZone" value="#TimeZone#" maxlength="50" tabindex="7" style="width:40px;">
	 	</cfif>

		<label <cfif request.qSystemSetupOptions.TimeZone>style="width:55px;"</cfif>>Country*</label>
        <select name="country1" id="country1" tabindex="8" onload="getUSCountryCust();"  <cfif request.qSystemSetupOptions.TimeZone>style="width:167px;"</cfif>>
        <option value="">Select</option>
        <cfloop query="request.qCountries">
        	<cfif request.qCountries.countrycode EQ 'US'>
        		<option data-code="#request.qCountries.countrycode#" value="#request.qCountries.countryID#" <cfif (request.qCountries.countryID is country1) OR (request.qCountries.countrycode is country1)> selected="selected" </cfif> >#request.qCountries.country#</option>
        	</cfif>
        </cfloop>
        <cfloop query="request.qCountries">
        	<cfif request.qCountries.countrycode EQ 'CA'>
        		<option data-code="#request.qCountries.countrycode#" value="#request.qCountries.countryID#" <cfif (request.qCountries.countryID is country1) OR (request.qCountries.countrycode is country1)> selected="selected" </cfif> >#request.qCountries.country#</option>
        	</cfif>
        </cfloop>
		<cfloop query="request.qCountries">
			<cfif not listFindNoCase("CA,US", request.qCountries.countrycode)>
	        	<option data-code="#request.qCountries.countrycode#" value="#request.qCountries.countryID#" <cfif (request.qCountries.countryID is country1) OR (request.qCountries.countrycode is country1)> selected="selected" </cfif> >#request.qCountries.country#</option>
	        </cfif>
		</cfloop>
		</select>
		<div class="clear"></div>
		<label>Contact Person</label>
        <cfinput type="text" name="ContactPerson" maxlength="50" value="#ContactPerson#" tabindex="8">
		<div class="clear"></div>
        <label>Phone No</label>
        <cfinput onchange="ParseUSNumber(this,'Phone No');" type="text" name="PhoneNO" maxlength="50" value="#PhoneNO#" tabindex="9" style="width:185px;">
        <label class="ex" style="width:20px;">Ext.</label>
        <input type="text" name="PhoneNOExt" tabindex="9" style="width:50px;" value="#PhoneNOExt#" maxlength="10">
        <div class="clear"></div>
		<label>Fax</label>
		<cfinput name="Fax" type="text" maxlength="150" tabindex="10" value="#Fax#" style="width:185px;" onchange="ParseUSNumber(this,'Fax');"/>
		<label class="ex" style="width:20px;">Ext.</label>
        <input type="text" name="FaxExt" tabindex="10" style="width:50px;" value="#FaxExt#" maxlength="10">
        <div class="clear"></div>
		<label>Toll Free</label>
		<cfinput name="Tollfree" type="text" maxlength="250" tabindex="11" value="#Tollfree#" style="width:185px;" onchange="ParseUSNumber(this,'Tollfree');"/>
		<label class="ex" style="width:20px;">Ext.</label>
        <input type="text" name="TollfreeExt" tabindex="11" style="width:50px;" value="#TollfreeExt#" maxlength="10">
		<div class="clear"></div>
        <label>Cell</label>
        <cfinput type="text" name="MobileNo" maxlength="50" value="#MobileNo#" tabindex="12" style="width:185px;" onchange="ParseUSNumber(this,'Mobile No');">
        <label class="ex" style="width:20px;">Ext.</label>
        <input type="text" name="MobileNoExt" tabindex="12" style="width:50px;" value="#MobileNoExt#" maxlength="10">
        <div class="clear"></div>
        <label>Email</label>
        <cfinput type="text" maxlength="250" name="Email" class="emailbox" value="#Email#" tabindex="13" onchange="Autofillwebsite(frmCustomer);">
        <div class="clear"></div>
        <label>Website</label>
        <input type="text" maxlength="50" class="emailbox" name="website" id="website" tabindex="14" value="#website#">
		<div class="clear"></div>
		<cfif request.qgetsystemsetupoptions.BillFromCompanies EQ 1>
	        <label>Bill From</label>
	   		<select name="BillFromCompany" tabindex="15">
	         	<option value="">Select</option>
	         	<cfloop query="request.qBillFromCompanies">
	         		<option value="#request.qBillFromCompanies.BillFromCompanyID#"<cfif request.qBillFromCompanies.BillFromCompanyID eq  BillFromCompany> selected="selected" </cfif>>#request.qBillFromCompanies.CompanyName#</option>
	         	</cfloop>
	        </select>
			<div class="clear"></div>
		</cfif>
        <label>Office*</label>
        <myoffices:virtualtag officeloc='#OfficeID1#' name="OfficeID1" customerID="#url.customerID#" tabindex="16" />
        <div class="clear"></div>
        <label>Sales Rep</label>
        <select name="salesperson" tabindex="17" style="width:174px;">
         <option value="">Select</option>
         <cfloop query="request.qSalesPerson">
         <option value="#request.qSalesPerson.EmployeeID#"<cfif request.qSalesPerson.EmployeeID eq  SalesRepID> selected="selected" </cfif>>#request.qSalesPerson.Name#</option>
         </cfloop>
        </select>
        <label>Lock on Loads</label>
		<input <cfif LockSalesAgentOnLoad> Checked </cfif> name="LockSalesAgentOnLoad" id="LockSalesAgentOnLoad" type="checkbox" class="small_chk" style="float: left;">
       <div class="clear"></div>
       <label>Dispatcher</label>
       <select name="Dispatcher" tabindex="18" style="width:174px;">
        <option value="">Select</option>
        <cfloop query="request.qSalesPerson">
         <option value="#request.qSalesPerson.EmployeeID#"<cfif request.qSalesPerson.EmployeeID eq  AcctMGRID> selected="selected" </cfif>>#request.qSalesPerson.Name#</option>
         </cfloop>       
       </select>
        <label>Lock on Loads</label>
		<input <cfif LockDispatcherOnLoad> Checked </cfif> name="LockDispatcherOnLoad" id="LockDispatcherOnLoad" type="checkbox" class="small_chk" style="float: left;">
       <div class="clear"></div>
       <label>Sales Rep 2</label>
       <select name="salesperson2" tabindex="18" style="width:174px;">
         <option value="">Select</option>
         <cfloop query="request.qSalesPerson">
         <option value="#request.qSalesPerson.EmployeeID#"<cfif request.qSalesPerson.EmployeeID eq  SalesRepID2> selected="selected" </cfif>>#request.qSalesPerson.Name#</option>
         </cfloop>
        </select>
		<div class="clear"></div>
        <label>Dispatcher 2</label>
       <select name="Dispatcher2" tabindex="18" style="width:174px;">
         <option value="">Select</option>
         <cfloop query="request.qSalesPerson">
         <option value="#request.qSalesPerson.EmployeeID#"<cfif request.qSalesPerson.EmployeeID eq  AcctMGRID2> selected="selected" </cfif>>#request.qSalesPerson.Name#</option>
         </cfloop>
        </select>
		<label>Lock on Loads</label>
		<input <cfif LockDispatcher2OnLoad> Checked </cfif> name="LockDispatcher2OnLoad" id="LockDispatcher2OnLoad" type="checkbox" class="small_chk" style="float: left;">
       <div class="clear"></div>
       <label>EDI Partner</label>
       <select name="EDIPartnerID" tabindex="18">
         <option value="">Select</option>        
         <option value="069331990INV" <cfif EDIPartnerID Eq '069331990INV'>selected="selected"</cfif> >Dollar General (069331990INV)</option>
         <option value="TRANSPLACE" <cfif EDIPartnerID Eq 'TRANSPLACE'>selected="selected"</cfif>>Morton Salt (TRANSPLACE)</option>        
       </select>
       
		<div class="clear"></div>
		<!--- Checking the rights for the Status and IsPayer--->
		<cfif ListContains(session.rightsList,'changeCustomerActiveStatus',',')>
        	<cfset changeActiveStatusRightAvailable = "">
			<cfset disableChangeActiveStatusSelect = "">
        <cfelse>
        	<cfset changeActiveStatusRightAvailable = "disabled">
			<cfif  session.checkUnload neq "add">
				<cfset disableChangeActiveStatusSelect = "disabled">
			<cfelse>
				<cfset disableChangeActiveStatusSelect = "">
			</cfif>
        </cfif>
        <label>Status*</label>
        <cfselect name="CustomerStatusID" tabindex="19" style="width:65px;">
        <cfif changeActiveStatusRightAvailable eq "" OR (changeActiveStatusRightAvailable eq "disabled" AND CustomerStatusID eq 1)>
          <option value="1" <cfif #CustomerStatusID# eq 1>selected="selected" </cfif>>Active</option>
         </cfif>
         <cfif changeActiveStatusRightAvailable eq "" OR (changeActiveStatusRightAvailable eq "disabled" AND CustomerStatusID eq 2) OR (changeActiveStatusRightAvailable eq "disabled" AND session.checkUnload eq "add")>
          <option value="2" <cfif #CustomerStatusID# eq 2>selected="selected" </cfif>>Inactive</option>
         </cfif>
        </cfselect>
		<label style="width:44px;">Payer*</label>
		 <select name="IsPayer" id="IsPayer" tabindex="20" style="width:55px;">
			<cfif changeActiveStatusRightAvailable eq "" OR (changeActiveStatusRightAvailable eq "disabled" AND IsPayer is 'True')>
	  		 	<option value="True" <cfif IsPayer is 'True'>selected ="selected"</cfif>>True</option>
	  		</cfif>
	  		<cfif changeActiveStatusRightAvailable eq "" OR (changeActiveStatusRightAvailable eq "disabled" AND IsPayer is 'False') OR (changeActiveStatusRightAvailable eq "disabled" AND session.checkUnload eq "add")>
	  		 	 <option value="False" <cfif IsPayer is 'False'>selected ="selected"</cfif>>False</option>
	  		</cfif>
  		 </select>
		 
		 <cfif request.qSystemSetupOptions.ForeignCurrencyEnabled>
			 <label class="currencyLabel" style="width:56px;">Currency</label>
			 <select name="defaultCurrency" id="defaultCurrency" style="width:47px;display:none;">
				<option value="" >Select Currency</option>
				<cfloop query = "request.qGetCurrencies"> 
					<option value="#CurrencyID#" <cfif defaultCurrency eq CurrencyID> selected="selected" </cfif>>#CurrencyNameISO#(#CurrencyName#)</option>
				</cfloop>		
			</select>			
		</cfif>
		<div class="clear"></div>
		<cfif request.qGetSystemSetupOptions.TurnOnConsolidatedInvoices>
			<hr style="margin-bottom: 10px;">
			<label>Consolidate Invoices?</label>
			<input <cfif ConsolidateInvoices> Checked </cfif> name="ConsolidateInvoices" id="ConsolidateInvoices" type="checkbox" class="small_chk" style="float: left;margin-top: 5px;" onclick="activeAllConsolidateCheckbox()">

			<label style="width: 100px;margin-left: 20px;">Include Individual Invoices</label>
			<input <cfif IncludeIndividualInvoices> Checked </cfif> name="IncludeIndividualInvoices" id="IncludeIndividualInvoices" type="checkbox" class="small_chk" style="float: left;margin-top: 5px;">
			<div style="float: left;">
				<img src="images/infoicon.png" class="InfotoolTip" style="width:22px;cursor:pointer;" title="This will increase the amount of pages in the Consolidation Report by the number of Loads that are in the Consolidation. Keep this off if you only need the POD's to be added to the report.">
			</div>

			<label style="width: 60px;margin-left: 15px;">Print PO## Column?</label>
			<input <cfif SeperateJobPo> Checked </cfif> name="SeperateJobPo" id="SeperateJobPo" type="checkbox" class="small_chk" style="float: left;margin-top: 5px;">
			<div class="clear"></div>
			<label>Print BOL## Column?</label>
			<input <cfif ConsolidateInvoiceBOL> Checked </cfif> name="ConsolidateInvoiceBOL" id="ConsolidateInvoiceBOL" type="checkbox" class="small_chk" style="float: left;margin-top: 5px;">

			<label style="width: 100px;margin-left: 20px;">Print Reference## Column?</label>
			<input <cfif ConsolidateInvoiceRef> Checked </cfif> name="ConsolidateInvoiceRef" id="ConsolidateInvoiceRef" type="checkbox" class="small_chk" style="float: left;margin-top: 5px;">

			<label style="width: 60px;margin-left: 38px;">Print Date Column?</label>
			<input <cfif ConsolidateInvoiceDate> Checked </cfif> name="ConsolidateInvoiceDate" id="ConsolidateInvoiceDate" type="checkbox" class="small_chk" style="float: left;margin-top: 5px;">

			<div class="clear"></div>
			<hr style="margin-top: 10px;">
	   	</cfif>
		<label style="text-align:left;width:120px;">Instructions</label>
   		<textarea rows="" cols="" tabindex="21" maxlength="1000" name="CustomerNotes" style="width:400px">#CustomerNotes#</textarea>
			<div class="clear"></div>

		<label style="text-align:left;width:120px;">Internal Notes</label>
   		<textarea rows="" cols="" tabindex="21" maxlength="1000" name="InternalNotes" style="width:400px">#InternalNotes#</textarea>
			<div class="clear"></div>
		<div style="border-bottom:1px solid ##e6e6e6; padding-top:7px;"></div>

		<div id="CustomerCreds" style="padding-top: 16px;"<cfif !val(IsPayer)>style="display:none;"</cfif> >
			<label>Login Name</label>
			<cfinput type="text" name="CustomerUsername" maxlength="50" value="#Username#" tabindex="22" autocomplete="off">
			<div class="clear"></div>
			<label>Password</label>
			<cfinput type="password" name="CustomerPassword" maxlength="50" value="#password#" tabindex="23" autocomplete="new-password" >
			<i class="far fa-eye fa-eye-slash" style="margin-left: -25px; cursor: pointer; margin-top:6px;"></i>
			<div class="clear"></div>
			<label>Customer Portal</label>
			<cfif CGI.HTTPS EQ "on">
				<cfset variables.https = "https://">
			<cfelse>
				<cfset variables.https = "http://">
			</cfif>
			<cfset variables.customerLoginUrl = variables.https & cgi.SERVER_NAME & cgi.SCRIPT_NAME & '?event=customerlogin'>

			<div>
				<span id="fakeCustPortalLink" style="color: ##3a5b96;text-decoration: underline;float: left;cursor: pointer;" title="#variables.customerLoginUrl#" onclick="openTab('#variables.customerLoginUrl#')">https://loadmanager.biz/Customer Portal...</span>
				<span id="orgCustPortalLink" style="display: none;">#variables.customerLoginUrl#</span>
				<input type="button" name="copylink" class="bttn" value="Copy Link" style="width: 75px !important;margin-top: -5px;" onclick="copyToClipboard('##orgCustPortalLink')">
			</div>
		</div>
	   <div class="clear"></div>
       <fieldset>
       </div>
       <div class="form-con">
       	<fieldset class="carrierFields">
       	<cfinvoke component="#variables.objloadGateway#" method="getFactoringDetails" returnvariable="request.qFactorings" />
       	
       	<label>Factoring Company</label>
		<cfselect name="FactoringID" id="FactoringID" tabindex="24" style="width:285px;" onchange="return popupAddFactory()">
			<option value="">Select</option>
			<option value="addFactory" style="background-color: gray;color: white;">Add New</option>
			<cfloop query="request.qFactorings">
				<option value="#request.qFactorings.Factoringid#" data-RemitName="#request.qFactorings.Name#"
					data-RemitAddress="#request.qFactorings.Address#"
					data-RemitCity="#request.qFactorings.City#"
					data-RemitState="#request.qFactorings.State#"
					data-RemitZip="#request.qFactorings.Zip#"
					data-RemitContact="#request.qFactorings.Contact#"
					data-RemitPhone="#request.qFactorings.Phone#"
					data-RemitFax="#request.qFactorings.Fax#" <cfif request.qFactorings.FactoringID EQ custFactoringID> selected </cfif>>#request.qFactorings.Name#</option>
		   </cfloop>
	   </cfselect>
		<div class="clear"></div>
		<label>Name</label>
		<cfinput name="RemitName" id="RemitName" class="RemitFL" type="text" tabindex="25" value="#RemitName#" maxlength="100"/>
		<div class="clear"></div>
		<label>Address</label>
		<textarea rows="2" tabindex="26" cols="" class="RemitFL" name="RemitAddress" id="RemitAddress" maxlength="200" style="height:25px;">#trim(RemitAddress)#</textarea>
		<div class="clear"></div>
		<label>City</label>
		<cfinput name="RemitCity" id="RemitCity" class="RemitFL" tabindex="-1" maxlength="50" type="text" value="#RemitCity#" style="width:90px;"/>
		<label style="width:77px;">State</label>
		<select name="RemitState" id="RemitState" class="RemitFL" tabindex="-1" style="width:100px;">
        <option value="">Select</option>
			<cfloop query="request.qStates">
	        	<option value="#request.qStates.statecode#" <cfif request.qStates.statecode is RemitState> selected="selected" </cfif> >#request.qStates.statecode#</option>
			</cfloop>
		</select>
		<div class="clear"></div>
		<label>Zipcode</label>
		<cfinput name="RemitZipcode" id="RemitZipcode" class="RemitFL" type="text" value="#RemitZipCode#" maxlength="20" tabindex="29" style="width:90px;"/>
		<label style="width:77px;">Contact</label>
		<cfinput name="RemitContact" id="RemitContact" class="RemitFL" tabindex="30" type="text" maxlength="150" value="#RemitContact#" style="width:90px;"/>
		<div class="clear"></div>
		<label>Phone</label>
		<cfinput name="RemitPhone" id="RemitPhone" class="RemitFL" tabindex="31" type="text" maxlength="150"  value="#RemitPhone#" style="width:90px;" onchange="ParseUSNumber(this,'Phone');"/>
		<label style="width:77px;">Fax</label>
		<cfinput name="RemitFax" id="RemitFax" class="RemitFL" onchange="ParseUSNumber(this,'Fax');" type="text" tabindex="32" maxlength="150" value="#RemitFax#" style="width:90px;"/>
		<div class="clear"></div>

		<div style="border-bottom:1px solid ##e6e6e6; padding-top:7px;"></div>
		<div style="padding-top:13px;">

   		 <label>Payment Terms</label>
   		 <cfinput type="text" name="BestOpp" value="#BestOpp#" maxlength="100" tabindex="32" style="width:250px;">
   		<div class="clear"></div>

        <label>Load Potential</label>
        <cfinput type="text" name="LoadPotential" maxlength="50" value="#LoadPotential#" tabindex="32" >
        </div>

 		<label>Rate Per Mile*</label>
        <cfinput type="text" name="RatePerMile" value="#RatePerMile#" tabindex="33" required="yes" message="Please enter Rate Per Mile">
         <div class="clear"></div>

		<div style="border-bottom:1px solid ##e6e6e6; padding-top:7px;"></div>
   		 <cfinput type="hidden" name="FinanceID" value="#FinanceID#" tabindex="35">
		<div style="width:100%; padding-top:13px;">
			<table style="border-collapse: collapse;border-spacing: 0;">
				<tbody>
					<tbody>
					<tr>
					  <td><label style="text-align: left !important;width: 65px !important;">Credit Limit</label></td>
					  <td>
					  	<cfif structKeyExists(session, 'rightsList') and listContains(session.rightsList, 'changeCustomerActiveStatus', ',') AND request.qSystemSetupOptions.editCreditLimit>
					  		<cfinput type="text" class="mid-textbox-1" style="text-align:right;" name="CreditLimit" id="CreditLimit" tabindex="36" value="#DollarFormat(CreditLimit)#" message="Please enter the credit limit">
					  	<cfelse>
						  <cfinput type="text" class="mid-textbox-1" style="text-align:right;" name="CreditLimit" id="CreditLimit" tabindex="36" value="#DollarFormat(CreditLimit)#" readonly="true" message="Please enter the credit limit">
						</cfif>
						</td>
					  <td><label style="text-align: left !important;width: 40px !important;">Balance</label></td>
					  <td>
						  <cfinput type="text" class="mid-textbox-1" style="text-align:right;" name="Balance"  id="Balance" value="#replace("$#Numberformat(Balance,"___.__")#", " ", "", "ALL")#" readonly="true" tabindex="38"
						  onchange="getbalance()">
						</td>
					  <td><label style="text-align: left !important;width: 50px !important;">Available</label></td>
					  <td>
						  <cfinput type="text" class="mid-textbox-1" style="text-align:right;" name="Available" id="Available" tabindex="37" value="#DollarFormat(Available)#"  readonly="true" message="Please enter the available Amount" >
						</td>
					</tr>
				</tbody>
				</tbody>
			</table>
		</div>
		 <div class="clear"></div>
		 <div style="padding-top:5px;">
		 <label style="text-align:left;width:120px;">Customer Directions</label>
		 <textarea maxlength="1000" rows="" cols="" tabindex="39" name="CustomerDirections" style="width:400px;height:147px;"  tabindex="39">#CustomerDirections#</textarea>
		 </div>
		 <div class="clear"></div>
		 <label style="text-align:left;width:120px;">#variables.freightBroker# Notes</label>
   		 <textarea rows="" cols="" tabindex="40" name="CarrierNotes" style="width:400px;height:148px;" maxlength="4000"  tabindex="40">#CarrierNotes#</textarea>

   		 <div class="clear"></div>
		 <label style="text-align:left;width:120px;">Customer Terms</label>
   		 <textarea rows="" cols="" tabindex="41" name="CustomerTerms" style="width:400px" maxlength="4000"  tabindex="40">#CustomerTerms#</textarea>

		 <div class="clear"></div>
		 <div style="padding-left:100px;padding-top:19px;">
		 	<cfif variables.customerdisabledStatus>
		 		<cfif structKeyExists(session, 'rightsList') and listContains( session.rightsList, 'UnlockCustomer', ',')>
		 		<input id="Unlock" name="unlock" type="button" class="green-btnUnlock" onClick="removeCustomerEditAccess('#request.qCustomer.customerId#');" value="Unlock" style="width:100px !important;float:right;">
		 	</cfif>
		 	<cfelse>
            
            <input  type="submit" name="submit" class="bttn" onClick="return validateCustomer(frmCustomer,0);" onfocus="checkUnload();" value="Save" style="width:112px;" tabindex="41" />
	          <input  type="submit" name="submit" class="bttn" onClick="return validateCustomer(frmCustomer,1);" onfocus="checkUnload();" value="Save &  Exit" style="width:112px;" tabindex="41" />
	        </cfif>
		 	<input  type="button" onclick="javascript:history.back();" name="back" class="bttn" value="Back" style="width:70px;" tabindex="42" />
		 
		 </div>
		<div class="clear"></div>
		</fieldset>
	</div>
   <div class="clear"></div>
 </cfform>
<cfif isDefined("url.customerid") and len(url.customerid) gt 1>
<p id="footer" style="padding-left:10px;font-family:Verdana, Geneva, sans-serif; font-style:italic bold; text-transform:uppercase;font-family:Verdana, Geneva, sans-serif; font-style:italic; text-transform:uppercase;width:80%;">Last Updated:<cfif isDefined("request.qCustomer")>&nbsp;&nbsp;&nbsp; #request.qCustomer.LastModifiedDateTime#&nbsp;&nbsp;&nbsp;#request.qCustomer.LastModifiedBy#</cfif></p>
</cfif>
</div>
<div class="white-bot"></div>
</div>
<br /><br /><br />
<cfif isDefined("url.customerid") and len(url.customerid) eq 1 and not len(trim(request.qSystemSetupOptions.DefaultCountry))>
	<cftry>
		<cfhttp url="https://api.ipdata.co/#cgi.REMOTE_ADDR#?api-key=f5d3af7561a17fec29bcb0fae144b444ea9cd90a6af000540191e20c" method="get" timeout="60">
		</cfhttp>
		<cfif cfhttp.Statuscode EQ '200 OK'>
			<cfset ipDataLoc = deserializeJson(cfhttp.FileContent)>
			<script type="text/javascript">
				$(document).ready(function(){
					$("##country1 option[data-code='#ipDataLoc.country_code#']").attr('selected','selected');
				})
			</script>
		</cfif>
		<cfcatch></cfcatch>
	</cftry>
</cfif>
  <style>
    /* The Modal (background) */
.modal {
  display: none; /* Hidden by default */
  position: fixed; /* Stay in place */
  z-index: 1; /* Sit on top */
  left: 0;
  top: 0;
  width: 100%; /* Full width */
  height: 100%; /* Full height */
  overflow: auto; /* Enable scroll if needed */
  background-color: rgb(0,0,0); /* Fallback color */
  background-color: rgba(0,0,0,0.4); /* Black w/ opacity */
}
/* Modal Content/Box */
.modal-content {
  background-color: ##defaf9;
  margin: 15% auto; /* 15% from the top and centered */
  padding: 20px;
  border: 1px solid ##888;
  width: 30%; /* Could be more or less, depending on screen size */
  height:220px;
}
/* The Close Button */
.close {
  color: ##fff;
  float: right;
  font-size: 28px;
  font-weight: bold;
  margin-right: 7px;
  margin-top: 10px;
}

.close:hover,
.close:focus {
  color: black;
  text-decoration: none;
  cursor: pointer;
} 
##ediheading{
  font-size: 15px;
  font-weight: bold;
  padding-top: 12px;
}
##headbakgrnd{
    background-color: ##82BBEF;
    position: initial;
    height: 38px;
    margin-top: -20px;
    width: 110%;
    margin-left: -20px;
}
</style>
<cfif isDefined("url.customerid") and len(url.customerid) gt 1>
	<div id="ModalProject44" class="modal"> 
	    <div class="modal-content" style="height:175px;">
	        <div id="headbakgrnd">
	            <span class="close Project44ApiClose">&times;</span>
	            <div id="ediheading"> <center>Project44</center></div>
	        </div>
	        <div style="margin-top: 10px;">
	        	<strong>Push location data to Project44</strong><input name="PushDataToProject44Api" id="PushDataToProject44Api" type="checkbox" class="small_chk" style="margin-top: 5px;margin-left: 5px;" <cfif request.qCustomer.PushDataToProject44Api> checked </cfif>>
	        </div>
	        <div style="margin-top: 10px;">
	        	<p>(If this option is on,then the location data will be send to project44)</p>
	        </div>
	        <div style="margin-top: 10px;">
	        	<label>Username</label>
	        	<input name="Project44ApiUsername" id="Project44ApiUsername" type="text" value="#request.qCustomer.Project44ApiUsername#">
	        </div>
	        <div style="margin-top: 10px;">
	        	<label>Password</label>
	        	<input name="Project44ApiPassword" id="Project44ApiPassword" type="password" value="#request.qCustomer.Project44ApiPassword#">
	        </div>
	        <div style="margin-top: 25px;text-align: right;margin-right: 50px;">
	            <input type="button" value="Cancel" class="black-btn Project44ApiClose" style="width:72px !important;height:22px;margin-top: 10px;">          
	            <input type="button"  value="Submit" class="black-btn" style="width:72px !important;height:22px;margin-top: 10px;margin-right:-24px;"
	                    onclick="PushDataToProject44Api()" >
	        </div>
	    </div>
	</div>
</cfif>
<script type="text/javascript">
	<cfif isDefined("url.customerid") and len(url.customerid) gt 1>
		function PushDataToProject44Api(){
			var PushDataToProject44Api = 0;
			if($('##PushDataToProject44Api').is(":checked")){
				PushDataToProject44Api =1;
			}
	        $('##PushDataToProject44Api').attr("disabled", true);

	        var Project44ApiUsername = $('##Project44ApiUsername').val();
	        var Project44ApiPassword = $('##Project44ApiPassword').val();

	        var path = urlComponentPath+"customergateway.cfc?method=PushDataToProject44Api";
	        $.ajax({
	            type: "Post",
	            url: path,
	            dataType: "json",
	            async: false,
	            data: {
	                customerid:'#url.customerid#',dsn:'#application.dsn#',PushDataToProject44Api:PushDataToProject44Api,Project44ApiUsername:Project44ApiUsername,Project44ApiPassword:Project44ApiPassword
	            },
	            success: function(data){
	                alert(data.MSG);
	                $('##PushDataToProject44Api').removeAttr("disabled");
	                document.getElementById('ModalProject44').style.display= "none";
	                $('body').removeClass('noscroll');
	            }
	        });  
	    }
    </cfif>
	$(document).ready(function(){
		$('##FactoringID').change(function(){

			if($.trim($('##FactoringID').val()).length){
				$('##RemitName').val($(this).find(':selected').attr('data-RemitName'));
				$('##RemitAddress').val($(this).find(':selected').attr('data-RemitAddress'));
				$('##RemitCity').val($(this).find(':selected').attr('data-RemitCity'));
				$('##RemitState').val($(this).find(':selected').attr('data-RemitState'));
				$('##RemitZipcode').val($(this).find(':selected').attr('data-RemitZip'));
				$('##RemitContact').val($(this).find(':selected').attr('data-RemitContact'));
				$('##RemitPhone').val($(this).find(':selected').attr('data-RemitPhone'));
				$('##RemitFax').val($(this).find(':selected').attr('data-RemitFax'));
			}
			else{
				$('##RemitName').val('');
				$('##RemitAddress').val('');
				$('##RemitCity').val('');
				$('##RemitState').val('');
				$('##RemitZipcode').val('');
				$('##RemitContact').val('');
				$('##RemitPhone').val('');
				$('##RemitFax').val('');
			}
		});

		<cfif isDefined("url.customerid") and len(url.customerid) gt 1>
			$('##Project44Api').click(function() {
	            $('body').addClass('noscroll');
	            document.getElementById('ModalProject44').style.display = "block";
	        });
	        $('.Project44ApiClose').click(function(){
	            document.getElementById('ModalProject44').style.display= "none";
	            $('body').removeClass('noscroll');
	        });
        </cfif>

		 $('##mailDocLink').click(function(){
			if($(this).attr('data-allowmail') == 'false')
			alert('You must setup your email address in your profile before you can email documents.');
			else
			mailDocOnClick('#session.URLToken#','customer'<cfif isDefined("url.customerid") and len(url.customerid) gt 1>,'#url.customerid#'<cfelse>,''</cfif>);
		 });


		 $("##frmCustomer").submit(function(){
		 	$('##isSaveEvent').val('true');
		 });
		 
		 $("##IsPayer").change(function(){
			if($(this).val() == "True"){
				$("##defaultCurrency, .currencyLabel").show();
			}else{
				$("##defaultCurrency, .currencyLabel").hide();
			}
		 });
		 $("##IsPayer").trigger("change");
		$("##CustomerName").keyup(function(){
		  	var key = $(this).val().replace(/\s+/g, '').substring(0,10);
		  	$("##CustomerCode").val(key.substring(0,10));
		});
		$("##CustomerName").change(function(){
		  	var key = $(this).val().replace(/\s+/g, '').substring(0,10);
		  	$("##CustomerCode").val(key);
		});
	});

	<cfif url.customerid eq 0 AND  request.qSystemSetupOptions.GoogleAddressLookup>
	
		var input = document.getElementById('CustomerName');
		google.maps.event.addDomListener(input, 'keydown', function(event) { 
		if (event.keyCode === 13) { 
				event.preventDefault(); 
			}
		});
		
		var autocomplete;
		
		function initAutocomplete() {
		  // Create the autocomplete object, restricting the search predictions to
		  // geographical location types.
		  autocomplete = new google.maps.places.Autocomplete(
		      document.getElementById('CustomerName'), {types: ['establishment']});
			  
		  // Avoid paying for data that you don't need by restricting the set of
		  // place fields that are returned to just the address components.
		  //autocomplete.setFields(['address_component']);

		  // When the user selects an address from the drop-down, populate the
		  // address fields in the form.
		  autocomplete.addListener('place_changed', fillInAddress);
		}

		function fillInAddress() {
		  // Get the place details from the autocomplete object.
		  var place = autocomplete.getPlace();

		  // Get each component of the address from the place details,
		  // and then fill-in the corresponding field on the form.
		  
		  document.getElementById('CustomerName').value = place.name;
		  
		  var streetNo = '';
		  var loc = '';
		  var city = '';
		  var state = '';
		  var zip = '';
		  var country = '';
		  
		  
		  for (var i = 0; i < place.address_components.length; i++) {
		
		    var addressType = place.address_components[i].types[0];
		    var val = '';
			
			if(addressType == 'street_number'){
				streetNo = place.address_components[i]['short_name'];
			}
		    if(addressType == 'route'){
				loc = place.address_components[i]['long_name'];
		    }
		    if(addressType == 'locality'){
				city = place.address_components[i]['long_name'];
		    }
		    if(addressType == 'administrative_area_level_1'){
				state = place.address_components[i]['short_name'];
		    }
		    if(addressType == 'postal_code'){
				zip = place.address_components[i]['short_name'];
		    }
		    if(addressType == 'country'){
				val = place.address_components[i]['short_name'];
		    	$('##country1 > option').each(function() {
				    var cArray = $(this).text().split(' ');
				    if(val == cArray[0]){
						country = $(this).val();
				    }
				});
		    }
		  }
		  
		  if($.trim(streetNo).length){
			document.getElementById('location').value = streetNo+' '+loc;
		  }
		  else{
			document.getElementById('location').value = loc;
		  }
		  document.getElementById('City').value = city;
		  document.getElementById('state').value = state;
		  document.getElementById('Zipcode').value = zip;
		  document.getElementById('country1').value = country;
		  
		}

		// Bias the autocomplete object to the user's geographical location,
		// as supplied by the browser's 'navigator.geolocation' object.
		function geolocate() {
		  if (navigator.geolocation) {
		    navigator.geolocation.getCurrentPosition(function(position) {
		      var geolocation = {
		        lat: position.coords.latitude,
		        lng: position.coords.longitude
		      };
		      var circle = new google.maps.Circle(
		          {center: geolocation, radius: position.coords.accuracy});
		      autocomplete.setBounds(circle.getBounds());
		    });
		  }
		}
	</cfif>
	function popupAddFactory() {
		var select = $('select[name="FactoringID"]');
		var options = select.children('option:selected');
		if(options.val() == "addFactory"){
			openAddNewFactoryPopup();
		}
	}
</script>
    
<cfif url.customerid eq 0 AND request.qSystemSetupOptions.TimeZone>
	<script src="https://momentjs.com/downloads/moment.js"></script>
	<script src="https://momentjs.com/downloads/moment-timezone-with-data.js"></script>
	<script type="text/javascript">
		$(document).ready(function(){
			var timeZone = moment.tz.guess();
			var time = new Date();
			var timeZoneOffset = time.getTimezoneOffset();
			$('##TimeZone').val(moment.tz.zone(timeZone).abbr(timeZoneOffset));
		})
	</script>
</cfif>

<cfif url.customerid eq 0 AND  request.qSystemSetupOptions.GoogleAddressLookup>
	<script src="https://maps.googleapis.com/maps/api/js?key=AIzaSyBPOZyc0LQameJpMi8buq_z3kGwtyYj_Zk&libraries=places&callback=initAutocomplete"
        async defer></script>
</cfif>
</cfoutput>
<cfoutput>
	<script type="text/javascript">
        $( document ).ready(function() {
        	$('.RemitFL').change(function(){
        		$('##FactoringID option:eq(0)').attr("selected", "selected");
        	})

            $('.form-popup-close').click(function(){
                $('body').removeClass('formpopup-body-noscroll');
                $(this).closest( ".form-popup" ).hide();
                $('.formpopup-overlay').hide();
                $('##FactoringID option:eq(0)').attr("selected", "selected");
            });
            $('.fpCityAuto').each(function(i, tag) {
                $(tag).autocomplete({
                    multiple: false,
                    width: 400,
                    scroll: true,
                    scrollHeight: 300,
                    cacheLength: 1,
                    highlight: false,
                    dataType: "json",
                    autoFocus: true,
                    source: 'searchCustomersAutoFill.cfm?queryType=getCity&CompanyID=#session.CompanyID#',
                    select: function(e, ui) {
                        $(this).val(ui.item.city);
                        var stateEle = $(this).closest('div').find('.fpStateAuto').attr("id");
                        var zipEle = $(this).closest('div').find('.fpZipAuto').attr("id");
                        if(!$.trim($('##'+stateEle).val()).length){
                            if($("##"+stateEle+" option[value='"+ui.item.state+"']").length){
                                $("##"+stateEle).val(ui.item.state);
                            }
                            else{
                                $("##"+stateEle).val("");
                            }
                        }

                        if(!$.trim($('##'+zipEle).val()).length){
                            $('##'+zipEle).val(ui.item.zip);
                        }
                        return false;
                    }
                });
                $(tag).data("ui-autocomplete")._renderItem = function(ul, item) {
                    return $( "<li>"+item.city+"<br/><b><u>State</u>:</b> "+ item.state+"&nbsp;&nbsp;&nbsp;<b><u>Zip</u>:</b>" + item.zip+"</li>" )
                            .appendTo( ul );
                }
            });

            $('.fpZipAuto').each(function(i, tag) {
                $(tag).autocomplete({
                    multiple: false,
                    width: 400,
                    scroll: true,
                    scrollHeight: 300,
                    cacheLength: 1,
                    minLength: 1,
                    highlight: false,
                    dataType: "json",
                    autoFocus: true,
                    source: 'searchCustomersAutoFill.cfm?queryType=GetZip&CompanyID=#session.CompanyID#',
                    select: function(e, ui) {
                        $(this).val(ui.item.zip);
                        var cityEle = $(this).closest('div').find('.fpCityAuto').attr("id");
                        var stateEle = $(this).closest('div').find('.fpStateAuto').attr("id");
                        if(!$.trim($('##'+cityEle).val()).length){
                            $('##'+cityEle).val(ui.item.city);
                        }
                        if(!$.trim($('##'+stateEle).val()).length){
                            if($("##"+stateEle+" option[value='"+ui.item.state+"']").length){
                                $("##"+stateEle).val(ui.item.state);
                            }
                            else{
                                $("##"+stateEle).val("");
                            }
                        }
                        return false;
                    }
                });
                $(tag).data("ui-autocomplete")._renderItem = function(ul, item) {
                    return $( "<li>"+item.zip+"<br/><b><u>State</u>:</b> "+ item.state+"&nbsp;&nbsp;&nbsp;<b><u>City</u>:</b>" + item.city+"</li>" )
                            .appendTo( ul );
                }
            });
		})
	</script>
	<div class="formpopup-overlay" style="left: 0;"></div>
</cfoutput>
<cfinclude template="formpopup/AddNewFactory.cfm">