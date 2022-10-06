<cfif not structKeyExists(url, "CompanyID") OR (structKeyExists(url, "CompanyID") AND ((len(trim(url.CompanyID)) AND not isValid("regex", url.CompanyID,'^[{]?[0-9a-fA-F]{8}-([0-9a-fA-F]{4}-){3}[0-9a-fA-F]{12}[}]?$')) OR NOT len(trim(url.CompanyID))))>
	<cfoutput>
		<h4>Page not found.</h4>
	</cfoutput>
	<cfabort>
</cfif>
<cfquery name="qSystemConfig" datasource="#trim(listFirst(cgi.SCRIPT_NAME,'/'))#">
	SELECT 
	S.BackgroundColor
	,C.CompanyName
	,S.companyLogoName
	,C.CompanyCode
	FROM Companies C
	INNER JOIN SystemConfig S ON C.CompanyID = S.CompanyID
	WHERE C.CompanyID = <cfqueryparam value="#url.CompanyID#" cfsqltype="cf_sql_varchar">
</cfquery>
<cfoutput>
	<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
	<html xmlns="http://www.w3.org/1999/xhtml">
		<head>
			<title>Load Manager TMS</title>
			<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
			<link rel="shortcut icon" href="../logofavicon.png">
			<script src="https://code.jquery.com/jquery-1.10.2.min.js"></script>
	    	<script src="https://code.jquery.com/ui/1.11.0/jquery-ui.min.js"></script>
			<link rel="stylesheet" href="https://code.jquery.com/ui/1.11.0/themes/smoothness/jquery-ui.css">

			<style type="text/css">
				h1{
					color: ##0a0a0a;
				    padding: 14px 0 10px 0;
				    margin: 0;
				    font-size: 20px;
				    font-weight: normal;
				}
				label{
					font-weight: bold;
					float: left;
				}
				input[type="text"]{
					float: left;
				    width: 104px;
				    height: 18px;
				    background: ##FFFFFF;
				    border: 1px solid ##b3b3b3;
				    padding: 2px 2px 0 2px;
				    margin: 0 6px 8px 0;
				    font-size: 11px;
				}
				input[type="submit"]{
					background: url(images/button-bg.gif) left top repeat-x;
					border: 1px solid ##b3b3b3;
				    width: 83px;
				    padding: 0px 10px 0 10px;
				    height: 20px;
				    font-size: 11px;
				    font-weight: bold;
				    line-height: 20px;
				    text-align: center;
				    margin: 0 0 0 40px;
				    cursor: pointer;
				    float: right;
				    margin-right: 25px;
				}
			</style>
		</head>
		<script type="text/javascript">
			function validatefrmOnBoard(){
				var DOTNumber = $('##DOTNumber').val();
				var MCNumber = $('##MCNumber').val();

				if(!$.trim(DOTNumber).length && !$.trim(MCNumber).length){
					alert('Please provide a DOTNumber or MCNumber.');
					$('##DOTNumber').focus();
					return false;
				}
			}
		</script>
		<body style="background-color: #qSystemConfig.BackgroundColor#;font: normal 11px/16px Arial, Helvetica, sans-serif;">
			<div style="text-align: center;">
				<img src="..\fileupload\img\#qSystemConfig.companyCode#\logo\#qSystemConfig.companyLogoName#" width="120px;"><br>
				<strong>#qSystemConfig.CompanyName#</strong>
			</div>
			<div style="margin-left: 15%;margin-right: 15%;">
				<h1>Enter Details</h1>
			</div>
			<form name="frmOnBoard" id="frmOnBoard" action="index.cfm?event=OnboardingLink:process&CompanyID=#url.CompanyID#" method="post" onsubmit="return validatefrmOnBoard();">
				<div style="margin-left: 15%;margin-right: 15%;background-color: ##fff;height: 30px;padding-top: 10px;padding-left: 10px;">
					<label style="width: 120px;"><i style="color:##448bc8">Please enter...</i> DOT ##</label>
					<input name="DOTNumber" type="text" maxlength="50" id="DOTNumber">
					<label style="width: 90px;text-align: right;padding-right: 10px;"><i style="color:##448bc8">...OR...</i> MC ##</label>
					<input name="MCNumber" type="text" maxlength="50" id="MCNumber">

					<input name="SaveContinue" type="submit" value="Continue>>" id="continue-btn" class="normal-bttn" >
				</div>
			</form>
		</body>
	</html>
</cfoutput>