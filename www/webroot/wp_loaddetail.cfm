<cfquery name="qgetLoad" datasource="weloadtrailers">
	SELECT LoadNumber,CustName,ContactPerson,Phone,Fax,ContactEmail FROM Loads
	WHERE LoadID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#url.LoadID#" null="#yesNoFormat(NOT len(url.LoadID))#">
</cfquery>
<cfoutput>
	<style>
		.iframeBackBtn{
			    background-color: ##EBE555;
			    font-size: 18px;
			    text-decoration: none;
			    color: ##151221!important;
			    border-width: 0px!important;
			    border-radius: 5px;
			    box-shadow: 6px 6px 18px 0px rgb(0 0 0 / 30%);
			    padding-top: 15px!important;
			    padding-right: 30px!important;
			    padding-bottom: 15px!important;
			    padding-left: 30px!important;
		}
		.iframeDelBtn{
			    background-color: ##dc3545;
			    font-size: 18px;
			    text-decoration: none;
			    color: ##151221!important;
			    border-width: 0px!important;
			    border-radius: 5px;
			    box-shadow: 6px 6px 18px 0px rgb(0 0 0 / 30%);
			    padding-top: 15px!important;
			    padding-right: 30px!important;
			    padding-bottom: 15px!important;
			    padding-left: 30px!important;
		}
	</style>

	
	<table class="loadTable" width="50%">
		<tr>
			<td colspan="2"><u>Pro## #qgetLoad.LoadNumber#</u></td>
		</tr>
		<tr>
			<td style="background-color: ##1c4689;color: ##fff;">Company Name</td>
			<td style="border: 1px solid ##c7c3c3;font-size: 12px;">#qgetLoad.CustName#</td>
		</tr>
		<tr>
			<td style="background-color: ##1c4689;color: ##fff;">Contact</td>
			<td style="border: 1px solid ##c7c3c3;font-size: 12px;">#qgetLoad.ContactPerson#</td>
		</tr>
		<tr>
			<td style="background-color: ##1c4689;color: ##fff;">Phone</td>
			<td style="border: 1px solid ##c7c3c3;font-size: 12px;">#qgetLoad.Phone#</td>
		</tr>
		<tr>
			<td style="background-color: ##1c4689;color: ##fff;">Fax</td>
			<td style="border: 1px solid ##c7c3c3;font-size: 12px;">#qgetLoad.Fax#</td>
		</tr>
		<tr>
			<td style="background-color: ##1c4689;color: ##fff;">Email</td>
			<td style="border: 1px solid ##c7c3c3;font-size: 12px;">#qgetLoad.ContactEmail#</td>
		</tr>
		<tr>
			<td colspan="2" align="right" style="padding-top: 20px;">
				<a class="iframeDelBtn" href="https://loadmanager.net/weloadtrailers/www/webroot/wp_loadlist.cfm?delId=#url.LoadID#" onclick="return confirm('Are you sure to delete this load?');">Delete</a>
				<a class="iframeBackBtn" href="https://loadmanager.net/weloadtrailers/www/webroot/wp_loadlist.cfm">Back</a>
			</td>
		</tr>
	</table>
</cfoutput>