<cfoutput>
	<cfset urlCfcPath = Replace(request.cfcpath, '.', '/','All')/>
	<script src="https://code.jquery.com/jquery-1.10.2.min.js"></script>
	<script type="text/javascript">
		function sendErrorReport(){
			var eName = $.trim($('##eName').val());
			var eEmail = $.trim($('##eEmail').val());
			var eMessage = $.trim($('##eMessage').val());
			var eSteps = $.trim($('##eSteps').val());

			if(!eName.length){
				alert('Please enter your Name.');
				$('##eName').focus();
			}
			else if(!eEmail.length){
				alert('Please enter your Email Address.');
				$('##eEmail').focus();
			}
			else if(!eMessage.length){
				alert('Please enter Message.');
				$('##eMessage').focus();
			}
			else if(!eSteps.length){
				alert('Please provide Steps to reproduce.');
				$('##eSteps').focus();
			}
			else{
				var formData = $("##frmErrorReport").serialize();
				var path = "ajax.cfm?event=ajxSendErrorReport";
				$.ajax({
                    type: "Post",
	                url     : path,
	                dataType: "json",
	                async: false,
	                data: formData,
                    success :function(data){
                        alert('Thank you for your support..!!');
                        setTimeout(function(){ javascript:history.back(); }, 500);
                    }
                })
			}
		}
	</script>
	<cfparam name="eName" default="">
	<cfparam name="eEmail" default="">

	<cfparam name="SmtpAddress" default="smtp.gmail.com">
	<cfparam name="SmtpPort" default=465>
	<cfparam name="SmtpUsername" default="loadmanagertestemail@gmail.com">
	<cfparam name="SmtpPassword" default="yPnvGC0kNZ2LbD5b">
	<cfparam name="FA_TLS" default=0>
	<cfparam name="FA_SSL" default=1>

	<cfif structKeyExists(session, "empid")>
		<cfquery name="request.qcurAgentdetails" datasource="#application.dsn#">
	    	SELECT Name, EmailID, SmtpAddress, SmtpUsername, SmtpPassword, SmtpPort, useTLS, useSSL,emailSignature,EmailValidated,Telephone
	        FROM Employees
	        WHERE EmployeeID = <cfif len(trim(session.empid))>
	        	<cfqueryparam value="#session.empid#" cfsqltype="cf_sql_varchar">
	        <cfelse>
	        	<cfqueryparam value="" cfsqltype="cf_sql_varchar" null="true">
	        </cfif>
	    </cfquery>
		<cfset eName = "#request.qcurAgentdetails.name#">
		<cfset eEmail = "#request.qcurAgentdetails.EmailID#">

		<cfif request.qcurAgentdetails.recordcount gt 0 and request.qcurAgentdetails.SmtpAddress neq "" and request.qcurAgentdetails.SmtpUsername neq "" and request.qcurAgentdetails.SmtpPort neq "" and request.qcurAgentdetails.SmtpPassword neq "" and request.qcurAgentdetails.SmtpPort neq 0 and request.qcurAgentdetails.EmailValidated eq 1>
			<cfset SmtpAddress=request.qcurAgentdetails.SmtpAddress>
			<cfset SmtpUsername=request.qcurAgentdetails.SmtpUsername>
			<cfset SmtpPort=request.qcurAgentdetails.SmtpPort>
			<cfset SmtpPassword=request.qcurAgentdetails.SmtpPassword>
			<cfset FA_SSL=request.qcurAgentdetails.useSSL>
			<cfset FA_TLS=request.qcurAgentdetails.useTLS>
		</cfif>
	</cfif>
	<form name="frmErrorReport" id="frmErrorReport">
		<input type="hidden" name="companycode" id="companycode" value="#companycode#">
		<input type="hidden" name="SmtpAddress" id="SmtpAddress" value="#SmtpAddress#">
		<input type="hidden" name="SmtpUsername" id="SmtpUsername" value="#SmtpUsername#">
		<input type="hidden" name="SmtpPort" id="SmtpPort" value="#SmtpPort#">
		<input type="hidden" name="SmtpPassword" id="SmtpPassword" value="#SmtpPassword#">
		<input type="hidden" name="FA_SSL" id="FA_SSL" value="#FA_SSL#">
		<input type="hidden" name="FA_TLS" id="FA_TLS" value="#FA_TLS#">
		<p>Help us fix the issue:</p>
		<label style="float:left;width: 140px;">Your Name*</label><input type="text" name="eName" id="eName" value="#eName#" style="width: 500px;"><br><br>
		<label style="float:left;width: 140px;">Email Address*</label><input type="text" name="eEmail" id="eEmail" value="#eEmail#" style="width: 500px;"><br><br>
		<label style="float:left;width: 140px;">Message*</label><textarea name="eMessage" id="eMessage" style="width: 500px;height: 100px;"></textarea><br><br>
		<label style="float:left;width: 140px;">Steps to reproduce*</label><textarea name="eSteps" id="eSteps" style="width: 500px;height: 150px;"></textarea>
		<div style="width: 700px;text-align: center;margin-top: 15px;">
			<input type="button" value="Send" onclick="sendErrorReport();">
			<input type="button" value="Cancel" style="margin-left: 10px;" onclick="javascript:history.back();"><br><br>
			<input type="button" value="Go Back" onclick="javascript:history.back();">
		</div>
	</form>
</cfoutput>