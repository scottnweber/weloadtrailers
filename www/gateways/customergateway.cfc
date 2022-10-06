<cfcomponent output="false">
<cffunction name="init" access="public" output="false" returntype="void">
	<cfargument name="dsn" type="string" required="yes" />
	<cfset variables.dsn = Application.dsn />
</cffunction>
<cffunction name="getAttachedFiles" access="public" returntype="query">
	<cfargument name="linkedid" type="string">
	<cfargument name="fileType" type="string">

	<cfquery name="getFilesAttached" datasource="#variables.dsn#">
		select * from FileAttachments where linked_id=<cfqueryparam value="#arguments.linkedid#" cfsqltype="cf_sql_varchar"> and linked_to=<cfqueryparam value="#arguments.filetype#" cfsqltype="cf_sql_integer">
	</cfquery>

	<cfreturn getFilesAttached>
</cffunction>
<!----Get All Customer Information---->
<cffunction name="getAllCustomers" access="public" output="false" returntype="any">
    <cfargument name="CustomerID" required="no" type="any">
    <cfargument name="sortorder" required="no" type="any">
    <cfargument name="sortby" required="no" type="any">
    <cfargument name="dsn" required="no" type="any">

    <cfif isdefined('dsn')>
    	<cfset activedsn = dsn>
    <cfelse>
    	<cfset activedsn = variables.dsn>
    </cfif>

			<CFSTOREDPROC PROCEDURE="USP_GetCustomerDetails" DATASOURCE="#activedsn#">
				<cfif isdefined('arguments.CustomerID') and len(arguments.CustomerID)>
				 	<CFPROCPARAM VALUE="#arguments.CustomerID#" cfsqltype="CF_SQL_VARCHAR">
				 <cfelse>
				 	<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR">
				 </cfif>
				 <CFPROCPARAM VALUE="#session.CompanyID#" cfsqltype="CF_SQL_VARCHAR">
				 <CFPROCRESULT NAME="qrygetcustomers">
			</CFSTOREDPROC>

      <cfif isDefined("arguments.sortorder") and isDefined("arguments.sortby") and len(arguments.sortby)>
      	
            <cfquery datasource="#activedsn#" name="getnewAgent">
                        select Customers.CustomerID, Customers.CustomerName,Customers.Location as custLocation,Customers.PhoneNo,ISNULL(RatePerMile,0) AS RatePrMile,Customers.CustomerStatusID,CUSTOMERs.OFFICEID,Customers.CompanyID,Offices.Location as ofLocation,Companies.CompanyName 

                        from Customers

                        inner join (select
					    customerid,
					    max(companyid) AS companyid,
					    stuff((
					        select ';' + offices.[location]
					        from CustomerOffices t
							inner join offices on offices.OfficeID = t.officeid
					        where t.customerid = c1.customerid
					        order by offices.[location]
					        for xml path('')
					    ),1,1,'') as OfficeLocations
						from CustomerOffices c1 inner join offices o1 on o1.officeid = c1.OfficeID
						where o1.CompanyID = '#session.companyid#'
						group by customerid) Offices ON Offices.CustomerID = Customers.CustomerID
						inner join Companies on Companies.CompanyID=Offices.CompanyID
                        where 1=1 AND IsPayer = 1
                        order by #arguments.sortby# #arguments.sortorder#;
            </cfquery>

           <cfreturn getnewAgent>

       </cfif>
             <cfreturn qrygetcustomers>
</cffunction>



