<cfheader name="expires" value="#now()#">
<cfheader name="pragma" value="no-cache">
<cfheader name="cache-control" value="no-cache, no-store, must-revalidate">
<cfoutput>
<cfsilent>	
<!---Init the default value------->       
<cfparam name="integratewithTran360" default="">
<cfparam name="trans360Usename" default="">
<cfparam name="trans360Password" default="">
<cfparam name="loadBoard123Usename" default="">
<cfparam name="loadBoard123Password" default="">
<cfparam name="loadBoard123" default="">
<cfparam name="integrationID" default="">
<cfparam name="FA_empcode" default="">
<cfparam name="FA_name" default="">
<cfparam name="FA_roleid" default="">

<cfparam name="FA_createdatetime" default="">
<cfparam name="FA_createby" default="">
<cfparam name="FA_lastmodifidatetime" default="">
<cfparam name="FA_lastmodifiedby" default="">
<cfparam name="FA_ipaddress" default="">
<cfparam name="FA_email" default="">
<cfparam name="FA_smtpAddress" default="">
<cfparam name="FA_smtpUsername" default="">
<cfparam name="FA_smtpPassword" default="">
<cfparam name="FA_smtpPort" default="">
<cfparam name="FA_TLS" default="">
<cfparam name="FA_SSL" default="">
<cfparam name="FA_logindate" default="">
<cfparam name="FA_totallogins" default="">
<cfparam name="FA_office" default="">
<cfparam name="FA_password" default="">
<cfparam name="FA_dispatcherid" default="">

<cfparam name="url.agent_id" default="0">
<cfparam name="editId" default="0">
<cfparam name="fa_isactive" default="False">
<cfparam name="address" default="">
<cfparam name="city" default="">
<cfparam name="state" default="">
<cfparam name="country" default="">
<cfparam name="state1" default="">
<cfparam name="country1" default="9bc066a3-2961-4410-b4ed-537cf4ee282a">
<cfparam name="Zipcode" default="">
<cfparam name="tel" default="">
<cfparam name="telextension" default="">
<cfparam name="cel" default="">
<cfparam name="celextension" default="">
<cfparam name="fax" default="">
<cfparam name="faxextension" default="">
<cfparam name="emailSignature" default="">
<cfparam name="loginid" default="">
<cfparam name="FA_commonrate" default="0">
<cfparam name="editid" default="0">
<cfparam name="defaultCurrency" default="0">
<cfparam name="PEPcustomerKey" default="">

<cfparam name="IntegrateWithDirectFreightLoadboard" default="">
<cfparam name="DirectFreightLoadboardUserName" default="">
<cfparam name="DirectFreightLoadboardPassword" default="">

<cfparam name="LoadBoard123Default" default="0">
<cfparam name="IntegrateWithTran360Default" default="0">
<cfparam name="IntegrateWithDirectFreightLoadboardDefault" default="0">
<cfparam name="EmailValidated" default="0">
<cfset flag=1>
<cfparam name="variables.agentdisabledStatus" default="false"> 
<cfparam name="integratewithPEP" default="0">
<cfparam name="integratewithITS" default="0">
<cfparam name="integratewithPEPDefault" default="0">
<cfparam name="integratewithITSDefault" default="0">
<cfparam name="DefaultSalesRepToLoad" default="0">
<cfparam name="DefaultDispatcherToLoad" default="0">

<cfparam name="LoadCustomerCount" default="0">
<!--- Encrypt String --->
<cfset Secret = application.dsn>
<cfset TheKey = 'NAMASKARAM'>
<cfset Encrypted = Encrypt(Secret, TheKey)>
<cfset dsn = URLEncodedFormat(ToBase64(Encrypted))>
	
<cfinvoke component="#variables.objLoadGateway#" method="getLoadStatusTypes" returnvariable="request.qLoadStatusTypes" />
<cfinvoke component="#variables.objloadGateway#" method="getSystemSetupOptions" returnvariable="request.qSystemSetupOptions" />
<cfif request.qSystemSetupOptions.ForeignCurrencyEnabled>
	<cfinvoke component="#variables.objloadGateway#" method="getCurrencies" IsActive="1" returnvariable="request.qGetCurrencies" />
</cfif>

<cfif structkeyexists(url,"agentid")>
	<cfinvoke component="#variables.objAgentGateway#" method="getAgentsLoadStatusTypes" agentId="#url.agentid#" returnvariable="qAgentsLoadStatusTypes" />	
	<cfset agentsLoadStatusTypesArray = valueList(qAgentsLoadStatusTypes.loadStatusTypeID)>
<cfelse>	
	<cfset qAgentsLoadStatusTypes="">
	<cfset agentsLoadStatusTypesArray = "">
</cfif>
<cfinvoke component="#variables.objloadGateway#" method="getcurAgentMaildetails" returnvariable="request.qcurMailAgentdetails" employeID="#session.empid#" />
	<cfif request.qcurMailAgentdetails.recordcount gt 0 and (request.qcurMailAgentdetails.SmtpAddress eq "" or request.qcurMailAgentdetails.SmtpUsername eq "" or request.qcurMailAgentdetails.SmtpPort eq "" or request.qcurMailAgentdetails.SmtpPassword eq "" or request.qcurMailAgentdetails.SmtpPort eq 0)>
	  <cfset mailsettings = "false">
  <cfelse>
	  <cfset mailsettings = "true">
  </cfif>
