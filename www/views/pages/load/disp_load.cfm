<!---Functuin for triming input string--->
<cfif not structKeyExists(Cookie, "LoadsDaysFilter")>
	<cfcookie name="LoadsDaysFilter" value="30" expires="never">
</cfif>
<cfif not structKeyExists(Cookie, "FilterLoadsByDays")>
	<cfcookie name="FilterLoadsByDays" value="0" expires="never">
</cfif>
<!--- <cfif not structKeyExists(Cookie, "FilterLoadsByStatus")>
	<cfcookie name="FilterLoadsByStatus" value="0" expires="never">
</cfif> --->
<cfif application.dsn NEQ "LoadManagerLive" and structKeyExists(session, "AdminUserName") and session.AdminUserName EQ 'global'>
	<cfif not structKeyExists(Cookie, "SortBy1")>
		<cfcookie name="SortBy1" value="StatusOrder" expires="never">
		<cfcookie name="SortOrder1" value="ASC" expires="never">
	</cfif>
	<cfif not structKeyExists(Cookie, "SortBy2")>
		<cfcookie name="SortBy2" value="l.LoadNumber" expires="never">
		<cfcookie name="SortOrder2" value="ASC" expires="never">
	</cfif>
	<cfif not structKeyExists(Cookie, "SortBy3")>
		<cfcookie name="SortBy3" value="" expires="never">
		<cfcookie name="SortOrder3" value="ASC" expires="never">
	</cfif>
	<cfif structkeyexists(form,"sortBy")>
		<cfcookie name="SortBy1" value="#form.sortBy#" expires="never">
		<cfcookie name="SortOrder1" value="#form.sortOrder#" expires="never">
		<cfcookie name="SortBy2" value="l.LoadNumber" expires="never">
		<cfcookie name="SortOrder2" value="ASC" expires="never">
		<cfcookie name="SortBy3" value="" expires="never">
		<cfcookie name="SortOrder3" value="ASC" expires="never">
	</cfif>
</cfif>
<cfoutput>
<style type="text/css">
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
	##loadernew{
		position: fixed;
		top:40%;
		left:40%;
		z-index: 999;
		display: none;
		width: 200px;
	}
	##loadingmsgnew{
		font-weight: bold;
		text-align: center;
		margin-top: 1px;
		background-color: ##fff;
		padding-bottom: 2px;
		padding-bottom: 2px;
	}
	.li-sort-3:hover{
		background-color: ##DCDCDC;
	}
</style>
<script>

$(document).ready(function(){
	$('.3-sort-li').mouseover(function(){
		if(!$(this).find('.3-sort-ul').is(":visible")){
			$(this).find('.3-sort-ul').show();
		}
	})
	$('.3-sort-li').mouseleave(function(){
		if($(this).find('.3-sort-ul').is(":visible")){
			$(this).find('.3-sort-ul').hide();
		}
	});
})

function updateDaysFilterCookies(){
	var LoadsDaysFilter = $('##daysFilter').val();
	var FilterDays = $('##filterDays').is(":checked");
	$.ajax({
        type    : 'POST',
        url     : "ajax.cfm?event=ajxUpdateDaysFilterCookies&#session.URLToken#",
        data    : {LoadsDaysFilter:$.trim(LoadsDaysFilter),FilterDays:FilterDays,Advanced:0},
        beforeSend:function() {
            $('.overlay').show();
        },
        success :function(response){
            document.location.href='index.cfm?event=#url.event#&#session.URLToken#'
        }
    })
}
$(document).ready(function(){
	var html = "";
	<cfif structKeyExists(session,"qLoadNumbers")>
		$("##responseCopyLoad").html("#trim(session.qLoadNumbers)#");			
		
		$("##responseCopyLoad").dialog({
			resizable: false,
			modal: true,
			title: "Load Copied Successfully",
			height: 170,
			width: 300
		});
		<cfset structDelete(session,"qLoadNumbers")> 
	</cfif>
	$("##postallloadboards").change(function(){
		if($("##postallloadboards").is(':checked')){
			$('##postToIts, ##postdatloadboard, ##posteverywhere, ##post123loadboard, ##postdirectfreight').prop('checked', true);
		}else{
			$('##postToIts, ##postdatloadboard, ##posteverywhere, ##post123loadboard, ##postdirectfreight').prop('checked', false);
		}
	});
	
	$( "[type='datefield']" ).datepicker({
		dateFormat: "mm/dd/yy",
		showOn: "button",
		buttonImage: "images/DateChooser.png",
		buttonImageOnly: true
	});

	//Begin:Ticket:836 Include Carrier Rate.
	$("##postdatloadboard,##postallloadboards").change(function(){
		if(this.checked){
			$('##postCarrierRatetoTranscore').prop("disabled", false);
		}
		else{
			$('##postCarrierRatetoTranscore').prop('checked',false);
			$('##postCarrierRatetoTranscore').prop("disabled", true);
		}
	});
	//End:Ticket:836 Include Carrier Rate.

	var tds = $("##tblLoadListHead").children('th').length;
	$('##tblLoadListFooter').attr('colspan',tds);

	<cfif structKeyExists(url, 'MPalert') and trim(url.MPalert) neq "1">alert("#url.MPalert#");</cfif>

	$("##importCSV").change(function(){
		var formData = new FormData();
		formData.append('file', $('##importCSV')[0].files[0]);

		var path = "ajax.cfm?event=uploadCSV<cfif structKeyExists(session, "iscustomer")>customer</cfif>&#session.URLToken#";

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
		        setTimeout(function(){ alert(jQuery.parseJSON(data).MESSAGE); location.reload();}, 500);
		    },
            beforeSend: function() {
		        $('.overlay').show()
		        $('##loader').show();
		        $('##loadingmsg').show();
		  
		    },
		});

	});

	$('##carrierLanesEmailButton').click(function(){

        if(!$("##carrierLanesEmailButton").data('allowmail')) {
            alert('You must setup your email address in your profile before sending email.');
        } else {
            var ArrCarrierID = ['00000000-0000-0000-0000-000000000000'];
            $(".ckLanes:checked").each(function()
            {	
            	var CarrierID = $(this).data("carrierid");
            	if($.trim(CarrierID).length){
            		ArrCarrierID.push(CarrierID);
            	}
            })
            $('.overlay').show();
            $.ajax({
                type    : 'POST',
                url     : "ajax.cfm?event=ajxSetBulkCarrierID&#session.URLToken#",
                data    : {ArrCarrierID:JSON.stringify(ArrCarrierID)},
                success :function(ts){
                	$('.overlay').hide();
                    carrierLaneAlertEmailOnClick('00000000-0000-0000-0000-000000000000','00000000-0000-0000-0000-000000000000',"#session.URLToken#&BulkCarrierIDTS="+ts);
                }
            })
        }               
    });
});	
function showfullmap(loadid) {
	var h = screen.height;
    var w = screen.width;
    var url ='index.cfm?event=Googlemap&LoadID='+loadid+'&#session.URLToken#'
    newwindow=window.open(url,'name','height='+h +',width='+w +',toolbar=0,scrollbars=0,location=0,statusbar=0,menubar=0,resizable=0');
    if (window.focus) {newwindow.focus()}
    return false; 
}
</script>
</cfoutput>
<cfset variables.Secret = application.dsn>
<cfset variables.TheKey = 'NAMASKARAM'>
<cfset variables.Encrypted = Encrypt(variables.Secret, variables.TheKey)>
<cfset variables.dsn = ToBase64(variables.Encrypted)>
<cfif structkeyexists(session,'iscustomer') AND val(session.iscustomer)>
	<cfset customer = 1>
<cfelse>
	<cfset customer = 0>
</cfif>
<cffunction name="truncateMyString" access="public" returntype="string">

<cfargument name="endindex" type="numeric" required="true"  />
<cfargument name="inputstring" type="string" required="true"  />

	<cfif Len(inputstring) le endindex>
		<cfset inputstring=inputstring.substring(0, Len(inputstring))>
	<cfelse>
		<cfset inputstring=inputstring.substring(0, endindex)>
	</cfif>

	<cfreturn inputstring>
</cffunction>
<!---Functuin for triming input string--->
<cfparam name="message" default="">
<cfparam name="url.linkid" default="">

<cfparam name="url.sortorder" default="ASC">
<cfparam name="sortby"  default="">
<cfparam name="variables.searchTextStored"  default="">
<cfparam name="session.searchtext"  default="">
<cfparam name="variables.pending"  default="0">
<cfparam name="form.searchOffice"  default="">

<cfif structKeyExists(url, "pending") and url.pending EQ 1>
    <cfset variables.pending = 1>
 </cfif>

<cfif StructKeyExists(form,"searchtext")>
	<cfif structkeyexists(form,"rememberSearch")>
		<cfset session.searchtext = form.searchtext>
		<cfset variables.searchTextStored=session.searchtext>
	<cfelse>
		<cfset session.searchtext = "">
		<cfset variables.searchTextStored=form.searchtext>
	</cfif>
<cfelse>
	<cfset variables.searchTextStored=session.searchtext>
</cfif>
<cfinvoke component="#variables.objloadGateway#" method="getLoadStatus" returnvariable="request.qLoadStatus" />
<cfsilent>
<cfinvoke component="#variables.objofficeGateway#" method="getAllOffices" sortby="officecode" sortorder="asc"  returnvariable="request.qOffices" />
<cfinvoke component="#variables.objloadGateway#" method="getLoadSystemSetupOptions" returnvariable="request.qSystemSetupOptions1" />
<cfinvoke component="#variables.objloadGateway#" method="getcurAgentMaildetails" returnvariable="request.qcurMailAgentdetails" employeID="#session.empid#" />
<cfif structkeyexists(session,"empid")>
	<cfinvoke component="#variables.objAgentGateway#" method="getAgentsLoadStatusTypes" agentId="#session.empid#" returnvariable="qAgentsLoadStatusTypes" />	
	<cfset agentsLoadStatusTypesArray = valueList(qAgentsLoadStatusTypes.loadStatusTypeID)>
	<cfinvoke component="#variables.objloadGateway#" method="getSystemSetupOptions" returnvariable="request.qGetSystemSetupOptions" />	
	<cfinvoke component="#variables.objLoadGateway#" method="getLoadStatusTypes" returnvariable="request.qLoadStatusTypes" />
<cfelse>	
	<cfset qAgentsLoadStatusTypes="">
	<cfset agentsLoadStatusTypesArray = "">
</cfif>

<!--- <cfif not structKeyExists(Cookie, "UserAssignedLoadStatusMyLoads")>
	<cfcookie name="UserAssignedLoadStatusMyLoads" value="#agentsLoadStatusTypesArray#" expires="never">
</cfif>
<cfif not structKeyExists(Cookie, "UserAssignedLoadStatusAllLoads")>
	<cfcookie name="UserAssignedLoadStatusAllLoads" value="#agentsLoadStatusTypesArray#" expires="never">
</cfif>
<cfif not structKeyExists(Cookie, "UserAssignedLoadStatusDefault")>
	<cfcookie name="UserAssignedLoadStatusDefault" value="#agentsLoadStatusTypesArray#" expires="never">
</cfif>
 --->
 <cfif request.qcurMailAgentdetails.recordcount gt 0 and (
       (structKeyExists(request.qcurMailAgentdetails, "SmtpAddress") AND request.qcurMailAgentdetails.SmtpAddress eq "") 
    or (structKeyExists(request.qcurMailAgentdetails, "SmtpUsername") AND request.qcurMailAgentdetails.SmtpUsername eq "") 
    or (structKeyExists(request.qcurMailAgentdetails, "SmtpPort") AND request.qcurMailAgentdetails.SmtpPort eq "") 
    or (structKeyExists(request.qcurMailAgentdetails, "SmtpPassword") AND request.qcurMailAgentdetails.SmtpPassword eq "")
    or (structKeyExists(request.qcurMailAgentdetails, "SmtpPort") AND request.qcurMailAgentdetails.SmtpPort eq 0)
    or (structKeyExists(request.qcurMailAgentdetails, "EmailValidated") AND request.qcurMailAgentdetails.EmailValidated eq 0)
    )>
        <cfset mailsettings = "false">
<cfelse>
    <cfset mailsettings = "true">
</cfif>
<cfset pageSize = 30>
<cfif structKeyExists(request.qSystemSetupOptions1, "rowsperpage") AND request.qSystemSetupOptions1.rowsperpage>
	<cfset pageSize = request.qSystemSetupOptions1.rowsperpage>
</cfif>

<!--- Getting page1 of All Results --->
<cfif isdefined('url.event') AND url.event eq 'exportData'>
	<cfinvoke component="#variables.objloadGateway#" method="getSystemSetupOptions" returnvariable="request.qGetSystemSetupOptions" />

	<cfinvoke component="#variables.objloadGateway#" method="getSearchLoads" LoadStatus="#request.qGetSystemSetupOptions.ARAndAPExportStatusID#" searchText="#variables.searchTextStored#" pageNo="1" agentUserName="#request.myLoadsAgentUserName#" rowsperpage="#pageSize#" returnvariable="qLoads" />
<cfelse>
	<cfif structkeyexists(session,"showloadtypestatusonloadsscreen") AND session.showloadtypestatusonloadsscreen EQ 1>
		<cfinvoke component="#variables.objloadGateway#" method="getSearchLoads" searchText="#variables.searchTextStored#" pageNo="1" pending="#variables.pending#" agentUserName="#session.AdminUserName#" rowsperpage="#pageSize#" returnvariable="qLoads" />
	<cfelse>
		<cfinvoke component="#variables.objloadGateway#" method="getSearchLoads" searchText="#variables.searchTextStored#" pageNo="1" pending="#variables.pending#" agentUserName="#request.myLoadsAgentUserName#" rowsperpage="#pageSize#" returnvariable="qLoads" />
	</cfif>
	
</cfif>

<cfif structkeyexists(session,"empid")>
	<cfif len(trim(session.empid))>
		<cfinvoke component="#variables.objloadGateway#" method="getcurAgentdetails" employeID="#session.empid#" returnvariable="request.qrygetAgentdetails" />
	</cfif>
</cfif>

