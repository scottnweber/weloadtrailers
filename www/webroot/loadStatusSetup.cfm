<cfsilent>
	<cfinvoke component="#variables.objAgentGateway#" method="getAllAgent" returnvariable="request.qAgent" />
	<cfinvoke component="#variables.objloadGateway#" method="getSystemSetupOptions" returnvariable="request.qSystemSetupOptions" />
	<cfif isDefined('form.submit') AND session.CompanyID EQ form.CompanyID>
		<cfinvoke component="#variables.objloadGateway#" method="getLoadStatusTypes" returnvariable="request.qLoadStatus" /> 
		<cfloop query="request.qLoadStatus">
			<cfif structKeyExists(form, "Color_#replace(request.qLoadStatus.statustypeid,'-','','ALL')#")>
				<cfset local.newColor = evaluate("Color_#replace(request.qLoadStatus.statustypeid,'-','','ALL')#")>
			</cfif>
			<cfif structKeyExists(form, "TextColor_#replace(request.qLoadStatus.statustypeid,'-','','ALL')#")>
				<cfset local.newTextColor = evaluate("TextColor_#replace(request.qLoadStatus.statustypeid,'-','','ALL')#")>
			</cfif>
			<cfif structKeyExists(form, "Filter_#replace(request.qLoadStatus.statustypeid,'-','','ALL')#")>
				<cfset local.newFilter = 1>
			<cfelse>
				<cfset local.newFilter = 0>
			</cfif>
			<cfif structKeyExists(form, "ForceNextStatus_#replace(request.qLoadStatus.statustypeid,'-','','ALL')#")>
				<cfset local.newForceNextStatus = 1>
			<cfelse>
				<cfset local.newForceNextStatus = 0>
			</cfif>

			<cfif structKeyExists(form, "AllowOnMobileWebApp_#replace(request.qLoadStatus.statustypeid,'-','','ALL')#")>
				<cfset local.AllowOnMobileWebApp = 1>
			<cfelse>
				<cfset local.AllowOnMobileWebApp = 0>
			</cfif>

			<cfif structKeyExists(form, "SendEmailForLoads_#replace(request.qLoadStatus.statustypeid,'-','','ALL')#")>
				<cfset local.SendEmailForLoads = 1>
			<cfelse>
				<cfset local.SendEmailForLoads = 0>
			</cfif>
			<cfif structKeyExists(form, "StatusDescription_#replace(request.qLoadStatus.statustypeid,'-','','ALL')#")>
				<cfset local.newStatusDescription = evaluate("StatusDescription_#replace(request.qLoadStatus.statustypeid,'-','','ALL')#")>
			</cfif>
			<cfif structKeyExists(form, "StatusUpdateEmailOption")>
				<cfset local.StatusUpdateEmailOption = 1>
			<cfelse>
				<cfset local.StatusUpdateEmailOption = 0>
			</cfif>
			<cfif structKeyExists(form, "SendUpdateOneTime_#replace(request.qLoadStatus.statustypeid,'-','','ALL')#")>
				<cfset local.SendUpdateOneTime = 1>
			<cfelse>
				<cfset local.SendUpdateOneTime = 0>
			</cfif>
			<cfif structKeyExists(form, "StatusIsActive_#replace(request.qLoadStatus.statustypeid,'-','','ALL')#")>
				<cfset local.isActive = evaluate("StatusIsActive_#replace(request.qLoadStatus.statustypeid,'-','','ALL')#")>
			</cfif>
			<cfinvoke component="#variables.objloadGateway#" method="setLoadStatusSetup"  newColor="#replace(local.newColor,'##','')#" newFilter="#local.newFilter#" newForceNextStatus="#local.newForceNextStatus#" AllowOnMobileWebApp="#local.AllowOnMobileWebApp#" statustypeid="#request.qLoadStatus.statustypeid#" SendEmailForLoads="#local.SendEmailForLoads#" UserAccountStatusUpdate="#form.UserAccountStatusUpdate#" StatusUpdateEmailOption="#local.StatusUpdateEmailOption#" StatusDescription="#local.newStatusDescription#" newTextColor="#replace(local.newTextColor,'##','')#" SendUpdateOneTime="#local.SendUpdateOneTime#" isActive="#local.isActive#" StatusUpdateMailType="#form.StatusUpdateMailType#" returnvariable="responseVariable" />

		</cfloop>

		<cfif len(trim(form.UserAccountStatusUpdate))>
			<cfinvoke component="#variables.objloadGateway#" method="getcurAgentMaildetails" returnvariable="request.qcurAgentdetails" employeID="#form.UserAccountStatusUpdate#" />

			<cfinvoke component="#variables.objAgentGateway#" method="verifyMailServer" returnvariable="request.smtpstatus">
				<cfinvokeargument name="host" value="#request.qcurAgentdetails.SmtpAddress#">
				<cfinvokeargument name="protocol" value="smtp">
				<cfinvokeargument name="port" value=#request.qcurAgentdetails.SmtpPort#>
				<cfinvokeargument name="user" value="#request.qcurAgentdetails.SmtpUsername#">
				<cfinvokeargument name="password" value="#request.qcurAgentdetails.SmtpPassword#">
				<cfinvokeargument name="useTLS" value=#request.qcurAgentdetails.useTLS#>
				<cfinvokeargument name="useSSL" value=#request.qcurAgentdetails.useSSL#>
				<cfinvokeargument name="overwrite" value=false>
				<cfinvokeargument name="timeout" value=10000>
		     </cfinvoke>
		 </cfif>
		 <cfinvoke component="#variables.objloadGateway#" method="getSystemSetupOptions" returnvariable="request.qSystemSetupOptions" />
	</cfif>
