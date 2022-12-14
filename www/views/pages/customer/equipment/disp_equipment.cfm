<cfparam name="message" default="">
<cfparam name="url.sortorder" default="desc">
<cfparam name="sortby"  default="">
<cfsilent>	
<cfif isdefined("form.searchText") and len(searchText)>	
	<cfinvoke component="#variables.objequipmentGateway#" method="getSearchedEquipment" searchText="#form.searchText#" returnvariable="request.qEquipments" />
<cfelse>
	<cfif isdefined("url.equipmentid") and len(url.equipmentid) gt 1>	
		<cfinvoke component="#variables.objequipmentGateway#" method="deleteEquipments" EquipmentID="#url.equipmentid#" returnvariable="message" />	
		<cfinvoke component="#variables.objequipmentGateway#" method="getAllEquipments" returnvariable="request.qEquipments" />
	</cfif>
</cfif>
</cfsilent>
<cfoutput>
<h1>All Equipment</h1>
<cfif isdefined("message") and len(message)>
<div class="msg-area">#message#</div>
</cfif>
<cfif isDefined("url.sortorder") and url.sortorder eq 'desc'>
          <cfset sortorder="asc">
 <cfelse>
          <cfset sortorder="desc">
</cfif>
<cfif isDefined("url.sortby")>
          <cfinvoke component="#variables.objequipmentGateway#" method="getAllEquipments" sortorder="#sortorder#" sortby="#sortby#"  returnvariable="request.qEquipments" />
</cfif> 
<div class="search-panel">
<div class="form-search">
<cfform action="index.cfm?event=equipment&#session.URLToken#" method="post" preserveData="yes">
	<fieldset>
	<cfinput name="searchText" type="text" required="yes" message="Please enter search text"  />
	<input name="" type="submit" class="s-bttn" value="Search" style="width:56px;" />
	<div class="clear"></div>
	</fieldset>
</cfform>			
</div>
<div class="addbutton"><a href="index.cfm?event=addequipment&#session.URLToken#">Add New</a></div></div>  
    <table width="100%" border="0" cellspacing="0" cellpadding="0" class="data-table">
      <thead>
      <tr>
    	<th width="5" align="left" valign="top"><img src="images/top-left.gif" alt="" width="5" height="23" /></th>
    	<th align="center" valign="middle" class="head-bg">&nbsp;</th>
    	<th align="center" valign="middle" class="head-bg"  onclick="document.location.href='index.cfm?event=equipment&sortorder=#sortorder#&sortby=EquipmentCode&#session.URLToken#'">Equipment Code</th>
    	<th align="center" valign="middle" class="head-bg"  onclick="document.location.href='index.cfm?event=equipment&sortorder=#sortorder#&sortby=EquipmentName&#session.URLToken#'">Name</th>
    	<th align="center" width="10%" valign="middle" class="head-bg"  onclick="document.location.href='index.cfm?event=equipment&sortorder=#sortorder#&sortby=EquipmentName&#session.URLToken#'">Post Everywhere</th>	
    	<th align="center" valign="middle" class="head-bg"  onclick="document.location.href='index.cfm?event=equipment&sortorder=#sortorder#&sortby=EquipmentName&#session.URLToken#'">Length</th>				
    	<th align="center" valign="middle" class="head-bg2" onclick="document.location.href='index.cfm?event=equipment&sortorder=#sortorder#&sortby=IsActive&#session.URLToken#'">Status</th>
    	<th width="5" align="right" valign="top"><img src="images/top-right.gif" alt="" width="5" height="23" /></th>
      </tr>
      </thead>
      <tbody>
    	<cfloop query="request.qEquipments">	
    	<tr <cfif request.qEquipments.currentRow mod 2 eq 0>bgcolor="##FFFFFF"<cfelse>bgcolor="##f7f7f7"</cfif>>
    		<td height="20" class="sky-bg">&nbsp;</td>
    		<td class="sky-bg2" valign="middle" onclick="document.location.href='index.cfm?event=addequipment&equipmentid=#request.qEquipments.EquipmentID#&#session.URLToken#'" align="center">#request.qEquipments.currentRow#</td>
    		<td class="normal-td" valign="middle" onclick="document.location.href='index.cfm?event=addequipment&equipmentid=#request.qEquipments.EquipmentID#&#session.URLToken#'"  align="left"><a title="#request.qEquipments.EquipmentCode# #request.qEquipments.EquipmentName#" href="index.cfm?event=addequipment&equipmentid=#request.qEquipments.EquipmentID#&#session.URLToken#">#request.qEquipments.EquipmentCode#</a></td>
    		<td class="normal-td" valign="middle" onclick="document.location.href='index.cfm?event=addequipment&equipmentid=#request.qEquipments.EquipmentID#&#session.URLToken#'" align="left"><a title="#request.qEquipments.EquipmentCode# #request.qEquipments.EquipmentName#" href="index.cfm?event=addequipment&equipmentid=#request.qEquipments.EquipmentID#&#session.URLToken#">#request.qEquipments.EquipmentName#</a></td>
    		<td class="normal-td" valign="middle" onclick="document.location.href='index.cfm?event=addequipment&equipmentid=#request.qEquipments.EquipmentID#&#session.URLToken#'" align="left"><a title="#request.qEquipments.EquipmentCode# #request.qEquipments.EquipmentName#" href="index.cfm?event=addequipment&equipmentid=#request.qEquipments.EquipmentID#&#session.URLToken#">
			<cfif request.qEquipments.PEPCODE eq true><input type="checkbox" name="chk" checked > <cfelse><input type="checkbox" name="chk"  ></cfif>
			</a></td>
    		<td class="normal-td" valign="middle" onclick="document.location.href='index.cfm?event=addequipment&equipmentid=#request.qEquipments.EquipmentID#&#session.URLToken#'" align="left"><a title="#request.qEquipments.EquipmentCode# #request.qEquipments.EquipmentName#" href="index.cfm?event=addequipment&equipmentid=#request.qEquipments.EquipmentID#&#session.URLToken#">#request.qEquipments.length#</a></td>
    		<td class="normal-td2" valign="middle" onclick="document.location.href='index.cfm?event=addequipment&equipmentid=#request.qEquipments.EquipmentID#&#session.URLToken#'"  align="center"><a href="index.cfm?event=addequipment&equipmentid=#request.qEquipments.EquipmentID#&#session.URLToken#"><cfif request.qEquipments.IsActive eq 1>Active<cfelse>Inactive</cfif></a></td>
    		<td class="normal-td3">&nbsp;</td>
    	 </tr>
    	 </cfloop>
    	 </tbody>
    	 <tfoot>
    	 <tr>
    		<td width="5" align="left" valign="top"><img src="images/left-bot.gif" alt="" width="5" height="23" /></td>
    		<td colspan="4" align="left" valign="middle" class="footer-bg">
    			<div class="up-down">
    				<div class="arrow-top"><a href="##"><img src="images/arrow-top.gif" alt="" /></a></div>
    				<div class="arrow-bot"><a href="##"><img src="images/arrow-bot.gif" alt="" /></a></div>
    			</div>
    			<div class="gen-left"><a href="##">View More</a></div>
    			<div class="gen-right"><img src="images/loader.gif" alt="" /></div>
    			<div class="clear"></div>
    		</td><td width="5" align="right" valign="top"  class="footer-bg">&nbsp;</td><td  class="footer-bg" width="5" align="right" valign="top">&nbsp;</td>
    		<td width="5" align="right" valign="top"><img src="images/right-bot.gif" alt="" width="5" height="23" /></td>
    	 </tr>	
    	 </tfoot>	  
    </table>
    </cfoutput>
    