<cfif isdefined("form.searchText")>
	<cfif not structKeyExists(form, "pageNo")>
		<cfset form.pageNo = 1>
	</cfif>
	<cfif structkeyexists(session,"showloadtypestatusonloadsscreen") AND session.showloadtypestatusonloadsscreen EQ 1>
		<cfinvoke component="#variables.objloadGateway#" method="getSearchLoads" pending="#variables.pending#" pageNo="#form.pageNo#" sortorder="#form.sortOrder#" sortby="#form.sortBy#" office="#form.searchOffice#" agentUserName="#session.AdminUserName#" rowsperpage="#pageSize#" returnvariable="qLoads" >
	        <cfinvokeargument name="searchText" value="#form.searchText#">
	        <cfif isdefined('url.event') AND url.event eq 'exportData'>
	        	<cfinvokeargument name="LoadStatus" value="#request.qGetSystemSetupOptions.ARAndAPExportStatusID#">
	        </cfif>
	   </cfinvoke>
	<cfelse>
		<cfinvoke component="#variables.objloadGateway#" method="getSearchLoads" pending="#variables.pending#" pageNo="#form.pageNo#" sortorder="#form.sortOrder#" sortby="#form.sortBy#" office="#form.searchOffice#" agentUserName="#request.myLoadsAgentUserName#" rowsperpage="#pageSize#" returnvariable="qLoads" >
	        <cfinvokeargument name="searchText" value="#form.searchText#">
	        <cfif isdefined('url.event') AND url.event eq 'exportData'>
	        	<cfinvokeargument name="LoadStatus" value="#request.qGetSystemSetupOptions.ARAndAPExportStatusID#">
	        </cfif>
	   </cfinvoke>
   </cfif>
   <cfif qLoads.recordcount lte 0>
		<script> showErrorMessage('block'); </script>
	<cfelse>
    	<script> showErrorMessage('none'); </script>
	</cfif>

   <!--- Handeling Advance Search --->
	<cfelseif isDefined("url.lastweek")>
		<cfset weekOrMonth = "lastweek">
	<cfelseif isDefined("url.thisweek")>
		<cfset weekOrMonth = "thisweek">
	<cfelseif isDefined("url.thismonth")>
		<cfset weekOrMonth = "thismonth">
	<cfelseif isDefined("url.lastmonth")>
		<cfset weekOrMonth = "lastmonth">
	<cfelseif isdefined("form.searchSubmit")>
            <cfset searchSubmitLocal='yes'>
            <cfset LoadStatusAdv = #form.LoadStatusAdv#>
			<cfset ShipperCityAdv = #form.ShipperCityAdv#>
            <cfset ConsigneeCityAdv = #form.ConsigneeCityAdv#>
            <cfset ShipperStateAdv = #form.ShipperStateAdv#>
            <cfset ConsigneeStateAdv = #form.ConsigneeStateAdv#>
            <cfset CustomerNameAdv = #form.CustomerNameAdv#>
            <cfset StartDateAdv = #form.StartDateAdv#>
            <cfset EndDateAdv = #form.EndDateAdv#>
            <cfset orderdateAdv = #form.orderdateAdv#>
            <cfset invoicedateAdv = #form.invoicedateAdv#>
            <cfset CarrierNameAdv = #form.CarrierNameAdv#>
            <cfset CustomerPOAdv = #form.CustomerPOAdv#>
			<cfset LoadBol = #form.txtBol#>
			<cfset carrierDispatcher = #form.txtDispatcher#>
			<cfset carrierAgent = #form.txtAgent#>
			<cfset internalRefAdv = #form.internalRefAdv#>
			<cfset userDefinedForTruckingAdv = #form.userDefinedForTruckingAdv#>
			<cfset EquipmentAdv = #form.EquipmentAdv#>
	<cfelse>

	<cfif isdefined("url.loadid") and len(url.loadid) gt 1>
		<cfinvoke component="#variables.objloadGateway#" method="deleteLoad" loadid="#url.loadid#" returnvariable="session.delMessage" />
		<cflocation url="index.cfm?event=myload&#session.URLToken#">
	</cfif>
	<cfif isdefined('url.carrierId') and len(url.carrierId) gt 1>
		<cfinvoke component="#variables.objloadGateway#" method="getSearchLoads" searchText="#variables.searchTextStored#" pageNo="1" carrierID ='#url.carrierId#' agentUserName="#request.myLoadsAgentUserName#" rowsperpage="#pageSize#" returnvariable="qLoads" />
		
	</cfif>
</cfif>
<!--- Handeling Advance Search Ended --->

</cfsilent>


<link href="file:///D|/loadManagerForDrake/webroot/styles/style.css" rel="stylesheet" type="text/css" />

<cfoutput>
<cfif structKeyExists(session, "showLicenseTerms")>
	<cfinvoke component="#variables.objloadGateway#" method="getLicenseTerms" returnvariable="request.LicenseTerm" />
	<div id="LicenseTerms" style="display: none;">
		<div style="height: 500px;overflow: auto;">
			<p style="font-weight: bold;font-size: 10px;">#htmlcodeformat(request.LicenseTerm)#</p>
		</div>
		<form name="frm_LicenseTermsAccept" id="frm_LicenseTermsAccept" method="post">
			<input type="hidden" value="1" name="LicenseTermsAccepted" id="LicenseTermsAccepted">
			<input type="submit" name="LicenseTermsAccept" value="Accept" style='float: right;'>
		</form>
	</div>
	<script>
		$(document).ready(function(){
			$("##LicenseTerms").dialog({
		        resizable: false,
		        modal: true,
		        title: "License Terms",
		        width: 900,
		        close : function( event, ui ){
		        	$('##LicenseTermsAccepted').val(0);
					$('##frm_LicenseTermsAccept').submit();
				}
		    });
		})
	</script>
</cfif>
<cfif isdefined('url.carrierId') and len(url.carrierId) gt 1>
	<cfinvoke component="#variables.objCarrierGateway#" carrierid="#url.carrierId#" method="getAllCarriers" returnvariable="request.qCarrier" />
	<cfinvoke component="#variables.objloadGateway#" method="getSearchLoads" searchText="#request.qCarrier.CarrierName#" pageNo="1" carrierID ='#url.carrierId#' agentUserName="#request.myLoadsAgentUserName#" rowsperpage="#pageSize#" returnvariable="qLoads" />
	<cfif request.qCarrier.recordcount >
		<cfset session.searchtext = request.qCarrier.CarrierName>
	</cfif>
	<cfif request.qCarrier.recordcount  gt 0>
		<h1>#request.qCarrier.CarrierName# Loads</h1>
	</cfif>
<cfelseif isdefined('url.event') AND url.event eq 'exportData'>
	<h1>Loads Ready To Be Exported</h1>
	<div style="clear:left;"></div>
<cfelseif isdefined('url.event') AND url.event eq 'myLoad'>
	<h1 style="padding: 0;">My Loads</h1>
	<div style="clear:left;"></div>
<cfelseif isdefined('url.event') AND url.event eq 'dispatchboard'>
	<h1>Dispatch Board</h1>
	<div style="clear:left;"></div>
<cfelse>
	<cfif structKeyExists(url, "pending")>
		<h1>Loads with missing <a target="_blank" style="text-decoration: underline;" href="index.cfm?event=attachmentTypes&#session.URLToken#">Attachments</a></h1>
	<cfelse>
		<h1>All Loads</h1>
	</cfif>
	<div style="clear:left;"></div>
</cfif>
<div id="message" class="msg-area" style="display:none; width:199px; margin: 0 0;">No match found</div>

<cfif structKeyExists(session,"message") AND session.message NEQ "" >
	<div class="col-md-12">&nbsp;</div>
	<div id="messageLoadsExportedForCustomer" class="msg-area">#session.message#</div>
	<cfset session.message = "">
</cfif>
<div id="messageLoadsExportedForCustomer" class="msg-area" style="display:none;width:199px; margin: 0 0;"></div>
<div id="messageLoadsExportedForCarrier" class="msg-area" style="display:none;width:199px; margin: 0 0;"></div>
<div id="messageLoadsExportedForBoth" class="msg-area" style="display:none;width:199px; margin: 0 0;"></div>
<div id="messageWarning" class="errormsg-area" style="display:none;width:199px; margin: 0 0;"></div>

<div class="search-panel" style="width:100%;">
    <div class="form-search">


<cfif isdefined('url.event') AND url.event eq 'addload:process'>
	<cfset actionUrl = 'index.cfm?event=load&#session.URLToken#'>
<cfelse>
	<cfset actionUrl = 'index.cfm?event=#url.event#&#session.URLToken#'>
</cfif>

<cfif structKeyExists(url, "pending") and url.pending EQ 1>
	<cfset actionUrl &= "&pending=1"> 
</cfif>

<cfset csrfToken=CSRFGenerateToken() />
<cfform id="dispLoadForm" name="dispLoadForm" action="#actionUrl#" method="post" preserveData="yes">
	<cfinput id="pageNo" name="pageNo" value="1" type="hidden">
    <cfinput id="sortOrder" name="sortOrder" value="ASC"  type="hidden">
    <cfinput id="sortBy" name="sortBy" value="StatusOrder"  type="hidden">
    <cfinput id="LoadStatusAdv" name="LoadStatusAdv" value="" type="hidden">
    <cfinput id="LoadNumberAdv" name="LoadNumberAdv" value="" type="hidden">
	<cfinput id="OfficeAdv" name="OfficeAdv" value="" type="hidden">
	<cfinput id="shipperCityAdv" name="shipperCityAdv" value="" type="hidden">
    <cfinput id="consigneeCityAdv" name="consigneeCityAdv" value="" type="hidden">
    <cfinput id="ShipperStateAdv" name="ShipperStateAdv" value="" type="hidden">
    <cfinput id="ConsigneeStateAdv" name="ConsigneeStateAdv" value="" type="hidden">
    <cfinput id="CustomerNameAdv" name="CustomerNameAdv" value="" type="hidden">
    <cfinput id="StartDateAdv" name="StartDateAdv" value="" type="hidden">
    <cfinput id="EndDateAdv" name="EndDateAdv" value="" type="hidden">
    <cfinput id="CarrierNameAdv" name="CarrierNameAdv" value="" type="hidden">
    <cfinput id="CustomerPOAdv" name="CustomerPOAdv" value="" type="hidden">
    <cfinput id="weekMonth" name="weekMonth" value="" type="hidden">
	<cfinput id="txtBol" name="txtBol" value="" type="hidden">
	<cfinput id="txtDispatcher" name="txtDispatcher" value="" type="hidden">
	<cfinput id="txtAgent" name="txtAgent" value="" type="hidden">
	<cfinput id="csfrToken" name="csfrToken" value="#csrfToken#" type="hidden">

	<cfinput id="orderdateAdv" name="orderdateAdv" value="" type="hidden">
	<cfinput id="invoicedateAdv" name="invoicedateAdv" value="" type="hidden">
	<cfinput id="internalRefAdv" name="internalRefAdv" value="" type="hidden">
	<cfinput id="userDefinedForTruckingAdv" name="userDefinedForTruckingAdv" value="" type="hidden">
	<cfinput id="EquipmentAdv" name="EquipmentAdv" value="" type="hidden">
	<fieldset >

	<cfif request.qSystemSetupOptions1.LoadsColumnsSetting EQ 1>
		<cfset placeHolderTxt = "Load##, Driver,TRK ##,TRL ##,Customer,.....">
		<cfset titleTxt = "Load##, Driver,TRK ##,TRL ##,Customer,Shipper,Commidity,Consignee,DelTime..">
	<cfelse>
		<cfset placeHolderTxt = "Load##, Status, Customer, PO##, BOL##, Carr......">
		<cfset titleTxt = "Load##, Status, Customer, PO##, BOL##, Carrier, City, State, Dispatcher ">
			<cfif request.qSystemSetupOptions1.freightBroker>
				<cfset titleTxt = titleTxt&"OR Sales Rep">
			<cfelse>
				<cfset titleTxt =  titleTxt&"OR"&left(request.qSystemSetupOptions1.userDef7,9) >
			</cfif>
			<cfset titleTxt =  titleTxt&",shipdate">
	</cfif>
	<cfinvoke component="#variables.objloadGateway#" method="getSystemSetupOptions" returnvariable="request.qGetSystemSetupOptions" />
	<input type="hidden" name="LoadNumberAutoIncrement" id="LoadNumberAutoIncrement" value="#request.qGetSystemSetupOptions.LoadNumberAutoIncrement#">
	<cfif ListContains(session.rightsList,'ShowOfficeFilter',',')>
		<label style="width: 31px;">Office</label>
		<select onchange="this.form.submit()" name="searchOffice" style="border: 1px solid ##b3b3b3;height: 21px;font: 11px/16px Arial,Helvetica,sans-serif !important;">
			<option value="">ALL Offices</option>
			<cfloop query="request.qOffices">
				<option value="#request.qOffices.officeid#" <cfif structKeyExists(form, "searchOffice") and form.searchOffice EQ request.qOffices.officeid> selected </cfif>>#request.qOffices.officecode#</option>
			</cfloop>
		</select>
	<cfelse>
		<input type="hidden" name="searchOffice" value="">
	</cfif>
	<div class="clear" style="margin-bottom: 5px;"></div>
	<input name="searchText"  style="width:224px;" type="text" placeholder="#placeHolderTxt#" value="#variables.searchTextStored#" id="searchText"  class="InfotoolTip" title="#titleTxt#" />
	
	<input name="exactMatchSearch" type="checkbox" class="s-bttn" value="1" id="exactMatchSearch" style="width: 15px;margin-left: 15px;margin-top: 3px;"/>
	<div style="margin-left: 6px; margin-top: 5px;float: left;color: ##3a5b96;;">Exact Match</div>
	
	

	<div class="clear"></div>
    <cfif isdefined('url.event') AND url.event eq 'exportData'>
        <div class="float-left"><label>Date From</label>
        <input class="" name="orderDateFrom" id="orderDateFrom" value="#dateformat('01/01/1900','mm/dd/yyyy')#" type="datefield" style="width:55px;margin-right:10px;"/></div>

        <div class="float-left"><label>Date To</label>
        <input class="" name="orderDateTo" id="orderDateTo" value="#dateformat(NOW(),'mm/dd/yyyy')#" type="datefield" style="width:55px;margin-right:10px;"/></div>
    </cfif>
	<div class="clear"></div>
	</fieldset>
	<fieldset>
		<input name="" onclick="clearPreviousSearchHiddenFields()" type="submit" class="s-bttn" value="Search" style="width:56px;margin-left: 0px;height: 40px;background-size: contain;" />
    	<input name="rememberSearch" type="checkbox" class="s-bttn" value="" <cfif session.searchtext neq "">checked="true"</cfif> id="rememberSearch" style="width: 15px;margin-left: 15px;margin-top: 3px;" onclick="rememberSearchSession(this);" />
		<div style="margin-left: 6px; margin-top: 5px;float: left;color: ##3a5b96;;">Remember Search</div>
		<input name="filterStatus" type="checkbox" class="s-bttn" value="" <cfif structKeyExists(session, "showloadtypestatusonloadsscreen") and session.showloadtypestatusonloadsscreen EQ 1>checked="true"</cfif> id="filterStatus" style="width: 15px;margin-left: 15px;margin-top: 3px;" onclick="FilterStatus(this);" />
		<div style="margin-left: 6px; margin-top: 5px;float: left;color: ##3a5b96;;">Filter by Status</div>
		<div class="clear"></div>
		<input name="filterDays" type="checkbox" class="s-bttn" value="" <cfif structKeyExists(cookie, "FilterLoadsByDays") and cookie.FilterLoadsByDays EQ 1>checked="true"</cfif> id="filterDays" style="width: 15px;margin-left: 140px;margin-top: -16px;" onclick="updateDaysFilterCookies();" />
		<div style="margin-left: 6px; margin-top: -13px;float: left;color: ##3a5b96;">Filter Loads for the last</div>
		<input style="width: 20px;margin-left: 10px;margin-top: -13px;<cfif NOT (structKeyExists(cookie, "FilterLoadsByDays") and cookie.FilterLoadsByDays EQ 1)>background-color: ##e3e3e3;</cfif>" name="daysFilter" id="daysFilter" value="#cookie.LoadsDaysFilter#" onkeyup="if (/\D/g.test(this.value)) this.value = this.value.replace(/\D/g,'')" onchange="updateDaysFilterCookies();" <cfif NOT (structKeyExists(cookie, "FilterLoadsByDays") and cookie.FilterLoadsByDays EQ 1)>disabled</cfif>>
		<div style="margin-left: 6px; margin-top: 5px;float: left;color: ##3a5b96;margin-top: -13px;">Days</div>

		<cfif structKeyExists(session, "delMessage")and len(session.delMessage)>
			<div id="delMessage" class="msg-area" style="float: left;margin-left: 10px;margin-bottom: 2px;">#session.delMessage#</div>
			<cfset structDelete(session, "delMessage")>
		</cfif>
	</fieldset>
