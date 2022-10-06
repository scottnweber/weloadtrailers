<cfparam name="request.event" default="#URL.event#" />
<cfscript>
	variables.objloadGateway = getGateway("gateways.loadgateway", MakeParameters("dsn=#Application.dsn#,pwdExpiryDays=#Application.pwdExpiryDays#"));
	variables.objAgentGateway = getGateway("gateways.agentgateway", MakeParameters("dsn=#Application.dsn#,pwdExpiryDays=#Application.pwdExpiryDays#"));
	variables.objloadGatewayNew = getGateway("gateways.loadgatewaynew", MakeParameters("dsn=#Application.dsn#,pwdExpiryDays=#Application.pwdExpiryDays#"));
	variables.objequipmentGateway = getGateway("gateways.equipmentgateway", MakeParameters("dsn=#Application.dsn#,pwdExpiryDays=#Application.pwdExpiryDays#"));
	variables.objCarrierGateway = getGateway("gateways.carriergateway", MakeParameters("dsn=#Application.dsn#,pwdExpiryDays=#Application.pwdExpiryDays#"));
	variables.objAlertGateway = getGateway("gateways.alertgateway", MakeParameters("dsn=#Application.dsn#,pwdExpiryDays=#Application.pwdExpiryDays#"));
</cfscript>

