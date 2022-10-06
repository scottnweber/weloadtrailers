
<cfoutput>
	<cfinvoke component="#variables.objloadGateway#" method="getSystemSetupOptions" returnvariable="request.qGetSystemSetupOptions" />
	<cfset requireValidMCNumber = request.qGetSystemSetupOptions.requireValidMCNumber>
	<cfinvoke component="#variables.objloadGateway#" method="getcurAgentMaildetails" returnvariable="request.qcurMailAgentdetails" employeID="#session.empid#" />
	<cfif request.qcurMailAgentdetails.recordcount gt 0 and (request.qcurMailAgentdetails.SmtpAddress eq "" or request.qcurMailAgentdetails.SmtpUsername eq "" or request.qcurMailAgentdetails.SmtpPort eq "" or request.qcurMailAgentdetails.SmtpPassword eq "" or request.qcurMailAgentdetails.SmtpPort eq 0)>
		<cfset mailsettings = "false">
	<cfelse>
		<cfset mailsettings = "true">
	</cfif>
	<cfif request.qGetSystemSetupOptions.freightBroker EQ 1>
		<cfset variables.freightBroker = "Carrier">
	<cfelse>
		<cfset variables.freightBroker = "Driver">
	</cfif>	
	<!---Init the default value------->
	<cfparam name="pv_apcant_id" default="">
	<cfparam name="pv_usdot_no" default="">
	<cfparam name="pv_pref_docket" default="">
	<cfparam name="pv_legal_name" default="">
	<cfparam name="AuthType_Common_status" default="">
	<cfparam name="AuthType_Common_appPending" default="">
	<cfparam name="AuthType_Contract_status" default="">
	<cfparam name="AuthType_Contract_appPending" default="">
	<cfparam name="AuthType_Broker_status" default="">
	<cfparam name="AuthType_Broker_appPending" default="">
	<cfparam name="household_goods" default="">
	<cfparam name="bipd_Insurance_required" default="">
	<cfparam name="bipd_Insurance_on_file" default="">
	<cfparam name="cargo_Insurance_required" default="">
	<cfparam name="cargo_Insurance_on_file" default="">
	<cfparam name="webLegger" default="">
	<cfparam name="MCNumber" default="">
	<cfparam name="businessAddress" default="">
	<cfparam name="businessPhone" default="">
	<cfparam name="insCarrier" default="">
	<cfparam name="insPolicy" default="">
	<cfparam name="insAgentName" default="">
	<cfparam name="insCarrierDetails" default="">
	<cfparam name="Status" default="">
	<cfparam name="StatusValID" default="">
	<cfparam name="StatusValCODE" default="">
	<cfparam name="CarrierName" default="">
	<cfparam name="City" default="">
	<cfparam name="State" default="">
	<cfparam name="State1" default="">
	<cfparam name="Address" default="">
	<cfparam name="Zipcode" default="">
	<cfparam name="Country" default="">
	<cfparam name="Country1" default="9bc066a3-2961-4410-b4ed-537cf4ee282a">
	<cfparam name="Phone" default="">
	<cfparam name="PhoneExt" default="">
	<cfparam name="CellPhone" default="">
	<cfparam name="CellPhoneExt" default="">
	<cfparam name="Fax" default="">
	<cfparam name="FaxExt" default="">
	<cfparam name="RemitName" default="">
	<cfparam name="RemitAddress" default="">
	<cfparam name="RemitCity" default="">
	<cfparam name="RemitState" default="">
	<cfparam name="RemitZipCode" default="">
	<cfparam name="RemitContact" default="">
	<cfparam name="RemitPhone" default="">
	<cfparam name="RemitFax" default="">
	<cfparam name="RemitEmail" default="">
	<cfparam name="FF" default="">
	<cfparam name="Tollfree" default="">
	<cfparam name="TollfreeExt" default="">
	<cfparam name="Email" default="">
	<cfparam name="Email" default="">
	<cfparam name="Website" default="">
	<cfparam name="InsCompany" default="">
	<cfparam name="InsComPhone" default="">
	<cfparam name="InsAgent" default="">

	<cfparam name="InsEmail" default="">
	<cfparam name="InsEmailCargo" default="">
	<cfparam name="InsEmailGeneral" default="">

	<cfparam name="InsAgentPhone" default="">
	<cfparam name="InsPolicyNo" default="">
	<cfparam name="InsExpDate" default="">
	<cfparam name="InsExpDateLive" default="">
	<cfparam name="CargoAmount" default="">
	<cfparam name="Certificate" default="">
	<cfparam name="Terms" default="">
	<cfparam name="TaxID" default="">
	<cfparam name="Track1099" default="">
	<cfparam name="RegNumber" default="">
	<cfparam name="ContactPerson" default="">
	<cfparam name="Dispatcher" default="">
	<cfparam name="TaxID" default="">
	<cfparam name="InsLimit" default="">
	<cfparam name="CommRate" default="">
	<cfparam name="CarrierInstructions" default="">
	<cfparam name="EquipmentNotes" default="">
	<cfparam name="Website" default="">
	<cfparam name="editid" default="0">
	<cfparam name="state11" default="">
	<cfparam name="StateValCODE" default="">
	<cfparam name="notes" default="">
	<cfparam name="variables.InsuranceCompanyName" default="">
	<cfparam name="variables.InsuranceCompanyAddress" default="">
	<cfparam name="variables.ExpirationDate" default="">
	<cfparam name="variables.commonStatus" default="1">
	<cfparam name="variables.contractstatus" default="1">
	<cfparam name="variables.brokerStatus" default="1">
	<cfparam name="variables.commonAppPending" default="1">
	<cfparam name="variables.contractAppPending" default="1">
	<cfparam name="variables.BrokerAppPending" default="1">
	<cfparam name="variables.BIPDInsRequired" default="1">
	<cfparam name="variables.cargoInsRequired" default="1">
	<cfparam name="variables.BIPDInsonFile" default="1">
	<cfparam name="variables.householdGoods" default="1">
	<cfparam name="variables.cargoInsonFile" default="1">
	<cfparam name="variables.CARGOExpirationDate" default="">
	<cfparam name="vendorID" default="">
	<cfparam name="MobileAppPassword" default="">
	<cfparam name="isShowDollar" default="1">
	<cfparam name="variables.InsAddress" default="">
	<cfparam name="variables.formatRequired" default="">
	<cfparam name="DOTNumber" default="">
	<cfparam name="bit_addWatch" default="">
	<cfparam name="risk_assessment" default="">
	<cfparam name="SaferWatchCarrierCertData" default="0">
	<cfparam name="PreConMethod" default="">
	<cfparam name="LoadLimit" default="">
	<cfset variables.carrierdisabledStatus=false>
	<cfparam name="defaultCurrency" default="0">
	<cfparam name="carrierEmailAvailableLoads" default="">
	<!--- #837 - Carrier Screen add new field Dispatch Fee --->
	<cfparam name="DispatchFee" default="">
	<cfparam name="RatePerMile" default="">
	<cfparam name="DispatchFeeAmount" default="">
	<cfparam name="SCAC" default="">
	<cfparam name="memo" default="">
	<cfparam name="InsCompanyCargo" default="">
	<cfparam name="InsComPhoneCargo" default="">
	<cfparam name="InsAgentCargo" default="">
	<cfparam name="InsAgentPhoneCargo" default="">
	<cfparam name="InsPolicyNoCargo" default="">
	<cfparam name="InsExpDateCargo" default="">
	<cfparam name="InsLimitCargo" default="">
	<cfparam name="variables.InsuranceCompanyAddressCargo" default="">
	<cfparam name="variables.householdGoodsCargo" default="1">
	<cfparam name="InsCompanyGeneral" default="">
	<cfparam name="InsComPhoneGeneral" default="">
	<cfparam name="InsAgentGeneral" default="">
	<cfparam name="InsAgentPhoneGeneral" default="">
	<cfparam name="InsPolicyNoGeneral" default="">
	<cfparam name="InsExpDateGeneral" default="">
	<cfparam name="InsLimitGeneral" default="">
	<cfparam name="variables.InsuranceCompanyAddressGeneral" default="">
	<cfparam name="variables.householdGoodsGeneral" default="1">
	<cfparam name="employeeType" default="">
	<cfparam name="source" default="">
	<cfparam name="carrierFactoringID" default=""> 
	<cfparam name="OnboardStatus" default="0"> 
	<cfparam name="CarrierOnboardStep" default=""> 
	<cfparam name="allowStatusChange" default="1">
	<!--- Encrypt String --->
	<cfset Secret = application.dsn>
	<cfset TheKey = 'NAMASKARAM'>
	<cfset Encrypted = Encrypt(Secret, TheKey)>
	<cfset dsn = URLEncodedFormat(ToBase64(Encrypted))>
	<cfset getMCNoURL="">
	<cfif isdefined('url.mcNo') and len(url.mcNo) gt 1>
		<cfset MCNumber=url.mcNo>
	</cfif>
	
	<cfif request.qgetsystemsetupoptions.ForeignCurrencyEnabled>
		<cfinvoke component="#variables.objloadGateway#" method="getCurrencies" IsActive="1" returnvariable="request.qGetCurrencies" />
	</cfif>
	<script type="text/javascript">
		$(function() {

		// City DropBox
			$("##City, ##RemitCity").autocomplete({
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
	                if($("##state option[value='"+ui.item.state+"']").length){
	                    $('##state').val(ui.item.state);
	                }
	                else{
	                    $('##state').val("");
	                }
	                $('##StateName').val(ui.item.state);
	                $('##Zipcode').val(ui.item.zip);
	                return false;
	            }
	        });
	        $("##City, ##RemitCity").data("ui-autocomplete")._renderItem = function(ul, item) {
	            return $( "<li>"+item.city+"<br/><b><u>State</u>:</b> "+ item.state+"&nbsp;&nbsp;&nbsp;<b><u>Zip</u>:</b>" + item.zip+"</li>" )
	                    .appendTo( ul );
	        }
			
			$("##Zipcode, ##RemitZipcode").autocomplete({
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
	                //auto complete the state and city based on first 5 characters of zip code
	                //Donot update a field if there is already a value entered
                    if($('##state').val() == '')
                    {   
                        if($("##state option[value='"+ui.item.state+"']").length){
                            $('##state').val(ui.item.state);
                        }
                        else{
                            $('##state').val("");
                        }
                        $('##StateName').val(ui.item.state);
                    }
                    if($('##City').val() == '')
                    {
                        $('##City').val(ui.item.city);
                    }
	                return false;
	            }
	        });
	        $("##Zipcode, ##RemitZipcode").data("ui-autocomplete")._renderItem = function(ul, item) {
	            return $( "<li>"+item.zip+"<br/><b><u>State</u>:</b> "+ item.state+"&nbsp;&nbsp;&nbsp;<b><u>City</u>:</b>" + item.city+"</li>" )
	                    .appendTo( ul );
	        }
	});
	function popitup(url) {
		newwindow=window.open(url,'Map','height=600,width=1000');
		if (window.focus) {newwindow.focus()}
		return false;
	}
	function InsAgentPhone1() {
	  var q=$('##InsAgentPhone').val();
	if(q.length>=50)
	{
		alert('Agent Phone needs to be corrected or text length must be less than 50' );
	  return false;
	 }
	}

	function delRow(rw){
		var rowId = $(rw).attr("id");
		var index = parseInt(rowId.split('_')[1]);
		var CarrierCommID = $('##CarrierCommID_'+index).val();
		var currentRowCount = parseInt($('.commodityWrap tbody tr').length);

		if (confirm("Are you sure you want to remove this?")) {

			if(CarrierCommID==''){
				delRow2(index,currentRowCount);
			}
			else{
				var path = urlComponentPath+"carriergateway.cfc?method=DeleteCarrierCommodity";
                $.ajax({
                    type: "Post",
                    url: path,
                    dataType: "json",
                    async: false,
                    data:{
                        dsn:'#application.dsn#',
                        ID:CarrierCommID
                    },
                    beforeSend: function() {
                    },
                    success: function(data){
                        if(data == 'Success'){
                            delRow2(index,currentRowCount);
                        }
                        else{
                            alert('Something went wrong. Unable to delete.');
                        }
                    }
                });
			}
		}
		
	}

	function delRow2(index,currentRowCount){

		if(currentRowCount==1){
			$(".sel_commodityType").val("");
			$("##CarrierCommID_1").val("");
			$(".txt_carrRateComm").val("$0.00");
			$(".txt_custRateComm").val("0%");
		}
		else{
			$("##trcomm_"+index).remove();
			if(currentRowCount>index){
				for(i=index+1;i<=currentRowCount;i++){
					var row = $("##trcomm_"+i);
					var j = i-1;
					$(row).find(".sel_commodityType").attr("name","sel_commodityType_"+j);
					$(row).find(".CarrierCommID").attr("id","CarrierCommID_"+j);
					$(row).find(".txt_carrRateComm").attr("name","txt_carrRateComm_"+j);
					$(row).find(".txt_custRateComm").attr("name","txt_custRateComm_"+j);
					$(row).find(".txt_custRateComm").attr("id","txt_custRateComm_"+j);
					$(row).find(".delRow").attr("id","delRow_"+j);
					$(row).attr("id","trcomm_"+j);
				}
			}
		}
	}

	function addNewRow(){
		var selectOptions = $('.sel_commodityType').html();
		var currentRowCount = parseInt($('.commodityWrap tbody tr').length);
		var newRowCont = currentRowCount+1;
		var appenString = '<tr id="trcomm_'+newRowCont+'"><td height="20" class="lft-bg">&nbsp;</td><td valign="middle" align="left" class="normaltd" style="width:325px;position:relative;top:-5px;padding:8px 0px;">';
		appenString  = appenString + '<select class="sel_commodityType" id="type" style="width:240px;height:26px;" name="sel_commodityType_'+newRowCont+'">'+selectOptions+'</select>';
		appenString  = appenString + '<input type="hidden" value="" class="CarrierCommID" id="CarrierCommID_'+newRowCont+'">';

		appenString  = appenString + '<input type="hidden" name="numberOfCommodity" value="1"></td>';
		appenString  =	appenString + '<td valign="middle" align="left" class="normaltd" style="width:142px;position:relative;top:-5px;"><input type="text" class="txt_carrRateComm q-textbox" value="$0.00" name="txt_carrRateComm_'+newRowCont+'"></td>';
		appenString  = appenString + '<td valign="middle" align="left" class="normaltd" style="width:250px;position:relative;top:-5px;"><input type="text" class="txt_custRateComm q-textbox" value="0.00%" name="txt_custRateComm_'+newRowCont+'"></td>';

		appenString  = appenString + '<td class="normaltd" colspan="2" valign="middle" align="left" style="position:relative;top:-5px;"><img class="delRow" id="delRow_'+newRowCont+'" onclick="delRow(this)" src="images/delete-icon.gif" style="width:10px;margin-left: 5px;cursor: pointer;"></td>';

		$('.commodityWrap tbody').append(appenString);
		$(appenString).find('.sel_commodityType').attr('name', 'sel_commodityType_' + parseInt(currentRowCount)+1);
	}

	function ConfirmMessage(index,stopno){
		if(stopno !=0){
			index=index+""+stopno;
		}
		percentagedata=$('##txt_custRateComm_'+index).val();
		percentagedata=percentagedata.replace("%", "");
		if(percentagedata.indexOf("%")==-1){
			if(percentagedata<1){
				percentagedata=percentagedata*100;
			}
			var percentagedata = parseFloat(percentagedata).toFixed(2);
			$('##txt_custRateComm_'+index).val(percentagedata+"%");
		}
		if(percentagedata.indexOf("%")>-1){
			var percentagedata = parseFloat(percentagedata).toFixed(2);
			$('##txt_custRateComm_'+index).val(percentagedata+"%");
		}
	}
	</script>

	<cfif isDefined("url.carrierid") and len(url.carrierid) >
		<cfinvoke component="#variables.objCarrierGateway#" method="checkStatusChange" returnvariable="allowStatusChange">
			<cfinvokeargument name="carrierid" value="#url.carrierid#">
		</cfinvoke>
		<cfinvoke component="#variables.objCarrierGateway#" method="getAllCarriers" returnvariable="request.qCarrier">
			<cfinvokeargument name="carrierid" value="#url.carrierid#">
		</cfinvoke>
		<cfinvoke component="#variables.objCarrierGateway#" method="getlifmcaDetails" returnvariable="request.qrygetlifmcaDetails">
			<cfinvokeargument name="carrierid" value="#url.carrierid#">
		</cfinvoke>
		<cfif not structkeyexists(url,"apidetails") and not structkeyexists(url,"saferWatchUpdate") and not structkeyexists(url,"carrierLookoutUpdate")>
			<cfif request.qrygetlifmcaDetails.recordcount>
				<cfset variables.InsuranceCompanyName=request.qrygetlifmcaDetails.InsuranceCompanyName>
				<cfset variables.InsuranceCompanyAddress=request.qrygetlifmcaDetails.InsuranceCompanyAddress>
				<cfset str = Reverse(variables.InsuranceCompanyAddress) >
				<cfset variables.ExpirationDate=request.qrygetlifmcaDetails.ExpirationDate>
				<cfset variables.commonStatus=request.qrygetlifmcaDetails.commonStatus>
				<cfset variables.contractStatus=request.qrygetlifmcaDetails.contractStatus>
				<cfset variables.brokerStatus=request.qrygetlifmcaDetails.brokerStatus>
				<cfset variables.commonAppPending=request.qrygetlifmcaDetails.commonAppPending>
				<cfset variables.contractAppPending=request.qrygetlifmcaDetails.contractAppPending>
				<cfset variables.BrokerAppPending=request.qrygetlifmcaDetails.BrokerAppPending>
				<cfset variables.BIPDInsRequired=request.qrygetlifmcaDetails.BIPDInsRequired>
				<cfset variables.cargoInsRequired=request.qrygetlifmcaDetails.cargoInsRequired>
				<cfset variables.BIPDInsonFile=request.qrygetlifmcaDetails.BIPDInsonFile>
				<cfset variables.cargoInsonFile=request.qrygetlifmcaDetails.cargoInsonFile>
				<cfset variables.householdGoods=request.qrygetlifmcaDetails.householdGoods>
				<cfset variables.CARGOExpirationDate=request.qrygetlifmcaDetails.CARGOExpirationDate>
				<cfset variables.InsuranceCompanyAddressCargo=request.qrygetlifmcaDetails.InsuranceCompanyAddressCargo>
				<cfset variables.InsuranceCompanyAddressGeneral=request.qrygetlifmcaDetails.InsuranceCompanyAddressGeneral>
				<cfset variables.householdGoodsCargo=request.qrygetlifmcaDetails.householdGoodsCargo>
				<cfset variables.householdGoodsGeneral=request.qrygetlifmcaDetails.householdGoodsGeneral>
			</cfif>
			<cfset MCNumber=request.qCarrier.MCNumber>
			<cfset variables.carrierId=url.carrierid>
		<cfelse>
			<cfset variables.carrierId=url.carrierid>
		</cfif>

		<script>			
		$(document).ready(function(){
		//when the page loads for carrier edit ajax call for inserting tab id of the page details
			var path = urlComponentPath+"carriergateway.cfc?method=insertTabDetails";
			$.ajax({
				type: "Post",
				url: path,
				dataType: "json",
				async: false,
				data: {
						tabID:tabID,
						carrierid:'#url.carrierid#',
						userid:'#session.empid#',
						sessionid:'#session.sessionid#',
						dsn:'#application.dsn#'
					},
					success: function(data){
					}
				});

				<cfif structKeyExists(request, "qGetExpiredDocuments") AND request.qGetExpiredDocuments.recordcount>
					if(confirm("This carrier has expired document(s), would you liked to request the carrier to provide new documents now?")){
						openCarrierOnboardPopup('#session.URLToken#&ExpiredDocuments=1','#url.carrierid#');
					}
				</cfif>
				<cfif structKeyExists(request, "qGetExpiredInsurance") AND request.qGetExpiredInsurance.recordcount>
					if(confirm("This carrier has expired Insurance(s), would you liked to request the carrier to provide new documents now?")){
						openCarrierOnboardPopup('#session.URLToken#&ExpiredInsurance=1','#url.carrierid#');
					}
				</cfif>
			});
			var path = urlComponentPath+"carriergateway.cfc?method=CheckCarrierMissingAttachment";
            $.ajax({
                type: "Post",
                url: path,
                dataType: "json",
                data: {
                    carrierid:'#url.carrierid#',companyid:'#session.companyid#',dsn:'#application.dsn#'
                },
                success: function(data){
                    if(data==1){
                        $('##missingReqAtt').show();
                    }
                }
            });
		</script>

		<cfset session.currentCarrierId = url.carrierid>
		<!---Object to get corresponding user edited the carrier--->
		<cfinvoke component="#variables.objCarrierGateway#" method="getUserEditingDetails" carrierid="#url.carrierid#" returnvariable="request.qryUserEditingDetails"/>

		<!---Condition to check user edited the carrier or not--->
		<cfif not len(trim(request.qryUserEditingDetails.InUseBy))>
			<!---Object to update corresponding user editing the carrier record--->
			<cfinvoke component="#variables.objCarrierGateway#" method="updateEditingUserId" carrierid="#url.carrierid#" userid="#session.empid#" status="false"/>
		<cfelse>
			<!---Object to get corresponding Previously edited---->
			<cfinvoke component="#variables.objAgentGateway#" method="getEditingUserName" returnvariable="request.qryGetEditingUserName" employeID="#request.qryUserEditingDetails.inuseby#" />
			<!---Condition to check current employee and previous editing employee are not same--->
			<cfif session.empid neq request.qryUserEditingDetails.inuseby>
				<cfif request.qryGetEditingUserName.recordcount>
					<cfset variables.carrierdisabledStatus=true>
					<div class="msg-area" style="margin-left:10px;margin-bottom:10px">
						<span style="color:##d21f1f">This carrier locked because it is currently being edited by #request.qryGetEditingUserName.Name# #dateformat(request.qryUserEditingDetails.inuseon,"mm/dd/yy hh:mm:ss")#.
							An Administrator can manually override this lock by clicking the unlock button.
						</span>
					</div>
				</cfif>
			</cfif>
		</cfif>
	<cfelse>
		<cfset variables.carrierId=0>

	</cfif>
	<cfset variables.objunitGateway = getGateway("gateways.unitgateway", MakeParameters("dsn=#Application.dsn#,pwdExpiryDays=#Application.pwdExpiryDays#")) >
	<cfinvoke component="#variables.objunitGateway#" method="getloadUnits" status="True" returnvariable="request.qUnits" />