</cfform>

	<cfif isdefined('weekOrMonth') AND weekOrMonth neq "">
    	<cfset form.weekMonth = '#weekOrMonth#'>
        <script> document.getElementById('weekMonth').value='#weekOrMonth#' </script>
    </cfif>

    <cfif isdefined("form.weekMonth") AND form.weekMonth neq "">

		<cfinvoke component="#variables.objloadGateway#" method="getSearchLoads" agentUserName="#request.myLoadsAgentUserName#" rowsperpage="#pageSize#" returnvariable="qLoads">
       		<cfinvokeargument name="#form.weekMonth#" value="#form.weekMonth#">
       		<cfif isdefined('form.pageNo')>
        		<cfinvokeargument name="pageNo" value="#form.pageNo#">
	        <cfelse>
		        <cfinvokeargument name="pageNo" value="1">
        	    <cfset form.pageNo = 1>
        	</cfif>

            <cfif isdefined('form.sortOrder')>
	            <cfinvokeargument name="sortorder" value="#form.sortOrder#">
            </cfif>
            <cfif isdefined('form.sortBy')>
	            <cfinvokeargument name="sortby" value="#form.sortBy#">
            </cfif>

		</cfinvoke>
	</cfif>

	<cfif isdefined('searchSubmitLocal') AND (searchSubmitLocal eq 'yes')>
        <cfset form.LoadStatusAdv = '#LoadStatusAdv#'>
		<cfset form.shipperCityAdv = '#shipperCityAdv#'>
        <cfset form.consigneeCityAdv = '#consigneeCityAdv#'>
        <cfset form.ShipperStateAdv = '#ShipperStateAdv#'>
        <cfset form.ConsigneeStateAdv = '#ConsigneeStateAdv#'>
        <cfset form.CustomerNameAdv = '#CustomerNameAdv#'>
        <cfset form.StartDateAdv = '#StartDateAdv#'>
        <cfset form.EndDateAdv = '#EndDateAdv#'>
        <cfset form.orderdateAdv = '#orderdateAdv#'>
        <cfset form.invoicedateAdv = '#invoicedateAdv#'>
        <cfset form.CarrierNameAdv = '#CarrierNameAdv#'>
        <cfset form.CustomerPOAdv = '#CustomerPOAdv#'>
		<cfset form.txtBol = '#LoadBol#'>
		<cfset form.txtDispatcher  = '#carrierDispatcher#'>
		<cfset form.txtAgent  = '#carrierAgent#'>
		<cfset form.internalRefAdv  = '#internalRefAdv#'>
		<cfset form.userDefinedForTruckingAdv  = '#userDefinedForTruckingAdv#'>
		<cfset form.EquipmentAdv  = '#EquipmentAdv#'>
    </cfif>

    <!--- Query for Advance Search and Advance Search Pagination --->
	<cfif (isdefined("form.LoadStatusAdv") AND form.LoadStatusAdv neq "")
	OR (isdefined("form.shipperCityAdv") AND form.shipperCityAdv neq "")
	OR (isdefined("form.consigneeCityAdv") AND form.consigneeCityAdv neq "")
	OR (isdefined("form.ShipperStateAdv") AND form.ShipperStateAdv neq "")
	OR (isdefined("form.ConsigneeStateAdv") AND form.ConsigneeStateAdv neq "")
	OR (isdefined("form.CustomerNameAdv") AND form.CustomerNameAdv neq "")
	OR (isdefined("form.StartDateAdv") AND form.StartDateAdv neq "")
	OR (isdefined("form.EndDateAdv") AND form.EndDateAdv neq "")
	OR (isdefined("form.invoicedateAdv") AND form.invoicedateAdv neq "")
	OR (isdefined("form.orderdateAdv") AND form.orderdateAdv neq "")
	OR (isdefined("form.CarrierNameAdv") AND form.CarrierNameAdv neq "")
	OR (isdefined("form.CustomerPOAdv") AND form.CustomerPOAdv neq "")
	OR (isdefined("form.txtBol") AND form.txtBol neq "")
	OR (isdefined("form.txtDispatcher") AND form.txtDispatcher neq "")
	OR (isdefined("form.txtAgent") AND form.txtAgent neq "")
	OR (isdefined("form.internalRefAdv") AND form.internalRefAdv neq "")
	OR (isdefined("form.userDefinedForTruckingAdv") AND form.userDefinedForTruckingAdv neq "")
	OR (isdefined("form.EquipmentAdv") AND form.EquipmentAdv neq "")
	>

        <cfinvoke component="#variables.objloadGateway#" method="getSearchLoads" agentUserName="#request.myLoadsAgentUserName#" rowsperpage="#pageSize#" returnvariable="qLoads">
			<cfinvokeargument name="LoadStatus" value="#form.LoadStatusAdv#">
            <cfinvokeargument name="LoadNumber" value="">
            <cfinvokeargument name="Office" value="">
			<cfinvokeargument name="shipperCity" value="#form.shipperCityAdv#">
            <cfinvokeargument name="consigneeCity" value="#form.consigneeCityAdv#">
            <cfinvokeargument name="ShipperState" value="#form.ShipperStateAdv#">
            <cfinvokeargument name="ConsigneeState" value="#form.ConsigneeStateAdv#">
            <cfinvokeargument name="CustomerName" value="#form.CustomerNameAdv#">
            <cfinvokeargument name="StartDate" value="#form.StartDateAdv#">
            <cfinvokeargument name="EndDate" value="#form.EndDateAdv#">
            <cfinvokeargument name="CarrierName" value="#form.CarrierNameAdv#">
            <cfinvokeargument name="CustomerPO" value="#form.CustomerPOAdv#">
            <cfinvokeargument name="bol" value="#form.txtBol#">
            <cfinvokeargument name="dispatcher" value="#form.txtDispatcher#">
            <cfinvokeargument name="agent" value="#form.txtAgent#">

            <cfinvokeargument name="orderdateAdv" value="#form.orderdateAdv#">
            <cfinvokeargument name="invoicedateAdv" value="#form.invoicedateAdv#">
            <cfinvokeargument name="internalRefAdv" value="#form.internalRefAdv#">
            <cfinvokeargument name="userDefinedForTruckingAdv" value="#form.userDefinedForTruckingAdv#">
            <cfinvokeargument name="EquipmentAdv" value="#form.EquipmentAdv#">
            
            <cfif isdefined('form.pageNo')>
	            <cfinvokeargument name="pageNo" value="#form.pageNo#">
            <cfelse>
            	<cfinvokeargument name="pageNo" value="1">
            </cfif>

            <cfif isdefined('form.sortOrder')>
	            <cfinvokeargument name="sortorder" value="#form.sortOrder#">
            </cfif>
            <cfif isdefined('form.sortBy')>
	            <cfinvokeargument name="sortby" value="#form.sortBy#">
            </cfif>

		</cfinvoke>
	</cfif>


</div>



   	<cfif isdefined('url.event') AND url.event eq 'exportData'>
    	<div id="exportLink" class="exportbutton">
       		<a href="javascript:exportLoads('#application.QBdsn#','#application.dsn#','#request.webpath#','#session.URLToken#')" onclick="document.getElementById('exportLink').className = 'busyButton';">Export ALL</a>
        </div>
    <cfelseif Not structKeyExists(session, "IsCustomer")>

    <!---add new link for dispatch board--->

		<cfif isdefined('url.event') and url.event eq 'dispatchboard'>

            <div class="addbutton">
                <a href="#addLoadUrl#">Add New</a>
            </div>

         <cfelse>
         <!---add new link for load/my load--->
            <div class="addbutton">
                <a href="#addLoadUrl#">Add New</a>
            </div>
         </cfif>
    <cfelseif  structKeyExists(session, "IsCustomer")>
    	<div class="addbutton">
            <a href="#addLoadUrl#">Add New</a>
        </div>
    </cfif>
</div>
<div class="clear"></div>

<cfif isdefined('url.event') and url.event eq 'dispatchboard'>
<cfinvoke component="#variables.objLoadGateway#" method="getLoadStatusTypes" returnvariable="qLoadStatusTypes" />
	<cfinvoke component="#variables.objAgentGateway#" method="getAgentsLoadStatusTypesByLoginID" agentLoginId="#session.AdminUserName#" returnvariable="qAgentsLoadStatusTypes" />

<cfquery name="qLoadsDistinceStatus" dbtype="query">
	SELECT DISTINCT statusText, statustypeid, colorCode
	FROM qLoads
