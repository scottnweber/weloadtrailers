<cfoutput>
<script language="javascript" type="text/javascript">
	function Validation()
	{	
		if(document.getElementById('txtCompanyCode').value.length == 0)
		{
			alert("Please enter company code.");
			document.getElementById('txtCompanyCode').focus();
			return false;
		}

		if(document.getElementById('txtEmailAddress').value.length == 0 && document.getElementById('txtUsername').value.length == 0)
		{
			alert("Please enter your Username/Email address.");
			document.getElementById('txtUsername').focus();
			return false;
		}
	}
	$(document).ready(function() {
		$('##txtCompanyCode').focus();
		$( "##txtUsername" ).keyup(function() {
			if($.trim($(this).val()).length){
				$('##txtEmailAddress').val('');
				$( "##txtEmailAddress" ).css('background-color','##c5c1c1');
				$('##txtEmailAddress').attr('readonly', true);
				$('##txtEmailAddress').attr('tabindex', 100);
			}
			else{
				$( "##txtEmailAddress" ).css('background-color','##fff');
				$("##txtEmailAddress").removeAttr('readonly');
				$('##txtEmailAddress').attr('tabindex', 3);
			}
		});

		$( "##txtEmailAddress" ).keyup(function() {
			if($.trim($(this).val()).length){
				$('##txtUsername').val('');
				$( "##txtUsername" ).css('background-color','##c5c1c1');
				$('##txtUsername').attr('readonly', true);
				$('##txtUsername').attr('tabindex', 100);
			}
			else{
				$( "##txtUsername" ).css('background-color','##fff');
				$("##txtUsername").removeAttr('readonly');
				$('##txtUsername').attr('tabindex', 3);
			}
		});
	})
</script>
<style>
	.login-bg form fieldset{
		margin-left: 25px;
	}
</style>
<div class="login-bg">
<div class="login-title">Password Recovery</div>
<form action="index.cfm?event=lostpassword:process&#Session.URLToken#<cfif structkeyexists(url,'type')>&type=c</cfif>" method="post" name="frmLostPassword" id="frmLostPassword" onSubmit="JavaScript: return Validation(this)" autocomplete="off">
				<fieldset>
				<!--- <label class="user">Please enter your email address and we will send your login details to you</label> --->
				<cfif isdefined('URL.Failed')>
					<div id="alertmsg">
						<!--- <h4 style="color:red;">Email Address Not Found</h4> --->
						<h4 style="color:red;margin-bottom: 15px;margin-left: 54px;">
							<cfif structkeyexists(url,"type")>
								No customer exists for that email address
							<cfelse>
								No user exists for that Username/Email address
							</cfif>
						</h4>
					</div>
				</cfif>
				<label class="user" style="width:100px;">Company Code:</label>
				<input type="text" id="txtCompanyCode" name="txtCompanyCode" class="field" tabindex="1">
				<div class="clear"></div>
				<label class="user" style="width:100px;">Username:</label>
				<input type="text" id="txtUsername" name="txtUsername" class="field"  tabindex="2">
				<div class="clear"></div>

				<label class="user" style="width:100px;">OR</label>
				<div class="clear"></div>
				<label class="user" style="width:100px;">Email Address:</label>
				<input type="text" id="txtEmailAddress" name="txtEmailAddress" class="field" tabindex="3">
				<div class="clear"></div>
				<div style="padding-left:110px;"><input  tabindex="4" type="button" value="Cancel" class="loginbttn" style="margin-right:15px;" onclick="document.location.href='index.cfm';" /><input type="submit" value="Submit" class="loginbttn"  tabindex="5"/></div>
				<div class="clear"></div>
				</fieldset>			
</form>
<div class="clear"></div>
</div>
</cfoutput>