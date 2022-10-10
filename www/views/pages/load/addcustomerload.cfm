<cfset AuthLevel = "Sales Representative,Manager,Dispatcher,Administrator,Central Dispatcher">
<cfinvoke component="#variables.objloadGateway#" AuthLevel="#AuthLevel#" method="getloadSalesPerson" returnvariable="request.qSalesPerson" />
<cfinvoke component="#variables.objloadGateway#" method="getSystemSetupOptions" returnvariable="request.qSystemSetupOptions" />
<cfinvoke component="#variables.objequipmentGateway#" method="getloadEquipments" returnvariable="request.qEquipments" />
<cfinvoke component="#variables.objcustomerGateway#" method="getloadCustomer" returnvariable="request.qCustomer" />
<cfinvoke component="#variables.objAgentGateway#" method="getAllStaes" returnvariable="request.qStates" />
<cfinvoke component="#variables.objunitGateway#" method="getloadUnits" status="True" returnvariable="request.qUnits" />
<cfinvoke component="#variables.objclassGateway#" method="getloadClasses" status="True" returnvariable="request.qClasses" />

<cfparam name="url.LoadID" default="">
<cfparam name="viewCopyOnly" default="0">
<cfset Secret = application.dsn>
<cfset TheKey = 'NAMASKARAM'>
<cfset Encrypted = Encrypt(Secret, TheKey)>
<cfset dsn = URLEncodedFormat(ToBase64(Encrypted))>
<cfif structkeyexists(session,"customerid")>
    <cfset variables.s_id = session.customerid>
<cfelse>
    <cfset variables.s_id = session.empid>
</cfif>
<cfif structKeyExists(url,"loadToBeCopied")>
    <cfinvoke component="#variables.objcustomerloadGateway#" method="GetCustomerLoadCopy" LoadID="#url.loadToBeCopied#" returnvariable="request.qLoad">
<cfelse>
    <cfinvoke component="#variables.objcustomerloadGateway#" method="GetCustomerLoad" LoadID="#url.LoadID#" returnvariable="request.qLoad">
    <cfif (len(trim(request.qLoad.StatusText)) AND trim(request.qLoad.StatusText) NEQ '0.1 EDI')>
        <cfset viewCopyOnly = 1>
    </cfif>
</cfif>

<cfinvoke component="#variables.objloadGateway#" method="getloadAttachedFiles" linkedid="#url.loadID#" fileType="1" returnvariable="request.filesAttached" />

