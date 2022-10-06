
<cfoutput>
<cfsilent>
 <cfinvoke component="#variables.objloadGateway#" method="getSystemSetupOptions" returnvariable="request.qGetSystemSetupOptions" />
 <cfset requireValidMCNumber = request.qGetSystemSetupOptions.requireValidMCNumber>
<cfinvoke component="#variables.objloadGateway#" method="getcurAgentMaildetails" returnvariable="request.qcurMailAgentdetails" employeID="#session.empid#" />
	<cfif request.qcurMailAgentdetails.recordcount gt 0 and (request.qcurMailAgentdetails.SmtpAddress eq "" or request.qcurMailAgentdetails.SmtpUsername eq "" or request.qcurMailAgentdetails.SmtpPort eq "" or request.qcurMailAgentdetails.SmtpPassword eq "" or request.qcurMailAgentdetails.SmtpPort eq 0)>
	  <cfset mailsettings = "false">
  <cfelse>
	  <cfset mailsettings = "true">
  </cfif>
	<cfif request.qGetSystemSetupOptions.freightBroker EQ 1 OR (request.qGetSystemSetupOptions.freightBroker EQ 2 AND  structKeyExists(url,"IsCarrier") AND url.IsCarrier EQ 1)>
		<cfset variables.freightBroker = "Carrier">
		<cfset variables.freightBrokerShortForm = "Carr">
		<cfset variables.freightBrokerId = "MC">
	<cfelseif request.qGetSystemSetupOptions.freightBroker EQ 0 OR (request.qGetSystemSetupOptions.freightBroker EQ 2 AND  structKeyExists(url,"IsCarrier") AND url.IsCarrier EQ 0)>
		<cfset variables.freightBroker = "Driver">
		<cfset variables.freightBrokerShortForm = "Driver">
		<cfset variables.freightBrokerId = "Driver Lic">
	<cfelse>
		<cfdump var="#request.qGetSystemSetupOptions.freightBroker#" abort>
	</cfif>
</cfsilent>

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
<cfparam name="DOBDate" default="">
<cfparam name="hiredDate" default="">
<cfparam name="businessAddress" default="">
<cfparam name="businessPhone" default="">
<cfparam name="insCarrier" default="">
<cfparam name="insPolicy" default="">
<cfparam name="insAgentName" default="">
<cfparam name="insCarrierDetails" default="">
<cfparam name="licState" default="">
<cfparam name="Status" default="">
<cfparam name="StatusValID" default="">
<cfparam name="StatusValCODE" default="">
<cfparam name="CarrierName" default="">
<cfparam name="City" default="">
<cfparam name="State" default="">
<cfparam name="State1" default="">
<cfparam name="Address" default="">
<cfparam name="Zipcode" default="">
<cfparam name="ss" default="">
<cfparam name="Country" default="">
<cfparam name="Country1" default="9bc066a3-2961-4410-b4ed-537cf4ee282a">
<cfparam name="Phone" default="">
<cfparam name="PhoneExt" default="">
<cfparam name="CellPhone" default="">
<cfparam name="CellPhoneExt" default="">
<cfparam name="Fax" default="">
<cfparam name="FaxExt" default="">
<cfparam name="Tollfree" default="">
<cfparam name="TollfreeExt" default="">
<cfparam name="Email" default="">
<cfparam name="CDLExpires" default="">
<cfparam name="InsExpDate" default="">
<cfparam name="lastDrugTest" default="">
<cfparam name="employeeType" default="">
<cfparam name="InsExpDateLive" default="">
<cfparam name="CargoAmount" default="">
<cfparam name="Certificate" default="">
<cfparam name="Terms" default="">
<cfparam name="RegNumber" default="">
<cfparam name="Dispatcher" default="">
<cfparam name="equipment" default="">
<cfparam name="CarrierInstructions" default="">
<cfparam name="EquipmentNotes" default="">
<cfparam name="editid" default="0">
<cfparam name="state11" default="">
<cfparam name="url.mcNo" default="0">
<cfparam name="StateValCODE" default="">
<cfparam name="notes" default="">
<cfparam name="MobileAppPassword" default="">
<cfparam name="isShowDollar" default="0">
<cfparam name="defaultCurrency" default="0">
<cfparam name="carrierEmailAvailableLoads" default="">
<cfparam name="CalculateDHMiles" default="1">
<cfparam name="vendorID" default="">
<cfparam name="company_name" default="">
<cfparam name="irs_ein" default="">
<cfparam name="fuelCardNo" default="">
<cfparam name="Track1099" default="">
<cfparam name="RatePerMile" default="">
<cfparam name="PreConMethod" default="">
<cfparam name="LoadLimit" default="">
<cfset variables.carrierdisabledStatus=false>
<!--- Encrypt String --->
<cfset Secret = application.dsn>
<cfset TheKey = 'NAMASKARAM'>
<cfset Encrypted = Encrypt(Secret, TheKey)>
<cfset dsn = URLEncodedFormat(ToBase64(Encrypted))>

<cfif request.qgetsystemsetupoptions.ForeignCurrencyEnabled>
	<cfinvoke component="#variables.objloadGateway#" method="getCurrencies" IsActive="1" returnvariable="request.qGetCurrencies" />
</cfif>