</cfquery>

	<table>
	  <tr>
		<td align="center">
			<label style="font-size:14px;  font-weight:bold">
				<cfset isFirstMatch = 'yes'>
				<cfloop query="qLoadsDistinceStatus">
					<cfquery dbtype="query" name="qIsLeftSideRecord">
						SELECT *
						FROM qAgentsLoadStatusTypes
						WHERE loadStatusTypeID = <cfqueryparam value="#qLoadsDistinceStatus.STATUSTYPEID#" cfsqltype="cf_sql_varchar">
					</cfquery>
					<cfif qIsLeftSideRecord.RecordCount NEQ 0>
						<cfif isFirstMatch EQ 'no'>, </cfif>
						<cfset isFirstMatch = 'no'>
						<font style="color:###qLoadsDistinceStatus.colorCode#">#qLoadsDistinceStatus.statustext# </font>
					</cfif>
				</cfloop>
			</label>
		</td>
		<td>&nbsp;</td>
		<td align="center">
			<label style="font-size:14px;  font-weight:bold">
				<cfset isFirstMatch = 'yes'>
				<cfloop query="qLoadsDistinceStatus">
					<cfquery dbtype="query" name="qIsLeftSideRecord">
						SELECT *
						FROM qAgentsLoadStatusTypes
						WHERE loadStatusTypeID = <cfqueryparam value="#qLoadsDistinceStatus.STATUSTYPEID#" cfsqltype="cf_sql_varchar">
					</cfquery>
					<cfif qIsLeftSideRecord.RecordCount NEQ 0>
						<cfif isFirstMatch EQ 'no'>, </cfif>
						<cfset isFirstMatch = 'no'>
						<font style="color:###qLoadsDistinceStatus.colorCode#">#qLoadsDistinceStatus.statustext# </font>
					</cfif>
				</cfloop>
			</label>
		</td>
	  </tr>
	  <tr>
		<td style="vertical-align:top;">
			<table style="width:100%; font-weight:bold; font-size:9px;"  border="0" cellspacing="0" cellpadding="0" class="data-table">
				<tr class="glossy-bg-blue">
					<td width="5" align="left" valign="top" class="sky-bg"><img src="images/head-bg.gif" alt="" width="5" height="23" /></td>
					<td colspan="13" align="left" valign="middle" class="footer-bg">
						<div class="up-down">
							<div class="arrow-top"><a href="javascript: tablePrevPage('dispLoadForm');"><img src="images/arrow-top.gif" alt="" /></a></div>
							<div class="arrow-bot"><a href="javascript: tableNextPage('dispLoadForm');"><img src="images/arrow-bot.gif" alt="" /></a></div>
						</div>
						<div class="gen-left"><a href="javascript: tablePrevPage('dispLoadForm');">Prev </a>-
						<a href="javascript: tableNextPage('dispLoadForm');"> Next</a></div>
						<div class="gen-right"></div>
						<div class="clear"></div>
					</td>
					<td width="5" align="right" valign="top" class="sky-bg"><img src="images/head-bg.gif" alt="" width="5" height="23" /></td>
				 </tr>
			</table>
			<table style="width:100%; font-weight:bold; font-size:9px;"  border="0" cellspacing="0" cellpadding="0" class="data-table">
			  <thead>
				  <tr>
				  	<th width="5" align="left" valign="top" class="sky-bg"></th>
					<th align="center" valign="middle" class="head-bg" onclick="sortTableBy('l.LoadNumber','dispLoadForm');">LOAD##</th>
					<th align="center" valign="middle" class="head-bg" onclick="sortTableBy('statusText','dispLoadForm');">STATUS</th>
					<th align="center" valign="middle" class="head-bg" onclick="sortTableBy('CustName','dispLoadForm');">CUSTOMER</th>
					<th align="center" valign="middle" class="head-bg" onclick="sortTableBy('NewPickupDate','dispLoadForm');">SHIP</th>
					<th align="center" valign="middle" class="head-bg" onclick="sortTableBy('l.shipperCity','dispLoadForm');">S.CITY</th>
					<th align="center" valign="middle" class="head-bg" onclick="sortTableBy('l.shipperState','dispLoadForm');">ST</th>
					<th align="center" valign="middle" class="head-bg" onclick="sortTableBy('consigneeCity','dispLoadForm');">C.CITY</th>
					<th align="center" valign="middle" class="head-bg" onclick="sortTableBy('consigneeState','dispLoadForm');">ST</th>
					<th align="center" valign="middle" class="head-bg" onclick="sortTableBy('NewDeliveryDate','dispLoadForm');">DELIVERY</th>
					<cfif NOT ListContains(session.rightsList,'HideCustomerPricing',',')>
						<th align="right" valign="middle" class="head-bg" onclick="sortTableBy('TotalCustomerCharges','dispLoadForm');">CUST AMT</th>
					</cfif>
					<th align="center" valign="middle" class="head-bg" onclick="sortTableBy('CarrierName','dispLoadForm');">
						<cfif request.qSystemSetupOptions1.freightBroker>
							CARRIER
						<cfelse>
							DRIVER
						</cfif>
					</th>
					<th align="right" valign="middle" class="head-bg2" onclick="sortTableBy('CarrierName','dispLoadForm');">Carr.Amt</th>
					<th width="5" align="right" valign="top"><img src="images/top-right.gif" alt="" width="5" height="23" /></th>
				  </tr>
			  </thead>
			  <tbody>

			  	 <cfif qLoads.recordcount eq 0>
					<script> showErrorMessage('block'); </script>
				<cfelse>
					<script> showErrorMessage('none'); </script>

				<cfloop query="qLoads">
					<cfquery dbtype="query" name="qIsLeftSideRecord">
						SELECT *
						FROM qAgentsLoadStatusTypes
						WHERE loadStatusTypeID = <cfqueryparam value="#qLoads.STATUSTYPEID#" cfsqltype="cf_sql_varchar">
					</cfquery>
					<cfif qIsLeftSideRecord.RecordCount EQ 0>
						<cfcontinue>
					</cfif>

					<cfif isdefined('url.event') AND url.event eq 'exportData' AND qLoads.ARExportedNN eq '1' AND qLoads.APExportedNN eq '1' >
						<cfcontinue>
					<cfelseif isdefined('url.event') AND url.event eq 'exportData'>
						<cfif not isdefined('form.orderDateFrom')>
							<cfset dateFrom = DateFormat('01/01/1900','mm/dd/yyyy')>
						<cfelse>
							<cfset dateFrom = DateFormat(form.orderDateFrom,'mm/dd/yyyy')>
						</cfif>

						<cfif not isdefined('form.orderDateTo')>
							<cfset dateTo = DateFormat(NOW(),'mm/dd/yyyy')>
						<cfelse>
							<cfset dateTo = DateFormat(form.orderDateTo,'mm/dd/yyyy')>
						</cfif>

						<cfif not isdefined('request.qLoads.orderDate') OR request.qLoads.orderDate eq ''>
							<cfset orderDate = DateFormat(NOW(),'mm/dd/yyyy')>
						<cfelse>
							<cfset orderDate = DateFormat(qLoads.orderDate,'mm/dd/yyyy')>
						</cfif>

						<cfif orderDate gte dateFrom AND orderDate lte dateTo>
							<!--- Do nothing, keep the normal flow --->
						<cfelse>
							<cfcontinue>
						</cfif>
					</cfif>
					<cfset request.ShipperStop = qLoads>
					<cfset request.ConsineeStop = qLoads>
					<cfinvoke component="#variables.objCutomerGateway#" method="getAllCustomers" CustomerID="#qLoads.PAYERID#" returnvariable="request.qCustomer" />
					<cfinvoke component="#variables.objloadGateway#" method="getLoadStatus" LoadStatusID="#qLoads.statusTypeID#" returnvariable="request.qLoadStatus" />


					<cfset pageSize = 30>
					<cfif isdefined("form.pageNo")>
						<cfset rowNum=(qLoads.currentRow) + ((form.pageNo-1)*pageSize)>
					<cfelse>
						<cfset rowNum=(qLoads.currentRow)>
					</cfif>
			  		<cfif ListContains(session.rightsList,'editLoad',',')>
						<cfset onRowClick = "document.location.href='index.cfm?event=addload&loadid=#qLoads.LOADID#&#session.URLToken#'">
					<cfelse>
						<cfif structKeyExists(session, "IsCustomer")>
							<cfset onRowClick = "document.location.href='index.cfm?event=addcustomerload&loadid=#qLoads.LOADID#&#session.URLToken#'">
						</cfif>
					</cfif>


				  <tr style="background:###request.qLoadStatus.ColorCode#; cursor:pointer;" onmouseover="this.style.background = '##FFFFFF';" onmouseout="this.style.background = '###request.qLoadStatus.ColorCode#';" onclick="#onRowClick#" <cfif qLoads.Row mod 2 eq 0>bgcolor="##FFFFFF"<cfelse>bgcolor="##f7f7f7"</cfif>>
					<td height="20" class="sky-bg">&nbsp;</td>

					<td width="40px" align="center" valign="middle" nowrap="nowrap" class="normal-td">#qLoads.loadNumber#</td>
					<td width="50px" align="left" valign="middle" nowrap="nowrap" class="normal-td" title="#qLoads.statusText#">#truncateMyString(6,qLoads.statusText)#</td>
					<td width="70px" align="left" valign="middle" nowrap="nowrap" class="normal-td" title="#request.qCustomer.customerName#">#truncateMyString(9, request.qCustomer.customerName)#</td>
					<td width="55px" align="left" valign="middle" nowrap="nowrap" class="normal-td" >#dateformat(qLoads.PICKUPDATE,'m/d/yy')#</td>
					<td width="55px" align="left" valign="middle" nowrap="nowrap" class="normal-td" title="#request.ShipperStop.shippercity#">#truncateMyString(9, request.ShipperStop.shippercity)#</td>
					<td width="20px" align="left" valign="middle" nowrap="nowrap" class="normal-td" >#request.ShipperStop.shipperState#</td>
					<td width="55px" align="left" valign="middle" nowrap="nowrap" class="normal-td" title="#request.ConsineeStop.consigneeCity#">#truncateMyString(9,request.ConsineeStop.consigneeCity)#</td>
					<td width="20px" align="left" valign="middle" nowrap="nowrap" class="normal-td" >#request.ConsineeStop.consigneeState#</td>
					<td width="55px" align="left" valign="middle" nowrap="nowrap" class="normal-td">#dateformat(qLoads.DeliveryDATE,'m/d/yy')#</td>
					<cfif NOT ListContains(session.rightsList,'HideCustomerPricing',',')>
						<td width="60px" align="right" valign="middle" nowrap="nowrap" class="normal-td" >#NumberFormat(qLoads.TOTALCUSTOMERCHARGES,'$')#</td>
					</cfif>
					<td width="70px" align="left" valign="middle" nowrap="nowrap" class="normal-td" title="#qLoads.CARRIERNAME#">#truncateMyString(10,qLoads.CARRIERNAME)#</td>
					<td width="70px" align="right" valign="middle" nowrap="nowrap" class="normal-td2" >#NumberFormat(qLoads.TOTALCARRIERCHARGES,'$')#</td>
					<td class="normal-td3">&nbsp;</td>
				  </tr>
    	 </cfloop>
    	 </cfif>
			  </tbody>
			  <tfoot>
				 <tr>
					<td width="5" align="left" valign="top"><img src="images/left-bot.gif" alt="" width="5" height="23" /></td>
					<td colspan="13" align="left" valign="middle" class="footer-bg">
						<div class="up-down">
							<div class="arrow-top"><a href="javascript: tablePrevPage('dispLoadForm');"><img src="images/arrow-top.gif" alt="" /></a></div>
							<div class="arrow-bot"><a href="javascript: tableNextPage('dispLoadForm');"><img src="images/arrow-bot.gif" alt="" /></a></div>
						</div>
						<div class="gen-left"><a href="javascript: tablePrevPage('dispLoadForm');">Prev </a>-
						<a href="javascript: tableNextPage('dispLoadForm');"> Next</a></div>
						<div class="gen-right"><img src="images/loader.gif" alt="" /></div>
						<div class="clear"></div>
					</td>
					<td width="5" align="right" valign="top"><img src="images/right-bot.gif" alt="" width="5" height="23" /></td>
				 </tr>
				 </tfoot>
			  </table>
		</td>
		<td>&nbsp;</td>
		<td style="vertical-align:top;"><!---2nd Table--->
			<table style="width:100%; font-weight:bold; font-size:9px;"  border="0" cellspacing="0" cellpadding="0" class="data-table">
				<tr>
					<td width="5" align="left" valign="top" class="sky-bg"><img src="images/head-bg.gif" alt="" width="5" height="23" /></td>
					<td colspan="13" align="left" valign="middle" class="footer-bg">
						<div class="up-down">
							<div class="arrow-top"><a href="javascript: tablePrevPage('dispLoadForm');"><img src="images/arrow-top.gif" alt="" /></a></div>
							<div class="arrow-bot"><a href="javascript: tableNextPage('dispLoadForm');"><img src="images/arrow-bot.gif" alt="" /></a></div>
						</div>
						<div class="gen-left"><a href="javascript: tablePrevPage('dispLoadForm');">Prev </a>-
						<a href="javascript: tableNextPage('dispLoadForm');"> Next</a></div>
						<div class="gen-right"></div>
						<div class="clear"></div>
					</td>
					<td width="5" align="right" valign="top" class="sky-bg"><img src="images/head-bg.gif" alt="" width="5" height="23" /></td>
				 </tr>
			</table>
			<table style="width:100%; font-weight:bold; font-size:9px;"  border="0" cellspacing="0" cellpadding="0" class="data-table">
			  <thead>
				  <tr>
					<th width="5" align="left" valign="top"><img src="images/top-left.gif" alt="" width="5" height="23" /></th>
					<th align="center" valign="middle" class="head-bg" onclick="sortTableBy('l.LoadNumber','dispLoadForm');">LOAD##</th>
					<th align="center" valign="middle" class="head-bg" onclick="sortTableBy('statusText','dispLoadForm');">STATUS</th>
					<th align="center" valign="middle" class="head-bg" onclick="sortTableBy('CustName','dispLoadForm');">CUSTOMER</th>
					<th align="center" valign="middle" class="head-bg" onclick="sortTableBy('NewPickupDate','dispLoadForm');">SHIP</th>
					<th align="center" valign="middle" class="head-bg" onclick="sortTableBy('l.shipperCity','dispLoadForm');">S.CITY</th>
					<th align="center" valign="middle" class="head-bg" onclick="sortTableBy('l.shipperState','dispLoadForm');">ST</th>
					<th align="center" valign="middle" class="head-bg" onclick="sortTableBy('l.consigneeCity','dispLoadForm');">C.CITY</th>
					<th align="center" valign="middle" class="head-bg" onclick="sortTableBy('l.consigneeState','dispLoadForm');">ST</th>
					<th align="center" valign="middle" class="head-bg" onclick="sortTableBy('NewDeliveryDate','dispLoadForm');">DELIVERY</th>
					<cfif NOT ListContains(session.rightsList,'HideCustomerPricing',',')>
						<th align="right" valign="middle" class="head-bg" onclick="sortTableBy('TotalCustomerCharges','dispLoadForm');">CUST AMT</th>
					</cfif>
					<th align="center" valign="middle" class="head-bg" onclick="sortTableBy('CarrierName','dispLoadForm');">
						<cfif request.qSystemSetupOptions1.freightBroker>
							CARRIER
						<cfelse>
							DRIVER
						</cfif>
					</th>
					<th align="right" valign="middle" class="head-bg2" onclick="sortTableBy('CarrierName','dispLoadForm');">Carr.Amt</th>
					<th width="5" align="right" valign="top"><img src="images/top-right.gif" alt="" width="5" height="23" /></th>
				  </tr>
			  </thead>
			  <tbody>


			  	 <cfif qLoads.recordcount eq 0>
					<script> showErrorMessage('block'); </script>
				<cfelse>
					<script> showErrorMessage('none'); </script>

				<cfloop query="qLoads">
					<cfquery dbtype="query" name="qIsLeftSideRecord">
						SELECT *
						FROM qAgentsLoadStatusTypes
						WHERE loadStatusTypeID = <cfqueryparam value="#qLoads.STATUSTYPEID#" cfsqltype="cf_sql_varchar">
					</cfquery>
					<cfif qIsLeftSideRecord.RecordCount EQ 0>
						<cfcontinue>
					</cfif>

					<cfif isdefined('url.event') AND url.event eq 'exportData' AND qLoads.ARExportedNN eq '1' AND qLoads.APExportedNN eq '1' >
						<cfcontinue>
					<cfelseif isdefined('url.event') AND url.event eq 'exportData'>
						<cfif not isdefined('form.orderDateFrom')>
							<cfset dateFrom = DateFormat('01/01/1900','mm/dd/yyyy')>
						<cfelse>
							<cfset dateFrom = DateFormat(form.orderDateFrom,'mm/dd/yyyy')>
						</cfif>

						<cfif not isdefined('form.orderDateTo')>
							<cfset dateTo = DateFormat(NOW(),'mm/dd/yyyy')>
						<cfelse>
							<cfset dateTo = DateFormat(form.orderDateTo,'mm/dd/yyyy')>
						</cfif>

						<cfif not isdefined('request.qLoads.orderDate') OR request.qLoads.orderDate eq ''>
							<cfset orderDate = DateFormat(NOW(),'mm/dd/yyyy')>
						<cfelse>
							<cfset orderDate = DateFormat(qLoads.orderDate,'mm/dd/yyyy')>
						</cfif>

						<cfif orderDate gte dateFrom AND orderDate lte dateTo>
							<!--- Do nothing, keep the normal flow --->
						<cfelse>
							<cfcontinue>
						</cfif>
					</cfif>
					<cfset request.ShipperStop = qLoads>
					<cfset request.ConsineeStop = qLoads>
					<cfinvoke component="#variables.objCutomerGateway#" method="getAllCustomers" CustomerID="#qLoads.PAYERID#" returnvariable="request.qCustomer" />
					<cfinvoke component="#variables.objloadGateway#" method="getLoadStatus" LoadStatusID="#qLoads.statusTypeID#" returnvariable="request.qLoadStatus" />


					<cfset pageSize = 30>
					<cfif isdefined("form.pageNo")>
						<cfset rowNum=(qLoads.currentRow) + ((form.pageNo-1)*pageSize)>
					<cfelse>
						<cfset rowNum=(qLoads.currentRow)>
					</cfif>
					<cfif ListContains(session.rightsList,'editLoad',',')>
			  			<cfset onRowClick = "document.location.href='index.cfm?event=addload&loadid=#qLoads.LOADID#&#session.URLToken#'">
					<cfelse>
						<cfif structKeyExists(session, "IsCustomer")>
							<cfset onRowClick = "document.location.href='index.cfm?event=addcustomerload&loadid=#qLoads.LOADID#&#session.URLToken#'">
						</cfif>
					</cfif>

				  <tr style="background:###request.qLoadStatus.ColorCode#; cursor:pointer;" onmouseover="this.style.background = '##FFFFFF';" onmouseout="this.style.background = '###request.qLoadStatus.ColorCode#';" onclick="#onRowClick#" <cfif qLoads.Row mod 2 eq 0>bgcolor="##FFFFFF"<cfelse>bgcolor="##f7f7f7"</cfif>>
					<td height="20" class="sky-bg">&nbsp;</td>
					<td width="40px" align="center" valign="middle" nowrap="nowrap" class="normal-td">#qLoads.loadNumber#</td>
					<td width="50px" align="left" valign="middle" nowrap="nowrap" class="normal-td" title="#qLoads.statusText#">#truncateMyString(6,qLoads.statusText)#</td>
					<td width="70px" align="left" valign="middle" nowrap="nowrap" class="normal-td" title="#request.qCustomer.customerName#">#truncateMyString(9, request.qCustomer.customerName)#</td>
					<td width="55px" align="left" valign="middle" nowrap="nowrap" class="normal-td" >#dateformat(qLoads.PICKUPDATE,'m/d/yy')#</td>
					<td width="55px" align="left" valign="middle" nowrap="nowrap" class="normal-td" title="#request.ShipperStop.shippercity#">#truncateMyString(9, request.ShipperStop.shippercity)#</td>
					<td width="20px" align="left" valign="middle" nowrap="nowrap" class="normal-td" >#request.ShipperStop.shipperState#</td>
					<td width="55px" align="left" valign="middle" nowrap="nowrap" class="normal-td" title="#request.ConsineeStop.consigneeCity#">#truncateMyString(9,request.ConsineeStop.consigneeCity)#</td>
					<td width="20px" align="left" valign="middle" nowrap="nowrap" class="normal-td" >#request.ConsineeStop.consigneeState#</td>
					<td width="55px" align="left" valign="middle" nowrap="nowrap" class="normal-td">#dateformat(qLoads.DeliveryDATE,'m/d/yy')#</td>
					<cfif NOT ListContains(session.rightsList,'HideCustomerPricing',',')>
						<td width="60px" align="right" valign="middle" nowrap="nowrap" class="normal-td" >#NumberFormat(qLoads.TOTALCUSTOMERCHARGES,'$')#</td>
					</cfif>
					<td width="70px" align="left" valign="middle" nowrap="nowrap" class="normal-td" title="#qLoads.CARRIERNAME#">#truncateMyString(10,qLoads.CARRIERNAME)#</td>
					<td width="70px" align="right" valign="middle" nowrap="nowrap" class="normal-td2" >#NumberFormat(qLoads.TOTALCARRIERCHARGES,'$')#</td>
					<td class="normal-td3">&nbsp;</td>
				  </tr>
    	 </cfloop>
    	 </cfif>
			  </tbody>
			  <tfoot>
				 <tr>
					<td width="5" align="left" valign="top"><img src="images/left-bot.gif" alt="" width="5" height="23" /></td>
					<td colspan="13" align="left" valign="middle" class="footer-bg">
						<div class="up-down">
							<div class="arrow-top"><a href="javascript: tablePrevPage('dispLoadForm');"><img src="images/arrow-top.gif" alt="" /></a></div>
							<div class="arrow-bot"><a href="javascript: tableNextPage('dispLoadForm');"><img src="images/arrow-bot.gif" alt="" /></a></div>
						</div>
						<div class="gen-left"><a href="javascript: tablePrevPage('dispLoadForm');">Prev </a>-
						<a href="javascript: tableNextPage('dispLoadForm');"> Next</a></div>
						<div class="gen-right"><img src="images/loader.gif" alt="" /></div>
						<div class="clear"></div>
					</td>
					<td width="5" align="right" valign="top"><img src="images/right-bot.gif" alt="" width="5" height="23" /></td>
				 </tr>
				 </tfoot>
			  </table>
		</td>
	  </tr>
	</table>


	  <div style="clear:left;"></div>
