<cfquery name="qrygetLoadid" datasource="#application.dsn#">
 select distinct(loadid) from loadstops
 order by loadid asc
</cfquery>

<cfloop query="qrygetLoadid">
	
	<cfquery name="qryGetstopNoDistinct" datasource="#application.dsn#">
		select distinct(stopNo) from loadstops
	 	where loadid='#qrygetLoadid.loadid#'
	</cfquery>	
	<cfloop query="qryGetstopNoDistinct">
		<cfquery name="qryGetshipper" datasource="#application.dsn#">
			select LoadStopID,loadid,stopdate,stopNo,loadType from loadstops
		 	where loadid='#qrygetLoadid.loadid#' and stopno=#qryGetstopNoDistinct.stopno# and loadtype=1
		</cfquery>	
		<cfquery name="qryGetconsignee" datasource="#application.dsn#">
			select LoadStopID,loadid,stopdate,stopNo,loadType from loadstops
		 	where loadid='#qrygetLoadid.loadid#' and stopno=#qryGetstopNoDistinct.stopno# and loadtype=2
		</cfquery>	
		<cfif IsValid("date",#qryGetshipper.stopdate#) and IsValid("date",#qryGetconsignee.stopdate#)>
			<cfset variables.dateCompareResult= DateCompare(qryGetshipper.stopdate, qryGetconsignee.stopdate)>
			<cfif variables.dateCompareResult eq -1>
				<cfset variables.noOfDays=dateDiff("d", qryGetshipper.stopdate, qryGetconsignee.stopdate)>
			<cfelseif variables.dateCompareResult eq 0>
				<cfset variables.noOfDays=0>
			<cfelseif variables.dateCompareResult eq 1>	
				<cfdump var="3" />
				<cfset variables.noOfDays="">
			</cfif>
		<cfelse>
			<cfset variables.noOfDays="">	
		</cfif>	
		<cfquery name="qryGetupdatestopdateDifference" datasource="#application.dsn#">
			update loadstops set 
			stopdateDifference=<cfqueryparam cfsqltype="cf_sql_integer" value="#variables.noOfDays#" null="#yesNoFormat(NOT len(variables.noOfDays))#">	
		where loadid='#qrygetLoadid.loadid#' and stopno=#qryGetstopNoDistinct.stopno#
		</cfquery>
	</cfloop>	
</cfloop>

stopDifference field is updated<cfabort>