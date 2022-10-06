<cfoutput>
<cfsilent>	
	<!---Init deafault Value------->
	<cfparam name="officeCode" default="">
	<cfparam name="location" default="">
	<cfparam name="AdminManager" default="">
	<cfparam name="ContactNo" default="">
	<cfparam name="ContactNoExt" default="">
	<cfparam name="FaxNo" default="">
	<cfparam name="FaxNoExt" default="">
	<cfparam name="EmailID" default="">
	<cfparam name="isActive" default="">
	<cfparam name="DisclaimerText" default="">
	<cfparam name="CustomerDisclaimerText" default="">
	<cfparam name="editId" default="0">
	<cfparam name="IntegrateWithITS" default="0">
	<cfparam name="ITSDefaultPosting" default="0">
	<cfparam name="ITSUserName" default="">
	<cfparam name="ITSPassword" default="">
	<cfif isdefined("url.officeId") and len(trim(url.officeId)) gt 1>
		<cfinvoke component="#variables.objOfficeGateway#" method="getAllOffices" OfficeID="#url.officeID#" returnvariable="request.qOffice" />
		<cfset officeCode=#request.qOffice.officeCode#>
		<cfset location=#request.qOffice.location#>
		<cfset AdminManager=#request.qOffice.AdminManager#>
		<cfset ContactNo=#request.qOffice.ContactNo#>
		<cfset ContactNoExt=#request.qOffice.ContactNoExt#>
		<cfset FaxNo=#request.qOffice.FaxNo#>
		<cfset FaxNoExt=#request.qOffice.FaxNoExt#>
		<cfset EmailID=#request.qOffice.EmailID#>
		<cfset isActive=#request.qOffice.isActive#>
		<cfset DisclaimerText=#request.qOffice.DisclaimerText#>
		<cfset CustomerDisclaimerText=#request.qOffice.CustomerDisclaimerText#>
		<cfset IntegrateWithITS=#request.qOffice.IntegrateWithITS#>
		<cfset ITSUserName=#request.qOffice.ITSUserName#>
		<cfset ITSPassword=#request.qOffice.ITSPassword#>
		<cfset ITSDefaultPosting=#request.qOffice.ITSDefaultPosting#>
		<cfset editid="#url.officeID#">
	</cfif>
</cfsilent>
<cfif isdefined("url.officeId") and len(trim(url.officeId)) gt 1>

<cfif ListContains(session.rightsList,'addEditDeleteOffices',',')>
	<cfset deleteLinkURL = "index.cfm?event=office&officeId=#editid#&#session.URLToken#&">
    <cfset deleteLinkOnClick = "return confirm('Are you sure to delete this record?');">
<cfelse>
    <cfset deleteLinkURL = "javascript: alert('Sorry!! you don\'t have rights to delete an User.')">
    <cfset deleteLinkOnClick = "">
</cfif>


