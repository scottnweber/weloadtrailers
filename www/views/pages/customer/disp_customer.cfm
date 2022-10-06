<cfparam name="message" default="">
<cfparam name="url.sortorder" default="desc">
<cfparam name="sortby"  default="">
<cfparam name="variables.pending"  default="0">
<cfsilent>
  <cfif structKeyExists(url, "pending") and url.pending EQ 1>
    <cfset variables.pending = 1>
  </cfif>
	<cfif isdefined("form.searchText") >
		<cfif structKeyExists(url,"payer")>
			<cfif structkeyexists(session,"currentusertype") AND  listfindnocase("sales representative,dispatcher,manager",session.currentusertype) >
				<cfinvoke component="#variables.objCutomerGateway#" method="getSearchedCustomer" officeid="#session.officeid#"  searchText="#form.searchText#" pageNo="#form.pageNo#" sortorder="#form.sortOrder#" sortby="#form.sortBy#" argPayer="#url.payer#"   returnvariable="qCustomer" />
			<cfelse>
				<cfinvoke component="#variables.objCutomerGateway#" method="getSearchedCustomer" searchText="#form.searchText#" pageNo="#form.pageNo#" sortorder="#form.sortOrder#" sortby="#form.sortBy#" argPayer="#url.payer#"  returnvariable="qCustomer" />
			</cfif>
		<cfelse>
			<cfif structkeyexists(session,"currentusertype") AND  listfindnocase("sales representative,dispatcher,manager",session.currentusertype) >
				<cfinvoke component="#variables.objCutomerGateway#" method="getSearchedCustomer" searchText="#form.searchText#" pending="#variables.pending#" officeid="#session.officeid#"   pageNo="#form.pageNo#" sortorder="#form.sortOrder#" sortby="#form.sortBy#"  returnvariable="qCustomer" />
			<cfelse>
				<cfinvoke component="#variables.objCutomerGateway#" method="getSearchedCustomer" searchText="#form.searchText#" pending="#variables.pending#" pageNo="#form.pageNo#" sortorder="#form.sortOrder#" sortby="#form.sortBy#"  returnvariable="qCustomer" />
			</cfif>
		</cfif>		
			<cfif qCustomer.recordcount lte 0>
				<cfset message="No match found">
			</cfif>
	<cfelse>
		<cfif isdefined("url.customerid") and len(url.customerid) gt 1>	
			<cfinvoke component="#variables.objCutomerGateway#" method="deleteCustomers" CustomerID="#url.customerid#" returnvariable="message" />
			<cfinvoke component="#variables.objCutomerGateway#" method="getSearchedCustomer" searchText="" pageNo="1" returnvariable="qCustomer" />
		<cfelseif isdefined("url.payer")>
      <cfif structkeyexists(session,"currentusertype") AND  listfindnocase("sales representative,dispatcher,manager",session.currentusertype) >
        <cfinvoke component="#variables.objCutomerGateway#" method="getSearchedCustomer" officeid="#session.officeid#" searchText="" pageNo="1" argPayer="#url.payer#" returnvariable="qCustomer" />  
      <cfelse>
  			<cfinvoke component="#variables.objCutomerGateway#" method="getSearchedCustomer" searchText="" pageNo="1" argPayer="#url.payer#" returnvariable="qCustomer" />		
      </cfif>
		<cfelse>
				<cfif structkeyexists(session,"currentusertype") AND  listfindnocase("sales representative,dispatcher,manager",session.currentusertype) >

						<cfinvoke component="#variables.objCutomerGateway#" pending="#variables.pending#" method="getSearchedCustomer" searchText="" pageNo="1" officeid="#session.officeid#" returnvariable="qCustomer" />				
				<cfelse>
					<!--- Getting page1 of All Results --->
					<cfinvoke component="#variables.objCutomerGateway#" pending="#variables.pending#" method="getSearchedCustomer" searchText="" pageNo="1" returnvariable="qCustomer" />
				</cfif>
					
		</cfif>
	</cfif>
 </cfsilent>

<cfoutput>
  <cfif structKeyExists(url, "pending")>
    <h1>Customers with missing <a target="_blank" style="text-decoration: underline;" href="index.cfm?event=attachmentTypes&#session.URLToken#">Attachments</a></h1>
  <cfelse>
    <h1>All Customers</h1>
  </cfif>
