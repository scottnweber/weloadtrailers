<cfcomponent output="false">
<cffunction name="init" access="public" output="false" returntype="void">
	<cfargument name="dsn" type="string" required="yes" />
	<cfset variables.dsn = Application.dsn />
</cffunction>
<!----Get All Equipments Information---->
<cffunction name="getAllEquipments" access="public" output="false" returntype="any">
    <cfargument name="EquipmentID" required="no" type="any">
	<cfargument name="sortorder" required="no" type="any">
	<cfargument name="sortby" required="no" type="any">
	<cfargument name="EquipmentMaint" default="0">
	<cfargument name="maintenanceWithEquipment" default="0">

	<cfset currentDate=now()>
    <cfif structKeyExists(arguments,"sortorder") and structKeyExists(arguments,"sortby") and len(arguments.sortby)>
        <cfquery datasource="#variables.dsn#" name="getnewAgent">
			select e.* <cfif arguments.EquipmentMaint>,emt.Description,emt.NextDate,emt.NextOdometer</cfif> from Equipments e
			<cfif arguments.EquipmentMaint>
				INNER JOIN EquipmentMaint emt on emt.EquipID = e.EquipmentID
			</cfif>
			where e.CompanyID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#session.CompanyID#">
			<cfif arguments.EquipmentMaint>
				and  e.EquipmentID in(
					select Distinct(e.EquipmentID) from Equipments e
					INNER JOIN EquipmentMaint em
					ON e.EquipmentID=em.EquipID
					<cfif not arguments.maintenanceWithEquipment>
						where e.Odometer> em.NextOdometer or em.NextDate < <cfqueryparam value="#currentDate#" cfsqltype="cf_sql_timestamp">
					</cfif>
				)
				<cfif not arguments.maintenanceWithEquipment>
					AND e.Odometer> emt.NextOdometer or emt.NextDate < <cfqueryparam value="#currentDate#" cfsqltype="cf_sql_timestamp">
				</cfif>
			</cfif>
			order by #arguments.sortby# #arguments.sortorder#;
		</cfquery>
		<cfreturn getnewAgent>
    </cfif>

	<cfquery name="qrygetcustomers" datasource="#variables.dsn#">
		select e.*<cfif arguments.EquipmentMaint>,emt.Description,emt.NextDate,emt.NextOdometer</cfif>
		from  Equipments e
		<cfif arguments.EquipmentMaint>
			INNER JOIN EquipmentMaint emt on emt.EquipID = e.EquipmentID
		</cfif>
		where e.CompanyID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#session.CompanyID#">
		<cfif arguments.EquipmentMaint>
			AND e.EquipmentID IN (
				select Distinct(e.EquipmentID)  from Equipments e
				INNER JOIN EquipmentMaint em
				ON e.EquipmentID=em.EquipID
				<cfif not arguments.maintenanceWithEquipment>
					where e.Odometer> em.NextOdometer or em.NextDate < <cfqueryparam value="#currentDate#" cfsqltype="cf_sql_timestamp">
				</cfif>
			)
			<cfif not arguments.maintenanceWithEquipment>
				AND e.Odometer> emt.NextOdometer or emt.NextDate < <cfqueryparam value="#currentDate#" cfsqltype="cf_sql_timestamp">
			</cfif>
		</cfif>
		<cfif structKeyExists(arguments,"EquipmentID") and len(arguments.EquipmentID)>
			and e.EquipmentID= <cfqueryparam value="#arguments.EquipmentID#">
		</cfif>
		ORDER BY e.EquipmentName
	</cfquery>
	<cfreturn qrygetcustomers>
</cffunction>
<cffunction name="getloadEquipments" access="public" output="false" returntype="any">
    <cfargument name="EquipmentID" required="no" type="any">
	<cfargument name="sortorder" required="no" type="any">
	<cfargument name="sortby" required="no" type="any">
		<cfquery name="qrygetcustomers" datasource="#variables.dsn#">
			select E.equipmentID,E.equipmentname,E.UnitNumber,E.temperature,E.temperaturescale,E.equipmenttype,RE.equipmentname AS RelEquip,E.TruckTrailerOption from  Equipments E
			LEFT JOIN Equipments RE on E.TruckTrailerOption = RE.EquipmentID
			where E.CompanyID = <cfqueryparam value= "#session.companyid#" cfSqltype="varchar">
			<cfif structKeyExists(arguments,"EquipmentID") and len(arguments.EquipmentID)>
				and E.EquipmentID=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.EquipmentID#">
			</cfif>
			and E.IsActive=1
			ORDER BY E.EquipmentType desc,E.EquipmentName
		</cfquery>
    <cfif structKeyExists(arguments,"sortorder") and structKeyExists(arguments,"sortby") and len(arguments.sortby)>
        <cfquery datasource="#variables.dsn#" name="getnewAgent">
		   select  equipmentID,equipmentname  from Equipments
		   where CompanyID = <cfqueryparam value= "#session.companyid#" cfSqltype="varchar">
		   order by #arguments.sortby# #arguments.sortorder#;
        </cfquery>
        <cfreturn getnewAgent>
    </cfif>
    <cfreturn qrygetcustomers>
</cffunction>
<!---Add Equipment Information---->
<cffunction name="Addequipment" access="public" output="false" returntype="any">
	<cfargument name="formStruct" type="struct" required="no" />
	
	<cfif structKeyExists(arguments.formStruct,"PEPCODE")>
		<cfset PEPcode=True>
	<cfelse>
		<cfset PEPcode=False>
	</cfif>
	<cfif structKeyExists(arguments.formStruct,"driverowned")>
        <cfset driverowned=True>
	<cfelse>
        <cfset driverowned=False>
	</cfif>
	<cfif structKeyExists(arguments.formStruct,"IFTA")>
        <cfset IFTA=True>
	<cfelse>
        <cfset IFTA=False>
	</cfif>
	<CFSTOREDPROC PROCEDURE="USP_InsertEquipment" DATASOURCE="#variables.dsn#">
		<cfprocparam cfsqltype="cf_sql_varchar" value="#session.CompanyID#">,
		<cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.EquipmentCode#">,
	    <cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.EquipmentName#">,
	    <cfprocparam cfsqltype="cf_sql_bit" value="#arguments.formStruct.Status#">,
	    <cfprocparam cfsqltype="cf_sql_varchar" value="#session.adminUserName#">,
	    <cfprocparam cfsqltype="cf_sql_varchar" value="#session.adminUserName#">,
	    <cfprocparam cfsqltype="cf_sql_date" value="#now()#">,
	    <cfprocparam cfsqltype="cf_sql_date" value="#now()#">,
	    <cfprocparam cfsqltype="cf_sql_varchar" value="#cgi.REMOTE_ADDR#">,
	    <cfprocparam cfsqltype="cf_sql_varchar" value="#cgi.HTTP_USER_AGENT#">,
	    <cfprocparam cfsqltype="cf_sql_bit" value="#PEPcode#">,
	    <cfprocparam cfsqltype="cf_sql_varchar" value="#val(arguments.formStruct.Width)#">,
	    <cfprocparam cfsqltype="cf_sql_varchar" value="#val(arguments.formStruct.Length)#">
	    <cfif structKeyExists(arguments.formStruct, "freightBroker")>
			<cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.TranscoreCode#">,
			<cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.PosteverywhereCode#">,
			<cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.ITSCode#">,
			<cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.123loadboardcode#">,
			<cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.traccarUniqueID#">,
		<cfelse>
			<cfprocparam cfsqltype="cf_sql_varchar" value="" null="true">,
			<cfprocparam cfsqltype="cf_sql_varchar" value="" null="true">,
			<cfprocparam cfsqltype="cf_sql_varchar" value="" null="true">,
			<cfprocparam cfsqltype="cf_sql_varchar" value="" null="true">,
			<cfprocparam cfsqltype="cf_sql_varchar" value="" null="true">,
	    </cfif>
        <cfif structKeyExists(arguments.formStruct, "unitNumber")>
			<cfprocparam cfsqltype="cf_sql_integer" value="#val(arguments.formStruct.Odometer)#">,
			<cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.unitNumber#">,
			<cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.vin#">,
			<cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.licensePlate#">,
			<cfif structKeyExists(arguments.formStruct, "Driver")>
           		<cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.Driver#">,
           <cfelse>
           		<cfprocparam cfsqltype="cf_sql_varchar" value="" null="true">,
           </cfif>
			<cfprocparam cfsqltype="cf_sql_bit" value="#driverowned#">,
			<cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.Notes#">,
        <cfelse>
			<cfprocparam cfsqltype="cf_sql_integer" value="" null="true">,
			<cfprocparam cfsqltype="cf_sql_varchar" value="" null="true">,
			<cfprocparam cfsqltype="cf_sql_varchar" value="" null="true">,
			<cfprocparam cfsqltype="cf_sql_varchar" value="" null="true">,
			<cfprocparam cfsqltype="cf_sql_varchar" value="" null="true">,  
			<cfprocparam cfsqltype="cf_sql_bit" value="" null="true">, 
			<cfprocparam cfsqltype="cf_sql_varchar" value="" null="true">, 
        </cfif>
		<cfif structKeyExists(arguments.formStruct, "tagexpirationdate") AND arguments.formStruct.tagexpirationdate NEQ "">
		   <cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.tagexpirationdate#">,
		<cfelse>
			<cfprocparam cfsqltype="cf_sql_varchar" value="" null="true">, 
		</cfif>
		<cfif structKeyExists(arguments.formStruct, "annualDueDate") AND arguments.formStruct.annualDueDate NEQ "">
		   <cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.annualDueDate#">,
		<cfelse>
			<cfprocparam cfsqltype="cf_sql_varchar" value="" null="true">, 
		</cfif>
		<cfif structKeyExists(arguments.formStruct, "temperature") AND arguments.formStruct.temperature NEQ "">
		   <cfprocparam cfsqltype="cf_sql_float" value="#arguments.formStruct.temperature#">,
		<cfelse>
			<cfprocparam cfsqltype="cf_sql_float" value="" null="true">, 
		</cfif>
		<cfif structKeyExists(arguments.formStruct, "temperaturescale") AND arguments.formStruct.temperaturescale NEQ "">
		   	<cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.temperaturescale#">,
		<cfelse>
			<cfprocparam cfsqltype="cf_sql_varchar" value="" null="true">, 
		</cfif>
		<cfprocparam cfsqltype="cf_sql_bit" value="#IFTA#">

		<cfif structKeyExists(arguments.formStruct, "IMEI") AND Len(Trim(arguments.formStruct.IMEI))>
			,<cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.IMEI#">
		<cfelse>
			,<cfprocparam cfsqltype="cf_sql_varchar" value="" null="true">
		</cfif>
		<cfif structKeyExists(arguments.formStruct, "DirectFreightCode") AND Len(Trim(arguments.formStruct.DirectFreightCode))>
			,<cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.DirectFreightCode#">
		<cfelse>
			,<cfprocparam cfsqltype="cf_sql_varchar" value="" null="true">
		</cfif>
		<cfif structKeyExists(arguments.formStruct, "EquipmentType") AND Len(Trim(arguments.formStruct.EquipmentType))>
			,<cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.EquipmentType#">
		<cfelse>
			,<cfprocparam cfsqltype="cf_sql_varchar" value="" null="true">
		</cfif>
		<cfif structKeyExists(arguments.formStruct, "TruckTrailerOption") AND Len(Trim(arguments.formStruct.TruckTrailerOption))>
			,<cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.TruckTrailerOption#">
		<cfelse>
			,<cfprocparam cfsqltype="cf_sql_varchar" value="" null="true">
		</cfif>
		<cfif structKeyExists(arguments.formStruct, "ShowCarrierOnboarding")>
			,<cfprocparam cfsqltype="cf_sql_bit" value="1">
		<cfelse>
			,<cfprocparam cfsqltype="cf_sql_bit" value="0">
		</cfif>
		<cfprocresult name="LastInsertedEquipment">
	</CFSTOREDPROC>
    <!--- If there are any files attached to this load then move from temp table to the main table --->
    <cfif structKeyExists(arguments.formStruct,"tempEquipmentId")>
	   <cfinvoke method="linkAttachments" tempEquipmentId="#arguments.formStruct.tempEquipmentId#" permEquipmentId="#LastInsertedEquipment.LastInsertedEquipmentID#">
    </cfif>

    <cfif structKeyExists(arguments.formStruct, "TruckTrailerOption")>
	    <cfquery name="qUpd" datasource="#variables.dsn#">
			UPDATE Equipments SET TruckTrailerOption = <cfqueryparam cfsqltype="cf_sql_varchar" value="#LastInsertedEquipment.LastInsertedEquipmentID#"> WHERE EquipmentID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.TruckTrailerOption#" null="#not len(arguments.formStruct.TruckTrailerOption)#">
		</cfquery>
	</cfif>

    <cfreturn "Equipment has been added Successfully">
</cffunction>

