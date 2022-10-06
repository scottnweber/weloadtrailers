<cfcomponent output="false">
<cffunction name="init" access="public" output="false" returntype="void">
	<cfargument name="dsn" type="string" required="yes" />
	<cfset variables.dsn = Application.dsn />
</cffunction>
<!----Get All Equipments Information---->
<cffunction name="getAllUnits" access="public" output="false" returntype="any">
  <cfargument name="UnitID" required="no" type="any">
  <cfargument name="sortorder" required="no" type="any">
  <cfargument name="sortby" required="no" type="any">
	<cfargument name="status" required="no" type="string">

	<cfquery name="qrygetunits" datasource="#variables.dsn#">
    SELECT * FROM Units
      WHERE CompanyID = <cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar">
      <cfif isdefined('arguments.UnitID') and len(arguments.UnitID)>
        AND UnitID = <cfqueryparam value="#arguments.UnitID#" cfsqltype="cf_sql_varchar">
      </cfif>	
      <cfif isdefined('arguments.status') and len(arguments.status)>
      	AND isActive = <cfqueryparam value="#arguments.status#" cfsqltype="cf_sql_bit">
      </cfif>
    ORDER BY unitName
	</cfquery>
             
	<cfif isDefined("arguments.sortorder") and isDefined("arguments.sortby") and len(arguments.sortby)> 
    	<cfquery datasource="#variables.dsn#" name="getnewAgent">
        SELECT *  FROM Units
          WHERE  CompanyID = <cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar">
        ORDER BY #arguments.sortby# #arguments.sortorder#;
		</cfquery>             
		<cfreturn getnewAgent>               
	</cfif>
    
  <cfreturn qrygetunits>
</cffunction>
<!-----get unit infor for add /edit load page----->
<cffunction name="getloadUnits" access="public" output="false" returntype="any">
    <cfargument name="UnitID" required="no" type="any">
     <cfargument name="sortorder" required="no" type="any">
     <cfargument name="sortby" required="no" type="any">
   <cfargument name="status" required="no" type="string">
  <cfquery name="qrygetunits" datasource="#variables.dsn#">
      select unitID,unitName,unitCode,CustomerRate,CarrierRate from  Units
        where companyid = '#session.companyid#'
        <cfif isdefined('arguments.UnitID') and len(arguments.UnitID)>
          and UnitID=<cfqueryparam value="#arguments.UnitID#" cfsqltype="cf_sql_varchar">
         </cfif>  
    <cfif isdefined('arguments.status') and len(arguments.status)>
      and isActive = <cfqueryparam value="#arguments.status#" cfsqltype="cf_sql_varchar">
    </cfif>
          ORDER BY unitName
  </cfquery>
             
  <cfif isDefined("arguments.sortorder") and isDefined("arguments.sortby") and len(arguments.sortby)> 
      <cfquery datasource="#variables.dsn#" name="getnewAgent">
          select unitID,unitName,unitCode from  Units
            where companyid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#session.CompanyID#">
            order by #arguments.sortby# #arguments.sortorder#;
    </cfquery>             
    <cfreturn getnewAgent>               
  </cfif>
    
    <cfreturn qrygetunits>
</cffunction>

<cffunction name="getloadUnitsForAutoLoading" access="remote" output="yes" returntype="struct" returnformat="json">
    <cfargument name="UnitID" required="no" type="any">
    <cfargument name="dsn" required="no" type="any">
    <cfargument name="companyid" required="no" type="any">
    <cfquery name="qrygetunits" datasource="#arguments.dsn#">
        select unitCode,PaymentAdvance from Units
        where companyid = <cfqueryparam value="#arguments.companyid#" cfsqltype="cf_sql_varchar">
        <cfif isdefined('arguments.UnitID') and len(arguments.UnitID)>
            and UnitID=<cfqueryparam value="#arguments.UnitID#" cfsqltype="cf_sql_varchar">
        </cfif>
        ORDER BY unitName
    </cfquery>
    <cfset strUnit = structNew()>
    <cfset strUnit.unitCode = qrygetunits.unitCode>
    <cfset strUnit.PaymentAdvance = qrygetunits.PaymentAdvance>
    <cfreturn strUnit>
