<cfif structKeyExists(form, "Process")>
	<cfinvoke component="#variables.objLoadGateway#" method="openNewYear" returnvariable="session.openNewYrResp"/>
    <cflocation url="index.cfm?event=OpenNewYear&#session.URLToken#">
</cfif>
<cfsilent>
	<cfinvoke component="#variables.objLoadGateway#" method="getLMASystemConfig" returnvariable="qLMASystemConfig" />
	<cfset FiscalYear = qLMASystemConfig['Fiscal Year']>
</cfsilent>
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
	<cfif structKeyExists(session, "openNewYrResp")>
        <div id="message" class="msg-area-#session.openNewYrResp.res#">#session.openNewYrResp.msg#</div>
        <cfset structDelete(session, "openNewYrResp")>
    </cfif>
    <div style="clear:left"></div>
	<div class="white-con-area" style="height: 36px;background-color: ##82bbef;">
		<div style="float: left;"><h2 style="color:white;font-weight:bold;margin-left: 12px;">Open New Year</h2></div>
	</div>
	<div style="clear:left"></div>

	<div class="white-con-area">
		<div class="white-top"></div>
	    <div class="white-mid">
			<cfform name="frmOpenNewYr" action="##" method="post" onsubmit="return validateFrm();">
				<div class="form-con">
					<fieldset>
						<b>Current Fiscal Year Date: #DateFormat(FiscalYear,'mm/dd/yyyy')#</b>
						<hr>
                        <div style="margin-top:10px;">
                        	<label style="width:266px;">Clear the Check Register History for the new year?</label>
                           	<input type="checkbox" class="DeptFilter" name="DeptFilter" id="DeptFilter" style="float: left;width: 15px;">
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
		$(document).ready(function(){
			
		});

		function validateFrm(){
			if(confirm('You are about to run the Open New Year procedure. Please ensure you have a backup and nobody else is in the system. Are ready to run this procedure?')){
				return true;
			}
			return false;
		}
	</script>
</cfoutput>