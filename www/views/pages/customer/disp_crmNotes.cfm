<cfparam name="message" default="">
<cfparam name="sortorder" default="desc">
<cfparam name="sortby"  default="">
<cfsilent>
    <cfif isdefined("form.searchFormSubmit") >
        <cfinvoke component="#variables.objCustomerGateway#" method="getSearchedCRMNotes" pageNo="#form.pageNo#" sortorder="#form.sortOrder#" sortby="#form.sortBy#"  CustomerID="#url.customerid#"  returnvariable="qCRMNotes" />
    <cfelse>
        <cfinvoke component="#variables.objCustomerGateway#" method="getSearchedCRMNotes"  CustomerID="#url.customerid#" searchText="" pageNo="1" returnvariable="qCRMNotes" />
    </cfif>
    <cfinvoke component="#variables.objCutomerGateway#" method="getAllCustomers" CustomerID="#url.customerid#" returnvariable="request.qCustomer" />
    <cfinvoke component="#variables.objCutomerGateway#" method="getCRMNoteTypeDetails" returnvariable="request.qCRMNoteTypes" />
    <cfinvoke component="#variables.objCustomerGateway#" method="getCustomerContacts"  CustomerID="#url.customerid#" returnvariable="qCustomerContacts" />
    <cfset AuthLevel = "Sales Representative,Manager,Dispatcher,Administrator,Central Dispatcher">
    <cfinvoke component="#variables.objloadGateway#" AuthLevel="#AuthLevel#" method="getloadSalesPerson" returnvariable="request.qSalesPerson" />
</cfsilent>

<cfoutput>
<style type="text/css">
    .crm-form-con label{
        width:50px !important;
    }
    .crm-form-con1 label{
        width:85px !important;
    }
    .ui-datepicker-trigger{
      float: left;
    }
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
    .msg-area-error{
        border: 1px solid ##da4646;
        padding: 5px 15px;
        font-weight: normal;
        width: 82%;
        float: left;
        margin-top: 5px;
        margin-bottom:  5px;
        background-color: ##e4b9c6;
        font-weight: bold;
        font-style: italic;
    }
</style>
  <script>
    function explode(str, maxLength) {
      var buff = "";
      var numOfLines = Math.floor(str.length/maxLength);

      for(var i = 0; i<numOfLines+1; i++) {
          buff += str.substr(i*maxLength, maxLength); if(i !== numOfLines) { buff += "<br>"; }
      }
      return buff;
    }

    $(document).ready(function(){
      <cfif structKeyExists(session, "CRMNoteMessage")>
        alert('#session.CRMNoteMessage#');
        <cfset structDelete(session, "CRMNoteMessage")>
      </cfif>
      $( ".datefield" ).datepicker({
              dateFormat: "mm/dd/yy",
              showOn: "button",
              buttonImage: "images/DateChooser.png",
              buttonImageOnly: true,
              showButtonPanel: true
            });

      $(".CRMNotes").each(function(){
        var str = $(this).html();
        $(this).html(explode(str, 80));
      })

      $('##CRMContactID').change(function(){
        if($.trim($('##CRMContactID').val()).length){
          $('##CRMPhoneNo').val($(this).find(':selected').attr('data-PhoneNo'));
          $('##CRMPhoneNoExt').val($(this).find(':selected').attr('data-PhoneNoExt'));
          $('##CRMFax').val($(this).find(':selected').attr('data-Fax'));
          $('##CRMFaxExt').val($(this).find(':selected').attr('data-FaxExt'));
          $('##CRMTollFree').val($(this).find(':selected').attr('data-TollFree'));
          $('##CRMTollFreeExt').val($(this).find(':selected').attr('data-TollFreeExt'));
          $('##CRMCell').val($(this).find(':selected').attr('data-PersonMobileNo'));
          $('##CRMCellExt').val($(this).find(':selected').attr('data-MobileNoExt'));
          $('##CRMEmail').val($(this).find(':selected').attr('data-Email'));
        }
      })
    })
  </script>
