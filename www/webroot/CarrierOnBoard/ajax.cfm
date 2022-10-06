<cfswitch expression="#url.event#">
	<cfcase value="ajxDelContact">
		<cfinvoke component="cfc.carrier" method="DeleteContact" CarrierContactID="#form.CarrierContactID#"></cfinvoke>
	</cfcase>
	<cfcase value="ajxDelLane">
		<cfinvoke component="cfc.carrier" method="DeleteLane" Lane="#form.Lane#" CarrierID = "#form.CarrierID#"></cfinvoke>
	</cfcase>
	<cfcase value="ajxDelCarrEquip">
		<cfinvoke component="cfc.carrier" method="DeleteCarrierEquipment" EquipmentID="#form.EquipmentID#" CarrierID = "#form.CarrierID#"></cfinvoke>
	</cfcase>
	<cfcase value="ajxDelAttachment">
		<cfinvoke component="cfc.carrier" method="DeleteAttachment" AttachmentID="#form.AttachmentID#" AttachmentFileName="#form.AttachmentFileName#"></cfinvoke>
	</cfcase>
	<cfcase value="ajxISDocumentSigned">
		<cfinvoke component="cfc.carrier" method="ISDocumentSigned" RequestID="#url.RequestID#" returnvariable="IsSigned"></cfinvoke>
		<cfoutput>#serializeJSON(IsSigned)#</cfoutput>
	</cfcase>
	<cfdefaultcase></cfdefaultcase>
</cfswitch>