<!---Add Customer Information---->
<cffunction name="AddCustomer" access="public" output="false" returntype="any">
	<cfargument name="formStruct" type="struct" required="no" />
	<cfargument name="idReturn" type="string" required="no"  default="" />

	<cfif not structKeyExists(variables,"dsn")>
		<cfset variables.dsn =application.dsn>
	</cfif>

	<cfset variables.userExists = 0>

	<cfif arguments.formStruct.IsPayer AND len(trim(arguments.formStruct.CustomerUsername))>
	    <cfquery name="qryGetCustomer" datasource="#variables.dsn#">
	    	select CustomerID from Customers
	    	where
	    		Username=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.CustomerUsername#">
	    		and customerid in (select customerid from CustomerOffices inner join offices on CustomerOffices.officeid = offices.officeid where offices.companyid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#session.companyid#">)
		</cfquery>
		<cfif qryGetCustomer.recordCount>
			<cfset variables.userExists = 1>
		</cfif>
	</cfif>

	<cfif structkeyexists(arguments.formStruct,"AddFromLoad") AND arguments.formStruct.AddFromLoad EQ 1>
		<cfquery name="qCheckCustomer" datasource="#variables.dsn#">
			SELECT CustomerID FROM Customers
			WHERE CustomerID IN (SELECT CustomerID FROM CustomerOffices 
								INNER JOIN Offices ON CustomerOffices.OfficeID = Offices.OfficeID 
								WHERE Offices.CompanyID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#session.CompanyID#">)
				AND CustomerName = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.CustomerName#">
		</cfquery>
		<cfif qCheckCustomer.recordcount>
			<cfset resultStruct ={}>
			<cfset resultStruct.id = qCheckCustomer.CustomerID>
			<cfreturn resultStruct>
		</cfif>
	</cfif>

	<CFSTOREDPROC PROCEDURE="USP_InsertCustomer" DATASOURCE="#variables.dsn#">
		<cfif structKeyExists(arguments.formStruct, "CustomerStatusID")>
			<CFPROCPARAM VALUE="#arguments.formStruct.CustomerStatusID#" cfsqltype="CF_SQL_INTEGER">
		<cfelse>
			<CFPROCPARAM VALUE="1" cfsqltype="CF_SQL_INTEGER">
		</cfif>
			<CFPROCPARAM VALUE="#arguments.formStruct.CustomerCode#" cfsqltype="CF_SQL_VARCHAR">
			<CFPROCPARAM VALUE="#trim(arguments.formStruct.CustomerName)#" cfsqltype="CF_SQL_VARCHAR">,
            <CFPROCPARAM VALUE="#arguments.formStruct.OfficeID1#" cfsqltype="CF_SQL_VARCHAR">,
            <CFPROCPARAM VALUE="#arguments.formStruct.Location#" cfsqltype="CF_SQL_VARCHAR">,
            <CFPROCPARAM VALUE="#arguments.formStruct.City#"  cfsqltype="CF_SQL_VARCHAR">,
            <CFPROCPARAM VALUE="#arguments.formStruct.State1#"  cfsqltype="CF_SQL_VARCHAR">,
            <CFPROCPARAM VALUE="#arguments.formStruct.Zipcode#" cfsqltype="CF_SQL_VARCHAR">,

            <CFPROCPARAM VALUE="#arguments.formStruct.website#"  cfsqltype="CF_SQL_VARCHAR">,
			<cfif isdefined('arguments.formStruct.salesperson') and len(arguments.formStruct.salesperson)>
		 		<CFPROCPARAM VALUE="#arguments.formStruct.salesperson#" cfsqltype="CF_SQL_VARCHAR">
			<cfelse>
		 		<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR">
		 	</cfif>

		 	<cfif isdefined('arguments.formStruct.Dispatcher') and len(arguments.formStruct.Dispatcher)>
		 		<CFPROCPARAM VALUE="#arguments.formStruct.Dispatcher#" cfsqltype="CF_SQL_VARCHAR">
			<cfelse>
		 		<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR">
		 	</cfif>

		 	<cfif isdefined('arguments.formStruct.LoadPotential') and len(arguments.formStruct.LoadPotential)>
		 		<CFPROCPARAM VALUE="#arguments.formStruct.LoadPotential#" cfsqltype="CF_SQL_VARCHAR">
			<cfelse>
		 		<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR">
		 	</cfif>

			<cfif isdefined('arguments.formStruct.BestOpp') and len(arguments.formStruct.BestOpp)>
		 		<CFPROCPARAM VALUE="#arguments.formStruct.BestOpp#" cfsqltype="CF_SQL_VARCHAR">
			<cfelse>
		 		<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR">
		 	</cfif>

            <CFPROCPARAM VALUE="#replaceNoCase(replaceNoCase(arguments.formStruct.CustomerDirections, "\r", "","ALL"), "\n", "", "ALL")#" cfsqltype="CF_SQL_LONGNVARCHAR"> ,
            <CFPROCPARAM VALUE="#arguments.formStruct.CustomerNotes#" cfsqltype="CF_SQL_VARCHAR">,
            <CFPROCPARAM VALUE="#arguments.formStruct.IsPayer#" cfSqltype="Cf_SQL_BIT">,
            <CFPROCPARAM VALUE="#session.adminUserName#"  cfsqltype="CF_SQL_VARCHAR">,
            <CFPROCPARAM VALUE="#arguments.formStruct.FinanceID#" cfsqltype="CF_SQL_VARCHAR">,
			<cfif arguments.formStruct.CreditLimit contains '$'>
			  	<CFPROCPARAM VALUE="#val(right(arguments.formStruct.CreditLimit,len(arguments.formStruct.CreditLimit)-1))#" cfsqltype="Cf_Sql_MONEY">,
			<cfelse>
              	<CFPROCPARAM VALUE="#val(arguments.formStruct.CreditLimit)#" cfsqltype="Cf_Sql_MONEY">,
			</cfif>
			  <cfif arguments.formStruct.Balance contains '$'>
				  <CFPROCPARAM VALUE="#val(right(arguments.formStruct.Balance,len(arguments.formStruct.Balance)-1))#" cfsqltype="Cf_Sql_MONEY">,
			  <cfelse>
	              <CFPROCPARAM VALUE="#val(arguments.formStruct.Balance)#" cfsqltype="Cf_Sql_MONEY">
			  </cfif>
              <cfif arguments.formStruct.Available contains '$'>
				<CFPROCPARAM VALUE="#val(right(arguments.formStruct.Available,len(arguments.formStruct.Available)-1))#" cfsqltype="Cf_Sql_MONEY">,
			  <cfelse>
			  	<CFPROCPARAM VALUE="#val(arguments.formStruct.Available)#" cfsqltype="Cf_Sql_MONEY">,
			  </cfif>
              <cfif arguments.formStruct.RatePerMile contains '$'>
				<CFPROCPARAM VALUE="#val(right(arguments.formStruct.RatePerMile,len(arguments.formStruct.RatePerMile)-1))#" cfsqltype="Cf_Sql_MONEY">,
			  <cfelse>
			  	<CFPROCPARAM VALUE="#val(arguments.formStruct.RatePerMile)#" cfsqltype="Cf_Sql_MONEY">,
			  </cfif>
			  <CFPROCPARAM VALUE="#arguments.formStruct.country1#" cfsqltype="cf_sql_varCHAR">,
              <CFPROCPARAM VALUE="#cgi.REMOTE_ADDR#"  cfsqltype="cf_sql_varCHAR">,
              <CFPROCPARAM VALUE="#cgi.HTTP_USER_AGENT#"  cfsqltype="cf_sql_varCHAR">,
			  <CFPROCPARAM VALUE="#arguments.formStruct.CarrierNotes#" cfsqltype="CF_SQL_VARCHAR">,
			
				<cfif isdefined('arguments.formStruct.RemitName') and len(arguments.formStruct.RemitName)>
					<CFPROCPARAM VALUE="#arguments.formStruct.RemitName#"  cfsqltype="CF_SQL_VARCHAR">
				<cfelse>
					<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR">
				</cfif>
				<cfif isdefined('arguments.formStruct.RemitAddress') and len(arguments.formStruct.RemitAddress)>
					<CFPROCPARAM VALUE="#arguments.formStruct.RemitAddress#"  cfsqltype="CF_SQL_VARCHAR">
				<cfelse>
					<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR">
				</cfif>
				<cfif isdefined('arguments.formStruct.RemitCity') and len(arguments.formStruct.RemitCity)>
					<CFPROCPARAM VALUE="#arguments.formStruct.RemitCity#"  cfsqltype="CF_SQL_VARCHAR">
				<cfelse>
					<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR">
				</cfif>
				<cfif isdefined('arguments.formStruct.RemitState') and len(arguments.formStruct.RemitState)>
					<CFPROCPARAM VALUE="#arguments.formStruct.RemitState#"  cfsqltype="CF_SQL_VARCHAR">
				<cfelse>
					<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR">
				</cfif>
				<cfif isdefined('arguments.formStruct.RemitZipcode') and len(arguments.formStruct.RemitZipcode)>
					<CFPROCPARAM VALUE="#arguments.formStruct.RemitZipcode#"  cfsqltype="CF_SQL_VARCHAR">
				<cfelse>
					<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR">
				</cfif>
				<cfif isdefined('arguments.formStruct.RemitContact') and len(arguments.formStruct.RemitContact)>
					<CFPROCPARAM VALUE="#arguments.formStruct.RemitContact#"  cfsqltype="CF_SQL_VARCHAR">
				<cfelse>
					<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR">
				</cfif>
				<cfif isdefined('arguments.formStruct.RemitFax') and len(arguments.formStruct.RemitFax)>
					<CFPROCPARAM VALUE="#arguments.formStruct.RemitFax#"  cfsqltype="CF_SQL_VARCHAR">
				<cfelse>
					<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR">
				</cfif>
				<cfif isdefined('arguments.formStruct.RemitPhone') and len(arguments.formStruct.RemitPhone)>
					<CFPROCPARAM VALUE="#arguments.formStruct.RemitPhone#"  cfsqltype="CF_SQL_VARCHAR">
				<cfelse>
					<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR">
				</cfif>
			  <cfif arguments.formStruct.isPayer>
			  		<cfif variables.userExists>
			  			<CFPROCPARAM VALUE=""  cfsqltype="CF_SQL_VARCHAR">
			  		<cfelse>
			  			<CFPROCPARAM VALUE="#arguments.formStruct.CustomerUsername#"  cfsqltype="CF_SQL_VARCHAR">
			  		</cfif>
				  	<CFPROCPARAM VALUE="#arguments.formStruct.CustomerPassword#"  cfsqltype="CF_SQL_VARCHAR">
			  <cfelse>
			  		<CFPROCPARAM VALUE=""  cfsqltype="CF_SQL_VARCHAR">
				  	<CFPROCPARAM VALUE=""  cfsqltype="CF_SQL_VARCHAR">
			  </cfif>
			  <cfif structKeyExists(arguments.formStruct, "defaultCurrency")>
					<CFPROCPARAM VALUE="#arguments.formStruct.defaultCurrency#"  cfsqltype="CF_SQL_INTEGER"  null="#YesNoFormat(not Len(arguments.formStruct.defaultCurrency))#">
				<cfelse>
					<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_INTEGER"  null="Yes">					
				</cfif>	
			  <cfif isdefined('arguments.formStruct.DOTNumber')>
			  		<CFPROCPARAM VALUE="#arguments.formStruct.DOTNumber#"  cfsqltype="CF_SQL_VARCHAR">
			  <cfelse>
			  		<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR"  null="Yes">	
			  </cfif>
			  <cfif isdefined('arguments.formStruct.MCNumber')>
			  		<CFPROCPARAM VALUE="#arguments.formStruct.MCNumber#"  cfsqltype="CF_SQL_VARCHAR">
			  <cfelse>
			  		<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR"  null="Yes">	
			  </cfif>
			  
			  <cfif isdefined('arguments.formStruct.EDIPartnerID')>
			  	<CFPROCPARAM VALUE="#arguments.formStruct.EDIPartnerID#"  cfsqltype="CF_SQL_VARCHAR">
			  <cfelse>
			    <CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR"  null="Yes">	
			  </cfif>
			  <cfif isdefined('arguments.formStruct.CustomerTerms') and len(arguments.formStruct.CustomerTerms)>
			 		,<CFPROCPARAM VALUE="#arguments.formStruct.CustomerTerms#" cfsqltype="CF_SQL_VARCHAR">
				<cfelse>
			 		,<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR">
			 	</cfif>
			<cfif isdefined('arguments.formStruct.ConsolidateInvoices')>
			 	,<CFPROCPARAM VALUE="1" cfsqltype="CF_SQL_BIT">
			<cfelse>
			 	,<CFPROCPARAM VALUE="0" cfsqltype="CF_SQL_BIT">
			</cfif>
			<cfif isdefined('arguments.formStruct.SeperateJobPo')>
			 	,<CFPROCPARAM VALUE="1" cfsqltype="CF_SQL_BIT">
			<cfelse>
			 	,<CFPROCPARAM VALUE="0" cfsqltype="CF_SQL_BIT">
			</cfif>
			<cfif isdefined('arguments.formStruct.FactoringID') and len(arguments.formStruct.FactoringID)>
				<CFPROCPARAM VALUE="#arguments.formStruct.FactoringID#"  cfsqltype="CF_SQL_VARCHAR">
			<cfelse>
				<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR"  null="Yes">	
			</cfif>
			<cfif isdefined('arguments.formStruct.TimeZone') and len(arguments.formStruct.TimeZone)>
				<CFPROCPARAM VALUE="#arguments.formStruct.TimeZone#"  cfsqltype="CF_SQL_VARCHAR">
			<cfelse>
				<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR"  null="Yes">	
			</cfif>
			<cfif isdefined('arguments.formStruct.LockSalesAgentOnLoad')>
			 	,<CFPROCPARAM VALUE="1" cfsqltype="CF_SQL_BIT">
			<cfelse>
			 	,<CFPROCPARAM VALUE="0" cfsqltype="CF_SQL_BIT">
			</cfif>
			<cfif isdefined('arguments.formStruct.LockDispatcherOnLoad')>
			 	,<CFPROCPARAM VALUE="1" cfsqltype="CF_SQL_BIT">
			<cfelse>
			 	,<CFPROCPARAM VALUE="0" cfsqltype="CF_SQL_BIT">
			</cfif>
			<cfif isdefined('arguments.formStruct.IncludeIndividualInvoices')>
			 	,<CFPROCPARAM VALUE="1" cfsqltype="CF_SQL_BIT">
			<cfelse>
			 	,<CFPROCPARAM VALUE="0" cfsqltype="CF_SQL_BIT">
			</cfif>
			<cfif structKeyExists(arguments.formStruct,'ContactPerson') and len(arguments.formStruct.ContactPerson)>
				,<CFPROCPARAM VALUE="#arguments.formStruct.ContactPerson#"  cfsqltype="CF_SQL_VARCHAR">
			<cfelse>
				,<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR">
			</cfif>

			<cfif structKeyExists(arguments.formStruct,'PhoneNO') and len(arguments.formStruct.PhoneNO)>
				,<CFPROCPARAM VALUE="#arguments.formStruct.PhoneNO#"  cfsqltype="CF_SQL_VARCHAR">
			<cfelse>
				,<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR">
			</cfif>

			<cfif structKeyExists(arguments.formStruct,'PhoneNOExt') and len(arguments.formStruct.PhoneNOExt)>
				,<CFPROCPARAM VALUE="#arguments.formStruct.PhoneNOExt#"  cfsqltype="CF_SQL_VARCHAR">
			<cfelse>
				,<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR">
			</cfif>

			<cfif structKeyExists(arguments.formStruct,'Tollfree') and len(arguments.formStruct.Tollfree)>
				,<CFPROCPARAM VALUE="#arguments.formStruct.Tollfree#"  cfsqltype="CF_SQL_VARCHAR">
			<cfelse>
				,<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR">
			</cfif>

			<cfif structKeyExists(arguments.formStruct,'TollfreeExt') and len(arguments.formStruct.TollfreeExt)>
				,<CFPROCPARAM VALUE="#arguments.formStruct.TollfreeExt#"  cfsqltype="CF_SQL_VARCHAR">
			<cfelse>
				,<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR">
			</cfif>

			<cfif structKeyExists(arguments.formStruct,'MobileNo') and len(arguments.formStruct.MobileNo)>
				,<CFPROCPARAM VALUE="#arguments.formStruct.MobileNo#"  cfsqltype="CF_SQL_VARCHAR">
			<cfelse>
				,<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR">
			</cfif>

			<cfif structKeyExists(arguments.formStruct,'MobileNoExt') and len(arguments.formStruct.MobileNoExt)>
				,<CFPROCPARAM VALUE="#arguments.formStruct.MobileNoExt#"  cfsqltype="CF_SQL_VARCHAR">
			<cfelse>
				,<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR">
			</cfif>

			<cfif structKeyExists(arguments.formStruct,'Fax') and len(arguments.formStruct.Fax)>
				,<CFPROCPARAM VALUE="#arguments.formStruct.Fax#"  cfsqltype="CF_SQL_VARCHAR">
			<cfelse>
				,<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR">
			</cfif>

			<cfif structKeyExists(arguments.formStruct,'FaxExt') and len(arguments.formStruct.FaxExt)>
				,<CFPROCPARAM VALUE="#arguments.formStruct.FaxExt#"  cfsqltype="CF_SQL_VARCHAR">
			<cfelse>
				,<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR">
			</cfif>

			<cfif structKeyExists(arguments.formStruct,'Email') and len(arguments.formStruct.Email)>
				,<CFPROCPARAM VALUE="#arguments.formStruct.Email#"  cfsqltype="CF_SQL_VARCHAR">
			<cfelse>
				,<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR">
			</cfif>

			<cfif structkeyexists(arguments.formStruct,"ConsolidateInvoiceBOL")>
			 	,<CFPROCPARAM VALUE="1" cfsqltype="CF_SQL_BIT">
			<cfelse>
			 	,<CFPROCPARAM VALUE="0" cfsqltype="CF_SQL_BIT">
			</cfif>

			<cfif structkeyexists(arguments.formStruct,"ConsolidateInvoiceRef")>
			 	,<CFPROCPARAM VALUE="1" cfsqltype="CF_SQL_BIT">
			<cfelse>
			 	,<CFPROCPARAM VALUE="0" cfsqltype="CF_SQL_BIT">
			</cfif>

			<cfif structkeyexists(arguments.formStruct,"ConsolidateInvoiceDate")>
			 	,<CFPROCPARAM VALUE="1" cfsqltype="CF_SQL_BIT">
			<cfelse>
			 	,<CFPROCPARAM VALUE="0" cfsqltype="CF_SQL_BIT">
			</cfif>
			<cfif structKeyExists(arguments.formStruct,'BillFromCompany') and len(arguments.formStruct.BillFromCompany)>
				,<CFPROCPARAM VALUE="#arguments.formStruct.BillFromCompany#"  cfsqltype="CF_SQL_VARCHAR">
			<cfelse>
				,<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR" null="true">
			</cfif>
			<cfif structKeyExists(arguments.formStruct,'InternalNotes') and len(arguments.formStruct.InternalNotes)>
				,<CFPROCPARAM VALUE="#arguments.formStruct.InternalNotes#"  cfsqltype="CF_SQL_VARCHAR">
			<cfelse>
				,<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR" null="true">
			</cfif>
			<cfif structKeyExists(arguments.formStruct, "salesperson2") AND len(trim(arguments.formStruct.salesperson2))>
		        	<CFPROCPARAM VALUE="#arguments.formStruct.salesperson2#"  cfsqltype="CF_SQL_VARCHAR">,
		    	<cfelse>
				<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR"  null="Yes">,
			</cfif>
		    	<cfif structKeyExists(arguments.formStruct, "Dispatcher2") AND len(trim(arguments.formStruct.Dispatcher2))>
		        	<CFPROCPARAM VALUE="#arguments.formStruct.Dispatcher2#"  cfsqltype="CF_SQL_VARCHAR">,
		    	<cfelse>
				<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR"  null="Yes">,	
			</cfif>
			<cfif isdefined('arguments.formStruct.LockDispatcher2OnLoad')>
			 	,<CFPROCPARAM VALUE="1" cfsqltype="CF_SQL_BIT">
			<cfelse>
			 	,<CFPROCPARAM VALUE="0" cfsqltype="CF_SQL_BIT">
			</cfif>
            <cfprocresult name="qLastInsertedCustomer">
	</CFSTOREDPROC>

	<cfloop list="#arguments.formStruct.officeid1#" item="ofcID">
		 <cfquery name="qInsertCustomerOffices" datasource="#variables.dsn#">
		 	INSERT INTO [CustomerOffices]
	           ([CustomerOfficesID]
	           ,[CustomerID]
	           ,[OfficeID])
	        VALUES(
	        	newid(),
	        	<cfqueryparam value='#qLastInsertedCustomer.lastInsertedCustomerID#' cfsqltype="cf_sql_varchar">,
	        	<cfqueryparam value='#ofcID#' cfsqltype="cf_sql_varchar">
	        	)
		 </cfquery>
	</cfloop>
	<cfif arguments.idReturn eq "true">
		<cfset resultStruct ={}>
		<cfset resultStruct.id = qLastInsertedCustomer.lastInsertedCustomerID>
		<cfif qLastInsertedCustomer.lastInsertedCustomerID eq ''>
        <cfset resultStruct.msg ="Customer addition failed">
        
		<cfelseif variables.userExists>
			<cfset resultStruct.msg ="The username is already in use, please update the username.">
		<cfelse>
			<cfset resultStruct.message ="Customer has been added Successfully">
            <cfset resultStruct.customerID = qLastInsertedCustomer.lastInsertedCustomerID>
            
		</cfif>
	
    <cfreturn resultStruct>
        
	<cfelseif variables.userExists>
		<cfreturn "The username is already in use, please update the username.">
	<cfelse>
	  <cfreturn "Customer has been added Successfully">
	</cfif>
   <cfreturn "Customer has been added Successfully">

</cffunction>

<!---Get All Offices--->
<cffunction name="getOffices" access="public" output="false" returntype="query">
     	<cfargument name="officeID" required="no" type="any">
         <CFSTOREDPROC PROCEDURE="USP_GetOfficeDetails" DATASOURCE="#variables.dsn#">
		<cfif isdefined('arguments.officeID') and len(arguments.officeID)>
		 	<CFPROCPARAM VALUE="#arguments.officeID#" cfsqltype="CF_SQL_VARCHAR">
		 <cfelse>
		 	<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR">
		 </cfif>
		 <CFPROCRESULT NAME="qrygetoffices">
		</CFSTOREDPROC>
         <cfreturn qrygetoffices>
</cffunction>
<!--- Get All Companies ---->
 <cffunction name="getCompanies" access="public" output="false" returntype="query">
         	<cfargument name="CompanyID" required="no" type="any">
             <cfquery name="qrygetcompanies" datasource="#variables.dsn#">
                 select * from Companies
         		<cfif isdefined('arguments.CompanyID') and len(arguments.CompanyID)>
         			where CompanyID  = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.CompanyID#">
         		</cfif>
             </cfquery>
             <cfreturn qrygetcompanies>
 </cffunction>
<!---Update Customer --->
<cffunction name="updateCustomers" access="public" output="false" returntype="any">
    <cfargument name="formStruct" type="struct">
    <cfargument name="editid" type="any">

	<cfset variables.userExists = 0>

    <cfif arguments.formStruct.IsPayer AND len(trim(arguments.formStruct.CustomerUsername))>
	    <cfquery name="qryGetCustomer" datasource="#variables.dsn#">
	    	select CustomerID from Customers
	    	where
	    		Username=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.CustomerUsername#"> 
	    		and customerid in 
				(select customerid from CustomerOffices inner join offices on CustomerOffices.officeid = offices.officeid where offices.companyid = 
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#session.companyid#">)
				AND CustomerID <> <cfqueryparam value="#arguments.formStruct.editid#">
		</cfquery>
		<cfif qryGetCustomer.recordCount>
			<cfset variables.userExists = 1>
		</cfif>
	</cfif>

	<cfquery name="qCustomercode" datasource="#variables.dsn#">
	    SELECT CustomerCode, AYBImport, UserName, Password
	    FROM Customers
	    WHERE CustomerID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.editid#">
	 </cfquery>
    <CFSTOREDPROC PROCEDURE="USP_UpdateCustomer" DATASOURCE="#variables.dsn#">
    	<CFPROCPARAM VALUE="#arguments.formStruct.editid#" cfsqltype="CF_SQL_VARCHAR">,

      <cfif structKeyExists(arguments.formStruct, "CustomerStatusID")>
        <CFPROCPARAM VALUE="#arguments.formStruct.CustomerStatusID#" cfsqltype="CF_SQL_INTEGER">,
      <cfelse>
        <CFPROCPARAM VALUE="1" cfsqltype="CF_SQL_INTEGER">,
      </cfif>
        <cfif qCustomercode.AYBImport EQ false>
        	<CFPROCPARAM VALUE="#arguments.formStruct.CustomerCode#" cfsqltype="CF_SQL_VARCHAR">,
        <cfelse>
        	<CFPROCPARAM VALUE="#qCustomercode.CustomerCode#" cfsqltype="CF_SQL_VARCHAR">,
        </cfif>
		<CFPROCPARAM VALUE="#trim(arguments.formStruct.CustomerName)#" cfsqltype="CF_SQL_VARCHAR">,
		<CFPROCPARAM VALUE="#arguments.formStruct.Location#" cfsqltype="CF_SQL_VARCHAR">,
		<CFPROCPARAM VALUE="#arguments.formStruct.City#"  cfsqltype="CF_SQL_VARCHAR">,
        <CFPROCPARAM VALUE="#arguments.formStruct.State1#"  cfsqltype="CF_SQL_VARCHAR">,
        <CFPROCPARAM VALUE="#arguments.formStruct.Zipcode#" cfsqltype="CF_SQL_VARCHAR">,
        <CFPROCPARAM VALUE="#arguments.formStruct.website#"  cfsqltype="CF_SQL_VARCHAR">,
		<cfif arguments.formStruct.salesperson neq ''>
	        <CFPROCPARAM VALUE="#arguments.formStruct.salesperson#"  cfsqltype="CF_SQL_VARCHAR">,
	    <cfelse>
			<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR"  null="Yes">,
		</cfif>
	    <cfif arguments.formStruct.Dispatcher neq ''>
	        <CFPROCPARAM VALUE="#arguments.formStruct.Dispatcher#"  cfsqltype="CF_SQL_VARCHAR">,
	    <cfelse>
			<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR"  null="Yes">,	
		</cfif>
	    <cfif arguments.formStruct.EDIPartnerID neq ''>
	        <CFPROCPARAM VALUE="#arguments.formStruct.EDIPartnerID#"  cfsqltype="CF_SQL_VARCHAR">,
	    <cfelse>
			<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR"  null="Yes">,	
		</cfif>
		<cfif structKeyExists(arguments.formStruct, "LoadPotential") and len(arguments.formStruct.LoadPotential)>
	 		<CFPROCPARAM VALUE="#arguments.formStruct.LoadPotential#" cfsqltype="CF_SQL_VARCHAR">,
		<cfelse>
	 		<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR">,
	 	</cfif>
	 	<cfif structKeyExists(arguments.formStruct, "BestOpp")  and len(arguments.formStruct.BestOpp)>
		 	<CFPROCPARAM VALUE="#arguments.formStruct.BestOpp#" cfsqltype="CF_SQL_VARCHAR">,
		<cfelse>
	 		<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR">,
	 	</cfif>
	    <CFPROCPARAM VALUE="#replaceNoCase(replaceNoCase(arguments.formStruct.CustomerDirections, "\r", "","ALL"), "\n", "", "ALL")#" cfsqltype="CF_SQL_LONGNVARCHAR">  ,
        <CFPROCPARAM VALUE="#arguments.formStruct.CustomerNotes#" cfsqltype="CF_SQL_VARCHAR">,
        <CFPROCPARAM VALUE="#arguments.formStruct.IsPayer#" cfSqltype="Cf_SQL_BIT">,
		<CFPROCPARAM VALUE="#session.adminUserName#"  cfsqltype="CF_SQL_VARCHAR">,
		<CFPROCPARAM VALUE="#arguments.formStruct.FinanceID#" cfsqltype="CF_SQL_VARCHAR">,
		<cfif arguments.formStruct.CreditLimit contains '$'>
		  	<CFPROCPARAM VALUE="#val(right(arguments.formStruct.CreditLimit,len(arguments.formStruct.CreditLimit)-1))#" cfsqltype="Cf_Sql_MONEY">,
		<cfelse>
	      	<CFPROCPARAM VALUE="#val(arguments.formStruct.CreditLimit)#" cfsqltype="Cf_Sql_MONEY">,
		</cfif>

		<CFPROCPARAM VALUE="#val(replaceNoCase(replaceNoCase(arguments.formStruct.Balance,'$',''),',','','ALL'))#" cfsqltype="Cf_Sql_MONEY">,
		
      	<cfif arguments.formStruct.Available contains '$'>
			<CFPROCPARAM VALUE="#val(right(arguments.formStruct.Available,len(arguments.formStruct.Available)-1))#" cfsqltype="Cf_Sql_MONEY">,
	  	<cfelse>
	  		<CFPROCPARAM VALUE="#val(arguments.formStruct.Available)#" cfsqltype="Cf_Sql_MONEY">,
	  	</cfif>
      	<cfif arguments.formStruct.RatePerMile contains '$'>
			<CFPROCPARAM VALUE="#val(right(arguments.formStruct.RatePerMile,len(arguments.formStruct.RatePerMile)-1))#" cfsqltype="Cf_Sql_MONEY">,
	  	<cfelse>
	  		<CFPROCPARAM VALUE="#val(arguments.formStruct.RatePerMile)#" cfsqltype="Cf_Sql_MONEY">,
	  	</cfif>
	  	<CFPROCPARAM VALUE="#arguments.formStruct.country1#" cfsqltype="cf_sql_varCHAR">,
        <CFPROCPARAM VALUE="#cgi.REMOTE_ADDR#"  cfsqltype="cf_sql_varCHAR">,
		<CFPROCPARAM VALUE="#arguments.formStruct.CarrierNotes#" cfsqltype="CF_SQL_VARCHAR">,

	  	<cfif structKeyExists(arguments.formStruct,'RemitName') and len(arguments.formStruct.RemitName)>
			<CFPROCPARAM VALUE="#arguments.formStruct.RemitName#"  cfsqltype="CF_SQL_VARCHAR">,
		<cfelse>
			<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR" null="Yes">,
		</cfif>
		<cfif structKeyExists(arguments.formStruct,'RemitAddress') and len(arguments.formStruct.RemitAddress)>
			<CFPROCPARAM VALUE="#arguments.formStruct.RemitAddress#"  cfsqltype="CF_SQL_VARCHAR">,
		<cfelse>
			<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR" null="Yes">,
		</cfif>
		<cfif structKeyExists(arguments.formStruct,'RemitCity') and len(arguments.formStruct.RemitCity)>
			<CFPROCPARAM VALUE="#arguments.formStruct.RemitCity#"  cfsqltype="CF_SQL_VARCHAR">,
		<cfelse>
			<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR" null="Yes">,
		</cfif>
		<cfif structKeyExists(arguments.formStruct,'RemitState') and len(arguments.formStruct.RemitState)>
			<CFPROCPARAM VALUE="#arguments.formStruct.RemitState#"  cfsqltype="CF_SQL_VARCHAR">,
		<cfelse>
			<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR" null="Yes">,
		</cfif>
		<cfif structKeyExists(arguments.formStruct,'RemitZipcode') and len(arguments.formStruct.RemitZipcode)>
			<CFPROCPARAM VALUE="#arguments.formStruct.RemitZipcode#"  cfsqltype="CF_SQL_VARCHAR">,
		<cfelse>
			<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR">,
		</cfif>
		<cfif structKeyExists(arguments.formStruct,'RemitContact') and len(arguments.formStruct.RemitContact)>
			<CFPROCPARAM VALUE="#arguments.formStruct.RemitContact#"  cfsqltype="CF_SQL_VARCHAR">,
		<cfelse>
			<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR" null="Yes">,
		</cfif>
		<cfif structKeyExists(arguments.formStruct,'RemitPhone') and len(arguments.formStruct.RemitPhone)>
			<CFPROCPARAM VALUE="#arguments.formStruct.RemitPhone#"  cfsqltype="CF_SQL_VARCHAR">,
		<cfelse>
			<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR" null="Yes">,
		</cfif>
		<cfif structKeyExists(arguments.formStruct,'RemitFax') and len(arguments.formStruct.RemitFax)>
			<CFPROCPARAM VALUE="#arguments.formStruct.RemitFax#"  cfsqltype="CF_SQL_VARCHAR">,
		<cfelse>
			<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR" null="Yes">,
		</cfif>
				
		<cfif arguments.formStruct.isPayer>
	  		<cfif variables.userExists>
	  			<CFPROCPARAM VALUE="#qCustomercode.UserName#"  cfsqltype="CF_SQL_VARCHAR">,
	  		<cfelse>
	  			<CFPROCPARAM VALUE="#arguments.formStruct.CustomerUsername#"  cfsqltype="CF_SQL_VARCHAR">,
	  		</cfif>
		  	<CFPROCPARAM VALUE="#arguments.formStruct.CustomerPassword#"  cfsqltype="CF_SQL_VARCHAR">,
	  	<cfelse>
	  		<CFPROCPARAM VALUE="#qCustomercode.UserName#"  cfsqltype="CF_SQL_VARCHAR">,
		  	<CFPROCPARAM VALUE="#qCustomercode.Password#"  cfsqltype="CF_SQL_VARCHAR">,
	  	</cfif>

		<cfif structKeyExists(arguments.formStruct, "defaultCurrency")>
			<CFPROCPARAM VALUE="#arguments.formStruct.defaultCurrency#"  cfsqltype="CF_SQL_INTEGER"  null="#YesNoFormat(not Len(arguments.formStruct.defaultCurrency))#">,
		<cfelse>
			<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_INTEGER"  null="Yes">,					
		</cfif>

		<cfif isdefined('arguments.formStruct.CustomerTerms') and len(arguments.formStruct.CustomerTerms)>
	 		,<CFPROCPARAM VALUE="#arguments.formStruct.CustomerTerms#" cfsqltype="CF_SQL_VARCHAR">,
		<cfelse>
	 		,<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR" null="Yes">,
	 	</cfif>

		<cfif isdefined('arguments.formStruct.MCNumber')>
			<CFPROCPARAM VALUE="#arguments.formStruct.MCNumber#"  cfsqltype="CF_SQL_VARCHAR">,
		<cfelse>
			<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR"  null="Yes">,	
		</cfif>

		<cfif isdefined('arguments.formStruct.DOTNumber')>
			<CFPROCPARAM VALUE="#arguments.formStruct.DOTNumber#"  cfsqltype="CF_SQL_VARCHAR">,
		<cfelse>
			<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR"  null="Yes">,	
		</cfif>

		<cfif isdefined('arguments.formStruct.ConsolidateInvoices')>
			<CFPROCPARAM VALUE="1" cfsqltype="CF_SQL_BIT">,
		<cfelse>
		 	<CFPROCPARAM VALUE="0" cfsqltype="CF_SQL_BIT">,
		</cfif>
		<cfif isdefined('arguments.formStruct.SeperateJobPo')>
		 	<CFPROCPARAM VALUE="1" cfsqltype="CF_SQL_BIT">,
		<cfelse>
		 	<CFPROCPARAM VALUE="0" cfsqltype="CF_SQL_BIT">,
		</cfif>

		<cfif isdefined('arguments.formStruct.FactoringID') and len(arguments.formStruct.FactoringID)>
			<CFPROCPARAM VALUE="#arguments.formStruct.FactoringID#"  cfsqltype="CF_SQL_VARCHAR">,
		<cfelse>
			<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR"  null="Yes">,
		</cfif>
		<cfif isdefined('arguments.formStruct.TimeZone') and len(arguments.formStruct.TimeZone)>
			<CFPROCPARAM VALUE="#arguments.formStruct.TimeZone#"  cfsqltype="CF_SQL_VARCHAR">
		<cfelse>
			<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR"  null="Yes">	
		</cfif>

		<cfif isdefined('arguments.formStruct.LockSalesAgentOnLoad')>
		 	,<CFPROCPARAM VALUE="1" cfsqltype="CF_SQL_BIT">
		<cfelse>
		 	,<CFPROCPARAM VALUE="0" cfsqltype="CF_SQL_BIT">
		</cfif>
		<cfif isdefined('arguments.formStruct.LockDispatcherOnLoad')>
		 	,<CFPROCPARAM VALUE="1" cfsqltype="CF_SQL_BIT">
		<cfelse>
		 	,<CFPROCPARAM VALUE="0" cfsqltype="CF_SQL_BIT">
		</cfif>
		<cfif isdefined('arguments.formStruct.IncludeIndividualInvoices')>
		 	,<CFPROCPARAM VALUE="1" cfsqltype="CF_SQL_BIT">
		<cfelse>
		 	,<CFPROCPARAM VALUE="0" cfsqltype="CF_SQL_BIT">
		</cfif>

		<cfif structKeyExists(arguments.formStruct,'ContactPerson') and len(arguments.formStruct.ContactPerson)>
			,<CFPROCPARAM VALUE="#arguments.formStruct.ContactPerson#"  cfsqltype="CF_SQL_VARCHAR">
		<cfelse>
			,<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR">
		</cfif>

		<cfif structKeyExists(arguments.formStruct,'PhoneNO') and len(arguments.formStruct.PhoneNO)>
			,<CFPROCPARAM VALUE="#arguments.formStruct.PhoneNO#"  cfsqltype="CF_SQL_VARCHAR">
		<cfelse>
			,<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR">
		</cfif>

		<cfif structKeyExists(arguments.formStruct,'PhoneNOExt') and len(arguments.formStruct.PhoneNOExt)>
			,<CFPROCPARAM VALUE="#arguments.formStruct.PhoneNOExt#"  cfsqltype="CF_SQL_VARCHAR">
		<cfelse>
			,<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR">
		</cfif>

		<cfif structKeyExists(arguments.formStruct,'Tollfree') and len(arguments.formStruct.Tollfree)>
			,<CFPROCPARAM VALUE="#arguments.formStruct.Tollfree#"  cfsqltype="CF_SQL_VARCHAR">
		<cfelse>
			,<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR">
		</cfif>

		<cfif structKeyExists(arguments.formStruct,'TollfreeExt') and len(arguments.formStruct.TollfreeExt)>
			,<CFPROCPARAM VALUE="#arguments.formStruct.TollfreeExt#"  cfsqltype="CF_SQL_VARCHAR">
		<cfelse>
			,<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR">
		</cfif>

		<cfif structKeyExists(arguments.formStruct,'MobileNo') and len(arguments.formStruct.MobileNo)>
			,<CFPROCPARAM VALUE="#arguments.formStruct.MobileNo#"  cfsqltype="CF_SQL_VARCHAR">
		<cfelse>
			,<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR">
		</cfif>

		<cfif structKeyExists(arguments.formStruct,'MobileNoExt') and len(arguments.formStruct.MobileNoExt)>
			,<CFPROCPARAM VALUE="#arguments.formStruct.MobileNoExt#"  cfsqltype="CF_SQL_VARCHAR">
		<cfelse>
			,<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR">
		</cfif>

		<cfif structKeyExists(arguments.formStruct,'Fax') and len(arguments.formStruct.Fax)>
			,<CFPROCPARAM VALUE="#arguments.formStruct.Fax#"  cfsqltype="CF_SQL_VARCHAR">
		<cfelse>
			,<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR">
		</cfif>

		<cfif structKeyExists(arguments.formStruct,'FaxExt') and len(arguments.formStruct.FaxExt)>
			,<CFPROCPARAM VALUE="#arguments.formStruct.FaxExt#"  cfsqltype="CF_SQL_VARCHAR">
		<cfelse>
			,<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR">
		</cfif>

		<cfif structKeyExists(arguments.formStruct,'Email') and len(arguments.formStruct.Email)>
			,<CFPROCPARAM VALUE="#arguments.formStruct.Email#"  cfsqltype="CF_SQL_VARCHAR">
		<cfelse>
			,<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR">
		</cfif>
		<cfif structkeyexists(arguments.formStruct,"ConsolidateInvoiceBOL")>
		 	,<CFPROCPARAM VALUE="1" cfsqltype="CF_SQL_BIT">
		<cfelse>
		 	,<CFPROCPARAM VALUE="0" cfsqltype="CF_SQL_BIT">
		</cfif>

		<cfif structkeyexists(arguments.formStruct,"ConsolidateInvoiceRef")>
		 	,<CFPROCPARAM VALUE="1" cfsqltype="CF_SQL_BIT">
		<cfelse>
		 	,<CFPROCPARAM VALUE="0" cfsqltype="CF_SQL_BIT">
		</cfif>

		<cfif structkeyexists(arguments.formStruct,"ConsolidateInvoiceDate")>
		 	,<CFPROCPARAM VALUE="1" cfsqltype="CF_SQL_BIT">
		<cfelse>
		 	,<CFPROCPARAM VALUE="0" cfsqltype="CF_SQL_BIT">
		</cfif>
		<cfif structKeyExists(arguments.formStruct,'BillFromCompany') and len(arguments.formStruct.BillFromCompany)>
			,<CFPROCPARAM VALUE="#arguments.formStruct.BillFromCompany#"  cfsqltype="CF_SQL_VARCHAR">
		<cfelse>
			,<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR" null="true">
		</cfif>
		<cfif structKeyExists(arguments.formStruct,'InternalNotes') and len(arguments.formStruct.InternalNotes)>
			,<CFPROCPARAM VALUE="#arguments.formStruct.InternalNotes#"  cfsqltype="CF_SQL_VARCHAR">
		<cfelse>
			,<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR" null="true">
		</cfif>
		<cfif arguments.formStruct.salesperson2 neq ''>
	        	<CFPROCPARAM VALUE="#arguments.formStruct.salesperson2#"  cfsqltype="CF_SQL_VARCHAR">,
	    	<cfelse>
			<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR"  null="Yes">,
		</cfif>
	    	<cfif arguments.formStruct.Dispatcher2 neq ''>
	        	<CFPROCPARAM VALUE="#arguments.formStruct.Dispatcher2#"  cfsqltype="CF_SQL_VARCHAR">,
	    	<cfelse>
			<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR"  null="Yes">,	
		</cfif>
		<cfif isdefined('arguments.formStruct.LockDispatcher2OnLoad')>
		 	,<CFPROCPARAM VALUE="1" cfsqltype="CF_SQL_BIT">
		<cfelse>
		 	,<CFPROCPARAM VALUE="0" cfsqltype="CF_SQL_BIT">
		</cfif>
	</CFSTOREDPROC>

     <cfquery name="qDeleteCustomerOffices" datasource="#variables.dsn#">
     	DELETE FROM CustomerOffices where CustomerID=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.editid#">
	 </cfquery>

	 <cfloop list="#arguments.formStruct.officeid1#" item="ofcID">
		 <cfquery name="qInsertCustomerOffices" datasource="#variables.dsn#">
		 	INSERT INTO [CustomerOffices]
	           ([CustomerOfficesID]
	           ,[CustomerID]
	           ,[OfficeID])
	        VALUES(
	        	newid(),
	        	<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.editid#">,
	        	<cfqueryparam cfsqltype="cf_sql_varchar" value="#ofcID#">
	        	)
		 </cfquery>
	</cfloop>
	 <cfset response = structNew()>
     
     <cfif variables.userExists>
		 <cfset response['msg'] = "The username is already in use, please select a different username">
         <cfset response['customerID']=editid>
     <cfelse>
		 <cfset response['msg'] = "Customer has been updated Successfully">
        <cfset response['customerID']=editid>
     </cfif>
    <cfreturn response>
</cffunction>
<cffunction name="deleteCustomers"  access="public" output="false" returntype="any">
<cfargument name="CustomerID" type="any" required="yes">
    <cftry>
    	<cfquery name="qryChkLoad" datasource="#variables.dsn#">
    		SELECT COUNT(LoadID) AS Exist FROM Loads WHERE CustomerID = <cfqueryparam value="#arguments.CustomerID#" cfsqltype="CF_SQL_VARCHAR">
    	</cfquery>

    	<cfif qryChkLoad.Exist EQ 0>
			<cfquery name="qryDelete" datasource="#variables.dsn#">
				DELETE FROM Customers WHERE CustomerID = <cfqueryparam value="#arguments.CustomerID#" cfsqltype="CF_SQL_VARCHAR">
			</cfquery>
			<cfreturn "Customer has been deleted successfully.">
		<cfelse>
			<cfreturn "Cannot Delete Customer because related data exists. Please consider deleting other data or making the customer Inactive">
		</cfif>
		<cfcatch type="any">
			<cfreturn "Cannot Delete Customer because related data exists. Please consider deleting other data or making the customer Inactive">
		</cfcatch>
	</cftry>
</cffunction>

<!--- Search customer --->
<cffunction name="getSearchedCustomer" access="public" output="false" returntype="query">
	<cfargument name="searchText" required="yes" type="any">
    <cfargument name="pageNo" required="yes" type="any">
    <cfargument name="sortorder" required="no" type="any">
    <cfargument name="sortby" required="no" type="any">
	<cfargument name="argPayer" required="no" type="any" default="2">
	<cfargument name="officeid" required="no" type="any" default="">
	<cfargument name="pending" required="no" type="any" default="0">

	<CFSTOREDPROC PROCEDURE="searchCustomer" DATASOURCE="#variables.dsn#">
		<cfif isdefined('arguments.searchText') and len(arguments.searchText)>
		 	<CFPROCPARAM VALUE="#arguments.searchText#" cfsqltype="CF_SQL_VARCHAR">
		 <cfelse>
		 	<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR">
		 </cfif>

         <cfif isdefined('arguments.pageNo') and len(arguments.pageNo)>
		 	<CFPROCPARAM VALUE="#arguments.pageNo#" cfsqltype="cf_sql_integer">
		 <cfelse>
		 	<CFPROCPARAM VALUE="1" cfsqltype="cf_sql_integer">
		 </cfif>

         <CFPROCPARAM VALUE="30" cfsqltype="cf_sql_integer"> <!--- Page Size --->

         <cfif isdefined('arguments.sortorder') and len(arguments.sortorder)>
		 	<CFPROCPARAM VALUE="#arguments.sortorder#" cfsqltype="cf_sql_varchar">
		 <cfelse>
		 	<CFPROCPARAM VALUE="ASC" cfsqltype="cf_sql_varchar">
		 </cfif>

         <cfif isdefined('arguments.sortby') and len(arguments.sortby)>
		 	<CFPROCPARAM VALUE="#arguments.sortby#" cfsqltype="cf_sql_varchar">
		 <cfelse>
		 	<CFPROCPARAM VALUE="CustomerName" cfsqltype="cf_sql_varchar">
		 </cfif>
         <CFPROCPARAM VALUE="#argPayer#" cfsqltype="cf_sql_varchar">

		 <CFPROCPARAM VALUE="#arguments.officeid#" cfsqltype="cf_sql_varchar">
		 <CFPROCPARAM VALUE="#session.companyid#" cfsqltype="CF_SQL_VARCHAR"> 
		 <CFPROCPARAM VALUE="#arguments.pending#" cfsqltype="cf_sql_varchar">
		 <cfif (structKeyExists(session, "currentusertype") AND session.currentusertype eq 'Administrator') OR ListContains(session.rightsList,'showAllOfficeCustomers',',') OR request.qgetsystemsetupoptions.ShowAllOfficeCustomers EQ 1>
			<CFPROCPARAM VALUE="1" cfsqltype="CF_SQL_BIT">
		<cfelse>
			<CFPROCPARAM VALUE="0" cfsqltype="CF_SQL_BIT">
		</cfif>
		 <CFPROCRESULT NAME="QreturnSearch">
	</CFSTOREDPROC>
    <cfreturn QreturnSearch>
</cffunction>
<!--- Add Stop--->
<cffunction name="AddStop" access="public" output="false" returntype="any">
   <cfargument name="formStruct" type="struct" required="no" />
   <cfquery name="insertquery" datasource="#variables.dsn#">
       insert into CustomerStops(CustomerStopName,City,StateID,PostalCode,Phone,PhoneExt,Fax,ContactPerson,CreatedBy,CreatedDateTime,
	    LastModifiedBy,LastModifiedDateTime,CustomerID,EmailID,Location,NewInstructions,NewDirections,StopType)
       values(
              <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.CustomerStopName#">,
              <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.City#">,
              <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.StateID#">,
			  <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.Zipcode#">,
              <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.Phone#">,
              <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.PhoneExt#">,
              <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.Fax#">,
              <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.ContactPerson#">,
              <cfqueryparam cfsqltype="cf_sql_varchar" value="#session.adminUserName#">,
			  <cfqueryparam cfsqltype="cf_sql_date" value="#now()#">,
			  <cfqueryparam cfsqltype="cf_sql_varchar" value="#session.adminUserName#">,
			  <cfqueryparam cfsqltype="cf_sql_date" value="#now()#">,
              <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.CustomerID#">,
              <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.EmailID#">,
              <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.Location#">,
              <cfqueryparam cfsqltype="cf_sql_longvarchar" value="#arguments.formStruct.NewInstructions#">,
              <cfqueryparam cfsqltype="cf_sql_longvarchar"  value="#arguments.formStruct.NewDirections#">,
              <cfif structkeyexists(arguments.formStruct,"StopType")>
              	<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.formStruct.StopType#">
              <cfelse>
              	NULL
              </cfif>
              )
   </cfquery>
   <cfreturn "Stop has been added Successfully">
</cffunction>

<!--- Update Stop--->
<cffunction name="UpdateStop" access="public" output="false" returntype="any">
   <cfargument name="formStruct" type="struct" required="no" />
   <cfquery name="insertquery" datasource="#variables.dsn#">
       update CustomerStops
	   set
	        CustomerStopName = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.CustomerStopName#">,
            City= <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.City#">,
            StateID= <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.StateID#">,
			PostalCode=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.Zipcode#">,
            Phone=  <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.Phone#">,
            PhoneExt=  <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.PhoneExt#">,
            Fax = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.Fax#">,
            ContactPerson=  <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.ContactPerson#">,
			LastModifiedBy =<cfqueryparam cfsqltype="cf_sql_varchar" value="#session.adminUserName#">,
			LastModifiedDateTime= <cfqueryparam cfsqltype="cf_sql_date" value="#now()#">,
            CustomerID= <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.CustomerID#">,
            EmailID= <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.EmailID#">,
            Location = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.Location#">,
            NewInstructions= <cfqueryparam cfsqltype="cf_sql_longvarchar" value="#arguments.formStruct.NewInstructions#">,
            NewDirections = <cfqueryparam cfsqltype="cf_sql_longvarchar"  value="#arguments.formStruct.NewDirections#">,
            UpdatedByIp=<cfqueryparam cfsqltype="cf_sql_varchar" value="#cgi.REMOTE_ADDR#">
            <cfif structkeyexists(arguments.formStruct,"StopType")>
            	,StopType= <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.formStruct.StopType#">
            </cfif>
			where CustomerStopID=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.editid#">

   </cfquery>
   <cfreturn "Stop has been Updated Successfully">
</cffunction>

<!----Get All Stop Information---->
<cffunction name="getAllStop" access="public" output="false" returntype="any">
    <cfargument name="CustomerStopID" required="no" type="any">
 	<CFSTOREDPROC PROCEDURE="USP_GetStopDetails" DATASOURCE="#variables.dsn#">
		<cfif isdefined('arguments.CustomerStopID') and len(arguments.CustomerStopID)>
		 	<CFPROCPARAM VALUE="#arguments.CustomerStopID#" cfsqltype="CF_SQL_VARCHAR">
		 <cfelse>
		 	<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR">
		 </cfif>
		 <CFPROCRESULT NAME="qrygetStops">
	</CFSTOREDPROC>
    <cfreturn qrygetStops>
</cffunction>

<!----Get All Stop Information By Customer---->
<cffunction name="getAllStopByCustomer" access="public" output="false" returntype="any">
    <cfargument name="CustomerID" required="no" type="any">
    <cfargument name="sortorder" required="no" type="any">
    <cfargument name="sortby" required="no" type="any">
         	<CFSTOREDPROC PROCEDURE="USP_GetStopDetailsByCustomer" DATASOURCE="#variables.dsn#">
				<cfif isdefined('arguments.CustomerID') and len(arguments.CustomerID)>
				 	<CFPROCPARAM VALUE="#arguments.CustomerID#" cfsqltype="CF_SQL_VARCHAR">
				 <cfelse>
				 	<CFPROCPARAM VALUE="" cfsqltype="CF_SQL_VARCHAR">
				 </cfif>
				 <CFPROCRESULT NAME="qrygetStops">
			</CFSTOREDPROC>

     <cfif isDefined("arguments.sortorder") and isDefined("arguments.sortby") and len(arguments.sortby)>

                 <cfquery datasource="#variables.dsn#" name="getnewAgent">
                             select CustomerStops.*, Customers.CustomerName from CustomerStops
                             inner join Customers on Customers.CustomerID=CustomerStops.CustomerID
                             where Customers.customerid 
                             <cfif isdefined('arguments.CustomerID') and len(arguments.CustomerID)>
                             =<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.CustomerID#">
                             <cfelse>
                             	in (select customerid from CustomerOffices inner join offices on CustomerOffices.officeid = offices.officeid where offices.companyid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#session.companyid#">)
                             </cfif>
                             order by #arguments.sortby# #arguments.sortorder#;
                 </cfquery>

                <cfreturn getnewAgent>

      </cfif>

<cfreturn qrygetStops>
</cffunction>



<!--- Get Shipper--->
<cffunction name="getShipper" access="public" output="false" returntype="any">
	<CFSTOREDPROC PROCEDURE="USP_GetShippersFromCustomersTable" DATASOURCE="#variables.dsn#">
		 <CFPROCRESULT NAME="qryGetShipperFrmCustomersTable">
	</CFSTOREDPROC>
	<cfreturn qryGetShipperFrmCustomersTable>
</cffunction>


<!--- Delete Stop--->
<cffunction name="deleteStop"  access="public" output="false" returntype="any">
<cfargument name="CustomerStopID" type="any" required="yes">
    <cftry>
		<cfquery name="qryDelete" datasource="#variables.dsn#">
			 DELETE FROM CustomerStops WHERE CustomerStopID=<cfqueryparam cfsqltype="cf_sql_varchar" value='#arguments.CustomerStopID#'>
		</cfquery>
		<cfreturn "Stop has been deleted successfully.">
		<cfcatch type="any">
			<cfreturn "Delete operation has been not successfull. This record is being used by other module.">
		</cfcatch>
	</cftry>
</cffunction>

<!--- Search Stop --->
<cffunction name="getSearchedStop" access="public" output="false" returntype="query">
	<cfargument name="searchText" required="yes" type="any">
	<CFSTOREDPROC PROCEDURE="searchStops" DATASOURCE="#variables.dsn#">
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

<!--- Get State Id by state code--->
<cffunction name="getStatesID" access="remote" output="false" returntype="any">
    <cfargument name="stateCode" type="string" required="yes">
	<cfquery name="qrygetState" datasource="freightAgency">
      select stateID as stid from states
      where statecode = <cfqueryparam cfsqltype="cf_sql_varchar" value='#arguments.stateCode#'>
    </cfquery>
	 <cfreturn qrygetState.stid>
</cffunction>
	<cffunction name="getAllpayerCustomers" access="public" output="false" returntype="any">
		<cfquery name="qryGetCustomers" datasource="#variables.dsn#">
			select customers.* from  customers
			inner join (select
						    customerid
							from CustomerOffices c1 inner join offices o1 on o1.officeid = c1.OfficeID
							where o1.CompanyID = <cfqueryparam value= "#session.companyid#" cfSqltype="varchar">
							group by customerid) Offices ON Offices.CustomerID = customers.CustomerID
			where IsPayer=<cfqueryparam cfsqltype="cf_sql_bit" value="1">
			and username IS NOT NULL and password IS NOT NULL
			order by CustomerName asc
		</cfquery>
		<cfreturn qryGetCustomers>
	</cffunction>

	<!---function to get the user editing details for corresponding customer --->
	<cffunction name="getUserEditingDetails" access="public" returntype="query">
		<cfargument name="customerid" type="string" required="yes"/>
		<!---Query to get the user editing details for corresponding customer--->
		
		<cfquery name="qryUpdateEditingUserId" datasource="#Application.dsn#">
			select  InUseBy,InUseOn from Customers
			where CustomerID=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.customerid#">
		</cfquery>

		<cfreturn qryUpdateEditingUserId>
	</cffunction>

	<!---function to update the userid for corresponding customers--->
	<cffunction name="removeUserAccessOnLoad" access="remote" returntype="struct" returnformat="json">
		<cfargument name="dsn" type="string" required="yes"/>
		<cfargument name="customerid" type="string" required="yes"/>
			<cfset var customers=StructNew()>
			<!---Query to get the userid--->
			<cfquery name="qryGetUserId" datasource="#arguments.dsn#" result="result">
				select InUseBy,InUseOn,CustomerCode from Customers where CustomerID=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.customerid#">
			</cfquery>

			<!-- Return if lock already removed-->
			<cfif len(trim(qryGetUserId.InUseBy)) eq 0>
				<cfset customers.msg = "No Lock Exist!" />
				<cfreturn customers>
			</cfif> 

			<!---Query to get editing User Name--->
			<cfquery name="qryGetUserName" datasource="#arguments.dsn#" result="result">
				SELECT NAME
				FROM employees
				WHERE employeeID = <cfqueryparam value="#qryGetUserId.inuseby#" cfsqltype="cf_sql_varchar">
			</cfquery>
			<cfset customer.userName=qryGetUserName.NAME>

			<cfset customer.onDateTime=dateformat(qryGetUserId.InUseOn,"mm/dd/yy hh:mm:ss")>
			<cfset customer.dsn=arguments.dsn>
			<!---Query to update the userid for corresponding loads to null--->
			<cfquery name="qryUpdateEditingUserId" datasource="#arguments.dsn#" result="result">
				UPDATE Customers
				SET
				InUseBy=null,
				InUseOn=null
				where CustomerId=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.customerid#">
			</cfquery>
			<cfreturn customers>
	</cffunction>
	<!---function to update the userid for corresponding customer--->
	<cffunction name="updateEditingUserId" access="public" returntype="void">
		<cfargument name="userid" type="string" required="yes"/>
		<cfargument name="customerid" type="string" required="yes"/>
		<cfargument name="status" type="boolean" required="yes"/>
		<cftry>
			<cfif  arguments.status>
				<!---Query to update the userid for corresponding customers to null--->
				<cfquery name="qryUpdateEditingUserId" datasource="#Application.dsn#" result="result">
					UPDATE Customers
					SET
					InUseBy=null,
					InUseOn=null,
					sessionid=null
					where InUseBy=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.userid#">
				</cfquery>
			<cfelse>
				<!---Query to update the userid for corresponding Customers--->
				<cfquery name="qryUpdateEditingUserId" datasource="#Application.dsn#" result="result">
					UPDATE Customers
					SET
					InUseBy=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.userid#">,
					InUseOn=<cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">,
					sessionid=<cfqueryparam cfsqltype="cf_sql_varchar" value="#session.sessionid#">
					where customerid=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.customerid#">
				</cfquery>
			</cfif>
			<cfcatch>
				<cfdocument format="pdf" filename="C:\pdf\CustomerLock_#DateTimeFormat(now(),"YYYY_MM_dd_HH_nn_ss_l")#.pdf" overwrite="true">
					<cfdump var="#arguments#">
					<cfdump var="#cfcatch#">
				</cfdocument>
			</cfcatch>
		</cftry>
	</cffunction>
	<!---function to insert UserBrowserTabDetails--->
	<cffunction name="insertTabDetails" access="remote" output="yes" returnformat="json">
		<cfargument name="tabID" type="any" required="yes">
		<cfargument name="customerid" type="any" required="yes">
		<cfargument name="sessionid" type="any" required="yes">
		<cfargument name="userid" type="any" required="yes">
		<cfargument name="dsn" type="any" required="yes">
		<!---query to select UserBrowserTabDetails--->
		<cfquery name="qryGetBrowserTabDetails" datasource="#arguments.dsn#">
			select * from  UserBrowserTabDetails
			where 1=1
			and customerid=<cfqueryparam value="#arguments.customerid#" cfsqltype="cf_sql_varchar">
			and sessionid=<cfqueryparam value="#arguments.sessionid#" cfsqltype="cf_sql_varchar">
			and userid=<cfqueryparam value="#arguments.userid#" cfsqltype="cf_sql_varchar">
			and tabID=<cfqueryparam value="#arguments.tabID#" cfsqltype="cf_sql_varchar">
		</cfquery>
		<cfif not qryGetBrowserTabDetails .recordcount>
			<!---Query to insert UserBrowserTabDetails--->
			<cfquery name="qryInsertGetBrowserTabDetails" datasource="#arguments.dsn#">
				INSERT INTO UserBrowserTabDetails (userid, customerid, tabid, sessionid, createddate)
	            VALUES (<cfqueryparam value="#arguments.userid#" cfsqltype="cf_sql_varchar">,
						<cfqueryparam value="#arguments.customerid#" cfsqltype="cf_sql_varchar">,
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
		<cfargument name="customerid" type="any" required="yes">
		<!---query to delete UserBrowserTabDetails--->
		<cfquery name="qryGetBrowserTabDetails" datasource="#arguments.dsn#">
			delete from  UserBrowserTabDetails
			where
			 sessionid=<cfqueryparam value="#arguments.sessionid#" cfsqltype="cf_sql_varchar">
			and userid=<cfqueryparam value="#arguments.userid#" cfsqltype="cf_sql_varchar">
			and tabID=<cfqueryparam value="#arguments.tabID#" cfsqltype="cf_sql_varchar">
			and CustomerId=<cfqueryparam value="#arguments.customerid#" cfsqltype="cf_sql_varchar">
		</cfquery>
	</cffunction>


	<!--- Get Session Ajax version--->
	<cffunction name="getAjaxSession" access="remote" output="yes" returnformat="json">
		<cfargument name="UnlockStatus" type="any" required="no">
		<cfargument name="customerid" type="any" required="no">
		<cfargument name="dsn" type="any" required="no">
		<cfargument name="sessionid" type="any" required="no">
		<cfargument name="userid" type="any" required="no">
		<cfargument name="tabid" type="any" required="no">
		<cfargument name="saveEvent" type="any" required="no">


		<cfif structkeyexists(arguments,"tabid")>
			<!----query to delete -corresponding rows of tabid--->
			<cfquery name="qryGetBrowserTabDetails" datasource="#arguments.dsn#">
				delete from  UserBrowserTabDetails
				where tabID=<cfqueryparam value="#arguments.tabid#" cfsqltype="cf_sql_varchar">
			</cfquery>
		</cfif>
		<cfif structkeyexists(arguments,"UnlockStatus") and structkeyexists(arguments,"customerid") and arguments.UnlockStatus eq false and len(trim(arguments.customerid)) gt 1 and structkeyexists(arguments,"dsn") and structkeyexists(arguments,"sessionid") and structkeyexists(arguments,"userid") and not structkeyexists(arguments, 'saveEvent')>
			<!---Query to select browser tab details--->
			<cfquery name="qryGetBrowsertabDetails" datasource="#arguments.dsn#">
				select id from UserBrowserTabDetails
				where
					customerid=<cfqueryparam value="#arguments.customerid#" cfsqltype="cf_sql_varchar">
				and sessionid=<cfqueryparam value="#arguments.sessionid#" cfsqltype="cf_sql_varchar">
				and userid=<cfqueryparam value="#arguments.userid#" cfsqltype="cf_sql_varchar">
			</cfquery>
		
			<cfif not qryGetBrowsertabDetails.recordcount>

				<!---Query to remove lock --->
				<cfquery name="qryGetInuseBy" datasource="#arguments.dsn#">
					update Customers
					set
						InUseBy=null,
						InUseOn=null,
						sessionId=null
					where customerid=<cfqueryparam value="#arguments.customerid#" cfsqltype="cf_sql_varchar">
					and InUseBy = <cfqueryparam value="#arguments.userid#" cfsqltype="cf_sql_varchar">
				</cfquery>
			</cfif>
		</cfif>
	 
	</cffunction>

	<cffunction name="getMultipleOffices" access="public" returntype="query">
		<cfargument name="MultipleOfficeIds" type="string" required="yes"/>
		
		<cfquery name="qrygetMultipleOffices" datasource="#Application.dsn#">
			SELECT Location FROM Offices
			WHERE OfficeID IN (<cfqueryparam 
                value="#arguments.MultipleOfficeIds#" 
                cfsqltype="CF_SQL_VARCHAR"
                list="yes" 
                /> )
			ORDER BY Location
		</cfquery>

		<cfreturn qrygetMultipleOffices>
	</cffunction>

	<cffunction name="getConsolidateLoads" access="public" output="false" returntype="query">
		<cfargument name="searchText" required="yes" type="any" default="">
	    <cfargument name="pageNo" required="yes" type="any" default="-1">
	    <cfargument name="sortorder" required="no" type="any" default="ASC">
	    <cfargument name="sortby" required="no" type="any" default="LP.StopDate,L.CustName,L.LoadNumber">

	    <cfquery name="qGetSystemConfig" datasource="#Application.dsn#">
			SELECT ConsolidateInvoiceTriggerStatus FROM SystemConfig WHERE CompanyID = <cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar">
		</cfquery>

	    <cfquery name="qConsolidateLoads" datasource="#Application.dsn#">
	    	<cfif arguments.pageNo neq -1>WITH page AS (</cfif>
	    	SELECT 
			L.LoadNumber
			,L.LoadID
			,LST.StatusText
			,LST.StatusDescription
			,L.CustName
			,L.CustomerPONo
			,LP.StopDate AS ShipDate
			,LP.StopTime AS ShipTime
			,LP.City AS ShipCity
			,LP.StateCode AS ShipState
			,LD.StopDate AS DelDate
			,LD.StopTime AS DelTime
			,LD.City AS DelCity
			,LD.StateCode AS DelState
			,L.TotalCustomerCharges
			,L.TotalCarrierCharges
			,ISNULL(l.CarrierName,l.LoadDriverName) AS CarrierName
			,L.EquipmentName
			,L.DriverName 
			,E.EmpDispatch
			,L.SalesAgent
			,LST.ColorCode
			,LST.TextColorCode
			,(select count(attachment_Id) from FileAttachments where (linked_Id = CONVERT(varchar(50),L.LoadID) OR linked_Id = CONVERT(varchar(50),L.CustomerID)) AND Billingattachments = 1 AND attachmentFileName not like '%.pdf' AND attachmentFileName not like '%.jpg'AND attachmentFileName not like '%.jpeg' AND attachmentFileName not like '%.png' AND attachmentFileName not like '%.gif') AS UnSupportedBillingDocuments
			,ROW_NUMBER() OVER (ORDER BY
                   #arguments.sortBy#  #arguments.sortOrder#
            ) AS Row
			FROM LOADS L
			INNER JOIN (SELECT
					    CustomerID
						from CustomerOffices c1 INNER JOIN offices o1 ON o1.officeid = c1.OfficeID
						WHERE o1.CompanyID = '#session.companyid#'
						GROUP BY customerid) Offices ON Offices.CustomerID = L.CustomerID
			JOIN (SELECT LS.LoadID,LS.City,LS.StateCode,LS.StopDate,LS.StopTime FROM LoadStops LS WHERE LS.StopNo = 0 AND LS.LoadType = 1) LP ON LP.LoadID = L.LoadID
			JOIN (SELECT LS.LoadID,LS.City,LS.StateCode,LS.StopDate,LS.StopTime FROM LoadStops LS WHERE LS.StopNo = (SELECT MAX(LS1.StopNo) FROM LoadStops LS1 WHERE LS1.LoadID = LS.LoadID) AND LS.LoadType = 2) LD ON LD.LoadID = L.LoadID
			JOIN LoadStatusTypes LST ON L.StatusTypeID = LST.StatusTypeID
			JOIN (SELECT Name as EmpDispatch,EmployeeID FROM Employees) as E on E.EmployeeID =L.DispatcherID
			WHERE L.StatusTypeID IN (<cfqueryparam value="#qGetSystemConfig.ConsolidateInvoiceTriggerStatus#" cfsqltype="cf_sql_varchar" list="true" null="#yesNoFormat(NOT len(qGetSystemConfig.ConsolidateInvoiceTriggerStatus))#">)
			AND (SELECT C.ConsolidateInvoices FROM Customers C WHERE C.CustomerID = L.CustomerID) = 1
			AND (SELECT COUNT(LCD.LoadID) from LoadsConsolidatedDetail LCD WHERE LCD.LoadID = L.LoadID) = 0
			<cfif isDefined("arguments.searchText") and len(arguments.searchText)>
				AND 
				(
					L.LoadNumber like <cfqueryparam cfsqltype="cf_sql_varchar" value="%#arguments.searchText#%">
					OR LST.StatusText like <cfqueryparam cfsqltype="cf_sql_varchar" value="%#arguments.searchText#%">
					OR L.CustName like <cfqueryparam cfsqltype="cf_sql_varchar" value="%#arguments.searchText#%">
					OR L.CustomerPONo like <cfqueryparam cfsqltype="cf_sql_varchar" value="%#arguments.searchText#%">
					OR L.EquipmentName like <cfqueryparam cfsqltype="cf_sql_varchar" value="%#arguments.searchText#%">
					OR L.DriverName like <cfqueryparam cfsqltype="cf_sql_varchar" value="%#arguments.searchText#%">
					OR E.EmpDispatch like <cfqueryparam cfsqltype="cf_sql_varchar" value="%#arguments.searchText#%">
					OR L.SalesAgent like <cfqueryparam cfsqltype="cf_sql_varchar" value="%#arguments.searchText#%">
					OR ISNULL(l.CarrierName,l.LoadDriverName) like <cfqueryparam cfsqltype="cf_sql_varchar" value="%#arguments.searchText#%">
				)
			</cfif>
			<cfif arguments.pageNo neq -1>
                )
                SELECT *,(select (max(row)/30) + (CASE WHEN max(row)%30 <> 0 THEN 1 ELSE 0 END)  FROM page) AS TotalPages  FROM page WHERE Row between (<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.pageNo#"> - 1) * 30 + 1 and <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.pageNo#"> * 30
            </cfif>
		</cfquery>


	    <cfreturn qConsolidateLoads>
	</cffunction>

	<cffunction name="getConsolidateInvoiceQueue" access="public" output="false" returntype="query">
		<cfargument name="searchText" required="yes" type="any" default="">
	    <cfargument name="pageNo" required="yes" type="any" default="-1">
	    <cfargument name="sortorder" required="no" type="any" default="ASC">
	    <cfargument name="sortby" required="no" type="any" default="LC.ConsolidatedInvoiceNumber">

	    <cfquery name="qConsolidateInvoiceQueue" datasource="#Application.dsn#">
	    	<cfif arguments.pageNo neq -1>WITH page AS (</cfif>
	    	SELECT 
	    		LC.ID
				,LC.ConsolidatedInvoiceNumber
				,LC.Description
				,LC.Date
				,'TESTREF' AS Reference
				,(SELECT SUM(L.TotalCustomerCharges) FROM Loads L WHERE L.LoadID IN (SELECT LCD.LoadID FROM LoadsConsolidatedDetail LCD WHERE LCD.ConsolidatedID = LC.ID)) AS Amount
				,LC.LoadCount
				,LC.Status
				,LC.CustomerID
				,ROW_NUMBER() OVER (ORDER BY
	                   #arguments.sortBy#  #arguments.sortOrder#
	            ) AS Row
			FROM LoadsConsolidated LC
			WHERE LC.CustomerID in (select customerid from CustomerOffices inner join offices on CustomerOffices.officeid = offices.officeid where offices.companyid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#session.companyid#">)
			<cfif isDefined("arguments.searchText") and len(arguments.searchText)>
				AND 
				(
					LC.ConsolidatedInvoiceNumber like <cfqueryparam cfsqltype="cf_sql_varchar" value="%#arguments.searchText#%">
					OR LC.Description like <cfqueryparam cfsqltype="cf_sql_varchar" value="%#arguments.searchText#%">
					OR LC.Amount like <cfqueryparam cfsqltype="cf_sql_varchar" value="%#arguments.searchText#%">
					OR LC.LoadCount like <cfqueryparam cfsqltype="cf_sql_varchar" value="%#arguments.searchText#%">
					OR LC.Status like <cfqueryparam cfsqltype="cf_sql_varchar" value="%#arguments.searchText#%">
				)
			</cfif>
			<cfif arguments.pageNo neq -1>
                )
                SELECT *,(select (max(row)/30) + (CASE WHEN max(row)%30 <> 0 THEN 1 ELSE 0 END)  FROM page) AS TotalPages  FROM page WHERE Row between (<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.pageNo#">  - 1) * 30 + 1 and <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.pageNo#">  * 30
            </cfif>
		</cfquery>


	    <cfreturn qConsolidateInvoiceQueue>
	</cffunction>

	<cffunction name="PushDataToProject44Api" access="remote" output="yes" returnformat="json">
		<cfargument name="customerid" required="yes" type="any">
		<cfargument name="dsn" required="yes" type="any">
		<cfargument name="PushDataToProject44Api" required="yes" type="any">
		<cfargument name="Project44ApiUsername" required="yes" type="any">
		<cfargument name="Project44ApiPassword" required="yes" type="any">
		<cfset response = structNew()>

		<cftry>
			<cfquery name="updateCustomer" datasource="#arguments.dsn#">
				UPDATE Customers
				SET
					PushDataToProject44Api = <cfqueryparam value="#arguments.PushDataToProject44Api#" cfsqltype="cf_sql_bit">
					,Project44ApiUsername = <cfqueryparam value="#arguments.Project44ApiUsername#" cfsqltype="cf_sql_varchar">
					,Project44ApiPassword = <cfqueryparam value="#arguments.Project44ApiPassword#" cfsqltype="cf_sql_varchar">
				WHERE customerid = <cfqueryparam value="#arguments.customerid#" cfsqltype="cf_sql_varchar">
			</cfquery>

			<cfset response.success = 1>
			<cfset response.msg = "Updated successfully.">
			<cfreturn response>

			<cfcatch>
				<cfset response.success = 0>
				<cfset response.msg = "Something went wrong. Please contact support">
				<cfreturn response>
			</cfcatch>
		 </cftry>
	</cffunction>

	<cffunction name="getConsolidatedInvoiceInformation" access="public" output="false" returntype="query">
		<cfargument name="ID" required="yes" type="any" default="">

		<cfquery name="qGetConsolidatedInvoiceInformation" datasource="#Application.dsn#">
			SELECT 
			ConsolidatedInvoiceNumber,
			REL,
			JOB,
			PaymentTerms,
			Comment,
			LC.CustomerID,
			LC.Status,
			(SELECT ShipperCity + ' ' + ShipperState + ' TO ' + ConsigneeCity + ' ' + ConsigneeState FROM Loads WHERE LoadID = (SELECT TOP 1 LoadID FROM LoadsConsolidatedDetail WHERE ConsolidatedID = ID)) AS LoadRoute,
			(SELECT TOP 1 Description FROM LoadStopCommodities WHERE LoadStopID in (SELECT TOP 1 LoadStopID FROM LoadStops WHERE LoadID = (SELECT TOP 1 LoadID FROM LoadsConsolidatedDetail WHERE ConsolidatedID = ID) AND LoadType=1)) AS Description,
			(SELECT SeperateJobPo FROM Customers WHERE Customers.CustomerID = LC.CustomerID) AS SeperateJobPo,
			JobEdited,
			ISNULL(LC.InvoiceDate,getdate()) AS InvoiceDate
			FROM LoadsConsolidated LC
			WHERE ID = <cfqueryparam value="#arguments.ID#" cfsqltype="cf_sql_varchar">
		</cfquery>

		<cfreturn qGetConsolidatedInvoiceInformation>
	</cffunction>

	<cffunction name="setConsolidatedInvoiceInformation" access="public" output="false" returntype="boolean">
		<cfargument name="ID" required="yes" type="any" default="">
		<cfargument name="REL" required="yes" type="any" default="">
		<cfargument name="JOB" required="yes" type="any" default="">
		<cfargument name="PaymentTerms" required="yes" type="any" default="">
		<cfargument name="Comment" required="yes" type="any" default="">
		<cfargument name="InvoiceDate" required="yes" type="any" default="">
		<cftry>
			<cfquery name="sGetConsolidatedInvoiceInformation" datasource="#Application.dsn#">
				UPDATE LoadsConsolidated
				SET 
				REL= <cfqueryparam value="#arguments.REL#" cfsqltype="cf_sql_varchar">,
				JOB= <cfqueryparam value="#arguments.JOB#" cfsqltype="cf_sql_varchar">,
				PaymentTerms= <cfqueryparam value="#arguments.PaymentTerms#" cfsqltype="cf_sql_varchar">,
				Comment = <cfqueryparam value="#arguments.Comment#" cfsqltype="cf_sql_varchar">,
				JobEdited = 1,
				InvoiceDate = <cfqueryparam value="#arguments.InvoiceDate#" cfsqltype="cf_sql_date">
				WHERE ID = <cfqueryparam value="#arguments.ID#" cfsqltype="cf_sql_varchar">
			</cfquery>
			<cfreturn 1>
			<cfcatch>
				<cfreturn 0>
			</cfcatch>
		</cftry>

	</cffunction>

	<cffunction name="getSearchedCRMNoteTypes" access="public" output="false" returntype="query">
		<cfargument name="searchText" required="yes" type="any" default="">
	    <cfargument name="pageNo" required="yes" type="any" default="-1">
	    <cfargument name="sortorder" required="no" type="any" default="ASC">
	    <cfargument name="sortby" required="no" type="any" default="C.NoteType">

	    <cfquery name="qCRMNoteTypes" datasource="#Application.dsn#">
	    	<cfif arguments.pageNo neq -1>WITH page AS (</cfif>
	    	SELECT 
	    		C.CRMNoteTypeID,
	    		C.NoteType,
	    		C.Description,
	    		C.CRMType,
				ROW_NUMBER() OVER (ORDER BY
	                   #arguments.sortBy#  #arguments.sortOrder#
	            ) AS Row
			FROM CRMNoteTypes C
			WHERE companyid = '#session.companyid#'
			<cfif isDefined("arguments.searchText") and len(arguments.searchText)>
				AND 
				(
					C.NoteType like <cfqueryparam cfsqltype="cf_sql_varchar" value="%#arguments.searchText#%">
					OR C.Description like <cfqueryparam cfsqltype="cf_sql_varchar" value="%#arguments.searchText#%">
					OR C.CRMType like <cfqueryparam cfsqltype="cf_sql_varchar" value="%#arguments.searchText#%">
				)
			</cfif>
			<cfif arguments.pageNo neq -1>
                )
                SELECT * FROM page WHERE Row between (<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.pageNo#"> - 1) * 30 + 1 and <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.pageNo#">  * 30
            </cfif>
		</cfquery>
		<cfreturn qCRMNoteTypes>
	</cffunction>

	<cffunction name="getCRMNoteTypeDuplicate" access="remote" output="false" returntype="any" returnFormat="plain">

		<cfargument name="NoteType" required="true">
		<cfargument name="CRMType" required="true">
		<cfargument name="editid" required="true">
		<cfargument name="companyid" required="true">
		<cfset local.dsn = trim(listFirst(cgi.SCRIPT_NAME,'/'))>
		<cfquery name="qryCRMNoteTypecheck" datasource="#local.dsn#">
			select NoteType from CRMNoteTypes
			where
				NoteType = <cfqueryparam value="#arguments.NoteType#" cfsqltype="cf_sql_varchar">
				AND CRMType = <cfqueryparam value="#arguments.CRMType#" cfsqltype="cf_sql_varchar">
				<cfif len(trim(arguments.editid))>
					AND CRMNoteTypeID <> <cfqueryparam value="#arguments.editid#" cfsqltype="cf_sql_varchar">
				</cfif>
				AND CompanyID = <cfqueryparam value="#arguments.companyid#" cfsqltype="cf_sql_varchar">
		</cfquery>
		<cfif qryCRMNoteTypecheck.recordcount>
			<cfreturn 0>
		</cfif>
		<cfreturn 1>
	</cffunction>

	<cffunction name="insertCRMNoteType" access="public" output="false" returntype="any">
	   	<cfargument name="formStruct" type="struct" required="no" />

	   	<cfquery name="qGetCRMNoteTypeID" datasource="#variables.dsn#">
	   		SELECT NewID() AS CRMNoteTypeID
	   	</cfquery>

		<cfquery name="insertquery" datasource="#variables.dsn#">
		   	INSERT INTO CRMNoteTypes(
		   	 	CRMNoteTypeID
	           ,NoteType
	           ,Description
	           ,CRMType
	           ,CreatedBy
	           ,LastModifiedBy
	           ,CompanyID
		   	)
		   	values(	
		   			<cfqueryparam cfsqltype="cf_sql_varchar" value="#qGetCRMNoteTypeID.CRMNoteTypeID#">
		   			,<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.NoteType#">
		   			,<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.Description#">
		   			,<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.CRMType#">
		   			,<cfqueryparam cfsqltype="cf_sql_varchar" value="#session.adminUserName#">
		   			,<cfqueryparam cfsqltype="cf_sql_varchar" value="#session.adminUserName#">
		   			,<cfqueryparam cfsqltype="cf_sql_varchar" value="#session.CompanyID#">
				  )
	   </cfquery>

	   <cfreturn qGetCRMNoteTypeID.CRMNoteTypeID>
	</cffunction>

	<cffunction name="getCRMNoteTypeDetails" access="public" output="false" returntype="query">
		<cfargument name="CRMNoteTypeID" required="no" type="any" default="">

	    <cfquery name="qCRMNoteType" datasource="#Application.dsn#">
	    	SELECT * FROM CRMNoteTypes
	    	WHERE CompanyID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#session.CompanyID#">
	    	<cfif structkeyexists(arguments,"CRMNoteTypeID") AND len(trim(arguments.CRMNoteTypeID))>
	    		AND CRMNoteTypeID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.CRMNoteTypeID#">
	    	</cfif>
		</cfquery>
	
		<cfreturn qCRMNoteType>
	</cffunction>

	<cffunction name="updadeCRMNoteType" access="public" output="false" returntype="any">
	   	<cfargument name="formStruct" type="struct" required="no" />

		<cfquery name="updatequery" datasource="#variables.dsn#">
		   	UPDATE CRMNoteTypes SET 
		   	 	NoteType=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.NoteType#">
	           ,Description=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.Description#">
	           ,CRMType=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.CRMType#">
	           ,LastModifiedBy=<cfqueryparam cfsqltype="cf_sql_varchar" value="#session.adminUserName#">
	        WHERE CRMNoteTypeID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formStruct.editid#">
	   </cfquery>

	   <cfreturn arguments.formStruct.editid>
	</cffunction>

	<cffunction name="deleteCRMNoteType" access="public" output="false" returntype="any">
	   	<cfargument name="CRMNoteTypeID" type="string" required="yes" />

		<cfquery name="deletequery" datasource="#variables.dsn#">
		   	DELETE FROM CRMNoteTypes 
	        WHERE CRMNoteTypeID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.CRMNoteTypeID#">
	   </cfquery>

	   <cfreturn arguments.CRMNoteTypeID>
	</cffunction>

	<cffunction name="getSearchedCRMNotes" access="public" output="false" returntype="query">
		<cfargument name="searchText" required="yes" type="any" default="">
	    <cfargument name="pageNo" required="yes" type="any" default="-1">
	    <cfargument name="sortorder" required="no" type="any" default="DESC">
	    <cfargument name="sortby" required="no" type="any" default="C.CreatedDateTime">
	    <cfargument name="CustomerID" required="yes" type="any" default="">

	    <cfquery name="qCRMNotes" datasource="#Application.dsn#">
	    	<cfif arguments.pageNo neq -1>WITH page AS (</cfif>
	    	SELECT 
	    		C.CRMNoteID,
	    		C.Note,
	    		C.NoteUser,
	    		C.CreatedDateTime,
	    		CT.NoteType,
				ROW_NUMBER() OVER (ORDER BY
	                   #arguments.sortBy#  #arguments.sortOrder#
	            ) AS Row
			FROM CRMNotes C
			INNER JOIN CRMNoteTypes CT ON CT.CRMNoteTypeID = C.CRMNoteTypeID
			WHERE CustomerID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.CustomerID#">
			AND CT.CRMType = 'Customer'
			<cfif arguments.pageNo neq -1>
                )
                SELECT * FROM page WHERE Row between (<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.pageNo#"> - 1) * 30 + 1 and <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.pageNo#"> * 30
            </cfif>
		</cfquery>

		<cfreturn qCRMNotes>
	</cffunction>

	<cffunction name="saveCRMCallFrequency" access="remote" output="false" returntype="any" returnFormat="plain">

		<cfargument name="CallFrequency" required="true">
		<cfargument name="NextCall" required="true">
		<cfargument name="editid" required="true">

		<cfset local.dsn = trim(listFirst(cgi.SCRIPT_NAME,'/'))>
		<cfquery name="qrysaveCRMCallFrequency" datasource="#local.dsn#">
			UPDATE Customers 
			SET CRMCallFrequency = 
			<cfif len(trim(arguments.CallFrequency))>
				<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#arguments.CallFrequency#">
			<cfelse>
				NULL
			</cfif>
			<cfif len(trim(arguments.NextCall))>
				,CRMNextCallDate = <cfqueryparam cfsqltype="cf_sql_date" value="#arguments.NextCall#">
			<cfelse>
				,CRMNextCallDate = <cfqueryparam cfsqltype="cf_sql_date" value="" null="true">
			</cfif>
			WHERE CustomerID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.editid#">
		</cfquery>
		
	</cffunction>

	<cffunction name="saveCRMNote" access="remote" output="yes" returnformat="json">
		<cfargument name="customerid" required="yes" type="any">
		<cfargument name="dsn" required="yes" type="any">
		<cfargument name="CRMNoteType" required="yes" type="any">
		<cfargument name="CRMNote" required="yes" type="any">
		<cfargument name="user" required="yes" type="any">
		<cfset response = structNew()>

		<cftry>
			<cfquery name="insertCRMnote" datasource="#arguments.dsn#">
				INSERT INTO CRMNotes VALUES(
					newid(),
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.customerid#">,
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.CRMNote#">,
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.CRMNoteType#">,
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.user#">,
					getdate()
				)
			</cfquery>

			<cfquery name="getCustomerCallFrequency" datasource="#arguments.dsn#">
				SELECT ISNULL(CRMCallFrequency,0) AS CRMCallFrequency  FROM Customers WHERE CustomerID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.customerid#">
			</cfquery>

			<cfquery name="updateCustomer" datasource="#arguments.dsn#">
				UPDATE Customers SET 
				CRMLastCallDate = getdate() 
				<cfif getCustomerCallFrequency.CRMCallFrequency EQ 0>
					,CRMNextCallDate =  NULL
				<cfelse>
					,CRMNextCallDate =  DATEADD(day, #getCustomerCallFrequency.CRMCallFrequency#, getdate())
				</cfif>
				WHERE CustomerID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.customerid#">
			</cfquery>

			<cfset response.success = 1>
			<cfset response.msg = "Note added successfully.">
			<cfreturn response>

			<cfcatch>
				<cfset response.success = 0>
				<cfset response.msg = "Something went wrong. Please contact support">
				<cfreturn response>
			</cfcatch>
		 </cftry>
	</cffunction>
	<cffunction name="getCustomerCRMOverdue" access="public" output="false" returntype="query">


	    <cfquery name="qryCountCustomer" datasource="#Application.dsn#">
	    	SELECT COUNT(c.customerid) AS custCount FROM Customers c
	 		WHERE CRMNextCallDate < getdate() AND customerid in (select customerid from CustomerOffices inner join offices on CustomerOffices.officeid = offices.officeid where offices.companyid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#session.companyid#">)
		</cfquery>
	
		<cfreturn qryCountCustomer>
	</cffunction>

	<cffunction name="getCRMCalls" access="public" output="false" returntype="query">
		<cfargument name="searchText" required="no" type="any">
	    <cfargument name="pageNo" required="no" type="any" default="1">
	    <cfargument name="sortorder" required="no" type="any" default="ASC">
	    <cfargument name="sortby" required="no" type="any" default="C.CustomerName">

	    <cfquery name="qgetCRMCalls" datasource="#Application.dsn#">
	    	BEGIN WITH page AS 
	    	(SELECT 
				C.CustomerID,
				C.CustomerName,
				C.Location,
				C.City,
				C.statecode,
				C.Zipcode,
				C.PhoneNo,
				C.CustomerStatusID,
				Offices.OfficeLocations,
				Dispatchers.Name as Dispatcher,
				SalesAgents.name as SalesAgent,
				C.CRMNextCallDate
				,ROW_NUMBER() OVER (ORDER BY #arguments.sortby# #arguments.sortorder#) AS Row
				FROM CUSTOMERS C
				inner join (select
			    customerid,
			    stuff((
			        select ';' + offices.[location]
			        from CustomerOffices t
					inner join offices on offices.OfficeID = t.officeid
			        where t.customerid = c1.customerid
			        order by offices.[location]
			        for xml path('')
			    ),1,1,'') as OfficeLocations
				from CustomerOffices c1 inner join offices o1 on o1.officeid = c1.OfficeID
				where o1.CompanyID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#session.CompanyID#">
				group by customerid) Offices ON Offices.CustomerID = c.CustomerID


				left join employees Dispatchers on Dispatchers.EmployeeID = C.AcctMGRID
				left join employees SalesAgents on SalesAgents.EmployeeID = C.SalesRepID
				WHERE C.CRMNextCallDate IS NOT NULL
	    	<cfif structKeyExists(arguments, "searchText") and len(trim(arguments.searchText))>
			    AND (C.CustomerName LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#arguments.searchText#%">
			    OR C.Location LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#arguments.searchText#%">
			    OR C.City LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#arguments.searchText#%">
			    OR C.statecode LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#arguments.searchText#%">
			    OR C.Zipcode LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#arguments.searchText#%">)
		    </cfif>
		    )
		    SELECT
		      *,(select (max(row)/30) + (CASE WHEN max(row)%30 <> 0 THEN 1 ELSE 0 END)  FROM page) AS TotalPages 
		    FROM page
		    WHERE Row BETWEEN (<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.pageNo#"> - 1) * 30 + 1 AND <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.pageNo#"> * 30
		    END
		</cfquery>

		<cfreturn qgetCRMCalls>
	</cffunction>

	<cffunction name="getCRMCallsReminder" access="public" output="false" returntype="query">
		<cfargument name="searchText" required="no" type="any">
	    <cfargument name="pageNo" required="no" type="any" default="1">
	    <cfargument name="sortorder" required="no" type="any" default="ASC">
	    <cfargument name="sortby" required="no" type="any" default="C.CustomerName">

	    <cfquery name="qgetCRMCalls" datasource="#Application.dsn#">
	    	BEGIN WITH page AS 
	    	(SELECT 
				C.CustomerID,
				C.CustomerName,
				C.Location,
				C.City,
				C.statecode,
				C.Zipcode,
				C.PhoneNo,
				C.CustomerStatusID,
				Offices.OfficeLocations,
				Dispatchers.Name as Dispatcher,
				SalesAgents.name as SalesAgent,
				C.CRMNextCallDate
				,ROW_NUMBER() OVER (ORDER BY #arguments.sortby# #arguments.sortorder#) AS Row
				FROM CUSTOMERS C
				left join employees Dispatchers on Dispatchers.EmployeeID = C.AcctMGRID
				left join employees SalesAgents on SalesAgents.EmployeeID = C.SalesRepID
				inner join (select
			    customerid,
			    stuff((
			        select ';' + offices.[location]
			        from CustomerOffices t
					inner join offices on offices.OfficeID = t.officeid
			        where t.customerid = c1.customerid
			        order by offices.[location]
			        for xml path('')
			    ),1,1,'') as OfficeLocations
				from CustomerOffices c1 inner join offices o1 on o1.officeid = c1.OfficeID
				where o1.CompanyID = '#session.companyid#'
				group by customerid) Offices ON Offices.CustomerID = c.CustomerID
				WHERE C.CRMNextCallDate IS NOT NULL
				AND  C.CRMNextCallDate  < getdate()
	    	<cfif structKeyExists(arguments, "searchText") and len(trim(arguments.searchText))>
			    AND (C.CustomerName LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#arguments.searchText#%">
			    OR C.Location LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#arguments.searchText#%">
			    OR C.City LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#arguments.searchText#%">
			    OR C.statecode LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#arguments.searchText#%">
			    OR C.Zipcode LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#arguments.searchText#%">)
		    </cfif>
		    )
		    SELECT
		      *
		    FROM page
		    WHERE Row BETWEEN (<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.pageNo#"> - 1) * 30 + 1 AND <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.pageNo#"> * 30
		    END
		</cfquery>

		<cfreturn qgetCRMCalls>
	</cffunction>

	<cffunction name="getConsolidateLoadList" access="public" output="false" returntype="query">
		<cfargument name="ConsolidatedID" required="yes" type="any" default="">
	    

	    <cfquery name="qConsolidateLoads" datasource="#Application.dsn#">
	
	    	SELECT 
			L.LoadNumber
			,LST.StatusText
			,LST.StatusDescription
			,L.CustName
			,L.CustomerPONo
			,LP.StopDate AS ShipDate
			,LP.StopTime AS ShipTime
			,LP.City AS ShipCity
			,LP.StateCode AS ShipState
			,LD.StopDate AS DelDate
			,LD.StopTime AS DelTime
			,LD.City AS DelCity
			,LD.StateCode AS DelState
			,L.TotalCustomerCharges
			,L.TotalCarrierCharges
			,ISNULL(l.CarrierName,l.LoadDriverName) AS CarrierName
			,L.EquipmentName
			,L.DriverName 
			,E.EmpDispatch
			,L.SalesAgent
			,LST.ColorCode
			,LST.TextColorCode
			,L.LoadID
			FROM LOADS L
			INNER JOIN LoadsConsolidatedDetail LCD ON L.LoadID = LCD.LoadID
			JOIN (SELECT LS.LoadID,LS.City,LS.StateCode,LS.StopDate,LS.StopTime FROM LoadStops LS WHERE LS.StopNo = 0 AND LS.LoadType = 1) LP ON LP.LoadID = L.LoadID
			JOIN (SELECT LS.LoadID,LS.City,LS.StateCode,LS.StopDate,LS.StopTime FROM LoadStops LS WHERE LS.StopNo = (SELECT MAX(LS1.StopNo) FROM LoadStops LS1 WHERE LS1.LoadID = LS.LoadID) AND LS.LoadType = 2) LD ON LD.LoadID = L.LoadID
			JOIN LoadStatusTypes LST ON L.StatusTypeID = LST.StatusTypeID
			JOIN (SELECT Name as EmpDispatch,EmployeeID FROM Employees) as E on E.EmployeeID =L.DispatcherID
			 
			WHERE LCD.ConsolidatedID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.ConsolidatedID#">

			
		</cfquery>


	    <cfreturn qConsolidateLoads>
	</cffunction>


	<cffunction name="getCustomerContacts" access="public" output="false" returntype="query">
		<cfargument name="CustomerID" required="yes" type="any" default="">
	    <cfargument name="CustomerContactID" required="no" type="any" default="">
	    <cfquery name="qCustomerContacts" datasource="#Application.dsn#">
	    	SELECT * FROM CustomerContacts
			WHERE CustomerID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.CustomerID#">
			<cfif structKeyExists(arguments, "CustomerContactID") AND len(trim(arguments.CustomerContactID))>
				AND CustomerContactID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.CustomerContactID#">
			</cfif>
		</cfquery>
		
	    <cfreturn qCustomerContacts>
	</cffunction>

	<cffunction name="addCustomerContact" access="public" output="false" returntype="string">
		<cfargument name="frmstruct" type="struct" required="yes" />

		<cfif structKeyExists(arguments.frmstruct, "Active")>
			<cfset var Active = 1>
		<cfelse>
			<cfset var Active = 0>
		</cfif>

	    <cfquery name="qAddCustomerContact" datasource="#Application.dsn#">
	    	<cfif structkeyexists(arguments.frmstruct,"CustomerContactId") AND LEN(TRIM(arguments.frmstruct.CustomerContactId))>
	    		UPDATE CustomerContacts SET 
				[ContactPerson] = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.frmstruct.ContactPerson#">
				,[PhoneNo] = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.frmstruct.PhoneNo#">
				,[PhoneNoExt] = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.frmstruct.PhoneNoExt#">
				,[Fax] = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.frmstruct.Fax#">
				,[FaxExt] = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.frmstruct.FaxExt#">
				,[TollFree] = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.frmstruct.TollFree#">
				,[TollfreeExt] = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.frmstruct.TollfreeExt#">
				,[PersonMobileNo] = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.frmstruct.PersonMobileNo#">
				,[MobileNoExt] = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.frmstruct.MobileNoExt#">
				,[Email] = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.frmstruct.Email#">
				,[ContactType] = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.frmstruct.ContactType#">
				,[Active] = <cfqueryparam cfsqltype="cf_sql_bit" value="#arguments.frmstruct.Active#">
				,[Location]=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.frmstruct.Location#">
	    		,[City]=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.frmstruct.City#">
	    		,[StateCode]=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.frmstruct.State1#">
	    		,[Zipcode]=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.frmstruct.ZipCode#">
	    		,[Notes]=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.frmstruct.Notes#">
	    		WHERE CustomerContactId = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.frmstruct.CustomerContactID#">
	    	<cfelse>
	    		INSERT INTO CustomerContacts (
	    			[CustomerContactID]
					,[CustomerID]
					,[ContactPerson]
					,[PhoneNo]
					,[PhoneNoExt]
					,[Fax]
					,[FaxExt]
					,[TollFree]
					,[TollfreeExt]
					,[PersonMobileNo]
					,[MobileNoExt]
					,[Email]
					,[ContactType]
					,[Active]
					,[Location]
					,[City]
					,[StateCode]
					,[Zipcode]
					,[Notes])
	    		VALUES(
	    			NEWID()
	    			,<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.frmstruct.CustomerID#">
	    			,<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.frmstruct.ContactPerson#">
	    			,<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.frmstruct.PhoneNo#">
	    			,<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.frmstruct.PhoneNoExt#">
	    			,<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.frmstruct.Fax#">
	    			,<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.frmstruct.FaxExt#">
	    			,<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.frmstruct.TollFree#">
	    			,<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.frmstruct.TollfreeExt#">
	    			,<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.frmstruct.PersonMobileNo#">
	    			,<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.frmstruct.MobileNoExt#">
	    			,<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.frmstruct.Email#">
	    			,<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.frmstruct.ContactType#">
	    			,<cfqueryparam cfsqltype="cf_sql_bit" value="#arguments.frmstruct.Active#">
	    			,<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.frmstruct.Location#">
	    			,<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.frmstruct.City#">
	    			,<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.frmstruct.State1#">
	    			,<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.frmstruct.ZipCode#">
	    			,<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.frmstruct.Notes#">
	    		)
	    	</cfif>
		</cfquery>
		
	    <cfreturn 'Customer contact saved successfully.'>
	</cffunction>

	<cffunction name="deleteCustomerContact" access="public" output="false" returntype="string">
		<cfargument name="CustomerContactID" required="no" type="any" default="">
		<cfquery name="qDelCustomerContact" datasource="#Application.dsn#">
			DELETE FROM CustomerContacts
			WHERE CustomerContactId = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.CustomerContactID#">
		</cfquery>
		<cfreturn 'Customer contact deleted.'>
	</cffunction>

	<cffunction name="getStopDetails" access="public" output="false" returntype="any">
	    <cfargument name="CustomerStopID" required="no" type="any">
	 	<cfquery name="qStopDetails" datasource="#Application.dsn#">
	 		select * from CustomerStops where  CustomerStopID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.CustomerStopID#">
	 	</cfquery>
	    <cfreturn qStopDetails>
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

	<cffunction name="uploadCustomerViaCSV" access="remote" output="yes" returnformat="json">
    	<cfargument name="createdBy" required="yes" type="any">
    	<cfargument name="CompanyID" required="yes" type="any">

    	<cftry>

    		<cfset var row="">
    		<cfset var fileName="">
    		<cfset var validHeader="">
    		<cfset var uploadedHeader="">
			<cfset var response = structNew()>  

			<cfset local.dsn = trim(listFirst(cgi.SCRIPT_NAME,'/'))>

			<cfset var rootPath = expandPath('../fileupload/tempCSV/')>

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
      	
      		<cffile action="read" file="#rootPath##fileName#" variable="csvfile"> 

      		<cfset validHeader = "Customer Code,Payer,Office,Company Name,Address,Address 2,Address 3,City,Postal/Zip,State,Country,Remit Name,Remit Address,Remit Address 2,Remit City,Remit Postal/Zip,Remit State,Remit Country,Remit Contact,Remit Email,Remit Phone,Remit Fax,General Contact,General Email,General Phone,General Fax,General Toll Free,General Cell,Billing Contact,Billing Email,Billing Phone,Billing Fax,Billing Toll Free,Billing Cell,Dispatch Contact,Dispatch Email,Dispatch Phone,Dispatch Fax,Dispatch Toll Free,Dispatch Cell,Dispatcher,Sales Agent,Notes,Currency,Payment Terms,Credit Limit,Website">

      		<cfset uploadedHeader = listgetAt('#csvfile#',1, '#chr(10)##chr(13)#')>
      		<cfif Compare(validHeader, uploadedHeader) NEQ 0>
		        <cffile action="delete" file="#rootPath##fileName#">
		        <cfset response.success = 0>
		        <cfset response.message = "There are one or more column headings that are not valid.  Please check correct and try again.">
		        <cfreturn response>
		    </cfif>

		    <cfset var currentRow = 1>
		    <cfset var ImportedAllRows = 1>
		    <cfset var custStruct = structNew()>
		    <cftransaction>
			    <cfloop index="row" list="#csvfile#" delimiters="#chr(10)##chr(13)#">
			    	<cfif currentRow NEQ 1>
			    		<cfset qryRow = CSVToQuery(row)>

			    		<cfset custStruct.CustomerCode = qryRow.column_1>
						<cfset custStruct.IsPayer = qryRow.column_2>
						<cfset custStruct.OfficeCode = qryRow.column_3>
						<cfset custStruct.CustomerName = qryRow.column_4>
						<cfset custStruct.Location = qryRow.column_5>
						<cfset custStruct.Address2 = qryRow.column_6>
						<cfset custStruct.Address3 = qryRow.column_7>
						<cfset custStruct.City = qryRow.column_8>
						<cfset custStruct.ZipCode = qryRow.column_9>
						<cfset custStruct.StateCode = qryRow.column_10>
						<cfset custStruct.Country = qryRow.column_11>
						<cfset custStruct.RemitName = qryRow.column_12>
						<cfset custStruct.RemitAddress = qryRow.column_13>
						<cfset custStruct.RemitAddress2 = qryRow.column_14>
						<cfset custStruct.RemitCity = qryRow.column_15>
						<cfset custStruct.RemitZip = qryRow.column_16>
						<cfset custStruct.RemitState = qryRow.column_17>
						<cfset custStruct.RemitCountry = qryRow.column_18>
						<cfset custStruct.RemitContact = qryRow.column_19>
						<cfset custStruct.RemitEmail = qryRow.column_20>
						<cfset custStruct.RemitPhone = qryRow.column_21>
						<cfset custStruct.RemitFax = qryRow.column_22>
						<cfset custStruct.InvoiceRemitInformation = "NOTICE OF ASSIGNMENT#chr(13)##chr(10)#Please be advised that we have assigned, made over, and sold to #custStruct.RemitName# all of our rights and interests in and to the accounts receivable arising from this invoice and that all payments should be made to:#chr(13)##chr(10)##chr(13)##chr(10)##custStruct.RemitName##chr(13)##chr(10)##custStruct.RemitAddress##chr(13)##chr(10)##custStruct.RemitCity#, #custStruct.RemitState# #custStruct.RemitZip##chr(13)##chr(10)##chr(13)##chr(10)#Any claims, offsets or disputes must be reports immediately to #custStruct.RemitName# at #custStruct.RemitPhone# or email #custStruct.RemitEmail#.">
						<cfset custStruct.GeneralContact = qryRow.column_23>
						<cfset custStruct.GeneralEmail = qryRow.column_24>
						<cfset custStruct.GeneralPhone = qryRow.column_25>
						<cfset custStruct.GeneralFax = qryRow.column_26>
						<cfset custStruct.GeneralTollFree = qryRow.column_27>
						<cfset custStruct.GeneralCell = qryRow.column_28>
						<cfset custStruct.BillingContact = qryRow.column_29>
						<cfset custStruct.BillingEmail = qryRow.column_30>
						<cfset custStruct.BillingPhone = qryRow.column_31>
						<cfset custStruct.BillingFax = qryRow.column_32>
						<cfset custStruct.BillingTollFree = qryRow.column_33>
						<cfset custStruct.BillingCell = qryRow.column_34>
						<cfset custStruct.DispatchContact = qryRow.column_35>
						<cfset custStruct.DispatchEmail = qryRow.column_36>
						<cfset custStruct.DispatchPhone = qryRow.column_37>
						<cfset custStruct.DispatchFax = qryRow.column_38>
						<cfset custStruct.DispatchTollFree = qryRow.column_39>
						<cfset custStruct.DispatchCell = qryRow.column_40>
						<cfset custStruct.Dispatcher = qryRow.column_41>
						<cfset custStruct.SalesAgent = qryRow.column_42>
						<cfset custStruct.Notes = qryRow.column_43>
						<cfset custStruct.Currency = qryRow.column_44>
						<cfset custStruct.PaymentTerms = qryRow.column_45>
						<cfset custStruct.CreditLimit = replaceNoCase(replaceNoCase(trim(qryRow.column_46),'$',''),',','','ALL')>
						<cfset custStruct.Website = qryRow.column_47>
						<CFSTOREDPROC PROCEDURE="USP_ImportCustomerViaCSV" DATASOURCE="#local.dsn#">
							<CFPROCPARAM VALUE="#arguments.CompanyID#" cfsqltype="CF_SQL_VARCHAR">
							<CFPROCPARAM VALUE="#row#" cfsqltype="CF_SQL_VARCHAR">
							<CFPROCPARAM VALUE="#CurrentRow#" cfsqltype="CF_SQL_INTEGER">
							<CFPROCPARAM VALUE="#custStruct.CustomerCode#" cfsqltype="CF_SQL_VARCHAR">
							<CFPROCPARAM VALUE="#custStruct.IsPayer#" cfsqltype="CF_SQL_BIT">
							<CFPROCPARAM VALUE="#custStruct.OfficeCode#" cfsqltype="CF_SQL_VARCHAR">
							<CFPROCPARAM VALUE="#custStruct.CustomerName#" cfsqltype="CF_SQL_VARCHAR">
							<CFPROCPARAM VALUE="#custStruct.Location#" cfsqltype="CF_SQL_VARCHAR">
							<CFPROCPARAM VALUE="#custStruct.City#" cfsqltype="CF_SQL_VARCHAR">
							<CFPROCPARAM VALUE="#custStruct.ZipCode#" cfsqltype="CF_SQL_VARCHAR">
							<CFPROCPARAM VALUE="#custStruct.StateCode#" cfsqltype="CF_SQL_VARCHAR">
							<CFPROCPARAM VALUE="#custStruct.Notes#" cfsqltype="CF_SQL_VARCHAR">
							<CFPROCPARAM VALUE="#custStruct.SalesAgent#" cfsqltype="CF_SQL_VARCHAR">
							<CFPROCPARAM VALUE="#custStruct.Dispatcher#" cfsqltype="CF_SQL_VARCHAR">
							<CFPROCPARAM VALUE="#custStruct.PaymentTerms#" cfsqltype="CF_SQL_VARCHAR">
							<cfif len(trim(custStruct.CreditLimit)) AND isNumeric(custStruct.CreditLimit)>
								<CFPROCPARAM VALUE="#custStruct.CreditLimit#" cfsqltype="CF_SQL_MONEY">
							<cfelse>
								<CFPROCPARAM VALUE="0" cfsqltype="CF_SQL_MONEY">
							</cfif>
							<CFPROCPARAM VALUE="#arguments.createdBy#" cfsqltype="CF_SQL_VARCHAR">
							<CFPROCPARAM VALUE="#custStruct.GeneralContact#" cfsqltype="CF_SQL_VARCHAR">
							<CFPROCPARAM VALUE="#custStruct.GeneralPhone#" cfsqltype="CF_SQL_VARCHAR">
							<CFPROCPARAM VALUE="#custStruct.GeneralFax#" cfsqltype="CF_SQL_VARCHAR">
							<CFPROCPARAM VALUE="#custStruct.GeneralTollFree#" cfsqltype="CF_SQL_VARCHAR">
							<CFPROCPARAM VALUE="#custStruct.GeneralCell#" cfsqltype="CF_SQL_VARCHAR">
							<CFPROCPARAM VALUE="#custStruct.GeneralEmail#" cfsqltype="CF_SQL_VARCHAR">
							<CFPROCPARAM VALUE="#custStruct.RemitName#" cfsqltype="CF_SQL_VARCHAR">
							<CFPROCPARAM VALUE="#custStruct.RemitAddress#" cfsqltype="CF_SQL_VARCHAR">
							<CFPROCPARAM VALUE="#custStruct.RemitCity#" cfsqltype="CF_SQL_VARCHAR">
							<CFPROCPARAM VALUE="#custStruct.RemitState#" cfsqltype="CF_SQL_VARCHAR">
							<CFPROCPARAM VALUE="#custStruct.RemitZip#" cfsqltype="CF_SQL_VARCHAR">
							<CFPROCPARAM VALUE="#custStruct.RemitPhone#" cfsqltype="CF_SQL_VARCHAR">
							<CFPROCPARAM VALUE="#custStruct.RemitFax#" cfsqltype="CF_SQL_VARCHAR">
							<CFPROCPARAM VALUE="#custStruct.RemitEmail#" cfsqltype="CF_SQL_VARCHAR">
							<CFPROCPARAM VALUE="#custStruct.RemitContact#" cfsqltype="CF_SQL_VARCHAR">
							<CFPROCPARAM VALUE="#custStruct.InvoiceRemitInformation#" cfsqltype="CF_SQL_VARCHAR">
							<CFPROCPARAM VALUE="#custStruct.BillingContact#" cfsqltype="CF_SQL_VARCHAR">
							<CFPROCPARAM VALUE="#custStruct.BillingPhone#" cfsqltype="CF_SQL_VARCHAR">
							<CFPROCPARAM VALUE="#custStruct.BillingFax#" cfsqltype="CF_SQL_VARCHAR">
							<CFPROCPARAM VALUE="#custStruct.BillingTollFree#" cfsqltype="CF_SQL_VARCHAR">
							<CFPROCPARAM VALUE="#custStruct.BillingCell#" cfsqltype="CF_SQL_VARCHAR">
							<CFPROCPARAM VALUE="#custStruct.BillingEmail#" cfsqltype="CF_SQL_VARCHAR">
							<CFPROCPARAM VALUE="#custStruct.DispatchContact#" cfsqltype="CF_SQL_VARCHAR">
							<CFPROCPARAM VALUE="#custStruct.DispatchPhone#" cfsqltype="CF_SQL_VARCHAR">
							<CFPROCPARAM VALUE="#custStruct.DispatchFax#" cfsqltype="CF_SQL_VARCHAR">
							<CFPROCPARAM VALUE="#custStruct.DispatchTollFree#" cfsqltype="CF_SQL_VARCHAR">
							<CFPROCPARAM VALUE="#custStruct.DispatchCell#" cfsqltype="CF_SQL_VARCHAR">
							<CFPROCPARAM VALUE="#custStruct.DispatchEmail#" cfsqltype="CF_SQL_VARCHAR">
							<CFPROCPARAM VALUE="#custStruct.Website#" cfsqltype="CF_SQL_VARCHAR">
							<CFPROCRESULT NAME="qCustomer">
						</CFSTOREDPROC>
						<cfif qCustomer.Success EQ 0>
							<cfset ImportedAllRows = 0>
						</cfif> 
			    	</cfif>
			    	<cfset currentRow++>
			    </cfloop>
		    <cftransaction>
		    <cfset response.success = 1>
		    <cfif ImportedAllRows EQ 0>
		        <cfset response.message = "Some rows are not imported. Please check log for more details.">
		    <cfelse>
		        <cfset response.message = "Customers imported successfully. Please check log for more details.">
		    </cfif>
		    <cfreturn response>
    		<cfcatch>
    			<cfquery name="qInsLog" datasource="#local.dsn#">
		          	INSERT INTO CustomerCsvImportLog (LogId,Message,CreatedDate,Success,RowData,CompanyID,CreatedBy)
		          	VALUES(newid(),
		          		<cfqueryparam cfsqltype="cf_sql_varchar" value='#cfcatch.message##cfcatch.detail#'>,
		          		getdate(),0,
		          		<cfqueryparam cfsqltype="cf_sql_varchar" value='#row#'>,
				        <cfqueryparam cfsqltype="cf_sql_varchar" value='#arguments.companyid#'>,
                		<cfqueryparam cfsqltype="cf_sql_varchar" value='#arguments.createdBy#'>)
		        </cfquery>
		        <cfset response.success = 0>
		        <cfset response.message = "Something went wrong. Please contact support.">
		        <cfreturn response>
    		</cfcatch>
    	</cftry>
    </cffunction>

    <cffunction name="getCustomerCsvImportLog" access="public" output="false" returntype="query">
    <cfargument name="searchText" required="no" type="any">
    <cfargument name="pageNo" required="no" type="any" default="1">
    <cfargument name="sortorder" required="no" type="any" default="DESC">
    <cfargument name="sortby" required="no" type="any" default="CreatedDate">

      <cfquery name="qgetCustomerCsvImportLog" datasource="#Application.dsn#">
        BEGIN WITH page AS 
        (SELECT 
          P.LogID
          ,P.CustomerCode
          ,P.Message
          ,P.CreatedDate
          ,P.Success
          ,P.CreatedBy
          ,ROW_NUMBER() OVER (ORDER BY #arguments.sortby# #arguments.sortorder#) AS Row
        FROM CustomerCsvImportLog P
        WHERE  P.CompanyID = <cfqueryparam value="#session.CompanyID#" cfsqltype="varchar">
        <cfif structKeyExists(arguments, "searchText") and len(trim(arguments.searchText))>
          AND (P.CustomerCode LIKE <cfqueryparam value="%#arguments.searchText#%" cfsqltype="cf_sql_varchar">
          		OR P.Message LIKE <cfqueryparam value="%#arguments.searchText#%" cfsqltype="cf_sql_varchar">
          	)
        </cfif>
        )
        SELECT
          *,(select (max(row)/30) + (CASE WHEN max(row)%30 <> 0 THEN 1 ELSE 0 END)  FROM page) AS TotalPages
        FROM page
        WHERE Row BETWEEN (<cfqueryparam value="#pageNo#" cfsqltype="cf_sql_varchar"> - 1) * 30 + 1 AND <cfqueryparam value="#pageNo#" cfsqltype="cf_sql_varchar"> * 30
        END
    </cfquery>

    <cfreturn qgetCustomerCsvImportLog>
  </cffunction>

   	<cffunction name="getloadCustomer" access="public" returntype="query">
   		<cfquery name="qCustomer" datasource="#Application.dsn#">
   			SELECT * FROM Customers WHERE CustomerID = <cfqueryparam value="#session.CustomerID#" cfsqltype="varchar">
   		</cfquery>
   		<cfreturn qCustomer>
   	</cffunction>

   	<cffunction name="CheckCustomerExists" access="public" returntype="string">
		<cfargument name="customerid" type="string" required="yes"/>
		<!---Query to get the user editing details for corresponding customer--->
		
		<cfquery name="qryCheckCustomerExists" datasource="#Application.dsn#">
			select  count(CustomerID) AS CustomerCount from Customers
			where CustomerID=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.customerid#">
		</cfquery>

		<cfreturn qryCheckCustomerExists.CustomerCount>
	</cffunction>

	<cffunction name="saveScheduleCall" access="public" returntype="struct">
		<cfargument name="CustomerID" type="string" required="yes"/>
		<cfargument name="frmstruct" type="struct" required="yes"/>

		<cftry>
			<cfquery name="qUpd" datasource="#Application.dsn#">
				UPDATE Customers SET
				CRMContactID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.frmstruct.CRMContactID#"   null="#not len(arguments.frmstruct.CRMContactID)#">
				,CRMPhoneNo = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.frmstruct.CRMPhoneNo#"   null="#not len(arguments.frmstruct.CRMPhoneNo)#">
				,CRMPhoneNOExt = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.frmstruct.CRMPhoneNOExt#"   null="#not len(arguments.frmstruct.CRMPhoneNOExt)#">
				,CRMFax = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.frmstruct.CRMFax#"   null="#not len(arguments.frmstruct.CRMFax)#">
				,CRMFaxExt = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.frmstruct.CRMFaxExt#"   null="#not len(arguments.frmstruct.CRMFaxExt)#">
				,CRMTollFree = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.frmstruct.CRMTollFree#"   null="#not len(arguments.frmstruct.CRMTollFree)#">
				,CRMTollFreeExt = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.frmstruct.CRMTollFreeExt#"   null="#not len(arguments.frmstruct.CRMTollFreeExt)#">
				,CRMCell = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.frmstruct.CRMCell#"   null="#not len(arguments.frmstruct.CRMCell)#">
				,CRMCellExt = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.frmstruct.CRMCellExt#"   null="#not len(arguments.frmstruct.CRMCellExt)#">
				,CRMEmail = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.frmstruct.CRMEmail#"   null="#not len(arguments.frmstruct.CRMEmail)#">
				,CRMNoteType = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.frmstruct.CRMNoteType#"   null="#not len(arguments.frmstruct.CRMNoteType)#">
				,CRMRepeatInterval = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.frmstruct.CRMRepeatInterval#" null="#not len(arguments.frmstruct.CRMRepeatInterval)#">
				,CRMNextCallDate = <cfqueryparam cfsqltype="cf_sql_date" value="#arguments.frmstruct.CRMNextCallDate#"  null="#not len(arguments.frmstruct.CRMNextCallDate)#">
				,CRMUser = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.frmstruct.CRMUser#"   null="#not len(arguments.frmstruct.CRMUser)#">
				WHERE CustomerID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.CustomerID#">
			</cfquery>

			<cfset respStr = structNew()>
		    <cfset respStr.res = "success">
		    <cfset respStr.msg = "Updated Successfully.">
		    <cfreturn respStr>
			<cfcatch>
			    <cfset respStr = structNew()>
			    <cfset respStr.res = "error">
			    <cfset respStr.msg = "Something went wrong. Please try again later.">
			    <cfreturn respStr>
		  	</cfcatch>
		</cftry>
	</cffunction>

	<cffunction name="recursiveAjaxDeleteCustomer" access="remote" returntype="struct" returnformat="json">
		<cfargument name="CustomerID" required="yes" type="string">
		<cfargument name="dsn" required="yes" type="string">
		<cftry>
			<cfquery name="qGet" datasource="#arguments.dsn#">
				SELECT COUNT(LoadID) AS LoadCount FROM Loads WHERE CustomerID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.CustomerID#">
			</cfquery>

			<cfquery name="qGetAcc" datasource="#arguments.dsn#">
				SELECT COUNT(idcount) AS AccCount FROM [LMA Accounts Receivable Transactions] 
				WHERE CustomerID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.CustomerID#">
				AND Balance <> 0
			</cfquery>

			<cfif qGet.LoadCount EQ 0 AND qGetAcc.AccCount EQ 0>

				<cfquery name="qDel" datasource="#arguments.dsn#">
					delete from FileAttachments WHERE linked_to = 2 AND linked_Id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.CustomerID#">

					delete from FileAttachmentsTemp WHERE linked_to = 2 AND linked_Id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.CustomerID#">

					delete from CRMNotes WHERE CustomerID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.CustomerID#">

					delete from CustomerOffices WHERE CustomerID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.CustomerID#">

					delete from CustomerContacts WHERE CustomerID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.CustomerID#">

					delete from Customers WHERE CustomerID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.CustomerID#">
				</cfquery>

				<cfset retStruct = structNew()>
				<cfset retStruct['deleted'] = 1>
				<cfreturn retStruct>
			<cfelse>
				<cfset retStruct = structNew()>
				<cfset retStruct['deleted'] = 0>
				<cfreturn retStruct>
			</cfif>
			<cfcatch>
				<cfdump var="#cfcatch#"><cfabort>
				<cfset retStruct = structNew()>
				<cfset retStruct['deleted'] = 0>
				<cfreturn retStruct>
			</cfcatch>
		</cftry>

	</cffunction>
	<cffunction name="CheckCustomerMissingAttachment" access="remote" output="yes" returntype="string" returnformat="json">
		<cfargument name="CustomerID" type="string" required="yes">
		<cfargument name="CompanyID" type="string" required="yes">
		<cfargument name="dsn" type="string" required="yes">
		<cftry>
			<cfquery name="qGet" datasource="#arguments.dsn#">
				SELECT COUNT(AttachmentTypeID) AS MissingAttCount FROM FileAttachmentTypes WHERE AttachmentType ='Customer' AND Required = 1 AND CompanyID = <cfqueryparam value="#arguments.CompanyID#" cfsqltype="cf_sql_varchar">
				AND AttachmentTypeID NOT IN (SELECT MFA.AttachmentTypeID FROM FileAttachments FA
				INNER JOIN MultipleFileAttachmentsTypes MFA ON FA.attachment_Id = MFA.AttachmentID
				WHERE FA.linked_Id=<cfqueryparam value="#arguments.CustomerID#" cfsqltype="cf_sql_varchar" list="true">)
			</cfquery>
			<cfif qGet.MissingAttCount EQ 0>
				<cfreturn 0>
			<cfelse>
				<cfreturn 1>
			</cfif>
			<cfcatch>
				<cfreturn 0>
			</cfcatch>
		</cftry>

	</cffunction>

	<cffunction name="getCRMCallHistory" access="public" output="false" returntype="query">
		<cfargument name="searchText" required="no" type="any">
		 <cfargument name="pageNo" required="no" type="any" default="1">
		 <cfargument name="sortorder" required="no" type="any" default="">
		 <cfargument name="sortby" required="no" type="any" default="">
	
		<cfquery name="qgetCRMCallHistory" datasource="#Application.dsn#">
			BEGIN WITH page AS 
			(SELECT 
			CN.CRMNoteID,
			CN.NoteUser AS UserName,
			C.CustomerName AS Company,
			CASE WHEN C.CustomerID = C.CRMContactID THEN C.ContactPerson ELSE CC.ContactPerson END AS Contact,
			CN.CreatedDateTime AS [Date],
			C.CRMPhoneNo AS Phone,
			CNT.NoteType AS CallType,
			CAST(CN.Note AS varchar(50)) AS CallNotes,
			C.CRMNextCallDate AS NextCallDate,
			<cfif len(trim(arguments.sortby))>
				ROW_NUMBER() OVER (ORDER BY #arguments.sortby# #arguments.sortorder#) AS Row
				<cfelse>
			ROW_NUMBER() OVER(ORDER BY CN.CreatedDateTime DESC, CN.NoteUser ASC, C.CustomerName ASC) AS Row
			</cfif>	
			FROM Customers C
			INNER JOIN CustomerOffices CO ON CO.CustomerID = C.CustomerID
			INNER JOIN Offices O ON O.OfficeID = CO.OfficeID
			INNER JOIN CRMNotes CN ON C.CustomerID = CN.CustomerID
			INNER JOIN CRMNoteTypes CNT ON CNT.CRMNoteTypeID = CN.CRMNoteTypeID
			LEFT JOIN CustomerContacts CC ON CC.CustomerContactID = C.CRMContactID
			WHERE O.CompanyID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#session.CompanyID#">
			<cfif structKeyExists(arguments, "searchText") and len(trim(arguments.searchText))>
				AND (CN.NoteUser LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#arguments.searchText#%">
				OR C.CustomerName LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#arguments.searchText#%">
				OR C.ContactPerson LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#arguments.searchText#%">
				OR CC.ContactPerson LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#arguments.searchText#%">
				  )
			</cfif>
			GROUP BY 
			CN.CRMNoteID,CN.NoteUser,C.CustomerName,C.CustomerID,C.CRMContactID,C.ContactPerson, CC.ContactPerson,CN.CreatedDateTime,C.CRMPhoneNo,CNT.NoteType,CAST(CN.Note AS varchar(50)),C.CRMNextCallDate 
			)
			SELECT *,(select (max(row)/30) + (CASE WHEN max(row)%30 <> 0 THEN 1 ELSE 0 END)  FROM page) AS TotalPages FROM page WHERE Row BETWEEN (<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.pageNo#"> - 1) * 30 + 1 AND <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.pageNo#"> * 30
			END
		</cfquery>
		<cfreturn qgetCRMCallHistory>
	</cffunction>

	<cffunction name="getCRMCallDetail" access="public" output="false" returntype="query">
		<cfargument name="CRMNoteID" required="yes" type="any">
	
		<cfquery name="qgetCRMCallDetail" datasource="#Application.dsn#">
			SELECT 
			CN.CRMNoteID,
			CN.NoteUser AS UserName,
			C.CustomerName AS Company,
			CASE WHEN C.CustomerID = C.CRMContactID THEN C.ContactPerson ELSE CC.ContactPerson END AS Contact,
			CN.CreatedDateTime AS [Date],
			C.CRMPhoneNo AS Phone,
			CNT.NoteType AS CallType,
			CN.Note AS CallNotes
			FROM CRMNotes CN 
			INNER JOIN Customers C ON C.CustomerID = CN.CustomerID
			INNER JOIN CRMNoteTypes CNT ON CNT.CRMNoteTypeID = CN.CRMNoteTypeID
			LEFT JOIN CustomerContacts CC ON CC.CustomerContactID = C.CRMContactID
			WHERE CN.CRMNoteID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.CRMNoteID#">
		</cfquery>
		<cfreturn qgetCRMCallDetail>
	</cffunction>
	<cffunction  name="saveFactoryFromCustScreen" access="remote" output="false" returntype="any" returnFormat="json">
		<cfargument name="dsn" type="string" required="yes" />
		<cfargument name="fpFactoringCompanyName" type="string" required="yes" />
		<cfargument name="fpFactoringCompanyAddress" type="string" required="yes" />
		<cfargument name="fpFactoringCompanyCity" type="string" required="yes" />
		<cfargument name="fpFactoringCompanyState" type="string" required="yes" />
		<cfargument name="fpFactoringCompanyZip" type="string" required="yes" />
		<cfargument name="fpFactoringCompanyContact" type="string" required="yes" />
		<cfargument name="fpFactoringCompanyPhone" type="string" required="yes" />
		<cfargument name="fpFactoringCompanyFax" type="string" required="yes" />
		<cfargument name="adminUserName" type="string" required="yes" />
		<cfargument name="empID" type="string" required="yes" />
		<cfargument name="CompanyID" type="string" required="yes" />
		<cftry>
			<cfquery name="qGet" datasource="#arguments.dsn#">
		        SELECT NEWID() AS FactoringID
		     </cfquery>
			<cfquery name="qInsertFactory" datasource="#arguments.dsn#">
				INSERT INTO Factorings(FactoringID,Name,Address,City,State,Zip,Phone,Fax,Contact,CreatedBy,CreatedDateTime,CompanyID) 
				VALUES (
					<cfqueryparam value="#qGet.FactoringID#" cfsqltype="CF_SQL_VARCHAR">,
					<cfqueryparam value="#arguments.fpFactoringCompanyName#" cfsqltype="CF_SQL_VARCHAR">,
					<cfqueryparam value="#arguments.fpFactoringCompanyAddress#" cfsqltype="CF_SQL_VARCHAR">,
					<cfqueryparam value="#arguments.fpFactoringCompanyCity#" cfsqltype="CF_SQL_VARCHAR">,
					<cfqueryparam value="#arguments.fpFactoringCompanyState#" cfsqltype="CF_SQL_VARCHAR">,
					<cfqueryparam value="#arguments.fpFactoringCompanyZip#" cfsqltype="CF_SQL_VARCHAR">,
					<cfqueryparam value="#arguments.fpFactoringCompanyPhone#" cfsqltype="CF_SQL_VARCHAR">,
					<cfqueryparam value="#arguments.fpFactoringCompanyFax#" cfsqltype="CF_SQL_VARCHAR">,
					<cfqueryparam value="#arguments.fpFactoringCompanyContact#" cfsqltype="CF_SQL_VARCHAR">,
					<cfqueryparam value="#arguments.adminUserName#" cfsqltype="CF_SQL_VARCHAR">,
					<cfqueryparam cfsqltype="cf_sql_date" value="#now()#">,
					<cfqueryparam value="#arguments.CompanyID#" cfsqltype="CF_SQL_VARCHAR">

				)
			</cfquery>
			<cfset response.success = 1>
      		<cfset response.id = qGet.FactoringID>
      		<cfreturn response>
      		<cfcatch type="any">
        		<cfset response.success = 0>
        		<cfreturn response>
      		</cfcatch>
    	</cftry>
	</cffunction>
</cfcomponent>