<h1 style="float: left;"><span style="padding-left:160px;">#request.qCustomer.CustomerName#</span></h1>
<div style="clear:both"></div>
<cfif structKeyExists(url, "msg")>
  <div id="message" class="msg-area">#url.msg#</div>
</cfif>
<cfif structKeyExists(session, "CRMresponse")>
    <div id="message" class="msg-area-#session.CRMresponse.res#">#session.CRMresponse.msg#</div>
    <cfset structdelete(session, 'CRMresponse', true)/> 
</cfif>
<cfif isdefined("url.customerid") and len(trim(url.customerid)) gt 1>
<div id="customerTabs" class="tabsload ui-tabs ui-widget ui-widget-content ui-corner-all" style="float:left;border:none;padding-bottom: 0;">
    <ul class="ui-tabs-nav ui-helper-reset ui-helper-clearfix ui-widget-header ui-corner-all" style="height:27px;background: ##dfeffc !important;border:none; ">
        <li class="ui-state-default ui-corner-top">
            <a class="ui-tabs-anchor" href="index.cfm?event=addcustomer&#session.URLToken#&customerId=#url.customerId#">Customer</a>
        </li>
        <li class="ui-state-default ui-corner-top">
          <a class="ui-tabs-anchor" href="index.cfm?event=CustomerContacts&#session.URLToken#&customerId=#url.customerId#">Contacts</a>
        </li>
        <li class="ui-state-default ui-corner-top  ui-tabs-active ui-state-active">
            <a class="ui-tabs-anchor">CRM</a>
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
<div class="search-panel">
<div class="form-search" style="display: none;">

<cfset frmAction = "index.cfm?event=CRMNotes&customerId=#url.customerid#&#session.URLToken#">   

<cfform id="dispCRMNotesForm" name="dispCRMNotesForm" action="#frmAction#" method="post" preserveData="yes">
    <cfinput id="pageNo" name="pageNo" value="1" type="hidden">
    <cfinput id="sortOrder" name="sortOrder" value="DESC" type="hidden">
    <cfinput id="sortBy" name="sortBy" value="C.CreatedDateTime" type="hidden">
    <cfinput name="searchFormSubmit"  type="hidden" />
</cfform>         
</div>

<div style="clear:both"></div>
<div class="white-con-area" style="height: 36px;background-color: ##82bbef;margin-top: 2px;">
    <h2 style="color:white;font-weight:bold;text-align: center;">Schedule Call</h2>
