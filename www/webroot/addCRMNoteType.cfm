<cfoutput>
	<cfsilent>
<!--- default value------->
		<cfparam name="NoteType" default="">
		<cfparam name="Description" default="">
		<cfparam name="CRMType" default="">
		<cfparam name="editid" default="">

		<cfinvoke component="#variables.objloadGateway#" method="getSystemSetupOptions" returnvariable="request.qSystemSetupOptions" /> 

		<cfif isdefined("url.CRMNoteTypeID") and len(trim(url.CRMNoteTypeID)) gt 1>
			<cfinvoke component="#variables.objCustomerGateway#" method="getCRMNoteTypeDetails" CRMNoteTypeID="#url.CRMNoteTypeID#" returnvariable="request.qCRMNoteType" />

			<cfif request.qCRMNoteType.recordcount eq 1>
				<cfset editid = url.CRMNoteTypeID>
				<cfset NoteType=#request.qCRMNoteType.NoteType#>
				<cfset Description=#request.qCRMNoteType.Description#>
				<cfset CRMType=#request.qCRMNoteType.CRMType#>
			</cfif>
		</cfif>
	</cfsilent>
	<script>
		$(document).ready(function(){
			<cfif structKeyExists(session, "CRMNoteTypeMessage")>
				alert('#session.CRMNoteTypeMessage#');
				<cfset structDelete(session, "CRMNoteTypeMessage")>
			</cfif>
		})
	</script>
	<cfif isdefined("url.CRMNoteTypeID") and len(trim(url.CRMNoteTypeID)) gt 1>
		<div class="white-con-area" style="height: 36px;background-color: ##82bbef;">
			<div class="search-panel"><div class="delbutton"><a href="index.cfm?event=delCRMNoteType&CRMNoteTypeID=#editid#&#session.URLToken#" onclick="return confirm('Are you sure to delete it ?');">  Delete</a></div></div>	
			<div style="float: left;"><h2 style="color:white;font-weight:bold;margin-left: 12px;">Edit CRM Note Type <span style="padding-left:180px;">#Ucase(NoteType)#</span></h2></div>
		</div>
		<div style="clear:left;"></div>
	<cfelse>
		<div class="white-con-area" style="height: 36px;background-color: ##82bbef;">
			<div style="float: left;"><h2 style="color:white;font-weight:bold;margin-left: 12px;">Add New CRM Note Type</h2></div>
		</div>
		<div style="clear:left;"></div>
	</cfif>
	<div class="white-con-area">
		<div class="white-top"></div>
		<div class="white-mid">
			<cfform name="frmCRMNoteType" action="index.cfm?event=addCRMNoteType:process&editid=#editid#&#session.URLToken#" method="post">
				<cfinput type="hidden" name="editid" value="#editid#">
				<cfinput type="hidden" name="companyid" id="companyid" value="#session.companyid#">
				<cfinput type="hidden" name="stayonpage" id="stayonpage" value="1">
				<div class="form-con">
					<fieldset class="carrierFields">
						<label><strong>Note Type*</strong></label>
						<cfinput type="text" name="NoteType" id="NoteType" value="#NoteType#" size="25" required="yes" message="Please enter the NoteType." maxlength="100" tabindex="1">
						<div class="clear"></div>
						<label><strong>Description*</strong></label>
						<textarea rows="2" cols="" maxlength="100" id="Description" name="Description" tabindex="2" style="height: 42px;">#Description#</textarea>
						<div class="clear"></div>
				        <label>CRM Type*</label>
						<select name="CRMType" id="CRMType"  style="width:286px;" tabindex="4" required="yes">
					        <option value="">Select</option>
					        <option value="Customer" <cfif CRMType EQ 'Customer'> selected </cfif>>Customer</option>
					        <cfif request.qSystemSetupOptions.FreightBroker EQ 2>
					        	<option value="Carrier" <cfif CRMType EQ 'Carrier'> selected </cfif>>Carrier</option>
					        	<option value="Driver" <cfif CRMType EQ 'Driver'> selected </cfif>>Driver</option>
					        <cfelseif request.qSystemSetupOptions.FreightBroker EQ 1>
					        	<option value="Carrier" <cfif CRMType EQ 'Carrier'> selected </cfif>>Carrier</option>
					        <cfelse>
					        	<option value="Driver" <cfif CRMType EQ 'Driver'> selected </cfif>>Driver</option>
					        </cfif>

					        <!--- <option value="Carrier" <cfif CRMType EQ 'Carrier'> selected </cfif>>Carrier</option> --->
						</select>
				        <div class="clear"></div> 
					</fieldset>
				</div>
				<div class="form-con">
					<fieldset class="carrierFields">
						<div style="padding-left:150px;"><input type="button" name="save" onclick="return validateCRMNoteType(1);" class="bttn" value="Save" style="width:112px;" /><input type="button" name="saveandexit" onclick="return validateCRMNoteType(0);" class="bttn" value="Save & Exit" style="width:112px;" /><input  type="button" onclick="javascript:history.back();" name="back" class="bttn" value="Back" style="width:70px;" /></div>
						<div class="clear"></div>  		
					</fieldset>
				</div>
			</cfform>
			<div class="clear"></div>
			<cfif isDefined("url.CRMNoteTypeID") and len(url.CRMNoteTypeID) gt 1>
				<p id="footer" style="padding-left:10px;font-family:Verdana, Geneva, sans-serif; font-style:italic bold; text-transform:uppercase;font-family:Verdana, Geneva, sans-serif; font-style:italic; text-transform:uppercase;width:80%;">Last Updated:<cfif isDefined("request.qCRMNoteType")>&nbsp;&nbsp;&nbsp; #request.qCRMNoteType.LastModifiedDateTime#&nbsp;&nbsp;&nbsp;#request.qCRMNoteType.LastModifiedBy#</cfif></p>
			</cfif>
		</div>
		<div class="white-bot"></div>
	</div>
</cfoutput>


