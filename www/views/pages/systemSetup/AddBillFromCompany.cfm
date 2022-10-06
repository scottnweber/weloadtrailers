<cfparam name="variables.ID" default="">
<cfparam name="variables.CompanyName" default="">
<cfparam name="variables.Contact" default="">
<cfparam name="variables.CompanyLogoName" default="">
<cfparam name="variables.Email" default="">
<cfparam name="variables.CCOnMail" default="0">
<cfparam name="variables.Address" default="">
<cfparam name="variables.Address2" default="">
<cfparam name="variables.City" default="">
<cfparam name="variables.StateCode" default="">
<cfparam name="variables.ZipCode" default="">
<cfparam name="variables.PhoneNumber" default="">
<cfparam name="variables.Fax" default="">
<cfparam name="variables.RemitInfo1" default="">
<cfparam name="variables.RemitInfo2" default="">
<cfparam name="variables.RemitInfo3" default="">
<cfparam name="variables.RemitInfo4" default="">
<cfparam name="variables.RemitInfo5" default="">
<cfparam name="variables.RemitInfo6" default="">
<cfinvoke component="#variables.objAgentGateway#" method="getAllStaes" returnvariable="request.qStates" />
<cfif structKeyExists(url, "ID") AND len(trim(url.ID))>
    <cfinvoke component="#variables.objAgentGateway#" method="getBillFromCompanyDetails" ID="#url.ID#" returnvariable="qCompanyDetails" />
    <cfset variables.ID = qCompanyDetails.BillFromCompanyID>
    <cfset variables.CompanyName = qCompanyDetails.CompanyName>
    <cfset variables.Contact = qCompanyDetails.Contact>
    <cfset variables.CompanyLogoName = qCompanyDetails.CompanyLogoName>
    <cfset variables.Email = qCompanyDetails.Email>
    <cfset variables.CCOnMail = qCompanyDetails.CCOnMail>
    <cfset variables.Address = qCompanyDetails.Address>
    <cfset variables.Address2 = qCompanyDetails.Address2>
    <cfset variables.City = qCompanyDetails.City>
    <cfset variables.StateCode = qCompanyDetails.State>
    <cfset variables.ZipCode = qCompanyDetails.ZipCode>
    <cfset variables.PhoneNumber = qCompanyDetails.PhoneNumber>
    <cfset variables.Fax = qCompanyDetails.Fax>
    <cfset variables.RemitInfo1 = qCompanyDetails.RemitInfo1>
    <cfset variables.RemitInfo2 = qCompanyDetails.RemitInfo2>
    <cfset variables.RemitInfo3 = qCompanyDetails.RemitInfo3>
    <cfset variables.RemitInfo4 = qCompanyDetails.RemitInfo4>
    <cfset variables.RemitInfo5 = qCompanyDetails.RemitInfo5>
    <cfset variables.RemitInfo6 = qCompanyDetails.RemitInfo6>