<cfinvoke component="#variables.objloadGateway#" method="getcurAgentdetails" returnvariable="request.qcurAgentdetails" employeID="#session.empid#" />
<cfif (isdefined("url.agentId") and len(trim(url.agentId)) gt 1) OR isdefined("url.CopyAgentID")>
<cfif isdefined("url.agentId") and len(trim(url.agentId)) gt 1>
	<cfinvoke component="#variables.objAgentGateway#" method="getAllAgent" agentId="#url.agentID#" returnvariable="request.qAgent" />
<cfelse>
	<cfinvoke component="#variables.objAgentGateway#" method="getAllAgent" agentId="#url.CopyAgentID#" returnvariable="request.qAgent" />
</cfif>

<cfset FA_email=#request.qAgent.emailID#>
<cfset FA_office=#request.qAgent.officeID#>
<cfset FA_commonrate=#request.qAgent.SalesCommission#>
<cfset FA_roleid = #request.qAgent.roleID#>
<cfset FA_empcode = #request.qAgent.employeeCode#>

<cfset FA_dispatcherid = #request.qAgent.DispatcherID#>

<cfif isDefined("url.agentID") and len(trim(url.agentID)) gt 1>
	<cfset loginid = #request.qAgent.loginid#>
	<cfset FA_name=#request.qAgent.name#>
	<cfset FA_password=#request.qAgent.password#>
	<cfset editid="#url.agentId#">
</cfif>
<cfset fa_isactive = #request.qAgent.isActive#>
<cfset address = #request.qAgent.address#>
<cfset city = #request.qAgent.city#>
<cfset state1 = #request.qAgent.state#>
<cfset Zipcode = #request.qAgent.zip#>
<cfset country1 = #request.qAgent.country#>
<cfset Tel = #request.qAgent.telephone#>
<cfset telextension=#request.qAgent.PhoneExtension#>
<cfset cel = #request.qAgent.cel#>
<cfset celextension=#request.qAgent.celextension#>
<cfset fax = #request.qAgent.fax#>
<cfset faxextension=#request.qAgent.faxextension#>
<cfset emailSignature = #request.qAgent.emailSignature#>
<cfset statustypeid=#request.qLoadStatusTypes.statustypeid#>
<cfset statustypetext=#request.qLoadStatusTypes.statustext# >
<cfset integratewithTran360 =#request.qAgent.integratewithTran360#>
<cfset trans360Usename =#request.qAgent.trans360Usename#>
<cfset trans360Password =#request.qAgent.trans360Password#>
<cfset IntegrateWithDirectFreightLoadboard =#request.qAgent.IntegrateWithDirectFreightLoadboard#>
<cfset DirectFreightLoadboardUserName =#request.qAgent.DirectFreightLoadboardUserName#>
<cfset DirectFreightLoadboardPassword =#request.qAgent.DirectFreightLoadboardPassword#>
<cfset integrationID =#request.qAgent.integrationID#>
<cfset FA_smtpAddress=#request.qAgent.SmtpAddress#>
<cfset FA_smtpUsername=#request.qAgent.SmtpUsername#>
<cfset FA_smtpPassword=#request.qAgent.SmtpPassword#>
<cfset FA_smtpPort=#request.qAgent.SmtpPort#>
<cfset loadBoard123Usename=#request.qAgent.loadBoard123Usename#>
<cfset loadBoard123Password=#request.qAgent.loadBoard123Password#>
<cfset loadBoard123=#request.qAgent.loadBoard123#>
<cfset PEPcustomerKey =#request.qAgent.PEPcustomerKey#>
<cfset LoadBoard123Default =#request.qAgent.LoadBoard123Default#>
<cfset IntegrateWithTran360Default =#request.qAgent.IntegrateWithTran360Default#>
<cfset IntegrateWithDirectFreightLoadboardDefault =#request.qAgent.IntegrateWithDirectFreightLoadboardDefault#>
<cfset EmailValidated =#request.qAgent.EmailValidated#>
<cfset integratewithPEP =#request.qAgent.integratewithPEP#>
<cfset integratewithITS =#request.qAgent.integratewithITS#>
<cfset integratewithPEPDefault =#request.qAgent.integratewithPEPDefault#>
<cfset integratewithITSDefault =#request.qAgent.integratewithITSDefault#>
<cfset DefaultSalesRepToLoad =#request.qAgent.DefaultSalesRepToLoad#>
<cfset DefaultDispatcherToLoad =#request.qAgent.DefaultDispatcherToLoad#>
<cfset LoadCustomerCount =#request.qAgent.LoadCustomerCount#>
<cfif request.qAgent.useTLS eq "true">
	<cfset FA_TLS="TLS">
<cfelseif request.qAgent.useSSL eq "true">
	<cfset FA_SSL="SSL">
</cfif>

<cfset defaultCurrency=#request.qAgent.defaultCurrency#>

<cfset flag=0>
<cfelse>
	<cfif len(trim(request.qSystemSetupOptions.DefaultCountry))>
		<cfset country1 = request.qSystemSetupOptions.DefaultCountry>
	</cfif>
</cfif>
</cfsilent>
<script>			
$(document).ready(function(){
//when the page loads for agent edit, ajax call for inserting tab id of the page details
var path = urlComponentPath+"agentgateway.cfc?method=insertTabDetails";

$.ajax({
	type: "Post",
	url: path,
	dataType: "json",
	async: false,
	data: {
		tabID:tabID,
		agentid:'#request.qAgent.EmployeeID#',
		userid:'#session.empid#',
		sessionid:'#session.sessionid#',
		dsn:'#application.dsn#'
	},
	success: function(data){
	//  console.log(data);
	}
});

});
</script>

