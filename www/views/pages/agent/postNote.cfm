<cfoutput>
<cfquery name="qGetNotes" datasource="#Application.dsn#">
	<cfif structKeyExists(session, "iscustomer") AND session.iscustomer EQ 1>
		SELECT Notes FROM Customers WHERE CustomerID = <cfqueryparam value="#session.CustomerID#" cfsqltype="cf_sql_varchar">
	<cfelse>
		SELECT Notes FROM Employees WHERE EmployeeID = <cfqueryparam value="#session.EmpID#" cfsqltype="cf_sql_varchar">
	</cfif>
</cfquery>
<cfif IsDefined("form.submit")>
	<cfif structKeyExists(session, "iscustomer") AND session.iscustomer EQ 1>
		<cfinvoke component="#variables.objagentGateway#" method="updateCustomerNotes" CustomerID="#session.CustomerID#" Notes="#form.Notes#" CompanyID="#session.CompanyID#" dsn="#application.dsn#" returnvariable="ret" />
	<cfelse>
		<cfinvoke component="#variables.objagentGateway#" method="updateNotes" EmployeeID="#session.EmpID#" Notes="#form.Notes#" CompanyID="#session.CompanyID#" dsn="#application.dsn#" returnvariable="ret" />
	</cfif>
</cfif>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
	<head>
		<meta http-equiv="X-UA-Compatible" content="IE=edge" />
		<meta http-equiv="X-UA-Compatible" content="IE=8" >
		<link rel="stylesheet" href="https://code.jquery.com/ui/1.11.0/themes/smoothness/jquery-ui.css">
		<script src="https://code.jquery.com/jquery-1.10.2.min.js"></script>
		<script src="https://code.jquery.com/ui/1.11.0/jquery-ui.min.js"></script>
		<script language="javascript" type="text/javascript" src="../scripts/jquery.form.js"></script>	
		<link href="../webroot/styles/style.css" rel="stylesheet" type="text/css" />

		<script type="text/javascript">
			function saveNotes(){
				var str = $("##notes").val();
		    	$.ajax({
		    		type: "Post",
					url: "../gateways/agentgateway.cfc?method=update<cfif structKeyExists(session, "iscustomer") AND session.iscustomer EQ 1>Customer</cfif>Notes",
					data:{
						<cfif structKeyExists(session, "iscustomer") AND session.iscustomer EQ 1>
							CustomerID:'#session.CustomerID#',Notes:str,CompanyID:'#session.CompanyID#',dsn:'#application.dsn#'
						<cfelse>
							EmployeeID:'#session.EmpID#',Notes:str,CompanyID:'#session.CompanyID#',dsn:'#application.dsn#'
						</cfif>
					},
					success: function(res){
					}
		    	})
			}
			window.onbeforeunload = function (evt) 
			{	
				saveNotes();
			}
			$(document).ready(function(){
				<cfif IsDefined("form.submit")>
					<cfif ret EQ 0>
						alert('Something went wrong. Unable to save the note.');
					</cfif>
					window.close(); 
				</cfif>
				$('##notes').focus();

				var buffer = 2;

				setInterval(function(){ 
					buffer = buffer - 1;
					if(buffer == 0){
						saveNotes();
					}
				}, 2000);

				$('##notes').keydown(function(e){
					buffer = 2;
				});
			})
		</script>
		<style>
			
		</style>
	</head>
	<body>
		<div class="white-con-area" style="height: 40px;background-color: ##82bbef;width: 100%;padding-left: 10px;">
			<div style="float: left; width: 100%; min-height: 40px;">
                <h1 style="color:white;font-weight:bold;">Post Notes</h1>
            </div>
		</div>
		<div class="white-con-area" style="width: 100%;">
	        <div class="white-mid" style="min-height: 500px;width: 100%;">
				<form action = "" method="POST" >
					<input name="submit" type="submit" class="green-btn" value="Save" style="width:100px !important; float:right; position:relative; -webkit-background-size:contain; -moz-background-size:contain;  -o-background-size:contain; background-size:contain;color: ##599700;margin-top: -28px;margin-right: 10px;">	
					<textarea style="width:99%;height:450px;padding: 2px;" name="notes" id="notes">#qGetNotes.Notes#</textarea>
					<input name="submit" type="submit" class="green-btn" value="Save" style="width:100px !important; float:right; position:relative; -webkit-background-size:contain; -moz-background-size:contain;  -o-background-size:contain; background-size:contain;color: ##599700;margin-top: 10px;margin-right: 10px;">	
				</form>
	        </div>
	    </div>
	</body>
</html>
</cfoutput>