<div style="clear:left"></div>

<cfif isdefined("message") and len(message)>
<div id="message" class="msg-area">#message#</div>
</cfif>
	<cfif isdefined("session.message") and len(session.message)>
		<div id="message" class="msg-area">#session.message#</div>
	<cfset exists= structdelete(session, 'message', true)/> 
	</cfif>
<div class="search-panel" style="width:100%;">
<div class="form-search" style="width:85%;">
<cfif structKeyExists(url,'payer')>
	<cfset frmAction = "index.cfm?event=customer&#session.URLToken#&payer=#url.payer#">
<cfelse>
	<cfif structKeyExists(url, "pending") and url.pending EQ 1>
    <cfset frmAction = "index.cfm?event=customer&#session.URLToken#&pending=1"> 
  <cfelse>
    <cfset frmAction = "index.cfm?event=customer&#session.URLToken#"> 
  </cfif>
</cfif>


<cfform id="dispCustomerForm" name="dispCustomerForm" action="#frmAction#" method="post" preserveData="yes">
	<cfinput id="pageNo" name="pageNo" value="1" type="hidden">
    
    <cfinput id="sortOrder" name="sortOrder" value="ASC" type="hidden">
    <cfinput id="sortBy" name="sortBy" value="CustomerName" type="hidden">
    
	<fieldset>
		<cfinput name="searchText" type="text" />
		<cfinput name="" onclick="javascript: document.getElementById('pageNo').value=1;" type="submit" class="s-bttn" value="Search" style="width:56px;" />
		<div class="clear"></div>
	</fieldset>
</cfform>			
</div>

<div style="float: left"> <!--- Add/Delete --->
  <div class="addbutton" style="float: left;"><a href="index.cfm?event=add<cfif request.qGetSystemSetupOptions.autoAddCustViaDOT EQ 1>new</cfif>customer&#session.URLToken#">Add New</a></div>
  <div class="delbutton"  style="float: left;display: none;">
    <a href="javascript:void(0);" onclick="bulkDeleteCustomers()">  Delete</a>
  </div>
</div>
</div>



