<!--- :::::
---------------------------------
Changing 571 Line Extra line comment of consigneeZipcode already use in getdistancenext.cfm page
---------------------------------
::::: --->
<cfoutput>

  <cfparam name="nextLoadStopId" default="">
  <cfparam name="nextLoadStopId" default="">
  <cfparam name="request.LoadStopInfoShipper.userDef1" default="">
  <cfparam name="request.LoadStopInfoShipper.userDef2" default="">
  <cfparam name="request.LoadStopInfoShipper.userDef3" default="">
  <cfparam name="request.LoadStopInfoShipper.userDef4" default="">
  <cfparam name="request.LoadStopInfoShipper.userDef5" default="">
  <cfparam name="request.LoadStopInfoShipper.userDef6" default="">
  <cfparam name="milse" default="0">
  <cfset shipIsPayer = "">
  <cfset consigneeIsPayer = "">
  <cfset ShipCustomerStopName ="">
  <cfset ConsineeCustomerStopName ="">
  <cfset ShipCustomerStopId ="">
  <cfset ConsigneeCustomerStopId ="">
  <cfset Shiplocation ="">
  <cfset Shipcity ="">
  <cfset Shipstate1 ="">
  <cfset Shipzipcode ="">
  <cfset ShipcontactPerson ="">
  <cfset ShipPhone ="">
  <cfset ShipPhoneExt ="">
  <cfset Shipfax ="">
  <cfset Shipemail ="">
  <cfset ShipPickupNo ="">
  <cfset ShippickupDate ="">
  <cfset ShippickupDateMultiple ="">
  <cfset ShippickupTime ="">
  <cfset ShipperTimeZone ="">
  <cfset ShiptimeIn ="">
  <cfset ShiptimeOut ="">
  <cfset ShipInstructions ="">
  <cfset Shipdirection ="">
  <cfset carrierIDNext ="">
  <cfset Consigneelocation ="">
  <cfset Consigneecity ="">
  <cfset Consigneestate1 ="">
  <cfset Consigneezipcode ="">
  <cfset ConsigneecontactPerson ="">
  <cfset ConsigneePhone ="">
  <cfset ConsigneePhoneExt ="">
  <cfset Consigneefax ="">
  <cfset Consigneeemail ="">
  <cfset ConsigneePickupNo ="">
  <cfset ConsigneepickupDate ="">
  <cfset ConsigneepickupTime ="">
  <cfset ConsigneeTimeZone ="">
  <cfset ConsigneetimeIn ="">
  <cfset ConsigneetimeOut ="">
  <cfset ConsigneeInstructions ="">
  <cfset Consigneedirection ="">
  <cfset shipBlind="False">
  <cfset ConsBlind="False">
  <cfset bookedwith1 ="">
  <cfset equipment1 ="">
  <cfset driver ="">
  <cfset driver2 ="">
  <cfset driverCell ="">
  <cfset truckNo ="">
  <cfset TrailerNo ="">
  <cfset refNo ="">
  <cfset showItems = false>
  <cfset stofficeidNext="">
  <cfset secDriverCell ="">
  <cfset carrierID2_1 = "">
  <cfset carrierID3_1 = "">
  <cfset thirdDriverCell ="">
  <cfparam name="statename" default="0">
  	<cfif stopNumber eq 2>
		<cfset currentTab=82>
	<cfelseif stopNumber eq 3>
		<cfset currentTab=200>
	<cfelseif stopNumber eq 4>
		<cfset currentTab=318>
	<cfelseif stopNumber eq 5>
			<cfset currentTab=436>
	<cfelseif stopNumber eq 6>
			<cfset currentTab=554>
	<cfelseif stopNumber eq 7>
			<cfset currentTab=672>
	<cfelseif stopNumber eq 8>
		<cfset currentTab=790>
	<cfelseif stopNumber eq 9>
		<cfset currentTab=908>
	<cfelseif stopNumber eq 10>
		<cfset currentTab=1026>
	<cfelse>
		<cfset currentTab=1026>
	</cfif>
  <cfinvoke component="#variables.objloadGateway#" method="getSystemSetupOptions" returnvariable="request.qSystemSetupOptions" />
  <cfinvoke component="#variables.objloadGateway#" method="getcurAgentdetails" returnvariable="request.qcurAgentdetails" employeID="#session.empid#" />
	<cfif request.qSystemSetupOptions.freightBroker>
		<cfset variables.freightBroker = "Carrier">
		<cfset variables.freightBrokerShortForm = "Carr">
		<cfset variables.freightBrokerReport = "Carrier">
	<cfelse>
		<cfset variables.freightBroker = "Driver">
		<cfset variables.freightBrokerShortForm = "Driv">
		<cfset variables.freightBrokerReport = "Dispatch">
	</cfif>
 <cfif loadIDN neq "">
    <cfinvoke component="#variables.objloadGateway#" method="getAllLoads" loadid="#loadIDN#" stopNo="#StopNoIs#" returnvariable="request.qLoads" />

	<cfif request.qLoads.recordcount and len(request.qLoads.LOADSTOPID) gt 1>
      <cfinvoke component="#variables.objloadGateway#" method="getAllItems" LOADSTOPID="#request.qLoads.LOADSTOPID#" returnvariable="request.qItems" />
      <cfset showItems = true>
      <cfset nextLoadStopId = request.qLoads.LOADSTOPID>
      <cfset url.editid=loadIDN>
      <cfset loadIDN=loadIDN>
      <cfset LOADSTOPID = request.qLoads.LOADSTOPID>
      <cfset loadStatus=request.qLoads.STATUSTYPEID>
      <cfset Salesperson=request.qLoads.SALESREPID>
      <cfset Dispatcher=request.qLoads.DISPATCHERID>
      <cfset Notes=request.qLoads.NEWNOTES>
      <cfset posttoloadboard=request.qLoads.ISPOST>
      <cfset CustomerRate=request.qLoads.CUSTFLATRATE>
      <cfset CarrierRate=request.qLoads.CARRFLATRATE>
      <cfset TotalCustomerCharges=request.qLoads.TotalCustomerCharges>
      <cfset TotalCarrierCharges=request.qLoads.TotalCarrierCharges>
      <cfset dispatchNotes=request.qLoads.NEWDISPATCHNOTES>
      <cfset NewcustomerID=request.qLoads.PAYERID>
      <cfset carrierIDNext=request.qLoads.NEWCARRIERID>
      <cfif len(carrierIDNext) gt 1>
        <cfquery  name="request.qoffices" datasource="#application.dsn#">
			   select * from carrieroffices  where location <> '' and carrierID=<cfqueryparam value="#carrierIDNext#" cfsqltype="cf_sql_varchar">
               ORDER BY Location ASC
			</cfquery>
      </cfif>
      <cfset stofficeidNext = request.qLoads.NEWofficeID>
      <cfset customerPO=request.qLoads.CUSTOMERPONO>
      <cfset request.ShipperStop = request.qLoads>
	  <cfinvoke component="#variables.objloadGateway#" method="getLoadStopInfo" StopNo="#StopNoIs#" LoadType="1" loadID="#loadID#" returnvariable="request.LoadStopInfoShipper" />
      <cfset ShipCustomerStopName=request.ShipperStop.ShipperStopName>
	  <cfset ShipCustomerStopId=request.ShipperStop.shipperCustomerID><!--- added alwin --->
      <cfset shiplocation=request.ShipperStop.ShipperLocation>
      <cfset shipcity=request.ShipperStop.Shippercity>
      <cfset shipstate1=request.ShipperStop.ShipperState>
      <cfset shipzipcode=request.ShipperStop.Shipperpostalcode>
      <cfset shipcontactPerson=request.ShipperStop.ShipperContactPerson>
      <cfset shipPhone=request.ShipperStop.Shipperphone>
      <cfset shipfax=request.ShipperStop.Shipperfax>
      <cfset shipemail=request.ShipperStop.ShipperemailId>
      <cfset shipPickupNo=request.ShipperStop.ShipperReleaseNo>
	  <cfif  NOT  (structkeyexists(url,"loadToBeCopied") ) OR  (structkeyexists(url,"loadToBeCopied") AND url.loadToBeCopied EQ 0 )>
		  <cfif  request.LoadStopInfoShipper.StopDate NEQ "01/01/1900">
			<cfset shippickupDate=request.LoadStopInfoShipper.StopDate>
		</cfif>
		  <cfset ShippickupDateMultiple=request.LoadStopInfoShipper.MultipleDates>
		  <cfset shippickupTime=request.LoadStopInfoShipper.StopTime>
		  <cfset shiptimeIn=request.LoadStopInfoShipper.TimeIn>
		  <cfset shiptimeOut=request.LoadStopInfoShipper.TimeOut>
	  </cfif>
	  <cfinvoke component="#variables.objloadGateway#" method="getPayerStop" stopID="#request.LoadStopInfoShipper.loadstopid#" returnvariable="request.shipIsPayer" />
	  <cfif request.shipIsPayer.recordcount>
			<cfset shipIsPayer = request.shipIsPayer.IsPayer>
	  <cfelse>
			<cfset shipIsPayer = 0>
	  </cfif>
	  <cfset shipBlind=request.ShipperStop.ShipperBlind>
      <cfset shipInstructions=request.ShipperStop.ShipperInstructions>
      <cfset shipdirection=request.ShipperStop.ShipperDirections>
      <cfset request.ConsineeStop = request.qloads>
	  <cfinvoke component="#variables.objloadGateway#" method="getLoadStopInfo" StopNo="#StopNoIs#" LoadType="2" loadID="#loadID#" returnvariable="request.LoadStopInfoConsignee" />
      <cfset ConsineeCustomerStopName=request.ConsineeStop.ConsigneeStopName>
	  <cfset ConsigneeCustomerStopId=request.ConsineeStop.consigneeCustomerID>
      <cfset consigneelocation=request.ConsineeStop.ConsigneeLocation>
      <cfset consigneecity=request.ConsineeStop.Consigneecity>
      <cfset consigneestate1=request.ConsineeStop.ConsigneeState>
      <cfset consigneezipcode=request.ConsineeStop.Consigneepostalcode>
      <cfset consigneecontactPerson=request.ConsineeStop.ConsigneeContactPerson>
      <cfset consigneePhone=request.ConsineeStop.Consigneephone>
      <cfset consigneefax=request.ConsineeStop.Consigneefax>
      <cfset consigneeemail=request.ConsineeStop.ConsigneeemailId>
      <cfset consigneePickupNo=request.ConsineeStop.ConsigneeReleaseNo>
	  <cfif  NOT  (structkeyexists(url,"loadToBeCopied") ) OR  (structkeyexists(url,"loadToBeCopied") AND url.loadToBeCopied EQ 0 )>
		  <cfif  request.LoadStopInfoConsignee.StopDate NEQ "01/01/1900">
			<cfset consigneepickupDate=request.LoadStopInfoConsignee.StopDate>
			</cfif>
		  <cfset consigneepickupTime=request.LoadStopInfoConsignee.StopTime>
		  <cfset consigneetimeIn=request.LoadStopInfoConsignee.TimeIn>
		  <cfset consigneetimeOut=request.LoadStopInfoConsignee.TimeOut>
		</cfif>
	  <cfinvoke component="#variables.objloadGateway#" method="getPayerStop" stopID="#request.LoadStopInfoConsignee.loadstopid#" returnvariable="request.consigneeIsPayer" />
	  <cfif request.consigneeIsPayer.recordcount>
			<cfset consigneeIsPayer = request.consigneeIsPayer.IsPayer>
	  <cfelse>
			<cfset consigneeIsPayer = 0>
	  </cfif>
	  <cfset ConsBlind=request.ConsineeStop.ConsigneeBlind>
      <cfset consigneeInstructions=request.ConsineeStop.ConsigneeInstructions>
      <cfset consigneedirection=request.ConsineeStop.ConsigneeDirections>
      <cfset bookedwith1=request.ConsineeStop.ConsigneeBOOKEDWITH>
      <cfset equipment1=request.ConsineeStop.ConsigneeEQUIPMENTID>
      <cfset driver=request.ConsineeStop.ConsigneeDRIVERNAME>
	 <cfset driver2=request.ConsineeStop.consigneeDriverName2>
      <cfset driverCell=request.ConsineeStop.ConsigneeDRIVERCELL>
      <cfset truckNo=request.ConsineeStop.ConsigneeTRUCKNO>
      <cfset TrailerNo=request.ConsineeStop.ConsigneeTRAILORNO>
      <cfset refNo=request.ConsineeStop.ConsigneeREFNO>
      <cfset milse=request.ConsineeStop.ConsigneeMILES>
      <cfset editid=loadIDN>
	  <cfset secDriverCell=request.ConsineeStop.consigneeDriverCell2>

    </cfif>
  </cfif>
  <input type="hidden" name="nextLoadStopId#stopNumber#" value="#nextLoadStopId#">
    <div class="white-mid" style="width: 932px;">
		<div>
			<div class="clear"></div>
			<div id="ShipperInfo"  style="clear:both">
				<div class="" style="position: absolute;">
					<div class="fa fa-minus-circle PlusToggleButton" onclick="showHideIcons(this,#stopNumber#);" style="position:relative;margin-left: 5px;"></div>
					<label style="float: left;width: 90px;padding: 0 10px 0 0;font-size: 12px;font-weight: bold;color: ##000000;margin-top: 7px;text-align: right;">Pickup Name</label>
				</div>
				<div style="    position: absolute;line-height: -20px;width: 224px;left: 357px;top: 35px;">
					<span style="display:inline-block;text-align:right;" name="span_Shipper" id="span_Shipper#stopNumber#"></span>
				</div>
				<div class="form-con InfoShipping#stopNumber# InfoStopLeft" style="width: 463px;">
					<fieldset>
						<cfset shipperStopId = "">
						<cfset shipperStopNameList="">
						<cfset tempList = "">
						<input name="shipper#stopNumber#" class="myElements" style="margin-left:112px;" id="shipper#stopNumber#" value="#ShipCustomerStopName#"  message="Please select a Shipper"   onkeyup ="ChkUpdteShipr(this.value,'Shipper',#stopNumber#); showChangeAlert('shipper',#stopNumber#);"  onblur ="ChkUpdteShipr(this.value,'Shipper',#stopNumber#); showChangeAlert('shipper',#stopNumber#);"   tabindex="#evaluate(currentTab++)#" title="Type text here to display list."/>
						<img src="images/clearRed.gif" style="height:14px;width:14px"  title="Click here to clear pickup information"  onclick="ChkUpdteShipr('','Shipper1',#stopNumber#);">
						<input type="hidden" name="shipperValueContainer#stopNumber#" id="shipperValueContainer#stopNumber#" value="#ShipCustomerStopId#"  message="Please select a Shipper"/>
						<input type="hidden" name="shipIsPayer#stopNumber#" class="updateCreateAlert" id="shipIsPayer#stopNumber#" value="#shipIsPayer#">
						<div class="clear"></div>
						<input name="shipperName#stopNumber#" id="shipperName#stopNumber#" value="#ShipCustomerStopName#" type="text"    onkeyup ="ChkUpdteShipr(this.value,'Shipper',#stopNumber#); showChangeAlert('shipper',#stopNumber#);"  tabindex="#evaluate(currentTab++)#" style="display: none;"/>
						<input type="hidden" name="shipperNameText#stopNumber#" id="shipperNameText#stopNumber#" value="#ShipCustomerStopName#" maxlength="100" >
						<div class="clear"></div>
						<p style="transform: rotate(-90deg);width: 300px;margin-left: -137px;color: ##0f4100;font-weight: bold;font-size: 20px;font-family: 'Arial Black';letter-spacing: 5px;">PICKUP</p>
                        <div class="clear" style="margin-top: -15px;"></div>
						<label>
							<p id="newShipper#stopNumber#" style="float: left;font-size: 14px;color: ##2c9500;display:none;">* NEW *</p>Address
							<div class="clear"></div>
							<span class="float_right">
								<cfif request.qSystemSetupOptions.googleMapsPcMiler AND request.qcurAgentdetails.PCMilerUsername NEQ "" AND request.qcurAgentdetails.PCMilerPassword NEQ "">
									<a href="##" onclick="Mypopitup('create_map.cfm?loc=#shiplocation#&city=#shipcity#&state=#stateName# #shipzipcode#&stopNo=#stopNumber#&shipOrConsName=#ShipCustomerStopName#&loadNum=#loadnumber#' );"><img style="float:left;" align="absmiddle" src="./map.jpg" width="24" height="24" alt="Pro Miles Map"  /></a>
								<cfelse>
									<a href="##" onclick="Mypopitup('create_map.cfm?loc=#shiplocation#&city=#shipcity#&state=#stateName# #shipzipcode#&stopNo=#stopNumber#&shipOrConsName=#ShipCustomerStopName#&loadNum=#loadnumber#' );"><img style="float:left;" align="absmiddle" src="./map.jpg" width="24" height="24" alt="Google Map"  /></a>
								</cfif>
							</span>
						</label>
						<input type="hidden" name="shipperUpAdd#stopNumber#" id="shipperUpAdd#stopNumber#" value="">
						<textarea class="addressChange" rows="" name="shipperlocation#stopNumber#" id="shipperlocation#stopNumber#" cols=""   onkeydown="ChkUpdteShiprAddress(this.value,'Shipper',#stopNumber#);" data-role="#stopNumber#" tabindex="#evaluate(currentTab++)#" maxlength="100" onchange="checkShipperUpdated('#stopNumber#');" style="height: 40px;">#shiplocation#</textarea>
						<div class="clear"></div>
						<cfset variables.citytabIndex=currentTab++>
						<label>City</label>
						<input class="addressChange" name="shippercity#stopNumber#" id="shippercity#stopNumber#" value="#shipcity#" type="text" data-role="#stopNumber#"  onkeydown="ChkUpdteShiprCity(this.value,'Shipper',#stopNumber#);" tabindex="-1"  maxlength="50" onchange="checkShipperUpdated('#stopNumber#');"/>
						<div class="clear"></div>
						<cfset variables.statetabIndex=variables.citytabIndex+1>
						<label>State</label>
						<select name="shipperstate#stopNumber#" id="shipperstate#stopNumber#" onchange="addressChanged(#stopNumber#);loadState(this,'shipper',#stopNumber#);checkShipperUpdated('#stopNumber#');" tabindex="-1" style="width:60px;">
						  <option value="">Select</option>
						  <cfloop query="request.qStates">
							<option value="#request.qStates.statecode#" <cfif request.qStates.statecode is shipstate1> selected="selected" </cfif> >#request.qStates.statecode#</option>
							<cfif request.qStates.statecode is shipstate1>
							  <cfset variables.stateName = #request.qStates.statecode#>
							</cfif>
						  </cfloop>
						</select>
						<input type="hidden" name="shipperStateName#stopNumber#" id="shipperStateName#stopNumber#" value ="<cfif structKeyExists(variables,"stateName")>#variables.stateName#</cfif>">
						<cfset variables.ziptabIndex=variables.statetabIndex-2>
						<label style="width: 58px;">Zip</label>
						<input class="addressChange" name="shipperZipcode#stopNumber#" id="shipperZipcode#stopNumber#" value="#shipzipcode#" type="text" data-role="#stopNumber#" tabindex="#evaluate(currentTab++)#"  maxlength="50" onchange="checkShipperUpdated('#stopNumber#');" style="width:60px;"/>
						<div class="clear"></div>
						<!---for promiles--->
						<input type="hidden" name="shipperAddressLocation#stopNumber#" id="shipperAddressLocation#stopNumber#" value="#shipcity#<cfif len(shipcity)>,</cfif>#shipstate1# #shipzipcode#">
						<cfif len(url.loadid) gt 1> <cfset currentTab=variables.ziptabIndex+3></cfif>

						<label>Contact</label>
						<input name="shipperContactPerson#stopNumber#" id="shipperContactPerson#stopNumber#" value="#shipcontactPerson#" type="text" tabindex="#evaluate(currentTab++)#" maxlength="100" onchange="checkShipperUpdated('#stopNumber#');"/>
						<div class="clear"></div>
						<label>Phone</label>
						<input name="shipperPhone#stopNumber#" id="shipperPhone#stopNumber#" value="#shipPhone#" type="text" onchange="ParseUSNumber(this.value);" tabindex="#evaluate(currentTab++)#"  maxlength="30" onchange="checkShipperUpdated('#stopNumber#');" style="width:155px !important;"/>
						<label style="width:30px !important;">Ext</label>
						<input name="shipperPhoneExt#stopNumber#" id="shipperPhoneExt#stopNumber#" value="#shipPhoneExt#" type="text" tabindex="#evaluate(currentTab+2)#" maxlength="10"  onchange="checkShipperUpdated('');" style="width:50px !important;" />
						<div class="clear"></div>
						<label>Fax</label>
						<input name="shipperFax#stopNumber#" id="shipperFax#stopNumber#" value="#shipfax#" type="text" tabindex="#evaluate(currentTab++)#" maxlength="150"/>
						<div class="clear"></div>
						<label>Email</label>
						<input name="shipperEmail#stopNumber#" id="shipperEmail#stopNumber#" value="#shipemail#" type="text" tabindex="#evaluate(currentTab++)#" maxlength="100" onchange="checkShipperUpdated('#stopNumber#');"/>
					</fieldset>
				</div>
				<div class="form-con InfoShipping#stopNumber#">
					<fieldset>
						<label class="stopsLeftLabel">Pickup ## </label>
						<input name="shipperPickupNo1#stopNumber#" id="shipperPickupNo1#stopNumber#" value="#shipPickupNo#" type="text" tabindex="#evaluate(currentTab++)#" maxlength="50"/>
						<label class="ch-box" style="width: 80px;text-align: right;margin-right: -5px;">Pickup Blind</label>
						<input name="shipBlind#stopNumber#" id="shipBlind#stopNumber#" type="checkbox" <cfif shipBlind is true> checked="checked" </cfif> class="check" tabindex="#evaluate(currentTab++)#" style="width: 18px;"/>
						<div class="clear"></div>
						<label class="stopsLeftLabel">
							<cfif request.qSystemSetupOptions.FreightBroker NEQ 0>
								<a style="color: ##4322cc;text-decoration:underline;" href="javascript:void(null)" onclick="window.open('index.cfm?event=addMultipleDates&stopNo=#stopNumber#&#session.URLToken#','Map','height=400,width=400');">Pickup Date*</a>
							<cfelse>
              	Pickup Date
							</cfif>
						</label>
						<div style="position:relative;float:left;">
							  <div style="float:left;">
							  	<input type="hidden" id="shipperPickupDateMultiple#stopNumber#" name="shipperPickupDateMultiple#stopNumber#" value="#ShippickupDateMultiple#">
						<input class="sm-input datefield" name="shipperPickupDate#stopNumber#" onchange="checkDateFormatAll(this);checkMultiplePickupDate(#stopNumber#);" id="shipperPickupDate#stopNumber#" value="#dateformat(ShippickupDate,'mm/dd/yyy')#" validate="date" message="Please enter a valid date" type="datefield" tabindex="#evaluate(currentTab++)#" data-stop="#stopNumber#"/>
						  </div></div>
						<label class="sm-lbl" style="width: 50px;">Apt. Time</label>
						<input class="pick-input" name="shipperpickupTime#stopNumber#" id="shipperpickupTime#stopNumber#" value="#shippickupTime#" type="text" tabindex="#evaluate(currentTab++)#" style="width:40px;" maxlength="50" />
						<cfif request.qSystemSetupOptions.timezone>
							<label class="sm-lbl" style="width: 55px;">Time Zone</label>
	                        <input class="pick-input" name="shipperTimeZone#stopNumber#" id="shipperTimeZone#stopNumber#" value="#shipperTimeZone#" type="text" tabindex="#evaluate(currentTab++)#" style="width:30px;"/>
	                    </cfif>
						<div class="clear"></div>
						<label class="stopsLeftLabel">Arrived</label>
						<input class="sm-input" name="shipperTimeIn#stopNumber#" id="shipperTimeIn#stopNumber#" value="#shiptimeIn#" type="text" tabindex="#evaluate(currentTab++)#" maxlength="50" />
						<label class="sm-lbl" style="width: 65px">Departed</label>
						<input class="pick-input" name="shipperTimeOut#stopNumber#" id="shipperTimeOut#stopNumber#" value="#shipTimeOut#" type="text" tabindex="#evaluate(currentTab++)#" maxlength="50" style="width: 40px;"/>
						<div class="clear"></div>
						<label class="stopsLeftLabel margin_top">Instructions</label>
						<textarea rows="" name="shipperNotes#stopNumber#" id="shipperNotes#stopNumber#" class="carrier-textarea-medium" cols="" tabindex="#evaluate(currentTab++)#"  style="width: 298px;height: 65px;margin-left: 0px;">#shipInstructions#</textarea>
						<div class="clear"></div>
						<label class="stopsLeftLabel margin_top">Internal Notes</label>
						<textarea maxlength="1000" rows="" name="shipperDirection#stopNumber#" id="shipperDirection#stopNumber#" class="carrier-textarea-medium" cols="" tabindex="#evaluate(currentTab++)#" onchange="checkShipperUpdated('#stopNumber#');"  style="width: 298px;height: 68px;margin-left: 0px;">#shipdirection#</textarea>
						<div class="clear"></div>
					</fieldset>
				</div>
			</div>
			<div class="clear"></div>
			<div align="center">
					<div style="border-bottom:1px solid ##e6e6e6; padding-top:7px;margin-bottom:8px;"></div>
				</div>
			<div class="clear"></div>
		</div>
		<div style="margin-top: 20px;">
			<div id="ConsigneeInfo" style="height:15px;">
				<div class="" style="clear:both;">
					<div class="fa fa-minus-circle PlusToggleButton" onclick="showHideConsineeIcons(this,#stopNumber#);" style="position:absolute;left:-16px;margin-top: -4px;"></div>
					<span class="ShipperHead" style="position:absolute;left:26px;color:##000000;font-size: 12px;padding-top: 0;">Delivery Name</span>
				</div>
				<div style="position: absolute;right: 0;line-height: 25px;width: 475px;">
					<span style="display:inline-block;" name="span_Consignee" id ="span_Consignee#stopNumber#"></span>
				</div>
				<div class="form-con InfoConsinee#stopNumber# InfoStopLeft" style="margin-top:-6px;width: 463px;">
				  <fieldset>
					<cfset shipperStopId = "">
					<cfset shipperStopNameList="">
					<cfset tempList = "">
					<input name="consignee#stopNumber#" class="myElements" style="margin-left:112px;" id="consignee#stopNumber#" value="#ConsineeCustomerStopName#"    onkeyup ="ChkUpdteShipr(this.value,'consignee',#stopNumber#); showChangeAlert('consignee',#stopNumber#);" onblur ="ChkUpdteShipr(this.value,'consignee',#stopNumber#); showChangeAlert('consignee',#stopNumber#);"  message="Please select a Consignee" tabindex="#evaluate(currentTab++)#" title="Type text here to display list."/><img src="images/clearRed.gif" style="height:14px;width:14px"  title="Click here to clear consignee information"  onclick="ChkUpdteShipr('','consignee1',#stopNumber#);">
					<input type="hidden" name="consigneeValueContainer#stopNumber#" id="consigneeValueContainer#stopNumber#" value="#ConsigneeCustomerStopId#"  message="Please select a Consignee" />
					<input type="hidden" name="consigneeIsPayer#stopNumber#" class="updateCreateAlert" id="consigneeIsPayer#stopNumber#" value="#consigneeIsPayer#">
					<div class="clear"></div>
					<input name="consigneeName#stopNumber#" id="consigneeName#stopNumber#" value="#ConsineeCustomerStopName#" type="text"    onkeyup ="ChkUpdteShipr(this.value,'consignee',#stopNumber#); showChangeAlert('consignee',#stopNumber#);" tabindex="#evaluate(currentTab++)#" maxlength="100" style="display:none;"/>
					<input type="hidden" name="consigneeNameText#stopNumber#" id="consigneeNameText#stopNumber#" value="#ConsineeCustomerStopName#">
					<div class="clear"></div>
                    <p style="transform: rotate(-90deg);width: 350px;margin-left: -163px;color: ##800000;font-weight: bold;font-size: 20px;font-family: 'Arial Black';letter-spacing: 5px;">DELIVERY</p>
                    <div class="clear" style="margin-top: -15px;"></div>
				 <label><p id="newConsignee#stopNumber#" style="float: left;font-size: 14px;color: ##2c9500;display:none;">* NEW *</p>Address
					<div class="clear"></div>
					<span class="float_right">
						<cfif request.qSystemSetupOptions.googleMapsPcMiler AND request.qcurAgentdetails.PCMilerUsername NEQ "" AND request.qcurAgentdetails.PCMilerPassword NEQ "">
							<a href="##" onclick="Mypopitup('create_map.cfm?loc=#Consigneelocation#&city=#Consigneecity#&state=#stateName# #Consigneezipcode#&stopNo=#stopNumber#&shipOrConsName=#ConsineeCustomerStopName#&loadNum=#loadnumber#');" ><img style="float:left;" align="absmiddle" src="./map.jpg" width="24" height="24" alt="Pro Miles Map"/></a>
						<cfelse>
							<a href="##" onclick="Mypopitup('create_map.cfm?loc=#Consigneelocation#&city=#Consigneecity#&state=#stateName# #Consigneezipcode#&stopNo=#stopNumber#&shipOrConsName=#ConsineeCustomerStopName#&loadNum=#loadnumber#');" ><img style="float:left;" align="absmiddle" src="./map.jpg" width="24" height="24" alt="Google Map"/></a>
						</cfif>
					</span>
				  </label>
				<input type="hidden" name="consigneeUpAdd#stopNumber#" id="consigneeUpAdd#stopNumber#" value="">

					<textarea class="addressChange" rows="" name="consigneelocation#stopNumber#" id="consigneelocation#stopNumber#" cols="" 	onkeydown="ChkUpdteShiprAddress(this.value,'consignee',#stopNumber#);"  data-role="#stopNumber#" tabindex="#evaluate(currentTab++)#"  maxlength="100" onchange="checkConsngeeUpdated('#stopNumber#');" style="height: 40px;">#Consigneelocation#</textarea>
					<cfset variables.cityConsigneetabIndex=currentTab+1>
					<div class="clear"></div>
					<label>City</label>
					<input class="addressChange" name="consigneecity#stopNumber#" id="consigneecity#stopNumber#" value="#Consigneecity#" type="text"  data-role="#stopNumber#" onkeydown="ChkUpdteShiprCity(this.value,'consignee',#stopNumber#);"   tabindex="-1"  maxlength="50" onchange="checkConsngeeUpdated('#stopNumber#');"/>
					<div class="clear"></div>
					<cfset variables.stateConsigneetabIndex=variables.cityConsigneetabIndex+1>
					<label>State</label>
					<select name="consigneestate#stopNumber#" id="consigneestate#stopNumber#" onchange="addressChanged(#stopNumber#);loadState(this,'consignee',#stopNumber#);checkConsngeeUpdated('#stopNumber#');"  tabindex="-1" style="width:60px;">
					  <option value="">Select</option>
					  <cfloop query="request.qStates">
						<option value="#request.qStates.statecode#" <cfif request.qStates.statecode is Consigneestate1> selected="selected" </cfif> >#request.qStates.statecode#</option>
						<cfif request.qStates.statecode is Consigneestate1>
						  <cfset variables.statecode = #request.qStates.statecode#>
						</cfif>
					  </cfloop>
					</select>
					<input type="hidden" name="consigneeStateName#stopNumber#" id="consigneeStateName#stopNumber#" value ="<cfif structKeyExists(variables,"statecode")>#variables.statecode#</cfif>">
					<cfset variables.zipConsigneetabIndex=variables.stateConsigneetabIndex-2>
					<label style="width:58px;">Zip</label>
						<cfoutput>
							<cfset Zipcode1="">
							<cfset Zipcode2="">
							<cfSet result1="0,0">
							<cfset result2="0,0">
							<cfset lat1="0">
							<cfset lat2="0">
							<cfset long1="0">
							<cfset long2="0">

								<cfif len(url.loadid) gt 1>
									<input tabindex="#evaluate(currentTab++)#" name="consigneeZipcode#stopNumber#" id="consigneeZipcode#stopNumber#" value="#Consigneezipcode#" type="text" onchange="getLongitudeLatitudeNext(load,#stopNumber#);ClaculateDistanceNext(load,#stopNumber#);addressChanged(#stopNumber#);"  maxlength="50"  style="width:60px;"/>
								<cfelse>
									<input tabindex="#evaluate(currentTab++)#" name="consigneeZipcode#stopNumber#"  id="consigneeZipcode#stopNumber#" value="#Consigneezipcode#" type="text" onchange="getLongitudeLatitudeNext(load,#stopNumber#);ClaculateDistanceNext(load,#stopNumber#);addressChanged(#stopNumber#);"  maxlength="50"  style="width:60px;"/>
								</cfif>
								<input type="hidden" name="result1#stopNumber#" id="result1#stopNumber#" value="#result1#" >
								<input type="hidden" name="result2#stopNumber#" id="result2#stopNumber#" value="#result2#" >
								<input type="hidden" name="lat1#stopNumber#" id="lat1#stopNumber#" value="#lat1#">
								<input type="hidden" name="long1#stopNumber#" id="long1#stopNumber#" value="#long1#">
								<input type="hidden" name="lat2#stopNumber#" id="lat2#stopNumber#" value="#lat2#">
								<input type="hidden" name="long2#stopNumber#" id="long2#stopNumber#" value="#long2#">
							</cfoutput>
					<div class="clear"></div>
					<!---for promiles--->
					<input type="hidden" name="consigneeAddressLocation#stopNumber#" id="consigneeAddressLocation#stopNumber#" value="#Consigneecity#<cfif len(Consigneecity)>,</cfif>#Consigneestate1# #Consigneezipcode#">
					<cfif structkeyexists(url,"loadid")>
						<cfset currentTab=variables.zipConsigneetabIndex+3>
					</cfif>
					<label>Contact</label>
					<input name="consigneeContactPerson#stopNumber#" id="consigneeContactPerson#stopNumber#" value="#ConsigneecontactPerson#" type="text" tabindex="#evaluate(currentTab++)#"  maxlength="200" onchange="checkConsngeeUpdated('#stopNumber#');"/>
					<div class="clear"></div>
					<label>Phone</label>
					<input name="consigneePhone#stopNumber#" id="consigneePhone#stopNumber#" value="#ConsigneePhone#" onchange="ParseUSNumber(this.value);" type="text" tabindex="#evaluate(currentTab++)#" maxlength="30" onchange="checkConsngeeUpdated('#stopNumber#');" style="width:155px !important;"/>
					<label style="width:30px !important;">Ext</label>
          <input name="consigneePhoneExt#stopNumber#" id="consigneePhoneExt#stopNumber#" value="#ConsigneePhoneExt#" type="text" tabindex="#evaluate(currentTab+21)#" maxlength="10" onchange="checkConsngeeUpdated('');" style="width:50px !important;"/>
					<div class="clear"></div>
					<label>Fax</label>
					<input name="consigneeFax#stopNumber#" id="consigneeFax#stopNumber#" value="#Consigneefax#" type="text" tabindex="#evaluate(currentTab++)#"  maxlength="150" onchange="checkConsngeeUpdated('#stopNumber#');"/>
					<div class="clear"></div>
					<label>Email</label>
					<input name="consigneeEmail#stopNumber#" id="consigneeEmail#stopNumber#" value="#Consigneeemail#" type="text" tabindex="#evaluate(currentTab++)#" maxlength="100" onchange="checkConsngeeUpdated('#stopNumber#');"/>
				  </fieldset>
				</div>
				<div class="form-con InfoConsinee#stopNumber#" style="margin-top: -7px;">
				  <fieldset>
					<label class="stopsLeftLabel">Delivery ##</label>
					<input name="consigneePickupNo#stopNumber#" id="consigneePickupNo#stopNumber#" value="#ConsigneePickupNo#" type="text" tabindex="#evaluate(currentTab++)#"/>
					<label class="ch-box" style="width: 80px;text-align: right;margin-right: -7px;">Delivery Blind</label>
					<input name="ConsBlind#stopNumber#" id="ConsBlind#stopNumber#" type="checkbox" <cfif ConsBlind is true> checked="checked" </cfif> class="check" tabindex="#evaluate(currentTab++)#" style="width: 18px;"/>
					<div class="clear"></div>
					<label class="stopsLeftLabel">Delivery Date*</label>
					<div style="position:relative;float:left;">
						  <div style="float:left;">
					<input class="sm-input datefield" name="consigneePickupDate#stopNumber#" onchange="checkDateFormatAll(this);" id="consigneePickupDate#stopNumber#" value="#dateformat(ConsigneepickupDate,'mm/dd/yyy')#" validate="date" message="Please enter a valid date" type="datefield" tabindex="#evaluate(currentTab++)#" data-stop="#stopNumber#" maxlength="50" />
					  </div></div>
					<label class="sm-lbl" style="width: 50px;">Apt. Time</label>
					<input class="pick-input" name="consigneepickupTime#stopNumber#" id="consigneepickupTime#stopNumber#" value="#ConsigneepickupTime#" type="text" tabindex="#evaluate(currentTab++)#" style="width: 40px;" maxlength="50" />
					<cfif request.qSystemSetupOptions.timezone>
						<label class="sm-lbl" style="width: 55px;">Time Zone</label>
	                    <input class="pick-input" name="consigneeTimeZone#stopNumber#" id="consigneeTimeZone#stopNumber#" value="#consigneeTimeZone#" type="text" tabindex="#evaluate(currentTab++)#" style="width:30px;"/>
	                </cfif>
					<div class="clear"></div>
					<label class="stopsLeftLabel">Arrived</label>
					<input class="sm-input" name="consigneeTimeIn#stopNumber#" id="consigneeTimeIn#stopNumber#" value="#ConsigneetimeIn#" message="Please enter a valid time" type="text" tabindex="#evaluate(currentTab++)#" maxlength="50" />
					<label class="sm-lbl" style="width:65px;">Departed</label>
					<input class="pick-input" name="consigneeTimeOut#stopNumber#" id="consigneeTimeOut#stopNumber#" value="#ConsigneeTimeOut#" type="text" message="Please enter a valid time" tabindex="#evaluate(currentTab++)#" maxlength="50" style="width: 40px;"/>
					<div class="clear"></div>
					<label class="stopsLeftLabel margin_top">Instructions</label>
					<textarea rows="" name="consigneeNotes#stopNumber#" id="consigneeNotes#stopNumber#" class="carrier-textarea-medium" cols="" tabindex="#evaluate(currentTab++)#"  style="width: 298px;height: 67px;margin-left: 0px;">#ConsigneeInstructions#</textarea>
					<div class="clear"></div>
					<label class="stopsLeftLabel margin_top">Internal Notes</label>
					<textarea rows="" maxlength="1000" name="consigneeDirection#stopNumber#" id="consigneeDirection#stopNumber#" class="carrier-textarea-medium" cols="" tabindex="#evaluate(currentTab++)#" onchange="checkConsngeeUpdated('#stopNumber#');" style="width: 298px;height: 68px;margin-left: 0px;">#Consigneedirection#</textarea>
					<div class="clear"></div>
				  </fieldset>
				</div>
			</div>
			<div class="clear"></div>
			<div align="center">
					<div style="border-bottom:1px solid ##e6e6e6; padding-top:7px;"></div>
				</div>
			<div class="clear"></div>
		</div>
		<cfset chckdCarrier = "">
		<cfif trim(carrierIDNext) NEQ ""> 
			<cfinvoke component="#variables.objcarrierGateway#" method="getAllCarriers" returnvariable="qgetcarier" carrierId="#carrierIDNext#"  />  
			<cfset chckdCarrier = qgetcarier.ISCARRIER >									
		</cfif>

		<div id="carriertabs#stopNumber#" class="tabsload ui-tabs ui-widget ui-widget-content ui-corner-all">
            <ul class="ui-tabs-nav ui-helper-reset ui-helper-clearfix ui-widget-header ui-corner-all" style="height:27px;">
                <li class="ui-state-default ui-corner-top ui-tabs-active ui-state-active"><a class="ui-tabs-anchor" href="##carriertabs-#stopNumber#-carrier" <cfif len(url.loadid) gt 1 AND NOT (request.qSystemSetupOptions.freightBroker EQ 0 OR (request.qSystemSetupOptions.freightBroker EQ 2 AND chckdCarrier EQ 0))>onclick="clearQuote(1);toggleCommodities(1);"<cfelse>onclick="toggleCommodities(1,'#stopNumber#');"</cfif>><cfif request.qSystemSetupOptions.freightBroker EQ 2>
                    <cfif chckdCarrier EQ  "">
                    	Carrier/Driver
                    <cfelseif  chckdCarrier EQ 0>
                        Driver
                    <cfelseif  chckdCarrier EQ 1>  
                        Carrier 
                    </cfif>
                <cfelse>
                    #variables.freightBroker#
                </cfif></a></li>

                <cfif request.qSystemSetupOptions.freightBroker EQ 0 OR (request.qSystemSetupOptions.freightBroker EQ 2 AND chckdCarrier EQ 0)>
                    <li class="ui-state-default ui-corner-top">
                        <a class="ui-tabs-anchor" href="##carriertabs-#stopNumber#-carrier2" onclick="toggleCommodities(0,'#stopNumber#')">Driver2</a>
                    </li>
                    <li class="ui-state-default ui-corner-top">
                        <a class="ui-tabs-anchor" href="##carriertabs-#stopNumber#-carrier3" onclick="toggleCommodities(0,'#stopNumber#')">Driver3</a>
                    </li>
                </cfif>

                <cfif len(url.loadid) gt 1 AND NOT (request.qSystemSetupOptions.freightBroker EQ 0 OR (request.qSystemSetupOptions.freightBroker EQ 2 AND chckdCarrier EQ 0))>
	                <li class="ui-state-default ui-corner-top"><a class="ui-tabs-anchor" href="##carriertabs-#stopNumber#-QuoteList" onclick="clearQuote(#stopNumber#)">Quote List</a></li>
	                <li class="ui-state-default ui-corner-top"><a class="ui-tabs-anchor add_quote_txt" href="##carriertabs-#stopNumber#-QuoteDetail" onclick="clearQuote(#stopNumber#)">Add Quote</a></li>
	                <div style="float: left; width: 56%; height:6px;">
	                    <h2 style="color:white;font-weight:bold;margin-top: -11px;margin-left: 135px;">
	                    	<cfif request.qSystemSetupOptions.freightBroker EQ 2>
                                <cfif chckdCarrier EQ  "">
                                	Carrier/Driver
                                <cfelseif  chckdCarrier EQ 0>
                                    Driver
                                <cfelseif  chckdCarrier EQ 1>  
                                    Carrier 
                                </cfif>
                            <cfelse>
                                #variables.freightBroker#
                            </cfif>
	                    </h2>
	                </div>
	            </cfif>
            </ul>
            <div id="carriertabs-#stopNumber#-carrier">
            	<div class="white-con-area" style="background-color: ##defaf9;">
            		<div class="fa fa-plus-circle PlusToggleButton" onclick="showHideCarrierBlock(this,#stopNumber#);" style="position:relative;margin-left: 0;margin-top: 10px"></div>
		  <div class="pg-title-carrier" style="float: left; width: 35%;padding-left:10px;/*color:white;*/font-weight:bold;font-size: 15px;">
			 <cfif request.qSystemSetupOptions.freightBroker EQ 2> 					                               
					<div class="" style="margin:12px 0px 0px 0px !important;">
						<input type="radio" name="Rad_freightBroker#stopNumber#"  id="Rad_freightBroker"  value="2" <cfif chckdCarrier EQ  "">checked</cfif>  onclick="ChangeLabelStop(2,#stopNumber#)">&nbsp;Both&nbsp;
						<input type="radio" name="Rad_freightBroker#stopNumber#"  id="Rad_freightBroker"  value="1" onclick="ChangeLabelStop(1,#stopNumber#)" <cfif chckdCarrier EQ 1>checked</cfif> >&nbsp;Carrier&nbsp;
						<input type="radio" name="Rad_freightBroker#stopNumber#"  id="Rad_freightBroker"  value="0" onclick="ChangeLabelStop(0,#stopNumber#)" <cfif chckdCarrier EQ 0>checked</cfif> >&nbsp;Driver&nbsp;
					</div>                                
				<cfelse>
					<h2 style="font-weight:bold;">#variables.freightBroker# </h2>
				</cfif>
		  </div>
	  </div>
      <div class="form-heading-carrier carrierBlock#stopNumber#">
        <div class="rt-button">
        </div>
        <div class="form-con carrierBlock#stopNumber#" style="font-weight:bold;text-transform:uppercase;">
		  <cfif ListContains(session.rightsList,'bookCarrierToLoad',',')>
              <cfset carrierLinksOnClick = "">
              <cfelse>
              <cfset carrierLinksOnClick = "alert('Sorry!! You don\'t have rights to add/edit #variables.freightBroker#.'); return false;">
            </cfif>
      
			<a href="javascript:void(0);" id="LinkRemoveCarrier#stopNumber#" onClick="#carrierLinksOnClick#; chooseCarrierNext(#stopNumber#);" style="color:##236334;display:none">
				<img style="vertical-align:bottom;" src="images/change.png">
				<span class="removetxt#stopNumber#">
									<cfif request.qSystemSetupOptions.freightBroker EQ 2> 
										Remove  
										<cfif  chckdCarrier EQ 0>
											Driver
										<cfelseif  chckdCarrier EQ 1>
											Carrier
										<cfelse>
											Carrier/Driver
										</cfif> 
									<cfelse>
										Remove #variables.freightBroker#
									</cfif>
				</span>
			</a>
        </div>
        <div class="clear"></div>
      </div>
      <div class="form-con carrierBlock#stopNumber#" style="width:400px"><input type="hidden" name="carrier_id#stopNumber#" id="carrier_id#stopNumber#" value="#carrierIDNext#" data-limit="<cfif trim(carrierIDNext) NEQ "">#qgetcarier.LoadLimit#</cfif>">
        <input name="carrierID#stopNumber#" id="carrierID#stopNumber#" type="hidden" value="#carrierIDNext#" />
        <fieldset>
          <div id="choosCarrier#stopNumber#" style="<cfif len(carrierIDNext) gt 0>display:none<cfelse>display:block</cfif>;">
            <div class="clear"></div>
			<label class="LabelfreightBroker#stopNumber#" style="width: 102px !important;">Choose #variables.freightBroker#</label>
            <input name="selectedCarrier#stopNumber#" id="selectedCarrierValue#stopNumber#" class="carrier-box" style="margin-left: 0;width: 230px !important;" type="text" <cfif carrierLinksOnClick NEQ ''>disabled="disabled"</cfif> tabindex="#evaluate(currentTab++)#" data-stop="#stopNumber#"/>
            <img style="display: none;" width="25" class="spinner#stopNumber#" src="images/spinner.gif">
            <input name="selectedCarrier#stopNumber#ValueContainer" id="selectedCarrierValue#stopNumber#ValueContainer" type="hidden" />
            <div class="clear"></div>
            <div class="clear"></div>
          </div>
          <div id="CarrierInfo#stopNumber#" style="<cfif len(carrierIDNext) gt 0>display:block<cfelse>display:none</cfif>;">
            <div class="clear"></div>
            <div class="clear"></div>
            <label>&nbsp;</label>
            <label class="field-textarea" tabindex="#evaluate(currentTab++)#"><b><a href=""></a></b><br/>
            </label>
            <div class="clear"></div>
            <label>Tel</label>
            <label class="field-text" tabindex="#evaluate(currentTab++)#"></label>
            <div class="clear"></div>
            <label>Cell</label>
            <label class="field-text" tabindex="#evaluate(currentTab++)#"></label>
            <div class="clear"></div>
            <label>Fax</label>
            <label class="field-text" tabindex="#evaluate(currentTab++)#"></label>
            <div class="clear"></div>
            <label>Email</label>
            <label class="field-text" tabindex="#evaluate(currentTab++)#"></label>
          </div>
          <label style="width: 102px !important;">Satellite Office</label>
          <select name="stOffice#stopNumber#" id="stOffice#stopNumber#" tabindex="#evaluate(currentTab++)#">
          <option value="">Choose a Satellite Office Contact</option>
          <cfloop query="request.qOffices">
            <option value="#request.qOffices.CarrierOfficeID#" <cfif stofficeidNext is request.qOffices.CarrierOfficeID>selected ="selected"</cfif>>#request.qOffices.location#</option>
          </cfloop>
          </select>
        </fieldset>
      </div>
      <div class="form-con carrierBlock#stopNumber#" style="width:400px">
        <fieldset>
      <cfif request.qSystemSetupOptions.freightBroker EQ 0 OR (request.qSystemSetupOptions.freightBroker EQ 2 AND chckdCarrier EQ 0)>
          <div style="width:195px;float:left;border: 1px solid ##b3b3b3;margin-left: -7px;margin-top: -45px;padding-top: 5px;margin-bottom: 5px;">
              <label class="carrierrightlabel" style="width: 58% !important;">Custom Driver Pay</label>
              <label class="switch switch-flat" style="padding: 0;width: 60px;height: 23px;">
                  <input class="switch-input CustomDriverPay" id="CustomDriverPay#stopNumber#" name="CustomDriverPay#stopNumber#" type="checkbox" onchange="customDriverPay(this);" />
                  <span class="switch-label" data-on="On" data-off="Off"></span> 
                  <span class="switch-handle"></span> 
              </label>
              <div class="divCustomDriverPayOptions" style="display: none">
                  <span style="float: left;width: 39%;text-align: right;font-weight: bold;">Flat Rate $
                  </span> 
                  <input type="checkbox" class="small_chk myElements chkCustomDriverPayFlatRate" style="float: left;margin-left: 5px;" id="chkCustomDriverPayFlatRate#stopNumber#" name="chkCustomDriverPayFlatRate#stopNumber#" onclick="customDriverPayOption(this)"> 
                  <span id="span_CustomDriverPayFlatRate#stopNumber#" class="span_CustomDriverPayFlatRate" style="display: none;">
                    <span style="float: left;">$</span>
                    <input type="text" style="width: 40px;margin-left: 5px;" class="customDriverPayFlatRate" id="customDriverPayFlatRate#stopNumber#" name="customDriverPayFlatRate#stopNumber#" onchange="calculateCustomDriverPay()" value="0">
                  </span>
                  <div class="clear"></div>

                  <span style="float: left;width: 39%;text-align: right;font-weight: bold;">Percentage %
                  </span> 
                  <input type="checkbox" class="small_chk myElements chkCustomDriverPayPercentage" style="float: left;margin-left: 5px;" id="chkCustomDriverPayPercentage#stopNumber#" name="chkCustomDriverPayPercentage#stopNumber#" onclick="customDriverPayOption(this)"> 
                  
                  <span id="span_CustomDriverPayPercentage#stopNumber#" class="span_CustomDriverPayPercentage" style="display: none;" >
                    <input type="text" style="width: 40px;" class="customDriverPayPercentage" id="customDriverPayPercentage#stopNumber#" name="customDriverPayPercentage#stopNumber#" onchange="calculateCustomDriverPay()" value="0">
                    <span style="float: left">%</span>
                  </span>
              </div>
          </div>
          <div class="clear"></div>
      </cfif>
			<div style="width:50%;float: left;" class="carrierrightdiv">
					<div style="width:200px;float:left;">
						<label class="carrierrightlabel">Driver 1</label>
						<input name="driver#stopNumber#" value="#driver#" type="text" tabindex="#evaluate(currentTab++)#" class="carriertextbox" maxlength="50"/>
					</div>
				<div style="width:200px;float:left;">
					<label class="carrierrightlabel">Driver Cell</label>
					<input name="driverCell#stopNumber#" value="#driverCell#" type="text" tabindex="#evaluate(currentTab++)#" class="carriertextbox" maxlength="15" onchange="ParseUSNumber(this,'Driver Cell');"/>
				</div>
				<cfif NOT (request.qSystemSetupOptions.freightBroker EQ 0 OR (request.qSystemSetupOptions.freightBroker EQ 2 AND chckdCarrier EQ 0))>
					<div style="width:200px;float:left;">
						<label class="carrierrightlabel">Driver 2</label>
						<input name="Secdriver#stopNumber#" value="#driver2#" type="text" tabindex="#evaluate(currentTab++)#" class="carriertextbox"  maxlength="50"/>
					</div>
					<div style="width:200px;float:left;">
						<label class="carrierrightlabel">Driver Cell</label>
						<input name="secDriverCell#stopNumber#" value="#secDriverCell#" type="text" tabindex="#evaluate(currentTab++)#" class="carriertextbox"  maxlength="15" onchange="ParseUSNumber(this,'Driver Cell');"/>
					</div>
				</cfif>
				<div style="width:200px;float:left;">
					<label class="carrierrightlabel">Truck ##</label>
					<input name="truckNo#stopNumber#" value="#truckNo#" type="text" tabindex="#evaluate(currentTab++)#" class="carriertextbox" maxlength="20"/>
				</div>
				<div style="width:200px;float:left;">
					<label class="carrierrightlabel">Trailer ##</label>
					<input name="TrailerNo#stopNumber#" value="#TrailerNo#" type="text" tabindex="#evaluate(currentTab++)#" class="carriertextbox"  maxlength="20"/>
				</div>
				<div style="width:200px;float:left;">
					<label class="carrierrightlabel">Ref ##</label>
					<input name="refNo#stopNumber#" value="#refNo#" type="text" tabindex="#evaluate(currentTab++)#" class="carriertextbox" maxlength="50"/>
				</div>
				<div style="width:200px;float:left;">
					<label class="carrierrightlabel">Miles ##</label>
					<input name="milse#stopNumber#" class="careermilse carriertextbox" id="milse#stopNumber#" value="#milse#" type="text" onclick="showWarningEnableButton('block','#stopNumber#');" onblur="showWarningEnableButton('none','#stopNumber#');changeQuantityWithValue(this,#stopNumber#);" onChange="changeQuantity(this.id,this.value,'unit');calculateTotalRates('#application.DSN#');" tabindex="#evaluate(currentTab++)#" style="width:81px !important;"/>
					<input id="refreshBtn#stopNumber#" title="Refresh Miles" value="" type="button" class="bttn" onclick="refreshMilesClicked('#stopNumber#');" style="width:17px; height:22px; background: url('images/refresh.png');"/>
					<input id="milesUpdateMode#stopNumber#" name="milesUpdateMode#stopNumber#" type="hidden" value="auto" >
				</div>
        <div style="width:200px;float:left;">
          <label class="carrierrightlabel">Booked With</label>
          <input name="bookedWith#stopNumber#" id="bookedWith#stopNumber#" value="#bookedwith1#" type="text" tabindex="#evaluate(currentTab++)#" class="carriertextbox" maxlength="500"/>
        </div>
			</div>
			<div style="width:50%;float: left;" class="carrierrightdiv">
				<div style="width:200px;float:left;">
					<label class="carrierrightlabel">Equipment</label>
					<select name="equipment#stopNumber#" id="equipment#stopNumber#" tabindex="#evaluate(currentTab++)#" class="carriertextbox selEquipment" style="width:116px !important;">
						<option value="">Select</option>
						<cfloop query="request.qEquipments">
							<option value="#request.qEquipments.equipmentID#" <cfif equipment1 is request.qEquipments.equipmentID> selected="selected" </cfif> data-temperature="#request.qEquipments.temperature#" data-temperaturescale="#request.qEquipments.temperaturescale#" data-type="#request.qEquipments.equipmenttype#" data-RelEquip="#request.qEquipments.RelEquip#" data-truckTrailer="#request.qEquipments.TruckTrailerOption#">#request.qEquipments.equipmentname#</option>
						</cfloop>
					</select>
				</div>
        <div style="width:200px;float:left;position: relative;">
            <label class="carrierrightlabel hyperLinkLabel#stopnumber#">Trailer</label>
            <select name="equipmentTrailer#stopNumber#" id="equipmentTrailer#stopNumber#" tabindex="#evaluate(currentTab++)#" class="carriertextbox">
                <option value="">Select</option>
                <cfloop query="request.qEquipments">
                    <cfif listFindNoCase('Trailer,Other', request.qEquipments.EquipmentType)>
                        <option value="#request.qEquipments.equipmentID#">#request.qEquipments.equipmentname#</option>
                    </cfif>
                </cfloop>
            </select>
        </div>
				<div style="width:200px;float:left;position: relative;">
                    <label style="text-align: left;width: 65px;"><strong>Temperature</strong></label>
                    <input type="text" name="temperature#stopNumber#" id="temperature#stopNumber#" value="" size="4" maxlength="5" validate="float"  style="width:40px" message="Please  enter the valid Temperature">
                    <label style="width: 5px;margin-top: -5px;margin-left: -5px;"><sup>o</sup></label>
                    <cfif request.qSystemSetupOptions.TemperatureSetting EQ 0>
                        <select name="temperaturescale#stopNumber#" id="temperaturescal#stopNumber#e" style="width:35px;">
                            <option value="C">C</option>
                            <option value="F">F</option>
                        </select>
                    <cfelseif request.qSystemSetupOptions.TemperatureSetting EQ 1>
                        F<input type="hidden" name="temperaturescale#stopNumber#" value="F">
                    <cfelse>
                        C<input type="hidden" name="temperaturescale#stopNumber#" value="C">
                    </cfif>
                </div>
				<div style="width:200px;float:left;">
					<label class="carrierrightlabel">#request.qSystemSetupOptions.userDef1#</label>
					<input name="userDef1#stopNumber#" value="#request.LoadStopInfoShipper.userDef1#" type="text" tabindex="#evaluate(currentTab++)#" class="carriertextbox"/>
				</div>
				<div style="width:200px;float:left;">
					<label class="carrierrightlabel">#request.qSystemSetupOptions.userDef2#</label>
					<input name="userDef2#stopNumber#" value="#request.LoadStopInfoShipper.userDef2#" type="text" tabindex="#evaluate(currentTab++)#" class="carriertextbox"/>
				</div>
				<div style="width:200px;float:left;">
					<label class="carrierrightlabel">#request.qSystemSetupOptions.userDef3#</label>
					<input name="userDef3#stopNumber#" value="#request.LoadStopInfoShipper.userDef3#" type="text" tabindex="#evaluate(currentTab++)#" class="carriertextbox"  maxlength="200"/>
				</div>
				<div style="width:200px;float:left;">
					<label class="carrierrightlabel">#request.qSystemSetupOptions.userDef4#</label>
					<input name="userDef4#stopNumber#" value="#request.LoadStopInfoShipper.userDef4#" type="text" tabindex="#evaluate(currentTab++)#" class="carriertextbox"  maxlength="200"/>

				</div>
				<div style="width:200px;float:left;">
					<label class="carrierrightlabel">#request.qSystemSetupOptions.userDef5#</label>
					<input name="userDef5#stopNumber#" value="#request.LoadStopInfoShipper.userDef5#" type="text" tabindex="#evaluate(currentTab++)#" class="carriertextbox"  maxlength="200"/>

				</div>
				<div style="width:200px;float:left;">
					<label class="carrierrightlabel">#request.qSystemSetupOptions.userDef6#</label>
					<input name="userDef6#stopNumber#" value="#request.LoadStopInfoShipper.userDef6#" type="text" tabindex="#evaluate(currentTab++)#" class="carriertextbox"  maxlength="200"/>

				</div>
			</div>
			
			<div class="clear"></div>
          <div id="warning#stopNumber#" class="msg-area" style="display:none; width:180px;">Warning!! Mannual Miles change has disabled automatic miles update on address change for Stop#stopNumber#. After changing an address use <b>Recalculate Miles</b> button to calculate miles again.</div>
        </fieldset>
      </div>
            </div>

        <cfif request.qSystemSetupOptions.freightBroker EQ 0 OR (request.qSystemSetupOptions.freightBroker EQ 2 AND chckdCarrier EQ 0)>
            <div id="carriertabs-#stopNumber#-carrier2">
                <div class="white-con-area" style="background-color: ##defaf9;">
                    <div class="fa fa-minus-circle PlusToggleButton" onclick="showHideCarrierBlock(this,1);" style="position:relative;margin-left: 0;margin-top: 10px"></div>
                    <div class="pg-title-carrier" style="float: left; width: 35%;padding-left:10px;font-weight:bold;font-size: 15px;">
                        <h2 style="font-weight:bold;">Driver</h2>
                    </div>
                </div>

                <div class="form-heading-carrier carrierBlock1">
                    <div class="rt-button">
                    </div>
                    <div class="form-con" style="font-weight:bold;text-transform:uppercase;padding: 6px 10px 0 4px;">
                        <cfset carrierLinksOnClick = "">
                        <a href="javascript:void(0);" onClick="chooseCarrierNext2(#stopnumber#);"  id="removeCarrierTag2_#stopnumber#"  <cfif  structkeyexists(url,"loadid") and len(trim(url.loadid)) gt 1  AND  carrierID2_1 EQ "">style="display:none;"<cfelseif structkeyexists(url,"loadToBeCopied") and len(trim(url.loadToBeCopied)) gt 1  AND  carrierID2_1 EQ "" >style="display:none;"<cfelse>style="color:##236334;"</cfif>>
                            <img style="vertical-align:bottom;" src="images/change.png">
                            <span class="removetxt">Remove Driver</span>
                        </a>

                    </div>
                    <div class="clear"></div>
                </div>

                <div class="form-con carrierBlock1" style="width:425px">
                    <input name="carrierID2_#stopNumber#" id="carrierID2_#stopNumber#" type="hidden" value="#carrierID2_1#" />
                    <fieldset>
                        <div id="choosCarrier2_#stopNumber#" style="<cfif len(carrierID2_1) gt 0>display:none<cfelse>display:block</cfif>;"><input type="hidden" name="carrier_id2_#stopNumber#" id="carrier_id2_#stopNumber#" value="#carrierID2_1#" data-limit="<cfif trim(carrierID2_1) NEQ "">#qgetcarier.LoadLimit#</cfif>">
                        <div class="clear"></div>
                        <cfset CarrierFilter = "openCarrierFilter();">
                        <label class="LabelfreightBroker" style="width: 102px !important;">Choose Driver</label>
                        <input name="selectedCarrier2_#stopNumber#" id="selectedCarrierValue2_#stopNumber#" class="carrier-box" style="margin-left: 0;width: 230px !important;" type="text" <cfif carrierLinksOnClick NEQ ''> disabled </cfif> tabindex="#evaluate(currentTab+33)#" title="Type text here to display list." data-stop="1"/>
                        <input name="selectedCarrierValueContainer2_#stopNumber#" id="selectedCarrierValueValueContainer2_#stopNumber#" type="hidden" />
                        <div class="clear"></div>
                        <div class="clear"></div>
                        </div>
                        <div id="CarrierInfo2_#stopNumber#" style="<cfif len(carrierID2_1) gt 0>display:block<cfelse>display:none</cfif>;">

                        <cfif structkeyexists(url,"loadid") and len(trim(url.loadid)) gt 1 and url.loadid NEQ 0>
                            <cfset cLoadID=url.loadid>
                        <cfelse>
                            <cfset cLoadID=''>
                        </cfif>
                        </div>
                        <label style="width: 102px !important;">Satellite Office</label>
                        <select name="stOffice2_#stopnumber#" id="stOffice2_#stopnumber#">
                            <option value="">Choose a Satellite Office Contact</option>
                            <cfloop query="request.qOffices">
                                <option value="#request.qOffices.CarrierOfficeID#">#request.qOffices.location#</option>
                            </cfloop>
                        </select>
                    </fieldset>
                </div>

                <div class="form-con carrierBlock1" style="width:460px">
                    <fieldset>
                        <div style="width:100%" class="carrierrightdiv">
                            <cfif request.qSystemSetupOptions.freightBroker EQ 0 OR (request.qSystemSetupOptions.freightBroker EQ 2 AND chckdCarrier EQ 0)>
                                <div style="width:195px;float:left;border: 1px solid ##b3b3b3;margin-left: -7px;margin-top: -45px;padding-top: 5px;margin-bottom: 5px;">
                                    <label class="carrierrightlabel" style="width: 58% !important;">Custom Driver Pay</label>
                                    <label class="switch switch-flat" style="padding: 0;width: 60px;height: 23px;">
                                        <input class="switch-input CustomDriverPay" id="CustomDriverPay2_#stopNumber#" name="CustomDriverPay2_#stopNumber#" type="checkbox" onchange="customDriverPay(this);" />
                                        <span class="switch-label" data-on="On" data-off="Off"></span> 
                                        <span class="switch-handle"></span> 
                                    </label>
                                    <div class="divCustomDriverPayOptions" style="display: none">
                                        <span style="float: left;width: 39%;text-align: right;font-weight: bold;">Flat Rate $
                                        </span> 
                                        <input type="checkbox" class="small_chk myElements chkCustomDriverPayFlatRate" style="float: left;margin-left: 5px;" id="chkCustomDriverPayFlatRate2_#stopNumber#" name="chkCustomDriverPayFlatRate2_#stopNumber#" onclick="customDriverPayOption(this)"> 

                                        <span id="span_CustomDriverPayFlatRate2_#stopNumber#" class="span_CustomDriverPayFlatRate" style="display:none;">
                                          <span style="float: left;">$</span>
                                          <input type="text" style="width: 40px;margin-left: 5px;" class="customDriverPayFlatRate" id="customDriverPayFlatRate2_#stopNumber#" name="customDriverPayFlatRate2_#stopNumber#" onchange="calculateCustomDriverPay()" value="0">
                                        </span>

                                        <div class="clear"></div>

                                        <span style="float: left;width: 39%;text-align: right;font-weight: bold;">Percentage %
                                        </span> 
                                        <input type="checkbox" class="small_chk myElements chkCustomDriverPayPercentage" style="float: left;margin-left: 5px;" id="chkCustomDriverPayPercentage2_#stopNumber#" name="chkCustomDriverPayPercentage2_#stopNumber#" onclick="customDriverPayOption(this)"> 

                                        <span id="span_CustomDriverPayPercentage2_#stopNumber#" class="span_CustomDriverPayPercentage" style="display:none;">
                                          <input type="text" style="width: 40px;" class="customDriverPayPercentage" id="customDriverPayPercentage2_#stopNumber#" name="customDriverPayPercentage2_#stopNumber#" onchange="calculateCustomDriverPay()" value="0">
                                          <span style="float: left;">%</span>
                                        </span>
                                    </div>
                                </div>
                                <div class="clear"></div>
                            </cfif>
                            <div style="width:200px;float:left;">
                                <label class="carrierrightlabel">Driver Cell</label>
                                <input name="secDriverCell#stopNumber#" value="#secDriverCell#" type="text" tabindex="#evaluate(currentTab+35)#" class="carriertextbox" maxlength="15" onchange="ParseUSNumber(this,'Driver Cell');"/>
                            </div>
                        </div>
                    </fieldset>
                </div>
            </div>

            <div id="carriertabs-#stopNumber#-carrier3">
                <div class="white-con-area" style="background-color: ##defaf9;">
                    <div class="fa fa-minus-circle PlusToggleButton" onclick="showHideCarrierBlock(this,1);" style="position:relative;margin-left: 0;margin-top: 10px"></div>
                    <div class="pg-title-carrier" style="float: left; width: 35%;padding-left:10px;font-weight:bold;font-size: 15px;">
                        <h2 style="font-weight:bold;">Driver</h2>
                    </div>
                </div>

                <div class="form-heading-carrier carrierBlock1">
                    <div class="rt-button">
                    </div>
                    <div class="form-con" style="font-weight:bold;text-transform:uppercase;padding: 6px 10px 0 4px;">
                        <cfset carrierLinksOnClick = "">
                        <a href="javascript:void(0);" onClick="chooseCarrierNext3(#stopnumber#);"  id="removeCarrierTag3_#stopnumber#"  <cfif  structkeyexists(url,"loadid") and len(trim(url.loadid)) gt 1  AND  carrierID3_1 EQ "">style="display:none;"<cfelseif structkeyexists(url,"loadToBeCopied") and len(trim(url.loadToBeCopied)) gt 1  AND  carrierID3_1 EQ "" >style="display:none;"<cfelse>style="color:##236334;"</cfif>>
                            <img style="vertical-align:bottom;" src="images/change.png">
                            <span class="removetxt">Remove Driver</span>
                        </a>
                    </div>
                    <div class="clear"></div>
                </div>

                <div class="form-con carrierBlock1" style="width:400px">
                    <input name="carrierID3_#stopNumber#" id="carrierID3_#stopNumber#" type="hidden" value="#carrierID3_1#" />
                    <fieldset>
                        <div id="choosCarrier3_#stopNumber#" style="<cfif len(carrierID3_1) gt 0>display:none<cfelse>display:block</cfif>;"><input type="hidden" name="carrier_id3_#stopNumber#" id="carrier_id3_#stopNumber#" value="#carrierID3_1#" data-limit="<cfif trim(carrierID3_1) NEQ "">#qgetcarier.LoadLimit#</cfif>">
                        <div class="clear"></div>
                        <cfset CarrierFilter = "openCarrierFilter();">
                        <label class="LabelfreightBroker" style="width: 102px !important;">Choose Driver</label>
                        <input name="selectedCarrier3_#stopNumber#" id="selectedCarrierValue3_#stopNumber#" class="carrier-box" style="margin-left: 0;width: 230px !important;" type="text" <cfif carrierLinksOnClick NEQ ''> disabled </cfif> tabindex="#evaluate(currentTab+33)#" title="Type text here to display list." data-stop="1"/>
                        <input name="selectedCarrierValueContainer3_#stopNumber#" id="selectedCarrierValueValueContainer3_#stopNumber#" type="hidden" />
                        <div class="clear"></div>
                        <div class="clear"></div>
                        </div>
                        <div id="CarrierInfo3_#stopNumber#" style="<cfif len(carrierID3_1) gt 0>display:block<cfelse>display:none</cfif>;">

                        <cfif structkeyexists(url,"loadid") and len(trim(url.loadid)) gt 1 and url.loadid NEQ 0>
                            <cfset cLoadID=url.loadid>
                        <cfelse>
                            <cfset cLoadID=''>
                        </cfif>
                        </div>
                        <label style="width: 102px !important;">Satellite Office</label>
                        <select name="stOffice3_#stopnumber#" id="stOffice3_#stopnumber#">
                            <option value="">Choose a Satellite Office Contact</option>
                            <cfloop query="request.qOffices">
                                <option value="#request.qOffices.CarrierOfficeID#">#request.qOffices.location#</option>
                            </cfloop>
                        </select>
                    </fieldset>
                </div>

                <div class="form-con carrierBlock1" style="width:400px">
                    <fieldset>
                        <div style="width:100%" class="carrierrightdiv">
                          <cfif request.qSystemSetupOptions.freightBroker EQ 0 OR (request.qSystemSetupOptions.freightBroker EQ 2 AND chckdCarrier EQ 0)>
                                <div style="width:195px;float:left;border: 1px solid ##b3b3b3;margin-left: -7px;margin-top: -45px;padding-top: 5px;margin-bottom: 5px;">
                                    <label class="carrierrightlabel" style="width: 58% !important;">Custom Driver Pay</label>
                                    <label class="switch switch-flat" style="padding: 0;width: 60px;height: 23px;">
                                        <input class="switch-input CustomDriverPay" id="CustomDriverPay3_#stopNumber#" name="CustomDriverPay3_#stopNumber#" type="checkbox" onchange="customDriverPay(this);" />
                                        <span class="switch-label" data-on="On" data-off="Off"></span> 
                                        <span class="switch-handle"></span> 
                                    </label>
                                    <div class="divCustomDriverPayOptions" style="display: none">
                                        <span style="float: left;width: 39%;text-align: right;font-weight: bold;">Flat Rate $
                                        </span> 
                                        <input type="checkbox" class="small_chk myElements chkCustomDriverPayFlatRate" style="float: left;margin-left: 5px;" id="chkCustomDriverPayFlatRate3_#stopNumber#" name="chkCustomDriverPayFlatRate3_#stopNumber#" onclick="customDriverPayOption(this)"> 

                                        <span id="span_CustomDriverPayFlatRate3_#stopNumber#" class="span_CustomDriverPayFlatRate" style="display: none;">
                                          <span style="float: left;">$</span>
                                          <input type="text" style="width: 40px;margin-left: 5px;;" class="customDriverPayFlatRate" id="customDriverPayFlatRate3_#stopNumber#" name="customDriverPayFlatRate3_#stopNumber#" onchange="calculateCustomDriverPay()" value="0">
                                        </span>

                                        <div class="clear"></div>

                                        <span style="float: left;width: 39%;text-align: right;font-weight: bold;">Percentage %
                                        </span> 
                                        <input type="checkbox" class="small_chk myElements chkCustomDriverPayPercentage" style="float: left;margin-left: 5px;" id="chkCustomDriverPayPercentage3_#stopNumber#" name="chkCustomDriverPayPercentage3_#stopNumber#" onclick="customDriverPayOption(this)"> 
                                        <span id="span_CustomDriverPayPercentage3_#stopNumber#" class="span_CustomDriverPayPercentage" style="display: none;">
                                          <input type="text" style="width: 40px;" class="customDriverPayPercentage" id="customDriverPayPercentage3_#stopNumber#" name="customDriverPayPercentage3_#stopNumber#" onchange="calculateCustomDriverPay()" value="0">
                                          <span style="float: left;">%</span>
                                      </span>
                                    </div>
                                </div>
                                <div class="clear"></div>
                            </cfif>
                            <div style="width:200px;float:left;">
                                <label class="carrierrightlabel">Driver Cell</label>
                                <input name="thirdDriverCell#stopNumber#" value="#thirdDriverCell#" type="text" tabindex="#evaluate(currentTab+35)#" class="carriertextbox" maxlength="15" onchange="ParseUSNumber(this,'Driver Cell');"/>
                            </div>
                        </div>
                    </fieldset>
                </div>
            </div>
        </cfif>

            <cfif len(url.loadid) gt 1 AND NOT (request.qSystemSetupOptions.freightBroker EQ 0 OR (request.qSystemSetupOptions.freightBroker EQ 2 AND chckdCarrier EQ 0))>
	            <div id="carriertabs-#stopNumber#-QuoteList">
	                <div class="white-con-area" style="background-color: ##defaf9;">
	                    <h2 style="font-weight: bold;float: left;">Carrier Quote List For Load</h2>
	                    <div style="height:15px">
	                        <strong class="quoteSuccessMsg" style="color: ##2fb135;display: none;">
	                        New Quote Added Succesfully</strong>
	                    </div>
	                    <table width="100%" class="tbl_quote_list" id="tbl_quote_list_#stopNumber#">
	                        <thead style="background-color: ##4a98dc;color: ##fff;">
	                            <tr>
	                                <th>Quote Amt</th>
	                                <th>Carrier Name</th>
	                                <th>Carrier MC</th>
	                                <th>Contact</th>
	                                <th>Phone</th>
	                                <th>Active</th>
	                                <th>Mileage</th>
	                                <th>Price/Mile</th>
	                                <th>Equipment</th>
                                  <th>Created By</th>
                                  <th>Updated By</th>
	                                <th>&nbsp;</th>
	                            </tr>
	                        </thead>
	                        <tbody>
	                        	<td colspan="12" class="noQuotesMsg">No Quotes Found</td>
	                        </tbody>
	                    </table>
	                </div>
	            </div>
	            <div id="carriertabs-#stopNumber#-QuoteDetail">
	                <div class="white-con-area" style="background-color: ##defaf9;">
	                    <h2 style="font-weight: bold" class="add_quote_txt">Add Quote</h2>
	                </div>
	                <div class="form-heading-carrier">
	                    <div class="rt-button">
	                    </div>
	                    <div class="form-con" style="font-weight:bold;text-transform:uppercase;padding: 6px 10px 0 4px;">
	                        <a href="javascript:void(0);" onclick="changeCarrier(#stopNumber#);"  id="changeCarrier#stopNumber#" style="color:##236334;display:none">
	                            <img style="vertical-align:bottom;" src="images/change.png">
	                            <span class="removetxt">
	                                  <cfif request.qSystemSetupOptions.freightBroker EQ 2> 
	                                    Change   
	                                    <cfif  chckdCarrier EQ 0>
	                                            Driver
	                                        <cfelseif  chckdCarrier EQ 1>
	                                            Carrier
	                                        <cfelse>
	                                            Carrier/Driver
	                                        </cfif>
	                                    <cfelse>
	                                        Change #variables.freightBroker#
	                                    </cfif>
	                            </span>
	                        </a>
	                    </div>
	                    <div class="clear"></div>
	                </div>
	                <div class="form-con" style="width:400px">
	                    <fieldset>
	                        <div id="chooseQuoteCarrier#stopNumber#">
	                            <div class="clear"></div>
	                            <label style="width: 102px !important;">Choose Carrier</label>
	                            <input class="quote-carrier-box" id="quote-carrier-box#stopNumber#" data-stop="#stopNumber#" style="margin-left: 0;width: 230px !important;" type="text" title="Type text here to display list."/>
	                            <input type="hidden" id="CarrierQuoteID" value="0" name="CarrierQuoteID#stopNumber#">
	                            <input type="hidden" id="valueContainer" name="quoteCarrierID#stopNumber#">
	                            <input type="hidden" id="carrierName">
	                            <input type="hidden" id="carrierMCNumber">
	                            <input type="hidden" id="carrierContactPerson">
	                            <input type="hidden" id="carrierPhoneNo">
	                            <input type="hidden" id="carrierActive">
	                        </div>
	                        <div id="quoteCarrierInfo#stopNumber#">
	                        </div>
	                    </fieldset>
	                </div>
	                <div class="form-con" style="width:400px">
	                    <fieldset>
	                            <div style="width:100%" class="carrierrightdiv">
	                                <div style="width:200px;float:left;">
	                                    <label class="carrierrightlabel">Amount</label>
	                                    <input id="quoteAmount#stopNumber#" value="$0.00" type="text" class="carriertextbox myElements" name="quoteAmount#stopNumber#">
	                                </div>
	                                <div style="width:200px;float:left;">
	                                    <label class="carrierrightlabel">Equipment</label>
	                                    <select id="quoteEquipment#stopNumber#" name="quoteEquipment#stopNumber#" class="carriertextbox myElements" style="width: 116px !important;">
	                                        <option value="">Select</option>
	                                        <cfloop query="request.qEquipments">
	                                            <option value="#request.qEquipments.equipmentID#">#request.qEquipments.equipmentname#</option>
	                                        </cfloop>
	                                    </select>
	                                </div>
	                            </div>
	                            <div class="clear"></div>

	                            <div style="width:100%" class="carrierrightdiv">
	                                <div style="width:200px;float:left;">
	                                    <label class="carrierrightlabel">Truck##</label>
	                                    <input id="quoteTruckNo#stopNumber#" name="quoteTruckNo#stopNumber#" value="" type="text" class="carriertextbox myElements">
	                                </div>
	                                <div style="width:200px;float:left;position: relative;">
	                                    <label class="carrierrightlabel">Fuel Surcharge</label>
	                                    <input id="quoteFuelSurcharge#stopNumber#" name="quoteFuelSurcharge#stopNumber#" value="" type="text" class="carriertextbox myElements">
	                                </div>
	                            </div>
	                            <div class="clear"></div>

	                            <div style="width:100%" class="carrierrightdiv">
	                                <div style="width:200px;float:left;">
	                                    <label class="carrierrightlabel">Trailer##</label>
	                                    <input id="quoteTrailerNo#stopNumber#" name="quoteTrailerNo#stopNumber#" value="" type="text" class="carriertextbox myElements">
	                                </div>
	                                <div style="width:200px;float:left;position: relative;">
	                                    <label class="carrierrightlabel">Container##</label>
	                                    <input id="quoteContainerNo#stopNumber#" name="quoteContainerNo#stopNumber#" value="" type="text" class="carriertextbox myElements">
	                                </div>
	                            </div>
	                            <div class="clear"></div>

	                            <div style="width:100%" class="carrierrightdiv">
	                                <div style="width:200px;float:left;">
	                                    <label class="carrierrightlabel">Ref##</label>
	                                    <input id="quoteRefNo#stopNumber#" name="quoteRefNo#stopNumber#" value="" type="text" class="carriertextbox myElements">
	                                </div>
	                                <div style="width:200px;float:left;position: relative;">
	                                    <label class="carrierrightlabel">Carr Ref##</label>
	                                    <input id="quoteCarrRefNo#stopNumber#" name="quoteCarrRefNo#stopNumber#" value="" type="text" class="carriertextbox myElements">
	                                </div>
	                            </div>
	                            <div class="clear"></div>

	                            <div style="width:100%" class="carrierrightdiv">
	                                <div style="width:200px;float:left;">
	                                    <label class="carrierrightlabel">Miles##</label>
	                                    <input id="quoteMiles#stopNumber#" name="quoteMiles#stopNumber#" value="0" type="text" class="carriertextbox myElements">
	                                </div>
	                            </div>
	                            <div class="clear"></div>
                                <div style="width:100%" class="carrierrightdiv">
                                    <div style="width:400px;float:left;position: relative;">
                                        <label class="carrierrightlabel">Comments</label>
                                        <textarea id="quotecomments#stopNumber#" name="quotecomments#stopNumber#" style="width: 310px;height: 75px;"></textarea>
                                    </div>
                                </div>
	                            <div class="clear"></div>
	                            <div style="width:100%" class="carrierrightdiv">
	                                <div style="width:200px;float:right;">
	                                    <input type="button" onclick ="saveQuote(#stopNumber#)" value="Save Quote">
	                                </div>
	                            </div>
	                        </fieldset>
	                </div>
	            </div>
	        </cfif>
        </div>
      <div class="clear"></div>
      <div class="carrier-gap">&nbsp;</div>
      <div class="clear"></div>
      <div class="commodityToggle#stopNumber#">
      <div class="white-con-area" style="height: 36px;background-color: ##82bbef;width: 932px;">
                        <div style="padding: 0 18px;overflow:hidden;">
                            <h2 onclick="window.open('index.cfm?event=unit&#session.URLToken#', '_blank');" style="color:white;font-weight:bold;float: left;cursor: pointer;">Commodities and Accessorials Table</h2>
                        </div>
                    </div>
