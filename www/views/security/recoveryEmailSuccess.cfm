<cfoutput>
<script language="javascript" type="text/javascript">
	function Validation()
	{
		if(document.getElementById('txtEmailAddress').value.length == 0)
		{
			alert("Please enter your email address");
			document.getElementById('txtEmailAddress').focus();
			return false;
		}
	}
</script>
<div class="login-bg">
	<div class="login-title">Email Sent</div>
	<form action="index.cfm?event=lostpassword:process&#Session.URLToken#<cfif structkeyexists(url,'type')>&type=c</cfif>" method="post" name="frmLostPassword" id="frmLostPassword" onSubmit="JavaScript: return Validation(this)" autocomplete="off">
		<fieldset>
		<cfif isdefined('URL.Success')>
			<div id="alertmsg">
				<cfif structKeyExists(url, "Type") AND url.Type EQ "CompanyCode">
					<h4 style="color:##287E0D;margin-bottom: 15px;margin-right: 40px;">
						The company code associated with the email entered has been sent.<br>
						Please check your email.<br>
						Click <a href="index.cfm" title="login" style="text-decoration: underline;">here</a>
						to login.
					</h4>
				<cfelseif structKeyExists(url, "Type") AND url.Type EQ "UserName">
					<h4 style="color:##287E0D;margin-bottom: 15px;margin-right: 40px;">
						Username and password is send to your email address.<br>
						Please check your email.<br>
						Click <a href="index.cfm" title="login" style="text-decoration: underline;">here</a>
						to login.
					</h4>
				<cfelse>
					<h4 style="color:##287E0D;margin-bottom: 15px;margin-right: 40px;">
						Username and password is send to your email address. Please check your email.<br>
						Click <a href="index.cfm<cfif isdefined('URL.Type')>?event=customerlogin</cfif>" title="login" style="text-decoration: underline;">here</a>
						to login.
					</h4>
				</cfif>
			</div>
		</cfif>
		<div class="clear"></div>
		</fieldset>			
	</form>
	<div class="clear"></div>
</div>
</cfoutput>