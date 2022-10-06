<cfoutput>
	<style type="text/css">
		.overlay{
		    position: fixed;
		    background-color: ##000000;
		    width: 100%;
		    height: 100%;
		    z-index: 99;
		    top: 0;
		    left: 0;
		    opacity: 0.5;
		    display: none;
		}
		##loader{
			position: fixed;
			top:40%;
			left:30%;
			z-index: 999;
			display: none;
		}
		##loadingmsg{
			top:50%;
			left:31%;
			position: fixed;
			z-index: 999;
			font-size: 14px;
			display: none;
		}
	</style>
	<cfset variables.dateFrom= "">
	<cfset variables.dateTo= "">
	<cfset variables.start1 = createDate( #year(now())#,01, 01 )>
	<cfset variables.end1 = createDate( #year(now())#, 03, 31 )>
	<cfset variables.start2 = createDate( #year(now())#,04, 01 )>
    <cfset variables.end2 = createDate( #year(now())#, 06, 30 )>
	<cfset variables.start3 = createDate( #year(now())#,07, 01 )>
	<cfset variables.end3 = createDate( #year(now())#, 09, 30 )>
	<cfset variables.start4 = createDate( #year(now())#,10, 01 )>
    <cfset variables.end4 = createDate( #year(now())#, 12, 31 )>
	<cfset variables.today = now()>
	<cfset variables.dateFromCheck1=dateDiff("d", #variables.start1#, #variables.today#)>
	<cfset variables.dateToCheck1=dateDiff("d", #variables.today#, #variables.end1#)>
	<cfset variables.dateFromCheck2=dateDiff("d", #variables.start2#, #variables.today#)>
	<cfset variables.dateToCheck2=dateDiff("d", #variables.today#, #variables.end2#)>
	<cfset variables.dateFromCheck3=dateDiff("d", #variables.start3#, #variables.today#)>
	<cfset variables.dateToCheck3=dateDiff("d", #variables.today#, #variables.end3#)>
	<cfset variables.dateFromCheck4=dateDiff("d", #variables.start4#, #variables.today#)>
	<cfset variables.dateToCheck4=dateDiff("d", #variables.today#, #variables.end4#)>
	
    <cfif variables.dateFromCheck1 gte 0 AND variables.dateToCheck1 gte 0 >
		<cfset variables.dateFrom= DateAdd('yyyy',-1,variables.start4)>
		<cfset variables.dateTo= DateAdd('yyyy',-1,variables.end4)>
    </cfif>
	<cfif variables.dateFromCheck2 gte 0 AND variables.dateToCheck2 gte 0>
		<cfset variables.dateFrom= variables.start1>
		<cfset variables.dateTo= variables.end1>
    </cfif>
	<cfif variables.dateFromCheck3 gte 0 AND variables.dateToCheck3 gte 0>
		<cfset variables.dateFrom= variables.start2> 
		<cfset variables.dateTo= variables.end2>
    </cfif>
	<cfif variables.dateFromCheck4 gte 0 AND variables.dateToCheck4 gte 0>
		<cfset variables.dateFrom= variables.start3>
		<cfset variables.dateTo= variables.end3>
	</cfif>
	
<h1 style="float: left;"> IFTA Export</h1><p style="margin-top: 15px;margin-left: 10px;float: left;">(Includes loads from "Delivered" to "Completed".)</p>
<div style="clear:left;"></div>
<div class="search-panel" style="width:100%;">
	<div class="form-search">
		<cfform id="disptaxSummary" name="disptaxSummary" action="index.cfm?event=iftaDownload&getExcel=1&#session.URLToken#" method="post" preserveData="yes">
			<input type="hidden" value="#session.empid#" id="empid">
			<input type="hidden" value="#session.CompanyID#" id="CompanyID">
			<fieldset>
				<cfif isdefined('url.event') AND url.event eq 'iftaDownload'>
					<div class="float-left"><label>Delivery Date From</label>
					<input class="" name="DateFrom" id="DateFrom" value="#dateformat(variables.dateFrom,'mm/dd/yyyy')#" type="datefield" style="width:71px;margin-right:10px;" onblur="checkDateFormatAll(this)"/></div>
					
					<div class="float-left"><label>Delivery Date To</label>
					<input class="" name="DateTo" id="DateTo" value="#dateformat(variables.dateTo,'mm/dd/yyyy')#" type="datefield" style="width:71px;margin-right:10px;" onblur="checkDateFormatAll(this)"/></div>
				</cfif>
				<div class="clear"></div>
			</fieldset>
		</cfform>
	</div>
   	<cfif isdefined('url.event') AND url.event eq 'iftaDownload'>
    	<div id="exportLink" class="exportbutton" style="margin-right: 154px;">
       		<a href="javascript:void(0);" onclick="exportTaxSummary();">Export ALL</a>
        </div>
    </cfif>
	<div class="clear"></div>
</div>
<div class="overlay">
</div>
<img src="images/loadingbar.gif" id="loader">
<strong id="loadingmsg">Generating Data.It will take some time.Please Wait.</strong>
<script>
$(document).ready(function(){
	$( "[type='datefield']" ).datepicker({
	  dateFormat: "mm/dd/yy",
	  showOn: "button",
	  buttonImage: "images/DateChooser.png",
	  buttonImageOnly: true,
	   showButtonPanel: true
	});
	$( ".datefield" ).datepicker( "option", "showButtonPanel", true );
	var old_goToToday = $.datepicker._gotoToday
	$.datepicker._gotoToday = function(id) {
		old_goToToday.call(this,id)
		this._selectDate(id)
	}
	
});
</script>
</cfoutput>