<cfif structKeyExists(url, "CarrierQuoteID")>
	<cfinvoke component="#variables.objloadGateway#" method="getLoadCarrierQuoteDetail" CarrierQuoteID="#url.CarrierQuoteID#" dsn="#application.dsn#" returnvariable="request.qCarrierQuoteDetail" />
	<cfset CarrierName = request.qCarrierQuoteDetail.QCarrierName>
	<cfset DOTNumber = request.qCarrierQuoteDetail.QDOTNumber>
	<cfset MCNumber = request.qCarrierQuoteDetail.QMCNumber>
	<cfset ContactPerson = request.qCarrierQuoteDetail.QContactPerson>
	<cfset CellPhone = request.qCarrierQuoteDetail.QCell>
	<cfset Phone = request.qCarrierQuoteDetail.QPhone>
	<cfset PhoneExt = request.qCarrierQuoteDetail.QPhoneExt>
	<cfset Email = request.qCarrierQuoteDetail.QEmail>
	<cfset url.DOTNumber = request.qCarrierQuoteDetail.QDOTNumber>
	<cfset url.mcNo = request.qCarrierQuoteDetail.QMCNumber>
</cfif>
<cfif isDefined("url.carrierid") and len(url.carrierid) and not structkeyexists(url,"apidetails") and not structkeyexists(url,"saferWatchUpdate") and not structkeyexists(url,"carrierLookoutUpdate")>

	<cfinvoke component="#variables.objCarrierGateway#" method="getLIWebsiteData" returnvariable="request.qLiWebsiteData">
		<cfinvokeargument name="carrierid" value="#url.carrierid#">
    </cfinvoke>
	<cfinvoke component="#variables.objCarrierGateway#" method="getCommodityById"  returnvariable="request.qGetCommodityById" >
		<cfinvokeargument name="carrierID" value="#url.carrierid#">
	</cfinvoke>
     <cfif request.qCarrier.recordcount gt 0 >
	     <cfset CarrierName=request.qCarrier.CarrierName>
	     <cfif isDefined("url.mcNo") and len(url.mcNo) gt 1>
			<cfset MCNumber=url.mcNo>
		 <cfelse>
			 <cfset MCNumber=request.qCarrier.MCNumber>
			 <cfset Address=request.qCarrier.Address>
			 <cfset StateValCODE=trim(request.qCarrier.StateCODE)>
			 <cfset Status=request.qCarrier.Status>
			 <cfset City=request.qCarrier.City>
			 <cfset Zipcode=request.qCarrier.Zipcode>
			 <cfset Country1=request.qCarrier.Country>
			 <cfset Phone=request.qCarrier.Phone>
			 <cfset PhoneExt=request.qCarrier.PhoneExt>
			 <cfif Phone NEQ "" AND NOT listContains(Phone, "-")>
					<cfset Phone =  "#left(Phone,3)#-#mid(Phone,4,3)#-#right(Phone,4)#" />
			</cfif>
			 <cfset RemitName=request.qCarrier.RemitName>
			 <cfset RemitAddress=request.qCarrier.RemitAddress>
			 <cfset RemitCity=request.qCarrier.RemitCity>
			 <cfset RemitState=request.qCarrier.RemitState>
			 <cfset RemitZipCode=request.qCarrier.RemitZipCode>
			 <cfset RemitContact=request.qCarrier.RemitContact>
			 <cfset RemitPhone=request.qCarrier.RemitPhone>
			 <cfset RemitFax=request.qCarrier.RemitFax>
			 <cfset RemitEmail=request.qCarrier.RemitEmail>
			 <cfset FF=request.qCarrier.FF>
			 <cfset InsCompany=request.qCarrier.InsCompany>
			 <cfset InsComPhone=request.qCarrier.InsCompPhone>
			  <cfif InsComPhone NEQ "" AND NOT listContains(InsComPhone, "-")>
					<cfset InsComPhone =  "#left(InsComPhone,3)#-#mid(InsComPhone,4,3)#-#right(InsComPhone,4)#" />
			</cfif>
			 <cfset InsAgent=request.qCarrier.InsAgent>
			 <cfset InsEmail=request.qCarrier.InsEmail>
			 <cfset InsEmailCargo=request.qCarrier.InsEmailCargo>
			 <cfset InsEmailGeneral=request.qCarrier.InsEmailGeneral>
			 <cfset InsAgentPhone=request.qCarrier.InsAgentPhone>
			  <cfif InsAgentPhone NEQ "" AND  NOT listContains(InsAgentPhone, "-")>
					<cfset InsAgentPhone =  "#left(InsAgentPhone,3)#-#mid(InsAgentPhone,4,3)#-#right(InsAgentPhone,4)#" />
			</cfif>
			 <cfset InsPolicyNo=request.qCarrier.InsPolicyNumber>
			 <cfset InsExpDate=request.qCarrier.InsExpDate>
			 <cfset DOTNumber=request.qCarrier.DOTNUMBER>

			 <cfset InsCompanyCargo=request.qCarrier.InsCompanyCargo>
			 <cfset InsComPhoneCargo=request.qCarrier.InsCompPhoneCargo>
			  <cfif InsComPhoneCargo NEQ "" AND NOT listContains(InsComPhoneCargo, "-")>
					<cfset InsComPhoneCargo =  "#left(InsComPhoneCargo,3)#-#mid(InsComPhoneCargo,4,3)#-#right(InsComPhoneCargo,4)#" />
			</cfif>
			 <cfset InsAgentCargo=request.qCarrier.InsAgentCargo>
			 <cfset InsAgentPhoneCargo=request.qCarrier.InsAgentPhoneCargo>
			  <cfif InsAgentPhoneCargo NEQ "" AND  NOT listContains(InsAgentPhoneCargo, "-")>
					<cfset InsAgentPhoneCargo =  "#left(InsAgentPhoneCargo,3)#-#mid(InsAgentPhoneCargo,4,3)#-#right(InsAgentPhoneCargo,4)#" />
			</cfif>
			 <cfset InsPolicyNoCargo=request.qCarrier.InsPolicyNumberCargo>
			 <cfset InsExpDateCargo=request.qCarrier.InsExpDateCargo>
			 <cfset InsCompanyGeneral=request.qCarrier.InsCompanyGeneral>
			 <cfset InsComPhoneGeneral=request.qCarrier.InsCompPhoneGeneral>
			  <cfif InsComPhoneGeneral NEQ "" AND NOT listContains(InsComPhoneGeneral, "-")>
					<cfset InsComPhoneGeneral =  "#left(InsComPhoneGeneral,3)#-#mid(InsComPhoneGeneral,4,3)#-#right(InsComPhoneGeneral,4)#" />
			</cfif>
			 <cfset InsAgentGeneral=request.qCarrier.InsAgentGeneral>
			 <cfset InsAgentPhoneGeneral=request.qCarrier.InsAgentPhoneGeneral>
			  <cfif InsAgentPhoneGeneral NEQ "" AND  NOT listContains(InsAgentPhoneGeneral, "-")>
					<cfset InsAgentPhoneGeneral =  "#left(InsAgentPhoneGeneral,3)#-#mid(InsAgentPhoneGeneral,4,3)#-#right(InsAgentPhoneGeneral,4)#" />
			</cfif>
			 <cfset InsPolicyNoGeneral=request.qCarrier.InsPolicyNumberGeneral>
			 <cfset InsExpDateGeneral=request.qCarrier.InsExpDateGeneral>
		</cfif>
		<cfif request.qGetSystemSetupOptions.CarrierLNI EQ 3 OR request.qGetSystemSetupOptions.CarrierLNI EQ 2>
			<cfset risk_assessment = request.qCarrier.RiskAssessment>
		</cfif>
		 <cfset CellPhone=request.qCarrier.Cel>
		 <cfset CellPhoneExt=request.qCarrier.CellPhoneExt>
		 <cfset Fax=request.qCarrier.Fax>
		 <cfset FaxExt=request.qCarrier.FaxExt>
		 <cfset Tollfree=request.qCarrier.Tollfree>
		 <cfset TollfreeExt=request.qCarrier.TollfreeExt>
		 <cfset Email=request.qCarrier.EmailID>
		 <cfset TaxID=request.qCarrier.TaxID>
		 <cfset Track1099=request.qCarrier.Track1099>
		 <cfset RegNumber=request.qCarrier.RegNumber>
		 <cfset ContactPerson=request.qCarrier.ContactPerson>
		 <cfset InsLimit=request.qCarrier.InsLimit>
		 <cfset InsExpDate=request.qCarrier.InsExpDate>
		 <cfset CarrierInstructions=request.qCarrier.CarrierInstructions>
		 <cfset EquipmentNotes=request.qCarrier.EquipmentNotes>
		 <cfset Website=request.qCarrier.Website>
		 <cfset notes =request.qCarrier.notes>
		 <cfset Terms =request.qCarrier.CarrierTerms>
		 <cfset editid=#url.carrierid#>
		 <cfset vendorID=request.qCarrier.VENDORID>
		 <cfset MobileAppPassword=request.qCarrier.MobileAppPassword>
		 <cfset isShowDollar=request.qCarrier.isShowDollar>
		 <cfset bit_addWatch =  request.qCarrier.SaferWatch>
		 <cfset getMCNoURL="index.cfm?event=addcarrier&carrierid=#url.carrierid#&#session.URLToken#">
		 <cfset PreConMethod=request.qCarrier.ContactHow>
		 <cfset LoadLimit=request.qCarrier.LoadLimit>
		 <cfset defaultCurrency=#request.qCarrier.defaultCurrency#>
		 <cfset carrierEmailAvailableLoads=request.qCarrier.CarrierEmailAvailableLoads>
		 <cfset DispatchFee = request.qCarrier.DispatchFee>
		 <cfset RatePerMile = request.qCarrier.RatePerMile>
		 <cfset DispatchFeeAmount = request.qCarrier.DispatchFeeAmount>
		 <cfset MyCarrierPackets = request.qCarrier.MyCarrierPackets>
		 <cfset SCAC=request.qCarrier.SCAC>
		 <cfset Memo =request.qCarrier.memo>

		 <cfset InsLimitCargo=request.qCarrier.InsLimitCargo>
		 <cfset InsLimitGeneral=request.qCarrier.InsLimitGeneral>
	     <cfset employeeType=request.qCarrier.employeeType>
	     <cfset carrierFactoringID=request.qCarrier.FactoringID>
	     <cfset OnboardStatus=request.qCarrier.OnboardStatus>
	     <cfset CarrierOnboardStep=request.qCarrier.CarrierOnboardStep>
	</cfif>
