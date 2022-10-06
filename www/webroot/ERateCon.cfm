<cfparam name="url.loadid" default="00000000-0000-0000-0000-000000000000">
<cfparam name="url.CompanyID" default="00000000-0000-0000-0000-000000000000">


<cfset local.dsn=trim(listFirst(cgi.SCRIPT_NAME,'/'))>
<cfset local.loadid=url.loadid>

<cfquery name="qGetCompanyDetails" datasource="#local.dsn#">
	SELECT companyName,
	(SELECT companyLogoName FROM SystemConfig WHERE CompanyID = <cfqueryparam value="#url.CompanyID#" cfsqltype="varchar">) AS companyLogoName,
	CompanyCode ,
	Phone
	FROM Companies
	WHERE CompanyID = <cfqueryparam value="#url.CompanyID#" cfsqltype="varchar">
</cfquery>
<cfquery name="qGetStates" datasource="#local.dsn#">
	SELECT StateCode FROM States
</cfquery>
<cfquery name="getSystemConfig" datasource="#local.dsn#">
	SELECT CarrierRateConfirmation,DropBox,DropBoxAccessToken FROM SystemConfig WHERE CompanyID = <cfqueryparam value="#url.CompanyID#" cfsqltype="varchar">
</cfquery>
<cfquery name="qrygetCommonDropBox" datasource="LoadManagerAdmin">
	SELECT 
	<cfif len(trim(getSystemConfig.DropBoxAccessToken))>
		'#getSystemConfig.DropBoxAccessToken#'
	<cfelse>
		DropBoxAccessToken 
	</cfif>
	AS DropBoxAccessToken
	FROM SystemSetup
</cfquery>
<cfquery name="qGetLoadDetails" datasource="#local.dsn#">
	SELECT 
	L.LoadNumber,
	LS.City AS OriginCity,
	LS.StateCode AS OriginState,
	LS.PostalCode AS OriginZip,
	(SELECT TOP 1 LS1.City FROM LoadStops LS1 WHERE LS1.LoadID = L.LoadID ORDER BY LS1.StopNo DESC,LS1.LoadType DESC) AS DestinationCity,
	(SELECT TOP 1 LS1.StateCode FROM LoadStops LS1 WHERE LS1.LoadID = L.LoadID ORDER BY LS1.StopNo DESC,LS1.LoadType DESC) AS DestinationState,
	(SELECT TOP 1 LS1.PostalCode FROM LoadStops LS1 WHERE LS1.LoadID = L.LoadID ORDER BY LS1.StopNo DESC,LS1.LoadType DESC) AS DestinationZip,
	(SELECT EquipmentName FROM Equipments E WHERE E.EquipmentID = LS.NewEquipmentID) AS Equipment,
	LS.StopDate AS Pickupdate,
	(SELECT carrierNotes FROM Customers C WHERE C.CustomerID = LS.CustomerID) AS carrierNotes,
	(SELECT Telephone FROM Employees WHERE EmployeeID = L.DispatcherID) AS Phone,
	(SELECT Name FROM Employees WHERE EmployeeID = L.DispatcherID) AS Dispatcher,
	(SELECT EmailID FROM Employees WHERE EmployeeID = L.DispatcherID) AS EmailID,
	L.StatusTypeID,
	(SELECT memo FROM Carriers Carr WHERE Carr.CarrierID = LS.NewCarrierID) AS CarrierTerms,
	LST.StatusText,
	L.TotalCarrierCharges,
	(SELECT isShowDollar FROM Carriers Carr WHERE Carr.CarrierID = LS.NewCarrierID) AS isShowDollar
	FROM Loads L
	INNER JOIN LoadStatusTypes LST ON LST.STATUSTYPEID = L.STATUSTYPEID
	INNER JOIN LoadStops LS ON LS.LoadID = L.LoadID AND LS.StopNo = 0 AND LS.LoadType = 1
	WHERE L.LoadID = <cfqueryparam value="#local.LoadID#" cfsqltype="varchar">
