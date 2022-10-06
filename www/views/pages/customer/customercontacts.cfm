<cfsilent>
    <cfif structKeyExists(url, "deleteCustomerContactid")>
        <cfinvoke component="#variables.objCustomerGateway#" method="deleteCustomerContact" CustomerContactid="#url.deleteCustomerContactid#" returnvariable="session.CustomerContactMsg" />
    </cfif>
    <cfinvoke component="#variables.objCustomerGateway#" method="getCustomerContacts"  CustomerID="#url.customerid#" returnvariable="qCustomerContacts" />
    <cfinvoke component="#variables.objCutomerGateway#" method="getAllCustomers" CustomerID="#url.customerid#" returnvariable="request.qCustomer" />
</cfsilent>
<cfoutput>
    <script>
        $(document).ready(function(){
        })
    </script>
    <h1 style="float: left;"><span style="padding-left:160px;">#request.qCustomer.CustomerName#</span></h1>
    <div style="clear:both"></div>
    <cfif structKeyExists(session, "CustomerContactMsg")>
        <div id="message" class="msg-area">#session.CustomerContactMsg#</div>
        <cfset structDelete(session, "CustomerContactMsg")>
    </cfif>
    <cfif isdefined("url.customerid") and len(trim(url.customerid)) gt 1>
        <div id="customerTabs" class="tabsload ui-tabs ui-widget ui-widget-content ui-corner-all" style="float:left;border:none;padding-bottom: 0;">
            <ul class="ui-tabs-nav ui-helper-reset ui-helper-clearfix ui-widget-header ui-corner-all" style="height:27px;background: ##dfeffc !important;border:none; ">
                <li class="ui-state-default ui-corner-top">
                    <a class="ui-tabs-anchor" href="index.cfm?event=addcustomer&#session.URLToken#&customerId=#url.customerId#">Customer</a>
                </li>
                <li class="ui-state-default ui-corner-top ui-tabs-active ui-state-active">
                  <a class="ui-tabs-anchor">Contacts</a>
                </li>
                <li class="ui-state-default ui-corner-top">
                  <a class="ui-tabs-anchor" href="index.cfm?event=CRMNotes&#session.URLToken#&customerId=#url.customerId#">CRM</a>
                </li>
                <li class="ui-state-default ui-corner-top">
                    <a class="ui-tabs-anchor" href="index.cfm?event=stop&#session.URLToken#&customerId=#url.customerId#">Stops</a>
                </li>
                <li class="ui-state-default ui-corner-top">
                    <a class="ui-tabs-anchor add_quote_txt"  href="index.cfm?event=addstop&#session.URLToken#&customerId=#url.customerId#">Add Stops</a>
                </li>
            </ul>
        </div>
    </cfif>
    <div class="addbutton"><a href="index.cfm?event=addCustomerContact&customerId=#url.customerId#&#session.URLToken#">Add New</a></div>
    <div style="clear:both"></div>
    <div class="white-con-area" style="height: 36px;background-color: ##82bbef;margin-top: 2px;width: 100%;">
        <h2 style="color:white;font-weight:bold;text-align: center;">Customer Contacts</h2>
    </div>

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
            <cfif qCustomerContacts.recordcount>
                <cfloop query="qCustomerContacts">	
                    <cfset onClickHref = 'index.cfm?event=addCustomerContact&customerid=#qCustomerContacts.CustomerID#&CustomerContactID=#qCustomerContacts.CustomerContactID#&#session.URLToken#'>
                	<cfset rowNum=(qCustomerContacts.currentRow)>
    	            <tr <cfif qCustomerContacts.currentRow mod 2 eq 0>bgcolor="##FFFFFF"<cfelse>bgcolor="##f7f7f7"</cfif>>
                        <td class="sky-bg2" valign="middle" style="border-left: 1px solid ##5d8cc9;">#rowNum#</td>
                        <td  align="left" valign="middle" nowrap="nowrap" class="normal-td" onclick="document.location.href=#onClickHref#"><a href="#onClickHref#">#qCustomerContacts.ContactPerson#</a></td>
                        <td  align="left" valign="middle" nowrap="nowrap" class="normal-td" onclick="document.location.href=#onClickHref#"><a href="#onClickHref#">#qCustomerContacts.ContactType#</a></td>
                        <td  align="left" valign="middle" nowrap="nowrap" class="normal-td" onclick="document.location.href=#onClickHref#"><a href="#onClickHref#">#qCustomerContacts.PhoneNo# #qCustomerContacts.PhoneNoExt#</a></td>
                        <td  align="left" valign="middle" nowrap="nowrap" class="normal-td" onclick="document.location.href=#onClickHref#"><a href="#onClickHref#">#qCustomerContacts.Fax# #qCustomerContacts.FaxExt#</a></td>
                        <td  align="left" valign="middle" nowrap="nowrap" class="normal-td" onclick="document.location.href=#onClickHref#"><a href="#onClickHref#">#qCustomerContacts.TollFree# #qCustomerContacts.TollFreeExt#</a></td>
                        <td  align="left" valign="middle" nowrap="nowrap" class="normal-td" onclick="document.location.href=#onClickHref#"><a href="#onClickHref#">#qCustomerContacts.personMobileNo# #qCustomerContacts.MobileNoExt#</a></td>
                        <td style="border-right: 1px solid ##5d8cc9;" align="left" valign="middle" nowrap="nowrap" class="normal-td2 CRMNotes" onclick="document.location.href=#onClickHref#"><a href="#onClickHref#">#qCustomerContacts.Email#</a></td>
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
    