<!--- Link attachments --->
<cffunction name="linkAttachments">
	<cfargument name="tempEquipmentId" type="string" required="yes" />
	<cfargument name="permEquipmentId" type="string" required="yes" />
	<cfquery name="retriveFromTemp" datasource="#application.dsn#">
		select * from fileattachmentstemp where linked_id =<cfqueryparam cfsqltype="cf_sql_varchar" value="#tempEquipmentId#">
	</cfquery>
	<cfset flagFile = 0>
	<cfif retriveFromTemp.recordcount neq 0>
		<cfloop query="retriveFromTemp">
			<cfquery name="insertFilesUploaded" datasource="#application.dsn#">
				insert into FileAttachments(linked_Id,linked_to,attachedFileLabel,attachmentFileName,uploadedBy)
				values(
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#permEquipmentId#">,
					<cfqueryparam cfsqltype="cf_sql_integer" value="#retriveFromTemp.linked_to#">,
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#retriveFromTemp.attachedFileLabel#">,
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#retriveFromTemp.attachmentFileName#">,
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#retriveFromTemp.uploadedBy#">)
			</cfquery>
		</cfloop>
		<cfset flagFile =1>
	</cfif>
	
	<cfif flagFile eq 1>
		<cfquery name="deleteTempFiles" datasource="#application.dsn#">
			delete from fileattachmentstemp where linked_id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#tempEquipmentId#">
		</cfquery>
	</cfif>
</cffunction>


<!---Update Equipment --->
<cffunction name="Updateequipment" access="public" output="false" returntype="any">
	<cfargument name="formStruct" type="struct">
	<cfargument name="editid" type="any">		

	<cfif structKeyExists(arguments.formStruct,"PEPCODE")>
		<cfset PEPcode=True>
	<cfelse>
		<cfset PEPcode=False>
	</cfif>
	<cfif structKeyExists(arguments.formStruct,"driverowned")>
		<cfset driverowned=True>
	<cfelse>
		<cfset driverowned=False>
	</cfif>
	<cfif structKeyExists(arguments.formStruct,"IFTA")>
		<cfset IFTA=True>
	<cfelse>
		<cfset IFTA=False>
	</cfif>
	<cfif structKeyExists(arguments.formStruct, "TruckTrailerOption")>
		<cfquery name="qUpd" datasource="#variables.dsn#">
			UPDATE Equipments SET TruckTrailerOption = NULL WHERE TruckTrailerOption = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.editid#">
		</cfquery>
	</cfif>
	<cfif structKeyExists(arguments.formStruct, "Driver")>
		<cfquery name="qUpd" datasource="#variables.dsn#">
			UPDATE Equipments SET Driver = NULL WHERE Driver = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.Driver#"> AND CompanyID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#session.CompanyID#">
		</cfquery>
	</cfif>
	<cfquery name="qUpd" datasource="#variables.dsn#">
		UPDATE Carriers SET EquipmentId = NULL WHERE EquipmentId = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.editid#">
	</cfquery>
	<CFSTOREDPROC PROCEDURE="USP_UpdateEquipment" DATASOURCE="#variables.dsn#">
		<cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.editid#">,
		<cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.EquipmentCode#">,
		<cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.EquipmentName#">,
		<cfprocparam cfsqltype="cf_sql_bit" value="#arguments.formStruct.Status#">,
		<cfprocparam cfsqltype="cf_sql_varchar" value="#session.adminUserName#">,
	    <cfprocparam cfsqltype="cf_sql_date" value="#now()#">,
		<cfprocparam cfsqltype="cf_sql_varchar" value="#cgi.REMOTE_ADDR#">,
		<cfprocparam cfsqltype="cf_sql_bit" value="#PEPcode#">,
		<cfprocparam cfsqltype="cf_sql_varchar" value="#val(arguments.formStruct.Width)#">
		<cfprocparam cfsqltype="cf_sql_varchar" value="#val(arguments.formStruct.Length)#">,
		

		<cfif structKeyExists(arguments.formStruct, "freightBroker")>
			<cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.TranscoreCode#">,
			<cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.PosteverywhereCode#">,
			<cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.ITSCode#">,
			<cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.123loadboardcode#">,
			<cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.traccarUniqueID#">,
		<cfelse>
			<cfprocparam cfsqltype="cf_sql_varchar" value="" null="true">,
			<cfprocparam cfsqltype="cf_sql_varchar" value="" null="true">,
			<cfprocparam cfsqltype="cf_sql_varchar" value="" null="true">,
			<cfprocparam cfsqltype="cf_sql_varchar" value="" null="true">,
			<cfprocparam cfsqltype="cf_sql_varchar" value="" null="true">,
	    </cfif>

	    <cfif structKeyExists(arguments.formStruct, "unitNumber")>
			<cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.unitNumber#">,
		<cfelse>
			<cfprocparam cfsqltype="cf_sql_varchar" value="" null="true">,
		</cfif>

		<cfif structKeyExists(arguments.formStruct, "vin")>
			<cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.vin#">,
		<cfelse>
			<cfprocparam cfsqltype="cf_sql_varchar" value="" null="true">,
		</cfif>

		<cfif structKeyExists(arguments.formStruct, "licensePlate")>
			<cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.licensePlate#">,
		<cfelse>
			<cfprocparam cfsqltype="cf_sql_varchar" value="" null="true">,
		</cfif>

		<cfif structKeyExists(arguments.formStruct, "Odometer")>
			<cfprocparam cfsqltype="cf_sql_integer" value="#val(arguments.formStruct.Odometer)#">,
		<cfelse>
			<cfprocparam cfsqltype="cf_sql_integer" value="" null="true">,
		</cfif>

		<cfif structKeyExists(arguments.formStruct, "tagexpirationdate") AND len(trim(arguments.formStruct.tagexpirationdate))>
			<cfprocparam cfsqltype="cf_sql_date" value="#arguments.formStruct.tagexpirationdate#">,
		<cfelse>
			<cfprocparam cfsqltype="cf_sql_date" value="" null="true">,
		</cfif>

		<cfif structKeyExists(arguments.formStruct, "annualDueDate") AND len(trim(arguments.formStruct.annualDueDate))>
			<cfprocparam cfsqltype="cf_sql_date" value="#arguments.formStruct.annualDueDate#">,
		<cfelse>
			<cfprocparam cfsqltype="cf_sql_date" value="" null="true">,
		</cfif>

		<cfif structKeyExists(arguments.formStruct, "Driver")>
			<cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.Driver#">,
			<cfif isDefined("driverowned")>
				<cfprocparam cfsqltype="cf_sql_bit" value="#driverowned#">,
			<cfelse>
				<cfprocparam cfsqltype="cf_sql_bit" value="" null="true">,
			</cfif>
		<cfelse>
			<cfprocparam cfsqltype="cf_sql_varchar" value="" null="true">,
			<cfprocparam cfsqltype="cf_sql_bit" value="" null="true">,
		</cfif>

		<cfif structKeyExists(arguments.formStruct, "Notes")>
			<cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.Notes#">,
		<cfelse>
			<cfprocparam cfsqltype="cf_sql_varchar" value="" null="true">,
		</cfif>
		<cfif structKeyExists(arguments.formStruct, "temperature") AND arguments.formStruct.temperature NEQ "">
			<cfprocparam cfsqltype="cf_sql_float" value="#arguments.formStruct.temperature#">,
		<cfelse>
			<cfprocparam cfsqltype="cf_sql_float" value="" null="true">, 
		</cfif>
		<cfif structKeyExists(arguments.formStruct, "temperaturescale") AND arguments.formStruct.temperaturescale NEQ "">
			<cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.temperaturescale#">,
		<cfelse>
			<cfprocparam cfsqltype="cf_sql_varchar" value="" null="true">, 
		</cfif>
		<cfprocparam cfsqltype="cf_sql_bit" value="#IFTA#">,
		<cfif structKeyExists(arguments.formStruct, "IMEI") AND Len(Trim(arguments.formStruct.IMEI))>
			<cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.IMEI#">
		<cfelse>
			<cfprocparam cfsqltype="cf_sql_varchar" value="" null="true">
		</cfif>
		<cfif structKeyExists(arguments.formStruct, "DirectFreightCode") AND Len(Trim(arguments.formStruct.DirectFreightCode))>
			,<cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.DirectFreightCode#">
		<cfelse>
			,<cfprocparam cfsqltype="cf_sql_varchar" value="" null="true">
		</cfif>
		<cfif structKeyExists(arguments.formStruct, "EquipmentType") AND Len(Trim(arguments.formStruct.EquipmentType))>
			,<cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.EquipmentType#">
		<cfelse>
			,<cfprocparam cfsqltype="cf_sql_varchar" value="" null="true">
		</cfif>
		<cfif structKeyExists(arguments.formStruct, "TruckTrailerOption") AND Len(Trim(arguments.formStruct.TruckTrailerOption))>
			,<cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.TruckTrailerOption#">
		<cfelse>
			,<cfprocparam cfsqltype="cf_sql_varchar" value="" null="true">
		</cfif>
		<cfif structKeyExists(arguments.formStruct, "ShowCarrierOnboarding")>
			,<cfprocparam cfsqltype="cf_sql_bit" value="1">
		<cfelse>
			,<cfprocparam cfsqltype="cf_sql_bit" value="0">
		</cfif>
	</CFSTOREDPROC>
	<cfif structKeyExists(arguments.formStruct, "TruckTrailerOption")>
		<cfquery name="qUpd" datasource="#variables.dsn#">
			UPDATE Equipments SET TruckTrailerOption = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.EditID#"> WHERE EquipmentID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.TruckTrailerOption#" null="#not len(arguments.formStruct.TruckTrailerOption)#">
		</cfquery>
	</cfif>
	<cfif structKeyExists(arguments.formStruct, "Driver")>
		<cfquery name="qUpd" datasource="#variables.dsn#">
			UPDATE Carriers SET EquipmentId = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.EditID#"> WHERE CarrierName = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.Driver#" null="#not len(arguments.formStruct.Driver)#">
		</cfquery>
	</cfif>
	<cfreturn "Equipment has been updated Successfully">
</cffunction>
	<!--- Delete Equipment---->
	<cffunction name="deleteEquipments"  access="public" output="false" returntype="any">
		<cfargument name="EquipmentID" type="any" required="yes">
			<cftry>
			<!---delete fileattachment table entry and associated files in equipments--->
			<cfquery name="qryGetfileAttachmentsEquipments" datasource="#variables.dsn#">
				select attachmentFileName,linked_Id from FileAttachments
				where  linked_Id=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.EquipmentID#">
					and linked_to=57
			</cfquery>
			<cfif qryGetfileAttachmentsEquipments.recordcount>
				<cfloop query="qryGetfileAttachmentsEquipments">
					<cfset variables.equipments = expandPath('../fileupload/img/#qryGetfileAttachmentsEquipments.attachmentFileName#')>
					<cfquery name="deleteItems" datasource="#variables.dsn#">
						delete from FileAttachments where linked_Id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#qryGetfileAttachmentsEquipments.linked_Id#">
					</cfquery>
					<cfif fileexists(variables.equipments)>
						<cffile action = "delete"  file = "#variables.equipments#">
					</cfif>
				</cfloop>
			</cfif>
			<!---delete fileattachment table entry and associated files in equipmentMaintenance--->
			<cfquery name="qryGetEquipMainT" datasource="#variables.dsn#">
				select EquipMainID from EquipmentMaint
				where  EquipID=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.EquipmentID#">
			</cfquery>
			<cfif qryGetEquipMainT.recordcount>
				<cfloop query="qryGetEquipMainT">
					<cfquery name="qryGetfileAttachmentsMaintenance" datasource="#variables.dsn#">
						select attachmentFileName,linked_Id from FileAttachments
						where  linked_Id=<cfqueryparam cfsqltype="cf_sql_varchar" value="#qryGetEquipMainT.EquipMainID#">
							and linked_to=58
					</cfquery>
					<cfif qryGetfileAttachmentsMaintenance.recordcount>
						<cfloop query="qryGetfileAttachmentsMaintenance" >
							<cfset variables.maintenance = expandPath('../fileupload/img/#qryGetfileAttachmentsMaintenance.attachmentFileName#')>
							<cfquery name="deleteItems" datasource="#variables.dsn#">
								delete from FileAttachments where linked_Id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#qryGetfileAttachmentsMaintenance.linked_Id#">
							</cfquery>
							<!---cfdirectory action="list" name="qlist" directory="#variables.maintenanceTrans#"--->
							<cfif fileexists(variables.maintenance)>
								<cffile action = "delete"  file = "#variables.maintenance#">
							</cfif>
						</cfloop>
					</cfif>
				</cfloop>
			</cfif>
			<!---delete fileattachment table entry and associated files in equipmentMaintenanceTransaction--->
			<cfquery name="qryGetEquipMainTransaction" datasource="#variables.dsn#">
				select EquipMainID from EquipmentMaintTrans
				where  EquipID=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.EquipmentID#">
			</cfquery>
			<cfif qryGetEquipMainTransaction.recordcount>
				<cfloop query="qryGetEquipMainTransaction">
					<cfquery name="qryGetfileAttachmentsTrans" datasource="#variables.dsn#">
						select attachmentFileName,linked_Id from FileAttachments
						where  linked_Id=<cfqueryparam cfsqltype="cf_sql_varchar" value="#qryGetEquipMainTransaction.EquipMainID#">
							and linked_to=59
					</cfquery>
					<cfif qryGetfileAttachmentsTrans.recordcount>
						<cfloop query="qryGetfileAttachmentsTrans">
							<cfset variables.maintenanceTrans = expandPath('../fileupload/img/#qryGetfileAttachmentsTrans.attachmentFileName#')>
							<cfquery name="deleteItems" datasource="#variables.dsn#">
								delete from FileAttachments where linked_Id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#qryGetfileAttachmentsTrans.linked_Id#">
							</cfquery>
							<cfif fileexists(variables.maintenanceTrans)>
								<cffile action = "delete"  file = "#variables.maintenanceTrans#">
							</cfif>
						</cfloop>
					</cfif>
				</cfloop>
			</cfif>
			<cfquery name="qryDeleteEquipmentMaintTrans" datasource="#variables.dsn#">
    			 delete from EquipmentMaintTrans where  EquipID=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.EquipmentID#">
    		</cfquery>
			<cfquery name="qryDelete" datasource="#variables.dsn#">
    			 delete from EquipmentMaint where  EquipID=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.EquipmentID#">
    		</cfquery>
    		<cfquery name="qryDelete" datasource="#variables.dsn#">
    			 delete from Equipments where  EquipmentID=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.EquipmentID#">
    		</cfquery>
    		<cfreturn "Equipments has been deleted successfully.">
    		<cfcatch type="any">
    			<cfreturn "Delete operation has been not successfull.">
    		</cfcatch>
    	</cftry>
	</cffunction>

	<!--- Delete Equipmentmaint---->
	<cffunction name="deleteEquipmentsMaint"  access="public" output="false" returntype="any">
		<cfargument name="equipmentID" type="any" required="yes">
		<cfargument name="equipmentMaintID" type="any" required="yes">
			<cfquery name="qryGetfileAttachments" datasource="#variables.dsn#">
				select attachmentFileName,linked_Id from FileAttachments
				where  linked_Id=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.equipmentMaintID#">
					and linked_to=58
			</cfquery>
			<cfif qryGetfileAttachments.recordcount>
				<cfloop query="qryGetfileAttachments">
					<cfset variables.maintenanceT = expandPath('../fileupload/img/#qryGetfileAttachments.attachmentFileName#')>
					<cfquery name="deleteItems" datasource="#variables.dsn#">
						delete from FileAttachments where linked_Id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#qryGetfileAttachments.linked_Id#">
					</cfquery>
					<cfif fileexists(variables.maintenanceT)>
						<cffile action = "delete"  file = "#variables.maintenanceT#">
					</cfif>
				</cfloop>
			</cfif>
			<cfquery name="qryGetEquipMainTransaction" datasource="#variables.dsn#">
				select EquipMainID from EquipmentMaintTrans
				where  EquipMaintID=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.equipmentMaintID#">
					and EquipID=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.equipmentID#">
			</cfquery>
			<cfif qryGetEquipMainTransaction.recordcount>
				<cfloop query="qryGetEquipMainTransaction">
					<cfquery name="qryGetfileAttachmentsTrans" datasource="#variables.dsn#">
						select attachmentFileName,linked_Id from FileAttachments
						where  linked_Id=<cfqueryparam cfsqltype="cf_sql_varchar" value="#qryGetEquipMainTransaction.EquipMainID#">
							and linked_to=59
					</cfquery>
					<cfif qryGetfileAttachmentsTrans.recordcount>
						<cfloop query="qryGetfileAttachmentsTrans">
							<cfset variables.maintenanceTrans = expandPath('../fileupload/img/#qryGetfileAttachmentsTrans.attachmentFileName#')>
							<cfquery name="deleteItems" datasource="#variables.dsn#">
								delete from FileAttachments where linked_Id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#qryGetfileAttachmentsTrans.linked_Id#">
							</cfquery>
							<cfif fileexists(variables.maintenanceTrans)>
								<cffile action = "delete"  file = "#variables.maintenanceTrans#">
							</cfif>
						</cfloop>
					</cfif>
				</cfloop>
			</cfif>
			<cftry>
				<cfquery name="qryDeleteEquipmentMaintTrans" datasource="#variables.dsn#">
					 delete from EquipmentMaintTrans where  EquipMaintID=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.EquipmentMaintID#">
					 and EquipID=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.equipmentID#">
				</cfquery>
				<cfquery name="qryDelete" datasource="#variables.dsn#">
					 delete from EquipmentMaint where  EquipMainID=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.EquipmentMaintID#">
					 and EquipID=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.equipmentID#">
				</cfquery>
				<cfreturn "Equipment Maintenance has been deleted successfully.">
    		<cfcatch type="any">

    			<cfreturn "Maintenance Delete operation has been not successfull.">
    		</cfcatch>
    	</cftry>
	</cffunction>

	<!--- Delete EquipmentmainTransaction---->
	<cffunction name="deleteEquipmentsMainTransaction"  access="remote" output="false" returntype="numeric">
		<cfargument name="equipMainID" type="any" required="yes">
		<cfargument name="dsName" required="true">
		<cfargument name="equipMaintId" required="true">
		<cfargument name="equipmentId" required="true">
		<cfset TheKey = "NAMASKARAM">
		<cfset variables.decrypted = Decrypt(ToString(ToBinary(arguments.dsName)), TheKey)>
		<cfquery name="qryGetfileAttachments" datasource="#variables.decrypted#">
			select attachmentFileName,linked_Id from FileAttachments
			where  linked_Id=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.equipMainID#">
				and linked_to=59
		</cfquery>
		<cfif qryGetfileAttachments.recordcount>
			<cfloop query="qryGetfileAttachments">
				<cfset variables.maintenanceTrans = expandPath('../fileupload/img/#qryGetfileAttachments.attachmentFileName#')>
				<cfquery name="deleteItems" datasource="#variables.decrypted#">
					delete from FileAttachments where linked_Id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#qryGetfileAttachments.linked_Id#">
				</cfquery>
				<cfif fileexists(variables.maintenanceTrans)>
					<cffile action = "delete"  file = "#variables.maintenanceTrans#">
				</cfif>
			</cfloop>
		</cfif>
		<cfquery name="qryDeleteEquipmentMaintTrans" datasource="#variables.decrypted#">
			delete from EquipmentMaintTrans where  EquipMainID=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.equipMainID#">
		</cfquery>
		<cfreturn 1>
    </cffunction>
    <cffunction name="getSearchedEquipment" access="public" output="false" returntype="query">
		<cfargument name="searchText" required="yes" type="any">
		<cfargument name="EquipmentMaint" default="0">
		<cfargument name="maintenanceWithEquipment" default="0">
		<CFSTOREDPROC PROCEDURE="searchEquipment" DATASOURCE="#variables.dsn#">
			<cfif isdefined('arguments.searchText') and len(arguments.searchText)>
				<CFPROCPARAM VALUE="#arguments.searchText#" cfsqltype="CF_SQL_VARCHAR">
			 <cfelse>
				<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR">
			 </cfif>
			 <CFPROCPARAM VALUE="#arguments.EquipmentMaint#" cfsqltype="cf_sql_bit">
			 <CFPROCPARAM VALUE="#arguments.maintenanceWithEquipment#" cfsqltype="cf_sql_bit">
			 <CFPROCPARAM VALUE="#session.CompanyID#" cfsqltype="CF_SQL_VARCHAR">
			 <CFPROCRESULT NAME="QreturnSearch">
		</CFSTOREDPROC>
		<cfreturn QreturnSearch>
	</cffunction>
	<!---Add Equipment Information---->
	<cffunction name="AddMaintenanceInformation" access="public" output="false" returntype="any">
	   <cfargument name="formStruct" type="struct" required="no" />
		<cfquery name="insertquery" datasource="#variables.dsn#">
		   insert into EquipmentMaintSetup(Description,MilesInterval,DateInterval,Notes,createdDate,CompanyID)
		   values(
				  <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.Description#">,
				  <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.formStruct.MilesInterval#"  null="#yesNoFormat(NOT len(arguments.formStruct.MilesInterval))#">,
				  <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.formStruct.DateInterval#" null="#yesNoFormat(NOT len(arguments.formStruct.DateInterval))#">,
				  <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.Notes#">,
				  <cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">,
				  <cfqueryparam cfsqltype="cf_sql_varchar" value="#session.CompanyID#">
				  )
	   </cfquery>
	   <cfreturn "Maintenance has been added Successfully">
	</cffunction>

	<cffunction name="getDescriptionDuplicate" access="remote" output="false" returntype="any" returnFormat="plain">
		<cfargument name="dsName" required="true">
		<cfargument name="description" required="true">
		<cfargument name="editid" required="true">
		<cfargument name="CompanyID" required="true">
		<cfset TheKey = "NAMASKARAM">
		<cfset variables.decrypted = Decrypt(ToString(ToBinary(arguments.dsName)), TheKey)>
		<cfquery name="qryDescriptioncheck" datasource="#variables.decrypted#">
			select Description from EquipmentMaintSetup
			where
				Description = <cfqueryparam value="#arguments.description#" cfsqltype="cf_sql_varchar">
				<cfif arguments.editid NEQ "">
					AND id <> <cfqueryparam value="#arguments.editid#" cfsqltype="cf_sql_varchar">
				</cfif>
				AND CompanyID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.CompanyID#">
		</cfquery>
		<cfif qryDescriptioncheck.recordcount>
			<cfreturn 0>
		</cfif>
		<cfreturn 1>
	</cffunction>
	<!---Update Equipment --->
	<cffunction name="UpdateMaintenanceInformation" access="public" output="false" returntype="any">
		<cfargument name="formStruct" type="struct">
		 <cfargument name="editid" type="any">
		<cfquery name="qryupdate" datasource="#variables.dsn#">
			 UPDATE EquipmentMaintSetup
			SET Description = <cfqueryparam value="#arguments.formStruct.Description#" cfsqltype="cf_sql_varchar">,
			MilesInterval = <cfqueryparam value="#arguments.formStruct.MilesInterval#" cfsqltype="cf_sql_integer" null="#yesNoFormat(NOT len(arguments.formStruct.MilesInterval))#">,
			DateInterval = <cfqueryparam value="#arguments.formStruct.DateInterval#" cfsqltype="cf_sql_integer" null="#yesNoFormat(NOT len(arguments.formStruct.DateInterval))#">,
			Notes = <cfqueryparam value="#arguments.formStruct.Notes#" cfsqltype="cf_sql_varchar">,
			ModifiedDate = <cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">
			where id=<cfqueryparam value="#arguments.formStruct.editid#" cfsqltype="cf_sql_integer">
		 </cfquery>
		 <cfreturn "Maintenance has been updated Successfully">
	</cffunction>

	<cffunction name="getMaintenanceInformation" access="public" output="false" returntype="any">
		<cfargument name="EquipmentMaintSetupId" required="no" type="any">
		<cfargument name="sortorder" required="no" type="any">
		<cfargument name="sortby" required="no" type="any">
			<cfquery name="qryGetMaintenance" datasource="#variables.dsn#">
				 select * from  EquipmentMaintSetup
				 where companyid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#session.CompanyID#">
				 <cfif structKeyExists(arguments,"EquipmentMaintSetupId") and len(arguments.EquipmentMaintSetupId)>
					and id=<cfqueryparam value="#arguments.EquipmentMaintSetupId#" cfsqltype="cf_sql_integer">
				</cfif>
				ORDER BY Description
			</cfquery>

			<cfif structKeyExists(arguments,"sortorder") and structKeyExists(arguments,"sortby") and len(arguments.sortby)>
				<cfquery datasource="#variables.dsn#" name="qryGetMaintenanceSorted">
					select *  from EquipmentMaintSetup
					where CompanyID  = <cfqueryparam cfsqltype="cf_sql_varchar" value="#session.CompanyID#">
					order by #arguments.sortby# #arguments.sortorder#;
				</cfquery>
				<cfreturn qryGetMaintenanceSorted>
			</cfif>
			<cfreturn qryGetMaintenance>
	</cffunction>

	<cffunction name="getMaintenanceInformationForSelect" access="public" output="false" returntype="any">
		<cfargument name="EquipmentID" required="yes" type="any">
		<cfquery name="qryGetMaintenance" datasource="#variables.dsn#">
			select Description from  EquipmentMaintSetup
			 where Description not in(
			 select Description from EquipmentMaint
			 where EquipID=<cfqueryparam value="#arguments.EquipmentID#" cfsqltype="cf_sql_varchar">
			 )
			 and CompanyID = <cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar">
			ORDER BY Description
		</cfquery>
		<cfreturn qryGetMaintenance>
	</cffunction>

	<cffunction name="getMaintenanceInformationAjax" access="remote" output="false" returntype="any" returnFormat="JSON">
		<cfargument name="EquipmentMaintSetupId" required="yes" >
		<cfargument name="dsName" required="true">
		<cfargument name="CompanyID" required="true">
		<cfset TheKey = "NAMASKARAM">
		<cfset variables.decrypted = Decrypt(ToString(ToBinary(arguments.dsName)), TheKey)>
		<cfset qryGetMaintenance="1">
		<cfif structKeyExists(arguments,"EquipmentMaintSetupId") and len(arguments.EquipmentMaintSetupId)>
			<cfquery name="qryGetMaintenance" datasource="#variables.decrypted#">
			 select * from  EquipmentMaintSetup
			 where  Description=<cfqueryparam value="#arguments.EquipmentMaintSetupId#" cfsqltype="cf_sql_varchar">
			 and CompanyID = <cfqueryparam value="#arguments.CompanyID#" cfsqltype="cf_sql_varchar">
			ORDER BY Description
			</cfquery>
		</cfif>
		 <cfreturn serializejson(qryGetMaintenance)>
	</cffunction>
	<!---get Maintenance Details --->
	<cffunction name="getEquipmentMaintTable" access="remote" returntype="query">
		<cfargument name="editid" required="no">
		<cfargument name="sortorder" required="no" type="any">
		<cfargument name="sortby" required="no" type="any">
		<cfargument name="equipmentmaintid" required="no" type="any">
		<cfif structkeyexists(arguments,"sortorder") and structkeyexists(arguments,"sortby") and len(arguments.sortby)>
			<cfquery name="qrySort" datasource="#variables.dsn#">
				SELECT * FROM EquipmentMaint
				where EquipID IN (SELECT EquipmentID FROM Equipments WHERE CompanyID = <cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar">)
				<cfif structkeyexists(arguments,"editid")>
					<cfif len(arguments.editid)>
						and  EquipID=<cfqueryparam value="#arguments.editid#" cfsqltype="cf_sql_varchar">
					</cfif>
				</cfif>
				<cfif structkeyexists(arguments,"equipmentmaintid")>
					<cfif len(arguments.equipmentmaintid)>
						and  EquipMainID=<cfqueryparam value="#arguments.equipmentmaintid#" cfsqltype="cf_sql_varchar">
					</cfif>
				</cfif>
				order by #arguments.sortby# #arguments.sortorder#
			</cfquery>
			<cfreturn qrySort>
		</cfif>
		<cfquery name="qry" datasource="#variables.dsn#">
			SELECT * FROM EquipmentMaint
			where EquipID IN (SELECT EquipmentID FROM Equipments WHERE CompanyID = <cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar">)
			<cfif structkeyexists(arguments,"editid")>
				<cfif len(arguments.editid)>
					and EquipID=<cfqueryparam value="#arguments.editid#" cfsqltype="cf_sql_varchar">
				</cfif>
			</cfif>
			<cfif structkeyexists(arguments,"equipmentmaintid")>
				<cfif len(arguments.equipmentmaintid)>
					and  EquipMainID=<cfqueryparam value="#arguments.equipmentmaintid#" cfsqltype="cf_sql_varchar">
				</cfif>
			</cfif>
			order by NextDate asc
		</cfquery>
		<cfreturn qry>
	</cffunction>

	<!---get Maintenance Transaction Details --->
	<cffunction name="getEquipmentMainTransaction" access="remote" returntype="query">
		<cfargument name="editid" required="no">
		<cfargument name="sortorder" required="no" type="any">
		<cfargument name="sortby" required="no" type="any">
		<cfargument name="equipmentMaint" required="no" type="any">
		<cfif structkeyexists(arguments,"sortorder") and structkeyexists(arguments,"sortby") and len(arguments.sortby)>
			<cfquery name="qrySort" datasource="#variables.dsn#">
				SELECT * FROM EquipmentMaintTrans
				where EquipID IN (SELECT EquipmentID FROM Equipments WHERE CompanyID = <cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar">)
				<cfif structkeyexists(arguments,"editid")>
					<cfif len(arguments.editid)>
						and  EquipID=<cfqueryparam value="#arguments.editid#" cfsqltype="cf_sql_varchar">
					</cfif>
				</cfif>
				<cfif structkeyexists(arguments,"equipmentMaint")>
					<cfif len(arguments.equipmentMaint)>
						and  EquipMaintID=<cfqueryparam value="#arguments.equipmentMaint#" cfsqltype="cf_sql_varchar">
					</cfif>
				</cfif>
				order by #arguments.sortby# #arguments.sortorder#
			</cfquery>
			<cfreturn qrySort>
		</cfif>
		<cfquery name="qry" datasource="#variables.dsn#">
			SELECT * FROM EquipmentMaintTrans
			where EquipID IN (SELECT EquipmentID FROM Equipments WHERE CompanyID = <cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar">)
			<cfif structkeyexists(arguments,"editid")>
				<cfif len(arguments.editid)>
					and EquipID=<cfqueryparam value="#arguments.editid#" cfsqltype="cf_sql_varchar">
				</cfif>
			</cfif>
			<cfif structkeyexists(arguments,"equipmentMaint")>
				<cfif len(arguments.equipmentMaint)>
					and  EquipMaintID=<cfqueryparam value="#arguments.equipmentMaint#" cfsqltype="cf_sql_varchar">
				</cfif>
			</cfif>
			order by Date
		</cfquery>
		<cfreturn qry>
	</cffunction>


	<!---Add EquipmentMaintenance table Information---->
	<cffunction name="insertEquipMaintInformation" access="public" output="false" returntype="any">
	   <cfargument name="formStruct" type="struct" required="yes" />
	   <cfargument name="isCarrier" type="any" required="no" />
		<cfif structkeyexists(arguments.formStruct,"equipmentId")>
			<cfif structkeyexists(arguments.formStruct,"MilesInterval") and structkeyexists(arguments.formStruct,"Odometer")>
				<cfset var nextOdometer=val(arguments.formStruct.MilesInterval)+val(arguments.formStruct.Odometer)>
			</cfif>
			<cfset variables.currentday=now()>
			<cfset variables.nextdate="">
			<cfif structkeyexists(arguments.formStruct,"nextDate")>
				<cfif len(trim(arguments.formStruct.nextDate))>
					<cfset variables.nextdate=arguments.formStruct.nextDate>
				<cfelse>
					<cfif structkeyexists(arguments.formStruct,"DateInterval")>
						<cfif arguments.formStruct.DateInterval neq 0>
							<cfset variables.nextdate=DateAdd("m",arguments.formStruct.DateInterval,variables.currentday)>
						</cfif>
					</cfif>
				</cfif>
			</cfif>
			<cfquery name="generateEquipMainID" datasource="#variables.dsn#">
				SELECT NewID() AS ID 
			</cfquery>

			<cfquery name="insertQueryEquipmentMaint" datasource="#variables.dsn#">
			   insert into EquipmentMaint(EquipMainID,EquipID,MilesInterval,DateInterval,NextOdometer,Notes,NextDate,Description,CreatedDate)
			   values(
					  <cfqueryparam cfsqltype="cf_sql_varchar" value="#generateEquipMainID.ID#">,
					  <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.equipmentId#">,
					  <cfqueryparam cfsqltype="cf_sql_integer" value="#val(arguments.formStruct.MilesInterval)#">,
					  <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.formStruct.DateInterval#">,
					  <cfqueryparam cfsqltype="cf_sql_integer" value="#val(nextOdometer)#">,
					  <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.Notes#">,
					  <cfqueryparam cfsqltype="cf_sql_timestamp" value="#variables.nextdate#"  null="#yesNoFormat(NOT len(variables.nextdate))#">,
					  <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.Description#">,
					  <cfqueryparam cfsqltype="cf_sql_timestamp" value="#variables.currentday#">
					  );
		   </cfquery>
			 <!--- If there are any files attached to this load then move from temp table to the main table --->
		   <cfif structKeyExists(arguments.formStruct,"tempEquipmentMaint")>
			   <cfinvoke method="linkAttachments" tempEquipmentId="#arguments.formStruct.tempEquipmentMaint#" permEquipmentId="#generateEquipMainID.ID#">
		   </cfif>
		   <cflocation url="index.cfm?event=addDriverEquipment&equipmentid=#arguments.formStruct.equipmentId#&#session.URLToken#&IsCarrier=#arguments.isCarrier#" addtoken="false">
	   </cfif>
	</cffunction>

	<!---Add EquipmentMaintenanceTranscation table Information---->
	<cffunction name="insertEquipMaintTransInformation" access="public" output="false" returntype="any">
	   <cfargument name="formStruct" type="struct" required="yes" />
	   <cfargument name="IsCarrier" type="any" required="no" />
		<cfif structkeyexists(arguments.formStruct,"equipmentIdForMainTrans")>
			<cfquery name="getEquipmentMaintdetails" datasource="#variables.dsn#">
				select MilesInterval,DateInterval from EquipmentMaint
				where EquipMainID=<cfqueryparam value="#arguments.formStruct.equipmentMainT#" cfsqltype="cf_sql_varchar">
		   </cfquery>
		   <cfquery name="EquipID" datasource="#variables.dsn#">
				SELECT NewID() AS NewEquipID
		   </cfquery>
			<cfquery name="insertqueryEquipMainTrans" datasource="#variables.dsn#">
				declare @equipMainID uniqueidentifier
				set @equipMainID = '#EquipID.NewEquipID#'
			   insert into EquipmentMaintTrans(EquipMainID,EquipID,EquipMaintID,
			   <cfif structkeyexists(arguments.formStruct,"Odometer") >
					<cfif len(trim(arguments.formStruct.Odometer))>
						Odometer,
						<cfset var nextOdometer = val(arguments.formStruct.Odometer)+val(getEquipmentMaintdetails.MilesInterval)>
					</cfif>
			   </cfif>
			   <cfif structkeyexists(arguments.formStruct,"Date")>
					<cfif len(trim(arguments.formStruct.Date))>
						Date,
						<cfset variables.nextdate=DateAdd("m",getEquipmentMaintdetails.DateInterval,arguments.formStruct.Date)>
					</cfif>
				</cfif>
			   <cfif structkeyexists(arguments.formStruct,"Notes")>
					<cfif len(trim(arguments.formStruct.Notes))>
						Notes,
					</cfif>
			   </cfif>
			   CreatedDate)
			   values(@equipMainID,
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.equipmentIdForMainTrans#">,
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.equipmentMainT#">,
						<cfif structkeyexists(arguments.formStruct,"Odometer") >
							<cfif len(trim(arguments.formStruct.Odometer))>
								<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.formStruct.Odometer#">,
							</cfif>
						</cfif>
						<cfif structkeyexists(arguments.formStruct,"Date")>
							<cfif len(trim(arguments.formStruct.Date))>
								<cfqueryparam cfsqltype="cf_sql_timestamp" value="#arguments.formStruct.Date#">,
							</cfif>
						</cfif>
						<cfif structkeyexists(arguments.formStruct,"Notes")>
							<cfif len(trim(arguments.formStruct.Notes))>
								<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.Notes#">,
							</cfif>
						</cfif>
					  <cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">
					  );
					  select @equipMainID as equipMaintID
		   </cfquery>
			<cfquery name="qryGetEquipments" datasource="#variables.dsn#">
				select odometer
				from Equipments
				where EquipmentID=<cfqueryparam value="#arguments.formStruct.equipmentIdForMainTrans#" cfsqltype="cf_sql_varchar">
			</cfquery>
		    <cfif structkeyexists(arguments.formStruct,"Odometer") >
				<cfif len(trim(arguments.formStruct.Odometer))>
					<cfset variables.equipmentValue=val(qryGetEquipments.odometer)>
					<cfif variables.equipmentValue lt arguments.formStruct.Odometer>
						<cfquery name="qryUpdateEquipment" datasource="#variables.dsn#" result="aa">
							UPDATE Equipments
							SET	Odometer = <cfqueryparam value="#arguments.formStruct.Odometer#" cfsqltype="cf_sql_integer">
							where EquipmentID=<cfqueryparam value="#arguments.formStruct.equipmentIdForMainTrans#" cfsqltype="cf_sql_varchar">
					   </cfquery>
					</cfif>
				</cfif>
			</cfif>
		   <cfquery name="qryUpdate" datasource="#variables.dsn#">
			  UPDATE EquipmentMaint
				SET
				<cfif structkeyexists(arguments.formStruct,"Odometer") >
					<cfif len(trim(arguments.formStruct.Odometer))>
						NextOdometer = <cfqueryparam value="#nextOdometer#" cfsqltype="cf_sql_integer">,
					</cfif>
				</cfif>
				<cfif structkeyexists(arguments.formStruct,"Date")>
					<cfif len(trim(arguments.formStruct.Date))>
						NextDate = <cfqueryparam value="#variables.nextdate#" cfsqltype="cf_sql_timestamp">,
					</cfif>
				</cfif>
				<cfif structkeyexists(arguments.formStruct,"Notes1")>
					<cfif len(trim(arguments.formStruct.Notes1))>
						Notes = <cfqueryparam value="#arguments.formStruct.Notes#" cfsqltype="cf_sql_varchar">,
					</cfif>
				</cfif>
				ModifiedDate = <cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">

				where EquipMainID=<cfqueryparam value="#arguments.formStruct.equipmentMainT#" cfsqltype="cf_sql_varchar">
		   </cfquery>

			<!--- If there are any files attached to this load then move from temp table to the main table --->
		   <cfif structKeyExists(arguments.formStruct,"tempEquipmentMaintTransId")>
			   <cfinvoke method="linkAttachments" tempEquipmentId="#arguments.formStruct.tempEquipmentMaintTransId#" permEquipmentId="#EquipID.NewEquipID#">
		   </cfif>
			<cfif arguments.formStruct.pageDirection>
				<cflocation url="index.cfm?event=addNewMaintenance&equipmentid=#arguments.formStruct.equipmentIdForMainTrans#&equipmentMaintId=#arguments.formStruct.equipmentMainT#&#session.URLToken#&IsCarrier=#arguments.IsCarrier#" addtoken="false">
			<cfelse>
				<cflocation url="index.cfm?event=addDriverEquipment&equipmentid=#arguments.formStruct.equipmentIdForMainTrans#&#session.URLToken#&IsCarrier=#arguments.IsCarrier#" addtoken="false">
			</cfif>
		</cfif>
	</cffunction>


	<!---Function to get unique Equipment ids for maintenance not up to date --->
	<cffunction name="getOutOfOdometerListEquipments" access="public" output="false" returntype="query">
		<cfset var currentDate=now()>
		<cfquery name="qryListEquipments" datasource="#variables.dsn#">
		   select e.EquipmentID from Equipments e
			LEFT JOIN EquipmentMaint em
			ON e.EquipmentID=em.EquipID
			where e.Odometer > em.NextOdometer or em.NextDate < <cfqueryparam value="#currentDate#" cfsqltype="cf_sql_timestamp">
			and e.CompanyID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#session.CompanyID#">
	   </cfquery>
	   <cfreturn qryListEquipments>
	</cffunction>
	<!---Function to get count for equipments that maintenance not up to date --->
	<cffunction name="getCountEquipments" access="public" output="false" returntype="query">
		<cfset var currentDate=now()>
		<cfquery name="qryCountequipments" datasource="#variables.dsn#">
		   select count(e.EquipmentID)  from Equipments e
			LEFT JOIN EquipmentMaint em
			ON e.EquipmentID=em.EquipID
			where (e.Odometer> em.NextOdometer or em.NextDate < <cfqueryparam value="#currentDate#" cfsqltype="cf_sql_timestamp">)
			AND e.CompanyID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#session.CompanyID#">
	   </cfquery>
	   <cfreturn qryCountequipments>
	</cffunction>
	<!---Update EquipmentMaintenance table Information---->
	<cffunction name="updadeEquipMaintInformation" access="public" output="false" returntype="any">
	   <cfargument name="formStruct" type="struct" required="yes" />
	   <cfargument name="isCarrier" type="any" required="yes" />

		<cfif structkeyexists(arguments.formStruct,"equipmentId") and structkeyexists(arguments.formStruct,"editEquipmentmMaintId")>
			<cfset variables.currentday=now()>

			<cfquery name="updateQuery" datasource="#variables.dsn#">
				UPDATE EquipmentMaint
				SET
					<cfif structkeyexists(arguments.formStruct,"MilesInterval") and len(trim(arguments.formStruct.MilesInterval))>
						MilesInterval= <cfqueryparam cfsqltype="cf_sql_integer" value="#val(arguments.formStruct.MilesInterval)#">,
					</cfif>
					<cfif structkeyexists(arguments.formStruct,"DateInterval") and len(trim(arguments.formStruct.DateInterval))>
						DateInterval= <cfqueryparam cfsqltype="cf_sql_integer" value="#val(arguments.formStruct.DateInterval)#">,
					</cfif>
					<cfif structkeyexists(arguments.formStruct,"Notes") and len(trim(arguments.formStruct.Notes))>
					Notes= <cfqueryparam cfsqltype="cf_sql_varchar" value="#val(arguments.formStruct.Notes)#">,
					</cfif>

					<cfif structkeyexists(arguments.formStruct,"MilesInterval") and structkeyexists(arguments.formStruct,"Odometer")>
						<cfset var nextOdometer=val(arguments.formStruct.MilesInterval)+val(arguments.formStruct.Odometer)>
						NextOdometer = <cfqueryparam value="#nextOdometer#" cfsqltype="cf_sql_integer">,
					</cfif>
					<cfset variables.nextdate="">
					<cfif structkeyexists(arguments.formStruct,"nextDate")>
						<cfif len(trim(arguments.formStruct.nextDate))>
							NextDate = <cfqueryparam value="#arguments.formStruct.nextDate#" cfsqltype="cf_sql_timestamp">,
						<cfelse>
							<cfif structkeyexists(arguments.formStruct,"DateInterval")>
								<cfif arguments.formStruct.DateInterval neq 0>
									<cfset variables.nextdate=DateAdd("m",arguments.formStruct.DateInterval,variables.currentday)>
									NextDate = <cfqueryparam value="#variables.nextdate#" cfsqltype="cf_sql_timestamp">,
								<cfelse>
									NextDate = <cfqueryparam value="" cfsqltype="cf_sql_timestamp"  null="#yesNoFormat(NOT len(arguments.formStruct.nextDate))#">,
								</cfif>
							</cfif>
						</cfif>
					</cfif>
					ModifiedDate = <cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">
					where
					EquipID=<cfqueryparam value="#arguments.formStruct.equipmentId#" cfsqltype="cf_sql_varchar">
					and EquipMainID=<cfqueryparam value="#arguments.formStruct.editEquipmentmMaintId#" cfsqltype="cf_sql_varchar">
			</cfquery>
		   <cflocation url="index.cfm?event=addNewMaintenance&equipmentid=#arguments.formStruct.equipmentId#&equipmentMaintId=#arguments.formStruct.editEquipmentmMaintId#&#session.URLToken#&IsCarrier=#arguments.isCarrier#" addtoken="false">
	   </cfif>
	</cffunction>
	<cffunction name="deleteEquipmentMainsetUp"  access="public" output="false" returntype="any">
		<cfargument name="EquipmentMainsetUp" type="any" required="yes">
			<cftry>
				<cfquery name="qryDeleteEquipmentMaintTrans" datasource="#variables.dsn#">
					delete from EquipmentMaintSetup where  id=<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.EquipmentMainsetUp#">
				</cfquery>
				<cfreturn "Equipment Maintenance SetUp has been deleted successfully.">
				<cfcatch type="any">
					<cfreturn "Maintenance SetUp Delete operation has been not successfull.">
				</cfcatch>
			</cftry>
	</cffunction>

	<cffunction name="exportAllIftaTaxSummary" access="public" returntype="query">
		<cfargument name="dateFrom" required="yes">
		<cfargument name="dateTo" required="yes">
		<CFSTOREDPROC PROCEDURE="usp_IFTAData" DATASOURCE="#variables.dsn#">
				<CFPROCPARAM VALUE="#arguments.dateFrom#" cfsqltype="cf_sql_timestamp">
				<CFPROCPARAM VALUE="#arguments.dateTo#" cfsqltype="cf_sql_timestamp">
			 <CFPROCRESULT NAME="QreturnResult">
		</CFSTOREDPROC>
		<cfreturn QreturnResult>
	</cffunction>

	<cffunction name="getFileAttachmentDetails" access="public" returntype="query">
		<cfargument name="EquipmentTransID" required="yes">
		<cfquery name="qryGetFileAttachmentDetails" datasource="#variables.dsn#">
			SELECT * FROM FileAttachments
			where linked_Id=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.EquipmentTransID#">
				and linked_to=<cfqueryparam cfsqltype="cf_sql_integer" value="59">
		</cfquery>
		<cfreturn qryGetFileAttachmentDetails>
	</cffunction>

	<!---function to get the user editing details for corresponding equipment --->
	<cffunction name="getUserEditingDetails" access="public" returntype="query">
		<cfargument name="equipmentid" type="string" required="yes"/>
		<!---Query to get the user editing details for corresponding equipment--->
		
		<cfquery name="qryUpdateEditingUserId" datasource="#Application.dsn#">
			select  InUseBy,InUseOn from Equipments
			where EquipmentID=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.equipmentid#">
		</cfquery>
		<cfreturn qryUpdateEditingUserId>
	</cffunction>

	<!---function to update the userid for corresponding equipment--->
	<cffunction name="removeUserAccessOnEquipment" access="remote" returntype="struct" returnformat="json">
		<cfargument name="dsn" type="string" required="yes"/>
		<cfargument name="equipmentid" type="string" required="yes"/>
			<cfset var equipments=StructNew()>
			<!---Query to get the userid--->
			<cfquery name="qryGetUserId" datasource="#arguments.dsn#" result="result">
				select InUseBy,InUseOn,EquipmentCode from Equipments where EquipmentID=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.equipmentid#">
			</cfquery>

			<!--- Return if lock already removed --->
			<cfif len(trim(qryGetUserId.InUseBy)) eq 0>
				<cfset equipments.msg = "No Lock Exist!" />
				<cfreturn equipments>
			</cfif> 

			<!---Query to get editing User Name--->
			<cfquery name="qryGetUserName" datasource="#arguments.dsn#" result="result">
				SELECT NAME
				FROM employees
				WHERE employeeID = <cfqueryparam value="#qryGetUserId.inuseby#" cfsqltype="cf_sql_varchar">
			</cfquery>
			<cfset equipments.userName=qryGetUserName.NAME>
			<cfset equipments.onDateTime=dateformat(qryGetUserId.InUseOn,"mm/dd/yy hh:mm:ss")>
			<cfset equipments.dsn=arguments.dsn>

			<!---Query to update the userid for corresponding equipments to null--->
			<cfquery name="qryUpdateEditingUserId" datasource="#arguments.dsn#" result="result">
				UPDATE Equipments
				SET
				InUseBy=null,
				InUseOn=null
				where EquipmentId=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.equipmentid#">
			</cfquery>
			<cfreturn equipments>
	</cffunction>

	<!---function to update the userid for corresponding equipment--->
	<cffunction name="updateEditingUserId" access="public" returntype="void">
		<cfargument name="userid" type="string" required="yes"/>
		<cfargument name="equipmentid" type="string" required="yes"/>
		<cfargument name="status" type="boolean" required="yes"/>
		
		<cfif  arguments.status>
			<!---Query to update the userid for corresponding customers to null--->
			<cfquery name="qryUpdateEditingUserId" datasource="#Application.dsn#" result="result">
				UPDATE Equipments
				SET
				InUseBy=null,
				InUseOn=null,
				sessionid=null
				where InUseBy=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.userid#">
			</cfquery>
		<cfelse>
			<!---Query to update the userid for corresponding Customers--->
			<cfquery name="qryUpdateEditingUserId" datasource="#Application.dsn#" result="result">
				UPDATE Equipments
				SET
				InUseBy=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.userid#">,
				InUseOn=<cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">,
				sessionid=<cfqueryparam cfsqltype="cf_sql_varchar" value="#session.sessionid#">
				where equipmentid=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.equipmentid#">
			</cfquery>
		</cfif>
	</cffunction>
	<!---function to insert UserBrowserTabDetails--->
	<cffunction name="insertTabDetails" access="remote" output="yes" returnformat="json">
		<cfargument name="tabID" type="any" required="yes">
		<cfargument name="equipmentid" type="any" required="yes">
		<cfargument name="sessionid" type="any" required="yes">
		<cfargument name="userid" type="any" required="yes">
		<cfargument name="dsn" type="any" required="yes">
	
		<!---query to select UserBrowserTabDetails--->
		<cfquery name="qryGetBrowserTabDetails" datasource="#arguments.dsn#">
			select * from  UserBrowserTabDetails
			where 1=1
			and equipmentid=<cfqueryparam value="#arguments.equipmentid#" cfsqltype="cf_sql_varchar">
			and sessionid=<cfqueryparam value="#arguments.sessionid#" cfsqltype="cf_sql_varchar">
			and userid=<cfqueryparam value="#arguments.userid#" cfsqltype="cf_sql_varchar">
			and tabID=<cfqueryparam value="#arguments.tabID#" cfsqltype="cf_sql_varchar">
		</cfquery>
		<cfif not qryGetBrowserTabDetails .recordcount>
			<!---Query to insert UserBrowserTabDetails--->
			<cfquery name="qryInsertGetBrowserTabDetails" datasource="#arguments.dsn#">
				INSERT INTO UserBrowserTabDetails (userid, equipmentid, tabid, sessionid, createddate)
	            VALUES (<cfqueryparam value="#arguments.userid#" cfsqltype="cf_sql_varchar">,
						<cfqueryparam value="#arguments.equipmentid#" cfsqltype="cf_sql_varchar">,
						<cfqueryparam value="#arguments.tabID#" cfsqltype="cf_sql_varchar">	,
						<cfqueryparam value="#arguments.sessionid#" cfsqltype="cf_sql_varchar">,
						<cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">)
			</cfquery>
		</cfif>
	</cffunction>

	<!---function to delete BrowserTabDetails--->
	<cffunction name="deleteTabDetails" access="remote" output="yes" returnformat="json">
		<cfargument name="tabID" type="any" required="yes">
		<cfargument name="sessionid" type="any" required="yes">
		<cfargument name="userid" type="any" required="yes">
		<cfargument name="dsn" type="any" required="yes">
		<cfargument name="equipmentid" type="any" required="yes">
		<!---query to delete UserBrowserTabDetails--->
		<cfquery name="qryGetBrowserTabDetails" datasource="#arguments.dsn#">
			delete from  UserBrowserTabDetails
			where
			 sessionid=<cfqueryparam value="#arguments.sessionid#" cfsqltype="cf_sql_varchar">
			and userid=<cfqueryparam value="#arguments.userid#" cfsqltype="cf_sql_varchar">
			and tabID=<cfqueryparam value="#arguments.tabID#" cfsqltype="cf_sql_varchar">
			and EquipmentID=<cfqueryparam value="#arguments.equipmentid#" cfsqltype="cf_sql_varchar">
		</cfquery>
	</cffunction>


	<!--- Get Session Ajax version--->
	<cffunction name="getAjaxSession" access="remote" output="yes" returnformat="json">
		<cfargument name="UnlockStatus" type="any" required="no">
		<cfargument name="equipmentid" type="any" required="no">
		<cfargument name="dsn" type="any" required="no">
		<cfargument name="sessionid" type="any" required="no">
		<cfargument name="userid" type="any" required="no">
		<cfargument name="tabid" type="any" required="no">
		<cfargument name="saveEvent" type="any" required="no" default="false">

		<cfif structkeyexists(arguments,"tabid")>
			<!----query to delete -corresponding rows of tabid--->
			<cfquery name="qryGetBrowserTabDetails" datasource="#arguments.dsn#">
				delete from  UserBrowserTabDetails
				where tabID=<cfqueryparam value="#arguments.tabid#" cfsqltype="cf_sql_varchar">
			</cfquery>
		</cfif>
	

		<cfif structkeyexists(arguments,"UnlockStatus") and structkeyexists(arguments,"equipmentid") and arguments.UnlockStatus eq false and len(trim(arguments.equipmentid)) gt 1 and structkeyexists(arguments,"dsn") and structkeyexists(arguments,"sessionid") and structkeyexists(arguments,"userid") and arguments.saveevent neq "true">
			<!---Query to select browser tab details--->
			
			<cfquery name="qryGetBrowsertabDetails" datasource="#arguments.dsn#">
				select id from UserBrowserTabDetails
				where
					equipmentid=<cfqueryparam value="#arguments.equipmentid#" cfsqltype="cf_sql_varchar">
				and sessionid=<cfqueryparam value="#arguments.sessionid#" cfsqltype="cf_sql_varchar">
				and userid=<cfqueryparam value="#arguments.userid#" cfsqltype="cf_sql_varchar">
			</cfquery>
			

			<cfif not qryGetBrowsertabDetails.recordcount>
				
				<!---Query to remove lock --->
				<cfquery name="qryGetInuseBy" datasource="#arguments.dsn#">
					update Equipments
					set
						InUseBy=null,
						InUseOn=null,
						sessionId=null
					where EquipmentID=<cfqueryparam value="#arguments.equipmentid#" cfsqltype="cf_sql_varchar">
					and InUseBy = <cfqueryparam value="#arguments.userid#" cfsqltype="cf_sql_varchar">
				</cfquery>
			<cfelse>
				<cfabort/>
			</cfif>
		</cfif>
	 
	</cffunction>

	<cffunction name="getExpenseInformation" access="public" output="false" returntype="any">
		<cfargument name="ExpenseId" required="no" type="any">
		<cfargument name="sortorder" required="no" type="any">
		<cfargument name="sortby" required="no" type="any">
			<cfquery name="qryGetExpenses" datasource="#variables.dsn#">
				 select * from  CarrierExpensesSetup
				 where companyid = '#session.companyid#'
				<cfif structKeyExists(arguments,"ExpenseId") and len(arguments.ExpenseId)>
					and ExpenseId=<cfqueryparam value="#arguments.ExpenseId#" cfsqltype="cf_sql_varchar">
				</cfif>
				<cfif structKeyExists(arguments,"sortorder") and structKeyExists(arguments,"sortby") and len(arguments.sortby)>
					ORDER BY #arguments.sortby# #arguments.sortorder#
				<cfelse>
					ORDER BY Description
				</cfif>
			</cfquery>

			<cfreturn qryGetExpenses>
	</cffunction>

	<cffunction name="getExpenseDescriptionDuplicate" access="remote" output="false" returntype="any" returnFormat="plain">
		<cfargument name="dsName" required="true">
		<cfargument name="description" required="true">
		<cfargument name="editid" required="true">
		<cfargument name="CompanyID" required="true">
		<cfset TheKey = "NAMASKARAM">
		<cfset variables.decrypted = Decrypt(ToString(ToBinary(arguments.dsName)), TheKey)>
		<cfquery name="qryDescriptioncheck" datasource="#variables.decrypted#">
			select Description from CarrierExpensesSetup
			where
			Description = <cfqueryparam value="#arguments.description#" cfsqltype="cf_sql_varchar">
			<cfif arguments.editid NEQ "">
				AND ExpenseId <> <cfqueryparam value="#arguments.editid#" cfsqltype="cf_sql_varchar">
			</cfif>
			AND CompanyID = <cfqueryparam value="#arguments.CompanyID#" cfsqltype="cf_sql_varchar">
		</cfquery>
		<cfif qryDescriptioncheck.recordcount>
			<cfreturn 0>
		</cfif>
		<cfreturn 1>
	</cffunction>

	<cffunction name="AddExpenseSetup" access="public" output="false" returntype="any">
	   <cfargument name="formStruct" type="struct" required="no" />
		<cfquery name="insertquery" datasource="#variables.dsn#">
		   insert into CarrierExpensesSetup(Description,Amount,CreatedBy,Category,CompanyID)
		   values(
				  	<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.Description#">,
				  	<cfqueryparam cfsqltype="cf_sql_money" value="#ReplaceNoCase(ReplaceNoCase(arguments.formStruct.Amount,'$','','ALL'),',','','ALL')#">,
				    <cfqueryparam cfsqltype="cf_sql_varchar" value="#session.adminUserName#">,
				    <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.Category#">,
				    <cfqueryparam cfsqltype="cf_sql_varchar" value="#session.CompanyID#">
				  )
	   </cfquery>
	   <cfreturn "Expense has been added Successfully.">
	</cffunction>

	<cffunction name="UpdateExpenseSetup" access="public" output="false" returntype="any">
	   <cfargument name="formStruct" type="struct" required="no" />
		<cfquery name="updatequery" datasource="#variables.dsn#">
		   UPDATE CarrierExpensesSetup
		   SET 
		   Description=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.Description#">
		   ,Amount=<cfqueryparam cfsqltype="cf_sql_money" value="#ReplaceNoCase(ReplaceNoCase(arguments.formStruct.Amount,'$','','ALL'),',','','ALL')#">
		   ,CreatedBy=<cfqueryparam cfsqltype="cf_sql_varchar" value="#session.adminUserName#">
		   ,Category=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.Category#">
			WHERE ExpenseId = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.editid#">
	   </cfquery>
	   <cfreturn "Expense has been updated Successfully.">
	</cffunction>

	<cffunction name="deleteExpenseSetup" access="public" output="false" returntype="any">
	   <cfargument name="ExpenseId" type="string" required="no" />
		<cfquery name="deletequery" datasource="#variables.dsn#">
		   DELETE FROM CarrierExpensesSetup
			WHERE ExpenseId = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.ExpenseId#">
	   </cfquery>
	   <cfreturn "Expense has been deleted Successfully.">
	</cffunction>

	<cffunction name="getCarrierExpenses" access="remote" returntype="query">
		<cfargument name="carrierID" required="no">

		<cfquery name="qGetCarrierExpenses" datasource="#variables.dsn#">
		   SELECT * FROM CarrierExpenses
			WHERE CarrierId = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.carrierID#">
			order by created desc
	   </cfquery>

	   <cfreturn qGetCarrierExpenses>
	</cffunction>

	<cffunction name="expenseAutoComplete" access="remote"  output="yes" returnformat="json">
		<cfargument name="term" required="no">
		<cfargument name="CompanyID" required="yes">
		<cfset local.dsn = trim(listFirst(cgi.SCRIPT_NAME,'/'))>
		<cfquery name="qGetExpenses" datasource="#local.dsn#">
		   SELECT Description,Amount,Category FROM CarrierExpensesSetup
			WHERE Description LIKE <cfqueryparam value="#url.term#%" cfsqltype="cf_sql_varchar">
			AND CompanyID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.CompanyID#">
	   </cfquery>
	   <cfset thisArrayBecomesJSON = [] />
	   <cfloop query="qGetExpenses">
	   		<cfset thisEvent = {
	   			"Description" = "#qGetExpenses.Description#",
				"Amount" = "#replace("$#Numberformat(qGetExpenses.amount,"___.__")#", " ", "", "ALL")#",
				"Category" = "#qGetExpenses.Category#"
	   		}>
	   		<cfset arrayAppend( thisArrayBecomesJSON, thisEvent ) />
	   </cfloop>
	   
	   <cfreturn serializeJSON( thisArrayBecomesJSON )>
	</cffunction>

	<cffunction name="insertCarrierExpense" access="public" output="false" returntype="any">
	   <cfargument name="formStruct" type="struct" required="no" />

		<cfquery name="insertquery" datasource="#variables.dsn#">
		   insert into CarrierExpenses(CarrierID,Description,Amount,CreatedBy,Category,Date)
		   values(	
		   			<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.driverid#">,
				  	<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.Description#">,
				  	<cfqueryparam cfsqltype="cf_sql_money" value="#ReplaceNoCase(ReplaceNoCase(arguments.formStruct.Amount,'$','','ALL'),',','','ALL')#">,
				    <cfqueryparam cfsqltype="cf_sql_varchar" value="#session.adminUserName#">,
				    <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.Category#">,
				    <cfqueryparam cfsqltype="cf_sql_date" value="#arguments.formStruct.date#">
				  )
	   </cfquery>
	   <cfreturn "Carrier Expense has been added Successfully.">
	</cffunction>

	<cffunction name="getCarrierExpenseInformation" access="public" output="false" returntype="any">
		<cfargument name="CarrierExpenseID" required="no" type="any">

			<cfquery name="qryGetCarrierExpense" datasource="#variables.dsn#">
				select * from  CarrierExpenses where 
				CarrierExpenseId=<cfqueryparam value="#arguments.CarrierExpenseID#" cfsqltype="cf_sql_varchar">
			</cfquery>

			<cfreturn qryGetCarrierExpense>
	</cffunction>

	<cffunction name="updadeCarrierExpense" access="public" output="false" returntype="any">
	   <cfargument name="formStruct" type="struct" required="no" />
		<cfquery name="updatequery" datasource="#variables.dsn#">
		   UPDATE CarrierExpenses
		   SET 
		   Description=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.Description#">
		   ,Amount=<cfqueryparam cfsqltype="cf_sql_money" value="#ReplaceNoCase(ReplaceNoCase(arguments.formStruct.Amount,'$','','ALL'),',','','ALL')#">
		   ,Category=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.Category#">
		   ,Date=<cfqueryparam cfsqltype="cf_sql_date" value="#arguments.formStruct.date#">
			WHERE CarrierExpenseId = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.editid#">
	   </cfquery>
	   <cfreturn "Carrier Expense has been updated Successfully.">
	</cffunction>

	<cffunction name="deleteCarrierExpense" access="public" output="false" returntype="any">
	   <cfargument name="carrierExpenseID" type="string" required="no" />

		<cfquery name="updatequery" datasource="#variables.dsn#">
		   DELETE FROM  CarrierExpenses
			WHERE CarrierExpenseId = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.carrierExpenseID#">
	   </cfquery>
	   <cfreturn "Carrier Expense has been deleted Successfully.">
	</cffunction>

	<cffunction name="insertRecurringCarrierExpense" access="public" output="false" returntype="any">
	   <cfargument name="formStruct" type="struct" required="no" />

		<cfquery name="insertquery" datasource="#variables.dsn#">
		   insert into CarrierExpensesRecurring(CarrierID,Description,Amount,CreatedBy,Category,NextDate,Interval)
		   values(	
		   			<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.driverid#">,
				  	<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.Description#">,
				  	<cfqueryparam cfsqltype="cf_sql_money" value="#ReplaceNoCase(ReplaceNoCase(arguments.formStruct.Amount,'$','','ALL'),',','','ALL')#">,
				    <cfqueryparam cfsqltype="cf_sql_varchar" value="#session.adminUserName#">,
				    <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.Category#">,
				    <cfqueryparam cfsqltype="cf_sql_date" value="#arguments.formStruct.date#">,
				    <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.interval#">
				  )
	   </cfquery>
	   <cfreturn "Recurring Carrier Expense has been added Successfully.">
	</cffunction>

	<cffunction name="getRecurringCarrierExpenses" access="remote" returntype="query">
		<cfargument name="carrierID" required="no">

		<cfquery name="qGetRecurringCarrierExpenses" datasource="#variables.dsn#">
		   SELECT * FROM CarrierExpensesRecurring
			WHERE CarrierId = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.carrierID#">
			order by created desc
	   </cfquery>

	   <cfreturn qGetRecurringCarrierExpenses>
	</cffunction>

	<cffunction name="getRecurringCarrierExpenseInformation" access="public" output="false" returntype="any">
		<cfargument name="carrierExpenseRecurringID" required="no" type="any">

			<cfquery name="qryGetRecurringCarrierExpense" datasource="#variables.dsn#">
				select * from  CarrierExpensesRecurring where 
				carrierExpenseRecurringID=<cfqueryparam value="#arguments.carrierExpenseRecurringID#" cfsqltype="cf_sql_varchar">
			</cfquery>

			<cfreturn qryGetRecurringCarrierExpense>
	</cffunction>

	<cffunction name="updateRecurringCarrierExpense" access="public" output="false" returntype="any">
	   <cfargument name="formStruct" type="struct" required="no" />
		<cfquery name="updatequery" datasource="#variables.dsn#">
		   UPDATE CarrierExpensesRecurring
		   SET 
		   Description=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.Description#">
		   ,Amount=<cfqueryparam cfsqltype="cf_sql_money" value="#ReplaceNoCase(ReplaceNoCase(arguments.formStruct.Amount,'$','','ALL'),',','','ALL')#">
		   ,Category=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.Category#">
		   ,NextDate=<cfqueryparam cfsqltype="cf_sql_date" value="#arguments.formStruct.date#">
		   ,Interval=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.Interval#">
			WHERE carrierExpenseRecurringID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.editid#">
	   </cfquery>
	   <cfreturn "Recurring Carrier Expense has been updated Successfully.">
	</cffunction>

	<cffunction name="deleteRecurringCarrierExpense" access="public" output="false" returntype="any">
	   	<cfargument name="carrierExpenseRecurringID" type="string" required="no" />
		<cfquery name="qDel" datasource="#variables.dsn#">
		   DELETE FROM CarrierExpensesRecurring
			WHERE carrierExpenseRecurringID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.carrierExpenseRecurringID#">
	   </cfquery>
	   <cfreturn "Recurring Carrier Expense has been deleted successfully.">
	</cffunction>

	<cffunction name="generateRecurringDriverExpenses" access="remote" output="false" returntype="string" returnFormat="plain">
	   <cfargument name="driverid" type="string" required="no" default=""/>
	   <cfargument name="adminUserName" type="string" required="no" default=""/>
	   <cfargument name="CompanyID" type="string" required="yes"/>
	   	<cfset variables.dsn = trim(listFirst(cgi.SCRIPT_NAME,'/'))>

	   	<cfif structKeyExists(arguments, "adminUserName") AND len(trim(arguments.adminUserName))>
	   		<cfset session.adminUserName = arguments.adminUserName>
	   	</cfif>

		<cfquery name="getQuery" datasource="#variables.dsn#">
		  	SELECT * FROM CarrierExpensesRecurring
		  	WHERE NextDate <= getdate()
		  	<cfif structKeyExists(arguments, "driverid") AND len(trim(arguments.driverid))>
		  		AND CarrierId = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.driverid#">
		  	</cfif>
		  	AND CarrierID IN (SELECT CarrierID FROM Carriers WHERE CompanyID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.CompanyID#">)
	    </cfquery>

	    <cfif not getQuery.recordcount>
	    	<cfreturn "No Carrier Expense generated.">
	    </cfif>
	    <cfloop query="getQuery">

	    	<cfswitch expression="#getQuery.interval#">
	    		<cfcase value="D">

	    			<cfset limit = DateDiff("d",getQuery.nextdate,now())>
	    			<cfloop from="0" to="#limit#" index="i">
	    				<cfset local.NextDate = dateAdd("d", '#i#', '#getQuery.Nextdate#')>
		    			<cfquery name="insertquery" datasource="#variables.dsn#">
						   insert into CarrierExpenses(CarrierID,Description,Amount,CreatedBy,Category,Date)
						   values(	
						   			<cfqueryparam cfsqltype="cf_sql_varchar" value="#getQuery.carrierID#">,
								  	<cfqueryparam cfsqltype="cf_sql_varchar" value="#getQuery.Description#">,
								  	<cfqueryparam cfsqltype="cf_sql_money" value="#getQuery.Amount#">,
								    <cfqueryparam cfsqltype="cf_sql_varchar" value="#session.adminUserName#">,
								    <cfqueryparam cfsqltype="cf_sql_varchar" value="#getQuery.Category#">,
								    <cfqueryparam cfsqltype="cf_sql_date" value="#local.Nextdate#">
								  )
					   </cfquery>
					</cfloop>
					<cfset local.NextDate = dateAdd("d", '1', '#local.Nextdate#')>
					<cfquery name="updatequery" datasource="#variables.dsn#">
					   UPDATE CarrierExpensesRecurring
					   SET 
					   NextDate=<cfqueryparam cfsqltype="cf_sql_date" value="#local.NextDate#">
					   WHERE carrierExpenseRecurringID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#getQuery.carrierExpenseRecurringID#">
				   </cfquery>

	    		</cfcase>

	    		<cfcase value="W">
	    			<cfset limit = DateDiff("ww",getQuery.nextdate,now())>
	    			<cfloop from="0" to="#limit#" index="i">
	    				<cfset local.NextDate = dateAdd("ww", '#i#', '#getQuery.Nextdate#')>
		    			<cfquery name="insertquery" datasource="#variables.dsn#">
						   insert into CarrierExpenses(CarrierID,Description,Amount,CreatedBy,Category,Date)
						   values(	
						   			<cfqueryparam cfsqltype="cf_sql_varchar" value="#getQuery.carrierID#">,
								  	<cfqueryparam cfsqltype="cf_sql_varchar" value="#getQuery.Description#">,
								  	<cfqueryparam cfsqltype="cf_sql_money" value="#getQuery.Amount#">,
								    <cfqueryparam cfsqltype="cf_sql_varchar" value="#session.adminUserName#">,
								    <cfqueryparam cfsqltype="cf_sql_varchar" value="#getQuery.Category#">,
								    <cfqueryparam cfsqltype="cf_sql_date" value="#local.Nextdate#">
								  )
					   </cfquery>
					</cfloop>
					<cfset local.NextDate = dateAdd("ww", '1', '#local.Nextdate#')>
					<cfquery name="updatequery" datasource="#variables.dsn#">
					   UPDATE CarrierExpensesRecurring
					   SET 
					   NextDate=<cfqueryparam cfsqltype="cf_sql_date" value="#local.NextDate#">
					   WHERE carrierExpenseRecurringID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#getQuery.carrierExpenseRecurringID#">
				   </cfquery>
	    		</cfcase>

	    		<cfcase value="Q">
	    			<cfset limit = DateDiff("q",getQuery.nextdate,now())>
	    			<cfloop from="0" to="#limit#" index="i">
	    				<cfset local.NextDate = dateAdd("q", '#i#', '#getQuery.Nextdate#')>
		    			<cfquery name="insertquery" datasource="#variables.dsn#">
						   insert into CarrierExpenses(CarrierID,Description,Amount,CreatedBy,Category,Date)
						   values(	
						   			<cfqueryparam cfsqltype="cf_sql_varchar" value="#getQuery.carrierID#">,
								  	<cfqueryparam cfsqltype="cf_sql_varchar" value="#getQuery.Description#">,
								  	<cfqueryparam cfsqltype="cf_sql_money" value="#getQuery.Amount#">,
								    <cfqueryparam cfsqltype="cf_sql_varchar" value="#session.adminUserName#">,
								    <cfqueryparam cfsqltype="cf_sql_varchar" value="#getQuery.Category#">,
								    <cfqueryparam cfsqltype="cf_sql_date" value="#local.Nextdate#">
								  )
					   </cfquery>
					</cfloop>
					<cfset local.NextDate = dateAdd("q", '1', '#local.Nextdate#')>
					<cfquery name="updatequery" datasource="#variables.dsn#">
					   UPDATE CarrierExpensesRecurring
					   SET 
					   NextDate=<cfqueryparam cfsqltype="cf_sql_date" value="#local.NextDate#">
					   WHERE carrierExpenseRecurringID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#getQuery.carrierExpenseRecurringID#">
				   </cfquery>
	    		</cfcase>

	    		<cfcase value="M">
	    			<cfset limit = DateDiff("m",getQuery.nextdate,now())>
	    			<cfloop from="0" to="#limit#" index="i">
	    				<cfset local.NextDate = dateAdd("m", '#i#', '#getQuery.Nextdate#')>
		    			<cfquery name="insertquery" datasource="#variables.dsn#">
						   insert into CarrierExpenses(CarrierID,Description,Amount,CreatedBy,Category,Date)
						   values(	
						   			<cfqueryparam cfsqltype="cf_sql_varchar" value="#getQuery.carrierID#">,
								  	<cfqueryparam cfsqltype="cf_sql_varchar" value="#getQuery.Description#">,
								  	<cfqueryparam cfsqltype="cf_sql_money" value="#getQuery.Amount#">,
								    <cfqueryparam cfsqltype="cf_sql_varchar" value="#session.adminUserName#">,
								    <cfqueryparam cfsqltype="cf_sql_varchar" value="#getQuery.Category#">,
								    <cfqueryparam cfsqltype="cf_sql_date" value="#local.Nextdate#">
								  )
					   </cfquery>
					</cfloop>
					<cfset local.NextDate = dateAdd("m", '1', '#local.Nextdate#')>
					<cfquery name="updatequery" datasource="#variables.dsn#">
					   UPDATE CarrierExpensesRecurring
					   SET 
					   NextDate=<cfqueryparam cfsqltype="cf_sql_date" value="#local.NextDate#">
					   WHERE carrierExpenseRecurringID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#getQuery.carrierExpenseRecurringID#">
				   </cfquery>
	    		</cfcase>

	    		<cfcase value="Y">
	    			<cfset limit = DateDiff("yyyy",getQuery.nextdate,now())>

	    			<cfloop from="0" to="#limit#" index="i">
	    				<cfset local.NextDate = dateAdd("yyyy", '#i#', '#getQuery.Nextdate#')>
		    			<cfquery name="insertquery" datasource="#variables.dsn#">
						   insert into CarrierExpenses(CarrierID,Description,Amount,CreatedBy,Category,Date)
						   values(	
						   			<cfqueryparam cfsqltype="cf_sql_varchar" value="#getQuery.carrierID#">,
								  	<cfqueryparam cfsqltype="cf_sql_varchar" value="#getQuery.Description#">,
								  	<cfqueryparam cfsqltype="cf_sql_money" value="#getQuery.Amount#">,
								    <cfqueryparam cfsqltype="cf_sql_varchar" value="#session.adminUserName#">,
								    <cfqueryparam cfsqltype="cf_sql_varchar" value="#getQuery.Category#">,
								    <cfqueryparam cfsqltype="cf_sql_date" value="#local.Nextdate#">
								  )
					   </cfquery>
					</cfloop>
					<cfset local.NextDate = dateAdd("yyyy", '1', '#local.Nextdate#')>
					<cfquery name="updatequery" datasource="#variables.dsn#">
					   UPDATE CarrierExpensesRecurring
					   SET 
					   NextDate=<cfqueryparam cfsqltype="cf_sql_date" value="#local.NextDate#">
					   WHERE carrierExpenseRecurringID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#getQuery.carrierExpenseRecurringID#">
				   </cfquery>
	    		</cfcase>

	    		<cfcase value="2">
	    			<cfquery name="insertquery" datasource="#variables.dsn#">
					   insert into CarrierExpenses(CarrierID,Description,Amount,CreatedBy,Category,Date)
					   values(	
					   			<cfqueryparam cfsqltype="cf_sql_varchar" value="#getQuery.carrierID#">,
							  	<cfqueryparam cfsqltype="cf_sql_varchar" value="#getQuery.Description#">,
							  	<cfqueryparam cfsqltype="cf_sql_money" value="#getQuery.Amount#">,
							    <cfqueryparam cfsqltype="cf_sql_varchar" value="#session.adminUserName#">,
							    <cfqueryparam cfsqltype="cf_sql_varchar" value="#getQuery.Category#">,
							    <cfqueryparam cfsqltype="cf_sql_date" value="#getQuery.Nextdate#">
							  )
				   </cfquery>
			
					<cfset local.NextDate = dateAdd("yyyy", '2', '#getQuery.Nextdate#')>
					<cfquery name="updatequery" datasource="#variables.dsn#">
					   UPDATE CarrierExpensesRecurring
					   SET 
					   NextDate=<cfqueryparam cfsqltype="cf_sql_date" value="#local.NextDate#">
					   WHERE carrierExpenseRecurringID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#getQuery.carrierExpenseRecurringID#">
				   </cfquery>
	    		</cfcase>
	    	</cfswitch>
	    </cfloop>
	   <cfreturn "Carrier Expense has been generated Successfully.">
	</cffunction>

	<cffunction name="OdometerReading" access="remote" output="yes" returntype="string" returnformat="json">
		<cfargument name="CompanyCode" type="string" required="yes">
		<cftry>
			<cfhttp url="https://proadmin.flexgps.net/sdk/?svc=get_token&login=LoadManager&pass=loadmanager2020&lang=en" method="get" timeout="60">
			</cfhttp>

			<cfif cfhttp.Statuscode EQ '200 OK'>
				<cfset local.token = DeserializeJSON(cfhttp.FileContent).token>
				<cfquery name="qGetEquipments" datasource="LoadManagerLive">
					SELECT EquipmentID,IMEI FROM Equipments WHERE CompanyID = (SELECT CompanyID FROM Companies WHERE CompanyCode = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.CompanyCode#">)
					AND IMEI IS NOT NULL
				</cfquery>

				<cfhttp url="https://proadmin.flexgps.net/sdk/?svc=get_units_paging&token=#local.token#&params={'page':1,'per_page':20,'fields':['counters']}" method="get" timeout="60" result="resUnits">
				</cfhttp>

				<cfif resUnits.Statuscode EQ '200 OK'>
					<cfset arrUnits = DeserializeJSON(resUnits.FileContent)>
					<cfloop array="#arrUnits#" index="unit">
						<cfif structKeyExists(unit, "counters") AND structKeyExists(unit.counters, "mileage")>
							<cfset local.hw_id = unit.hw_id>
							<cfset local.mileage = unit.counters.mileage>

							<cfquery name="qUpdOdoMeter" datasource="LoadManagerLive">
								UPDATE Equipments SET Odometer = <cfqueryparam cfsqltype="cf_sql_integer" value="#local.mileage#"> WHERE IMEI = <cfqueryparam cfsqltype="cf_sql_varchar" value="#local.hw_id#">
							</cfquery>
						</cfif>
					</cfloop>
					<cfquery name="qInsOdoMeterLog" datasource="LoadManagerLive">
						INSERT INTO [dbo].[OdometerLog]
				           ([CreatedDateTime]
				           ,[Data]
				           ,[CompanyID])
				        VALUES(
				        	getdate(),
				        	<cfqueryparam cfsqltype="cf_sql_varchar" value="#resUnits.FileContent#">,
				        	(SELECT CompanyID FROM Companies WHERE CompanyCode = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.CompanyCode#">)
				        	)
					</cfquery>
				</cfif>
			</cfif>
			<cfreturn 'Success'>
			<cfcatch>
				<cffile action="append" file="#ExpandPath("../webroot/logs")#/Application.Log.txt" output="OdometerReading:#serializeJSON(cfcatch)#">
				<cfreturn 'Failed.'>
			</cfcatch>
		</cftry>
	</cffunction>

	<cffunction name="uploadEquipmentViaCSV" access="remote" output="yes" returnformat="json">
	    <cfargument name="createdBy" required="yes" type="any">
	    <cfargument name="CompanyID" required="yes" type="any">

	    <cftry>
	    	<cfset row="">
      		<cfset response = structNew()>  
      		<cfset local.dsn = trim(listFirst(cgi.SCRIPT_NAME,'/'))>

      		<cfset rootPath = expandPath('../fileupload/tempCSV/')>
      		<cfif not directoryExists(rootPath)>
        		<cfdirectory action = "create" directory = "#rootPath#" > 
      		</cfif>

      		<cffile action="upload" filefield="file" destination="#rootPath#" nameConflict="MakeUnique" result=uploadedFile>

      		<cfif uploadedFile.SERVERFILEEXT NEQ 'csv'>
		        <cfset response.success = 0>
		        <cfset response.message = "Invalid file extension.Please upload CSV file.">
		        <cfreturn response>
		    </cfif> 

		    <cfset fileName = uploadedFile.SERVERFILE>

		    <!--- <cfset fileName = 'temp.csv'> --->

		    <cffile action="read" file="#rootPath##fileName#" variable="csvfile">

			<cfset validHeader = "Status,Unit ##,Type,Internal or External,Description,License Plate ##,Vin/Serial ##">
			<cfset uploadedHeader = listgetAt('#csvfile#',1, '#chr(10)##chr(13)#')>

			<cfif Compare(validHeader, uploadedHeader) NEQ 0>
				<cffile action="delete" file="#rootPath##fileName#">
				<cfset response.success = 0>
				<cfset response.message = "There are one or more column headings that are not valid.  Please check correct and try again.">
				<cfreturn response>
			</cfif>

			<cfquery name="qGet" datasource="#local.dsn#">
		        SELECT EquipmentName FROM Equipments WHERE CompanyID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.companyid#">
		    </cfquery>

		    <cfset validEquipments = valuelist(qGet.EquipmentName)>
			<cfset currentRow = 1>
      		<cfset bitImportedAll = 1>
      		<cftransaction>
			<cfloop index="row" list="#csvfile#" delimiters="#chr(10)##chr(13)#">
        		<cfif currentRow NEQ 1>
          			<cfset qryRow = CSVToQuery(row)>
          			<cfif qryRow.column_1 EQ 'Active'>
          				<cfset status = 1>
          			<cfelse>
          				<cfset status = 0>
          			</cfif>
          			<cfset unitNumber = qryRow.column_2>
          			<cfset Type = qryRow.column_3>
          			<cfset InternalOrExternal = qryRow.column_4>
          			<cfset EquipmentName = qryRow.column_5>
          			<cfset licensePlate = qryRow.column_6>
          			<cfset vin = qryRow.column_7>

          			<cfif NOT listFindNoCase(validEquipments, EquipmentName)>
          				<cfquery name="qGetEquip" datasource="#local.dsn#">
			              	SELECT NewID() AS EquipmentID
			            </cfquery>
			            <cfquery name="qIns" datasource="#local.dsn#">
			            	INSERT INTO Equipments(EquipmentID,IsActive,UnitNumber,EquipmentType,InternalOrExternal,EquipmentName,EquipmentCode,licensePlate,vin,CompanyID,CreatedBy,LastModifiedBy,CreatedDateTime,LastModifiedDateTime,UpdatedByIP,GUID)
			            	VALUES(
			            		<cfqueryparam cfsqltype="cf_sql_varchar" value="#qGetEquip.EquipmentID#">
			            		,<cfqueryparam cfsqltype="cf_sql_bit" value="#status#">
			            		,<cfqueryparam cfsqltype="cf_sql_varchar" value="#unitNumber#">
			            		,<cfqueryparam cfsqltype="cf_sql_varchar" value="#Type#">
			            		,<cfqueryparam cfsqltype="cf_sql_varchar" value="#InternalOrExternal#">
			            		,<cfqueryparam cfsqltype="cf_sql_varchar" value="#EquipmentName#">
			            		,<cfqueryparam cfsqltype="cf_sql_varchar" value="#EquipmentName#">
			            		,<cfqueryparam cfsqltype="cf_sql_varchar" value="#licensePlate#">
			            		,<cfqueryparam cfsqltype="cf_sql_varchar" value="#vin#">
			            		,<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.companyid#">
			            		,<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.createdBy#">
			            		,<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.createdBy#">
			            		,getdate()
			            		,getdate()
			            		,<cfqueryparam cfsqltype="cf_sql_varchar" value="#cgi.REMOTE_ADDR#">
	    						,<cfqueryparam cfsqltype="cf_sql_varchar" value="#cgi.HTTP_USER_AGENT#">
			            	)
			            </cfquery>

			            <cfquery name="qInsLog" datasource="#local.dsn#">
							INSERT INTO EquipmentCsvImportLog (LogId,Message,CreatedDate,Success,RowData,CompanyID,CreatedBy,EquipmentName)
							VALUES(newid(),
							<cfqueryparam cfsqltype="cf_sql_varchar" value='Imported Equipment(Row Number:#currentRow#).'>,
							getdate(),
							1,
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#row#">,
							<cfqueryparam cfsqltype="cf_sql_varchar" value='#arguments.companyid#'>,
							<cfqueryparam cfsqltype="cf_sql_varchar" value='#arguments.createdBy#'>,
							<cfqueryparam cfsqltype="cf_sql_varchar" value='#EquipmentName#'>
							)
						</cfquery>
			            <!--- Insert Log --->
			        <cfelse>
			        	<cfset bitImportedAll = 0>
			        	<cfquery name="qInsLog" datasource="#local.dsn#">
							INSERT INTO EquipmentCsvImportLog (LogId,Message,CreatedDate,Success,RowData,CompanyID,CreatedBy,EquipmentName)
							VALUES(newid(),
							<cfqueryparam cfsqltype="cf_sql_varchar" value='EquipmentName already exists. Row Number:#currentRow#'>,
							getdate(),0,
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#row#">,
							<cfqueryparam cfsqltype="cf_sql_varchar" value='#arguments.companyid#'>,
							<cfqueryparam cfsqltype="cf_sql_varchar" value='#arguments.createdBy#'>,
							<cfqueryparam cfsqltype="cf_sql_varchar" value='#EquipmentName#'>)
						</cfquery>
			         	<!--- Insert Log --->
          			</cfif>
          		</cfif>
          		<cfset currentRow++>
          	</cfloop>
          	<cfset response.success = 1>
      		<cfif bitImportedAll EQ 0>
        		<cfset response.message = "Some rows are not imported. Please check log for more details.">
      		<cfelse>
        		<cfset response.message = "Equipments imported successfully. Please check log for more details.">
      		</cfif>
     		 <cfreturn response>
      		</cftransaction>
	    	<cfcatch>
	    		<cfquery name="qInsLog" datasource="#local.dsn#">
					INSERT INTO EquipmentCsvImportLog (LogId,Message,CreatedDate,Success,RowData,CompanyID,CreatedBy)
					VALUES(newid(),
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#cfcatch.message##cfcatch.detail#">,
					getdate(),0,
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#row#">,
					<cfqueryparam cfsqltype="cf_sql_varchar" value='#arguments.companyid#'>,
					<cfqueryparam cfsqltype="cf_sql_varchar" value='#arguments.createdBy#'>
					)
				</cfquery>
	    		<!--- Insert Log --->
		        <cfset response.success = 0>
		        <cfset response.message = "Something went wrong. Please contact support.">
		        <cfreturn response>
		    </cfcatch>
	    </cftry>
	</cffunction>

	<cffunction	name="CSVToQuery" access="public" returntype="query" output="false"	hint="Converts the given CSV string to a query.">

		<cfargument	name="CSV" type="string" required="true"	hint="This is the CSV string that will be manipulated."/>
		<cfargument name="Delimiter" type="string" required="false" default="," hint="This is the delimiter that will separate the fields within the CSV value."/>
		<cfargument name="Qualifier" type="string" required="false"	default="""" hint="This is the qualifier that will wrap around fields that have special characters embeded."/>

		<cfset var LOCAL = StructNew() />
		<cfset ARGUMENTS.Delimiter = Left( ARGUMENTS.Delimiter, 1 ) />
		<cfif Len( ARGUMENTS.Qualifier )>
			<cfset ARGUMENTS.Qualifier = Left( ARGUMENTS.Qualifier, 1 ) />
		</cfif>
		<cfset LOCAL.LineDelimiter = Chr( 10 ) />
		<cfset ARGUMENTS.CSV = ARGUMENTS.CSV.ReplaceAll("\r?\n",LOCAL.LineDelimiter) />
		<cfset LOCAL.Delimiters = ARGUMENTS.CSV.ReplaceAll("[^\#ARGUMENTS.Delimiter#\#LOCAL.LineDelimiter#]+","").ToCharArray()/>
		<cfset ARGUMENTS.CSV = (" " & ARGUMENTS.CSV) />
		<cfset ARGUMENTS.CSV = ARGUMENTS.CSV.ReplaceAll("([\#ARGUMENTS.Delimiter#\#LOCAL.LineDelimiter#]{1})","$1 ") />
		<cfset LOCAL.Tokens = ARGUMENTS.CSV.Split("[\#ARGUMENTS.Delimiter#\#LOCAL.LineDelimiter#]{1}") />
		<cfset LOCAL.Rows = ArrayNew( 1 ) />
		<cfset ArrayAppend(LOCAL.Rows,ArrayNew( 1 )) />
		<cfset LOCAL.RowIndex = 1 />
		<cfset LOCAL.IsInValue = false />
		<cfloop	index="LOCAL.TokenIndex" from="1" to="#ArrayLen( LOCAL.Tokens )#" step="1">
			<cfset LOCAL.FieldIndex = ArrayLen(LOCAL.Rows[ LOCAL.RowIndex ]) />
			<cfset LOCAL.Token = LOCAL.Tokens[ LOCAL.TokenIndex ].ReplaceFirst("^.{1}","") />
			<cfif Len( ARGUMENTS.Qualifier )>
				<cfif LOCAL.IsInValue>
					<cfset LOCAL.Token = LOCAL.Token.ReplaceAll("\#ARGUMENTS.Qualifier#{2}","{QUALIFIER}")/>
					<cfset LOCAL.Rows[ LOCAL.RowIndex ][ LOCAL.FieldIndex ] = (LOCAL.Rows[ LOCAL.RowIndex ][ LOCAL.FieldIndex ] &
						LOCAL.Delimiters[ LOCAL.TokenIndex - 1 ] & LOCAL.Token) />
					<cfif (Right( LOCAL.Token, 1 ) EQ ARGUMENTS.Qualifier)>
						<cfset LOCAL.Rows[ LOCAL.RowIndex ][ LOCAL.FieldIndex ] = LOCAL.Rows[ LOCAL.RowIndex ][ LOCAL.FieldIndex ].ReplaceFirst( ".{1}$", "" ) />
						<cfset LOCAL.IsInValue = false />
					</cfif>
				<cfelse>
					<cfif (Left( LOCAL.Token, 1 ) EQ ARGUMENTS.Qualifier)>
						<cfset LOCAL.Token = LOCAL.Token.ReplaceFirst("^.{1}","")/>
						<cfset LOCAL.Token = LOCAL.Token.ReplaceAll("\#ARGUMENTS.Qualifier#{2}","{QUALIFIER}")/>
						<cfif (Right( LOCAL.Token, 1 ) EQ ARGUMENTS.Qualifier)>
							<cfset ArrayAppend(LOCAL.Rows[ LOCAL.RowIndex ],LOCAL.Token.ReplaceFirst(".{1}$","")) />
						<cfelse>
							<cfset LOCAL.IsInValue = true />
							<cfset ArrayAppend(LOCAL.Rows[ LOCAL.RowIndex ],LOCAL.Token)/>
						</cfif>
					<cfelse>
						<cfset ArrayAppend(LOCAL.Rows[ LOCAL.RowIndex ],LOCAL.Token) />
					</cfif>
				</cfif>
				<cfset LOCAL.Rows[ LOCAL.RowIndex ][ ArrayLen( LOCAL.Rows[ LOCAL.RowIndex ] ) ] = Replace(
					LOCAL.Rows[ LOCAL.RowIndex ][ ArrayLen( LOCAL.Rows[ LOCAL.RowIndex ] ) ],"{QUALIFIER}",ARGUMENTS.Qualifier,
					"ALL") />
			<cfelse>
				<cfset ArrayAppend(LOCAL.Rows[ LOCAL.RowIndex ],LOCAL.Token)/>
			</cfif>
			<cfif ((NOT LOCAL.IsInValue) AND (LOCAL.TokenIndex LT ArrayLen( LOCAL.Tokens )) AND	(LOCAL.Delimiters[ LOCAL.TokenIndex ] EQ LOCAL.LineDelimiter))>
				<cfset ArrayAppend(LOCAL.Rows,ArrayNew( 1 )) />
				<cfset LOCAL.RowIndex = (LOCAL.RowIndex + 1) />
			</cfif>
		</cfloop>

		<cfset LOCAL.MaxFieldCount = 0 />
		<cfset LOCAL.EmptyArray = ArrayNew( 1 ) />
		<cfloop	index="LOCAL.RowIndex"from="1"to="#ArrayLen( LOCAL.Rows )#" step="1">
			<cfset LOCAL.MaxFieldCount = Max(LOCAL.MaxFieldCount,ArrayLen(LOCAL.Rows[ LOCAL.RowIndex ]))/>
			<cfset ArrayAppend(LOCAL.EmptyArray,"")/>
		</cfloop>

		<cfset LOCAL.Query = QueryNew( "" ) />

		<cfloop	index="LOCAL.FieldIndex" from="1" to="#LOCAL.MaxFieldCount#" step="1">
			<cfset QueryAddColumn(LOCAL.Query,"COLUMN_#LOCAL.FieldIndex#","CF_SQL_VARCHAR",LOCAL.EmptyArray) />
		</cfloop>
		<cfloop	index="LOCAL.RowIndex" from="1" to="#ArrayLen( LOCAL.Rows )#"	step="1">
			<cfloop	index="LOCAL.FieldIndex" from="1" to="#ArrayLen( LOCAL.Rows[ LOCAL.RowIndex ] )#" step="1">
				<cfset LOCAL.Query[ "COLUMN_#LOCAL.FieldIndex#" ][ LOCAL.RowIndex ] = JavaCast("string",LOCAL.Rows[ LOCAL.RowIndex ][ LOCAL.FieldIndex ]) />
			</cfloop>
		</cfloop>
		<cfreturn LOCAL.Query />

	</cffunction>

	<cffunction name="getEquipmentCsvImportLog" access="public" output="false" returntype="query">
	    <cfargument name="searchText" required="no" type="any">
	    <cfargument name="pageNo" required="no" type="any" default="1">
	    <cfargument name="sortorder" required="no" type="any" default="DESC">
	    <cfargument name="sortby" required="no" type="any" default="CreatedDate">

      	<cfquery name="qgetEquipmentCsvImportLog" datasource="#Application.dsn#">
	        BEGIN WITH page AS 
	        (SELECT 
	          P.LogID
	          ,P.EquipmentName
	          ,P.RowData
	          ,P.Message
	          ,P.CreatedDate
	          ,P.Success
	          ,P.CreatedBy
	          ,ROW_NUMBER() OVER (ORDER BY #arguments.sortby# #arguments.sortorder#) AS Row
	        FROM EquipmentCsvImportLog P
	        WHERE  P.CompanyID = <cfqueryparam value="#session.CompanyID#" cfsqltype="varchar">
	        <cfif structKeyExists(arguments, "searchText") and len(trim(arguments.searchText))>
          		AND P.EquipmentName LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#arguments.searchText#%">
        	</cfif>
	        )
	        SELECT
	          *,(select (max(row)/30) + (CASE WHEN max(row)%30 <> 0 THEN 1 ELSE 0 END)  FROM page) AS TotalPages
	        FROM page
	        WHERE Row BETWEEN (<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.pageNo#"> - 1) * 30 + 1 AND <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.pageNo#"> * 30
	        END
    	</cfquery>

    	<cfreturn qgetEquipmentCsvImportLog>
  	</cffunction>

  	<cffunction name="getDriverEquipments" access="public" output="false" returntype="any">
		<cfargument name="driver" required="no" type="any">

		<cfquery name="qDriverEquipments" datasource="#variables.dsn#">
			select * from  Equipments where 
			driver=<cfqueryparam value="#arguments.driver#" cfsqltype="cf_sql_varchar">
		</cfquery>

		<cfreturn qDriverEquipments>
	</cffunction>

	<cffunction name="getEquipmentTruckTrailer" access="remote" output="yes" returntype="any" returnformat="json">
		<cfargument name="EquipmentType" required="yes" type="string">

		<cfquery name="qGet" datasource="#variables.dsn#">
			SELECT E.EquipmentID,E.EquipmentName,E.EquipmentType,RE.EquipmentName AS RelEquip FROM Equipments E
			LEFT JOIN Equipments RE on E.TruckTrailerOption = RE.EquipmentID
			WHERE E.CompanyID = <cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar">
			<cfif len(trim(arguments.EquipmentType))>
				AND E.EquipmentType = <cfqueryparam value="#arguments.EquipmentType#" cfsqltype="cf_sql_varchar">
			<cfelse>
				AND E.EquipmentType IS NOT NULL
			</cfif>
			ORDER BY E.EquipmentName
		</cfquery>
		<cfset var retArr = arrayNew(1)>
    	<cfset tempper = 0>
    	<cfloop query="qGet">
    		<cfset tempStruct = structNew()>
    		<cfset tempStruct["EquipmentID"] = qGet.EquipmentID>
    		<cfset tempStruct["EquipmentName"] = qGet.EquipmentName>
    		<cfset tempStruct["EquipmentType"] = qGet.EquipmentType>
    		<cfset tempStruct["RelEquip"] =  qGet.RelEquip>
    		<cfset arrayAppend(retArr, tempStruct)>
    	</cfloop>
    	<cfreturn retArr>
	</cffunction>

	<cffunction name="saveEquipmentPopup" access="remote" output="false" returntype="any" returnFormat="json">
		<cfargument name="fpEquipmentCode" type="string" required="yes" />
		<cfargument name="fpEquipmentType" type="string" required="yes" />
		<cfargument name="fpEquipmentName" type="string" required="yes" />
		<cfargument name="fpEquipmentLength" type="string" required="yes" />
		<cfargument name="fpEquipmentWidth" type="string" required="yes" />
		<cfargument name="fpEquipmentITSCode" type="string" required="yes" />
		<cfargument name="fpEquipmentDATCode" type="string" required="yes" />
		<cfargument name="fpEquipmentPECode" type="string" required="yes" />
		<cfargument name="fpEquipmentStatus" type="string" required="yes" />
		<cfargument name="fpEquipment123Code" type="string" required="yes" />
		<cfargument name="fpEquipmentDFCode" type="string" required="yes" />
		<cfargument name="fpEquipmentTraccar" type="string" required="yes" />
		<cfargument name="fpEquipmentTemperature" type="string" required="yes" />
		<cfargument name="fpEquipmentTempScale" type="string" required="yes" />
		<cfargument name="dsn" type="string" required="yes" />
		<cfargument name="CompanyID" type="string" required="yes" />
		<cfargument name="adminUserName" type="string" required="yes" />

		<cftry>
			<cfquery name="qGet" datasource="#arguments.dsn#">
	        	SELECT NEWID() AS EquipmentID
	      	</cfquery>
			<cfquery name="qIns" datasource="#arguments.dsn#">
				INSERT INTO Equipments(
					EquipmentID,
					EquipmentCode,
					EquipmentType,
					EquipmentName,
					Length,
					Width,
					ITSCode,
					TranscoreCode,
					PosteverywhereCode,
					IsActive,
					LoadboardCode,
					DirectFreightCode,
					TraccarUniqueID,
					Temperature,
					Temperaturescale,
					CreatedDateTime,
					LastModifiedDateTime,
					CreatedByIP,
					UpdatedByIP,
					GUID,
					CreatedBy,
					LastModifiedBy,
					CompanyID
					)
				VALUES(
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#qGet.EquipmentID#">
					,<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.fpEquipmentCode#">
					,<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.fpEquipmentType#">
					,<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.fpEquipmentName#">
					,<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.fpEquipmentLength#">
					,<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.fpEquipmentWidth#">
					,<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.fpEquipmentITSCode#">
					,<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.fpEquipmentDATCode#">
					,<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.fpEquipmentPECode#">
					,<cfqueryparam cfsqltype="cf_sql_bit" value="#arguments.fpEquipmentStatus#">
					,<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.fpEquipment123Code#">
					,<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.fpEquipmentDFCode#">
					,<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.fpEquipmentTraccar#">
					,<cfqueryparam cfsqltype="cf_sql_float" value="#arguments.fpEquipmentTemperature#"  null="#not len(arguments.fpEquipmentTemperature)#">
					,<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.fpEquipmentTempScale#">
					,getdate()
					,getdate()
					,<cfqueryparam cfsqltype="cf_sql_varchar" value="#cgi.REMOTE_ADDR#">
					,<cfqueryparam cfsqltype="cf_sql_varchar" value="#cgi.REMOTE_ADDR#">
	    			,<cfqueryparam cfsqltype="cf_sql_varchar" value="#cgi.HTTP_USER_AGENT#">
	    			,<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.adminUserName#">
	    			,<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.adminUserName#">
	    			,<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.CompanyID#">
				)
			</cfquery>
			<cfset response.success = 1>
      		<cfset response.id = qGet.EquipmentID>
      		<cfreturn response>
			<cfcatch type="any">
	        	<cfset response.success = 0>
	        	<cfreturn response>
	      	</cfcatch>
		</cftry>
	</cffunction>
</cfcomponent>