</cfquery>
<cfif structKeyExists(form, "submit")>
	
	<cfquery name="qUpdateLoadStop" datasource="#local.dsn#">
		UPDATE LoadStops
		SET NewDriverName = <cfqueryparam value="#form.DriverName#" cfsqltype="varchar">,
		NewDriverCell = <cfqueryparam value="#form.DriverPhone#" cfsqltype="varchar">,
		RefNo = <cfqueryparam value="#form.Ref#" cfsqltype="varchar">,
		NewTruckNo = <cfqueryparam value="#form.Truck#" cfsqltype="varchar">,
		NewTrailorNo = <cfqueryparam value="#form.Trailer#" cfsqltype="varchar">
		WHERE LoadID = <cfqueryparam value="#local.LoadID#" cfsqltype="varchar">
	</cfquery>


	<cfset dispatchNotes = "#form.DateTimeString# - Carrier's dispatcher #form.signature# signed the rate con.">

	<cfif len(trim(form.city)) OR len(trim(form.state))>
		<cfset dispatchNotes &= ' Driver is currentely in '>
		<cfif len(trim(form.city))>
			<cfset dispatchNotes &= '#trim(form.city)#'>
		</cfif>
		<cfif len(trim(form.city)) AND len(trim(form.state))>
			<cfset dispatchNotes &= ', '>
		</cfif>
		<cfif len(trim(form.state))>
			<cfset dispatchNotes &= '#form.state#'>
		</cfif>
		<cfset dispatchNotes &= '.'>
	</cfif>
	<cfif len(trim(form.time))>
		<cfset dispatchNotes &= ' Expected pickup time is #form.time#.'>
	</cfif>

	<cfif len(trim(form.phone)) AND len(trim(form.email))>
		<cfset dispatchNotes &= ' Call or Email #form.signature# at #form.phone# and #form.email# respectively.'>
	<cfelseif len(trim(form.phone))>
		<cfset dispatchNotes &= ' Call #form.signature# at #form.phone#.'>
	<cfelseif len(trim(form.email))>
		<cfset dispatchNotes &= ' Email #form.signature# at #form.email#.'>
	</cfif>

	<cfquery name="qUpdateLoad" datasource="#local.dsn#">
		UPDATE Loads
		SET NewDispatchNotes = <cfqueryparam value="#dispatchNotes##chr(13)##chr(10)#" cfsqltype="cf_sql_varchar"> + NewDispatchNotes
		WHERE LoadID = <cfqueryparam value="#local.LoadID#" cfsqltype="varchar">
	</cfquery>

	<cfif qGetLoadDetails.StatusText NEQ '3. DISPATCHED'>
		<cfset dispatchNote = '#form.DateTimeString# - #form.signature# > Status changed to DISPATCHED'>
		<cfquery name="updateLoad" datasource="#local.dsn#">
			UPDATE Loads
			SET
				StatusTypeID = (select statustypeid from LoadStatusTypes where StatusText='3. DISPATCHED' and companyid ='#url.companyid#')
				,NewDispatchNotes = <cfqueryparam value="#dispatchNote##chr(13)##chr(10)#" cfsqltype="cf_sql_varchar"> + NewDispatchNotes
			WHERE LoadID = <cfqueryparam value="#local.LoadID#" cfsqltype="cf_sql_varchar">
		</cfquery>
	</cfif>
	<CFSTOREDPROC PROCEDURE="USP_GetCarrierReport" DATASOURCE="#Application.dsn#">
		<CFPROCPARAM VALUE="#local.LoadID#" cfsqltype="CF_SQL_VARCHAR">
		<CFPROCRESULT NAME="qCarrierReport">
	</CFSTOREDPROC>
	<cfif len(trim(qCarrierReport.CompanyCode)) and directoryExists(expandPath("../reports/#trim(qCarrierReport.CompanyCode)#")) and fileExists(expandPath("../reports/#trim(qCarrierReport.CompanyCode)#/CarrierReport.cfm"))>
		<cfinclude template="../reports/#trim(qCarrierReport.CompanyCode)#/CarrierReport.cfm">
	<cfelse>
		<cfinclude template="../reports/CarrierReport.cfm">
	</cfif>
	<cfset UploadDir = "#ExpandPath('../')#fileupload\img\">
	<cfset fileName = "Rate_Con_with_sign_#DateFormat(Now(),"YYMMDD")##TimeFormat(Now(),"hhmmss")##qCarrierReport.loadNumber#.pdf">
	<cfpdf action="write" source="CarrierReport" destination="#UploadDir#\#fileName#" overwrite="yes">
	<cfset CompanyCode = qGetCompanyDetails.CompanyCode>
	<cfif getSystemConfig.DropBox EQ 1 >
		<!--- Begin : DropBox Integration  ---->
		<cfhttp
			method="post"
			url="https://api.dropboxapi.com/2/users/get_current_account"	
			result="returnStruct"> 
				<cfhttpparam type="HEADER" name="Authorization" value="Bearer #qrygetCommonDropBox.DropBoxAccessToken#">	
		</cfhttp> 	
		<cfif returnStruct.Statuscode EQ "200 OK"> <!--- Authorization Success --->
			<cfhttp
				method="POST"
				url="https://api.dropboxapi.com/2/files/get_metadata"	
				result="returnStruct"> 
					<cfhttpparam type="HEADER" name="Authorization" value="Bearer #qrygetCommonDropBox.DropBoxAccessToken#">			
					<cfhttpparam type="HEADER" name="Content-Type" value="application/json">			
					<cfhttpparam type="body" value='{"path": "/fileupload/img/#CompanyCode#"}'>			
			</cfhttp>				
			<cfif returnStruct.Statuscode NEQ "200 OK"> <!--- Folder Not Found, Create Folder ---->				
				<cfset tmpStruct = {
					 "path" = '/fileupload/img/#CompanyCode#'
					}>
				<cfhttp
					method="post"
					url="https://api.dropboxapi.com/2/files/create_folder"	
					result="returnStructCreateFolder"> 
						<cfhttpparam type="HEADER" name="Authorization" value="Bearer #qrygetCommonDropBox.DropBoxAccessToken#">	
						<cfhttpparam type="HEADER" name="Content-Type" value="application/json">
						<cfhttpparam type="body" value="#serializeJSON(tmpStruct)#">
				</cfhttp> 						
			</cfif>	
						
			<cfoutput>
				<cfset tmpStruct = {"path":"/fileupload/img/#CompanyCode#/#fileName#"
													,"mode":{".tag":"add"}
													,"autorename":true}>
			</cfoutput>
			<cffile action = "readbinary"
					file = "#UploadDir#/#fileName#"
					variable="filcontent">
			<cfhttp
					method="post"
					url="https://content.dropboxapi.com/2/files/upload"	
					result="returnStruct"> 
							<cfhttpparam type="HEADER" name="Authorization" value="Bearer #qrygetCommonDropBox.DropBoxAccessToken#">		
							<cfhttpparam type="HEADER" name="Content-Type" value="application/octet-stream">
							<cfhttpparam type="HEADER" name="Dropbox-API-Arg" value="#serializeJSON(tmpStruct)#">
							<cfhttpparam type="body" value="#filcontent#">
			</cfhttp> 
			<cfif len(trim(form.email))>
				<cfmail from="loadmanagertestemail@gmail.com" subject="Load## #qCarrierReport.LOADNUMBER# Rate Con With Signature." to="#form.email#" server="smtp.gmail.com" username="loadmanagertestemail@gmail.com" password="yPnvGC0kNZ2LbD5b" port="465" usessl="1" usetls="0" type="text/plain">
					<cfmailparam
						content="#CarrierReport#"
						type="application/pdf"
						file="#fileName#"
						/>
				</cfmail>
			</cfif>
			<cfif fileExists("#UploadDir#/#fileName#")>
				<cffile action="delete" file="#UploadDir#/#fileName#">	
			</cfif>			
		<cfelse> <!--- Authorization Fails  ---->
			<cfreturn 0 >					
		</cfif>
		<!--- End : DropBox Integration  ---->
	</cfif>
	<cfset arguments.frmStruct.fileLabel = "Rate Con With Signature.">
	<cfquery name="updateAttachments" datasource="#local.dsn#">
		INSERT INTO FileAttachments(
					linked_Id,
					linked_to,
					attachedFileLabel,
					attachmentFileName,
					uploadedBy
					<cfif getSystemConfig.dropBox EQ 1>,DropBoxFile</cfif>
		) VALUES (
			<cfqueryparam value="#local.LoadID#" cfsqltype="cf_sql_varchar">,
			1,
			<cfqueryparam value="Rate Con With Signature" cfsqltype="cf_sql_varchar">,
			<cfqueryparam value="#fileName#" cfsqltype="cf_sql_varchar">,
			'Driver'
			<cfif getSystemConfig.dropBox EQ 1>,1</cfif>
		)
	</cfquery>

	<cfset Secret = local.dsn>
    <cfset TheKey = 'NAMASKARAM'>
    <cfset Encrypted = Encrypt(Secret, TheKey)>
    <cfset dsn = URLEncodedFormat(ToBase64(Encrypted))>
	<cflocation url="https://#cgi.http_host#/#local.dsn#/www/webroot/index.cfm?event=CarrierReport&loadid=#loadid#&signature=#form.signature#&ipAddress=#form.ipAddress#">
