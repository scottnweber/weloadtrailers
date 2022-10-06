<cfparam name="CarrierHead" default="">
<cfparam name="CustInvHead" default="">
<cfparam name="BOLHead" default="">
<cfparam name="WorkImpHead" default="">
<cfparam name="WorkExpHead" default="">
<cfparam name="SalesHead" default=""> 
<cfsilent>
	<cfif isDefined('form.submitCompanyInformation')>
		<cfif isdefined("form.ccOnEmails")>
			<cfset ccOnEmails = true>
		<cfelse>
			<cfset ccOnEmails = false>
		</cfif>
		<cfset imagesFolder = ExpandPath('..\fileupload\img\#session.userCompanyCode#\logo')>
		<cfif not directoryExists(imagesFolder)>
			<cfset directoryCreate(imagesFolder)>
		</cfif>
		<!--- <cfset reportFolder = ExpandPath('../reports')> --->
		<cfif form.companyLogo NEQ ''>
			<cffile action="upload" fileField="companyLogo" destination="#imagesFolder#" nameconflict="makeunique">
			<cfset serverFileName = '#cffile.SERVERFILE#'>	
		<cfelse>
			<cfset serverFileName = ''>
		</cfif>
		<cfinvoke component="#variables.objloadGateway#" method="setCompanyInformationUpdate"  companyName="#form.companyName#" MC="#form.MC#" companyLogoName="#serverFileName#" emailId="#form.emailId#" ccOnEmails="#ccOnEmails#" address="#form.address#" address2="#form.address2#" city="#form.city#" zipCode="#form.zipCode#"  state="#form.state#" returnvariable="companyInformationUpdated" RemitInfo1="#form.RemitInfo1#" RemitInfo2="#form.RemitInfo2#" RemitInfo3="#form.RemitInfo3#" RemitInfo4="#form.RemitInfo4#" RemitInfo5="#form.RemitInfo5#" RemitInfo6="#form.RemitInfo6#" phone="#form.phone#" fax="#form.fax#" contact="#form.contact#"/>
	</cfif>
	<cfinvoke component="#variables.objAgentGateway#" method="getAllStaes" returnvariable="request.qStates" />
	<cfinvoke component="#variables.objloadGateway#" method="getCompanyInformation" returnvariable="request.qGetCompanyInformation" />
</cfsilent>
<cfoutput>
	
<div class="white-con-area" style="height: 40px;background-color: ##82bbef;">
	<div style="float: left; width: 100%; min-height: 40px;">
		<h1 style="color:white;font-weight:bold;margin-left:350px;">Company Information</h1>
	</div>
</div>
<div style="clear:left"></div>

