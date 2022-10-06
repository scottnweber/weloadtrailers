<cfoutput>
    <cftry>
        <cfset local.dsn = trim(listFirst(cgi.SCRIPT_NAME,'/'))>
        <cfquery name="qGetSystemConfig" datasource="#local.dsn#">
            SELECT companyName FROM Companies WHERE CompanyID = <cfqueryparam value="#session.companyid#" cfsqltype="cf_sql_varchar">
        </cfquery>

        <cfquery name="qLMASystemConfig" datasource="#local.dsn#">
            SELECT [Fiscal Year] FROM [LMA System Config] WHERE CompanyID = <cfqueryparam value="#session.companyid#" cfsqltype="cf_sql_varchar">
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

        <cfquery name="qIncomeStatement" datasource="#local.dsn#">
            SELECT 
            ISS.ProfitType,
            ISS.MainTitle,
            ISS.SubTitle,
            COA.GL_ACCT,
            COA.Description,
            COA.#dateFormat(now(), "MMM")#_#yrVal# AS CurrentMonth,
            (OPEN_#yrVal#
                    <cfloop list="#monthList#" index="month">
                    + #month#_#yrVal#
                    </cfloop>
                ) AS CurrentYTD

            <cfif yrDiff EQ 0>
                ,COA.#dateFormat(now(), "MMM")#_1YR AS PriorYearMonth
                ,(OPEN_1YR
                    <cfloop list="#monthList#" index="month">
                    + #month#_1YR
                    </cfloop>
                ) AS PriorYearYTD
            <cfelseif yrDiff EQ 1>
                ,COA.#dateFormat(now(), "MMM")#_2YR AS PriorYearMonth
                ,(OPEN_2YR
                    <cfloop list="#monthList#" index="month">
                    + #month#_2YR
                    </cfloop>
                ) AS PriorYearYTD
            <cfelse>
                ,0 AS PriorYearMonth
                ,0 AS PriorYearYTD
            </cfif>
            <cfif structKeyExists(url, "SummarizeDepts") AND url.SummarizeDepts>
                ,LEFT(GL_ACCT,4) AS GL_ACCT_GRP
            </cfif>
            <cfif structKeyExists(url, "DeptFilter") AND url.DeptFilter>
                ,(select Description from [LMA General Ledger Dept] WHERE CompanyID = <cfqueryparam value="#session.companyid#" cfsqltype="cf_sql_varchar">
                    AND Dept =  <cfqueryparam value="#TRIM(url.FromDept)#" cfsqltype="cf_sql_varchar">) AS DeptDesc
            </cfif>
            FROM [LMA General Ledger Income Statement Setup] ISS 
            INNER JOIN [LMA General Ledger Chart of Accounts] COA ON COA.GL_ACCT between GLAcctFROM+'%' AND GLAcctTo+'%'
            WHERE COA.#dateFormat(now(), "MMM")#_#yrVal# <> 0
            AND COA.CompanyID = <cfqueryparam value="#session.CompanyID#" cfsqltype="cf_sql_varchar">
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
            ORDER BY ISS.MainSort,ISS.subsort,COA.GL_ACCT
        </cfquery>

    	<cfset fileName = "Trial Balance Date-#DateFormat(Now(),'mm.dd.yyyy')#.pdf">
    	<cfheader name="Content-Disposition" value="inline; filename=#fileName#">
    	<cfdocument format="PDF" name="IncomeStatement"  margintop="2" orientation="landscape">
    		<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
    	    <HTML xmlns="http://www.w3.org/1999/xhtml">
    	        <HEAD>
    	            <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
    	            <TITLE>Load Manager TMS</TITLE>
    	        </HEAD> 
    	        <BODY style="font-family: 'Arial';">
                    <cfdocumentitem type="header">
                        <table width="100%" style="font-family: 'Arial';border-bottom: solid 6px ##C0C0C0;border-top: solid 3px ##C0C0C0;">
                            <tr>
                                <td colspan="3" style="padding-bottom: 10px;">
                                    <h2>#qGetSystemConfig.companyName#</h2>
                                </td>
                            </tr>
                            <tr>
                                <td width="50%">
                                    <h2><i>Profit and Loss Statement - Monthly</i></h2>
                                </td>
                                <td width="10%" valign="top" align="right" style="border-right: solid 1px;padding-right: 5px;font-size: 13px;"><i><b>Month</b></i></td>
                                <td width="40%" valign="top" align="left" style="padding-left: 15px;font-size: 13px;"><i><b>For</b>: #DateFormat(url.Period,"m/yy")#</i></td>
                            </tr>
                        </table>
                        <cfif structKeyExists(qIncomeStatement, "DeptDesc") and len(trim(qIncomeStatement.DeptDesc))>
                            <p style="margin-left: 350px;font-size: 12px;margin-top: 3px;margin-bottom: 0px;"><b>Dept Desc:</b>#qIncomeStatement.DeptDesc#</p>
                        </cfif>
                        <div style="position: absolute;bottom:0px;width: 100%;">
                            <table width="100%" style="font-family: 'Arial';font-size: 14px;" cellspacing="0" cellpadding="0">
                                <thead>
                                    <tr>
                                        <th align="left" style="border-bottom: solid 3px;border-top: solid 3px;padding-top: 10px;" width="7%" valign="bottom"><i>Account##</i></th>
                                        <th align="left" style="border-bottom: solid 3px;border-top: solid 3px;padding-top: 10px;" width="15%" valign="bottom"><i>Description</i></th>
                                        <th align="right" style="border-bottom: solid 3px;border-top: solid 3px;padding-top: 10px;" width="9%" valign="bottom"><i>Current<br>Month</i></th>
                                        <th align="right" style="border-bottom: solid 3px;border-top: solid 3px;padding-top: 10px;" width="4%" valign="bottom"><i>%</i></th>
                                        <th align="right" style="border-bottom: solid 3px;border-top: solid 3px;" width="9%" valign="bottom"><i>Current<br>YTD</i></th>
                                        <th align="right" style="border-bottom: solid 3px;border-top: solid 3px;padding-top: 10px;border-right: solid 1px;" width="4%" valign="bottom"><i>% </i></th>
                                        <th align="right" style="border-bottom: solid 3px;border-top: solid 3px;padding-top: 10px;" width="9%" valign="bottom"><i>Prior Year<br>Month</i></th>
                                        <th align="right" style="border-bottom: solid 3px;border-top: solid 3px;padding-top: 10px;" width="4%" valign="bottom"><i>%</i></th>
                                        <th align="right" style="border-bottom: solid 3px;border-top: solid 3px;padding-top: 10px;" width="9%" valign="bottom"><i>Prior Year<br>YTD</i></th>
                                        <th align="right" style="border-bottom: solid 3px;border-top: solid 3px;padding-top: 10px;border-right: solid 1px;" width="4%" valign="bottom"><i>% </i></th>
                                        <th align="right" style="border-bottom: solid 3px;border-top: solid 3px;padding-top: 10px;" width="9%" valign="bottom"><i>Variance<br>Month</i></th>
                                        <th align="right" style="border-bottom: solid 3px;border-top: solid 3px;padding-top: 10px;" width="4%" valign="bottom"><i>%</i></th>
                                        <th align="right" style="border-bottom: solid 3px;border-top: solid 3px;padding-top: 10px;" width="9%" valign="bottom"><i>Variance<br>YTD</i></th>
                                        <th align="right" style="border-bottom: solid 3px;border-top: solid 3px;padding-top: 10px;" width="4%" valign="bottom"><i>%</i></th>
                                    </tr>
                                </thead>
                            </table>
                        </div>
                    </cfdocumentitem>
                    <div style="position: absolute;top:0px;width: 100%;">
                        <table width="100%" style="font-family: 'Arial';font-size: 14px;" cellspacing="0" cellpadding="0">
                            <tbody>
                                <cfset ProfitTypeCurrentMonthTotal = 0>
                                <cfset ProfitTypeCurrentYTDTotal = 0>
                                <cfset ProfitTypePriorYearMonthTotal = 0>
                                <cfset ProfitTypePriorYearYTDTotal = 0>
                                <cfset ProfitTypeVarianceMonthTotal = 0>
                                <cfset ProfitTypeVarianceYTDTotal = 0>
                                <cfloop query="qIncomeStatement" group="ProfitType">
                                    <cfloop group="MainTitle">
                                        <tr>
                                            <td height="50" colspan="6" style="border-bottom: inset 1px;border-right: solid 1px;" valign="bottom">
                                                <b>#qIncomeStatement.MainTitle#</b>
                                            </td>
                                            <td height="50" colspan="4" style="border-bottom: inset 1px;border-right: solid 1px;">&nbsp;</td>
                                            <td height="50" colspan="4" style="border-bottom: inset 1px;">&nbsp;</td>
                                        </tr>
                                        <tr>
                                            <td height="35" colspan="6" valign="bottom" style="border-right: solid 1px;">
                                                <i style="margin-left: 10px;">#qIncomeStatement.SubTitle#</i>
                                            </td>
                                            <td height="35" colspan="4" style="border-right: solid 1px;">&nbsp;</td>
                                            <td height="35" colspan="4">&nbsp;</td>
                                        </tr>
                                        <cfset CurrentMonthTotal = 0>
                                        <cfset CurrentYTDTotal = 0>
                                        <cfset PriorYearMonthTotal = 0>
                                        <cfset PriorYearYTDTotal = 0>
                                        <cfset VarianceMonthTotal = 0>
                                        <cfset VarianceYTDTotal = 0>
                                        <cfloop group="GL_ACCT">
                                            <cfset CurrentMonthTotal = CurrentMonthTotal+CurrentMonth>
                                            <cfset CurrentYTDTotal = CurrentYTDTotal+CurrentYTD>
                                            <cfset PriorYearMonthTotal = PriorYearMonthTotal+PriorYearMonth>
                                            <cfset PriorYearYTDTotal = PriorYearYTDTotal+PriorYearYTD>
                                            <cfset VarianceMonth = CurrentMonth - PriorYearMonth>
                                            <cfset VarianceMonthTotal = VarianceMonthTotal + VarianceMonth>
                                            <cfset VarianceYTD = CurrentYTD - PriorYearYTD>
                                            <cfset VarianceYTDTotal = VarianceYTDTotal + VarianceYTD>
                                        </cfloop>
                                        <cfif structKeyExists(url, "SummarizeDepts") AND url.SummarizeDepts>
                                            <cfloop group="GL_ACCT_GRP">
                                                <cfset local.CurrentMonth = 0>
                                                <cfset local.CurrentYTD = 0>
                                                <cfset local.PriorYearMonth = 0>
                                                <cfset local.PriorYearYTD = 0>
                                                <cfloop group="GL_ACCT">
                                                    <cfset local.CurrentMonth = local.CurrentMonth + qIncomeStatement.CurrentMonth>
                                                    <cfset local.CurrentYTD = local.CurrentYTD + qIncomeStatement.CurrentYTD>
                                                    <cfset local.PriorYearMonth = local.PriorYearMonth + qIncomeStatement.PriorYearMonth>
                                                    <cfset local.PriorYearYTD = local.PriorYearYTD + qIncomeStatement.PriorYearYTD>
                                                    <cfset CurrentMonthPerc = (CurrentMonth/CurrentMonthTotal)*100>
                                                    <cfset CurrentYTDPerc = (CurrentYTD/CurrentYTDTotal)*100>
                                                    <cfif PriorYearMonthTotal EQ 0>
                                                        <cfset PriorYearMonthPerc = 0>
                                                    <cfelse>
                                                        <cfset PriorYearMonthPerc = (PriorYearMonth/PriorYearMonthTotal)*100>
                                                    </cfif>
                                                    <cfif PriorYearYTDTotal EQ 0>
                                                        <cfset PriorYearYTDPerc = 0>
                                                    <cfelse>
                                                        <cfset PriorYearYTDPerc = (PriorYearYTD/PriorYearYTDTotal)*100>
                                                    </cfif>
                                                    <cfset VarianceMonth = CurrentMonth - PriorYearMonth>
                                                    <cfset VarianceMonthPerc = (VarianceMonth/VarianceMonthTotal)*100>
                                                    <cfset VarianceYTD = CurrentYTD - PriorYearYTD>
                                                    <cfset VarianceYTDPerc = (VarianceYTD/VarianceYTDTotal)*100>

                                                    <cfif ProfitTypeCurrentMonthTotal EQ 0>
                                                        <cfset ProfitTypeCurrentMonthTotal = CurrentMonthTotal>
                                                    <cfelse>
                                                        <cfset ProfitTypeCurrentMonthTotal = ProfitTypeCurrentMonthTotal-CurrentMonthTotal>
                                                    </cfif>

                                                    <cfif ProfitTypeCurrentYTDTotal EQ 0>
                                                        <cfset ProfitTypeCurrentYTDTotal = CurrentYTDTotal>
                                                    <cfelse>
                                                        <cfset ProfitTypeCurrentYTDTotal = ProfitTypeCurrentMonthTotal-CurrentYTDTotal>
                                                    </cfif>

                                                    <cfif ProfitTypePriorYearMonthTotal EQ 0>
                                                        <cfset ProfitTypePriorYearMonthTotal = PriorYearMonthTotal>
                                                    <cfelse>
                                                        <cfset ProfitTypePriorYearMonthTotal = ProfitTypePriorYearMonthTotal-PriorYearMonthTotal>
                                                    </cfif>

                                                    <cfif ProfitTypePriorYearYTDTotal EQ 0>
                                                        <cfset ProfitTypePriorYearYTDTotal = PriorYearYTDTotal>
                                                    <cfelse>
                                                        <cfset ProfitTypePriorYearYTDTotal = ProfitTypePriorYearMonthTotal-PriorYearYTDTotal>
                                                    </cfif>
                                                </cfloop>
                                                <tr>
                                                    <td style="font-size: 11px;" width="7%" align="center">
                                                        #qIncomeStatement.GL_ACCT#
                                                    </td>
                                                    <td style="font-size: 11px;" width="15%">
                                                        #qIncomeStatement.Description#
                                                    </td>
                                                    
                                                    <!--- Current --->
                                                    <td style="font-size: 11px;" width="9%" align="right">
                                                        #DollarFormat(CurrentMonth)#
                                                    </td>
                                                    <td style="font-size: 11px;" width="4%" align="right">
                                                        #numberFormat(CurrentMonthPerc,'__.0')#%
                                                    </td>
                                                    <td style="font-size: 11px;" width="9%" align="right">
                                                        #DollarFormat(CurrentYTD)#
                                                    </td>
                                                    <td style="font-size: 11px;border-right: solid 1px;" width="4%" align="right">
                                                        #numberFormat(CurrentYTDPerc,'__.0')#%
                                                    </td>
                                                    <!--- Current --->

                                                    <!--- Prior --->
                                                    <td style="font-size: 11px;" width="9%" align="right">
                                                        #DollarFormat(PriorYearMonth)#
                                                    </td>
                                                    <td style="font-size: 11px;" width="4%" align="right">
                                                        #numberFormat(PriorYearMonthPerc,'__.0')#%
                                                    </td>
                                                    <td style="font-size: 11px;" width="9%" align="right">
                                                        #DollarFormat(PriorYearYTD)#
                                                    </td>
                                                    <td style="font-size: 11px;border-right: solid 1px;" width="4%" align="right">
                                                        #numberFormat(PriorYearYTDPerc,'__.0')#%
                                                    </td>
                                                    <!--- Prior --->

                                                    <!--- Variance --->
                                                    <td style="font-size: 11px;" width="9%" align="right">
                                                        #DollarFormat(VarianceMonth)#
                                                    </td>
                                                    <td style="font-size: 11px;" width="4%" align="right">
                                                        #numberFormat(VarianceMonthPerc,'__.0')#%
                                                    </td>
                                                    <td style="font-size: 11px;" width="9%" align="right">
                                                        #DollarFormat(VarianceYTD)#
                                                    </td>
                                                    <td style="font-size: 11px;" width="4%" align="right">
                                                        #numberFormat(VarianceYTDPerc,'__.0')#%
                                                    </td>
                                                    <!--- Variance --->
                                                </tr>
                                            </cfloop>
                                        <cfelse>
                                            <cfloop group="GL_ACCT">
                                                <cfset CurrentMonthPerc = (CurrentMonth/CurrentMonthTotal)*100>

                                                <cfif CurrentYTDTotal EQ 0>
                                                    <cfset CurrentYTDPerc = 0>
                                                <cfelse>
                                                    <cfset CurrentYTDPerc = (CurrentYTD/CurrentYTDTotal)*100>
                                                </cfif>

                                                <cfif PriorYearMonthTotal EQ 0>
                                                    <cfset PriorYearMonthPerc = 0>
                                                <cfelse>
                                                    <cfset PriorYearMonthPerc = (PriorYearMonth/PriorYearMonthTotal)*100>
                                                </cfif>

                                                <cfif PriorYearYTDTotal EQ 0>
                                                    <cfset PriorYearYTDPerc = 0>
                                                <cfelse>
                                                    <cfset PriorYearYTDPerc = (PriorYearYTD/PriorYearYTDTotal)*100>
                                                </cfif>

                                                <cfset VarianceMonth = CurrentMonth - PriorYearMonth>
                                                <cfset VarianceMonthPerc = (VarianceMonth/VarianceMonthTotal)*100>
                                                <cfset VarianceYTD = CurrentYTD - PriorYearYTD>

                                                <cfif VarianceYTDTotal EQ 0>
                                                    <cfset VarianceYTDPerc = 0>
                                                <cfelse>
                                                    <cfset VarianceYTDPerc = (VarianceYTD/VarianceYTDTotal)*100>
                                                </cfif>

                                                <cfif ProfitTypeCurrentMonthTotal EQ 0>
                                                    <cfset ProfitTypeCurrentMonthTotal = CurrentMonthTotal>
                                                <cfelse>
                                                    <cfset ProfitTypeCurrentMonthTotal = ProfitTypeCurrentMonthTotal-CurrentMonthTotal>
                                                </cfif>

                                                <cfif ProfitTypeCurrentYTDTotal EQ 0>
                                                    <cfset ProfitTypeCurrentYTDTotal = CurrentYTDTotal>
                                                <cfelse>
                                                    <cfset ProfitTypeCurrentYTDTotal = ProfitTypeCurrentMonthTotal-CurrentYTDTotal>
                                                </cfif>

                                                <cfif ProfitTypePriorYearMonthTotal EQ 0>
                                                    <cfset ProfitTypePriorYearMonthTotal = PriorYearMonthTotal>
                                                <cfelse>
                                                    <cfset ProfitTypePriorYearMonthTotal = ProfitTypePriorYearMonthTotal-PriorYearMonthTotal>
                                                </cfif>

                                                <cfif ProfitTypePriorYearYTDTotal EQ 0>
                                                    <cfset ProfitTypePriorYearYTDTotal = PriorYearYTDTotal>
                                                <cfelse>
                                                    <cfset ProfitTypePriorYearYTDTotal = ProfitTypePriorYearMonthTotal-PriorYearYTDTotal>
                                                </cfif>
                                                <tr>
                                                    <td style="font-size: 11px;" width="7%" align="center">
                                                        #qIncomeStatement.GL_ACCT#
                                                    </td>
                                                    <td style="font-size: 11px;" width="15%">
                                                        #qIncomeStatement.Description#
                                                    </td>
                                                    
                                                    <!--- Current --->
                                                    <td style="font-size: 11px;" width="9%" align="right">
                                                        #DollarFormat(CurrentMonth)#
                                                    </td>
                                                    <td style="font-size: 11px;" width="4%" align="right">
                                                        #numberFormat(CurrentMonthPerc,'__.0')#%
                                                    </td>
                                                    <td style="font-size: 11px;" width="9%" align="right">
                                                        #DollarFormat(CurrentYTD)#
                                                    </td>
                                                    <td style="font-size: 11px;border-right: solid 1px;" width="4%" align="right">
                                                        #numberFormat(CurrentYTDPerc,'__.0')#%
                                                    </td>
                                                    <!--- Current --->

                                                    <!--- Prior --->
                                                    <td style="font-size: 11px;" width="9%" align="right">
                                                        #DollarFormat(PriorYearMonth)#
                                                    </td>
                                                    <td style="font-size: 11px;" width="4%" align="right">
                                                        #numberFormat(PriorYearMonthPerc,'__.0')#%
                                                    </td>
                                                    <td style="font-size: 11px;" width="9%" align="right">
                                                        #DollarFormat(PriorYearYTD)#
                                                    </td>
                                                    <td style="font-size: 11px;border-right: solid 1px;" width="4%" align="right">
                                                        #numberFormat(PriorYearYTDPerc,'__.0')#%
                                                    </td>
                                                    <!--- Prior --->

                                                    <!--- Variance --->
                                                    <td style="font-size: 11px;" width="9%" align="right">
                                                        #DollarFormat(VarianceMonth)#
                                                    </td>
                                                    <td style="font-size: 11px;" width="4%" align="right">
                                                        #numberFormat(VarianceMonthPerc,'__.0')#%
                                                    </td>
                                                    <td style="font-size: 11px;" width="9%" align="right">
                                                        #DollarFormat(VarianceYTD)#
                                                    </td>
                                                    <td style="font-size: 11px;" width="4%" align="right">
                                                        #numberFormat(VarianceYTDPerc,'__.0')#%
                                                    </td>
                                                    <!--- Variance --->
                                                </tr>
                                            </cfloop>
                                        </cfif>
                                        <tr>
                                            <td colspan="2" height="35" valign="top" style="border-top: inset 1px;">
                                                <b style="margin-left: 10px;">#qIncomeStatement.SubTitle#</b>
                                            </td>

                                            <!--- Current --->
                                            <td valign="top" style="font-size: 11px;border-top: inset 1px;"  align="right">
                                                <b>#dollarformat(CurrentMonthTotal)#</b>
                                            </td>
                                            <td valign="top" style="font-size: 11px;border-top: inset 1px;" align="right">
                                                <b>100.0%</b>
                                            </td>
                                            <td valign="top" style="font-size: 11px;border-top: inset 1px;" align="right">
                                                <b>#dollarformat(CurrentYTDTotal)#</b>
                                            </td>
                                            <td valign="top" style="font-size: 11px;border-right: solid 1px;border-top: inset 1px;" width="4%" align="right">
                                                <b>100.0%</b>
                                            </td>
                                            <!--- Current --->

                                            <!--- Prior --->
                                            <td valign="top" style="font-size: 11px;border-top: inset 1px;"  align="right">
                                                <b>#dollarformat(PriorYearMonthTotal)#</b>
                                            </td>
                                            <td valign="top" style="font-size: 11px;border-top: inset 1px;" align="right">
                                                <b>100.0%</b>
                                            </td>
                                            <td valign="top" style="font-size: 11px;border-top: inset 1px;" align="right">
                                                <b>#dollarformat(PriorYearYTDTotal)#</b>
                                            </td>
                                            <td valign="top" style="font-size: 11px;border-right: solid 1px;border-top: inset 1px;" width="4%" align="right">
                                                <b>100.0%</b>
                                            </td>
                                            <!--- Prior --->

                                            <!--- Variance --->
                                            <td valign="top" style="font-size: 11px;border-top: inset 1px;"  align="right">
                                                <b>#dollarformat(VarianceMonthTotal)#</b>
                                            </td>
                                            <td valign="top" style="font-size: 11px;border-top: inset 1px;" align="right">
                                                <b>100.0%</b>
                                            </td>
                                            <td valign="top" style="font-size: 11px;border-top: inset 1px;" align="right">
                                                <b>#dollarformat(VarianceYTDTotal)#</b>
                                            </td>
                                            <td valign="top" style="font-size: 11px;border-top: inset 1px;" width="4%" align="right">
                                                <b>100.0%</b>
                                            </td>
                                            <!--- Variance --->
                                        </tr>
                                        <tr>
                                            <td colspan="2" height="35" valign="top" style="border-top: inset 1px;">
                                                <b>Total #qIncomeStatement.MainTitle#</b>
                                            </td>

                                            <!--- Current --->
                                            <td valign="top" style="font-size: 11px;border-top: inset 1px;"  align="right">
                                                <b style="font-size: 12px;">#dollarformat(CurrentMonthTotal)#</b>
                                            </td>
                                            <td valign="top" style="font-size: 11px;border-top: inset 1px;padding-top: 3px;" align="right">
                                                <b>100.0%</b>
                                            </td>
                                            <td valign="top" style="font-size: 11px;border-top: inset 1px;" align="right">
                                                <b style="font-size: 12px;">#dollarformat(CurrentYTDTotal)#</b>
                                            </td>
                                            <td valign="top" style="font-size: 11px;border-right: solid 1px;border-top: inset 1px;padding-top: 3px;" width="4%" align="right">
                                                <b>100.0%</b>
                                            </td>
                                            <!--- Current --->

                                            <!--- Prior --->
                                            <td valign="top" style="font-size: 11px;border-top: inset 1px;"  align="right">
                                                <b style="font-size: 12px;">#dollarformat(PriorYearMonthTotal)#</b>
                                            </td>
                                            <td valign="top" style="font-size: 11px;border-top: inset 1px;padding-top: 3px;" align="right">
                                                <b>100.0%</b>
                                            </td>
                                            <td valign="top" style="font-size: 11px;border-top: inset 1px;" align="right">
                                                <b style="font-size: 12px;">#dollarformat(PriorYearYTDTotal)#</b>
                                            </td>
                                            <td valign="top" style="font-size: 11px;border-right: solid 1px;border-top: inset 1px;padding-top: 3px;" width="4%" align="right">
                                                <b>100.0%</b>
                                            </td>
                                            <!--- Prior --->

                                            <!--- Variance --->
                                            <td valign="top" style="font-size: 11px;border-top: inset 1px;"  align="right">
                                                <b style="font-size: 12px;">#dollarformat(VarianceMonthTotal)#</b>
                                            </td>
                                            <td valign="top" style="font-size: 11px;border-top: inset 1px;padding-top: 3px;" align="right">
                                                <b>100.0%</b>
                                            </td>
                                            <td valign="top" style="font-size: 11px;border-top: inset 1px;" align="right">
                                                <b style="font-size: 12px;">#dollarformat(VarianceYTDTotal)#</b>
                                            </td>
                                            <td valign="top" style="font-size: 11px;border-top: inset 1px;padding-top: 3px;" width="4%" align="right">
                                                <b>100.0%</b>
                                            </td>
                                            <!--- Variance --->

                                        </tr>
                                    </cfloop>
                                    <tr>
                                        <td colspan="2" style="border-top: dashed 1px;padding-bottom: 30px;">
                                            <b>#ProfitType#</b>
                                        </td>

                                        <!--- Current --->
                                        <td valign="top" style="font-size: 11px;border-top: dashed 1px;"  align="right">
                                            <b style="font-size: 12px;">#dollarformat(ProfitTypeCurrentMonthTotal)#</b>
                                        </td>
                                        <td valign="top" style="font-size: 11px;border-top: dashed 1px;padding-top: 4px;" align="right">
                                            &nbsp;
                                        </td>
                                        <td valign="top" style="font-size: 11px;border-top: dashed 1px;" align="right">
                                            <b style="font-size: 12px;">#dollarformat(ProfitTypeCurrentYTDTotal)#</b>
                                        </td>
                                        <td valign="top" style="font-size: 11px;border-right: solid 1px;border-top: dashed 1px;padding-top: 4px;" width="4%" align="right">
                                            &nbsp;
                                        </td>
                                        <!--- Current --->

                                        <!--- Prior --->
                                        <td valign="top" style="font-size: 11px;border-top: dashed 1px;"  align="right">
                                            <b style="font-size: 12px;">#dollarformat(ProfitTypePriorYearMonthTotal)#</b>
                                        </td>
                                        <td valign="top" style="font-size: 11px;border-top: dashed 1px;padding-top: 4px;" align="right">
                                            &nbsp;
                                        </td>
                                        <td valign="top" style="font-size: 11px;border-top: dashed 1px;" align="right">
                                            <b style="font-size: 12px;">#dollarformat(ProfitTypePriorYearYTDTotal)#</b>
                                        </td>
                                        <td valign="top" style="font-size: 11px;border-right: solid 1px;border-top: dashed 1px;padding-top: 4px;" width="4%" align="right">
                                            &nbsp;
                                        </td>
                                        <!--- Prior --->


                                        <!--- PriVarianceor --->
                                        <td valign="top" style="font-size: 11px;border-top: dashed 1px;"  align="right">
                                            <b style="font-size: 12px;">#dollarformat(ProfitTypeVarianceMonthTotal)#</b>
                                        </td>
                                        <td valign="top" style="font-size: 11px;border-top: dashed 1px;padding-top: 4px;" align="right">
                                            &nbsp;
                                        </td>
                                        <td valign="top" style="font-size: 11px;border-top: dashed 1px;" align="right">
                                            <b style="font-size: 12px;">#dollarformat(ProfitTypeVarianceYTDTotal)#</b>
                                        </td>
                                        <td valign="top" style="font-size: 11px;border-top: dashed 1px;padding-top: 4px;" width="4%" align="right">
                                            &nbsp;
                                        </td>
                                        <!--- Variance --->
                                    </tr>
                                </cfloop>
                            </tbody>
                        </table>
                    </div>
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
    	<cfcontent variable="#toBinary(IncomeStatement)#" type="application/pdf" /> 	
        <cfcatch>
            <cfset fileName = "Trial Balance Date-#DateFormat(Now(),'mm.dd.yyyy')#.pdf">
            <cfheader name="Content-Disposition" value="inline; filename=#fileName#">
            <cfdocument format="PDF" name="IncomeStatement" margintop="1.5">
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
            <cfcontent variable="#toBinary(IncomeStatement)#" type="application/pdf" />  
        </cfcatch>
    </cftry>
</cfoutput>