</cfif>
<cfoutput>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<title>Load Manager TMS</title>
		<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
		<link rel="shortcut icon" href="../logofavicon.png">
		<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css">
		<meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no">
		<style type="text/css">
			.label_left{
				width: 150px;float: left;text-align: right;
			}
			.label_right{
				width: 150px;float: left;text-align: right;margin-left: 25px;
			}
			.clear{
				clear: both;height: 10px;
			}
			.SaveRateCon{
				background: none;
			    border: none;
			    cursor: pointer;
			}
			.SaveRateCon:focus{
			    outline:0;
			}
			.SaveRateCon:active {
			  transform: translate3d(-1px,-1px,-1px);
			}

			@media (max-width: 768px) { 
				.comHdr{
					text-align: center;
					font-size: 12px;
				}
				.imgHdr{
					text-align: center;
				}
				.imgHdr img{
					width:80%;
				}
				.div-rating-perc,.div-steps-ins{
					margin-top: 10px;
				}
				.div-form {
					margin-left: 10px;
					margin-right: 10px;
					border: 1px solid ##dedede;
					padding-bottom: 10px;
				}
				.div-form input,.div-form select,.div-form textarea{
					width:86%;
					margin-left: 12px;
				}
				.div-form label{
					margin-top: 10px;
				}
				.div-form .Time{
					width:50%;
				}
				.lmLogo img{
					width:100px;
				}
				.lmLogo{
					text-align: center;
				}
			}

			@media (min-width: 1200px) {
				.div-form{
					margin-left: 25px;
					width:70%;
					border: 1px solid ##dedede;
					padding: 10px;
				}
				.div-form label{
					text-align: right;
				}
				.div-input-row{
					margin-top: 10px;
				}
				.div-steps-ins{
					font-size: 12px;
				}
				.lmLogo img{
					width:100px;
				}
				.lmLogo{
					text-align: center;
				}
			}
		</style>
	</head>
	<body style="font: normal 11px/16px Arial, Helvetica, sans-serif;color: ##000000;background-color: ##e3ecf9;">
		<div class="container">
			<div class="row">
    			<div class="col-xs-12 col-lg-2 imgHdr">
    				<img src="../fileupload/img/#qGetCompanyDetails.CompanyCode#/logo/#qGetCompanyDetails.companyLogoName#" width="100%" />
    			</div>
    		</div>
    		<div class="row">
    			<div class="col-xs-12 col-lg-3 comHdr">
    				<b>#qGetCompanyDetails.companyName# Phone:#qGetCompanyDetails.phone#</b>
    			</div>
    		</div>
    		<div class="row">
    			<div class="col-xs-12 col-lg-12" style="text-align: center;">
    				<h3>Electronic Rate Confirmation</h3>
    			</div>
    		</div>


    		<cfif qGetLoadDetails.recordcount>
	    		<div class="row">
	    			<div class="col-xs-12 col-lg-4">
	    				<strong>Load## </strong>#qGetLoadDetails.LoadNumber#<br>
						<strong>Origin: </strong><cfif len(trim(qGetLoadDetails.OriginCity))>#qGetLoadDetails.OriginCity#, </cfif><cfif len(trim(qGetLoadDetails.OriginState))>#qGetLoadDetails.OriginState# </cfif><cfif len(trim(qGetLoadDetails.OriginZip))>#qGetLoadDetails.OriginZip# </cfif><br>
						<strong>Destination: </strong><cfif len(trim(qGetLoadDetails.DestinationCity))>#qGetLoadDetails.DestinationCity#, </cfif><cfif len(trim(qGetLoadDetails.DestinationState))>#qGetLoadDetails.DestinationState# </cfif><cfif len(trim(qGetLoadDetails.DestinationZip))>#qGetLoadDetails.DestinationZip# </cfif><br>
						<strong>Equipment: </strong>#qGetLoadDetails.Equipment#<br>
						<strong>Pickup Date: </strong>#DateFormat("#qGetLoadDetails.Pickupdate#",'MM/DD/YYYY')#<br>
						<cfif qGetLoadDetails.isShowDollar EQ 1>
							<strong>Amount: </strong>#DollarFormat(qGetLoadDetails.TotalCarrierCharges)#<br>
						</cfif>
						<strong>Notes: </strong>#qGetLoadDetails.carrierNotes#
	    			</div>
	    			<div class="col-xs-12 col-lg-4 div-rating-perc">
	    				<div style="float: left;padding:5px;border:1px solid ##b50808;border-radius: 10px;">
							<div>
								<b style="color:##b50808">YOUR RATING ON THIS LOAD STARTS WITH THIS VALUE</b>
								<div id="perc" style="width: 0%;background-color: ##a3efed;border-radius: 3px;text-align: center;font-size: 40px;padding-top: 15px;padding-bottom: 15px;">&nbsp;</div>
								<div id="percText" style="width: 100%;text-align: center;font-size: 40px;padding-top: 15px;padding-bottom: 15px;margin-top: -45px;">0%</div>
								<b style="color:##b50808">PLEASE FILL OUT ALL INFORMATION TO GET 100% RATING</b>
							</div>
						</div>
	    			</div>
	    		</div>
	    		<div class="row">
	    			<div class="col-xs-12 col-lg-12 div-steps-ins">
	    				<p>Please follow the steps:</p>
						<p>1) Update information below:</p>
	    			</div>
	    		</div>
	    		<form method="post" action="" onsubmit="return validate()">
					<input type="hidden" name="DateTimeString" id="DateTimeString" value="">
					<input type="hidden" name="ipAddress" id="ipAddress" value="">
					<input type="hidden" name="CompanyID" id="CompanyID" value="#url.CompanyID#">
		    		<div class="row  div-form"  style="background-color: ##defaf9;">
		    			<div class="col-xs-12 col-lg-12">
				    		<div class="row div-input-row">
				    			<label class="col-xs-12 col-lg-3">
				    				Driver Name
				    			</label>
				    			<input class="col-xs-12 col-lg-3 percentage" tabindex="1" name="DriverName" data-perc="20" maxlength="50">
				    			<label class="col-xs-12 col-lg-3">
				    				Driver Cell Phone
				    			</label>
				    			<input class="col-xs-12 col-lg-3 percentage" tabindex="2" name="DriverPhone" onchange="ParseUSNumber(this)" data-perc="20" maxlength="15">
				    		</div>
				    		<div class="row div-input-row">
				    			<label class="col-xs-12 col-lg-3">
				    				Driver Location(City)
				    			</label>
				    			<input class="col-xs-12 col-lg-3 percentage" tabindex="3" name="City" data-perc="10">
				    			<label class="col-xs-12 col-lg-3">
				    				Driver Location(State)
				    			</label>
				    			<select class="col-xs-12 col-lg-3 percentage" style="height:20px;" tabindex="4" name="State"  data-perc="10">
									<option value="">Select State</option>
									<cfloop query="qGetStates">
										<option value="#qGetStates.stateCode#">#qGetStates.stateCode#</option>
									</cfloop>
								</select>
				    		</div>
				    		<div class="row div-input-row">
				    			<label class="col-xs-12 col-lg-3">
				    				Expected Pickup Time
				    			</label>
				    			<input class="col-xs-12 col-lg-1 percentage Time" tabindex="5" name="Time" data-perc="20">
				    			<label class="col-xs-12 col-lg-1">
				    				Ref##
				    			</label>
				    			<input class="col-xs-6 col-lg-1" tabindex="6" name="Ref" maxlength="50">
				    			<label class="col-xs-12 col-lg-3">
				    				Truck##
				    			</label>
				    			<input class="col-xs-12 col-lg-1 percentage" tabindex="7" name="Truck" data-perc="5" maxlength="20">
				    			<label class="col-xs-12 col-lg-1">
				    				Trailer##
				    			</label>
				    			<input class="col-xs-6 col-lg-1 percentage" tabindex="8"  name="Trailer" data-perc="5" maxlength="20">
				    		</div>
				    		<div class="row div-input-row">
				    			<label class="col-xs-12 col-lg-3">
				    				Your Name/Signature*
				    			</label>
				    			<input class="col-xs-12 col-lg-3" tabindex="9" name="Signature" id="Signature">
				    			<label class="col-xs-12 col-lg-3">
				    				Your Phone
				    			</label>
				    			<input class="col-xs-12 col-lg-3 percentage" tabindex="10" name="phone" onchange="ParseUSNumber(this)" data-perc="5">
				    		</div>
				    		<div class="row div-input-row">
				    			<label class="col-xs-12 col-lg-3">
				    				Your Email
				    			</label>
				    			<input class="col-xs-12 col-lg-3 percentage" tabindex="11" name="Email" id="Email" data-perc="5">
				    		</div>
				    		<div class="row div-input-row">
				    			<label class="col-xs-12 col-lg-3">
				    				Carrier Terms
				    			</label>
				    			<textarea name="CarrierTerms" class="col-xs-12 col-lg-6" tabindex="12" rows="3" style="background-color: ##defaf9;" readonly="readonly">#qGetLoadDetails.carrierTerms#</textarea>
				    		</div>
				    	</div>
		    		</div>
		    		<div class="row">
		    			<div class="col-xs-12 col-lg-12 div-steps-ins">
							<p>2) Click Save & Sign Rate Con buttton to view your Rate Confirmation.</p>
		    			</div>
		    		</div>
		    		<div class="row">
		    			<div class="col-xs-12 col-lg-12">
		    				<img src="images/loadDelLoader.gif" id="delLoader" style="display: none;">
		    				<button class="SaveRateCon" id="SaveRateCon" type="submit" name="submit"><img src="images/SaveRateCon.png" class="SaveRateConBtn"/></button>
		    			</div>
		    		</div>
		    	</form>
	    		<div class="row">
	    			<div class="col-xs-12 col-lg-12 div-steps-ins">
						<p>3) When your rate con is displayed, dispatch your driver.</p>
	    			</div>
	    		</div>
	    	<cfelse>
	    		<div class="row">
					<div class="col-xs-12">
						<p style="color:##e74c3c;font-weight: bold;">This load has been DELETED.<br>Please call dispatch for more information.</p>
					</div>
				</div>
	    	</cfif>
    		<div class="row">
    			<div class="col-xs-12 col-lg-12" style="border:outset 1px;margin-bottom: 10px;">
    			</div>
    		</div>
    		<div class="row" style="margin-bottom: 20px;">
    			<div class="col-xs-12 col-lg-12">
    				<strong><u>NOTE:</u> For help please call #qGetCompanyDetails.companyName# at #qGetLoadDetails.Phone# and ask for #qGetLoadDetails.Dispatcher#. You can also email us at #qGetLoadDetails.EmailID#</strong>
    			</div>
    		</div>
    		<div class="row lmLogo" style="margin-bottom: 20px;">
    			<div class="col-xs-12 col-lg-8">
    				<i>Powered by <a href="http://www.loadmanager.com">Load Manager TMS</a> software.</i><br><img src="https://www.loadmanager.com/wp-content/uploads/2016/06/small-load-logo.png">
    			</div>
    		</div>
		</div>
	</body>