<div class="white-con-area">
	<div class="white-top"></div>
	
    <div class="white-mid">
		
		<cfform name="frmCompanyInformation" enctype="multipart/form-data" method="post">
			<div class="form-con">
				<fieldset>
					<label>Company Logo</label>
			        <input type="file" name="companyLogo" onchange="checkFiletype()"  id="companyLogo"  style="width: 75px;margin-right: 0 !important;border-right: none;"/>
			        <input type="text" id="imgName" readonly value="<cfif len(trim(request.qGetCompanyInformation.CompanyLogoName))>#request.qGetCompanyInformation.CompanyLogoName#<cfelse>No File Chosen</cfif>" style="width: 109px;border-left: none;">
			        <div class="clear"></div>
					<label>Company Name</label>
					<input type="text" name="companyName" id="companyName" value="#request.qGetCompanyInformation.companyName#">
					<div class="clear"></div>
					
					<label>Contact</label>
					<input type="text" name="Contact" id="Contact" value="#request.qGetCompanyInformation.Contact#" maxlength="150">
					<div class="clear"></div>

					<label>MC##</label>
					<input type="text" name="MC" id="MC" value="#request.qGetCompanyInformation.MC#">
					<div class="clear"></div>

					<label>Email</label>
					<input type="text" name="emailId" id="emailId" value="#request.qGetCompanyInformation.email#">
					<div class="clear"></div>
					
					<input type="checkbox" name="ccOnEmails" id="ccOnEmails"  <cfif request.qGetCompanyInformation.ccOnEmails EQ true>checked="checked"</cfif> style="width: 12px;margin-left: 111px;">CC on all emails</input>
					<div class="clear"></div>

					<label>Address</label>
					<input type="text" name="Address" id="Address" value="#request.qGetCompanyInformation.Address#">
					<div class="clear"></div>
					
					
					<div class="clear"></div>
					<label>Address 2</label>
					<input type="text" name="Address2" id="Address2" value="#request.qGetCompanyInformation.Address2#">
					<div class="clear"></div>
					
					<label>City</label>
					<input type="text" name="City" id="City" value="#request.qGetCompanyInformation.City#">
					<div class="clear"></div>
					
					<label>State</label>
					<select name="State" id="State">
						<option value="">Select</option>
						<cfloop query="request.qStates">
							<option value="#request.qStates.statecode#" <cfif request.qStates.statecode is request.qGetCompanyInformation.State> selected="selected" </cfif> >#request.qStates.statecode#</option>
						</cfloop>
					</select>
					
					<div class="clear"></div>
					<label>Zip code</label> 
					<input type="text" name="ZipCode" id="ZipCode"  value="#request.qGetCompanyInformation.ZipCode#"   />
					<div class="clear"></div>
				
					<label>Phone No</label>
					<input type="text" name="phone" id="phone" value="#request.qGetCompanyInformation.phone#" onchange="ParseUSNumber(this,'Phone No');">
					<div class="clear"></div>

					<label>Fax</label>
					<input type="text" name="fax" id="fax" value="#request.qGetCompanyInformation.fax#">
					<div class="clear"></div>

					<div class="clear" style="border-top: 1px solid ##E6E6E6;" >&nbsp;</div>	
					<input type="hidden" name="companyID" id="companyID" value="#request.qGetCompanyInformation.companyID#">
					<input  type="submit" name="submitCompanyInformation" onfocus="" class="bttn" value="Save" style="width:80px;margin-left:112px;margin-top:5px;" />
					
					<div id="message" class="msg-area" style="width: 181px;margin-left: 70px;margin-top: 36px; display:<cfif isDefined('companyInformationUpdated')>block;<cfelse>none;</cfif>">
						<cfif isDefined('companyInformationUpdated') AND companyInformationUpdated GT 0>
							Information saved successfully
						<cfelseif isDefined('companyInformationUpdated')>
							unknown <b>Error</b> occured while saving
						</cfif>
					</div>
					
				</fieldset>
			</div>
			<div class="form-con">
				<fieldset>
					<label style="width:125px;">Remittance Information</label>
			        <div class="clear"></div>
			        <label style="width:125px;">Line1</label>
			       	<input type="text" maxlength="50" name="RemitInfo1" id="RemitInfo1" value="#request.qGetCompanyInformation.RemitInfo1#">
			        <div class="clear"></div>
			        <label style="width:125px;">Line2</label>
			       	<input type="text" maxlength="50" name="RemitInfo2" id="RemitInfo2" value="#request.qGetCompanyInformation.RemitInfo2#">
			        <div class="clear"></div>
			        <label style="width:125px;">Line3</label>
			       	<input type="text" maxlength="50" name="RemitInfo3" id="RemitInfo3" value="#request.qGetCompanyInformation.RemitInfo3#">
			        <div class="clear"></div>
			        <label style="width:125px;">Line4</label>
			       	<input type="text" maxlength="50" name="RemitInfo4" id="RemitInfo4" value="#request.qGetCompanyInformation.RemitInfo4#">
			        <div class="clear"></div>
			        <label style="width:125px;">Line5</label>
			       	<input type="text" maxlength="50" name="RemitInfo5" id="RemitInfo5" value="#request.qGetCompanyInformation.RemitInfo5#">
			        <div class="clear"></div>
			        <label style="width:125px;">Line6</label>
			       	<input type="text" maxlength="50" name="RemitInfo6" id="RemitInfo6" value="#request.qGetCompanyInformation.RemitInfo6#">
			        <div class="clear"></div>
				</fieldset>
			</div>
			<div class="clear"></div>
		</cfform>
    </div>
    <div class="white-bot"></div>
</div>
<script type="text/javascript">
	$(document).ready(function(){
		$("##companyLogo").change(function () {
	        var fileExtension = ['jpeg', 'jpg', 'png', 'gif', 'bmp'];
	        if ($.inArray($(this).val().split('.').pop().toLowerCase(), fileExtension) == -1) {
	            alert("Only formats are allowed : "+fileExtension.join(', '));
	            $(this).val('');
	        }
	        else{
	        	$('##imgName').val($(this).val().replace(/C:\\fakepath\\/i, ''));
	        }
	    });
	});
</script>
</cfoutput>