<cfelse>
	<cfif isDefined("url.carrierid") and len(url.carrierid) >
		<cfinvoke component="#variables.objCarrierGateway#" method="getAllCarriers" returnvariable="request.qCarrier">
			<cfinvokeargument name="carrierid" value="#url.carrierid#">
		</cfinvoke>
		<cfset MyCarrierPackets = request.qCarrier.MyCarrierPackets>
	</cfif>
	<cfif structkeyexists(url,"apidetails")>
		<cfset editid=#url.carrierid#>
		<cfset getMCNoURL="index.cfm?event=addcarrier&carrierid=#url.carrierid#&#session.URLToken#">
	<cfelseif structkeyexists(url,"saferWatchUpdate")>
		<cfset editid=#url.carrierid#>
		<cfset getMCNoURL="index.cfm?event=addcarrier&carrierid=#url.carrierid#&#session.URLToken#">
	<cfelseif structkeyexists(url,"carrierLookoutUpdate")>
		<cfset editid=#url.carrierid#>
		<cfset getMCNoURL="index.cfm?event=addcarrier&carrierid=#url.carrierid#&#session.URLToken#">
	<cfelse>
		<cfset getMCNoURL="index.cfm?event=addcarrier&#session.URLToken#">
	</cfif>

	<cfif isdefined('url.mcNo') and len(url.mcNo) gt 1>
   		<!--- Since carrierid doesnot exists so here make a webservice call --->
    		<cfif request.qGetSystemSetupOptions.CarrierLNI EQ 3>
				<cfinclude template="websiteDATACarrier_Saferwatch.cfm">
			<cfelseif request.qGetSystemSetupOptions.CarrierLNI EQ 2>
				<cfinclude template="websiteDATACarrier_CarrierLookout.cfm">
			<cfelse>
				<cfinclude template="websiteDATACarrierFMCSA.cfm">
			</cfif>
		<!--- end --->
	<cfelseif isdefined('url.DOTNumber') and len(url.DOTNumber) gt 1>
		<!--- Since carrierid doesnot exists so here make a webservice call --->
		<cfif request.qGetSystemSetupOptions.CarrierLNI EQ 3>
			<cfinclude template="websiteDATACarrier_Saferwatch.cfm">
		<cfelseif request.qGetSystemSetupOptions.CarrierLNI EQ 2>
			<cfinclude template="websiteDATACarrier_CarrierLookout.cfm">
		<cfelse>
    		<cfinclude template="websiteDATACarrierFMCSA.cfm">
		</cfif>
		<!--- end --->
	<cfelseif isdefined('url.LegalName') and len(url.LegalName) gt 1>	
		<cfinclude template="websiteDATACarrierFMCSA.cfm">
    </cfif>
</cfif>
   <cfif len(CarrierName)>
    <cfset ValidMCNO=1>


	<cfif structKeyExists(url, "mcNo") or structKeyExists(url, "DOTNumber")>
	    <cfset InsPolicyNo=insPolicy>
	    <cfset InsComPhone=InsAgentPhone>
	    <cfset InsAgentPhone=InsAgentPhone>
	    <cfset variables.InsuranceCompanyAddress=trim(variables.formatRequired)>
 	    <cfset InsAgent=replacenocase(insAgentName,'<br/>','',"all")>
		 <cfset StateValCODE=State11>
		<cfset businessPhone = replacenocase(businessPhone,'(',"","all")>
		<cfset businessPhone = replacenocase(businessPhone,') ',"-","all")>
	    <cfset Phone=businessPhone>
	    <cfset InsCompany=insCarrier>
        <cfif ISVALID("DATE",InsExpDateLive)>
		     <cfset InsExpDate=dateformat(InsExpDateLive,'mm/dd/yyyy')>
        <cfelse>
        	<cfset InsExpDate=''>
        </cfif>

	    <cfset bipd_Insurance_on_file = replace(bipd_Insurance_on_file,"$","","all")>
	    <cfset bipd_Insurance_on_file = replace(bipd_Insurance_on_file,",","","all")>
		<cfif request.qGetSystemSetupOptions.CarrierLNI EQ 3 >
			<cfset InsLimit=val(bipd_Insurance_on_file)>
		<cfelseif request.qGetSystemSetupOptions.CarrierLNI EQ 2>
			<cfset InsLimit=replace(InsLimit,"$","","all")>
		<cfelse>
			<cfset InsLimit=val(bipd_Insurance_on_file)*1000>
		</cfif>
	</cfif>
<cfelse>
	<cfset  ValidMCNO=0>
</cfif>
<cfif isdefined("variables.carrierId") AND variables.carrierId EQ 0 AND len(trim(request.qGetSystemSetupOptions.DefaultCountry)) AND NOT Len(Trim(country1))>
	<cfset country1 = request.qGetSystemSetupOptions.DefaultCountry>
</cfif>
<cfif structKeyExists(session,"errmessage") AND session.errmessage NEQ "" >
	<div class="col-md-12">&nbsp;</div>
	<div id="messageLoadsExportedForCustomer" class="msg-area">#session.errmessage#</div>
	<cfset session.errmessage = "">
</cfif>
<cfform name="frmCarrier" action="index.cfm?event=addcarrier:process&#session.URLToken#&editid=#editid#" onsubmit="return InsAgentPhone1();" method="post" autocomplete="off">
	<input type="hidden" name="IsCarrier" id="IsCarrier" value="1">

	<input type="hidden" name="carrierdisabledStatus" id="carrierdisabledStatus" value="#variables.carrierdisabledStatus#">
	<input type="hidden" name="isSaveEvent" id="isSaveEvent" value="false"/>
	<input name="appDsn" id="appDsn" type="hidden" value="#application.dsn#">
	<input type="hidden" name="tabid" id="tabid" value="">
	<input name="urlToken" id="urlToken" type="hidden" value="#session.urlToken#">
	<cfif structKeyExists(url, "CarrierQuoteID")>
		<input type="hidden" name="CarrierQuoteID" value="#url.CarrierQuoteID#">
		<input type="hidden" name="QStopno" value="#request.qCarrierQuoteDetail.StopNo#">
		<input type="hidden" name="QAmount" value="#ReplaceNoCase(ReplaceNoCase(request.qCarrierQuoteDetail.Amount,'$','','ALL'),',','','ALL')#">
	</cfif>
	<cfif isDefined("url.carrierid") and len(url.carrierid)>
	<cfinvoke component="#variables.objCarrierGateway#" method="getAttachedFiles" linkedid="#url.carrierid#" fileType="3" returnvariable="request.filesAttached" />
    
    <div style="clear:both"></div>
	<cfif isdefined("url.CarrMessage") and len(url.CarrMessage)>
		<div id="message" class="msg-area" style="width:500px">#url.CarrMessage#</div>
	</cfif>
	<cfif structKeyExists(session, "CLresponse") and len(session.CLresponse)>
		<div id="message" class="msg-area-#session.CLresponse#"><cfif session.CLresponse EQ "error">Something went wrong. Unable to update via Carrier Lookout. Please try again later.<cfelse>Updated via Carrier Lookout successfully.</cfif></div>
		<cfset structdelete(session, 'CLresponse', true)/> 
	</cfif>
	<div style="clear:both"></div>

	<div class="search-panel" style="height:50px;width:999px">
		<div style="float: left; width: 80%; text-align: center;"><h1>#Ucase(CarrierName)#</h1></div>
        <input type="hidden" id="SaveAndExit" name="SaveAndExit" value="0"/>
        
	<cfif carrierdisabledStatus neq true>
		<div class="delbutton"><a href="index.cfm?event=carrier&carrierid=#editid#&IsCarrier=1&#session.URLToken#" onclick="return confirm('Are you sure to delete it ?','Delete Carrier');">Delete</a></div>
	</cfif>
	</div>
	<cfinclude template="carrierTabs.cfm">
	<div class="search-panel" style="height:30px;width:1120px">
		<div style="float:left;margin-top: -18px">
			<cfif request.qGetSystemSetupOptions.CarrierLNI EQ 3 >
				<div style="float:left;margin-top: 5px;">
					<input type="checkbox" name="bit_addWatch"   id="AddWatch" value="1" <cfif bit_addWatch EQ 1>checked</cfif>>&nbsp;<label><b>Add Watch</b></label>
					<span>
					<cfif MCNumber NEQ "">
						<cfset number = "MC"&MCNumber >
					<cfelseif  DOTNumber NEQ "" >
						<cfset number = DOTNumber>
					<cfelse>
						<cfset number = 0 >
					</cfif>
						<a href="http://www.saferwatch.com/swCarrierDetailsLink.php?&number=#number#" target="_blank">
							<cfif risk_assessment EQ "Unacceptable">
								&nbsp;<img style="vertical-align:bottom;" src="images/SW-Red.png">
							<cfelseif risk_assessment EQ "Moderate">
								&nbsp;<img style="vertical-align:bottom;" src="images/SW-Yellow.png">
							<cfelseif risk_assessment EQ "Acceptable">
								&nbsp;<img style="vertical-align:bottom;" src="images/SW-Green.png">
							<cfelse>
								&nbsp;<img style="vertical-align:bottom;" src="images/SW-Blank.png">
							</cfif>
						</a>
					</span>
				</div>
			<cfelseif request.qGetSystemSetupOptions.CarrierLNI EQ 2 >
				<div style="float:left;margin-top: 5px;">
					<cfif risk_assessment EQ "Unacceptable">
		                &nbsp;<img style="vertical-align:middle;width: 15px;" src="images/CL-Red.png">
		            <cfelseif risk_assessment EQ "Moderate">
		                &nbsp;<img style="vertical-align:middle;width: 15px;" src="images/CL-Yellow.png">
		            <cfelseif risk_assessment EQ "Acceptable">
		                &nbsp;<img style="vertical-align:middle;width: 15px;" src="images/CL-Green.png">
		            </cfif>
		        </div>
			</cfif>
			<cfif request.qgetsystemsetupoptions.OnboardCarrier EQ 1>
				<cfif OnboardStatus EQ 0>
					<div style="float:left;">
						&nbsp;<cfinput name="OnBoardCarrier" id="OnBoardCarrier" type="button" class="normal-bttn" value="Onboard Carrier" style="width:95px !important;line-height:15px;height: 40px;background-size: contain;white-space: normal;color:##800000" onclick="openCarrierOnboardPopup('#session.URLToken#','#editid#')"/>
					</div>
				<cfelseif OnboardStatus EQ 1>
					<cfif len(trim(CarrierOnboardStep))>
						<cfset onboardbtn = "Onboarding.. #CarrierOnboardStep#">
					<cfelse>
						<cfset onboardbtn = "Onboarding in Progress">
					</cfif>
					<div style="float:left;">
						&nbsp;<cfinput name="OnBoardCarrier" id="OnBoardCarrier" type="button" class="normal-bttn" value="#onboardbtn#" style="width:100px !important;line-height:15px;height: 40px;background-size: contain;white-space: normal;" onclick="openCarrierOnboardPopup('#session.URLToken#','#editid#')"/>
					</div>
					<cfif len(trim(CarrierOnboardStep)) and ListContains(session.rightsList,'addCarrier',',')>
						<div style="float:left;">
							&nbsp;<cfinput name="ManualSign" id="ManualSign" type="button" class="normal-bttn" value="Switch to Manual Sign" style="width:100px !important;line-height:15px;height: 40px;background-size: contain;white-space: normal;" onclick="SwitchManualSign('#editid#')"/>
						</div>
					</cfif>
				<cfelseif OnboardStatus EQ 3>
					<div style="float:left;">
						&nbsp;<cfinput name="OnBoardCarrier" id="OnBoardCarrier" type="button" class="normal-bttn" value="Request Expired Documents" style="width:115px !important;line-height:15px;height: 40px;background-size: contain;white-space: normal;" onclick="openCarrierOnboardPopup('#session.URLToken#&ExpiredDocuments=1','#editid#')"/>
					</div>
				<cfelseif OnboardStatus EQ 4>
					<div style="float:left;">
						&nbsp;<cfinput name="OnBoardCarrier" id="OnBoardCarrier" type="button" class="normal-bttn" value="Documents Pending" style="width:110px !important;line-height:15px;height: 40px;background-size: contain;white-space: normal;" onclick="openCarrierOnboardPopup('#session.URLToken#&ExpiredDocuments=1','#editid#')"/>
					</div>
				<cfelse>
					<div style="float:left;">
						<cfinput name="ResendOnboard" type="button" value="..." style="width: 20px !important;text-align: center;padding: 0;margin-left: -18px;margin-top: 24px;" title="Resend Carrier Onboarding Email" onclick="openCarrierOnboardPopup('#session.URLToken#','#editid#')">
					</div>
					<div style="float:left;">
						&nbsp;<cfinput name="OnBoardCarrier" id="OnBoardCarrier" type="button" class="normal-bttn" value="View Carrier Packet" style="width:95px !important;line-height:15px;height: 40px;background-size: contain;white-space: normal;color:##0f4100;" onclick="ViewCarrierPacket('#editid#')" />
					</div>
				</cfif>
			<cfelseif DOTNumber NEQ "" and request.qGetSystemSetupOptions.MyCarrierPackets>
				<cfif MyCarrierPackets>
					<div style="float:left;margin-left: 20px;">
						<a href="http://www.mycarrierpackets.com/RegisteredCustomer/CarrierDetails/DOTNumber/#DOTNumber#" target="_blank">
							&nbsp;<img style="vertical-align:bottom;" src="images/logo/mcp_logo.png" width="40">
							<strong>View Carrier Packet</strong>
						</a>
					</div>
				<cfelse>
					<div style="float:left;">
						<cfinput name="MyCarrierPackets" id="MyCarrierPackets" type="hidden"/>
						&nbsp;<cfinput name="inviteCarrier" id="inviteCarrier" type="button" class="normal-bttn" value="Onboard Carrier" style="width:95px !important;line-height:15px;height: 40px;background-size: contain;white-space: normal;"/>
					</div>
				</cfif>
			</cfif>
			
			<div style="float: left;margin-left: 3px;">
				<input id="mailDocLink" style="width:110px !important;line-height: 15px;height: 40px;background-size: contain;" type="button" class="normal-bttn"value="Email Doc" <cfif mailsettings>data-allowmail="true"<cfelse>data-allowmail="false"</cfif>/>
			</div>
	  		<cfif request.qGetSystemSetupOptions.CarrierLNI EQ 3 >
			  	<div style="float: left;margin-left: 3px;">
					<cfinput name="Update" id="update_btn" type="button" class="normal-bttn"  onclick="return getsaferwatchConfirmation();"      value="Update Via SaferWatch" style="width:110px !important;line-height:15px;height: 40px;background-size: contain;white-space: normal;" />
				</div>
			 <cfelseif request.qGetSystemSetupOptions.CarrierLNI EQ 2 >
			 	<div style="float: left;margin-left: 3px;margin-right: 3px;">
					<cfinput name="Update" id="update_btn" type="button" class="normal-bttn"  onclick="return getCarrierLookoutConfirmation();" value="Update Via Carrier Lookout" style="width:110px !important;line-height:15px;height: 40px;background-size: contain;white-space: normal;" />
				</div>
			<cfelse>
				<cfset variables.updateLabel = "">
			</cfif>
			<cfif carrierdisabledStatus neq true>
			<cfif requireValidMCNumber EQ True>
			
            <cfinput name="Save" type="submit" class="normal-bttn" value="Save" onclick="return validateCarrier(frmCarrier,'#application.dsn#','#ValidMCNO#','driver');saveExit(0);" onfocus="checkUnload();" style="width:110px !important;height: 40px;background-size: contain;" />
            <cfinput name="SaveAndExit" type="submit" class="normal-bttn" value="Save & Exit" onclick="return validateCarrier(frmCarrier,'#application.dsn#','#ValidMCNO#','driver');saveExit(1);" onfocus="checkUnload();" style="width:110px !important;height: 40px;background-size: contain;" />

            
		  <cfelse>
          
          <cfinput name="Save" type="submit" class="normal-bttn" value="Save" onclick="return validateCarrier(frmCarrier,'#application.dsn#',0);saveExit(0);" onfocus="checkUnload();" style="width:110px !important;height: 40px;background-size: contain;;" />
	            <cfinput name="SaveAndExit" type="submit" class="normal-bttn" value="Save & Exit" onclick="return validateCarrier(frmCarrier,'#application.dsn#',1);saveExit(1);" onfocus="checkUnload();" style="width:110px !important;height: 40px;background-size: contain;" />

		  </cfif>
		<cfelse>
			<cfif structkeyexists(session,"rightslist") and len(trim(url.carrierid)) gt 0 and variables.carrierdisabledStatus and ListContains(session.rightsList,'UnlockCarrier',',')>
				<input id="Unlock" name="unlock" type="button" class="green-btnUnlock" onClick="removeCarrierEditAccess('#url.carrierid#');" value="Unlock" style="width:110px !important;height: 40px;background-size: contain;">
			</cfif>
		</cfif>
		</div>
	</div>
	</h1>
	 <div class="white-con-area" style="height: 36px;background-color: ##82bbef;width:999px;">
		 <div style="float: left; width: 20%;" id="divUploadedFiles">
		 	<img id="missingReqAtt" style="float: left;background-color: ##fff;border-radius: 11px;margin-top: 15px;margin-left: 2px;margin-right: 2px;display: none;width: 16px;" src="images/exclamation.ico" title="Required Attachments Missing">
			<cfif carrierdisabledStatus neq true>
			 <cfif request.filesAttached.recordcount neq 0>
				&nbsp;<a id="attachFile" style="display:block;font-size: 13px;padding-left: 2px;color:white;" href="##" onclick="popitup('../fileupload/multipleFileupload/MultipleUpload.cfm?id=#url.carrierid#&attachTo=3&user=#session.adminusername#&dsn=#dsn#&attachtype=Carrier&CompanyID=#session.CompanyID#')"><img style="vertical-align:bottom;" src="images/attachment.png">View/Attach Files</a>
			<cfelse>
				&nbsp;<a style="display:block;font-size: 13px;padding-left: 2px;color:white;" href="##" onclick="popitup('../fileupload/multipleFileupload/MultipleUpload.cfm?id=#url.carrierid#&attachTo=3&user=#session.adminusername#&dsn=#dsn#&attachtype=Carrier&CompanyID=#session.CompanyID#')"><img style="vertical-align:bottom;" src="images/attachment.png">Attach Files</a>

			</cfif>
			<cfelse>
				&nbsp;
				<span style="display:block;font-size: 13px;padding-left: 2px;color:white;"></span>
			</cfif>
		</div>
		<div style="float: left; width: 46%;margin-left: 150px;"><h2 style="color:white;font-weight:bold;">Carrier Information</h2></div>
	</div>
	<div style="clear:left;"></div>