</div>
<div class="white-con-area">
    <div class="white-top"></div>
    <div class="white-mid">
        <cfform name="frmCustomerCrm" action="index.cfm?event=saveScheduleCall&CustomerID=#url.CustomerID#&#session.URLToken#" method="post">
            <div class="form-con">
                <fieldset  class="carrierFields">
                    <label>Contact Name</label>
                    <select name="CRMContactID" id="CRMContactID">
                        <option value="">Select</option>
                        <option value="#request.qCustomer.CustomerID#" <cfif request.qCustomer.CRMContactID EQ request.qCustomer.CustomerID> selected </cfif>
                            data-PhoneNo = "#request.qCustomer.PhoneNo#"
                            data-PhoneNoExt = "#request.qCustomer.PhoneNoExt#"
                            data-Fax = "#request.qCustomer.Fax#"
                            data-FaxExt = "#request.qCustomer.FaxExt#"
                            data-TollFree = "#request.qCustomer.TollFree#"
                            data-TollfreeExt = "#request.qCustomer.TollfreeExt#"
                            data-PersonMobileNo = "#request.qCustomer.PersonMobileNo#"
                            data-MobileNoExt = "#request.qCustomer.MobileNoExt#"
                            data-Email = "#request.qCustomer.Email#"
                            >#request.qCustomer.ContactPerson#</option>
                        <cfloop query="qCustomerContacts">
                          <option value="#qCustomerContacts.CustomerContactID#" <cfif request.qCustomer.CRMContactID EQ qCustomerContacts.CustomerContactID> selected </cfif>
                            data-PhoneNo = "#qCustomerContacts.PhoneNo#"
                            data-PhoneNoExt = "#qCustomerContacts.PhoneNoExt#"
                            data-Fax = "#qCustomerContacts.Fax#"
                            data-FaxExt = "#qCustomerContacts.FaxExt#"
                            data-TollFree = "#qCustomerContacts.TollFree#"
                            data-TollfreeExt = "#qCustomerContacts.TollfreeExt#"
                            data-PersonMobileNo = "#qCustomerContacts.PersonMobileNo#"
                            data-MobileNoExt = "#qCustomerContacts.MobileNoExt#"
                            data-Email = "#qCustomerContacts.Email#"
                            >#qCustomerContacts.ContactPerson#</option>
                        </cfloop>
                    </select>
                    <div class="clear"></div>
                    <label>Phone</label>
                    <cfinput onchange="ParseUSNumber(this,'Phone No');" type="text" name="CRMPhoneNo" id="CRMPhoneNo" maxlength="50" value="#request.qCustomer.CRMPhoneNo#" style="width:70px;">
                    <cfinput type="text" name="CRMPhoneNoExt" id="CRMPhoneNoExt" style="width:18px;" value="#request.qCustomer.CRMPhoneNOExt#" maxlength="10">
                    <label style="width: 52px;">Fax</label>
                    <cfinput onchange="ParseUSNumber(this,'Fax');" type="text" name="CRMFax" id="CRMFax" maxlength="50" value="#request.qCustomer.CRMFax#" style="width:70px;">
                    <cfinput type="text" name="CRMFaxExt" id="CRMFaxExt" style="width:18px;" value="#request.qCustomer.CRMFaxExt#" maxlength="10">
                    <div class="clear"></div>
                    <label>Toll Free</label>
                    <cfinput onchange="ParseUSNumber(this,'Toll Free');" type="text" name="CRMTollFree" id="CRMTollFree" maxlength="50" value="#request.qCustomer.CRMTollFree#" style="width:70px;">
                    <cfinput type="text" name="CRMTollFreeExt" id="CRMTollFreeExt" style="width:18px;" value="#request.qCustomer.CRMTollFreeExt#" maxlength="10">
                    <label style="width: 52px;">Cell</label>
                    <cfinput onchange="ParseUSNumber(this,'Cell');" type="text" name="CRMCell" id="CRMCell" maxlength="50" value="#request.qCustomer.CRMCell#" style="width:70px;">
                    <cfinput type="text" name="CRMCellExt" id="CRMCellExt" style="width:18px;" value="#request.qCustomer.CRMCellExt#" maxlength="10">
                    <div class="clear"></div>
                    <label>Email</label>
                    <cfinput type="text" name="CRMEmail" id="CRMEmail" maxlength="250" value="#request.qCustomer.CRMEmail#">
                </fieldset>
            </div>
            <div class="form-con" style="border-left:solid 1px;width: 404px;">
                <fieldset  class="carrierFields">
                    <label>Call Note Type</label>
                    <select name="CRMNoteType" style="width: 100px;">
                        <option value="">Select</option>
                        <cfloop query="request.qCRMNoteTypes">
                          <cfif request.qCRMNoteTypes.CRMType EQ 'Customer'>
                            <option value="#request.qCRMNoteTypes.CRMNoteTypeID#" <cfif request.qCustomer.CRMNoteType EQ request.qCRMNoteTypes.CRMNoteTypeID> selected </cfif>>#request.qCRMNoteTypes.NoteType#(#request.qCRMNoteTypes.Description#)</option>
                          </cfif>
                        </cfloop>
                    </select>
                    <label style="width: 116px;">Repeat how many times?</label>
                    <select name="CRMRepeatInterval" id="CRMRepeatInterval" style="width: 35px;">
                        <cfloop from="0" to="10" index="i">
                          <option value="#i#" <cfif request.qCustomer.CRMRepeatInterval EQ i> selected </cfif>>#i#</option>
                        </cfloop>
                    </select>
                    <div class="clear"></div>
                    <label>Start Date</label>
                    <cfinput class="sm-input datefield" type="text" name="CRMNextCallDate" id="CRMNextCallDate" value="#dateFormat(request.qCustomer.CRMNextCallDate,"mm/dd/yyyy")#" style="width:60px;"  onchange="checkDateFormatAll(this);">
                    <label style="margin-left: 65px;">Days to Next Call</label>
                    <cfinput type="text" name="CRMCallFrequency" id="CRMCallFrequency" value="#request.qCustomer.CRMCallFrequency#" style="width:30px;" onkeyup="if (/\D/g.test(this.value)) this.value = this.value.replace(/\D/g,'')">
                    <div class="clear"></div>
                    <label>Assign to User</label>
                    <select name="CRMUser" id="CRMUser">
                        <option value="">Select</option>
                        <cfloop query="request.qSalesPerson">
                          <option value="#request.qSalesPerson.EmployeeID#" <cfif request.qCustomer.CRMUser EQ request.qSalesPerson.EmployeeID> selected </cfif>>#request.qSalesPerson.Name#</option>
                      </cfloop>
                    </select>
                    <div class="clear"></div>
                    <input  type="submit" name="submit" class="bttn" value="Save" style="width:60px !important;height: 35px;background-size: contain;color: ##599700;margin-left: 219px;" />
                    <input  type="submit" name="submit" class="bttn" value="Save & Exit" style="width:100px !important;height: 35px;background-size: contain;color: ##599700;" />
                </fieldset>
            </div>
            <div class="clear"></div>
        </cfform>
    </div>
    <div class="white-bot"></div>
