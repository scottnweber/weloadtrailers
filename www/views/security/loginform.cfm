<cfparam name="URL.allowedUserFlagID" default="1">
<cfoutput>
<cfif variables.showCaptcha EQ 1>
	<script src="javascripts/jquery-captcha.js?#now()#" language="javascript" type="text/javascript"></script>
</cfif>
<script language="JavaScript1.2" type="text/javascript">
	<cfif variables.showCaptcha EQ 1>
		$(document).ready(function() {
			const captcha =new Captcha($('##canvas'),{});
			const code = captcha.getCode();
		})
	</cfif>
	function Validation(objForm) {
		if(objForm.txtUserName.value == "") {
			alert('Please insert your user name.');
			objForm.txtUserName.focus();
			return false;
		}
		if(objForm.txtPassword.value == "") {
			alert('Please insert your password.');
			objForm.txtPassword.focus();
			return false;
		}
		if(objForm.txtCompanyCode.value == "") {
			alert('Please insert your Company Code.');
			objForm.txtCompanyCode.focus();
			return false;
		}

		<cfif variables.showCaptcha EQ 1>
			if(objForm.Captcha.value == "") {
				alert('Please enter Captcha.');
				objForm.Captcha.focus();
				return false;
			}
			if(objForm.Captcha.value != objForm.CaptchaCheck.value) {
				alert('Invalid Captcha.');
				objForm.Captcha.focus();
				return false;
			}
		</cfif>
		<cfif listFirst(cgi.SCRIPT_NAME,'/') EQ 'LoadManagerBeta'>
		return true;
		<cfelse>
			$.ajax({
	            type    : 'GET',
	            url     : "ajax.cfm?event=ajxCheckBetaVersion&CompanyCode="+objForm.txtCompanyCode.value,
	            success :function(res){
	            	if(res==1){
	            		$("##frmLogin").attr('action', 'https://loadmanager.net/loadmanagerbeta/www/webroot/index.cfm?event=login:process');
	            		objForm.submit();
	            	}
	            	else{
	            		$('##loggingIn').show();
	            		objForm.submit();
	            	}
	            }
	        })
			return false;
		</cfif>

	}

	function Initialize() {
		document.getElementById('txtCompanyCode').focus();

		if(top.document.location.href != document.location.href) {
			try {
				top.locateTimeout('index.cfm?event=loginPage&#Session.URLToken#');
				window.close();
			}
			catch (e) {
			}
		}
						
	}
	
	$(document).ready(function() {
        $('.getInactiveUser').click(function() {
            var customerId = $(this).val();
            var useruniqueid = $(this).attr( "data-useruniqueid" );
            if(customerId) {
	            $.ajax({
			   		type 	: 'POST',
				  	url		: "eliminateInactiveUsers.cfc?method=eliminateinactiveusers",
				  	data 	: {customerId : customerId, useruniqueid : useruniqueid},
				  	success	:function(data){
				  		$('.userLimitWarning').hide();
				  		$('.userListItem_'+customerId+'_'+useruniqueid).hide();
				  	}
				});
            }
        });
    });

</script>
<style type="text/css">
	.loggedUsersTd{
		width: 90px !important;
		text-align: center !important;
		padding: 5px !important;
	}
	.loggedUsers{
		width: 300px !important;
		margin: 0 auto !important;
	}
	.loggedUsers h3, .loggedUsers h4{
		text-align: center !important;
	}
	.loggedUsers h3 {
		color: red !important;
	}
	.login-bg{
		background: none;
		border: solid 2px ##ccd5ff;
		<cfif variables.showCaptcha EQ 1>height: auto;</cfif>
	}
	.login-title{
		border-bottom: solid 2px ##ccd5ff;
		width: auto;
		padding-bottom: 15px;
	}
	.login-bg form fieldset{
		margin-top: 20px;
		margin-bottom: 10px;
	}
	.login-bg form fieldset label.fpass{
		font-size: 10px;
	}
</style>

<cfif structKeyExists(session, "PaymentExpired") AND Session.PaymentExpired EQ 1 >
<div align="center" style="background:##e6e6e6;margin:5%;width:55%;margin-left: 21%;">
	<div style="margin:5%;">
		<h3 class="text-bold" style="color:##880015;font-weight:bold;fontsize:15px; margin-left: -391px;">PAYMENT DUE :</h3>
		<h4 style="text-align: justify;color:##3f48cc;font-size:13px;">#qPaymentDue.Message#</h4>
