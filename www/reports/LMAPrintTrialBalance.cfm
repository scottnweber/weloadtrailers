<cfoutput>
    <cftry>
        <cfset local.dsn = trim(listFirst(cgi.SCRIPT_NAME,'/'))>
        <cfquery name="qLMASystemConfig" datasource="#local.dsn#">
            SELECT [Fiscal Year] FROM [LMA System Config]  WHERE CompanyID = <cfqueryparam value="#session.companyid#" cfsqltype="cf_sql_varchar">
        </cfquery>
        <cfset FiscalYear = qLMASystemConfig['Fiscal Year']>
        <cfset startYear = CreateDate(1990, DateFormat(FiscalYear,'mm'), 1)> 
        <cfset monthList = "">
        <cfloop index="i" from="#DateFormat(url.period,'yyyy-mm-dd')#" to="#DateFormat(startYear,'yyyy-mm-dd')#" step="#createTimeSpan(-30, 0, 0, 0)#">
            <cfset monthList = listAppend(monthList, dateFormat('#i#', "MMM"))>
            <cfif dateFormat('#i#', "MMM") EQ DateFormat(FiscalYear,"MMM")>
                <cfset periodYr = dateFormat('#i#','yyyy')>
                <cfset FiscYr = dateFormat(FiscalYear,'yyyy')>
                <cfset yrDiff = FiscYr - periodYr>
                <cfif yrDiff EQ 0>
                    <cfset yrVal = "CURRENT">
                <cfelse>
                    <cfset yrVal = "#yrDiff#YR">
                </cfif>
                <cfbreak>
            </cfif>
        </cfloop> 

        <cfif NOT Len(Trim(FiscalYear)) OR NOT listFind("0,1,2", yrDiff)>
            <cfset fileName = "Trial Balance Date-#DateFormat(Now(),'mm.dd.yyyy')#.pdf">
            <cfheader name="Content-Disposition" value="inline; filename=#fileName#">
            <cfdocument format="PDF" name="TrialBalance" margintop="1.5">
                <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
                <HTML xmlns="http://www.w3.org/1999/xhtml">
                    <HEAD>
                        <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
                        <TITLE>Load Manager TMS</TITLE>
                    </HEAD> 
                    <BODY style="font-family: 'Arial';">
                        Invalid Fiscal Year.
                    </BODY>
                </HTML>
            </cfdocument>
            <cfcontent variable="#toBinary(TrialBalance)#" type="application/pdf" />   
        <cfelse>
            <cfquery name="qGetSystemConfig" datasource="#local.dsn#">
                SELECT companyName FROM Companies WHERE CompanyID = <cfqueryparam value="#session.companyid#" cfsqltype="cf_sql_varchar">
            </cfquery>

            <cfquery name="qGetTrialBalance" datasource="#local.dsn#">
                SELECT GL_ACCT,Description,ISNULL(CREDIT_DEBIT,'C') AS CREDIT_DEBIT
                ,(OPEN_#yrVal#
                    <cfloop list="#monthList#" index="month">
                    + #month#_#yrVal#
                    </cfloop>
                ) AS Balance
                <cfif structKeyExists(url, "SummarizeDepts") AND url.SummarizeDepts>
                    ,LEFT(GL_ACCT,4) AS GL_ACCT_GRP
                </cfif>
                <cfif structKeyExists(url, "DeptFilter") AND url.DeptFilter>
                    ,(select Description from [LMA General Ledger Dept] WHERE CompanyID = <cfqueryparam value="#session.companyid#" cfsqltype="cf_sql_varchar">
                        AND Dept = <cfqueryparam value="#TRIM(url.FromDept)#" cfsqltype="cf_sql_varchar">) AS DeptDesc
                </cfif>
                FROM  [LMA General Ledger Chart of Accounts]
                WHERE CompanyID = <cfqueryparam value="#session.companyid#" cfsqltype="cf_sql_varchar">
                <cfif structKeyExists(url, "DeptFilter") AND url.DeptFilter>
                    <cfif LEN(TRIM(url.FromDept)) OR LEN(TRIM(url.ToDept))>
                        AND LEN(GL_ACCT) > 4
                        <cfif LEN(TRIM(url.FromDept))>
                            AND RIGHT(GL_ACCT,4) >= <cfqueryparam value="#Rjustify(url.FromDept,4)#" cfsqltype="cf_sql_varchar">
                        </cfif>
                        <cfif LEN(TRIM(url.ToDept))>
                            AND RIGHT(GL_ACCT,4) <= <cfqueryparam value="#Rjustify(url.ToDept,4)#" cfsqltype="cf_sql_varchar">
                        </cfif>
                    </cfif>
                </cfif>
                ORDER BY GL_ACCT
            </cfquery>


        	<cfset fileName = "Trial Balance Date-#DateFormat(Now(),'mm.dd.yyyy')#.pdf">
        	<cfheader name="Content-Disposition" value="inline; filename=#fileName#">
        	<cfdocument format="PDF" name="TrialBalance" margintop="2">
        		<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
        	    <HTML xmlns="http://www.w3.org/1999/xhtml">
        	        <HEAD>
        	            <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
        	            <TITLE>Load Manager TMS</TITLE>
        	        </HEAD> 
        	        <BODY style="font-family: 'Arial';">
                        <cfdocumentitem type="header">
                            <table width="100%" style="font-family: 'Arial';border-bottom: solid 6px ##C0C0C0;border-top: solid 3px ##C0C0C0;margin-top: 25px;">
                                <tr>
                                    <td width="80%">
                                        <h2>#qGetSystemConfig.companyName#</h2>
                                        <h2>Trial Balance</h2>
                                    </td>
                                    <td width="20%" valign="bottom"><b>Period</b>: #DateFormat(url.Period,"m/yy")#</td>
                                </tr>
                            </table>
                            <cfif structKeyExists(qGetTrialBalance, "DeptDesc") and len(trim(qGetTrialBalance.DeptDesc))>
                                <p style="margin-left: 350px;font-size: 12px;margin-top: 3px;margin-bottom: 0px;"><b>Dept Desc:</b>#qGetTrialBalance.DeptDesc#</p>
                            </cfif>
                            <table width="100%" style="font-family: 'Arial';font-size: 14px;margin-top: 16px;" cellspacing="0" cellpadding="0">
                                <thead>
                                    <tr>
                                        <th width="10%" align="left" style="border-bottom: solid 3px;border-top: solid 3px;padding-top: 10px;">Account##</th>
                                        <th width="60%" align="left" style="border-bottom: solid 3px;border-top: solid 3px;padding-top: 10px;">Description</th>
                                        <th width="15%" align="right" style="border-bottom: solid 3px;border-top: solid 3px;padding-top: 10px;">Debit</th>
                                        <th width="15%" align="right" style="border-bottom: solid 3px;border-top: solid 3px;padding-top: 10px;">Credit</th>
                                    </tr>
                                </thead>
                            </table>
                        </cfdocumentitem>
                        <cfset local.debitTotal = 0>
                        <cfset local.creditTotal = 0>
                        <table width="100%" style="font-family: 'Arial';font-size: 14px;margin-top: -10px;" cellspacing="0" cellpadding="0">
                            <tbody>
                                <cfif structKeyExists(url, "SummarizeDepts") AND url.SummarizeDepts>
                                    <cfloop query="qGetTrialBalance" group="GL_ACCT_GRP">
                                        <cfset local.Balance = 0>
                                        <cfloop group="GL_ACCT">
                                            <cfset local.Balance = local.Balance + qGetTrialBalance.Balance>
                                        </cfloop>
                                        <cfif qGetTrialBalance.Balance NEQ 0>
                                            <tr>
                                                <td width="10%" style="font-size: 12px;padding-top: 5px;">#qGetTrialBalance.GL_ACCT_GRP#</td>
                                                <td width="60%" style="font-size: 12px;padding-top: 5px;">#qGetTrialBalance.Description#</td>
                                                <td width="15%" style="font-size: 12px;padding-top: 5px;" align="right">
                                                    <cfif qGetTrialBalance.CREDIT_DEBIT EQ "D">
                                                        <b>#DollarFormat(local.Balance)#</b>
                                                        <cfset local.debitTotal = local.debitTotal + local.Balance>
                                                    </cfif>
                                                </td>
                                                <td width="15%" style="font-size: 12px;padding-top: 5px;" align="right">
                                                    <cfif qGetTrialBalance.CREDIT_DEBIT EQ "C">
                                                        <b>#DollarFormat(-1*local.Balance)#</b>
                                                        <cfset local.creditTotal = local.creditTotal + local.Balance>
                                                    </cfif>
                                                </td>
                                            </tr>
                                        </cfif>
                                    </cfloop>
                                <cfelse>
                                    <cfloop query="qGetTrialBalance">
                                        <cfif qGetTrialBalance.Balance NEQ 0>
                                            <tr>
                                                <td width="10%" style="font-size: 12px;padding-top: 5px;border-bottom: solid 1px gray;">
                                                    <cfif len(qGetTrialBalance.GL_ACCT) EQ 4>
                                                        #qGetTrialBalance.GL_ACCT#&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                                                    <cfelse>
                                                        #replace(qGetTrialBalance.GL_ACCT," ","&nbsp;","all")#

                                                    </cfif>
                                                </td>
                                                <td width="60%" style="font-size: 12px;padding-top: 5px;border-bottom: solid 1px gray;">#qGetTrialBalance.Description#</td>
                                                <td width="15%" style="font-size: 12px;padding-top: 5px;border-bottom: solid 1px gray;" align="right">
                                                    <cfif qGetTrialBalance.CREDIT_DEBIT EQ "D">
                                                        <b>#DollarFormat(qGetTrialBalance.Balance)#</b>
                                                        <cfset local.debitTotal = local.debitTotal + qGetTrialBalance.Balance>
                                                    </cfif>
                                                </td>
                                                <td width="15%" style="font-size: 12px;padding-top: 5px;border-bottom: solid 1px gray;" align="right">
                                                    <cfif qGetTrialBalance.CREDIT_DEBIT EQ "C">
                                                        <b>#DollarFormat(-1*qGetTrialBalance.Balance)#</b>
                                                        <cfset local.creditTotal = local.creditTotal + qGetTrialBalance.Balance>
                                                    </cfif>
                                                </td>
                                            </tr>
                                        </cfif>
                                    </cfloop>
                                </cfif>
                                <tr>
                                    <td colspan="2" align="right">
                                        <b>Total: </b>
                                    </td>
                                    <td align="right"><b>#DollarFormat(local.debitTotal)#</b></td>
                                    <td align="right"><b>#DollarFormat(-1*local.creditTotal)#</b></td>
                                </tr>
                            </tbody>
                        </table>
                        <cfdocumentitem type = "footer">
                            <table width="100%" style="font-family: 'Arial';font-size: 12px;margin-top: -10px;" cellspacing="0" cellpadding="0" style="border-top: solid 5px ##C0C0C0;">
                                <tr>
                                    <td>#DateTimeFormat(now(),"mmm dd, yyyy, hh:nn:ss tt")#</td>
                                    <td align="right">Page #cfdocument.currentpagenumber# of #cfdocument.totalpagecount#</td>
                                </tr>
                            </table>
                        </cfdocumentitem> 
        	        </BODY>
        	    </HTML>      	
        	</cfdocument>
        	<cfcontent variable="#toBinary(TrialBalance)#" type="application/pdf" /> 	
        </cfif>
        <cfcatch>
            <cfset fileName = "Trial Balance Date-#DateFormat(Now(),'mm.dd.yyyy')#.pdf">
            <cfheader name="Content-Disposition" value="inline; filename=#fileName#">
            <cfdocument format="PDF" name="TrialBalance" margintop="1.5">
                <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
                <HTML xmlns="http://www.w3.org/1999/xhtml">
                    <HEAD>
                        <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
                        <TITLE>Load Manager TMS</TITLE>
                    </HEAD> 
                    <BODY style="font-family: 'Arial';">
                        Unable To Generate Report.
                    </BODY>
                </HTML>
            </cfdocument>
            <cfcontent variable="#toBinary(TrialBalance)#" type="application/pdf" />  
        </cfcatch>
    </cftry>
</cfoutput>