<cfinvoke component="#variables.objAgentGateway#" method="getUserEditingDetails" agentid ="#request.qAgent.EmployeeID#" returnvariable="request.qryAgentEditingDetails"/>
<!---Condition to check user edited the agent or not--->
<cfif not len(trim(request.qryAgentEditingDetails.InUseBy))>

<!---Object to update corresponding user edited the agent--->
	<cfinvoke component="#variables.objAgentGateway#" method="updateEditingUserId" agentid="#request.qAgent.EmployeeID#"
	 userid="#session.empid#" status="false"/>
	<cfset session.currentAgentId = #request.qAgent.EmployeeID#/>
<cfelse>
<!---Object to get corresponding Previously edited---->
	<cfinvoke component="#variables.objAgentGateway#" method="getEditingUserName" returnvariable="request.qryGetEditingUserName" employeID="#request.qryAgentEditingDetails.inuseby#" />

<!---Condition to check current employee and previous editing agent are not same--->
	<cfif session.empid neq request.qryAgentEditingDetails.inuseby and structKeyExists(url, "agentid")>
		
		<cfif request.qryGetEditingUserName.recordcount>
			<cfset variables.agentdisabledStatus=true>
			<div class="msg-area" style="margin-left:10px;margin-bottom:10px">
				<span style="color:##d21f1f">
					This agent locked because it is currently being edited by #request.qryGetEditingUserName.Name# #dateformat(request.qryAgentEditingDetails.inuseon,"mm/dd/yy hh:mm:ss")#.An Administrator can manually override this lock by clicking the unlock button.
				</span>
			</div>
		</cfif>

	</cfif>	

</cfif>


<script type="text/javascript" language="javascript" src="javascripts/jquery.js?ver=20220413"></script>
<script type='text/javascript' language="javascript" src='javascripts/jquery.autocomplete.js'></script>
<script type="text/javascript">
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
		$("##City").autocomplete('searchCityAutoFill.cfm', {
		extraParams: {queryType: 'getCity'},
		multiple: false,
		width: 400,
		scroll: true,
		scrollHeight: 300,
		cacheLength: 1,
		highlight: false,
		dataType: "json",
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
		strId = this.id;
		$('##state').val(data.state);
		$('##Zipcode').val(data.zip);

		});
	
		//zip AutoComplete
		$("##Zipcode").autocomplete('searchCityAutoFill.cfm', {
		
		extraParams: {queryType: 'GetZip'},
		multiple: false,
		width: 400,
		scroll: true,
		scrollHeight: 300,
		cacheLength: 5,
		minLength: 5,
		highlight: false,
		dataType: "json",
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
		});
	
		
		
	
});
function popitup(url) {
	newwindow=window.open(url,'Map','height=600,width=900');
	if (window.focus) {newwindow.focus()}
	return false;
}
			
</script>




<cfif ListContains(session.rightsList,'addEditDeleteAgents',',')>
	<cfif LoadCustomerCount EQ 0>
		<cfset deleteLinkURL = "index.cfm?event=agent&agentId=#editid#&#session.URLToken#&sortorder=asc&sortby=Name">
	    <cfset deleteLinkOnClick = "return confirm('Are you sure to delete this record?');">
	<cfelse>
	    <cfset deleteLinkURL = "javascript: alert('Deletion not allows because this user exists on Load and/or Customer profiles. Please set the user to INACTIVE in order to hide them from the system drop down lists.')">
	    <cfset deleteLinkOnClick = "">
	</cfif>
<cfelse>
    <cfset deleteLinkURL = "javascript: alert('Sorry!! you don\'t have rights to delete an Agent.')">
    <cfset deleteLinkOnClick = "">
</cfif>

<cfif isdefined("url.agentId") and len(trim(url.agentId)) gt 1>
<cfinvoke component="#variables.objAgentGateway#" method="getAttachedFiles" linkedid="#url.agentId#" fileType="4" returnvariable="request.filesAttached" /> 


<div style="clear:both"></div>
	<cfif isdefined("session.message") and len(session.message)>
	<div id="message" class="msg-area" style="width:500px">#session.message#<cfif structKeyExists(url, 'Palert') and trim(url.Palert) neq "1"> #url.palert#</cfif></div>
	<cfset exists= structdelete(session, 'message', true)/> 
	</cfif>
	<div style="clear:both"></div>


<div class="search-panel"><div class="delbutton">
<cfif agentdisabledStatus neq true>
<a href="#deleteLinkURL#" onclick="#deleteLinkOnClick#">  Delete</a>
	</cfif>
