<cfcomponent output="false">	
<cffunction name="init" access="public" output="false" returntype="void">
		<cfargument name="dsn" type="string" required="yes" />
		<cfset variables.dsn = replaceNoCase(arguments.dsn, "Beta", "Live") />
</cffunction>
<!---Get Agent Information------->	
<cffunction name="getAllAgent" access="remote" returntype="any">
<cfargument name="agentid" required="no">
<cfargument name="sortorder" required="no" type="any">
<cfargument name="sortby" required="no" type="any">
	
	<CFSTOREDPROC PROCEDURE="USP_GetAgentDetails" DATASOURCE="#variables.dsn#"> 
		<cfif isdefined('arguments.agentid') and len(arguments.agentid)>
		 	<CFPROCPARAM VALUE="#arguments.agentid#" cfsqltype="CF_SQL_VARCHAR">  
		 <cfelse>
		 	<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR">  
		 </cfif>
		 <cfif structKeyExists(session, 'Manager') AND session.currentusertype EQ 'Manager'>
		 	<CFPROCPARAM VALUE="#session.officeid#" cfsqltype="CF_SQL_VARCHAR">  
		 <cfelse>
		 	<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR"> 
		 </cfif>
		 <CFPROCPARAM VALUE="#session.companyid#" cfsqltype="CF_SQL_VARCHAR"> 
		<CFPROCRESULT NAME="getAgent"> 
	</CFSTOREDPROC>
     <cfif isDefined("arguments.sortorder") and isDefined("arguments.sortby") and len(arguments.sortby)> 
          
       <cfquery datasource="#variables.dsn#" name="getnewAgent">
                   select Employees.* , Offices.Location,Roles.RoleValue from Employees
                   inner join Offices on Offices.OfficeID = Employees.OfficeID
                   inner join Roles on Roles.RoleID = Employees.RoleID
                   where 1=1 
				   <cfif session.currentusertype EQ 'Manager'>
						AND Offices.OfficeID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#session.OfficeID#"> 
				   </cfif>
				   AND Offices.CompanyID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#session.CompanyID#"> 
                   order by #arguments.sortby# #arguments.sortorder#;
       </cfquery>        
      <cfreturn getnewAgent>               
                   
     </cfif>
    
  <cfreturn getAgent>
</cffunction>
<!-----Insert Agent Information----->
<cffunction name="AddAgent" access="public" returntype="string">
	<cfargument name="formStruct" type="struct" required="no">
	<cfif isdefined("arguments.formStruct.integratewithTran360")>
	    <cfset integratewithTran360=True>
	<cfelse>
		<cfset integratewithTran360=False>
	</cfif>
	<cfif isdefined("arguments.formStruct.loadBoard123")>
	    <cfset loadBoard123=True>
	<cfelse>
		<cfset loadBoard123=False>
	</cfif>
	<cfif isdefined("arguments.formStruct.IntegrateWithDirectFreightLoadboard")>
	    <cfset IntegrateWithDirectFreightLoadboard=1>
	<cfelse>
		<cfset IntegrateWithDirectFreightLoadboard=0>
	</cfif>
	<cfset FA_TLS=False>
	<cfset FA_SSL=False>
	<cfif isdefined("arguments.formStruct.FA_SEC") and arguments.formStruct.FA_SEC eq "TLS">
		<cfset FA_TLS=True>
	</cfif>
	<cfif isdefined("arguments.formStruct.FA_SEC") and arguments.formStruct.FA_SEC eq "SSL">
		<cfset FA_SSL=True>
	</cfif>
	<cfif isdefined("arguments.formStruct.FA_smtpPort") and arguments.formStruct.FA_smtpPort eq "">
	    <cfset FA_port=0>
	<cfelse>
		<cfset FA_port=arguments.formStruct.FA_smtpPort>
	</cfif>

	<cfif isdefined("arguments.formStruct.LoadBoard123Default")>
	    <cfset LoadBoard123Default=1>
	<cfelse>
		<cfset LoadBoard123Default=0>
	</cfif>

	<cfif isdefined("arguments.formStruct.IntegrateWithTran360Default")>
	    <cfset IntegrateWithTran360Default=1>
	<cfelse>
		<cfset IntegrateWithTran360Default=0>
	</cfif>

	<cfif isdefined("arguments.formStruct.IntegrateWithDirectFreightLoadboardDefault")>
	    <cfset IntegrateWithDirectFreightLoadboardDefault=1>
	<cfelse>
		<cfset IntegrateWithDirectFreightLoadboardDefault=0>
	</cfif>

	<cfif isdefined("arguments.formStruct.integratewithITS")>
	    <cfset integratewithITS=True>
	<cfelse>
		<cfset integratewithITS=False>
	</cfif>

	<cfif isdefined("arguments.formStruct.integratewithPEP")>
	    <cfset integratewithPEP=True>
	<cfelse>
		<cfset integratewithPEP=False>
	</cfif>

	<cfif isdefined("arguments.formStruct.integratewithPEPDefault")>
	    <cfset integratewithPEPDefault=True>
	<cfelse>
		<cfset integratewithPEPDefault=False>
	</cfif>

	<cfif isdefined("arguments.formStruct.integratewithITSDefault")>
	    <cfset integratewithITSDefault=True>
	<cfelse>
		<cfset integratewithITSDefault=False>
	</cfif>
	<cfif isdefined("arguments.formStruct.DefaultSalesRepToLoad")>
	    <cfset DefaultSalesRepToLoad=1>
	<cfelse>
		<cfset DefaultSalesRepToLoad=0>
	</cfif>
	
	<cfif isdefined("arguments.formStruct.DefaultDispatcherToLoad")>
	    <cfset DefaultDispatcherToLoad=1>
	<cfelse>
		<cfset DefaultDispatcherToLoad=0>
	</cfif>

	<CFSTOREDPROC PROCEDURE="USP_InsertAgent" DATASOURCE="#variables.dsn#">
		<CFPROCPARAM cfsqltype="cf_sql_varchar" value="#arguments.formStruct.FA_name#">,
	  	<CFPROCPARAM cfsqltype="cf_sql_varchar" value="#arguments.formStruct.address#">,
		<CFPROCPARAM cfsqltype="cf_sql_varchar" value="#arguments.formStruct.city#">,
		<CFPROCPARAM cfsqltype="cf_sql_varchar" value="#arguments.formStruct.state#">,
		<CFPROCPARAM cfsqltype="cf_sql_varchar" value="#arguments.formStruct.Zipcode#">,
		<CFPROCPARAM cfsqltype="cf_sql_varchar" value="#arguments.formStruct.country#">,
		<CFPROCPARAM cfsqltype="cf_sql_varchar" value="#arguments.formStruct.tel#">,
		<cfif structKeyExists(arguments.formStruct, "telextension")>
			<CFPROCPARAM cfsqltype="cf_sql_varchar" value="#arguments.formStruct.telextension#">,
		<cfelse>
			,<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR"  null="Yes">	
		</cfif> 
		<CFPROCPARAM cfsqltype="cf_sql_varchar" value="#arguments.formStruct.cel#">,

		<cfif structKeyExists(arguments.formStruct, "celextension")>
		 	<CFPROCPARAM cfsqltype="cf_sql_varchar" value="#arguments.formStruct.celextension#">,
		<cfelse>
	        ,<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR"  null="Yes">	
	    </cfif> 
		<CFPROCPARAM cfsqltype="cf_sql_varchar" value="#arguments.formStruct.fax#">,
		<cfif structKeyExists(arguments.formStruct, "faxextension")>
		  	<CFPROCPARAM cfsqltype="cf_sql_varchar" value="#arguments.formStruct.faxextension#">,
		<cfelse>
	        ,<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR"  null="Yes">	
	    </cfif> 
		<CFPROCPARAM cfsqltype="cf_sql_varchar" value="#arguments.formStruct.emailSignature#">,
		<CFPROCPARAM cfsqltype="cf_sql_varchar" value="#arguments.formStruct.loginid#">,
		<CFPROCPARAM cfsqltype="cf_sql_varchar" value="#arguments.formStruct.FA_roleid#">,
		<CFPROCPARAM cfsqltype="cf_sql_varchar" value="#arguments.formStruct.FA_password#">,
		<CFPROCPARAM cfsqltype="cf_sql_date" value="#now()#">,
		<CFPROCPARAM cfsqltype="cf_sql_varchar" value="#session.adminUserName#">,
		<CFPROCPARAM cfsqltype="cf_sql_date" value="#Now()#">,
		<CFPROCPARAM cfsqltype="cf_sql_varchar" value="#session.adminUserName#">,
		<CFPROCPARAM cfsqltype="cf_sql_varchar" value="#arguments.formStruct.FA_isactive#">,
		<CFPROCPARAM cfsqltype="cf_sql_varchar" value="#cgi.REMOTE_ADDR#">,
		<CFPROCPARAM cfsqltype="cf_sql_date" value="#now()#">,
		<CFPROCPARAM cfsqltype="cf_sql_varchar" value="#arguments.formStruct.FA_email#">,
		<CFPROCPARAM cfsqltype="cf_sql_varchar" value="#arguments.formStruct.FA_office#">,
		<cfif arguments.formStruct.FA_commonrate contains '$'>
		  	<CFPROCPARAM cfsqltype="cf_sql_float" value="#val(right(arguments.formStruct.FA_commonrate,len(arguments.formStruct.FA_commonrate)-1))#">,
		<cfelse>
			<CFPROCPARAM cfsqltype="cf_sql_float" value="#val(arguments.formStruct.FA_commonrate)#">,
		</cfif>
	    <CFPROCPARAM cfsqltype="cf_sql_varchar" value="#cgi.REMOTE_ADDR#">, 
		<CFPROCPARAM value="#integratewithTran360#" cfsqltype="cf_sql_bit">,
		<CFPROCPARAM value="#arguments.formStruct.trans360Usename#" cfsqltype="cf_sql_varchar">,
		<CFPROCPARAM value="#arguments.formStruct.trans360Password#" cfsqltype="cf_sql_varchar">,
		<CFPROCPARAM value="#arguments.formStruct.FA_smtpAddress#"	cfsqltype="cf_sql_varchar">,
		<CFPROCPARAM value="#arguments.formStruct.FA_smtpUsername#"	cfsqltype="cf_sql_varchar">,
		<CFPROCPARAM value="#arguments.formStruct.FA_smtpPassword#"	cfsqltype="cf_sql_varchar">,
		<CFPROCPARAM value="#FA_port#"		cfsqltype="cf_sql_integer">,
		<CFPROCPARAM value="#FA_TLS#" cfsqltype="cf_sql_bit">,
		<CFPROCPARAM value="#FA_SSL#" cfsqltype="cf_sql_bit">,
		<CFPROCPARAM value="#loadBoard123#" cfsqltype="cf_sql_bit">,
		<CFPROCPARAM value="#arguments.formStruct.loadBoard123Usename#" cfsqltype="cf_sql_varchar">,
		<CFPROCPARAM value="#arguments.formStruct.loadBoard123Password#" cfsqltype="cf_sql_varchar">,
	  	<cfif structKeyExists(arguments.formStruct, "defaultCurrency")>
			<CFPROCPARAM value="#arguments.formStruct.defaultCurrency#" cfsqltype="cf_sql_integer" null="#YesNoFormat(not Len(arguments.formStruct.defaultCurrency))#">,
		<cfelse>
			<CFPROCPARAM VALUE="" cfsqltype="cf_sql_integer"  null="Yes">	
		</cfif>	  
		<cfif structKeyExists(arguments.formStruct, "PEPcustomerKey")>
		  	<CFPROCPARAM cfsqltype="cf_sql_varchar" value="#arguments.formStruct.PEPcustomerKey#">
		<cfelse>
	        <CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR"  null="Yes">	
	    </cfif> 
	    ,<CFPROCPARAM value="#IntegrateWithDirectFreightLoadboard#" cfsqltype="cf_sql_bit">
	    ,<CFPROCPARAM value="#arguments.formStruct.DirectFreightLoadboardUserName#" cfsqltype="cf_sql_varchar">
		,<CFPROCPARAM value="#arguments.formStruct.DirectFreightLoadboardPassword#" cfsqltype="cf_sql_varchar">
		,<CFPROCPARAM value="#LoadBoard123Default#" cfsqltype="cf_sql_bit">
		,<CFPROCPARAM value="#IntegrateWithTran360Default#" cfsqltype="cf_sql_bit">
		,<CFPROCPARAM value="#IntegrateWithDirectFreightLoadboardDefault#" cfsqltype="cf_sql_bit">
		,<CFPROCPARAM value="#integratewithITS#" cfsqltype="cf_sql_bit">
		,<CFPROCPARAM value="#integratewithITSDefault#" cfsqltype="cf_sql_bit">
		,<CFPROCPARAM value="#integratewithPEP#" cfsqltype="cf_sql_bit">
		,<CFPROCPARAM value="#integratewithPEPDefault#" cfsqltype="cf_sql_bit">
		,<CFPROCPARAM value="#DefaultSalesRepToLoad#" cfsqltype="cf_sql_bit">
		,<CFPROCPARAM value="#DefaultDispatcherToLoad#" cfsqltype="cf_sql_bit">
		<cfprocresult name="qLastInsertedAgent">
	</CFSTOREDPROC>

	<cfif isdefined('AsignedLoadType')>
	    <cfloop index="i" list="#arguments.formStruct.AsignedLoadType#">
			<cfset statusTypeIDforElements = Replace(i,'-','_','ALL')>
	        <cfquery name="qInsertAgentLoadType" datasource="#variables.dsn#">
	            INSERT INTO agentsLoadTypes(agentid,loadstatustypeid)
	            VALUES(
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#qLastInsertedAgent.LastInsertedEmployeeID#">,
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#i#">
				)
	        </cfquery>
	    </cfloop>
	</cfif>
	<cfreturn qLastInsertedAgent.LastInsertedEmployeeID>