<cfset CarrOrgName="">
<cfset getMCNoURL=""> 
<cfif isdefined('url.mcNo') and len(url.mcNo) gt 1>
	<cfset MCNumber=url.mcNo>
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
	newwindow=window.open(url,'Map','height=600,width=600');
	if (window.focus) {newwindow.focus()}
	return false;
}
function InsAgentPhone1() {
  var q=$('##InsAgentPhone').val();
if(q.length>=50)
{	
	alert('User Phone needs to be corrected or text length must be less than 50' );
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
function checkDateFormat(ele){
	var reg =/((^(10|12|0?[13578])([/])(3[01]|[12][0-9]|0?[1-9])([/])((1[8-9]\d{2})|([2-9]\d{3}))$)|(^(11|0?[469])([/])(30|[12][0-9]|0?[1-9])([/])((1[8-9]\d{2})|([2-9]\d{3}))$)|(^(0?2)([/])(2[0-8]|1[0-9]|0?[1-9])([/])((1[8-9]\d{2})|([2-9]\d{3}))$)|(^(0?2)([/])(29)([/])([2468][048]00)$)|(^(0?2)([/])(29)([/])([3579][26]00)$)|(^(0?2)([/])(29)([/])([1][89][0][48])$)|(^(0?2)([/])(29)([/])([2-9][0-9][0][48])$)|(^(0?2)([/])(29)([/])([1][89][2468][048])$)|(^(0?2)([/])(29)([/])([2-9][0-9][2468][048])$)|(^(0?2)([/])(29)([/])([1][89][13579][26])$)|(^(0?2)([/])(29)([/])([2-9][0-9][13579][26])$))/;
	var textValue=$(ele).val();
	if(textValue.length){
		if(!textValue.match(reg)){
			alert('Please enter a date in mm/dd/yyyy format');
			$(ele).focus();
			$(ele).val('');
		}
	}	
}
</script>

<cfif isDefined("url.carrierid") and len(url.carrierid)>
    <cfinvoke component="#variables.objCarrierGateway#" method="getAllCarriers" returnvariable="request.qCarrier">
    	<cfinvokeargument name="carrierid" value="#url.carrierid#">
    </cfinvoke>
		<cfset MCNumber=request.qCarrier.MCNumber>

	<cfset session.currentDriverId=request.qCarrier.CarrierID>
	<script>			
		$(document).ready(function(){
			//when the page loads for driver edit ajax call for inserting tab id of the page details
			var path = urlComponentPath+"carriergateway.cfc?method=insertTabDetails";
			$.ajax({
            type: "Post",
            url: path,
            dataType: "json",
            async: false,
			data: {
				tabID:tabID,carrierid:'#url.carrierid#',userid:'#session.empid#',sessionid:'#session.sessionid#',dsn:'#application.dsn#'
			},
            success: function(data){
           //  console.log(data);
            }
          });
		});
		var path = urlComponentPath+"carriergateway.cfc?method=CheckCarrierMissingAttachment";
        $.ajax({
            type: "Post",
            url: path,
            dataType: "json",
            data: {
                carrierid:'#url.carrierid#',companyid:'#session.companyid#',dsn:'#application.dsn#',type:'Driver'
            },
            success: function(data){
                if(data==1){
                    $('##missingReqAtt').show();
                }
            }
        });
	</script>

	 <!---Object to get corresponding user edited the carrier--->
	 <cfinvoke component="#variables.objCarrierGateway#" method="getUserEditingDetails" carrierid="#url.carrierid#" returnvariable="request.qryUserEditingDetails"/>
	 <!---Condition to check user edited the driver or not--->
	 <cfif not len(trim(request.qryUserEditingDetails.InUseBy))>
	 	<!---Object to update corresponding user edited the driver--->
	 	<cfinvoke component="#variables.objCarrierGateway#" method="updateEditingUserId" carrierid="#url.carrierid#" userid="#session.empid#" status="false"/>
	 <cfelse>
	 	<!---Object to get corresponding Previously edited---->
	 	<cfinvoke component="#variables.objAgentGateway#" method="getEditingUserName" returnvariable="request.qryGetEditingUserName" employeID="#request.qryUserEditingDetails.inuseby#" />
	 	<!---Condition to check current employee and previous editing employee are not same--->
	 	<cfif session.empid neq request.qryUserEditingDetails.inuseby>
	 		<cfif request.qryGetEditingUserName.recordcount>
	 			<cfset variables.carrierdisabledStatus=true>
	 			<div class="msg-area" style="margin-left:10px;margin-bottom:10px">
	 				<span style="color:##d21f1f">This Driver locked because it is currently being edited by #request.qryGetEditingUserName.Name# #dateformat(request.qryUserEditingDetails.inuseon,"mm/dd/yy hh:mm:ss")#.
	 					An Administrator can manually override this lock by clicking the unlock button.
	 				</span>
	 			</div>
	 		</cfif>
	 	</cfif>
	 </cfif>	
</cfif>

<!--- if updLIData exists in the url, then do the webservice call and update the db --->
<cfif (isdefined('url.updLIData') or len('MCNumber')) and isdefined('url.carrierID')>
	<cfinclude template="websiteDATA.cfm">
	<cfinvoke component="#variables.objCarrierGateway#" method="EditLIWebsiteData" returnvariable="message">
		 <cfinvokeargument name="carrierId" value="#url.carrierID#">
	 </cfinvoke>
	 <cfif not StructKeyExists(url,"updLIData")>
		<cfset message="">
	 </cfif>
</cfif>
<cfset variables.objunitGateway = getGateway("gateways.unitgateway", MakeParameters("dsn=#Application.dsn#,pwdExpiryDays=#Application.pwdExpiryDays#")) >
    
<cfinvoke component="#variables.objunitGateway#" method="getloadUnits" status="True" returnvariable="request.qUnits" />
<cfif isDefined("url.carrierid") and len(url.carrierid)>
	<cfinvoke component="#variables.objCarrierGateway#" method="getCarrierOffice" carrierid="#url.carrierid#" returnvariable="request.qCarrierOffice" />
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
			 <cfset InsExpDate=request.qCarrier.InsExpDate>
		 </cfif>
	     <cfset CellPhone=request.qCarrier.Cel>
	     <cfset Fax=request.qCarrier.Fax> 
	     <cfset Tollfree=request.qCarrier.Tollfree>
	     <cfset PhoneExt=request.qCarrier.PhoneExt>
	     <cfset CellPhoneExt=request.qCarrier.CellPhoneExt>
	     <cfset FaxExt=request.qCarrier.FaxExt> 
	     <cfset TollfreeExt=request.qCarrier.TollfreeExt>
	     <cfset Email=request.qCarrier.EmailID> 
		 <cfset CDLExpires=request.qCarrier.CDLExpires> 
	     <cfset RegNumber=request.qCarrier.RegNumber>
	     <cfset equipment=request.qCarrier.EquipmentID>
	     <cfset InsExpDate=request.qCarrier.InsExpDate>
	     <cfset CarrierInstructions=request.qCarrier.CarrierInstructions>
	     <cfset EquipmentNotes=request.qCarrier.EquipmentNotes>
		 <cfset notes =request.qCarrier.notes>
		 <cfset Terms =request.qCarrier.CarrierTerms>		 
		 <cfset licState =request.qCarrier.licState>
		 <cfset DOBDate =request.qCarrier.DOBDate>
		 <cfset hiredDate =request.qCarrier.hiredDate>
		 <cfset ss =request.qCarrier.ss>
		 <cfset employeeType =request.qCarrier.employeeType>
		 <cfset lastDrugTest =request.qCarrier.lastDrugTest>		 
	     <cfset editid=#url.carrierid#>
	     <cfset getMCNoURL="index.cfm?event=adddriver&carrierid=#url.carrierid#&#session.URLToken#"> 
	     <cfset PreConMethod=request.qCarrier.ContactHow>
	     <cfset LoadLimit=request.qCarrier.LoadLimit>
		 <cfset MobileAppPassword=request.qCarrier.MobileAppPassword>
		 <cfset isShowDollar=request.qCarrier.isShowDollar>
		 <cfset defaultCurrency=#request.qCarrier.defaultCurrency#>
		 <cfset carrierEmailAvailableLoads=#request.qCarrier.CarrierEmailAvailableLoads#>
		 <cfset CalculateDHMiles=#request.qCarrier.CalculateDHMiles#>
		 <cfset vendorID=request.qCarrier.VENDORID>
		 <cfset company_name=request.qCarrier.company_name>
		 <cfset irs_ein=request.qCarrier.irs_ein>
		 <cfset fuelCardNo = request.qCarrier.fuelCardNo>
		 <cfset Track1099=request.qCarrier.Track1099>
		 <cfset RatePerMile=request.qCarrier.RatePerMile>
		 <cfinclude template="dbwebsiteDATA.cfm"> 
	</cfif>
<cfelse>
	<cfset getMCNoURL="index.cfm?event=adddriver&#session.URLToken#">
	<cfset PreConMethod="">
	<cfset LoadLimit="0">
	<cfif len(trim(request.qGetSystemSetupOptions.DefaultCountry))>
		<cfset country1 = request.qGetSystemSetupOptions.DefaultCountry>
	</cfif>
   <!--- Since carrierid doesnot exists so here make a webservice call --->
    <cfinclude template="websiteDATA.cfm"> 
</cfif>
   <cfif len(pv_legal_name)> 
    <cfset ValidMCNO=1>      
   	<cfset CarrOrgName=pv_legal_name>
	<cfset pv_legal_name = Replace(pv_legal_name,"&","~","all")>
	<cfloop list="#pv_legal_name#" index="ldrIndx" delimiters=" ">
		<cfset webLegger = listAppend(webLegger,ldrIndx,"^")>
	</cfloop>
	<cfset MCNumber=#MCNumber#>
	<cfif not isDefined("url.carrierid")>
		<cfset CarrierName=CarrOrgName>
	    <cfset MCNumber=#MCNumber#>
	    <cfset NowAddress=replace(businessAddress,"&nbsp;"," ","all")>
	    <cfset addLen = listlen(NowAddress," ")> 
	    <cfset Address="">       
        <cfset AddressLen=addLen-3>
         <cfloop from="1" to="#AddressLen#" index="listindex">
         <cfset Address=Address & " " & listgetAt(NowAddress,listindex," ")>
        </cfloop>
        <cfset Address=trim(Address)>
        <cfset loopCount = 1>
        
	    <cfloop from="#addLen#" to="1" step="-1" index="lstindx">
	     <cfif loopcount is 1 >
	    	<cfset Zipcode=listgetAt(NowAddress,lstindx," ")>
	     <cfelseif loopcount is 2>
	     	<cfset State11=listgetAt(NowAddress,lstindx," ")>
	     <cfelseif loopcount is 3>
	     	<cfset City=listgetAt(NowAddress,lstindx," ")>
	     <cfelse>        
	      <cfbreak>
	     </cfif>
	    <cfset loopCount = loopCount + 1>
	    </cfloop>

		 <cfset StateValCODE=State11>	 
		<cfset businessPhone = replacenocase(businessPhone,'(',"","all")>
		<cfset businessPhone = replacenocase(businessPhone,') ',"-","all")>
	    <cfset Phone=businessPhone>
                
        <cfif ISVALID("DATE",InsExpDateLive)>
		    <cfset InsExpDate=dateformat(InsExpDateLive,'mm/dd/yyyy')>
        <cfelse>
        	<cfset InsExpDate=''>
        </cfif>
        
	    <cfset bipd_Insurance_on_file = replace(bipd_Insurance_on_file,"$","","all")>
	    <cfset bipd_Insurance_on_file = replace(bipd_Insurance_on_file,",","","all")>
        
	</cfif>
<cfelse>
<cfset  ValidMCNO=0>
</cfif>	
<cfform name="frmCarrier" action="index.cfm?event=adddriver:process&#session.URLToken#&editid=#editid#" onsubmit="return validateCarrier(frmCarrier,'#application.dsn#');InsAgentPhone1();" method="post" autocomplete="off">
	<input id="username" style="display:none" type="text" name="usernameremembered">
  	<input id="password" style="display:none" type="password" name="passwordremembered">
	<input type="hidden" name="IsCarrier" id="IsCarrier" value="0">
    <input type="hidden" id="SaveAndExit" name="SaveAndExit" value="0"/>
    <input type="hidden" name="carrierdisabledStatus" id="carrierdisabledStatus" value="#variables.carrierdisabledStatus#">
    <input type="hidden" id="CompanyID" name="CompanyID" value="#session.CompanyID#">
    <input type="hidden" name="isSaveEvent" id="isSaveEvent" value="false"/>
    <input name="appDsn" id="appDsn" type="hidden" value="#application.dsn#">
    <input type="hidden" name="tabid" id="tabid" value="">
<cfif isDefined("url.carrierid") and len(url.carrierid)>
 
	<cfinvoke component="#variables.objCarrierGateway#" method="getAttachedFiles" linkedid="#url.carrierid#" fileType="3" returnvariable="request.filesAttached" /> 
    <div style="clear:both"></div>
	<cfif isdefined("session.message") and len(session.message)>
	<div id="message" class="msg-area" style="width:500px">#session.message#</div>
	<cfset exists= structdelete(session, 'message', true)/> 
	</cfif>
	<div style="clear:both"></div>

	<div class="search-panel" style="height:40px;">
		<div style="float: left; width: 80%; text-align: center;"><h1>#Ucase(CarrierName)#</h1></div>
		<div class="delbutton">
			<cfif carrierdisabledStatus neq true>
		<a href="index.cfm?event=carrier&carrierid=#editid#&IsCarrier=0&#session.URLToken#" onclick="return confirm('Are you sure to delete it ?','Delete #variables.freightBroker#');">Delete</a>
		</cfif>
		</div>
	</div>	
	<div style="float:left;">
		<div id="customerTabs" class="tabsload ui-tabs ui-widget ui-widget-content ui-corner-all" style="float:left;border:none;padding-bottom: 0;margin-top: -5px;">
			<ul class="ui-tabs-nav ui-helper-reset ui-helper-clearfix ui-widget-header ui-corner-all" style="height:27px;background: ##dfeffc !important;border:none; ">
		    	<li class="ui-state-default ui-corner-top ui-tabs-active ui-state-active">
		    		<a class="ui-tabs-anchor" href="##cust-detail">#variables.FreightBroker#</a>
		    	</li>
		    	<li class="ui-state-default ui-corner-top">
		    		<a class="ui-tabs-anchor" href="index.cfm?event=CarrierCRMNotes&#session.URLToken#&carrierid=#url.carrierid#<cfif request.qGetSystemSetupOptions.FreightBroker EQ 2 AND structKeyExists(url, "iscarrier") AND url.iscarrier eq 0>&IsCarrier=0</cfif>">CRM</a>
		    	</li>
		     
			</ul>
		</div>
	</div>
	<div class="search-panel" style="height:30px;">
		<div style="float:right">
			<cfif carrierdisabledStatus neq true>
			<input id="mailDocLink" style="width:110px !important;line-height: 15px;" type="button" class="normal-bttn"value="Email Doc" <cfif mailsettings>data-allowmail="true"<cfelse>data-allowmail="false"</cfif>/>
		  <cfif requireValidMCNumber EQ True>	
           <cfinput name="Save" type="submit" class="normal-bttn" value="Save" onclick="saveExit(0);" onfocus="checkUnload();" style="width:44px;" />
	        <cfinput name="Save" type="submit" class="normal-bttn" value="Save & Exit" onclick="saveExit(1);" onfocus="checkUnload();" style="width:44px;" />
            
		  <cfelse>
			<cfinput name="Save" type="submit" class="normal-bttn" value="Save" onclick="saveExit(0);" onfocus="checkUnload();" style="width:44px;" />
            <cfinput name="Save" type="submit" class="normal-bttn" value="Save & Exit" onclick="saveExit(1);" onfocus="checkUnload();" style="width:44px;" />
            
           

		  </cfif>	
			<cfinput name="Return" type="button" class="normal-bttn" onclick="javascript:history.back();" value="Back" style="width:62px;line-height:15px;" />	
		<cfelse>
			<cfif structKeyExists(session, 'rightsList') and ListContains(session.rightsList, 'UnlockDriver', ',')>
				<input id="Unlock" name="unlock" type="button" class="green-btnUnlock" onClick="removeDriverEditAccess('#url.carrierid#');" value="Unlock" style="width:100px !important;float:right;">
			</cfif>
		</cfif>
		</div>
	</div>
	</h1>
	 <div class="white-con-area" style="height: 36px;background-color: ##82bbef;">
		 <div style="float: left; width: 20%;" id="divUploadedFiles">
		 	<img id="missingReqAtt" style="float: left;background-color: ##fff;border-radius: 11px;margin-top: 6px;margin-left: 2px;margin-right: 2px;display: none;" src="images/exclamation.ico" title="Required Attachments Missing">
		 	<cfif carrierdisabledStatus neq true>
			 <cfif request.filesAttached.recordcount neq 0>
				&nbsp;<a style="display:block;font-size: 13px;padding-left: 2px;color:white;" href="##" onclick="popitup('../fileupload/multipleFileupload/MultipleUpload.cfm?id=#url.carrierid#&attachTo=3&user=#session.adminusername#&dsn=#dsn#&attachtype=Driver&CompanyID=#session.CompanyID#')"><img style="vertical-align:bottom;" src="images/attachment.png">View/Attach Files</a>
			<cfelse>
				&nbsp;<a style="display:block;font-size: 13px;padding-left: 2px;color:white;" href="##" onclick="popitup('../fileupload/multipleFileupload/MultipleUpload.cfm?id=#url.carrierid#&attachTo=3&user=#session.adminusername#&dsn=#dsn#&attachtype=Driver&CompanyID=#session.CompanyID#')"><img style="vertical-align:bottom;" src="images/attachment.png">Attach Files</a>

			</cfif>
			<cfelse>
				&nbsp; 
				<span style = "display:block;font-size: 13px;padding-left: 2px;color:white;"></span>	
			</cfif>
		</div>
		<div style="float: left; width: 46%;"><h2 style="color:white;font-weight:bold;">#variables.freightBroker# Information</h2></div>
		<div style="float: left; width: 34%;"><h2 style="color:white;font-weight:bold;">Remit Information</h2></div>
	</div>
	<div style="clear:left;"></div>
<cfelse>
	<cfset tempLoadId = #createUUID()#>
	 <cfset session.checkUnload ='add'>
	 <div>
	 <div style="float:left;">
	<h1>Add New #variables.freightBroker#</h1>
	</div>

	<fieldset class="carrierFields" style="width: 682px;float: right;">
			<div style="padding-left:120px;">
			<cfif carrierdisabledStatus neq true>
			<cfif requireValidMCNumber EQ True>	
                <cfinput name="Save" type="submit" class="normal-bttn" value="Save" onclick="saveExit(0);" onfocus="checkUnload();" style="width:44px;" />
                <cfinput name="Save" type="submit" class="normal-bttn" value="Save & Exit" onclick="saveExit(1);" onfocus="checkUnload();" style="width:44px;" />
			<cfelse>
					<cfinput name="Save" type="submit" class="normal-bttn" value="Save" onfocus="checkUnload();saveExit(0);" style="width:44px;" />
	                <cfinput name="Save" type="submit" class="normal-bttn" value="Save & Exit" onclick="saveExit(1);" onfocus="checkUnload();" style="width:44px;" />

			</cfif>
			<cfelse>
				<cfif structKeyExists(session, 'rightsList') and listContains(session.rightsList, 'UnlockDriver', ',')>
					<input id="Unlock" name="unlock" type="button" class="normal-bttn" onClick="removeDriverEditAccess('#url.carrierid#');" value="Unlock" style="width:100px !important;float:right;">
				</cfif>
			</cfif>
			<cfinput name="Return" type="button" class="normal-bttn" onclick="javascript:history.back();" value="Back" style="width:62px;" />
			<cfif isDefined("url.carrierid") and len(url.carrierid) gt 1>
				<cfinput name="GenRecExp" type="button" class="normal-bttn" onclick="document.location.href='index.cfm?event=generateRecurringDriverExpenses&driverid=#carrierid#&#session.URLToken#&#isCarrier#'" value="Generate Recurring Expenses" style="width:184px !important;" />
			</cfif>
			</div>
			<div style="clear:left;"></div>
		</fieldset>
		<div style="clear:left;"></div>
	</div>

		 <div class="white-con-area" style="height: 36px;background-color: ##82bbef;">
			 <div style="float: left; width: 20%;" id="divUploadedFiles">
			</div>

			


			<div style="float: left; width: 46%;"><h2 style="color:white;font-weight:bold;">#variables.freightBroker# Information</h2></div>
			<div style="float: left; width: 34%;"><h2 style="color:white;font-weight:bold;">Remit Information</h2></div>
		</div>
	<div style="clear:left;"></div>
</cfif>
<cfif isdefined("message") and len(message)> 
</cfif>

			<div class="white-con-area">
				<div class="white-mid">
                     <cfinput type="hidden" id="editid" name="editid" value="#editid#">
						<div class="form-con">
							<fieldset class="carrierFields">
                                <label>#variables.freightBrokerId# ##</label>
								<cfif requireValidMCNumber EQ True>
								  <cfinput name="MCNumber" id="MCNumber" type="text" tabindex="1"  value="#MCNumber#" onchange="getMCDetails('#getMCNoURL#',this.value,'#application.dsn#','driver');"  style="width:75px !important;" maxlength="50"/>
								<cfelse>
								  <cfinput name="MCNumber" id="MCNumber" type="text" tabindex="1"  value="#MCNumber#" onchange="getMCDetails('#getMCNoURL#',this.value,'#application.dsn#','driver');" style="width:75px !important;" maxlength="50"/>
								</cfif>
                      		    <label style="width:50px;">Lic State:</label>
								<cfinput id="licState" type="text" tabindex="1" style="width:18px;" name="licState" maxlength="2" value="#licState#">

								<label style="width:25px;">DOB:</label>
								<input name="DOBDate" tabindex="1" type="datefield" value="#Dateformat(DOBDate,'mm/dd/yyyy')#" style="width:56px !important;" onchange="checkDateFormat(this);"/>
                      		    <div class="clear"></div>
                      		   
							    <label>Name *</label>
				       	        <cfinput name="CarrierName" type="text" tabindex="2" value="#CarrierName#"  required="yes" message="Please enter #variables.freightBroker# name" style="width:146px;" maxlength="100"  class="disAllowHash"/>
				       			<label style="width:47px;padding-left: 4px;padding-right: 5px;">Hired:</label>
								<input name="hiredDate" tabindex="2" type="datefield" value="#Dateformat(hiredDate,'mm/dd/yyyy')#" style="width:56px" onchange="checkDateFormat(this);"/>
								<div class="clear"></div>
								
				       	        <cfinput name="RegNumber" type="hidden" tabindex="3" value="#RegNumber#" maxlength="20"/>
							   	<label>Address</label>
								<textarea rows="2" tabindex="4" cols="" name="Address" style="height:auto;" maxlength="200">#trim(Address)#</textarea>
								<div class="clear"></div>                                
								<label>City</label>
								<cfinput name="City" id="City" tabindex="-1" type="text" value="#City#" maxlength="150"/>
								<div class="clear"></div>
								<label>State</label>
                                <select name="State" id="state" tabindex="-1" style="width:100px;">
                                    <option value="">Select</option>
                                    <cfloop query="request.qstates">
                                        <option value="#request.qstates.StateCode#" <cfif  request.qstates.STATECODE is StateValCODE> selected="selected" </cfif>>#request.qstates.statecode#</option>
                                   </cfloop>
                               	</select>
								<label style="width:70px;">Zip</label>
								<cfinput name="Zipcode" style="width:100px;" id="Zipcode" type="text" value="#Zipcode#" tabindex="7" maxlength="20"/>
							<div class="clear"></div>
							<label>Country</label>
							<select name="Country" tabindex="8" style="width:128px;">
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
							<label style="width:43px;">SS##</label>
							<cfinput name="ss" style="width:100px;" id="ss" type="text" value="#ss#" onchange="ParseSSNumber(this);" tabindex="8" message="Please enter a SS##" maxlength="11"/>
							<div class="clear"></div>
							<label>Phone</label>
							<cfinput name="Phone" tabindex="9" type="text" value="#Phone#" onchange="ParseUSNumber(this);" style="width:185px;" maxlength="150"/>
							<label class="ex" style="width:20px;">Ext.</label>
        					<input type="text" name="PhoneExt" tabindex="19" style="width:50px;" value="#PhoneExt#" maxlength="10">
							<div class="clear"></div>
							<label>Fax</label>
							<cfinput name="Fax" type="text" tabindex="10" value="#Fax#" style="width:185px;" maxlength="150"/>
							<label class="ex" style="width:20px;">Ext.</label>
        					<input type="text" name="FaxExt" tabindex="19" style="width:50px;" value="#FaxExt#" maxlength="10">
							<div class="clear"></div>				
							<label>Phone 2</label>
							<cfinput name="Tollfree" type="text" tabindex="11" value="#Tollfree#" style="width:185px;" maxlength="250"/>
							<label class="ex" style="width:20px;">Ext.</label>
        					<input type="text" name="TollfreeExt" tabindex="19" style="width:50px;" value="#TollfreeExt#" maxlength="10">
							<div class="clear"></div>
							<label>Cell</label>
							<cfinput name="CellPhone" tabindex="12" type="text" value="#CellPhone#" style="width:185px;" maxlength="150"/>
							<label class="ex" style="width:20px;">Ext.</label>
        					<input type="text" name="CellPhoneExt" tabindex="19" style="width:50px;" value="#CellPhoneExt#" maxlength="10">
							<div class="clear"></div>
							<label>Email</label>
							<cfinput class="emailbox" name="Email" type="text" tabindex="13" value="#Email#"  validate="email"  maxlength="150"/>
							<div class="clear"></div>
							<label>Company Name</label>
							<cfinput name="company_name" type="text" value="#company_name#" maxlength="50" />
							<div class="clear"></div>
							<label>IRS EIN##</label>
							<cfinput name="irs_ein" type="text" value="#irs_ein#" maxlength="50" />
							<div class="clear"></div>
							<div class="float-left">
							<label style="width:89px">CDL Expires</label>
							<input name="CDLExpires" tabindex="14" type="datefield" value="#Dateformat(CDLExpires,'mm/dd/yyyy')#" style="width:64px" onchange="checkDateFormat(this);"/>
							</div>
							<input name="HasmatLicense" type="hidden" value="False">
							<div class="float-left">
                            <label style="width:70px;">Equip</label>
                            <select name="equipment" tabindex="17" style="width:106px;">
                                <option value="">Select</option>
                                <cfloop query="request.qEquipments">
                                    <option value="#request.qEquipments.equipmentId#" <cfif equipment is request.qEquipments.equipmentId> selected="selected" </cfif>>
                                    	<cfif len(trim(request.qEquipments.equipmentCode))>#trim(request.qEquipments.equipmentCode)#</cfif>
                                    	<cfif len(trim(request.qEquipments.equipmentName))>- #trim(request.qEquipments.equipmentName)#</cfif>
                                    	<cfif len(trim(request.qEquipments.unitNumber))>- #trim(request.qEquipments.unitNumber)#</cfif>
                                    	<cfif len(trim(request.qEquipments.licensePlate))>- #trim(request.qEquipments.licensePlate)#</cfif>
                                    </option>
								</cfloop>
                            </select>
							</div>
                            <div class="clear"></div>
							<div class="float-left">
							<label style="width:89px">Physical Expires</label>
							<input name="InsExpDate" tabindex="17" type="datefield" value="#Dateformat(InsExpDate,'mm/dd/yyyy')#" style="width:64px" onchange="checkDateFormat(this);" />
							</div>
							<div class="float-left">
							<label style="width:73px;">Emp. Type</label>
                            <select name="employeeType" id="employeeType" tabindex="17" style="width:106px;">
								<option value="">Select</option>
								<option value="ownerOperator" <cfif employeeType EQ "ownerOperator"> selected="selected" </cfif>>Owner Operator</option>
								<option value="employee" <cfif employeeType EQ "employee"> selected="selected" </cfif>>Employee</option>
                            </select>
							</div>
							<div class="clear"></div>
							<div class="float-left">
							<label style="width:89px">Last Drug Test</label>
							<input name="lastDrugTest" tabindex="31" type="datefield" value="#Dateformat(lastDrugTest,'mm/dd/yyyy')#" style="width:64px"  onchange="checkDateFormat(this);" autocomplete="nope" />
							</div>
							<div class="float-left">
							<label style="width:73px;">Status</label>
                            <select name="Status" tabindex="31" style="width:106px;">
                                <option value="1" <cfif Status is 1> selected="selected" </cfif>>Active</option>
                                <option value="0" <cfif Status is 0> selected="selected" </cfif>>InActive</option>
                            </select>
							</div>
							<div class="clear"></div>
							<div class="float-left">
								<label>Preferred Contact Method</label>
								<select name="PreConMethod" id="PreConMethod" style="width:87px;">
								    <option value="1" <cfif PreConMethod EQ 1> selected="true" </cfif>>E-mail</option>
								    <option value="2" <cfif PreConMethod EQ 2> selected="true" </cfif>>Text</option>
								    <option value="3" <cfif PreConMethod EQ 3> selected="true" </cfif>>Both</option>
								</select>
							</div>
							<div class="float-left">
								<label style="width:77px;">Track 1099</label>
								<select name="Track1099" tabindex="36" style="width:105px;">
									<option value="True" <cfif Track1099 is 'True'> selected="true" </cfif>>True</option>
									<option value="False" <cfif Track1099 is 'False'> selected="true" </cfif>>False</option>
								</select>
							</div>
							<div class="clear"></div>

							<div style="display:none;"><label>Load Limit Per Day</label> <!---We dont need this as perhttps://loadmanager.freshdesk.com/support/tickets/653---> 
                            <cfinput name="LoadLimit" type="text" value="#trim(LoadLimit)#" tabindex="18"/>
							<div class="clear"></div>
							<label>&nbsp;</label>
							0 = System Default
							<div class="clear"></div></div>
							
							<label>Mobile App Password </label>														
								 <cfinput name="MobileAppPassword" type="password" tabindex="18" bindAttribute="autocomplete" bind="off" value="#MobileAppPassword#" style="width:126px;"  message="please enter Mobile App Password" autocomplete="new-password" maxlength="50">
								<div class="clear"></div>
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
							<cfif request.qGetSystemSetupOptions.freightBroker EQ 0 AND request.qGetSystemSetupOptions.ActivateBulkAndLoadNotificationEmail>
								<!--- Activate/Deactivate load alert email --->
								<label>Email Available Loads</label>
								<input type="checkbox" name="carrierEmailAvailableLoads" <cfif len(carrierEmailAvailableLoads) AND carrierEmailAvailableLoads EQ 1>checked="checked"</cfif> class="small_chk" style="float: left;">
							</cfif>		
							<label>Calculate DeadHead Miles</label>		
							<input type="checkbox" name="CalculateDHMiles" <cfif CalculateDHMiles EQ 1>checked="checked"</cfif> class="small_chk" style="float: left;">		
							<label style="width:95px">Show Terms<br>& Amount in<br>Dispatch Report</label>
								 <input type="checkbox" name="isShowDollar" id="isShowDollar" class="small_chk myElements" style="float: left;" <cfif len(isShowDollar) AND isShowDollar EQ 1>checked="checked"</cfif>>	
							<div class="clear"></div> 
						 </fieldset>
					</div>
					<div class="form-con">
						<fieldset class="carrierFields">
							<div class="clear"></div>
							
							<cfif isdefined('url.CarrierId') and len(url.carrierId) gt 1>
								<div style="float:right;">
									<cfinput name="currentloads" type="button" class="normal-bttn" onclick="document.location.href='index.cfm?event=load&#session.URLToken#&carrierId=#url.CarrierId#'" value="CURRENT LOADS" style="width:62px;line-height:15px;margin-top:4px;" />	
								</div>
							</cfif>
							<div class="clear"></div>
							<!---BEGIN: 769: Add Driver Code in Driver screen--->
							<label style="text-align:left;width:75px;">Driver Code</label>
							<cfinput name="venderId" type="text"  value="#trim(vendorID)#"  maxlength="20">
							<div class="clear"></div>
							<!---END: 769: Add Driver Code in Driver screen--->

							<label style="text-align:left;width:75px;">Rate Per Mile</label>
							<cfinput name="RatePerMile" id="RatePerMile" type="text" value="#replace("$#Numberformat(RatePerMile,"___.__")#", " ", "", "ALL")#" onchange="validateRatePerMile();" style="width:45px;" >
							<div class="clear"></div>
							<label style="text-align:left;width:75px;">Fuel Card No.</label>
							<cfinput name="fuelCardNo" type="text"  value="#fuelCardNo#"  maxlength="50">
							<div class="clear"></div>
							<label style="text-align:left;">#variables.freightBroker# Terms</label>
							<div class="clear"></div>
							<cftextarea name="Terms" tabindex="33" style="height:200px;width:400px" maxlength="50">#Terms#</cftextarea>
							<div class="clear"></div>
							
							<label style="text-align:left;width:125px;margin-left:6px;">#variables.freightBroker# Instructions</label>
							<div class="clear"></div>
							<textarea name="CarrierInstructions" tabindex="34" rows="" cols="" style="height:100px;width:400px">#CarrierInstructions#</textarea>
							<div class="clear"></div>
						</fieldset>
					</div>
					<div class="clear"></div>
					<div class="gap"></div>
					<div class="clear"></div>

					<cfif isDefined("url.carrierid") and len(url.carrierid)>
					<cfinvoke component="#variables.objequipmentGateway#" method="getDriverEquipments" driver="#CarrierName#" returnvariable="request.qDriverEquipments" />
					<div class="white-con-area" style="height: 36px;background-color: ##82bbef;">
						<h2 style="color:white;font-weight:bold;margin-left: 5px;">Equipment</h2>
					</div>
					<div class="addbutton" style="cursor: pointer;padding-bottom: 8px;margin-right: 5px;"><a onClick='openEquipmentPopup();'>Add Equipment</a></div>
					<div class="clear"></div>
					<div class="carrier-mid" style="background-color: white;">
						<cfif request.qDriverEquipments.recordcount>
							<table width="85%" border="0" cellspacing="0" cellpadding="0" class="data-table" style="margin-bottom: 15px;">
								<thead>
									<tr>
										<th width="5" align="left" valign="top"><img src="images/top-left.gif" alt="" width="5" height="23" /></th>
										<th align="center" valign="middle" class="head-bg">&nbsp;</th>
										<th align="center" valign="middle" class="head-bg">Equipment Code</th>
										<th align="center" valign="middle" class="head-bg">Name</th>
										<th align="center" valign="middle" class="head-bg">Status</th>
										<th align="center" valign="middle" class="head-bg">Lic.Plate</th>	
										<th align="center" valign="middle" class="head-bg2" >VIN</th>
										<th  align="right" valign="top"><img src="images/top-right.gif" alt="" width="5" height="23" /></th>
									</tr>
								</thead>
								<tbody>
									<cfloop query="request.qDriverEquipments">	
										<cfset href="index.cfm?event=addDriverEquipment&equipmentid=#request.qDriverEquipments.EquipmentID#&#session.URLToken#&IsCarrier=0">
										<cfset onclick="document.location.href='#href#'">
				
										<tr <cfif request.qDriverEquipments.currentRow mod 2 eq 0>bgcolor="##FFFFFF"<cfelse>bgcolor="##f7f7f7"</cfif>>
											<td height="20" class="sky-bg">&nbsp;</td>
											<td class="sky-bg2" valign="middle" align="center" onclick="#onclick#">#request.qDriverEquipments.currentRow#</td>
											<td class="normal-td" valign="middle" align="left" onclick="#onclick#">
												<a href="#href#" title="#request.qDriverEquipments.EquipmentCode#">#request.qDriverEquipments.EquipmentCode#</a>
											</td>
											<td class="normal-td" valign="middle" align="left" onclick="#onclick#">
												<a href="#href#" title="#request.qDriverEquipments.EquipmentCode#">#request.qDriverEquipments.EquipmentName#</a>
											</td>
											<td class="normal-td" valign="middle" align="left" onclick="#onclick#">
												<a href="#href#" title="#request.qDriverEquipments.EquipmentCode#">
													<cfif request.qDriverEquipments.IsActive EQ 1>Active<cfelse>Inactive</cfif>
												</a>
											</td>
											<td class="normal-td" valign="middle" align="left" onclick="#onclick#">
												<a href="#href#" title="#request.qDriverEquipments.EquipmentCode#">#request.qDriverEquipments.LicensePlate#</a>
											</td>
											<td height="30px" class="normal-td2" valign="middle" align="center" onclick="#onclick#" >
												<a href="#href#" title="#request.qDriverEquipments.EquipmentCode#">#request.qDriverEquipments.VIN#</a>
											</td>	
											<td class="normal-td3">&nbsp;</td> 
										</tr>
									</cfloop>
								</tbody>
								<tfoot>
									<tr>
										<td width="5" align="left" valign="top"><img src="images/left-bot.gif" alt="" width="5" height="23" /></td>
										<td colspan="4" align="left" valign="middle" class="footer-bg">
										<div class="up-down">
										<div class="arrow-top"><a href="##"><img src="images/arrow-top.gif" alt="" /></a></div>
										<div class="arrow-bot"><a href="##"><img src="images/arrow-bot.gif" alt="" /></a></div>
										</div>
										<div class="gen-left"></div>
										<div class="gen-right"><img src="images/loader.gif" alt="" /></div>
										<div class="clear"></div>
										</td><td width="5" align="right" valign="top"  class="footer-bg">&nbsp;</td><td  class="footer-bg" width="5" align="right" valign="top">&nbsp;</td>
										<td width="5" align="right" valign="top"><img src="images/right-bot.gif" alt="" width="5" height="23" /></td>
									</tr>	
								</tfoot>
							</table>
						<cfelse>
							No Equipment Found.
						</cfif>
					</div>
					<div class="clear"></div>
					</cfif>
		<div class="white-con-area" style="height: 36px;background-color: ##82bbef;text-align:center;">
			<h2 style="color:white;font-weight:bold;">#variables.freightBroker# Commodity Pricing</h2>
		</div>
		<div class="carrier-mid" style="background-color: white;">
			<br/>
			<div><input type="button" onclick="addNewRow()" value="Add New Row"></div>
			<br/>
			<div class="commodityWrap">
				<table id="tblrow"  class="noh" border="0" cellspacing="0" cellpadding="0">
					<thead>
						<tr>
							<th align="left" width="5" valign="top"><img src="images/top-left.gif" alt=""  height="23" /></th>
							<th align="center" valign="middle" class="head-bg" style="text-align:center;">Commodity</th>
							<th align="left" valign="middle" class="head-bg" style="text-align:center;">#variables.freightBrokerShortForm# Rate</th>
							<th align="left" valign="middle" class="head-bg" style="text-align:center;">#variables.freightBrokerShortForm# % of Customer Total</th>
							<th align="left" valign="middle" class="head-bg" style="text-align:center;">Delete</th>
							<th valign="top" width="5" align="right" style="left: -1px;position: relative;"><img src="images/top-right.gif" alt="" width="5" height="23"></th>
						</tr>
					</thead>					
					<tbody>
						<cfset variables.leftIndex=5>
						<cfif IsDefined("request.qGetCommodityById") and request.qGetCommodityById.recordcount >
							<cfloop query="#request.qGetCommodityById#">
								<tr id="trcomm_#request.qGetCommodityById.currentrow#">
									<td height="20"  width="5"  class="lft-bg">&nbsp;</td>
									<td class="normaltd" valign="middle" align="left" style="width:274px;position:relative;top:-#variables.leftIndex#px;padding:8px 0px;">
										<select name="sel_commodityType_#request.qGetCommodityById.currentrow#" id="type" class="sel_commodityType" style="width:240px;height:26px;">
										  <option value=""></option>
										  <cfloop query="request.qUnits">
											<option value="#request.qUnits.unitID#" <cfif request.qGetCommodityById.COMMODITYID eq request.qUnits.unitID >selected</cfif> >#request.qUnits.unitName#<cfif trim(request.qUnits.unitCode) neq ''>(#request.qUnits.unitCode#)</cfif></option>
										  </cfloop>
										</select>
										<input type="hidden" value="1" name="numberOfCommodity">
										<input type="hidden" value="#request.qGetCommodityById.ID#" id="CarrierCommID_#request.qGetCommodityById.currentrow#" class="CarrierCommID">
									</td>
									
									<td class="normaltd" valign="middle" align="left"  style="width:142px;position:relative;top:-5px;"><input type="text" name="txt_carrRateComm_#request.qGetCommodityById.currentrow#" class="txt_carrRateComm q-textbox" value="$#request.qGetCommodityById.carrrate#"></td>
									<td class="normaltd" valign="middle" align="left"  style="width:132px;position:relative;top:-5px;"><input type="text" name="txt_custRateComm_#request.qGetCommodityById.currentrow#" id="txt_custRateComm_#request.qGetCommodityById.currentrow#" class="txt_custRateComm q-textbox" value="#request.qGetCommodityById.CarrRateOfCustTotal#%" onChange="ConfirmMessage('#request.qGetCommodityById.currentrow#',0)"></td>
									<td class="normaltd" colspan="2" valign="middle" align="left" style="position:relative;top:-5px;">
										<img class="delRow" id="delRow_#request.qGetCommodityById.currentrow#" onclick="delRow(this)" src="images/delete-icon.gif" style="width:10px;margin-left: 5px;cursor: pointer;">
									</td>
								</tr><cfset variables.leftIndex=variables.leftIndex+2>
							</cfloop>
							
						<cfelse>
							<tr id="trcomm_1">
									<td height="20"  width="5"  class="lft-bg">&nbsp;</td>
									<td class="normaltd" valign="middle" align="left" style="width:274px;position:relative;top:-#variables.leftIndex#px;padding:8px 0px;">
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
									<td class="normaltd" valign="middle" align="left"  style="width:132px;position:relative;top:-5px;"><input type="text" name="txt_custRateComm_1" class="txt_custRateComm q-textbox" value="0"></td>
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

		<div class="form-con" style="height:98px;">
				<fieldset class="carrierFields">
					<label style="width:38px">Notes</label>
					<cftextarea rows="7" style="width: 80%; height: 107px;" name="Notes">#notes#</cftextarea>
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
				</fieldset>

		<div class="clear"></div>
		</div>
		<div class="clear"></div>
		<div class="form-con">&nbsp;</div>
		<div class="form-con">
		
		</div>
		<div class="clear"></div>
		
		<cfif isDefined("url.carrierid") and len(url.carrierid) gt 1>
          <p id="footer" style="padding-left:10px;font-family:Verdana, Geneva, sans-serif; font-style:italic bold; text-transform:uppercase;">Last Updated:<cfif isDefined("request.qCarrier")>&nbsp;&nbsp;&nbsp; #request.qCarrier.LastModifiedDateTime#&nbsp;&nbsp;&nbsp;#request.qCarrier.LastModifiedBy#</cfif></p>
       </cfif>
	</div>
	</cfform>
	<div class="white-bot"></div>
	<cfif structkeyexists(url,"carrierid") and len(url.carrierid) gt 1>
		
		<div class="addbutton"  style="cursor: pointer;padding-bottom: 8px;"><a href="index.cfm?event=addDriverExpense&driverid=#url.carrierid#&#session.URLToken#&#isCarrier#">Add Expense</a></div>
		<cfinvoke component="#variables.objequipmentGateway#" method="getCarrierExpenses" carrierID="#url.carrierid#" returnvariable="request.qCarrierExpenses" />
			<div class="white-con-area" style="height: 36px;background-color: ##82bbef;margin-bottom: 14px; margin-top: 33px;">
				<div style="float: left; width: 46%;"><h2 style="color:white;font-weight:bold;margin-left: 12px;">Current #variables.freightBroker# Expenses</h2></div>
			</div>
			<div style="clear:left;"></div>	
		<cfif isdefined("message") and len(message)>
			<div class="msg-area" style="margin-top:35px;margin-bottom:11px;">#message#</div>
		</cfif>
		</div>
		<cfif request.qCarrierExpenses.recordcount>
			<table width="85%" border="0" cellspacing="0" cellpadding="0" class="data-table" id="test">
				<thead>
					<tr>
						<th width="5" align="left" valign="top"><img src="images/top-left.gif" alt="" width="5" height="23" /></th>
						<th align="center" valign="middle" class="head-bg">&nbsp;</th>
						<th align="center" valign="middle" class="head-bg">Description</th>
						<th align="center" valign="middle" class="head-bg">Date</th>
						<th align="center" valign="middle" class="head-bg">Amount</th>
						<th align="center" valign="middle" class="head-bg">Category</th>	
						<th width="100px" align="center" valign="middle" class="head-bg2" >Date Created</th>
						<th  align="right" valign="top"><img src="images/top-right.gif" alt="" width="5" height="23" /></th>
					</tr>
				</thead>
				<tbody>
					<cfloop query="request.qCarrierExpenses">	
						<tr <cfif request.qCarrierExpenses.currentRow mod 2 eq 0>bgcolor="##FFFFFF"<cfelse>bgcolor="##f7f7f7"</cfif> <cfif request.qCarrierExpenses.currentRow GT 5>style="display: none;" class="hiddenExp"</cfif>>
							<td height="20" class="sky-bg">&nbsp;</td>
							<td class="sky-bg2" valign="middle" align="center">#request.qCarrierExpenses.currentRow#</td>
							
							<td class="normal-td" valign="middle" align="left" onclick="document.location.href='index.cfm?event=addDriverExpense&driverid=#carrierid#&carrierExpenseID=#request.qCarrierExpenses.carrierExpenseID#&#session.URLToken#&#isCarrier#'">
								<a title="#request.qCarrierExpenses.Description#" href="index.cfm?event=addDriverExpense&driverid=#carrierid#&carrierExpenseID=#request.qCarrierExpenses.carrierExpenseID#&#session.URLToken#&#isCarrier#">#request.qCarrierExpenses.Description#</a>
							</td>

							<td class="normal-td" valign="middle" align="left" onclick="document.location.href='index.cfm?event=addDriverExpense&driverid=#carrierid#&carrierExpenseID=#request.qCarrierExpenses.carrierExpenseID#&#session.URLToken#&#isCarrier#'">
								<a title="#request.qCarrierExpenses.Description#" href="index.cfm?event=addDriverExpense&driverid=#carrierid#&carrierExpenseID=#request.qCarrierExpenses.carrierExpenseID#&#session.URLToken#&#isCarrier#">#DateFormat(request.qCarrierExpenses.Date, "mm-dd-yyyy")#</a>
							</td>
							
							<td class="normal-td" valign="middle" align="left" onclick="document.location.href='index.cfm?event=addDriverExpense&driverid=#carrierid#&carrierExpenseID=#request.qCarrierExpenses.carrierExpenseID#&#session.URLToken#&#isCarrier#'">
								<a title="#request.qCarrierExpenses.Description#" href="index.cfm?event=addDriverExpense&driverid=#carrierid#&carrierExpenseID=#request.qCarrierExpenses.carrierExpenseID#&#session.URLToken#&#isCarrier#">#request.qCarrierExpenses.Amount#</a>
							</td>

							<td class="normal-td" valign="middle" align="left" onclick="document.location.href='index.cfm?event=addDriverExpense&driverid=#carrierid#&carrierExpenseID=#request.qCarrierExpenses.carrierExpenseID#&#session.URLToken#&#isCarrier#'">
								<a title="#request.qCarrierExpenses.Description#" href="index.cfm?event=addDriverExpense&driverid=#carrierid#&carrierExpenseID=#request.qCarrierExpenses.carrierExpenseID#&#session.URLToken#&#isCarrier#">#request.qCarrierExpenses.Category#</a>
							</td>
							<td height="30px" class="normal-td2" valign="middle" align="center" onclick="document.location.href='index.cfm?event=addDriverExpense&driverid=#carrierid#&carrierExpenseID=#request.qCarrierExpenses.carrierExpenseID#&#session.URLToken#&#isCarrier#'">
	
								<a title="#request.qCarrierExpenses.Description#" href="index.cfm?event=addDriverExpense&driverid=#carrierid#&carrierExpenseID=#request.qCarrierExpenses.carrierExpenseID#&#session.URLToken#&#isCarrier#">#DateFormat(request.qCarrierExpenses.Created, "mm-dd-yyyy")#</a>
						
							</td>	
							<td class="normal-td3">&nbsp;</td> 
						</tr>
					</cfloop>
				</tbody>
				<tfoot>
					<tr>
						<td width="5" align="left" valign="top"><img src="images/left-bot.gif" alt="" width="5" height="23" /></td>
						<td colspan="4" align="left" valign="middle" class="footer-bg">
						<div class="up-down">
						<div class="arrow-top"><a href="##"><img src="images/arrow-top.gif" alt="" /></a></div>
						<div class="arrow-bot"><a href="##"><img src="images/arrow-bot.gif" alt="" /></a></div>
						</div>
						<div class="gen-left"><a onclick="showHiddenExp()">View More</a></div>
						<div class="gen-right"><img src="images/loader.gif" alt="" /></div>
						<div class="clear"></div>
						</td><td width="5" align="right" valign="top"  class="footer-bg">&nbsp;</td><td  class="footer-bg" width="5" align="right" valign="top">&nbsp;</td>
						<td width="5" align="right" valign="top"><img src="images/right-bot.gif" alt="" width="5" height="23" /></td>
					</tr>	
				</tfoot>
			</table><cfelse>
			No #variables.freightBroker# Expenses Found.
		</cfif>

		<div class="clear"></div>
		<div class="white-con-area">
		<div class="addbutton"  style="cursor: pointer;padding-bottom: 8px;"><a href="index.cfm?event=addRecurringExpense&driverid=#url.carrierid#&#session.URLToken#&#isCarrier#">Add Recurring Expense</a></div>	<div class="clear"></div>
		<cfinvoke component="#variables.objequipmentGateway#" method="getRecurringCarrierExpenses" carrierID="#url.carrierid#" returnvariable="request.qRecurringCarrierExpenses" />

			<div class="white-con-area" style="height: 36px;background-color: ##82bbef;margin-bottom: 14px; ">
				<div style="float: left; width: 46%;"><h2 style="color:white;font-weight:bold;margin-left: 12px;">Recurring #variables.freightBroker# Expenses List</h2></div>
			</div>
			<div style="clear:left;"></div>

		<cfif isdefined("message") and len(message)>
			<div class="msg-area" style="margin-top:35px;margin-bottom:11px;">#message#</div>
		</cfif>
		</div>
		<cfif request.qRecurringCarrierExpenses.recordcount>
			<table width="85%" border="0" cellspacing="0" cellpadding="0" class="data-table" id="test">
				<thead>
					<tr>
						<th width="5" align="left" valign="top"><img src="images/top-left.gif" alt="" width="5" height="23" /></th>
						<th align="center" valign="middle" class="head-bg">&nbsp;</th>
						<th align="center" valign="middle" class="head-bg">Description</th>
						<th align="center" valign="middle" class="head-bg">Next Date</th>
						<th align="center" valign="middle" class="head-bg">Amount</th>
						<th align="center" valign="middle" class="head-bg">Category</th>	
						<th align="center" valign="middle" class="head-bg">Interval</th>
						<th width="100px" align="center" valign="middle" class="head-bg2" >Date Created</th>
						<th  align="right" valign="top"><img src="images/top-right.gif" alt="" width="5" height="23" /></th>
					</tr>
				</thead>
				<tbody>
					<cfloop query="request.qRecurringCarrierExpenses">	
						<tr <cfif request.qRecurringCarrierExpenses.currentRow mod 2 eq 0>bgcolor="##FFFFFF"<cfelse>bgcolor="##f7f7f7"</cfif> <cfif request.qRecurringCarrierExpenses.currentRow GT 5>style="display: none;" class="hiddenRecExp"</cfif>>
							<td height="20" class="sky-bg">&nbsp;</td>
							<td class="sky-bg2" valign="middle" align="center">#request.qRecurringCarrierExpenses.currentRow#</td>
							
							<td class="normal-td" valign="middle" align="left" onclick="document.location.href='index.cfm?event=addRecurringExpense&driverid=#carrierid#&carrierExpenseRecurringID=#request.qRecurringCarrierExpenses.carrierExpenseRecurringID#&#session.URLToken#&#isCarrier#'">
								<a title="#request.qRecurringCarrierExpenses.Description#" href="index.cfm?event=addRecurringExpense&driverid=#carrierid#&carrierExpenseRecurringID=#request.qRecurringCarrierExpenses.carrierExpenseRecurringID#&#session.URLToken#&#isCarrier#">#request.qRecurringCarrierExpenses.Description#</a>
							</td>

							<td class="normal-td" valign="middle" align="left" onclick="document.location.href='index.cfm?event=addRecurringExpense&driverid=#carrierid#&carrierExpenseRecurringID=#request.qRecurringCarrierExpenses.carrierExpenseRecurringID#&#session.URLToken#&#isCarrier#'">
								<a title="#request.qRecurringCarrierExpenses.Description#" href="index.cfm?event=addRecurringExpense&driverid=#carrierid#&carrierExpenseRecurringID=#request.qRecurringCarrierExpenses.carrierExpenseRecurringID#&#session.URLToken#&#isCarrier#">#DateFormat(request.qRecurringCarrierExpenses.NextDate, "mm-dd-yyyy")#</a>
							</td>
							
							<td class="normal-td" valign="middle" align="left" onclick="document.location.href='index.cfm?event=addRecurringExpense&driverid=#carrierid#&carrierExpenseRecurringID=#request.qRecurringCarrierExpenses.carrierExpenseRecurringID#&#session.URLToken#&#isCarrier#'">
								<a title="#request.qRecurringCarrierExpenses.Description#" href="index.cfm?event=addRecurringExpense&driverid=#carrierid#&carrierExpenseRecurringID=#request.qRecurringCarrierExpenses.carrierExpenseRecurringID#&#session.URLToken#&#isCarrier#">#request.qRecurringCarrierExpenses.Amount#</a>
							</td>

							<td class="normal-td" valign="middle" align="left" onclick="document.location.href='index.cfm?event=addRecurringExpense&driverid=#carrierid#&carrierExpenseRecurringID=#request.qRecurringCarrierExpenses.carrierExpenseRecurringID#&#session.URLToken#&#isCarrier#'">
								<a title="#request.qRecurringCarrierExpenses.Description#" href="index.cfm?event=addRecurringExpense&driverid=#carrierid#&carrierExpenseRecurringID=#request.qRecurringCarrierExpenses.carrierExpenseRecurringID#&#session.URLToken#&#isCarrier#">#request.qRecurringCarrierExpenses.Category#</a>
							</td>

							<td class="normal-td" valign="middle" align="left" onclick="document.location.href='index.cfm?event=addRecurringExpense&driverid=#carrierid#&carrierExpenseRecurringID=#request.qRecurringCarrierExpenses.carrierExpenseRecurringID#&#session.URLToken#&#isCarrier#'">
								<a title="#request.qRecurringCarrierExpenses.Description#" href="index.cfm?event=addRecurringExpense&driverid=#carrierid#&carrierExpenseRecurringID=#request.qRecurringCarrierExpenses.carrierExpenseRecurringID#&#session.URLToken#&#isCarrier#">#request.qRecurringCarrierExpenses.Interval#</a>
							</td>

							<td height="30px" class="normal-td2" valign="middle" align="center" onclick="document.location.href='index.cfm?event=addRecurringExpense&driverid=#carrierid#&carrierExpenseRecurringID=#request.qRecurringCarrierExpenses.carrierExpenseRecurringID#&#session.URLToken#&#isCarrier#'">
								<a title="#request.qRecurringCarrierExpenses.Description#" href="index.cfm?event=addRecurringExpense&driverid=#carrierid#&carrierExpenseRecurringID=#request.qRecurringCarrierExpenses.carrierExpenseRecurringID#&#session.URLToken#&#isCarrier#">#DateFormat(request.qRecurringCarrierExpenses.Created, "mm-dd-yyyy")#</a>
							</td>	
							<td class="normal-td3">&nbsp;</td> 
						</tr>
					</cfloop>
				</tbody>
				<tfoot>
					<tr>
						<td width="5" align="left" valign="top"><img src="images/left-bot.gif" alt="" width="5" height="23" /></td>
						<td colspan="5" align="left" valign="middle" class="footer-bg">
						<div class="up-down">
						<div class="arrow-top"><a href="##"><img src="images/arrow-top.gif" alt="" /></a></div>
						<div class="arrow-bot"><a href="##"><img src="images/arrow-bot.gif" alt="" /></a></div>
						</div>
						<div class="gen-left"><a onclick="showHiddenRecExp()">View More</a></div>
						<div class="gen-right"><img src="images/loader.gif" alt="" /></div>
						<div class="clear"></div>
						</td><td width="5" align="right" valign="top"  class="footer-bg">&nbsp;</td><td  class="footer-bg" width="5" align="right" valign="top">&nbsp;</td>
						<td width="5" align="right" valign="top"><img src="images/right-bot.gif" alt="" width="5" height="23" /></td>
					</tr>	
				</tfoot>
			</table>
		<cfelse>
			No Recurring #variables.freightBroker# Expenses Found.
		</cfif></div>
		</div>
	</cfif>
</div>
<br/><br/><br/>
<script type="text/javascript">
		function showHiddenExp(){
			$('.hiddenExp').show();
			$('html,body').animate({ scrollTop: 9999 }, 'slow');
		}

		function showHiddenRecExp(){
			$('.hiddenRecExp').show();
			$('html,body').animate({ scrollTop: 9999 }, 'slow');
		}
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
		function openEquipmentPopup(){
			var url='index.cfm?event=addDriverEquipment&#session.URLToken#&IsCarrier=0';
			var h = screen.height;
            var w = screen.width;
            var driver = $('##CarrierName').val();
            url = url + '&equipDriver='+driver;
			newwindow=window.open(url,'name','height='+h +',width='+w +',toolbar=0,scrollbars=0,location=0,statusbar=0,menubar=0,resizable=0');

            if (window.focus) {newwindow.focus()}
            return false;
		}
		$(document).ready(function(){

			<cfif structKeyExists(url, "expmessage")>
				alert('#url.expmessage#');
				$('html,body').animate({ scrollTop: 9999 }, 'slow');
			</cfif>
			$("##frmCarrier").submit(function(){
				$('##isSaveEvent').val('true');
			});


			$('##employeeType').change(function(){
				if($(this).val() != 'ownerOperator'){
					$("##isShowDollar").attr('checked', false);
				}
			})
			
			 $('##mailDocLink').click(function(){
				if($(this).attr('data-allowmail') == 'false')
				alert('You must setup your email address in your profile before you can email documents.');
				else
					mailDocOnClick('#session.URLToken#','carrier'<cfif isDefined("url.carrierid") and len(url.carrierid) gt 1>,'#url.carrierid#'</cfif>);
			 });
			 <cfif NOT ListContains(session.rightsList,'editDrivers',',') AND isdefined("editid") and len(editid) gt 1>
			 	$("input:not([id=Return], [id=currentloads], [id=mailDocLink], [id=editid]),textarea, select").attr('disabled','disabled');
			 	$("input:not([id=Return], [id=currentloads], [id=mailDocLink]),textarea, select").css("cursor", "not-allowed");
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

			if (!$('##CellPhone').val().match(phRegEx)) {
				$('##PreConMethod').val('1');
			  	$("##PreConMethod option:not(:selected)").attr('disabled', true);
			}else{
			  	$("##PreConMethod option:not(:selected)").removeAttr('disabled');
			}
			
			$( "[type='datefield']" ).datepicker({
			  dateFormat: "mm/dd/yy",
			  showOn: "button",
			  buttonImage: "images/DateChooser.png",
			  buttonImageOnly: true,
			  showButtonPanel: true
			});
			$( "[type='datefield']" ).datepicker( "option", "showButtonPanel", true );
               
                var old_goToToday = $.datepicker._gotoToday
                $.datepicker._gotoToday = function(id) {
                 old_goToToday.call(this,id)
                 this._selectDate(id)
                }


		});
</script>
<style>
	.sel_commodityType,.selEquipmentID{
    	float: left;
    	margin-left: 5px;
    }
</style>
</cfoutput>	