</cfif>
		<div class="login-bg" <cfif structKeyExists(session, "PaymentExpired") AND Session.PaymentExpired EQ 1 >style="margin-top:3% !important;margin-bottom:2% !important;"</cfif> style="height: 200px;">
			<div class="login-title">Login<cfif listFirst(cgi.SCRIPT_NAME,'/') EQ 'LoadManagerBeta'><sup> BETA</sup></cfif></div>
			<form action="index.cfm?event=login:process&#Session.URLToken#&reinit=true" method="post" name="frmLogin" id="frmLogin" onSubmit="JavaScript: return Validation(this)" autocomplete="off">
				<cfif IsDefined("URL.AlertMessageID") And IsDefined("Session.Passport.LoginError") And URL.AlertMessageID EQ 1>
					<div class="msg-area" style="width:360px;color:red;">#Session.Passport.LoginError#</div>
				<cfelseif IsDefined("URL.AlertMessageID") and URL.AlertMessageID eq 2>
					<div class="msg-area" style="width:360px;color:red;">Session has expired</div>
				<cfelseif IsDefined("URL.AlertMessageID") and URL.AlertMessageID eq 10>
					<div class="msg-area" style="width:360px;color:red;">Invalid Captcha.</div>
				<cfelseif IsDefined("URL.AlertMessageID") and URL.AlertMessageID eq 11>
					<div class="msg-area" style="width:360px;color:red;">Your subscription is no longer active.</div>
				<cfelseif IsDefined("URL.AlertMessageID") and URL.AlertMessageID eq 12>
					<div class="msg-area" style="width:360px;color:red;">Invalid Company Code.</div>
				</cfif>
				<fieldset>
				<input type="hidden" id="txtCompanyCode" name="txtCompanyCode" value="weloadtrailers">
				<label class="user">Username: </label>
				<input type="text" id="txtUserName" name="txtUsername" class="field">
				<div class="clear"></div>
				<label class="user">Password:</label>
				<input type="password" id="txtPassword" name="txtLoginPassword" class="field" maxlength="50">
				<i class="far fa-eye fa-eye-slash"  style="margin-left: -20px; cursor: pointer; margin-top:6px;"></i>
				<div class="clear"></div>

				<cfif variables.showCaptcha EQ 1>
					<label class="user">Enter Captcha:</label>
					<input type="text" id="Captcha" name="Captcha" class="field" style="width: 75px;">
					<label class="user">Remember me</label>
					<input type="checkbox" style="width: 20px;" name="Remember">
					<div class="clear"></div>
					<label class="user">&nbsp;</label>
					<input type="hidden" value="" name="CaptchaCheck" id="CaptchaCheck">
					<canvas id="canvas" width="130" height="45"></canvas>

					<div class="clear"></div>
				</cfif>

				<label class="user">&nbsp;</label>
				
				<div style="float: left;width: 140px;">
					<label class="fpass"><a  href="index.cfm?event=lostUserName&#Session.URLToken#">Forgot your Username?</a></label>
					<label class="fpass"><a  href="index.cfm?event=lostPassword&#Session.URLToken#">Forgot your Password?</a></label>
				</div>
				<div>
					<input name="btnSubmit" type="submit" class="loginbttn" value="Login">
				</div>
				<div class="clear"></div>	
			</form>
			<cfif structKeyExists(session, "PaymentExpired") AND Session.PaymentExpired EQ 1 >
			<cfset structDelete(session, "PaymentExpired")>
			<div align="center">
				</br>
				<p class="text-center" style="color:##880015;font-weight:bold;fontsize:15px;">Your login has expired due to missing payment.  </p>
				<p  class="text-center" style="color:##880015;font-weight:bold;fontsize:15px;">Please call us to get your login reactivated.</p>	
			</div>
		</div>		
	</div>
	<div>&nbsp;</div>
	</cfif>
	<div id="loggingIn" style="color:red;text-align: center;margin-top: 5px;display: none;"><b>Logging in...</b></div>
</div>

<div class="clear"></div>
<cfif URL.allowedUserFlagID EQ 0>
	<cfquery name="qActiveUsers" datasource="#Application.dsn#">
		SELECT 	cutomerId,currenttime,isactive,username,isLoggedIn,useruniqueid
		FROM	userCountCheck 
		<cfif structKeyExists(url, "txtCompanyCode")>
			WHERE CUTOMERID IN (SELECT E.EmployeeID from Employees E INNER JOIN Offices O ON O.OfficeID = E.OfficeID
				INNER JOIN Companies C ON C.CompanyID = O.CompanyID WHERE C.CompanyCode = <cfqueryparam value="#url.txtCompanyCode#" cfsqltype="cf_sql_varchar">)
		</cfif>
	</cfquery>

	<div class="loggedUsers">
		<h3 class="userLimitWarning">All Users are currently logged on. To Log on, please click on a red circle X below to log off a user and try again.</h3>
		<h4>Current User Status</h4>
		<table>
			<thead>
				<th class="loggedUsersTd">Name</th>
				<th class="loggedUsersTd">Status</th>
				<th class="loggedUsersTd">Last Active Date_time</th>
				<th class="loggedUsersTd">Action</th>
			</thead>
			<tbody>
				<cfif qActiveUsers.recordcount>
					<cfloop query="qActiveUsers">
						<tr class="userListItem_#qActiveUsers.cutomerId#_#qActiveUsers.useruniqueid#">
							<td class="loggedUsersTd">#qActiveUsers.username#</td>
							<td class="loggedUsersTd">
								<cfif qActiveUsers.isactive eq 0>
									<span style="color:red">Inactive</span>
								<cfelse>
									<span>Active</span>
								</cfif>
							</td>
							<td class="loggedUsersTd">#DatetimeFormat(qActiveUsers.currenttime,"mm/dd/yyyy_HH:nn:ss")#</td>
							<td class="loggedUsersTd"><button style="border: none; border-radius: 100%; color: white; background-color: red; margin-left: 10px;" value="#qActiveUsers.cutomerId#" data-useruniqueid="#qActiveUsers.useruniqueid#" class="getInactiveUser"> x </button>
							</td>
						<tr>
					</cfloop>	
				</cfif>		
			</tbody>
		</table>
	</div>

</cfif>


<script language="javascript" type="text/javascript">
	Initialize();
</script>
<!--LOGIN_PAGE--><!---Do not remove this HTML comment, it is used for ajax to detect when the session times out--->
</cfoutput>