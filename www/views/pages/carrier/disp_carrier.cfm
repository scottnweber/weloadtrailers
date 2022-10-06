<cfparam name="message" default="">
<cfparam name="url.sortorder" default="desc">
<cfparam name="url.carrierfilter" default="false">
<cfparam name="url.equipment" default="">
<cfparam name="url.IsCarrier" default="">
<cfparam name="variables.pending"  default="0">
<cfif structKeyExists(url, "pending") and url.pending EQ 1>
    <cfset variables.pending = 1>
</cfif>
<cfinvoke component="#variables.objloadGateway#" method="getSystemSetupOptions" returnvariable="request.qSystemSetupOptions" />
<cfinvoke component="#variables.objequipmentGateway#" method="getAllEquipments" returnvariable="request.qEquipments" />
<cfinvoke component="#variables.objAgentGateway#" method="getAllStaes" returnvariable="request.qStates" />

<cfparam name="sortby"  default="">
<cfsilent>

<cfif request.qSystemSetupOptions.freightBroker EQ 1 OR (request.qSystemSetupOptions.freightBroker EQ 2 AND  structKeyExists(url,"IsCarrier") AND url.IsCarrier EQ 1)>
	<cfset variables.freightBroker = "carrier">    
<cfelseif   request.qSystemSetupOptions.freightBroker EQ 0 OR (request.qSystemSetupOptions.freightBroker EQ 2 AND  structKeyExists(url,"IsCarrier") AND url.IsCarrier EQ 0)>
	<cfset variables.freightBroker = "driver">
<cfelse>
    <cfdump var="#request.qSystemSetupOptions.freightBroker#" abort>
</cfif>
<cfset canEditDrivers = 1>
<cfif variables.freightBroker EQ "driver" AND NOT ListContains(session.rightsList,'editDrivers',',')>
    <cfset canEditDrivers = 0>
</cfif>
<!--- Getting page1 of All Results --->
<cfinvoke component="#variables.objCarrierGateway#" method="getSearchedCarrier" searchText="" pageNo="1"  IsCarrier="#url.IsCarrier#" pending="#variables.pending#" returnvariable="qCarrier" />


<cfif isdefined("form.searchText")>
   	<cfinvoke component="#variables.objCarrierGateway#" method="getSearchedCarrier" searchText="#form.searchText#" pageNo="#form.pageNo#" sortorder="#form.sortOrder#" sortby="#form.sortBy#" pending="#variables.pending#" IsCarrier="#url.IsCarrier#"   returnvariable="qCarrier" />
	<cfif qCarrier.recordcount lte 0>
		<cfset message="No match found">
	</cfif>
    


<cfelseif isdefined("form.form_submitted") and isdefined("url.carrierfilter") and #url.carrierfilter# eq "true" >
	<cfif isdefined("form.pageNo")>
    	<cfset pages = #form.pageNo#>
    <cfelse>
    	<cfset pages = 1>
    </cfif>
    
    <cfif isdefined("form.insExp")>	
		<cfset insEXP = #form.insExp#>
    <cfelse>
		<cfset insEXP = 0>
	</cfif>
    
    <cfif not isdefined('form.consigneecity')>
		<cfset form.consigneecity = "">
	</cfif>

    <cfif not isdefined('form.equipment')>
		<cfset form.equipment = "">
	</cfif>
    
    <cfif not isdefined('form.consigneestate')>
		<cfset form.consigneestate = "">
	</cfif>
    
    <cfif not isdefined('form.consigneeZipcode')>
		<cfset form.consigneeZipcode = "">
	</cfif>
    
    <cfif not isdefined('form.shippercity')>
		<cfset form.shippercity = "">
	</cfif>
    
	<cfif not isdefined('form.shipperstate')>
		<cfset form.shipperstate = "">
	</cfif>
    
	<cfif not isdefined('form.shipperZipcode')>
		<cfset form.shipperZipcode = "">
	</cfif>

    
    
   	
    <cfinvoke component="#variables.objCarrierGateway#" method="getFilteredCarrier" pageNo="#pages#" sortorder="ASC" sortby="CarrierName" 
    insexp="#insEXP#" shippercity="#form.shippercity#" shipperstate="#form.shipperstate#" shipperZipcode="#form.shipperZipcode#" consigneecity="#form.consigneecity#" consigneestate="#form.consigneestate#" consigneeZipcode="#form.consigneeZipcode#"   returnvariable="qCarrier" />
    <cfif qCarrier.recordcount lte 0>
		<cfset message="No More Record found">
	</cfif>
    
    
    
