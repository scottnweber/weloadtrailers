<!--- :::::
---------------------------------
Changing 571 Line Extra line comment of consigneeZipcode already use in getdistancenext.cfm page
---------------------------------
::::: --->
<style>
  span.iconediting {
    position: absolute;
    right: -10px;
    top: 3px;
    font-size: 20px;
}

</style>
<cfoutput>
	<cfparam name="nextLoadStopId" default="">
	<cfparam name="nextLoadStopId" default="">
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
	<cfset ConsigneetimeIn ="">
	<cfset ConsigneetimeOut ="">
	<cfset ConsigneeInstructions ="">
	<cfset Consigneedirection ="">
	<cfset shipBlind="False">
	<cfset ConsBlind="False">
	<cfset bookedwith1 ="">
	<cfset equipment1 ="">
	<cfset equipmentTrailer ="">
	<cfset driver ="">
	<cfset driver2 ="">
	<cfset driverCell ="">
	<cfset truckNo ="">
	<cfset TrailerNo ="">
	<cfset refNo ="">
	<cfset showItems = false>
	<cfset stofficeidNext="">
	<cfset loadIDN = "">
	<cfset secDriverCell ="">
	<cfset temperature ="">
	<cfset temperaturescale ="">
	<cfset ShipperTimeZone ="">
	<cfset ConsigneeTimeZone ="">
	<cfset carrierID2_1 = "">
	<cfset carrierID3_1 = "">
	<cfset thirdDriverCell ="">
	<cfset CustomDriverPayFlatRate = 0>
	<cfset CustomDriverPayFlatRate2 = 0>
	<cfset CustomDriverPayFlatRate3 = 0>
	<cfset CustomDriverPayPercentage = 0>
	<cfset CustomDriverPayPercentage2 = 0>
	<cfset CustomDriverPayPercentage3 = 0>
	<cfset CustomDriverPayOption = 0>
	<cfset CustomDriverPayOption2 = 0>
	<cfset CustomDriverPayOption3 = 0>
	<cfset LateStop = 0>
	<cfset userDef1 = ''>
    <cfset userDef2 = ''>
    <cfset userDef3 = ''>
    <cfset userDef4 = ''>
    <cfset userDef5 = ''>
    <cfset userDef6 = ''>
	<cfif isdefined("url.loadid") and len(trim(url.loadid)) gt 1 >
		<cfset loadIDN = url.loadid>
		<cfelseif isdefined("url.loadToBeCopied") and len(trim(url.loadToBeCopied)) gt 1>
		<cfset loadIDN = url.loadToBeCopied>
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
				<cfset LateStop=request.qLoads.LateStop>
				<cfif  NOT ( structkeyexists(url,"loadToBeCopied")  and len(trim(url.loadToBeCopied)) gt 1 ) OR (( structkeyexists(url,"loadToBeCopied")  and len(trim(url.loadToBeCopied)) gt 1 )  AND (request.qSystemSetupOptions1.CopyLoadCarrier EQ 1 OR request.qLoads.STATUSTEXT EQ '. TEMPLATE'))>
					<cfset carrierIDNext=request.qLoads.NEWCARRIERID>
					<cfset carrierID2_1=request.qLoads.NEWCARRIERID2>
            		<cfset carrierID3_1=request.qLoads.NEWCARRIERID3>
				<cfelse>
					<cfset carrierIDNext= "">
				</cfif>
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
				<cfset shiplocation=request.ShipperStop.ShipperLocation>
				<cfset shipcity=request.ShipperStop.Shippercity>
				<cfset shipstate1=request.ShipperStop.ShipperState>
				<cfset shipzipcode=request.ShipperStop.Shipperpostalcode>
				<cfset shipcontactPerson=request.ShipperStop.ShipperContactPerson>
				<cfset shipPhone=request.ShipperStop.Shipperphone>
				<cfset shipPhoneExt=request.ShipperStop.ShipperphoneExt>
				<cfset shipfax=request.ShipperStop.Shipperfax>
				<cfset shipemail=request.ShipperStop.ShipperemailId>
				<cfset shipPickupNo=request.ShipperStop.ShipperReleaseNo>
				<cfset shipperTimeZone=request.ShipperStop.shipperTimeZone>
				<cfif  NOT ( structkeyexists(url,"loadToBeCopied")  and len(trim(url.loadToBeCopied)) gt 1 ) OR (( structkeyexists(url,"loadToBeCopied")  and len(trim(url.loadToBeCopied)) gt 1 )  AND (request.qSystemSetupOptions1.CopyLoadDeliveryPickupDates EQ 1 OR request.qLoads.STATUSTEXT EQ '. TEMPLATE'))>
					<cfif  request.LoadStopInfoShipper.StopDate NEQ "01/01/1900">
						<cfset shippickupDate=request.LoadStopInfoShipper.StopDate>
					</cfif>
					<cfset ShippickupDateMultiple=request.LoadStopInfoShipper.MultipleDates>
					<cfset shippickupTime=request.LoadStopInfoShipper.StopTime>
				</cfif>
				<cfif NOT (structkeyexists(url,"loadToBeCopied") and len(trim(url.loadToBeCopied)) gt 1)>
					<cfif len(trim(request.LoadStopInfoShipper.DriverTimeIn))>
             <cfset shiptimeIn=request.LoadStopInfoShipper.DriverTimeIn>
          <cfelse>
             <cfset shiptimeIn=request.LoadStopInfoShipper.TimeIn>
          </cfif>
          <cfif len(trim(request.LoadStopInfoShipper.DriverTimeOut))>
            <cfset shiptimeOut=request.LoadStopInfoShipper.DriverTimeOut>
          <cfelse>
            <cfset shiptimeOut=request.LoadStopInfoShipper.TimeOut>
          </cfif>
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
				<cfset consigneelocation=request.ConsineeStop.ConsigneeLocation>
				<cfset consigneecity=request.ConsineeStop.Consigneecity>
				<cfset consigneestate1=request.ConsineeStop.ConsigneeState>
				<cfset consigneezipcode=request.ConsineeStop.Consigneepostalcode>
				<cfset consigneecontactPerson=request.ConsineeStop.ConsigneeContactPerson>
				<cfset consigneePhone=request.ConsineeStop.Consigneephone>
				<cfset consigneePhoneExt=request.ConsineeStop.ConsigneephoneExt>
				<cfset consigneefax=request.ConsineeStop.Consigneefax>
				<cfset consigneeemail=request.ConsineeStop.ConsigneeemailId>
				<cfset consigneePickupNo=request.ConsineeStop.ConsigneeReleaseNo>
				<cfset consigneetimezone=request.ConsineeStop.consigneetimezone>
				<cfif  NOT ( structkeyexists(url,"loadToBeCopied")  and len(trim(url.loadToBeCopied)) gt 1 ) OR (( structkeyexists(url,"loadToBeCopied")  and len(trim(url.loadToBeCopied)) gt 1 )  AND (request.qSystemSetupOptions1.CopyLoadDeliveryPickupDates EQ 1 OR request.qLoads.STATUSTEXT EQ '. TEMPLATE'))>
					<cfif  request.LoadStopInfoConsignee.StopDate NEQ "01/01/1900">
						<cfset consigneepickupDate=request.LoadStopInfoConsignee.StopDate>
					</cfif>
					<cfset consigneepickupTime=request.LoadStopInfoConsignee.StopTime>
				</cfif>
				<cfif NOT (structkeyexists(url,"loadToBeCopied") and len(trim(url.loadToBeCopied)) gt 1)>
					<cfif len(trim(request.LoadStopInfoConsignee.DriverTimeIn))>
            <cfset consigneetimeIn=request.LoadStopInfoConsignee.DriverTimeIn>
          <cfelse>
            <cfset consigneetimeIn=request.LoadStopInfoConsignee.TimeIn>
          </cfif>
          <cfif len(trim(request.LoadStopInfoConsignee.DriverTimeOut))>
            <cfset consigneetimeOut=request.LoadStopInfoConsignee.DriverTimeOut>
          <cfelse>
            <cfset consigneetimeOut=request.LoadStopInfoConsignee.TimeOut>
          </cfif>
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
				<cfif NOT (structkeyexists(url,"loadToBeCopied") and len(trim(url.loadToBeCopied)) gt 1)>
					<cfset bookedwith1=request.ConsineeStop.ConsigneeBOOKEDWITH>
				</cfif>
				<cfset equipment1=request.ConsineeStop.ConsigneeEQUIPMENTID>
				<cfset equipmentTrailer=request.ConsineeStop.equipmentTrailer>
				<cfif NOT (structkeyexists(url,"loadToBeCopied") and len(trim(url.loadToBeCopied)) gt 1)>
					<cfset driver=request.ConsineeStop.ConsigneeDRIVERNAME>
					<cfset driver2=request.ConsineeStop.ConsigneeDRIVERNAME2>
					<cfset driverCell=request.ConsineeStop.ConsigneeDRIVERCELL>
					<cfset truckNo=request.ConsineeStop.ConsigneeTRUCKNO>
					<cfset TrailerNo=request.ConsineeStop.ConsigneeTRAILORNO>
					<cfset refNo=request.ConsineeStop.ConsigneeREFNO>
					<cfset milse=request.ConsineeStop.ConsigneeMILES>
					<cfset userDef1 = request.LoadStopInfoShipper.userDef1>
		            <cfset userDef2 = request.LoadStopInfoShipper.userDef2>
		            <cfset userDef3 = request.LoadStopInfoShipper.userDef3>
		            <cfset userDef4 = request.LoadStopInfoShipper.userDef4>
		            <cfset userDef5 = request.LoadStopInfoShipper.userDef5>
		            <cfset userDef6 = request.LoadStopInfoShipper.userDef6>
		            <cfset secDriverCell=request.ConsineeStop.consigneeDriverCell2>
				</cfif>
				<cfset editid=loadIDN>
				<cfset temperature=request.ConsineeStop.temperature>
       			<cfset temperaturescale=request.ConsineeStop.temperaturescale>
       			<cfset thirdDriverCell=request.ConsineeStop.consigneeDriverCell3>
       			<cfset CustomDriverPayFlatRate = request.ConsineeStop.CustomDriverPayFlatRate>
				<cfset CustomDriverPayFlatRate2 = request.ConsineeStop.CustomDriverPayFlatRate2>
				<cfset CustomDriverPayFlatRate3 = request.ConsineeStop.CustomDriverPayFlatRate3>
				<cfset CustomDriverPayPercentage = request.ConsineeStop.CustomDriverPayPercentage>
				<cfset CustomDriverPayPercentage2 = request.ConsineeStop.CustomDriverPayPercentage2>
				<cfset CustomDriverPayPercentage3 = request.ConsineeStop.CustomDriverPayPercentage3>
				<cfset CustomDriverPayOption=request.ConsineeStop.CustomDriverPayOption>
		        <cfset CustomDriverPayOption2=request.ConsineeStop.CustomDriverPayOption2>
		        <cfset CustomDriverPayOption3=request.ConsineeStop.CustomDriverPayOption3>
			</cfif>
		</cfif>
		<script language="javascript" type="text/javascript">
			$(document).ready(function(){
				var shipperValue='<cfoutput>#clean_javascript_data(ShipCustomerStopName)#</cfoutput>';
				var shiplocation='<cfoutput>#clean_javascript_data(shiplocation)#</cfoutput>';
				var shipcity='<cfoutput>#clean_javascript_data(shipcity)#</cfoutput>';
				var shipstate1='<cfoutput>#clean_javascript_data(shipstate1)#</cfoutput>';
				var shipzipcode='<cfoutput>#clean_javascript_data(shipzipcode)#</cfoutput>';
				var shipcontactPerson='<cfoutput>#clean_javascript_data(shipcontactPerson)#</cfoutput>';
				var shipPhone='<cfoutput>#clean_javascript_data(shipPhone)#</cfoutput>';
				var shipfax='<cfoutput>#clean_javascript_data(shipfax)#</cfoutput>';
				var shipemail='<cfoutput>#clean_javascript_data(shipemail)#</cfoutput>';
				var shipPickupNo='<cfoutput>#clean_javascript_data(shipPickupNo)#</cfoutput>';
				var shippickupDate='<cfoutput>#clean_javascript_data(shippickupDate)#</cfoutput>';
				var shippickupTime='<cfoutput>#clean_javascript_data(shippickupTime)#</cfoutput>';
				var shiptimeOut='<cfoutput>#clean_javascript_data(shiptimeOut)#</cfoutput>';
				var shiptimeIn='<cfoutput>#clean_javascript_data(shiptimeIn)#</cfoutput>';
				var shipInstructions="<cfoutput>#clean_javascript_data(shipInstructions)#</cfoutput>";
				var Shipdirection='<cfoutput>#clean_javascript_data(Shipdirection)#</cfoutput>';

				var consineeValue='<cfoutput>#clean_javascript_data(ConsineeCustomerStopName)#</cfoutput>';
				var consigneelocation='<cfoutput>#clean_javascript_data(consigneelocation)#</cfoutput>';
				var consigneecity='<cfoutput>#clean_javascript_data(consigneecity)#</cfoutput>';
				var consigneestate1='<cfoutput>#clean_javascript_data(consigneestate1)#</cfoutput>';
				var consigneezipcode='<cfoutput>#clean_javascript_data(consigneezipcode)#</cfoutput>';
				var consigneecontactPerson='<cfoutput>#clean_javascript_data(consigneecontactPerson)#</cfoutput>';
				var consigneePhone='<cfoutput>#clean_javascript_data(consigneePhone)#</cfoutput>';
				var consigneefax='<cfoutput>#clean_javascript_data(consigneefax)#</cfoutput>';
				var consigneeemail='<cfoutput>#clean_javascript_data(consigneeemail)#</cfoutput>';
				var consigneePickupNo='<cfoutput>#clean_javascript_data(consigneePickupNo)#</cfoutput>';
				var consigneetimeIn='<cfoutput>#clean_javascript_data(consigneetimeIn)#</cfoutput>';
				var consigneetimeOut='<cfoutput>#clean_javascript_data(consigneetimeOut)#</cfoutput>';
				var consigneepickupTime='<cfoutput>#clean_javascript_data(consigneepickupTime)#</cfoutput>';
				var consigneepickupDate='<cfoutput>#clean_javascript_data(consigneepickupDate)#</cfoutput>';
				var consigneeInstructions='<cfoutput>#clean_javascript_data(consigneeInstructions)#</cfoutput>';
				var consigneedirection='<cfoutput>#clean_javascript_data(consigneedirection)#</cfoutput>';
				if (shipstate1=='<![CDATA[0]]>'){
					shipstate1='<![CDATA[]]>';
				}
				if(shipperValue !="<![CDATA[]]>" || shiplocation !="<![CDATA[]]>" || shipcity !="<![CDATA[]]>" || shipstate1 !='<![CDATA[]]>' || shipzipcode !="<![CDATA[]]>" || shipPhone !="<![CDATA[]]>" || shipfax !="<![CDATA[]]>" || shipemail !="<![CDATA[]]>" || shipPickupNo !="<![CDATA[]]>" || shippickupDate !="<![CDATA[]]>" || shippickupTime !="<![CDATA[]]>" || shiptimeIn !="<![CDATA[]]>" || shiptimeOut !="<![CDATA[]]>" || shipInstructions!="<![CDATA[]]>"){
					$(".InfoShipping"+<cfoutput>#stopNumber#</cfoutput>).show();
				}else{
					$(".InfoShipping"+<cfoutput>#stopNumber#</cfoutput>).hide();
				}
				if(consineeValue !="<![CDATA[]]>" || consigneelocation !="<![CDATA[]]>" || consigneecity !="<![CDATA[]]>" || consigneestate1 !="<![CDATA[]]>" || consigneezipcode !="<![CDATA[]]>" || consigneecontactPerson !="<![CDATA[]]>" || consigneePhone !="<![CDATA[]]>" || consigneefax !="<![CDATA[]]>" || consigneeemail !="<![CDATA[]]>" || consigneePickupNo !="<![CDATA[]]>" || consigneetimeIn !="<![CDATA[]]>" || consigneetimeOut !="<![CDATA[]]>" || consigneetimeOut !="<![CDATA[]]>" || consigneepickupTime !="<![CDATA[]]>" || consigneepickupDate !="<![CDATA[]]>" || consigneeInstructions !="<![CDATA[]]>"|| consigneedirection!="<![CDATA[]]>"){
					$(".InfoConsinee"+<cfoutput>#stopNumber#</cfoutput>).show();
				}else{
					$(".InfoConsinee"+<cfoutput>#stopNumber#</cfoutput>).hide();
				}
				<cfif request.qItems.recordcount>
					$("##totalResult#stopNumber#").val(#request.qItems.recordcount#);
				<cfelse>
					$("##totalResult#stopNumber#").val(1);
				</cfif>
				<cfif not len(trim(carrierIDNext)) OR collapseCarrierBlock EQ 1>
					$(".carrierBlock"+<cfoutput>#stopNumber#</cfoutput>).hide();
				</cfif>
			});

</script>

  <input type="hidden" name="nextLoadStopId#stopNumber#" value="#nextLoadStopId#">
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
	</cfif>
	<cfset variables.previousstopNumber=stopNumber-1>
	<cfset variables.NextstopNumber=stopNumber+1>
    <div class="white-mid" style="width: 932px;">
		<div>
			<cfif ( structkeyexists(url,"loadid") and len(trim(url.loadid)) gt 1 )>
				<cfif variables.totalStopcount neq stopNumber>
					<a href="javascript:void(0);"><img src="images/upButton.png"  style="position:absolute;margin-left: 795px;margin-top: -30px;" title="By clicking this  stop #(stopNumber-1)# and stop #stopNumber# get swaped " onclick="return stopInterChanging('up','#url.loadid#','#application.dsn#',#(stopNumber-1)#);"></a>
					<a href="javascript:void(0);"><img src="images/upButton.png" style="position:absolute;margin-top: -30px; margin-left: 822px; -ms-transform: rotate(180deg);-webkit-transform: rotate(180deg);transform: rotate(180deg);" title="By clicking this stop #(stopNumber)#  and stop #(stopNumber+1)#  get swaped " onclick="return stopInterChanging('down','#url.loadid#','#application.dsn#',#(stopNumber-1)#);"></a>
				<cfelse>
					<a href="javascript:void(0);"><img src="images/upButton.png"  style="position:absolute;margin-left: 822px;margin-top: -30px;" title="By clicking this  stop #(stopNumber-1)#  and stop #(stopNumber)#  get swaped " onclick="return stopInterChanging('up','#url.loadid#','#application.dsn#',#(stopNumber-1)#);"></a>
				</cfif>
			</cfif>
			<div class="clear"></div>
			<div id="ShipperInfo"  style="clear:both">
				<div class="" style="position: absolute;">
					<div class="fa fa-<cfif ShipCustomerStopName neq "" or shiplocation neq "" or shipcity neq "" or (shipstate1 neq 0 AND shipstate1 neq "") or shipzipcode neq "" or shipcontactPerson neq "" or shipPhone neq "" or shipfax neq "" or shipemail neq "" or shipPickupNo neq "" or shippickupDate neq "" or shippickupTime neq "" or shiptimeIn neq "" or shiptimeOut neq "" or shipInstructions neq "" or  Shipdirection neq "">minus<cfelse>plus</cfif>-circle PlusToggleButton" onclick="showHideIcons(this,#stopNumber#);" style="position:relative;margin-left: 5px;"></div>
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
					<input name="shipper#stopNumber#" class="myElements  <cfif len(trim(request.ShipperStop.shipperCustomerID))>hyperLinkLabelStop</cfif>" style="margin-left:112px;" id="shipper#stopNumber#" value="#ShipCustomerStopName#"  message="Please select a Shipper"   onkeyup ="ChkUpdteShipr(this.value,'Shipper',#stopNumber#); showChangeAlert('shipper',#stopNumber#);" onblur ="ChkUpdteShipr(this.value,'Shipper',#stopNumber#); showChangeAlert('shipper',#stopNumber#);"   tabindex="#evaluate(currentTab++)#" onclick="openCustomerPopup('#request.ShipperStop.shipperCustomerID#',this);" title="Type text here to display list."/>
					<img src="images/clearRed.gif" style="height:14px;width:14px"  title="Click here to clear pickup information"  onclick="ChkUpdteShipr('','Shipper1',#stopNumber#);">
					<input type="hidden" name="shipperValueContainer#stopNumber#" id="shipperValueContainer#stopNumber#" value="#shipperCustomerID#"  message="Please select a Shipper"/>
					<input type="hidden" name="shipIsPayer#stopNumber#" class="updateCreateAlert" id="shipIsPayer#stopNumber#" value="#shipIsPayer#">
					<div class="clear"></div>
					<!--- <label>Name*</label> --->
					<input style="display: none;" name="shipperName#stopNumber#" id="shipperName#stopNumber#" value="#ShipCustomerStopName#" type="text"    onkeyup ="ChkUpdteShipr(this.value,'Shipper',#stopNumber#); showChangeAlert('shipper',#stopNumber#);"  tabindex="#evaluate(currentTab++)#" maxlength="100"/>
					<input type="hidden" name="shipperNameText#stopNumber#" id="shipperNameText#stopNumber#" value="#ShipCustomerStopName#">
					<div class="clear"></div>
                    <p style="transform: rotate(-90deg);width: 300px;margin-left: -137px;color: ##0f4100;font-weight: bold;font-size: 20px;font-family: 'Arial Black';letter-spacing: 5px;">PICKUP</p>
                    <div class="clear" style="margin-top: -15px;"></div>
					<label>
					<p id="newShipper#stopNumber#" style="float: left;font-size: 14px;color: ##2c9500;display:none;">* NEW *</p>Address
					<div class="clear"></div>
					<span class="float_right">
						<cfif request.qSystemSetupOptions.googleMapsPcMiler AND request.qcurAgentdetails.PCMilerUsername NEQ "" AND request.qcurAgentdetails.PCMilerPassword NEQ "">
							<a href="##" onclick="Mypopitup('create_map.cfm?loc=#shiplocation#&city=#shipcity#&state=#stateName# #shipzipcode#&stopNo=#stopNumber#&shipOrConsName=#ShipCustomerStopName#&loadNum=#loadnumber#' );"><img style="float:left;" align="absmiddle" src="./map.jpg" width="24" height="24" alt="PC Miler Map"  /></a>
						<cfelse>
							<a href="##" onclick="Mypopitup('create_map.cfm?loc=#shiplocation#&city=#shipcity#&state=#stateName# #shipzipcode#&stopNo=#stopNumber#&shipOrConsName=#ShipCustomerStopName#&loadNum=#loadnumber#' );"><img style="float:left;" align="absmiddle" src="./map.jpg" width="24" height="24" alt="Google Map"  /></a>
						</cfif>
					</span>

				</label>
				   <input type="hidden" name="shipperUpAdd#stopNumber#" id="shipperUpAdd#stopNumber#" value="">
					<!---for promiles--->
					<input type="hidden" name="shipperAddressLocation#stopNumber#" id="shipperAddressLocation#stopNumber#" value="#shipcity#<cfif len(shipcity)>,</cfif> #shipstate1# #shipzipcode#">
					<textarea rows="" name="shipperlocation#stopNumber#" id="shipperlocation#stopNumber#" cols=""   onkeydown="ChkUpdteShiprAddress(this.value,'Shipper',#stopNumber#);" class="addressChange" data-role="#stopNumber#"  tabindex="#evaluate(currentTab++)#" maxlength="100" onchange="checkShipperUpdated('#stopNumber#');" style="height: 40px;">#left(shiplocation,100)#</textarea>
					<div class="clear"></div>
					<cfset variables.citytabIndex=currentTab+1>
					<label>City</label>
					<input name="shippercity#stopNumber#" id="shippercity#stopNumber#" value="#shipcity#" type="text" class="addressChange" data-role="#stopNumber#"  onkeydown="ChkUpdteShiprCity(this.value,'Shipper',#stopNumber#);" tabindex="-1"  maxlength="50" onchange="checkShipperUpdated('#stopNumber#');"/>
					<div class="clear"></div>
					<cfset variables.statetabIndex=variables.citytabIndex+1>
					<label>State</label>
					<select name="shipperstate#stopNumber#" id="shipperstate#stopNumber#" onchange="addressChanged(#stopNumber#);loadState(this,'shipper',#stopNumber#);checkShipperUpdated('#stopNumber#');" tabindex="-1"  style="width:60px;">
					  <option value="">Select</option>
					  <cfloop query="request.qStates">
						<option value="#request.qStates.statecode#" <cfif request.qStates.statecode is shipstate1> selected="selected" </cfif> >#request.qStates.statecode#</option>
						<cfif request.qStates.statecode is shipstate1>
						  <cfset variables.stateName = #request.qStates.statecode#>
						 <cfelse>
							<cfset variables.stateName = "">
						</cfif>
					  </cfloop>
					</select>
					<input type="hidden" name="shipperStateName#stopNumber#" id="shipperStateName#stopNumber#" value ="<cfif structKeyExists(variables,"stateName")>#shipstate1#</cfif>">
					<cfset variables.ziptabIndex=variables.statetabIndex-2>
					<label style="width: 58px;">Zip</label>
					<input name="shipperZipcode#stopNumber#" id="shipperZipcode#stopNumber#" value="#shipzipcode#" type="text" class="addressChange" data-role="#stopNumber#" <cfif len(url.loadid) gt 1> tabindex="#evaluate(currentTab++)#"</cfif> maxlength="50" style="width:60px;"/>
					<div class="clear"></div>
					<label>Contact</label>
					<input name="shipperContactPerson#stopNumber#" id="shipperContactPerson#stopNumber#" value="#shipcontactPerson#" type="text" tabindex="#evaluate(currentTab++)#" maxlength="100" onchange="checkShipperUpdated('#stopNumber#');"/>
					<div class="clear"></div>
					<label>Phone</label>
					<input name="shipperPhone#stopNumber#" id="shipperPhone#stopNumber#" value="#shipPhone#" type="text" onchange="ParseUSNumber(this.value);" tabindex="#evaluate(currentTab++)#" maxlength="30" onchange="checkShipperUpdated('#stopNumber#');" style="width:155px !important;"/>
					<label style="width:30px !important;">Ext</label>
					<input name="shipperPhoneExt#stopNumber#" id="shipperPhoneExt#stopNumber#" value="#shipPhoneExt#" type="text" tabindex="#evaluate(currentTab+2)#" maxlength="10"  onchange="checkShipperUpdated('');" style="width:50px !important;" />
					<div class="clear"></div>
					<label>Fax</label>
					<input name="shipperFax#stopNumber#" id="shipperFax#stopNumber#" value="#shipfax#" type="text" tabindex="#evaluate(currentTab++)#" maxlength="150"/>
					<div class="clear"></div>
					<label>Email</label>
					<input name="shipperEmail#stopNumber#" id="shipperEmail#stopNumber#" value="#shipemail#" type="text" tabindex="#evaluate(currentTab++)#" maxlength="100" onchange="checkShipperUpdated('#stopNumber#');"/>
					<div class="clear"></div>
				  </fieldset>
				</div>
				<div class="form-con InfoShipping#stopNumber#">
				  <fieldset>
				  	<div class="edique-pickup" style="font-size: 12px;color: green"></div>
					
					<label class="stopsLeftLabel">Pickup ## </label>
					<input name="shipperPickupNo1#stopNumber#" id="shipperPickupNo1#stopNumber#" value="#shipPickupNo#" type="text" tabindex="#evaluate(currentTab++)#"  maxlength="50"/>

					<label class="ch-box" style="width: 80px;text-align: right;margin-right: -5px;">Pickup Blind</label>
					<input name="shipBlind#stopNumber#" id="shipBlind#stopNumber#" type="checkbox" <cfif shipBlind is true> checked="checked" </cfif> class="check" tabindex="#evaluate(currentTab++)#" style="width:18px;"/>
					<div class="clear"></div>


					<div class="clear"></div>
					<label class="stopsLeftLabel">
						<cfif request.qSystemSetupOptions.FreightBroker NEQ 0 AND request.qSystemSetupOptions.FreightBroker NEQ 0 AND structkeyexists(url,"loadid") and len(trim(url.loadid)) gt 1 and request.qloads.statustext GTE '2. BOOKED' and PostTo123LoadBoard NEQ 1 and posttoDirectFreight NEQ 1 and posttoloadboard NEQ 1 and posttoTranscore NEQ 1 and posttoITS NEQ 1>
							Pickup Date
						<cfelse>
              <a style="color: ##4322cc;text-decoration:underline;" href="javascript:void(null)" onclick="window.open('index.cfm?event=addMultipleDates&stopNo=#stopNumber#&#session.URLToken#','Map','height=400,width=400');">Pickup Date</a>
						</cfif>
					</label>
					<div style="position:relative;float:left;">
						  <div style="float:left;">
					<input type="hidden" name="oldShipperPickupDate#stopNumber#" value="#dateformat(ShippickupDate,'yyyymmdd')#">
					<input type="hidden" id="shipperPickupDateMultiple#stopNumber#" name="shipperPickupDateMultiple#stopNumber#" value="#ShippickupDateMultiple#">
					<input class="sm-input datefield" name="shipperPickupDate#stopNumber#" id="shipperPickupDate#stopNumber#" value="#dateformat(ShippickupDate,'mm/dd/yyy')#" validate="date" message="Please enter a valid date" type="datefield" tabindex="#evaluate(currentTab++)#" data-stop="#stopNumber#" onchange="checkDateFormatAll(this);checkMultiplePickupDate(#stopNumber#);"/>
					  </div></div>
					<label class="sm-lbl" style="width: 50px;">Apt. Time</label>
					<input type="hidden" name="oldShipperpickupTime#stopNumber#" id="oldShipperpickupTime#stopNumber#" value="#shippickupTime#">
					<input type="hidden" id="ShipperStopDateQ#stopNumber#" name="ShipperStopDateQ#stopNumber#" value="#ShipperStopDateQ#">

					<input class="pick-input <cfif Len(EDISCAC)> NumericOnlyFields  edidatetime</cfif>" name="shipperpickupTime#stopNumber#" id="shipperpickupTime#stopNumber#" value="#shippickupTime#" type="text" tabindex="#evaluate(currentTab++)#" style="width:40px;" <cfif len(EDISCAC)>maxlength="9" </cfif>/>
					<cfif request.qSystemSetupOptions.timezone>
						<label class="sm-lbl" style="width: 55px;">Time Zone</label>
                        <input class="pick-input" name="shipperTimeZone#stopNumber#" id="shipperTimeZone#stopNumber#" value="#shipperTimeZone#" type="text" tabindex="#evaluate(currentTab++)#" style="width:30px;"/>
                    </cfif>
					<div class="clear"></div>
					<label class="stopsLeftLabel labelShipperTimein#stopNumber#">Arrived<br><span <cfif LateStop EQ 1> style="color: ##800000;" </cfif>>Late?</span> <input name="LateStop" id="LateStop" type="checkbox" class="check myElements" style="width: 12px;float: right;margin-right: 0 !important;margin-left: 2px;" <cfif LateStop EQ 1> checked </cfif>></label>
					<input type="hidden" name="oldShipperTimeIn#stopNumber#" id="oldShipperTimeIn#stopNumber#" value="#shiptimeIn#">

					<input style="width:60px;" class="sm-input <cfif Len(EDISCAC)> NumericOnlyFields edidatetime </cfif>" name="shipperTimeIn#stopNumber#" id="shipperTimeIn#stopNumber#" value="#shiptimeIn#" type="text" tabindex="#evaluate(currentTab++)#"  <cfif len(EDISCAC)>maxlength="4" </cfif> onchange="checkTimeForProject44('#stopNumber#','shipper','ARRIVED')"/>
					<cfif request.qSystemSetupOptions.Project44 AND ( structkeyexists(url,"loadid") and len(trim(url.loadid)) gt 1 ) AND qGetCustCons.PushDataToProject44Api>
                        <img class="44Logo" style="float:left;border-radius: 50%;cursor: pointer;" src="images/44Logo.png" onclick="sendProject44Local('#stopNumber#','shipper','ARRIVED');">
                    </cfif>
					<label class="sm-lbl"  style="width:65px !important;">Departed</label>
					<input type="hidden" name="oldshipperTimeOut#stopNumber#" id="oldshipperTimeOut#stopNumber#" value="#shipTimeOut#">
					<input style="width:40px;" class="pick-input <cfif Len(EDISCAC)> NumericOnlyFields edidatetime </cfif>" name="shipperTimeOut#stopNumber#" id="shipperTimeOut#stopNumber#" value="#shipTimeOut#" type="text" tabindex="#evaluate(currentTab++)#"  <cfif len(EDISCAC)>maxlength="4" </cfif>  onchange="checkTimeForProject44('#stopNumber#','shipper','DEPARTED')"/>
					<cfif request.qSystemSetupOptions.Project44 AND ( structkeyexists(url,"loadid") and len(trim(url.loadid)) gt 1 ) AND qGetCustCons.PushDataToProject44Api>
                        <img class="44Logo" style="float:left;border-radius: 50%;cursor: pointer;" src="images/44Logo.png" onclick="sendProject44Local('#stopNumber#','shipper','DEPARTED');">
                    </cfif>
					<cfif len(EDISCAC)>
                       <label class="stopsLeftLabel labelShipperTimein#stopNumber#" style="width: 66px !important;margin-left: 17px;display:none;">Late Reason</label>                                   
                        <select name="shipperEdiReasonCode#stopNumber#" id="shipperEdiReasonCode#stopNumber#" tabindex=1 class="medium " style="margin-left:0px;width:70px;display:none;">
                            <option value="">Select Reason</option> 
                            <cfloop query="qgetEdiReasonCodes">
                                <option value="#qgetEdiReasonCodes.ReasonCode#"> #qgetEdiReasonCodes.ReasonText#</option>
                            </cfloop>      
                        </select>
                    </cfif>
					<div class="clear"></div>
					<div style="color:red;" id="shipperProject44Text#stopNumber#"></div>
                    <div class="clear"></div>
					<label class="stopsLeftLabel margin_top">Instructions</label>
					<textarea rows="" name="shipperNotes#stopNumber#" id="shipperNotes#stopNumber#" class="carrier-textarea-medium" cols="" tabindex="#evaluate(currentTab++)#" style="width: 298px;height: 67px;margin-left: 0px;">#shipInstructions#</textarea>
					<div class="clear"></div>
					<label class="stopsLeftLabel margin_top">Internal Notes</label>
					<textarea rows="" maxlength="1000" name="shipperDirection#stopNumber#" id="shipperDirection#stopNumber#" class="carrier-textarea-medium" cols="" tabindex="#evaluate(currentTab++)#" onchange="checkShipperUpdated('#stopNumber#');" style="width: 298px;height: 67px;margin-left: 0px;">#shipdirection#</textarea>
					<div class="clear"></div>
				  </fieldset>
				</div>
			</div>
			<div class="clear"></div>
			<div align="center"><!---img border="0" alt="" src="images/line.jpg"--->
					<div style="border-bottom:1px solid ##e6e6e6; padding-top:7px;margin-bottom: 8px;"></div>
				</div>
			<div class="clear"></div>
		</div>
		<div style="margin-top: 20px;">
			<div id="ConsigneeInfo" style="height:15px;">
				<div class="" style="clear:both;">
					<div class="fa fa-<cfif ConsineeCustomerStopName neq "" or consigneelocation neq "" or consigneecity neq "" or ( consigneestate1 neq 0 AND consigneestate1 neq "") or consigneezipcode neq "" or consigneecontactPerson neq "" or consigneePhone neq "" or consigneefax neq "" or consigneeemail neq "" or consigneePickupNo neq "" or consigneepickupDate neq "" or consigneepickupTime neq "" or consigneetimeIn neq "" or consigneetimeOut neq "" or consigneedirection neq "" or consigneeInstructions neq "">minus<cfelse>plus</cfif>-circle PlusToggleButton" onclick="showHideConsineeIcons(this,#stopNumber#);" style="position:absolute;left:-16px;margin-top: -1px;"></div>
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
						<input name="consignee#stopNumber#"  class="myElements  <cfif len(trim(request.ConsineeStop.consigneeCustomerID))>hyperLinkLabelStop</cfif>" style="margin-left:112px;" id="consignee#stopNumber#" value="#ConsineeCustomerStopName#"    onkeyup ="ChkUpdteShipr(this.value,'consignee',#stopNumber#); showChangeAlert('consignee',#stopNumber#);"  onblur ="ChkUpdteShipr(this.value,'consignee',#stopNumber#); showChangeAlert('consignee',#stopNumber#);"  message="Please select a Consignee" tabindex="#evaluate(currentTab++)#" onclick="openCustomerPopup('#request.ConsineeStop.consigneeCustomerID#',this);" title="Type text here to display list."/><img src="images/clearRed.gif" style="height:14px;width:14px"  title="Click here to clear consignee information"  onclick="ChkUpdteShipr('','consignee1',#stopNumber#);">
						<input type="hidden" name="consigneeValueContainer#stopNumber#" id="consigneeValueContainer#stopNumber#" value="#consigneeCustomerID#"  message="Please select a Consignee" />
						<input type="hidden" name="consigneeIsPayer#stopNumber#" class="updateCreateAlert" id="consigneeIsPayer#stopNumber#" value="#consigneeIsPayer#">
						<div class="clear"></div>
						<input style="display: none;" name="consigneeName#stopNumber#" id="consigneeName#stopNumber#" value="#ConsineeCustomerStopName#" type="text"    onkeyup ="ChkUpdteShipr(this.value,'consignee',#stopNumber#); showChangeAlert('consignee',#stopNumber#);" tabindex="#evaluate(currentTab++)#" maxlength="100"/>
						<input type="hidden" name="consigneeNameText#stopNumber#" id="consigneeNameText#stopNumber#" value="#ConsineeCustomerStopName#">
						<div class="clear"></div>
                        <p style="transform: rotate(-90deg);width: 350px;margin-left: -163px;color: ##800000;font-weight: bold;font-size: 20px;font-family: 'Arial Black';letter-spacing: 5px;">DELIVERY</p>
                        <div class="clear" style="margin-top: -15px;"></div>
						<label><p id="newConsignee#stopNumber#" style="float: left;font-size: 14px;color: ##2c9500;display:none;">* NEW *</p>Address
						<div class="clear"></div>
						<span class="float_right">
							<cfif request.qSystemSetupOptions.googleMapsPcMiler AND request.qcurAgentdetails.PCMilerUsername NEQ "" AND request.qcurAgentdetails.PCMilerPassword NEQ "">
								<a href="##" onclick="Mypopitup('create_map.cfm?loc=#Consigneelocation#&city=#Consigneecity#&state=#stateName# #Consigneezipcode#&stopNo=#stopNumber#&shipOrConsName=#ConsineeCustomerStopName#&loadNum=#loadnumber#');" ><img style="float:left;" align="absmiddle" src="./map.jpg" width="24" height="24" alt="PC Miler Map"/></a>
							<cfelse>
								<a href="##" onclick="Mypopitup('create_map.cfm?loc=#Consigneelocation#&city=#Consigneecity#&state=#stateName# #Consigneezipcode#&stopNo=#stopNumber#&shipOrConsName=#ConsineeCustomerStopName#&loadNum=#loadnumber#');" ><img style="float:left;" align="absmiddle" src="./map.jpg" width="24" height="24" alt="Google Map"/></a>
							</cfif>
						</span>
						</label>
						<input type="hidden" name="consigneeUpAdd#stopNumber#" id="consigneeUpAdd#stopNumber#" value="">
						<textarea rows="" name="consigneelocation#stopNumber#" id="consigneelocation#stopNumber#" cols="" 	onkeydown="ChkUpdteShiprAddress(this.value,'consignee',#stopNumber#);"  class="addressChange" data-role="#stopNumber#"  tabindex="#evaluate(currentTab++)#" maxlength="100" onchange="checkConsngeeUpdated('#stopNumber#');" style="height: 40px;">#left(Consigneelocation,100)#</textarea>
						<div class="clear"></div>
						<cfset variables.cityConsigneetabIndex=currentTab+1>
						<label>City</label>
						<input name="consigneecity#stopNumber#" id="consigneecity#stopNumber#" value="#Consigneecity#" type="text" class="addressChange" data-role="#stopNumber#" onkeydown="ChkUpdteShiprCity(this.value,'consignee',#stopNumber#);"  tabindex="-1"  maxlength="50" onchange="checkConsngeeUpdated('#stopNumber#');"/>

						<div class="clear"></div>
						<cfset variables.stateConsigneetabIndex=variables.cityConsigneetabIndex+1>
						<label>State</label>
						<select name="consigneestate#stopNumber#" id="consigneestate#stopNumber#" onchange="addressChanged(#stopNumber#);loadState(this,'consignee',#stopNumber#);checkConsngeeUpdated('#stopNumber#');;" tabindex="-1"   style="width:60px;">
						  <option value="">Select</option>
						  <cfloop query="request.qStates">
							<option value="#request.qStates.statecode#" <cfif request.qStates.statecode is Consigneestate1> selected="selected" </cfif> >#request.qStates.statecode#</option>
							<cfif request.qStates.statecode is Consigneestate1>
							  <cfset variables.statecode = #request.qStates.statecode#>
							 <cfelse>
								<cfset variables.statecode = "">
							</cfif>
						  </cfloop>
						</select>
						<input type="hidden" name="consigneeStateName#stopNumber#" id="consigneeStateName#stopNumber#" value ="<cfif structKeyExists(variables,"statecode")>#Consigneestate1#</cfif>">
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

								<cfif structkeyexists(url,"loadid") and len(url.loadid) gt 1>
									<input tabindex="#evaluate(currentTab++)#" name="consigneeZipcode#stopNumber#" id="consigneeZipcode#stopNumber#" value="#Consigneezipcode#" type="text" onchange="getLongitudeLatitudeNext(load,#stopNumber#);ClaculateDistanceNext(load,#stopNumber#);addressChanged(#stopNumber#);checkConsngeeUpdated('#stopNumber#');;"  maxlength="50"  style="width:60px;"/>
								<cfelse>
									<input tabindex="" name="consigneeZipcode#stopNumber#"  id="consigneeZipcode#stopNumber#" value="#Consigneezipcode#" type="text" onchange="getLongitudeLatitudeNext(load,#stopNumber#);ClaculateDistanceNext(load,#stopNumber#);addressChanged(#stopNumber#);checkConsngeeUpdated('#stopNumber#');;"  maxlength="50"  style="width:60px;"/>
								</cfif>
								<input type="hidden" name="result1#stopNumber#" id="result1#stopNumber#" value="#result1#" >
								<input type="hidden" name="result2#stopNumber#" id="result2#stopNumber#" value="#result2#" >
								<input type="hidden" name="lat1#stopNumber#" id="lat1#stopNumber#" value="#lat1#">
								<input type="hidden" name="long1#stopNumber#" id="long1#stopNumber#" value="#long1#">
								<input type="hidden" name="lat2#stopNumber#" id="lat2#stopNumber#" value="#lat2#">
								<input type="hidden" name="long2#stopNumber#" id="long2#stopNumber#" value="#long2#">
							</cfoutput>
						<div class="clear"></div>
						<label>Contact</label>
						<input name="consigneeContactPerson#stopNumber#" id="consigneeContactPerson#stopNumber#" value="#ConsigneecontactPerson#" type="text" tabindex="#evaluate(currentTab++)#" maxlength="100" onchange="checkConsngeeUpdated('#stopNumber#');"/>
						<div class="clear"></div>
						<label>Phone</label>
						<input name="consigneePhone#stopNumber#" id="consigneePhone#stopNumber#" value="#ConsigneePhone#" onchange="ParseUSNumber(this.value);" type="text" tabindex="#evaluate(currentTab++)#" maxlength="30" onchange="checkConsngeeUpdated('#stopNumber#');" style="width:155px !important;"/>
						<label style="width:30px !important;">Ext</label>
          	<input name="consigneePhoneExt#stopNumber#" id="consigneePhoneExt#stopNumber#" value="#ConsigneePhoneExt#" type="text" tabindex="#evaluate(currentTab+21)#" maxlength="10" onchange="checkConsngeeUpdated('');" style="width:50px !important;"/>
						<div class="clear"></div>
						<label>Fax</label>
						<input name="consigneeFax#stopNumber#" id="consigneeFax#stopNumber#" value="#Consigneefax#" type="text" tabindex="#evaluate(currentTab++)#" maxlength="150"/>
						<div class="clear"></div>
						<label>Email</label>
						<input name="consigneeEmail#stopNumber#" id="consigneeEmail#stopNumber#" value="#Consigneeemail#" type="text" tabindex="#evaluate(currentTab++)#"  maxlength="100" onchange="checkConsngeeUpdated('#stopNumber#');"/>
					  </fieldset>
					</div>
					<!---for promiles--->
					<input type="hidden" name="consigneeAddressLocation#stopNumber#" id="consigneeAddressLocation#stopNumber#" value="#Consigneecity#<cfif len(Consigneecity)>,</cfif> #Consigneestate1# #Consigneezipcode#">
					<div class="form-con InfoConsinee#stopNumber#" style="margin-top: -6px;">
					  <fieldset>
					  	<div class="edique-delivery" style="font-size: 12px;color: green"></div>
						
						<label class="stopsLeftLabel">Delivery ##</label>
						<input name="consigneePickupNo#stopNumber#" id="consigneePickupNo#stopNumber#" value="#ConsigneePickupNo#" type="text" tabindex="#evaluate(currentTab++)#" maxlength="50"/>
						<label class="ch-box" style="width: 80px;text-align: right;margin-right: -7px;">Delivery Blind</label>
						<input name="ConsBlind#stopNumber#" id="ConsBlind#stopNumber#" type="checkbox" <cfif ConsBlind is true> checked="checked" </cfif> class="check" tabindex="#evaluate(currentTab++)#" style="width: 18px;"/>
						<div class="clear"></div>
						<label class="stopsLeftLabel">Delivery Date</label>
						<div style="position:relative;float:left;">
						<div style="float:left;">
						<input type="hidden" name="oldConsigneePickupDate#stopNumber#" id="oldConsigneePickupDate#stopNumber#" value="#dateformat(ConsigneepickupDate,'yyyymmdd')#">
						<input class="sm-input datefield" name="consigneePickupDate#stopNumber#" id="consigneePickupDate#stopNumber#" value="#dateformat(ConsigneepickupDate,'mm/dd/yyy')#" validate="date" message="Please enter a valid date" type="datefield" tabindex="#evaluate(currentTab++)#" data-stop="#stopNumber#"  onchange="checkDateFormatAll(this);"/>
						  </div></div>
						<label class="sm-lbl" style="width: 50px;">Apt. Time</label>
						<input type="hidden" name="oldConsigneepickupTime#stopNumber#" id="oldConsigneepickupTime#stopNumber#" value="#ConsigneepickupTime#">
						<input type="hidden" id="ConsigneeStopDateQ#stopNumber#" name="ConsigneeStopDateQ#stopNumber#" value="#ConsigneeStopDateQ#">


						<input class="pick-input <cfif Len(EDISCAC)> NumericOnlyFields  edidatetime</cfif>" name="consigneepickupTime#stopNumber#" id="consigneepickupTime#stopNumber#" value="#ConsigneepickupTime#" type="text" tabindex="#evaluate(currentTab++)#" style="width: 40px;"  <cfif len(EDISCAC)>maxlength="9" </cfif>/>
						
						<cfif request.qSystemSetupOptions.timezone>
							<label class="sm-lbl" style="width: 55px;">Time Zone</label>
		                    <input class="pick-input" name="consigneeTimeZone#stopNumber#" id="consigneeTimeZone#stopNumber#" value="#consigneeTimeZone#" type="text" tabindex="#evaluate(currentTab++)#" style="width:30px;"/>
		                </cfif>

						<div class="clear"></div>
						<label class="stopsLeftLabel labelConsigneeTimein#stopNumber#" style="width:80px !important;">Arrived</label>
						<input type="hidden" name="oldConsigneeTimeIn#stopNumber#" id="oldConsigneeTimeIn#stopNumber#" value="#ConsigneetimeIn#">

						<input style="width:60px;" class="sm-input <cfif Len(EDISCAC)> NumericOnlyFields edidatetime </cfif>" name="consigneeTimeIn#stopNumber#" id="consigneeTimeIn#stopNumber#" value="#ConsigneetimeIn#" message="Please enter a valid time" type="text" tabindex="#evaluate(currentTab++)#"  <cfif len(EDISCAC)>maxlength="4" </cfif> onchange="checkTimeForProject44('#stopNumber#','consignee','ARRIVED')"/>
						<cfif request.qSystemSetupOptions.Project44 AND ( structkeyexists(url,"loadid") and len(trim(url.loadid)) gt 1 ) AND qGetCustCons.PushDataToProject44Api>
	                        <img class="44Logo" style="float:left;border-radius: 50%;cursor: pointer;" src="images/44Logo.png" onclick="sendProject44Local('#stopNumber#','consignee','ARRIVED');">
	                    </cfif>
						<label class="sm-lbl" style="width:65px;">Departed</label>
						<input type="hidden" name="oldConsigneeTimeOut#stopNumber#" id="oldConsigneeTimeOut#stopNumber#" value="#ConsigneeTimeOut#">
						
						<input style="width:40px;" class="pick-input <cfif Len(EDISCAC)> NumericOnlyFields edidatetime </cfif>" name="consigneeTimeOut#stopNumber#" id="consigneeTimeOut#stopNumber#" value="#ConsigneeTimeOut#" type="text" message="Please enter a valid time" tabindex="#evaluate(currentTab++)#"  <cfif len(EDISCAC)>maxlength="4" </cfif>onchange="checkTimeForProject44('#stopNumber#','consignee','DEPARTED')"/>
						<cfif request.qSystemSetupOptions.Project44 AND ( structkeyexists(url,"loadid") and len(trim(url.loadid)) gt 1 ) AND qGetCustCons.PushDataToProject44Api>
	                        <img class="44Logo" style="float:left;border-radius: 50%;cursor: pointer;" src="images/44Logo.png" onclick="sendProject44Local('#stopNumber#','consignee','DEPARTED');">
	                    </cfif>
						<cfif len(EDISCAC)>
                        <label class="stopsLeftLabel labelConsigneeTimein#stopNumber#" style="width: 66px !important;margin-left: 17px;display:none;">Late Reason</label>                                
                        <select name="consigneeEdiReasonCode#stopNumber#" id="consigneeEdiReasonCode#stopNumber#" tabindex=1 class="medium " style="margin-left:0px;width:70px;display:none;">
                            <option value="">Select Reason</option> 
                            <cfloop query="qgetEdiReasonCodes">
                                <option value="#qgetEdiReasonCodes.ReasonCode#"> #qgetEdiReasonCodes.ReasonText#</option>
                            </cfloop>      
                        </select>
                    </cfif>
						<div class="clear"></div>
						<div style="color:red;" id="consigneeProject44Text#stopNumber#"></div>
						<div class="clear"></div>
						<label class="stopsLeftLabel  margin_top">Instructions</label>
						<textarea rows="" name="consigneeNotes#stopNumber#" id="consigneeNotes#stopNumber#" class="carrier-textarea-medium" cols="" tabindex="#evaluate(currentTab++)#" style="width: 298px;height: 67px;margin-left: 0px;">#ConsigneeInstructions#</textarea>
						<div class="clear"></div>
						<label class="stopsLeftLabel  margin_top">Internal Notes</label>
						<textarea rows="" maxlength="1000" name="consigneeDirection#stopNumber#" id="consigneeDirection#stopNumber#" class="carrier-textarea-medium" cols="" tabindex="#evaluate(currentTab++)#" onchange="checkConsngeeUpdated('#stopNumber#');" style="width: 298px;height: 67px;margin-left: 0px;">#Consigneedirection#</textarea>
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
                    </cfif>
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
                </ul>

	            <div id="carriertabs-#stopNumber#-carrier">
	            	<div class="white-con-area" style="background-color: ##defaf9;">
	            		<div class="fa fa-<cfif len(trim(carrierIDNext)) AND collapseCarrierBlock EQ 0>minus<cfelse>plus</cfif>-circle PlusToggleButton" onclick="showHideCarrierBlock(this,#stopNumber#);" style="position:relative;margin-left: 0;margin-top: 10px"></div>
			<div class="pg-title-carrier" style="float: left; width: 35%;padding-left:10px;/*color:white;*/font-weight:bold;font-size: 15px;">
				<cfif request.qSystemSetupOptions.freightBroker EQ 2> 						   
						<cfif chckdCarrier EQ  "">
							<div class="" style="margin:12px 0px 0px 0px !important;">
								<input type="radio" name="Rad_freightBroker#stopNumber#"  id="Rad_freightBroker"  value="2" <cfif chckdCarrier EQ  "">checked</cfif>  onclick="ChangeLabelStop(2,#stopNumber#)">&nbsp;Both&nbsp;
								<input type="radio" name="Rad_freightBroker#stopNumber#"  id="Rad_freightBroker"  value="1" onclick="ChangeLabelStop(1,#stopNumber#)" <cfif chckdCarrier EQ 1>checked</cfif> >&nbsp;Carrier&nbsp;
								<input type="radio" name="Rad_freightBroker#stopNumber#"  id="Rad_freightBroker"  value="0" onclick="ChangeLabelStop(0,#stopNumber#)" <cfif chckdCarrier EQ 0>checked</cfif> >&nbsp;Driver&nbsp;
							</div>       
						<cfelseif  chckdCarrier EQ 0>
								<h2 class="div_freightBrokerHeading#stopNumber#"  style="/*color:white;*/font-weight:bold;">Driver</h2>
								<div class="div_freightBroker#stopNumber#" style="margin:12px 0px 0px 0px !important;display:none;">
									<input type="radio" name="Rad_freightBroker#stopNumber#"  id="Rad_freightBroker"  value="2" <cfif chckdCarrier EQ  "">checked</cfif>  onclick="ChangeLabelStop(2,#stopNumber#)">&nbsp;Both&nbsp;
									<input type="radio" name="Rad_freightBroker#stopNumber#"  id="Rad_freightBroker"  value="1" onclick="ChangeLabelStop(1,#stopNumber#)" <cfif chckdCarrier EQ 1>checked</cfif> >&nbsp;Carrier&nbsp;
									<input type="radio" name="Rad_freightBroker#stopNumber#"  id="Rad_freightBroker"  value="0" onclick="ChangeLabelStop(0,#stopNumber#)" <cfif chckdCarrier EQ 0>checked</cfif> >&nbsp;Driver&nbsp;
								</div>   
						<cfelseif  chckdCarrier EQ 1>
								<h2 class="div_freightBrokerHeading#stopNumber#" style="/*color:white;*/font-weight:bold;">Carrier</h2>
								<div class="div_freightBroker#stopNumber#" style="margin:12px 0px 0px 0px !important;display:none;">
									<input type="radio" name="Rad_freightBroker#stopNumber#"  id="Rad_freightBroker"  value="2" <cfif chckdCarrier EQ  "">checked</cfif>  onclick="ChangeLabelStop(2,#stopNumber#)">&nbsp;Both&nbsp;
									<input type="radio" name="Rad_freightBroker#stopNumber#"  id="Rad_freightBroker"  value="1" onclick="ChangeLabelStop(1,#stopNumber#)" <cfif chckdCarrier EQ 1>checked</cfif> >&nbsp;Carrier&nbsp;
									<input type="radio" name="Rad_freightBroker#stopNumber#"  id="Rad_freightBroker"  value="0" onclick="ChangeLabelStop(0,#stopNumber#)" <cfif chckdCarrier EQ 0>checked</cfif> >&nbsp;Driver&nbsp;
								</div>  
						</cfif>
					<cfelse>
						<h2 style="/*color:white;*/font-weight:bold;">#variables.freightBroker# </h2>
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
            
				<a href="javascript:void(0);" id="LinkRemoveCarrier#stopNumber#"  onClick="#carrierLinksOnClick#; chooseCarrierNext(#stopNumber#);"   <cfif ( ( structkeyexists(url,"loadid") and len(trim(url.loadid)) gt 1 ) ) AND  carrierIDNext EQ "">style="display:none;"<cfelse>style="color:##236334"</cfif>>
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
      <div class="form-con carrierBlock#stopNumber#" style="width:400px;"><input type="hidden" name="carrier_id#stopNumber#" id="carrier_id#stopNumber#" value="#carrierIDNext#" data-limit="<cfif trim(carrierIDNext) NEQ "">#qgetcarier.LoadLimit#</cfif>">
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

			<div style="width:50%;float: left;" class="carrierrightdiv">
				<cfif request.qSystemSetupOptions.freightBroker EQ 0 OR (request.qSystemSetupOptions.freightBroker EQ 2 AND chckdCarrier EQ 0)>
                    <div style="width:195px;float:left;border: 1px solid ##b3b3b3;margin-left: -7px;margin-top: -45px;padding-top: 5px;margin-bottom: 5px;">
                        <label class="carrierrightlabel" style="width: 58% !important;">Custom Driver Pay</label>
                        <label class="switch switch-flat" style="padding: 0;width: 60px;height: 23px;">
                            <input class="switch-input CustomDriverPay" id="CustomDriverPay#stopNumber#" name="CustomDriverPay#stopNumber#" type="checkbox" onchange="customDriverPay(this);" <cfif CustomDriverPay EQ 1> checked </cfif>  />
                            <span class="switch-label" data-on="On" data-off="Off"></span> 
                            <span class="switch-handle"></span> 
                        </label>
                        <div class="divCustomDriverPayOptions" <cfif CustomDriverPay NEQ 1>style="display: none"</cfif>>
                            <span style="float: left;width: 39%;text-align: right;font-weight: bold;">Flat Rate $
                            </span> 
                            <input type="checkbox" class="small_chk myElements chkCustomDriverPayFlatRate" style="float: left;margin-left: 5px;" id="chkCustomDriverPayFlatRate#stopNumber#" name="chkCustomDriverPayFlatRate#stopNumber#" onclick="customDriverPayOption(this)" <cfif CustomDriverPayOption EQ 1> checked </cfif>> 

                            <span id="span_CustomDriverPayFlatRate#stopNumber#" class="span_CustomDriverPayFlatRate" <cfif CustomDriverPayOption NEQ 1>style="display:none;"</cfif>>
	                            <span style="float: left;">$</span>
	                            <input type="text" style="width: 40px;margin-left: 5px;" class="customDriverPayFlatRate" id="customDriverPayFlatRate#stopNumber#" name="customDriverPayFlatRate#stopNumber#" onchange="calculateCustomDriverPay()" value="#customDriverPayFlatRate#">
	                        </span>
                            <div class="clear"></div>

                            <span style="float: left;width: 39%;text-align: right;font-weight: bold;">Percentage %
                            </span> 
                            <input type="checkbox" class="small_chk myElements chkCustomDriverPayPercentage" style="float: left;margin-left: 5px;" id="chkCustomDriverPayPercentage#stopNumber#" name="chkCustomDriverPayPercentage#stopNumber#" onclick="customDriverPayOption(this)" <cfif CustomDriverPayOption EQ 2> checked </cfif>> 
                            
                            <span id="span_CustomDriverPayPercentage#stopNumber#" class="span_CustomDriverPayPercentage" <cfif CustomDriverPayOption NEQ 2>style="display:none;"</cfif>>
	                            <input type="text" style="width: 40px;" class="customDriverPayPercentage" id="customDriverPayPercentage#stopNumber#" name="customDriverPayPercentage#stopNumber#" onchange="calculateCustomDriverPay()" value="#customDriverPayPercentage#">
	                            <span style="float: left;">%</span>
	                        </span>
                        </div>
                    </div>
                    <div class="clear"></div>
                </cfif>
				<div style="width:200px;float:left;">
					<label class="carrierrightlabel">Driver 1</label>
					<input name="driver#stopNumber#" value="#driver#" type="text" tabindex="#evaluate(currentTab++)#" class="carriertextbox"  maxlength="50"/>
				</div>
				<div style="width:200px;float:left;">
					<label class="carrierrightlabel">Driver Cell</label>
					<input name="driverCell#stopNumber#" value="#driverCell#" type="text" tabindex="#evaluate(currentTab++)#" class="carriertextbox" maxlength="15"/>
				</div>
				<cfif NOT (request.qSystemSetupOptions.freightBroker EQ 0 OR (request.qSystemSetupOptions.freightBroker EQ 2 AND chckdCarrier EQ 0))>
					<div style="width:200px;float:left;">
						<label class="carrierrightlabel">Driver 2</label>
						<input name="Secdriver#stopNumber#" value="#driver2#" type="text" tabindex="#evaluate(currentTab++)#" class="carriertextbox" maxlength="50"/>
					</div>
					<div style="width:200px;float:left;">
						<label class="carrierrightlabel">Driver Cell</label>
						<input name="secDriverCell#stopNumber#" value="#secDriverCell#" type="text" tabindex="#evaluate(currentTab++)#" class="carriertextbox" maxlength="15"/>
					</div>
				</cfif>
				<div style="width:200px;float:left;">
					<label class="carrierrightlabel">Truck ##</label>
					<input name="truckNo#stopNumber#" id="truckNo#stopNumber#" value="#truckNo#" type="text" tabindex="#evaluate(currentTab++)#" class="carriertextbox"  maxlength="20"/>
				</div>
				<div style="width:200px;float:left;">
					<label class="carrierrightlabel">Trailer ##</label>
					<input name="TrailerNo#stopNumber#" value="#TrailerNo#" type="text" tabindex="#evaluate(currentTab++)#" class="carriertextbox" maxlength="20"/>
				</div>
				<div style="width:200px;float:left;">
					<label class="carrierrightlabel">Ref ##</label>
					<input name="refNo#stopNumber#" value="#refNo#" type="text" tabindex="#evaluate(currentTab++)#" class="carriertextbox" maxlength="50"/>
				</div>
				<div style="width:200px;float:left;">
					<label class="carrierrightlabel">Miles ##</label>
					<input name="milse#stopNumber#" class="careermilse carriertextbox" id="milse#stopNumber#" value="#milse#" type="text" onclick="showWarningEnableButton('block','#stopNumber#');" onblur="showWarningEnableButton('none','#stopNumber#');changeQuantityWithValue(this,#stopNumber#);" onChange="changeQuantity(this.id,this.value,'unit');calculateTotalRates('#application.DSN#');" tabindex="#evaluate(currentTab++)#" style="width:81px !important;"/>
					<input id="refreshBtn#stopNumber#" title="Refresh Miles" value=" " type="button" class="bttn" onclick="refreshMilesClicked('#stopNumber#');" style="width:17px; height:22px; background: url('images/refresh.png');"/>
					<input id="milesUpdateMode#stopNumber#" name="milesUpdateMode#stopNumber#" type="hidden" value="auto" >
				</div>
				<div style="width:200px;float:left;">
					<label class="carrierrightlabel">Booked With</label>
					<input name="bookedWith#stopNumber#" id="bookedWith#stopNumber#" value="#bookedwith1#" type="text" tabindex="#evaluate(currentTab++)#" class="carriertextbox" maxlength="500" />
				</div>
			</div>
			<div style="width:50%;float: left;" class="carrierrightdiv">
				<div style="width:200px;float:left;position: relative;">
					<label class="carrierrightlabel">Equipment</label>
					<select name="equipment#stopNumber#" id="equipment#stopNumber#" tabindex="#evaluate(currentTab++)#" class="carriertextbox selEquipment" style="width: 116px !important;">
						<option value="">Select</option>
						<cfloop query="request.qEquipments">
							<option value="#request.qEquipments.equipmentID#" <cfif equipment1 is request.qEquipments.equipmentID> selected="selected" </cfif> data-temperature="#request.qEquipments.temperature#" data-temperaturescale="#request.qEquipments.temperaturescale#" data-type="#request.qEquipments.equipmenttype#" data-RelEquip="#request.qEquipments.RelEquip#" data-truckTrailer="#request.qEquipments.TruckTrailerOption#">#request.qEquipments.equipmentname#</option>
						</cfloop>
					</select>
				</div>
		        <div style="width:200px;float:left;position: relative;">
		            <label class="carrierrightlabel hyperLinkLabel">Trailer</label>
		            <select name="equipmentTrailer#stopNumber#" id="equipmentTrailer#stopNumber#" tabindex="#evaluate(currentTab++)#" class="carriertextbox">
		                <option value="">Select</option>
		                <cfloop query="request.qEquipments">
		                    <cfif listFindNoCase('Trailer,Other', request.qEquipments.EquipmentType)>
		                        <option <cfif equipmentTrailer is request.qEquipments.equipmentID> selected="selected" </cfif> value="#request.qEquipments.equipmentID#">#request.qEquipments.equipmentname#</option>
		                    </cfif>
		                </cfloop>
		            </select>
		        </div>
				<div style="width:200px;float:left;position: relative;">
                    <label style="text-align: left;width: 65px;"><strong>Temperature</strong></label>
                    <input type="text" name="temperature#stopNumber#" id="temperature#stopNumber#" value="#temperature#" size="4" maxlength="5" validate="float"  style="width:40px" message="Please  enter the valid Temperature" >
                    <label style="width: 5px;margin-top: -5px;margin-left: -5px;"><sup>o</sup></label>
                     <cfif request.qSystemSetupOptions.TemperatureSetting EQ 0>
                        <select name="temperaturescale#stopNumber#" id="temperaturescal#stopNumber#e" style="width:35px;">
                            <option value="C" <cfif temperaturescale EQ "C"> selected </cfif> >C</option>
                            <option value="F" <cfif temperaturescale EQ "F"> selected </cfif> >F</option>
                        </select>
                    <cfelseif request.qSystemSetupOptions.TemperatureSetting EQ 1>
                        F<input type="hidden" name="temperaturescale#stopNumber#" value="F">
                    <cfelse>
                        C<input type="hidden" name="temperaturescale#stopNumber#" value="C">
                    </cfif>
                </div>
				<div style="width:200px;float:left;position: relative;">
					<label class="carrierrightlabel">#request.qSystemSetupOptions.userDef1#</label>
					<input name="userDef1#stopNumber#" value="#userDef1#" type="text" tabindex="#evaluate(currentTab++)#" class="carriertextbox userOnchageUpdate" data-loadid="#url.loadid#"  data-stopNumber="#stopNumber#" data-inputname="userDef1"  maxlength="200"/>

				</div>
				<div style="width:200px;float:left;position: relative;">
					<label class="carrierrightlabel">#request.qSystemSetupOptions.userDef2#</label>
					<input name="userDef2#stopNumber#" value="#userDef2#" type="text" tabindex="#evaluate(currentTab++)#" class="carriertextbox userOnchageUpdate" data-loadid="#url.loadid#"  data-stopNumber="#stopNumber#" data-inputname="userDef2"  maxlength="200"/>

				</div>
				<div style="width:200px;float:left;position: relative;">
					<label class="carrierrightlabel">#request.qSystemSetupOptions.userDef3#</label>
					<input name="userDef3#stopNumber#" value="#userDef3#" type="text" tabindex="#evaluate(currentTab++)#" class="carriertextbox userOnchageUpdate" data-loadid="#url.loadid#"  data-stopNumber="#stopNumber#" data-inputname="userDef3"  maxlength="200"/>

				</div>
				<div style="width:200px;float:left;position: relative;">
					<label class="carrierrightlabel">#request.qSystemSetupOptions.userDef4#</label>
					<input name="userDef4#stopNumber#" value="#userDef4#" type="text" tabindex="#evaluate(currentTab++)#" class="carriertextbox userOnchageUpdate" data-loadid="#url.loadid#"  data-stopNumber="#stopNumber#" data-inputname="userDef4"  maxlength="200"/>

				</div>
				<div style="width:200px;float:left;position: relative;">
					<label class="carrierrightlabel">#request.qSystemSetupOptions.userDef5#</label>
					<input name="userDef5#stopNumber#" value="#userDef5#" type="text" tabindex="#evaluate(currentTab++)#" class="carriertextbox userOnchageUpdate" data-loadid="#url.loadid#"  data-stopNumber="#stopNumber#" data-inputname="userDef5" maxlength="200"/>

				</div>
				<div style="width:200px;float:left;">
					<label class="carrierrightlabel">#request.qSystemSetupOptions.userDef6#</label>
					<input name="userDef6#stopNumber#" value="#userDef6#" type="text" tabindex="#evaluate(currentTab++)#" class="carriertextbox userOnchageUpdate" data-loadid="#url.loadid#"  data-stopNumber="#stopNumber#" data-inputname="userDef6"  maxlength="200"/>

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
                        <div id="choosCarrier2_#stopNumber#" style="<cfif len(carrierID2_1) gt 0>display:none<cfelse>display:block</cfif>;"><input type="hidden" name="carrier_id2_#stopNumber#" id="carrier_id2_#stopNumber#" value="#carrierID2_1#" data-limit="0">
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
                        <cfinvoke component="#variables.objloadGateway#" method="getCarrierInfoForm" returnvariable="formHTML" carrierId="#carrierID2_1#" urlToken="#session.URLToken#" loadid='#cLoadID#' stopno="#stopnumber#" id="2_#stopnumber#"/>
                            #formHTML#
                        </div>
                        <label style="width: 102px !important;">Satellite Office</label>
                        <select name="stOffice" id="stOffice">
                            <option value="">Choose a Satellite Office Contact</option>
                            <cfloop query="request.qOffices">
                                <option value="#request.qOffices.CarrierOfficeID#" <cfif stofficeid is request.qOffices.CarrierOfficeID>selected ="selected"</cfif>>#request.qOffices.location#</option>
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
	                                    <input class="switch-input CustomDriverPay" id="CustomDriverPay2_#stopnumber#" name="CustomDriverPay2_#stopnumber#" type="checkbox" onchange="customDriverPay(this);" <cfif CustomDriverPay EQ 1> checked </cfif>/>
	                                    <span class="switch-label" data-on="On" data-off="Off"></span> 
	                                    <span class="switch-handle"></span> 
	                                </label>
	                                <div class="divCustomDriverPayOptions" <cfif CustomDriverPay NEQ 1>style="display: none"</cfif>>
	                                    <span style="float: left;width: 39%;text-align: right;font-weight: bold;">Flat Rate $
	                                    </span> 
	                                    <input type="checkbox" class="small_chk myElements chkCustomDriverPayFlatRate" style="float: left;margin-left: 5px;" id="chkCustomDriverPayFlatRate2_#stopnumber#" name="chkCustomDriverPayFlatRate2_#stopnumber#" onclick="customDriverPayOption(this)" <cfif CustomDriverPayOption EQ 1> checked </cfif>> 

	                                    <span id="span_CustomDriverPayFlatRate2_#stopnumber#" class="span_CustomDriverPayFlatRate" <cfif CustomDriverPayOption2 NEQ 1>style="display:none;"</cfif>>
	                                    <span style="float: left;">$</span>
		                                    <input type="text" style="width: 40px;margin-left: 5px;" class="customDriverPayFlatRate" id="customDriverPayFlatRate2_#stopnumber#" name="customDriverPayFlatRate2_#stopnumber#" onchange="calculateCustomDriverPay(this)" value="#CustomDriverPayFlatRate2#">
		                                </span>

	                                    <div class="clear"></div>

	                                    <span style="float: left;width: 39%;text-align: right;font-weight: bold;">Percentage %
	                                    </span> 
	                                    <input type="checkbox" class="small_chk myElements chkCustomDriverPayPercentage" style="float: left;margin-left: 5px;" id="chkCustomDriverPayPercentage2_#stopnumber#" name="chkCustomDriverPayPercentage2_#stopnumber#" onclick="customDriverPayOption(this)" <cfif CustomDriverPayOption EQ 2> checked </cfif>> 

	                                    <span id="span_CustomDriverPayPercentage2_#stopnumber#" class="span_CustomDriverPayPercentage" <cfif CustomDriverPayOption2 NEQ 2>style="display:none;"</cfif>>
		                                    <input type="text" style="width: 40px;" class="customDriverPayPercentage" id="customDriverPayPercentage2_#stopnumber#" name="customDriverPayPercentage2_#stopnumber#" onchange="calculateCustomDriverPay(this)" value="#customDriverPayPercentage2#">
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
                        <div id="choosCarrier3_#stopNumber#" style="<cfif len(carrierID3_1) gt 0>display:none<cfelse>display:block</cfif>;"><input type="hidden" name="carrier_id3_#stopNumber#" id="carrier_id3_#stopNumber#" value="#carrierID3_1#" data-limit="0">
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
                        <cfinvoke component="#variables.objloadGateway#" method="getCarrierInfoForm" returnvariable="formHTML" carrierId="#carrierID3_1#" urlToken="#session.URLToken#" loadid='#cLoadID#' stopno="#stopnumber#" id="3_#stopnumber#"/>
                            #formHTML#
                        </div>
                        <label style="width: 102px !important;">Satellite Office</label>
                        <select name="stOffice" id="stOffice">
                            <option value="">Choose a Satellite Office Contact</option>
                            <cfloop query="request.qOffices">
                                <option value="#request.qOffices.CarrierOfficeID#" <cfif stofficeid is request.qOffices.CarrierOfficeID>selected ="selected"</cfif>>#request.qOffices.location#</option>
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
                                        <input class="switch-input CustomDriverPay" id="CustomDriverPay3_#stopnumber#" name="CustomDriverPay3_#stopnumber#" type="checkbox" onchange="customDriverPay(this);" <cfif CustomDriverPay EQ 1> checked </cfif>/>
                                        <span class="switch-label" data-on="On" data-off="Off"></span> 
                                        <span class="switch-handle"></span> 
                                    </label>
                                    <div class="divCustomDriverPayOptions" style="<cfif CustomDriverPay NEQ 1>display: none;</cfif>">
                                        <span style="float: left;width: 39%;text-align: right;font-weight: bold;">Flat Rate $
                                        </span> 
                                        <input type="checkbox" class="small_chk myElements chkCustomDriverPayFlatRate" style="float: left;margin-left: 5px;" id="chkCustomDriverPayFlatRate3_#stopnumber#" name="chkCustomDriverPayFlatRate3_#stopnumber#" onclick="customDriverPayOption(this)" <cfif CustomDriverPayOption EQ 1> checked </cfif>> 

                                        <span id="span_CustomDriverPayFlatRate3_#stopnumber#" class="span_CustomDriverPayFlatRate" <cfif CustomDriverPayOption3 NEQ 1>style="display:none;"</cfif>>
                                        	<span style="float: left;">$</span>
	                                        <input type="text" style="width: 40px;margin-left: 5px;" class="customDriverPayFlatRate" id="customDriverPayFlatRate3_#stopnumber#" name="customDriverPayFlatRate3_#stopnumber#" onchange="calculateCustomDriverPay(this)" value="#CustomDriverPayFlatRate3#">
	                                    </span>
                                        <div class="clear"></div>

                                        <span style="float: left;width: 39%;text-align: right;font-weight: bold;">Percentage %
                                        </span> 
                                        <input type="checkbox" class="small_chk myElements chkCustomDriverPayPercentage" style="float: left;margin-left: 5px;" id="chkCustomDriverPayPercentage3_#stopnumber#" name="chkCustomDriverPayPercentage3_#stopnumber#" onclick="customDriverPayOption(this)" <cfif CustomDriverPayOption EQ 2> checked </cfif>> 
                                        <span id="span_CustomDriverPayPercentage3_#stopnumber#" class="span_CustomDriverPayPercentage" <cfif CustomDriverPayOption3 NEQ 2>style="display:none;"</cfif>>
	                                        <input type="text" style="width: 40px;" class="customDriverPayPercentage" id="customDriverPayPercentage3_#stopnumber#" name="customDriverPayPercentage3_#stopnumber#" onchange="calculateCustomDriverPay(this)" value="#CustomDriverPayPercentage3#">
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
                        <div class="clear"></div>
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
                                <cfif request.qLoadCarrierQuotes.recordcount>
                                    <cfloop query="request.qLoadCarrierQuotes">
                                        <cfif request.qLoadCarrierQuotes.StopNo eq stopNumber>
                                            <tr>
                                                <td id="quoteAmount_#request.qLoadCarrierQuotes.CarrierQuoteID#_#stopNumber#">
	                                                #DollarFormat(request.qLoadCarrierQuotes.Amount)#
	                                            </td>
                                                <td><p onclick="openCarrierQuote(#request.qLoadCarrierQuotes.CarrierQuoteID#,#stopNumber#)" style="cursor: pointer;text-decoration: underline;color: ##0000ff;"><cfif request.qLoadCarrierQuotes.QUnknownCarrier>#request.qLoadCarrierQuotes.QCarrierName#<cfelse>#request.qLoadCarrierQuotes.CarrierName#</cfif></p></td>
                                                <td><cfif request.qLoadCarrierQuotes.QUnknownCarrier>#request.qLoadCarrierQuotes.QMCNumber#<cfelse>#request.qLoadCarrierQuotes.MCNumber#</cfif></td>
                                                <td><cfif request.qLoadCarrierQuotes.QUnknownCarrier>#request.qLoadCarrierQuotes.QContactPerson#<cfelse>#request.qLoadCarrierQuotes.ContactPerson#</cfif></td>
                                                <td><cfif request.qLoadCarrierQuotes.QUnknownCarrier>#request.qLoadCarrierQuotes.QPhone#<cfelse>#request.qLoadCarrierQuotes.Phone#</cfif></td>
                                                <td>#request.qLoadCarrierQuotes.Active#</td>
                                                <td id="quoteMiles_#request.qLoadCarrierQuotes.CarrierQuoteID#_#stopNumber#">#request.qLoadCarrierQuotes.Miles#</td>
                                                <td id="quotePricePerMiles_#request.qLoadCarrierQuotes.CarrierQuoteID#_#stopNumber#">
	                                                <cfif request.qLoadCarrierQuotes.Amount GT 0 AND request.qLoadCarrierQuotes.Miles GT 0>
	                                                #DollarFormat(request.qLoadCarrierQuotes.Amount/request.qLoadCarrierQuotes.Miles)#
	                                                <cfelse>
	                                                    N/A
	                                                </cfif>
                                            	</td>
                                                <td id="quoteEquipmentName_#request.qLoadCarrierQuotes.CarrierQuoteID#_#stopNumber#">#request.qLoadCarrierQuotes.EquipmentName#</td>
                                                <td id="quoteCreatedBy_#request.qLoadCarrierQuotes.CarrierQuoteID#_#stopNumber#">#request.qLoadCarrierQuotes.CreatedBy#</td>
                                                <td id="quoteUpdatedBy_#request.qLoadCarrierQuotes.CarrierQuoteID#_#stopNumber#">#request.qLoadCarrierQuotes.ModifiedBy#</td>
                                                <td id="quoteAddBook_#request.qLoadCarrierQuotes.CarrierQuoteID#_#stopNumber#">
                                                    <input type="button" value="<cfif request.qLoadCarrierQuotes.QUnknownCarrier>Add<cfelse>Book</cfif>" 
                                                        <cfif request.qLoadCarrierQuotes.QUnknownCarrier>
                                                            onclick="addQuoteCarrier('#stopNumber#','#request.qLoadCarrierQuotes.Amount#','#request.qLoadCarrierQuotes.CarrierQuoteID#')"
                                                        <cfelse>
                                                            onclick="bookQuote('#stopNumber#','#request.qLoadCarrierQuotes.carrierid#','#request.qLoadCarrierQuotes.Amount#')"
                                                        </cfif>
                                                         style="width:50px !important;height: 17px;">
                                                </td>
                                            </tr>
                                        </cfif>
                                    </cfloop>
                                <cfelse>
                                    <tr>
                                        <td colspan="10" class="noQuotesMsg">No Quotes Found</td>
                                    </tr>
                                </cfif>
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
                                <input class="quote-carrier-box" data-stop="#stopNumber#" style="margin-left: 0;width: 230px !important;" type="text" title="Type text here to display list."/>
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
      <div class="white-con-area" style="height: 36px;background-color: ##82bbef;;width: 932px;">
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
                  			<input <cfif structkeyexists(session,"rightslist") and NOT ListContains(session.rightsList,'ComData',',') AND ListContains('ComData-Fuel,ComData-CashAdvance',request.qItems.description,',')> style="opacity: 0.5;" onclick="return false;"</cfif> name="isFee#stopNumber#_#request.qItems.currentRow#" id="isFee#stopNumber#_#request.qItems.currentRow#" class="check isFee" <cfif request.qItems.fee is 1> checked="checked" </cfif> type="checkbox" tabindex="#evaluate(currentTab+1)#"/>
                  		</td>
                  		<td class="normaltdC" valign="middle" align="left">
                  			<input <cfif structkeyexists(session,"rightslist") and NOT ListContains(session.rightsList,'ComData',',') AND ListContains('ComData-Fuel,ComData-CashAdvance',request.qItems.description,',')> style="opacity: 0.5;" readonly</cfif> name="qty#stopNumber#_#request.qItems.currentRow#" id="qty#stopNumber#_#request.qItems.currentRow#" onchange="CalculateTotal('#Application.dsn#')" class="qty q-textbox" type="text" value="#request.qItems.qty#"  tabindex="#evaluate(currentTab+1)#"/>
                  		</td>

                  		<td class="normaltdC" valign="middle" align="left">
							<select <cfif structkeyexists(session,"rightslist") and NOT ListContains(session.rightsList,'ComData',',') AND ListContains('ComData-Fuel,ComData-CashAdvance',request.qItems.description,',')>  style="opacity: 0.5;pointer-events: none;" </cfif> name="unit#stopNumber#_#request.qItems.currentRow#" id="unit#stopNumber#_#request.qItems.currentRow#" class="t-select unit typeSelect#stopNumber#" onchange="changeQuantityWithtype(this,#stopNumber#);checkForFee(this.value,'#request.qItems.currentRow#','#stopNumber#','#application.dsn#'); autoloaddescription(this, '#stopNumber#', '#request.qItems.currentRow#','#application.dsn#');" tabindex="#evaluate(currentTab+1)#">
								<option value=""></option>
								<cfloop query="request.qUnits">
									<option value="#request.qUnits.unitID#" <cfif request.qUnits.unitID is request.qItems.unitid> selected="selected" </cfif>>#request.qUnits.unitName#<cfif trim(request.qUnits.unitCode) neq ''>(#request.qUnits.unitCode#)</cfif></option>
								</cfloop>
                    		</select>
                    	</td>

                  		<td class="normaltdC" valign="middle" align="left">
                  			<input <cfif structkeyexists(session,"rightslist") and NOT ListContains(session.rightsList,'ComData',',') AND ListContains('ComData-Fuel,ComData-CashAdvance',request.qItems.description,',')> style="opacity: 0.5;width:#descriptionWidth#px;" Readonly <cfelse>style="width:#descriptionWidth#px;"</cfif> name="description#stopNumber#_#request.qItems.currentRow#" id="description#stopNumber#_#request.qItems.currentRow#" class="t-textbox" value="#replace(request.qItems.description,'"','&quot;','all')#" type="text" tabindex="#evaluate(currentTab+1)#" />
                  		</td>

                  		<td class="normaltdC" valign="middle" align="left">
                  			<input <cfif structkeyexists(session,"rightslist") and NOT ListContains(session.rightsList,'ComData',',') AND ListContains('ComData-Fuel,ComData-CashAdvance',request.qItems.description,',')> style="opacity: 0.5;width:58px;" Readonly <cfelse>style="width:58px;"</cfif> name="dimensions#stopNumber#_#request.qItems.currentRow#" id="dimensions#stopNumber#_#request.qItems.currentRow#" class="t-textbox" value="#replace(request.qItems.dimensions,'"','&quot;','all')#" type="text" tabindex="#evaluate(currentTab+1)#" maxlength="150"/>
                  		</td>

				  		<cfif request.qSystemSetupOptions.commodityWeight>
							<td class="normaltdC" valign="middle" align="left">
								<input <cfif structkeyexists(session,"rightslist") and NOT ListContains(session.rightsList,'ComData',',') AND ListContains('ComData-Fuel,ComData-CashAdvance',request.qItems.description,',')> style="opacity: 0.5;" Readonly</cfif> name="weight#stopNumber#_#request.qItems.currentRow#" id="weight#stopNumber#_#request.qItems.currentRow#" class="wt-textbox" value="#request.qItems.weight#" type="text" tabindex="#evaluate(currentTab+1)#" />
							</td>
				  		</cfif>
                  		<td class="normaltdC" valign="middle" align="left">
                  			<select <cfif structkeyexists(session,"rightslist") and NOT ListContains(session.rightsList,'ComData',',') AND ListContains('ComData-Fuel,ComData-CashAdvance',request.qItems.description,',')>  style="width:60px;opacity: 0.5;pointer-events: none;"<cfelse> style="width:60px;" </cfif> name="class#stopNumber#_#request.qItems.currentRow#" id="class#stopNumber#_#request.qItems.currentRow#" class="t-select" tabindex="#evaluate(currentTab+1)#">
	                      		<option></option>
	                      		<cfloop query="request.qClasses">
	                        		<option value="#request.qClasses.classId#" <cfif request.qClasses.classId is request.qItems.classid> selected="selected" </cfif>>#request.qClasses.className#
	                        		</option>
	                      		</cfloop>
                    		</select>
                    		<cfif structkeyexists(session,"rightslist") and NOT ListContains(session.rightsList,'ComData',',') AND ListContains('ComData-Fuel,ComData-CashAdvance',request.qItems.description,',')> 
                        		<input type="hidden" name="class#stopNumber#_#request.qItems.currentRow#" value="#request.qItems.classid#">
                    		</cfif> 
                		</td>

              <cfif request.qItems.CUSTRATE eq "">
                <cfset variables.CustomerRate = '0.00' >
              <cfelse>
                <cfset variables.CustomerRate = request.qItems.CUSTRATE >
              </cfif>
              <cfif request.qItems.CARRRATE eq "">
                <cfset variables.CarrierRate = '0.00' >
              <cfelse>
                <cfset variables.CarrierRate = request.qItems.CARRRATE >
              </cfif>
          		<cfif request.qSystemSetupOptions.ForeignCurrencyEnabled>
                <cfset variables.CustomerRate = replace((variables.CustomerRate),",","","ALL")>
              <cfelse>
                 <cfset variables.CustomerRate = replace(myCurrencyFormatter(variables.CustomerRate),",","","ALL")>
              </cfif>

              <cfif request.qSystemSetupOptions.ForeignCurrencyEnabled>
                 <cfset variables.CarrierRate = replace((variables.CarrierRate),",","","ALL")>
              <cfelse>
                <cfset variables.CarrierRate = replace(myCurrencyFormatter(variables.CarrierRate),",","","ALL")>
              </cfif>

              <cfif request.qItems.paymentadvance EQ 1>
                <cfif request.qItems.CUSTRATE GT 0>
                  <cfset variables.CustomerRate = "("&variables.CustomerRate&")">
                </cfif>
                <cfif request.qItems.CARRRATE GT 0>
                  <cfset variables.CarrierRate = "("&variables.CarrierRate&")">
                </cfif>
              </cfif>

					  	<cfset variables.carrierPercentage = 0 >
				  		<cfif isdefined("request.qItems.CarrRateOfCustTotal") and IsNumeric(request.qItems.CarrRateOfCustTotal)>
							<cfset variables.carrierPercentage = request.qItems.CarrRateOfCustTotal >
				  		</cfif>
				  
			  			<cfif NOT ListContains(session.rightsList,'HideCustomerPricing',',')>
				  			<td class="normaltdC" valign="middle" align="left">
				  				<input <cfif structkeyexists(session,"rightslist") and NOT ListContains(session.rightsList,'ComData',',') AND ListContains('ComData-Fuel,ComData-CashAdvance',request.qItems.description,',')> style="opacity: 0.5;" Readonly</cfif> name="CustomerRate#stopNumber#_#request.qItems.currentRow#" id="CustomerRate#stopNumber#_#request.qItems.currentRow#" onChange="CalculateTotal('#Application.dsn#');formatDollarNegative(this.value, this.id);" class="q-textbox CustomerRate" value="#variables.CustomerRate#" type="text" tabindex="#evaluate(currentTab+1)#" <cfif request.qItems.paymentadvance EQ 1>style="color: red;"</cfif>/>
				  			</td>
				 		<cfelse>
				 			<input type="hidden" name="CustomerRate#stopNumber#_#request.qItems.currentRow#" id="CustomerRate#stopNumber#_#request.qItems.currentRow#" <cfif request.qSystemSetupOptions.ForeignCurrencyEnabled>value="#(variables.CustomerRate)#"<cfelse>value="#variables.CustomerRate#"</cfif>>
				 		</cfif>


					  	<td class="normaltd2C" valign="middle" align="left">
					  		<input <cfif structkeyexists(session,"rightslist") and NOT ListContains(session.rightsList,'ComData',',') AND ListContains('ComData-Fuel,ComData-CashAdvance',request.qItems.description,',')> style="opacity: 0.5;" Readonly</cfif> name="CarrierRate#stopNumber#_#request.qItems.currentRow#" id="CarrierRate#stopNumber#_#request.qItems.currentRow#" onChange="CalculateTotal('#Application.dsn#');formatDollarNegative(this.value, this.id);" class="q-textbox CarrierRate" value="#variables.CarrierRate#"  type="text" tabindex="#evaluate(currentTab+1)#" <cfif request.qItems.paymentadvance EQ 1>style="color: red;"</cfif>/>
					  	</td><!---myCurrencyFormatter(variables.CarrierRate)--->
				  

				 		<cfif NOT ListContains(session.rightsList,'HideCustomerPricing',',')>
							<td class="normaltd2C" valign="middle" align="left">
								<input <cfif structkeyexists(session,"rightslist") and NOT ListContains(session.rightsList,'ComData',',') AND ListContains('ComData-Fuel,ComData-CashAdvance',request.qItems.description,',')> style="opacity: 0.5;width:105px;" Readonly</cfif> onChange="ConfirmMessage('#request.qItems.currentRow#',#stopNumber#)" name="CarrierPer#stopNumber#_#request.qItems.currentRow#" id="CarrierPer#stopNumber#_#request.qItems.currentRow#" class="q-textbox CarrierPer" value="#variables.carrierPercentage#%" onChange=""  type="text" tabindex="#evaluate(currentTab+1)#" />
							</td>
						<cfelse>
							<input type="hidden" name="CarrierPer#stopNumber#_#request.qItems.currentRow#" id="CarrierPer#stopNumber#_#request.qItems.currentRow#"  value="#variables.carrierPercentage#%" >
						</cfif>

						<cfif len(trim(request.qItems.DirectCost))>
                            <cfset variables.directCost = request.qItems.DirectCost>
                        <cfelse>
                            <cfset variables.directCost = '0.00'>
                        </cfif>
						<cfif request.qSystemSetupOptions.UseDirectCost>
							<td class="normaltdC" valign="middle" align="left">
								<input name="directCost#stopNumber#_#request.qItems.currentRow#" id="directCost#stopNumber#_#request.qItems.currentRow#" class="q-textbox directCost" value="#myCurrencyFormatter(variables.directCost)#" type="text"<cfif request.qItems.paymentAdvance>style="background-color: ##e3e3e3;" Readonly
                                </cfif> onChange="CalculateTotal('#Application.dsn#');formatDollarNegative(this.value, this.id);" tabindex="#evaluate(currentTab+1)#"/>
							</td>
						<cfelse>
							<input name="directCost#stopNumber#_#request.qItems.currentRow#" id="directCost#stopNumber#_#request.qItems.currentRow#" value="#dollarFormat(variables.directCost)#" type="hidden"/>
						</cfif>

						<cfif NOT ListContains(session.rightsList,'HideCustomerPricing',',')>
							<td class="normaltdC" valign="middle" align="left">
								<input name="custCharges#stopNumber#_#request.qItems.currentRow#" id="custCharges#stopNumber#_#request.qItems.currentRow#" onchange="CalculateTotal('#Application.dsn#');" class="custCharges q-textbox" value="#request.qItems.custCharges#" type="text" style="background-color: ##e3e3e3;" readonly/>
							</td>
						<cfelse>
                			<input type="hidden" name="custCharges#stopNumber#_#request.qItems.currentRow#" id="custCharges#stopNumber#_#request.qItems.currentRow#" value="#request.qItems.custCharges#">
						</cfif>

                  		<td class="normaltd2C" valign="middle" align="left">
                  			<input name="carrCharges#stopNumber#_#request.qItems.currentRow#" id="carrCharges#stopNumber#_#request.qItems.currentRow#" onchange="CalculateTotal('#Application.dsn#');" class="carrCharges q-textbox" value="#request.qItems.carrCharges#" type="text" style="background-color: ##e3e3e3;" Readonly/>
                  		</td>
                  		<cfif len(trim(request.qItems.DirectCostTotal))>
                            <cfset variables.DirectCostTotal = request.qItems.DirectCostTotal>
                        <cfelse>
                            <cfset variables.DirectCostTotal = '0.00'>
                        </cfif>
                  		<cfif request.qSystemSetupOptions.UseDirectCost>
							<td class="normaltdC" valign="middle" align="left">
								<input name="directCostTotal#stopNumber#_#request.qItems.currentRow#" id="directCostTotal#stopNumber#_#request.qItems.currentRow#" class="q-textbox directCostTotal" value="#myCurrencyFormatter(variables.DirectCostTotal)#" type="text" style="background-color: ##e3e3e3;width: 60px;" Readonly/>
							</td>
						<cfelse>
							<input name="directCostTotal#stopNumber#_#request.qItems.currentRow#" id="directCostTotal#stopNumber#_#request.qItems.currentRow#" value="#dollarFormat(variables.DirectCostTotal)#" type="hidden"/>
						</cfif>

                  		<td class="normaltdC" valign="middle" align="left">
                  			<img onclick="delRowCommodities(this)" name="delComm#stopNumber#_#request.qItems.currentRow#" id="delComm#stopNumber#_#request.qItems.currentRow#" src="images/delete-icon-red.gif" style="width:10px;margin-left: 5px;cursor: pointer;float: left">
                  			<img name="sortComm#stopNumber#_#request.qItems.currentRow#" id="sortComm#stopNumber#_#request.qItems.currentRow#" src="images/sort.png" style="width:12px;margin-left: 5px;cursor: pointer">
                  			<input type="hidden" name="commStopId#stopNumber#_#request.qItems.currentRow#" id="commStopId#stopNumber#_#request.qItems.currentRow#" value="<cfif structKeyExists(url, "loadToBeCopied") and len(trim(url.loadToBeCopied)) gt 1>0<cfelse>#request.qItems.LoadStopCommoditiesID#</cfif>">
                            <input type="hidden" name="commSrNo#stopNumber#_#request.qItems.currentRow#" id="commSrNo#stopNumber#_#request.qItems.currentRow#" value="#request.qItems.SrNo#">
                  		</td>
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
                  			<select name="unit#stopNumber#_#rowNum#" id="unit#stopNumber#_#rowNum#" class="unit t-select" onchange="changeQuantityWithtype(this,#stopNumber#);checkForFee(this.value,'#rowNum#','#stopNumber#','#application.dsn#')" tabindex="#evaluate(currentTab+1)#">
	                      		<option value=""></option>
	                      		<cfloop query="request.qUnits">
	                        		<option value="#request.qUnits.unitID#">#request.qUnits.unitName#<cfif trim(request.qUnits.unitCode) neq ''>(#request.qUnits.unitCode#)</cfif></option>
	                      		</cfloop>
                    		</select>
                    	</td>
                  		<td class="normaltdC" valign="middle" align="left">
                  			<input name="description#stopNumber#_#rowNum#" id="description#stopNumber#_#rowNum#" class="t-textbox" type="text" tabindex="#evaluate(currentTab+1)#" style="width:#descriptionWidth#px;"/>
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
					  			<input name="CustomerRate#stopNumber#_#rowNum#" id="CustomerRate#stopNumber#_#rowNum#" tabindex="#evaluate(currentTab+1)#" onChange="CalculateTotal('#Application.dsn#');formatDollarNegative(this.value, this.id);" class="CustomerRate q-textbox"  type="text" <cfif request.qSystemSetupOptions.ForeignCurrencyEnabled>value="0.00"<cfelse>value="$0.00"</cfif> />
					  		</td><!---$--->
					  	<cfelse>
					  		<input name="CustomerRate#stopNumber#_#rowNum#" id="CustomerRate#stopNumber#_#rowNum#" type="hidden" <cfif request.qSystemSetupOptions.ForeignCurrencyEnabled>value="0.00"<cfelse>value="$0.00"</cfif> />
					  	</cfif>
				  		<td class="normaltd2C" valign="middle" align="left">
				  			<input name="CarrierRate#stopNumber#_#rowNum#" id="CarrierRate#stopNumber#_#rowNum#" tabindex="#evaluate(currentTab+1)#"  onChange="CalculateTotal('#Application.dsn#');formatDollarNegative(this.value, this.id);" class="CarrierRate q-textbox"  type="text" <cfif request.qSystemSetupOptions.ForeignCurrencyEnabled>value="0.00"<cfelse>value="$0.00"</cfif>/>
				  		</td>

				  		<cfif NOT ListContains(session.rightsList,'HideCustomerPricing',',')>
				  			<td class="normaltd2C" valign="middle" align="left">
				  				<input name="CarrierPer#stopNumber#_#rowNum#" id="CarrierPer#stopNumber#_#rowNum#" class="q-textbox CarrierPer" value="0.00%" onChange="ConfirmMessage('#rowNum#',#stopNumber#)"  type="text" tabindex="#evaluate(currentTab+1)#" />
				  			</td>
				  		<cfelse>
				  			<input name="CarrierPer#stopNumber#_#rowNum#" id="CarrierPer#stopNumber#_#rowNum#" value="0.00%"  type="hidden"  />
				  		</cfif>

				  		<cfif request.qSystemSetupOptions.UseDirectCost>
							<td class="normaltdC" valign="middle" align="left">
								<input name="directCost#stopNumber#_#rowNum#" id="directCost#stopNumber#_#rowNum#" class="q-textbox directCost" type="text" value="$0.00" tabindex="#evaluate(currentTab+1)#" onChange="CalculateTotal('#Application.dsn#');formatDollarNegative(this.value, this.id);"  tabindex="#evaluate(currentTab+1)#"/>
							</td>
						<cfelse>
							<input name="directCost#stopNumber#_#rowNum#" id="directCost#stopNumber#_#rowNum#" type="hidden" value="$0.00"/>
						</cfif>

						<cfif NOT ListContains(session.rightsList,'HideCustomerPricing',',')>
				  			<td class="normaltdC" valign="middle" align="left">
				  				<input name="custCharges#stopNumber#_#rowNum#" id="custCharges#stopNumber#_#rowNum#" onchange="CalculateTotal('#Application.dsn#');" class="custCharges q-textbox" type="text" value="$0.00" tabindex="#evaluate(currentTab+1)#" readonly style="background-color: ##e3e3e3;"/>
				  			</td>
				  		<cfelse>
				  			<input name="custCharges#stopNumber#_#rowNum#" id="custCharges#stopNumber#_#rowNum#" type="hidden" value="$0.00"/>
				  		</cfif>

			  			
              			<td class="normaltd2C" valign="middle" align="left">
              				<input name="carrCharges#stopNumber#_#rowNum#" id="carrCharges#stopNumber#_#rowNum#" onchange="CalculateTotal('#Application.dsn#');" class="carrCharges q-textbox" type="text"  value="$0.00" tabindex="#evaluate(currentTab+1)#" readonly style="background-color: ##e3e3e3;"/>
              			</td>

              			<cfif request.qSystemSetupOptions.UseDirectCost>
							<td class="normaltdC" valign="middle" align="left">
								<input name="directCostTotal#stopNumber#_#rowNum#" id="directCostTotal#stopNumber#_#rowNum#" class="q-textbox directCostTotal" type="text" value="$0.00" tabindex="#evaluate(currentTab+1)#" readonly style="background-color: ##e3e3e3;width: 60px;"/>
							</td>
						<cfelse>
							<input name="directCostTotal#stopNumber#_#rowNum#" id="directCostTotal#stopNumber#_#rowNum#" type="hidden" value="$0.00" />
						</cfif>

              			<td class="normaltdC" valign="middle" align="left">
              				<img onclick="delRowCommodities(this)" name="delComm#stopNumber#_#request.qItems.currentRow#" id="delComm#stopNumber#_#request.qItems.currentRow#" src="images/delete-icon-red.gif" style="width:10px;margin-left: 5px;cursor: pointer">
              				<img name="sortComm#stopNumber#_#request.qItems.currentRow#" id="sortComm#stopNumber#_#request.qItems.currentRow#" src="images/sort.png" style="width:12px;margin-left: 5px;cursor: pointer">

              			</td>
              			<td class="normal-td3C normal-td3">&nbsp;</td>
            		</tr>
         		</cfloop>
            </cfif>
        </tbody>
    	<tfoot>
          	<cfif  loadIDN neq "" and showItems is true>
				<input type="hidden" value="#request.qItems.Recordcount#" name="TotalrowCommodities#stopNumber#"  id="TotalrowCommodities#stopNumber#">
               <input type="hidden" value="#request.qItems.Recordcount#" name="totalResult#stopNumber#"  id="totalResult#stopNumber#">
               <input type="hidden" value="#request.qItems.Recordcount#" name="commoditityAlreadyCount#stopNumber#"  id="commoditityAlreadyCount#stopNumber#">
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
				search: function(event, ui){$(this).autocomplete('option', 'source', $(this).autocomplete('option', 'source') +$("##shipperPickupDate"+(($(this).data("stop") == 1) ? "" : $(this).data("stop"))).val() + '&deliverydate=' + $("##consigneePickupDate"+(($(this).data("stop") == 1) ? "" : $(this).data("stop"))).val())},
				source: 'searchCarrierAutoFill.cfm?queryType=getCustomers&iscarrier='+val+'&companyid=#session.companyid#&loadid=#loadid#&pickupdate=',
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
					alert("Warning!! This #variables.freightBroker# has expired insurance, please make sure this carrier's insurance is updated.");
					if(! (#request.qSystemSetupOptions.AllowBooking#)){
						$(this).val('');
                        return false;
					}
				}
				
				document.getElementById("CarrierInfo"+stopNumber).style.display = 'block';
				document.getElementById('choosCarrier'+stopNumber).style.display = 'none';
				DisplayIntextFieldNext(ui.item.value, "'"+stopNumber+"'",'#Application.dsn#');
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

				if((ui.item.unitNumber.trim() != "") && (ui.item.unitNumber != -1)){
					$("##truckNo"+stopNumber).val(ui.item.unitNumber);
				}
				$("##LinkRemoveCarrier"+stopNumber).show();
				return false;
			}
            });
            $("##selectedCarrier"+stopNumber).data("ui-autocomplete")._renderItem = function(ul, item) {
               if(item.risk_assessment != ""){
                    var url = "<a target='_blank' href='"+item.link+"'><img src='"+item.risk_assessment+"' alt='Risk Assement Icon'></a>";
                }else{
                    var url = "";
                }

			   return $( "<li>"+item.name+"<br/><b><u>City</u>:</b> "+ item.city+"&nbsp;&nbsp;&nbsp;<b><u>State</u>:</b>" + item.state+"&nbsp;&nbsp;&nbsp;<b><u>Zip</u>:</b> " + item.zip+"&nbsp;&nbsp;&nbsp;<b><u>Insurance Expiry</u>:</b> " + item.InsExpDate+"</li>" )
					.appendTo( ul );
            }
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
				$('##'+this.id+'Notes').val(ui.item.notes);
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
	// Customer TropBox
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
    $('##selectedCarrierValue#stopNumber#').keyup(function(){
        $('.spinner#stopNumber#').show();
        if(!$.trim($(this).val()).length){
           $('.spinner#stopNumber#').hide(); 
        }
    });
    DriverContactAutoComplete('#stopNumber#');
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
			search: function(event, ui){$(this).autocomplete('option', 'source', 'searchCarrierAutoFill.cfm?queryType=getCustomers&IsCarrier=#chckdCarrier#&companyid=#session.companyid#&loadid=#loadid#&pickupdate=' + $("##shipperPickupDate"+(($(this).data("stop") == 1) ? "" : $(this).data("stop"))).val() + '&deliverydate=' + $("##consigneePickupDate"+(($(this).data("stop") == 1) ? "" : $(this).data("stop"))).val())},
			source: 'searchCarrierAutoFill.cfm?queryType=getCustomers&IsCarrier=#chckdCarrier#&companyid=#session.companyid#&loadid=#loadid#&pickupdate=',
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
				<cfif ( structkeyexists(url,"loadid") and len(trim(url.loadid)) gt 1 )>
                    loadCarrierAutoSave('#url.loadid#',ui.item.value,#(stopNumber-1)#,'#session.companyid#');
                </cfif>
				var strHtml = "<div class='clear'></div>"
					strHtml = strHtml + "<input name='carrierID#stopNumber#' id='carrierID#stopNumber#' type='hidden' value='"+ui.item.value+"' />"
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
					strHtml = strHtml + "<input name='CarrierEmailID#stopNumber#' data-carrID='"+ui.item.value+"' class='emailbox CarrEmail' value="+ui.item.email+">";
					strHtml = strHtml + "<div class='clear'></div>"
					strHtml = strHtml + "<label>Phone</label>"
					strHtml = strHtml + "<input type='text' name='CarrierPhoneNo#stopNumber#' value='"+ui.item.phoneNo+"' class='inp70px' onchange='ParseUSNumber(this);'>"
					strHtml = strHtml + "<input type='text' name='CarrierPhoneNoExt#stopNumber#' value='"+ui.item.phoneext+"' class='inp18px'>"
					strHtml = strHtml + "<label class='label45px'>Fax</label>"
					strHtml = strHtml + "<input type='text' name='CarrierFax#stopNumber#' value='"+ui.item.fax+"' class='inp70px' onchange='ParseUSNumber(this);'>"
					strHtml = strHtml + "<input type='text' name='CarrierFaxExt#stopNumber#' value='"+ui.item.faxext+"' class='inp18px'>"
					strHtml = strHtml + "<div class='clear'></div>"
					strHtml = strHtml + "<label>Toll Free</label>"
					strHtml = strHtml + "<input type='text' name='CarrierTollFree#stopNumber#' value='"+ui.item.tollfree+"' class='inp70px' onchange='ParseUSNumber(this);'>"
					strHtml = strHtml + "<input type='text' name='CarrierTollFreeExt#stopNumber#' value='"+ui.item.tollfreeext+"' class='inp18px'>"
					strHtml = strHtml + "<label class='label45px'>Cell</label>"
					strHtml = strHtml + "<input type='text' name='CarrierCell#stopNumber#' value='"+ui.item.cell+"' class='inp70px' onchange='ParseUSNumber(this);'>"
					strHtml = strHtml + "<input type='text' name='CarrierCellExt#stopNumber#' value='"+ui.item.cellphoneext+"' class='inp18px'>"
					if($.trim(ui.item.RemitName).length){
            strHtml = strHtml + "<div class='clear'></div>";
            strHtml = strHtml + '<label style="width: 102px !important;">Factoring Co.</label>';
            strHtml = strHtml + '<label class="field-text disabledLoadInputs" style="width:273px !important">'+ui.item.RemitName+'</label>';
          }
				if(ui.item.iscarrier == 1 && ui.item.insuranceExpired == 'yes')
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
                        autoFocus: true,
                        source: 'searchCarrierContactAutoFill.cfm?carrierID='+carrID,
                        select: function(e, ui) {
                        	alert();
                        	$('##CarrierPhoneNo#stopNumber#').val(ui.item.phoneno);
                            $('##CarrierPhoneNoExt#stopNumber#').val(ui.item.phonenoext);
                            $('##CarrierFax#stopNumber#').val(ui.item.fax);
                            $('##CarrierFaxExt#stopNumber#').val(ui.item.faxext);
                            $('##CarrierTollFree#stopNumber#').val(ui.item.tollfree);
                            $('##CarrierTollFreeExt#stopNumber#').val(ui.item.tollfreeext);
                            $('##CarrierCell#stopNumber#').val(ui.item.PersonMobileNo);
                            $('##CarrierCellExt#stopNumber#').val(ui.item.MobileNoExt);
                        },
                    })
                    $(tag).data("ui-autocomplete")._renderItem = function(ul, item) {
                        return $( "<li><b><u>Email</u>:</b>"+item.email+"<br/><b><u>Contact</u>:</b> "+ item.ContactPerson+"&nbsp;&nbsp;&nbsp;<b><u>Phone</u>:</b> "+ item.phoneno+"<br/><b><u>cell</u>:</b>" + item.PersonMobileNo+"&nbsp;&nbsp;&nbsp;<b><u>Type</u>:</b> " + item.ContactType+"</li>" )
                    .appendTo( ul );
                    }
                })
				CarrierContactAutoComplete();
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
				
				if((ui.item.unitNumber.trim() != "") && (ui.item.unitNumber != -1)){
					$("##truckNo#stopNumber#").val(ui.item.unitNumber);
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
				<cfif ( structkeyexists(url,"loadid") and len(trim(url.loadid)) gt 1 )>
                    //loadCarrierAutoSave('#url.loadid#',ui.item.value,#(stopNumber-1)#,'#session.companyid#');
                </cfif>
				var strHtml = "<div class='clear'></div>"
					strHtml = strHtml + "<input name='carrierID2_#stopNumber#' id='carrierID2_#stopNumber#' type='hidden' value='"+ui.item.value+"' />"
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
				if(ui.item.iscarrier == 1 && ui.item.insuranceExpired == 'yes')
                {
					alert("Warning!! This #variables.freightBroker# has expired insurance, please make sure this carrier's insurance is updated.");
					if(! (#request.qSystemSetupOptions.AllowBooking#)){
						$(this).val('');
                        return false;
					}
				}
				
				document.getElementById("CarrierInfo2_#stopNumber#").style.display = 'block';
				document.getElementById('choosCarrier2_#stopNumber#').style.display = 'none';
				//DisplayIntextFieldNext(ui.item.value, '#stopNumber#','#Application.dsn#');
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
                    })
                    $(tag).data("ui-autocomplete")._renderItem = function(ul, item) {
                        return $( "<li><b><u>Email</u>:</b>"+item.email+"<br/><b><u>Contact</u>:</b> "+ item.ContactPerson+"&nbsp;&nbsp;&nbsp;<b><u>Phone</u>:</b> "+ item.phoneno+"<br/><b><u>cell</u>:</b>" + item.PersonMobileNo+"&nbsp;&nbsp;&nbsp;<b><u>Type</u>:</b> " + item.ContactType+"</li>" )
                    .appendTo( ul );
                    }
                })
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
				<cfif ( structkeyexists(url,"loadid") and len(trim(url.loadid)) gt 1 )>
                    //loadCarrierAutoSave('#url.loadid#',ui.item.value,#(stopNumber-1)#,'#session.companyid#');
                </cfif>
				var strHtml = "<div class='clear'></div>"
					strHtml = strHtml + "<input name='carrierID3_#stopNumber#' id='carrierID3_#stopNumber#' type='hidden' value='"+ui.item.value+"' />"
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
				if(ui.item.iscarrier == 1 && ui.item.insuranceExpired == 'yes')
                {
					alert("Warning!! This #variables.freightBroker# has expired insurance, please make sure this carrier's insurance is updated.");
					if(! (#request.qSystemSetupOptions.AllowBooking#)){
						$(this).val('');
                        return false;
					}
				}
				
				document.getElementById("CarrierInfo3_#stopNumber#").style.display = 'block';
				document.getElementById('choosCarrier3_#stopNumber#').style.display = 'none';
				//DisplayIntextFieldNext(ui.item.value, '#stopNumber#','#Application.dsn#');
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
                    })
                    $(tag).data("ui-autocomplete")._renderItem = function(ul, item) {
                        return $( "<li><b><u>Email</u>:</b>"+item.email+"<br/><b><u>Contact</u>:</b> "+ item.ContactPerson+"&nbsp;&nbsp;&nbsp;<b><u>Phone</u>:</b> "+ item.phoneno+"<br/><b><u>cell</u>:</b>" + item.PersonMobileNo+"&nbsp;&nbsp;&nbsp;<b><u>Type</u>:</b> " + item.ContactType+"</li>" )
                    .appendTo( ul );
                    }
                })
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
    })

</script>
</cfoutput>