</cffunction>
<cffunction name="getAttachedFiles" access="public" returntype="query">
	<cfargument name="linkedid" type="string">
	<cfargument name="fileType" type="string">

	<cfquery name="getFilesAttached" datasource="#variables.dsn#">
		select * from FileAttachments where linked_id=<cfqueryparam value="#arguments.linkedid#" cfsqltype="cf_sql_varchar"> and linked_to=<cfqueryparam value="#arguments.filetype#" cfsqltype="cf_sql_integer">
	</cfquery>		
		
	<cfreturn getFilesAttached>	
</cffunction>
<!-----Update Agent Information---->
<cffunction name="UpdateAgent" access="public" returntype="any">
	<cfargument name="formStruct" type="struct" required="yes">

	<cfif isdefined("arguments.formStruct.integratewithTran360")>
	    <cfset integratewithTran360=True>
	<cfelse>
		<cfset integratewithTran360=False>
	</cfif>
	<cfif isdefined("arguments.formStruct.loadBoard123")>
	    <cfset loadBoard123=True>
	<cfelse>
		<cfset loadBoard123=False>
	</cfif>
	<cfif isdefined("arguments.formStruct.IntegrateWithDirectFreightLoadboard")>
	    <cfset IntegrateWithDirectFreightLoadboard=1>
	<cfelse>
		<cfset IntegrateWithDirectFreightLoadboard=0>
	</cfif>
	<cfset FA_TLS=False>
	<cfset FA_SSL=False>
	<cfif isdefined("arguments.formStruct.FA_SEC") and arguments.formStruct.FA_SEC eq "TLS">
		<cfset FA_TLS=True>
	</cfif>
	<cfif isdefined("arguments.formStruct.FA_SEC") and arguments.formStruct.FA_SEC eq "SSL">
		<cfset FA_SSL=True>
	</cfif>

	<cfif isdefined("arguments.formStruct.FA_smtpPort") and arguments.formStruct.FA_smtpPort eq "">
	    <cfset FA_port=0>
	<cfelse>
		<cfset FA_port=arguments.formStruct.FA_smtpPort>
	</cfif>
		
	<cfif isdefined("arguments.formStruct.LoadBoard123Default")>
	    <cfset LoadBoard123Default=1>
	<cfelse>
		<cfset LoadBoard123Default=0>
	</cfif>

	<cfif isdefined("arguments.formStruct.IntegrateWithTran360Default")>
	    <cfset IntegrateWithTran360Default=1>
	<cfelse>
		<cfset IntegrateWithTran360Default=0>
	</cfif>

	<cfif isdefined("arguments.formStruct.IntegrateWithDirectFreightLoadboardDefault")>
	    <cfset IntegrateWithDirectFreightLoadboardDefault=1>
	<cfelse>
		<cfset IntegrateWithDirectFreightLoadboardDefault=0>
	</cfif>

	<cfif isdefined("arguments.formStruct.integratewithITS")>
	    <cfset integratewithITS=True>
	<cfelse>
		<cfset integratewithITS=False>
	</cfif>

	<cfif isdefined("arguments.formStruct.integratewithPEP")>
	    <cfset integratewithPEP=True>
	<cfelse>
		<cfset integratewithPEP=False>
	</cfif>

	<cfif isdefined("arguments.formStruct.integratewithPEPDefault")>
	    <cfset integratewithPEPDefault=True>
	<cfelse>
		<cfset integratewithPEPDefault=False>
	</cfif>

	<cfif isdefined("arguments.formStruct.integratewithITSDefault")>
	    <cfset integratewithITSDefault=True>
	<cfelse>
		<cfset integratewithITSDefault=False>
	</cfif>

	<cfif isdefined("arguments.formStruct.DefaultSalesRepToLoad")>
	    <cfset DefaultSalesRepToLoad=1>
	<cfelse>
		<cfset DefaultSalesRepToLoad=0>
	</cfif>
	
	<cfif isdefined("arguments.formStruct.DefaultDispatcherToLoad")>
	    <cfset DefaultDispatcherToLoad=1>
	<cfelse>
		<cfset DefaultDispatcherToLoad=0>
	</cfif>
	<CFSTOREDPROC PROCEDURE="USP_UpdateAgent" DATASOURCE="#variables.dsn#">
		<CFPROCPARAM cfsqltype="cf_sql_varchar" value="#arguments.formStruct.editid#">,
		<CFPROCPARAM cfsqltype="cf_sql_varchar" value="#arguments.formStruct.FA_name#">,
		<CFPROCPARAM cfsqltype="cf_sql_varchar" value="#arguments.formStruct.FA_roleid#">,
		<CFPROCPARAM cfsqltype="cf_sql_varchar" value="#arguments.formStruct.FA_password#">,
	  	<CFPROCPARAM cfsqltype="cf_sql_varchar" value="#arguments.formStruct.address#">,
		<CFPROCPARAM cfsqltype="cf_sql_varchar" value="#arguments.formStruct.city#">,
		<CFPROCPARAM cfsqltype="cf_sql_varchar" value="#arguments.formStruct.state#">,
		<CFPROCPARAM cfsqltype="cf_sql_varchar" value="#arguments.formStruct.Zipcode#">,
		<CFPROCPARAM cfsqltype="cf_sql_varchar" value="#arguments.formStruct.country#">,
		<CFPROCPARAM cfsqltype="cf_sql_varchar" value="#arguments.formStruct.tel#">,
		<cfif structKeyExists(arguments.formStruct, "telextension")>
			<CFPROCPARAM cfsqltype="cf_sql_varchar" value="#arguments.formStruct.telextension#">,
		<cfelse>
			,<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR"  null="Yes">	
		</cfif> 
		<CFPROCPARAM cfsqltype="cf_sql_varchar" value="#arguments.formStruct.cel#">,
		<cfif structKeyExists(arguments.formStruct, "celextension")>
		 	<CFPROCPARAM cfsqltype="cf_sql_varchar" value="#arguments.formStruct.celextension#">,
		<cfelse>
	        ,<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR"  null="Yes">	
	    </cfif> 
		<CFPROCPARAM cfsqltype="cf_sql_varchar" value="#arguments.formStruct.fax#">,
		<cfif structKeyExists(arguments.formStruct, "faxextension")>
		  	<CFPROCPARAM cfsqltype="cf_sql_varchar" value="#arguments.formStruct.faxextension#">,
		<cfelse>
	        ,<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR"  null="Yes">	
	    </cfif> 
	    <CFPROCPARAM cfsqltype="cf_sql_varchar" value="#arguments.formStruct.loginid#">,
		<CFPROCPARAM cfsqltype="cf_sql_varchar" value="#arguments.formStruct.emailSignature#">,
		<CFPROCPARAM cfsqltype="cf_sql_date" value="#now()#">,
		<CFPROCPARAM cfsqltype="cf_sql_varchar" value="#session.adminUserName#">,
		<CFPROCPARAM cfsqltype="cf_sql_varchar" value="#arguments.formStruct.FA_isactive#">,
		<CFPROCPARAM cfsqltype="cf_sql_varchar" value="#cgi.REMOTE_ADDR#">,
		<CFPROCPARAM cfsqltype="cf_sql_varchar" value="#arguments.formStruct.FA_email#">,
		<CFPROCPARAM cfsqltype="cf_sql_varchar" value="#arguments.formStruct.FA_office#">,
		<cfif arguments.formStruct.FA_commonrate contains '$'>
		  	<CFPROCPARAM cfsqltype="cf_sql_float" value="#val(right(arguments.formStruct.FA_commonrate,len(arguments.formStruct.FA_commonrate)-1))#">,
		<cfelse>
			<CFPROCPARAM cfsqltype="cf_sql_float" value="#val(arguments.formStruct.FA_commonrate)#">,
		</cfif>
	    <CFPROCPARAM cfsqltype="cf_sql_varchar" value="#cgi.REMOTE_ADDR#">, 
		<CFPROCPARAM value="#integratewithTran360#" cfsqltype="cf_sql_bit">,
		<CFPROCPARAM value="#arguments.formStruct.trans360Usename#" cfsqltype="cf_sql_varchar">,
		<CFPROCPARAM value="#arguments.formStruct.trans360Password#" cfsqltype="cf_sql_varchar">,
		<CFPROCPARAM value="#arguments.formStruct.integrationID#" cfsqltype="cf_sql_varchar">,
		<CFPROCPARAM value="#arguments.formStruct.FA_smtpAddress#"	cfsqltype="cf_sql_varchar">,
		<CFPROCPARAM value="#arguments.formStruct.FA_smtpUsername#"	cfsqltype="cf_sql_varchar">,
		<CFPROCPARAM value="#arguments.formStruct.FA_smtpPassword#"	cfsqltype="cf_sql_varchar">,
		<CFPROCPARAM value="#FA_port#"		cfsqltype="cf_sql_integer">,
		<CFPROCPARAM value="#FA_TLS#" cfsqltype="cf_sql_bit">,
		<CFPROCPARAM value="#FA_SSL#" cfsqltype="cf_sql_bit">,

		<CFPROCPARAM value="#loadBoard123#" cfsqltype="cf_sql_bit">,
		<CFPROCPARAM value="#arguments.formStruct.loadBoard123Usename#" cfsqltype="cf_sql_varchar">,
		<CFPROCPARAM value="#arguments.formStruct.loadBoard123Password#" cfsqltype="cf_sql_varchar">,
	  	<cfif structKeyExists(arguments.formStruct, "defaultCurrency")>
			<CFPROCPARAM value="#arguments.formStruct.defaultCurrency#" cfsqltype="cf_sql_integer" null="#YesNoFormat(not Len(arguments.formStruct.defaultCurrency))#">,
		<cfelse>
			<CFPROCPARAM VALUE="" cfsqltype="cf_sql_integer"  null="Yes">	
		</cfif>	  
		<cfif structKeyExists(arguments.formStruct, "PEPcustomerKey")>
		  	<CFPROCPARAM cfsqltype="cf_sql_varchar" value="#arguments.formStruct.PEPcustomerKey#">
		<cfelse>
	        <CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR"  null="Yes">	
	    </cfif> 
	    ,<CFPROCPARAM value="#IntegrateWithDirectFreightLoadboard#" cfsqltype="cf_sql_bit">
	    ,<CFPROCPARAM value="#arguments.formStruct.DirectFreightLoadboardUserName#" cfsqltype="cf_sql_varchar">
		,<CFPROCPARAM value="#arguments.formStruct.DirectFreightLoadboardPassword#" cfsqltype="cf_sql_varchar">
		,<CFPROCPARAM value="#LoadBoard123Default#" cfsqltype="cf_sql_bit">
		,<CFPROCPARAM value="#IntegrateWithTran360Default#" cfsqltype="cf_sql_bit">
		,<CFPROCPARAM value="#IntegrateWithDirectFreightLoadboardDefault#" cfsqltype="cf_sql_bit">
		,<CFPROCPARAM value="#integratewithITS#" cfsqltype="cf_sql_bit">
		,<CFPROCPARAM value="#integratewithITSDefault#" cfsqltype="cf_sql_bit">
		,<CFPROCPARAM value="#integratewithPEP#" cfsqltype="cf_sql_bit">
		,<CFPROCPARAM value="#integratewithPEPDefault#" cfsqltype="cf_sql_bit">
		,<CFPROCPARAM value="#DefaultSalesRepToLoad#" cfsqltype="cf_sql_bit">
		,<CFPROCPARAM value="#DefaultDispatcherToLoad#" cfsqltype="cf_sql_bit">
	</CFSTOREDPROC>
	<!--- insert AgentLoadTypes --->
	<cfquery name="delete" datasource="#variables.dsn#">
		DELETE FROM agentsLoadTypes
	    WHERE agentid=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.editid#">
	</cfquery>

	<cfif isdefined('AsignedLoadType')>
	    <cfloop index="i" list="#arguments.formStruct.AsignedLoadType#">
			<cfset statusTypeIDforElements = Replace(i,'-','_','ALL')>
	        <cfquery name="qInsertAgentLoadType" datasource="#variables.dsn#">
	            INSERT INTO agentsLoadTypes(agentid,loadstatustypeid)
	            VALUES(
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.editid#">,
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#i#">
				)
	        </cfquery>
	    </cfloop>
	</cfif>
	<cfreturn arguments.formStruct.editid>