<cfelse>
	<cfset tempLoadId = #createUUID()#>
	 <cfset session.checkUnload ='add'>
	<div>
		<div style="float:left;">
			<h1>Add New Carrier</h1>
		</div>
		<div style="float:left;">
			<cfif MCNumber NEQ "">
				<cfset number = "MC"&MCNumber >
			<cfelseif  DOTNumber NEQ "" >
				<cfset number = DOTNumber>
			<cfelse>
				<cfset number = 0 >
			</cfif>
			<cfif request.qGetSystemSetupOptions.CarrierLNI EQ 3 >
				<a href="http://www.saferwatch.com/swCarrierDetailsLink.php?&number=#number#" target="_blank">
					<cfif risk_assessment EQ "Unacceptable">
						&nbsp;<img style="vertical-align:bottom;margin-top: 10px;" src="images/SW-Red.png">
					<cfelseif risk_assessment EQ "Moderate">
						&nbsp;<img style="vertical-align:bottom;margin-top: 10px;" src="images/SW-Yellow.png">
					<cfelseif risk_assessment EQ "Acceptable">
						&nbsp;<img style="vertical-align:bottom;margin-top: 10px;" src="images/SW-Green.png">
					<cfelse>
						&nbsp;<img style="vertical-align:bottom;margin-top: 10px;" src="images/SW-Blank.png">
					</cfif>
				</a>
			<cfelseif request.qGetSystemSetupOptions.CarrierLNI EQ 2 >
				<cfif risk_assessment EQ "Unacceptable">
                    &nbsp;<img style="vertical-align:middle;width: 15px;margin-top: 15px;" src="images/CL-Red.png">
                <cfelseif risk_assessment EQ "Moderate">
                    &nbsp;<img style="vertical-align:middle;width: 15px;margin-top: 15px;" src="images/CL-Yellow.png">
                <cfelseif risk_assessment EQ "Acceptable">
                    &nbsp;<img style="vertical-align:middle;width: 15px;margin-top: 15px;" src="images/CL-Green.png">
                </cfif>
			</cfif>
		</div>
		<cfif not isDefined("url.carrierid")>
			<fieldset class="carrierFields">
				<div style="float:right;margin-top: 10px;margin-right: 147px;">
					<cfinput name="Save" type="submit" class="normal-bttn" value="Save" onClick="return validateAddCarrier(frmCarrier);saveExit(0)" onfocus="checkUnload();" style="width:44px;"/>
					<cfif structKeyExists(url, "CarrierQuoteID")>
						<cfinput name="Save" type="submit" class="normal-bttn" value="Save & Book" onClick="return validateAddCarrier(frmCarrier);saveExit(1)" onfocus="checkUnload();" style="width:44px;"/>
					<cfelse>
	                    <cfinput name="SaveAndExit" type="submit" class="normal-bttn" value="Save & Exit" onClick="return validateAddCarrier(frmCarrier);saveExit(1)" onfocus="checkUnload();" style="width:44px;"/>
	                </cfif>
                    <cfinput name="Return" type="button" class="normal-bttn" onclick="javascript:history.back();" value="Back" style="width:62px;" />					<input type="hidden" id="SaveAndExit" name="SaveAndExit" value="0"/>
                    
				</div>
				<div style="clear:both;"></div>
			</fieldset>
		</cfif>
		<div style="clear:both;"></div>
	</div>
		 <div class="white-con-area" style="height: 36px;background-color: ##82bbef;width:999px">
			 <div style="float: left; width: 20%;" id="divUploadedFiles">
			</div>
			<div style="float: left; width: 80%;margin-left: 150px;"><h2 style="color:white;font-weight:bold;">Carrier Information</h2></div>
		</div>
	<div style="clear:left;"></div>
</cfif>
<cfif isdefined("message") and len(message)>
<div class="msg-area" style="margin-left: 13px;">#message#</div>
</cfif>

			<div class="white-con-area" style="width:999px">
				<div class="white-mid" style="width:999px">
					<h3 id="hViewOnly" style="font-weight: bold;color: red;width:100%;text-align:center;display: none;">VIEW ONLY. EDIT NOT ALLOWED</h3>
                     <cfinput type="hidden" id="editid" name="editid" value="#editid#">
                     <cfinput type="hidden" id="CompanyID" name="CompanyID" value="#session.CompanyID#">
					 <input type="hidden" name="risk_assessment" value="#risk_assessment#" >
					 <input type="hidden" name="source" value="#source#" >
					 <cfif request.qGetSystemSetupOptions.CarrierLNI EQ 3>
					 	<cfset CarrierLNISaferWatch = 1>
					 <cfelse>
					 	<cfset CarrierLNISaferWatch = 0>
					 </cfif>
					 <cfinput type="hidden" id="SaferWatch" name="SaferWatch" value="#val(CarrierLNISaferWatch)#">
						<div class="form-con" style="width:475px;">
							<fieldset class="carrierFields">
								<label class="DOTNumber" style="width: 133px;">DOT ##</label>
                      		    <cfif structkeyexists(url,"DOTNumber")>
                      		    	<cfinput name="DOTNumber" id="DOTNumber" tabindex="1" type="text" value="#Dotnumber#" maxlength="50"/>
                      		    <cfelse>
									<cfinput name="DOTNumber" id="DOTNumber" tabindex="1" type="text" value="#DOTNumber#" maxlength="50"/>
                      		    </cfif>
                                <label  style="width: 46px;">MC ##</label>
								<cfif requireValidMCNumber EQ True>
								  <cfinput name="MCNumber" id="MCNumber" type="text" tabindex="2"  value="#MCNumber#"  required="no" message="Please enter MC Number" maxlength="50"/>
								<cfelse>
								  <cfinput name="MCNumber" id="MCNumber" type="text" tabindex="2"  value="#MCNumber#" onchange="getMCDetails('#getMCNoURL#',this.value,'#application.dsn#','carrier');" maxlength="50"/>
								</cfif>
                      		    <div class="clear"></div>
                      		     <label>Company *</label>
				       	        <cfinput name="CarrierName" id="CarrierName" type="text" tabindex="3" value="#CarrierName#"  required="yes" message="Please enter carrier name" maxlength="100"  class="disAllowHash"/>
				       			<div class="clear"></div>
                      		    <label>Vendor Code</label>

                             	<cfif isdefined('url.CarrierId') and len(url.carrierId) GT 1 AND (request.qCarrier.AYBImport EQ true) >
                                	<cfinput name="venderId" type="text" value="#trim(vendorID)#" readonly  maxlength="10" style="width:104px !important;">
                                <cfelse>
                                	<cfinput name="venderId" id="venderId" type="text" style="width:104px !important;" value="#trim(vendorID)#" tabindex="4"  bindAttribute="autocomplete" bind="off" maxlength="10" />		
                                </cfif>

                                <label style="width:49px;">SCAC&nbsp;</label>

                             	<cfinput class="alphanumeric" name="SCAC" tabindex="5" type="text" maxlength="8" style="width:104px !important;" value="#SCAC#"/>

                      		    <div class="clear"></div>
                      		   
				       	        <cfinput name="RegNumber" type="hidden" value="#RegNumber#" maxlength="20"/>
							   	<label>Address *</label>
								<textarea rows="2" tabindex="6" maxlength="200" cols="" name="Address" style="height:auto;">#trim(Address)#</textarea>
								<div class="clear"></div>
								<label>City *</label>
								<cfinput maxlength="150" name="City" id="City" tabindex="-1" type="text" value="#City#" required="yes" message="Please enter a city"/>
								<div class="clear"></div>
									<label>State *</label>

                                <select name="State" id="state" tabindex="-1" style="width:100px;">
                                    <option value="">Select</option>
