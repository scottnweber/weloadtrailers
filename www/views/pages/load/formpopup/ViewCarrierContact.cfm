<cfoutput>
	<style>
	    ##popup-carrier-contact-details{
	        width: auto;
	        left: 34%;
	        background-color: #request.qSystemSetupOptions1.BackgroundColorForContent#;
	    }
	</style>
	<script type="text/javascript">
		function openViewCarrierContactPopup(inp){
			var CarrierContactID = $(inp).closest('div').find('[id^=CarrierContactID]').val();
			if(CarrierContactID.length){
				var path = urlComponentPath+"carriergateway.cfc?method=getCarrierContactDetail&CarrierContactID="+CarrierContactID+"&dsn=#Application.dsn#";
				$.ajax({
	                type: "get",
	                url: path,
	                success: function(response){
	                	var obj = jQuery.parseJSON(response);
	                	$.each(obj, function(key,value) {
	                		if(key=='EMAIL'){
	                			value = '<a href="mailto:'+value+'">'+value+'</a>';
	                		}
	                		if(key=='LOCATION'){
	                			value = value[0].replace(/\n/g, "<br />");
	                		}
						  	$('##fp_'+key).html(value);
						}); 
	                	$('body').addClass('formpopup-body-noscroll');
						$('.formpopup-overlay').show();
						$('##popup-carrier-contact-details').show();
	                }
	            });
			}
		}
	</script>
	<div class="form-popup" id="popup-carrier-contact-details">
	    <div class="form-popup-header">
	        Carrier Contact Details
	        <span class="form-popup-close">&times;</span>
	    </div>
	    <div class="form-popup-content">
	    	<label>Contact Type:</label>
	    	<span id="fp_CONTACTTYPE"></span>
	    	<div class="clear"></div>
		    <label>Contact Name:</label>
		    <span id="fp_CONTACTPERSON"></span>
		    <div class="clear"></div>
		    <label>Address:</label>
		    <div id="fp_LOCATION" style="float: left;width:170px;"></div>
		    <div class="clear"></div>
		    <label>&nbsp;</label>
		    <span id="fp_CITY"></span>, <span id="fp_STATECODE"></span> <span id="fp_ZIPCODE"></span> 
		    <div class="clear"></div>
		    <label>Phone:</label>
		    <span id="fp_PHONENO"></span> <span id="fp_PHONENOEXT"></span>
		    <div class="clear"></div>
		    <label>Fax:</label>
		    <span id="fp_FAX"></span> <span id="fp_FAXEXT"></span>
		    <div class="clear"></div>
		    <label>Toll Free:</label>
		    <span id="fp_TOLLFREE"></span> <span id="fp_TOLLFREEEXT"></span>
		    <div class="clear"></div>
		    <label>Cell:</label>
		    <span id="fp_PERSONMOBILENO"></span> <span id="fp_MOBILENOEXT"></span>
		    <div class="clear"></div>
		    <label>EmailID:</label>
		    <span id="fp_EMAIL"></span>
		    <div class="clear"></div>
		    <input type="button" class="actbttn form-popup-close" name="closeCarrierContactForm" value="Close" style="float: right;">
	    </div>
	</div>
</cfoutput>