</cffunction>


<!---function to exclude With PaymentAdvance options--->
<cffunction name="getUnitIdsOfPaymentAdvance" access="remote"  returntype="any" returnformat="plain">
    <cfargument name="dsn" type="string" required="true" />
    <cfargument name="companyid" required="no" type="any">
    <cfquery name="qrygetunits" datasource="#arguments.dsn#">
        select unitID from  Units
        where companyid = '#arguments.companyid#'
        and isActive = 1
        and  PaymentAdvance=1 
    </cfquery>  
    <cfset variables.listUnitId=valuelist(qrygetunits.unitID)>
    <cfset variables.listUnitId=listtoarray(variables.listUnitId)>
    <cfreturn serializejson(variables.listUnitId)>
</cffunction>

<!---Add Equipment Information---->
<cffunction name="Addunit" access="public" output="false" returntype="any">
    <cfargument name="formStruct" type="struct" required="no" />
    <cfset variables.customerRate = replace( arguments.formStruct.CustomerRate,"$","","ALL") >
    <cfif not structKeyExists(arguments.formStruct, "paymentAdvance")>
      <cfset paymentAdvance = 0>
    <cfelse>
      <cfset paymentAdvance = 1>
    </cfif>
    <cfif not structKeyExists(arguments.formStruct, "Status")>
      <cfset Status = 0>
    <cfelse>
      <cfset Status = 1>
    </cfif>
    <cfif not structKeyExists(arguments.formStruct, "IsFee")>
      <cfset IsFee = 0>
    <cfelse>
      <cfset IsFee = 1>
    </cfif>
    <cfif not structKeyExists(arguments.formStruct, "HideOnCustomerInvoice")>
      <cfset HideOnCustomerInvoice = 0>
    <cfelse>
      <cfset HideOnCustomerInvoice = 1>
    </cfif>

    <cfset variables.carrierRate = replace( arguments.formStruct.CarrierRate,"$","","ALL") > 
    <CFSTOREDPROC PROCEDURE="USP_InsertUnit" DATASOURCE="#variables.dsn#">
      <cfprocparam cfsqltype="cf_sql_varchar" value="#session.CompanyID#">,
      <cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.UnitCode#">,
      <cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.UnitName#">,
      <cfprocparam cfsqltype="cf_sql_bit" value="#Status#">,
      <cfprocparam cfsqltype="cf_sql_varchar" value="#session.adminUserName#">,
      <cfprocparam cfsqltype="cf_sql_varchar" value="#session.adminUserName#">,
      <cfprocparam cfsqltype="cf_sql_date" value="#now()#">,
      <cfprocparam cfsqltype="cf_sql_date" value="#now()#">,
      <cfprocparam cfsqltype="cf_sql_bit" value="#IsFee#">, 
      <cfprocparam cfsqltype="cf_sql_varchar" value="#cgi.REMOTE_ADDR#">,
      <cfprocparam cfsqltype="cf_sql_varchar" value="#cgi.HTTP_USER_AGENT#"> ,
      <cfprocparam cfsqltype="cf_sql_money"  value="#variables.customerRate#">,
      <cfprocparam cfsqltype="cf_sql_money"  value="#variables.carrierRate#">,
      <cfprocparam cfsqltype="cf_sql_bit" value="#paymentAdvance#">,
      <cfprocparam cfsqltype="cf_sql_bit" value="#HideOnCustomerInvoice#">,
      <cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.GLSalesAccount#">,
      <cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.GLExpenseAccount#">,
      <cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.GLBankAccount#">
      <cfprocresult name="LastInsertedUnit">
    </CFSTOREDPROC>
  <cfreturn "Unit has been added Successfully">	    	
