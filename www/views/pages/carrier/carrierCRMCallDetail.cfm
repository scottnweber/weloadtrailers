<cfoutput>
	<style>
		.Company{
			font-size: 14px;
			margin-left: 5px;
		}
	</style>
	<div class="white-con-area" style="width:999px">
		<div class="white-mid" style="width:999px">
			<div class="form-con" style="width:500px;padding:0;background-color: #request.qsystemsetupoptions1.BackgroundColorForContent# !important;">
				<div style="height: 36px;background-color: ##82bbef;margin-bottom: 5px;float: right;">
                    <h2 style="color:white;font-weight:bold;padding-top: 10px;width:490px;text-align: left;">Call Details</h2>
                </div>
                <div class="clear"></div>
                <fieldset>
                    <b class="Company">#qCRMCallDetail.Company#</b>
                    <div class="clear"></div>
                    <label>User Name:</label>#qCRMCallDetail.UserName#
                    <div class="clear"></div>
                    <label>Contact:</label>#qCRMCallDetail.Contact#
                    <div class="clear"></div>
                    <label>Date:</label>#DateFormat(qCRMCallDetail.Date,"mm/dd/yyyy")#
                    <div class="clear"></div>
                   	<label>Phone##:</label>#qCRMCallDetail.Phone#
                   	<div class="clear"></div>
                    <label>Type:</label>#qCRMCallDetail.CallType#
                    <div class="clear"></div>
                    <label><u>Call Note:</u></label>
                    <div class="clear"></div>
                    <div style="margin-left: 50px;">#qCRMCallDetail.CallNotes#</div>
                    <div class="clear"></div>
                    <input type="button" onclick="document.location.href='index.cfm?event=carrierCRMCallHistory&#session.URLToken#'" name="back" class="bttn" value="Back" style="float: right;">
                </fieldset>
			</div>
		</div>
	</div>
</cfoutput>