</cffunction>

<cffunction name="quickUserStatusUpdate" access="remote" returnformat="plain">
	<cfargument name="dsn" required="yes" type="string"/>
	<cfargument name="agentid" required="yes" type="string"/>
	<cfargument name="action" required="yes" type="string"/>
	<cfargument name="checkedStatus" required="yes" type="string"/>
	<cfset variables.TheKey = 'NAMASKARAM'>
	<cfset local.dsn = Decrypt(ToString(ToBinary(arguments.dsn)), variables.TheKey)>
	<cftry>
		<cfif arguments.action eq 'insert'>
			<cfquery name="qInsertAgentLoadType" datasource="#local.dsn#">
	            INSERT INTO agentsLoadTypes(agentid,loadstatustypeid)
	            VALUES(
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.agentid#">,
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.checkedStatus#">
				)
	        </cfquery>
	     <cfelse>
	     	<cfquery name="qDeleteAgentLoadType" datasource="#local.dsn#">
	            DELETE FROM agentsLoadTypes 
	            WHERE 
	            agentid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.agentid#">
	            AND loadstatustypeid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.checkedStatus#">
	        </cfquery>
	     </cfif>
	    <cfreturn 1>
		<cfcatch><cfreturn 0></cfcatch>
	</cftry>
</cffunction>
<!----delete agent------>
<cffunction name="deleteAgent" access="public" returntype="any">
<cfargument name="agentid" required="yes">
	<cftry>
		<cfquery name="qryDelete" datasource="#variables.dsn#">
			 delete from Employees where  EmployeeID=<cfqueryparam value="#arguments.agentid#" cfsqltype="cf_sql_varchar">
		</cfquery>
		<cfreturn "User has been deleted successfully.">	
		<cfcatch type="any">
			<cfreturn "Deletion not allows because this user exists on Load and/or Customer profiles. Please set the user to INACTIVE in order to hide them from the system drop down lists.">
		</cfcatch>
	</cftry>
</cffunction>
<!---Get All offices--->
<cffunction name="getOffices" access="public" output="false" returntype="query">
	<cfargument name="officeID" required="no" type="any">
	<CFSTOREDPROC PROCEDURE="USP_GetOfficeDetails" DATASOURCE="#variables.dsn#"> 
		<cfif isdefined('arguments.officeID') and len(arguments.officeID)>
		 	<CFPROCPARAM VALUE="#arguments.officeID#" cfsqltype="CF_SQL_VARCHAR">  
		 <cfelse>
		 	<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR">  
		 </cfif>
		 <CFPROCPARAM VALUE="#session.companyid#" cfsqltype="CF_SQL_VARCHAR">  
		 <CFPROCRESULT NAME="qrygetoffices"> 
	</CFSTOREDPROC>
    <cfreturn qrygetoffices>
</cffunction>

<!---Get All Countries--->
<cffunction name="getAllCountries" access="public" output="false" returntype="query">
	<CFSTOREDPROC PROCEDURE="USP_GetcountryDetails" DATASOURCE="#variables.dsn#"> 
		 <CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR">  
		 <CFPROCRESULT NAME="qrygetcountries"> 
	</CFSTOREDPROC>	
    <cfreturn qrygetcountries>
</cffunction>
<!--- Get All States--->
<cffunction name="getAllStaes" access="public" output="false" returntype="query">
	<cfargument name="stateID" required="no" type="any">
	<CFSTOREDPROC PROCEDURE="USP_GetStateDetails" DATASOURCE="#variables.dsn#"> 
    	<cfif isdefined('arguments.stateID')>
			<CFPROCPARAM VALUE="#arguments.stateID#" cfsqltype="CF_SQL_VARCHAR">
		<cfelse>
			<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR">
        </cfif>
		 <CFPROCRESULT NAME="qrygetStates"> 
	</CFSTOREDPROC>
	 <cfreturn qrygetStates>   
</cffunction>
<!--- Get User Role--->
<cffunction name="getUserRoleByUserName" access="public" output="false" returntype="query">
	<cfargument name="userName" required="yes" type="any">
	<CFSTOREDPROC PROCEDURE="USP_GetUserRoleByUserName" DATASOURCE="#variables.dsn#"> 
		 <CFPROCPARAM VALUE="#userName#" cfsqltype="CF_SQL_VARCHAR">
		 <CFPROCRESULT NAME="qrygetStates">
	</CFSTOREDPROC>
	 <cfreturn qrygetStates>   
</cffunction>
<!---Get All Roles--->
<!--- Get Loggedin User Info--->
<cffunction name="GetUserInfoUserName" access="public" output="false" returntype="query">
	<cfargument name="userName" required="yes" type="any">
	<CFSTOREDPROC PROCEDURE="USP_GetUserInfoUserName" DATASOURCE="#variables.dsn#"> 
		 <CFPROCPARAM VALUE="#userName#" cfsqltype="CF_SQL_VARCHAR">
		 <CFPROCRESULT NAME="qrygetInfos">
	</CFSTOREDPROC>
	 <cfreturn qrygetInfos>
</cffunction>