<cfelseif isdefined("url.carrierfilter") and #url.carrierfilter# eq "true">
	
	<cfif isdefined("form.pageNo")>
    	<cfset pages = #form.pageNo#>
    <cfelse>
    	<cfset pages = 1>
    </cfif>
    
    <cfif isdefined("form.insExp")>	
		<cfset insEXP = #form.insExp#>
    <cfelse>
		<cfset insEXP = 0>
	</cfif>
   	<cfif not isdefined('url.consigneecity')>
		<cfset url.consigneecity = "">
	</cfif>

    <cfif not isdefined('url.consigneestate')>
		<cfset url.consigneestate = "">
	</cfif>
    
    <cfif not isdefined('url.consigneeZipcode')>
		<cfset url.consigneeZipcode = "">
	</cfif>
    
    <cfif not isdefined('url.shippercity')>
		<cfset url.shippercity = "">
	</cfif>
    
	<cfif not isdefined('url.shipperstate')>
		<cfset url.shipperstate = "">
	</cfif>
    
	<cfif not isdefined('url.shipperZipcode')>
		<cfset url.shipperZipcode = "">
	</cfif>

    <cfinvoke component="#variables.objCarrierGateway#" method="getFilteredCarrier" pageNo="#pages#" sortorder="ASC" sortby="CarrierName" 
    insexp="#insEXP#" shippercity="#url.shippercity#" shipperstate="#url.shipperstate#" shipperZipcode="#url.shipperZipcode#" consigneecity="#url.consigneecity#" consigneestate="#url.consigneestate#" consigneeZipcode="#url.consigneeZipcode#" returnvariable="qCarrier" />
    <cfif qCarrier.recordcount lte 0>
		<cfset message="No More Record found">
	</cfif>



<cfelse>
	<cfif isdefined("url.carrierid") and len(url.carrierid) gt 1>	
		<cfinvoke component="#variables.objCarrierGateway#" method="getAllCarriers" returnvariable="request.qCarrier">
			<cfinvokeargument name="carrierid" value="#url.carrierid#">
		</cfinvoke>
        <cfif canEditDrivers EQ 1 >
    		<cfinvoke component="#variables.objCarrierGateway#" method="deleteCarriers" CarrierID="#url.carrierid#" returnvariable="message1" />
    		<cfif message1 eq 1>
                <cfinvoke component="#variables.objCarrierGateway#" method="deleteCarrierContacts" CarrierID="#url.carrierid#" returnvariable="message" />
                <cfinvoke component="#variables.objCarrierGateway#" method="deleteCarrierLookoutData" CarrierID="#url.carrierid#" returnvariable="message" />
    			<cfinvoke component="#variables.objCarrierGateway#" method="deleteCarriersoffices" CarrierID="#url.carrierid#" returnvariable="message" />
    			<cfinvoke component="#variables.objCarrierGateway#" method="deleteCarrierLipublicfmcsa" CarrierID="#url.carrierid#" returnvariable="message" />
                <cfinvoke component="#variables.objCarrierGateway#" method="deleteCarrierEquipments" CarrierID="#url.carrierid#" returnvariable="message" />
    			<cfif (request.qSystemSetupOptions.freightBroker EQ 1 OR (request.qSystemSetupOptions.freightBroker EQ 2 AND  structKeyExists(url,"IsCarrier") AND url.IsCarrier EQ 1)) EQ 1 AND request.qSystemSetupOptions.SaferWatch  EQ 1 >				
    				<cfinvoke component="#variables.objCarrierGateway#" method="RemoveWatch" returnvariable="message">
    						<cfinvokeargument name="DOTNumber" value="#request.qCarrier.DOTNumber#">
    						<cfinvokeargument name="MCNumber" value="MC#request.qCarrier.MCNumber#">
    					</cfinvoke>
                    <cfset message="Deleted Carrier record.">
                <cfelse>
                    <cfset message="Deleted Driver record.">
    			</cfif>
    		<cfelse>
    			<cfset message="Deletion is not allowed because data is active in other records.">
    		</cfif>      		
        </cfif>
		<cfinvoke component="#variables.objCarrierGateway#" method="getSearchedCarrier" IsCarrier="#url.IsCarrier#"  searchText="" pageNo="1" returnvariable="qCarrier" />
	</cfif>
</cfif>
</cfsilent>
<cfinvoke component="#variables.objloadGateway#" method="getcurAgentMaildetails" returnvariable="request.qcurMailAgentdetails" employeID="#session.empid#" />
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
<cfoutput>
<!---<cfset insExp="#request.qSystemSetupOptions.showExpiredInsuranceCarriers#">--->
<cfif isdefined("message") and len(message)>
 <div id="message" class="msg-area">#message#</div>
 
 <cfif isdefined("url.CarrMessage") and len(url.CarrMessage)>
	<div id="message" class="msg-area" style="width:500px">#url.CarrMessage#</div>
	</cfif>