<cfloop query="request.qstates">
<option value="#request.qstates.StateCode#" <cfif ucase(request.qstates.StateCode) eq #ucase(StateValCODE)#> selected="true"</cfif>>#request.qstates.statecode#</option>
</cfloop>
                               </select>
								<label style="width:70px;">Zip* </label>
								<cfinput name="Zipcode" style="width:100px;" id="Zipcode" type="text" value="#Zipcode#" required="yes" tabindex="9" message="Please enter a zipcode" maxlength="20"/>
							<div class="clear"></div>
							<label>Country *</label>
							<select name="Country" tabindex="10">
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
							<label>Phone*</label>
							<cfinput name="Phone" tabindex="11" type="text" value="#Phone#" required="yes" message="Please enter Phone Number." onchange="ParseUSNumber(this,'Phone');" style="width:185px;" maxlength="150"/>
							<label class="ex" style="width:20px;">Ext.</label>
        					<input type="text" name="PhoneExt" tabindex="12" style="width:50px;" value="#PhoneExt#" maxlength="10">
							<div class="clear"></div>
							<label>Fax</label>
							<cfinput name="Fax" type="text" tabindex="13" value="#Fax#" style="width:185px;" maxlength="150" onchange="ParseUSNumber(this,'Fax');"/>
							<label class="ex" style="width:20px;">Ext.</label>
        					<input type="text" name="FaxExt" tabindex="14" style="width:50px;" value="#FaxExt#" maxlength="10">
							<div class="clear"></div>
							<label>Toll Free</label>
							<cfinput name="Tollfree" type="text" tabindex="15" value="#Tollfree#" style="width:185px;" maxlength="250"  onchange="ParseUSNumber(this,'Toll Free');"/>
							<label class="ex" style="width:20px;">Ext.</label>
        					<input type="text" name="TollfreeExt" tabindex="16" style="width:50px;" value="#TollfreeExt#" maxlength="10">
							<div class="clear"></div>
							<label>Cell</label>
							<cfinput name="CellPhone" tabindex="17" type="text" value="#CellPhone#" style="width:185px;" maxlength="150" onchange="ParseUSNumber(this,'Cell');"/>
							<label class="ex" style="width:20px;">Ext.</label>
        					<input type="text" name="CellPhoneExt" tabindex="18" style="width:50px;" value="#CellPhoneExt#" maxlength="10">
        					<div class="clear"></div>
        					<label>Emp. Type</label>
                            <select name="employeeType" tabindex="19">
								<option value="">Select</option>
								<option value="ownerOperator" <cfif employeeType EQ "ownerOperator"> selected="selected" </cfif>>Owner Operator</option>
								<option value="Carrier" <cfif employeeType EQ "Carrier"> selected="selected" </cfif>>Carrier</option>
                            </select>
							<div class="clear"></div>
							<div>
								<label style="text-align:left;">Carrier Terms</label>
								<cftextarea name="memo" style="height:270px;width:400px" maxlength="8000"  tabindex="20">#memo#</cftextarea>
								<div class="clear"></div>
								<p style="font-style: italic;">These terms will override the Carrier Terms in the System Setup.</p>
								<div class="clear"></div>
							</div>
						 </fieldset>
					</div>
					<div class="form-con" style="width:475px">
						<fieldset class="carrierFields">
							<label>Email</label>
							<cfinput class="emailbox" name="Email" type="text" tabindex="21" value="#Email#" maxlength="150" />
							<div class="clear"></div>
							<label>Website</label>
							<cfinput class="emailbox" name="Website" type="text" tabindex="22"  value="#Website#" maxlength="200"/>
							<div class="clear"></div>
							<label>Contact Person</label>
                               <cfinput name="ContactPerson" type="text" tabindex="23" value="#ContactPerson#" maxlength="150">
							<div class="clear"></div>
                               <label>Status</label>
                               <select name="Status" tabindex="24" style="width:100px;" <cfif allowStatusChange EQ 0 OR listFindNoCase("3,4", OnboardStatus) OR (request.qGetSystemSetupOptions.KeepCarrierInactive EQ 1 AND Status EQ 0 AND OnboardStatus EQ 0) OR (Status EQ 0 AND NOT ListContains(session.rightsList,'addCarrier',','))>class="disAllowStatusEdit"</cfif>>
                                <option value="1" <cfif Status is 1> selected="true" </cfif>>Active</option>
                                <option value="0" <cfif Status is 0> selected="true" </cfif>>InActive</option>
                               </select>
								<input name="HasmatLicense" type="hidden" value="False">
                               <div class="clear"></div>
                               <label class="FedTaxId">Fed Tax ID</label>
								<cfinput name="TaxID" type="text" value="#TaxID#" tabindex="26" style="width:120px;" maxlength="20"/>
								<label style="width:60px;">Track 1099</label>
								<select name="Track1099" tabindex="27" style="width:96px;">
									<option value="True" <cfif Track1099 is 'True'> selected="true" </cfif>>True</option>
									<option value="False" <cfif Track1099 is 'False'> selected="true" </cfif>>False</option>
								</select>
								<div class="clear"></div>
								<!--- #837: Carrier screen add new field Dispatch Fee: Begins --->
								<cfif request.qGetSystemSetupOptions.Dispatch EQ 1>
									<label >Dispatch Fee </label>
									<cfinput name="DispatchFee" id="DispatchFee" type="text" value="#trim(NumberFormat(DispatchFee, '99999.99'))#%" tabindex="28" onchange="validateDispatchFee();" style="width:45px;text-align:right;"  onkeypress="return isNumberKey(event)" maxlength="6" />	
									<cfinput  name="DispatchFeeAmount" id="DispatchFeeAmount" type="text" style="width:40px;margin-left:7px; text-align:right;" onchange="validateDispatchFeeAmount();" value="#replace("$#Numberformat(DispatchFeeAmount,"___.__")#", " ", "", "ALL")#" tabindex="28">
								</cfif>
								<!--- #837: Carrier screen add new field Dispatch Fee: Ends --->
								<label style="width:<cfif request.qGetSystemSetupOptions.Dispatch EQ 1>105<cfelse>90</cfif>px;">Rate Per Mile</label>
								<cfinput name="RatePerMile" id="RatePerMile" type="text" value="#replace("$#Numberformat(RatePerMile,"___.__")#", " ", "", "ALL")#" tabindex="28" style="width:45px;text-align:right;" onchange="validateRatePerMile();">
								<div class="clear"></div>
								
								<label>Mobile App Password </label>														
								 <cfinput name="MobileAppPassword" type="password" tabindex="29" bindAttribute="autocomplete" bind="off" value="#MobileAppPassword#" style="width:126px;"  message="please enter Mobile App Password" autocomplete="new-password" maxlength="50">
								  <label style="width:120px">Show Terms and Amount in <cfif request.qGetSystemSetupOptions.Dispatch EQ 1 AND DispatchFee NEQ 0>Dispatch Report<cfelse>Rate Confirmation</cfif></label>
								 <input type="checkbox" name="isShowDollar" tabindex="30" class="small_chk myElements" style="float: left;" <cfif len(isShowDollar) AND isShowDollar EQ 1>checked="checked"</cfif>>
							<div class="clear"></div>
							<label>Preferred Contact Method</label>
							<select name="PreConMethod" id="PreConMethod" tabindex="31" >
							    <option value="1" <cfif PreConMethod EQ 1> selected="true" </cfif>>E-mail</option>
							    <option value="2" <cfif PreConMethod EQ 2> selected="true" </cfif>>Text</option>
							    <option value="3" <cfif PreConMethod EQ 3> selected="true" </cfif>>Both</option>
							</select>
							<div class="clear"></div>

							<div style="display:none;"><label>Load Limit Per Day</label>  <!---We dont need this as perhttps://loadmanager.freshdesk.com/support/tickets/653---> 
                            <cfinput name="LoadLimit" type="text" value="#trim(LoadLimit)#" tabindex="30"/>
							<div class="clear"></div>
							<label>&nbsp;</label>
							0 = System Default
							<div class="clear"></div></div>
							
							<cfif request.qgetsystemsetupoptions.ForeignCurrencyEnabled>
								<label>Default Currency</label>
								<select name="defaultCurrency" id="defaultCurrency">
									<option value="" >Select Currency</option>
									<cfloop query = "request.qGetCurrencies"> 
										<option value="#CurrencyID#" <cfif defaultCurrency eq CurrencyID> selected="selected" </cfif>>#CurrencyNameISO#(#CurrencyName#)</option>
									</cfloop>		
								</select>
								<div class="clear"></div>
							</cfif>
							<cfif request.qGetSystemSetupOptions.ActivateBulkAndLoadNotificationEmail EQ 1>
								<!--- Activate/Deactivate load alert email --->
								<label>Email Available Loads</label>
								<input tabindex="32" type="checkbox" name="carrierEmailAvailableLoads" <cfif len(carrierEmailAvailableLoads) AND carrierEmailAvailableLoads EQ 1>checked="checked"</cfif> class="small_chk" style="float:left">
							</cfif>
							<cfif isdefined('url.CarrierId') and len(url.carrierId) gt 1>
								<div style="float:right;margin-right: 12px;">
									<cfinput name="currentloads" type="button" class="normal-bttn" onclick="document.location.href='index.cfm?event=load&#session.URLToken#&carrierId=#url.CarrierId#'" value="CURRENT LOADS" style="width:62px;line-height:15px;margin-top:4px;" />
								</div>
							</cfif>
							<div class="clear"></div>
							<div>
								<label style="text-align:left;">#variables.freightBroker# Notes</label>
								<cftextarea tabindex="33" name="Terms" style="height:100px;width:400px" maxlength="50">#Terms#</cftextarea>
								<div class="clear"></div>
							 </div>
							<div class="clear"></div>
							<div style="height: 36px;background-color: ##82bbef;margin-bottom: 5px;text-align: center;">
								<h2 style="color:white;font-weight:bold;padding-top: 10px;">Remit Information</h2>
							</div>
							<cfinvoke component="#variables.objloadGateway#" method="getFactoringDetails" returnvariable="request.qFactorings" />
       	
					       	<label>Factoring Company</label>
							<cfselect name="FactoringID" id="FactoringID" tabindex="34" style="width:285px;">
								<option value="">Select</option>
								<cfloop query="request.qFactorings">
									<option value="#request.qFactorings.Factoringid#" data-RemitName="#request.qFactorings.Name#"
										data-RemitAddress="#request.qFactorings.Address#"
										data-RemitCity="#request.qFactorings.City#"
										data-RemitState="#request.qFactorings.State#"
										data-RemitZip="#request.qFactorings.Zip#"
										data-RemitContact="#request.qFactorings.Contact#"
										data-RemitPhone="#request.qFactorings.Phone#"
										data-RemitFax="#request.qFactorings.Fax#" 
										data-RemitEmail="#request.qFactorings.Email#"
										data-FF="#NumberFormat(request.qFactorings.FF,'0.00')#"
										<cfif request.qFactorings.FactoringID EQ carrierFactoringID> selected </cfif>>#request.qFactorings.Name#</option>
							   </cfloop>
						   </cfselect>
							<div class="clear"></div>
                      		<label>Name</label>
							<cfinput name="RemitName" type="text" tabindex="35" value="#RemitName#" maxlength="100"/>
							<div class="clear"></div>
							<label>Address</label>
							<textarea rows="2" tabindex="36" cols="" maxlength="200" id="RemitAddress" name="RemitAddress" style="height:auto;">#trim(RemitAddress)#</textarea>
							<div class="clear"></div>
							<label>City</label>
							<cfinput name="RemitCity" id="RemitCity" tabindex="-1" maxlength="50" type="text" value="#RemitCity#" style="width:90px;" />
							<label style="width:77px;">State</label>
							<select name="RemitState" id="RemitState" tabindex="-1" style="width:100px;">
                                <option value="">Select</option>
								<cfloop query="request.qstates">
									<option value="#request.qstates.StateCode#" <cfif ucase(request.qstates.StateCode) eq #ucase(RemitState)#> selected="true"</cfif>>#request.qstates.statecode#</option>
								</cfloop>
							</select>
							<div class="clear"></div>
							<label>Zipcode</label>
							<cfinput name="RemitZipcode" type="text" value="#RemitZipcode#" tabindex="39" style="width:90px;" maxlength="20"/>
							<label style="width:77px;">Contact</label>
							<cfinput name="RemitContact" tabindex="40" type="text" value="#RemitContact#"  style="width:90px;" maxlength="150"/>
							<div class="clear"></div>
							<label>Phone</label>
							<cfinput name="RemitPhone" tabindex="41" type="text" value="#RemitPhone#" style="width:90px" onchange="ParseUSNumber(this,'Phone No');" maxlength="150"/>
							<label style="width:77px;">Fax</label>
							<cfinput name="RemitFax" type="text" tabindex="42" value="#RemitFax#" style="width:90px;" onchange="ParseUSNumber(this,'Fax');"  maxlength="150"/>
							<div class="clear"></div>
                      		<label>Email</label>
							<cfinput name="RemitEmail" type="text" tabindex="42" value="#RemitEmail#" maxlength="100"/>
							<div class="clear"></div>
							<label style="margin-left: 190px;">Factoring Fee</label>
							<cfinput name="FF" type="text" value="#NumberFormat(FF,'0.00')#" tabindex="42" style="width:90px;" maxlength="20"/>
							<div class="clear"></div>
							<!--- Insurance Boxes 1 --->
							<table width="237" border="0" cellspacing="0" cellpadding="0" class="noh" bgcolor="" style="    padding-bottom: 9px; margin-left: 76px !important;display:none">
								<thead>
									<tr>
										<th width="5" align="left" valign="top"><img src="images/top-left.gif" alt="" width="5" height="23" /></th>
										<th align="center" valign="middle" class="head-bg">Authority Type</th>
										<th align="center" valign="middle" class="head-bg">Status</th>
										<th align="center" valign="middle" class="head-bg2">App. Pending</th>
										<th width="5" align="right" valign="top"><img src="images/top-right.gif" alt="" width="5" height="23" /></th>
									</tr>
								</thead>
								<tbody>
									<tr bgcolor="##f7f7f7" >
										<td colspan="2" class="head-bg lft-bg" valign="middle" align="center">COMMON</td>
										<td valign="middle" align="center">
											<select name="commonStatus" id="commonStatus" class="activeSelectbox">
												<option value="1" <cfif variables.commonStatus eq 1>selected="true"</cfif>>Active</option>
												<option value="0" <cfif variables.commonStatus eq 0>selected="true"</cfif>>InActive</option>
											</select>
										</td>
										<td valign="middle" align="center">
											<select name="commonAppPending" id="commonAppPending" class="activeSelectbox">
												<option value="1" <cfif variables.commonAppPending eq 1>selected="true"</cfif>>Yes</option>
												<option value="0" <cfif variables.commonAppPending eq 0>selected="true"</cfif>>No</option>
											</select>
										<td class="normal-td3">&nbsp;</td>
									</tr>
									<tr bgcolor="##FFFFFF">
										<td colspan="2" class="head-bg lft-bg" valign="middle" align="center">CONTRACT</td>
										<td valign="middle" align="center">
											<select name="contractStatus" id="contractStatus" class="activeSelectbox">
												<option value="1" <cfif variables.contractStatus eq 1>selected="true"</cfif>>Active</option>
												<option value="0" <cfif variables.contractStatus eq 0>selected="true"</cfif>>InActive</option>
											</select>
										</td>
										<td valign="middle" align="center">
											<select name="contractAppPending" id="contractAppPending" class="activeSelectbox">
												<option value="1" <cfif variables.contractAppPending eq 1>selected="true"</cfif>>Yes</option>
												<option value="0" <cfif variables.contractAppPending eq 0>selected="true"</cfif>>No</option>
											</select>
										</td>
										<td class="normal-td3">&nbsp;</td>
									</tr>
									<tr bgcolor="##f7f7f7">
										<td colspan="2" class="head-bg lft-bg" valign="middle" align="center">BROKER</td>
										<td valign="middle" align="center">
											<select name="brokerStatus" id="brokerStatus" class="activeSelectbox">
												<option value="1" <cfif variables.brokerStatus eq 1>selected="true"</cfif>> Active</option>
												<option value="0" <cfif variables.brokerStatus eq 0>selected="true"</cfif>>InActive</option>
											</select>
										</td>
										<td valign="middle" align="center">
											<select name="BrokerAppPending" id="BrokerAppPending" class="activeSelectbox">
												<option value="1" <cfif variables.BrokerAppPending eq 1>selected="true"</cfif>>Yes</option>
												<option value="0" <cfif variables.BrokerAppPending eq 0>selected="true"</cfif>>No</option>
											</select>
										</td>
										<td class="normal-td3">&nbsp;</td>
									</tr>
								</tbody>
								<tfoot>
									<tr>
										<td width="5" align="left" valign="top"><img src="images/left-bot.gif" alt="" width="5" height="23" /></td>
										<td colspan="3" align="left" valign="middle" class="footer-bg"></td>
										<td width="5" align="right" valign="top"><img src="images/right-bot.gif" alt="" width="5" height="23" /></td>
									</tr>
								</tfoot>
							</table>
							<div class="clear"></div>
							<!--- Insurance Boxes 2 --->
							<table width="315" border="0" cellspacing="0" cellpadding="0" class="noh" bgcolor="" style="padding-bottom:25px; margin-left: 32px !important;display: none">
								<thead>
									<tr>
										<th width="5" align="left" valign="top"><img src="images/top-left.gif" alt="" width="5" height="23" /></th>
										<th align="center" valign="middle" class="head-bg">Ins. Type</th>
										<th align="center" valign="middle" class="head-bg">Ins. Required</th>
										<th align="center" valign="middle" class="head-bg">Ins. on File</th>
										<th align="center" valign="middle" class="head-bg2">Exp. Date</th>
										<th width="5" align="right" valign="top"><img src="images/top-right.gif" alt="" width="5" height="23" /></th>
									</tr>
								</thead>
								<tbody>
									<tr bgcolor="##f7f7f7" >
										<td class="head-bg lft-bg" colspan="2" valign="middle" align="center">BIPD</td>
										<td valign="middle" align="center">
											<select name="BIPDInsRequired" id="BIPDInsRequired" class="activeSelectbox" style="margin-left: 12px;">
												<option value="1" <cfif variables.BIPDInsRequired eq 1>selected="true"</cfif>>Yes</option>
												<option value="0" <cfif variables.BIPDInsRequired eq 0>selected="true"</cfif>>No</option>
											</select>
										</td>

										<td valign="middle" align="center">
											<select name="BIPDInsonFile" id="BIPDInsonFile" class="activeSelectbox">
												<option value="1" <cfif variables.BIPDInsonFile eq 1>selected="true"</cfif>>Yes</option>
												<option value="0" <cfif variables.BIPDInsonFile eq 0>selected="true"</cfif>>No</option>
											</select>
										</td>
										<td valign="middle" align="center">

											<input name="ExpirationDate" type="datefield" value="#Dateformat(variables.ExpirationDate,'mm/dd/yyyy')#" style="width:64px" onblur="checkDateFormatAll(this);"/>
										</td>

										<td class="normal-td3">&nbsp;</td>
									</tr>
								    <tr bgcolor="##FFFFFF">
										<td class="head-bg lft-bg" colspan="2" valign="middle" align="center">CARGO</td>
										<td valign="middle" align="center">
											<select name="cargoInsRequired" id="cargoInsRequired" class="activeSelectbox" style="margin-left: 12px;">
												<option value="1" <cfif variables.cargoInsRequired eq 1>selected="true"</cfif>>Yes</option>
												<option value="0" <cfif variables.cargoInsRequired eq 0>selected="true"</cfif>>No</option>
											</select>
										</td>
										<td valign="middle" align="center">
											<select name="cargoInsonFile" id="cargoInsonFile" class="activeSelectbox">
												<option value="1" <cfif variables.cargoInsonFile eq 1>selected="true"</cfif>>Yes</option>
												<option value="0" <cfif variables.cargoInsonFile eq 0>selected="true"</cfif>>No</option>
											</select>
										</td>
										<td valign="middle" align="center">
											<input name="CARGOExpirationDate" type="datefield" value="#Dateformat(variables.CARGOExpirationDate,'mm/dd/yyyy')#" style="width:64px" onblur="checkDateFormatAll(this);"/>'
										</td>
										<td class="normal-td3">&nbsp;</td>
								    </tr>
								</tbody>
								<tfoot>
									<tr>
										<td width="5" align="left" valign="top"><img src="images/left-bot.gif" alt="" width="5" height="23" /></td>
										<td colspan="4" align="left" valign="middle" class="footer-bg"></td>
										<td width="5" align="right" valign="top"><img src="images/right-bot.gif" alt="" width="5" height="23" /></td>
									</tr>
								</tfoot>
							</table>
							

							<div class="clear"></div>
							<div class="clear"></div>
						</fieldset>
					</div>
					<div class="clear"></div>

				<!---Begin : Insurance - Auto Liability (BIPD) --->
				<div class="form-con" style="width:315px;padding:0;<cfif request.qGetSystemSetupOptions.CarrierLNI EQ 2>display:none;</cfif>">
					<fieldset class="carrierFields">
					<div style="height: 36px;background-color: ##82bbef;margin-bottom: 5px;float: right;margin-right: 10px">
							<h2 style="color:white;font-weight:bold;padding-top: 10px;width:300px">Insurance - Auto Liability (BIPD)</h2>
						</div>
						<label style="width:190px;text-align:left;padding-left:10px;">Company</label>
						<label style="text-align:left;">Phone</label>
						<div class="clear"></div>
						<cfinput name="InsCompany" tabindex="26" type="text" value="#InsCompany#" style="width:190px;margin-left:10px;" maxlength="100"/>
						<cfinput name="InsComPhone" tabindex="27" type="text" value="#trim(InsComPhone)#" onchange="ParseUSNumber(this,"");" style="width:90px;" maxlength="50"/>
						<div class="clear"></div>
						<label style="width:190px;text-align:left;padding-left:10px;">Agent</label>
						<label style="text-align:left;">Agent Phone</label>
						<div class="clear"></div>
						<cfinput name="InsAgent" id="InsAgent" tabindex="28" type="text" value="#trim(InsAgent)#" style="width:190px;margin-left:10px;" maxlength="50"/>

						<cfinput name="InsAgentPhone"  id="InsAgentPhone" tabindex="29" type="text" value="#trim(InsAgentPhone)#" onchange="ParseUSNumber(this,"");" style="width:90px;" maxlength="50"/>
						<div class="clear"></div>


						<label style="width:190px;text-align:left;padding-left:10px;">Email</label>
						<div class="clear"></div>
						<cfinput name="InsEmail" id="InsEmail" tabindex="28" type="text" value="#trim(InsEmail)#" style="width:295px;margin-left:10px;" maxlength="50"/>
						<div class="clear"></div>


						<label style="margin-left: -36px;">Address</label>
						<div class="clear"></div>
						<textarea name="InsuranceCompanyAddress" id="InsuranceCompanyAddress" class="textBoxCarrierInsurance" placeholder="Company Address" rows="4" maxlength="200" style="width:306px !important">#InsuranceCompanyAddress#</textarea>
						<div class="clear"></div>
						<label style="width:50px">Policy ##</label>
						<cfinput name="InsPolicyNo" tabindex="30" type="text" value="#InsPolicyNo#" style="width:65px" maxlength="50"/>
						<label style="width:82px">Expiration Date</label>
						<cfif isdate(InsExpDate)>
							<input name="InsExpDate" tabindex="31" type="datefield" value="#Dateformat(InsExpDate,'mm/dd/yyyy')#" style="width:64px" onchange="checkDateFormatAll(this);" class=" datefield"/>
						<cfelse>
							<input name="InsExpDate" tabindex="31" type="datefield" value="" style="width:64px" onchange="checkDateFormatAll(this);" class=" datefield"/>
						</cfif>

						<div class="clear"></div>
						<label style="width:50px">Limit</label>
						<cfif  InsLimit NEQ "" AND  LSIsCurrency(InsLimit)>
							<cfset InsLimit  = LSParseCurrency(InsLimit)>
						<cfelse>
							<cfset InsLimit  = 0>
						</cfif>
						<input type="text" name="InsLimit" tabindex="32" value="#DollarFormat(InsLimit)#"  style="width:65px;text-align: right;" maxlength="20">
						<label style="width: 90px; font-size: 10px">Household Goods:</label>
						<select name="householdGoods" id="householdGoods" class="activeSelectbox">
							<option value="1" <cfif variables.householdGoods eq 1>selected="true"</cfif>>Yes</option>
							<option value="0" <cfif variables.householdGoods eq 0>selected="true"</cfif>>No</option>
						</select>
						<div class="clear"></div>
					</fieldset>
				</div>
				<!---End : Insurance - Auto Liability (BIPD) --->

				<!---Begin : Insurance - Cargo --->
				<div class="form-con" style="width:315px;padding:0;margin-left: 10px;<cfif request.qGetSystemSetupOptions.CarrierLNI EQ 2>display:none;</cfif>">
					<fieldset class="carrierFields">
					<div style="height: 36px;background-color: ##82bbef;margin-bottom: 5px;width:310px">
							<h2 style="color:white;font-weight:bold;padding-top: 10px;">Insurance - Cargo</h2>
						</div>
						<label style="width:190px;text-align:left;padding-left:10px;">Company</label>
						<label style="text-align:left;">Phone</label>
						<div class="clear"></div>
						<cfinput name="InsCompanyCargo" tabindex="26" type="text" value="#InsCompanyCargo#" style="width:190px;margin-left:10px;" maxlength="100"/>
						<cfinput name="InsComPhoneCargo" tabindex="27" type="text" value="#trim(InsComPhoneCargo)#" onchange="ParseUSNumber(this,"");" style="width:90px;" maxlength="50"/>
						<div class="clear"></div>
						<label style="width:190px;text-align:left;padding-left:10px;">Agent</label>
						<label style="text-align:left;">Agent Phone</label>
						<div class="clear"></div>
						<cfinput name="InsAgentCargo" id="InsAgentCargo" tabindex="28" type="text" value="#trim(InsAgentCargo)#" style="width:190px;margin-left:10px;" maxlength="50"/>

						<cfinput name="InsAgentPhoneCargo"  id="InsAgentPhoneCargo" tabindex="29" type="text" value="#trim(InsAgentPhoneCargo)#" onchange="ParseUSNumber(this,"");" style="width:90px;" maxlength="50"/>
						<div class="clear"></div>

						<label style="width:190px;text-align:left;padding-left:10px;">Email</label>
						<div class="clear"></div>
						<cfinput name="InsEmailCargo" id="InsEmailCargo" tabindex="28" type="text" value="#trim(InsEmailCargo)#" style="width:295px;margin-left:10px;" maxlength="50"/>
						<div class="clear"></div>

						<label style="margin-left: -36px;">Address</label>
						<div class="clear"></div>
						<textarea name="InsuranceCompanyAddressCargo" id="InsuranceCompanyAddressCargo" class="textBoxCarrierInsurance" placeholder="Company Address" rows="4" maxlength="200" style="width:306px !important">#InsuranceCompanyAddressCargo#</textarea>
						<div class="clear"></div>
						<label style="width:50px">Policy ##</label>
						<cfinput name="InsPolicyNoCargo" tabindex="30" type="text" value="#InsPolicyNoCargo#" style="width:65px" maxlength="50"/>
						<label style="width:82px">Expiration Date</label>
						<cfif isdate(InsExpDateCargo)>
							<input name="InsExpDateCargo" tabindex="31" type="datefield" value="#Dateformat(InsExpDateCargo,'mm/dd/yyyy')#" style="width:64px" onchange="checkDateFormatAll(this);" class=" datefield"/>
						<cfelse>
							<input name="InsExpDateCargo" tabindex="31" type="datefield" value="" style="width:64px" onchange="checkDateFormatAll(this);" class=" datefield"/>
						</cfif>

						<div class="clear"></div>
						<label style="width:50px">Limit</label>
						<cfif  InsLimitCargo NEQ "" AND  LSIsCurrency(InsLimitCargo)>
							<cfset InsLimitCargo  = LSParseCurrency(InsLimitCargo)>
						<cfelse>
							<cfset InsLimitCargo  = 0>
						</cfif>
						<input type="text" name="InsLimitCargo" tabindex="32" value="#DollarFormat(InsLimitCargo)#"  style="width:65px;text-align: right;" maxlength="20">
						<label style="width: 90px; font-size: 10px">Household Goods:</label>
						<select name="householdGoodsCargo" id="householdGoodsCargo" class="activeSelectbox">
							<option value="1" <cfif variables.householdGoodsCargo eq 1>selected="true"</cfif>>Yes</option>
							<option value="0" <cfif variables.householdGoodsCargo eq 0>selected="true"</cfif>>No</option>
						</select>
						<div class="clear"></div>
					</fieldset>
				</div>
				<!---End : Insurance - Cargo --->
				<!---Begin : Insurance - General Liability --->
				<div class="form-con" style="width:315px;padding:0;margin-left: 10px;<cfif request.qGetSystemSetupOptions.CarrierLNI EQ 2>display:none;</cfif>">
					<fieldset class="carrierFields">
					<div style="height: 36px;background-color: ##82bbef;margin-bottom: 5px;">
							<h2 style="color:white;font-weight:bold;padding-top: 10px;">Insurance - General Liability</h2>
						</div>
						<label style="width:190px;text-align:left;padding-left:10px;">Company</label>
						<label style="text-align:left;">Phone</label>
						<div class="clear"></div>
						<cfinput name="InsCompanyGeneral" tabindex="26" type="text" value="#InsCompanyGeneral#" style="width:190px;margin-left:10px;" maxlength="100"/>
						<cfinput name="InsComPhoneGeneral" tabindex="27" type="text" value="#trim(InsComPhoneGeneral)#" onchange="ParseUSNumber(this,"");" style="width:90px;" maxlength="50"/>
						<div class="clear"></div>
						<label style="width:190px;text-align:left;padding-left:10px;">Agent</label>
						<label style="text-align:left;">Agent Phone</label>
						<div class="clear"></div>
						<cfinput name="InsAgentGeneral" id="InsAgentGeneral" tabindex="28" type="text" value="#trim(InsAgentGeneral)#" style="width:190px;margin-left:10px;" maxlength="50"/>

						<cfinput name="InsAgentPhoneGeneral"  id="InsAgentPhoneGeneral" tabindex="29" type="text" value="#trim(InsAgentPhoneGeneral)#" onchange="ParseUSNumber(this,"");" style="width:90px;" maxlength="50"/>
						<div class="clear"></div>
						<label style="width:190px;text-align:left;padding-left:10px;">Email</label>
						<div class="clear"></div>
						<cfinput name="InsEmailGeneral" id="InsEmailGeneral" tabindex="28" type="text" value="#trim(InsEmailGeneral)#" style="width:295px;margin-left:10px;" maxlength="50"/>
						<div class="clear"></div>
						<label style="margin-left: -36px;">Address</label>
						<div class="clear"></div>
						<textarea name="InsuranceCompanyAddressGeneral" id="InsuranceCompanyAddressGeneral" class="textBoxCarrierInsurance" placeholder="Company Address" rows="4" maxlength="200" style="width:306px !important">#InsuranceCompanyAddressGeneral#</textarea>
						<div class="clear"></div>
						<label style="width:50px">Policy ##</label>
						<cfinput name="InsPolicyNoGeneral" tabindex="30" type="text" value="#InsPolicyNoGeneral#" style="width:65px" maxlength="50"/>
						<label style="width:82px">Expiration Date</label>
						<cfif isdate(InsExpDateGeneral)>
							<input name="InsExpDateGeneral" tabindex="31" type="datefield" value="#Dateformat(InsExpDateGeneral,'mm/dd/yyyy')#" style="width:64px" onchange="checkDateFormatAll(this);" class=" datefield"/>
						<cfelse>
							<input name="InsExpDateGeneral" tabindex="31" type="datefield" value="" style="width:64px" onchange="checkDateFormatAll(this);" class=" datefield"/>
						</cfif>

						<div class="clear"></div>
						<label style="width:50px">Limit</label>
						<cfif  InsLimitGeneral NEQ "" AND  LSIsCurrency(InsLimitGeneral)>
							<cfset InsLimitGeneral  = LSParseCurrency(InsLimitGeneral)>
						<cfelse>
							<cfset InsLimitGeneral  = 0>
						</cfif>
						<input type="text" name="InsLimitGeneral" tabindex="32" value="#DollarFormat(InsLimitGeneral)#"  style="width:65px;text-align: right;" maxlength="20">
						<label style="width: 90px; font-size: 10px">Household Goods:</label>
						<select name="householdGoodsGeneral" id="householdGoodsGeneral" class="activeSelectbox">
							<option value="1" <cfif variables.householdGoodsGeneral eq 1>selected="true"</cfif>>Yes</option>
							<option value="0" <cfif variables.householdGoodsGeneral eq 0>selected="true"</cfif>>No</option>
						</select>
						<div class="clear"></div>
					</fieldset>
				</div>
				<!---End : Insurance - General Liability --->
				<div class="search-rt"></div>
				<div class="clear"></div>
				<cfif isDefined("url.carrierid")>
					<fieldset class="carrierFields">
						<div style="padding-left:120px;float: right;margin-right: 10px">
							<cfif carrierdisabledStatus neq true>
							<cfinput name="Save" type="submit" class="normal-bttn" value="Save"  onfocus="checkUnload();" style="width:44px;" onclick="return validateCarrier(frmCarrier,'#application.dsn#','#ValidMCNO#','driver');saveExit(0);"/>
							<cfinput name="Return" type="button" class="normal-bttn" onclick="javascript:history.back();" value="Back" style="width:62px;" />
							<cfelse>
								<cfif structkeyexists(session,"rightslist") and len(trim(url.carrierid)) gt 0 and variables.carrierdisabledStatus and ListContains(session.rightsList,'UnlockCarrier',',')>
										<input id="Unlock" name="unlock" type="button" class="normal-bttn" onClick="removeCarrierEditAccess('#url.carrierid#');" value="Unlock" style="width:100px !important;">
								</cfif>
							</cfif>
						</div>
					</fieldset>
					<div class="gap"></div>
				</cfif>
				<div class="carrier-mid">
				<table id="tblrow1" width="100%" class="noh" border="0" cellspacing="0" cellpadding="0">
				  <thead>
				  <tr>
					<th width="5" align="left" valign="top"><img src="images/top-left.gif" alt="" width="5" height="23" /></th>
					<th align="center" valign="middle" class="head-bg">Del</th>
					<th align="center" valign="middle" class="head-bg">Office/Name</th>
					<th align="center" valign="middle" class="head-bg">Manager</th>

					<th align="center" valign="middle" class="head-bg">Phone</th>
					<th  align="center" valign="middle" class="head-bg">Fax</th>
					<th align="center" valign="middle" class="head-bg2">Email</th>
					<th width="5" align="right" valign="top"><img src="images/top-right.gif" alt="" width="5" height="23" /></th>
				  </tr>
				  </thead>
				  <tbody>
	             <cfif isdefined('url.carrierId') and len(url.carrierID) >
	             	<cfinvoke component="#variables.objCarrierGateway#" method="getCarrierOffice" carrierid="#url.carrierid#" returnvariable="request.qCarrierOffice" />
	                 <cfloop query="request.qCarrierOffice">
	                   <cfinput type="hidden" name="CarrierOfficeID#request.qCarrierOffice.currentRow#" value="#request.qCarrierOffice.CarrierOfficeID#">
	                     <tr <cfif #request.qCarrierOffice.currentRow# mod 2 eq 0> bgcolor="##FFFFFF"<cfelse>bgcolor="##f7f7f7"</cfif>>
	           				<td height="20" class="lft-bg">&nbsp;</td>
	           				<td class="lft-bg2" valign="middle" align="center"><input name="delchk#request.qCarrierOffice.currentRow#" class="check" type="checkbox" value="" /></td>
	           				<td class="normaltd" valign="middle" align="left"><input name="office_name#request.qCarrierOffice.currentRow#" class="t-textbox" type="text"  value="#request.qCarrierOffice.location#" maxlength="100" /></td>
	           				<td class="normaltd" valign="middle" align="left"><input name="office_manager#request.qCarrierOffice.currentRow#" class="td-textbox" type="text" value="#request.qCarrierOffice.Manager#" maxlength="50" /></td>
	           				<td class="normaltd" valign="middle" align="left"><input name="office_phone#request.qCarrierOffice.currentRow#" class="td-textbox" type="text"  <cfif request.qCarrierOffice.PhoneNo NEQ "" AND NOT listContains(request.qCarrierOffice.PhoneNo, "-")>
					value="#left(request.qCarrierOffice.PhoneNo,3)#-#mid(request.qCarrierOffice.PhoneNo,4,3)#-#right(request.qCarrierOffice.PhoneNo,4)#"<cfelse>value="#request.qCarrierOffice.PhoneNo#"
			</cfif>  onchange="ParseUSNumber(this,'Office Phone #request.qCarrierOffice.currentRow#')" maxlength="50"/></td>
	           				<td class="normaltd" valign="middle" align="left"><input name="office_fax#request.qCarrierOffice.currentRow#" class="td-textbox" type="text"  <cfif request.qCarrierOffice.Fax NEQ "" AND NOT listContains(request.qCarrierOffice.Fax, "-")>
					value="#left(request.qCarrierOffice.Fax,3)#-#mid(request.qCarrierOffice.Fax,4,3)#-#right(request.qCarrierOffice.Fax,4)#"<cfelse>value="#request.qCarrierOffice.Fax#"
			</cfif>   onchange="ParseUSNumber(this,'Office Fax #request.qCarrierOffice.currentRow#')" maxlength="20"/></td>
	           				<td class="normaltd2" valign="middle" align="left"><input name="office_Email#request.qCarrierOffice.currentRow#" class="td-textbox" type="text" value="#request.qCarrierOffice.EmailID#"  onchange="validateEmail(this,'Office Email #request.qCarrierOffice.currentRow#')"  maxlength="100"/></td>
	           				<td class="normal-td3">&nbsp;</td>
	           			  </tr>
		                 </cfloop>
		                 <cfif request.qCarrierOffice.recordcount lt 5>
		                 <cfset toLoop = 5 - #request.qCarrierOffice.recordcount#>
		                 <cfset cnt=#request.qCarrierOffice.recordcount#+1>
		                 <cfloop index="in" from="#cnt#" to="5">
		                     <cfinput type="hidden" name="CarrierOfficeID#in#" value="0">
				  			  <tr <cfif #in# mod 2 eq 0> bgcolor="##FFFFFF"<cfelse>bgcolor="##f7f7f7"</cfif>>
				  				<td height="20" class="lft-bg">&nbsp;</td>
				  				<td class="lft-bg2" valign="middle" align="center"><input name="delchk#in#" class="check" type="checkbox" value="" /></td>
				  				<td class="normaltd" valign="middle" align="left"><input name="office_name#in#" class="t-textbox" type="text"  value=""/></td>
				  				<td class="normaltd" valign="middle" align="left"><input name="office_manager#in#" class="td-textbox" type="text" value="" /></td>
				  				<td class="normaltd" valign="middle" align="left"><input name="office_phone#in#" class="td-textbox" type="text" value="" /></td>
				  				<td class="normaltd" valign="middle" align="left"><input name="office_fax#in#" class="td-textbox" type="text" value="" /></td>
				  				<td class="normaltd2" valign="middle" align="left"><input name="office_Email#in#" class="td-textbox" type="text" value=""/></td>
				  				<td class="normal-td3">&nbsp;</td>
				  			  </tr>
		                </cfloop>
              			</cfif>
            			<cfelse>
		             <cfloop index="in" from="1" to="5">
					  <tr <cfif #in# mod 2 eq 0> bgcolor="##FFFFFF"<cfelse>bgcolor="##f7f7f7"</cfif>>
						<td height="20" class="lft-bg">&nbsp;</td>
						<td class="lft-bg2" valign="middle" align="center"><input name="delchk#in#" class="check" type="checkbox" value="" /></td>
						<td class="normaltd" valign="middle" align="left"><input name="office_name#in#" class="t-textbox" type="text"  value=""/></td>
						<td class="normaltd" valign="middle" align="left"><input name="office_manager#in#" class="td-textbox" type="text" value="" /></td>
						<td class="normaltd" valign="middle" align="left"><input name="office_phone#in#" class="td-textbox" type="text" value="" /></td>
						<td class="normaltd" valign="middle" align="left"><input name="office_fax#in#" class="td-textbox" type="text" value="" /></td>
						<td class="normaltd2" valign="middle" align="left"><input name="office_Email#in#" class="td-textbox" type="text" value=""/></td>
						<td class="normal-td3">&nbsp;</td>
					  </tr>
		              </cfloop>
                      </cfif>
					  </tbody>
		               <tfoot>
					  <tr>
					<td width="5" align="left" valign="top"><img src="images/left-bot.gif" alt="" width="5" height="23" /></td>
					<td colspan="6" align="left" valign="middle" class="footer-bg"></td>
					<td width="5" align="right" valign="top"><img src="images/right-bot.gif" alt="" width="5" height="23" /></td>
				  </tr>
				  </tfoot>
				</table>
		<div class="clear"></div>
		</div>
		<div class="carrier-links">
		<cfif len(pv_usdot_no) gt 1>
		   <ul>
		      <li><a href="http://li-public.fmcsa.dot.gov/LIVIEW/pkg_carrquery.prc_activeinsurance?pv_apcant_id=#pv_apcant_id#&pv_legal_name=#webLegger#&pv_pref_docket=MC#MCNumber#&pv_usdot_no=#pv_usdot_no#&pv_vpath=LIVIEW" target="blank">Active/Pending Insurance</a></li>
			  <li>|</li>
			  <li><a href="http://li-public.fmcsa.dot.gov/LIVIEW/pkg_carrquery.prc_rejectinsurance?pv_apcant_id=#pv_apcant_id#&pv_legal_name=#webLegger#&pv_pref_docket=MC#MCNumber#&pv_usdot_no=#pv_usdot_no#&pv_vpath=LIVIEW" target="blank">Rejected Insurance</a></li>
			  <li>|</li>
			  <li><a href="http://li-public.fmcsa.dot.gov/LIVIEW/pkg_carrquery.prc_insurancehistory?pv_apcant_id=#pv_apcant_id#&pv_legal_name=#webLegger#&pv_pref_docket=MC#MCNumber#&pv_usdot_no=#pv_usdot_no#&pv_vpath=LIVIEW" target="blank">Insurance History</a></li>
			  <li>|</li>
			  <li><a href="http://li-public.fmcsa.dot.gov/LIVIEW/pkg_carrquery.prc_authorityhistory?pv_apcant_id=#pv_apcant_id#&pv_legal_name=#webLegger#&pv_pref_docket=MC#MCNumber#&pv_usdot_no=#pv_usdot_no#&pv_vpath=LIVIEW" target="blank">Authority History</a></li>
			  <li>|</li>
			  <li><a href="http://li-public.fmcsa.dot.gov/LIVIEW/pkg_carrquery.prc_pendapplication?pv_apcant_id=#pv_apcant_id#&pv_legal_name=#webLegger#&pv_pref_docket=MC#MCNumber#&pv_usdot_no=#pv_usdot_no#&pv_vpath=LIVIEW" target="blank">Pending Application</a></li>
			  <li>|</li>
              <li><a href="http://li-public.fmcsa.dot.gov/LIVIEW/pkg_carrquery.prc_revocation?pv_apcant_id=#pv_apcant_id#&amp;pv_legal_name=#webLegger#&amp;pv_pref_docket=MC#MCNumber#&amp;pv_usdot_no=#pv_usdot_no#&amp;pv_vpath=LIVIEW" target="blank">Revocation</a></li>
              <li>|</li>
              <li><a href="http://safersys.org/" target="blank">SAFER System</a></li>
		   </ul>