<cfswitch expression="#request.event#">

	<cfcase value="uploadCSV">
		<cfinvoke component="#variables.objloadGateway#" method="uploadCSV" returnvariable="response" /> 
		<cfoutput>#serializeJSON(response)#</cfoutput>
	</cfcase>

	<cfcase value="AddCityStateRecord">
		<cfinvoke component="#variables.objAgentGateway#" method="AddCityStateRecord" frmStruct="#form#" returnvariable="response" /> 
		<cfoutput>#serializeJSON(response)#</cfoutput>
	</cfcase>

	<cfcase value="setSessionLanesLoadID">
		<cfset session.lanesLoadID =arraytolist(deserializeJSON(form.lanesLoadID))>
		<cfoutput>#serializeJSON(1)#</cfoutput>
	</cfcase>

	<cfcase value="ajxSendLoadEmailUpdate">
		<cfif structKeyExists(url, "CompanyID")>
			<cfset session.CompanyID = url.CompanyID>
		</cfif>
		<cfif structKeyExists(url, "UserFullName")>
			<cfset session.UserFullName = url.UserFullName>
		</cfif>
		<cfinvoke component="#variables.objloadGateway#" method="getSystemSetupOptions" returnvariable="request.qGetSystemSetupOptions" />
		<cfinvoke component="#variables.objloadGatewayNew#" method="SendLoadEmailUpdate" loadid="#url.LoadID#" NewStatus="#url.NewStatus#" /> 
		<cfif structKeyExists(session, "LoadEmailUpdateMsg")>
			<cfset structDelete(session, "LoadEmailUpdateMsg")>
		</cfif>
		<cfoutput>#serializeJSON(1)#</cfoutput>
	</cfcase>

	<cfcase value="updateUserAssignedLoadStatus">
		<cfif structKeyExists(session, "UserAssignedLoadStatus")>
			<cfif form.action EQ 'insert'>
				<cfif form.urlEvent EQ 'Myload' and not listFindNoCase(session.UserAssignedLoadStatus["MyLoads"], form.checkedStatus)>
					<cfset session.UserAssignedLoadStatus["MyLoads"] = listAppend(session.UserAssignedLoadStatus["MyLoads"], form.checkedStatus)>
				</cfif>

				<cfif form.urlEvent EQ 'load' and not listFindNoCase(session.UserAssignedLoadStatus["AllLoads"], form.checkedStatus)>
					<cfset session.UserAssignedLoadStatus["AllLoads"] = listAppend(session.UserAssignedLoadStatus["AllLoads"], form.checkedStatus)>
				</cfif>
			<cfelse>
				<cfif form.urlEvent EQ 'Myload' and listFindNoCase(session.UserAssignedLoadStatus["MyLoads"], form.checkedStatus)>
					<cfset session.UserAssignedLoadStatus["MyLoads"] = listDeleteAt(session.UserAssignedLoadStatus["MyLoads"], listFind(session.UserAssignedLoadStatus["MyLoads"], form.checkedStatus))>
				</cfif>

				<cfif form.urlEvent EQ 'load' and listFindNoCase(session.UserAssignedLoadStatus["AllLoads"], form.checkedStatus)>
					<cfset session.UserAssignedLoadStatus["AllLoads"] = listDeleteAt(session.UserAssignedLoadStatus["AllLoads"], listFind(session.UserAssignedLoadStatus["AllLoads"], form.checkedStatus))>
				</cfif>
			</cfif>

			<cfif structKeyExists(session, "IsCustomer") and structKeyExists(session, "customerid") and len(trim(session.customerid))>
				<cfinvoke component="#variables.objAgentGateway#" method="quickUserStatusUpdate" dsn="#form.dsn#" agentid="#session.customerid#" action="#form.action#" checkedStatus="#form.checkedStatus#" returnvariable="response" />
			</cfif>
		</cfif>
		<cfoutput>#serializeJSON(1)#</cfoutput>
	</cfcase>

	<cfcase value="ajxSendErrorReport">
		<cfmail from="#form.eEmail#" to="support@loadmanager.com" subject="#left((stripHTML(trim(form.eMessage))),100)#" type="html" server="#form.SmtpAddress#" username="#form.SmtpUsername#" password="#form.SmtpPassword#" port="#form.SmtpPort#" usessl="#form.FA_SSL#" usetls="#form.FA_TLS#">
			<cfoutput>
				Name :<b>#form.eName#</b><br>
				Email address :<b>#form.eEmail#</b><br><br>
				<b>#form.eMessage#</b><br>
				<b><u>Steps to reproduce:</u></b><br>
				<b>#Replace(form.eSteps, "#chr(13)##chr(10)#", "<br>" , "all")#</b><br>
				<cfif len(form.companycode)>Company Code : <b>#form.companycode#</b></cfif>
			</cfoutput>
		</cfmail>
		<cfoutput>#serializeJSON(1)#</cfoutput>
	</cfcase>

	<cfcase value="getDashBoardCarrierAuto">
		<cfinvoke component="#variables.objCarrierGateway#" method="getDashBoardCarrierAuto" term="#url.term#" returnvariable="qRet"></cfinvoke>
		<cfoutput>#serializeJSON(qRet)#</cfoutput>
	</cfcase>

	<cfcase value="updateDashboardChart">
		<cfif NOT structKeyExists(form, "dateType")>
			<cfset form.dateType = "NewPickupDate">
		</cfif>
		<cfinvoke component="#variables.objloadGatewayNew#" method="updateDashboardChart" groupby = "#form.GroupBy#" dateFrom = "#form.dateFrom#" dateTo = "#form.dateTo#" statusFrom = "#form.statusFrom#" statusTo = "#form.statusTo#" Dispatcher = "#form.Dispatcher#" SalesRep = "#form.SalesRep#" totalField="#form.totalField#" dateType="#form.dateType#" returnvariable="qRet"/>
		<cfoutput>#serializeJSON(qRet)#</cfoutput>
	</cfcase>

	<cfcase value="getEquipmentTruckTrailer">
		<cfinvoke component="#variables.objequipmentGateway#" method="getEquipmentTruckTrailer" EquipmentType="#url.EquipmentType#" returnvariable="qRet"/>
		<cfoutput>#serializeJSON(qRet)#</cfoutput>
	</cfcase>

	<cfcase value="ajxApproveCarrierRate">
		<cfinvoke component="#variables.objAlertGateway#" method="ApproveCarrierRate" LoadID="#url.LoadID#"/>
		<cfoutput>1</cfoutput>
	</cfcase>

	<cfcase value="ajxAcknowledgeAlert">
		<cfinvoke component="#variables.objAlertGateway#" method="AcknowledgeAlert" AlertID="#url.AlertID#"/>
		<cfoutput>1</cfoutput>
	</cfcase>

	<cfcase value="ajxUploadCarrierDoc">
		<cfinvoke component="#variables.objcarrierGateway#" method="ajxUploadCarrierDoc" returnvariable="qRet"/>
		<cfoutput>#serializeJSON(qRet)#</cfoutput>
	</cfcase>

	<cfcase value="ajxGetCarrierPacketURL"> 
		<cfinvoke component="#variables.objcarrierGateway#" method="GetCarrierPacketURL" CarrierID="#form.CarrierID#" returnvariable="qRet"/>
		<cfoutput>#serializeJSON(qRet)#</cfoutput>
	</cfcase>

	<cfcase value="ajxUploadTemplateFields"> 
		<cfinvoke component="#variables.objcarrierGateway#" method="SaveTemplateFields" frmStruct="#form#" returnvariable="qRet"/>
		<cfoutput>#serializeJSON(qRet)#</cfoutput>
	</cfcase>

	<cfcase value="ajxSelectEquipment"> 
		<cfinvoke component="#variables.objcarrierGateway#" method="SetEquipmentOnBoard" EquipmentID="#form.EquipmentID#"  ShowCarrierOnboarding="#form.ShowCarrierOnboarding#"/>
		<cfoutput>1</cfoutput>
	</cfcase>

	<cfcase value="ajxBulkDeleteLoad"> 
		<cfinvoke component="#variables.objloadGateway#" method="deleteLoad" loadid="#form.loadid#" dsn="#form.dsn#" empid='#form.empid#' adminUserName='#session.adminUserName#' bulkDelete=1 returnvariable="qRet"/>
		<cfoutput>#serializeJSON(qRet)#</cfoutput>
	</cfcase>

	<cfcase value="ajxCancelDispatch">
		<cfinvoke component="#variables.objloadGatewayNew#" method="CancelLoadDispatch" LoadID="#form.LoadID#"/>
		<cfoutput>1</cfoutput>
	</cfcase>

	<cfcase value="ajxVerifyDocument">
		<cfinvoke component="#variables.objCarrierGateway#" method="VerifyDocument" frmstruct="#form#" returnvariable="carrierstatus"/>
		<cfoutput>#carrierstatus#</cfoutput>
	</cfcase>

	<cfcase value="ajxCheckBetaVersion">
		<cfinvoke component="#variables.objagentGateway#" method="CheckBetaVersion" CompanyCode="#url.CompanyCode#" returnvariable="Ret"/>
		<cfoutput>#Ret#</cfoutput>
	</cfcase>

	<cfcase value="ajxUpdateUserRights">
		<cfinvoke component="#variables.objagentGateway#" method="UpdateUserRights" RoleID="#form.RoleID#" securityParameter="#form.securityParameter#" checked="#form.checked#" returnvariable="Ret"/>
		<cfoutput>#Ret#</cfoutput>
	</cfcase>

	<cfcase value="ajxUpdateEditableStatus">
		<cfinvoke component="#variables.objagentGateway#" method="UpdateEditableStatus" RoleID="#form.RoleID#" editableStatus="#form.editableStatus#" returnvariable="Ret"/>
		<cfoutput>#Ret#</cfoutput>
	</cfcase>

	<cfcase value="ajxCheckLoadLmit">
		<cfinvoke component="#variables.objloadGatewayNew#" method="CheckLoadLimitReached" returnvariable="Ret"/>
		<cfoutput>#Ret#</cfoutput>
	</cfcase>

	<cfcase value="ajxOffMobileAppSwitchConfirmation">
		<cfinvoke component="#variables.objagentGateway#" method="MobileAppSwitchConfirmation"/>
		<cfoutput>1</cfoutput>
	</cfcase>

	<cfcase value="ajxUpdateDaysFilterCookies">
		<cfinvoke component="#variables.objloadGatewayNew#" method="updateDaysFilterCookies" LoadsDaysFilter="#form.LoadsDaysFilter#" FilterDays="#form.FilterDays#" Advanced="#form.Advanced#"/>
		<cfoutput>1</cfoutput>
	</cfcase>

	<cfcase value="ajxUpdateCustomerPayment">
		<cfinvoke component="#variables.objloadGatewayNew#" method="UpdateCustomerPayment" frmstruct="#form#"/>
		<cfoutput>1</cfoutput>
	</cfcase>

	<cfcase value="ajxSaveLoadPricingNotes">
		<cfinvoke component="#variables.objloadGatewayNew#" LoadID="#form.LoadID#" PricingNotes="#form.PricingNotes#" method="UpdateLoadPricingNotes" />
		<cfoutput>1</cfoutput>
	</cfcase>

	<cfcase value="ajxsetDefaultBillFromCompany">
		<cfinvoke component="#variables.objloadGatewayNew#" CompanyID="#form.CompanyID#" checked="#form.checked#" method="UpdateDefaultBillFromCompany"/>
		<cfoutput>1</cfoutput>
	</cfcase>
	
	<cfcase value="ajxCustomerPaymentCsv">
		<cfinvoke component="#variables.objloadGatewayNew#" method="uploadCustomerPaymentCsv" returnvariable="response" /> 
		<cfoutput>#serializeJSON(response)#</cfoutput>
	</cfcase>

	<cfcase value="ajxCheckCarrierVendorID">
		<cfinvoke component="#variables.objCarrierGateway#" VendorID ="#url.VendorID#" method="CheckCarrierVendorID" returnvariable="response" /> 
		<cfoutput>#serializeJSON(response)#</cfoutput>
	</cfcase>

	<cfcase value="ajxSetBulkCarrierID">
		<cfset delTempDir = expandPath('../temp/')>
		<cfif directoryExists(delTempDir)>
			<cfdirectory action="list" directory="#delTempDir#" recurse="false" name="dirList" filter="BulkAlertCarrierID_*">
			<cfloop query="dirList">
				<cfif dateDiff('h', dirList.DateLastModified, now()) GT 1>
					<cfset FileDelete("#dirList.directory#/#dirList.Name#")>
				</cfif>
			</cfloop>
		</cfif>
		<cfset filePath = expandPath("../temp/")>
		<cfset timeStamp = dateTimeFormat(now(),'YYMMDDHHNNSSL')>
		<cfset fileName = "BulkAlertCarrierID_"&session.CompanyID&"_"&timeStamp>
		<cfset opList = arrayToList(deserializeJSON(form.ArrCarrierID))>
		<cffile action="write" file="#filePath##fileName#.txt" output="#opList#">
		<cfoutput>#timeStamp#</cfoutput>
	</cfcase>

	<cfcase value="ajxUpdateSortCookies">
		<cfcookie name="#form.fieldName#" value="#form.val#" expires="never">
		<cfoutput>1</cfoutput>
	</cfcase>

	<cfcase value="ajxUpdateReportCookies">
		<cfcookie name="#form.fieldName#" value="#form.val#" expires="never">
		<cfoutput>1</cfoutput>
	</cfcase>
	
	<cfcase value="ajxClearSortCookies">
		<cfcookie name="SortBy1" value="StatusOrder" expires="never">
		<cfcookie name="SortOrder1" value="ASC" expires="never">
		<cfcookie name="SortBy2" value="l.LoadNumber" expires="never">
		<cfcookie name="SortOrder2" value="ASC" expires="never">>
		<cfcookie name="SortBy3" value="" expires="never">
		<cfcookie name="SortOrder3" value="ASC" expires="never">>
		<cfoutput>1</cfoutput>
	</cfcase>
