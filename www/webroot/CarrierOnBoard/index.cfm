<cfinclude template="checkCarrierExists.cfm">
<cfparam name="OnboardStatus" default="0">
<cfparam name="url.CarrierID" default="">
<cfif len(trim(url.CarrierID))>
	<cfinvoke component="cfc.carrier" method="CheckOnboardStatus" returnVariable="OnboardStatus">
		<cfinvokeargument name="CarrierID" value="#url.CarrierID#">
	</cfinvoke>
</cfif>
<cfif structKeyExists(url, "CompanyID")>
	<cfinvoke component="cfc.carrier" method="GetCompanySystemConfig" returnVariable="qSystemConfig"></cfinvoke>
<cfelse>
	<cfinvoke component="cfc.carrier" method="GetSystemConfig" returnVariable="qSystemConfig"></cfinvoke>
</cfif>
<cfinvoke component="cfc.carrier" method="GetCarrierAttachmentTypes" returnVariable="qAttTypes">
	<cfinvokeargument name="CompanyID" value="#qSystemConfig.CompanyID#">
</cfinvoke>
<cfinvoke component="cfc.carrier" method="GetTemplates" returnVariable="qTemplates">
	<cfinvokeargument name="CompanyID" value="#qSystemConfig.CompanyID#">
</cfinvoke>
<cfinvoke component="cfc.carrier" method="GetEquipments" returnVariable="qEquipments">
	<cfinvokeargument name="CompanyID" value="#qSystemConfig.CompanyID#">
</cfinvoke>
<cfparam name="listEvents" default="">
<cfif NOT structKeyExists(url, "RenewAttachmentType")>
	<cfset listEvents = "CarrierInformation,CarrierInsurance,AddContact,CoveredLanes">
	<cfif qEquipments.recordcount>
		<cfset listEvents = listAppend(listEvents, "CarrierEquipments")>
	</cfif>
	<cfif qSystemConfig.PromptForACHInformation>
		<cfset listEvents = listAppend(listEvents, "CarrierACHInformation")>
	</cfif>
	<cfif qSystemConfig.PromptForELDStatus OR qSystemConfig.PromptForCertifications>
		<cfset listEvents = listAppend(listEvents, "CarrierELDAndCertification")>
	</cfif>
	<cfloop query="qAttTypes">
		<cfset listEvents = listAppend(listEvents, "#qAttTypes.AttachmentTypeID#_AttachFile")>
	</cfloop>
	<cfloop query="qTemplates">
		<cfset listEvents = listAppend(listEvents, "#qTemplates.ID#_ZohoSign")>
	</cfloop>
<cfelse>
	<cfloop list="#url.RenewAttachmentType#" item="ID">
		<cfset listEvents = listAppend(listEvents, "#ID#_AttachFile")>
	</cfloop>
</cfif>
<cfif NOT listFindNoCase("FinishOnBoard,DocumentRenewed,SubmitManually", url.event)>
	<cfset TotalStep = listLen(listEvents)>
	<cfset CurrentStep = listFindNoCase(listEvents, replaceNoCase(url.event, ":Process", ""))>
	<cfif CurrentStep NEQ TotalStep>
		<cfset NextEvent = listGetAt(listEvents, CurrentStep+1)>
	<cfelse>
		<cfif NOT structKeyExists(url, "RenewAttachmentType")>
			<cfset NextEvent = "FinishOnBoard">
		<cfelse>
			<cfset NextEvent = "DocumentRenewed">
		</cfif>
	</cfif>
	<cfif CurrentStep NEQ 1 AND CurrentStep NEQ 0>
		<cfset PrevEvent = listGetAt(listEvents, CurrentStep-1)>
	</cfif>
</cfif>
<cfif findNoCase("_AttachFile", url.event)>
	<cfif structKeyExists(url,'event') AND url.event EQ '_AttachFile'>
		<cfdump  var="Something went wrong please try again later..."><cfabort>
	</cfif>
	<cfset AttachmentTypeID = listGetAt(url.event, 1,'_')>
	<cfset url.event = listGetAt(url.event, 2,'_')>
</cfif>
<cfif findNoCase("_ZohoSign", url.event)>
	<cfset ID = listGetAt(url.event, 1,'_')>
	<cfset url.event = listGetAt(url.event, 2,'_')>