</cfif>
<div class="search-panel">
<div class="form-search form-search-big">
<cfif ListContains(session.rightsList,'addCarrier',',')>
	<cfif variables.freightBroker EQ 'carrier'>
		<div class="addbutton"><a href="index.cfm?event=addnewcarrier&#session.URLToken#&IsCarrier=#url.IsCarrier#">Add New</a></div>
	<cfelse>
		<cfif canEditDrivers EQ 1 > 
            <div class="addbutton"><a href="index.cfm?event=add#variables.freightBroker#&#session.URLToken#&IsCarrier=#url.IsCarrier#">Add New</a></div> 
        </cfif>
	</cfif>
</cfif>
<div class="clear"></div>
<cfif isdefined("url.carrierfilter") and #url.carrierfilter# eq "true" >
	<cfset form_action ="index.cfm?event=carrier&#session.URLToken#&carrierfilter=true&equipment=#url.equipment#&consigneecity=#url.consigneecity#&consigneestate=#url.consigneestate#&consigneeZipcode=#url.consigneeZipcode#&shippercity=#url.shippercity#&shipperstate=#url.shipperstate#&shipperZipcode=#url.shipperZipcode#&IsCarrier=#url.IsCarrier#">
<cfelse>
	<cfif structKeyExists(url, "pending") and url.pending EQ 1>
        <cfset form_action = "index.cfm?event=carrier&#session.URLToken#&IsCarrier=#url.IsCarrier#&pending=1"> 
    <cfelse>
        <cfset form_action = "index.cfm?event=carrier&#session.URLToken#&IsCarrier=#url.IsCarrier#"> 
    </cfif>
</cfif>

