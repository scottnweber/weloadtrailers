<cfset request.fileUploadedPer = request.webpath & "/images/">



<!--- Read spreadsheet into query object ---> 
<cfspreadsheet action="read" headerrow="1" src="#request.fileUploadedPer#cwsseller.xlsx" query="qCarrierList"   rows="2-46" sheetname = "cwsseller1" >

 <cfquery name="test" dbtype="query">
	select * from qCarrierList
 </cfquery>

	<cfset var_LastIndex =10>
	<cfset qCarrierImpQuery = "">
<cfoutput>
	<cfloop query="#test#">
		<cfset qCarrierImpQuery = qCarrierImpQuery& 
		"INSERT INTO cws_sellerinfo (id_sellerinfo,id_customer,id_seller) Values("& #id_sellerinfo#&","&#id_customer#&","&#id_seller#&
		"); <br>" >
		
		<cfset var_LastIndex =var_LastIndex+1>
		
	</cfloop>
	
	#qCarrierImpQuery#
</cfoutput>
<cfabort>