<div class="carrier-mid" style="width: 932px">
    <table width="100%" class="noh carrierCalTable" border="0" cellspacing="0" cellpadding="0" id="commodity_#stopNumber#">
        <thead>
            <tr>
                <th width="5" align="right" valign="top">
                    <img src="images/top-left.gif" alt="" width="5" height="23" />
                </th>
                <th align="right" valign="middle" class="head-bg">Fee</th>
                <th align="right" valign="middle" class="head-bg">Qty</th>
                <th align="left" valign="middle" class="head-bg textalign">Type</th>
                <th align="left" valign="middle" class="head-bg">Description</th>
                <th align="left" valign="middle" class="head-bg">Dimensions</th>
                <cfif request.qSystemSetupOptions.commodityWeight>
                    <th align="right" valign="middle" class="head-bg">Wt(lbs)</th>
                </cfif>

                <th align="right" valign="middle" class="head-bg"><a style="text-decoration: underline;color:##4322cc;" href="index.cfm?event=class&#session.URLToken#">Class</a></th>

                <cfif NOT ListContains(session.rightsList,'HideCustomerPricing',',')>
                    <th align="right" valign="middle" class="head-bg">Cust. Rate</th>
                </cfif>
                                
                <th align="right" valign="middle" class="head-bg textalign">#variables.freightBrokerShortForm#. Rate</th>

                <cfif NOT ListContains(session.rightsList,'HideCustomerPricing',',')>
                    <th align="right" valign="middle" class="head-bg textalign">
                        % of Total
                    </th>
                </cfif>

                <cfif request.qSystemSetupOptions.UseDirectCost>
                    <th align="right" valign="middle" class="head-bg textalign">Direct Cost</th>
                </cfif>

                <cfif NOT ListContains(session.rightsList,'HideCustomerPricing',',')>
                    <th align="right" valign="middle" class="head-bg textalign">Cust. Total</th>
                </cfif>

                <th align="right" valign="middle" class="head-bg textalign">#variables.freightBrokerShortForm#. Total</th>

                <cfif request.qSystemSetupOptions.UseDirectCost>
                    <th align="right" valign="middle" class="head-bg textalign">D.Cost Total</th>
                </cfif>

                <th align="right" valign="middle" class="head-bg2 textalign" style="width:40px;"></th>
                <th width="5" align="right" valign="top">
                    <img src="images/top-right.gif" alt="" width="5" height="23" />
                </th>
            </tr>
        </thead>
        
        <cfset descriptionWidth = 510>
        <cfif request.qSystemSetupOptions.commodityWeight>
            <cfset descriptionWidth = descriptionWidth-58>
        </cfif>
        <cfif NOT ListContains(session.rightsList,'HideCustomerPricing',',')>
            <cfset descriptionWidth = descriptionWidth-192>
        </cfif>
        <cfif request.qSystemSetupOptions.UseDirectCost>
            <cfset descriptionWidth = descriptionWidth-130>
        </cfif>

        <tbody class="commRows">
            <cfif  loadIDN neq "" and showItems is true>
                <cfloop query="request.qItems">
                    <tr <cfif request.qItems.currentRow mod 2 eq 0>bgcolor="##FFFFFF"<cfelse>  bgcolor="##f7f7f7"</cfif> id="commodities#stopNumber#_#request.qItems.currentRow#">
                        <td height="20" class="lft-bg">&nbsp;</td>
                        <td class="lft-bg2" valign="middle" align="center">
                            <input name="isFee#stopNumber#_#request.qItems.currentRow#" id="isFee#stopNumber#_#request.qItems.currentRow#" class="check isFee" <cfif request.qItems.fee is 1> checked="checked" </cfif> type="checkbox" tabindex="#evaluate(currentTab+1)#"/>
                        </td>
                        <td class="normaltdC" valign="middle" align="left">
                            <input name="qty#stopNumber#_#request.qItems.currentRow#" id="qty#stopNumber#_#request.qItems.currentRow#" onchange="CalculateTotal('#Application.dsn#')" class="qty q-textbox" type="text" value="#request.qItems.qty#"  tabindex="#evaluate(currentTab+1)#"/>
                        </td>
                        <td class="normaltdC" valign="middle" align="left">
                            <select name="unit#stopNumber#_#request.qItems.currentRow#" id="unit#stopNumber#_#request.qItems.currentRow#" class="t-select unit typeSelect#stopNumber#" onchange="changeQuantityWithtype(this,'#stopNumber#');checkForFee(this.value,'#request.qItems.currentRow#','#stopNumber#','#application.dsn#')" tabindex="#evaluate(currentTab+1)#">
                                <option value=""></option>
                                <cfloop query="request.qUnits">
                                    <option value="#request.qUnits.unitID#" <cfif request.qUnits.unitID is request.qItems.unitid> selected="selected" </cfif>>#request.qUnits.unitName#<cfif trim(request.qUnits.unitCode) neq ''>(#request.qUnits.unitCode#)</cfif>
                                    </option>
                                </cfloop>
                            </select>
                        </td>
                        <td class="normaltdC" valign="middle" align="left">
                            <input name="description#stopNumber#_#request.qItems.currentRow#" id="description#stopNumber#_#request.qItems.currentRow#" class="t-textbox" value="#request.qItems.description#" type="text" tabindex="#evaluate(currentTab+1)#" style="width:#descriptionWidth#px;"/>
                        </td>
				        <cfif request.qSystemSetupOptions.commodityWeight>
                            <td class="normaltdC" valign="middle" align="left">
                                <input name="weight#stopNumber#_#request.qItems.currentRow#" id="weight#stopNumber#_#request.qItems.currentRow#" class="wt-textbox" value="#request.qItems.weight#" type="text" tabindex="#evaluate(currentTab+1)#" />
                            </td>
				        </cfif>
                        <td class="normaltdC" valign="middle" align="left">
                            <select name="class#stopNumber#_#request.qItems.currentRow#" id="class#stopNumber#_#request.qItems.currentRow#" class="t-select" tabindex="#evaluate(currentTab++)#" style="width:60px;" >
                                <option></option>
                                <cfloop query="request.qClasses">
                                    <option value="#request.qClasses.classId#" <cfif request.qClasses.classId is request.qItems.classid> selected="selected" </cfif>>#request.qClasses.className#</option>
                                </cfloop> 
                            </select>
                        </td>
				        <cfset variables.CustomerRate = request.qItems.CUSTRATE >
                        <cfset variables.CarrierRate = request.qItems.CARRRATE >
                        <cfif request.qItems.CUSTRATE eq ""><cfset variables.CustomerRate = '0.00' ></cfif>
                        <cfif request.qItems.CARRRATE eq ""><cfset variables.CarrierRate = '0.00' ></cfif>
                        <cfset variables.carrierPercentage = 0 >
				        <cfif isdefined("request.qItems.CarrRateOfCustTotal") and IsNumeric(request.qItems.CarrRateOfCustTotal)>
                            <cfset variables.carrierPercentage = request.qItems.CarrRateOfCustTotal >
				        </cfif>

                        <cfif NOT ListContains(session.rightsList,'HideCustomerPricing',',')>
                            <td class="normaltdC" valign="middle" align="left">
                                <input name="CustomerRate#stopNumber#_#request.qItems.currentRow#" id="CustomerRate#stopNumber#_#request.qItems.currentRow#" onChange="CalculateTotal('#Application.dsn#');" class="q-textbox CustomerRate" <cfif request.qSystemSetupOptions.ForeignCurrencyEnabled>value="#(variables.CustomerRate)#"<cfelse>value="#DollarFormat(variables.CustomerRate)#"</cfif>  type="text" tabindex="#evaluate(currentTab++)#"/>
                            </td>
					    <cfelse>
                            <input name="CustomerRate#stopNumber#_#request.qItems.currentRow#" id="CustomerRate#stopNumber#_#request.qItems.currentRow#" <cfif request.qSystemSetupOptions.ForeignCurrencyEnabled>value="#(variables.CustomerRate)#"<cfelse>value="#DollarFormat(variables.CustomerRate)#"</cfif>  type="hidden"/>
                        </cfif>
                        <td class="normaltd2C" valign="middle" align="left">
                            <input name="CarrierRate#stopNumber#_#request.qItems.currentRow#" id="CarrierRate#stopNumber#_#request.qItems.currentRow#" onChange="CalculateTotal('#Application.dsn#');formatDollar(this.value, this.id);" class="q-textbox CarrierRate" <cfif request.qSystemSetupOptions.ForeignCurrencyEnabled>value="#(variables.CarrierRate)#"<cfelse>value="#DollarFormat(variables.CarrierRate)#"</cfif>  type="text" tabindex="#evaluate(currentTab+1)#" />
                        </td>

				        <cfif NOT ListContains(session.rightsList,'HideCustomerPricing',',')>
                            <td class="normaltd2C" valign="middle" align="left">
                                <input  onChange="ConfirmMessage('#request.qItems.currentRow#',#stopNumber#)" name="CarrierPer#stopNumber#_#request.qItems.currentRow#" id="CarrierPer#stopNumber#_#request.qItems.currentRow#" class="q-textbox CarrierPer" value="#variables.carrierPercentage#%" onChange=""  type="text" tabindex="#evaluate(currentTab+1)#" />
                            </td>
				        <cfelse>    
                            <input name="CarrierPer#stopNumber#_#request.qItems.currentRow#" id="CarrierPer#stopNumber#_#request.qItems.currentRow#"  value="#variables.carrierPercentage#%" type="hidden"/>
				        </cfif>

                        <cfif request.qSystemSetupOptions.UseDirectCost>
                            <td class="normaltdC" valign="middle" align="left">
                                <input name="directCost#stopNumber#_#request.qItems.currentRow#" id="directCost#stopNumber#_#request.qItems.currentRow#" class="q-textbox directCost" value="$0.00" type="text" onChange="CalculateTotal('#Application.dsn#');formatDollarNegative(this.value, this.id);" tabindex="#evaluate(currentTab+1)#"/>
                            </td>
                        <cfelse>
                            <input name="directCost#stopNumber#_#request.qItems.currentRow#" id="directCost#stopNumber#_#request.qItems.currentRow#" value="$0.00" type="hidden"  />
                        </cfif>

                        <cfif NOT ListContains(session.rightsList,'HideCustomerPricing',',')>
                            <td class="normaltdC" valign="middle" align="left">
                                <input name="custCharges#stopNumber#_#request.qItems.currentRow#" id="custCharges#stopNumber#_#request.qItems.currentRow#" onchange="CalculateTotal('#Application.dsn#');" class="custCharges q-textbox" value="#request.qItems.custCharges#" type="text"  />
                            </td>
                        <cfelse>
                            <input name="custCharges#stopNumber#_#request.qItems.currentRow#" id="custCharges#stopNumber#_#request.qItems.currentRow#" value="#request.qItems.custCharges#" type="hidden" />
                        </cfif>

                        <td class="normaltd2C" valign="middle" align="left">
                            <input name="carrCharges#stopNumber#_#request.qItems.currentRow#" id="carrCharges#stopNumber#_#request.qItems.currentRow#" onchange="CalculateTotal('#Application.dsn#');" class="carrCharges q-textbox" value="#request.qItems.carrCharges#" type="text"  />
                        </td>

                        <cfif request.qSystemSetupOptions.UseDirectCost>
                            <td class="normaltdC" valign="middle" align="left">
                                <input name="directCostTotal#stopNumber#_#request.qItems.currentRow#" id="directCostTotal#stopNumber#_#request.qItems.currentRow#" class="q-textbox directCostTotal" value="$0.00" type="text" readonly style="background-color: ##e3e3e3;width: 60px;" />
                            </td>
                        <cfelse>
                            <input name="directCostTotal#stopNumber#_#request.qItems.currentRow#" id="directCostTotal#stopNumber#_#request.qItems.currentRow#" value="$0.00" type="hidden" />
                        </cfif>

                        <td class="normal-td3C normal-td3">&nbsp;</td>
                    </tr>
                </cfloop>
            <cfelse>
                <cfloop from ="1" to="1" index="rowNum">
                    <tr <cfif rowNum mod 2 eq 0>bgcolor="##FFFFFF"<cfelse>  bgcolor="##f7f7f7"</cfif> >
                        <td height="20" class="lft-bg">&nbsp;</td>
                        <td class="lft-bg2" valign="middle" align="center">
                            <input name="isFee#stopNumber#_#rowNum#" id="isFee#stopNumber#_#rowNum#" class="isFee check" type="checkbox" tabindex="#evaluate(currentTab+1)#"/>
                        </td>
                        <td class="normaltdC" valign="middle" align="left">
                            <input name="qty#stopNumber#_#rowNum#" id="qty#stopNumber#_#rowNum#" onChange="CalculateTotal('#Application.dsn#')" value="1" class="qty q-textbox" type="text"  tabindex="#evaluate(currentTab+1)#"/>
                        </td>
                        <td class="normaltdC" valign="middle" align="left">
                            <select name="unit#stopNumber#_#rowNum#" id="unit#stopNumber#_#rowNum#" class="unit t-select typeSelect#stopNumber#" onchange="changeQuantityWithtype(this,'#stopNumber#');checkForFee(this.value,'#rowNum#','#stopNumber#','#application.dsn#'); autoloaddescription(this, '#stopNumber#', '1','#application.dsn#');" tabindex="#evaluate(currentTab+1)#" >
                                <option value=""></option>
                                <cfloop query="request.qUnits">
                                    <option value="#request.qUnits.unitID#">#request.qUnits.unitName#<cfif trim(request.qUnits.unitCode) neq ''>(#request.qUnits.unitCode#)</cfif></option>
                                </cfloop>
                            </select>
                        </td>
                        <td class="normaltdC" valign="middle" align="left">
                            <input name="description#stopNumber#_#rowNum#" id="description#stopNumber#_#rowNum#" class="t-textbox" type="text" tabindex="#evaluate(currentTab+1)#" style="width:#descriptionwidth#px;"/>
                        </td>
                        <td class="normaltdC" valign="middle" align="left">
                            <input name="dimensions#stopNumber#_#rowNum#" id="dimensions#stopNumber#_#rowNum#" class="t-textbox" type="text" tabindex="#evaluate(currentTab+1)#" maxlength="150" style="width:58px;"/>
                        </td>
				        <cfif request.qSystemSetupOptions.commodityWeight>
    						<td class="normaltdC" valign="middle" align="left">
                                <input name="weight#stopNumber#_#rowNum#" id="weight#stopNumber#_#rowNum#" class="wt-textbox" type="text" tabindex="#evaluate(currentTab+1)#"/>
                            </td>
    					</cfif>
                        <td class="normaltdC" valign="middle" align="left">
                            <select name="class#stopNumber#_#rowNum#" id="class#stopNumber#_#rowNum#" class="t-select" tabindex="#evaluate(currentTab+1)#" style="width:60px;">
                                <option value=""></option>
                                <cfloop query="request.qClasses">
                                    <option value="#request.qClasses.classId#">#request.qClasses.className#</option>
                                </cfloop>
                            </select>
                        </td>
				        <cfset variables.carrierPercentage = 0>
				        <cfif IsDefined("request.qItems.CarrRateOfCustTotal") and IsNumeric(request.qItems.CarrRateOfCustTotal)>
                            <cfset variables.carrierPercentage = request.qItems.CarrRateOfCustTotal>
				        </cfif>
		
                        <cfif NOT ListContains(session.rightsList,'HideCustomerPricing',',')>
                            <td class="normaltdC" valign="middle" align="left">
                                <input name="CustomerRate#stopNumber#_#rowNum#" id="CustomerRate#stopNumber#_#rowNum#" tabindex="#evaluate(currentTab+1)#" onChange="CalculateTotal('#Application.dsn#');" class="CustomerRate q-textbox"  type="text"  <cfif request.qSystemSetupOptions.ForeignCurrencyEnabled>value="0.00"<cfelse>value="$0.00"</cfif> />
                            </td>
					    <cfelse>
                            <input name="CustomerRate#stopNumber#_#rowNum#" id="CustomerRate#stopNumber#_#rowNum#" type="hidden" <cfif request.qSystemSetupOptions.ForeignCurrencyEnabled>value="0.00"<cfelse>value="$0.00"</cfif> />
					    </cfif>
                        <td class="normaltd2C" valign="middle" align="left">
                            <input name="CarrierRate#stopNumber#_#rowNum#" id="CarrierRate#stopNumber#_#rowNum#" tabindex="#evaluate(currentTab+1)#"  onChange="CalculateTotal('#Application.dsn#');" class="CarrierRate q-textbox"  type="text" <cfif request.qSystemSetupOptions.ForeignCurrencyEnabled>value="0.00"<cfelse>value="$0.00"</cfif>/>
                        </td>
				
                        <cfif NOT ListContains(session.rightsList,'HideCustomerPricing',',')>
				            <td class="normaltd2C" valign="middle" align="left">
                                <input name="CarrierPer#stopNumber#_#rowNum#" id="CarrierPer#stopNumber#_#rowNum#"  class="q-textbox CarrierPer" value="0.00%" onChange="ConfirmMessage('#rowNum#',#stopNumber#)"  type="text" tabindex="#evaluate(currentTab+1)#" />
                            </td>
				        <cfelse>
                            <input name="CarrierPer#stopNumber#_#rowNum#" id="CarrierPer#stopNumber#_#rowNum#" value="0.00%"  type="hidden" />
				 	        
				        </cfif>

                        <cfif request.qSystemSetupOptions.UseDirectCost>
                            <td class="normaltdC" valign="middle" align="left">
                                <input name="directCost#stopNumber#_#rowNum#" id="directCost#stopNumber#_#rowNum#" class="q-textbox directCost" type="text" value="$0.00" onChange="CalculateTotal('#Application.dsn#');formatDollarNegative(this.value, this.id);"  tabindex="#evaluate(currentTab+1)#" />
                            </td>
                        <cfelse>
                            <input name="directCost#rowNum##stopNumber#" id="directCost#stopNumber#_#rowNum#"  type="hidden" value="$0.00"/>
                        </cfif>

                        <cfif NOT ListContains(session.rightsList,'HideCustomerPricing',',')>
                            <td class="normaltdC" valign="middle" align="left">
                                <input name="custCharges#rowNum##stopNumber#" id="custCharges#stopNumber#_#rowNum#" onchange="CalculateTotal('#Application.dsn#');" class="custCharges q-textbox" type="text" value="$0.00" readonly style="background-color: ##e3e3e3;"/>
                            </td>
                        <cfelse>
                            <input name="custCharges#rowNum##stopNumber#" id="custCharges#stopNumber#_#rowNum#" type="hidden" value="$0.00" />
                        </cfif>

                        <td class="normaltd2C" valign="middle" align="left">
                            <input name="carrCharges#stopNumber#_#rowNum#" id="carrCharges#stopNumber#_#rowNum#" onchange="CalculateTotal('#Application.dsn#');" class="carrCharges q-textbox" type="text"  value="$0.00" readonly  style="background-color: ##e3e3e3;"/>
                        </td>

                        <cfif request.qSystemSetupOptions.UseDirectCost>
                            <td class="normaltdC" valign="middle" align="left">
                                <input name="directCostTotal#rowNum##stopNumber#" id="directCostTotal#stopNumber#_#rowNum#" class="q-textbox directCostTotal" type="text" value="$0.00" readonly  style="background-color: ##e3e3e3;width:60px;"/>
                            </td>
                        <cfelse>
                            <input name="directCostTotal#rowNum##stopNumber#" id="directCostTotal#stopNumber#_#rowNum#" type="hidden" value="$0.00"/>
                        </cfif>

                        <td class="normaltdC" valign="middle" align="left">
                            <img name="delComm#stopNumber#_#rowNum#" id="delComm#stopNumber#_#rowNum#" src="images/delete-icon-red.gif" style="width:10px;margin-left: 5px;cursor: pointer;float:left" onclick="delRowCommodities(this)" >
                  	        <img name="sortComm#stopNumber#_#rowNum#" id="sortComm#stopNumber#_#rowNum#" src="images/sort.png" style="width:12px;margin-left: 5px;cursor: pointer">
                  	        <input type="hidden" name="commStopId#stopNumber#_#rowNum#" id="commStopId#stopNumber#_#rowNum#" value="0">
                            <input type="hidden" name="commSrNo#stopNumber#_#rowNum#" id="commSrNo#stopNumber#_#rowNum#" value="0">
                        </td>
                        <td class="normal-td3C normal-td3">&nbsp;</td>
                        
                    </tr>
                
                </cfloop>
            </cfif>
        </tbody>
        <tfoot>
        	<cfif  loadIDN neq "" and showItems is true>
                <input type="hidden" value="#request.qItems.recordcount#" name="TotalrowCommodities#stopNumber#"  id="TotalrowCommodities#stopNumber#">
                <input type="hidden" value="#request.qItems.recordcount#" name="totalResult#stopNumber#"  id="totalResult#stopNumber#">
                <input type="hidden" value="#request.qItems.recordcount#" name="commoditityAlreadyCount#stopNumber#"  id="commoditityAlreadyCount#stopNumber#">
        	<cfelse>
				<input type="hidden" value="1" name="TotalrowCommodities#stopNumber#"  id="TotalrowCommodities#stopNumber#">
                <input type="hidden" value="1" name="totalResult#stopNumber#"  id="totalResult#stopNumber#">
                <input type="hidden" value="1" name="commoditityAlreadyCount#stopNumber#"  id="commoditityAlreadyCount#stopNumber#">
        	</cfif>
            <tr>
                <td width="5" align="left" valign="top">
                    <img src="images/left-bot.gif" alt="" width="5" height="23" />
                </td>
                <td <cfif request.qSystemSetupOptions.commodityWeight> colspan="6" <cfelse>  colspan="5"</cfif> align="left" valign="middle" class="footer-bg"></td>

                <td width="5" align="right" valign="top" class="footer-bg"></td>
                <cfif NOT ListContains(session.rightsList,'HideCustomerPricing',',')>
                    <td width="5" align="right" valign="top" class="footer-bg customerCurrencyISO"></td>
                </cfif>
                <td width="5" align="right" valign="top" class="footer-bg carrierCurrencyISO"></td>
                <cfif NOT ListContains(session.rightsList,'HideCustomerPricing',',')>
                    <td width="5" align="right" valign="top" class="footer-bg"></td>
                </cfif>
                <cfif request.qSystemSetupOptions.UseDirectCost>
                    <td width="5" align="right" valign="top" class="footer-bg"></td>
                </cfif>
                <cfif NOT ListContains(session.rightsList,'HideCustomerPricing',',')>
                    <td width="5" align="right" valign="top" class="footer-bg customerCurrencyISO"></td>
                </cfif>
                <td width="5" align="right" valign="top" class="footer-bg carrierCurrencyISO"></td>
                <cfif request.qSystemSetupOptions.UseDirectCost>
                    <td width="5" align="right" valign="top" class="footer-bg"></td>
                </cfif>
                <td width="5" align="right" valign="top" class="footer-bg"></td>


                <td width="5" align="right" valign="top">
                    <img src="images/right-bot.gif" alt="" width="5" height="23" />
                </td>
            </tr>
        </tfoot>
    </table>
    <div class="clear"></div>