</div></div>
<h1>Edit User <span style="padding-left:180px;">#ucase(FA_name)#</span></h1>
<div style="clear:left"></div>
	<div class="white-con-area" style="height: 36px;background-color: ##82bbef;">
		<div style="float: left; width: 40%;" id="divUploadedFiles">
			<cfif agentdisabledStatus neq true>
			<cfif request.filesAttached.recordcount neq 0>
			&nbsp;<a style="display:block;font-size: 13px;padding-left: 2px;color:white;" href="##" onclick="popitup('../fileupload/multipleFileupload/MultipleUpload.cfm?id=#url.agentId#&attachTo=4&user=#session.adminusername#&dsn=#dsn#&attachtype=Agent&CompanyID=#session.CompanyID#')"><img style="vertical-align:bottom;" src="images/attachment.png">View/Attach Files</a>
			<cfelse>
				&nbsp;<a style="display:block;font-size: 13px;padding-left: 2px;color:white;" href="##" onclick="popitup('../fileupload//multipleFileupload/MultipleUpload.cfm?id=#url.agentId#&attachTo=4&user=#session.adminusername#&dsn=#dsn#&attachtype=Agent&CompanyID=#session.CompanyID#')"><img style="vertical-align:bottom;" src="images/attachment.png">Attach Files</a>
			</cfif>
			</cfif>	
		</div>
		<div style="float: left; width: 60%;"><h2 style="color:white;font-weight:bold;">User Information</h2></div>
	</div>
