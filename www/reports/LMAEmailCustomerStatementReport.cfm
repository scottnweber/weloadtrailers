<cfparam name="variables.MailSend" default="0">
<cfinvoke component="#variables.objloadGateway#" method="getcurAgentMaildetails" returnvariable="request.qcurAgentdetails" employeID="#session.empid#" />
<cfset SmtpAddress=request.qcurAgentdetails.SmtpAddress>
<cfset SmtpUsername=request.qcurAgentdetails.SmtpUsername>
<cfset SmtpPort=request.qcurAgentdetails.SmtpPort>
<cfset SmtpPassword=request.qcurAgentdetails.SmtpPassword>
<cfset FA_SSL=request.qcurAgentdetails.useSSL>
<cfset FA_TLS=request.qcurAgentdetails.useTLS>
<cfset MailFrom=request.qcurAgentdetails.EmailID>
<cfset emailSignature = request.qcurAgentdetails.emailSignature>
<cfif IsDefined("form.sendEmail")>
	<cfset local.dsn = trim(listFirst(cgi.SCRIPT_NAME,'/'))>
	<cfquery name="qGetSystemConfig" datasource="#local.dsn#">
	    SELECT
        (SELECT companyCode FROM SystemConfig  WHERE CompanyID = <cfqueryparam value="#session.companyid#" cfsqltype="cf_sql_varchar">) AS companyCode,
        (SELECT companyName FROM SystemConfig  WHERE CompanyID = <cfqueryparam value="#session.companyid#" cfsqltype="cf_sql_varchar">) AS companyName,
        (SELECT companyLogoName FROM SystemConfig  WHERE CompanyID =<cfqueryparam value="#session.companyid#" cfsqltype="cf_sql_varchar">) AS companyLogoName,
        Address,
        City,
        State,
        ZipCode,
        Phone,
        fax,
        email
        FROM Companies
        WHERE CompanyID = <cfqueryparam value="#session.companyid#" cfsqltype="cf_sql_varchar">
	</cfquery>

	<cfquery name="qCustStmt" datasource="#local.dsn#">
        SELECT 
        C.CustomerID,
        C.CustomerName,
        C.CustomerCode,
        C.Location,
        C.City,
        C.statecode,
        C.Zipcode,
        C.PhoneNo,
        C.Fax,
        C.Email,
        C.ContactPerson,
        C.FactoringID,
        C.RemitName,
        C.RemitAddress,
        C.RemitCity,
        C.RemitState,
        C.RemitZipcode,
        C.RemitContact,
        C.RemitPhone,
        C.RemitFax,
        ART.TRANS_NUMBER,
        ART.Date,
        ART.Description,
        CASE WHEN typetrans = 'P' THEN -1*(ISNULL(applied,0)+ISNULL(discount,0)) ELSE ART.Total END AS Total,
        CASE WHEN typetrans = 'P' THEN 0 ELSE ART.Balance END AS Balance

        ,CASE WHEN (DATEDIFF(day,DATEADD(DD,ISNULL(ST.[Terms Days],0),ART.date),getdate())) <=30 THEN  CASE WHEN typetrans = 'P' THEN 0 ELSE ART.Balance END ELSE 0 END AS Below30 
        ,CASE WHEN (DATEDIFF(day,DATEADD(DD,ISNULL(ST.[Terms Days],0),ART.date),getdate())) BETWEEN 31 AND 60 THEN  CASE WHEN typetrans = 'P' THEN 0 ELSE ART.Balance END ELSE 0 END AS Over30 
        ,CASE WHEN (DATEDIFF(day,DATEADD(DD,ISNULL(ST.[Terms Days],0),ART.date),getdate())) BETWEEN 61 AND 90 THEN  CASE WHEN typetrans = 'P' THEN 0 ELSE ART.Balance END ELSE 0 END AS Over60
        ,CASE WHEN (DATEDIFF(day,DATEADD(DD,ISNULL(ST.[Terms Days],0),ART.date),getdate())) >=91 THEN  CASE WHEN typetrans = 'P' THEN 0 ELSE ART.Balance END ELSE 0 END AS Over90 
        ,typetrans
        ,(ISNULL(ARPT.Applie,0)+ISNULL(ARPT.Discou,0)) AS AmountPaid
        ,ARPT.InvoicNumber AS CheckInvoiceNo
        FROM [LMA Accounts Receivable Transactions] ART
        LEFT JOIN [LMA Accounts Receivable Payment Detail] ARPT ON ARPT.CheckNumber = ART.TRANS_NUMBER AND ART.typetrans = 'P' AND ARPT.CompanyID = ART.CompanyID
        INNER JOIN CUSTOMERS C ON C.CustomerID = ART.CustomerID
        LEFT JOIN [LMA System Terms] ST ON ST.ID = ART.term_number  AND ST.CompanyID = ART.CompanyID
		WHERE (CASE WHEN typetrans = 'P' THEN 0 ELSE ART.Balance END <> 0 OR (CASE WHEN typetrans = 'P' THEN 0 ELSE ART.Balance END = 0 AND DATEDIFF(month, ART.Date, <cfqueryparam value="#url.statementdate#" cfsqltype="cf_sql_date">) = 0))
		AND ART.CompanyID = <cfqueryparam value="#session.companyid#" cfsqltype="cf_sql_varchar">
        AND C.CustomerName >= <cfqueryparam value="#url.customerLimitFrom#" cfsqltype="cf_sql_varchar">
        AND C.CustomerName <= <cfqueryparam value="#url.customerLimitTo#" cfsqltype="cf_sql_varchar">
        ORDER BY C.CustomerName,typetrans,TRANS_NUMBER
	</cfquery>

	<cfloop query="qCustStmt" group="CustomerID">
		<cfif len(trim(qCustStmt.Email))>
			<cfset fileName = "Customer Statement Report Date-#DateFormat(Now(),'mm.dd.yyyy')#.pdf">
			<cfdocument format="PDF" name="CustomerStatement">
				<cfoutput>
					<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
				    <HTML xmlns="http://www.w3.org/1999/xhtml">
				        <HEAD>
				            <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
				            <TITLE>Load Manager TMS</TITLE>
				        </HEAD> 
				        <BODY style="font-family: 'Arial Narrow';">
				        	<table width="100%" style='font-family: "Arial";' cellspacing="0">
	                			<tr>
	                				<img src="../fileupload/img/#qGetSystemConfig.companycode#/logo/#qGetSystemConfig.companyLogoName#" width="90"></td>
	                				<td width="30%" valign="top">
	                					<b style="font-size: 13px;">#qGetSystemConfig.CompanyName#</b><br>
	                					<b style="font-size: 12px;">#qGetSystemConfig.Address#</b><br>
	                					<b style="font-size: 12px;">#qGetSystemConfig.City#, #qGetSystemConfig.state# #qGetSystemConfig.zipcode#</b><br>
	                					<div style="border-bottom: 1px solid black;margin-bottom: 5px;"></div>
	                					<span style="font-size: 11px;"><b>Phone: </b>#qGetSystemConfig.Phone#</span><br>
	                					<span style="font-size: 11px;"><b>Fax: </b>#qGetSystemConfig.fax#</span><br>
	                					<span style="font-size: 11px;"><b>E-Mail: </b>#qGetSystemConfig.Email#</span>
	                				</td>
	                				<td  width="50%" valign="top">
	                					<table width="100%" cellspacing="0">
	                						<tr>
	                							<td colspan="3" style="background-color:##000;" align="center">
	                								<h2 style="color:##fff;">Statement of Account</h2>
	                							</td>
	                						</tr>
	                						<tr><td colspan="3">&nbsp;</td></tr>
	                						<tr>
	                							<td width="20%">&nbsp;</td>
	                							<td width="30%" style="border: 1px solid black;background-color: ##808080;color:##fff" align="right"><b style="font-size: 14px;">Date: </b></td>
	                							<td width="50%" align="center" style="border-top: 1px solid black;border-right: 1px solid black;border-bottom: 1px solid black;"><b style="font-size: 14px;">#url.statementDate#</b></td>
	                						</tr>
	                						<tr><td colspan="3">&nbsp;</td></tr>
	                						<tr>
	                							<td width="20%">&nbsp;</td>
	                							<td width="30%" style="border: 1px solid black;background-color: ##808080;color:##fff" align="right"><b style="font-size: 14px;">Account ##: </b></td>
	                							<td width="50%" align="center" style="border-top: 1px solid black;border-right: 1px solid black;border-bottom: 1px solid black;"><b style="font-size: 14px;">#qCustStmt.CustomerCode#</b></td>
	                						</tr>
	                					</table>
	                				</td>
	                			</tr>
	                		</table>
	                		<table width="100%" style='font-family: "Arial";margin-top: 20px;' cellspacing="0">
	                			<tr>
	                				<td width="45%" align="center" style="background-color: ##000;color:##fff"><b style="font-size: 14px;">BILL TO:</b></td>
	                				<td width="10%"></td>
	                				<td width="45%" align="center" style="background-color: ##000;color:##fff"><b style="font-size: 14px;">REMIT TO:</b></td>
	                			</tr>
	                			<tr>
	                				<td width="45%" style="padding-left: 10px;padding-top: 5px;font-size: 14px;" valign="top">
	                					#qCustStmt.CustomerName#<br>
	                					#qCustStmt.location#<br>
	                					#qCustStmt.city#, #qCustStmt.statecode# #qCustStmt.zipcode#<br><br>
	                					<b>Contact: </b>#qCustStmt.contactperson#<br>
	                					<span style="font-size: 11px;"><b>Phone ##: </b>#qCustStmt.phoneno#<b style="margin-left: 20px;">Fax: </b>#qCustStmt.fax#</span>

	                				</td>
	                				<td width="10%"></td>
	                				<td width="45%" style="padding-left: 10px;padding-top: 5px;font-size: 14px;"  valign="top">
	                                    <cfif len(trim(qCustStmt.FactoringID))>
	                    					#qCustStmt.RemitName#<br>
	                    					#qCustStmt.RemitAddress#<br>
	                    					#qCustStmt.RemitCity#, #qCustStmt.RemitState# #qCustStmt.RemitZipcode#<br>
	                                        <cfif len(trim(qCustStmt.RemitContact))>
	                                            <br>
	                                            <b>Contact: </b>#qCustStmt.RemitContact#<br>
	                                            <span style="font-size: 11px;"><b>Phone ##: </b>#qCustStmt.Remitphone#<b style="margin-left: 20px;">Fax: </b>#qCustStmt.Remitfax#</span>
	                                        </cfif>
	                                    <cfelse>
	                                        #qCustStmt.CustomerName#<br>
	                                        #qCustStmt.location#<br>
	                                        #qCustStmt.city#, #qCustStmt.statecode# #qCustStmt.zipcode#<br><br>
	                                        <b>Contact: </b>#qCustStmt.contactperson#<br>
	                                        <span style="font-size: 11px;"><b>Phone ##: </b>#qCustStmt.phoneno#<b style="margin-left: 20px;">Fax: </b>#qCustStmt.fax#</span>
	                                    </cfif>
	                				</td>
	                			</tr>
	                		</table>
	                        <table width="100%" style='font-family: "Arial";margin-top: 10px;' cellspacing="0">
	                            <thead>
	                                <tr>
	                                    <th style="border-top: 1px solid black;border-left: 1px solid black;background-color: ##808080;color:##fff">Reference ##</th>
	                                    <th style="border-top: 1px solid black;border-left: 1px solid black;background-color: ##808080;color:##fff">Date</th>
	                                    <th style="border-top: 1px solid black;border-left: 1px solid black;background-color: ##808080;color:##fff">Description/PO ##</th>
	                                    <th style="border-top: 1px solid black;border-left: 1px solid black;background-color: ##808080;color:##fff">Amount</th>
	                                    <th style="border-top: 1px solid black;border-left: 1px solid black;background-color: ##808080;color:##fff">Balance</th>
	                                    <th style="border-top: 1px solid black;border-left: 1px solid black;border-right: 1px solid black;background-color: ##808080;color:##fff">Cum. Balance</th>
	                                </tr>
	                            </thead>
	                            <tbody style="font-size: 13px;">
	                                <cfset local.cumBal = 0>
	                                <cfset local.Below30Total = 0>
	                                <cfset local.Over30Total = 0>
	                                <cfset local.Over60Total = 0>
	                                <cfset local.Over90Total = 0>
	                                <cfset local.TotalAmountDue = 0>
	                                
	                                <cfloop group="TRANS_NUMBER">

	                                    <cfset local.cumBal = local.cumBal + qCustStmt.balance>
	                                    <cfset local.Below30Total = local.Below30Total + qCustStmt.Below30>
	                                    <cfset local.Over30Total = local.Over30Total + qCustStmt.Over30>
	                                    <cfset local.Over60Total = local.Over60Total + qCustStmt.Over60>
	                                    <cfset local.Over90Total = local.Over90Total + qCustStmt.Over90>
	                                    <cfset local.TotalAmountDue = local.TotalAmountDue + qCustStmt.balance>
	                                    <tr>
	                                        <td align="right" style="padding-right: 5px;border-bottom: inset 1px ##808080;"><b>#qCustStmt.TRANS_NUMBER#</b></td>
	                                        <td style="padding-right: 5px;padding-left: 5px;border-bottom: inset 1px ##808080;">#DateFormat(qCustStmt.date,"mm/dd/yyyy")#</td>
	                                        <td style="border-bottom: inset 1px ##808080;">#qCustStmt.Description#</td>
	                                        <td style="border-bottom: inset 1px ##808080;padding-right: 5px;" align="right">#DollarFormat(qCustStmt.total)#</td>
	                                        <td style="border-bottom: inset 1px ##808080;padding-right: 5px;" align="right"><b>#DollarFormat(qCustStmt.balance)#</b></td>
	                                        <td style="border-bottom: inset 1px ##808080;padding-right: 5px;" align="right">#DollarFormat(local.cumBal)#</td>
	                                    </tr>
	                                    <cfif typetrans eq 'p'>
	                                        <cfloop group="CheckInvoiceNo">
	                                            <tr>
	                                                <td colspan="2"></td>
	                                                <td style="font-size: 11px;padding-bottom: 1px;"><i>Inv## #qCustStmt.CheckInvoiceNo#</i></td>
	                                                <td style="font-size: 11px;" align="right"><i>#DollarFormat(qCustStmt.AmountPaid)#</i></td>
	                                                <td colspan="2"></td>
	                                            </tr>
	                                        </cfloop>
	                                    </cfif>
	                                </cfloop>
	                            </tbody>
	                        </table>
	                        <cfif structKeyExists(url, "comment") and len(trim(url.comment))>
	                            <table width="100%" style='font-family: "Arial";margin-top: 10px;font-size: 13px;' cellspacing="0">
	                                <tr>
	                                    <td>#url.comment#</td>
	                                </tr>
	                            </table>
	                        </cfif>
                            <table width="100%" style='font-family: "Arial";' cellspacing="0">
                                <thead>
                                    <tr>
                                        <th style="background-color: ##000;color:##fff"><b style="font-size: 14px;"><b>1-30</b></th>
                                        <th style="background-color: ##000;color:##fff"><b style="font-size: 14px;"><b>31-60</b></th>
                                        <th style="background-color: ##000;color:##fff"><b style="font-size: 14px;"><b>61-90</b></th>
                                        <th style="background-color: ##000;color:##fff"><b style="font-size: 14px;"><b>90+</b></th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <tr>
                                        <td width="25%" align="center" style="border-left: 1px solid black;border-bottom: 1px solid black;">#DollarFormat(local.Below30Total)#</td>
                                        <td width="25%" align="center" style="border-left: 1px solid black;border-bottom: 1px solid black;">#DollarFormat(local.Over30Total)#</td>
                                        <td width="25%" align="center" style="border-left: 1px solid black;border-bottom: 1px solid black;">#DollarFormat(local.Over60Total)#</td>
                                        <td width="25%" align="center" style="border-left: 1px solid black;border-bottom: 1px solid black;border-right: 1px solid black;">#DollarFormat(local.Over90Total)#</td>
                                    </tr>
                                    <tr>
                                        <td colspan="4"></td>
                                    </tr>
                                    <tr>
                                        <td colspan="2"></td>
                                        <td style="background-color: ##000;color:##fff" align="right"><b>Total Amount Due: </b></td>
                                        <td style="border-top: 1px solid black;border-right: 1px solid black;border-bottom: 1px solid black;padding-right: 5px;" align="right"><b>#DollarFormat(local.TotalAmountDue)#</b></td>
                                    </tr>
                                </tbody>
                            </table>
	                        <cfdocumentitem type = "footer">
	                            <table width="100%" style="font-family: 'Arial Narrow';font-size: 12px;margin-top: -10px;" cellspacing="0" cellpadding="0" style="border-top: solid 1px;">
	                                <tr>
	                                    <td>#DateTimeFormat(now(),"mmm dd, yyyy, hh:nn:ss tt")#</td>
	                                    <td align="right">Page #cfdocument.CURRENTPAGENUMBER# of #cfdocument.TOTALPAGECOUNT#</td>
	                                </tr>
	                            </table>
	                        </cfdocumentitem> 
				        </BODY>
				</cfoutput>
			</cfdocument>

			<cfmail from='"#SmtpUsername#" <#MailFrom#>' subject="#form.Subject#" to="#qCustStmt.Email#"  type="text/plain" server="#SmtpAddress#" username="#SmtpUsername#" password="#SmtpPassword#" port="#SmtpPort#" usessl="#FA_SSL#" usetls="#FA_TLS#" >
				#form.body#
				<cfmailparam file="#fileName#.pdf" type="application/pdf" content="#CustomerStatement#"/>
			</cfmail>

			<cfquery name="inslog" datasource="#local.dsn#">
				INSERT INTO [dbo].[EmailLogs]
		           ([loadID]
		           ,[date]
		           ,[subject]
		           ,[emailBody]
		           ,[reportType]
		           ,[createDate]
		           ,[fromAddress]
		           ,[toAddress])
		     VALUES
		           ('n/a'
		           ,<cfqueryparam value="#url.statementdate#" cfsqltype="cf_sql_date">
		           ,<cfqueryparam value="#form.Subject#" cfsqltype="cf_sql_varchar">
		           ,<cfqueryparam value="#form.body#" cfsqltype="cf_sql_varchar">
		           ,'CustomerStatement'
		           ,getdate()
		           ,<cfqueryparam value="#SmtpUsername#" cfsqltype="cf_sql_varchar">
		           ,<cfqueryparam value="#qCustStmt.Email#" cfsqltype="cf_sql_varchar">)
			</cfquery>
		</cfif>
	</cfloop>
	<cfset variables.MailSend = 1>
