<cfoutput>
<script language="javascript" type="text/javascript">
	function Validation()
	{	
		if(document.getElementById('txtCompanyName').value.length == 0)
		{
			alert("Please enter CompanyName.");
			document.getElementById('txtCompanyName').focus();
			return false;
		}

		if(document.getElementById('txtUsername').value.length == 0)
		{
			alert("Please enter your Name.");
			document.getElementById('txtUsername').focus();
			return false;
		}

		if(document.getElementById('txtEmailAddress').value.length == 0)
		{
			alert("Please enter Email Address.");
			document.getElementById('txtEmailAddress').focus();
			return false;
		}
	}
	$(document).ready(function() {
		$('##txtCompanyName').focus();
	})
</script>
<style>
	.login-bg form fieldset{
		margin-left: 25px;
	}
</style>
<div class="login-bg">
	<div class="login-title">Account Recovery</div>
	<form action="index.cfm?event=lostCompanyCode:process&#Session.URLToken#<cfif structkeyexists(url,'type')>&type=c</cfif>" method="post" name="frmLostCompanyCode" id="frmLostCompanyCode" onSubmit="JavaScript: return Validation(this)" autocomplete="off">
		<fieldset>
			<cfif isdefined('URL.Failed')>
				<div id="alertmsg">
					<h4 style="color:red;margin-bottom: 15px;margin-left: 54px;">
						No company record exists for that Email address
					</h4>
				</div>
			</cfif>
			<label class="user" style="width:145px;text-align: left;">Company Name:</label>
			<input type="text" id="txtCompanyName" name="txtCompanyName" class="field" tabindex="1">
			<div class="clear"></div>
			<label class="user" style="width:145px;text-align: left;">Your Name:</label>
			<input type="text" id="txtUsername" name="txtUsername" class="field"  tabindex="2">
			<div class="clear"></div>
			<label class="user" style="width:145px;text-align: left;">Account Email Address: <span style="font-size: 10px;font-weight: normal;font-style: italic;">Please put in the email on file associate with your subscription</span></label>
			<input type="text" id="txtEmailAddress" name="txtEmailAddress" class="field" tabindex="3">
			<div class="clear"></div>
			<div style="padding-left:156px;"><input  tabindex="4" type="button" value="Cancel" class="loginbttn" style="margin-right:15px;" onclick="document.location.href='index.cfm';" /><input type="submit" value="Submit" class="loginbttn"  tabindex="5"/></div>
			<div class="clear"></div>
		</fieldset>			
	</form>
	<div class="clear"></div>
</div>
</cfoutput>