<cfoutput>
    <style type="text/css">
        .white-mid div.form-con fieldset input {
            margin-bottom: 3px !important;
        }
        .white-mid div.form-con fieldset textarea {
            margin-bottom: 3px !important;
        }
        .white-mid div.form-con fieldset select {
            margin-bottom: 3px !important;
        }
        .head-l{
            border-left: 1px solid ##5d8cc9;border-top-left-radius: 5px;
        }
        .head-r{
            border-top-right-radius: 5px;
        }
        .body-l{
           border-left: 1px solid ##5d8cc9; 
        }
        .body-r{
           border-right: 1px solid ##5d8cc9; 
        }
        .footer-bg{
            border-right: 1px solid ##5d8cc9; 
            border-left: 1px solid ##5d8cc9; 
            border-bottom-right-radius: 5px;
            border-bottom-left-radius: 5px;
        }
        .stop{
            width: 852px;
        }
        .stop-head{
            height: 28px;
            background-color: ##82bbef;
            padding-top: 5px;
            border-top-left-radius: 5px;
            border-top-right-radius: 5px;
            overflow: hidden;
        }
        .stop-head h4{
            color: ##000000;
            font-size: 12px;
            width:63px;
            border: 1px solid ##aaaaaa;
            background-color: ##ffffff;
            height: 27px;
            border-top-left-radius: 5px;
            border-top-right-radius: 5px;
            padding-top: 5px;
            text-align: center;
            margin-left: 5px;
            float: left;
            height: 28px;
            overflow: hidden;
        }
        .stop-h{
            padding-top: 5px;
        }
        .stop-h .fa{
            margin-left: 10px;
            margin-top: 0px;
            float: none;
        }
        .stop-h-label{
            font-weight: bold;
            font-size: 12px;
            margin-left: 8px;
        }
        .Infostop{
            margin-top: -25px;
        }
        .sortImg{
            width: 13px;
            margin-left: 5px;
            cursor: pointer;
        }
        .stop-head h2{
            color: white;
            font-weight: bold;
            padding: 0;
        }
        .stopLinks{
            float: left;
            width: 260px;
            margin-left: 10px;
        }
        .stopLinks a{
            margin-left: 5px;
            text-decoration: underline;
        }
        .stopLoadNo{
            float: left;
            width: 185px;
        }
        .stopAction{
            float: right;
            width: 265px;
            text-align: right;
            margin-right: 2px;
        }
        .green-btn{
            color: ##599700 !important;
        }

        .ui-widget, .ui-widget input, .ui-widget select, .ui-widget textarea, .ui-widget button{
            font:11px/16px Arial,Helvetica,sans-serif !important;
        }
        li.ui-menu-item{
            background:##EDEEF2 !important;
            color:black !important;
        }
        li.ui-state-focus{
            background:##20358A !important;
            color:##fff  !important;
        }
        li.ui-tabs-active{
            background:##ffffff !important;
        }
        .ui-datepicker-trigger{
            float: left;
        }
        .custCharges{
            background-color: ##e3e3e3;
        }
        .overlay {
            display: none;
            z-index: 2;
            background: ##000;
            position: fixed;
            text-align: center;
            opacity: 0.3;
            overflow: hidden;
             width: 100%;
            height: 100%;
            top: 0;
            right: 0;
            bottom: 0;
            left: 0;
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
        ##copyNoOfLoads{
            width: 60px;
            height: 18px;
            background: ##FFFFFF;
            border: 1px solid ##b3b3b3;
            padding: 2px 2px 0 2px;
            margin: 0 0 8px 0;
            font-size: 11px;
        }

        ##copyOptionPopup{
            width: 450px;
            position: absolute;
            top: 40%;
            left: 30%;
            z-index: 9999;
            display: none;
            box-shadow: 0 2px 6px rgba(0,0,0,0.2);
        }
        .copyOptionPopupHeader{
            background-color: ##82bbef;
            padding-left: 5px;
        }
        .copyOptionPopupContent{
            background-color:#request.qSystemSetupOptions.BackgroundColorForContent# !important;
            padding-left: 15px;
            font-size: 14px;
            padding-right:10px;
            padding-bottom:10px;
            padding-top: 10px;
        }

        .copyOptionPopupContent label{
            vertical-align:middle;
        }

        .copyOptionPopupContent .popupChk{
            height: 22px;
            width: 18px;
            vertical-align:middle;
        }
        .copyOptionPopupContent .smallChk{
            vertical-align:middle;
        }

        .copyLoadSysOpt{
            border:solid 1px;
            width: 260px;
            padding:5px;
        }
        .stopUpDown{
            float: right;
            margin-top: -5px;
        }
        .down-btn{
            -ms-transform: rotate(180deg);-webkit-transform: rotate(180deg);transform: rotate(180deg);
        }
        .stopUpDown img{
            margin-left: -5px;
            cursor: pointer;
        }
    </style>
    <cfif structkeyexists(url,"loadid") and len(trim(url.loadid)) gt 1>
        <div class="delbutton" style="float: none;width: 852px;text-align: right;padding: 0;">
            <a href="index.cfm?event=load&loadid=#url.loadID#&#session.URLToken#" onclick="return confirm('Are you sure to delete this load?');">  Delete</a>
        </div>
    </cfif>
    <div class="white-con-area" style="height: 40px;background-color: ##82bbef;">
        <div style="float: left; min-height: 40px; width: 43%;" id="divUploadedFiles">
            <cfif len(trim(url.loadid)) and viewCopyOnly EQ 0>
                <cfif request.filesAttached.recunt neq 0>
                    <a style="display:block;font-size: 13px;padding-left: 10px;color:white;width: 131px;float: left;margin-top: 12px;" href="##" onclick="popitup('../fileupload/multipleFileupload/MultipleUpload.cfm?id=#url.loadid#&attachTo=1&user=#session.adminusername#&dsn=#dsn#&attachtype=Load&CompanyID=#session.CompanyID#')">
                        <img style="vertical-align:bottom;" src="images/attachment.png">
                        <span class="attText">View/Attach Files</span>
                    </a>
                <cfelse>
                    <a style="display:block;font-size: 13px;padding-left: 10px;color:white;float: left;margin-top: 12px;" href="##" onclick="popitup('../fileupload/multipleFileupload/MultipleUpload.cfm?id=#url.loadid#&attachTo=1&user=#session.adminusername#&dsn=#dsn#&attachtype=Load&CompanyID=#session.CompanyID#')">
                        <img style="vertical-align:bottom;" src="images/attachment.png">
                        <span class="attText">Attach Files</span>
                        </a>
                </cfif>
            </cfif>
        </div>
        <div style="float: left; width: 57%; min-height: 40px;"><h1 style="color:white;font-weight:bold;">
            <cfif len(request.qLoad.LoadID)>Load###request.qLoad.LoadNumber#<cfelse>Add New Load</cfif></h1></div>
    </div>
    <form name="load"  class="addLoadWrap" id="load" action="index.cfm?event=addcustomerload:process&#session.URLToken#" method="post" onsubmit="return validateCustomerLoad();">
        <input type="hidden" name="LoadID" id="LoadID" value="#request.qLoad.LoadID#">
        <cfif not structkeyexists(session,"customerid")>
            <input type="hidden" name="Dispatcher" id="Dispatcher" value="#session.empid#">
            <input type="hidden" name="Salesperson" id="Salesperson" value="#session.empid#">
        </cfif>
        <cfset totalstops = -1>
        <cfloop query="request.qLoad" group="StopNo">
            <cfset totalstops++>
        </cfloop>
        <input type="hidden" name="totalstops" id="totalstops" value="#totalstops#">
        <input type="hidden" name="customerCommoditiesCharges" id="customerCommoditiesCharges" value="#request.qLoad.customerCommoditiesCharges#">

        <div class="white-con-area" id="viewOnlyMsg" style="text-align: center;display: none;">
            <div class="white-mid">
                <h3 style="font-weight: bold;color: red;width:100%">VIEW ONLY. EDIT NOT ALLOWED</h3>
                <div class="clear"></div>
            </div>
        </div>

        <div class="white-con-area">
            <div class="white-mid">
                <div class="form-con" style="width: 225px;">
                    
                    <fieldset>
                        <label class="space_it">Equip/L x W</label>
                        <select id="equipment" name="equipment" class="medium" style="width:70px;"  onchange="settemperaturescale()">
                            <option value="" data-temperature="" data-temperaturescale="">Select</option>
                            <cfloop query="request.qEquipments">
                                <option value="#request.qEquipments.equipmentID#" data-temperature="#request.qEquipments.temperature#" data-temperaturescale="#request.qEquipments.temperaturescale#" <cfif request.qEquipments.equipmentID EQ request.qLoad.EquipmentID> selected </cfif>>#request.qEquipments.equipmentname#</option>
                            </cfloop>
                        </select>
                        <input type="text" class="myElements" name="EquipmentLength" id="EquipmentLength" value="#request.qLoad.EquipmentLength#" style="width:15px;margin-left: 4px;margin-right: 1px !important;" >
                        <b style="float: left;margin-top: 3px;margin-left: 4px;">x</b>
                        <input type="text" class="myElements" name="EquipmentWidth" id="EquipmentWidth" value="#request.qLoad.EquipmentWidth#" style="width:15px;margin-left: 4px;margin-right: 1px !important;" >
                        <div class="clear"></div>
                        <label class="space_it">Temperature</label>
                        <input type="text" name="temperature" id="temperature"style="width:40px" class="myElements" value="#request.qLoad.temperature#">
                        <label style="width: 5px;margin-top: -5px;margin-left: -5px;"><sup>o</sup></label>
                        <cfif request.qSystemSetupOptions.TemperatureSetting EQ 0>
                            <select name="temperaturescale" id="temperaturescale" style="width:35px;">
                                <option value="C" <cfif request.qLoad.temperaturescale EQ "C"> selected </cfif> >C</option>
                                <option value="F" <cfif request.qLoad.temperaturescale EQ "F"> selected </cfif>>F</option>
                            </select>
                        <cfelseif request.qSystemSetupOptions.TemperatureSetting EQ 1>
                            F<input type="hidden" name="temperaturescale" value="F">
                        <cfelse>
                            C<input type="hidden" name="temperaturescale" value="C">
                        </cfif>
                        <div class="clear"></div>
                    </fieldset>
                </div>
                <div class="form-con" style="width: 310px;">
                    <fieldset>
                        <label class="space_it" style="width: 36px;">Notes</label><br>
                        <textarea class="medium-textbox  myElements" name="Notes" style="margin-left: 6px;width: 285px; height: 76px;" maxlength="1000">#request.qLoad.NewNotes#</textarea>
                    </fieldset>
                </div>
                <div class="form-con" style="width: 250px;padding-top: 20px;">
                    <fieldset>
                        <cfif len(request.qLoad.LoadID)>
                            <input id="custInvReportLink" style="width:110px !important;height:38px;background-size: contain;" type="button" class="black-btn tooltip" value="Customer Con" onclick="window.open('../reports/CustomerInvoiceReport.cfm?loadid=#request.qLoad.LoadID#&dsn=#application.dsn#&#session.URLToken#');">
                        </cfif>
                        <input name="save" type="submit" class="green-btn" style="width:110px !important;height:38px;background-size: contain;" value="Save">
                        <cfif len(request.qLoad.LoadID)>
                            <input style="width:110px !important;height:38px;background-size: contain;" name="map-button" type="button" class="black-btn" value="Google Map" onclick="showfullmap('#request.qLoad.LoadID#')">
                            <input type="button" class="blue-btn" value="Copy Load" id="CopyLoad" style="width:110px !important;height:38px;background-size: contain;" onclick="CopyLoad1('#url.loadid#','#session.URLToken#',#request.qSystemSetupOptions.CopyLoadLimit#)">
                        </cfif>
                    </fieldset>
                </div>
                <div class="clear"></div>
                <div class="white-con-area">
                    <div class="white-con-area" style="height: 36px;background-color: ##82bbef;">
                        <div style="padding: 0 18px;overflow:hidden;">
                            <h2 style="color:white;font-weight:bold;float: left;">Broker</h2>
                        </div>
                    </div>
                </div>
                <div class="form-con">
                    <fieldset>
                        <cfif NOT structkeyexists(session,"CustomerID")>
                            <label style="width: 75px;"><b>Broker*</b></label>
                            <input name="cutomerIdAuto" id="cutomerIdAuto" value="#request.qLoad.CustName#" placeholder ="Type text here to display list." />
                            <div class="clear"></div>
                        </cfif>
                        <label style="width: 75px;">Broker Info</label>
                        <div id="CustInfoNew">
                            <input type="hidden" name="CustomerID" id="CustomerID" value="#request.qLoad.CustomerID#">
                            <input type="hidden" name="CustomerName" id="CustomerName" value="#request.qLoad.CustName#">
                            <input type="hidden" name="CustomerLocation" id="CustomerLocation" value="#request.qLoad.Address#">
                            <input type="hidden" name="CustomerCity" id="CustomerCity" value="#request.qLoad.City#">
                            <input type="hidden" name="CustomerStateCode" id="CustomerStateCode" value="#request.qLoad.StateCode#">
                            <input type="hidden" name="CustomerZipCode" id="CustomerZipCode" value="#request.qLoad.PostalCode#">

                            <label class="field-textarea" id="BrokerAddress" style="width:188px;">
                                <cfif len(trim(request.qLoad.CustomerID))>
                                    <b style="color:##4322cc;text-decoration:underline;">
                                        #request.qLoad.CustName#
                                    </b><br>
                                    #request.qLoad.Address#<br>
                                    #request.qLoad.City#, #request.qLoad.StateCode#<br>
                                    #request.qLoad.PostalCode#
                                </cfif>
                            </label>
                        </div>
                    </fieldset>
                </div>
                <div class="form-con">
                    <fieldset>
                        <label>Contact</label>
                        <input name="CustomerContact" id="CustomerContact" value="#request.qLoad.ContactPerson#" style="width: 233px;" maxlength="100">
                        <div class="clear"></div>
                        <label>Tel</label>
                        <input name="customerPhone" id="customerPhone" value="#request.qLoad.Phone#" style="width: 89px;" onchange="ParseUSNumber(this,'Phone');" maxlength="50">
                        <label style="width:31px;">Cell</label>
                        <input name="customerCell" id="customerCell" value="#request.qLoad.CellNo#" style="width: 90px;" onchange="ParseUSNumber(this,'Cell');" maxlength="50">
                        <div class="clear"></div>
                        <label>Fax</label>
                        <input name="customerFax" id="customerFax" value="#request.qLoad.Fax#" style="width: 233px;" onchange="ParseUSNumber(this,'Fax');" maxlength="30">
                        <div class="clear"></div>
                        <label>Email</label>
                        <input name="CustomerEmail" id="CustomerEmail" value="#request.qLoad.ContactEmail#" style="width: 233px;"  maxlength="150">
                        <div class="clear"></div>
                        <label>PO##</label>
                        <input name="customerPO" id="customerPO" type="text" value="#request.qLoad.CustomerPONo#" class="sm-input disAllowHash myElements" style="width:93px;" maxlength="50">
                        <label style="width: 24px;">BOL##</label>
                        <input name="customerBOL" id="customerBOL" type="text" value="#request.qLoad.BOLNum#" class="sm-input disAllowHash myElements" style="width:92px;" maxlength="30">
                    </fieldset>
                </div>
                <div class="clear"></div>
            </div>
        </div>
        <div class="gap"></div>
        <div id="stops">
            <cfloop query="request.qLoad" group="StopNo">
                <div class="stop" id="stop_#request.qLoad.StopNo#">
                    <input type="hidden" name="shipperStopID_#request.qLoad.StopNo#" id="shipperStopID_#request.qLoad.StopNo#" value="#request.qLoad.shipperStopID#">
                    <input type="hidden" name="consigneeStopID_#request.qLoad.StopNo#" id="consigneeStopID_#request.qLoad.StopNo#" value="#request.qLoad.consigneeStopID#">
                    <div class="white-con-area stop-head">
                        <h4>Stop #request.qLoad.StopNo+1#</h4>
                        <div class="stopLinks">
                            <a href="##stop_#request.qLoad.StopNo#">###request.qLoad.StopNo+1#</a>
                        </div>
                        <div class="stopLoadNo">
                            <cfif len(request.qLoad.LoadID)>
                                <h2>Load###request.qLoad.LoadNumber#</h2>
                            </cfif>
                        </div>
                        <div class="stopUpDown">
                            <cfif len(request.qLoad.LoadID)>
                                <img src="images/upButton.png" <cfif stopNO EQ 0>style="display:none"</cfif>
                                onclick = "swapStops(#stopNO#,#stopNO-1#)"
                                >
                                <img src="images/upButton.png" class="down-btn" <cfif stopNO EQ request.qLoad.StopNo[request.qLoad.recordcount]>style="display:none"</cfif> onclick = "swapStops(#stopNO#,#stopNO+1#)">
                            </cfif>
                        </div>
                        <div class="stopAction">
                            <input name="addstopButton" type="button" onclick="AddNewStop();" class="green-btn" value="Add Stop" style="width:125px !important;">
                            <input style="width:125px !important;<cfif StopNo EQ 0>display: none;</cfif>" name="delstopButton_#request.qLoad.StopNo#" id="delstopButton_#request.qLoad.StopNo#" type="button" onclick="DeleteStop(#StopNo#);" value="Delete Stop">
                        </div>
                        
                    </div>
                    <div class="white-con-area">
                        <div class="white-mid">
                            <div class="stop-h">
                                <span class="fa PlusToggleButton fa-minus-circle fa-pickup" onclick="showHideStopInfo(this,#StopNo#,'Pickup');"></span>
                                <span class="stop-h-label">Pickup Name</span>
                            </div>
                            <div class="clear"></div>
                            <div class="Infostop" id="InfoPickup_#request.qLoad.StopNo#">
                                <div class="form-con" style="width: 20px;">
                                    <p style="transform: rotate(-90deg);margin-top: 167px;letter-spacing: 5px;font-family: 'Arial Black';color: ##0f4100;font-weight: bold;font-size: 20px;">PICKUP</p>
                                </div>
                                <div class="form-con" style="margin-left: -40px;">
                                    <fieldset>
                                        <label>&nbsp;</label>
                                        <input type="text" class="myElements shipperAuto" name="shipper_#request.qLoad.StopNo#" id="shipper_#request.qLoad.StopNo#" value="#request.qLoad.shipper#" placeholder="Type text here to display list.">
                                        <input type="hidden" name="shipperid_#request.qLoad.StopNo#" id="shipperid_#request.qLoad.StopNo#" value="#request.qLoad.shipperid#">
                                        <img src="images/clear.gif" class="imgPickupClear" style="height:14px;width:14px;" title="Click here to clear pickup information" onclick="ClearShipper(#StopNo#,'shipper');">
                                        <div class="clear"></div>
                                        <label>Address<br>
                                            <a href="##" onclick="Mypopitup('' );">
                                                <img  align="absmiddle" src="./map.jpg" width="24" height="24" alt="Pro Miles Map"  />
                                            </a>
                                        </label>
                                        <textarea class="addressChange myElements" rows="" name="shipperlocation_#StopNo#" id="shipperlocation_#StopNo#" cols="" maxlength="200"  style="height: 40px;">#request.qLoad.shipperlocation#</textarea>
                                        <div class="clear"></div>
                                        <label>City</label>
                                        <input class="myElements cityAuto" name="shippercity_#StopNo#" id="shippercity_#StopNo#" value="#request.qLoad.shippercity#" type="text" maxlength="50">
                                        <div class="clear"></div>
                                        <label>State</label>
                                        <select name="shipperstate_#StopNo#" id="shipperstate_#StopNo#" style="width:60px;" class="myElements">
                                            <option value="">Select</option>
                                                <cfloop query="request.qStates">
                                                    <option value="#request.qStates.statecode#" <cfif request.qStates.statecode EQ request.qLoad.shipperstate> selected </cfif>>#request.qStates.statecode#</option>
                                                </cfloop>
                                            </select>
                                        <label style="width: 58px;">Zip</label>
                                        <input name="shipperZipcode_#StopNo#" id="shipperZipcode_#StopNo#" value="#request.qLoad.shipperZipcode#" type="text"  maxlength="50" style="width:60px;" class="myElements zipAuto">
                                        <div class="clear"></div>
                                        <label>Contact</label>
                                        <input name="shipperContactPerson_#StopNo#" id="shipperContactPerson_#StopNo#" value="#request.qLoad.shipperContactPerson#" type="text" maxlength="100" class="myElements">
                                        <div class="clear"></div>
                                        <label>Phone</label>
                                        <input class="myElements" name="shipperPhone_#StopNo#" id="shipperPhone_#StopNo#" value="#request.qLoad.shipperPhone#" type="text" onchange="ParseUSNumber(this,'Phone');" maxlength="30">
                                        <div class="clear"></div>
                                        <label>Fax</label>
                                        <input name="shipperFax_#StopNo#" id="shipperFax_#StopNo#" value="#request.qLoad.shipperFax#" type="text" maxlength="30" class="myElements" onchange="ParseUSNumber(this,'Fax');">
                                        <div class="clear"></div>
                                        <label>Email</label>
                                        <input name="shipperEmail_#StopNo#" id="shipperEmail_#StopNo#" value="#request.qLoad.shipperEmail#" type="text" maxlength="100" class="myElements">
                                    </fieldset>
                                </div>
                                <div class="form-con">
                                    <fieldset>
                                        <label class="stopsLeftLabel">Pickup##</label>
                                        <input name="shipperPickupNo_#StopNo#" id="shipperPickupNo_#StopNo#" value="#request.qLoad.shipperReleaseNo#" type="text"  maxlength="50" class="myElements">
                                        <div class="clear"></div>
                                        <label class="stopsLeftLabel">Pickup Date</label>
                                        <input class="sm-input datefield myElements" name="shipperPickupDate_#StopNo#" id="shipperPickupDate_#StopNo#" value="#request.qLoad.shipperStopDate#" type="datefield"  onchange="checkDateFormatAll(this);">
                                        <label class="sm-lbl" style="width: 50px;">Apt. Time</label>
                                        <input class="pick-input  myElements" name="shipperpickupTime_#StopNo#" id="shipperpickupTime_#StopNo#" value="#request.qLoad.shipperStopTime#" type="text" style="width:40px;" maxlength="50">
                                        <cfif request.qSystemSetupOptions.timezone>
                                            <label class="sm-lbl" style="width: 55px;">Time Zone</label>
                                            <input class="pick-input myElements" name="shipperTimeZone_#StopNo#" id="shipperTimeZone_#StopNo#" value="#request.qLoad.shipperTimeZone#" type="text" style="width:25px;" maxlength="25">
                                        </cfif>
                                        <div class="clear"></div>
                                        <label class="stopsLeftLabel">Instructions</label>
                                        <textarea rows="" name="shipperNotes_#StopNo#" id="shipperNotes_#StopNo#" class="carrier-textarea-medium myElements" cols="" style="width: 293px;height: 165px;margin-left: 0px;">#request.qLoad.shipperInstructions#</textarea>
                                    </fieldset>
                                </div>
                            </div>
                            <div class="clear"></div>
                            <div align="center">
                                <div style="border-bottom:1px solid ##e6e6e6; padding-top:7px;margin-bottom: 8px;"></div>
                            </div>
                            <div class="stop-h">
                                <span class="fa PlusToggleButton fa-minus-circle fa-delivery" onclick="showHideStopInfo(this,#StopNo#,'Delivery');"></span>
                                <span class="stop-h-label">Delivery Name</span>
                            </div>
                            <div class="clear"></div>
                            <div class="Infostop" id="InfoDelivery_#StopNo#">
                                <div class="form-con" style="width: 20px;">
                                    <p style="transform: rotate(-90deg);margin-top: 185px;letter-spacing: 5px;font-family: 'Arial Black';color: ##800000;font-weight: bold;font-size: 20px;">DELIVERY</p>
                                </div>
                                <div class="form-con" style="margin-left: -40px;">
                                    <fieldset>
                                        <label>&nbsp;</label>
                                        <input class="myElements shipperAuto" name="consignee_#StopNo#" id="consignee_#StopNo#" value="#request.qLoad.consignee#"  placeholder="Type text here to display list.">
                                        <input type="hidden" name="consigneeid_#StopNo#" id="consigneeid_#StopNo#" value="#request.qLoad.consigneeID#">
                                        <img src="images/clear.gif" class="imgDeliveryClear" style="height:14px;width:14px;" title="Click here to clear delivery information" onclick="ClearShipper(#StopNo#,'consignee');">
                                        <div class="clear"></div>
                                        <label>Address<br>
                                            <a href="##" onclick="Mypopitup('' );">
                                                <img  align="absmiddle" src="./map.jpg" width="24" height="24" alt="Pro Miles Map"  />
                                            </a>
                                        </label>
                                        <textarea class="addressChange myElements" rows="" name="consigneelocation_#StopNo#" id="consigneelocation_#StopNo#" cols="" maxlength="200"  style="height: 40px;">#request.qLoad.consigneelocation#</textarea>
                                        <div class="clear"></div>
                                        <label>City</label>
                                        <input class="addressChange myElements cityAuto" name="consigneecity_#StopNo#" id="consigneecity_#StopNo#" value="#request.qLoad.consigneecity#" type="text" maxlength="50">
                                        <div class="clear"></div>
                                        <label>State</label>
                                        <select name="consigneestate_#StopNo#" id="consigneestate_#StopNo#" style="width:60px;" class="myElements">
                                            <option value="">Select</option>
                                                <cfloop query="request.qStates">
                                                    <option value="#request.qStates.statecode#" <cfif request.qStates.statecode EQ request.qLoad.consigneestate> selected </cfif>>#request.qStates.statecode#</option>
                                                </cfloop>
                                            </select>
                                        </select>
                                        <label style="width: 58px;">Zip</label>
                                        <input name="consigneeZipcode_#StopNo#" id="consigneeZipcode_#StopNo#" value="#request.qLoad.consigneeZipcode#" type="text"  maxlength="50" style="width:60px;" class="myElements zipAuto">
                                        <div class="clear"></div>
                                        <label>Contact</label>
                                        <input name="consigneeContactPerson_#StopNo#" id="consigneeContactPerson_#StopNo#" value="#request.qLoad.consigneeContactPerson#" type="text" maxlength="100" class="myElements">
                                        <div class="clear"></div>
                                        <label>Phone</label>
                                        <input class="myElements" name="consigneePhone_#StopNo#" id="consigneePhone_#StopNo#" value="#request.qLoad.consigneePhone#" type="text" onchange="ParseUSNumber(this,'Phone');" maxlength="30">
                                        <div class="clear"></div>
                                        <label>Fax</label>
                                        <input name="consigneeFax_#StopNo#" id="consigneeFax_#StopNo#" value="#request.qLoad.consigneeFax#" type="text" maxlength="30" class="myElements" onchange="ParseUSNumber(this,'Fax');">
                                        <div class="clear"></div>
                                        <label>Email</label>
                                        <input name="consigneeEmail_#StopNo#" id="consigneeEmail_#StopNo#" value="#request.qLoad.consigneeEmail#" type="text" maxlength="100" class="myElements">
                                    </fieldset>
                                </div>
                                <div class="form-con">
                                    <fieldset>
                                        <label class="stopsLeftLabel">Delivery##</label>
                                        <input name="consigneePickupNo_#StopNo#" id="consigneePickupNo_#StopNo#" value="#request.qLoad.consigneeReleaseNo#" type="text"  maxlength="50" class="myElements">
                                        <div class="clear"></div>
                                        <label class="stopsLeftLabel">Delivery Date</label>
                                        <input class="sm-input datefield myElements" name="consigneePickupDate_#StopNo#" id="consigneePickupDate_#StopNo#" value="#request.qLoad.consigneeStopDate#" type="datefield" onchange="checkDateFormatAll(this);" >
                                        <label class="sm-lbl" style="width: 50px;">Apt. Time</label>
                                        <input class="pick-input  myElements" name="consigneepickupTime_#StopNo#" id="consigneepickupTime_#StopNo#" value="#request.qLoad.consigneeStopTime#" type="text" style="width:40px;" maxlength="50">
                                        <cfif request.qSystemSetupOptions.timezone>
                                            <label class="sm-lbl" style="width: 55px;">Time Zone</label>
                                            <input class="pick-input myElements" name="consigneeTimeZone_#StopNo#" id="consigneeTimeZone_#StopNo#" value="#request.qLoad.consigneeTimeZone#" type="text" style="width:25px;" maxlength="25">
                                        </cfif>
                                        <div class="clear"></div>
                                        <label class="stopsLeftLabel">Instructions</label>
                                        <textarea rows="" name="consigneeNotes_#StopNo#" id="consigneeNotes_#StopNo#" class="carrier-textarea-medium myElements" cols="" style="width: 278px;height: 165px;margin-left: 0px;">#request.qLoad.consigneeInstructions#</textarea>
                                    </fieldset>
                                </div>
                            </div>
                            <div class="clear"></div>
                            <div align="center">
                                <div style="border-bottom:1px solid ##e6e6e6; padding-top:7px;margin-bottom: 8px;"></div>
                            </div>
                        </div>
                    </div>
                    <div class="white-con-area" style="height: 36px;background-color: ##82bbef;">
                        <div style="padding: 0 18px;overflow:hidden;">
                            <h2 style="color:white;font-weight:bold;float: left;">Accessorials and Commodities</h2>
                        </div>
                    </div>
                    <div class="white-mid">
                        <table width="100%" border="0" cellspacing="0" cellpadding="0">
                            <thead>
                                <tr>
                                    <th align="right" valign="middle" class="head-bg head-l">Fee</th>
                                    <th align="right" valign="middle" class="head-bg">Qty</th>
                                    <th align="right" valign="middle" class="head-bg">Type</th>
                                    <th align="right" valign="middle" class="head-bg">Description</th>
                                    <th align="right" valign="middle" class="head-bg">Dimensions</th>
                                    <th align="right" valign="middle" class="head-bg">Wt(lbs)</th>
                                    <th align="right" valign="middle" class="head-bg">Class</th>
                                    <th align="right" valign="middle" class="head-bg">Cust. Rate</th>
                                    <th align="right" valign="middle" class="head-bg">Cust. Total</th>
                                    <th align="right" valign="middle" class="head-bg head-r">&nbsp;</th>
                                </tr>
                            </thead>
                            <tbody id="tbody_commodity_#StopNo#" class="commRows">
                                <cfset totalStopComm = 0>
                                <cfloop group="SrNo">
                                    <cfset totalStopComm++>
                                    <tr bgcolor="##f7f7f7" class="tr_commodity" id="tr_commodity_#StopNo#_#SrNo#">
                                        <input type="hidden" value="#request.qLoad.LoadStopCommoditiesID#" id="LoadStopCommoditiesID_#StopNo#_#SrNo#" name="LoadStopCommoditiesID_#StopNo#_#SrNo#">
                                        <td class="lft-bg2 body-l" valign="middle" align="center" height="20">
                                            <input name="isFee_#StopNo#_#SrNo#" id="isFee_#StopNo#_#SrNo#" class="isFee check myElements" type="checkbox" <cfif request.qLoad.FEE EQ 1> checked </cfif>>
                                        </td>
                                        <td class="normaltdC" valign="middle" align="left">
                                            <input name="qty_#StopNo#_#SrNo#" id="qty_#StopNo#_#SrNo#" class="qty q-textbox myElements valid" type="text" value="#request.qLoad.qty#" onchange="CalculateCustomerRate(#StopNo#,#SrNo#)">
                                        </td>
                                        <td class="normaltdC" valign="middle" align="left">
                                            <select name="unit_#StopNo#_#SrNo#" id="unit_#StopNo#_#SrNo#" class="t-select unit typeSelect1 myElements" onchange="populateUnitDetails(this);">
                                                <option value=""></option>
                                                <cfloop query="request.qUnits">
                                                    <option value="#request.qUnits.unitID#" <cfif request.qLoad.unitID EQ request.qUnits.unitID> selected </cfif>>#request.qUnits.unitName#<cfif trim(request.qUnits.unitCode) neq ''>(#request.qUnits.unitCode#)</cfif>
                                                    </option>
                                                </cfloop>
                                            </select>
                                        </td>
                                        <td class="normaltdC" valign="middle" align="left">
                                            <input name="description_#StopNo#_#SrNo#" id="description_#StopNo#_#SrNo#" class="t-textbox myElements" type="text" style="width: 344px;" value="#request.qLoad.description#">
                                        </td>
                                        <td class="normaltdC" valign="middle" align="left">
                                            <input name="dimensions_#StopNo#_#SrNo#" id="dimensions_#StopNo#_#SrNo#" class="t-textbox myElements" type="text" style="width: 100px;" value="#request.qLoad.dimensions#">
                                        </td>
                                        <td class="normaltdC" valign="middle" align="left">
                                            <input name="weight_#StopNo#_#SrNo#" id="weight_#StopNo#_#SrNo#" class="wt-textbox myElements" type="text" value="#request.qLoad.weight#">
                                        </td>
                                        <td class="normaltdC" valign="middle" align="left">
                                            <select name="class_#StopNo#_#SrNo#" id="class_#StopNo#_#SrNo#" class="t-select myElements">
                                                <option value=""></option>
                                                <cfloop query="request.qClasses">
                                                    <option value="#request.qClasses.classId#" <cfif request.qLoad.classId EQ request.qClasses.classId> selected </cfif>>
                                                        #request.qClasses.className#
                                                    </option>
                                                </cfloop>
                                            </select>
                                        </td>
                                        <td class="normaltdC" valign="middle" align="left">
                                            <input name="CustomerRate_#StopNo#_#SrNo#" id="CustomerRate_#StopNo#_#SrNo#" class="q-textbox CustomerRate myElements valid" type="text" value="#DollarFormat(request.qLoad.custRate)#" onchange="CalculateCustomerRate(#StopNo#,#SrNo#)">
                                        </td>
                                        <td class="normaltdC" valign="middle" align="left">
                                            <input name="custCharges_#StopNo#_#SrNo#" id="custCharges_#StopNo#_#SrNo#" class="q-textbox custCharges myElements valid" type="text" value="#DollarFormat(request.qLoad.custCharges)#" readonly tabindex="-1">
                                        </td>
                                        <td class="normaltdC body-r" valign="middle" align="left" width="5%">
                                            <img onclick="delCommodityRow(this)" class="delComm" name="delComm_#StopNo#_#SrNo#" id="delComm_#StopNo#_#SrNo#" src="images/delete-icon.gif" style="width:10px;margin-left: 5px;cursor: pointer;float: left">
                                            <img class="sortImg" name="sortImg_#StopNo#_#SrNo#" id="sortImg_#StopNo#_#SrNo#" src="images/sort.png" style="display: none;">
                                        </td>
                                    </tr>
                                </cfloop>
                            </tbody>
                            <tfoot>
                                <tr>
                                    <td colspan="10" align="left" valign="middle" class="footer-bg"></td>
                                </tr>
                            </tfoot>
                        </table>
                        <input type="hidden" name="totalcommodity_#StopNo#" id="totalcommodity_#StopNo#" value="#totalStopComm#">
                        <input type="button" class="btn_addNewRow" name="btn_addNewRow_#StopNo#" id="btn_addNewRow_#StopNo#" onclick="addNewCommodity(#StopNo#)" value="Add New Row">
                    </div>
                    <div style="width: 830px;text-align: right;margin-bottom: 20px;">
                        <input name="addstopButton" type="button" onclick="AddNewStop();" class="green-btn" value="Add Stop">
                        <input <cfif StopNo EQ 0>style="display: none;"</cfif> name="delstopButton_#StopNo#" id="delstopButton_#StopNo#" type="button" onclick="DeleteStop(#StopNo#);"  value="Delete Stop">
                        <br>
                        <input name="save" type="submit" class="green-btn" value="Save" style="width: 145px !important;">
                    </div>
                </div>
            </cfloop>
        </div>
    </form>

    <script type="text/javascript">

        $(document).ready(function() {

            generateStopLinks();
            initiateSortable();
            initiateAutoComplete();

            <cfloop query="request.qLoad" group="StopNo">
                reSortCommodities(#request.qLoad.StopNo#);
            </cfloop>

            <cfif viewCopyOnly EQ 1>
                $('input,textarea,select').prop( "disabled", true ).css('background-color','##e3e3e3');
                $('.delComm,.sortImg').hide();
                $('input[type="button"]').hide();
                $('input[type="submit"]').hide();
                $('.imgPickupClear,.imgDeliveryClear').hide();
                $('.field-textarea').css('background-color','##e3e3e3')
                $('##CopyLoad').show().prop( "disabled", false );
                $('##copyNoOfLoads').prop( "disabled", false ).css('background-color','##fff');
                $('.copyOptionPopupContent input[type="button"]').show().prop( "disabled", false );
                $('##viewOnlyMsg').show();
            <cfelse>
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
            </cfif>
        })

        function initiateAutoComplete(){
            $('##cutomerIdAuto').each(function(i, tag) {
                $(tag).autocomplete({
                    multiple: false,
                    width: 400,
                    scroll: true,
                    scrollHeight: 300,
                    cacheLength: 1,
                    highlight: false,
                    dataType: "json",
                    autoFocus: true,
                    source: 'searchCustomersAutoFill.cfm?queryType=getCustomers&CompanyID=#session.CompanyID#',
                    select: function(e, ui) {
                        $(this).val(ui.item.name);
                        $('##CustomerID').val(ui.item.value);
                        $('##CustomerName').val(ui.item.name);
                        $('##CustomerLocation').val(ui.item.location);
                        $('##CustomerCity').val(ui.item.city);
                        $('##CustomerStateCode').val(ui.item.state);
                        $('##CustomerZipCode').val(ui.item.zip);
                        $('##BrokerAddress').html('<b>'+ui.item.name+'</b><br>'+ui.item.location+'<br>'+ui.item.city+', '+ui.item.state+'<br>'+ui.item.zip);
                        $('##CustomerContact').val(ui.item.contactPerson);
                        $('##customerPhone').val(ui.item.phoneNo);
                        $('##customerCell').val(ui.item.cellNo);
                        $('##customerFax').val(ui.item.fax);
                        $('##CustomerEmail').val(ui.item.email);
                        return false;
                    }
                })  
                $(tag).data("ui-autocomplete")._renderItem = function(ul, item) {
                    return $( "<li>"+item.name+"<br/><b><u>Address</u>:</b> "+ item.location+"&nbsp;&nbsp;&nbsp;<b><u>City</u>:</b>" + item.city+"&nbsp;&nbsp;&nbsp;<b><u>State</u>:</b> " + item.state+"<br/><b><u>Zip</u>:</b> " + item.zip+"</li>" )
                            .appendTo( ul );
                }
            })

            $('.shipperAuto').each(function(i, tag) {
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
                        var id = this.id;
                        var type = id.split('_')[0];
                        var stopNo = id.split('_')[1];
                        if(ui.item.value !='00000000-0000-0000-0000-000000000000'){
                            $("##"+type+"id_"+stopNo).val(ui.item.value);
                        }
                        else{
                            $("##"+type+"id_"+stopNo).val('');
                        }
                        $("##"+type+"_"+stopNo).val(ui.item.name);
                        $("##"+type+"location_"+stopNo).val(ui.item.location);
                        $("##"+type+"city_"+stopNo).val(ui.item.city);
                        $("##"+type+"state_"+stopNo).val(ui.item.state);
                        $("##"+type+"Zipcode_"+stopNo).val(ui.item.zip);
                        $("##"+type+"ContactPerson_"+stopNo).val(ui.item.contactPerson);
                        $("##"+type+"Phone_"+stopNo).val(ui.item.phoneNo);
                        $("##"+type+"Fax_"+stopNo).val(ui.item.fax);
                        $("##"+type+"Email_"+stopNo).val(ui.item.email);
                        $("##"+type+"Notes_"+stopNo).val(ui.item.notes);
                        <cfif request.qSystemSetupOptions.timezone>
                            $("##"+type+"TimeZone_"+stopNo).val(ui.item.timezone);
                        </cfif>
                        return false;
                    },
                })
                $(tag).data("ui-autocomplete")._renderItem = function(ul, item) {
                    return $( "<li>"+item.name+"<br/><b><u>Address</u>:</b> "+ item.location+"&nbsp;&nbsp;&nbsp;<b><u>City</u>:</b>" + item.city+"&nbsp;&nbsp;&nbsp;<b><u>State</u>:</b> " + item.state+"<br/><b><u>Zip</u>:</b> " + item.zip+"</li>" )
                            .appendTo( ul );
                }
            });

            $('.cityAuto').each(function(i, tag) {
                $(tag).autocomplete({
                    multiple: false,
                    width: 400,
                    scroll: true,
                    scrollHeight: 300,
                    cacheLength: 1,
                    highlight: false,
                    dataType: "json",
                    source: 'searchCustomersAutoFill.cfm?queryType=getCity&CompanyID=#session.CompanyID#',
                    select: function(e, ui) {
                        $(this).val(ui.item.city);
                        var id = this.id;
                        var type = id.split('_')[0];
                        type = type.replace('city','');
                        var stopNo = id.split('_')[1];

                        if($("##"+type+"state_"+stopNo+" option[value='"+ui.item.state+"']").length){
                            $("##"+type+"state_"+stopNo).val(ui.item.state);
                        }
                        $("##"+type+"Zipcode_"+stopNo).val(ui.item.zip);
                        return false;
                    }
                });
                $(tag).data("ui-autocomplete")._renderItem = function(ul, item) {
                    return $( "<li>"+item.city+"<br/><b><u>State</u>:</b> "+ item.state+"&nbsp;&nbsp;&nbsp;<b><u>Zip</u>:</b>" + item.zip+"</li>" )
                    .appendTo( ul );
                }
            })

            $('.zipAuto').each(function(i, tag) {
                $(tag).autocomplete({
                    multiple: false,
                    width: 400,
                    scroll: true,
                    scrollHeight: 300,
                    cacheLength: 1,
                    minLength: 1,
                    highlight: false,
                    dataType: "json",
                    source: 'searchCustomersAutoFill.cfm?queryType=GetZip&CompanyID=#session.CompanyID#',
                    select: function(e, ui) {
                        $(this).val(ui.item.zip);
                        var id = this.id;
                        var type = id.split('_')[0];
                        type = type.replace('Zipcode','');
                        var stopNo = id.split('_')[1];

                        if($("##"+type+"state_"+stopNo).val() == ''){
                            if($("##"+type+"state_"+stopNo+" option[value='"+ui.item.state+"']").length){
                                $("##"+type+"state_"+stopNo).val(ui.item.state);
                            }
                        }
                        if($("##"+type+"city_"+stopNo).val() == ''){
                           $("##"+type+"city_"+stopNo).val(ui.item.city) 
                        }

                        return false;
                    }
                });
                $(tag).data("ui-autocomplete")._renderItem = function(ul, item) {
                    return $( "<li>"+item.zip+"<br/><b><u>State</u>:</b> "+ item.state+"&nbsp;&nbsp;&nbsp;<b><u>City</u>:</b>" + item.city+"</li>" )
                            .appendTo( ul );
                }
            })
        }

        function initiateSortable(){
            $('.commRows').sortable({
                start: function(e, ui) {
                    // creates a temporary attribute on the element with the old index
                    $(this).attr('data-previndex', ui.item.index());
                },
                update: function(e, ui) {
                    var tbodyId = $(this).attr("id");
                    var stopNo = tbodyId.split('_')[2];

                    $(this).find('tr').each(function (i, tr){
                        var ind = i+1;
                        $(this).find('input,select,img').each(function () {
                            var Name = this.name;
                            $(this).attr("name",Name.split('_')[0]+'_'+stopNo+'_'+ind);
                            $(this).attr("id",Name.split('_')[0]+'_'+stopNo+'_'+ind);
                        });
                        $(this).attr("id","tr_commodity_"+stopNo+"_"+ind);
                    });
                    reSortCommodities(stopNo);
                }
            });
            $( ".commRows" ).disableSelection();
        }

        function AddNewStop(){
            var count = $('##totalstops').val();
            var original = document.getElementById('stop_0');
            var clone = original.cloneNode(true);
            count = ++count;
            var stopNo = count + 1;
            $(clone).find('.stop-head h4').html('Stop '+stopNo);
            
            $(clone).find(".tr_commodity:gt(0)").remove();

            $(clone).find("input,select,textarea").each(function(e){
                var name = $(this).attr("name");
                name = name.replace("_0", "_"+count);
                $(this).attr("name",name);
                $(this).attr("id",name);
                if($(this).prop("tagName")=="TEXTAREA" || $(this).prop("tagName")=="SELECT" || ($(this).prop("tagName")=="INPUT" && $(this).attr("type") != "button" && $(this).attr("type") != "submit")){
                    $(this).val("");
                }
            });

            $(clone).find(".fa-pickup").attr("onclick","showHideStopInfo(this,"+count+",'Pickup')");
            $(clone).find(".fa-delivery").attr("onclick","showHideStopInfo(this,"+count+",'Delivery')");
            $(clone).find("##InfoPickup_0").attr("id","InfoPickup_"+count);
            $(clone).find("##InfoDelivery_0").attr("id","InfoDelivery_"+count);

            $(clone).find("##tbody_commodity_0").attr("id","tbody_commodity_"+count);
            $(clone).find("##tr_commodity_0_1").attr("id","tr_commodity_"+count+"_1");
            $(clone).find("##totalcommodity_"+count).val("1");
            $(clone).find(".btn_addNewRow").attr("onclick","addNewCommodity("+count+")");
            
            $(clone).find("##qty_"+count+"_1").val(1);
            $(clone).find("##qty_"+count+"_1").attr("onchange","CalculateCustomerRate("+count+",1)");

            $(clone).find("##CustomerRate_"+count+"_1").val("$0.00");
            $(clone).find("##CustomerRate_"+count+"_1").attr("onchange","CalculateCustomerRate("+count+",1)");
            $(clone).find("##custCharges_"+count+"_1").val("$0.00");
            
            $(clone).find(".delComm").attr("name","delComm_"+count+"_1");
            $(clone).find(".delComm").attr("id","delComm_"+count+"_1");

            $(clone).find(".sortImg").attr("name","sortImg_"+count+"_1");
            $(clone).find(".sortImg").attr("id","sortImg_"+count+"_1").hide();
            $(clone).find("##delstopButton_"+count).show();
            $(clone).find("##delstopButton_"+count).attr("onclick","DeleteStop("+count+")");

            $(clone).find(".datefield").removeClass('hasDatepicker');
            $(clone).find(".ui-datepicker-trigger").remove();

            $(clone).find(".imgPickupClear").attr("onclick","ClearShipper("+count+",'shipper');");
            $(clone).find(".imgDeliveryClear").attr("onclick","ClearShipper("+count+",'consignee');");

            $(clone).find(".stopUpDown img").hide();

            $(clone).find(".datefield").datepicker({
              dateFormat: "mm/dd/yy",
              showOn: "button",
              buttonImage: "images/DateChooser.png",
              buttonImageOnly: true,
              showButtonPanel: true
            });

            $(clone).find( ".datefield" ).datepicker( "option", "showButtonPanel", true );
                var old_goToToday = $.datepicker._gotoToday
                $.datepicker._gotoToday = function(id) {
                 old_goToToday.call(this,id)
                 this._selectDate(id)
            }

            $(clone).attr("id","stop_"+count);
            $("##stops").append(clone);
            $('html, body').animate({
                scrollTop: $("##stop_"+count).offset().top
            }, 500);
            $("##shipper_"+count).focus();
            $('##totalstops').val(count);
            generateStopLinks();
            initiateSortable();
            initiateAutoComplete();

        }

        function generateStopLinks(){
            var count = $('##totalstops').val();
            $(".stopLinks").html('');
            for(i=0;i<=count;i++){
                var j = i+1;
                $(".stopLinks").append('<a href="##stop_'+i+'">##'+j+'</a>');
            }
        }
        function DeleteStop2(stopNo){
            var count = $('##totalstops').val();
                $('##stop_'+stopNo).remove();

                if(count>stopNo){
                    for(i=stopNo+1;i<=count;i++){
                        var clone = $('##stop_'+i);
                        var j = i-1;
                        $(clone).find("input,select,textarea").each(function(e){
                            var name = $(this).attr("name");
                            name = name.replace("_"+i, "_"+j);
                            $(this).attr("name",name);
                            $(this).attr("id",name);
                        });
                        $(clone).find('.stop-head h4').html('Stop '+i);
                        $(clone).find(".fa-pickup").attr("onclick","showHideStopInfo(this,"+j+",'Pickup')");
                        $(clone).find(".fa-delivery").attr("onclick","showHideStopInfo(this,"+j+",'Delivery')");
                        $(clone).find("##InfoPickup_"+i).attr("id","InfoPickup_"+j);
                        $(clone).find("##InfoDelivery_"+i).attr("id","InfoDelivery_"+j);

                        $(clone).find("##tbody_commodity_"+i).attr("id","tbody_commodity_"+j);
                        $(clone).find("##tr_commodity_"+i+"_1").attr("id","tr_commodity_"+j+"_1");
                        $(clone).find("##totalcommodity_"+j).val("1");
                        $(clone).find(".btn_addNewRow").attr("onclick","addNewCommodity("+j+")");

                        $(clone).find(".delComm").attr("name","delComm_"+j+"_1");
                        $(clone).find(".delComm").attr("id","delComm_"+j+"_1");
                        $(clone).find(".sortImg").attr("name","sortImg_"+j+"_1");
                        $(clone).find(".sortImg").attr("id","sortImg_"+j+"_1");

                        $(clone).find("##delstopButton_"+j).attr("onclick","DeleteStop("+j+")");

                        $(clone).attr("id","stop_"+j);
                    }
                }

                var customerCommoditiesCharges = 0;
                $( ".custCharges" ).each(function() {
                    var custCharges = this.value;
                    custCharges = custCharges.replace("$","");
                    custCharges = custCharges.replace(/,/g,"");
                    customerCommoditiesCharges = customerCommoditiesCharges + parseFloat(custCharges);
                });
                $("##customerCommoditiesCharges").val(customerCommoditiesCharges);
                count = --count;
                $('##totalstops').val(count);
                generateStopLinks();
        }
        function DeleteStop(stopNo){
            if (confirm("Are you sure you want to delete this stop?")) {
                
                var shipperStopID = $('##shipperStopID_'+stopNo).val();

                if(shipperStopID!=''){
                    var path = urlComponentPath+"customerloadgateway.cfc?method=deleteStop";
                    $.ajax({
                        type: "Post",
                        url: path,
                        dataType: "json",
                        async: false,
                        data:{
                            dsn:'#application.dsn#',
                            LoadID:'#request.qLoad.LoadID#',
                            stopNo:stopNo,
                            LoadNumber:'#request.qLoad.LoadNumber#',
                            UpdatedByUserID:'#variables.s_id#',
                            UpdatedBy:'#session.adminUserName#'
                        },
                        beforeSend: function() {
                            $('.overlay').show();
                            $('##loader').show();
                        },
                        success: function(data){
                            if(data == 'Success'){
                                DeleteStop2(stopNo);
                            }
                            else{
                                alert('Something went wrong. Unable to delete.');
                            }
                            $('.overlay').hide();
                            $('##loader').hide();
                        }
                    });
                }
                else{
                    DeleteStop2(stopNo);  
                }
            }
        }

        function addNewCommodity(stopNo){
            var count = $('##totalcommodity_'+stopNo).val();
            var original = document.getElementById('tr_commodity_'+stopNo+'_1');
            var clone = original.cloneNode(true);
            count = ++count;
            $(clone).attr("id","tr_commodity_"+stopNo+"_"+count)

            $(clone).find("input,select").each(function(e){
                var name = $(this).attr("name");
                name = name.split('_');
                $(this).attr("name",name[0]+"_"+stopNo+"_"+count);
                $(this).attr("id",name[0]+"_"+stopNo+"_"+count);
                if(name[0]=='isFee'){
                    $(this).attr('checked', false);
                }
                if(name[0]=='qty'){
                    $(this).val(1);
                    $(this).attr("onchange","CalculateCustomerRate("+stopNo+","+count+")");
                }
                if(name[0]=='unit' || name[0]=='description' || name[0]=='dimensions' || name[0]=='weight' || name[0]=='class' || name[0]=='LoadStopCommoditiesID'){
                    $(this).val("");
                }
                if(name[0]=='CustomerRate' || name[0]=='custCharges'){
                    $(this).val("$0.00");
                    if(name[0]=='CustomerRate'){
                        $(this).attr("onchange","CalculateCustomerRate("+stopNo+","+count+")");
                    }
                }
            });
            $(clone).find(".delComm").attr("name","delComm_"+stopNo+"_"+count);
            $(clone).find(".delComm").attr("id","delComm_"+stopNo+"_"+count);

            $(clone).find(".sortImg").attr("name","sortImg_"+stopNo+"_"+count);
            $(clone).find(".sortImg").attr("id","sortImg_"+stopNo+"_"+count);
            $("##tbody_commodity_"+stopNo).append(clone);
            $('##totalcommodity_'+stopNo).val(count);
            reSortCommodities(stopNo);
        }

        function reSortCommodities(stopNo){
            var totalCount = $("##tbody_commodity_"+stopNo).find('tr:last').index();

            if(totalCount!=0){
                $("##tbody_commodity_"+stopNo).find('tr').each(function (j,comm) {
                    if(j==0){
                        $(this).find('[id^=sortImg]').attr('src','images/sortdwn.png').show();
                    }
                    else if(j==totalCount){
                        $(this).find('[id^=sortImg]').attr('src','images/sortup.png').show();
                    }
                    else{
                        $(this).find('[id^=sortImg]').attr('src','images/sort.png').show();
                    }
                })
            }
            else{
                $("##tbody_commodity_"+stopNo).find('[id^=sortImg]').hide();
            }
        }

        function delCommodityRow(row){
            if (confirm("Are you sure you want to delete this item?")) {
                var rowId = $(row).attr("id");
                var stopNo = rowId.split('_')[1];
                var rowNo = parseInt(rowId.split('_')[2]);
                var count = parseInt($('##totalcommodity_'+stopNo).val());
                var LoadStopCommoditiesID = $("##LoadStopCommoditiesID_"+stopNo+"_"+rowNo).val();

                if(LoadStopCommoditiesID!=''){
                    var description = $("##description_"+stopNo+"_"+rowNo).val();
                    var path = urlComponentPath+"customerloadgateway.cfc?method=delCommodityRow";
                    $('.overlay').show();
                    $('##loader').show();
                    $.ajax({
                        type: "Post",
                        url: path,
                        dataType: "json",
                        async: false,
                        data:{
                            dsn:'#application.dsn#',
                            LoadStopCommoditiesID:LoadStopCommoditiesID,
                            SrNo:rowNo,
                            LoadID:'#request.qLoad.LoadID#',
                            LoadNumber:'#request.qLoad.LoadNumber#',
                            UpdatedByUserID:'#variables.s_id#',
                            UpdatedBy:'#session.adminUserName#',
                            stopNo:stopNo,
                            description:description,
                            count:count
                        },
                        beforeSend: function() {
                            $('.overlay').show();
                            $('##loader').show();
                        },
                        success: function(data){
                            if(data == 'Success'){
                                delCommodityRow2(row);
                            }
                            else{
                                alert('Something went wrong. Unable to delete.');
                            }
                            $('.overlay').hide();
                            $('##loader').hide();
                        }
                    });
                }
                else{
                    delCommodityRow2(row);
                }
            }
        }

        function delCommodityRow2(row){
            var rowId = $(row).attr("id");
            var stopNo = rowId.split('_')[1];
            var rowNo = parseInt(rowId.split('_')[2]);
            var count = parseInt($('##totalcommodity_'+stopNo).val());

            if(count==1){
                var clone = $("##tr_commodity_"+stopNo+"_"+rowNo);
                $(clone).find("input,select").each(function(e){
                    var name = $(this).attr("name");
                    name = name.split('_');
                    if(name[0]=='isFee'){
                        $(this).attr('checked', false);
                    }
                    if(name[0]=='qty'){
                        $(this).val(1);
                    }
                    if(name[0]=='unit' || name[0]=='description' || name[0]=='weight' || name[0]=='class'){
                        $(this).val("");
                    }
                    if(name[0]=='CustomerRate' || name[0]=='custCharges'){
                        $(this).val("$0.00");
                    }
                });
            }
            else{
                $("##tr_commodity_"+stopNo+"_"+rowNo).remove();
                if(count>rowNo){
                    for(i=rowNo+1;i<=count;i++){
                        var j = i-1;
                        var row = $("##tr_commodity_"+stopNo+"_"+i);
                        $(row).find("input,select,img").each(function(e){
                            var name = $(this).attr("name");
                            name = name.split('_');
                            $(this).attr("name",name[0]+"_"+stopNo+"_"+j);
                            $(this).attr("id",name[0]+"_"+stopNo+"_"+j);
                        })
                        $("##tr_commodity_"+stopNo+"_"+i).attr("id","tr_commodity_"+stopNo+"_"+j);
                    }
                }
                count = --count;
                $('##totalcommodity_'+stopNo).val(count);

                var customerCommoditiesCharges = 0;
                $( ".custCharges" ).each(function() {
                    var custCharges = this.value;
                    custCharges = custCharges.replace("$","");
                    custCharges = custCharges.replace(/,/g,"");
                    customerCommoditiesCharges = customerCommoditiesCharges + parseFloat(custCharges);
                });
                $("##customerCommoditiesCharges").val(customerCommoditiesCharges);
                
                reSortCommodities(stopNo);
            }

        }

        function populateUnitDetails(row){
            var stopNo = parseInt(row.id.split('_')[1]);
            var rowNo = parseInt(row.id.split('_')[2]);
            var unitID = row.value;

            if(unitID!=""){
                $.ajax({
                    type    : 'GET',
                    url     : "../gateways/loadgateway.cfc?method=checkAjaxFeeUnit",
                    dataType: "json",
                    async: false,
                    data: {
                        dsn: '#application.dsn#',
                        unitId: unitID,
                        CompanyID:'#session.CompanyID#'
                    },
                    success: function(data){
                        retValue = data;
                        if (retValue[0] === true || retValue[0] == 'true'){
                            $('##isFee_'+stopNo+'_'+rowNo).prop('checked', true);
                        }
                        else{
                            $('##isFee_'+stopNo+'_'+rowNo).prop('checked', false);
                        }
                        $('##description_'+stopNo+'_'+rowNo).val(retValue[1]);
                        formatDollarNegative(retValue[2],'CustomerRate_'+stopNo+'_'+rowNo);
                        CalculateCustomerRate(stopNo,rowNo);
                    }

                });
            }
        }

        function CalculateCustomerRate(stopNo,rowNo){
            var qty = $('##qty_'+stopNo+'_'+rowNo).val();
            var customerRate = $('##CustomerRate_'+stopNo+'_'+rowNo).val();
            customerRate = customerRate.replace("$","");
            customerRate = customerRate.replace(/,/g,"");

            if(isNaN(customerRate) || !customerRate.length){
                alert('Invalid rate.');
                customerRate=0;
                $('##CustomerRate_'+stopNo+'_'+rowNo).focus();
            }

            if(isNaN(qty) || !qty.length){
                alert('Invalid Quantity.');
                $('##qty_'+stopNo+'_'+rowNo).val(1);
                qty = 1;
                $('##qty_'+stopNo+'_'+rowNo).focus();
            }

            var custCharges = qty * customerRate;
            formatDollarNegative(custCharges,'custCharges_'+stopNo+'_'+rowNo);
            formatDollarNegative(customerRate,'CustomerRate_'+stopNo+'_'+rowNo);

            var customerCommoditiesCharges = 0;
            $( ".custCharges" ).each(function() {
                var custCharges = this.value;
                custCharges = custCharges.replace("$","");
                custCharges = custCharges.replace(/,/g,"");
                customerCommoditiesCharges = customerCommoditiesCharges + parseFloat(custCharges);
            });
            $("##customerCommoditiesCharges").val(customerCommoditiesCharges);
        }

        function settemperaturescale(){
            var temp = $("##equipment option:selected").data("temperature");
            var scale = $("##equipment option:selected").data("temperaturescale");
            $("##temperature").val(temp);
            $("##temperaturescale").val(scale);
        }

        function ClearShipper(stopNo,type){
            $('##'+type+"_"+stopNo).val('');
            $('##'+type+"id_"+stopNo).val('');
            $('##'+type+"location_"+stopNo).val('');
            $('##'+type+"city_"+stopNo).val('');
            $('##'+type+"state_"+stopNo).val('');
            $('##'+type+"Zipcode_"+stopNo).val('');
            $('##'+type+"ContactPerson_"+stopNo).val('');
            $('##'+type+"Phone_"+stopNo).val('');
            $('##'+type+"Fax_"+stopNo).val('');
            $('##'+type+"Email_"+stopNo).val('');
        }

        function validateCustomerLoad(){
            var rv = true;
            var CustomerID = $('##CustomerID').val();
            if (!$.trim(CustomerID).length) {
                alert('Please choose a broker.');
                $('##cutomerIdAuto').focus()
                rv = false;
            }

            var eqLen = $('##EquipmentLength').val();
            if (eqLen.length && (isNaN(eqLen) || $.trim(eqLen) == '')) {
                alert('Invalid Equipment Length.');
                $('##EquipmentLength').focus()
                rv = false;
            }
            var eqWid = $('##EquipmentWidth').val();
            if (eqWid.length && (isNaN(eqWid) || $.trim(eqWid) == '')) {
                alert('Invalid Equipment Width.');
                $('##EquipmentWidth').focus()
                rv = false;
            }
            var eqTemp = $('##temperature').val();
            if (eqTemp.length && (isNaN(eqTemp) || $.trim(eqTemp) == '')) {
                alert('Invalid Equipment Temperature.');
                $('##temperature').focus()
                rv = false;
            }

            $('.tr_commodity').each(function(i, obj) {
                var qty = $(this).find(".qty").val();
                if(isNaN(qty) || !qty.length){
                    alert('Invalid Quantity.');
                    rv = false;
                }
                var wt = $(this).find(".wt-textbox").val();
                if (wt.length && (isNaN(wt) || $.trim(wt) == '')) {
                    alert('Invalid Weight.');
                    rv = false;
                }
                var customerRate = $(this).find(".CustomerRate").val(); 
                customerRate = customerRate.replace("$","");
                customerRate = customerRate.replace(/,/g,"");
                if(isNaN(customerRate) || !customerRate.length){
                    alert('Invalid rate.');
                    rv = false;
                }
            })

            return rv;
        }

        function CopyLoad1(loadid,token,maxValue){
            $("##copyNoOfLoads").removeAttr('disabled');
            $("##copyNoOfLoads").removeAttr('readonly');
            $("##copyNoOfLoads").val(1);
            $("##cpyShowLoadCopyOptions").removeAttr('disabled');
            $("##cpyIncSalesDisp").removeAttr('disabled');
            $("##cpyIncDates").removeAttr('disabled');

            $('##copyOptionloadid').val(loadid);
            $('##copyOptiontoken').val(token);
            $('##copyOptionmaxValue').val(maxValue);
            $('.overlay').show();
            $('##copyOptionPopup').show();
            $('##copyNoOfLoads').focus();
        }
        function CopyLoad2(){
            var loadid=$('##copyOptionloadid').val();
            var token=$('##copyOptiontoken').val();
            var maxValue=$('##copyOptionmaxValue').val();

            var NoOfCopies=$('##copyNoOfLoads').val(); 

            if(isNaN(NoOfCopies) || parseInt(NoOfCopies) < 0 ||  isNaN(parseInt(NoOfCopies))){
                alert("Please enter a valid numeric value.");
                $('##copyNoOfLoads').focus();
                return false;
            }else if (parseInt(NoOfCopies)  > parseInt(maxValue) ){
                alert("The value should be less than "+maxValue);
                $('##copyNoOfLoads').focus();
                return false;
            }
            else if (parseInt(NoOfCopies) == 0) {
                alert('Please enter value greater than 0.');
                $('##copyNoOfLoads').focus();
                return false;
            }
            else{
                NoOfCopies = parseInt(NoOfCopies);
            }       

            var url = "index.cfm?event=addcustomerload";
            url += "&NoOfCopies="+parseInt(NoOfCopies);
            url += "&loadToBeCopied="+loadid;

            <cfif request.qSystemSetupOptions.ShowLoadCopyOptions>
                if($("##cpyShowLoadCopyOptions").is(':checked')){
                    url += "&ShowLoadCopyOptions=0"
                }
                else{
                    url += "&ShowLoadCopyOptions=1"
                }
                if($("##cpyIncSalesDisp").is(':checked')){
                    url += "&CopyLoadIncludeAgentAndDispatcher=1"
                }
                else{
                    url += "&CopyLoadIncludeAgentAndDispatcher=0"
                }
                if($("##cpyIncDates").is(':checked')){
                    url += "&CopyLoadDeliveryPickupDates=1"
                }
                else{
                    url += "&CopyLoadDeliveryPickupDates=0"
                }
            </cfif>

            url += "&"+token;
            window.open(url);
            closeCopyPopup();

        }

        function closeCopyPopup(){
            $('.overlay').hide();
            $('##copyOptionPopup').hide();
        }

        function swapStops(stop1,stop2){

            if (confirm("Are you sure you want to change the stops?")) {
                var path = urlComponentPath+"customerloadgateway.cfc?method=swapStops";
                $.ajax({
                    type: "Post",
                    url: path,
                    dataType: "json",
                    async: false,
                    data:{
                        dsn:'#application.dsn#',
                        LoadID:'#request.qLoad.LoadID#',
                        stop1:stop1,
                        stop2:stop2,
                        LoadNumber:'#request.qLoad.LoadNumber#',
                        UpdatedByUserID:'#variables.s_id#',
                        UpdatedBy:'#session.adminUserName#'
                    },
                    beforeSend: function() {
                        $('.overlay').show();
                        $('##loader').show();
                    },
                    success: function(data){
                        if(data == 'Success'){
                            window.location.href=window.location.href;
                        }
                        else{
                            alert('Something went wrong. Unable to change stops.');
                        }
                        $('.overlay').hide();
                        $('##loader').hide();
                    }
                });
            }
        }

        function showfullmap(loadid) {
             var path = urlComponentPath+"loadgateway.cfc?method=generateGoogleMapLink";
            $.ajax({
                type    : 'GET',
                url     : path,
                data    : {dsn : '#application.DSN#', loadId : loadid, isLoadList:1,CompanyID:'#session.CompanyID#'},
                dataType: "text",
                async   : false,
                success :function(url){
                    newwindow=window.open(url,'name','height=560,width=965,toolbar=0,scrollbars=0,location=0,statusbar=0,menubar=0,resizable=0');
                    if (window.focus) {newwindow.focus()}
                }
            });
        }
        function popitup(url) {
            newwindow=window.open(url,'Map','height=600,width=800');
            if (window.focus) {newwindow.focus()}
            return false;
        }
    </script>

    <div id="copyOptionPopup">
        <div class="copyOptionPopupHeader"><h1 style="color:white;font-weight:bold;">Copy Load</h1></div>
        <div class="copyOptionPopupContent">
            <fieldset>
                <input type="hidden" value="" id="copyOptionloadid">
                <input type="hidden" value="" id="copyOptiontoken">
                <input type="hidden" value="" id="copyOptionmaxValue">
                <label style="font-size: 14px;font-weight: bold;">How many copies would you like? (Maximum of #request.qSystemSetupOptions.CopyLoadLimit#)</label>
                <input type="text" id="copyNoOfLoads" value="1" onkeyup="if (/\D/g.test(this.value)) this.value = this.value.replace(/\D/g,'')">
                <div class="clear"></div>

                <cfif request.qSystemSetupOptions.ShowLoadCopyOptions>
                    <div class="copyLoadSysOpt">
                        <div style="border-bottom: solid 1px;">
                            <b style="font-size: 12px;">Load Copy Options</b>
                            (<label style="font-size: 11px;">Do not show this again</label>
                            <input type="checkbox" class="smallChk" id="cpyShowLoadCopyOptions">)
                        </div>
                        <label style="font-size: 12px;">Copy Sales Rep/Dispatcher?</label>
                        <input type="checkbox" id="cpyIncSalesDisp" class="popupChk" <cfif request.qSystemSetupOptions.CopyLoadIncludeAgentAndDispatcher EQ 1>checked="checked"</cfif> style="margin-left: 2px;">
                        <div class="clear"></div>
                        <label style="font-size: 12px;">Copy Delivery/Pickup Dates?</label>
                        <input type="checkbox" id="cpyIncDates" class="popupChk" <cfif request.qSystemSetupOptions.CopyLoadDeliveryPickupDates EQ 1>checked="checked"</cfif>>
                    </div>
                </cfif>
                <input type="button" value="OK" style="margin-left:305px;width: 40px !important" onclick="CopyLoad2()">
                <input type="button" value="Cancel" style="width: 65px !important" onclick="closeCopyPopup()">
            </fieldset>
        </div>
    </div> 

    <div class="overlay">
    </div>
    <div id="loader">
        <img src="images/loadDelLoader.gif">
        <p id="loadingmsg">Please wait.</p>
    </div>
</cfoutput>