</cfsilent>
<cfoutput>
<cfinvoke component="#variables.objloadGateway#" method="getLoadStatusTypes" returnvariable="request.qLoadStatus" />
<div class="white-con-area" style="height: 40px;background-color: ##82bbef;">
	<div style="float: left; width: 100%; min-height: 40px;">
		<h1 style="color:white;font-weight:bold;margin-left:350px;">Load Status</h1>
	</div>
</div>
<div style="clear:left"></div>

<div class="white-con-area">
	<div class="white-top"></div>
	
    <div class="white-mid">
		
		<cfform name="frmLoadStatus" enctype="multipart/form-data" method="post">
			<input type="hidden" name="CompanyID" value="#session.companyid#">
			<div class="form-con" style="padding-left: 0;padding-right: 0">
				<fieldset class="LoadStatusSettings" style="border-right: groove 1px;">
					<input  type="submit" name="submit" onclick="return validateLoadStatusForm();" onfocus="" class="bttn" value="Save" style="width:80px;margin-left:112px;margin-top:5px;" />
					
					<cfloop query="request.qLoadStatus">
						<div class="automatic_notes_heading" style="background-color: ##82bbef;margin-bottom: 10px;padding-left: 5px;padding-top: 0;">#trim(replaceNoCase(REReplace(request.qLoadStatus.StatusText,"[0-9]","","ALL"), ".", ""))#</div>
						<label>Text Color</label>
						<input name="TextColor_#replace(request.qLoadStatus.statustypeid,'-','','ALL')#" id="TextColor_#replace(request.qLoadStatus.statustypeid,'-','','ALL')#" type="text" value="###trim(request.qLoadStatus.TextColorCode)#"  style="width:154px;" maxlength="50" />
						<input name="textcolorpicker" id="TextColor1_#replace(request.qLoadStatus.statustypeid,'-','','ALL')#" type="color" value="###trim(request.qLoadStatus.TextColorCode)#"  onchange="changeStatusColor('TextColor1_#replace(request.qLoadStatus.statustypeid,'-','','ALL')#','TextColor_#replace(request.qLoadStatus.statustypeid,'-','','ALL')#');"  style="width:20px;" />		
						<div class="clear"></div>
						<label>Background Color</label>
						<input name="Color_#replace(request.qLoadStatus.statustypeid,'-','','ALL')#" id="Color_#replace(request.qLoadStatus.statustypeid,'-','','ALL')#" type="text" value="###trim(request.qLoadStatus.colorcode)#"  style="width:154px;" maxlength="50" />
						<input name="colorpicker" id="Color1_#replace(request.qLoadStatus.statustypeid,'-','','ALL')#" type="color" value="###trim(request.qLoadStatus.colorcode)#"  onchange="changeStatusColor('Color1_#replace(request.qLoadStatus.statustypeid,'-','','ALL')#','Color_#replace(request.qLoadStatus.statustypeid,'-','','ALL')#');"  style="width:20px;" />		
						<div class="clear"></div>
						<cfif request.qLoadStatus.StatusText NEQ '. TEMPLATE'>
							<label>Description</label>
							<input name="StatusDescription_#replace(request.qLoadStatus.statustypeid,'-','','ALL')#" id="StatusDescription_#replace(request.qLoadStatus.StatusDescription,'-','','ALL')#" type="text" value="#request.qLoadStatus.StatusDescription#"  style="width:154px;" maxlength="50" />	
							<div class="clear"></div>
						<cfelse>
							<input name="StatusDescription_#replace(request.qLoadStatus.statustypeid,'-','','ALL')#" id="StatusDescription_#replace(request.qLoadStatus.StatusDescription,'-','','ALL')#" type="hidden" value="#request.qLoadStatus.StatusDescription#"  />	
						</cfif>

						<label>Status</label>
						<select style="width: 75px;" name="StatusIsActive_#replace(request.qLoadStatus.statustypeid,'-','','ALL')#" id="StatusIsActive_#replace(request.qLoadStatus.statustypeid,'-','','ALL')#">
							<option value="0" <cfif request.qLoadStatus.IsActive EQ 0> selected </cfif>>Inactive</option>
							<option value="1" <cfif request.qLoadStatus.IsActive EQ 1> selected </cfif>>Active</option>
						</select>
						<!--- <input name="StatusDescription_#replace(request.qLoadStatus.statustypeid,'-','','ALL')#" id="StatusDescription_#replace(request.qLoadStatus.StatusDescription,'-','','ALL')#" type="text" value="#request.qLoadStatus.StatusDescription#"  style="width:154px;" maxlength="50" />	 --->
						<div class="clear"></div>

						<label>Filter On My Loads</label>
						<input type="checkbox" class="input_width" name="Filter_#replace(request.qLoadStatus.statustypeid,'-','','ALL')#" id="Filter" style="width:12px;" <cfif request.qLoadStatus.filter EQ 1>checked</cfif>>
						<div class="clear"></div>
						<label>Force Next Load Status</label>
						<input type="checkbox" class="input_width"  name="ForceNextStatus_#replace(request.qLoadStatus.statustypeid,'-','','ALL')#" id="ForceNextStatus" style="width:12px;" <cfif request.qLoadStatus.ForceNextStatus EQ 1>checked</cfif>>
						<div class="clear"></div>
						<label>Allow On Mobile App</label>
						<input type="checkbox" class="input_width"  name="AllowOnMobileWebApp_#replace(request.qLoadStatus.statustypeid,'-','','ALL')#" id="AllowOnMobileWebApp" style="width:12px;" <cfif request.qLoadStatus.AllowOnMobileWebApp EQ 1>checked</cfif>>
						<div class="clear"></div><hr style="margin-bottom: 5px;">
						<label>Send update email for loads that reach this status</label>
						<input type="checkbox" class="input_width SendEmailForLoads"  name="SendEmailForLoads_#replace(request.qLoadStatus.statustypeid,'-','','ALL')#" id="SendEmailForLoads" style="width:12px;" <cfif request.qLoadStatus.SendEmailForLoads EQ 1>checked </cfif>>
						<label style="text-align: left;width: 132px !important;">Send one-time only for mobile app auto updates</label>
						<input type="radio" data-prev="#request.qLoadStatus.SendUpdateOneTime#" class="SendUpdateOneTime" name="SendUpdateOneTime_#replace(request.qLoadStatus.statustypeid,'-','','ALL')#" value="1" style="width:12px;margin-top: 5px;" <cfif request.qLoadStatus.SendUpdateOneTime EQ 1>checked </cfif>>
						<div class="clear" style="margin-bottom: 35px;"></div>
					</cfloop>

					
					<div class="clear" style="border-top: 1px solid ##E6E6E6;" >&nbsp;</div>	
					<input  type="submit" name="submit" onclick="return validateLoadStatusForm();" onfocus="" class="bttn" value="Save" style="width:80px;margin-left:112px;margin-top:5px;" />
					
					<div id="message" class="msg-area" style="width: 181px;margin-left: 70px;margin-top: 36px; display:<cfif isDefined('responseVariable')>block;<cfelse>none;</cfif>">
						<cfif isDefined('responseVariable') AND responseVariable GT 0>
							Information saved successfully
						<cfelseif isDefined('responseVariable')>
							unknown <b>Error</b> occured while saving
						</cfif>
					</div>
					
				</fieldset>
			</div>
			<div class="form-con" style="padding-left: 0;">
				<fieldset style="padding-top: 33px;">
					<div class="automatic_notes_heading" style="background-color: ##82bbef;margin-bottom: 10px;padding-left: 5px;height: 20px;">OTHER SETTINGS</div>
				</fieldset>

				<fieldset style="border: solid 1px;padding: 5px;width: 385px;margin-left: 5px;">
                    <legend style="font-weight: bold;font-size: 12px;">User Account For Send Load Status Update Email</legend>
                    <div style="margin:15px 15px;">       
                        <input type="radio" name="StatusUpdateMailType" value="0" style="width:15px; padding:0px 0px 0 0px;margin-bottom:5px;" <cfif request.qSystemSetupOptions.StatusUpdateMailType EQ 0> checked </cfif>>
                        <label class="normal" for="none" style="text-align:left; padding:2px 0 0 0;width: 110px;">Use Company Email:</label>
                        <select name="UserAccountStatusUpdate" id="UserAccountStatusUpdate">
							<option value="">Select</option>
							<cfloop query="request.qAgent">
								<option value="#request.qAgent.employeeID#" <cfif request.qSystemSetupOptions.UserAccountStatusUpdate EQ request.qAgent.employeeID> selected </cfif>  >#request.qAgent.name#(#request.qAgent.emailId#)</option>
							</cfloop>
						</select>
                        <div class="clear"></div>
                        <input type="radio" name="StatusUpdateMailType" value="1" style="width:15px; padding:0 0 0 0;margin-bottom:5px;" <cfif request.qSystemSetupOptions.StatusUpdateMailType EQ 1> checked </cfif>>
                        <label class="normal" for="none" style="text-align:left; padding:2px 0 0 0;width: 110px;">Use No Reply Email:</label>
                        <input class="disabledLoadInputs" style="position:absolute;" type="text" value="noreply@loadmanager.com" readonly> 
                    </div>      
                    <div class="clear"></div>
					<div style="border:groove 1px;width: 205px;font-size: 11px;font-weight: bold;padding: 5px 5px 10px 5px;margin: 5px 0px 0px 165px;height: 27px;">
						<input type="checkbox" name="StatusUpdateEmailOption" value="1" style="width:12px;"  <cfif request.qSystemSetupOptions.StatusUpdateEmailOption EQ 1> checked ="checked" </cfif>>
						<label style="width: 151px;text-align: left;">Open email so user can review email before sending.</label>
					</div>  
                </fieldset>

			</div>
			<div class="clear"></div>
		</cfform>
    </div>
    <div class="white-bot"></div>