<cfform id="dispCarrierForm" name="dispCarrierForm" action="#form_action#" method="post" preserveData="yes">
    <cfinput id="pageNo" name="pageNo" value="1" type="hidden">
    
    <cfinput id="sortOrder" name="sortOrder" value="ASC" type="hidden">
    <cfinput id="sortBy" name="sortBy" value="CarrierName" type="hidden">
    
	<div style="float:left;width:1024px;">
    <h1>
        <cfif request.qSystemSetupOptions.freightBroker EQ 1>
            <cfif structKeyExists(url, "pending") and url.pending EQ 1>Carriers with missing <a target="_blank" style="text-decoration: underline;" href="index.cfm?event=attachmentTypes&#session.URLToken#">Attachments</a><cfelse>Select Carriers</cfif>
        <cfelseif request.qSystemSetupOptions.freightBroker EQ 0>
            <cfif structKeyExists(url, "pending") and url.pending EQ 1>Drivers with missing <a target="_blank" style="text-decoration: underline;" href="index.cfm?event=attachmentTypes&#session.URLToken#">Attachments</a><cfelse>Driver List</cfif>
        <cfelseif request.qSystemSetupOptions.freightBroker EQ 2>
            <cfif structKeyExists(url,"IsCarrier") AND url.IsCarrier EQ 1>
                <cfif structKeyExists(url, "pending") and url.pending EQ 1>Carriers with missing <a target="_blank" style="text-decoration: underline;" href="index.cfm?event=attachmentTypes&#session.URLToken#">Attachments</a><cfelse>Select Carriers</cfif>    
            <cfelseif structKeyExists(url,"IsCarrier") AND url.IsCarrier EQ 0>
               <cfif structKeyExists(url, "pending") and url.pending EQ 1>Drivers with missing <a target="_blank" style="text-decoration: underline;" href="index.cfm?event=attachmentTypes&#session.URLToken#">Attachments</a><cfelse>Driver List</cfif>
            </cfif>
        </cfif> 
    </h1>
	<fieldset>
        <cfinput name="searchText" type="text" message="Please enter search text"  />
        <cfif request.qSystemSetupOptions.freightBroker EQ 1 OR (request.qSystemSetupOptions.freightBroker EQ 2 AND  structKeyExists(url,"IsCarrier") AND url.IsCarrier EQ 1)>
            <select name="searchPickUpState" id="searchPickUpState">
                <option value="">Select State</option>
                <cfloop query="request.qStates">
                    <option <cfif structKeyExists(form,"searchPickUpState") AND form.searchPickUpState EQ request.qStates.statecode> selected </cfif> value="#request.qStates.statecode#">#request.qStates.statecode#</option>    
                </cfloop>  
            </select>
            <span style="float: left;margin-left: -95px;margin-top: -75px;">"Use CTL + Mouse"</span>
            <select name="searchEquipmentID" id="searchEquipmentID" multiple style="height: 100px;margin-top: -77px">
                <cfloop query="request.qEquipments">
                    <option <cfif structKeyExists(form,"searchEquipmentID") AND listFindNoCase(form.searchEquipmentID, request.qEquipments.EquipmentID)> selected </cfif>  value="#request.qEquipments.EquipmentID#">#request.qEquipments.EquipmentName#</option>
                </cfloop>
            </select>
        </cfif>
        <input name="" onclick="javascript: document.getElementById('pageNo').value=1;" type="submit" class="s-bttn" value="Search" style="width:56px;" />
        <cfif request.qSystemSetupOptions.freightBroker EQ 1 OR (request.qSystemSetupOptions.freightBroker EQ 2 AND structKeyExists(url,"IsCarrier") AND url.IsCarrier EQ 1)>    
            <input id="carrierLanesEmailButton" class="s-bttn" value="Email Carriers" type="button" <cfif mailsettings>data-allowmail="true"<cfelse>data-allowmail="false"</cfif>>
            <input type="hidden" name="TotalCarrierChargesHidden" id="TotalCarrierChargesHidden" value="0">
            <input type="hidden" name="Dispatcher" id="Dispatcher" value="00000000-0000-0000-0000-000000000000">
            <input id="copyButtonId" type="button"  class="s-bttn" value="Copy Emails" id="CopyEmails" onclick="copyToClipboard()">
        </cfif>
        <div class="clear"></div>
	</fieldset>
    </div>
    <cfif url.carrierfilter eq true>
	<div style="float:left;width:450px;">
    	<fieldset class="career_filter">
        	<legend>FILTER CARRIER</legend>
            <span class="carrier_type">
                <span><p>&nbsp;All </p><input type="radio" name="Carrier_Type" id="Carrier_Type1" value="1" 
                <cfif isdefined("form.Carrier_Type") and #form.Carrier_Type# eq "1"> checked="checked"</cfif>&nbsp; />
                </span>
                <span><p>LTL :</p><input type="radio" name="Carrier_Type" id="Carrier_Type1" value="2" 
                <cfif isdefined("form.Carrier_Type") and #form.Carrier_Type# eq "2"> checked="checked"</cfif> />
                </span>
            </span>
            <span class="int">
            	<p>Ins EXP:</p> <input name="insExp" type="checkbox"  <cfif isdefined("form.insExp")> checked="checked" </cfif> value="1" />
            </span>
            <span class="equipment">
            	  <p>Equipment:</p>
                  <select name="equipment">
                    <option value="">Select</option>
                    <cfloop query="request.qEquipments">
                      <option value="#request.qEquipments.equipmentname#" <cfif isdefined("form.equipment") ><cfif #form.equipment# eq request.qEquipments.equipmentname >selected="selected"</cfif> 
					  <cfelseif url.equipment eq request.qEquipments.equipmentID> selected="selected" </cfif>>#request.qEquipments.equipmentname#</option>
                    </cfloop>
                  </select>
            </span>
            <div class="clear"></div>
            
            <div class="carrier_bottom_area">
            	<div class="carrier_bottom_area_left">
                	<fieldset class="career_subfilter">
                       
	        			<legend>ORIGIN</legend>
                        <div class="career_subfilter_area">
                        <span class="equipment highpadd">
                            <label>City</label>
                            <input type="text" name="shippercity" id="shippercity" value=<cfif isdefined('form.shippercity') >"#form.shippercity#"
							<cfelseif isdefined('url.shippercity')> "#url.shippercity#" </cfif>  />
                        </span>
                        <div class="clear"></div>
                        <span class="equipment">
                            <label>State</label>
                            <select name="shipperstate" id="shipperstate" onChange="" >
                              <option value="">Select</option>
                              <cfloop query="request.qStates">
                                <option value="#request.qStates.statecode#" 
								<cfif isdefined("form.shipperstate") ><cfif #form.shipperstate# eq request.qStates.statecode >selected="selected"</cfif> <cfelseif url.shipperstate eq request.qStates.statecode> selected="selected" </cfif>>#request.qStates.statecode#</option>
                              </cfloop>
                            </select>
                            
                            <label class="zip">Zip</label>
                            <input name="shipperZipcode" id="shipperZipcode" value=<cfif isdefined('form.shipperZipcode') >"#form.shipperZipcode#"
							<cfelseif isdefined('url.shipperZipcode')> "#url.shipperZipcode#" </cfif> type="text" class="zip" />
                            
                        </span>
                        <div class="clear"></div>
                        </div>
                    </fieldset>
                </div>
            	<div class="carrier_bottom_area_right">
                	<fieldset class="career_subfilter">
	        			<legend>DESTINATION</legend>
                        <span class="equipment highpadd">
                            <label>City</label>
                            <input type="text" name="consigneecity" id="consigneecity"  value=<cfif isdefined('form.consigneecity') >"#form.consigneecity#"
							<cfelseif isdefined('url.consigneecity')> "#url.consigneecity#" </cfif>/>
                        </span>
                        <div class="clear"></div>
                        <span class="equipment">
                         <label>State</label>
                         <select name="consigneestate" id="consigneestate" >
                            <option value="">Select</option>
                            <cfloop query="request.qStates">
                              <option value="#request.qStates.statecode#" <cfif isdefined("form.consigneestate") ><cfif #form.consigneestate# eq request.qStates.statecode >selected="selected"</cfif> <cfelseif url.consigneestate eq request.qStates.statecode> selected="selected" </cfif>>#request.qStates.statecode#</option>
                            </cfloop>
                         </select>
                         <label class="zip">Zip</label>
                         <input name="consigneeZipcode" id="consigneeZipcode" value=<cfif isdefined('form.consigneeZipcode') >"#form.consigneeZipcode#"
                         <cfelseif isdefined('url.consigneeZipcode')> "#url.consigneeZipcode#" </cfif> type="text" class="zip" />
                        </span>
                        <div class="clear"></div>
                    </fieldset>
                </div>
            </div>
            <div class="clear"></div>
            <div class="clear">&nbsp;</div>
            <div style="text-align:center;">
                <input type="hidden" name="form_submitted" value="form_submitted"  />
                <button class="button" type="button" name="submit_form" value="submit_form" onclick="this.form.submit();" >Submit</button>
                <button class="button" type="button" name="submit_form" value="submit_form" onclick="window.location='index.cfm?event=carrier&#session.URLToken#&carrierfilter=true' " >Reset</button>
            </div>
        </fieldset>
    <div class="clear">&nbsp;</div>
    </div>
    </cfif>
