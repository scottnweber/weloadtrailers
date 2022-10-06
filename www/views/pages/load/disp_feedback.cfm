<cfinvoke component="#variables.objloadGateway#" method="getCompanyName" returnvariable="request.qCompanyName" /> 
<cfinvoke component="#variables.objloadGateway#" method="getcurAgentMaildetails" returnvariable="request.qcurAgentdetails" employeID="#session.empid#" />

<cfif isDefined('FORM.feedback_buttn')>
	<cfif not len(trim(form.f_description))>
		<cfset errMsg = "Please enter description.">
	<cfelse>

		<cfset imagesFolder = ExpandPath('..\fileupload\img\support')>
		<cfif not directoryExists(imagesFolder)>
			<cfdirectory action="create" directory="#imagesFolder#">
		</cfif>
		<cfif form.Attachment NEQ ''>
			<cffile action="upload" fileField="Attachment" destination="#imagesFolder#" nameconflict="makeunique">
			<cfset serverFileName = '#cffile.SERVERFILE#'>
			   <cfset attachment_local_file_1 = "#imagesFolder#\#serverFileName#">
		<cfelse>
			<cfset serverFileName = ''>
		</cfif>

		<cfif isdefined('session.AdminUserName')>
			<cfset User=session.AdminUserName>
		<cfelse>
			<cfset User=''>
		</cfif>
		<cfquery name="qrySetfeedback" datasource="#Application.dsn#" result="qResult">
			INSERT INTO FeedbackDetails (
				u_publicIP,
				u_LocalIP,
				[User], 
				Company_name, 
				name, 
				email, 
				phone, 
				attachment,
				description,
				flag,
				url )
			VALUES (
				<cfqueryparam value="#CGI.REMOTE_ADDR#" cfsqltype="cf_sql_varchar">,
				<cfqueryparam value="#CGI.SERVER_NAME#" cfsqltype="cf_sql_varchar">,
				<cfqueryparam value="#User#" cfsqltype="cf_sql_varchar">,
				<cfqueryparam value="#form.comp_Name#" cfsqltype="cf_sql_varchar">,
				<cfqueryparam value="#form.f_Name#" cfsqltype="cf_sql_varchar">,
				<cfqueryparam value="#form.f_email#" cfsqltype="cf_sql_varchar">,
				<cfqueryparam value="#form.f_phone#" cfsqltype="cf_sql_varchar">,
				<cfqueryparam value="#serverFileName#" cfsqltype="cf_sql_varchar">,
				<cfqueryparam value="#form.f_description#" cfsqltype="cf_sql_varchar">,
				<cfqueryparam value="0" cfsqltype="cf_sql_bit">,
				<cfqueryparam value="#CGI.HTTP_HOST#" cfsqltype="cf_sql_varchar">
				)
		</cfquery>

		<cfif request.qcurAgentdetails.SmtpAddress eq "" or request.qcurAgentdetails.SmtpUsername eq "" or request.qcurAgentdetails.SmtpPort eq "" or request.qcurAgentdetails.SmtpPassword eq "" or request.qcurAgentdetails.useSSL eq "" or request.qcurAgentdetails.useTLS eq "" or request.qcurAgentdetails.SmtpPort eq 0 or request.qcurAgentdetails.EmailValidated EQ 0>
			<cfset SmtpAddress = "smtp.gmail.com">
			<cfset SmtpPort = 465>
			<cfset SmtpUsername = "loadmanagertestemail@gmail.com">
			<cfset SmtpPassword = "yPnvGC0kNZ2LbD5b">
			<cfset FA_TLS = 0>
			<cfset FA_SSL = 1>
			<cfset SmtpFrom = "loadmanagertestemail@gmail.com">
		<cfelse>
			<cfset SmtpAddress=request.qcurAgentdetails.SmtpAddress>
			<cfset SmtpUsername=request.qcurAgentdetails.SmtpUsername>
			<cfset SmtpPort=request.qcurAgentdetails.SmtpPort>
			<cfset SmtpPassword=request.qcurAgentdetails.SmtpPassword>
			<cfset FA_SSL=request.qcurAgentdetails.useSSL>
			<cfset FA_TLS=request.qcurAgentdetails.useTLS>
			<cfset SmtpFrom = form.f_email>
		</cfif>

	  	<cfmail from="#SmtpFrom#" to="support@loadmanager.com" subject="#left((stripHTML(trim(form.f_description))),100)#" type="html" server="#SmtpAddress#" username="#SmtpUsername#" password="#SmtpPassword#" port="#SmtpPort#" usessl="#FA_SSL#" usetls="#FA_TLS#">
			<cfsilent>
				<cfif form.Attachment NEQ ''>
			    	<cfmailparam file="#attachment_local_file_1#">
			    </cfif>
			</cfsilent>
			<cfoutput>
				<cfif len(form.f_Name) gt 2>Name :<b>#form.f_Name#</b><br></cfif>
				<cfif len(form.f_phone) gt 2>Phone :<b>#form.f_phone#</b><br></cfif>
				<cfif len(form.f_email) gt 2>Email address :<b>#form.f_email#</b><br></cfif>
				<cfif len(form.f_description) gt 2>Description :<b> #form.f_description#</b><br></cfif>
				<cfif len(form.comp_Name) gt 2>Company Name : <b>#form.comp_Name#</b><br></cfif>
				<cfif len(form.companycode) gt 2>Company Code : <b>#form.companycode#</b><br></cfif>
			</cfoutput>
		</cfmail>
		<cflocation  url="index.cfm?event=myLoad&thnks=1">
	</cfif>
