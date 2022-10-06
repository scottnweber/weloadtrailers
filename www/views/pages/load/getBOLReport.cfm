<cfparam name="editid" default="0">
<cfoutput>
<cfif structkeyexists(url,"loadid") and (not structkeyexists(url,"print"))>
	<cfinvoke component="#variables.objloadGateway#" method="getAllLoads" loadid="#url.loadID#" stopNo="0" returnvariable="request.qLoads" /> 
    <cfinvoke component="#variables.objloadGateway#" method="GetShipperConsignee" loadid="#url.loadID#" loadtype=1 returnvariable="request.shipper" />
	<cfinvoke component="#variables.objloadGateway#" method="GetShipperConsignee" loadid="#url.loadID#" loadtype=2 returnvariable="request.consignee" />
	<cfinvoke component="#variables.objclassGateway#" method="getAllClasses" status="True" returnvariable="request.qClasses" />
	<cfinvoke component="#variables.objloadGateway#" method="GetBOLDetails" loadid="#url.loadid#" returnvariable="request.BolDetails">
	<cfinvoke component="#variables.objloadGateway#" method="getcurAgentMaildetails" returnvariable="request.qcurMailAgentdetails" employeID="#session.empid#" />
	<cfif request.qcurMailAgentdetails.recordcount gt 0 and (request.qcurMailAgentdetails.SmtpAddress eq "" or request.qcurMailAgentdetails.SmtpUsername eq "" or request.qcurMailAgentdetails.SmtpPort eq "" or request.qcurMailAgentdetails.SmtpPassword eq "" or request.qcurMailAgentdetails.SmtpPort eq 0)>
		<cfset mailsettings = "false">
	<cfelse>
		<cfset mailsettings = "true">
	</cfif>
	<cfset editid=loadID>
	<script  type="text/javascript">
		 //mailUrlToken will be used for passing urlToken
		var mailUrlToken = "#session.URLToken#"; 
		<cfif structkeyexists(url,"loadid") and len(trim(url.loadid)) gt 1>
		var mailLoadId = "#url.loadid#"; 
		</cfif>
		$(document).ready(function(){
			$('##bolReportImg').click(function(){
				if(!$('##save').data('allowmail')) {
					alert('You must setup your email address in your profile before you can email reports.');
				} else {
					var path = urlComponentPath+"loadgateway.cfc?method=AddBOLDetails";
    				var result ={dsn:'#application.dsn#'};
    				$.each($('##bolForm').serializeArray(), function() {
					    result[this.name] = this.value;
					});

	                $.ajax({
		                type: "Post",
		                url: path,
		                dataType: "json",
		                data: {
		                    frmstruct:JSON.stringify(result)
		                },
		                success: function(){
		               		
		                }
		            });
					BOLReportOnClick(mailLoadId,mailUrlToken);
				}
			});
			$('##shortBOLImg').click(function(){
				if(!$('##save').data('allowmail')) {
					alert('You must setup your email address in your profile before you can email reports.');
				} else {
					var path = urlComponentPath+"loadgateway.cfc?method=AddBOLDetails";
    				var result ={dsn:'#application.dsn#'};
    				$.each($('##bolForm').serializeArray(), function() {
					    result[this.name] = this.value;
					});

	                $.ajax({
		                type: "Post",
		                url: path,
		                dataType: "json",
		                data: {
		                    frmstruct:JSON.stringify(result)
		                },
		                success: function(){
		               		
		                }
		            });
					shortBOLOnClick(mailLoadId,mailUrlToken);
				}
			});
			<cfif request.qSystemSetupOptions.UseNonFeeAccOnBOL>
				$("##AccessorialsTable input").prop( "readonly", true );
			</cfif>
		});

		function validateBOLFrm(){
			var CODAmount = $('##CODAmount').val();
			var DeclaredValue = $('##DeclaredValue').val();

			CODAmount = CODAmount.replace("$","");
            CODAmount = CODAmount.replace(/,/g,"");
            if(isNaN(CODAmount) || !CODAmount.length){
            	alert("Invalid COD Amount.");
            	$('##CODAmount').focus();
            	return false;
            }

            DeclaredValue = DeclaredValue.replace("$","");
            DeclaredValue = DeclaredValue.replace(/,/g,"");
            
            if(isNaN(DeclaredValue) || !DeclaredValue.length){
            	alert("Invalid Declared Value.");
            	$('##DeclaredValue').focus();
            	return false;
            }
			
		}
	</script>
	<style>
		<cfif request.qSystemSetupOptions.UseNonFeeAccOnBOL>
			##AccessorialsTable input{
				background-color: ##F5F5F5;
				opacity: 0.8;
			}
			##AccessorialsTable select{
				background-color: ##F5F5F5;
				opacity: 0.8;
				pointer-events: none;
			}
		</cfif>
	</style>
	<cfform  id="bolForm" action="index.cfm?event=BOLReport:process&#session.URLToken#" method="post" preserveData="yes" target="_blank" onsubmit="return validateBOLFrm()">
		<input type="hidden" name="loadid" value="#url.loadid#">
		<input type="hidden" name="companyid" value="#session.companyid#">
	  	<div class="bop_report">
            <div class="bop_form">
					<fieldset class="bop_form">
		            <label>Pickup</label>
					<select name="shipper">
						<cfloop query="request.shipper">
							<option value="#request.shipper.customerID#" <cfif request.shipper.forbol eq 1>selected</cfif>>#request.shipper.custname#</option>
						</cfloop>
					</select>
					<div class="clear"></div>
		            <label>Delivery</label>
					<select name="consignee">
						 <cfloop query="request.consignee">
							<option value="#request.consignee.customerID#" <cfif request.consignee.forbol eq 1>selected</cfif>>#request.consignee.custname#</option>
						</cfloop>
					</select>
					<div class="clear"></div>
		            <label>Emergency Response Number</label>
					<input name="EmergencyResponseNo" type="text" align="left" value="#request.qLoads.emergencyresponseno#" style="text-align:right"/>
					<div class="clear"></div>
		            <label>COD Amt</label>
		            <cfset newNum = #NumberFormat(request.qLoads.codamt,".00")#>
		            <cfset Codamount = #DollarFormat(newNum)#>
		            <cfset Amount = replace(Codamount, ",", "", "all")> 
					<input name="CODAmount" id="CODAmount" type="text" align="left" value="#Amount#" style="text-align:right"/>
					<div class="clear"></div>
		            <label>COD Fee</label>
					<select name="CODFee">
						<option valye="Pre-Paid" <cfif request.qLoads.codfee eq 'Pre-Paid'>selected</cfif>>Pre-Paid</option>
						<option valye="Collect" <cfif request.qLoads.codfee eq 'Collect'>selected</cfif>>Collect</option>
					</select> 
					<div class="clear"></div>
		            <label>Declared Value</label>
		           	<cfset DecValue =#NumberFormat(request.qLoads.declaredvalue,".00")# >
		           	<cfset DeclareValue = #DollarFormat(DecValue)#>
		           	<cfset Declare = replace(DeclareValue, ",", "", "all")>
					<input name="DeclaredValue" id="DeclaredValue" type="text" align="right" value="#Declare#" style="text-align:right"/>	
                    </div>
                    <div class="bop_for_ryt">
                        <table id="AccessorialsTable" width="100%" class="noh" border="0" cellspacing="0" cellpadding="0">
							<thead>
								<tr>
								  <th width="5" align="left" valign="top"><img src="images/top-left.gif" alt="" width="5" height="23" /></th>
								  <th width="212" align="center" class="head-bg">Description</th>
								  <th width="257" align="center" class="head-bg">Hazmat</th>
								  <th width="337" align="center" class="head-bg">Class</th>
								  <th width="264" align="center" class="head-bg">Piece(s)</th>
								  <th width="239"  align="center" class="head-bg1">Wt(lbs)</th>
								  <th width="5" align="right" valign="top"><img src="images/top-right.gif" alt="" width="5" height="23" /></th>
								</tr>
							</thead>
							<tbody>
								<cfif (isdefined("url.loadid") and len(trim(url.loadid)) gt 1 and request.BolDetails.recordcount neq 0 )>
								  <cfloop query="request.BolDetails">
									<tr <cfif request.BolDetails.currentRow mod 2 eq 0>bgcolor="##FFFFFF"<cfelse>  bgcolor="##f7f7f7"</cfif> >
									  <td height="20" class="lft-bg">&nbsp;</td>
									  <td class="lft-bg2" align="center"><input name="description#request.BolDetails.currentRow#"  id="description#request.BolDetails.currentRow#" type="text"  value="#replace(request.BolDetails.description,'"','&quot;','all')#"/></td>
									  <td class="normaltd" align="center"><input name="hazmat#request.BolDetails.currentRow#" class="q-textbox1" type="text" value="#request.BolDetails.hazmat#"/></td>
									  <td class="normaltd" align="center">
										  <select name="class#request.BolDetails.currentRow#" class="t-select1" style="text-align:right;" >
										  <option value=""></option> 
										  <cfloop query="request.qClasses">
											<option style="text-align:right" value="#request.qClasses.classId#" <cfif request.qClasses.classId eq request.BolDetails.classId>selected</cfif>>#request.qClasses.className#</option>
										  </cfloop>
										</select> </td>
									  <td class="normaltd" align="center"><input name="pieces#request.BolDetails.currentRow#" id="pieces#request.BolDetails.currentRow#" class="q-textbox1" type="text" value="#request.BolDetails.qty#" style="text-align:right"/></td>
									  <td class="normaltd2" align="center"><input name="weight#request.BolDetails.currentRow#" id="weight#request.BolDetails.currentRow#" class="q-textbox1" type="text" value="#request.BolDetails.weight#" style="text-align:right"/></td>
									  <td class="normal-td3">&nbsp;</td>
									</tr>
								  </cfloop>
									
								  <cfif request.BolDetails.recordcount lt 5>
									<cfset remainCol=request.BolDetails.recordcount+1>
									<cfloop from ="#remainCol#" to="5" index="rowNum">
									  <tr <cfif rowNum mod 2 eq 0>bgcolor="##FFFFFF"<cfelse>  bgcolor="##f7f7f7"</cfif> >
									  <td height="20" class="lft-bg">&nbsp;</td>
									  <td class="lft-bg2" align="center" ><input name="description#rowNum#"  id="description#rowNum#" class="td-textbox1"  type="text" /></td>
									  <td class="normaltd" align="center"><input name="hazmat#rowNum#" class="q-textbox1" type="text" /></td>
									  <td class="normaltd" align="center">
										  <select name="class#rowNum#" class="t-select1"  >
										  <option value=""></option>
										  <cfloop query="request.qClasses">
											<option style="text-align:right" value="#request.qClasses.classId#">#request.qClasses.className#</option>
										  </cfloop>
										</select> </td>
									  <td class="normaltd" align="center"><input name="pieces#rowNum#" id="pieces#rowNum#" class="q-textbox1" type="text" style="text-align:right"/></td>
									  <td class="normaltd2" align="center"><input name="weight#rowNum#" id="weight#rowNum#" class="q-textbox1" type="text" style="text-align:right"/></td>
									  <td class="normal-td3">&nbsp;</td>
									</tr>
									</cfloop>
								  </cfif> 
								  <cfelse>
								  <cfloop from ="1" to="5" index="rowNum">
									<tr <cfif rowNum mod 2 eq 0>bgcolor="##FFFFFF"<cfelse>  bgcolor="##f7f7f7"</cfif> >
									  <td height="20" class="lft-bg">&nbsp;</td>
									  <td class="lft-bg2" align="center"><input name="description#rowNum#"  class="td-textbox1" id="description#rowNum#" type="text" /></td>
									  <td class="normaltd" align="center"><input name="hazmat#rowNum#" class="q-textbox1" type="text"   /></td>
									  <td class="normaltd" align="center">
										  <select name="class#rowNum#" class="t-select1" >
										  <option value="" style="text-align:right"></option>
										  <cfloop query="request.qClasses">
											<option value="#request.qClasses.classId#" style="text-align:right">#request.qClasses.className#</option>
										  </cfloop>
										</select> </td>
									  <td class="normaltd" align="center"><input name="pieces#rowNum#" id="pieces#rowNum#" class="q-textbox1" type="text" style="text-align:right" /></td>
									  <td class="normaltd2" align="center"><input name="weight#rowNum#" id="weight#rowNum#" class="q-textbox1" type="text" style="text-align:right" /></td>
									  <td class="normal-td3">&nbsp;</td>
									</tr>
								  </cfloop>
								</cfif>
							</tbody>
							<tfoot>
								<tr>
								  <td width="5" align="left" ><img src="images/left-bot.gif" alt="" width="5" height="23" /></td>
								  <td colspan="5" align="left"  class="footer-bg"></td>
								  <td width="5" align="right" ><img src="images/right-bot.gif" alt="" width="5" height="23" /></td>
								</tr>
							</tfoot>
						</table>
                    </div>
                    <div class="clear"></div>
                    <div class="bop_form" style="width:100%">
			            <label>From Name</label>
			            <input name="BOLFromName" type="text" value="#request.qLoads.BOLFromName#"/>	
			            <label style="width:50px">TEL</label>
			            <input name="BOLFromTel" type="text" value="#request.qLoads.BOLFromTel#"/> 
			            <label style="width:50px">Email</label>
			            <input name="BOLFromEmail" type="text" value="#request.qLoads.BOLFromEmail#"/> 
                    </div>
                    <div class="clear"></div>
                    <div class="bop_form" style="width:100%">
			            <label>RE Name</label>
			            <input name="BOLREName" type="text" value="#request.qLoads.BOLREName#"/>	
			            <label style="width:50px">Po##</label>
			            <input name="BOLREPO" type="text" value="#request.qLoads.BOLREPO#"/> 
                    </div>
                    <div class="bop_form1">
						<div class="left">
							<label>Notes</label>
                            <textarea name="Notes">#request.qLoads.notes#</textarea>
                        </div>
                    </fieldset>
					<fieldset class="btn">
					<table>
						<tr>
							<td>
								<div style="cursor:pointer;width:27px;background-color: ##bfbcbc;float: left;margin: 5px 0;text-align: center;"><img id="bolReportImg" style="vertical-align:bottom;" src="images/black_mail.png" data-action="view" ></div>
								<input id="save" name="submit" type="submit" class="green-btn tooltip" value="Print BOL"  <cfif mailsettings>data-allowmail="true"<cfelse>data-allowmail="false"</cfif>/> 
							</td>
							<td>
								<div style="cursor:pointer;width:27px;background-color: ##bfbcbc;float: left;margin: 5px 0;text-align: center;"><img id="shortBOLImg" style="vertical-align:bottom;" src="images/black_mail.png" data-action="view" ></div>
								<input name="submit" type="submit" class="green-btn tooltip" value="Straight BOL" <cfif mailsettings>data-allowmail="true"<cfelse>data-allowmail="false"</cfif>>
							</td>
						</tr>
					</table>
						<input id="actionReport" name="actionReport" type="hidden" class="green-btn" value="view"/>
					</fieldset>
                </div>
     		</div>
			<div class="clear"></div>
 	 	</div>
  		</div>	
	</cfform>
<cfelse>
	Unable to generate the report. Please specify the load Number or Load ID	
</cfif>
</cfoutput>

	