</div>
      <div class="addcommodityButton"><input type="button" onclick="addNewRowCommodities(this,#stopNumber#)" value="Add New Row" ></div></div>
      <div class="carrier-gap">&nbsp;</div>
	</div>

  <script type="text/javascript">
  
  function ChangeLabelStop(val,stopNumber){
		switch(val) {
            case 0: $(".LabelfreightBroker"+stopNumber).text('Choose Driver'); 					
                    $(" .removetxt"+stopNumber).text('Remove Driver'); 
					chooseCarrier();   					
                     break;
            case 1:
                    $(".LabelfreightBroker"+stopNumber).text('Choose Carrier');                    
					$(".removetxt"+stopNumber).text('Remove Carrier');  
					chooseCarrier();
                    break; 
            case 2:
                    $(".LabelfreightBroker"+stopNumber).text('Choose Carrier/Driver');					
				   $(".removetxt"+stopNumber).text('Remove Carrier/Driver'); 
				   chooseCarrier();
                    break;                
        }




		$("##LinkRemoveCarrier"+stopNumber).hide();
		 $("##LinkRemoveCarrier"+stopNumber).trigger("click");
         $("##selectedCarrierValue"+stopNumber).autocomplete({
                multiple: false,
				width: 450,
				scroll: true,
				scrollHeight: 300,
				cacheLength: 1,
				highlight: false,
				dataType: "json",
        delay:500,
				search: function(event, ui){$(this).autocomplete('option', 'source', 'searchCarrierAutoFill.cfm?queryType=getCustomers&iscarrier='+val+'&companyid=#session.companyid#&loadid=#loadid#&pickupdate=' + $("##shipperPickupDate"+(($(this).data("stop") == 1) ? "" : $(this).data("stop"))).val() + '&deliverydate=' + $("##consigneePickupDate"+(($(this).data("stop") == 1) ? "" : $(this).data("stop"))).val())},
				source: 'searchCarrierAutoFill.cfm?queryType=getCustomers&companyid=#session.companyid#&loadid=#loadid#&iscarrier='+val+'&pickupdate=',
			select: function(e, ui) {
				if(ui.item.isoverlimit == 'yes')
				{
					alert("#ReReplace(variables.freightBroker,"\b(\w)","\u\1")# has reached their daily limit for this pickup date.");
					return false;
				}

				$(this).val(ui.item.name);
				$('##'+this.id+'ValueContainer'+stopNumber).val(ui.item.value);
				var strHtml = "<div class='clear'></div>"
					strHtml = strHtml + "<div class='clear'></div>"
					strHtml = strHtml + "<label>&nbsp;</label>"
					strHtml = strHtml + "<label class='field-textarea'>"
					strHtml = strHtml + "<b>"
					<cfif ListContains(session.rightsList,'bookCarrierToLoad',',')>
						<cfif request.qSystemSetupOptions.FreightBroker EQ 1>
							strHtml = strHtml + "<a href='index.cfm?event=addcarrier&Iscarrier=1&carrierid="+ui.item.value+"' style='color:##4322cc;text-decoration:underline;'>"
						<cfelse>
							strHtml = strHtml + "<a href='index.cfm?event=adddriver&Iscarrier=0&carrierid="+ui.item.value+"' style='color:##4322cc;text-decoration:underline;'>"
						</cfif>
					<cfelse>
						strHtml = strHtml + "<a href='javascript: alert('Sorry!! You don\'t have rights to add/edit #variables.freightBroker#.'); return false;' style='color:##4322cc;text-decoration:underline;'>"
					</cfif>
					strHtml = strHtml + ui.item.name
					strHtml = strHtml + "</a>"
					strHtml = strHtml + "</b>"
					strHtml = strHtml + "<br/>"
					strHtml = strHtml + ""+ui.item.name+"<br/>"+ui.item.city+"<br/>"+ui.item.state+"&nbsp;-&nbsp;"+ui.item.zip+""
					strHtml = strHtml + "</label>"
					strHtml = strHtml + "<div class='clear'></div>"
					strHtml = strHtml + "<label>Tel</label>"
					strHtml = strHtml + "<label class='field-text'>"+ui.item.phoneNo+"</label>"
					strHtml = strHtml + "<div class='clear'></div>"
					strHtml = strHtml + "<label>Cell</label>"
					strHtml = strHtml + "<label class='field-text'>"+ui.item.cell+"</label>"
					strHtml = strHtml + "<div class='clear'></div>"
					strHtml = strHtml + "<label>Fax</label>"
					strHtml = strHtml + "<label class='field-text'>"+ui.item.fax+"</label>"
					strHtml = strHtml + "<div class='clear'></div>"
					strHtml = strHtml + "<label>Email</label>"
					strHtml = strHtml + "<label class='emailbox'>"+ui.item.email+"</label>";
				if(ui.item.iscarrier == 1 && ui.item.insuranceExpired == 'yes')
				{
					alert("Warning!! This #variables.freightBroker# has expired insurance, please make sure this carrier's insurance is updated");
					if(! (#request.qSystemSetupOptions.AllowBooking#)){
						$(this).val('');
                        return false;
					}
				}
				
				document.getElementById("CarrierInfo"+stopNumber).style.display = 'block';
				document.getElementById('choosCarrier'+stopNumber).style.display = 'none';
				DisplayIntextFieldNext(ui.item.value, stopNumber,'#Application.dsn#');
				$('##CarrierInfo'+stopNumber).html(strHtml);
				getCarrierCommodityValue(ui.item.value,"unit",stopNumber);
				$('##carrier_id' + stopNumber).data("limit", ui.item.loadLimit);
				if(ui.item.EquipmentID.trim() != ""){
          if(ui.item.eqActive.trim() == 1){
					 $("##equipment"+stopNumber).val(ui.item.EquipmentID);
          }
          else{
            alert('The default equipment assigned to this #variables.freightBroker# is inactive.');
          }
				}
				$("##LinkRemoveCarrier"+stopNumber).show();
				return false;
			}
            });
           
  }
  
$(function() {

	function format(mail) {
		return mail.name + "<br/><b><u>Address</u>:</b> " + mail.location+"&nbsp;&nbsp;&nbsp;<b><u>City</u>:</b>" + mail.city+"&nbsp;&nbsp;&nbsp;<b><u>State</u>:</b> " + mail.state+"<br><b><u>Zip</u>:</b> " + mail.zip;
	}

	function Cityformat(mail)
		{
			return mail.city + "<br/><b><u>State</u>:</b> " + mail.state+"&nbsp;&nbsp;&nbsp;<b><u>Zip</u>:</b> " + mail.zip;
		}

		function Zipformat(mail)
		{
			return mail.zip + "<br/><b><u>State</u>:</b> " + mail.state+"&nbsp;&nbsp;&nbsp;<b><u>City</u>:</b> " + mail.city;
		}

	// Shippper DropBox
	$("##shipper#stopNumber#, ##consignee#stopNumber#").each(function(i, tag) {
		$(tag).autocomplete({
			multiple: false,
			width: 400,
			scroll: true,
			scrollHeight: 300,
			cacheLength: 1,
			highlight: false,
			dataType: "json",
			autoFocus: true,
			source: 'searchCustomersAutoFill.cfm?queryType=getShippers&CompanyID=#session.CompanyID#&stoptype='+this.id,
			select: function(e, ui) {
        $(this).removeClass('hyperLinkLabelStop');
				$(this).val(ui.item.name);
				$(this).parent().find('.updateCreateAlert').val(ui.item.isPayer);
				var controlType = '';
				if(this.id.substring(0, 4) == 'ship')
					controlType = 'shipper';
				else
					controlType = 'consignee';
				if(ui.item.value != "NA"){
					$('##'+controlType+'ValueContainer#stopNumber#').val(ui.item.value);
          $(this).attr("onclick","openCustomerPopup('"+ui.item.value+"',this);");
          $(this).addClass('hyperLinkLabelStop');
				}
				$('##'+controlType+'Name#stopNumber#').val(ui.item.name);
				$('##'+controlType+'NameText#stopNumber#').val(ui.item.name);
				$('##'+controlType+'location#stopNumber#').val(ui.item.location);
				$('##'+controlType+'city#stopNumber#').val(ui.item.city);
				$('##'+controlType+'Zipcode#stopNumber#').val(ui.item.zip);
				$('##'+controlType+'ContactPerson#stopNumber#').val(ui.item.contactPerson);
				$('##'+controlType+'Phone#stopNumber#').val(ui.item.phoneNo);
				$('##'+controlType+'PhoneExt#stopNumber#').val(ui.item.phoneNoExt);
				$('##'+controlType+'Fax#stopNumber#').val(ui.item.fax);
				$('##'+controlType+'state#stopNumber#').val(ui.item.state);
				$('##'+controlType+'StateName#stopNumber#').val(ui.item.state);
				$('##'+controlType+'Email#stopNumber#').val(ui.item.email);
        $('##'+controlType+'Notes#stopNumber#').val(ui.item.notes);
				<cfif request.qSystemSetupOptions.timezone>
					$('##'+controlType+'TimeZone#stopNumber#').val(ui.item.timezone);
				</cfif>
				addressChanged('#stopNumber#');
				var stopNum ="";
				var customerType ="";
				var idText = $(this).attr('id');

				 if(idText.indexOf("shipper")!=-1)
				{
					customerType= 'shipper';
					idText = idText.split("shipper");
				}
				else if(idText.indexOf("consignee")!=-1)
				{
					customerType= 'consignee';
					var idText = idText.split("consignee");
				}

				stopNum =idText[1];
				showChangeAlert(customerType,stopNum);
				return false;
			}
		});
		$(tag).data("ui-autocomplete")._renderItem = function(ul, item) {
			return $( "<li>"+item.name+"<br/><b><u>Address</u>:</b> "+ item.location+"&nbsp;&nbsp;&nbsp;<b><u>City</u>:</b>" + item.city+"&nbsp;&nbsp;&nbsp;<b><u>State</u>:</b> " + item.state+"<br/><b><u>Zip</u>:</b> " + item.zip+"</li>" )
					.appendTo( ul );
		}
	});


	//City Shippper City
	$("##shippercity#stopNumber#, ##consigneecity#stopNumber#").each(function(i, tag) {
		$(tag).autocomplete({
			multiple: false,
			width: 400,
			scroll: true,
			scrollHeight: 300,
			cacheLength: 1,
			highlight: false,
			dataType: "json",
      autoFocus: true,
			source: 'searchCustomersAutoFill.cfm?queryType=getCity&CompanyID=#session.CompanyID#',
			select: function(e, ui) {
				$(this).val(ui.item.city);
				strId = this.id;
				initialStr = strId.substr(0, 7);
				if(initialStr != 'shipper') {
					initialStr = 'consignee';
				}

        if($("##"+initialStr+"state#stopNumber# option[value='"+ui.item.state+"']").length){
				  $('##'+initialStr+'state#stopNumber#').val(ui.item.state);
        }
        else{
          $('##'+initialStr+'state#stopNumber#').val('');
        }
				$('##'+initialStr+'StateName#stopNumber#').val(ui.item.state);
				$('##'+initialStr+'Zipcode#stopNumber#').val(ui.item.zip);
				return false;
			}
		});
		$(tag).data("ui-autocomplete")._renderItem = function(ul, item) {
			return $( "<li>"+item.city+"<br/><b><u>State</u>:</b> "+ item.state+"&nbsp;&nbsp;&nbsp;<b><u>Zip</u>:</b>" + item.zip+"</li>" )
					.appendTo( ul );
		}
	});


	//zip AutoComplete
	$("##shipperZipcode#stopNumber#, ##consigneeZipcode#stopNumber#").each(function(i, tag) {
		$(tag).autocomplete({
			multiple: false,
			width: 400,
			scroll: true,
			scrollHeight: 300,
			cacheLength: 1,
			minLength: 1,
			highlight: false,
			dataType: "json",
      autoFocus: true,
			source: 'searchCustomersAutoFill.cfm?queryType=GetZip&CompanyID=#session.CompanyID#',
			select: function(e, ui) {
				$(this).val(ui.item.zip);
				strId = this.id;
				zipCodeVal=$('##'+strId).val();
				//auto complete the state and city based on first 5 characters of zip code
				if(zipCodeVal.length == 5)
				{
					initialStr = strId.substr(0, 7);
					if(initialStr != 'shipper')
						initialStr = 'consignee';
					//Donot update a field if there is already a value entered
					if($('##'+initialStr+'state#stopNumber#').val() == '')
					{

            if($("##"+initialStr+"state#stopNumber# option[value='"+ui.item.state+"']").length){
						  $('##'+initialStr+'state#stopNumber#').val(ui.item.state);
            }
            else{
              $('##'+initialStr+'state#stopNumber#').val("");
            }
						$('##'+initialStr+'StateName#stopNumber#').val(ui.item.state);
					}

					if($('##'+initialStr+'city#stopNumber#').val() == '')
					{
						$('##'+initialStr+'city#stopNumber#').val(ui.item.city);
					}
					addressChanged(#stopNumber#,'ajaxpage');
				}
				return false;
			}
		});
		$(tag).data("ui-autocomplete")._renderItem = function(ul, item) {
			return $( "<li>"+item.zip+"<br/><b><u>State</u>:</b> "+ item.state+"&nbsp;&nbsp;&nbsp;<b><u>City</u>:</b>" + item.city+"</li>" )
					.appendTo( ul );
		}

	});
	
	

	function formatCarrier#stopNumber#(mail) {
		return mail.name + "<br/><b><u>City</u>:</b> " + mail.city+"&nbsp;&nbsp;&nbsp;<b><u>State</u>:</b> " + mail.state+"&nbsp;&nbsp;&nbsp;<b><u>Zip</u>:</b> " + mail.zip+"&nbsp;&nbsp;&nbsp;<b><u>Insurance Expiry</u>:</b> " + mail.InsExpDate;
	}
	
	$('##quote-carrier-box#stopNumber#').each(function(i, tag) {
        $(tag).autocomplete({
            multiple: false,
            width: 450,
            scroll: true,
            scrollHeight: 300,
            cacheLength: 1,
            highlight: false,
            dataType: "json",
            autoFocus: true,
            response: function(event, ui) {
                var stop = $(this).data("stop");
                var tempID = $('##chooseQuoteCarrier'+stop+' ##valueContainer').val();

                if(ui.content.length == 0 && !tempID.length){
                    if(confirm('There is no matching carrier found in our system. Would you like to enter a quote from an unknown carrier?')){
                        
                        var strHtml = "<div class='clear'></div>";
                        strHtml = strHtml + "<label>MC ##</label>";
                        strHtml = strHtml + "<input type='text' id='QMCNo_"+stop+"'  value='' class='inp83px'>";
                        strHtml = strHtml + "<label class='label40px'>DOT ##</label>";
                        strHtml = strHtml + "<input type='text' id='QDotNo_"+stop+"'  value='' class='inp83px'>";
                        strHtml = strHtml + "<div class='clear'></div>";

                        strHtml = strHtml + "<label>Contact</label>";
                        strHtml = strHtml + "<input type='text' id='QContact_"+stop+"' value='' class='inp83px'>";
                        strHtml = strHtml + "<label class='label40px'>Cell</label>";
                        strHtml = strHtml + "<input type='text' id='QCell_"+stop+"' value='' class='inp83px' onchange='ParseUSNumber(this);'>";
                        strHtml = strHtml + "<div class='clear'></div>";

                        strHtml = strHtml + "<label>Phone</label>";
                        strHtml = strHtml + "<input type='text' id='QPhone_"+stop+"' value='' class='inp83px' onchange='ParseUSNumber(this);'>";
                        strHtml = strHtml + "<label class='label40px'>Ext</label>";
                        strHtml = strHtml + "<input type='text' id='QExt_"+stop+"' value='' class='inp83px'>";
                        strHtml = strHtml + "<div class='clear'></div>";

                        strHtml = strHtml + "<label>Email</label>";
                        strHtml = strHtml + "<input type='text' id='QEmail_"+stop+"' style='width:230px;' value=''>";
                        strHtml = strHtml + "<div class='clear'></div>";

                        document.getElementById("quoteCarrierInfo"+stop).style.display = 'block';
                        $('##quoteCarrierInfo'+stop).html(strHtml);
                        $('##chooseQuoteCarrier'+stop+' ##valueContainer').val('0');

                    }
                }
            },
            search: function(event, ui){$(this).autocomplete('option', 'source', 'searchCarrierAutoFill.cfm?queryType=getCustomers&companyid=#session.companyid#&loadid=#loadid#&pickupdate=' + $("##shipperPickupDate"+(($(this).data("stop") == 1) ? "" : $(this).data("stop"))).val() + '&deliverydate=' + $("##consigneePickupDate"+(($(this).data("stop") == 1) ? "" : $(this).data("stop"))).val())},
            source: 'searchCarrierAutoFill.cfm?queryType=getCustomers&companyid=#session.companyid#&loadid=#loadid#&pickupdate=',
            select: function(e, ui) { 
                var stop = $(this).data("stop");
                if(ui.item.isoverlimit == 'yes')
                {
                    alert("#ReReplace(variables.freightBroker,"\b(\w)","\u\1")# has reached their daily limit for this pickup date.");
                    return false;
                }
                $(this).val(ui.item.name);
                $('##chooseQuoteCarrier'+stop+' ##valueContainer').val(ui.item.value);
                $('##chooseQuoteCarrier'+stop+' ##carrierName').val(ui.item.name);
                $('##chooseQuoteCarrier'+stop+' ##carrierMCNumber').val(ui.item.MCNumber);
                $('##chooseQuoteCarrier'+stop+' ##carrierContactPerson').val(ui.item.ContactPerson);
                $('##chooseQuoteCarrier'+stop+' ##carrierPhoneNo').val(ui.item.phoneNo);
                if(ui.item.Status == 'ACTIVE'){
                    $('##chooseQuoteCarrier'+stop+' ##carrierActive').val('Yes');
                }
                else{
                    $('##chooseQuoteCarrier'+stop+' ##carrierActive').val('No');
                }
                var strHtml = "<div class='clear'></div>"
                strHtml = strHtml + "<div class='clear'></div>"
                if(ui.item.risk_assessment != ""){
                    strHtml = strHtml + "<label><a target='_blank' href='"+ui.item.link+"'><img src='"+ui.item.risk_assessment+"' alt='Risk Assement Icon'></a></label>"
                }else{
                    strHtml = strHtml + "<label>&nbsp;</label>"
                }
                strHtml = strHtml + "<label class='field-textarea'>"
                strHtml = strHtml + "<b>"

                <cfset Iscarrier = "">
                <cfif structkeyexists(request,"qLoads") AND structkeyexists(request.qLoads,"Iscarrier") AND request.qLoads.Iscarrier NEQ "" >
                     <cfset Iscarrier = "&Iscarrier=#request.qLoads.Iscarrier#">
                </cfif>


                <cfif ListContains(session.rightsList,'bookCarrierToLoad',',')>
                    <cfif request.qSystemSetupOptions.FreightBroker EQ 1>
                        strHtml = strHtml + "<a href='index.cfm?event=addcarrier&#Iscarrier#&carrierid="+ui.item.value+"' style='color:##4322cc;text-decoration:underline;'>"
                    <cfelseif request.qSystemSetupOptions.FreightBroker EQ 2>
                        if(ui.item.iscarrier == 1){
                            strHtml = strHtml + "<a href='index.cfm?event=addcarrier&Iscarrier=1&carrierid="+ui.item.value+"' style='color:##4322cc;text-decoration:underline;'>"
                        }else{
                            strHtml = strHtml + "<a href='index.cfm?event=adddriver&&Iscarrier=0&carrierid="+ui.item.value+"' style='color:##4322cc;text-decoration:underline;'>"
                        }
                    <cfelse>
                          strHtml = strHtml + "<a href='index.cfm?event=adddriver&#Iscarrier#&carrierid="+ui.item.value+"' style='color:##4322cc;text-decoration:underline;'>"
                    </cfif>
                <cfelse>
                    strHtml = strHtml + "<a href='javascript: alert('Sorry!! You don\'t have rights to add/edit #variables.freightBroker#.'); return false;' style='color:##4322cc;text-decoration:underline;'>"
                </cfif>
                strHtml = strHtml + ui.item.name
                strHtml = strHtml + "</a>"
                strHtml = strHtml + "</b>"
                strHtml = strHtml + "<br/>"
                strHtml = strHtml + ""+ui.item.name+"<br/>"+ui.item.city+"<br/>"+ui.item.state+"&nbsp;-&nbsp;"+ui.item.zip+""
                strHtml = strHtml + "</label>"
                strHtml = strHtml + "<div class='clear'></div>"
                strHtml = strHtml + "<label>Tel</label>"
                strHtml = strHtml + "<label class='cellnum-text'>"+ui.item.phoneNo+"</label>"
                strHtml = strHtml + "<label class='space_load'>Cell</label>"
                strHtml = strHtml + "<label class='cellnum-text'>"+ui.item.cell+"</label>"
                strHtml = strHtml + "<div class='clear'></div>"
                strHtml = strHtml + "<label>Fax</label>"
                strHtml = strHtml + "<label class='field-text'>"+ui.item.fax+"</label>"
                strHtml = strHtml + "<div class='clear'></div>"
                strHtml = strHtml + "<label>Email</label>"
                strHtml = strHtml + "<label class='emailbox'>"+ui.item.email+"</label>";
                if(ui.item.status == 'INACTIVE'){
                    alert('#variables.freightBroker# is Inactive.');
                    changeCarrier(stop);
                    return false;
                }

                if(ui.item.insuranceExpired == 'yes')
                {
                    alert('One or more of the #variables.freightBroker#s insurances has an expiration date prior to the final delivery of this load.')
                }

                document.getElementById("quoteCarrierInfo"+stop).style.display = 'block';
                document.getElementById('chooseQuoteCarrier'+stop).style.display = 'none';

                DisplayIntextField(ui.item.value,'#Application.dsn#');
                $('##quoteCarrierInfo'+stop).html(strHtml);
                $('##changeCarrier'+stop).show();
                return false;
            }

        });
        $(tag).data("ui-autocomplete")._renderItem = function(ul, item) {
            //console.log(item);
            if(item.risk_assessment != ""){
                var url = "<a target='_blank' href='"+item.link+"'><img src='"+item.risk_assessment+"' alt='Risk Assement Icon'></a>";
            }else{
                var url = "";
            }

            return $( "<li>"+item.name+"&nbsp;&nbsp;&nbsp;<b><u>Status</u>:</b> "+ item.status+"&nbsp;&nbsp;&nbsp;"+url+"<br/><b><u>City</u>:</b> "+ item.city+"&nbsp;&nbsp;&nbsp;<b><u>State</u>:</b>" + item.state+"&nbsp;&nbsp;&nbsp;<b><u>Zip</u>:</b> " + item.zip+"&nbsp;&nbsp;&nbsp;<b><u>Insurance Expiry</u>:</b> " + item.InsExpDate+"</li>" )
                    .appendTo( ul );
        }
    })

    $('##selectedCarrierValue#stopNumber#').keyup(function(){
        $('.spinner#stopNumber#').show();
        if(!$.trim($(this).val()).length){
           $('.spinner#stopNumber#').hide(); 
        }
    });
	// Customer TropBox
	$("##selectedCarrierValue#stopNumber#").each(function(i, tag) {
		$(tag).autocomplete({
			multiple: false,
			width: 450,
			scroll: true,
			scrollHeight: 300,
			cacheLength: 1,
			highlight: false,
			dataType: "json",
      autoFocus: true,
			search: function(event, ui){$(this).autocomplete('option', 'source', 'searchCarrierAutoFill.cfm?queryType=getCustomers&companyid=#session.companyid#&loadid=#loadid#&pickupdate=' + $("##shipperPickupDate"+(($(this).data("stop") == 1) ? "" : $(this).data("stop"))).val() + '&deliverydate=' + $("##consigneePickupDate"+(($(this).data("stop") == 1) ? "" : $(this).data("stop"))).val())},
			source: 'searchCarrierAutoFill.cfm?queryType=getCustomers&companyid=#session.companyid#&loadid=#loadid#&pickupdate=',

        response:function(event, ui){
                $('.spinner#stopNumber#').hide();
            },
			select: function(e, ui) {
				if(ui.item.isoverlimit == 'yes')
				{
					alert("#ReReplace(variables.freightBroker,"\b(\w)","\u\1")# has reached their daily limit for this pickup date.");
					return false;
				}

				$(this).val(ui.item.name);
				$('##'+this.id+'ValueContainer#stopNumber#').val(ui.item.value);
				var strHtml = "<div class='clear'></div>"
					/*strHtml = strHtml + "<input name='carrierID#stopNumber#' id='carrierID#stopNumber#' type='hidden' value='"+ui.item.value+"' />"*/
					strHtml = strHtml + "<div class='clear'></div>"
					strHtml = strHtml + "<label>&nbsp;</label>"
					strHtml = strHtml + "<label class='field-textarea carrier-field-textarea'>"
					strHtml = strHtml + "<b>"
					<cfif ListContains(session.rightsList,'bookCarrierToLoad',',')>
						<cfif request.qSystemSetupOptions.FreightBroker EQ 1>
							strHtml = strHtml + "<a href='index.cfm?event=addcarrier&Iscarrier=1&carrierid="+ui.item.value+"' style='color:##4322cc;text-decoration:underline;'>"
						<cfelse>
							strHtml = strHtml + "<a href='index.cfm?event=adddriver&Iscarrier=0&carrierid="+ui.item.value+"' style='color:##4322cc;text-decoration:underline;'>"
						</cfif>
					<cfelse>
						strHtml = strHtml + "<a href='javascript: alert('Sorry!! You don\'t have rights to add/edit #variables.freightBroker#.'); return false;' style='color:##4322cc;text-decoration:underline;'>"
					</cfif>
					strHtml = strHtml + ui.item.name
					strHtml = strHtml + "</a>"
					strHtml = strHtml + "</b>"
					strHtml = strHtml + "<br/>"
					strHtml = strHtml + ""+ui.item.location+"<br/>"+ui.item.city+",&nbsp;"+ui.item.state+"&nbsp;"+ui.item.zip+"<br><br><a class='underline'>MC##:</a>"+ui.item.MCNumber+"&nbsp;&nbsp;<a class='underline'>DOT##:<a>"+ui.item.DOTNumber+"&nbsp;&nbsp;<a class='underline'>SCAC##:<a>"+ui.item.SCAC+""
					strHtml = strHtml + "</label>"

					strHtml = strHtml + "<div class='clear'></div>"
          strHtml = strHtml + "<label>Contact</label>"
          strHtml = strHtml + "<input data-carrID='"+ui.item.value+"' class='CarrierContactAuto' value='"+ui.item.ContactPerson+"' placeholder='type text here to display list'>";
          strHtml = strHtml + "<input type='hidden' name='CarrierContactID#stopNumber#' id='CarrierContactID#stopNumber#' value=''>";
          strHtml = strHtml + "<input style='width: 20px !important;height: 18px;padding: 0;' type='button' value='...' onclick='openViewCarrierContactPopup(this)'>";
          strHtml = strHtml + "<div class='clear'></div>"
          strHtml = strHtml + "<label>Email</label>"
          strHtml = strHtml + "<input name='CarrierEmailID#stopNumber#' id='CarrierEmailID#stopNumber#' data-carrID='"+ui.item.value+"' class='emailbox CarrEmail' value="+ui.item.email+">";
          strHtml = strHtml + "<div class='clear'></div>"
          strHtml = strHtml + "<label>Phone</label>"
          strHtml = strHtml + "<input type='text' name='CarrierPhoneNo#stopNumber#' id='CarrierPhoneNo#stopNumber#' value='"+ui.item.phoneNo+"' class='inp70px' onchange='ParseUSNumber(this);'>"
          strHtml = strHtml + "<input type='text' name='CarrierPhoneNoExt#stopNumber#' id='CarrierPhoneNoExt#stopNumber#' value='"+ui.item.phoneext+"' class='inp18px'>"
          strHtml = strHtml + "<label class='label45px'>Fax</label>"
          strHtml = strHtml + "<input type='text' name='CarrierFax#stopNumber#' id='CarrierFax#stopNumber#' value='"+ui.item.fax+"' class='inp70px' onchange='ParseUSNumber(this);'>"
          strHtml = strHtml + "<input type='text' name='CarrierFaxExt#stopNumber#' id='CarrierFaxExt#stopNumber#' value='"+ui.item.faxext+"' class='inp18px'>"
          strHtml = strHtml + "<div class='clear'></div>"
          strHtml = strHtml + "<label>Toll Free</label>"
          strHtml = strHtml + "<input type='text' name='CarrierTollFree#stopNumber#' id='CarrierTollFree#stopNumber#' value='"+ui.item.tollfree+"' class='inp70px' onchange='ParseUSNumber(this);'>"
          strHtml = strHtml + "<input type='text' name='CarrierTollFreeExt#stopNumber#' id='CarrierTollFreeExt#stopNumber#' value='"+ui.item.tollfreeext+"' class='inp18px'>"
          strHtml = strHtml + "<label class='label45px'>Cell</label>"
          strHtml = strHtml + "<input type='text' name='CarrierCell#stopNumber#' id='CarrierCell#stopNumber#' value='"+ui.item.cell+"' class='inp70px' onchange='ParseUSNumber(this);'>"
          strHtml = strHtml + "<input type='text' name='CarrierCellExt#stopNumber#' id='CarrierCellExt#stopNumber#' value='"+ui.item.cellphoneext+"' class='inp18px'>"
          if($.trim(ui.item.RemitName).length){
            strHtml = strHtml + "<div class='clear'></div>";
            strHtml = strHtml + '<label style="width: 102px !important;">Factoring Co.</label>';
            strHtml = strHtml + '<label class="field-text disabledLoadInputs" style="width:273px !important">'+ui.item.RemitName+'</label>';
          }

				if(ui.item.iscarrier == 1 &&  ui.item.insuranceExpired == 'yes')
				{
					alert("Warning!! This #variables.freightBroker# has expired insurance, please make sure this carrier's insurance is updated.");
					if(! (#request.qSystemSetupOptions.AllowBooking#)){
						$(this).val('');
                        return false;
					}

				}
				
				document.getElementById("CarrierInfo#stopNumber#").style.display = 'block';
				document.getElementById('choosCarrier#stopNumber#').style.display = 'none';
				DisplayIntextFieldNext(ui.item.value, '#stopNumber#','#Application.dsn#');
				$('##CarrierInfo#stopNumber#').html(strHtml);
				$('.CarrEmail').each(function(i, tag) {
                    var carrID = $( this ).data( "carrid" );
                    $(tag).autocomplete({
                        multiple: false,
                        width: 450,
                        scroll: true,
                        scrollHeight: 300,
                        cacheLength: 1,
                        highlight: false,
                        dataType: "json",
                        minLength:0,
                        autoFocus: true,
                        source: 'searchCarrierContactAutoFill.cfm?carrierID='+carrID,
                        select: function(e, ui) { 
                           $('##CarrierPhoneNo#stopNumber#').val(ui.item.phoneno);
                            $('##CarrierPhoneNoExt#stopNumber#').val(ui.item.phonenoext);
                            $('##CarrierFax#stopNumber#').val(ui.item.fax);
                            $('##CarrierFaxExt#stopNumber#').val(ui.item.faxext);
                            $('##CarrierTollFree#stopNumber#').val(ui.item.tollfree);
                            $('##CarrierTollFreeExt#stopNumber#').val(ui.item.tollfreeext);
                            $('##CarrierCell#stopNumber#').val(ui.item.PersonMobileNo);
                            $('##CarrierCellExt#stopNumber#').val(ui.item.MobileNoExt);
                        },
                    }).focus(function() { 
			        	$(this).keydown();
			        })
                    $(tag).data("ui-autocomplete")._renderItem = function(ul, item) {
                        return $( "<li><b><u>Email</u>:</b> "+item.email+"<br/><b><u>Contact</u>:</b> "+ item.ContactPerson+"&nbsp;&nbsp;&nbsp;<b><u>Phone</u>:</b> "+ item.phoneno+"<br/><b><u>cell</u>:</b> " + item.PersonMobileNo+"&nbsp;&nbsp;&nbsp;<b><u>Type</u>:</b> " + item.ContactType+"</li>" )
                    .appendTo( ul );
                    }
                })
        CarrierContactAutoComplete();
        DriverContactAutoComplete('#stopNumber#');
				getCarrierCommodityValue(ui.item.value,"unit",#stopNumber#);
				$('##carrier_id' + #stopNumber#).data("limit", ui.item.loadLimit);
				if(ui.item.EquipmentID.trim() != ""){
          if(ui.item.eqActive.trim() == 1){
					 $("##equipment#stopNumber#").val(ui.item.EquipmentID);
          }
          else{
            alert('The default equipment assigned to this #variables.freightBroker# is inactive.');
          }
				}
				$("##LinkRemoveCarrier#stopNumber#").show();
				return false;
			}
		});
		$(tag).data("ui-autocomplete")._renderItem = function(ul, item) {
			return $( "<li>"+item.name+"<br/><b><u>City</u>:</b> "+ item.city+"&nbsp;&nbsp;&nbsp;<b><u>State</u>:</b>" + item.state+"&nbsp;&nbsp;&nbsp;<b><u>Zip</u>:</b> " + item.zip+"&nbsp;&nbsp;&nbsp;<b><u>Insurance Expiry</u>:</b> " + item.InsExpDate+"</li>" )
					.appendTo( ul );
		}

	});


	$("##selectedCarrierValue2_#stopNumber#").each(function(i, tag) {
		$(tag).autocomplete({
			multiple: false,
			width: 450,
			scroll: true,
			scrollHeight: 300,
			cacheLength: 1,
			highlight: false,
			dataType: "json",
      autoFocus: true,
			search: function(event, ui){$(this).autocomplete('option', 'source', 'searchCarrierAutoFill.cfm?queryType=getCustomers&iscarrier=0&companyid=#session.companyid#&loadid=#loadid#&pickupdate=' + $("##shipperPickupDate"+(($(this).data("stop") == 1) ? "" : $(this).data("stop"))).val() + '&deliverydate=' + $("##consigneePickupDate"+(($(this).data("stop") == 1) ? "" : $(this).data("stop"))).val())},
			source: 'searchCarrierAutoFill.cfm?queryType=getCustomers&iscarrier=0&companyid=#session.companyid#&loadid=#loadid#&pickupdate=',
			select: function(e, ui) {
				if(ui.item.isoverlimit == 'yes')
				{
					alert("#ReReplace(variables.freightBroker,"\b(\w)","\u\1")# has reached their daily limit for this pickup date.");
					return false;
				}

				$(this).val(ui.item.name);
				$('##selectedCarrierValueValueContainer2_#stopNumber#').val(ui.item.value);
				var strHtml = "<div class='clear'></div>"
					strHtml = strHtml + "<div class='clear'></div>"
					strHtml = strHtml + "<label>&nbsp;</label>"
					strHtml = strHtml + "<label class='field-textarea carrier-field-textarea'>"
					strHtml = strHtml + "<b>"
					<cfif ListContains(session.rightsList,'bookCarrierToLoad',',')>
						<cfif request.qSystemSetupOptions.FreightBroker EQ 1>
							strHtml = strHtml + "<a href='index.cfm?event=addcarrier&Iscarrier=1&carrierid="+ui.item.value+"' style='color:##4322cc;text-decoration:underline;'>"
						<cfelse>
							strHtml = strHtml + "<a href='index.cfm?event=adddriver&Iscarrier=0&carrierid="+ui.item.value+"' style='color:##4322cc;text-decoration:underline;'>"
						</cfif>
					<cfelse>
						strHtml = strHtml + "<a href='javascript: alert('Sorry!! You don\'t have rights to add/edit #variables.freightBroker#.'); return false;' style='color:##4322cc;text-decoration:underline;'>"
					</cfif>
					strHtml = strHtml + ui.item.name
					strHtml = strHtml + "</a>"
					strHtml = strHtml + "</b>"
					strHtml = strHtml + "<br/>"
					strHtml = strHtml + ""+ui.item.location+"<br/>"+ui.item.city+",&nbsp;"+ui.item.state+"&nbsp;"+ui.item.zip+"<br><br><a class='underline'>MC##:</a>"+ui.item.MCNumber+"&nbsp;&nbsp;<a class='underline'>DOT##:<a>"+ui.item.DOTNumber+"&nbsp;&nbsp;<a class='underline'>SCAC##:<a>"+ui.item.SCAC+""
					strHtml = strHtml + "</label>"
					strHtml = strHtml + "<div class='clear'></div>"
          strHtml = strHtml + "<label>Contact</label>"
          strHtml = strHtml + "<input data-carrID='"+ui.item.value+"' class='CarrierContactAuto' value='' placeholder='type text here to display list'>";
                    strHtml = strHtml + "<input type='hidden' name='CarrierContactID2_#stopNumber#' id='CarrierContactID2_#stopNumber#' value=''>";
          strHtml = strHtml + "<div class='clear'></div>"
          strHtml = strHtml + "<label>Email</label>"
          strHtml = strHtml + "<input name='CarrierEmailID2_#stopNumber#' id='CarrierEmailID2_#stopNumber#' data-carrID='"+ui.item.value+"' class='emailbox CarrEmail' value="+ui.item.email+">";
          strHtml = strHtml + "<div class='clear'></div>"
          strHtml = strHtml + "<label>Phone</label>"
          strHtml = strHtml + "<input type='text' name='CarrierPhoneNo2_#stopNumber#' id='CarrierPhoneNo2_#stopNumber#' value='"+ui.item.phoneNo+"' class='inp70px' onchange='ParseUSNumber(this);'>"
          strHtml = strHtml + "<input type='text' name='CarrierPhoneNoExt2_#stopNumber#' id='CarrierPhoneNoExt2_#stopNumber#' value='"+ui.item.phoneext+"' class='inp18px'>"
          strHtml = strHtml + "<label class='label45px'>Fax</label>"
          strHtml = strHtml + "<input type='text' name='CarrierFax2_#stopNumber#' id='CarrierFax2_#stopNumber#' value='"+ui.item.fax+"' class='inp70px' onchange='ParseUSNumber(this);'>"
          strHtml = strHtml + "<input type='text' name='CarrierFaxExt2_#stopNumber#' id='CarrierFaxExt2_#stopNumber#' value='"+ui.item.faxext+"' class='inp18px'>"
          strHtml = strHtml + "<div class='clear'></div>"
          strHtml = strHtml + "<label>Toll Free</label>"
          strHtml = strHtml + "<input type='text' name='CarrierTollFree2_#stopNumber#' id='CarrierTollFree2_#stopNumber#' value='"+ui.item.tollfree+"' class='inp70px' onchange='ParseUSNumber(this);'>"
          strHtml = strHtml + "<input type='text' name='CarrierTollFreeExt2_#stopNumber#' id='CarrierTollFreeExt2_#stopNumber#' value='"+ui.item.tollfreeext+"' class='inp18px'>"
          strHtml = strHtml + "<label class='label45px'>Cell</label>"
          strHtml = strHtml + "<input type='text' name='CarrierCell2_#stopNumber#' id='CarrierCell2_#stopNumber#' value='"+ui.item.cell+"' class='inp70px' onchange='ParseUSNumber(this);'>"
          strHtml = strHtml + "<input type='text' name='CarrierCellExt2_#stopNumber#' id='CarrierCellExt2_#stopNumber#' value='"+ui.item.cellphoneext+"' class='inp18px'>"
          
				if(ui.item.iscarrier == 1 &&  ui.item.insuranceExpired == 'yes')
				{
					alert("Warning!! This #variables.freightBroker# has expired insurance, please make sure this carrier's insurance is updated.");
					if(! (#request.qSystemSetupOptions.AllowBooking#)){
						$(this).val('');
                        return false;
					}

				}
				document.getElementById("CarrierInfo2_#stopNumber#").style.display = 'block';
				document.getElementById('choosCarrier2_#stopNumber#').style.display = 'none';
				document.getElementById("carrierID2_#stopNumber#").value = ui.item.value;
				$('##CarrierInfo2_#stopNumber#').html(strHtml);
        CarrierContactAutoComplete();
				$('.CarrEmail').each(function(i, tag) {
                    var carrID = $( this ).data( "carrid" );
                    $(tag).autocomplete({
                        multiple: false,
                        width: 450,
                        scroll: true,
                        scrollHeight: 300,
                        cacheLength: 1,
                        highlight: false,
                        dataType: "json",
                        minLength:0,
                        autoFocus: true,
                        source: 'searchCarrierContactAutoFill.cfm?carrierID='+carrID,
                        select: function(e, ui) {
                          $('##CarrierPhoneNo2_#stopNumber#').val(ui.item.phoneno);
                          $('##CarrierPhoneNoExt2_#stopNumber#').val(ui.item.phonenoext);
                          $('##CarrierFax2_#stopNumber#').val(ui.item.fax);
                          $('##CarrierFaxExt2_#stopNumber#').val(ui.item.faxext);
                          $('##CarrierTollFree2_#stopNumber#').val(ui.item.tollfree);
                          $('##CarrierTollFreeExt2_#stopNumber#').val(ui.item.tollfreeext);
                          $('##CarrierCell2_#stopNumber#').val(ui.item.PersonMobileNo);
                          $('##CarrierCellExt2_#stopNumber#').val(ui.item.MobileNoExt);

                        },
                    }).focus(function() { 
			        	$(this).keydown();
			        })
                    $(tag).data("ui-autocomplete")._renderItem = function(ul, item) {
                        return $( "<li><b><u>Email</u>:</b> "+item.email+"<br/><b><u>Contact</u>:</b> "+ item.ContactPerson+"&nbsp;&nbsp;&nbsp;<b><u>Phone</u>:</b> "+ item.phoneno+"<br/><b><u>cell</u>:</b> " + item.PersonMobileNo+"&nbsp;&nbsp;&nbsp;<b><u>Type</u>:</b> " + item.ContactType+"</li>" )
                    .appendTo( ul );
                    }
                })
				return false;
			}
		});
		$(tag).data("ui-autocomplete")._renderItem = function(ul, item) {
			return $( "<li>"+item.name+"<br/><b><u>City</u>:</b> "+ item.city+"&nbsp;&nbsp;&nbsp;<b><u>State</u>:</b>" + item.state+"&nbsp;&nbsp;&nbsp;<b><u>Zip</u>:</b> " + item.zip+"&nbsp;&nbsp;&nbsp;<b><u>Insurance Expiry</u>:</b> " + item.InsExpDate+"</li>" )
					.appendTo( ul );
		}

	});

	$("##selectedCarrierValue3_#stopNumber#").each(function(i, tag) {
		$(tag).autocomplete({
			multiple: false,
			width: 450,
			scroll: true,
			scrollHeight: 300,
			cacheLength: 1,
			highlight: false,
			dataType: "json",
      autoFocus: true,
			search: function(event, ui){$(this).autocomplete('option', 'source', 'searchCarrierAutoFill.cfm?queryType=getCustomers&iscarrier=0&companyid=#session.companyid#&loadid=#loadid#&pickupdate=' + $("##shipperPickupDate"+(($(this).data("stop") == 1) ? "" : $(this).data("stop"))).val() + '&deliverydate=' + $("##consigneePickupDate"+(($(this).data("stop") == 1) ? "" : $(this).data("stop"))).val())},
			source: 'searchCarrierAutoFill.cfm?queryType=getCustomers&iscarrier=0&companyid=#session.companyid#&loadid=#loadid#&pickupdate=',
			select: function(e, ui) {
				if(ui.item.isoverlimit == 'yes')
				{
					alert("#ReReplace(variables.freightBroker,"\b(\w)","\u\1")# has reached their daily limit for this pickup date.");
					return false;
				}

				$(this).val(ui.item.name);
				$('##selectedCarrierValueValueContainer3_#stopNumber#').val(ui.item.value);
				var strHtml = "<div class='clear'></div>"
					strHtml = strHtml + "<div class='clear'></div>"
					strHtml = strHtml + "<label>&nbsp;</label>"
					strHtml = strHtml + "<label class='field-textarea carrier-field-textarea'>"
					strHtml = strHtml + "<b>"
					<cfif ListContains(session.rightsList,'bookCarrierToLoad',',')>
						<cfif request.qSystemSetupOptions.FreightBroker EQ 1>
							strHtml = strHtml + "<a href='index.cfm?event=addcarrier&Iscarrier=1&carrierid="+ui.item.value+"' style='color:##4322cc;text-decoration:underline;'>"
						<cfelse>
							strHtml = strHtml + "<a href='index.cfm?event=adddriver&Iscarrier=0&carrierid="+ui.item.value+"' style='color:##4322cc;text-decoration:underline;'>"
						</cfif>
					<cfelse>
						strHtml = strHtml + "<a href='javascript: alert('Sorry!! You don\'t have rights to add/edit #variables.freightBroker#.'); return false;' style='color:##4322cc;text-decoration:underline;'>"
					</cfif>
					strHtml = strHtml + ui.item.name
					strHtml = strHtml + "</a>"
					strHtml = strHtml + "</b>"
					strHtml = strHtml + "<br/>"
					strHtml = strHtml + ""+ui.item.location+"<br/>"+ui.item.city+",&nbsp;"+ui.item.state+"&nbsp;"+ui.item.zip+"<br><br><a class='underline'>MC##:</a>"+ui.item.MCNumber+"&nbsp;&nbsp;<a class='underline'>DOT##:<a>"+ui.item.DOTNumber+"&nbsp;&nbsp;<a class='underline'>SCAC##:<a>"+ui.item.SCAC+""
					strHtml = strHtml + "</label>"
					strHtml = strHtml + "<div class='clear'></div>"
          strHtml = strHtml + "<label>Contact</label>"
          strHtml = strHtml + "<input data-carrID='"+ui.item.value+"' class='CarrierContactAuto' value='' placeholder='type text here to display list'>";
                    strHtml = strHtml + "<input type='hidden' name='CarrierContactID3_#stopNumber#' id='CarrierContactID3_#stopNumber#' value=''>";
          strHtml = strHtml + "<div class='clear'></div>"
          strHtml = strHtml + "<label>Email</label>"
          strHtml = strHtml + "<input name='CarrierEmailID3_#stopNumber#' data-carrID='"+ui.item.value+"' class='emailbox CarrEmail' value="+ui.item.email+">";
          strHtml = strHtml + "<div class='clear'></div>"
          strHtml = strHtml + "<label>Phone</label>"
          strHtml = strHtml + "<input type='text' name='CarrierPhoneNo3_#stopNumber#' id='CarrierPhoneNo3_#stopNumber#' value='"+ui.item.phoneNo+"' class='inp70px' onchange='ParseUSNumber(this);'>"
          strHtml = strHtml + "<input type='text' name='CarrierPhoneNoExt3_#stopNumber#' id='CarrierPhoneNoExt3_#stopNumber#' value='"+ui.item.phoneext+"' class='inp18px'>"
          strHtml = strHtml + "<label class='label45px'>Fax</label>"
          strHtml = strHtml + "<input type='text' name='CarrierFax3_#stopNumber#' id='CarrierFax3_#stopNumber#' value='"+ui.item.fax+"' class='inp70px' onchange='ParseUSNumber(this);'>"
          strHtml = strHtml + "<input type='text' name='CarrierFaxExt3_#stopNumber#' id='CarrierFaxExt3_#stopNumber#' value='"+ui.item.faxext+"' class='inp18px'>"
          strHtml = strHtml + "<div class='clear'></div>"
          strHtml = strHtml + "<label>Toll Free</label>"
          strHtml = strHtml + "<input type='text' name='CarrierTollFree3_#stopNumber#' id='CarrierTollFree3_#stopNumber#' value='"+ui.item.tollfree+"' class='inp70px' onchange='ParseUSNumber(this);'>"
          strHtml = strHtml + "<input type='text' name='CarrierTollFreeExt3_#stopNumber#' id='CarrierTollFreeExt3_#stopNumber#' value='"+ui.item.tollfreeext+"' class='inp18px'>"
          strHtml = strHtml + "<label class='label45px'>Cell</label>"
          strHtml = strHtml + "<input type='text' name='CarrierCell3_#stopNumber#' id='CarrierCell3_#stopNumber#' value='"+ui.item.cell+"' class='inp70px' onchange='ParseUSNumber(this);'>"
          strHtml = strHtml + "<input type='text' name='CarrierCellExt3_#stopNumber#' id='CarrierCellExt3_#stopNumber#' value='"+ui.item.cellphoneext+"' class='inp18px'>"
          
				if(ui.item.iscarrier == 1 &&  ui.item.insuranceExpired == 'yes')
				{
					alert("Warning!! This #variables.freightBroker# has expired insurance, please make sure this carrier's insurance is updated.");
					if(! (#request.qSystemSetupOptions.AllowBooking#)){
						$(this).val('');
                        return false;
					}

				}
				document.getElementById("CarrierInfo3_#stopNumber#").style.display = 'block';
				document.getElementById('choosCarrier3_#stopNumber#').style.display = 'none';
				document.getElementById("carrierID3_#stopNumber#").value = ui.item.value;
				$('##CarrierInfo3_#stopNumber#').html(strHtml);
        CarrierContactAutoComplete();
				$('.CarrEmail').each(function(i, tag) {
                    var carrID = $( this ).data( "carrid" );
                    $(tag).autocomplete({
                        multiple: false,
                        width: 450,
                        scroll: true,
                        scrollHeight: 300,
                        cacheLength: 1,
                        highlight: false,
                        dataType: "json",
                        minLength:0,
                        autoFocus: true,
                        source: 'searchCarrierContactAutoFill.cfm?carrierID='+carrID,
                        select: function(e, ui) {
                          $('##CarrierPhoneNo3_#stopNumber#').val(ui.item.phoneno);
                          $('##CarrierPhoneNoExt3_#stopNumber#').val(ui.item.phonenoext);
                          $('##CarrierFax3_#stopNumber#').val(ui.item.fax);
                          $('##CarrierFaxExt3_#stopNumber#').val(ui.item.faxext);
                          $('##CarrierTollFree3_#stopNumber#').val(ui.item.tollfree);
                          $('##CarrierTollFreeExt3_#stopNumber#').val(ui.item.tollfreeext);
                          $('##CarrierCell3_#stopNumber#').val(ui.item.PersonMobileNo);
                          $('##CarrierCellExt3_#stopNumber#').val(ui.item.MobileNoExt);

                        },
                    }).focus(function() { 
			        	$(this).keydown();
			        })
                    $(tag).data("ui-autocomplete")._renderItem = function(ul, item) {
                        return $( "<li><b><u>Email</u>:</b> "+item.email+"<br/><b><u>Contact</u>:</b> "+ item.ContactPerson+"&nbsp;&nbsp;&nbsp;<b><u>Phone</u>:</b> "+ item.phoneno+"<br/><b><u>cell</u>:</b> " + item.PersonMobileNo+"&nbsp;&nbsp;&nbsp;<b><u>Type</u>:</b> " + item.ContactType+"</li>" )
                    .appendTo( ul );
                    }
                })
				return false;
			}
		});
		$(tag).data("ui-autocomplete")._renderItem = function(ul, item) {
			return $( "<li>"+item.name+"<br/><b><u>City</u>:</b> "+ item.city+"&nbsp;&nbsp;&nbsp;<b><u>State</u>:</b>" + item.state+"&nbsp;&nbsp;&nbsp;<b><u>Zip</u>:</b> " + item.zip+"&nbsp;&nbsp;&nbsp;<b><u>Insurance Expiry</u>:</b> " + item.InsExpDate+"</li>" )
					.appendTo( ul );
		}

	});
});
</script>
<script type="text/javascript">
    $( document ).ready(function() {
  		  $('.hyperLinkLabel#stopnumber#').on("click",function() {
            var EquipID = $(this).next().val();
            if($.trim(EquipID).length){
                var frieghtBrokerStatus = document.getElementById('frieghtBroker').value;
                if(frieghtBrokerStatus==0){
                    var url ='index.cfm?event=addDriverEquipment&equipmentid='+EquipID+'&#session.URLToken#&iscarrier=1'
                }
                else{
                    var url ='index.cfm?event=addEquipment&equipmentid='+EquipID+'&#session.URLToken#&iscarrier=1'
                }
                window.open(url, "_blank");
            }
            else{
                alert('Please select a Trailer.')
            }
        });

      $(".carrierBlock"+<cfoutput>#stopNumber#</cfoutput>).hide();


      $('##equipment#stopNumber#').each(function() {
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

        $("##equipment#stopNumber#").change(function(){ 
            if(typeof $("##equipment#stopNumber# option:selected").data("temperature") != 'undefined' && $("##equipment#stopNumber# option:selected").data("temperature") != ''){
                $("##temperature#stopNumber#").val($("##equipment#stopNumber# option:selected").data("temperature"));
            }
            else{
                $("##temperature#stopNumber#").val('');
            }
            
            if(typeof $("##equipment#stopNumber# option:selected").data("temperaturescale") != 'undefined' && $("##equipment#stopNumber# option:selected").data("temperaturescale") != ''){
            	$("##temperaturescale#stopNumber#").val($("##equipment#stopNumber# option:selected").data("temperaturescale"));
            }
            else{
            	$("##temperaturescale#stopNumber#").val('C');
            }

            var dataTruckTrailer = $("##equipment#stopNumber# option:selected").data("trucktrailer");
             if($("##equipmentTrailer#stopNumber# option[value='"+dataTruckTrailer+"']").length && !$('##equipmentTrailer#stopNumber#').val().length){
              $('##equipmentTrailer#stopNumber#').val(dataTruckTrailer);
             }
           
        })
        	$( ".datefield" ).datepicker({
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


          <cfif request.qSystemSetupOptions.freightBroker EQ 0 OR (request.qSystemSetupOptions.freightBroker EQ 2 AND chckdCarrier EQ 0)>
            customDriverPay($('.CustomDriverPay').first());
          </cfif>

    })

    $('.commRows').sortable({
        start: function(e, ui) {
        // creates a temporary attribute on the element with the old index
        $(this).attr('data-previndex', ui.item.index());
    },
    update: function(e, ui) {
        // gets the new and old index then removes the temporary attribute
        var newIndex = ui.item.index();
        var oldIndex = $(this).attr('data-previndex');

        $(this).removeAttr('data-previndex');

        var tableId = $(this).parent().attr("id");

        $('##'+tableId+' tbody tr').each(function (i, tr){
        	$(this).find('input,select,img').each(function () {
			    var Name = this.name;
			    var ind = i+1;
			    $(this).attr("name",Name.split('_')[0]+'_'+ind);
			    $(this).attr("id",Name.split('_')[0]+'_'+ind);
			});
        })
        reSortCommodities()
    }

    });

    $( ".commRows" ).disableSelection();
</script>
<style>
  .hyperLinkLabel#stopnumber#{
    text-decoration: underline;
    color:##4322cc !important;
    cursor: pointer;
  }
</style>
</cfoutput>