</cfif>
<cfoutput>
	<cfif structKeyExists(url, "ID") AND len(trim(url.ID))>
		<div class="clear"></div>
        <div class="delbutton" style="float:right;">
            <a href="index.cfm?event=deleteBillFromCompany&ID=#url.id#&#session.URLToken#" onclick="return confirm('Are you sure you want to delete this Company?');">  Delete</a>
        </div>
        <div class="clear"></div>
    </cfif>
    <div class="white-con-area" style="height: 40px;background-color: ##82bbef;">
		<div style="float: left; width: 100%; min-height: 40px;">
			<h1 style="color:white;font-weight:bold;margin-left:350px;"><cfif structKeyExists(url, "ID") AND len(trim(url.ID))>Edit<cfelse>Add</cfif> Bill From Company</h1>
		</div>
	</div>
	<div style="clear:left"></div>
	<div class="white-con-area">
		<div class="white-top"></div>
        <div class="white-mid">
			<cfform id="CompanyInfoForm" name="CompanyInfoForm" enctype="multipart/form-data" action="index.cfm?event=AddBillFromCompany:Process&#session.URLToken#" method="post" onsubmit="return validateCompanyInfo();">
		        <div class="form-con">
					<fieldset>
						<label>Company Logo</label>
				        <input type="file" name="CompanyLogo"  id="CompanyLogo" style="width: 75px;margin-right: 0 !important;border-right: none;"/>
				        <input type="text" id="imgName" readonly value="<cfif len(trim(variables.CompanyLogoName))>#variables.CompanyLogoName#<cfelse>No File Chosen</cfif>" style="width: 109px;border-left: none;">
				        <div class="clear"></div>
						<label>Company Name*</label>
						<input type="text" name="CompanyName" id="CompanyName" value="#variables.CompanyName#">
						<div class="clear"></div>
						<label>Contact</label>
						<input type="text" name="Contact" id="Contact" value="#variables.Contact#">
						<div class="clear"></div>
						<label>Email*</label>
						<input type="text" name="Email" id="Email" value="#variables.Email#">
						<div class="clear"></div>
						<input type="checkbox" name="CCOnMail" id="CCOnMail" <cfif CCOnMail> checked </cfif> style="width: 12px;margin-left: 111px;">CC on all emails
						<div class="clear"></div>
						<label>Address</label>
						<input type="text" name="Address" id="Address" value="#variables.Address#">
						<div class="clear"></div>
						<div class="clear"></div>
						<label>Address 2</label>
						<input type="text" name="Address2" id="Address2" value="#variables.Address2#">
						<div class="clear"></div>
						<label>City</label>
						<input type="text" name="City" id="City" value="#variables.City#">
						<div class="clear"></div>
						<label>State</label>
						<select name="StateCode" id="StateCode">
							<option value="">Select</option>
							<cfloop query="request.qStates">
								<option value="#request.qStates.statecode#" <cfif variables.statecode EQ request.qStates.statecode> selected </cfif>>#request.qStates.statecode#</option>
							</cfloop>
						</select>
						<div class="clear"></div>
						<label>Zip code</label> 
						<input type="text" name="ZipCode" id="ZipCode" value="#variables.ZipCode#"/>
						<div class="clear"></div>
						<label>Phone No</label>
						<input type="text" name="PhoneNumber" id="PhoneNumber" value="#variables.PhoneNumber#" onchange="ParseUSNumber(this,'Phone No');">
						<div class="clear"></div>
						<label>Fax</label>
						<input type="text" name="Fax" id="Fax" value="#variables.Fax#" onchange="ParseUSNumber(this,'Fax');">
						<div class="clear"></div>
						<div class="clear" style="border-top: 1px solid ##E6E6E6;" >&nbsp;</div>	
						<input type="hidden" name="ID" id="ID" value="#variables.ID#">
						<input id="save" name="SubmitCompanyInfo" type="submit" class="green-btn" value="Save" style="margin-left: 110px;">
						<input type="button" onclick="javascript:history.back();" name="cancel" class="bttn" value="Cancel" style="width: 125px !important;">
					</fieldset>
			 	</div>
			 	<div class="form-con">
			 		<fieldset>
						<label style="width:125px;">Remittance Information</label>
			        	<div class="clear"></div>
			        	<label style="width:125px;">Line1</label>
				       	<input type="text" maxlength="50" name="RemitInfo1" id="RemitInfo1" value="#variables.RemitInfo1#">
				        <div class="clear"></div>
				        <label style="width:125px;">Line2</label>
				       	<input type="text" maxlength="50" name="RemitInfo2" id="RemitInfo2" value="#variables.RemitInfo2#">
				        <div class="clear"></div>
				        <label style="width:125px;">Line3</label>
				       	<input type="text" maxlength="50" name="RemitInfo3" id="RemitInfo3" value="#variables.RemitInfo3#">
				        <div class="clear"></div>
				        <label style="width:125px;">Line4</label>
				       	<input type="text" maxlength="50" name="RemitInfo4" id="RemitInfo4" value="#variables.RemitInfo4#">
				        <div class="clear"></div>
				        <label style="width:125px;">Line5</label>
				       	<input type="text" maxlength="50" name="RemitInfo5" id="RemitInfo5" value="#variables.RemitInfo5#">
				        <div class="clear"></div>
				        <label style="width:125px;">Line6</label>
				       	<input type="text" maxlength="50" name="RemitInfo6" id="RemitInfo6" value="#variables.RemitInfo6#">
				        <div class="clear"></div>
				        <img <cfif not len(trim(variables.CompanyLogoName))>style="display: none;"</cfif> width="150" id="imgPreview" src="..\fileupload\img\#session.userCompanyCode#\logo\#variables.CompanyLogoName#"> 
					</fieldset>
			 	</div>
				<div class="clear"></div>
			</cfform>
		</div>
    	<div class="white-bot"></div>
	</div>
	<script type="text/javascript">
		$(document).ready(function(){
			$("##CompanyLogo").change(function () {
		        var fileExtension = ['jpeg', 'jpg', 'png', 'gif', 'bmp'];
		        if ($.inArray($(this).val().split('.').pop().toLowerCase(), fileExtension) == -1) {
		            alert("Only formats are allowed : "+fileExtension.join(', '));
		            $(this).val('');
		        }
		        else{
		        	var file = $(this)[0].files[0];
		        	$('##imgPreview').attr("src",URL.createObjectURL(file)).show();
		        	$('##imgName').val($(this).val().replace(/C:\\fakepath\\/i, ''));
		        }
		    });
		});

		function validateCompanyInfo(){
			var CompanyName = $('##CompanyName').val();
			var Email = $('##Email').val();
			if(!$.trim(CompanyName).length){
				alert('Please provide a CompanyName.');
				$('##CompanyName').focus();
				return false;
			}
			if(!$.trim(Email).length){
				alert('Please provide an Email.');
				$('##Email').focus();
				return false;
			}
			return true;
		}
	</script>
</cfoutput>