<!--- Get Loggedin User Info--->
<cffunction name="GetUserInfo" access="public" output="false" returntype="query">
	<cfargument name="userName" required="yes" type="any">
	<cfargument name="CompanyCode" required="yes" type="any">

	<cfquery name="qUserInfo" datasource="#variables.dsn#">
		SELECT Employees.*,Roles.*,C.CompanyID FROM Employees
		INNER JOIN Roles ON Employees.RoleID = Roles.RoleID
		INNER JOIN Offices O ON O.OfficeID = Employees.OfficeID
		INNER JOIN Companies C ON C.CompanyID = O.CompanyID
		WHERE Employees.loginid = <cfqueryparam cfsqltype="cf_sql_varchar"  value="#arguments.userName#">
		AND C.companycode =<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.CompanyCode#" />
	</cfquery>

	<cfif not qUserInfo.recordcount>
		<cfquery name="qUserInfo" datasource="LoadmanagerAdmin">
			SELECT 
			'Administrator' AS RoleValue,
			E.ID AS EmployeeID,
			E.Name,
			R.userRights,
			R.EditableStatuses,
			C.CompanyID,
			1 AS LicenseTermsAccepted
			FROM GlobalUsers E
			INNER JOIN [#variables.dsn#].[dbo].[Companies] C ON C.CompanyCode = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.CompanyCode#" />
			INNER JOIN [#variables.dsn#].[dbo].[Roles] R ON R.RoleValue = 'Administrator' AND R.CompanyID = C.CompanyID
			WHERE E.loginid = <cfqueryparam cfsqltype="cf_sql_varchar"  value="#arguments.userName#">
		</cfquery>
	</cfif>
	<cfreturn qUserInfo>
</cffunction>
<!---Get All Roles--->
<cffunction name="getAllRole" access="public" output="false" returntype="query">
	<cfargument name="roleID" required="no" type="any">
    <cfquery name="qrygetRole" datasource="#variables.dsn#">
        select * from roles where companyid = '#session.companyid#'
		<cfif isdefined('arguments.roleID') and len(arguments.roleID)>
			and roleID  = <cfqueryparam value="#arguments.roleID#" cfsqltype="cf_sql_varchar">
		</cfif>	
    </cfquery>
    <cfreturn qrygetRole>
</cffunction>

<cffunction name="getRoles" access="public" returntype="query">
    <cfquery name="qGetRoles" datasource="#variables.dsn#">
       select RoleID,RoleValue from Roles where CompanyID = <cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar">
    </cfquery>
    <cfreturn qGetRoles>
</cffunction>

<cffunction  name="getSecurityParameters" access="public" returntype="query">
	<cfquery name="qSecurityParameters" datasource="#variables.dsn#">
      select Type,Category,Parameter,Description,ParameterID from SecurityParameter order by ParameterID
    </cfquery>
	<cfreturn qSecurityParameters>
</cffunction>
<cffunction  name="getLoadStatusType" access="public" returntype="query">
	<cfargument  name="CompanyID" required="yes" type="any">
	<cfquery name="qgetLoadStatusType" datasource="#variables.dsn#">
      select StatusText,StatusDescription from LoadStatusTypes where CompanyID = <cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar"> order by StatusOrder
    </cfquery>
	<cfreturn qgetLoadStatusType>
</cffunction>

<cffunction name="getRoleSecurityParameters" access="public" returntype="query">
	<cfargument name="RoleID" required="yes" type="any">	
  <cfquery name="qgetRoleSecurityParameters" datasource="#variables.dsn#">
     select EditableStatuses,userRights from Roles where RoleID = <cfqueryparam value="#arguments.RoleID#" cfsqltype="cf_sql_integer">
  </cfquery>
  <cfreturn qgetRoleSecurityParameters>
</cffunction>

<cffunction  name="UpdateUserRights" access="public" returntype="any">
	<cfargument name="securityParameter" type="any" required="yes" default=""/>
	<cfargument name="roleID" required="yes" type="any">	
	<cfargument name="checked" required="yes" type="any">	

	<cfquery name="qGet" datasource="#variables.dsn#">
		SELECT UserRights FROM Roles WHERE RoleID = <cfqueryparam value="#arguments.roleID#" cfsqltype="cf_sql_varchar">
	</cfquery>
	<cfset var listUserRights = qGet.UserRights>

	<cfif arguments.checked EQ 1>
		<cfset listUserRights =  listAppend(listUserRights, securityParameter)>
	<cfelse>
		<cfset var index = listFindNocase(listUserRights,securityParameter)>
		<cfif '#index#' NEQ 0>
			<cfset listUserRights =  listDeleteAt(listUserRights, index)>
		</cfif>
	</cfif>

	<cfquery name="qUpdateUserRights" datasource="#variables.dsn#">
		UPDATE Roles SET userRights = <cfqueryparam value="#listUserRights#" cfsqltype="cf_sql_varchar" null="#yesNoFormat(NOT len(listUserRights))#"> WHERE roleID = <cfqueryparam value="#arguments.roleID#" cfsqltype="cf_sql_varchar">
	</cfquery>
	<cfreturn 1>
</cffunction>

<cffunction  name="UpdateEditableStatus" access="public" returntype="any">
	<cfargument name="editableStatus" type="any" required="yes" default=""/>
	<cfargument name="roleID" required="yes" type="any">

	<cfset var status = arraytolist(deserializeJSON(arguments.editableStatus))>

	<cfquery name="qUpdateEditableStatus" datasource="#variables.dsn#">
		UPDATE Roles SET EditableStatuses = <cfqueryparam value="#status#" cfsqltype="cf_sql_varchar" null="#yesNoFormat(NOT len(status))#"> WHERE roleID = <cfqueryparam value="#arguments.roleID#" cfsqltype="cf_sql_varchar">
	</cfquery>
	<cfreturn 1>
</cffunction>
<!---Get All Dispatcher--->
<cffunction name="getAllDispatcher" access="public" output="false" returntype="query">
    <cfquery name="qrygetDispatcher" datasource="#variables.dsn#">
        select * from carriers where status = 1 and companyid = <cfqueryparam value="#session.companyid#" cfsqltype="cf_sql_varchar">
        ORDER BY CarrierName
    </cfquery>
    <cfreturn qrygetDispatcher>
</cffunction>
<!--- Get Search Agent --->
<cffunction name="getSearchedAgent" access="public" output="false" returntype="query">
	<cfargument name="searchText" required="yes" type="any">
	<CFSTOREDPROC PROCEDURE="searchAgent" DATASOURCE="#variables.dsn#"> 
		<cfif isdefined('arguments.searchText') and len(arguments.searchText)>
		 	<CFPROCPARAM VALUE="#arguments.searchText#" cfsqltype="CF_SQL_VARCHAR">  
		 <cfelse>
		 	<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR">  
		 </cfif>
		 <CFPROCPARAM VALUE="#session.companyid#" cfsqltype="CF_SQL_VARCHAR">  
		 <CFPROCRESULT NAME="QreturnSearch"> 
	</CFSTOREDPROC>
    <cfreturn QreturnSearch>
</cffunction>
<!---Get Sales Person with auth level---->
<cffunction name="getSalesPerson" access="remote" returntype="any">
 	<cfargument name="AuthLevelId" required="no">
	<cfquery name="getSalesperson" datasource="#variables.dsn#">
		 SELECT * FROM employees
		 INNER JOIN Roles ON Roles.RoleID = employees.RoleID
			INNER JOIN Offices ON Offices.OfficeID = Employees.OfficeID
	        WHERE 
	        (RoleValue IN (<cfqueryparam list="true" value="#arguments.AuthLevelId#">)
	        	OR RoleValue = 'Administrator')
	        AND employees.isActive = 'True'
	        AND Offices.CompanyID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#session.CompanyID#"> 
	        ORDER BY Name
	 </cfquery>
 <cfreturn getSalesperson>
</cffunction>


<cffunction name="getAgentsLoadStatusTypes" access="public" returntype="any">
<cfargument name="agentid" required="yes">
	<cfquery name="qAgentsLoadStatuses" datasource="#variables.dsn#">
		<cfif structKeyExists(session, "IsCustomer")>
			SELECT loadStatusTypeID
			FROM customers
			LEFT OUTER JOIN agentsLoadTypes ON customers.customerid = agentsLoadTypes.AgentID
			WHERE customerid = <cfqueryparam value="#session.customerid#" cfsqltype="cf_sql_varchar" null="#yesNoFormat(NOT len(trim(session.customerid)))#">
		<cfelse>
			SELECT loadStatusTypeID
			FROM employees
			LEFT OUTER JOIN agentsLoadTypes ON employees.employeeID = agentsLoadTypes.AgentID
			WHERE employeeID = <cfqueryparam value="#arguments.agentid#" cfsqltype="cf_sql_varchar" null="#yesNoFormat(NOT len(trim(arguments.agentid)))#">
		</cfif>
	 </cfquery>
 <cfreturn qAgentsLoadStatuses>
</cffunction>

<cffunction name="getAgentsLoadStatusTypesByLoginID" access="public" returntype="any">
<cfargument name="agentLoginId" required="yes">
	 <cfquery name="qAgentsLoadStatuses" datasource="#variables.dsn#">
		SELECT loadStatusTypeID
		FROM employees
		INNER JOIN Offices ON Offices.OfficeID = Employees.OfficeID
		LEFT OUTER JOIN agentsLoadTypes ON employees.employeeID = agentsLoadTypes.AgentID
		WHERE loginid = <cfqueryparam value="#agentLoginId#" cfsqltype="cf_sql_varchar">
		AND Offices.CompanyID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#session.CompanyID#"> 
	 </cfquery>
 <cfreturn qAgentsLoadStatuses>
</cffunction>


<cffunction name="verifyPEPLoginStatus" access="public" returntype="boolean">
	<cfargument name="PEPcustomerKey" type="string" required="yes" default="">

	<cftry>
		<cfset var isSuccess = true>

		<cfquery name="qSysOption" datasource="#variables.dsn#">
	        SELECT PEPsecretKey FROM SystemConfig WHERE companyid = <cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar">
	    </cfquery>

	    <cfoutput>
			<cfsavecontent variable="strXML">
				<PostLoads.Many>
					<LoadDO>
						<postAction>D</postAction>
						<importRef>TEST1234</importRef>
					</LoadDO>
				</PostLoads.Many>
			</cfsavecontent>
		</cfoutput>

		<cfhttp method="post" url="https://post.loadboardnetwork.com/api/xml/post-loads/" useragent="#CGI.http_user_agent#" result="objGet">
			<cfhttpparam type="HEADER" name="Content-Type" value="application/xml">
			<cfhttpparam type="url" name="ServiceKey" value="#qSysOption.PEPsecretKey#"/>
			<cfhttpparam type="url" name="CustomerKey"  value="#arguments.PEPcustomerKey#"/>
			<cfhttpparam type="url"  name="ServiceAction"  value="Many" />
			<cfhttpparam type="body" value="#strXML.Trim()#"/>
		</cfhttp>
		<cfif objGet.Statuscode EQ "201 Created">
			<cfset InvalidCredentials = findnocase("Invalid credentials",objGet.FileContent)>
			<cfif InvalidCredentials neq 0>
				<cfset isSuccess = false>
			<cfelse>
				<cfset isSuccess = true>
			</cfif>
		<cfelse>
			<cfset isSuccess = false>
		</cfif>
			<cfcatch type="any">
				<cfset isSuccess = false>
			</cfcatch>
	</cftry>
	<cfreturn isSuccess>
</cffunction>

<cffunction name="verifyDirectFreightLoginStatus" access="public" returntype="boolean">
	<cfargument name="DirectFreightLoadboardUserName" type="string" required="yes" default="">
	<cfargument name="DirectFreightLoadboardPassword" type="string" required="yes" default="">

	<cftry>
		<cfset var isSuccess = true>

		<cfset APIToken = "015f303e2c3c329b69ed06f21deaf6d2e1fab1c3">
		<!--- Login --->
		<cfset loginBody = structNew()>
		<cfset loginBody['login'] = arguments.DirectFreightLoadboardUserName>
		<cfset loginBody['realm'] = "email">
		<cfset loginBody['secret'] = arguments.DirectFreightLoadboardPassword>

		<cfhttp method="post" url="https://api.directfreight.com/v1/end_user_authentications/" result="DirectFreightLogin">
			<cfhttpparam type="header" name="Accept"  value="application/json" />
			<cfhttpparam type="header" name="Content-Type"  value="application/json" />
			<cfhttpparam type="header" name="api-token"  value="#APIToken#" />
			<cfhttpparam type="body"  value="#serializeJSON(loginBody)#" />
		</cfhttp>

		<cfif DirectFreightLogin.Statuscode EQ '201 Created'>
			<cfset isSuccess = true>
		<cfelse>
			<cfset isSuccess = false>
		</cfif>
		<cfcatch type="any">
			<cfset isSuccess = false>
		</cfcatch>
	</cftry>
	<cfreturn isSuccess>
</cffunction>

<cffunction name="verifyTrancoreLoginStatus" access="public" returntype="boolean">
	<cfargument name="tranUname" type="string" required="yes" default="">
	<cfargument name="tranPwd" type="string" required="yes" default="">
	
	<cfset var isSuccess = true>
	<cfset var TranscoreData360 = "">
	<cfset var tranLoginText = "">
	
	<cfsavecontent variable="soapHeaderTransCoreTxt">
	<cfoutput>
		<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:tcor="http://www.tcore.com/TcoreHeaders.xsd" xmlns:tcor1="http://www.tcore.com/TcoreTypes.xsd" xmlns:tfm="http://www.tcore.com/TfmiFreightMatching.xsd">
		  <soapenv:Header>
			  <tcor:sessionHeader soapenv:mustUnderstand="1">
				<tcor:sessionToken>
					<tcor1:primary></tcor1:primary>
					<tcor1:secondary></tcor1:secondary>
				</tcor:sessionToken>
			  </tcor:sessionHeader>
			  <tcor:correlationHeader soapenv:mustUnderstand="0">
			  </tcor:correlationHeader>
			  <tcor:applicationHeader soapenv:mustUnderstand="0">
				<tcor:application>TFMI</tcor:application>
				<tcor:applicationVersion>1</tcor:applicationVersion>
			  </tcor:applicationHeader>
		  </soapenv:Header>
		  <soapenv:Body>
			  <tfm:loginRequest>
				<tfm:loginOperation>
					<tfm:loginId>#arguments.tranUname#</tfm:loginId>
					<tfm:password>#arguments.tranPwd#</tfm:password>
					<tfm:thirdPartyId>TFMI</tfm:thirdPartyId>
					<tfm:apiVersion>2</tfm:apiVersion>
				</tfm:loginOperation>
			  </tfm:loginRequest>
		  </soapenv:Body>
		</soapenv:Envelope>
	</cfoutput>
	</cfsavecontent>
	
	<cftry>
		
<!--- LIVE URL --->		
  		<cfhttp method="post" url="http://www.transcoreservices.com:8000/TfmiRequest" result="TranscoreData360">
			<cfhttpparam type="xml"  value="#trim( soapHeaderTransCoreTxt )#" /> 
		</cfhttp>
		
		<cfset TranscoreData360 = xmlparse(TranscoreData360.filecontent)>
		<cfset tranLoginText = TranscoreData360['soapenv:Envelope']['soapenv:Body']['XmlChildren'][1]['XmlChildren'][1]['XmlChildren'][1]['XmlName']>
			
		<cfif tranLoginText.contains('Error') or tranLoginText.contains('error')>
			<cfset isSuccess = false>
		<cfelse>
			<cfset arr_primary		= XmlSearch(TranscoreData360,"//*[name()='tcor:primary']")>
			<cfset arr_secondary	= XmlSearch(TranscoreData360,"//*[name()='tcor:secondary']")>
			<cfset timesession_exp	= XmlSearch(TranscoreData360,"//*[name()='tfm:expiration']")>

			<cfif arrayLen(arr_primary) AND arrayLen(arr_secondary) AND arrayLen(timesession_exp)>
				<cfquery name="qUpdTranscoreSession" datasource="#variables.dsn#">
					Update Employees
					SET transcorePrimaryKey=<cfqueryparam cfsqltype="cf_sql_varchar"value="#arr_primary[1].XmlText#">
						,transcoreSecondaryKey=<cfqueryparam cfsqltype="cf_sql_varchar"value="#arr_secondary[1].XmlText#">
						,transcoreTimeSessionExp=<cfqueryparam cfsqltype="cf_sql_timestamp" value="#replaceNoCase(replaceNoCase(timesession_exp[1].XMLText, "T", " "), "Z", "")#">
					where trans360Usename = <cfqueryparam cfsqltype="cf_sql_varchar"value="#arguments.tranUname#"> and trans360Password=<cfqueryparam cfsqltype="cf_sql_varchar"value="#arguments.tranPwd#">
				</cfquery>
			</cfif>
		</cfif>
		
		<cfcatch type="any">
			<cfset isSuccess = false>
		</cfcatch>
	</cftry>
	
	<cfreturn isSuccess>

</cffunction>
			

<cffunction name="verifyMailServer" returntype="struct" access="public" output="true">
    <cfargument name="protocol" type="string" required="true" hint="Mail protocol: SMTP, POP3 or IMAP" />
    <cfargument name="host" type="string" required="true" hint="Mail server name (Example: pop.gmail.com)"/>
    <cfargument name="port" type="numeric" default="-1" hint="Mail server port number. Default is -1, meaning use the default port for this protocol)" />
    <cfargument name="user" type="string" required="true" hint="Mail account username" />
    <cfargument name="password" type="string" required="true" hint="Mail account password" />
    <cfargument name="useSSL" type="boolean" default="false" hint="If true, use SSL (Secure Sockets Layer)" >
    <cfargument name="useTLS" type="boolean" default="false" hint="If true, use TLS (Transport Level Security)" >
    <cfargument name="enforceTLS" type="boolean" default="false" hint="If true, require TLS support" >
    <cfargument name="timeout" type="numeric" default="0" hint="Maximum milliseconds to wait for connection. Default is 0 (wait forever)" />
    <cfargument name="debug" type="boolean" default="false" hint="If true, enable debugging. By default information is sent to is sent to System.out." >
    <cfargument name="logPath" type="string" default="" hint="Send debugging output to this file. Absolute file path. Has no effect if debugging is disabled." >
    <cfargument name="append" type="boolean" default="true" hint="If false, the existing log file will be overwritten" >
		
    <cfset var status         = structNew() />
    <cfset var props         = "" />
    <cfset var mailSession     = "" />
    <cfset var store         = "" />
    <cfset var transport    = "" />
    <cfset var logFile        = "" />
    <cfset var fos             = "" />
    <cfset var ps             = "" />
    
    <!--- validate protocol --->
    <cfset arguments.protocol = lcase( trim(arguments.protocol) ) />
    <cfif not listFindNocase("pop3,smtp,imap", arguments.protocol)>
        <cfthrow type="IllegalArgument" message="Invalid protocol. Allowed values: POP3, IMAP and SMTP" />
    </cfif>
    
    <cfscript>
		// initialize status messages
		status.wasVerified		= false;
		status.errorType		= "";
		status.errorDetail		= "";

      try {
      	if (not arguments.useSSL and not arguments.useTLS) {
      		return status;
      	}
		props = createObject("java", "java.util.Properties").init();
		
		// enable securty settings
		if (arguments.useSSL or arguments.useTLS) {
			// use the secure protocol
			// this will set the property mail.{protocol}.ssl.enable = true
			if (arguments.useSSL) {
				arguments.protocol = arguments.protocol &"s";
				props.put("mail.user", arguments.user);
				props.put("mail.password", arguments.password);
			}
			// enable identity check
			//props.put("mail."& protocol &".ssl.checkserveridentity", "true");
		
			// enable transport level security and make it mandatory
			// so the connection fails if TLS is not supported
			if (arguments.useTLS) {
				//props.put("mail."& protocol &".starttls.required", "true");
				props.put("mail."& protocol &".starttls.enable", "true");
			}
		
			props.put("mail."& protocol &".host", arguments.host);
			props.put("mail."& protocol &".port", arguments.port);
		}
		
		// force authentication command
		props.put("mail."& protocol &".auth", "true");
		
		// for simple verifications, apply timeout to both socket connection and I/O
		if (structKeyExists(arguments, "timeout")) {
			props.put("mail."& protocol &".connectiontimeout", arguments.timeout);
			props.put("mail."& protocol &".timeout", arguments.timeout);
		}
		
		// create a new mail session 
		mailSession = createObject("java", "javax.mail.Session").getInstance( props );
		// enable debugging
		if (arguments.debug) {
			mailSession.setDebug( true );

			// redirect the output to the given log file
			if ( len(trim(arguments.logPath)) ) {
				logFile = createObject("java", "java.io.File").init( arguments.logPath );
				fos      = createObject("java", "java.io.FileOutputStream").init( logFile, arguments.overwrite );
				ps       = createObject("java", "java.io.PrintStream").init( fos );
				mailSession.setDebugOut( ps );
			}
		}
		
		// Connect to an SMTP server ... 
		if ( left(arguments.protocol, 4) eq "smtp") {
			transport = mailSession.getTransport( protocol );
			transport.connect(arguments.host, arguments.port, arguments.user, arguments.password);
			transport.close();
			// if we reached here, the credentials should be verified
			status.wasVerified     = true;
		}
		
		// Otherwise, it is a POP3 or IMAP server
		else {

			store = mailSession.getStore( protocol );
			store.connect(arguments.host, arguments.port, arguments.user, arguments.password);
			store.close();
			// if we reached here, the credentials should be verified
			status.wasVerified     = true;
		}
	  }
	 //for authentication failures
	 catch(javax.mail.AuthenticationFailedException e) {
			   status.errorType     = "Authentication";
			 status.errorDetail     = e;
		}
	 // some other failure occurred like a javax.mail.MessagingException
	 catch(Any e) {
			 status.errorType     = "Other";
			 status.errorDetail     = e;
	 }



	 // always close the stream ( messy work-around for lack of finally clause prior to CF9...)
	 if ( not IsSimpleValue(ps) ) {
		   ps.close();
	 }

        return status;
    </cfscript>
</cffunction>
	<!---function to get editing User Name--->
	<cffunction name="getEditingUserName" access="public" returntype="any">
		<cfargument name="employeID" required="yes">
		<!---Query to get editing User Name--->
		 <cfquery name="qryGetEditingUserName" datasource="#variables.dsn#">
			SELECT NAME
			FROM employees
			WHERE employeeID = <cfqueryparam value="#arguments.employeID#" cfsqltype="cf_sql_varchar">
			UNION
			SELECT NAME + ' (Global User)' AS NAME
			FROM [LoadmanagerAdmin].[dbo].[GlobalUsers]
			WHERE ID = <cfqueryparam value="#arguments.employeID#" cfsqltype="cf_sql_varchar"> 
		 </cfquery>
		<cfreturn qryGetEditingUserName>
	</cffunction>
	<!---function to get roleid--->
	<cffunction name="getRoleid" access="public" returntype="any">
		<cfargument name="employeID" required="yes">
		<!---Query to get roleid--->
		 <cfquery name="qryGetRoleid" datasource="#variables.dsn#">
			SELECT roleid
			FROM employees
			WHERE employeeID = <cfqueryparam value="#arguments.employeID#" cfsqltype="cf_sql_varchar">
		 </cfquery>
		<cfreturn qryGetRoleid>
	</cffunction>

	<!--- lock functions begins --->

	<!---function to get the user editing details for corresponding agent --->
	<cffunction name="getUserEditingDetails" access="public" returntype="query">
		<cfargument name="agentid" type="string" required="yes"/>

		<!---Query to get the user editing details for corresponding agent--->
		<cfquery name="qryUpdateEditingUserId" datasource="#Application.dsn#">
			SELECT  InUseBy,InUseOn
			FROM Employees
			WHERE EmployeeID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.agentid#">
		</cfquery>

		<cfreturn qryUpdateEditingUserId>
	</cffunction>

	<!---function to update the userid for corresponding agents--->
	<cffunction name="removeUserAccessOnAgent" access="remote" returntype="struct" returnformat="json">
		<cfargument name="dsn" type="string" required="yes"/>
		<cfargument name="agentid" type="string" required="yes"/>
		<cfset var agents=StructNew()>

		<!---Query to get the userid--->
		<cfquery name="qryGetUserId" datasource="#arguments.dsn#" result="result">
			SELECT InUseBy,InUseOn,EmployeeCode
			FROM Employees
			WHERE EmployeeID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.agentid#">
		</cfquery>

		<!-- Return if lock already removed-->
		<cfif len(trim(qryGetUserId.InUseBy)) eq 0>
			<cfset agents.msg = "No Lock Exist!" />
			<cfreturn agents>
		</cfif> 

		<!---Query to get editing User Name--->
		<cfquery name="qryGetUserName" datasource="#arguments.dsn#" result="result">
			SELECT NAME
			FROM employees
			WHERE employeeID = <cfqueryparam value="#qryGetUserId.inuseby#" cfsqltype="cf_sql_varchar">
		</cfquery>

		<cfset agents.userName = qryGetUserName.NAME>
		<cfset agents.onDateTime = dateformat(qryGetUserId.InUseOn,"mm/dd/yy hh:mm:ss")>
		<cfset agents.dsn = arguments.dsn>
		
		<!---Query to update the userid for corresponding loads to null--->
		<cfquery name="qryUpdateEditingUserId" datasource="#arguments.dsn#" result="result">
			UPDATE Employees
			SET
			InUseBy=null,
			InUseOn=null
			WHERE EmployeeId = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.agentid#">
		</cfquery>
		<cfreturn agents>
	</cffunction>

	<!---function to update the userid for corresponding agent--->
	<cffunction name="updateEditingUserId" access="public" returntype="void">
		<cfargument name="userid" type="string" required="yes"/>
		<cfargument name="agentid" type="string" required="yes"/>
		<cfargument name="status" type="boolean" required="yes"/>
		
		<cfif  arguments.status>
			<!---Query to update the userid for corresponding agent to null--->
			<cfquery name="qryUpdateEditingUserId" datasource="#Application.dsn#" result="result">
				UPDATE Employees
				SET
				InUseBy=null,
				InUseOn=null,
				sessionid=null
				where InUseBy=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.userid#">
			</cfquery>
		<cfelse>
			<!---Query to update the userid for corresponding Agent--->
			<cfquery name="qryUpdateEditingUserId" datasource="#Application.dsn#" result="result">
				UPDATE Employees
				SET
				InUseBy=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.userid#">,
				InUseOn=<cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">,
				sessionid=<cfqueryparam cfsqltype="cf_sql_varchar" value="#session.sessionid#">
				where EmployeeID=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.agentid#">
			</cfquery>
		</cfif>
	</cffunction>

	<!---function to insert UserBrowserTabDetails--->
	<cffunction name="insertTabDetails" access="remote" output="yes" returnformat="json">
		<cfargument name="tabID" type="any" required="yes">
		<cfargument name="agentid" type="any" required="yes">
		<cfargument name="sessionid" type="any" required="yes">
		<cfargument name="userid" type="any" required="yes">
		<cfargument name="dsn" type="any" required="yes">

		<!---query to select UserBrowserTabDetails--->
		<cfquery name="qryGetBrowserTabDetails" datasource="#arguments.dsn#">
			SELECT * 
			FROM  UserBrowserTabDetails
			WHERE 1=1
			AND agentid = <cfqueryparam value="#arguments.agentid#" cfsqltype="cf_sql_varchar">
			AND sessionid = <cfqueryparam value="#arguments.sessionid#" cfsqltype="cf_sql_varchar">
			AND userid = <cfqueryparam value="#arguments.userid#" cfsqltype="cf_sql_varchar">
			AND tabID = <cfqueryparam value="#arguments.tabID#" cfsqltype="cf_sql_varchar">
		</cfquery>

		<cfif not qryGetBrowserTabDetails .recordcount>
			<!---Query to insert UserBrowserTabDetails--->
			<cfquery name="qryInsertGetBrowserTabDetails" datasource="#arguments.dsn#">
				INSERT INTO UserBrowserTabDetails (userid, agentid, tabid, sessionid, createddate)
	            VALUES (<cfqueryparam value="#arguments.userid#" cfsqltype="cf_sql_varchar">,
						<cfqueryparam value="#arguments.agentid#" cfsqltype="cf_sql_varchar">,
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
		<cfargument name="agentid" type="any" required="yes">
		<!---query to delete UserBrowserTabDetails--->
		<cfquery name="qryGetBrowserTabDetails" datasource="#arguments.dsn#">
			DELETE FROM  UserBrowserTabDetails
			WHERE
			 	sessionid=<cfqueryparam value = "#arguments.sessionid#" cfsqltype="cf_sql_varchar">
			AND userid=<cfqueryparam value = "#arguments.userid#" cfsqltype="cf_sql_varchar">
			AND tabID=<cfqueryparam value = "#arguments.tabID#" cfsqltype="cf_sql_varchar">
			AND agentid=<cfqueryparam value = "#arguments.agentid#" cfsqltype="cf_sql_varchar">
		</cfquery>
	</cffunction>


	<!--- Get Session Ajax version--->
	<cffunction name="getAjaxSession" access="remote" output="yes" returnformat="json">
		<cfargument name="UnlockStatus" type="any" required="no">
		<cfargument name="agentid" type="any" required="no">
		<cfargument name="dsn" type="any" required="no">
		<cfargument name="sessionid" type="any" required="no">
		<cfargument name="userid" type="any" required="no">
		<cfargument name="tabid" type="any" required="no">
		<cfargument name="saveEvent" type="any" required="no" default="false">

		<cfif structkeyexists(arguments,"tabid")>
			<!----query to delete -corresponding rows of tabid--->
			<cfquery name="qryGetBrowserTabDetails" datasource="#arguments.dsn#">
				DELETE FROM  UserBrowserTabDetails
				WHERE tabID=<cfqueryparam value="#arguments.tabid#" cfsqltype="cf_sql_varchar">
			</cfquery>
		</cfif>
	
		
		<cfif structkeyexists(arguments,"UnlockStatus") 
			  and structkeyexists(arguments,"agentid")
			  and arguments.UnlockStatus eq false
			  and len(trim(arguments.agentid)) gt 1
			  and structkeyexists(arguments,"dsn")
			  and structkeyexists(arguments,"sessionid")
			  and structkeyexists(arguments,"userid")
			  and arguments.saveevent neq "true">

			<!---Query to select browser tab details--->
			<cfquery name="qryGetBrowsertabDetails" datasource="#arguments.dsn#">
				SELECT id 
				FROM UserBrowserTabDetails
				WHERE
					agentid=<cfqueryparam value="#arguments.agentid#" cfsqltype="cf_sql_varchar">
				AND sessionid=<cfqueryparam value="#arguments.sessionid#" cfsqltype="cf_sql_varchar">
				AND userid=<cfqueryparam value="#arguments.userid#" cfsqltype="cf_sql_varchar">
			</cfquery>
			

			<cfif not qryGetBrowsertabDetails.recordcount>
				<!---Query to remove lock --->
				<cfquery name="qryGetInuseBy" datasource="#arguments.dsn#">
					UPDATE Employees
					SET
						InUseBy=null,
						InUseOn=null,
						sessionId=null
					WHERE employeeid=<cfqueryparam value="#arguments.agentid#" cfsqltype="cf_sql_varchar">
					AND InUseBy = <cfqueryparam value="#arguments.userid#" cfsqltype="cf_sql_varchar">
				</cfquery>
			</cfif>
		</cfif>
	 
	</cffunction>
	<!--- lock functions ends --->

	<cffunction name="validateAndUpdateSMTP" access="remote" returntype="any">
		<cfargument name="login" required="no" type="string">
		<cfargument name="password" required="no" type="string">
		<cfargument name="CompanyCode" required="no" type="string">
		<cfargument name="dsn" required="no" type="string">

		<cfquery name="qgetEmployeeSmtpDetails" datasource="#arguments.dsn#">
			select employees.EmailID,SmtpAddress,SmtpUsername,SmtpPassword,SmtpPort,useSSL,useTLS,EmailValidated
			from employees 
			inner join offices on offices.officeid = employees.officeid
			inner join companies on companies.companyid = offices.companyid
			where loginid = <cfqueryparam value="#arguments.login#" cfsqltype="cf_sql_varchar">
			AND password = <cfqueryparam value="#arguments.password#" cfsqltype="cf_sql_varchar">
			AND companycode = <cfqueryparam value="#arguments.CompanyCode#" cfsqltype="cf_sql_varchar">
		</cfquery>

		<cfif qgetEmployeeSmtpDetails.EmailValidated EQ 0>
			<cfreturn 1>
		</cfif>

		<cfif qgetEmployeeSmtpDetails.recordcount and len(trim(qgetEmployeeSmtpDetails.EmailID)) and len(trim(qgetEmployeeSmtpDetails.SmtpAddress)) and len(trim(qgetEmployeeSmtpDetails.SmtpUsername)) and len(trim(qgetEmployeeSmtpDetails.SmtpPassword)) and len(trim(qgetEmployeeSmtpDetails.SmtpPort))>
			<cfinvoke method="verifyMailServer" returnvariable="smtpStatus">
				<cfinvokeargument name="host" value="#qgetEmployeeSmtpDetails.SmtpAddress#">
				<cfinvokeargument name="protocol" value="smtp">
				<cfinvokeargument name="port" value=#qgetEmployeeSmtpDetails.SmtpPort#>
				<cfinvokeargument name="user" value="#qgetEmployeeSmtpDetails.SmtpUsername#">
				<cfinvokeargument name="password" value="#qgetEmployeeSmtpDetails.SmtpPassword#">
				<cfinvokeargument name="useTLS" value=#qgetEmployeeSmtpDetails.useTLS#>
				<cfinvokeargument name="useSSL" value=#qgetEmployeeSmtpDetails.useSSL#>
				<cfinvokeargument name="overwrite" value=false>
				<cfinvokeargument name="timeout" value=10000>
			</cfinvoke>
		
			<cfif NOT smtpStatus.WASVERIFIED>
				<cfreturn 0>
			<cfelse>
				<cfreturn 1>
			</cfif>
		</cfif>
		<cfreturn 1>
	</cffunction>

	<cffunction name="SaveUserCookie" access="public" output="false">
		<cfargument name="Cookie" required="yes" type="any">

		<cfquery name="qSaveCOokie" datasource="#variables.dsn#">
			INSERT INTO [dbo].[UserCookies] ([Cookie]) VALUES (<cfqueryparam cfsqltype="cf_sql_varchar"  value="#arguments.Cookie#">)
		</cfquery>
	</cffunction>

	<cffunction name="LicenseTermsAccept" access="public" output="false">
		<cfquery name="qLicenseTermsAccept" datasource="#variables.dsn#">
			UPDATE Employees SET 
			LicenseTermsAccepted = 1,
			LicenseTermsAcceptedDateTime = getdate(),
			LicenseTermsAcceptedIP = <cfqueryparam cfsqltype="cf_sql_varchar" value="#cgi.REMOTE_ADDR#">,
			LicenseTermsAcceptedName = <cfqueryparam cfsqltype="cf_sql_varchar" value="#session.adminUserName#"> +  RIGHT(CONVERT(VARCHAR, GETDATE(), 100),7)
			WHERE EmployeeID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#session.empid#">
		</cfquery>
	</cffunction>

	<cffunction name="updateNotes" access="remote" returntype="boolean">
		<cfargument name="EmployeeID" required="yes" type="string">
		<cfargument name="Notes" required="yes" type="string">
		<cfargument name="CompanyID" required="yes" type="string">
		<cfargument name="dsn" required="yes" type="string">

		<cftry>
			<cfquery name="qUpdNotes" datasource="#arguments.dsn#">
				UPDATE Employees 
				SET Notes = <cfqueryparam value="#arguments.Notes#" cfsqltype="cf_sql_varchar">
				WHERE EmployeeID = <cfqueryparam value="#arguments.EmployeeID#" cfsqltype="cf_sql_varchar">
				AND OfficeID IN (SELECT OfficeID FROM Offices WHERE CompanyID = <cfqueryparam value="#arguments.CompanyID#" cfsqltype="cf_sql_varchar">)
			</cfquery>
			<cfreturn 1>
			<cfcatch>
				<cfreturn 0>
			</cfcatch>
		</cftry>
	</cffunction>

	<cffunction name="updateCustomerNotes" access="remote" returntype="boolean">
		<cfargument name="CustomerID" required="yes" type="string">
		<cfargument name="Notes" required="yes" type="string">
		<cfargument name="CompanyID" required="yes" type="string">
		<cfargument name="dsn" required="yes" type="string">

		<cftry>
			<cfquery name="qUpdNotes" datasource="#arguments.dsn#">
				UPDATE Customers 
				SET Notes = <cfqueryparam value="#arguments.Notes#" cfsqltype="cf_sql_varchar">
				WHERE CustomerID = <cfqueryparam value="#arguments.CustomerID#" cfsqltype="cf_sql_varchar">
			</cfquery>
			<cfreturn 1>
			<cfcatch>
				<cfreturn 0>
			</cfcatch>
		</cftry>
	</cffunction>

	<cffunction name="checkAgentCompany" access="public" returntype="boolean">
		<cfargument name="agentid" required="yes" type="string">

		<cfquery name="qCheckAgentCompany" datasource="#variables.dsn#">
			select E.EmployeeID from Employees  E
			inner join offices o on o.OfficeID = e.OfficeID
			where E.EmployeeID = <cfqueryparam value="#arguments.agentid#" cfsqltype="cf_sql_varchar">
			AND o.CompanyID = <cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar">
		</cfquery>

		<cfif qCheckAgentCompany.recordcount>
			<cfreturn 1>
		<cfelse>
			<cfreturn 0>
		</cfif>
	</cffunction>

	<cffunction name="checkUserLoginActive" access="public" returntype="boolean">
		<cftry>
			<cfif structkeyexists(session,"empid") and len(session.empid) and structKeyExists(Session, "useruniqueid") and len(Session.useruniqueid)>
				<cfquery name="qGetActiveUsers" datasource="#Application.dsn#" >
					SELECT * FROM  userCountCheck 
					WHERE cutomerId = <cfqueryparam cfsqltype="cf_sql_varchar" value="#Session.empid#">
					AND useruniqueid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#Session.useruniqueid#">
				</cfquery>

				<cfif qGetActiveUsers.recordcount>
					<cfreturn 1>
				<cfelse>
					<cfreturn 0>
				</cfif>
			</cfif>

			<cfcatch>
				<cfreturn 0>
			</cfcatch>
		</cftry>
		<cfquery name="qCheckAgentCompany" datasource="#variables.dsn#">
			select E.EmployeeID from Employees  E
			inner join offices o on o.OfficeID = e.OfficeID
			where E.EmployeeID = <cfqueryparam value="#Session.empid#" cfsqltype="cf_sql_varchar">
			AND o.CompanyID = <cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar">
		</cfquery>

		<cfif qCheckAgentCompany.recordcount>
			<cfreturn 1>
		<cfelse>
			<cfreturn 0>
		</cfif>
	</cffunction>

	<cffunction name="AddCityStateRecord" access="public" returntype="struct" returnformat="json">
		<cfargument name="frmStruct" required="yes" type="struct">
		<cftry>
			<cfquery name="qCheckRecord" datasource="#variables.dsn#">
				SELECT COUNT(*) AS rCount FROM PostalCode WHERE City = <cfqueryparam value="#arguments.frmStruct.City#" cfsqltype="cf_sql_varchar"> AND StateCode = <cfqueryparam value="#arguments.frmStruct.State#" cfsqltype="cf_sql_varchar">
			</cfquery>

			<cfif qCheckRecord.rCount>
				<cfset respStr = structNew()>
		    	<cfset respStr.res = 'error'>
		    	<cfset respStr.msg = "City already exists.">
		    	<cfreturn respStr>
			<cfelse>
				<cfquery name="qIns" datasource="#variables.dsn#">
					INSERT INTO PostalCode VALUES(
						'0',
						<cfqueryparam value="#arguments.frmStruct.City#" cfsqltype="cf_sql_varchar">,
						<cfqueryparam value="#arguments.frmStruct.State#" cfsqltype="cf_sql_varchar">,
						'US'
						)
				</cfquery>
				<cfset respStr = structNew()>
		    	<cfset respStr.res = 'success'>
		    	<cfset respStr.msg = "City added successfully.">
		    	<cfreturn respStr>
			</cfif>
			<cfcatch>
				<cfset CreateLogError(cfcatch)>
				<cfset respStr = structNew()>
		    	<cfset respStr.res = 'error'>
		    	<cfset respStr.msg = "Something went wrong. Unable to add.">
				<cfreturn respStr>
			</cfcatch>
		</cftry>
	</cffunction>

	<cffunction name="CreateLogError" access="public" returntype="void">
		<cfargument name="Exception" type="any" required="true"/>
		<cfset var errordetail = "">
		<cfset var companycode = "">
		<cfset var template = "">
		<cfset var sourcepage = "">

		<cfif isDefined('arguments.Exception.cause.Detail') and isDefined('arguments.Exception.cause.Message')>
			<cfset errordetail = "#arguments.Exception.cause.Detail##arguments.Exception.cause.Message#">
		<cfelseif isDefined('arguments.Exception.Message') >
			<cfset errordetail = "#arguments.Exception.Message#">
		</cfif>

		<cfif structKeyExists(arguments.Exception, "TagContext") AND isArray(arguments.Exception.TagContext) AND NOT arrayIsEmpty(arguments.Exception.TagContext) AND isstruct(arguments.Exception.TagContext[1]) AND structKeyExists(arguments.Exception.TagContext[1], "raw_trace")>
			<cfset template = arguments.Exception.TagContext[1].raw_trace>
		</cfif>
		
		<cfif structKeyExists(session, "usercompanycode")>
			<cfset companycode ="["&session.usercompanycode&"]">
		</cfif>
		
		<cfif isDefined("cgi.HTTP_REFERER")>
			<cfset sourcepage = "#chr(10)#[Sourcepage]:#cgi.HTTP_REFERER#">
		</cfif>

		<cffile action="append" file="#ExpandPath("../webroot/logs")#/Application.Log.txt" output="#dateTimeFormat(now())##chr(10)##(companycode)##errordetail##chr(10)#[URLData]:#SerializeJSON(url)##chr(10)#[FormData]:#SerializeJSON(form)##chr(10)#[SessionData]:#SerializeJSON(session)##trim(template)##sourcepage#">

		<cfquery name="qInsLog" datasource="LoadManagerAdmin">
   			INSERT INTO LMErrorLog (CompanyCode,Detail,Status,FormData,URLData,Template,SourcePage)
   			VALUES (
   				<cfif structKeyExists(session, "usercompanycode")>
   					<cfqueryparam value="#session.usercompanycode#" cfsqltype="cf_sql_varchar">
   				<cfelse>
   					NULL
   				</cfif>
   				,<cfqueryparam value="#errordetail#" cfsqltype="cf_sql_varchar">
   				,'Pending'
   				<cfif isDefined("form")>
   					,<cfqueryparam value="#SerializeJSON(form)#" cfsqltype="cf_sql_varchar">
   				<cfelse>
   					,NULL
   				</cfif>
   				,<cfqueryparam value="#SerializeJSON(url)#" cfsqltype="cf_sql_varchar">
   				,<cfqueryparam value="#Template#" cfsqltype="cf_sql_varchar">
   				<cfif isDefined("cgi.HTTP_REFERER")>
   					,<cfqueryparam value="#cgi.HTTP_REFERER#" cfsqltype="cf_sql_varchar">
   				<cfelse>
   					,NULL
   				</cfif>
   				)
   		</cfquery>
	</cffunction>

	<cffunction name="getHelpSettings" access="remote" output="yes" returnformat="json">
		<cfargument name="Tab" type="string" required="yes"/>
		<cfargument name="SubMenu" type="string" required="yes"/>

		<cfquery name="qGetSubmenuURL" datasource="LoadManagerAdmin">
			SELECT URL FROM HelpSettings WHERE 
			Tab = <cfqueryparam value="#arguments.Tab#" cfsqltype="cf_sql_varchar"> AND
			SubMenu = <cfqueryparam value="#arguments.SubMenu#" cfsqltype="cf_sql_varchar">
		</cfquery>

		<cfreturn qGetSubmenuURL.URL>
	</cffunction>

	<cffunction name="getInfoBubble" access="remote" output="yes" returntype="array" returnformat="json">
		<cfargument name="Tab" type="string" required="yes"/>
		<cfargument name="SubMenu" type="string" required="yes"/>

		<cfquery name="qGetInfoBubble" datasource="LoadManagerAdmin">
			SELECT * FROM InfoBubble WHERE 
			Tab = <cfqueryparam value="#arguments.Tab#" cfsqltype="cf_sql_varchar"> AND
			SubMenu = <cfqueryparam value="#arguments.SubMenu#" cfsqltype="cf_sql_varchar">
		</cfquery>
		<cfset resArr = arrayNew(1)>
		<cfloop query="qGetInfoBubble">
			<cfset resStruct = structNew()>
			<cfset resStruct["Label"] = qGetInfoBubble.Label>
			<cfset resStruct["Information"] = qGetInfoBubble.Information>
			<cfset resStruct["InsertAfter"] = qGetInfoBubble.InsertAfter>
			<cfset resStruct["Field"] = qGetInfoBubble.Field>
			<cfset arrayAppend(resArr, resStruct)>
		</cfloop>
		<cfreturn resArr>
	</cffunction>

	<cffunction name="getBanner" access="public" returntype="query">
		<cfargument name="CompanyID" type="string" required="yes">

		<cfquery name="qSysConfig" datasource="#variables.dsn#">
			SELECT BannerSkipDate,FreightBroker,Dispatch FROM SystemConfig WHERE CompanyID =  <cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar">
		</cfquery>

		<cfif qSysConfig.Dispatch EQ 1>
			<cfset local.AssignTo = 'Dispatch Services'>
		<cfelseif qSysConfig.FreightBroker EQ 1>
			<cfset local.AssignTo = 'Carriers'>
		<cfelseif qSysConfig.FreightBroker EQ 0>
			<cfset local.AssignTo = 'Freight Broker'>
		<cfelseif qSysConfig.FreightBroker EQ 2>
			<cfset local.AssignTo = 'Carrier & Freight Broker'>
		</cfif>

		<cfquery name="qBanner" datasource="LoadManagerAdmin">
			SELECT CAST(BannerText AS VARCHAR(MAX)) AS BannerText,1 AS SortOrder FROM Banner 
			WHERE CompanyID = <cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar">
			AND BannerStatus = 1
			AND getdate() between ISNULL(BannerStartDate,'1990-01-01') AND ISNULL(BannerEndDate,'1990-01-01')
			<cfif len(trim(qSysConfig.BannerSkipDate))>
				AND CAST(getdate() as DATE) <> <cfqueryparam value="#qSysConfig.BannerSkipDate#" cfsqltype="cf_sql_date">
			</cfif>

			UNION
			SELECT CAST(BannerText AS VARCHAR(MAX)) AS BannerText,2 AS SortOrder FROM Banner 
			WHERE AssignTo = <cfqueryparam value="#local.AssignTo#" cfsqltype="cf_sql_varchar">
			AND BannerStatus = 1
			AND getdate() between ISNULL(BannerStartDate,'1990-01-01') AND ISNULL(BannerEndDate,'1990-01-01')
			<cfif len(trim(qSysConfig.BannerSkipDate))>
				AND CAST(getdate() as DATE) <> <cfqueryparam value="#qSysConfig.BannerSkipDate#" cfsqltype="cf_sql_date">
			</cfif>

			UNION
			SELECT CAST(BannerText AS VARCHAR(MAX)) AS BannerText,3 AS SortOrder FROM Banner 
			WHERE AssignTo = 'All Companies'
			AND BannerStatus = 1
			AND getdate() between ISNULL(BannerStartDate,'1990-01-01') AND ISNULL(BannerEndDate,'1990-01-01')
			<cfif len(trim(qSysConfig.BannerSkipDate))>
				AND CAST(getdate() as DATE) <> <cfqueryparam value="#qSysConfig.BannerSkipDate#" cfsqltype="cf_sql_date">
			</cfif>
			ORDER BY SortOrder
		</cfquery>

		<cfreturn qBanner>
	</cffunction>

	<cffunction name="skipBannerForToday" access="remote" output="yes" returnformat="json">
		<cfargument name="CompanyID" type="any" required="yes">

		<cfset local.dsn = trim(listFirst(cgi.SCRIPT_NAME,'/'))>

		<cfquery name="qUpd" datasource="#local.dsn#">
			UPDATE SystemConfig SET BannerSkipDate = getdate()
			WHERE CompanyID = <cfqueryparam value="#arguments.CompanyID#" cfsqltype="cf_sql_varchar">
		</cfquery>
		<cfreturn 1>
	</cffunction>

	<cffunction name="CheckBetaVersion" access="public" returntype="boolean">
		<cfargument name="CompanyCode" type="any" required="yes">

		<cfquery name="qGet" datasource="#variables.dsn#">
			SELECT COUNT(C.CompanyID) AS Cnt FROM Companies C
			INNER JOIN SystemConfig S ON S.CompanyID = C.CompanyID
			WHERE C.CompanyCode = <cfqueryparam value="#arguments.CompanyCode#" cfsqltype="cf_sql_varchar">
			AND S.useBetaVersion = 1
		</cfquery>

		<cfreturn qGet.Cnt>
	</cffunction>

	<cffunction name="getBillFromCompanies" access="public" returntype="query">
		<cfargument name="incCompany" required="no" type="boolean" default="0">
		<cfquery name="qGet" datasource="#variables.dsn#">
			SELECT BillFromCompanyID,CompanyName FROM BillFromCompanies
			WHERE CompanyID = <cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar">
			<cfif arguments.incCompany EQ 1>
				UNION
				SELECT CompanyID AS BillFromCompanyID,CompanyName FROM Companies
				WHERE CompanyID = <cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar">
			</cfif>
			ORDER BY CompanyName
		</cfquery>
		<cfreturn qGet>
	</cffunction>

	<cffunction name="SearchBillFromCompanies" access="public" output="false" returntype="query">
    <cfargument name="searchText" required="yes" type="any" default="">
    <cfargument name="pageNo" required="yes" type="any" default="-1">
    <cfargument name="sortorder" required="no" type="any" default="ASC">
    <cfargument name="sortby" required="no" type="any" default="CompanyName">

    <cfquery name="qGet" datasource="#Application.dsn#">
      <cfif arguments.pageNo neq -1>WITH page AS (</cfif>
      SELECT BillFromCompanyID,CompanyName,Email,Address,City,State,Zipcode,PhoneNumber,Fax,
        ROW_NUMBER() OVER (ORDER BY #arguments.sortBy#  #arguments.sortOrder#) AS Row
      FROM BillFromCompanies
      WHERE CompanyID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#session.CompanyID#">
      <cfif len(trim(arguments.searchText))>
        AND
        (CompanyName like <cfqueryparam value="%#arguments.searchText#%" cfsqltype="cf_sql_varchar">
        or Email like <cfqueryparam value="%#arguments.searchText#%" cfsqltype="cf_sql_varchar">
        or Address like <cfqueryparam value="%#arguments.searchText#%" cfsqltype="cf_sql_varchar">
        or City like <cfqueryparam value="%#arguments.searchText#%" cfsqltype="cf_sql_varchar">
        or State like <cfqueryparam value="%#arguments.searchText#%" cfsqltype="cf_sql_varchar">)
      </cfif>
      <cfif arguments.pageNo neq -1>
        )
       SELECT *,(select (max(row)/30) + (CASE WHEN max(row)%30 <> 0 THEN 1 ELSE 0 END)  FROM page) AS TotalPages FROM page WHERE Row between (<cfqueryparam value="#pageNo#" cfsqltype="cf_sql_varchar"> - 1) * 30 + 1 and <cfqueryparam value="#pageNo#" cfsqltype="cf_sql_varchar">*30
       ORDER BY Row
      </cfif>
    </cfquery>

    <cfreturn qGet>
  </cffunction>

  <cffunction name="SaveBillFromCompany" access="public" returntype="struct">
    <cfargument name="formStruct" type="struct" required="yes"/>
    <cfset var ServerFileName = "">
    <cfset imagesFolder = ExpandPath('..\fileupload\img\#session.userCompanyCode#\logo')>
    <cfif not directoryExists(imagesFolder)>
			<cfset directoryCreate(imagesFolder)>
		</cfif>
		<cfif arguments.formStruct.CompanyLogo NEQ ''>
			<cffile action="upload" fileField="CompanyLogo" destination="#imagesFolder#" nameconflict="makeunique">
			<cfset ServerFileName = cffile.SERVERFILE>
		</cfif>
    <cfif len(trim(arguments.formStruct.ID))>
    	<cfquery name="qUpd" datasource="#Application.dsn#">
    		UPDATE [BillFromCompanies] SET 
    		[CompanyName]=<cfqueryparam value="#arguments.formStruct.CompanyName#" cfsqltype="cf_sql_varchar">
    	 ,[Contact]=<cfqueryparam value="#arguments.formStruct.Contact#" cfsqltype="cf_sql_varchar">
       ,[Email]=<cfqueryparam value="#arguments.formStruct.Email#" cfsqltype="cf_sql_varchar">
       ,[Address]=<cfqueryparam value="#arguments.formStruct.Address#" cfsqltype="cf_sql_varchar">
       ,[Address2]=<cfqueryparam value="#arguments.formStruct.Address2#" cfsqltype="cf_sql_varchar">
       ,[City]=<cfqueryparam value="#arguments.formStruct.City#" cfsqltype="cf_sql_varchar">
       ,[State]=<cfqueryparam value="#arguments.formStruct.StateCode#" cfsqltype="cf_sql_varchar">
       ,[Zipcode]=<cfqueryparam value="#arguments.formStruct.Zipcode#" cfsqltype="cf_sql_varchar">
       ,[PhoneNumber]=<cfqueryparam value="#arguments.formStruct.PhoneNumber#" cfsqltype="cf_sql_varchar">
       ,[Fax]=<cfqueryparam value="#arguments.formStruct.Fax#" cfsqltype="cf_sql_varchar">
       ,[ModifiedDateTime]=GETDATE()
       ,[ModifiedBy]=<cfqueryparam value="#session.adminUserName#" cfsqltype="cf_sql_varchar">
       <cfif len(trim(ServerFileName))>,[CompanyLogoName]=<cfqueryparam value="#ServerFileName#" cfsqltype="cf_sql_varchar"></cfif>
       ,[CCOnMail]=<cfif structKeyExists(arguments.formStruct, "CCOnMail")>1<cfelse>0</cfif>
       ,[RemitInfo1]=<cfqueryparam value="#arguments.formStruct.RemitInfo1#" cfsqltype="cf_sql_varchar">
     	 ,[RemitInfo2]=<cfqueryparam value="#arguments.formStruct.RemitInfo2#" cfsqltype="cf_sql_varchar">
     	 ,[RemitInfo3]=<cfqueryparam value="#arguments.formStruct.RemitInfo3#" cfsqltype="cf_sql_varchar">
     	 ,[RemitInfo4]=<cfqueryparam value="#arguments.formStruct.RemitInfo4#" cfsqltype="cf_sql_varchar">
     	 ,[RemitInfo5]=<cfqueryparam value="#arguments.formStruct.RemitInfo5#" cfsqltype="cf_sql_varchar">
     	 ,[RemitInfo6]=<cfqueryparam value="#arguments.formStruct.RemitInfo6#" cfsqltype="cf_sql_varchar">
    		WHERE BillFromCompanyID = <cfqueryparam value="#arguments.formStruct.ID#" cfsqltype="cf_sql_varchar"> 
    	</cfquery>
    <cfelse>
	    <cfquery name="qIns" datasource="#Application.dsn#">
	    	INSERT INTO [BillFromCompanies]
	           ([CompanyName]
	           ,[Contact]
	           ,[Email]
	           ,[Address]
	           ,[Address2]
	           ,[City]
	           ,[State]
	           ,[Zipcode]
	           ,[PhoneNumber]
	           ,[Fax]
	           ,[CreatedBy]
	           ,[ModifiedBy]
	           <cfif len(trim(ServerFileName))>,[CompanyLogoName]</cfif>
	           ,[CompanyID]
	           ,[CCOnMail]
	           ,[RemitInfo1]
           	 ,[RemitInfo2]
           	 ,[RemitInfo3]
           	 ,[RemitInfo4]
           	 ,[RemitInfo5]
           	 ,[RemitInfo6]
	           )
	     VALUES
	           (<cfqueryparam value="#arguments.formStruct.CompanyName#" cfsqltype="cf_sql_varchar">
	           ,<cfqueryparam value="#arguments.formStruct.Contact#" cfsqltype="cf_sql_varchar">
	           ,<cfqueryparam value="#arguments.formStruct.Email#" cfsqltype="cf_sql_varchar">
	           ,<cfqueryparam value="#arguments.formStruct.Address#" cfsqltype="cf_sql_varchar">
	           ,<cfqueryparam value="#arguments.formStruct.Address2#" cfsqltype="cf_sql_varchar">
	           ,<cfqueryparam value="#arguments.formStruct.City#" cfsqltype="cf_sql_varchar">
	           ,<cfqueryparam value="#arguments.formStruct.StateCode#" cfsqltype="cf_sql_varchar">
	           ,<cfqueryparam value="#arguments.formStruct.Zipcode#" cfsqltype="cf_sql_varchar">
	           ,<cfqueryparam value="#arguments.formStruct.PhoneNumber#" cfsqltype="cf_sql_varchar">
	           ,<cfqueryparam value="#arguments.formStruct.Fax#" cfsqltype="cf_sql_varchar">
	           ,<cfqueryparam value="#session.adminUserName#" cfsqltype="cf_sql_varchar">
	           ,<cfqueryparam value="#session.adminUserName#" cfsqltype="cf_sql_varchar">
	           <cfif len(trim(ServerFileName))>,<cfqueryparam value="#ServerFileName#" cfsqltype="cf_sql_varchar"></cfif>
	           ,<cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar">
	           ,<cfif structKeyExists(arguments.formStruct, "CCOnMail")>1<cfelse>0</cfif>
	           ,<cfqueryparam value="#arguments.formStruct.RemitInfo1#" cfsqltype="cf_sql_varchar">
	           ,<cfqueryparam value="#arguments.formStruct.RemitInfo2#" cfsqltype="cf_sql_varchar">
	           ,<cfqueryparam value="#arguments.formStruct.RemitInfo3#" cfsqltype="cf_sql_varchar">
	           ,<cfqueryparam value="#arguments.formStruct.RemitInfo4#" cfsqltype="cf_sql_varchar">
	           ,<cfqueryparam value="#arguments.formStruct.RemitInfo5#" cfsqltype="cf_sql_varchar">
	           ,<cfqueryparam value="#arguments.formStruct.RemitInfo6#" cfsqltype="cf_sql_varchar">)
	  	</cfquery>
	  </cfif>
    <cfset var response = structNew()>
    <cfset response['res']='success'>
    <cfset response['msg']="Company details saved successfully.">
    <cfreturn response>
  </cffunction>

  <cffunction name="getBillFromCompanyDetails" access="public" returntype="query">
  	<cfargument name="ID" type="string" required="yes"/>
		<cfquery name="qGet" datasource="#variables.dsn#">
			SELECT 
			BillFromCompanyID,CompanyName,Contact,CompanyLogoName,Email,Address,Address2,City,State,Zipcode,PhoneNumber,Fax,CCOnMail,RemitInfo1,RemitInfo2,RemitInfo3,RemitInfo4,RemitInfo5,RemitInfo6
			FROM BillFromCompanies
			WHERE BillFromCompanyID = <cfqueryparam value="#arguments.ID#" cfsqltype="cf_sql_varchar">
		</cfquery>
		<cfreturn qGet>
	</cffunction>

	<cffunction name="DeleteBillFromCompany" access="public" returntype="struct">
  	<cfargument name="ID" type="string" required="yes"/>
		<cfquery name="qDel" datasource="#variables.dsn#">
			DELETE FROM BillFromCompanies
			WHERE BillFromCompanyID = <cfqueryparam value="#arguments.ID#" cfsqltype="cf_sql_varchar">
		</cfquery>
		<cfset var response = structNew()>
    <cfset response['res']='success'>
    <cfset response['msg']="Company deleted successfully.">
    <cfreturn response>
	</cffunction>

	<cffunction name="MobileAppSwitchConfirmation" access="public" returntype="void">
		<cfquery name="qDel" datasource="#variables.dsn#">
			UPDATE Systemconfig SET MobileAppSwitchConfirmation = 0 WHERE CompanyID = <cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar">
		</cfquery>
	</cffunction>
</cfcomponent>