</html>
<script src="https://code.jquery.com/jquery-1.10.2.min.js"></script>
<script type="text/javascript">

	$(document).ready(function(){
		var currentDate = new Date();
		var arr = /\((.*)\)/.exec(currentDate.toString())[1].split(" ");
		var i;
		var timezone = "";
		for (i = 0; i < arr.length; i++) {
		  timezone += arr[i].split("")[0] + "";
		}
        var currentDay = currentDate.getDate();
        var currentMonth = currentDate.getMonth() + 1;
        var currentYear = currentDate.getFullYear();
        var hours = currentDate.getHours();
        var minutes = currentDate.getMinutes();
        currentMonth = currentMonth < 10 ? '0'+currentMonth : currentMonth;
        currentDay = currentDay < 10 ? '0'+currentDay : currentDay;
        var currentDate = currentMonth + "/" + currentDay + "/" + currentYear;
        var ampm = hours >= 12 ? 'PM' : 'AM';
        hours = hours % 12;
        hours = hours ? hours : 12; // the hour '0' should be '12'
        minutes = minutes < 10 ? '0'+minutes : minutes;
        var strTime = hours + ':' + minutes + ' ' + ampm;
        var DateTimeString = currentDate+' '+strTime+' '+timezone;
		$('##DateTimeString').val(DateTimeString);

		$.getJSON("https://api.ipify.org?format=json", function(data) { 
			$('##ipAddress').val(data.ip);
	    }) 

	    $('.percentage').change(function(){
	    	var per = 0;
	    	var curr_per = $("##percText").html().split('%')[0];
	    	$( ".percentage" ).each(function() {
	    	    if($.trim($(this).val()).length){
	    	   		per+=$(this).data('perc');
	    	    }
			});
			$("##perc").animate({ width: per+'%' }, 'slow');
			var rem_perc = per-curr_per;

			console.log('curr:'+curr_per+'rem:'+rem_perc);
			jQuery({ Counter: curr_per }).animate({ Counter: per }, {
			    duration: 500,
			    easing: 'swing',
			    step: function () {
			      $("##percText").text(Math.round(this.Counter)+'%');
			    }
			  });
	    })
	})

	

	function validate(){
		var regex = /^([a-zA-Z0-9_\.\-\+])+\@(([a-zA-Z0-9\-])+\.)+([a-zA-Z0-9]{2,4})+$/;
		var name = $.trim($('##Signature').val());
		var email = $.trim($('##Email').val());
		if(!name.length){
			alert('Please enter Your Name/Signature.');
			$('##Signature').focus();
			return false;
		}
		else if(email.length && !regex.test(email)){
			alert('Invalid Email.');
			$('##Email').focus();
			return false;
		}
		else if(email.includes(".@")){
			alert('Invalid Email.');
			$('##Email').focus();
			return false;	
		}
		else{
			$( "##SaveRateCon" ).hide();
			$( "##delLoader" ).show();
			return true;
		}
	}
	function ParseUSNumber(frmfld,fldName) {
		var phoneText = $(frmfld).val();
		phoneText = phoneText.toString().replace(/,/g, "");
		phoneText = phoneText.replace(/-/g, "");
		phoneText = phoneText.replace(/\(/g, "");
		phoneText = phoneText.replace(/\)/g, "");
		phoneText = phoneText.replace(/ /g, "");
		phoneText = phoneText.replace(/ /g, "");
		  
	  	if(phoneText.substring(0,10).search(/[a-zA-Z]/g)==-1 & isFinite(phoneText.substring(0,10)) & phoneText.substring(0,10).length==10){
			var part1 = phoneText.substring(0,6);
			part1 = part1.replace(/(\S{3})/g, "$1-");
			var part2 = phoneText.substring(6,10);
			var ext = phoneText.substring(10);
			if (ext.length) {
				var phoneField = part1 + part2+" "+ext;
			} else {
				var phoneField = part1 + part2;
			}
			$(frmfld).val(phoneField);
		} else if(phoneText.substring(0,10).length !=0) {
			alert('Invalid Phone Number!');
			$(frmfld).focus();
		}
	}
</script>
</cfoutput>