</div>

<div style="clear:both"></div>
<div class="white-con-area" style="height: 36px;background-color: ##82bbef;margin-top: 2px;">
    <h2 style="color:white;font-weight:bold;text-align: center;">CRM Notes</h2>
</div>
<div class="white-con-area">
    <div class="white-top"></div>
    <div class="white-mid">
        <div class="form-con crm-form-con" style="width:275px;padding-right: 0;padding-left: 0;">
            <fieldset>
                <input  type="submit" name="submit" class="bttn" onclick="openCRMModal()" value="Add Call Note" style="width:100px !important;" />
            </fieldset>
        </div>
    </div>
</div>


<table width="100%" border="0" class="data-table" cellspacing="0" cellpadding="0" style="color:##000000;">
      <thead>
      <tr>

    	<th width="5" align="center" valign="middle" class="head-bg" style="border-left: 1px solid ##5d8cc9;border-top-left-radius: 5px;">&nbsp;</th>
    	<th width="25" align="center" valign="middle" class="head-bg" onclick="sortTableBy('NoteType','dispCRMNotesForm');">Call Note Type</th>
    	<th width="50" align="center" valign="middle" class="head-bg" onclick="sortTableBy('C.CreatedDateTime','dispCRMNotesForm');">Date/Time</th>
        <th width="50" align="center" valign="middle" class="head-bg" onclick="sortTableBy('NoteUser','dispCRMNotesForm');">User</th>
    	<th width="30" align="center" valign="middle" class="head-bg2" style="border-right: 1px solid ##5d8cc9;border-top-right-radius: 5px;">Notes</th>
   
      </tr>
      </thead>
      <tbody>
        <cfif qCRMNotes.recordcount>
         <cfloop query="qCRMNotes">	
    	   

            <cfset pageSize = 30>
            <cfif isdefined("form.pageNo")>
            	<cfset rowNum=(qCRMNotes.currentRow) + ((form.pageNo-1)*pageSize)>
            <cfelse>
            	<cfset rowNum=(qCRMNotes.currentRow)>
            </cfif>
    	<tr <cfif qCRMNotes.currentRow mod 2 eq 0>bgcolor="##FFFFFF"<cfelse>bgcolor="##f7f7f7"</cfif>>
		
			<td class="sky-bg2" valign="middle" style="border-left: 1px solid ##5d8cc9;">#rowNum#</td>
			<td  align="left" valign="middle" nowrap="nowrap" class="normal-td"><a>#qCRMNotes.NoteType#</a></td>
			<td align="left" valign="middle" nowrap="nowrap" class="normal-td"><a>#DateFormat(qCRMNotes.CreatedDateTime,'mm/dd/yyyy')#</a></td>
            <td align="left" valign="middle" nowrap="nowrap" class="normal-td"><a>#qCRMNotes.NoteUser#</a></td>
			<td style="border-right: 1px solid ##5d8cc9;" align="left" valign="middle" nowrap="nowrap" class="normal-td2 CRMNotes"><a>#qCRMNotes.Note#</a></td>
		
    	 </tr>
    	 </cfloop>
         <cfelse>
            <tr><td  colspan="5" align="center">No Records Found.</td></tr>
        </cfif>
    	 </tbody>

    	 <tfoot>
    	 <tr>

    		<td colspan="5" align="left" valign="middle" class="footer-bg" style="border-left: 1px solid ##5d8cc9;border-right: 1px solid ##5d8cc9;border-bottom-left-radius: 5px;;border-bottom-right-radius: 5px;">
    			<div class="up-down">
    				<div class="arrow-top"><a href="javascript: tablePrevPage('dispCRMNotesForm');"><img src="images/arrow-top.gif" alt="" /></a></div>
    				<div class="arrow-bot"><a href="javascript: tableNextPage('dispCRMNotesForm');"><img src="images/arrow-bot.gif" alt="" /></a></div>
    			</div>
    			<div class="gen-left"><a href="javascript: tablePrevPage('dispCRMNotesForm');">Prev </a>-<a href="javascript: tableNextPage('dispCRMNotesForm');"> Next</a></div>
    			<div class="gen-right"><img src="images/loader.gif" alt="" /></div>
    			<div class="clear"></div>
    		</td>

    	 </tr>	
    	 </tfoot>	  
    </table><div class="clear"></div>
    <input  type="submit" name="submit" onclick="openCRMModal()" class="bttn" value="Add Call Note" style="width:100px !important;" />
    <div id="ModalCRM" class="modal"> 
        <div class="modal-content" style="height:310px;">
            <div id="headbakgrnd">
                <span class="close ModalCRMClose">&times;</span>
                <div id="ediheading"> <center>Add CRM Note</center></div>
            </div>
            <div style="margin-top: 10px;">
                <strong>Type</strong>
                <select id="CRMNoteType">
                    <option value="">Select</option>
                    <cfloop query="request.qCRMNoteTypes">
                        <cfif request.qCRMNoteTypes.CRMType EQ 'Customer'>
                            <option value="#request.qCRMNoteTypes.CRMNoteTypeID#">#request.qCRMNoteTypes.NoteType#(#request.qCRMNoteTypes.Description#)</option>
                        </cfif>
                    </cfloop>
                </select>
            </div>
            <div style="margin-top: 10px;">
                <textarea id="CRMNote" style="width: 400px;height: 200px;padding: 5px;"></textarea>
            </div>
            <div style="margin-top: 25px;text-align: right;margin-right: 50px;">
                <input type="button" value="Cancel" class="black-btn ModalCRMClose" style="width:72px !important;height:22px;margin-top: 10px;">          
                <input type="button"  value="Submit" class="black-btn" style="width:72px !important;height:22px;margin-top: 10px;margin-right:-24px;"
                        onclick="saveCRMNote()" >
            </div>
        </div>
    </div>
    <style>
    /* The Modal (background) */
