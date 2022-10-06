<cfoutput>
	<style>
	    ##popup-e-dispatch{
	        left: 27%;
	        background-color: #request.qSystemSetupOptions1.BackgroundColorForContent#;
	        width: 450px;
	        top: 30%;
	    }
	</style>
	<script type="text/javascript">
		function openEDispatchpopup(){
			$('body').addClass('formpopup-body-noscroll');
			$('.formpopup-overlay').show();
			$('##popup-e-dispatch').show();
		}

		function submitDispatchForm(opt){
			if(opt == 1){
				<cfif structkeyexists(url,"loadid") and len(trim(url.loadid)) gt 1>
					newwindow=window.open('index.cfm?event=loadMail&type=EDispatch&loadid='+mailLoadId+'&'+mailUrlToken+'&carrierDispatch=#variables.carrierDispatch#','Map','height=550,width=750');
		            if (window.focus) {
		                newwindow.focus()
		            }
	            </cfif>
	            $('body').removeClass('formpopup-body-noscroll');
	            $( ".form-popup" ).hide();
	            $('.formpopup-overlay').hide();
			}
			else{
				$.ajax({
                    type    : 'POST',
                    url     : "ajax.cfm?event=ajxCancelDispatch&#session.URLToken#",
                    data    : {LoadID:'#url.loadid#'},
                    success :function(data){
                        location.reload();
                    }
                })
			}
            
		}
	</script>
	<div class="form-popup" id="popup-e-dispatch">
	    <div class="form-popup-header">
	        This load has already been dispatched
	        <span class="form-popup-close">&times;</span>
	    </div>
	    <div class="form-popup-content">
	    	<form name="frmAddNewCustomer" id="frmAddNewCustomer">
	    		<p><b>Do you want to dispatch it to a new driver or would you like to cancel the previous dispatch?</b></p>
	            <div class="clear"></div>
	            <input type="button" name="NewDriver" class="actbttn" value="New Driver" style="margin-left: 175px;" onclick="submitDispatchForm(1)">
		        <input type="button" class="actbttn" name="CancelDispatch" class="bttn" value="Cancel Dispatch" onclick="submitDispatchForm(2)">
		        <img src="images/loadDelLoader.gif" class="fp-loader">
		    </form>
	    </div>
	</div>
</cfoutput>