</cfif>
<cfif isDefined("NextEvent") AND structKeyExists(form, "back") AND structKeyExists(form, "PrevEvent")>
	<cfset NextEvent = form.PrevEvent>
</cfif>
<cfif OnboardStatus EQ 2 AND not structKeyExists(url, "isPdf") AND NOT structKeyExists(url, "RenewAttachmentType")>
	<cfinclude template="include/Header.cfm" />
	<cfinclude template="form/OnBoardCompleted.cfm" />
	<cfinclude template="include/Footer.cfm" />
	<cfabort>
</cfif>
<cfif structKeyExists(url, "CarrierOnboardStatus") AND url.CarrierOnboardStatus EQ 1 AND not structKeyExists(url, "isPdf") AND NOT structKeyExists(url, "RenewAttachmentType")>
	<cfinclude template="include/Header.cfm" />
	<cfinclude template="form/OnBoardStarted.cfm" />
	<cfinclude template="include/Footer.cfm" />
	<cfabort>
</cfif>
<cfif structKeyExists(url, "isPdf")><cfset TotalStep = 7></cfif>
<cfswitch expression="#url.event#">
	<cfcase value="CarrierInformation">
		<cfinvoke component="cfc.carrier" method="GetStates" returnVariable="qStates"></cfinvoke>
		<cfinvoke component="cfc.carrier" method="GetCountries" returnVariable="qCountries"></cfinvoke>
		<cfinvoke component="cfc.carrier" method="GetCarrierInfo" returnVariable="qCarrierInfo">
			<cfinvokeargument name="CarrierID" value="#url.CarrierID#">
		</cfinvoke>
		<cfinclude template="include/Header.cfm" />
		<cfinclude template="form/CarrierInformation.cfm" />
		<cfinclude template="include/Footer.cfm" />
	</cfcase>

	<cfcase value="CarrierInformation:Process">
		<cfif not structIsEmpty(form)>
			<cfinvoke component="cfc.carrier" method="SaveCarrierInfo" returnvariable="resCarrierID">
				<cfinvokeargument name="CarrierID" value="#url.CarrierID#">
				<cfinvokeargument name="FrmStruct" value="#form#">
			</cfinvoke>
			<cflocation url="index.cfm?event=#NextEvent#&CarrierID=#resCarrierID#">
		<cfelse>
			<cflocation url="index.cfm?event=#NextEvent#&CarrierID=#url.CarrierID#">
		</cfif>
	</cfcase>

	<cfcase value="CarrierInsurance">
		<cfinvoke component="cfc.carrier" method="GetCarrierInsuranceInfo" returnVariable="qCarrierInsuranceInfo">
			<cfinvokeargument name="CarrierID" value="#url.CarrierID#">
		</cfinvoke>
		<cfinvoke component="cfc.carrier" method="GetBIPDInsuranceCertificate" CarrierID="#url.CarrierID#" returnVariable="qCertificate"></cfinvoke>
		<cfinvoke component="cfc.carrier" method="GetCargoInsuranceCertificate" CarrierID="#url.CarrierID#" returnVariable="qCargoCertificate"></cfinvoke>
		<cfinvoke component="cfc.carrier" method="GetGeneralInsuranceCertificate" CarrierID="#url.CarrierID#" returnVariable="qGeneralCertificate"></cfinvoke>
		<cfinclude template="include/Header.cfm" />
		<cfinclude template="form/CarrierInsurance.cfm" />
		<cfinclude template="include/Footer.cfm" />
	</cfcase>

	<cfcase value="CarrierInsurance:Process">
		<cfif not structIsEmpty(form)>
			<cfinvoke component="cfc.carrier" method="SaveCarrierInsurance">
				<cfinvokeargument name="CarrierID" value="#url.CarrierID#">
				<cfinvokeargument name="FrmStruct" value="#form#">
			</cfinvoke>
		<cfif structKeyExists(form, 'file')>
			<cfinvoke component="cfc.carrier" method="AttachInsuranceCertificate" returnvariable="request.InsuranceBIPD">
				<cfinvokeargument name="CarrierID" value="#url.CarrierID#">
				<cfinvokeargument name="FrmStruct" value="#form#">
				<cfinvokeargument name="AttachmentLabel" value="InsuranceBIPD">
				<cfinvokeargument name="file" value="#form.file#">
				<cfinvokeargument name="fileField" value="file">
				<cfinvokeargument name="InsExpDate" value="#form.InsExpDate#">
			</cfinvoke>
			<cfif isDefined('request.InsuranceBIPD') AND request.InsuranceBIPD EQ 'error'>
				<cflocation url="index.cfm?event=CarrierInsurance&CarrierID=#url.CarrierID#&mssg=1">
			</cfif>
		</cfif>
		<cfif structKeyExists(form, 'file_1')>
			<cfinvoke component="cfc.carrier" method="AttachInsuranceCertificate" returnvariable="request.InsuranceCargo">
				<cfinvokeargument name="CarrierID" value="#url.CarrierID#">
				<cfinvokeargument name="FrmStruct" value="#form#">
				<cfinvokeargument name="AttachmentLabel" value="InsuranceCargo">
				<cfinvokeargument name="file" value="#form.file_1#">
				<cfinvokeargument name="fileField" value="file_1">
				<cfinvokeargument name="InsExpDate" value="#form.InsExpDateCargo#">
			</cfinvoke>
			<cfif isDefined('request.InsuranceCargo') AND request.InsuranceCargo EQ 'error'>
				<cflocation url="index.cfm?event=CarrierInsurance&CarrierID=#url.CarrierID#&mssg=1">
			</cfif>
		</cfif>
		<cfif structKeyExists(form, 'file_2')>
			<cfinvoke component="cfc.carrier" method="AttachInsuranceCertificate" returnvariable="request.InsuranceGeneral">
				<cfinvokeargument name="CarrierID" value="#url.CarrierID#">
				<cfinvokeargument name="FrmStruct" value="#form#">
				<cfinvokeargument name="AttachmentLabel" value="InsuranceGeneral">
				<cfinvokeargument name="file" value="#form.file_2#">
				<cfinvokeargument name="fileField" value="file_2">
				<cfinvokeargument name="InsExpDate" value="#form.InsExpDateGeneral#">
			</cfinvoke>
			<cfif isDefined('request.InsuranceGeneral') AND request.InsuranceGeneral EQ 'error'>
				<cflocation url="index.cfm?event=CarrierInsurance&CarrierID=#url.CarrierID#&mssg=1">
			</cfif>
		</cfif>
		</cfif>
		<cflocation url="index.cfm?event=#NextEvent#&CarrierID=#url.CarrierID#">
	</cfcase>

	<cfcase value="AddContact">
		<cfinvoke component="cfc.carrier" method="GetContacts"  returnVariable="qDrivers">
			<cfinvokeargument name="CarrierID" value="#url.CarrierID#">
			<cfinvokeargument name="ContactType" value="Driver">
		</cfinvoke>
		<cfinvoke component="cfc.carrier" method="GetContacts"  returnVariable="qContacts">
			<cfinvokeargument name="CarrierID" value="#url.CarrierID#">
		</cfinvoke>
		<cfinclude template="include/Header.cfm" />
		<cfinclude template="form/AddContact.cfm" />
		<cfinclude template="include/Footer.cfm" />
	</cfcase>

	<cfcase value="AddContact:Process">
		<cfif not structIsEmpty(form)>
			<cfinvoke component="cfc.carrier" method="AddCarrierContact">
				<cfinvokeargument name="CarrierID" value="#url.CarrierID#">
				<cfinvokeargument name="FrmStruct" value="#form#">
			</cfinvoke>
		</cfif>
		<cflocation url="index.cfm?event=#NextEvent#&CarrierID=#url.CarrierID#">
	</cfcase>

	<cfcase value="CoveredLanes">
		<cfinvoke component="cfc.carrier" method="GetLanes" returnVariable="qLanes">
			<cfinvokeargument name="CarrierID" value="#url.CarrierID#">
		</cfinvoke>
		<cfinclude template="include/Header.cfm" />
		<cfinclude template="form/CoveredLanes.cfm" />
		<cfinclude template="include/Footer.cfm" />
	</cfcase>

	<cfcase value="CoveredLanes:Process">
		<cfinvoke component="cfc.carrier" method="SaveCoveredLanes">
			<cfinvokeargument name="CarrierID" value="#url.CarrierID#">
			<cfinvokeargument name="FrmStruct" value="#form#">
		</cfinvoke>
		<cflocation url="index.cfm?event=#NextEvent#&CarrierID=#url.CarrierID#">
	</cfcase>

	<cfcase value="CarrierEquipments">
		<cfinvoke component="cfc.carrier" method="GetCarrierEquipments" returnVariable="qCarrierEquipments">
			<cfinvokeargument name="CarrierID" value="#url.CarrierID#">
		</cfinvoke>
		<cfinclude template="include/Header.cfm" />
		<cfinclude template="form/CarrierEquipments.cfm" />
		<cfinclude template="include/Footer.cfm" />
	</cfcase>

	<cfcase value="CarrierEquipments:Process">
		<cfinvoke component="cfc.carrier" method="SaveCarrierEquipments">
			<cfinvokeargument name="CarrierID" value="#url.CarrierID#">
			<cfinvokeargument name="FrmStruct" value="#form#">
		</cfinvoke>
		<cflocation url="index.cfm?event=#NextEvent#&CarrierID=#url.CarrierID#">
	</cfcase>

	<cfcase value="CarrierACHInformation">
		<cfinvoke component="cfc.carrier" method="GetCopyOfVoidedCheck" CarrierID="#url.CarrierID#" returnVariable="qCopyOfVoid"></cfinvoke>
		<cfinvoke component="cfc.carrier" method="GetStates" returnVariable="qStates"></cfinvoke>
		<cfinvoke component="cfc.carrier" method="GetCarrierACH" returnVariable="qCarrierACH">
			<cfinvokeargument name="CarrierID" value="#url.CarrierID#">
		</cfinvoke>
		<cfinclude template="include/Header.cfm" />
		<cfinclude template="form/CarrierACHInformation.cfm" />
		<cfinclude template="include/Footer.cfm" />
	</cfcase>
	
	<cfcase value="CarrierACHInformation:Process">
		<cfif not structIsEmpty(form)>
			<cfif structKeyExists(form, 'file')>
				<cfinvoke component="cfc.carrier" method="AttachInsuranceCertificate">
					<cfinvokeargument name="CarrierID" value="#url.CarrierID#">
					<cfinvokeargument name="FrmStruct" value="#form#">
					<cfinvokeargument name="AttachmentLabel" value="Copy of voided check">
					<cfinvokeargument name="file" value="#form.file#">
					<cfinvokeargument name="fileField" value="file">
				</cfinvoke>
			</cfif>
			<cfinvoke component="cfc.carrier" method="SaveCarrierACH">
				<cfinvokeargument name="CarrierID" value="#url.CarrierID#">
				<cfinvokeargument name="FrmStruct" value="#form#">
			</cfinvoke>
		</cfif>
		<cflocation url="index.cfm?event=#NextEvent#&CarrierID=#url.CarrierID#">
	</cfcase>

	<cfcase value="CarrierELDAndCertification">
		<cfinvoke component="cfc.carrier" method="GetCarrierELDAndCertification" returnVariable="qCarrierELDCert">
			<cfinvokeargument name="CarrierID" value="#url.CarrierID#">
		</cfinvoke>
		<cfinclude template="include/Header.cfm" />
		<cfinclude template="form/CarrierELDAndCertification.cfm" />
		<cfinclude template="include/Footer.cfm" />
	</cfcase>

	<cfcase value="CarrierELDAndCertification:Process">
		<cfif qSystemConfig.PromptForELDStatus>
			<cfinvoke component="cfc.carrier" method="SaveELDStatus">
				<cfinvokeargument name="CarrierID" value="#url.CarrierID#">
				<cfinvokeargument name="FrmStruct" value="#form#">
			</cfinvoke>
		</cfif>
		<cfif qSystemConfig.PromptForCertifications>
			<cfinvoke component="cfc.carrier" method="SaveCertifications">
				<cfinvokeargument name="CarrierID" value="#url.CarrierID#">
				<cfinvokeargument name="FrmStruct" value="#form#">
			</cfinvoke>
		</cfif>
		<cflocation url="index.cfm?event=#NextEvent#&CarrierID=#url.CarrierID#">
	</cfcase>

	<cfcase value="AttachFile">
		<cfinvoke component="cfc.carrier" method="GetAttachmentTypeDetail" AttachmentTypeID="#AttachmentTypeID#" returnVariable="qAttDetail"></cfinvoke>
		<cfinvoke component="cfc.carrier" method="GetCarrierAttachment" CarrierID="#url.CarrierID#" AttachmentTypeID="#AttachmentTypeID#" returnVariable="qCarrAtt"></cfinvoke>
		<cfinclude template="include/Header.cfm" />
		<cfinclude template="form/AttachFile.cfm" />
		<cfinclude template="include/Footer.cfm" />
	</cfcase>

	<cfcase value="AttachFile:Process">
		<cfif structIsEmpty(form)>
			<cfabort>
		</cfif>
		<cfinvoke component="cfc.carrier" method="AttachFile">
			<cfinvokeargument name="CarrierID" value="#url.CarrierID#">
			<cfinvokeargument name="FrmStruct" value="#form#">
		</cfinvoke>
		<cfif structKeyExists(url, "RenewAttachmentType")>
			<cflocation url="index.cfm?event=#NextEvent#&CarrierID=#url.CarrierID#&RenewAttachmentType=#url.RenewAttachmentType#">
		</cfif>
		<cflocation url="index.cfm?event=#NextEvent#&CarrierID=#url.CarrierID#">
	</cfcase>

	<cfcase value="ZohoSign">
		<cfinvoke component="cfc.carrier" method="ZohoSignAPI" returnVariable="zohoEmbedded">
			<cfinvokeargument name="CarrierID" value="#url.CarrierID#">
			<cfinvokeargument name="TemplateID" value="#ID#">
			<cfinvokeargument name="CompanyID" value="#qSystemConfig.CompanyID#">
			<cfinvokeargument name="CompanyCode" value="#qSystemConfig.CompanyCode#">
		</cfinvoke>
		<cfinclude template="include/Header.cfm" />
		<cfinclude template="form/ZohoSign.cfm" />
		<cfinclude template="include/Footer.cfm" />
	</cfcase>

	<cfcase value="ZohoSign:Process">
		<cflocation url="index.cfm?event=#NextEvent#&CarrierID=#url.CarrierID#">
	</cfcase>

	<cfcase value="FinishOnBoard">
		<cfinvoke component="cfc.carrier" method="FinishOnBoard">
			<cfinvokeargument name="CarrierID" value="#url.CarrierID#">
		</cfinvoke>
		<cfif structKeyExists(url, "SwitchManualSign")>
			<cfoutput>1</cfoutput><cfabort>
		</cfif>
		<cfinclude template="include/Header.cfm" />
		<cfinclude template="form/FinishOnBoard.cfm" />
		<cfinclude template="include/Footer.cfm" />
	</cfcase>

	<cfcase value="SubmitManually">
		<cfhttp
			method="POST"
			url="https://api.dropboxapi.com/2/files/get_temporary_link"	
			result="returnStruct"> 
			<cfhttpparam type="HEADER" name="Authorization" value="Bearer #qSystemConfig.DropBoxAccessToken#">	
			<cfhttpparam type="HEADER" name="Content-Type" value="application/json">	
			<cfhttpparam type="body" value='{"path":#SerializeJSON('/fileupload/img/#qSystemConfig.CompanyCode#/' & url.UploadFileName)#}'>
		</cfhttp> 
		<cfset filePath = deserializeJSON(returnStruct.fileContent).link>
		<cfinclude template="include/Header.cfm" />
		<cfinclude template="form/SubmitManually.cfm" />
		<cfinclude template="include/Footer.cfm" />
	</cfcase>

	<cfcase value="DocumentRenewed">
		<cfinvoke component="cfc.carrier" method="DocumentRenewed">
			<cfinvokeargument name="CarrierID" value="#url.CarrierID#">
		</cfinvoke>
		<cfinclude template="include/Header.cfm" />
		<cfinclude template="form/DocumentRenewed.cfm" />
		<cfinclude template="include/Footer.cfm" />
	</cfcase>
	<cfdefaultcase></cfdefaultcase>
</cfswitch>
<cfif isDefined("currentStep") AND not structKeyExists(url, "isPdf") AND len(trim(url.carrierid)) AND NOT structKeyExists(url, "RenewAttachmentType")>
	<cfinvoke component="cfc.carrier" method="UpdateCarrierOnboardStep" CarrierID="#url.carrierid#" CarrierOnboardStep = "STEP #currentStep# OF #TotalStep#"></cfinvoke>
</cfif>