<div class="search-panel"><div class="delbutton"><a href="#deleteLinkURL#"  onclick="#deleteLinkOnClick#">  Delete</a></div></div>
<h1>Edit Office <span style="padding-left:180px;">#Ucase(officeCode)#</span></h1>
<cfelse>
<cfset session.checkUnload ='add'>
<h1>Add New Office</h1>
</cfif>
<div class="white-con-area">
<div class="white-top"></div>
<div class="white-mid">
<cfform name="frmoffice" action="index.cfm?event=addoffice:process&#session.URLToken#&checkUnload=0" method="post" onsubmit="return validateOffice()">
	<cfinput type="hidden" name="editId" value="#editId#">
	<div class="form-con">
	<fieldset>
	    <label><strong>Office Code*</strong></label>
		<cfinput type="text" maxlength="20" name="officeCode" value="#officeCode#" size="25" required="yes" message="Please enter the office code">
		<div class="clear"></div>
		<label><strong>Location*</strong></label>
        <cfinput type="text" name="Location" maxlength="50" value="#location#" size="25" required="yes" message="Please  enter the location">
        <div class="clear"></div>
        <label><strong>Admin Manager*</strong></label>
		<cfinput type="text" name="adminManager" maxlength="50" value="#adminManager#" size="25" required="yes" message="Please  enter the admin manager">
        <div class="clear"></div>
        <label><strong>Phone No.*</strong></label>
        <cfinput maxlength="20" onchange="ParseUSNumber(this);" type="text" name="contactNo" value="#contactNo#" required="yes"  message="Please enter phone number" style="width:100px;">
        <label class="ex" style="width:16px;">Ext.</label>
        <input type="text" name="contactNoExt" tabindex="19" style="width:37px;" value="#contactNoExt#" maxlength="10">
        <div class="clear"></div>
		<label><strong>Fax No*</strong></label>
		<cfinput maxlength="20" type="text" name="faxno" value="#faxno#" style="width:100px;">
		<label class="ex" style="width:16px;">Ext.</label>
        <input type="text" name="faxNoExt" tabindex="19" style="width:37px;" value="#faxNoExt#" maxlength="10">
		<div class="clear"></div>	
		<label><strong>Email ID*</strong></label>
		<cfinput class="emailbox" maxlength="50" type="text" name="emailID" value="#EmailID#" required="yes" validate="email" validateat="onSubmit" message="Please enter a valid email">
		<div class="clear"></div>
		<label><strong>Active*</strong></label>
		<cfselect  name="isactive">
		<option value="True" <cfif isactive is 'True'>selected="selected"</cfif>>True</option>
		<option value="False" <cfif isactive is 'False'>selected="selected"</cfif>>False</option>
		</cfselect>
		<div class="clear" style="border-top: 1px solid ##B4C2CF;margin-top:14px;padding-top:15px;"></div>  


		<input type="hidden" name="ITSUserNameOld" value="#ITSUserName#">
		<input type="hidden" name="ITSPasswordOld" value="#ITSPassword#">
		<label>Truckstop</label>
		<input type="checkbox" name="integratewithITS" tabindex="36" id="integratewithITS"  <cfif integratewithITS EQ 1>checked="checked"</cfif>   style="width:12px;" onclick="enableITSDefaultPosting()"/>
		<div class="clear"></div>
		<label>UserName</label> 
		<input type="text" name="ITSUserName" maxlength="150" tabindex="36" id="ITSUserName" value="#ITSUserName#" onkeyup="enableITSDefaultPosting()" />
		<div class="clear"></div>
		<label>Password</label> 
		<input type="text" name="ITSPassword" maxlength="150" tabindex="36" id="ITSPassword" value="#ITSPassword#" onkeyup="enableITSDefaultPosting()" />
		<div class="clear"></div>
		<label>Default Posting</label>
		<input type="checkbox" name="ITSDefaultPosting" tabindex="36" id="ITSDefaultPosting" <cfif ITSDefaultPosting EQ true AND integratewithITS EQ true AND len(trim(ITSUserName)) AND len(trim(ITSPassword))>checked="checked"</cfif> <cfif integratewithITS NEQ true OR NOT len(trim(ITSUserName)) OR NOT len(trim(ITSPassword))>disabled </cfif>  style="width:12px;" />
		<div class="clear"></div>	
		</fieldset>
		</div>
		<div class="form-con">
		<fieldset>		
		
		<label>Disclaimer &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</label>
		<div class="clear"></div>
		<textarea rows="" name="DisclaimerText" cols="" class="big">#DisclaimerText#</textarea>
		
		<div class="clear"></div>
		<label>Customer Disclaimer</label>
		<div class="clear"></div>
		<textarea rows="" name="CustomerDisclaimerText" cols="" class="big">#CustomerDisclaimerText#</textarea>
		<div class="clear"></div>	
		<div style="padding-left:30px;">
       
       <cfif ListContains(session.rightsList,'addEditDeleteOffices',',')>
       		<cfset saveOfficeOnClick = "return validateOffices(frmoffice);">
       <cfelse>
        	<cfset saveOfficeOnClick = "return false;">
       </cfif>
       
        <input  type="submit" name="submit" class="bttn" onclick="#saveOfficeOnClick#" onfocus="checkUnload();" value="Save Office" style="width:112px;"  <cfif saveOfficeOnClick eq 'return false;'>disabled="disabled"</cfif> />
        <input  type="button" onclick="javascript:history.back();" name="back" class="bttn" value="Back" style="width:70px;"/></div>
		<div class="clear"></div>
		</fieldset>
	</div>
   <div class="clear"></div>
 </cfform>
<div class="clear"></div>
<cfif isDefined("url.officeId") and len(officeId) gt 1>
<p id="footer" style="padding-left:10px;font-family:Verdana, Geneva, sans-serif; font-style:italic bold; text-transform:uppercase;font-family:Verdana, Geneva, sans-serif; font-style:italic; text-transform:uppercase;width:80%;">Last Updated:<cfif isDefined("request.qOffice")>&nbsp;&nbsp;&nbsp; #request.qOffice.LastModifiedDateTime#&nbsp;&nbsp;&nbsp;#request.qOffice.LastModifiedBy#</cfif></p>
</cfif>
</div>

<div class="white-bot"></div>
</div>
<script type="text/javascript">
	function enableITSDefaultPosting(loadBoard){
		if($("##integratewithITS").is(':checked') && $('##ITSUserName').val().length && $('##ITSPassword').val().length){
			$("##ITSDefaultPosting").removeAttr("disabled");
		}
		else{
			$("##ITSDefaultPosting").attr("disabled","disabled");
		}
	}

	function validateOffice(){
		var integratewithITS = $("##integratewithITS").is(":checked");
		var ITSUserName = $('##ITSUserName').val();
		var ITSPassword = $('##ITSPassword').val();
		if(integratewithITS && (!$.trim(ITSUserName).length || !$.trim(ITSPassword).length)){
			alert('Please complete Truckstop credentials. ');
			return false;
		}
	}
</script>
</cfoutput>