</cfif>
			 <div class="clear"></div>
		</div>
        <div class="clear"></div>
		<div class="white-con-area" style="height: 36px;background-color: ##82bbef;text-align:center;width:999px">
			<h2 style="color:white;font-weight:bold;">Carrier Commodity Pricing</h2>
		</div>
		<div class="carrier-mid" style="background-color: white;">
			<br/>
			<div><input type="button" onclick="addNewRow()" value="Add New Row"></div>
			<br/>
			<div class="commodityWrap">
				<table id="tblrow2"  class="noh" border="0" cellspacing="0" cellpadding="0" style="width:100%">
					<thead>
						<tr>
							<th align="left" width="5" valign="top"><img src="images/top-left.gif" alt=""  height="23" /></th>
							<th align="center" valign="middle" class="head-bg" style="text-align:center;">Commodity</th>
							<th align="left" valign="middle" class="head-bg" style="text-align:center;">Carrier Rate</th>
							<th align="left" valign="middle" class="head-bg" style="text-align:center;">Carrier % of Customer Total</th>
							<th align="left" valign="middle" class="head-bg" style="text-align:center;">&nbsp;</th>
							<th valign="top" width="5" align="right" style="left: -1px;position: relative;"><img src="images/top-right.gif" alt="" width="5" height="23"></th>
						</tr>
					</thead>
					<tbody>
						<cfset variables.leftIndex=5>
						<cfif IsDefined("request.qGetCommodityById") and request.qGetCommodityById.recordcount >
							<cfloop query="#request.qGetCommodityById#">
								<tr id="trcomm_#request.qGetCommodityById.currentrow#">
									<td height="20"  width="5"  class="lft-bg">&nbsp;</td>
									<td class="normaltd" valign="middle" align="left" style="width:325px;position:relative;top:-#variables.leftIndex#px;padding:8px 0px;">
										<select name="sel_commodityType_#request.qGetCommodityById.currentrow#" id="type" class="sel_commodityType" style="width:240px;height:26px;">
										  <option value=""></option>
										  <cfloop query="request.qUnits">
											<option value="#request.qUnits.unitID#" <cfif request.qGetCommodityById.COMMODITYID eq request.qUnits.unitID >selected="true"</cfif> >#request.qUnits.unitName#<cfif trim(request.qUnits.unitCode) neq ''>(#request.qUnits.unitCode#)</cfif></option>
										  </cfloop>
										</select>
										<input type="hidden" value="1" name="numberOfCommodity">
										<input type="hidden" value="#request.qGetCommodityById.ID#" id="CarrierCommID_#request.qGetCommodityById.currentrow#" class="CarrierCommID">
									</td>

									<td class="normaltd" valign="middle" align="left"  style="width:142px;position:relative;top:-5px;"><input type="text" name="txt_carrRateComm_#request.qGetCommodityById.currentrow#" class="txt_carrRateComm q-textbox" value="$#request.qGetCommodityById.carrrate#"></td>
									<td class="normaltd" valign="middle" align="left"  style="width:250px;position:relative;top:-5px;"><input type="text" name="txt_custRateComm_#request.qGetCommodityById.currentrow#" id="txt_custRateComm_#request.qGetCommodityById.currentrow#" class="txt_custRateComm q-textbox" value="#request.qGetCommodityById.CarrRateOfCustTotal#%" onChange="ConfirmMessage('#request.qGetCommodityById.currentrow#',0)"></td>

									<td class="normaltd" colspan="2" valign="middle" align="left" style="position:relative;top:-5px;">
										<img class="delRow" id="delRow_#request.qGetCommodityById.currentrow#" onclick="delRow(this)" src="images/delete-icon.gif" style="width:10px;margin-left: 5px;cursor: pointer;">
									</td>
								</tr><cfset variables.leftIndex=variables.leftIndex+2>
							</cfloop>

						<cfelse>
							<tr id="trcomm_1">
									<td height="20"  width="5"  class="lft-bg">&nbsp;</td>
									<td class="normaltd" valign="middle" align="left" style="width:325px;position:relative;top:-#variables.leftIndex#px;padding:8px 0px;">
										<select name="sel_commodityType_1" id="type" class="sel_commodityType" style="width:240px;height:26px;">
										  <option value=""></option>
										  <cfloop query="request.qUnits">
											<option value="#request.qUnits.unitID#"  >#request.qUnits.unitName#<cfif trim(request.qUnits.unitCode) neq ''>(#request.qUnits.unitCode#)</cfif></option>
										  </cfloop>
										</select>
										<input type="hidden" value="1" name="numberOfCommodity">
										<input type="hidden" value="" id="CarrierCommID_1" class="CarrierCommID">
									</td>

									<td class="normaltd" valign="middle" align="left"  style="width:142px;position:relative;top:-5px;"><input type="text" name="txt_carrRateComm_1" class="txt_carrRateComm q-textbox" value="0"></td>

									<td class="normaltd"  valign="middle" align="left"  style="width:250px;position:relative;top:-5px;"><input type="text" name="txt_custRateComm_1" class="txt_custRateComm q-textbox" value="0"></td>

									<td class="normaltd" colspan="2" valign="middle" align="left" style="position:relative;top:-5px;">
										<img class="delRow" id="delRow_1" onclick="delRow(this)" src="images/delete-icon.gif" style="width:10px;margin-left: 5px;cursor: pointer;">
									</td>
								</tr><cfset variables.leftIndex=variables.leftIndex+2>
						</cfif>
					</tbody>
					<tfoot>
						<tr>
							<td width="5" align="left" valign="top" style="position:relative;top:-6px;"><img src="images/left-bot.gif" alt="" width="5" height="23" /></td>
							<td colspan="2" align="left" valign="middle" style="position:relative;top:-6px;" class="footer-bg"></td>
							<td colspan="2" align="left" valign="middle" style="position:relative;top:-6px;" class="footer-bg"></td>
							<td width="5" style="position:relative;top:-6px;" align="right" valign="top"><img src="images/right-bot.gif" alt="" width="5" height="23" /></td>
						</tr>
					</tfoot>
				</table>
			</div>
		</div>
		<div class="clear"></div>
		<div class="white-con-area" style="height: 36px;background-color: ##82bbef;text-align:center;width:999px">
			<h2 style="color:white;font-weight:bold;">Carrier Equipments</h2>
		</div>
		<div class="carrier-mid" style="background-color: white;">
			<br/>
			<div><input type="button" onclick="AddNewEquipmentRow()" value="Add New Row"></div>
			<br/>
			<div>
				<table id="tblrow3"  class="noh" border="0" cellspacing="0" cellpadding="0" width="100%">
					<thead>
						<tr>
							<th align="center" width="30%" valign="middle" class="head-bg" style="border-left: 1px solid ##5d8cc9;border-top-left-radius: 5px;cursor: pointer;" onclick="loadCarrierEquipments('EquipmentName');">Truck</th>
							<th align="center" width="30%" valign="middle" class="head-bg" style="text-align:center;">Trailer</th>
							<th align="center" width="30%" valign="middle" class="head-bg" style="text-align:center;">Driver</th>
							<th align="center" width="5%" valign="middle" class="head-bg" style="text-align:center;">Default</th>
							<th align="center" width="5%" valign="middle" class="head-bg" style="text-align:center;border-top-right-radius: 5px;">&nbsp;</th>
						</tr>
					</thead>
					<input id="sortby" name="sortby" value="ModifiedDateTime" type="hidden">
					<input id="sortorder" name="sortOrder" value="ASC" type="hidden">
					<input id="totalequipcount" name="totalequipcount" value="0" type="hidden">
					<tbody id="carrierEquipments">
					</tbody>
					<tfoot>
						<tr>
							<td colspan="5" align="left" valign="middle" class="footer-bg" style="border-left: 1px solid ##5d8cc9;border-right: 1px solid ##5d8cc9;border-bottom-right-radius: 5px;border-bottom-left-radius: 5px;"></td>
						</tr>
					</tfoot>
				</table>
			</div>
		</div>
		<div class="clear"></div>

		<div class="form-con" style="height:98px;">
				<fieldset class="carrierFields">
					<label style="width:38px">Notes</label>
					<cftextarea rows="7" style="width: 80%; height: 83px;" name="Notes">#notes#</cftextarea>
					<div class="clear"></div>

				</fieldset>
		<div class="clear"></div>
		</div>

		<div class="form-con" style="height:98px;">
				<fieldset class="carrierFields">
					<label style="width:98px">Equipment Notes</label>
					<cftextarea rows="5" style="width: 70%; height: 79px;" name="EquipmentNotes" id="EquipmentNotes" onkeypress="checkmaxlength()">#EquipmentNotes#</cftextarea>
                     <div class="clear"></div>
					<label>&nbsp;</label>
					<div class="clear"></div>
					<cfinput type="hidden" value="" name="SaveContinue">
					<cfinput type="hidden" value="#session.urltoken#" name="stoken" id="stoken">
				</fieldset>

		<div class="clear"></div>
		</div>
		<div class="clear"></div>
		<div>
			<cfif isDefined("url.carrierid") and len(url.carrierid) gt 1>
	          <p id="footer" style="padding-left:10px;font-family:Verdana, Geneva, sans-serif; font-style:italic bold; text-transform:uppercase;">
			  Last Updated<cfif isDefined("request.qCarrier")>&nbsp;On&nbsp; #dateTimeFormat(request.qCarrier.LastModifiedDateTime,"mm/dd/yyyy hh:mm tt")#&nbsp;By&nbsp;#request.qCarrier.LastModifiedBy#</cfif>
			  <span class="pull-right" style="padding-right:2%">Created <cfif isDefined("request.qCarrier")>&nbsp;On&nbsp; #dateTimeFormat(request.qCarrier.CreatedDateTime,"mm/dd/yyyy hh:mm tt")#&nbsp;By&nbsp;#request.qCarrier.CreatedBy#</cfif></span>
			  </p>
	       </cfif>
       </div>
	</div>
	</cfform>
		<div class="white-bot"></div>