</cffunction>
<!---Update Equipment --->
<cffunction name="Updateunit" access="public" output="false" returntype="any">
  <cfargument name="formStruct" type="struct">
  <cfargument name="editid" type="any"> 
  <cfif not structKeyExists(arguments.formStruct, "paymentAdvance")>
    <cfset paymentAdvance = 0>
  <cfelse>
    <cfset paymentAdvance = 1>
  </cfif>
  <cfif not structKeyExists(arguments.formStruct, "Status")>
    <cfset Status = 0>
  <cfelse>
    <cfset Status = 1>
  </cfif>
  <cfif not structKeyExists(arguments.formStruct, "IsFee")>
    <cfset IsFee = 0>
  <cfelse>
    <cfset IsFee = 1>
  </cfif>
  <cfif not structKeyExists(arguments.formStruct, "HideOnCustomerInvoice")>
    <cfset HideOnCustomerInvoice = 0>
  <cfelse>
    <cfset HideOnCustomerInvoice = 1>
  </cfif>
	<cfset variables.customerRate = replace( arguments.formStruct.CustomerRate,"$","","ALL") > 
	<cfset variables.carrierRate = replace( arguments.formStruct.CarrierRate,"$","","ALL") >
  <cfset variables.customerRate = ReplaceNoCase(variables.customerRate,',','','ALL')>
  <cfset variables.carrierRate = ReplaceNoCase(variables.carrierRate,',','','ALL')>
    <CFSTOREDPROC PROCEDURE="USP_UpdateUnit" DATASOURCE="#variables.dsn#">
      <cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.editid#">,
      <cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.UnitCode#">,
      <cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.UnitName#">,
      <cfprocparam cfsqltype="cf_sql_bit" value="#Status#">,
      <cfprocparam cfsqltype="cf_sql_varchar" value="#session.adminUserName#">,
      <cfprocparam cfsqltype="cf_sql_date" value="#now()#">,
      <cfprocparam cfsqltype="cf_sql_bit"  value="#IsFee#">,
      <cfprocparam cfsqltype="cf_sql_varchar" value="#cgi.REMOTE_ADDR#">,
      <cfprocparam cfsqltype="cf_sql_money"  value="#variables.customerRate#">,
      <cfprocparam cfsqltype="cf_sql_money"  value="#variables.carrierRate#">,
      <cfprocparam cfsqltype="cf_sql_bit" value="#paymentAdvance#">,
      <cfprocparam cfsqltype="cf_sql_bit"  value="#HideOnCustomerInvoice#">,
      <cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.GLSalesAccount#">,
      <cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.GLExpenseAccount#">,
      <cfprocparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.GLBankAccount#">
    </CFSTOREDPROC>
     <cfreturn "Unit has been updated Successfully">
</cffunction>
<!--- Delete Equipment---->
<cffunction name="deleteUnits"  access="public" output="false" returntype="any">
<cfargument name="UnitID" type="any" required="yes">
    <cftry>
    		<cfquery name="qryDelete" datasource="#variables.dsn#">
    			 delete from Units where  UnitID=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.UnitID#">
    		</cfquery>
    		<cfreturn "Units has been deleted successfully.">	
    		<cfcatch type="any">
    			<cfreturn "Delete operation has been not successfull.">
    		</cfcatch>
    	</cftry>
</cffunction>  

<cffunction name="getSearchedUnit" access="public" output="false" returntype="query">
	<cfargument name="searchText" required="yes" type="any">
	<CFSTOREDPROC PROCEDURE="searchUnit" DATASOURCE="#variables.dsn#"> 
		<cfif isdefined('arguments.searchText') and len(arguments.searchText)>
		 	<CFPROCPARAM VALUE="#arguments.searchText#" cfsqltype="CF_SQL_VARCHAR">  
		 <cfelse>
		 	<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR">  
		 </cfif>
     <CFPROCPARAM VALUE="#session.CompanyID#" cfsqltype="CF_SQL_VARCHAR">  
		 <CFPROCRESULT NAME="QreturnSearch"> 
	</CFSTOREDPROC>
    <cfreturn QreturnSearch>
</cffunction>

<cffunction name="getFirstUnit" access="public" output="false" returntype="string">
  <cfquery name="qGetUnit" datasource="#variables.dsn#">
    SELECT TOP 1 UnitID FROM Units
    WHERE  CompanyID = <cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar">
    ORDER BY unitName
  </cfquery>
  <cfreturn qGetUnit.UnitID>
</cffunction>
</cfcomponent>