</div>
<style>
	.automatic_notes_heading .InfotoolTip{
		margin-left: 5px;position: relative;top: 4px;
	}
</style>
<script type="text/javascript">
	function changeStatusColor(id1,id2) {            
        document.getElementById(id2).value = document.getElementById(id1).value;			
    }

    function validateLoadStatusForm(){
    	var ckd = $('.SendEmailForLoads:checked').length;
    	var useracc = $('##UserAccountStatusUpdate').val();
    	if(ckd != 0 && !useracc.length){
    		alert('Please select an user account that has a valid email address to send load status update email.');
    		$('##UserAccountStatusUpdate').focus();
    		return false;
    	}
    }

    $('.SendUpdateOneTime').click(function(){
    	var previous = $(this).attr('data-prev');
	    if(previous==1) {
	        this.checked = false;
	        $(this).attr('data-prev',0 );
	    }
	    else{
	    	this.checked = true;
	    	$(this).attr('data-prev',1 );
	    }
	    

	});

    $( document ).ready(function() {
    	<cfif structKeyExists(request, "smtpstatus") AND NOT request.smtpstatus.WASVERIFIED>
    		alert('SMTP settings for user account selected is invalid. Please select an user account that has a valid email address to send load status update email.');
    	</cfif>
    	<cfif NOT ListContains(session.rightsList,'editLoad',',')>
    		alert('You have the permission to edit a load turned off so changing the "Allow Edit" setting for any load status will not allow the user to edit a load. You must first change the Permission to allow editing loads.');
    	</cfif>
    })
</script>
<style>
	.LoadStatusSettings label{
		width: 145px !important;
	}
</style>
</cfoutput>