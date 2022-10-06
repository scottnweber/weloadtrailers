<cfif structKeyExists(form, "Process")>
	<cfinvoke component="#variables.objLoadGateway#" method="GLRecalculate" year="#form.UpdateFrom#" returnvariable="session.GLRecalculateResp"/>
    <cflocation url="index.cfm?event=GLRecalculate&#session.URLToken#">
</cfif>
<cfoutput>
	<style type="text/css">
		.reportsSubHeading{
			border-bottom: 1px solid ##77463d !important;
			margin-bottom: 5px !important;
		}
		.msg-area-success{
            border: 1px solid ##a4da46;
            padding: 5px 15px;
            width: 82%;
            float: left;
            margin-top: 5px;
            margin-bottom:  5px;
            background-color: ##b9e4b9;
            font-weight: bold;
            font-style: italic;
        }
        .msg-area-error{
            border: 1px solid ##da4646;
            padding: 5px 15px;
            width: 82%;
            float: left;
            margin-top: 5px;
            margin-bottom:  5px;
            background-color: ##e4b9c6;
            font-weight: bold;
            font-style: italic;
        }
	</style>
	<cfif structKeyExists(session, "GLRecalculateResp")>
        <div id="message" class="msg-area-#session.GLRecalculateResp.res#">#session.GLRecalculateResp.msg#</div>
        <cfset structDelete(session, "GLRecalculateResp")>
    </cfif>
    <div style="clear:left"></div>
	<div class="white-con-area" style="height: 36px;background-color: ##82bbef;">
		<div style="float: left;"><h2 style="color:white;font-weight:bold;margin-left: 12px;">G/L Recalculate</h2></div>
	</div>
	<div style="clear:left"></div>

	<div class="white-con-area">
		<div class="white-top"></div>
	    <div class="white-mid">
			<cfform name="frmGLRecalculate" action="##" method="post" onsubmit="return validateFrm();">
				<div class="form-con">
					<fieldset>
						<h2 class="reportsSubHeading">Update From</h2>
						<div class="clear"></div>
	            		<div style="width:10px; float:left;">&nbsp;</div>
	           			<div style="float:left;">
			                <cfinput type="radio" name="UpdateFrom" value="0"  style="width:15px; padding:0px 0px 0 0px;margin-bottom:1px;" checked/>
			                <label class="normal" for="Detail" style="text-align:left; padding:0 0 0 0;width: 100px;" >Current Year</label>
			            </div>
	
			            <div style="float:left;">
			                <cfinput type="radio" name="UpdateFrom" value="1" style="width:15px; padding:0px 0px 0 0px;margin-bottom:1px;"/>
			                <label class="normal" for="Summary" style="text-align:left; padding:0 0 0 0;width: 100px;" >1 Year Prior</label>
			            </div>

			            <div style="float:left;">
			                <cfinput type="radio" name="UpdateFrom" value="2" id="Summary"  style="width:15px; padding:0px 0px 0 0px;margin-bottom:1px;"/>
			                <label class="normal" for="Summary" style="text-align:left; padding:0 0 0 0;width: 100px;" >2 Years Prior</label>
			            </div>
	    				<div class="clear"></div>

	    				<div class="right" style="margin-top:39px;">
				        	<div style="margin-left: 150px;">
								<input id="Process" type="submit" name="Process" class="bttn tooltip" value="Process" style="width:95px;"/>
				        	</div>
					    </div>
					</fieldset>
				</div>
	   			<div class="clear"></div>
	 		</cfform>
	    </div>
		<div class="white-bot"></div>
	</div>

	<script type="text/javascript">
		function validateFrm(){
			if(confirm('Are you sure you want to continue?')){
				return true;
			}
			return false;
		}
	</script>
</cfoutput>