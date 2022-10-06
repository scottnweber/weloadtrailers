<cfparam name="form.sortOrder" default="ASC">
<cfparam name="form.sortBy" default="CarrierName">
<cfparam name="form.pageNo" default="1">
<cfparam name="form.PickUpState" default="">
<cfparam name="form.DeliveryState" default="">
<cfparam name="form.EquipmentID" default="">

<cfsilent>
    <cfinvoke component="#variables.objCarrierGateway#" method="getAdvanceSearchedCarrier" pageNo="#form.pageNo#" sortorder="#form.sortOrder#" sortby="#form.sortBy#" frmstruct="#form#" returnvariable="qCarrier" />
    <cfinvoke component="#variables.objloadGateway#" method="getSystemSetupOptions" returnvariable="request.qSystemSetupOptions" />
    <cfinvoke component="#variables.objloadGateway#" method="getcurAgentMaildetails" returnvariable="request.qcurMailAgentdetails" employeID="#session.empid#" />
</cfsilent>
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
<cfset variables.freightBroker = "carrier"> 
<cfset url.iscarrier = 1> 
<cfset canEditDrivers = 1>
<cfif variables.freightBroker EQ "driver" AND NOT ListContains(session.rightsList,'editDrivers',',')>
    <cfset canEditDrivers = 0>
</cfif>
<cfoutput>
    <cfform id="dispCarrierForm" name="dispCarrierForm" action="index.cfm?event=CarrierAdvanced&#session.URLToken#&Iscarrier=1" method="post" preserveData="yes">
        <cfinput id="pageNo" name="pageNo" value="1" type="hidden">
        <cfinput id="sortOrder" name="sortOrder" value="ASC" type="hidden">
        <cfinput id="sortBy" name="sortBy" value="CarrierName" type="hidden">
        <cfinput name="PickUpState" id="PickUpState" value="#form.PickUpState#" type="hidden">
        <cfinput name="DeliveryState" id="DeliveryState" value="#form.DeliveryState#" type="hidden">
        <cfinput name="EquipmentID" id="EquipmentID" value="#form.EquipmentID#" type="hidden">
        <input id="carrierLanesEmailButton" class="black-btn tooltip" value="Email Carriers" type="button" <cfif mailsettings>data-allowmail="true"<cfelse>data-allowmail="false"</cfif>>
        <input type="hidden" name="TotalCarrierChargesHidden" id="TotalCarrierChargesHidden" value="0">
        <input type="hidden" name="Dispatcher" id="Dispatcher" value="00000000-0000-0000-0000-000000000000">
        <input id="copyButtonId" type="button" value="Copy Emails" id="CopyEmails" onclick="copyToClipboard()">

    </cfform>   
	<style type="text/css">
		span.carrierTextarea{ 
			white-space: pre-wrap;      
			white-space: -moz-pre-wrap; 
			white-space: -pre-wrap;     
			white-space: -o-pre-wrap;   
			word-wrap: break-word;
		}
        ##carrierLanesEmailButton{
            margin-bottom: 5px;
        }
        .data-table th{
            background-size: contain;
        }
	</style>


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
	<table width="100%" border="0" class="data-table" cellspacing="0" cellpadding="0">
        <thead>
            <tr>
        	<th width="5" align="left" valign="top"><img src="images/top-left.gif" alt="" width="5" height="32"/></th>			
        	<th width="24" align="center" valign="middle" class="head-bg">&nbsp;</th>	
            <th width="24" align="center" valign="middle" class="head-bg">Select<br><input type="checkbox" class="myElements" onclick="selectAllCarriers(this);"> </th>   		
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
            <th width="120" align="center" valign="middle" class="head-bg" onclick="sortTableBy('Address','dispCarrierForm');">Address</th>
        	<th width="120" align="center" valign="middle" class="head-bg" onclick="sortTableBy('city','dispCarrierForm');">City</th>
			<th width="50" align="center" valign="middle" class="head-bg" onclick="sortTableBy('StateCode','dispCarrierForm');">State</th>
            <th width="50" align="center" valign="middle" class="head-bg" onclick="sortTableBy('ZipCode','dispCarrierForm');">Zip</th>
            <th width="50" align="center" valign="middle" class="head-bg" onclick="sortTableBy('ContactPerson','dispCarrierForm');">Contact</th>
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
					<td class="sky-bg2" valign="middle" onclick="#tdOnClickString#" align="center">#rowNum#</td><td align="left" valign="middle" nowrap="nowrap" class="normal-td">
                        <input type="checkbox" class="ckLanes myElements" data-emailid="#qCarrier.EmailID#"  value="#qCarrier.CarrierID#">
                    </td>					
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
                            <a title="#tdTitleString#" href="#tdHrefClickString#&IsCarrier=#url.IsCarrier#">#qCarrier.address#</a>
                        <cfelse>
                            #qCarrier.address#
                        </cfif>   
                    </td>
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
                            <a title="#tdTitleString#" href="#tdHrefClickString#&IsCarrier=#url.IsCarrier#">#qCarrier.ZipCode#</a>
                        <cfelse>
                            #qCarrier.ZipCode#
                        </cfif>
                    </td>
                    <td align="left" valign="middle" nowrap="nowrap" class="normal-td" onclick="#tdOnClickString#">
                        <cfif canEditDrivers EQ 1 >
                            <a title="#tdTitleString#" href="#tdHrefClickString#&IsCarrier=#url.IsCarrier#">#qCarrier.ContactPerson#</a>
                        <cfelse>
                            #qCarrier.ContactPerson#
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
					<td colspan="<cfif request.qSystemSetupOptions.freightBroker EQ 1 OR (request.qSystemSetupOptions.freightBroker EQ 2 AND  structKeyExists(url,"IsCarrier") AND url.IsCarrier EQ 1)>15<cfelse>14</cfif>" align="left" valign="middle" nowrap="nowrap" class="normal-td" style="height:10px;">
						<span class="carrierTextarea" style="display: block;max-height: 35px;overflow: hidden;">#qCarrier.notes#</span>
					</td>
				</tr>
        	 </cfloop>
        	 </tbody>
        	 <tfoot>
        	 <tr>
        		<td width="5" align="left" valign="top"><img src="images/left-bot.gif" alt="" width="5" height="23" /></td>
        		<td colspan="<cfif request.qSystemSetupOptions.freightBroker EQ 1 OR (request.qSystemSetupOptions.freightBroker EQ 2 AND  structKeyExists(url,"IsCarrier") AND url.IsCarrier EQ 1)>15<cfelse>14</cfif>" align="left" valign="middle" class="footer-bg">
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
        </cfoutput>
        