<cfelse>
<cfset tempLoadId = #createUUID()#>
<cfset session.checkUnload ='add'>
<h1>Add New User</h1>
</cfif>
<div class="white-con-area">
<div class="white-top"></div>
<div class="white-mid">
<cfform name="frmAgent" action="index.cfm?event=addagent:process&#session.URLToken#" method="post">
	<cfinput type="hidden" id="editid" name="editId" value="#editId#">
	<cfinput type="hidden" id="companyid" name="companyid" value="#session.companyid#">
    <input type="hidden" id="SaveAndExit" name="SaveAndExit" value="0"/>
    
    <input type="hidden" name="agentdisabledStatus" id="agentdisabledStatus" value="#variables.agentdisabledstatus#">
    <input type="hidden" name="isSaveEvent" id="isSaveEvent" value="false"/>
    <input name="appDsn" id="appDsn" type="hidden" value="#application.dsn#">
    <input name="tabid" id="tabid" type="hidden" value="">

	<div class="form-con" style="border-right:1px solid ##B4C2CF;width: 402px;">
	<fieldset>
		<label>Name*</label>
        <cfinput type="text" name="FA_name" tabindex="1" value="#FA_name#" maxlength="50" size="25" required="yes" message="Please  enter the name">
        <div class="clear"></div>
		<label>Address*</label>
        <cftextarea type="text" tabindex="2" name="address">#address#</cftextarea>
        <div class="clear"></div>
		<label>City*</label>
		<cfif zipcode eq ''>
	        <cfinput type="text" name="city" id="City" maxlength="50" value="#city#" size="25" tabindex="3" required="yes" message="Please enter a city">
	    <cfelse>
	    	<cfinput type="text" name="city" id="City" maxlength="50" value="#city#" size="25" tabindex="4" required="yes" message="Please enter a city">
	    </cfif>
        <div class="clear"></div>
		<label>State*</label>
        <select name="state" id="state" <cfif zipcode eq ''> tabindex="4"<cfelse> tabindex="5"</cfif>>
        <option value="">Select</option>
		<cfloop query="request.qStates">
             	<option value="#request.qStates.stateCode#" <cfif request.qStates.stateCode is state1> selected="selected" </cfif> >#request.qStates.stateCode#</option>	
		</cfloop>
		</select>
        <div class="clear"></div>
		<label>Zip*</label>
		<cfif zipcode neq ''>
	         <cfinput type="text" name="Zipcode" id="Zipcode" maxlength="50" tabindex="3" value="#zipcode#" size="25" required="yes" message="Please enter a valid zipcode">
	    <cfelse>
	    	 <cfinput type="text" name="Zipcode" id="Zipcode" maxlength="50" tabindex="5" value="#zipcode#" size="25" required="yes" message="Please enter a valid zipcode">    
	    </cfif>     
        <div class="clear"></div>
		<label>Country*</label>
       <select name="country" tabindex="6">
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
               		<label>Tel</label>
                        <input type="text" maxlength="50" name="tel" tabindex="7" value="#tel#" onchange="ParseUSNumber(this);" style="width:100px;">
               	    <label class="ex" style="width:16px;">Ext.</label>
               		<input type="text" name="telextension" tabindex="19" style="width:37px;" value="#telextension#" maxlength="10">
               	    <div class="clear"></div>

		<label>Cel</label>
        <cfinput type="text" name="cel" tabindex="8" maxlength="50" value="#cel#" style="width:100px;">
        <label class="ex" style="width:16px;">Ext.</label>
        <input type="text" name="celextension" tabindex="19" style="width:37px;" value="#celextension#" maxlength="10">
        <div class="clear"></div>
		<label>Fax</label>
        <cfinput type="text" name="fax" tabindex="9" maxlength="50" value="#fax#" style="width:100px;">
        <label class="ex" style="width:16px;">Ext.</label>
        <input type="text" name="faxextension" tabindex="19" style="width:37px;" value="#faxextension#" maxlength="10">
        <div class="clear"></div>
	
		<div class="clear"  style="border-top: 1px solid ##B4C2CF;padding-top:5px;padding-bottom: 19px;margin-top: 12px;">&nbsp;</div>
		<label>Email*</label>
		<cfinput class="emailbox" type="text" name="FA_email" tabindex="10" value="#FA_email#" maxlength="50" required="yes" message="Please enter a valid email">
		<div class="clear"></div>
		<label>SMTP server address</label>
		<cfinput type="text" name="FA_smtpAddress" tabindex="11" value="#FA_smtpAddress#" maxlength="200"  autocomplete="off">	
		<div class="clear"></div>
		<label>SMTP user name</label>
		<cfinput type="text" name="FA_smtpUsername" tabindex="12" value="#FA_smtpUsername#" maxlength="200"  autocomplete="off">	
		<div class="clear"></div>
		<label>SMTP password</label>
		<cfinput name="dummyPW" type="password" value="" style="width:0px;margin-left:-15px;opacity:0">
		<cfinput type="password" name="FA_smtpPassword" tabindex="13" value="#FA_smtpPassword#" maxlength="200" autocomplete="off">
		<i class="far fa-eye fa-eye-slash" style="margin-left: -25px; cursor: pointer; margin-top:6px;"></i>
		<div class="clear"></div>
		<label>SMTP port</label>
		<cfinput type="text" name="FA_smtpPort" tabindex="14" value="#FA_smtpPort#"  autocomplete="off" validate="integer" message="Please enter numeric value">
		<div class="clear"></div>
		<label>Use TLS</label>
		<input type="checkbox" value="TLS" tabindex="15" name="FA_SEC" id="FA_TLS"  <cfif FA_TLS EQ "TLS">checked="checked"</cfif>   style="width:12px;" />
		<label>Use SSL</label>
		<input type="checkbox" value="SSL" tabindex="16" name="FA_SEC" id="FA_SSL"  <cfif FA_SSL EQ "SSL">checked="checked"</cfif>   style="width:12px;" />
		<div class="clear"></div>
		<label style="width:130px;">Verify SMTP settings <i style="font-size: 10px;">(Email <cfif NOT EmailValidated>Not</cfif> Validated)</i></label>
		<input type="checkbox" name="verifySMTP" id="verifySMTP" style="width:12px;" tabindex="17"/>
		<div class="clear"></div>
		<label>E-mail Signature</label>
		<div class="clear"></div>
        <cftextarea type="text" tabindex="18" name="emailSignature" style="width: 337px;height: 125px;margin-left: 15px;margin-bottom: 23px;">#emailSignature#</cftextarea>
		<div class="clear"  style="border-top: 1px solid ##B4C2CF;padding-top:5px;padding-bottom: 19px;margin-top: 12px;">&nbsp;</div>
		<div class="clear"></div>
		<label style="width:200px">Default this User to Load SalesRep:</label>
		<input type="checkbox" value="SSL" tabindex="16" name="DefaultSalesRepToLoad" id="DefaultSalesRepToLoad"  <cfif DefaultSalesRepToLoad EQ 1>checked="checked"</cfif>   style="width:12px;" />
		<div class="clear"></div>
		<label style="width:200px">Default this User to Load Dispatcher:</label>
		<input type="checkbox" value="SSL" tabindex="16" name="DefaultDispatcherToLoad" id="DefaultDispatcherToLoad"  <cfif DefaultDispatcherToLoad EQ 1>checked="checked"</cfif>   style="width:12px;" />
		</fieldset>
		</div>
		<div class="form-con">
		<fieldset>	
		<div class="right">

       <div style="padding-left:150px;"> 
       
       <cfif ListContains(session.rightsList,'addEditDeleteAgents',',')>
       		<cfset saveAgentOnClick = "validateAgent(frmAgent,'#application.dsn#',#flag#)">
       <cfelse>
        	<cfset saveAgentOnClick = "return false">
       </cfif>
        <input id="mailDocLink" type="button" class="bttn"value="Email Doc" data-allowmail="#mailsettings#"/><div class="clear"></div>
		<cfif structKeyExists(url, 'agentid')>
			<cfif structKeyExists(url, 'agentid')>
				<cfset agentID = url.agentID>
			<cfelse>
				<cfset agentID = "">
			</cfif>
			<input id="copyUser" type="button" class="bttn"value="Copy User" onclick="window.open('index.cfm?event=addagent&CopyAgentID=#agentID#&#session.URLToken#','_blank');"/><div class="clear"></div>
		</cfif>
			
  <cfif agentdisabledStatus neq true>
         <input  type="submit" name="submit" onfocus="checkUnload();" class="bttn" value="Save" style="width:112px;" onclick="if(#saveAgentOnClick#){saveExit(0);}else{return false;}" <cfif saveAgentOnClick eq ''>disabled="disabled"</cfif> />
         <input  type="submit" name="submit" onfocus="checkUnload();" class="bttn" value="Save & Exit" style="width:112px;" onclick="if(#saveAgentOnClick#) {saveExit(1);}else{return false;}" <cfif saveAgentOnClick eq ''>disabled="disabled"</cfif> />
 <cfelse>
         	<!--- check if user has rights for unlocking --->
         	<cfif structKeyExists(session, 'rightsList') and ListContains(session.rightsList,'UnlockAgent',',')>
         		<input id="Unlock" name="unlock" type="button"  style="width:112px;" class="bttn" onClick="removeAgentEditAccess('#request.qAgent.employeeId#');" value="Unlock">         		
         	</cfif> 

         </cfif>
         
         
        <input  type="button" onclick="javascript:history.back();" name="back" class="bttn" value="Back" style="width:70px;" />
       </div>

	    </div>		
        <label>Login*</label>
		<cfinput type="text" name="loginidAutoDummy" id="loginidAutoDummy" maxlength="100" tabindex="23" value="#loginid#" style="display:none;">
		<cfinput type="text" name="loginid" id="loginid" maxlength="100" tabindex="23" value="#loginid#" required="yes" message="Please enter a loginid">
        <div class="clear"></div>
        <label>Password*</label>
        <cfinput type="password" id="password"  name="FA_password" maxlength="50" tabindex="24" value="#FA_password#" >
		<i class="far fa-eye fa-eye-slash" style="margin-left: -25px; cursor: pointer; margin-top:6px;"></i>
        <div class="clear"></div>
		<label>Role*</label>
		<select name="FA_roleid" tabindex="25">            
        <option value="">Select</option>
		<cfloop query="request.qRoles">            
        	<option value="#request.qRoles.roleid#" <cfif request.qRoles.roleid is FA_roleid OR(NOT Len(FA_roleid) AND request.qRoles.roleValue eq 'Administrator')> selected="selected"</cfif>><cfif lcase(request.qRoles.roleValue) eq "lmadmin">Admin<cfelse>#request.qRoles.roleValue#</cfif> </option>	
		</cfloop>
		</select>
        <div class="clear"></div>
		<label>Active*</label>
		<cfselect  name="FA_isactive" tabindex="26">
		<option value="True" <cfif fa_isactive is 'True'>selected ="selected"</cfif>>True</option>
		<option value="False" <cfif fa_isactive is 'False'>selected ="selected"</cfif>>False</option>
		</cfselect>
		<div class="clear"></div>
        <label>Offices *</label>
		<select name="FA_office" tabindex="27">
		    <option value="">Select..</option>            
			<cfloop query="request.qOffices">
			<option value="#request.qOffices.officeid#" <cfif FA_office is request.qOffices.officeid>selected ="selected"</cfif>>#request.qOffices.location#</option>
		    </cfloop>
		</select>
		<div class="clear"></div>
		<label>Sales Commission</label>
		<cfinput type="text" name="FA_commonrate" tabindex="28" value="#numberformat(FA_commonrate,'0.00')#" validate="float" message="Please enter numeric value">%
        <div class="clear"></div>
		
		<cfif request.qSystemSetupOptions.ForeignCurrencyEnabled>
			<label>Default Currency</label>
			<select name="defaultCurrency" id="defaultCurrency">
				<option value="" >Select Currency</option>
				<cfloop query = "request.qGetCurrencies"> 
					<option value="#CurrencyID#" <cfif defaultCurrency eq CurrencyID> selected="selected" </cfif>>#CurrencyNameISO#(#CurrencyName#)</option>
				</cfloop>		
			</select>
			<div class="clear"></div>
		</cfif>
		
		<div class="clear"  style="border-top: 1px solid ##B4C2CF;padding-top:5px;padding-bottom: 19px;margin-top: 12px;">&nbsp;</div>
        <table>
			<tr><td style="text-align:left"><label>Asigned Load Type</label></td><td style="padding-left:45px;"><strong>Status</strong></td></tr>
		</table>
		<div style="padding-left:30px; float:left; padding-top:20px;">"Use CTL + Mouse"</div>
	
		
 
		<div style="float:left; padding-left:10px; ">
			<select name="AsignedLoadType" id="AsignedLoadType" tabindex="29" multiple="multiple" size="5" style="height:145px; padding:5px 0px; width:150px">
 
			  <cfloop query="request.qLoadStatusTypes">
				<option value="#request.qLoadStatusTypes.statustypeid#" <cfif ListContains(agentsLoadStatusTypesArray,'#request.qLoadStatusTypes.statustypeid#') OR (listLen(agentsLoadStatusTypesArray) EQ 0)>selected ="selected"</cfif>>#request.qLoadStatusTypes.StatusDescription#</option>
			  </cfloop>

			</select>
		</div>

		<div style="clear:both;"></div>
		
		<div class="clear"></div>
		
		<div <cfif request.qSystemSetupOptions.FreightBroker EQ 0>style="display:none;"</cfif>>
			<div class="clear"  style="border-top: 1px solid ##B4C2CF;<cfif #CGI.HTTP_USER_AGENT# CONTAINS "MSIE">margin-top:36px<cfelse>margin-top:36px;</cfif>padding-top:15px;">&nbsp;</div>
			<label>123 Load Board</label>
			<input type="checkbox" name="loadBoard123" tabindex="30" id="loadBoard123" <cfif loadBoard123 EQ true>checked="checked"</cfif>   style="width:12px;" onclick="enableDefaultPosting('LoadBoard123')"/>
			<div class="clear"></div>
		
			<label>User Name</label> 
			<input type="text" name="loadBoard123Usename" maxlength="200" tabindex="31" id="loadBoard123Usename"   value="#loadBoard123Usename#"     onkeyup="enableDefaultPosting('LoadBoard123')"/>
			<div class="clear"></div>
			<label>Password</label> 
			<input type="password" name="loadBoard123Password" maxlength="200" tabindex="32" id="loadBoard123Password"   value="#loadBoard123Password#" onkeyup="enableDefaultPosting('LoadBoard123')"/>
			<i class="far fa-eye fa-eye-slash" style="margin-left: -25px; cursor: pointer; margin-top:6px;"></i>
			<label>Default Posting</label>
			<input type="checkbox" name="LoadBoard123Default" tabindex="30" id="LoadBoard123Default" <cfif LoadBoard123Default EQ true AND loadBoard123 EQ true AND len(trim(loadBoard123Usename)) AND len(trim(loadBoard123Password))>checked="checked"</cfif>  <cfif loadBoard123 NEQ true OR NOT len(trim(loadBoard123Usename)) OR NOT len(trim(loadBoard123Password))>disabled </cfif> style="width:12px;" />
			<div class="clear"  style="border-top: 1px solid ##B4C2CF;margin-top:36px;padding-top:15px;">&nbsp;</div>

			<label>DirectFreight Load Board</label>
			<input type="checkbox" name="IntegrateWithDirectFreightLoadboard" tabindex="36" id="IntegrateWithDirectFreightLoadboard"  <cfif IntegrateWithDirectFreightLoadboard EQ 1>checked="checked"</cfif>   style="width:12px;" onclick="enableDefaultPosting('DirectFreight')"/>
			<div class="clear"></div>
			<label>User Name</label> 
			<input type="text" name="DirectFreightLoadboardUserName" tabindex="37" id="DirectFreightLoadboardUserName" maxlength="200" value="#DirectFreightLoadboardUserName#"   onkeyup="enableDefaultPosting('DirectFreight')"  />
			<div class="clear"></div>
			<label>Password</label> 
			<input type="password" name="DirectFreightLoadboardPassword" tabindex="38" id="DirectFreightLoadboardPassword" maxlength="200" value="#DirectFreightLoadboardPassword#" onkeyup="enableDefaultPosting('DirectFreight')"/>
			<i class="far fa-eye fa-eye-slash" style="margin-left: -25px; cursor: pointer; margin-top:6px;"></i>
			<label>Default Posting</label>
			<input type="checkbox" name="IntegrateWithDirectFreightLoadboardDefault" tabindex="30" id="IntegrateWithDirectFreightLoadboardDefault" <cfif IntegrateWithDirectFreightLoadboardDefault EQ true AND IntegrateWithDirectFreightLoadboard EQ true AND len(trim(DirectFreightLoadboardUserName)) AND len(trim(DirectFreightLoadboardPassword))>checked="checked"</cfif> <cfif IntegrateWithDirectFreightLoadboard NEQ true OR NOT len(trim(DirectFreightLoadboardUserName)) OR NOT len(trim(DirectFreightLoadboardPassword))>disabled </cfif>   style="width:12px;" />
			<div class="clear"  style="border-top: 1px solid ##B4C2CF;margin-top:14px;padding-top:15px;">&nbsp;</div>

			<label>LoadBoard Network</label>
			<input type="checkbox" name="integratewithPEP" tabindex="36" id="integratewithPEP"  <cfif integratewithPEP EQ 1>checked="checked"</cfif>   style="width:12px;" onclick="enableDefaultPosting('PEP')"/>
			<div class="clear"></div>
			<label>PE Customer Key</label> 
			<input type="text" name="PEPcustomerKey" maxlength="100" tabindex="36" id="PEPcustomerKey" value="#PEPcustomerKey#" onkeyup="enableDefaultPosting('PEP')"/>
			<label>Default Posting</label>
			<input type="checkbox" name="integratewithPEPDefault" tabindex="30" id="integratewithPEPDefault" <cfif integratewithPEPDefault EQ true AND integratewithPEP EQ true AND len(trim(PEPcustomerKey))>checked="checked"</cfif> <cfif integratewithPEP NEQ true OR NOT len(trim(PEPcustomerKey))>disabled </cfif>  style="width:12px;" />
			<div class="clear"  style="border-top: 1px solid ##B4C2CF;margin-top:14px;padding-top:15px;">&nbsp;</div>
			
			<label>DAT Load Board</label>
			<input type="checkbox" name="integratewithTran360" tabindex="33" id="integratewithTran360"  <cfif integratewithTran360 EQ true>checked="checked"</cfif>   style="width:12px;" onclick="enableDefaultPosting('Tran360')"/>
			<div class="clear"></div>
			<label>User Name</label> 
			<input type="text" name="trans360Usename" tabindex="34" id="trans360Usename" maxlength="200" value="#trans360Usename#" onkeyup="enableDefaultPosting('Tran360')" />
			<div class="clear"></div>
			<label>Password</label> 
			<input type="password" name="trans360Password" tabindex="35" id="trans360Password" maxlength="200" value="#trans360Password#" onkeyup="enableDefaultPosting('Tran360')" />
			<i class="far fa-eye fa-eye-slash" style="margin-left: -25px; cursor: pointer; margin-top:6px;"></i>
			<label>Default Posting</label>
			<input type="checkbox" name="IntegrateWithTran360Default" tabindex="30" id="IntegrateWithTran360Default" <cfif IntegrateWithTran360Default EQ true AND integratewithTran360 EQ true AND len(trim(trans360Usename)) AND len(trim(trans360Password))>checked="checked"</cfif> <cfif integratewithTran360 NEQ true OR NOT len(trim(trans360Usename)) OR NOT len(trim(trans360Password))>disabled </cfif>  style="width:12px;" />
			<div class="clear"  style="border-top: 1px solid ##B4C2CF;margin-top:14px;padding-top:15px;">&nbsp;</div>

			
			<label>Truckstop</label>
			<input type="checkbox" name="integratewithITS" tabindex="36" id="integratewithITS"  <cfif integratewithITS EQ 1>checked="checked"</cfif>   style="width:12px;" onclick="enableDefaultPosting('ITS')"/>
			<div class="clear"></div>
			<label>Internet Truckstop</label> 
			<input type="text" name="integrationID" maxlength="50" tabindex="36" id="integrationID" value="#integrationID#" onkeyup="enableDefaultPosting('ITS')" />

			<label>Default Posting</label>
			<input type="checkbox" name="integratewithITSDefault" tabindex="30" id="integratewithITSDefault" <cfif integratewithITSDefault EQ true AND integratewithITS EQ true AND len(trim(PEPcustomerKey))>checked="checked"</cfif> <cfif integratewithITS NEQ true OR NOT len(trim(PEPcustomerKey))>disabled </cfif>  style="width:12px;" />
			<div class="clear"  style="border-top: 1px solid ##B4C2CF;margin-top:37px;padding-top:22px;">&nbsp;</div>
		</div>
		<div style="padding-left:142px;">
        <cfif agentdisabledStatus neq true>
        <input  type="submit" tabindex="37" name="submit" onfocus="checkUnload();" class="bttn" value="Save" style="width:112px;" onclick="if(#saveAgentOnClick#) {saveExit(0);}else{return false;}" <cfif saveAgentOnClick eq ''>disabled="disabled"</cfif> />
	       <input  type="submit" tabindex="37" name="submit" onfocus="checkUnload();" class="bttn" value="Save & Exit" style="width:112px;" onclick="if(#saveAgentOnClick#) {saveExit(1);}else{return false;}" <cfif saveAgentOnClick eq ''>disabled="disabled"</cfif> />