</cfif>
<cfoutput>
	<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
	<html>
	<head>
		<meta http-equiv="X-UA-Compatible" content="IE=edge" />
		<meta http-equiv="X-UA-Compatible" content="IE=8" >
		<script language="javascript" type="text/javascript" src="https://code.jquery.com/jquery-1.6.2.min.js"></script>	

		<script language="javascript" type="text/javascript" src="../webroot/javascripts/plugins/ckeditor/ckeditor.js?ver=4.16.0"></script>	
		<link href="../webroot/styles/style.css" rel="stylesheet" type="text/css" />
		<style>
			.progress { position:relative; width:400px; border: 1px solid ##ddd; padding: 1px; border-radius: 3px; }
			.bar { background-image:url("../webroot/images/pbar-ani.gif"); width:0%; height:20px; border-radius: 3px; }
			.percent { position:absolute; display:inline-block; top:3px; left:48%; }
			
			input.alertbox{
				border-color:##dd0000;
			}
			ul.tabs{
				margin: 0;
				padding: 0px;
				list-style: none;
			}
			ul.tabs li{
				background: none;
				color: ##222;
				display: inline-block;
				padding: 10px 15px;
				cursor: pointer;
			}
			ul.tabs li.current{
				background: ##ededed;
				color: ##222;
			}
			.tab-content{
				display: none;
				background: ##ededed;
				padding: 15px;
			}
			.tab-content.current{
				display: inherit;
			}
			##cke_tbody{
				width:500px;
				float: left;
			}
			##cke_1_bottom {
				display: none;
			}
			##cke_1_contents{
				height: 250px !important;
			}
			##cke_1_top {
				display: none;
			}
		</style>
		<script type="text/javascript">
			<cfif variables.MailSend EQ 1>
				$(document).ready(function(){
						alert('Customer statements are sent successfully.');
						window.close();
				})
			</cfif>
		</script> 
	</head>
	<body>
		<p>
			<div class="white-mid" style=" border-top: 5px solid rgb(130, 187, 239);width: 100%;">
				<div class="form-con" style="width:auto;">			
					<div style="color:##000000;font-size:14px;font-weight:bold;margin-bottom:20px;margin-top:10px;">
						Email Customer Statement
					</div>
					<div class="clear"></div>			
					<div id="tab-1" class="tab-content current">
						<form action="index.cfm?event=MailCustomerStatement&customerLimitFrom=#URLEncodedFormat(url.customerLimitFrom)#&customerLimitTo=#URLEncodedFormat(url.customerLimitTo)#&statementDate=#url.statementDate#&Comment=#url.Comment#&#session.URLToken#" method="POST" style="margin-top: 10px;">
							<fieldset>
								<label style="margin-top: 3px;">Subject:</label>
								<input style="width:500px;" type="Text" name="Subject" class="mid-textbox-1" id="Subject" value="Load Manager - Customer Statement #url.statementdate#">
								<div class="clear"></div>
								<label style="margin-top: 3px;">Message:</label>
								<textarea style="width:500px;height:180px;" class="addressChange" rows="" name="body" id="tbody" cols="">#emailSignature#</textarea>
								<div class="clear"></div>
								<div style="width:auto;float: right;">
									<input id="sendEmail" type = "Submit" name = "sendEmail" value="Send">
									<b class="loading" style="display:none;">Sending mails.Please wait.</b><br><img src="../webroot/images/loadDelLoader.gif" class="loading" style="display:none;">
								</div>
							</fieldset>
						</form> 
					</div>
				</div>
			</div>
			<div class="white-mid" style="width:auto;">
				<div class="form-con" style="bottom: 0px; position: absolute; background-color: rgb(130, 187, 239); width: 100%; padding: 2px 5px;">	
				</div>
			</div>
		</p> 
		<div class="clear"></div>	
	</body>  
	<script type="text/javascript">
		$(document).ready(function(){
			
			$('##sendEmail').click(function(){
				$('##sendEmail').hide();
				$('.loading').show();
			})

			$('ul.tabs li').click(function(){
				var tab_id = $(this).attr('data-tab');

				$('ul.tabs li').removeClass('current');
				$('.tab-content').removeClass('current');

				$(this).addClass('current');
				$("##"+tab_id).addClass('current');
			})
			CKEDITOR.replace('tbody', {
		} );

		});
		function countCharacters(){ 
			$("##charcount").text($("##tab-2 ##body").val().length);		
		}

	</script>
	</html>
</cfoutput>