</div>
<br/><br/><br/>
<script type="text/javascript">
		function validateRatePerMile(){
			var RatePerMile = $('##RatePerMile').val();

	 		RatePerMile = RatePerMile.replace("$","");
			RatePerMile = RatePerMile.replace(/,/g,"");

			if(isNaN(RatePerMile) || !RatePerMile.length){
				alert("Invalid Rate Per Mile.")
				$('##RatePerMile').val('$0.00');
				$('##RatePerMile').focus();
				return false;
			}
		}
		
		$(document).ready(function(){


			 <cfif isdefined("url.carrierid") and len(trim(url.carrierid)) gt 1 and structKeyExists(session, "currentusertype") and session.currentusertype eq 'Data Entry'>
            	$('##hViewOnly').show();
            	$('##frmCarrier input,##frmCarrier textarea,##frmCarrier select').css('opacity','0.7');
            	$('##frmCarrier input,##frmCarrier textarea').attr('readonly','readonly');
            	$('##frmCarrier select').css('pointer-events','none');
            	$('.delbutton').hide();
            	$('##customerTabs').css('pointer-events','none').css('opacity','0.6');
            	$('##frmCarrier input[type="submit"]').hide();
            	$('##frmCarrier input[type="button"]').hide();
            	$('.delbutton,.delRow,##attachFile,.overlay').hide();
            </cfif>

			$("##frmCarrier").submit(function(){
				$('##isSaveEvent').val('true');
			});
			
			 $('##mailDocLink').click(function(){
				if($(this).attr('data-allowmail') == 'false')
				alert('You must setup your email address in your profile before you can email documents.');
				else
					mailDocOnClick('#session.URLToken#','carrier'<cfif isDefined("url.carrierid") and len(url.carrierid) gt 1>,'#url.carrierid#'</cfif>);
			 });

			 <cfif isDefined("duplicateVendorId") AND duplicateVendorId EQ 1>
			 	alert("Vendor code already in use, please enter a valid vendor code.");
			</cfif>

			//Cell phone number validation and prefered contact method selection
			var phRegEx = /^(?:(?:\+?1\s*(?:[.-]\s*)?)?(?:\(\s*([2-9]1[02-9]|[2-9][02-8]1|[2-9][02-8][02-9])\s*\)|([2-9]1[02-9]|[2-9][02-8]1|[2-9][02-8][02-9]))\s*(?:[.-]\s*)?)?([2-9]1[02-9]|[2-9][02-9]1|[2-9][02-9]{2})\s*(?:[.-]\s*)?([0-9]{4})(?:\s*(?:##|x\.?|ext\.?|extension)\s*(\d+))?$/;

			$('##CellPhone').blur(function(){
			  if (!$(this).val().match(phRegEx)) {
			  	$('##PreConMethod').val('1');
			    $("##PreConMethod option:not(:selected)").attr('disabled', true);
			  }else{
			    $("##PreConMethod option:not(:selected)").removeAttr('disabled');
			  }
			});


		    if(navigator.userAgent.indexOf("Firefox") != -1 ) 
			   {
				$("input[type=password]").each( function(){
					
					$(this).attr('readonly',true);
					
					$(this).bind("focus",function() {
						$(this).attr('readonly',false);
					});
					
					$(this).bind("blur",function() {
						$(this).attr('readonly',true);
					});
				}); 
			   } 
			/* Preventing Autofill from Chrome and Firefox ends*/

			$( "[type='datefield']" ).datepicker({
			  dateFormat: "mm/dd/yy",
			  showOn: "button",
			  buttonImage: "images/DateChooser.png",
			  buttonImageOnly: true,
			  
			});
            $( "[type='datefield']" ).datepicker({
                showButtonPanel: true
              });

            $( "[type='datefield']" ).datepicker( "option", "showButtonPanel", true );
               
                var old_goToToday = $.datepicker._gotoToday
                $.datepicker._gotoToday = function(id) {
                 old_goToToday.call(this,id)
                 this._selectDate(id)
                }

			$('##inviteCarrier').click(function(){
				var DOTnum = $('##DOTNumber').val();
				$('##MyCarrierPackets').val(1)
			    window.open('https://mycarrierpackets.com/RegisteredCustomer/SendCarrierPacket?dotNumber='+DOTnum, '_blank');
			    $('##frmCarrier').submit();
			})

			$('.alphanumeric').bind('keypress', function(e)
			{
			    if ((e.which < 65 || e.which > 122) && (e.which < 48 || e.which > 57))
			    {
			        e.preventDefault();
			    }
			});

			$("##CarrierName").keyup(function(){
			  var key = $(this).val().replace(/\s+/g, '');
			  if(key.length <=10){
			  	$("##venderId").val(key);
			  }
			});

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
					$('##RemitEmail').val($(this).find(':selected').attr('data-RemitEmail'));
					$('##FF').val($(this).find(':selected').attr('data-FF'));
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
					$('##RemitEmail').val('');
					$('##FF').val('0.00');
				}
			});

			loadCarrierEquipments('ModifiedDateTime');

		});

		function loadCarrierEquipments(sortby){
			if($('##sortby').val()==sortby){
                if($('##sortorder').val()=='ASC'){
                    var sortorder = 'DESC';
                }
                else{
                    var sortorder = 'ASC';
                }
            }
            else{
                var sortorder = 'ASC';
            }
            $('##sortorder').val(sortorder);
            $('##sortby').val(sortby);
			$.ajax({
                type    : 'GET',
                url     : "../gateways/carriergateway.cfc?method=getCarrierEquipments",
                data    : {carrierid : '#editid#', dsn:"#application.dsn#", sortby : sortby, sortorder:sortorder,companyid:'#session.CompanyID#'},
                success :function(response){
                	result = JSON.parse(response);
                    $('##carrierEquipments').html(result.data);
                    $('##totalequipcount').val(result.recordcount);
                    <cfif isdefined("url.carrierid") and len(trim(url.carrierid)) gt 1 and structKeyExists(session, "currentusertype") and session.currentusertype eq 'Data Entry'>
						$('##frmCarrier input,##frmCarrier textarea,##frmCarrier select').css('opacity','0.7');
	            		$('##frmCarrier input,##frmCarrier textarea').attr('readonly','readonly');
	            		$('##frmCarrier select').css('pointer-events','none');
	            		$('##delRow').hide();
            		</cfif>
		            createSelect2();
                },
                beforeSend:function() {
                    $('##carrierEquipments').html('<tr><td colspan="3" align="center" style="border-left: 1px solid ##5d8cc9;border-right: 1px solid ##5d8cc9;"><img src="images/loadDelLoader.gif" style="margin-top: 25px;"><br>Please wait...</td></tr>');
                },
            });
		}
		
		function AddNewEquipmentRow(){
			var count = $('##totalequipcount').val();
    		$('##EquipmentID_1').select2('destroy');
    		$('##relEquipmentID_1').select2('destroy');
    		$('##DriverContactID_1').select2('destroy');
            var original = document.getElementById('equipmentrow_1');
            var clone = original.cloneNode(true);
            count = ++count;
 	
            $(clone).attr("id","equipmentrow_"+count);
            
            $(clone).find("##CarrierEquipmentID_1").val("");
            $(clone).find("##EquipmentID_1").val("");
            $(clone).find("##relEquipmentID_1").val("");
            $(clone).find("##DriverContactID_1").val("");
            $(clone).find("##IsDefault_1").removeAttr('checked');
           	$(clone).find("input,select").each(function(e){
            	var name = $(this).attr("name");
                name = name.replace("_1", "_"+count);
                $(this).attr("name",name);
                $(this).attr("id",name);
            })
           	$(clone).find(".delRow").attr("name","RemoveEquip_"+count);
           	$(clone).find(".delRow").attr("id","RemoveEquip_"+count);
            $("##carrierEquipments").append(clone);
            $('##totalequipcount').val(count);
            createSelect2();
		}

		function RemoveEquipmentRow(row){
			var rowId = $(row).attr("id");
			var rowNo = parseInt(rowId.split('_')[1]);
			var count = parseInt($('##totalequipcount').val());
			var CarrierEquipmentID = $("##CarrierEquipmentID_"+rowNo).val();
			if (confirm("Are you sure you want to remove this?")) {
				if(CarrierEquipmentID==''){
					RemoveEquipmentRow2(count,rowNo);
				}
				else{
					var path = urlComponentPath+"carriergateway.cfc?method=DeleteCarrierEquipment";
	                $.ajax({
	                    type: "Post",
	                    url: path,
	                    dataType: "json",
	                    async: false,
	                    data:{
	                        dsn:'#application.dsn#',
	                        CarrierEquipmentID:CarrierEquipmentID
	                    },
	                    beforeSend: function() {
	                    },
	                    success: function(data){
	                        if(data == 'Success'){
	                            RemoveEquipmentRow2(count,rowNo);
	                        }
	                        else{
	                            alert('Something went wrong. Unable to delete.');
	                        }
	                    }
	                });
				}
			}
		}
		function RemoveEquipmentRow2(count,rowNo){
			if(count==1){
				$("##CarrierEquipmentID_1").val("");
	            $("##EquipmentID_1").val("");
	            $("##relEquipmentID_1").val("");
	            $("##IsDefault_1").removeAttr('checked');
			}
			else{
				$("##equipmentrow_"+rowNo).remove();
				if(count>rowNo){
					for(i=rowNo+1;i<=count;i++){
						var j = i-1;
						var row = $("##equipmentrow_"+i);
						$(row).find("input,select").each(function(e){
			            	var name = $(this).attr("name");
			                name = name.split('_');
			                $(this).attr("name",name[0]+'_'+j);
			                $(this).attr("id",name[0]+'_'+j);
			            });
			            $(row).find(".delRow").attr("name","RemoveEquip_"+j);
           				$(row).find(".delRow").attr("id","RemoveEquip_"+j);
			            $(row).attr("id","equipmentrow_"+j);
					}
				}
				count = --count;
	            $('##totalequipcount').val(count);
			}
		}

		function DefaultEquipment(row){
			var rowId = $(row).attr("id");
			var rowNo = parseInt(rowId.split('_')[1]);
			var checked = $(row).attr('checked');
			$(".IsDefault").removeAttr('checked');
			if(checked){
				$(row).attr('checked', true);
			}
		}

		function changeTruck(row){
			var rowId = $(row).attr("id");
			var rowNo = parseInt(rowId.split('_')[1]);
			$('##relEquipmentID_'+rowNo).val('');
			var Trailer = $('##'+rowId+' option:selected').attr('data-trailer');
			$('##relEquipmentID_'+rowNo).val(Trailer);
		}

		function ViewCarrierPacket(CarrierID){
			$('.overlay_rp').show();
			$('##loader_new').show();
			$.ajax({
                type    : 'POST',
                url     : "ajax.cfm?event=ajxGetCarrierPacketURL",
                data    : {CarrierID:CarrierID},
                success :function(response){
                	var resData = jQuery.parseJSON(response);
                	if(resData.success){
                		window.open(resData.url, "_blank");
                	}
                	else{
                		alert('Unable to process the request.')
                	}
                	$('.overlay_rp').hide();
                	$('##loader_new').hide();
                }
            })
		}
