<cfsilent>
    <cfif structKeyExists(url, "deleteCarrierContactid")>
        <cfinvoke component="#variables.objCarrierGateway#" method="deleteCarrierContact" CarrierContactid="#url.deleteCarrierContactid#" returnvariable="session.CarrierContactMsg" />
    </cfif>
    <cfinvoke component="#variables.objCarrierGateway#" method="getCarrierContacts"  CarrierID="#url.carrierid#" returnvariable="qCarrierContacts" />
    <cfinvoke component="#variables.objCarrierGateway#" method="getAllCarriers" returnvariable="request.qCarrier">
        <cfinvokeargument name="carrierid" value="#url.carrierid#">
    </cfinvoke>
    <cfinvoke component="#variables.objloadGateway#" method="getSystemSetupOptions" returnvariable="request.qGetSystemSetupOptions" />
</cfsilent>
<cfoutput>
    <script type="text/javascript">
        function popitup(url) {
            newwindow=window.open(url,'Map','height=600,width=800');
            if (window.focus) {newwindow.focus()}
            return false;
        }
    </script>
    <cfset Secret = application.dsn>
    <cfset TheKey = 'NAMASKARAM'>
    <cfset Encrypted = Encrypt(Secret, TheKey)>
    <cfset dsn = URLEncodedFormat(ToBase64(Encrypted))>
    <h1 style="float: left;"><span style="padding-left:160px;">#request.qCarrier.CarrierName#</span></h1>
    <div style="clear:both"></div>
    <cfif structKeyExists(session, "CarrierContactMsg")>
        <div id="message" class="msg-area">#session.CarrierContactMsg#</div>
        <cfset structDelete(session, "CarrierContactMsg")>
    </cfif>
    <cfif isdefined("url.CarrierID") and len(trim(url.CarrierID)) gt 1>
        <cfinclude template="carrierTabs.cfm">
    </cfif>
    <div class="addbutton"><a href="index.cfm?event=addCarrierContact&CarrierId=#url.CarrierId#&#session.URLToken#<cfif structKeyExists(url, "IsCarrier")>&IsCarrier=#url.IsCarrier#</cfif>">Add New</a></div>
    <div style="clear:both"></div>

    <div class="white-con-area" style="height: 36px;background-color: ##82bbef;width:999px;">
         <div style="float: left; width: 20%;" id="divUploadedFiles">
            <img id="missingReqAtt" style="float: left;background-color: ##fff;border-radius: 11px;margin-top: 15px;margin-left: 2px;margin-right: 2px;display: none;width: 16px;" src="images/exclamation.ico" title="Required Attachments Missing">
            <cfinvoke component="#variables.objCarrierGateway#" method="getAttachedFiles" linkedid="#url.carrierid#" fileType="3" returnvariable="request.filesAttached" />
            <cfif request.filesAttached.recordcount neq 0>
                &nbsp;<a id="attachFile" style="display:block;font-size: 13px;padding-left: 2px;color:white;" href="##" onclick="popitup('../fileupload/multipleFileupload/MultipleUpload.cfm?id=#url.carrierid#&attachTo=3&user=#session.adminusername#&dsn=#dsn#&attachtype=Carrier&CompanyID=#session.CompanyID#')"><img style="vertical-align:bottom;" src="images/attachment.png">View/Attach Files</a>
            <cfelse>
                &nbsp;<a style="display:block;font-size: 13px;padding-left: 2px;color:white;" href="##" onclick="popitup('../fileupload/multipleFileupload/MultipleUpload.cfm?id=#url.carrierid#&attachTo=3&user=#session.adminusername#&dsn=#dsn#&attachtype=Carrier&CompanyID=#session.CompanyID#')"><img style="vertical-align:bottom;" src="images/attachment.png">Attach Files</a>

            </cfif>
        </div>
        <div style="float: left; width: 46%;margin-left: 150px;"><h2 style="color:white;font-weight:bold;">Carrier Contacts</h2></div>
    </div>
    <div style="clear:left;"></div>

    <table width="100%" border="0" class="data-table" cellspacing="0" cellpadding="0" style="color:##000000;">
        <thead>
            <tr>
    	        <th width="5" align="center" valign="middle" class="head-bg" style="border-left: 1px solid ##5d8cc9;border-top-left-radius: 5px;">&nbsp;</th>
            	<th align="center" valign="middle" class="head-bg">Contact Person</th>
                <th align="center" valign="middle" class="head-bg">Type</th>
            	<th align="center" valign="middle" class="head-bg">Phone No</th>
                <th align="center" valign="middle" class="head-bg">Fax</th>
                <th align="center" valign="middle" class="head-bg">Toll Free</th>
                <th align="center" valign="middle" class="head-bg">Cell</th>
            	<th align="center" valign="middle" class="head-bg2" style="border-right: 1px solid ##5d8cc9;">Email</th>
            </tr>
        </thead>
        <tbody>
            <cfif qCarrierContacts.recordcount>
                <cfloop query="qCarrierContacts">	
                    <cfset onClickHref = 'index.cfm?event=addCarrierContact&Carrierid=#qCarrierContacts.CarrierID#&CarrierContactID=#qCarrierContacts.CarrierContactID#&#session.URLToken#'>
                    <cfif structKeyExists(url, "IsCarrier")>
                        <cfset onClickHref &= "&IsCarrier=#url.IsCarrier#">
                    </cfif>
                	<cfset rowNum=(qCarrierContacts.currentRow)>
    	            <tr <cfif qCarrierContacts.currentRow mod 2 eq 0>bgcolor="##FFFFFF"<cfelse>bgcolor="##f7f7f7"</cfif>>
                        <td class="sky-bg2" valign="middle" style="border-left: 1px solid ##5d8cc9;">#rowNum#</td>
                        <td  align="left" valign="middle" nowrap="nowrap" class="normal-td" onclick="document.location.href=#onClickHref#"><a href="#onClickHref#">#qCarrierContacts.ContactPerson#</a></td>
                        <td  align="left" valign="middle" nowrap="nowrap" class="normal-td" onclick="document.location.href=#onClickHref#"><a href="#onClickHref#">#qCarrierContacts.ContactType#</a></td>
                        <td  align="left" valign="middle" nowrap="nowrap" class="normal-td" onclick="document.location.href=#onClickHref#"><a href="#onClickHref#">#qCarrierContacts.PhoneNo# #qCarrierContacts.PhoneNoExt#</a></td>
                        <td  align="left" valign="middle" nowrap="nowrap" class="normal-td" onclick="document.location.href=#onClickHref#"><a href="#onClickHref#">#qCarrierContacts.Fax# #qCarrierContacts.FaxExt#</a></td>
                        <td  align="left" valign="middle" nowrap="nowrap" class="normal-td" onclick="document.location.href=#onClickHref#"><a href="#onClickHref#">#qCarrierContacts.TollFree# #qCarrierContacts.TollFreeExt#</a></td>
                        <td  align="left" valign="middle" nowrap="nowrap" class="normal-td" onclick="document.location.href=#onClickHref#"><a href="#onClickHref#">#qCarrierContacts.personMobileNo# #qCarrierContacts.MobileNoExt#</a></td>
                        <td style="border-right: 1px solid ##5d8cc9;" align="left" valign="middle" nowrap="nowrap" class="normal-td2 CRMNotes" onclick="document.location.href=#onClickHref#"><a href="#onClickHref#">#qCarrierContacts.Email#</a></td>
    	            </tr>
    	        </cfloop>
            <cfelse>
                <tr><td  colspan="8" align="center" style="border-left: 1px solid ##5d8cc9;border-right: 1px solid ##5d8cc9;">No Records Found.</td></tr>
            </cfif>
    	</tbody>
        <tfoot>
            <tr>
                <td colspan="8" align="left" valign="middle" class="footer-bg" style="border-left: 1px solid ##5d8cc9;border-right: 1px solid ##5d8cc9;border-bottom-left-radius: 5px;;border-bottom-right-radius: 5px;">
                </td>
            </tr>	
        </tfoot>	  
    </table>
    <div class="clear"></div>
</cfoutput>
    