<cfquery name="qrygetFilterCarriers" datasource="#Application.dsn#">
	<cfif structKeyExists(url, "loadid")>
		SELECT DISTINCT 
		isnull(carr.email,C.EmailID) as email,
		isnull(carr.ContactPerson,c.contactperson) as contactperson,
		isnull(carr.phoneno,c.phone) as phoneno,
		isnull(carr.phonenoext,c.phoneext) as phonenoext,
		isnull(carr.fax,c.fax) as fax,
		isnull(carr.faxext,c.faxext) as faxext,
		isnull(carr.tollfree,c.tollfree) as tollfree,
		isnull(carr.tollfreeext,c.tollfreeext) as tollfreeext,
		isnull(carr.PersonMobileNo,c.Cel) as PersonMobileNo,
		isnull(carr.MobileNoExt,c.CellPhoneExt) as MobileNoExt,
		ContactType,
		carr.CarrierContactID
		,NULL AS EqTruck
		,NULL AS EqTrailer
		FROM LoadStops a
		JOIN LoadStops b ON a.LoadID = b.LoadID AND a.StopNo = b.StopNo
		LEFT OUTER JOIN (SELECT [CarrierID],email,ContactPerson,phoneno,phonenoext,fax,faxext,tollfree,tollfreeext,PersonMobileNo,MobileNoExt,ContactType,CarrierContactID from CarrierContacts) AS carr ON carr.CarrierID = a.NewCarrierID
		LEFT OUTER JOIN Carriers C ON C.CarrierID = a.NewCarrierID 
		WHERE a.LoadID =<cfqueryparam value="#url.loadid#" cfsqltype="cf_sql_varchar">

		AND a.LoadType = 1
		AND b.LoadType = 2
		AND b.StopNo =a.StopNo
		AND isnull(carr.email,C.EmailID) LIKE <cfqueryparam value="%#url.term#%" cfsqltype="cf_sql_varchar">
	<cfelse>
		select CarrierContactID,email,ContactPerson,phoneno,phonenoext,fax,faxext,tollfree,tollfreeext,PersonMobileNo,MobileNoExt,ContactType 

		,(SELECT TOP 1 EquipmentID FROM CarrierEquipments WHERE CarrierID = <cfqueryparam value="#url.carrierid#" cfsqltype="cf_sql_varchar"> AND DriverContactID = CarrierContacts.CarrierContactID) AS EqTruck

		,(SELECT TOP 1 E.TruckTrailerOption FROM CarrierEquipments CE
			LEFT JOIN Equipments E ON E.EquipmentID = CE.EquipmentID
			WHERE CE.CarrierID = <cfqueryparam value="#url.carrierid#" cfsqltype="cf_sql_varchar"> AND CE.DriverContactID = CarrierContacts.CarrierContactID) AS EqTrailer

		from CarrierContacts
		where carrierid = <cfqueryparam value="#url.carrierid#" cfsqltype="cf_sql_varchar" null="#not len(url.carrierid)#">
		AND <cfif structKeyExists(url, "type") and url.type EQ "contact">
				ContactPerson LIKE <cfqueryparam value="#url.term#%" cfsqltype="cf_sql_varchar">
			<cfelse>
				email LIKE <cfqueryparam value="%#url.term#%" cfsqltype="cf_sql_varchar">
			</cfif> 
			<cfif structKeyExists(url, "contactType") and url.contactType EQ "Driver">
				AND ContactType ='Driver'
			</cfif>
		UNION
		select CarrierID AS CarrierContactID,EmailID,ContactPerson,phone,phoneext,fax,faxext,tollfree,tollfreeext,Cel,CellPhoneExt,'General' ContactType,NULL AS EqTruck,NULL AS EqTrailer from Carriers
		where carrierid = <cfqueryparam value="#url.carrierid#" cfsqltype="cf_sql_varchar" null="#not len(url.carrierid)#">
		AND <cfif structKeyExists(url, "type") and url.type EQ "contact">
				ContactPerson LIKE <cfqueryparam value="#url.term#%" cfsqltype="cf_sql_varchar">
			<cfelse>
				emailid LIKE <cfqueryparam value="%#url.term#%" cfsqltype="cf_sql_varchar">
			</cfif> 
			<cfif structKeyExists(url, "contactType") and url.contactType EQ "Driver">
				AND 1 = 2
			</cfif>
	</cfif>
</cfquery>

<cfset thisArrayBecomesJSON = [] />
<cfloop query="qrygetFilterCarriers">
	{
		<cfset thisEvent = {
		"label" = "#qrygetFilterCarriers.email#",	
		"value" = "#qrygetFilterCarriers.email#",	
		"email" = "#qrygetFilterCarriers.email#",
		"ContactPerson" = "#qrygetFilterCarriers.ContactPerson#",
		"phoneno" = "#qrygetFilterCarriers.phoneno#",
		"phonenoext" = "#qrygetFilterCarriers.phonenoext#",
		"fax" = "#qrygetFilterCarriers.fax#",
		"faxext" = "#qrygetFilterCarriers.faxext#",
		"tollfree" = "#qrygetFilterCarriers.tollfree#",
		"tollfreeext" = "#qrygetFilterCarriers.tollfreeext#",
		"PersonMobileNo" = "#qrygetFilterCarriers.PersonMobileNo#",
		"MobileNoExt" = "#qrygetFilterCarriers.MobileNoExt#",
		"ContactType" = "#qrygetFilterCarriers.ContactType#",
		"CarrierContactID" = "#qrygetFilterCarriers.CarrierContactID#",
		"EqTruck" = "#qrygetFilterCarriers.EqTruck#",
		"EqTrailer" = "#qrygetFilterCarriers.EqTrailer#"
		} />
	}
	<cfset arrayAppend( thisArrayBecomesJSON, thisEvent ) />
</cfloop>
<cfset myJSON = serializeJSON( thisArrayBecomesJSON ) />
<cfoutput>#myJSON#</cfoutput>








