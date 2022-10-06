
<cfoutput>
		<cfimport taglib="../../../plugins/customtags/mytag/" prefix="myoffices" >	
		<!---Init Default Value------->
		<cfparam name="EquipmentCode" default="">
		<cfparam name="ITSCode" default="">
		<cfparam name="TranscoreCode" default="">
		<cfparam name="PosteverywhereCode" default="">
		<cfparam name="loadboardcode" default="">
		<cfparam name="Length" default="">
		<cfparam name="Width" default="">
		<cfparam name="PEPcode" default="0">
		<cfparam name="EquipmentName" default="">
		<cfparam name="Status" default="">
		<cfparam name="url.editid" default="0">
		<cfparam name="url.equipmentid" default="0">
		<cfparam name="unitNumber" default="">
		<cfparam name="vin" default="">
		<cfparam name="licensePlate" default="">
		<cfparam name="tagexpirationdate" default="">
		<cfparam name="annualDueDate" default="">
		<cfparam name="Driver" default="">
		<cfparam name="driverowned" default="0">
		<cfparam name="Notes" default="">
		<cfparam name="Odometer" default="">
		<cfparam name="url.sortorder" default="desc">
		<cfparam name="sortby"  default="">
		<cfparam name="tempEquipmentId"  default="">
		<cfparam name="variables.equipmentdisabledStatus" default="false"> 
		<cfparam name="temperature"  default="">
		<cfparam name="temperaturescale"  default="">
		<cfparam name="IFTA" default="0">
		<cfparam name="IMEI" default="">
		<cfparam name="EquipmentType" default="">
		<cfparam name="TruckTrailerOption" default="">
		<cfif structKeyExists(url,"IsCarrier")>
			<cfset isCarrier = url.IsCarrier>
		</cfif>
		<cfset Secret = application.dsn>
		<cfset TheKey = 'NAMASKARAM'>
		<cfset Encrypted = Encrypt(Secret, TheKey)>
		<cfset dsn = URLEncodedFormat(ToBase64(Encrypted))>
		<cfif structkeyexists(url,"equipmentid")and structkeyexists(url,"equipmentMaintId") and structkeyexists(url,"deleteMaintItem")>
			<cfif len(trim(url.equipmentid)) gt 1 and len(trim(url.equipmentMaintId)) and url.deleteMaintItem eq 1>
				<cfinvoke component="#variables.objequipmentGateway#" method="deleteEquipmentsMaint" equipmentID="#url.equipmentid#" equipmentMaintID="#url.equipmentMaintId#" returnvariable="message">
			</cfif>
		</cfif>
		<cfinvoke component="#variables.objloadGateway#" method="getLoadSystemSetupOptions" returnvariable="request.qSystemSetupOptions1" />
		<cfinvoke component="#variables.objequipmentGateway#" method="getMaintenanceInformation" returnvariable="request.qGetMaintenanceInformation" />
		<cfif isdefined("url.equipmentid") and len(trim(url.equipmentid)) gt 1>
			<cfinvoke component="#variables.objequipmentGateway#" method="getAllEquipments" EquipmentID="#url.equipmentid#" returnvariable="request.qEquipments" />
			<cfinvoke component="#variables.objequipmentGateway#" method="getMaintenanceInformationForSelect" EquipmentID="#url.equipmentid#" returnvariable="request.qGetMaintenanceselect" />
			<cfif request.qEquipments.recordcount>
				<cfset EquipmentCode=request.qEquipments.EquipmentCode>
				<cfset EquipmentName=request.qEquipments.EquipmentName>
				<cfset PEPcode=request.qEquipments.PEPcode>
				<cfset Width=request.qEquipments.Width>
				<cfset Status=request.qEquipments.IsActive>
				<cfset editid=request.qEquipments.EquipmentID>
				<cfset unitNumber=request.qEquipments.unitNumber>
				<cfset vin=request.qEquipments.vin>
				<cfset licensePlate=request.qEquipments.licensePlate>
				<cfset tagexpirationdate=request.qEquipments.tagexpirationdate>
				<cfset annualDueDate=request.qEquipments.annualDueDate>
				<cfset Driver=request.qEquipments.Driver>
				<cfset driverowned=request.qEquipments.driverowned>
				<cfset Notes=request.qEquipments.Notes>	
				<cfset Odometer = request.qEquipments.Odometer>	
				<cfset Length=request.qEquipments.Length>
				<cfif request.qSystemSetupOptions1.freightBroker>
					<cfset ITSCode=request.qEquipments.ITSCode>
					<cfset TranscoreCode=request.qEquipments.TranscoreCode>
					<cfset PosteverywhereCode=request.qEquipments.PosteverywhereCode>
					<cfset LoadboardCode=request.qEquipments.LoadboardCode>	
				</cfif>
				<cfset temperature=request.qEquipments.temperature>	
				<cfset temperaturescale=request.qEquipments.temperaturescale>	
				<cfset IFTA=request.qEquipments.IFTA>
				<cfset IMEI=request.qEquipments.IMEI>
				<cfset EquipmentType=request.qEquipments.EquipmentType>
				<cfset TruckTrailerOption=request.qEquipments.TruckTrailerOption>
				<script>			
					$(document).ready(function(){

							//when the page loads for equipment edit ajax call for inserting tab id of the page details
						var path = urlComponentPath+"equipmentgateway.cfc?method=insertTabDetails";
						$.ajax({
			            type: "Post",
			            url: path,
			            dataType: "json",
			            async: false,
						data: {
							tabID:tabID,equipmentid:'#request.qEquipments.EquipmentId#',userid:'#session.empid#',sessionid:'#session.sessionid#',dsn:'#application.dsn#'
						},
			            success: function(data){
			            console.log(data);
			            }
			          });
					});
				</script>
				<!---Object to get corresponding user edited the equipment--->
				<cfinvoke component="#variables.objEquipmentGateway#" method="getUserEditingDetails" equipmentid="#request.qEquipments.EquipmentID#" returnvariable="request.qryEquipmentEditingDetails"/>

				<cfif not len(trim(request.qryEquipmentEditingDetails.InUseBy))>
					<!---Object to update corresponding user edited the equipment--->
					<cfinvoke component="#variables.objEquipmentGateway#" method="updateEditingUserId" equipmentid="#request.qEquipments.EquipmentID#" userid="#session.empid#" status="false"/>
					<cfset session.currentEquipmentId = #request.qEquipments.EquipmentID#/>
				<cfelse>

						<!---Object to get corresponding Previously edited---->
					<cfinvoke component="#variables.objAgentGateway#" method="getEditingUserName" returnvariable="request.qryGetEditingUserName" employeID="#request.qryEquipmentEditingDetails.inuseby#" />
						<!---Condition to check current employee and previous editing employee are not same--->
					<cfif session.empid neq request.qryEquipmentEditingDetails.inuseby>
						<cfif request.qryGetEditingUserName.recordcount>
							<cfset variables.equipmentdisabledStatus=true>
								<div class="msg-area" style="margin-left:10px;margin-bottom:10px">
									<span style="color:##d21f1f">This equipment locked because it is currently being edited by #request.qryGetEditingUserName.Name# #dateformat(request.qryEquipmentEditingDetails.inuseon,"mm/dd/yy hh:mm:ss")#.
										An Administrator can manually override this lock by clicking the unlock button.
									</span>
								</div>
						</cfif>
					</cfif>
				</cfif>				
			</cfif>
		</cfif>
		<cfquery name="getDrivers" datasource="#application.DSN#">
			select DISTINCT carrierid, CarrierName from carriers
			WHERE CompanyID = <cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar">
		</cfquery>
	<cfif structkeyexists(url,"equipmentid") and len(trim(url.equipmentid)) gt 1>
		<cfinvoke component="#variables.objequipmentGateway#" method="getEquipmentMaintTable" editid="#editid#" returnvariable="request.qEquipmentMaint" />
		<div class="search-panel">
			<div class="delbutton">
				<cfif PEPcode neq 1 and equipmentdisabledStatus neq true>
					<a href="index.cfm?event=equipment&equipmentid=#editid#&#session.URLToken#&IsCarrier=#isCarrier#" onclick="return confirm('Are you sure to delete it ?');">
					Delete 
					</a>
				</cfif>
			</div>
		</div>	
		<div class="white-con-area" style="height: 36px;background-color: ##82bbef;">
			<cfif equipmentdisabledStatus neq true>
			<div style="float: left; width: 20%;" id="divUploadedFiles">
				&nbsp;<a style="display:block;font-size: 13px;padding-left: 10px;color:white;margin-top:-5px;" href="##" onclick="popitupEquip('../fileupload/multipleFileupload/MultipleUpload.cfm?id=#editid#&attachTo=57&user=#session.adminusername#&dsn=#dsn#&attachtype=Equipment&CompanyID=#session.CompanyID#')">
				<img style="vertical-align:bottom;" src="images/attachment.png">
				View/Attach Files</a>
			</div>
		</cfif>
			<div style="float: left;"><h2 style="color:white;font-weight:bold;margin-left: 12px;">Edit Equipment <span style="padding-left:40px;">#Ucase(EquipmentName)#</span></h2></div>
		</div>
		<div style="clear:left;"></div>
	<cfelse>
		<cfset tempEquipmentId = #createUUID()#>
		<div class="white-con-area" style="height: 36px;background-color: ##82bbef;">
		<div style="float: left; width: 20%;" id="divUploadedFiles">
			&nbsp;<a style="display:block;font-size: 13px;padding-left: 10px;color:white;margin-top:-5px;" href="##" onclick="popitupEquip('../fileupload/multipleFileupload/MultipleUpload.cfm?id=#tempEquipmentId#&attachTo=57&user=#session.adminusername#&newFlag=1&dsn=#dsn#&attachtype=Equipment')">
			<img style="vertical-align:bottom;" src="images/attachment.png">
			Attach Files</a>
		</div>
		<div style="float: left;"><h2 style="color:white;font-weight:bold;margin-left: 12px;">Add New Equipment</h2></div>
	</div>
	<div style="clear:left;"></div>
	</cfif>
	<cfif structkeyexists(url,"sortorder") and url.sortorder eq 'desc'>
		<cfset sortorder="asc">
	 <cfelse>
		<cfset sortorder="desc">
	</cfif>
	<cfif structkeyexists(url,"sortby")>
		<cfinvoke component="#variables.objequipmentGateway#" method="getEquipmentMaintTable" editid="#editid#" sortorder="#sortorder#" sortby="#sortby#"  returnvariable="request.qEquipmentMaint" />
	</cfif> 
	<div class="white-con-area">
		<div class="white-top"></div>
		<div class="white-mid">
		<cfform name="frmEquipment" action="index.cfm?event=addequipment:process&editid=#editid#&#session.URLToken#&IsCarrier=#isCarrier#" method="post">
			<cfinput type="hidden" name="editid" value="#editid#">
			<input name="appDsn" id="appDsn" type="hidden" value="#application.dsn#">
			<input type="hidden" name="tabid" id="tabid" value="">
			<input type="hidden" name="equipmentdisabledStatus" id="equipmentdisabledStatus" value="#variables.equipmentdisabledstatus#">
			<input type="hidden" name="isSaveEvent" id="isSaveEvent" value="false"/>
			<cfif structKeyExists(url, "equipDriver")>
				<input type="hidden" name="equipDriver" id="equipDriver" value="1"/>
			</cfif>
			<div class="form-con">
				<fieldset>    
					<label><strong>Equipment Code*</strong></label>
					<cfif PEPcode neq 1>
						<cfinput type="text" name="EquipmentCode" value="#EquipmentCode#" size="25" required="yes" message="Please  enter the equipment code" maxlength="100" style="width: 110px;">
						<label style="width: 37px;"><strong>Type*</strong></label>
						<select name="EquipmentType" id="EquipmentType" style="width: 60px;" onchange="trailerTruckOption(0)">
							<option value="">Select</option>
						  	<option value="Truck" <cfif EquipmentType eq 'Truck'>selected="selected" </cfif>>Truck</option>
						  	<option value="Trailer" <cfif EquipmentType eq 'Trailer'>selected="selected" </cfif>>Trailer</option>
						  	<option value="Other" <cfif EquipmentType eq 'Other'>selected="selected" </cfif>>Other</option>
						</select>
						<div class="clear"></div>  
						<label><strong>Description*</strong></label>
						<cfinput type="text" name="EquipmentName" value="#EquipmentName#" size="25" required="yes" message="Please  enter the equipment name" maxlength="100" style="width:225px;">
					<cfelse>
						<cfinput type="text" name="EquipmentCode" readonly  value="#EquipmentCode#" size="25" required="yes" message="Please  enter the equipment code" style="width: 110px;">
						<label style="width: 37px;"><strong>Type*</strong></label>
						<select name="EquipmentType" id="EquipmentType" style="width: 60px;" onchange="trailerTruckOption()">
							<option value="">Select</option>
						  	<option value="Truck" <cfif EquipmentType eq 'Truck'>selected="selected" </cfif>>Truck</option>
						  	<option value="Trailer" <cfif EquipmentType eq 'Trailer'>selected="selected" </cfif>>Trailer</option>
						  	<option value="Other" <cfif EquipmentType eq 'Other'>selected="selected" </cfif>>Other</option>
						</select>
						<div class="clear"></div>  
						<label><strong>Description*</strong></label>
						<cfinput type="text" name="EquipmentName"   readonly  value="#EquipmentName#" size="25" required="yes" message="Please  enter the description" style="width:225px;">
					</cfif>
					<div class="clear"></div>
					<label><strong>Length</strong></label>
					<cfinput type="text" name="Length" value="#Length#" size="4" maxlength="4" validate="integer"  style="width:40px" message="Please  enter the valid Length">
					<label style="width:84px;"> <strong>Width</strong> </label>
					<cfinput type="text" name="Width" value="#Width#" size="4" maxlength="4" validate="integer" style="width:40px" message="Please  enter the valid Width">
					<div class="clear"></div>
					<cfif (request.qSystemSetupOptions1.freightBroker eq 2 AND url.isCarrier eq 0) OR (request.qSystemSetupOptions1.freightBroker eq 0)>
						<label><strong>Equipment##</strong></label>
					<cfelse>
						<label><strong>Unit Number</strong></label>
					</cfif>		
					<cfinput type="text" name="unitNumber" value="#unitNumber#" size="25" message="Please enter the unit number" maxlength="50">
					<div class="clear"></div>
					
					<label><strong>VIN</strong></label>
					<cfinput type="text" name="vin" value="#vin#" size="25" message="Please enter the vin" maxlength="50">
					<div class="clear"></div>
					
					<label><strong>License Plate##</strong></label>
					<cfinput type="text" name="licensePlate" value="#licensePlate#" size="25" message="Please enter the license plate" maxlength="50">
					<div class="clear"></div>
					
					<label><strong>Tag Expiration Date</strong></label>
					<input class="" name="tagexpirationdate" id="tagexpirationdate" value="#dateformat(tagexpirationdate,'mm/dd/yyyy')#" type="datefield" style="width:75px;" validate="date" readOnly />
					<div class="clear"></div>
					
					<label><strong>Annual Due Date</strong></label>
					<input class="" name="annualDueDate" id="annualDueDate" value="#dateformat(annualDueDate,'mm/dd/yyyy')#" type="datefield" style="width:75px;" validate="date" readOnly />
					<div class="clear"></div>
					
					<label><strong>Driver</strong></label>
					<select name="Driver">
						<option value="">Select</option>
						<cfloop query="getDrivers">
							<option value="#getDrivers.carriername#" <cfif Driver EQ getDrivers.carriername
							or (structKeyExists(url, "equipDriver") AND url.equipDriver EQ getDrivers.carriername)
							> selected </cfif> >#getDrivers.carriername#</option>
						</cfloop>
					</select>
					<div class="clear"></div>
					<label><strong>Driver Owned?</strong></label>
					<input type="checkbox" name="driverowned" id="driverowned" value="1" <cfif driverowned EQ 1> checked="checked" </cfif>  style="width:20px;">

					
					<label style="width: 75px;"><strong>Active*</strong></label>
					<select name="Status" style="width: 80px;">
					  <option value="1" <cfif Status eq '1'>selected="selected" </cfif>>Active</option>
					  <option value="0" <cfif Status eq '0'>selected="selected" </cfif>>InActive</option>
					</select>
					<div class="clear"></div>
					<label for="Odometer"><strong>Odometer</strong></label>
					<input type="text" name="Odometer" id="Odometer" value="#Odometer#">
					<input type="hidden" name="tempEquipmentId" id="tempEquipmentId" value="#tempEquipmentId#">
					<div class="clear"></div>
					<div class="clear"></div>
					<label for="Trailer"><strong id="labelTrOption">
						Truck/Trailer:
					</strong></label>
					<select name="TruckTrailerOption" id="TruckTrailerOption">
					</select>
				</fieldset>
			</div>
			<div class="form-con">
				<fieldset>
					<label style="width: 20px;"><strong>IMEI</strong></label>
					<cfinput type="text" name="IMEI" value="#IMEI#" size="25" maxlength="100" style="width: 280px;">
					<div class="clear"></div>
					<label style="text-align:left;"><strong>Notes</strong></label>
					<div class="clear"></div>
					<textarea name="notes" id="notes" <cfif request.qSystemSetupOptions1.freightBroker> style="width:300px;"<cfelse> style="width: 311px;margin: 0px 0px 8px;height: 215px;" </cfif>  >#notes#</textarea>
					<div class="clear"></div>

					<label style="text-align: left;width: 63px;"><strong>Temperature</strong></label>
					<cfinput type="text" name="temperature" value="#temperature#" size="4" maxlength="5" validate="float"  style="width:40px" message="Please  enter the valid Temperature">
					<label style="width: 5px;margin-top: -5px;margin-left: -5px;"><sup>o</sup></label>
					<select name="temperaturescale" style="width:35px;">
						<option value="C" <cfif temperaturescale EQ "C"> selected </cfif> >C</option>
						<option value="F" <cfif temperaturescale EQ "F"> selected </cfif> >F</option>
					</select>
					<div class="clear"></div>
					<cfif listFind("0,2", request.qSystemSetupOptions1.freightBroker)>
						<label style="text-align: left;width: 72px;"><strong>IFTA Inlcude?</strong></label>
							<input type="checkbox" name="IFTA" id="IFTA" value="1" <cfif IFTA EQ 1> checked="checked" </cfif>  style="width:20px;">
						<div class="clear"></div>
					</cfif>
					<div style="padding-left:150px;">
					<cfif equipmentdisabledstatus neq true>	
						<input  type="submit" name="submit" onclick="return validateEquipment(frmEquipment,'#application.dsn#');" class="bttn" value="Save Equipment" style="width:112px;"     />
						<cfelse>
							<cfif structKeyExists(session, 'rightsList') and listContains( session.rightsList, 'UnlockEquipment', ',')>
								
								<input id="Unlock" name="unlock" type="button" class="green-btnUnlock" onClick="removeEquipmentEditAccess('#request.qEquipments.equipmentid#');" value="Unlock"  >

							</cfif>
						</cfif>
						<input  type="button" onclick="document.location.href='index.cfm?event=equipment&#session.URLToken#&IsCarrier=#isCarrier#'"  name="back" class="bttn" value="Back" style="width:70px;" /></div>
					<div class="clear"></div>  		
				</fieldset>
			</div>
		</cfform>
		<div class="clear"></div>
		<cfif structkeyexists(url,"equipmentid") and len(url.equipmentid) gt 1>
		<p id="footer" style="padding-left:10px;font-family:Verdana, Geneva, sans-serif; font-style:italic bold; text-transform:uppercase;font-family:Verdana, Geneva, sans-serif; font-style:italic; text-transform:uppercase;width:80%;">Last Updated:<cfif isDefined("request.qEquipments")>&nbsp;&nbsp;&nbsp; #request.qEquipments.LastModifiedDateTime#&nbsp;&nbsp;&nbsp;#request.qEquipments.LastModifiedBy#</cfif></p>
		</cfif> 
	</div>
	<div class="white-bot"></div>
	<cfif structkeyexists(url,"equipmentid") and len(url.equipmentid) gt 1>
		<cfif equipmentdisabledstatus neq true>
		<div class="addbutton"  style="cursor: pointer;padding-bottom: 8px;"><a href="index.cfm?event=addNewMaintenance&equipmentid=#url.equipmentid#&#session.URLToken#&IsCarrier=#isCarrier#">Add Maintenance</a></div>
		</cfif>
		<cfif request.qEquipmentMaint.recordcount>
			<div class="white-con-area" style="height: 36px;background-color: ##82bbef;margin-bottom: 14px; margin-top: 33px;">
				<div style="float: left; width: 20%;" id="divUploadedFiles">
				</div>
				<div style="float: left; width: 46%;"><h2 style="color:white;font-weight:bold;margin-left: 12px;">Equipment Maintenance List</h2></div>
			</div>
			<div style="clear:left;"></div>
		</cfif>	
		<cfif isdefined("message") and len(message)>
			<div class="msg-area" style="margin-top:35px;margin-bottom:11px;">#message#</div>
		</cfif>
		</div>
		<cfif request.qEquipmentMaint.recordcount>
			<table width="85%" border="0" cellspacing="0" cellpadding="0" class="data-table" id="test">
				<thead>
					<tr>
						<th width="5" align="left" valign="top"><img src="images/top-left.gif" alt="" width="5" height="23" /></th>
						<th align="center" valign="middle" class="head-bg">&nbsp;</th>
						<th align="center" valign="middle" class="head-bg" onclick="document.location.href='index.cfm?event=addDriverEquipment&equipmentid=#url.equipmentid#&sortorder=#sortorder#&sortby=Description&#session.URLToken#'">Description</th>
						<th align="center" valign="middle" class="head-bg" onclick="document.location.href='index.cfm?event=addDriverEquipment&equipmentid=#url.equipmentid#&sortorder=#sortorder#&sortby=MilesInterval&#session.URLToken#'">Miles Interval</th>
						<th align="center" valign="middle" class="head-bg" onclick="document.location.href='index.cfm?event=addDriverEquipment&equipmentid=#url.equipmentid#&sortorder=#sortorder#&sortby=NextOdometer&#session.URLToken#'">Next Odometer</th>		
						<th align="center" valign="middle" class="head-bg" onclick="document.location.href='index.cfm?event=addDriverEquipment&equipmentid=#url.equipmentid#&sortorder=#sortorder#&sortby=DateInterval&#session.URLToken#'">Date Interval</th>
						<th align="center" valign="middle" class="head-bg" onclick="document.location.href='index.cfm?event=addDriverEquipment&equipmentid=#url.equipmentid#&sortorder=#sortorder#&sortby=NextDate&#session.URLToken#'">NextDate</th>
						<th align="center" valign="middle" class="head-bg" onclick="document.location.href='index.cfm?event=addDriverEquipment&equipmentid=#url.equipmentid#&sortorder=#sortorder#&sortby=Notes&#session.URLToken#'">Notes</th>
						<th width="100px" align="center" valign="middle" class="head-bg2" >Transactions</th>
						<th  align="right" valign="top"><img src="images/top-right.gif" alt="" width="5" height="23" /></th>
					</tr>
				</thead>
				<tbody>
					<cfloop query="request.qEquipmentMaint">	
						<tr <cfif request.qEquipmentMaint.currentRow mod 2 eq 0>bgcolor="##FFFFFF"<cfelse>bgcolor="##f7f7f7"</cfif>>
							<td height="20" class="sky-bg">&nbsp;</td>
							<td class="sky-bg2" valign="middle" align="center">#request.qEquipmentMaint.currentRow#</td>
							<td class="normal-td" valign="middle" align="left" <cfif equipmentdisabledstatus neq true> onclick="document.location.href='index.cfm?event=addNewMaintenance&equipmentid=#request.qEquipments.EquipmentID#&equipmentMaintId=#request.qEquipmentMaint.EquipMainID#&#session.URLToken#&IsCarrier=#isCarrier#'" </cfif> >
								<cfif equipmentdisabledstatus neq true>
								<a title="#request.qEquipmentMaint.Description#" href="index.cfm?event=addNewMaintenance&equipmentid=#request.qEquipments.EquipmentID#&equipmentMaintId=#request.qEquipmentMaint.EquipMainID#&#session.URLToken#&IsCarrier=#isCarrier#">#request.qEquipmentMaint.Description#</a>
								<cfelse>
									#request.qEquipmentMaint.Description#
								</cfif>
							</td>
							<td class="normal-td" valign="middle" align="center" <cfif equipmentdisabledstatus neq true> onclick="document.location.href='index.cfm?event=addNewMaintenance&equipmentid=#request.qEquipments.EquipmentID#&equipmentMaintId=#request.qEquipmentMaint.EquipMainID#&#session.URLToken#&IsCarrier=#isCarrier#'" 
							  </cfif> >
							  <cfif equipmentdisabledstatus neq true>
							  <a title="#request.qEquipmentMaint.Description#" href="index.cfm?event=addNewMaintenance&equipmentid=#request.qEquipments.EquipmentID#&equipmentMaintId=#request.qEquipmentMaint.EquipMainID#&#session.URLToken#&IsCarrier=#isCarrier#">#request.qEquipmentMaint.MilesInterval#</a>
							<cfelse>
								#request.qEquipmentMaint.MilesInterval#
							</cfif>
							</td>
							<td class="normal-td" valign="middle" align="center"  <cfif equipmentdisabledstatus neq true> onclick="document.location.href='index.cfm?event=addNewMaintenance&equipmentid=#request.qEquipments.EquipmentID#&equipmentMaintId=#request.qEquipmentMaint.EquipMainID#&#session.URLToken#&IsCarrier=#isCarrier#'" </cfif> >
								<cfif equipmentdisabledstatus neq true>
								<a title="#request.qEquipmentMaint.Description#" href="index.cfm?event=addNewMaintenance&equipmentid=#request.qEquipments.EquipmentID#&equipmentMaintId=#request.qEquipmentMaint.EquipMainID#&#session.URLToken#&IsCarrier=#isCarrier#">#request.qEquipmentMaint.NextOdometer#</a>
							<cfelse>
								#request.qEquipmentMaint.NextOdometer#
								</cfif>
							</td>
							<td class="normal-td" valign="middle" align="center" <cfif equipmentdisabledstatus neq true>  onclick="document.location.href='index.cfm?event=addNewMaintenance&equipmentid=#request.qEquipments.EquipmentID#&equipmentMaintId=#request.qEquipmentMaint.EquipMainID#&#session.URLToken#&IsCarrier=#isCarrier#'" 
							</cfif>>
							<cfif equipmentdisabledstatus neq true>
							<a title="#request.qEquipmentMaint.Description#" href="index.cfm?event=addNewMaintenance&equipmentid=#request.qEquipments.EquipmentID#&equipmentMaintId=#request.qEquipmentMaint.EquipMainID#&#session.URLToken#&IsCarrier=#isCarrier#"><cfif len(trim(request.qEquipmentMaint.DateInterval))><cfif request.qEquipmentMaint.DateInterval eq 1>#request.qEquipmentMaint.DateInterval#-Month<cfelseif request.qEquipmentMaint.DateInterval eq 0><cfelse>#request.qEquipmentMaint.DateInterval#-Months</cfif><cfelse></cfif></a>
							<cfelse>
								<cfif len(trim(request.qEquipmentMaint.DateInterval))><cfif request.qEquipmentMaint.DateInterval eq 1>#request.qEquipmentMaint.DateInterval#-Month<cfelseif request.qEquipmentMaint.DateInterval eq 0><cfelse>#request.qEquipmentMaint.DateInterval#-Months</cfif><cfelse></cfif>
							</cfif>
							</td>
							<td class="normal-td" valign="middle" align="center"  <cfif equipmentdisabledstatus neq true>  onclick="document.location.href='index.cfm?event=addNewMaintenance&equipmentid=#request.qEquipments.EquipmentID#&equipmentMaintId=#request.qEquipmentMaint.EquipMainID#&#session.URLToken#&IsCarrier=#isCarrier#'" </cfif>>
								<cfif equipmentdisabledstatus neq true>  
								<a title="#request.qEquipmentMaint.Description#" href="index.cfm?event=addNewMaintenance&equipmentid=#request.qEquipments.EquipmentID#&equipmentMaintId=#request.qEquipmentMaint.EquipMainID#&#session.URLToken#&IsCarrier=#isCarrier#">#DateFormat(request.qEquipmentMaint.NextDate, "mmm-dd-yyyy")#</a>
								<cfelse>
								#DateFormat(request.qEquipmentMaint.NextDate, "mmm-dd-yyyy")#
								</cfif>
							</td>
							<td width="150px"  class="normal-td" valign="middle" align="left" <cfif equipmentdisabledstatus neq true>  onclick="document.location.href='index.cfm?event=addNewMaintenance&equipmentid=#request.qEquipments.EquipmentID#&equipmentMaintId=#request.qEquipmentMaint.EquipMainID#&#session.URLToken#&IsCarrier=#isCarrier#'" </cfif> >
								<cfif equipmentdisabledstatus neq true>
								<a title="#request.qEquipmentMaint.Description#" href="index.cfm?event=addNewMaintenance&equipmentid=#request.qEquipments.EquipmentID#&equipmentMaintId=#request.qEquipmentMaint.EquipMainID#&#session.URLToken#&IsCarrier=#isCarrier#">
							<cfif len(trim(request.qEquipmentMaint.Notes)) gt 30>
								#left(request.qEquipmentMaint.Notes,15)#...#right(request.qEquipmentMaint.Notes,14)#
							<cfelse>
								#request.qEquipmentMaint.Notes#
							</cfif>
							</a>
							<cfelse>
								<cfif len(trim(request.qEquipmentMaint.Notes)) gt 30>
									#left(request.qEquipmentMaint.Notes,15)#...#right(request.qEquipmentMaint.Notes,14)#
								<cfelse>
									#request.qEquipmentMaint.Notes#
								</cfif>
							</cfif>
							</td>		
							<td height="30px" class="normal-td2" valign="middle" align="center">
							<cfif equipmentdisabledstatus neq true>
								<a title="Add Maintenance Transaction for #request.qEquipmentMaint.Description#" href="index.cfm?event=addNewMaintenanceTransaction&equipmentid=#request.qEquipments.EquipmentID#&equipmentMaintId=#request.qEquipmentMaint.EquipMainID#&pageDirection=0&#session.URLToken#&IsCarrier=#isCarrier#"><button>Add Trans</button></a>
							</cfif>
							</td>	
							<td class="normal-td3">&nbsp;</td> 
						</tr>
					</cfloop>
				</tbody>
				<tfoot>
					<tr>
						<td width="5" align="left" valign="top"><img src="images/left-bot.gif" alt="" width="5" height="23" /></td>
						<td colspan="6" align="left" valign="middle" class="footer-bg">
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
		</cfif>
		</div>
	</cfif>
	<script>
		$(function(){
			$('##frmEquipment').submit( function(){
				$('##isSaveEvent').val('true');
			});
			$( "[type='datefield']" ).datepicker({
			 dateFormat: "mm/dd/yy",
			 showOn: "button",
			 buttonImage: "images/DateChooser.png",
			 buttonImageOnly: true,
			 showButtonPanel: true
		   });
			$( ".datefield" ).datepicker( "option", "showButtonPanel", true );
			var old_goToToday = $.datepicker._gotoToday
			$.datepicker._gotoToday = function(id) {
				old_goToToday.call(this,id)
				this._selectDate(id)
			}
			trailerTruckOption(1);
		})

		function trailerTruckOption(pageLoad){
			var val = $('##EquipmentType').val();
			var TruckTrailerOption = '#TruckTrailerOption#';
			if(val == 'Truck'){
				$('##labelTrOption').html('Trailer:');
				var eqType = 'Trailer';
			}
			else if(val == 'Trailer'){
				$('##labelTrOption').html('Truck:');
				var eqType = 'Truck';
			}
			else{
				$('##labelTrOption').html('Truck/Trailer:');
				var eqType = '';
			}
			$('##TruckTrailerOption').html('<option value="">Select</option>');
			$.ajax({
                type    : 'GET',
                url     : "ajax.cfm?event=getEquipmentTruckTrailer&EquipmentType="+eqType,
                success :function(response){
                    var respData = jQuery.parseJSON(response);
                    $.each(respData, function( index, item ) {
                    	if(item.EquipmentID == TruckTrailerOption && pageLoad == 1){
                    		var selText = 'selected'
                    	}
                    	else{
                    		var selText = ''
                    	}
                    	$('##TruckTrailerOption').append('<option value="'+item.EquipmentID+'" '+selText+' data-type="'+item.EquipmentType+'" data-relequip="'+item.RelEquip+'">'+item.EquipmentName+'</option>')
                	})
                	$('.styledSelect').remove();
                		$('.options').remove();
                		var selHtml = $('.select').html();
                		$(selHtml).insertBefore('.select');
                		$('.select').remove();
                	$('##TruckTrailerOption').each(function() {
                		
						var width = $(this).width()-2;
					    // Cache the number of options
					    var $this = $(this),
					    numberOfOptions = $(this).children('option').length;
					    // Hides the select element
					    $this.addClass('s-hidden');
					    // Wrap the select element in a div
					    $this.wrap('<div class="select" style="width:'+width+'px"></div>');
					    // Insert a styled div to sit over the top of the hidden select element
					    $this.after('<div class="styledSelect"></div>');
					    // Cache the styled div
					    var $styledSelect = $this.next('div.styledSelect');
					    // Show the first select option in the styled div
					    $styledSelect.text($this.find('option:selected').text());
					    // Insert an unordered list after the styled div and also cache the list
					    var $table = $('<table />',{'class': 'options','cellspacing':0,'cellpadding':0}).insertAfter($styledSelect);
					    var $thead = $('<thead />').appendTo($table);
					    var $theadtr = $('<tr />').appendTo($thead);
					   	$('<th />', {html: 'Equip','width':'45%'}).appendTo($theadtr);
					   	$('<th />', {html: 'Related Equip','width':'45%'}).appendTo($theadtr);
					   	$('<th />', {html: 'Type','width':'10%'}).appendTo($theadtr);
					   	var $tbody = $('<tbody />').appendTo($table);
					    // Insert a list item into the unordered list for each select option
					    for (var i = 0; i < numberOfOptions; i++) {
					    	var $tbodytr = $('<tr />',{
					    		rel: $this.children('option').eq(i).val()
					    	}).appendTo($tbody);
					        $('<td />', {
					            html: $this.children('option').eq(i).text()
					        }).appendTo($tbodytr);
					        $('<td />', {
					            html: $this.children('option').eq(i).attr('data-relequip')
					        }).appendTo($tbodytr);
					        $('<td />', {
					            html: $this.children('option').eq(i).attr('data-type')
					        }).appendTo($tbodytr);
					    }
					    // Cache the list items
					    var $listItems = $table.children('tbody').children('tr');
					    
					    // Show the unordered list when the styled div is clicked (also hides it if the div is clicked again)
					    $styledSelect.click(function(e) {
					        e.stopPropagation();

					        if($table.is(":visible")){
					        	$table.hide();
					        	return false;
					        }

					        $('div.styledSelect.active').each(function() {
					            $(this).removeClass('active').next('table.options').hide();
					        });
					        $(this).toggleClass('active').next('table.options').toggle();
					        if($(this).next('table.options').css('display')=='table'){
					        	$(this).next('table.options').css('display','block');
					        }
					        if($this.find('option:selected').val() != ''){
					        	$table.children('tbody').children('tr').eq($this.prop('selectedIndex')).addClass('hover');
					        }
					        
					    });
					    // Hides the unordered list when a list item is clicked and updates the styled div to show the selected list item
					    // Updates the select element to have the value of the equivalent option
					    $listItems.click(function(e) {
					        e.stopPropagation();
					        $styledSelect.text($(this).children('td:first').text()).removeClass('active');
					        $this.val($(this).attr('rel'));
					        $table.hide();
					        $this.trigger("change");
					        /* alert($this.val()); Uncomment this for demonstration! */
					    });

					    $listItems.hover(function(e) {
					     	$table.children('tbody').children('tr').removeClass('hover');
					    });
					    // Hides the unordered list when clicking outside of it
					    $(document).click(function() {
					        $styledSelect.removeClass('active');
					        $table.hide();
					    });
					});
                }
            })
		}
	</script>
	<style>
	    .s-hidden {
	        visibility:hidden;
	        padding-right:10px;
	    }
	    .select {
	        cursor:pointer;
	        display:inline-block;
	        position:relative;
	        font:normal 11px/22px Arial,Sans-Serif;
	        color:black;
	        border: 1px solid ##b3b3b3;
	        float: left;
	        height: 21px;
	        margin-bottom: 3px;
	    }
	    .styledSelect {
	        position:absolute;
	        top:0;
	        right:0;
	        bottom:0;
	        left:0;
	        background-color:white;
	        padding:0 4px;
	        height: 21px;
	        overflow: hidden;
	    }
	    .styledSelect:after {
	        content:"";
	        width:0;
	        height:0;
	        border:5px solid transparent;
	        border-color:black transparent transparent transparent;
	        position:absolute;
	        top:9px;
	        right:6px;
	    }
	    .styledSelect:active,.styledSelect.active {
	        background-color:##eee;
	    }
	    .options {
	        display:none;
	        position:absolute;
	        top:100%;
	        right:0;
	        left:0;
	        z-index:999;
	        margin:0 0;
	        padding:0 0;
	        list-style:none;
	        border:1px solid ##b3b3b3;
	        background-color:white;
	        -webkit-box-shadow:0 1px 2px rgba(0,0,0,0.2);
	        -moz-box-shadow:0 1px 2px rgba(0,0,0,0.2);
	        box-shadow:0 1px 2px rgba(0,0,0,0.2);
	        width:352px;
	        max-height: 125px;
	        overflow: auto;
	    }
	    
	    .options tr {
	        padding:0 6px;
	        margin:0 0;
	        padding:0 10px;
	    }
	    .options tr:hover {
	        background-color:##39f;
	        color:white;
	    }
	    .options td {
	        border-top: 1px solid ##b3b3b3;
	        border-right: 1px solid ##b3b3b3;
	        font: 11px/16px Arial,Helvetica,sans-serif !important;
	        padding-left: 3px;
	        padding-right: 3px;
	    }
	    .options th{
	        border-right: 1px solid ##b3b3b3;
	        text-align: left;
	        font: 11px/16px Arial,Helvetica,sans-serif !important;
	        padding-left: 3px;
	        padding-right: 3px;
	        font-weight: bold !important;
	    }
	    .options tr.hover {
	        background-color:##39f;
	        color:white;
	    }
	    .options tbody tr:first-child td:first-child {
	        border-right: none;
	    }
	    .options tbody tr:first-child td:nth-child(2) {
	        border-right: none;
	    }
    </style>
</cfoutput>