</cfform>


</div>
</div>   
		<style type="text/css">
			span.carrierTextarea{ 
				white-space: pre-wrap;      
				white-space: -moz-pre-wrap; 
				white-space: -pre-wrap;     
				white-space: -o-pre-wrap;   
				word-wrap: break-word;
			}
            <cfif canEditDrivers NEQ 1 >
                .content-area table.data-table tr:hover{
                    cursor: auto;
                }
            </cfif>
            ##searchPickUpState,##searchEquipmentID{
                float: left;
                width: 194px;
                height: 22px;
                background: ##FFFFFF;
                border: 1px solid ##b3b3b3;
                padding: 0;
                font-size: 11px;
                margin-left: 5px;
            }
            .data-table th {
                background-size: contain;
            }
		</style>
	   <table width="100%" border="0" class="data-table" cellspacing="0" cellpadding="0">
          <thead>
          <tr>
        	<th width="5" align="left" valign="top" ><img src="images/top-left.gif" alt="" width="5" height="32" /></th>			
        	<th width="24" align="center" valign="middle" class="head-bg">&nbsp;</th>	

            <cfif request.qSystemSetupOptions.freightBroker EQ 1 OR (request.qSystemSetupOptions.freightBroker EQ 2 AND  structKeyExists(url,"IsCarrier") AND url.IsCarrier EQ 1)>
                <th width="24" align="center" valign="middle" class="head-bg">Select<br><input type="checkbox" class="myElements" onclick="selectAllCarriers(this);"> </th>     
            </cfif>

        	<th width="100" align="center" valign="middle" class="head-bg" onclick="sortTableBy('CarrierName','dispCarrierForm');" >Name</th>
        	<th width="120" align="center" valign="middle" class="head-bg" onclick="sortTableBy('MCNumber','dispCarrierForm');">
				<cfif request.qSystemSetupOptions.freightBroker EQ 1 OR (request.qSystemSetupOptions.freightBroker EQ 2 AND  structKeyExists(url,"IsCarrier") AND url.IsCarrier EQ 1)>
					MCNumber
				<cfelseif request.qSystemSetupOptions.freightBroker EQ 0 OR (request.qSystemSetupOptions.freightBroker EQ 2 AND  structKeyExists(url,"IsCarrier") AND url.IsCarrier EQ 0)>
					Driver Lic ##
				</cfif>
			</th>
            <cfif request.qSystemSetupOptions.freightBroker EQ 1 OR (request.qSystemSetupOptions.freightBroker EQ 2 AND  structKeyExists(url,"IsCarrier") AND url.IsCarrier EQ 1)>
                <th width="120" align="center" valign="middle" class="head-bg" onclick="sortTableBy('DotNumber','dispCarrierForm');">
                        DotNumber
                </th>
            </cfif>
        	<th width="120" align="center" valign="middle" class="head-bg" onclick="sortTableBy('city','dispCarrierForm');">City</th>
			<th width="50" align="center" valign="middle" class="head-bg" onclick="sortTableBy('StateCode','dispCarrierForm');">State</th>
        	<th width="109" align="center" valign="middle" class="head-bg" onclick="sortTableBy('phone','dispCarrierForm');">Phone</th>
        	<th width="109" align="center" valign="middle" class="head-bg" onclick="sortTableBy('emailid','dispCarrierForm');">Email</th>
			<th width="125" align="center" valign="middle" class="head-bg" onclick="sortTableBy('CDLEXPIRES','dispCarrierForm');" nowrap="nowrap"><cfif variables.freightBroker EQ "driver">
				CDL Expiration 
			<cfelse>
				Insurance Expiration
			</cfif>
            <th width="125" align="center" valign="middle" class="head-bg" onclick="sortTableBy('crmnextcalldate','dispCarrierForm');">Next Call</th>
			</th>
            <th width="109" align="center" valign="middle" class="head-bg2" onclick="sortTableBy('status','dispCarrierForm');">Status</th>
        	<th width="5" align="right" valign="top"><img src="images/top-right.gif" alt="" width="5" height="32" /></th>
          </tr>
          </thead>
          <tbody>
        	<cfloop query="qCarrier">
				<cfset pageSize = 30>
				<cfif isdefined("form.pageNo")>
					<cfset rowNum=(qCarrier.currentRow) + ((form.pageNo-1)*pageSize)>
				<cfelse>
					<cfset rowNum=(qCarrier.currentRow)>
				</cfif>
				<tr <cfif qCarrier.currentRow mod 2 eq 0>bgcolor="##FFFFFF"<cfelse>bgcolor="##f7f7f7"</cfif>>

    				<cfset tdOnClickString ="document.location.href='index.cfm?event=add#variables.freightBroker#&carrierid=#qCarrier.CarrierID#&#session.URLToken#&IsCarrier=#url.IsCarrier#'">
                    
                    <cfif canEditDrivers NEQ 1 >
                        <cfset tdOnClickString = "">
                    </cfif>
					<cfset tdTitleString ="#qCarrier.CarrierName# #qCarrier.MCNumber# #qCarrier.city# #qCarrier.Phone# #qCarrier.EmailID#">
					<cfset tdHrefClickString ="index.cfm?event=add#variables.freightBroker#&carrierid=#qCarrier.CarrierID#&#session.URLToken#">			
					<td height="20" class="sky-bg">&nbsp;</td>					
					<td class="sky-bg2" valign="middle" onclick="#tdOnClickString#" align="center">#rowNum#</td>
                    <cfif request.qSystemSetupOptions.freightBroker EQ 1 OR (request.qSystemSetupOptions.freightBroker EQ 2 AND  structKeyExists(url,"IsCarrier") AND url.IsCarrier EQ 1)>
                        <td align="left" valign="middle" nowrap="nowrap" class="normal-td">
                        <input type="checkbox" class="ckLanes myElements" data-emailid="#qCarrier.EmailID#"  value="#qCarrier.CarrierID#">
                    </td>	
                    </cfif>				
					<td align="left" valign="middle" nowrap="nowrap" class="normal-td" >
						<cfif (request.qSystemSetupOptions.freightBroker EQ 1 OR (request.qSystemSetupOptions.freightBroker EQ 2 AND  structKeyExists(url,"IsCarrier") AND url.IsCarrier EQ 1) ) AND request.qSystemSetupOptions.SaferWatch>						
							<cfif qCarrier.MCNumber NEQ "">
								<cfset number = "MC"&qCarrier.MCNumber >
							<cfelseif  qCarrier.DOTNumber NEQ "" >
								<cfset number = qCarrier.DOTNumber>
							<cfelse>
								<cfset number = 0 >
							</cfif>
							<cfset risk_assessment = 	qCarrier.RiskAssessment>
                            <cfif request.qSystemSetupOptions.CarrierLNI EQ 3 >					
								<a href="http://www.saferwatch.com/swCarrierDetailsLink.php?&number=#number#&IsCarrier=#url.IsCarrier#" target="_blank">
									<cfif risk_assessment EQ "Unacceptable">
										&nbsp;<img style="vertical-align:bottom;" src="images/SW-Red.png" height="16px"  width="25px">
									<cfelseif risk_assessment EQ "Moderate">
										&nbsp;<img style="vertical-align:bottom;" src="images/SW-Yellow.png" height="16px"  width="25px">
									<cfelseif risk_assessment EQ "Acceptable">
										&nbsp;<img style="vertical-align:bottom;" src="images/SW-Green.png" height="16px"  width="25px">
									<cfelse>   
										&nbsp;<img style="vertical-align:bottom;" src="images/SW-Blank.png" height="16px"  width="25px">
									</cfif>
								</a>	
                            </cfif>				
						</cfif>
                        <cfif (request.qSystemSetupOptions.freightBroker EQ 1 OR (request.qSystemSetupOptions.freightBroker EQ 2 AND  structKeyExists(url,"IsCarrier") AND url.IsCarrier EQ 1) ) AND request.qSystemSetupOptions.carrierLNI EQ 2>
                            <cfset risk_assessment =    qCarrier.RiskAssessment>
                            <cfif risk_assessment EQ "Unacceptable">
                                &nbsp;<img style="vertical-align:middle;width: 15px;" src="images/CL-Red.png">
                            <cfelseif risk_assessment EQ "Moderate">
                                &nbsp;<img style="vertical-align:middle;width: 15px;" src="images/CL-Yellow.png">
                            <cfelseif risk_assessment EQ "Acceptable">
                                &nbsp;<img style="vertical-align:middle;width: 15px;" src="images/CL-Green.png">
                            </cfif>
                        </cfif> 

						<cfif canEditDrivers EQ 1 >
                            <a title="#tdTitleString#" href="#tdHrefClickString#&IsCarrier=#url.IsCarrier#" onclick="#tdOnClickString#">#qCarrier.CarrierName#</a>
                        <cfelse>
                            #qCarrier.CarrierName#
                        </cfif>
					</td>
					<td align="left" valign="middle" nowrap="nowrap" class="normal-td" onclick="#tdOnClickString#">
						<cfif canEditDrivers EQ 1 >
                            <a title="#tdTitleString#" href="#tdHrefClickString#&IsCarrier=#url.IsCarrier#">#qCarrier.MCNumber#</a>
                        <cfelse>
                            #qCarrier.MCNumber#
                        </cfif>
					</td>
                    <cfif request.qSystemSetupOptions.freightBroker EQ 1 OR (request.qSystemSetupOptions.freightBroker EQ 2 AND  structKeyExists(url,"IsCarrier") AND url.IsCarrier EQ 1)>
                        <td align="left" valign="middle" nowrap="nowrap" class="normal-td" onclick="#tdOnClickString#">
                            <a title="#tdTitleString#" href="#tdHrefClickString#">#qCarrier.DotNumber#</a>
                        </td>
                    </cfif>
					<td align="left" valign="middle" nowrap="nowrap" class="normal-td" onclick="#tdOnClickString#">
						<cfif canEditDrivers EQ 1 >
                            <a title="#tdTitleString#" href="#tdHrefClickString#&IsCarrier=#url.IsCarrier#">#qCarrier.city#</a>
                        <cfelse>
                            #qCarrier.city#
                        </cfif>   
					</td>

					<td align="left" valign="middle" nowrap="nowrap" class="normal-td" onclick="#tdOnClickString#">
						<cfif canEditDrivers EQ 1 >
                            <a title="#tdTitleString#" href="#tdHrefClickString#&IsCarrier=#url.IsCarrier#">#qCarrier.stateCode#</a>
                        <cfelse>
                            #qCarrier.stateCode#
                        </cfif>
					</td>

					<td align="left" valign="middle" nowrap="nowrap" class="normal-td" onclick="#tdOnClickString#">
                        <cfif canEditDrivers EQ 1 >
						  <a title="#tdTitleString#" href="#tdHrefClickString#&IsCarrier=#url.IsCarrier#">#qCarrier.PhoneNo#</a>
                        <cfelse>
                            #qCarrier.PhoneNo#
                        </cfif>
					</td>

					<td align="left" valign="middle" nowrap="nowrap" class="normal-td" onclick="#tdOnClickString#">
                        <cfif canEditDrivers EQ 1 >
						  <a title="#tdTitleString#" href="mailto:#qCarrier.EmailID#">#qCarrier.EmailID#</a>
                        <cfelse>
                            #qCarrier.EmailID#
                        </cfif>  
					</td>
					<cfif variables.freightBroker EQ "driver">
						<cfset fieldName = "qCarrier.CDLEXPIRES">
					<cfelse>
						<cfset fieldName = "qCarrier.insExpDate">
					</cfif>

					<td align="left" valign="middle" nowrap="nowrap" class="normal-td" onclick="#tdOnClickString#">
						<cfif canEditDrivers EQ 1 >
                            <a title="#tdTitleString#" href="mailto:#qCarrier.EmailID#">#DateFormat(Evaluate(fieldName),'MM/DD/YY')#</a>
                        <cfelse>
                            #DateFormat(Evaluate(fieldName),'MM/DD/YY')#
                        </cfif>  
					</td>

                    <td align="left" valign="middle" nowrap="nowrap" class="normal-td" onclick="#tdOnClickString#">
                        <cfif canEditDrivers EQ 1 >
                            <a title="#tdTitleString#" href="mailto:#qCarrier.EmailID#">#DateFormat(qCarrier.crmnextcalldate,'MM/DD/YYYY')#</a>
                        <cfelse>
                            #DateFormat(qCarrier.crmnextcalldate,'MM/DD/YYYY')#
                        </cfif>  
                    </td>

					<td  align="center" valign="middle" nowrap="nowrap" class="normal-td2" onclick="#tdOnClickString#">
                        <cfif canEditDrivers EQ 1 >
						  <a href="#tdHrefClickString#&IsCarrier=#url.IsCarrier#"><cfif qCarrier.Status eq 0 >InActive<cfelse>Active</cfif></a>
                        <cfelse>
                            <cfif qCarrier.Status eq 0 >InActive<cfelse>Active</cfif>
                        </cfif>  
					</td>
					
					<td class="normal-td3">&nbsp;</td>
	        	</tr>
				<tr <cfif qCarrier.currentRow mod 2 eq 0>bgcolor="##FFFFFF"<cfelse>bgcolor="##f7f7f7"</cfif>>
					<td height="20" class="sky-bg">&nbsp;</td>
					<td class="sky-bg2" valign="middle" onclick="#tdOnClickString#" align="center">&nbsp;</td>
					<td colspan="<cfif request.qSystemSetupOptions.freightBroker EQ 1 OR (request.qSystemSetupOptions.freightBroker EQ 2 AND  structKeyExists(url,"IsCarrier") AND url.IsCarrier EQ 1)>12<cfelse>10</cfif>" align="left" valign="middle" nowrap="nowrap" class="normal-td" style="height:10px;">
						<span class="carrierTextarea" style="display: block;max-height: 35px;overflow: hidden;">#qCarrier.notes#</span>
					</td>
				</tr>
        	 </cfloop>
        	 </tbody>
        	 <tfoot>
        	 <tr>
        		<td width="5" align="left" valign="top"><img src="images/left-bot.gif" alt="" width="5" height="23" /></td>
        		<td colspan="<cfif request.qSystemSetupOptions.freightBroker EQ 1 OR (request.qSystemSetupOptions.freightBroker EQ 2 AND  structKeyExists(url,"IsCarrier") AND url.IsCarrier EQ 1)>12<cfelse>10</cfif>" align="left" valign="middle" class="footer-bg">
        			<div class="up-down">
        				<div class="arrow-top"><a href="javascript: tablePrevPage('dispCarrierForm');"><img src="images/arrow-top.gif" alt="" /></a></div>
        				<div class="arrow-bot"><a href="javascript: tableNextPage('dispCarrierForm');"><img src="images/arrow-bot.gif" alt="" /></a></div>
        			</div>
        			<div class="gen-left" style="font-size: 14px;">
                        <cfif qCarrier.recordcount>
                            <button type="button" class="bttn_nav" onclick="tablePrevPage('dispCarrierForm');">PREV</button>
                            Page
                            <input type="text" onkeyup="if (/\D/g.test(this.value)) this.value = this.value.replace(/\D/g,'')" value="<cfif structKeyExists(form, "pageNo")>#form.pageNo#<cfelse>1</cfif>" id="jumpPageNo" style="text-align: center;width: 25px;" onchange="jumpToPage('dispCarrierForm')">
                                <input type="hidden" id="TotalPages" value="#qCarrier.TotalPages#">
                            of #qCarrier.TotalPages#
                             <button type="button" class="bttn_nav" onclick="tableNextPage('dispCarrierForm');">NEXT</button>
                        </cfif>
                    </div>
        			<div class="gen-right"><img src="images/loader.gif" alt="" /></div>
        			<div class="clear"></div>
        		</td>
        		<td width="5" align="right" valign="top"><img src="images/right-bot.gif" alt="" width="5" height="23" /></td>
        	 </tr>	
        	 </tfoot>	  
        </table>

    <script type="text/javascript">
        function copyToClipboard(text) {

            var EmailIDs = [];
            $(".ckLanes:checked").each(function()
            {   
                emailid = $(this).data('emailid')
                if($.trim(emailid).length){
                    emailid=emailid.replace(";", ",");
                    EmailIDs.push(emailid);
                }
            })
            EmailIDs = unique(EmailIDs);
            EmailIDs = EmailIDs.toString().replace(/,/g, ", ");
            if(!$.trim(EmailIDs).length){
                alert('No Emails copied. Please choose atleast one carrier.');
                return false;
            }
            var $temp = $("<input>");
            $("body").append($temp);
            $temp.val(EmailIDs).select();
            document.execCommand("copy");
            $temp.remove();
            alert('Emails copied.');
        }

        function unique(list) {
            var result = [];
            $.each(list, function(i, e) {
                if ($.inArray(e, result) == -1) result.push(e);
            });
            return result;
        }

        function selectAllCarriers(ckbox){
            if($(ckbox).prop("checked")){
                 $(".ckLanes").prop('checked', true);
            }
            else{
                $(".ckLanes").prop('checked', false);
            }
        }

        $(document).ready(function(){
            $('##carrierLanesEmailButton').click(function(){
                if(!$("##carrierLanesEmailButton").data('allowmail')) {
                    alert('You must setup your email address in your profile before sending email.');
                } else {
                    var ArrCarrierID = ['00000000-0000-0000-0000-000000000000'];
                    $(".ckLanes:checked").each(function()
                    {
                        ArrCarrierID.push($(this).val());
                    })
                    carrierLaneAlertEmailOnClick(ArrCarrierID,'00000000-0000-0000-0000-000000000000',"#session.URLToken#");
                }               
            });
        })
    </script>
        </cfoutput>
        