<table width="100%" border="0" class="data-table" cellspacing="0" cellpadding="0" style="color:##000000;">
      <thead>
      <tr>
    	<th width="5" align="left" valign="top"><img src="images/top-left.gif" alt="" width="5" height="23" /></th>
    	<th width="29" align="center" valign="middle" class="head-bg">&nbsp;</th>
      <th width="25" align="center" valign="middle" class="head-bg"><input type="checkbox" class="ckDelCustomer" value=""></th>
    	<th width="25" align="center" valign="middle" class="head-bg" onclick="sortTableBy('CustomerName','dispCustomerForm');">Name</th>
    	<th width="50" align="center" valign="middle" class="head-bg" onclick="sortTableBy('address','dispCustomerForm');">Address</th>
      <th width="40" align="center" valign="middle" class="head-bg" onclick="sortTableBy('City','dispCustomerForm');">City</th>
      <th width="40" align="center" valign="middle" class="head-bg" onclick="sortTableBy('stateCode','dispCustomerForm');">State</th>
      <th width="50" align="center" valign="middle" class="head-bg" onclick="sortTableBy('zipCode','dispCustomerForm');">Zip</th>
    	<th width="50" align="center" valign="middle" class="head-bg" onclick="sortTableBy('phoneNo','dispCustomerForm');">Phone No.</th>
        <th width="40" align="center" valign="middle" class="head-bg" onclick="sortTableBy('office','dispCustomerForm');">Office</th>
        <th width="40" align="center" valign="middle" class="head-bg" onclick="sortTableBy('CRMNextCallDate','dispCustomerForm');">Next Call</th>
        <cfif listFindNoCase("1,2", request.qGetSystemSetupOptions.freightbroker)>
          <th width="40" align="center" valign="middle" class="head-bg" onclick="sortTableBy('SalesAgent','dispCustomerForm');">Sales Rep</th>
        </cfif>
        <th width="40" align="center" valign="middle" class="head-bg" onclick="sortTableBy('Dispatcher','dispCustomerForm');">Dispatcher</th>
    	<th width="30" align="center" valign="middle" class="head-bg2" onclick="sortTableBy('status','dispCustomerForm');">Status</th>
    	<th width="5" align="right" valign="top"><img src="images/top-right.gif" alt="" width="5" height="23" /></th>
      </tr>
      </thead>
      <tbody>
         <cfloop query="qCustomer">	
    	    <cfinvoke component="#variables.objCutomerGateway#" method="getCompanies" returnvariable="request.qCompanies">
    	    <cfinvokeargument name="CompanyID" value="#session.CompanyID#">
    	    </cfinvoke>
            
            <cfset pageSize = 30>
            <cfif isdefined("form.pageNo")>
            	<cfset rowNum=(qCustomer.currentRow) + ((form.pageNo-1)*pageSize)>
            <cfelse>
            	<cfset rowNum=(qCustomer.currentRow)>
            </cfif>
    	<tr <cfif qCustomer.currentRow mod 2 eq 0>bgcolor="##FFFFFF"<cfelse>bgcolor="##f7f7f7"</cfif>>
			<td height="20" class="sky-bg">&nbsp;</td>

			<td class="sky-bg2" valign="middle" onclick="document.location.href='index.cfm?event=addcustomer&customerid=#qCustomer.CustomerID#&#session.URLToken#'" align="center">#rowNum#</td>
      <td  align="left" valign="middle" nowrap="nowrap" class="normal-td" style="padding:0px 5px 0px 5px;">
        <input type="checkbox" class="ckDelCustomer" value="#qCustomer.CustomerID#">
      </td>
			<td  align="left" valign="middle" nowrap="nowrap" class="normal-td" onclick="document.location.href='index.cfm?event=addcustomer&customerid=#qCustomer.CustomerID#&#session.URLToken#'"><a title="#qCustomer.CustomerName# #qCustomer.OfficeLocation# #qCustomer.PhoneNo# #request.qCompanies.CompanyName#" href="index.cfm?event=addcustomer&customerid=#qCustomer.CustomerID#&#session.URLToken#">#qCustomer.CustomerName#</a></td>
			<td align="left" valign="middle" nowrap="nowrap" class="normal-td" onclick="document.location.href='index.cfm?event=addcustomer&customerid=#qCustomer.CustomerID#&#session.URLToken#'"><a title="#qCustomer.CustomerName# #qCustomer.OfficeLocation#  #qCustomer.PhoneNo# #request.qCompanies.CompanyName#" href="index.cfm?event=addcustomer&customerid=#qCustomer.CustomerID#&#session.URLToken#"><cfif isDefined("qCustomer.custLocation")>#qCustomer.custLocation#</cfif><cfif isDefined("qCustomer.Location")>#qCustomer.Location#</cfif></a></td>
      <td align="left" valign="middle" nowrap="nowrap" class="normal-td" onclick="document.location.href='index.cfm?event=addcustomer&customerid=#qCustomer.CustomerID#&#session.URLToken#'"><a title="#qCustomer.CustomerName# #qCustomer.OfficeLocation#  #qCustomer.PhoneNo# #request.qCompanies.CompanyName#" href="index.cfm?event=addcustomer&customerid=#qCustomer.CustomerID#&#session.URLToken#">#qCustomer.City#</a></td>
      <td align="left" valign="middle" nowrap="nowrap" class="normal-td" onclick="document.location.href='index.cfm?event=addcustomer&customerid=#qCustomer.CustomerID#&#session.URLToken#'"><a title="#qCustomer.CustomerName# #qCustomer.OfficeLocation#  #qCustomer.PhoneNo# #request.qCompanies.CompanyName#" href="index.cfm?event=addcustomer&customerid=#qCustomer.CustomerID#&#session.URLToken#">#qCustomer.stateCode#</a></td>
      <td align="left" valign="middle" nowrap="nowrap" class="normal-td" onclick="document.location.href='index.cfm?event=addcustomer&customerid=#qCustomer.CustomerID#&#session.URLToken#'"><a title="#qCustomer.CustomerName# #qCustomer.OfficeLocation#  #qCustomer.PhoneNo# #request.qCompanies.CompanyName#" href="index.cfm?event=addcustomer&customerid=#qCustomer.CustomerID#&#session.URLToken#">#qCustomer.zipCode#</a></td>
			<td align="left" valign="middle" nowrap="nowrap" class="normal-td" onclick="document.location.href='index.cfm?event=addcustomer&customerid=#qCustomer.CustomerID#&#session.URLToken#'"><a title="#qCustomer.CustomerName# #qCustomer.OfficeLocation#  #qCustomer.PhoneNo# #request.qCompanies.CompanyName#" href="index.cfm?event=addcustomer&customerid=#qCustomer.CustomerID#&#session.URLToken#">#qCustomer.PhoneNo#</a></td>
			


      <td align="left" valign="middle" nowrap="nowrap" class="normal-td" onclick="document.location.href='index.cfm?event=addcustomer&customerid=#qCustomer.CustomerID#&#session.URLToken#'">
            <a title="#qCustomer.CustomerName# #qCustomer.OfficeLocation#  #qCustomer.PhoneNo# #request.qCompanies.CompanyName#" href="index.cfm?event=addcustomer&customerid=#qCustomer.CustomerID#&#session.URLToken#">#replace(qCustomer.OfficeLocation, ";", '<br>','all')#
            </a><br>
      </td>
      <td align="left" valign="middle" nowrap="nowrap" class="normal-td" onclick="document.location.href='index.cfm?event=addcustomer&customerid=#qCustomer.CustomerID#&#session.URLToken#'"><a title="#qCustomer.CustomerName# #qCustomer.OfficeLocation#  #qCustomer.PhoneNo# #request.qCompanies.CompanyName#" href="index.cfm?event=addcustomer&customerid=#qCustomer.CustomerID#&#session.URLToken#">#dateformat(qCustomer.CRMNextCallDate,'mm/dd/yyyy')#</a></td>

      <cfif listFindNoCase("1,2", request.qGetSystemSetupOptions.freightbroker)>
        <td align="left" valign="middle" nowrap="nowrap" class="normal-td" onclick="document.location.href='index.cfm?event=addcustomer&customerid=#qCustomer.CustomerID#&#session.URLToken#'"><a title="#qCustomer.CustomerName# #qCustomer.OfficeLocation#  #qCustomer.PhoneNo# #request.qCompanies.CompanyName#" href="index.cfm?event=addcustomer&customerid=#qCustomer.CustomerID#&#session.URLToken#">#qCustomer.SalesAgent#</a></td>
      </cfif>
      <td align="left" valign="middle" nowrap="nowrap" class="normal-td" onclick="document.location.href='index.cfm?event=addcustomer&customerid=#qCustomer.CustomerID#&#session.URLToken#'"><a title="#qCustomer.CustomerName# #qCustomer.OfficeLocation#  #qCustomer.PhoneNo# #request.qCompanies.CompanyName#" href="index.cfm?event=addcustomer&customerid=#qCustomer.CustomerID#&#session.URLToken#">#qCustomer.Dispatcher#</a></td>

			<td align="center" valign="middle" nowrap="nowrap" class="normal-td2" onclick="document.location.href='index.cfm?event=addcustomer&customerid=#qCustomer.CustomerID#&#session.URLToken#'"><a href="index.cfm?event=addcustomer&customerid=#qCustomer.CustomerID#&#session.URLToken#"><cfif #qCustomer.CustomerStatusId# eq 1>Active<cfelse>Inactive</cfif></a></td>
			<td class="normal-td3">&nbsp;</td>
    	 </tr>
    	 </cfloop>
    	 </tbody>
    	 <tfoot>
    	 <tr>
    		<td width="5" align="left" valign="top"><img src="images/left-bot.gif" alt="" width="5" height="23" /></td>
    		<td colspan="<cfif listFindNoCase("1,2", request.qGetSystemSetupOptions.freightbroker)>13<cfelse>12</cfif>" align="left" valign="middle" class="footer-bg">
    			<div class="up-down">
    				<div class="arrow-top"><a href="javascript: tablePrevPage('dispCustomerForm');"><img src="images/arrow-top.gif" alt="" /></a></div>
    				<div class="arrow-bot"><a href="javascript: tableNextPage('dispCustomerForm');"><img src="images/arrow-bot.gif" alt="" /></a></div>
    			</div>
          <div class="gen-left" style="font-size: 14px;">
              <cfif qCustomer.recordcount>
                  <button type="button" class="bttn_nav" onclick="tablePrevPage('dispCustomerForm');">PREV</button>
                  Page 
                  <input type="text" onkeyup="if (/\D/g.test(this.value)) this.value = this.value.replace(/\D/g,'')" value="<cfif structKeyExists(form, "pageNo")>#form.pageNo#<cfelse>1</cfif>" id="jumpPageNo" style="text-align: center;width: 25px;" onchange="jumpToPage('dispCustomerForm')">
                      <input type="hidden" id="TotalPages" value="#qCustomer.TotalPages#">
                  of #qCustomer.TotalPages#
                  <button type="button" class="bttn_nav" onclick="tableNextPage('dispCustomerForm');">NEXT</button>
              </cfif>
          </div>
    			<div class="gen-right"><img src="images/loader.gif" alt="" /></div>
    			<div class="clear"></div>
    		</td>
    		<td width="5" align="right" valign="top"><img src="images/right-bot.gif" alt="" width="5" height="23" /></td>
    	 </tr>	
    	 </tfoot>	  
    </table>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/jquery-confirm/3.3.2/jquery-confirm.min.css">
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jquery-confirm/3.3.2/jquery-confirm.min.js"></script>
    <script  type="text/javascript">
      $(document).ready(function(){
        $('.ckDelCustomer').click(function(){
          var val = $(this).val();
          var ckd = $(this).prop("checked");
          if(!val.length){
            $(".ckDelCustomer").prop('checked', ckd);
          }
          if(ckd){
            $('.delbutton').show();
          }
          else{
            $('.delbutton').hide();
          }
        })
      })

      function bulkDeleteCustomers(){
        $.confirm({
          title: '<p style="color:##ba0000">Warning!</p>',
          content: '<strong style="font-size:12px;">Are you sure you want to delete the selected customer(s)?</strong>',
          buttons: {
            confirm: {
              text: 'OK',
              action: function () {
                var arrCustomers = [];
                $(".ckDelCustomer:checked").each(function() {
                  if(this.value.length){
                    arrCustomers.push(this.value);
                  }
                });
                $('.overlay').show();
                $('##loader').show();
                recursiveAjaxDeleteCustomer(arrCustomers,0);
              }
            },
            cancel: {
                btnClass: 'btn-blue',
                keys: ['enter'],
            }
          }
        })
      }

      var del = 0;
      var notDel = 0;

      function recursiveAjaxDeleteCustomer(arrCustomers,indx){
        if(indx<arrCustomers.length){
          var CustomerID = arrCustomers[indx];
          var path = "../gateways/customergateway.cfc?method=recursiveAjaxDeleteCustomer";
          $.ajax({
            type: "post",
            url: path,    
            dataType: "json",
            data: {
                CustomerID : CustomerID, dsn: '#application.dsn#'
            },
            success: function(data){
              if(data.deleted == 1){
                del++;
              }
              else{
                notDel++
              }
              recursiveAjaxDeleteCustomer(arrCustomers,indx+1);
            }
          });
        }
        else{
          $('##loader').hide();
          var dialogMsg = '<strong><span style="color:##0f4100">'+del+'</span> customer entries have been successfully deleted.</strong>'
          if(notDel != 0){
            dialogMsg = dialogMsg + '<br><strong><span style="color:##800000">'+notDel+'</span> customer entries are currentely assigned loads and cannot be deleted. Please unassign all loads to delete customer entries.</strong>'
          }
          $.confirm({
             title: '<p style="color:##ba0000">Deleted!</p>',
              content: '<strong style="font-size:12px;">'+dialogMsg+'</strong>',
              buttons: {
                  confirm: {
                      text: 'OK',
                      action: function () {
                        window.location.reload();
                      },
                      btnClass: 'btn-blue',
                      keys: ['enter'],
                  }
              }
          });
        }
      }
    </script>
    <style>
      .jconfirm-scrollpane{
        margin-left: 35%;
        width:32% !important;
      }
      ##loader{
            position: fixed;
            top:40%;
            left:40%;
            z-index: 999;
            display: none;
        }
        ##loadingmsg{
            font-weight: bold;
            text-align: center;
            margin-top: 1px;
            background-color: ##fff;
        }
    </style>
    <div class="overlay">
    </div>
    <div id="loader">
        <img src="images/loadDelLoader.gif">
        <p id="loadingmsg">Please wait.</p>
    </div>
    </cfoutput>
    