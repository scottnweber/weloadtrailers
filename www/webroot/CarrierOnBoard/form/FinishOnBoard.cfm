<cfoutput>
	<script>
        function closeWin() {
			window.close();
        }
    </script>

	<div class="row pb-10" style="background-color: ##defaf9;">
		<div class="col-xs-12 col-lg-12 pl-0 pr-0">
			<h2 class="col-xs-12 col-lg-12 blueBg">FINISHED!</h2>
		</div>
		<div class="col-xs-12 col-lg-12" style="font-size: 14px;">
			<cfif structKeyExists(url, "SubmitManually") AND url.SubmitManually EQ 1>
				Thank you for onboarding with us.
			<cfelseif structKeyExists(url, "SubmitManually") AND url.SubmitManually EQ 2>
				Thank you for onboarding with us and please manually sign and submit by email.
			<cfelse>
				Congratulations, you have successfully completed the onboarding process. If you have any questions or need anything please call/email us and we will assist you.
			</cfif>
		</div>
	</div>
</cfoutput>