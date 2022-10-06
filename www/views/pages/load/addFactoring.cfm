<cfoutput>
	<cfsilent>
<!--- default value------->
		<cffile action="read" file="#expandPath('../webroot/')#cfrAllowedColor.json" variable="allowedColors">
		<cfinvoke component="#variables.objloadGateway#" method="getSystemSetupOptions" returnvariable="request.qSystemSetupOptions" /> 
		<cfparam name="Name" default="">
		<cfparam name="Address" default="">
		<cfparam name="City" default="">
		<cfparam name="State1" default="">
		<cfparam name="Zip" default="">
		<cfparam name="Contact" default="">
		<cfparam name="Phone" default="">
		<cfparam name="Fax" default="">
		<cfparam name="Email" default="">
		<cfparam name="InvoiceRemitInformation" default="">
		<cfparam name="editid" default="">
		<cfparam name="PrintOnInvoice" default="1">
		<cfparam name="UseFactInfoAsBillTo" default="0">
		<cfparam name="FF" default="#request.qSystemSetupOptions.FactoringFee#">
		<cfparam name="InfoColor" default="##000000">
		<cfif isdefined("url.Factoringid") and len(trim(url.Factoringid)) gt 1>
			<cfinvoke component="#variables.objloadGateway#" method="getFactoringDetails" Factoringid="#url.Factoringid#" returnvariable="request.qFactoring" />

			<cfif request.qFactoring.recordcount eq 1>
				<cfset editid = url.Factoringid>
				<cfset Name=#request.qFactoring.Name#>
				<cfset Address=#request.qFactoring.Address#>
				<cfset City=#request.qFactoring.City#>
				<cfset State1=#request.qFactoring.State#>
				<cfset Zip=#request.qFactoring.Zip#>
				<cfset Phone=#request.qFactoring.Phone#>
				<cfset Fax=#request.qFactoring.Fax#>
				<cfset Email=#request.qFactoring.Email#>
				<cfset Contact=#request.qFactoring.Contact#>
				<cfset InvoiceRemitInformation=#request.qFactoring.InvoiceRemitInformation#>
				<cfset PrintOnInvoice=#request.qFactoring.PrintOnInvoice#>
				<cfset FF=#request.qFactoring.FF#>
				<cfset UseFactInfoAsBillTo=#request.qFactoring.UseFactInfoAsBillTo#>
				<cfset InfoColor=#request.qFactoring.InfoColor#>
			</cfif>
		</cfif>
	</cfsilent>
	<script language="javascript" type="text/javascript" src="../webroot/javascripts/plugins/ckeditor/ckeditor.js?ver=4.16.0"></script>
	<script>
		$(document).ready(function(){
			CKEDITOR.replace('InvoiceRemitInformation', {contentsCss: "body {font-size: 11px;font-family:Arial;color:#InfoColor#} p {margin:0};",allowedContent: 'p b u'});

		})

		function newBackgroundColor(color) {            
	        document.getElementById("InfoColor").value = color;	
	        CKEDITOR.instances.InvoiceRemitInformation.document.getBody().setStyle('color', color);
	    }
		function autoFillRemitInfo(){
			var Name = $('##Name').val();
			Name = $.trim(Name);
			var Address = $('##Address').val();
			Address = $.trim(Address);
			var City = $('##City').val();
			City = $.trim(City);
			var state = $('##state').val();
			state = $.trim(state);
			var Zip = $('##Zip').val();
			Zip = $.trim(Zip);
			var Phone = $('##Phone').val();
			Phone = $.trim(Phone);
			var Email = $('##Email').val();
			Email = $.trim(Email);

			CKEDITOR.instances['InvoiceRemitInformation'].setData('NOTICE OF ASSIGNMENT<br>Please be advised that we have assigned, made over, and sold to '+Name+' all of our rights and interests in and to the accounts receivable arising from this invoice and that all payments should be made to:<br><br><b><u>REMIT PAYMENT TO:</u></b></br>'+Name+'<br>'+Address+'<br>'+City+', '+state+' '+Zip+'<br><br>'+'Any claims, offsets or disputes must be reports immediately to '+Name+' at '+Phone+' or email '+Email+'.');
		}

		function validateFactoringFrm(){
			var FF = $('##FF').val();
			if(!$.trim(FF).length || isNaN(FF)){
				alert('Invalid Factoring Fee%.');
				$('##FF').val(0);
				$('##FF').focus();
				return false;
			}
			return true;
		}
	</script>
	<style>
		.msg-area-success{
            border: 1px solid ##a4da46;
            padding: 5px 15px;
            font-weight: normal;
            width: 82%;
            float: left;
            margin-top: 5px;
            margin-bottom:  5px;
            background-color: ##b9e4b9;
            font-weight: bold;
            font-style: italic;
        }
		##cke_1_bottom {
			display: none;
		}
		##cke_1_top {
			display: none;
		}
		##cke_1_contents{
			height: 300px !important;
		}
		.ckcontent p { 
			margin: 0;
		}
	</style>
	<cfif structKeyExists(session, "FactoringMessage")>
		<div id="message" class="msg-area-success">#session.FactoringMessage#</div>
		<cfset structDelete(session, "FactoringMessage")>
	</cfif>
	<div style="clear:left"></div>
	<cfif isdefined("url.Factoringid") and len(trim(url.Factoringid)) gt 1>
		<div class="white-con-area" style="height: 36px;background-color: ##82bbef;">
			<div class="search-panel"><div class="delbutton"><a href="index.cfm?event=delFactoring&FactoringID=#editid#&#session.URLToken#" onclick="return confirm('Are you sure to delete it ?');">  Delete</a></div></div>	
			<div style="float: left;"><h2 style="color:white;font-weight:bold;margin-left: 12px;">Edit Factoring <span style="padding-left:180px;">#Ucase(Name)#</span></h2></div>
		</div>
		<div style="clear:left;"></div>
	<cfelse>
		<div class="white-con-area" style="height: 36px;background-color: ##82bbef;">
			<div style="float: left;"><h2 style="color:white;font-weight:bold;margin-left: 12px;">Add New Factoring</h2></div>
		</div>
		<div style="clear:left;"></div>
	</cfif>
	<div class="white-con-area">
		<div class="white-top"></div>
		<div class="white-mid">
			<cfform name="frmFactoring" action="index.cfm?event=addFactoring:process&editid=#editid#&#session.URLToken#" method="post" onsubmit="return validateFactoringFrm();">
				<cfinput type="hidden" name="editid" value="#editid#">
				<cfinput type="hidden" name="companyid" value="#session.companyid#">
				<cfinput type="hidden" name="stayonpage" id="stayonpage" value="1">
				<div class="form-con" style="padding-left: 0;padding-right: 0;width: 412px;">
					<fieldset class="carrierFields">
						<label>&nbsp;</label>
						<input name="UseFactInfoAsBillTo" id="UseFactInfoAsBillTo" type="checkbox" class="small_chk" style="float: left;" <cfif UseFactInfoAsBillTo>checked </cfif>>
						<strong>Use Factoring info below as the "Bill To" on the invoice</strong>
						<div class="clear"></div>
					</fieldset>
				</div>
				<div class="form-con">
					<fieldset class="carrierFields">
						<label>&nbsp;</label>
						<input name="PrintOnInvoice" id="PrintOnInvoice" type="checkbox" class="small_chk" style="float: left;" <cfif PrintOnInvoice>checked </cfif>>
						<strong>Print "Invoice Remit Information" on invoice</strong>
						<div class="clear"></div>
					</fieldset>
				</div>
				<div class="clear"></div>
				<div class="form-con" style="padding-left: 0;padding-right: 0;">
					<fieldset class="carrierFields">
						
						<label><strong>Name*</strong></label>
						<cfinput type="text" name="Name" id="Name" value="#Name#" size="25" required="yes" message="Please enter the name." maxlength="100" tabindex="1">
						<div class="clear"></div>
						<label><strong>Address*</strong></label>
						<textarea rows="2" cols="" maxlength="100" id="Address" name="Address" tabindex="2" style="height: 42px;">#Address#</textarea>
						<div class="clear"></div>
						<label>City*</label>
				        <cfinput type="text" name="City" maxlength="50" value="#City#" tabindex="3" required="yes" message="Please enter the city.">
				        <div class="clear"></div>
				        <label>State*</label>
						<select name="state" id="state"  style="width:100px;" tabindex="4" required="yes">
				        <option value="">Select</option>
						<cfloop query="request.qStates">
				        	<option value="#request.qStates.statecode#" <cfif request.qStates.statecode is State1> selected="selected" </cfif> >#request.qStates.statecode#</option>
						</cfloop>
						</select>
						<label style="width:70px;">Zipcode*</label>
				 		<cfinput type="text" name="Zip" id="Zip" value="#Zip#" maxlength="50" tabindex="5" required="yes" message="Please enter a zipcode." style="width:100px;">
				        <div class="clear"></div>
				        <label>Contact Person</label>
				        <cfinput type="text" name="Contact" maxlength="50" value="#Contact#" tabindex="6">
						<div class="clear"></div>
				        <label>Phone No</label>
				        <cfinput type="text" name="Phone" id="Phone" maxlength="50" value="#Phone#" tabindex="7" onchange="ParseUSNumber(this,'Phone');">
				        <div class="clear"></div>
						<label>Fax</label>
						<cfinput name="Fax" id="Fax" type="text" maxlength="150"  value="#Fax#" tabindex="8" onchange="ParseUSNumber(this,'Fax');"/>
				        <div class="clear"></div>
				        <label>Email</label>
						<cfinput name="Email" type="text" maxlength="150" value="#Email#" tabindex="9"/>
				        <cfif request.qSystemSetupOptions.AutomaticFactoringFee>
					        <div class="clear"></div>
					        <label>Factoring Fee</label>
					        <cfinput name="FF" id="FF" type="text" value="#NumberFormat(FF,'0.00')#" tabindex="9" style="width:30px;"/>%
					    <cfelse>
					    	<cfinput type="hidden" name="FF" id="FF" value="#FF#">
					    </cfif>
					</fieldset>
				</div>
				<div class="form-con" style="width: 115px;padding-left: 0;padding-right: 0;">
					<fieldset class="carrierFields">
						<label style="margin-left: 15px;"><strong>Invoice Remit Information</strong></label>
						<input class="black-btn" style="width: 105px !important;margin-top: 115px;" type="button" value="Auto-Fill===>>" onclick="autoFillRemitInfo()">
						<label style="width: 29px;margin-left: -10px;">Text Color:</label>
						
						<input name="colorpicker" id="color1" type="color" value="#InfoColor#" onchange="newBackgroundColor(colorpicker.value);" style="width:78px;margin-top:10px;margin-right: 2px !important;"  list="presetColors">
						<datalist id="presetColors">
							<cfloop array="#deserializeJSON(allowedColors)#" index="color">
							    <option>#color.COLORVALUE#</option>
							</cfloop>
						</datalist>

						<input name="InfoColor" id="InfoColor" type="text" value="#InfoColor#" style="width:57px;margin-left: 29px;" maxlength="50">
					</fieldset>
				</div>
				<div class="form-con" style="padding-left: 0;padding-right: 0;width: 305px;">
					<fieldset class="carrierFields">
						<textarea id="InvoiceRemitInformation" name="InvoiceRemitInformation" tabindex="11" style="height: 300px;padding:5px; ">#InvoiceRemitInformation#
						</textarea>
						<div class="clear" style="margin-top: 10px;"></div>
						<div style="width: 50%;float: left;">
							<input name="ApplyToAllCustomers" id="ApplyToAllCustomers" type="checkbox" class="small_chk" style="float: left;">
							<strong>Apply this to all customers.</strong>
						</div>
						<div style="width: 50%;float: left;">
							<input tabindex="12" type="button" name="save" onclick="return validateFactoring(1);" class="bttn" value="Save" style="width:112px;" />
							<input type="button"  tabindex="13" name="saveandexit" onclick="return validateFactoring(0);" class="bttn" value="Save & Exit" style="width:112px;" />
							<input tabindex="14" type="button" onclick="javascript:history.back();" name="back" class="bttn" value="Back" style="width:70px;" />
						</div>
						<div class="clear"></div>  		
					</fieldset>
				</div>
			</cfform>
			<div class="clear"></div>
			<cfif isDefined("url.Factoringid") and len(url.Factoringid) gt 1>
				<p id="footer" style="padding-left:10px;font-family:Verdana, Geneva, sans-serif; font-style:italic bold; text-transform:uppercase;font-family:Verdana, Geneva, sans-serif; font-style:italic; text-transform:uppercase;width:80%;">Last Updated:<cfif isDefined("request.qFactoring")>&nbsp;&nbsp;&nbsp; #request.qFactoring.LastModifiedDateTime#&nbsp;&nbsp;&nbsp;#request.qFactoring.LastModifiedBy#</cfif></p>
			</cfif>
		</div>
		<div class="white-bot"></div>
	</div>
</cfoutput>