<cfelse>
	<cfform id="dispLoadFormUdateShipDate" name="dispLoadFormUdateShipDate" action="#actionUrl#" method="post" preserveData="yes">
		<cfinput name="dsn" type="hidden" value="#variables.dsn#" id="dsn">
		<cfif  structKeyExists(session, "IsCustomer")>
			<cfinput name="Id" type="hidden" value="#session.customerid#" id="Id">
		<cfelse>
			<cfinput name="Id" type="hidden" value="#session.empid#" id="Id">
		</cfif>
		<cfinput name="urlToken" type="hidden" value="#session.urlToken#" id="urlToken">
		<cfinput name="urlEvent" type="hidden" value="#url.event#" id="urlEvent">
		<!---  Show User Status check boxes--->
		<div style="width: 900px; float: left; margin-top: -92px;margin-left: 375px;<cfif (structKeyExists(session, "showloadtypestatusonloadsscreen") and session.showloadtypestatusonloadsscreen eq 0) OR NOT structKeyExists(session, "showloadtypestatusonloadsscreen")>display:none;</cfif>" class="mystatusbox">
			<style>
				.status-box{
					position: relative;
					margin-bottom: 6px;
				}
				.status-box label {
				    margin: 4px;
				    border-radius: 30px;
				    position: relative;
				    width: 140px;
				    padding: 3px 9px;
				    display: inline-block;
				    cursor: pointer;
				}
				.status-box label input {
				    vertical-align: middle;
				    display: inline-block;
				    height: 100%;
				   margin-right: 6px;
				}
				.status-box label small{
					font-size: 11px;
					margin-left: 16px;

				}
				.status-box label.checkbox input[type="checkbox"] {
				  display: none;
				}
				.status-box label.checkbox input[type="checkbox"]:checked + span {
				  opacity: 1;
				}
				
				.status-box label.checkbox span {
					position: absolute;
					top: 3px;
					left: 3px;
					width: 10px;
					height: 10px;
					-ms-transform: rotate(45deg);
					-webkit-transform: rotate(45deg);
					transform: rotate(45deg);
					transition: opacity 500ms ease;
					border-radius: 40px;
					border: 2px solid ##666;
				  
				}
				.status-box label.checkbox input[type="checkbox"]:checked ~ span{
					border: 2px solid ##0395fd;
					background: ##0395fd;
				}
				.status-box label.checkbox input[type="checkbox"]:checked ~ span::before {
				  position: absolute;
				  content: '';
				  top:2px;
				  left: 7px;
				  width: 2px;
				  height: 8px;
				  background-color: ##fff;
				}
				.status-box label.checkbox input[type="checkbox"]:checked ~ span::after {
				  position: absolute;
				  content: '';
				  top: 8px;
				  left: 4px;
				  width: 4px;
				  height: 2px;
				  background-color: ##fff;
				}
			</style>
			<cfif not structKeyExists(session, "UserAssignedLoadStatus")>
				<cfset session.UserAssignedLoadStatus["MyLoads"] = agentsLoadStatusTypesArray>
				<cfset session.UserAssignedLoadStatus["AllLoads"] = agentsLoadStatusTypesArray>
				<cfset session.UserAssignedLoadStatus["Default"] = agentsLoadStatusTypesArray>
			</cfif>
			<cfif isDefined("request.qLoadStatusTypes")>
				<div style="float:left; padding-left:30px; ">
					<div class="status-box">
						<cfloop query="request.qLoadStatusTypes">
							<cfif request.qLoadStatusTypes.Filter Eq "1" AND request.qLoadStatusTypes.IsActive EQ 1>	
								<cfif structKeyExists(url, "pending") and NOT listFindNoCase("ACTIVE,BOOKED", request.qLoadStatusTypes.StatusDescription)>
									<cfcontinue>
								</cfif>
								<label class="checkbox" style="background-color:###request.qLoadStatusTypes.COLORCODE#;color:###request.qLoadStatusTypes.TEXTCOLORCODE#;">
								<input type="checkbox" class="chk-my-status" name="chkLoadSTatusAssigned" id="chkLoadSTatusAssigned" value="#request.qLoadStatusTypes.statustypeid#" 
								<cfif url.event EQ 'Myload' AND listFindNoCase(session.UserAssignedLoadStatus["MyLoads"], request.qLoadStatusTypes.statustypeid)>
									checked ="checked"
								<cfelseif url.event EQ 'load' AND listFindNoCase(session.UserAssignedLoadStatus["AllLoads"], request.qLoadStatusTypes.statustypeid)>
									checked ="checked"
								</cfif>>
								<span></span>
								<small>#request.qLoadStatusTypes.StatusDescription#</small></label>
							</cfif>
					  </cfloop>

					</div>

					
				</div>
			</cfif>
		</div>
		<!--- ./ End --->
	<cfif request.qSystemSetupOptions1.rolloverShipDateStatus>
		 <cfif isdefined('url.event') AND url.event neq 'exportData'>
		 	<div id="dialog-confirm"></div>
		 	<div id="Information"></div>
		 	<div id="responseUploadProcess"></div>
		 	<cfif request.qSystemSetupOptions1.rolloverShipDateStatus AND structKeyExists(request, "qrygetAgentdetails") AND structKeyExists(request.qrygetAgentdetails, "ROLEID") AND request.qrygetAgentdetails.ROLEID neq 7>
		 			<div class="LoadActions" style="float:left;">
		 			<div style="width: 780px; float: left; margin-top: -68px;margin-left: 496px;" class="hideStatus">
		 				<!--- Begin:Ticket:836 Include Carrier Rate. --->
						<div style="float: left" id="status">
							<div style="float:left;width: 65px;">
								<label style="color: ##0a0a0a;font-weight: bold;">Status</label>
		    				</div>
							<div style="float:left;">
								<select name="loadStatusUpdate" id="loadStatusUpdate" class="medium" style="width: 123px;" onchange="loadboardsstatus()">
					                <option value="">Select Status</option>
									<cfloop query="request.qLoadStatus">
										<cfif not request.qLoadStatus.SystemUpdated>
											<cfif ListContains(replace(session.editableStatuses," ","","ALL"),replace(request.qLoadStatus.Text," ","","ALL"),',')>
						                  		<option value="#request.qLoadStatus.value#" data-forcenextstatus="#request.qLoadStatus.ForceNextStatus#" data-statusText="#request.qLoadStatus.Text#">#request.qLoadStatus.StatusDescription#</option>
						              		</cfif>
						              	</cfif>
					                </cfloop>
					             </select>
			 				</div>
						</div>
						<div style="float: left;margin-left: 5px;" id="status">
							<div style="float:left;width: 115px;text-align: right">
								<label style="color: ##0a0a0a;font-weight: bold;">Post 123Load Board</label>
		    				</div>
							<div style="float:left;margin-top: 1px;margin-left: 2px">
								<input name="post123loadboard" type="checkbox" id="post123loadboard">
			 				</div>
						</div>
						<div style="float: left;margin-left: 5px;" id="status">
							<div style="float:left;width: 150px;text-align: right">
								<label style="color: ##0a0a0a;font-weight: bold;">Post to Direct Freight<span style="color:##11c511">(FREE)</span></label>
		    				</div>
							<div style="float:left;margin-top: 1px;margin-left: 2px">
								<input name="postdirectfreight" type="checkbox" id="postdirectfreight">
			 				</div>
						</div>
						<div style="float: left;margin-left: 10px;" id="status">
							<div style="float:left;width: 105px;text-align: right">
								<label style="color: ##0a0a0a;font-weight: bold;">LoadBoard Network</label>
		    				</div>
							<div style="float:left;margin-top: 1px;margin-left: 2px">
								<input name="posteverywhere" type="checkbox" id="posteverywhere">
			 				</div>
						</div>
						<div style="float: left;margin-left: 10px;" id="status">
							<div style="float:left;width: 128px;text-align: right">
								<label style="color: ##0a0a0a;font-weight: bold;">Include Carrier Rate</label>
		    				</div>
							<div style="float:left;margin-top: 1px;margin-left: 2px">
								<input disabled name="postCarrierRatetoTranscore" type="checkbox" id="postCarrierRatetoTranscore">
			 				</div>
						</div>
						<!--- End:Ticket:836 Include Carrier Rate. --->
		  				<div style="clear:both"></div>
					</div>

					<div style="width: 667px; float: left; margin-top: -44px;margin-left: 496px;" class="hideDate">

						<div style="float: left;" id="rollOverShipDateContainerrollOverShipDateContainer">
		  					<div style="float:left;width: 65px;">
								<label style="color: ##0a0a0a;font-weight: bold;">Pickup Date</label>
		    				</div>

							<div style="float:left;">
								<input name="rollOverShipDate" class="datefieldinput " style="width:103px;margin-right:10px;" id="rollOverShipDate" onblur="checkDateFormatAll(this)" value="">
								<img class="ui-datepicker-trigger" src="images/DateChooser.png" alt="..." title="..." onclick="javascript:window.open('index.cfm?event=addMultipleDates&stopNo=0&action=myloads&#session.URLToken#','Map','height=400,width=400');">
								<input type="hidden" id="shipperPickupDateMultiple" name="shipperPickupDateMultiple" value="">
								<input type="hidden" id="shipperPickupDate" name="shipperPickupDate" value="#DateFormat(now(),'mm/dd/yyyy')#">
								<input type="hidden" id="consigneePickupDate" name="consigneePickupDate" value="#DateFormat(DateAdd('d',1,now()),'mm/dd/yyyy')#">
			 				</div>
						</div>
						<div style="float: left;" id="status">
							<div style="float:left;width: 115px;text-align: right;">
								<label style="color: ##0a0a0a;font-weight: bold;">Post DAT Load Board</label>
		    				</div>
							<div style="float:left;margin-top: 1px;margin-left: 2px">
								<input name="postdatloadboard" type="checkbox" id="postdatloadboard">
			 				</div>
						</div>
						<div style="float: left;margin-left: 10px;" id="status">
							<div style="float:left;width: 60px;text-align: right">
								<label style="color: ##0a0a0a;font-weight: bold;">Post to ITS</label>
		    				</div>
							<div style="float:left;margin-top: 1px;margin-left: 2px">
								<input name="postToIts" type="checkbox" id="postToIts">
			 				</div>
						</div>
						<div style="float: left;margin-left: 10px;" id="status">
							<div style="float:left;width: 128px;text-align: right">
								<label style="color: ##0a0a0a;font-weight: bold;">Post to All Load Boards</label>
							</div>
							<div style="float:left;margin-top: 1px;margin-left: 2px">
								<input name="postallloadboards" id="postallloadboards" type="checkbox">
							</div>
						</div>

		  				<div style="clear:both">
						</div>
						<div style="margin-top: 5px;" id="weekendRollOver">

							
			 				<div style="float:left;width:345px;text-align: right">
								<label style="color: ##0a0a0a;font-weight: bold;">Weekends rollover to Monday? </label>
		    				</div>
		    				<div style="float:left;margin-left: 2px">
								<input name="weekendRollOvercheck" type="checkbox" id="weekendRollOvercheck" checked="true">
			 				</div>
			 				<div style="float: left;margin-left: 9px;margin-top: -7px;" id="updateLoadsContainer">
							<cfinput name="updateLoads" id="updateLoads" onclick="return UpdateLoadsCheck();" type="button" class="s-bttn" value="Update Loads" style="width:56px;">
							<cfinput id="carrierLanesEmailButton" name="carrierLanesEmailButton" class="black-btn tooltip" data-allowmail="#mailsettings#" value="Email Carriers" type="button">
							<cfinput type="hidden" name="TotalCarrierChargesHidden" id="TotalCarrierChargesHidden" value="0">
        					<cfinput type="hidden" name="Dispatcher" id="Dispatcher" value="00000000-0000-0000-0000-000000000000">
							<cfinput name="CompanyID" type="hidden" value="#session.CompanyID#" id="CompanyID">
						</div>

		    				<div style="clear:both;"></div>
						</div>
					</div>
				</div>

			</cfif>
			
		</cfif>
	</cfif>
	
	<cfif request.qSystemSetupOptions1.LoadsColumnsSetting EQ 1>		
		<table width="100%" border="0" cellspacing="0" cellpadding="0" class="data-table glossy-bg-blue">
			<tr class="glossy-bg-blue">
				<th width="5" class="" align="left" valign="top" style="border:1px solid ##5d8cc9;">

				<span></span>
					<span class="up-down gen-left">
						<span class="arrow-top"><a href="javascript: tablePrevPage('dispLoadForm');" style="padding-left:5px !important;"><img src="images/arrow-top.gif" alt=""  style="width: 10px;"/></a></span>
						<span class="arrow-bot"><a href="javascript: tableNextPage('dispLoadForm');"><img src="images/arrow-bot.gif" alt=""  style="width: 10px;" /></a></span>
					</span>						
					<span class="gen-left"><a href="javascript: tablePrevPage('dispLoadForm');">&nbsp;&nbsp;Prev </a>-<a href="javascript: tableNextPage('dispLoadForm');"> Next</a></span>
					<span class="gen-right"></span>
					<span class="span"></div>

				</th>													
			 </tr>
		</table>
		<table width="100%" border="0" cellspacing="0" cellpadding="0" class="data-table">			  
			 <thead>
				<tr>
					<th width="5" align="left" valign="top" class="sky-bg"></th>

					<th width="29" align="center" valign="middle" class="head-bg numbering">&nbsp;</th>
					<cfif request.qSystemSetupOptions1.rolloverShipDateStatus AND structKeyExists(request, "qrygetAgentdetails") AND structKeyExists(request.qrygetAgentdetails, "ROLEID") AND request.qrygetAgentdetails.ROLEID neq 7>
						<cfif isdefined('url.event') AND url.event neq 'exportData'>
							<th  align="center" valign="middle" class="head-bg"> <input type="checkbox" name="rolloverShipDateAll" id="rolloverShipDateAll" class="checkboxSelect" onclick="checkboxOperation(this)"></th>
						</cfif>
					</cfif>
					<th align="center" valign="middle" class="head-bg load" onclick="sortTableBy('l.LoadNumber','dispLoadForm');">LOAD##</th>
					<th align="center" style="width:10% !important;" valign="middle" class="head-bg " onclick="sortTableBy('c.CarrierName','dispLoadForm');">Driver </th>
					<th align="center" style="width:10% !important;"  valign="middle" class="head-bg " onclick="sortTableBy('l.TruckNo','dispLoadForm');">TRK ##</th>
					<th align="center" style="width:10% !important;" valign="middle" class="head-bg " onclick="sortTableBy('l.TrailorNo','dispLoadForm');">TRL ##</th>
					<th align="center"  style="width:10% !important;" valign="middle" class="head-bg " onclick="sortTableBy('l.CustName','dispLoadForm');">Customer</th>
					<th align="center"  style="width:10% !important;" valign="middle" class="head-bg " onclick="sortTableBy('stops.shipperStopName','dispLoadForm');">Shipper</th>
					<th align="center"  style="width:10% !important;" valign="middle" class="head-bg " >Commodity</th>
					<th align="center"  style="width:10% !important;" valign="middle" class="head-bg " >Consignee</th>
					<cfif isdefined('url.event') AND url.event neq 'myLoad' AND  request.qSystemSetupOptions1.ShowCarrierInvoiceNumberInAllLoads EQ 1>
						<th align="center"  style="width:10% !important;" valign="middle" class="head-bg " >CARR_INV</th>
					</cfif>
					<th align="center"  style="width:10% !important;" valign="middle" class="head-bg " >Delivery&nbsp;Date</th>
					<th align="center"  style="width:10% !important;" valign="middle" class="head-bg " onclick="sortTableBy('l.NewDeliveryTime','dispLoadForm');">DelTime</th>
					<th width="5" align="center" valign="middle" style="width:20% !important;" nowrap="nowrap" class="head-bg " >Dispatch Notes</th>
					<th width="5" align="right" valign="top"><img src="images/top-right.gif" alt="" width="5" height="23" /></th>
				</tr>
		  </thead>
			  <tbody>			  
				<cfloop query="qLoads">
					<cfset onHrefClick = "index.cfm?event=addload&loadid=#qLoads.LOADID#&#session.URLToken#">
					<cfinvoke component="#variables.objloadGateway#" method="getLoadStatus" LoadStatusID="#qLoads.statusTypeID#" returnvariable="request.qLoadStatus" />
					<tr style="background:###request.qLoadStatus.ColorCode#; cursor:pointer;" onmouseover="this.style.background = '##FFFFFF';" onmouseout="this.style.background = '###request.qLoadStatus.ColorCode#';" <cfif qLoads.Row mod 2 eq 0>bgcolor="##FFFFFF"<cfelse>bgcolor="##f7f7f7"</cfif>>
								<td height="20" class="sky-bg">&nbsp;</td>								
								<td align="center" valign="middle" nowrap="nowrap" class="sky-bg2" >#qLoads.Row#</td>
								<cfif request.qSystemSetupOptions1.rolloverShipDateStatus AND structKeyExists(request, "qrygetAgentdetails") AND structKeyExists(request.qrygetAgentdetails, "ROLEID") AND request.qrygetAgentdetails.ROLEID neq 7>
									<cfif isdefined('url.event') AND url.event neq 'exportData'>
										<td align="center" valign="middle" nowrap="nowrap" class="sky-bg2 " style="padding: 0 5px 0 5px;" >
											<cfif ListContains(replace(session.editableStatuses," ","","ALL"),replace(qLoads.STATUSTEXT," ","","ALL"),',') AND NOT qLoads.ForceNextStatus>
												<cfinput type="checkbox" name="rolloverShipDateCheckSub" id="rolloverShipDateCheckSub" class="checkboxSelect" value="#qLoads.loadNumber#"></td>
											<cfelse>
												<cfinput type="checkbox" name="rolloverShipDateCheckSub" id="rolloverShipDateCheckSub" class="checkboxSelect" value="#qLoads.loadNumber#"  data-code="disabled" data-status='#qLoads.StatusTypeID#'></td>
											</cfif>
									</cfif>
								</cfif>
								<input type="hidden" name="StatusText#qLoads.loadNumber#" id="StatusText#qLoads.loadNumber#" value="#qLoads.STATUSTEXT#">
								<td align="left" valign="middle" nowrap="nowrap" class="normal-td"  onclick="location.href='#onHrefClick#'"><a href="#onHrefClick#">#qLoads.loadNumber#</a></td>
								<td align="left" valign="middle" nowrap="nowrap" class="normal-td"  onclick="location.href='#onHrefClick#'"><a href="#onHrefClick#">#qLoads.DriverName#</a></td>
								<td align="left" valign="middle" nowrap="nowrap" class="normal-td"  onclick="location.href='#onHrefClick#'"><a href="#onHrefClick#">#replace(qLoads.TruckNo,",,","","all")#</a></td>
								<td align="left" valign="middle" nowrap="nowrap" class="normal-td"  onclick="location.href='#onHrefClick#'"><a href="#onHrefClick#">#replace(qLoads.TrailorNo,",,","","all")#</a></td>
								<td align="left" valign="middle" nowrap="nowrap" class="normal-td"  onclick="location.href='#onHrefClick#'"><a href="#onHrefClick#">#qLoads.Customer#</a></td>
								<td align="left" valign="middle" nowrap="nowrap" class="normal-td"  onclick="location.href='#onHrefClick#'"><a href="#onHrefClick#">#qLoads.Shipper#</a></td>
								<td align="left" valign="middle" nowrap="nowrap" class="normal-td"  onclick="location.href='#onHrefClick#'"><a href="#onHrefClick#">#qLoads.COMMODITY#</a></td>
								<td align="left" valign="middle" nowrap="nowrap" class="normal-td"  onclick="location.href='#onHrefClick#'"><a href="#onHrefClick#">#qLoads.CONSIGNEE#</a></td>
								<cfif isdefined('url.event') AND url.event neq 'myLoad'  AND  request.qSystemSetupOptions1.ShowCarrierInvoiceNumberInAllLoads EQ 1>
									<td align="left" valign="middle" nowrap="nowrap" class="normal-td"  onclick="location.href='#onHrefClick#'"><a href="#onHrefClick#">
										<cfif qLoads.CarrierInvoiceNumber NEQ 0> #qLoads.CarrierInvoiceNumber#</cfif>
									</a></td>
								</cfif>
								<td align="left" valign="middle" nowrap="nowrap" class="normal-td"  onclick="location.href='#onHrefClick#'"><a href="#onHrefClick#">#DateFormat(qLoads.NewDeliveryDate,'mm/dd/yyyy')#</a></td>
								<td align="left" valign="middle" nowrap="nowrap" class="normal-td"  onclick="location.href='#onHrefClick#'"><a href="#onHrefClick#">#qLoads.DelTime#</a></td>
								<td align="left" valign="middle" nowrap="nowrap" style="width:20% !important;" class="normal-td" >
									<a href="javascript:void(0)" style="text-decoration: underline !important;" class="InfotoolTip" title="#qLoads.DispatchNotes#"> Show Notes</a>
								</td>
								<td class="normal-td3">&nbsp;</td>
					</tr>
				</cfloop>
			  </tbody>			
			</table>
	<cfelse>
			
			<table width="100%" border="0" cellspacing="0" cellpadding="0" class="data-table" id="tblLoadList"> 	
			  <thead>
			  	<tr class="glossy-bg-blue">
					<th colspan="5" class="" align="left" valign="top" style="border:1px solid ##5d8cc9;border-right: none;">
						<span>&nbsp;&nbsp;</span>
						<span class="up-down gen-left">
							<span class="arrow-top"><a href="javascript: tablePrevPage('dispLoadForm');" style="padding-left:5px !important;"><img src="images/arrow-top.gif" alt="" style="width: 10px;" /></a></span>
							<span class="arrow-bot"><a href="javascript: tableNextPage('dispLoadForm');"><img src="images/arrow-bot.gif" alt=""  style="width: 10px;" /></a></span>
						</span>						
						<span class="gen-left"><a href="javascript: tablePrevPage('dispLoadForm');">&nbsp;&nbsp;Prev </a>-<a href="javascript: tableNextPage('dispLoadForm');"> Next</a></span>
						<span class="gen-right"></span>
						<span class="span"></div>
					</th>	
					<th colspan="27" align="left" style="border:1px solid ##5d8cc9;border-left: none;">
						<cfif application.dsn NEQ "LoadManagerLive" and structKeyExists(session, "AdminUserName") and session.AdminUserName EQ 'global'>
						<label style="float: left;font-size: 16px;padding-top: 5px;">SORT BY:&nbsp;</label>
						<cfloop from="1" to="3" index="i">
							<label style="float: left;font-size: 16px;padding-top: 5px;">#i#.</label>
							<select name="SortBy#i#" id="SortBy#i#" style="border: 1px solid ##b3b3b3;height: 21px;font: 11px/16px Arial,Helvetica,sans-serif !important;float: left;margin-top: 2px;" onchange="MultipleSort('SortBy#i#',this.value);">
								<option value="">SELECT SORT</option>
								<cfset loadsColumnStatus="#request.qGetSystemSetupOptions.LoadsColumnsStatus#">
								<cfloop list="#request.qGetSystemSetupOptions.LoadsColumns#" item="colname" index="j">
									<cfset activeColumn = ListGetAt(loadsColumnStatus,j)>
									<cfif activeColumn EQ  1>
										<cfswitch expression="#colname#">
											<cfcase value="Load Number">
												<option value="l.LoadNumber" <cfif cookie["SortBy#i#"] EQ "l.LoadNumber"> selected </cfif>>LOAD##</option>
											</cfcase>
											<cfcase value="Status">
												<option value="StatusDescription" <cfif cookie["SortBy#i#"] EQ "StatusDescription" OR cookie["SortBy#i#"] EQ "StatusOrder"> selected </cfif>>STATUS</option>
											</cfcase>
											<cfcase value="Customer">
												<option value="CustName" <cfif cookie["SortBy#i#"] EQ "CustName"> selected </cfif>>CUSTOMER</option>
											</cfcase>
											<cfcase value="Po##">
												<option value="CustomerPONo" <cfif cookie["SortBy#i#"] EQ "CustomerPONo"> selected </cfif>>PO##</option>
											</cfcase>
											<cfcase value="Pickup Date">
												<option value="NewPickupDate" <cfif cookie["SortBy#i#"] EQ "NewPickupDate"> selected </cfif>>Pickup Date</option>
											</cfcase>
											<cfcase value="Pickup Time">
												<option value="NewPickupTime" <cfif cookie["SortBy#i#"] EQ "NewPickupTime"> selected </cfif>>Pickup Time</option>
											</cfcase>
											<cfcase value="Delivery Time">
												<option value="NewDeliveryTime" <cfif cookie["SortBy#i#"] EQ "NewDeliveryTime"> selected </cfif>>Delivery Time</option>
											</cfcase>
											<cfcase value="Pickup City">
												<option value="l.shipperCity" <cfif cookie["SortBy#i#"] EQ "l.shipperCity"> selected </cfif>>Pickup City</option>
											</cfcase>
											<cfcase value="Pickup ST">
												<option value="l.shipperState" <cfif cookie["SortBy#i#"] EQ "l.shipperState"> selected </cfif>>Pickup ST</option>
											</cfcase>
											<cfcase value="Delivery City">
												<option value="l.consigneeCity" <cfif cookie["SortBy#i#"] EQ "l.consigneeCity"> selected </cfif>>Delivery City</option>
											</cfcase>
											<cfcase value="Delivery ST">
												<option value="l.consigneeState" <cfif cookie["SortBy#i#"] EQ "l.consigneeState"> selected </cfif>>Delivery ST</option>
											</cfcase>
											<cfcase value="Delivery Date">
												<option value="NewDeliveryDate" <cfif cookie["SortBy#i#"] EQ "NewDeliveryDate"> selected </cfif>>Delivery Date</option>
											</cfcase>
											<cfcase value="Cust Amt">
												<cfif NOT ListContains(session.rightsList,'HideCustomerPricing',',')>	
													<option value="TotalCustomerCharges" <cfif cookie["SortBy#i#"] EQ "TotalCustomerCharges"> selected </cfif>>Cust Amt</option>
												</cfif>
											</cfcase>
											<cfcase value="Carr Amt">
												<cfif customer NEQ 1 AND  NOT ListContains(session.rightsList,'HideFinancialRates',',')>	
													<option value="TotalCarrierCharges" <cfif cookie["SortBy#i#"] EQ "TotalCarrierCharges"> selected </cfif>>Carr Amt</option>
												</cfif>
											</cfcase>
											<cfcase value="Miles">
												<option value="TotalMiles" <cfif cookie["SortBy#i#"] EQ "TotalMiles"> selected </cfif>>Miles</option>
											</cfcase>
											<cfcase value="DH Miles">
												<option value="TotalMiles" <cfif cookie["SortBy#i#"] EQ "TotalMiles"> selected </cfif>>DH Miles</option>
											</cfcase>
											<cfcase value="Carr_Inv">
												<cfif isdefined('url.event') AND url.event neq 'myLoad' AND  request.qSystemSetupOptions1.ShowCarrierInvoiceNumberInAllLoads EQ 1>
													<option value="TotalCarrierCharges" <cfif cookie["SortBy#i#"] EQ "TotalCarrierCharges"> selected </cfif>>Carr_Inv</option>
												</cfif>
											</cfcase>
											<cfcase value="Carrier/ Driver">
											<cfif customer NEQ 1>
												<option value="TotalMiles" <cfif cookie["SortBy#i#"] EQ "TotalMiles"> selected </cfif>><cfif request.qSystemSetupOptions1.freightBroker>
													CARRIER
												<cfelseif NOT val(request.qSystemSetupOptions1.freightBroker)>
													DRIVER
												</cfif></option>
											</cfif>
											</cfcase>
											<cfcase value="Equipment">
												<option value="l.EquipmentName" <cfif cookie["SortBy#i#"] EQ "l.EquipmentName"> selected </cfif>>Equipment</option>
											</cfcase>
											<cfcase value="Driver">
												<option value="DriverName" <cfif cookie["SortBy#i#"] EQ "DriverName"> selected </cfif>>Driver</option>
											</cfcase>
											<cfcase value="Dispatcher">
												<option value="empDispatch" <cfif cookie["SortBy#i#"] EQ "empDispatch"> selected </cfif>>Dispatcher</option>
											</cfcase>
											<cfcase value="Sales Rep">
												<option value="SalesAgent" <cfif cookie["SortBy#i#"] EQ "SalesAgent"> selected </cfif>>Sales Rep</option>
											</cfcase>
											<cfcase value="Invoice Date">
												<option value="BillDate" <cfif cookie["SortBy#i#"] EQ "BillDate"> selected </cfif>>Invoice Date</option>
											</cfcase>
											<cfcase value="UserDef7">
												<option value="userDefinedFieldTrucking" <cfif cookie["SortBy#i#"] EQ "userDefinedFieldTrucking"> selected </cfif>>#request.qGetSystemSetupOptions.UserDef7#</option>
											</cfcase>
											<cfcase value="Internal Ref##">
												<option value="InternalRef" <cfif cookie["SortBy#i#"] EQ "InternalRef"> selected </cfif>>Internal Ref##</option>
											</cfcase>
											<cfcase value="Type">
												<option value="Equipments.EquipmentType" <cfif cookie["SortBy#i#"] EQ "Equipments.EquipmentType"> selected </cfif>>Type</option>
											</cfcase>
											<cfcase value="Rel. Equip">
												<option value="RelEquip.EquipmentName" <cfif cookie["SortBy#i#"] EQ "RelEquip.EquipmentName"> selected </cfif>>Rel. Equip</option>
											</cfcase>
											<cfcase value="Bill From">
												<option value="ISNULL(BillFromCompanies.Companyname,Companies.CompanyName)" <cfif cookie["SortBy#i#"] EQ "ISNULL(BillFromCompanies.Companyname,Companies.CompanyName)"> selected </cfif>>Bill From</option>
											</cfcase>
											<cfcase value="Dispatcher 2">
												<option value="L.Dispatcher2Name" <cfif cookie["SortBy#i#"] EQ "L.Dispatcher2Name"> selected </cfif>>Dispatcher 2</option>
											</cfcase>
										</cfswitch>
									</cfif>
								</cfloop>
							</select>
							<ul style="float:left;margin-left: 5px;margin-right: 5px;margin-top: 2px;">
								<li style="cursor: pointer;" class="3-sort-li">
									<cfif cookie["SortOrder#i#"] EQ "ASC">
										<img src="images/AtoZ.png" height="20">
									<cfelse>
										<img src="images/ZtoA.png" height="20">
									</cfif>
									<ul class="3-sort-ul" style="background-color: ##fff;position: absolute;display: none;">
										<li style="padding: 5px;" class="li-sort-3" onclick="MultipleSort('SortOrder#i#','ASC');"><img src="images/AtoZ.png" height="20" style="vertical-align:middle;"> <span style="color: ##808080;">Sort Ascending</span></li>
										<li style="padding: 5px;" class="li-sort-3" onclick="MultipleSort('SortOrder#i#','DESC');"><img src="images/ZtoA.png" height="20" style="vertical-align:middle;"> <span style="color: ##808080;">Sort Descending</span></li>
									</ul>
								</li>
							</ul>
						</cfloop>
						<a href="javascript: clearMultipleSort();" style="margin-top: 5px;">Clear Sort</a>
						</cfif>
					</th>												
				 </tr>
			  <tr  id="tblLoadListHead">
			  	<th width="5" align="left" valign="top" class="fillHeader"></th>
				<th width="29" align="center" valign="middle" class="head-bg numbering">&nbsp;</th>
				<cfif request.qSystemSetupOptions1.rolloverShipDateStatus AND structKeyExists(request, "qrygetAgentdetails") AND structKeyExists(request.qrygetAgentdetails, "ROLEID") AND request.qrygetAgentdetails.ROLEID neq 7>
					<cfif isdefined('url.event') AND url.event neq 'exportData'>
						<th  align="center" valign="middle" class="head-bg"> <input type="checkbox" name="rolloverShipDateAll" id="rolloverShipDateAll" class="checkboxSelect" onclick="checkboxOperation(this)"></th>
					</cfif>
				</cfif>
				
				<cfset loadsColumnStatus="#request.qGetSystemSetupOptions.LoadsColumnsStatus#">
				<cfloop list="#request.qGetSystemSetupOptions.LoadsColumns#" item="colname" index="i">	
				<cfset activeColumn = ListGetAt(loadsColumnStatus,i)>
				<cfif activeColumn EQ  1>
				<cfswitch expression="#colname#">
					<cfcase value="Load Number">
						<th align="center" valign="middle" class="head-bg load" onclick="sortTableBy('l.LoadNumber','dispLoadForm');">LOAD##</th>
					</cfcase>
					<cfcase value="Status">
						<th align="center" valign="middle" class="head-bg statusWrap" onclick="sortTableBy('StatusDescription','dispLoadForm');">STATUS</th>
					</cfcase>
					<cfcase value="Customer">
						<th align="center" valign="middle" class="head-bg custWrap" onclick="sortTableBy('CustName','dispLoadForm');"><cfif structKeyExists(session, "currentusertype") AND session.currentusertype EQ "Administrator">CUSTOMER<cfelse>BROKER</cfif></th>
					</cfcase>
					<cfcase value="Po##">
						<th align="center" valign="middle" class="head-bg poWrap" onclick="sortTableBy('CustomerPONo','dispLoadForm');">PO##</th>
					</cfcase>
					<cfcase value="Pickup Date">
					<th align="center" valign="middle" class="head-bg shipdate" onclick="sortTableBy('NewPickupDate','dispLoadForm');">Pickup&nbsp;Date</th>
					</cfcase>
					<cfcase value="Pickup Time">
					<th align="center" valign="middle" class="head-bg shipdate" onclick="sortTableBy('NewPickupTime','dispLoadForm');">Pickup&nbsp;Time</th>
					</cfcase>
					<cfcase value="Delivery Time">
					<th align="center" valign="middle" class="head-bg shipdate" onclick="sortTableBy('NewDeliveryTime','dispLoadForm');">Delivery&nbsp;Time</th>
					</cfcase>
					<cfcase value="Pickup City">
					<th align="center" valign="middle" class="head-bg" onclick="sortTableBy('l.shipperCity','dispLoadForm');">Pickup&nbsp;City</th>
					</cfcase>
					<cfcase value="Pickup ST">
					<th align="center" valign="middle" class="head-bg stHead" onclick="sortTableBy('l.shipperState','dispLoadForm');">Pickup&nbsp;ST</th>
					</cfcase>
					<cfcase value="Delivery City">
					<th align="center" valign="middle" class="head-bg" onclick="sortTableBy('l.consigneeCity','dispLoadForm');">Delivery&nbsp;City</th>
					</cfcase>
					<cfcase value="Delivery ST">
					<th align="center" valign="middle" class="head-bg stHead" onclick="sortTableBy('l.consigneeState','dispLoadForm');">Delivery&nbsp;ST</th>
					</cfcase>
					<cfcase value="Delivery Date">
					<th align="center" valign="middle" class="head-bg deliverDate" onclick="sortTableBy('NewDeliveryDate','dispLoadForm');">Delivery&nbsp;Date</th>
					</cfcase>
					<cfcase value="Cust Amt">	
						<cfif NOT ListContains(session.rightsList,'HideCustomerPricing',',')>				
							<th align="right" valign="middle" class="head-bg custAmt" onclick="sortTableBy('TotalCustomerCharges','dispLoadForm');">Cust&nbsp;Amt</th>
						</cfif>
					</cfcase>
					<cfcase value="Carr Amt">
						<cfif customer NEQ 1 AND  NOT ListContains(session.rightsList,'HideFinancialRates',',')>
							<th align="right" valign="middle" class="head-bg custAmt" onclick="sortTableBy('TotalCarrierCharges','dispLoadForm');">Carr&nbsp;Amt</th>	
						</cfif>				
					</cfcase>
					<cfcase value="Miles">
					<!---BEGIN: 604: Add a column to All Loads/ My Loads--->

					<th align="right" valign="middle" class="head-bg custAmt" onclick="sortTableBy('TotalMiles','dispLoadForm');">MILES</th>					
					
					</cfcase>
					<cfcase value="DH Miles">
					<!---END: 604: Add a column to All Loads/ My Loads --->
					<!---BEGIN: 604: Add a column to All Loads/ My Loads : Add DeadHead Miles for Load--->
					<th align="right" valign="middle" class="head-bg custAmt" onclick="sortTableBy('TotalMiles','dispLoadForm');" style="min-width: 60px;">DH MILES</th>					
					
					</cfcase>
					<cfcase value="Carr_Inv">
					<!---END: 604: Add a column to All Loads/ My Loads : Add DeadHead Miles for Load--->
					<cfif isdefined('url.event') AND url.event neq 'myLoad' AND  request.qSystemSetupOptions1.ShowCarrierInvoiceNumberInAllLoads EQ 1>
							<th align="right" valign="middle" class="head-bg custAmt" onclick="sortTableBy('TotalCarrierCharges','dispLoadForm');">CARR_INV</th>
						</cfif>
					</cfcase>
					<cfcase value="Carrier/ Driver">
					<cfif customer NEQ 1>
						<th align="center" valign="middle" class="head-bg" onclick="sortTableBy('CarrierName','dispLoadForm');">
							
							<cfif request.qSystemSetupOptions1.freightBroker>
								CARRIER
							<cfelseif NOT val(request.qSystemSetupOptions1.freightBroker)>
								DRIVER
							</cfif>
						</th>
					</cfif>
					</cfcase>
					<cfcase value="Equipment">
					<th align="center" valign="middle" class="head-bg dispatch" onclick="sortTableBy('l.EquipmentName','dispLoadForm');">Equipment </th>
					</cfcase>
					<cfcase value="Driver">
					<th align="center" valign="middle" class="head-bg dispatch" onclick="sortTableBy('DriverName','dispLoadForm');">Driver </th>
					</cfcase>
					<cfcase value="Dispatcher">
					<th align="center" valign="middle" class="head-bg dispatch" onclick="sortTableBy('empDispatch','dispLoadForm');">Dispatcher </th>
					</cfcase>
					<cfcase value="Sales Rep">
					<th align="center" valign="middle" class="head-bg agent" onclick="sortTableBy('SalesAgent','dispLoadForm');">Sales&nbsp;Rep</th>
					</cfcase>
					<cfcase value="Map">
						<th align="center" valign="middle" class="head-bg">Map</th>
					</cfcase>
					<cfcase value="Invoice Date">
					<th align="center" valign="middle" class="head-bg BillDate" onclick="sortTableBy('BillDate','dispLoadForm');">Inv&nbsp;Date</th>
					</cfcase>

					<cfcase value="UserDef7">
						<th align="center" valign="middle" class="head-bg agent" onclick="sortTableBy('userDefinedFieldTrucking','dispLoadForm');">#request.qGetSystemSetupOptions.UserDef7#</th>
					</cfcase>

					<cfcase value="Internal Ref##">
						<th align="center" valign="middle" class="head-bg agent" onclick="sortTableBy('InternalRef','dispLoadForm');">Internal&nbsp;Ref##</th>
					</cfcase>
					<cfcase value="Type">
						<th align="center" valign="middle" class="head-bg" onclick="sortTableBy('Equipments.EquipmentType','dispLoadForm');">Type</th>
					</cfcase>
					<cfcase value="Rel. Equip">
						<th align="center" valign="middle" class="head-bg" onclick="sortTableBy('RelEquip.EquipmentName','dispLoadForm');">Rel.&nbsp;Equip</th>
					</cfcase>
					<cfcase value="Bill From">
						<th align="center" valign="middle" class="head-bg" onclick="sortTableBy('ISNULL(BillFromCompanies.Companyname,Companies.CompanyName)','dispLoadForm');">Bill From</th>
					</cfcase>
					<cfcase value="Dispatcher 2">
						<th align="center" valign="middle" class="head-bg" onclick="sortTableBy('L.Dispatcher2Name','dispLoadForm');">Dispatcher&nbsp;2</th>
					</cfcase>
					</cfswitch>
					</cfif>
				</cfloop>
				<th width="5" align="right" valign="top" class="fillHeaderRight">
				</th>
			  </tr>
			  </thead>
				<tbody>					
					<cfif qLoads.recordcount eq 0>
						<script> showErrorMessage('block'); </script>
					<cfelse>
						<script> showErrorMessage('none'); </script>
						<cfset variables.counter=0>
						<cfloop query="qLoads">
							<cfif isdefined('url.event') AND url.event eq 'exportData' AND qLoads.ARExportedNN eq '1' AND qLoads.APExportedNN eq '1' >
								<cfcontinue>
							<cfelseif isdefined('url.event') AND url.event eq 'exportData'>
								<cfif not isdefined('form.orderDateFrom')>
									<cfset dateFrom = DateFormat('01/01/1900','mm/dd/yyyy')>
								<cfelse>
									<cfset dateFrom = DateFormat(form.orderDateFrom,'mm/dd/yyyy')>
								</cfif>

								<cfif not isdefined('form.orderDateTo')>
									<cfset dateTo = DateFormat(NOW(),'mm/dd/yyyy')>
								<cfelse>
									<cfset dateTo = DateFormat(form.orderDateTo,'mm/dd/yyyy')>
								</cfif>

								<cfif not isdefined('request.qLoads.orderDate') OR request.qLoads.orderDate eq ''>
									<cfset orderDate = DateFormat(NOW(),'mm/dd/yyyy')>
								<cfelse>
									<cfset orderDate = DateFormat(qLoads.orderDate,'mm/dd/yyyy')>
								</cfif>

								<cfif orderDate gte dateFrom AND orderDate lte dateTo>
									<!--- Do nothing, keep the normal flow --->
								<cfelse>
									<cfcontinue>
								</cfif>
							</cfif>
							<cfset request.ShipperStop = qLoads>
							<cfset request.ConsineeStop = qLoads>							<!---BEGIN: 771: All Loads/ My Loads must show first shipper and last consignee --->
							<cfinvoke component="#variables.objloadGateway#" method="getFirstShipperDeatils" LoadID="#qLoads.Loadid#" returnvariable="request.qFirstShipperDeatils" />
							<cfinvoke component="#variables.objloadGateway#" method="getLastConsineeDeatils" LoadID="#qLoads.Loadid#" returnvariable="request.qLastConsineeDeatils" />
							<!---END: 771: All Loads/ My Loads must show first shipper and last consignee --->
							<cfset pageSize = 30>
							<cfif structKeyExists(request.qSystemSetupOptions1, "rowsperpage") AND request.qSystemSetupOptions1.rowsperpage>
								<cfset pageSize = request.qSystemSetupOptions1.rowsperpage>
							</cfif>

							<cfif isdefined("form.pageNo")>
								<cfset rowNum=(qLoads.currentRow) + ((form.pageNo-1)*pageSize)>
							<cfelse>
								<cfset rowNum=(qLoads.currentRow)>
							</cfif>
							<cfif structKeyExists(session, "currentusertype") AND session.currentusertype EQ "Administrator">
								<cfset onRowClick = "document.location.href='index.cfm?event=addload&loadid=#qLoads.LOADID#&#session.URLToken#'">
								<cfset onHrefClick = "index.cfm?event=addload&loadid=#qLoads.LOADID#&#session.URLToken#">
							<cfelse>
								<cfset onRowClick = "document.location.href='index.cfm?event=addcustomerload&loadid=#qLoads.LOADID#&#session.URLToken#'">
								<cfset onHrefClick = "index.cfm?event=addcustomerload&loadid=#qLoads.LOADID#&#session.URLToken#">
							</cfif>
							<tr style="background:###qLoads.ColorCode#; cursor:pointer;" onmouseover="this.style.background = '##FFFFFF';" onmouseout="this.style.background = '###qLoads.ColorCode#';" <cfif qLoads.Row mod 2 eq 0>bgcolor="##FFFFFF"<cfelse>bgcolor="##f7f7f7"</cfif>>
								<td height="20" class="sky-bg">&nbsp;</td>
								<td align="center" valign="middle" nowrap="nowrap" class="sky-bg2" onclick="#onRowClick#">#rowNum#</td>
								<cfif request.qSystemSetupOptions1.rolloverShipDateStatus AND structKeyExists(request, "qrygetAgentdetails") AND structKeyExists(request.qrygetAgentdetails, "ROLEID") AND request.qrygetAgentdetails.ROLEID neq 7>
									<cfif isdefined('url.event') AND url.event neq 'exportData'>
										<td align="center" valign="middle" nowrap="nowrap" class="sky-bg2 " style="padding: 0 5px 0 5px;" >
											<cfif ListContains(replace(session.editableStatuses," ","","ALL"),replace(qLoads.STATUSTEXT," ","","ALL"),',') AND NOT qLoads.ForceNextStatus>
												<cfinput type="checkbox" name="rolloverShipDateCheckSub" id="rolloverShipDateCheckSub" class="checkboxSelect ckLanes" value="#qLoads.loadNumber#" data-loadid = "#qLoads.loadid#" data-carrierid="#qLoads.CarrierID#" data-status="#qLoads.StatusTypeID#">
											<cfelse>
												<cfinput type="checkbox" name="rolloverShipDateCheckSub" id="rolloverShipDateCheckSub" class="checkboxSelect ckLanes" value="#qLoads.loadNumber#" data-code="disabled" data-status='#qLoads.StatusTypeID#' data-loadid = "#qLoads.loadid#" data-carrierid="#qLoads.CarrierID#">
											</cfif>
										</td>
									</cfif>
								</cfif>
								<input type="hidden" name="StatusText#qLoads.loadNumber#" id="StatusText#qLoads.loadNumber#" value="#qLoads.STATUSTEXT#">
								<cfset loadsColumnStatus="#request.qGetSystemSetupOptions.LoadsColumnsStatus#">
								<cfloop list="#request.qGetSystemSetupOptions.LoadsColumns#" item="colname" index="i">	
								<cfset activeColumn = ListGetAt(loadsColumnStatus,i)>
								<cfif activeColumn EQ  1>
								<cfswitch expression="#colname#">
									<cfcase value="Load Number">
									<td align="left" valign="middle" nowrap="nowrap" class="normal-td" onclick="#onRowClick#"><a href="#onHrefClick#" style="color:###qLoads.TextColorCode#">#qLoads.loadNumber#</a></td>
									</cfcase>
									<cfcase value="Status">
									<td  align="left" valign="middle" nowrap="nowrap" class="normal-td" onclick="#onRowClick#"><a href="#onHrefClick#" style="color:###qLoads.TextColorCode#">#qLoads.StatusDescription# #qLoads.LoadStatusStopNo#</a></td>
									</cfcase>
									
									<cfcase value="Customer">
									<td  align="left" valign="middle" nowrap="nowrap" class="normal-td" onclick="#onRowClick#"><a href="#onHrefClick#" style="color:###qLoads.TextColorCode#">#qLoads.CustName#</a></td>
									</cfcase>
									<cfcase value="Po##">
									<td  align="left" valign="middle" nowrap="nowrap" class="normal-td" onclick="#onRowClick#"><a href="#onHrefClick#" style="color:###qLoads.TextColorCode#">#qLoads.CUSTOMERPONO#</a></td>
									</cfcase>
									<cfcase value="Pickup Date">
									<td align="left" valign="middle" nowrap="nowrap" class="normal-td" onclick="#onRowClick#"><a href="#onHrefClick#" style="color:###qLoads.TextColorCode#">#dateformat(qLoads.PICKUPDATE,'mm/dd/yyyy')#</a></td>
									</cfcase>
									<cfcase value="Pickup Time">
									<td align="left" valign="middle" nowrap="nowrap" class="normal-td" onclick="#onRowClick#"><a href="#onHrefClick#" style="color:###qLoads.TextColorCode#">#qLoads.PICKUPTIME#</a></td>
									</cfcase>
									<cfcase value="Delivery Time">
									<td align="left" valign="middle" nowrap="nowrap" class="normal-td" onclick="#onRowClick#"><a href="#onHrefClick#" style="color:###qLoads.TextColorCode#">#qLoads.DELIVERYTIME#</a></td>
									</cfcase>
									<cfcase value="Pickup City">
									<td align="left" valign="middle" nowrap="nowrap" class="normal-td" onclick="#onRowClick#"><a href="#onHrefClick#" style="color:###qLoads.TextColorCode#">#request.qFirstShipperDeatils.CITY#</a></td>
									</cfcase>
									<cfcase value="Pickup ST">
									<td align="left" valign="middle" nowrap="nowrap" class="normal-td" onclick="#onRowClick#"><a href="#onHrefClick#" style="color:###qLoads.TextColorCode#"><cfif request.qFirstShipperDeatils.StateCode NEQ 0>#request.qFirstShipperDeatils.StateCode#</cfif></a></td>
									</cfcase>
									<cfcase value="Delivery City">
									<td align="left" valign="middle" nowrap="nowrap" class="normal-td" onclick="#onRowClick#"><a href="#onHrefClick#" style="color:###qLoads.TextColorCode#">#request.qLastConsineeDeatils.CITY# </a></td>
									</cfcase>
									<cfcase value="Delivery ST">
									<td align="left" valign="middle" nowrap="nowrap" class="normal-td" onclick="#onRowClick#"><a href="#onHrefClick#" style="color:###qLoads.TextColorCode#"><cfif request.qLastConsineeDeatils.StateCode NEQ 0>#request.qLastConsineeDeatils.StateCode#</cfif></a></td>
									</cfcase>
									<cfcase value="Delivery Date">
									<td align="left" valign="middle" nowrap="nowrap" class="normal-td" onclick="#onRowClick#"><a href="#onHrefClick#" style="color:###qLoads.TextColorCode#">#dateformat(qLoads.DeliveryDATE,'mm/dd/yyyy')#</a></td>
									</cfcase>
									<cfcase value="Cust Amt">
									<cfif NOT ListContains(session.rightsList,'HideCustomerPricing',',')>
										<cfif request.qSystemSetupOptions1.ForeignCurrencyEnabled>
											<td align="right" valign="middle" nowrap="nowrap" class="normal-td custAmt" onclick="#onRowClick#"><a href="#onHrefClick#" style="color:###qLoads.TextColorCode#">#NumberFormat(qLoads.TOTALCUSTOMERCHARGES)# #qLoads.CUSTOMERCURRENCYISO#</a></td>
										<cfelse>
											<td align="right" valign="middle" nowrap="nowrap" class="normal-td custAmt" onclick="#onRowClick#"><a href="#onHrefClick#" style="color:###qLoads.TextColorCode#">#DollarFormat(qLoads.TOTALCUSTOMERCHARGES)#</a></td>
										</cfif>
									</cfif>
									</cfcase>
									<cfcase value="Carr Amt">
									<cfif customer NEQ 1 AND  NOT ListContains(session.rightsList,'HideFinancialRates',',')>
										<cfif request.qSystemSetupOptions1.ForeignCurrencyEnabled>
											<td align="right" valign="middle" nowrap="nowrap" class="normal-td carrAmt" onclick="#onRowClick#"><a href="#onHrefClick#" style="color:###qLoads.TextColorCode#">#NumberFormat(qLoads.TOTALCARRIERCHARGES)# #qLoads.CARRIERCURRENCYISO#</a></td>
											
										<cfelse>
											<td align="right" valign="middle" nowrap="nowrap" class="normal-td carrAmt" onclick="#onRowClick#"><a href="#onHrefClick#" style="color:###qLoads.TextColorCode#">#DollarFormat(qLoads.TOTALCARRIERCHARGES)#</a></td>
											
										</cfif>
									</cfif>
									</cfcase>
									<cfcase value="Miles">
									<!---BEGIN: 604: Add a column to All Loads/ My Loads --->
									<td align="right" valign="middle" nowrap="nowrap" class="normal-td carrAmt" onclick="#onRowClick#" style="padding-right: 3px;"><a href="#onHrefClick#" style="color:###qLoads.TextColorCode#">#numberformat(qLoads.Miles,"__.00")#</a></td>
									
									<!---END: 604: Add a column to All Loads/ My Loads --->
									</cfcase>
									<cfcase value="DH Miles">
									<!---BEGIN: 604: Add a column to All Loads/ My Loads : Add DeadHead Miles for Load--->
									<td align="right" valign="middle" nowrap="nowrap" class="normal-td carrAmt" onclick="#onRowClick#" style="padding-right: 3px;"><a href="#onHrefClick#" style="color:###qLoads.TextColorCode#">#qLoads.DeadHeadMiles#</a></td>
									
									<!---END: 604: Add a column to All Loads/ My Loads : Add DeadHead Miles for Load--->
									</cfcase>
									<cfcase value="Carr_Inv">
									<cfif isdefined('url.event') AND url.event neq 'myLoad'  AND  request.qSystemSetupOptions1.ShowCarrierInvoiceNumberInAllLoads EQ 1>
											<td align="right" valign="middle" nowrap="nowrap" class="normal-td carrAmt" onclick="#onRowClick#"><a href="#onHrefClick#" style="color:###qLoads.TextColorCode#">
											<cfif qLoads.CarrierInvoiceNumber NEQ 0>#qLoads.CarrierInvoiceNumber#</cfif>
											</a></td>
										</cfif>
									</cfcase>
									<cfcase value="Carrier/ Driver">
									<cfif customer neq 1>
										<td  align="left" valign="middle" nowrap="nowrap" class="normal-td" onclick="#onRowClick#">
											<a href="#onHrefClick#" style="color:###qLoads.TextColorCode#">#qLoads.CARRIERNAME#</a>
										</td>
									</cfif>
									</cfcase>
									<cfcase value="Equipment">
									<td  align="left" valign="middle" nowrap="nowrap" class="normal-td" onclick="#onRowClick#"><a href="#onHrefClick#" style="color:###qLoads.TextColorCode#">#qLoads.EquipmentName#</a></td>
									</cfcase>
									<cfcase value="Driver">
									<td  align="left" valign="middle" nowrap="nowrap" class="normal-td" onclick="#onRowClick#"><a href="#onHrefClick#" style="color:###qLoads.TextColorCode#">#qLoads.DriverName#</a></td>
									</cfcase>
									<cfcase value="Dispatcher">
									<td  align="left" valign="middle" nowrap="nowrap" class="normal-td" onclick="#onRowClick#"><a href="#onHrefClick#" style="color:###qLoads.TextColorCode#">#qLoads.empDispatch#</a></td>
									</cfcase>
									<cfcase value="Sales Rep">
									<td  align="left" valign="middle" nowrap="nowrap" class="normal-td" onclick="#onRowClick#"><a href="#onHrefClick#" style="color:###qLoads.TextColorCode#">#qLoads.empAgent#</a></td>
									</cfcase>
									<cfcase value="Map">
										<td  align="left" valign="middle" nowrap="nowrap" class="normal-td">
											<input style="width: 50px !important;font-size: 10px;height: 18px;" name="map-button" type="button" class="black-btn" onclick="showfullmap('#qLoads.Loadid#')" value="Map" />
										</td>
									</cfcase>
									<cfcase value="Invoice Date">
									<td  align="left" valign="middle" nowrap="nowrap" class="normal-td" onclick="#onRowClick#"><a href="#onHrefClick#" style="color:###qLoads.TextColorCode#">#dateformat(qLoads.BillDate,'mm/dd/yyyy')#</a></td>
									</cfcase>
									<cfcase value="UserDef7">
									<td  align="left" valign="middle" nowrap="nowrap" class="normal-td" onclick="#onRowClick#"><a href="#onHrefClick#" style="color:###qLoads.TextColorCode#">#qLoads.userDefinedFieldTrucking#</a></td>
									</cfcase>
									<cfcase value="Internal Ref##">
									<td  align="left" valign="middle" nowrap="nowrap" class="normal-td" onclick="#onRowClick#"><a href="#onHrefClick#" style="color:###qLoads.TextColorCode#">#qLoads.InternalRef#</a></td>
									</cfcase>
									<cfcase value="Type">
										<td  align="left" valign="middle" nowrap="nowrap" class="normal-td" onclick="#onRowClick#"><a href="#onHrefClick#" style="color:###qLoads.TextColorCode#">#qLoads.EquipmentType#</a></td>
									</cfcase>
									<cfcase value="Rel. Equip">
										<td  align="left" valign="middle" nowrap="nowrap" class="normal-td" onclick="#onRowClick#"><a href="#onHrefClick#" style="color:###qLoads.TextColorCode#">#qLoads.RelEquip#</a></td>
									</cfcase>
									<cfcase value="Bill From">
										<td  align="left" valign="middle" nowrap="nowrap" class="normal-td" onclick="#onRowClick#"><a href="#onHrefClick#" style="color:###qLoads.TextColorCode#">#qLoads.BillFrom#</a></td>
									</cfcase>
									<cfcase value="Dispatcher 2">
										<td  align="left" valign="middle" nowrap="nowrap" class="normal-td" onclick="#onRowClick#"><a href="#onHrefClick#" style="color:###qLoads.TextColorCode#">#qLoads.Dispatcher2Name#</a></td>
									</cfcase>
									</cfswitch>
								</cfif>
							</cfloop>
									<td class="normal-td3">&nbsp;</td>
							</tr>
							<cfset variables.counter++>
						</cfloop>
					</cfif>
				</tbody>
				<tfoot>
					<tr>
					<td width="5" align="left" valign="top"><img src="images/left-bot.gif" alt="" width="5" height="23" /></td>
					<td colspan='16' align="left" valign="middle" class="footer-bg" id="tblLoadListFooter">
						<div class="up-down">
							<div class="arrow-top"><a href="javascript: tablePrevPage('dispLoadForm');"><img src="images/arrow-top.gif" alt="" /></a></div>
							<div class="arrow-bot"><a href="javascript: tableNextPage('dispLoadForm');"><img src="images/arrow-bot.gif" alt="" /></a></div>
						</div>

						<div class="gen-left" style="font-size: 14px;">
			              <cfif qLoads.recordcount>
			              	<button type="button" class="bttn_nav" onclick="tablePrevPage('dispLoadForm');">PREV</button>
			                  <input type="text" onkeyup="if (/\D/g.test(this.value)) this.value = this.value.replace(/\D/g,'')" value="<cfif structKeyExists(form, "pageNo")>#form.pageNo#<cfelse>1</cfif>" id="jumpPageNo" style="text-align: center;width: 25px;" onchange="jumpToPage('dispLoadForm')">
			                      <input type="hidden" id="TotalPages" value="#qLoads.TotalPages#">
			                  of #qLoads.TotalPages#
			                  <button type="button" class="bttn_nav" onclick="tableNextPage('dispLoadForm');">NEXT</button>
			              </cfif>
			          </div>
						<div class="gen-right"><img src="images/loader.gif" alt="" /></div>
						<div class="clear"></div>
					</td>
					<td class="footer-bg"></td>
					<td class="footer-bg"></td>
					<td width="6" align="right" valign="top"><img src="images/right-bot.gif" alt="" width="5" height="23" /></td>
				 </tr>
				 </tfoot>
			</table>
		</cfif>
</cfform>
</cfif>
  <div id="responseCopyLoad"></div>
  <div class="overlay">
	</div>
	<img src="images/loadingbar.gif" id="loader">
	<strong id="loadingmsg">Uploading loads.It will take some time.Please Wait.</strong>
	<div id="loadernew">
		<img src="images/loadDelLoader.gif" style="width:200px">
		<p id="loadingmsgnew"></p>
	</div>
</cfoutput>