</cfswitch>

<cffunction name="MakeParameters" access="private" output="false" returntype="Array">
	<cfargument name="ParameterString" type="string" required="yes" />
	<cfset var arrReturn = ArrayNew(1) />
	<cfset var tmpStruct = "" />
	<cfset var strParameterStringItem = "" />
	<cfset var intArrayCount = 0 />
	
	<cfloop list="#arguments.ParameterString#" index="strParameterStringItem">
		<cfset tmpStruct = StructNew() />
		<cfset tmpStruct.name = ListFirst(strParameterStringItem, "=") />
		<cfset tmpStruct.value = ListLast(strParameterStringItem, "=") />
		<cfset intArrayCount = intArrayCount + 1 />
		<cfset arrReturn[intArrayCount] = tmpStruct />
	</cfloop>
	
	<cfreturn arrReturn />
</cffunction>

<cffunction name="getGateway" access="private" output="false" returntype="any">
	<cfargument name="GatewayPath" type="string" required="yes" />
	<cfargument name="Parameters" type="array" required="no" default="#ArrayNew(1)#" />
	<cfset var tmpGateway = "" />
	<cfset var objFile = CreateObject("java", "java.io.File") />
	<cfset var objDate = CreateObject("java","java.util.Date") />
	<cfset var blnGatewayExpired = true />
	<cfset var intArrayCount = 0 />
	
    <!--- Check the Last Modified Date --->
    <cftry>
		<cfscript>
	        if (Not StructKeyExists(Application, "Gateways"))
	            Application.Gateways = StructNew();

	        if (StructKeyExists(Application.Gateways, arguments.GatewayPath)) {
	            objFile.init(ExpandPath(Replace(arguments.GatewayPath, ".", "/", "ALL")));
	            if (StructKeyExists(Application.Gateways[arguments.GatewayPath],"lastLoaded") AND objDate.init(objFile.lastModified()) GT Application.Gateways[arguments.GatewayPath].lastLoaded)
	                blnGatewayExpired = true;
	        }
	    </cfscript>
    	<cfcatch></cfcatch>
	</cftry>
    
	<cfif (Not StructKeyExists(Application.Gateways, arguments.GatewayPath) OR IsDefined("URL.reload") OR blnGatewayExpired OR Session.blnDebugMode)>
		<!--- Lock and Reload --->
		<cflock name="application_#Application.Name#_gatewayloader" type="exclusive" timeout="120">

			<cfset tmpGateway = CreateObject("component", arguments.GatewayPath) />

			<cfinvoke component="#tmpGateway#" method="init">
				<cfloop from="1" to="#ArrayLen(arguments.Parameters)#" index="intArrayCount">
					<cfinvokeargument name="#arguments.Parameters[intArrayCount].name#" value="#arguments.Parameters[intArrayCount].value#" />
				</cfloop>
			</cfinvoke>

			<cfscript>
				Application.Gateways[arguments.GatewayPath] = StructNew();
				Application.Gateways[arguments.GatewayPath].object = tmpGateway;
				Application.Gateways[arguments.GatewayPath].lastLoaded = Now();
			</cfscript>

        </cflock>
	</cfif>
	
	<cfreturn Application.Gateways[arguments.GatewayPath].object />

</cffunction>
<cfscript>
function stripHTML(str) {
    // remove the whole tag and its content
    var list = "style,script,noscript";
    for (var tag in list){
        str = reReplaceNoCase(str, "<s*(#tag#)[^>]*?>(.*?)","","all");
    }

    str = reReplaceNoCase(str, "<.*?>","","all");
    //get partial html in front
    str = reReplaceNoCase(str, "^.*?>","");
    //get partial html at end
    str = reReplaceNoCase(str, "<.*$","");

    str = ReplaceNoCase(str, "&nbsp;","","ALL");
    return trim(str);

}
</cfscript>