</cfif>
<cfscript>
function stripHTML(str) {
    // remove the whole tag and its content
    var list = "style,script,noscript";
    for (var tag in list){
        str = reReplaceNoCase(str, "<s*(#tag#)[^>]*?>(.*?)","","all");
    }

    str = reReplaceNoCase(str, "<.*?>","","all");
    //get partial html in front
    str = reReplaceNoCase(str, "^.*?>","");
    //get partial html at end
    str = reReplaceNoCase(str, "<.*$","");

    str = ReplaceNoCase(str, "&nbsp;","","ALL");
    return trim(str);

}
</cfscript>
<cfoutput>
	<script language="javascript" type="text/javascript" src="../webroot/javascripts/plugins/ckeditor/ckeditor.js?ver=4.16.0"></script>
	<script  type="text/javascript">
		$(document).ready(function(){
			CKEDITOR.replace('f_description', {
				startupFocus : true
			});
		});
		
	</script>
	<style>
		##cke_f_description{
			margin-bottom: 10px;
		}
		##cke_1_bottom {
			display: none;
		}
		##cke_1_top{
			display: none;
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
        ##cke_1_contents{
			height: 450px !important;
		}
	</style>
    <cfif isdefined("errMsg")>
        <div id="message" class="msg-area-error">#errMsg#</div>
    </cfif>
    <div style="clear:left"></div>
	<h1>Create Support Ticket</h1>
	<div style="clear:left"></div>
	<div class="white-con-area" style="width: 100%;">
		<div class="white-top"></div>
	    <div class="white-mid" style="width: 100%;">
			<cfform name="frmLongShortMiles" enctype="multipart/form-data" method="post">
				<input type="hidden" name="comp_Name" id="comp_Name" value="#request.qCompanyName.COMPANYNAME#">
		       	<input type="hidden" name="companycode" id="companycode" value="#request.qCompanyName.companycode#">
		       	<input type="hidden" name="f_Name" id="f_Name" value="#request.qcurAgentdetails.name#">
				<input type="hidden" name="f_email" id="f_email" value="#request.qcurAgentdetails.EmailID#">
				<input type="hidden" name="f_phone" id="f_phone" value="#request.qcurAgentdetails.Telephone#">
				<div class="form-con" style="width: 695px;">
					<fieldset>
						<label style="width: 75px;font-size: 14px;">Description</label><span>(Press Control + V to paste screen shot)</span>
						<input  type="submit" name="feedback_buttn" onfocus="" class="bttn" value="Send" style="width:80px;margin-left: 545px;margin-top: -20px;" />
						<div class="clear"></div>
						<cftextarea name="f_description" id="f_description" ></cftextarea>
						<div class="clear"></div>
						<label style="width: 61px;">Attachment</label>  
						<input type="file" name="Attachment" />
						<div class="clear"></div>
						<input  type="submit" name="feedback_buttn" onfocus="" class="bttn" value="Send" style="width:80px;margin-left: 545px;" />
					</fieldset>
				</div>
				<div class="form-con" style="width: 260px;">
					<div style="float:right;">
						<div align="center" style="width:100%;position:relative;" >
							<img src="images/support.png" width="230px" border="0"><br>
							<span style="float:left;font-size:15px;color:##0c587d">�	<b>Feature Request</b></span><br>
							<span style="float:left;font-size:15px;color:##0c587d">�	<b>Make a Suggestion</b></span><br>
							<span style="float:left;font-size:15px;color:##0c587d">�	<b>Report a problem</b></span><br>
						</div>
					</div>
				</div>
	        	<div class="clear"></div>
				<div class="clear">&nbsp;</div>
	         	<div class="clear">&nbsp;</div>     
	   			<div class="clear"></div>
		 	</cfform>
		</div>
		<div class="white-bot"></div>
	</div>
</cfoutput>