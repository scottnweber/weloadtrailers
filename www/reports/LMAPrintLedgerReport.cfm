<cfoutput>
    <cftry>
        <cfset local.dsn = trim(listFirst(cgi.SCRIPT_NAME,'/'))>
        <cfquery name="qLMASystemConfig" datasource="#local.dsn#">
            SELECT [Fiscal Year] FROM [LMA System Config]  WHERE CompanyID = <cfqueryparam value="#session.companyid#" cfsqltype="cf_sql_varchar">
        </cfquery>
        <cfset FiscalYearStart = qLMASystemConfig['Fiscal Year']>
        <cfset FiscalYearEnd = dateAdd("d", -1, dateAdd("yyyy", 1, FiscalYearStart))>

        <cfset FiscalYearStartCurrent = DateFormat(FiscalYearStart,"mm/dd/yyyy")>
        <cfset FiscalYearEndCurrrent = DateFormat(FiscalYearEnd,"mm/dd/yyyy")>

        <cfset FiscalYearStartOneYr = DateFormat(dateadd("yyyy",-1,FiscalYearStartCurrent),"mm/dd/yyyy")>
        <cfset FiscalYearEndOneYr =  DateFormat(dateadd("yyyy",-1,FiscalYearEndCurrrent),"mm/dd/yyyy")>

        <cfset FiscalYearStartTwoYr = DateFormat(dateadd("yyyy",-2,FiscalYearStartCurrent),"mm/dd/yyyy")>
        <cfset FiscalYearEndTwoYr =  DateFormat(dateadd("yyyy",-2,FiscalYearEndCurrrent),"mm/dd/yyyy")>

        <cfif NOT Len(Trim(FiscalYearStart))>
            <cfset fileName = "Trial Balance Date-#DateFormat(Now(),'mm.dd.yyyy')#.pdf">
            <cfheader name="Content-Disposition" value="inline; filename=#fileName#">
            <cfdocument format="PDF" name="LedgerReport" margintop="1.5">
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
            <cfcontent variable="#toBinary(LedgerReport)#" type="application/pdf" /> 
        <cfelseif 
        (NOT (dateDiff("d", FiscalYearStartTwoYr, url.periodstart) GTE 0 AND dateDiff("d", FiscalYearEndCurrrent, url.periodstart) LTE 0)) 
        OR (NOT (dateDiff("d", FiscalYearStartTwoYr, url.periodend) GTE 0 AND dateDiff("d", FiscalYearEndCurrrent, url.periodend) LTE 0)) 
        OR dateDiff("m", url.periodstart, url.periodend) LT 0>  
            <cfset fileName = "Trial Balance Date-#DateFormat(Now(),'mm.dd.yyyy')#.pdf">
            <cfheader name="Content-Disposition" value="inline; filename=#fileName#">
            <cfdocument format="PDF" name="LedgerReport" margintop="1.5">
                <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
                <HTML xmlns="http://www.w3.org/1999/xhtml">
                    <HEAD>
                        <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
                        <TITLE>Load Manager TMS</TITLE>
                    </HEAD> 
                    <BODY style="font-family: 'Arial';">
                        Invalid Period.
                    </BODY>
                </HTML>
            </cfdocument>
            <cfcontent variable="#toBinary(LedgerReport)#" type="application/pdf" /> 
        <cfelse>
            
            <cfset dateRangeStart = CreateDate(DateFormat(url.periodstart,'yyyy'), DateFormat(url.periodstart,'mm'), 1)>
            <cfset dateRangeEnd = CreateDate(DateFormat(url.periodend,'yyyy'), DateFormat(url.periodend,'mm'), 1)>
            <cfset dateRangeEnd = dateadd("m",1,dateRangeEnd)>
            <cfset dateRangeEnd = dateadd("d",-1,dateRangeEnd)>
            <cfset monthList = "">
            
            <cfloop index="i" from="#DateFormat(dateRangeStart,'yyyy-mm-dd')#" to="#DateFormat(dateRangeEnd,'yyyy-mm-dd')#" step="#createTimeSpan(31, 0, 0, 0)#">
                <cfset dateRange = DateFormat(i,'mm/dd/yyyy')>

                <cfif dateDiff("d", FiscalYearStartCurrent, dateRange) GTE 0 AND dateDiff("d", FiscalYearEndCurrrent, dateRange) LTE 0>
                    <cfset monthList = listAppend(monthList, "#dateformat(dateRange,"MMM")#_CURRENT")>
                </cfif>
                <cfif dateDiff("d", FiscalYearStartOneYr, dateRange) GTE 0 AND dateDiff("d", FiscalYearEndOneYr, dateRange) LTE 0>
                    <cfset monthList = listAppend(monthList, "#dateformat(dateRange,"MMM")#_1YR")>
                </cfif>
                <cfif dateDiff("d", FiscalYearStartTwoYr, dateRange) GTE 0 AND dateDiff("d", FiscalYearEndTwoYr, dateRange) LTE 0>
                    <cfset monthList = listAppend(monthList, "#dateformat(dateRange,"MMM")#_2YR")>
                </cfif>
            </cfloop>

            <cfquery name="qGetSystemConfig" datasource="#local.dsn#">
                SELECT companyName FROM Companies WHERE CompanyID = <cfqueryparam value="#session.companyid#" cfsqltype="cf_sql_varchar">
            </cfquery>

            <cfquery name="qLedgerReport" datasource="#local.dsn#">
                SELECT COA.GL_ACCT,COA.Description,0 AS openBal,
                (0
                <cfloop list="#monthList#" index="month">
                    + #month#
                </cfloop>)
                AS currentBal 
                ,GL.ID AS GLID,GL.EntryDate,GL.[Invoice Code] AS TransCode,GL.Code AS REF,GL.Typetran,GL.Description AS GLDescription,GL.Damount,GL.Camount

                FROM  [LMA General Ledger Chart of Accounts] COA
                LEFT JOIN [LMA General Ledger Transactions] GL ON GL.[GL Account] = COA.GL_ACCT AND GL.CompanyID= COA.CompanyID
                AND GL.EntryDate >= <cfqueryparam value="#dateRangeStart#" cfsqltype="cf_sql_date">
                AND GL.EntryDate <= <cfqueryparam value="#dateRangeEnd#" cfsqltype="cf_sql_date">
                WHERE COA.CompanyID = <cfqueryparam value="#session.companyid#" cfsqltype="cf_sql_varchar">
                AND COA.GL_ACCT BETWEEN  <cfqueryparam value="#url.FromAccount#" cfsqltype="cf_sql_varchar"> AND  <cfqueryparam value="#url.ToAccount#" cfsqltype="cf_sql_varchar">

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
                ORDER BY COA.GL_ACCT,GL.EntryDate
            </cfquery> 



        	<cfset fileName = "Ledger Report Date-#DateFormat(Now(),'mm.dd.yyyy')#.pdf">
        	<cfheader name="Content-Disposition" value="inline; filename=#fileName#">
        	<cfdocument format="PDF" name="LedgerReport" margintop="2">
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
                                    <td width="60%">
                                        <h2>#qGetSystemConfig.companyName#</h2>
                                        <h2><i>General Ledger Report</i></h2>
                                    </td>
                                    <td width="40%" align="right" style="font-size: 10px;padding-left: 10px;">
                                        <table style="font-size: 13px;" cellspacing="0" cellpadding="0" width="100%">
                                            <tr>
                                                <td align="right"><i><b>Period From: </b></i></td>
                                                <td>#DateFormat(url.periodstart,"m/yy")#</td>
                                                <td align="right"><i><b>To: </b></i></td>
                                                <td>#DateFormat(url.periodend,"m/yy")#</td>
                                            </tr>
                                            <tr>
                                                <td align="right"><i><b>Account From: </b></i></td>
                                                <td>#url.FromAccount#</td>
                                                <td align="right"><i><b>To: </b></i></td>
                                                <td>#url.ToAccount#</td>
                                            </tr>
                                            <cfif structKeyExists(url, "DeptFilter") AND url.DeptFilter>
                                                <td align="right"><i><b>Dept From: </b></i></td>
                                                <td>#url.FromDept#</td>
                                                <td align="right"><i><b>To: </b></i></td>
                                                <td>#url.ToDept#</td>
                                            </cfif>
                                        </table>
                                    </td>
                                </tr>
                            </table>
                            <table width="100%" style="font-family: 'Arial';font-size: 14px;margin-top: 16px;" cellspacing="0" cellpadding="0">
                                <thead>
                                    <tr>
                                        <th align="left" width="10%" style="border-bottom: solid 3px;border-top: solid 3px;padding-top: 10px;"><i>Date</i></th>
                                        <th align="left" width="15%" style="border-bottom: solid 3px;border-top: solid 3px;padding-top: 10px;"><i>Transaction##</i></th>
                                        <th style="border-bottom: solid 3px;border-top: solid 3px;padding-top: 10px;" align="left" width="15%"><i>Reference</i></th>
                                        <th style="border-bottom: solid 3px;border-top: solid 3px;padding-top: 10px;" align="left" width="10%"><i>Type</i></th>
                                        <th style="border-bottom: solid 3px;border-top: solid 3px;padding-top: 10px;" align="left" width="20%"><i>Description</i></th>
                                        <th style="border-bottom: solid 3px;border-top: solid 3px;padding-top: 10px;" align="right" width="10%"><i>Debit</i></th>
                                        <th style="border-bottom: solid 3px;border-top: solid 3px;padding-top: 10px;" align="right" width="10%"><i>Credit</i></th>
                                        <th style="border-bottom: solid 3px;border-top: solid 3px;padding-top: 10px;" align="right" width="10%"><i>Balance</i></th>
                                    </tr>
                                </thead>
                            </table>
                        </cfdocumentitem>
                        <table width="100%" style="font-family: 'Arial';font-size: 14px;" cellspacing="0" cellpadding="0">
                            <cfloop query="qLedgerReport" group="gl_acct">
                                <cfif qLedgerReport.currentBal neq 0>
                                    <tr>
                                        <td colspan="2" style="border-bottom: solid 1px;"><i><b>Account##:</b></i>#replace(qLedgerReport.gl_acct," ","&nbsp;","all")#</td>
                                        <td colspan="3" style="border-bottom: solid 1px;"><i><b>Description:</b></i>#qLedgerReport.Description#</td>
                                        <td colspan="2" style="border-bottom: solid 1px;"><i><b>Open Balance:</b></i></td>
                                        <td style="border-bottom: solid 1px;" align="right">#DollarFormat(qLedgerReport.openBal)#</td>
                                    </tr>
                                    <cfset local.bal = 0>
                                    <cfset local.DamountTotal = 0>
                                    <cfset local.CamountTotal = 0>
                                    <cfloop group="GLID">
                                        <cfif len(trim(qLedgerReport.GLID))>
                                            <cfset local.DamountTotal = local.DamountTotal + qLedgerReport.Damount>
                                            <cfset local.CamountTotal = local.CamountTotal + qLedgerReport.Camount>
                                            <cfset local.bal = local.bal+qLedgerReport.Damount+qLedgerReport.Camount>
                                            <tr style="font-size: 12px;">
                                                <td align="left" width="10%">#DateFormat(qLedgerReport.EntryDate,"mm/dd/yyyy")#</td>
                                                <td align="left" width="15%">#qLedgerReport.TransCode#</td>
                                                <td align="left" width="15%">#qLedgerReport.Ref#</td>
                                                <td align="left" width="10%">#qLedgerReport.Typetran#</td>
                                                <td align="left" width="20%">#qLedgerReport.GLDescription#</td>
                                                <td align="right" width="10%">
                                                    <cfif qLedgerReport.Damount NEQ 0>
                                                        #DollarFormat(qLedgerReport.Damount)#
                                                    </cfif>
                                                </td>
                                                <td align="right" width="10%">
                                                    <cfif qLedgerReport.Camount NEQ 0>
                                                        #DollarFormat(qLedgerReport.Camount)#
                                                    </cfif>
                                                </td>
                                                <td align="right" width="10%">#DollarFormat(local.bal)#</td>
                                            </tr>
                                        <cfelse>
                                            <tr><td colspan="8" style="height: 10px;"></td></tr>
                                        </cfif>
                                    </cfloop>
                                    <cfif local.bal neq 0>
                                        <tr>
                                            <td colspan="3"></td>
                                            <td style="border-top: solid 1px;"><i><b>Acct##:</b></i>#qLedgerReport.gl_acct#</td>
                                            <td align="center" style="border-top: solid 1px;"><b>Total:</b></td>
                                            <td style="border-top: solid 1px;" align="right">#DollarFormat(local.DamountTotal)#</td>
                                            <td style="border-top: solid 1px;" align="right">#DollarFormat(local.CamountTotal)#</td>
                                            <td style="border-top: solid 1px;" align="right">#DollarFormat(local.bal)#</td>
                                        </tr>
                                    </cfif>
                                    <tr>
                                        <td colspan="5"></td>
                                        <td colspan="2" style="border-bottom: solid 1px;border-top: solid 1px;"><i><b>Current Balance:</b></i></td>
                                        <td style="border-bottom: solid 1px;border-top: solid 1px;" align="right">#DollarFormat(qLedgerReport.currentBal)#</td>
                                    </tr>
                                    <tr>
                                        <td colspan="8" style="height: 30px;"></td>
                                    </tr>
                                </cfif>
                            </cfloop>
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
        	<cfcontent variable="#toBinary(LedgerReport)#" type="application/pdf" /> 	
        </cfif>
        <cfcatch>
            <cfdump var="#cfcatch#"><cfabort>
            <cfset fileName = "Trial Balance Date-#DateFormat(Now(),'mm.dd.yyyy')#.pdf">
            <cfheader name="Content-Disposition" value="inline; filename=#fileName#">
            <cfdocument format="PDF" name="LedgerReport" margintop="1.5">
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
            <cfcontent variable="#toBinary(LedgerReport)#" type="application/pdf" />  
        </cfcatch>
    </cftry>
</cfoutput>