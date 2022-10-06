<cfoutput>
	<style>
	    ##popup-loadboard{
	        width: 270px;
	        left: 32%;
	        background-color: #request.qSystemSetupOptions.BackgroundColorForContent#;
	        top:37%;
	    }
	    .respMsg{
	    	font-size: 14px;
	    }
	    .redAlert{
	    	color:red;
	    }
	    .formpopup-overlay{
	    	left: 0;
	    }
	</style>

	<script type="text/javascript">
		$(document).ready(function(){
			<cfif structKeyExists(session, "FailedLBResponse") and len(trim(session.FailedLBResponse))>
				openloadboardPopup();
			</cfif>
			$('.form-popup-close').click(function(){
                $('body').removeClass('formpopup-body-noscroll');
                $( ".form-popup" ).hide();
                $('.formpopup-overlay').hide();
            });
		});
		function openloadboardPopup(){
			$('body').addClass('formpopup-body-noscroll');
			$('.formpopup-overlay').show();
			$('##popup-loadboard').show();
		}
		
	</script>
	<div class="form-popup" id="popup-loadboard">
	    <div class="form-popup-header" style="text-align: left;padding-left: 7px;">
	        LoadBoard Says:
	        <span class="form-popup-close">&times;</span>
	    </div>
	    <div class="form-popup-content">
	    	<cfif structKeyExists(session, "FailedLBResponse") and len(trim(session.FailedLBResponse))>
	    		<cfloop list="#session.FailedLBResponse#" index="LoadBoard">
			    	<div class="respMsg"><b>#LoadBoard# : </b><span class="redAlert">Credentials failed.</span></div>
			    </cfloop>
			    <cfset structDelete(session, "FailedLBResponse")>
		    </cfif>
	    </div>
	</div>
</cfoutput>