.modal {
  display: none; /* Hidden by default */
  position: fixed; /* Stay in place */
  z-index: 1; /* Sit on top */
  left: 0;
  top: 0;
  width: 100%; /* Full width */
  height: 100%; /* Full height */
  overflow: auto; /* Enable scroll if needed */
  background-color: rgb(0,0,0); /* Fallback color */
  background-color: rgba(0,0,0,0.4); /* Black w/ opacity */
}
/* Modal Content/Box */
.modal-content {
  background-color: ##defaf9;
  margin: 15% auto; /* 15% from the top and centered */
  padding: 20px;
  border: 1px solid ##888;
  width: 30%; /* Could be more or less, depending on screen size */
  height:220px;
}
/* The Close Button */
.close {
  color: ##fff;
  float: right;
  font-size: 28px;
  font-weight: bold;
  margin-right: 7px;
  margin-top: 10px;
}

.close:hover,
.close:focus {
  color: black;
  text-decoration: none;
  cursor: pointer;
} 
##ediheading{
  font-size: 15px;
  font-weight: bold;
  padding-top: 12px;
}
##headbakgrnd{
    background-color: ##82BBEF;
    position: initial;
    height: 38px;
    margin-top: -20px;
    width: 110%;
    margin-left: -20px;
}
</style>
    <script type="text/javascript"> 
        function openCRMModal(){
            $('body').addClass('noscroll');
            $("##CRMNote").val(clock() + ' - #session.UserFullName# > ');
            document.getElementById('ModalCRM').style.display = "block";
            $("##CRMNote").focus();
        }
          
        function clock(){
          var currentDate = new Date();
          var currentDay = currentDate.getDate();
          var currentMonth = currentDate.getMonth() + 1;
          var currentYear = currentDate.getFullYear();
          var hours = currentDate.getHours();
          var minutes = currentDate.getMinutes();

          var currentDate = currentMonth + "/" + currentDay + "/" + currentYear;
          var ampm = hours >= 12 ? 'PM' : 'AM';
          hours = hours % 12;
          hours = hours ? hours : 12; // the hour '0' should be '12'
          minutes = minutes < 10 ? '0'+minutes : minutes;
          var strTime = hours + ':' + minutes + ' ' + ampm;
          var FinalTime = currentDate+' '+strTime;
          return FinalTime
        }
        $(document).ready(function(){
            $('.ModalCRMClose').click(function(){
                document.getElementById('ModalCRM').style.display= "none";
                $('body').removeClass('noscroll');
            });

            $(".only-numeric").bind("keypress", function (e) {
                  var keyCode = e.which ? e.which : e.keyCode
                  if (!(keyCode >= 48 && keyCode <= 57)) {
                    return false;
                  }else{
                  }
              });
        })      
        function saveCRMNote(){

            var CRMNoteType = $('##CRMNoteType').val();
            var CRMNote = $('##CRMNote').val();

            if(CRMNoteType.length == 0){
                alert('Select a notetype.');
                $('##CRMNoteType').focus();
                return false;
            }
            if(CRMNote.length == 0){
                alert('Please enter a note.');
                $('##CRMNote').focus();
                return false;
            }

            var path = urlComponentPath+"customergateway.cfc?method=saveCRMNote";
            $.ajax({
                type: "Post",
                url: path,
                dataType: "json",
                async: false,
                data: {
                    customerid:'#url.customerid#',dsn:'#application.dsn#',CRMNoteType:CRMNoteType,CRMNote:CRMNote,user:'#session.adminusername#'
                },
                success: function(data){
                    location.href = "index.cfm?event=CRMNotes&customerid=#url.CustomerID#&#session.URLToken#&msg="+data.MSG;
                }
            });  
        }   
    </script>
    </cfoutput>
    