</script>
<div class="overlay"></div>
<div id="loader_new">
	<img src="images/loadDelLoader.gif">
	<p id="loadingmsg_new">Please wait.</p>
</div>
<div id="CLPopup">
<div class="CLPopupHeader"><h1 style="color:white;font-weight:bold;">Carrier Lookout</h1></div>
<div class="CLPopupContent">
	<fieldset>
		<label style="font-size: 12px;font-weight: bold;">Do you want to update existing address, contact, phone, etc information or just update the insurance information?</label>
        <div class="clear"></div>
        <input type="button" value="Update Insurance Only" style="margin-left:120px;" onclick="UpdateViaCarrierLookOut(1)">
		<input type="button" value="Update All Info" onclick="UpdateViaCarrierLookOut(2)">
	</fieldset>
</div>
</div>
	<style>
		
        ##CLPopup{
	        width: 450px;
	        position: absolute;
	        top: 20%;
	        left: 30%;
	        z-index: 9999;
	        display: none;
	        box-shadow: 0 2px 6px rgba(0,0,0,0.2);
	    }
	    .CLPopupHeader{
	        background-color: ##82bbef;
	        padding-left: 5px;
	    }
	    .CLPopupContent{
	    	background-color:#request.qSystemSetupOptions1.BackgroundColorForContent# !important;
	        padding-left: 15px;
	        font-size: 14px;
	        padding-right:10px;
	        padding-bottom:10px;
	        padding-top: 10px;
	    }
	    .CLPopupContent label{
	        vertical-align:middle;
	    }
	    .msg-area-success{
            border: 1px solid ##a4da46;
            padding: 5px 15px;
            font-weight: normal;
            width: 85%;
            float: left;
            margin-top: 5px;
            margin-bottom:  5px;
            background-color: ##b9e4b9;
            font-weight: bold;
            font-style: italic;
        }
        .msg-area-error{
            border: 1px solid ##da4646;
            padding: 5px 15px;
            font-weight: normal;
            width: 85%;
            float: left;
            margin-top: 5px;
            margin-bottom:  5px;
            background-color: ##e4b9c6;
            font-weight: bold;
            font-style: italic;
        }
        .sel_commodityType,.selEquipmentID{
        	float: left;
        	margin-left: 5px;
        }
		##loader_new{
			position: fixed;
			top:40%;
			left:40%;
			z-index: 999;
			display: none;
		}
		##loadingmsg_new{
			font-weight: bold;
			text-align: center;
			margin-top: 1px;
			background-color: ##fff;
		}
		.disAllowStatusEdit{
			background: none repeat scroll 0 0 ##e3e3e3 !important;
		    border: 1px solid ##c5c1c1 !important;
		    color: ##434343 !important;
		    pointer-events: none;
		}
	</style>
	<style>
	    .s-hidden {
	        visibility:hidden;
	        padding-right:10px;
	    }
	    .select {
	        cursor:pointer;
	        display:inline-block;
	        position:relative;
	        font:normal 11px/22px Arial,Sans-Serif;
	        color:black;
	        border: 1px solid ##b3b3b3;
	        float: left;
	        height: 21px;
	        margin-bottom: 3px;
	    }
	    .styledSelect {
	        position:absolute;
	        top:0;
	        right:0;
	        bottom:0;
	        left:0;
	        background-color:white;
	        padding:0 4px;
	        height: 21px;
	        overflow: hidden;
	    }
	    .styledSelect:after {
	        content:"";
	        width:0;
	        height:0;
	        border:5px solid transparent;
	        border-color:black transparent transparent transparent;
	        position:absolute;
	        top:9px;
	        right:6px;
	    }
	    .styledSelect:active,.styledSelect.active {
	        background-color:##eee;
	    }
	    .options {
	        display:none;
	        position:absolute;
	        top:100%;
	        right:0;
	        left:0;
	        z-index:999;
	        margin:0 0;
	        padding:0 0;
	        list-style:none;
	        border:1px solid ##b3b3b3;
	        background-color:white;
	        -webkit-box-shadow:0 1px 2px rgba(0,0,0,0.2);
	        -moz-box-shadow:0 1px 2px rgba(0,0,0,0.2);
	        box-shadow:0 1px 2px rgba(0,0,0,0.2);
	        width:352px;
	        max-height: 125px;
	        overflow: auto;
	    }
	    
	    .options tr {
	        padding:0 6px;
	        margin:0 0;
	        padding:0 10px;
	    }
	    .options tr:hover {
	        background-color:##39f;
	        color:white;
	    }
	    .options td {
	        border-top: 1px solid ##b3b3b3;
	        border-right: 1px solid ##b3b3b3;
	        font: 11px/16px Arial,Helvetica,sans-serif !important;
	        padding-left: 3px;
	        padding-right: 3px;
	    }
	    .options th{
	        border-right: 1px solid ##b3b3b3;
	        text-align: left;
	        font: 11px/16px Arial,Helvetica,sans-serif !important;
	        padding-left: 3px;
	        padding-right: 3px;
	        font-weight: bold !important;
	    }
	    .options tr.hover {
	        background-color:##39f;
	        color:white;
	    }
	    .options tbody tr:first-child td:first-child {
	        border-right: none;
	    }
	    .options tbody tr:first-child td:nth-child(2) {
	        border-right: none;
	    }
    </style>
    <div class="overlay" <cfif isdefined("url.carrierid") and len(trim(url.carrierid)) gt 1 and structKeyExists(session, "currentusertype") and session.currentusertype eq 'Data Entry'>style="display:block;"</cfif>></div>
     <link href="https://cdn.jsdelivr.net/npm/select2@4.1.0-beta.1/dist/css/select2.min.css" rel="stylesheet" />
    <script src="https://cdn.jsdelivr.net/npm/select2@4.1.0-beta.1/dist/js/select2.min.js"></script>
     <script type="text/javascript">
        function createSelect2(){
        	$('.EquipmentSelect2').each(function(i, tag) {
        		var id=$(this).attr('id');
	        	$(tag).select2({
	            		"language": {
	   					"noResults": function(){
				         	if(confirm('There is no matching equipment found. Do you like to add a new equipment?')){
				         		var term = event.target.value;
	                            openAddNewEquipmentPopup(term,id,'Truck');
	                        }
				    	}
				   	},
	            });
        	});
        	$('.RelEquipmentSelect2').each(function(i, tag) {
        		var id=$(this).attr('id');
	        	$(tag).select2({
	            		"language": {
	   					"noResults": function(){
				         	if(confirm('There is no matching equipment found. Do you like to add a new equipment?')){
				         		var term = event.target.value;
	                            openAddNewEquipmentPopup(term,id,'Trailer');
	                        }
				    	}
				   	},
	            });
        	});
        	$('.DriverSelect2').each(function(i, tag) {
        		var id=$(this).attr('id');
	        	$(tag).select2({
	            		"language": {
	   					"noResults": function(){
				         	if(confirm('There is no matching driver found. Do you like to add a new driver?')){
				         		var term = event.target.value;
				         		openAddNewCarrierContactPopup(term,id);
	                        }
				    	}
				   	},
	            });
        	});
        }

        function SwitchManualSign(CarrierID){
        	$.ajax({
                type: "GET",
                url: 'CarrierOnBoard/index.cfm?event=FinishOnBoard&CarrierID='+CarrierID+'&SwitchManualSign=1',
                dataType: "json",
                beforeSend: function() {
                	$('.overlay_rp').show();
					$('##loader_new').show();
                },
                success: function(data){
                	location.reload();
                }
            });
        }
      </script>
    <style>
      	.select2-container--default .select2-selection--single .select2-selection__rendered {
		    color: ##000;
		}
    </style>
    <script type="text/javascript">
        $( document ).ready(function() {
            $('.form-popup-close').click(function(){
                $('body').removeClass('formpopup-body-noscroll');
                $(this).closest( ".form-popup" ).hide();
                $('.formpopup-overlay').hide();
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
        });
    </script>
    <div class="formpopup-overlay" style="left: 0;"></div>
</cfoutput>
<cfinclude template="formpopup/AddNewEquipment.cfm">
<cfinclude template="formpopup/AddNewCarrierContact.cfm">