<cfelse>
			<cfif structKeyExists(session, 'rightsList') and ListContains(session.rightsList,'UnlockAgent',',')>
				<input id="Unlock" name="unlock" type="button"  style="width:112px;" class="bttn" onClick="removeAgentEditAccess('#request.qAgent.employeeId#');" value="Unlock">         		
			</cfif> 			
		</cfif>

        <input  type="button" onclick="javascript:history.back();" name="back" class="bttn" tabindex="38" value="Back" style="width:70px;" /></div>
		<div class="clear"></div>
		</fieldset>
	</div>
   <div class="clear"></div>
 </cfform>
<cfif isDefined("url.agentid") and len(agentid) gt 1>
<p id="footer" style="padding-left:10px;font-family:Verdana, Geneva, sans-serif; font-style:italic bold; text-transform:uppercase;font-family:Verdana, Geneva, sans-serif; font-style:italic; text-transform:uppercase;width:80%;">Last Updated:<cfif isDefined("request.qAgent")>&nbsp;&nbsp;&nbsp; #request.qAgent.LastModifiedDateTime#&nbsp;&nbsp;&nbsp;#request.qAgent.LastModifiedBy#</cfif></p>
</cfif>
</div>

<div class="white-bot">	
</div>
</div>
<script type="text/javascript">
		$(document).ready(function(){
			 $('##mailDocLink').click(function(){
				if($(this).attr('data-allowmail') == 'false')
				alert('You must setup your email address in your profile before you can email documents.');
				else
				mailDocOnClick('#session.URLToken#','agent'<cfif isDefined("url.agentId") and len(url.agentId) gt 1>,'#url.agentId#'<cfelse>,''</cfif>);
			 });

			 $("##frmAgent").submit(function(){
			 	$('##isSaveEvent').val('true');
			 });
			 $('##FA_TLS').click(function(){
			 	$('##FA_SSL').attr('checked', false);
			 });
			 $('##FA_SSL').click(function(){
			 	$('##FA_TLS').attr('checked', false);
			 });
		});

		function enableDefaultPosting(loadBoard){
			if(loadBoard == 'LoadBoard123'){
				if($("##loadBoard123").is(':checked') && $('##loadBoard123Usename').val().length && $('##loadBoard123Password').val().length){
					$("##LoadBoard123Default").removeAttr("disabled");
				}
				else{
					$("##LoadBoard123Default").attr("disabled","disabled");
				}
			}	

			if(loadBoard == 'Tran360'){
				if($("##integratewithTran360").is(':checked') && $('##trans360Usename').val().length && $('##trans360Password').val().length){
					$("##IntegrateWithTran360Default").removeAttr("disabled");
				}
				else{
					$("##IntegrateWithTran360Default").attr("disabled","disabled");
				}
			}

			if(loadBoard == 'DirectFreight'){
				if($("##IntegrateWithDirectFreightLoadboard").is(':checked') && $('##DirectFreightLoadboardUserName').val().length && $('##DirectFreightLoadboardPassword').val().length){
					$("##IntegrateWithDirectFreightLoadboardDefault").removeAttr("disabled");
				}
				else{
					$("##IntegrateWithDirectFreightLoadboardDefault").attr("disabled","disabled");
				}
			}
			if(loadBoard == 'PEP'){
				if($("##integratewithPEP").is(':checked') && $('##PEPcustomerKey').val().length){
					$("##integratewithPEPDefault").removeAttr("disabled");
				}
				else{
					$("##integratewithPEPDefault").attr("disabled","disabled");
				}
			}

			if(loadBoard == 'ITS'){
				if($("##integratewithITS").is(':checked') && $('##integrationID').val().length){
					$("##integratewithITSDefault").removeAttr("disabled");
				}
				else{
					$("##integratewithITSDefault").attr("disabled","disabled");
				}
			}
		}
</script>
<div class="formpopup-overlay"></div>
</cfoutput>
<cfinclude template="popup/LoadBoardValidationResponse.cfm">